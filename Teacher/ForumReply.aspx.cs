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
        #region Properties

        protected string CurrentLanguage
        {
            get
            {
                string lang = Session["preferredLanguage"] as string;
                return string.IsNullOrEmpty(lang) ? "EN" : lang;
            }
        }

        private string ConnectionString =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        private string ForumId
        {
            get { return hidForumId.Value ?? ""; }
            set { hidForumId.Value = value; }
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

            ((SiteMaster)Master).LayoutMode = "Sidebar";
            txtReply.Attributes["placeholder"] = T("Write your reply...", "Tulis balasan anda...");

            if (!IsPostBack)
            {
                string forumId = (Request.QueryString["forumId"] ?? "").Trim();
                if (string.IsNullOrEmpty(forumId))
                {
                    ShowError(T("No discussion ID was provided.", "Tiada ID perbincangan disediakan."));
                    return;
                }

                ForumId = forumId;
                ApplyLicenseRestrictions();
                LoadPage();
            }
            else
            {
                if (string.IsNullOrEmpty(ForumId))
                    ShowError(T("No discussion ID was provided.", "Tiada ID perbincangan disediakan."));
            }
        }

        private void ApplyLicenseRestrictions()
        {
            string licenseStatus = GetTeacherLicenseStatus();
            hidLicenseStatus.Value = licenseStatus;

            if (licenseStatus.Equals("Pending", StringComparison.OrdinalIgnoreCase))
            {
                txtReply.Enabled = false;
                txtReply.Attributes["placeholder"] = T(
                    "Replying is disabled until your teaching license has been approved.",
                    "Membalas dilumpuhkan sehingga lesen mengajar anda diluluskan.");
                btnPostReply.Enabled = false;
            }
        }

        #endregion

        #region Event Handlers

        protected void btnLike_Click(object sender, EventArgs e)
        {
            string teacherId = Session["userId"].ToString();
            string forumId = ForumId;

            LikeForumPost(teacherId, forumId);
            LoadPage();
        }

        protected void btnPostReply_Click(object sender, EventArgs e)
        {
            string replyText = txtReply.Text.Trim();

            if (string.IsNullOrEmpty(replyText))
            {
                pnlReplyVal.Visible = true;
                litReplyVal.Text = T("Reply cannot be empty.", "Balasan tidak boleh kosong.");
                LoadPage();
                return;
            }

            pnlReplyVal.Visible = false;
            string teacherId = Session["userId"].ToString();
            string forumId = ForumId;

            CreateReply(teacherId, forumId, replyText);
            NotifyForumCreator(teacherId, forumId);

            txtReply.Text = "";
            hidToast.Value = T("Reply posted successfully.", "Balasan berjaya dihantar.");
            LoadPage();
        }

        #endregion

        #region Data Loading

        private void LoadPage()
        {
            string teacherId = Session["userId"].ToString();
            string forumId = ForumId;

            using (var conn = new SqlConnection(ConnectionString))
            {
                conn.Open();

                if (!LoadMainDiscussion(conn, teacherId, forumId))
                    return;

                LoadReplies(conn, forumId);
                LoadMoreDiscussions(conn, forumId);
            }

            pnlMain.Visible = true;
            pnlError.Visible = false;
        }

        /// <summary>
        /// Loads the main discussion post. Returns false if not found.
        /// </summary>
        private bool LoadMainDiscussion(SqlConnection conn, string teacherId, string forumId)
        {
            const string sql = @"
                SELECT f.[title], f.[message], f.[createdAt], f.[createdBy],
                    COALESCE(t.[name], s.[name], p.[name], u.[username]) AS creatorName,
                    u.[role],
                    (SELECT COUNT(*) FROM dbo.[ForumChat] WHERE [forumId]=f.[forumId]) AS replyCount,
                    (SELECT COUNT(*) FROM dbo.[ForumLike] WHERE [forumId]=f.[forumId]) AS likeCount,
                    (SELECT COUNT(*) FROM dbo.[ForumLike]
                        WHERE [forumId]=f.[forumId] AND [senderUserId]=@teacherId) AS myLike
                FROM dbo.[Forum] f
                INNER JOIN dbo.[User]    u ON u.[userId]=f.[createdBy]
                LEFT  JOIN dbo.[Teacher] t ON t.[userId]=u.[userId]
                LEFT  JOIN dbo.[Student] s ON s.[userId]=u.[userId]
                LEFT  JOIN dbo.[Parent]  p ON p.[userId]=u.[userId]
                WHERE f.[forumId]=@forumId AND f.[discussionType]='Public'";

            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@teacherId", teacherId);
                cmd.Parameters.AddWithValue("@forumId", forumId);

                using (var reader = cmd.ExecuteReader())
                {
                    if (!reader.Read())
                    {
                        ShowError(T(
                            "This discussion was not found or is not a public discussion.",
                            "Perbincangan ini tidak dijumpai atau bukan perbincangan awam."));
                        return false;
                    }

                    string creatorName = reader["creatorName"]?.ToString() ?? "User";
                    string role = reader["role"]?.ToString() ?? "";
                    int replyCount = Convert.ToInt32(reader["replyCount"]);
                    int likeCount = Convert.ToInt32(reader["likeCount"]);
                    bool isLiked = Convert.ToInt32(reader["myLike"]) > 0;
                    DateTime createdAt = reader["createdAt"] != DBNull.Value
                        ? Convert.ToDateTime(reader["createdAt"])
                        : DateTime.Now;

                    litInitials.Text = HttpUtility.HtmlEncode(BuildInitials(creatorName));
                    litCreatorName.Text = HttpUtility.HtmlEncode(creatorName);
                    litRoleBadge.Text = BuildRoleBadgeHtml(role);
                    litPostDate.Text = HttpUtility.HtmlEncode(FormatTimeAgo(createdAt));
                    litTitle.Text = HttpUtility.HtmlEncode(reader["title"]?.ToString() ?? "");
                    litMessage.Text = HttpUtility.HtmlEncode(reader["message"]?.ToString() ?? "");
                    litReplyCount.Text = replyCount.ToString();
                    litRepliesBadge.Text = replyCount.ToString();
                    RenderLikeButton(isLiked, likeCount);
                }
            }

            return true;
        }

        private void LoadReplies(SqlConnection conn, string forumId)
        {
            const string sql = @"
                SELECT fc.[forumChatId], fc.[senderUserId], fc.[message], fc.[createdAt],
                    COALESCE(t.[name], s.[name], p.[name], u.[username]) AS senderName,
                    u.[role]
                FROM dbo.[ForumChat] fc
                INNER JOIN dbo.[User]    u ON u.[userId]=fc.[senderUserId]
                LEFT  JOIN dbo.[Teacher] t ON t.[userId]=u.[userId]
                LEFT  JOIN dbo.[Student] s ON s.[userId]=u.[userId]
                LEFT  JOIN dbo.[Parent]  p ON p.[userId]=u.[userId]
                WHERE fc.[forumId]=@forumId
                ORDER BY fc.[createdAt] ASC";

            var replies = new List<object>();

            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@forumId", forumId);

                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string senderName = reader["senderName"]?.ToString() ?? "User";
                        string role = reader["role"]?.ToString() ?? "";
                        DateTime sentAt = reader["createdAt"] != DBNull.Value
                            ? Convert.ToDateTime(reader["createdAt"])
                            : DateTime.Now;

                        replies.Add(new
                        {
                            initials = BuildInitials(senderName),
                            senderName,
                            roleCss = GetRoleCss(role),
                            roleLabel = GetRoleLabel(role),
                            message = reader["message"]?.ToString() ?? "",
                            timeAgo = FormatTimeAgo(sentAt)
                        });
                    }
                }
            }

            pnlReplies.Visible = replies.Count > 0;
            pnlRepliesEmpty.Visible = replies.Count == 0;

            if (replies.Count > 0)
            {
                rptReplies.DataSource = replies;
                rptReplies.DataBind();
            }
        }

        private void LoadMoreDiscussions(SqlConnection conn, string forumId)
        {
            const string sql = @"
                SELECT TOP 5 f.[forumId], f.[title], f.[createdAt],
                    COALESCE(t.[name], s.[name], p.[name], u.[username]) AS creatorName,
                    u.[role]
                FROM dbo.[Forum] f
                INNER JOIN dbo.[User]    u ON u.[userId]=f.[createdBy]
                LEFT  JOIN dbo.[Teacher] t ON t.[userId]=u.[userId]
                LEFT  JOIN dbo.[Student] s ON s.[userId]=u.[userId]
                LEFT  JOIN dbo.[Parent]  p ON p.[userId]=u.[userId]
                WHERE f.[discussionType]='Public' AND f.[forumId]<>@forumId
                ORDER BY f.[createdAt] DESC";

            var discussions = new List<object>();

            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@forumId", forumId);

                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string creatorName = reader["creatorName"]?.ToString() ?? "User";
                        string role = reader["role"]?.ToString() ?? "";
                        DateTime createdAt = reader["createdAt"] != DBNull.Value
                            ? Convert.ToDateTime(reader["createdAt"])
                            : DateTime.Now;
                        string title = reader["title"]?.ToString() ?? "";

                        discussions.Add(new
                        {
                            forumId = reader["forumId"].ToString(),
                            title = title.Length > 60 ? title.Substring(0, 60) + "…" : title,
                            creatorName,
                            initials = BuildInitials(creatorName),
                            timeAgo = FormatTimeAgo(createdAt),
                            roleCss = GetRoleCss(role)
                        });
                    }
                }
            }

            if (discussions.Count > 0)
            {
                rptMore.DataSource = discussions;
                rptMore.DataBind();
            }
        }

        #endregion

        #region Database Operations

        private void LikeForumPost(string teacherId, string forumId)
        {
            using (var conn = new SqlConnection(ConnectionString))
            {
                conn.Open();

                // Check if already liked — only allow one like per user
                using (var cmd = new SqlCommand(
                    "SELECT COUNT(*) FROM dbo.[ForumLike] WHERE [forumId]=@forumId AND [senderUserId]=@teacherId", conn))
                {
                    cmd.Parameters.AddWithValue("@forumId", forumId);
                    cmd.Parameters.AddWithValue("@teacherId", teacherId);
                    int alreadyLiked = Convert.ToInt32(cmd.ExecuteScalar());
                    if (alreadyLiked > 0) return;
                }

                using (var txn = conn.BeginTransaction())
                {
                    string likeId;
                    using (var cmd = new SqlCommand(
                        "SELECT ISNULL(MAX(CAST(SUBSTRING([likeId],5,LEN([likeId])-4) AS INT)),0) FROM dbo.[ForumLike]",
                        conn, txn))
                    {
                        likeId = "LIKE" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3");
                    }

                    using (var cmd = new SqlCommand(
                        "INSERT INTO dbo.[ForumLike]([likeId],[forumId],[senderUserId],[createdAt]) VALUES(@likeId,@forumId,@teacherId,GETDATE())",
                        conn, txn))
                    {
                        cmd.Parameters.AddWithValue("@likeId", likeId);
                        cmd.Parameters.AddWithValue("@forumId", forumId);
                        cmd.Parameters.AddWithValue("@teacherId", teacherId);
                        cmd.ExecuteNonQuery();
                    }

                    txn.Commit();
                }
            }
        }

        private void CreateReply(string teacherId, string forumId, string replyText)
        {
            using (var conn = new SqlConnection(ConnectionString))
            {
                conn.Open();
                using (var txn = conn.BeginTransaction())
                {
                    string chatId;
                    using (var cmd = new SqlCommand(
                        "SELECT ISNULL(MAX(CAST(SUBSTRING([forumChatId],3,LEN([forumChatId])-2) AS INT)),0) FROM dbo.[ForumChat]",
                        conn, txn))
                    {
                        chatId = "FC" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3");
                    }

                    const string insertSql = @"INSERT INTO dbo.[ForumChat]
                        ([forumChatId],[forumId],[senderUserId],[message],[createdAt])
                        VALUES(@chatId, @forumId, @teacherId, @message, GETDATE())";

                    using (var cmd = new SqlCommand(insertSql, conn, txn))
                    {
                        cmd.Parameters.AddWithValue("@chatId", chatId);
                        cmd.Parameters.AddWithValue("@forumId", forumId);
                        cmd.Parameters.AddWithValue("@teacherId", teacherId);
                        cmd.Parameters.AddWithValue("@message", replyText);
                        cmd.ExecuteNonQuery();
                    }

                    txn.Commit();
                }
            }
        }

        /// <summary>
        /// Sends a notification to the original forum creator when a new reply is posted.
        /// Non-critical — failures are silently ignored.
        /// </summary>
        private void NotifyForumCreator(string replierId, string forumId)
        {
            try
            {
                using (var conn = new SqlConnection(ConnectionString))
                {
                    conn.Open();

                    // Get original post creator
                    string creatorId;
                    using (var cmd = new SqlCommand("SELECT [createdBy] FROM dbo.[Forum] WHERE [forumId]=@forumId", conn))
                    {
                        cmd.Parameters.AddWithValue("@forumId", forumId);
                        creatorId = cmd.ExecuteScalar()?.ToString();
                    }

                    // Don't notify yourself
                    if (string.IsNullOrEmpty(creatorId) || creatorId == replierId)
                        return;

                    // Generate notification ID
                    string notificationId;
                    using (var cmd = new SqlCommand(
                        "SELECT ISNULL(MAX(CAST(SUBSTRING([notificationId],2,LEN([notificationId])-1) AS INT)),0) FROM dbo.[Notification]", conn))
                    {
                        notificationId = "N" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3");
                    }

                    const string insertSql = @"INSERT INTO dbo.[Notification]
                        ([notificationId],[toUserId],[titleEN],[titleBM],[messageEN],[messageBM],[isRead],[createdAt])
                        VALUES(@id, @toUserId, @titleEN, @titleBM, @messageEN, @messageBM, 0, GETDATE())";

                    using (var cmd = new SqlCommand(insertSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@id", notificationId);
                        cmd.Parameters.AddWithValue("@toUserId", creatorId);
                        cmd.Parameters.AddWithValue("@titleEN", "New Forum Reply");
                        cmd.Parameters.AddWithValue("@titleBM", "Balasan Forum Baharu");
                        cmd.Parameters.AddWithValue("@messageEN", "Your forum discussion has received a new reply.");
                        cmd.Parameters.AddWithValue("@messageBM", "Perbincangan forum anda telah menerima balasan baharu.");
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch
            {
                // Notification failure is non-critical
            }
        }

        private string GetTeacherLicenseStatus()
        {
            try
            {
                using (var conn = new SqlConnection(ConnectionString))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("SELECT [status] FROM dbo.[Teacher] WHERE [userId]=@u", conn))
                    {
                        cmd.Parameters.AddWithValue("@u", Session["userId"].ToString());
                        var result = cmd.ExecuteScalar();
                        return result != null && result != DBNull.Value ? result.ToString() : "";
                    }
                }
            }
            catch
            {
                return "";
            }
        }

        #endregion

        #region Helper Methods

        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        private void ShowError(string message)
        {
            litErrMsg.Text = HttpUtility.HtmlEncode(message);
            pnlError.Visible = true;
            pnlMain.Visible = false;
            if (pnlReplyVal != null) pnlReplyVal.Visible = false;
        }

        private void RenderLikeButton(bool isLiked, int likeCount)
        {
            btnLike.CssClass = "tc-forum-reply-like-btn " + (isLiked ? "liked" : "notliked");
            string iconClass = isLiked ? "bi bi-heart-fill" : "bi bi-heart";
            string label = isLiked ? T("Liked", "Disukai") : T("Like", "Suka");
            btnLike.Text = string.Format("<i class=\"{0}\"></i> {1} {2}", iconClass, likeCount, HttpUtility.HtmlEncode(label));
        }

        private string BuildRoleBadgeHtml(string role)
        {
            return string.Format("<span class=\"tc-forum-reply-role-badge {0}\">{1}</span>",
                HttpUtility.HtmlAttributeEncode(GetRoleCss(role)),
                HttpUtility.HtmlEncode(GetRoleLabel(role)));
        }

        private static string BuildInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "U";

            string[] parts = name.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length >= 2)
                return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();

            return name.Trim()[0].ToString().ToUpper();
        }

        private static string GetRoleCss(string role)
        {
            switch ((role ?? "").Trim().ToLower())
            {
                case "teacher": return "teacher";
                case "student": return "student";
                case "parent": return "parent";
                default: return "";
            }
        }

        private string GetRoleLabel(string role)
        {
            switch ((role ?? "").Trim().ToLower())
            {
                case "teacher": return T("Teacher", "Guru");
                case "student": return T("Student", "Pelajar");
                case "parent": return T("Parent", "Ibu Bapa");
                default: return role ?? "";
            }
        }

        private static string FormatTimeAgo(DateTime dateTime)
        {
            TimeSpan elapsed = DateTime.Now - dateTime;

            if (elapsed.TotalMinutes < 1) return "Just now";
            if (elapsed.TotalHours < 1) return (int)elapsed.TotalMinutes + " min ago";
            if (elapsed.TotalDays < 1) return (int)elapsed.TotalHours + " hr ago";
            if (elapsed.TotalDays < 7)
            {
                int days = (int)elapsed.TotalDays;
                return days + " day" + (days == 1 ? "" : "s") + " ago";
            }

            return dateTime.ToString("d MMM yyyy, h:mm tt");
        }

        #endregion
    }
}
