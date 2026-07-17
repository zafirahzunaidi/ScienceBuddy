using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace ScienceBuddy.Admin
{
    public partial class ParentDetails : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        protected string CurrentLanguage => ((ScienceBuddy.SiteMaster)Master).CurrentLanguage;
        protected string T(string en, string bm) => CurrentLanguage == "BM" ? bm : en;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.QueryString["handler"] == "ParentCRUD" && Request.HttpMethod == "POST") { HandleAjax(); return; }
            if (Session["userId"] == null || Session["role"]?.ToString() != "Admin") { Response.Redirect("~/Login.aspx", false); return; }
            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            if (!IsPostBack) { SetUserInfo(); string id = Request.QueryString["id"] ?? ""; if (string.IsNullOrEmpty(id)) { Response.Redirect("~/Admin/ParentManagement.aspx", false); return; } LoadParent(id); }
        }

        private void SetUserInfo() { using (var c = new SqlConnection(ConnStr)) { c.Open(); using (var cmd = new SqlCommand("SELECT [username] FROM dbo.[User] WHERE [userId]=@u", c)) { cmd.Parameters.AddWithValue("@u", Session["userId"].ToString()); var v = cmd.ExecuteScalar(); string n = v?.ToString() ?? "Admin"; ((ScienceBuddy.SiteMaster)Master).SetUserInfo(n, "Administrator", n.Length >= 2 ? n.Substring(0, 2).ToUpper() : n.ToUpper()); } } }

        private void LoadParent(string parentId)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(@"SELECT p.[parentId],p.[name],p.[phoneNumber],u.[userId],u.[username],u.[email],u.[status],
                    (SELECT COUNT(*) FROM dbo.[StudentParent] WHERE [parentId]=p.[parentId]) AS children
                    FROM dbo.[Parent] p LEFT JOIN dbo.[User] u ON u.[userId]=p.[userId] WHERE p.[parentId]=@pid", conn))
                {
                    cmd.Parameters.AddWithValue("@pid", parentId);
                    using (var rd = cmd.ExecuteReader())
                    {
                        if (!rd.Read()) { Response.Redirect("~/Admin/ParentManagement.aspx", false); return; }
                        string name = NS(rd["name"]); string username = NS(rd["username"]); string email = NS(rd["email"]);
                        string phone = NS(rd["phoneNumber"]); string status = NS(rd["status"]); string userId = NS(rd["userId"]);
                        hfParentId.Value = parentId; hfUserId.Value = userId; hfStatus.Value = status;
                        litInitials.Text = name.Length >= 2 ? name.Substring(0, 2).ToUpper() : "P";
                        litName.Text = HttpUtility.HtmlEncode(name); litParentId.Text = parentId;
                        litUsername.Text = HttpUtility.HtmlEncode(username); litEmail.Text = HttpUtility.HtmlEncode(email);
                        litChildren.Text = rd["children"].ToString();
                        litStatusBadge.Text = status == "Active" ? "<span class='sb-badge sb-badge-success'>" + T("Active", "Aktif") + "</span>" : "<span class='sb-badge sb-badge-error'>" + HttpUtility.HtmlEncode(status) + "</span>";
                        litProfileFields.Text = F(T("Full Name","Nama Penuh"), name) + F(T("Username","Nama Pengguna"), username) + F(T("Email","E-mel"), email) + F(T("Phone","Telefon"), phone);
                        litAccountFields.Text = F(T("User ID","ID Pengguna"), userId) + F(T("Parent ID","ID Ibu Bapa"), parentId) + F(T("Status","Status"), status) + F(T("Role","Peranan"), "Parent") + F(T("Children Linked","Anak Dihubungkan"), rd["children"].ToString());
                    }
                }
                // Activity
                using (var cmd = new SqlCommand("SELECT TOP 20 [action],[description],[logDateTime] FROM dbo.[Log] WHERE [userId]=@u ORDER BY [logDateTime] DESC", conn))
                {
                    cmd.Parameters.AddWithValue("@u", hfUserId.Value); string html = ""; bool has = false;
                    using (var rd = cmd.ExecuteReader()) { while (rd.Read()) { has = true; string dt = rd["logDateTime"] != DBNull.Value ? Convert.ToDateTime(rd["logDateTime"]).ToString("dd MMM yyyy HH:mm") : "-"; html += "<div class='ad-parent-details-log-item'><div class='ad-parent-details-log-ico'><i class='bi bi-activity'></i></div><div class='ad-parent-details-log-body'><div class='ad-parent-details-log-action'>" + HttpUtility.HtmlEncode(NS(rd["action"])) + "</div><div class='ad-parent-details-log-desc'>" + HttpUtility.HtmlEncode(NS(rd["description"])) + "</div><div class='ad-parent-details-log-time'>" + dt + "</div></div></div>"; } }
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
                string parentId = Request.QueryString["parentId"] ?? "";
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    string userId = ""; using (var cmd = new SqlCommand("SELECT [userId] FROM dbo.[Parent] WHERE [parentId]=@p", conn)) { cmd.Parameters.AddWithValue("@p", parentId); var v = cmd.ExecuteScalar(); userId = v?.ToString() ?? ""; }
                    switch (action)
                    {
                        case "get":
                            using (var cmd = new SqlCommand("SELECT p.[name],p.[phoneNumber],u.[email] FROM dbo.[Parent] p LEFT JOIN dbo.[User] u ON u.[userId]=p.[userId] WHERE p.[parentId]=@p", conn))
                            { cmd.Parameters.AddWithValue("@p", parentId); using (var rd = cmd.ExecuteReader()) { if (rd.Read()) Response.Write("{\"success\":true,\"data\":{\"name\":\"" + EJ(rd["name"]) + "\",\"email\":\"" + EJ(rd["email"]) + "\",\"phone\":\"" + EJ(rd["phoneNumber"]) + "\"}}"); else Response.Write("{\"success\":false}"); } } break;
                        case "edit":
                            string n = Request.QueryString["name"] ?? ""; string em = Request.QueryString["email"] ?? ""; string ph = Request.QueryString["phone"] ?? "";
                            using (var cmd = new SqlCommand("UPDATE dbo.[Parent] SET [name]=@n,[phoneNumber]=@p WHERE [parentId]=@pid", conn)) { cmd.Parameters.AddWithValue("@n", n); cmd.Parameters.AddWithValue("@p", (object)ph ?? DBNull.Value); cmd.Parameters.AddWithValue("@pid", parentId); cmd.ExecuteNonQuery(); }
                            if (!string.IsNullOrEmpty(em)) { using (var cmd = new SqlCommand("UPDATE dbo.[User] SET [email]=@e WHERE [userId]=@u", conn)) { cmd.Parameters.AddWithValue("@e", em); cmd.Parameters.AddWithValue("@u", userId); cmd.ExecuteNonQuery(); } }
                            ILog(conn, adminId, "Updated Parent", "Updated " + parentId); Response.Write("{\"success\":true}"); break;
                        case "changeStatus":
                            string st = Request.QueryString["newStatus"] ?? ""; string reason = Request.QueryString["reason"] ?? "";
                            string csEmail = ""; string csName = "";
                            using (var cmd = new SqlCommand("SELECT p.[name], u.[email] FROM dbo.[Parent] p LEFT JOIN dbo.[User] u ON u.[userId]=p.[userId] WHERE p.[parentId]=@p", conn)) { cmd.Parameters.AddWithValue("@p", parentId); using (var rd = cmd.ExecuteReader()) { if (rd.Read()) { csEmail = rd["email"]?.ToString() ?? ""; csName = rd["name"]?.ToString() ?? "Parent"; } } }
                            using (var cmd = new SqlCommand("UPDATE dbo.[User] SET [status]=@s WHERE [userId]=@u", conn)) { cmd.Parameters.AddWithValue("@s", st); cmd.Parameters.AddWithValue("@u", userId); cmd.ExecuteNonQuery(); }
                            string aId = GID(conn, "UserStatusAction", "actionId", "USA");
                            using (var cmd = new SqlCommand("INSERT INTO dbo.[UserStatusAction]([actionId],[userId],[actionType],[reason],[actionDate],[performedBy]) VALUES(@a,@u,@t,@r,@d,@p)", conn)) { cmd.Parameters.AddWithValue("@a", aId); cmd.Parameters.AddWithValue("@u", userId); cmd.Parameters.AddWithValue("@t", st); cmd.Parameters.AddWithValue("@r", string.IsNullOrEmpty(reason) ? "Changed by admin." : reason); cmd.Parameters.AddWithValue("@d", DateTime.Today); cmd.Parameters.AddWithValue("@p", adminId); cmd.ExecuteNonQuery(); }
                            ILog(conn, adminId, st == "Blocked" ? "Account Blocked" : "Account Activated", st == "Blocked" ? "Administrator blocked the account." : "Administrator reactivated the account.");
                            SendStatusEmail(csEmail, csName, st, reason);
                            Response.Write("{\"success\":true,\"emailSent\":\"" + EJ(csEmail) + "\",\"emailStatus\":\"" + EJ(st) + "\"}"); break;
                        case "archive":
                            using (var cmd = new SqlCommand("UPDATE dbo.[User] SET [status]='Deleted' WHERE [userId]=@u", conn)) { cmd.Parameters.AddWithValue("@u", userId); cmd.ExecuteNonQuery(); }
                            ILog(conn, adminId, "Archived Parent", parentId); Response.Write("{\"success\":true}"); break;
                        case "resetPw":
                            string pw = "SB" + DateTime.Now.ToString("HHmmss");
                            using (var cmd = new SqlCommand("UPDATE dbo.[User] SET [password]=@p WHERE [userId]=@u", conn)) { cmd.Parameters.AddWithValue("@p", pw); cmd.Parameters.AddWithValue("@u", userId); cmd.ExecuteNonQuery(); }
                            ILog(conn, adminId, "Password Reset", "Reset for " + parentId); Response.Write("{\"success\":true,\"newPw\":\"" + pw + "\"}"); break;
                        default: Response.Write("{\"success\":false}"); break;
                    }
                }
            } catch (Exception ex) { Response.Write("{\"success\":false,\"msg\":\"" + EJ(ex.Message) + "\"}"); }
            Response.End();
        }

        private string F(string l, string v) { return "<div class='ad-parent-details-field'><div class='ad-parent-details-field-label'>" + HttpUtility.HtmlEncode(l) + "</div><div class='ad-parent-details-field-value'>" + HttpUtility.HtmlEncode(v ?? "-") + "</div></div>"; }
        private void ILog(SqlConnection c, string uid, string act, string desc) { string id = GID(c, "Log", "logId", "LOG"); using (var cmd = new SqlCommand("INSERT INTO dbo.[Log]([logId],[userId],[action],[description],[logDateTime],[status]) VALUES(@a,@b,@c,@d,@e,'Success')", c)) { cmd.Parameters.AddWithValue("@a", id); cmd.Parameters.AddWithValue("@b", uid); cmd.Parameters.AddWithValue("@c", act); cmd.Parameters.AddWithValue("@d", desc); cmd.Parameters.AddWithValue("@e", DateTime.Now); cmd.ExecuteNonQuery(); } }
        private string GID(SqlConnection c, string tbl, string col, string pfx) { using (var cmd = new SqlCommand(string.Format("SELECT TOP 1 [{0}] FROM dbo.[{1}] ORDER BY [{0}] DESC", col, tbl), c)) { var v = cmd.ExecuteScalar(); if (v == null || v == DBNull.Value) return pfx + "001"; string l = v.ToString(); int n; int.TryParse(l.Substring(pfx.Length), out n); n++; return pfx + n.ToString().PadLeft(l.Length - pfx.Length, '0'); } }
        private static string NS(object v) { return (v == null || v == DBNull.Value) ? "" : v.ToString(); }
        private static string EJ(object v) { string s = NS(v); return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", ""); }

        private void SendStatusEmail(string toEmail, string userName, string newStatus, string reason)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(toEmail)) return;
                string smtpHost = System.Configuration.ConfigurationManager.AppSettings["SmtpHost"] ?? "smtp.gmail.com";
                int smtpPort = int.Parse(System.Configuration.ConfigurationManager.AppSettings["SmtpPort"] ?? "587");
                string smtpUser = System.Configuration.ConfigurationManager.AppSettings["SmtpUsername"] ?? "";
                string smtpPass = System.Configuration.ConfigurationManager.AppSettings["SmtpPassword"] ?? "";
                bool smtpSsl = bool.Parse(System.Configuration.ConfigurationManager.AppSettings["SmtpEnableSsl"] ?? "true");
                string subject, body;
                if (newStatus == "Blocked")
                {
                    subject = "ScienceBuddy Account Blocked";
                    body = "Dear " + userName + ",\n\nYour ScienceBuddy account has been blocked by an administrator.\n\nReason:\n" + (string.IsNullOrWhiteSpace(reason) ? "No reason provided." : reason) + "\n\nWhile your account is blocked, you will not be able to log in to ScienceBuddy.\n\nIf you believe this was done in error, please contact the ScienceBuddy administrator.\n\nRegards,\nScienceBuddy Administration";
                }
                else
                {
                    subject = "ScienceBuddy Account Reactivated";
                    body = "Dear " + userName + ",\n\nYour ScienceBuddy account has been reactivated.\n\nYou may now log in and continue using ScienceBuddy.\n\nWelcome back!\n\nRegards,\nScienceBuddy Administration";
                }
                using (var mail = new System.Net.Mail.MailMessage(smtpUser, toEmail, subject, body))
                {
                    mail.IsBodyHtml = false;
                    using (var smtp = new System.Net.Mail.SmtpClient(smtpHost, smtpPort))
                    {
                        smtp.Credentials = new System.Net.NetworkCredential(smtpUser, smtpPass);
                        smtp.EnableSsl = smtpSsl;
                        smtp.Send(mail);
                    }
                }
            }
            catch { /* Email failure should not block the status change */ }
        }
    }
}
