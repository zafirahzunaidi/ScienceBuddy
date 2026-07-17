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

        private static readonly HashSet<string> AllowedExtensions = new HashSet<string>(
            StringComparer.OrdinalIgnoreCase)
        { ".pdf", ".doc", ".docx", ".ppt", ".pptx", ".jpg", ".jpeg", ".png" };

        private const int MaxFileSize = 10 * 1024 * 1024;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"]?.ToString() != "Teacher")
            {
                Response.Redirect("~/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest(); return;
            }

            var master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            // Always resolve teacher certification status (needed for every request)
            if (!AuthorizeTeacher()) return;

            // Handle edit modal postback
            string eventTarget = Request["__EVENTTARGET"];
            string eventArg = Request["__EVENTARGUMENT"];
            if (eventTarget == "LoadEdit" && !string.IsNullOrEmpty(eventArg))
            {
                LoadEditForm(eventArg, Session["userId"].ToString());
                if (!IsPostBack) { LoadFilterDropdowns(); LoadMaterials(); }
                return;
            }

            if (!IsPostBack)
            {
                LoadFilterDropdowns();
                SetTabUI();
                LoadMaterials();
            }
        }

        private bool _isCertified = false;

        private bool AuthorizeTeacher()
        {
            string userId = Session["userId"].ToString();
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("SELECT [status] FROM dbo.[Teacher] WHERE [userId]=@u", conn))
                    {
                        cmd.Parameters.AddWithValue("@u", userId);
                        var val = cmd.ExecuteScalar();
                        if (val == null || val == DBNull.Value) { pnlDenied.Visible = true; return false; }
                        string s = val.ToString();
                        if (s.Equals("Certified", StringComparison.OrdinalIgnoreCase))
                        {
                            _isCertified = true;
                            pnlMain.Visible = true;
                            return true;
                        }
                        if (s.Equals("Pending", StringComparison.OrdinalIgnoreCase))
                        {
                            _isCertified = false;
                            pnlMain.Visible = true;
                            return true;
                        }
                        pnlDenied.Visible = true; return false;
                    }
                }
            }
            catch { pnlDenied.Visible = true; return false; }
        }

        private void LoadFilterDropdowns()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                ddlFilterLevel.Items.Clear();
                ddlFilterLevel.Items.Add(new ListItem(T("All Levels","Semua Tahap"), ""));
                using (var cmd = new SqlCommand("SELECT [levelId],[levelNameEN] FROM dbo.[Level] ORDER BY [levelId]", conn))
                using (var r = cmd.ExecuteReader()) while (r.Read()) ddlFilterLevel.Items.Add(new ListItem(r["levelNameEN"].ToString(), r["levelId"].ToString()));

                ddlFilterUnit.Items.Clear();
                ddlFilterUnit.Items.Add(new ListItem(T("All Units","Semua Unit"), ""));

                ddlFilterType.Items.Clear();
                ddlFilterType.Items.Add(new ListItem(T("All Types","Semua Jenis"), ""));
                ddlFilterType.Items.Add(new ListItem("PDF", "PDF"));
                ddlFilterType.Items.Add(new ListItem(T("Document","Dokumen"), "Document"));
                ddlFilterType.Items.Add(new ListItem("PPTX", "PPTX"));
                ddlFilterType.Items.Add(new ListItem(T("Image","Imej"), "Image"));

                ddlFilterStatus.Items.Clear();
                ddlFilterStatus.Items.Add(new ListItem(T("All Status","Semua Status"), ""));
                ddlFilterStatus.Items.Add(new ListItem(T("Pending","Menunggu"), "Pending"));
                ddlFilterStatus.Items.Add(new ListItem(T("Approved","Diluluskan"), "Approved"));
                ddlFilterStatus.Items.Add(new ListItem(T("Rejected","Ditolak"), "Rejected"));

                // Set search placeholder
                txtSearch.Attributes["placeholder"] = T("Search materials...","Cari bahan...");
                btnSearch.Text = T("Search","Cari");
            }
        }

        private void LoadMaterials()
        {
            // If not certified, hide all My Materials content — pending panel is shown via SetTabUI
            if (!_isCertified)
            {
                pnlMaterials.Visible = false;
                pnlEmpty.Visible = false;
                pnlDiscover.Visible = false;
                pnlDiscoverEmpty.Visible = false;
                return;
            }

            string userId = Session["userId"].ToString();
            string search = txtSearch.Text.Trim();
            string lvl = ddlFilterLevel.SelectedValue, unit = ddlFilterUnit.SelectedValue;
            string type = ddlFilterType.SelectedValue, status = ddlFilterStatus.SelectedValue;

            string sql = @"SELECT m.[materialId],m.[materialTitle],m.[materialContent],m.[materialType],
                m.[fileUrl],m.[createdDate],m.[status],m.[language],ISNULL(st.[subtopicTitleEN],'—') AS subtopicName
                FROM dbo.[Material] m LEFT JOIN dbo.[Subtopic] st ON st.[subtopicId]=m.[subtopicId]
                LEFT JOIN dbo.[Unit] u ON u.[unitId]=st.[unitId] WHERE m.[createdByUserId]=@userId AND (m.[status] IS NULL OR m.[status]<>'Deleted')";
            if (!string.IsNullOrEmpty(search)) sql += " AND (m.[materialTitle] LIKE @s OR m.[materialContent] LIKE @s)";
            if (!string.IsNullOrEmpty(lvl)) sql += " AND u.[levelId]=@lvl";
            if (!string.IsNullOrEmpty(unit)) sql += " AND u.[unitId]=@unit";
            if (!string.IsNullOrEmpty(type)) sql += " AND m.[materialType]=@type";
            if (!string.IsNullOrEmpty(status)) sql += " AND m.[status]=@status";
            sql += " ORDER BY m.[createdDate] DESC";

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    if (!string.IsNullOrEmpty(search)) cmd.Parameters.AddWithValue("@s", "%" + search + "%");
                    if (!string.IsNullOrEmpty(lvl)) cmd.Parameters.AddWithValue("@lvl", lvl);
                    if (!string.IsNullOrEmpty(unit)) cmd.Parameters.AddWithValue("@unit", unit);
                    if (!string.IsNullOrEmpty(type)) cmd.Parameters.AddWithValue("@type", type);
                    if (!string.IsNullOrEmpty(status)) cmd.Parameters.AddWithValue("@status", status);
                    var dt = new DataTable(); new SqlDataAdapter(cmd).Fill(dt);
                    pnlMaterials.Visible = dt.Rows.Count > 0;
                    pnlEmpty.Visible = dt.Rows.Count == 0;
                    pnlDiscover.Visible = false;
                    pnlDiscoverEmpty.Visible = false;
                    if (dt.Rows.Count > 0) { rptMaterials.DataSource = dt; rptMaterials.DataBind(); }
                }
            }
        }

        private void LoadDiscoverMaterials()
        {
            string userId = Session["userId"].ToString();
            string search = txtSearch.Text.Trim();
            string lvl = ddlFilterLevel.SelectedValue, unit = ddlFilterUnit.SelectedValue;
            string type = ddlFilterType.SelectedValue;

            string sql = @"SELECT m.[materialId],m.[materialTitle],m.[materialContent],m.[materialType],
                m.[fileUrl],m.[createdDate],m.[language],ISNULL(st.[subtopicTitleEN],'—') AS subtopicName,
                COALESCE(t.[name],u2.[username],'Teacher') AS teacherName
                FROM dbo.[Material] m LEFT JOIN dbo.[Subtopic] st ON st.[subtopicId]=m.[subtopicId]
                LEFT JOIN dbo.[Unit] un ON un.[unitId]=st.[unitId]
                LEFT JOIN dbo.[User] u2 ON u2.[userId]=m.[createdByUserId]
                LEFT JOIN dbo.[Teacher] t ON t.[userId]=m.[createdByUserId]
                WHERE m.[createdByUserId]<>@userId AND m.[status]='Approved'";
            if (!string.IsNullOrEmpty(search)) sql += " AND (m.[materialTitle] LIKE @s OR m.[materialContent] LIKE @s)";
            if (!string.IsNullOrEmpty(lvl)) sql += " AND un.[levelId]=@lvl";
            if (!string.IsNullOrEmpty(unit)) sql += " AND un.[unitId]=@unit";
            if (!string.IsNullOrEmpty(type)) sql += " AND m.[materialType]=@type";
            sql += " ORDER BY m.[createdDate] DESC";

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    if (!string.IsNullOrEmpty(search)) cmd.Parameters.AddWithValue("@s", "%" + search + "%");
                    if (!string.IsNullOrEmpty(lvl)) cmd.Parameters.AddWithValue("@lvl", lvl);
                    if (!string.IsNullOrEmpty(unit)) cmd.Parameters.AddWithValue("@unit", unit);
                    if (!string.IsNullOrEmpty(type)) cmd.Parameters.AddWithValue("@type", type);
                    var dt = new DataTable(); new SqlDataAdapter(cmd).Fill(dt);
                    pnlDiscover.Visible = dt.Rows.Count > 0;
                    pnlDiscoverEmpty.Visible = dt.Rows.Count == 0;
                    pnlMaterials.Visible = false;
                    pnlEmpty.Visible = false;
                    if (dt.Rows.Count > 0) { rptDiscover.DataSource = dt; rptDiscover.DataBind(); }
                }
            }
        }

        // ── Filter events ────────────────────────────────────────────
        protected void btnSearch_Click(object sender, EventArgs e) { LoadForActiveTab(); }
        protected void btnTabMine_Click(object sender, EventArgs e) { hidActiveTab.Value = "mine"; SetTabUI(); LoadForActiveTab(); }
        protected void btnTabDiscover_Click(object sender, EventArgs e) { hidActiveTab.Value = "discover"; SetTabUI(); LoadForActiveTab(); }

        private void SetTabUI()
        {
            bool isMine = hidActiveTab.Value != "discover";
            btnTabMine.CssClass = "mm-tab" + (isMine ? " active" : "");
            btnTabDiscover.CssClass = "mm-tab" + (!isMine ? " active" : "");

            // Upload button: visible on Mine tab, enabled only when certified
            pnlUploadBtn.Visible = isMine;
            if (isMine)
            {
                pnlUploadEnabled.Visible = _isCertified;
                pnlUploadDisabled.Visible = !_isCertified;
            }

            // Filter bar and status chips: visible only when certified AND on Mine tab
            pnlFilterBar.Visible = isMine && _isCertified;
            pnlStatusChips.Visible = isMine && _isCertified;

            // Pending state panel: visible when on Mine tab and not certified
            pnlMyMaterialsPending.Visible = isMine && !_isCertified;
        }

        private void LoadForActiveTab()
        {
            SetTabUI();
            if (hidActiveTab.Value == "discover") LoadDiscoverMaterials();
            else LoadMaterials();
        }

        protected void ddlFilterLevel_Changed(object sender, EventArgs e)
        {
            ddlFilterUnit.Items.Clear();
            ddlFilterUnit.Items.Add(new ListItem(T("All Units","Semua Unit"), ""));
            string lid = ddlFilterLevel.SelectedValue;
            if (!string.IsNullOrEmpty(lid))
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("SELECT [unitId],[unitNameEN] FROM dbo.[Unit] WHERE [levelId]=@l ORDER BY [orderNo]", conn))
                    { cmd.Parameters.AddWithValue("@l", lid); using (var r = cmd.ExecuteReader()) while (r.Read()) ddlFilterUnit.Items.Add(new ListItem(r["unitNameEN"].ToString(), r["unitId"].ToString())); }
                }
            }
            LoadForActiveTab();
        }
        protected void ddlFilterUnit_Changed(object sender, EventArgs e) { LoadForActiveTab(); }
        protected void ddlFilterType_Changed(object sender, EventArgs e) { LoadForActiveTab(); }
        protected void ddlFilterStatus_Changed(object sender, EventArgs e) { LoadForActiveTab(); }

        protected void btnChip_Click(object sender, EventArgs e)
        {
            var btn = sender as LinkButton;
            string status = btn?.CommandArgument ?? "";
            // Update chip UI
            btnChipAll.CssClass = "mm-chip" + (status == "" ? " active" : "");
            btnChipApproved.CssClass = "mm-chip" + (status == "Approved" ? " active" : "");
            btnChipPending.CssClass = "mm-chip" + (status == "Pending" ? " active" : "");
            btnChipRejected.CssClass = "mm-chip" + (status == "Rejected" ? " active" : "");
            // Set ddlFilterStatus value for the query
            try { ddlFilterStatus.SelectedValue = status; } catch { }
            LoadForActiveTab();
        }

        protected string GetIconCss(string t)
        {
            if (string.IsNullOrEmpty(t)) return "mm-ico-default";
            string l = t.ToLower();
            if (l.Contains("pdf")) return "mm-ico-pdf";
            if (l.Contains("doc")) return "mm-ico-doc";
            if (l.Contains("ppt")) return "mm-ico-ppt";
            if (l.Contains("image") || l.Contains("jpg") || l.Contains("png")) return "mm-ico-image";
            if (l.Contains("video")) return "mm-ico-video";
            return "mm-ico-default";
        }

        // ── Edit modal load ──────────────────────────────────────────
        private void LoadEditForm(string materialId, string userId)
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
                        cmd.Parameters.AddWithValue("@uid", userId);
                        using (var r = cmd.ExecuteReader())
                        {
                            if (!r.Read()) return;
                            hidMaterialId.Value = materialId;
                            txtTitle.Text = r["materialTitle"]?.ToString() ?? "";
                            txtDescription.Text = r["materialContent"]?.ToString() ?? "";
                            string langVal = r["language"]?.ToString() ?? "EN";
                            try { ddlLanguage.SelectedValue = langVal; } catch { }
                            string levelId = r["levelId"]?.ToString();
                            string unitId = r["unitId"]?.ToString();
                            string subtopicId = r["subtopicId"]?.ToString();
                            string fileUrl = r["fileUrl"]?.ToString();
                            string matStatus = r["status"]?.ToString() ?? "";
                            r.Close();

                            // Store original values for change detection
                            hidOrigTitle.Value = txtTitle.Text;
                            hidOrigDesc.Value = txtDescription.Text;
                            hidOrigLang.Value = langVal;
                            hidOrigLevel.Value = levelId ?? "";
                            hidOrigUnit.Value = unitId ?? "";
                            hidOrigSubtopic.Value = subtopicId ?? "";

                            // Load form dropdowns
                            LoadFormDropdowns(conn, levelId, unitId, subtopicId);

                            // File info
                            if (!string.IsNullOrEmpty(fileUrl))
                            { pnlCurrentFile.Visible = true; litCurrentFile.Text = HttpUtility.HtmlEncode(Path.GetFileName(fileUrl)); }

                            // Modal title
                            bool isResubmit = matStatus.Equals("Rejected", StringComparison.OrdinalIgnoreCase);
                            litFormTitle.Text = isResubmit ? "Resubmit Material" : "Edit Material";
                            litSaveBtnText.Text = "Confirm Changes";

                            hidShowEditModal.Value = "1";
                        }
                    }
                }
            }
            catch { }
            LoadMaterials();
        }

        private void LoadFormDropdowns(SqlConnection conn, string selLevel, string selUnit, string selSubtopic)
        {
            ddlLevel.Items.Clear(); ddlLevel.Items.Add(new ListItem("— Select Level —", ""));
            using (var cmd = new SqlCommand("SELECT [levelId],[levelNameEN] FROM dbo.[Level] ORDER BY [levelId]", conn))
            using (var r = cmd.ExecuteReader()) while (r.Read()) ddlLevel.Items.Add(new ListItem(r["levelNameEN"].ToString(), r["levelId"].ToString()));
            if (!string.IsNullOrEmpty(selLevel)) try { ddlLevel.SelectedValue = selLevel; } catch { }

            ddlUnit.Items.Clear(); ddlUnit.Items.Add(new ListItem("— Select Unit —", ""));
            if (!string.IsNullOrEmpty(selLevel))
            {
                using (var cmd = new SqlCommand("SELECT [unitId],[unitNameEN] FROM dbo.[Unit] WHERE [levelId]=@l ORDER BY [orderNo]", conn))
                { cmd.Parameters.AddWithValue("@l", selLevel); using (var r = cmd.ExecuteReader()) while (r.Read()) ddlUnit.Items.Add(new ListItem(r["unitNameEN"].ToString(), r["unitId"].ToString())); }
            }
            if (!string.IsNullOrEmpty(selUnit)) try { ddlUnit.SelectedValue = selUnit; } catch { }

            ddlSubtopic.Items.Clear(); ddlSubtopic.Items.Add(new ListItem("— Select Subtopic —", ""));
            if (!string.IsNullOrEmpty(selUnit))
            {
                using (var cmd = new SqlCommand("SELECT [subtopicId],[subtopicTitleEN] FROM dbo.[Subtopic] WHERE [unitId]=@u ORDER BY [orderNo]", conn))
                { cmd.Parameters.AddWithValue("@u", selUnit); using (var r = cmd.ExecuteReader()) while (r.Read()) ddlSubtopic.Items.Add(new ListItem(r["subtopicTitleEN"].ToString(), r["subtopicId"].ToString())); }
            }
            if (!string.IsNullOrEmpty(selSubtopic)) try { ddlSubtopic.SelectedValue = selSubtopic; } catch { }
        }

        protected void ddlLevel_Changed(object sender, EventArgs e)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                ddlUnit.Items.Clear(); ddlUnit.Items.Add(new ListItem("— Select Unit —", ""));
                string lid = ddlLevel.SelectedValue;
                if (!string.IsNullOrEmpty(lid))
                    using (var cmd = new SqlCommand("SELECT [unitId],[unitNameEN] FROM dbo.[Unit] WHERE [levelId]=@l ORDER BY [orderNo]", conn))
                    { cmd.Parameters.AddWithValue("@l", lid); using (var r = cmd.ExecuteReader()) while (r.Read()) ddlUnit.Items.Add(new ListItem(r["unitNameEN"].ToString(), r["unitId"].ToString())); }
                ddlSubtopic.Items.Clear(); ddlSubtopic.Items.Add(new ListItem("— Select Subtopic —", ""));
            }
            hidShowEditModal.Value = "1";
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
            hidShowEditModal.Value = "1";
        }

        // ── Save (update) ────────────────────────────────────────────
        protected void btnSave_Click(object sender, EventArgs e)
        {
            string materialId = hidMaterialId.Value;
            string userId = Session["userId"].ToString();
            string title = txtTitle.Text.Trim();
            string desc = txtDescription.Text.Trim();
            string lang = ddlLanguage.SelectedValue;
            string levelVal = ddlLevel.SelectedValue;
            string unitVal = ddlUnit.SelectedValue;
            string subtopicId = ddlSubtopic.SelectedValue;

            // ── Server-side validation (same rules as upload) ──
            if (string.IsNullOrEmpty(title))
            { hidToast.Value = "Title is required."; hidShowEditModal.Value = "1"; LoadMaterials(); return; }
            if (string.IsNullOrEmpty(lang))
            { hidToast.Value = "Language is required."; hidShowEditModal.Value = "1"; LoadMaterials(); return; }

            if (string.IsNullOrEmpty(levelVal))
            { hidToast.Value = "Level is required."; hidShowEditModal.Value = "1"; LoadMaterials(); return; }
            if (string.IsNullOrEmpty(unitVal))
            { hidToast.Value = "Unit is required."; hidShowEditModal.Value = "1"; LoadMaterials(); return; }
            if (string.IsNullOrEmpty(subtopicId))
            { hidToast.Value = "Subtopic is required."; hidShowEditModal.Value = "1"; LoadMaterials(); return; }

            // ── Change detection — compare with original values ──
            string origTitle = hidOrigTitle.Value.Trim();
            string origDesc = hidOrigDesc.Value.Trim();
            string origLang = hidOrigLang.Value;
            string origLevel = hidOrigLevel.Value;
            string origUnit = hidOrigUnit.Value;
            string origSubtopic = hidOrigSubtopic.Value;
            bool hasNewFile = fuFile.HasFile;

            bool changed = hasNewFile ||
                !string.Equals(title, origTitle, StringComparison.Ordinal) ||
                !string.Equals(desc, origDesc, StringComparison.Ordinal) ||
                !string.Equals(lang, origLang, StringComparison.Ordinal) ||
                !string.Equals(levelVal, origLevel, StringComparison.Ordinal) ||
                !string.Equals(unitVal, origUnit, StringComparison.Ordinal) ||
                !string.Equals(subtopicId, origSubtopic, StringComparison.Ordinal);

            if (!changed)
            {
                hidToast.Value = T("No changes were made.", "Tiada perubahan dibuat.");
                LoadMaterials(); return;
            }

            // ── File validation (only if a new file is uploaded) ──
            string fileUrl = null; string materialType = null;
            if (hasNewFile)
            {
                string ext = Path.GetExtension(fuFile.FileName).ToLower();
                if (!AllowedExtensions.Contains(ext)) { hidToast.Value = "Invalid file type."; hidShowEditModal.Value = "1"; LoadMaterials(); return; }
                if (fuFile.PostedFile.ContentLength > MaxFileSize) { hidToast.Value = "File exceeds 10 MB."; hidShowEditModal.Value = "1"; LoadMaterials(); return; }
                materialType = GetMaterialType(ext);
                string fn = Guid.NewGuid().ToString("N").Substring(0, 12) + ext;
                string dir = Server.MapPath("~/Images/Material/");
                if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);
                fuFile.SaveAs(Path.Combine(dir, fn));
                fileUrl = fn;
            }

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    if (!VerifyOwnership(conn, materialId, userId)) { hidToast.Value = "Permission denied."; LoadMaterials(); return; }

                    string sql = @"UPDATE dbo.[Material] SET [materialTitle]=@t,[materialContent]=@d,[language]=@l,[subtopicId]=@st,[status]='Pending'"
                        + (fileUrl != null ? ",[fileUrl]=@f,[materialType]=@mt" : "") + " WHERE [materialId]=@id AND [createdByUserId]=@uid";
                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@t", title);
                        cmd.Parameters.AddWithValue("@d", (object)desc ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@l", lang);
                        cmd.Parameters.AddWithValue("@st", subtopicId);
                        cmd.Parameters.AddWithValue("@id", materialId);
                        cmd.Parameters.AddWithValue("@uid", userId);
                        if (fileUrl != null) { cmd.Parameters.AddWithValue("@f", fileUrl); cmd.Parameters.AddWithValue("@mt", materialType); }
                        cmd.ExecuteNonQuery();
                    }
                }
                hidToast.Value = T("Material updated successfully and submitted for review.", "Bahan berjaya dikemas kini dan dihantar untuk semakan.");
            }
            catch { hidToast.Value = "An error occurred. Please try again."; }
            LoadMaterials();
        }

        /// <summary>Checks if a rich-text value is effectively empty (only empty HTML tags or whitespace).</summary>
        private static bool IsEmptyRichText(string val)
        {
            if (string.IsNullOrWhiteSpace(val)) return true;
            // Strip all HTML tags and decode common entities
            string stripped = System.Text.RegularExpressions.Regex.Replace(val, @"<[^>]*>", "");
            stripped = stripped.Replace("&nbsp;", " ").Trim();
            return stripped.Length == 0;
        }

        // ── Delete (soft delete — set status to 'Deleted') ─────────
        protected void btnConfirmDelete_Click(object sender, EventArgs e)
        {
            string materialId = hidDeleteId.Value;
            string userId = Session["userId"].ToString();
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    if (!VerifyOwnership(conn, materialId, userId)) { hidToast.Value = "Permission denied."; LoadForActiveTab(); return; }
                    using (var cmd = new SqlCommand("UPDATE dbo.[Material] SET [status]='Deleted' WHERE [materialId]=@id AND [createdByUserId]=@uid", conn))
                    { cmd.Parameters.AddWithValue("@id", materialId); cmd.Parameters.AddWithValue("@uid", userId); cmd.ExecuteNonQuery(); }
                }
                hidToast.Value = T("Material deleted successfully.","Bahan berjaya dipadam.");
            }
            catch { hidToast.Value = "Could not delete material."; }
            LoadForActiveTab();
        }

        // ── Repeater commands ─────────────────────────────────────────
        protected void rptMaterials_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            HandleFileCommand(e.CommandName, e.CommandArgument?.ToString());
        }

        protected void rptDiscover_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            HandleFileCommand(e.CommandName, e.CommandArgument?.ToString());
        }

        private void HandleFileCommand(string commandName, string fileUrl)
        {
            if (string.IsNullOrEmpty(fileUrl)) return;
            string filePath = GetFilePath(fileUrl);
            string physicalPath = Server.MapPath("~/" + filePath);

            if (commandName == "ViewMaterial")
            {
                // Redirect to file URL — browser will display inline (preview)
                Response.Redirect(ResolveUrl("~/") + filePath, false);
                Context.ApplicationInstance.CompleteRequest();
            }
            else if (commandName == "DownloadMaterial")
            {
                // Force download with attachment header
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

        // ── Utilities ────────────────────────────────────────────────
        private bool VerifyOwnership(SqlConnection conn, string id, string userId)
        {
            using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[Material] WHERE [materialId]=@id AND [createdByUserId]=@u", conn))
            { cmd.Parameters.AddWithValue("@id", id); cmd.Parameters.AddWithValue("@u", userId); return Convert.ToInt32(cmd.ExecuteScalar()) > 0; }
        }

        private static string GetMaterialType(string ext)
        {
            switch (ext) { case ".pdf": return "PDF"; case ".doc": case ".docx": return "Document"; case ".ppt": case ".pptx": return "PPTX"; case ".jpg": case ".jpeg": case ".png": return "Image"; default: return "Other"; }
        }

        protected string GetFileIcon(string t)
        {
            if (string.IsNullOrEmpty(t)) return "bi-file-earmark";
            string l = t.ToLower();
            if (l.Contains("pdf")) return "bi-file-earmark-pdf-fill";
            if (l.Contains("doc")) return "bi-file-earmark-word-fill";
            if (l.Contains("ppt")) return "bi-file-earmark-slides-fill";
            if (l.Contains("image")) return "bi-file-earmark-image-fill";
            return "bi-file-earmark-fill";
        }

        protected string GetStatusCss(string s)
        {
            if (string.IsNullOrEmpty(s)) return "mm-badge-pending";
            string l = s.ToLower();
            if (l == "approved") return "mm-badge-approved";
            if (l == "rejected") return "mm-badge-rejected";
            return "mm-badge-pending";
        }

        protected string TruncateText(string text, int max)
        {
            if (string.IsNullOrEmpty(text)) return "No description";
            return text.Length <= max ? text : text.Substring(0, max) + "…";
        }

        /// <summary>Returns the web-relative path for a material file. Handles both
        /// old format (Images/Material/file.pdf) and new format (file.pdf only).</summary>
        protected string GetFilePath(object fileUrlObj)
        {
            string fileUrl = fileUrlObj?.ToString() ?? "";
            if (string.IsNullOrEmpty(fileUrl)) return "#";
            // If already has folder prefix, use as-is
            if (fileUrl.StartsWith("Images/", StringComparison.OrdinalIgnoreCase))
                return fileUrl;
            // Otherwise prepend the folder
            return "Images/Material/" + fileUrl;
        }
    }
}
