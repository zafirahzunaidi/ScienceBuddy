using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace ScienceBuddy.Student
{
    public partial class MyProfile1 : Page
    {
        // ── Connection string ─────────────────────────────────────────
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        // ── Language helper ────────────────────────────────────────────
        public string CurrentLanguage = "EN";

        public string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        // ── Page Load ─────────────────────────────────────────────────
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null ||
                Session["role"].ToString() != "Student")
            {
                Response.Redirect("~/Login.aspx", false);
                return;
            }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";

            InitLang();

            if (!IsPostBack)
            {
                SetLabels();
                LoadProfile();
            }
        }

        // ── InitLang ──────────────────────────────────────────────────
        private void InitLang()
        {
            string lang = Session["preferredLanguage"] as string;
            if (!string.IsNullOrEmpty(lang))
            {
                CurrentLanguage = lang;
                return;
            }

            string userId = Session["userId"] as string;
            if (!string.IsNullOrEmpty(userId))
            {
                try
                {
                    const string sql = "SELECT preferredLanguage FROM [User] WHERE userId = @userId";
                    using (var conn = new SqlConnection(ConnStr))
                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@userId", userId);
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
            }

            CurrentLanguage = "EN";
            Session["preferredLanguage"] = "EN";
        }

        // ── SetLabels ─────────────────────────────────────────────────
        private void SetLabels()
        {
            litPageTitle.Text       = T("My Profile", "Profil Saya");
            litPersonalTitle.Text   = T("Personal Information", "Maklumat Peribadi");
            litUsernameLbl.Text     = T("Username", "Nama Pengguna");
            litNameLbl.Text         = T("Name", "Nama");
            litNicknameLbl.Text     = T("Nickname", "Nama Panggilan");
            litPhoneLbl.Text        = T("Phone Number", "Nombor Telefon");
            litEmailLbl.Text        = T("Email", "Emel");
            litLangTitle.Text       = T("Language Preference", "Pilihan Bahasa");
            litLangLbl.Text         = T("Language Preference", "Pilihan Bahasa");
            litPersonalityTitle.Text = T("Personality", "Personaliti");
            litPersStyleLbl.Text    = T("Learning Style", "Gaya Pembelajaran");
            litRetakeBtn.Text       = T("Retake Personality Test", "Jawab Semula Ujian Personaliti");
            litComingSoon.Text      = T("Coming Soon", "Akan Datang");
            litStatusTitle.Text     = T("Account Status", "Status Akaun");
            litStatusRoleLbl.Text   = T("Role", "Peranan");
            litStatusStatusLbl.Text = T("Status", "Status");
            litStatusLangLbl.Text   = T("Language Preference", "Pilihan Bahasa");
            litSaveBtn.Text         = T("Save Changes", "Simpan Perubahan");
            litParentCodeLbl.Text   = T("Parent Code", "Kod Ibu Bapa");
            litLevelLbl.Text        = T("Current Level", "Tahap Semasa");
            litXPLbl.Text           = T("Total XP", "Jumlah XP");

            btnSave.Text            = T("Save Changes", "Simpan Perubahan");
        }

        // ── LoadProfile ───────────────────────────────────────────────
        private void LoadProfile()
        {
            string userId = Session["userId"].ToString();

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Load User record
                string username = "", email = "", role = "", preferredLanguage = "", status = "";
                const string sqlUser = @"SELECT username, email, role, preferredLanguage, status
                                         FROM [User] WHERE userId = @userId";
                using (var cmd = new SqlCommand(sqlUser, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            username          = reader["username"]?.ToString() ?? "";
                            email             = reader["email"]?.ToString() ?? "";
                            role              = reader["role"]?.ToString() ?? "";
                            preferredLanguage = reader["preferredLanguage"]?.ToString() ?? "EN";
                            status            = reader["status"]?.ToString() ?? "";
                        }
                    }
                }

                // Load Student record
                string studentId = "", name = "", nickname = "", phoneNumber = "", parentCode = "";
                int xp = 0;
                string currentlevelId = "", personalityId = "";
                const string sqlStudent = @"SELECT studentId, name, nickname, phoneNumber, 
                                                   currentlevelId, XP, personalityId, parentCode
                                            FROM Student WHERE userId = @userId";
                using (var cmd = new SqlCommand(sqlStudent, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            studentId      = reader["studentId"]?.ToString() ?? "";
                            name           = reader["name"]?.ToString() ?? "";
                            nickname       = reader["nickname"]?.ToString() ?? "";
                            phoneNumber    = reader["phoneNumber"]?.ToString() ?? "";
                            currentlevelId = reader["currentlevelId"]?.ToString() ?? "";
                            xp             = reader["XP"] == DBNull.Value ? 0 : Convert.ToInt32(reader["XP"]);
                            personalityId  = reader["personalityId"]?.ToString() ?? "";
                            parentCode     = reader["parentCode"]?.ToString() ?? "";
                        }
                    }
                }

                // Load Level name
                string levelName = "\u2014";
                if (!string.IsNullOrEmpty(currentlevelId) && Tbl(conn, "Level"))
                {
                    string sqlLevel = CurrentLanguage == "BM"
                        ? "SELECT levelNameBM FROM Level WHERE levelId = @levelId"
                        : "SELECT levelNameEN FROM Level WHERE levelId = @levelId";
                    using (var cmd = new SqlCommand(sqlLevel, conn))
                    {
                        cmd.Parameters.AddWithValue("@levelId", currentlevelId);
                        object result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                            levelName = result.ToString();
                    }
                }

                // Load Personality
                string persName = "\u2014", persDesc = "\u2014", persStyle = "\u2014", persAvatar = "", persColour = "";
                if (!string.IsNullOrEmpty(personalityId) && Tbl(conn, "Personality"))
                {
                    const string sqlPers = @"SELECT personalityNameEN, personalityNameBM, 
                                                    descriptionEN, descriptionBM,
                                                    learningStyleEN, learningStyleBM, 
                                                    avatar, colour
                                             FROM Personality WHERE personalityId = @pid";
                    using (var cmd = new SqlCommand(sqlPers, conn))
                    {
                        cmd.Parameters.AddWithValue("@pid", personalityId);
                        using (var reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                persName   = CurrentLanguage == "BM"
                                    ? (reader["personalityNameBM"]?.ToString() ?? reader["personalityNameEN"]?.ToString() ?? "\u2014")
                                    : (reader["personalityNameEN"]?.ToString() ?? "\u2014");
                                persDesc   = CurrentLanguage == "BM"
                                    ? (reader["descriptionBM"]?.ToString() ?? reader["descriptionEN"]?.ToString() ?? "\u2014")
                                    : (reader["descriptionEN"]?.ToString() ?? "\u2014");
                                persStyle  = CurrentLanguage == "BM"
                                    ? (reader["learningStyleBM"]?.ToString() ?? reader["learningStyleEN"]?.ToString() ?? "\u2014")
                                    : (reader["learningStyleEN"]?.ToString() ?? "\u2014");
                                persAvatar = reader["avatar"]?.ToString() ?? "";
                                persColour = reader["colour"]?.ToString() ?? "";
                            }
                        }
                    }
                }

                // ── Populate Hero ──
                string displayName = string.IsNullOrWhiteSpace(nickname) ? name : nickname;
                litHeroName.Text       = System.Web.HttpUtility.HtmlEncode(displayName);
                litHeroRole.Text       = T("Student", "Pelajar");
                litHeroLevel.Text       = System.Web.HttpUtility.HtmlEncode(levelName);
                litHeroPersonality.Text = System.Web.HttpUtility.HtmlEncode(persName);
                litHeroXP.Text          = xp.ToString("N0") + " XP";
                litHeroParentCode.Text  = System.Web.HttpUtility.HtmlEncode(parentCode);

                // Avatar initial
                string initials = GetInitials(displayName);
                litHeroInitial.Text = System.Web.HttpUtility.HtmlEncode(initials);

                // ── Populate Form ──
                txtUsername.Text = username;
                txtName.Text     = name;
                txtNickname.Text = nickname;
                txtPhone.Text    = phoneNumber;
                txtEmail.Text    = email;

                // ── Language dropdown ──
                ddlLanguage.SelectedValue = preferredLanguage;

                // ── Personality card ──
                litPersName.Text  = System.Web.HttpUtility.HtmlEncode(persName);
                litPersDesc.Text  = System.Web.HttpUtility.HtmlEncode(persDesc);
                litPersStyle.Text = System.Web.HttpUtility.HtmlEncode(persStyle);

                if (!string.IsNullOrWhiteSpace(persAvatar))
                {
                    litPersAvatarFallback.Text = "<img src=\"" +
                        System.Web.HttpUtility.HtmlAttributeEncode(ResolveUrl("~/Images/Personality/" + persAvatar)) +
                        "\" alt=\"Personality\" style=\"width:100%;height:100%;object-fit:cover;\" />";
                }

                // ── Account Status ──
                litStatusRole.Text   = System.Web.HttpUtility.HtmlEncode(role);
                litStatusStatus.Text = System.Web.HttpUtility.HtmlEncode(status);
                litStatusLang.Text   = preferredLanguage == "BM" ? "Bahasa Melayu" : "English";

                // Store studentId in ViewState for save
                ViewState["studentId"] = studentId;
                ViewState["userId"]    = userId;
            }
        }

        // ── btnSave_Click ─────────────────────────────────────────────
        protected void btnSave_Click(object sender, EventArgs e)
        {
            InitLang();
            pnlSuccess.Visible  = false;
            pnlSaveError.Visible = false;

            // Validate required fields
            string name     = txtName.Text.Trim();
            string nickname = txtNickname.Text.Trim();
            string email    = txtEmail.Text.Trim();

            if (string.IsNullOrEmpty(name) || string.IsNullOrEmpty(nickname) || string.IsNullOrEmpty(email))
            {
                litSaveError.Text      = T("Please fill in all required fields.", "Sila isi semua maklumat yang diperlukan.");
                pnlSaveError.Visible   = true;
                return;
            }

            string studentId = ViewState["studentId"] as string;
            string userId    = ViewState["userId"] as string;
            string phone     = txtPhone.Text.Trim();
            string lang      = ddlLanguage.SelectedValue;

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Update Student
                const string sqlStudent = @"UPDATE Student 
                                            SET name = @n, nickname = @nn, phoneNumber = @ph 
                                            WHERE studentId = @sid";
                using (var cmd = new SqlCommand(sqlStudent, conn))
                {
                    cmd.Parameters.AddWithValue("@n", name);
                    cmd.Parameters.AddWithValue("@nn", nickname);
                    cmd.Parameters.AddWithValue("@ph", (object)phone ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@sid", studentId);
                    cmd.ExecuteNonQuery();
                }

                // Update User
                const string sqlUser = @"UPDATE [User] 
                                         SET email = @em, preferredLanguage = @lang 
                                         WHERE userId = @uid";
                using (var cmd = new SqlCommand(sqlUser, conn))
                {
                    cmd.Parameters.AddWithValue("@em", email);
                    cmd.Parameters.AddWithValue("@lang", lang);
                    cmd.Parameters.AddWithValue("@uid", userId);
                    cmd.ExecuteNonQuery();
                }
            }

            // Update session
            Session["preferredLanguage"] = lang;
            Session["_profileName"]      = string.IsNullOrWhiteSpace(nickname) ? name : nickname;
            CurrentLanguage              = lang;

            // Show success
            litSuccess.Text    = T("Profile updated successfully.", "Profil berjaya dikemas kini.");
            pnlSuccess.Visible = true;

            // Refresh labels and profile display
            SetLabels();
            LoadProfile();
        }

        // ── Utility helpers ───────────────────────────────────────────

        private static string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "S";
            var parts = name.Trim().Split(' ');
            return parts.Length >= 2
                ? (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper()
                : name[0].ToString().ToUpper();
        }

        private static bool Tbl(SqlConnection conn, string tableName)
        {
            const string sql = @"
                SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
                WHERE  TABLE_NAME = @tableName
                AND    TABLE_TYPE = 'BASE TABLE'";
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@tableName", tableName);
                return (int)cmd.ExecuteScalar() > 0;
            }
        }
    }
}
