using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Student
{
    public partial class ForumPage : Page
    {
        // ── Connection string ─────────────────────────────────────────
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

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

            if (!IsPostBack)
            {
                InitLang();
                SetLabels();
                BuildFilters();
                LoadDiscussions();
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
            litPageTitle.Text       = T("Forum", "Forum");
            litTitle.Text           = T("Forum", "Forum");
            litSubtitle.Text        = T("Ask questions, share ideas, and learn Science together.",
                                        "Tanya soalan, kongsi idea, dan belajar Sains bersama-sama.");
            litTotalDiscLbl.Text    = T("Total Discussions", "Jumlah Perbincangan");
            litMyDiscLbl.Text       = T("My Discussions", "Perbincangan Saya");
            litTotalRepliesLbl.Text = T("Total Replies", "Jumlah Balasan");
            litCTAText.Text         = T("Have a Science question?", "Ada soalan Sains?");
            litCTABtn.Text          = T("Create Discussion", "Cipta Perbincangan");
            litEmptyTitle.Text      = T("No discussions yet.", "Tiada perbincangan lagi.");
            litEmptyDesc.Text       = T("Be the first to ask a Science question!",
                                        "Jadilah yang pertama bertanya soalan Sains!");

            // Sort dropdown bilingual
            ddlSort.Items.Clear();
            ddlSort.Items.Add(new ListItem(T("Latest", "Terkini"), "Latest"));
            ddlSort.Items.Add(new ListItem(T("Most Liked", "Paling Disukai"), "MostLiked"));
            ddlSort.Items.Add(new ListItem(T("Most Replies", "Paling Banyak Balasan"), "MostReplies"));

            // Search placeholder
            txtSearch.Attributes["placeholder"] = T("Search", "Cari");
            btnFilter.Text = T("Filter", "Tapis");
        }

        // ── Build filter dropdowns ────────────────────────────────────
        private void BuildFilters()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Tags
                ddlTag.Items.Clear();
                ddlTag.Items.Add(new ListItem(T("All Tags", "Semua Tag"), ""));

                if (Tbl(conn, "Tag"))
                {
                    const string sql = "SELECT tagId, tagName FROM Tag ORDER BY tagName";
                    using (var cmd = new SqlCommand(sql, conn))
                    using (var rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            ddlTag.Items.Add(new ListItem(rdr["tagName"].ToString(), rdr["tagId"].ToString()));
                        }
                    }
                }
            }
        }

        // ── Load discussions ──────────────────────────────────────────
        private void LoadDiscussions()
        {
            string userId = Session["userId"].ToString();
            string tagFilter = ddlTag.SelectedValue;
            string sortVal = ddlSort.SelectedValue;
            string search = txtSearch.Text.Trim();

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                if (!Tbl(conn, "Forum"))
                {
                    ShowEmpty();
                    return;
                }

                // Build SQL
                string sql = @"
                    SELECT f.forumId, f.title, f.message, f.discussionType, f.createdAt, f.createdBy,
                           COALESCE(s.nickname, s.name, u.username) AS creatorName,
                           (SELECT COUNT(*) FROM ForumChat fc WHERE fc.forumId = f.forumId) AS replyCount,
                           (SELECT COUNT(*) FROM ForumLike fl WHERE fl.forumId = f.forumId) AS likeCount,
                           (SELECT COUNT(*) FROM ForumLike fl2 WHERE fl2.forumId = f.forumId AND fl2.senderUserId = @userId) AS isLiked
                    FROM   Forum f
                    JOIN   [User] u ON u.userId = f.createdBy
                    LEFT JOIN Student s ON s.userId = f.createdBy
                    {0}
                    WHERE  f.discussionType = 'Public'
                    {1}
                    {2}
                    {3}";

                string joinTag = "";
                string whereTag = "";
                string whereSearch = "";
                string orderBy = "ORDER BY f.createdAt DESC";

                // Tag filter
                if (!string.IsNullOrEmpty(tagFilter) && Tbl(conn, "ForumTag"))
                {
                    joinTag = "JOIN ForumTag ft ON ft.forumId = f.forumId";
                    whereTag = "AND ft.tagId = @tagId";
                }

                // Search filter
                if (!string.IsNullOrEmpty(search))
                {
                    whereSearch = "AND f.title LIKE '%' + @search + '%'";
                }

                // Sort
                switch (sortVal)
                {
                    case "MostLiked":
                        orderBy = "ORDER BY likeCount DESC, f.createdAt DESC";
                        break;
                    case "MostReplies":
                        orderBy = "ORDER BY replyCount DESC, f.createdAt DESC";
                        break;
                    default:
                        orderBy = "ORDER BY f.createdAt DESC";
                        break;
                }

                sql = string.Format(sql, joinTag, whereTag, whereSearch, orderBy);

                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    if (!string.IsNullOrEmpty(tagFilter))
                        cmd.Parameters.AddWithValue("@tagId", tagFilter);
                    if (!string.IsNullOrEmpty(search))
                        cmd.Parameters.AddWithValue("@search", search);

                    var da = new SqlDataAdapter(cmd);
                    var dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count == 0)
                    {
                        ShowEmpty();
                        return;
                    }

                    // Get tags for each forum
                    var forumTags = new Dictionary<string, string>();
                    if (Tbl(conn, "ForumTag") && Tbl(conn, "Tag"))
                    {
                        const string tagSql = @"
                            SELECT ft.forumId, t.tagName
                            FROM ForumTag ft
                            JOIN Tag t ON t.tagId = ft.tagId";
                        using (var tagCmd = new SqlCommand(tagSql, conn))
                        using (var tagRdr = tagCmd.ExecuteReader())
                        {
                            while (tagRdr.Read())
                            {
                                string fId = tagRdr["forumId"].ToString();
                                string tName = tagRdr["tagName"].ToString();
                                if (forumTags.ContainsKey(fId))
                                    forumTags[fId] += ", " + tName;
                                else
                                    forumTags[fId] = tName;
                            }
                        }
                    }

                    // Build display list
                    var list = new List<object>();
                    int myCount = 0;
                    int totalReplies = 0;

                    foreach (DataRow row in dt.Rows)
                    {
                        string forumId = row["forumId"].ToString();
                        string title = row["title"].ToString();
                        string message = row["message"].ToString();
                        string creatorName = row["creatorName"].ToString();
                        DateTime createdAt = row["createdAt"] == DBNull.Value
                            ? DateTime.Now : Convert.ToDateTime(row["createdAt"]);
                        int replyCount = Convert.ToInt32(row["replyCount"]);
                        int likeCount = Convert.ToInt32(row["likeCount"]);
                        bool isLiked = Convert.ToInt32(row["isLiked"]) > 0;
                        string discType = row["discussionType"].ToString();
                        string createdBy = row["createdBy"].ToString();

                        // Count my discussions
                        if (createdBy == userId) myCount++;
                        totalReplies += replyCount;

                        // Message preview (first 120 chars)
                        string preview = message.Length > 120 ? message.Substring(0, 120) + "…" : message;

                        // Creator initial
                        string initial = !string.IsNullOrWhiteSpace(creatorName)
                            ? creatorName[0].ToString().ToUpper() : "?";

                        // Tags
                        string tags = forumTags.ContainsKey(forumId) ? forumTags[forumId] : "";

                        // Discussion type label
                        string typeLabel = discType == "Public" ? T("Public", "Awam") : discType;

                        list.Add(new
                        {
                            ForumId = forumId,
                            Title = title,
                            MessagePreview = preview,
                            CreatorName = creatorName,
                            CreatorInitial = initial,
                            Date = FormatDate(createdAt),
                            DiscussionType = typeLabel,
                            ReplyCount = replyCount,
                            LikeCount = likeCount,
                            IsLiked = isLiked,
                            Tags = tags
                        });
                    }

                    // Bind
                    pnlList.Visible = true;
                    pnlEmpty.Visible = false;
                    rptDiscussions.DataSource = list;
                    rptDiscussions.DataBind();

                    // Stats
                    litTotalDisc.Text = dt.Rows.Count.ToString();
                    litMyDisc.Text = myCount.ToString();
                    litTotalReplies.Text = totalReplies.ToString();
                }
            }
        }

        // ── Filter button click ───────────────────────────────────────
        protected void btnFilter_Click(object sender, EventArgs e)
        {
            LoadDiscussions();
        }

        // ── Like / Unlike ─────────────────────────────────────────────
        protected void rptDiscussions_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "Like") return;

            string forumId = e.CommandArgument.ToString();
            string userId = Session["userId"].ToString();

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Check if already liked
                const string checkSql = @"
                    SELECT COUNT(*) FROM ForumLike
                    WHERE forumId = @forumId AND senderUserId = @userId";
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
                        WHERE forumId = @forumId AND senderUserId = @userId";
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

            // Reload
            LoadDiscussions();
        }

        // ── Helpers ───────────────────────────────────────────────────

        private void ShowEmpty()
        {
            pnlList.Visible = false;
            pnlEmpty.Visible = true;
            litTotalDisc.Text = "0";
            litMyDisc.Text = "0";
            litTotalReplies.Text = "0";
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
