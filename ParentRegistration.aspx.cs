using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace ScienceBuddy
{
    public partial class ParentRegistration : Page
    {
        private string ConnectionString
        {
            get { return ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // Redirect to home if user is already logged in
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
            string password = txtPassword.Text;
            string parentCode = txtParentCode.Text.Trim().ToUpper();
            string relationship = ddlRelationship.SelectedValue;
            string preferredLanguage = ddlLanguage.SelectedValue;

            // Validate password length against database configuration
            int minimumLength = GetMinimumPasswordLength();
            if (password.Length < minimumLength)
            {
                ShowError("Password must be at least " + minimumLength + " characters.");
                return;
            }

            // If parent code is entered, a relationship must also be selected
            if (!string.IsNullOrEmpty(parentCode) && string.IsNullOrEmpty(relationship))
            {
                ShowError("Please select a relationship when entering a Parent Code.");
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnectionString))
                {
                    conn.Open();

                    // Check for duplicates
                    if (IsUsernameTaken(conn, username))
                    {
                        ShowError("Username already exists.");
                        return;
                    }
                    if (IsEmailTaken(conn, email))
                    {
                        ShowError("Email already exists.");
                        return;
                    }

                    // If a parent code was entered, verify it exists and find the child
                    string linkedStudentId = null;
                    if (!string.IsNullOrEmpty(parentCode))
                    {
                        linkedStudentId = FindStudentByParentCode(conn, parentCode);
                        if (linkedStudentId == null)
                        {
                            ShowError("Invalid Parent Code. Please check with your child.");
                            return;
                        }
                    }

                    // Create User + Parent rows in a transaction
                    using (SqlTransaction txn = conn.BeginTransaction())
                    {
                        try
                        {
                            string newUserId = GenerateNextId(conn, txn, "User", "userId", "U");
                            string newParentId = GenerateNextId(conn, txn, "Parent", "parentId", "P");
                            string hashedPassword = PasswordHelper.HashPassword(password);

                            InsertUserRow(conn, txn, newUserId, username, hashedPassword, email, preferredLanguage);
                            InsertParentRow(conn, txn, newParentId, newUserId, fullName, phone);

                            // Link the child account if a valid parent code was provided
                            if (!string.IsNullOrEmpty(linkedStudentId))
                                LinkChildToParent(conn, txn, linkedStudentId, newParentId, relationship);

                            SendWelcomeNotification(conn, txn, newUserId);

                            txn.Commit();

                            // Show success message
                            pnlForm.Visible = false;
                            pnlSuccess.Visible = true;

                            if (!string.IsNullOrEmpty(linkedStudentId))
                                litSuccessMsg.Text = "Your account has been created and your child has been linked successfully. Sign in to begin supporting their learning journey.";
                            else
                                litSuccessMsg.Text = "Your account has been created successfully. Sign in to link your child and begin supporting their learning journey.";
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
                VALUES (@userId, @username, @password, @email, 'Parent', @lang, 'Active')";

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

        private void InsertParentRow(SqlConnection conn, SqlTransaction txn,
            string parentId, string userId, string name, string phone)
        {
            string sql = @"INSERT INTO dbo.[Parent]
                (parentId, userId, name, phoneNumber)
                VALUES (@parentId, @userId, @name, @phone)";

            using (SqlCommand cmd = new SqlCommand(sql, conn, txn))
            {
                cmd.Parameters.AddWithValue("@parentId", parentId);
                cmd.Parameters.AddWithValue("@userId", userId);
                cmd.Parameters.AddWithValue("@name", name);
                cmd.Parameters.AddWithValue("@phone", phone);
                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Links the child (student) to the new parent account via the StudentParent table.
        /// Skips if the link already exists (e.g. same child linked twice).
        /// </summary>
        private void LinkChildToParent(SqlConnection conn, SqlTransaction txn,
            string studentId, string parentId, string relationship)
        {
            // Prevent duplicate links
            using (SqlCommand checkCmd = new SqlCommand(
                "SELECT COUNT(*) FROM dbo.[StudentParent] WHERE studentId = @sid AND parentId = @pid", conn, txn))
            {
                checkCmd.Parameters.AddWithValue("@sid", studentId);
                checkCmd.Parameters.AddWithValue("@pid", parentId);
                if ((int)checkCmd.ExecuteScalar() > 0)
                    return; // already linked
            }

            string linkId = GenerateNextId(conn, txn, "StudentParent", "studentParentId", "SP");

            string sql = @"INSERT INTO dbo.[StudentParent]
                (studentParentId, studentId, parentId, relationship)
                VALUES (@id, @studentId, @parentId, @relationship)";

            using (SqlCommand cmd = new SqlCommand(sql, conn, txn))
            {
                cmd.Parameters.AddWithValue("@id", linkId);
                cmd.Parameters.AddWithValue("@studentId", studentId);
                cmd.Parameters.AddWithValue("@parentId", parentId);
                cmd.Parameters.AddWithValue("@relationship", relationship);
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
                    'Link your child account to start monitoring their progress.',
                    'Pautkan akaun anak anda untuk mula memantau kemajuan mereka.',
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

        private bool IsUsernameTaken(SqlConnection conn, string username)
        {
            using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[User] WHERE username = @val", conn))
            {
                cmd.Parameters.AddWithValue("@val", username);
                return (int)cmd.ExecuteScalar() > 0;
            }
        }

        private bool IsEmailTaken(SqlConnection conn, string email)
        {
            using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[User] WHERE email = @val", conn))
            {
                cmd.Parameters.AddWithValue("@val", email);
                return (int)cmd.ExecuteScalar() > 0;
            }
        }

        /// <summary>
        /// Looks up a student by their parent code. Returns the studentId or null if not found.
        /// </summary>
        private string FindStudentByParentCode(SqlConnection conn, string code)
        {
            using (SqlCommand cmd = new SqlCommand("SELECT studentId FROM dbo.[Student] WHERE parentCode = @code", conn))
            {
                cmd.Parameters.AddWithValue("@code", code);
                object result = cmd.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                    return result.ToString();
            }
            return null;
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
            litError.Text = Server.HtmlEncode(message);
        }
    }
}
