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
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] != null && Session["role"] != null)
            { Response.Redirect("~/", false); Context.ApplicationInstance.CompleteRequest(); return; }
            ((SiteMaster)Master).LayoutMode = "TopNav";
        }

        protected void BtnRegister_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            string name = txtName.Text.Trim();
            string username = txtUsername.Text.Trim();
            string email = txtEmail.Text.Trim().ToLower();
            string phone = txtPhone.Text.Trim();
            string qualification = txtQualification.Text.Trim();
            string bio = txtBio.Text.Trim();
            string password = txtPassword.Text;

            int minLen = GetMinPasswordLength();
            if (password.Length < minLen) { ShowError("Password must be at least " + minLen + " characters."); return; }

            // Validate certificate file
            if (!fuCertificate.HasFile)
            { ShowError("Please upload your teaching certificate."); return; }

            string ext = Path.GetExtension(fuCertificate.FileName).ToLower();
            if (ext != ".pdf")
            { ShowError("Only PDF files are accepted for the teaching certificate."); return; }

            if (fuCertificate.PostedFile.ContentLength > 5 * 1024 * 1024)
            { ShowError("Certificate file must not exceed 5MB."); return; }

            string savedFilePath = null;

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    if (Exists(conn, "SELECT COUNT(*) FROM dbo.[User] WHERE username=@v", username)) { ShowError("Username already exists."); return; }

                    // Check existing email with teacher-specific messages
                    string existingStatus = GetExistingTeacherStatus(conn, email);
                    if (existingStatus != null)
                    {
                        switch (existingStatus)
                        {
                            case "Pending":
                                ShowError("An account with this email is already pending approval. Please wait for the admin to review your certificate.");
                                return;
                            case "Certified":
                                ShowError("An account with this email is already certified. Please sign in instead.");
                                return;
                            case "Not Certified":
                                ShowError("An account with this email was not certified. Please contact support for assistance.");
                                return;
                            case "Blocked":
                                ShowError("An account with this email has been blocked. Please contact support for more information.");
                                return;
                            case "Deleted":
                                ShowError("An account with this email has been removed. Please contact support if you wish to re-register.");
                                return;
                            default:
                                ShowError("An account with this email already exists. Please sign in or use a different email.");
                                return;
                        }
                    }

                    using (var txn = conn.BeginTransaction())
                    {
                        try
                        {
                            string userId = GenId(conn, txn, "User", "userId", "U");
                            string teacherId = GenId(conn, txn, "Teacher", "teacherId", "T");
                            string lang = ddlLanguage.SelectedValue;

                            // Save certificate file
                            string timestamp = DateTime.Now.ToString("yyyyMMddHHmmss");
                            string certFileName = $"cert_{teacherId}_{timestamp}.pdf";
                            string certFolder = Server.MapPath("~/Uploads/TeacherCertificates/");
                            if (!Directory.Exists(certFolder)) Directory.CreateDirectory(certFolder);
                            savedFilePath = Path.Combine(certFolder, certFileName);
                            fuCertificate.SaveAs(savedFilePath);
                            string relativePath = "Uploads/TeacherCertificates/" + certFileName;

                            // Insert User
                            using (var cmd = new SqlCommand("INSERT INTO dbo.[User](userId,username,password,email,role,preferredLanguage,status) VALUES(@id,@u,@p,@e,'Teacher',@l,'Active')", conn, txn))
                            {
                                cmd.Parameters.AddWithValue("@id", userId);
                                cmd.Parameters.AddWithValue("@u", username);
                                cmd.Parameters.AddWithValue("@p", PasswordHelper.HashPassword(password));
                                cmd.Parameters.AddWithValue("@e", email);
                                cmd.Parameters.AddWithValue("@l", lang);
                                cmd.ExecuteNonQuery();
                            }

                            // Insert Teacher
                            using (var cmd = new SqlCommand("INSERT INTO dbo.[Teacher](teacherId,userId,name,phoneNumber,qualification,bio,status,approvedDate,licenseCert) VALUES(@id,@uid,@n,@ph,@q,@bio,'Pending',NULL,@cert)", conn, txn))
                            {
                                cmd.Parameters.AddWithValue("@id", teacherId);
                                cmd.Parameters.AddWithValue("@uid", userId);
                                cmd.Parameters.AddWithValue("@n", name);
                                cmd.Parameters.AddWithValue("@ph", phone);
                                cmd.Parameters.AddWithValue("@q", qualification);
                                cmd.Parameters.AddWithValue("@bio", bio);
                                cmd.Parameters.AddWithValue("@cert", relativePath);
                                cmd.ExecuteNonQuery();
                            }

                            // Insert Log entry
                            string logId = GenId(conn, txn, "Log", "logId", "LG");
                            using (var cmd = new SqlCommand("INSERT INTO dbo.[Log](logId,userId,action,description,createdAt) VALUES(@id,@uid,@act,@desc,@now)", conn, txn))
                            {
                                cmd.Parameters.AddWithValue("@id", logId);
                                cmd.Parameters.AddWithValue("@uid", userId);
                                cmd.Parameters.AddWithValue("@act", "Teacher Registration Submitted");
                                cmd.Parameters.AddWithValue("@desc", "Teacher registration submitted for " + name + " (" + email + ")");
                                cmd.Parameters.AddWithValue("@now", DateTime.Now);
                                cmd.ExecuteNonQuery();
                            }

                            txn.Commit();

                            // Redirect to status page
                            Session["TeacherStatusUserId"] = userId;
                            Response.Redirect("~/TeacherRegistrationStatus.aspx", false);
                            Context.ApplicationInstance.CompleteRequest();
                        }
                        catch
                        {
                            txn.Rollback();
                            // Remove staged file on failure
                            if (savedFilePath != null && File.Exists(savedFilePath))
                                try { File.Delete(savedFilePath); } catch { }
                            throw;
                        }
                    }
                }
            }
            catch (Exception)
            {
                // Remove staged file on failure
                if (savedFilePath != null && File.Exists(savedFilePath))
                    try { File.Delete(savedFilePath); } catch { }
                ShowError("Registration failed. Please try again.");
            }
        }

        private string GetExistingTeacherStatus(SqlConnection conn, string email)
        {
            using (var cmd = new SqlCommand("SELECT u.status, t.status FROM dbo.[User] u LEFT JOIN dbo.[Teacher] t ON u.userId=t.userId WHERE u.email=@e", conn))
            {
                cmd.Parameters.AddWithValue("@e", email);
                using (var reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        string userStatus = reader.IsDBNull(0) ? null : reader.GetString(0);
                        string teacherStatus = reader.IsDBNull(1) ? null : reader.GetString(1);

                        if (userStatus == "Deleted") return "Deleted";
                        if (userStatus == "Blocked") return "Blocked";
                        if (teacherStatus == "Pending") return "Pending";
                        if (teacherStatus == "Certified") return "Certified";
                        if (teacherStatus == "Not Certified") return "Not Certified";
                        return userStatus; // fallback
                    }
                }
            }
            return null;
        }

        private string GenId(SqlConnection c, SqlTransaction t, string table, string col, string prefix)
        { int n = 1; using (var cmd = new SqlCommand($"SELECT TOP 1 [{col}] FROM dbo.[{table}] ORDER BY [{col}] DESC", c, t)) { var r = cmd.ExecuteScalar(); if (r != null && r != DBNull.Value) { string last = r.ToString(); if (last.Length > prefix.Length && int.TryParse(last.Substring(prefix.Length), out int num)) n = num + 1; } } return prefix + n.ToString("D3"); }

        private bool Exists(SqlConnection c, string sql, string val)
        { using (var cmd = new SqlCommand(sql, c)) { cmd.Parameters.AddWithValue("@v", val); return (int)cmd.ExecuteScalar() > 0; } }

        private int GetMinPasswordLength()
        { try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT configValue FROM dbo.[ConfigurationSetting] WHERE configKey='Password Minimum Length'", c)) { c.Open(); var r = cmd.ExecuteScalar(); if (r != null && r != DBNull.Value && int.TryParse(r.ToString(), out int v)) return v; } } catch { } return 8; }

        private void ShowError(string msg) { pnlError.Visible = true; litError.Text = HttpUtility.HtmlEncode(msg); }
    }
}
