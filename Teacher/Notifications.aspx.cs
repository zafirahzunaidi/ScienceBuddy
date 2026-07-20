using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Teacher
{
    public partial class Notifications : Page
    {
        #region Properties

        protected string CurrentLanguage
        {
            get
            {
                string lang = Session["preferredLanguage"] as string;
                return string.IsNullOrEmpty(lang) ? "EN" : lang;
            }
        }

        private string ConnectionString =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        private string ActiveTab
        {
            get { return ViewState["Tab"] as string ?? "All"; }
            set { ViewState["Tab"] = value; }
        }

        #endregion

        #region Page Lifecycle

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"]?.ToString() != "Teacher")
            {
                Response.Redirect("~/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            var master = (SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            if (!IsPostBack)
                LoadNotifications();
        }

        #endregion

        #region Event Handlers

        protected void btnTab_Click(object sender, EventArgs e)
        {
            var button = (LinkButton)sender;
            ActiveTab = button.CommandArgument;
            LoadNotifications();
        }

        protected void rptNotifs_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "MarkRead")
                return;

            string notificationId = e.CommandArgument.ToString();
            string teacherId = Session["userId"].ToString();

            MarkNotificationAsRead(notificationId, teacherId);

            hidToast.Value = T("Notification marked as read.", "Pemberitahuan ditandai dibaca.");
            LoadNotifications();
        }

        #endregion

        #region Data Loading

        private void LoadNotifications()
        {
            string teacherId = Session["userId"].ToString();
            string currentTab = ActiveTab;

            LoadNotificationCounts(teacherId);
            UpdateTabStyles(currentTab);

            var notifications = FetchNotifications(teacherId, currentTab);

            if (notifications.Count > 0)
            {
                pnlList.Visible = true;
                pnlEmpty.Visible = false;
                rptNotifs.DataSource = notifications;
                rptNotifs.DataBind();
            }
            else
            {
                pnlList.Visible = false;
                pnlEmpty.Visible = true;
            }
        }

        private void LoadNotificationCounts(string teacherId)
        {
            using (var conn = new SqlConnection(ConnectionString))
            {
                conn.Open();

                litCountAll.Text = ExecuteCount(conn,
                    "SELECT COUNT(*) FROM dbo.[Notification] WHERE [toUserId]=@u",
                    teacherId).ToString();

                litCountUnread.Text = ExecuteCount(conn,
                    "SELECT COUNT(*) FROM dbo.[Notification] WHERE [toUserId]=@u AND ([isRead]=0 OR [isRead] IS NULL)",
                    teacherId).ToString();

                litCountRead.Text = ExecuteCount(conn,
                    "SELECT COUNT(*) FROM dbo.[Notification] WHERE [toUserId]=@u AND [isRead]=1",
                    teacherId).ToString();
            }
        }

        private List<object> FetchNotifications(string teacherId, string tab)
        {
            string sql = @"SELECT [notificationId], [titleEN], [titleBM], [messageEN], [messageBM], [isRead], [createdAt]
                           FROM dbo.[Notification]
                           WHERE [toUserId] = @u";

            if (tab == "Unread")
                sql += " AND ([isRead]=0 OR [isRead] IS NULL)";
            else if (tab == "Read")
                sql += " AND [isRead]=1";

            sql += " ORDER BY [createdAt] DESC";

            var notifications = new List<object>();

            using (var conn = new SqlConnection(ConnectionString))
            {
                conn.Open();
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@u", teacherId);

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string title = GetLocalizedText(reader, "titleEN", "titleBM");
                            string message = GetLocalizedText(reader, "messageEN", "messageBM");
                            bool isRead = reader["isRead"] != DBNull.Value && Convert.ToBoolean(reader["isRead"]);
                            DateTime createdAt = reader["createdAt"] != DBNull.Value
                                ? Convert.ToDateTime(reader["createdAt"])
                                : DateTime.Now;

                            notifications.Add(new
                            {
                                notificationId = reader["notificationId"].ToString(),
                                title,
                                message,
                                isRead,
                                timeDisplay = createdAt.ToString("d MMM yyyy, h:mm tt")
                            });
                        }
                    }
                }
            }

            return notifications;
        }

        #endregion

        #region Database Operations

        private void MarkNotificationAsRead(string notificationId, string teacherId)
        {
            const string sql = @"UPDATE dbo.[Notification]
                                 SET [isRead] = 1
                                 WHERE [notificationId] = @notificationId AND [toUserId] = @teacherId";

            using (var conn = new SqlConnection(ConnectionString))
            {
                conn.Open();
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@notificationId", notificationId);
                    cmd.Parameters.AddWithValue("@teacherId", teacherId);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        private int ExecuteCount(SqlConnection conn, string sql, string userId)
        {
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@u", userId);
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        #endregion

        #region Helper Methods

        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        private void UpdateTabStyles(string activeTab)
        {
            btnTabAll.CssClass = "tc-notifications-tab" + (activeTab == "All" ? " active" : "");
            btnTabUnread.CssClass = "tc-notifications-tab" + (activeTab == "Unread" ? " active" : "");
            btnTabRead.CssClass = "tc-notifications-tab" + (activeTab == "Read" ? " active" : "");
        }

        /// <summary>
        /// Returns the localized text based on current language preference.
        /// Falls back to English if BM is unavailable.
        /// </summary>
        private string GetLocalizedText(SqlDataReader reader, string enColumn, string bmColumn)
        {
            if (CurrentLanguage == "BM")
                return reader[bmColumn]?.ToString() ?? reader[enColumn]?.ToString() ?? "";

            return reader[enColumn]?.ToString() ?? "";
        }

        #endregion
    }
}
