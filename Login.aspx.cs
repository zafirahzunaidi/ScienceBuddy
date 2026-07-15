using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace ScienceBuddy
{
    public partial class Login : Page
    {
        private const int MaxAttempts = 5;
        private const int LockoutMinutes = 5;

        protected void Page_Load(object sender, EventArgs e)
        {
            ((SiteMaster)Master).LayoutMode = "TopNav";

            if (!IsPostBack)
            {
                string msg = Request.QueryString["msg"];
                if (!string.IsNullOrEmpty(msg))
                {
                    switch (msg)
                    {
                        case "reset": ShowSuccess("Your password has been reset. Please sign in with your new password."); break;
                        case "registered": ShowSuccess("Registration successful! Please sign in to start your science adventure."); break;
                        case "logout": ShowSuccess("You have been signed out safely."); break;
                    }
                }
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            // 1. Throttling check
            if (IsLockedOut())
            {
                ShowError("Too many unsuccessful sign-in attempts. Please wait before trying again.");
                return;
            }

            string identifier = txtUsername.Text.Trim();
            string password = txtPassword.Text; // never trim passwords

            string connStr = ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

            // 2. Query by username OR email
            const string sql = @"
                SELECT userId, password, role, status
                FROM   dbo.[User]
                WHERE  username = @identifier OR email = @identifier";

            try
            {
                using (var conn = new SqlConnection(connStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@identifier", identifier);
                    conn.Open();

                    string userId = null, storedPassword = null, role = null, status = null;

                    using (var reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read())
                        {
                            RecordFailedAttempt();
                            ShowError("Incorrect username/email or password.");
                            return;
                        }
                        userId = reader["userId"].ToString();
                        storedPassword = reader["password"].ToString();
                        role = reader["role"].ToString();
                        status = reader["status"].ToString();
                    }

                    // 3. BCrypt verification
                    if (!PasswordHelper.VerifyPassword(password, storedPassword))
                    {
                        RecordFailedAttempt();
                        ShowError("Incorrect username/email or password.");
                        return;
                    }

                    // 4. Account status check
                    switch (status)
                    {
                        case "Active":
                            break;
                        case "Blocked":
                            if (role == "Teacher")
                            {
                                string tStatus = GetTeacherStatus(conn, userId);
                                if (tStatus == "Not Certified")
                                {
                                    Session["TeacherStatusUserId"] = userId;
                                    Response.Redirect("~/TeacherRegistrationStatus.aspx", false);
                                    Context.ApplicationInstance.CompleteRequest();
                                    return;
                                }
                            }
                            ShowError("Your account has been blocked. Please contact the administrator for assistance.");
                            return;
                        case "Deleted":
                            ShowError("This account is no longer available.");
                            return;
                        default:
                            ShowError("Your account status is not valid. Please contact the administrator.");
                            return;
                    }

                    // 5. Teacher-specific approval check (before session creation)
                    if (role == "Teacher")
                    {
                        string teacherStatus = GetTeacherStatus(conn, userId);
                        if (teacherStatus == "Pending")
                        {
                            Session["TeacherStatusUserId"] = userId;
                            Response.Redirect("~/TeacherRegistrationStatus.aspx", false);
                            Context.ApplicationInstance.CompleteRequest();
                            return;
                        }
                        else if (teacherStatus != "Certified")
                        {
                            ShowError("Your teacher account is not yet approved. Please contact support.");
                            return;
                        }
                    }

                    // 6. Validate role
                    if (role != "Admin" && role != "Student" && role != "Teacher" && role != "Parent")
                    {
                        ShowError("Your account role is not recognised. Please contact the administrator.");
                        return;
                    }

                    // 7. Reset throttle + clear stale session + create new session
                    ResetFailedAttempts();
                    Session.Clear();
                    Session["userId"] = userId;
                    Session["username"] = identifier;
                    Session["role"] = role;

                    // 8. Redirect by role
                    switch (role)
                    {
                        case "Admin": Response.Redirect("~/Admin/Dashboard.aspx", false); break;
                        case "Student": Response.Redirect("~/Student/Dashboard.aspx", false); break;
                        case "Teacher": Response.Redirect("~/Teacher/Dashboard.aspx", false); break;
                        case "Parent": Response.Redirect("~/Parent/ParentDashboard.aspx", false); break;
                    }
                    Context.ApplicationInstance.CompleteRequest();
                }
            }
            catch (SqlException)
            {
                ShowError("A system error occurred. Please try again later.");
            }
        }

        // ── Throttling (Session-based) ──
        private bool IsLockedOut()
        {
            var lockoutUntil = Session["LoginLockoutUntil"] as DateTime?;
            if (lockoutUntil.HasValue && DateTime.Now < lockoutUntil.Value)
                return true;
            if (lockoutUntil.HasValue && DateTime.Now >= lockoutUntil.Value)
            { Session.Remove("LoginLockoutUntil"); Session.Remove("LoginFailedAttempts"); }
            return false;
        }

        private void RecordFailedAttempt()
        {
            int attempts = Session["LoginFailedAttempts"] as int? ?? 0;
            attempts++;
            Session["LoginFailedAttempts"] = attempts;

            if (attempts >= MaxAttempts)
            {
                Session["LoginLockoutUntil"] = DateTime.Now.AddMinutes(LockoutMinutes);
            }
        }

        private void ResetFailedAttempts()
        {
            Session.Remove("LoginFailedAttempts");
            Session.Remove("LoginLockoutUntil");
        }

        // ── Helpers ──
        private string GetTeacherStatus(SqlConnection conn, string userId)
        {
            using (var cmd = new SqlCommand("SELECT status FROM dbo.[Teacher] WHERE userId=@uid", conn))
            {
                cmd.Parameters.AddWithValue("@uid", userId);
                var result = cmd.ExecuteScalar();
                return result != null && result != DBNull.Value ? result.ToString() : "";
            }
        }

        private void ShowError(string message)
        {
            pnlError.Visible = true;
            pnlSuccess.Visible = false;
            litError.Text = System.Web.HttpUtility.HtmlEncode(message);
        }

        private void ShowSuccess(string message)
        {
            pnlSuccess.Visible = true;
            pnlError.Visible = false;
            litSuccess.Text = System.Web.HttpUtility.HtmlEncode(message);
        }
    }
}
