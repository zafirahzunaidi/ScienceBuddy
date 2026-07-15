using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace ScienceBuddy
{
    public partial class ParentRegistration : Page
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
            string password = txtPassword.Text;
            string parentCode = txtParentCode.Text.Trim().ToUpper();
            string relationship = ddlRelationship.SelectedValue;

            int minLen = GetMinPasswordLength();
            if (password.Length < minLen) { ShowError("Password must be at least " + minLen + " characters."); return; }

            // If parent code entered, relationship is required
            if (!string.IsNullOrEmpty(parentCode) && string.IsNullOrEmpty(relationship))
            { ShowError("Please select a relationship when entering a Parent Code."); return; }

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    if (Exists(conn, "SELECT COUNT(*) FROM dbo.[User] WHERE username=@v", username)) { ShowError("Username already exists."); return; }
                    if (Exists(conn, "SELECT COUNT(*) FROM dbo.[User] WHERE email=@v", email)) { ShowError("Email already exists."); return; }

                    // Validate parent code if provided
                    string linkedStudentId = null;
                    if (!string.IsNullOrEmpty(parentCode))
                    {
                        using (var cmd = new SqlCommand("SELECT studentId FROM dbo.[Student] WHERE parentCode=@c", conn))
                        {
                            cmd.Parameters.AddWithValue("@c", parentCode);
                            var r = cmd.ExecuteScalar();
                            if (r == null || r == DBNull.Value) { ShowError("Invalid Parent Code. Please check with your child."); return; }
                            linkedStudentId = r.ToString();
                        }
                    }

                    using (var txn = conn.BeginTransaction())
                    {
                        try
                        {
                            string userId = GenId(conn, txn, "User", "userId", "U");
                            string parentId = GenId(conn, txn, "Parent", "parentId", "P");
                            string lang = ddlLanguage.SelectedValue;

                            using (var cmd = new SqlCommand("INSERT INTO dbo.[User](userId,username,password,email,role,preferredLanguage,status) VALUES(@id,@u,@p,@e,'Parent',@l,'Active')", conn, txn))
                            { cmd.Parameters.AddWithValue("@id", userId); cmd.Parameters.AddWithValue("@u", username); cmd.Parameters.AddWithValue("@p", PasswordHelper.HashPassword(password)); cmd.Parameters.AddWithValue("@e", email); cmd.Parameters.AddWithValue("@l", lang); cmd.ExecuteNonQuery(); }

                            using (var cmd = new SqlCommand("INSERT INTO dbo.[Parent](parentId,userId,name,phoneNumber) VALUES(@id,@uid,@n,@ph)", conn, txn))
                            { cmd.Parameters.AddWithValue("@id", parentId); cmd.Parameters.AddWithValue("@uid", userId); cmd.Parameters.AddWithValue("@n", name); cmd.Parameters.AddWithValue("@ph", phone); cmd.ExecuteNonQuery(); }

                            // Link child if parent code was provided
                            if (!string.IsNullOrEmpty(linkedStudentId))
                            {
                                // Check duplicate link
                                bool alreadyLinked = false;
                                using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[StudentParent] WHERE studentId=@sid AND parentId=@pid", conn, txn))
                                { cmd.Parameters.AddWithValue("@sid", linkedStudentId); cmd.Parameters.AddWithValue("@pid", parentId); alreadyLinked = (int)cmd.ExecuteScalar() > 0; }

                                if (!alreadyLinked)
                                {
                                    string spId = GenId(conn, txn, "StudentParent", "studentParentId", "SP");
                                    using (var cmd = new SqlCommand("INSERT INTO dbo.[StudentParent](studentParentId,studentId,parentId,relationship) VALUES(@id,@sid,@pid,@rel)", conn, txn))
                                    { cmd.Parameters.AddWithValue("@id", spId); cmd.Parameters.AddWithValue("@sid", linkedStudentId); cmd.Parameters.AddWithValue("@pid", parentId); cmd.Parameters.AddWithValue("@rel", relationship); cmd.ExecuteNonQuery(); }
                                }
                            }

                            // Welcome notification
                            string nid = GenId(conn, txn, "Notification", "notificationId", "N");
                            using (var cmd = new SqlCommand("INSERT INTO dbo.[Notification](notificationId,toUserId,titleEN,titleBM,messageEN,messageBM,isRead,createdAt) VALUES(@id,@uid,'Welcome to ScienceBuddy','Selamat Datang ke ScienceBuddy','Link your child account to start monitoring their progress.','Pautkan akaun anak anda untuk mula memantau kemajuan mereka.',0,@now)", conn, txn))
                            { cmd.Parameters.AddWithValue("@id", nid); cmd.Parameters.AddWithValue("@uid", userId); cmd.Parameters.AddWithValue("@now", DateTime.Now); cmd.ExecuteNonQuery(); }

                            txn.Commit();
                            pnlForm.Visible = false; pnlSuccess.Visible = true;
                            litSuccessMsg.Text = !string.IsNullOrEmpty(linkedStudentId)
                                ? "Your account has been created and your child has been linked successfully. Sign in to begin supporting their learning journey."
                                : "Your account has been created successfully. Sign in to link your child and begin supporting their learning journey.";
                        }
                        catch { txn.Rollback(); throw; }
                    }
                }
            }
            catch (Exception) { ShowError("Registration failed. Please try again."); }
        }

        private string GenId(SqlConnection c, SqlTransaction t, string table, string col, string prefix)
        { int n = 1; using (var cmd = new SqlCommand($"SELECT TOP 1 [{col}] FROM dbo.[{table}] ORDER BY [{col}] DESC", c, t)) { var r = cmd.ExecuteScalar(); if (r != null && r != DBNull.Value) { string last = r.ToString(); if (last.Length > prefix.Length && int.TryParse(last.Substring(prefix.Length), out int num)) n = num + 1; } } return prefix + n.ToString("D3"); }

        private bool Exists(SqlConnection c, string sql, string val)
        { using (var cmd = new SqlCommand(sql, c)) { cmd.Parameters.AddWithValue("@v", val); return (int)cmd.ExecuteScalar() > 0; } }

        private int GetMinPasswordLength()
        { try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT configValue FROM dbo.[ConfigurationSetting] WHERE configKey='Password Minimum Length'", c)) { c.Open(); var r = cmd.ExecuteScalar(); if (r != null && r != DBNull.Value && int.TryParse(r.ToString(), out int v)) return v; } } catch { } return 8; }

        private void ShowError(string msg) { pnlError.Visible = true; litError.Text = System.Web.HttpUtility.HtmlEncode(msg); }
    }
}
