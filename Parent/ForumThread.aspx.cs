using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Parent
{
    public partial class ForumThread : Page
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
            _userId = Session["userId"].ToString();
            _forumId = Request.QueryString["forumId"] ?? "";
            if (!IsPostBack) { btnReply.Text = T("Post Reply", "Hantar Balasan"); btnDeleteThread.Text = T("Confirm Delete", "Sahkan Padam"); LoadThread(); }
            else { LoadThread(); }
        }

        private void LoadThread()
        {
            if (string.IsNullOrEmpty(_forumId)) { pnlNotFound.Visible = true; return; }
            try
            {
                using (var c = new SqlConnection(ConnStr))
                {
                    c.Open();
                    string createdBy = "";
                    using (var cmd = new SqlCommand(@"SELECT f.forumId, f.createdBy, f.title, f.message, f.discussionType, f.createdAt, u.username
                        FROM dbo.Forum f INNER JOIN dbo.[User] u ON f.createdBy=u.userId WHERE f.forumId=@id", c))
                    {
                        cmd.Parameters.AddWithValue("@id", _forumId);
                        using (var r = cmd.ExecuteReader())
                        {
                            if (!r.Read()) { pnlNotFound.Visible = true; return; }
                            createdBy = r["createdBy"].ToString();
                            litAuthorInitial.Text = r["username"].ToString().Substring(0, 1).ToUpper();
                            litAuthorName.Text = r["username"].ToString();
                            litDate.Text = T("Posted ", "Dihantar pada ") + GetTimeAgo(Convert.ToDateTime(r["createdAt"]));
                            litTitle.Text = Server.HtmlEncode(r["title"].ToString());
                            litMessage.Text = Server.HtmlEncode(r["message"].ToString()).Replace("\n", "<br/>");
                            string type = r["discussionType"].ToString();
                            litTypeBadge.Text = " <span class='pt-forum-type-badge'>" + type + "</span>";
                        }
                    }

                    pnlThread.Visible = true;

                    // Tags
                    pnlTags.Controls.Clear();
                    using (var cmd = new SqlCommand("SELECT t.tagName FROM dbo.ForumTag ft INNER JOIN dbo.Tag t ON ft.tagId=t.tagId WHERE ft.forumId=@id", c))
                    { cmd.Parameters.AddWithValue("@id", _forumId); using (var r = cmd.ExecuteReader()) { StringBuilder sb = new StringBuilder(); while (r.Read()) sb.Append("<span class='pt-forum-tag'>" + Server.HtmlEncode(r["tagName"].ToString()) + "</span> "); if (sb.Length > 0) pnlTags.Controls.Add(new LiteralControl(sb.ToString())); } }

                    // Likes
                    int likeCount = 0; bool userLiked = false;
                    using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.ForumLike WHERE forumId=@id", c)) { cmd.Parameters.AddWithValue("@id", _forumId); likeCount = (int)cmd.ExecuteScalar(); }
                    using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.ForumLike WHERE forumId=@id AND senderUserId=@uid", c)) { cmd.Parameters.AddWithValue("@id", _forumId); cmd.Parameters.AddWithValue("@uid", _userId); userLiked = (int)cmd.ExecuteScalar() > 0; }
                    litLikeCount.Text = likeCount.ToString();
                    btnLike.CssClass = userLiked ? "pt-forum-like-btn pt-forum-liked" : "pt-forum-like-btn";
                    btnLike.Text = userLiked ? "<i class='bi bi-heart-fill'></i> " + likeCount : "<i class='bi bi-heart'></i> " + likeCount;

                    // Replies
                    int replyCount = 0;
                    using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.ForumChat WHERE forumId=@id", c)) { cmd.Parameters.AddWithValue("@id", _forumId); replyCount = (int)cmd.ExecuteScalar(); }
                    litReplyCount.Text = replyCount.ToString();

                    pnlReplies.Controls.Clear();
                    using (var cmd = new SqlCommand("SELECT fc.message, fc.createdAt, u.username FROM dbo.ForumChat fc INNER JOIN dbo.[User] u ON fc.senderUserId=u.userId WHERE fc.forumId=@id ORDER BY fc.createdAt ASC", c))
                    {
                        cmd.Parameters.AddWithValue("@id", _forumId);
                        using (var r = cmd.ExecuteReader())
                        {
                            StringBuilder sb = new StringBuilder(); bool has = false;
                            while (r.Read()) { has = true; string postedText = T("Posted ", "Dihantar pada ") + GetTimeAgo(Convert.ToDateTime(r["createdAt"])); sb.AppendFormat("<div class='pt-forum-reply-card'><div class='pt-forum-reply-avatar'>{0}</div><div class='pt-forum-reply-content'><div class='pt-forum-reply-meta'><span class='pt-forum-reply-author'>{1}</span> <span class='pt-forum-reply-date'>&bull; {2}</span></div><div class='pt-forum-reply-message'>{3}</div></div></div>", r["username"].ToString().Substring(0, 1).ToUpper(), Server.HtmlEncode(r["username"].ToString()), postedText, Server.HtmlEncode(r["message"].ToString()).Replace("\n","<br/>")); }
                            if (has) { pnlReplies.Controls.Add(new LiteralControl(sb.ToString())); pnlNoReplies.Visible = false; } else pnlNoReplies.Visible = true;
                        }
                    }

                    // Owner actions
                    if (createdBy == _userId) { pnlOwnerActions.Visible = true; lnkEdit.HRef = "EditDiscussion.aspx?forumId=" + _forumId; }
                    else { pnlOwnerActions.Visible = false; }
                }
            }
            catch { pnlNotFound.Visible = true; }
        }

        protected void BtnLike_Click(object sender, EventArgs e)
        {
            try
            {
                using (var c = new SqlConnection(ConnStr)) { c.Open();
                    bool liked = false;
                    using (var cmd = new SqlCommand("SELECT likeId FROM dbo.ForumLike WHERE forumId=@fid AND senderUserId=@uid", c))
                    { cmd.Parameters.AddWithValue("@fid", _forumId); cmd.Parameters.AddWithValue("@uid", _userId); var r = cmd.ExecuteScalar(); if (r != null && r != DBNull.Value) liked = true; }

                    if (liked)
                    { using (var cmd = new SqlCommand("DELETE FROM dbo.ForumLike WHERE forumId=@fid AND senderUserId=@uid", c)) { cmd.Parameters.AddWithValue("@fid", _forumId); cmd.Parameters.AddWithValue("@uid", _userId); cmd.ExecuteNonQuery(); } }
                    else
                    {
                        using (var txn = c.BeginTransaction()) { try {
                            string likeId = GenId(c, txn, "ForumLike", "likeId", "LIKE");
                            using (var cmd = new SqlCommand("INSERT INTO dbo.ForumLike(likeId,forumId,senderUserId,createdAt) VALUES(@id,@fid,@uid,@now)", c, txn))
                            { cmd.Parameters.AddWithValue("@id", likeId); cmd.Parameters.AddWithValue("@fid", _forumId); cmd.Parameters.AddWithValue("@uid", _userId); cmd.Parameters.AddWithValue("@now", DateTime.Now); cmd.ExecuteNonQuery(); }
                            // Notify thread author
                            string authorId = ""; using (var cmd = new SqlCommand("SELECT createdBy FROM dbo.Forum WHERE forumId=@id", c, txn)) { cmd.Parameters.AddWithValue("@id", _forumId); authorId = cmd.ExecuteScalar()?.ToString() ?? ""; }
                            if (!string.IsNullOrEmpty(authorId) && authorId != _userId)
                            {
                                string nid = GenId(c, txn, "Notification", "notificationId", "N");
                                string threadTitle = ""; using (var cmd = new SqlCommand("SELECT title FROM dbo.Forum WHERE forumId=@id", c, txn)) { cmd.Parameters.AddWithValue("@id", _forumId); threadTitle = cmd.ExecuteScalar()?.ToString() ?? ""; }
                                string username = ""; using (var cmd = new SqlCommand("SELECT username FROM dbo.[User] WHERE userId=@u", c, txn)) { cmd.Parameters.AddWithValue("@u", _userId); username = cmd.ExecuteScalar()?.ToString() ?? ""; }
                                using (var cmd = new SqlCommand("INSERT INTO dbo.Notification(notificationId,toUserId,titleEN,titleBM,messageEN,messageBM,isRead,createdAt) VALUES(@id,@to,@te,@tb,@me,@mb,0,@now)", c, txn))
                                { cmd.Parameters.AddWithValue("@id", nid); cmd.Parameters.AddWithValue("@to", authorId); cmd.Parameters.AddWithValue("@te", "Someone liked your forum post"); cmd.Parameters.AddWithValue("@tb", "Seseorang menyukai hantaran forum anda"); cmd.Parameters.AddWithValue("@me", username + " liked your forum post: " + threadTitle + "."); cmd.Parameters.AddWithValue("@mb", username + " menyukai hantaran forum anda: " + threadTitle + "."); cmd.Parameters.AddWithValue("@now", DateTime.Now); cmd.ExecuteNonQuery(); }
                            }
                            txn.Commit();
                        } catch { txn.Rollback(); } }
                    }
                }
            }
            catch { }
            LoadThread();
        }

        protected void BtnReply_Click(object sender, EventArgs e)
        {
            string reply = txtReply.Text.Trim();
            if (string.IsNullOrEmpty(reply)) { ShowMsg(T("Reply cannot be empty.", "Balasan tidak boleh kosong."), false); return; }
            try
            {
                using (var c = new SqlConnection(ConnStr)) { c.Open(); using (var txn = c.BeginTransaction()) { try {
                    string fcId = GenId(c, txn, "ForumChat", "forumChatId", "FC");
                    using (var cmd = new SqlCommand("INSERT INTO dbo.ForumChat(forumChatId,forumId,senderUserId,message,createdAt) VALUES(@id,@fid,@uid,@msg,@now)", c, txn))
                    { cmd.Parameters.AddWithValue("@id", fcId); cmd.Parameters.AddWithValue("@fid", _forumId); cmd.Parameters.AddWithValue("@uid", _userId); cmd.Parameters.AddWithValue("@msg", reply); cmd.Parameters.AddWithValue("@now", DateTime.Now); cmd.ExecuteNonQuery(); }
                    // Notify thread author
                    string authorId = ""; using (var cmd = new SqlCommand("SELECT createdBy FROM dbo.Forum WHERE forumId=@id", c, txn)) { cmd.Parameters.AddWithValue("@id", _forumId); authorId = cmd.ExecuteScalar()?.ToString() ?? ""; }
                    if (!string.IsNullOrEmpty(authorId) && authorId != _userId)
                    {
                        string nid = GenId(c, txn, "Notification", "notificationId", "N");
                        string threadTitle = ""; using (var cmd = new SqlCommand("SELECT title FROM dbo.Forum WHERE forumId=@id", c, txn)) { cmd.Parameters.AddWithValue("@id", _forumId); threadTitle = cmd.ExecuteScalar()?.ToString() ?? ""; }
                        string username = ""; using (var cmd = new SqlCommand("SELECT username FROM dbo.[User] WHERE userId=@u", c, txn)) { cmd.Parameters.AddWithValue("@u", _userId); username = cmd.ExecuteScalar()?.ToString() ?? ""; }
                        using (var cmd = new SqlCommand("INSERT INTO dbo.Notification(notificationId,toUserId,titleEN,titleBM,messageEN,messageBM,isRead,createdAt) VALUES(@id,@to,@te,@tb,@me,@mb,0,@now)", c, txn))
                        { cmd.Parameters.AddWithValue("@id", nid); cmd.Parameters.AddWithValue("@to", authorId); cmd.Parameters.AddWithValue("@te", "New forum reply"); cmd.Parameters.AddWithValue("@tb", "Balasan forum baharu"); cmd.Parameters.AddWithValue("@me", username + " replied to your forum post: " + threadTitle + "."); cmd.Parameters.AddWithValue("@mb", username + " membalas hantaran forum anda: " + threadTitle + "."); cmd.Parameters.AddWithValue("@now", DateTime.Now); cmd.ExecuteNonQuery(); }
                    }
                    txn.Commit(); txtReply.Text = "";
                } catch { txn.Rollback(); throw; } } }
            }
            catch { ShowMsg(T("Error posting reply.", "Ralat menghantar balasan."), false); }
            LoadThread();
        }

        protected void BtnDeleteThread_Click(object sender, EventArgs e)
        {
            try
            {
                using (var c = new SqlConnection(ConnStr)) { c.Open(); using (var txn = c.BeginTransaction()) { try {
                    // Verify ownership
                    string owner = ""; using (var cmd = new SqlCommand("SELECT createdBy FROM dbo.Forum WHERE forumId=@id", c, txn)) { cmd.Parameters.AddWithValue("@id", _forumId); owner = cmd.ExecuteScalar()?.ToString() ?? ""; }
                    if (owner != _userId) { txn.Rollback(); return; }
                    using (var cmd = new SqlCommand("DELETE FROM dbo.ForumLike WHERE forumId=@id", c, txn)) { cmd.Parameters.AddWithValue("@id", _forumId); cmd.ExecuteNonQuery(); }
                    using (var cmd = new SqlCommand("DELETE FROM dbo.ForumTag WHERE forumId=@id", c, txn)) { cmd.Parameters.AddWithValue("@id", _forumId); cmd.ExecuteNonQuery(); }
                    using (var cmd = new SqlCommand("DELETE FROM dbo.ForumChat WHERE forumId=@id", c, txn)) { cmd.Parameters.AddWithValue("@id", _forumId); cmd.ExecuteNonQuery(); }
                    using (var cmd = new SqlCommand("DELETE FROM dbo.Forum WHERE forumId=@id", c, txn)) { cmd.Parameters.AddWithValue("@id", _forumId); cmd.ExecuteNonQuery(); }
                    txn.Commit();
                    Response.Redirect("Forum.aspx", false); Context.ApplicationInstance.CompleteRequest();
                } catch { txn.Rollback(); } } }
            }
            catch { }
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
        private string GetTimeAgo(DateTime dt) { var d = DateTime.Now - dt; if (d.TotalSeconds < 0) return dt.ToString("dd MMM yyyy"); if (d.TotalMinutes < 60) return (int)d.TotalMinutes + " min ago"; if (d.TotalHours < 24) return (int)d.TotalHours + " hours ago"; if (d.TotalDays < 31) return (int)d.TotalDays + " days ago"; return dt.ToString("dd MMM yyyy"); }
        private void ShowMsg(string msg, bool ok) { pnlMessage.Visible = true; divMsg.InnerHtml = msg; iMsgIcon.Attributes["class"] = ok ? "bi bi-check-circle-fill" : "bi bi-exclamation-circle-fill"; }
        protected void BtnCloseMsg_Click(object sender, EventArgs e) { pnlMessage.Visible = false; LoadThread(); }
        private void LoadSidebarChildren()
        {
            try { using (var c = new System.Data.SqlClient.SqlConnection(ConnStr)) { string pid = ""; using (var cmd = new System.Data.SqlClient.SqlCommand("SELECT parentId FROM dbo.[Parent] WHERE userId=@u", c)) { cmd.Parameters.AddWithValue("@u", Session["userId"].ToString()); c.Open(); var r = cmd.ExecuteScalar(); if (r != null) pid = r.ToString(); } using (var cmd = new System.Data.SqlClient.SqlCommand("SELECT s.studentId, ISNULL(s.nickname,s.name) AS n FROM dbo.StudentParent sp INNER JOIN dbo.Student s ON sp.studentId=s.studentId WHERE sp.parentId=@p ORDER BY s.name", c)) { cmd.Parameters.AddWithValue("@p", pid); using (var r = cmd.ExecuteReader()) { while (r.Read()) ddlSidebarChild2.Items.Add(new System.Web.UI.WebControls.ListItem(r["n"].ToString(), r["studentId"].ToString())); } } } } catch { }
            string saved = Session["selectedChildId"] as string;
            if (!string.IsNullOrEmpty(saved) && ddlSidebarChild2.Items.FindByValue(saved) != null) ddlSidebarChild2.SelectedValue = saved;
        }
    }
}