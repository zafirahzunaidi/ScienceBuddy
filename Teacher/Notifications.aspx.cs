using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Teacher
{
    public partial class Notifications : Page
    {
        protected string CurrentLanguage { get { string l = Session["preferredLanguage"] as string; return string.IsNullOrEmpty(l) ? "EN" : l; } }
        protected string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        private string ActiveTab { get { return ViewState["Tab"] as string ?? "All"; } set { ViewState["Tab"] = value; } }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"]?.ToString() != "Teacher")
            { Response.Redirect("~/Login.aspx", false); Context.ApplicationInstance.CompleteRequest(); return; }
            var master = (ScienceBuddy.SiteMaster)Master; master.LayoutMode = "Sidebar";
            if (!IsPostBack) LoadNotifications();
        }

        private void LoadNotifications()
        {
            string userId = Session["userId"].ToString();
            string tab = ActiveTab;

            int countAll = 0, countUnread = 0, countRead = 0;
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                countAll = Count(conn, "SELECT COUNT(*) FROM dbo.[Notification] WHERE [toUserId]=@u", userId);
                countUnread = Count(conn, "SELECT COUNT(*) FROM dbo.[Notification] WHERE [toUserId]=@u AND ([isRead]=0 OR [isRead] IS NULL)", userId);
                countRead = Count(conn, "SELECT COUNT(*) FROM dbo.[Notification] WHERE [toUserId]=@u AND [isRead]=1", userId);
            }

            // Set counts in literals
            litCountAll.Text = countAll.ToString();
            litCountUnread.Text = countUnread.ToString();
            litCountRead.Text = countRead.ToString();

            // Tab active state
            btnTabAll.CssClass = "tc-notifications-tab" + (tab == "All" ? " active" : "");
            btnTabUnread.CssClass = "tc-notifications-tab" + (tab == "Unread" ? " active" : "");
            btnTabRead.CssClass = "tc-notifications-tab" + (tab == "Read" ? " active" : "");

            // Query
            string sql = "SELECT [notificationId],[titleEN],[titleBM],[messageEN],[messageBM],[isRead],[createdAt] FROM dbo.[Notification] WHERE [toUserId]=@u";
            if (tab == "Unread") sql += " AND ([isRead]=0 OR [isRead] IS NULL)";
            else if (tab == "Read") sql += " AND [isRead]=1";
            sql += " ORDER BY [createdAt] DESC";

            var list = new List<object>();
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@u", userId);
                    using (var r = cmd.ExecuteReader())
                        while (r.Read())
                        {
                            string title = CurrentLanguage == "BM"
                                ? (r["titleBM"]?.ToString() ?? r["titleEN"]?.ToString() ?? "")
                                : (r["titleEN"]?.ToString() ?? "");
                            string msg = CurrentLanguage == "BM"
                                ? (r["messageBM"]?.ToString() ?? r["messageEN"]?.ToString() ?? "")
                                : (r["messageEN"]?.ToString() ?? "");
                            bool isRead = r["isRead"] != DBNull.Value && Convert.ToBoolean(r["isRead"]);
                            DateTime created = r["createdAt"] != DBNull.Value ? Convert.ToDateTime(r["createdAt"]) : DateTime.Now;
                            list.Add(new { notificationId = r["notificationId"].ToString(), title, message = msg, isRead, timeDisplay = created.ToString("d MMM yyyy, h:mm tt") });
                        }
                }
            }

            if (list.Count > 0) { pnlList.Visible = true; pnlEmpty.Visible = false; rptNotifs.DataSource = list; rptNotifs.DataBind(); }
            else { pnlList.Visible = false; pnlEmpty.Visible = true; }
        }

        protected void btnTab_Click(object sender, EventArgs e)
        {
            var btn = (LinkButton)sender;
            ActiveTab = btn.CommandArgument;
            LoadNotifications();
        }

        protected void rptNotifs_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "MarkRead")
            {
                string nid = e.CommandArgument.ToString();
                string userId = Session["userId"].ToString();
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("UPDATE dbo.[Notification] SET [isRead]=1 WHERE [notificationId]=@nid AND [toUserId]=@uid", conn))
                    { cmd.Parameters.AddWithValue("@nid", nid); cmd.Parameters.AddWithValue("@uid", userId); cmd.ExecuteNonQuery(); }
                }
                hidToast.Value = T("Notification marked as read.", "Pemberitahuan ditandai dibaca.");
                LoadNotifications();
            }
        }

        private int Count(SqlConnection conn, string sql, string userId)
        { using (var cmd = new SqlCommand(sql, conn)) { cmd.Parameters.AddWithValue("@u", userId); return Convert.ToInt32(cmd.ExecuteScalar()); } }
    }
}
