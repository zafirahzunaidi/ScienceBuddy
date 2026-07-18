using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.Services;
using System.Web.UI;

// Admin Profile - Code Behind

namespace ScienceBuddy.Admin
{
    public partial class Profile : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected string CurrentLanguage => ((ScienceBuddy.SiteMaster)Master).CurrentLanguage;

        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null)
            { Response.Redirect("~/Login.aspx", false); return; }
            if (Session["role"] == null || Session["role"].ToString() != "Admin")
            { Response.Redirect("~/Login.aspx", false); return; }

            var master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            if (!IsPostBack)
                LoadProfile(Session["userId"].ToString());
        }

        private void LoadProfile(string userId)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(
                    "SELECT [username],[email],[role],[preferredLanguage],[status] FROM dbo.[User] WHERE [userId]=@uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string username = reader["username"]?.ToString() ?? "-";
                            string email    = reader["email"]?.ToString() ?? "-";
                            string role     = reader["role"]?.ToString() ?? "Admin";
                            string lang     = reader["preferredLanguage"]?.ToString() ?? "EN";
                            string status   = reader["status"]?.ToString() ?? "-";

                            // Hero section
                            litUsername.Text  = HttpUtility.HtmlEncode(username);
                            litEmail.Text    = HttpUtility.HtmlEncode(email);
                            litRole.Text     = T("Administrator", "Pentadbir");
                            litLanguage.Text = lang == "BM" ? "Bahasa Melayu" : "English";
                            litStatus.Text   = "<span class='ad-profile-status'><span class='ad-profile-status-dot'></span>" + HttpUtility.HtmlEncode(status) + "</span>";
                            litInitials.Text = username.Length >= 2
                                ? username.Substring(0, 2).ToUpper()
                                : username.ToUpper();

                            // Card fields
                            litUsernameVal.Text = HttpUtility.HtmlEncode(username);
                            litEmailVal.Text = HttpUtility.HtmlEncode(email);
                            litRoleVal.Text = T("Administrator", "Pentadbir");
                            litLangVal.Text = lang == "BM" ? "Bahasa Melayu" : "English";

                            // Hidden fields for modal pre-population
                            hfUserId.Value = userId;
                            hfCurrentName.Value = username;
                            hfCurrentEmail.Value = email;
                            hfCurrentLang.Value = lang;
                            hfCurrentStatus.Value = status;

                            // Master user widget
                            string ini = username.Length >= 2 ? username.Substring(0, 2).ToUpper() : username.ToUpper();
                            ((ScienceBuddy.SiteMaster)Master).SetUserInfo(username, "Administrator", ini);
                        }
                    }
                }
            }
        }

        // ── AJAX WebMethod for profile saving ────────────────────────
        [WebMethod(EnableSession = true)]
        public static object SaveProfile(string displayName, string email, string language)
        {
            // Session check
            if (HttpContext.Current.Session["userId"] == null ||
                HttpContext.Current.Session["role"]?.ToString() != "Admin")
            {
                return new { success = false, message = "Unauthorized." };
            }

            string userId = HttpContext.Current.Session["userId"].ToString();

            // Server-side validation
            if (string.IsNullOrWhiteSpace(displayName))
                return new { success = false, message = "Display name cannot be empty." };
            if (string.IsNullOrWhiteSpace(email) || !email.Contains("@") || !email.Contains("."))
                return new { success = false, message = "Please enter a valid email address." };
            if (language != "EN" && language != "BM")
                language = "EN";

            displayName = displayName.Trim();
            email = email.Trim();

            string connStr = ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

            try
            {
                using (var conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    // Check email uniqueness (excluding current user)
                    using (var checkCmd = new SqlCommand(
                        "SELECT COUNT(*) FROM dbo.[User] WHERE [email]=@email AND [userId]<>@uid", conn))
                    {
                        checkCmd.Parameters.AddWithValue("@email", email);
                        checkCmd.Parameters.AddWithValue("@uid", userId);
                        int count = Convert.ToInt32(checkCmd.ExecuteScalar());
                        if (count > 0)
                            return new { success = false, message = "This email address is already in use by another account." };
                    }

                    // Update only: username, email, preferredLanguage
                    using (var updateCmd = new SqlCommand(
                        @"UPDATE dbo.[User] 
                          SET [username]=@name, [email]=@email, [preferredLanguage]=@lang 
                          WHERE [userId]=@uid", conn))
                    {
                        updateCmd.Parameters.AddWithValue("@name", displayName);
                        updateCmd.Parameters.AddWithValue("@email", email);
                        updateCmd.Parameters.AddWithValue("@lang", language);
                        updateCmd.Parameters.AddWithValue("@uid", userId);
                        updateCmd.ExecuteNonQuery();
                    }
                }

                return new { success = true, message = "Profile updated successfully." };
            }
            catch (Exception ex)
            {
                return new { success = false, message = "An error occurred: " + ex.Message };
            }
        }
    }
}
