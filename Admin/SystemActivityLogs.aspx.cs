using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

// Admin SystemActivityLogs - Code Behind

namespace ScienceBuddy.Admin
{
    public partial class SystemActivityLogs : Page
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
                LoadTimeline("", "", "");
            }

            txtSearch.Attributes["placeholder"] = T("Search action or description…", "Cari tindakan atau penerangan…");
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
                litTotal.Text = SafeScalar(conn, "SELECT COUNT(*) FROM dbo.[Log]");
                litToday.Text = SafeScalar(conn, "SELECT COUNT(*) FROM dbo.[Log] WHERE CAST([logDateTime] AS DATE)=CAST(GETDATE() AS DATE)");
                litSuccess.Text = SafeScalar(conn, "SELECT COUNT(*) FROM dbo.[Log] WHERE [status]='Success'");

                int warnCount = SafeInt(conn, "SELECT COUNT(*) FROM dbo.[Log] WHERE [status] IN ('Warning','Failed')");
                litWarn.Text = warnCount.ToString();

                // Trends
                litTotalTrend.Text = T("All time", "Sepanjang masa");
                litTodayTrend.Text = litToday.Text + " " + T("activities today", "aktiviti hari ini");
                litSuccessTrend.Text = litSuccess.Text + " " + T("successful", "berjaya");
                litWarnTrend.Text = warnCount > 0 ? (warnCount + " " + T("need attention", "perlu perhatian")) : T("All clear", "Semua baik");
            }
        }

        private void LoadTimeline(string search, string statusFilter, string actionFilter)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                string sql = @"SELECT [logId],[userId],[action],[description],[logDateTime],[status]
                    FROM dbo.[Log] WHERE 1=1";

                if (!string.IsNullOrWhiteSpace(search))
                    sql += " AND ([action] LIKE @s OR [description] LIKE @s)";
                if (!string.IsNullOrWhiteSpace(statusFilter))
                    sql += " AND [status]=@st";
                if (!string.IsNullOrWhiteSpace(actionFilter))
                    sql += " AND [action] LIKE @act";
                sql += " ORDER BY [logDateTime] DESC";

                using (var cmd = new SqlCommand(sql, conn))
                {
                    if (!string.IsNullOrWhiteSpace(search))
                        cmd.Parameters.AddWithValue("@s", "%" + search + "%");
                    if (!string.IsNullOrWhiteSpace(statusFilter))
                        cmd.Parameters.AddWithValue("@st", statusFilter);
                    if (!string.IsNullOrWhiteSpace(actionFilter))
                        cmd.Parameters.AddWithValue("@act", "%" + actionFilter + "%");

                    var da = new SqlDataAdapter(cmd);
                    var dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count == 0)
                    {
                        pnlTimeline.Visible = false;
                        pnlEmpty.Visible = true;
                        return;
                    }

                    var list = new List<object>();
                    string lastDate = "";

                    foreach (DataRow row in dt.Rows)
                    {
                        DateTime logDt = row["logDateTime"] == DBNull.Value ? DateTime.Now : Convert.ToDateTime(row["logDateTime"]);
                        string dateKey = logDt.ToString("yyyy-MM-dd");
                        string dateLabel = GetDateLabel(logDt);
                        bool showHeader = dateKey != lastDate;
                        lastDate = dateKey;

                        string action = NullSafe(row["action"]);
                        string status = NullSafe(row["status"]);

                        list.Add(new
                        {
                            logId = row["logId"].ToString(),
                            action = action,
                            description = NullSafe(row["description"]),
                            timeStr = logDt.ToString("HH:mm"),
                            dateLabel = dateLabel,
                            showDateHeader = showHeader,
                            statusLabel = TranslateStatus(status),
                            statusCls = status == "Success" ? "sb-badge-success" : status == "Warning" ? "sb-badge-warning" : status == "Failed" ? "sb-badge-error" : "sb-badge-gray",
                            icoClass = GetIcon(action),
                            icoStyle = GetIconStyle(action, status)
                        });
                    }

                    pnlTimeline.Visible = true;
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

            string logId = e.CommandArgument.ToString();
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [logId],[userId],[action],[description],[logDateTime],[status] FROM dbo.[Log] WHERE [logId]=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", logId);
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read()) return;

                        litMLogId.Text = HttpUtility.HtmlEncode(NullSafe(reader["logId"]));
                        litMUserId.Text = HttpUtility.HtmlEncode(NullSafe(reader["userId"]));
                        litMAction.Text = HttpUtility.HtmlEncode(NullSafe(reader["action"]));
                        litMDesc.Text = HttpUtility.HtmlEncode(NullSafe(reader["description"]));

                        string status = NullSafe(reader["status"]);
                        litMStatus.Text = string.Format("<span class=\"sb-badge {0}\">{1}</span>",
                            status == "Success" ? "sb-badge-success" : status == "Warning" ? "sb-badge-warning" : status == "Failed" ? "sb-badge-error" : "sb-badge-gray",
                            HttpUtility.HtmlEncode(TranslateStatus(status)));

                        DateTime logDt = reader["logDateTime"] == DBNull.Value ? DateTime.Now : Convert.ToDateTime(reader["logDateTime"]);
                        litMDateTime.Text = logDt.ToString("d MMM yyyy, HH:mm:ss");
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
            LoadTimeline(txtSearch.Text.Trim(), ddlStatus.SelectedValue, ddlAction.SelectedValue);
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlStatus.SelectedIndex = 0;
            ddlAction.SelectedIndex = 0;
            LoadTimeline("", "", "");
        }

        // --- Helpers ---

        private string GetDateLabel(DateTime dt)
        {
            if (dt.Date == DateTime.Today) return T("Today", "Hari Ini");
            if (dt.Date == DateTime.Today.AddDays(-1)) return T("Yesterday", "Semalam");
            if (dt.Date >= DateTime.Today.AddDays(-7)) return T("Earlier This Week", "Awal Minggu Ini");
            return dt.ToString("d MMM yyyy");
        }

        private string TranslateStatus(string status)
        {
            switch (status)
            {
                case "Success": return T("Success", "Berjaya");
                case "Warning": return T("Warning", "Amaran");
                case "Failed": return T("Failed", "Gagal");
                default: return status;
            }
        }

        private static string GetIcon(string action)
        {
            if (string.IsNullOrEmpty(action)) return "bi bi-circle";
            string lower = action.ToLower();
            if (lower.Contains("login") && !lower.Contains("logout")) return "bi bi-door-open-fill";
            if (lower.Contains("logout")) return "bi bi-door-closed-fill";
            if (lower.Contains("notif")) return "bi bi-bell-fill";
            if (lower.Contains("lesson")) return "bi bi-book-fill";
            if (lower.Contains("quiz")) return "bi bi-patch-question-fill";
            if (lower.Contains("forum")) return "bi bi-chat-left-text-fill";
            if (lower.Contains("teacher")) return "bi bi-person-badge-fill";
            if (lower.Contains("config")) return "bi bi-gear-fill";
            if (lower.Contains("security")) return "bi bi-shield-lock-fill";
            if (lower.Contains("content")) return "bi bi-clipboard-check-fill";
            return "bi bi-activity";
        }

        private static string GetIconStyle(string action, string status)
        {
            string lower = (action ?? "").ToLower();
            string st = (status ?? "").ToLower();
            if (st == "failed" || lower.Contains("fail") || lower.Contains("suspicious")) return "background:#FEE2E2;color:#DC2626;";
            if (st == "warning") return "background:#FEF3C7;color:#D97706;";
            if (lower.Contains("login")) return "background:#DBEAFE;color:#2563EB;";
            if (lower.Contains("notif")) return "background:#FEF3C7;color:#B45309;";
            if (lower.Contains("content") || lower.Contains("approv")) return "background:#ECFDF5;color:#059669;";
            if (lower.Contains("config") || lower.Contains("security")) return "background:#F5F3FF;color:#7C3AED;";
            return "background:#F1F5F9;color:#64748B;";
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

        private int SafeInt(SqlConnection conn, string sql)
        {
            try
            {
                using (var cmd = new SqlCommand(sql, conn))
                {
                    var result = cmd.ExecuteScalar();
                    return result != null && result != DBNull.Value ? Convert.ToInt32(result) : 0;
                }
            }
            catch { return 0; }
        }

        private static string NullSafe(object val)
        {
            return (val == null || val == DBNull.Value) ? "" : val.ToString();
        }
    }
}
