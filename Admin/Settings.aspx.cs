using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

// Admin Settings - Code Behind

namespace ScienceBuddy.Admin
{
    public partial class Settings : Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected string CurrentLanguage =>
            ((ScienceBuddy.SiteMaster)Master).CurrentLanguage;

        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // Handle AJAX POST actions
            if (Request.HttpMethod == "POST" && Request.Form["action"] != null)
            {
                HandleAjax();
                return;
            }

            if (Session["userId"] == null)
            { Response.Redirect("~/Login.aspx", false); return; }
            if (Session["role"] == null || Session["role"].ToString() != "Admin")
            { Response.Redirect("~/Login.aspx", false); return; }

            var master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            if (!IsPostBack)
                LoadSettings(Session["userId"].ToString());
        }

        private void LoadSettings(string userId)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(
                    "SELECT [username],[preferredLanguage],[status],[role] FROM dbo.[User] WHERE [userId]=@uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string username = reader["username"]?.ToString() ?? "Admin";
                            string lang = reader["preferredLanguage"]?.ToString() ?? "EN";
                            string status = reader["status"]?.ToString() ?? "Active";
                            string role = reader["role"]?.ToString() ?? "Admin";

                            litLang.Text = lang == "BM" ? "Bahasa Melayu (BM)" : "English (EN)";
                            litStatus.Text = status;
                            litRole.Text = role == "Admin" ? "Administrator" : role;

                            string ini = username.Length >= 2 ? username.Substring(0, 2).ToUpper() : username.ToUpper();
                            ((ScienceBuddy.SiteMaster)Master).SetUserInfo(username, "Administrator", ini);
                        }
                    }
                }

                // Last login from Log table
                using (var cmd = new SqlCommand(
                    "SELECT TOP 1 [logDateTime] FROM dbo.[Log] WHERE [userId]=@uid AND [action]='Login' ORDER BY [logDateTime] DESC", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    var val = cmd.ExecuteScalar();
                    litLastLogin.Text = val != null && val != DBNull.Value
                        ? Convert.ToDateTime(val).ToString("dd MMM yyyy, hh:mm tt")
                        : T("Never", "Tiada");
                }

                // Last password change from Log table
                using (var cmd = new SqlCommand(
                    "SELECT TOP 1 [logDateTime] FROM dbo.[Log] WHERE [userId]=@uid AND [action]='Change Password' ORDER BY [logDateTime] DESC", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    var val = cmd.ExecuteScalar();
                    litLastPwChange.Text = val != null && val != DBNull.Value
                        ? Convert.ToDateTime(val).ToString("dd MMM yyyy, hh:mm tt")
                        : T("Never changed", "Belum pernah ditukar");
                }

                // Server time
                litServerTime.Text = DateTime.Now.ToString("dd MMM yyyy, hh:mm:ss tt");

                // Load notification preferences from ConfigurationSetting
                LoadNotificationPreferences(conn, userId);
            }
        }

        private void LoadNotificationPreferences(SqlConnection conn, string userId)
        {
            // Notification prefs stored as: NOTIF_<userId>_<key>
            string prefix = "NOTIF_" + userId + "_";
            string[] keys = { "emailNotif", "sysAnnounce", "teacherReg", "materialReq", "questionReq", "quizReview" };

            string script = "window.addEventListener('load',function(){";
            foreach (var key in keys)
            {
                string configKey = prefix + key;
                string val = "1"; // default ON
                using (var cmd = new SqlCommand(
                    "SELECT [configValue] FROM dbo.[ConfigurationSetting] WHERE [configKey]=@k", conn))
                {
                    cmd.Parameters.AddWithValue("@k", configKey);
                    var result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                        val = result.ToString();
                }
                string chkId = "chk" + char.ToUpper(key[0]) + key.Substring(1);
                // Fix: chkEmailNotif, chkSysAnnounce, etc.
                if (key == "emailNotif") chkId = "chkEmailNotif";
                else if (key == "sysAnnounce") chkId = "chkSysAnnounce";
                else if (key == "teacherReg") chkId = "chkTeacherReg";
                else if (key == "materialReq") chkId = "chkMaterialReq";
                else if (key == "questionReq") chkId = "chkQuestionReq";
                else if (key == "quizReview") chkId = "chkQuizReview";

                script += "var e=document.getElementById('" + chkId + "');if(e)e.checked=" + (val == "1" ? "true" : "false") + ";";
            }
            script += "initNotifState();});";

            ClientScript.RegisterStartupScript(GetType(), "notifPrefs", script, true);
        }

        // ══════════════════════════════════════════════════════════
        // AJAX Handler
        // ══════════════════════════════════════════════════════════
        private void HandleAjax()
        {
            Response.ContentType = "application/json";
            string action = Request.Form["action"];

            if (Session["userId"] == null || Session["role"]?.ToString() != "Admin")
            {
                Response.Write("{\"success\":false,\"message\":\"Unauthorized\"}");
                Response.End();
                return;
            }

            string userId = Session["userId"].ToString();

            try
            {
                switch (action)
                {
                    case "ChangePassword": HandleChangePassword(userId); break;
                    case "SaveNotifications": HandleSaveNotifications(userId); break;
                    case "SignOutAll": HandleSignOutAll(userId); break;
                    case "DeleteAccount": HandleDeleteAccount(userId); break;
                    default:
                        Response.Write("{\"success\":false,\"message\":\"Unknown action\"}");
                        break;
                }
            }
            catch (Exception ex)
            {
                Response.Write("{\"success\":false,\"message\":\"" + EscapeJson(ex.Message) + "\"}");
            }
            Response.End();
        }

        private void HandleChangePassword(string userId)
        {
            string currentPwd = Request.Form["currentPassword"] ?? "";
            string newPwd = Request.Form["newPassword"] ?? "";

            if (string.IsNullOrWhiteSpace(currentPwd) || string.IsNullOrWhiteSpace(newPwd))
            {
                Response.Write("{\"success\":false,\"message\":\"Missing fields.\"}");
                return;
            }
            if (newPwd.Length < 8)
            {
                Response.Write("{\"success\":false,\"message\":\"Password must be at least 8 characters.\"}");
                return;
            }

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Verify current password
                string dbPassword = "";
                using (var cmd = new SqlCommand("SELECT [password] FROM dbo.[User] WHERE [userId]=@uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    var val = cmd.ExecuteScalar();
                    dbPassword = val?.ToString() ?? "";
                }

                if (dbPassword != currentPwd)
                {
                    Response.Write("{\"success\":false,\"field\":\"current\",\"message\":\"" + EscapeJson(T("Current password is incorrect.", "Kata laluan semasa tidak betul.")) + "\"}");
                    return;
                }

                // Update password
                using (var cmd = new SqlCommand("UPDATE dbo.[User] SET [password]=@pwd WHERE [userId]=@uid", conn))
                {
                    cmd.Parameters.AddWithValue("@pwd", newPwd);
                    cmd.Parameters.AddWithValue("@uid", userId);
                    cmd.ExecuteNonQuery();
                }

                // Insert log
                InsertLog(conn, userId, "Change Password", "Administrator changed their password.");
            }

            Response.Write("{\"success\":true}");
        }

        private void HandleSaveNotifications(string userId)
        {
            string[] keys = { "emailNotif", "sysAnnounce", "teacherReg", "materialReq", "questionReq", "quizReview" };
            string prefix = "NOTIF_" + userId + "_";

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                foreach (var key in keys)
                {
                    string configKey = prefix + key;
                    string val = Request.Form[key] ?? "0";

                    // Check if exists
                    bool exists = false;
                    string existingId = "";
                    using (var cmd = new SqlCommand("SELECT [configId] FROM dbo.[ConfigurationSetting] WHERE [configKey]=@k", conn))
                    {
                        cmd.Parameters.AddWithValue("@k", configKey);
                        var result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            exists = true;
                            existingId = result.ToString();
                        }
                    }

                    if (exists)
                    {
                        using (var cmd = new SqlCommand("UPDATE dbo.[ConfigurationSetting] SET [configValue]=@v,[lastUpdated]=@d WHERE [configKey]=@k", conn))
                        {
                            cmd.Parameters.AddWithValue("@v", val);
                            cmd.Parameters.AddWithValue("@d", DateTime.Now);
                            cmd.Parameters.AddWithValue("@k", configKey);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    else
                    {
                        string newId = GenerateConfigId(conn);
                        using (var cmd = new SqlCommand("INSERT INTO dbo.[ConfigurationSetting]([configId],[configKey],[configValue],[lastUpdated]) VALUES(@id,@k,@v,@d)", conn))
                        {
                            cmd.Parameters.AddWithValue("@id", newId);
                            cmd.Parameters.AddWithValue("@k", configKey);
                            cmd.Parameters.AddWithValue("@v", val);
                            cmd.Parameters.AddWithValue("@d", DateTime.Now);
                            cmd.ExecuteNonQuery();
                        }
                    }
                }

                InsertLog(conn, userId, "Update Settings", "Administrator updated notification preferences.");
            }

            Response.Write("{\"success\":true}");
        }

        private void HandleSignOutAll(string userId)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                InsertLog(conn, userId, "Sign Out All", "Administrator signed out from all devices.");
            }

            // Clear session
            Session.Clear();
            Session.Abandon();

            Response.Write("{\"success\":true,\"redirect\":\"" + ResolveUrl("~/Login.aspx") + "\"}");
        }

        private void HandleDeleteAccount(string userId)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Soft delete: set status to Deleted
                using (var cmd = new SqlCommand("UPDATE dbo.[User] SET [status]='Deleted' WHERE [userId]=@uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    cmd.ExecuteNonQuery();
                }

                InsertLog(conn, userId, "Delete Account", "Administrator soft-deleted their account.");
            }

            // Clear session
            Session.Clear();
            Session.Abandon();

            Response.Write("{\"success\":true,\"redirect\":\"" + ResolveUrl("~/Login.aspx") + "\"}");
        }

        // ══════════════════════════════════════════════════════════
        // Utility Methods
        // ══════════════════════════════════════════════════════════
        private void InsertLog(SqlConnection conn, string userId, string action, string description)
        {
            string logId = GenerateLogId(conn);
            using (var cmd = new SqlCommand(
                "INSERT INTO dbo.[Log]([logId],[userId],[action],[description],[logDateTime],[status]) VALUES(@id,@uid,@a,@d,@dt,'Success')", conn))
            {
                cmd.Parameters.AddWithValue("@id", logId);
                cmd.Parameters.AddWithValue("@uid", userId);
                cmd.Parameters.AddWithValue("@a", action);
                cmd.Parameters.AddWithValue("@d", description);
                cmd.Parameters.AddWithValue("@dt", DateTime.Now);
                cmd.ExecuteNonQuery();
            }
        }

        private string GenerateLogId(SqlConnection conn)
        {
            using (var cmd = new SqlCommand("SELECT TOP 1 [logId] FROM dbo.[Log] ORDER BY [logId] DESC", conn))
            {
                var val = cmd.ExecuteScalar();
                if (val != null && val != DBNull.Value)
                {
                    string last = val.ToString();
                    if (last.StartsWith("LOG") && int.TryParse(last.Substring(3), out int num))
                        return "LOG" + (num + 1).ToString("D4");
                }
            }
            return "LOG0001";
        }

        private string GenerateConfigId(SqlConnection conn)
        {
            using (var cmd = new SqlCommand("SELECT TOP 1 [configId] FROM dbo.[ConfigurationSetting] ORDER BY [configId] DESC", conn))
            {
                var val = cmd.ExecuteScalar();
                if (val != null && val != DBNull.Value)
                {
                    string last = val.ToString();
                    // configId format: CONFIG001, CONFIG002, etc.
                    if (last.StartsWith("CONFIG") && int.TryParse(last.Substring(6), out int num))
                        return "CONFIG" + (num + 1).ToString("D3");
                }
            }
            return "CONFIG100";
        }

        private static string EscapeJson(string s)
        {
            if (string.IsNullOrEmpty(s)) return "";
            return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "");
        }
    }
}
