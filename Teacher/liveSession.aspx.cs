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

        /// <summary>
        /// Minimum session duration (in minutes) loaded from ConfigurationSetting table.
        /// Cached in ViewState to avoid repeated DB calls per postback.
        /// </summary>
        protected int MinSessionDuration
        {
            get
            {
                if (ViewState["_minDur"] != null)
                    return (int)ViewState["_minDur"];

                int value = 30; // fallback default
                try
                {
                    using (var conn = new SqlConnection(ConnStr))
                    {
                        conn.Open();
                        using (var cmd = new SqlCommand(
                            "SELECT [configValue] FROM dbo.[ConfigurationSetting] WHERE [configId]='CONFIG014'", conn))
                        {
                            var result = cmd.ExecuteScalar();
                            if (result != null && result != DBNull.Value)
                                int.TryParse(result.ToString(), out value);
                        }
                    }
                }
                catch { }

                ViewState["_minDur"] = value;
                return value;
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

            // AJAX handlers — return JSON and short-circuit the page lifecycle
            string handler = Request.QueryString["handler"] ?? "";
            if (handler == "subtopicsByUnit")
            {
                HandleSubtopicsByUnit();
                return;
            }
            if (handler == "sessionSummary")
            {
                HandleSessionSummary();
                return;
            }

            var master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                btnSchedule.Text = T("Schedule", "Jadualkan");
                btnStartLive.Text = T("Start Live", "Mulakan Langsung");
                hidLicenseStatus.Value = GetTeacherLicenseStatus();
                LoadPage();
                LoadSummaryIfRequested();
            }
        }

        #endregion

        #region Event Handlers

        protected void rptSessions_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string[] args = e.CommandArgument.ToString().Split('|');

            if (e.CommandName == "StartSession" && args.Length >= 1)
            {
                StartLiveSession(args[0]);
                return;
            }
            else if (e.CommandName == "ViewSummary" && args.Length >= 1)
            {
                LoadSummaryForSession(args[0]);
                LoadPage();
                return;
            }
            else if (e.CommandName == "Reschedule" && args.Length >= 4)
            {
                ShowRescheduleModal(args);
            }
            else if (e.CommandName == "Cancel" && args.Length >= 3)
            {
                ShowCancelModal(args);
            }

            LoadPage();
        }

        protected void btnSaveReschedule_Click(object sender, EventArgs e)
        {
            string sessionId = hidRescId.Value;
            string date = txtRescDate.Text;
            string start = txtRescStart.Text;
            string end = txtRescEnd.Text;

            if (string.IsNullOrEmpty(date) || string.IsNullOrEmpty(start) || string.IsNullOrEmpty(end))
            {
                ShowRescheduleError(T("Please fill all fields.", "Sila lengkapkan semua medan."));
                return;
            }

            DateTime startDt, endDt;
            if (!DateTime.TryParse(date + " " + start, out startDt) || !DateTime.TryParse(date + " " + end, out endDt))
            {
                ShowRescheduleError(T("Invalid date/time.", "Tarikh/masa tidak sah."));
                return;
            }

            if (endDt <= startDt)
            {
                ShowRescheduleError(T("End time must be after start time.", "Masa tamat mesti selepas masa mula."));
                return;
            }

            string teacherId = GetTeacherId();
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(
                    "UPDATE dbo.[LiveConsultationSession] SET [startDateTime]=@s,[endDateTime]=@e WHERE [sessionId]=@id AND [teacherId]=@t", conn))
                {
                    cmd.Parameters.AddWithValue("@s", startDt);
                    cmd.Parameters.AddWithValue("@e", endDt);
                    cmd.Parameters.AddWithValue("@id", sessionId);
                    cmd.Parameters.AddWithValue("@t", teacherId);
                    cmd.ExecuteNonQuery();
                }
            }

            hidToast.Value = T("Live session rescheduled successfully.", "Sesi langsung berjaya dijadual semula.");
            LoadPage();
        }

        protected void btnConfirmCancel_Click(object sender, EventArgs e)
        {
            string sessionId = hidCancelId.Value;
            string teacherId = GetTeacherId();

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(
                    "UPDATE dbo.[LiveConsultationSession] SET [status]='Cancelled' WHERE [sessionId]=@s AND [teacherId]=@t", conn))
                {
                    cmd.Parameters.AddWithValue("@s", sessionId);
                    cmd.Parameters.AddWithValue("@t", teacherId);
                    cmd.ExecuteNonQuery();
                }
            }

            hidToast.Value = T("Live session cancelled.", "Sesi langsung dibatalkan.");
            LoadPage();
        }

        protected void btnStartLive_Click(object sender, EventArgs e)
        {
            string title = txtInstantTitle.Text.Trim();
            string selectedUnitId = Request.Form[ddlInstantUnit.UniqueID] ?? "";
            string selectedSubtopicId = Request.Form[ddlInstantSubtopic.UniqueID] ?? "";

            // Validate required fields
            var errors = new List<string>();
            if (string.IsNullOrEmpty(title))
                errors.Add(T("Please enter a session title.", "Sila masukkan tajuk sesi."));
            if (string.IsNullOrEmpty(selectedUnitId))
                errors.Add(T("Please select a unit.", "Sila pilih unit."));
            if (string.IsNullOrEmpty(selectedSubtopicId))
                errors.Add(T("Please select a subtopic.", "Sila pilih subtopik."));

            if (errors.Count > 0)
            {
                pnlInstantError.Visible = true;
                litInstantError.Text = string.Join("<br/>", errors);
                hidShowInstantModal.Value = "1";
                LoadPage();
                return;
            }

            string teacherId = GetTeacherId();
            if (string.IsNullOrEmpty(teacherId)) return;

            string unitId = null;
            string newSessionId = null;

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                using (var cmd = new SqlCommand("SELECT [unitId] FROM dbo.[Subtopic] WHERE [subtopicId]=@s", conn))
                {
                    cmd.Parameters.AddWithValue("@s", selectedSubtopicId);
                    unitId = cmd.ExecuteScalar()?.ToString();
                }

                newSessionId = GenerateNextSessionId(conn);
                string roomName = "ScienceBuddy-" + newSessionId;
                string meetingLink = "https://meet.jit.si/" + roomName;
                string description = txtInstantDesc.Text.Trim();
                DateTime now = DateTime.Now;

                using (var cmd = new SqlCommand(
                    @"INSERT INTO dbo.[LiveConsultationSession]
                      ([sessionId],[teacherId],[unitId],[subtopicId],[sessionTitle],[sessionDescription],[meetingLink],[startDateTime],[endDateTime],[status])
                      VALUES(@id,@t,@u,@s,@title,@desc,@link,@st,@en,@status)", conn))
                {
                    cmd.Parameters.AddWithValue("@id", newSessionId);
                    cmd.Parameters.AddWithValue("@t", teacherId);
                    cmd.Parameters.AddWithValue("@u", (object)unitId ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@s", selectedSubtopicId);
                    cmd.Parameters.AddWithValue("@title", title);
                    cmd.Parameters.AddWithValue("@desc", string.IsNullOrEmpty(description) ? (object)DBNull.Value : description);
                    cmd.Parameters.AddWithValue("@link", meetingLink);
                    cmd.Parameters.AddWithValue("@st", now);
                    cmd.Parameters.AddWithValue("@en", DateTime.Today);
                    cmd.Parameters.AddWithValue("@status", "Ongoing");
                    cmd.ExecuteNonQuery();
                }

                // Notify all active students that a live session has started
                NotifyStudents(conn, title,
                    titleEN: "Live Session Started",
                    titleBM: "Sesi Langsung Telah Bermula",
                    msgEN: "A live session titled \"" + title + "\" has started. Join now.",
                    msgBM: "Sesi langsung bertajuk \"" + title + "\" telah bermula. Sertai sekarang.");
            }

            txtInstantTitle.Text = "";
            txtInstantDesc.Text = "";
            Response.Redirect("~/Teacher/liveClass.aspx?id=" + Server.UrlEncode(newSessionId), false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected void btnEndLive_Click(object sender, EventArgs e)
        {
            hidToast.Value = T("Live session ended.", "Sesi langsung ditamatkan.");
            LoadPage();
        }

        protected void btnSchedule_Click(object sender, EventArgs e)
        {
            string title = txtTitle.Text.Trim();
            string date = txtDate.Text;
            string start = txtStart.Text;
            string end = txtEnd.Text;
            string selectedSubtopicId = Request.Form[ddlSubtopic.UniqueID] ?? "";

            if (string.IsNullOrEmpty(title) || string.IsNullOrEmpty(date) ||
                string.IsNullOrEmpty(start) || string.IsNullOrEmpty(end) || string.IsNullOrEmpty(selectedSubtopicId))
            {
                ShowScheduleError(T("Please fill in all required fields.", "Sila lengkapkan semua medan."));
                return;
            }

            DateTime startDt, endDt;
            if (!DateTime.TryParse(date + " " + start, out startDt) || !DateTime.TryParse(date + " " + end, out endDt))
            {
                ShowScheduleError(T("Invalid date/time.", "Tarikh/masa tidak sah."));
                return;
            }
            if (startDt < DateTime.Now)
            {
                ShowScheduleError(T("Date and time cannot be in the past.", "Tarikh dan masa tidak boleh pada masa lalu."));
                return;
            }
            if (endDt <= startDt)
            {
                ShowScheduleError(T("End time must be after start time.", "Masa tamat mesti selepas masa mula."));
                return;
            }

            string teacherId = GetTeacherId();
            if (string.IsNullOrEmpty(teacherId))
                return;

            string unitId = null;
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                using (var cmd = new SqlCommand("SELECT [unitId] FROM dbo.[Subtopic] WHERE [subtopicId]=@s", conn))
                {
                    cmd.Parameters.AddWithValue("@s", selectedSubtopicId);
                    unitId = cmd.ExecuteScalar()?.ToString();
                }

                string newSessionId = GenerateNextSessionId(conn);
                string meetingLink = "https://meet.jit.si/ScienceBuddy-" + newSessionId;
                string description = txtDesc.Text.Trim();

                using (var cmd = new SqlCommand(
                    @"INSERT INTO dbo.[LiveConsultationSession]
                      ([sessionId],[teacherId],[unitId],[subtopicId],[sessionTitle],[sessionDescription],[meetingLink],[startDateTime],[endDateTime],[status])
                      VALUES(@id,@t,@u,@s,@title,@desc,@link,@st,@en,@status)", conn))
                {
                    cmd.Parameters.AddWithValue("@id", newSessionId);
                    cmd.Parameters.AddWithValue("@t", teacherId);
                    cmd.Parameters.AddWithValue("@u", (object)unitId ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@s", selectedSubtopicId);
                    cmd.Parameters.AddWithValue("@title", title);
                    cmd.Parameters.AddWithValue("@desc", string.IsNullOrEmpty(description) ? (object)DBNull.Value : description);
                    cmd.Parameters.AddWithValue("@link", meetingLink);
                    cmd.Parameters.AddWithValue("@st", startDt);
                    cmd.Parameters.AddWithValue("@en", endDt);
                    cmd.Parameters.AddWithValue("@status", "Upcoming");
                    cmd.ExecuteNonQuery();
                }

                // Notify all active students about the scheduled session
                string dateTimeStr = startDt.ToString("dd MMM yyyy, hh:mm tt");
                NotifyStudents(conn, title,
                    titleEN: "Upcoming Live Session",
                    titleBM: "Sesi Langsung Akan Datang",
                    msgEN: "A new live session titled \"" + title + "\" has been scheduled for " + dateTimeStr + ".",
                    msgBM: "Sesi langsung baharu bertajuk \"" + title + "\" telah dijadualkan pada " + dateTimeStr + ".");
            }

            hidToast.Value = T("Live class scheduled successfully!", "Kelas langsung berjaya dijadualkan!");
            txtTitle.Text = "";
            txtDate.Text = "";
            txtStart.Text = "";
            txtEnd.Text = "";
            txtDesc.Text = "";
            LoadPage();
        }

        protected void hidShowInstantModal_ValueChanged(object sender, EventArgs e)
        {
        }

        #endregion

        #region Data Loading

        private void LoadPage()
        {
            string teacherId = GetTeacherId();
            LoadUnitDropdowns();

            if (!string.IsNullOrEmpty(teacherId))
            {
                ExpireOverdueSessions(teacherId);
                LoadStats(teacherId);
                LoadSessionTabs(teacherId);
            }
            else
            {
                // No certified teacher record — show empty states
                pnlListUpcoming.Visible = false;
                pnlUpcomingEmpty.Visible = true;
                pnlListHistory.Visible = false;
                pnlHistoryEmpty.Visible = true;
            }
        }

        private void LoadUnitDropdowns()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                ddlUnit.Items.Clear();
                ddlUnit.Items.Add(new ListItem(T("— Select Unit —", "— Pilih Unit —"), ""));
                ddlInstantUnit.Items.Clear();
                ddlInstantUnit.Items.Add(new ListItem(T("— Select Unit —", "— Pilih Unit —"), ""));

                using (var cmd = new SqlCommand(
                    @"SELECT u.[unitId], u.[unitNameEN], l.[levelNameEN]
                      FROM dbo.[Unit] u
                      INNER JOIN dbo.[Level] l ON l.[levelId]=u.[levelId]
                      ORDER BY u.[levelId], u.[orderNo]", conn))
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string text = reader["levelNameEN"] + " - " + reader["unitNameEN"];
                        string value = reader["unitId"].ToString();
                        ddlUnit.Items.Add(new ListItem(text, value));
                        ddlInstantUnit.Items.Add(new ListItem(text, value));
                    }
                }

                // Subtopic dropdowns start empty — populated via AJAX when a unit is selected
                ddlSubtopic.Items.Clear();
                ddlSubtopic.Items.Add(new ListItem(T("— Select Unit First —", "— Pilih Unit Dahulu —"), ""));
                ddlInstantSubtopic.Items.Clear();
                ddlInstantSubtopic.Items.Add(new ListItem(T("— Select Unit First —", "— Pilih Unit Dahulu —"), ""));
            }
        }

        private void LoadStats(string teacherId)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                litUpcoming.Text = ExecuteCountQuery(conn,
                    "SELECT COUNT(*) FROM dbo.[LiveConsultationSession] WHERE [teacherId]=@t AND [startDateTime]>GETDATE()", teacherId);

                litCompleted.Text = ExecuteCountQuery(conn,
                    "SELECT COUNT(*) FROM dbo.[LiveConsultationSession] WHERE [teacherId]=@t AND [endDateTime]<GETDATE()", teacherId);

                litCancelled.Text = ExecuteCountQuery(conn,
                    "SELECT COUNT(*) FROM dbo.[LiveConsultationSession] WHERE [teacherId]=@t AND [status]='Cancelled'", teacherId);

                litStudentsJoined.Text = ExecuteCountQuery(conn,
                    @"SELECT COUNT(DISTINCT lsp.[studentId])
                      FROM dbo.[LiveSessionParticipant] lsp
                      INNER JOIN dbo.[LiveConsultationSession] lcs ON lcs.[sessionId]=lsp.[sessionId]
                      WHERE lcs.[teacherId]=@t", teacherId);
            }
        }

        private void LoadSessionTabs(string teacherId)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                LoadUpcomingSessions(conn, teacherId);
                LoadHistorySessions(conn, teacherId);
            }
        }

        private void LoadUpcomingSessions(SqlConnection conn, string teacherId)
        {
            string sql = @"SELECT lcs.[sessionId], lcs.[sessionTitle], lcs.[startDateTime], lcs.[endDateTime], lcs.[status],
                ISNULL(st.[subtopicTitleEN],'') AS topic,
                (SELECT COUNT(*) FROM dbo.[LiveSessionParticipant] WHERE [sessionId]=lcs.[sessionId]) AS students
                FROM dbo.[LiveConsultationSession] lcs
                LEFT JOIN dbo.[Subtopic] st ON st.[subtopicId]=lcs.[subtopicId]
                WHERE lcs.[teacherId]=@t AND lcs.[status] IN ('Upcoming','Ongoing')
                ORDER BY lcs.[startDateTime] ASC";

            var sessions = new List<object>();
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@t", teacherId);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        DateTime startTime = reader["startDateTime"] != DBNull.Value ? Convert.ToDateTime(reader["startDateTime"]) : DateTime.Now;
                        DateTime endTime = reader["endDateTime"] != DBNull.Value ? Convert.ToDateTime(reader["endDateTime"]) : startTime;
                        string status = reader["status"]?.ToString() ?? "Upcoming";

                        string badgeCss, badgeLabel;
                        if (status.Equals("Ongoing", StringComparison.OrdinalIgnoreCase))
                        {
                            badgeCss = "tc-live-session-badge-live";
                            badgeLabel = "🔴 " + T("LIVE NOW", "LANGSUNG");
                        }
                        else
                        {
                            badgeCss = "tc-live-session-badge-upcoming";
                            badgeLabel = T("Upcoming", "Akan Datang");
                        }

                        // Teachers can start a session up to 15 minutes before the scheduled time
                        bool canStart = DateTime.Now >= startTime.AddMinutes(-15);

                        sessions.Add(new
                        {
                            sessionId = reader["sessionId"].ToString(),
                            title = reader["sessionTitle"]?.ToString() ?? "",
                            day = startTime.Day.ToString(),
                            month = startTime.ToString("MMM").ToUpper(),
                            timeRange = startTime.ToString("h:mm tt") + " – " + endTime.ToString("h:mm tt"),
                            topic = reader["topic"]?.ToString() ?? "",
                            students = Convert.ToInt32(reader["students"]),
                            duration = "",
                            badgeCss,
                            badgeLabel,
                            rawStart = startTime.ToString("yyyy-MM-dd HH:mm"),
                            rawEnd = endTime.ToString("yyyy-MM-dd HH:mm"),
                            canStart
                        });
                    }
                }
            }

            if (sessions.Count > 0)
            {
                pnlListUpcoming.Visible = true;
                pnlUpcomingEmpty.Visible = false;
                rptUpcoming.DataSource = sessions;
                rptUpcoming.DataBind();
            }
            else
            {
                pnlListUpcoming.Visible = false;
                pnlUpcomingEmpty.Visible = true;
            }
        }

        private void LoadHistorySessions(SqlConnection conn, string teacherId)
        {
            string sql = @"SELECT lcs.[sessionId], lcs.[sessionTitle], lcs.[startDateTime], lcs.[endDateTime], lcs.[status],
                ISNULL(st.[subtopicTitleEN],'') AS topic,
                (SELECT COUNT(*) FROM dbo.[LiveSessionParticipant] WHERE [sessionId]=lcs.[sessionId]) AS students
                FROM dbo.[LiveConsultationSession] lcs
                LEFT JOIN dbo.[Subtopic] st ON st.[subtopicId]=lcs.[subtopicId]
                WHERE lcs.[teacherId]=@t AND lcs.[status] IN ('Completed','Cancelled','Expired')
                ORDER BY lcs.[startDateTime] DESC";

            var sessions = new List<object>();
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@t", teacherId);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        DateTime startTime = reader["startDateTime"] != DBNull.Value ? Convert.ToDateTime(reader["startDateTime"]) : DateTime.Now;
                        DateTime endTime = reader["endDateTime"] != DBNull.Value ? Convert.ToDateTime(reader["endDateTime"]) : startTime;
                        int durationMinutes = (int)(endTime - startTime).TotalMinutes;
                        string status = reader["status"]?.ToString() ?? "Completed";

                        string badgeCss, badgeLabel;
                        if (status.Equals("Cancelled", StringComparison.OrdinalIgnoreCase))
                        {
                            badgeCss = "tc-live-session-badge-cancelled";
                            badgeLabel = T("Cancelled", "Dibatalkan");
                        }
                        else if (status.Equals("Expired", StringComparison.OrdinalIgnoreCase))
                        {
                            badgeCss = "tc-live-session-badge-expired";
                            badgeLabel = T("Expired", "Tamat Tempoh");
                        }
                        else
                        {
                            badgeCss = "tc-live-session-badge-completed";
                            badgeLabel = T("Completed", "Selesai");
                        }

                        bool isCompleted = status.Equals("Completed", StringComparison.OrdinalIgnoreCase);

                        sessions.Add(new
                        {
                            sessionId = reader["sessionId"].ToString(),
                            title = reader["sessionTitle"]?.ToString() ?? "",
                            day = startTime.Day.ToString(),
                            month = startTime.ToString("MMM").ToUpper(),
                            timeRange = startTime.ToString("h:mm tt") + " – " + endTime.ToString("h:mm tt"),
                            topic = reader["topic"]?.ToString() ?? "",
                            students = Convert.ToInt32(reader["students"]),
                            duration = durationMinutes + " min",
                            badgeCss,
                            badgeLabel,
                            isCompleted
                        });
                    }
                }
            }

            if (sessions.Count > 0)
            {
                pnlListHistory.Visible = true;
                pnlHistoryEmpty.Visible = false;
                rptHistory.DataSource = sessions;
                rptHistory.DataBind();
            }
            else
            {
                pnlListHistory.Visible = false;
                pnlHistoryEmpty.Visible = true;
            }
        }

        /// <summary>
        /// Loads session summary from query string on initial page load (e.g. redirected after ending a session).
        /// </summary>
        private void LoadSummaryIfRequested()
        {
            string summaryId = (Request.QueryString["summary"] ?? "").Trim();
            if (string.IsNullOrEmpty(summaryId)) return;

            LoadSummaryForSession(summaryId);
        }

        /// <summary>
        /// Loads and binds session summary data (title, duration, participants) for a completed session.
        /// </summary>
        private void LoadSummaryForSession(string sessionId)
        {
            string teacherId = GetTeacherId();
            if (string.IsNullOrEmpty(teacherId) || string.IsNullOrEmpty(sessionId)) return;

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
                        cmd.Parameters.AddWithValue("@id", sessionId);
                        cmd.Parameters.AddWithValue("@t", teacherId);
                        using (var reader = cmd.ExecuteReader())
                        {
                            if (!reader.Read()) return;
                            title = reader["sessionTitle"]?.ToString() ?? "";
                            startTime = reader["startDateTime"] != DBNull.Value ? Convert.ToDateTime(reader["startDateTime"]) : DateTime.Now;
                            endTime = reader["endDateTime"] != DBNull.Value ? Convert.ToDateTime(reader["endDateTime"]) : DateTime.Now;
                        }
                    }

                    string durationText = FormatDuration(endTime - startTime);

                    var participants = LoadSessionParticipants(conn, sessionId);

                    // Bind summary UI
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

                    hidShowSummary.Value = "1";
                }
            }
            catch { }
        }

        #endregion

        #region Database Operations

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

        private void StartLiveSession(string sessionId)
        {
            string teacherId = GetTeacherId();
            if (string.IsNullOrEmpty(teacherId)) return;

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
                    cmd.Parameters.AddWithValue("@t", teacherId);
                    cmd.ExecuteNonQuery();
                }
            }

            Response.Redirect("~/Teacher/liveClass.aspx?id=" + Server.UrlEncode(sessionId), false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private string GetTeacherId()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(
                    "SELECT [teacherId] FROM dbo.[Teacher] WHERE [userId]=@u AND [status]='Certified'", conn))
                {
                    cmd.Parameters.AddWithValue("@u", Session["userId"].ToString());
                    return cmd.ExecuteScalar()?.ToString();
                }
            }
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

        /// <summary>
        /// Generates the next sequential session ID (e.g. LIVE001, LIVE002).
        /// </summary>
        private string GenerateNextSessionId(SqlConnection conn)
        {
            using (var cmd = new SqlCommand(
                "SELECT ISNULL(MAX(CAST(SUBSTRING([sessionId],5,LEN([sessionId])-4) AS INT)),0) FROM dbo.[LiveConsultationSession] WHERE [sessionId] LIKE 'LIVE%'", conn))
            {
                return "LIVE" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3");
            }
        }

        /// <summary>
        /// Sends a notification to all active students. Non-critical — failures are swallowed.
        /// </summary>
        private void NotifyStudents(SqlConnection conn, string sessionTitle, string titleEN, string titleBM, string msgEN, string msgBM)
        {
            try
            {
                int maxNotifNum = 0;
                using (var cmd = new SqlCommand(
                    "SELECT ISNULL(MAX(CAST(SUBSTRING([notificationId],2,LEN([notificationId])-1) AS INT)),0) FROM dbo.[Notification]", conn))
                {
                    maxNotifNum = Convert.ToInt32(cmd.ExecuteScalar());
                }

                var studentUserIds = new List<string>();
                using (var cmd = new SqlCommand(
                    "SELECT u.[userId] FROM dbo.[User] u INNER JOIN dbo.[Student] s ON s.[userId]=u.[userId] WHERE u.[status]='Active'", conn))
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                        studentUserIds.Add(reader["userId"].ToString());
                }

                foreach (var studentUserId in studentUserIds)
                {
                    maxNotifNum++;
                    string notificationId = "N" + maxNotifNum.ToString("D3");

                    using (var ins = new SqlCommand(
                        @"INSERT INTO dbo.[Notification]
                          ([notificationId],[toUserId],[titleEN],[titleBM],[messageEN],[messageBM],[isRead],[createdAt])
                          VALUES(@id,@uid,@tEN,@tBM,@mEN,@mBM,0,GETDATE())", conn))
                    {
                        ins.Parameters.AddWithValue("@id", notificationId);
                        ins.Parameters.AddWithValue("@uid", studentUserId);
                        ins.Parameters.AddWithValue("@tEN", titleEN);
                        ins.Parameters.AddWithValue("@tBM", titleBM);
                        ins.Parameters.AddWithValue("@mEN", msgEN);
                        ins.Parameters.AddWithValue("@mBM", msgBM);
                        ins.ExecuteNonQuery();
                    }
                }
            }
            catch { /* Notification failure is non-critical */ }
        }

        #endregion

        #region Helper Methods

        /// <summary>
        /// Bilingual text helper — returns English or Bahasa Melayu based on session language.
        /// </summary>
        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        private string ExecuteCountQuery(SqlConnection conn, string sql, string teacherId)
        {
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@t", teacherId);
                return Convert.ToInt32(cmd.ExecuteScalar()).ToString();
            }
        }

        /// <summary>
        /// Formats a TimeSpan into a human-readable duration string (e.g. "45 min", "1 hr 30 min").
        /// </summary>
        private string FormatDuration(TimeSpan duration)
        {
            int totalMinutes = (int)duration.TotalMinutes;

            if (totalMinutes < 1)
                return "< 1 min";
            if (totalMinutes < 60)
                return totalMinutes + " min";

            int hours = (int)duration.TotalHours;
            int minutes = duration.Minutes;
            return minutes > 0 ? hours + " hr " + minutes + " min" : hours + " hr";
        }

        /// <summary>
        /// Builds participant initials from a name (first + last initial, or single initial).
        /// </summary>
        private string GetInitials(string name)
        {
            if (string.IsNullOrEmpty(name)) return "";

            var parts = name.Trim().Split(' ');
            if (parts.Length >= 2)
                return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();

            return name[0].ToString().ToUpper();
        }

        /// <summary>
        /// Loads participant list (name + initials) for a given session.
        /// </summary>
        private List<object> LoadSessionParticipants(SqlConnection conn, string sessionId)
        {
            var participants = new List<object>();

            using (var cmd = new SqlCommand(
                @"SELECT DISTINCT s.[name], s.[nickname]
                  FROM dbo.[LiveSessionParticipant] p
                  LEFT JOIN dbo.[Student] s ON s.[studentId]=p.[studentId]
                  WHERE p.[sessionId]=@id
                  ORDER BY s.[name]", conn))
            {
                cmd.Parameters.AddWithValue("@id", sessionId);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string name = reader["name"]?.ToString() ?? reader["nickname"]?.ToString() ?? "Student";
                        string initials = GetInitials(name);
                        participants.Add(new { name, initials });
                    }
                }
            }

            return participants;
        }

        private void ShowScheduleError(string msg)
        {
            pnlError.Visible = true;
            litError.Text = HttpUtility.HtmlEncode(msg);
            hidShowModal.Value = "1";
        }

        private void ShowRescheduleError(string msg)
        {
            pnlRescError.Visible = true;
            litRescError.Text = msg;
            hidShowRescModal.Value = "1";
            LoadPage();
        }

        private void ShowRescheduleModal(string[] args)
        {
            hidRescId.Value = args[0];
            litRescTitle.Text = HttpUtility.HtmlEncode(args[3]);

            DateTime startTime = DateTime.Parse(args[1]);
            DateTime endTime = DateTime.Parse(args[2]);

            litRescCurrent.Text = T("Current: ", "Semasa: ") +
                startTime.ToString("d MMM yyyy, h:mm tt") + " – " + endTime.ToString("h:mm tt");

            txtRescDate.Text = startTime.ToString("yyyy-MM-dd");
            txtRescStart.Text = startTime.ToString("HH:mm");
            txtRescEnd.Text = endTime.ToString("HH:mm");
            btnSaveReschedule.Text = T("Save Changes", "Simpan Perubahan");
            hidShowRescModal.Value = "1";
        }

        private void ShowCancelModal(string[] args)
        {
            hidCancelId.Value = args[0];
            litCancelTitle.Text = HttpUtility.HtmlEncode(args[1]);
            litCancelTime.Text = args[2];
            btnConfirmCancel.Text = T("Cancel Session", "Batalkan Sesi");
            hidShowCancelModal.Value = "1";
        }

        /// <summary>
        /// AJAX handler: returns subtopics as JSON for the selected unit (used by client-side dropdowns).
        /// </summary>
        private void HandleSubtopicsByUnit()
        {
            Response.Clear();
            Response.ContentType = "application/json";

            string unitId = (Request.QueryString["unitId"] ?? "").Trim();
            if (string.IsNullOrEmpty(unitId))
            {
                Response.Write("[]");
                Response.End();
                return;
            }

            try
            {
                var sb = new System.Text.StringBuilder("[");
                bool first = true;

                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand(
                        "SELECT [subtopicId],[subtopicTitleEN] FROM dbo.[Subtopic] WHERE [unitId]=@u ORDER BY [orderNo]", conn))
                    {
                        cmd.Parameters.AddWithValue("@u", unitId);
                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                if (!first) sb.Append(",");
                                first = false;

                                string id = reader["subtopicId"].ToString().Replace("\"", "\\\"");
                                string name = (reader["subtopicTitleEN"]?.ToString() ?? "").Replace("\"", "\\\"");
                                sb.Append("{\"id\":\"" + id + "\",\"name\":\"" + name + "\"}");
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

        /// <summary>
        /// AJAX handler: returns session summary as JSON for the summary modal.
        /// </summary>
        private void HandleSessionSummary()
        {
            Response.Clear();
            Response.ContentType = "application/json";

            string sessionId = (Request.QueryString["id"] ?? "").Trim();
            if (string.IsNullOrEmpty(sessionId) || Session["userId"] == null)
            {
                Response.Write("{\"error\":true}");
                Response.End();
                return;
            }

            try
            {
                string userId = Session["userId"].ToString();
                string teacherId = "";

                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand(
                        "SELECT [teacherId] FROM dbo.[Teacher] WHERE [userId]=@u AND [status]='Certified'", conn))
                    {
                        cmd.Parameters.AddWithValue("@u", userId);
                        teacherId = cmd.ExecuteScalar()?.ToString() ?? "";
                    }
                }

                if (string.IsNullOrEmpty(teacherId))
                {
                    Response.Write("{\"error\":true}");
                    Response.End();
                    return;
                }

                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    string title = "";
                    DateTime startTime = DateTime.Now, endTime = DateTime.Now;

                    using (var cmd = new SqlCommand(
                        @"SELECT [sessionTitle],[startDateTime],[endDateTime]
                          FROM dbo.[LiveConsultationSession]
                          WHERE [sessionId]=@id AND [teacherId]=@t AND [status]='Completed'", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", sessionId);
                        cmd.Parameters.AddWithValue("@t", teacherId);
                        using (var reader = cmd.ExecuteReader())
                        {
                            if (!reader.Read())
                            {
                                Response.Write("{\"error\":true}");
                                Response.End();
                                return;
                            }
                            title = reader["sessionTitle"]?.ToString() ?? "";
                            startTime = reader["startDateTime"] != DBNull.Value ? Convert.ToDateTime(reader["startDateTime"]) : DateTime.Now;
                            endTime = reader["endDateTime"] != DBNull.Value ? Convert.ToDateTime(reader["endDateTime"]) : DateTime.Now;
                        }
                    }

                    string durationText = FormatDuration(endTime - startTime);

                    // Build participants JSON array
                    var participantsJson = new System.Text.StringBuilder("[");
                    int studentCount = 0;
                    bool first = true;

                    using (var cmd = new SqlCommand(
                        @"SELECT DISTINCT s.[name], s.[nickname]
                          FROM dbo.[LiveSessionParticipant] p
                          LEFT JOIN dbo.[Student] s ON s.[studentId]=p.[studentId]
                          WHERE p.[sessionId]=@id
                          ORDER BY s.[name]", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", sessionId);
                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                string name = reader["name"]?.ToString() ?? reader["nickname"]?.ToString() ?? "Student";
                                string initials = GetInitials(name);

                                if (!first) participantsJson.Append(",");
                                first = false;
                                participantsJson.Append("{\"name\":\"" + name.Replace("\"", "\\\"") + "\",\"initials\":\"" + initials + "\"}");
                                studentCount++;
                            }
                        }
                    }
                    participantsJson.Append("]");

                    string json = "{\"title\":\"" + title.Replace("\"", "\\\"") + "\","
                        + "\"startTime\":\"" + startTime.ToString("h:mm tt") + "\","
                        + "\"endTime\":\"" + endTime.ToString("h:mm tt") + "\","
                        + "\"duration\":\"" + durationText + "\","
                        + "\"studentCount\":" + studentCount + ","
                        + "\"participants\":" + participantsJson.ToString() + "}";

                    Response.Write(json);
                }
            }
            catch { Response.Write("{\"error\":true}"); }

            Response.End();
        }

        #endregion
    }
}
