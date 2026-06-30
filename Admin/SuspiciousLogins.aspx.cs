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
            if (!IsPostBack) { SetMasterUser(); LoadAll(); }
            txtSearch.Attributes["placeholder"] = T("Search username...", "Cari nama pengguna...");
            btnSearch.Text = T("Search", "Cari"); btnReset.Text = T("Reset", "Tetapkan Semula");
        }

        private void LoadAll() { LoadStats(); LoadLogs(txtSearch.Text.Trim(), ddlStatus.SelectedValue); LoadSecurityActions(); }

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
                litSuspicious.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[Log] WHERE [action] LIKE '%Suspicious%'");
                litBlocked.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[UserStatusAction] WHERE [actionType]='Blocked'");
                litFailed.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[Log] WHERE [action] LIKE '%Failed%'");
                litResolved.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[UserStatusAction] WHERE [actionType]='Unblocked'");
            }
        }

        private void LoadLogs(string search, string statusF)
        {
            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                string sql = @"SELECT l.[logId],l.[userId],l.[action],l.[description],l.[logDateTime],l.[status],
                    ISNULL(u.[username],'Unknown') AS username, u.[status] AS userStatus
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
                        string st = NS(r["status"]); string uStatus = NS(r["userStatus"]);
                        DateTime logDt = r["logDateTime"] == DBNull.Value ? DateTime.Now : Convert.ToDateTime(r["logDateTime"]);
                        list.Add(new { logId = r["logId"].ToString(), userId = NS(r["userId"]),
                            username = NS(r["username"]), action = NS(r["action"]),
                            description = NS(r["description"]), dateStr = logDt.ToString("d MMM yyyy, HH:mm"),
                            statusLabel = st == "Failed" ? T("Failed","Gagal") : st == "Warning" ? T("Warning","Amaran") : st == "Success" ? T("Success","Berjaya") : st,
                            statusCls = st == "Failed" ? "sb-badge-error" : st == "Warning" ? "sb-badge-warning" : st == "Success" ? "sb-badge-success" : "sb-badge-gray",
                            isBlocked = uStatus == "Blocked",
                            canBlock = uStatus == "Active" && (NS(r["action"]).Contains("Failed") || NS(r["action"]).Contains("Suspicious")) });
                    }
                    pnlLogs.Visible = true; pnlEmpty.Visible = false; rptLogs.DataSource = list; rptLogs.DataBind();
                }
            }
        }

        // ── Security Actions from UserStatusAction ───────────────────
        private void LoadSecurityActions()
        {
            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                using (var cmd = new SqlCommand(@"SELECT usa.[actionId],usa.[userId],usa.[actionType],usa.[reason],usa.[actionDate],
                    ISNULL(u.[username],'Unknown') AS targetUser, ISNULL(adm.[username],'Admin') AS adminUser
                    FROM dbo.[UserStatusAction] usa
                    LEFT JOIN dbo.[User] u ON u.[userId]=usa.[userId]
                    LEFT JOIN dbo.[User] adm ON adm.[userId]=usa.[performedBy]
                    ORDER BY usa.[actionDate] DESC", conn))
                {
                    var da = new SqlDataAdapter(cmd); var dt = new DataTable(); da.Fill(dt);
                    if (dt.Rows.Count == 0) { pnlActions.Visible = false; pnlNoActions.Visible = true; return; }
                    var list = new List<object>();
                    foreach (DataRow r in dt.Rows) {
                        string aType = NS(r["actionType"]);
                        DateTime dt2 = r["actionDate"] == DBNull.Value ? DateTime.Now : Convert.ToDateTime(r["actionDate"]);
                        list.Add(new { actionId = r["actionId"].ToString(), userId = NS(r["userId"]),
                            targetUser = NS(r["targetUser"]),
                            adminUser = NS(r["adminUser"]), actionType = aType,
                            reason = NS(r["reason"]), dateStr = dt2.ToString("d MMM yyyy"),
                            typeCls = aType == "Blocked" ? "sb-badge-error" : aType == "Unblocked" ? "sb-badge-success" : "sb-badge-warning",
                            typeLabel = aType == "Blocked" ? T("Blocked","Disekat") : aType == "Unblocked" ? T("Unblocked","Dinyahsekat") : T("Deleted","Dipadam") });
                    }
                    pnlActions.Visible = true; pnlNoActions.Visible = false; rptActions.DataSource = list; rptActions.DataBind();
                }
            }
        }

        // ── Block User ───────────────────────────────────────────────
        protected void rptLogs_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "BlockUser") return;
            string userId = e.CommandArgument.ToString();
            if (string.IsNullOrEmpty(userId)) return;
            string adminId = Session["userId"].ToString();

            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                // Update User status
                using (var cmd = new SqlCommand("UPDATE dbo.[User] SET [status]='Blocked' WHERE [userId]=@uid AND [status]='Active'", conn))
                { cmd.Parameters.AddWithValue("@uid", userId); cmd.ExecuteNonQuery(); }

                // Insert UserStatusAction
                string actionId = GenId(conn, "UserStatusAction", "USA");
                using (var cmd = new SqlCommand(@"INSERT INTO dbo.[UserStatusAction]([actionId],[userId],[actionType],[reason],[actionDate],[performedBy])
                    VALUES(@id,@uid,'Blocked',@reason,@dt,@admin)", conn))
                { cmd.Parameters.AddWithValue("@id", actionId); cmd.Parameters.AddWithValue("@uid", userId);
                  cmd.Parameters.AddWithValue("@reason", "Suspicious login attempts exceeded limit.");
                  cmd.Parameters.AddWithValue("@dt", DateTime.Today); cmd.Parameters.AddWithValue("@admin", adminId);
                  cmd.ExecuteNonQuery(); }

                // Insert Log
                string logId = GenId(conn, "Log", "LOG");
                using (var cmd = new SqlCommand(@"INSERT INTO dbo.[Log]([logId],[userId],[action],[description],[logDateTime],[status])
                    VALUES(@id,@uid,'Account Locked','Administrator blocked user after suspicious login activity.',GETDATE(),'Success')", conn))
                { cmd.Parameters.AddWithValue("@id", logId); cmd.Parameters.AddWithValue("@uid", adminId);
                  cmd.ExecuteNonQuery(); }
            }
            LoadAll();
        }

        // ── Unblock User ─────────────────────────────────────────────
        protected void rptActions_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "UnblockUser") return;
            string userId = e.CommandArgument.ToString();
            if (string.IsNullOrEmpty(userId)) return;
            string adminId = Session["userId"].ToString();

            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                // Update User status
                using (var cmd = new SqlCommand("UPDATE dbo.[User] SET [status]='Active' WHERE [userId]=@uid AND [status]='Blocked'", conn))
                { cmd.Parameters.AddWithValue("@uid", userId); cmd.ExecuteNonQuery(); }

                // Insert UserStatusAction
                string actionId = GenId(conn, "UserStatusAction", "USA");
                using (var cmd = new SqlCommand(@"INSERT INTO dbo.[UserStatusAction]([actionId],[userId],[actionType],[reason],[actionDate],[performedBy])
                    VALUES(@id,@uid,'Unblocked',@reason,@dt,@admin)", conn))
                { cmd.Parameters.AddWithValue("@id", actionId); cmd.Parameters.AddWithValue("@uid", userId);
                  cmd.Parameters.AddWithValue("@reason", "Administrator manually restored account.");
                  cmd.Parameters.AddWithValue("@dt", DateTime.Today); cmd.Parameters.AddWithValue("@admin", adminId);
                  cmd.ExecuteNonQuery(); }

                // Insert Log
                string logId = GenId(conn, "Log", "LOG");
                using (var cmd = new SqlCommand(@"INSERT INTO dbo.[Log]([logId],[userId],[action],[description],[logDateTime],[status])
                    VALUES(@id,@uid,'Account Unblocked','Administrator unblocked user account.',GETDATE(),'Success')", conn))
                { cmd.Parameters.AddWithValue("@id", logId); cmd.Parameters.AddWithValue("@uid", adminId);
                  cmd.ExecuteNonQuery(); }
            }
            LoadAll();
        }

        protected void btnSearch_Click(object sender, EventArgs e) { LoadLogs(txtSearch.Text.Trim(), ddlStatus.SelectedValue); }
        protected void btnReset_Click(object sender, EventArgs e) { txtSearch.Text = ""; ddlStatus.SelectedIndex = 0; LoadAll(); }

        private string GenId(SqlConnection conn, string table, string prefix)
        {
            string col = table == "UserStatusAction" ? "actionId" : "logId";
            string sql = string.Format("SELECT MAX(CAST(SUBSTRING([{0}],{1},LEN([{0}])-{2}) AS INT)) FROM dbo.[{3}]", col, prefix.Length + 1, prefix.Length, table);
            try { using (var cmd = new SqlCommand(sql, conn)) { var v = cmd.ExecuteScalar(); int next = (v != null && v != DBNull.Value) ? Convert.ToInt32(v) + 1 : 1; return prefix + next.ToString("D3"); } }
            catch { return prefix + DateTime.Now.Ticks.ToString().Substring(10); }
        }

        private string SS(SqlConnection c, string sql) { try { using (var cmd = new SqlCommand(sql, c)) { var v = cmd.ExecuteScalar(); return v != null && v != DBNull.Value ? Convert.ToInt32(v).ToString() : "0"; } } catch { return "0"; } }
        private static string NS(object v) { return (v == null || v == DBNull.Value) ? "" : v.ToString(); }
    }
}
