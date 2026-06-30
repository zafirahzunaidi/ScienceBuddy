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
    public partial class ForumDiscussions : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        protected string CurrentLanguage => ((ScienceBuddy.SiteMaster)Master).CurrentLanguage;
        protected string T(string en, string bm) => CurrentLanguage == "BM" ? bm : en;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.QueryString["handler"] == "ForumAction" && Request.HttpMethod == "POST") { HandleAction(); return; }
            if (Session["userId"] == null || Session["role"]?.ToString() != "Admin") { Response.Redirect("~/Login.aspx", false); return; }
            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            if (!IsPostBack) { SetUserInfo(); LoadStats(); LoadForums("", "", "newest"); txtSearch.Attributes["placeholder"] = T("Search forum title, message, username...", "Cari tajuk forum, mesej, nama pengguna..."); }
        }

        private void SetUserInfo() { using (var c = new SqlConnection(ConnStr)) { c.Open(); using (var cmd = new SqlCommand("SELECT [username] FROM dbo.[User] WHERE [userId]=@u", c)) { cmd.Parameters.AddWithValue("@u", Session["userId"].ToString()); var v = cmd.ExecuteScalar(); string n = v?.ToString() ?? "Admin"; ((ScienceBuddy.SiteMaster)Master).SetUserInfo(n, "Administrator", n.Length >= 2 ? n.Substring(0, 2).ToUpper() : n.ToUpper()); } } }

        private void LoadStats()
        {
            using (var c = new SqlConnection(ConnStr)) { c.Open();
                litTotal.Text = SC(c, "SELECT COUNT(*) FROM dbo.[Forum]").ToString();
                litPublic.Text = SC(c, "SELECT COUNT(*) FROM dbo.[Forum] WHERE [discussionType]='Public'").ToString();
                litPrivate.Text = SC(c, "SELECT COUNT(*) FROM dbo.[Forum] WHERE [discussionType]='Private'").ToString();
                litToday.Text = SC(c, "SELECT COUNT(*) FROM dbo.[Forum] WHERE CAST([createdAt] AS DATE)=CAST(GETDATE() AS DATE)").ToString();
            }
        }

        private void LoadForums(string search, string type, string sort)
        {
            var list = new List<object>();
            using (var c = new SqlConnection(ConnStr)) { c.Open();
                string sql = @"SELECT f.[forumId],f.[title],f.[message],f.[discussionType],f.[createdAt],f.[createdBy],
                    u.[username],u.[role] FROM dbo.[Forum] f LEFT JOIN dbo.[User] u ON u.[userId]=f.[createdBy] WHERE 1=1";
                if (!string.IsNullOrWhiteSpace(type)) sql += " AND f.[discussionType]=@t";
                if (!string.IsNullOrWhiteSpace(search)) sql += " AND (f.[title] LIKE @s OR f.[message] LIKE @s OR u.[username] LIKE @s OR f.[forumId] LIKE @s)";
                sql += sort == "oldest" ? " ORDER BY f.[createdAt] ASC" : " ORDER BY f.[createdAt] DESC";
                using (var cmd = new SqlCommand(sql, c)) {
                    if (!string.IsNullOrWhiteSpace(type)) cmd.Parameters.AddWithValue("@t", type);
                    if (!string.IsNullOrWhiteSpace(search)) cmd.Parameters.AddWithValue("@s", "%" + search + "%");
                    using (var da = new SqlDataAdapter(cmd)) { var dt = new DataTable(); da.Fill(dt);
                        foreach (DataRow r in dt.Rows) {
                            string msg = NS(r, "message"); string msgPreview = msg.Length > 100 ? msg.Substring(0, 100) + "..." : msg;
                            string dtype = NS(r, "discussionType");
                            string json = "{\"id\":\"" + EJ(NS(r, "forumId")) + "\",\"title\":\"" + EJ(NS(r, "title")) + "\",\"message\":\"" + EJ(msg) + "\",\"type\":\"" + EJ(dtype) + "\",\"username\":\"" + EJ(NS(r, "username")) + "\",\"role\":\"" + EJ(NS(r, "role")) + "\",\"date\":\"" + (r["createdAt"] != DBNull.Value ? Convert.ToDateTime(r["createdAt"]).ToString("dd MMM yyyy HH:mm") : "-") + "\"}";
                            list.Add(new { forumId = NS(r, "forumId"), title = NS(r, "title"), messagePreview = msgPreview, discussionType = dtype,
                                username = NS(r, "username"), role = NS(r, "role"), createdByUserId = NS(r, "createdBy"),
                                createdAt = r["createdAt"] != DBNull.Value ? Convert.ToDateTime(r["createdAt"]).ToString("dd MMM yyyy") : "-",
                                typeCls = dtype == "Public" ? "fd-badge-public" : "fd-badge-private", jsonData = json });
                        }
                    }
                }
            }
            if (list.Count > 0) { rptForums.DataSource = list; rptForums.DataBind(); pnlEmpty.Visible = false; }
            else { pnlEmpty.Visible = true; }
        }

        protected void btnSearch_Click(object sender, EventArgs e) { LoadStats(); LoadForums(txtSearch.Text.Trim(), ddlType.SelectedValue, ddlSort.SelectedValue); }
        protected void btnReset_Click(object sender, EventArgs e) { txtSearch.Text = ""; ddlType.SelectedIndex = 0; ddlSort.SelectedIndex = 0; LoadStats(); LoadForums("", "", "newest"); }

        private void HandleAction()
        {
            Response.ContentType = "application/json";
            try {
                if (Session["userId"] == null) { Response.Write("{\"success\":false}"); Response.End(); return; }
                string action = Request.QueryString["action"] ?? "";
                string forumId = Request.QueryString["forumId"] ?? "";
                string adminId = Session["userId"].ToString();
                using (var c = new SqlConnection(ConnStr)) { c.Open();
                    switch (action) {
                        case "view":
                            ILog(c, adminId, "Viewed Forum", "Viewed discussion " + forumId + "."); Response.Write("{\"success\":true}"); break;
                        case "delete":
                            string uid = Request.QueryString["uid"] ?? "";
                            // Get title for notification
                            string title = ""; using (var cmd = new SqlCommand("SELECT [title] FROM dbo.[Forum] WHERE [forumId]=@f", c)) { cmd.Parameters.AddWithValue("@f", forumId); var v = cmd.ExecuteScalar(); title = v?.ToString() ?? ""; }
                            // Delete forum chats first, then forum
                            using (var cmd = new SqlCommand("DELETE FROM dbo.[ForumTag] WHERE [forumId]=@f", c)) { cmd.Parameters.AddWithValue("@f", forumId); cmd.ExecuteNonQuery(); }
                            using (var cmd = new SqlCommand("DELETE FROM dbo.[ForumLike] WHERE [forumId]=@f", c)) { cmd.Parameters.AddWithValue("@f", forumId); cmd.ExecuteNonQuery(); }
                            using (var cmd = new SqlCommand("DELETE FROM dbo.[ForumChat] WHERE [forumId]=@f", c)) { cmd.Parameters.AddWithValue("@f", forumId); cmd.ExecuteNonQuery(); }
                            using (var cmd = new SqlCommand("DELETE FROM dbo.[Forum] WHERE [forumId]=@f", c)) { cmd.Parameters.AddWithValue("@f", forumId); cmd.ExecuteNonQuery(); }
                            ILog(c, adminId, "Deleted Forum", "Deleted discussion " + forumId + " (" + title + ").");
                            if (!string.IsNullOrEmpty(uid)) INotif(c, uid, "Discussion Removed", "Perbincangan Dipadam", "Your discussion \"" + title + "\" has been removed by the administrator.", "Perbincangan anda \"" + title + "\" telah dipadam oleh pentadbir.");
                            Response.Write("{\"success\":true}"); break;
                        default: Response.Write("{\"success\":false}"); break;
                    }
                }
            } catch (Exception ex) { Response.Write("{\"success\":false,\"msg\":\"" + EJ(ex.Message) + "\"}"); }
            Response.End();
        }

        private void ILog(SqlConnection c, string uid, string act, string desc) { string id = GID(c, "Log", "logId", "LOG"); using (var cmd = new SqlCommand("INSERT INTO dbo.[Log]([logId],[userId],[action],[description],[logDateTime],[status]) VALUES(@a,@b,@c,@d,@e,'Success')", c)) { cmd.Parameters.AddWithValue("@a", id); cmd.Parameters.AddWithValue("@b", uid); cmd.Parameters.AddWithValue("@c", act); cmd.Parameters.AddWithValue("@d", desc); cmd.Parameters.AddWithValue("@e", DateTime.Now); cmd.ExecuteNonQuery(); } }
        private void INotif(SqlConnection c, string to, string tEN, string tBM, string mEN, string mBM) { if (string.IsNullOrEmpty(to)) return; string id = GID(c, "Notification", "notificationId", "N"); using (var cmd = new SqlCommand("INSERT INTO dbo.[Notification]([notificationId],[toUserId],[titleEN],[titleBM],[messageEN],[messageBM],[isRead],[createdAt]) VALUES(@a,@b,@c,@d,@e,@f,0,@g)", c)) { cmd.Parameters.AddWithValue("@a", id); cmd.Parameters.AddWithValue("@b", to); cmd.Parameters.AddWithValue("@c", tEN); cmd.Parameters.AddWithValue("@d", tBM); cmd.Parameters.AddWithValue("@e", mEN); cmd.Parameters.AddWithValue("@f", mBM); cmd.Parameters.AddWithValue("@g", DateTime.Now); cmd.ExecuteNonQuery(); } }
        private string GID(SqlConnection c, string tbl, string col, string pfx) { using (var cmd = new SqlCommand(string.Format("SELECT TOP 1 [{0}] FROM dbo.[{1}] ORDER BY [{0}] DESC", col, tbl), c)) { var v = cmd.ExecuteScalar(); if (v == null || v == DBNull.Value) return pfx + "001"; string l = v.ToString(); int n; int.TryParse(l.Substring(pfx.Length), out n); n++; return pfx + n.ToString().PadLeft(l.Length - pfx.Length, '0'); } }
        private int SC(SqlConnection c, string sql) { try { using (var cmd = new SqlCommand(sql, c)) { var v = cmd.ExecuteScalar(); return v != null && v != DBNull.Value ? Convert.ToInt32(v) : 0; } } catch { return 0; } }
        private static string NS(DataRow r, string col) { if (!r.Table.Columns.Contains(col)) return ""; return r[col] == null || r[col] == DBNull.Value ? "" : r[col].ToString(); }
        private static string EJ(string s) { return (s ?? "").Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", ""); }
    }
}
