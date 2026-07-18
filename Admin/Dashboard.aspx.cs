using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

// Admin Dashboard - Code Behind
namespace ScienceBuddy.Admin
{
    public partial class Dashboard : Page
    {
        // ── Connection string ────────────────────────────────────────
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        // ── Language helper ──────────────────────────────────────────
        protected string CurrentLanguage =>
            ((ScienceBuddy.SiteMaster)Master).CurrentLanguage;

        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        // ── Page Load ────────────────────────────────────────────────
        protected void Page_Load(object sender, EventArgs e)
        {
            // 1. Authorization
            if (Session["userId"] == null)
            {
                Response.Redirect("~/Login.aspx", false); return;
            }
            if (Session["role"] == null || Session["role"].ToString() != "Admin")
            {
                Response.Redirect("~/Login.aspx", false); return;
            }

            // 2. Tell master page to use sidebar layout
            var master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                LoadDashboard(Session["userId"].ToString());
            }
        }

        // ── Main load ────────────────────────────────────────────────
        private void LoadDashboard(string userId)
        {
            // Hero date
            litDate.Text = DateTime.Now.ToString("dddd, d MMMM yyyy");

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Admin display name
                SetAdminName(conn, userId);

                // Summary counts
                int studentCount  = SafeCount(conn, "SELECT COUNT(*) FROM dbo.[Student]");
                int parentCount   = SafeCount(conn, "SELECT COUNT(*) FROM dbo.[Parent]");
                int teacherCount  = SafeCount(conn, "SELECT COUNT(*) FROM dbo.[Teacher]");
                int lessonCount   = SafeCount(conn, "SELECT COUNT(*) FROM dbo.[Lesson]");
                int quizCount     = SafeCount(conn, "SELECT COUNT(*) FROM dbo.[Quiz]");
                int questionCount = SafeCount(conn, "SELECT COUNT(*) FROM dbo.[Question]");
                int materialCount = SafeCount(conn, "SELECT COUNT(*) FROM dbo.[Material]");

                litStudents.Text  = studentCount.ToString();
                litParents.Text   = parentCount.ToString();
                litTeachers.Text  = teacherCount.ToString();
                litLessons.Text   = lessonCount.ToString();
                litQuizzes.Text   = quizCount.ToString();
                litQuestions.Text  = questionCount.ToString();
                litMaterials.Text  = materialCount.ToString();

                // Pending counts (quiz-level approval + materials)
                int pendingQ = SafeCount(conn, "SELECT COUNT(*) FROM dbo.[Quiz] WHERE [status]='Pending'");
                int pendingM = SafeCount(conn, "SELECT COUNT(*) FROM dbo.[Material] WHERE [status]='Pending'");
                int forumReports = SafeCount(conn, "SELECT COUNT(*) FROM dbo.[ForumPost] WHERE [status]='Reported'");

                litPendingRequests.Text = (pendingQ + pendingM).ToString();
                litPendingQ.Text = pendingQ.ToString();
                litPendingM.Text = pendingM.ToString();
                litForumReports.Text = forumReports.ToString();

                int deletedCount = SafeCount(conn, "SELECT COUNT(*) FROM dbo.[User] WHERE [status]='Deleted'");
                if (litDeletedAccounts != null) litDeletedAccounts.Text = deletedCount.ToString();

                // Load pending requests table (latest 5)
                LoadPendingRequests(conn);

                // Master user info widget
                master_SetUserInfo(conn, userId);

                // Recent logs (latest 5)
                LoadRecentLogs(conn);

                // Recent notifications (latest 5)
                LoadNotifications(conn, userId);
            }
        }

        // ── Admin display name ───────────────────────────────────────
        private void SetAdminName(SqlConnection conn, string userId)
        {
            const string sql = "SELECT [username] FROM dbo.[User] WHERE [userId] = @uid";
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@uid", userId);
                var val = cmd.ExecuteScalar();
                litAdminName.Text = HttpUtility.HtmlEncode(
                    val != null && val != DBNull.Value ? val.ToString() : "Admin");
            }
        }

        // ── Master user widget ───────────────────────────────────────
        private void master_SetUserInfo(SqlConnection conn, string userId)
        {
            const string sql = "SELECT [username] FROM dbo.[User] WHERE [userId] = @uid";
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@uid", userId);
                var val = cmd.ExecuteScalar();
                string name = val != null && val != DBNull.Value ? val.ToString() : "Admin";
                string initials = name.Length >= 2 ? name.Substring(0, 2).ToUpper() : name.ToUpper();
                var master = (ScienceBuddy.SiteMaster)Master;
                master.SetUserInfo(name, "Administrator", initials);
            }
        }

        // ── Pending content requests (latest 5) ──────────────────────
        private void LoadPendingRequests(SqlConnection conn)
        {
            const string sql = @"
                SELECT TOP 5 * FROM (
                    SELECT q.[quizId] AS requestId, 'Quiz' AS requestType,
                        ISNULL(q.[quizTitleEN], q.[quizTitleBM]) AS title,
                        ISNULL(t.[name], u.[username]) AS requestedBy,
                        q.[createdAt] AS submittedDate
                    FROM dbo.[Quiz] q
                    LEFT JOIN dbo.[User] u ON u.[userId] = q.[createdByUserId]
                    LEFT JOIN dbo.[Teacher] t ON t.[userId] = q.[createdByUserId]
                    WHERE q.[status] = 'Pending'
                    UNION ALL
                    SELECT m.[materialId] AS requestId, 'Material' AS requestType,
                        m.[materialTitle] AS title,
                        ISNULL(t.[name], u.[username]) AS requestedBy,
                        m.[createdDate] AS submittedDate
                    FROM dbo.[Material] m
                    LEFT JOIN dbo.[User] u ON u.[userId] = m.[createdByUserId]
                    LEFT JOIN dbo.[Teacher] t ON t.[userId] = m.[createdByUserId]
                    WHERE m.[status] = 'Pending'
                ) combined ORDER BY submittedDate DESC";

            using (var cmd = new SqlCommand(sql, conn))
            {
                var da = new SqlDataAdapter(cmd);
                var dt = new DataTable();
                da.Fill(dt);

                if (dt.Rows.Count == 0)
                {
                    pnlRequests.Visible      = false;
                    pnlRequestsEmpty.Visible = true;
                    return;
                }

                var list = new List<object>();
                foreach (DataRow row in dt.Rows)
                {
                    DateTime submitted = row["submittedDate"] == DBNull.Value
                        ? DateTime.Now : Convert.ToDateTime(row["submittedDate"]);

                    // Assign priority based on age
                    var age = DateTime.Now - submitted;
                    string priority = age.TotalDays > 7 ? "high" : age.TotalDays > 3 ? "medium" : "low";
                    string priorityLabel = age.TotalDays > 7 ? T("High", "Tinggi") : age.TotalDays > 3 ? T("Medium", "Sederhana") : T("Low", "Rendah");

                    list.Add(new
                    {
                        requestType   = row["requestType"].ToString(),
                        badgeType     = row["requestType"].ToString().ToLower(),
                        requestedBy   = row["requestedBy"]?.ToString() ?? "—",
                        requestedDate = submitted.ToString("d MMM yyyy"),
                        priority      = priority,
                        priorityLabel = priorityLabel
                    });
                }

                pnlRequests.Visible      = true;
                pnlRequestsEmpty.Visible = false;
                rptRequests.DataSource   = list;
                rptRequests.DataBind();
            }
        }

        // ── Recent activity logs ─────────────────────────────────────
        private void LoadRecentLogs(SqlConnection conn)
        {
            const string sql = @"
                SELECT TOP 5
                    l.[logId], l.[action], l.[description],
                    l.[logDateTime], l.[status],
                    ISNULL(u.[username], 'System') AS username
                FROM dbo.[Log] l
                LEFT JOIN dbo.[User] u ON u.[userId] = l.[userId]
                ORDER BY l.[logDateTime] DESC";

            using (var cmd = new SqlCommand(sql, conn))
            {
                var da = new SqlDataAdapter(cmd);
                var dt = new DataTable();
                da.Fill(dt);

                if (dt.Rows.Count == 0)
                {
                    pnlLogs.Visible      = false;
                    pnlLogsEmpty.Visible = true;
                    return;
                }

                var list = new List<object>();
                foreach (DataRow row in dt.Rows)
                {
                    string action      = row["action"]?.ToString() ?? "";
                    string description = row["description"]?.ToString() ?? "";
                    string status      = row["status"]?.ToString() ?? "";
                    string username    = row["username"]?.ToString() ?? "System";
                    DateTime logDt     = row["logDateTime"] == DBNull.Value
                                         ? DateTime.Now
                                         : Convert.ToDateTime(row["logDateTime"]);

                    list.Add(new
                    {
                        action      = action,
                        description = description.Length > 80
                                        ? description.Substring(0, 80) + "\u2026"
                                        : description,
                        status      = status,
                        username    = username,
                        timeAgo     = FormatTimeAgo(logDt),
                        dotColor    = GetDotColor(action, status)
                    });
                }

                pnlLogs.Visible      = true;
                pnlLogsEmpty.Visible = false;
                rptLogs.DataSource   = list;
                rptLogs.DataBind();
            }
        }

        // ── Recent notifications (latest 5) ────────────────────────────
        private void LoadNotifications(SqlConnection conn, string userId)
        {
            const string sql = @"
                SELECT TOP 5
                    n.[notificationId], n.[titleEN], n.[titleBM],
                    n.[messageEN], n.[messageBM],
                    n.[isRead], n.[createdAt],
                    ISNULL(u.[username], n.[toUserId]) AS recipientName,
                    u.[role] AS recipientRole
                FROM dbo.[Notification] n
                LEFT JOIN dbo.[User] u ON u.[userId] = n.[toUserId]
                ORDER BY n.[createdAt] DESC";

            using (var cmd = new SqlCommand(sql, conn))
            {
                var da = new SqlDataAdapter(cmd);
                var dt = new DataTable();
                da.Fill(dt);

                if (dt.Rows.Count == 0)
                {
                    pnlNotifs.Visible      = false;
                    pnlNotifsEmpty.Visible = true;
                    return;
                }

                var list = new List<object>();
                foreach (DataRow row in dt.Rows)
                {
                    string title = CurrentLanguage == "BM"
                        ? (NullSafe(row["titleBM"]) != "" ? NullSafe(row["titleBM"]) : NullSafe(row["titleEN"]))
                        : NullSafe(row["titleEN"]);
                    if (string.IsNullOrWhiteSpace(title)) title = NullSafe(row["titleEN"]);
                    if (string.IsNullOrWhiteSpace(title)) title = T("(No title)", "(Tiada tajuk)");

                    string message = CurrentLanguage == "BM"
                        ? (NullSafe(row["messageBM"]) != "" ? NullSafe(row["messageBM"]) : NullSafe(row["messageEN"]))
                        : NullSafe(row["messageEN"]);
                    if (message.Length > 90) message = message.Substring(0, 90) + "\u2026";

                    bool isRead = row["isRead"] != DBNull.Value && Convert.ToBoolean(row["isRead"]);
                    DateTime createdAt = row["createdAt"] == DBNull.Value
                        ? DateTime.Now : Convert.ToDateTime(row["createdAt"]);

                    list.Add(new
                    {
                        title   = title,
                        message = message,
                        isRead  = isRead,
                        timeAgo = FormatTimeAgo(createdAt)
                    });
                }

                pnlNotifs.Visible      = true;
                pnlNotifsEmpty.Visible = false;
                rptNotifs.DataSource   = list;
                rptNotifs.DataBind();
            }
        }

        private static string NullSafe(object val)
        {
            return (val == null || val == DBNull.Value) ? "" : val.ToString();
        }

        // ── Utility: safe scalar count ───────────────────────────────
        private int SafeCount(SqlConnection conn, string sql)
        {
            try
            {
                using (var cmd = new SqlCommand(sql, conn))
                {
                    var val = cmd.ExecuteScalar();
                    return val != null && val != DBNull.Value ? Convert.ToInt32(val) : 0;
                }
            }
            catch { return 0; }
        }

        // ── Utility: timeline dot colour based on action ─────────────
        private static string GetDotColor(string action, string status)
        {
            if (string.IsNullOrEmpty(action)) return "blue";
            string a = action.ToLower();
            string s = (status ?? "").ToLower();
            if (s == "failed" || a.Contains("fail") || a.Contains("reject") || a.Contains("suspicious") || a.Contains("block"))
                return "red";
            if (a.Contains("approv") || a.Contains("certif") || s == "success" || a.Contains("register"))
                return "green";
            if (a.Contains("submit") || a.Contains("pending"))
                return "orange";
            if (a.Contains("lesson") || a.Contains("quiz") || a.Contains("update"))
                return "blue";
            return "purple";
        }

        // ── Utility: status badge HTML ───────────────────────────────
        protected string BuildStatusBadge(string status)
        {
            if (string.IsNullOrWhiteSpace(status)) return "";
            string lower = status.ToLower();
            string cls   = lower == "success"  ? "sb-badge-success"
                         : lower == "failed"   ? "sb-badge-error"
                         : lower == "warning"  ? "sb-badge-warning"
                         : lower == "info"     ? "sb-badge-primary"
                         : "sb-badge-gray";
            string label = status;
            switch (lower)
            {
                case "pending":   label = T("Pending", "Tertunggak"); break;
                case "approved":  label = T("Approved", "Diluluskan"); break;
                case "rejected":  label = T("Rejected", "Ditolak"); break;
                case "completed": label = T("Completed", "Selesai"); break;
                case "active":    label = T("Active", "Aktif"); break;
                case "inactive":  label = T("Inactive", "Tidak Aktif"); break;
                case "success":   label = T("Success", "Berjaya"); break;
                case "failed":    label = T("Failed", "Gagal"); break;
                case "warning":   label = T("Warning", "Amaran"); break;
            }
            return string.Format(
                "<span class=\"sb-badge {0}\" style=\"margin-left:4px;\">{1}</span>",
                cls,
                HttpUtility.HtmlEncode(label));
        }

        // ── Utility: relative time ───────────────────────────────────
        private static string FormatTimeAgo(DateTime dt)
        {
            var span = DateTime.Now - dt;
            if (span.TotalMinutes < 1)  return "Just now";
            if (span.TotalHours   < 1)  return (int)span.TotalMinutes + " min ago";
            if (span.TotalDays    < 1)  return (int)span.TotalHours + " hr ago";
            if (span.TotalDays    < 7)  return (int)span.TotalDays + " day" + ((int)span.TotalDays == 1 ? "" : "s") + " ago";
            return dt.ToString("d MMM yyyy");
        }

        // ── Utility: HtmlEncode for inline use in repeater ───────────
        protected string HtmlEncode(object value)
        {
            return HttpUtility.HtmlEncode(value?.ToString() ?? "");
        }
    }
}
