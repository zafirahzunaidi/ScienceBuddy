using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Net;
using System.Text;
using System.Web.Script.Serialization;
using ScienceBuddy.Services;

namespace ScienceBuddy.Student
{
    public partial class AIStudyCompanion1 : Page
    {
        // Connection string
        private string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString; }
        }

        // Personality visual properties
        public string PersonalityAvatar = "";
        public string PersonalityColour = "#7C3AED";

        // Quiz metadata properties
        public string GeneratedQuizTitle = "";
        public string GeneratedQuizDate = "";
        public string GeneratedQuizScore = "";

        // Language helper
        public string CurrentLanguage = "EN";

        public string T(string en, string bm)
        {
            if (CurrentLanguage == "BM")
            {
                return bm;
            }
            return en;
        }

        // Page Load
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null ||
                Session["role"].ToString() != "Student")
            {
                Response.Redirect("~/Login.aspx", false);
                return;
            }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";

            InitLang();

            if (!IsPostBack)
            {
                SetLabels();
                LoadPage();

                Session["AIChatHistory"] = new List<Dictionary<string, string>>();
                AppendAIMessage("assistant", T(
                    "Hi! I am your AI Study Companion. Ask me anything about your Science lessons.",
                    "Hai! Saya Rakan Pembelajaran AI anda. Tanya saya apa-apa tentang pelajaran Sains anda."));
            }
        }

        // Language initialisation
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

        // Set bilingual labels
        private void SetLabels()
        {
            litPageTitle.Text = T("AI Study Companion", "Rakan Pembelajaran AI");
            litHeroTitle.Text = T("AI Study Companion", "Rakan Pembelajaran AI");
            litHealthTitle.Text = T("AI noticed this about you", "AI perasan ini tentang anda");
            litAvgScoreLbl.Text = T("Latest Score", "Skor Terkini");
            litTotalAttemptsLbl.Text = T("Previous Avg", "Purata Sebelum");
            litStrongTopicsLbl.Text = T("Change", "Perubahan");
            litWeakTopicsLbl.Text = T("quizzes", "kuiz");
            litStrongTitle.Text = T("Your Win", "Kemenangan Anda");
            litStrongEmpty.Text = T("Keep going to discover your strengths!",
                                    "Teruskan untuk mengetahui kekuatan anda!");
            litWeakTitle.Text = T("Your Focus", "Fokus Anda");
            litWeakEmpty.Text = T("No weak topics yet. Great job!",
                                  "Tiada topik lemah lagi. Bagus!");
            litRecommendTitle.Text = T("Your plan for today", "Pelan anda untuk hari ini");
            litTipsTitle.Text = T("Your 3-Step Mission", "Misi 3 Langkah Anda");
            litChatTitle.Text = T("Ask your AI Coach", "Tanya Coach AI anda");
            litChatSub.Text = T("I know your latest results. Ask what to learn next!",
                                "Saya tahu keputusan terkini anda. Tanya apa yang perlu dipelajari seterusnya!");
            litChatNote.Text = T("AI can make mistakes, so always check with your teacher or lesson notes.",
                                 "AI boleh membuat kesilapan, jadi sentiasa semak dengan guru atau nota pelajaran anda.");
            litEmptyTitle.Text = T("Start your learning journey!",
                                   "Mulakan perjalanan pembelajaran anda!");
            litEmptyDesc.Text = T("Start your learning journey first to unlock your AI companion's insights.",
                                  "Mulakan perjalanan pembelajaran anda dahulu untuk membuka pandangan rakan AI anda.");
            litHealthEmpty.Text = T("Complete more quizzes to unlock your personalised learning analysis.",
                                    "Selesaikan lebih banyak kuiz untuk membuka analisis pembelajaran peribadi anda.");
        }

        // Load page data
        private void LoadPage()
        {
            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();

                if (!Tbl(connection, "Student"))
                {
                    ShowEmptyState();
                    return;
                }

                // 1. Get student data
                string userId = Session["userId"] as string;
                string studentId = null;
                string name = "";
                string nickname = "";
                string currentlevelId = "";
                string personalityId = "";

                const string sqlStudent = @"SELECT studentId, name, nickname, currentlevelId, personalityId 
                                            FROM Student WHERE userId = @userId";
                using (SqlCommand command = new SqlCommand(sqlStudent, connection))
                {
                    command.Parameters.AddWithValue("@userId", userId);
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            studentId = reader["studentId"] != null ? reader["studentId"].ToString() : null;
                            name = reader["name"] != DBNull.Value ? reader["name"].ToString() : "";
                            nickname = reader["nickname"] != DBNull.Value ? reader["nickname"].ToString() : "";
                            currentlevelId = reader["currentlevelId"] != DBNull.Value ? reader["currentlevelId"].ToString() : "";
                            personalityId = reader["personalityId"] != DBNull.Value ? reader["personalityId"].ToString() : "";
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
                if (Tbl(connection, "Personality") && !string.IsNullOrEmpty(personalityId))
                {
                    const string sqlP = @"SELECT personalityNameEN, personalityNameBM, 
                                          learningStyleEN, learningStyleBM, avatar, colour 
                                          FROM Personality WHERE personalityId = @pid";
                    using (SqlCommand command = new SqlCommand(sqlP, connection))
                    {
                        command.Parameters.AddWithValue("@pid", personalityId);
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string nameEN = reader["personalityNameEN"] != DBNull.Value ? reader["personalityNameEN"].ToString() : "";
                                string nameBM = reader["personalityNameBM"] != DBNull.Value ? reader["personalityNameBM"].ToString() : "";
                                personalityName = T(nameEN, nameBM);

                                string styleEN = reader["learningStyleEN"] != DBNull.Value ? reader["learningStyleEN"].ToString() : "";
                                string styleBM = reader["learningStyleBM"] != DBNull.Value ? reader["learningStyleBM"].ToString() : "";
                                learningStyle = T(styleEN, styleBM);

                                if (reader["avatar"] != null && reader["avatar"] != DBNull.Value)
                                {
                                    string avatar = reader["avatar"].ToString().Trim();
                                    if (!string.IsNullOrEmpty(avatar))
                                    {
                                        string avatarPath = "";
                                        if (avatar.StartsWith("~/"))
                                            avatarPath = avatar;
                                        else if (avatar.StartsWith("Images/"))
                                            avatarPath = "~/" + avatar;
                                        else
                                            avatarPath = "~/Images/Personality/" + Path.GetFileName(avatar);

                                        string physicalPath = Server.MapPath(avatarPath);
                                        if (File.Exists(physicalPath))
                                            PersonalityAvatar = ResolveUrl(avatarPath);
                                    }
                                }

                                if (reader["colour"] != null && reader["colour"] != DBNull.Value)
                                {
                                    string colour = reader["colour"].ToString().Trim();
                                    if (System.Text.RegularExpressions.Regex.IsMatch(colour, "^#[0-9A-Fa-f]{6}$"))
                                        PersonalityColour = colour;
                                }
                            }
                        }
                    }
                }

                // 3. Get level info
                string levelName = "";
                if (Tbl(connection, "Level") && !string.IsNullOrEmpty(currentlevelId))
                {
                    const string sqlL = "SELECT levelNameEN, levelNameBM FROM Level WHERE levelId = @lid";
                    using (SqlCommand command = new SqlCommand(sqlL, connection))
                    {
                        command.Parameters.AddWithValue("@lid", currentlevelId);
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string lvlEN = reader["levelNameEN"] != DBNull.Value ? reader["levelNameEN"].ToString() : "";
                                string lvlBM = reader["levelNameBM"] != DBNull.Value ? reader["levelNameBM"].ToString() : "";
                                levelName = T(lvlEN, lvlBM);
                            }
                        }
                    }
                }

                // 4. Set hero card
                string displayName = !string.IsNullOrEmpty(nickname) ? nickname : name;
                litStudentName.Text = HttpUtility.HtmlEncode(displayName);
                litCurrentLevel.Text = HttpUtility.HtmlEncode(levelName);
                litPersonality.Text = HttpUtility.HtmlEncode(personalityName);

                // 5. Load AILearningAnalysis
                decimal avgScore = 0;
                int totalAttempts = 0;
                string strongTopics = "";
                string weakTopics = "";
                LearningAnalysisData generatedAnalysis = null;
                bool hasAnalysis = false;

                if (Tbl(connection, "AILearningAnalysis"))
                {
                    const string sqlAI = @"SELECT TOP 1
                                           avgQuizScore, totalQuizAttempts,
                                           strongTopics, weakTopics,
                                           overallSummary, analysisJson
                                           FROM AILearningAnalysis
                                           WHERE studentId = @s AND isLatest = 1";
                    using (SqlCommand command = new SqlCommand(sqlAI, connection))
                    {
                        command.Parameters.AddWithValue("@s", studentId);
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                hasAnalysis = true;
                                avgScore = reader["avgQuizScore"] != DBNull.Value ? Convert.ToDecimal(reader["avgQuizScore"]) : 0;
                                totalAttempts = reader["totalQuizAttempts"] != DBNull.Value ? Convert.ToInt32(reader["totalQuizAttempts"]) : 0;
                                strongTopics = reader["strongTopics"] != DBNull.Value ? reader["strongTopics"].ToString() : "";
                                weakTopics = reader["weakTopics"] != DBNull.Value ? reader["weakTopics"].ToString() : "";

                                if (reader["analysisJson"] != null && reader["analysisJson"] != DBNull.Value)
                                    generatedAnalysis = ParseLearningAnalysisJson(reader["analysisJson"].ToString());
                            }
                        }
                    }
                }

                // Load quiz metadata if ResultId is available
                if (generatedAnalysis != null && !string.IsNullOrWhiteSpace(generatedAnalysis.ResultId) && Tbl(connection, "QuizResult"))
                {
                    const string sqlQM = @"SELECT q.quizTitleEN, q.quizTitleBM, qr.attemptedDate, qr.percentage 
                                           FROM QuizResult qr INNER JOIN Quiz q ON q.quizId = qr.quizId 
                                           WHERE qr.resultId = @rid AND qr.studentId = @sid";
                    using (SqlCommand cmdQM = new SqlCommand(sqlQM, connection))
                    {
                        cmdQM.Parameters.AddWithValue("@rid", generatedAnalysis.ResultId);
                        cmdQM.Parameters.AddWithValue("@sid", studentId);
                        using (SqlDataReader rdrQM = cmdQM.ExecuteReader())
                        {
                            if (rdrQM.Read())
                            {
                                string titleEN = rdrQM["quizTitleEN"] != DBNull.Value ? rdrQM["quizTitleEN"].ToString() : "";
                                string titleBM = rdrQM["quizTitleBM"] != DBNull.Value ? rdrQM["quizTitleBM"].ToString() : "";
                                GeneratedQuizTitle = T(titleEN, titleBM);

                                if (rdrQM["attemptedDate"] != DBNull.Value)
                                    GeneratedQuizDate = Convert.ToDateTime(rdrQM["attemptedDate"]).ToString("dd MMM yyyy");

                                if (rdrQM["percentage"] != DBNull.Value)
                                    GeneratedQuizScore = Convert.ToDecimal(rdrQM["percentage"]).ToString("0") + "%";
                            }
                        }
                    }
                }

                // 6. Fallback from QuizResult if no analysis
                int lessonsDone = 0;
                int quizAttempts = 0;

                if (!hasAnalysis)
                {
                    if (Tbl(connection, "QuizResult"))
                    {
                        const string sqlFallback = @"SELECT AVG(percentage) AS avgPct, COUNT(*) AS cnt 
                                                     FROM QuizResult WHERE studentId = @s";
                        using (SqlCommand command = new SqlCommand(sqlFallback, connection))
                        {
                            command.Parameters.AddWithValue("@s", studentId);
                            using (SqlDataReader reader = command.ExecuteReader())
                            {
                                if (reader.Read())
                                {
                                    avgScore = reader["avgPct"] != DBNull.Value ? Convert.ToDecimal(reader["avgPct"]) : 0;
                                    quizAttempts = reader["cnt"] != DBNull.Value ? Convert.ToInt32(reader["cnt"]) : 0;
                                    totalAttempts = quizAttempts;
                                }
                            }
                        }
                    }

                    if (Tbl(connection, "LessonProgress"))
                    {
                        const string sqlLP = @"SELECT COUNT(*) FROM LessonProgress 
                                               WHERE studentId = @s AND isCompleted = 1";
                        using (SqlCommand command = new SqlCommand(sqlLP, connection))
                        {
                            command.Parameters.AddWithValue("@s", studentId);
                            object result = command.ExecuteScalar();
                            lessonsDone = (result != null && result != DBNull.Value) ? Convert.ToInt32(result) : 0;
                        }
                    }
                }
                else
                {
                    if (Tbl(connection, "LessonProgress"))
                    {
                        const string sqlLP = @"SELECT COUNT(*) FROM LessonProgress 
                                               WHERE studentId = @s AND isCompleted = 1";
                        using (SqlCommand command = new SqlCommand(sqlLP, connection))
                        {
                            command.Parameters.AddWithValue("@s", studentId);
                            object result = command.ExecuteScalar();
                            lessonsDone = (result != null && result != DBNull.Value) ? Convert.ToInt32(result) : 0;
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

                pnlEmpty.Visible = false;

                // ═══ SECTION 1: HERO - Progress scores ═══
                if (generatedAnalysis != null)
                {
                    // Hero headline and celebration
                    string headline = generatedAnalysis.ProgressHeadline ?? "";
                    string celebration = generatedAnalysis.CelebrationMessage ?? "";
                    litAIMessage.Text = HttpUtility.HtmlEncode(headline);
                    litHeroSub.Text = HttpUtility.HtmlEncode(celebration);

                    // Score values
                    litAvgScore.Text = generatedAnalysis.CurrentQuizScore.ToString("0.0") + "%";
                    litTotalAttempts.Text = generatedAnalysis.PreviousRecentAverage.ToString("0.0") + "%";

                    string changePrefix = generatedAnalysis.ScoreChange >= 0 ? "+" : "";
                    litStrongTopics.Text = changePrefix + generatedAnalysis.ScoreChange.ToString("0.0") + "%";

                    pnlHealth.Visible = true;
                }
                else if (totalAttempts > 0)
                {
                    litAIMessage.Text = HttpUtility.HtmlEncode(GetAIMessage(personalityId));
                    litHeroSub.Text = "";
                    litAvgScore.Text = avgScore.ToString("0.0") + "%";
                    litTotalAttempts.Text = "—";
                    litStrongTopics.Text = "—";
                    pnlHealth.Visible = true;
                }
                else
                {
                    litAIMessage.Text = HttpUtility.HtmlEncode(GetAIMessage(personalityId));
                    litHeroSub.Text = "";
                    pnlHealth.Visible = false;
                }

                // Total quiz attempts chip
                litWeakTopics.Text = totalAttempts.ToString();

                // ═══ SECTION 2: AI NOTICED THIS ABOUT YOU ═══
                if (hasAnalysis && generatedAnalysis != null)
                {
                    pnlStatusRow.Visible = true;

                    // Strong topics card
                    if (!string.IsNullOrWhiteSpace(strongTopics))
                    {
                        pnlStrong.Visible = true;
                        pnlStrongEmpty.Visible = false;
                        litStrongList.Text = FormatChips(strongTopics, "green");
                    }
                    else
                    {
                        pnlStrong.Visible = false;
                        pnlStrongEmpty.Visible = true;
                    }

                    // Weak topics card
                    if (!string.IsNullOrWhiteSpace(weakTopics))
                    {
                        pnlWeak.Visible = true;
                        pnlWeakEmpty.Visible = false;
                        litWeakList.Text = FormatChips(weakTopics, "orange");
                    }
                    else
                    {
                        pnlWeak.Visible = false;
                        pnlWeakEmpty.Visible = true;
                    }

                    // Personality insight card
                    if (!string.IsNullOrWhiteSpace(generatedAnalysis.PersonalityInsight))
                    {
                        pnlPersonalityInsight.Visible = true;
                        string pName = !string.IsNullOrWhiteSpace(generatedAnalysis.PersonalityName)
                            ? generatedAnalysis.PersonalityName : personalityName;
                        litPersonalityInsightLabel.Text = T(
                            "Your " + HttpUtility.HtmlEncode(pName) + " Style",
                            "Gaya " + HttpUtility.HtmlEncode(pName) + " Anda");
                        litPersonalityInsightText.Text = HttpUtility.HtmlEncode(generatedAnalysis.PersonalityInsight);

                        // Show learning style below insight
                        if (!string.IsNullOrWhiteSpace(learningStyle))
                            litTopicZoneTitle.Text = "<i class=\"bi bi-mortarboard\"></i> " + HttpUtility.HtmlEncode(learningStyle);
                        else
                            litTopicZoneTitle.Text = "";
                    }
                    else
                    {
                        pnlPersonalityInsight.Visible = false;
                        litTopicZoneTitle.Text = "";
                    }
                }
                else
                {
                    pnlStatusRow.Visible = false;
                }

                // ═══ SECTION 3: YOUR PLAN FOR TODAY ═══
                List<object> recommendations = BuildRecommendations(
                    generatedAnalysis, personalityId, weakTopics,
                    avgScore, lessonsDone, quizAttempts);

                if (recommendations.Count > 0)
                {
                    pnlRecommend.Visible = true;
                    rptRecommendations.DataSource = recommendations;
                    rptRecommendations.DataBind();

                    // Coach Tip = StudentAdvice only
                    if (generatedAnalysis != null && !string.IsNullOrWhiteSpace(generatedAnalysis.StudentAdvice))
                        litExplanation.Text = HttpUtility.HtmlEncode(generatedAnalysis.StudentAdvice);
                    else
                        litExplanation.Text = T(
                            "These recommendations are based on your learning patterns and personality type.",
                            "Cadangan ini berdasarkan corak pembelajaran dan jenis personaliti anda.");
                }
                else
                {
                    pnlRecommend.Visible = false;
                }

                // ═══ SECTION 4: PERSONALITY MISSION ═══
                List<string> tips;
                string[] missionLabels = GetMissionLabels(personalityId);

                if (generatedAnalysis != null &&
                    generatedAnalysis.NextMissionSteps != null &&
                    generatedAnalysis.NextMissionSteps.Count == 3)
                {
                    tips = generatedAnalysis.NextMissionSteps;

                    if (!string.IsNullOrWhiteSpace(generatedAnalysis.NextMissionTitle))
                        litTipsTitle.Text = HttpUtility.HtmlEncode(generatedAnalysis.NextMissionTitle);
                    else
                        litTipsTitle.Text = T("Your 3-Step Mission", "Misi 3 Langkah Anda");
                }
                else if (generatedAnalysis != null &&
                         generatedAnalysis.StudyTips != null &&
                         generatedAnalysis.StudyTips.Count == 3)
                {
                    tips = generatedAnalysis.StudyTips;
                }
                else
                {
                    tips = GetStudyTips(personalityId);
                }

                // Set personality-specific step labels
                litStrongEmptyTitle.Text = missionLabels[0];
                litTrendBadge.Text = missionLabels[1];
                litConfidenceBadge.Text = missionLabels[2];

                litTip1.Text = tips.Count > 0 ? HttpUtility.HtmlEncode(tips[0]) : "";
                litTip2.Text = tips.Count > 1 ? HttpUtility.HtmlEncode(tips[1]) : "";
                litTip3.Text = tips.Count > 2 ? HttpUtility.HtmlEncode(tips[2]) : "";

                // ═══ SECTION 5: CHATBOT - personalised chips ═══
                string firstWeak = "";
                if (!string.IsNullOrWhiteSpace(weakTopics))
                {
                    string[] weakArr = weakTopics.Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries);
                    if (weakArr.Length > 0) firstWeak = weakArr[0].Trim();
                }

                string pNameForChat = !string.IsNullOrWhiteSpace(personalityName) ? personalityName : "my";

                if (!string.IsNullOrEmpty(firstWeak))
                {
                    litChatChip1.Text = string.Format(
                        "<button type=\"button\" class=\"st-ai-chip\" onclick=\"document.getElementById('{0}').value = 'Why should I practise {1}?';\">" +
                        "<i class=\"bi bi-bullseye\"></i> Why practise {1}?</button>",
                        txtAIMessage.ClientID, HttpUtility.HtmlAttributeEncode(firstWeak));

                    litChatChip2.Text = string.Format(
                        "<button type=\"button\" class=\"st-ai-chip\" onclick=\"document.getElementById('{0}').value = 'Help me understand {1}.';\">" +
                        "<i class=\"bi bi-lightbulb\"></i> Help me understand {1}</button>",
                        txtAIMessage.ClientID, HttpUtility.HtmlAttributeEncode(firstWeak));
                }
                else
                {
                    litChatChip1.Text = string.Format(
                        "<button type=\"button\" class=\"st-ai-chip\" onclick=\"document.getElementById('{0}').value = 'What should I learn next?';\">" +
                        "<i class=\"bi bi-signpost-split\"></i> What next?</button>",
                        txtAIMessage.ClientID);

                    litChatChip2.Text = string.Format(
                        "<button type=\"button\" class=\"st-ai-chip\" onclick=\"document.getElementById('{0}').value = 'Help me with my focus topic';\">" +
                        "<i class=\"bi bi-bullseye\"></i> Focus topic</button>",
                        txtAIMessage.ClientID);
                }

                litChatChip3.Text = string.Format(
                    "<button type=\"button\" class=\"st-ai-chip\" onclick=\"document.getElementById('{0}').value = 'Make a {1} study plan.';\">" +
                    "<i class=\"bi bi-calendar-check\"></i> {1} study plan</button>",
                    txtAIMessage.ClientID, HttpUtility.HtmlAttributeEncode(pNameForChat));

                litChatChip4.Text = string.Format(
                    "<button type=\"button\" class=\"st-ai-chip\" onclick=\"document.getElementById('{0}').value = 'How did my score change?';\">" +
                    "<i class=\"bi bi-graph-up-arrow\"></i> Score change?</button>",
                    txtAIMessage.ClientID);

            } // end using connection
        }

        // Mission labels by personality
        private string[] GetMissionLabels(string personalityId)
        {
            switch (personalityId)
            {
                case "P001": return new[] { "GOAL", "CHALLENGE", "WIN" };
                case "P002": return new[] { "SEE", "CREATE", "EXPLORE" };
                case "P003": return new[] { "UNDERSTAND", "EXPLAIN", "CHECK" };
                case "P004": return new[] { "START", "CHALLENGE", "BEAT" };
                case "P005": return new[] { "LEARN", "PAUSE", "TRY" };
                case "P006": return new[] { "DISCUSS", "SHARE", "PRACTISE" };
                default: return new[] { "STEP 1", "STEP 2", "STEP 3" };
            }
        }

        // Show empty state
        private void ShowEmptyState()
        {
            pnlEmpty.Visible = true;
            pnlHealth.Visible = false;
            pnlHealthEmpty.Visible = false;
            pnlStatusRow.Visible = false;
            pnlRecommend.Visible = false;
        }

        // Format chips
        private string FormatChips(string topics, string color)
        {
            if (string.IsNullOrWhiteSpace(topics)) return "";

            string[] items = topics.Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries);
            string cssClass = color == "green" ? "st-ai-chip st-ai-chip--green" : "st-ai-chip st-ai-chip--orange";

            StringBuilder htmlBuilder = new StringBuilder();
            foreach (string item in items)
            {
                string trimmed = item.Trim();
                if (!string.IsNullOrEmpty(trimmed))
                    htmlBuilder.AppendFormat("<span class='{0}'>{1}</span>", cssClass, HttpUtility.HtmlEncode(trimmed));
            }
            return htmlBuilder.ToString();
        }

        // AI Message based on personality
        private string GetAIMessage(string personalityId)
        {
            switch (personalityId)
            {
                case "P001": return T("I can help you earn your next badge faster.",
                             "Saya boleh membantu anda memperoleh lencana seterusnya dengan lebih cepat.");
                case "P002": return T("Let's explore Science in a fun and visual way.",
                             "Jom terokai Sains dengan cara yang menyeronokkan dan visual.");
                case "P003": return T("Let's understand your mistakes and improve step by step.",
                             "Jom fahami kesilapan anda dan tambah baik langkah demi langkah.");
                case "P004": return T("Ready for your next challenge?",
                             "Bersedia untuk cabaran seterusnya?");
                case "P005": return T("No rush. Let's learn calmly together.",
                             "Tidak perlu tergesa-gesa. Jom belajar dengan tenang bersama.");
                case "P006": return T("Let's learn together with your friends and teachers.",
                             "Jom belajar bersama rakan dan guru anda.");
                default: return T("I'm here to help you learn better!",
                             "Saya di sini untuk membantu anda belajar dengan lebih baik!");
            }
        }

        // Build recommendations
        private List<object> BuildRecommendations(
            LearningAnalysisData analysis, string personalityId,
            string weakTopics, decimal avgScore, int lessonsDone, int quizAttempts)
        {
            List<object> recommendations = new List<object>();
            string buttonText = T("Let's Go", "Jom");

            if (analysis != null)
            {
                if (!string.IsNullOrWhiteSpace(analysis.RecommendedLessonId))
                {
                    string lessonTitle = !string.IsNullOrWhiteSpace(analysis.RecommendedLessonTitle)
                        ? analysis.RecommendedLessonTitle
                        : T("Recommended Lesson", "Pelajaran Dicadangkan");

                    string shortReason = T("Review before your next quiz", "Ulang kaji sebelum kuiz seterusnya");
                    string fullReason = !string.IsNullOrWhiteSpace(analysis.LessonReason)
                        ? analysis.LessonReason
                        : T("Review this lesson to strengthen your understanding.", "Ulang kaji pelajaran ini untuk mengukuhkan kefahaman anda.");

                    recommendations.Add(new
                    {
                        Category = T("LEARN", "BELAJAR"),
                        Icon = "<i class=\"bi bi-book-half\"></i>",
                        Title = lessonTitle,
                        ShortReason = shortReason,
                        Reason = fullReason,
                        Url = ResolveUrl("~/Student/Lesson.aspx") + "?lessonId=" + HttpUtility.UrlEncode(analysis.RecommendedLessonId),
                        BtnText = buttonText
                    });
                }

                if (!string.IsNullOrWhiteSpace(analysis.RecommendedQuizDifficulty))
                {
                    string diffLabel = analysis.RecommendedQuizDifficulty;
                    if (CurrentLanguage == "BM")
                    {
                        if (diffLabel == "Easy") diffLabel = "Mudah";
                        else if (diffLabel == "Medium") diffLabel = "Sederhana";
                        else if (diffLabel == "Hard") diffLabel = "Sukar";
                    }

                    string shortReason = T("Matches your current level", "Sepadan dengan tahap semasa anda");
                    string fullReason = !string.IsNullOrWhiteSpace(analysis.QuizReason)
                        ? analysis.QuizReason
                        : T("This difficulty matches your recent performance.", "Tahap ini sepadan dengan prestasi terkini anda.");

                    recommendations.Add(new
                    {
                        Category = T("PRACTISE", "BERLATIH"),
                        Icon = "<i class=\"bi bi-clipboard-check\"></i>",
                        Title = T("Quiz: ", "Kuiz: ") + diffLabel,
                        ShortReason = shortReason,
                        Reason = fullReason,
                        Url = ResolveUrl("~/Student/PracticeLibrary.aspx"),
                        BtnText = buttonText
                    });
                }

                if (!string.IsNullOrWhiteSpace(analysis.RecommendedLabId))
                {
                    string labTitle = !string.IsNullOrWhiteSpace(analysis.RecommendedLabTitle)
                        ? analysis.RecommendedLabTitle
                        : T("Recommended Virtual Lab", "Makmal Maya Dicadangkan");

                    string shortReason = T("Hands-on practice for this topic", "Latihan amali untuk topik ini");
                    string fullReason = !string.IsNullOrWhiteSpace(analysis.LabReason)
                        ? analysis.LabReason
                        : T("Try this lab to strengthen the related Science concept.", "Cuba makmal ini untuk mengukuhkan konsep Sains berkaitan.");

                    recommendations.Add(new
                    {
                        Category = T("EXPLORE", "TEROKAI"),
                        Icon = "<i class=\"bi bi-eyedropper\"></i>",
                        Title = labTitle,
                        ShortReason = shortReason,
                        Reason = fullReason,
                        Url = ResolveUrl("~/Student/VirtualLab.aspx") + "?labId=" + HttpUtility.UrlEncode(analysis.RecommendedLabId),
                        BtnText = buttonText
                    });
                }

                if (recommendations.Count > 0) return recommendations;
            }

            return BuildFallbackRecommendations(personalityId, weakTopics, avgScore, lessonsDone, quizAttempts);
        }

        private List<object> BuildFallbackRecommendations(string personalityId, string weakTopics,
            decimal avgScore, int lessonsDone, int quizAttempts)
        {
            List<object> list = new List<object>();
            string goText = T("Let's Go", "Jom");

            if (!string.IsNullOrWhiteSpace(weakTopics))
            {
                list.Add(new
                {
                    Category = T("PRACTISE", "BERLATIH"),
                    Icon = "<i class=\"bi bi-pencil-square\"></i>",
                    Title = T("Practice Weak Topics", "Latih Topik Lemah"),
                    ShortReason = T("Focus on weak areas to improve", "Fokus pada kawasan lemah untuk meningkat"),
                    Reason = T("Focus on your weak areas to improve your overall score.",
                               "Fokus pada kawasan lemah anda untuk meningkatkan skor keseluruhan."),
                    Url = ResolveUrl("~/Student/PracticeLibrary.aspx"),
                    BtnText = goText
                });
            }

            if (lessonsDone < 3)
            {
                list.Add(new
                {
                    Category = T("LEARN", "BELAJAR"),
                    Icon = "<i class=\"bi bi-book\"></i>",
                    Title = T("Continue Learning", "Teruskan Belajar"),
                    ShortReason = T("More lessons to explore", "Lebih banyak pelajaran untuk diterokai"),
                    Reason = T("You have more lessons to explore. Keep going!",
                               "Anda mempunyai lebih banyak pelajaran untuk diterokai. Teruskan!"),
                    Url = ResolveUrl("~/Student/MyLearning.aspx"),
                    BtnText = goText
                });
            }

            if (quizAttempts < 3)
            {
                list.Add(new
                {
                    Category = T("PRACTISE", "BERLATIH"),
                    Icon = "<i class=\"bi bi-clipboard-check\"></i>",
                    Title = T("Try More Quizzes", "Cuba Lebih Banyak Kuiz"),
                    ShortReason = T("Reinforce what you've learned", "Kukuhkan apa yang dipelajari"),
                    Reason = T("Quizzes help reinforce what you've learned. Try a few more!",
                               "Kuiz membantu mengukuhkan apa yang anda pelajari. Cuba lebih banyak!"),
                    Url = ResolveUrl("~/Student/PracticeLibrary.aspx"),
                    BtnText = goText
                });
            }

            return list;
        }

        // Study tips based on personality
        private List<string> GetStudyTips(string personalityId)
        {
            List<string> tips = new List<string>();
            switch (personalityId)
            {
                case "P001":
                    tips.Add(T("Set small daily goals and track your streaks.", "Tetapkan matlamat harian kecil dan jejaki rekod anda."));
                    tips.Add(T("Challenge yourself with harder quizzes.", "Cabari diri anda dengan kuiz lebih sukar."));
                    tips.Add(T("Celebrate your wins! Check your badges.", "Raikan kemenangan anda! Semak lencana anda."));
                    break;
                case "P002":
                    tips.Add(T("Draw mind maps to visualise concepts.", "Lukis peta minda untuk memvisualisasikan konsep."));
                    tips.Add(T("Try the Virtual Labs for hands-on exploration!", "Cuba Makmal Maya untuk penerokaan praktikal!"));
                    tips.Add(T("Create colourful study notes.", "Cipta nota belajar berwarna."));
                    break;
                case "P003":
                    tips.Add(T("Review mistakes after each quiz to understand why.", "Ulang kaji kesilapan selepas setiap kuiz."));
                    tips.Add(T("Summarise lessons in your own words.", "Rumuskan pelajaran dalam perkataan sendiri."));
                    tips.Add(T("Ask 'why' — understanding reasons helps you remember.", "Tanya 'kenapa' — memahami sebab membantu mengingat."));
                    break;
                case "P004":
                    tips.Add(T("Time yourself during quizzes for speed.", "Ukur masa semasa kuiz untuk kelajuan."));
                    tips.Add(T("Try to beat your previous best score.", "Cuba atasi skor terbaik sebelum ini."));
                    tips.Add(T("Don't skip lessons — each builds your foundation.", "Jangan langkau pelajaran — setiap satu membina asas."));
                    break;
                case "P005":
                    tips.Add(T("Study in short 15-minute sessions.", "Belajar dalam sesi pendek 15 minit."));
                    tips.Add(T("Pick one topic per day and explore deeply.", "Pilih satu topik sehari dan terokai mendalam."));
                    tips.Add(T("Go slow. Consistency matters more than speed.", "Perlahan. Konsistensi lebih penting daripada kelajuan."));
                    break;
                case "P006":
                    tips.Add(T("Study with a friend or discuss in the Forum.", "Belajar bersama rakan atau bincang di Forum."));
                    tips.Add(T("Teach what you've learned to someone else!", "Ajar apa yang dipelajari kepada orang lain!"));
                    tips.Add(T("Join Live Sessions to interact with your teacher.", "Sertai Sesi Langsung untuk berinteraksi dengan guru."));
                    break;
                default:
                    tips.Add(T("Review your lessons regularly.", "Ulang kaji pelajaran secara berkala."));
                    tips.Add(T("Practice makes perfect — try a quiz every day!", "Latihan menjadikan sempurna — cuba kuiz setiap hari!"));
                    tips.Add(T("Take breaks and stay hydrated.", "Ambil rehat dan kekal terhidrat."));
                    break;
            }
            return tips;
        }

        private LearningAnalysisData ParseLearningAnalysisJson(string analysisJson)
        {
            if (string.IsNullOrWhiteSpace(analysisJson)) return null;
            try
            {
                JavaScriptSerializer serializer = new JavaScriptSerializer();
                return serializer.Deserialize<LearningAnalysisData>(analysisJson);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Could not read analysis JSON: " + ex.Message);
                return null;
            }
        }

        private string GetLatestLearningContext()
        {
            string userId = Session["userId"] as string;
            if (string.IsNullOrWhiteSpace(userId)) return "";

            const string sql = @"SELECT TOP 1 ai.analysisJson
                FROM AILearningAnalysis ai
                INNER JOIN Student s ON s.studentId = ai.studentId
                WHERE s.userId = @userId AND ai.isLatest = 1";

            using (SqlConnection connection = new SqlConnection(ConnStr))
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@userId", userId);
                connection.Open();
                object result = command.ExecuteScalar();
                if (result == null || result == DBNull.Value) return "";
                return result.ToString();
            }
        }

        // Table exists helper
        private static bool Tbl(SqlConnection connection, string tableName)
        {
            const string sql = @"SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
                WHERE TABLE_NAME = @tableName AND TABLE_TYPE = 'BASE TABLE'";
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@tableName", tableName);
                return (int)command.ExecuteScalar() > 0;
            }
        }

        protected void btnAISend_Click(object sender, EventArgs e)
        {
            string userMessage = (txtAIMessage.Text ?? "").Trim();
            if (string.IsNullOrEmpty(userMessage)) return;

            AppendAIMessage("user", userMessage);
            txtAIMessage.Text = "";

            try
            {
                string reply = GetNvidiaAIReply();
                AppendAIMessage("assistant", reply);
            }
            catch (Exception ex)
            {
                AppendAIMessage("assistant", "Sorry, I could not contact the AI service. " + ex.Message);
            }
        }

        private void AppendAIMessage(string role, string text)
        {
            var history = Session["AIChatHistory"] as List<Dictionary<string, string>>;
            if (history == null) history = new List<Dictionary<string, string>>();

            history.Add(new Dictionary<string, string>
            {
                { "role", role },
                { "content", text }
            });
            Session["AIChatHistory"] = history;

            string cssClass = role == "user" ? "st-ai-msg-user" : "st-ai-msg-bot";
            string safeText = Server.HtmlEncode(text).Replace("\n", "<br/>");
            chatBox.InnerHtml += "<div class='st-ai-msg " + cssClass + "'>" + safeText + "</div>";
        }

        private string GetNvidiaAIReply()
        {
            string apiKey = ConfigurationManager.AppSettings["NvidiaApiKey"];
            string model = ConfigurationManager.AppSettings["NvidiaModel"];
            string endpoint = ConfigurationManager.AppSettings["NvidiaApiEndpoint"];
            string systemPrompt = ConfigurationManager.AppSettings["AIStudyCompanionPrompt"];

            if (string.IsNullOrEmpty(model)) model = "meta/llama-3.1-8b-instruct";
            if (string.IsNullOrEmpty(endpoint)) endpoint = "https://integrate.api.nvidia.com/v1/chat/completions";
            if (string.IsNullOrEmpty(apiKey) || apiKey == "YOUR_NVIDIA_API_KEY_HERE")
                return "Please set the NVIDIA API key in Web.config first.";

            var history = Session["AIChatHistory"] as List<Dictionary<string, string>>;
            if (history == null) history = new List<Dictionary<string, string>>();

            var messagesList = new List<Dictionary<string, string>>();

            if (!string.IsNullOrEmpty(systemPrompt))
            {
                messagesList.Add(new Dictionary<string, string>
                {
                    { "role", "system" },
                    { "content", systemPrompt }
                });
            }

            string learningContext = GetLatestLearningContext();
            if (!string.IsNullOrWhiteSpace(learningContext))
            {
                messagesList.Add(new Dictionary<string, string>
                {
                    { "role", "system" },
                    { "content", "This is the student's latest verified learning analysis. Use it when the student asks about progress, weak topics, recommended lessons, quiz difficulty, virtual labs or study advice. Do not change or invent the factual values:\n" + learningContext }
                });
            }

            foreach (var message in history)
            {
                messagesList.Add(new Dictionary<string, string>
                {
                    { "role", message["role"] },
                    { "content", message["content"] }
                });
            }

            var payload = new Dictionary<string, object>
            {
                { "model", model },
                { "messages", messagesList },
                { "temperature", 0.7 },
                { "top_p", 0.9 },
                { "max_tokens", 700 },
                { "stream", false }
            };

            var serializer = new JavaScriptSerializer();
            serializer.MaxJsonLength = int.MaxValue;
            string jsonPayload = serializer.Serialize(payload);
            byte[] requestBytes = Encoding.UTF8.GetBytes(jsonPayload);

            var request = (HttpWebRequest)WebRequest.Create(endpoint);
            request.Method = "POST";
            request.ContentType = "application/json";
            request.Accept = "application/json";
            request.Headers["Authorization"] = "Bearer " + apiKey;
            request.Timeout = 60000;
            request.ContentLength = requestBytes.Length;

            using (var requestStream = request.GetRequestStream())
            {
                requestStream.Write(requestBytes, 0, requestBytes.Length);
            }

            string responseBody;
            try
            {
                using (var response = (HttpWebResponse)request.GetResponse())
                using (var reader = new StreamReader(response.GetResponseStream(), Encoding.UTF8))
                {
                    responseBody = reader.ReadToEnd();
                }
            }
            catch (WebException wex)
            {
                if (wex.Response != null)
                {
                    using (var errorStream = wex.Response.GetResponseStream())
                    using (var reader = new StreamReader(errorStream, Encoding.UTF8))
                    {
                        string errorBody = reader.ReadToEnd();
                        throw new Exception("NVIDIA API returned an error: " + errorBody);
                    }
                }
                throw new Exception("Network error calling NVIDIA API: " + wex.Message);
            }

            var result = serializer.DeserializeObject(responseBody) as Dictionary<string, object>;
            if (result == null || !result.ContainsKey("choices"))
                return "Sorry, I received an unexpected response from the AI.";

            var choices = result["choices"] as object[];
            if (choices == null || choices.Length == 0)
                return "Sorry, the AI did not return an answer.";

            var firstChoice = choices[0] as Dictionary<string, object>;
            var replyMessage = firstChoice != null && firstChoice.ContainsKey("message")
                ? firstChoice["message"] as Dictionary<string, object> : null;

            string reply = replyMessage != null && replyMessage.ContainsKey("content")
                ? replyMessage["content"] as string : null;

            return string.IsNullOrEmpty(reply) ? "Sorry, I received an empty reply." : reply.Trim();
        }
    }
}
