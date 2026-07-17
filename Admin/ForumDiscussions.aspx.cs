using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

// Admin ForumDiscussions - Code Behind

namespace ScienceBuddy.Admin
{
    public partial class ForumDiscussions : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected string CurrentLanguage => ((ScienceBuddy.SiteMaster)Master).CurrentLanguage;

        protected string T(string en, string bm) => CurrentLanguage == "BM" ? bm : en;

        // --- Page Lifecycle ---

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.QueryString["handler"] == "ForumAction" && Request.HttpMethod == "POST")
            { HandleAction(); return; }

            if (Session["userId"] == null || Session["role"]?.ToString() != "Admin")
            { Response.Redirect("~/Login.aspx", false); return; }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                SetUserInfo();
                LoadStats();
                LoadForums("", "", "newest");
                txtSearch.Attributes["placeholder"] = T("Search forum title, message, username...", "Cari tajuk forum, mesej, nama pengguna...");
            }
        }

        private void SetUserInfo()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [username] FROM dbo.[User] WHERE [userId]=@u", conn))
                {
                    cmd.Parameters.AddWithValue("@u", Session["userId"].ToString());
                    var result = cmd.ExecuteScalar();
                    string name = result?.ToString() ?? "Admin";
                    string initials = name.Length >= 2 ? name.Substring(0, 2).ToUpper() : name.ToUpper();
                    ((ScienceBuddy.SiteMaster)Master).SetUserInfo(name, "Administrator", initials);
                }
            }
        }

        // --- Data Loading ---

        private void LoadStats()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                litTotal.Text = SafeCount(conn, "SELECT COUNT(*) FROM dbo.[Forum]").ToString();
                litPublic.Text = SafeCount(conn, "SELECT COUNT(*) FROM dbo.[Forum] WHERE [discussionType]='Public'").ToString();
                litPrivate.Text = SafeCount(conn, "SELECT COUNT(*) FROM dbo.[Forum] WHERE [discussionType]='Private'").ToString();
                litToday.Text = SafeCount(conn, "SELECT COUNT(*) FROM dbo.[Forum] WHERE CAST([createdAt] AS DATE)=CAST(GETDATE() AS DATE)").ToString();
            }
        }

        private void LoadForums(string search, string type, string sort)
        {
            var list = new List<object>();

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                string sql = @"SELECT f.[forumId],f.[title],f.[message],f.[discussionType],f.[createdAt],f.[createdBy],
                    u.[username],u.[role] FROM dbo.[Forum] f LEFT JOIN dbo.[User] u ON u.[userId]=f.[createdBy] WHERE 1=1";

                if (!string.IsNullOrWhiteSpace(type))
                    sql += " AND f.[discussionType]=@t";
                if (!string.IsNullOrWhiteSpace(search))
                    sql += " AND (f.[title] LIKE @s OR f.[message] LIKE @s OR u.[username] LIKE @s OR f.[forumId] LIKE @s)";

                sql += sort == "oldest" ? " ORDER BY f.[createdAt] ASC" : " ORDER BY f.[createdAt] DESC";

                using (var cmd = new SqlCommand(sql, conn))
                {
                    if (!string.IsNullOrWhiteSpace(type))
                        cmd.Parameters.AddWithValue("@t", type);
                    if (!string.IsNullOrWhiteSpace(search))
                        cmd.Parameters.AddWithValue("@s", "%" + search + "%");

                    using (var da = new SqlDataAdapter(cmd))
                    {
                        var dt = new DataTable();
                        da.Fill(dt);

                        foreach (DataRow row in dt.Rows)
                        {
                            string msg = NullSafe(row, "message");
                            string msgPreview = msg.Length > 100 ? msg.Substring(0, 100) + "..." : msg;
                            string dtype = NullSafe(row, "discussionType");
                            string json = "{\"id\":\"" + EscapeJson(NullSafe(row, "forumId")) +
                                "\",\"title\":\"" + EscapeJson(NullSafe(row, "title")) +
                                "\",\"message\":\"" + EscapeJson(msg) +
                                "\",\"type\":\"" + EscapeJson(dtype) +
                                "\",\"username\":\"" + EscapeJson(NullSafe(row, "username")) +
                                "\",\"role\":\"" + EscapeJson(NullSafe(row, "role")) +
                                "\",\"date\":\"" + (row["createdAt"] != DBNull.Value ? Convert.ToDateTime(row["createdAt"]).ToString("dd MMM yyyy HH:mm") : "-") + "\"}";

                            list.Add(new
                            {
                                forumId = NullSafe(row, "forumId"),
                                title = NullSafe(row, "title"),
                                messagePreview = msgPreview,
                                discussionType = dtype,
                                username = NullSafe(row, "username"),
                                role = NullSafe(row, "role"),
                                createdByUserId = NullSafe(row, "createdBy"),
                                createdAt = row["createdAt"] != DBNull.Value ? Convert.ToDateTime(row["createdAt"]).ToString("dd MMM yyyy") : "-",
                                typeCls = dtype == "Public" ? "ad-forum-discussions-badge-public" : "ad-forum-discussions-badge-private",
                                jsonData = json
                            });
                        }
                    }
                }
            }

            if (list.Count > 0)
            {
                rptForums.DataSource = list;
                rptForums.DataBind();
                pnlEmpty.Visible = false;
            }
            else
            {
                pnlEmpty.Visible = true;
            }
        }

        // --- Event Handlers ---

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadStats();
            LoadForums(txtSearch.Text.Trim(), ddlType.SelectedValue, ddlSort.SelectedValue);
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlType.SelectedIndex = 0;
            ddlSort.SelectedIndex = 0;
            LoadStats();
            LoadForums("", "", "newest");
        }

        // --- AJAX Handlers ---

        private void HandleAction()
        {
            Response.ContentType = "application/json";
            try
            {
                if (Session["userId"] == null)
                { Response.Write("{\"success\":false}"); Response.End(); return; }

                string action = Request.QueryString["action"] ?? "";
                string forumId = Request.QueryString["forumId"] ?? "";
                string adminId = Session["userId"].ToString();

                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    switch (action)
                    {
                        case "view":
                            InsertLog(conn, adminId, "Viewed Forum", "Viewed discussion " + forumId + ".");
                            Response.Write("{\"success\":true}");
                            break;

                        case "delete":
                            string uid = Request.QueryString["uid"] ?? "";

                            // Get title for notification
                            string title = "";
                            using (var cmd = new SqlCommand("SELECT [title] FROM dbo.[Forum] WHERE [forumId]=@f", conn))
                            {
                                cmd.Parameters.AddWithValue("@f", forumId);
                                var result = cmd.ExecuteScalar();
                                title = result?.ToString() ?? "";
                            }

                            // Delete forum related data first, then the forum itself
                            using (var cmd = new SqlCommand("DELETE FROM dbo.[ForumTag] WHERE [forumId]=@f", conn))
                            { cmd.Parameters.AddWithValue("@f", forumId); cmd.ExecuteNonQuery(); }
                            using (var cmd = new SqlCommand("DELETE FROM dbo.[ForumLike] WHERE [forumId]=@f", conn))
                            { cmd.Parameters.AddWithValue("@f", forumId); cmd.ExecuteNonQuery(); }
                            using (var cmd = new SqlCommand("DELETE FROM dbo.[ForumChat] WHERE [forumId]=@f", conn))
                            { cmd.Parameters.AddWithValue("@f", forumId); cmd.ExecuteNonQuery(); }
                            using (var cmd = new SqlCommand("DELETE FROM dbo.[Forum] WHERE [forumId]=@f", conn))
                            { cmd.Parameters.AddWithValue("@f", forumId); cmd.ExecuteNonQuery(); }

                            InsertLog(conn, adminId, "Deleted Forum", "Deleted discussion " + forumId + " (" + title + ").");

                            if (!string.IsNullOrEmpty(uid))
                                InsertNotification(conn, uid, "Discussion Removed", "Perbincangan Dipadam",
                                    "Your discussion \"" + title + "\" has been removed by the administrator.",
                                    "Perbincangan anda \"" + title + "\" telah dipadam oleh pentadbir.");

                            Response.Write("{\"success\":true}");
                            break;

                        default:
                            Response.Write("{\"success\":false}");
                            break;
                    }
                }
            }
            catch (Exception ex)
            {
                Response.Write("{\"success\":false,\"msg\":\"" + EscapeJson(ex.Message) + "\"}");
            }
            Response.End();
        }

        // --- Helpers ---

        private void InsertLog(SqlConnection conn, string uid, string action, string desc)
        {
            string id = GenerateId(conn, "Log", "logId", "LOG");
            using (var cmd = new SqlCommand("INSERT INTO dbo.[Log]([logId],[userId],[action],[description],[logDateTime],[status]) VALUES(@a,@b,@c,@d,@e,'Success')", conn))
            {
                cmd.Parameters.AddWithValue("@a", id);
                cmd.Parameters.AddWithValue("@b", uid);
                cmd.Parameters.AddWithValue("@c", action);
                cmd.Parameters.AddWithValue("@d", desc);
                cmd.Parameters.AddWithValue("@e", DateTime.Now);
                cmd.ExecuteNonQuery();
            }
        }

        private void InsertNotification(SqlConnection conn, string toUserId, string titleEN, string titleBM, string msgEN, string msgBM)
        {
            if (string.IsNullOrEmpty(toUserId)) return;
            string id = GenerateId(conn, "Notification", "notificationId", "N");
            using (var cmd = new SqlCommand("INSERT INTO dbo.[Notification]([notificationId],[toUserId],[titleEN],[titleBM],[messageEN],[messageBM],[isRead],[createdAt]) VALUES(@a,@b,@c,@d,@e,@f,0,@g)", conn))
            {
                cmd.Parameters.AddWithValue("@a", id);
                cmd.Parameters.AddWithValue("@b", toUserId);
                cmd.Parameters.AddWithValue("@c", titleEN);
                cmd.Parameters.AddWithValue("@d", titleBM);
                cmd.Parameters.AddWithValue("@e", msgEN);
                cmd.Parameters.AddWithValue("@f", msgBM);
                cmd.Parameters.AddWithValue("@g", DateTime.Now);
                cmd.ExecuteNonQuery();
            }
        }

        private string GenerateId(SqlConnection conn, string tbl, string col, string pfx)
        {
            using (var cmd = new SqlCommand(string.Format("SELECT TOP 1 [{0}] FROM dbo.[{1}] ORDER BY [{0}] DESC", col, tbl), conn))
            {
                var result = cmd.ExecuteScalar();
                if (result == null || result == DBNull.Value) return pfx + "001";
                string lastId = result.ToString();
                int num;
                int.TryParse(lastId.Substring(pfx.Length), out num);
                num++;
                return pfx + num.ToString().PadLeft(lastId.Length - pfx.Length, '0');
            }
        }

        private int SafeCount(SqlConnection conn, string sql)
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

        private static string NullSafe(DataRow row, string col)
        {
            if (!row.Table.Columns.Contains(col)) return "";
            return row[col] == null || row[col] == DBNull.Value ? "" : row[col].ToString();
        }

        private static string EscapeJson(string s)
        {
            return (s ?? "").Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "");
        }
    }
}
