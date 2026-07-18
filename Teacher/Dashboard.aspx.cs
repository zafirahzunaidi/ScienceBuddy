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
        // ── Language support ─────────────────────────────────────────
        protected string CurrentLanguage
        {
            get
            {
                string lang = Session["preferredLanguage"] as string;
                return string.IsNullOrEmpty(lang) ? "EN" : lang;
            }
        }
        protected string T(string en, string bm) { 
            return CurrentLanguage == "BM" ? bm : en; 
        }

        // ── Connection string ────────────────────────────────────────
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        // ── Page Load ────────────────────────────────────────────────
        protected void Page_Load(object sender, EventArgs e)
        {
            // 1. Authorization: check session
            if (Session["userId"] == null)
            {
                Response.Redirect("~/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }
            if (Session["role"] == null || Session["role"].ToString() != "Teacher")
            {
                Response.Redirect("~/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            // 2. Tell master page to use sidebar layout
            var master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                string userId = Session["userId"].ToString();
                LoadTeacherDashboard(userId);
            }
        }

        // ── Main load ────────────────────────────────────────────────
        private void LoadTeacherDashboard(string userId)
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // Retrieve teacher record
                    string teacherId = null;
                    string teacherName = null;
                    string teacherStatus = null;

                    const string sqlTeacher = @"
                        SELECT [teacherId], [name], [status]
                        FROM dbo.[Teacher]
                        WHERE [userId] = @userId";

                    using (var cmd = new SqlCommand(sqlTeacher, conn))
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

                    // If no teacher record found, deny access
                    if (string.IsNullOrEmpty(teacherId))
                    {
                        ShowDeniedPanel();
                        return;
                    }

                    // Check teacher status
                    if (!string.Equals(teacherStatus, "Certified",
                        StringComparison.OrdinalIgnoreCase))
                    {
                        HandleNonCertifiedStatus(teacherStatus);
                        return;
                    }

                    // Teacher is Certified — show full dashboard
                    pnlDashboard.Visible = true;

                    // Set display info
                    string displayName = !string.IsNullOrWhiteSpace(teacherName)
                        ? teacherName : "Teacher";
                    litTeacherName.Text = HttpUtility.HtmlEncode(displayName);

                    // Set master page user info
                    SetMasterUserInfo(teacherName);

                    // Load summary counts
                    LoadSummaryCounts(conn, userId, teacherId);

                    // Load quiz contribution
                    LoadQuizContribution(conn, userId);

                    // Load timeline sessions (new card)
                    LoadTimelineSessions(conn, teacherId);

                    // Load dashboard notifications (new card)
                    LoadDashNotifications(conn, userId);

                    // Load practice quiz engagement
                    LoadPracticeQuizEngagement(conn, userId);
                }
            }
            catch
            {
                // Graceful failure — show dashboard with defaults
                pnlDashboard.Visible = true;
                litTeacherName.Text = "Teacher";
            }
        }

        // ── Handle non-certified statuses ────────────────────────────
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
                // Suspended, Blocked, Deleted, or any other non-Certified status
                pnlDenied.Visible = true;
            }
        }

        private void ShowDeniedPanel()
        {
            pnlDenied.Visible = true;
        }

        // ── Set master page user widget ──────────────────────────────
        private void SetMasterUserInfo(string teacherName)
        {
            string displayName = !string.IsNullOrWhiteSpace(teacherName)
                ? teacherName : "Teacher";
            string initials = "T";

            var parts = displayName.Trim().Split(' ');
            if (parts.Length >= 2)
                initials = (parts[0][0].ToString() +
                    parts[parts.Length - 1][0].ToString()).ToUpper();
            else if (displayName.Length >= 1)
                initials = displayName[0].ToString().ToUpper();

            var master = (ScienceBuddy.SiteMaster)Master;
            master.SetUserInfo(displayName, "Teacher", initials);
        }

        // ── Load summary counts ──────────────────────────────────────
        private void LoadSummaryCounts(SqlConnection conn, string userId,
            string teacherId)
        {
            // Total Lessons (Materials created by this teacher)
            litTotalLessons.Text = SafeCount(conn,
                "SELECT COUNT(*) FROM dbo.[Material] WHERE [createdByUserId] = @p",
                "@p", userId).ToString();

            // Total Quizzes created by this teacher
            litTotalQuizzes.Text = SafeCount(conn,
                "SELECT COUNT(*) FROM dbo.[Quiz] WHERE [createdByUserId] = @p",
                "@p", userId).ToString();

            // Upcoming live sessions
            litUpcomingSessions.Text = SafeCount(conn,
                @"SELECT COUNT(*) FROM dbo.[LiveConsultationSession]
                  WHERE [teacherId] = @p AND [startDateTime] > GETDATE()",
                "@p", teacherId).ToString();

            // Total distinct students who participated in this teacher's sessions
            litTotalStudents.Text = SafeCount(conn,
                @"SELECT COUNT(DISTINCT lsp.[studentId])
                  FROM dbo.[LiveSessionParticipant] lsp
                  INNER JOIN dbo.[LiveConsultationSession] lcs
                    ON lcs.[sessionId] = lsp.[sessionId]
                  WHERE lcs.[teacherId] = @p",
                "@p", teacherId).ToString();
        }

        // ── Load quiz contribution ────────────────────────────────────
        private void LoadQuizContribution(SqlConnection conn, string userId)
        {
            try
            {
                // Unit Quiz Questions — count approved questions using Question.createdByUserId
                int myUnit = 0;
                using (var cmd = new SqlCommand(
                    @"SELECT COUNT(DISTINCT q.[questionId]) FROM dbo.[Question] q
                      INNER JOIN dbo.[Quiz] qz ON qz.[quizId]=q.[quizId]
                      WHERE q.[createdByUserId]=@p AND qz.[quizType]='Unit' AND q.[status]='Approved'", conn))
                { cmd.Parameters.AddWithValue("@p", userId); var v = cmd.ExecuteScalar(); myUnit = (v != null && v != DBNull.Value) ? Convert.ToInt32(v) : 0; }

                int totalUnit = 0;
                using (var cmd = new SqlCommand(
                    @"SELECT COUNT(DISTINCT q.[questionId]) FROM dbo.[Question] q
                      INNER JOIN dbo.[Quiz] qz ON qz.[quizId]=q.[quizId]
                      WHERE qz.[quizType]='Unit' AND q.[status]='Approved'", conn))
                { var v = cmd.ExecuteScalar(); totalUnit = (v != null && v != DBNull.Value) ? Convert.ToInt32(v) : 0; }

                litUnitMyCount.Text = myUnit.ToString();
                litUnitTotal.Text = totalUnit.ToString();
                int unitPct = totalUnit > 0 ? (int)Math.Round((double)myUnit / totalUnit * 100) : 0;
                hidUnitPct.Value = unitPct.ToString();

                // Level Quiz Questions — count approved questions using Question.createdByUserId
                int myLevel = 0;
                using (var cmd = new SqlCommand(
                    @"SELECT COUNT(DISTINCT q.[questionId]) FROM dbo.[Question] q
                      INNER JOIN dbo.[Quiz] qz ON qz.[quizId]=q.[quizId]
                      WHERE q.[createdByUserId]=@p AND qz.[quizType]='Level' AND q.[status]='Approved'", conn))
                { cmd.Parameters.AddWithValue("@p", userId); var v = cmd.ExecuteScalar(); myLevel = (v != null && v != DBNull.Value) ? Convert.ToInt32(v) : 0; }

                int totalLevel = 0;
                using (var cmd = new SqlCommand(
                    @"SELECT COUNT(DISTINCT q.[questionId]) FROM dbo.[Question] q
                      INNER JOIN dbo.[Quiz] qz ON qz.[quizId]=q.[quizId]
                      WHERE qz.[quizType]='Level' AND q.[status]='Approved'", conn))
                { var v = cmd.ExecuteScalar(); totalLevel = (v != null && v != DBNull.Value) ? Convert.ToInt32(v) : 0; }

                litLevelMyCount.Text = myLevel.ToString();
                litLevelTotal.Text = totalLevel.ToString();
                int levelPct = totalLevel > 0 ? (int)Math.Round((double)myLevel / totalLevel * 100) : 0;
                hidLevelPct.Value = levelPct.ToString();
            }
            catch
            {
                litUnitMyCount.Text = "0"; litUnitTotal.Text = "0"; hidUnitPct.Value = "0";
                litLevelMyCount.Text = "0"; litLevelTotal.Text = "0"; hidLevelPct.Value = "0";
            }
        }

        // ── Load timeline sessions (new dashboard card) ───────────
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

            var list = new List<object>();
            try
            {
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@tid", teacherId);
                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            DateTime start = r["startDateTime"] != DBNull.Value ? Convert.ToDateTime(r["startDateTime"]) : DateTime.Now;
                            DateTime end = r["endDateTime"] != DBNull.Value ? Convert.ToDateTime(r["endDateTime"]) : DateTime.Now;
                            string title = r["sessionTitle"]?.ToString() ?? "";
                            string topic = r["subtopicName"]?.ToString() ?? "";
                            DateTime now = DateTime.Now;

                            string dotCss, badgeCss, btnCss, statusLabel, btnLabel;
                            if (now >= start && now <= end)
                            { dotCss = "dot-green"; badgeCss = "badge-green"; btnCss = "btn-green"; statusLabel = "LIVE NOW"; btnLabel = T("Start Now", "Mula Sekarang"); }
                            else if (start <= now.AddMinutes(15))
                            { dotCss = "dot-yellow"; badgeCss = "badge-yellow"; btnCss = "btn-yellow"; statusLabel = T("Starting Soon", "Bermula Segera"); btnLabel = T("Starting Soon", "Bermula Segera"); }
                            else
                            { dotCss = "dot-blue"; badgeCss = "badge-blue"; btnCss = "btn-blue"; statusLabel = T("Upcoming", "Akan Datang"); btnLabel = T("View Details", "Lihat Butiran"); }

                            string friendlyDate = FormatFriendlyDate(start);

                            list.Add(new { title, topic, friendlyDate, dotCss, badgeCss, btnCss, statusLabel, btnLabel });
                        }
                    }
                }
            }
            catch { }

            if (list.Count > 0)
            {
                pnlTimelineSessions.Visible = true; pnlTimelineEmpty.Visible = false;
                rptTimelineSessions.DataSource = list; rptTimelineSessions.DataBind();
            }
            else
            {
                pnlTimelineSessions.Visible = false; pnlTimelineEmpty.Visible = true;
            }
        }

        private static string FormatFriendlyDate(DateTime dt)
        {
            DateTime today = DateTime.Today;
            if (dt.Date == today) return "Today • " + dt.ToString("h:mm tt");
            if (dt.Date == today.AddDays(1)) return "Tomorrow • " + dt.ToString("h:mm tt");
            if (dt.Date < today.AddDays(7)) return dt.ToString("ddd") + " • " + dt.ToString("h:mm tt");
            return dt.ToString("d MMM") + " • " + dt.ToString("h:mm tt");
        }

        // ── Load dashboard notifications (new card) ──────────────────
        private void LoadDashNotifications(SqlConnection conn, string userId)
        {
            const string sql = @"
                SELECT TOP 4
                    [titleEN], [titleBM], [messageEN], [messageBM], [isRead], [createdAt]
                FROM dbo.[Notification]
                WHERE [toUserId] = @uid
                ORDER BY [createdAt] DESC";

            var list = new List<object>();
            try
            {
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            string title = CurrentLanguage == "BM"
                                ? (r["titleBM"]?.ToString() ?? r["titleEN"]?.ToString() ?? "")
                                : (r["titleEN"]?.ToString() ?? "");
                            string message = CurrentLanguage == "BM"
                                ? (r["messageBM"]?.ToString() ?? r["messageEN"]?.ToString() ?? "")
                                : (r["messageEN"]?.ToString() ?? "");
                            bool isRead = r["isRead"] != DBNull.Value && Convert.ToBoolean(r["isRead"]);
                            DateTime createdAt = r["createdAt"] != DBNull.Value ? Convert.ToDateTime(r["createdAt"]) : DateTime.Now;

                            list.Add(new
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

            if (list.Count > 0)
            {
                pnlDashNotifs.Visible = true; pnlDashNotifsEmpty.Visible = false;
                rptDashNotifs.DataSource = list; rptDashNotifs.DataBind();
            }
            else
            {
                pnlDashNotifs.Visible = false; pnlDashNotifsEmpty.Visible = true;
            }
        }

        // ── Load practice quiz engagement ──────────────────────────
        private void LoadPracticeQuizEngagement(SqlConnection conn, string userId)
        {
            try
            {
                const string sql = @"
                    SELECT [quizId], [quizTitleEN], [quizTitleBM], [language],
                           [levelId], [unitId], [status]
                    FROM dbo.[Quiz]
                    WHERE [createdByUserId]=@userId
                      AND [quizType]='Practice'
                      AND [status]='Approved'
                    ORDER BY [quizId] DESC";

                var quizzes = new List<Dictionary<string, string>>();
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            var q = new Dictionary<string, string>();
                            q["quizId"] = r["quizId"]?.ToString() ?? "";
                            q["quizTitleEN"] = r["quizTitleEN"]?.ToString() ?? "";
                            q["quizTitleBM"] = r["quizTitleBM"]?.ToString() ?? "";
                            q["language"] = r["language"]?.ToString() ?? "EN";
                            q["levelId"] = r["levelId"]?.ToString() ?? "";
                            q["unitId"] = r["unitId"]?.ToString() ?? "";
                            q["status"] = r["status"]?.ToString() ?? "";
                            quizzes.Add(q);
                        }
                    }
                }

                if (quizzes.Count == 0)
                {
                    pnlPQCards.Visible = false;
                    pnlPQEmpty.Visible = true;
                    return;
                }

                var list = new List<object>();
                foreach (var q in quizzes)
                {
                    string lang = q["language"];
                    string title = lang == "BM" ? q["quizTitleBM"] : q["quizTitleEN"];
                    if (string.IsNullOrWhiteSpace(title))
                        title = q["quizTitleEN"];
                    if (string.IsNullOrWhiteSpace(title))
                        title = "Untitled";

                    // Level name
                    string levelName = "";
                    if (!string.IsNullOrEmpty(q["levelId"]))
                    {
                        using (var cmd = new SqlCommand("SELECT [levelNameEN] FROM dbo.[Level] WHERE [levelId]=@lid", conn))
                        {
                            cmd.Parameters.AddWithValue("@lid", q["levelId"]);
                            var v = cmd.ExecuteScalar();
                            levelName = (v != null && v != DBNull.Value) ? v.ToString() : "";
                        }
                    }

                    // Subtopic name (from the first Question linked to this quiz)
                    string subtopicName = "";
                    using (var cmd = new SqlCommand(
                        @"SELECT TOP 1 st.[subtopicTitleEN]
                          FROM dbo.[Question] qn
                          INNER JOIN dbo.[Subtopic] st ON st.[subtopicId]=qn.[subtopicId]
                          WHERE qn.[quizId]=@qid", conn))
                    {
                        cmd.Parameters.AddWithValue("@qid", q["quizId"]);
                        var v = cmd.ExecuteScalar();
                        subtopicName = (v != null && v != DBNull.Value) ? v.ToString() : "";
                    }

                    // Question count per quiz
                    int questionCount = 0;
                    using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[Question] WHERE [quizId]=@qid", conn))
                    {
                        cmd.Parameters.AddWithValue("@qid", q["quizId"]);
                        var v = cmd.ExecuteScalar();
                        questionCount = (v != null && v != DBNull.Value) ? Convert.ToInt32(v) : 0;
                    }

                    // Students attempted (distinct studentId from QuizResult)
                    int studentsAttempted = 0;
                    using (var cmd = new SqlCommand("SELECT COUNT(DISTINCT [studentId]) FROM dbo.[QuizResult] WHERE [quizId]=@qid", conn))
                    {
                        cmd.Parameters.AddWithValue("@qid", q["quizId"]);
                        var v = cmd.ExecuteScalar();
                        studentsAttempted = (v != null && v != DBNull.Value) ? Convert.ToInt32(v) : 0;
                    }

                    // Total attempts (count of QuizResult records)
                    int totalAttempts = 0;
                    using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[QuizResult] WHERE [quizId]=@qid", conn))
                    {
                        cmd.Parameters.AddWithValue("@qid", q["quizId"]);
                        var v = cmd.ExecuteScalar();
                        totalAttempts = (v != null && v != DBNull.Value) ? Convert.ToInt32(v) : 0;
                    }

                    // Average score (AVG percentage from QuizResult)
                    string avgScore = "0.0%";
                    using (var cmd = new SqlCommand("SELECT AVG(CAST([percentage] AS DECIMAL(5,2))) FROM dbo.[QuizResult] WHERE [quizId]=@qid", conn))
                    {
                        cmd.Parameters.AddWithValue("@qid", q["quizId"]);
                        var v = cmd.ExecuteScalar();
                        if (v != null && v != DBNull.Value)
                            avgScore = Convert.ToDecimal(v).ToString("0.0") + "%";
                    }

                    list.Add(new
                    {
                        title,
                        levelName,
                        subtopicName,
                        langLabel = lang == "BM" ? "Bahasa Melayu" : "English",
                        questionCount,
                        studentsAttempted,
                        totalAttempts,
                        avgScore
                    });
                }

                pnlPQCards.Visible = true;
                pnlPQEmpty.Visible = false;
                rptPracticeQuizCards.DataSource = list;
                rptPracticeQuizCards.DataBind();
            }
            catch (Exception)
            {
                pnlPQCards.Visible = false;
                pnlPQEmpty.Visible = true;
            }
        }

        // ── Utility: safe parameterized count ────────────────────────
        private int SafeCount(SqlConnection conn, string sql,
            string paramName, string paramValue)
        {
            try
            {
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue(paramName, paramValue);
                    var val = cmd.ExecuteScalar();
                    return val != null && val != DBNull.Value
                        ? Convert.ToInt32(val) : 0;
                }
            }
            catch { return 0; }
        }

        // ── Utility: relative time ───────────────────────────────────
        private static string FormatTimeAgo(DateTime dt)
        {
            var span = DateTime.Now - dt;
            if (span.TotalMinutes < 1) return "Just now";
            if (span.TotalHours < 1)
                return (int)span.TotalMinutes + " min ago";
            if (span.TotalDays < 1)
                return (int)span.TotalHours + " hr ago";
            if (span.TotalDays < 7)
                return (int)span.TotalDays + " day"
                    + ((int)span.TotalDays == 1 ? "" : "s") + " ago";
            return dt.ToString("d MMM yyyy");
        }

        // ── WebMethod: Available Topics (read-only) ──────────────────
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

                    // Load all levels
                    var levels = new List<TopicLevel>();
                    using (var cmd = new SqlCommand(
                        "SELECT [levelId],[levelNameEN] FROM dbo.[Level] ORDER BY [levelId]", conn))
                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            levels.Add(new TopicLevel
                            {
                                LevelId = r["levelId"].ToString(),
                                LevelName = r["levelNameEN"]?.ToString() ?? "",
                                Units = new List<TopicUnit>()
                            });
                        }
                    }

                    // Load all units
                    var unitMap = new Dictionary<string, List<TopicUnit>>();
                    var allUnits = new List<TopicUnit>();
                    using (var cmd = new SqlCommand(
                        "SELECT [unitId],[unitNameEN],[levelId] FROM dbo.[Unit] ORDER BY [levelId],[orderNo]", conn))
                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            string levelId = r["levelId"].ToString();
                            var unit = new TopicUnit
                            {
                                UnitId = r["unitId"].ToString(),
                                UnitName = r["unitNameEN"]?.ToString() ?? "",
                                Subtopics = new List<string>()
                            };
                            if (!unitMap.ContainsKey(levelId))
                                unitMap[levelId] = new List<TopicUnit>();
                            unitMap[levelId].Add(unit);
                            allUnits.Add(unit);
                        }
                    }

                    // Load all subtopics
                    var subtopicMap = new Dictionary<string, List<string>>();
                    using (var cmd = new SqlCommand(
                        "SELECT [subtopicTitleEN],[unitId] FROM dbo.[Subtopic] ORDER BY [unitId],[orderNo]", conn))
                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            string unitId = r["unitId"].ToString();
                            string title = r["subtopicTitleEN"]?.ToString() ?? "";
                            if (!subtopicMap.ContainsKey(unitId))
                                subtopicMap[unitId] = new List<string>();
                            subtopicMap[unitId].Add(title);
                        }
                    }

                    // Assemble hierarchy
                    foreach (var unit in allUnits)
                    {
                        if (subtopicMap.ContainsKey(unit.UnitId))
                            unit.Subtopics = subtopicMap[unit.UnitId];
                    }

                    foreach (var level in levels)
                    {
                        if (unitMap.ContainsKey(level.LevelId))
                            level.Units = unitMap[level.LevelId];
                    }

                    result = levels;
                }
            }
            catch { }

            return result;
        }

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
    }
}
