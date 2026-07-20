using System;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI;

namespace ScienceBuddy.Teacher
{
    public partial class MyProfile : Page
    {
        #region Properties

        protected global::System.Web.UI.WebControls.Literal litPermissions;
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl certIconDiv;
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl certIconI;

        protected string CurrentLanguage
        {
            get
            {
                string lang = Session["preferredLanguage"] as string;
                return string.IsNullOrEmpty(lang) ? "EN" : lang;
            }
        }

        protected bool IsCertified { get; set; }

        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        #endregion

        #region Localization

        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        #endregion

        #region Page Lifecycle

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"]?.ToString() != "Teacher")
            {
                Response.Redirect("~/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            // AJAX handlers — use Response.End() to prevent page rendering
            string handler = Request.QueryString["handler"];
            if (!string.IsNullOrEmpty(handler))
            {
                try
                {
                    if (handler == "savelang") HandleSaveLanguage();
                    else if (handler == "changepw") HandleChangePassword();
                    else if (handler == "deleteaccount") HandleDeleteAccount();
                    Response.End();
                }
                catch (System.Threading.ThreadAbortException) { /* Expected from Response.End */ }
                return;
            }

            var master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            if (!IsPostBack)
                LoadProfile();
        }

        #endregion

        #region Event Handlers

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string teacherName = txtName.Text.Trim();
            string phoneNumber = txtPhone.Text.Trim();
            string bio = txtBio.Text.Trim();

            if (!ValidateProfileInput(teacherName, phoneNumber, bio))
                return;

            string userId = Session["userId"].ToString();

            try
            {
                UpdateTeacherProfile(userId, teacherName, phoneNumber, bio);
                hidToast.Value = T("Profile updated successfully.", "Profil berjaya dikemas kini.");
                LoadProfile();
            }
            catch
            {
                hidToast.Value = T("An error occurred.", "Ralat berlaku.");
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Teacher/Dashboard.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        #endregion

        #region AJAX Handlers

        private void HandleSaveLanguage()
        {
            Response.Clear();
            Response.ContentType = "text/plain";

            string lang = (Request.QueryString["lang"] ?? "EN").Trim();
            if (lang != "EN" && lang != "BM") lang = "EN";

            Session["preferredLanguage"] = lang;

            try
            {
                string userId = Session["userId"]?.ToString() ?? "";
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("UPDATE dbo.[User] SET [preferredLanguage]=@l WHERE [userId]=@uid", conn))
                    {
                        cmd.Parameters.AddWithValue("@l", lang);
                        cmd.Parameters.AddWithValue("@uid", userId);
                        cmd.ExecuteNonQuery();
                    }
                }
                Response.Write("OK");
            }
            catch
            {
                Response.StatusCode = 500;
                Response.Write("Error");
            }
        }

        private void HandleChangePassword()
        {
            Response.Clear();
            Response.ContentType = "text/plain";

            string userId = Session["userId"]?.ToString() ?? "";
            string currentPassword = Request.Form["current"] ?? "";
            string newPassword = Request.Form["newpw"] ?? "";

            if (string.IsNullOrEmpty(currentPassword) || string.IsNullOrEmpty(newPassword) || newPassword.Length < 6)
            {
                Response.StatusCode = 400;
                Response.Write(T("Invalid input.", "Input tidak sah."));
                return;
            }

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // Verify current password
                    string storedHash = "";
                    using (var cmd = new SqlCommand("SELECT [password] FROM dbo.[User] WHERE [userId]=@uid", conn))
                    {
                        cmd.Parameters.AddWithValue("@uid", userId);
                        var result = cmd.ExecuteScalar();
                        storedHash = result?.ToString() ?? "";
                    }

                    if (string.IsNullOrEmpty(storedHash) || !PasswordHelper.VerifyPassword(currentPassword, storedHash))
                    {
                        Response.StatusCode = 400;
                        Response.Write(T("Current password is incorrect.", "Kata laluan semasa tidak betul."));
                        return;
                    }

                    // Update password with new hash
                    string newHash = PasswordHelper.HashPassword(newPassword);
                    using (var cmd2 = new SqlCommand("UPDATE dbo.[User] SET [password]=@pw WHERE [userId]=@uid", conn))
                    {
                        cmd2.Parameters.AddWithValue("@pw", newHash);
                        cmd2.Parameters.AddWithValue("@uid", userId);
                        cmd2.ExecuteNonQuery();
                    }

                    Response.Write("OK");
                }
            }
            catch (Exception ex)
            {
                if (!(ex is System.Threading.ThreadAbortException))
                {
                    Response.StatusCode = 500;
                    Response.Write(T("Error changing password.", "Ralat menukar kata laluan."));
                }
            }
        }

        private void HandleDeleteAccount()
        {
            Response.Clear();
            Response.ContentType = "text/plain";

            string userId = Session["userId"]?.ToString() ?? "";
            if (string.IsNullOrEmpty(userId))
            {
                Response.StatusCode = 400;
                Response.Write("Invalid session.");
                return;
            }

            string reason = Request.Form["reason"] ?? "";
            string detail = Request.Form["detail"] ?? "";
            string description = "Account deleted. Reason: " + BuildDeletionReasonText(reason, detail);

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var txn = conn.BeginTransaction())
                    {
                        try
                        {
                            // Mark user as deleted
                            using (var cmd = new SqlCommand("UPDATE dbo.[User] SET [status]='Deleted' WHERE [userId]=@uid", conn, txn))
                            {
                                cmd.Parameters.AddWithValue("@uid", userId);
                                cmd.ExecuteNonQuery();
                            }

                            // Generate next log ID and insert audit record
                            string logId;
                            using (var cmd2 = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING([logId],4,LEN([logId])-3) AS INT)),0) FROM dbo.[Log]", conn, txn))
                            {
                                logId = "LOG" + (Convert.ToInt32(cmd2.ExecuteScalar()) + 1).ToString("D3");
                            }

                            using (var cmd3 = new SqlCommand(@"INSERT INTO dbo.[Log]([logId],[userId],[action],[description],[logDateTime],[status])
                                VALUES(@id,@uid,@act,@desc,GETDATE(),'Success')", conn, txn))
                            {
                                cmd3.Parameters.AddWithValue("@id", logId);
                                cmd3.Parameters.AddWithValue("@uid", userId);
                                cmd3.Parameters.AddWithValue("@act", "Delete Account");
                                cmd3.Parameters.AddWithValue("@desc", description);
                                cmd3.ExecuteNonQuery();
                            }

                            txn.Commit();
                        }
                        catch
                        {
                            txn.Rollback();
                            throw;
                        }
                    }
                }

                Session.Clear();
                Session.Abandon();
                Response.Write("OK");
            }
            catch
            {
                Response.StatusCode = 500;
                Response.Write(T("Error deleting account.", "Ralat memadam akaun."));
            }
        }

        #endregion

        #region Data Loading

        private void LoadProfile()
        {
            string userId = Session["userId"].ToString();

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                const string sql = @"SELECT [teacherId],[name],[phoneNumber],[academicQualification],[bio],[licenseCert],[status],[approvedDate]
                    FROM dbo.[Teacher] WHERE [userId]=@uid";

                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);

                    using (var reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read()) return;

                        string teacherName = reader["name"]?.ToString() ?? "";
                        string teacherId = reader["teacherId"]?.ToString() ?? "";
                        string phoneNumber = reader["phoneNumber"]?.ToString() ?? "";
                        string qualification = reader["academicQualification"]?.ToString() ?? "";
                        string bio = reader["bio"]?.ToString() ?? "";
                        string licenseCert = reader["licenseCert"]?.ToString() ?? "";
                        string licenseStatus = reader["status"]?.ToString() ?? "";

                        IsCertified = licenseStatus.Equals("Certified", StringComparison.OrdinalIgnoreCase);
                        bool isPending = licenseStatus.Equals("Pending", StringComparison.OrdinalIgnoreCase);
                        bool isRejected = licenseStatus.Equals("Not Certified", StringComparison.OrdinalIgnoreCase)
                                       || licenseStatus.Equals("Rejected", StringComparison.OrdinalIgnoreCase);

                        SetVerificationPanelVisibility(IsCertified, isPending, isRejected);
                        RenderPermissions(IsCertified);
                        PopulateHeroSection(teacherName, teacherId, IsCertified, isPending, isRejected);
                        PopulatePersonalInfo(teacherName, teacherId, phoneNumber, qualification, bio);
                        PopulateCertificateSection(licenseCert, reader["approvedDate"]);
                        PopulateProfileCompletion(phoneNumber, qualification, bio, licenseCert, licenseStatus);

                        btnSave.Text = T("Save Changes", "Simpan Perubahan");
                        btnCancel.Text = T("Cancel", "Batal");
                    }
                }
            }
        }

        #endregion

        #region Database Operations

        private void UpdateTeacherProfile(string userId, string name, string phone, string bio)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                const string sql = "UPDATE dbo.[Teacher] SET [name]=@n,[phoneNumber]=@p,[bio]=@b WHERE [userId]=@uid";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@n", name);
                    cmd.Parameters.AddWithValue("@p", phone);
                    cmd.Parameters.AddWithValue("@b", (object)bio ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@uid", userId);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        #endregion

        #region Helper Methods

        /// <summary>
        /// Validates profile form input fields. Sets hidToast with error message on failure.
        /// </summary>
        private bool ValidateProfileInput(string name, string phone, string bio)
        {
            if (string.IsNullOrEmpty(name))
            { hidToast.Value = T("Full Name is required.", "Nama Penuh diperlukan."); return false; }

            if (name.Length > 100)
            { hidToast.Value = T("Full Name cannot exceed 100 characters.", "Nama Penuh tidak boleh melebihi 100 aksara."); return false; }

            if (string.IsNullOrEmpty(phone))
            { hidToast.Value = T("Phone number is required.", "Nombor telefon diperlukan."); return false; }

            foreach (char c in phone)
            {
                if (!char.IsDigit(c))
                { hidToast.Value = T("Phone number must contain digits only.", "Nombor telefon mesti mengandungi digit sahaja."); return false; }
            }

            if (bio.Length > 500)
            { hidToast.Value = T("Bio cannot exceed 500 characters.", "Biografi tidak boleh melebihi 500 aksara."); return false; }

            return true;
        }

        private void SetVerificationPanelVisibility(bool isCertified, bool isPending, bool isRejected)
        {
            if (isCertified) pnlVerCertified.Visible = true;
            else if (isPending) pnlVerPending.Visible = true;
            else if (isRejected) pnlVerRejected.Visible = true;
            else pnlVerUnknown.Visible = true;
        }

        private void PopulateHeroSection(string teacherName, string teacherId, bool isCertified, bool isPending, bool isRejected)
        {
            // Avatar initials
            string initials = "T";
            var nameParts = teacherName.Trim().Split(' ');
            if (nameParts.Length >= 2)
                initials = (nameParts[0][0].ToString() + nameParts[nameParts.Length - 1][0].ToString()).ToUpper();
            else if (teacherName.Length > 0)
                initials = teacherName[0].ToString().ToUpper();

            litInitials.Text = HttpUtility.HtmlEncode(initials);
            litName.Text = HttpUtility.HtmlEncode(teacherName);
            litTeacherId.Text = HttpUtility.HtmlEncode(teacherId);
            litMemberId.Text = HttpUtility.HtmlEncode(teacherId);

            // Status badge styling
            string badgeCss = "tc-my-profile-badge-grey";
            string statusLabel = T("Status Unavailable", "Status Tidak Tersedia");
            string profileStatusText = T("Active", "Aktif");

            if (isCertified)
            {
                badgeCss = "tc-my-profile-badge-green";
                statusLabel = T("Verified Educator", "Pendidik Disahkan");
                profileStatusText = T("Verified", "Disahkan");
                pnlAvatarVerified.Visible = true;
            }
            else if (isPending)
            {
                badgeCss = "tc-my-profile-badge-orange";
                statusLabel = T("Unverified Teacher", "Guru Belum Disahkan");
                profileStatusText = T("Pending", "Menunggu");
            }
            else if (isRejected)
            {
                badgeCss = "tc-my-profile-badge-red";
                statusLabel = T("Verification Rejected", "Pengesahan Ditolak");
                profileStatusText = T("Rejected", "Ditolak");
            }

            litStatusBadge.Text = "<span class='tc-my-profile-badge " + badgeCss + "'><i class='bi bi-patch-check-fill' style='font-size:.7rem;'></i> "
                + HttpUtility.HtmlEncode(statusLabel) + "</span>";
            litProfileStatus.Text = HttpUtility.HtmlEncode(profileStatusText);
        }

        private void PopulatePersonalInfo(string teacherName, string teacherId, string phone, string qualification, string bio)
        {
            txtName.Text = teacherName;
            litTID.Text = HttpUtility.HtmlEncode(teacherId);
            litQual.Text = string.IsNullOrEmpty(qualification) ? "—" : HttpUtility.HtmlEncode(qualification);
            txtPhone.Text = phone;
            txtBio.Text = bio;
            txtBio.Attributes["placeholder"] = T("Tell students about yourself...", "Ceritakan tentang diri anda kepada pelajar...");
        }

        private void PopulateCertificateSection(string licenseCert, object approvedDateValue)
        {
            if (!string.IsNullOrEmpty(licenseCert))
            {
                pnlCertExists.Visible = true;
                litCertName.Text = HttpUtility.HtmlEncode(Path.GetFileName(licenseCert));
                lnkCert.HRef = ResolveUrl("~/") + licenseCert;

                SetCertificateIcon(Path.GetExtension(licenseCert).ToLowerInvariant());

                if (approvedDateValue != null && approvedDateValue != DBNull.Value)
                {
                    pnlApprovedDate.Visible = true;
                    litApprovedDate.Text = Convert.ToDateTime(approvedDateValue).ToString("d MMM yyyy");
                }
            }
            else
            {
                pnlCertEmpty.Visible = true;
            }
        }

        private void SetCertificateIcon(string extension)
        {
            string iconClass = "bi bi-file-earmark-fill";
            string iconCssClass = "tc-my-profile-cert-icon other";

            if (extension == ".pdf")
            {
                iconClass = "bi bi-file-earmark-pdf-fill";
                iconCssClass = "tc-my-profile-cert-icon pdf";
            }
            else if (extension == ".png" || extension == ".jpg" || extension == ".jpeg" || extension == ".gif" || extension == ".webp")
            {
                iconClass = "bi bi-file-earmark-image-fill";
                iconCssClass = "tc-my-profile-cert-icon img";
            }
            else if (extension == ".doc" || extension == ".docx")
            {
                iconClass = "bi bi-file-earmark-word-fill";
                iconCssClass = "tc-my-profile-cert-icon doc";
            }
            else if (extension == ".ppt" || extension == ".pptx")
            {
                iconClass = "bi bi-file-earmark-ppt-fill";
                iconCssClass = "tc-my-profile-cert-icon ppt";
            }

            certIconDiv.Attributes["class"] = iconCssClass;
            certIconI.Attributes["class"] = iconClass;
        }

        private void PopulateProfileCompletion(string phone, string qualification, string bio, string licenseCert, string status)
        {
            int filledFields = 0;
            const int totalFields = 5;

            if (!string.IsNullOrEmpty(phone)) filledFields++;
            if (!string.IsNullOrEmpty(qualification)) filledFields++;
            if (!string.IsNullOrEmpty(bio)) filledFields++;
            if (!string.IsNullOrEmpty(licenseCert)) filledFields++;
            if (!string.IsNullOrEmpty(status)) filledFields++;

            int completionPercent = (int)Math.Round((double)filledFields / totalFields * 100);

            if (litPct != null)
                litPct.Text = completionPercent.ToString();

            if (litProgressMsg != null)
            {
                litProgressMsg.Text = completionPercent >= 80
                    ? T("Your profile looks great!", "Profil anda kelihatan hebat!")
                    : T("Complete your profile for a better experience.", "Lengkapkan profil anda untuk pengalaman yang lebih baik.");
            }
        }

        private void RenderPermissions(bool isApproved)
        {
            var sb = new StringBuilder();
            sb.Append("<ul class=\"tc-my-profile-perm-list\">");

            if (isApproved)
            {
                AppendPermissionItem(sb, true, T("Upload Learning Materials", "Muat Naik Bahan Pembelajaran"));
                AppendPermissionItem(sb, true, T("Create Quizzes", "Cipta Kuiz"));
                AppendPermissionItem(sb, true, T("View Student Progress", "Lihat Prestasi Pelajar"));
                AppendPermissionItem(sb, true, T("Conduct Live Sessions", "Jalankan Sesi Langsung"));
                AppendPermissionItem(sb, true, T("Forum", "Forum"));
                AppendPermissionItem(sb, true, T("Private Messages", "Mesej Peribadi"));
                AppendPermissionItem(sb, true, T("Discover Shared Materials", "Temui Bahan Dikongsi"));
            }
            else
            {
                // Non-certified teachers have restricted access to core teaching features
                AppendPermissionItem(sb, false, T("Upload Learning Materials", "Muat Naik Bahan Pembelajaran"));
                AppendPermissionItem(sb, false, T("Create Quizzes", "Cipta Kuiz"));
                AppendPermissionItem(sb, false, T("View Student Progress", "Lihat Prestasi Pelajar"));
                AppendPermissionItem(sb, false, T("Conduct Live Sessions", "Jalankan Sesi Langsung"));
                AppendPermissionItem(sb, true, T("Forum", "Forum"));
                AppendPermissionItem(sb, true, T("Private Messages", "Mesej Peribadi"));
                AppendPermissionItem(sb, true, T("Discover Materials", "Temui Bahan"));
            }

            sb.Append("</ul>");
            litPermissions.Text = sb.ToString();
        }

        private void AppendPermissionItem(StringBuilder sb, bool allowed, string permissionName)
        {
            string liClass = allowed ? "enabled" : "restricted";
            string icon = allowed ? "bi bi-check-lg" : "bi bi-lock-fill";
            string statusLabel = allowed ? T("Allowed", "Dibenarkan") : T("Restricted", "Terhad");
            string statusCss = allowed ? "tc-my-profile-perm-status allowed" : "tc-my-profile-perm-status restricted";

            sb.AppendFormat(
                "<li class=\"{0}\"><span class=\"tc-my-profile-perm-ico\"><i class=\"{1}\"></i></span><span class=\"tc-my-profile-perm-name\">{2}</span><span class=\"{3}\">{4}</span></li>",
                liClass, icon, HttpUtility.HtmlEncode(permissionName), statusCss, statusLabel);
        }

        /// <summary>
        /// Maps the deletion reason code to a human-readable description.
        /// </summary>
        private string BuildDeletionReasonText(string reason, string detail)
        {
            if (reason == "other" && !string.IsNullOrEmpty(detail)) return detail;

            switch (reason)
            {
                case "no_longer_use": return "I no longer use ScienceBuddy";
                case "another_account": return "I created another account";
                case "privacy": return "I have privacy concerns";
                case "technical": return "I am experiencing technical issues";
                case "not_meet_needs": return "The platform does not meet my needs";
                default: return reason;
            }
        }

        #endregion
    }
}
