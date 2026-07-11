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
    public partial class QuizReview : Page
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
            if (Session["userId"] == null || Session["role"] == null || Session["role"].ToString() != "Student")
            {
                Response.Redirect("~/Login.aspx", false);
                return;
            }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            InitLang();

            if (!IsPostBack)
            {
                LoadReview();
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
                    using (SqlConnection connection = new SqlConnection(ConnStr))
                    using (SqlCommand command = new SqlCommand("SELECT preferredLanguage FROM [User] WHERE userId=@uid", connection))
                    {
                        command.Parameters.AddWithValue("@uid", userId);
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
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("Error: " + ex.Message);
                }
            }

            CurrentLanguage = "EN";
            Session["preferredLanguage"] = "EN";
        }

        private void LoadReview()
        {
            string resultId = Request.QueryString["resultId"];
            if (string.IsNullOrEmpty(resultId))
            {
                ShowError(T("Result not found.", "Keputusan tidak dijumpai."));
                return;
            }

            string userId = Session["userId"].ToString();
            bool isBM = CurrentLanguage == "BM";

            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();

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
                using (SqlCommand command = new SqlCommand(verifySql, connection))
                {
                    command.Parameters.AddWithValue("@rid", resultId);
                    command.Parameters.AddWithValue("@uid", userId);
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        if (!reader.Read())
                        {
                            ShowError(T("Result not found or access denied.", "Keputusan tidak dijumpai atau akses ditolak."));
                            return;
                        }

                        if (isBM)
                        {
                            quizTitle = reader["quizTitleBM"].ToString();
                        }
                        else
                        {
                            quizTitle = reader["quizTitleEN"].ToString();
                        }
                        if (string.IsNullOrWhiteSpace(quizTitle))
                        {
                            quizTitle = reader["quizTitleEN"].ToString();
                        }

                        if (reader["percentage"] != DBNull.Value)
                        {
                            pct = Convert.ToDecimal(reader["percentage"]);
                        }
                        else
                        {
                            pct = 0;
                        }

                        quizId = reader["quizId"].ToString();

                        if (reader["quizType"] != DBNull.Value)
                        {
                            quizType = reader["quizType"].ToString();
                        }
                        else
                        {
                            quizType = "Practice";
                        }
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

                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    command.Parameters.AddWithValue("@rid", resultId);
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            qNum++;
                            bool isCorrect = reader["isCorrect"] != DBNull.Value && Convert.ToBoolean(reader["isCorrect"]);
                            if (isCorrect)
                            {
                                correctCount++;
                            }

                            string qText;
                            if (isBM)
                            {
                                qText = Sv(reader, "questionTextBM");
                            }
                            else
                            {
                                qText = Sv(reader, "questionTextEN");
                            }
                            if (string.IsNullOrWhiteSpace(qText))
                            {
                                qText = Sv(reader, "questionTextEN");
                            }

                            string selectedAnswer = Sv(reader, "selectedAnswer");
                            string correctAnswer = Sv(reader, "correctAnswer");
                            string questionType = Sv(reader, "questionType");

                            // Get option texts for display
                            string selectedDisplay = TranslateAnswer(reader, selectedAnswer, questionType, isBM);
                            string correctDisplay = TranslateAnswer(reader, correctAnswer, questionType, isBM);

                            // Explanation
                            string explanation;
                            if (isCorrect)
                            {
                                if (isBM)
                                {
                                    explanation = Sv(reader, "correctExplanationBM");
                                }
                                else
                                {
                                    explanation = Sv(reader, "correctExplanationEN");
                                }
                                if (string.IsNullOrWhiteSpace(explanation))
                                {
                                    explanation = Sv(reader, "correctExplanationEN");
                                }
                                if (string.IsNullOrWhiteSpace(explanation))
                                {
                                    explanation = T("Great job! You selected the correct answer.", "Bagus! Anda memilih jawapan yang betul.");
                                }
                            }
                            else
                            {
                                if (isBM)
                                {
                                    explanation = Sv(reader, "wrongExplanationBM");
                                }
                                else
                                {
                                    explanation = Sv(reader, "wrongExplanationEN");
                                }
                                if (string.IsNullOrWhiteSpace(explanation))
                                {
                                    explanation = Sv(reader, "wrongExplanationEN");
                                }
                                if (string.IsNullOrWhiteSpace(explanation))
                                {
                                    explanation = T("Review this topic and try again to improve your understanding.", "Ulang kaji topik ini dan cuba lagi untuk meningkatkan kefahaman anda.");
                                }

                                // Collect weak topic
                                string subtopic;
                                if (isBM)
                                {
                                    subtopic = Sv(reader, "subtopicTitleBM");
                                }
                                else
                                {
                                    subtopic = Sv(reader, "subtopicTitleEN");
                                }
                                if (string.IsNullOrWhiteSpace(subtopic))
                                {
                                    subtopic = Sv(reader, "subtopicTitleEN");
                                }
                                if (!string.IsNullOrWhiteSpace(subtopic))
                                {
                                    weakTopics.Add(subtopic);
                                }
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

                if (items.Count == 0)
                {
                    ShowError(T("No answers found for this result.", "Tiada jawapan dijumpai untuk keputusan ini."));
                    return;
                }

                // ══ DISPLAY ══
                pnlReview.Visible = true;
                pnlError.Visible = false;
                litPageTitle.Text = T("Quiz Review", "Semakan Kuiz");
                litTitle.Text = T("Answer Review", "Semakan Jawapan");
                litSub.Text = HttpUtility.HtmlEncode(quizTitle);

                // Header chips
                litHeaderPct.Text = Math.Round(pct, 0) + "%";
                litHeaderCorrect.Text = correctCount + "/" + items.Count + " " + T("correct", "betul");
                string typeLabel;
                if (quizType == "Practice")
                {
                    typeLabel = T("Practice", "Latihan");
                }
                else if (quizType == "Unit")
                {
                    typeLabel = T("Unit", "Unit");
                }
                else
                {
                    typeLabel = T("Level", "Tahap");
                }
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
                        chips += "<span class=\"st-quizreview-weak-chip\"><i class=\"bi bi-book-half\"></i> " + HttpUtility.HtmlEncode(topic) + "</span>";
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
            if (string.IsNullOrWhiteSpace(answer))
            {
                return T("(No answer)", "(Tiada jawapan)");
            }

            string qt = (questionType ?? "").ToLower().Replace(" ", "").Replace("/", "");

            // True/False
            if (qt.Contains("true") || qt == "tf")
            {
                if (answer.Equals("True", StringComparison.OrdinalIgnoreCase))
                {
                    if (isBM)
                    {
                        return "Betul";
                    }
                    return "True";
                }
                if (answer.Equals("False", StringComparison.OrdinalIgnoreCase))
                {
                    if (isBM)
                    {
                        return "Salah";
                    }
                    return "False";
                }
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
                    if (!string.IsNullOrWhiteSpace(optText))
                    {
                        texts.Add(part + ". " + optText);
                    }
                    else
                    {
                        texts.Add(part);
                    }
                }
                return string.Join(" | ", texts);
            }

            // MCQ - single letter
            string optionText = GetOptionText(rdr, answer, isBM);
            if (!string.IsNullOrWhiteSpace(optionText))
            {
                return answer + ". " + optionText;
            }
            return answer;
        }

        private string GetOptionText(SqlDataReader rdr, string letter, bool isBM)
        {
            string upper = letter.Trim().ToUpper();
            switch (upper)
            {
                case "A":
                    if (isBM)
                    {
                        return Sv(rdr, "optionA_BM");
                    }
                    return Sv(rdr, "optionA_EN");
                case "B":
                    if (isBM)
                    {
                        return Sv(rdr, "optionB_BM");
                    }
                    return Sv(rdr, "optionB_EN");
                case "C":
                    if (isBM)
                    {
                        return Sv(rdr, "optionC_BM");
                    }
                    return Sv(rdr, "optionC_EN");
                case "D":
                    if (isBM)
                    {
                        return Sv(rdr, "optionD_BM");
                    }
                    return Sv(rdr, "optionD_EN");
                default:
                    return "";
            }
        }

        private void ShowError(string msg)
        {
            pnlError.Visible = true;
            pnlReview.Visible = false;
            litError.Text = HttpUtility.HtmlEncode(msg);
            litErrBtn.Text = T("Back", "Kembali");
        }

        private static string Sv(SqlDataReader rdr, string col)
        {
            try
            {
                object v = rdr[col];
                if (v != null && v != DBNull.Value)
                {
                    return v.ToString();
                }
                return "";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error: " + ex.Message);
                return "";
            }
        }
    }
}
