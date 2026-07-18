using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Student
{
    public partial class MyProfile1 : Page
    {
        // Connection string
        private string ConnectionString
        {
            get { return ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString; }
        }

        // Language helper
        public string CurrentLanguage = "EN";

        public string T(string en, string bm)
        {
            if (CurrentLanguage == "BM")
            {
                return bm;
            }
            return en;
        }

        // Page Load
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

        // InitLang
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
                    using (SqlConnection connection = new SqlConnection(ConnectionString))
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

        // SetLabels
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

        // LoadProfile
        private void LoadProfile()
        {
            string userId = Session["userId"].ToString();

            using (SqlConnection connection = new SqlConnection(ConnectionString))
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
                if (!string.IsNullOrEmpty(currentlevelId) && TableExists(connection, "Level"))
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
                if (!string.IsNullOrEmpty(personalityId) && TableExists(connection, "Personality"))
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

                // Populate Hero
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

                // Populate Form
                txtUsername.Text = username;
                txtName.Text = name;
                txtNickname.Text = nickname;
                txtPhone.Text = phoneNumber;
                txtEmail.Text = email;

                // Language dropdown
                ddlLanguage.SelectedValue = preferredLanguage;

                // Personality card
                litPersName.Text = System.Web.HttpUtility.HtmlEncode(persName);
                litPersDesc.Text = System.Web.HttpUtility.HtmlEncode(persDesc);
                litPersStyle.Text = System.Web.HttpUtility.HtmlEncode(persStyle);

                if (!string.IsNullOrWhiteSpace(persAvatar))
                {
                    litPersAvatarFallback.Text = "<img src=\"" +
                        System.Web.HttpUtility.HtmlAttributeEncode(ResolveUrl("~/Images/Personality/" + persAvatar)) +
                        "\" alt=\"Personality\" style=\"width:100%;height:100%;object-fit:cover;\" />";
                }

                // Account Status
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

                // Load linked parents
                LoadParents(connection, studentId);
            }
        }

        // btnSave_Click
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

            using (SqlConnection connection = new SqlConnection(ConnectionString))
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

        // btnChangePw_Click
        protected void btnChangePw_Click(object sender, EventArgs e)
        {
            InitLang();
            pnlPwSuccess.Visible = false;
            pnlPwError.Visible = false;

            // Keep the details section open after postback
            ClientScript.RegisterStartupScript(GetType(), "openPw", "document.querySelector('.st-profile-collapsible').open=true;", true);

            // Password fields don't retain value on postback, read from Request.Form
            string currentPw = Request.Form[txtCurrentPw.UniqueID] ?? "";
            string newPw = Request.Form[txtNewPw.UniqueID] ?? "";
            string confirmPw = Request.Form[txtConfirmPw.UniqueID] ?? "";
            string userId = Session["userId"].ToString();

            if (string.IsNullOrEmpty(currentPw) || string.IsNullOrEmpty(newPw) || string.IsNullOrEmpty(confirmPw))
            {
                litPwError.Text = T("Please fill in all password fields.", "Sila isi semua ruangan kata laluan.");
                pnlPwError.Visible = true;
                return;
            }
            if (newPw != confirmPw)
            {
                litPwError.Text = T("New passwords do not match.", "Kata laluan baru tidak sepadan.");
                pnlPwError.Visible = true;
                return;
            }
            int minPwLength = GetConfigInt("Password Minimum Length", 8);
            if (newPw.Length < minPwLength)
            {
                litPwError.Text = T("Password must be at least " + minPwLength + " characters.", "Kata laluan mestilah sekurang-kurangnya " + minPwLength + " aksara.");
                pnlPwError.Visible = true;
                return;
            }

            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                connection.Open();
                // Retrieve stored password hash for verification
                string storedPasswordHash = "";
                using (SqlCommand cmd = new SqlCommand("SELECT password FROM [User] WHERE userId=@uid", connection))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        storedPasswordHash = result.ToString();
                    }
                }

                // Verify current password using PasswordHelper
                if (!PasswordHelper.VerifyPassword(currentPw, storedPasswordHash))
                {
                    litPwError.Text = T("Current password is incorrect.", "Kata laluan semasa tidak betul.");
                    pnlPwError.Visible = true;
                    return;
                }

                // Hash the new password and save
                string newPasswordHash = PasswordHelper.HashPassword(newPw);
                using (SqlCommand cmd = new SqlCommand("UPDATE [User] SET password=@pw WHERE userId=@uid", connection))
                {
                    cmd.Parameters.AddWithValue("@pw", newPasswordHash);
                    cmd.Parameters.AddWithValue("@uid", userId);
                    cmd.ExecuteNonQuery();
                }
            }

            txtCurrentPw.Text = "";
            txtNewPw.Text = "";
            txtConfirmPw.Text = "";
            litPwSuccess.Text = T("Password updated successfully.", "Kata laluan berjaya dikemas kini.");
            pnlPwSuccess.Visible = true;
        }

        // rptParents_ItemCommand (Remove Parent)
        protected void rptParents_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "RemoveParent")
            {
                return;
            }
            InitLang();
            string studentParentId = e.CommandArgument.ToString();

            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                connection.Open();

                // Get parent userId before deleting the link
                string parentUserId = "";
                try
                {
                    using (SqlCommand cmd = new SqlCommand("SELECT p.userId FROM Parent p JOIN StudentParent sp ON sp.parentId=p.parentId WHERE sp.studentParentId=@spid", connection))
                    {
                        cmd.Parameters.AddWithValue("@spid", studentParentId);
                        var r = cmd.ExecuteScalar();
                        if (r != null && r != DBNull.Value) parentUserId = r.ToString();
                    }
                }
                catch (Exception ex) { System.Diagnostics.Debug.WriteLine("Get parent userId error: " + ex.Message); }

                using (SqlCommand cmd = new SqlCommand("DELETE FROM StudentParent WHERE studentParentId=@spid", connection))
                {
                    cmd.Parameters.AddWithValue("@spid", studentParentId);
                    cmd.ExecuteNonQuery();
                }

                // Notify parent of unlink
                if (!string.IsNullOrEmpty(parentUserId))
                {
                    try
                    {
                        SendNotification(connection, parentUserId, "Child Unlinked", "Anak Dipadam Pautan", "Your child has removed the parent link.", "Anak anda telah membuang pautan ibu bapa.");
                    }
                    catch (Exception ex) { System.Diagnostics.Debug.WriteLine("Unlink notification error: " + ex.Message); }
                }
            }

            LoadProfile();
        }

        // btnDeleteAccount_Click
        protected void btnDeleteAccount_Click(object sender, EventArgs e)
        {
            InitLang();
            pnlDeleteError.Visible = false;

            string password = (Request.Form[txtDeletePw.UniqueID] ?? "").Trim();
            string userId = Session["userId"].ToString();

            if (string.IsNullOrEmpty(password))
            {
                litDeleteError.Text = T("Please enter your password.", "Sila masukkan kata laluan anda.");
                pnlDeleteError.Visible = true;
                return;
            }

            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                connection.Open();

                // Verify password using PasswordHelper
                string storedPasswordHash = "";
                using (SqlCommand cmd = new SqlCommand("SELECT password FROM [User] WHERE userId=@uid", connection))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        storedPasswordHash = result.ToString();
                    }
                }

                if (!PasswordHelper.VerifyPassword(password, storedPasswordHash))
                {
                    litDeleteError.Text = T("Incorrect password.", "Kata laluan tidak betul.");
                    pnlDeleteError.Visible = true;
                    return;
                }

                // Set status to Deleted
                using (SqlCommand cmd = new SqlCommand("UPDATE [User] SET status='Deleted' WHERE userId=@uid", connection))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    cmd.ExecuteNonQuery();
                }

                // Log the deletion
                if (TableExists(connection, "Log"))
                {
                    string logId = "LOG001";
                    using (SqlCommand seqCmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING(logId,4,LEN(logId)-3) AS INT)),0) FROM Log WHERE logId LIKE 'LOG[0-9]%'", connection))
                    {
                        int last = Convert.ToInt32(seqCmd.ExecuteScalar());
                        logId = "LOG" + (last + 1).ToString("D3");
                    }
                    using (SqlCommand cmd = new SqlCommand("INSERT INTO Log(logId,userId,action,description,logDateTime,status) VALUES(@lid,@uid,@act,@desc,@dt,@st)", connection))
                    {
                        cmd.Parameters.AddWithValue("@lid", logId);
                        cmd.Parameters.AddWithValue("@uid", userId);
                        cmd.Parameters.AddWithValue("@act", "Account Deleted");
                        cmd.Parameters.AddWithValue("@desc", "Student account deleted by user request.");
                        cmd.Parameters.AddWithValue("@dt", DateTime.Now);
                        cmd.Parameters.AddWithValue("@st", "Success");
                        cmd.ExecuteNonQuery();
                    }
                }
            }

            // Logout
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Login.aspx", false);
        }

        // btnSendQuery_Click
        protected void btnSendQuery_Click(object sender, EventArgs e)
        {
            InitLang();
            pnlContactSuccess.Visible = false;
            pnlContactError.Visible = false;

            string subject = txtContactSubject.Text.Trim();
            string message = txtContactMsg.Text.Trim();

            if (string.IsNullOrEmpty(subject) || string.IsNullOrEmpty(message))
            {
                litContactError.Text = T("Please fill in both subject and message.", "Sila isi kedua-dua subjek dan mesej.");
                pnlContactError.Visible = true;
                return;
            }

            try
            {
                string smtpHost = ConfigurationManager.AppSettings["SmtpHost"];
                int smtpPort = int.Parse(ConfigurationManager.AppSettings["SmtpPort"] ?? "587");
                string smtpUser = ConfigurationManager.AppSettings["SmtpUsername"];
                string smtpPass = ConfigurationManager.AppSettings["SmtpPassword"];
                bool smtpSsl = ConfigurationManager.AppSettings["SmtpEnableSsl"] == "true";
                string adminEmail = ConfigurationManager.AppSettings["ContactRecipientEmail"];

                string studentName = txtName.Text.Trim();
                string studentEmail = txtEmail.Text.Trim();

                string body = "Student Query from ScienceBuddy\n\n";
                body += "From: " + studentName + " (" + studentEmail + ")\n";
                body += "Subject: " + subject + "\n\n";
                body += "Message:\n" + message + "\n\n";
                body += "Sent: " + DateTime.Now.ToString("dd MMM yyyy HH:mm");

                using (var mail = new System.Net.Mail.MailMessage())
                {
                    mail.From = new System.Net.Mail.MailAddress(smtpUser, "ScienceBuddy Student");
                    mail.To.Add(adminEmail);
                    mail.Subject = "[Student Query] " + subject;
                    mail.Body = body;
                    mail.IsBodyHtml = false;

                    using (var smtp = new System.Net.Mail.SmtpClient(smtpHost, smtpPort))
                    {
                        smtp.Credentials = new System.Net.NetworkCredential(smtpUser, smtpPass);
                        smtp.EnableSsl = smtpSsl;
                        smtp.Send(mail);
                    }
                }

                txtContactSubject.Text = "";
                txtContactMsg.Text = "";
                litContactSuccess.Text = T("Your message has been sent! We'll get back to you soon.", "Mesej anda telah dihantar! Kami akan hubungi anda segera.");
                pnlContactSuccess.Visible = true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Email error: " + ex.Message);
                litContactError.Text = T("Failed to send message. Please try again later.", "Gagal menghantar mesej. Sila cuba lagi kemudian.");
                pnlContactError.Visible = true;
            }
        }

        // Load linked parents
        private void LoadParents(SqlConnection connection, string studentId)
        {
            if (!TableExists(connection, "StudentParent") || !TableExists(connection, "Parent"))
            {
                pnlParentList.Visible = false;
                pnlNoParent.Visible = true;
                return;
            }

            const string sql = @"SELECT sp.studentParentId, p.name AS parentName, sp.relationship
                FROM StudentParent sp JOIN Parent p ON p.parentId=sp.parentId
                JOIN Student s ON s.studentId=sp.studentId
                WHERE s.studentId=@sid";

            DataTable parentTable = new DataTable();
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@sid", studentId);
                new SqlDataAdapter(command).Fill(parentTable);
            }

            if (parentTable.Rows.Count == 0)
            {
                pnlParentList.Visible = false;
                pnlNoParent.Visible = true;
            }
            else
            {
                pnlParentList.Visible = true;
                pnlNoParent.Visible = false;
                var list = new System.Collections.Generic.List<object>();
                foreach (DataRow row in parentTable.Rows)
                {
                    list.Add(new
                    {
                        StudentParentId = row["studentParentId"].ToString(),
                        ParentName = System.Web.HttpUtility.HtmlEncode(row["parentName"].ToString()),
                        Relationship = System.Web.HttpUtility.HtmlEncode(row["relationship"].ToString())
                    });
                }
                rptParents.DataSource = list;
                rptParents.DataBind();
            }
        }

        // Utility helpers

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

        private static bool TableExists(SqlConnection connection, string tableName)
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

        private void SendNotification(SqlConnection conn, string toUserId, string titleEN, string titleBM, string msgEN, string msgBM)
        {
            try
            {
                string nId = "N001";
                using (SqlCommand cmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING(notificationId,2,LEN(notificationId)-1) AS INT)),0) FROM Notification WHERE notificationId LIKE 'N[0-9]%'", conn))
                {
                    nId = "N" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3");
                }
                using (SqlCommand cmd = new SqlCommand("INSERT INTO Notification(notificationId,toUserId,titleEN,titleBM,messageEN,messageBM,isRead,createdAt) VALUES(@id,@to,@tEN,@tBM,@mEN,@mBM,0,@dt)", conn))
                {
                    cmd.Parameters.AddWithValue("@id", nId);
                    cmd.Parameters.AddWithValue("@to", toUserId);
                    cmd.Parameters.AddWithValue("@tEN", titleEN);
                    cmd.Parameters.AddWithValue("@tBM", titleBM);
                    cmd.Parameters.AddWithValue("@mEN", msgEN);
                    cmd.Parameters.AddWithValue("@mBM", msgBM);
                    cmd.Parameters.AddWithValue("@dt", DateTime.Now);
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Notification error: " + ex.Message);
            }
        }

        private int GetConfigInt(string configKey, int defaultValue)
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(ConnectionString))
                {
                    connection.Open();
                    using (SqlCommand command = new SqlCommand("SELECT configValue FROM ConfigurationSetting WHERE configKey=@k", connection))
                    {
                        command.Parameters.AddWithValue("@k", configKey);
                        object result = command.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            return Convert.ToInt32(result);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Config error: " + ex.Message);
            }
            return defaultValue;
        }
    }
}

