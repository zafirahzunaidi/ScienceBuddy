using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.Services;
using System.Web.UI;

namespace ScienceBuddy.Teacher
{
    public partial class Dashboard : Page
    {
        #region Properties

        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

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
                string userId = Session["userId"].ToString();
                LoadTeacherDashboard(userId);
            }
        }

        #endregion

        #region Data Loading

        private void LoadTeacherDashboard(string userId)
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    string teacherId = null;
                    string teacherName = null;
                    string teacherStatus = null;

                    using (var cmd = new SqlCommand(
                        @"SELECT [teacherId], [name], [status]
                          FROM dbo.[Teacher]
                          WHERE [userId] = @userId", conn))
                    {
                        cmd.Parameters.AddWithValue("@userId", userId);

                        using (var reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                teacherId = reader["teacherId"]?.ToString();
                                teacherName = reader["name"]?.ToString();
                                teacherStatus = reader["status"]?.ToString();
                            }
                        }
                    }

                    if (string.IsNullOrEmpty(teacherId))
                    {
                        pnlDenied.Visible = true;
                        return;
                    }

                    if (!string.Equals(teacherStatus, "Certified", StringComparison.OrdinalIgnoreCase))
                    {
                        HandleNonCertifiedStatus(teacherStatus);
                        return;
                    }

                    // Teacher is Certified — show full dashboard
                    pnlDashboard.Visible = true;

                    string displayName = !string.IsNullOrWhiteSpace(teacherName) ? teacherName : "Teacher";
                    litTeacherName.Text = HttpUtility.HtmlEncode(displayName);

                    SetMasterUserInfo(teacherName);
                    LoadSummaryCounts(conn, userId, teacherId);
                    LoadQuizContribution(conn, userId);
                    LoadTimelineSessions(conn, teacherId);
                    LoadDashboardNotifications(conn, userId);
                    LoadPracticeQuizEngagement(conn, userId);
                }
            }
            catch
            {
                pnlDashboard.Visible = true;
                litTeacherName.Text = "Teacher";
            }
        }

        private void LoadSummaryCounts(SqlConnection conn, string userId, string teacherId)
        {
            litTotalLessons.Text = SafeCount(conn,
                "SELECT COUNT(*) FROM dbo.[Material] WHERE [createdByUserId] = @p",
                "@p", userId).ToString();

            litTotalQuizzes.Text = SafeCount(conn,
                "SELECT COUNT(*) FROM dbo.[Quiz] WHERE [createdByUserId] = @p",
                "@p", userId).ToString();

            litUpcomingSessions.Text = SafeCount(conn,
                @"SELECT COUNT(*) FROM dbo.[LiveConsultationSession]
                  WHERE [teacherId] = @p AND [startDateTime] > GETDATE()",
                "@p", teacherId).ToString();

            litTotalStudents.Text = SafeCount(conn,
                @"SELECT COUNT(DISTINCT lsp.[studentId])
                  FROM dbo.[LiveSessionParticipant] lsp
                  INNER JOIN dbo.[LiveConsultationSession] lcs
                    ON lcs.[sessionId] = lsp.[sessionId]
                  WHERE lcs.[teacherId] = @p",
                "@p", teacherId).ToString();
        }

        /// <summary>
        /// Loads the teacher's quiz contribution stats (approved questions for Unit and Level quizzes).
        /// </summary>
        private void LoadQuizContribution(SqlConnection conn, string userId)
        {
            try
            {
                int myUnitCount = GetApprovedQuestionCount(conn, userId, "Unit");
                int totalUnitCount = GetTotalApprovedQuestionCount(conn, "Unit");

                litUnitMyCount.Text = myUnitCount.ToString();
                litUnitTotal.Text = totalUnitCount.ToString();
                hidUnitPct.Value = CalculatePercentage(myUnitCount, totalUnitCount).ToString();

                int myLevelCount = GetApprovedQuestionCount(conn, userId, "Level");
                int totalLevelCount = GetTotalApprovedQuestionCount(conn, "Level");

                litLevelMyCount.Text = myLevelCount.ToString();
                litLevelTotal.Text = totalLevelCount.ToString();
                hidLevelPct.Value = CalculatePercentage(myLevelCount, totalLevelCount).ToString();
            }
            catch
            {
                litUnitMyCount.Text = "0";
                litUnitTotal.Text = "0";
                hidUnitPct.Value = "0";
                litLevelMyCount.Text = "0";
                litLevelTotal.Text = "0";
                hidLevelPct.Value = "0";
            }
        }

        /// <summary>
        /// Loads upcoming live sessions for the timeline card (top 3 future sessions).
        /// </summary>
        private void LoadTimelineSessions(SqlConnection conn, string teacherId)
        {
            const string sql = @"
                SELECT TOP 3
                    lcs.[sessionTitle], lcs.[startDateTime], lcs.[endDateTime],
                    ISNULL(st.[subtopicTitleEN],'') AS subtopicName
                FROM dbo.[LiveConsultationSession] lcs
                LEFT JOIN dbo.[Subtopic] st ON st.[subtopicId] = lcs.[subtopicId]
                WHERE lcs.[teacherId] = @tid AND lcs.[endDateTime] > GETDATE()
                ORDER BY lcs.[startDateTime] ASC";

            var sessions = new List<object>();

            try
            {
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@tid", teacherId);

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            DateTime startTime = reader["startDateTime"] != DBNull.Value
                                ? Convert.ToDateTime(reader["startDateTime"]) : DateTime.Now;
                            DateTime endTime = reader["endDateTime"] != DBNull.Value
                                ? Convert.ToDateTime(reader["endDateTime"]) : DateTime.Now;
                            string sessionTitle = reader["sessionTitle"]?.ToString() ?? "";
                            string subtopicName = reader["subtopicName"]?.ToString() ?? "";

                            string dotCss, badgeCss, btnCss, statusLabel, btnLabel;
                            DetermineSessionStatus(startTime, endTime,
                                out dotCss, out badgeCss, out btnCss, out statusLabel, out btnLabel);

                            sessions.Add(new
                            {
                                title = sessionTitle,
                                topic = subtopicName,
                                friendlyDate = FormatFriendlyDate(startTime),
                                dotCss,
                                badgeCss,
                                btnCss,
                                statusLabel,
                                btnLabel
                            });
                        }
                    }
                }
            }
            catch { }

            if (sessions.Count > 0)
            {
                pnlTimelineSessions.Visible = true;
                pnlTimelineEmpty.Visible = false;
                rptTimelineSessions.DataSource = sessions;
                rptTimelineSessions.DataBind();
            }
            else
            {
                pnlTimelineSessions.Visible = false;
                pnlTimelineEmpty.Visible = true;
            }
        }

        /// <summary>
        /// Loads the 4 most recent notifications for the dashboard card.
        /// </summary>
        private void LoadDashboardNotifications(SqlConnection conn, string userId)
        {
            const string sql = @"
                SELECT TOP 4
                    [titleEN], [titleBM], [messageEN], [messageBM], [isRead], [createdAt]
                FROM dbo.[Notification]
                WHERE [toUserId] = @uid
                ORDER BY [createdAt] DESC";

            var notifications = new List<object>();

            try
            {
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string title = CurrentLanguage == "BM"
                                ? (reader["titleBM"]?.ToString() ?? reader["titleEN"]?.ToString() ?? "")
                                : (reader["titleEN"]?.ToString() ?? "");

                            string message = CurrentLanguage == "BM"
                                ? (reader["messageBM"]?.ToString() ?? reader["messageEN"]?.ToString() ?? "")
                                : (reader["messageEN"]?.ToString() ?? "");

                            bool isRead = reader["isRead"] != DBNull.Value && Convert.ToBoolean(reader["isRead"]);
                            DateTime createdAt = reader["createdAt"] != DBNull.Value
                                ? Convert.ToDateTime(reader["createdAt"]) : DateTime.Now;

                            notifications.Add(new
                            {
                                title,
                                message = message.Length > 80 ? message.Substring(0, 80) + "…" : message,
                                isRead,
                                timeAgo = FormatTimeAgo(createdAt)
                            });
                        }
                    }
                }
            }
            catch { }

            if (notifications.Count > 0)
            {
                pnlDashNotifs.Visible = true;
                pnlDashNotifsEmpty.Visible = false;
                rptDashNotifs.DataSource = notifications;
                rptDashNotifs.DataBind();
            }
            else
            {
                pnlDashNotifs.Visible = false;
                pnlDashNotifsEmpty.Visible = true;
            }
        }

        /// <summary>
        /// Loads approved practice quizzes with engagement stats (students attempted, avg score).
        /// </summary>
        private void LoadPracticeQuizEngagement(SqlConnection conn, string userId)
        {
            try
            {
                const string sql = @"
                    SELECT [quizId], [quizTitleEN], [quizTitleBM], [language],
                           [levelId], [unitId], [status]
                    FROM dbo.[Quiz]
                    WHERE [createdByUserId] = @userId
                      AND [quizType] = 'Practice'
                      AND [status] = 'Approved'
                    ORDER BY [quizId] DESC";

                var quizRecords = new List<Dictionary<string, string>>();

                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            quizRecords.Add(new Dictionary<string, string>
                            {
                                ["quizId"] = reader["quizId"]?.ToString() ?? "",
                                ["quizTitleEN"] = reader["quizTitleEN"]?.ToString() ?? "",
                                ["quizTitleBM"] = reader["quizTitleBM"]?.ToString() ?? "",
                                ["language"] = reader["language"]?.ToString() ?? "EN",
                                ["levelId"] = reader["levelId"]?.ToString() ?? "",
                                ["unitId"] = reader["unitId"]?.ToString() ?? ""
                            });
                        }
                    }
                }

                if (quizRecords.Count == 0)
                {
                    pnlPQCards.Visible = false;
                    pnlPQEmpty.Visible = true;
                    return;
                }

                var quizCards = new List<object>();

                foreach (var quiz in quizRecords)
                {
                    string quizLanguage = quiz["language"];
                    string quizTitle = ResolveQuizTitle(quiz, quizLanguage);
                    string levelName = GetLevelName(conn, quiz["levelId"]);
                    string subtopicName = GetQuizSubtopicName(conn, quiz["quizId"]);
                    int questionCount = SafeCount(conn,
                        "SELECT COUNT(*) FROM dbo.[Question] WHERE [quizId] = @p",
                        "@p", quiz["quizId"]);
                    int studentsAttempted = SafeCount(conn,
                        "SELECT COUNT(DISTINCT [studentId]) FROM dbo.[QuizResult] WHERE [quizId] = @p",
                        "@p", quiz["quizId"]);
                    int totalAttempts = SafeCount(conn,
                        "SELECT COUNT(*) FROM dbo.[QuizResult] WHERE [quizId] = @p",
                        "@p", quiz["quizId"]);
                    string averageScore = GetAverageScore(conn, quiz["quizId"]);

                    quizCards.Add(new
                    {
                        title = quizTitle,
                        levelName,
                        subtopicName,
                        langLabel = quizLanguage == "BM" ? "Bahasa Melayu" : "English",
                        questionCount,
                        studentsAttempted,
                        totalAttempts,
                        avgScore = averageScore
                    });
                }

                pnlPQCards.Visible = true;
                pnlPQEmpty.Visible = false;
                rptPracticeQuizCards.DataSource = quizCards;
                rptPracticeQuizCards.DataBind();
            }
            catch
            {
                pnlPQCards.Visible = false;
                pnlPQEmpty.Visible = true;
            }
        }

        #endregion

        #region Database Operations

        private int GetApprovedQuestionCount(SqlConnection conn, string userId, string quizType)
        {
            using (var cmd = new SqlCommand(
                @"SELECT COUNT(DISTINCT q.[questionId]) FROM dbo.[Question] q
                  INNER JOIN dbo.[Quiz] qz ON qz.[quizId] = q.[quizId]
                  WHERE q.[createdByUserId] = @p AND qz.[quizType] = @t AND q.[status] = 'Approved'", conn))
            {
                cmd.Parameters.AddWithValue("@p", userId);
                cmd.Parameters.AddWithValue("@t", quizType);
                var result = cmd.ExecuteScalar();
                return (result != null && result != DBNull.Value) ? Convert.ToInt32(result) : 0;
            }
        }

        private int GetTotalApprovedQuestionCount(SqlConnection conn, string quizType)
        {
            using (var cmd = new SqlCommand(
                @"SELECT COUNT(DISTINCT q.[questionId]) FROM dbo.[Question] q
                  INNER JOIN dbo.[Quiz] qz ON qz.[quizId] = q.[quizId]
                  WHERE qz.[quizType] = @t AND q.[status] = 'Approved'", conn))
            {
                cmd.Parameters.AddWithValue("@t", quizType);
                var result = cmd.ExecuteScalar();
                return (result != null && result != DBNull.Value) ? Convert.ToInt32(result) : 0;
            }
        }

        private string GetLevelName(SqlConnection conn, string levelId)
        {
            if (string.IsNullOrEmpty(levelId)) return "";

            using (var cmd = new SqlCommand(
                "SELECT [levelNameEN] FROM dbo.[Level] WHERE [levelId] = @lid", conn))
            {
                cmd.Parameters.AddWithValue("@lid", levelId);
                var result = cmd.ExecuteScalar();
                return (result != null && result != DBNull.Value) ? result.ToString() : "";
            }
        }

        /// <summary>
        /// Gets the subtopic name from the first question linked to this quiz.
        /// </summary>
        private string GetQuizSubtopicName(SqlConnection conn, string quizId)
        {
            using (var cmd = new SqlCommand(
                @"SELECT TOP 1 st.[subtopicTitleEN]
                  FROM dbo.[Question] qn
                  INNER JOIN dbo.[Subtopic] st ON st.[subtopicId] = qn.[subtopicId]
                  WHERE qn.[quizId] = @qid", conn))
            {
                cmd.Parameters.AddWithValue("@qid", quizId);
                var result = cmd.ExecuteScalar();
                return (result != null && result != DBNull.Value) ? result.ToString() : "";
            }
        }

        private string GetAverageScore(SqlConnection conn, string quizId)
        {
            using (var cmd = new SqlCommand(
                "SELECT AVG(CAST([percentage] AS DECIMAL(5,2))) FROM dbo.[QuizResult] WHERE [quizId] = @qid", conn))
            {
                cmd.Parameters.AddWithValue("@qid", quizId);
                var result = cmd.ExecuteScalar();
                return (result != null && result != DBNull.Value)
                    ? Convert.ToDecimal(result).ToString("0.0") + "%"
                    : "0.0%";
            }
        }

        private int SafeCount(SqlConnection conn, string sql, string paramName, string paramValue)
        {
            try
            {
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue(paramName, paramValue);
                    var result = cmd.ExecuteScalar();
                    return (result != null && result != DBNull.Value) ? Convert.ToInt32(result) : 0;
                }
            }
            catch { return 0; }
        }

        #endregion

        #region AJAX Handlers

        /// <summary>
        /// Returns the full topic hierarchy (Level → Unit → Subtopics) for the curriculum browser.
        /// </summary>
        [WebMethod]
        public static List<TopicLevel> GetAvailableTopics()
        {
            var result = new List<TopicLevel>();
            string connStr = ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

            try
            {
                using (var conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    var levels = new List<TopicLevel>();
                    using (var cmd = new SqlCommand(
                        "SELECT [levelId],[levelNameEN] FROM dbo.[Level] ORDER BY [levelId]", conn))
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            levels.Add(new TopicLevel
                            {
                                LevelId = reader["levelId"].ToString(),
                                LevelName = reader["levelNameEN"]?.ToString() ?? "",
                                Units = new List<TopicUnit>()
                            });
                        }
                    }

                    var unitsByLevel = new Dictionary<string, List<TopicUnit>>();
                    var allUnits = new List<TopicUnit>();

                    using (var cmd = new SqlCommand(
                        "SELECT [unitId],[unitNameEN],[levelId] FROM dbo.[Unit] ORDER BY [levelId],[orderNo]", conn))
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string levelId = reader["levelId"].ToString();
                            var unit = new TopicUnit
                            {
                                UnitId = reader["unitId"].ToString(),
                                UnitName = reader["unitNameEN"]?.ToString() ?? "",
                                Subtopics = new List<string>()
                            };

                            if (!unitsByLevel.ContainsKey(levelId))
                                unitsByLevel[levelId] = new List<TopicUnit>();

                            unitsByLevel[levelId].Add(unit);
                            allUnits.Add(unit);
                        }
                    }

                    var subtopicsByUnit = new Dictionary<string, List<string>>();

                    using (var cmd = new SqlCommand(
                        "SELECT [subtopicTitleEN],[unitId] FROM dbo.[Subtopic] ORDER BY [unitId],[orderNo]", conn))
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string unitId = reader["unitId"].ToString();
                            string subtopicTitle = reader["subtopicTitleEN"]?.ToString() ?? "";

                            if (!subtopicsByUnit.ContainsKey(unitId))
                                subtopicsByUnit[unitId] = new List<string>();

                            subtopicsByUnit[unitId].Add(subtopicTitle);
                        }
                    }

                    // Assemble the hierarchy
                    foreach (var unit in allUnits)
                    {
                        if (subtopicsByUnit.ContainsKey(unit.UnitId))
                            unit.Subtopics = subtopicsByUnit[unit.UnitId];
                    }

                    foreach (var level in levels)
                    {
                        if (unitsByLevel.ContainsKey(level.LevelId))
                            level.Units = unitsByLevel[level.LevelId];
                    }

                    result = levels;
                }
            }
            catch { }

            return result;
        }

        #endregion

        #region Helper Methods

        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        private void HandleNonCertifiedStatus(string status)
        {
            string normalized = (status ?? "").Trim().ToLower();

            if (normalized == "pending")
            {
                pnlPending.Visible = true;
            }
            else if (normalized == "not certified" || normalized == "rejected")
            {
                pnlRejected.Visible = true;
            }
            else
            {
                pnlDenied.Visible = true;
            }
        }

        private void SetMasterUserInfo(string teacherName)
        {
            string displayName = !string.IsNullOrWhiteSpace(teacherName) ? teacherName : "Teacher";
            string initials = BuildInitials(displayName);

            var master = (ScienceBuddy.SiteMaster)Master;
            master.SetUserInfo(displayName, "Teacher", initials);
        }

        private static string BuildInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "T";

            var parts = name.Trim().Split(' ');
            if (parts.Length >= 2)
                return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();

            return name[0].ToString().ToUpper();
        }

        /// <summary>
        /// Determines the visual status (CSS classes, labels) for a session based on timing.
        /// </summary>
        private void DetermineSessionStatus(DateTime startTime, DateTime endTime,
            out string dotCss, out string badgeCss, out string btnCss,
            out string statusLabel, out string btnLabel)
        {
            DateTime now = DateTime.Now;

            if (now >= startTime && now <= endTime)
            {
                dotCss = "dot-green";
                badgeCss = "badge-green";
                btnCss = "btn-green";
                statusLabel = "LIVE NOW";
                btnLabel = T("Start Now", "Mula Sekarang");
            }
            else if (startTime <= now.AddMinutes(15))
            {
                dotCss = "dot-yellow";
                badgeCss = "badge-yellow";
                btnCss = "btn-yellow";
                statusLabel = T("Starting Soon", "Bermula Segera");
                btnLabel = T("Starting Soon", "Bermula Segera");
            }
            else
            {
                dotCss = "dot-blue";
                badgeCss = "badge-blue";
                btnCss = "btn-blue";
                statusLabel = T("Upcoming", "Akan Datang");
                btnLabel = T("View Details", "Lihat Butiran");
            }
        }

        private static string FormatFriendlyDate(DateTime dateTime)
        {
            DateTime today = DateTime.Today;

            if (dateTime.Date == today)
                return "Today — " + dateTime.ToString("h:mm tt");
            if (dateTime.Date == today.AddDays(1))
                return "Tomorrow — " + dateTime.ToString("h:mm tt");
            if (dateTime.Date < today.AddDays(7))
                return dateTime.ToString("ddd") + " — " + dateTime.ToString("h:mm tt");

            return dateTime.ToString("d MMM") + " — " + dateTime.ToString("h:mm tt");
        }

        private static string FormatTimeAgo(DateTime dateTime)
        {
            var elapsed = DateTime.Now - dateTime;

            if (elapsed.TotalMinutes < 1) return "Just now";
            if (elapsed.TotalHours < 1) return (int)elapsed.TotalMinutes + " min ago";
            if (elapsed.TotalDays < 1) return (int)elapsed.TotalHours + " hr ago";
            if (elapsed.TotalDays < 7)
            {
                int days = (int)elapsed.TotalDays;
                return days + " day" + (days == 1 ? "" : "s") + " ago";
            }

            return dateTime.ToString("d MMM yyyy");
        }

        private static int CalculatePercentage(int part, int total)
        {
            return total > 0 ? (int)Math.Round((double)part / total * 100) : 0;
        }

        private static string ResolveQuizTitle(Dictionary<string, string> quiz, string language)
        {
            string title = language == "BM" ? quiz["quizTitleBM"] : quiz["quizTitleEN"];

            if (string.IsNullOrWhiteSpace(title))
                title = quiz["quizTitleEN"];
            if (string.IsNullOrWhiteSpace(title))
                title = "Untitled";

            return title;
        }

        #endregion

        #region Inner Classes

        public class TopicLevel
        {
            public string LevelId { get; set; }
            public string LevelName { get; set; }
            public List<TopicUnit> Units { get; set; }
        }

        public class TopicUnit
        {
            public string UnitId { get; set; }
            public string UnitName { get; set; }
            public List<string> Subtopics { get; set; }
        }

        #endregion
    }
}
