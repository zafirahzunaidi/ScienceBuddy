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
    public partial class LiveSessions1 : Page
    {
        private string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString; }
        }

        public string CurrentLanguage = "EN";

        public string T(string en, string bm)
        {
            if (CurrentLanguage == "BM")
            {
                return bm;
            }
            return en;
        }

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
                    using (SqlConnection connection = new SqlConnection(ConnStr))
                    using (SqlCommand command = new SqlCommand(sql, connection))
                    {
                        command.Parameters.AddWithValue("@userId", userId);
                        connection.Open();
                        object result = command.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            lang = result.ToString();
                            Session["preferredLanguage"] = lang;
                            CurrentLanguage = lang;
                            return;
                        }
                    }
                }
                catch (SqlException ex)
                {
                    System.Diagnostics.Debug.WriteLine("Database error: " + ex.Message);
                }
            }

            CurrentLanguage = "EN";
            Session["preferredLanguage"] = "EN";
        }

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

            string allClass = "st-livesessions-filter-btn";
            if (filter == "all")
            {
                allClass += " active";
            }
            btnFilterAll.CssClass = allClass;

            string upcomingClass = "st-livesessions-filter-btn";
            if (filter == "upcoming")
            {
                upcomingClass += " active";
            }
            btnFilterUpcoming.CssClass = upcomingClass;

            string ongoingClass = "st-livesessions-filter-btn";
            if (filter == "ongoing")
            {
                ongoingClass += " active";
            }
            btnFilterOngoing.CssClass = ongoingClass;

            string completedClass = "st-livesessions-filter-btn";
            if (filter == "completed")
            {
                completedClass += " active";
            }
            btnFilterCompleted.CssClass = completedClass;
        }

        private void LoadSessions()
        {
            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();

                if (!Tbl(connection, "LiveConsultationSession"))
                {
                    pnlGrid.Visible = false;
                    pnlEmpty.Visible = true;
                    litUpcoming.Text = "0";
                    litJoined.Text = "0";
                    litCompleted.Text = "0";
                    return;
                }

                string studentId = GetStudentId(connection);

                // Build query
                string sql = @"
                    SELECT  s.sessionId, s.sessionTitle, s.sessionDescription,
                            s.meetingLink, s.startDateTime, s.endDateTime, s.status,
                            t.name AS teacherName,
                            u.unitNameEN, u.unitNameBM,
                            st.subtopicTitleEN, st.subtopicTitleBM";

                if (!string.IsNullOrEmpty(studentId) && Tbl(connection, "LiveSessionParticipant"))
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

                if (!string.IsNullOrEmpty(studentId) && Tbl(connection, "LiveSessionParticipant"))
                {
                    sql += @"
                    LEFT JOIN LiveSessionParticipant lsp ON lsp.sessionId = s.sessionId AND lsp.studentId = @studentId";
                }

                sql += @"
                    ORDER BY s.startDateTime DESC";

                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    if (!string.IsNullOrEmpty(studentId))
                    {
                        command.Parameters.AddWithValue("@studentId", studentId);
                    }

                    SqlDataAdapter adapter = new SqlDataAdapter(command);
                    DataTable dataTable = new DataTable();
                    adapter.Fill(dataTable);

                    if (dataTable.Rows.Count == 0)
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

                    List<object> sessionList = new List<object>();

                    foreach (DataRow row in dataTable.Rows)
                    {
                        DateTime startDT = Convert.ToDateTime(row["startDateTime"]);
                        DateTime endDT = Convert.ToDateTime(row["endDateTime"]);

                        // Determine status
                        string status;
                        string statusBadgeClass;
                        if (startDT > now)
                        {
                            status = upcomingLabel;
                            statusBadgeClass = "st-livesessions-badge-upcoming";
                            countUpcoming++;
                        }
                        else if (startDT <= now && endDT >= now)
                        {
                            status = ongoingLabel;
                            statusBadgeClass = "st-livesessions-badge-ongoing";
                        }
                        else
                        {
                            status = completedLabel;
                            statusBadgeClass = "st-livesessions-badge-completed";
                            countCompleted++;
                        }

                        bool hasJoined = row["hasJoinedId"] != DBNull.Value &&
                                         !string.IsNullOrEmpty(row["hasJoinedId"].ToString());
                        if (hasJoined)
                        {
                            countJoined++;
                        }

                        // Apply filter
                        if (filter == "upcoming" && status != upcomingLabel)
                        {
                            continue;
                        }
                        if (filter == "ongoing" && status != ongoingLabel)
                        {
                            continue;
                        }
                        if (filter == "completed" && status != completedLabel)
                        {
                            continue;
                        }

                        // Build display fields
                        string title;
                        if (row["sessionTitle"] != DBNull.Value)
                        {
                            title = HttpUtility.HtmlEncode(row["sessionTitle"].ToString());
                        }
                        else
                        {
                            title = "";
                        }

                        string description = "";
                        if (row["sessionDescription"] != DBNull.Value)
                        {
                            string desc = row["sessionDescription"].ToString();
                            if (desc.Length > 100)
                            {
                                desc = desc.Substring(0, 100) + "...";
                            }
                            description = HttpUtility.HtmlEncode(desc);
                        }

                        string teacherName;
                        if (row["teacherName"] != DBNull.Value)
                        {
                            teacherName = HttpUtility.HtmlEncode(row["teacherName"].ToString());
                        }
                        else
                        {
                            teacherName = "";
                        }

                        string unitName;
                        if (isBM)
                        {
                            if (row["unitNameBM"] != DBNull.Value)
                            {
                                unitName = row["unitNameBM"].ToString();
                            }
                            else
                            {
                                string fallback = "";
                                if (row["unitNameEN"] != null && row["unitNameEN"] != DBNull.Value)
                                {
                                    fallback = row["unitNameEN"].ToString();
                                }
                                unitName = fallback;
                            }
                        }
                        else
                        {
                            if (row["unitNameEN"] != DBNull.Value)
                            {
                                unitName = row["unitNameEN"].ToString();
                            }
                            else
                            {
                                unitName = "";
                            }
                        }
                        unitName = HttpUtility.HtmlEncode(unitName);

                        string subtopicName;
                        if (isBM)
                        {
                            if (row["subtopicTitleBM"] != DBNull.Value)
                            {
                                subtopicName = row["subtopicTitleBM"].ToString();
                            }
                            else
                            {
                                string fallback = "";
                                if (row["subtopicTitleEN"] != null && row["subtopicTitleEN"] != DBNull.Value)
                                {
                                    fallback = row["subtopicTitleEN"].ToString();
                                }
                                subtopicName = fallback;
                            }
                        }
                        else
                        {
                            if (row["subtopicTitleEN"] != DBNull.Value)
                            {
                                subtopicName = row["subtopicTitleEN"].ToString();
                            }
                            else
                            {
                                subtopicName = "";
                            }
                        }
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

        // Filter click handlers
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

        // Repeater item command (Join Session)
        protected void rptSessions_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "Join")
            {
                return;
            }

            string sessionId = e.CommandArgument.ToString();

            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();

                string studentId = GetStudentId(connection);
                if (string.IsNullOrEmpty(studentId))
                {
                    return;
                }

                // Check if participant already exists
                const string sqlCheck = @"
                    SELECT COUNT(*) FROM LiveSessionParticipant
                    WHERE  sessionId = @sessionId AND studentId = @studentId";

                bool exists = false;
                using (SqlCommand command = new SqlCommand(sqlCheck, connection))
                {
                    command.Parameters.AddWithValue("@sessionId", sessionId);
                    command.Parameters.AddWithValue("@studentId", studentId);
                    exists = (int)command.ExecuteScalar() > 0;
                }

                DateTime now = DateTime.Now;

                if (!exists)
                {
                    // Insert new participant
                    string participantId = "LSP" + now.ToString("yyyyMMddHHmmss");
                    const string sqlInsert = @"
                        INSERT INTO LiveSessionParticipant(participantId, sessionId, studentId, joinedAt)
                        VALUES(@pid, @sid, @stid, @now)";
                    using (SqlCommand command = new SqlCommand(sqlInsert, connection))
                    {
                        command.Parameters.AddWithValue("@pid", participantId);
                        command.Parameters.AddWithValue("@sid", sessionId);
                        command.Parameters.AddWithValue("@stid", studentId);
                        command.Parameters.AddWithValue("@now", now);
                        command.ExecuteNonQuery();
                    }
                }
                else
                {
                    // Update joinedAt
                    const string sqlUpdate = @"
                        UPDATE LiveSessionParticipant SET joinedAt = @now
                        WHERE  sessionId = @sessionId AND studentId = @studentId";
                    using (SqlCommand command = new SqlCommand(sqlUpdate, connection))
                    {
                        command.Parameters.AddWithValue("@now", now);
                        command.Parameters.AddWithValue("@sessionId", sessionId);
                        command.Parameters.AddWithValue("@studentId", studentId);
                        command.ExecuteNonQuery();
                    }
                }

                // Get meeting link
                const string sqlLink = "SELECT meetingLink FROM LiveConsultationSession WHERE sessionId = @sessionId";
                string meetingLink = "";
                using (SqlCommand command = new SqlCommand(sqlLink, connection))
                {
                    command.Parameters.AddWithValue("@sessionId", sessionId);
                    object result = command.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        meetingLink = result.ToString();
                    }
                }

                // Get student display name for the call
                const string sqlName = "SELECT name, nickname FROM Student WHERE studentId = @studentId";
                string displayName = "Student";
                using (SqlCommand cmdName = new SqlCommand(sqlName, connection))
                {
                    cmdName.Parameters.AddWithValue("@studentId", studentId);
                    using (SqlDataReader reader = cmdName.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string name = reader["name"].ToString();
                            string nickname = reader["nickname"] == DBNull.Value ? "" : reader["nickname"].ToString();
                            displayName = string.IsNullOrEmpty(nickname) ? name : nickname;
                        }
                    }
                }

                // Build a unique, safe room name from the session ID
                string roomName = "ScienceBuddy-" + sessionId;

                hidRoomName.Value = roomName;
                hidDisplayName.Value = HttpUtility.HtmlEncode(displayName);
                litRoomTitle.Text = "Live Session";

                pnlGrid.Visible = false;
                pnlJoinedRoom.Visible = true;
            }

        }
        protected void btnLeaveRoom_Click(object sender, EventArgs e)
        {
            pnlJoinedRoom.Visible = false;
            pnlGrid.Visible = true;
            InitLang();
            SetLabels();
            LoadSessions();
        }

        // Get studentId for the logged-in user
        private string GetStudentId(SqlConnection conn)
        {
            if (!Tbl(conn, "Student"))
            {
                return null;
            }

            string userId = Session["userId"] as string;
            if (string.IsNullOrEmpty(userId))
            {
                return null;
            }

            const string sql = "SELECT studentId FROM Student WHERE userId = @userId";
            using (SqlCommand command = new SqlCommand(sql, conn))
            {
                command.Parameters.AddWithValue("@userId", userId);
                object result = command.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                {
                    return result.ToString();
                }
                else
                {
                    return null;
                }
            }
        }

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
            using (SqlCommand command = new SqlCommand(sql, conn))
            {
                command.Parameters.AddWithValue("@tableName", tableName);
                return (int)command.ExecuteScalar() > 0;
            }
        }

    }
}
