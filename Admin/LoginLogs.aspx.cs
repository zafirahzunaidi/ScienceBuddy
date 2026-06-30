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
    public partial class LoginLogs : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        protected string CurrentLanguage => ((ScienceBuddy.SiteMaster)Master).CurrentLanguage;
        protected string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null) { Response.Redirect("~/Login.aspx", false); return; }
            if (Session["role"] == null || Session["role"].ToString() != "Admin") { Response.Redirect("~/Login.aspx", false); return; }
            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            if (!IsPostBack) { SetMasterUser(); LoadStats(); LoadLogs("", "", ""); }
            txtSearch.Attributes["placeholder"] = T("Search user...", "Cari pengguna...");
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
                litSuccess.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[Log] WHERE [action] LIKE '%Login%' AND [action] NOT LIKE '%Failed%' AND [action] NOT LIKE '%Suspicious%' AND [action] NOT LIKE '%Locked%' AND [status]='Success'");
                litFailed.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[Log] WHERE [action] LIKE '%Failed%Login%'");
                litLocked.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[Log] WHERE [action] LIKE '%Locked%'");
                litSuspicious.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[Log] WHERE [action] LIKE '%Suspicious%'");
            }
        }

        private void LoadLogs(string search, string actionF, string statusF)
        {
            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                string sql = @"SELECT l.[logId],l.[action],l.[description],l.[logDateTime],l.[status],
                    ISNULL(u.[username],'Unknown') AS username, u.[role]
                    FROM dbo.[Log] l LEFT JOIN dbo.[User] u ON u.[userId]=l.[userId]
                    WHERE (l.[action] LIKE '%Login%' OR l.[action] LIKE '%Logout%' OR l.[action] LIKE '%Locked%' OR l.[action] LIKE '%Suspicious%')";
                if (!string.IsNullOrWhiteSpace(search)) sql += " AND (u.[username] LIKE @s OR l.[userId] LIKE @s)";
                if (!string.IsNullOrWhiteSpace(actionF)) sql += " AND l.[action] LIKE @act";
                if (!string.IsNullOrWhiteSpace(statusF)) sql += " AND l.[status]=@st";
                sql += " ORDER BY l.[logDateTime] DESC";

                using (var cmd = new SqlCommand(sql, conn)) {
                    if (!string.IsNullOrWhiteSpace(search)) cmd.Parameters.AddWithValue("@s", "%" + search + "%");
                    if (!string.IsNullOrWhiteSpace(actionF)) cmd.Parameters.AddWithValue("@act", "%" + actionF + "%");
                    if (!string.IsNullOrWhiteSpace(statusF)) cmd.Parameters.AddWithValue("@st", statusF);
                    var da = new SqlDataAdapter(cmd); var dt = new DataTable(); da.Fill(dt);
                    if (dt.Rows.Count == 0) { pnlLogs.Visible = false; pnlEmpty.Visible = true; return; }
                    var list = new List<object>();
                    foreach (DataRow r in dt.Rows) {
                        string action = NS(r["action"]); string st = NS(r["status"]);
                        DateTime logDt = r["logDateTime"] == DBNull.Value ? DateTime.Now : Convert.ToDateTime(r["logDateTime"]);
                        list.Add(new { logId = r["logId"].ToString(), action = action, description = NS(r["description"]),
                            username = NS(r["username"]), dateStr = logDt.ToString("d MMM yyyy, HH:mm"),
                            statusLabel = st == "Success" ? T("Success","Berjaya") : st == "Failed" ? T("Failed","Gagal") : st == "Warning" ? T("Warning","Amaran") : st,
                            statusCls = st == "Success" ? "sb-badge-success" : st == "Failed" ? "sb-badge-error" : st == "Warning" ? "sb-badge-warning" : "sb-badge-gray",
                            icoClass = GetIcon(action), icoStyle = GetIconStyle(action, st) });
                    }
                    pnlLogs.Visible = true; pnlEmpty.Visible = false; rptLogs.DataSource = list; rptLogs.DataBind();
                }
            }
        }

        protected void rptLogs_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "ViewLog") return;
            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                using (var cmd = new SqlCommand(@"SELECT l.*,ISNULL(u.[username],'Unknown') AS username,u.[role]
                    FROM dbo.[Log] l LEFT JOIN dbo.[User] u ON u.[userId]=l.[userId] WHERE l.[logId]=@id", conn))
                { cmd.Parameters.AddWithValue("@id", e.CommandArgument.ToString());
                    using (var rd = cmd.ExecuteReader()) { if (!rd.Read()) return;
                        litMLogId.Text = HttpUtility.HtmlEncode(NS(rd["logId"]));
                        litMUser.Text = HttpUtility.HtmlEncode(NS(rd["username"]) + " (" + NS(rd["role"]) + ")");
                        litMAction.Text = HttpUtility.HtmlEncode(NS(rd["action"]));
                        litMDesc.Text = HttpUtility.HtmlEncode(NS(rd["description"]));
                        string st = NS(rd["status"]);
                        litMStatus.Text = string.Format("<span class=\"sb-badge {0}\">{1}</span>",
                            st == "Success" ? "sb-badge-success" : st == "Failed" ? "sb-badge-error" : "sb-badge-warning",
                            HttpUtility.HtmlEncode(st));
                        DateTime dt2 = rd["logDateTime"] == DBNull.Value ? DateTime.Now : Convert.ToDateTime(rd["logDateTime"]);
                        litMDate.Text = dt2.ToString("d MMM yyyy, HH:mm:ss");
                    }
                }
            }
            pnlModal.Visible = true;
        }

        protected void btnCloseModal_Click(object sender, EventArgs e) { pnlModal.Visible = false; }
        protected void btnSearch_Click(object sender, EventArgs e) { LoadLogs(txtSearch.Text.Trim(), ddlAction.SelectedValue, ddlStatus.SelectedValue); }
        protected void btnReset_Click(object sender, EventArgs e) { txtSearch.Text = ""; ddlAction.SelectedIndex = 0; ddlStatus.SelectedIndex = 0; LoadLogs("", "", ""); }

        private static string GetIcon(string action) {
            string a = (action ?? "").ToLower();
            if (a.Contains("suspicious")) return "bi bi-exclamation-triangle-fill";
            if (a.Contains("locked")) return "bi bi-lock-fill";
            if (a.Contains("failed")) return "bi bi-x-circle-fill";
            if (a.Contains("logout")) return "bi bi-door-closed-fill";
            return "bi bi-box-arrow-in-right";
        }
        private static string GetIconStyle(string action, string status) {
            string a = (action ?? "").ToLower();
            if (a.Contains("suspicious")) return "background:#FEF3C7;color:#D97706;";
            if (a.Contains("locked")) return "background:#F3E8FF;color:#7C3AED;";
            if (a.Contains("failed")) return "background:#FEE2E2;color:#DC2626;";
            if (a.Contains("logout")) return "background:#F1F5F9;color:#64748B;";
            return "background:#ECFDF5;color:#059669;";
        }
        private string SS(SqlConnection c, string sql) { try { using (var cmd = new SqlCommand(sql, c)) { var v = cmd.ExecuteScalar(); return v != null && v != DBNull.Value ? Convert.ToInt32(v).ToString() : "0"; } } catch { return "0"; } }
        private static string NS(object v) { return (v == null || v == DBNull.Value) ? "" : v.ToString(); }
    }
}
