using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace ScienceBuddy
{
    public partial class Login : Page
    {
        // Brute-force protection: lock the user out after 5 failed attempts for 5 minutes
        private const int MaxLoginAttempts = 5;
        private const int LockoutDurationMinutes = 5;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Use top-nav layout for guest pages (no sidebar)
            ((SiteMaster)Master).LayoutMode = "TopNav";

            if (!IsPostBack)
                DisplayQueryStringMessage();
        }

        /// <summary>
        /// Shows a status banner if the user arrived from password reset, registration, or logout.
        /// </summary>
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

            if (IsLockedOut())
            {
                ShowError("Too many unsuccessful sign-in attempts. Please wait before trying again.");
                return;
            }

            string enteredUsername = txtUsername.Text.Trim();
            string enteredPassword = txtPassword.Text; // passwords must never be trimmed or modified

            // Look up user by exact username (case-sensitive binary collation)
            var userRecord = FetchUserByUsername(enteredUsername);

            if (userRecord == null)
            {
                RecordFailedAttempt();
                ShowError("Incorrect username or password.");
                return;
            }

            // Verify the password using BCrypt (falls back to plain-text for unmigrated accounts)
            if (!PasswordHelper.VerifyPassword(enteredPassword, userRecord.StoredPasswordHash))
            {
                RecordFailedAttempt();
                AddLog(userRecord.UserId, "Failed Login", "Incorrect password entered.", "Failed");
                if ((Session["LoginFailedAttempts"] as int?) >= MaxLoginAttempts)
                {
                    AddLog(userRecord.UserId, "Account Locked", "Account temporarily locked due to too many failed attempts.", "Failed");
                }
                ShowError("Incorrect username or password.");
                return;
            }

            // Check if the account is active, blocked, or deleted
            if (!ValidateAccountStatus(userRecord))
                return;

            // Teachers need additional certification approval before they can log in
            if (userRecord.Role == "Teacher" && !ValidateTeacherApproval(userRecord))
                return;

            // Only recognised roles may proceed
            if (!IsValidRole(userRecord.Role))
            {
                ShowError("Your account role is not recognised. Please contact the administrator.");
                return;
            }

            // Authentication passed — create session and redirect
            ResetFailedAttempts();
            AddLog(userRecord.UserId, "Login", "User logged into the system successfully.", "Success");
            CreateUserSession(userRecord.UserId, enteredUsername, userRecord.Role);
            RedirectToDashboard(userRecord.Role);
        }

        // ────────────────────────────────────────────────────────
        //  DATABASE LOOKUP
        // ────────────────────────────────────────────────────────

        /// <summary>
        /// Queries the User table for the given username using binary collation
        /// so that "aminah" will NOT match "Aminah" or "AMINAH".
        /// </summary>
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

        // ────────────────────────────────────────────────────────
        //  ACCOUNT VALIDATION
        // ────────────────────────────────────────────────────────

        /// <summary>
        /// Returns true if the account is active and can proceed to login.
        /// Shows appropriate error messages for blocked or deleted accounts.
        /// </summary>
        private bool ValidateAccountStatus(UserRecord user)
        {
            switch (user.Status)
            {
                case "Active":
                    return true;

                case "Blocked":
                    // A blocked Teacher who was never certified should see their status page
                    if (user.Role == "Teacher")
                    {
                        string certStatus = GetTeacherCertificationStatus(user.UserId);
                        if (certStatus == "Not Certified")
                        {
                            Session["TeacherStatusUserId"] = user.UserId;
                            Response.Redirect("~/TeacherRegistrationStatus.aspx", false);
                            Context.ApplicationInstance.CompleteRequest();
                            return false;
                        }
                    }
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

        /// <summary>
        /// Teachers must be "Certified" before they can log in.
        /// Pending teachers are redirected to a waiting page.
        /// </summary>
        private bool ValidateTeacherApproval(UserRecord user)
        {
            string certificationStatus = GetTeacherCertificationStatus(user.UserId);

            if (certificationStatus == "Pending")
            {
                Session["TeacherStatusUserId"] = user.UserId;
                Response.Redirect("~/TeacherRegistrationStatus.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return false;
            }

            if (certificationStatus != "Certified")
            {
                ShowError("Your teacher account is not yet approved. Please contact support.");
                return false;
            }

            return true;
        }

        private bool IsValidRole(string role)
        {
            return role == "Admin" || role == "Student" || role == "Teacher" || role == "Parent";
        }

        // ────────────────────────────────────────────────────────
        //  SESSION AND REDIRECT
        // ────────────────────────────────────────────────────────

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
        //  BRUTE-FORCE THROTTLING (session-based)
        // ────────────────────────────────────────────────────────

        private bool IsLockedOut()
        {
            DateTime? lockoutExpiry = Session["LoginLockoutUntil"] as DateTime?;

            if (!lockoutExpiry.HasValue)
                return false;

            // Lockout has expired — clear it and allow the attempt
            if (DateTime.Now >= lockoutExpiry.Value)
            {
                Session.Remove("LoginLockoutUntil");
                Session.Remove("LoginFailedAttempts");
                return false;
            }

            return true;
        }

        private void RecordFailedAttempt()
        {
            int failedCount = (Session["LoginFailedAttempts"] as int?) ?? 0;
            failedCount++;
            Session["LoginFailedAttempts"] = failedCount;

            if (failedCount >= MaxLoginAttempts)
                Session["LoginLockoutUntil"] = DateTime.Now.AddMinutes(LockoutDurationMinutes);
        }

        private void ResetFailedAttempts()
        {
            Session.Remove("LoginFailedAttempts");
            Session.Remove("LoginLockoutUntil");
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

        // ────────────────────────────────────────────────────────
        //  LOGGING
        // ────────────────────────────────────────────────────────

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

        // ────────────────────────────────────────────────────────
        //  INNER CLASS: holds one row from the User table
        // ────────────────────────────────────────────────────────

        private class UserRecord
        {
            public string UserId;
            public string StoredPasswordHash;
            public string Role;
            public string Status;
        }
    }
}
