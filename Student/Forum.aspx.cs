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
    public partial class Forum : Page
    {
        // â”€â”€ Connection string â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        private string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString; }
        }

        // â”€â”€ Language helper â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        public string CurrentLanguage = "EN";

        public string T(string en, string bm)
        {
            if (CurrentLanguage == "BM")
            {
                return bm;
            }
            return en;
        }

        // â”€â”€ Page Load â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null ||
                Session["role"].ToString() != "Student")
            {
                Response.Redirect("~/Login.aspx", false);
                return;
            }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";

            // Always init language and set labels (fixes tab text disappearing on postback)
            InitLang();
            SetLabels();

            if (!IsPostBack)
            {
                BuildFilters();
                LoadDiscussions();
            }
        }

        // â”€â”€ Language initialisation â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

        // â”€â”€ Bilingual labels â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        private void SetLabels()
        {
            bool isPrivate = hfCategory.Value == "private";

            litPageTitle.Text = T("Forum", "Forum");
            litTitle.Text = T("Forum", "Forum");
            litSubtitle.Text = T("Ask questions, share ideas, and learn Science together.",
                                "Tanya soalan, kongsi idea, dan belajar Sains bersama-sama.");

            // Tab labels (include icon HTML so it persists on postback)
            litTabPublic.Text = "<i class=\"bi bi-globe\"></i> " + T("Public", "Awam");
            litTabPrivate.Text = "<i class=\"bi bi-people-fill\"></i> " + T("Family", "Keluarga");
            litTabMy.Text = "<i class=\"bi bi-person-fill\"></i> " + T("My Forum", "Forum Saya");

            // Summary card labels based on selected tab
            if (isPrivate)
            {
                litTotalDiscLbl.Text = T("Private Discussions", "Perbincangan Peribadi");
                litMyDiscLbl.Text = T("My Discussions", "Perbincangan Saya");
                litTotalRepliesLbl.Text = T("Total Replies", "Jumlah Balasan");
            }
            else
            {
                litTotalDiscLbl.Text = T("Public Discussions", "Perbincangan Awam");
                litMyDiscLbl.Text = T("My Discussions", "Perbincangan Saya");
                litTotalRepliesLbl.Text = T("Total Replies", "Jumlah Balasan");
            }

            // Empty state labels and CTA based on selected tab
            if (isPrivate)
            {
                litEmptyTitle.Text = T("No private parent-student discussions yet.",
                                        "Tiada perbincangan peribadi murid-ibu bapa lagi.");
                litEmptyDesc.Text = T("Start a private discussion with your linked parent and siblings. Only you, your siblings and your parent can see these conversations.",
                                        "Mulakan perbincangan peribadi dengan ibu bapa anda yang dipautkan. Hanya anda dan ibu bapa anda boleh melihat perbualan ini.");
                litCTAText.Text = T("Want to chat with your parent privately?", "Ingin berbual dengan ibu bapa anda secara peribadi?");
                litCTABtn.Text = T("Create Private Discussion", "Cipta Perbincangan Peribadi");
            }
            else if (hfCategory.Value == "my")
            {
                litEmptyTitle.Text = T("You haven't created any discussions yet.",
                                        "Anda belum mencipta sebarang perbincangan lagi.");
                litEmptyDesc.Text = T("Create your first discussion and start learning together!",
                                        "Cipta perbincangan pertama anda dan mula belajar bersama!");
                litCTAText.Text = T("Ready to start a discussion?", "Bersedia untuk memulakan perbincangan?");
                litCTABtn.Text = T("Create Discussion", "Cipta Perbincangan");
            }
            else
            {
                litEmptyTitle.Text = T("No public discussions yet.",
                                        "Tiada perbincangan awam lagi.");
                litEmptyDesc.Text = T("Be the first to ask a Science question!",
                                        "Jadilah yang pertama bertanya soalan Sains!");
                litCTAText.Text = T("Have a Science question?", "Ada soalan Sains?");
                litCTABtn.Text = T("Create Discussion", "Cipta Perbincangan");
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
            btnTabPublic.CssClass = "st-forum-cat-tab";
            btnTabPrivate.CssClass = "st-forum-cat-tab";
            btnTabMy.CssClass = "st-forum-cat-tab";

            if (hfCategory.Value == "private")
                btnTabPrivate.CssClass = "st-forum-cat-tab active";
            else if (hfCategory.Value == "my")
                btnTabMy.CssClass = "st-forum-cat-tab active";
            else
                btnTabPublic.CssClass = "st-forum-cat-tab active";
        }

        // â”€â”€ Tab click handlers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

        protected void btnTabMy_Click(object sender, EventArgs e)
        {
            hfCategory.Value = "my";
            SetLabels();
            LoadDiscussions();
        }

        // â”€â”€ Build filter dropdowns â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        private void BuildFilters()
        {
            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();

                // Tags
                ddlTag.Items.Clear();
                ddlTag.Items.Add(new ListItem(T("All Tags", "Semua Tag"), ""));

                if (Tbl(connection, "Tag"))
                {
                    const string sql = "SELECT tagId, tagName FROM Tag ORDER BY tagName";
                    using (SqlCommand command = new SqlCommand(sql, connection))
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            ddlTag.Items.Add(new ListItem(reader["tagName"].ToString(), reader["tagId"].ToString()));
                        }
                    }
                }
            }
        }

        // â”€â”€ Load discussions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        private void LoadDiscussions()
        {
            string userId = Session["userId"].ToString();
            string tagFilter = ddlTag.SelectedValue;
            string sortVal = ddlSort.SelectedValue;
            string search = txtSearch.Text.Trim();
            bool isPrivate = hfCategory.Value == "private";
            bool isMy = hfCategory.Value == "my";

            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();

                if (!Tbl(connection, "Forum"))
                {
                    ShowEmpty();
                    return;
                }

                // â”€â”€ Build WHERE clause based on category tab â”€â”€
                string categoryWhere;
                List<SqlParameter> extraParams = new List<SqlParameter>();

                if (isMy)
                {
                    categoryWhere = "f.createdBy = @userId";
                }
                else if (isPrivate)
                {
                    // Get linked parent userIds
                    List<string> allowedUserIds = new List<string> { userId };
                    allowedUserIds.AddRange(GetLinkedParentUserIds(connection, userId));

                    // Build IN clause with parameters
                    List<string> inParams = new List<string>();
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
                if (!string.IsNullOrEmpty(tagFilter) && Tbl(connection, "ForumTag"))
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

                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    command.Parameters.AddWithValue("@userId", userId);
                    if (!string.IsNullOrEmpty(tagFilter))
                    {
                        command.Parameters.AddWithValue("@tagId", tagFilter);
                    }
                    if (!string.IsNullOrEmpty(search))
                    {
                        command.Parameters.AddWithValue("@search", search);
                    }

                    // Add extra parameters for private tab IN clause
                    foreach (SqlParameter p in extraParams)
                    {
                        command.Parameters.Add(p);
                    }

                    SqlDataAdapter adapter = new SqlDataAdapter(command);
                    DataTable dataTable = new DataTable();
                    adapter.Fill(dataTable);

                    if (dataTable.Rows.Count == 0)
                    {
                        ShowEmpty();
                        return;
                    }

                    // Get tags for each forum
                    Dictionary<string, string> forumTags = new Dictionary<string, string>();
                    if (Tbl(connection, "ForumTag") && Tbl(connection, "Tag"))
                    {
                        const string tagSql = @"
                            SELECT ft.forumId, t.tagName
                            FROM ForumTag ft
                            JOIN Tag t ON t.tagId = ft.tagId";
                        using (SqlCommand tagCmd = new SqlCommand(tagSql, connection))
                        using (SqlDataReader tagReader = tagCmd.ExecuteReader())
                        {
                            while (tagReader.Read())
                            {
                                string fId = tagReader["forumId"].ToString();
                                string tName = tagReader["tagName"].ToString();
                                if (forumTags.ContainsKey(fId))
                                {
                                    forumTags[fId] += ", " + tName;
                                }
                                else
                                {
                                    forumTags[fId] = tName;
                                }
                            }
                        }
                    }

                    // Build display list
                    List<object> list = new List<object>();
                    int myCount = 0;
                    int totalReplies = 0;

                    foreach (DataRow row in dataTable.Rows)
                    {
                        string forumId = row["forumId"].ToString();
                        string title = row["title"].ToString();
                        string message = row["message"].ToString();
                        string creatorName = row["creatorName"].ToString();

                        DateTime createdAt;
                        if (row["createdAt"] == DBNull.Value)
                        {
                            createdAt = DateTime.Now;
                        }
                        else
                        {
                            createdAt = Convert.ToDateTime(row["createdAt"]);
                        }

                        int replyCount = Convert.ToInt32(row["replyCount"]);
                        int likeCount = Convert.ToInt32(row["likeCount"]);
                        bool isLiked = Convert.ToInt32(row["isLiked"]) > 0;

                        string discType = "";
                        if (row["discussionType"] != DBNull.Value)
                        {
                            discType = row["discussionType"].ToString();
                        }

                        string createdBy = row["createdBy"].ToString();

                        // Count my discussions
                        if (createdBy == userId)
                        {
                            myCount++;
                        }
                        totalReplies += replyCount;

                        // Message preview (first 120 chars)
                        string preview;
                        if (message.Length > 120)
                        {
                            preview = message.Substring(0, 120) + "â€¦";
                        }
                        else
                        {
                            preview = message;
                        }

                        // Creator initial
                        string initial;
                        if (!string.IsNullOrWhiteSpace(creatorName))
                        {
                            initial = creatorName[0].ToString().ToUpper();
                        }
                        else
                        {
                            initial = "?";
                        }

                        // Tags
                        string tags = "";
                        if (forumTags.ContainsKey(forumId))
                        {
                            tags = forumTags[forumId];
                        }

                        // Discussion type label and badge CSS
                        string typeLabel;
                        string badgeCss;
                        if (discType == "Private")
                        {
                            typeLabel = T("Private", "Peribadi");
                            badgeCss = "st-forum-disc-badge private";
                        }
                        else
                        {
                            typeLabel = T("Public", "Awam");
                            badgeCss = "st-forum-disc-badge public";
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
                            Tags = tags,
                            IsOwner = (createdBy == userId)
                        });
                    }

                    // Bind
                    pnlList.Visible = true;
                    pnlEmpty.Visible = false;
                    rptDiscussions.DataSource = list;
                    rptDiscussions.DataBind();

                    // Stats
                    litTotalDisc.Text = dataTable.Rows.Count.ToString();
                    litMyDisc.Text = myCount.ToString();
                    litTotalReplies.Text = totalReplies.ToString();
                }
            }
        }

        // â”€â”€ Get linked parent userIds â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        private List<string> GetLinkedParentUserIds(SqlConnection connection, string userId)
        {
            List<string> parentUserIds = new List<string>();

            if (!Tbl(connection, "StudentParent") || !Tbl(connection, "Parent") || !Tbl(connection, "Student"))
            {
                return parentUserIds;
            }

            const string sql = @"
                SELECT p.userId
                FROM Parent p
                JOIN StudentParent sp ON sp.parentId = p.parentId
                JOIN Student s ON s.studentId = sp.studentId
                WHERE s.userId = @userId";

            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@userId", userId);
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        if (reader["userId"] != DBNull.Value)
                        {
                            parentUserIds.Add(reader["userId"].ToString());
                        }
                    }
                }
            }

            return parentUserIds;
        }

        // â”€â”€ Filter button click â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        protected void btnFilter_Click(object sender, EventArgs e)
        {
            LoadDiscussions();
        }

        // â”€â”€ Like / Unlike â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        protected void rptDiscussions_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Delete")
            {
                HandleDelete(e.CommandArgument.ToString());
                return;
            }

            if (e.CommandName != "Like")
            {
                return;
            }

            string forumId = e.CommandArgument.ToString();
            string userId = Session["userId"].ToString();

            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();

                // Check if already liked
                const string checkSql = @"
                    SELECT COUNT(*) FROM ForumLike
                    WHERE forumId = @forumId AND senderUserId = @userId";
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
                        WHERE forumId = @forumId AND senderUserId = @userId";
                    using (SqlCommand delCmd = new SqlCommand(delSql, connection))
                    {
                        delCmd.Parameters.AddWithValue("@forumId", forumId);
                        delCmd.Parameters.AddWithValue("@userId", userId);
                        delCmd.ExecuteNonQuery();
                    }
                }
                else
                {
                    // Like â€” generate sequential ID (likeId is NVARCHAR(10))
                    string likeId = "LIKE001";
                    const string seqSql = @"
                        SELECT ISNULL(MAX(CAST(SUBSTRING(likeId, 5, LEN(likeId) - 4) AS INT)), 0)
                        FROM ForumLike WHERE likeId LIKE 'LIKE[0-9]%'";
                    using (SqlCommand seqCmd = new SqlCommand(seqSql, connection))
                    {
                        object lastVal = seqCmd.ExecuteScalar();
                        if (lastVal != null && lastVal != DBNull.Value)
                        {
                            int lastNum = Convert.ToInt32(lastVal);
                            likeId = "LIKE" + (lastNum + 1).ToString("D3");
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

            // Reload
            LoadDiscussions();
        }

        // â”€â”€ Delete forum post (with ownership check) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        private void HandleDelete(string forumId)
        {
            string userId = Session["userId"].ToString();

            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();

                // Verify ownership
                const string ownerSql = "SELECT createdBy FROM Forum WHERE forumId = @fid";
                using (SqlCommand ownerCmd = new SqlCommand(ownerSql, connection))
                {
                    ownerCmd.Parameters.AddWithValue("@fid", forumId);
                    object result = ownerCmd.ExecuteScalar();
                    if (result == null || result == DBNull.Value || result.ToString() != userId)
                    {
                        // Not owner â€” do nothing
                        LoadDiscussions();
                        return;
                    }
                }

                // Delete related records first (ForumTag, ForumLike, ForumChat), then Forum
                if (Tbl(connection, "ForumTag"))
                {
                    using (SqlCommand cmd = new SqlCommand("DELETE FROM ForumTag WHERE forumId = @fid", connection))
                    {
                        cmd.Parameters.AddWithValue("@fid", forumId);
                        cmd.ExecuteNonQuery();
                    }
                }

                if (Tbl(connection, "ForumLike"))
                {
                    using (SqlCommand cmd = new SqlCommand("DELETE FROM ForumLike WHERE forumId = @fid", connection))
                    {
                        cmd.Parameters.AddWithValue("@fid", forumId);
                        cmd.ExecuteNonQuery();
                    }
                }

                if (Tbl(connection, "ForumChat"))
                {
                    using (SqlCommand cmd = new SqlCommand("DELETE FROM ForumChat WHERE forumId = @fid", connection))
                    {
                        cmd.Parameters.AddWithValue("@fid", forumId);
                        cmd.ExecuteNonQuery();
                    }
                }

                using (SqlCommand cmd = new SqlCommand("DELETE FROM Forum WHERE forumId = @fid AND createdBy = @uid", connection))
                {
                    cmd.Parameters.AddWithValue("@fid", forumId);
                    cmd.Parameters.AddWithValue("@uid", userId);
                    cmd.ExecuteNonQuery();
                }
            }

            LoadDiscussions();
        }

        // â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

        /// <summary>
        /// Returns true if the given table exists in the current database.
        /// Uses INFORMATION_SCHEMA so it never throws on a missing table.
        /// </summary>
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

