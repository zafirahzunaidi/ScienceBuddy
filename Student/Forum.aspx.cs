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
            bool isPrivate = hfCategory.Value == "private";

            litPageTitle.Text       = T("Forum", "Forum");
            litTitle.Text           = T("Forum", "Forum");
            litSubtitle.Text        = T("Ask questions, share ideas, and learn Science together.",
                                        "Tanya soalan, kongsi idea, dan belajar Sains bersama-sama.");

            // Tab labels
            litTabPublic.Text       = T("Public", "Awam");
            litTabPrivate.Text      = T("Student-Parent", "Murid-Ibu Bapa");

            // Summary card labels based on selected tab
            if (isPrivate)
            {
                litTotalDiscLbl.Text    = T("Private Discussions", "Perbincangan Peribadi");
                litMyDiscLbl.Text       = T("My Discussions", "Perbincangan Saya");
                litTotalRepliesLbl.Text = T("Total Replies", "Jumlah Balasan");
            }
            else
            {
                litTotalDiscLbl.Text    = T("Public Discussions", "Perbincangan Awam");
                litMyDiscLbl.Text       = T("My Discussions", "Perbincangan Saya");
                litTotalRepliesLbl.Text = T("Total Replies", "Jumlah Balasan");
            }

            litCTAText.Text         = T("Have a Science question?", "Ada soalan Sains?");
            litCTABtn.Text          = T("Create Discussion", "Cipta Perbincangan");

            // Empty state labels based on selected tab
            if (isPrivate)
            {
                litEmptyTitle.Text  = T("No private parent-student discussions yet.",
                                        "Tiada perbincangan peribadi murid-ibu bapa lagi.");
                litEmptyDesc.Text   = T("No parent-linked discussions are available yet.",
                                        "Tiada perbincangan berkaitan ibu bapa tersedia buat masa ini.");
            }
            else
            {
                litEmptyTitle.Text  = T("No public discussions yet.",
                                        "Tiada perbincangan awam lagi.");
                litEmptyDesc.Text   = T("Be the first to ask a Science question!",
                                        "Jadilah yang pertama bertanya soalan Sains!");
            }

            // Sort dropdown bilingual
            ddlSort.Items.Clear();
            ddlSort.Items.Add(new ListItem(T("Latest", "Terkini"), "Latest"));
            ddlSort.Items.Add(new ListItem(T("Most Liked", "Paling Disukai"), "MostLiked"));
            ddlSort.Items.Add(new ListItem(T("Most Replies", "Paling Banyak Balasan"), "MostReplies"));

            // Search placeholder
            txtSearch.Attributes["placeholder"] = T("Search", "Cari");
            btnFilter.Text = T("Filter", "Tapis");

            // Highlight active tab CSS
            if (isPrivate)
            {
                btnTabPublic.CssClass  = "fm-cat-tab";
                btnTabPrivate.CssClass = "fm-cat-tab active";
            }
            else
            {
                btnTabPublic.CssClass  = "fm-cat-tab active";
                btnTabPrivate.CssClass = "fm-cat-tab";
            }
        }

        // ── Tab click handlers ────────────────────────────────────────
        protected void btnTabPublic_Click(object sender, EventArgs e)
        {
            hfCategory.Value = "public";
            SetLabels();
            LoadDiscussions();
        }

        protected void btnTabPrivate_Click(object sender, EventArgs e)
        {
            hfCategory.Value = "private";
            SetLabels();
            LoadDiscussions();
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
            bool isPrivate = hfCategory.Value == "private";

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                if (!Tbl(conn, "Forum"))
                {
                    ShowEmpty();
                    return;
                }

                // ── Build WHERE clause based on category tab ──
                string categoryWhere;
                var extraParams = new List<SqlParameter>();

                if (isPrivate)
                {
                    // Get linked parent userIds
                    var allowedUserIds = new List<string> { userId };
                    allowedUserIds.AddRange(GetLinkedParentUserIds(conn, userId));

                    // Build IN clause with parameters
                    var inParams = new List<string>();
                    for (int i = 0; i < allowedUserIds.Count; i++)
                    {
                        string pName = "@allowedUid" + i;
                        inParams.Add(pName);
                        extraParams.Add(new SqlParameter(pName, allowedUserIds[i]));
                    }

                    categoryWhere = "f.discussionType = 'Private' AND f.createdBy IN (" + string.Join(",", inParams) + ")";
                }
                else
                {
                    categoryWhere = "(f.discussionType IS NULL OR f.discussionType <> 'Private')";
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
                    WHERE  {1}
                    {2}
                    {3}
                    {4}";

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

                sql = string.Format(sql, joinTag, categoryWhere, whereTag, whereSearch, orderBy);

                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    if (!string.IsNullOrEmpty(tagFilter))
                        cmd.Parameters.AddWithValue("@tagId", tagFilter);
                    if (!string.IsNullOrEmpty(search))
                        cmd.Parameters.AddWithValue("@search", search);

                    // Add extra parameters for private tab IN clause
                    foreach (var p in extraParams)
                        cmd.Parameters.Add(p);

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
                        string discType = row["discussionType"] == DBNull.Value
                            ? "" : row["discussionType"].ToString();
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

                        // Discussion type label and badge CSS
                        string typeLabel;
                        string badgeCss;
                        if (discType == "Private")
                        {
                            typeLabel = T("Private", "Peribadi");
                            badgeCss = "fm-disc-badge private";
                        }
                        else
                        {
                            typeLabel = T("Public", "Awam");
                            badgeCss = "fm-disc-badge public";
                        }

                        list.Add(new
                        {
                            ForumId = forumId,
                            Title = title,
                            MessagePreview = preview,
                            CreatorName = creatorName,
                            CreatorInitial = initial,
                            Date = FormatDate(createdAt),
                            DiscussionType = typeLabel,
                            BadgeCss = badgeCss,
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

        // ── Get linked parent userIds ─────────────────────────────────
        private List<string> GetLinkedParentUserIds(SqlConnection conn, string userId)
        {
            var parentUserIds = new List<string>();

            if (!Tbl(conn, "StudentParent") || !Tbl(conn, "Parent") || !Tbl(conn, "Student"))
                return parentUserIds;

            const string sql = @"
                SELECT p.userId
                FROM Parent p
                JOIN StudentParent sp ON sp.parentId = p.parentId
                JOIN Student s ON s.studentId = sp.studentId
                WHERE s.userId = @userId";

            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        if (rdr["userId"] != DBNull.Value)
                            parentUserIds.Add(rdr["userId"].ToString());
                    }
                }
            }

            return parentUserIds;
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
                    // Like — generate sequential ID (likeId is NVARCHAR(10))
                    string likeId = "LK001";
                    const string seqSql = @"
                        SELECT ISNULL(MAX(CAST(SUBSTRING(likeId, 3, LEN(likeId) - 2) AS INT)), 0)
                        FROM ForumLike WHERE likeId LIKE 'LK[0-9]%'";
                    using (var seqCmd = new SqlCommand(seqSql, conn))
                    {
                        object lastVal = seqCmd.ExecuteScalar();
                        if (lastVal != null && lastVal != DBNull.Value)
                        {
                            int lastNum = Convert.ToInt32(lastVal);
                            likeId = "LK" + (lastNum + 1).ToString("D3");
                        }
                    }

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
