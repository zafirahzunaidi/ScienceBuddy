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
        protected string CurrentLanguage
        { get { string l = Session["preferredLanguage"] as string; return string.IsNullOrEmpty(l) ? "EN" : l; } }
        protected string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }

        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        protected bool IsCertified { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"]?.ToString() != "Teacher")
            { Response.Redirect("~/Login.aspx", false); Context.ApplicationInstance.CompleteRequest(); return; }

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

                        // Hero
                        string initials = "T";
                        var parts = name.Trim().Split(' ');
                        if (parts.Length >= 2) initials = (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
                        else if (name.Length > 0) initials = name[0].ToString().ToUpper();
                        litInitials.Text = HttpUtility.HtmlEncode(initials);
                        litName.Text = HttpUtility.HtmlEncode(name);
                        litTeacherId.Text = HttpUtility.HtmlEncode(tid);
                        litBioPreview.Text = HttpUtility.HtmlEncode(bio.Length > 100 ? bio.Substring(0, 100) + "…" : bio);

                        // Status badge
                        string badgeCss = "mp-badge-grey", statusLabel = T("Status Unavailable","Status Tidak Tersedia");
                        if (IsCertified) { badgeCss = "mp-badge-green"; statusLabel = T("Verified Educator","Pendidik Disahkan"); }
                        else if (isPending) { badgeCss = "mp-badge-orange"; statusLabel = T("Unverified Teacher","Guru Belum Disahkan"); }
                        else if (isRejected) { badgeCss = "mp-badge-red"; statusLabel = T("Verification Rejected","Pengesahan Ditolak"); }
                        litStatusBadge.Text = "<span class='mp-badge " + badgeCss + "'><i class='bi bi-circle-fill' style='font-size:.5rem;'></i> " + HttpUtility.HtmlEncode(statusLabel) + "</span>";

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
                        litPct.Text = pct.ToString();
                        litProgressMsg.Text = pct >= 80 ? T("Your profile looks great!", "Profil anda kelihatan hebat!") :
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
    }
}
