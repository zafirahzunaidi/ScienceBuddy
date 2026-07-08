using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Student
{
    public partial class Quiz : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        public string CurrentLanguage = "EN";
        public string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }
        private const decimal PASS_THRESHOLD = 70m;

        private DataTable Questions
        {
            get { return ViewState["Qs"] as DataTable; }
            set { ViewState["Qs"] = value; }
        }
        private Dictionary<int, string> Answers
        {
            get { return ViewState["Ans"] as Dictionary<int, string> ?? new Dictionary<int, string>(); }
            set { ViewState["Ans"] = value; }
        }
        private int CurrentIdx
        {
            get { return ViewState["Idx"] != null ? (int)ViewState["Idx"] : 0; }
            set { ViewState["Idx"] = value; }
        }

        // Mark settings from ConfigurationSetting
        private decimal EasyMark = 1, MediumMark = 3, HardMark = 5;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null || Session["role"].ToString() != "Student")
            { Response.Redirect("~/Login.aspx", false); return; }
            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            InitLang();
            if (!IsPostBack) LoadQuiz();
        }

        private void InitLang()
        {
            string lang = Session["preferredLanguage"] as string;
            if (!string.IsNullOrEmpty(lang)) { CurrentLanguage = lang; return; }
            string uid = Session["userId"] as string;
            if (!string.IsNullOrEmpty(uid))
            {
                try
                {
                    using (var c = new SqlConnection(ConnStr))
                    using (var cmd = new SqlCommand("SELECT preferredLanguage FROM [User] WHERE userId=@u", c))
                    { cmd.Parameters.AddWithValue("@u", uid); c.Open(); object r = cmd.ExecuteScalar();
                      if (r != null && r != DBNull.Value) { lang = r.ToString(); Session["preferredLanguage"] = lang; CurrentLanguage = lang; return; } }
                } catch { }
            }
            CurrentLanguage = "EN"; Session["preferredLanguage"] = "EN";
        }

        private void LoadMarkSettings(SqlConnection conn)
        {
            try
            {
                const string sql = "SELECT configKey, configValue FROM ConfigurationSetting WHERE configKey IN ('Easy Question Mark','Medium Question Mark','Hard Question Mark')";
                using (var cmd = new SqlCommand(sql, conn))
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        string key = rdr["configKey"].ToString();
                        decimal val;
                        if (decimal.TryParse(rdr["configValue"].ToString(), out val))
                        {
                            if (key.Contains("Easy")) EasyMark = val;
                            else if (key.Contains("Medium")) MediumMark = val;
                            else if (key.Contains("Hard")) HardMark = val;
                        }
                    }
                }
            }
            catch { /* fallback to defaults */ }
        }

        private decimal GetMarkForDifficulty(string difficulty)
        {
            if (string.IsNullOrWhiteSpace(difficulty)) return EasyMark;
            switch (difficulty.ToLower().Trim())
            {
                case "medium": return MediumMark;
                case "hard": return HardMark;
                default: return EasyMark;
            }
        }

        private void LoadQuiz()
        {
            string quizId = Request.QueryString["quizId"];
            if (string.IsNullOrEmpty(quizId)) { ShowError(T("Quiz not found", "Kuiz tidak dijumpai"), T("No quiz ID provided.", "Tiada ID kuiz.")); return; }
            string userId = Session["userId"].ToString();

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                string studentId = null, currentLevelId = null;
                using (var cmd = new SqlCommand("SELECT studentId, currentLevelId FROM Student WHERE userId=@u", conn))
                { cmd.Parameters.AddWithValue("@u", userId); using (var r = cmd.ExecuteReader()) { if (r.Read()) { studentId = r["studentId"].ToString(); currentLevelId = r["currentLevelId"] == DBNull.Value ? null : r["currentLevelId"].ToString(); } } }
                if (string.IsNullOrEmpty(studentId)) { ShowError(T("Student not found", "Pelajar tidak dijumpai"), T("Profile not found.", "Profil tidak dijumpai.")); return; }

                const string qzSql = @"SELECT q.quizId,q.quizTitleEN,q.quizTitleBM,q.quizType,q.levelId,q.unitId,
                    lv.levelNameEN,lv.levelNameBM,u.unitNameEN,u.unitNameBM
                    FROM Quiz q LEFT JOIN Level lv ON lv.levelId=q.levelId LEFT JOIN Unit u ON u.unitId=q.unitId
                    WHERE q.quizId=@qid AND (q.status IS NULL OR q.status IN ('Approved','Published'))";
                DataRow qzRow = null;
                using (var cmd = new SqlCommand(qzSql, conn))
                { cmd.Parameters.AddWithValue("@qid", quizId); var dt = new DataTable(); new SqlDataAdapter(cmd).Fill(dt);
                  if (dt.Rows.Count == 0) { ShowError(T("Quiz not found", "Kuiz tidak dijumpai"), T("This quiz does not exist.", "Kuiz ini tidak wujud.")); return; }
                  qzRow = dt.Rows[0]; }

                string quizType = S(qzRow, "quizType"); if (string.IsNullOrWhiteSpace(quizType)) quizType = "Practice";
                string levelId = S(qzRow, "levelId");

                // Access check
                if (!string.IsNullOrEmpty(levelId) && !string.IsNullOrEmpty(currentLevelId))
                { int ql = ExtractNum(levelId), sl = ExtractNum(currentLevelId);
                  if (ql > sl) { ShowError(T("Level Locked", "Tahap Dikunci"), T("Reach this level first.", "Capai tahap ini dahulu.")); return; } }

                // Load questions — allow Approved or NULL status (admin-created)
                const string qSql = @"SELECT questionId,questionTextEN,questionTextBM,questionType,questionImageUrl,
                    optionA_EN,optionA_BM,optionB_EN,optionB_BM,optionC_EN,optionC_BM,optionD_EN,optionD_BM,
                    correctAnswer,difficulty FROM Question WHERE quizId=@qid AND (status='Approved' OR status IS NULL) ORDER BY questionId";
                DataTable questions;
                using (var cmd = new SqlCommand(qSql, conn)) { cmd.Parameters.AddWithValue("@qid", quizId); questions = new DataTable(); new SqlDataAdapter(cmd).Fill(questions); }
                if (questions.Rows.Count == 0)
                {
                    // Debug: try without status filter to see if questions exist at all
                    int totalAny = 0;
                    using (var cmd2 = new SqlCommand("SELECT COUNT(*) FROM Question WHERE quizId=@qid", conn))
                    { cmd2.Parameters.AddWithValue("@qid", quizId); totalAny = (int)cmd2.ExecuteScalar(); }
                    string debugInfo = "<!-- DEBUG: quizId=" + quizId + ", questionsWithStatusFilter=0, totalQuestionsForQuiz=" + totalAny + " -->";
                    ShowError(T("No Questions", "Tiada Soalan"), T("No questions available for this quiz.", "Tiada soalan untuk kuiz ini.") + debugInfo);
                    return;
                }

                ViewState["QuizId"] = quizId; ViewState["QuizType"] = quizType;
                ViewState["StudentId"] = studentId; ViewState["UnitId"] = S(qzRow, "unitId"); ViewState["LevelId"] = levelId;
                Questions = questions; Answers = new Dictionary<int, string>(); CurrentIdx = 0;

                bool isBM = CurrentLanguage == "BM";
                string title = isBM ? S(qzRow, "quizTitleBM") : S(qzRow, "quizTitleEN");
                if (string.IsNullOrWhiteSpace(title)) title = S(qzRow, "quizTitleEN");
                litQuizTitle.Text = HttpUtility.HtmlEncode(title);
                litQType.Text = GetTypeLabel(quizType);
                litQuizSub.Text = GetInstructions(quizType);
                litQCount.Text = questions.Rows.Count + " " + T("questions", "soalan");
                litPageTitle.Text = GetTypeLabel(quizType);
                litProgressLabel.Text = T("Progress", "Kemajuan");
                btnPrev.Text = T("Previous", "Sebelumnya"); btnNext.Text = T("Next", "Seterusnya"); btnSubmit.Text = T("Submit Quiz", "Hantar Kuiz");

                pnlQuiz.Visible = true; pnlError.Visible = false;
                DisplayQuestion(0);
            }
        }

        private void DisplayQuestion(int idx)
        {
            var dt = Questions; if (dt == null || idx < 0 || idx >= dt.Rows.Count) return;
            CurrentIdx = idx; var row = dt.Rows[idx]; int total = dt.Rows.Count;
            bool isBM = CurrentLanguage == "BM";
            pnlValMsg.Visible = false;

            // Restore saved answer
            var answers = Answers;
            string savedAns = answers.ContainsKey(idx) ? answers[idx] : "";

            // Progress
            int pct = (int)((idx + 1) * 100.0 / total);
            progressFill.Style["width"] = pct + "%";
            litProgressCount.Text = (idx + 1) + " / " + total;
            litQNum.Text = T("Question ", "Soalan ") + (idx + 1) + " / " + total;

            // Text
            string qText = isBM ? S(row, "questionTextBM") : S(row, "questionTextEN");
            if (string.IsNullOrWhiteSpace(qText)) qText = S(row, "questionTextEN");
            litQText.Text = HttpUtility.HtmlEncode(qText);

            // Image
            string imgUrl = S(row, "questionImageUrl");
            if (!string.IsNullOrWhiteSpace(imgUrl) && imgUrl.ToLower() != "optional" && imgUrl.ToLower() != "null")
            { string p = imgUrl.StartsWith("~/") ? imgUrl : imgUrl.StartsWith("Images/") ? "~/" + imgUrl : "~/Images/Question/" + imgUrl;
              imgQuestion.ImageUrl = ResolveUrl(p); imgQuestion.Visible = true; }
            else { imgQuestion.Visible = false; }

            // Difficulty
            string diff = S(row, "difficulty");
            if (!string.IsNullOrWhiteSpace(diff)) { pnlQDiff.Visible = true; divDiff.Attributes["class"] = "st-quiz-q-diff " + diff.ToLower(); litQDiff.Text = diff; }
            else { pnlQDiff.Visible = false; }

            // Options
            string optA = isBM ? S(row, "optionA_BM") : S(row, "optionA_EN"); if (string.IsNullOrWhiteSpace(optA)) optA = S(row, "optionA_EN");
            string optB = isBM ? S(row, "optionB_BM") : S(row, "optionB_EN"); if (string.IsNullOrWhiteSpace(optB)) optB = S(row, "optionB_EN");
            string optC = isBM ? S(row, "optionC_BM") : S(row, "optionC_EN"); if (string.IsNullOrWhiteSpace(optC)) optC = S(row, "optionC_EN");
            string optD = isBM ? S(row, "optionD_BM") : S(row, "optionD_EN"); if (string.IsNullOrWhiteSpace(optD)) optD = S(row, "optionD_EN");

            string qType = NormalizeQuestionType(S(row, "questionType"));
            pnlMCQ.Visible = false; pnlTF.Visible = false; pnlMulti.Visible = false; pnlDrag.Visible = false;

            switch (qType)
            {
                case "TF": RenderTF(optA, optB, savedAns); break;
                case "MULTISELECT": RenderMulti(optA, optB, optC, optD, savedAns); break;
                case "DRAGDROP": RenderDragDrop(qText, optA, optB, optC, optD, savedAns, row); break;
                default: RenderMCQ(optA, optB, optC, optD, savedAns); break;
            }

            // Nav
            btnPrev.Visible = idx > 0;
            bool isLast = idx == total - 1;
            btnNext.Visible = !isLast; btnSubmit.Visible = isLast;
        }

        private void RenderMCQ(string a, string b, string c, string d, string saved)
        {
            pnlMCQ.Visible = true;
            rblMCQ.Items.Clear();
            if (!string.IsNullOrWhiteSpace(a)) rblMCQ.Items.Add(new ListItem("A. " + a, "A"));
            if (!string.IsNullOrWhiteSpace(b)) rblMCQ.Items.Add(new ListItem("B. " + b, "B"));
            if (!string.IsNullOrWhiteSpace(c)) rblMCQ.Items.Add(new ListItem("C. " + c, "C"));
            if (!string.IsNullOrWhiteSpace(d)) rblMCQ.Items.Add(new ListItem("D. " + d, "D"));
            if (!string.IsNullOrEmpty(saved)) { var li = rblMCQ.Items.FindByValue(saved); if (li != null) li.Selected = true; }
        }

        private void RenderTF(string a, string b, string saved)
        {
            pnlTF.Visible = true;
            rblTF.Items.Clear();
            string trueLabel = !string.IsNullOrWhiteSpace(a) ? a : T("True", "Betul");
            string falseLabel = !string.IsNullOrWhiteSpace(b) ? b : T("False", "Salah");
            rblTF.Items.Add(new ListItem("<span class=\"qz-tf-ico\"><i class=\"bi bi-check-circle-fill\" style=\"color:#22C55E;\"></i></span><span class=\"qz-tf-lbl\">" + HttpUtility.HtmlEncode(trueLabel) + "</span>", "A"));
            rblTF.Items.Add(new ListItem("<span class=\"qz-tf-ico\"><i class=\"bi bi-x-circle-fill\" style=\"color:#EF4444;\"></i></span><span class=\"qz-tf-lbl\">" + HttpUtility.HtmlEncode(falseLabel) + "</span>", "B"));
            if (!string.IsNullOrEmpty(saved)) { var li = rblTF.Items.FindByValue(saved); if (li != null) li.Selected = true; }
        }

        private void RenderMulti(string a, string b, string c, string d, string saved)
        {
            pnlMulti.Visible = true;
            litMultiHint.Text = T("Select all correct answers", "Pilih semua jawapan yang betul");
            cblMulti.Items.Clear();
            if (!string.IsNullOrWhiteSpace(a)) cblMulti.Items.Add(new ListItem("A. " + a, "A"));
            if (!string.IsNullOrWhiteSpace(b)) cblMulti.Items.Add(new ListItem("B. " + b, "B"));
            if (!string.IsNullOrWhiteSpace(c)) cblMulti.Items.Add(new ListItem("C. " + c, "C"));
            if (!string.IsNullOrWhiteSpace(d)) cblMulti.Items.Add(new ListItem("D. " + d, "D"));
            if (!string.IsNullOrEmpty(saved))
            {
                var sel = saved.Split(',').Select(x => x.Trim()).ToHashSet(StringComparer.OrdinalIgnoreCase);
                foreach (ListItem li in cblMulti.Items) { if (sel.Contains(li.Value)) li.Selected = true; }
            }
        }

        private void RenderDragDrop(string qText, string a, string b, string c, string d, string saved, DataRow row)
        {
            pnlDrag.Visible = true;
            // Count blanks
            int blanks = qText.Split(new[] { "_____" }, StringSplitOptions.None).Length - 1;
            if (blanks < 1) blanks = 1;
            litDragHint.Text = blanks > 1
                ? T("Drag or click options in order to fill " + blanks + " blanks", "Seret atau klik pilihan mengikut urutan untuk mengisi " + blanks + " tempat kosong")
                : T("Drag or click an option to fill the blank", "Seret atau klik pilihan untuk mengisi tempat kosong");
            litDDResetBtn.Text = T("Reset", "Tetapkan Semula");
            litDDPlaceholder.Text = T("Drag answers here or click them", "Seret jawapan ke sini atau klik padanya");

            // Build chips as plain HTML with draggable and onclick
            var options = new List<string>();
            if (!string.IsNullOrWhiteSpace(a)) options.Add(a);
            if (!string.IsNullOrWhiteSpace(b)) options.Add(b);
            if (!string.IsNullOrWhiteSpace(c)) options.Add(c);
            if (!string.IsNullOrWhiteSpace(d)) options.Add(d);

            string chipsHtml = "";
            foreach (var opt in options)
            {
                string escaped = HttpUtility.HtmlEncode(opt);
                string jsVal = HttpUtility.JavaScriptStringEncode(opt);
                chipsHtml += string.Format(
                    "<div class=\"qz-dd-chip\" draggable=\"true\" data-value=\"{0}\" " +
                    "ondragstart=\"ddStartDrag(event,'{1}')\" ondragend=\"ddEndDrag(event)\" " +
                    "onclick=\"ddChipClick('{1}')\">{0}</div>",
                    escaped, jsVal);
            }
            litDDChips.Text = chipsHtml;

            // Set hidden field value
            hdnDDAnswer.Value = saved ?? "";

            // Register startup script to initialize the DD with correct blanks count and hidden field ID
            string initScript = string.Format("ddInit({0}, '{1}', '{2}');",
                blanks,
                hdnDDAnswer.ClientID,
                HttpUtility.JavaScriptStringEncode(saved ?? ""));
            ScriptManager.RegisterStartupScript(this, GetType(), "ddInitScript", initScript, true);

            ViewState["DDBlanks"] = blanks;
        }

        // ── Navigation ────────────────────────────────────────────────
        protected void btnPrev_Click(object sender, EventArgs e) { SaveCurrentAnswer(); int i = CurrentIdx; if (i > 0) DisplayQuestion(i - 1); }
        protected void btnNext_Click(object sender, EventArgs e) { SaveCurrentAnswer(); int i = CurrentIdx; int t = Questions != null ? Questions.Rows.Count : 0; if (i < t - 1) DisplayQuestion(i + 1); }

        private void SaveCurrentAnswer()
        {
            int idx = CurrentIdx;
            var dt = Questions; if (dt == null || idx >= dt.Rows.Count) return;
            string qType = NormalizeQuestionType(S(dt.Rows[idx], "questionType"));
            string answer = "";

            switch (qType)
            {
                case "TF": answer = rblTF.SelectedValue; break;
                case "MULTISELECT":
                    var sel = new List<string>();
                    foreach (ListItem li in cblMulti.Items) { if (li.Selected) sel.Add(li.Value); }
                    sel.Sort(); answer = string.Join(",", sel); break;
                case "DRAGDROP": answer = hdnDDAnswer.Value; break;
                default: answer = rblMCQ.SelectedValue; break;
            }

            var answers = Answers; answers[idx] = answer; Answers = answers;
        }

        // ── Submit ────────────────────────────────────────────────────
        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            SaveCurrentAnswer();
            var answers = Answers; var dt = Questions;
            if (dt == null || dt.Rows.Count == 0) return;

            // Validate all answered
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                if (!answers.ContainsKey(i) || string.IsNullOrWhiteSpace(answers[i]))
                {
                    pnlValMsg.Visible = true;
                    litValMsg.Text = T("Please answer all questions before submitting.", "Sila jawab semua soalan sebelum menghantar.");
                    return;
                }
            }

            string quizId = ViewState["QuizId"] as string;
            string studentId = ViewState["StudentId"] as string;
            string quizType = ViewState["QuizType"] as string;

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                LoadMarkSettings(conn);

                // Calculate
                decimal totalMarks = 0, score = 0;
                var details = new List<AnsDetail>();
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    var row = dt.Rows[i];
                    string qid = row["questionId"].ToString();
                    string correct = S(row, "correctAnswer");
                    string selected = answers.ContainsKey(i) ? answers[i] : "";
                    string qType = NormalizeQuestionType(S(row, "questionType"));
                    string diff = S(row, "difficulty");
                    decimal mark = GetMarkForDifficulty(diff);
                    totalMarks += mark;
                    bool isCorrect = CheckAnswer(qType, selected, correct, row);
                    decimal awarded = isCorrect ? mark : 0;
                    score += awarded;
                    details.Add(new AnsDetail { QuestionId = qid, Selected = selected, IsCorrect = isCorrect, Marks = awarded });
                }

                decimal percentage = totalMarks > 0 ? Math.Round(score * 100m / totalMarks, 2) : 0;
                string status = percentage >= PASS_THRESHOLD ? "Passed" : "Failed";

                using (var trans = conn.BeginTransaction())
                {
                    try
                    {
                        // Attempt number
                        int attemptNo = 1;
                        using (var cmd = new SqlCommand("SELECT ISNULL(MAX(attemptNo),0) FROM QuizResult WHERE studentId=@s AND quizId=@q", conn, trans))
                        { cmd.Parameters.AddWithValue("@s", studentId); cmd.Parameters.AddWithValue("@q", quizId); attemptNo = Convert.ToInt32(cmd.ExecuteScalar()) + 1; }

                        // Generate resultId QR###
                        string resultId = "QR001";
                        using (var cmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING(resultId,3,LEN(resultId)-2) AS INT)),0) FROM QuizResult WHERE resultId LIKE 'QR[0-9]%'", conn, trans))
                        { int last = Convert.ToInt32(cmd.ExecuteScalar()); resultId = "QR" + (last + 1).ToString("D3"); }

                        // Insert QuizResult
                        using (var cmd = new SqlCommand(@"INSERT INTO QuizResult (resultId,studentId,quizId,score,totalMarks,percentage,resultStatus,attemptNo,attemptedDate)
                            VALUES (@rid,@sid,@qid,@sc,@tm,@pct,@st,@att,@dt)", conn, trans))
                        {
                            cmd.Parameters.AddWithValue("@rid", resultId); cmd.Parameters.AddWithValue("@sid", studentId);
                            cmd.Parameters.AddWithValue("@qid", quizId); cmd.Parameters.AddWithValue("@sc", score);
                            cmd.Parameters.AddWithValue("@tm", totalMarks); cmd.Parameters.AddWithValue("@pct", percentage);
                            cmd.Parameters.AddWithValue("@st", status); cmd.Parameters.AddWithValue("@att", attemptNo);
                            cmd.Parameters.AddWithValue("@dt", DateTime.Now); cmd.ExecuteNonQuery();
                        }

                        // Generate answerId base QA###
                        int ansBase = 0;
                        using (var cmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING(answerId,3,LEN(answerId)-2) AS INT)),0) FROM QuizAnswer WHERE answerId LIKE 'QA[0-9]%'", conn, trans))
                        { ansBase = Convert.ToInt32(cmd.ExecuteScalar()); }

                        foreach (var d in details)
                        {
                            ansBase++;
                            string aid = "QA" + ansBase.ToString("D3");
                            using (var cmd = new SqlCommand(@"INSERT INTO QuizAnswer (answerId,resultId,questionId,selectedAnswer,isCorrect,marksAwarded)
                                VALUES (@aid,@rid,@qid,@sel,@cor,@m)", conn, trans))
                            {
                                cmd.Parameters.AddWithValue("@aid", aid); cmd.Parameters.AddWithValue("@rid", resultId);
                                cmd.Parameters.AddWithValue("@qid", d.QuestionId); cmd.Parameters.AddWithValue("@sel", (object)d.Selected ?? DBNull.Value);
                                cmd.Parameters.AddWithValue("@cor", d.IsCorrect ? 1 : 0); cmd.Parameters.AddWithValue("@m", d.Marks);
                                cmd.ExecuteNonQuery();
                            }
                        }

                        // XP award
                        AwardXP(conn, trans, studentId, quizType, percentage, attemptNo);

                        trans.Commit();
                        Response.Redirect("~/Student/QuizResult.aspx?resultId=" + resultId, false);
                    }
                    catch { trans.Rollback(); ShowError(T("Error", "Ralat"), T("Submission failed. Please try again.", "Penghantaran gagal. Sila cuba lagi.")); }
                }
            }
        }

        // ── Marking ───────────────────────────────────────────────────
        private bool CheckAnswer(string qType, string selected, string correct, DataRow row)
        {
            if (string.IsNullOrWhiteSpace(selected) || string.IsNullOrWhiteSpace(correct)) return false;
            selected = selected.Trim(); correct = correct.Trim();

            switch (qType)
            {
                case "TF":
                case "MCQ":
                    return string.Equals(selected, correct, StringComparison.OrdinalIgnoreCase);

                case "MULTISELECT":
                    var selSet = selected.Split(',').Select(x => x.Trim().ToUpper()).Where(x => x.Length > 0).OrderBy(x => x).ToList();
                    var corSet = correct.Split(',').Select(x => x.Trim().ToUpper()).Where(x => x.Length > 0).OrderBy(x => x).ToList();
                    return selSet.SequenceEqual(corSet);

                case "DRAGDROP":
                    // correctAnswer may be bilingual: "Tongue,Lidah" for single blank
                    // or multi-blank: "Sun,Earth,Red"
                    var correctParts = correct.Split(',').Select(x => x.Trim()).ToList();
                    var selectedParts = selected.Split(',').Select(x => x.Trim()).ToList();

                    // Single blank: selected has 1 item, correct may have EN/BM alternatives
                    if (selectedParts.Count == 1)
                    {
                        return correctParts.Any(cp => string.Equals(cp, selectedParts[0], StringComparison.OrdinalIgnoreCase));
                    }

                    // Multiple blanks: check exact sequence match against correct
                    if (selectedParts.Count == correctParts.Count)
                    {
                        bool allMatch = true;
                        for (int i = 0; i < selectedParts.Count; i++)
                        { if (!string.Equals(selectedParts[i], correctParts[i], StringComparison.OrdinalIgnoreCase)) { allMatch = false; break; } }
                        return allMatch;
                    }
                    return false;

                default:
                    return string.Equals(selected, correct, StringComparison.OrdinalIgnoreCase);
            }
        }

        private void AwardXP(SqlConnection conn, SqlTransaction trans, string studentId, string quizType, decimal pct, int attemptNo)
        {
            try
            {
                string search = quizType == "Practice" ? "Practice" : quizType == "Unit" ? "Unit" : "Level";
                bool shouldAward = quizType == "Practice" || (pct >= PASS_THRESHOLD && (quizType != "Unit" || attemptNo == 1));
                if (!shouldAward) return;

                string xaId = null;
                using (var cmd = new SqlCommand("SELECT TOP 1 xpActionId FROM XPAction WHERE actionNameEN LIKE '%'+@s+'%'", conn, trans))
                { cmd.Parameters.AddWithValue("@s", search); var r = cmd.ExecuteScalar(); if (r != null && r != DBNull.Value) xaId = r.ToString(); }
                if (xaId == null) return;

                string xtId = "XT001";
                using (var cmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING(xpTransactionId,3,LEN(xpTransactionId)-2) AS INT)),0) FROM XPTransaction WHERE xpTransactionId LIKE 'XT[0-9]%'", conn, trans))
                { xtId = "XT" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3"); }

                int amt = 10;
                using (var cmd = new SqlCommand("INSERT INTO XPTransaction (xpTransactionId,studentId,xpActionId,xpAmount,dateEarned) VALUES (@id,@s,@xa,@a,@d)", conn, trans))
                { cmd.Parameters.AddWithValue("@id", xtId); cmd.Parameters.AddWithValue("@s", studentId); cmd.Parameters.AddWithValue("@xa", xaId); cmd.Parameters.AddWithValue("@a", amt); cmd.Parameters.AddWithValue("@d", DateTime.Today); cmd.ExecuteNonQuery(); }

                using (var cmd = new SqlCommand("UPDATE Student SET XP=ISNULL(XP,0)+@a WHERE studentId=@s", conn, trans))
                { cmd.Parameters.AddWithValue("@a", amt); cmd.Parameters.AddWithValue("@s", studentId); cmd.ExecuteNonQuery(); }
            }
            catch { }
        }

        // ── Helpers ───────────────────────────────────────────────────
        private string NormalizeQuestionType(string qt)
        {
            if (string.IsNullOrWhiteSpace(qt)) return "MCQ";
            string raw = qt.Trim().ToLower().Replace(" ", "").Replace("/", "").Replace("&", "").Replace("-", "");
            if (raw.Contains("truefalse") || raw == "tf") return "TF";
            if (raw.Contains("multi")) return "MULTISELECT";
            if (raw.Contains("drag") || raw.Contains("drop")) return "DRAGDROP";
            return "MCQ";
        }

        private string GetTypeLabel(string t)
        {
            switch (t) { case "Practice": return T("Practice Quiz", "Kuiz Latihan"); case "Unit": return T("Unit Quiz", "Kuiz Unit"); case "Level": return T("Level Assessment", "Penilaian Tahap"); default: return T("Quiz", "Kuiz"); }
        }
        private string GetInstructions(string t)
        {
            switch (t) { case "Practice": return T("This quiz helps you practise and strengthen your Science understanding.", "Kuiz ini membantu anda berlatih dan mengukuhkan kefahaman Sains."); case "Unit": return T("Complete this quiz to check your understanding of this unit.", "Selesaikan kuiz ini untuk menyemak kefahaman anda tentang unit ini."); case "Level": return T("This assessment checks your understanding for the whole level.", "Penilaian ini menyemak kefahaman anda untuk keseluruhan tahap."); default: return T("Answer all questions.", "Jawab semua soalan."); }
        }

        private void ShowError(string title, string desc)
        {
            pnlError.Visible = true; pnlQuiz.Visible = false;
            litErrorTitle.Text = HttpUtility.HtmlEncode(title);
            litErrorDesc.Text = HttpUtility.HtmlEncode(desc);
            litErrorBtn.Text = T("Back", "Kembali");
        }

        private static string S(DataRow r, string c) { return r[c] != null && r[c] != DBNull.Value ? r[c].ToString() : ""; }
        private static int ExtractNum(string id) { string n = new string(id.Where(char.IsDigit).ToArray()); int v; return int.TryParse(n, out v) ? v : 0; }

        [Serializable]
        private class AnsDetail { public string QuestionId; public string Selected; public bool IsCorrect; public decimal Marks; }
    }
}

