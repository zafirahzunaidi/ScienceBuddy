using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

// Admin TeacherDetails - Code Behind
namespace ScienceBuddy.Admin
{
    public partial class TeacherDetails : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        protected string CurrentLanguage => ((ScienceBuddy.SiteMaster)Master).CurrentLanguage;
        protected string T(string en, string bm) => CurrentLanguage == "BM" ? bm : en;

        // --- Page Lifecycle ---

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.QueryString["handler"] == "TeacherCRUD" && Request.HttpMethod == "POST")
            { HandleAjax(); return; }

            if (Session["userId"] == null || Session["role"]?.ToString() != "Admin")
            { Response.Redirect("~/Login.aspx", false); return; }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                SetUserInfo();
                string id = Request.QueryString["id"] ?? "";
                if (string.IsNullOrEmpty(id))
                { Response.Redirect("~/Admin/TeacherManagement.aspx", false); return; }
                LoadTeacher(id);
            }
        }

        // --- Data Loading ---

        private void SetUserInfo()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [username] FROM dbo.[User] WHERE [userId]=@u", conn))
                {
                    cmd.Parameters.AddWithValue("@u", Session["userId"].ToString());
                    var result = cmd.ExecuteScalar();
                    string name = result?.ToString() ?? "Admin";
                    string initials = name.Length >= 2 ? name.Substring(0, 2).ToUpper() : name.ToUpper();
                    ((ScienceBuddy.SiteMaster)Master).SetUserInfo(name, "Administrator", initials);
                }
            }
        }

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
                        if (!rd.Read())
                        { Response.Redirect("~/Admin/TeacherManagement.aspx", false); return; }

                        string name = NS(rd["name"]);
                        string username = NS(rd["username"]);
                        string email = NS(rd["email"]);
                        string phone = NS(rd["phoneNumber"]);
                        string status = NS(rd["status"]);
                        string userId = NS(rd["userId"]);
                        string qualification = NS(rd["academicQualification"]);
                        string bio = NS(rd["bio"]);

                        hfTeacherId.Value = teacherId;
                        hfUserId.Value = userId;
                        hfStatus.Value = status;
                        litInitials.Text = name.Length >= 2 ? name.Substring(0, 2).ToUpper() : "T";
                        litName.Text = HttpUtility.HtmlEncode(name);
                        litTeacherId.Text = teacherId;
                        litUsername.Text = HttpUtility.HtmlEncode(username);
                        litEmail.Text = HttpUtility.HtmlEncode(email);
                        litMaterials.Text = rd["materials"].ToString();
                        litQuizzes.Text = rd["quizzes"].ToString();
                        litStatusBadge.Text = status == "Active"
                            ? "<span class='sb-badge sb-badge-success'>" + T("Active", "Aktif") + "</span>"
                            : "<span class='sb-badge sb-badge-error'>" + HttpUtility.HtmlEncode(status) + "</span>";

                        litProfileFields.Text =
                            Field(T("Full Name", "Nama Penuh"), name) +
                            Field(T("Username", "Nama Pengguna"), username) +
                            Field(T("Email", "E-mel"), email) +
                            Field(T("Phone", "Telefon"), phone) +
                            Field(T("Qualification", "Kelayakan"), qualification) +
                            Field(T("Bio", "Bio"), bio);

                        litAccountFields.Text =
                            Field(T("User ID", "ID Pengguna"), userId) +
                            Field(T("Teacher ID", "ID Guru"), teacherId) +
                            Field(T("Status", "Status"), status) +
                            Field(T("Role", "Peranan"), "Teacher") +
                            Field(T("Materials Uploaded", "Bahan Dimuat Naik"), rd["materials"].ToString()) +
                            Field(T("Quizzes Created", "Kuiz Dicipta"), rd["quizzes"].ToString());
                    }
                }

                // Activity log
                using (var cmd = new SqlCommand("SELECT TOP 20 [action],[description],[logDateTime] FROM dbo.[Log] WHERE [userId]=@u ORDER BY [logDateTime] DESC", conn))
                {
                    cmd.Parameters.AddWithValue("@u", hfUserId.Value);
                    string html = "";
                    bool hasRows = false;
                    using (var rd = cmd.ExecuteReader())
                    {
                        while (rd.Read())
                        {
                            hasRows = true;
                            string dt = rd["logDateTime"] != DBNull.Value
                                ? Convert.ToDateTime(rd["logDateTime"]).ToString("dd MMM yyyy HH:mm") : "-";
                            html += "<div class='ad-teacher-details-log-item'><div class='ad-teacher-details-log-ico'><i class='bi bi-activity'></i></div><div class='ad-teacher-details-log-body'><div class='ad-teacher-details-log-action'>" +
                                HttpUtility.HtmlEncode(NS(rd["action"])) + "</div><div class='ad-teacher-details-log-desc'>" +
                                HttpUtility.HtmlEncode(NS(rd["description"])) + "</div><div class='ad-teacher-details-log-time'>" + dt + "</div></div></div>";
                        }
                    }
                    litActivityLog.Text = hasRows ? html
                        : "<div style='text-align:center;padding:2rem;color:var(--color-text-muted);'><i class='bi bi-clock-history' style='font-size:2rem;opacity:.4;'></i><p style='margin-top:8px;'>" + T("No activity.", "Tiada aktiviti.") + "</p></div>";
                }
            }
        }

        // --- AJAX Handlers ---

        private void HandleAjax()
        {
            Response.ContentType = "application/json";
            try
            {
                if (Session["userId"] == null) { Response.Write("{\"success\":false}"); Response.End(); return; }
                string action = Request.QueryString["action"] ?? "";
                string adminId = Session["userId"].ToString();
                string teacherId = Request.QueryString["teacherId"] ?? "";

                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    string userId = "";
                    using (var cmd = new SqlCommand("SELECT [userId] FROM dbo.[Teacher] WHERE [teacherId]=@t", conn))
                    {
                        cmd.Parameters.AddWithValue("@t", teacherId);
                        var val = cmd.ExecuteScalar();
                        userId = val?.ToString() ?? "";
                    }

                    switch (action)
                    {
                        case "get":
                            using (var cmd = new SqlCommand("SELECT t.[name],t.[phoneNumber],u.[email] FROM dbo.[Teacher] t LEFT JOIN dbo.[User] u ON u.[userId]=t.[userId] WHERE t.[teacherId]=@t", conn))
                            {
                                cmd.Parameters.AddWithValue("@t", teacherId);
                                using (var rd = cmd.ExecuteReader())
                                {
                                    if (rd.Read())
                                        Response.Write("{\"success\":true,\"data\":{\"name\":\"" + EJ(rd["name"]) + "\",\"email\":\"" + EJ(rd["email"]) + "\",\"phone\":\"" + EJ(rd["phoneNumber"]) + "\"}}");
                                    else
                                        Response.Write("{\"success\":false}");
                                }
                            }
                            break;

                        case "edit":
                            string eName = Request.QueryString["name"] ?? "";
                            string eEmail = Request.QueryString["email"] ?? "";
                            string ePhone = Request.QueryString["phone"] ?? "";
                            using (var cmd = new SqlCommand("UPDATE dbo.[Teacher] SET [name]=@n,[phoneNumber]=@p WHERE [teacherId]=@t", conn))
                            {
                                cmd.Parameters.AddWithValue("@n", eName);
                                cmd.Parameters.AddWithValue("@p", (object)ePhone ?? DBNull.Value);
                                cmd.Parameters.AddWithValue("@t", teacherId);
                                cmd.ExecuteNonQuery();
                            }
                            if (!string.IsNullOrEmpty(eEmail))
                            {
                                using (var cmd = new SqlCommand("UPDATE dbo.[User] SET [email]=@e WHERE [userId]=@u", conn))
                                {
                                    cmd.Parameters.AddWithValue("@e", eEmail);
                                    cmd.Parameters.AddWithValue("@u", userId);
                                    cmd.ExecuteNonQuery();
                                }
                            }
                            ILog(conn, adminId, "Updated Teacher", "Updated " + teacherId);
                            Response.Write("{\"success\":true}");
                            break;

                        case "changeStatus":
                            string newStatus = Request.QueryString["newStatus"] ?? "";
                            string reason = Request.QueryString["reason"] ?? "";
                            string csEmail = "", csName = "";
                            using (var cmd = new SqlCommand("SELECT t.[name], u.[email] FROM dbo.[Teacher] t LEFT JOIN dbo.[User] u ON u.[userId]=t.[userId] WHERE t.[teacherId]=@t", conn))
                            {
                                cmd.Parameters.AddWithValue("@t", teacherId);
                                using (var rd = cmd.ExecuteReader())
                                {
                                    if (rd.Read())
                                    {
                                        csEmail = rd["email"]?.ToString() ?? "";
                                        csName = rd["name"]?.ToString() ?? "Teacher";
                                    }
                                }
                            }
                            using (var cmd = new SqlCommand("UPDATE dbo.[User] SET [status]=@s WHERE [userId]=@u", conn))
                            {
                                cmd.Parameters.AddWithValue("@s", newStatus);
                                cmd.Parameters.AddWithValue("@u", userId);
                                cmd.ExecuteNonQuery();
                            }
                            string aId = GID(conn, "UserStatusAction", "actionId", "USA");
                            using (var cmd = new SqlCommand("INSERT INTO dbo.[UserStatusAction]([actionId],[userId],[actionType],[reason],[actionDate],[performedBy]) VALUES(@a,@u,@t,@r,@d,@p)", conn))
                            {
                                cmd.Parameters.AddWithValue("@a", aId);
                                cmd.Parameters.AddWithValue("@u", userId);
                                cmd.Parameters.AddWithValue("@t", newStatus);
                                cmd.Parameters.AddWithValue("@r", string.IsNullOrEmpty(reason) ? "Changed by admin." : reason);
                                cmd.Parameters.AddWithValue("@d", DateTime.Today);
                                cmd.Parameters.AddWithValue("@p", adminId);
                                cmd.ExecuteNonQuery();
                            }
                            ILog(conn, adminId, newStatus == "Blocked" ? "Account Blocked" : "Account Activated",
                                newStatus == "Blocked" ? "Administrator blocked the account." : "Administrator reactivated the account.");
                            SendStatusEmail(csEmail, csName, newStatus, reason);
                            Response.Write("{\"success\":true,\"emailSent\":\"" + EJ(csEmail) + "\",\"emailStatus\":\"" + EJ(newStatus) + "\"}");
                            break;

                        case "archive":
                            using (var cmd = new SqlCommand("UPDATE dbo.[User] SET [status]='Deleted' WHERE [userId]=@u", conn))
                            {
                                cmd.Parameters.AddWithValue("@u", userId);
                                cmd.ExecuteNonQuery();
                            }
                            ILog(conn, adminId, "Archived Teacher", teacherId);
                            Response.Write("{\"success\":true}");
                            break;

                        case "resetPw":
                            string newPw = "SB" + DateTime.Now.ToString("HHmmss");
                            using (var cmd = new SqlCommand("UPDATE dbo.[User] SET [password]=@p WHERE [userId]=@u", conn))
                            {
                                cmd.Parameters.AddWithValue("@p", newPw);
                                cmd.Parameters.AddWithValue("@u", userId);
                                cmd.ExecuteNonQuery();
                            }
                            ILog(conn, adminId, "Password Reset", "Reset for " + teacherId);
                            Response.Write("{\"success\":true,\"newPw\":\"" + newPw + "\"}");
                            break;

                        default:
                            Response.Write("{\"success\":false}");
                            break;
                    }
                }
            }
            catch (Exception ex)
            {
                Response.Write("{\"success\":false,\"msg\":\"" + EJ(ex.Message) + "\"}");
            }
            Response.End();
        }

        // --- Helper Methods ---

        private string Field(string label, string value)
        {
            return "<div class='ad-teacher-details-field'><div class='ad-teacher-details-field-label'>" +
                HttpUtility.HtmlEncode(label) + "</div><div class='ad-teacher-details-field-value'>" +
                HttpUtility.HtmlEncode(value ?? "-") + "</div></div>";
        }

        private void ILog(SqlConnection c, string uid, string act, string desc)
        {
            string id = GID(c, "Log", "logId", "LOG");
            using (var cmd = new SqlCommand("INSERT INTO dbo.[Log]([logId],[userId],[action],[description],[logDateTime],[status]) VALUES(@a,@b,@c,@d,@e,'Success')", c))
            {
                cmd.Parameters.AddWithValue("@a", id);
                cmd.Parameters.AddWithValue("@b", uid);
                cmd.Parameters.AddWithValue("@c", act);
                cmd.Parameters.AddWithValue("@d", desc);
                cmd.Parameters.AddWithValue("@e", DateTime.Now);
                cmd.ExecuteNonQuery();
            }
        }

        private string GID(SqlConnection c, string tbl, string col, string pfx)
        {
            using (var cmd = new SqlCommand(string.Format("SELECT TOP 1 [{0}] FROM dbo.[{1}] ORDER BY [{0}] DESC", col, tbl), c))
            {
                var val = cmd.ExecuteScalar();
                if (val == null || val == DBNull.Value) return pfx + "001";
                string last = val.ToString();
                int num;
                int.TryParse(last.Substring(pfx.Length), out num);
                num++;
                return pfx + num.ToString().PadLeft(last.Length - pfx.Length, '0');
            }
        }

        private static string NS(object v)
        {
            return (v == null || v == DBNull.Value) ? "" : v.ToString();
        }

        private static string EJ(object v)
        {
            string s = NS(v);
            return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "");
        }

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
