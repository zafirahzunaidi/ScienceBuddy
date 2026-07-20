using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

// Admin TeacherManagement - Code Behind

namespace ScienceBuddy.Admin
{
    public partial class TeacherManagement : Page
    {
        private bool _isAjax = false;

        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected string CurrentLanguage => ((ScienceBuddy.SiteMaster)Master).CurrentLanguage;

        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        protected override void Render(HtmlTextWriter writer)
        {
            if (!_isAjax)
                base.Render(writer);
        }

        // --- Page Lifecycle ---

        protected void Page_Load(object sender, EventArgs e)
        {
            // AJAX handler
            if (Request.QueryString["handler"] == "TeacherCRUD" && Request.HttpMethod == "POST")
            { _isAjax = true; HandleTeacherAjax(); return; }

            if (Session["userId"] == null)
            { Response.Redirect("~/Login.aspx", false); return; }
            if (Session["role"] == null || Session["role"].ToString() != "Admin")
            { Response.Redirect("~/Login.aspx", false); return; }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                SetMasterUser();
                LoadInsights();
                LoadTeachers("", "", "", "name");
            }

            txtSearch.Attributes["placeholder"] = T("Search teacher name…", "Cari nama guru…");
            btnSearch.Text = T("Search", "Cari");
            btnReset.Text = T("Reset", "Tetapkan Semula");
            btnCloseProfile.Text = T("Close", "Tutup");
        }

        // --- Data Loading ---

        private void SetMasterUser()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [username] FROM dbo.[User] WHERE [userId]=@uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", Session["userId"].ToString());
                    var result = cmd.ExecuteScalar();
                    string name = result != null && result != DBNull.Value ? result.ToString() : "Admin";
                    string initials = name.Length >= 2 ? name.Substring(0, 2).ToUpper() : name.ToUpper();
                    ((ScienceBuddy.SiteMaster)Master).SetUserInfo(name, "Administrator", initials);
                }
            }
        }

        private void LoadInsights()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                litTotal.Text = SafeScalar(conn, "SELECT COUNT(*) FROM dbo.[Teacher]");
                litActive.Text = SafeScalar(conn, "SELECT COUNT(*) FROM dbo.[Teacher] WHERE [status]='Certified'");
                litLessons.Text = SafeScalar(conn, "SELECT COUNT(*) FROM dbo.[Material] m JOIN dbo.[User] u ON u.[userId]=m.[createdByUserId] WHERE u.[role]='Teacher'");
                litQuizzes.Text = SafeScalar(conn, "SELECT COUNT(*) FROM dbo.[Quiz] q JOIN dbo.[User] u ON u.[userId]=q.[createdByUserId] WHERE u.[role]='Teacher'");
            }
        }

        private void LoadTeachers(string search, string statusFilter, string langFilter, string sort)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                string sql = @"SELECT t.[teacherId],t.[name],t.[phoneNumber],t.[academicQualification],t.[status] AS tStatus,
                    u.[username],u.[email],u.[preferredLanguage],
                    (SELECT COUNT(*) FROM dbo.[Material] WHERE [createdByUserId]=t.[userId]) AS matCount,
                    (SELECT COUNT(*) FROM dbo.[Quiz] WHERE [createdByUserId]=t.[userId] AND [quizType]='Practice') AS qzCount
                    FROM dbo.[Teacher] t LEFT JOIN dbo.[User] u ON u.[userId]=t.[userId] WHERE 1=1";

                if (!string.IsNullOrWhiteSpace(search))
                    sql += " AND (t.[name] LIKE @s OR u.[username] LIKE @s)";
                if (!string.IsNullOrWhiteSpace(statusFilter))
                    sql += " AND t.[status]=@st";
                if (!string.IsNullOrWhiteSpace(langFilter))
                    sql += " AND u.[preferredLanguage]=@lg";

                sql += sort == "name_desc" ? " ORDER BY t.[name] DESC" : " ORDER BY t.[name] ASC";

                using (var cmd = new SqlCommand(sql, conn))
                {
                    if (!string.IsNullOrWhiteSpace(search))
                        cmd.Parameters.AddWithValue("@s", "%" + search + "%");
                    if (!string.IsNullOrWhiteSpace(statusFilter))
                        cmd.Parameters.AddWithValue("@st", statusFilter);
                    if (!string.IsNullOrWhiteSpace(langFilter))
                        cmd.Parameters.AddWithValue("@lg", langFilter);

                    var da = new SqlDataAdapter(cmd);
                    var dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count == 0)
                    {
                        pnlTeachers.Visible = false;
                        pnlEmpty.Visible = true;
                        return;
                    }

                    string[] grads = {
                        "background:linear-gradient(135deg,#059669,#34D399);",
                        "background:linear-gradient(135deg,#0891B2,#22D3EE);",
                        "background:linear-gradient(135deg,#7C3AED,#A78BFA);",
                        "background:linear-gradient(135deg,#D97706,#FBBF24);",
                        "background:linear-gradient(135deg,#EC4899,#F472B6);",
                        "background:linear-gradient(135deg,#6366F1,#818CF8);"
                    };

                    var list = new List<object>();
                    int idx = 0;
                    foreach (DataRow row in dt.Rows)
                    {
                        string teacherName = NullSafe(row["name"]);
                        string username = NullSafe(row["username"]);
                        string displayName = !string.IsNullOrWhiteSpace(teacherName) ? teacherName : username;
                        string status = NullSafe(row["tStatus"]);
                        string lang = NullSafe(row["preferredLanguage"]);

                        list.Add(new
                        {
                            teacherId = row["teacherId"].ToString(),
                            displayName = displayName,
                            username = username,
                            initials = GetInitials(displayName),
                            phone = string.IsNullOrWhiteSpace(NullSafe(row["phoneNumber"])) ? "-" : NullSafe(row["phoneNumber"]),
                            language = lang == "BM" ? "BM" : "EN",
                            materialsCount = row["matCount"],
                            quizzesCount = row["qzCount"],
                            statusLabel = status == "Certified" ? T("Certified", "Bertauliah") : status == "Pending" ? T("Pending", "Menunggu") : T("Not Certified", "Tidak Bertauliah"),
                            statusPillClass = status == "Certified" ? "tm-pill-certified" : status == "Pending" ? "tm-pill-pending" : "tm-pill-rejected",
                            dotClass = status == "Certified" ? "certified" : status == "Pending" ? "pending" : "rejected",
                            gradient = grads[idx % grads.Length]
                        });
                        idx++;
                    }

                    pnlTeachers.Visible = true;
                    pnlEmpty.Visible = false;
                    rptTeachers.DataSource = list;
                    rptTeachers.DataBind();
                }
            }
        }

        // --- Event Handlers ---

        protected void rptTeachers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string tid = e.CommandArgument.ToString();
            if (e.CommandName == "ViewProfile") ShowProfile(tid);
            else if (e.CommandName == "ViewContent") ShowContent(tid);
        }

        protected void btnCloseModal_Click(object sender, EventArgs e)
        {
            pnlProfileModal.Visible = false;
            pnlContentModal.Visible = false;
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadInsights();
            LoadTeachers(txtSearch.Text.Trim(), ddlStatus.SelectedValue, ddlLang.SelectedValue, ddlSort.SelectedValue);
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlStatus.SelectedIndex = 0;
            ddlLang.SelectedIndex = 0;
            ddlSort.SelectedIndex = 0;
            LoadInsights();
            LoadTeachers("", "", "", "name");
        }

        // --- Profile Modal ---

        private void ShowProfile(string tid)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(@"SELECT t.[name],t.[phoneNumber],t.[academicQualification],t.[status],t.[approvedDate],t.[userId],
                    u.[username],u.[email],u.[preferredLanguage],
                    (SELECT COUNT(*) FROM dbo.[Material] WHERE [createdByUserId]=t.[userId]) AS matCnt,
                    (SELECT COUNT(*) FROM dbo.[Quiz] WHERE [createdByUserId]=t.[userId] AND [quizType]='Practice') AS qzCnt,
                    (SELECT COUNT(*) FROM dbo.[LiveConsultationSession] WHERE [teacherId]=t.[teacherId]) AS sessCnt,
                    (SELECT COUNT(*) FROM dbo.[Material] WHERE [createdByUserId]=t.[userId] AND [status]='Pending')+(SELECT COUNT(*) FROM dbo.[Quiz] WHERE [createdByUserId]=t.[userId] AND [status]='Pending' AND [quizType]='Practice') AS pendCnt
                    FROM dbo.[Teacher] t LEFT JOIN dbo.[User] u ON u.[userId]=t.[userId] WHERE t.[teacherId]=@tid", conn))
                {
                    cmd.Parameters.AddWithValue("@tid", tid);
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read()) return;

                        string teacherName = NullSafe(reader["name"]);
                        string username = NullSafe(reader["username"]);
                        string displayName = !string.IsNullOrWhiteSpace(teacherName) ? teacherName : username;

                        litMInitials.Text = GetInitials(displayName);
                        litMName.Text = HttpUtility.HtmlEncode(displayName);
                        litMUsername.Text = HttpUtility.HtmlEncode(username);
                        litMEmail.Text = HttpUtility.HtmlEncode(NullSafe(reader["email"]));
                        litMPhone.Text = HttpUtility.HtmlEncode(NullSafe(reader["phoneNumber"]));
                        litMQual.Text = HttpUtility.HtmlEncode(NullSafe(reader["academicQualification"]));

                        string status = NullSafe(reader["status"]);
                        litMStatus.Text = string.Format("<span class=\"sb-badge {0}\">{1}</span>",
                            status == "Certified" ? "sb-badge-success" : status == "Pending" ? "sb-badge-warning" : "sb-badge-error",
                            HttpUtility.HtmlEncode(status == "Certified" ? T("Certified", "Bertauliah") : status == "Pending" ? T("Pending", "Menunggu") : T("Not Certified", "Tidak Bertauliah")));

                        litMLang.Text = NullSafe(reader["preferredLanguage"]) == "BM" ? "Bahasa Melayu" : "English";
                        litMDate.Text = reader["approvedDate"] == DBNull.Value ? "-" : Convert.ToDateTime(reader["approvedDate"]).ToString("d MMM yyyy");
                        litMMaterials.Text = reader["matCnt"].ToString();
                        litMQuizzes.Text = reader["qzCnt"].ToString();
                        litMSessions.Text = reader["sessCnt"].ToString();
                        litMPending.Text = reader["pendCnt"].ToString();
                    }
                }
            }
            pnlProfileModal.Visible = true;
            pnlContentModal.Visible = false;
        }

        // --- Content Modal ---

        private void ShowContent(string tid)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Get userId from teacherId
                string userId = "";
                using (var cmd = new SqlCommand("SELECT [userId] FROM dbo.[Teacher] WHERE [teacherId]=@tid", conn))
                {
                    cmd.Parameters.AddWithValue("@tid", tid);
                    var result = cmd.ExecuteScalar();
                    userId = result != null ? result.ToString() : "";
                }

                if (string.IsNullOrEmpty(userId))
                {
                    pnlContentList.Visible = false;
                    pnlNoContent.Visible = true;
                    pnlContentModal.Visible = true;
                    pnlProfileModal.Visible = false;
                    return;
                }

                string sql = @"SELECT 'Material' AS cType, [materialTitle] AS title, [createdDate] AS dt, [status] FROM dbo.[Material] WHERE [createdByUserId]=@uid
                    UNION ALL SELECT 'Practice Quiz', ISNULL([quizTitleEN],[quizTitleBM]), [createdAt], [status] FROM dbo.[Quiz] WHERE [createdByUserId]=@uid AND [quizType]='Practice'
                    ORDER BY dt DESC";

                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    var da = new SqlDataAdapter(cmd);
                    var dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count == 0)
                    {
                        pnlContentList.Visible = false;
                        pnlNoContent.Visible = true;
                    }
                    else
                    {
                        var list = new List<object>();
                        foreach (DataRow row in dt.Rows)
                        {
                            string status = NullSafe(row["status"]);
                            list.Add(new
                            {
                                contentType = row["cType"].ToString(),
                                title = NullSafe(row["title"]),
                                dateStr = row["dt"] == DBNull.Value ? "-" : Convert.ToDateTime(row["dt"]).ToString("d MMM yyyy"),
                                statusLabel = status == "Approved" ? T("Approved", "Diluluskan") : status == "Pending" ? T("Pending", "Menunggu") : T("Rejected", "Ditolak"),
                                statusCls = status == "Approved" ? "sb-badge-success" : status == "Pending" ? "sb-badge-warning" : "sb-badge-error",
                                typeCls = row["cType"].ToString() == "Material" ? "sb-badge-secondary" : "sb-badge-yellow"
                            });
                        }
                        pnlContentList.Visible = true;
                        pnlNoContent.Visible = false;
                        rptContent.DataSource = list;
                        rptContent.DataBind();
                    }
                }
            }
            pnlContentModal.Visible = true;
            pnlProfileModal.Visible = false;
        }

        // --- AJAX Handlers ---

        private void HandleTeacherAjax()
        {
            Response.Clear();
            Response.ContentType = "application/json";
            try
            {
                if (Session["userId"] == null || Session["role"]?.ToString() != "Admin")
                { Response.Write("{\"success\":false,\"msg\":\"Unauthorized\"}"); }
                else
                {
                    string action = Request.QueryString["action"] ?? "";
                    string adminId = Session["userId"].ToString();
                    switch (action)
                    {
                        case "addTeacher": HandleAdd(adminId); break;
                        default: Response.Write("{\"success\":false,\"msg\":\"Unknown action\"}"); break;
                    }
                }
            }
            catch (Exception ex)
            {
                Response.Clear();
                Response.Write("{\"success\":false,\"msg\":\"" + EscJ(ex.Message) + "\"}");
            }
            Response.Flush();
            HttpContext.Current.ApplicationInstance.CompleteRequest();
        }

        private void HandleAdd(string adminId)
        {
            string name          = Request.Form["name"]          ?? "";
            string username      = Request.Form["username"]      ?? "";
            string email         = Request.Form["email"]         ?? "";
            string password      = Request.Form["password"]      ?? "";
            string phone         = Request.Form["phone"]         ?? "";
            string qualification = Request.Form["qualification"] ?? "";
            string bio           = Request.Form["bio"]           ?? "";
            string lang          = Request.Form["lang"]          ?? "EN";

            // Server-side validation
            if (string.IsNullOrWhiteSpace(name) || string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(email))
            { Response.Write("{\"success\":false,\"msg\":\"Name, username and email are required.\"}"); return; }
            if (string.IsNullOrWhiteSpace(phone))
            { Response.Write("{\"success\":false,\"msg\":\"Phone number is required.\"}"); return; }
            if (string.IsNullOrWhiteSpace(password) || password.Length < 8)
            { Response.Write("{\"success\":false,\"msg\":\"Password must be at least 8 characters.\"}"); return; }
            if (string.IsNullOrWhiteSpace(qualification))
            { Response.Write("{\"success\":false,\"msg\":\"Academic qualification is required.\"}"); return; }
            if (string.IsNullOrWhiteSpace(bio))
            { Response.Write("{\"success\":false,\"msg\":\"Bio is required.\"}"); return; }

            // Validate and save certificate PDF
            var certFile = Request.Files["cert"];
            if (certFile == null || certFile.ContentLength == 0)
            { Response.Write("{\"success\":false,\"msg\":\"Teaching certificate PDF is required.\"}"); return; }
            string certExt = System.IO.Path.GetExtension(certFile.FileName).ToLower();
            if (certExt != ".pdf")
            { Response.Write("{\"success\":false,\"msg\":\"Only PDF files are accepted for the certificate.\"}"); return; }

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Check username uniqueness
                using (var chk = new SqlCommand("SELECT COUNT(*) FROM dbo.[User] WHERE [username]=@u", conn))
                { chk.Parameters.AddWithValue("@u", username);
                  if (Convert.ToInt32(chk.ExecuteScalar()) > 0) { Response.Write("{\"success\":false,\"msg\":\"Username already exists.\"}"); return; } }

                // Check email uniqueness
                using (var chk = new SqlCommand("SELECT COUNT(*) FROM dbo.[User] WHERE [email]=@e", conn))
                { chk.Parameters.AddWithValue("@e", email);
                  if (Convert.ToInt32(chk.ExecuteScalar()) > 0) { Response.Write("{\"success\":false,\"msg\":\"Email already exists.\"}"); return; } }

                // Check phone uniqueness
                using (var chk = new SqlCommand("SELECT COUNT(*) FROM dbo.[Teacher] WHERE [phoneNumber]=@p", conn))
                { chk.Parameters.AddWithValue("@p", phone);
                  if (Convert.ToInt32(chk.ExecuteScalar()) > 0) { Response.Write("{\"success\":false,\"msg\":\"Phone number already exists.\"}"); return; } }

                // Save certificate to images/teacher
                string certPath = "";
                try
                {
                    string folder = HttpContext.Current.Server.MapPath("~/Images/Teacher/");
                    if (!System.IO.Directory.Exists(folder))
                        System.IO.Directory.CreateDirectory(folder);
                    string safeName = System.IO.Path.GetFileNameWithoutExtension(certFile.FileName).Replace(" ", "_");
                    string fileName = "cert_" + safeName + "_" + DateTime.Now.ToString("yyyyMMddHHmmss") + ".pdf";
                    certFile.SaveAs(System.IO.Path.Combine(folder, fileName));
                    certPath = "Images/Teacher/" + fileName;
                }
                catch (Exception ex)
                { Response.Write("{\"success\":false,\"msg\":\"Failed to save certificate: " + EscJ(ex.Message) + "\"}"); return; }

                // BEGIN TRANSACTION
                using (var txn = conn.BeginTransaction())
                {
                    try
                    {
                        string userId    = GenId(conn, "User",    "userId",    "U",   txn);
                        string teacherId = GenId(conn, "Teacher", "teacherId", "T",   txn);

                        // 1. Insert User
                        using (var cmd = new SqlCommand("INSERT INTO dbo.[User]([userId],[username],[password],[email],[role],[preferredLanguage],[status]) VALUES(@uid,@un,@pw,@em,'Teacher',@lg,'Active')", conn, txn))
                        { cmd.Parameters.AddWithValue("@uid", userId); cmd.Parameters.AddWithValue("@un", username); cmd.Parameters.AddWithValue("@pw", PasswordHelper.HashPassword(password)); cmd.Parameters.AddWithValue("@em", email); cmd.Parameters.AddWithValue("@lg", lang); cmd.ExecuteNonQuery(); }

                        // 2. Insert Teacher (status=Pending, approvedDate=NULL)
                        using (var cmd = new SqlCommand("INSERT INTO dbo.[Teacher]([teacherId],[userId],[name],[phoneNumber],[academicQualification],[bio],[licenseCert],[status],[approvedDate]) VALUES(@tid,@uid,@name,@ph,@qual,@bio,@cert,'Pending',NULL)", conn, txn))
                        { cmd.Parameters.AddWithValue("@tid", teacherId); cmd.Parameters.AddWithValue("@uid", userId); cmd.Parameters.AddWithValue("@name", name);
                          cmd.Parameters.AddWithValue("@ph", phone);
                          cmd.Parameters.AddWithValue("@qual", qualification);
                          cmd.Parameters.AddWithValue("@bio", bio);
                          cmd.Parameters.AddWithValue("@cert", certPath);
                          cmd.ExecuteNonQuery(); }

                        // 3. Insert Welcome Notification
                        string notifId = GenId(conn, "Notification", "notificationId", "N", txn);
                        using (var cmd = new SqlCommand("INSERT INTO dbo.[Notification]([notificationId],[toUserId],[titleEN],[titleBM],[messageEN],[messageBM],[isRead],[createdAt]) VALUES(@nid,@uid,@tEN,@tBM,@mEN,@mBM,0,GETDATE())", conn, txn))
                        { cmd.Parameters.AddWithValue("@nid", notifId); cmd.Parameters.AddWithValue("@uid", userId);
                          cmd.Parameters.AddWithValue("@tEN", "Welcome to ScienceBuddy");
                          cmd.Parameters.AddWithValue("@tBM", "Selamat Datang ke ScienceBuddy");
                          cmd.Parameters.AddWithValue("@mEN", "Welcome! Your teacher account has been successfully created. Your account is currently under review by the administrator. Once your teaching credentials are approved, you will be able to upload learning materials, create practice quizzes and conduct live consultation sessions. Thank you for joining ScienceBuddy.");
                          cmd.Parameters.AddWithValue("@mBM", "Selamat datang! Akaun guru anda telah berjaya didaftarkan. Akaun anda sedang menunggu semakan dan kelulusan daripada pentadbir. Selepas sijil pengajaran anda diluluskan, anda boleh memuat naik bahan pembelajaran, mencipta kuiz latihan serta menjalankan sesi konsultasi secara langsung. Terima kasih kerana menyertai ScienceBuddy.");
                          cmd.ExecuteNonQuery(); }

                        // 4. Insert Log
                        string logId = GenId(conn, "Log", "logId", "LOG", txn);
                        using (var cmd = new SqlCommand("INSERT INTO dbo.[Log]([logId],[userId],[action],[description],[logDateTime],[status]) VALUES(@a,@b,'Teacher Created',@c,@d,'Success')", conn, txn))
                        { cmd.Parameters.AddWithValue("@a", logId); cmd.Parameters.AddWithValue("@b", adminId);
                          cmd.Parameters.AddWithValue("@c", "Administrator created teacher account " + teacherId + " (" + name + ").");
                          cmd.Parameters.AddWithValue("@d", DateTime.Now); cmd.ExecuteNonQuery(); }

                        txn.Commit();

                        // Return success with details
                        Response.Write("{\"success\":true,\"teacherId\":\"" + EscJ(teacherId) + "\",\"userId\":\"" + EscJ(userId) + "\",\"username\":\"" + EscJ(username) + "\",\"name\":\"" + EscJ(name) + "\"}");
                    }
                    catch (Exception ex)
                    {
                        txn.Rollback();
                        // If DB failed, clean up the saved file
                        if (!string.IsNullOrEmpty(certPath))
                        { try { string fp = HttpContext.Current.Server.MapPath(certPath); if (System.IO.File.Exists(fp)) System.IO.File.Delete(fp); } catch { } }
                        Response.Write("{\"success\":false,\"msg\":\"Transaction failed: " + EscJ(ex.Message) + "\"}");
                    }
                }
            }
        }

        // --- Helpers ---

        private string SafeScalar(SqlConnection conn, string sql)
        {
            try
            {
                using (var cmd = new SqlCommand(sql, conn))
                {
                    var result = cmd.ExecuteScalar();
                    return result != null && result != DBNull.Value ? Convert.ToInt32(result).ToString() : "0";
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
            if (string.IsNullOrWhiteSpace(name)) return "T";
            var parts = name.Trim().Split(' ');
            return parts.Length >= 2
                ? (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper()
                : name.Substring(0, Math.Min(2, name.Length)).ToUpper();
        }

        private string GenId(SqlConnection conn, string tbl, string col, string pfx)
        {
            return GenId(conn, tbl, col, pfx, null);
        }

        private string GenId(SqlConnection conn, string tbl, string col, string pfx, SqlTransaction txn)
        {
            using (var cmd = new SqlCommand(string.Format("SELECT TOP 1 [{0}] FROM dbo.[{1}] ORDER BY [{0}] DESC", col, tbl), conn))
            {
                cmd.Transaction = txn;
                var result = cmd.ExecuteScalar();
                if (result == null || result == DBNull.Value) return pfx + "001";
                string lastId = result.ToString();
                int num;
                int.TryParse(lastId.Substring(pfx.Length), out num);
                num++;
                return pfx + num.ToString().PadLeft(lastId.Length - pfx.Length, '0');
            }
        }

        private static string EscJ(string s)
        {
            return (s ?? "").Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "");
        }
    }
}
