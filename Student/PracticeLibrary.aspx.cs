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
        private string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString; }
        }

        public string CurrentLanguage = "EN";

        public string T(string en, string bm)
        {
            if (CurrentLanguage == "BM")
            {
                return bm;
            }
            return en;
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
            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();
                ddlLevel.Items.Clear();
                ddlLevel.Items.Add(new ListItem(T("All Levels", "Semua Tahap"), ""));
                if (Tbl(connection, "Level"))
                {
                    string sqlLevel;
                    if (CurrentLanguage == "BM")
                    {
                        sqlLevel = "SELECT levelId, levelNameBM AS levelName FROM Level ORDER BY levelId";
                    }
                    else
                    {
                        sqlLevel = "SELECT levelId, levelNameEN AS levelName FROM Level ORDER BY levelId";
                    }
                    using (SqlCommand command = new SqlCommand(sqlLevel, connection))
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            ddlLevel.Items.Add(new ListItem(reader["levelName"].ToString(), reader["levelId"].ToString()));
                        }
                    }
                }
                ddlUnit.Items.Clear();
                ddlUnit.Items.Add(new ListItem(T("All Units", "Semua Unit"), ""));
                if (Tbl(connection, "Unit"))
                {
                    string sqlUnit;
                    if (CurrentLanguage == "BM")
                    {
                        sqlUnit = "SELECT unitId, unitNameBM AS unitName FROM Unit ORDER BY orderNo";
                    }
                    else
                    {
                        sqlUnit = "SELECT unitId, unitNameEN AS unitName FROM Unit ORDER BY orderNo";
                    }
                    using (SqlCommand command = new SqlCommand(sqlUnit, connection))
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            ddlUnit.Items.Add(new ListItem(reader["unitName"].ToString(), reader["unitId"].ToString()));
                        }
                    }
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
            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();
                if (!Tbl(connection, "Quiz"))
                {
                    pnlGrid.Visible = false;
                    pnlEmpty.Visible = true;
                    return;
                }

                string studentId = GetStudentId(connection);
                bool hasQuestion = Tbl(connection, "Question");
                bool hasResult = Tbl(connection, "QuizResult");

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

                List<SqlParameter> parameters = new List<SqlParameter>();
                if (!string.IsNullOrEmpty(studentId))
                {
                    parameters.Add(new SqlParameter("@studentId", studentId));
                }

                string filterLevel = ddlLevel.SelectedValue;
                if (!string.IsNullOrEmpty(filterLevel))
                {
                    sql += " AND q.levelId = @filterLevel";
                    parameters.Add(new SqlParameter("@filterLevel", filterLevel));
                }
                string filterUnit = ddlUnit.SelectedValue;
                if (!string.IsNullOrEmpty(filterUnit))
                {
                    sql += " AND q.unitId = @filterUnit";
                    parameters.Add(new SqlParameter("@filterUnit", filterUnit));
                }
                string filterLang = ddlLanguage.SelectedValue;
                if (!string.IsNullOrEmpty(filterLang))
                {
                    if (filterLang == "BOTH")
                    {
                        sql += " AND q.language = 'BOTH'";
                    }
                    else
                    {
                        sql += " AND (q.language = @filterLang OR q.language = 'BOTH')";
                        parameters.Add(new SqlParameter("@filterLang", filterLang));
                    }
                }
                sql += " ORDER BY q.quizTitleEN";

                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    command.Parameters.AddRange(parameters.ToArray());
                    SqlDataAdapter adapter = new SqlDataAdapter(command);
                    DataTable dataTable = new DataTable();
                    adapter.Fill(dataTable);
                    if (dataTable.Rows.Count == 0)
                    {
                        pnlGrid.Visible = false;
                        pnlEmpty.Visible = true;
                        return;
                    }

                    pnlGrid.Visible = true;
                    pnlEmpty.Visible = false;
                    bool isBM = CurrentLanguage == "BM";
                    string startText = T("Start Practice", "Mula Latihan");
                    string attemptedText = T("Attempted", "Telah Dijawab");
                    string notAttemptedText = T("Not Attempted", "Belum Dijawab");
                    string bestLabel = T("Best:", "Terbaik:");
                    string questionsLabel = T("questions", "soalan");

                    List<object> quizList = new List<object>();
                    foreach (DataRow row in dataTable.Rows)
                    {
                        string quizLang;
                        if (row["language"] != DBNull.Value)
                        {
                            quizLang = row["language"].ToString();
                        }
                        else
                        {
                            quizLang = "EN";
                        }

                        string titleEN;
                        if (row["quizTitleEN"] != DBNull.Value)
                        {
                            titleEN = row["quizTitleEN"].ToString();
                        }
                        else
                        {
                            titleEN = "";
                        }

                        string titleBM;
                        if (row["quizTitleBM"] != DBNull.Value)
                        {
                            titleBM = row["quizTitleBM"].ToString();
                        }
                        else
                        {
                            titleBM = "";
                        }

                        string title;
                        if (quizLang == "EN")
                        {
                            title = titleEN;
                        }
                        else if (quizLang == "BM")
                        {
                            if (!string.IsNullOrWhiteSpace(titleBM))
                            {
                                title = titleBM;
                            }
                            else
                            {
                                title = titleEN;
                            }
                        }
                        else
                        {
                            if (isBM)
                            {
                                if (!string.IsNullOrWhiteSpace(titleBM))
                                {
                                    title = titleBM;
                                }
                                else
                                {
                                    title = titleEN;
                                }
                            }
                            else
                            {
                                if (!string.IsNullOrWhiteSpace(titleEN))
                                {
                                    title = titleEN;
                                }
                                else
                                {
                                    title = titleBM;
                                }
                            }
                        }
                        if (string.IsNullOrWhiteSpace(title))
                        {
                            if (!string.IsNullOrWhiteSpace(titleEN))
                            {
                                title = titleEN;
                            }
                            else
                            {
                                title = titleBM;
                            }
                        }

                        string levelName;
                        if (isBM)
                        {
                            if (row["levelNameBM"] != DBNull.Value)
                            {
                                levelName = row["levelNameBM"].ToString();
                            }
                            else if (row["levelNameEN"] != null)
                            {
                                levelName = row["levelNameEN"].ToString();
                            }
                            else
                            {
                                levelName = "";
                            }
                        }
                        else
                        {
                            if (row["levelNameEN"] != null)
                            {
                                levelName = row["levelNameEN"].ToString();
                            }
                            else
                            {
                                levelName = "";
                            }
                        }

                        string unitName;
                        if (isBM)
                        {
                            if (row["unitNameBM"] != DBNull.Value)
                            {
                                unitName = row["unitNameBM"].ToString();
                            }
                            else if (row["unitNameEN"] != null)
                            {
                                unitName = row["unitNameEN"].ToString();
                            }
                            else
                            {
                                unitName = "";
                            }
                        }
                        else
                        {
                            if (row["unitNameEN"] != null)
                            {
                                unitName = row["unitNameEN"].ToString();
                            }
                            else
                            {
                                unitName = "";
                            }
                        }

                        int questionCount;
                        if (row["questionCount"] != DBNull.Value)
                        {
                            questionCount = Convert.ToInt32(row["questionCount"]);
                        }
                        else
                        {
                            questionCount = 0;
                        }

                        int attemptCount;
                        if (row["attemptCount"] != DBNull.Value)
                        {
                            attemptCount = Convert.ToInt32(row["attemptCount"]);
                        }
                        else
                        {
                            attemptCount = 0;
                        }

                        bool isAttempted = attemptCount > 0;
                        string bestScoreDisplay = "";
                        if (isAttempted && row["bestScore"] != DBNull.Value)
                        {
                            bestScoreDisplay = bestLabel + " " + Convert.ToInt32(row["bestScore"]) + "%";
                        }

                        string lang;
                        if (row["language"] != DBNull.Value)
                        {
                            lang = row["language"].ToString();
                        }
                        else
                        {
                            lang = "EN";
                        }
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
            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();
                if (!Tbl(connection, "AILearningAnalysis"))
                {
                    pnlRecommend.Visible = true;
                    litRecommendTitle.Text = T("Personalised Recommendations", "Cadangan Peribadi");
                    litRecommendText.Text = T("Complete more quizzes to unlock personalised recommendations.", "Selesaikan lebih banyak kuiz untuk membuka cadangan peribadi.");
                    return;
                }

                string studentId = GetStudentId(connection);
                if (string.IsNullOrEmpty(studentId))
                {
                    pnlRecommend.Visible = true;
                    litRecommendTitle.Text = T("Personalised Recommendations", "Cadangan Peribadi");
                    litRecommendText.Text = T("Complete more quizzes to unlock personalised recommendations.", "Selesaikan lebih banyak kuiz untuk membuka cadangan peribadi.");
                    return;
                }

                const string sql = "SELECT TOP 1 weakTopics FROM AILearningAnalysis WHERE studentId = @s AND isLatest = 1";
                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    command.Parameters.AddWithValue("@s", studentId);
                    object result = command.ExecuteScalar();
                    pnlRecommend.Visible = true;
                    if (result != null && result != DBNull.Value && !string.IsNullOrWhiteSpace(result.ToString()))
                    {
                        litRecommendTitle.Text = T("Recommended based on your weak topics:", "Dicadangkan berdasarkan topik lemah anda:");
                        litRecommendText.Text = HttpUtility.HtmlEncode(result.ToString());
                    }
                    else
                    {
                        litRecommendTitle.Text = T("Personalised Recommendations", "Cadangan Peribadi");
                        litRecommendText.Text = T("Complete more quizzes to unlock personalised recommendations.", "Selesaikan lebih banyak kuiz untuk membuka cadangan peribadi.");
                    }
                }
            }
        }

        protected void Filter_Changed(object sender, EventArgs e)
        {
            InitLang();
            SetLabels();
            LoadRecommendation();
            LoadQuizzes();
        }

        private string GetStudentId(SqlConnection conn)
        {
            if (!Tbl(conn, "Student"))
            {
                return null;
            }
            string userId = Session["userId"] as string;
            if (string.IsNullOrEmpty(userId))
            {
                return null;
            }
            const string sql = "SELECT studentId FROM Student WHERE userId = @userId";
            using (SqlCommand command = new SqlCommand(sql, conn))
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

        private static bool Tbl(SqlConnection conn, string tableName)
        {
            const string sql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @tableName AND TABLE_TYPE = 'BASE TABLE'";
            using (SqlCommand command = new SqlCommand(sql, conn))
            {
                command.Parameters.AddWithValue("@tableName", tableName);
                return (int)command.ExecuteScalar() > 0;
            }
        }
    }
}
