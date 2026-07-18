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

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"]?.ToString() != "Teacher")
            { Response.Redirect("~/Login.aspx", false); Context.ApplicationInstance.CompleteRequest(); return; }

            // AJAX handler for subtopics by unit
            string handler = Request.QueryString["handler"] ?? "";
            if (handler == "subtopicsByUnit")
            { HandleSubtopicsByUnit(); return; }
            if (handler == "sessionSummary")
            { HandleSessionSummary(); return; }

            var master = (ScienceBuddy.SiteMaster)Master; master.LayoutMode = "Sidebar";
            if (!IsPostBack)
            {
                btnSchedule.Text = T("Schedule", "Jadualkan");
                btnStartLive.Text = T("Start Live", "Mulakan Langsung");
                hidLicenseStatus.Value = GetTeacherLicenseStatus();
                LoadPage();
                LoadSummaryIfRequested();
            }
        }

        private void LoadSummaryIfRequested()
        {
            string summaryId = (Request.QueryString["summary"] ?? "").Trim();
            if (string.IsNullOrEmpty(summaryId)) return;

            string teacherId = GetTeacherId();
            if (string.IsNullOrEmpty(teacherId)) return;

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // Verify this session belongs to the current teacher and is Completed
                    string title = "";
                    DateTime startTime = DateTime.MinValue, endTime = DateTime.MinValue;
                    using (var cmd = new SqlCommand(
                        @"SELECT [sessionTitle],[startDateTime],[endDateTime]
                          FROM dbo.[LiveConsultationSession]
                          WHERE [sessionId]=@id AND [teacherId]=@t AND [status]='Completed'", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", summaryId);
                        cmd.Parameters.AddWithValue("@t", teacherId);
                        using (var r = cmd.ExecuteReader())
                        {
                            if (!r.Read()) return; // Not found or not authorized
                            title = r["sessionTitle"]?.ToString() ?? "";
                            startTime = r["startDateTime"] != DBNull.Value ? Convert.ToDateTime(r["startDateTime"]) : DateTime.Now;
                            endTime = r["endDateTime"] != DBNull.Value ? Convert.ToDateTime(r["endDateTime"]) : DateTime.Now;
                        }
                    }

                    // Duration
                    TimeSpan duration = endTime - startTime;
                    string durationText;
                    int totalMinutes = (int)duration.TotalMinutes;
                    if (totalMinutes < 1) durationText = "< 1 min";
                    else if (totalMinutes < 60) durationText = totalMinutes + " min";
                    else
                    {
                        int h = (int)duration.TotalHours;
                        int m = duration.Minutes;
                        durationText = m > 0 ? h + " hr " + m + " min" : h + " hr";
                    }

                    // Participants
                    var participants = new List<object>();
                    using (var cmd = new SqlCommand(
                        @"SELECT DISTINCT s.[name], s.[nickname]
                          FROM dbo.[LiveSessionParticipant] p
                          LEFT JOIN dbo.[Student] s ON s.[studentId]=p.[studentId]
                          WHERE p.[sessionId]=@id
                          ORDER BY s.[name]", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", summaryId);
                        using (var r = cmd.ExecuteReader())
                        {
                            while (r.Read())
                            {
                                string name = r["name"]?.ToString() ?? r["nickname"]?.ToString() ?? "Student";
                                string initials = "";
                                var parts = name.Trim().Split(' ');
                                if (parts.Length >= 2) initials = (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
                                else if (name.Length > 0) initials = name[0].ToString().ToUpper();
                                participants.Add(new { name, initials });
                            }
                        }
                    }

                    // Bind
                    litSumTitle.Text = HttpUtility.HtmlEncode(title);
                    litSumStart.Text = startTime.ToString("h:mm tt");
                    litSumEnd.Text = endTime.ToString("h:mm tt");
                    litSumDuration.Text = durationText;
                    litSumStudents.Text = participants.Count.ToString();

                    if (participants.Count > 0)
                    {
                        pnlSumPartsList.Visible = true;
                        pnlSumNoParticipants.Visible = false;
                        rptSumParticipants.DataSource = participants;
                        rptSumParticipants.DataBind();
                    }
                    else
                    {
                        pnlSumPartsList.Visible = false;
                        pnlSumNoParticipants.Visible = true;
                    }

                    // pnlSummary already in DOM
                    hidShowSummary.Value = "1";
                }
            }
            catch { }
        }

        private void LoadSummaryForSession(string summaryId)
        {
            string teacherId = GetTeacherId();
            if (string.IsNullOrEmpty(teacherId) || string.IsNullOrEmpty(summaryId)) return;

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    string title = "";
                    DateTime startTime = DateTime.MinValue, endTime = DateTime.MinValue;
                    using (var cmd = new SqlCommand(
                        @"SELECT [sessionTitle],[startDateTime],[endDateTime]
                          FROM dbo.[LiveConsultationSession]
                          WHERE [sessionId]=@id AND [teacherId]=@t AND [status]='Completed'", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", summaryId);
                        cmd.Parameters.AddWithValue("@t", teacherId);
                        using (var r = cmd.ExecuteReader())
                        {
                            if (!r.Read()) return;
                            title = r["sessionTitle"]?.ToString() ?? "";
                            startTime = r["startDateTime"] != DBNull.Value ? Convert.ToDateTime(r["startDateTime"]) : DateTime.Now;
                            endTime = r["endDateTime"] != DBNull.Value ? Convert.ToDateTime(r["endDateTime"]) : DateTime.Now;
                        }
                    }

                    TimeSpan duration = endTime - startTime;
                    string durationText;
                    int totalMinutes = (int)duration.TotalMinutes;
                    if (totalMinutes < 1) durationText = "< 1 min";
                    else if (totalMinutes < 60) durationText = totalMinutes + " min";
                    else
                    {
                        int h = (int)duration.TotalHours;
                        int m = duration.Minutes;
                        durationText = m > 0 ? h + " hr " + m + " min" : h + " hr";
                    }

                    var participants = new List<object>();
                    using (var cmd = new SqlCommand(
                        @"SELECT DISTINCT s.[name], s.[nickname]
                          FROM dbo.[LiveSessionParticipant] p
                          LEFT JOIN dbo.[Student] s ON s.[studentId]=p.[studentId]
                          WHERE p.[sessionId]=@id
                          ORDER BY s.[name]", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", summaryId);
                        using (var r = cmd.ExecuteReader())
                        {
                            while (r.Read())
                            {
                                string name = r["name"]?.ToString() ?? r["nickname"]?.ToString() ?? "Student";
                                string initials = "";
                                var parts = name.Trim().Split(' ');
                                if (parts.Length >= 2) initials = (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
                                else if (name.Length > 0) initials = name[0].ToString().ToUpper();
                                participants.Add(new { name, initials });
                            }
                        }
                    }

                    litSumTitle.Text = HttpUtility.HtmlEncode(title);
                    litSumStart.Text = startTime.ToString("h:mm tt");
                    litSumEnd.Text = endTime.ToString("h:mm tt");
                    litSumDuration.Text = durationText;
                    litSumStudents.Text = participants.Count.ToString();

                    if (participants.Count > 0)
                    {
                        pnlSumPartsList.Visible = true;
                        pnlSumNoParticipants.Visible = false;
                        rptSumParticipants.DataSource = participants;
                        rptSumParticipants.DataBind();
                    }
                    else
                    {
                        pnlSumPartsList.Visible = false;
                        pnlSumNoParticipants.Visible = true;
                    }

                    // pnlSummary already in DOM
                    hidShowSummary.Value = "1";
                }
            }
            catch { }
        }

        private void HandleSubtopicsByUnit()
        {
            Response.Clear();
            Response.ContentType = "application/json";
            string unitId = (Request.QueryString["unitId"] ?? "").Trim();
            if (string.IsNullOrEmpty(unitId)) { Response.Write("[]"); Response.End(); return; }
            try
            {
                var sb = new System.Text.StringBuilder("[");
                bool first = true;
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("SELECT [subtopicId],[subtopicTitleEN] FROM dbo.[Subtopic] WHERE [unitId]=@u ORDER BY [orderNo]", conn))
                    {
                        cmd.Parameters.AddWithValue("@u", unitId);
                        using (var r = cmd.ExecuteReader())
                        {
                            while (r.Read())
                            {
                                if (!first) sb.Append(",");
                                first = false;
                                sb.Append("{\"id\":\"" + r["subtopicId"].ToString().Replace("\"", "\\\"") + "\",\"name\":\"" + (r["subtopicTitleEN"]?.ToString() ?? "").Replace("\"", "\\\"") + "\"}");
                            }
                        }
                    }
                }
                sb.Append("]");
                Response.Write(sb.ToString());
            }
            catch { Response.Write("[]"); }
            Response.End();
        }

        private string GetTeacherLicenseStatus()
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("SELECT [status] FROM dbo.[Teacher] WHERE [userId]=@u", conn))
                    {
                        cmd.Parameters.AddWithValue("@u", Session["userId"].ToString());
                        var val = cmd.ExecuteScalar();
                        return val != null && val != DBNull.Value ? val.ToString() : "";
                    }
                }
            }
            catch { return ""; }
        }

        private void LoadPage()
        {
            string teacherId = GetTeacherId();
            LoadSubtopics();
            if (!string.IsNullOrEmpty(teacherId))
            {
                // Auto-expire sessions past endDateTime that were never started
                ExpireOverdueSessions(teacherId);
                LoadStats(teacherId);
                LoadBothTabs(teacherId);
            }
            else
            {
                // Pending or no teacher record — show empty states for both tabs
                pnlListUpcoming.Visible = false;
                pnlUpcomingEmpty.Visible = true;
                pnlListHistory.Visible = false;
                pnlHistoryEmpty.Visible = true;
            }
        }

        private void ExpireOverdueSessions(string teacherId)
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand(
                        @"UPDATE dbo.[LiveConsultationSession]
                          SET [status]='Expired'
                          WHERE [teacherId]=@t AND [status]='Upcoming' AND [endDateTime]<GETDATE()", conn))
                    {
                        cmd.Parameters.AddWithValue("@t", teacherId);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch { }
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
                conn.Open();
                // Load Units for schedule modal and instant modal
                ddlUnit.Items.Clear();
                ddlUnit.Items.Add(new ListItem(T("— Select Unit —", "— Pilih Unit —"), ""));
                ddlInstantUnit.Items.Clear();
                ddlInstantUnit.Items.Add(new ListItem(T("— Select Unit —", "— Pilih Unit —"), ""));
                using (var cmd = new SqlCommand("SELECT u.[unitId],u.[unitNameEN],l.[levelNameEN] FROM dbo.[Unit] u INNER JOIN dbo.[Level] l ON l.[levelId]=u.[levelId] ORDER BY u.[levelId],u.[orderNo]", conn))
                using (var r = cmd.ExecuteReader()) while (r.Read())
                {
                    var item = new ListItem(r["levelNameEN"] + " - " + r["unitNameEN"], r["unitId"].ToString());
                    ddlUnit.Items.Add(item);
                    ddlInstantUnit.Items.Add(new ListItem(item.Text, item.Value));
                }

                // Load all subtopics for instant modal (initially disabled, loaded via JS)
                ddlSubtopic.Items.Clear(); ddlInstantSubtopic.Items.Clear();
                ddlSubtopic.Items.Add(new ListItem(T("— Select Unit First —", "— Pilih Unit Dahulu —"), ""));
                ddlInstantSubtopic.Items.Add(new ListItem(T("— Select Unit First —", "— Pilih Unit Dahulu —"), ""));
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

        private void LoadBothTabs(string teacherId)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Upcoming
                string sqlUp = @"SELECT lcs.[sessionId],lcs.[sessionTitle],lcs.[startDateTime],lcs.[endDateTime],lcs.[status],
                    ISNULL(st.[subtopicTitleEN],'') AS topic,
                    (SELECT COUNT(*) FROM dbo.[LiveSessionParticipant] WHERE [sessionId]=lcs.[sessionId]) AS students
                    FROM dbo.[LiveConsultationSession] lcs
                    LEFT JOIN dbo.[Subtopic] st ON st.[subtopicId]=lcs.[subtopicId]
                    WHERE lcs.[teacherId]=@t AND lcs.[status] IN ('Upcoming','Ongoing')
                    ORDER BY lcs.[startDateTime] ASC";

                var upList = new List<object>();
                using (var cmd = new SqlCommand(sqlUp, conn))
                {
                    cmd.Parameters.AddWithValue("@t", teacherId);
                    using (var r = cmd.ExecuteReader()) while (r.Read())
                    {
                        DateTime start = r["startDateTime"] != DBNull.Value ? Convert.ToDateTime(r["startDateTime"]) : DateTime.Now;
                        DateTime end = r["endDateTime"] != DBNull.Value ? Convert.ToDateTime(r["endDateTime"]) : start;
                        string status = r["status"]?.ToString() ?? "Upcoming";
                        string badgeCss, badgeLabel;
                        if (status.Equals("Ongoing", StringComparison.OrdinalIgnoreCase)) { badgeCss = "ls-badge-live"; badgeLabel = "?? " + T("LIVE NOW", "LANGSUNG"); }
                        else { badgeCss = "ls-badge-upcoming"; badgeLabel = T("Upcoming", "Akan Datang"); }
                        bool canStart = DateTime.Now >= start.AddMinutes(-15);
                        upList.Add(new { sessionId = r["sessionId"].ToString(), title = r["sessionTitle"]?.ToString() ?? "", day = start.Day.ToString(), month = start.ToString("MMM").ToUpper(), timeRange = start.ToString("h:mm tt") + " – " + end.ToString("h:mm tt"), topic = r["topic"]?.ToString() ?? "", students = Convert.ToInt32(r["students"]), duration = "", badgeCss, badgeLabel, rawStart = start.ToString("yyyy-MM-dd HH:mm"), rawEnd = end.ToString("yyyy-MM-dd HH:mm"), canStart });
                    }
                }
                if (upList.Count > 0) { pnlListUpcoming.Visible = true; pnlUpcomingEmpty.Visible = false; rptUpcoming.DataSource = upList; rptUpcoming.DataBind(); }
                else { pnlListUpcoming.Visible = false; pnlUpcomingEmpty.Visible = true; }

                // History
                string sqlHist = @"SELECT lcs.[sessionId],lcs.[sessionTitle],lcs.[startDateTime],lcs.[endDateTime],lcs.[status],
                    ISNULL(st.[subtopicTitleEN],'') AS topic,
                    (SELECT COUNT(*) FROM dbo.[LiveSessionParticipant] WHERE [sessionId]=lcs.[sessionId]) AS students
                    FROM dbo.[LiveConsultationSession] lcs
                    LEFT JOIN dbo.[Subtopic] st ON st.[subtopicId]=lcs.[subtopicId]
                    WHERE lcs.[teacherId]=@t AND lcs.[status] IN ('Completed','Cancelled','Expired')
                    ORDER BY lcs.[startDateTime] DESC";

                var histList = new List<object>();
                using (var cmd = new SqlCommand(sqlHist, conn))
                {
                    cmd.Parameters.AddWithValue("@t", teacherId);
                    using (var r = cmd.ExecuteReader()) while (r.Read())
                    {
                        DateTime start = r["startDateTime"] != DBNull.Value ? Convert.ToDateTime(r["startDateTime"]) : DateTime.Now;
                        DateTime end = r["endDateTime"] != DBNull.Value ? Convert.ToDateTime(r["endDateTime"]) : start;
                        int mins = (int)(end - start).TotalMinutes;
                        string status = r["status"]?.ToString() ?? "Completed";
                        string badgeCss, badgeLabel;
                        if (status.Equals("Cancelled", StringComparison.OrdinalIgnoreCase)) { badgeCss = "ls-badge-cancelled"; badgeLabel = T("Cancelled", "Dibatalkan"); }
                        else if (status.Equals("Expired", StringComparison.OrdinalIgnoreCase)) { badgeCss = "ls-badge-expired"; badgeLabel = T("Expired", "Tamat Tempoh"); }
                        else { badgeCss = "ls-badge-completed"; badgeLabel = T("Completed", "Selesai"); }
                        bool isCompleted = status.Equals("Completed", StringComparison.OrdinalIgnoreCase);
                        histList.Add(new { sessionId = r["sessionId"].ToString(), title = r["sessionTitle"]?.ToString() ?? "", day = start.Day.ToString(), month = start.ToString("MMM").ToUpper(), timeRange = start.ToString("h:mm tt") + " – " + end.ToString("h:mm tt"), topic = r["topic"]?.ToString() ?? "", students = Convert.ToInt32(r["students"]), duration = mins + " min", badgeCss, badgeLabel, isCompleted });
                    }
                }
                if (histList.Count > 0) { pnlListHistory.Visible = true; pnlHistoryEmpty.Visible = false; rptHistory.DataSource = histList; rptHistory.DataBind(); }
                else { pnlListHistory.Visible = false; pnlHistoryEmpty.Visible = true; }
            }
        }

        protected void rptSessions_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string[] args = e.CommandArgument.ToString().Split('|');
            if (e.CommandName == "StartSession" && args.Length >= 1)
            {
                string sessionId = args[0];
                string tid = GetTeacherId();
                if (!string.IsNullOrEmpty(tid))
                {
                    using (var conn = new SqlConnection(ConnStr))
                    {
                        conn.Open();
                        using (var cmd = new SqlCommand(
                            @"UPDATE dbo.[LiveConsultationSession]
                              SET [status]='Ongoing', [startDateTime]=@st
                              WHERE [sessionId]=@id AND [teacherId]=@t AND [status]='Upcoming'", conn))
                        {
                            cmd.Parameters.AddWithValue("@st", DateTime.Now);
                            cmd.Parameters.AddWithValue("@id", sessionId);
                            cmd.Parameters.AddWithValue("@t", tid);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    Response.Redirect("~/Teacher/liveClass.aspx?id=" + Server.UrlEncode(sessionId), false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }
            }
            else if (e.CommandName == "ViewSummary" && args.Length >= 1)
            {
                string sessionId = args[0];
                LoadSummaryForSession(sessionId);
                LoadPage();
                return;
            }
            else if (e.CommandName == "Reschedule" && args.Length >= 4)
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
            string unit = Request.Form[ddlInstantUnit.UniqueID] ?? "";
            string sub = Request.Form[ddlInstantSubtopic.UniqueID] ?? "";

            // Validate required fields
            var errors = new List<string>();
            if (string.IsNullOrEmpty(title)) errors.Add(T("Please enter a session title.", "Sila masukkan tajuk sesi."));
            if (string.IsNullOrEmpty(unit)) errors.Add(T("Please select a unit.", "Sila pilih unit."));
            if (string.IsNullOrEmpty(sub)) errors.Add(T("Please select a subtopic.", "Sila pilih subtopik."));

            if (errors.Count > 0)
            {
                pnlInstantError.Visible = true;
                litInstantError.Text = string.Join("<br/>", errors);
                hidShowInstantModal.Value = "1";
                LoadPage();
                return;
            }

            string tid = GetTeacherId(); if (string.IsNullOrEmpty(tid)) return;
            string unitId = null;
            string newId = null;
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [unitId] FROM dbo.[Subtopic] WHERE [subtopicId]=@s", conn))
                { cmd.Parameters.AddWithValue("@s", sub); unitId = cmd.ExecuteScalar()?.ToString(); }

                using (var cmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING([sessionId],5,LEN([sessionId])-4) AS INT)),0) FROM dbo.[LiveConsultationSession] WHERE [sessionId] LIKE 'LIVE%'", conn))
                { newId = "LIVE" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3"); }

                string roomName = "ScienceBuddy-" + newId;
                string meetingLink = "https://meet.jit.si/" + roomName;
                string desc = txtInstantDesc.Text.Trim();
                DateTime now = DateTime.Now;

                using (var cmd = new SqlCommand("INSERT INTO dbo.[LiveConsultationSession]([sessionId],[teacherId],[unitId],[subtopicId],[sessionTitle],[sessionDescription],[meetingLink],[startDateTime],[endDateTime],[status]) VALUES(@id,@t,@u,@s,@title,@desc,@link,@st,@en,@status)", conn))
                {
                    cmd.Parameters.AddWithValue("@id", newId);
                    cmd.Parameters.AddWithValue("@t", tid);
                    cmd.Parameters.AddWithValue("@u", (object)unitId ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@s", sub);
                    cmd.Parameters.AddWithValue("@title", title);
                    cmd.Parameters.AddWithValue("@desc", string.IsNullOrEmpty(desc) ? (object)DBNull.Value : desc);
                    cmd.Parameters.AddWithValue("@link", meetingLink);
                    cmd.Parameters.AddWithValue("@st", now);
                    cmd.Parameters.AddWithValue("@en", DateTime.Today);
                    cmd.Parameters.AddWithValue("@status", "Ongoing");
                    cmd.ExecuteNonQuery();
                }

            }

            txtInstantTitle.Text = ""; txtInstantDesc.Text = "";
            Response.Redirect("~/Teacher/liveClass.aspx?id=" + Server.UrlEncode(newId), false);
            Context.ApplicationInstance.CompleteRequest();
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
            hidToast.Value = T("Live session ended.", "Sesi langsung ditamatkan.");
            LoadPage();
        }

        protected void btnSchedule_Click(object sender, EventArgs e)
        {
            string title = txtTitle.Text.Trim(), date = txtDate.Text, start = txtStart.Text, end = txtEnd.Text;
            string sub = Request.Form[ddlSubtopic.UniqueID] ?? "";
            if (string.IsNullOrEmpty(title) || string.IsNullOrEmpty(date) || string.IsNullOrEmpty(start) || string.IsNullOrEmpty(end) || string.IsNullOrEmpty(sub))
            { ShowError(T("Please fill in all required fields.", "Sila lengkapkan semua medan.")); return; }
            DateTime startDt, endDt;
            if (!DateTime.TryParse(date + " " + start, out startDt) || !DateTime.TryParse(date + " " + end, out endDt)) { ShowError(T("Invalid date/time.", "Tarikh/masa tidak sah.")); return; }
            if (startDt < DateTime.Now) { ShowError(T("Date and time cannot be in the past.", "Tarikh dan masa tidak boleh pada masa lalu.")); return; }
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
                using (var cmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING([sessionId],5,LEN([sessionId])-4) AS INT)),0) FROM dbo.[LiveConsultationSession] WHERE [sessionId] LIKE 'LIVE%'", conn))
                { newId = "LIVE" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3"); }

                string meetingLink = "https://meet.jit.si/ScienceBuddy-" + newId;
                string desc = txtDesc.Text.Trim();

                using (var cmd = new SqlCommand("INSERT INTO dbo.[LiveConsultationSession]([sessionId],[teacherId],[unitId],[subtopicId],[sessionTitle],[sessionDescription],[meetingLink],[startDateTime],[endDateTime],[status]) VALUES(@id,@t,@u,@s,@title,@desc,@link,@st,@en,@status)", conn))
                {
                    cmd.Parameters.AddWithValue("@id", newId); cmd.Parameters.AddWithValue("@t", tid);
                    cmd.Parameters.AddWithValue("@u", (object)unitId ?? DBNull.Value); cmd.Parameters.AddWithValue("@s", sub);
                    cmd.Parameters.AddWithValue("@title", title);
                    cmd.Parameters.AddWithValue("@desc", string.IsNullOrEmpty(desc) ? (object)DBNull.Value : desc);
                    cmd.Parameters.AddWithValue("@link", meetingLink);
                    cmd.Parameters.AddWithValue("@st", startDt); cmd.Parameters.AddWithValue("@en", endDt);
                    cmd.Parameters.AddWithValue("@status", "Upcoming");
                    cmd.ExecuteNonQuery();
                }
            }
            hidToast.Value = T("Live class scheduled successfully!", "Kelas langsung berjaya dijadualkan!");
            txtTitle.Text = ""; txtDate.Text = ""; txtStart.Text = ""; txtEnd.Text = ""; txtDesc.Text = "";
            LoadPage();
        }

        private void ShowError(string msg) { pnlError.Visible = true; litError.Text = HttpUtility.HtmlEncode(msg); hidShowModal.Value = "1"; }

        protected void hidShowInstantModal_ValueChanged(object sender, EventArgs e)
        {

        }

        private void HandleSessionSummary()
        {
            Response.Clear();
            Response.ContentType = "application/json";
            string sessionId = (Request.QueryString["id"] ?? "").Trim();
            if (string.IsNullOrEmpty(sessionId) || Session["userId"] == null)
            { Response.Write("{\"error\":true}"); Response.End(); return; }

            try
            {
                string userId = Session["userId"].ToString();
                string teacherId = "";
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("SELECT [teacherId] FROM dbo.[Teacher] WHERE [userId]=@u AND [status]='Certified'", conn))
                    { cmd.Parameters.AddWithValue("@u", userId); teacherId = cmd.ExecuteScalar()?.ToString() ?? ""; }
                }
                if (string.IsNullOrEmpty(teacherId)) { Response.Write("{\"error\":true}"); Response.End(); return; }

                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    string title = ""; DateTime startTime = DateTime.Now, endTime = DateTime.Now;
                    using (var cmd = new SqlCommand("SELECT [sessionTitle],[startDateTime],[endDateTime] FROM dbo.[LiveConsultationSession] WHERE [sessionId]=@id AND [teacherId]=@t AND [status]='Completed'", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", sessionId); cmd.Parameters.AddWithValue("@t", teacherId);
                        using (var r = cmd.ExecuteReader())
                        {
                            if (!r.Read()) { Response.Write("{\"error\":true}"); Response.End(); return; }
                            title = r["sessionTitle"]?.ToString() ?? "";
                            startTime = r["startDateTime"] != System.DBNull.Value ? Convert.ToDateTime(r["startDateTime"]) : DateTime.Now;
                            endTime = r["endDateTime"] != System.DBNull.Value ? Convert.ToDateTime(r["endDateTime"]) : DateTime.Now;
                        }
                    }

                    TimeSpan duration = endTime - startTime;
                    int totalMinutes = (int)duration.TotalMinutes;
                    string durationText;
                    if (totalMinutes < 1) durationText = "< 1 min";
                    else if (totalMinutes < 60) durationText = totalMinutes + " min";
                    else { int h = (int)duration.TotalHours; int m = duration.Minutes; durationText = m > 0 ? h + " hr " + m + " min" : h + " hr"; }

                    var participants = new System.Text.StringBuilder();
                    int studentCount = 0;
                    participants.Append("[");
                    using (var cmd = new SqlCommand("SELECT DISTINCT s.[name],s.[nickname] FROM dbo.[LiveSessionParticipant] p LEFT JOIN dbo.[Student] s ON s.[studentId]=p.[studentId] WHERE p.[sessionId]=@id ORDER BY s.[name]", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", sessionId);
                        using (var r = cmd.ExecuteReader())
                        {
                            bool first = true;
                            while (r.Read())
                            {
                                string name = r["name"]?.ToString() ?? r["nickname"]?.ToString() ?? "Student";
                                string initials = "";
                                var parts = name.Trim().Split(' ');
                                if (parts.Length >= 2) initials = (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
                                else if (name.Length > 0) initials = name[0].ToString().ToUpper();
                                if (!first) participants.Append(",");
                                first = false;
                                participants.Append("{\"name\":\"" + name.Replace("\"", "\\\"") + "\",\"initials\":\"" + initials + "\"}");
                                studentCount++;
                            }
                        }
                    }
                    participants.Append("]");

                    string json = "{\"title\":\"" + title.Replace("\"", "\\\"") + "\","
                        + "\"startTime\":\"" + startTime.ToString("h:mm tt") + "\","
                        + "\"endTime\":\"" + endTime.ToString("h:mm tt") + "\","
                        + "\"duration\":\"" + durationText + "\","
                        + "\"studentCount\":" + studentCount + ","
                        + "\"participants\":" + participants.ToString() + "}";
                    Response.Write(json);
                }
            }
            catch { Response.Write("{\"error\":true}"); }
            Response.End();
        }
    }
}
