using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace ScienceBuddy.Teacher
{
    public partial class liveClass : Page
    {
        #region Properties

        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected string CurrentLanguage
        {
            get
            {
                string lang = Session["preferredLanguage"] as string;
                return string.IsNullOrEmpty(lang) ? "EN" : lang;
            }
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

            var master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                LoadLiveRoom();
            }
        }

        #endregion

        #region Event Handlers

        protected void btnEndLive_Click(object sender, EventArgs e)
        {
            string sessionId = hidLiveSessionId.Value;
            string userId = Session["userId"]?.ToString() ?? "";
            string teacherId = GetTeacherId(userId);

            if (!string.IsNullOrEmpty(sessionId) && !string.IsNullOrEmpty(teacherId))
            {
                EndLiveSession(sessionId, teacherId);
            }

            Response.Redirect("~/Teacher/liveSession.aspx?summary=" + Server.UrlEncode(sessionId), false);
            Context.ApplicationInstance.CompleteRequest();
        }

        #endregion

        #region Data Loading

        /// <summary>
        /// Loads the live room details for the session specified in the query string.
        /// Verifies that the session belongs to the current teacher and is currently ongoing.
        /// </summary>
        private void LoadLiveRoom()
        {
            string sessionId = (Request.QueryString["id"] ?? "").Trim();
            if (string.IsNullOrEmpty(sessionId)) { ShowAccessDenied(); return; }

            string userId = Session["userId"].ToString();
            string teacherId = GetTeacherId(userId);
            if (string.IsNullOrEmpty(teacherId)) { ShowAccessDenied(); return; }

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    using (var cmd = new SqlCommand(
                        @"SELECT [sessionId], [sessionTitle], [meetingLink], [status]
                          FROM dbo.[LiveConsultationSession]
                          WHERE [sessionId]=@id AND [teacherId]=@t AND [status]='Ongoing'", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", sessionId);
                        cmd.Parameters.AddWithValue("@t", teacherId);

                        using (var reader = cmd.ExecuteReader())
                        {
                            if (!reader.Read())
                            {
                                ShowAccessDenied();
                                return;
                            }

                            string sessionTitle = reader["sessionTitle"]?.ToString() ?? "Live Class";
                            string meetingLink = reader["meetingLink"]?.ToString() ?? "";

                            // Extract room name from the Jitsi meeting URL
                            string roomName = meetingLink;
                            if (meetingLink.StartsWith("https://meet.jit.si/"))
                                roomName = meetingLink.Substring("https://meet.jit.si/".Length);

                            string teacherName = GetTeacherName(teacherId);

                            litLiveRoomTitle.Text = HttpUtility.HtmlEncode(sessionTitle);
                            hidLiveRoomName.Value = roomName;
                            hidLiveDisplayName.Value = HttpUtility.HtmlEncode(teacherName);
                            hidLiveSessionId.Value = sessionId;

                            pnlLiveRoom.Visible = true;
                            pnlDenied.Visible = false;
                        }
                    }
                }
            }
            catch
            {
                ShowAccessDenied();
            }
        }

        #endregion

        #region Database Operations

        /// <summary>
        /// Marks a live session as completed and records the end time.
        /// </summary>
        private void EndLiveSession(string sessionId, string teacherId)
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    using (var cmd = new SqlCommand(
                        @"UPDATE dbo.[LiveConsultationSession]
                          SET [endDateTime]=@endTime, [status]='Completed'
                          WHERE [sessionId]=@id AND [teacherId]=@t AND [status]='Ongoing'", conn))
                    {
                        cmd.Parameters.AddWithValue("@endTime", DateTime.Now);
                        cmd.Parameters.AddWithValue("@id", sessionId);
                        cmd.Parameters.AddWithValue("@t", teacherId);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch { }
        }

        /// <summary>
        /// Retrieves the teacherId for a certified teacher by their userId.
        /// </summary>
        private string GetTeacherId(string userId)
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    using (var cmd = new SqlCommand(
                        "SELECT [teacherId] FROM dbo.[Teacher] WHERE [userId]=@u AND [status]='Certified'", conn))
                    {
                        cmd.Parameters.AddWithValue("@u", userId);
                        return cmd.ExecuteScalar()?.ToString() ?? "";
                    }
                }
            }
            catch { return ""; }
        }

        /// <summary>
        /// Retrieves the teacher's display name for the Jitsi room.
        /// </summary>
        private string GetTeacherName(string teacherId)
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    using (var cmd = new SqlCommand(
                        "SELECT [name] FROM dbo.[Teacher] WHERE [teacherId]=@t", conn))
                    {
                        cmd.Parameters.AddWithValue("@t", teacherId);
                        return cmd.ExecuteScalar()?.ToString() ?? "Teacher";
                    }
                }
            }
            catch { return "Teacher"; }
        }

        #endregion

        #region Helper Methods

        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        private void ShowAccessDenied()
        {
            pnlDenied.Visible = true;
            pnlLiveRoom.Visible = false;
        }

        #endregion
    }
}
