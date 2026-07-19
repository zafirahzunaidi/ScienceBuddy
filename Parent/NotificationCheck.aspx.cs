using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace ScienceBuddy.Parent
{
    // Lightweight JSON endpoint polled by JS for real-time notification toasts
    public partial class NotificationCheck : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Clear();
            Response.ContentType = "application/json";

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
                string connStr = ConfigurationManager
                    .ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

                using (var conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    using (var cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM dbo.Notification WHERE toUserId = @uid AND isRead = 0",
                        conn))
                    {
                        cmd.Parameters.AddWithValue("@uid", userId);
                        unreadCount = (int)cmd.ExecuteScalar();
                    }

                    if (unreadCount > 0)
                    {
                        using (var cmd = new SqlCommand(
                            @"SELECT TOP 1 titleEN FROM dbo.Notification 
                            WHERE toUserId = @uid AND isRead = 0 
                            ORDER BY createdAt DESC", conn))
                        {
                            cmd.Parameters.AddWithValue("@uid", userId);
                            object result = cmd.ExecuteScalar();
                            if (result != null && result != DBNull.Value)
                                latestTitle = result.ToString();
                        }
                    }
                }
            }
            catch { }

            latestTitle = latestTitle.Replace("\\", "\\\\").Replace("\"", "\\\"");

            Response.Write(string.Format(
                "{{\"count\":{0},\"latest\":\"{1}\"}}", unreadCount, latestTitle));
            Response.End();
        }
    }
}
