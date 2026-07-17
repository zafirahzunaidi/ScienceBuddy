using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

// Admin SystemSettings - Code Behind

namespace ScienceBuddy.Admin
{
    public partial class SystemSettings : Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected string CurrentLanguage =>
            ((ScienceBuddy.SiteMaster)Master).CurrentLanguage;

        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        // Store config data loaded on Page_Load
        private static Dictionary<string, ConfigItem> _configCache;

        private class ConfigItem
        {
            public string Value { get; set; }
            public string Key { get; set; }
            public string Updated { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // Handle AJAX save request
            if (Request.QueryString["handler"] == "SaveConfig" && Request.HttpMethod == "POST")
            {
                HandleAjaxSave();
                return;
            }

            if (Session["userId"] == null || Session["role"] == null || Session["role"].ToString() != "Admin")
            {
                Response.Redirect("~/Login.aspx", false); return;
            }

            var master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                LoadConfigData();
                LoadSummary();
                SetUserInfo();
            }
        }

        private void HandleAjaxSave()
        {
            Response.ContentType = "application/json";
            try
            {
                if (Session["userId"] == null || Session["role"] == null || Session["role"].ToString() != "Admin")
                {
                    Response.Write("{\"success\":false,\"message\":\"Unauthorized\"}");
                    Response.End();
                    return;
                }

                string configId = Request.QueryString["configId"];
                string newValue = Request.QueryString["newValue"];
                string userId = Session["userId"].ToString();

                if (string.IsNullOrWhiteSpace(configId) || string.IsNullOrWhiteSpace(newValue))
                {
                    Response.Write("{\"success\":false,\"message\":\"Missing parameters\"}");
                    Response.End();
                    return;
                }

                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // Get current value and key
                    string oldValue = "";
                    string configKey = "";
                    using (var cmd = new SqlCommand("SELECT [configKey],[configValue] FROM dbo.[ConfigurationSetting] WHERE [configId]=@id", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", configId);
                        using (var reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                configKey = reader["configKey"]?.ToString() ?? "";
                                oldValue = reader["configValue"]?.ToString() ?? "";
                            }
                            else
                            {
                                Response.Write("{\"success\":false,\"message\":\"Configuration not found\"}");
                                Response.End();
                                return;
                            }
                        }
                    }

                    if (oldValue == newValue.Trim())
                    {
                        string noChangeMsg = CurrentLanguage == "BM" ? "Tiada perubahan dikesan." : "No changes detected.";
                        Response.Write("{\"success\":true,\"message\":\"" + EscapeJson(noChangeMsg) + "\",\"updatedAt\":\"\"}");
                        Response.End();
                        return;
                    }

                    // Update config
                    DateTime now = DateTime.Now;
                    using (var cmd = new SqlCommand("UPDATE dbo.[ConfigurationSetting] SET [configValue]=@val, [lastUpdated]=@dt WHERE [configId]=@id", conn))
                    {
                        cmd.Parameters.AddWithValue("@val", newValue.Trim());
                        cmd.Parameters.AddWithValue("@dt", now);
                        cmd.Parameters.AddWithValue("@id", configId);
                        cmd.ExecuteNonQuery();
                    }

                    // Insert log
                    string description = string.Format("Updated {0} from {1} to {2}.", configKey, oldValue, newValue.Trim());
                    InsertLog(conn, userId, "Configuration Updated", description, "Success");

                    string updatedAt = now.ToString("dd MMM yyyy hh:mm tt");
                    string msg = CurrentLanguage == "BM"
                        ? string.Format("Dikemas kini {0} dari {1} ke {2}.", configKey, oldValue, newValue.Trim())
                        : description;

                    Response.Write("{\"success\":true,\"message\":\"" + EscapeJson(msg) + "\",\"updatedAt\":\"" + EscapeJson(updatedAt) + "\"}");
                }
            }
            catch (Exception ex)
            {
                Response.Write("{\"success\":false,\"message\":\"" + EscapeJson(ex.Message) + "\"}");
            }
            Response.End();
        }

        private void SetUserInfo()
        {
            string userId = Session["userId"].ToString();
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [username] FROM dbo.[User] WHERE [userId]=@uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    var val = cmd.ExecuteScalar();
                    string name = val != null && val != DBNull.Value ? val.ToString() : "Admin";
                    string initials = name.Length >= 2 ? name.Substring(0, 2).ToUpper() : name.ToUpper();
                    var master = (ScienceBuddy.SiteMaster)Master;
                    master.SetUserInfo(name, "Administrator", initials);
                }
            }
        }

        private void LoadConfigData()
        {
            _configCache = new Dictionary<string, ConfigItem>();
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [configId],[configKey],[configValue],[lastUpdated] FROM dbo.[ConfigurationSetting] ORDER BY [configId]", conn))
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string id = reader["configId"].ToString();
                        string val = reader["configValue"] != DBNull.Value ? reader["configValue"].ToString() : "";
                        string key = reader["configKey"] != DBNull.Value ? reader["configKey"].ToString() : "";
                        DateTime? lastUpd = reader["lastUpdated"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(reader["lastUpdated"]) : null;
                        string updStr = lastUpd.HasValue ? lastUpd.Value.ToString("dd MMM yyyy hh:mm tt") : "-";

                        _configCache[id] = new ConfigItem { Value = val, Key = key, Updated = updStr };
                    }
                }
            }

            litLastSync.Text = DateTime.Now.ToString("dd MMM yyyy hh:mm tt");
        }

        private void LoadSummary()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[ConfigurationSetting]", conn))
                    litTotalSettings.Text = cmd.ExecuteScalar().ToString();

                using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[ConfigurationSetting] WHERE CAST([lastUpdated] AS DATE) = CAST(GETDATE() AS DATE)", conn))
                    litUpdatedToday.Text = cmd.ExecuteScalar().ToString();

                using (var cmd = new SqlCommand("SELECT TOP 1 [configKey],[lastUpdated] FROM dbo.[ConfigurationSetting] ORDER BY [lastUpdated] DESC", conn))
                using (var reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        litRecentName.Text = HttpUtility.HtmlEncode(reader["configKey"]?.ToString() ?? "-");
                        if (reader["lastUpdated"] != DBNull.Value)
                            litRecentTime.Text = Convert.ToDateTime(reader["lastUpdated"]).ToString("dd MMM yyyy hh:mm tt");
                    }
                }
            }
        }

        // Called from ASPX via <%= GetVal("CONFIG001") %>
        protected string GetVal(string configId)
        {
            if (_configCache != null && _configCache.ContainsKey(configId))
                return HttpUtility.HtmlAttributeEncode(_configCache[configId].Value);
            return "";
        }

        // Called from ASPX via <%= GetUpdated("CONFIG001") %>
        protected string GetUpdated(string configId)
        {
            if (_configCache != null && _configCache.ContainsKey(configId))
                return HttpUtility.HtmlEncode(_configCache[configId].Updated);
            return "-";
        }

        private void InsertLog(SqlConnection conn, string userId, string action, string description, string status)
        {
            string logId = GenerateId(conn, "Log", "logId", "LOG");
            const string sql = @"INSERT INTO dbo.[Log] ([logId],[userId],[action],[description],[logDateTime],[status])
                                 VALUES (@logId,@userId,@action,@desc,@dt,@status)";
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@logId", logId);
                cmd.Parameters.AddWithValue("@userId", userId);
                cmd.Parameters.AddWithValue("@action", action);
                cmd.Parameters.AddWithValue("@desc", description);
                cmd.Parameters.AddWithValue("@dt", DateTime.Now);
                cmd.Parameters.AddWithValue("@status", status);
                cmd.ExecuteNonQuery();
            }
        }

        private string GenerateId(SqlConnection conn, string tableName, string idColumn, string prefix)
        {
            string sql = string.Format("SELECT TOP 1 [{0}] FROM dbo.[{1}] ORDER BY [{0}] DESC", idColumn, tableName);
            using (var cmd = new SqlCommand(sql, conn))
            {
                var val = cmd.ExecuteScalar();
                if (val == null || val == DBNull.Value)
                    return prefix + "001";
                string lastId = val.ToString();
                string numPart = lastId.Substring(prefix.Length);
                int num = 0;
                int.TryParse(numPart, out num);
                num++;
                return prefix + num.ToString().PadLeft(lastId.Length - prefix.Length, '0');
            }
        }

        private static string EscapeJson(string s)
        {
            if (string.IsNullOrEmpty(s)) return "";
            return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "");
        }
    }
}
