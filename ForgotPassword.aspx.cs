using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Net;
using System.Net.Mail;
using System.Security.Cryptography;
using System.Text;
using System.Web.UI;

namespace ScienceBuddy
{
    public partial class ForgotPassword : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        // Token expires after 20 minutes; users must wait 2 minutes between reset requests
        private const int TokenExpiryMinutes = 20;
        private const int ThrottleSeconds = 120;

        protected void Page_Load(object sender, EventArgs e)
        {
            ((SiteMaster)Master).LayoutMode = "TopNav";
        }

        protected void BtnSend_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            string identifier = txtIdentifier.Text.Trim();

            // Always show same generic message
            const string genericMsg = "If an account matches the information provided, a password reset link has been sent.";

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // Find user by username or email
                    string userId = null, email = null, status = null;
                    using (var cmd = new SqlCommand("SELECT userId, email, status FROM dbo.[User] WHERE username=@id OR email=@id", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", identifier);
                        using (var r = cmd.ExecuteReader())
                        {
                            if (r.Read())
                            {
                                userId = r["userId"].ToString();
                                email = r["email"].ToString();
                                status = r["status"].ToString();
                            }
                        }
                    }

                    // No account or ineligible — show generic message, do nothing
                    if (string.IsNullOrEmpty(userId) || status != "Active" || string.IsNullOrEmpty(email))
                    {
                        ShowStatus(genericMsg, true);
                        pnlForm.Visible = false;
                        return;
                    }

                    // Throttle: check if a token was created recently
                    using (var cmd = new SqlCommand("SELECT TOP 1 createdAt FROM dbo.[PasswordResetToken] WHERE userId=@uid AND usedAt IS NULL ORDER BY createdAt DESC", conn))
                    {
                        cmd.Parameters.AddWithValue("@uid", userId);
                        var lastCreated = cmd.ExecuteScalar();
                        if (lastCreated != null && lastCreated != DBNull.Value)
                        {
                            var lastTime = Convert.ToDateTime(lastCreated);
                            if ((DateTime.Now - lastTime).TotalSeconds < ThrottleSeconds)
                            {
                                ShowStatus(genericMsg, true);
                                pnlForm.Visible = false;
                                return;
                            }
                        }
                    }

                    // Generate secure token
                    byte[] tokenBytes = new byte[32];
                    using (var rng = RandomNumberGenerator.Create()) { rng.GetBytes(tokenBytes); }
                    string rawToken = Convert.ToBase64String(tokenBytes).Replace("+", "-").Replace("/", "_").TrimEnd('=');
                    string tokenHash = ComputeSHA256(rawToken);

                    using (var txn = conn.BeginTransaction())
                    {
                        try
                        {
                            // Invalidate previous unused tokens
                            using (var cmd = new SqlCommand("UPDATE dbo.[PasswordResetToken] SET usedAt=@now WHERE userId=@uid AND usedAt IS NULL", conn, txn))
                            { cmd.Parameters.AddWithValue("@now", DateTime.Now); cmd.Parameters.AddWithValue("@uid", userId); cmd.ExecuteNonQuery(); }

                            // Insert new token
                            string tokenId = GenId(conn, txn);
                            using (var cmd = new SqlCommand("INSERT INTO dbo.[PasswordResetToken](tokenId,userId,tokenHash,createdAt,expiresAt,usedAt) VALUES(@id,@uid,@hash,@created,@expires,NULL)", conn, txn))
                            {
                                cmd.Parameters.AddWithValue("@id", tokenId);
                                cmd.Parameters.AddWithValue("@uid", userId);
                                cmd.Parameters.AddWithValue("@hash", tokenHash);
                                cmd.Parameters.AddWithValue("@created", DateTime.Now);
                                cmd.Parameters.AddWithValue("@expires", DateTime.Now.AddMinutes(TokenExpiryMinutes));
                                cmd.ExecuteNonQuery();
                            }
                            txn.Commit();
                        }
                        catch { txn.Rollback(); throw; }
                    }

                    // Build reset URL
                    string resetUrl = Request.Url.GetLeftPart(UriPartial.Authority)
                        + ResolveUrl("~/ResetPassword.aspx") + "?token=" + Uri.EscapeDataString(rawToken);

                    // Send email
                    try { SendResetEmail(email, resetUrl); }
                    catch
                    {
                        // Dev mode: output to debug
                        System.Diagnostics.Debug.WriteLine("[DEV] Password reset link: " + resetUrl);
                    }
                }
            }
            catch { /* Do not expose errors */ }

            ShowStatus(genericMsg, true);
            pnlForm.Visible = false;
        }

        private void SendResetEmail(string toEmail, string resetUrl)
        {
            string smtpHost = ConfigurationManager.AppSettings["SmtpHost"] ?? "smtp.gmail.com";
            int smtpPort = int.Parse(ConfigurationManager.AppSettings["SmtpPort"] ?? "587");
            string smtpUser = ConfigurationManager.AppSettings["SmtpUsername"] ?? "";
            string smtpPass = ConfigurationManager.AppSettings["SmtpPassword"] ?? "";
            bool smtpSsl = bool.Parse(ConfigurationManager.AppSettings["SmtpEnableSsl"] ?? "true");

            if (string.IsNullOrEmpty(smtpUser) || string.IsNullOrEmpty(smtpPass))
            {
                System.Diagnostics.Debug.WriteLine("[DEV] SMTP not configured. Reset link: " + resetUrl);
                return;
            }

            string body = $@"Hello,

A password reset was requested for your ScienceBuddy account.

Click the link below to reset your password. This link expires in {TokenExpiryMinutes} minutes and can only be used once.

{resetUrl}

If you did not request this, you can safely ignore this email. Do not share this link with anyone.

— ScienceBuddy Support";

            using (var mail = new MailMessage())
            {
                mail.From = new MailAddress(smtpUser, "ScienceBuddy Support");
                mail.To.Add(toEmail);
                mail.Subject = "Reset your ScienceBuddy password";
                mail.Body = body;
                mail.IsBodyHtml = false;

                using (var smtp = new SmtpClient(smtpHost, smtpPort))
                {
                    smtp.Credentials = new NetworkCredential(smtpUser, smtpPass);
                    smtp.EnableSsl = smtpSsl;
                    smtp.Send(mail);
                }
            }
        }

        private string GenId(SqlConnection conn, SqlTransaction txn)
        {
            int nextNumber = 1;
            using (SqlCommand cmd = new SqlCommand("SELECT TOP 1 [tokenId] FROM dbo.[PasswordResetToken] ORDER BY [tokenId] DESC", conn, txn))
            {
                object result = cmd.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                {
                    string lastId = result.ToString();
                    // Token IDs follow format PRT001, PRT002, etc.
                    if (lastId.Length > 3 && int.TryParse(lastId.Substring(3), out int lastNumber))
                        nextNumber = lastNumber + 1;
                }
            }
            return "PRT" + nextNumber.ToString("D3");
        }

        /// <summary>
        /// Hashes the reset token before storing it in the database.
        /// Only the hash is stored; the raw token is sent to the user via email.
        /// This way, even if the database is compromised, tokens cannot be reused.
        /// </summary>
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

        private void ShowStatus(string msg, bool success)
        {
            pnlStatus.Visible = true;
            divStatus.InnerText = msg;
            divStatus.Attributes["class"] = success ? "reg-status reg-status--success" : "reg-status reg-status--error";
        }
    }
}
