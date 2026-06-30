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
        // ── Language support ─────────────────────────────────────────
        protected string CurrentLanguage
        {
            get
            {
                string lang = Session["preferredLanguage"] as string;
                return string.IsNullOrEmpty(lang) ? "EN" : lang;
            }
        }
        protected string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }

        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        private static readonly HashSet<string> AllowedExts = new HashSet<string>(
            StringComparer.OrdinalIgnoreCase)
        { ".pdf", ".doc", ".docx", ".ppt", ".pptx", ".jpg", ".jpeg", ".png", ".mp4" };

        private const int MaxFileBytes = 100 * 1024 * 1024; // 100 MB

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"]?.ToString() != "Teacher")
            { Response.Redirect("~/Login.aspx", false); Context.ApplicationInstance.CompleteRequest(); return; }

            var master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                if (!Authorize()) return;
                LoadDropdowns();
                SetPlaceholders();
            }
        }

        private bool Authorize()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [status] FROM dbo.[Teacher] WHERE [userId]=@u", conn))
                {
                    cmd.Parameters.AddWithValue("@u", Session["userId"].ToString());
                    var val = cmd.ExecuteScalar();
                    if (val == null || val == DBNull.Value ||
                        !val.ToString().Equals("Certified", StringComparison.OrdinalIgnoreCase))
                    { Response.Redirect("~/Teacher/Dashboard.aspx", false); Context.ApplicationInstance.CompleteRequest(); return false; }
                }
            }
            return true;
        }

        private void LoadDropdowns()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                ddlLevel.Items.Clear();
                ddlLevel.Items.Add(new ListItem("— Select Level —", ""));
                using (var cmd = new SqlCommand("SELECT [levelId],[levelNameEN] FROM dbo.[Level] ORDER BY [levelId]", conn))
                using (var r = cmd.ExecuteReader())
                    while (r.Read()) ddlLevel.Items.Add(new ListItem(r["levelNameEN"].ToString(), r["levelId"].ToString()));
                ddlUnit.Items.Clear(); ddlUnit.Items.Add(new ListItem("— Select Unit —", ""));
                ddlSubtopic.Items.Clear(); ddlSubtopic.Items.Add(new ListItem("— Select Subtopic —", ""));
            }
        }

        private void SetPlaceholders()
        {
            txtTitle.Attributes["placeholder"] = T("Enter material title...", "Masukkan tajuk bahan...");
            txtDescription.Attributes["placeholder"] = T("Describe what this material covers...", "Terangkan apa yang diliputi bahan ini...");
        }

        protected void ddlLevel_Changed(object sender, EventArgs e)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                ddlUnit.Items.Clear(); ddlUnit.Items.Add(new ListItem("— Select Unit —", ""));
                ddlSubtopic.Items.Clear(); ddlSubtopic.Items.Add(new ListItem("— Select Subtopic —", ""));
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
                ddlSubtopic.Items.Clear(); ddlSubtopic.Items.Add(new ListItem("— Select Subtopic —", ""));
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

            if (string.IsNullOrEmpty(title)) { ShowError("Material Title is required."); return; }
            if (string.IsNullOrEmpty(desc)) { ShowError("Description is required."); return; }
            if (string.IsNullOrEmpty(ddlLevel.SelectedValue)) { ShowError("Please select a Level."); return; }
            if (string.IsNullOrEmpty(ddlUnit.SelectedValue)) { ShowError("Please select a Unit."); return; }
            if (string.IsNullOrEmpty(subtopicId)) { ShowError("Please select a Subtopic."); return; }
            if (string.IsNullOrEmpty(language)) language = "EN";
            if (!fuFile.HasFile) { ShowError("Please upload a file."); return; }

            string ext = Path.GetExtension(fuFile.FileName).ToLower();
            if (!AllowedExts.Contains(ext))
            { ShowError("Unsupported file type. Supported formats: PDF, DOC, DOCX, PPT, PPTX, JPG, JPEG, PNG, MP4"); return; }
            if (fuFile.PostedFile.ContentLength > MaxFileBytes)
            { ShowError("File size exceeds the maximum limit of 100 MB."); return; }

            string materialType = GetMaterialType(ext);
            string fileName = Guid.NewGuid().ToString("N").Substring(0, 12) + ext;
            string relativePath = "Images/Material/" + fileName;
            string physicalDir = Server.MapPath("~/Images/Material/");
            if (!Directory.Exists(physicalDir)) Directory.CreateDirectory(physicalDir);

            try
            {
                fuFile.SaveAs(Path.Combine(physicalDir, fileName));
                string userId = Session["userId"].ToString();
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    string newId = GenerateId(conn);
                    const string sql = @"INSERT INTO dbo.[Material]
                        ([materialId],[subtopicId],[createdByUserId],[materialTitle],[materialType],[fileUrl],[materialContent],[createdDate],[status],[language])
                        VALUES(@id,@sub,@uid,@title,@type,@file,@desc,@date,'Pending',@lang)";
                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@id", newId);
                        cmd.Parameters.AddWithValue("@sub", subtopicId);
                        cmd.Parameters.AddWithValue("@uid", userId);
                        cmd.Parameters.AddWithValue("@title", title);
                        cmd.Parameters.AddWithValue("@type", materialType);
                        cmd.Parameters.AddWithValue("@file", relativePath);
                        cmd.Parameters.AddWithValue("@desc", desc);
                        cmd.Parameters.AddWithValue("@date", DateTime.Now.ToString("yyyy-MM-dd"));
                        cmd.Parameters.AddWithValue("@lang", language);
                        cmd.ExecuteNonQuery();
                    }
                }
                hidToast.Value = T("Material uploaded successfully.","Bahan berjaya dimuat naik.");
            }
            catch { ShowError("An unexpected error occurred. Please try again."); }
        }

        private void ShowError(string msg) { pnlError.Visible = true; litError.Text = HttpUtility.HtmlEncode(msg); }

        private string GenerateId(SqlConnection conn)
        {
            using (var cmd = new SqlCommand("SELECT MAX(CAST(SUBSTRING([materialId],2,LEN([materialId])-1) AS INT)) FROM dbo.[Material]", conn))
            {
                var val = cmd.ExecuteScalar();
                int next = (val != null && val != DBNull.Value) ? Convert.ToInt32(val) + 1 : 1;
                return "M" + next.ToString("D3");
            }
        }

        private static string GetMaterialType(string ext)
        {
            switch (ext)
            {
                case ".pdf": return "PDF";
                case ".doc": case ".docx": return "Document";
                case ".ppt": case ".pptx": return "PPTX";
                case ".jpg": case ".jpeg": case ".png": return "Image";
                case ".mp4": return "Video";
                default: return "Other";
            }
        }
    }
}
