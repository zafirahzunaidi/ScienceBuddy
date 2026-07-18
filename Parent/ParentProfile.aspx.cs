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
        private string DatabaseConnectionString =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected string CurrentLanguage = "EN";

        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        private string _authenticatedUserId = "";
        private string _parentRecordId = "";

        // ══════════════════════════════════════════════════════════════
        //  PAGE LIFECYCLE
        // ══════════════════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!ValidateParentSession())
            {
                return;
            }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            LoadLanguagePreference();
            LoadUnreadNotificationBadge();
            _authenticatedUserId = Session["userId"].ToString();
            ResolveParentRecordId();

            if (!IsPostBack)
            {
                ApplyPageLabels();
                PopulateSidebarChildren();
                LoadProfileData();
            }
            else
            {
                ApplyPageLabels();
            }
        }

        /// <summary>
        /// Validates that the current session belongs to an authenticated parent.
        /// Redirects to login if session is missing or role mismatch.
        /// </summary>
        private bool ValidateParentSession()
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

        private void LoadLanguagePreference()
        {
            string cachedLanguage = Session["preferredLanguage"] as string;
            if (!string.IsNullOrEmpty(cachedLanguage))
            {
                CurrentLanguage = cachedLanguage;
                return;
            }

            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(
                    "SELECT preferredLanguage FROM dbo.[User] WHERE userId = @userId", connection))
                {
                    command.Parameters.AddWithValue("@userId", Session["userId"].ToString());
                    connection.Open();
                    object result = command.ExecuteScalar();

                    if (result != null && result != DBNull.Value)
                    {
                        CurrentLanguage = result.ToString();
                        Session["preferredLanguage"] = CurrentLanguage;
                    }
                }
            }
            catch { }
        }

        private void ResolveParentRecordId()
        {
            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(
                    "SELECT parentId FROM dbo.[Parent] WHERE userId = @userId", connection))
                {
                    command.Parameters.AddWithValue("@userId", _authenticatedUserId);
                    connection.Open();
                    object result = command.ExecuteScalar();

                    if (result != null)
                    {
                        _parentRecordId = result.ToString();
                    }
                }
            }
            catch { }
        }

        // ══════════════════════════════════════════════════════════════
        //  SIDEBAR CHILDREN DROPDOWN
        // ══════════════════════════════════════════════════════════════
        private void PopulateSidebarChildren()
        {
            ddlSidebarChild.Items.Clear();

            try
            {
                const string childQuery = @"SELECT s.studentId, ISNULL(s.nickname, s.name) AS displayName 
                    FROM dbo.StudentParent sp 
                    INNER JOIN dbo.Student s ON sp.studentId = s.studentId 
                    WHERE sp.parentId = @parentId ORDER BY s.name";

                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(childQuery, connection))
                {
                    command.Parameters.AddWithValue("@parentId", _parentRecordId);
                    connection.Open();

                    using (var reader = command.ExecuteReader())
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

        // ══════════════════════════════════════════════════════════════
        //  PAGE LABELS & REPORT CATEGORY DROPDOWN
        // ══════════════════════════════════════════════════════════════
        private void ApplyPageLabels()
        {
            btnSave.Text = T("Save Profile Changes", "Simpan Perubahan Profil");
            btnChangePwd.Text = T("Change Password", "Tukar Kata Laluan");
            btnReportSubmit.Text = T("Submit Report", "Hantar Laporan");
            btnDeleteAccount.Text = T("Confirm Close Account", "Sahkan Tutup Akaun");
            PopulateReportCategoryDropdown();
        }

        /// <summary>
        /// Populates the issue category dropdown with translated display text
        /// while keeping stable internal values for validation and email.
        /// </summary>
        private void PopulateReportCategoryDropdown()
        {
            string previouslySelected = ddlReportCategory.SelectedValue;
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

            // Restore selection on postback so dropdown doesn't reset
            if (!string.IsNullOrEmpty(previouslySelected) &&
                ddlReportCategory.Items.FindByValue(previouslySelected) != null)
            {
                ddlReportCategory.SelectedValue = previouslySelected;
            }
        }

        // ══════════════════════════════════════════════════════════════
        //  LOAD PROFILE DATA
        // ══════════════════════════════════════════════════════════════
        private void LoadProfileData()
        {
            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                {
                    connection.Open();

                    // User account details
                    string username = "", email = "", accountRole = "";
                    string accountStatus = "", languagePref = "";

                    using (var command = new SqlCommand(
                        "SELECT username, email, role, status, preferredLanguage FROM dbo.[User] WHERE userId = @userId",
                        connection))
                    {
                        command.Parameters.AddWithValue("@userId", _authenticatedUserId);

                        using (var reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                username = reader["username"] != DBNull.Value ? reader["username"].ToString() : "";
                                email = reader["email"] != DBNull.Value ? reader["email"].ToString() : "";
                                accountRole = reader["role"] != DBNull.Value ? reader["role"].ToString() : "";
                                accountStatus = reader["status"] != DBNull.Value ? reader["status"].ToString() : "";
                                languagePref = reader["preferredLanguage"] != DBNull.Value ? reader["preferredLanguage"].ToString() : "EN";
                            }
                        }
                    }

                    // Parent personal details
                    string parentFullName = "";
                    string parentPhone = "";

                    using (var command = new SqlCommand(
                        "SELECT name, phoneNumber FROM dbo.[Parent] WHERE parentId = @parentId", connection))
                    {
                        command.Parameters.AddWithValue("@parentId", _parentRecordId);

                        using (var reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                parentFullName = reader["name"] != DBNull.Value ? reader["name"].ToString() : "";
                                parentPhone = reader["phoneNumber"] != DBNull.Value ? reader["phoneNumber"].ToString() : "";
                            }
                        }
                    }

                    // Linked children count for the hero card
                    int linkedChildCount = 0;
                    using (var command = new SqlCommand(
                        "SELECT COUNT(*) FROM dbo.StudentParent WHERE parentId = @parentId", connection))
                    {
                        command.Parameters.AddWithValue("@parentId", _parentRecordId);
                        linkedChildCount = (int)command.ExecuteScalar();
                    }

                    // Populate form fields
                    txtUsername.Text = username;
                    txtName.Text = parentFullName;
                    txtEmail.Text = email;
                    txtPhone.Text = parentPhone;

                    if (ddlLang.Items.FindByValue(languagePref) != null)
                    {
                        ddlLang.SelectedValue = languagePref;
                    }

                    // Hero section
                    litHeroName.Text = Server.HtmlEncode(parentFullName);
                    litInitials.Text = BuildNameInitials(parentFullName);
                    litHeroEmail.Text = Server.HtmlEncode(email);
                    litChildrenCount.Text = string.Format(
                        T("{0} child(ren) linked", "{0} anak dipautkan"), linkedChildCount);

                    // Account status chips
                    litStatusRole.Text = accountRole;
                    litStatusStatus.Text = accountStatus;
                    litStatusLang.Text = languagePref == "BM" ? "Bahasa Melayu" : "English";
                }
            }
            catch { }
        }

        private string BuildNameInitials(string fullName)
        {
            if (string.IsNullOrEmpty(fullName))
            {
                return "P";
            }

            string[] nameParts = fullName.Trim().Split(' ');
            if (nameParts.Length >= 2)
            {
                return (nameParts[0][0].ToString() + nameParts[nameParts.Length - 1][0].ToString()).ToUpper();
            }

            return nameParts[0][0].ToString().ToUpper();
        }

        // ══════════════════════════════════════════════════════════════
        //  SAVE PROFILE CHANGES
        // ══════════════════════════════════════════════════════════════
        protected void BtnSave_Click(object sender, EventArgs e)
        {
            string updatedName = txtName.Text.Trim();
            string updatedEmail = txtEmail.Text.Trim();
            string updatedPhone = txtPhone.Text.Trim();
            string selectedLanguage = ddlLang.SelectedValue;

            if (string.IsNullOrEmpty(updatedName))
            {
                ShowFeedbackMessage(T("Name cannot be empty.", "Nama tidak boleh kosong."), false);
                return;
            }
            if (string.IsNullOrEmpty(updatedEmail))
            {
                ShowFeedbackMessage(T("Email cannot be empty.", "E-mel tidak boleh kosong."), false);
                return;
            }

            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                {
                    connection.Open();

                    // Update parent personal info
                    using (var command = new SqlCommand(
                        "UPDATE dbo.[Parent] SET name = @name, phoneNumber = @phone WHERE parentId = @parentId",
                        connection))
                    {
                        command.Parameters.AddWithValue("@name", updatedName);
                        command.Parameters.AddWithValue("@phone", (object)updatedPhone ?? DBNull.Value);
                        command.Parameters.AddWithValue("@parentId", _parentRecordId);
                        command.ExecuteNonQuery();
                    }

                    // Update user account settings (email + language preference)
                    using (var command = new SqlCommand(
                        "UPDATE dbo.[User] SET email = @email, preferredLanguage = @lang WHERE userId = @userId",
                        connection))
                    {
                        command.Parameters.AddWithValue("@email", updatedEmail);
                        command.Parameters.AddWithValue("@lang", selectedLanguage);
                        command.Parameters.AddWithValue("@userId", _authenticatedUserId);
                        command.ExecuteNonQuery();
                    }
                }

                // Apply language change immediately
                Session["preferredLanguage"] = selectedLanguage;
                CurrentLanguage = selectedLanguage;

                ShowFeedbackMessage(T("Profile updated successfully!", "Profil berjaya dikemas kini!"), true);
                LoadProfileData();
            }
            catch
            {
                ShowFeedbackMessage(T("An error occurred while saving.", "Ralat berlaku semasa menyimpan."), false);
            }
        }

        // ══════════════════════════════════════════════════════════════
        //  CHANGE PASSWORD
        // ══════════════════════════════════════════════════════════════
        protected void BtnChangePwd_Click(object sender, EventArgs e)
        {
            string currentPassword = txtCurrentPwd.Text;
            string newPassword = txtNewPwd.Text;
            string confirmPassword = txtConfirmPwd.Text;

            // Validation: all fields required, minimum length, match check
            if (string.IsNullOrEmpty(currentPassword))
            {
                ShowFeedbackMessage(T("Please enter your current password.",
                    "Sila masukkan kata laluan semasa anda."), false);
                return;
            }
            if (string.IsNullOrEmpty(newPassword))
            {
                ShowFeedbackMessage(T("Please enter a new password.",
                    "Sila masukkan kata laluan baharu."), false);
                return;
            }
            if (newPassword.Length < 6)
            {
                ShowFeedbackMessage(T("New password must be at least 6 characters.",
                    "Kata laluan baharu mesti sekurang-kurangnya 6 aksara."), false);
                return;
            }
            if (newPassword != confirmPassword)
            {
                ShowFeedbackMessage(T("New passwords do not match.",
                    "Kata laluan baharu tidak sepadan."), false);
                return;
            }

            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                {
                    connection.Open();

                    // Retrieve the stored hash for BCrypt verification
                    string storedPasswordHash = "";
                    using (var command = new SqlCommand(
                        "SELECT password FROM dbo.[User] WHERE userId = @userId", connection))
                    {
                        command.Parameters.AddWithValue("@userId", _authenticatedUserId);
                        object result = command.ExecuteScalar();

                        if (result != null && result != DBNull.Value)
                        {
                            storedPasswordHash = result.ToString();
                        }
                    }

                    // Verify current password matches before allowing change
                    if (!PasswordHelper.VerifyPassword(currentPassword, storedPasswordHash))
                    {
                        ShowFeedbackMessage(T("Current password is incorrect.",
                            "Kata laluan semasa tidak betul."), false);
                        return;
                    }

                    // Hash the new password and persist it
                    string newPasswordHash = PasswordHelper.HashPassword(newPassword);
                    using (var command = new SqlCommand(
                        "UPDATE dbo.[User] SET password = @newHash WHERE userId = @userId", connection))
                    {
                        command.Parameters.AddWithValue("@newHash", newPasswordHash);
                        command.Parameters.AddWithValue("@userId", _authenticatedUserId);
                        command.ExecuteNonQuery();
                    }
                }

                // Clear the password fields after successful change
                txtCurrentPwd.Text = "";
                txtNewPwd.Text = "";
                txtConfirmPwd.Text = "";
                ShowFeedbackMessage(T("Password changed successfully!",
                    "Kata laluan berjaya ditukar!"), true);
            }
            catch
            {
                ShowFeedbackMessage(T("An error occurred while changing password.",
                    "Ralat berlaku semasa menukar kata laluan."), false);
            }
        }

        // ══════════════════════════════════════════════════════════════
        //  FEEDBACK MESSAGE POPUP
        // ══════════════════════════════════════════════════════════════
        private void ShowFeedbackMessage(string messageText, bool isSuccess)
        {
            pnlMessage.Visible = true;
            divMsg.InnerHtml = messageText;
            iMsgIcon.Attributes["class"] = isSuccess
                ? "bi bi-check-circle-fill"
                : "bi bi-exclamation-circle-fill";
        }

        protected void BtnCloseMsg_Click(object sender, EventArgs e)
        {
            pnlMessage.Visible = false;
        }

        // ══════════════════════════════════════════════════════════════
        //  REPORT A PROBLEM (email to admin)
        // ══════════════════════════════════════════════════════════════

        private static readonly string[] AllowedCategoryKeys = {
            "Account", "ChildLinking", "StudyPlan",
            "QuizProgress", "TeacherChat", "Forum",
            "Technical", "Other"
        };

        protected void BtnReportSubmit_Click(object sender, EventArgs e)
        {
            pnlReportSuccess.Visible = false;
            pnlReportError.Visible = false;

            string selectedCategoryKey = ddlReportCategory.SelectedValue;
            string categoryLabel = ddlReportCategory.SelectedItem != null
                ? ddlReportCategory.SelectedItem.Text
                : "";
            string reportSubject = txtReportSubject.Text.Trim();
            string reportMessage = txtReportMessage.Text.Trim();

            // Validate the category is one of the allowed internal keys
            if (string.IsNullOrEmpty(selectedCategoryKey) ||
                Array.IndexOf(AllowedCategoryKeys, selectedCategoryKey) < 0)
            {
                ShowReportError(T("Please select an issue category.", "Sila pilih kategori isu."));
                return;
            }

            if (string.IsNullOrEmpty(reportSubject))
            {
                ShowReportError(T("Please enter a subject.", "Sila masukkan subjek."));
                return;
            }
            if (reportSubject.Length > 100)
            {
                ShowReportError(T("Subject must not exceed 100 characters.",
                    "Subjek tidak boleh melebihi 100 aksara."));
                return;
            }

            if (string.IsNullOrEmpty(reportMessage))
            {
                ShowReportError(T("Please enter a message.", "Sila masukkan mesej."));
                return;
            }
            if (reportMessage.Length > 1000)
            {
                ShowReportError(T("Message must not exceed 1000 characters.",
                    "Mesej tidak boleh melebihi 1000 aksara."));
                return;
            }

            // Fetch parent name and email for the report body
            string parentFullName = "";
            string parentEmailAddress = "";
            FetchParentContactDetails(out parentFullName, out parentEmailAddress);

            // Sanitize subject to prevent email header injection
            reportSubject = reportSubject.Replace("\r", "").Replace("\n", "");

            // Send the report via SMTP
            bool emailSent = SendReportEmail(categoryLabel, reportSubject, reportMessage,
                parentFullName, parentEmailAddress);

            if (emailSent)
            {
                ddlReportCategory.SelectedIndex = 0;
                txtReportSubject.Text = "";
                txtReportMessage.Text = "";
                pnlReportSuccess.Visible = true;
                litReportStatus.Text = T("Your report has been sent to the admin.",
                    "Laporan anda telah dihantar kepada pentadbir.");
            }
        }

        private void FetchParentContactDetails(out string name, out string email)
        {
            name = "";
            email = "";

            try
            {
                const string contactQuery = @"SELECT p.name, u.email 
                    FROM dbo.[Parent] p 
                    INNER JOIN dbo.[User] u ON p.userId = u.userId 
                    WHERE p.parentId = @parentId";

                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(contactQuery, connection))
                {
                    command.Parameters.AddWithValue("@parentId", _parentRecordId);
                    connection.Open();

                    using (var reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            name = reader["name"] != DBNull.Value ? reader["name"].ToString() : "";
                            email = reader["email"] != DBNull.Value ? reader["email"].ToString() : "";
                        }
                    }
                }
            }
            catch { }
        }

        /// <summary>
        /// Sends the problem report email using the same SMTP configuration
        /// as the public Contact page. Returns true on success.
        /// </summary>
        private bool SendReportEmail(string categoryText, string subject, string message,
            string parentName, string parentEmail)
        {
            try
            {
                string smtpHost = ConfigurationManager.AppSettings["SmtpHost"] ?? "smtp.gmail.com";
                int smtpPort = int.Parse(ConfigurationManager.AppSettings["SmtpPort"] ?? "587");
                string smtpUser = ConfigurationManager.AppSettings["SmtpUsername"] ?? "";
                string smtpPass = ConfigurationManager.AppSettings["SmtpPassword"] ?? "";
                bool smtpSsl = bool.Parse(ConfigurationManager.AppSettings["SmtpEnableSsl"] ?? "true");
                string recipientAddress = ConfigurationManager.AppSettings["ContactRecipientEmail"]
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
                    parentName, _authenticatedUserId, parentEmail, categoryText, subject, message,
                    DateTime.Now.ToString("dd MMM yyyy HH:mm:ss"));

                using (var mailMessage = new MailMessage())
                {
                    mailMessage.From = new MailAddress(smtpUser, "ScienceBuddy Parent Report");
                    mailMessage.To.Add(recipientAddress);

                    if (!string.IsNullOrEmpty(parentEmail))
                    {
                        mailMessage.ReplyToList.Add(new MailAddress(parentEmail, parentName));
                    }

                    mailMessage.Subject = emailSubject;
                    mailMessage.Body = emailBody;
                    mailMessage.IsBodyHtml = false;

                    using (var smtpClient = new SmtpClient(smtpHost, smtpPort))
                    {
                        smtpClient.Credentials = new NetworkCredential(smtpUser, smtpPass);
                        smtpClient.EnableSsl = smtpSsl;
                        smtpClient.Send(mailMessage);
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

        private void ShowReportError(string errorText)
        {
            pnlReportError.Visible = true;
            litReportError.Text = errorText;
        }

        // ══════════════════════════════════════════════════════════════
        //  SOFT DELETE ACCOUNT (mark as Deleted, log action, end session)
        // ══════════════════════════════════════════════════════════════

        protected void BtnDeleteAccount_Click(object sender, EventArgs e)
        {
            pnlDeleteError.Visible = false;

            // Confirmation checkbox must be ticked
            if (!chkDeleteConfirm.Checked)
            {
                ShowDeleteError(T("Please tick the confirmation checkbox before deleting your account.",
                    "Sila tandakan kotak pengesahan sebelum memadam akaun anda."));
                return;
            }

            // Optional reason with length cap
            string deletionReason = txtDeleteReason.Text.Trim();
            if (deletionReason.Length > 300)
            {
                ShowDeleteError(T("Reason must not exceed 300 characters.",
                    "Sebab tidak boleh melebihi 300 aksara."));
                return;
            }
            if (string.IsNullOrEmpty(deletionReason))
            {
                deletionReason = "Parent requested account deletion.";
            }

            // Security: only use session userId, never from query string or form
            string sessionUserId = Session["userId"] != null ? Session["userId"].ToString() : "";
            if (string.IsNullOrEmpty(sessionUserId) ||
                Session["role"] == null ||
                Session["role"].ToString() != "Parent")
            {
                ShowDeleteError(T("Session expired. Please log in again.",
                    "Sesi tamat. Sila log masuk semula."));
                return;
            }

            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                {
                    connection.Open();

                    // Verify this account exists, is a parent, and is not already deleted
                    string existingStatus = VerifyAccountBeforeDeletion(connection, sessionUserId);
                    if (existingStatus == null)
                    {
                        return; // error already shown inside helper
                    }

                    // Execute soft delete in a transaction
                    PerformSoftDeleteTransaction(connection, sessionUserId, deletionReason);
                }

                // End session and redirect to login
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

        /// <summary>
        /// Checks that the parent account exists and is not already marked as Deleted.
        /// Returns the current status string, or null if validation fails.
        /// </summary>
        private string VerifyAccountBeforeDeletion(SqlConnection connection, string userId)
        {
            using (var command = new SqlCommand(
                "SELECT status FROM dbo.[User] WHERE userId = @userId AND role = 'Parent'",
                connection))
            {
                command.Parameters.AddWithValue("@userId", userId);
                object result = command.ExecuteScalar();

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

        /// <summary>
        /// Updates User.status to 'Deleted' and inserts a UserStatusAction log entry
        /// inside a single transaction to ensure atomicity.
        /// </summary>
        private void PerformSoftDeleteTransaction(SqlConnection connection,
            string userId, string reason)
        {
            using (var transaction = connection.BeginTransaction())
            {
                try
                {
                    // Mark account as Deleted
                    using (var command = new SqlCommand(
                        "UPDATE dbo.[User] SET [status] = N'Deleted' WHERE userId = @userId AND [role] = N'Parent'",
                        connection, transaction))
                    {
                        command.Parameters.AddWithValue("@userId", userId);
                        command.ExecuteNonQuery();
                    }

                    // Log this action in UserStatusAction table
                    string actionId = GenerateNextStatusActionId(connection, transaction);
                    using (var command = new SqlCommand(
                        @"INSERT INTO dbo.[UserStatusAction]([actionId],[userId],[actionType],[reason],[actionDate],[performedBy])
                          VALUES(@actionId, @userId, N'Deleted', @reason, @actionDate, @performedBy)",
                        connection, transaction))
                    {
                        command.Parameters.AddWithValue("@actionId", actionId);
                        command.Parameters.AddWithValue("@userId", userId);
                        command.Parameters.AddWithValue("@reason", reason);
                        command.Parameters.AddWithValue("@actionDate", DateTime.Now);
                        command.Parameters.AddWithValue("@performedBy", userId);
                        command.ExecuteNonQuery();
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

        /// <summary>
        /// Generates the next sequential actionId for UserStatusAction using the USA prefix.
        /// Handles both "USA" prefix (current standard) and legacy "US" prefix records.
        /// </summary>
        private string GenerateNextStatusActionId(SqlConnection connection, SqlTransaction transaction)
        {
            int nextSequenceNumber = 1;

            using (var command = new SqlCommand(
                "SELECT MAX(actionId) FROM dbo.[UserStatusAction]", connection, transaction))
            {
                object result = command.ExecuteScalar();

                if (result != null && result != DBNull.Value)
                {
                    string lastActionId = result.ToString();

                    if (lastActionId.StartsWith("USA") && lastActionId.Length > 3)
                    {
                        int numericPart;
                        if (int.TryParse(lastActionId.Substring(3), out numericPart))
                        {
                            nextSequenceNumber = numericPart + 1;
                        }
                    }
                    else if (lastActionId.StartsWith("US") && lastActionId.Length > 2)
                    {
                        // Fallback for legacy records with shorter "US" prefix
                        int numericPart;
                        if (int.TryParse(lastActionId.Substring(2), out numericPart))
                        {
                            nextSequenceNumber = numericPart + 1;
                        }
                    }
                }
            }

            return "USA" + nextSequenceNumber.ToString("D3");
        }

        private void ShowDeleteError(string errorText)
        {
            pnlDeleteError.Visible = true;
            litDeleteError.Text = errorText;
        }

        // ══════════════════════════════════════════════════════════════
        //  NOTIFICATION BADGE
        // ══════════════════════════════════════════════════════════════
        private void LoadUnreadNotificationBadge()
        {
            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(
                    "SELECT COUNT(*) FROM dbo.Notification WHERE toUserId = @userId AND isRead = 0",
                    connection))
                {
                    command.Parameters.AddWithValue("@userId", Session["userId"].ToString());
                    connection.Open();
                    int unreadCount = (int)command.ExecuteScalar();

                    litUnreadBadge.Text = unreadCount > 0
                        ? "<span class='pt-sidebar-badge'>" + unreadCount + "</span>"
                        : "";
                }
            }
            catch { }
        }
    }
}
