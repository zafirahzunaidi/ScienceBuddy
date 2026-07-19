using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace ScienceBuddy.Teacher
{
    public partial class liveClass : Page
    {
        protected string CurrentLanguage { get { string l = Session["preferredLanguage"] as string; return string.IsNullOrEmpty(l) ? "EN" : l; } }
        protected string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"]?.ToString() != "Teacher")
            { Response.Redirect("~/Login.aspx", false); Context.ApplicationInstance.CompleteRequest(); return; }

            var master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                LoadLiveRoom();
            }
        }

        private void LoadLiveRoom()
        {
            string sessionId = (Request.QueryString["id"] ?? "").Trim();
            if (string.IsNullOrEmpty(sessionId)) { ShowDenied(); return; }

            string userId = Session["userId"].ToString();
            string teacherId = GetTeacherId(userId);
            if (string.IsNullOrEmpty(teacherId)) { ShowDenied(); return; }

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand(
                        @"SELECT [sessionId],[sessionTitle],[meetingLink],[status]
                          FROM dbo.[LiveConsultationSession]
                          WHERE [sessionId]=@id AND [teacherId]=@t AND [status]='Ongoing'", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", sessionId);
                        cmd.Parameters.AddWithValue("@t", teacherId);
                        using (var r = cmd.ExecuteReader())
                        {
                            if (r.Read())
                            {
                                string title = r["sessionTitle"]?.ToString() ?? "Live Class";
                                string meetingLink = r["meetingLink"]?.ToString() ?? "";

                                string roomName = meetingLink;
                                if (meetingLink.StartsWith("https://meet.jit.si/"))
                                    roomName = meetingLink.Substring("https://meet.jit.si/".Length);

                                string teacherName = GetTeacherName(teacherId);

                                litLiveRoomTitle.Text = HttpUtility.HtmlEncode(title);
                                hidLiveRoomName.Value = roomName;
                                hidLiveDisplayName.Value = HttpUtility.HtmlEncode(teacherName);
                                hidLiveSessionId.Value = sessionId;

                                pnlLiveRoom.Visible = true;
                                pnlDenied.Visible = false;
                            }
                            else
                            {
                                ShowDenied();
                            }
                        }
                    }
                }
            }
            catch { ShowDenied(); }
        }

        private void ShowDenied()
        {
            pnlDenied.Visible = true;
            pnlLiveRoom.Visible = false;
        }

        protected void btnEndLive_Click(object sender, EventArgs e)
        {
            string sessionId = hidLiveSessionId.Value;
            string userId = Session["userId"]?.ToString() ?? "";
            string teacherId = GetTeacherId(userId);

            if (!string.IsNullOrEmpty(sessionId) && !string.IsNullOrEmpty(teacherId))
            {
                try
                {
                    using (var conn = new SqlConnection(ConnStr))
                    {
                        conn.Open();
                        using (var cmd = new SqlCommand(
                            @"UPDATE dbo.[LiveConsultationSession]
                              SET [endDateTime]=@en, [status]='Completed'
                              WHERE [sessionId]=@id AND [teacherId]=@t AND [status]='Ongoing'", conn))
                        {
                            cmd.Parameters.AddWithValue("@en", DateTime.Now);
                            cmd.Parameters.AddWithValue("@id", sessionId);
                            cmd.Parameters.AddWithValue("@t", teacherId);
                            cmd.ExecuteNonQuery();
                        }
                    }
                }
                catch { }
            }

            Response.Redirect("~/Teacher/liveSession.aspx?summary=" + Server.UrlEncode(sessionId), false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private string GetTeacherId(string userId)
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("SELECT [teacherId] FROM dbo.[Teacher] WHERE [userId]=@u AND [status]='Certified'", conn))
                    {
                        cmd.Parameters.AddWithValue("@u", userId);
                        return cmd.ExecuteScalar()?.ToString() ?? "";
                    }
                }
            }
            catch { return ""; }
        }

        private string GetTeacherName(string teacherId)
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("SELECT [name] FROM dbo.[Teacher] WHERE [teacherId]=@t", conn))
                    {
                        cmd.Parameters.AddWithValue("@t", teacherId);
                        return cmd.ExecuteScalar()?.ToString() ?? "Teacher";
                    }
                }
            }
            catch { return "Teacher"; }
        }
    }
}
