using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace ScienceBuddy.Admin
{
    public partial class TeacherDetails : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        protected string CurrentLanguage => ((ScienceBuddy.SiteMaster)Master).CurrentLanguage;
        protected string T(string en, string bm) => CurrentLanguage == "BM" ? bm : en;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.QueryString["handler"] == "TeacherCRUD" && Request.HttpMethod == "POST") { HandleAjax(); return; }
            if (Session["userId"] == null || Session["role"]?.ToString() != "Admin") { Response.Redirect("~/Login.aspx", false); return; }
            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            if (!IsPostBack) { SetUserInfo(); string id = Request.QueryString["id"] ?? ""; if (string.IsNullOrEmpty(id)) { Response.Redirect("~/Admin/TeacherManagement.aspx", false); return; } LoadTeacher(id); }
        }

        private void SetUserInfo() { using (var c = new SqlConnection(ConnStr)) { c.Open(); using (var cmd = new SqlCommand("SELECT [username] FROM dbo.[User] WHERE [userId]=@u", c)) { cmd.Parameters.AddWithValue("@u", Session["userId"].ToString()); var v = cmd.ExecuteScalar(); string n = v?.ToString() ?? "Admin"; ((ScienceBuddy.SiteMaster)Master).SetUserInfo(n, "Administrator", n.Length >= 2 ? n.Substring(0, 2).ToUpper() : n.ToUpper()); } } }

        private void LoadTeacher(string teacherId)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(@"SELECT t.[teacherId],t.[name],t.[phoneNumber],t.[academicQualification],t.[bio],t.[status] AS tStatus,
                    u.[userId],u.[username],u.[email],u.[status],
                    (SELECT COUNT(*) FROM dbo.[Material] WHERE [createdByUserId]=u.[userId]) AS materials,
                    (SELECT COUNT(*) FROM dbo.[Quiz] WHERE [createdByUserId]=u.[userId]) AS quizzes
                    FROM dbo.[Teacher] t LEFT JOIN dbo.[User] u ON u.[userId]=t.[userId] WHERE t.[teacherId]=@tid", conn))
                {
                    cmd.Parameters.AddWithValue("@tid", teacherId);
                    using (var rd = cmd.ExecuteReader())
                    {
                        if (!rd.Read()) { Response.Redirect("~/Admin/TeacherManagement.aspx", false); return; }
                        string name = NS(rd["name"]); string username = NS(rd["username"]); string email = NS(rd["email"]);
                        string phone = NS(rd["phoneNumber"]); string status = NS(rd["status"]); string userId = NS(rd["userId"]);
                        string qualification = NS(rd["academicQualification"]); string bio = NS(rd["bio"]);
                        hfTeacherId.Value = teacherId; hfUserId.Value = userId;
                        litInitials.Text = name.Length >= 2 ? name.Substring(0, 2).ToUpper() : "T";
                        litName.Text = HttpUtility.HtmlEncode(name); litTeacherId.Text = teacherId;
                        litUsername.Text = HttpUtility.HtmlEncode(username); litEmail.Text = HttpUtility.HtmlEncode(email);
                        litMaterials.Text = rd["materials"].ToString(); litQuizzes.Text = rd["quizzes"].ToString();
                        litStatusBadge.Text = status == "Active" ? "<span class='sb-badge sb-badge-success'>" + T("Active", "Aktif") + "</span>" : "<span class='sb-badge sb-badge-error'>" + HttpUtility.HtmlEncode(status) + "</span>";
                        litProfileFields.Text = F(T("Full Name","Nama Penuh"), name) + F(T("Username","Nama Pengguna"), username) + F(T("Email","E-mel"), email) + F(T("Phone","Telefon"), phone) + F(T("Qualification","Kelayakan"), qualification) + F(T("Bio","Bio"), bio);
                        litAccountFields.Text = F(T("User ID","ID Pengguna"), userId) + F(T("Teacher ID","ID Guru"), teacherId) + F(T("Status","Status"), status) + F(T("Role","Peranan"), "Teacher") + F(T("Materials Uploaded","Bahan Dimuat Naik"), rd["materials"].ToString()) + F(T("Quizzes Created","Kuiz Dicipta"), rd["quizzes"].ToString());
                    }
                }
                // Activity
                using (var cmd = new SqlCommand("SELECT TOP 20 [action],[description],[logDateTime] FROM dbo.[Log] WHERE [userId]=@u ORDER BY [logDateTime] DESC", conn))
                {
                    cmd.Parameters.AddWithValue("@u", hfUserId.Value); string html = ""; bool has = false;
                    using (var rd = cmd.ExecuteReader()) { while (rd.Read()) { has = true; string dt = rd["logDateTime"] != DBNull.Value ? Convert.ToDateTime(rd["logDateTime"]).ToString("dd MMM yyyy HH:mm") : "-"; html += "<div class='sd-log-item'><div class='sd-log-ico'><i class='bi bi-activity'></i></div><div class='sd-log-body'><div class='sd-log-action'>" + HttpUtility.HtmlEncode(NS(rd["action"])) + "</div><div class='sd-log-desc'>" + HttpUtility.HtmlEncode(NS(rd["description"])) + "</div><div class='sd-log-time'>" + dt + "</div></div></div>"; } }
                    litActivityLog.Text = has ? html : "<div style='text-align:center;padding:2rem;color:var(--color-text-muted);'><i class='bi bi-clock-history' style='font-size:2rem;opacity:.4;'></i><p style='margin-top:8px;'>" + T("No activity.", "Tiada aktiviti.") + "</p></div>";
                }
            }
        }

        private void HandleAjax()
        {
            Response.ContentType = "application/json";
            try
            {
                if (Session["userId"] == null) { Response.Write("{\"success\":false}"); Response.End(); return; }
                string action = Request.QueryString["action"] ?? ""; string adminId = Session["userId"].ToString();
                string teacherId = Request.QueryString["teacherId"] ?? "";
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    string userId = ""; using (var cmd = new SqlCommand("SELECT [userId] FROM dbo.[Teacher] WHERE [teacherId]=@t", conn)) { cmd.Parameters.AddWithValue("@t", teacherId); var v = cmd.ExecuteScalar(); userId = v?.ToString() ?? ""; }
                    switch (action)
                    {
                        case "get":
                            using (var cmd = new SqlCommand("SELECT t.[name],t.[phoneNumber],u.[email] FROM dbo.[Teacher] t LEFT JOIN dbo.[User] u ON u.[userId]=t.[userId] WHERE t.[teacherId]=@t", conn))
                            { cmd.Parameters.AddWithValue("@t", teacherId); using (var rd = cmd.ExecuteReader()) { if (rd.Read()) Response.Write("{\"success\":true,\"data\":{\"name\":\"" + EJ(rd["name"]) + "\",\"email\":\"" + EJ(rd["email"]) + "\",\"phone\":\"" + EJ(rd["phoneNumber"]) + "\"}}"); else Response.Write("{\"success\":false}"); } } break;
                        case "edit":
                            string n = Request.QueryString["name"] ?? ""; string em = Request.QueryString["email"] ?? ""; string ph = Request.QueryString["phone"] ?? "";
                            using (var cmd = new SqlCommand("UPDATE dbo.[Teacher] SET [name]=@n,[phoneNumber]=@p WHERE [teacherId]=@t", conn)) { cmd.Parameters.AddWithValue("@n", n); cmd.Parameters.AddWithValue("@p", (object)ph ?? DBNull.Value); cmd.Parameters.AddWithValue("@t", teacherId); cmd.ExecuteNonQuery(); }
                            if (!string.IsNullOrEmpty(em)) { using (var cmd = new SqlCommand("UPDATE dbo.[User] SET [email]=@e WHERE [userId]=@u", conn)) { cmd.Parameters.AddWithValue("@e", em); cmd.Parameters.AddWithValue("@u", userId); cmd.ExecuteNonQuery(); } }
                            ILog(conn, adminId, "Updated Teacher", "Updated " + teacherId); Response.Write("{\"success\":true}"); break;
                        case "changeStatus":
                            string st = Request.QueryString["newStatus"] ?? ""; string reason = Request.QueryString["reason"] ?? "";
                            using (var cmd = new SqlCommand("UPDATE dbo.[User] SET [status]=@s WHERE [userId]=@u", conn)) { cmd.Parameters.AddWithValue("@s", st); cmd.Parameters.AddWithValue("@u", userId); cmd.ExecuteNonQuery(); }
                            string aId = GID(conn, "UserStatusAction", "actionId", "USA");
                            using (var cmd = new SqlCommand("INSERT INTO dbo.[UserStatusAction]([actionId],[userId],[actionType],[reason],[actionDate],[performedBy]) VALUES(@a,@u,@t,@r,@d,@p)", conn)) { cmd.Parameters.AddWithValue("@a", aId); cmd.Parameters.AddWithValue("@u", userId); cmd.Parameters.AddWithValue("@t", st); cmd.Parameters.AddWithValue("@r", string.IsNullOrEmpty(reason) ? "Changed by admin." : reason); cmd.Parameters.AddWithValue("@d", DateTime.Today); cmd.Parameters.AddWithValue("@p", adminId); cmd.ExecuteNonQuery(); }
                            ILog(conn, adminId, "Teacher Status Changed", teacherId + " -> " + st); Response.Write("{\"success\":true}"); break;
                        case "archive":
                            using (var cmd = new SqlCommand("UPDATE dbo.[User] SET [status]='Deleted' WHERE [userId]=@u", conn)) { cmd.Parameters.AddWithValue("@u", userId); cmd.ExecuteNonQuery(); }
                            ILog(conn, adminId, "Archived Teacher", teacherId); Response.Write("{\"success\":true}"); break;
                        case "resetPw":
                            string pw = "SB" + DateTime.Now.ToString("HHmmss");
                            using (var cmd = new SqlCommand("UPDATE dbo.[User] SET [password]=@p WHERE [userId]=@u", conn)) { cmd.Parameters.AddWithValue("@p", pw); cmd.Parameters.AddWithValue("@u", userId); cmd.ExecuteNonQuery(); }
                            ILog(conn, adminId, "Password Reset", "Reset for " + teacherId); Response.Write("{\"success\":true,\"newPw\":\"" + pw + "\"}"); break;
                        default: Response.Write("{\"success\":false}"); break;
                    }
                }
            } catch (Exception ex) { Response.Write("{\"success\":false,\"msg\":\"" + EJ(ex.Message) + "\"}"); }
            Response.End();
        }

        private string F(string l, string v) { return "<div class='sd-field'><div class='sd-field-label'>" + HttpUtility.HtmlEncode(l) + "</div><div class='sd-field-value'>" + HttpUtility.HtmlEncode(v ?? "-") + "</div></div>"; }
        private void ILog(SqlConnection c, string uid, string act, string desc) { string id = GID(c, "Log", "logId", "LOG"); using (var cmd = new SqlCommand("INSERT INTO dbo.[Log]([logId],[userId],[action],[description],[logDateTime],[status]) VALUES(@a,@b,@c,@d,@e,'Success')", c)) { cmd.Parameters.AddWithValue("@a", id); cmd.Parameters.AddWithValue("@b", uid); cmd.Parameters.AddWithValue("@c", act); cmd.Parameters.AddWithValue("@d", desc); cmd.Parameters.AddWithValue("@e", DateTime.Now); cmd.ExecuteNonQuery(); } }
        private string GID(SqlConnection c, string tbl, string col, string pfx) { using (var cmd = new SqlCommand(string.Format("SELECT TOP 1 [{0}] FROM dbo.[{1}] ORDER BY [{0}] DESC", col, tbl), c)) { var v = cmd.ExecuteScalar(); if (v == null || v == DBNull.Value) return pfx + "001"; string l = v.ToString(); int n; int.TryParse(l.Substring(pfx.Length), out n); n++; return pfx + n.ToString().PadLeft(l.Length - pfx.Length, '0'); } }
        private static string NS(object v) { return (v == null || v == DBNull.Value) ? "" : v.ToString(); }
        private static string EJ(object v) { string s = NS(v); return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", ""); }
    }
}
