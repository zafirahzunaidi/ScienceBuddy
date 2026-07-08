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
    public partial class LiveSessions : Page
    {
        // ── Connection string ─────────────────────────────────────────
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        // ── Language helper ────────────────────────────────────────────
        public string CurrentLanguage = "EN";

        public string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        // ── Page Load ─────────────────────────────────────────────────
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null ||
                Session["role"].ToString() != "Student")
            {
                Response.Redirect("~/Login.aspx", false);
                return;
            }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                InitLang();
                SetLabels();
                LoadSessions();
            }
        }

        // ── Language initialisation ───────────────────────────────────
        private void InitLang()
        {
            string lang = Session["preferredLanguage"] as string;
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
                    using (var conn = new SqlConnection(ConnStr))
                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@userId", userId);
                        conn.Open();
                        object result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            lang = result.ToString();
                            Session["preferredLanguage"] = lang;
                            CurrentLanguage = lang;
                            return;
                        }
                    }
                }
                catch (SqlException) { }
            }

            CurrentLanguage = "EN";
            Session["preferredLanguage"] = "EN";
        }

        // ── Set bilingual labels ──────────────────────────────────────
        private void SetLabels()
        {
            litPageTitle.Text = T("Live Sessions", "Sesi Langsung");
            litTitle.Text = T("Live Sessions", "Sesi Langsung");
            litSubtitle.Text = T("Join teacher-led learning sessions and ask questions in real time.",
                                 "Sertai sesi pembelajaran bersama guru dan tanya soalan secara langsung.");

            litUpcomingLbl.Text = T("Upcoming Sessions", "Sesi Akan Datang");
            litJoinedLbl.Text = T("Joined Sessions", "Sesi Disertai");
            litCompletedLbl.Text = T("Completed Sessions", "Sesi Selesai");

            btnFilterAll.Text = T("All", "Semua");
            btnFilterUpcoming.Text = T("Upcoming", "Akan Datang");
            btnFilterOngoing.Text = T("Ongoing", "Sedang Berlangsung");
            btnFilterCompleted.Text = T("Completed", "Selesai");

            litEmptyTitle.Text = T("No live sessions available",
                                   "Tiada sesi langsung tersedia");
            litEmptyDesc.Text = T("No live sessions are available yet.",
                                  "Tiada sesi langsung tersedia buat masa ini.");
            litEmptyBtn.Text = T("Back to Dashboard", "Kembali ke Papan Pemuka");

            // Highlight active filter tab
            string filter = hfFilter.Value;
            btnFilterAll.CssClass = "lss-filter-btn" + (filter == "all" ? " active" : "");
            btnFilterUpcoming.CssClass = "lss-filter-btn" + (filter == "upcoming" ? " active" : "");
            btnFilterOngoing.CssClass = "lss-filter-btn" + (filter == "ongoing" ? " active" : "");
            btnFilterCompleted.CssClass = "lss-filter-btn" + (filter == "completed" ? " active" : "");
        }

        // ── Load session cards ────────────────────────────────────────
        private void LoadSessions()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                if (!Tbl(conn, "LiveConsultationSession"))
                {
                    pnlGrid.Visible = false;
                    pnlEmpty.Visible = true;
                    litUpcoming.Text = "0";
                    litJoined.Text = "0";
                    litCompleted.Text = "0";
                    return;
                }

                string studentId = GetStudentId(conn);

                // Build query
                string sql = @"
                    SELECT  s.sessionId, s.sessionTitle, s.sessionDescription,
                            s.meetingLink, s.startDateTime, s.endDateTime, s.status,
                            t.name AS teacherName,
                            u.unitNameEN, u.unitNameBM,
                            st.subtopicTitleEN, st.subtopicTitleBM";

                if (!string.IsNullOrEmpty(studentId) && Tbl(conn, "LiveSessionParticipant"))
                {
                    sql += @",
                            lsp.participantId AS hasJoinedId";
                }
                else
                {
                    sql += @",
                            NULL AS hasJoinedId";
                }

                sql += @"
                    FROM    LiveConsultationSession s
                    LEFT JOIN Teacher t ON t.teacherId = s.teacherId
                    LEFT JOIN Unit u ON u.unitId = s.unitId
                    LEFT JOIN Subtopic st ON st.subtopicId = s.subtopicId";

                if (!string.IsNullOrEmpty(studentId) && Tbl(conn, "LiveSessionParticipant"))
                {
                    sql += @"
                    LEFT JOIN LiveSessionParticipant lsp ON lsp.sessionId = s.sessionId AND lsp.studentId = @studentId";
                }

                sql += @"
                    ORDER BY s.startDateTime DESC";

                using (var cmd = new SqlCommand(sql, conn))
                {
                    if (!string.IsNullOrEmpty(studentId))
                        cmd.Parameters.AddWithValue("@studentId", studentId);

                    var da = new SqlDataAdapter(cmd);
                    var dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count == 0)
                    {
                        pnlGrid.Visible = false;
                        pnlEmpty.Visible = true;
                        litUpcoming.Text = "0";
                        litJoined.Text = "0";
                        litCompleted.Text = "0";
                        return;
                    }

                    pnlGrid.Visible = true;
                    pnlEmpty.Visible = false;

                    bool isBM = CurrentLanguage == "BM";
                    DateTime now = DateTime.Now;

                    string joinBtnText = T("Join Session", "Sertai Sesi");
                    string viewDetailsText = T("View Details", "Lihat Butiran");
                    string noLinkText = T("No Link Available", "Tiada Pautan");
                    string joinedLabel = T("Joined", "Disertai");
                    string notJoinedLabel = T("Not Joined", "Belum Disertai");
                    string upcomingLabel = T("Upcoming", "Akan Datang");
                    string ongoingLabel = T("Ongoing", "Sedang Berlangsung");
                    string completedLabel = T("Completed", "Selesai");

                    int countUpcoming = 0, countJoined = 0, countCompleted = 0;
                    string filter = hfFilter.Value;

                    var sessionList = new List<object>();

                    foreach (DataRow row in dt.Rows)
                    {
                        DateTime startDT = Convert.ToDateTime(row["startDateTime"]);
                        DateTime endDT = Convert.ToDateTime(row["endDateTime"]);

                        // Determine status
                        string status;
                        string statusBadgeClass;
                        if (startDT > now)
                        {
                            status = upcomingLabel;
                            statusBadgeClass = "lss-badge-upcoming";
                            countUpcoming++;
                        }
                        else if (startDT <= now && endDT >= now)
                        {
                            status = ongoingLabel;
                            statusBadgeClass = "lss-badge-ongoing";
                        }
                        else
                        {
                            status = completedLabel;
                            statusBadgeClass = "lss-badge-completed";
                            countCompleted++;
                        }

                        bool hasJoined = row["hasJoinedId"] != DBNull.Value &&
                                         !string.IsNullOrEmpty(row["hasJoinedId"].ToString());
                        if (hasJoined) countJoined++;

                        // Apply filter
                        if (filter == "upcoming" && status != upcomingLabel) continue;
                        if (filter == "ongoing" && status != ongoingLabel) continue;
                        if (filter == "completed" && status != completedLabel) continue;

                        // Build display fields
                        string title = row["sessionTitle"] != DBNull.Value
                            ? HttpUtility.HtmlEncode(row["sessionTitle"].ToString()) : "";

                        string description = "";
                        if (row["sessionDescription"] != DBNull.Value)
                        {
                            string desc = row["sessionDescription"].ToString();
                            if (desc.Length > 100)
                                desc = desc.Substring(0, 100) + "...";
                            description = HttpUtility.HtmlEncode(desc);
                        }

                        string teacherName = row["teacherName"] != DBNull.Value
                            ? HttpUtility.HtmlEncode(row["teacherName"].ToString()) : "";

                        string unitName = isBM
                            ? (row["unitNameBM"] != DBNull.Value ? row["unitNameBM"].ToString() : row["unitNameEN"]?.ToString() ?? "")
                            : (row["unitNameEN"] != DBNull.Value ? row["unitNameEN"].ToString() : "");
                        unitName = HttpUtility.HtmlEncode(unitName);

                        string subtopicName = isBM
                            ? (row["subtopicTitleBM"] != DBNull.Value ? row["subtopicTitleBM"].ToString() : row["subtopicTitleEN"]?.ToString() ?? "")
                            : (row["subtopicTitleEN"] != DBNull.Value ? row["subtopicTitleEN"].ToString() : "");
                        subtopicName = HttpUtility.HtmlEncode(subtopicName);

                        string dateFormatted = startDT.ToString("dd MMM yyyy");
                        string timeFormatted = startDT.ToString("hh:mm tt") + " - " + endDT.ToString("hh:mm tt");

                        bool hasLink = row["meetingLink"] != DBNull.Value &&
                                       !string.IsNullOrEmpty(row["meetingLink"].ToString());

                        string sessionId = row["sessionId"].ToString();

                        sessionList.Add(new
                        {
                            Title = title,
                            Description = description,
                            TeacherName = teacherName,
                            Unit = unitName,
                            Subtopic = subtopicName,
                            Date = dateFormatted,
                            Time = timeFormatted,
                            Status = status,
                            StatusBadgeClass = statusBadgeClass,
                            HasJoined = hasJoined,
                            HasLink = hasLink,
                            SessionId = sessionId,
                            JoinBtnText = joinBtnText,
                            ViewDetailsText = viewDetailsText,
                            NoLinkText = noLinkText,
                            JoinedLabel = joinedLabel,
                            NotJoinedLabel = notJoinedLabel,
                            CompletedLabel = completedLabel
                        });
                    }

                    // Update summary counts
                    litUpcoming.Text = countUpcoming.ToString();
                    litJoined.Text = countJoined.ToString();
                    litCompleted.Text = countCompleted.ToString();

                    if (sessionList.Count == 0)
                    {
                        pnlGrid.Visible = false;
                        pnlEmpty.Visible = true;
                    }
                    else
                    {
                        rptSessions.DataSource = sessionList;
                        rptSessions.DataBind();
                    }
                }
            }
        }

        // ── Filter click handlers ─────────────────────────────────────
        protected void btnFilterAll_Click(object sender, EventArgs e)
        {
            hfFilter.Value = "all";
            InitLang();
            SetLabels();
            LoadSessions();
        }

        protected void btnFilterUpcoming_Click(object sender, EventArgs e)
        {
            hfFilter.Value = "upcoming";
            InitLang();
            SetLabels();
            LoadSessions();
        }

        protected void btnFilterOngoing_Click(object sender, EventArgs e)
        {
            hfFilter.Value = "ongoing";
            InitLang();
            SetLabels();
            LoadSessions();
        }

        protected void btnFilterCompleted_Click(object sender, EventArgs e)
        {
            hfFilter.Value = "completed";
            InitLang();
            SetLabels();
            LoadSessions();
        }

        // ── Repeater item command (Join Session) ──────────────────────
        protected void rptSessions_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "Join") return;

            string sessionId = e.CommandArgument.ToString();

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                string studentId = GetStudentId(conn);
                if (string.IsNullOrEmpty(studentId)) return;

                // Check if participant already exists
                const string sqlCheck = @"
                    SELECT COUNT(*) FROM LiveSessionParticipant
                    WHERE  sessionId = @sessionId AND studentId = @studentId";

                bool exists = false;
                using (var cmd = new SqlCommand(sqlCheck, conn))
                {
                    cmd.Parameters.AddWithValue("@sessionId", sessionId);
                    cmd.Parameters.AddWithValue("@studentId", studentId);
                    exists = (int)cmd.ExecuteScalar() > 0;
                }

                DateTime now = DateTime.Now;

                if (!exists)
                {
                    // Insert new participant
                    string participantId = "LSP" + now.ToString("yyyyMMddHHmmss");
                    const string sqlInsert = @"
                        INSERT INTO LiveSessionParticipant(participantId, sessionId, studentId, joinedAt)
                        VALUES(@pid, @sid, @stid, @now)";
                    using (var cmd = new SqlCommand(sqlInsert, conn))
                    {
                        cmd.Parameters.AddWithValue("@pid", participantId);
                        cmd.Parameters.AddWithValue("@sid", sessionId);
                        cmd.Parameters.AddWithValue("@stid", studentId);
                        cmd.Parameters.AddWithValue("@now", now);
                        cmd.ExecuteNonQuery();
                    }
                }
                else
                {
                    // Update joinedAt
                    const string sqlUpdate = @"
                        UPDATE LiveSessionParticipant SET joinedAt = @now
                        WHERE  sessionId = @sessionId AND studentId = @studentId";
                    using (var cmd = new SqlCommand(sqlUpdate, conn))
                    {
                        cmd.Parameters.AddWithValue("@now", now);
                        cmd.Parameters.AddWithValue("@sessionId", sessionId);
                        cmd.Parameters.AddWithValue("@studentId", studentId);
                        cmd.ExecuteNonQuery();
                    }
                }

                // Get meeting link
                const string sqlLink = "SELECT meetingLink FROM LiveConsultationSession WHERE sessionId = @sessionId";
                string meetingLink = "";
                using (var cmd = new SqlCommand(sqlLink, conn))
                {
                    cmd.Parameters.AddWithValue("@sessionId", sessionId);
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                        meetingLink = result.ToString();
                }

                // Open meeting link in new tab
                if (!string.IsNullOrEmpty(meetingLink))
                {
                    string script = "window.open('" + meetingLink.Replace("'", "\\'") + "', '_blank');";
                    ClientScript.RegisterStartupScript(this.GetType(), "openMeeting", script, true);
                }
            }

            // Reload sessions
            InitLang();
            SetLabels();
            LoadSessions();
        }

        // ── Get studentId for the logged-in user ──────────────────────
        private string GetStudentId(SqlConnection conn)
        {
            if (!Tbl(conn, "Student")) return null;
            string userId = Session["userId"] as string;
            if (string.IsNullOrEmpty(userId)) return null;

            const string sql = "SELECT studentId FROM Student WHERE userId = @userId";
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                object result = cmd.ExecuteScalar();
                return result != null && result != DBNull.Value ? result.ToString() : null;
            }
        }

        // ── Table exists helper ───────────────────────────────────────
        /// <summary>
        /// Returns true if the given table exists in the current database.
        /// Uses INFORMATION_SCHEMA so it never throws on a missing table.
        /// </summary>
        private static bool Tbl(SqlConnection conn, string tableName)
        {
            const string sql = @"
                SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
                WHERE  TABLE_NAME = @tableName
                AND    TABLE_TYPE = 'BASE TABLE'";
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@tableName", tableName);
                return (int)cmd.ExecuteScalar() > 0;
            }
        }
    }
}
