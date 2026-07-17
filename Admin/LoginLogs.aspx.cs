using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

// Admin LoginLogs - Code Behind

namespace ScienceBuddy.Admin
{
    public partial class LoginLogs : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected string CurrentLanguage => ((ScienceBuddy.SiteMaster)Master).CurrentLanguage;

        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        // --- Page Lifecycle ---

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null)
            { Response.Redirect("~/Login.aspx", false); return; }
            if (Session["role"] == null || Session["role"].ToString() != "Admin")
            { Response.Redirect("~/Login.aspx", false); return; }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                SetMasterUser();
                LoadStats();
                LoadLogs("", "", "");
            }

            txtSearch.Attributes["placeholder"] = T("Search user...", "Cari pengguna...");
            btnSearch.Text = T("Search", "Cari");
            btnReset.Text = T("Reset", "Tetapkan Semula");
            btnCloseModal.Text = T("Close", "Tutup");
        }

        // --- Data Loading ---

        private void SetMasterUser()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [username] FROM dbo.[User] WHERE [userId]=@uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", Session["userId"].ToString());
                    var result = cmd.ExecuteScalar();
                    string name = result != null && result != DBNull.Value ? result.ToString() : "Admin";
                    string initials = name.Length >= 2 ? name.Substring(0, 2).ToUpper() : name.ToUpper();
                    ((ScienceBuddy.SiteMaster)Master).SetUserInfo(name, "Administrator", initials);
                }
            }
        }

        private void LoadStats()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                litSuccess.Text = SafeScalar(conn, "SELECT COUNT(*) FROM dbo.[Log] WHERE [action] LIKE '%Login%' AND [action] NOT LIKE '%Failed%' AND [action] NOT LIKE '%Suspicious%' AND [action] NOT LIKE '%Locked%' AND [status]='Success'");
                litFailed.Text = SafeScalar(conn, "SELECT COUNT(*) FROM dbo.[Log] WHERE [action] LIKE '%Failed%Login%'");
                litLocked.Text = SafeScalar(conn, "SELECT COUNT(*) FROM dbo.[Log] WHERE [action] LIKE '%Locked%'");
                litSuspicious.Text = SafeScalar(conn, "SELECT COUNT(*) FROM dbo.[Log] WHERE [action] LIKE '%Suspicious%'");
            }
        }

        private void LoadLogs(string search, string actionFilter, string statusFilter)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                string sql = @"SELECT l.[logId],l.[action],l.[description],l.[logDateTime],l.[status],
                    ISNULL(u.[username],'Unknown') AS username, u.[role]
                    FROM dbo.[Log] l LEFT JOIN dbo.[User] u ON u.[userId]=l.[userId]
                    WHERE (l.[action] LIKE '%Login%' OR l.[action] LIKE '%Logout%' OR l.[action] LIKE '%Locked%' OR l.[action] LIKE '%Suspicious%')";

                if (!string.IsNullOrWhiteSpace(search))
                    sql += " AND (u.[username] LIKE @s OR l.[userId] LIKE @s)";
                if (!string.IsNullOrWhiteSpace(actionFilter))
                    sql += " AND l.[action] LIKE @act";
                if (!string.IsNullOrWhiteSpace(statusFilter))
                    sql += " AND l.[status]=@st";
                sql += " ORDER BY l.[logDateTime] DESC";

                using (var cmd = new SqlCommand(sql, conn))
                {
                    if (!string.IsNullOrWhiteSpace(search))
                        cmd.Parameters.AddWithValue("@s", "%" + search + "%");
                    if (!string.IsNullOrWhiteSpace(actionFilter))
                        cmd.Parameters.AddWithValue("@act", "%" + actionFilter + "%");
                    if (!string.IsNullOrWhiteSpace(statusFilter))
                        cmd.Parameters.AddWithValue("@st", statusFilter);

                    var da = new SqlDataAdapter(cmd);
                    var dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count == 0)
                    {
                        pnlLogs.Visible = false;
                        pnlEmpty.Visible = true;
                        return;
                    }

                    var list = new List<object>();
                    foreach (DataRow row in dt.Rows)
                    {
                        string action = NullSafe(row["action"]);
                        string status = NullSafe(row["status"]);
                        DateTime logDt = row["logDateTime"] == DBNull.Value ? DateTime.Now : Convert.ToDateTime(row["logDateTime"]);

                        list.Add(new
                        {
                            logId = row["logId"].ToString(),
                            action = action,
                            description = NullSafe(row["description"]),
                            username = NullSafe(row["username"]),
                            dateStr = logDt.ToString("d MMM yyyy, HH:mm"),
                            statusLabel = status == "Success" ? T("Success", "Berjaya") : status == "Failed" ? T("Failed", "Gagal") : status == "Warning" ? T("Warning", "Amaran") : status,
                            statusCls = status == "Success" ? "sb-badge-success" : status == "Failed" ? "sb-badge-error" : status == "Warning" ? "sb-badge-warning" : "sb-badge-gray",
                            icoClass = GetIcon(action),
                            icoStyle = GetIconStyle(action, status)
                        });
                    }

                    pnlLogs.Visible = true;
                    pnlEmpty.Visible = false;
                    rptLogs.DataSource = list;
                    rptLogs.DataBind();
                }
            }
        }

        // --- Event Handlers ---

        protected void rptLogs_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "ViewLog") return;

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(@"SELECT l.*,ISNULL(u.[username],'Unknown') AS username,u.[role]
                    FROM dbo.[Log] l LEFT JOIN dbo.[User] u ON u.[userId]=l.[userId] WHERE l.[logId]=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", e.CommandArgument.ToString());
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read()) return;

                        litMLogId.Text = HttpUtility.HtmlEncode(NullSafe(reader["logId"]));
                        litMUser.Text = HttpUtility.HtmlEncode(NullSafe(reader["username"]) + " (" + NullSafe(reader["role"]) + ")");
                        litMAction.Text = HttpUtility.HtmlEncode(NullSafe(reader["action"]));
                        litMDesc.Text = HttpUtility.HtmlEncode(NullSafe(reader["description"]));

                        string status = NullSafe(reader["status"]);
                        litMStatus.Text = string.Format("<span class=\"sb-badge {0}\">{1}</span>",
                            status == "Success" ? "sb-badge-success" : status == "Failed" ? "sb-badge-error" : "sb-badge-warning",
                            HttpUtility.HtmlEncode(status));

                        DateTime logDt = reader["logDateTime"] == DBNull.Value ? DateTime.Now : Convert.ToDateTime(reader["logDateTime"]);
                        litMDate.Text = logDt.ToString("d MMM yyyy, HH:mm:ss");
                    }
                }
            }
            pnlModal.Visible = true;
        }

        protected void btnCloseModal_Click(object sender, EventArgs e)
        {
            pnlModal.Visible = false;
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadLogs(txtSearch.Text.Trim(), ddlAction.SelectedValue, ddlStatus.SelectedValue);
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlAction.SelectedIndex = 0;
            ddlStatus.SelectedIndex = 0;
            LoadLogs("", "", "");
        }

        // --- Helpers ---

        private static string GetIcon(string action)
        {
            string lower = (action ?? "").ToLower();
            if (lower.Contains("suspicious")) return "bi bi-exclamation-triangle-fill";
            if (lower.Contains("locked")) return "bi bi-lock-fill";
            if (lower.Contains("failed")) return "bi bi-x-circle-fill";
            if (lower.Contains("logout")) return "bi bi-door-closed-fill";
            return "bi bi-box-arrow-in-right";
        }

        private static string GetIconStyle(string action, string status)
        {
            string lower = (action ?? "").ToLower();
            if (lower.Contains("suspicious")) return "background:#FEF3C7;color:#D97706;";
            if (lower.Contains("locked")) return "background:#F3E8FF;color:#7C3AED;";
            if (lower.Contains("failed")) return "background:#FEE2E2;color:#DC2626;";
            if (lower.Contains("logout")) return "background:#F1F5F9;color:#64748B;";
            return "background:#ECFDF5;color:#059669;";
        }

        private string SafeScalar(SqlConnection conn, string sql)
        {
            try
            {
                using (var cmd = new SqlCommand(sql, conn))
                {
                    var result = cmd.ExecuteScalar();
                    return result != null && result != DBNull.Value ? Convert.ToInt32(result).ToString() : "0";
                }
            }
            catch { return "0"; }
        }

        private static string NullSafe(object val)
        {
            return (val == null || val == DBNull.Value) ? "" : val.ToString();
        }
    }
}
