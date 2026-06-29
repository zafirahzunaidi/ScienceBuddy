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
    public partial class Notifications : Page
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

            if (!IsPostBack)
            {
                InitLanguage();
                SetLabels();
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
            litTotalLbl.Text  = T("Total Notifications", "Jumlah Pemberitahuan");
            litUnreadLbl.Text = T("Unread", "Belum Dibaca");
            litLatestLbl.Text = T("Latest", "Terkini");
            litBackBtn.Text   = T("Back to Dashboard", "Kembali ke Dashboard");
            litMarkAll.Text   = T("Mark All as Read", "Tandai Semua Dibaca");
            litEmptyTitle.Text = T("Nothing here yet", "Tiada apa-apa di sini lagi");
            litEmptyDesc.Text  = T("Your learning updates will appear here.",
                                   "Kemas kini pembelajaran anda akan muncul di sini.");
            litEmptyBtn.Text   = T("Back to Dashboard", "Kembali ke Dashboard");
        }

        private void LoadNotifications()
        {
            string userId = Session["userId"].ToString();

            if (!TableExists("Notification"))
            {
                ShowEmpty(0, 0);
                return;
            }

            DataTable dt;
            const string sql = @"
                SELECT notificationId, titleEN, titleBM, messageEN, messageBM,
                       isRead, createdAt
                FROM   Notification
                WHERE  toUserId = @userId
                ORDER BY createdAt DESC";

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                var da = new SqlDataAdapter(cmd);
                dt = new DataTable();
                conn.Open();
                da.Fill(dt);
            }

            int total  = dt.Rows.Count;
            int unread = 0;
            DateTime? latest = null;

            var list = new List<object>();
            bool isBM = CurrentLanguage == "BM";

            foreach (DataRow row in dt.Rows)
            {
                bool isRead = Convert.ToBoolean(row["isRead"]);
                if (!isRead) unread++;

                DateTime created = row["createdAt"] == DBNull.Value
                    ? DateTime.Now : Convert.ToDateTime(row["createdAt"]);

                if (latest == null || created > latest) latest = created;

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

            // Summary
            litTotalCount.Text  = total.ToString();
            litUnreadCount.Text = unread.ToString();
            litLatestDate.Text  = latest.HasValue ? latest.Value.ToString("d MMM yyyy") : "—";

            if (total == 0)
            {
                ShowEmpty(total, unread);
                return;
            }

            pnlList.Visible  = true;
            pnlEmpty.Visible = false;
            btnMarkAllRead.Visible = unread > 0;
            rptNotifications.DataSource = list;
            rptNotifications.DataBind();
        }

        private void ShowEmpty(int total, int unread)
        {
            pnlList.Visible  = false;
            pnlEmpty.Visible = true;
            btnMarkAllRead.Visible = false;
            litTotalCount.Text  = total.ToString();
            litUnreadCount.Text = unread.ToString();
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
