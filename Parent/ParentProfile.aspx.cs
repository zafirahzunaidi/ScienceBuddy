using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Text.RegularExpressions;
using System.Web.UI;

namespace ScienceBuddy.Parent
{
    public partial class ParentProfile : Page
    {
        // ── Connection string ─────────────────────────────────────────
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        // ── Language ──────────────────────────────────────────────────
        protected string CurrentLanguage = "EN";

        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        private string _userId = "";

        // ══════════════════════════════════════════════════════════════
        //  PAGE LOAD
        // ══════════════════════════════════════════════════════════════

        protected void Page_Load(object sender, EventArgs e)
        {
            // Authorization
            if (Session["userId"] == null || Session["role"] == null ||
                Session["role"].ToString() != "Parent")
            {
                Response.Redirect("~/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";

            _userId = Session["userId"].ToString();
            LoadCurrentLanguage();
            SetLabels();

            if (!IsPostBack)
            {
                LoadProfile();
            }
        }

        // ══════════════════════════════════════════════════════════════
        //  LANGUAGE
        // ══════════════════════════════════════════════════════════════

        private void LoadCurrentLanguage()
        {
            string lang = Session["preferredLanguage"] as string;
            if (!string.IsNullOrEmpty(lang))
            {
                CurrentLanguage = lang;
                return;
            }

            try
            {
                const string sql = "SELECT preferredLanguage FROM dbo.[User] WHERE userId = @userId";
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", _userId);
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        lang = result.ToString();
                        Session["preferredLanguage"] = lang;
                        CurrentLanguage = lang;
                        return;
                    }
                }
            }
            catch (SqlException) { }

            CurrentLanguage = "EN";
        }

        // ══════════════════════════════════════════════════════════════
        //  LABELS
        // ══════════════════════════════════════════════════════════════

        private void SetLabels()
        {
            litTitle.Text       = T("My Profile", "Profil Saya");
            litSub.Text         = T("View and update your parent account details.",
                                    "Lihat dan kemaskini butiran akaun ibu bapa anda.");
            litLblUsername.Text  = T("Username", "Nama Pengguna");
            litLblName.Text     = T("Full Name", "Nama Penuh");
            litLblEmail.Text    = T("Email Address", "Alamat Emel");
            litLblPhone.Text    = T("Phone Number", "Nombor Telefon");
            litLblLang.Text     = T("Preferred Language", "Bahasa Pilihan");
            btnSave.Text        = T("Save Changes", "Simpan Perubahan");
        }

        // ══════════════════════════════════════════════════════════════
        //  LOAD PROFILE
        // ══════════════════════════════════════════════════════════════

        private void LoadProfile()
        {
            try
            {
                const string sql = @"
                    SELECT u.username, u.email, u.preferredLanguage,
                           p.name, p.phoneNumber
                    FROM dbo.[User] u
                    INNER JOIN dbo.[Parent] p ON p.userId = u.userId
                    WHERE u.userId = @userId";

                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", _userId);
                    conn.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            txtUsername.Text = reader["username"]?.ToString() ?? "";
                            txtName.Text    = reader["name"]?.ToString() ?? "";
                            txtEmail.Text   = reader["email"]?.ToString() ?? "";
                            txtPhone.Text   = reader["phoneNumber"]?.ToString() ?? "";

                            string lang = reader["preferredLanguage"]?.ToString() ?? "EN";
                            if (ddlLang.Items.FindByValue(lang) != null)
                                ddlLang.SelectedValue = lang;
                        }
                    }
                }
            }
            catch (SqlException)
            {
                ShowMessage(T("Unable to load profile.", "Gagal memuatkan profil."), true);
            }
        }

        // ══════════════════════════════════════════════════════════════
        //  SAVE PROFILE
        // ══════════════════════════════════════════════════════════════

        protected void BtnSave_Click(object sender, EventArgs e)
        {
            string name  = txtName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string phone = txtPhone.Text.Trim();
            string lang  = ddlLang.SelectedValue;

            // ── Validation ────────────────────────────────────────────
            if (string.IsNullOrEmpty(name))
            {
                ShowMessage(T("Name is required.", "Nama diperlukan."), true);
                return;
            }

            if (string.IsNullOrEmpty(email))
            {
                ShowMessage(T("Email is required.", "Emel diperlukan."), true);
                return;
            }

            if (!Regex.IsMatch(email, @"^[^@\s]+@[^@\s]+\.[^@\s]+$"))
            {
                ShowMessage(T("Please enter a valid email address.", "Sila masukkan alamat emel yang sah."), true);
                return;
            }

            if (!string.IsNullOrEmpty(phone))
            {
                if (!Regex.IsMatch(phone, @"^\d{10,12}$"))
                {
                    ShowMessage(T("Phone number must be 10-12 digits.", "Nombor telefon mesti 10-12 digit."), true);
                    return;
                }
            }

            if (lang != "EN" && lang != "BM")
            {
                ShowMessage(T("Invalid language selection.", "Pilihan bahasa tidak sah."), true);
                return;
            }

            // ── Email uniqueness check ────────────────────────────────
            try
            {
                const string checkSql = "SELECT COUNT(*) FROM dbo.[User] WHERE email = @email AND userId != @userId";
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(checkSql, conn))
                {
                    cmd.Parameters.AddWithValue("@email", email);
                    cmd.Parameters.AddWithValue("@userId", _userId);
                    conn.Open();
                    int count = Convert.ToInt32(cmd.ExecuteScalar());
                    if (count > 0)
                    {
                        ShowMessage(T("This email is already used by another account.",
                                      "Emel ini sudah digunakan oleh akaun lain."), true);
                        return;
                    }
                }
            }
            catch (SqlException)
            {
                ShowMessage(T("An error occurred. Please try again.",
                              "Ralat berlaku. Sila cuba lagi."), true);
                return;
            }

            // ── Update ────────────────────────────────────────────────
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var tran = conn.BeginTransaction())
                    {
                        // Update User
                        const string userSql = @"
                            UPDATE dbo.[User]
                            SET email = @email, preferredLanguage = @lang
                            WHERE userId = @userId";

                        using (var cmd = new SqlCommand(userSql, conn, tran))
                        {
                            cmd.Parameters.AddWithValue("@email", email);
                            cmd.Parameters.AddWithValue("@lang", lang);
                            cmd.Parameters.AddWithValue("@userId", _userId);
                            cmd.ExecuteNonQuery();
                        }

                        // Update Parent
                        const string parentSql = @"
                            UPDATE dbo.[Parent]
                            SET name = @name, phoneNumber = @phone
                            WHERE userId = @userId";

                        using (var cmd = new SqlCommand(parentSql, conn, tran))
                        {
                            cmd.Parameters.AddWithValue("@name", name);
                            cmd.Parameters.AddWithValue("@phone", string.IsNullOrEmpty(phone) ? (object)DBNull.Value : phone);
                            cmd.Parameters.AddWithValue("@userId", _userId);
                            cmd.ExecuteNonQuery();
                        }

                        tran.Commit();
                    }
                }

                // Update session language
                Session["preferredLanguage"] = lang;
                CurrentLanguage = lang;

                // Refresh labels with new language
                SetLabels();

                ShowMessage(T("Profile updated successfully.", "Profil berjaya dikemaskini."), false);
            }
            catch (SqlException)
            {
                ShowMessage(T("An error occurred while saving. Please try again.",
                              "Ralat berlaku semasa menyimpan. Sila cuba lagi."), true);
            }
        }

        // ══════════════════════════════════════════════════════════════
        //  MESSAGES
        // ══════════════════════════════════════════════════════════════

        private void ShowMessage(string message, bool isError)
        {
            pnlMessage.Visible = true;
            divMsg.InnerHtml = Server.HtmlEncode(message);
            divMsg.Attributes["class"] = isError ? "pp-msg error" : "pp-msg success";
        }
    }
}
