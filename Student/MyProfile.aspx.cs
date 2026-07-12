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
        private string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString; }
        }

        // ── Language helper ────────────────────────────────────────────
        public string CurrentLanguage = "EN";

        public string T(string en, string bm)
        {
            if (CurrentLanguage == "BM")
            {
                return bm;
            }
            return en;
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
                    using (SqlConnection connection = new SqlConnection(ConnStr))
                    using (SqlCommand command = new SqlCommand(sql, connection))
                    {
                        command.Parameters.AddWithValue("@userId", userId);
                        connection.Open();
                        object result = command.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            lang = result.ToString();
                            Session["preferredLanguage"] = lang;
                            CurrentLanguage = lang;
                            return;
                        }
                    }
                }
                catch (SqlException ex)
                {
                    System.Diagnostics.Debug.WriteLine("Database error: " + ex.Message);
                }
            }

            CurrentLanguage = "EN";
            Session["preferredLanguage"] = "EN";
        }

        // ── SetLabels ─────────────────────────────────────────────────
        private void SetLabels()
        {
            litPageTitle.Text = T("My Profile", "Profil Saya");
            litPersonalTitle.Text = T("Personal Information", "Maklumat Peribadi");
            litUsernameLbl.Text = T("Username", "Nama Pengguna");
            litNameLbl.Text = T("Name", "Nama");
            litNicknameLbl.Text = T("Nickname", "Nama Panggilan");
            litPhoneLbl.Text = T("Phone Number", "Nombor Telefon");
            litEmailLbl.Text = T("Email", "Emel");
            litLangTitle.Text = T("Language Preference", "Pilihan Bahasa");
            litLangLbl.Text = T("Language Preference", "Pilihan Bahasa");
            litPersonalityTitle.Text = T("Personality", "Personaliti");
            litPersStyleLbl.Text = T("Learning Style", "Gaya Pembelajaran");
            litRetakeBtn.Text = T("Retake Personality Test", "Jawab Semula Ujian Personaliti");
            litComingSoon.Text = T("Coming Soon", "Akan Datang");
            litStatusTitle.Text = T("Account Status", "Status Akaun");
            litStatusRoleLbl.Text = T("Role", "Peranan");
            litStatusStatusLbl.Text = T("Status", "Status");
            litStatusLangLbl.Text = T("Language Preference", "Pilihan Bahasa");
            litSaveBtn.Text = T("Save Changes", "Simpan Perubahan");
            litParentCodeLbl.Text = T("Parent Code", "Kod Ibu Bapa");
            litLevelLbl.Text = T("Current Level", "Tahap Semasa");
            litXPLbl.Text = T("Total XP", "Jumlah XP");

            btnSave.Text = T("Save Changes", "Simpan Perubahan");
        }

        // ── LoadProfile ───────────────────────────────────────────────
        private void LoadProfile()
        {
            string userId = Session["userId"].ToString();

            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();

                // Load User record
                string username = "", email = "", role = "", preferredLanguage = "", status = "";
                const string sqlUser = @"SELECT username, email, role, preferredLanguage, status
                                         FROM [User] WHERE userId = @userId";
                using (SqlCommand command = new SqlCommand(sqlUser, connection))
                {
                    command.Parameters.AddWithValue("@userId", userId);
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            if (reader["username"] != null)
                            {
                                username = reader["username"].ToString();
                            }
                            else
                            {
                                username = "";
                            }

                            if (reader["email"] != null)
                            {
                                email = reader["email"].ToString();
                            }
                            else
                            {
                                email = "";
                            }

                            if (reader["role"] != null)
                            {
                                role = reader["role"].ToString();
                            }
                            else
                            {
                                role = "";
                            }

                            if (reader["preferredLanguage"] != null)
                            {
                                preferredLanguage = reader["preferredLanguage"].ToString();
                            }
                            else
                            {
                                preferredLanguage = "EN";
                            }

                            if (reader["status"] != null)
                            {
                                status = reader["status"].ToString();
                            }
                            else
                            {
                                status = "";
                            }
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
                using (SqlCommand command = new SqlCommand(sqlStudent, connection))
                {
                    command.Parameters.AddWithValue("@userId", userId);
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            if (reader["studentId"] != null)
                            {
                                studentId = reader["studentId"].ToString();
                            }
                            else
                            {
                                studentId = "";
                            }

                            if (reader["name"] != null)
                            {
                                name = reader["name"].ToString();
                            }
                            else
                            {
                                name = "";
                            }

                            if (reader["nickname"] != null)
                            {
                                nickname = reader["nickname"].ToString();
                            }
                            else
                            {
                                nickname = "";
                            }

                            if (reader["phoneNumber"] != null)
                            {
                                phoneNumber = reader["phoneNumber"].ToString();
                            }
                            else
                            {
                                phoneNumber = "";
                            }

                            if (reader["currentlevelId"] != null)
                            {
                                currentlevelId = reader["currentlevelId"].ToString();
                            }
                            else
                            {
                                currentlevelId = "";
                            }
                            if (reader["XP"] == DBNull.Value)
                            {
                                xp = 0;
                            }
                            else
                            {
                                xp = Convert.ToInt32(reader["XP"]);
                            }
                            if (reader["personalityId"] != null)
                            {
                                personalityId = reader["personalityId"].ToString();
                            }
                            else
                            {
                                personalityId = "";
                            }

                            if (reader["parentCode"] != null)
                            {
                                parentCode = reader["parentCode"].ToString();
                            }
                            else
                            {
                                parentCode = "";
                            }
                        }
                    }
                }

                // Load Level name
                string levelName = "\u2014";
                if (!string.IsNullOrEmpty(currentlevelId) && Tbl(connection, "Level"))
                {
                    string sqlLevel;
                    if (CurrentLanguage == "BM")
                    {
                        sqlLevel = "SELECT levelNameBM FROM Level WHERE levelId = @levelId";
                    }
                    else
                    {
                        sqlLevel = "SELECT levelNameEN FROM Level WHERE levelId = @levelId";
                    }
                    using (SqlCommand command = new SqlCommand(sqlLevel, connection))
                    {
                        command.Parameters.AddWithValue("@levelId", currentlevelId);
                        object result = command.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            levelName = result.ToString();
                        }
                    }
                }

                // Load Personality
                string persName = "\u2014", persDesc = "\u2014", persStyle = "\u2014", persAvatar = "", persColour = "";
                if (!string.IsNullOrEmpty(personalityId) && Tbl(connection, "Personality"))
                {
                    const string sqlPers = @"SELECT personalityNameEN, personalityNameBM, 
                                                    descriptionEN, descriptionBM,
                                                    learningStyleEN, learningStyleBM, 
                                                    avatar, colour
                                             FROM Personality WHERE personalityId = @pid";
                    using (SqlCommand command = new SqlCommand(sqlPers, connection))
                    {
                        command.Parameters.AddWithValue("@pid", personalityId);
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                if (CurrentLanguage == "BM")
                                {
                                    persName = reader["personalityNameBM"]?.ToString() ?? reader["personalityNameEN"]?.ToString() ?? "\u2014";
                                }
                                else
                                {
                                    persName = reader["personalityNameEN"]?.ToString() ?? "\u2014";
                                }

                                if (CurrentLanguage == "BM")
                                {
                                    persDesc = reader["descriptionBM"]?.ToString() ?? reader["descriptionEN"]?.ToString() ?? "\u2014";
                                }
                                else
                                {
                                    persDesc = reader["descriptionEN"]?.ToString() ?? "\u2014";
                                }

                                if (CurrentLanguage == "BM")
                                {
                                    persStyle = reader["learningStyleBM"]?.ToString() ?? reader["learningStyleEN"]?.ToString() ?? "\u2014";
                                }
                                else
                                {
                                    persStyle = reader["learningStyleEN"]?.ToString() ?? "\u2014";
                                }

                                persAvatar = reader["avatar"]?.ToString() ?? "";
                                persColour = reader["colour"]?.ToString() ?? "";
                            }
                        }
                    }
                }

                // ── Populate Hero ──
                string displayName;
                if (string.IsNullOrWhiteSpace(nickname))
                {
                    displayName = name;
                }
                else
                {
                    displayName = nickname;
                }

                litHeroName.Text = System.Web.HttpUtility.HtmlEncode(displayName);
                litHeroRole.Text = T("Student", "Pelajar");
                litHeroLevel.Text = System.Web.HttpUtility.HtmlEncode(levelName);
                litHeroPersonality.Text = System.Web.HttpUtility.HtmlEncode(persName);
                litHeroXP.Text = xp.ToString("N0") + " XP";
                litHeroParentCode.Text = System.Web.HttpUtility.HtmlEncode(parentCode);

                // Avatar initial
                string initials = GetInitials(displayName);
                litHeroInitial.Text = System.Web.HttpUtility.HtmlEncode(initials);

                // ── Populate Form ──
                txtUsername.Text = username;
                txtName.Text = name;
                txtNickname.Text = nickname;
                txtPhone.Text = phoneNumber;
                txtEmail.Text = email;

                // ── Language dropdown ──
                ddlLanguage.SelectedValue = preferredLanguage;

                // ── Personality card ──
                litPersName.Text = System.Web.HttpUtility.HtmlEncode(persName);
                litPersDesc.Text = System.Web.HttpUtility.HtmlEncode(persDesc);
                litPersStyle.Text = System.Web.HttpUtility.HtmlEncode(persStyle);

                if (!string.IsNullOrWhiteSpace(persAvatar))
                {
                    litPersAvatarFallback.Text = "<img src=\"" +
                        System.Web.HttpUtility.HtmlAttributeEncode(ResolveUrl("~/Images/Personality/" + persAvatar)) +
                        "\" alt=\"Personality\" style=\"width:100%;height:100%;object-fit:cover;\" />";
                }

                // ── Account Status ──
                litStatusRole.Text = System.Web.HttpUtility.HtmlEncode(role);
                litStatusStatus.Text = System.Web.HttpUtility.HtmlEncode(status);
                if (preferredLanguage == "BM")
                {
                    litStatusLang.Text = "Bahasa Melayu";
                }
                else
                {
                    litStatusLang.Text = "English";
                }

                // Store studentId in ViewState for save
                ViewState["studentId"] = studentId;
                ViewState["userId"] = userId;
            }
        }

        // ── btnSave_Click ─────────────────────────────────────────────
        protected void btnSave_Click(object sender, EventArgs e)
        {
            InitLang();
            pnlSuccess.Visible = false;
            pnlSaveError.Visible = false;

            // Validate required fields
            string name = txtName.Text.Trim();
            string nickname = txtNickname.Text.Trim();
            string email = txtEmail.Text.Trim();

            if (string.IsNullOrEmpty(name) || string.IsNullOrEmpty(nickname) || string.IsNullOrEmpty(email))
            {
                litSaveError.Text = T("Please fill in all required fields.", "Sila isi semua maklumat yang diperlukan.");
                pnlSaveError.Visible = true;
                return;
            }

            string studentId = ViewState["studentId"] as string;
            string userId = ViewState["userId"] as string;
            string phone = txtPhone.Text.Trim();
            string lang = ddlLanguage.SelectedValue;

            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();

                // Update Student
                const string sqlStudent = @"UPDATE Student 
                                            SET name = @n, nickname = @nn, phoneNumber = @ph 
                                            WHERE studentId = @sid";
                using (SqlCommand command = new SqlCommand(sqlStudent, connection))
                {
                    command.Parameters.AddWithValue("@n", name);
                    command.Parameters.AddWithValue("@nn", nickname);
                    command.Parameters.AddWithValue("@ph", (object)phone ?? DBNull.Value);
                    command.Parameters.AddWithValue("@sid", studentId);
                    command.ExecuteNonQuery();
                }

                // Update User
                const string sqlUser = @"UPDATE [User] 
                                         SET email = @em, preferredLanguage = @lang 
                                         WHERE userId = @uid";
                using (SqlCommand command = new SqlCommand(sqlUser, connection))
                {
                    command.Parameters.AddWithValue("@em", email);
                    command.Parameters.AddWithValue("@lang", lang);
                    command.Parameters.AddWithValue("@uid", userId);
                    command.ExecuteNonQuery();
                }
            }

            // Update session
            Session["preferredLanguage"] = lang;
            if (string.IsNullOrWhiteSpace(nickname))
            {
                Session["_profileName"] = name;
            }
            else
            {
                Session["_profileName"] = nickname;
            }
            CurrentLanguage = lang;

            // Show success
            litSuccess.Text = T("Profile updated successfully.", "Profil berjaya dikemas kini.");
            pnlSuccess.Visible = true;

            // Refresh labels and profile display
            SetLabels();
            LoadProfile();
        }

        // ── Utility helpers ───────────────────────────────────────────

        private static string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name))
            {
                return "S";
            }
            string[] parts = name.Trim().Split(' ');
            if (parts.Length >= 2)
            {
                return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
            }
            return name[0].ToString().ToUpper();
        }

        private static bool Tbl(SqlConnection connection, string tableName)
        {
            const string sql = @"
                SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
                WHERE  TABLE_NAME = @tableName
                AND    TABLE_TYPE = 'BASE TABLE'";
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@tableName", tableName);
                return (int)command.ExecuteScalar() > 0;
            }
        }
    }
}
