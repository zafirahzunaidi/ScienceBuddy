using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Net;
using System.Net.Mail;
using System.Web;
using System.Web.UI;

// Admin RecycleBin - Code Behind
namespace ScienceBuddy.Admin
{
    public partial class RecycleBin : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        protected string CurrentLanguage => ((ScienceBuddy.SiteMaster)Master).CurrentLanguage;
        protected string T(string en, string bm) => CurrentLanguage == "BM" ? bm : en;
        private bool _isAjax = false;

        protected override void Render(HtmlTextWriter writer)
        {
            if (!_isAjax) base.Render(writer);
        }

        // ── Page Lifecycle ───────────────────────────────────────────
        protected void Page_Load(object sender, EventArgs e)
        {
            // AJAX handlers
            if (Request.QueryString["handler"] == "RestoreUser" && Request.HttpMethod == "POST")
            { _isAjax = true; HandleRestoreUser(); return; }

            if (Request.QueryString["handler"] == "DeletePermanently" && Request.HttpMethod == "POST")
            { _isAjax = true; HandleDeletePermanently(); return; }

            // Auth check
            if (Session["userId"] == null || Session["role"]?.ToString() != "Admin")
            { Response.Redirect("~/Login.aspx", false); return; }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                SetMasterUser();
                LoadStats();
                LoadDeletedUsers();
            }
        }

        // ── Master user widget ───────────────────────────────────────
        private void SetMasterUser()
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

        // ── Load Stats ───────────────────────────────────────────────
        private void LoadStats()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                int students = SS(conn, "SELECT COUNT(*) FROM dbo.[User] WHERE [status]='Deleted' AND [role]='Student'");
                int parents = SS(conn, "SELECT COUNT(*) FROM dbo.[User] WHERE [status]='Deleted' AND [role]='Parent'");
                int teachers = SS(conn, "SELECT COUNT(*) FROM dbo.[User] WHERE [status]='Deleted' AND [role]='Teacher'");

                litDeletedStudents.Text = students.ToString();
                litDeletedParents.Text = parents.ToString();
                litDeletedTeachers.Text = teachers.ToString();
                litTotalDeleted.Text = (students + parents + teachers).ToString();
            }
        }

        // ── Load Deleted Users ───────────────────────────────────────
        private void LoadDeletedUsers()
        {
            var list = new List<object>();

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                string sql = @"
                    SELECT u.[userId], u.[username], u.[role],
                        CASE
                            WHEN u.[role]='Student' THEN ISNULL(s.[name], u.[username])
                            WHEN u.[role]='Parent'  THEN ISNULL(p.[name], u.[username])
                            WHEN u.[role]='Teacher' THEN ISNULL(t.[name], u.[username])
                            ELSE u.[username]
                        END AS fullName
                    FROM dbo.[User] u
                    LEFT JOIN dbo.[Student] s ON s.[userId] = u.[userId]
                    LEFT JOIN dbo.[Parent] p ON p.[userId] = u.[userId]
                    LEFT JOIN dbo.[Teacher] t ON t.[userId] = u.[userId]
                    WHERE u.[status] = 'Deleted'
                    ORDER BY u.[userId] DESC";

                using (var cmd = new SqlCommand(sql, conn))
                using (var da = new SqlDataAdapter(cmd))
                {
                    var dt = new DataTable();
                    da.Fill(dt);

                    foreach (DataRow r in dt.Rows)
                    {
                        string role = NS(r, "role");
                        string roleCls = role == "Student" ? "type-question"
                                       : role == "Parent" ? "type-material"
                                       : "priority-medium";

                        list.Add(new
                        {
                            userId = NS(r, "userId"),
                            username = HttpUtility.HtmlEncode(NS(r, "username")),
                            role = role,
                            roleCls = roleCls,
                            fullName = HttpUtility.HtmlEncode(NS(r, "fullName")),
                            deletedDate = "-"
                        });
                    }
                }
            }

            if (list.Count > 0)
            {
                rptDeleted.DataSource = list;
                rptDeleted.DataBind();
                pnlTable.Visible = true;
                pnlEmpty.Visible = false;
            }
            else
            {
                pnlTable.Visible = false;
                pnlEmpty.Visible = true;
            }
        }

        private bool HasRelatedRecords(SqlConnection conn, string userId, string role)
        {
            int count = 0;

            using (var cmd = new SqlCommand())
            {
                cmd.Connection = conn;

                switch (role)
                {
                    case "Teacher":

                        cmd.CommandText = @"
                SELECT
                    (SELECT COUNT(*) FROM Quiz
                        WHERE createdByUserId=@id)
                  + (SELECT COUNT(*) FROM Material
                        WHERE createdByUserId=@id)
                  + (SELECT COUNT(*)
                        FROM LiveConsultationSession ls
                        INNER JOIN Teacher t
                            ON ls.teacherId=t.teacherId
                        WHERE t.userId=@id)";
                        break;

                    case "Student":

                        cmd.CommandText = @"
                SELECT
                    (SELECT COUNT(*)
                        FROM QuizResult qr
                        INNER JOIN Student s
                            ON qr.studentId=s.studentId
                        WHERE s.userId=@id)

                  + (SELECT COUNT(*)
                        FROM Certificate c
                        INNER JOIN Student s
                            ON c.studentId=s.studentId
                        WHERE s.userId=@id)

                  + (SELECT COUNT(*)
                        FROM LessonProgress lp
                        INNER JOIN Student s
                            ON lp.studentId=s.studentId
                        WHERE s.userId=@id)

                  + (SELECT COUNT(*)
                        FROM XPTransaction xp
                        INNER JOIN Student s
                            ON xp.studentId=s.studentId
                        WHERE s.userId=@id)

                  + (SELECT COUNT(*)
                        FROM LabProgress lab
                        INNER JOIN Student s
                            ON lab.studentId=s.studentId
                        WHERE s.userId=@id)

                  + (SELECT COUNT(*)
                        FROM AILearningAnalysis ai
                        INNER JOIN Student s
                            ON ai.studentId=s.studentId
                        WHERE s.userId=@id)";
                        break;

                    case "Parent":

                        cmd.CommandText = @"
                SELECT COUNT(*)
                FROM StudyPlan sp
                INNER JOIN StudentParent spa
                    ON sp.studentParentId = spa.studentParentId
                INNER JOIN Parent p
                    ON spa.parentId = p.parentId
                WHERE p.userId=@id";
                        break;

                    default:
                        return false;
                }

                cmd.Parameters.AddWithValue("@id", userId);

                count = Convert.ToInt32(cmd.ExecuteScalar());
            }

            return count > 0;
        }

        // ── AJAX: Restore User ───────────────────────────────────────
        private void HandleRestoreUser()
        {
            Response.ContentType = "application/json";
            try
            {
                if (Session["userId"] == null)
                { Response.Write("{\"success\":false,\"msg\":\"Unauthorized\"}"); return; }

                string uid = Request.Form["userId"] ?? "";
                if (string.IsNullOrEmpty(uid))
                { Response.Write("{\"success\":false,\"msg\":\"Missing userId\"}"); return; }

                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // Get user info for email
                    string username = "";
                    string email = "";
                    using (var cmd = new SqlCommand("SELECT [username],[email] FROM dbo.[User] WHERE [userId]=@uid", conn))
                    {
                        cmd.Parameters.AddWithValue("@uid", uid);
                        using (var rd = cmd.ExecuteReader())
                        {
                            if (rd.Read())
                            {
                                username = rd["username"]?.ToString() ?? "";
                                email = rd["email"]?.ToString() ?? "";
                            }
                        }
                    }

                    // Restore user
                    using (var cmd = new SqlCommand("UPDATE dbo.[User] SET [status]='Active' WHERE [userId]=@uid", conn))
                    {
                        cmd.Parameters.AddWithValue("@uid", uid);
                        cmd.ExecuteNonQuery();
                    }

                    // Log
                    InsertLog(conn, Session["userId"].ToString(), "User Restored",
                        "Restored user " + username + " (" + uid + ") from recycle bin.", "Success");

                    // Send restore email
                    if (!string.IsNullOrEmpty(email))
                    {
                        SendRestoreEmail(email, username);
                    }
                }

                Response.Write("{\"success\":true,\"msg\":\"" + EJ("Account restored successfully.") + "\"}");
            }
            catch (Exception ex)
            {
                Response.Write("{\"success\":false,\"msg\":\"" + EJ(ex.Message) + "\"}");
            }
        }

        // ── AJAX: Delete Permanently ─────────────────────────────────
        private void HandleDeletePermanently()
        {
            Response.ContentType = "application/json";

            try
            {
                if (Session["userId"] == null)
                {
                    Response.Write("{\"success\":false,\"msg\":\"Unauthorized\"}");
                    return;
                }

                string uid = Request.Form["userId"] ?? "";
                string role = Request.Form["role"] ?? "";

                if (string.IsNullOrEmpty(uid))
                {
                    Response.Write("{\"success\":false,\"msg\":\"Missing userId\"}");
                    return;
                }

                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // Prevent deleting users with important academic records
                    if (HasRelatedRecords(conn, uid, role))
                    {
                        Response.Write(
                            "{\"success\":false," +
                            "\"msg\":\"This account cannot be permanently deleted because it has academic records. Keep it in the Recycle Bin instead.\"}");
                        return;
                    }

                    // Get username for log
                    string username = "";
                    using (var cmd = new SqlCommand(
                        "SELECT [username] FROM dbo.[User] WHERE [userId]=@uid", conn))
                    {
                        cmd.Parameters.AddWithValue("@uid", uid);
                        var val = cmd.ExecuteScalar();
                        username = val?.ToString() ?? "";
                    }

                    // Delete from role table first
                    if (role == "Student")
                    {
                        using (var cmd = new SqlCommand(
                            "DELETE FROM dbo.[Student] WHERE [userId]=@uid", conn))
                        {
                            cmd.Parameters.AddWithValue("@uid", uid);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    else if (role == "Parent")
                    {
                        using (var cmd = new SqlCommand(
                            "DELETE FROM dbo.[Parent] WHERE [userId]=@uid", conn))
                        {
                            cmd.Parameters.AddWithValue("@uid", uid);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    else if (role == "Teacher")
                    {
                        using (var cmd = new SqlCommand(
                            "DELETE FROM dbo.[Teacher] WHERE [userId]=@uid", conn))
                        {
                            cmd.Parameters.AddWithValue("@uid", uid);
                            cmd.ExecuteNonQuery();
                        }
                    }

                    // Delete from User table
                    using (var cmd = new SqlCommand(
                        "DELETE FROM dbo.[User] WHERE [userId]=@uid", conn))
                    {
                        cmd.Parameters.AddWithValue("@uid", uid);
                        cmd.ExecuteNonQuery();
                    }

                    // Log action
                    InsertLog(
                        conn,
                        Session["userId"].ToString(),
                        "User Permanently Deleted",
                        "Permanently deleted user " + username + " (" + uid + ", " + role + ").",
                        "Success");
                }

                Response.Write("{\"success\":true,\"msg\":\"" +
                    EJ("Account permanently deleted.") + "\"}");
            }
            catch (Exception ex)
            {
                Response.Write("{\"success\":false,\"msg\":\"" +
                    EJ(ex.Message) + "\"}");
            }
        }

        // ── Send Restore Email ───────────────────────────────────────
        private void SendRestoreEmail(string toEmail, string username)
        {
            try
            {
                string host = ConfigurationManager.AppSettings["SmtpHost"];
                int port = int.Parse(ConfigurationManager.AppSettings["SmtpPort"] ?? "587");
                string smtpUser = ConfigurationManager.AppSettings["SmtpUsername"];
                string smtpPass = ConfigurationManager.AppSettings["SmtpPassword"];
                bool ssl = bool.Parse(ConfigurationManager.AppSettings["SmtpEnableSsl"] ?? "true");

                using (var msg = new MailMessage())
                {
                    msg.From = new MailAddress(smtpUser, "ScienceBuddy");
                    msg.To.Add(toEmail);
                    msg.Subject = "Your ScienceBuddy Account Has Been Restored";
                    msg.IsBodyHtml = true;
                    msg.Body = "<div style='font-family:Arial,sans-serif;max-width:500px;margin:0 auto;'>"
                        + "<h2 style='color:#059669;'>Account Restored</h2>"
                        + "<p>Hi <strong>" + HttpUtility.HtmlEncode(username) + "</strong>,</p>"
                        + "<p>Your ScienceBuddy account has been restored by an administrator. You can now log in again with your existing credentials.</p>"
                        + "<p>If you did not expect this, please contact support.</p>"
                        + "<br/><p style='color:#94a3b8;font-size:12px;'>— The ScienceBuddy Team</p>"
                        + "</div>";

                    using (var client = new SmtpClient(host, port))
                    {
                        client.Credentials = new NetworkCredential(smtpUser, smtpPass);
                        client.EnableSsl = ssl;
                        client.Send(msg);
                    }
                }
            }
            catch { /* Email failure should not block restore */ }
        }

        // ── Helper: Insert Log ───────────────────────────────────────
        private void InsertLog(SqlConnection conn, string userId, string action, string desc, string status)
        {
            string id = GenId(conn, "Log", "logId", "LOG");
            using (var cmd = new SqlCommand("INSERT INTO dbo.[Log]([logId],[userId],[action],[description],[logDateTime],[status]) VALUES(@a,@b,@c,@d,@e,@f)", conn))
            {
                cmd.Parameters.AddWithValue("@a", id);
                cmd.Parameters.AddWithValue("@b", userId);
                cmd.Parameters.AddWithValue("@c", action);
                cmd.Parameters.AddWithValue("@d", desc);
                cmd.Parameters.AddWithValue("@e", DateTime.Now);
                cmd.Parameters.AddWithValue("@f", status);
                cmd.ExecuteNonQuery();
            }
        }

        // ── Helper: Generate ID ──────────────────────────────────────
        private string GenId(SqlConnection conn, string tbl, string col, string pfx)
        {
            using (var cmd = new SqlCommand(string.Format("SELECT TOP 1 [{0}] FROM dbo.[{1}] ORDER BY [{0}] DESC", col, tbl), conn))
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

        // ── Helper: Safe scalar count ────────────────────────────────
        private int SS(SqlConnection conn, string sql)
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

        // ── Helper: Null-safe string from DataRow ────────────────────
        private static string NS(DataRow r, string col)
        {
            if (!r.Table.Columns.Contains(col)) return "";
            return r[col] == null || r[col] == DBNull.Value ? "" : r[col].ToString();
        }

        // ── Helper: Escape JSON ──────────────────────────────────────
        private static string EJ(object v)
        {
            string s = (v == null || v == DBNull.Value) ? "" : v.ToString();
            return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "");
        }
    }
}
