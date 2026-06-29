using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace ScienceBuddy.Student
{
    public partial class MyLearning : Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        private string CurrentLanguage = "EN";
        private string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null ||
                Session["role"].ToString() != "Student")
            {
                Response.Redirect("~/Login.aspx", false);
                return;
            }

            var master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                InitLanguage();
                SetLabels();
                LoadPage();
            }
        }

        private void InitLanguage()
        {
            string lang = Session["preferredLanguage"] as string;
            if (!string.IsNullOrEmpty(lang)) { CurrentLanguage = lang; return; }

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
                        object r = cmd.ExecuteScalar();
                        if (r != null && r != DBNull.Value)
                        { lang = r.ToString(); Session["preferredLanguage"] = lang; CurrentLanguage = lang; return; }
                    }
                }
                catch (SqlException) { }
            }
            CurrentLanguage = "EN"; Session["preferredLanguage"] = "EN";
        }

        private void SetLabels()
        {
            litPageTitle.Text = T("My Learning", "Pembelajaran Saya");
            litTitle.Text     = T("My Learning", "Pembelajaran Saya");
            litSubtitle.Text  = T("Choose your level and continue your science journey.",
                                  "Pilih tahap anda dan teruskan perjalanan Sains.");
            litEmptyTitle.Text = T("No learning content yet", "Tiada kandungan pembelajaran lagi");
            litEmptyDesc.Text  = T("Learning levels will appear here once available.",
                                   "Tahap pembelajaran akan muncul di sini apabila tersedia.");
            litQuizEmpty.Text  = T("Level assessment is not available yet.",
                                   "Penilaian tahap belum tersedia lagi.");
        }

        private void LoadPage()
        {
            string userId = Session["userId"].ToString();

            if (!TableExists("Level") || !TableExists("Student"))
            {
                pnlEmpty.Visible = true;
                pnlUnits.Visible = false;
                return;
            }

            // Get student's current level
            string currentLevelId = null;
            string studentId = null;
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                const string sStu = "SELECT studentId, currentlevelId FROM Student WHERE userId = @userId";
                using (var cmd = new SqlCommand(sStu, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    using (var rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            studentId = rdr["studentId"].ToString();
                            currentLevelId = rdr["currentlevelId"]?.ToString();
                        }
                    }
                }

                if (string.IsNullOrEmpty(currentLevelId)) currentLevelId = "LV001";

                // Load all levels
                LoadLevels(conn, currentLevelId);

                // Load units for current level
                LoadUnits(conn, currentLevelId, studentId);

                // Load level quiz
                LoadLevelQuiz(conn, currentLevelId);
            }
        }

        private void LoadLevels(SqlConnection conn, string currentLevelId)
        {
            const string sql = "SELECT levelId, levelNameEN, levelNameBM, levelDescriptionEN, levelDescriptionBM FROM Level ORDER BY levelId";
            var dt = new DataTable();
            using (var cmd = new SqlCommand(sql, conn))
            { var da = new SqlDataAdapter(cmd); da.Fill(dt); }

            if (dt.Rows.Count == 0) { pnlEmpty.Visible = true; return; }

            int currentOrder = GetLevelOrder(currentLevelId);
            bool isBM = CurrentLanguage == "BM";
            var list = new List<object>();
            string[] icons = { "🌱", "🔬", "🚀" };
            string[] iconBgs = { "#DCFCE7", "#DBEAFE", "#F3E8FF" };
            string[] iconColors = { "#15803D", "#1D4ED8", "#7C3AED" };

            for (int i = 0; i < dt.Rows.Count; i++)
            {
                var row = dt.Rows[i];
                string lid  = row["levelId"].ToString();
                int order   = GetLevelOrder(lid);
                bool isCurrent = lid == currentLevelId;
                bool isLocked  = order > currentOrder;
                bool isUnlocked = order < currentOrder;

                string name = isBM ? row["levelNameBM"].ToString() : row["levelNameEN"].ToString();
                if (string.IsNullOrWhiteSpace(name)) name = row["levelNameEN"].ToString();
                string desc = isBM ? row["levelDescriptionBM"].ToString() : row["levelDescriptionEN"].ToString();
                if (string.IsNullOrWhiteSpace(desc)) desc = row["levelDescriptionEN"].ToString();

                string cssClass = isCurrent ? "current" : (isLocked ? "locked" : "");
                string badgeClass = isCurrent ? "ml-badge-current" : (isLocked ? "ml-badge-locked" : "ml-badge-unlocked");
                string badgeText = isCurrent ? T("Current", "Semasa")
                    : (isLocked ? T("Locked", "Dikunci") : T("Unlocked", "Dibuka"));
                string btnText = isLocked ? T("Locked", "Dikunci") : T("View Level", "Lihat Tahap");
                string btnClass = isLocked ? "sb-btn sb-btn-ghost sb-btn-sm" : "sb-btn sb-btn-primary sb-btn-sm";
                string linkUrl = isLocked ? "#" : ResolveUrl("~/Student/MyLearning.aspx?level=" + lid);

                list.Add(new {
                    CssClass = cssClass, Name = HttpUtility.HtmlEncode(name),
                    Description = HttpUtility.HtmlEncode(desc),
                    Icon = i < icons.Length ? icons[i] : "📖",
                    IconBg = i < iconBgs.Length ? iconBgs[i] : "#F0F7FF",
                    IconColor = i < iconColors.Length ? iconColors[i] : "#2563EB",
                    BadgeClass = badgeClass, BadgeText = badgeText,
                    BtnText = btnText, BtnClass = btnClass,
                    LinkUrl = linkUrl, IsLocked = isLocked
                });
            }

            rptLevels.DataSource = list;
            rptLevels.DataBind();
        }

        private void LoadUnits(SqlConnection conn, string levelId, string studentId)
        {
            // Use query param if provided and accessible
            string qLevel = Request.QueryString["level"];
            if (!string.IsNullOrEmpty(qLevel) && GetLevelOrder(qLevel) <= GetLevelOrder(levelId))
                levelId = qLevel;

            if (!TableExists("Unit"))
            {
                pnlUnits.Visible = false;
                return;
            }

            bool isBM = CurrentLanguage == "BM";
            litUnitsTitle.Text = T("Units", "Unit");

            const string sql = @"
                SELECT u.unitId, u.unitNameEN, u.unitNameBM,
                       u.unitDescriptionEN, u.unitDescriptionBM, u.orderNo,
                       (SELECT COUNT(*) FROM Subtopic WHERE unitId = u.unitId) AS subtopicCount,
                       (SELECT COUNT(*) FROM Lesson ls
                        JOIN Subtopic st ON st.subtopicId = ls.subtopicId
                        WHERE st.unitId = u.unitId) AS lessonCount
                FROM Unit u
                WHERE u.levelId = @levelId
                ORDER BY u.orderNo";

            var dt = new DataTable();
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@levelId", levelId);
                var da = new SqlDataAdapter(cmd);
                da.Fill(dt);
            }

            if (dt.Rows.Count == 0)
            {
                pnlUnits.Visible = false;
                return;
            }

            // Get lesson progress for this student
            var completedMap = new Dictionary<string, int>(); // unitId -> completed lessons
            if (!string.IsNullOrEmpty(studentId) && TableExists("LessonProgress"))
            {
                const string pSql = @"
                    SELECT st.unitId, COUNT(*) AS cnt
                    FROM LessonProgress lp
                    JOIN Lesson ls ON ls.lessonId = lp.lessonId
                    JOIN Subtopic st ON st.subtopicId = ls.subtopicId
                    WHERE lp.studentId = @studentId AND lp.isCompleted = 1
                    GROUP BY st.unitId";
                using (var cmd2 = new SqlCommand(pSql, conn))
                {
                    cmd2.Parameters.AddWithValue("@studentId", studentId);
                    using (var rdr = cmd2.ExecuteReader())
                    {
                        while (rdr.Read())
                            completedMap[rdr["unitId"].ToString()] = Convert.ToInt32(rdr["cnt"]);
                    }
                }
            }

            var list = new List<object>();
            foreach (DataRow row in dt.Rows)
            {
                string unitId = row["unitId"].ToString();
                string name = isBM ? row["unitNameBM"].ToString() : row["unitNameEN"].ToString();
                if (string.IsNullOrWhiteSpace(name)) name = row["unitNameEN"].ToString();
                string desc = isBM ? row["unitDescriptionBM"].ToString() : row["unitDescriptionEN"].ToString();
                if (string.IsNullOrWhiteSpace(desc)) desc = row["unitDescriptionEN"].ToString();

                int subtopics = Convert.ToInt32(row["subtopicCount"]);
                int lessons   = Convert.ToInt32(row["lessonCount"]);
                int completed = completedMap.ContainsKey(unitId) ? completedMap[unitId] : 0;
                int pct = lessons > 0 ? Math.Min(completed * 100 / lessons, 100) : 0;

                list.Add(new {
                    Name = HttpUtility.HtmlEncode(name),
                    Description = HttpUtility.HtmlEncode(desc),
                    SubtopicCount = subtopics,
                    SubtopicLabel = T("subtopics", "subtopik"),
                    LessonCount = lessons,
                    LessonLabel = T("lessons", "pelajaran"),
                    ProgressPct = pct,
                    ProgressText = completed + "/" + lessons + " " + T("completed", "selesai"),
                    BtnText = T("View Unit", "Lihat Unit"),
                    LinkUrl = ResolveUrl("~/Student/UnitDetails.aspx?unitId=" + unitId)
                });
            }

            pnlUnits.Visible = true;
            rptUnits.DataSource = list;
            rptUnits.DataBind();
        }

        private void LoadLevelQuiz(SqlConnection conn, string levelId)
        {
            if (!TableExists("Quiz"))
            {
                pnlQuiz.Visible = false;
                pnlQuizEmpty.Visible = true;
                return;
            }

            bool isBM = CurrentLanguage == "BM";
            const string sql = @"
                SELECT TOP 1 quizId, quizTitleEN, quizTitleBM
                FROM Quiz
                WHERE levelId = @levelId AND quizType = 'Level'
                ORDER BY createdAt DESC";

            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@levelId", levelId);
                using (var rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        string title = isBM ? rdr["quizTitleBM"].ToString() : rdr["quizTitleEN"].ToString();
                        if (string.IsNullOrWhiteSpace(title)) title = rdr["quizTitleEN"].ToString();

                        pnlQuiz.Visible = true;
                        pnlQuizEmpty.Visible = false;
                        litQuizTitle.Text = HttpUtility.HtmlEncode(title);
                        litQuizSub.Text = T("Test your knowledge for this level",
                                            "Uji pengetahuan anda untuk tahap ini");
                        litQuizBtn.Text = T("Start Quiz", "Mula Kuiz");
                    }
                    else
                    {
                        pnlQuiz.Visible = false;
                        pnlQuizEmpty.Visible = true;
                    }
                }
            }
        }

        // ── Utilities ─────────────────────────────────────────────────
        private static int GetLevelOrder(string levelId)
        {
            switch (levelId)
            {
                case "LV001": return 1;
                case "LV002": return 2;
                case "LV003": return 3;
                default: return 0;
            }
        }

        private bool TableExists(string tableName)
        {
            const string sql = @"SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
                WHERE TABLE_NAME = @t AND TABLE_TYPE = 'BASE TABLE'";
            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@t", tableName);
                conn.Open();
                return (int)cmd.ExecuteScalar() > 0;
            }
        }
    }
}
