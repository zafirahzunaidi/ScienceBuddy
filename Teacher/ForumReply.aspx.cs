using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Teacher
{
    public partial class ForumReply : Page
    {
        protected string CurrentLanguage
        {
            get { string l = Session["preferredLanguage"] as string; return string.IsNullOrEmpty(l) ? "EN" : l; }
        }
        protected string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        private string ForumId
        {
            get { return hidForumId.Value ?? ""; }
            set { hidForumId.Value = value; }
        }

        // ════════════════════════════════════════════════════════════
        //  PAGE LOAD
        // ════════════════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"]?.ToString() != "Teacher")
            { Response.Redirect("~/Login.aspx", false); Context.ApplicationInstance.CompleteRequest(); return; }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";

            txtReply.Attributes["placeholder"] = T("Write your reply...", "Tulis balasan anda...");

            if (!IsPostBack)
            {
                string qsId = (Request.QueryString["forumId"] ?? "").Trim();
                if (string.IsNullOrEmpty(qsId))
                { ShowError(T("No discussion ID was provided.", "Tiada ID perbincangan disediakan.")); return; }
                ForumId = qsId;
                LoadPage();
            }
            else
            {
                if (string.IsNullOrEmpty(ForumId))
                    ShowError(T("No discussion ID was provided.", "Tiada ID perbincangan disediakan."));
            }
        }

        // ════════════════════════════════════════════════════════════
        //  LOAD ALL PAGE DATA
        // ════════════════════════════════════════════════════════════
        private void LoadPage()
        {
            string userId  = Session["userId"].ToString();
            string forumId = ForumId;

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // ── 1. Main discussion post (Public only) ─────────────
                const string sqlPost = @"
                    SELECT f.[title], f.[message], f.[createdAt], f.[createdBy],
                        COALESCE(t.[name], s.[name], p.[name], u.[username]) AS creatorName,
                        u.[role],
                        (SELECT COUNT(*) FROM dbo.[ForumChat] WHERE [forumId]=f.[forumId]) AS replyCount,
                        (SELECT COUNT(*) FROM dbo.[ForumLike] WHERE [forumId]=f.[forumId]) AS likeCount,
                        (SELECT COUNT(*) FROM dbo.[ForumLike]
                            WHERE [forumId]=f.[forumId] AND [senderUserId]=@uid) AS myLike
                    FROM dbo.[Forum] f
                    INNER JOIN dbo.[User]    u ON u.[userId]=f.[createdBy]
                    LEFT  JOIN dbo.[Teacher] t ON t.[userId]=u.[userId]
                    LEFT  JOIN dbo.[Student] s ON s.[userId]=u.[userId]
                    LEFT  JOIN dbo.[Parent]  p ON p.[userId]=u.[userId]
                    WHERE f.[forumId]=@fid AND f.[discussionType]='Public'";

                string creatorUserId = null;
                using (var cmd = new SqlCommand(sqlPost, conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    cmd.Parameters.AddWithValue("@fid", forumId);
                    using (var r = cmd.ExecuteReader())
                    {
                        if (!r.Read())
                        {
                            ShowError(T("This discussion was not found or is not a public discussion.",
                                "Perbincangan ini tidak dijumpai atau bukan perbincangan awam.")); return;
                        }
                        string name    = r["creatorName"]?.ToString() ?? "User";
                        string role    = r["role"]?.ToString()        ?? "";
                        int replyCnt   = Convert.ToInt32(r["replyCount"]);
                        int likeCnt    = Convert.ToInt32(r["likeCount"]);
                        bool liked     = Convert.ToInt32(r["myLike"]) > 0;
                        DateTime dt    = r["createdAt"] != DBNull.Value ? Convert.ToDateTime(r["createdAt"]) : DateTime.Now;
                        creatorUserId  = r["createdBy"]?.ToString();

                        litInitials.Text     = HttpUtility.HtmlEncode(BuildInitials(name));
                        litCreatorName.Text  = HttpUtility.HtmlEncode(name);
                        litRoleBadge.Text    = BuildRoleBadge(role);
                        litPostDate.Text     = HttpUtility.HtmlEncode(FormatTime(dt));
                        litTitle.Text        = HttpUtility.HtmlEncode(r["title"]?.ToString()   ?? "");
                        litMessage.Text      = HttpUtility.HtmlEncode(r["message"]?.ToString() ?? "");
                        litReplyCount.Text   = replyCnt.ToString();
                        litRepliesBadge.Text = replyCnt.ToString();
                        RenderLikeButton(liked, likeCnt);
                    }
                }

                // ── 2. Replies ────────────────────────────────────────
                const string sqlReplies = @"
                    SELECT fc.[forumChatId], fc.[senderUserId], fc.[message], fc.[createdAt],
                        COALESCE(t.[name], s.[name], p.[name], u.[username]) AS senderName,
                        u.[role]
                    FROM dbo.[ForumChat] fc
                    INNER JOIN dbo.[User]    u ON u.[userId]=fc.[senderUserId]
                    LEFT  JOIN dbo.[Teacher] t ON t.[userId]=u.[userId]
                    LEFT  JOIN dbo.[Student] s ON s.[userId]=u.[userId]
                    LEFT  JOIN dbo.[Parent]  p ON p.[userId]=u.[userId]
                    WHERE fc.[forumId]=@fid ORDER BY fc.[createdAt] ASC";

                var replies = new List<object>();

                using (var cmd = new SqlCommand(sqlReplies, conn))
                {
                    cmd.Parameters.AddWithValue("@fid", forumId);
                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            string sName  = r["senderName"]?.ToString() ?? "User";
                            string sRole  = r["role"]?.ToString()       ?? "";
                            DateTime sent = r["createdAt"] != DBNull.Value ? Convert.ToDateTime(r["createdAt"]) : DateTime.Now;

                            replies.Add(new { initials = BuildInitials(sName), senderName = sName,
                                roleCss = RoleCss(sRole), roleLabel = RoleLabel(sRole),
                                message = r["message"]?.ToString() ?? "", timeAgo = FormatTime(sent) });
                        }
                    }
                }

                pnlReplies.Visible      = replies.Count > 0;
                pnlRepliesEmpty.Visible = replies.Count == 0;
                if (replies.Count > 0) { rptReplies.DataSource = replies; rptReplies.DataBind(); }

                // ── 3. More Discussions (up to 5, excluding current) ──
                const string sqlMore = @"
                    SELECT TOP 5 f.[forumId], f.[title], f.[createdAt],
                        COALESCE(t.[name], s.[name], p.[name], u.[username]) AS creatorName,
                        u.[role]
                    FROM dbo.[Forum] f
                    INNER JOIN dbo.[User]    u ON u.[userId]=f.[createdBy]
                    LEFT  JOIN dbo.[Teacher] t ON t.[userId]=u.[userId]
                    LEFT  JOIN dbo.[Student] s ON s.[userId]=u.[userId]
                    LEFT  JOIN dbo.[Parent]  p ON p.[userId]=u.[userId]
                    WHERE f.[discussionType]='Public' AND f.[forumId]<>@fid
                    ORDER BY f.[createdAt] DESC";

                var moreList = new List<object>();
                using (var cmd = new SqlCommand(sqlMore, conn))
                {
                    cmd.Parameters.AddWithValue("@fid", forumId);
                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            string mn   = r["creatorName"]?.ToString() ?? "User";
                            string mRole = r["role"]?.ToString() ?? "";
                            DateTime md = r["createdAt"] != DBNull.Value ? Convert.ToDateTime(r["createdAt"]) : DateTime.Now;
                            string mt   = r["title"]?.ToString() ?? "";
                            moreList.Add(new { forumId = r["forumId"].ToString(),
                                title = mt.Length > 60 ? mt.Substring(0, 60) + "…" : mt,
                                creatorName = mn, initials = BuildInitials(mn), timeAgo = FormatTime(md),
                                roleCss = RoleCss(mRole) });
                        }
                    }
                }
                if (moreList.Count > 0) { rptMore.DataSource = moreList; rptMore.DataBind(); }
            }

            pnlMain.Visible  = true;
            pnlError.Visible = false;
        }

        // ════════════════════════════════════════════════════════════
        //  LIKE / UNLIKE
        // ════════════════════════════════════════════════════════════
        //  LIKE (no unlike — one like per user only)
        // ════════════════════════════════════════════════════════════
        protected void btnLike_Click(object sender, EventArgs e)
        {
            string userId = Session["userId"].ToString();
            string forumId = ForumId;
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                // Check if already liked — if so, do nothing
                int exists;
                using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[ForumLike] WHERE [forumId]=@f AND [senderUserId]=@u", conn))
                { cmd.Parameters.AddWithValue("@f", forumId); cmd.Parameters.AddWithValue("@u", userId); exists = Convert.ToInt32(cmd.ExecuteScalar()); }

                if (exists == 0)
                {
                    // Insert like
                    using (var txn = conn.BeginTransaction())
                    {
                        string newId;
                        using (var cmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING([likeId],5,LEN([likeId])-4) AS INT)),0) FROM dbo.[ForumLike]", conn, txn))
                        { newId = "LIKE" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3"); }
                        using (var cmd = new SqlCommand("INSERT INTO dbo.[ForumLike]([likeId],[forumId],[senderUserId],[createdAt]) VALUES(@id,@f,@u,GETDATE())", conn, txn))
                        { cmd.Parameters.AddWithValue("@id", newId); cmd.Parameters.AddWithValue("@f", forumId); cmd.Parameters.AddWithValue("@u", userId); cmd.ExecuteNonQuery(); }
                        txn.Commit();
                    }
                }
                // If already liked, do nothing (no unlike)
            }
            LoadPage();
        }

        // ════════════════════════════════════════════════════════════
        //  POST REPLY
        // ════════════════════════════════════════════════════════════
        protected void btnPostReply_Click(object sender, EventArgs e)
        {
            string replyText = txtReply.Text.Trim();
            if (string.IsNullOrEmpty(replyText))
            {
                pnlReplyVal.Visible = true;
                litReplyVal.Text    = T("Reply cannot be empty.", "Balasan tidak boleh kosong.");
                LoadPage(); return;
            }
            pnlReplyVal.Visible = false;
            string userId  = Session["userId"].ToString();
            string forumId = ForumId;
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var txn = conn.BeginTransaction())
                {
                    string newId;
                    using (var cmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING([forumChatId],3,LEN([forumChatId])-2) AS INT)),0) FROM dbo.[ForumChat]", conn, txn))
                    { newId = "FC" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3"); }
                    using (var cmd = new SqlCommand("INSERT INTO dbo.[ForumChat]([forumChatId],[forumId],[senderUserId],[message],[createdAt]) VALUES(@id,@fid,@uid,@msg,GETDATE())", conn, txn))
                    { cmd.Parameters.AddWithValue("@id", newId); cmd.Parameters.AddWithValue("@fid", forumId); cmd.Parameters.AddWithValue("@uid", userId); cmd.Parameters.AddWithValue("@msg", replyText); cmd.ExecuteNonQuery(); }
                    txn.Commit();
                }
            }
            txtReply.Text  = "";
            hidToast.Value = T("Reply posted successfully.", "Balasan berjaya dihantar.");
            LoadPage();
        }

        // ════════════════════════════════════════════════════════════
        //  HELPERS
        // ════════════════════════════════════════════════════════════
        private void RenderLikeButton(bool liked, int likeCount)
        {
            btnLike.CssClass = "frd-like-btn " + (liked ? "liked" : "notliked");
            string icon  = liked ? "bi bi-heart-fill" : "bi bi-heart";
            string label = liked ? T("Liked", "Disukai") : T("Like", "Suka");
            btnLike.Text = string.Format("<i class=\"{0}\"></i> {1} {2}", icon, likeCount, HttpUtility.HtmlEncode(label));
        }

        private string BuildRoleBadge(string role)
        {
            return string.Format("<span class=\"frd-role-badge {0}\">{1}</span>",
                HttpUtility.HtmlAttributeEncode(RoleCss(role)), HttpUtility.HtmlEncode(RoleLabel(role)));
        }

        private void ShowError(string message)
        {
            litErrMsg.Text   = HttpUtility.HtmlEncode(message);
            pnlError.Visible = true;
            pnlMain.Visible  = false;
            if (pnlReplyVal != null) pnlReplyVal.Visible = false;
        }

        private static string BuildInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "U";
            string[] parts = name.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length >= 2) return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
            return name.Trim()[0].ToString().ToUpper();
        }

        private static string RoleCss(string role)
        {
            switch ((role ?? "").Trim().ToLower())
            {
                case "teacher": return "teacher";
                case "student": return "student";
                case "parent":  return "parent";
                default:        return "";
            }
        }

        private string RoleLabel(string role)
        {
            switch ((role ?? "").Trim().ToLower())
            {
                case "teacher": return T("Teacher", "Guru");
                case "student": return T("Student", "Pelajar");
                case "parent":  return T("Parent",  "Ibu Bapa");
                default:        return role ?? "";
            }
        }

        private static string FormatTime(DateTime dt)
        {
            TimeSpan span = DateTime.Now - dt;
            if (span.TotalMinutes < 1)  return "Just now";
            if (span.TotalHours   < 1)  return (int)span.TotalMinutes + " min ago";
            if (span.TotalDays    < 1)  return (int)span.TotalHours   + " hr ago";
            if (span.TotalDays    < 7)  return (int)span.TotalDays + " day" + ((int)span.TotalDays == 1 ? "" : "s") + " ago";
            return dt.ToString("d MMM yyyy, h:mm tt");
        }
    }
}
