using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Student
{
    public partial class Notifications1 : Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        private string CurrentLanguage = "EN";

        private string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null ||
                Session["role"].ToString() != "Student")
            {
                Response.Redirect("~/Login.aspx", false);
                return;
            }

            var master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            // Always init language and labels (fixes BM toggle + postback text loss)
            InitLanguage();
            SetLabels();

            if (!IsPostBack)
            {
                LoadNotifications();
            }
        }

        private void InitLanguage()
        {
            string lang = Session["preferredLanguage"] as string;
            if (!string.IsNullOrEmpty(lang))
            {
                CurrentLanguage = lang;
                return;
            }

            string userId = Session["userId"] as string;
            if (!string.IsNullOrEmpty(userId))
            {
                try
                {
                    const string sql = "SELECT preferredLanguage FROM [User] WHERE userId = @userId";
                    using (var conn = new SqlConnection(ConnStr))
                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@userId", userId);
                        conn.Open();
                        object result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            lang = result.ToString();
                            Session["preferredLanguage"] = lang;
                            CurrentLanguage = lang;
                            return;
                        }
                    }
                }
                catch (SqlException) { }
            }

            CurrentLanguage = "EN";
            Session["preferredLanguage"] = "EN";
        }

        private void SetLabels()
        {
            litPageTitle.Text = T("Notifications", "Pemberitahuan");
            litTitle.Text     = T("Notifications", "Pemberitahuan");
            litSubtitle.Text  = T("Stay updated with your learning activities.",
                                  "Kekal dikemas kini dengan aktiviti pembelajaran anda.");
            litFilterAll.Text = T("All", "Semua");
            litFilterUnread.Text = T("Unread", "Belum Dibaca");
            litFilterRead.Text = T("Read", "Dibaca");
            litMarkAll.Text   = T("Mark All Read", "Tandai Semua Dibaca");
            litEmptyTitle.Text = T("All caught up!", "Semuanya dikemas kini!");
            litEmptyDesc.Text  = T("No notifications here. Keep learning and updates will appear!",
                                   "Tiada pemberitahuan di sini. Teruskan belajar dan kemas kini akan muncul!");
            litEmptyBtn.Text   = T("Continue Learning", "Teruskan Belajar");
            txtSearch.Attributes["placeholder"] = T("Search notifications...", "Cari pemberitahuan...");

            // Update filter chip active state
            string filter = ViewState["Filter"] as string ?? "all";
            btnFilterAll.CssClass = filter == "all" ? "st-notifications-chip active" : "st-notifications-chip";
            btnFilterUnread.CssClass = filter == "unread" ? "st-notifications-chip active" : "st-notifications-chip";
            btnFilterRead.CssClass = filter == "read" ? "st-notifications-chip active" : "st-notifications-chip";
        }

        private void LoadNotifications()
        {
            string userId = Session["userId"].ToString();

            if (!TableExists("Notification"))
            {
                ShowEmpty(userId);
                return;
            }

            string filter = ViewState["Filter"] as string ?? "all";
            string search = txtSearch.Text.Trim();

            string sql = @"
                SELECT notificationId, titleEN, titleBM, messageEN, messageBM,
                       isRead, createdAt
                FROM   Notification
                WHERE  toUserId = @userId";

            if (filter == "unread") sql += " AND isRead = 0";
            else if (filter == "read") sql += " AND isRead = 1";

            if (!string.IsNullOrEmpty(search))
                sql += " AND (titleEN LIKE @search OR titleBM LIKE @search OR messageEN LIKE @search OR messageBM LIKE @search)";

            sql += " ORDER BY createdAt DESC";

            DataTable dt;
            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                if (!string.IsNullOrEmpty(search))
                    cmd.Parameters.AddWithValue("@search", "%" + search + "%");
                var da = new SqlDataAdapter(cmd);
                dt = new DataTable();
                conn.Open();
                da.Fill(dt);
            }

            int unread = 0;
            var list = new List<object>();
            bool isBM = CurrentLanguage == "BM";

            foreach (DataRow row in dt.Rows)
            {
                bool isRead = Convert.ToBoolean(row["isRead"]);
                if (!isRead) unread++;

                DateTime created = row["createdAt"] == DBNull.Value
                    ? DateTime.Now : Convert.ToDateTime(row["createdAt"]);

                string title = isBM ? row["titleBM"].ToString() : row["titleEN"].ToString();
                if (string.IsNullOrWhiteSpace(title)) title = row["titleEN"].ToString();

                string message = isBM ? row["messageBM"].ToString() : row["messageEN"].ToString();
                if (string.IsNullOrWhiteSpace(message)) message = row["messageEN"].ToString();

                list.Add(new
                {
                    Id        = row["notificationId"].ToString(),
                    Title     = HttpUtility.HtmlEncode(title),
                    Message   = HttpUtility.HtmlEncode(message),
                    IsRead    = isRead,
                    TimeAgo   = FormatTimeAgo(created),
                    Icon      = GetIcon(title),
                    IconBg    = isRead ? "#F0F7FF" : "#FFF0E8",
                    IconColor = isRead ? "#64748B" : "#FF6B2C"
                });
            }

            if (list.Count == 0)
            {
                ShowEmpty(userId);
                return;
            }

            pnlList.Visible  = true;
            pnlEmpty.Visible = false;
            // Show Mark All Read based on GLOBAL unread count, not filtered
            btnMarkAllRead.Visible = GetGlobalUnreadCount(userId) > 0;
            rptNotifications.DataSource = list;
            rptNotifications.DataBind();
        }

        private void ShowEmpty(string userId)
        {
            pnlList.Visible  = false;
            pnlEmpty.Visible = true;
            // Still show Mark All Read if unread exist globally
            btnMarkAllRead.Visible = GetGlobalUnreadCount(userId) > 0;
        }

        private int GetGlobalUnreadCount(string userId)
        {
            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand("SELECT COUNT(*) FROM Notification WHERE toUserId=@uid AND isRead=0", conn))
            {
                cmd.Parameters.AddWithValue("@uid", userId);
                conn.Open();
                return (int)cmd.ExecuteScalar();
            }
        }

        // ── Event handlers ────────────────────────────────────────────

        protected void btnMarkAllRead_Click(object sender, EventArgs e)
        {
            string userId = Session["userId"].ToString();
            const string sql = @"
                UPDATE Notification SET isRead = 1
                WHERE  toUserId = @userId AND isRead = 0";

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                conn.Open();
                cmd.ExecuteNonQuery();
            }

            InitLanguage();
            SetLabels();
            LoadNotifications();
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            var btn = (LinkButton)sender;
            ViewState["Filter"] = btn.CommandArgument;
            InitLanguage();
            SetLabels();
            LoadNotifications();
        }

        protected void rptNotifications_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "MarkRead")
            {
                string notifId = e.CommandArgument.ToString();
                string userId  = Session["userId"].ToString();

                const string sql = @"
                    UPDATE Notification SET isRead = 1
                    WHERE  notificationId = @notifId
                    AND    toUserId = @userId";

                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@notifId", notifId);
                    cmd.Parameters.AddWithValue("@userId",  userId);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                InitLanguage();
                SetLabels();
                LoadNotifications();
            }
        }

        // ── Utilities ─────────────────────────────────────────────────

        private static string GetIcon(string title)
        {
            if (string.IsNullOrEmpty(title)) return "bi-bell";
            string t = title.ToLower();
            if (t.Contains("badge") || t.Contains("lencana"))  return "bi-award-fill";
            if (t.Contains("quiz") || t.Contains("kuiz"))      return "bi-patch-question-fill";
            if (t.Contains("lesson") || t.Contains("pelajaran")) return "bi-book-fill";
            if (t.Contains("live") || t.Contains("langsung"))  return "bi-camera-video-fill";
            if (t.Contains("xp"))                               return "bi-lightning-charge-fill";
            if (t.Contains("forum"))                            return "bi-chat-dots-fill";
            return "bi-bell-fill";
        }

        private static string FormatTimeAgo(DateTime dt)
        {
            var span = DateTime.Now - dt;
            if (span.TotalMinutes < 1)  return "Just now";
            if (span.TotalHours   < 1)  return (int)span.TotalMinutes + " min ago";
            if (span.TotalDays    < 1)  return (int)span.TotalHours   + " hr ago";
            if (span.TotalDays    < 7)  return (int)span.TotalDays    + " day" + ((int)span.TotalDays == 1 ? "" : "s") + " ago";
            return dt.ToString("d MMM yyyy");
        }

        private bool TableExists(string tableName)
        {
            const string sql = @"
                SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
                WHERE TABLE_NAME = @tableName AND TABLE_TYPE = 'BASE TABLE'";
            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@tableName", tableName);
                conn.Open();
                return (int)cmd.ExecuteScalar() > 0;
            }
        }
    }
}
