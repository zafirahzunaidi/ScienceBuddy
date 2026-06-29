using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

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
            // Hero
            litDate.Text = DateTime.Now.ToString("dddd, d MMMM yyyy");

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Admin display name
                SetAdminName(conn, userId);

                // Summary counts
                litStudents.Text        = SafeCount(conn, "SELECT COUNT(*) FROM dbo.[Student]").ToString();
                litParents.Text         = SafeCount(conn, "SELECT COUNT(*) FROM dbo.[Parent]").ToString();
                litTeachers.Text        = SafeCount(conn, "SELECT COUNT(*) FROM dbo.[Teacher]").ToString();
                litLessons.Text         = SafeCount(conn, "SELECT COUNT(*) FROM dbo.[Lesson]").ToString();
                litQuizzes.Text         = SafeCount(conn, "SELECT COUNT(*) FROM dbo.[Quiz]").ToString();

                // Pending content requests — table may not exist yet
                litPendingRequests.Text = "0";
                pnlRequestsEmpty.Visible = true;
                pnlRequests.Visible      = false;

                // Master user info widget
                master_SetUserInfo(conn, userId);

                // Recent logs (latest 10)
                LoadRecentLogs(conn);

                // Recent notifications for this admin (latest 5)
                LoadNotifications(conn, userId);

                // Apply bilingual labels
                ApplyLanguageLabels();
            }
        }

        // ── Bilingual labels ─────────────────────────────────────────
        private void ApplyLanguageLabels()
        {
            // These Literals are set here; the ASPX markup uses them
            // Hero greeting prefix is set in SetAdminName
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

        // ── Recent activity logs ─────────────────────────────────────
        private void LoadRecentLogs(SqlConnection conn)
        {
            const string sql = @"
                SELECT TOP 10
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
                                        ? description.Substring(0, 80) + "…"
                                        : description,
                        status      = status,
                        username    = username,
                        timeAgo     = FormatTimeAgo(logDt),
                        iconClass   = GetLogIcon(action),
                        iconStyle   = GetLogIconStyle(action, status)
                    });
                }

                pnlLogs.Visible      = true;
                pnlLogsEmpty.Visible = false;
                rptLogs.DataSource   = list;
                rptLogs.DataBind();
            }
        }

        // ── Recent notifications ─────────────────────────────────────
        private void LoadNotifications(SqlConnection conn, string userId)
        {
            const string sql = @"
                SELECT TOP 5
                    [notificationId], [titleEN], [titleBM],
                    [messageEN], [messageBM],
                    [isRead], [createdAt]
                FROM dbo.[Notification]
                WHERE [toUserId] = @uid
                ORDER BY [createdAt] DESC";

            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@uid", userId);
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
                    string title   = CurrentLanguage == "BM"
                        ? (row["titleBM"]?.ToString() ?? row["titleEN"]?.ToString() ?? "(No title)")
                        : (row["titleEN"]?.ToString() ?? "(No title)");
                    string message = CurrentLanguage == "BM"
                        ? (row["messageBM"]?.ToString() ?? row["messageEN"]?.ToString() ?? "")
                        : (row["messageEN"]?.ToString() ?? "");
                    if (string.IsNullOrWhiteSpace(title)) title = row["titleEN"]?.ToString() ?? "(No title)";
                    if (string.IsNullOrWhiteSpace(message)) message = row["messageEN"]?.ToString() ?? "";
                    bool   isRead  = row["isRead"] != DBNull.Value && Convert.ToBoolean(row["isRead"]);
                    DateTime createdAt = row["createdAt"] == DBNull.Value
                                          ? DateTime.Now
                                          : Convert.ToDateTime(row["createdAt"]);

                    list.Add(new
                    {
                        title   = title,
                        message = message.Length > 90 ? message.Substring(0, 90) + "…" : message,
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
            // Translate status label
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

        // ── Utility: log icon per action keyword ─────────────────────
        private static string GetLogIcon(string action)
        {
            if (string.IsNullOrEmpty(action)) return "bi bi-circle";
            string a = action.ToLower();
            if (a.Contains("login") && a.Contains("fail")) return "bi bi-x-circle-fill";
            if (a.Contains("suspicious"))                   return "bi bi-exclamation-triangle-fill";
            if (a.Contains("login"))                        return "bi bi-box-arrow-in-right";
            if (a.Contains("logout"))                       return "bi bi-box-arrow-right";
            if (a.Contains("block"))                        return "bi bi-slash-circle-fill";
            if (a.Contains("approv") || a.Contains("certif")) return "bi bi-check-circle-fill";
            if (a.Contains("reject"))                       return "bi bi-x-circle-fill";
            if (a.Contains("lesson") || a.Contains("quiz")) return "bi bi-pencil-fill";
            if (a.Contains("notif"))                        return "bi bi-bell-fill";
            if (a.Contains("config"))                       return "bi bi-gear-fill";
            return "bi bi-activity";
        }

        private static string GetLogIconStyle(string action, string status)
        {
            string lower  = (action ?? "").ToLower();
            string sLower = (status ?? "").ToLower();
            if (sLower == "failed" || lower.Contains("fail") || lower.Contains("reject") || lower.Contains("suspicious"))
                return "background:#FEE2E2;color:#DC2626;";
            if (lower.Contains("approv") || lower.Contains("certif") || sLower == "success")
                return "background:#D1FAE5;color:#059669;";
            if (lower.Contains("block"))
                return "background:#FEF3C7;color:#D97706;";
            if (lower.Contains("login"))
                return "background:#DBEAFE;color:#2563EB;";
            return "background:#EDE9FE;color:#7C3AED;";
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
