using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Parent
{
    public partial class CreateDiscussion : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        protected string CurrentLanguage = "EN";
        protected string T(string en, string bm) => CurrentLanguage == "BM" ? bm : en;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null || Session["role"].ToString() != "Parent") { Response.Redirect("~/Login.aspx", false); Context.ApplicationInstance.CompleteRequest(); return; }
            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar"; LoadSidebarChildren();
            string l = Session["preferredLanguage"] as string; if (!string.IsNullOrEmpty(l)) CurrentLanguage = l;
            if (!IsPostBack) { btnSubmit.Text = T("Create", "Buat"); LoadTags(); PreSelectType(); }
        }

        private void PreSelectType()
        {
            string type = Request.QueryString["type"];
            if (!string.IsNullOrEmpty(type) && ddlType.Items.FindByValue(type) != null)
                ddlType.SelectedValue = type;
        }

        private void LoadTags()
        {
            // Show 5 existing tags as suggestions
            try
            {
                using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT TOP 5 tagName FROM dbo.Tag ORDER BY NEWID()", c))
                {
                    c.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        var sb = new System.Text.StringBuilder();
                        sb.Append("<span style='font-size:0.78rem;color:#64748B;font-weight:600;'>" + T("Suggested tags: ", "Tag cadangan: ") + "</span>");
                        while (r.Read()) sb.Append("<span class='pt-tag-pill'>" + System.Web.HttpUtility.HtmlEncode(r["tagName"].ToString()) + "</span> ");
                        litTagSuggestions.Text = sb.ToString();
                    }
                }
            }
            catch { }
        }

        protected void BtnSubmit_Click(object sender, EventArgs e)
        {
            string title = txtTitle.Text.Trim();
            string message = txtMessage.Text.Trim();
            string type = ddlType.SelectedValue;
            if (string.IsNullOrEmpty(title)) { ShowMsg(T("Title cannot be empty.", "Tajuk tidak boleh kosong."), false); return; }
            if (string.IsNullOrEmpty(message)) { ShowMsg(T("Message cannot be empty.", "Mesej tidak boleh kosong."), false); return; }

            try
            {
                using (var c = new SqlConnection(ConnStr)) { c.Open(); using (var txn = c.BeginTransaction()) { try {
                    string forumId = GenId(c, txn, "Forum", "forumId", "F");
                    using (var cmd = new SqlCommand("INSERT INTO dbo.Forum(forumId,createdBy,title,message,discussionType,createdAt) VALUES(@id,@uid,@t,@m,@type,@now)", c, txn))
                    { cmd.Parameters.AddWithValue("@id", forumId); cmd.Parameters.AddWithValue("@uid", Session["userId"].ToString()); cmd.Parameters.AddWithValue("@t", title); cmd.Parameters.AddWithValue("@m", message); cmd.Parameters.AddWithValue("@type", type); cmd.Parameters.AddWithValue("@now", DateTime.Now); cmd.ExecuteNonQuery(); }

                    // Tags - parse textbox
                    string rawTags = txtTags.Text.Trim();
                    if (!string.IsNullOrEmpty(rawTags))
                    {
                        var tagNames = rawTags.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
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

                            // Insert ForumTag
                            string ftId = GenId(c, txn, "ForumTag", "forumTagId", "FTAG");
                            using (var cmd2 = new SqlCommand("INSERT INTO dbo.ForumTag(forumTagId,forumId,tagId) VALUES(@id,@fid,@tid)", c, txn))
                            { cmd2.Parameters.AddWithValue("@id", ftId); cmd2.Parameters.AddWithValue("@fid", forumId); cmd2.Parameters.AddWithValue("@tid", tagId); cmd2.ExecuteNonQuery(); }
                        }
                    }
                    txn.Commit();
                    Response.Redirect("ForumThread.aspx?forumId=" + forumId, false); Context.ApplicationInstance.CompleteRequest();
                } catch { txn.Rollback(); throw; } } }
            }
            catch { ShowMsg(T("Error creating discussion.", "Ralat membuat perbincangan."), false); }
        }

        private string GenId(SqlConnection c, SqlTransaction t, string table, string col, string prefix) { int n = 1; using (var cmd = new SqlCommand(string.Format("SELECT MAX({0}) FROM dbo.[{1}]", col, table), c, t)) { var r = cmd.ExecuteScalar(); if (r != null && r != DBNull.Value) { string last = r.ToString(); if (last.Length > prefix.Length) { int num; if (int.TryParse(last.Substring(prefix.Length), out num)) n = num + 1; } } } return prefix + n.ToString("D3"); }
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