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
    public partial class SuspiciousLogins : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        protected string CurrentLanguage => ((ScienceBuddy.SiteMaster)Master).CurrentLanguage;
        protected string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null) { Response.Redirect("~/Login.aspx", false); return; }
            if (Session["role"] == null || Session["role"].ToString() != "Admin") { Response.Redirect("~/Login.aspx", false); return; }
            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            if (!IsPostBack) { SetMasterUser(); LoadStats(); LoadLogs("", ""); }
            txtSearch.Attributes["placeholder"] = T("Search username...", "Cari nama pengguna...");
            btnSearch.Text = T("Search", "Cari"); btnReset.Text = T("Reset", "Tetapkan Semula");
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
                // Suspicious = logs with action containing 'suspicious' or 'fail'
                litSuspicious.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[Log] WHERE [action] LIKE '%Suspicious%'");
                litBlocked.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[User] WHERE [status]='Blocked'");
                litFailed.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[Log] WHERE [action] LIKE '%Failed%' OR [status]='Failed'");
                litResolved.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[Log] WHERE ([action] LIKE '%Suspicious%' OR [action] LIKE '%Failed%') AND [status]='Success'");
            }
        }

        private void LoadLogs(string search, string statusF)
        {
            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                string sql = @"SELECT l.[logId],l.[action],l.[description],l.[logDateTime],l.[status],
                    ISNULL(u.[username],'Unknown') AS username
                    FROM dbo.[Log] l LEFT JOIN dbo.[User] u ON u.[userId]=l.[userId]
                    WHERE (l.[action] LIKE '%Login%' OR l.[action] LIKE '%Suspicious%' OR l.[action] LIKE '%Security%' OR l.[action] LIKE '%Block%')";
                if (!string.IsNullOrWhiteSpace(search)) sql += " AND u.[username] LIKE @s";
                if (!string.IsNullOrWhiteSpace(statusF)) sql += " AND l.[status]=@st";
                sql += " ORDER BY l.[logDateTime] DESC";

                using (var cmd = new SqlCommand(sql, conn)) {
                    if (!string.IsNullOrWhiteSpace(search)) cmd.Parameters.AddWithValue("@s", "%" + search + "%");
                    if (!string.IsNullOrWhiteSpace(statusF)) cmd.Parameters.AddWithValue("@st", statusF);
                    var da = new SqlDataAdapter(cmd); var dt = new DataTable(); da.Fill(dt);
                    if (dt.Rows.Count == 0) { pnlLogs.Visible = false; pnlEmpty.Visible = true; return; }
                    var list = new List<object>();
                    foreach (DataRow r in dt.Rows) {
                        string st = NS(r["status"]);
                        DateTime logDt = r["logDateTime"] == DBNull.Value ? DateTime.Now : Convert.ToDateTime(r["logDateTime"]);
                        list.Add(new { username = NS(r["username"]), action = NS(r["action"]),
                            description = NS(r["description"]),
                            dateStr = logDt.ToString("d MMM yyyy, HH:mm"),
                            statusLabel = st == "Failed" ? T("Failed","Gagal") : st == "Warning" ? T("Warning","Amaran") : st == "Success" ? T("Resolved","Diselesaikan") : st,
                            statusCls = st == "Failed" ? "sb-badge-error" : st == "Warning" ? "sb-badge-warning" : st == "Success" ? "sb-badge-success" : "sb-badge-gray" });
                    }
                    pnlLogs.Visible = true; pnlEmpty.Visible = false; rptLogs.DataSource = list; rptLogs.DataBind();
                }
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e) { LoadLogs(txtSearch.Text.Trim(), ddlStatus.SelectedValue); }
        protected void btnReset_Click(object sender, EventArgs e) { txtSearch.Text = ""; ddlStatus.SelectedIndex = 0; LoadLogs("", ""); }

        private string SS(SqlConnection c, string sql) { try { using (var cmd = new SqlCommand(sql, c)) { var v = cmd.ExecuteScalar(); return v != null && v != DBNull.Value ? Convert.ToInt32(v).ToString() : "0"; } } catch { return "0"; } }
        private static string NS(object v) { return (v == null || v == DBNull.Value) ? "" : v.ToString(); }
    }
}
