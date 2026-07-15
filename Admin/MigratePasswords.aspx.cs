using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;

namespace ScienceBuddy.Admin
{
    public partial class MigratePasswords : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Only allow Admin access
            if (Session["role"] == null || Session["role"].ToString() != "Admin")
            { Response.Redirect("~/Login", false); Context.ApplicationInstance.CompleteRequest(); }
        }

        protected void BtnMigrate_Click(object sender, EventArgs e)
        {
            string connStr = ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
            int total = 0, migrated = 0, skipped = 0, empty = 0, failed = 0;

            try
            {
                using (var conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    // First: ALTER column to support BCrypt length
                    using (var cmd = new SqlCommand("ALTER TABLE dbo.[User] ALTER COLUMN [password] nvarchar(100)", conn))
                    { cmd.ExecuteNonQuery(); }

                    // Read all users
                    var users = new System.Collections.Generic.List<Tuple<string, string>>();
                    using (var cmd = new SqlCommand("SELECT userId, password FROM dbo.[User]", conn))
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string uid = reader["userId"].ToString();
                            string pwd = reader["password"] != DBNull.Value ? reader["password"].ToString() : "";
                            users.Add(Tuple.Create(uid, pwd));
                        }
                    }

                    total = users.Count;

                    foreach (var user in users)
                    {
                        string uid = user.Item1;
                        string pwd = user.Item2;

                        if (string.IsNullOrWhiteSpace(pwd))
                        { empty++; continue; }

                        if (PasswordHelper.IsBCryptHash(pwd))
                        { skipped++; continue; }

                        try
                        {
                            string hashed = PasswordHelper.HashPassword(pwd);
                            using (var cmd = new SqlCommand("UPDATE dbo.[User] SET [password]=@p WHERE userId=@id", conn))
                            {
                                cmd.Parameters.AddWithValue("@p", hashed);
                                cmd.Parameters.AddWithValue("@id", uid);
                                cmd.ExecuteNonQuery();
                            }
                            migrated++;
                        }
                        catch { failed++; }
                    }
                }

                var sb = new StringBuilder();
                sb.AppendFormat("<strong>Migration Complete</strong><br/>");
                sb.AppendFormat("Total accounts: {0}<br/>", total);
                sb.AppendFormat("Migrated to BCrypt: {0}<br/>", migrated);
                sb.AppendFormat("Already BCrypt (skipped): {0}<br/>", skipped);
                sb.AppendFormat("Empty passwords: {0}<br/>", empty);
                sb.AppendFormat("Failed: {0}", failed);
                litResult.Text = sb.ToString();
                pnlResult.Visible = true;
                btnMigrate.Enabled = false;
                btnMigrate.Text = "Migration Complete";
            }
            catch (Exception ex)
            {
                litResult.Text = "Migration failed: " + Server.HtmlEncode(ex.Message);
                pnlResult.Visible = true;
            }
        }
    }
}
