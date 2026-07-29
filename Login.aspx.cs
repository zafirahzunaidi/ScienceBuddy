using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace ScienceBuddy
{
    public partial class Login : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Use top-nav layout for guest pages (no sidebar)
            ((SiteMaster)Master).LayoutMode = "TopNav";

            if (!IsPostBack)
                DisplayQueryStringMessage();
        }

        private void DisplayQueryStringMessage()
        {
            string msg = Request.QueryString["msg"];
            if (string.IsNullOrEmpty(msg)) return;

            switch (msg)
            {
                case "reset":
                    ShowSuccess("Your password has been reset. Please sign in with your new password.");
                    break;
                case "registered":
                    ShowSuccess("Registration successful! Please sign in to start your science adventure.");
                    break;
                case "logout":
                    ShowSuccess("You have been signed out safely.");
                    break;
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string enteredUsername = txtUsername.Text.Trim();
            string enteredPassword = txtPassword.Text;

            // Look up user by exact username (case-sensitive binary collation)
            var userRecord = FetchUserByUsername(enteredUsername);

            if (userRecord == null)
            {
                ShowError("Incorrect username or password.");
                return;
            }

            // Check if account is locked due to too many failed attempts
            int maxAttempts = GetConfigInt("Suspicious Login Attempt", 5);
            int lockMinutes = GetConfigInt("Account Lock Duration (Minutes)", 30);

            if (IsAccountLocked(userRecord.UserId, maxAttempts, lockMinutes))
            {
                ShowError("Your account has been temporarily locked due to too many failed login attempts." +
                    "Please try again after " + lockMinutes + " minutes.");
                return;
            }

            // Verify the password using BCrypt (falls back to plain-text for unmigrated accounts)
            if (!PasswordHelper.VerifyPassword(enteredPassword, userRecord.StoredPasswordHash))
            {
                AddLog(userRecord.UserId, "Failed Login", "Incorrect password entered.", "Failed");

                // Check if this attempt triggers the lock
                int recentFails = CountRecentFailedAttempts(userRecord.UserId, lockMinutes) + 1;
                if (recentFails >= maxAttempts)
                {
                    AddLog(userRecord.UserId, "Account Locked", "Account temporarily locked due to " + recentFails + " failed attempts.", "Failed");
                }

                ShowError("Incorrect username or password.");
                return;
            }

            // Check if the account is active, blocked, or deleted
            if (!ValidateAccountStatus(userRecord))
                return;

            // Only recognised roles may proceed
            if (!IsValidRole(userRecord.Role))
            {
                ShowError("Your account role is not recognised. Please contact the administrator.");
                return;
            }

            // Authentication passed — create session and redirect
            AddLog(userRecord.UserId, "Login", "User logged into the system successfully.", "Success");
            CreateUserSession(userRecord.UserId, enteredUsername, userRecord.Role);

            // For students: check if personality test has been completed
            if (userRecord.Role == "Student" && !HasCompletedPersonalityTest(userRecord.UserId))
            {
                Response.Redirect("~/Student/PersonalityTest.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            RedirectToDashboard(userRecord.Role);
        }

        // ────────────────────────────────────────────────────────
        //  BRUTE-FORCE PROTECTION (account-based via Log table)
        // ────────────────────────────────────────────────────────

        private bool IsAccountLocked(string userId, int maxAttempts, int lockMinutes)
        {
            int recentFails = CountRecentFailedAttempts(userId, lockMinutes);
            return recentFails >= maxAttempts;
        }

        private int CountRecentFailedAttempts(string userId, int withinMinutes)
        {
            string connStr = ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
            try
            {
                using (var conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand(@"
                        SELECT COUNT(*) FROM dbo.[Log] 
                        WHERE [userId]=@uid 
                        AND [action]='Failed Login' 
                        AND [logDateTime] >= DATEADD(MINUTE, -@mins, GETDATE())", conn))
                    {
                        cmd.Parameters.AddWithValue("@uid", userId);
                        cmd.Parameters.AddWithValue("@mins", withinMinutes);
                        return Convert.ToInt32(cmd.ExecuteScalar());
                    }
                }
            }
            catch { return 0; }
        }

        private int GetConfigInt(string configKey, int defaultValue)
        {
            string connStr = ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
            try
            {
                using (var conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("SELECT [configValue] FROM dbo.[ConfigurationSetting] WHERE [configKey]=@key", conn))
                    {
                        cmd.Parameters.AddWithValue("@key", configKey);
                        var val = cmd.ExecuteScalar();
                        if (val != null && val != DBNull.Value)
                        {
                            int result;
                            if (int.TryParse(val.ToString(), out result))
                                return result;
                        }
                    }
                }
            }
            catch { }
            return defaultValue;
        }

        // ────────────────────────────────────────────────────────
        //  DATABASE LOOKUP
        // ────────────────────────────────────────────────────────

        private UserRecord FetchUserByUsername(string username)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

            const string query = @"
                SELECT userId, password, role, status
                FROM dbo.[User]
                WHERE username = @username COLLATE Latin1_General_BIN";

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@username", username);
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read())
                            return null;

                        return new UserRecord
                        {
                            UserId = reader["userId"].ToString(),
                            StoredPasswordHash = reader["password"].ToString(),
                            Role = reader["role"].ToString(),
                            Status = reader["status"].ToString()
                        };
                    }
                }
            }
            catch (SqlException)
            {
                ShowError("A system error occurred. Please try again later.");
                return null;
            }
        }

        //  ACCOUNT VALIDATION
        private bool ValidateAccountStatus(UserRecord user)
        {
            switch (user.Status)
            {
                case "Active":
                    return true;

                case "Blocked":
                    ShowError("Your account has been blocked. Please contact the administrator for assistance.");
                    return false;

                case "Deleted":
                    ShowError("This account is no longer available.");
                    return false;

                default:
                    ShowError("Your account status is not valid. Please contact the administrator.");
                    return false;
            }
        }

        private bool IsValidRole(string role)
        {
            return role == "Admin" || role == "Student" || role == "Teacher" || role == "Parent";
        }

        //  SESSION AND REDIRECT
        private void CreateUserSession(string userId, string username, string role)
        {
            Session.Clear(); // remove any leftover session data from a previous user
            Session["userId"] = userId;
            Session["username"] = username;
            Session["role"] = role;
        }

        private void RedirectToDashboard(string role)
        {
            string dashboardUrl;

            switch (role)
            {
                case "Admin":   dashboardUrl = "~/Admin/Dashboard.aspx"; break;
                case "Student": dashboardUrl = "~/Student/Dashboard.aspx"; break;
                case "Teacher": dashboardUrl = "~/Teacher/Dashboard.aspx"; break;
                case "Parent":  dashboardUrl = "~/Parent/ParentDashboard.aspx"; break;
                default:        dashboardUrl = "~/Default.aspx"; break;
            }

            Response.Redirect(dashboardUrl, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        // ────────────────────────────────────────────────────────
        //  HELPER METHODS
        // ────────────────────────────────────────────────────────

        /// <summary>
        /// Looks up the Teacher table to check whether the teacher is Certified, Pending, or Not Certified.
        /// </summary>
        private string GetTeacherCertificationStatus(string userId)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand("SELECT status FROM dbo.[Teacher] WHERE userId = @userId", conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                conn.Open();
                object result = cmd.ExecuteScalar();
                return (result != null && result != DBNull.Value) ? result.ToString() : "";
            }
        }

        private void ShowError(string message)
        {
            pnlError.Visible = true;
            pnlSuccess.Visible = false;
            litError.Text = Server.HtmlEncode(message);
        }

        private void ShowSuccess(string message)
        {
            pnlSuccess.Visible = true;
            pnlError.Visible = false;
            litSuccess.Text = Server.HtmlEncode(message);
        }

        //  LOGGING

        private void AddLog(string userId, string action, string description, string status)
        {
            try
            {
                string connStr = ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    string logId = "LOG001";
                    using (SqlCommand cmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING(logId,4,LEN(logId)-3) AS INT)),0) FROM Log WHERE logId LIKE 'LOG[0-9]%'", conn))
                    {
                        logId = "LOG" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3");
                    }
                    using (SqlCommand cmd = new SqlCommand("INSERT INTO Log(logId,userId,action,description,logDateTime,status) VALUES(@lid,@uid,@act,@desc,@dt,@st)", conn))
                    {
                        cmd.Parameters.AddWithValue("@lid", logId);
                        cmd.Parameters.AddWithValue("@uid", userId);
                        cmd.Parameters.AddWithValue("@act", action);
                        cmd.Parameters.AddWithValue("@desc", description);
                        cmd.Parameters.AddWithValue("@dt", DateTime.Now);
                        cmd.Parameters.AddWithValue("@st", status);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Log error: " + ex.Message);
            }
        }

        //  PERSONALITY TEST CHECK

        private bool HasCompletedPersonalityTest(string userId)
        {
            string connStr = ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT personalityId FROM Student WHERE userId = @uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    object result = cmd.ExecuteScalar();
                    return result != null && result != DBNull.Value;
                }
            }
        }

        //  INNER CLASS: holds one row from the User table

        private class UserRecord
        {
            public string UserId;
            public string StoredPasswordHash;
            public string Role;
            public string Status;
        }
    }
}
