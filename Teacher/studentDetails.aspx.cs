using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Teacher
{
    public partial class studentDetails : Page
    {
        #region Properties

        protected string CurrentLanguage
        {
            get
            {
                string lang = Session["preferredLanguage"] as string;
                return string.IsNullOrEmpty(lang) ? "EN" : lang;
            }
        }

        /// <summary>
        /// Returns English or Bahasa Melayu text based on the current language preference.
        /// </summary>
        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        // Exposed to ASPX for progress bar width binding
        protected int LessonPct = 0, UnitPct = 0, LevelPct = 0;

        #endregion

        #region Page Lifecycle

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"]?.ToString() != "Teacher")
            {
                Response.Redirect("~/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            // AJAX endpoint for loading quiz answer details
            if (Request.QueryString["handler"] == "answers")
            {
                HandleAnswerRequest();
                return;
            }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                string studentId = (Request.QueryString["studentId"] ?? "").Trim();

                if (string.IsNullOrEmpty(studentId))
                {
                    ShowError(T("No student specified.", "Tiada pelajar dinyatakan."));
                    return;
                }

                LoadStudentDetails(studentId);
            }
        }

        #endregion

        #region AJAX Handlers

        private void HandleAnswerRequest()
        {
            Response.Clear();
            Response.ContentType = "text/html";

            string resultId = (Request.QueryString["resultId"] ?? "").Trim();
            if (string.IsNullOrEmpty(resultId))
            {
                Response.Write("<div class=\"tc-student-details-empty\">Invalid request.</div>");
                Response.End();
                return;
            }

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    var sb = new System.Text.StringBuilder();

                    using (var cmd = new SqlCommand(@"
                        SELECT qst.[questionTextEN], qst.[questionTextBM], qst.[questionType],
                               qst.[optionA_EN], qst.[optionA_BM], qst.[optionB_EN], qst.[optionB_BM],
                               qst.[optionC_EN], qst.[optionC_BM], qst.[optionD_EN], qst.[optionD_BM],
                               qa.[selectedAnswer], qst.[correctAnswer], qa.[isCorrect]
                        FROM dbo.[QuizAnswer] qa
                        INNER JOIN dbo.[Question] qst ON qst.[questionId] = qa.[questionId]
                        WHERE qa.[resultId] = @rid
                        ORDER BY qa.[answerId]", conn))
                    {
                        cmd.Parameters.AddWithValue("@rid", resultId);

                        using (var reader = cmd.ExecuteReader())
                        {
                            int questionNumber = 0;

                            while (reader.Read())
                            {
                                questionNumber++;
                                BuildAnswerCard(sb, reader, questionNumber);
                            }

                            if (questionNumber == 0)
                            {
                                sb.AppendFormat("<div class=\"tc-student-details-empty\">{0}</div>",
                                    T("No answer records found.", "Tiada rekod jawapan dijumpai."));
                            }
                        }
                    }

                    Response.Write(sb.ToString());
                }
            }
            catch
            {
                Response.Write("<div class=\"tc-student-details-empty\">" +
                    T("Error loading answers.", "Ralat memuatkan jawapan.") + "</div>");
            }

            Response.End();
        }

        #endregion

        #region Data Loading

        private void LoadStudentDetails(string studentId)
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // Basic student info
                    string studentName = "", levelName = "-";
                    using (var cmd = new SqlCommand(@"
                        SELECT s.[name], COALESCE(lv.[levelNameEN], '-') AS lvl
                        FROM dbo.[Student] s
                        INNER JOIN dbo.[User] u ON u.[userId] = s.[userId]
                        LEFT JOIN dbo.[Level] lv ON lv.[levelId] = s.[currentLevelId]
                        WHERE s.[studentId] = @sid AND u.[status] = 'Active'", conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", studentId);
                        using (var reader = cmd.ExecuteReader())
                        {
                            if (!reader.Read())
                            {
                                ShowError(T("Student not found.", "Pelajar tidak dijumpai."));
                                return;
                            }
                            studentName = reader["name"]?.ToString() ?? "Student";
                            levelName = reader["lvl"].ToString();
                        }
                    }

                    litName.Text = HttpUtility.HtmlEncode(studentName);
                    litStudentId.Text = HttpUtility.HtmlEncode(studentId);
                    litLevel.Text = HttpUtility.HtmlEncode(levelName);
                    litInitials.Text = HttpUtility.HtmlEncode(GetInitials(studentName));

                    // Lesson completion progress
                    int totalLessons = 0, completedLessons = 0;
                    using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[Lesson]", conn))
                        totalLessons = Convert.ToInt32(cmd.ExecuteScalar());

                    using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[LessonProgress] WHERE [studentId] = @s AND [isCompleted] = 1", conn))
                    {
                        cmd.Parameters.AddWithValue("@s", studentId);
                        completedLessons = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    litLessons.Text = completedLessons + " / " + totalLessons;
                    LessonPct = totalLessons > 0 ? (int)Math.Round((decimal)completedLessons / totalLessons * 100) : 0;

                    // Quiz averages
                    decimal unitQuizAverage = GetQuizAverage(conn, studentId, "Unit");
                    decimal levelQuizAverage = GetQuizAverage(conn, studentId, "Level");

                    litUnitAvg.Text = unitQuizAverage >= 0
                        ? unitQuizAverage.ToString("0.0") + "%"
                        : T("No Attempt", "Tiada Cubaan");
                    litLevelAvg.Text = levelQuizAverage >= 0
                        ? levelQuizAverage.ToString("0.0") + "%"
                        : T("No Attempt", "Tiada Cubaan");

                    UnitPct = unitQuizAverage >= 0 ? (int)Math.Round(unitQuizAverage) : 0;
                    LevelPct = levelQuizAverage >= 0 ? (int)Math.Round(levelQuizAverage) : 0;

                    // Lesson progress table
                    LoadLessonProgress(conn, studentId);

                    // Quiz result tables
                    BindQuiz(conn, studentId, "Unit", rptUnitQuiz, pnlUnitQuizTable, pnlUnitQuizEmpty);
                    BindQuiz(conn, studentId, "Level", rptLevelQuiz, pnlLevelQuizTable, pnlLevelQuizEmpty);

                    // Weak topics - quizzes where latest attempt is below pass mark
                    var weakTopicList = LoadWeakTopics(conn, studentId, out bool hasNoQuizAttempts);

                    // Certificates
                    var certificateList = LoadCertificates(conn, studentId);

                    // Performance summary panel
                    litInsLessons.Text = HttpUtility.HtmlEncode(completedLessons + " / " + totalLessons);

                    int weakUnitCount = 0, weakLevelCount = 0;
                    foreach (var weakItem in weakTopicList)
                    {
                        string quizType = ((dynamic)weakItem).quizType;
                        if (quizType == "Unit") weakUnitCount++;
                        else weakLevelCount++;
                    }

                    litInsWeakUnit.Text = weakUnitCount.ToString();
                    litInsWeakLevel.Text = weakLevelCount.ToString();
                    litInsCerts.Text = certificateList.Count.ToString();

                    BuildInsightRecommendation(weakUnitCount, weakLevelCount, hasNoQuizAttempts);
                }

                pnlMain.Visible = true;
                pnlError.Visible = false;
            }
            catch
            {
                ShowError(T("Error loading student data.", "Ralat memuatkan data pelajar."));
            }
        }

        private void LoadLessonProgress(SqlConnection conn, string studentId)
        {
            var lessonRows = new List<object>();

            using (var cmd = new SqlCommand(@"
                SELECT les.[lessonTitleEN], les.[lessonTitleBM], lp.[isCompleted], lp.[completedDate]
                FROM dbo.[LessonProgress] lp
                INNER JOIN dbo.[Lesson] les ON les.[lessonId] = lp.[lessonId]
                WHERE lp.[studentId] = @s
                ORDER BY lp.[completedDate] DESC", conn))
            {
                cmd.Parameters.AddWithValue("@s", studentId);

                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        bool isCompleted = reader["isCompleted"] != DBNull.Value && Convert.ToBoolean(reader["isCompleted"]);
                        string completedDate = reader["completedDate"] != DBNull.Value
                            ? Convert.ToDateTime(reader["completedDate"]).ToString("d MMM yyyy")
                            : "-";

                        string lessonTitle = CurrentLanguage == "BM"
                            ? (reader["lessonTitleBM"]?.ToString() ?? reader["lessonTitleEN"]?.ToString() ?? "")
                            : (reader["lessonTitleEN"]?.ToString() ?? reader["lessonTitleBM"]?.ToString() ?? "");

                        lessonRows.Add(new
                        {
                            lesson = lessonTitle,
                            status = isCompleted ? T("Completed", "Selesai") : T("Incomplete", "Belum Selesai"),
                            statusCss = isCompleted ? "done" : "inc",
                            date = completedDate
                        });
                    }
                }
            }

            if (lessonRows.Count > 0)
            {
                pnlLessonTable.Visible = true;
                pnlLessonEmpty.Visible = false;
                rptLessons.DataSource = lessonRows;
                rptLessons.DataBind();
            }
            else
            {
                pnlLessonTable.Visible = false;
                pnlLessonEmpty.Visible = true;
            }
        }

        private List<object> LoadWeakTopics(SqlConnection conn, string studentId, out bool hasNoQuizAttempts)
        {
            // Read pass marks from configuration (CONFIG004 = Unit, CONFIG005 = Level)
            decimal unitPassMark = 50, levelPassMark = 50;
            using (var cmd = new SqlCommand(
                "SELECT [configId], [configValue] FROM dbo.[ConfigurationSetting] WHERE [configId] IN ('CONFIG004','CONFIG005')", conn))
            {
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string configId = reader["configId"]?.ToString() ?? "";
                        decimal configValue;
                        if (decimal.TryParse(reader["configValue"]?.ToString(), out configValue))
                        {
                            if (configId == "CONFIG004") unitPassMark = configValue;
                            else if (configId == "CONFIG005") levelPassMark = configValue;
                        }
                    }
                }
            }

            string titleColumn = CurrentLanguage == "BM"
                ? "COALESCE(q.[quizTitleBM], q.[quizTitleEN], 'Quiz')"
                : "COALESCE(q.[quizTitleEN], q.[quizTitleBM], 'Quiz')";
            string unitNameColumn = CurrentLanguage == "BM"
                ? "COALESCE(u.[unitNameBM], u.[unitNameEN], '')"
                : "COALESCE(u.[unitNameEN], u.[unitNameBM], '')";
            string levelNameColumn = CurrentLanguage == "BM"
                ? "COALESCE(lv.[levelNameBM], lv.[levelNameEN], '')"
                : "COALESCE(lv.[levelNameEN], lv.[levelNameBM], '')";

            var weakTopicList = new List<object>();
            int totalAttemptedQuizzes = 0;

            using (var cmd = new SqlCommand(@"
                SELECT quizName, quizType, percentage, scopeName FROM (
                    SELECT " + titleColumn + @" AS quizName, q.[quizType],
                           qr.[percentage],
                           CASE WHEN q.[quizType]='Unit' THEN " + unitNameColumn + @"
                                ELSE " + levelNameColumn + @" END AS scopeName,
                           ROW_NUMBER() OVER(PARTITION BY qr.[quizId] ORDER BY qr.[attemptedDate] DESC, qr.[attemptNo] DESC) AS rn
                    FROM dbo.[QuizResult] qr
                    INNER JOIN dbo.[Quiz] q ON q.[quizId] = qr.[quizId]
                    LEFT JOIN dbo.[Unit] u ON u.[unitId] = q.[unitId]
                    LEFT JOIN dbo.[Level] lv ON lv.[levelId] = q.[levelId]
                    WHERE qr.[studentId] = @s AND q.[quizType] IN ('Unit','Level')
                ) sub WHERE rn = 1
                ORDER BY quizType, quizName", conn))
            {
                cmd.Parameters.AddWithValue("@s", studentId);

                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        totalAttemptedQuizzes++;

                        string quizName = reader["quizName"]?.ToString() ?? "";
                        string quizType = reader["quizType"]?.ToString() ?? "";
                        string scopeName = reader["scopeName"]?.ToString() ?? "";
                        decimal percentage = reader["percentage"] != DBNull.Value
                            ? Convert.ToDecimal(reader["percentage"]) : 0;

                        decimal passMark = quizType == "Unit" ? unitPassMark : levelPassMark;

                        if (percentage < passMark)
                        {
                            weakTopicList.Add(new
                            {
                                quizType = quizType,
                                scopeLabel = quizType == "Unit" ? T("Unit Quiz", "Kuiz Unit") : T("Level Quiz", "Kuiz Tahap"),
                                scopeName = scopeName,
                                quizName = quizName,
                                latestPct = percentage.ToString("0.0") + "%",
                                passMarkStr = passMark.ToString("0") + "%",
                                statusLabel = T("Needs Improvement", "Perlu Peningkatan")
                            });
                        }
                    }
                }
            }

            // Three states: no attempts, has weak topics, all passed
            hasNoQuizAttempts = (totalAttemptedQuizzes == 0);

            if (hasNoQuizAttempts)
            {
                pnlWeakNoAttempts.Visible = true;
                pnlWeakEmpty.Visible = false;
            }
            else if (weakTopicList.Count > 0)
            {
                rptWeak.DataSource = weakTopicList;
                rptWeak.DataBind();
                pnlWeakEmpty.Visible = false;
                pnlWeakNoAttempts.Visible = false;
            }
            else
            {
                pnlWeakEmpty.Visible = true;
                pnlWeakNoAttempts.Visible = false;
            }

            return weakTopicList;
        }

        private List<object> LoadCertificates(SqlConnection conn, string studentId)
        {
            var certificateList = new List<object>();

            try
            {
                string titleCol = CurrentLanguage == "BM" ? "c.[certificateTitleBM]" : "c.[certificateTitleEN]";
                string descCol = CurrentLanguage == "BM" ? "c.[certificateDescriptionBM]" : "c.[certificateDescriptionEN]";

                using (var cmd = new SqlCommand(@"
                    SELECT COALESCE(" + titleCol + @", c.[certificateTitleEN], 'Certificate') AS title,
                           COALESCE(" + descCol + @", c.[certificateDescriptionEN], '') AS descr,
                           COALESCE(lv.[levelNameEN], '-') AS lvl,
                           c.[issuedDate], c.[status]
                    FROM dbo.[Certificate] c
                    LEFT JOIN dbo.[Level] lv ON lv.[levelId] = c.[levelId]
                    WHERE c.[studentId] = @s
                    ORDER BY c.[issuedDate] DESC", conn))
                {
                    cmd.Parameters.AddWithValue("@s", studentId);

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string issuedDate = reader["issuedDate"] != DBNull.Value
                                ? Convert.ToDateTime(reader["issuedDate"]).ToString("d MMM yyyy")
                                : "-";
                            string status = reader["status"]?.ToString() ?? "";

                            certificateList.Add(new
                            {
                                title = reader["title"].ToString(),
                                description = reader["descr"].ToString(),
                                level = reader["lvl"].ToString(),
                                date = issuedDate,
                                status = status,
                                statusCss = status == "Active" ? "active" : "pending"
                            });
                        }
                    }
                }
            }
            catch { }

            if (certificateList.Count > 0)
            {
                rptCerts.DataSource = certificateList;
                rptCerts.DataBind();
                pnlCertEmpty.Visible = false;
            }
            else
            {
                pnlCertEmpty.Visible = true;
            }

            return certificateList;
        }

        #endregion

        #region Database Operations

        private decimal GetQuizAverage(SqlConnection conn, string studentId, string quizType)
        {
            using (var cmd = new SqlCommand(@"
                SELECT AVG(CAST(qr.[percentage] AS DECIMAL(5,2)))
                FROM dbo.[QuizResult] qr
                INNER JOIN dbo.[Quiz] q ON q.[quizId] = qr.[quizId]
                WHERE qr.[studentId] = @s AND q.[quizType] = @t", conn))
            {
                cmd.Parameters.AddWithValue("@s", studentId);
                cmd.Parameters.AddWithValue("@t", quizType);
                var result = cmd.ExecuteScalar();
                return (result != null && result != DBNull.Value) ? Convert.ToDecimal(result) : -1;
            }
        }

        private void BindQuiz(SqlConnection conn, string studentId, string quizType,
            Repeater rpt, Panel pnlTable, Panel pnlEmpty)
        {
            bool isBM = CurrentLanguage == "BM";
            string titleCol = isBM
                ? "COALESCE(q.[quizTitleBM], q.[quizTitleEN], 'Quiz')"
                : "COALESCE(q.[quizTitleEN], q.[quizTitleBM], 'Quiz')";

            var quizRows = new List<object>();

            using (var cmd = new SqlCommand(@"
                SELECT quizName, score, totalMarks, percentage, resultStatus,
                       attemptNo, attemptedDate, resultId, correctCount, wrongCount
                FROM (
                    SELECT " + titleCol + @" AS quizName,
                           qr.[score], qr.[totalMarks], qr.[percentage], qr.[resultStatus],
                           qr.[attemptNo], qr.[attemptedDate], qr.[resultId],
                           (SELECT COUNT(*) FROM dbo.[QuizAnswer] qa WHERE qa.[resultId] = qr.[resultId] AND qa.[isCorrect] = 1) AS correctCount,
                           (SELECT COUNT(*) FROM dbo.[QuizAnswer] qa WHERE qa.[resultId] = qr.[resultId] AND qa.[isCorrect] = 0) AS wrongCount,
                           ROW_NUMBER() OVER(PARTITION BY qr.[quizId] ORDER BY qr.[attemptedDate] DESC, qr.[attemptNo] DESC) AS rn
                    FROM dbo.[QuizResult] qr
                    INNER JOIN dbo.[Quiz] q ON q.[quizId] = qr.[quizId]
                    WHERE qr.[studentId] = @s AND q.[quizType] = @t
                ) sub WHERE rn = 1
                ORDER BY attemptedDate DESC", conn))
            {
                cmd.Parameters.AddWithValue("@s", studentId);
                cmd.Parameters.AddWithValue("@t", quizType);

                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string attemptedDate = reader["attemptedDate"] != DBNull.Value
                            ? Convert.ToDateTime(reader["attemptedDate"]).ToString("d MMM yyyy") : "-";

                        string percentageDisplay = reader["percentage"] != DBNull.Value
                            ? Convert.ToDecimal(reader["percentage"]).ToString("0.0") + "%" : "-";

                        string scoreDisplay = reader["score"] != DBNull.Value
                            ? Convert.ToDecimal(reader["score"]).ToString("0") + "/" + Convert.ToDecimal(reader["totalMarks"]).ToString("0")
                            : "-";

                        string resultStatus = reader["resultStatus"]?.ToString() ?? "-";
                        int correctCount = reader["correctCount"] != DBNull.Value ? Convert.ToInt32(reader["correctCount"]) : 0;
                        int wrongCount = reader["wrongCount"] != DBNull.Value ? Convert.ToInt32(reader["wrongCount"]) : 0;

                        quizRows.Add(new
                        {
                            quizName = reader["quizName"].ToString(),
                            score = scoreDisplay,
                            pct = percentageDisplay,
                            result = resultStatus == "Passed" ? T("Passed", "Lulus") : T("Failed", "Gagal"),
                            resCss = resultStatus == "Passed" ? "pass" : "fail",
                            attempts = reader["attemptNo"]?.ToString() ?? "1",
                            date = attemptedDate,
                            resultId = reader["resultId"].ToString(),
                            correctCount = correctCount,
                            wrongCount = wrongCount
                        });
                    }
                }
            }

            if (quizRows.Count > 0)
            {
                pnlTable.Visible = true;
                pnlEmpty.Visible = false;
                rpt.DataSource = quizRows;
                rpt.DataBind();
            }
            else
            {
                pnlTable.Visible = false;
                pnlEmpty.Visible = true;
            }
        }

        #endregion

        #region Helper Methods

        /// <summary>
        /// Builds an HTML answer card for a single quiz question, handling MCQ, Drag-and-Drop, and Multi-Select types.
        /// </summary>
        private void BuildAnswerCard(System.Text.StringBuilder sb, SqlDataReader reader, int questionNumber)
        {
            string questionTextEN = reader["questionTextEN"]?.ToString() ?? "";
            string questionTextBM = reader["questionTextBM"]?.ToString() ?? "";
            string questionType = reader["questionType"]?.ToString() ?? "MCQ";

            string optionA_EN = reader["optionA_EN"]?.ToString() ?? "";
            string optionA_BM = reader["optionA_BM"]?.ToString() ?? "";
            string optionB_EN = reader["optionB_EN"]?.ToString() ?? "";
            string optionB_BM = reader["optionB_BM"]?.ToString() ?? "";
            string optionC_EN = reader["optionC_EN"]?.ToString() ?? "";
            string optionC_BM = reader["optionC_BM"]?.ToString() ?? "";
            string optionD_EN = reader["optionD_EN"]?.ToString() ?? "";
            string optionD_BM = reader["optionD_BM"]?.ToString() ?? "";

            string selectedAnswer = reader["selectedAnswer"] != DBNull.Value ? reader["selectedAnswer"].ToString() : "-";
            string correctAnswer = reader["correctAnswer"]?.ToString() ?? "-";
            bool isCorrect = reader["isCorrect"] != DBNull.Value && Convert.ToBoolean(reader["isCorrect"]);

            string statusLabel = isCorrect ? T("Correct", "Betul") : T("Wrong", "Salah");
            string badgeCss = isCorrect ? "correct" : "wrong";

            // Card header
            sb.Append("<div class=\"tc-student-details-ans-card\">");
            sb.AppendFormat("<div class=\"tc-student-details-ans-header\"><span class=\"tc-student-details-ans-num\">Q{0}</span><span class=\"tc-student-details-ans-badge {1}\">{2}</span></div>",
                questionNumber, badgeCss, statusLabel);

            // Language sections side by side
            sb.Append("<div class=\"tc-student-details-ans-langs\">");

            // English section
            sb.Append("<div class=\"tc-student-details-ans-lang-section\">");
            sb.AppendFormat("<div class=\"tc-student-details-ans-lang-label\">{0}</div>", T("English", "Bahasa Inggeris"));
            if (!string.IsNullOrEmpty(questionTextEN))
            {
                sb.AppendFormat("<div class=\"tc-student-details-ans-q\">{0}</div>", HttpUtility.HtmlEncode(questionTextEN));
                sb.Append("<div class=\"tc-student-details-ans-options\">");
                AppendOptionHtml(sb, "A", optionA_EN, selectedAnswer, correctAnswer, isCorrect);
                AppendOptionHtml(sb, "B", optionB_EN, selectedAnswer, correctAnswer, isCorrect);
                AppendOptionHtml(sb, "C", optionC_EN, selectedAnswer, correctAnswer, isCorrect);
                AppendOptionHtml(sb, "D", optionD_EN, selectedAnswer, correctAnswer, isCorrect);
                sb.Append("</div>");
            }
            else
            {
                sb.AppendFormat("<div class=\"tc-student-details-ans-unavail\">{0}</div>",
                    T("Translation unavailable", "Terjemahan tidak tersedia"));
            }
            sb.Append("</div>");

            // Bahasa Melayu section
            sb.Append("<div class=\"tc-student-details-ans-lang-section\">");
            sb.AppendFormat("<div class=\"tc-student-details-ans-lang-label\">{0}</div>", T("Bahasa Melayu", "Bahasa Melayu"));
            if (!string.IsNullOrEmpty(questionTextBM))
            {
                sb.AppendFormat("<div class=\"tc-student-details-ans-q\">{0}</div>", HttpUtility.HtmlEncode(questionTextBM));
                sb.Append("<div class=\"tc-student-details-ans-options\">");
                AppendOptionHtml(sb, "A", optionA_BM, selectedAnswer, correctAnswer, isCorrect);
                AppendOptionHtml(sb, "B", optionB_BM, selectedAnswer, correctAnswer, isCorrect);
                AppendOptionHtml(sb, "C", optionC_BM, selectedAnswer, correctAnswer, isCorrect);
                AppendOptionHtml(sb, "D", optionD_BM, selectedAnswer, correctAnswer, isCorrect);
                sb.Append("</div>");
            }
            else
            {
                sb.AppendFormat("<div class=\"tc-student-details-ans-unavail\">{0}</div>",
                    T("Translation unavailable", "Terjemahan tidak tersedia"));
            }
            sb.Append("</div>"); // BM lang section
            sb.Append("</div>"); // ans-langs

            // Student answer summary - varies by question type
            string notAnswered = T("Not Answered", "Tidak Dijawab");
            string selectedDisplay = string.IsNullOrEmpty(selectedAnswer) || selectedAnswer == "-" ? notAnswered : selectedAnswer;
            string correctDisplay = correctAnswer;

            sb.Append("<div class=\"tc-student-details-ans-summary\">");

            if (IsDragAndDrop(questionType))
            {
                // Drag and Drop: display answer text in both languages
                sb.Append("<div class=\"tc-student-details-ans-dd-block\">");
                sb.AppendFormat("<div class=\"tc-student-details-ans-dd-title\">{0}</div>", T("Student's Answer", "Jawapan Pelajar"));
                if (string.IsNullOrEmpty(selectedAnswer) || selectedAnswer == "-")
                {
                    sb.AppendFormat("<div class=\"tc-student-details-ans-dd-val\">{0}</div>", notAnswered);
                }
                else
                {
                    sb.AppendFormat("<div class=\"tc-student-details-ans-dd-lang\"><span class=\"tc-student-details-ans-dd-lang-label\">{0}:</span> {1}</div>",
                        T("English", "Bahasa Inggeris"), HttpUtility.HtmlEncode(selectedAnswer));
                    sb.AppendFormat("<div class=\"tc-student-details-ans-dd-lang\"><span class=\"tc-student-details-ans-dd-lang-label\">{0}:</span> {1}</div>",
                        T("Bahasa Melayu", "Bahasa Melayu"), HttpUtility.HtmlEncode(selectedAnswer));
                }
                sb.Append("</div>");

                sb.Append("<div class=\"tc-student-details-ans-dd-block\">");
                sb.AppendFormat("<div class=\"tc-student-details-ans-dd-title\">{0}</div>", T("Correct Answer", "Jawapan Betul"));
                sb.AppendFormat("<div class=\"tc-student-details-ans-dd-lang\"><span class=\"tc-student-details-ans-dd-lang-label\">{0}:</span> {1}</div>",
                    T("English", "Bahasa Inggeris"), HttpUtility.HtmlEncode(correctAnswer));
                sb.AppendFormat("<div class=\"tc-student-details-ans-dd-lang\"><span class=\"tc-student-details-ans-dd-lang-label\">{0}:</span> {1}</div>",
                    T("Bahasa Melayu", "Bahasa Melayu"), HttpUtility.HtmlEncode(correctAnswer));
                sb.Append("</div>");
            }

            else if (IsMultiSelect(questionType))
            {
                // Multi-select: sort selected letters alphabetically
                string sortedSelected = SortLetters(selectedAnswer, notAnswered);
                string sortedCorrect = SortLetters(correctAnswer, "-");
                sb.AppendFormat("<div class=\"tc-student-details-ans-pair\"><span class=\"tc-student-details-ans-pair-label\">{0}:</span><span class=\"tc-student-details-ans-pair-val\">{1}</span></div>",
                    T("Student's Answer", "Jawapan Pelajar"), HttpUtility.HtmlEncode(sortedSelected));
                sb.AppendFormat("<div class=\"tc-student-details-ans-pair\"><span class=\"tc-student-details-ans-pair-label\">{0}:</span><span class=\"tc-student-details-ans-pair-val\">{1}</span></div>",
                    T("Correct Answer", "Jawapan Betul"), HttpUtility.HtmlEncode(sortedCorrect));
            }
            else
            {
                // MCQ / True-False: display option letter only
                sb.AppendFormat("<div class=\"tc-student-details-ans-pair\"><span class=\"tc-student-details-ans-pair-label\">{0}:</span><span class=\"tc-student-details-ans-pair-val\">{1}</span></div>",
                    T("Student's Answer", "Jawapan Pelajar"), HttpUtility.HtmlEncode(selectedDisplay));
                sb.AppendFormat("<div class=\"tc-student-details-ans-pair\"><span class=\"tc-student-details-ans-pair-label\">{0}:</span><span class=\"tc-student-details-ans-pair-val\">{1}</span></div>",
                    T("Correct Answer", "Jawapan Betul"), HttpUtility.HtmlEncode(correctDisplay));
            }

            sb.Append("</div>"); // ans-summary
            sb.Append("</div>"); // ans-card
        }

        /// <summary>
        /// Appends a single MCQ option div with correct/wrong highlighting based on the student's selection.
        /// </summary>
        private void AppendOptionHtml(System.Text.StringBuilder sb, string optionLetter, string optionText,
            string selectedAnswer, string correctAnswer, bool isCorrect)
        {
            if (string.IsNullOrEmpty(optionText)) return;

            string cssModifier = correctAnswer == optionLetter
                ? " tc-student-details-opt-correct"
                : (selectedAnswer == optionLetter && !isCorrect ? " tc-student-details-opt-wrong" : "");

            sb.AppendFormat("<div class=\"tc-student-details-ans-opt{0}\"><span class=\"tc-student-details-opt-label\">{1}</span>{2}</div>",
                cssModifier, optionLetter, HttpUtility.HtmlEncode(optionText));
        }

        private void BuildInsightRecommendation(int weakUnitCount, int weakLevelCount, bool noAttempts)
        {
            string recommendation;

            if (noAttempts)
                recommendation = T("Encourage the student to attempt a Unit or Level quiz so their performance can be evaluated.",
                                   "Galakkan pelajar mencuba Kuiz Unit atau Kuiz Level supaya prestasi mereka dapat dinilai.");
            else if (weakUnitCount > 0 && weakLevelCount > 0)
                recommendation = T("Review the failed Unit and Level topics before reattempting the quizzes.",
                                   "Ulang kaji topik Unit dan Level yang gagal sebelum mencuba semula kuiz.");
            else if (weakUnitCount > 0)
                recommendation = T("Review the failed Unit topics before reattempting the Unit quizzes.",
                                   "Ulang kaji topik Unit yang gagal sebelum mencuba semula Kuiz Unit.");
            else if (weakLevelCount > 0)
                recommendation = T("Review the failed Level topics before reattempting the Level quizzes.",
                                   "Ulang kaji topik Level yang gagal sebelum mencuba semula Kuiz Level.");
            else
                recommendation = T("Excellent progress. Continue completing the remaining lessons and maintain your performance.",
                                   "Prestasi yang cemerlang. Teruskan menyelesaikan pelajaran yang masih belum lengkap dan kekalkan prestasi anda.");

            litInsight.Text = HttpUtility.HtmlEncode(recommendation);
        }

        private void ShowError(string message)
        {
            pnlError.Visible = true;
            pnlMain.Visible = false;
            litErrMsg.Text = HttpUtility.HtmlEncode(message);
        }

        private static string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "S";

            var parts = name.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            return parts.Length >= 2
                ? (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper()
                : name.Trim()[0].ToString().ToUpper();
        }

        private static string SortLetters(string val, string fallback)
        {
            if (string.IsNullOrEmpty(val) || val == "-") return fallback;

            // Split by common delimiters, filter to single letters, sort alphabetically
            var letters = val.Split(new[] { ',', ';', ' ', '|' }, StringSplitOptions.RemoveEmptyEntries);
            var sorted = new List<string>();

            foreach (var letter in letters)
            {
                string trimmed = letter.Trim().ToUpper();
                if (!string.IsNullOrEmpty(trimmed))
                    sorted.Add(trimmed);
            }

            sorted.Sort();
            return sorted.Count > 0 ? string.Join(", ", sorted) : fallback;
        }

        private static bool IsDragAndDrop(string questionType)
        {
            return questionType.Equals("DragDrop", StringComparison.OrdinalIgnoreCase)
                || questionType.Equals("Drag and Drop", StringComparison.OrdinalIgnoreCase)
                || questionType.Equals("DnD", StringComparison.OrdinalIgnoreCase);
        }

        private static bool IsMultiSelect(string questionType)
        {
            return questionType.Equals("MultiSelect", StringComparison.OrdinalIgnoreCase)
                || questionType.Equals("Multi-select", StringComparison.OrdinalIgnoreCase)
                || questionType.Equals("MS", StringComparison.OrdinalIgnoreCase);
        }

        #endregion
    }
}
