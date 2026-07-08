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
    public partial class AIStudyCompanion1 : Page
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

        // ── Language initialisation ───────────────────────────────────
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
            litPageTitle.Text = T("AI Study Companion", "Rakan Pembelajaran AI");
            litHeroTitle.Text = T("AI Study Companion", "Rakan Pembelajaran AI");
            litHeroSub.Text = T("Your smart learning buddy is here to guide your next step.",
                                "Rakan pembelajaran pintar anda sedia membantu langkah seterusnya.");
            litHealthTitle.Text = T("Learning Health", "Kesihatan Pembelajaran");
            litAvgScoreLbl.Text = T("Average Quiz Score", "Purata Skor Kuiz");
            litTotalAttemptsLbl.Text = T("Total Quiz Attempts", "Jumlah Percubaan Kuiz");
            litStrongTopicsLbl.Text = T("Strong Topics", "Topik Kuat");
            litWeakTopicsLbl.Text = T("Weak Topics", "Topik Lemah");
            litHealthEmpty.Text = T("Complete more quizzes to unlock your personalised learning analysis.",
                                    "Selesaikan lebih banyak kuiz untuk membuka analisis pembelajaran peribadi anda.");
            litStrongTitle.Text = T("Strong Topics", "Topik Kuat");
            litStrongEmptyTitle.Text = T("Strong Topics", "Topik Kuat");
            litStrongEmpty.Text = T("Your strong topics will appear here after you attempt more quizzes.",
                                    "Topik kuat anda akan dipaparkan di sini selepas anda menjawab lebih banyak kuiz.");
            litWeakTitle.Text = T("Weak Topics", "Topik Lemah");
            litWeakEmptyTitle.Text = T("Weak Topics", "Topik Lemah");
            litWeakEmpty.Text = T("No weak topics detected yet. Keep learning!",
                                  "Tiada topik lemah dikesan buat masa ini. Teruskan belajar!");
            litRecommendTitle.Text = T("Recommended Next Steps", "Langkah Seterusnya Dicadangkan");
            litTipsTitle.Text = T("Study Tips", "Tip Belajar");
            litEmptyTitle.Text = T("Start your learning journey!",
                                   "Mulakan perjalanan pembelajaran anda!");
            litEmptyDesc.Text = T("Start your learning journey first to unlock your AI companion's insights.",
                                  "Mulakan perjalanan pembelajaran anda dahulu untuk membuka pandangan rakan AI anda.");
        }

        // ── Load page data ────────────────────────────────────────────
        private void LoadPage()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                if (!Tbl(conn, "Student"))
                {
                    ShowEmptyState();
                    return;
                }

                // 1. Get student data
                string userId = Session["userId"] as string;
                string studentId = null, name = "", nickname = "", currentlevelId = "", personalityId = "";

                const string sqlStudent = @"SELECT studentId, name, nickname, currentlevelId, personalityId 
                                            FROM Student WHERE userId = @userId";
                using (var cmd = new SqlCommand(sqlStudent, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    using (var rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            studentId = rdr["studentId"]?.ToString();
                            name = rdr["name"]?.ToString() ?? "";
                            nickname = rdr["nickname"]?.ToString() ?? "";
                            currentlevelId = rdr["currentlevelId"]?.ToString() ?? "";
                            personalityId = rdr["personalityId"]?.ToString() ?? "";
                        }
                    }
                }

                if (string.IsNullOrEmpty(studentId))
                {
                    ShowEmptyState();
                    return;
                }

                // 2. Get personality info
                string personalityName = "";
                string learningStyle = "";
                if (Tbl(conn, "Personality") && !string.IsNullOrEmpty(personalityId))
                {
                    const string sqlP = @"SELECT personalityNameEN, personalityNameBM, 
                                          learningStyleEN, learningStyleBM FROM Personality WHERE personalityId = @pid";
                    using (var cmd = new SqlCommand(sqlP, conn))
                    {
                        cmd.Parameters.AddWithValue("@pid", personalityId);
                        using (var rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                personalityName = T(rdr["personalityNameEN"]?.ToString() ?? "",
                                                   rdr["personalityNameBM"]?.ToString() ?? "");
                                learningStyle = T(rdr["learningStyleEN"]?.ToString() ?? "",
                                                  rdr["learningStyleBM"]?.ToString() ?? "");
                            }
                        }
                    }
                }

                // 3. Get level info
                string levelName = "";
                if (Tbl(conn, "Level") && !string.IsNullOrEmpty(currentlevelId))
                {
                    const string sqlL = "SELECT levelNameEN, levelNameBM FROM Level WHERE levelId = @lid";
                    using (var cmd = new SqlCommand(sqlL, conn))
                    {
                        cmd.Parameters.AddWithValue("@lid", currentlevelId);
                        using (var rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                levelName = T(rdr["levelNameEN"]?.ToString() ?? "",
                                             rdr["levelNameBM"]?.ToString() ?? "");
                            }
                        }
                    }
                }

                // 4. Set hero card
                string displayName = !string.IsNullOrEmpty(nickname) ? nickname : name;
                litStudentName.Text = HttpUtility.HtmlEncode(displayName);
                litCurrentLevel.Text = HttpUtility.HtmlEncode(levelName);
                litPersonality.Text = HttpUtility.HtmlEncode(personalityName);
                litAIMessage.Text = GetAIMessage(personalityId);

                // 5. Try load AILearningAnalysis
                decimal avgScore = 0;
                int totalAttempts = 0;
                string strongTopics = "";
                string weakTopics = "";
                string overallSummary = "";
                bool hasAnalysis = false;

                if (Tbl(conn, "AILearningAnalysis"))
                {
                    const string sqlAI = @"SELECT TOP 1 avgQuizScore, totalQuizAttempts, 
                                           strongTopics, weakTopics, overallSummary
                                           FROM AILearningAnalysis 
                                           WHERE studentId = @s AND isLatest = 1";
                    using (var cmd = new SqlCommand(sqlAI, conn))
                    {
                        cmd.Parameters.AddWithValue("@s", studentId);
                        using (var rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                hasAnalysis = true;
                                avgScore = rdr["avgQuizScore"] != DBNull.Value 
                                    ? Convert.ToDecimal(rdr["avgQuizScore"]) : 0;
                                totalAttempts = rdr["totalQuizAttempts"] != DBNull.Value 
                                    ? Convert.ToInt32(rdr["totalQuizAttempts"]) : 0;
                                strongTopics = rdr["strongTopics"]?.ToString() ?? "";
                                weakTopics = rdr["weakTopics"]?.ToString() ?? "";
                                overallSummary = rdr["overallSummary"]?.ToString() ?? "";
                            }
                        }
                    }
                }

                // 6. Fallback from QuizResult and LessonProgress if no analysis
                int lessonsDone = 0;
                int quizAttempts = 0;

                if (!hasAnalysis)
                {
                    if (Tbl(conn, "QuizResult"))
                    {
                        const string sqlFallback = @"SELECT AVG(percentage) AS avgPct, COUNT(*) AS cnt 
                                                     FROM QuizResult WHERE studentId = @s";
                        using (var cmd = new SqlCommand(sqlFallback, conn))
                        {
                            cmd.Parameters.AddWithValue("@s", studentId);
                            using (var rdr = cmd.ExecuteReader())
                            {
                                if (rdr.Read())
                                {
                                    avgScore = rdr["avgPct"] != DBNull.Value 
                                        ? Convert.ToDecimal(rdr["avgPct"]) : 0;
                                    quizAttempts = rdr["cnt"] != DBNull.Value 
                                        ? Convert.ToInt32(rdr["cnt"]) : 0;
                                    totalAttempts = quizAttempts;
                                }
                            }
                        }
                    }

                    if (Tbl(conn, "LessonProgress"))
                    {
                        const string sqlLP = @"SELECT COUNT(*) FROM LessonProgress 
                                               WHERE studentId = @s AND isCompleted = 1";
                        using (var cmd = new SqlCommand(sqlLP, conn))
                        {
                            cmd.Parameters.AddWithValue("@s", studentId);
                            object result = cmd.ExecuteScalar();
                            lessonsDone = result != null && result != DBNull.Value 
                                ? Convert.ToInt32(result) : 0;
                        }
                    }
                }
                else
                {
                    // Get lessonsDone even with analysis for recommendations
                    if (Tbl(conn, "LessonProgress"))
                    {
                        const string sqlLP = @"SELECT COUNT(*) FROM LessonProgress 
                                               WHERE studentId = @s AND isCompleted = 1";
                        using (var cmd = new SqlCommand(sqlLP, conn))
                        {
                            cmd.Parameters.AddWithValue("@s", studentId);
                            object result = cmd.ExecuteScalar();
                            lessonsDone = result != null && result != DBNull.Value 
                                ? Convert.ToInt32(result) : 0;
                        }
                    }
                    quizAttempts = totalAttempts;
                }

                // Check if student has any data at all
                if (totalAttempts == 0 && lessonsDone == 0 && !hasAnalysis)
                {
                    ShowEmptyState();
                    return;
                }

                // Display health summary
                pnlEmpty.Visible = false;

                if (totalAttempts > 0 || hasAnalysis)
                {
                    pnlHealth.Visible = true;
                    pnlHealthEmpty.Visible = false;
                    litAvgScore.Text = avgScore.ToString("0.0") + "%";
                    litTotalAttempts.Text = totalAttempts.ToString();

                    // Strong topics
                    if (!string.IsNullOrWhiteSpace(strongTopics))
                    {
                        litStrongTopics.Text = FormatChips(strongTopics, "green");
                        pnlStrong.Visible = true;
                        pnlStrongEmpty.Visible = false;
                        litStrongList.Text = FormatTopicList(strongTopics, "green");
                    }
                    else
                    {
                        litStrongTopics.Text = "<span class='st-ai-chip st-ai-chip--green'>—</span>";
                        pnlStrong.Visible = false;
                        pnlStrongEmpty.Visible = true;
                    }

                    // Weak topics
                    if (!string.IsNullOrWhiteSpace(weakTopics))
                    {
                        litWeakTopics.Text = FormatChips(weakTopics, "orange");
                        pnlWeak.Visible = true;
                        pnlWeakEmpty.Visible = false;
                        litWeakList.Text = FormatTopicList(weakTopics, "orange");
                    }
                    else
                    {
                        litWeakTopics.Text = "<span class='st-ai-chip st-ai-chip--orange'>—</span>";
                        pnlWeak.Visible = false;
                        pnlWeakEmpty.Visible = true;
                    }
                }
                else
                {
                    pnlHealth.Visible = false;
                    pnlHealthEmpty.Visible = true;
                    pnlStrong.Visible = false;
                    pnlStrongEmpty.Visible = true;
                    pnlWeak.Visible = false;
                    pnlWeakEmpty.Visible = true;
                }

                // 7. Build recommendations
                var recommendations = BuildRecommendations(personalityId, weakTopics, avgScore, lessonsDone, quizAttempts);
                if (recommendations.Count > 0)
                {
                    pnlRecommend.Visible = true;
                    rptRecommendations.DataSource = recommendations;
                    rptRecommendations.DataBind();

                    if (!string.IsNullOrWhiteSpace(overallSummary))
                    {
                        litExplanation.Text = HttpUtility.HtmlEncode(overallSummary);
                    }
                    else
                    {
                        litExplanation.Text = T(
                            "These recommendations are based on your learning patterns and personality type.",
                            "Cadangan ini berdasarkan corak pembelajaran dan jenis personaliti anda.");
                    }
                }
                else
                {
                    pnlRecommend.Visible = false;
                }

                // 8. Study tips based on personality
                var tips = GetStudyTips(personalityId);
                litTip1.Text = tips.Count > 0 ? tips[0] : "";
                litTip2.Text = tips.Count > 1 ? tips[1] : "";
                litTip3.Text = tips.Count > 2 ? tips[2] : "";
            }
        }

        // ── Show empty state ──────────────────────────────────────────
        private void ShowEmptyState()
        {
            pnlEmpty.Visible = true;
            pnlHealth.Visible = false;
            pnlHealthEmpty.Visible = false;
            pnlStrong.Visible = false;
            pnlStrongEmpty.Visible = false;
            pnlWeak.Visible = false;
            pnlWeakEmpty.Visible = false;
            pnlRecommend.Visible = false;
        }

        // ── Format chips for health cards ─────────────────────────────
        private string FormatChips(string topics, string color)
        {
            if (string.IsNullOrWhiteSpace(topics)) return "";
            string[] items = topics.Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries);
            string cssClass = color == "green" ? "st-ai-chip st-ai-chip--green" : "st-ai-chip st-ai-chip--orange";
            var sb = new System.Text.StringBuilder();
            foreach (string item in items)
            {
                string trimmed = item.Trim();
                if (!string.IsNullOrEmpty(trimmed))
                {
                    sb.AppendFormat("<span class='{0}'>{1}</span>", cssClass, HttpUtility.HtmlEncode(trimmed));
                }
            }
            return sb.ToString();
        }

        // ── Format topic list for detail sections ─────────────────────
        private string FormatTopicList(string topics, string color)
        {
            if (string.IsNullOrWhiteSpace(topics)) return "";
            string[] items = topics.Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries);
            string icon = color == "green" ? "<i class=\"bi bi-check-circle-fill\" style=\"color:#10B981;\"></i>" : "<i class=\"bi bi-pin-fill\" style=\"color:#F59E0B;\"></i>";
            var sb = new System.Text.StringBuilder();
            foreach (string item in items)
            {
                string trimmed = item.Trim();
                if (!string.IsNullOrEmpty(trimmed))
                {
                    sb.AppendFormat("{0} {1}<br/>", icon, HttpUtility.HtmlEncode(trimmed));
                }
            }
            return sb.ToString();
        }

        // ── AI Message based on personality ───────────────────────────
        private string GetAIMessage(string personalityId)
        {
            switch (personalityId)
            {
                case "P001": // Achiever
                    return T("I can help you earn your next badge faster.",
                                     "Saya boleh membantu anda memperoleh lencana seterusnya dengan lebih cepat.");
                case "P002": // Creative
                    return T("Let's explore Science in a fun and visual way.",
                                     "Jom terokai Sains dengan cara yang menyeronokkan dan visual.");
                case "P003": // Thinker
                    return T("Let's understand your mistakes and improve step by step.",
                                     "Jom fahami kesilapan anda dan tambah baik langkah demi langkah.");
                case "P004": // Go-Getter
                    return T("Ready for your next challenge?",
                                     "Bersedia untuk cabaran seterusnya?");
                case "P005": // Chill Learner
                    return T("No rush. Let's learn calmly together.",
                                     "Tidak perlu tergesa-gesa. Jom belajar dengan tenang bersama.");
                case "P006": // Socializer
                    return T("Let's learn together with your friends and teachers.",
                                     "Jom belajar bersama rakan dan guru anda.");
                default:
                    return T("I'm here to help you learn better!",
                                     "Saya di sini untuk membantu anda belajar dengan lebih baik!");
            }
        }

        // ── Build recommendations ─────────────────────────────────────
        private List<object> BuildRecommendations(string personalityId, string weakTopics,
            decimal avgScore, int lessonsDone, int quizAttempts)
        {
            var list = new List<object>();
            string goText = T("Let's Go!", "Jom!");

            // If weak topics exist, recommend practice
            if (!string.IsNullOrWhiteSpace(weakTopics))
            {
                list.Add(new
                {
                    Icon = "<i class=\"bi bi-pencil-square\"></i>",
                    Title = T("Practice Weak Topics", "Latih Topik Lemah"),
                    Reason = T("Focus on your weak areas to improve your overall score.",
                               "Fokus pada kawasan lemah anda untuk meningkatkan skor keseluruhan."),
                    Url = ResolveUrl("~/Student/PracticeLibrary.aspx"),
                    BtnText = goText
                });
            }

            // If few lessons completed
            if (lessonsDone < 3)
            {
                list.Add(new
                {
                    Icon = "<i class=\"bi bi-book\"></i>",
                    Title = T("Continue Learning", "Teruskan Belajar"),
                    Reason = T("You have more lessons to explore. Keep going!",
                               "Anda mempunyai lebih banyak pelajaran untuk diterokai. Teruskan!"),
                    Url = ResolveUrl("~/Student/MyLearning.aspx"),
                    BtnText = goText
                });
            }

            // If few quiz attempts
            if (quizAttempts < 3)
            {
                list.Add(new
                {
                    Icon = "<i class=\"bi bi-clipboard-check\"></i>",
                    Title = T("Try More Quizzes", "Cuba Lebih Banyak Kuiz"),
                    Reason = T("Quizzes help reinforce what you've learned. Try a few more!",
                               "Kuiz membantu mengukuhkan apa yang anda pelajari. Cuba lebih banyak!"),
                    Url = ResolveUrl("~/Student/PracticeLibrary.aspx"),
                    BtnText = goText
                });
            }

            // Personality-specific recommendations
            switch (personalityId)
            {
                case "P001": // Achiever → Progress & Rewards
                    list.Add(new
                    {
                        Icon = "<i class=\"bi bi-trophy\"></i>",
                        Title = T("Check Your Progress", "Semak Kemajuan Anda"),
                        Reason = T("See how close you are to your next achievement!",
                                   "Lihat sejauh mana anda daripada pencapaian seterusnya!"),
                        Url = ResolveUrl("~/Student/Progress.aspx"),
                        BtnText = goText
                    });
                    break;
                case "P002": // Creative → Virtual Labs
                    list.Add(new
                    {
                        Icon = "<i class=\"bi bi-eyedropper\"></i>",
                        Title = T("Explore Virtual Labs", "Terokai Makmal Maya"),
                        Reason = T("Hands-on experiments to spark your creativity!",
                                   "Eksperimen secara praktikal untuk mencetus kreativiti anda!"),
                        Url = ResolveUrl("~/Student/VirtualLabs.aspx"),
                        BtnText = goText
                    });
                    break;
                case "P003": // Thinker → Lesson review
                    list.Add(new
                    {
                        Icon = "<i class=\"bi bi-search\"></i>",
                        Title = T("Review Your Lessons", "Ulang Kaji Pelajaran"),
                        Reason = T("Go deeper into topics to strengthen your understanding.",
                                   "Dalami topik untuk mengukuhkan pemahaman anda."),
                        Url = ResolveUrl("~/Student/MyLearning.aspx"),
                        BtnText = goText
                    });
                    break;
                case "P004": // Go-Getter → Practice more
                    list.Add(new
                    {
                        Icon = "<i class=\"bi bi-lightning-charge\"></i>",
                        Title = T("Take on a Challenge", "Terima Cabaran"),
                        Reason = T("Push yourself with harder quizzes!",
                                   "Uji diri anda dengan kuiz yang lebih mencabar!"),
                        Url = ResolveUrl("~/Student/PracticeLibrary.aspx"),
                        BtnText = goText
                    });
                    break;
                case "P005": // Chill Learner → Continue Learning
                    list.Add(new
                    {
                        Icon = "<i class=\"bi bi-flower1\"></i>",
                        Title = T("Learn at Your Pace", "Belajar Mengikut Kadar Anda"),
                        Reason = T("No rush — pick up where you left off.",
                                   "Tidak perlu tergesa — sambung dari mana anda berhenti."),
                        Url = ResolveUrl("~/Student/MyLearning.aspx"),
                        BtnText = goText
                    });
                    break;
                case "P006": // Socializer → Forum / Live
                    list.Add(new
                    {
                        Icon = "<i class=\"bi bi-chat-dots\"></i>",
                        Title = T("Join the Forum", "Sertai Forum"),
                        Reason = T("Discuss and learn together with your peers!",
                                   "Bincang dan belajar bersama rakan sebaya anda!"),
                        Url = ResolveUrl("~/Student/Forum.aspx"),
                        BtnText = goText
                    });
                    break;
            }

            return list;
        }

        // ── Study tips based on personality ────────────────────────────
        private List<string> GetStudyTips(string personalityId)
        {
            var tips = new List<string>();

            switch (personalityId)
            {
                case "P001": // Achiever
                    tips.Add(T("Set small daily goals and track your streaks to stay motivated.",
                               "Tetapkan matlamat harian kecil dan jejaki rekod anda untuk kekal bermotivasi."));
                    tips.Add(T("Challenge yourself with harder quizzes after mastering easy ones.",
                               "Cabari diri anda dengan kuiz lebih sukar selepas menguasai yang mudah."));
                    tips.Add(T("Celebrate your wins! Check your badges and XP regularly.",
                               "Raikan kemenangan anda! Semak lencana dan XP anda secara berkala."));
                    break;
                case "P002": // Creative
                    tips.Add(T("Draw mind maps or diagrams to visualise Science concepts.",
                               "Lukis peta minda atau gambar rajah untuk memvisualisasikan konsep Sains."));
                    tips.Add(T("Try the Virtual Labs — they're great for hands-on exploration!",
                               "Cuba Makmal Maya — sesuai untuk penerokaan secara praktikal!"));
                    tips.Add(T("Create your own study notes with colours and doodles.",
                               "Cipta nota belajar anda sendiri dengan warna dan lukisan."));
                    break;
                case "P003": // Thinker
                    tips.Add(T("Review your mistakes after each quiz to understand why.",
                               "Ulang kaji kesilapan anda selepas setiap kuiz untuk memahami sebabnya."));
                    tips.Add(T("Take notes and summarise lessons in your own words.",
                               "Ambil nota dan rumuskan pelajaran dalam perkataan anda sendiri."));
                    tips.Add(T("Ask 'why' questions — understanding the reason helps you remember.",
                               "Tanya soalan 'kenapa' — memahami sebab membantu anda mengingat."));
                    break;
                case "P004": // Go-Getter
                    tips.Add(T("Time yourself during quizzes to build speed and accuracy.",
                               "Ukur masa anda semasa kuiz untuk membina kelajuan dan ketepatan."));
                    tips.Add(T("Try to beat your previous best score on each quiz.",
                               "Cuba atasi skor terbaik anda sebelum ini pada setiap kuiz."));
                    tips.Add(T("Don't skip lessons — each one builds your foundation.",
                               "Jangan langkau pelajaran — setiap satu membina asas anda."));
                    break;
                case "P005": // Chill Learner
                    tips.Add(T("Study in short 15-minute sessions with breaks in between.",
                               "Belajar dalam sesi pendek 15 minit dengan rehat di antaranya."));
                    tips.Add(T("Pick one topic per day and explore it deeply.",
                               "Pilih satu topik sehari dan terokai secara mendalam."));
                    tips.Add(T("It's okay to go slow. Consistency matters more than speed.",
                               "Tidak mengapa untuk perlahan. Konsistensi lebih penting daripada kelajuan."));
                    break;
                case "P006": // Socializer
                    tips.Add(T("Study with a friend or discuss topics in the Forum.",
                               "Belajar bersama rakan atau bincangkan topik di Forum."));
                    tips.Add(T("Teach what you've learned to someone else — it helps you remember!",
                               "Ajar apa yang anda pelajari kepada orang lain — ia membantu anda mengingat!"));
                    tips.Add(T("Join Live Sessions to interact with your teacher and classmates.",
                               "Sertai Sesi Langsung untuk berinteraksi dengan guru dan rakan sekelas."));
                    break;
                default:
                    tips.Add(T("Review your lessons regularly to keep concepts fresh.",
                               "Ulang kaji pelajaran anda secara berkala untuk mengekalkan konsep."));
                    tips.Add(T("Practice makes perfect — try a quiz every day!",
                               "Latihan menjadikan sempurna — cuba satu kuiz setiap hari!"));
                    tips.Add(T("Take breaks and stay hydrated while studying.",
                               "Ambil rehat dan kekal terhidrat semasa belajar."));
                    break;
            }

            return tips;
        }

        // ── Table exists helper ───────────────────────────────────────
        /// <summary>
        /// Returns true if the given table exists in the current database.
        /// Uses INFORMATION_SCHEMA so it never throws on a missing table.
        /// </summary>
        private static bool Tbl(SqlConnection conn, string tableName)
        {
            const string sql = @"
                SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
                WHERE  TABLE_NAME = @tableName
                AND    TABLE_TYPE = 'BASE TABLE'";
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@tableName", tableName);
                return (int)cmd.ExecuteScalar() > 0;
            }
        }
    }
}
