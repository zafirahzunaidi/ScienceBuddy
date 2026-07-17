using System;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.UI;

namespace ScienceBuddy
{
    public partial class TeacherRegistration : Page
    {
        private string ConnectionString
        {
            get { return ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
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

            // Collect form inputs
            string fullName = txtName.Text.Trim();
            string username = txtUsername.Text.Trim();
            string email = txtEmail.Text.Trim().ToLower();
            string phone = txtPhone.Text.Trim();
            string qualification = txtQualification.Text.Trim();
            string bio = txtBio.Text.Trim();
            string password = txtPassword.Text;
            string preferredLanguage = ddlLanguage.SelectedValue;

            // Server-side password length validation
            int minimumLength = GetMinimumPasswordLength();
            if (password.Length < minimumLength)
            {
                ShowError("Password must be at least " + minimumLength + " characters.");
                return;
            }

            // Certificate upload validation
            if (!ValidateCertificateUpload())
                return;

            string savedFilePath = null;

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnectionString))
                {
                    conn.Open();

                    // Check username availability
                    if (IsUsernameTaken(conn, username))
                    {
                        ShowError("Username already exists.");
                        return;
                    }

                    // For teachers, check email with detailed status messages
                    string existingStatus = CheckExistingTeacherEmail(conn, email);
                    if (existingStatus != null)
                    {
                        ShowExistingAccountError(existingStatus);
                        return;
                    }

                    using (SqlTransaction txn = conn.BeginTransaction())
                    {
                        try
                        {
                            string newUserId = GenerateNextId(conn, txn, "User", "userId", "U");
                            string newTeacherId = GenerateNextId(conn, txn, "Teacher", "teacherId", "T");
                            string hashedPassword = PasswordHelper.HashPassword(password);

                            // Save the uploaded certificate to the server
                            savedFilePath = SaveCertificateFile(newTeacherId);
                            string relativeCertPath = "Uploads/TeacherCertificates/" + Path.GetFileName(savedFilePath);

                            InsertUserRow(conn, txn, newUserId, username, hashedPassword, email, preferredLanguage);
                            InsertTeacherRow(conn, txn, newTeacherId, newUserId, fullName, phone, qualification, bio, relativeCertPath);
                            LogRegistrationAction(conn, txn, newUserId, fullName, email);

                            txn.Commit();

                            // Redirect to status page so the teacher knows to wait for admin approval
                            Session["TeacherStatusUserId"] = newUserId;
                            Response.Redirect("~/TeacherRegistrationStatus.aspx", false);
                            Context.ApplicationInstance.CompleteRequest();
                        }
                        catch
                        {
                            txn.Rollback();
                            CleanUpFailedUpload(savedFilePath);
                            throw;
                        }
                    }
                }
            }
            catch (Exception)
            {
                CleanUpFailedUpload(savedFilePath);
                ShowError("Registration failed. Please try again.");
            }
        }

        // ────────────────────────────────────────────────────────
        //  CERTIFICATE UPLOAD
        // ────────────────────────────────────────────────────────

        /// <summary>
        /// Validates the uploaded certificate file. Only PDF, max 5MB.
        /// </summary>
        private bool ValidateCertificateUpload()
        {
            if (!fuCertificate.HasFile)
            {
                ShowError("Please upload your teaching certificate.");
                return false;
            }

            string extension = Path.GetExtension(fuCertificate.FileName).ToLower();
            if (extension != ".pdf")
            {
                ShowError("Only PDF files are accepted for the teaching certificate.");
                return false;
            }

            // 5MB limit
            if (fuCertificate.PostedFile.ContentLength > 5 * 1024 * 1024)
            {
                ShowError("Certificate file must not exceed 5MB.");
                return false;
            }

            return true;
        }

        /// <summary>
        /// Saves the uploaded PDF to ~/Uploads/TeacherCertificates/ with a unique filename.
        /// </summary>
        private string SaveCertificateFile(string teacherId)
        {
            string timestamp = DateTime.Now.ToString("yyyyMMddHHmmss");
            string fileName = "cert_" + teacherId + "_" + timestamp + ".pdf";

            string folderPath = Server.MapPath("~/Uploads/TeacherCertificates/");
            if (!Directory.Exists(folderPath))
                Directory.CreateDirectory(folderPath);

            string fullPath = Path.Combine(folderPath, fileName);
            fuCertificate.SaveAs(fullPath);
            return fullPath;
        }

        /// <summary>
        /// Removes the uploaded file if the database transaction fails.
        /// </summary>
        private void CleanUpFailedUpload(string filePath)
        {
            if (!string.IsNullOrEmpty(filePath) && File.Exists(filePath))
            {
                try { File.Delete(filePath); }
                catch { } // best-effort cleanup
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
                VALUES (@userId, @username, @password, @email, 'Teacher', @lang, 'Active')";

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

        private void InsertTeacherRow(SqlConnection conn, SqlTransaction txn,
            string teacherId, string userId, string name, string phone,
            string qualification, string bio, string certPath)
        {
            string sql = @"INSERT INTO dbo.[Teacher]
                (teacherId, userId, name, phoneNumber, qualification, bio, status, approvedDate, licenseCert)
                VALUES (@teacherId, @userId, @name, @phone, @qualification, @bio, 'Pending', NULL, @certPath)";

            using (SqlCommand cmd = new SqlCommand(sql, conn, txn))
            {
                cmd.Parameters.AddWithValue("@teacherId", teacherId);
                cmd.Parameters.AddWithValue("@userId", userId);
                cmd.Parameters.AddWithValue("@name", name);
                cmd.Parameters.AddWithValue("@phone", phone);
                cmd.Parameters.AddWithValue("@qualification", qualification);
                cmd.Parameters.AddWithValue("@bio", bio);
                cmd.Parameters.AddWithValue("@certPath", certPath);
                cmd.ExecuteNonQuery();
            }
        }

        private void LogRegistrationAction(SqlConnection conn, SqlTransaction txn,
            string userId, string teacherName, string email)
        {
            string logId = GenerateNextId(conn, txn, "Log", "logId", "LG");

            string sql = @"INSERT INTO dbo.[Log]
                (logId, userId, action, description, createdAt)
                VALUES (@logId, @userId, @action, @description, @createdAt)";

            using (SqlCommand cmd = new SqlCommand(sql, conn, txn))
            {
                cmd.Parameters.AddWithValue("@logId", logId);
                cmd.Parameters.AddWithValue("@userId", userId);
                cmd.Parameters.AddWithValue("@action", "Teacher Registration Submitted");
                cmd.Parameters.AddWithValue("@description", "Teacher registration submitted for " + teacherName + " (" + email + ")");
                cmd.Parameters.AddWithValue("@createdAt", DateTime.Now);
                cmd.ExecuteNonQuery();
            }
        }

        // ────────────────────────────────────────────────────────
        //  DUPLICATE EMAIL CHECK (Teacher-specific)
        // ────────────────────────────────────────────────────────

        /// <summary>
        /// Checks if an email is already used by a Teacher account.
        /// Returns the status string or null if the email is available.
        /// Teachers get specific messages based on their certification state.
        /// </summary>
        private string CheckExistingTeacherEmail(SqlConnection conn, string email)
        {
            string sql = @"SELECT u.status, t.status
                FROM dbo.[User] u
                LEFT JOIN dbo.[Teacher] t ON u.userId = t.userId
                WHERE u.email = @email";

            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@email", email);
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (!reader.Read())
                        return null; // email not in use

                    string userStatus = reader.IsDBNull(0) ? null : reader.GetString(0);
                    string teacherStatus = reader.IsDBNull(1) ? null : reader.GetString(1);

                    if (userStatus == "Deleted") return "Deleted";
                    if (userStatus == "Blocked") return "Blocked";
                    if (teacherStatus == "Pending") return "Pending";
                    if (teacherStatus == "Certified") return "Certified";
                    if (teacherStatus == "Not Certified") return "Not Certified";

                    return userStatus ?? "Exists";
                }
            }
        }

        /// <summary>
        /// Shows the appropriate error message based on the existing account's status.
        /// </summary>
        private void ShowExistingAccountError(string status)
        {
            switch (status)
            {
                case "Pending":
                    ShowError("An account with this email is already pending approval. Please wait for the admin to review your certificate.");
                    break;
                case "Certified":
                    ShowError("An account with this email is already certified. Please sign in instead.");
                    break;
                case "Not Certified":
                    ShowError("An account with this email was not certified. Please contact support for assistance.");
                    break;
                case "Blocked":
                    ShowError("An account with this email has been blocked. Please contact support for more information.");
                    break;
                case "Deleted":
                    ShowError("An account with this email has been removed. Please contact support if you wish to re-register.");
                    break;
                default:
                    ShowError("An account with this email already exists. Please sign in or use a different email.");
                    break;
            }
        }

        // ────────────────────────────────────────────────────────
        //  VALIDATION HELPERS
        // ────────────────────────────────────────────────────────

        private bool IsUsernameTaken(SqlConnection conn, string username)
        {
            using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[User] WHERE username = @val", conn))
            {
                cmd.Parameters.AddWithValue("@val", username);
                return (int)cmd.ExecuteScalar() > 0;
            }
        }

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

            return 8;
        }

        // ────────────────────────────────────────────────────────
        //  ID GENERATION
        // ────────────────────────────────────────────────────────

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

        // ────────────────────────────────────────────────────────
        //  UI FEEDBACK
        // ────────────────────────────────────────────────────────

        private void ShowError(string message)
        {
            pnlError.Visible = true;
            litError.Text = HttpUtility.HtmlEncode(message);
        }
    }
}
