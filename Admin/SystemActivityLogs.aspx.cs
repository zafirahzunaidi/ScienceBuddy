using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Admin
{
    public partial class SystemActivityLogs : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        protected string CurrentLanguage => ((ScienceBuddy.SiteMaster)Master).CurrentLanguage;
        protected string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null) { Response.Redirect("~/Login.aspx", false); return; }
            if (Session["role"] == null || Session["role"].ToString() != "Admin") { Response.Redirect("~/Login.aspx", false); return; }
            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            if (!IsPostBack) { SetMasterUser(); LoadStats(); LoadTimeline("", "", ""); }
            txtSearch.Attributes["placeholder"] = T("Search action or description…", "Cari tindakan atau penerangan…");
            btnSearch.Text = T("Search", "Cari"); btnReset.Text = T("Reset", "Tetapkan Semula");
            btnCloseModal.Text = T("Close", "Tutup");
        }

        private void SetMasterUser()
        {
            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                using (var cmd = new SqlCommand("SELECT [username] FROM dbo.[User] WHERE [userId]=@uid", conn))
                { cmd.Parameters.AddWithValue("@uid", Session["userId"].ToString());
                  var v = cmd.ExecuteScalar(); string n = v != null && v != DBNull.Value ? v.ToString() : "Admin";
                  ((ScienceBuddy.SiteMaster)Master).SetUserInfo(n, "Administrator", n.Length >= 2 ? n.Substring(0, 2).ToUpper() : n.ToUpper()); } }
        }

        private void LoadStats()
        {
            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                litTotal.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[Log]");
                string todaySql = "SELECT COUNT(*) FROM dbo.[Log] WHERE CAST([logDateTime] AS DATE)=CAST(GETDATE() AS DATE)";
                litToday.Text = SS(conn, todaySql);
                litSuccess.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[Log] WHERE [status]='Success'");
                int warn = SafeInt(conn, "SELECT COUNT(*) FROM dbo.[Log] WHERE [status] IN ('Warning','Failed')");
                litWarn.Text = warn.ToString();
                // Trends
                litTotalTrend.Text = T("All time", "Sepanjang masa");
                litTodayTrend.Text = litToday.Text + " " + T("activities today", "aktiviti hari ini");
                litSuccessTrend.Text = litSuccess.Text + " " + T("successful", "berjaya");
                litWarnTrend.Text = warn > 0 ? (warn + " " + T("need attention", "perlu perhatian")) : T("All clear", "Semua baik");
            }
        }

        private void LoadTimeline(string search, string statusF, string actionF)
        {
            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                string sql = @"SELECT [logId],[userId],[action],[description],[logDateTime],[status]
                    FROM dbo.[Log] WHERE 1=1";
                if (!string.IsNullOrWhiteSpace(search)) sql += " AND ([action] LIKE @s OR [description] LIKE @s)";
                if (!string.IsNullOrWhiteSpace(statusF)) sql += " AND [status]=@st";
                if (!string.IsNullOrWhiteSpace(actionF)) sql += " AND [action] LIKE @act";
                sql += " ORDER BY [logDateTime] DESC";

                using (var cmd = new SqlCommand(sql, conn)) {
                    if (!string.IsNullOrWhiteSpace(search)) cmd.Parameters.AddWithValue("@s", "%" + search + "%");
                    if (!string.IsNullOrWhiteSpace(statusF)) cmd.Parameters.AddWithValue("@st", statusF);
                    if (!string.IsNullOrWhiteSpace(actionF)) cmd.Parameters.AddWithValue("@act", "%" + actionF + "%");
                    var da = new SqlDataAdapter(cmd); var dt = new DataTable(); da.Fill(dt);
                    if (dt.Rows.Count == 0) { pnlTimeline.Visible = false; pnlEmpty.Visible = true; return; }

                    var list = new List<object>(); string lastDate = "";
                    foreach (DataRow r in dt.Rows) {
                        DateTime logDt = r["logDateTime"] == DBNull.Value ? DateTime.Now : Convert.ToDateTime(r["logDateTime"]);
                        string dateKey = logDt.ToString("yyyy-MM-dd");
                        string dateLabel = GetDateLabel(logDt);
                        bool showHeader = dateKey != lastDate; lastDate = dateKey;
                        string action = NS(r["action"]); string status = NS(r["status"]);

                        list.Add(new {
                            logId = r["logId"].ToString(),
                            action = action,
                            description = NS(r["description"]),
                            timeStr = logDt.ToString("HH:mm"),
                            dateLabel = dateLabel,
                            showDateHeader = showHeader,
                            statusLabel = TranslateStatus(status),
                            statusCls = status == "Success" ? "sb-badge-success" : status == "Warning" ? "sb-badge-warning" : status == "Failed" ? "sb-badge-error" : "sb-badge-gray",
                            icoClass = GetIcon(action),
                            icoStyle = GetIconStyle(action, status)
                        });
                    }
                    pnlTimeline.Visible = true; pnlEmpty.Visible = false;
                    rptLogs.DataSource = list; rptLogs.DataBind();
                }
            }
        }

        protected void rptLogs_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "ViewLog") return;
            string logId = e.CommandArgument.ToString();
            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                using (var cmd = new SqlCommand("SELECT [logId],[userId],[action],[description],[logDateTime],[status] FROM dbo.[Log] WHERE [logId]=@id", conn))
                { cmd.Parameters.AddWithValue("@id", logId);
                    using (var rd = cmd.ExecuteReader()) { if (!rd.Read()) return;
                        litMLogId.Text = HttpUtility.HtmlEncode(NS(rd["logId"]));
                        litMUserId.Text = HttpUtility.HtmlEncode(NS(rd["userId"]));
                        litMAction.Text = HttpUtility.HtmlEncode(NS(rd["action"]));
                        litMDesc.Text = HttpUtility.HtmlEncode(NS(rd["description"]));
                        string st = NS(rd["status"]);
                        litMStatus.Text = string.Format("<span class=\"sb-badge {0}\">{1}</span>",
                            st=="Success"?"sb-badge-success":st=="Warning"?"sb-badge-warning":st=="Failed"?"sb-badge-error":"sb-badge-gray",
                            HttpUtility.HtmlEncode(TranslateStatus(st)));
                        DateTime dt2 = rd["logDateTime"]==DBNull.Value?DateTime.Now:Convert.ToDateTime(rd["logDateTime"]);
                        litMDateTime.Text = dt2.ToString("d MMM yyyy, HH:mm:ss");
                    }
                }
            }
            pnlModal.Visible = true;
        }

        protected void btnCloseModal_Click(object sender, EventArgs e) { pnlModal.Visible = false; }
        protected void btnSearch_Click(object sender, EventArgs e) { LoadTimeline(txtSearch.Text.Trim(), ddlStatus.SelectedValue, ddlAction.SelectedValue); }
        protected void btnReset_Click(object sender, EventArgs e) { txtSearch.Text = ""; ddlStatus.SelectedIndex = 0; ddlAction.SelectedIndex = 0; LoadTimeline("", "", ""); }

        // ── Helpers ──────────────────────────────────────────────────
        private string GetDateLabel(DateTime dt)
        {
            if (dt.Date == DateTime.Today) return T("Today", "Hari Ini");
            if (dt.Date == DateTime.Today.AddDays(-1)) return T("Yesterday", "Semalam");
            if (dt.Date >= DateTime.Today.AddDays(-7)) return T("Earlier This Week", "Awal Minggu Ini");
            return dt.ToString("d MMM yyyy");
        }

        private string TranslateStatus(string s)
        {
            switch (s) { case "Success": return T("Success", "Berjaya"); case "Warning": return T("Warning", "Amaran"); case "Failed": return T("Failed", "Gagal"); default: return s; }
        }

        private static string GetIcon(string action)
        {
            if (string.IsNullOrEmpty(action)) return "bi bi-circle";
            string a = action.ToLower();
            if (a.Contains("login") && !a.Contains("logout")) return "bi bi-door-open-fill";
            if (a.Contains("logout")) return "bi bi-door-closed-fill";
            if (a.Contains("notif")) return "bi bi-bell-fill";
            if (a.Contains("lesson")) return "bi bi-book-fill";
            if (a.Contains("quiz")) return "bi bi-patch-question-fill";
            if (a.Contains("forum")) return "bi bi-chat-left-text-fill";
            if (a.Contains("teacher")) return "bi bi-person-badge-fill";
            if (a.Contains("config")) return "bi bi-gear-fill";
            if (a.Contains("security")) return "bi bi-shield-lock-fill";
            if (a.Contains("content")) return "bi bi-clipboard-check-fill";
            return "bi bi-activity";
        }

        private static string GetIconStyle(string action, string status)
        {
            string a = (action ?? "").ToLower(); string s = (status ?? "").ToLower();
            if (s == "failed" || a.Contains("fail") || a.Contains("suspicious")) return "background:#FEE2E2;color:#DC2626;";
            if (s == "warning") return "background:#FEF3C7;color:#D97706;";
            if (a.Contains("login")) return "background:#DBEAFE;color:#2563EB;";
            if (a.Contains("notif")) return "background:#FEF3C7;color:#B45309;";
            if (a.Contains("content") || a.Contains("approv")) return "background:#ECFDF5;color:#059669;";
            if (a.Contains("config") || a.Contains("security")) return "background:#F5F3FF;color:#7C3AED;";
            return "background:#F1F5F9;color:#64748B;";
        }

        private string SS(SqlConnection c, string sql) { try { using (var cmd = new SqlCommand(sql, c)) { var v = cmd.ExecuteScalar(); return v != null && v != DBNull.Value ? Convert.ToInt32(v).ToString() : "0"; } } catch { return "0"; } }
        private int SafeInt(SqlConnection c, string sql) { try { using (var cmd = new SqlCommand(sql, c)) { var v = cmd.ExecuteScalar(); return v != null && v != DBNull.Value ? Convert.ToInt32(v) : 0; } } catch { return 0; } }
        private static string NS(object v) { return (v == null || v == DBNull.Value) ? "" : v.ToString(); }
    }
}
