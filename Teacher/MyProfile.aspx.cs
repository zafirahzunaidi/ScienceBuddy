using System;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.UI;

namespace ScienceBuddy.Teacher
{
    public partial class MyProfile : Page
    {
        protected global::System.Web.UI.WebControls.Literal litPermissions;
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl certIconDiv;
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl certIconI;

        protected string CurrentLanguage
        { get { string l = Session["preferredLanguage"] as string; return string.IsNullOrEmpty(l) ? "EN" : l; } }
        protected string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }

        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        protected bool IsCertified { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"]?.ToString() != "Teacher")
            { Response.Redirect("~/Login.aspx", false); Context.ApplicationInstance.CompleteRequest(); return; }

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

            if (!IsPostBack) LoadProfile();
        }

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
                    using (var r = cmd.ExecuteReader())
                    {
                        if (!r.Read()) return;
                        string name = r["name"]?.ToString() ?? "";
                        string tid = r["teacherId"]?.ToString() ?? "";
                        string phone = r["phoneNumber"]?.ToString() ?? "";
                        string qual = r["academicQualification"]?.ToString() ?? "";
                        string bio = r["bio"]?.ToString() ?? "";
                        string cert = r["licenseCert"]?.ToString() ?? "";
                        string status = r["status"]?.ToString() ?? "";

                        IsCertified = status.Equals("Certified", StringComparison.OrdinalIgnoreCase);
                        bool isPending = status.Equals("Pending", StringComparison.OrdinalIgnoreCase);
                        bool isRejected = status.Equals("Not Certified", StringComparison.OrdinalIgnoreCase) || status.Equals("Rejected", StringComparison.OrdinalIgnoreCase);

                        // Verification panel
                        if (IsCertified) pnlVerCertified.Visible = true;
                        else if (isPending) pnlVerPending.Visible = true;
                        else if (isRejected) pnlVerRejected.Visible = true;
                        else pnlVerUnknown.Visible = true;

                        // Access Permissions
                        RenderPermissions(IsCertified);

                        // Hero
                        string initials = "T";
                        var parts = name.Trim().Split(' ');
                        if (parts.Length >= 2) initials = (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
                        else if (name.Length > 0) initials = name[0].ToString().ToUpper();
                        litInitials.Text = HttpUtility.HtmlEncode(initials);
                        litName.Text = HttpUtility.HtmlEncode(name);
                        litTeacherId.Text = HttpUtility.HtmlEncode(tid);
                        litMemberId.Text = HttpUtility.HtmlEncode(tid);

                        // Status badge
                        string badgeCss = "mp-badge-grey", statusLabel = T("Status Unavailable","Status Tidak Tersedia");
                        string profileStatusText = T("Active","Aktif");
                        if (IsCertified) { badgeCss = "mp-badge-green"; statusLabel = T("Verified Educator","Pendidik Disahkan"); profileStatusText = T("Verified","Disahkan"); pnlAvatarVerified.Visible = true; }
                        else if (isPending) { badgeCss = "mp-badge-orange"; statusLabel = T("Unverified Teacher","Guru Belum Disahkan"); profileStatusText = T("Pending","Menunggu"); }
                        else if (isRejected) { badgeCss = "mp-badge-red"; statusLabel = T("Verification Rejected","Pengesahan Ditolak"); profileStatusText = T("Rejected","Ditolak"); }
                        litStatusBadge.Text = "<span class='mp-badge " + badgeCss + "'><i class='bi bi-patch-check-fill' style='font-size:.7rem;'></i> " + HttpUtility.HtmlEncode(statusLabel) + "</span>";
                        litProfileStatus.Text = HttpUtility.HtmlEncode(profileStatusText);

                        // Personal info
                        txtName.Text = name;
                        litTID.Text = HttpUtility.HtmlEncode(tid);
                        litQual.Text = string.IsNullOrEmpty(qual) ? "—" : HttpUtility.HtmlEncode(qual);
                        txtPhone.Text = phone;
                        txtBio.Text = bio;
                        txtBio.Attributes["placeholder"] = T("Tell students about yourself...", "Ceritakan tentang diri anda kepada pelajar...");

                        // Certificate
                        if (!string.IsNullOrEmpty(cert))
                        {
                            pnlCertExists.Visible = true;
                            litCertName.Text = HttpUtility.HtmlEncode(Path.GetFileName(cert));
                            lnkCert.HRef = ResolveUrl("~/") + cert;

                            // Set icon based on file type
                            string ext = Path.GetExtension(cert).ToLowerInvariant();
                            string iconClass = "bi bi-file-earmark-fill";
                            string iconCssClass = "mp-cert-icon other";
                            if (ext == ".pdf") { iconClass = "bi bi-file-earmark-pdf-fill"; iconCssClass = "mp-cert-icon pdf"; }
                            else if (ext == ".png" || ext == ".jpg" || ext == ".jpeg" || ext == ".gif" || ext == ".webp") { iconClass = "bi bi-file-earmark-image-fill"; iconCssClass = "mp-cert-icon img"; }
                            else if (ext == ".doc" || ext == ".docx") { iconClass = "bi bi-file-earmark-word-fill"; iconCssClass = "mp-cert-icon doc"; }
                            else if (ext == ".ppt" || ext == ".pptx") { iconClass = "bi bi-file-earmark-ppt-fill"; iconCssClass = "mp-cert-icon ppt"; }
                            certIconDiv.Attributes["class"] = iconCssClass;
                            certIconI.Attributes["class"] = iconClass;

                            // Approved date
                            var approvedDateVal = r["approvedDate"];
                            if (approvedDateVal != null && approvedDateVal != DBNull.Value)
                            {
                                pnlApprovedDate.Visible = true;
                                litApprovedDate.Text = Convert.ToDateTime(approvedDateVal).ToString("d MMM yyyy");
                            }
                        }
                        else { pnlCertEmpty.Visible = true; }

                        // Profile completion
                        int filled = 0, total = 5;
                        if (!string.IsNullOrEmpty(phone)) filled++;
                        if (!string.IsNullOrEmpty(qual)) filled++;
                        if (!string.IsNullOrEmpty(bio)) filled++;
                        if (!string.IsNullOrEmpty(cert)) filled++;
                        if (!string.IsNullOrEmpty(status)) filled++;
                        int pct = (int)Math.Round((double)filled / total * 100);
                        if (litPct != null) litPct.Text = pct.ToString();
                        if (litProgressMsg != null) litProgressMsg.Text = pct >= 80 ? T("Your profile looks great!", "Profil anda kelihatan hebat!") :
                            T("Complete your profile for a better experience.", "Lengkapkan profil anda untuk pengalaman yang lebih baik.");

                        // Button text
                        btnSave.Text = T("Save Changes", "Simpan Perubahan");
                        btnCancel.Text = T("Cancel", "Batal");
                    }
                }
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string name = txtName.Text.Trim();
            string phone = txtPhone.Text.Trim();
            string bio = txtBio.Text.Trim();

            // Validation
            if (string.IsNullOrEmpty(name))
            { hidToast.Value = T("Full Name is required.", "Nama Penuh diperlukan."); return; }
            if (name.Length > 100)
            { hidToast.Value = T("Full Name cannot exceed 100 characters.", "Nama Penuh tidak boleh melebihi 100 aksara."); return; }
            if (string.IsNullOrEmpty(phone))
            { hidToast.Value = T("Phone number is required.", "Nombor telefon diperlukan."); return; }
            foreach (char c in phone) { if (!char.IsDigit(c)) { hidToast.Value = T("Phone number must contain digits only.", "Nombor telefon mesti mengandungi digit sahaja."); return; } }
            if (bio.Length > 500)
            { hidToast.Value = T("Bio cannot exceed 500 characters.", "Biografi tidak boleh melebihi 500 aksara."); return; }

            string userId = Session["userId"].ToString();
            try
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
                hidToast.Value = T("Profile updated successfully.", "Profil berjaya dikemas kini.");
                LoadProfile();
            }
            catch { hidToast.Value = T("An error occurred.", "Ralat berlaku."); }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        { Response.Redirect("~/Teacher/Dashboard.aspx", false); Context.ApplicationInstance.CompleteRequest(); }

        private void RenderPermissions(bool isApproved)
        {
            var sb = new System.Text.StringBuilder();
            sb.Append("<ul class=\"mp-perm-list\">");

            if (isApproved)
            {
                AppendPerm(sb, true, T("Upload Learning Materials", "Muat Naik Bahan Pembelajaran"));
                AppendPerm(sb, true, T("Create Quizzes", "Cipta Kuiz"));
                AppendPerm(sb, true, T("View Student Progress", "Lihat Prestasi Pelajar"));
                AppendPerm(sb, true, T("Conduct Live Sessions", "Jalankan Sesi Langsung"));
                AppendPerm(sb, true, T("Forum", "Forum"));
                AppendPerm(sb, true, T("Private Messages", "Mesej Peribadi"));
                AppendPerm(sb, true, T("Discover Shared Materials", "Temui Bahan Dikongsi"));
            }
            else
            {
                AppendPerm(sb, false, T("Upload Learning Materials", "Muat Naik Bahan Pembelajaran"));
                AppendPerm(sb, false, T("Create Quizzes", "Cipta Kuiz"));
                AppendPerm(sb, false, T("View Student Progress", "Lihat Prestasi Pelajar"));
                AppendPerm(sb, false, T("Conduct Live Sessions", "Jalankan Sesi Langsung"));
                AppendPerm(sb, true, T("Forum", "Forum"));
                AppendPerm(sb, true, T("Private Messages", "Mesej Peribadi"));
                AppendPerm(sb, true, T("Discover Materials", "Temui Bahan"));
            }

            sb.Append("</ul>");
            litPermissions.Text = sb.ToString();
        }

        private void AppendPerm(System.Text.StringBuilder sb, bool allowed, string name)
        {
            string liClass = allowed ? "enabled" : "restricted";
            string icon = allowed ? "bi bi-check-lg" : "bi bi-lock-fill";
            string statusLabel = allowed ? T("Allowed", "Dibenarkan") : T("Restricted", "Terhad");
            string statusCss = allowed ? "mp-perm-status allowed" : "mp-perm-status restricted";
            sb.AppendFormat(
                "<li class=\"{0}\"><span class=\"mp-perm-ico\"><i class=\"{1}\"></i></span><span class=\"mp-perm-name\">{2}</span><span class=\"{3}\">{4}</span></li>",
                liClass, icon, HttpUtility.HtmlEncode(name), statusCss, statusLabel);
        }

        private void HandleSaveLanguage()
        {
            Response.Clear(); Response.ContentType = "text/plain";
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
            catch { Response.StatusCode = 500; Response.Write("Error"); }
        }

        private void HandleChangePassword()
        {
            Response.Clear(); Response.ContentType = "text/plain";
            string userId = Session["userId"]?.ToString() ?? "";
            string current = Request.Form["current"] ?? "";
            string newPw = Request.Form["newpw"] ?? "";
            if (string.IsNullOrEmpty(current) || string.IsNullOrEmpty(newPw) || newPw.Length < 6)
            { Response.StatusCode = 400; Response.Write(T("Invalid input.", "Input tidak sah.")); return; }
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
                    if (string.IsNullOrEmpty(storedHash) || !PasswordHelper.VerifyPassword(current, storedHash))
                    { Response.StatusCode = 400; Response.Write(T("Current password is incorrect.", "Kata laluan semasa tidak betul.")); return; }
                    // Update password with hash
                    string newHash = PasswordHelper.HashPassword(newPw);
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
                { Response.StatusCode = 500; Response.Write(T("Error changing password.", "Ralat menukar kata laluan.")); }
            }
        }

        private void HandleDeleteAccount()
        {
            Response.Clear(); Response.ContentType = "text/plain";
            string userId = Session["userId"]?.ToString() ?? "";
            if (string.IsNullOrEmpty(userId))
            { Response.StatusCode = 400; Response.Write("Invalid session."); return; }

            string reason = Request.Form["reason"] ?? "";
            string detail = Request.Form["detail"] ?? "";
            // Build description
            string reasonText = reason;
            if (reason == "other" && !string.IsNullOrEmpty(detail)) reasonText = detail;
            else if (reason == "no_longer_use") reasonText = "I no longer use ScienceBuddy";
            else if (reason == "another_account") reasonText = "I created another account";
            else if (reason == "privacy") reasonText = "I have privacy concerns";
            else if (reason == "technical") reasonText = "I am experiencing technical issues";
            else if (reason == "not_meet_needs") reasonText = "The platform does not meet my needs";
            string description = "Account deleted. Reason: " + reasonText;

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var txn = conn.BeginTransaction())
                    {
                        try
                        {
                            // 1. Update user status to Deleted
                            using (var cmd = new SqlCommand("UPDATE dbo.[User] SET [status]='Deleted' WHERE [userId]=@uid", conn, txn))
                            {
                                cmd.Parameters.AddWithValue("@uid", userId);
                                cmd.ExecuteNonQuery();
                            }
                            // 2. Generate log ID and insert Log record
                            string logId;
                            using (var cmd2 = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING([logId],4,LEN([logId])-3) AS INT)),0) FROM dbo.[Log]", conn, txn))
                            { logId = "LOG" + (Convert.ToInt32(cmd2.ExecuteScalar()) + 1).ToString("D3"); }
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
                        catch { txn.Rollback(); throw; }
                    }
                }
                Session.Clear();
                Session.Abandon();
                Response.Write("OK");
            }
            catch { Response.StatusCode = 500; Response.Write(T("Error deleting account.", "Ralat memadam akaun.")); }
        }
    }
}
