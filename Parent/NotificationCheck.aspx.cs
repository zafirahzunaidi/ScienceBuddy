using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace ScienceBuddy.Parent
{
    /// <summary>
    /// Lightweight endpoint polled by JavaScript to check for new notifications.
    /// Returns JSON: {"count":3,"latest":"New message from teacher"}
    /// Used by the real-time notification toast on Parent pages.
    /// </summary>
    public partial class NotificationCheck : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Clear();
            Response.ContentType = "application/json";

            // Authorization check
            if (Session["userId"] == null || Session["role"] == null ||
                Session["role"].ToString() != "Parent")
            {
                Response.Write("{\"count\":0,\"latest\":\"\"}");
                Response.End();
                return;
            }

            string userId = Session["userId"].ToString();
            int unreadCount = 0;
            string latestTitle = "";

            try
            {
                string connectionString = ConfigurationManager
                    .ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

                using (var connection = new SqlConnection(connectionString))
                {
                    connection.Open();

                    // Get unread notification count
                    using (var command = new SqlCommand(
                        "SELECT COUNT(*) FROM dbo.Notification WHERE toUserId = @uid AND isRead = 0",
                        connection))
                    {
                        command.Parameters.AddWithValue("@uid", userId);
                        unreadCount = (int)command.ExecuteScalar();
                    }

                    // Get the title of the most recent unread notification
                    if (unreadCount > 0)
                    {
                        using (var command = new SqlCommand(
                            @"SELECT TOP 1 titleEN FROM dbo.Notification 
                            WHERE toUserId = @uid AND isRead = 0 
                            ORDER BY createdAt DESC", connection))
                        {
                            command.Parameters.AddWithValue("@uid", userId);
                            object result = command.ExecuteScalar();
                            if (result != null && result != DBNull.Value)
                                latestTitle = result.ToString();
                        }
                    }
                }
            }
            catch { }

            // Escape quotes in title for safe JSON
            latestTitle = latestTitle.Replace("\\", "\\\\").Replace("\"", "\\\"");

            Response.Write(string.Format(
                "{{\"count\":{0},\"latest\":\"{1}\"}}", unreadCount, latestTitle));
            Response.End();
        }
    }
}
