using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;

namespace ScienceBuddy.Student
{
    public partial class QuizReviewPage : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        public string CurrentLanguage = "EN";
        public string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null || Session["role"].ToString() != "Student")
            { Response.Redirect("~/Login.aspx", false); return; }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            InitLang();

            if (!IsPostBack) LoadReview();
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
                    using (var conn = new SqlConnection(ConnStr))
                    using (var cmd = new SqlCommand("SELECT preferredLanguage FROM [User] WHERE userId=@uid", conn))
                    {
                        cmd.Parameters.AddWithValue("@uid", userId); conn.Open();
                        object r = cmd.ExecuteScalar();
                        if (r != null && r != DBNull.Value) { lang = r.ToString(); Session["preferredLanguage"] = lang; CurrentLanguage = lang; return; }
                    }
                }
                catch { }
            }
            CurrentLanguage = "EN"; Session["preferredLanguage"] = "EN";
        }

        private void LoadReview()
        {
            string resultId = Request.QueryString["resultId"];
            if (string.IsNullOrEmpty(resultId)) { ShowError(T("Result not found.", "Keputusan tidak dijumpai.")); return; }

            string userId = Session["userId"].ToString();
            bool isBM = CurrentLanguage == "BM";

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Verify ownership and get quiz info
                const string verifySql = @"
                    SELECT qr.resultId, qr.percentage, qr.quizId,
                           q.quizTitleEN, q.quizTitleBM, q.quizType
                    FROM QuizResult qr
                    JOIN Quiz q ON q.quizId = qr.quizId
                    JOIN Student s ON s.studentId = qr.studentId
                    WHERE qr.resultId=@rid AND s.userId=@uid";

                string quizTitle = "";
                string quizId = "";
                string quizType = "";
                decimal pct = 0;
                using (var cmd = new SqlCommand(verifySql, conn))
                {
                    cmd.Parameters.AddWithValue("@rid", resultId);
                    cmd.Parameters.AddWithValue("@uid", userId);
                    using (var rdr = cmd.ExecuteReader())
                    {
                        if (!rdr.Read()) { ShowError(T("Result not found or access denied.", "Keputusan tidak dijumpai atau akses ditolak.")); return; }
                        quizTitle = isBM ? rdr["quizTitleBM"].ToString() : rdr["quizTitleEN"].ToString();
                        if (string.IsNullOrWhiteSpace(quizTitle)) quizTitle = rdr["quizTitleEN"].ToString();
                        pct = rdr["percentage"] != DBNull.Value ? Convert.ToDecimal(rdr["percentage"]) : 0;
                        quizId = rdr["quizId"].ToString();
                        quizType = rdr["quizType"] != DBNull.Value ? rdr["quizType"].ToString() : "Practice";
                    }
                }

                // Load answers with full question data including options and subtopic
                const string sql = @"
                    SELECT qa.selectedAnswer, qa.isCorrect, qa.marksAwarded,
                           qst.questionTextEN, qst.questionTextBM, qst.questionImageUrl, qst.questionType,
                           qst.optionA_EN, qst.optionA_BM, qst.optionB_EN, qst.optionB_BM,
                           qst.optionC_EN, qst.optionC_BM, qst.optionD_EN, qst.optionD_BM,
                           qst.correctAnswer, qst.correctExplanationEN, qst.correctExplanationBM,
                           qst.wrongExplanationEN, qst.wrongExplanationBM,
                           st.subtopicTitleEN, st.subtopicTitleBM
                    FROM QuizAnswer qa
                    JOIN Question qst ON qst.questionId = qa.questionId
                    LEFT JOIN Subtopic st ON st.subtopicId = qst.subtopicId
                    WHERE qa.resultId = @rid
                    ORDER BY qa.answerId";

                var items = new List<object>();
                var weakTopics = new HashSet<string>();
                int qNum = 0;
                int correctCount = 0;

                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@rid", resultId);
                    using (var rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            qNum++;
                            bool isCorrect = rdr["isCorrect"] != DBNull.Value && Convert.ToBoolean(rdr["isCorrect"]);
                            if (isCorrect) correctCount++;

                            string qText = isBM ? Sv(rdr, "questionTextBM") : Sv(rdr, "questionTextEN");
                            if (string.IsNullOrWhiteSpace(qText)) qText = Sv(rdr, "questionTextEN");

                            string selectedAnswer = Sv(rdr, "selectedAnswer");
                            string correctAnswer = Sv(rdr, "correctAnswer");
                            string questionType = Sv(rdr, "questionType");

                            // Get option texts for display
                            string selectedDisplay = TranslateAnswer(rdr, selectedAnswer, questionType, isBM);
                            string correctDisplay = TranslateAnswer(rdr, correctAnswer, questionType, isBM);

                            // Explanation
                            string explanation;
                            if (isCorrect)
                            {
                                explanation = isBM ? Sv(rdr, "correctExplanationBM") : Sv(rdr, "correctExplanationEN");
                                if (string.IsNullOrWhiteSpace(explanation)) explanation = Sv(rdr, "correctExplanationEN");
                                if (string.IsNullOrWhiteSpace(explanation))
                                    explanation = T("Great job! You selected the correct answer.", "Bagus! Anda memilih jawapan yang betul.");
                            }
                            else
                            {
                                explanation = isBM ? Sv(rdr, "wrongExplanationBM") : Sv(rdr, "wrongExplanationEN");
                                if (string.IsNullOrWhiteSpace(explanation)) explanation = Sv(rdr, "wrongExplanationEN");
                                if (string.IsNullOrWhiteSpace(explanation))
                                    explanation = T("Review this topic and try again to improve your understanding.", "Ulang kaji topik ini dan cuba lagi untuk meningkatkan kefahaman anda.");

                                // Collect weak topic
                                string subtopic = isBM ? Sv(rdr, "subtopicTitleBM") : Sv(rdr, "subtopicTitleEN");
                                if (string.IsNullOrWhiteSpace(subtopic)) subtopic = Sv(rdr, "subtopicTitleEN");
                                if (!string.IsNullOrWhiteSpace(subtopic)) weakTopics.Add(subtopic);
                            }

                            items.Add(new
                            {
                                QLabel = T("Question ", "Soalan ") + qNum,
                                QuestionText = HttpUtility.HtmlEncode(qText),
                                SelectedDisplay = HttpUtility.HtmlEncode(selectedDisplay),
                                CorrectDisplay = HttpUtility.HtmlEncode(correctDisplay),
                                IsCorrect = isCorrect,
                                Explanation = HttpUtility.HtmlEncode(explanation),
                                YourLabel = T("Your answer", "Jawapan anda"),
                                CorrectLabel = T("Correct", "Betul")
                            });
                        }
                    }
                }

                if (items.Count == 0) { ShowError(T("No answers found for this result.", "Tiada jawapan dijumpai untuk keputusan ini.")); return; }

                // ══ DISPLAY ══
                pnlReview.Visible = true;
                pnlError.Visible = false;
                litPageTitle.Text = T("Quiz Review", "Semakan Kuiz");
                litTitle.Text = T("Answer Review", "Semakan Jawapan");
                litSub.Text = HttpUtility.HtmlEncode(quizTitle);

                // Header chips
                litHeaderPct.Text = Math.Round(pct, 0) + "%";
                litHeaderCorrect.Text = correctCount + "/" + items.Count + " " + T("correct", "betul");
                string typeLabel = quizType == "Practice" ? T("Practice", "Latihan") : quizType == "Unit" ? T("Unit", "Unit") : T("Level", "Tahap");
                litHeaderType.Text = typeLabel;

                // Back link
                litBack.Text = T("Back to Result", "Kembali ke Keputusan");
                lnkBack.HRef = ResolveUrl("~/Student/QuizResult.aspx?resultId=" + resultId);

                // Weak Topics
                if (weakTopics.Count > 0)
                {
                    pnlWeakTopics.Visible = true;
                    litWeakTitle.Text = T("Topics to Review", "Topik untuk Ulang Kaji");
                    string chips = "";
                    foreach (string topic in weakTopics)
                    {
                        chips += "<span class=\"rv-weak-chip\"><i class=\"bi bi-book-half\"></i> " + HttpUtility.HtmlEncode(topic) + "</span>";
                    }
                    litWeakChips.Text = chips;
                }

                // Buttons
                litRetryBtn.Text = T("Try Again", "Cuba Lagi");
                litResultBtn.Text = T("Back to Result", "Kembali ke Keputusan");
                litPracticeBtn.Text = T("Practice Library", "Perpustakaan Latihan");
                litLearningBtn.Text = T("My Learning", "Pembelajaran Saya");
                litHistoryBtn.Text = T("Quiz History", "Sejarah Kuiz");
                lnkRetry.HRef = ResolveUrl("~/Student/Quiz.aspx?quizId=" + quizId);
                lnkResult.HRef = ResolveUrl("~/Student/QuizResult.aspx?resultId=" + resultId);

                // Bind
                rptQuestions.DataSource = items;
                rptQuestions.DataBind();
            }
        }

        /// <summary>
        /// Translates answer letters (A, B, C, D, True, False) to display text including option content.
        /// </summary>
        private string TranslateAnswer(SqlDataReader rdr, string answer, string questionType, bool isBM)
        {
            if (string.IsNullOrWhiteSpace(answer)) return T("(No answer)", "(Tiada jawapan)");

            string qt = (questionType ?? "").ToLower().Replace(" ", "").Replace("/", "");

            // True/False
            if (qt.Contains("true") || qt == "tf")
            {
                if (answer.Equals("True", StringComparison.OrdinalIgnoreCase))
                    return isBM ? "Betul" : "True";
                if (answer.Equals("False", StringComparison.OrdinalIgnoreCase))
                    return isBM ? "Salah" : "False";
                return answer;
            }

            // MultiSelect or DragDrop - show as comma-separated with option text
            if (answer.Contains(","))
            {
                var parts = answer.Split(',').Select(p => p.Trim()).ToList();
                var texts = new List<string>();
                foreach (string part in parts)
                {
                    string optText = GetOptionText(rdr, part, isBM);
                    texts.Add(!string.IsNullOrWhiteSpace(optText) ? part + ". " + optText : part);
                }
                return string.Join(" | ", texts);
            }

            // MCQ - single letter
            string optionText = GetOptionText(rdr, answer, isBM);
            if (!string.IsNullOrWhiteSpace(optionText))
                return answer + ". " + optionText;
            return answer;
        }

        private string GetOptionText(SqlDataReader rdr, string letter, bool isBM)
        {
            string upper = letter.Trim().ToUpper();
            switch (upper)
            {
                case "A": return isBM ? Sv(rdr, "optionA_BM") : Sv(rdr, "optionA_EN");
                case "B": return isBM ? Sv(rdr, "optionB_BM") : Sv(rdr, "optionB_EN");
                case "C": return isBM ? Sv(rdr, "optionC_BM") : Sv(rdr, "optionC_EN");
                case "D": return isBM ? Sv(rdr, "optionD_BM") : Sv(rdr, "optionD_EN");
                default: return "";
            }
        }

        private void ShowError(string msg)
        {
            pnlError.Visible = true; pnlReview.Visible = false;
            litError.Text = HttpUtility.HtmlEncode(msg);
            litErrBtn.Text = T("Back", "Kembali");
        }

        private static string Sv(SqlDataReader rdr, string col)
        {
            try { object v = rdr[col]; return v != null && v != DBNull.Value ? v.ToString() : ""; }
            catch { return ""; }
        }
    }
}
