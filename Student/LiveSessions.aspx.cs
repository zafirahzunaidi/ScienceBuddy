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
                    string getReminderLabel = T("Remind Me", "Ingatkan");
                    string reminderSentLabel = T("Sent", "Dihantar");

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
                            CompletedLabel = completedLabel,
                            UpcomingLabel = upcomingLabel,
                            GetReminderLabel = getReminderLabel,
                            ReminderSentLabel = reminderSentLabel
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
            if (e.CommandName == "Reminder")
            {
                HandleReminder(e.CommandArgument.ToString());
                return;
            }

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
                    string participantId = "LIVEP001";
                    using (SqlCommand seqCmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING(participantId,6,LEN(participantId)-5) AS INT)),0) FROM LiveSessionParticipant WHERE participantId LIKE 'LIVEP[0-9]%'", connection))
                    {
                        participantId = "LIVEP" + (Convert.ToInt32(seqCmd.ExecuteScalar()) + 1).ToString("D3");
                    }
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

                    // Award XP for attending live session (XP008) â€” first join only
                    AwardSessionXp(connection, studentId);
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

        // â”€â”€ Handle Reminder (register + send email) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        private void HandleReminder(string sessionId)
        {
            InitLang();
            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();

                string studentId = GetStudentId(connection);
                if (string.IsNullOrEmpty(studentId)) return;

                // Register as participant if not already
                bool exists = false;
                if (Tbl(connection, "LiveSessionParticipant"))
                {
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM LiveSessionParticipant WHERE sessionId=@sid AND studentId=@stid", connection))
                    {
                        cmd.Parameters.AddWithValue("@sid", sessionId);
                        cmd.Parameters.AddWithValue("@stid", studentId);
                        exists = (int)cmd.ExecuteScalar() > 0;
                    }

                    if (!exists)
                    {
                        string participantId = "LIVEP001";
                        using (SqlCommand seqCmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING(participantId,6,LEN(participantId)-5) AS INT)),0) FROM LiveSessionParticipant WHERE participantId LIKE 'LIVEP[0-9]%'", connection))
                        {
                            participantId = "LIVEP" + (Convert.ToInt32(seqCmd.ExecuteScalar()) + 1).ToString("D3");
                        }
                        using (SqlCommand cmd = new SqlCommand("INSERT INTO LiveSessionParticipant(participantId,sessionId,studentId,joinedAt) VALUES(@pid,@sid,@stid,@now)", connection))
                        {
                            cmd.Parameters.AddWithValue("@pid", participantId);
                            cmd.Parameters.AddWithValue("@sid", sessionId);
                            cmd.Parameters.AddWithValue("@stid", studentId);
                            cmd.Parameters.AddWithValue("@now", DateTime.Now);
                            cmd.ExecuteNonQuery();
                        }
                    }
                }

                // Get session details for email
                string title = "", teacherName = "", meetingLink = "";
                DateTime startDT = DateTime.Now, endDT = DateTime.Now;

                const string sessSql = @"SELECT s.sessionTitle, s.meetingLink, s.startDateTime, s.endDateTime, t.name AS teacherName
                    FROM LiveConsultationSession s LEFT JOIN Teacher t ON t.teacherId=s.teacherId
                    WHERE s.sessionId=@sid";
                using (SqlCommand cmd = new SqlCommand(sessSql, connection))
                {
                    cmd.Parameters.AddWithValue("@sid", sessionId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            title = reader["sessionTitle"] != DBNull.Value ? reader["sessionTitle"].ToString() : "";
                            teacherName = reader["teacherName"] != DBNull.Value ? reader["teacherName"].ToString() : "";
                            meetingLink = reader["meetingLink"] != DBNull.Value ? reader["meetingLink"].ToString() : "";
                            startDT = Convert.ToDateTime(reader["startDateTime"]);
                            endDT = Convert.ToDateTime(reader["endDateTime"]);
                        }
                    }
                }

                // Get student email
                string userId = Session["userId"].ToString();
                string studentEmail = "";
                using (SqlCommand cmd = new SqlCommand("SELECT email FROM [User] WHERE userId=@uid", connection))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                        studentEmail = result.ToString();
                }

                // Send reminder email
                if (!string.IsNullOrEmpty(studentEmail))
                {
                    SendReminderEmail(studentEmail, title, teacherName, startDT, endDT, meetingLink);
                }
            }

            // Reload page
            SetLabels();
            LoadSessions();
        }

        private void SendReminderEmail(string toEmail, string sessionTitle, string teacherName,
            DateTime startDT, DateTime endDT, string meetingLink)
        {
            try
            {
                string smtpHost = ConfigurationManager.AppSettings["SmtpHost"];
                int smtpPort = int.Parse(ConfigurationManager.AppSettings["SmtpPort"] ?? "587");
                string smtpUser = ConfigurationManager.AppSettings["SmtpUsername"];
                string smtpPass = ConfigurationManager.AppSettings["SmtpPassword"];
                bool smtpSsl = ConfigurationManager.AppSettings["SmtpEnableSsl"] == "true";

                string subject = T("Reminder: Live Session - ", "Peringatan: Sesi Langsung - ") + sessionTitle;

                string body = T("Hi! Here is your live session reminder:\n\n", "Hai! Berikut ialah peringatan sesi langsung anda:\n\n");
                body += T("Session: ", "Sesi: ") + sessionTitle + "\n";
                body += T("Teacher: ", "Guru: ") + teacherName + "\n";
                body += T("Date: ", "Tarikh: ") + startDT.ToString("dd MMM yyyy") + "\n";
                body += T("Time: ", "Masa: ") + startDT.ToString("hh:mm tt") + " - " + endDT.ToString("hh:mm tt") + "\n";
                if (!string.IsNullOrEmpty(meetingLink))
                    body += T("Meeting Link: ", "Pautan Mesyuarat: ") + meetingLink + "\n";
                body += "\n" + T("Don't forget to join on time. See you there!", "Jangan lupa untuk menyertai tepat pada waktunya. Jumpa di sana!");
                body += "\n\n- ScienceBuddy";

                using (var mail = new System.Net.Mail.MailMessage())
                {
                    mail.From = new System.Net.Mail.MailAddress(smtpUser, "ScienceBuddy");
                    mail.To.Add(toEmail);
                    mail.Subject = subject;
                    mail.Body = body;
                    mail.IsBodyHtml = false;

                    using (var smtp = new System.Net.Mail.SmtpClient(smtpHost, smtpPort))
                    {
                        smtp.Credentials = new System.Net.NetworkCredential(smtpUser, smtpPass);
                        smtp.EnableSsl = smtpSsl;
                        smtp.Send(mail);
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Email error: " + ex.Message);
            }
        }

        // Award XP for attending live session (XP008)
        private void AwardSessionXp(SqlConnection conn, string studentId)
        {
            try
            {
                if (!Tbl(conn, "XPAction") || !Tbl(conn, "XPTransaction")) return;

                int xpAmount = 0;
                using (SqlCommand cmd = new SqlCommand("SELECT xpValue FROM XPAction WHERE xpActionId='XP008'", conn))
                {
                    object r = cmd.ExecuteScalar();
                    if (r != null && r != DBNull.Value) xpAmount = Convert.ToInt32(r);
                }
                if (xpAmount <= 0) return;

                string xtId = "XPT001";
                using (SqlCommand cmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING(xpTransactionId,4,LEN(xpTransactionId)-3) AS INT)),0) FROM XPTransaction WHERE xpTransactionId LIKE 'XPT[0-9]%'", conn))
                {
                    xtId = "XPT" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3");
                }

                using (SqlCommand cmd = new SqlCommand("INSERT INTO XPTransaction(xpTransactionId,studentId,xpActionId,xpAmount,dateEarned) VALUES(@id,@s,@a,@xp,@dt)", conn))
                {
                    cmd.Parameters.AddWithValue("@id", xtId);
                    cmd.Parameters.AddWithValue("@s", studentId);
                    cmd.Parameters.AddWithValue("@a", "XP008");
                    cmd.Parameters.AddWithValue("@xp", xpAmount);
                    cmd.Parameters.AddWithValue("@dt", DateTime.Today);
                    cmd.ExecuteNonQuery();
                }

                using (SqlCommand cmd = new SqlCommand("UPDATE Student SET XP=ISNULL(XP,0)+@xp WHERE studentId=@s", conn))
                {
                    cmd.Parameters.AddWithValue("@xp", xpAmount);
                    cmd.Parameters.AddWithValue("@s", studentId);
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Session XP error: " + ex.Message);
            }
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

