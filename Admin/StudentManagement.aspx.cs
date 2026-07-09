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
    public partial class StudentManagement : Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected string CurrentLanguage =>
            ((ScienceBuddy.SiteMaster)Master).CurrentLanguage;

        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // AJAX CRUD handler
            if (Request.QueryString["handler"] == "StudentCRUD" && Request.HttpMethod == "POST")
            { HandleAjax(); return; }

            if (Session["userId"] == null)
            { Response.Redirect("~/Login.aspx", false); return; }
            if (Session["role"] == null || Session["role"].ToString() != "Admin")
            { Response.Redirect("~/Login.aspx", false); return; }

            var master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                SetMasterUserInfo();
                LoadLevelDropdown();
                LoadInsights();
                LoadStudents("", "", "", "", "name");
            }

            // Bilingual labels
            txtSearch.Attributes["placeholder"] = T("Search by name, username or email…", "Cari mengikut nama, nama pengguna atau e-mel…");
            btnSearch.Text     = T("Search", "Cari");
            btnReset.Text      = T("Reset", "Tetapkan Semula");
            btnCloseModal.Text = T("Close", "Tutup");
        }

        private void SetMasterUserInfo()
        {
            string uid = Session["userId"].ToString();
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [username] FROM dbo.[User] WHERE [userId]=@uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", uid);
                    var val = cmd.ExecuteScalar();
                    string name = (val != null && val != DBNull.Value) ? val.ToString() : "Admin";
                    string ini = name.Length >= 2 ? name.Substring(0, 2).ToUpper() : name.ToUpper();
                    ((ScienceBuddy.SiteMaster)Master).SetUserInfo(name, "Administrator", ini);
                }
            }
        }

        private void LoadLevelDropdown()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                string col = CurrentLanguage == "BM" ? "levelNameBM" : "levelNameEN";
                using (var cmd = new SqlCommand(
                    "SELECT [levelId],[levelNameEN],[levelNameBM] FROM dbo.[Level] ORDER BY [levelId]", conn))
                {
                    var reader = cmd.ExecuteReader();
                    ddlLevel.Items.Clear();
                    ddlLevel.Items.Add(new ListItem(T("All Levels", "Semua Tahap"), ""));
                    while (reader.Read())
                    {
                        string name = CurrentLanguage == "BM"
                            ? reader["levelNameBM"].ToString()
                            : reader["levelNameEN"].ToString();
                        ddlLevel.Items.Add(new ListItem(name, reader["levelId"].ToString()));
                    }
                }
            }
        }

        private void LoadInsights()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Total students
                litTotal.Text = SafeScalar(conn, "SELECT COUNT(*) FROM dbo.[Student]");

                // Average XP
                litAvgXP.Text = SafeScalar(conn, "SELECT ISNULL(AVG([XP]),0) FROM dbo.[Student]");

                // Highest level
                string lvlCol = CurrentLanguage == "BM" ? "l.[levelNameBM]" : "l.[levelNameEN]";
                using (var cmd = new SqlCommand(string.Format(@"
                    SELECT TOP 1 {0}
                    FROM dbo.[Student] s
                    JOIN dbo.[Level] l ON l.[levelId] = s.[currentLevelId]
                    ORDER BY l.[levelId] DESC", lvlCol), conn))
                {
                    var val = cmd.ExecuteScalar();
                    litHighLevel.Text = (val != null && val != DBNull.Value) ? val.ToString() : "-";
                }

                // Active students (User.status = 'Active')
                litActive.Text = SafeScalar(conn,
                    "SELECT COUNT(*) FROM dbo.[Student] s JOIN dbo.[User] u ON u.[userId]=s.[userId] WHERE u.[status]='Active'");
            }
        }

        private void LoadStudents(string search, string levelFilter, string statusFilter, string langFilter, string sortBy)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                string lvlCol = CurrentLanguage == "BM" ? "lv.[levelNameBM]" : "lv.[levelNameEN]";
                string pCol   = CurrentLanguage == "BM" ? "p.[personalityNameBM]" : "p.[personalityNameEN]";

                string sql = string.Format(@"
                    SELECT
                        s.[studentId], s.[name], s.[nickname], s.[XP], s.[currentLevelId],
                        u.[username], u.[email], u.[status], u.[preferredLanguage],
                        ISNULL({0}, '-') AS levelName,
                        ISNULL({1}, '-') AS personalityName,
                        (SELECT COUNT(*) FROM dbo.[LessonProgress] lp WHERE lp.[studentId]=s.[studentId] AND lp.[isCompleted]=1) AS lessonsCompleted,
                        (SELECT COUNT(*) FROM dbo.[StudentBadge] sb WHERE sb.[studentId]=s.[studentId]) AS badgesEarned
                    FROM dbo.[Student] s
                    LEFT JOIN dbo.[User] u ON u.[userId] = s.[userId]
                    LEFT JOIN dbo.[Level] lv ON lv.[levelId] = s.[currentLevelId]
                    LEFT JOIN dbo.[Personality] p ON p.[personalityId] = s.[personalityId]
                    WHERE 1=1", lvlCol, pCol);

                if (!string.IsNullOrWhiteSpace(search))
                    sql += " AND (s.[name] LIKE @search OR s.[nickname] LIKE @search OR u.[username] LIKE @search OR u.[email] LIKE @search)";
                if (!string.IsNullOrWhiteSpace(levelFilter))
                    sql += " AND s.[currentLevelId] = @level";
                if (!string.IsNullOrWhiteSpace(statusFilter))
                    sql += " AND u.[status] = @status";
                if (!string.IsNullOrWhiteSpace(langFilter))
                    sql += " AND u.[preferredLanguage] = @lang";

                // Sort
                switch (sortBy)
                {
                    case "name_desc": sql += " ORDER BY s.[name] DESC"; break;
                    case "xp_desc":   sql += " ORDER BY s.[XP] DESC"; break;
                    case "xp_asc":    sql += " ORDER BY s.[XP] ASC"; break;
                    default:          sql += " ORDER BY s.[name] ASC"; break;
                }

                using (var cmd = new SqlCommand(sql, conn))
                {
                    if (!string.IsNullOrWhiteSpace(search))
                        cmd.Parameters.AddWithValue("@search", "%" + search + "%");
                    if (!string.IsNullOrWhiteSpace(levelFilter))
                        cmd.Parameters.AddWithValue("@level", levelFilter);
                    if (!string.IsNullOrWhiteSpace(statusFilter))
                        cmd.Parameters.AddWithValue("@status", statusFilter);
                    if (!string.IsNullOrWhiteSpace(langFilter))
                        cmd.Parameters.AddWithValue("@lang", langFilter);

                    var da = new SqlDataAdapter(cmd);
                    var dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count == 0)
                    {
                        pnlStudents.Visible = false;
                        pnlEmpty.Visible    = true;
                        return;
                    }

                    var list = new List<object>();
                    string[] gradients = {
                        "background:linear-gradient(135deg,#6366F1,#818CF8);",
                        "background:linear-gradient(135deg,#EC4899,#F472B6);",
                        "background:linear-gradient(135deg,#10B981,#34D399);",
                        "background:linear-gradient(135deg,#F59E0B,#FBBF24);",
                        "background:linear-gradient(135deg,#06B6D4,#22D3EE);",
                        "background:linear-gradient(135deg,#8B5CF6,#A78BFA);"
                    };

                    int idx = 0;
                    foreach (DataRow row in dt.Rows)
                    {
                        string name     = NullSafe(row["name"]);
                        string nickname = NullSafe(row["nickname"]);
                        string display  = !string.IsNullOrWhiteSpace(nickname) ? nickname : (!string.IsNullOrWhiteSpace(name) ? name : "Student");
                        string username = NullSafe(row["username"]);
                        string status   = NullSafe(row["status"]);
                        int xp          = row["XP"] == DBNull.Value ? 0 : Convert.ToInt32(row["XP"]);
                        int maxXp       = 500; // per-level scale
                        int pct         = Math.Min(xp * 100 / Math.Max(maxXp, 1), 100);
                        string initials = GetInitials(display);
                        string lang     = NullSafe(row["preferredLanguage"]);

                        list.Add(new
                        {
                            studentId       = row["studentId"].ToString(),
                            displayName     = display,
                            username        = username,
                            initials        = initials,
                            levelName       = NullSafe(row["levelName"]),
                            personalityName = NullSafe(row["personalityName"]),
                            language        = lang == "BM" ? "BM" : "EN",
                            xp              = xp,
                            xpPct           = pct,
                            lessonsCompleted = row["lessonsCompleted"],
                            badgesEarned    = row["badgesEarned"],
                            statusClass     = status == "Active" ? "active" : "inactive",
                            avatarGradient  = gradients[idx % gradients.Length]
                        });
                        idx++;
                    }

                    pnlStudents.Visible = true;
                    pnlEmpty.Visible    = false;
                    rptStudents.DataSource = list;
                    rptStudents.DataBind();
                }
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadStudents(txtSearch.Text.Trim(), ddlLevel.SelectedValue, ddlStatus.SelectedValue, ddlLang.SelectedValue, ddlSort.SelectedValue);
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlLevel.SelectedIndex  = 0;
            ddlStatus.SelectedIndex = 0;
            ddlLang.SelectedIndex   = 0;
            ddlSort.SelectedIndex   = 0;
            LoadStudents("", "", "", "", "name");
        }

        // ── View Details modal ───────────────────────────────────────
        protected void rptStudents_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "ViewStudent")
                ShowStudentModal(e.CommandArgument.ToString());
        }

        private void ShowStudentModal(string studentId)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                string lvlCol = CurrentLanguage == "BM" ? "lv.[levelNameBM]" : "lv.[levelNameEN]";
                string pCol   = CurrentLanguage == "BM" ? "p.[personalityNameBM]" : "p.[personalityNameEN]";

                string sql = string.Format(@"
                    SELECT s.[studentId], s.[name], s.[nickname], s.[XP], s.[phoneNumber],
                           u.[username], u.[email], u.[status], u.[preferredLanguage],
                           ISNULL({0}, '-') AS levelName,
                           ISNULL({1}, '-') AS personalityName,
                           (SELECT COUNT(*) FROM dbo.[LessonProgress] lp WHERE lp.[studentId]=s.[studentId] AND lp.[isCompleted]=1) AS lessonsCompleted,
                           (SELECT COUNT(*) FROM dbo.[StudentBadge] sb WHERE sb.[studentId]=s.[studentId]) AS badgesEarned,
                           (SELECT COUNT(*) FROM dbo.[QuizResult] qr WHERE qr.[studentId]=s.[studentId]) AS quizzesCompleted
                    FROM dbo.[Student] s
                    LEFT JOIN dbo.[User] u ON u.[userId]=s.[userId]
                    LEFT JOIN dbo.[Level] lv ON lv.[levelId]=s.[currentLevelId]
                    LEFT JOIN dbo.[Personality] p ON p.[personalityId]=s.[personalityId]
                    WHERE s.[studentId]=@sid", lvlCol, pCol);

                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@sid", studentId);
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read()) return;

                        string name     = NullSafe(reader["nickname"]);
                        if (string.IsNullOrWhiteSpace(name)) name = NullSafe(reader["name"]);
                        if (string.IsNullOrWhiteSpace(name)) name = "Student";
                        string username = NullSafe(reader["username"]);
                        int xp          = reader["XP"] == DBNull.Value ? 0 : Convert.ToInt32(reader["XP"]);
                        int pct         = Math.Min(xp * 100 / Math.Max(500, 1), 100);
                        string status   = NullSafe(reader["status"]);
                        string lang     = NullSafe(reader["preferredLanguage"]);

                        litMInitials.Text    = GetInitials(name);
                        litMName.Text        = HttpUtility.HtmlEncode(name);
                        litMUsername.Text     = HttpUtility.HtmlEncode(username);
                        litMEmail.Text       = HttpUtility.HtmlEncode(NullSafe(reader["email"]));
                        litMPhone.Text       = HttpUtility.HtmlEncode(NullSafe(reader["phoneNumber"]));
                        litMLevel.Text       = string.Format("<span class=\"sb-badge sb-badge-primary\">{0}</span>",
                                                HttpUtility.HtmlEncode(NullSafe(reader["levelName"])));
                        litMPersonality.Text = HttpUtility.HtmlEncode(NullSafe(reader["personalityName"]));
                        litMLangVal.Text     = lang == "BM" ? "Bahasa Melayu" : "English";
                        litMStatus.Text      = string.Format("<span class=\"sb-badge {0}\">{1}</span>",
                                                status == "Active" ? "sb-badge-success" : "sb-badge-error",
                                                HttpUtility.HtmlEncode(status == "Active" ? T("Active","Aktif") : T("Blocked","Disekat")));
                        litMXP.Text          = xp.ToString();
                        litMXPPct.Text       = pct.ToString();
                        litMLessons.Text     = reader["lessonsCompleted"].ToString();
                        litMBadges.Text      = reader["badgesEarned"].ToString();
                        litMQuizzes.Text     = reader["quizzesCompleted"].ToString();
                    }
                }
            }
            pnlModal.Visible = true;
        }

        protected void btnCloseModal_Click(object sender, EventArgs e)
        {
            pnlModal.Visible = false;
        }

        // ── Helpers ──────────────────────────────────────────────────
        private string SafeScalar(SqlConnection conn, string sql)
        {
            try
            {
                using (var cmd = new SqlCommand(sql, conn))
                {
                    var val = cmd.ExecuteScalar();
                    return (val != null && val != DBNull.Value) ? Convert.ToInt32(val).ToString() : "0";
                }
            }
            catch { return "0"; }
        }

        private static string NullSafe(object val)
        {
            return (val == null || val == DBNull.Value) ? "" : val.ToString();
        }

        private static string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "S";
            var parts = name.Trim().Split(' ');
            if (parts.Length >= 2)
                return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
            return name.Substring(0, Math.Min(2, name.Length)).ToUpper();
        }

        // ══════════════════════════════════════════════════════════════
        // AJAX CRUD HANDLERS
        // ══════════════════════════════════════════════════════════════
        private void HandleAjax()
        {
            Response.ContentType = "application/json";
            try
            {
                if (Session["userId"] == null || Session["role"]?.ToString() != "Admin")
                { Response.Write("{\"success\":false,\"msg\":\"Unauthorized\"}"); Response.End(); return; }
                string action = Request.QueryString["action"] ?? "";
                string adminId = Session["userId"].ToString();
                switch (action)
                {
                    case "add": HandleAdd(adminId); break;
                    case "edit": HandleEdit(adminId); break;
                    case "changeStatus": HandleChangeStatus(adminId); break;
                    case "archive": HandleArchive(adminId); break;
                    case "getStudent": HandleGetStudent(); break;
                    default: Response.Write("{\"success\":false,\"msg\":\"Unknown action\"}"); break;
                }
            }
            catch (Exception ex) { Response.Write("{\"success\":false,\"msg\":\"" + EscJson(ex.Message) + "\"}"); }
            Response.End();
        }

        private void HandleGetStudent()
        {
            string sid = Request.QueryString["studentId"] ?? "";
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(@"SELECT s.[studentId],s.[name],s.[phoneNumber],s.[currentLevelId],u.[email],u.[username],u.[status]
                    FROM dbo.[Student] s LEFT JOIN dbo.[User] u ON u.[userId]=s.[userId] WHERE s.[studentId]=@sid", conn))
                {
                    cmd.Parameters.AddWithValue("@sid", sid);
                    using (var rd = cmd.ExecuteReader())
                    {
                        if (!rd.Read()) { Response.Write("{\"success\":false,\"msg\":\"Not found\"}"); return; }
                        Response.Write("{\"success\":true,\"data\":{\"studentId\":\"" + EscJson(NullSafe(rd["studentId"])) +
                            "\",\"name\":\"" + EscJson(NullSafe(rd["name"])) +
                            "\",\"email\":\"" + EscJson(NullSafe(rd["email"])) +
                            "\",\"phone\":\"" + EscJson(NullSafe(rd["phoneNumber"])) +
                            "\",\"levelId\":\"" + EscJson(NullSafe(rd["currentLevelId"])) +
                            "\",\"username\":\"" + EscJson(NullSafe(rd["username"])) +
                            "\",\"status\":\"" + EscJson(NullSafe(rd["status"])) + "\"}}");
                    }
                }
            }
        }

        private void HandleAdd(string adminId)
        {
            // Read parameters from Form body (sent via FormData)
            string name = Request.Form["name"] ?? "";
            string username = Request.Form["username"] ?? "";
            string password = Request.Form["password"] ?? "";
            string email = Request.Form["email"] ?? "";
            string phone = Request.Form["phone"] ?? "";
            string levelId = Request.Form["levelId"] ?? "";
            string lang = Request.Form["lang"] ?? "EN";
            if (string.IsNullOrWhiteSpace(name) || string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(email))
            { Response.Write("{\"success\":false,\"msg\":\"Name, username and email are required.\"}"); return; }
            if (string.IsNullOrWhiteSpace(password) || password.Length < 8)
            { Response.Write("{\"success\":false,\"msg\":\"Password must be at least 8 characters.\"}"); return; }

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Check uniqueness before starting transaction
                using (var chk = new SqlCommand("SELECT COUNT(*) FROM dbo.[User] WHERE [email]=@e OR [username]=@u", conn))
                { chk.Parameters.AddWithValue("@e", email); chk.Parameters.AddWithValue("@u", username);
                  if (Convert.ToInt32(chk.ExecuteScalar()) > 0) { Response.Write("{\"success\":false,\"msg\":\"Username or email already exists.\"}"); return; } }

                // BEGIN TRANSACTION — all inserts succeed or none persist
                using (var txn = conn.BeginTransaction())
                {
                    try
                    {
                        string userId = GenId(conn, "User", "userId", "U", txn);
                        string studentId = GenId(conn, "Student", "studentId", "S", txn);

                        // 1. Insert User
                        using (var cmd = new SqlCommand("INSERT INTO dbo.[User]([userId],[username],[password],[email],[role],[preferredLanguage],[status]) VALUES(@uid,@un,@pw,@em,'Student',@lg,'Active')", conn, txn))
                        { cmd.Parameters.AddWithValue("@uid", userId); cmd.Parameters.AddWithValue("@un", username); cmd.Parameters.AddWithValue("@pw", password); cmd.Parameters.AddWithValue("@em", email); cmd.Parameters.AddWithValue("@lg", lang); cmd.ExecuteNonQuery(); }

                        // 2. Insert Student (foreign key to User)
                        using (var cmd = new SqlCommand("INSERT INTO dbo.[Student]([studentId],[userId],[name],[phoneNumber],[currentLevelId],[XP],[parentCode]) VALUES(@sid,@uid,@name,@ph,@lv,0,@pc)", conn, txn))
                        { cmd.Parameters.AddWithValue("@sid", studentId); cmd.Parameters.AddWithValue("@uid", userId); cmd.Parameters.AddWithValue("@name", name);
                          cmd.Parameters.AddWithValue("@ph", string.IsNullOrEmpty(phone) ? (object)DBNull.Value : phone);
                          cmd.Parameters.AddWithValue("@lv", string.IsNullOrEmpty(levelId) ? "LV001" : levelId);
                          cmd.Parameters.AddWithValue("@pc", "PC" + DateTime.Now.ToString("yyMMddHHmmss")); cmd.ExecuteNonQuery(); }

                        // 3. Insert Notification
                        string notifId = GenId(conn, "Notification", "notificationId", "N", txn);
                        using (var cmd = new SqlCommand("INSERT INTO dbo.[Notification]([notificationId],[toUserId],[titleEN],[titleBM],[messageEN],[messageBM],[isRead],[createdAt]) VALUES(@a,@b,'Welcome to ScienceBuddy!','Selamat Datang ke ScienceBuddy!','Your student account has been created. Start learning today!','Akaun pelajar anda telah dicipta. Mula belajar hari ini!',0,@c)", conn, txn))
                        { cmd.Parameters.AddWithValue("@a", notifId); cmd.Parameters.AddWithValue("@b", userId); cmd.Parameters.AddWithValue("@c", DateTime.Now); cmd.ExecuteNonQuery(); }

                        // 4. Insert Log
                        string logId = GenId(conn, "Log", "logId", "LOG", txn);
                        using (var cmd = new SqlCommand("INSERT INTO dbo.[Log]([logId],[userId],[action],[description],[logDateTime],[status]) VALUES(@a,@b,@c,@d,@e,'Success')", conn, txn))
                        { cmd.Parameters.AddWithValue("@a", logId); cmd.Parameters.AddWithValue("@b", adminId); cmd.Parameters.AddWithValue("@c", "Added Student"); cmd.Parameters.AddWithValue("@d", "Created student: " + name + " (" + studentId + ")."); cmd.Parameters.AddWithValue("@e", DateTime.Now); cmd.ExecuteNonQuery(); }

                        // COMMIT — all steps succeeded
                        txn.Commit();
                    }
                    catch (Exception ex)
                    {
                        // ROLLBACK — no partial records
                        txn.Rollback();
                        Response.Write("{\"success\":false,\"msg\":\"Transaction failed: " + EscJson(ex.Message) + "\"}");
                        return;
                    }
                }
            }
            Response.Write("{\"success\":true}");
        }

        private void HandleEdit(string adminId)
        {
            string studentId = Request.QueryString["studentId"] ?? "";
            string name = Request.QueryString["name"] ?? "";
            string email = Request.QueryString["email"] ?? "";
            string phone = Request.QueryString["phone"] ?? "";
            string levelId = Request.QueryString["levelId"] ?? "";
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                string userId = ""; using (var cmd = new SqlCommand("SELECT [userId] FROM dbo.[Student] WHERE [studentId]=@sid", conn))
                { cmd.Parameters.AddWithValue("@sid", studentId); var v = cmd.ExecuteScalar(); userId = v?.ToString() ?? ""; }
                if (string.IsNullOrEmpty(userId)) { Response.Write("{\"success\":false,\"msg\":\"Not found.\"}"); return; }
                using (var cmd = new SqlCommand("UPDATE dbo.[Student] SET [name]=@n,[phoneNumber]=@p,[currentLevelId]=@lv WHERE [studentId]=@sid", conn))
                { cmd.Parameters.AddWithValue("@n", name); cmd.Parameters.AddWithValue("@p", string.IsNullOrEmpty(phone) ? (object)DBNull.Value : phone); cmd.Parameters.AddWithValue("@lv", string.IsNullOrEmpty(levelId) ? "LV001" : levelId); cmd.Parameters.AddWithValue("@sid", studentId); cmd.ExecuteNonQuery(); }
                if (!string.IsNullOrEmpty(email)) { using (var cmd = new SqlCommand("UPDATE dbo.[User] SET [email]=@e WHERE [userId]=@uid", conn)) { cmd.Parameters.AddWithValue("@e", email); cmd.Parameters.AddWithValue("@uid", userId); cmd.ExecuteNonQuery(); } }
                InsertLog(conn, adminId, "Updated Student", "Updated student " + name + " (" + studentId + ").", "Success");
                InsertNotif(conn, userId, "Account Updated", "Akaun Dikemas Kini", "Your account information has been updated.", "Maklumat akaun anda telah dikemas kini.");
            }
            Response.Write("{\"success\":true}");
        }

        private void HandleChangeStatus(string adminId)
        {
            string studentId = Request.QueryString["studentId"] ?? "";
            string newStatus = Request.QueryString["newStatus"] ?? "";
            string reason = Request.QueryString["reason"] ?? "";
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                string userId = ""; using (var cmd = new SqlCommand("SELECT [userId] FROM dbo.[Student] WHERE [studentId]=@sid", conn))
                { cmd.Parameters.AddWithValue("@sid", studentId); var v = cmd.ExecuteScalar(); userId = v?.ToString() ?? ""; }
                if (string.IsNullOrEmpty(userId)) { Response.Write("{\"success\":false,\"msg\":\"Not found.\"}"); return; }
                using (var cmd = new SqlCommand("UPDATE dbo.[User] SET [status]=@s WHERE [userId]=@uid", conn))
                { cmd.Parameters.AddWithValue("@s", newStatus); cmd.Parameters.AddWithValue("@uid", userId); cmd.ExecuteNonQuery(); }
                string aId = GenId(conn, "UserStatusAction", "actionId", "USA");
                using (var cmd = new SqlCommand("INSERT INTO dbo.[UserStatusAction]([actionId],[userId],[actionType],[reason],[actionDate],[performedBy]) VALUES(@a,@u,@t,@r,@d,@p)", conn))
                { cmd.Parameters.AddWithValue("@a", aId); cmd.Parameters.AddWithValue("@u", userId); cmd.Parameters.AddWithValue("@t", newStatus); cmd.Parameters.AddWithValue("@r", string.IsNullOrEmpty(reason) ? "Status changed by administrator." : reason); cmd.Parameters.AddWithValue("@d", DateTime.Today); cmd.Parameters.AddWithValue("@p", adminId); cmd.ExecuteNonQuery(); }
                InsertLog(conn, adminId, "Student Status Changed", "Changed " + studentId + " to " + newStatus + ".", "Success");
                string tEN = newStatus == "Active" ? "Account Restored" : "Account " + newStatus;
                string tBM = newStatus == "Active" ? "Akaun Dipulihkan" : "Akaun " + newStatus;
                InsertNotif(conn, userId, tEN, tBM, "Your account status has been changed to " + newStatus + ".", "Status akaun anda telah ditukar kepada " + newStatus + ".");
            }
            Response.Write("{\"success\":true}");
        }

        private void HandleArchive(string adminId)
        {
            string studentId = Request.QueryString["studentId"] ?? "";
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                string userId = ""; using (var cmd = new SqlCommand("SELECT [userId] FROM dbo.[Student] WHERE [studentId]=@sid", conn))
                { cmd.Parameters.AddWithValue("@sid", studentId); var v = cmd.ExecuteScalar(); userId = v?.ToString() ?? ""; }
                if (string.IsNullOrEmpty(userId)) { Response.Write("{\"success\":false,\"msg\":\"Not found.\"}"); return; }
                using (var cmd = new SqlCommand("UPDATE dbo.[User] SET [status]='Deleted' WHERE [userId]=@uid", conn))
                { cmd.Parameters.AddWithValue("@uid", userId); cmd.ExecuteNonQuery(); }
                string aId = GenId(conn, "UserStatusAction", "actionId", "USA");
                using (var cmd = new SqlCommand("INSERT INTO dbo.[UserStatusAction]([actionId],[userId],[actionType],[reason],[actionDate],[performedBy]) VALUES(@a,@u,'Deleted','Archived by administrator.',@d,@p)", conn))
                { cmd.Parameters.AddWithValue("@a", aId); cmd.Parameters.AddWithValue("@u", userId); cmd.Parameters.AddWithValue("@d", DateTime.Today); cmd.Parameters.AddWithValue("@p", adminId); cmd.ExecuteNonQuery(); }
                InsertLog(conn, adminId, "Archived Student", "Archived student " + studentId + ".", "Success");
            }
            Response.Write("{\"success\":true}");
        }

        private void InsertLog(SqlConnection c, string uid, string action, string desc, string status)
        { string id = GenId(c, "Log", "logId", "LOG"); using (var cmd = new SqlCommand("INSERT INTO dbo.[Log]([logId],[userId],[action],[description],[logDateTime],[status]) VALUES(@a,@b,@c,@d,@e,@f)", c)) { cmd.Parameters.AddWithValue("@a", id); cmd.Parameters.AddWithValue("@b", uid); cmd.Parameters.AddWithValue("@c", action); cmd.Parameters.AddWithValue("@d", desc.Length > 900 ? desc.Substring(0, 900) : desc); cmd.Parameters.AddWithValue("@e", DateTime.Now); cmd.Parameters.AddWithValue("@f", status); cmd.ExecuteNonQuery(); } }

        private void InsertNotif(SqlConnection c, string toUid, string tEN, string tBM, string mEN, string mBM)
        { if (string.IsNullOrEmpty(toUid)) return; string id = GenId(c, "Notification", "notificationId", "N"); using (var cmd = new SqlCommand("INSERT INTO dbo.[Notification]([notificationId],[toUserId],[titleEN],[titleBM],[messageEN],[messageBM],[isRead],[createdAt]) VALUES(@a,@b,@c,@d,@e,@f,0,@g)", c)) { cmd.Parameters.AddWithValue("@a", id); cmd.Parameters.AddWithValue("@b", toUid); cmd.Parameters.AddWithValue("@c", tEN); cmd.Parameters.AddWithValue("@d", tBM); cmd.Parameters.AddWithValue("@e", mEN); cmd.Parameters.AddWithValue("@f", mBM); cmd.Parameters.AddWithValue("@g", DateTime.Now); cmd.ExecuteNonQuery(); } }

        private string GenId(SqlConnection c, string tbl, string col, string pfx)
        { return GenId(c, tbl, col, pfx, null); }

        private string GenId(SqlConnection c, string tbl, string col, string pfx, SqlTransaction txn)
        { using (var cmd = new SqlCommand(string.Format("SELECT TOP 1 [{0}] FROM dbo.[{1}] ORDER BY [{0}] DESC", col, tbl), c)) { cmd.Transaction = txn; var v = cmd.ExecuteScalar(); if (v == null || v == DBNull.Value) return pfx + "001"; string l = v.ToString(); int n; int.TryParse(l.Substring(pfx.Length), out n); n++; return pfx + n.ToString().PadLeft(l.Length - pfx.Length, '0'); } }

        private static string EscJson(string s) { return (s ?? "").Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", ""); }
    }
}
