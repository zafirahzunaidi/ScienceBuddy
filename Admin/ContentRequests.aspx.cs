using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Admin
{
    public partial class ContentRequests : Page
    {
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
            if (Session["userId"] == null)
            { Response.Redirect("~/Login.aspx", false); return; }

            if (Session["role"] == null || Session["role"].ToString() != "Admin")
            { Response.Redirect("~/Login.aspx", false); return; }

            var master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                SetMasterUserInfo();
                LoadSummary();
                LoadTables("", "", "");

                // Show success toast from reject→notify→redirect workflow
                if (Session["cr_toast"] != null)
                {
                    ShowToast("<i class=\"bi bi-check-circle-fill\"></i> " + Session["cr_toast"].ToString(), "sb-alert-success");
                    Session.Remove("cr_toast");
                }
            }

            // Set bilingual placeholders/labels every load (even on postback)
            txtSearch.Attributes["placeholder"] = T("Search by title, teacher or subtopic…", "Cari mengikut tajuk, guru atau subtopik…");
            btnSearch.Text = T("Search", "Cari");
            btnReset.Text  = T("Reset", "Tetapkan Semula");
        }

        // ── Master user widget ───────────────────────────────────────
        private void SetMasterUserInfo()
        {
            string userId = Session["userId"].ToString();
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(
                    "SELECT [username] FROM dbo.[User] WHERE [userId]=@uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    var val = cmd.ExecuteScalar();
                    string name = val != null && val != DBNull.Value ? val.ToString() : "Admin";
                    string ini  = name.Length >= 2 ? name.Substring(0, 2).ToUpper() : name.ToUpper();
                    ((ScienceBuddy.SiteMaster)Master).SetUserInfo(name, "Administrator", ini);
                }
            }
        }

        // ── Load summary counts ──────────────────────────────────────
        private void LoadSummary()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                int pending  = CountByStatus(conn, "Pending");
                int approved = CountByStatus(conn, "Approved");
                int rejected = CountByStatus(conn, "Rejected");
                int total    = pending + approved + rejected;

                litPending.Text  = pending.ToString();
                litApproved.Text = approved.ToString();
                litRejected.Text = rejected.ToString();
                litTotal.Text    = total.ToString();

                // Badge next to "Pending Requests" heading
                litPendingBadge.Text = pending > 0
                    ? string.Format(
                        " <span class=\"sb-badge sb-badge-warning\" style=\"margin-left:4px;\">{0}</span>",
                        pending)
                    : "";
            }
        }

        private int CountByStatus(SqlConnection conn, string status)
        {
            // Count Material + Practice Quiz rows with this status
            const string sql = @"
                SELECT
                  (SELECT COUNT(*) FROM dbo.[Material] WHERE [status]=@s)
                + (SELECT COUNT(*) FROM dbo.[Quiz]     WHERE [status]=@s AND [quizType]='Practice')";
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@s", status);
                var v = cmd.ExecuteScalar();
                return v != null && v != DBNull.Value ? Convert.ToInt32(v) : 0;
            }
        }

        // ── Load both tables with optional filters ───────────────────
        private void LoadTables(string search, string statusFilter, string typeFilter)
        {
            var rows = FetchRows(search, statusFilter, typeFilter);

            // Split pending vs reviewed
            var pending  = new List<object>();
            var reviewed = new List<object>();

            foreach (var r in rows)
            {
                var row = (dynamic)r;
                if (row.status == "Pending")
                    pending.Add(r);
                else
                    reviewed.Add(r);
            }

            // Pending table
            if (pending.Count > 0)
            {
                pnlPending.Visible      = true;
                pnlPendingEmpty.Visible = false;
                rptPending.DataSource   = pending;
                rptPending.DataBind();
            }
            else
            {
                pnlPending.Visible      = false;
                pnlPendingEmpty.Visible = true;
            }

            // History table
            if (reviewed.Count > 0)
            {
                pnlHistory.Visible      = true;
                pnlHistoryEmpty.Visible = false;
                rptHistory.DataSource   = reviewed;
                rptHistory.DataBind();
            }
            else
            {
                pnlHistory.Visible      = false;
                pnlHistoryEmpty.Visible = true;
            }
        }

        // ── Build combined row list ──────────────────────────────────
        private List<object> FetchRows(string search, string statusFilter, string typeFilter)
        {
            var list = new List<object>();
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                bool wantMaterial = typeFilter == "" || typeFilter == "Material";
                bool wantQuiz     = typeFilter == "" || typeFilter == "Practice Quiz";

                // ── Materials ────────────────────────────────────────
                if (wantMaterial)
                {
                    string sql = @"
                        SELECT
                            m.[materialId]      AS requestId,
                            m.[materialTitle]   AS title,
                            m.[materialType]    AS subType,
                            m.[language],
                            m.[createdDate]     AS submittedDate,
                            m.[reviewedDate],
                            m.[status],
                            m.[createdByUserId] AS teacherUserId,
                            ISNULL(t.[name], u.[username]) AS teacherName,
                            ISNULL(st.[subtopicTitleEN], '') AS subtopicTitle,
                            ISNULL(un.[unitNameEN], '')    AS unitName
                        FROM dbo.[Material] m
                        LEFT JOIN dbo.[User]     u  ON u.[userId]     = m.[createdByUserId]
                        LEFT JOIN dbo.[Teacher]  t  ON t.[userId]     = m.[createdByUserId]
                        LEFT JOIN dbo.[Subtopic] st ON st.[subtopicId] = m.[subtopicId]
                        LEFT JOIN dbo.[Unit]     un ON un.[unitId]     = st.[unitId]
                        WHERE 1=1";

                    if (!string.IsNullOrWhiteSpace(statusFilter))
                        sql += " AND m.[status] = @status";
                    if (!string.IsNullOrWhiteSpace(search))
                        sql += @" AND (
                            m.[materialTitle]        LIKE @search OR
                            ISNULL(t.[name],'')      LIKE @search OR
                            u.[username]             LIKE @search OR
                            ISNULL(st.[subtopicTitleEN],'') LIKE @search)";

                    sql += " ORDER BY m.[createdDate] DESC";

                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        if (!string.IsNullOrWhiteSpace(statusFilter))
                            cmd.Parameters.AddWithValue("@status", statusFilter);
                        if (!string.IsNullOrWhiteSpace(search))
                            cmd.Parameters.AddWithValue("@search", "%" + search + "%");

                        var da = new SqlDataAdapter(cmd);
                        var dt = new DataTable();
                        da.Fill(dt);

                        foreach (DataRow row in dt.Rows)
                        {
                            list.Add(new
                            {
                                requestId     = row["requestId"].ToString(),
                                sourceType    = "Material",
                                title         = row["title"].ToString(),
                                teacherName   = row["teacherName"].ToString(),
                                teacherUserId = row["teacherUserId"].ToString(),
                                unitName      = row["unitName"].ToString(),
                                subtopicTitle = row["subtopicTitle"].ToString(),
                                language      = row["language"] == DBNull.Value ? "—" : row["language"].ToString(),
                                submittedDate = row["submittedDate"] == DBNull.Value
                                                  ? "—"
                                                  : Convert.ToDateTime(row["submittedDate"]).ToString("d MMM yyyy"),
                                reviewedDate  = row["reviewedDate"] == DBNull.Value
                                                  ? "—"
                                                  : Convert.ToDateTime(row["reviewedDate"]).ToString("d MMM yyyy"),
                                status        = row["status"].ToString()
                            });
                        }
                    }
                }

                // ── Practice Quizzes ─────────────────────────────────
                if (wantQuiz)
                {
                    string sql = @"
                        SELECT
                            q.[quizId]                          AS requestId,
                            ISNULL(q.[quizTitleEN], q.[quizTitleBM]) AS title,
                            q.[language],
                            q.[createdAt]                       AS submittedDate,
                            CAST(NULL AS DATE)                  AS reviewedDate,
                            q.[status],
                            q.[createdByUserId]                 AS teacherUserId,
                            ISNULL(t.[name], u.[username])      AS teacherName,
                            ISNULL(st.[subtopicTitleEN], '')    AS subtopicTitle,
                            ISNULL(un.[unitNameEN], '')         AS unitName
                        FROM dbo.[Quiz] q
                        LEFT JOIN dbo.[User]     u  ON u.[userId]     = q.[createdByUserId]
                        LEFT JOIN dbo.[Teacher]  t  ON t.[userId]     = q.[createdByUserId]
                        LEFT JOIN dbo.[Subtopic] st ON st.[subtopicId] = q.[subtopicId]
                        LEFT JOIN dbo.[Unit]     un ON un.[unitId]     = st.[unitId]
                        WHERE q.[quizType] = 'Practice'";

                    if (!string.IsNullOrWhiteSpace(statusFilter))
                        sql += " AND q.[status] = @status";
                    if (!string.IsNullOrWhiteSpace(search))
                        sql += @" AND (
                            ISNULL(q.[quizTitleEN],'')       LIKE @search OR
                            ISNULL(q.[quizTitleBM],'')       LIKE @search OR
                            ISNULL(t.[name],'')              LIKE @search OR
                            u.[username]                     LIKE @search OR
                            ISNULL(st.[subtopicTitleEN],'')  LIKE @search)";

                    sql += " ORDER BY q.[createdAt] DESC";

                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        if (!string.IsNullOrWhiteSpace(statusFilter))
                            cmd.Parameters.AddWithValue("@status", statusFilter);
                        if (!string.IsNullOrWhiteSpace(search))
                            cmd.Parameters.AddWithValue("@search", "%" + search + "%");

                        var da = new SqlDataAdapter(cmd);
                        var dt = new DataTable();
                        da.Fill(dt);

                        foreach (DataRow row in dt.Rows)
                        {
                            list.Add(new
                            {
                                requestId     = row["requestId"].ToString(),
                                sourceType    = "Practice Quiz",
                                title         = row["title"].ToString(),
                                teacherName   = row["teacherName"].ToString(),
                                teacherUserId = row["teacherUserId"].ToString(),
                                unitName      = row["unitName"].ToString(),
                                subtopicTitle = row["subtopicTitle"].ToString(),
                                language      = row["language"] == DBNull.Value ? "—" : row["language"].ToString(),
                                submittedDate = row["submittedDate"] == DBNull.Value
                                                  ? "—"
                                                  : Convert.ToDateTime(row["submittedDate"]).ToString("d MMM yyyy"),
                                reviewedDate  = row["reviewedDate"] == DBNull.Value
                                                  ? "—"
                                                  : Convert.ToDateTime(row["reviewedDate"]).ToString("d MMM yyyy"),
                                status        = row["status"].ToString()
                            });
                        }
                    }
                }
            }

            // Sort: pending first, then newest reviewed first
            list.Sort((a, b) =>
            {
                var da = (dynamic)a;
                var db = (dynamic)b;
                int sa = da.status == "Pending" ? 0 : 1;
                int sb2 = db.status == "Pending" ? 0 : 1;
                return sa.CompareTo(sb2);
            });

            return list;
        }

        // ── Search button ────────────────────────────────────────────
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string search = txtSearch.Text.Trim();
            string status = ddlStatus.SelectedValue;
            string type   = ddlType.SelectedValue;
            LoadSummary();
            LoadTables(search, status, type);
        }

        // ── Reset button ─────────────────────────────────────────────
        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text         = "";
            ddlStatus.SelectedIndex = 0;
            ddlType.SelectedIndex   = 0;
            LoadSummary();
            LoadTables("", "", "");
        }

        // ── Approve / Reject from pending repeater ───────────────────
        protected void rptPending_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "Approve" && e.CommandName != "Reject") return;

            // Parse: sourceType|requestId|teacherUserId|teacherName|title
            string[] parts = e.CommandArgument.ToString().Split('|');
            if (parts.Length < 5) return;

            string sourceType    = parts[0];
            string id            = parts[1];
            string teacherUserId = parts[2];
            string teacherName   = parts[3];
            string contentTitle  = parts[4];
            string newStatus     = e.CommandName == "Approve" ? "Approved" : "Rejected";

            bool ok = UpdateStatus(sourceType, id, newStatus);
            if (!ok)
            {
                LoadSummary();
                LoadTables(txtSearch.Text.Trim(), ddlStatus.SelectedValue, ddlType.SelectedValue);
                ShowToast("<i class=\"bi bi-x-circle-fill\"></i> " + T("Failed to update status.", "Gagal mengemas kini status."), "sb-alert-error");
                return;
            }

            if (e.CommandName == "Approve")
            {
                // ── APPROVE: Insert notification directly, stay on page ──
                InsertApprovalNotification(teacherUserId, contentTitle);

                LoadSummary();
                LoadTables(txtSearch.Text.Trim(), ddlStatus.SelectedValue, ddlType.SelectedValue);
                ShowToast("<i class=\"bi bi-check-circle-fill\"></i> " +
                    T("Content approved successfully. Notification sent to the teacher.",
                      "Kandungan berjaya diluluskan. Notifikasi telah dihantar kepada guru."),
                    "sb-alert-success");
            }
            else
            {
                // ── REJECT: Store in Session, redirect to Notifications ──
                Session["notif_action"]        = "Rejected";
                Session["notif_teacherUserId"] = teacherUserId;
                Session["notif_teacherName"]   = teacherName;
                Session["notif_contentTitle"]  = contentTitle;
                Session["notif_contentType"]   = sourceType;
                Session["notif_requestId"]     = id;

                Response.Redirect("~/Admin/Notifications.aspx?from=contentrequest", false);
                Context.ApplicationInstance.CompleteRequest();
            }
        }

        // ── Insert approval notification directly ────────────────────
        private void InsertApprovalNotification(string teacherUserId, string contentTitle)
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    string notifId = GenerateNextNotifId(conn);

                    string titleEN = "Content Request Approved";
                    string titleBM = "Permohonan Kandungan Diluluskan";
                    string msgEN   = string.Format(
                        "Your learning content \"{0}\" has been approved and is now available in ScienceBuddy.", contentTitle);
                    string msgBM   = string.Format(
                        "Kandungan pembelajaran \"{0}\" telah diluluskan dan kini tersedia dalam ScienceBuddy.", contentTitle);

                    using (var cmd = new SqlCommand(@"
                        INSERT INTO dbo.[Notification]
                            ([notificationId],[toUserId],[titleEN],[titleBM],[messageEN],[messageBM],[isRead],[createdAt])
                        VALUES (@id,@uid,@tEN,@tBM,@mEN,@mBM,0,GETDATE())", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", notifId);
                        cmd.Parameters.AddWithValue("@uid", teacherUserId);
                        cmd.Parameters.AddWithValue("@tEN", titleEN);
                        cmd.Parameters.AddWithValue("@tBM", titleBM);
                        cmd.Parameters.AddWithValue("@mEN", msgEN);
                        cmd.Parameters.AddWithValue("@mBM", msgBM);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch { /* Notification insert failure should not block approval */ }
        }

        // ── Generate next notification ID (N001, N002, etc.) ─────────
        private string GenerateNextNotifId(SqlConnection conn)
        {
            using (var cmd = new SqlCommand(
                "SELECT MAX(CAST(SUBSTRING([notificationId],2,LEN([notificationId])-1) AS INT)) FROM dbo.[Notification]", conn))
            {
                var val = cmd.ExecuteScalar();
                int next = (val != null && val != DBNull.Value) ? Convert.ToInt32(val) + 1 : 1;
                return "N" + next.ToString("D3");
            }
        }

        // ── Update status in DB ──────────────────────────────────────
        private bool UpdateStatus(string sourceType, string id, string newStatus)
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    string sql;
                    SqlCommand cmd;

                    if (sourceType == "Material")
                    {
                        sql = @"UPDATE dbo.[Material]
                                SET [status]       = @status,
                                    [reviewedDate] = @reviewed
                                WHERE [materialId] = @id";
                        cmd = new SqlCommand(sql, conn);
                        cmd.Parameters.AddWithValue("@status",   newStatus);
                        cmd.Parameters.AddWithValue("@reviewed", DateTime.Today);
                        cmd.Parameters.AddWithValue("@id",       id);
                    }
                    else // Practice Quiz — Quiz has no reviewedDate column per schema
                    {
                        sql = @"UPDATE dbo.[Quiz]
                                SET [status] = @status
                                WHERE [quizId]    = @id
                                AND   [quizType]  = 'Practice'";
                        cmd = new SqlCommand(sql, conn);
                        cmd.Parameters.AddWithValue("@status", newStatus);
                        cmd.Parameters.AddWithValue("@id",     id);
                    }

                    int affected = cmd.ExecuteNonQuery();
                    return affected > 0;
                }
            }
            catch { return false; }
        }

        // ── Toast helper ─────────────────────────────────────────────
        private void ShowToast(string html, string cssClass)
        {
            pnlToast.Visible = true;
            litToast.Text    = string.Format(
                "<span class=\"alert-icon\"></span><div class=\"alert-content\">{0}</div>",
                html);
            // Apply the correct alert class via attribute
            pnlToast.Attributes["class"] = "";
            litToast.Text = string.Format(
                "<div class=\"sb-alert {0}\" style=\"position:fixed;bottom:24px;right:24px;z-index:3000;max-width:380px;\">" +
                "<span class=\"alert-icon\"></span>" +
                "<div class=\"alert-content\">{1}</div></div>",
                cssClass, html);
        }

        // ── Status badge HTML ─────────────────────────────────────────
        protected string BuildStatusBadge(string status)
        {
            if (string.IsNullOrWhiteSpace(status)) return "";
            switch (status)
            {
                case "Approved": return "<span class=\"sb-badge sb-badge-success\"><i class=\"bi bi-check-circle-fill\"></i> Approved</span>";
                case "Rejected": return "<span class=\"sb-badge sb-badge-error\"><i class=\"bi bi-x-circle-fill\"></i> Rejected</span>";
                case "Pending":  return "<span class=\"sb-badge sb-badge-warning\"><i class=\"bi bi-hourglass-split\"></i> Pending</span>";
                default:         return string.Format("<span class=\"sb-badge sb-badge-gray\">{0}</span>", HttpUtility.HtmlEncode(status));
            }
        }

        // ── HtmlEncode for repeater bindings ─────────────────────────
        protected string HtmlEncode(object value)
        {
            return HttpUtility.HtmlEncode(value?.ToString() ?? "");
        }
    }
}
