using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Parent
{
    public partial class EditDiscussion : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        protected string CurrentLanguage = "EN";
        protected string T(string en, string bm) => CurrentLanguage == "BM" ? bm : en;
        private string _userId = "", _forumId = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null || Session["role"].ToString() != "Parent") { Response.Redirect("~/Login.aspx", false); Context.ApplicationInstance.CompleteRequest(); return; }
            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar"; LoadSidebarChildren();
            string l = Session["preferredLanguage"] as string; if (!string.IsNullOrEmpty(l)) CurrentLanguage = l;
            _userId = Session["userId"].ToString(); _forumId = Request.QueryString["forumId"] ?? "";
            if (!IsPostBack) { btnSave.Text = T("Save Changes", "Simpan Perubahan"); LoadForm(); }
        }

        private void LoadForm()
        {
            if (string.IsNullOrEmpty(_forumId)) { pnlDenied.Visible = true; return; }
            try
            {
                using (var c = new SqlConnection(ConnStr))
                {
                    c.Open();
                    using (var cmd = new SqlCommand("SELECT createdBy, title, message, discussionType FROM dbo.Forum WHERE forumId=@id", c))
                    {
                        cmd.Parameters.AddWithValue("@id", _forumId);
                        using (var r = cmd.ExecuteReader())
                        {
                            if (!r.Read() || r["createdBy"].ToString() != _userId) { pnlDenied.Visible = true; return; }
                            txtTitle.Text = r["title"].ToString();
                            txtMessage.Text = r["message"].ToString();
                            if (ddlType.Items.FindByValue(r["discussionType"].ToString()) != null) ddlType.SelectedValue = r["discussionType"].ToString();
                        }
                    }
                    // Load current tags for display
                    pnlCurrentTags.Controls.Clear();
                    using (var cmd = new SqlCommand("SELECT t.tagId, t.tagName FROM dbo.ForumTag ft INNER JOIN dbo.Tag t ON ft.tagId=t.tagId WHERE ft.forumId=@id", c))
                    { cmd.Parameters.AddWithValue("@id", _forumId); using (var r = cmd.ExecuteReader()) { var sb = new System.Text.StringBuilder(); while (r.Read()) sb.Append("<span class='pt-forum-tag'>" + Server.HtmlEncode(r["tagName"].ToString()) + "</span> "); if (sb.Length > 0) pnlCurrentTags.Controls.Add(new LiteralControl(sb.ToString())); else pnlCurrentTags.Controls.Add(new LiteralControl("<span style='color:#94A3B8;font-size:0.82rem;'>" + T("No tags","Tiada tag") + "</span>")); } }
                    pnlForm.Visible = true;
                    lnkBack.HRef = "ForumThread.aspx?forumId=" + _forumId;
                }
            }
            catch { pnlDenied.Visible = true; }
        }

        protected void BtnSave_Click(object sender, EventArgs e)
        {
            string title = txtTitle.Text.Trim(); string message = txtMessage.Text.Trim(); string type = ddlType.SelectedValue;
            if (string.IsNullOrEmpty(title)) { ShowMsg(T("Title cannot be empty.", "Tajuk tidak boleh kosong."), false); return; }
            if (string.IsNullOrEmpty(message)) { ShowMsg(T("Message cannot be empty.", "Mesej tidak boleh kosong."), false); return; }
            try
            {
                using (var c = new SqlConnection(ConnStr)) { c.Open(); using (var txn = c.BeginTransaction()) { try {
                    // Verify ownership
                    string owner = ""; using (var cmd = new SqlCommand("SELECT createdBy FROM dbo.Forum WHERE forumId=@id", c, txn)) { cmd.Parameters.AddWithValue("@id", _forumId); owner = cmd.ExecuteScalar()?.ToString() ?? ""; }
                    if (owner != _userId) { txn.Rollback(); ShowMsg(T("Not authorized.", "Tidak dibenarkan."), false); return; }
                    using (var cmd = new SqlCommand("UPDATE dbo.Forum SET title=@t, message=@m, discussionType=@type WHERE forumId=@id", c, txn))
                    { cmd.Parameters.AddWithValue("@t", title); cmd.Parameters.AddWithValue("@m", message); cmd.Parameters.AddWithValue("@type", type); cmd.Parameters.AddWithValue("@id", _forumId); cmd.ExecuteNonQuery(); }
                    // Update tags: keep existing, add new from textbox
                    string rawNewTags = txtNewTags.Text.Trim();
                    if (!string.IsNullOrEmpty(rawNewTags))
                    {
                        var tagNames = rawNewTags.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                        var processed = new System.Collections.Generic.HashSet<string>(StringComparer.OrdinalIgnoreCase);
                        foreach (string rawTag in tagNames)
                        {
                            string tagName = rawTag.Trim();
                            if (string.IsNullOrEmpty(tagName) || processed.Contains(tagName)) continue;
                            processed.Add(tagName);
                            // Find or create tag
                            string tagId = null;
                            using (var cmd2 = new SqlCommand("SELECT tagId FROM dbo.Tag WHERE LOWER(tagName)=LOWER(@n)", c, txn))
                            { cmd2.Parameters.AddWithValue("@n", tagName); var tr = cmd2.ExecuteScalar(); if (tr != null && tr != DBNull.Value) tagId = tr.ToString(); }
                            if (string.IsNullOrEmpty(tagId))
                            {
                                tagId = GenId(c, txn, "Tag", "tagId", "TAG");
                                using (var cmd2 = new SqlCommand("INSERT INTO dbo.Tag(tagId,tagName,createdAt) VALUES(@id,@n,@now)", c, txn))
                                { cmd2.Parameters.AddWithValue("@id", tagId); cmd2.Parameters.AddWithValue("@n", tagName); cmd2.Parameters.AddWithValue("@now", DateTime.Now); cmd2.ExecuteNonQuery(); }
                            }
                            // Check if link already exists
                            using (var cmd2 = new SqlCommand("SELECT COUNT(*) FROM dbo.ForumTag WHERE forumId=@fid AND tagId=@tid", c, txn))
                            { cmd2.Parameters.AddWithValue("@fid", _forumId); cmd2.Parameters.AddWithValue("@tid", tagId); if ((int)cmd2.ExecuteScalar() > 0) continue; }
                            string ftId = GenId(c, txn, "ForumTag", "forumTagId", "FTAG");
                            using (var cmd2 = new SqlCommand("INSERT INTO dbo.ForumTag(forumTagId,forumId,tagId) VALUES(@id,@fid,@tid)", c, txn))
                            { cmd2.Parameters.AddWithValue("@id", ftId); cmd2.Parameters.AddWithValue("@fid", _forumId); cmd2.Parameters.AddWithValue("@tid", tagId); cmd2.ExecuteNonQuery(); }
                        }
                    }
                    txn.Commit();
                    Response.Redirect("ForumThread.aspx?forumId=" + _forumId, false); Context.ApplicationInstance.CompleteRequest();
                } catch { txn.Rollback(); throw; } } }
            }
            catch { ShowMsg(T("Error saving.", "Ralat menyimpan."), false); }
        }

        private string GenId(SqlConnection conn, SqlTransaction txn, string table, string column, string prefix)
        {
            int nextNumber = 1;
            using (var cmd = new SqlCommand(string.Format("SELECT MAX({0}) FROM dbo.[{1}]", column, table), conn, txn))
            {
                object result = cmd.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                {
                    string lastId = result.ToString();
                    if (lastId.Length > prefix.Length)
                    {
                        string numericPart = lastId.Substring(prefix.Length);
                        if (int.TryParse(numericPart, out int lastNumber))
                            nextNumber = lastNumber + 1;
                    }
                }
            }
            return prefix + nextNumber.ToString("D3");
        }
        private void ShowMsg(string msg, bool ok) { pnlMessage.Visible = true; divMsg.InnerHtml = msg; iMsgIcon.Attributes["class"] = ok ? "bi bi-check-circle-fill" : "bi bi-exclamation-circle-fill"; }
        protected void BtnCloseMsg_Click(object sender, EventArgs e) { pnlMessage.Visible = false; }
        private void LoadSidebarChildren()
        {
            try { using (var c = new System.Data.SqlClient.SqlConnection(ConnStr)) { string pid = ""; using (var cmd = new System.Data.SqlClient.SqlCommand("SELECT parentId FROM dbo.[Parent] WHERE userId=@u", c)) { cmd.Parameters.AddWithValue("@u", Session["userId"].ToString()); c.Open(); var r = cmd.ExecuteScalar(); if (r != null) pid = r.ToString(); } using (var cmd = new System.Data.SqlClient.SqlCommand("SELECT s.studentId, ISNULL(s.nickname,s.name) AS n FROM dbo.StudentParent sp INNER JOIN dbo.Student s ON sp.studentId=s.studentId WHERE sp.parentId=@p ORDER BY s.name", c)) { cmd.Parameters.AddWithValue("@p", pid); using (var r = cmd.ExecuteReader()) { while (r.Read()) ddlSidebarChild2.Items.Add(new System.Web.UI.WebControls.ListItem(r["n"].ToString(), r["studentId"].ToString())); } } } } catch { }
            string saved = Session["selectedChildId"] as string;
            if (!string.IsNullOrEmpty(saved) && ddlSidebarChild2.Items.FindByValue(saved) != null) ddlSidebarChild2.SelectedValue = saved;
        }
    }
}