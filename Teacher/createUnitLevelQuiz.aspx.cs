using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Teacher
{
    [Serializable]
    public class QuestionData
    {
        public string QuestionTextEN { get; set; } = "";
        public string QuestionTextBM { get; set; } = "";
        public string QuestionType { get; set; } = "MCQ";
        public string Difficulty { get; set; } = "Medium";

        public string OptionA_EN { get; set; } = "";
        public string OptionA_BM { get; set; } = "";
        public string OptionB_EN { get; set; } = "";
        public string OptionB_BM { get; set; } = "";
        public string OptionC_EN { get; set; } = "";
        public string OptionC_BM { get; set; } = "";
        public string OptionD_EN { get; set; } = "";
        public string OptionD_BM { get; set; } = "";

        // MCQ: "A"-"D" | True/False: "A"/"B" | Multiselect: "A,B" | D&D: built at submit
        public string CorrectAnswer { get; set; } = "";

        public string CorrectExplanationEN { get; set; } = "";
        public string CorrectExplanationBM { get; set; } = "";
        public string WrongExplanationEN { get; set; } = "";
        public string WrongExplanationBM { get; set; } = "";

        public bool IsSaved { get; set; } = false;

        // Image filename only (not full path or data-URL)
        public string QuestionImageUrl { get; set; } = "";

        // Multiselect fields
        public string MsChk { get; set; } = "";
        public string MsAEN { get; set; } = ""; public string MsABM { get; set; } = "";
        public string MsBEN { get; set; } = ""; public string MsBBM { get; set; } = "";
        public string MsCEN { get; set; } = ""; public string MsCBM { get; set; } = "";
        public string MsDEN { get; set; } = ""; public string MsDBM { get; set; } = "";

        // Drag & Drop word bank
        public string[] FibEN { get; set; } = new string[4];
        public string[] FibBM { get; set; } = new string[4];

        // Drag & Drop mapping order (words in blank order)
        public string[] FibMapEN { get; set; } = new string[0];
        public string[] FibMapBM { get; set; } = new string[0];

        // D&D mapping indices serialised as JSON for round-tripping through hidden fields
        public string FibIdxENJson { get; set; } = "{}";
        public string FibIdxBMJson { get; set; } = "{}";
    }

    public partial class createUnitLevelQuiz : Page
    {
        #region Control Declarations

        protected global::System.Web.UI.WebControls.Panel pnlSubtopicSelect;
        protected global::System.Web.UI.WebControls.DropDownList ddlSubtopic;
        protected global::System.Web.UI.WebControls.Panel pnlQuizTitles;
        protected global::System.Web.UI.WebControls.Literal litQuizTitleEN;
        protected global::System.Web.UI.WebControls.Literal litQuizTitleBM;
        protected global::System.Web.UI.WebControls.Literal litScopeLabel;
        protected global::System.Web.UI.WebControls.HiddenField hidDeleteIndex;
        protected global::System.Web.UI.WebControls.Button btnDeleteQuestion;
        protected global::System.Web.UI.WebControls.HiddenField hidCurrentIndex;
        protected global::System.Web.UI.WebControls.HiddenField hidQuestionsJson;
        protected global::System.Web.UI.WebControls.Button btnNavGo;
        protected global::System.Web.UI.WebControls.Literal litQuestionsJson;
        protected global::System.Web.UI.WebControls.FileUpload fuQuestionImage;
        protected global::System.Web.UI.WebControls.HiddenField hidImgFileName;
        protected global::System.Web.UI.WebControls.HiddenField hidSubmitSuccess;

        #endregion

        #region Properties

        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected string CurrentLanguage
        {
            get
            {
                string lang = Session["preferredLanguage"] as string;
                return string.IsNullOrEmpty(lang) ? "EN" : lang;
            }
        }

        protected int CurrentIndex
        {
            get { return ViewState["CIdx"] != null ? (int)ViewState["CIdx"] : 0; }
            set { ViewState["CIdx"] = value; }
        }

        private string CurrentTab
        {
            get { return hidCurrentTab.Value ?? "EN"; }
            set { hidCurrentTab.Value = value; }
        }

        private List<QuestionData> Questions
        {
            get { return ViewState["Qs"] as List<QuestionData> ?? new List<QuestionData>(); }
            set { ViewState["Qs"] = value; }
        }

        /// <summary>
        /// Returns the localized string based on the current language preference.
        /// </summary>
        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

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

            var master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                if (!Authorize()) { ShowError(T("Access denied.", "Akses ditolak.")); return; }
                if (!InitContext()) return;

                if (Questions.Count == 0)
                {
                    var questionList = new List<QuestionData> { new QuestionData() };
                    Questions = questionList;
                }

                LoadCurrentQuestion();
                LocalizeDropdowns();
            }
        }

        #endregion

        #region Event Handlers

        // Tab switching is now client-side only; these handlers kept for fallback/non-JS
        protected void btnTabEN_Click(object sender, EventArgs e)
        {
            SaveCurrentToMemory();
            CurrentTab = "EN";
            LoadCurrentQuestion();
        }

        protected void btnTabBM_Click(object sender, EventArgs e)
        {
            SaveCurrentToMemory();
            CurrentTab = "BM";
            LoadCurrentQuestion();
        }

        // Prev/Next are now client-side; kept as server-side fallback
        protected void btnPrev_Click(object sender, EventArgs e)
        {
            SaveCurrentToMemory();
            if (CurrentIndex > 0) CurrentIndex--;
            LoadCurrentQuestion();
        }

        protected void btnNext_Click(object sender, EventArgs e)
        {
            SaveCurrentToMemory();
            var questionList = Questions;
            if (CurrentIndex < questionList.Count - 1) CurrentIndex++;
            LoadCurrentQuestion();
        }

        protected void btnNav_Command(object sender, CommandEventArgs e)
        {
            SaveCurrentToMemory();
            CurrentIndex = Convert.ToInt32(e.CommandArgument);
            LoadCurrentQuestion();
        }

        // Hidden button kept for potential future server-side nav; not used by JS engine
        protected void btnNavGo_Click(object sender, EventArgs e)
        {
            SaveCurrentToMemory();
            LoadCurrentQuestion();
        }

        protected void btnAddQuestion_Click(object sender, EventArgs e)
        {
            SaveCurrentToMemory();
            var questionList = Questions;
            questionList.Add(new QuestionData());
            Questions = questionList;
            CurrentIndex = questionList.Count - 1;
            LoadCurrentQuestion();
        }

        protected void btnDeleteQuestion_Click(object sender, EventArgs e)
        {
            var questionList = Questions;

            // Never delete the last remaining question
            if (questionList.Count <= 1) return;

            int deleteIndex;
            if (!int.TryParse(hidDeleteIndex.Value, out deleteIndex)) return;
            if (deleteIndex < 0 || deleteIndex >= questionList.Count) return;

            questionList.RemoveAt(deleteIndex);
            Questions = questionList;

            // Adjust current index so we don't go out of bounds
            if (CurrentIndex >= questionList.Count) CurrentIndex = questionList.Count - 1;
            if (CurrentIndex == deleteIndex && CurrentIndex > 0) CurrentIndex--;

            hidDeleteIndex.Value = "-1";
            hidToast.Value = T("Question deleted.", "Soalan dipadam.");
            LoadCurrentQuestion();
        }

        protected void btnSaveQ_Click(object sender, EventArgs e)
        {
            SaveCurrentToMemory();
            var questionList = Questions;
            questionList[CurrentIndex].IsSaved = true;
            Questions = questionList;
            LoadCurrentQuestion();
        }

        protected void btnSubmitQuiz_Click(object sender, EventArgs e)
        {
            SaveCurrentToMemory();

            var questionList = Questions;
            string quizId = ViewState["QuizId"] as string;
            string subtopicId = ViewState["SubtopicId"] as string;
            string teacherUserId = Session["userId"].ToString();

            if (string.IsNullOrEmpty(quizId))
            { ShowError(T("Quiz not found.", "Kuiz tidak ditemui.")); return; }
            if (string.IsNullOrEmpty(subtopicId))
            { ShowError(T("Subtopic not specified.", "Subtopik tidak dinyatakan.")); return; }

            // Save uploaded image (applies to current question)
            string uploadedImageFileName = SaveQuestionImage();
            if (!string.IsNullOrEmpty(uploadedImageFileName) && questionList.Count > 0)
            {
                int imageQuestionIndex = CurrentIndex < questionList.Count ? CurrentIndex : 0;
                questionList[imageQuestionIndex].QuestionImageUrl = uploadedImageFileName;
            }

            // Validate all questions before saving
            if (!ValidateAllQuestions(questionList)) return;

            // Insert all questions in a single transaction
            SubmitQuizToDatabase(questionList, quizId, subtopicId, teacherUserId);
        }

        #endregion

        #region AJAX Handlers

        /// <summary>
        /// Switches language preference without a full page reload.
        /// </summary>
        [WebMethod(EnableSession = true)]
        public static object SetLanguage(string lang)
        {
            lang = (lang ?? "").Trim().ToUpper();
            if (lang != "EN" && lang != "BM") lang = "EN";

            HttpContext.Current.Session["preferredLanguage"] = lang;

            string userId = HttpContext.Current.Session["userId"] as string;
            if (!string.IsNullOrEmpty(userId))
            {
                try
                {
                    string connStr = ConfigurationManager
                        .ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
                    const string sql = "UPDATE [User] SET preferredLanguage = @lang WHERE userId = @userId";
                    using (var conn = new SqlConnection(connStr))
                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@lang", lang);
                        cmd.Parameters.AddWithValue("@userId", userId);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
                catch (SqlException) { /* session already updated, DB failure is non-critical */ }
            }

            return new { ok = true, lang = lang };
        }

        #endregion

        #region Data Loading

        /// <summary>
        /// Populates UI controls from the current question in the Questions list.
        /// </summary>
        private void LoadCurrentQuestion()
        {
            var questionList = Questions;
            if (CurrentIndex >= questionList.Count) CurrentIndex = questionList.Count - 1;
            if (CurrentIndex < 0) CurrentIndex = 0;

            var question = questionList[CurrentIndex];
            bool isEnglishTab = CurrentTab == "EN";

            litQNum.Text = (CurrentIndex + 1).ToString();
            ddlQType.SelectedValue = question.QuestionType ?? "MCQ";
            ddlQDiff.SelectedValue = question.Difficulty ?? "Medium";

            // Tab styling
            btnTabEN.CssClass = isEnglishTab ? "tc-question-builder-tab active" : "tc-question-builder-tab";
            btnTabBM.CssClass = isEnglishTab ? "tc-question-builder-tab" : "tc-question-builder-tab active";

            // Labels
            litQTextLabel.Text = isEnglishTab
                ? T("Question (English)", "Soalan (Bahasa Inggeris)")
                : T("Question (Bahasa Melayu)", "Soalan (Bahasa Melayu)");
            litOptionsLabel.Text = isEnglishTab
                ? T("Options (English)", "Pilihan (Bahasa Inggeris)")
                : T("Options (Bahasa Melayu)", "Pilihan (Bahasa Melayu)");
            litCorrectExpLabel.Text = isEnglishTab
                ? T("Correct Explanation (EN)", "Penjelasan Betul (EN)")
                : T("Correct Explanation (BM)", "Penjelasan Betul (BM)");
            litWrongExpLabel.Text = isEnglishTab
                ? T("Wrong Explanation (EN)", "Penjelasan Salah (EN)")
                : T("Wrong Explanation (BM)", "Penjelasan Salah (BM)");

            // Question text and options
            txtQuestionText.Text = isEnglishTab ? question.QuestionTextEN : question.QuestionTextBM;
            txtOptA.Text = isEnglishTab ? question.OptionA_EN : question.OptionA_BM;
            txtOptB.Text = isEnglishTab ? question.OptionB_EN : question.OptionB_BM;
            txtOptC.Text = isEnglishTab ? question.OptionC_EN : question.OptionC_BM;
            txtOptD.Text = isEnglishTab ? question.OptionD_EN : question.OptionD_BM;
            txtCorrectExp.Text = isEnglishTab ? question.CorrectExplanationEN : question.CorrectExplanationBM;
            txtWrongExp.Text = isEnglishTab ? question.WrongExplanationEN : question.WrongExplanationBM;

            // Correct answer radio buttons
            radA.Checked = question.CorrectAnswer == "A";
            radB.Checked = question.CorrectAnswer == "B";
            radC.Checked = question.CorrectAnswer == "C";
            radD.Checked = question.CorrectAnswer == "D";

            // Navigation
            BindNav();
            btnPrev.Enabled = CurrentIndex > 0;
            btnNext.Enabled = CurrentIndex < questionList.Count - 1;

            EmitJsBootstrap();
        }

        /// <summary>
        /// Emits a script block with the full question data so the client-side JS
        /// engine can initialise from server state on load.
        /// </summary>
        private void EmitJsBootstrap()
        {
            var questionList = Questions;
            var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();

            var questionsArray = new List<object>();
            foreach (var q in questionList)
            {
                questionsArray.Add(new
                {
                    qEN = q.QuestionTextEN, qBM = q.QuestionTextBM,
                    aEN = q.OptionA_EN, aBM = q.OptionA_BM,
                    bEN = q.OptionB_EN, bBM = q.OptionB_BM,
                    cEN = q.OptionC_EN, cBM = q.OptionC_BM,
                    dEN = q.OptionD_EN, dBM = q.OptionD_BM,
                    ceEN = q.CorrectExplanationEN, ceBM = q.CorrectExplanationBM,
                    weEN = q.WrongExplanationEN, weBM = q.WrongExplanationBM,
                    correct = q.CorrectAnswer, type = q.QuestionType,
                    diff = q.Difficulty, saved = q.IsSaved,
                    fibIdxEN = q.FibIdxENJson, fibIdxBM = q.FibIdxBMJson
                });
            }

            string jsonData = serializer.Serialize(questionsArray);
            string tab = CurrentTab ?? "EN";

            litQuestionsJson.Text = string.Format(
                "<script>window.__QD={0};window.__CI={1};window.__CT='{2}';</s" + "cript>",
                jsonData, CurrentIndex, tab == "BM" ? "BM" : "EN");
        }

        private void BindNav()
        {
            var questionList = Questions;
            var navItems = new List<object>();

            for (int i = 0; i < questionList.Count; i++)
                navItems.Add(new { Index = i, Done = questionList[i].IsSaved });

            rptNav.DataSource = navItems;
            rptNav.DataBind();
        }

        #endregion

        #region Database Operations

        /// <summary>
        /// Verifies the teacher has "Certified" status.
        /// </summary>
        private bool Authorize()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [status] FROM dbo.[Teacher] WHERE [userId]=@u", conn))
                {
                    cmd.Parameters.AddWithValue("@u", Session["userId"].ToString());
                    var result = cmd.ExecuteScalar();
                    return result != null && result.ToString().Equals("Certified", StringComparison.OrdinalIgnoreCase);
                }
            }
        }

        /// <summary>
        /// Finds the quiz ID based on mode (unit or level) and subtopic.
        /// </summary>
        private string GetQuizId(SqlConnection conn, string mode)
        {
            string sql;
            SqlCommand cmd;

            if (mode == "unit")
            {
                sql = "SELECT TOP 1 [quizId] FROM dbo.[Quiz] WHERE [quizType]='Unit' AND [unitId]=@uid AND [subtopicId]=@sid";
                cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@uid", Request.QueryString["unitId"]);
                cmd.Parameters.AddWithValue("@sid", Request.QueryString["subtopicId"]);
            }
            else
            {
                sql = "SELECT TOP 1 [quizId] FROM dbo.[Quiz] WHERE [quizType]='Level' AND [levelId]=@lid AND [subtopicId]=@sid";
                cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@lid", Request.QueryString["level"]);
                cmd.Parameters.AddWithValue("@sid", Request.QueryString["subtopicId"]);
            }

            using (cmd)
            {
                var result = cmd.ExecuteScalar();
                return result?.ToString();
            }
        }

        /// <summary>
        /// Inserts all questions into the database within a transaction,
        /// then sends a success notification to the teacher.
        /// </summary>
        private void SubmitQuizToDatabase(List<QuestionData> questionList, string quizId, string subtopicId, string teacherUserId)
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var txn = conn.BeginTransaction())
                    {
                        try
                        {
                            int maxQuestionNumber = GetMaxQuestionNumber(conn, txn);

                            foreach (var question in questionList)
                            {
                                maxQuestionNumber++;
                                string questionId = "QST" + maxQuestionNumber.ToString("D3");
                                InsertQuestion(conn, txn, questionId, quizId, subtopicId, teacherUserId, question);
                            }

                            txn.Commit();

                            // Send confirmation notification to the teacher
                            SendSubmissionNotification(conn, teacherUserId, quizId);

                            hidSubmitSuccess.Value = "1";
                        }
                        catch (Exception ex)
                        {
                            txn.Rollback();
                            ShowError(T("Failed to submit quiz. Please try again.",
                                "Gagal menghantar kuiz. Sila cuba lagi.") + " (" + ex.Message + ")");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowError(T("Database error occurred.",
                    "Ralat pangkalan data berlaku.") + " (" + ex.Message + ")");
            }
        }

        private int GetMaxQuestionNumber(SqlConnection conn, SqlTransaction txn)
        {
            using (var cmd = new SqlCommand(
                "SELECT ISNULL(MAX(CAST(SUBSTRING([questionId],4,LEN([questionId])-3) AS INT)),0) FROM dbo.[Question]",
                conn, txn))
            {
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        private void InsertQuestion(SqlConnection conn, SqlTransaction txn, string questionId,
            string quizId, string subtopicId, string teacherUserId, QuestionData question)
        {
            string questionType = question.QuestionType ?? "MCQ";

            // Resolve per-type option values
            string optAEN, optABM, optBEN, optBBM, optCEN, optCBM, optDEN, optDBM;
            ResolveOptionsByType(question, questionType,
                out optAEN, out optABM, out optBEN, out optBBM,
                out optCEN, out optCBM, out optDEN, out optDBM);

            // For Drag & Drop, replace [Blank N] markers with _____ before saving
            string questionTextEN = question.QuestionTextEN ?? "";
            string questionTextBM = question.QuestionTextBM ?? "";
            if (questionType == "Drag & Drop")
            {
                var blankPattern = new System.Text.RegularExpressions.Regex(@"\[Blank \d+\]");
                questionTextEN = blankPattern.Replace(questionTextEN, "_____");
                questionTextBM = blankPattern.Replace(questionTextBM, "_____");
            }

            string correctAnswer = BuildCorrectAnswer(question);
            string imageFileName = NullIfEmpty(question.QuestionImageUrl);

            const string sql = @"INSERT INTO dbo.[Question]
                ([questionId],[quizId],[subtopicId],[createdByUserId],
                 [questionTextEN],[questionTextBM],[questionType],
                 [questionImageUrl],
                 [optionA_EN],[optionA_BM],[optionB_EN],[optionB_BM],
                 [optionC_EN],[optionC_BM],[optionD_EN],[optionD_BM],
                 [correctAnswer],
                 [correctExplanationEN],[correctExplanationBM],
                 [wrongExplanationEN],[wrongExplanationBM],
                 [difficulty],[status],[createdAt],[reviewedDate])
                VALUES
                (@qid,@quiz,@sub,@uid,
                 @tEN,@tBM,@type,
                 @imgUrl,
                 @aEN,@aBM,@bEN,@bBM,
                 @cEN,@cBM,@dEN,@dBM,
                 @ans,
                 @ceEN,@ceBM,
                 @weEN,@weBM,
                 @diff,'Pending',GETDATE(),NULL)";

            using (var cmd = new SqlCommand(sql, conn, txn))
            {
                cmd.Parameters.AddWithValue("@qid", questionId);
                cmd.Parameters.AddWithValue("@quiz", quizId);
                cmd.Parameters.AddWithValue("@sub", subtopicId);
                cmd.Parameters.AddWithValue("@uid", teacherUserId);
                cmd.Parameters.AddWithValue("@tEN", questionTextEN);
                cmd.Parameters.AddWithValue("@tBM", questionTextBM);
                cmd.Parameters.AddWithValue("@type", questionType);
                cmd.Parameters.AddWithValue("@imgUrl", (object)imageFileName ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@aEN", (object)NullIfEmpty(optAEN) ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@aBM", (object)NullIfEmpty(optABM) ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@bEN", (object)NullIfEmpty(optBEN) ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@bBM", (object)NullIfEmpty(optBBM) ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@cEN", (object)NullIfEmpty(optCEN) ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@cBM", (object)NullIfEmpty(optCBM) ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@dEN", (object)NullIfEmpty(optDEN) ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@dBM", (object)NullIfEmpty(optDBM) ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@ans", correctAnswer);
                cmd.Parameters.AddWithValue("@ceEN", (object)NullIfEmpty(question.CorrectExplanationEN) ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@ceBM", (object)NullIfEmpty(question.CorrectExplanationBM) ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@weEN", (object)NullIfEmpty(question.WrongExplanationEN) ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@weBM", (object)NullIfEmpty(question.WrongExplanationBM) ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@diff", question.Difficulty ?? "Medium");
                cmd.ExecuteNonQuery();
            }
        }

        private void SendSubmissionNotification(SqlConnection conn, string teacherUserId, string quizId)
        {
            string titleEN = T("Question Submitted Successfully", "Soalan Berjaya Dihantar");
            string titleBM = "Soalan Berjaya Dihantar";
            string quizTitleEN = ViewState["QuizTitleEN"] as string ?? quizId;
            string quizTitleBM = ViewState["QuizTitleBM"] as string ?? quizId;
            string messageEN = $"Your questions for {quizTitleEN} were submitted successfully and are pending review.";
            string messageBM = $"Soalan anda untuk {quizTitleBM} telah berjaya dihantar dan sedang menunggu semakan.";

            try
            {
                string notificationId = GenerateNotificationId(conn);
                const string notifSql = @"INSERT INTO dbo.[Notification]
                    ([notificationId],[toUserId],[titleEN],[titleBM],[messageEN],[messageBM],[isRead],[createdAt])
                    VALUES(@nid,@uid,@tEN,@tBM,@mEN,@mBM,0,GETDATE())";

                using (var cmd = new SqlCommand(notifSql, conn))
                {
                    cmd.Parameters.AddWithValue("@nid", notificationId);
                    cmd.Parameters.AddWithValue("@uid", teacherUserId);
                    cmd.Parameters.AddWithValue("@tEN", titleEN);
                    cmd.Parameters.AddWithValue("@tBM", titleBM);
                    cmd.Parameters.AddWithValue("@mEN", messageEN);
                    cmd.Parameters.AddWithValue("@mBM", messageBM);
                    cmd.ExecuteNonQuery();
                }
            }
            catch { /* notification failure must not block overall success */ }
        }

        /// <summary>
        /// Generates the next notification ID in the format N001, N002, ...
        /// </summary>
        private string GenerateNotificationId(SqlConnection conn)
        {
            const string sql = "SELECT TOP 1 [notificationId] FROM dbo.[Notification] ORDER BY [notificationId] DESC";
            using (var cmd = new SqlCommand(sql, conn))
            {
                var result = cmd.ExecuteScalar();
                if (result == null || result == DBNull.Value) return "N001";

                string lastId = result.ToString();
                if (lastId.Length > 1 && int.TryParse(lastId.Substring(1), out int numericPart))
                    return "N" + (numericPart + 1).ToString().PadLeft(lastId.Length - 1, '0');

                return "N001";
            }
        }

        #endregion

        #region Helper Methods

        /// <summary>
        /// Localizes dropdown display text for difficulty and question type.
        /// </summary>
        private void LocalizeDropdowns()
        {
            ddlQDiff.Items.FindByValue("Easy").Text = T("Easy", "Mudah");
            ddlQDiff.Items.FindByValue("Medium").Text = T("Medium", "Sederhana");
            ddlQDiff.Items.FindByValue("Hard").Text = T("Hard", "Sukar");

            ddlQType.Items.FindByValue("MCQ").Text = T("MCQ", "Aneka Pilihan");
            ddlQType.Items.FindByValue("True/False").Text = T("True / False", "Betul / Salah");
            ddlQType.Items.FindByValue("Multiselect").Text = T("Multiselect", "Pelbagai Pilihan");
            ddlQType.Items.FindByValue("Drag & Drop").Text = T("Drag & Drop", "Seret & Letak");
        }

        /// <summary>
        /// Initialises page context from query string parameters.
        /// Supports two flows: direct quizId or legacy mode+subtopicId.
        /// </summary>
        private bool InitContext()
        {
            string quizIdParam = Request.QueryString["quizId"];

            // New flow: quizId passed directly from Manage Quizzes
            if (!string.IsNullOrEmpty(quizIdParam))
                return InitFromQuizId(quizIdParam);

            // Legacy flow: mode + subtopicId + unitId/level
            string mode = Request.QueryString["mode"];
            string subtopicId = Request.QueryString["subtopicId"];
            if (string.IsNullOrEmpty(mode) || string.IsNullOrEmpty(subtopicId))
            { ShowError(T("Invalid parameters.", "Parameter tidak sah.")); return false; }

            return InitFromLegacyParams(mode, subtopicId);
        }

        /// <summary>
        /// Initialises context using the legacy mode/subtopicId/unitId query string parameters.
        /// </summary>
        private bool InitFromLegacyParams(string mode, string subtopicId)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Load subtopic name
                string subtopicName = "";
                using (var cmd = new SqlCommand("SELECT [subtopicTitleEN] FROM dbo.[Subtopic] WHERE [subtopicId]=@s", conn))
                {
                    cmd.Parameters.AddWithValue("@s", subtopicId);
                    var result = cmd.ExecuteScalar();
                    subtopicName = result?.ToString() ?? "";
                }

                litSubtopic.Text = HttpUtility.HtmlEncode(subtopicName);
                litPropSubtopic.Text = HttpUtility.HtmlEncode(subtopicName);
                pnlSubtopicSelect.Visible = false;

                if (mode == "unit")
                {
                    string unitId = Request.QueryString["unitId"];
                    if (string.IsNullOrEmpty(unitId))
                    { ShowError(T("Unit not specified.", "Unit tidak dinyatakan.")); return false; }

                    string unitName = "";
                    using (var cmd = new SqlCommand("SELECT [unitNameEN] FROM dbo.[Unit] WHERE [unitId]=@u", conn))
                    {
                        cmd.Parameters.AddWithValue("@u", unitId);
                        var result = cmd.ExecuteScalar();
                        unitName = result?.ToString() ?? "";
                    }

                    litMode.Text = T("Unit Quiz", "Kuiz Unit");
                    litScope.Text = HttpUtility.HtmlEncode(unitName);
                    litScopeLabel.Text = T("Unit", "Unit");
                }
                else if (mode == "level")
                {
                    string levelId = Request.QueryString["level"];
                    if (string.IsNullOrEmpty(levelId))
                    { ShowError(T("Level not specified.", "Tahap tidak dinyatakan.")); return false; }

                    string levelName = "";
                    using (var cmd = new SqlCommand("SELECT [levelNameEN] FROM dbo.[Level] WHERE [levelId]=@l", conn))
                    {
                        cmd.Parameters.AddWithValue("@l", levelId);
                        var result = cmd.ExecuteScalar();
                        levelName = result?.ToString() ?? "";
                    }

                    litMode.Text = T("Level Quiz", "Kuiz Tahap");
                    litScope.Text = HttpUtility.HtmlEncode(levelName);
                    litScopeLabel.Text = T("Level", "Tahap");
                }
                else
                {
                    ShowError(T("Invalid mode.", "Mod tidak sah."));
                    return false;
                }

                string quizId = GetQuizId(conn, mode);
                if (string.IsNullOrEmpty(quizId))
                {
                    ShowError(T("No matching quiz found for the selected criteria.",
                        "Tiada kuiz yang sepadan ditemui untuk kriteria yang dipilih."));
                    return false;
                }

                ViewState["QuizId"] = quizId;
                ViewState["SubtopicId"] = subtopicId;
                ViewState["QuizTitleEN"] = litScope.Text;
                ViewState["QuizTitleBM"] = litScope.Text;
            }

            pnlBuilder.Visible = true;
            btnAddQuestion.Text = T("+ Add Question", "+ Tambah Soalan");
            btnSubmitQuiz.Text = T("Submit Quiz", "Hantar Kuiz");
            return true;
        }

        /// <summary>
        /// Initialises context directly from a quizId (new flow from Manage Quizzes).
        /// </summary>
        private bool InitFromQuizId(string quizId)
        {
            string subtopicId = (Request.QueryString["subtopicId"] ?? "").Trim();

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Load quiz metadata
                string quizType = "", unitId = "", levelId = "", titleEN = "", titleBM = "";
                using (var cmd = new SqlCommand(
                    "SELECT [quizType],[unitId],[levelId],[quizTitleEN],[quizTitleBM] FROM dbo.[Quiz] WHERE [quizId]=@qid", conn))
                {
                    cmd.Parameters.AddWithValue("@qid", quizId);
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read())
                        { ShowError(T("Quiz not found.", "Kuiz tidak ditemui.")); return false; }

                        quizType = reader["quizType"]?.ToString() ?? "";
                        unitId = reader["unitId"]?.ToString() ?? "";
                        levelId = reader["levelId"]?.ToString() ?? "";
                        titleEN = reader["quizTitleEN"]?.ToString() ?? "";
                        titleBM = reader["quizTitleBM"]?.ToString() ?? "";
                    }
                }

                if (quizType != "Unit" && quizType != "Level")
                {
                    ShowError(T("Invalid quiz type. Only Unit or Level quizzes are supported.",
                        "Jenis kuiz tidak sah. Hanya kuiz Unit atau Tahap disokong."));
                    return false;
                }

                if (string.IsNullOrEmpty(subtopicId))
                {
                    ShowError(T("Subtopic not specified. Please select a subtopic from Manage Quizzes.",
                        "Subtopik tidak dinyatakan. Sila pilih subtopik dari Urus Kuiz."));
                    return false;
                }

                // Verify subtopic exists and belongs to the correct unit
                string subtopicName = "";
                using (var cmd = new SqlCommand("SELECT [subtopicTitleEN],[unitId] FROM dbo.[Subtopic] WHERE [subtopicId]=@s", conn))
                {
                    cmd.Parameters.AddWithValue("@s", subtopicId);
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read())
                        { ShowError(T("Subtopic not found.", "Subtopik tidak ditemui.")); return false; }

                        subtopicName = reader["subtopicTitleEN"]?.ToString() ?? "";
                        string subtopicUnitId = reader["unitId"]?.ToString() ?? "";

                        // For Unit quizzes, verify subtopic belongs to the quiz's unit
                        if (quizType == "Unit" && !string.IsNullOrEmpty(unitId) && subtopicUnitId != unitId)
                        {
                            ShowError(T("Selected subtopic does not belong to this quiz's unit.",
                                "Subtopik yang dipilih bukan milik unit kuiz ini."));
                            return false;
                        }
                    }
                }

                // Set scope display info based on quiz type
                if (quizType == "Unit")
                {
                    litMode.Text = T("Unit Quiz", "Kuiz Unit");
                    string unitName = "";
                    using (var cmd = new SqlCommand("SELECT [unitNameEN] FROM dbo.[Unit] WHERE [unitId]=@u", conn))
                    {
                        cmd.Parameters.AddWithValue("@u", unitId);
                        var result = cmd.ExecuteScalar();
                        unitName = result?.ToString() ?? "-";
                    }
                    litScope.Text = HttpUtility.HtmlEncode(unitName);
                    litScopeLabel.Text = T("Unit", "Unit");
                }
                else
                {
                    litMode.Text = T("Level Quiz", "Kuiz Tahap");
                    string levelName = "";
                    using (var cmd = new SqlCommand("SELECT [levelNameEN] FROM dbo.[Level] WHERE [levelId]=@l", conn))
                    {
                        cmd.Parameters.AddWithValue("@l", levelId);
                        var result = cmd.ExecuteScalar();
                        levelName = result?.ToString() ?? "-";
                    }
                    litScope.Text = HttpUtility.HtmlEncode(levelName);
                    litScopeLabel.Text = T("Level", "Tahap");
                }

                // Display subtopic as read-only
                litSubtopic.Text = HttpUtility.HtmlEncode(subtopicName);
                litPropSubtopic.Text = HttpUtility.HtmlEncode(subtopicName);
                pnlSubtopicSelect.Visible = false;

                // Display quiz titles
                litQuizTitleEN.Text = HttpUtility.HtmlEncode(titleEN);
                litQuizTitleBM.Text = HttpUtility.HtmlEncode(titleBM);
                pnlQuizTitles.Visible = true;

                ViewState["QuizId"] = quizId;
                ViewState["SubtopicId"] = subtopicId;
                ViewState["QuizTitleEN"] = titleEN;
                ViewState["QuizTitleBM"] = titleBM;
            }

            pnlBuilder.Visible = true;
            btnAddQuestion.Text = T("+ Add Question", "+ Tambah Soalan");
            btnSubmitQuiz.Text = T("Submit Quiz", "Hantar Kuiz");
            return true;
        }

        /// <summary>
        /// Syncs the current question state from the client into the server-side Questions list.
        /// Prefers the full JSON store sent by JavaScript; falls back to reading individual controls.
        /// </summary>
        private void SaveCurrentToMemory()
        {
            // If JS has sent us the full serialised store, use that as the authoritative source
            if (!string.IsNullOrEmpty(hidQuestionsJson.Value))
            {
                try
                {
                    var parsed = DeserializeQuestionsJson(hidQuestionsJson.Value);
                    if (parsed != null && parsed.Count > 0)
                    {
                        Questions = parsed;
                        if (!string.IsNullOrEmpty(hidCurrentIndex.Value) &&
                            int.TryParse(hidCurrentIndex.Value, out int jsIndex))
                            CurrentIndex = jsIndex;
                        return;
                    }
                }
                catch { /* fall through to control-based save */ }
            }

            // Fallback: read from individual server controls
            SaveCurrentFromControls();
        }

        /// <summary>
        /// Reads question data from individual ASP.NET controls (original fallback behaviour).
        /// </summary>
        private void SaveCurrentFromControls()
        {
            var questionList = Questions;
            if (CurrentIndex >= questionList.Count) return;

            var question = questionList[CurrentIndex];
            bool isEnglishTab = CurrentTab == "EN";

            if (isEnglishTab)
            {
                question.QuestionTextEN = txtQuestionText.Text;
                question.OptionA_EN = txtOptA.Text;
                question.OptionB_EN = txtOptB.Text;
                question.OptionC_EN = txtOptC.Text;
                question.OptionD_EN = txtOptD.Text;
                question.CorrectExplanationEN = txtCorrectExp.Text;
                question.WrongExplanationEN = txtWrongExp.Text;
            }
            else
            {
                question.QuestionTextBM = txtQuestionText.Text;
                question.OptionA_BM = txtOptA.Text;
                question.OptionB_BM = txtOptB.Text;
                question.OptionC_BM = txtOptC.Text;
                question.OptionD_BM = txtOptD.Text;
                question.CorrectExplanationBM = txtCorrectExp.Text;
                question.WrongExplanationBM = txtWrongExp.Text;
            }

            question.QuestionType = NormalizeQuestionType(ddlQType.SelectedValue);
            question.Difficulty = NormalizeDifficulty(ddlQDiff.SelectedValue);

            if (radA.Checked) question.CorrectAnswer = "A";
            else if (radB.Checked) question.CorrectAnswer = "B";
            else if (radC.Checked) question.CorrectAnswer = "C";
            else if (radD.Checked) question.CorrectAnswer = "D";

            Questions = questionList;
        }

        /// <summary>
        /// Deserializes the question array JSON sent from the client-side JS store.
        /// </summary>
        private List<QuestionData> DeserializeQuestionsJson(string json)
        {
            var result = new List<QuestionData>();
            try
            {
                var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
                var rawList = serializer.Deserialize<List<Dictionary<string, object>>>(json);

                foreach (var dict in rawList)
                {
                    string getString(string key) => dict.ContainsKey(key) ? (dict[key] ?? "").ToString() : "";
                    bool getBool(string key) => dict.ContainsKey(key) && dict[key] is bool boolVal && boolVal;

                    string[] getFibArray(string key)
                    {
                        var arr = new string[4];
                        if (dict.ContainsKey(key) && dict[key] is System.Collections.ArrayList arrayList)
                            for (int i = 0; i < Math.Min(arrayList.Count, 4); i++)
                                arr[i] = arrayList[i]?.ToString() ?? "";
                        return arr;
                    }

                    // Keep plain filenames only; discard data-URLs
                    string imageUrl = "";
                    string rawImageValue = getString("img");
                    if (!string.IsNullOrEmpty(rawImageValue) && !rawImageValue.StartsWith("data:"))
                        imageUrl = rawImageValue;

                    result.Add(new QuestionData
                    {
                        QuestionTextEN = getString("qEN"),
                        QuestionTextBM = getString("qBM"),
                        OptionA_EN = getString("aEN"), OptionA_BM = getString("aBM"),
                        OptionB_EN = getString("bEN"), OptionB_BM = getString("bBM"),
                        OptionC_EN = getString("cEN"), OptionC_BM = getString("cBM"),
                        OptionD_EN = getString("dEN"), OptionD_BM = getString("dBM"),
                        CorrectExplanationEN = getString("ceEN"),
                        CorrectExplanationBM = getString("ceBM"),
                        WrongExplanationEN = getString("weEN"),
                        WrongExplanationBM = getString("weBM"),
                        CorrectAnswer = getString("correct"),
                        QuestionType = NormalizeQuestionType(getString("type")),
                        Difficulty = NormalizeDifficulty(getString("diff")),
                        IsSaved = getBool("saved"),
                        QuestionImageUrl = imageUrl,
                        MsChk = getString("msChk"),
                        MsAEN = getString("msAEN"), MsABM = getString("msABM"),
                        MsBEN = getString("msBEN"), MsBBM = getString("msBBM"),
                        MsCEN = getString("msCEN"), MsCBM = getString("msCBM"),
                        MsDEN = getString("msDEN"), MsDBM = getString("msDBM"),
                        FibEN = getFibArray("fibEN"),
                        FibBM = getFibArray("fibBM"),
                        FibMapEN = getFibArray("fibMapEN"),
                        FibMapBM = getFibArray("fibMapBM"),
                        FibIdxENJson = dict.ContainsKey("fibIdxEN") ? serializer.Serialize(dict["fibIdxEN"]) : "{}",
                        FibIdxBMJson = dict.ContainsKey("fibIdxBM") ? serializer.Serialize(dict["fibIdxBM"]) : "{}"
                    });
                }
            }
            catch { return null; }

            return result;
        }

        /// <summary>
        /// Validates all questions before submission. Returns false and shows error if invalid.
        /// </summary>
        private bool ValidateAllQuestions(List<QuestionData> questionList)
        {
            for (int i = 0; i < questionList.Count; i++)
            {
                var question = questionList[i];
                string questionLabel = T($"Question {i + 1}", $"Soalan {i + 1}");
                string questionType = question.QuestionType ?? "MCQ";

                // Question text required for all types
                if (string.IsNullOrWhiteSpace(question.QuestionTextEN))
                { ShowError($"{questionLabel}: {T("English question text is required.", "Teks soalan Bahasa Inggeris diperlukan.")}"); return false; }
                if (string.IsNullOrWhiteSpace(question.QuestionTextBM))
                { ShowError($"{questionLabel}: {T("Bahasa Melayu question text is required.", "Teks soalan Bahasa Melayu diperlukan.")}"); return false; }

                // Explanations required for all types
                if (string.IsNullOrWhiteSpace(question.CorrectExplanationEN))
                { ShowError($"{questionLabel}: {T("Correct explanation (English) is required.", "Penjelasan betul (Bahasa Inggeris) diperlukan.")}"); return false; }
                if (string.IsNullOrWhiteSpace(question.CorrectExplanationBM))
                { ShowError($"{questionLabel}: {T("Correct explanation (Bahasa Melayu) is required.", "Penjelasan betul (Bahasa Melayu) diperlukan.")}"); return false; }
                if (string.IsNullOrWhiteSpace(question.WrongExplanationEN))
                { ShowError($"{questionLabel}: {T("Wrong explanation (English) is required.", "Penjelasan salah (Bahasa Inggeris) diperlukan.")}"); return false; }
                if (string.IsNullOrWhiteSpace(question.WrongExplanationBM))
                { ShowError($"{questionLabel}: {T("Wrong explanation (Bahasa Melayu) is required.", "Penjelasan salah (Bahasa Melayu) diperlukan.")}"); return false; }

                if (!ValidateQuestionByType(question, questionLabel, questionType))
                    return false;
            }

            return true;
        }

        /// <summary>
        /// Validates type-specific rules (MCQ options, True/False answer, Multiselect, Drag & Drop).
        /// </summary>
        private bool ValidateQuestionByType(QuestionData question, string questionLabel, string questionType)
        {
            switch (questionType)
            {
                case "MCQ":
                    if (string.IsNullOrWhiteSpace(question.OptionA_EN) || string.IsNullOrWhiteSpace(question.OptionB_EN))
                    { ShowError($"{questionLabel}: {T("Options A and B (English) are required.", "Pilihan A dan B (Bahasa Inggeris) diperlukan.")}"); return false; }
                    if (string.IsNullOrWhiteSpace(question.OptionA_BM) || string.IsNullOrWhiteSpace(question.OptionB_BM))
                    { ShowError($"{questionLabel}: {T("Options A and B (Bahasa Melayu) are required.", "Pilihan A dan B (Bahasa Melayu) diperlukan.")}"); return false; }
                    if (string.IsNullOrEmpty(question.CorrectAnswer))
                    { ShowError($"{questionLabel}: {T("Please select the correct answer.", "Sila pilih jawapan yang betul.")}"); return false; }

                    string selectedOptionEN = question.CorrectAnswer == "A" ? question.OptionA_EN
                        : question.CorrectAnswer == "B" ? question.OptionB_EN
                        : question.CorrectAnswer == "C" ? question.OptionC_EN
                        : question.OptionD_EN;
                    if (string.IsNullOrWhiteSpace(selectedOptionEN))
                    { ShowError($"{questionLabel}: {T("The selected correct answer option must not be empty.", "Pilihan jawapan betul yang dipilih tidak boleh kosong.")}"); return false; }
                    break;

                case "True/False":
                    if (string.IsNullOrEmpty(question.CorrectAnswer))
                    { ShowError($"{questionLabel}: {T("Please select the correct answer.", "Sila pilih jawapan yang betul.")}"); return false; }
                    break;

                case "Multiselect":
                    if (!ValidateMultiselect(question, questionLabel)) return false;
                    break;

                case "Drag & Drop":
                    if (!ValidateDragAndDrop(question, questionLabel)) return false;
                    break;
            }

            return true;
        }

        private bool ValidateMultiselect(QuestionData question, string questionLabel)
        {
            if (string.IsNullOrWhiteSpace(question.MsAEN) || string.IsNullOrWhiteSpace(question.MsBEN) || string.IsNullOrWhiteSpace(question.MsCEN))
            { ShowError($"{questionLabel}: {T("Options A, B and C (English) are required for Multiselect.", "Pilihan A, B dan C (Bahasa Inggeris) diperlukan untuk Berbilang Pilihan.")}"); return false; }
            if (string.IsNullOrWhiteSpace(question.MsABM) || string.IsNullOrWhiteSpace(question.MsBBM) || string.IsNullOrWhiteSpace(question.MsCBM))
            { ShowError($"{questionLabel}: {T("Options A, B and C (Bahasa Melayu) are required for Multiselect.", "Pilihan A, B dan C (Bahasa Melayu) diperlukan untuk Berbilang Pilihan.")}"); return false; }

            var selectedLetters = (question.MsChk ?? "").Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
            if (selectedLetters.Length == 0)
            { ShowError($"{questionLabel}: {T("Please select the correct answers.", "Sila pilih jawapan yang betul.")}"); return false; }
            if (selectedLetters.Length == 1)
            { ShowError($"{questionLabel}: {T("Please select at least 2 correct answers.", "Sila pilih sekurang-kurangnya 2 jawapan betul.")}"); return false; }

            var optionMapEN = new Dictionary<string, string>
            {
                {"A", question.MsAEN}, {"B", question.MsBEN},
                {"C", question.MsCEN}, {"D", question.MsDEN}
            };

            foreach (var letter in selectedLetters)
            {
                if (!optionMapEN.ContainsKey(letter) || string.IsNullOrWhiteSpace(optionMapEN[letter]))
                { ShowError($"{questionLabel}: {T("A selected correct answer option is empty.", "Pilihan jawapan betul yang dipilih adalah kosong.")}"); return false; }
            }

            return true;
        }

        private bool ValidateDragAndDrop(QuestionData question, string questionLabel)
        {
            var fibENWords = (question.FibEN ?? new string[4]).Where((string s) => !string.IsNullOrWhiteSpace(s)).ToList();
            var fibBMWords = (question.FibBM ?? new string[4]).Where((string s) => !string.IsNullOrWhiteSpace(s)).ToList();

            if (fibENWords.Count < 2)
            { ShowError($"{questionLabel}: {T("At least two answer options are required.", "Sekurang-kurangnya dua pilihan jawapan diperlukan.")}"); return false; }
            if (fibBMWords.Count < 2)
            { ShowError($"{questionLabel}: {T("At least two answer options are required.", "Sekurang-kurangnya dua pilihan jawapan diperlukan.")}"); return false; }

            var blankPattern = new System.Text.RegularExpressions.Regex(@"\[Blank \d\]");
            int enBlankCount = blankPattern.Matches(question.QuestionTextEN ?? "").Count;
            int bmBlankCount = blankPattern.Matches(question.QuestionTextBM ?? "").Count;

            if (enBlankCount < 1 || bmBlankCount < 1)
            { ShowError($"{questionLabel}: {T("At least one blank is required.", "Sekurang-kurangnya satu tempat kosong diperlukan.")}"); return false; }
            if (enBlankCount != bmBlankCount)
            { ShowError($"{questionLabel}: {T("The number of blanks in English and Bahasa Melayu must match.", "Bilangan tempat kosong dalam Bahasa Inggeris dan Bahasa Melayu mesti sepadan.")}"); return false; }

            // Mapping count must match blank count
            var enMappedWords = (question.FibMapEN ?? new string[0]).Where((string s) => !string.IsNullOrWhiteSpace(s)).ToList();
            var bmMappedWords = (question.FibMapBM ?? new string[0]).Where((string s) => !string.IsNullOrWhiteSpace(s)).ToList();

            if (enMappedWords.Count == 0 || bmMappedWords.Count == 0)
            { ShowError($"{questionLabel}: {T("Please select the correct mapping order.", "Sila pilih susunan pemetaan yang betul.")}"); return false; }
            if (enMappedWords.Count != enBlankCount)
            { ShowError($"{questionLabel}: {T("The number of mappings must match the number of blanks.", "Bilangan pemetaan mesti sepadan dengan bilangan tempat kosong.")}"); return false; }
            if (bmMappedWords.Count != bmBlankCount)
            { ShowError($"{questionLabel}: {T("The number of mappings must match the number of blanks.", "Bilangan pemetaan mesti sepadan dengan bilangan tempat kosong.")}"); return false; }

            return true;
        }

        /// <summary>
        /// Resolves option A-D values based on question type (MCQ uses standard options,
        /// True/False uses fixed text, Multiselect uses Ms* fields, D&D uses FIB words).
        /// </summary>
        private void ResolveOptionsByType(QuestionData question, string questionType,
            out string optAEN, out string optABM, out string optBEN, out string optBBM,
            out string optCEN, out string optCBM, out string optDEN, out string optDBM)
        {
            if (questionType == "Multiselect")
            {
                optAEN = question.MsAEN; optABM = question.MsABM;
                optBEN = question.MsBEN; optBBM = question.MsBBM;
                optCEN = question.MsCEN; optCBM = question.MsCBM;
                optDEN = question.MsDEN; optDBM = question.MsDBM;
            }
            else if (questionType == "True/False")
            {
                // Fixed bilingual option text; C and D are NULL
                optAEN = "True"; optABM = "Betul";
                optBEN = "False"; optBBM = "Salah";
                optCEN = null; optCBM = null;
                optDEN = null; optDBM = null;
            }
            else if (questionType == "Drag & Drop")
            {
                // Store each word bank word in the option slots (up to 4)
                var fibEN = question.FibEN ?? new string[4];
                var fibBM = question.FibBM ?? new string[4];
                optAEN = fibEN.Length > 0 ? fibEN[0] : null; optABM = fibBM.Length > 0 ? fibBM[0] : null;
                optBEN = fibEN.Length > 1 ? fibEN[1] : null; optBBM = fibBM.Length > 1 ? fibBM[1] : null;
                optCEN = fibEN.Length > 2 ? fibEN[2] : null; optCBM = fibBM.Length > 2 ? fibBM[2] : null;
                optDEN = fibEN.Length > 3 ? fibEN[3] : null; optDBM = fibBM.Length > 3 ? fibBM[3] : null;
            }
            else
            {
                // Standard MCQ options
                optAEN = question.OptionA_EN; optABM = question.OptionA_BM;
                optBEN = question.OptionB_EN; optBBM = question.OptionB_BM;
                optCEN = question.OptionC_EN; optCBM = question.OptionC_BM;
                optDEN = question.OptionD_EN; optDBM = question.OptionD_BM;
            }
        }

        /// <summary>
        /// Builds the correct answer string for database storage based on question type.
        /// </summary>
        private string BuildCorrectAnswer(QuestionData question)
        {
            switch (question.QuestionType ?? "MCQ")
            {
                case "True/False":
                    return question.CorrectAnswer ?? "";

                case "Multiselect":
                    return question.MsChk ?? "";

                case "Drag & Drop":
                    // Concatenate EN mapped words then BM mapped words
                    var enMapped = (question.FibMapEN ?? new string[0])
                        .Where((string s) => !string.IsNullOrWhiteSpace(s)).ToList();
                    var bmMapped = (question.FibMapBM ?? new string[0])
                        .Where((string s) => !string.IsNullOrWhiteSpace(s)).ToList();
                    return string.Join(",", enMapped.Concat(bmMapped));

                default: // MCQ
                    return question.CorrectAnswer ?? "";
            }
        }

        /// <summary>
        /// Saves the uploaded question image to ~/Images/Question/ and returns just the filename.
        /// Returns null if nothing was uploaded.
        /// </summary>
        private string SaveQuestionImage()
        {
            if (fuQuestionImage == null || !fuQuestionImage.HasFile)
                return null;

            string originalName = Path.GetFileName(fuQuestionImage.FileName);
            if (string.IsNullOrWhiteSpace(originalName))
                return null;

            string folder = Server.MapPath("~/Images/Question/");
            if (!Directory.Exists(folder))
                Directory.CreateDirectory(folder);

            fuQuestionImage.SaveAs(Path.Combine(folder, originalName));
            return originalName;
        }

        private void ShowError(string message)
        {
            pnlError.Visible = true;
            pnlBuilder.Visible = false;
            litError.Text = HttpUtility.HtmlEncode(message);
        }

        /// <summary>
        /// Ensures the question type stored is always the English standard value,
        /// regardless of the current website display language.
        /// </summary>
        private static string NormalizeQuestionType(string value)
        {
            if (string.IsNullOrEmpty(value)) return "MCQ";
            switch (value)
            {
                case "MCQ": return "MCQ";
                case "True/False": return "True/False";
                case "Multiselect": return "Multiselect";
                case "Drag & Drop": return "Drag & Drop";
                default: return "MCQ";
            }
        }

        /// <summary>
        /// Ensures the difficulty stored is always the English standard value,
        /// regardless of the current website display language.
        /// </summary>
        private static string NormalizeDifficulty(string value)
        {
            if (string.IsNullOrEmpty(value)) return "Medium";
            switch (value)
            {
                case "Easy": return "Easy";
                case "Medium": return "Medium";
                case "Hard": return "Hard";
                default: return "Medium";
            }
        }

        /// <summary>
        /// Returns null for blank/whitespace strings, otherwise trims and returns the value.
        /// Used to convert empty strings to DBNull-compatible nulls.
        /// </summary>
        private static string NullIfEmpty(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? null : value.Trim();
        }

        private string JsEscape(string s)
        {
            if (string.IsNullOrEmpty(s)) return "";
            return s.Replace("\\", "\\\\").Replace("'", "\\'").Replace("\r", "\\r").Replace("\n", "\\n");
        }

        #endregion
    }
}
