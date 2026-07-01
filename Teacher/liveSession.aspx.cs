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
    public partial class liveSession : Page
    {
        protected string CurrentLanguage { get { string l = Session["preferredLanguage"] as string; return string.IsNullOrEmpty(l) ? "EN" : l; } }
        protected string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        private DateTime CalMonth
        {
            get
            {
                if (!string.IsNullOrEmpty(hidCalMonth.Value)) return DateTime.Parse(hidCalMonth.Value);
                return new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
            }
            set { hidCalMonth.Value = value.ToString("yyyy-MM-01"); }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"]?.ToString() != "Teacher")
            { Response.Redirect("~/Login.aspx", false); Context.ApplicationInstance.CompleteRequest(); return; }
            var master = (ScienceBuddy.SiteMaster)Master; master.LayoutMode = "Sidebar";
            if (!IsPostBack) { btnSchedule.Text = T("Schedule", "Jadualkan"); LoadPage(); }
        }

        private void LoadPage()
        {
            string userId = Session["userId"].ToString();
            string teacherId = GetTeacherId(userId);
            if (string.IsNullOrEmpty(teacherId)) return;

            LoadSubtopics();
            var sessionDates = LoadSessions(teacherId);
            RenderCalendar(sessionDates);
        }

        private string GetTeacherId(string userId)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [teacherId] FROM dbo.[Teacher] WHERE [userId]=@u AND [status]='Certified'", conn))
                { cmd.Parameters.AddWithValue("@u", userId); return cmd.ExecuteScalar()?.ToString(); }
            }
        }

        private void LoadSubtopics()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                ddlSubtopic.Items.Clear();
                ddlSubtopic.Items.Add(new ListItem(T("— Select —", "— Pilih —"), ""));
                using (var cmd = new SqlCommand("SELECT st.[subtopicId], st.[subtopicTitleEN], u.[unitNameEN] FROM dbo.[Subtopic] st INNER JOIN dbo.[Unit] u ON u.[unitId]=st.[unitId] ORDER BY u.[levelId],u.[orderNo],st.[orderNo]", conn))
                using (var r = cmd.ExecuteReader())
                    while (r.Read()) ddlSubtopic.Items.Add(new ListItem(r["unitNameEN"] + " > " + r["subtopicTitleEN"], r["subtopicId"].ToString()));
            }
        }

        private HashSet<int> LoadSessions(string teacherId)
        {
            var dates = new HashSet<int>();
            var month = CalMonth;
            var list = new List<object>();

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                const string sql = @"SELECT lcs.[sessionId],lcs.[sessionTitle],lcs.[startDateTime],lcs.[endDateTime],lcs.[status],
                    (SELECT COUNT(*) FROM dbo.[LiveSessionParticipant] WHERE [sessionId]=lcs.[sessionId]) AS pCount
                    FROM dbo.[LiveConsultationSession] lcs WHERE lcs.[teacherId]=@tid ORDER BY lcs.[startDateTime] DESC";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@tid", teacherId);
                    using (var r = cmd.ExecuteReader())
                        while (r.Read())
                        {
                            DateTime start = r["startDateTime"] != DBNull.Value ? Convert.ToDateTime(r["startDateTime"]) : DateTime.Now;
                            if (start.Year == month.Year && start.Month == month.Month) dates.Add(start.Day);
                            // Only show upcoming in panel
                            if (start >= DateTime.Now.AddHours(-2))
                            {
                                string status = r["status"]?.ToString() ?? "Scheduled";
                                string badgeCss = "ls-badge-upcoming"; string statusLabel = T("Upcoming", "Akan Datang");
                                if (status.Equals("Active", StringComparison.OrdinalIgnoreCase)) { badgeCss = "ls-badge-active"; statusLabel = T("Active", "Aktif"); }
                                else if (status.Equals("Completed", StringComparison.OrdinalIgnoreCase)) { badgeCss = "ls-badge-completed"; statusLabel = T("Completed", "Selesai"); }
                                list.Add(new { sessionId = r["sessionId"].ToString(), title = r["sessionTitle"]?.ToString() ?? "", dateStr = start.ToString("d MMM yyyy"), timeStr = start.ToString("h:mm tt"), participants = Convert.ToInt32(r["pCount"]), badgeCss, statusLabel });
                            }
                        }
                }
            }

            if (list.Count > 0) { pnlSessions.Visible = true; pnlEmpty.Visible = false; rptSessions.DataSource = list; rptSessions.DataBind(); }
            else { pnlSessions.Visible = false; pnlEmpty.Visible = true; }
            return dates;
        }

        private void RenderCalendar(HashSet<int> sessionDays)
        {
            var month = CalMonth;
            litMonth.Text = month.ToString("MMMM yyyy");
            int daysInMonth = DateTime.DaysInMonth(month.Year, month.Month);
            int startDow = (int)new DateTime(month.Year, month.Month, 1).DayOfWeek;
            var sb = new System.Text.StringBuilder();
            foreach (var h in new[] { "S", "M", "T", "W", "T", "F", "S" }) sb.Append("<span class='cal-h'>" + h + "</span>");
            for (int i = 0; i < startDow; i++) sb.Append("<span class='cal-d empty'>.</span>");
            for (int d = 1; d <= daysInMonth; d++)
            {
                string cls = "cal-d";
                if (d == DateTime.Now.Day && month.Month == DateTime.Now.Month && month.Year == DateTime.Now.Year) cls += " today";
                else if (sessionDays.Contains(d)) cls += " has-session";
                sb.Append("<span class='" + cls + "'>" + d + "</span>");
            }
            litCalendar.Text = sb.ToString();
        }

        protected void btnPrevMonth_Click(object sender, EventArgs e) { CalMonth = CalMonth.AddMonths(-1); LoadPage(); }
        protected void btnNextMonth_Click(object sender, EventArgs e) { CalMonth = CalMonth.AddMonths(1); LoadPage(); }

        protected void btnSchedule_Click(object sender, EventArgs e)
        {
            string title = txtTitle.Text.Trim(), date = txtDate.Text, start = txtStart.Text, end = txtEnd.Text, link = txtLink.Text.Trim(), subtopic = ddlSubtopic.SelectedValue;
            if (string.IsNullOrEmpty(title) || string.IsNullOrEmpty(date) || string.IsNullOrEmpty(start) || string.IsNullOrEmpty(end) || string.IsNullOrEmpty(subtopic) || string.IsNullOrEmpty(link))
            { ShowError(T("Please fill in all required fields.", "Sila lengkapkan semua medan yang diperlukan.")); return; }

            DateTime startDt, endDt;
            if (!DateTime.TryParse(date + " " + start, out startDt) || !DateTime.TryParse(date + " " + end, out endDt))
            { ShowError(T("Invalid date or time.", "Tarikh atau masa tidak sah.")); return; }
            if (endDt <= startDt) { ShowError(T("End time must be after start time.", "Masa tamat mesti selepas masa mula.")); return; }

            string userId = Session["userId"].ToString();
            string teacherId = GetTeacherId(userId);
            if (string.IsNullOrEmpty(teacherId)) return;

            // Get unitId from subtopic
            string unitId = null;
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [unitId] FROM dbo.[Subtopic] WHERE [subtopicId]=@s", conn))
                { cmd.Parameters.AddWithValue("@s", subtopic); unitId = cmd.ExecuteScalar()?.ToString(); }

                string newId;
                using (var cmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING([sessionId],2,LEN([sessionId])-1) AS INT)),0) FROM dbo.[LiveConsultationSession]", conn))
                { newId = "S" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3"); }

                using (var cmd = new SqlCommand(@"INSERT INTO dbo.[LiveConsultationSession]([sessionId],[teacherId],[unitId],[subtopicId],[sessionTitle],[sessionDescription],[meetingLink],[startDateTime],[endDateTime],[status])
                    VALUES(@id,@tid,@uid,@sid,@title,@desc,@link,@start,@end,'Scheduled')", conn))
                {
                    cmd.Parameters.AddWithValue("@id", newId);
                    cmd.Parameters.AddWithValue("@tid", teacherId);
                    cmd.Parameters.AddWithValue("@uid", (object)unitId ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@sid", subtopic);
                    cmd.Parameters.AddWithValue("@title", title);
                    cmd.Parameters.AddWithValue("@desc", (object)txtDesc.Text.Trim() ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@link", link);
                    cmd.Parameters.AddWithValue("@start", startDt);
                    cmd.Parameters.AddWithValue("@end", endDt);
                    cmd.ExecuteNonQuery();
                }
            }
            hidToast.Value = T("Live class scheduled successfully!", "Kelas langsung berjaya dijadualkan!");
            txtTitle.Text = ""; txtDate.Text = ""; txtStart.Text = ""; txtEnd.Text = ""; txtLink.Text = ""; txtDesc.Text = "";
            LoadPage();
        }

        protected void rptSessions_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Delete")
            {
                string sid = e.CommandArgument.ToString();
                string teacherId = GetTeacherId(Session["userId"].ToString());
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("DELETE FROM dbo.[LiveSessionParticipant] WHERE [sessionId]=@s", conn))
                    { cmd.Parameters.AddWithValue("@s", sid); cmd.ExecuteNonQuery(); }
                    using (var cmd = new SqlCommand("DELETE FROM dbo.[LiveConsultationSession] WHERE [sessionId]=@s AND [teacherId]=@t", conn))
                    { cmd.Parameters.AddWithValue("@s", sid); cmd.Parameters.AddWithValue("@t", teacherId); cmd.ExecuteNonQuery(); }
                }
                hidToast.Value = T("Session deleted.", "Sesi dipadam.");
                LoadPage();
            }
        }

        private void ShowError(string msg) { pnlError.Visible = true; litError.Text = HttpUtility.HtmlEncode(msg); hidShowModal.Value = "1"; }
    }
}
