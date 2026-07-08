using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Parent
{
    public partial class ParentProfile : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        protected string CurrentLanguage = "EN";
        protected string T(string en, string bm) => CurrentLanguage == "BM" ? bm : en;
        private string _parentUserId = "", _parentId = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!EnsureAuth()) return;
            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            LoadLang();
            _parentUserId = Session["userId"].ToString();
            LoadParentId();

            if (!IsPostBack)
            {
                SetLabels();
                LoadChildren();
                LoadProfile();
            }
            else
            {
                SetLabels();
            }
        }

        private bool EnsureAuth()
        {
            if (Session["userId"] == null || Session["role"] == null || Session["role"].ToString() != "Parent")
            { Response.Redirect("~/Login.aspx", false); Context.ApplicationInstance.CompleteRequest(); return false; }
            return true;
        }

        private void LoadLang()
        {
            string l = Session["preferredLanguage"] as string;
            if (!string.IsNullOrEmpty(l)) { CurrentLanguage = l; return; }
            try
            {
                using (var c = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT preferredLanguage FROM dbo.[User] WHERE userId=@u", c))
                { cmd.Parameters.AddWithValue("@u", Session["userId"].ToString()); c.Open(); var r = cmd.ExecuteScalar(); if (r != null && r != DBNull.Value) { CurrentLanguage = r.ToString(); Session["preferredLanguage"] = CurrentLanguage; } }
            }
            catch { }
        }

        private void LoadParentId()
        {
            try
            {
                using (var c = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT parentId FROM dbo.[Parent] WHERE userId=@u", c))
                { cmd.Parameters.AddWithValue("@u", _parentUserId); c.Open(); var r = cmd.ExecuteScalar(); if (r != null) _parentId = r.ToString(); }
            }
            catch { }
        }

        private void LoadChildren()
        {
            ddlSidebarChild.Items.Clear();
            try
            {
                using (var c = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT s.studentId, ISNULL(s.nickname,s.name) AS n FROM dbo.StudentParent sp INNER JOIN dbo.Student s ON sp.studentId=s.studentId WHERE sp.parentId=@p ORDER BY s.name", c))
                { cmd.Parameters.AddWithValue("@p", _parentId); c.Open(); using (var r = cmd.ExecuteReader()) { while (r.Read()) ddlSidebarChild.Items.Add(new ListItem(r["n"].ToString(), r["studentId"].ToString())); } }
            }
            catch { }
            if (ddlSidebarChild.Items.Count > 0)
            {
                string saved = Session["selectedChildId"] as string;
                if (!string.IsNullOrEmpty(saved) && ddlSidebarChild.Items.FindByValue(saved) != null) ddlSidebarChild.SelectedValue = saved;
                else Session["selectedChildId"] = ddlSidebarChild.Items[0].Value;
            }
        }

        protected void SidebarChildChanged(object sender, EventArgs e) { Session["selectedChildId"] = ddlSidebarChild.SelectedValue; }

        private void SetLabels()
        {
            btnSave.Text = T("Save Changes", "Simpan Perubahan");
            btnChangePwd.Text = T("Change Password", "Tukar Kata Laluan");
        }

        private void LoadProfile()
        {
            try
            {
                using (var c = new SqlConnection(ConnStr))
                {
                    c.Open();

                    // Load User data
                    string username = "", email = "", role = "", status = "", lang = "";
                    using (var cmd = new SqlCommand("SELECT username, email, role, status, preferredLanguage FROM dbo.[User] WHERE userId=@u", c))
                    {
                        cmd.Parameters.AddWithValue("@u", _parentUserId);
                        using (var r = cmd.ExecuteReader())
                        {
                            if (r.Read())
                            {
                                username = r["username"] != DBNull.Value ? r["username"].ToString() : "";
                                email = r["email"] != DBNull.Value ? r["email"].ToString() : "";
                                role = r["role"] != DBNull.Value ? r["role"].ToString() : "";
                                status = r["status"] != DBNull.Value ? r["status"].ToString() : "";
                                lang = r["preferredLanguage"] != DBNull.Value ? r["preferredLanguage"].ToString() : "EN";
                            }
                        }
                    }

                    // Load Parent data
                    string name = "", phone = "";
                    using (var cmd = new SqlCommand("SELECT name, phoneNumber FROM dbo.[Parent] WHERE parentId=@p", c))
                    {
                        cmd.Parameters.AddWithValue("@p", _parentId);
                        using (var r = cmd.ExecuteReader())
                        {
                            if (r.Read())
                            {
                                name = r["name"] != DBNull.Value ? r["name"].ToString() : "";
                                phone = r["phoneNumber"] != DBNull.Value ? r["phoneNumber"].ToString() : "";
                            }
                        }
                    }

                    // Children count
                    int childCount = 0;
                    using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.StudentParent WHERE parentId=@p", c))
                    { cmd.Parameters.AddWithValue("@p", _parentId); childCount = (int)cmd.ExecuteScalar(); }

                    // Populate form
                    txtUsername.Text = username;
                    txtName.Text = name;
                    txtEmail.Text = email;
                    txtPhone.Text = phone;
                    if (ddlLang.Items.FindByValue(lang) != null) ddlLang.SelectedValue = lang;

                    // Hero
                    litHeroName.Text = Server.HtmlEncode(name);
                    litInitials.Text = GetInitials(name);
                    litHeroEmail.Text = Server.HtmlEncode(email);
                    litChildrenCount.Text = string.Format(T("{0} child(ren) linked", "{0} anak dipautkan"), childCount);

                    // Account status
                    litStatusRole.Text = role;
                    litStatusStatus.Text = status;
                    litStatusLang.Text = lang == "BM" ? "Bahasa Melayu" : "English";
                }
            }
            catch { }
        }

        private string GetInitials(string name)
        {
            if (string.IsNullOrEmpty(name)) return "P";
            var parts = name.Trim().Split(' ');
            if (parts.Length >= 2) return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
            return parts[0][0].ToString().ToUpper();
        }

        // ══════════════════════════════════════════════════════════════
        //  SAVE PROFILE
        // ══════════════════════════════════════════════════════════════
        protected void BtnSave_Click(object sender, EventArgs e)
        {
            string name = txtName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string phone = txtPhone.Text.Trim();
            string lang = ddlLang.SelectedValue;

            if (string.IsNullOrEmpty(name)) { ShowMsg(T("Name cannot be empty.", "Nama tidak boleh kosong."), false); return; }
            if (string.IsNullOrEmpty(email)) { ShowMsg(T("Email cannot be empty.", "E-mel tidak boleh kosong."), false); return; }

            try
            {
                using (var c = new SqlConnection(ConnStr))
                {
                    c.Open();

                    // Update Parent table
                    using (var cmd = new SqlCommand("UPDATE dbo.[Parent] SET name=@n, phoneNumber=@ph WHERE parentId=@p", c))
                    { cmd.Parameters.AddWithValue("@n", name); cmd.Parameters.AddWithValue("@ph", (object)phone ?? DBNull.Value); cmd.Parameters.AddWithValue("@p", _parentId); cmd.ExecuteNonQuery(); }

                    // Update User table (email + language)
                    using (var cmd = new SqlCommand("UPDATE dbo.[User] SET email=@e, preferredLanguage=@l WHERE userId=@u", c))
                    { cmd.Parameters.AddWithValue("@e", email); cmd.Parameters.AddWithValue("@l", lang); cmd.Parameters.AddWithValue("@u", _parentUserId); cmd.ExecuteNonQuery(); }
                }

                Session["preferredLanguage"] = lang;
                CurrentLanguage = lang;
                ShowMsg(T("Profile updated successfully!", "Profil berjaya dikemas kini!"), true);
                LoadProfile();
            }
            catch { ShowMsg(T("An error occurred while saving.", "Ralat berlaku semasa menyimpan."), false); }
        }

        // ══════════════════════════════════════════════════════════════
        //  CHANGE PASSWORD
        // ══════════════════════════════════════════════════════════════
        protected void BtnChangePwd_Click(object sender, EventArgs e)
        {
            string current = txtCurrentPwd.Text;
            string newPwd = txtNewPwd.Text;
            string confirm = txtConfirmPwd.Text;

            if (string.IsNullOrEmpty(current)) { ShowMsg(T("Please enter your current password.", "Sila masukkan kata laluan semasa anda."), false); return; }
            if (string.IsNullOrEmpty(newPwd)) { ShowMsg(T("Please enter a new password.", "Sila masukkan kata laluan baharu."), false); return; }
            if (newPwd.Length < 6) { ShowMsg(T("New password must be at least 6 characters.", "Kata laluan baharu mesti sekurang-kurangnya 6 aksara."), false); return; }
            if (newPwd != confirm) { ShowMsg(T("New passwords do not match.", "Kata laluan baharu tidak sepadan."), false); return; }

            try
            {
                using (var c = new SqlConnection(ConnStr))
                {
                    c.Open();

                    // Verify current password
                    string storedPwd = "";
                    using (var cmd = new SqlCommand("SELECT password FROM dbo.[User] WHERE userId=@u", c))
                    { cmd.Parameters.AddWithValue("@u", _parentUserId); var r = cmd.ExecuteScalar(); if (r != null && r != DBNull.Value) storedPwd = r.ToString(); }

                    if (storedPwd != current)
                    { ShowMsg(T("Current password is incorrect.", "Kata laluan semasa tidak betul."), false); return; }

                    // Update password
                    using (var cmd = new SqlCommand("UPDATE dbo.[User] SET password=@p WHERE userId=@u", c))
                    { cmd.Parameters.AddWithValue("@p", newPwd); cmd.Parameters.AddWithValue("@u", _parentUserId); cmd.ExecuteNonQuery(); }
                }

                txtCurrentPwd.Text = "";
                txtNewPwd.Text = "";
                txtConfirmPwd.Text = "";
                ShowMsg(T("Password changed successfully!", "Kata laluan berjaya ditukar!"), true);
            }
            catch { ShowMsg(T("An error occurred while changing password.", "Ralat berlaku semasa menukar kata laluan."), false); }
        }

        private void ShowMsg(string msg, bool ok) { pnlMessage.Visible = true; divMsg.InnerHtml = msg; iMsgIcon.Attributes["class"] = ok ? "bi bi-check-circle-fill" : "bi bi-exclamation-circle-fill"; }
        protected void BtnCloseMsg_Click(object sender, EventArgs e) { pnlMessage.Visible = false; }
    }
}
