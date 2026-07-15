using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace ScienceBuddy
{
    public partial class StudentRegistration : Page
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
            string nickname = txtNickname.Text.Trim();
            string username = txtUsername.Text.Trim();
            string email = txtEmail.Text.Trim().ToLower();
            string phone = txtPhone.Text.Trim();
            string password = txtPassword.Text;

            int minLen = GetMinPasswordLength();
            if (password.Length < minLen) { ShowError("Password must be at least " + minLen + " characters."); return; }

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    if (Exists(conn, "SELECT COUNT(*) FROM dbo.[User] WHERE username=@v", username)) { ShowError("Username already exists."); return; }
                    if (Exists(conn, "SELECT COUNT(*) FROM dbo.[User] WHERE email=@v", email)) { ShowError("Email already exists."); return; }

                    using (var txn = conn.BeginTransaction())
                    {
                        try
                        {
                            string userId = GenId(conn, txn, "User", "userId", "U");
                            string studentId = GenId(conn, txn, "Student", "studentId", "S");
                            string parentCode = GenerateParentCode(conn, txn);
                            string lang = ddlLanguage.SelectedValue;

                            using (var cmd = new SqlCommand("INSERT INTO dbo.[User](userId,username,password,email,role,preferredLanguage,status) VALUES(@id,@u,@p,@e,'Student',@l,'Active')", conn, txn))
                            { cmd.Parameters.AddWithValue("@id", userId); cmd.Parameters.AddWithValue("@u", username); cmd.Parameters.AddWithValue("@p", PasswordHelper.HashPassword(password)); cmd.Parameters.AddWithValue("@e", email); cmd.Parameters.AddWithValue("@l", lang); cmd.ExecuteNonQuery(); }

                            using (var cmd = new SqlCommand("INSERT INTO dbo.[Student](studentId,userId,name,phoneNumber,nickname,currentLevelId,XP,personalityId,parentCode) VALUES(@id,@uid,@n,@ph,@nick,'LV001',0,NULL,@pc)", conn, txn))
                            { cmd.Parameters.AddWithValue("@id", studentId); cmd.Parameters.AddWithValue("@uid", userId); cmd.Parameters.AddWithValue("@n", name); cmd.Parameters.AddWithValue("@ph", phone); cmd.Parameters.AddWithValue("@nick", nickname); cmd.Parameters.AddWithValue("@pc", parentCode); cmd.ExecuteNonQuery(); }

                            // Welcome notification
                            string nid = GenId(conn, txn, "Notification", "notificationId", "N");
                            using (var cmd = new SqlCommand("INSERT INTO dbo.[Notification](notificationId,toUserId,titleEN,titleBM,messageEN,messageBM,isRead,createdAt) VALUES(@id,@uid,'Welcome to ScienceBuddy','Selamat Datang ke ScienceBuddy','Start your first science lesson and begin exploring.','Mulakan pelajaran Sains pertama anda dan mula meneroka.',0,@now)", conn, txn))
                            { cmd.Parameters.AddWithValue("@id", nid); cmd.Parameters.AddWithValue("@uid", userId); cmd.Parameters.AddWithValue("@now", DateTime.Now); cmd.ExecuteNonQuery(); }

                            txn.Commit();
                            pnlForm.Visible = false; pnlSuccess.Visible = true;
                        }
                        catch { txn.Rollback(); throw; }
                    }
                }
            }
            catch (Exception) { ShowError("Registration failed. Please try again."); }
        }

        private string GenerateParentCode(SqlConnection conn, SqlTransaction txn)
        {
            const string chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
            var rng = new Random();
            for (int attempt = 0; attempt < 20; attempt++)
            {
                var code = new char[6];
                for (int i = 0; i < 6; i++) code[i] = chars[rng.Next(chars.Length)];
                string result = new string(code);
                using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[Student] WHERE parentCode=@c", conn, txn))
                { cmd.Parameters.AddWithValue("@c", result); if ((int)cmd.ExecuteScalar() == 0) return result; }
            }
            return Guid.NewGuid().ToString("N").Substring(0, 6).ToUpper();
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
