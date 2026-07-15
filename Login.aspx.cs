using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace ScienceBuddy
{
    public partial class Login : Page
    {
        // ── Page lifecycle ────────────────────────────────────────────
        protected void Page_Load(object sender, EventArgs e)
        {
            ((SiteMaster)Master).LayoutMode = "TopNav";

            if (!IsPostBack)
            {
                // Show contextual messages from redirect query strings.
                string msg = Request.QueryString["msg"];
                if (!string.IsNullOrEmpty(msg))
                {
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
            }
        }

        // ── Login button click ────────────────────────────────────────
        protected void btnLogin_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text;   // plain-text match against [User].password

            string connStr = ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

            // Retrieve userId, role, and status for the matching username + password.
            // Uses parameterised query — no string concatenation.
            const string sql = @"
                SELECT userId, role, status
                FROM   [User]
                WHERE  username = @username
                AND    password = @password";

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@username", username);
                    cmd.Parameters.AddWithValue("@password", password);

                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read())
                        {
                            // No row found — username or password is wrong.
                            ShowError("Incorrect username or password. Please try again.");
                            return;
                        }

                        string userId = reader["userId"].ToString();
                        string role   = reader["role"].ToString();
                        string status = reader["status"].ToString();

                        reader.Close();
                        conn.Close();

                        // ── Status checks ─────────────────────────────────
                        switch (status)
                        {
                            case "Active":
                                // Proceed to session setup and redirect below.
                                break;

                            case "Blocked":
                                // Check if blocked Teacher with Not Certified status
                                if (role == "Teacher")
                                {
                                    string tStatus = GetTeacherStatus(userId);
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
                                ShowError("This account no longer exists. Please register for a new account.");
                                return;

                            default:
                                ShowError("Your account status is not valid. Please contact the administrator.");
                                return;
                        }

                        // ── Store session values ──────────────────────────
                        Session["userId"]   = userId;
                        Session["username"] = username;
                        Session["role"]     = role;

                        // ── Teacher status check ──────────────────────────
                        if (role == "Teacher")
                        {
                            string teacherStatus = GetTeacherStatus(userId);
                            if (teacherStatus == "Pending")
                            {
                                Session.Clear();
                                Session["TeacherStatusUserId"] = userId;
                                Response.Redirect("~/TeacherRegistrationStatus.aspx", false);
                                Context.ApplicationInstance.CompleteRequest();
                                return;
                            }
                            else if (teacherStatus != "Certified")
                            {
                                Session.Clear();
                                ShowError("Your teacher account is not yet approved. Please contact support.");
                                return;
                            }
                        }

                        // ── Redirect by role ──────────────────────────────
                        switch (role)
                        {
                            case "Admin":
                                Response.Redirect("~/Admin/Dashboard.aspx", false);
                                break;

                            case "Student":
                                Response.Redirect("~/Student/Dashboard.aspx", false);
                                break;

                            case "Teacher":
                                Response.Redirect("~/Teacher/Dashboard.aspx", false);
                                break;

                            case "Parent":
                                Response.Redirect("~/Parent/ParentDashboard.aspx", false);
                                break;

                            default:
                                // Unknown role — clear session and show error.
                                Session.Clear();
                                ShowError("Your account role is not recognised. Please contact the administrator.");
                                break;
                        }
                    }
                }
            }
            catch (SqlException)
            {
                // Do not expose database error details to the user.
                ShowError("A system error occurred. Please try again later.");
            }
        }

        // ── UI helpers ────────────────────────────────────────────────
        private void ShowError(string message)
        {
            pnlError.Visible   = true;
            pnlSuccess.Visible = false;
            litError.Text      = System.Web.HttpUtility.HtmlEncode(message);
        }

        private void ShowSuccess(string message)
        {
            pnlSuccess.Visible = true;
            pnlError.Visible   = false;
            litSuccess.Text    = System.Web.HttpUtility.HtmlEncode(message);
        }

        private string GetTeacherStatus(string userId)
        {
            string connStr = ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
            try
            {
                using (var conn = new SqlConnection(connStr))
                using (var cmd = new SqlCommand("SELECT status FROM dbo.[Teacher] WHERE userId=@uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    conn.Open();
                    var result = cmd.ExecuteScalar();
                    return result != null && result != DBNull.Value ? result.ToString() : "";
                }
            }
            catch { return ""; }
        }
    }
}
