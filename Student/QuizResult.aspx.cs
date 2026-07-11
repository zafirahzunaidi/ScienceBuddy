using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace ScienceBuddy.Student
{
    public partial class QuizResult : Page
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
                LoadResult();
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

        private void LoadResult()
        {
            string resultId = Request.QueryString["resultId"];
            if (string.IsNullOrEmpty(resultId))
            {
                ShowError(T("Result not found.", "Keputusan tidak dijumpai."));
                return;
            }

            string userId = Session["userId"].ToString();

            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();

                // Load result + quiz info, verify student owns this result
                const string sql = @"
                    SELECT qr.resultId, qr.score, qr.totalMarks, qr.percentage, qr.resultStatus,
                           qr.attemptNo, qr.attemptedDate, qr.quizId,
                           q.quizTitleEN, q.quizTitleBM, q.quizType, q.levelId, q.unitId,
                           lv.levelNameEN, lv.levelNameBM,
                           u.unitNameEN, u.unitNameBM,
                           s.studentId
                    FROM QuizResult qr
                    JOIN Quiz q ON q.quizId = qr.quizId
                    JOIN Student s ON s.studentId = qr.studentId
                    LEFT JOIN Level lv ON lv.levelId = q.levelId
                    LEFT JOIN Unit u ON u.unitId = q.unitId
                    WHERE qr.resultId = @rid AND s.userId = @uid";

                DataRow row = null;
                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    command.Parameters.AddWithValue("@rid", resultId);
                    command.Parameters.AddWithValue("@uid", userId);
                    DataTable dataTable = new DataTable();
                    SqlDataAdapter adapter = new SqlDataAdapter(command);
                    adapter.Fill(dataTable);
                    if (dataTable.Rows.Count == 0)
                    {
                        ShowError(T("Result not found or access denied.", "Keputusan tidak dijumpai atau akses ditolak."));
                        return;
                    }
                    row = dataTable.Rows[0];
                }

                decimal score = 0;
                if (row["score"] != DBNull.Value)
                {
                    score = Convert.ToDecimal(row["score"]);
                }

                decimal totalMarks = 0;
                if (row["totalMarks"] != DBNull.Value)
                {
                    totalMarks = Convert.ToDecimal(row["totalMarks"]);
                }

                decimal percentage = 0;
                if (row["percentage"] != DBNull.Value)
                {
                    percentage = Convert.ToDecimal(row["percentage"]);
                }

                string resultStatus = "Failed";
                if (row["resultStatus"] != DBNull.Value)
                {
                    resultStatus = row["resultStatus"].ToString();
                }

                int attemptNo = 1;
                if (row["attemptNo"] != DBNull.Value)
                {
                    attemptNo = Convert.ToInt32(row["attemptNo"]);
                }

                string quizType = "Practice";
                if (row["quizType"] != DBNull.Value)
                {
                    quizType = row["quizType"].ToString();
                }

                string quizId = row["quizId"].ToString();

                string levelId = null;
                if (row["levelId"] != DBNull.Value)
                {
                    levelId = row["levelId"].ToString();
                }

                string unitId = null;
                if (row["unitId"] != DBNull.Value)
                {
                    unitId = row["unitId"].ToString();
                }

                bool isBM = CurrentLanguage == "BM";
                string quizTitle;
                if (isBM)
                {
                    quizTitle = S(row, "quizTitleBM");
                }
                else
                {
                    quizTitle = S(row, "quizTitleEN");
                }
                if (string.IsNullOrWhiteSpace(quizTitle))
                {
                    quizTitle = S(row, "quizTitleEN");
                }

                bool passed = resultStatus == "Passed";

                // Count correct/wrong answers
                int correctCount = 0;
                int totalQ = 0;
                const string ansSql = "SELECT COUNT(*) AS total, SUM(CASE WHEN isCorrect=1 THEN 1 ELSE 0 END) AS corr FROM QuizAnswer WHERE resultId=@rid";
                using (SqlCommand command = new SqlCommand(ansSql, connection))
                {
                    command.Parameters.AddWithValue("@rid", resultId);
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            totalQ = Convert.ToInt32(reader["total"]);
                            if (reader["corr"] != DBNull.Value)
                            {
                                correctCount = Convert.ToInt32(reader["corr"]);
                            }
                            else
                            {
                                correctCount = 0;
                            }
                        }
                    }
                }
                int wrongCount = totalQ - correctCount;

                // ══ DISPLAY ══
                pnlResult.Visible = true;
                pnlError.Visible = false;
                litPageTitle.Text = T("Quiz Result", "Keputusan Kuiz");

                // Hero
                if (passed)
                {
                    divHero.Attributes["class"] = "st-quizresult-hero passed";
                }
                else
                {
                    divHero.Attributes["class"] = "st-quizresult-hero failed";
                }

                if (passed)
                {
                    litHeroIcon.Text = "<i class=\"bi bi-trophy-fill\"></i>";
                }
                else
                {
                    litHeroIcon.Text = "<i class=\"bi bi-emoji-neutral-fill\"></i>";
                }

                // Hero message based on percentage
                if (percentage >= 90)
                {
                    litHeroTitle.Text = T("Excellent!", "Cemerlang!");
                    litHeroSub.Text = T("Excellent work! You are a Science star!", "Cemerlang! Anda bintang Sains!");
                }
                else if (percentage >= 70)
                {
                    litHeroTitle.Text = T("Great Job!", "Bagus!");
                    litHeroSub.Text = T("Great job! You passed this quiz.", "Bagus! Anda lulus kuiz ini.");
                }
                else
                {
                    litHeroTitle.Text = T("Keep Trying!", "Teruskan Usaha!");
                    litHeroSub.Text = T("Keep trying. Review the answers and try again.", "Teruskan usaha. Semak jawapan dan cuba lagi.");
                }

                // Score
                litScorePct.Text = Math.Round(percentage, 0) + "%";

                // Stars
                int starCount = 0;
                if (percentage >= 90)
                {
                    starCount = 3;
                }
                else if (percentage >= 70)
                {
                    starCount = 2;
                }
                else if (percentage >= 50)
                {
                    starCount = 1;
                }

                string starsHtml = "";
                for (int i = 0; i < 3; i++)
                {
                    if (i < starCount)
                    {
                        starsHtml += "<i class=\"bi bi-star-fill st-quizresult-star-on\"></i>";
                    }
                    else
                    {
                        starsHtml += "<i class=\"bi bi-star st-quizresult-star-off\"></i>";
                    }
                }
                litStars.Text = starsHtml;

                // Stats
                litStatCorrect.Text = correctCount.ToString();
                litStatCorrectLbl.Text = T("Correct Answers", "Jawapan Betul");
                litStatWrong.Text = wrongCount.ToString();
                litStatWrongLbl.Text = T("Wrong Answers", "Jawapan Salah");
                litStatTotal.Text = totalQ.ToString();
                litStatTotalLbl.Text = T("Total Questions", "Jumlah Soalan");
                litStatScore.Text = score + "/" + totalMarks;
                litStatScoreLbl.Text = T("Score", "Markah");
                litStatAttempt.Text = "#" + attemptNo;
                litStatAttemptLbl.Text = T("Attempt", "Percubaan");

                // Quiz type message
                pnlMessage.Visible = true;
                switch (quizType)
                {
                    case "Practice":
                        litMsgTitle.Text = T("Practice Quiz", "Kuiz Latihan");
                        litMessage.Text = T("This practice helps you prepare for your unit and level quizzes.",
                                            "Latihan ini membantu anda bersedia untuk kuiz unit dan penilaian tahap.");
                        break;
                    case "Unit":
                        litMsgTitle.Text = T("Unit Quiz", "Kuiz Unit");
                        if (passed)
                        {
                            litMessage.Text = T("You passed the unit quiz. Keep going to the next learning activity.",
                                "Anda lulus kuiz unit. Teruskan ke aktiviti pembelajaran seterusnya.");
                        }
                        else
                        {
                            litMessage.Text = T("Review this unit and try the quiz again.",
                                "Ulang kaji unit ini dan cuba kuiz sekali lagi.");
                        }
                        break;
                    case "Level":
                        litMsgTitle.Text = T("Level Assessment", "Penilaian Tahap");
                        if (passed)
                        {
                            litMessage.Text = T("You passed the level assessment. Your certificate may now be unlocked.",
                                "Anda lulus penilaian tahap. Sijil anda mungkin boleh dibuka sekarang.");
                        }
                        else
                        {
                            litMessage.Text = T("Review the level topics and try again when you are ready.",
                                "Ulang kaji topik tahap ini dan cuba lagi apabila anda bersedia.");
                        }
                        break;
                    default:
                        pnlMessage.Visible = false;
                        break;
                }

                // Action buttons
                litReviewBtn.Text = T("Review Answers", "Semak Jawapan");
                litRetryBtn.Text = T("Try Again", "Cuba Lagi");
                litProgressBtn.Text = T("Progress & Rewards", "Kemajuan & Ganjaran");
                litHistoryBtn.Text = T("Quiz History", "Sejarah Kuiz");
                lnkReview.HRef = ResolveUrl("~/Student/QuizResult.aspx?resultId=" + resultId).Replace("QuizResult", "QuizReview");
                lnkRetry.HRef = ResolveUrl("~/Student/Quiz.aspx?quizId=" + quizId);

                // Back button based on type
                switch (quizType)
                {
                    case "Practice":
                        litBackBtn.Text = T("Practice Library", "Perpustakaan Latihan");
                        lnkBack.HRef = ResolveUrl("~/Student/PracticeLibrary.aspx");
                        break;
                    case "Unit":
                        litBackBtn.Text = T("Back to Unit", "Kembali ke Unit");
                        if (!string.IsNullOrEmpty(unitId))
                        {
                            lnkBack.HRef = ResolveUrl("~/Student/UnitDetails.aspx?unitId=" + unitId);
                        }
                        else
                        {
                            lnkBack.HRef = ResolveUrl("~/Student/MyLearning.aspx");
                        }
                        break;
                    case "Level":
                        litBackBtn.Text = T("Back to Level", "Kembali ke Tahap");
                        if (!string.IsNullOrEmpty(levelId))
                        {
                            lnkBack.HRef = ResolveUrl("~/Student/LevelDetails.aspx?levelId=" + levelId);
                        }
                        else
                        {
                            lnkBack.HRef = ResolveUrl("~/Student/MyLearning.aspx");
                        }
                        break;
                    default:
                        litBackBtn.Text = T("My Learning", "Pembelajaran Saya");
                        lnkBack.HRef = ResolveUrl("~/Student/MyLearning.aspx");
                        break;
                }

                // Retry visible for Practice always, or if failed
                pnlRetry.Visible = (quizType == "Practice" || !passed);
            }
        }

        private void ShowError(string msg)
        {
            pnlError.Visible = true;
            pnlResult.Visible = false;
            litErrorTitle.Text = T("Error", "Ralat");
            litError.Text = HttpUtility.HtmlEncode(msg);
            litErrBtn.Text = T("Back", "Kembali");
        }

        private static string S(DataRow row, string col)
        {
            if (row[col] != null && row[col] != DBNull.Value)
            {
                return row[col].ToString();
            }
            return "";
        }
    }
}
