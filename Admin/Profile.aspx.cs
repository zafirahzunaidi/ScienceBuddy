using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

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

                            litUsername.Text  = HttpUtility.HtmlEncode(username);
                            litEmail.Text    = HttpUtility.HtmlEncode(email);
                            litRole.Text     = T("Administrator", "Pentadbir");
                            litLanguage.Text = lang == "BM" ? "Bahasa Melayu" : "English";
                            litStatus.Text   = "<span class='ap-status'><span class='ap-status-dot'></span>" + HttpUtility.HtmlEncode(status) + "</span>";
                            litInitials.Text = username.Length >= 2
                                ? username.Substring(0, 2).ToUpper()
                                : username.ToUpper();

                            // Duplicate fields for the card layout
                            litUsernameVal.Text = HttpUtility.HtmlEncode(username);
                            litEmailVal.Text = HttpUtility.HtmlEncode(email);
                            litRoleVal.Text = T("Administrator", "Pentadbir");
                            litLangVal.Text = lang == "BM" ? "Bahasa Melayu" : "English";

                            // Master user widget
                            string ini = username.Length >= 2 ? username.Substring(0, 2).ToUpper() : username.ToUpper();
                            ((ScienceBuddy.SiteMaster)Master).SetUserInfo(username, "Administrator", ini);
                        }
                    }
                }
            }
        }
    }
}
