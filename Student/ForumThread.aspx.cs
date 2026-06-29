using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Student
{
    public partial class ForumThread : Page
    {
        // ── Connection string ─────────────────────────────────────────
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ScienceBuddyDB"].ConnectionString;

        // ── Language helper ────────────────────────────────────────────
        public string CurrentLanguage = "EN";

        public string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
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
                    using (var conn = new SqlConnection(ConnStr))
                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@userId", userId);
                        conn.Open();
                        object result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            lang = result.ToString();
                            Session["preferredLanguage"] = lang;
                            CurrentLanguage = lang;
                            return;
                        }
                    }
                }
                catch (SqlException) { }
            }

            CurrentLanguage = "EN";
            Session["preferredLanguage"] = "EN";
        }

        // ── Bilingual labels ──────────────────────────────────────────
        private void SetLabels()
        {
            litPageTitle.Text       = T("Forum Thread", "Perbincangan Forum");
            litBack.Text            = T("Back to Forum", "Kembali ke Forum");
            litErrorTitle.Text      = T("Discussion not found", "Perbincangan tidak dijumpai");
            litErrorDesc.Text       = T("This discussion does not exist or you don't have access.",
                                        "Perbincangan ini tidak wujud atau anda tiada akses.");
            litErrorBtn.Text        = T("Back", "Kembali");
            litLikesLabel.Text      = T("likes", "suka");
            litRepliesLabel.Text    = T("replies", "balasan");
            litRepliesTitle.Text    = T("Replies", "Balasan");
            litReplyFormTitle.Text  = T("Post Reply", "Hantar Balasan");
            litReplySuccess.Text    = T("Reply posted successfully!", "Balasan berjaya dihantar!");
            litReplyError.Text      = T("Please write something before posting.",
                                        "Sila tulis sesuatu sebelum menghantar.");

            // Reply textarea placeholder
            txtReply.Attributes["placeholder"] = T("Write your reply...", "Tulis balasan anda...");

            // Button text
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

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                if (!Tbl(conn, "Forum"))
                {
                    ShowError();
                    return;
                }

                // ── Load Forum record ──
                string forumSql = @"
                    SELECT f.forumId, f.title, f.message, f.discussionType, f.createdBy, f.createdAt
                    FROM   Forum f
                    WHERE  f.forumId = @forumId";

                DataRow forumRow = null;
                using (var cmd = new SqlCommand(forumSql, conn))
                {
                    cmd.Parameters.AddWithValue("@forumId", forumId);
                    var da = new SqlDataAdapter(cmd);
                    var dt = new DataTable();
                    da.Fill(dt);
                    if (dt.Rows.Count == 0)
                    {
                        ShowError();
                        return;
                    }
                    forumRow = dt.Rows[0];
                }

                string title = forumRow["title"].ToString();
                string message = forumRow["message"].ToString();
                string discussionType = forumRow["discussionType"].ToString();
                string createdBy = forumRow["createdBy"].ToString();
                DateTime createdAt = forumRow["createdAt"] == DBNull.Value
                    ? DateTime.Now : Convert.ToDateTime(forumRow["createdAt"]);

                // ── Private access check ──
                if (discussionType.Equals("Private", StringComparison.OrdinalIgnoreCase))
                {
                    bool hasAccess = false;

                    // Check if creator
                    if (createdBy == userId)
                    {
                        hasAccess = true;
                    }
                    else if (Tbl(conn, "ForumChat"))
                    {
                        // Check if user has participated
                        const string accessSql = @"
                            SELECT COUNT(*) FROM ForumChat
                            WHERE  forumId = @forumId AND senderUserId = @userId";
                        using (var accessCmd = new SqlCommand(accessSql, conn))
                        {
                            accessCmd.Parameters.AddWithValue("@forumId", forumId);
                            accessCmd.Parameters.AddWithValue("@userId", userId);
                            hasAccess = (int)accessCmd.ExecuteScalar() > 0;
                        }
                    }

                    if (!hasAccess)
                    {
                        ShowError();
                        return;
                    }
                }

                // ── Get creator display name ──
                string creatorName = GetDisplayName(conn, createdBy);

                // ── Load tags ──
                string tagsHtml = "";
                if (Tbl(conn, "ForumTag") && Tbl(conn, "Tag"))
                {
                    const string tagSql = @"
                        SELECT t.tagName
                        FROM   ForumTag ft
                        JOIN   Tag t ON t.tagId = ft.tagId
                        WHERE  ft.forumId = @forumId";
                    using (var tagCmd = new SqlCommand(tagSql, conn))
                    {
                        tagCmd.Parameters.AddWithValue("@forumId", forumId);
                        using (var rdr = tagCmd.ExecuteReader())
                        {
                            while (rdr.Read())
                            {
                                tagsHtml += "<span class='ft-tag'>" +
                                    Server.HtmlEncode(rdr["tagName"].ToString()) + "</span>";
                            }
                        }
                    }
                }

                // ── Count likes ──
                int likeCount = 0;
                bool isLiked = false;
                if (Tbl(conn, "ForumLike"))
                {
                    const string likeSql = "SELECT COUNT(*) FROM ForumLike WHERE forumId = @forumId";
                    using (var likeCmd = new SqlCommand(likeSql, conn))
                    {
                        likeCmd.Parameters.AddWithValue("@forumId", forumId);
                        likeCount = (int)likeCmd.ExecuteScalar();
                    }

                    const string isLikedSql = @"
                        SELECT COUNT(*) FROM ForumLike
                        WHERE  forumId = @forumId AND senderUserId = @userId";
                    using (var isLikedCmd = new SqlCommand(isLikedSql, conn))
                    {
                        isLikedCmd.Parameters.AddWithValue("@forumId", forumId);
                        isLikedCmd.Parameters.AddWithValue("@userId", userId);
                        isLiked = (int)isLikedCmd.ExecuteScalar() > 0;
                    }
                }

                // ── Count replies ──
                int replyCount = 0;
                if (Tbl(conn, "ForumChat"))
                {
                    const string replySql = "SELECT COUNT(*) FROM ForumChat WHERE forumId = @forumId";
                    using (var replyCmd = new SqlCommand(replySql, conn))
                    {
                        replyCmd.Parameters.AddWithValue("@forumId", forumId);
                        replyCount = (int)replyCmd.ExecuteScalar();
                    }
                }

                // ── Set header display ──
                pnlMain.Visible = true;
                pnlError.Visible = false;

                litThreadTitle.Text = Server.HtmlEncode(title);
                litDiscType.Text = discussionType == "Public"
                    ? T("Public", "Awam") : T("Private", "Peribadi");
                litCreatorName.Text = Server.HtmlEncode(creatorName);
                litCreatorDate.Text = T("Posted on", "Dihantar pada") + " " + createdAt.ToString("d MMM yyyy, h:mm tt");
                litTags.Text = tagsHtml;
                litLikeCount.Text = likeCount.ToString();
                litReplyCount.Text = replyCount.ToString();
                litOrigMessage.Text = Server.HtmlEncode(message);

                // Like button state
                if (isLiked)
                {
                    btnLike.CssClass = "ft-like-btn liked";
                    litLikeText.Text = T("Liked", "Disukai");
                }
                else
                {
                    btnLike.CssClass = "ft-like-btn";
                    litLikeText.Text = T("Like", "Suka");
                }

                // Discussion type badge class
                // Update badge CSS class based on type
                // (handled in markup with public class, we update if private)

                // ── Load replies ──
                LoadReplies(conn, forumId);
            }
        }

        // ── Load Replies ──────────────────────────────────────────────
        private void LoadReplies(SqlConnection conn, string forumId)
        {
            if (!Tbl(conn, "ForumChat"))
            {
                rptReplies.DataSource = null;
                rptReplies.DataBind();
                return;
            }

            const string sql = @"
                SELECT fc.forumChatId, fc.senderUserId, fc.message, fc.createdAt
                FROM   ForumChat fc
                WHERE  fc.forumId = @forumId
                ORDER BY fc.createdAt ASC";

            var replies = new List<object>();

            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@forumId", forumId);
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        string senderUserId = rdr["senderUserId"].ToString();
                        string msg = rdr["message"].ToString();
                        DateTime date = rdr["createdAt"] == DBNull.Value
                            ? DateTime.Now : Convert.ToDateTime(rdr["createdAt"]);

                        replies.Add(new
                        {
                            SenderUserId = senderUserId,
                            Message = msg,
                            CreatedAt = date
                        });
                    }
                }
            }

            // Build display list with names
            var displayList = new List<object>();
            foreach (dynamic reply in replies)
            {
                string senderName = GetDisplayName(conn, reply.SenderUserId);
                string senderRole = GetUserRole(conn, reply.SenderUserId);
                string senderInitial = !string.IsNullOrWhiteSpace(senderName)
                    ? senderName[0].ToString().ToUpper() : "?";

                string roleLabel = "";
                switch (senderRole)
                {
                    case "Student": roleLabel = T("Student", "Pelajar"); break;
                    case "Teacher": roleLabel = T("Teacher", "Guru"); break;
                    case "Parent": roleLabel = T("Parent", "Ibu Bapa"); break;
                    default: roleLabel = senderRole; break;
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

            if (string.IsNullOrEmpty(forumId)) return;

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                if (!Tbl(conn, "ForumLike")) return;

                // Check if already liked
                const string checkSql = @"
                    SELECT COUNT(*) FROM ForumLike
                    WHERE  forumId = @forumId AND senderUserId = @userId";
                bool exists;
                using (var checkCmd = new SqlCommand(checkSql, conn))
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
                    using (var delCmd = new SqlCommand(delSql, conn))
                    {
                        delCmd.Parameters.AddWithValue("@forumId", forumId);
                        delCmd.Parameters.AddWithValue("@userId", userId);
                        delCmd.ExecuteNonQuery();
                    }
                }
                else
                {
                    // Like
                    string likeId = "LK" + DateTime.Now.ToString("yyyyMMddHHmmss");
                    const string insSql = @"
                        INSERT INTO ForumLike (likeId, forumId, senderUserId, createdAt)
                        VALUES (@likeId, @forumId, @userId, @now)";
                    using (var insCmd = new SqlCommand(insSql, conn))
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

            if (string.IsNullOrEmpty(forumId)) return;

            if (string.IsNullOrEmpty(replyMsg))
            {
                pnlReplyError.Visible = true;
                litReplyError.Text = T("Please write something before posting.",
                                       "Sila tulis sesuatu sebelum menghantar.");
                return;
            }

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                if (!Tbl(conn, "ForumChat")) return;

                string forumChatId = "FC" + DateTime.Now.ToString("yyyyMMddHHmmss");

                const string sql = @"
                    INSERT INTO ForumChat (forumChatId, forumId, senderUserId, message, createdAt)
                    VALUES (@forumChatId, @forumId, @userId, @message, @now)";

                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@forumChatId", forumChatId);
                    cmd.Parameters.AddWithValue("@forumId", forumId);
                    cmd.Parameters.AddWithValue("@userId", userId);
                    cmd.Parameters.AddWithValue("@message", replyMsg);
                    cmd.Parameters.AddWithValue("@now", DateTime.Now);
                    cmd.ExecuteNonQuery();
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
        }

        /// <summary>
        /// Gets display name for a user: Student nickname/name > Teacher name > Parent name > username
        /// </summary>
        private string GetDisplayName(SqlConnection conn, string userId)
        {
            // Try Student (nickname > name)
            if (Tbl(conn, "Student"))
            {
                const string sql = @"
                    SELECT s.nickname, s.name
                    FROM   Student s
                    WHERE  s.userId = @userId";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    using (var rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            string nickname = rdr["nickname"] == DBNull.Value ? "" : rdr["nickname"].ToString().Trim();
                            string name = rdr["name"] == DBNull.Value ? "" : rdr["name"].ToString().Trim();
                            if (!string.IsNullOrEmpty(nickname)) return nickname;
                            if (!string.IsNullOrEmpty(name)) return name;
                        }
                    }
                }
            }

            // Try Teacher
            if (Tbl(conn, "Teacher"))
            {
                const string sql = @"
                    SELECT t.name
                    FROM   Teacher t
                    WHERE  t.userId = @userId";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    using (var rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            string name = rdr["name"] == DBNull.Value ? "" : rdr["name"].ToString().Trim();
                            if (!string.IsNullOrEmpty(name)) return name;
                        }
                    }
                }
            }

            // Try Parent
            if (Tbl(conn, "Parent"))
            {
                const string sql = @"
                    SELECT p.name
                    FROM   Parent p
                    WHERE  p.userId = @userId";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    using (var rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            string name = rdr["name"] == DBNull.Value ? "" : rdr["name"].ToString().Trim();
                            if (!string.IsNullOrEmpty(name)) return name;
                        }
                    }
                }
            }

            // Fallback to username
            const string userSql = "SELECT username FROM [User] WHERE userId = @userId";
            using (var cmd = new SqlCommand(userSql, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                object result = cmd.ExecuteScalar();
                return result != null && result != DBNull.Value ? result.ToString() : "Unknown";
            }
        }

        /// <summary>
        /// Gets user role from the User table.
        /// </summary>
        private string GetUserRole(SqlConnection conn, string userId)
        {
            const string sql = "SELECT role FROM [User] WHERE userId = @userId";
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                object result = cmd.ExecuteScalar();
                return result != null && result != DBNull.Value ? result.ToString() : "Student";
            }
        }

        private static string FormatDate(DateTime dt)
        {
            var span = DateTime.Now - dt;
            if (span.TotalMinutes < 1) return "Just now";
            if (span.TotalHours < 1) return (int)span.TotalMinutes + " min ago";
            if (span.TotalDays < 1) return (int)span.TotalHours + " hr ago";
            if (span.TotalDays < 7) return (int)span.TotalDays + " day" + ((int)span.TotalDays == 1 ? "" : "s") + " ago";
            return dt.ToString("d MMM yyyy");
        }

        /// <summary>
        /// Returns true if the given table exists in the current database.
        /// Uses INFORMATION_SCHEMA so it never throws on a missing table.
        /// </summary>
        private static bool Tbl(SqlConnection conn, string tableName)
        {
            const string sql = @"
                SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
                WHERE  TABLE_NAME = @tableName
                AND    TABLE_TYPE = 'BASE TABLE'";
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@tableName", tableName);
                return (int)cmd.ExecuteScalar() > 0;
            }
        }
    }
}
