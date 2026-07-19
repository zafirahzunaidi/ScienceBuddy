using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Net;
using System.Net.Mail;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Parent
{
    public partial class ParentProfile : Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected string CurrentLanguage = "EN";

        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        private string _userId = "";
        private string _parentId = "";

        // --- Page Load ---
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!CheckAuth())
            {
                return;
            }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            LoadLang();
            LoadUnreadBadge();
            _userId = Session["userId"].ToString();
            LoadParentId();

            if (!IsPostBack)
            {
                SetLabels();
                LoadChildren();
                LoadProfileData();
            }
            else
            {
                SetLabels();
            }
        }

        private bool CheckAuth()
        {
            if (Session["userId"] == null || Session["role"] == null ||
                Session["role"].ToString() != "Parent")
            {
                Response.Redirect("~/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return false;
            }
            return true;
        }

        private void LoadLang()
        {
            string cached = Session["preferredLanguage"] as string;
            if (!string.IsNullOrEmpty(cached))
            {
                CurrentLanguage = cached;
                return;
            }

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(
                    "SELECT preferredLanguage FROM dbo.[User] WHERE userId = @userId", conn))
                {
                    cmd.Parameters.AddWithValue("@userId", Session["userId"].ToString());
                    conn.Open();
                    object result = cmd.ExecuteScalar();

                    if (result != null && result != DBNull.Value)
                    {
                        CurrentLanguage = result.ToString();
                        Session["preferredLanguage"] = CurrentLanguage;
                    }
                }
            }
            catch { }
        }

        private void LoadParentId()
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(
                    "SELECT parentId FROM dbo.[Parent] WHERE userId = @userId", conn))
                {
                    cmd.Parameters.AddWithValue("@userId", _userId);
                    conn.Open();
                    object result = cmd.ExecuteScalar();

                    if (result != null)
                    {
                        _parentId = result.ToString();
                    }
                }
            }
            catch { }
        }

        // --- Sidebar Children ---
        private void LoadChildren()
        {
            ddlSidebarChild.Items.Clear();

            try
            {
                const string sql = @"SELECT s.studentId, ISNULL(s.nickname, s.name) AS displayName 
                    FROM dbo.StudentParent sp 
                    INNER JOIN dbo.Student s ON sp.studentId = s.studentId 
                    WHERE sp.parentId = @parentId ORDER BY s.name";

                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@parentId", _parentId);
                    conn.Open();

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            ddlSidebarChild.Items.Add(new ListItem(
                                reader["displayName"].ToString(),
                                reader["studentId"].ToString()));
                        }
                    }
                }
            }
            catch { }

            if (ddlSidebarChild.Items.Count > 0)
            {
                string savedChildId = Session["selectedChildId"] as string;
                if (!string.IsNullOrEmpty(savedChildId) &&
                    ddlSidebarChild.Items.FindByValue(savedChildId) != null)
                {
                    ddlSidebarChild.SelectedValue = savedChildId;
                }
                else
                {
                    Session["selectedChildId"] = ddlSidebarChild.Items[0].Value;
                }
            }
        }

        protected void SidebarChildChanged(object sender, EventArgs e)
        {
            Session["selectedChildId"] = ddlSidebarChild.SelectedValue;
        }

        // --- Labels & Report Category ---
        private void SetLabels()
        {
            btnSave.Text = T("Save Profile Changes", "Simpan Perubahan Profil");
            btnChangePwd.Text = T("Change Password", "Tukar Kata Laluan");
            btnReportSubmit.Text = T("Submit Report", "Hantar Laporan");
            btnDeleteAccount.Text = T("Confirm Close Account", "Sahkan Tutup Akaun");
            LoadReportCategories();
        }

        private void LoadReportCategories()
        {
            string prev = ddlReportCategory.SelectedValue;
            ddlReportCategory.Items.Clear();

            ddlReportCategory.Items.Add(new ListItem(T("-- Select --", "-- Pilih --"), ""));
            ddlReportCategory.Items.Add(new ListItem(T("Account problem", "Masalah akaun"), "Account"));
            ddlReportCategory.Items.Add(new ListItem(T("Child linking problem", "Masalah pautan anak"), "ChildLinking"));
            ddlReportCategory.Items.Add(new ListItem(T("Study plan problem", "Masalah pelan pembelajaran"), "StudyPlan"));
            ddlReportCategory.Items.Add(new ListItem(T("Quiz/progress problem", "Masalah kuiz/kemajuan"), "QuizProgress"));
            ddlReportCategory.Items.Add(new ListItem(T("Teacher/chat problem", "Masalah guru/sembang"), "TeacherChat"));
            ddlReportCategory.Items.Add(new ListItem(T("Forum problem", "Masalah forum"), "Forum"));
            ddlReportCategory.Items.Add(new ListItem(T("Technical problem", "Masalah teknikal"), "Technical"));
            ddlReportCategory.Items.Add(new ListItem(T("Other", "Lain-lain"), "Other"));

            if (!string.IsNullOrEmpty(prev) &&
                ddlReportCategory.Items.FindByValue(prev) != null)
            {
                ddlReportCategory.SelectedValue = prev;
            }
        }

        // --- Load Profile ---
        private void LoadProfileData()
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    string username = "", email = "", accountRole = "";
                    string accountStatus = "", langPref = "";

                    using (var cmd = new SqlCommand(
                        "SELECT username, email, role, status, preferredLanguage FROM dbo.[User] WHERE userId = @userId",
                        conn))
                    {
                        cmd.Parameters.AddWithValue("@userId", _userId);

                        using (var reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                username = reader["username"] != DBNull.Value ? reader["username"].ToString() : "";
                                email = reader["email"] != DBNull.Value ? reader["email"].ToString() : "";
                                accountRole = reader["role"] != DBNull.Value ? reader["role"].ToString() : "";
                                accountStatus = reader["status"] != DBNull.Value ? reader["status"].ToString() : "";
                                langPref = reader["preferredLanguage"] != DBNull.Value ? reader["preferredLanguage"].ToString() : "EN";
                            }
                        }
                    }

                    string parentName = "";
                    string parentPhone = "";

                    using (var cmd = new SqlCommand(
                        "SELECT name, phoneNumber FROM dbo.[Parent] WHERE parentId = @parentId", conn))
                    {
                        cmd.Parameters.AddWithValue("@parentId", _parentId);

                        using (var reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                parentName = reader["name"] != DBNull.Value ? reader["name"].ToString() : "";
                                parentPhone = reader["phoneNumber"] != DBNull.Value ? reader["phoneNumber"].ToString() : "";
                            }
                        }
                    }

                    int childCount = 0;
                    using (var cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM dbo.StudentParent WHERE parentId = @parentId", conn))
                    {
                        cmd.Parameters.AddWithValue("@parentId", _parentId);
                        childCount = (int)cmd.ExecuteScalar();
                    }

                    txtUsername.Text = username;
                    txtName.Text = parentName;
                    txtEmail.Text = email;
                    txtPhone.Text = parentPhone;

                    if (ddlLang.Items.FindByValue(langPref) != null)
                    {
                        ddlLang.SelectedValue = langPref;
                    }

                    litHeroName.Text = Server.HtmlEncode(parentName);
                    litInitials.Text = GetInitials(parentName);
                    litHeroEmail.Text = Server.HtmlEncode(email);
                    litChildrenCount.Text = string.Format(
                        T("{0} child(ren) linked", "{0} anak dipautkan"), childCount);

                    litStatusRole.Text = accountRole;
                    litStatusStatus.Text = accountStatus;
                    litStatusLang.Text = langPref == "BM" ? "Bahasa Melayu" : "English";
                }
            }
            catch { }
        }

        private string GetInitials(string fullName)
        {
            if (string.IsNullOrEmpty(fullName))
            {
                return "P";
            }

            string[] parts = fullName.Trim().Split(' ');
            if (parts.Length >= 2)
            {
                return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
            }

            return parts[0][0].ToString().ToUpper();
        }

        // --- Save Profile ---
        protected void BtnSave_Click(object sender, EventArgs e)
        {
            string name = txtName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string phone = txtPhone.Text.Trim();
            string lang = ddlLang.SelectedValue;

            if (string.IsNullOrEmpty(name))
            {
                ShowMsg(T("Name cannot be empty.", "Nama tidak boleh kosong."), false);
                return;
            }
            if (string.IsNullOrEmpty(email))
            {
                ShowMsg(T("Email cannot be empty.", "E-mel tidak boleh kosong."), false);
                return;
            }

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    using (var cmd = new SqlCommand(
                        "UPDATE dbo.[Parent] SET name = @name, phoneNumber = @phone WHERE parentId = @parentId",
                        conn))
                    {
                        cmd.Parameters.AddWithValue("@name", name);
                        cmd.Parameters.AddWithValue("@phone", (object)phone ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@parentId", _parentId);
                        cmd.ExecuteNonQuery();
                    }

                    using (var cmd = new SqlCommand(
                        "UPDATE dbo.[User] SET email = @email, preferredLanguage = @lang WHERE userId = @userId",
                        conn))
                    {
                        cmd.Parameters.AddWithValue("@email", email);
                        cmd.Parameters.AddWithValue("@lang", lang);
                        cmd.Parameters.AddWithValue("@userId", _userId);
                        cmd.ExecuteNonQuery();
                    }
                }

                Session["preferredLanguage"] = lang;
                CurrentLanguage = lang;

                ShowMsg(T("Profile updated successfully!", "Profil berjaya dikemas kini!"), true);
                LoadProfileData();
            }
            catch
            {
                ShowMsg(T("An error occurred while saving.", "Ralat berlaku semasa menyimpan."), false);
            }
        }

        // --- Change Password ---
        protected void BtnChangePwd_Click(object sender, EventArgs e)
        {
            string currentPwd = txtCurrentPwd.Text;
            string newPwd = txtNewPwd.Text;
            string confirmPwd = txtConfirmPwd.Text;

            if (string.IsNullOrEmpty(currentPwd))
            {
                ShowMsg(T("Please enter your current password.",
                    "Sila masukkan kata laluan semasa anda."), false);
                return;
            }
            if (string.IsNullOrEmpty(newPwd))
            {
                ShowMsg(T("Please enter a new password.",
                    "Sila masukkan kata laluan baharu."), false);
                return;
            }
            if (newPwd.Length < 6)
            {
                ShowMsg(T("New password must be at least 6 characters.",
                    "Kata laluan baharu mesti sekurang-kurangnya 6 aksara."), false);
                return;
            }
            if (newPwd != confirmPwd)
            {
                ShowMsg(T("New passwords do not match.",
                    "Kata laluan baharu tidak sepadan."), false);
                return;
            }

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    string storedHash = "";
                    using (var cmd = new SqlCommand(
                        "SELECT password FROM dbo.[User] WHERE userId = @userId", conn))
                    {
                        cmd.Parameters.AddWithValue("@userId", _userId);
                        object result = cmd.ExecuteScalar();

                        if (result != null && result != DBNull.Value)
                        {
                            storedHash = result.ToString();
                        }
                    }

                    if (!PasswordHelper.VerifyPassword(currentPwd, storedHash))
                    {
                        ShowMsg(T("Current password is incorrect.",
                            "Kata laluan semasa tidak betul."), false);
                        return;
                    }

                    string newHash = PasswordHelper.HashPassword(newPwd);
                    using (var cmd = new SqlCommand(
                        "UPDATE dbo.[User] SET password = @newHash WHERE userId = @userId", conn))
                    {
                        cmd.Parameters.AddWithValue("@newHash", newHash);
                        cmd.Parameters.AddWithValue("@userId", _userId);
                        cmd.ExecuteNonQuery();
                    }
                }

                txtCurrentPwd.Text = "";
                txtNewPwd.Text = "";
                txtConfirmPwd.Text = "";
                ShowMsg(T("Password changed successfully!",
                    "Kata laluan berjaya ditukar!"), true);
            }
            catch
            {
                ShowMsg(T("An error occurred while changing password.",
                    "Ralat berlaku semasa menukar kata laluan."), false);
            }
        }

        // --- Feedback Message ---
        private void ShowMsg(string text, bool isSuccess)
        {
            pnlMessage.Visible = true;
            divMsg.InnerHtml = text;
            iMsgIcon.Attributes["class"] = isSuccess
                ? "bi bi-check-circle-fill"
                : "bi bi-exclamation-circle-fill";
        }

        protected void BtnCloseMsg_Click(object sender, EventArgs e)
        {
            pnlMessage.Visible = false;
        }

        // --- Report a Problem ---

        private static readonly string[] AllowedCategoryKeys = {
            "Account", "ChildLinking", "StudyPlan",
            "QuizProgress", "TeacherChat", "Forum",
            "Technical", "Other"
        };

        protected void BtnReportSubmit_Click(object sender, EventArgs e)
        {
            pnlReportSuccess.Visible = false;
            pnlReportError.Visible = false;

            string categoryKey = ddlReportCategory.SelectedValue;
            string categoryLabel = ddlReportCategory.SelectedItem != null
                ? ddlReportCategory.SelectedItem.Text
                : "";
            string subject = txtReportSubject.Text.Trim();
            string message = txtReportMessage.Text.Trim();

            if (string.IsNullOrEmpty(categoryKey) ||
                Array.IndexOf(AllowedCategoryKeys, categoryKey) < 0)
            {
                ShowReportError(T("Please select an issue category.", "Sila pilih kategori isu."));
                return;
            }

            if (string.IsNullOrEmpty(subject))
            {
                ShowReportError(T("Please enter a subject.", "Sila masukkan subjek."));
                return;
            }
            if (subject.Length > 100)
            {
                ShowReportError(T("Subject must not exceed 100 characters.",
                    "Subjek tidak boleh melebihi 100 aksara."));
                return;
            }

            if (string.IsNullOrEmpty(message))
            {
                ShowReportError(T("Please enter a message.", "Sila masukkan mesej."));
                return;
            }
            if (message.Length > 1000)
            {
                ShowReportError(T("Message must not exceed 1000 characters.",
                    "Mesej tidak boleh melebihi 1000 aksara."));
                return;
            }

            // Get parent contact info for the email
            string parentName = "";
            string parentEmail = "";
            try
            {
                const string sql = @"SELECT p.name, u.email 
                    FROM dbo.[Parent] p 
                    INNER JOIN dbo.[User] u ON p.userId = u.userId 
                    WHERE p.parentId = @parentId";

                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@parentId", _parentId);
                    conn.Open();

                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            parentName = reader["name"] != DBNull.Value ? reader["name"].ToString() : "";
                            parentEmail = reader["email"] != DBNull.Value ? reader["email"].ToString() : "";
                        }
                    }
                }
            }
            catch { }

            // Prevent email header injection
            subject = subject.Replace("\r", "").Replace("\n", "");

            bool sent = SendEmail(categoryLabel, subject, message, parentName, parentEmail);

            if (sent)
            {
                ddlReportCategory.SelectedIndex = 0;
                txtReportSubject.Text = "";
                txtReportMessage.Text = "";
                pnlReportSuccess.Visible = true;
                litReportStatus.Text = T("Your report has been sent to the admin.",
                    "Laporan anda telah dihantar kepada pentadbir.");
            }
        }

        private bool SendEmail(string categoryText, string subject, string message,
            string parentName, string parentEmail)
        {
            try
            {
                string smtpHost = ConfigurationManager.AppSettings["SmtpHost"] ?? "smtp.gmail.com";
                int smtpPort = int.Parse(ConfigurationManager.AppSettings["SmtpPort"] ?? "587");
                string smtpUser = ConfigurationManager.AppSettings["SmtpUsername"] ?? "";
                string smtpPass = ConfigurationManager.AppSettings["SmtpPassword"] ?? "";
                bool smtpSsl = bool.Parse(ConfigurationManager.AppSettings["SmtpEnableSsl"] ?? "true");
                string recipient = ConfigurationManager.AppSettings["ContactRecipientEmail"]
                    ?? "najihahazmi26@gmail.com";

                if (string.IsNullOrEmpty(smtpUser) || string.IsNullOrEmpty(smtpPass))
                {
                    ShowReportError(T("Email service is not configured. Please try again later.",
                        "Perkhidmatan e-mel tidak dikonfigurasikan. Sila cuba lagi kemudian."));
                    return false;
                }

                string emailSubject = "[ScienceBuddy Parent Report] " + categoryText + " - " + subject;
                string emailBody = string.Format(
                    "Parent Name: {0}\nParent userId: {1}\nParent Email: {2}\nCategory: {3}\nSubject: {4}\n\nMessage:\n{5}\n\nDate/Time: {6}",
                    parentName, _userId, parentEmail, categoryText, subject, message,
                    DateTime.Now.ToString("dd MMM yyyy HH:mm:ss"));

                using (var mail = new MailMessage())
                {
                    mail.From = new MailAddress(smtpUser, "ScienceBuddy Parent Report");
                    mail.To.Add(recipient);

                    if (!string.IsNullOrEmpty(parentEmail))
                    {
                        mail.ReplyToList.Add(new MailAddress(parentEmail, parentName));
                    }

                    mail.Subject = emailSubject;
                    mail.Body = emailBody;
                    mail.IsBodyHtml = false;

                    using (var smtp = new SmtpClient(smtpHost, smtpPort))
                    {
                        smtp.Credentials = new NetworkCredential(smtpUser, smtpPass);
                        smtp.EnableSsl = smtpSsl;
                        smtp.Send(mail);
                    }
                }

                return true;
            }
            catch
            {
                ShowReportError(T("Unable to send your report right now. Please try again later.",
                    "Tidak dapat menghantar laporan anda sekarang. Sila cuba lagi kemudian."));
                return false;
            }
        }

        private void ShowReportError(string text)
        {
            pnlReportError.Visible = true;
            litReportError.Text = text;
        }

        // --- Soft Delete Account ---

        protected void BtnDeleteAccount_Click(object sender, EventArgs e)
        {
            pnlDeleteError.Visible = false;

            if (!chkDeleteConfirm.Checked)
            {
                ShowDeleteError(T("Please tick the confirmation checkbox before deleting your account.",
                    "Sila tandakan kotak pengesahan sebelum memadam akaun anda."));
                return;
            }

            string reason = txtDeleteReason.Text.Trim();
            if (reason.Length > 300)
            {
                ShowDeleteError(T("Reason must not exceed 300 characters.",
                    "Sebab tidak boleh melebihi 300 aksara."));
                return;
            }
            if (string.IsNullOrEmpty(reason))
            {
                reason = "Parent requested account deletion.";
            }

            // Security: only use session userId, never from query string or form
            string sessUserId = Session["userId"] != null ? Session["userId"].ToString() : "";
            if (string.IsNullOrEmpty(sessUserId) ||
                Session["role"] == null ||
                Session["role"].ToString() != "Parent")
            {
                ShowDeleteError(T("Session expired. Please log in again.",
                    "Sesi tamat. Sila log masuk semula."));
                return;
            }

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    string status = CheckBeforeDelete(conn, sessUserId);
                    if (status == null)
                    {
                        return;
                    }

                    DoSoftDelete(conn, sessUserId, reason);
                }

                Session.Clear();
                Session.Abandon();
                Response.Redirect("~/Login.aspx?msg=accountDeleted", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch
            {
                ShowDeleteError(T("An error occurred. Please try again later.",
                    "Ralat berlaku. Sila cuba lagi kemudian."));
            }
        }

        private string CheckBeforeDelete(SqlConnection conn, string userId)
        {
            using (var cmd = new SqlCommand(
                "SELECT status FROM dbo.[User] WHERE userId = @userId AND role = 'Parent'",
                conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                object result = cmd.ExecuteScalar();

                if (result == null || result == DBNull.Value)
                {
                    ShowDeleteError(T("Account not found.", "Akaun tidak dijumpai."));
                    return null;
                }

                string currentStatus = result.ToString();
                if (currentStatus == "Deleted")
                {
                    ShowDeleteError(T("This account has already been marked as deleted.",
                        "Akaun ini telah ditandakan sebagai dipadam."));
                    return null;
                }

                return currentStatus;
            }
        }

        private void DoSoftDelete(SqlConnection conn, string userId, string reason)
        {
            using (var transaction = conn.BeginTransaction())
            {
                try
                {
                    using (var cmd = new SqlCommand(
                        "UPDATE dbo.[User] SET [status] = N'Deleted' WHERE userId = @userId AND [role] = N'Parent'",
                        conn, transaction))
                    {
                        cmd.Parameters.AddWithValue("@userId", userId);
                        cmd.ExecuteNonQuery();
                    }

                    string actionId = GenActionId(conn, transaction);
                    using (var cmd = new SqlCommand(
                        @"INSERT INTO dbo.[UserStatusAction]([actionId],[userId],[actionType],[reason],[actionDate],[performedBy])
                          VALUES(@actionId, @userId, N'Deleted', @reason, @actionDate, @performedBy)",
                        conn, transaction))
                    {
                        cmd.Parameters.AddWithValue("@actionId", actionId);
                        cmd.Parameters.AddWithValue("@userId", userId);
                        cmd.Parameters.AddWithValue("@reason", reason);
                        cmd.Parameters.AddWithValue("@actionDate", DateTime.Now);
                        cmd.Parameters.AddWithValue("@performedBy", userId);
                        cmd.ExecuteNonQuery();
                    }

                    transaction.Commit();
                }
                catch
                {
                    transaction.Rollback();
                    throw;
                }
            }
        }

        // Handles both "USA" prefix (current) and legacy "US" prefix
        private string GenActionId(SqlConnection conn, SqlTransaction transaction)
        {
            int next = 1;

            using (var cmd = new SqlCommand(
                "SELECT MAX(actionId) FROM dbo.[UserStatusAction]", conn, transaction))
            {
                object result = cmd.ExecuteScalar();

                if (result != null && result != DBNull.Value)
                {
                    string lastId = result.ToString();

                    if (lastId.StartsWith("USA") && lastId.Length > 3)
                    {
                        int num;
                        if (int.TryParse(lastId.Substring(3), out num))
                        {
                            next = num + 1;
                        }
                    }
                    else if (lastId.StartsWith("US") && lastId.Length > 2)
                    {
                        int num;
                        if (int.TryParse(lastId.Substring(2), out num))
                        {
                            next = num + 1;
                        }
                    }
                }
            }

            return "USA" + next.ToString("D3");
        }

        private void ShowDeleteError(string text)
        {
            pnlDeleteError.Visible = true;
            litDeleteError.Text = text;
        }

        // --- Notification Badge ---
        private void LoadUnreadBadge()
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(
                    "SELECT COUNT(*) FROM dbo.Notification WHERE toUserId = @userId AND isRead = 0",
                    conn))
                {
                    cmd.Parameters.AddWithValue("@userId", Session["userId"].ToString());
                    conn.Open();
                    int count = (int)cmd.ExecuteScalar();

                    litUnreadBadge.Text = count > 0
                        ? "<span class='pt-sidebar-badge'>" + count + "</span>"
                        : "";
                }
            }
            catch { }
        }
    }
}
