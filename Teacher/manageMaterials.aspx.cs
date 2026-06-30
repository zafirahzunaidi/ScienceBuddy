using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Teacher
{
    public partial class manageMaterials : Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        private static readonly HashSet<string> AllowedExtensions = new HashSet<string>(
            StringComparer.OrdinalIgnoreCase)
        { ".pdf", ".doc", ".docx", ".ppt", ".pptx", ".jpg", ".jpeg", ".png" };

        private const int MaxFileSize = 10 * 1024 * 1024; // 10 MB

        // ── Page Load ────────────────────────────────────────────────
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null)
            {
                Response.Redirect("~/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest(); return;
            }
            if (Session["role"] == null || Session["role"].ToString() != "Teacher")
            {
                Response.Redirect("~/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest(); return;
            }

            var master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                if (!AuthorizeTeacher()) return;
                LoadFilterDropdowns();
                LoadMaterials();
            }
        }

        // ── Authorization ────────────────────────────────────────────
        private bool AuthorizeTeacher()
        {
            string userId = Session["userId"].ToString();
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    const string sql = @"SELECT [status] FROM dbo.[Teacher] WHERE [userId] = @userId";
                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@userId", userId);
                        var val = cmd.ExecuteScalar();
                        if (val == null || val == DBNull.Value)
                        { pnlDenied.Visible = true; return false; }

                        string status = val.ToString();
                        if (string.Equals(status, "Certified", StringComparison.OrdinalIgnoreCase))
                        { pnlMain.Visible = true; return true; }
                        if (string.Equals(status, "Pending", StringComparison.OrdinalIgnoreCase))
                        { pnlPending.Visible = true; return false; }

                        pnlDenied.Visible = true; return false;
                    }
                }
            }
            catch { pnlDenied.Visible = true; return false; }
        }

        // ── Load filter dropdowns ────────────────────────────────────
        private void LoadFilterDropdowns()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                // Level filter
                ddlFilterLevel.Items.Clear();
                ddlFilterLevel.Items.Add(new ListItem("All Levels", ""));
                const string sqlLevels = "SELECT [levelId],[levelNameEN] FROM dbo.[Level] ORDER BY [levelId]";
                using (var cmd = new SqlCommand(sqlLevels, conn))
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                        ddlFilterLevel.Items.Add(new ListItem(rdr["levelNameEN"].ToString(), rdr["levelId"].ToString()));
                }
            }
        }

        // ── Load materials ───────────────────────────────────────────
        private void LoadMaterials()
        {
            string userId = Session["userId"].ToString();
            string search = txtSearch.Text.Trim();
            string levelFilter = ddlFilterLevel.SelectedValue;

            string sql = @"
                SELECT m.[materialId], m.[materialTitle], m.[materialContent],
                       m.[materialType], m.[fileUrl], m.[createdDate],
                       m.[status], m.[language],
                       ISNULL(st.[subtopicTitleEN],'—') AS subtopicName
                FROM dbo.[Material] m
                LEFT JOIN dbo.[Subtopic] st ON st.[subtopicId] = m.[subtopicId]
                LEFT JOIN dbo.[Unit] u ON u.[unitId] = st.[unitId]
                WHERE m.[createdByUserId] = @userId";

            if (!string.IsNullOrEmpty(search))
                sql += " AND (m.[materialTitle] LIKE @search OR m.[materialContent] LIKE @search)";
            if (!string.IsNullOrEmpty(levelFilter))
                sql += " AND u.[levelId] = @levelId";

            sql += " ORDER BY m.[createdDate] DESC";

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    if (!string.IsNullOrEmpty(search))
                        cmd.Parameters.AddWithValue("@search", "%" + search + "%");
                    if (!string.IsNullOrEmpty(levelFilter))
                        cmd.Parameters.AddWithValue("@levelId", levelFilter);

                    var da = new SqlDataAdapter(cmd);
                    var dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        pnlMaterials.Visible = true;
                        pnlEmpty.Visible = false;
                        rptMaterials.DataSource = dt;
                        rptMaterials.DataBind();
                    }
                    else
                    {
                        pnlMaterials.Visible = false;
                        pnlEmpty.Visible = true;
                    }
                }
            }
        }

        // ── Show upload form ─────────────────────────────────────────
        protected void btnShowUpload_Click(object sender, EventArgs e)
        {
            ResetForm();
            litFormTitle.Text = "Upload New Material";
            litFileRequired.Text = "*";
            pnlCurrentFile.Visible = false;
            pnlForm.Visible = true;
            LoadFormDropdowns(null, null, null);
        }

        // ── Cancel form ──────────────────────────────────────────────
        protected void btnCancel_Click(object sender, EventArgs e)
        {
            pnlForm.Visible = false;
            LoadMaterials();
        }

        // ── Search ───────────────────────────────────────────────────
        protected void btnSearch_Click(object sender, EventArgs e) { LoadMaterials(); }
        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlFilterLevel.SelectedIndex = 0;
            LoadMaterials();
        }
        protected void ddlFilterLevel_Changed(object sender, EventArgs e) { LoadMaterials(); }

        // ── Form dropdowns (Level → Unit → Subtopic) ─────────────────
        private void LoadFormDropdowns(string selectedLevel, string selectedUnit, string selectedSubtopic)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Levels
                ddlLevel.Items.Clear();
                ddlLevel.Items.Add(new ListItem("— Select Level —", ""));
                using (var cmd = new SqlCommand("SELECT [levelId],[levelNameEN] FROM dbo.[Level] ORDER BY [levelId]", conn))
                using (var rdr = cmd.ExecuteReader())
                    while (rdr.Read())
                        ddlLevel.Items.Add(new ListItem(rdr["levelNameEN"].ToString(), rdr["levelId"].ToString()));
                if (!string.IsNullOrEmpty(selectedLevel))
                    ddlLevel.SelectedValue = selectedLevel;

                // Units
                LoadUnits(conn, ddlLevel.SelectedValue);
                if (!string.IsNullOrEmpty(selectedUnit))
                    try { ddlUnit.SelectedValue = selectedUnit; } catch { }

                // Subtopics
                LoadSubtopics(conn, ddlUnit.SelectedValue);
                if (!string.IsNullOrEmpty(selectedSubtopic))
                    try { ddlSubtopic.SelectedValue = selectedSubtopic; } catch { }
            }
        }

        private void LoadUnits(SqlConnection conn, string levelId)
        {
            ddlUnit.Items.Clear();
            ddlUnit.Items.Add(new ListItem("— Select Unit —", ""));
            if (string.IsNullOrEmpty(levelId)) return;
            const string sql = "SELECT [unitId],[unitNameEN] FROM dbo.[Unit] WHERE [levelId] = @lid ORDER BY [orderNo]";
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@lid", levelId);
                using (var rdr = cmd.ExecuteReader())
                    while (rdr.Read())
                        ddlUnit.Items.Add(new ListItem(rdr["unitNameEN"].ToString(), rdr["unitId"].ToString()));
            }
        }

        private void LoadSubtopics(SqlConnection conn, string unitId)
        {
            ddlSubtopic.Items.Clear();
            ddlSubtopic.Items.Add(new ListItem("— Select Subtopic —", ""));
            if (string.IsNullOrEmpty(unitId)) return;
            const string sql = "SELECT [subtopicId],[subtopicTitleEN] FROM dbo.[Subtopic] WHERE [unitId] = @uid ORDER BY [orderNo]";
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@uid", unitId);
                using (var rdr = cmd.ExecuteReader())
                    while (rdr.Read())
                        ddlSubtopic.Items.Add(new ListItem(rdr["subtopicTitleEN"].ToString(), rdr["subtopicId"].ToString()));
            }
        }

        protected void ddlLevel_Changed(object sender, EventArgs e)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                LoadUnits(conn, ddlLevel.SelectedValue);
                LoadSubtopics(conn, "");
            }
        }

        protected void ddlUnit_Changed(object sender, EventArgs e)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                LoadSubtopics(conn, ddlUnit.SelectedValue);
            }
        }

        // ── Save (Insert or Update) ──────────────────────────────────
        protected void btnSave_Click(object sender, EventArgs e)
        {
            string title = txtTitle.Text.Trim();
            string description = txtDescription.Text.Trim();
            string language = ddlLanguage.SelectedValue;
            string subtopicId = ddlSubtopic.SelectedValue;
            string materialId = hidMaterialId.Value;
            bool isEdit = !string.IsNullOrEmpty(materialId);

            if (string.IsNullOrEmpty(title))
            { ShowMessage("Title is required.", true); return; }
            if (string.IsNullOrEmpty(subtopicId))
            { ShowMessage("Please select a subtopic.", true); return; }

            // File handling
            string fileUrl = null;
            string materialType = null;

            if (fuFile.HasFile)
            {
                string ext = Path.GetExtension(fuFile.FileName).ToLower();
                if (!AllowedExtensions.Contains(ext))
                { ShowMessage("Invalid file type. Accepted: PDF, DOC, DOCX, PPT, PPTX, JPG, JPEG, PNG.", true); return; }
                if (fuFile.PostedFile.ContentLength > MaxFileSize)
                { ShowMessage("File size exceeds 10 MB limit.", true); return; }

                materialType = GetMaterialType(ext);
                string fileName = Guid.NewGuid().ToString("N").Substring(0, 12) + ext;
                string relativePath = "Images/Material/" + fileName;
                string physicalDir = Server.MapPath("~/Images/Material/");
                if (!Directory.Exists(physicalDir))
                    Directory.CreateDirectory(physicalDir);
                fuFile.SaveAs(Path.Combine(physicalDir, fileName));
                fileUrl = relativePath;
            }
            else if (!isEdit)
            {
                ShowMessage("Please select a file to upload.", true); return;
            }

            string userId = Session["userId"].ToString();

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    if (isEdit)
                    {
                        // Verify ownership
                        if (!VerifyOwnership(conn, materialId, userId))
                        { ShowMessage("You do not have permission to edit this material.", true); return; }

                        string sqlUpdate = @"
                            UPDATE dbo.[Material] SET
                                [materialTitle] = @title,
                                [materialContent] = @desc,
                                [language] = @lang,
                                [subtopicId] = @subtopicId"
                            + (fileUrl != null ? ", [fileUrl] = @fileUrl, [materialType] = @mType" : "")
                            + " WHERE [materialId] = @id AND [createdByUserId] = @userId";

                        using (var cmd = new SqlCommand(sqlUpdate, conn))
                        {
                            cmd.Parameters.AddWithValue("@title", title);
                            cmd.Parameters.AddWithValue("@desc", (object)description ?? DBNull.Value);
                            cmd.Parameters.AddWithValue("@lang", language);
                            cmd.Parameters.AddWithValue("@subtopicId", subtopicId);
                            cmd.Parameters.AddWithValue("@id", materialId);
                            cmd.Parameters.AddWithValue("@userId", userId);
                            if (fileUrl != null)
                            {
                                cmd.Parameters.AddWithValue("@fileUrl", fileUrl);
                                cmd.Parameters.AddWithValue("@mType", materialType);
                            }
                            cmd.ExecuteNonQuery();
                        }
                        ShowMessage("Material updated successfully.", false);
                    }
                    else
                    {
                        string newId = GenerateNewId(conn);
                        const string sqlInsert = @"
                            INSERT INTO dbo.[Material]
                                ([materialId],[subtopicId],[createdByUserId],[materialTitle],
                                 [materialType],[fileUrl],[materialContent],[createdDate],
                                 [status],[language])
                            VALUES
                                (@id,@subtopicId,@userId,@title,
                                 @mType,@fileUrl,@desc,@createdDate,
                                 @status,@lang)";

                        using (var cmd = new SqlCommand(sqlInsert, conn))
                        {
                            cmd.Parameters.AddWithValue("@id", newId);
                            cmd.Parameters.AddWithValue("@subtopicId", subtopicId);
                            cmd.Parameters.AddWithValue("@userId", userId);
                            cmd.Parameters.AddWithValue("@title", title);
                            cmd.Parameters.AddWithValue("@mType", materialType);
                            cmd.Parameters.AddWithValue("@fileUrl", fileUrl);
                            cmd.Parameters.AddWithValue("@desc", (object)description ?? DBNull.Value);
                            cmd.Parameters.AddWithValue("@createdDate", DateTime.Now.ToString("yyyy-MM-dd"));
                            cmd.Parameters.AddWithValue("@status", "Pending");
                            cmd.Parameters.AddWithValue("@lang", language);
                            cmd.ExecuteNonQuery();
                        }
                        ShowMessage("Material uploaded successfully! It will be reviewed by admin.", false);
                    }
                }
            }
            catch
            {
                ShowMessage("An error occurred. Please try again.", true);
            }

            pnlForm.Visible = false;
            LoadMaterials();
        }

        // ── Repeater item command (Edit / Delete) ────────────────────
        protected void rptMaterials_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string materialId = e.CommandArgument.ToString();
            string userId = Session["userId"].ToString();

            if (e.CommandName == "DeleteMaterial")
            {
                try
                {
                    using (var conn = new SqlConnection(ConnStr))
                    {
                        conn.Open();
                        if (!VerifyOwnership(conn, materialId, userId))
                        { ShowMessage("You cannot delete this material.", true); return; }

                        const string sql = "DELETE FROM dbo.[Material] WHERE [materialId] = @id AND [createdByUserId] = @userId";
                        using (var cmd = new SqlCommand(sql, conn))
                        {
                            cmd.Parameters.AddWithValue("@id", materialId);
                            cmd.Parameters.AddWithValue("@userId", userId);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    ShowMessage("Material deleted.", false);
                }
                catch { ShowMessage("Could not delete material.", true); }
                LoadMaterials();
            }
            else if (e.CommandName == "EditMaterial")
            {
                LoadEditForm(materialId, userId);
            }
        }

        private void LoadEditForm(string materialId, string userId)
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    const string sql = @"
                        SELECT m.[materialId], m.[materialTitle], m.[materialContent],
                               m.[materialType], m.[fileUrl], m.[language], m.[subtopicId],
                               st.[unitId], u.[levelId]
                        FROM dbo.[Material] m
                        LEFT JOIN dbo.[Subtopic] st ON st.[subtopicId] = m.[subtopicId]
                        LEFT JOIN dbo.[Unit] u ON u.[unitId] = st.[unitId]
                        WHERE m.[materialId] = @id AND m.[createdByUserId] = @userId";

                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@id", materialId);
                        cmd.Parameters.AddWithValue("@userId", userId);
                        using (var rdr = cmd.ExecuteReader())
                        {
                            if (!rdr.Read())
                            { ShowMessage("Material not found.", true); return; }

                            hidMaterialId.Value = materialId;
                            txtTitle.Text = rdr["materialTitle"]?.ToString() ?? "";
                            txtDescription.Text = rdr["materialContent"]?.ToString() ?? "";
                            ddlLanguage.SelectedValue = rdr["language"]?.ToString() ?? "EN";

                            string levelId = rdr["levelId"]?.ToString();
                            string unitId = rdr["unitId"]?.ToString();
                            string subtopicId = rdr["subtopicId"]?.ToString();
                            string fileUrl = rdr["fileUrl"]?.ToString();

                            rdr.Close();

                            LoadFormDropdowns(levelId, unitId, subtopicId);

                            litFormTitle.Text = "Edit Material";
                            litFileRequired.Text = "(optional — leave blank to keep current file)";
                            if (!string.IsNullOrEmpty(fileUrl))
                            {
                                pnlCurrentFile.Visible = true;
                                litCurrentFile.Text = HttpUtility.HtmlEncode(
                                    Path.GetFileName(fileUrl));
                            }
                            pnlForm.Visible = true;
                        }
                    }
                }
            }
            catch { ShowMessage("Could not load material for editing.", true); }
        }

        // ── Utility methods ──────────────────────────────────────────
        private bool VerifyOwnership(SqlConnection conn, string materialId, string userId)
        {
            const string sql = "SELECT COUNT(*) FROM dbo.[Material] WHERE [materialId] = @id AND [createdByUserId] = @userId";
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@id", materialId);
                cmd.Parameters.AddWithValue("@userId", userId);
                return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }
        }

        private string GenerateNewId(SqlConnection conn)
        {
            const string sql = "SELECT MAX(CAST(SUBSTRING([materialId],2,LEN([materialId])-1) AS INT)) FROM dbo.[Material]";
            using (var cmd = new SqlCommand(sql, conn))
            {
                var val = cmd.ExecuteScalar();
                int next = (val != null && val != DBNull.Value) ? Convert.ToInt32(val) + 1 : 1;
                return "M" + next.ToString("D3");
            }
        }

        private void ResetForm()
        {
            hidMaterialId.Value = "";
            txtTitle.Text = "";
            txtDescription.Text = "";
            ddlLanguage.SelectedIndex = 0;
            pnlCurrentFile.Visible = false;
        }

        private void ShowMessage(string msg, bool isError)
        {
            pnlMessage.Visible = true;
            string bg = isError ? "background:#FEF2F2;color:#DC2626;border:1px solid #FEE2E2;"
                                : "background:#ECFDF5;color:#059669;border:1px solid #D1FAE5;";
            litMessage.Text = "<div style='" + bg + "padding:.75rem 1rem;border-radius:10px;font-size:.85rem;font-weight:600;'>"
                + HttpUtility.HtmlEncode(msg) + "</div>";
        }

        private static string GetMaterialType(string ext)
        {
            switch (ext.ToLower())
            {
                case ".pdf": return "PDF";
                case ".doc": case ".docx": return "Document";
                case ".ppt": case ".pptx": return "PPTX";
                case ".jpg": case ".jpeg": case ".png": return "Image";
                default: return "Other";
            }
        }

        protected string GetFileIcon(string materialType)
        {
            if (string.IsNullOrEmpty(materialType)) return "bi-file-earmark";
            string t = materialType.ToLower();
            if (t.Contains("pdf")) return "bi-file-earmark-pdf-fill";
            if (t.Contains("doc")) return "bi-file-earmark-word-fill";
            if (t.Contains("ppt")) return "bi-file-earmark-slides-fill";
            if (t.Contains("image") || t.Contains("jpg") || t.Contains("png")) return "bi-file-earmark-image-fill";
            return "bi-file-earmark-fill";
        }

        protected string GetStatusStyle(string status)
        {
            if (string.IsNullOrEmpty(status)) return "background:#F3F4F6;color:#6B7280;";
            string s = status.ToLower();
            if (s == "approved") return "background:#D1FAE5;color:#059669;";
            if (s == "rejected") return "background:#FEE2E2;color:#DC2626;";
            return "background:#FEF3C7;color:#D97706;"; // Pending
        }

        protected string TruncateText(string text, int maxLength)
        {
            if (string.IsNullOrEmpty(text)) return "No description";
            return text.Length <= maxLength ? text : text.Substring(0, maxLength) + "…";
        }
    }
}
