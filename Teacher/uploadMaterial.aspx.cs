using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Teacher
{
    public partial class uploadMaterial : Page
    {
        protected string CurrentLanguage
        { get { string lang = Session["preferredLanguage"] as string; return string.IsNullOrEmpty(lang) ? "EN" : lang; } }
        protected string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        private static readonly HashSet<string> AllowedExts = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        { ".pdf", ".doc", ".docx", ".ppt", ".pptx", ".jpg", ".jpeg", ".png", ".mp4" };
        private const int MaxFileBytes = 100 * 1024 * 1024;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"]?.ToString() != "Teacher")
            { Response.Redirect("~/Login.aspx", false); Context.ApplicationInstance.CompleteRequest(); return; }
            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            if (!IsPostBack) { if (!Authorize()) return; LoadDropdowns(); }
        }

        private bool Authorize()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [status] FROM dbo.[Teacher] WHERE [userId]=@u", conn))
                { cmd.Parameters.AddWithValue("@u", Session["userId"].ToString()); var v = cmd.ExecuteScalar();
                  if (v == null || v == DBNull.Value || !v.ToString().Equals("Certified", StringComparison.OrdinalIgnoreCase))
                  { Response.Redirect("~/Teacher/Dashboard.aspx", false); Context.ApplicationInstance.CompleteRequest(); return false; } }
            }
            return true;
        }

        private void LoadDropdowns()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                ddlLevel.Items.Clear(); ddlLevel.Items.Add(new ListItem(T("— Select Level —","— Pilih Tahap —"), ""));
                using (var cmd = new SqlCommand("SELECT [levelId],[levelNameEN] FROM dbo.[Level] ORDER BY [levelId]", conn))
                using (var r = cmd.ExecuteReader()) while (r.Read()) ddlLevel.Items.Add(new ListItem(r["levelNameEN"].ToString(), r["levelId"].ToString()));
                ddlUnit.Items.Clear(); ddlUnit.Items.Add(new ListItem(T("— Select Unit —","— Pilih Unit —"), ""));
                ddlSubtopic.Items.Clear(); ddlSubtopic.Items.Add(new ListItem(T("— Select Subtopic —","— Pilih Subtopik —"), ""));
            }
        }

        protected void ddlLevel_Changed(object sender, EventArgs e)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                ddlUnit.Items.Clear(); ddlUnit.Items.Add(new ListItem(T("— Select Unit —","— Pilih Unit —"), ""));
                ddlSubtopic.Items.Clear(); ddlSubtopic.Items.Add(new ListItem(T("— Select Subtopic —","— Pilih Subtopik —"), ""));
                string lid = ddlLevel.SelectedValue;
                if (!string.IsNullOrEmpty(lid))
                    using (var cmd = new SqlCommand("SELECT [unitId],[unitNameEN] FROM dbo.[Unit] WHERE [levelId]=@l ORDER BY [orderNo]", conn))
                    { cmd.Parameters.AddWithValue("@l", lid); using (var r = cmd.ExecuteReader()) while (r.Read()) ddlUnit.Items.Add(new ListItem(r["unitNameEN"].ToString(), r["unitId"].ToString())); }
            }
        }

        protected void ddlUnit_Changed(object sender, EventArgs e)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                ddlSubtopic.Items.Clear(); ddlSubtopic.Items.Add(new ListItem(T("— Select Subtopic —","— Pilih Subtopik —"), ""));
                string uid = ddlUnit.SelectedValue;
                if (!string.IsNullOrEmpty(uid))
                    using (var cmd = new SqlCommand("SELECT [subtopicId],[subtopicTitleEN] FROM dbo.[Subtopic] WHERE [unitId]=@u ORDER BY [orderNo]", conn))
                    { cmd.Parameters.AddWithValue("@u", uid); using (var r = cmd.ExecuteReader()) while (r.Read()) ddlSubtopic.Items.Add(new ListItem(r["subtopicTitleEN"].ToString(), r["subtopicId"].ToString())); }
            }
        }

        protected void btnUpload_Click(object sender, EventArgs e)
        {
            string title = txtTitle.Text.Trim();
            string desc = txtDescription.Text.Trim();
            string subtopicId = ddlSubtopic.SelectedValue;
            string language = hidLanguage.Value;

            if (string.IsNullOrEmpty(title)) { ShowError(T("Material Title is required.","Tajuk Bahan diperlukan.")); return; }
            if (string.IsNullOrEmpty(ddlLevel.SelectedValue)) { ShowError(T("Please select a Level.","Sila pilih Tahap.")); return; }
            if (string.IsNullOrEmpty(ddlUnit.SelectedValue)) { ShowError(T("Please select a Unit.","Sila pilih Unit.")); return; }
            if (string.IsNullOrEmpty(subtopicId)) { ShowError(T("Please select a Subtopic.","Sila pilih Subtopik.")); return; }
            if (string.IsNullOrEmpty(language)) language = "EN";
            if (!fuFile.HasFile) { ShowError(T("Please upload a file.","Sila muat naik fail.")); return; }

            string ext = Path.GetExtension(fuFile.FileName).ToLower();
            if (!AllowedExts.Contains(ext)) { ShowError(T("Unsupported file type.","Jenis fail tidak disokong.")); return; }
            if (fuFile.PostedFile.ContentLength > MaxFileBytes) { ShowError(T("File exceeds 100 MB limit.","Fail melebihi had 100 MB.")); return; }

            string materialType = GetMaterialType(ext);
            string fileName = fuFile.FileName; // keep original filename
            string physicalDir = Server.MapPath("~/Images/Material/");
            if (!Directory.Exists(physicalDir)) Directory.CreateDirectory(physicalDir);

            try
            {
                fuFile.SaveAs(Path.Combine(physicalDir, fileName));
                string userId = Session["userId"].ToString();
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    string newId = GenId(conn);
                    using (var cmd = new SqlCommand(@"INSERT INTO dbo.[Material]([materialId],[subtopicId],[createdByUserId],[materialTitle],[materialType],[fileUrl],[materialContent],[createdDate],[status],[language])
                        VALUES(@id,@sub,@uid,@title,@type,@file,@desc,GETDATE(),'Pending',@lang)", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", newId);
                        cmd.Parameters.AddWithValue("@sub", subtopicId);
                        cmd.Parameters.AddWithValue("@uid", userId);
                        cmd.Parameters.AddWithValue("@title", title);
                        cmd.Parameters.AddWithValue("@type", materialType);
                        cmd.Parameters.AddWithValue("@file", fileName); // filename only
                        cmd.Parameters.AddWithValue("@desc", string.IsNullOrEmpty(desc) ? (object)DBNull.Value : desc);
                        cmd.Parameters.AddWithValue("@lang", language);
                        cmd.ExecuteNonQuery();
                    }

                    // Insert notification for the teacher
                    InsertNotification(conn, userId);
                }
                hidToast.Value = T("Material uploaded successfully!", "Bahan berjaya dimuat naik!");
                txtTitle.Text = ""; txtDescription.Text = "";
            }
            catch { ShowError(T("An error occurred. Please try again.","Ralat berlaku. Sila cuba lagi.")); }
        }

        private void ShowError(string msg) { pnlError.Visible = true; litError.Text = HttpUtility.HtmlEncode(msg); }

        private void InsertNotification(SqlConnection conn, string userId)
        {
            try
            {
                // Generate notification ID: N + 3-digit
                string notifId;
                using (var cmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING([notificationId],2,LEN([notificationId])-1) AS INT)),0) FROM dbo.[Notification]", conn))
                { notifId = "N" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3"); }

                using (var cmd = new SqlCommand(@"INSERT INTO dbo.[Notification]([notificationId],[toUserId],[titleEN],[messageEN],[titleBM],[messageBM],[isRead],[createdAt])
                    VALUES(@id,@uid,@tEN,@mEN,@tBM,@mBM,0,GETDATE())", conn))
                {
                    cmd.Parameters.AddWithValue("@id", notifId);
                    cmd.Parameters.AddWithValue("@uid", userId);
                    cmd.Parameters.AddWithValue("@tEN", "Material Submitted");
                    cmd.Parameters.AddWithValue("@mEN", "Your learning material has been submitted successfully and is pending review.");
                    cmd.Parameters.AddWithValue("@tBM", "Bahan Telah Dihantar");
                    cmd.Parameters.AddWithValue("@mBM", "Bahan pembelajaran anda telah berjaya dihantar dan sedang menunggu semakan.");
                    cmd.ExecuteNonQuery();
                }
            }
            catch { /* notification insert failure should not block upload success */ }
        }

        private string GenId(SqlConnection conn)
        {
            using (var cmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING([materialId],2,LEN([materialId])-1) AS INT)),0) FROM dbo.[Material]", conn))
            { return "M" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3"); }
        }

        private static string GetMaterialType(string ext)
        {
            switch (ext) { case ".pdf": return "PDF"; case ".doc": case ".docx": return "Document"; case ".ppt": case ".pptx": return "PPTX"; case ".jpg": case ".jpeg": case ".png": return "Image"; case ".mp4": return "Video"; default: return "Other"; }
        }
    }
}
