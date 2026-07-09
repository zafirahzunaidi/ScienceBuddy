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
    public partial class PracticeLibrary1 : Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        public string CurrentLanguage = "EN";

        public string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

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
                LoadRecommendation();
                LoadQuizzes();
            }
        }

        private void InitLang()
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
                        object result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        { lang = result.ToString(); Session["preferredLanguage"] = lang; CurrentLanguage = lang; return; }
                    }
                }
                catch (SqlException) { }
            }
            CurrentLanguage = "EN"; Session["preferredLanguage"] = "EN";
        }

        private void SetLabels()
        {
            litPageTitle.Text = T("Practice Library", "Perpustakaan Latihan");
            litTitle.Text = T("Practice Library", "Perpustakaan Latihan");
            litSubtitle.Text = T("Try extra quizzes to improve your Science skills.",
                                 "Cuba kuiz tambahan untuk meningkatkan kemahiran Sains anda.");
            litEmptyTitle.Text = T("No practice quizzes available", "Tiada kuiz latihan tersedia");
            litEmptyDesc.Text = T("No practice quizzes are available yet.", "Tiada kuiz latihan tersedia buat masa ini.");
            litEmptyBtn.Text = T("Back to Dashboard", "Kembali ke Papan Pemuka");
        }

        private void BuildFilters()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                ddlLevel.Items.Clear();
                ddlLevel.Items.Add(new ListItem(T("All Levels", "Semua Tahap"), ""));
                if (Tbl(conn, "Level"))
                {
                    string sqlLevel = CurrentLanguage == "BM"
                        ? "SELECT levelId, levelNameBM AS levelName FROM Level ORDER BY levelId"
                        : "SELECT levelId, levelNameEN AS levelName FROM Level ORDER BY levelId";
                    using (var cmd = new SqlCommand(sqlLevel, conn))
                    using (var rdr = cmd.ExecuteReader())
                    { while (rdr.Read()) ddlLevel.Items.Add(new ListItem(rdr["levelName"].ToString(), rdr["levelId"].ToString())); }
                }
                ddlUnit.Items.Clear();
                ddlUnit.Items.Add(new ListItem(T("All Units", "Semua Unit"), ""));
                if (Tbl(conn, "Unit"))
                {
                    string sqlUnit = CurrentLanguage == "BM"
                        ? "SELECT unitId, unitNameBM AS unitName FROM Unit ORDER BY orderNo"
                        : "SELECT unitId, unitNameEN AS unitName FROM Unit ORDER BY orderNo";
                    using (var cmd = new SqlCommand(sqlUnit, conn))
                    using (var rdr = cmd.ExecuteReader())
                    { while (rdr.Read()) ddlUnit.Items.Add(new ListItem(rdr["unitName"].ToString(), rdr["unitId"].ToString())); }
                }
                ddlSubtopic.Items.Clear();
                ddlSubtopic.Items.Add(new ListItem(T("All Subtopics", "Semua Subtopik"), ""));
                ddlSubtopic.Visible = false;
                ddlLanguage.Items.Clear();
                ddlLanguage.Items.Add(new ListItem(T("All Languages", "Semua Bahasa"), ""));
                ddlLanguage.Items.Add(new ListItem("English", "EN"));
                ddlLanguage.Items.Add(new ListItem("Bahasa Melayu", "BM"));
                ddlLanguage.Items.Add(new ListItem(T("Both", "Kedua-dua"), "BOTH"));
            }
        }

        private void LoadQuizzes()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                if (!Tbl(conn, "Quiz")) { pnlGrid.Visible = false; pnlEmpty.Visible = true; return; }

                string studentId = GetStudentId(conn);
                bool hasQuestion = Tbl(conn, "Question");
                bool hasResult = Tbl(conn, "QuizResult");

                string sql = @"SELECT q.quizId, q.quizTitleEN, q.quizTitleBM, q.language,
                        l.levelNameEN, l.levelNameBM, l.levelId,
                        u.unitNameEN, u.unitNameBM, u.unitId"
                    + (hasQuestion ? ",(SELECT COUNT(*) FROM Question WHERE quizId = q.quizId) AS questionCount" : ",0 AS questionCount")
                    + (hasResult && !string.IsNullOrEmpty(studentId)
                        ? ",(SELECT TOP 1 score FROM QuizResult WHERE quizId = q.quizId AND studentId = @studentId ORDER BY score DESC) AS bestScore,(SELECT COUNT(*) FROM QuizResult WHERE quizId = q.quizId AND studentId = @studentId) AS attemptCount"
                        : ",NULL AS bestScore,0 AS attemptCount")
                    + @" FROM Quiz q
                    LEFT JOIN Level l ON l.levelId = q.levelId
                    LEFT JOIN Unit u ON u.unitId = q.unitId
                    WHERE q.quizType = 'Practice' AND (q.status = 'Approved' OR q.status IS NULL)";

                var parameters = new List<SqlParameter>();
                if (!string.IsNullOrEmpty(studentId)) parameters.Add(new SqlParameter("@studentId", studentId));

                string filterLevel = ddlLevel.SelectedValue;
                if (!string.IsNullOrEmpty(filterLevel)) { sql += " AND q.levelId = @filterLevel"; parameters.Add(new SqlParameter("@filterLevel", filterLevel)); }
                string filterUnit = ddlUnit.SelectedValue;
                if (!string.IsNullOrEmpty(filterUnit)) { sql += " AND q.unitId = @filterUnit"; parameters.Add(new SqlParameter("@filterUnit", filterUnit)); }
                string filterLang = ddlLanguage.SelectedValue;
                if (!string.IsNullOrEmpty(filterLang))
                {
                    if (filterLang == "BOTH") sql += " AND q.language = 'BOTH'";
                    else { sql += " AND (q.language = @filterLang OR q.language = 'BOTH')"; parameters.Add(new SqlParameter("@filterLang", filterLang)); }
                }
                sql += " ORDER BY q.quizTitleEN";

                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddRange(parameters.ToArray());
                    var da = new SqlDataAdapter(cmd);
                    var dt = new DataTable();
                    da.Fill(dt);
                    if (dt.Rows.Count == 0) { pnlGrid.Visible = false; pnlEmpty.Visible = true; return; }

                    pnlGrid.Visible = true; pnlEmpty.Visible = false;
                    bool isBM = CurrentLanguage == "BM";
                    string startText = T("Start Practice", "Mula Latihan");
                    string attemptedText = T("Attempted", "Telah Dijawab");
                    string notAttemptedText = T("Not Attempted", "Belum Dijawab");
                    string bestLabel = T("Best:", "Terbaik:");
                    string questionsLabel = T("questions", "soalan");

                    var quizList = new List<object>();
                    foreach (DataRow row in dt.Rows)
                    {
                        string quizLang = row["language"] != DBNull.Value ? row["language"].ToString() : "EN";
                        string titleEN = row["quizTitleEN"] != DBNull.Value ? row["quizTitleEN"].ToString() : "";
                        string titleBM = row["quizTitleBM"] != DBNull.Value ? row["quizTitleBM"].ToString() : "";
                        string title;
                        if (quizLang == "EN") title = titleEN;
                        else if (quizLang == "BM") title = !string.IsNullOrWhiteSpace(titleBM) ? titleBM : titleEN;
                        else title = isBM ? (!string.IsNullOrWhiteSpace(titleBM) ? titleBM : titleEN) : (!string.IsNullOrWhiteSpace(titleEN) ? titleEN : titleBM);
                        if (string.IsNullOrWhiteSpace(title)) title = !string.IsNullOrWhiteSpace(titleEN) ? titleEN : titleBM;

                        string levelName = isBM ? (row["levelNameBM"] != DBNull.Value ? row["levelNameBM"].ToString() : row["levelNameEN"]?.ToString() ?? "") : (row["levelNameEN"]?.ToString() ?? "");
                        string unitName = isBM ? (row["unitNameBM"] != DBNull.Value ? row["unitNameBM"].ToString() : row["unitNameEN"]?.ToString() ?? "") : (row["unitNameEN"]?.ToString() ?? "");
                        int questionCount = row["questionCount"] != DBNull.Value ? Convert.ToInt32(row["questionCount"]) : 0;
                        int attemptCount = row["attemptCount"] != DBNull.Value ? Convert.ToInt32(row["attemptCount"]) : 0;
                        bool isAttempted = attemptCount > 0;
                        string bestScoreDisplay = "";
                        if (isAttempted && row["bestScore"] != DBNull.Value) bestScoreDisplay = bestLabel + " " + Convert.ToInt32(row["bestScore"]) + "%";
                        string lang = row["language"] != DBNull.Value ? row["language"].ToString() : "EN";
                        string quizId = row["quizId"].ToString();

                        quizList.Add(new
                        {
                            Title = HttpUtility.HtmlEncode(title),
                            Level = HttpUtility.HtmlEncode(levelName),
                            Unit = HttpUtility.HtmlEncode(unitName),
                            Language = lang,
                            QuestionCount = questionCount,
                            QuestionsLabel = questionsLabel,
                            IsAttempted = isAttempted,
                            BestScore = bestScoreDisplay,
                            ScoreDisplay = isAttempted ? bestScoreDisplay : "",
                            BadgeClass = isAttempted ? "st-practice-badge-attempted" : "st-practice-badge-new",
                            StatusText = isAttempted ? attemptedText : notAttemptedText,
                            BtnText = startText,
                            Url = ResolveUrl("~/Student/Quiz.aspx?quizId=" + HttpUtility.UrlEncode(quizId))
                        });
                    }
                    rptQuizzes.DataSource = quizList;
                    rptQuizzes.DataBind();
                }
            }
        }

        private void LoadRecommendation()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                if (!Tbl(conn, "AILearningAnalysis"))
                { pnlRecommend.Visible = true; litRecommendTitle.Text = T("💡 Personalised Recommendations","💡 Cadangan Peribadi"); litRecommendText.Text = T("Complete more quizzes to unlock personalised recommendations.","Selesaikan lebih banyak kuiz untuk membuka cadangan peribadi."); return; }

                string studentId = GetStudentId(conn);
                if (string.IsNullOrEmpty(studentId))
                { pnlRecommend.Visible = true; litRecommendTitle.Text = T("💡 Personalised Recommendations","💡 Cadangan Peribadi"); litRecommendText.Text = T("Complete more quizzes to unlock personalised recommendations.","Selesaikan lebih banyak kuiz untuk membuka cadangan peribadi."); return; }

                const string sql = "SELECT TOP 1 weakTopics FROM AILearningAnalysis WHERE studentId = @s AND isLatest = 1";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@s", studentId);
                    object result = cmd.ExecuteScalar();
                    pnlRecommend.Visible = true;
                    if (result != null && result != DBNull.Value && !string.IsNullOrWhiteSpace(result.ToString()))
                    { litRecommendTitle.Text = T("🎯 Recommended based on your weak topics:","🎯 Dicadangkan berdasarkan topik lemah anda:"); litRecommendText.Text = HttpUtility.HtmlEncode(result.ToString()); }
                    else
                    { litRecommendTitle.Text = T("💡 Personalised Recommendations","💡 Cadangan Peribadi"); litRecommendText.Text = T("Complete more quizzes to unlock personalised recommendations.","Selesaikan lebih banyak kuiz untuk membuka cadangan peribadi."); }
                }
            }
        }

        protected void Filter_Changed(object sender, EventArgs e)
        {
            InitLang(); SetLabels(); LoadRecommendation(); LoadQuizzes();
        }

        private string GetStudentId(SqlConnection conn)
        {
            if (!Tbl(conn, "Student")) return null;
            string userId = Session["userId"] as string;
            if (string.IsNullOrEmpty(userId)) return null;
            const string sql = "SELECT studentId FROM Student WHERE userId = @userId";
            using (var cmd = new SqlCommand(sql, conn))
            { cmd.Parameters.AddWithValue("@userId", userId); object result = cmd.ExecuteScalar(); return result != null && result != DBNull.Value ? result.ToString() : null; }
        }

        private static bool Tbl(SqlConnection conn, string tableName)
        {
            const string sql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @tableName AND TABLE_TYPE = 'BASE TABLE'";
            using (var cmd = new SqlCommand(sql, conn))
            { cmd.Parameters.AddWithValue("@tableName", tableName); return (int)cmd.ExecuteScalar() > 0; }
        }
    }
}
