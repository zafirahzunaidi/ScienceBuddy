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
        private string ConnectionString
        {
            get { return ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString; }
        }

        private string CurrentLanguage = "EN";

        private string T(string englishText, string malayText)
        {
            if (CurrentLanguage == "BM")
            {
                return malayText;
            }
            return englishText;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null || Session["role"].ToString() != "Student")
            {
                Response.Redirect("~/Login.aspx", false);
                return;
            }

            ScienceBuddy.SiteMaster master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            InitLanguage();
            SetLabels();

            if (!IsPostBack)
            {
                LoadNotifications();
            }
        }

        private void InitLanguage()
        {
            string lang = null;

            if (Session["preferredLanguage"] != null)
            {
                lang = Session["preferredLanguage"].ToString();
            }

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
                    using (SqlConnection connection = new SqlConnection(ConnectionString))
                    using (SqlCommand command = new SqlCommand(sql, connection))
                    {
                        command.Parameters.AddWithValue("@userId", userId);
                        connection.Open();
                        object result = command.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            lang = result.ToString();
                            Session["preferredLanguage"] = lang;
                            CurrentLanguage = lang;
                            return;
                        }
                    }
                }
                catch (SqlException ex)
                {
                    System.Diagnostics.Debug.WriteLine("Error loading preferred language: " + ex.Message);
                }
            }

            CurrentLanguage = "EN";
            Session["preferredLanguage"] = "EN";
        }

        private void SetLabels()
        {
            litTitle.Text = T("Notifications", "Pemberitahuan");
            litFilterAll.Text = T("All", "Semua");
            litFilterUnread.Text = T("Unread", "Belum Dibaca");
            litFilterRead.Text = T("Read", "Dibaca");
            litMarkAll.Text = T("Mark All Read", "Tanda Semua Telah Dibaca");
            litEmptyTitle.Text = T("All caught up!", "Semuanya dikemas kini!");
            litEmptyDesc.Text = T("No notifications here. Keep learning and updates will appear!", "Tiada pemberitahuan di sini. Teruskan belajar dan kemas kini akan muncul!");
            litEmptyBtn.Text = T("Continue Learning", "Teruskan Belajar");
            txtSearch.Attributes["placeholder"] = T("Search notifications...", "Cari pemberitahuan...");

            // Update filter chip active state
            string filter;
            if (ViewState["Filter"] != null)
            {
                filter = ViewState["Filter"].ToString();
            }
            else
            {
                filter = "all";
            }

            if (filter == "all")
            {
                btnFilterAll.CssClass = "st-notifications-chip active";
            }
            else
            {
                btnFilterAll.CssClass = "st-notifications-chip";
            }

            if (filter == "unread")
            {
                btnFilterUnread.CssClass = "st-notifications-chip active";
            }
            else
            {
                btnFilterUnread.CssClass = "st-notifications-chip";
            }

            if (filter == "read")
            {
                btnFilterRead.CssClass = "st-notifications-chip active";
            }
            else
            {
                btnFilterRead.CssClass = "st-notifications-chip";
            }
        }

        private void LoadNotifications()
        {
            string userId = Session["userId"].ToString();

            if (!TableExists("Notification"))
            {
                ShowEmpty(userId);
                return;
            }

            string filter;
            if (ViewState["Filter"] != null)
            {
                filter = ViewState["Filter"].ToString();
            }
            else
            {
                filter = "all";
            }

            string search = txtSearch.Text.Trim();

            string sql = @"
                SELECT notificationId, titleEN, titleBM, messageEN, messageBM,
                       isRead, createdAt
                FROM   Notification
                WHERE  toUserId = @userId";

            if (filter == "unread")
            {
                sql += " AND isRead = 0";
            }
            else if (filter == "read")
            {
                sql += " AND isRead = 1";
            }

            if (!string.IsNullOrEmpty(search))
            {
                sql += " AND (titleEN LIKE @search OR titleBM LIKE @search OR messageEN LIKE @search OR messageBM LIKE @search)";
            }

            sql += " ORDER BY createdAt DESC";

            DataTable dataTable;
            using (SqlConnection connection = new SqlConnection(ConnectionString))
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@userId", userId);
                if (!string.IsNullOrEmpty(search))
                {
                    command.Parameters.AddWithValue("@search", "%" + search + "%");
                }
                SqlDataAdapter adapter = new SqlDataAdapter(command);
                dataTable = new DataTable();
                connection.Open();
                adapter.Fill(dataTable);
            }

            int unread = 0;
            List<object> list = new List<object>();
            bool isBM = CurrentLanguage == "BM";

            foreach (DataRow row in dataTable.Rows)
            {
                bool isRead = Convert.ToBoolean(row["isRead"]);
                if (!isRead)
                {
                    unread++;
                }

                DateTime created;
                if (row["createdAt"] == DBNull.Value)
                {
                    created = DateTime.Now;
                }
                else
                {
                    created = Convert.ToDateTime(row["createdAt"]);
                }

                string title;
                if (isBM)
                {
                    title = row["titleBM"].ToString();
                }
                else
                {
                    title = row["titleEN"].ToString();
                }
                if (string.IsNullOrWhiteSpace(title))
                {
                    title = row["titleEN"].ToString();
                }

                string message;
                if (isBM)
                {
                    message = row["messageBM"].ToString();
                }
                else
                {
                    message = row["messageEN"].ToString();
                }
                if (string.IsNullOrWhiteSpace(message))
                {
                    message = row["messageEN"].ToString();
                }

                string iconBg;
                if (isRead)
                {
                    iconBg = "#F0F7FF";
                }
                else
                {
                    iconBg = "#FFF0E8";
                }

                string iconColor;
                if (isRead)
                {
                    iconColor = "#64748B";
                }
                else
                {
                    iconColor = "#FF6B2C";
                }

                list.Add(new
                {
                    Id = row["notificationId"].ToString(),
                    Title = HttpUtility.HtmlEncode(title),
                    Message = HttpUtility.HtmlEncode(message),
                    IsRead = isRead,
                    TimeAgo = FormatTimeAgo(created),
                    Icon = GetIcon(title),
                    IconBg = iconBg,
                    IconColor = iconColor
                });
            }

            if (list.Count == 0)
            {
                ShowEmpty(userId);
                return;
            }

            pnlList.Visible = true;
            pnlEmpty.Visible = false;
            // Show Mark All Read based on GLOBAL unread count, not filtered
            btnMarkAllRead.Visible = GetGlobalUnreadCount(userId) > 0;
            rptNotifications.DataSource = list;
            rptNotifications.DataBind();
        }

        private void ShowEmpty(string userId)
        {
            pnlList.Visible = false;
            pnlEmpty.Visible = true;
            // Still show Mark All Read if unread exist globally
            btnMarkAllRead.Visible = GetGlobalUnreadCount(userId) > 0;
        }

        private int GetGlobalUnreadCount(string userId)
        {
            using (SqlConnection connection = new SqlConnection(ConnectionString))
            using (SqlCommand command = new SqlCommand("SELECT COUNT(*) FROM Notification WHERE toUserId=@uid AND isRead=0", connection))
            {
                command.Parameters.AddWithValue("@uid", userId);
                connection.Open();
                return (int)command.ExecuteScalar();
            }
        }

        // Event handlers

        protected void btnMarkAllRead_Click(object sender, EventArgs e)
        {
            string userId = Session["userId"].ToString();
            const string sql = @"
                UPDATE Notification SET isRead = 1
                WHERE  toUserId = @userId AND isRead = 0";

            using (SqlConnection connection = new SqlConnection(ConnectionString))
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@userId", userId);
                connection.Open();
                command.ExecuteNonQuery();
            }

            InitLanguage();
            SetLabels();
            LoadNotifications();
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            LinkButton button = (LinkButton)sender;
            ViewState["Filter"] = button.CommandArgument;
            InitLanguage();
            SetLabels();
            LoadNotifications();
        }

        protected void rptNotifications_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "MarkRead")
            {
                string notifId = e.CommandArgument.ToString();
                string userId = Session["userId"].ToString();

                const string sql = @"
                    UPDATE Notification SET isRead = 1
                    WHERE  notificationId = @notifId
                    AND    toUserId = @userId";

                using (SqlConnection connection = new SqlConnection(ConnectionString))
                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    command.Parameters.AddWithValue("@notifId", notifId);
                    command.Parameters.AddWithValue("@userId", userId);
                    connection.Open();
                    command.ExecuteNonQuery();
                }

                InitLanguage();
                SetLabels();
                LoadNotifications();
            }
        }

        // Utilities

        private static string GetIcon(string title)
        {
            if (string.IsNullOrEmpty(title))
            {
                return "bi-bell";
            }
            string t = title.ToLower();
            if (t.Contains("badge") || t.Contains("lencana"))
            {
                return "bi-award-fill";
            }
            if (t.Contains("quiz") || t.Contains("kuiz"))
            {
                return "bi-patch-question-fill";
            }
            if (t.Contains("lesson") || t.Contains("pelajaran"))
            {
                return "bi-book-fill";
            }
            if (t.Contains("live") || t.Contains("langsung"))
            {
                return "bi-camera-video-fill";
            }
            if (t.Contains("xp"))
            {
                return "bi-lightning-charge-fill";
            }
            if (t.Contains("forum"))
            {
                return "bi-chat-dots-fill";
            }
            return "bi-bell-fill";
        }

        private static string FormatTimeAgo(DateTime dt)
        {
            TimeSpan span = DateTime.Now - dt;
            if (span.TotalMinutes < 1)
            {
                return "Just now";
            }
            if (span.TotalHours < 1)
            {
                return (int)span.TotalMinutes + " min ago";
            }
            if (span.TotalDays < 1)
            {
                return (int)span.TotalHours + " hr ago";
            }
            if (span.TotalDays < 7)
            {
                return (int)span.TotalDays + " day" + ((int)span.TotalDays == 1 ? "" : "s") + " ago";
            }
            return dt.ToString("d MMM yyyy");
        }

        private bool TableExists(string tableName)
        {
            const string sql = @"
                SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
                WHERE TABLE_NAME = @tableName AND TABLE_TYPE = 'BASE TABLE'";
            using (SqlConnection connection = new SqlConnection(ConnectionString))
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@tableName", tableName);
                connection.Open();
                return (int)command.ExecuteScalar() > 0;
            }
        }
    }
}
