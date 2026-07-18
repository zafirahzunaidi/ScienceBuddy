using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace ScienceBuddy.Student
{
    public partial class MyRanking1 : Page
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

            if (!IsPostBack)
            {
                InitLang();
                SetLabels();
                LoadPage();
            }
        }

        // ── Language initialization ───────────────────────────────────
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

        // ── Set bilingual labels ──────────────────────────────────────
        private void SetLabels()
        {
            litPageTitle.Text = T("My Ranking", "Kedudukan Saya");
            litHeroMessage.Text = T("See your position and keep improving step by step.",
                "Lihat kedudukan anda dan teruskan peningkatan langkah demi langkah.");
            litBoardTitle.Text = T("Top 10 Leaderboard", "10 Teratas Papan Kedudukan");
            litYourPosTitle.Text = T("Your Position", "Kedudukan Anda");
            litPersonalRankLbl.Text = T("Rank", "Kedudukan");
            litPersonalLevelLbl.Text = T("Level", "Tahap");
            litPersonalBadgesLbl.Text = T("Badges", "Lencana");
            litTipsTitle.Text = T("Ways to Earn XP", "Cara Memperoleh XP");
            litTip1.Text = T("Complete lessons", "Selesaikan pelajaran");
            litTip2.Text = T("Complete virtual labs", "Selesaikan makmal maya");
            litTip3.Text = T("Attempt practice quizzes", "Jawab kuiz latihan");
            litTip4.Text = T("Pass unit quizzes", "Lulus kuiz unit");
            litNavBack.Text = T("Back to Progress &amp; Rewards", "Kembali ke Kemajuan &amp; Ganjaran");
            litNavLearn.Text = T("Continue Learning", "Teruskan Pembelajaran");
            litNavPractice.Text = T("Practice Library", "Perpustakaan Latihan");
            litPodiumTitle.Text = T("Top 3 Champions", "3 Juara Teratas");
            litFilterLabel.Text = T("Filter leaderboard", "Tapis papan kedudukan");
            litFAll.Text = T("All Students", "Semua Pelajar");
            litFLevel.Text = T("My Level", "Tahap Saya");
            litFPers.Text = T("My Personality", "Personaliti Saya");
        }

        // ── Load page data ────────────────────────────────────────────
        private void LoadPage()
        {
            string userId = Session["userId"].ToString();

            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();

                string studentId = GetStudentId(connection, userId);
                if (string.IsNullOrEmpty(studentId))
                {
                    SetEmptyState();
                    return;
                }

                bool hasBadgeTable = Tbl(connection, "StudentBadge");

                string badgeSubquery;
                if (hasBadgeTable)
                {
                    badgeSubquery = "(SELECT COUNT(*) FROM StudentBadge WHERE studentId = s.studentId)";
                }
                else
                {
                    badgeSubquery = "0";
                }

                string sql = string.Format(@"
                    SELECT s.studentId, s.name, s.nickname, s.XP, s.currentlevelId, s.personalityId,
                           l.levelNameEN, l.levelNameBM,
                           {0} AS badgeCount,
                           ROW_NUMBER() OVER (ORDER BY s.XP DESC, s.studentId) AS rankPos
                    FROM Student s
                    JOIN [User] u ON u.userId = s.userId
                    LEFT JOIN Level l ON l.levelId = s.currentlevelId
                    WHERE u.status = 'Active' AND u.role = 'Student'", badgeSubquery);

                DataTable dataTable = new DataTable();
                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    SqlDataAdapter adapter = new SqlDataAdapter(command);
                    adapter.Fill(dataTable);
                }

                if (dataTable.Rows.Count == 0)
                {
                    SetEmptyState();
                    return;
                }

                int myRank = 0;
                int myXP = 0;
                string myName = "Student";
                string myLevelName = "\u2014";
                int myBadgeCount = 0;
                string myInitial = "S";
                string currentLevelId = "";
                string personalityId = "";

                foreach (DataRow row in dataTable.Rows)
                {
                    if (row["studentId"].ToString() == studentId)
                    {
                        myRank = Convert.ToInt32(row["rankPos"]);
                        if (row["XP"] == DBNull.Value)
                        {
                            myXP = 0;
                        }
                        else
                        {
                            myXP = Convert.ToInt32(row["XP"]);
                        }

                        string nickname = row["nickname"]?.ToString();
                        string name = row["name"]?.ToString();
                        if (!string.IsNullOrWhiteSpace(nickname))
                        {
                            myName = nickname;
                        }
                        else
                        {
                            myName = name;
                        }

                        if (CurrentLanguage == "BM")
                        {
                            myLevelName = row["levelNameBM"]?.ToString() ?? row["levelNameEN"]?.ToString() ?? "\u2014";
                        }
                        else
                        {
                            myLevelName = row["levelNameEN"]?.ToString() ?? "\u2014";
                        }

                        myBadgeCount = Convert.ToInt32(row["badgeCount"]);
                        currentLevelId = row["currentlevelId"]?.ToString() ?? "";
                        personalityId = row["personalityId"]?.ToString() ?? "";
                        if (!string.IsNullOrWhiteSpace(myName))
                        {
                            myInitial = myName[0].ToString().ToUpper();
                        }
                        else
                        {
                            myInitial = "S";
                        }
                        break;
                    }
                }

                litHeroRank.Text = T("Your Rank: #", "Kedudukan Anda: #") + myRank.ToString();
                litHeroXP.Text = myXP.ToString("N0") + " XP";
                litHeroLevel.Text = T("Level: ", "Tahap: ") + HttpUtility.HtmlEncode(myLevelName);

                litPersonalInitial.Text = HttpUtility.HtmlEncode(myInitial);
                litPersonalName.Text = HttpUtility.HtmlEncode(myName);
                litPersonalRank.Text = "#" + myRank.ToString();
                litPersonalXP.Text = myXP.ToString("N0");
                litPersonalLevel.Text = HttpUtility.HtmlEncode(myLevelName);
                litPersonalBadges.Text = myBadgeCount.ToString();

                string rankFilter;
                if (ViewState["RankFilter"] != null)
                {
                    rankFilter = ViewState["RankFilter"] as string;
                }
                else
                {
                    rankFilter = "all";
                }
                if (rankFilter == null)
                {
                    rankFilter = "all";
                }

                List<object> leaderboard = new List<object>();
                int count = 0;
                int filteredRank = 0;
                int topCount = GetConfigInt("Leaderboard Top Count", 10);
                foreach (DataRow row in dataTable.Rows)
                {
                    if (rankFilter == "level" && !string.IsNullOrEmpty(currentLevelId))
                    {
                        string rowLevel = row["currentlevelId"]?.ToString() ?? "";
                        if (rowLevel != currentLevelId)
                        {
                            continue;
                        }
                    }
                    else if (rankFilter == "personality" && !string.IsNullOrEmpty(personalityId))
                    {
                        string rowPers = row["personalityId"]?.ToString() ?? "";
                        if (rowPers != personalityId)
                        {
                            continue;
                        }
                    }

                    filteredRank++;
                    if (count >= topCount)
                    {
                        continue;
                    }

                    string nickname = row["nickname"]?.ToString();
                    string name = row["name"]?.ToString();
                    string displayName;
                    if (!string.IsNullOrWhiteSpace(nickname))
                    {
                        displayName = nickname;
                    }
                    else
                    {
                        displayName = name;
                    }

                    int xp;
                    if (row["XP"] == DBNull.Value)
                    {
                        xp = 0;
                    }
                    else
                    {
                        xp = Convert.ToInt32(row["XP"]);
                    }

                    string levelName;
                    if (CurrentLanguage == "BM")
                    {
                        levelName = row["levelNameBM"]?.ToString() ?? row["levelNameEN"]?.ToString() ?? "\u2014";
                    }
                    else
                    {
                        levelName = row["levelNameEN"]?.ToString() ?? "\u2014";
                    }

                    int badges = Convert.ToInt32(row["badgeCount"]);
                    bool isCurrentUser = row["studentId"].ToString() == studentId;
                    string initial;
                    if (!string.IsNullOrWhiteSpace(displayName))
                    {
                        initial = displayName[0].ToString().ToUpper();
                    }
                    else
                    {
                        initial = "S";
                    }

                    leaderboard.Add(new
                    {
                        Rank = filteredRank,
                        DisplayName = HttpUtility.HtmlEncode(displayName),
                        LevelName = HttpUtility.HtmlEncode(levelName),
                        XP = xp.ToString("N0"),
                        BadgeCount = badges,
                        IsCurrentUser = isCurrentUser,
                        Initial = initial
                    });

                    count++;
                }

                rptLeaderboard.DataSource = leaderboard;
                rptLeaderboard.DataBind();

                BuildPodium(dataTable, studentId);

                if (myRank > topCount)
                {
                    pnlYourPosition.Visible = true;
                    litYourPosRank.Text = "#" + myRank.ToString();
                    litYourPosName.Text = HttpUtility.HtmlEncode(myName);
                    litYourPosXP.Text = myXP.ToString("N0") + " XP";
                }

                litMotivateMsg.Text = GetMotivationalMessage(myRank);
            }
        }

        // ── Build Top 3 Podium ───────────────────────────────────────
        private void BuildPodium(DataTable dataTable, string currentStudentId)
        {
            if (dataTable.Rows.Count == 0)
            {
                litPodium.Text = "";
                return;
            }

            List<DataRow> top3 = new List<DataRow>();
            for (int i = 0; i < Math.Min(3, dataTable.Rows.Count); i++)
            {
                top3.Add(dataTable.Rows[i]);
            }

            string html = "<div class=\"st-ranking-podium\">";

            int[] order;
            if (top3.Count >= 3)
            {
                order = new[] { 1, 0, 2 };
            }
            else if (top3.Count == 2)
            {
                order = new[] { 1, 0 };
            }
            else
            {
                order = new[] { 0 };
            }
            string[] classes = { "first", "second", "third" };

            foreach (int idx in order)
            {
                if (idx >= top3.Count)
                {
                    continue;
                }
                DataRow row = top3[idx];
                int rank = idx + 1;
                string placeClass = classes[idx];
                string nickname = row["nickname"]?.ToString();
                string name = row["name"]?.ToString();
                string displayName;
                if (!string.IsNullOrWhiteSpace(nickname))
                {
                    displayName = nickname;
                }
                else
                {
                    displayName = name;
                }

                string initial;
                if (!string.IsNullOrWhiteSpace(displayName))
                {
                    initial = displayName[0].ToString().ToUpper();
                }
                else
                {
                    initial = "S";
                }

                int xp;
                if (row["XP"] == DBNull.Value)
                {
                    xp = 0;
                }
                else
                {
                    xp = Convert.ToInt32(row["XP"]);
                }
                bool isMe = row["studentId"].ToString() == currentStudentId;

                html += "<div class=\"st-ranking-podium-player " + placeClass + "\">";
                if (rank == 1)
                {
                    html += "<div class=\"st-ranking-podium-crown\"><i class=\"bi bi-trophy-fill\"></i></div>";
                }
                if (isMe)
                {
                    html += "<div class=\"st-ranking-podium-you\">" + T("You", "Anda") + "</div>";
                }
                html += "<div class=\"st-ranking-podium-avatar\">" + HttpUtility.HtmlEncode(initial) + "</div>";
                html += "<div class=\"st-ranking-podium-name\">" + HttpUtility.HtmlEncode(displayName) + "</div>";
                html += "<div class=\"st-ranking-podium-xp\">" + xp.ToString("N0") + " XP</div>";
                html += "<div class=\"st-ranking-podium-block\"><span>" + rank + "</span></div>";
                html += "</div>";
            }

            html += "</div>";
            litPodium.Text = html;
        }

        // ── Get student ID from userId ────────────────────────────────
        private string GetStudentId(SqlConnection connection, string userId)
        {
            const string sql = "SELECT studentId FROM Student WHERE userId = @userId";
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@userId", userId);
                object result = command.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                {
                    return result.ToString();
                }
                return null;
            }
        }

        // ── Filter click handler ──────────────────────────────────────
        protected void btnFilter_Click(object sender, EventArgs e)
        {
            System.Web.UI.WebControls.LinkButton button = (System.Web.UI.WebControls.LinkButton)sender;
            ViewState["RankFilter"] = button.CommandArgument;
            InitLang();
            SetLabels();
            LoadPage();

            string filter = button.CommandArgument;
            if (filter == "all")
            {
                btnFilterAll.CssClass = "st-ranking-filter-chip active";
            }
            else
            {
                btnFilterAll.CssClass = "st-ranking-filter-chip";
            }

            if (filter == "level")
            {
                btnFilterLevel.CssClass = "st-ranking-filter-chip active";
            }
            else
            {
                btnFilterLevel.CssClass = "st-ranking-filter-chip";
            }

            if (filter == "personality")
            {
                btnFilterPers.CssClass = "st-ranking-filter-chip active";
            }
            else
            {
                btnFilterPers.CssClass = "st-ranking-filter-chip";
            }
        }

        // ── Motivational message based on rank ────────────────────────
        private string GetMotivationalMessage(int rank)
        {
            if (rank == 1)
            {
                return T("You're leading the leaderboard!", "Anda mendahului papan kedudukan!");
            }
            if (rank <= 3)
            {
                return T("You're in the top 3. Amazing work!", "Anda berada dalam 3 teratas. Hebat!");
            }
            if (rank <= 10)
            {
                return T("You're in the top 10. Keep going!", "Anda berada dalam 10 teratas. Teruskan usaha!");
            }

            return T("Every lesson gives you XP. Keep learning and your rank will improve.",
                "Setiap pelajaran memberi XP. Teruskan belajar dan kedudukan anda akan meningkat.");
        }

        // ── Rank CSS class helper (used in aspx markup) ───────────────
        protected string GetRankClass(int rank)
        {
            switch (rank)
            {
                case 1: return "st-ranking-board-rank st-ranking-gold";
                case 2: return "st-ranking-board-rank st-ranking-silver";
                case 3: return "st-ranking-board-rank st-ranking-bronze";
                default: return "st-ranking-board-rank st-ranking-normal";
            }
        }

        // ── Empty state when no data ──────────────────────────────────
        private void SetEmptyState()
        {
            litHeroRank.Text = T("My Ranking", "Kedudukan Saya");
            litHeroXP.Text = "0 XP";
            litHeroLevel.Text = T("Level: \u2014", "Tahap: \u2014");
            litPersonalName.Text = "\u2014";
            litPersonalRank.Text = "#\u2014";
            litPersonalXP.Text = "0";
            litPersonalLevel.Text = "\u2014";
            litPersonalBadges.Text = "0";
            litMotivateMsg.Text = T("Every lesson gives you XP. Keep learning and your rank will improve.",
                "Setiap pelajaran memberi XP. Teruskan belajar dan kedudukan anda akan meningkat.");
        }

        // ── Table existence check ─────────────────────────────────────
        private static bool Tbl(SqlConnection connection, string tableName)
        {
            const string sql = @"
                SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
                WHERE TABLE_NAME = @tableName
                AND TABLE_TYPE = 'BASE TABLE'";
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@tableName", tableName);
                return (int)command.ExecuteScalar() > 0;
            }
        }

        private int GetConfigInt(string configKey, int defaultValue)
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(ConnStr))
                {
                    connection.Open();
                    using (SqlCommand command = new SqlCommand("SELECT configValue FROM ConfigurationSetting WHERE configKey=@k", connection))
                    {
                        command.Parameters.AddWithValue("@k", configKey);
                        object result = command.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            return Convert.ToInt32(result);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Config error: " + ex.Message);
            }
            return defaultValue;
        }
    }
}
