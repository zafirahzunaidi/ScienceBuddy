using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Teacher
{
    public partial class manageMaterials : Page
    {
        #region Properties

        private bool _isCertified = false;

        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        private static readonly HashSet<string> AllowedExtensions = new HashSet<string>(
            StringComparer.OrdinalIgnoreCase)
        { ".pdf", ".doc", ".docx", ".ppt", ".pptx", ".jpg", ".jpeg", ".png" };

        private const int MaxFileSize = 10 * 1024 * 1024;

        protected string CurrentLanguage
        {
            get
            {
                string lang = Session["preferredLanguage"] as string;
                return string.IsNullOrEmpty(lang) ? "EN" : lang;
            }
        }

        /// <summary>Bilingual text helper — returns English or Malay based on session preference.</summary>
        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

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

            var master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            if (!AuthorizeTeacher())
                return;

            // Handle edit modal postback triggered from client-side __doPostBack
            string eventTarget = Request["__EVENTTARGET"];
            string eventArg = Request["__EVENTARGUMENT"];

            if (eventTarget == "LoadEdit" && !string.IsNullOrEmpty(eventArg))
            {
                LoadEditForm(eventArg, Session["userId"].ToString());

                if (!IsPostBack)
                {
                    LoadFilterDropdowns();
                    LoadMaterials();
                }
                return;
            }

            if (!IsPostBack)
            {
                LoadFilterDropdowns();
                SetTabUI();
                LoadMaterials();
            }
        }

        #endregion

        #region Event Handlers

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadForActiveTab();
        }

        protected void btnTabMine_Click(object sender, EventArgs e)
        {
            hidActiveTab.Value = "mine";
            SetTabUI();
            LoadForActiveTab();
        }

        protected void btnTabDiscover_Click(object sender, EventArgs e)
        {
            hidActiveTab.Value = "discover";
            SetTabUI();
            LoadForActiveTab();
        }

        protected void ddlFilterLevel_Changed(object sender, EventArgs e)
        {
            ddlFilterUnit.Items.Clear();
            ddlFilterUnit.Items.Add(new ListItem(T("All Units", "Semua Unit"), ""));

            string selectedLevelId = ddlFilterLevel.SelectedValue;

            if (!string.IsNullOrEmpty(selectedLevelId))
            {
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
                                ddlFilterUnit.Items.Add(new ListItem(reader["unitNameEN"].ToString(), reader["unitId"].ToString()));
                        }
                    }
                }
            }

            LoadForActiveTab();
        }

        protected void ddlFilterUnit_Changed(object sender, EventArgs e)
        {
            LoadForActiveTab();
        }

        protected void ddlFilterType_Changed(object sender, EventArgs e)
        {
            LoadForActiveTab();
        }

        protected void ddlFilterStatus_Changed(object sender, EventArgs e)
        {
            LoadForActiveTab();
        }

        protected void btnChip_Click(object sender, EventArgs e)
        {
            var btn = sender as LinkButton;
            string filterStatus = btn?.CommandArgument ?? "";

            // Update chip active states
            btnChipAll.CssClass = "tc-manage-materials-chip" + (filterStatus == "" ? " active" : "");
            btnChipApproved.CssClass = "tc-manage-materials-chip" + (filterStatus == "Approved" ? " active" : "");
            btnChipPending.CssClass = "tc-manage-materials-chip" + (filterStatus == "Pending" ? " active" : "");
            btnChipRejected.CssClass = "tc-manage-materials-chip" + (filterStatus == "Rejected" ? " active" : "");

            // Sync the dropdown filter to match chip selection
            try { ddlFilterStatus.SelectedValue = filterStatus; } catch { }

            LoadForActiveTab();
        }

        protected void ddlLevel_Changed(object sender, EventArgs e)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                ddlUnit.Items.Clear();
                ddlUnit.Items.Add(new ListItem("— Select Unit —", ""));

                string selectedLevelId = ddlLevel.SelectedValue;

                if (!string.IsNullOrEmpty(selectedLevelId))
                {
                    using (var cmd = new SqlCommand(
                        "SELECT [unitId],[unitNameEN] FROM dbo.[Unit] WHERE [levelId]=@l ORDER BY [orderNo]", conn))
                    {
                        cmd.Parameters.AddWithValue("@l", selectedLevelId);
                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                                ddlUnit.Items.Add(new ListItem(reader["unitNameEN"].ToString(), reader["unitId"].ToString()));
                        }
                    }
                }

                ddlSubtopic.Items.Clear();
                ddlSubtopic.Items.Add(new ListItem("— Select Subtopic —", ""));
            }

            hidShowEditModal.Value = "1";
        }

        protected void ddlUnit_Changed(object sender, EventArgs e)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                ddlSubtopic.Items.Clear();
                ddlSubtopic.Items.Add(new ListItem("— Select Subtopic —", ""));

                string selectedUnitId = ddlUnit.SelectedValue;

                if (!string.IsNullOrEmpty(selectedUnitId))
                {
                    using (var cmd = new SqlCommand(
                        "SELECT [subtopicId],[subtopicTitleEN] FROM dbo.[Subtopic] WHERE [unitId]=@u ORDER BY [orderNo]", conn))
                    {
                        cmd.Parameters.AddWithValue("@u", selectedUnitId);
                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                                ddlSubtopic.Items.Add(new ListItem(reader["subtopicTitleEN"].ToString(), reader["subtopicId"].ToString()));
                        }
                    }
                }
            }

            hidShowEditModal.Value = "1";
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            System.Diagnostics.Debug.WriteLine("[btnSave_Click] START " + DateTime.Now.ToString("HH:mm:ss.fff"));

            string materialId = hidMaterialId.Value;
            string teacherId = Session["userId"].ToString();
            string title = txtTitle.Text.Trim();
            string description = txtDescription.Text.Trim();
            string language = ddlLanguage.SelectedValue;
            string selectedLevelId = ddlLevel.SelectedValue;
            string selectedUnitId = ddlUnit.SelectedValue;
            string subtopicId = ddlSubtopic.SelectedValue;

            // Server-side validation (same rules as upload page)
            if (!ValidateEditForm(title, language, selectedLevelId, selectedUnitId, subtopicId))
                return;

            System.Diagnostics.Debug.WriteLine("[btnSave_Click] Validation passed " + DateTime.Now.ToString("HH:mm:ss.fff"));

            // Change detection — compare with original hidden field values
            bool hasNewFile = fuFile.HasFile;
            bool changed = hasNewFile ||
                !string.Equals(title, hidOrigTitle.Value.Trim(), StringComparison.Ordinal) ||
                !string.Equals(description, hidOrigDesc.Value.Trim(), StringComparison.Ordinal) ||
                !string.Equals(language, hidOrigLang.Value, StringComparison.Ordinal) ||
                !string.Equals(selectedLevelId, hidOrigLevel.Value, StringComparison.Ordinal) ||
                !string.Equals(selectedUnitId, hidOrigUnit.Value, StringComparison.Ordinal) ||
                !string.Equals(subtopicId, hidOrigSubtopic.Value, StringComparison.Ordinal);

            if (!changed)
            {
                hidToast.Value = T("No changes were made.", "Tiada perubahan dibuat.");
                LoadMaterials();
                return;
            }

            // File validation (only if a new file is uploaded)
            string fileUrl = null;
            string materialType = null;

            if (hasNewFile)
            {
                System.Diagnostics.Debug.WriteLine("[btnSave_Click] File validation start " + DateTime.Now.ToString("HH:mm:ss.fff"));

                string ext = Path.GetExtension(fuFile.FileName).ToLower();

                if (!AllowedExtensions.Contains(ext))
                {
                    hidToast.Value = "Invalid file type.";
                    hidShowEditModal.Value = "1";
                    LoadMaterials();
                    return;
                }

                if (fuFile.PostedFile.ContentLength > MaxFileSize)
                {
                    hidToast.Value = "File exceeds 10 MB.";
                    hidShowEditModal.Value = "1";
                    LoadMaterials();
                    return;
                }

                materialType = GetMaterialType(ext);
                string fileName = Guid.NewGuid().ToString("N").Substring(0, 12) + ext;
                string uploadDir = Server.MapPath("~/Images/Material/");

                if (!Directory.Exists(uploadDir))
                    Directory.CreateDirectory(uploadDir);

                System.Diagnostics.Debug.WriteLine("[btnSave_Click] SaveAs start " + DateTime.Now.ToString("HH:mm:ss.fff"));
                fuFile.SaveAs(Path.Combine(uploadDir, fileName));
                System.Diagnostics.Debug.WriteLine("[btnSave_Click] SaveAs done " + DateTime.Now.ToString("HH:mm:ss.fff"));

                fileUrl = fileName;
            }

            try
            {
                System.Diagnostics.Debug.WriteLine("[btnSave_Click] DB connection start " + DateTime.Now.ToString("HH:mm:ss.fff"));

                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    System.Diagnostics.Debug.WriteLine("[btnSave_Click] Ownership check " + DateTime.Now.ToString("HH:mm:ss.fff"));

                    if (!VerifyOwnership(conn, materialId, teacherId))
                    {
                        hidToast.Value = "Permission denied.";
                        LoadMaterials();
                        return;
                    }

                    System.Diagnostics.Debug.WriteLine("[btnSave_Click] SQL UPDATE start " + DateTime.Now.ToString("HH:mm:ss.fff"));

                    // Any edit resets status to Pending for admin re-review
                    string sql = @"UPDATE dbo.[Material] SET [materialTitle]=@t,[materialContent]=@d,[language]=@l,[subtopicId]=@st,[status]='Pending',[reviewedDate]=NULL"
                        + (fileUrl != null ? ",[fileUrl]=@f,[materialType]=@mt" : "")
                        + " WHERE [materialId]=@id AND [createdByUserId]=@uid";

                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@t", title);
                        cmd.Parameters.AddWithValue("@d", (object)description ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@l", language);
                        cmd.Parameters.AddWithValue("@st", subtopicId);
                        cmd.Parameters.AddWithValue("@id", materialId);
                        cmd.Parameters.AddWithValue("@uid", teacherId);

                        if (fileUrl != null)
                        {
                            cmd.Parameters.AddWithValue("@f", fileUrl);
                            cmd.Parameters.AddWithValue("@mt", materialType);
                        }

                        cmd.ExecuteNonQuery();
                    }

                    System.Diagnostics.Debug.WriteLine("[btnSave_Click] SQL UPDATE done " + DateTime.Now.ToString("HH:mm:ss.fff"));
                }

                hidToast.Value = T("Material updated successfully and submitted for review.",
                    "Bahan berjaya dikemas kini dan dihantar untuk semakan.");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[btnSave_Click] ERROR: " + ex.Message);
                hidToast.Value = T("An error occurred. Please try again.", "Ralat berlaku. Sila cuba lagi.");
            }

            System.Diagnostics.Debug.WriteLine("[btnSave_Click] LoadMaterials start " + DateTime.Now.ToString("HH:mm:ss.fff"));
            LoadMaterials();
            System.Diagnostics.Debug.WriteLine("[btnSave_Click] END " + DateTime.Now.ToString("HH:mm:ss.fff"));
        }

        protected void btnConfirmDelete_Click(object sender, EventArgs e)
        {
            string materialId = hidDeleteId.Value;
            string teacherId = Session["userId"].ToString();

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    if (!VerifyOwnership(conn, materialId, teacherId))
                    {
                        hidToast.Value = "Permission denied.";
                        LoadForActiveTab();
                        return;
                    }

                    // Soft delete — marks material as Deleted rather than removing the row
                    using (var cmd = new SqlCommand(
                        "UPDATE dbo.[Material] SET [status]='Deleted' WHERE [materialId]=@id AND [createdByUserId]=@uid", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", materialId);
                        cmd.Parameters.AddWithValue("@uid", teacherId);
                        cmd.ExecuteNonQuery();
                    }
                }

                hidToast.Value = T("Material deleted successfully.", "Bahan berjaya dipadam.");
            }
            catch
            {
                hidToast.Value = "Could not delete material.";
            }

            LoadForActiveTab();
        }

        protected void rptMaterials_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            HandleFileCommand(e.CommandName, e.CommandArgument?.ToString());
        }

        protected void rptDiscover_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            HandleFileCommand(e.CommandName, e.CommandArgument?.ToString());
        }

        #endregion

        #region Data Loading

        private void LoadFilterDropdowns()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Levels
                ddlFilterLevel.Items.Clear();
                ddlFilterLevel.Items.Add(new ListItem(T("All Levels", "Semua Tahap"), ""));

                using (var cmd = new SqlCommand("SELECT [levelId],[levelNameEN] FROM dbo.[Level] ORDER BY [levelId]", conn))
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                        ddlFilterLevel.Items.Add(new ListItem(reader["levelNameEN"].ToString(), reader["levelId"].ToString()));
                }

                // Units (starts empty, populated on level change)
                ddlFilterUnit.Items.Clear();
                ddlFilterUnit.Items.Add(new ListItem(T("All Units", "Semua Unit"), ""));

                // Material types
                ddlFilterType.Items.Clear();
                ddlFilterType.Items.Add(new ListItem(T("All Types", "Semua Jenis"), ""));
                ddlFilterType.Items.Add(new ListItem("PDF", "PDF"));
                ddlFilterType.Items.Add(new ListItem(T("Document", "Dokumen"), "Document"));
                ddlFilterType.Items.Add(new ListItem("PPTX", "PPTX"));
                ddlFilterType.Items.Add(new ListItem(T("Image", "Imej"), "Image"));

                // Status
                ddlFilterStatus.Items.Clear();
                ddlFilterStatus.Items.Add(new ListItem(T("All Status", "Semua Status"), ""));
                ddlFilterStatus.Items.Add(new ListItem(T("Pending", "Menunggu"), "Pending"));
                ddlFilterStatus.Items.Add(new ListItem(T("Approved", "Diluluskan"), "Approved"));
                ddlFilterStatus.Items.Add(new ListItem(T("Rejected", "Ditolak"), "Rejected"));

                // Search bar localisation
                txtSearch.Attributes["placeholder"] = T("Search materials...", "Cari bahan...");
                btnSearch.Text = T("Search", "Cari");
            }
        }

        private void LoadMaterials()
        {
            // Non-certified teachers cannot see My Materials list — pending panel is shown via SetTabUI
            if (!_isCertified)
            {
                pnlMaterials.Visible = false;
                pnlEmpty.Visible = false;
                pnlDiscover.Visible = false;
                pnlDiscoverEmpty.Visible = false;
                return;
            }

            string teacherId = Session["userId"].ToString();
            string searchTerm = txtSearch.Text.Trim();
            string filterLevel = ddlFilterLevel.SelectedValue;
            string filterUnit = ddlFilterUnit.SelectedValue;
            string filterType = ddlFilterType.SelectedValue;
            string filterStatus = ddlFilterStatus.SelectedValue;

            string sql = @"SELECT m.[materialId],m.[materialTitle],m.[materialContent],m.[materialType],
                m.[fileUrl],m.[createdDate],m.[status],m.[language],ISNULL(st.[subtopicTitleEN],'—') AS subtopicName
                FROM dbo.[Material] m LEFT JOIN dbo.[Subtopic] st ON st.[subtopicId]=m.[subtopicId]
                LEFT JOIN dbo.[Unit] u ON u.[unitId]=st.[unitId] WHERE m.[createdByUserId]=@userId AND (m.[status] IS NULL OR m.[status]<>'Deleted')";

            if (!string.IsNullOrEmpty(searchTerm)) sql += " AND (m.[materialTitle] LIKE @s OR m.[materialContent] LIKE @s)";
            if (!string.IsNullOrEmpty(filterLevel)) sql += " AND u.[levelId]=@lvl";
            if (!string.IsNullOrEmpty(filterUnit)) sql += " AND u.[unitId]=@unit";
            if (!string.IsNullOrEmpty(filterType)) sql += " AND m.[materialType]=@type";
            if (!string.IsNullOrEmpty(filterStatus)) sql += " AND m.[status]=@status";
            sql += " ORDER BY m.[createdDate] DESC";

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", teacherId);
                    if (!string.IsNullOrEmpty(searchTerm)) cmd.Parameters.AddWithValue("@s", "%" + searchTerm + "%");
                    if (!string.IsNullOrEmpty(filterLevel)) cmd.Parameters.AddWithValue("@lvl", filterLevel);
                    if (!string.IsNullOrEmpty(filterUnit)) cmd.Parameters.AddWithValue("@unit", filterUnit);
                    if (!string.IsNullOrEmpty(filterType)) cmd.Parameters.AddWithValue("@type", filterType);
                    if (!string.IsNullOrEmpty(filterStatus)) cmd.Parameters.AddWithValue("@status", filterStatus);

                    var materialList = new DataTable();
                    new SqlDataAdapter(cmd).Fill(materialList);

                    pnlMaterials.Visible = materialList.Rows.Count > 0;
                    pnlEmpty.Visible = materialList.Rows.Count == 0;
                    pnlDiscover.Visible = false;
                    pnlDiscoverEmpty.Visible = false;

                    if (materialList.Rows.Count == 0)
                        SetEmptyStateContent(filterStatus);

                    if (materialList.Rows.Count > 0)
                    {
                        rptMaterials.DataSource = materialList;
                        rptMaterials.DataBind();
                    }
                }
            }
        }

        private void LoadDiscoverMaterials()
        {
            string teacherId = Session["userId"].ToString();
            string searchTerm = txtSearch.Text.Trim();
            string filterLevel = ddlFilterLevel.SelectedValue;
            string filterUnit = ddlFilterUnit.SelectedValue;
            string filterType = ddlFilterType.SelectedValue;

            string sql = @"SELECT m.[materialId],m.[materialTitle],m.[materialContent],m.[materialType],
                m.[fileUrl],m.[createdDate],m.[language],ISNULL(st.[subtopicTitleEN],'—') AS subtopicName,
                COALESCE(t.[name],u2.[username],'Teacher') AS teacherName
                FROM dbo.[Material] m LEFT JOIN dbo.[Subtopic] st ON st.[subtopicId]=m.[subtopicId]
                LEFT JOIN dbo.[Unit] un ON un.[unitId]=st.[unitId]
                LEFT JOIN dbo.[User] u2 ON u2.[userId]=m.[createdByUserId]
                LEFT JOIN dbo.[Teacher] t ON t.[userId]=m.[createdByUserId]
                WHERE m.[createdByUserId]<>@userId AND m.[status]='Approved'";

            if (!string.IsNullOrEmpty(searchTerm)) sql += " AND (m.[materialTitle] LIKE @s OR m.[materialContent] LIKE @s)";
            if (!string.IsNullOrEmpty(filterLevel)) sql += " AND un.[levelId]=@lvl";
            if (!string.IsNullOrEmpty(filterUnit)) sql += " AND un.[unitId]=@unit";
            if (!string.IsNullOrEmpty(filterType)) sql += " AND m.[materialType]=@type";
            sql += " ORDER BY m.[createdDate] DESC";

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", teacherId);
                    if (!string.IsNullOrEmpty(searchTerm)) cmd.Parameters.AddWithValue("@s", "%" + searchTerm + "%");
                    if (!string.IsNullOrEmpty(filterLevel)) cmd.Parameters.AddWithValue("@lvl", filterLevel);
                    if (!string.IsNullOrEmpty(filterUnit)) cmd.Parameters.AddWithValue("@unit", filterUnit);
                    if (!string.IsNullOrEmpty(filterType)) cmd.Parameters.AddWithValue("@type", filterType);

                    var materialList = new DataTable();
                    new SqlDataAdapter(cmd).Fill(materialList);

                    pnlDiscover.Visible = materialList.Rows.Count > 0;
                    pnlDiscoverEmpty.Visible = materialList.Rows.Count == 0;
                    pnlMaterials.Visible = false;
                    pnlEmpty.Visible = false;

                    if (materialList.Rows.Count > 0)
                    {
                        rptDiscover.DataSource = materialList;
                        rptDiscover.DataBind();
                    }
                }
            }
        }

        private void LoadEditForm(string materialId, string teacherId)
        {
            pnlMain.Visible = true;

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    const string sql = @"SELECT m.*,st.[unitId],u.[levelId] FROM dbo.[Material] m
                        LEFT JOIN dbo.[Subtopic] st ON st.[subtopicId]=m.[subtopicId]
                        LEFT JOIN dbo.[Unit] u ON u.[unitId]=st.[unitId]
                        WHERE m.[materialId]=@id AND m.[createdByUserId]=@uid";

                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@id", materialId);
                        cmd.Parameters.AddWithValue("@uid", teacherId);

                        using (var reader = cmd.ExecuteReader())
                        {
                            if (!reader.Read())
                                return;

                            hidMaterialId.Value = materialId;
                            txtTitle.Text = reader["materialTitle"]?.ToString() ?? "";
                            txtDescription.Text = reader["materialContent"]?.ToString() ?? "";

                            string langVal = reader["language"]?.ToString() ?? "EN";
                            try { ddlLanguage.SelectedValue = langVal; } catch { }

                            string levelId = reader["levelId"]?.ToString();
                            string unitId = reader["unitId"]?.ToString();
                            string subtopicId = reader["subtopicId"]?.ToString();
                            string fileUrl = reader["fileUrl"]?.ToString();
                            string matStatus = reader["status"]?.ToString() ?? "";

                            reader.Close();

                            // Store original values for change detection on save
                            hidOrigTitle.Value = txtTitle.Text;
                            hidOrigDesc.Value = txtDescription.Text;
                            hidOrigLang.Value = langVal;
                            hidOrigLevel.Value = levelId ?? "";
                            hidOrigUnit.Value = unitId ?? "";
                            hidOrigSubtopic.Value = subtopicId ?? "";

                            LoadFormDropdowns(conn, levelId, unitId, subtopicId);

                            // Show current file info in modal
                            if (!string.IsNullOrEmpty(fileUrl))
                            {
                                pnlCurrentFile.Visible = true;
                                litCurrentFile.Text = HttpUtility.HtmlEncode(Path.GetFileName(fileUrl));
                            }

                            // Rejected materials use "Resubmit" wording
                            bool isResubmit = matStatus.Equals("Rejected", StringComparison.OrdinalIgnoreCase);
                            litFormTitle.Text = isResubmit ? "Resubmit Material" : "Edit Material";
                            litSaveBtnText.Text = "Confirm Changes";
                            hidMaterialStatus.Value = matStatus;

                            hidShowEditModal.Value = "1";
                        }
                    }
                }
            }
            catch { }

            LoadMaterials();
        }

        private void LoadFormDropdowns(SqlConnection conn, string selectedLevelId, string selectedUnitId, string selectedSubtopicId)
        {
            // Levels
            ddlLevel.Items.Clear();
            ddlLevel.Items.Add(new ListItem("— Select Level —", ""));

            using (var cmd = new SqlCommand("SELECT [levelId],[levelNameEN] FROM dbo.[Level] ORDER BY [levelId]", conn))
            using (var reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                    ddlLevel.Items.Add(new ListItem(reader["levelNameEN"].ToString(), reader["levelId"].ToString()));
            }

            if (!string.IsNullOrEmpty(selectedLevelId))
                try { ddlLevel.SelectedValue = selectedLevelId; } catch { }

            // Units (filtered by selected level)
            ddlUnit.Items.Clear();
            ddlUnit.Items.Add(new ListItem("— Select Unit —", ""));

            if (!string.IsNullOrEmpty(selectedLevelId))
            {
                using (var cmd = new SqlCommand(
                    "SELECT [unitId],[unitNameEN] FROM dbo.[Unit] WHERE [levelId]=@l ORDER BY [orderNo]", conn))
                {
                    cmd.Parameters.AddWithValue("@l", selectedLevelId);
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                            ddlUnit.Items.Add(new ListItem(reader["unitNameEN"].ToString(), reader["unitId"].ToString()));
                    }
                }
            }

            if (!string.IsNullOrEmpty(selectedUnitId))
                try { ddlUnit.SelectedValue = selectedUnitId; } catch { }

            // Subtopics (filtered by selected unit)
            ddlSubtopic.Items.Clear();
            ddlSubtopic.Items.Add(new ListItem("— Select Subtopic —", ""));

            if (!string.IsNullOrEmpty(selectedUnitId))
            {
                using (var cmd = new SqlCommand(
                    "SELECT [subtopicId],[subtopicTitleEN] FROM dbo.[Subtopic] WHERE [unitId]=@u ORDER BY [orderNo]", conn))
                {
                    cmd.Parameters.AddWithValue("@u", selectedUnitId);
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                            ddlSubtopic.Items.Add(new ListItem(reader["subtopicTitleEN"].ToString(), reader["subtopicId"].ToString()));
                    }
                }
            }

            if (!string.IsNullOrEmpty(selectedSubtopicId))
                try { ddlSubtopic.SelectedValue = selectedSubtopicId; } catch { }
        }

        #endregion

        #region Database Operations

        private bool AuthorizeTeacher()
        {
            string teacherId = Session["userId"].ToString();

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    using (var cmd = new SqlCommand(
                        "SELECT [status] FROM dbo.[Teacher] WHERE [userId]=@u", conn))
                    {
                        cmd.Parameters.AddWithValue("@u", teacherId);
                        var result = cmd.ExecuteScalar();

                        if (result == null || result == DBNull.Value)
                        {
                            pnlDenied.Visible = true;
                            return false;
                        }

                        string certStatus = result.ToString();

                        if (certStatus.Equals("Certified", StringComparison.OrdinalIgnoreCase))
                        {
                            _isCertified = true;
                            pnlMain.Visible = true;
                            return true;
                        }

                        if (certStatus.Equals("Pending", StringComparison.OrdinalIgnoreCase))
                        {
                            _isCertified = false;
                            pnlMain.Visible = true;
                            return true;
                        }

                        pnlDenied.Visible = true;
                        return false;
                    }
                }
            }
            catch
            {
                pnlDenied.Visible = true;
                return false;
            }
        }

        private bool VerifyOwnership(SqlConnection conn, string materialId, string teacherId)
        {
            using (var cmd = new SqlCommand(
                "SELECT COUNT(*) FROM dbo.[Material] WHERE [materialId]=@id AND [createdByUserId]=@u", conn))
            {
                cmd.Parameters.AddWithValue("@id", materialId);
                cmd.Parameters.AddWithValue("@u", teacherId);
                return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }
        }

        #endregion

        #region Helper Methods

        private void LoadForActiveTab()
        {
            SetTabUI();

            if (hidActiveTab.Value == "discover")
                LoadDiscoverMaterials();
            else
                LoadMaterials();
        }

        private void SetTabUI()
        {
            bool isMineTab = hidActiveTab.Value != "discover";

            btnTabMine.CssClass = "tc-manage-materials-tab" + (isMineTab ? " active" : "");
            btnTabDiscover.CssClass = "tc-manage-materials-tab" + (!isMineTab ? " active" : "");

            // Upload button: visible on Mine tab, enabled only when certified
            pnlUploadBtn.Visible = isMineTab;
            if (isMineTab)
            {
                pnlUploadEnabled.Visible = _isCertified;
                pnlUploadDisabled.Visible = !_isCertified;
            }

            // Filter bar and status chips: visible only when certified AND on Mine tab
            pnlFilterBar.Visible = isMineTab && _isCertified;
            pnlStatusChips.Visible = isMineTab && _isCertified;

            // Pending certification panel: visible when on Mine tab and not certified
            pnlMyMaterialsPending.Visible = isMineTab && !_isCertified;
        }

        private bool ValidateEditForm(string title, string language, string levelId, string unitId, string subtopicId)
        {
            if (string.IsNullOrEmpty(title))
            {
                hidToast.Value = "Title is required.";
                hidShowEditModal.Value = "1";
                LoadMaterials();
                return false;
            }

            if (string.IsNullOrEmpty(language))
            {
                hidToast.Value = "Language is required.";
                hidShowEditModal.Value = "1";
                LoadMaterials();
                return false;
            }

            if (string.IsNullOrEmpty(levelId))
            {
                hidToast.Value = "Level is required.";
                hidShowEditModal.Value = "1";
                LoadMaterials();
                return false;
            }

            if (string.IsNullOrEmpty(unitId))
            {
                hidToast.Value = "Unit is required.";
                hidShowEditModal.Value = "1";
                LoadMaterials();
                return false;
            }

            if (string.IsNullOrEmpty(subtopicId))
            {
                hidToast.Value = "Subtopic is required.";
                hidShowEditModal.Value = "1";
                LoadMaterials();
                return false;
            }

            return true;
        }

        private void SetEmptyStateContent(string filterStatus)
        {
            switch ((filterStatus ?? "").ToLower())
            {
                case "approved":
                    litEmptyTitle.Text = T("No approved materials found.", "Tiada bahan yang diluluskan dijumpai.");
                    litEmptyDesc.Text = T("You don't have any approved learning materials at the moment.",
                        "Anda tidak mempunyai bahan pembelajaran yang diluluskan buat masa ini.");
                    pnlEmptyUploadBtn.Visible = false;
                    break;

                case "pending":
                    litEmptyTitle.Text = T("No pending materials found.", "Tiada bahan menunggu dijumpai.");
                    litEmptyDesc.Text = T("You don't have any learning materials waiting for review.",
                        "Anda tidak mempunyai bahan pembelajaran yang menunggu semakan.");
                    pnlEmptyUploadBtn.Visible = false;
                    break;

                case "rejected":
                    litEmptyTitle.Text = T("No rejected materials found.", "Tiada bahan ditolak dijumpai.");
                    litEmptyDesc.Text = T("You don't have any rejected learning materials.",
                        "Anda tidak mempunyai bahan pembelajaran yang ditolak.");
                    pnlEmptyUploadBtn.Visible = false;
                    break;

                default:
                    litEmptyTitle.Text = T("You haven't uploaded any learning materials yet.",
                        "Anda belum memuat naik sebarang bahan pembelajaran.");
                    litEmptyDesc.Text = T("Click \"Upload Material\" to add your first learning resource.",
                        "Klik \"Muat Naik Bahan\" untuk menambah sumber pembelajaran pertama anda.");
                    pnlEmptyUploadBtn.Visible = true;
                    break;
            }
        }

        private void HandleFileCommand(string commandName, string fileUrl)
        {
            if (string.IsNullOrEmpty(fileUrl))
                return;

            string filePath = GetFilePath(fileUrl);
            string physicalPath = Server.MapPath("~/" + filePath);

            if (commandName == "ViewMaterial")
            {
                // Browser will display the file inline (preview)
                Response.Redirect(ResolveUrl("~/") + filePath, false);
                Context.ApplicationInstance.CompleteRequest();
            }
            else if (commandName == "DownloadMaterial")
            {
                if (File.Exists(physicalPath))
                {
                    string fileName = Path.GetFileName(physicalPath);
                    Response.Clear();
                    Response.ContentType = "application/octet-stream";
                    Response.AddHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
                    Response.TransmitFile(physicalPath);
                    Response.End();
                }
            }
        }

        private static string GetMaterialType(string ext)
        {
            switch (ext)
            {
                case ".pdf": return "PDF";
                case ".doc":
                case ".docx": return "Document";
                case ".ppt":
                case ".pptx": return "PPTX";
                case ".jpg":
                case ".jpeg":
                case ".png": return "Image";
                default: return "Other";
            }
        }

        /// <summary>Checks if a rich-text value is effectively empty (only empty HTML tags or whitespace).</summary>
        private static bool IsEmptyRichText(string val)
        {
            if (string.IsNullOrWhiteSpace(val))
                return true;

            string stripped = Regex.Replace(val, @"<[^>]*>", "");
            stripped = stripped.Replace("&nbsp;", " ").Trim();
            return stripped.Length == 0;
        }

        // ---- Protected helpers called from ASPX markup ----

        protected string GetIconCss(string t)
        {
            if (string.IsNullOrEmpty(t)) return "tc-manage-materials-ico-default";

            string lower = t.ToLower();
            if (lower.Contains("pdf")) return "tc-manage-materials-ico-pdf";
            if (lower.Contains("doc")) return "tc-manage-materials-ico-doc";
            if (lower.Contains("ppt")) return "tc-manage-materials-ico-ppt";
            if (lower.Contains("image") || lower.Contains("jpg") || lower.Contains("png")) return "tc-manage-materials-ico-image";
            if (lower.Contains("video")) return "tc-manage-materials-ico-video";
            return "tc-manage-materials-ico-default";
        }

        protected string GetTypeBadgeCss(string t)
        {
            if (string.IsNullOrEmpty(t)) return "tc-manage-materials-meta-badge-default";

            string lower = t.ToLower();
            if (lower.Contains("pdf")) return "tc-manage-materials-meta-badge-pdf";
            if (lower.Contains("doc")) return "tc-manage-materials-meta-badge-doc";
            if (lower.Contains("ppt")) return "tc-manage-materials-meta-badge-ppt";
            if (lower.Contains("image") || lower.Contains("jpg") || lower.Contains("png")) return "tc-manage-materials-meta-badge-image";
            if (lower.Contains("video")) return "tc-manage-materials-meta-badge-video";
            return "tc-manage-materials-meta-badge-default";
        }

        protected string GetFileIcon(string t)
        {
            if (string.IsNullOrEmpty(t)) return "bi-file-earmark";

            string lower = t.ToLower();
            if (lower.Contains("pdf")) return "bi-file-earmark-pdf-fill";
            if (lower.Contains("doc")) return "bi-file-earmark-word-fill";
            if (lower.Contains("ppt")) return "bi-file-earmark-slides-fill";
            if (lower.Contains("image")) return "bi-file-earmark-image-fill";
            return "bi-file-earmark-fill";
        }

        protected string GetStatusCss(string s)
        {
            if (string.IsNullOrEmpty(s)) return "tc-manage-materials-badge-pending";

            string lower = s.ToLower();
            if (lower == "approved") return "tc-manage-materials-badge-approved";
            if (lower == "rejected") return "tc-manage-materials-badge-rejected";
            return "tc-manage-materials-badge-pending";
        }

        protected string TruncateText(string text, int max)
        {
            if (string.IsNullOrEmpty(text)) return "No description";
            return text.Length <= max ? text : text.Substring(0, max) + "…";
        }

        /// <summary>Returns the web-relative path for a material file.
        /// Handles both old format (Images/Material/file.pdf) and new format (filename only).</summary>
        protected string GetFilePath(object fileUrlObj)
        {
            string fileUrl = fileUrlObj?.ToString() ?? "";

            if (string.IsNullOrEmpty(fileUrl))
                return "#";

            if (fileUrl.StartsWith("Images/", StringComparison.OrdinalIgnoreCase))
                return fileUrl;

            return "Images/Material/" + fileUrl;
        }

        #endregion
    }
}
