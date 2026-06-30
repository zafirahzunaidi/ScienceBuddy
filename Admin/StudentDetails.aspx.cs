using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace ScienceBuddy.Admin
{
    public partial class StudentDetails : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        protected string CurrentLanguage => ((ScienceBuddy.SiteMaster)Master).CurrentLanguage;
        protected string T(string en, string bm) => CurrentLanguage == "BM" ? bm : en;

        protected void Page_Load(object sender, EventArgs e)
        {
            // AJAX handler (reuses StudentManagement CRUD)
            if (Request.QueryString["handler"] == "StudentCRUD" && Request.HttpMethod == "POST")
            { HandleAjax(); return; }

            if (Session["userId"] == null || Session["role"]?.ToString() != "Admin")
            { Response.Redirect("~/Login.aspx", false); return; }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                SetUserInfo();
                string id = Request.QueryString["id"] ?? "";
                if (string.IsNullOrEmpty(id)) { Response.Redirect("~/Admin/StudentManagement.aspx", false); return; }
                LoadStudent(id);
            }
        }

        private void SetUserInfo()
        {
            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                using (var cmd = new SqlCommand("SELECT [username] FROM dbo.[User] WHERE [userId]=@u", conn))
                { cmd.Parameters.AddWithValue("@u", Session["userId"].ToString()); var v = cmd.ExecuteScalar(); string name = v?.ToString() ?? "Admin";
                  ((ScienceBuddy.SiteMaster)Master).SetUserInfo(name, "Administrator", name.Length >= 2 ? name.Substring(0, 2).ToUpper() : name.ToUpper()); } }
        }

        private void LoadStudent(string studentId)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                string sql = @"SELECT s.[studentId],s.[name],s.[phoneNumber],s.[XP],s.[currentLevelId],
                    u.[userId],u.[username],u.[email],u.[status],u.[preferredLanguage],
                    ISNULL(lv.[levelNameEN],'-') AS levelName,
                    (SELECT COUNT(*) FROM dbo.[StudentBadge] WHERE [studentId]=s.[studentId]) AS badges,
                    (SELECT COUNT(*) FROM dbo.[LessonProgress] WHERE [studentId]=s.[studentId] AND [isCompleted]=1) AS lessons
                    FROM dbo.[Student] s
                    LEFT JOIN dbo.[User] u ON u.[userId]=s.[userId]
                    LEFT JOIN dbo.[Level] lv ON lv.[levelId]=s.[currentLevelId]
                    WHERE s.[studentId]=@sid";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@sid", studentId);
                    using (var rd = cmd.ExecuteReader())
                    {
                        if (!rd.Read()) { Response.Redirect("~/Admin/StudentManagement.aspx", false); return; }
                        string name = NS(rd["name"]); string username = NS(rd["username"]); string email = NS(rd["email"]);
                        string phone = NS(rd["phoneNumber"]); string status = NS(rd["status"]); string userId = NS(rd["userId"]);
                        int xp = rd["XP"] != DBNull.Value ? Convert.ToInt32(rd["XP"]) : 0;
                        string level = NS(rd["levelName"]);

                        hfStudentId.Value = studentId;
                        hfUserId.Value = userId;
                        litInitials.Text = name.Length >= 2 ? name.Substring(0, 2).ToUpper() : "S";
                        litName.Text = HttpUtility.HtmlEncode(name);
                        litStudentId.Text = studentId;
                        litUsername.Text = HttpUtility.HtmlEncode(username);
                        litEmail.Text = HttpUtility.HtmlEncode(email);
                        litXP.Text = xp.ToString();
                        litBadges.Text = rd["badges"].ToString();
                        litLessons.Text = rd["lessons"].ToString();
                        litStatusBadge.Text = status == "Active"
                            ? "<span class='sb-badge sb-badge-success'>" + T("Active", "Aktif") + "</span>"
                            : "<span class='sb-badge sb-badge-error'>" + HttpUtility.HtmlEncode(status) + "</span>";

                        // Profile tab fields
                        litProfileFields.Text =
                            Field(T("Full Name", "Nama Penuh"), name) +
                            Field(T("Username", "Nama Pengguna"), username) +
                            Field(T("Email", "E-mel"), email) +
                            Field(T("Phone", "Telefon"), phone) +
                            Field(T("Level", "Tahap"), level) +
                            Field(T("Language", "Bahasa"), NS(rd["preferredLanguage"]) == "BM" ? "Bahasa Melayu" : "English") +
                            Field("XP", xp.ToString());

                        // Account tab fields
                        litAccountFields.Text =
                            Field(T("User ID", "ID Pengguna"), userId) +
                            Field(T("Student ID", "ID Pelajar"), studentId) +
                            Field(T("Current Status", "Status Semasa"), status) +
                            Field(T("Role", "Peranan"), "Student") +
                            Field(T("Level", "Tahap"), level);
                    }
                }

                // Activity log
                LoadActivityLog(conn, studentId);
                // Security log
                LoadSecurityLog(conn, studentId);
            }
        }

        private void LoadActivityLog(SqlConnection conn, string studentId)
        {
            // Get userId for this student
            string userId = hfUserId.Value;
            string sql = @"SELECT TOP 20 [action],[description],[logDateTime],[status]
                FROM dbo.[Log] WHERE [userId]=@uid ORDER BY [logDateTime] DESC";
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@uid", userId);
                using (var rd = cmd.ExecuteReader())
                {
                    string html = "";
                    bool hasRows = false;
                    while (rd.Read())
                    {
                        hasRows = true;
                        string dt = rd["logDateTime"] != DBNull.Value ? Convert.ToDateTime(rd["logDateTime"]).ToString("dd MMM yyyy HH:mm") : "-";
                        html += "<div class='sd-log-item'><div class='sd-log-ico'><i class='bi bi-activity'></i></div><div class='sd-log-body'><div class='sd-log-action'>" +
                            HttpUtility.HtmlEncode(NS(rd["action"])) + "</div><div class='sd-log-desc'>" +
                            HttpUtility.HtmlEncode(NS(rd["description"])) + "</div><div class='sd-log-time'>" + dt + "</div></div></div>";
                    }
                    litActivityLog.Text = hasRows ? html : "<div class='qb-empty' style='padding:2rem;'><i class='bi bi-clock-history' style='font-size:2rem;opacity:.4;'></i><div style='margin-top:8px;font-size:.9rem;color:var(--color-text-muted);'>" + T("No activity records.", "Tiada rekod aktiviti.") + "</div></div>";
                }
            }
        }

        private void LoadSecurityLog(SqlConnection conn, string studentId)
        {
            string userId = hfUserId.Value;
            string sql = @"SELECT TOP 15 [actionType],[reason],[actionDate],[performedBy]
                FROM dbo.[UserStatusAction] WHERE [userId]=@uid ORDER BY [actionDate] DESC";
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@uid", userId);
                using (var rd = cmd.ExecuteReader())
                {
                    string html = "";
                    bool hasRows = false;
                    while (rd.Read())
                    {
                        hasRows = true;
                        string dt = rd["actionDate"] != DBNull.Value ? Convert.ToDateTime(rd["actionDate"]).ToString("dd MMM yyyy") : "-";
                        string icon = NS(rd["actionType"]).Contains("Block") ? "bi-slash-circle" : NS(rd["actionType"]).Contains("Delete") ? "bi-trash" : "bi-shield-check";
                        html += "<div class='sd-log-item'><div class='sd-log-ico' style='background:#FEE2E2;color:#DC2626;'><i class='bi " + icon + "'></i></div><div class='sd-log-body'><div class='sd-log-action'>" +
                            HttpUtility.HtmlEncode(NS(rd["actionType"])) + "</div><div class='sd-log-desc'>" +
                            HttpUtility.HtmlEncode(NS(rd["reason"])) + "</div><div class='sd-log-time'>" + dt + " | " + T("By: ", "Oleh: ") + HttpUtility.HtmlEncode(NS(rd["performedBy"])) + "</div></div></div>";
                    }
                    litSecurityLog.Text = hasRows ? html : "<div class='qb-empty' style='padding:2rem;'><i class='bi bi-shield-check' style='font-size:2rem;opacity:.4;color:#059669;'></i><div style='margin-top:8px;font-size:.9rem;color:var(--color-text-muted);'>" + T("No security actions recorded.", "Tiada tindakan keselamatan direkodkan.") + "</div></div>";
                }
            }
        }

        private string Field(string label, string value)
        {
            return "<div class='sd-field'><div class='sd-field-label'>" + HttpUtility.HtmlEncode(label) + "</div><div class='sd-field-value'>" + HttpUtility.HtmlEncode(value ?? "-") + "</div></div>";
        }

        // ── AJAX (same handlers as StudentManagement) ──
        private void HandleAjax()
        {
            Response.ContentType = "application/json";
            try
            {
                if (Session["userId"] == null) { Response.Write("{\"success\":false}"); Response.End(); return; }
                string action = Request.QueryString["action"] ?? "";
                string adminId = Session["userId"].ToString();
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    switch (action)
                    {
                        case "getStudent":
                            string sid = Request.QueryString["studentId"] ?? "";
                            using (var cmd = new SqlCommand("SELECT s.[studentId],s.[name],s.[phoneNumber],u.[email] FROM dbo.[Student] s LEFT JOIN dbo.[User] u ON u.[userId]=s.[userId] WHERE s.[studentId]=@sid", conn))
                            { cmd.Parameters.AddWithValue("@sid", sid); using (var rd = cmd.ExecuteReader()) { if (rd.Read()) Response.Write("{\"success\":true,\"data\":{\"name\":\"" + EJ(rd["name"]) + "\",\"email\":\"" + EJ(rd["email"]) + "\",\"phone\":\"" + EJ(rd["phoneNumber"]) + "\"}}"); else Response.Write("{\"success\":false}"); } }
                            break;
                        case "edit":
                            string eId = Request.QueryString["studentId"] ?? "";
                            string eName = Request.QueryString["name"] ?? "";
                            string eEmail = Request.QueryString["email"] ?? "";
                            string ePhone = Request.QueryString["phone"] ?? "";
                            string uId = ""; using (var cmd = new SqlCommand("SELECT [userId] FROM dbo.[Student] WHERE [studentId]=@s", conn)) { cmd.Parameters.AddWithValue("@s", eId); var v = cmd.ExecuteScalar(); uId = v?.ToString() ?? ""; }
                            using (var cmd = new SqlCommand("UPDATE dbo.[Student] SET [name]=@n,[phoneNumber]=@p WHERE [studentId]=@s", conn)) { cmd.Parameters.AddWithValue("@n", eName); cmd.Parameters.AddWithValue("@p", (object)ePhone ?? DBNull.Value); cmd.Parameters.AddWithValue("@s", eId); cmd.ExecuteNonQuery(); }
                            if (!string.IsNullOrEmpty(eEmail) && !string.IsNullOrEmpty(uId)) { using (var cmd = new SqlCommand("UPDATE dbo.[User] SET [email]=@e WHERE [userId]=@u", conn)) { cmd.Parameters.AddWithValue("@e", eEmail); cmd.Parameters.AddWithValue("@u", uId); cmd.ExecuteNonQuery(); } }
                            ILog(conn, adminId, "Updated Student", "Updated " + eId);
                            Response.Write("{\"success\":true}");
                            break;
                        case "changeStatus":
                            string csId = Request.QueryString["studentId"] ?? "";
                            string csStatus = Request.QueryString["newStatus"] ?? "";
                            string csReason = Request.QueryString["reason"] ?? "";
                            string csUid = ""; using (var cmd = new SqlCommand("SELECT [userId] FROM dbo.[Student] WHERE [studentId]=@s", conn)) { cmd.Parameters.AddWithValue("@s", csId); var v = cmd.ExecuteScalar(); csUid = v?.ToString() ?? ""; }
                            using (var cmd = new SqlCommand("UPDATE dbo.[User] SET [status]=@st WHERE [userId]=@u", conn)) { cmd.Parameters.AddWithValue("@st", csStatus); cmd.Parameters.AddWithValue("@u", csUid); cmd.ExecuteNonQuery(); }
                            string aId = GID(conn, "UserStatusAction", "actionId", "USA");
                            using (var cmd = new SqlCommand("INSERT INTO dbo.[UserStatusAction]([actionId],[userId],[actionType],[reason],[actionDate],[performedBy]) VALUES(@a,@u,@t,@r,@d,@p)", conn))
                            { cmd.Parameters.AddWithValue("@a", aId); cmd.Parameters.AddWithValue("@u", csUid); cmd.Parameters.AddWithValue("@t", csStatus); cmd.Parameters.AddWithValue("@r", string.IsNullOrEmpty(csReason) ? "Changed by admin." : csReason); cmd.Parameters.AddWithValue("@d", DateTime.Today); cmd.Parameters.AddWithValue("@p", adminId); cmd.ExecuteNonQuery(); }
                            ILog(conn, adminId, "Status Changed", csId + " -> " + csStatus);
                            Response.Write("{\"success\":true}");
                            break;
                        case "archive":
                            string arId = Request.QueryString["studentId"] ?? "";
                            string arUid = ""; using (var cmd = new SqlCommand("SELECT [userId] FROM dbo.[Student] WHERE [studentId]=@s", conn)) { cmd.Parameters.AddWithValue("@s", arId); var v = cmd.ExecuteScalar(); arUid = v?.ToString() ?? ""; }
                            using (var cmd = new SqlCommand("UPDATE dbo.[User] SET [status]='Deleted' WHERE [userId]=@u", conn)) { cmd.Parameters.AddWithValue("@u", arUid); cmd.ExecuteNonQuery(); }
                            ILog(conn, adminId, "Archived Student", arId);
                            Response.Write("{\"success\":true}");
                            break;
                        case "resetPw":
                            string rpId = Request.QueryString["studentId"] ?? "";
                            string rpUid = ""; using (var cmd = new SqlCommand("SELECT [userId] FROM dbo.[Student] WHERE [studentId]=@s", conn)) { cmd.Parameters.AddWithValue("@s", rpId); var v = cmd.ExecuteScalar(); rpUid = v?.ToString() ?? ""; }
                            string newPw = "SB" + DateTime.Now.ToString("HHmmss");
                            using (var cmd = new SqlCommand("UPDATE dbo.[User] SET [password]=@p WHERE [userId]=@u", conn)) { cmd.Parameters.AddWithValue("@p", newPw); cmd.Parameters.AddWithValue("@u", rpUid); cmd.ExecuteNonQuery(); }
                            ILog(conn, adminId, "Password Reset", "Reset password for " + rpId);
                            Response.Write("{\"success\":true,\"newPw\":\"" + newPw + "\"}");
                            break;
                        default: Response.Write("{\"success\":false}"); break;
                    }
                }
            }
            catch (Exception ex) { Response.Write("{\"success\":false,\"msg\":\"" + EJ(ex.Message) + "\"}"); }
            Response.End();
        }

        private void ILog(SqlConnection c, string uid, string act, string desc)
        { string id = GID(c, "Log", "logId", "LOG"); using (var cmd = new SqlCommand("INSERT INTO dbo.[Log]([logId],[userId],[action],[description],[logDateTime],[status]) VALUES(@a,@b,@c,@d,@e,'Success')", c)) { cmd.Parameters.AddWithValue("@a", id); cmd.Parameters.AddWithValue("@b", uid); cmd.Parameters.AddWithValue("@c", act); cmd.Parameters.AddWithValue("@d", desc); cmd.Parameters.AddWithValue("@e", DateTime.Now); cmd.ExecuteNonQuery(); } }

        private string GID(SqlConnection c, string tbl, string col, string pfx)
        { using (var cmd = new SqlCommand(string.Format("SELECT TOP 1 [{0}] FROM dbo.[{1}] ORDER BY [{0}] DESC", col, tbl), c)) { var v = cmd.ExecuteScalar(); if (v == null || v == DBNull.Value) return pfx + "001"; string l = v.ToString(); int n; int.TryParse(l.Substring(pfx.Length), out n); n++; return pfx + n.ToString().PadLeft(l.Length - pfx.Length, '0'); } }

        private static string NS(object v) { return (v == null || v == DBNull.Value) ? "" : v.ToString(); }
        private static string EJ(object v) { string s = NS(v); return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", ""); }
    }
}
