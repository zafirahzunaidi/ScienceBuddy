using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Student
{
    public partial class ForumThread1 : Page
    {
        // ── Connection string ─────────────────────────────────────────
        private string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString; }
        }

        // ── Language helper ────────────────────────────────────────────
        public string CurrentLanguage = "EN";

        public string T(string en, string bm)
        {
            if (CurrentLanguage == "BM")
            {
                return bm;
            }
            return en;
        }

        // ── Page Load ─────────────────────────────────────────────────
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null ||
                Session["role"].ToString() != "Student")
            {
                Response.Redirect("~/Login.aspx", false);
                return;
            }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";

            InitLang();
            SetLabels();

            if (!IsPostBack)
            {
                LoadThread();
            }
        }

        // ── Language initialisation ───────────────────────────────────
        private void InitLang()
        {
            string lang = Session["preferredLanguage"] as string;
            if (!string.IsNullOrEmpty(lang))
            {
                CurrentLanguage = lang;
                return;
            }

            string userId = Session["userId"] as string;
            if (!string.IsNullOrEmpty(userId))
            {
                try
                {
                    const string sql = "SELECT preferredLanguage FROM [User] WHERE userId = @userId";
                    using (SqlConnection connection = new SqlConnection(ConnStr))
                    using (SqlCommand command = new SqlCommand(sql, connection))
                    {
                        command.Parameters.AddWithValue("@userId", userId);
                        connection.Open();
                        object result = command.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            lang = result.ToString();
                            Session["preferredLanguage"] = lang;
                            CurrentLanguage = lang;
                            return;
                        }
                    }
                }
                catch (SqlException ex)
                {
                    System.Diagnostics.Debug.WriteLine("Database error: " + ex.Message);
                }
            }

            CurrentLanguage = "EN";
            Session["preferredLanguage"] = "EN";
        }

        // ── Bilingual labels ──────────────────────────────────────────
        private void SetLabels()
        {
            litPageTitle.Text = T("Forum Thread", "Perbincangan Forum");
            litBack.Text = T("Back to Forum", "Kembali ke Forum");
            litErrorTitle.Text = T("Discussion not found", "Perbincangan tidak dijumpai");
            litErrorDesc.Text = T("This discussion does not exist or you don't have access.",
                                    "Perbincangan ini tidak wujud atau anda tiada akses.");
            litErrorBtn.Text = T("Back", "Kembali");
            litRestrictedTitle.Text = T("Private Discussion", "Perbincangan Peribadi");
            litRestrictedDesc.Text = T("This private discussion is not available for your account.",
                                        "Perbincangan peribadi ini tidak tersedia untuk akaun anda.");
            litRestrictedBtn.Text = T("Back to Forum", "Kembali ke Forum");
            litLikesLabel.Text = T("likes", "suka");
            litRepliesLabel.Text = T("replies", "balasan");
            litRepliesTitle.Text = T("Replies", "Balasan");
            litReplyFormTitle.Text = T("Post Reply", "Hantar Balasan");
            litReplySuccess.Text = T("Reply posted successfully!", "Balasan berjaya dihantar!");
            litReplyError.Text = T("Please write something before posting.",
                                    "Sila tulis sesuatu sebelum menghantar.");
            litOrigMsgLabel.Text = T("Original Message", "Mesej Asal");
            litNoReplies.Text = T("No replies yet. Be the first to respond!", "Belum ada balasan. Jadilah yang pertama!");
            litPrivateNotice.Text = T("This is a private Student-Parent discussion. Only you and your linked parent can view this.",
                                        "Ini adalah perbincangan peribadi Murid-Ibu Bapa. Hanya anda dan ibu bapa yang dipautkan boleh melihat ini.");

            txtReply.Attributes["placeholder"] = T("Write your reply...", "Tulis balasan anda...");
            btnReply.Text = T("Post Reply", "Hantar Balasan");
        }

        // ── Load Thread ───────────────────────────────────────────────
        private void LoadThread()
        {
            string forumId = Request.QueryString["forumId"];
            string userId = Session["userId"].ToString();

            if (string.IsNullOrEmpty(forumId))
            {
                ShowError();
                return;
            }

            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();

                if (!Tbl(connection, "Forum"))
                {
                    ShowError();
                    return;
                }

                // ── Load Forum record ──
                const string forumSql = @"
                    SELECT f.forumId, f.title, f.message, f.discussionType, f.createdBy, f.createdAt
                    FROM   Forum f
                    WHERE  f.forumId = @forumId";

                DataRow forumRow = null;
                using (SqlCommand command = new SqlCommand(forumSql, connection))
                {
                    command.Parameters.AddWithValue("@forumId", forumId);
                    SqlDataAdapter adapter = new SqlDataAdapter(command);
                    DataTable dataTable = new DataTable();
                    adapter.Fill(dataTable);
                    if (dataTable.Rows.Count == 0)
                    {
                        ShowError();
                        return;
                    }
                    forumRow = dataTable.Rows[0];
                }

                string title = "";
                if (forumRow["title"] != DBNull.Value)
                {
                    title = forumRow["title"].ToString();
                }

                string message = "";
                if (forumRow["message"] != DBNull.Value)
                {
                    message = forumRow["message"].ToString();
                }

                string discussionType = "Public";
                if (forumRow["discussionType"] != DBNull.Value)
                {
                    discussionType = forumRow["discussionType"].ToString();
                }

                string createdBy = "";
                if (forumRow["createdBy"] != DBNull.Value)
                {
                    createdBy = forumRow["createdBy"].ToString();
                }

                DateTime createdAt;
                if (forumRow["createdAt"] == DBNull.Value)
                {
                    createdAt = DateTime.Now;
                }
                else
                {
                    createdAt = Convert.ToDateTime(forumRow["createdAt"]);
                }

                // ── Private access check ──
                if (discussionType.Equals("Private", StringComparison.OrdinalIgnoreCase))
                {
                    bool hasAccess = CheckPrivateAccess(connection, userId, createdBy);

                    if (!hasAccess)
                    {
                        ShowRestricted();
                        return;
                    }
                }

                // ── Get creator display name ──
                string creatorName = GetDisplayName(connection, createdBy);

                // ── Load tags ──
                string tagsHtml = "";
                if (Tbl(connection, "ForumTag") && Tbl(connection, "Tag"))
                {
                    const string tagSql = @"
                        SELECT t.tagName
                        FROM   ForumTag ft
                        JOIN   Tag t ON t.tagId = ft.tagId
                        WHERE  ft.forumId = @forumId";
                    using (SqlCommand tagCmd = new SqlCommand(tagSql, connection))
                    {
                        tagCmd.Parameters.AddWithValue("@forumId", forumId);
                        using (SqlDataReader reader = tagCmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                tagsHtml += "<span class='ft-tag'>" +
                                    HttpUtility.HtmlEncode(reader["tagName"].ToString()) + "</span>";
                            }
                        }
                    }
                }

                // ── Count likes ──
                int likeCount = 0;
                bool isLiked = false;
                if (Tbl(connection, "ForumLike"))
                {
                    const string likeSql = "SELECT COUNT(*) FROM ForumLike WHERE forumId = @forumId";
                    using (SqlCommand likeCmd = new SqlCommand(likeSql, connection))
                    {
                        likeCmd.Parameters.AddWithValue("@forumId", forumId);
                        likeCount = (int)likeCmd.ExecuteScalar();
                    }

                    const string isLikedSql = @"
                        SELECT COUNT(*) FROM ForumLike
                        WHERE  forumId = @forumId AND senderUserId = @userId";
                    using (SqlCommand isLikedCmd = new SqlCommand(isLikedSql, connection))
                    {
                        isLikedCmd.Parameters.AddWithValue("@forumId", forumId);
                        isLikedCmd.Parameters.AddWithValue("@userId", userId);
                        isLiked = (int)isLikedCmd.ExecuteScalar() > 0;
                    }
                }

                // ── Count replies ──
                int replyCount = 0;
                if (Tbl(connection, "ForumChat"))
                {
                    const string replySql = "SELECT COUNT(*) FROM ForumChat WHERE forumId = @forumId";
                    using (SqlCommand replyCmd = new SqlCommand(replySql, connection))
                    {
                        replyCmd.Parameters.AddWithValue("@forumId", forumId);
                        replyCount = (int)replyCmd.ExecuteScalar();
                    }
                }

                // ── Set header display ──
                pnlMain.Visible = true;
                pnlError.Visible = false;
                pnlRestricted.Visible = false;

                litThreadTitle.Text = HttpUtility.HtmlEncode(title);
                litCreatorName.Text = HttpUtility.HtmlEncode(creatorName);
                litCreatorDate.Text = T("Posted on ", "Dihantar pada ") + createdAt.ToString("d MMM yyyy, h:mm tt");
                litTags.Text = tagsHtml;
                litLikeCount.Text = likeCount.ToString();
                litReplyCount.Text = replyCount.ToString();
                litOrigMessage.Text = HttpUtility.HtmlEncode(message);

                // Discussion type badge
                SetDiscussionBadge(discussionType);

                // Private notice
                if (discussionType.Equals("Private", StringComparison.OrdinalIgnoreCase))
                {
                    pnlPrivateNotice.Visible = true;
                    divHeader.Attributes["class"] = "st-forumthread-header private-thread";
                }
                else
                {
                    divHeader.Attributes["class"] = "st-forumthread-header public-thread";
                }

                // Like button state
                if (isLiked)
                {
                    btnLike.CssClass = "st-forumthread-like-btn liked";
                    litLikeText.Text = T("Liked", "Disukai");
                }
                else
                {
                    btnLike.CssClass = "st-forumthread-like-btn";
                    litLikeText.Text = T("Like", "Suka");
                }

                // ── Load replies ──
                LoadReplies(connection, forumId);
            }
        }

        // ── Private access logic ──────────────────────────────────────
        private bool CheckPrivateAccess(SqlConnection connection, string studentUserId, string createdBy)
        {
            // Case 1: Student is the creator
            if (createdBy == studentUserId)
            {
                return true;
            }

            // Case 2: Creator is linked parent
            if (Tbl(connection, "Student") && Tbl(connection, "StudentParent") && Tbl(connection, "Parent"))
            {
                const string sql = @"
                    SELECT COUNT(*)
                    FROM   Student s
                    JOIN   StudentParent sp ON sp.studentId = s.studentId
                    JOIN   Parent p ON p.parentId = sp.parentId
                    WHERE  s.userId = @studentUserId
                    AND    p.userId = @createdBy";

                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    command.Parameters.AddWithValue("@studentUserId", studentUserId);
                    command.Parameters.AddWithValue("@createdBy", createdBy);
                    return (int)command.ExecuteScalar() > 0;
                }
            }

            return false;
        }

        // ── Set discussion badge ──────────────────────────────────────
        private void SetDiscussionBadge(string discussionType)
        {
            string badgeClass = "st-forumthread-disc-badge ";
            string badgeText = "";

            switch ((discussionType ?? "").ToLower())
            {
                case "private":
                    badgeClass += "private";
                    badgeText = "<i class=\"bi bi-lock-fill\"></i> " + T("Private", "Peribadi");
                    break;
                case "question":
                    badgeClass += "question";
                    badgeText = "<i class=\"bi bi-question-circle-fill\"></i> " + T("Question", "Soalan");
                    break;
                case "sharing":
                    badgeClass += "sharing";
                    badgeText = "<i class=\"bi bi-share-fill\"></i> " + T("Sharing", "Perkongsian");
                    break;
                case "help":
                    badgeClass += "help";
                    badgeText = "<i class=\"bi bi-life-preserver\"></i> " + T("Help", "Bantuan");
                    break;
                default:
                    badgeClass += "public";
                    badgeText = "<i class=\"bi bi-globe\"></i> " + T("Public", "Awam");
                    break;
            }

            spnDiscBadge.Attributes["class"] = badgeClass;
            litDiscType.Text = badgeText;
        }

        // ── Load Replies ──────────────────────────────────────────────
        private void LoadReplies(SqlConnection connection, string forumId)
        {
            if (!Tbl(connection, "ForumChat"))
            {
                pnlNoReplies.Visible = true;
                return;
            }

            const string sql = @"
                SELECT fc.forumChatId, fc.senderUserId, fc.message, fc.createdAt
                FROM   ForumChat fc
                WHERE  fc.forumId = @forumId
                ORDER BY fc.createdAt ASC";

            List<object> replies = new List<object>();

            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@forumId", forumId);
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string senderUserId = reader["senderUserId"].ToString();

                        string msg = "";
                        if (reader["message"] != DBNull.Value)
                        {
                            msg = reader["message"].ToString();
                        }

                        DateTime date;
                        if (reader["createdAt"] == DBNull.Value)
                        {
                            date = DateTime.Now;
                        }
                        else
                        {
                            date = Convert.ToDateTime(reader["createdAt"]);
                        }

                        replies.Add(new
                        {
                            SenderUserId = senderUserId,
                            Message = msg,
                            CreatedAt = date
                        });
                    }
                }
            }

            if (replies.Count == 0)
            {
                pnlNoReplies.Visible = true;
                return;
            }

            // Build display list with names
            List<object> displayList = new List<object>();
            foreach (dynamic reply in replies)
            {
                string senderName = GetDisplayName(connection, reply.SenderUserId);
                string senderRole = GetUserRole(connection, reply.SenderUserId);

                string senderInitial;
                if (!string.IsNullOrWhiteSpace(senderName))
                {
                    senderInitial = senderName[0].ToString().ToUpper();
                }
                else
                {
                    senderInitial = "U";
                }

                string roleLabel = "";
                switch (senderRole)
                {
                    case "Student":
                        roleLabel = T("Student", "Pelajar");
                        break;
                    case "Teacher":
                        roleLabel = T("Teacher", "Guru");
                        break;
                    case "Parent":
                        roleLabel = T("Parent", "Ibu Bapa");
                        break;
                    default:
                        roleLabel = senderRole;
                        break;
                }

                displayList.Add(new
                {
                    SenderName = senderName,
                    SenderInitial = senderInitial,
                    SenderRole = senderRole,
                    SenderRoleLabel = roleLabel,
                    Message = reply.Message,
                    Date = FormatDate(reply.CreatedAt)
                });
            }

            rptReplies.DataSource = displayList;
            rptReplies.DataBind();
        }

        // ── Like / Unlike ─────────────────────────────────────────────
        protected void btnLike_Click(object sender, EventArgs e)
        {
            string forumId = Request.QueryString["forumId"];
            string userId = Session["userId"].ToString();

            if (string.IsNullOrEmpty(forumId))
            {
                return;
            }

            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();

                if (!Tbl(connection, "ForumLike"))
                {
                    return;
                }

                // Check if already liked
                const string checkSql = @"
                    SELECT COUNT(*) FROM ForumLike
                    WHERE  forumId = @forumId AND senderUserId = @userId";
                bool exists;
                using (SqlCommand checkCmd = new SqlCommand(checkSql, connection))
                {
                    checkCmd.Parameters.AddWithValue("@forumId", forumId);
                    checkCmd.Parameters.AddWithValue("@userId", userId);
                    exists = (int)checkCmd.ExecuteScalar() > 0;
                }

                if (exists)
                {
                    // Unlike
                    const string delSql = @"
                        DELETE FROM ForumLike
                        WHERE  forumId = @forumId AND senderUserId = @userId";
                    using (SqlCommand delCmd = new SqlCommand(delSql, connection))
                    {
                        delCmd.Parameters.AddWithValue("@forumId", forumId);
                        delCmd.Parameters.AddWithValue("@userId", userId);
                        delCmd.ExecuteNonQuery();
                    }
                }
                else
                {
                    // Like — generate sequential ID
                    string likeId = "FL001";
                    const string seqSql = @"
                        SELECT ISNULL(MAX(CAST(SUBSTRING(likeId, 3, LEN(likeId) - 2) AS INT)), 0)
                        FROM ForumLike WHERE likeId LIKE 'FL[0-9]%'";
                    using (SqlCommand seqCmd = new SqlCommand(seqSql, connection))
                    {
                        object lastVal = seqCmd.ExecuteScalar();
                        if (lastVal != null && lastVal != DBNull.Value)
                        {
                            int lastNum = Convert.ToInt32(lastVal);
                            likeId = "FL" + (lastNum + 1).ToString("D3");
                        }
                    }

                    const string insSql = @"
                        INSERT INTO ForumLike (likeId, forumId, senderUserId, createdAt)
                        VALUES (@likeId, @forumId, @userId, @now)";
                    using (SqlCommand insCmd = new SqlCommand(insSql, connection))
                    {
                        insCmd.Parameters.AddWithValue("@likeId", likeId);
                        insCmd.Parameters.AddWithValue("@forumId", forumId);
                        insCmd.Parameters.AddWithValue("@userId", userId);
                        insCmd.Parameters.AddWithValue("@now", DateTime.Now);
                        insCmd.ExecuteNonQuery();
                    }
                }
            }

            // Reload thread
            LoadThread();
        }

        // ── Post Reply ────────────────────────────────────────────────
        protected void btnReply_Click(object sender, EventArgs e)
        {
            string forumId = Request.QueryString["forumId"];
            string userId = Session["userId"].ToString();
            string replyMsg = txtReply.Text.Trim();

            pnlReplySuccess.Visible = false;
            pnlReplyError.Visible = false;

            if (string.IsNullOrEmpty(forumId))
            {
                return;
            }

            if (string.IsNullOrEmpty(replyMsg))
            {
                pnlReplyError.Visible = true;
                return;
            }

            // Re-check access for Private threads before allowing reply
            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();

                if (!Tbl(connection, "Forum") || !Tbl(connection, "ForumChat"))
                {
                    return;
                }

                // Verify private access
                const string typeSql = "SELECT discussionType, createdBy FROM Forum WHERE forumId = @forumId";
                string discType = "Public";
                string createdBy = "";
                using (SqlCommand typeCmd = new SqlCommand(typeSql, connection))
                {
                    typeCmd.Parameters.AddWithValue("@forumId", forumId);
                    using (SqlDataReader reader = typeCmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            if (reader["discussionType"] != DBNull.Value)
                            {
                                discType = reader["discussionType"].ToString();
                            }
                            else
                            {
                                discType = "Public";
                            }

                            if (reader["createdBy"] != DBNull.Value)
                            {
                                createdBy = reader["createdBy"].ToString();
                            }
                            else
                            {
                                createdBy = "";
                            }
                        }
                    }
                }

                if (discType.Equals("Private", StringComparison.OrdinalIgnoreCase))
                {
                    if (!CheckPrivateAccess(connection, userId, createdBy))
                    {
                        pnlReplyError.Visible = true;
                        litReplyError.Text = T("You do not have access to reply to this private discussion.",
                                               "Anda tidak mempunyai akses untuk membalas perbincangan peribadi ini.");
                        return;
                    }
                }

                // Generate sequential forumChatId
                string forumChatId = "FC001";
                const string seqSql = @"
                    SELECT ISNULL(MAX(CAST(SUBSTRING(forumChatId, 3, LEN(forumChatId) - 2) AS INT)), 0)
                    FROM ForumChat WHERE forumChatId LIKE 'FC[0-9]%'";
                using (SqlCommand seqCmd = new SqlCommand(seqSql, connection))
                {
                    object lastVal = seqCmd.ExecuteScalar();
                    if (lastVal != null && lastVal != DBNull.Value)
                    {
                        int lastNum = Convert.ToInt32(lastVal);
                        forumChatId = "FC" + (lastNum + 1).ToString("D3");
                    }
                }

                const string insertSql = @"
                    INSERT INTO ForumChat (forumChatId, forumId, senderUserId, message, createdAt)
                    VALUES (@forumChatId, @forumId, @userId, @message, @now)";

                using (SqlCommand command = new SqlCommand(insertSql, connection))
                {
                    command.Parameters.AddWithValue("@forumChatId", forumChatId);
                    command.Parameters.AddWithValue("@forumId", forumId);
                    command.Parameters.AddWithValue("@userId", userId);
                    command.Parameters.AddWithValue("@message", replyMsg);
                    command.Parameters.AddWithValue("@now", DateTime.Now);
                    command.ExecuteNonQuery();
                }
            }

            // Clear and show success
            txtReply.Text = "";
            pnlReplySuccess.Visible = true;

            // Reload thread
            LoadThread();
        }

        // ── Helpers ───────────────────────────────────────────────────

        private void ShowError()
        {
            pnlError.Visible = true;
            pnlMain.Visible = false;
            pnlRestricted.Visible = false;
        }

        private void ShowRestricted()
        {
            pnlRestricted.Visible = true;
            pnlMain.Visible = false;
            pnlError.Visible = false;
        }

        /// <summary>
        /// Gets display name for a user: Student nickname/name > Teacher name > Parent name > username
        /// </summary>
        private string GetDisplayName(SqlConnection connection, string userId)
        {
            if (Tbl(connection, "Student"))
            {
                const string sql = "SELECT nickname, name FROM Student WHERE userId = @userId";
                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    command.Parameters.AddWithValue("@userId", userId);
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string nickname = "";
                            if (reader["nickname"] != DBNull.Value)
                            {
                                nickname = reader["nickname"].ToString().Trim();
                            }

                            string name = "";
                            if (reader["name"] != DBNull.Value)
                            {
                                name = reader["name"].ToString().Trim();
                            }

                            if (!string.IsNullOrEmpty(nickname))
                            {
                                return nickname;
                            }
                            if (!string.IsNullOrEmpty(name))
                            {
                                return name;
                            }
                        }
                    }
                }
            }

            if (Tbl(connection, "Teacher"))
            {
                const string sql = "SELECT name FROM Teacher WHERE userId = @userId";
                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    command.Parameters.AddWithValue("@userId", userId);
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string name = "";
                            if (reader["name"] != DBNull.Value)
                            {
                                name = reader["name"].ToString().Trim();
                            }
                            if (!string.IsNullOrEmpty(name))
                            {
                                return name;
                            }
                        }
                    }
                }
            }

            if (Tbl(connection, "Parent"))
            {
                const string sql = "SELECT name FROM Parent WHERE userId = @userId";
                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    command.Parameters.AddWithValue("@userId", userId);
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string name = "";
                            if (reader["name"] != DBNull.Value)
                            {
                                name = reader["name"].ToString().Trim();
                            }
                            if (!string.IsNullOrEmpty(name))
                            {
                                return name;
                            }
                        }
                    }
                }
            }

            const string userSql = "SELECT username FROM [User] WHERE userId = @userId";
            using (SqlCommand command = new SqlCommand(userSql, connection))
            {
                command.Parameters.AddWithValue("@userId", userId);
                object result = command.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                {
                    return result.ToString();
                }
                return "Unknown";
            }
        }

        private string GetUserRole(SqlConnection connection, string userId)
        {
            const string sql = "SELECT role FROM [User] WHERE userId = @userId";
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@userId", userId);
                object result = command.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                {
                    return result.ToString();
                }
                return "Student";
            }
        }

        private static string FormatDate(DateTime dt)
        {
            TimeSpan span = DateTime.Now - dt;
            if (span.TotalMinutes < 1)
            {
                return "Just now";
            }
            if (span.TotalHours < 1)
            {
                return (int)span.TotalMinutes + " min ago";
            }
            if (span.TotalDays < 1)
            {
                return (int)span.TotalHours + " hr ago";
            }
            if (span.TotalDays < 7)
            {
                return (int)span.TotalDays + " day" + ((int)span.TotalDays == 1 ? "" : "s") + " ago";
            }
            return dt.ToString("d MMM yyyy");
        }

        private static bool Tbl(SqlConnection connection, string tableName)
        {
            const string sql = @"
                SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
                WHERE  TABLE_NAME = @tableName
                AND    TABLE_TYPE = 'BASE TABLE'";
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@tableName", tableName);
                return (int)command.ExecuteScalar() > 0;
            }
        }
    }
}
