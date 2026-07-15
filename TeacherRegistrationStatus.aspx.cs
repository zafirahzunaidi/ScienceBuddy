using System;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.UI;

namespace ScienceBuddy
{
    public partial class TeacherRegistrationStatus : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["TeacherStatusUserId"] == null)
            { Response.Redirect("~/Login", false); Context.ApplicationInstance.CompleteRequest(); return; }

            ((SiteMaster)Master).LayoutMode = "TopNav";

            if (!IsPostBack)
                LoadStatus();
        }

        private void LoadStatus()
        {
            string userId = Session["TeacherStatusUserId"].ToString();

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT u.status, t.status, t.name, t.qualification, t.licenseCert FROM dbo.[User] u INNER JOIN dbo.[Teacher] t ON u.userId=t.userId WHERE u.userId=@uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read())
                        { Response.Redirect("~/Login", false); Context.ApplicationInstance.CompleteRequest(); return; }

                        string userStatus = reader.GetString(0);
                        string teacherStatus = reader.GetString(1);
                        string teacherName = reader.IsDBNull(2) ? "" : reader.GetString(2);
                        string qualification = reader.IsDBNull(3) ? "" : reader.GetString(3);
                        string certFile = reader.IsDBNull(4) ? "" : reader.GetString(4);

                        // Hide all panels
                        pnlPending.Visible = false;
                        pnlCertified.Visible = false;
                        pnlRejected.Visible = false;
                        pnlBlocked.Visible = false;
                        pnlDeleted.Visible = false;

                        if (userStatus == "Deleted")
                        {
                            pnlDeleted.Visible = true;
                        }
                        else if (userStatus == "Blocked")
                        {
                            pnlBlocked.Visible = true;
                        }
                        else if (teacherStatus == "Certified")
                        {
                            pnlCertified.Visible = true;
                        }
                        else if (teacherStatus == "Not Certified")
                        {
                            pnlRejected.Visible = true;
                            litCertFile.Text = HttpUtility.HtmlEncode(Path.GetFileName(certFile));
                        }
                        else // Pending
                        {
                            pnlPending.Visible = true;
                            litTeacherName.Text = HttpUtility.HtmlEncode(teacherName);
                            litQualification.Text = HttpUtility.HtmlEncode(qualification);
                        }
                    }
                }
            }
        }

        protected void BtnResubmit_Click(object sender, EventArgs e)
        {
            string userId = Session["TeacherStatusUserId"]?.ToString();
            if (string.IsNullOrEmpty(userId))
            { Response.Redirect("~/Login", false); Context.ApplicationInstance.CompleteRequest(); return; }

            // Validate new certificate
            if (!fuNewCertificate.HasFile)
            { ShowResubmitError("Please upload a new teaching certificate."); return; }

            string ext = Path.GetExtension(fuNewCertificate.FileName).ToLower();
            if (ext != ".pdf")
            { ShowResubmitError("Only PDF files are accepted for the teaching certificate."); return; }

            if (fuNewCertificate.PostedFile.ContentLength > 5 * 1024 * 1024)
            { ShowResubmitError("Certificate file must not exceed 5MB."); return; }

            string savedFilePath = null;

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // Get teacher info
                    string teacherId = null;
                    string oldCertPath = null;
                    using (var cmd = new SqlCommand("SELECT teacherId, licenseCert FROM dbo.[Teacher] WHERE userId=@uid", conn))
                    {
                        cmd.Parameters.AddWithValue("@uid", userId);
                        using (var reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                teacherId = reader.GetString(0);
                                oldCertPath = reader.IsDBNull(1) ? null : reader.GetString(1);
                            }
                        }
                    }

                    if (teacherId == null)
                    { ShowResubmitError("Teacher record not found."); return; }

                    // Save new certificate
                    string timestamp = DateTime.Now.ToString("yyyyMMddHHmmss");
                    string certFileName = $"cert_{teacherId}_{timestamp}.pdf";
                    string certFolder = Server.MapPath("~/Uploads/TeacherCertificates/");
                    if (!Directory.Exists(certFolder)) Directory.CreateDirectory(certFolder);
                    savedFilePath = Path.Combine(certFolder, certFileName);
                    fuNewCertificate.SaveAs(savedFilePath);
                    string relativePath = "Uploads/TeacherCertificates/" + certFileName;

                    using (var txn = conn.BeginTransaction())
                    {
                        try
                        {
                            // Update Teacher status and certificate
                            using (var cmd = new SqlCommand("UPDATE dbo.[Teacher] SET status='Pending', licenseCert=@cert WHERE userId=@uid", conn, txn))
                            {
                                cmd.Parameters.AddWithValue("@cert", relativePath);
                                cmd.Parameters.AddWithValue("@uid", userId);
                                cmd.ExecuteNonQuery();
                            }

                            // Update User status to Active
                            using (var cmd = new SqlCommand("UPDATE dbo.[User] SET status='Active' WHERE userId=@uid", conn, txn))
                            {
                                cmd.Parameters.AddWithValue("@uid", userId);
                                cmd.ExecuteNonQuery();
                            }

                            // Insert Log entry
                            string logId = GenId(conn, txn, "Log", "logId", "LG");
                            using (var cmd = new SqlCommand("INSERT INTO dbo.[Log](logId,userId,action,description,createdAt) VALUES(@id,@uid,@act,@desc,@now)", conn, txn))
                            {
                                cmd.Parameters.AddWithValue("@id", logId);
                                cmd.Parameters.AddWithValue("@uid", userId);
                                cmd.Parameters.AddWithValue("@act", "Teacher Certificate Resubmitted");
                                cmd.Parameters.AddWithValue("@desc", "Teacher resubmitted certificate for review.");
                                cmd.Parameters.AddWithValue("@now", DateTime.Now);
                                cmd.ExecuteNonQuery();
                            }

                            txn.Commit();

                            // Delete old certificate file
                            if (!string.IsNullOrEmpty(oldCertPath))
                            {
                                string oldFullPath = Server.MapPath("~/" + oldCertPath);
                                if (File.Exists(oldFullPath))
                                    try { File.Delete(oldFullPath); } catch { }
                            }

                            // Reload status
                            LoadStatus();
                        }
                        catch
                        {
                            txn.Rollback();
                            if (savedFilePath != null && File.Exists(savedFilePath))
                                try { File.Delete(savedFilePath); } catch { }
                            throw;
                        }
                    }
                }
            }
            catch (Exception)
            {
                if (savedFilePath != null && File.Exists(savedFilePath))
                    try { File.Delete(savedFilePath); } catch { }
                ShowResubmitError("Resubmission failed. Please try again.");
            }
        }

        private string GenId(SqlConnection c, SqlTransaction t, string table, string col, string prefix)
        { int n = 1; using (var cmd = new SqlCommand($"SELECT TOP 1 [{col}] FROM dbo.[{table}] ORDER BY [{col}] DESC", c, t)) { var r = cmd.ExecuteScalar(); if (r != null && r != DBNull.Value) { string last = r.ToString(); if (last.Length > prefix.Length && int.TryParse(last.Substring(prefix.Length), out int num)) n = num + 1; } } return prefix + n.ToString("D3"); }

        private void ShowResubmitError(string msg)
        {
            pnlRejected.Visible = true;
            pnlResubmitError.Visible = true;
            litResubmitError.Text = HttpUtility.HtmlEncode(msg);
        }
    }
}
