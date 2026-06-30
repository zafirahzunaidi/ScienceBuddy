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
                if (!AuthorizeTeacher()) return;
                LoadFilterDropdowns();
                LoadMaterials();
            }
        }

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
                        if (s.Equals("Certified", StringComparison.OrdinalIgnoreCase)) { pnlMain.Visible = true; return true; }
                        if (s.Equals("Pending", StringComparison.OrdinalIgnoreCase)) { pnlPending.Visible = true; return false; }
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
            string userId = Session["userId"].ToString();
            string search = txtSearch.Text.Trim();
            string lvl = ddlFilterLevel.SelectedValue, unit = ddlFilterUnit.SelectedValue;
            string type = ddlFilterType.SelectedValue, status = ddlFilterStatus.SelectedValue;

            string sql = @"SELECT m.[materialId],m.[materialTitle],m.[materialContent],m.[materialType],
                m.[fileUrl],m.[createdDate],m.[status],m.[language],ISNULL(st.[subtopicTitleEN],'—') AS subtopicName
                FROM dbo.[Material] m LEFT JOIN dbo.[Subtopic] st ON st.[subtopicId]=m.[subtopicId]
                LEFT JOIN dbo.[Unit] u ON u.[unitId]=st.[unitId] WHERE m.[createdByUserId]=@userId";
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
                    if (dt.Rows.Count > 0) { rptMaterials.DataSource = dt; rptMaterials.DataBind(); }
                }
            }
        }

        // ── Filter events ────────────────────────────────────────────
        protected void btnSearch_Click(object sender, EventArgs e) { LoadMaterials(); }
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
            LoadMaterials();
        }
        protected void ddlFilterUnit_Changed(object sender, EventArgs e) { LoadMaterials(); }
        protected void ddlFilterType_Changed(object sender, EventArgs e) { LoadMaterials(); }
        protected void ddlFilterStatus_Changed(object sender, EventArgs e) { LoadMaterials(); }

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
                            try { ddlLanguage.SelectedValue = r["language"]?.ToString() ?? "EN"; } catch { }
                            string levelId = r["levelId"]?.ToString();
                            string unitId = r["unitId"]?.ToString();
                            string subtopicId = r["subtopicId"]?.ToString();
                            string fileUrl = r["fileUrl"]?.ToString();
                            string matStatus = r["status"]?.ToString() ?? "";
                            r.Close();

                            // Load form dropdowns
                            LoadFormDropdowns(conn, levelId, unitId, subtopicId);

                            // File info
                            if (!string.IsNullOrEmpty(fileUrl))
                            { pnlCurrentFile.Visible = true; litCurrentFile.Text = HttpUtility.HtmlEncode(Path.GetFileName(fileUrl)); }

                            // Modal title
                            bool isResubmit = matStatus.Equals("Rejected", StringComparison.OrdinalIgnoreCase);
                            litFormTitle.Text = isResubmit ? "Resubmit Material" : "Edit Material";
                            litSaveBtnText.Text = isResubmit ? "Resubmit Material" : "Update Material";

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
            string subtopicId = ddlSubtopic.SelectedValue;

            if (string.IsNullOrEmpty(title) || string.IsNullOrEmpty(subtopicId))
            { hidToast.Value = "Please fill in required fields."; hidShowEditModal.Value = "1"; LoadMaterials(); return; }

            string fileUrl = null; string materialType = null;
            if (fuFile.HasFile)
            {
                string ext = Path.GetExtension(fuFile.FileName).ToLower();
                if (!AllowedExtensions.Contains(ext)) { hidToast.Value = "Invalid file type."; hidShowEditModal.Value = "1"; LoadMaterials(); return; }
                if (fuFile.PostedFile.ContentLength > MaxFileSize) { hidToast.Value = "File exceeds 10 MB."; hidShowEditModal.Value = "1"; LoadMaterials(); return; }
                materialType = GetMaterialType(ext);
                string fn = Guid.NewGuid().ToString("N").Substring(0, 12) + ext;
                string dir = Server.MapPath("~/Images/Material/");
                if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);
                fuFile.SaveAs(Path.Combine(dir, fn));
                fileUrl = "Images/Material/" + fn;
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
                hidToast.Value = T("Material updated successfully.","Bahan berjaya dikemas kini.");
            }
            catch { hidToast.Value = "An error occurred. Please try again."; }
            LoadMaterials();
        }

        // ── Delete ───────────────────────────────────────────────────
        protected void btnConfirmDelete_Click(object sender, EventArgs e)
        {
            string materialId = hidDeleteId.Value;
            string userId = Session["userId"].ToString();
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    if (!VerifyOwnership(conn, materialId, userId)) { hidToast.Value = "Permission denied."; LoadMaterials(); return; }
                    using (var cmd = new SqlCommand("DELETE FROM dbo.[Material] WHERE [materialId]=@id AND [createdByUserId]=@uid", conn))
                    { cmd.Parameters.AddWithValue("@id", materialId); cmd.Parameters.AddWithValue("@uid", userId); cmd.ExecuteNonQuery(); }
                }
                hidToast.Value = T("Material deleted successfully.","Bahan berjaya dipadam.");
            }
            catch { hidToast.Value = "Could not delete material."; }
            LoadMaterials();
        }

        // ── Repeater (not used for commands now but kept for compatibility) ──
        protected void rptMaterials_ItemCommand(object source, RepeaterCommandEventArgs e) { }

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
    }
}
