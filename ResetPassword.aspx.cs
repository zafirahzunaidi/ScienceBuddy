using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web.UI;

namespace ScienceBuddy
{
    public partial class ResetPassword : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        private string _userId;

        protected void Page_Load(object sender, EventArgs e)
        {
            ((SiteMaster)Master).LayoutMode = "TopNav";

            if (!IsPostBack)
            {
                if (!ValidateToken())
                {
                    pnlForm.Visible = false;
                    pnlInvalid.Visible = true;
                }
            }
        }

        private bool ValidateToken()
        {
            string rawToken = Request.QueryString["token"];
            if (string.IsNullOrWhiteSpace(rawToken)) return false;

            string tokenHash = ComputeSHA256(rawToken);

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(@"SELECT t.userId, t.expiresAt, t.usedAt, u.status
                    FROM dbo.[PasswordResetToken] t
                    INNER JOIN dbo.[User] u ON t.userId = u.userId
                    WHERE t.tokenHash = @hash", conn))
                {
                    cmd.Parameters.AddWithValue("@hash", tokenHash);
                    conn.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        if (!r.Read()) return false;
                        if (r["usedAt"] != DBNull.Value) return false;
                        DateTime expires = Convert.ToDateTime(r["expiresAt"]);
                        if (DateTime.Now > expires) return false;
                        string userStatus = r["status"].ToString();
                        if (userStatus != "Active") return false;
                        _userId = r["userId"].ToString();
                        ViewState["ResetUserId"] = _userId;
                        ViewState["TokenHash"] = tokenHash;
                        return true;
                    }
                }
            }
            catch { return false; }
        }

        protected void BtnReset_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string userId = ViewState["ResetUserId"] as string;
            string tokenHash = ViewState["TokenHash"] as string;
            if (string.IsNullOrEmpty(userId) || string.IsNullOrEmpty(tokenHash))
            {
                pnlForm.Visible = false;
                pnlInvalid.Visible = true;
                return;
            }

            string password = txtPassword.Text;
            int minLen = GetMinPasswordLength();
            if (password.Length < minLen)
            {
                ShowError("Password must be at least " + minLen + " characters.");
                return;
            }

            try
            {
                string hashedPassword = PasswordHelper.HashPassword(password);

                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // Re-validate token (prevent race condition)
                    using (var chk = new SqlCommand("SELECT COUNT(*) FROM dbo.[PasswordResetToken] WHERE tokenHash=@hash AND usedAt IS NULL AND expiresAt > @now", conn))
                    {
                        chk.Parameters.AddWithValue("@hash", tokenHash);
                        chk.Parameters.AddWithValue("@now", DateTime.Now);
                        if ((int)chk.ExecuteScalar() == 0)
                        {
                            pnlForm.Visible = false; pnlInvalid.Visible = true; return;
                        }
                    }

                    using (var txn = conn.BeginTransaction())
                    {
                        try
                        {
                            // Update password
                            using (var cmd = new SqlCommand("UPDATE dbo.[User] SET [password]=@pwd WHERE userId=@uid", conn, txn))
                            { cmd.Parameters.AddWithValue("@pwd", hashedPassword); cmd.Parameters.AddWithValue("@uid", userId); cmd.ExecuteNonQuery(); }

                            // Mark token as used
                            using (var cmd = new SqlCommand("UPDATE dbo.[PasswordResetToken] SET usedAt=@now WHERE tokenHash=@hash", conn, txn))
                            { cmd.Parameters.AddWithValue("@now", DateTime.Now); cmd.Parameters.AddWithValue("@hash", tokenHash); cmd.ExecuteNonQuery(); }

                            // Invalidate other unused tokens for this user
                            using (var cmd = new SqlCommand("UPDATE dbo.[PasswordResetToken] SET usedAt=@now WHERE userId=@uid AND usedAt IS NULL", conn, txn))
                            { cmd.Parameters.AddWithValue("@now", DateTime.Now); cmd.Parameters.AddWithValue("@uid", userId); cmd.ExecuteNonQuery(); }

                            txn.Commit();
                            pnlForm.Visible = false;
                            pnlSuccess.Visible = true;
                        }
                        catch { txn.Rollback(); throw; }
                    }
                }
            }
            catch { ShowError("An error occurred. Please try again."); }
        }

        private int GetMinPasswordLength()
        {
            try
            {
                using (var c = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT configValue FROM dbo.[ConfigurationSetting] WHERE configKey='Password Minimum Length'", c))
                { c.Open(); var r = cmd.ExecuteScalar(); if (r != null && r != DBNull.Value && int.TryParse(r.ToString(), out int v)) return v; }
            }
            catch { }
            return 8;
        }

        private static string ComputeSHA256(string input)
        {
            using (var sha = SHA256.Create())
            {
                byte[] bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(input));
                var sb = new StringBuilder(64);
                foreach (byte b in bytes) sb.Append(b.ToString("x2"));
                return sb.ToString();
            }
        }

        private void ShowError(string msg)
        {
            pnlError.Visible = true;
            litError.Text = System.Web.HttpUtility.HtmlEncode(msg);
        }
    }
}
