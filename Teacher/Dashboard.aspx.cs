using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
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
        protected string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }

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

                    // Load upcoming sessions
                    LoadUpcomingSessions(conn, teacherId);

                    // Load student performance
                    LoadStudentPerformance(conn, userId, teacherId);

                    // Load notifications
                    LoadNotifications(conn, userId);
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

        // ── Load upcoming sessions ───────────────────────────────────
        private void LoadUpcomingSessions(SqlConnection conn, string teacherId)
        {
            const string sql = @"
                SELECT TOP 5
                    lcs.[sessionId], lcs.[sessionTitle],
                    lcs.[startDateTime], lcs.[endDateTime], lcs.[status],
                    (SELECT COUNT(*)
                     FROM dbo.[LiveSessionParticipant]
                     WHERE [sessionId] = lcs.[sessionId]) AS participantCount
                FROM dbo.[LiveConsultationSession] lcs
                WHERE lcs.[teacherId] = @teacherId
                  AND lcs.[startDateTime] > GETDATE()
                ORDER BY lcs.[startDateTime] ASC";

            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@teacherId", teacherId);
                var da = new SqlDataAdapter(cmd);
                var dt = new DataTable();
                da.Fill(dt);

                if (dt.Rows.Count == 0)
                {
                    pnlSessions.Visible = false;
                    pnlSessionsEmpty.Visible = true;
                    return;
                }

                var list = new List<object>();
                foreach (DataRow row in dt.Rows)
                {
                    string title = row["sessionTitle"]?.ToString()
                        ?? "Untitled Session";
                    DateTime startDt = row["startDateTime"] == DBNull.Value
                        ? DateTime.Now
                        : Convert.ToDateTime(row["startDateTime"]);
                    int participants = row["participantCount"] == DBNull.Value
                        ? 0 : Convert.ToInt32(row["participantCount"]);
                    string status = row["status"]?.ToString() ?? "Scheduled";

                    string badgeClass = "td-badge-upcoming";
                    string statusLabel = "Upcoming";
                    if (string.Equals(status, "Active",
                        StringComparison.OrdinalIgnoreCase))
                    {
                        badgeClass = "td-badge-active";
                        statusLabel = "Active";
                    }

                    list.Add(new
                    {
                        sessionTitle = title,
                        sessionDate = startDt.ToString("d MMM yyyy"),
                        sessionTime = startDt.ToString("h:mm tt"),
                        participantCount = participants,
                        badgeClass = badgeClass,
                        statusLabel = statusLabel
                    });
                }

                pnlSessions.Visible = true;
                pnlSessionsEmpty.Visible = false;
                rptSessions.DataSource = list;
                rptSessions.DataBind();
            }
        }

        // ── Load student performance ─────────────────────────────────
        private void LoadStudentPerformance(SqlConnection conn, string userId,
            string teacherId)
        {
            // Average Quiz Score — from QuizResult for quizzes created by teacher
            try
            {
                const string sqlAvg = @"
                    SELECT AVG(qr.[percentage])
                    FROM dbo.[QuizResult] qr
                    INNER JOIN dbo.[Quiz] q ON q.[quizId] = qr.[quizId]
                    WHERE q.[createdByUserId] = @userId";

                using (var cmd = new SqlCommand(sqlAvg, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    var val = cmd.ExecuteScalar();
                    if (val != null && val != DBNull.Value)
                    {
                        decimal avg = Convert.ToDecimal(val);
                        litAvgQuizScore.Text = avg.ToString("0.0") + "%";
                    }
                    else
                    {
                        litAvgQuizScore.Text = "—";
                    }
                }
            }
            catch { litAvgQuizScore.Text = "—"; }

            // Lesson Completion Rate — percentage of completed lesson progress
            // across all students (global metric visible to teacher)
            try
            {
                const string sqlCompletion = @"
                    SELECT
                        CASE WHEN COUNT(*) = 0 THEN NULL
                        ELSE CAST(SUM(CASE WHEN [isCompleted] = 1 THEN 1 ELSE 0 END)
                             AS DECIMAL(10,2)) * 100 / COUNT(*)
                        END
                    FROM dbo.[LessonProgress]";

                using (var cmd = new SqlCommand(sqlCompletion, conn))
                {
                    var val = cmd.ExecuteScalar();
                    if (val != null && val != DBNull.Value)
                    {
                        decimal rate = Convert.ToDecimal(val);
                        litLessonCompletionRate.Text = rate.ToString("0.0") + "%";
                    }
                    else
                    {
                        litLessonCompletionRate.Text = "—";
                    }
                }
            }
            catch { litLessonCompletionRate.Text = "—"; }

            // Students Completed Today — distinct students who completed
            // a lesson today
            try
            {
                const string sqlToday = @"
                    SELECT COUNT(DISTINCT [studentId])
                    FROM dbo.[LessonProgress]
                    WHERE [isCompleted] = 1
                      AND CAST([completedDate] AS DATE) = CAST(GETDATE() AS DATE)";

                using (var cmd = new SqlCommand(sqlToday, conn))
                {
                    var val = cmd.ExecuteScalar();
                    litCompletedToday.Text = (val != null && val != DBNull.Value)
                        ? Convert.ToInt32(val).ToString() : "0";
                }
            }
            catch { litCompletedToday.Text = "0"; }
        }

        // ── Load notifications ───────────────────────────────────────
        private void LoadNotifications(SqlConnection conn, string userId)
        {
            const string sql = @"
                SELECT TOP 5
                    [notificationId], [titleEN], [messageEN],
                    [isRead], [createdAt]
                FROM dbo.[Notification]
                WHERE [toUserId] = @userId
                ORDER BY [createdAt] DESC";

            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                var da = new SqlDataAdapter(cmd);
                var dt = new DataTable();
                da.Fill(dt);

                if (dt.Rows.Count == 0)
                {
                    pnlNotifs.Visible = false;
                    pnlNotifsEmpty.Visible = true;
                    return;
                }

                var list = new List<object>();
                foreach (DataRow row in dt.Rows)
                {
                    string title = row["titleEN"]?.ToString() ?? "(No title)";
                    string message = row["messageEN"]?.ToString() ?? "";
                    bool isRead = row["isRead"] != DBNull.Value
                        && Convert.ToBoolean(row["isRead"]);
                    DateTime createdAt = row["createdAt"] == DBNull.Value
                        ? DateTime.Now
                        : Convert.ToDateTime(row["createdAt"]);

                    list.Add(new
                    {
                        title = title,
                        message = message.Length > 100
                            ? message.Substring(0, 100) + "…" : message,
                        isRead = isRead,
                        timeAgo = FormatTimeAgo(createdAt)
                    });
                }

                pnlNotifs.Visible = true;
                pnlNotifsEmpty.Visible = false;
                rptNotifs.DataSource = list;
                rptNotifs.DataBind();
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
    }
}
