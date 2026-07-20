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
        #region Properties

        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected string CurrentLanguage
        {
            get
            {
                string lang = Session["preferredLanguage"] as string;
                return string.IsNullOrEmpty(lang) ? "EN" : lang;
            }
        }

        private static readonly HashSet<string> AllowedExtensions = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            ".pdf", ".doc", ".docx", ".ppt", ".pptx", ".jpg", ".jpeg", ".png", ".mp4"
        };

        private const int MaxFileSizeBytes = 100 * 1024 * 1024;

        #endregion

        #region Page Lifecycle

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"]?.ToString() != "Teacher")
            {
                Response.Redirect("~/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                if (!Authorize()) return;
                LoadDropdowns();
            }
        }

        #endregion

        #region Event Handlers

        protected void ddlLevel_Changed(object sender, EventArgs e)
        {
            string selectedLevelId = ddlLevel.SelectedValue;

            ResetDropdown(ddlUnit, T("— Select Unit —", "— Pilih Unit —"));
            ResetDropdown(ddlSubtopic, T("— Select Subtopic —", "— Pilih Subtopik —"));

            if (string.IsNullOrEmpty(selectedLevelId)) return;

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                using (var cmd = new SqlCommand(
                    "SELECT [unitId],[unitNameEN] FROM dbo.[Unit] WHERE [levelId]=@l ORDER BY [orderNo]", conn))
                {
                    cmd.Parameters.AddWithValue("@l", selectedLevelId);

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            ddlUnit.Items.Add(new ListItem(
                                reader["unitNameEN"].ToString(),
                                reader["unitId"].ToString()));
                        }
                    }
                }
            }
        }

        protected void ddlUnit_Changed(object sender, EventArgs e)
        {
            string selectedUnitId = ddlUnit.SelectedValue;

            ResetDropdown(ddlSubtopic, T("— Select Subtopic —", "— Pilih Subtopik —"));

            if (string.IsNullOrEmpty(selectedUnitId)) return;

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                using (var cmd = new SqlCommand(
                    "SELECT [subtopicId],[subtopicTitleEN] FROM dbo.[Subtopic] WHERE [unitId]=@u ORDER BY [orderNo]", conn))
                {
                    cmd.Parameters.AddWithValue("@u", selectedUnitId);

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            ddlSubtopic.Items.Add(new ListItem(
                                reader["subtopicTitleEN"].ToString(),
                                reader["subtopicId"].ToString()));
                        }
                    }
                }
            }
        }

        protected void btnUpload_Click(object sender, EventArgs e)
        {
            string title = txtTitle.Text.Trim();
            string description = txtDescription.Text.Trim();
            string selectedSubtopicId = ddlSubtopic.SelectedValue;
            string language = hidLanguage.Value;

            // Validate form inputs
            if (string.IsNullOrEmpty(title)) { ShowError(T("Material Title is required.", "Tajuk Bahan diperlukan.")); return; }
            if (string.IsNullOrEmpty(ddlLevel.SelectedValue)) { ShowError(T("Please select a Level.", "Sila pilih Tahap.")); return; }
            if (string.IsNullOrEmpty(ddlUnit.SelectedValue)) { ShowError(T("Please select a Unit.", "Sila pilih Unit.")); return; }
            if (string.IsNullOrEmpty(selectedSubtopicId)) { ShowError(T("Please select a Subtopic.", "Sila pilih Subtopik.")); return; }
            if (string.IsNullOrEmpty(language)) language = "EN";
            if (!fuFile.HasFile) { ShowError(T("Please upload a file.", "Sila muat naik fail.")); return; }

            // Validate file type and size
            string fileExtension = Path.GetExtension(fuFile.FileName).ToLower();

            if (!AllowedExtensions.Contains(fileExtension))
            {
                ShowError(T("Unsupported file type.", "Jenis fail tidak disokong."));
                return;
            }

            if (fuFile.PostedFile.ContentLength > MaxFileSizeBytes)
            {
                ShowError(T("The selected file exceeds the 100 MB upload limit. Please choose a smaller file.",
                            "Fail yang dipilih melebihi had muat naik 100 MB. Sila pilih fail yang lebih kecil."));
                return;
            }

            string materialType = GetMaterialType(fileExtension);
            string fileName = fuFile.FileName; // keep original filename

            string physicalDir = Server.MapPath("~/Images/Material/");
            if (!Directory.Exists(physicalDir))
                Directory.CreateDirectory(physicalDir);

            try
            {
                fuFile.SaveAs(Path.Combine(physicalDir, fileName));

                string teacherId = Session["userId"].ToString();

                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    using (var txn = conn.BeginTransaction())
                    {
                        string materialId = GenerateMaterialId(conn, txn);

                        InsertMaterial(conn, txn, materialId, selectedSubtopicId, teacherId,
                                       title, materialType, fileName, description, language);

                        InsertLog(conn, txn, teacherId, materialId);

                        txn.Commit();
                    }

                    // Notification is non-critical — failure should not block upload success
                    InsertNotification(conn, teacherId);
                }

                // Reset form on success
                hidToast.Value = T("Material uploaded successfully!", "Bahan berjaya dimuat naik!");
                txtTitle.Text = "";
                txtDescription.Text = "";
                hidLanguage.Value = "EN";
                ddlLevel.SelectedIndex = 0;
                ResetDropdown(ddlUnit, T("— Select Unit —", "— Pilih Unit —"));
                ResetDropdown(ddlSubtopic, T("— Select Subtopic —", "— Pilih Subtopik —"));
            }
            catch
            {
                ShowError(T("An error occurred. Please try again.", "Ralat berlaku. Sila cuba lagi."));
            }
        }

        #endregion

        #region Data Loading

        private void LoadDropdowns()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                ResetDropdown(ddlLevel, T("— Select Level —", "— Pilih Tahap —"));

                using (var cmd = new SqlCommand("SELECT [levelId],[levelNameEN] FROM dbo.[Level] ORDER BY [levelId]", conn))
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        ddlLevel.Items.Add(new ListItem(
                            reader["levelNameEN"].ToString(),
                            reader["levelId"].ToString()));
                    }
                }

                ResetDropdown(ddlUnit, T("— Select Unit —", "— Pilih Unit —"));
                ResetDropdown(ddlSubtopic, T("— Select Subtopic —", "— Pilih Subtopik —"));
            }
        }

        #endregion

        #region Database Operations

        private bool Authorize()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                using (var cmd = new SqlCommand(
                    "SELECT [status] FROM dbo.[Teacher] WHERE [userId]=@u", conn))
                {
                    cmd.Parameters.AddWithValue("@u", Session["userId"].ToString());
                    var status = cmd.ExecuteScalar();

                    // Only certified teachers can upload materials
                    if (status == null || status == DBNull.Value ||
                        !status.ToString().Equals("Certified", StringComparison.OrdinalIgnoreCase))
                    {
                        Response.Redirect("~/Teacher/Dashboard.aspx", false);
                        Context.ApplicationInstance.CompleteRequest();
                        return false;
                    }
                }
            }

            return true;
        }

        private void InsertMaterial(SqlConnection conn, SqlTransaction txn, string materialId,
            string subtopicId, string userId, string title, string materialType,
            string fileName, string description, string language)
        {
            using (var cmd = new SqlCommand(@"
                INSERT INTO dbo.[Material]
                    ([materialId],[subtopicId],[createdByUserId],[materialTitle],[materialType],
                     [fileUrl],[materialContent],[createdDate],[status],[language])
                VALUES
                    (@id,@sub,@uid,@title,@type,@file,@desc,GETDATE(),'Pending',@lang)", conn, txn))
            {
                cmd.Parameters.AddWithValue("@id", materialId);
                cmd.Parameters.AddWithValue("@sub", subtopicId);
                cmd.Parameters.AddWithValue("@uid", userId);
                cmd.Parameters.AddWithValue("@title", title);
                cmd.Parameters.AddWithValue("@type", materialType);
                cmd.Parameters.AddWithValue("@file", fileName);
                cmd.Parameters.AddWithValue("@desc", string.IsNullOrEmpty(description) ? (object)DBNull.Value : description);
                cmd.Parameters.AddWithValue("@lang", language);
                cmd.ExecuteNonQuery();
            }
        }

        private void InsertLog(SqlConnection conn, SqlTransaction txn, string userId, string materialId)
        {
            string logId = GenerateLogId(conn, txn);

            using (var cmd = new SqlCommand(@"
                INSERT INTO dbo.[Log]
                    ([logId],[userId],[action],[description],[logDateTime],[status])
                VALUES
                    (@id,@uid,@act,@desc,GETDATE(),'Success')", conn, txn))
            {
                cmd.Parameters.AddWithValue("@id", logId);
                cmd.Parameters.AddWithValue("@uid", userId);
                cmd.Parameters.AddWithValue("@act", "Material Uploaded");
                cmd.Parameters.AddWithValue("@desc", "Uploaded material " + materialId + " for review.");
                cmd.ExecuteNonQuery();
            }
        }

        private void InsertNotification(SqlConnection conn, string userId)
        {
            try
            {
                string notificationId = GenerateNotificationId(conn);

                using (var cmd = new SqlCommand(@"
                    INSERT INTO dbo.[Notification]
                        ([notificationId],[toUserId],[titleEN],[messageEN],[titleBM],[messageBM],[isRead],[createdAt])
                    VALUES
                        (@id,@uid,@tEN,@mEN,@tBM,@mBM,0,GETDATE())", conn))
                {
                    cmd.Parameters.AddWithValue("@id", notificationId);
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

        #endregion

        #region Validation

        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        private void ShowError(string msg)
        {
            pnlError.Visible = true;
            litError.Text = HttpUtility.HtmlEncode(msg);
        }

        #endregion

        #region Helper Methods

        /// <summary>
        /// Clears all items from the dropdown and adds a default placeholder item.
        /// </summary>
        private void ResetDropdown(DropDownList ddl, string placeholderText)
        {
            ddl.Items.Clear();
            ddl.Items.Add(new ListItem(placeholderText, ""));
        }

        private string GenerateMaterialId(SqlConnection conn, SqlTransaction txn)
        {
            using (var cmd = new SqlCommand(
                "SELECT ISNULL(MAX(CAST(SUBSTRING([materialId],2,LEN([materialId])-1) AS INT)),0) FROM dbo.[Material]", conn, txn))
            {
                return "M" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3");
            }
        }

        private string GenerateMaterialId(SqlConnection conn)
        {
            using (var cmd = new SqlCommand(
                "SELECT ISNULL(MAX(CAST(SUBSTRING([materialId],2,LEN([materialId])-1) AS INT)),0) FROM dbo.[Material]", conn))
            {
                return "M" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3");
            }
        }

        private string GenerateLogId(SqlConnection conn, SqlTransaction txn)
        {
            using (var cmd = new SqlCommand(
                "SELECT ISNULL(MAX(CAST(SUBSTRING([logId],4,LEN([logId])-3) AS INT)),0) FROM dbo.[Log]", conn, txn))
            {
                return "LOG" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3");
            }
        }

        private string GenerateNotificationId(SqlConnection conn)
        {
            using (var cmd = new SqlCommand(
                "SELECT ISNULL(MAX(CAST(SUBSTRING([notificationId],2,LEN([notificationId])-1) AS INT)),0) FROM dbo.[Notification]", conn))
            {
                return "N" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3");
            }
        }

        private static string GetMaterialType(string extension)
        {
            switch (extension)
            {
                case ".pdf": return "PDF";
                case ".doc":
                case ".docx": return "Document";
                case ".ppt":
                case ".pptx": return "PPTX";
                case ".jpg":
                case ".jpeg":
                case ".png": return "Image";
                case ".mp4": return "Video";
                default: return "Other";
            }
        }

        #endregion
    }
}
