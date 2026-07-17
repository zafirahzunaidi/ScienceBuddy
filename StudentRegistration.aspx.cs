using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace ScienceBuddy
{
    public partial class StudentRegistration : Page
    {
        private string ConnectionString
        {
            get { return ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // If already logged in, redirect to home
            if (Session["userId"] != null && Session["role"] != null)
            {
                Response.Redirect("~/", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            ((SiteMaster)Master).LayoutMode = "TopNav";
        }

        protected void BtnRegister_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            // Collect form values
            string fullName = txtName.Text.Trim();
            string nickname = txtNickname.Text.Trim();
            string username = txtUsername.Text.Trim();
            string email = txtEmail.Text.Trim().ToLower();
            string phone = txtPhone.Text.Trim();
            string password = txtPassword.Text;
            string preferredLanguage = ddlLanguage.SelectedValue;

            // Server-side password length check (minimum from database settings)
            int minimumLength = GetMinimumPasswordLength();
            if (password.Length < minimumLength)
            {
                ShowError("Password must be at least " + minimumLength + " characters.");
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnectionString))
                {
                    conn.Open();

                    // Check for duplicate username or email before proceeding
                    if (IsValueTaken(conn, "username", username))
                    {
                        ShowError("Username already exists.");
                        return;
                    }
                    if (IsValueTaken(conn, "email", email))
                    {
                        ShowError("Email already exists.");
                        return;
                    }

                    // Use a transaction so that both User and Student rows are created together
                    using (SqlTransaction txn = conn.BeginTransaction())
                    {
                        try
                        {
                            string newUserId = GenerateNextId(conn, txn, "User", "userId", "U");
                            string newStudentId = GenerateNextId(conn, txn, "Student", "studentId", "S");
                            string parentCode = GenerateUniqueParentCode(conn, txn);
                            string hashedPassword = PasswordHelper.HashPassword(password);

                            InsertUserRow(conn, txn, newUserId, username, hashedPassword, email, preferredLanguage);
                            InsertStudentRow(conn, txn, newStudentId, newUserId, fullName, phone, nickname, parentCode);
                            SendWelcomeNotification(conn, txn, newUserId);

                            txn.Commit();

                            // Show success and hide the form
                            pnlForm.Visible = false;
                            pnlSuccess.Visible = true;
                        }
                        catch
                        {
                            txn.Rollback();
                            throw;
                        }
                    }
                }
            }
            catch (Exception)
            {
                ShowError("Registration failed. Please try again.");
            }
        }

        // ────────────────────────────────────────────────────────
        //  DATABASE INSERT METHODS
        // ────────────────────────────────────────────────────────

        private void InsertUserRow(SqlConnection conn, SqlTransaction txn,
            string userId, string username, string hashedPassword, string email, string language)
        {
            string sql = @"INSERT INTO dbo.[User]
                (userId, username, password, email, role, preferredLanguage, status)
                VALUES (@userId, @username, @password, @email, 'Student', @lang, 'Active')";

            using (SqlCommand cmd = new SqlCommand(sql, conn, txn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                cmd.Parameters.AddWithValue("@username", username);
                cmd.Parameters.AddWithValue("@password", hashedPassword);
                cmd.Parameters.AddWithValue("@email", email);
                cmd.Parameters.AddWithValue("@lang", language);
                cmd.ExecuteNonQuery();
            }
        }

        private void InsertStudentRow(SqlConnection conn, SqlTransaction txn,
            string studentId, string userId, string name, string phone, string nickname, string parentCode)
        {
            string sql = @"INSERT INTO dbo.[Student]
                (studentId, userId, name, phoneNumber, nickname, currentLevelId, XP, personalityId, parentCode)
                VALUES (@studentId, @userId, @name, @phone, @nickname, 'LV001', 0, NULL, @parentCode)";

            using (SqlCommand cmd = new SqlCommand(sql, conn, txn))
            {
                cmd.Parameters.AddWithValue("@studentId", studentId);
                cmd.Parameters.AddWithValue("@userId", userId);
                cmd.Parameters.AddWithValue("@name", name);
                cmd.Parameters.AddWithValue("@phone", phone);
                cmd.Parameters.AddWithValue("@nickname", nickname);
                cmd.Parameters.AddWithValue("@parentCode", parentCode);
                cmd.ExecuteNonQuery();
            }
        }

        private void SendWelcomeNotification(SqlConnection conn, SqlTransaction txn, string userId)
        {
            string notifId = GenerateNextId(conn, txn, "Notification", "notificationId", "N");

            string sql = @"INSERT INTO dbo.[Notification]
                (notificationId, toUserId, titleEN, titleBM, messageEN, messageBM, isRead, createdAt)
                VALUES (@id, @userId,
                    'Welcome to ScienceBuddy', 'Selamat Datang ke ScienceBuddy',
                    'Start your first science lesson and begin exploring.',
                    'Mulakan pelajaran Sains pertama anda dan mula meneroka.',
                    0, @createdAt)";

            using (SqlCommand cmd = new SqlCommand(sql, conn, txn))
            {
                cmd.Parameters.AddWithValue("@id", notifId);
                cmd.Parameters.AddWithValue("@userId", userId);
                cmd.Parameters.AddWithValue("@createdAt", DateTime.Now);
                cmd.ExecuteNonQuery();
            }
        }

        // ────────────────────────────────────────────────────────
        //  VALIDATION HELPERS
        // ────────────────────────────────────────────────────────

        /// <summary>
        /// Checks if a username or email is already registered.
        /// </summary>
        private bool IsValueTaken(SqlConnection conn, string columnName, string value)
        {
            // columnName is always a trusted string from our own code, not from user input
            string sql = "SELECT COUNT(*) FROM dbo.[User] WHERE " + columnName + " = @value";

            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@value", value);
                return (int)cmd.ExecuteScalar() > 0;
            }
        }

        /// <summary>
        /// Reads the minimum password length from the ConfigurationSetting table.
        /// Falls back to 8 if the setting is missing or unreadable.
        /// </summary>
        private int GetMinimumPasswordLength()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(ConnectionString))
                {
                    string sql = "SELECT configValue FROM dbo.[ConfigurationSetting] WHERE configKey = 'Password Minimum Length'";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        conn.Open();
                        object result = cmd.ExecuteScalar();

                        if (result != null && result != DBNull.Value && int.TryParse(result.ToString(), out int length))
                            return length;
                    }
                }
            }
            catch { }

            return 8; // sensible default
        }

        // ────────────────────────────────────────────────────────
        //  ID GENERATION
        // ────────────────────────────────────────────────────────

        /// <summary>
        /// Generates the next sequential ID for a table (e.g. U001, U002, S001, S002).
        /// Reads the highest existing ID and increments the numeric portion by 1.
        /// </summary>
        private string GenerateNextId(SqlConnection conn, SqlTransaction txn, string tableName, string idColumn, string prefix)
        {
            int nextNumber = 1;

            string sql = "SELECT TOP 1 [" + idColumn + "] FROM dbo.[" + tableName + "] ORDER BY [" + idColumn + "] DESC";

            using (SqlCommand cmd = new SqlCommand(sql, conn, txn))
            {
                object result = cmd.ExecuteScalar();

                if (result != null && result != DBNull.Value)
                {
                    string lastId = result.ToString();
                    string numericPart = lastId.Substring(prefix.Length);

                    if (int.TryParse(numericPart, out int lastNumber))
                        nextNumber = lastNumber + 1;
                }
            }

            return prefix + nextNumber.ToString("D3");
        }

        /// <summary>
        /// Creates a random 6-character alphanumeric code for linking parent accounts.
        /// Avoids ambiguous characters (0, O, 1, I, L) so parents can read it easily.
        /// Retries up to 20 times to ensure uniqueness.
        /// </summary>
        private string GenerateUniqueParentCode(SqlConnection conn, SqlTransaction txn)
        {
            const string allowedCharacters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
            Random random = new Random();

            for (int attempt = 0; attempt < 20; attempt++)
            {
                char[] codeChars = new char[6];
                for (int i = 0; i < 6; i++)
                    codeChars[i] = allowedCharacters[random.Next(allowedCharacters.Length)];

                string candidateCode = new string(codeChars);

                // Make sure no other student already has this code
                using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[Student] WHERE parentCode = @code", conn, txn))
                {
                    cmd.Parameters.AddWithValue("@code", candidateCode);
                    if ((int)cmd.ExecuteScalar() == 0)
                        return candidateCode;
                }
            }

            // Extremely unlikely fallback
            return Guid.NewGuid().ToString("N").Substring(0, 6).ToUpper();
        }

        // ────────────────────────────────────────────────────────
        //  UI FEEDBACK
        // ────────────────────────────────────────────────────────

        private void ShowError(string message)
        {
            pnlError.Visible = true;
            litError.Text = Server.HtmlEncode(message);
        }
    }
}
