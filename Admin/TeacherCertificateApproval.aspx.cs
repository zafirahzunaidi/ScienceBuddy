using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace ScienceBuddy.Admin
{
    public partial class TeacherCertificateApproval : Page
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
            if (Session["userId"] == null)
            { Response.Redirect("~/Login.aspx", false); return; }
            if (Session["role"] == null || Session["role"].ToString() != "Admin")
            { Response.Redirect("~/Login.aspx", false); return; }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                SetMasterUser();
                LoadSummary();
                LoadTeachers("", "", "newest");
            }

            // Bilingual labels
            txtSearch.Attributes["placeholder"] = T("Search by name, ID or qualification…", "Cari mengikut nama, ID atau kelayakan…");
            btnSearch.Text = T("Search", "Cari");
            btnReset.Text = T("Reset", "Tetapkan Semula");
        }

        // ── Master user widget ───────────────────────────────────────
        private void SetMasterUser()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [username] FROM dbo.[User] WHERE [userId]=@uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", Session["userId"].ToString());
                    var val = cmd.ExecuteScalar();
                    string name = (val != null && val != DBNull.Value) ? val.ToString() : "Admin";
                    string initials = name.Length >= 2 ? name.Substring(0, 2).ToUpper() : name.ToUpper();
                    ((ScienceBuddy.SiteMaster)Master).SetUserInfo(name, "Administrator", initials);
                }
            }
        }

        // ── Load Summary Cards ───────────────────────────────────────
        private void LoadSummary()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                litPending.Text = SafeCount(conn, "SELECT COUNT(*) FROM dbo.[Teacher] WHERE [status]='Pending'").ToString();
                litCertified.Text = SafeCount(conn, "SELECT COUNT(*) FROM dbo.[Teacher] WHERE [status]='Certified'").ToString();
                litNotCertified.Text = SafeCount(conn, "SELECT COUNT(*) FROM dbo.[Teacher] WHERE [status]='Not Certified'").ToString();
                litTotal.Text = SafeCount(conn, "SELECT COUNT(*) FROM dbo.[Teacher] WHERE [licenseCert] IS NOT NULL AND [licenseCert] <> ''").ToString();
            }
        }

        // ── Load Teachers ────────────────────────────────────────────
        private void LoadTeachers(string search, string statusFilter, string sortBy)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                string sql = @"
                    SELECT t.[teacherId], t.[userId], t.[name], t.[academicQualification],
                           t.[licenseCert], t.[status], t.[approvedDate]
                    FROM dbo.[Teacher] t
                    WHERE t.[licenseCert] IS NOT NULL AND t.[licenseCert] <> ''";

                if (!string.IsNullOrWhiteSpace(search))
                    sql += " AND (t.[name] LIKE @search OR t.[teacherId] LIKE @search OR t.[academicQualification] LIKE @search)";
                if (!string.IsNullOrWhiteSpace(statusFilter))
                    sql += " AND t.[status] = @status";

                // Priority: Pending first, then Certified, then Not Certified
                sql += " ORDER BY CASE t.[status] WHEN 'Pending' THEN 0 WHEN 'Certified' THEN 1 ELSE 2 END";

                switch (sortBy)
                {
                    case "oldest": sql += ", t.[approvedDate] ASC, t.[teacherId] ASC"; break;
                    default: sql += ", t.[approvedDate] DESC, t.[teacherId] DESC"; break;
                }

                using (var cmd = new SqlCommand(sql, conn))
                {
                    if (!string.IsNullOrWhiteSpace(search))
                        cmd.Parameters.AddWithValue("@search", "%" + search + "%");
                    if (!string.IsNullOrWhiteSpace(statusFilter))
                        cmd.Parameters.AddWithValue("@status", statusFilter);

                    var da = new SqlDataAdapter(cmd);
                    var dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count == 0)
                    {
                        pnlCards.Visible = false;
                        pnlEmpty.Visible = true;
                        return;
                    }

                    var list = new List<object>();
                    string[] gradients = {
                        "background:linear-gradient(135deg,#059669,#34D399);",
                        "background:linear-gradient(135deg,#2563EB,#60A5FA);",
                        "background:linear-gradient(135deg,#7C3AED,#A78BFA);",
                        "background:linear-gradient(135deg,#D97706,#FBBF24);",
                        "background:linear-gradient(135deg,#DC2626,#F87171);",
                        "background:linear-gradient(135deg,#0891B2,#22D3EE);"
                    };

                    int idx = 0;
                    foreach (DataRow row in dt.Rows)
                    {
                        string name = NullSafe(row["name"]);
                        string status = NullSafe(row["status"]);
                        string certFile = NullSafe(row["licenseCert"]);
                        string qualification = NullSafe(row["academicQualification"]);
                        DateTime? approvedDate = row["approvedDate"] == DBNull.Value
                            ? (DateTime?)null
                            : Convert.ToDateTime(row["approvedDate"]);

                        string badgeClass, statusLabel;
                        switch (status)
                        {
                            case "Certified":
                                badgeClass = "ad-teacher-cert-badge-certified";
                                statusLabel = T("Certified", "Bertauliah");
                                break;
                            case "Not Certified":
                                badgeClass = "ad-teacher-cert-badge-rejected";
                                statusLabel = T("Not Certified", "Tidak Bertauliah");
                                break;
                            default:
                                badgeClass = "ad-teacher-cert-badge-pending";
                                statusLabel = T("Pending", "Tertunggak");
                                break;
                        }

                        // Build certificate URL
                        string certUrl = "";
                        if (!string.IsNullOrWhiteSpace(certFile))
                        {
                            if (certFile.Contains("/") || certFile.Contains("\\"))
                                certUrl = certFile.Replace("\\", "/").Replace("~/", "");
                            else
                                certUrl = "Uploads/TeacherCertificates/" + certFile;
                        }

                        list.Add(new
                        {
                            teacherId = NullSafe(row["teacherId"]),
                            name = string.IsNullOrWhiteSpace(name) ? "Teacher" : name,
                            initials = GetInitials(name),
                            qualification = string.IsNullOrWhiteSpace(qualification) ? "-" : qualification,
                            certFile = string.IsNullOrWhiteSpace(certFile) ? "-" : System.IO.Path.GetFileName(certFile),
                            certUrl = certUrl,
                            status = status,
                            statusLabel = statusLabel,
                            badgeClass = badgeClass,
                            submittedDate = approvedDate.HasValue
                                ? approvedDate.Value.ToString("d MMM yyyy") : "-",
                            avatarGradient = gradients[idx % gradients.Length]
                        });
                        idx++;
                    }

                    pnlCards.Visible = true;
                    pnlEmpty.Visible = false;
                    rptTeachers.DataSource = list;
                    rptTeachers.DataBind();
                }
            }
        }

        // ── Search / Reset ───────────────────────────────────────────
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadSummary();
            LoadTeachers(txtSearch.Text.Trim(), ddlStatus.SelectedValue, ddlSort.SelectedValue);
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlStatus.SelectedIndex = 0;
            ddlSort.SelectedIndex = 0;
            LoadSummary();
            LoadTeachers("", "", "newest");
        }

        // ── Approve / Reject Action ─────────────────────────────────
        protected void btnDoAction_Click(object sender, EventArgs e)
        {
            string action = hfAction.Value;
            string teacherId = hfTeacherId.Value;

            if (string.IsNullOrWhiteSpace(action) || string.IsNullOrWhiteSpace(teacherId))
                return;

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Get teacher's userId for notification
                string teacherUserId = "";
                using (var cmd = new SqlCommand("SELECT [userId] FROM dbo.[Teacher] WHERE [teacherId]=@tid", conn))
                {
                    cmd.Parameters.AddWithValue("@tid", teacherId);
                    var v = cmd.ExecuteScalar();
                    teacherUserId = (v != null && v != DBNull.Value) ? v.ToString() : "";
                }

                // Check current status - only allow action on Pending certificates
                string currentStatus = "";
                using (var cmd = new SqlCommand("SELECT [status] FROM dbo.[Teacher] WHERE [teacherId]=@tid", conn))
                {
                    cmd.Parameters.AddWithValue("@tid", teacherId);
                    var v = cmd.ExecuteScalar();
                    currentStatus = (v != null && v != DBNull.Value) ? v.ToString() : "";
                }

                if (currentStatus != "Pending")
                {
                    ShowToast(T("This certificate has already been reviewed.",
                        "Sijil ini telah disemak."), false);
                    hfAction.Value = ""; hfTeacherId.Value = "";
                    LoadSummary();
                    LoadTeachers(txtSearch.Text.Trim(), ddlStatus.SelectedValue, ddlSort.SelectedValue);
                    return;
                }

                if (action == "approve")
                {
                    using (var cmd = new SqlCommand(
                        "UPDATE dbo.[Teacher] SET [status]='Certified', [approvedDate]=@dt WHERE [teacherId]=@tid", conn))
                    {
                        cmd.Parameters.AddWithValue("@dt", DateTime.Today);
                        cmd.Parameters.AddWithValue("@tid", teacherId);
                        cmd.ExecuteNonQuery();
                    }

                    InsertLog(conn, "Approved Teacher Certificate",
                        "Administrator approved teacher certificate " + teacherId + ".",
                        "Success");

                    // Send notification to teacher
                    if (!string.IsNullOrEmpty(teacherUserId))
                    {
                        InsertNotification(conn, teacherUserId,
                            "Certificate Approved", "Sijil Diluluskan",
                            "Congratulations! Your teaching certificate has been approved. You may now upload learning materials to ScienceBuddy.",
                            "Tahniah! Sijil pengajaran anda telah diluluskan. Anda kini boleh memuat naik bahan pembelajaran ke ScienceBuddy.");
                    }

                    ShowToast(T("Teacher certificate approved successfully.",
                        "Sijil guru berjaya diluluskan."), true);
                }
                else if (action == "reject")
                {
                    using (var cmd = new SqlCommand(
                        "UPDATE dbo.[Teacher] SET [status]='Not Certified', [approvedDate]=NULL WHERE [teacherId]=@tid", conn))
                    {
                        cmd.Parameters.AddWithValue("@tid", teacherId);
                        cmd.ExecuteNonQuery();
                    }

                    InsertLog(conn, "Rejected Teacher Certificate",
                        "Administrator rejected teacher certificate " + teacherId + ".",
                        "Success");

                    // Send notification to teacher
                    if (!string.IsNullOrEmpty(teacherUserId))
                    {
                        InsertNotification(conn, teacherUserId,
                            "Certificate Rejected", "Sijil Ditolak",
                            "Your teaching certificate was not approved. Please review the feedback and upload a new certificate.",
                            "Sijil pengajaran anda tidak diluluskan. Sila semak maklum balas dan muat naik sijil baharu.");
                    }

                    ShowToast(T("Teacher certificate rejected.",
                        "Sijil guru ditolak."), true);
                }
            }

            hfAction.Value = "";
            hfTeacherId.Value = "";

            LoadSummary();
            LoadTeachers(txtSearch.Text.Trim(), ddlStatus.SelectedValue, ddlSort.SelectedValue);
        }

        // ── Helpers ──────────────────────────────────────────────────
        private int SafeCount(SqlConnection conn, string sql)
        {
            try
            {
                using (var cmd = new SqlCommand(sql, conn))
                {
                    var val = cmd.ExecuteScalar();
                    return (val != null && val != DBNull.Value) ? Convert.ToInt32(val) : 0;
                }
            }
            catch { return 0; }
        }

        private void InsertLog(SqlConnection conn, string action, string desc, string status)
        {
            try
            {
                string logId = GenLogId(conn);
                using (var cmd = new SqlCommand(
                    @"INSERT INTO dbo.[Log]([logId],[userId],[action],[description],[logDateTime],[status])
                      VALUES(@id,@uid,@act,@desc,GETDATE(),@st)", conn))
                {
                    cmd.Parameters.AddWithValue("@id", logId);
                    cmd.Parameters.AddWithValue("@uid", Session["userId"].ToString());
                    cmd.Parameters.AddWithValue("@act", action);
                    cmd.Parameters.AddWithValue("@desc", desc);
                    cmd.Parameters.AddWithValue("@st", status);
                    cmd.ExecuteNonQuery();
                }
            }
            catch { /* Logging failure should not block primary operation */ }
        }

        private string GenLogId(SqlConnection conn)
        {
            try
            {
                using (var cmd = new SqlCommand(
                    "SELECT MAX(CAST(SUBSTRING([logId],4,LEN([logId])-3) AS INT)) FROM dbo.[Log]", conn))
                {
                    var val = cmd.ExecuteScalar();
                    int next = (val != null && val != DBNull.Value) ? Convert.ToInt32(val) + 1 : 1;
                    return "LOG" + next.ToString("D3");
                }
            }
            catch { return "LOG" + DateTime.Now.Ticks.ToString().Substring(10); }
        }

        private void ShowToast(string msg, bool success)
        {
            pnlToast.Visible = true;
            string cls = success ? "sb-alert-success" : "sb-alert-error";
            string icon = success ? "bi-check-circle-fill" : "bi-x-circle-fill";
            litToast.Text = string.Format(
                "<div class=\"sb-alert {0}\" style=\"position:fixed;bottom:24px;right:24px;z-index:3000;max-width:380px;animation:ad-teacher-cert-toastIn .3s ease both;\"><span class=\"alert-icon\"><i class=\"bi {1}\"></i></span><div class=\"alert-content\">{2}</div></div>",
                cls, icon, HttpUtility.HtmlEncode(msg));
        }

        private static string NullSafe(object val)
        {
            return (val == null || val == DBNull.Value) ? "" : val.ToString();
        }

        private static string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "T";
            var parts = name.Trim().Split(' ');
            if (parts.Length >= 2)
                return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
            return name.Substring(0, Math.Min(2, name.Length)).ToUpper();
        }

        private void InsertNotification(SqlConnection conn, string toUserId, string titleEN, string titleBM, string msgEN, string msgBM)
        {
            try
            {
                string notifId = GenNotifId(conn);
                using (var cmd = new SqlCommand(
                    @"INSERT INTO dbo.[Notification]([notificationId],[toUserId],[titleEN],[titleBM],[messageEN],[messageBM],[isRead],[createdAt])
                      VALUES(@id,@uid,@tEN,@tBM,@mEN,@mBM,0,GETDATE())", conn))
                {
                    cmd.Parameters.AddWithValue("@id", notifId);
                    cmd.Parameters.AddWithValue("@uid", toUserId);
                    cmd.Parameters.AddWithValue("@tEN", titleEN);
                    cmd.Parameters.AddWithValue("@tBM", titleBM);
                    cmd.Parameters.AddWithValue("@mEN", msgEN);
                    cmd.Parameters.AddWithValue("@mBM", msgBM);
                    cmd.ExecuteNonQuery();
                }
            }
            catch { }
        }

        private string GenNotifId(SqlConnection conn)
        {
            try
            {
                using (var cmd = new SqlCommand(
                    "SELECT MAX(CAST(SUBSTRING([notificationId],2,LEN([notificationId])-1) AS INT)) FROM dbo.[Notification]", conn))
                {
                    var val = cmd.ExecuteScalar();
                    int next = (val != null && val != DBNull.Value) ? Convert.ToInt32(val) + 1 : 1;
                    return "N" + next.ToString("D3");
                }
            }
            catch { return "N" + DateTime.Now.Ticks.ToString().Substring(10); }
        }
    }
}
