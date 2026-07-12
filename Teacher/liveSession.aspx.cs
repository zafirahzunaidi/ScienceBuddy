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
        private string ActiveTab { get { return ViewState["Tab"] as string ?? "Upcoming"; } set { ViewState["Tab"] = value; } }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"]?.ToString() != "Teacher")
            { Response.Redirect("~/Login.aspx", false); Context.ApplicationInstance.CompleteRequest(); return; }
            var master = (ScienceBuddy.SiteMaster)Master; master.LayoutMode = "Sidebar";
            if (!IsPostBack) { btnSchedule.Text = T("Schedule", "Jadualkan"); btnStartLive.Text = T("Start Live", "Mulakan Langsung"); btnTabUpcoming.Text = T("Upcoming", "Akan Datang"); btnTabHistory.Text = T("History", "Sejarah"); LoadPage(); }
        }

        private void LoadPage()
        {
            string teacherId = GetTeacherId();
            if (string.IsNullOrEmpty(teacherId)) return;
            LoadSubtopics();
            LoadStats(teacherId);
            LoadSessions(teacherId);
        }

        private string GetTeacherId()
        {
            using (var conn = new SqlConnection(ConnStr))
            { conn.Open(); using (var cmd = new SqlCommand("SELECT [teacherId] FROM dbo.[Teacher] WHERE [userId]=@u AND [status]='Certified'", conn)) { cmd.Parameters.AddWithValue("@u", Session["userId"].ToString()); return cmd.ExecuteScalar()?.ToString(); } }
        }

        private void LoadSubtopics()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open(); ddlSubtopic.Items.Clear(); ddlInstantSubtopic.Items.Clear();
                ddlSubtopic.Items.Add(new ListItem(T("— Select —", "— Pilih —"), ""));
                ddlInstantSubtopic.Items.Add(new ListItem(T("— Select —", "— Pilih —"), ""));
                using (var cmd = new SqlCommand("SELECT st.[subtopicId],st.[subtopicTitleEN],u.[unitNameEN] FROM dbo.[Subtopic] st INNER JOIN dbo.[Unit] u ON u.[unitId]=st.[unitId] ORDER BY u.[levelId],u.[orderNo],st.[orderNo]", conn))
                using (var r = cmd.ExecuteReader()) while (r.Read())
                {
                    var item = new ListItem(r["unitNameEN"] + " > " + r["subtopicTitleEN"], r["subtopicId"].ToString());
                    ddlSubtopic.Items.Add(item);
                    ddlInstantSubtopic.Items.Add(new ListItem(item.Text, item.Value));
                }
            }
        }

        private void LoadStats(string teacherId)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                litUpcoming.Text = Cnt(conn, "SELECT COUNT(*) FROM dbo.[LiveConsultationSession] WHERE [teacherId]=@t AND [startDateTime]>GETDATE()", teacherId);
                litCompleted.Text = Cnt(conn, "SELECT COUNT(*) FROM dbo.[LiveConsultationSession] WHERE [teacherId]=@t AND [endDateTime]<GETDATE()", teacherId);
                litCancelled.Text = Cnt(conn, "SELECT COUNT(*) FROM dbo.[LiveConsultationSession] WHERE [teacherId]=@t AND [status]='Cancelled'", teacherId);
                litStudentsJoined.Text = Cnt(conn, "SELECT COUNT(DISTINCT lsp.[studentId]) FROM dbo.[LiveSessionParticipant] lsp INNER JOIN dbo.[LiveConsultationSession] lcs ON lcs.[sessionId]=lsp.[sessionId] WHERE lcs.[teacherId]=@t", teacherId);
            }
        }

        private string Cnt(SqlConnection conn, string sql, string tid)
        { using (var cmd = new SqlCommand(sql, conn)) { cmd.Parameters.AddWithValue("@t", tid); return Convert.ToInt32(cmd.ExecuteScalar()).ToString(); } }

        private void LoadSessions(string teacherId)
        {
            bool upcoming = ActiveTab == "Upcoming";
            btnTabUpcoming.CssClass = "ls-tab" + (upcoming ? " active" : "");
            btnTabHistory.CssClass = "ls-tab" + (!upcoming ? " active" : "");

            string sql = @"SELECT lcs.[sessionId],lcs.[sessionTitle],lcs.[startDateTime],lcs.[endDateTime],lcs.[status],
                ISNULL(st.[subtopicTitleEN],'') AS topic,
                (SELECT COUNT(*) FROM dbo.[LiveSessionParticipant] WHERE [sessionId]=lcs.[sessionId]) AS students
                FROM dbo.[LiveConsultationSession] lcs
                LEFT JOIN dbo.[Subtopic] st ON st.[subtopicId]=lcs.[subtopicId]
                WHERE lcs.[teacherId]=@t" + (upcoming ? " AND lcs.[startDateTime]>GETDATE() AND ISNULL(lcs.[status],'Scheduled')<>'Cancelled'" : " AND (lcs.[endDateTime]<GETDATE() OR lcs.[status]='Cancelled')") + " ORDER BY lcs.[startDateTime]" + (upcoming ? " ASC" : " DESC");

            var list = new List<object>();
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@t", teacherId);
                    using (var r = cmd.ExecuteReader()) while (r.Read())
                    {
                        DateTime start = r["startDateTime"] != DBNull.Value ? Convert.ToDateTime(r["startDateTime"]) : DateTime.Now;
                        DateTime end = r["endDateTime"] != DBNull.Value ? Convert.ToDateTime(r["endDateTime"]) : start;
                        int mins = (int)(end - start).TotalMinutes;
                        string status = r["status"]?.ToString() ?? "Scheduled";
                        string badgeCss, badgeLabel;
                        if (status.Equals("Live", StringComparison.OrdinalIgnoreCase)) { badgeCss = "ls-badge-live"; badgeLabel = "🔴 " + T("LIVE NOW", "LANGSUNG"); }
                        else if (upcoming) { badgeCss = "ls-badge-upcoming"; badgeLabel = T("Upcoming", "Akan Datang"); }
                        else if (status.Equals("Cancelled", StringComparison.OrdinalIgnoreCase)) { badgeCss = "ls-badge-cancelled"; badgeLabel = T("Cancelled", "Dibatalkan"); }
                        else { badgeCss = "ls-badge-completed"; badgeLabel = T("Completed", "Selesai"); }
                        list.Add(new { sessionId = r["sessionId"].ToString(), title = r["sessionTitle"]?.ToString() ?? "", day = start.Day.ToString(), month = start.ToString("MMM").ToUpper(), timeRange = start.ToString("h:mm tt") + " – " + end.ToString("h:mm tt"), topic = r["topic"]?.ToString() ?? "", students = Convert.ToInt32(r["students"]), duration = !upcoming ? mins + " min" : "", badgeCss, badgeLabel, isUpcoming = upcoming, rawStart = start.ToString("yyyy-MM-dd HH:mm"), rawEnd = end.ToString("yyyy-MM-dd HH:mm") });
                    }
                }
            }

            if (list.Count > 0) { pnlList.Visible = true; pnlEmpty.Visible = false; rptSessions.DataSource = list; rptSessions.DataBind(); }
            else
            {
                pnlList.Visible = false; pnlEmpty.Visible = true;
                litEmptyTitle.Text = upcoming ? T("No Upcoming Live Sessions", "Tiada Kelas Langsung Akan Datang") : T("No completed sessions yet.", "Tiada sesi selesai lagi.");
                litEmptySub.Text = upcoming ? T("You haven't scheduled any live classes yet.", "Anda belum menjadualkan kelas langsung.") : T("Completed live classes will appear here.", "Kelas langsung yang selesai akan terpapar di sini.");
            }
        }

        protected void btnTab_Click(object sender, EventArgs e) { ActiveTab = ((Button)sender).CommandArgument; LoadPage(); }

        protected void rptSessions_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string[] args = e.CommandArgument.ToString().Split('|');
            if (e.CommandName == "Reschedule" && args.Length >= 4)
            {
                hidRescId.Value = args[0];
                litRescTitle.Text = HttpUtility.HtmlEncode(args[3]);
                DateTime st = DateTime.Parse(args[1]), en = DateTime.Parse(args[2]);
                litRescCurrent.Text = T("Current: ", "Semasa: ") + st.ToString("d MMM yyyy, h:mm tt") + " – " + en.ToString("h:mm tt");
                txtRescDate.Text = st.ToString("yyyy-MM-dd");
                txtRescStart.Text = st.ToString("HH:mm");
                txtRescEnd.Text = en.ToString("HH:mm");
                btnSaveReschedule.Text = T("Save Changes", "Simpan Perubahan");
                hidShowRescModal.Value = "1";
            }
            else if (e.CommandName == "Cancel" && args.Length >= 3)
            {
                hidCancelId.Value = args[0];
                litCancelTitle.Text = HttpUtility.HtmlEncode(args[1]);
                litCancelTime.Text = args[2];
                btnConfirmCancel.Text = T("Cancel Session", "Batalkan Sesi");
                hidShowCancelModal.Value = "1";
            }
            LoadPage();
        }

        protected void btnSaveReschedule_Click(object sender, EventArgs e)
        {
            string sid = hidRescId.Value, date = txtRescDate.Text, start = txtRescStart.Text, end = txtRescEnd.Text;
            if (string.IsNullOrEmpty(date) || string.IsNullOrEmpty(start) || string.IsNullOrEmpty(end))
            { pnlRescError.Visible = true; litRescError.Text = T("Please fill all fields.", "Sila lengkapkan semua medan."); hidShowRescModal.Value = "1"; LoadPage(); return; }
            DateTime startDt, endDt;
            if (!DateTime.TryParse(date + " " + start, out startDt) || !DateTime.TryParse(date + " " + end, out endDt))
            { pnlRescError.Visible = true; litRescError.Text = T("Invalid date/time.", "Tarikh/masa tidak sah."); hidShowRescModal.Value = "1"; LoadPage(); return; }
            if (endDt <= startDt) { pnlRescError.Visible = true; litRescError.Text = T("End time must be after start time.", "Masa tamat mesti selepas masa mula."); hidShowRescModal.Value = "1"; LoadPage(); return; }

            string tid = GetTeacherId();
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("UPDATE dbo.[LiveConsultationSession] SET [startDateTime]=@s,[endDateTime]=@e WHERE [sessionId]=@id AND [teacherId]=@t", conn))
                { cmd.Parameters.AddWithValue("@s", startDt); cmd.Parameters.AddWithValue("@e", endDt); cmd.Parameters.AddWithValue("@id", sid); cmd.Parameters.AddWithValue("@t", tid); cmd.ExecuteNonQuery(); }
            }
            hidToast.Value = T("Live session rescheduled successfully.", "Sesi langsung berjaya dijadual semula.");
            LoadPage();
        }

        protected void btnConfirmCancel_Click(object sender, EventArgs e)
        {
            string sid = hidCancelId.Value; string tid = GetTeacherId();
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("UPDATE dbo.[LiveConsultationSession] SET [status]='Cancelled' WHERE [sessionId]=@s AND [teacherId]=@t", conn))
                { cmd.Parameters.AddWithValue("@s", sid); cmd.Parameters.AddWithValue("@t", tid); cmd.ExecuteNonQuery(); }
            }
            hidToast.Value = T("Live session cancelled.", "Sesi langsung dibatalkan.");
            LoadPage();
        }

        protected void btnStartLive_Click(object sender, EventArgs e)
        {
            string title = txtInstantTitle.Text.Trim();
            string sub = ddlInstantSubtopic.SelectedValue;
            string platform = ddlInstantPlatform.SelectedValue;
            if (string.IsNullOrEmpty(title) || string.IsNullOrEmpty(sub) || string.IsNullOrEmpty(platform))
            { pnlInstantError.Visible = true; litInstantError.Text = T("Please fill all required fields.", "Sila lengkapkan semua medan."); hidShowInstantModal.Value = "1"; LoadPage(); return; }

            string tid = GetTeacherId(); if (string.IsNullOrEmpty(tid)) return;
            string unitId = null;
            string newId = null;  // ← moved up here
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [unitId] FROM dbo.[Subtopic] WHERE [subtopicId]=@s", conn))
                { cmd.Parameters.AddWithValue("@s", sub); unitId = cmd.ExecuteScalar()?.ToString(); }

                using (var cmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING([sessionId],5,LEN([sessionId])-4) AS INT)),0) FROM dbo.[LiveConsultationSession] WHERE [sessionId] LIKE 'LIVE%'", conn))
                { newId = "LIVE" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3"); }

                DateTime now = DateTime.Now;
                using (var cmd = new SqlCommand("INSERT INTO dbo.[LiveConsultationSession]([sessionId],[teacherId],[unitId],[subtopicId],[sessionTitle],[sessionDescription],[meetingLink],[startDateTime],[endDateTime],[status]) VALUES(@id,@t,@u,@s,@title,@desc,@link,@st,@en,'Live')", conn))
                {
                    cmd.Parameters.AddWithValue("@id", newId);
                    cmd.Parameters.AddWithValue("@t", tid);
                    cmd.Parameters.AddWithValue("@u", (object)unitId ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@s", sub);
                    cmd.Parameters.AddWithValue("@title", title);
                    cmd.Parameters.AddWithValue("@desc", (object)txtInstantDesc.Text.Trim() ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@link", platform);
                    cmd.Parameters.AddWithValue("@st", now);
                    cmd.Parameters.AddWithValue("@en", now.AddHours(1));
                    cmd.ExecuteNonQuery();
                }
            
            }

            string teacherName = GetTeacherName(tid);
            string roomName = "ScienceBuddy-" + newId;

            hidLiveRoomName.Value = roomName;
            hidLiveDisplayName.Value = HttpUtility.HtmlEncode(teacherName);
            litLiveRoomTitle.Text = HttpUtility.HtmlEncode(title);

            pnlList.Visible = false;
            pnlEmpty.Visible = false;
            pnlLiveRoom.Visible = true;

            hidToast.Value = T("Instant live session started successfully!", "Sesi langsung segera berjaya dimulakan!");
            txtInstantTitle.Text = ""; txtInstantDesc.Text = "";
            return; // pnlLiveRoom stays visible

        }

        private string GetTeacherName(string teacherId)
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

        protected void btnEndLive_Click(object sender, EventArgs e)
        {
            pnlLiveRoom.Visible = false;
            LoadPage();
        }

        protected void btnSchedule_Click(object sender, EventArgs e)
        {
            string title = txtTitle.Text.Trim(), date = txtDate.Text, start = txtStart.Text, end = txtEnd.Text, link = txtLink.Text.Trim(), sub = ddlSubtopic.SelectedValue;
            if (string.IsNullOrEmpty(title) || string.IsNullOrEmpty(date) || string.IsNullOrEmpty(start) || string.IsNullOrEmpty(end) || string.IsNullOrEmpty(sub) || string.IsNullOrEmpty(link))
            { ShowError(T("Please fill in all required fields.", "Sila lengkapkan semua medan.")); return; }
            DateTime startDt, endDt;
            if (!DateTime.TryParse(date + " " + start, out startDt) || !DateTime.TryParse(date + " " + end, out endDt)) { ShowError(T("Invalid date/time.", "Tarikh/masa tidak sah.")); return; }
            if (endDt <= startDt) { ShowError(T("End time must be after start time.", "Masa tamat mesti selepas masa mula.")); return; }

            string tid = GetTeacherId(); 
            if (string.IsNullOrEmpty(tid)) 
                return;
            string unitId = null;
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [unitId] FROM dbo.[Subtopic] WHERE [subtopicId]=@s", conn)) { cmd.Parameters.AddWithValue("@s", sub); unitId = cmd.ExecuteScalar()?.ToString(); }
                string newId;
                using (var cmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING([sessionId],2,LEN([sessionId])-1) AS INT)),0) FROM dbo.[LiveConsultationSession]", conn))
                { newId = "S" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3"); }
                using (var cmd = new SqlCommand("INSERT INTO dbo.[LiveConsultationSession]([sessionId],[teacherId],[unitId],[subtopicId],[sessionTitle],[sessionDescription],[meetingLink],[startDateTime],[endDateTime],[status]) VALUES(@id,@t,@u,@s,@title,@desc,@link,@st,@en,'Scheduled')", conn))
                {
                    cmd.Parameters.AddWithValue("@id", newId); cmd.Parameters.AddWithValue("@t", tid);
                    cmd.Parameters.AddWithValue("@u", (object)unitId ?? DBNull.Value); cmd.Parameters.AddWithValue("@s", sub);
                    cmd.Parameters.AddWithValue("@title", title); cmd.Parameters.AddWithValue("@desc", (object)txtDesc.Text.Trim() ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@link", link); cmd.Parameters.AddWithValue("@st", startDt); cmd.Parameters.AddWithValue("@en", endDt);
                    cmd.ExecuteNonQuery();
                }
            }
            hidToast.Value = T("Live class scheduled successfully!", "Kelas langsung berjaya dijadualkan!");
            txtTitle.Text = ""; txtDate.Text = ""; txtStart.Text = ""; txtEnd.Text = ""; txtLink.Text = ""; txtDesc.Text = "";
            LoadPage();
        }

        private void ShowError(string msg) { pnlError.Visible = true; litError.Text = HttpUtility.HtmlEncode(msg); hidShowModal.Value = "1"; }

        protected void hidShowInstantModal_ValueChanged(object sender, EventArgs e)
        {

        }
    }
}
