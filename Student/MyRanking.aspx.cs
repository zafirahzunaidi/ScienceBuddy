using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace ScienceBuddy.Student
{
    public partial class MyRanking : Page
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

        // ── Set bilingual labels ──────────────────────────────────────
        private void SetLabels()
        {
            litPageTitle.Text       = T("My Ranking", "Kedudukan Saya");
            litHeroMessage.Text     = T("See your position and keep improving step by step.",
                                        "Lihat kedudukan anda dan teruskan peningkatan langkah demi langkah.");
            litBoardTitle.Text      = T("Top 10 Leaderboard", "10 Teratas Papan Kedudukan");
            litYourPosTitle.Text    = T("Your Position", "Kedudukan Anda");
            litPersonalRankLbl.Text = T("Rank", "Kedudukan");
            litPersonalLevelLbl.Text = T("Level", "Tahap");
            litPersonalBadgesLbl.Text = T("Badges", "Lencana");
            litTipsTitle.Text       = T("Ways to Earn XP", "Cara Memperoleh XP");
            litTip1.Text            = T("Complete lessons", "Selesaikan pelajaran");
            litTip2.Text            = T("Complete virtual labs", "Selesaikan makmal maya");
            litTip3.Text            = T("Attempt practice quizzes", "Jawab kuiz latihan");
            litTip4.Text            = T("Pass unit quizzes", "Lulus kuiz unit");
            litNavBack.Text         = T("Back to Progress &amp; Rewards", "Kembali ke Kemajuan &amp; Ganjaran");
            litNavLearn.Text        = T("Continue Learning", "Teruskan Pembelajaran");
            litNavPractice.Text     = T("Practice Library", "Perpustakaan Latihan");
            litPodiumTitle.Text     = T("Top 3 Champions", "3 Juara Teratas");
            litFilterLabel.Text    = T("Filter leaderboard", "Tapis papan kedudukan");
            litFAll.Text           = T("All Students", "Semua Pelajar");
            litFLevel.Text         = T("My Level", "Tahap Saya");
            litFPers.Text          = T("My Personality", "Personaliti Saya");
        }

        // ── Load page data ────────────────────────────────────────────
        private void LoadPage()
        {
            string userId = Session["userId"].ToString();

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // 1. Get logged-in student's studentId
                string studentId = GetStudentId(conn, userId);
                if (string.IsNullOrEmpty(studentId))
                {
                    SetEmptyState();
                    return;
                }

                // 2. Check if StudentBadge table exists
                bool hasBadgeTable = Tbl(conn, "StudentBadge");

                // 3. Query ALL active students ranked by XP DESC
                string badgeSubquery = hasBadgeTable
                    ? "(SELECT COUNT(*) FROM StudentBadge WHERE studentId = s.studentId)"
                    : "0";

                string sql = string.Format(@"
                    SELECT s.studentId, s.name, s.nickname, s.XP, s.currentlevelId, s.personalityId,
                           l.levelNameEN, l.levelNameBM,
                           {0} AS badgeCount,
                           ROW_NUMBER() OVER (ORDER BY s.XP DESC, s.studentId) AS rankPos
                    FROM Student s
                    JOIN [User] u ON u.userId = s.userId
                    LEFT JOIN Level l ON l.levelId = s.currentlevelId
                    WHERE u.status = 'Active' AND u.role = 'Student'", badgeSubquery);

                var dt = new DataTable();
                using (var cmd = new SqlCommand(sql, conn))
                {
                    var da = new SqlDataAdapter(cmd);
                    da.Fill(dt);
                }

                if (dt.Rows.Count == 0)
                {
                    SetEmptyState();
                    return;
                }

                // 4. Find logged-in student's data from the result
                int myRank = 0;
                int myXP = 0;
                string myName = "Student";
                string myLevelName = "—";
                int myBadgeCount = 0;
                string myInitial = "S";
                string currentLevelId = "";
                string personalityId = "";

                foreach (DataRow row in dt.Rows)
                {
                    if (row["studentId"].ToString() == studentId)
                    {
                        myRank = Convert.ToInt32(row["rankPos"]);
                        myXP = row["XP"] == DBNull.Value ? 0 : Convert.ToInt32(row["XP"]);
                        string nickname = row["nickname"]?.ToString();
                        string name = row["name"]?.ToString();
                        myName = !string.IsNullOrWhiteSpace(nickname) ? nickname : name;
                        myLevelName = CurrentLanguage == "BM"
                            ? (row["levelNameBM"]?.ToString() ?? row["levelNameEN"]?.ToString() ?? "—")
                            : (row["levelNameEN"]?.ToString() ?? "—");
                        myBadgeCount = Convert.ToInt32(row["badgeCount"]);
                        currentLevelId = row["currentlevelId"]?.ToString() ?? "";
                        personalityId = row["personalityId"]?.ToString() ?? "";
                        myInitial = !string.IsNullOrWhiteSpace(myName) ? myName[0].ToString().ToUpper() : "S";
                        break;
                    }
                }

                // 5. Set hero
                litHeroRank.Text = T("Your Rank: #", "Kedudukan Anda: #") + myRank.ToString();
                litHeroXP.Text = myXP.ToString("N0") + " XP";
                litHeroLevel.Text = T("Level: ", "Tahap: ") + HttpUtility.HtmlEncode(myLevelName);

                // 6. Set personal rank card
                litPersonalInitial.Text = HttpUtility.HtmlEncode(myInitial);
                litPersonalName.Text = HttpUtility.HtmlEncode(myName);
                litPersonalRank.Text = "#" + myRank.ToString();
                litPersonalXP.Text = myXP.ToString("N0");
                litPersonalLevel.Text = HttpUtility.HtmlEncode(myLevelName);
                litPersonalBadges.Text = myBadgeCount.ToString();

                // 7. Build top 10 leaderboard (with filter support)
                string rankFilter = ViewState["RankFilter"] as string ?? "all";
                var leaderboard = new List<object>();
                int count = 0;
                int filteredRank = 0;
                foreach (DataRow row in dt.Rows)
                {
                    // Apply filter
                    if (rankFilter == "level" && !string.IsNullOrEmpty(currentLevelId))
                    {
                        string rowLevel = row["currentlevelId"]?.ToString() ?? "";
                        if (rowLevel != currentLevelId) continue;
                    }
                    else if (rankFilter == "personality" && !string.IsNullOrEmpty(personalityId))
                    {
                        string rowPers = row["personalityId"]?.ToString() ?? "";
                        if (rowPers != personalityId) continue;
                    }

                    filteredRank++;
                    if (count >= 10) continue; // still count for rank but don't add to display

                    string nickname = row["nickname"]?.ToString();
                    string name = row["name"]?.ToString();
                    string displayName = !string.IsNullOrWhiteSpace(nickname) ? nickname : name;
                    int xp = row["XP"] == DBNull.Value ? 0 : Convert.ToInt32(row["XP"]);
                    string levelName = CurrentLanguage == "BM"
                        ? (row["levelNameBM"]?.ToString() ?? row["levelNameEN"]?.ToString() ?? "—")
                        : (row["levelNameEN"]?.ToString() ?? "—");
                    int badges = Convert.ToInt32(row["badgeCount"]);
                    bool isCurrentUser = row["studentId"].ToString() == studentId;
                    string initial = !string.IsNullOrWhiteSpace(displayName)
                        ? displayName[0].ToString().ToUpper() : "S";

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

                // 7b. Build Top 3 Podium
                BuildPodium(dt, studentId);

                // 8. If logged-in student is NOT in top 10, show "Your Position" card
                if (myRank > 10)
                {
                    pnlYourPosition.Visible = true;
                    litYourPosRank.Text = "#" + myRank.ToString();
                    litYourPosName.Text = HttpUtility.HtmlEncode(myName);
                    litYourPosXP.Text = myXP.ToString("N0") + " XP";
                }

                // 9. Set motivational message
                litMotivateMsg.Text = GetMotivationalMessage(myRank);
            }
        }

        // ── Build Top 3 Podium ───────────────────────────────────────
        private void BuildPodium(DataTable dt, string currentStudentId)
        {
            if (dt.Rows.Count == 0) { litPodium.Text = ""; return; }

            // Get top 3 rows (already ordered by rankPos)
            var top3 = new List<DataRow>();
            for (int i = 0; i < Math.Min(3, dt.Rows.Count); i++) top3.Add(dt.Rows[i]);

            // Build podium in visual order: #2, #1, #3
            string html = "<div class=\"rk-podium\">";

            // Render in order: second (index 1), first (index 0), third (index 2)
            int[] order = top3.Count >= 3 ? new[] { 1, 0, 2 } : top3.Count == 2 ? new[] { 1, 0 } : new[] { 0 };
            string[] classes = { "first", "second", "third" };

            foreach (int idx in order)
            {
                if (idx >= top3.Count) continue;
                var row = top3[idx];
                int rank = idx + 1;
                string placeClass = classes[idx];
                string nickname = row["nickname"]?.ToString();
                string name = row["name"]?.ToString();
                string displayName = !string.IsNullOrWhiteSpace(nickname) ? nickname : name;
                string initial = !string.IsNullOrWhiteSpace(displayName) ? displayName[0].ToString().ToUpper() : "S";
                int xp = row["XP"] == DBNull.Value ? 0 : Convert.ToInt32(row["XP"]);
                bool isMe = row["studentId"].ToString() == currentStudentId;

                html += "<div class=\"rk-podium-player " + placeClass + "\">";
                if (rank == 1) html += "<div class=\"rk-podium-crown\"><i class=\"bi bi-trophy-fill\"></i></div>";
                if (isMe) html += "<div class=\"rk-podium-you\">" + T("You", "Anda") + "</div>";
                html += "<div class=\"rk-podium-avatar\">" + HttpUtility.HtmlEncode(initial) + "</div>";
                html += "<div class=\"rk-podium-name\">" + HttpUtility.HtmlEncode(displayName) + "</div>";
                html += "<div class=\"rk-podium-xp\">" + xp.ToString("N0") + " XP</div>";
                html += "<div class=\"rk-podium-block\"><span>" + rank + "</span></div>";
                html += "</div>";
            }

            html += "</div>";
            litPodium.Text = html;
        }

        // ── Get student ID from userId ────────────────────────────────
        private string GetStudentId(SqlConnection conn, string userId)
        {
            const string sql = "SELECT studentId FROM Student WHERE userId = @userId";
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                object result = cmd.ExecuteScalar();
                return result != null && result != DBNull.Value ? result.ToString() : null;
            }
        }

        // ── Filter click handler ──────────────────────────────────────
        protected void btnFilter_Click(object sender, EventArgs e)
        {
            var btn = (System.Web.UI.WebControls.LinkButton)sender;
            ViewState["RankFilter"] = btn.CommandArgument;
            InitLang();
            SetLabels();
            LoadPage();

            // Update active chip styles
            string filter = btn.CommandArgument;
            btnFilterAll.CssClass = filter == "all" ? "rk-filter-chip active" : "rk-filter-chip";
            btnFilterLevel.CssClass = filter == "level" ? "rk-filter-chip active" : "rk-filter-chip";
            btnFilterPers.CssClass = filter == "personality" ? "rk-filter-chip active" : "rk-filter-chip";
        }

        // ── Motivational message based on rank ────────────────────────
        private string GetMotivationalMessage(int rank)
        {
            if (rank == 1)
                return T("You're leading the leaderboard! 🥇",
                         "Anda mendahului papan kedudukan! 🥇");
            if (rank <= 3)
                return T("You're in the top 3. Amazing work! 🥈",
                         "Anda berada dalam 3 teratas. Hebat! 🥈");
            if (rank <= 10)
                return T("You're in the top 10. Keep going! 🌟",
                         "Anda berada dalam 10 teratas. Teruskan usaha! 🌟");

            return T("Every lesson gives you XP. Keep learning and your rank will improve. 💪",
                     "Setiap pelajaran memberi XP. Teruskan belajar dan kedudukan anda akan meningkat. 💪");
        }

        // ── Rank CSS class helper (used in aspx markup) ───────────────
        protected string GetRankClass(int rank)
        {
            switch (rank)
            {
                case 1: return "rk-board-rank rk-gold";
                case 2: return "rk-board-rank rk-silver";
                case 3: return "rk-board-rank rk-bronze";
                default: return "rk-board-rank rk-normal";
            }
        }

        // ── Empty state when no data ──────────────────────────────────
        private void SetEmptyState()
        {
            litHeroRank.Text = T("My Ranking", "Kedudukan Saya");
            litHeroXP.Text = "0 XP";
            litHeroLevel.Text = T("Level: —", "Tahap: —");
            litPersonalName.Text = "—";
            litPersonalRank.Text = "#—";
            litPersonalXP.Text = "0";
            litPersonalLevel.Text = "—";
            litPersonalBadges.Text = "0";
            litMotivateMsg.Text = T("Every lesson gives you XP. Keep learning and your rank will improve.",
                                    "Setiap pelajaran memberi XP. Teruskan belajar dan kedudukan anda akan meningkat.");
        }

        // ── Table existence check ─────────────────────────────────────
        private static bool Tbl(SqlConnection conn, string tableName)
        {
            const string sql = @"
                SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
                WHERE TABLE_NAME = @tableName
                AND TABLE_TYPE = 'BASE TABLE'";
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@tableName", tableName);
                return (int)cmd.ExecuteScalar() > 0;
            }
        }
    }
}
