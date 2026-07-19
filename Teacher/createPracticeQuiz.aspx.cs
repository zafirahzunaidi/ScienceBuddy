using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.Services;
using System.Web.UI;

namespace ScienceBuddy.Teacher
{
    public partial class createPracticeQuiz : Page
    {
        protected string CurrentLanguage
        {
            get { string l = Session["preferredLanguage"] as string; return string.IsNullOrEmpty(l) ? "EN" : l; }
        }
        protected string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }

        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"]?.ToString() != "Teacher")
            { Response.Redirect("~/Login.aspx", false); Context.ApplicationInstance.CompleteRequest(); return; }

            var master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            // AJAX handlers — return JSON without full page lifecycle
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

        // -- AJAX: all levels -----------------------------------------
        private void HandleLevels()
        {
            Response.Clear(); Response.ContentType = "application/json";
            try
            {
                var sb = new System.Text.StringBuilder("[");
                bool first = true;
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("SELECT [levelId],[levelNameEN] FROM dbo.[Level] ORDER BY [levelId]", conn))
                    using (var r = cmd.ExecuteReader())
                        while (r.Read())
                        {
                            if (!first) sb.Append(","); first = false;
                            sb.AppendFormat("{{\"id\":\"{0}\",\"name\":\"{1}\"}}",
                                HttpUtility.JavaScriptStringEncode(r["levelId"].ToString()),
                                HttpUtility.JavaScriptStringEncode(r["levelNameEN"].ToString()));
                        }
                }
                sb.Append("]");
                Response.Write(sb.ToString());
            }
            catch { Response.Write("[]"); }
            Response.End();
        }

        // -- AJAX: units by level -------------------------------------
        private void HandleUnits()
        {
            Response.Clear(); Response.ContentType = "application/json";
            string levelId = (Request.QueryString["levelId"] ?? "").Trim();
            if (string.IsNullOrEmpty(levelId)) { Response.Write("[]"); Response.End(); return; }
            try
            {
                var sb = new System.Text.StringBuilder("[");
                bool first = true;
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("SELECT [unitId],[unitNameEN] FROM dbo.[Unit] WHERE [levelId]=@l ORDER BY [orderNo]", conn))
                    {
                        cmd.Parameters.AddWithValue("@l", levelId);
                        using (var r = cmd.ExecuteReader())
                            while (r.Read())
                            {
                                if (!first) sb.Append(","); first = false;
                                sb.AppendFormat("{{\"id\":\"{0}\",\"name\":\"{1}\"}}",
                                    HttpUtility.JavaScriptStringEncode(r["unitId"].ToString()),
                                    HttpUtility.JavaScriptStringEncode(r["unitNameEN"].ToString()));
                            }
                    }
                }
                sb.Append("]");
                Response.Write(sb.ToString());
            }
            catch { Response.Write("[]"); }
            Response.End();
        }

        // -- AJAX: subtopics by unit ----------------------------------
        private void HandleSubtopics()
        {
            Response.Clear(); Response.ContentType = "application/json";
            string unitId = (Request.QueryString["unitId"] ?? "").Trim();
            if (string.IsNullOrEmpty(unitId)) { Response.Write("[]"); Response.End(); return; }
            try
            {
                var sb = new System.Text.StringBuilder("[");
                bool first = true;
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("SELECT [subtopicId],[subtopicTitleEN] FROM dbo.[Subtopic] WHERE [unitId]=@u ORDER BY [orderNo]", conn))
                    {
                        cmd.Parameters.AddWithValue("@u", unitId);
                        using (var r = cmd.ExecuteReader())
                            while (r.Read())
                            {
                                if (!first) sb.Append(","); first = false;
                                sb.AppendFormat("{{\"id\":\"{0}\",\"name\":\"{1}\"}}",
                                    HttpUtility.JavaScriptStringEncode(r["subtopicId"].ToString()),
                                    HttpUtility.JavaScriptStringEncode(r["subtopicTitleEN"].ToString()));
                            }
                    }
                }
                sb.Append("]");
                Response.Write(sb.ToString());
            }
            catch { Response.Write("[]"); }
            Response.End();
        }

        // -- Authorization ---------------------------------------------
        private bool AuthorizeTeacher()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [status] FROM dbo.[Teacher] WHERE [userId]=@u", conn))
                {
                    cmd.Parameters.AddWithValue("@u", Session["userId"].ToString());
                    var val = cmd.ExecuteScalar();
                    if (val == null || val == DBNull.Value ||
                        !val.ToString().Equals("Certified", StringComparison.OrdinalIgnoreCase))
                    { pnlDenied.Visible = true; return false; }
                }
            }
            return true;
        }

        // -- Validate query-string params and populate hero ------------
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
                ShowInvalid(T("Invalid language selection.", "Pilihan bahasa tidak sah.")); return;
            }

            string levelName = null, unitName = null, subtopicName = null;

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                using (var cmd = new SqlCommand("SELECT [levelNameEN] FROM dbo.[Level] WHERE [levelId]=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", levelId);
                    var v = cmd.ExecuteScalar();
                    if (v == null || v == DBNull.Value) { ShowInvalid(T("The selected Level does not exist.", "Tahap yang dipilih tidak wujud.")); return; }
                    levelName = v.ToString();
                }

                using (var cmd = new SqlCommand("SELECT [unitNameEN] FROM dbo.[Unit] WHERE [unitId]=@uid AND [levelId]=@lid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", unitId);
                    cmd.Parameters.AddWithValue("@lid", levelId);
                    var v = cmd.ExecuteScalar();
                    if (v == null || v == DBNull.Value) { ShowInvalid(T("The selected Unit does not belong to the chosen Level.", "Unit yang dipilih tidak tergolong dalam Tahap yang dipilih.")); return; }
                    unitName = v.ToString();
                }

                using (var cmd = new SqlCommand("SELECT [subtopicTitleEN] FROM dbo.[Subtopic] WHERE [subtopicId]=@sid AND [unitId]=@uid", conn))
                {
                    cmd.Parameters.AddWithValue("@sid", subtopicId);
                    cmd.Parameters.AddWithValue("@uid", unitId);
                    var v = cmd.ExecuteScalar();
                    if (v == null || v == DBNull.Value) { ShowInvalid(T("The selected Subtopic does not belong to the chosen Unit.", "Subtopik yang dipilih tidak tergolong dalam Unit yang dipilih.")); return; }
                    subtopicName = v.ToString();
                }
            }

            string langLabel = language == "BM" ? "Bahasa Melayu" : "English";

            litLevel.Text    = HttpUtility.HtmlEncode(levelName);
            litUnit.Text     = HttpUtility.HtmlEncode(unitName);
            litSubtopic.Text = HttpUtility.HtmlEncode(subtopicName);
            litLanguage.Text = HttpUtility.HtmlEncode(langLabel);

            // Populate hidden fields for JS to read
            hidLevelId.Value    = levelId;
            hidUnitId.Value     = unitId;
            hidSubtopicId.Value = subtopicId;
            hidLanguage.Value   = language;

            pnlMain.Visible = true;
        }

        private void ShowInvalid(string message)
        {
            litInvalidMsg.Text = HttpUtility.HtmlEncode(message);
            pnlInvalid.Visible = true;
        }

        // -- Submit Practice Quiz --------------------------------------
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
                ShowInvalid(T("Missing required data. Please try again.", "Data yang diperlukan tiada. Sila cuba lagi.")
                    + " [DEBUG: title=" + (quizTitle ?? "NULL") + " sub=" + (subtopicId ?? "NULL") + " unit=" + (unitId ?? "NULL") + " lang=" + (language ?? "NULL") + "]");
                return;
            }

            // Parse questions from JSON
            System.Collections.Generic.List<System.Collections.Generic.Dictionary<string, object>> questions;
            try
            {
                questions = Newtonsoft.Json.JsonConvert.DeserializeObject<
                    System.Collections.Generic.List<System.Collections.Generic.Dictionary<string, object>>>(questionsJson);
            }
            catch
            {
                ShowInvalid(T("Invalid question data.", "Data soalan tidak sah."));
                return;
            }

            if (questions == null || questions.Count == 0)
            {
                ShowInvalid(T("At least one question is required.", "Sekurang-kurangnya satu soalan diperlukan."));
                return;
            }

            bool isEN = language == "EN";
            string titleEN = isEN ? quizTitle : null;
            string titleBM = isEN ? null : quizTitle;

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var txn = conn.BeginTransaction())
                {
                    try
                    {
                        // Generate Quiz ID
                        int maxQuizNum = 0;
                        using (var cmd = new SqlCommand(
                            "SELECT ISNULL(MAX(CAST(SUBSTRING([quizId],2,LEN([quizId])-1) AS INT)),0) FROM dbo.[Quiz] WHERE [quizId] LIKE 'Q%' AND ISNUMERIC(SUBSTRING([quizId],2,LEN([quizId])-1))=1",
                            conn, txn))
                        { maxQuizNum = Convert.ToInt32(cmd.ExecuteScalar()); }
                        maxQuizNum++;
                        string quizId = "Q" + maxQuizNum.ToString("D3");

                        // Insert Quiz record
                        const string quizSql = @"INSERT INTO dbo.[Quiz]
                            ([quizId],[quizType],[quizTitleEN],[quizTitleBM],
                             [unitId],[levelId],[language],
                             [createdByUserId],[status],[createdAt])
                            VALUES
                            (@qid,'Practice',@tEN,@tBM,
                             @uid,@lid,@lang,
                             @userId,'Pending',GETDATE())";

                        using (var cmd = new SqlCommand(quizSql, conn, txn))
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

                        // Generate Question IDs
                        int maxQstNum = 0;
                        using (var cmd = new SqlCommand(
                            "SELECT ISNULL(MAX(CAST(SUBSTRING([questionId],4,LEN([questionId])-3) AS INT)),0) FROM dbo.[Question] WHERE [questionId] LIKE 'QST%'",
                            conn, txn))
                        { maxQstNum = Convert.ToInt32(cmd.ExecuteScalar()); }

                        string qSuf = isEN ? "EN" : "BM";
                        string otherSuf = isEN ? "BM" : "EN";

                        foreach (var qDict in questions)
                        {
                            maxQstNum++;
                            string qid = "QST" + maxQstNum.ToString("D3");

                            string G(string key) { object v; return qDict.TryGetValue(key, out v) && v != null ? v.ToString() : ""; }
                            string Nv(string s) { return string.IsNullOrWhiteSpace(s) ? null : s.Trim(); }

                            string qType = G("type");
                            if (string.IsNullOrEmpty(qType)) qType = "MCQ";
                            // Normalize to English standard values
                            switch (qType) { case "MCQ": case "True/False": case "Multiselect": case "Drag & Drop": break; default: qType = "MCQ"; break; }

                            string difficulty = G("diff");
                            switch (difficulty) { case "Easy": case "Medium": case "Hard": break; default: difficulty = "Medium"; break; }

                            // Question text — stored in the content language slot
                            string textContent = G("q" + qSuf);
                            string textEN = isEN ? textContent : "";
                            string textBM = isEN ? "" : textContent;

                            // Options — resolve per type
                            string aEN, aBM, bEN, bBM, cEN, cBM, dEN, dBM;
                            if (qType == "Multiselect")
                            {
                                string msA = G("msA" + qSuf), msB = G("msB" + qSuf), msC = G("msC" + qSuf), msD = G("msD" + qSuf);
                                if (isEN) { aEN = msA; bEN = msB; cEN = msC; dEN = msD; aBM = null; bBM = null; cBM = null; dBM = null; }
                                else { aBM = msA; bBM = msB; cBM = msC; dBM = msD; aEN = null; bEN = null; cEN = null; dEN = null; }
                            }
                            else if (qType == "True/False")
                            {
                                // Store True/False options only in the quiz content language
                                if (isEN) { aEN = "True"; bEN = "False"; aBM = null; bBM = null; }
                                else { aBM = "Betul"; bBM = "Salah"; aEN = null; bEN = null; }
                                cEN = null; cBM = null; dEN = null; dBM = null;
                            }
                            else if (qType == "Drag & Drop")
                            {
                                string[] fib = new string[4];
                                var fibKey = "fib" + qSuf;
                                if (qDict.ContainsKey(fibKey) && qDict[fibKey] is Newtonsoft.Json.Linq.JArray jarr)
                                {
                                    for (int fi = 0; fi < Math.Min(4, jarr.Count); fi++)
                                        fib[fi] = jarr[fi]?.ToString() ?? "";
                                }
                                if (isEN) { aEN = fib[0]; bEN = fib[1]; cEN = fib[2]; dEN = fib[3]; aBM = null; bBM = null; cBM = null; dBM = null; }
                                else { aBM = fib[0]; bBM = fib[1]; cBM = fib[2]; dBM = fib[3]; aEN = null; bEN = null; cEN = null; dEN = null; }

                                // Replace blank markers with _____
                                var blankPattern = new System.Text.RegularExpressions.Regex(@"\[Blank \d+\]");
                                textEN = blankPattern.Replace(textEN, "_____");
                                textBM = blankPattern.Replace(textBM, "_____");
                            }
                            else // MCQ
                            {
                                string a = G("a" + qSuf), b = G("b" + qSuf), c = G("c" + qSuf), d = G("d" + qSuf);
                                if (isEN) { aEN = a; bEN = b; cEN = c; dEN = d; aBM = null; bBM = null; cBM = null; dBM = null; }
                                else { aBM = a; bBM = b; cBM = c; dBM = d; aEN = null; bEN = null; cEN = null; dEN = null; }
                            }

                            // Correct answer
                            string correctAnswer = G("correct");
                            if (qType == "Multiselect") correctAnswer = G("msChk");

                            // Drag & Drop: build correctAnswer from fibMap (same as Unit/Level Quiz)
                            if (qType == "Drag & Drop")
                            {
                                // If JS already built the comma-separated correct value, use it.
                                // Otherwise, rebuild from fibMap array as a safety net.
                                if (string.IsNullOrWhiteSpace(correctAnswer))
                                {
                                    var fibMapKey = "fibMap" + qSuf;
                                    if (qDict.ContainsKey(fibMapKey) && qDict[fibMapKey] is Newtonsoft.Json.Linq.JArray mapArr)
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
                                // Final guard: never allow NULL correctAnswer for Drag & Drop
                                if (string.IsNullOrWhiteSpace(correctAnswer))
                                {
                                    txn.Rollback();
                                    ShowInvalid(T("Please complete the correct answer mapping for every blank.",
                                                  "Sila lengkapkan pemetaan jawapan betul bagi setiap ruang kosong."));
                                    return;
                                }
                            }

                            // Question image — decode from data URL and save to Images/Question/
                            string imgFileName = null;
                            string imgRawName = G("img");
                            string imgDataUrl = G("imgDataUrl");
                            if (!string.IsNullOrWhiteSpace(imgRawName) && !string.IsNullOrWhiteSpace(imgDataUrl)
                                && imgDataUrl.StartsWith("data:"))
                            {
                                imgFileName = SaveQuestionImageFromDataUrl(imgRawName, imgDataUrl);
                            }

                            // Explanations
                            string ceContent = G("ce" + qSuf), weContent = G("we" + qSuf);
                            string ceEN = isEN ? ceContent : null;
                            string ceBM = isEN ? null : ceContent;
                            string weEN = isEN ? weContent : null;
                            string weBM = isEN ? null : weContent;

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
                                cmd.Parameters.AddWithValue("@qid", qid);
                                cmd.Parameters.AddWithValue("@quiz", quizId);
                                cmd.Parameters.AddWithValue("@sub", subtopicId);
                                cmd.Parameters.AddWithValue("@uid", userId);
                                cmd.Parameters.AddWithValue("@tEN", (object)Nv(textEN) ?? DBNull.Value);
                                cmd.Parameters.AddWithValue("@tBM", (object)Nv(textBM) ?? DBNull.Value);
                                cmd.Parameters.AddWithValue("@type", qType);
                                cmd.Parameters.AddWithValue("@imgUrl", (object)imgFileName ?? DBNull.Value);
                                cmd.Parameters.AddWithValue("@aEN", (object)Nv(aEN) ?? DBNull.Value);
                                cmd.Parameters.AddWithValue("@aBM", (object)Nv(aBM) ?? DBNull.Value);
                                cmd.Parameters.AddWithValue("@bEN", (object)Nv(bEN) ?? DBNull.Value);
                                cmd.Parameters.AddWithValue("@bBM", (object)Nv(bBM) ?? DBNull.Value);
                                cmd.Parameters.AddWithValue("@cEN", (object)Nv(cEN) ?? DBNull.Value);
                                cmd.Parameters.AddWithValue("@cBM", (object)Nv(cBM) ?? DBNull.Value);
                                cmd.Parameters.AddWithValue("@dEN", (object)Nv(dEN) ?? DBNull.Value);
                                cmd.Parameters.AddWithValue("@dBM", (object)Nv(dBM) ?? DBNull.Value);
                                cmd.Parameters.AddWithValue("@ans", (object)Nv(correctAnswer) ?? DBNull.Value);
                                cmd.Parameters.AddWithValue("@ceEN", (object)Nv(ceEN) ?? DBNull.Value);
                                cmd.Parameters.AddWithValue("@ceBM", (object)Nv(ceBM) ?? DBNull.Value);
                                cmd.Parameters.AddWithValue("@weEN", (object)Nv(weEN) ?? DBNull.Value);
                                cmd.Parameters.AddWithValue("@weBM", (object)Nv(weBM) ?? DBNull.Value);
                                cmd.Parameters.AddWithValue("@diff", difficulty);
                                cmd.ExecuteNonQuery();
                            }
                        }

                        // Insert Log record (inside transaction — only persists if commit succeeds)
                        int maxLogNum = 0;
                        using (var logCmd = new SqlCommand(
                            "SELECT ISNULL(MAX(CAST(SUBSTRING([logId],4,LEN([logId])-3) AS INT)),0) FROM dbo.[Log]",
                            conn, txn))
                        { maxLogNum = Convert.ToInt32(logCmd.ExecuteScalar()); }
                        string logId = "LOG" + (maxLogNum + 1).ToString("D3");
                        using (var logCmd = new SqlCommand(
                            "INSERT INTO dbo.[Log]([logId],[userId],[action],[description],[logDateTime],[status]) VALUES(@id,@uid,@act,@desc,GETDATE(),'Success')",
                            conn, txn))
                        {
                            logCmd.Parameters.AddWithValue("@id", logId);
                            logCmd.Parameters.AddWithValue("@uid", userId);
                            logCmd.Parameters.AddWithValue("@act", "Quiz Submitted");
                            logCmd.Parameters.AddWithValue("@desc", "Submitted quiz " + quizId + " for review.");
                            logCmd.ExecuteNonQuery();
                        }

                        txn.Commit();

                        // Store success message in Session and redirect to Manage Quiz
                        Session["PracticeQuizSuccess"] = isEN
                            ? "Practice Quiz submitted successfully."
                            : "Kuiz Latihan berjaya dihantar.";
                        Response.Redirect("~/Teacher/manageQuiz.aspx?tab=practice", false);
                        Context.ApplicationInstance.CompleteRequest();
                        return;
                    }
                    catch (Exception ex)
                    {
                        txn.Rollback();
                        System.Diagnostics.Debug.WriteLine("[PracticeQuiz Save Error] " + ex.ToString());
                        ShowInvalid(T("The quiz could not be saved. Please try again.",
                                      "Kuiz tidak dapat disimpan. Sila cuba lagi.") + " [DEBUG: " + ex.Message + "]");
                    }
                }
            }
        }

        // -- WebMethod: Switch language without page reload ------------
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

        // -- Save question image from base64 data URL to Images/Question/ --
        // Returns just the filename saved (with duplicate handling), or null on failure.
        private string SaveQuestionImageFromDataUrl(string originalName, string dataUrl)
        {
            try
            {
                // Extract base64 content from data URL (format: "data:image/png;base64,AAAA...")
                int commaIdx = dataUrl.IndexOf(',');
                if (commaIdx < 0) return null;
                string base64 = dataUrl.Substring(commaIdx + 1);
                byte[] bytes = Convert.FromBase64String(base64);

                string fileName = System.IO.Path.GetFileName(originalName);
                if (string.IsNullOrWhiteSpace(fileName)) return null;

                string folder = Server.MapPath("~/Images/Question/");
                if (!System.IO.Directory.Exists(folder))
                    System.IO.Directory.CreateDirectory(folder);

                // Duplicate handling: if file exists, append (1), (2), etc.
                string targetPath = System.IO.Path.Combine(folder, fileName);
                if (System.IO.File.Exists(targetPath))
                {
                    string nameOnly = System.IO.Path.GetFileNameWithoutExtension(fileName);
                    string ext = System.IO.Path.GetExtension(fileName);
                    int counter = 1;
                    do
                    {
                        fileName = nameOnly + "(" + counter + ")" + ext;
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
    }
}
