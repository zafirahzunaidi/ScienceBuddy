using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace ScienceBuddy.Teacher
{
    public partial class createPracticeQuiz : Page
    {
        #region Properties

        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected string CurrentLanguage
        {
            get
            {
                string lang = Session["preferredLanguage"] as string;
                return string.IsNullOrEmpty(lang) ? "EN" : lang;
            }
        }

        /// <summary>
        /// Returns the English or Bahasa Melayu string based on user's language preference.
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

            // Route AJAX handlers early — return JSON without full page lifecycle
            string handler = Request.QueryString["handler"] ?? "";
            if (handler == "levels")    { HandleLevels();    return; }
            if (handler == "units")     { HandleUnits();     return; }
            if (handler == "subtopics") { HandleSubtopics(); return; }

            if (!IsPostBack)
            {
                if (!AuthorizeTeacher()) return;
                ValidateAndLoad();
            }
            else
            {
                // Keep main panel visible on postback so controls retain values
                pnlMain.Visible = true;
            }
        }

        #endregion

        #region Event Handlers

        protected void btnSubmitPQ_Click(object sender, EventArgs e)
        {
            string userId     = Session["userId"]?.ToString() ?? "";
            string levelId    = hidLevelId.Value;
            string unitId     = hidUnitId.Value;
            string subtopicId = hidSubtopicId.Value;
            string language   = hidLanguage.Value;
            string quizTitle  = (hidQuizTitle.Value ?? "").Trim();
            string questionsJson = hidQuestionsJson.Value ?? "[]";

            if (string.IsNullOrEmpty(quizTitle) || string.IsNullOrEmpty(subtopicId) ||
                string.IsNullOrEmpty(unitId) || string.IsNullOrEmpty(language))
            {
                ShowInvalid(T("Missing required data. Please try again.",
                              "Data yang diperlukan tiada. Sila cuba lagi.")
                    + " [DEBUG: title=" + (quizTitle ?? "NULL")
                    + " sub=" + (subtopicId ?? "NULL")
                    + " unit=" + (unitId ?? "NULL")
                    + " lang=" + (language ?? "NULL") + "]");
                return;
            }

            // Parse questions from JSON submitted by the client
            List<Dictionary<string, object>> questions;
            try
            {
                questions = JsonConvert.DeserializeObject<List<Dictionary<string, object>>>(questionsJson);
            }
            catch
            {
                ShowInvalid(T("Invalid question data.", "Data soalan tidak sah."));
                return;
            }

            if (questions == null || questions.Count == 0)
            {
                ShowInvalid(T("At least one question is required.",
                              "Sekurang-kurangnya satu soalan diperlukan."));
                return;
            }

            bool isEnglish = language == "EN";
            string titleEN = isEnglish ? quizTitle : null;
            string titleBM = isEnglish ? null : quizTitle;

            SavePracticeQuiz(userId, levelId, unitId, subtopicId, language,
                             titleEN, titleBM, isEnglish, questions);
        }

        #endregion

        #region AJAX Handlers

        private void HandleLevels()
        {
            string json = BuildJsonArray(
                "SELECT [levelId],[levelNameEN] FROM dbo.[Level] ORDER BY [levelId]",
                cmd => { },
                reader => new
                {
                    id = reader["levelId"].ToString(),
                    name = reader["levelNameEN"].ToString()
                });

            WriteJsonResponse(json);
        }

        private void HandleUnits()
        {
            string levelId = (Request.QueryString["levelId"] ?? "").Trim();
            if (string.IsNullOrEmpty(levelId)) { WriteJsonResponse("[]"); return; }

            string json = BuildJsonArray(
                "SELECT [unitId],[unitNameEN] FROM dbo.[Unit] WHERE [levelId]=@l ORDER BY [orderNo]",
                cmd => cmd.Parameters.AddWithValue("@l", levelId),
                reader => new
                {
                    id = reader["unitId"].ToString(),
                    name = reader["unitNameEN"].ToString()
                });

            WriteJsonResponse(json);
        }

        private void HandleSubtopics()
        {
            string unitId = (Request.QueryString["unitId"] ?? "").Trim();
            if (string.IsNullOrEmpty(unitId)) { WriteJsonResponse("[]"); return; }

            string json = BuildJsonArray(
                "SELECT [subtopicId],[subtopicTitleEN] FROM dbo.[Subtopic] WHERE [unitId]=@u ORDER BY [orderNo]",
                cmd => cmd.Parameters.AddWithValue("@u", unitId),
                reader => new
                {
                    id = reader["subtopicId"].ToString(),
                    name = reader["subtopicTitleEN"].ToString()
                });

            WriteJsonResponse(json);
        }

        /// <summary>
        /// WebMethod: Switch language without page reload.
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
                catch (SqlException) { /* session already updated */ }
            }

            return new { ok = true, lang = lang };
        }

        #endregion

        #region Data Loading

        /// <summary>
        /// Validates query-string parameters and populates the page hero section with context info.
        /// </summary>
        private void ValidateAndLoad()
        {
            string levelId    = (Request.QueryString["levelId"]    ?? "").Trim();
            string unitId     = (Request.QueryString["unitId"]     ?? "").Trim();
            string subtopicId = (Request.QueryString["subtopicId"] ?? "").Trim();
            string language   = (Request.QueryString["language"]   ?? "").Trim().ToUpperInvariant();

            if (string.IsNullOrEmpty(levelId) || string.IsNullOrEmpty(unitId) ||
                string.IsNullOrEmpty(subtopicId) || string.IsNullOrEmpty(language))
            {
                ShowInvalid(T("Missing required parameters. Please go back and select a Level, Unit, Subtopic, and Language.",
                              "Parameter diperlukan tidak lengkap. Sila kembali dan pilih Tahap, Unit, Subtopik, dan Bahasa."));
                return;
            }

            if (language != "EN" && language != "BM")
            {
                ShowInvalid(T("Invalid language selection.", "Pilihan bahasa tidak sah."));
                return;
            }

            // Verify that Level, Unit, and Subtopic exist and belong to each other
            string levelName = null, unitName = null, subtopicName = null;

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                using (var cmd = new SqlCommand(
                    "SELECT [levelNameEN] FROM dbo.[Level] WHERE [levelId]=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", levelId);
                    var val = cmd.ExecuteScalar();
                    if (val == null || val == DBNull.Value)
                    {
                        ShowInvalid(T("The selected Level does not exist.",
                                      "Tahap yang dipilih tidak wujud."));
                        return;
                    }
                    levelName = val.ToString();
                }

                using (var cmd = new SqlCommand(
                    "SELECT [unitNameEN] FROM dbo.[Unit] WHERE [unitId]=@uid AND [levelId]=@lid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", unitId);
                    cmd.Parameters.AddWithValue("@lid", levelId);
                    var val = cmd.ExecuteScalar();
                    if (val == null || val == DBNull.Value)
                    {
                        ShowInvalid(T("The selected Unit does not belong to the chosen Level.",
                                      "Unit yang dipilih tidak tergolong dalam Tahap yang dipilih."));
                        return;
                    }
                    unitName = val.ToString();
                }

                using (var cmd = new SqlCommand(
                    "SELECT [subtopicTitleEN] FROM dbo.[Subtopic] WHERE [subtopicId]=@sid AND [unitId]=@uid", conn))
                {
                    cmd.Parameters.AddWithValue("@sid", subtopicId);
                    cmd.Parameters.AddWithValue("@uid", unitId);
                    var val = cmd.ExecuteScalar();
                    if (val == null || val == DBNull.Value)
                    {
                        ShowInvalid(T("The selected Subtopic does not belong to the chosen Unit.",
                                      "Subtopik yang dipilih tidak tergolong dalam Unit yang dipilih."));
                        return;
                    }
                    subtopicName = val.ToString();
                }
            }

            // Populate hero display labels
            string langLabel = language == "BM" ? "Bahasa Melayu" : "English";

            litLevel.Text    = HttpUtility.HtmlEncode(levelName);
            litUnit.Text     = HttpUtility.HtmlEncode(unitName);
            litSubtopic.Text = HttpUtility.HtmlEncode(subtopicName);
            litLanguage.Text = HttpUtility.HtmlEncode(langLabel);

            // Populate hidden fields for client-side JavaScript
            hidLevelId.Value    = levelId;
            hidUnitId.Value     = unitId;
            hidSubtopicId.Value = subtopicId;
            hidLanguage.Value   = language;

            pnlMain.Visible = true;
        }

        #endregion

        #region Database Operations

        /// <summary>
        /// Checks whether the current teacher is certified. Shows denied panel if not.
        /// </summary>
        private bool AuthorizeTeacher()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(
                    "SELECT [status] FROM dbo.[Teacher] WHERE [userId]=@u", conn))
                {
                    cmd.Parameters.AddWithValue("@u", Session["userId"].ToString());
                    var val = cmd.ExecuteScalar();
                    if (val == null || val == DBNull.Value ||
                        !val.ToString().Equals("Certified", StringComparison.OrdinalIgnoreCase))
                    {
                        pnlDenied.Visible = true;
                        return false;
                    }
                }
            }
            return true;
        }

        /// <summary>
        /// Persists the practice quiz and all its questions within a single transaction.
        /// Redirects to manageQuiz on success; shows error on failure.
        /// </summary>
        private void SavePracticeQuiz(string userId, string levelId, string unitId,
            string subtopicId, string language, string titleEN, string titleBM,
            bool isEnglish, List<Dictionary<string, object>> questions)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var txn = conn.BeginTransaction())
                {
                    try
                    {
                        string quizId = GenerateNextId(conn, txn,
                            "SELECT ISNULL(MAX(CAST(SUBSTRING([quizId],2,LEN([quizId])-1) AS INT)),0) FROM dbo.[Quiz] WHERE [quizId] LIKE 'Q%' AND ISNUMERIC(SUBSTRING([quizId],2,LEN([quizId])-1))=1",
                            "Q", 3);

                        InsertQuizRecord(conn, txn, quizId, titleEN, titleBM,
                                         unitId, levelId, language, userId);

                        // Determine the current max question number for ID generation
                        int maxQuestionNum = 0;
                        using (var cmd = new SqlCommand(
                            "SELECT ISNULL(MAX(CAST(SUBSTRING([questionId],4,LEN([questionId])-3) AS INT)),0) FROM dbo.[Question] WHERE [questionId] LIKE 'QST%'",
                            conn, txn))
                        {
                            maxQuestionNum = Convert.ToInt32(cmd.ExecuteScalar());
                        }

                        string langSuffix = isEnglish ? "EN" : "BM";

                        foreach (var questionData in questions)
                        {
                            maxQuestionNum++;
                            string questionId = "QST" + maxQuestionNum.ToString("D3");

                            InsertQuestion(conn, txn, questionId, quizId, subtopicId,
                                           userId, questionData, isEnglish, langSuffix);
                        }

                        InsertLogRecord(conn, txn, userId, quizId);

                        txn.Commit();

                        // Store success message and redirect
                        Session["PracticeQuizSuccess"] = isEnglish
                            ? "Practice Quiz submitted successfully."
                            : "Kuiz Latihan berjaya dihantar.";
                        Response.Redirect("~/Teacher/manageQuiz.aspx?tab=practice", false);
                        Context.ApplicationInstance.CompleteRequest();
                    }
                    catch (InvalidOperationException validationEx)
                    {
                        // Validation errors (e.g., blank mapping incomplete) — show message directly
                        txn.Rollback();
                        ShowInvalid(validationEx.Message);
                    }
                    catch (Exception ex)
                    {
                        txn.Rollback();
                        System.Diagnostics.Debug.WriteLine("[PracticeQuiz Save Error] " + ex.ToString());
                        ShowInvalid(T("The quiz could not be saved. Please try again.",
                                      "Kuiz tidak dapat disimpan. Sila cuba lagi.")
                            + " [DEBUG: " + ex.Message + "]");
                    }
                }
            }
        }

        private void InsertQuizRecord(SqlConnection conn, SqlTransaction txn,
            string quizId, string titleEN, string titleBM,
            string unitId, string levelId, string language, string userId)
        {
            const string sql = @"INSERT INTO dbo.[Quiz]
                ([quizId],[quizType],[quizTitleEN],[quizTitleBM],
                 [unitId],[levelId],[language],
                 [createdByUserId],[status],[createdAt])
                VALUES
                (@qid,'Practice',@tEN,@tBM,
                 @uid,@lid,@lang,
                 @userId,'Pending',GETDATE())";

            using (var cmd = new SqlCommand(sql, conn, txn))
            {
                cmd.Parameters.AddWithValue("@qid", quizId);
                cmd.Parameters.AddWithValue("@tEN", (object)titleEN ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@tBM", (object)titleBM ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@uid", unitId);
                cmd.Parameters.AddWithValue("@lid", levelId);
                cmd.Parameters.AddWithValue("@lang", language);
                cmd.Parameters.AddWithValue("@userId", userId);
                cmd.ExecuteNonQuery();
            }
        }

        private void InsertQuestion(SqlConnection conn, SqlTransaction txn,
            string questionId, string quizId, string subtopicId, string userId,
            Dictionary<string, object> questionData, bool isEnglish, string langSuffix)
        {
            // Local helper to extract string values from the question dictionary
            string GetValue(string key)
            {
                object val;
                return questionData.TryGetValue(key, out val) && val != null ? val.ToString() : "";
            }

            // Determine question type with fallback to MCQ
            string questionType = GetValue("type");
            if (string.IsNullOrEmpty(questionType)) questionType = "MCQ";
            switch (questionType)
            {
                case "MCQ": case "True/False": case "Multiselect": case "Drag & Drop": break;
                default: questionType = "MCQ"; break;
            }

            // Normalize difficulty
            string difficulty = GetValue("diff");
            switch (difficulty)
            {
                case "Easy": case "Medium": case "Hard": break;
                default: difficulty = "Medium"; break;
            }

            // Question text — stored in the content language slot
            string questionText = GetValue("q" + langSuffix);
            string textEN = isEnglish ? questionText : "";
            string textBM = isEnglish ? "" : questionText;

            // Resolve options based on question type
            string aEN, aBM, bEN, bBM, cEN, cBM, dEN, dBM;
            ResolveOptions(questionType, questionData, isEnglish, langSuffix, GetValue,
                           out aEN, out aBM, out bEN, out bBM,
                           out cEN, out cBM, out dEN, out dBM,
                           ref textEN, ref textBM);

            // Resolve correct answer
            string correctAnswer = ResolveCorrectAnswer(questionType, questionData,
                                                        isEnglish, langSuffix, GetValue);

            // Drag & Drop requires a non-empty correct answer
            if (questionType == "Drag & Drop" && string.IsNullOrWhiteSpace(correctAnswer))
            {
                throw new InvalidOperationException(
                    T("Please complete the correct answer mapping for every blank.",
                      "Sila lengkapkan pemetaan jawapan betul bagi setiap ruang kosong."));
            }

            // Question image — decode from data URL and save to disk
            string imageFileName = null;
            string imageRawName = GetValue("img");
            string imageDataUrl = GetValue("imgDataUrl");
            if (!string.IsNullOrWhiteSpace(imageRawName) && !string.IsNullOrWhiteSpace(imageDataUrl)
                && imageDataUrl.StartsWith("data:"))
            {
                imageFileName = SaveQuestionImageFromDataUrl(imageRawName, imageDataUrl);
            }

            // Explanations
            string correctExplanation = GetValue("ce" + langSuffix);
            string wrongExplanation   = GetValue("we" + langSuffix);
            string ceEN = isEnglish ? correctExplanation : null;
            string ceBM = isEnglish ? null : correctExplanation;
            string weEN = isEnglish ? wrongExplanation : null;
            string weBM = isEnglish ? null : wrongExplanation;

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
                cmd.Parameters.AddWithValue("@uid", userId);
                cmd.Parameters.AddWithValue("@tEN", (object)NullIfEmpty(textEN) ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@tBM", (object)NullIfEmpty(textBM) ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@type", questionType);
                cmd.Parameters.AddWithValue("@imgUrl", (object)imageFileName ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@aEN", (object)NullIfEmpty(aEN) ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@aBM", (object)NullIfEmpty(aBM) ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@bEN", (object)NullIfEmpty(bEN) ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@bBM", (object)NullIfEmpty(bBM) ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@cEN", (object)NullIfEmpty(cEN) ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@cBM", (object)NullIfEmpty(cBM) ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@dEN", (object)NullIfEmpty(dEN) ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@dBM", (object)NullIfEmpty(dBM) ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@ans", (object)NullIfEmpty(correctAnswer) ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@ceEN", (object)NullIfEmpty(ceEN) ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@ceBM", (object)NullIfEmpty(ceBM) ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@weEN", (object)NullIfEmpty(weEN) ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@weBM", (object)NullIfEmpty(weBM) ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@diff", difficulty);
                cmd.ExecuteNonQuery();
            }
        }

        private void InsertLogRecord(SqlConnection conn, SqlTransaction txn,
            string userId, string quizId)
        {
            string logId = GenerateNextId(conn, txn,
                "SELECT ISNULL(MAX(CAST(SUBSTRING([logId],4,LEN([logId])-3) AS INT)),0) FROM dbo.[Log]",
                "LOG", 3);

            using (var cmd = new SqlCommand(
                "INSERT INTO dbo.[Log]([logId],[userId],[action],[description],[logDateTime],[status]) VALUES(@id,@uid,@act,@desc,GETDATE(),'Success')",
                conn, txn))
            {
                cmd.Parameters.AddWithValue("@id", logId);
                cmd.Parameters.AddWithValue("@uid", userId);
                cmd.Parameters.AddWithValue("@act", "Quiz Submitted");
                cmd.Parameters.AddWithValue("@desc", "Submitted quiz " + quizId + " for review.");
                cmd.ExecuteNonQuery();
            }
        }

        #endregion

        #region Helper Methods

        /// <summary>
        /// Resolves option values (A/B/C/D) based on question type and language.
        /// For Drag &amp; Drop, also replaces [Blank N] markers with underscores in question text.
        /// </summary>
        private void ResolveOptions(string questionType, Dictionary<string, object> questionData,
            bool isEnglish, string langSuffix, Func<string, string> getValue,
            out string aEN, out string aBM, out string bEN, out string bBM,
            out string cEN, out string cBM, out string dEN, out string dBM,
            ref string textEN, ref string textBM)
        {
            aEN = aBM = bEN = bBM = cEN = cBM = dEN = dBM = null;

            if (questionType == "Multiselect")
            {
                string msA = getValue("msA" + langSuffix);
                string msB = getValue("msB" + langSuffix);
                string msC = getValue("msC" + langSuffix);
                string msD = getValue("msD" + langSuffix);

                if (isEnglish) { aEN = msA; bEN = msB; cEN = msC; dEN = msD; }
                else           { aBM = msA; bBM = msB; cBM = msC; dBM = msD; }
            }
            else if (questionType == "True/False")
            {
                if (isEnglish) { aEN = "True"; bEN = "False"; }
                else           { aBM = "Betul"; bBM = "Salah"; }
            }
            else if (questionType == "Drag & Drop")
            {
                string[] blanks = new string[4];
                var fibKey = "fib" + langSuffix;
                if (questionData.ContainsKey(fibKey) && questionData[fibKey] is JArray jarr)
                {
                    for (int i = 0; i < Math.Min(4, jarr.Count); i++)
                        blanks[i] = jarr[i]?.ToString() ?? "";
                }

                if (isEnglish) { aEN = blanks[0]; bEN = blanks[1]; cEN = blanks[2]; dEN = blanks[3]; }
                else           { aBM = blanks[0]; bBM = blanks[1]; cBM = blanks[2]; dBM = blanks[3]; }

                // Replace [Blank N] markers with underscores in question text
                var blankPattern = new Regex(@"\[Blank \d+\]");
                textEN = blankPattern.Replace(textEN, "_____");
                textBM = blankPattern.Replace(textBM, "_____");
            }
            else // MCQ
            {
                string a = getValue("a" + langSuffix);
                string b = getValue("b" + langSuffix);
                string c = getValue("c" + langSuffix);
                string d = getValue("d" + langSuffix);

                if (isEnglish) { aEN = a; bEN = b; cEN = c; dEN = d; }
                else           { aBM = a; bBM = b; cBM = c; dBM = d; }
            }
        }

        /// <summary>
        /// Determines the correct answer value based on question type.
        /// For Drag &amp; Drop, reconstructs from fibMap if not provided by the client.
        /// </summary>
        private string ResolveCorrectAnswer(string questionType,
            Dictionary<string, object> questionData, bool isEnglish,
            string langSuffix, Func<string, string> getValue)
        {
            if (questionType == "Multiselect")
                return getValue("msChk");

            string correctAnswer = getValue("correct");

            if (questionType == "Drag & Drop")
            {
                // If the client already built a comma-separated value, use it.
                // Otherwise rebuild from fibMap array as a safety net.
                if (string.IsNullOrWhiteSpace(correctAnswer))
                {
                    var fibMapKey = "fibMap" + langSuffix;
                    if (questionData.ContainsKey(fibMapKey) && questionData[fibMapKey] is JArray mapArr)
                    {
                        var mapped = new List<string>();
                        foreach (var token in mapArr)
                        {
                            string word = token?.ToString() ?? "";
                            if (!string.IsNullOrWhiteSpace(word))
                                mapped.Add(word.Trim());
                        }
                        correctAnswer = string.Join(",", mapped);
                    }
                }
            }

            return correctAnswer;
        }

        /// <summary>
        /// Generates the next sequential ID (e.g., Q001, QST004, LOG012) by querying
        /// the current max and incrementing.
        /// </summary>
        private string GenerateNextId(SqlConnection conn, SqlTransaction txn,
            string maxQuery, string prefix, int paddingWidth)
        {
            int currentMax;
            using (var cmd = new SqlCommand(maxQuery, conn, txn))
            {
                currentMax = Convert.ToInt32(cmd.ExecuteScalar());
            }
            return prefix + (currentMax + 1).ToString("D" + paddingWidth);
        }

        /// <summary>
        /// Saves a base64 data URL image to ~/Images/Question/ with duplicate-name handling.
        /// Returns the saved filename, or null on failure.
        /// </summary>
        private string SaveQuestionImageFromDataUrl(string originalName, string dataUrl)
        {
            try
            {
                int commaIdx = dataUrl.IndexOf(',');
                if (commaIdx < 0) return null;

                string base64 = dataUrl.Substring(commaIdx + 1);
                byte[] bytes = Convert.FromBase64String(base64);

                string fileName = System.IO.Path.GetFileName(originalName);
                if (string.IsNullOrWhiteSpace(fileName)) return null;

                string folder = Server.MapPath("~/Images/Question/");
                if (!System.IO.Directory.Exists(folder))
                    System.IO.Directory.CreateDirectory(folder);

                // Handle duplicate filenames by appending (1), (2), etc.
                string targetPath = System.IO.Path.Combine(folder, fileName);
                if (System.IO.File.Exists(targetPath))
                {
                    string nameOnly = System.IO.Path.GetFileNameWithoutExtension(fileName);
                    string extension = System.IO.Path.GetExtension(fileName);
                    int counter = 1;
                    do
                    {
                        fileName = nameOnly + "(" + counter + ")" + extension;
                        targetPath = System.IO.Path.Combine(folder, fileName);
                        counter++;
                    } while (System.IO.File.Exists(targetPath));
                }

                System.IO.File.WriteAllBytes(targetPath, bytes);
                return fileName;
            }
            catch
            {
                return null;
            }
        }

        /// <summary>
        /// Executes a query and builds a JSON array string from the results.
        /// Used by AJAX handlers to return dropdown data.
        /// </summary>
        private string BuildJsonArray(string sql, Action<SqlCommand> addParams,
            Func<SqlDataReader, object> buildItem)
        {
            try
            {
                var sb = new StringBuilder("[");
                bool first = true;

                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        addParams(cmd);
                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                if (!first) sb.Append(",");
                                first = false;

                                dynamic item = buildItem(reader);
                                sb.AppendFormat("{{\"id\":\"{0}\",\"name\":\"{1}\"}}",
                                    HttpUtility.JavaScriptStringEncode(item.id),
                                    HttpUtility.JavaScriptStringEncode(item.name));
                            }
                        }
                    }
                }

                sb.Append("]");
                return sb.ToString();
            }
            catch
            {
                return "[]";
            }
        }

        private void WriteJsonResponse(string json)
        {
            Response.Clear();
            Response.ContentType = "application/json";
            Response.Write(json);
            Response.End();
        }

        private void ShowInvalid(string message)
        {
            litInvalidMsg.Text = HttpUtility.HtmlEncode(message);
            pnlInvalid.Visible = true;
        }

        /// <summary>
        /// Returns null if the string is null or whitespace; otherwise returns the trimmed value.
        /// Used to convert empty strings to DBNull for database inserts.
        /// </summary>
        private static string NullIfEmpty(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? null : value.Trim();
        }

        #endregion
    }
}
