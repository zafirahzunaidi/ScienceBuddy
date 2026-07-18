using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ScienceBuddy.Services;

namespace ScienceBuddy.Student
{
    public partial class Quiz : Page
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

        // Pass threshold is now loaded dynamically from ConfigurationSetting
        // private const decimal PASS_THRESHOLD = 70m;

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
            {
                Response.Redirect("~/Login.aspx", false);
                return;
            }
            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            InitLang();
            if (!IsPostBack)
            {
                LoadQuiz();
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
            string uid = Session["userId"] as string;
            if (!string.IsNullOrEmpty(uid))
            {
                try
                {
                    using (SqlConnection connection = new SqlConnection(ConnStr))
                    using (SqlCommand command = new SqlCommand("SELECT preferredLanguage FROM [User] WHERE userId=@u", connection))
                    {
                        command.Parameters.AddWithValue("@u", uid);
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

        private void LoadMarkSettings(SqlConnection conn)
        {
            try
            {
                const string sql = "SELECT configKey, configValue FROM ConfigurationSetting WHERE configKey IN ('Easy Question Mark','Medium Question Mark','Hard Question Mark')";
                using (SqlCommand command = new SqlCommand(sql, conn))
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string key = reader["configKey"].ToString();
                        decimal val;
                        if (decimal.TryParse(reader["configValue"].ToString(), out val))
                        {
                            if (key.Contains("Easy"))
                            {
                                EasyMark = val;
                            }
                            else if (key.Contains("Medium"))
                            {
                                MediumMark = val;
                            }
                            else if (key.Contains("Hard"))
                            {
                                HardMark = val;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error: " + ex.Message);
                /* fallback to defaults */
            }
        }

        private decimal GetMarkForDifficulty(string difficulty)
        {
            if (string.IsNullOrWhiteSpace(difficulty))
            {
                return EasyMark;
            }
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
            if (string.IsNullOrEmpty(quizId))
            {
                ShowError(T("Quiz not found", "Kuiz tidak dijumpai"), T("No quiz ID provided.", "Tiada ID kuiz."));
                return;
            }
            string userId = Session["userId"].ToString();

            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();

                string studentId = null, currentLevelId = null;
                using (SqlCommand command = new SqlCommand("SELECT studentId, currentLevelId FROM Student WHERE userId=@u", connection))
                {
                    command.Parameters.AddWithValue("@u", userId);
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            studentId = reader["studentId"].ToString();
                            if (reader["currentLevelId"] == DBNull.Value)
                            {
                                currentLevelId = null;
                            }
                            else
                            {
                                currentLevelId = reader["currentLevelId"].ToString();
                            }
                        }
                    }
                }
                if (string.IsNullOrEmpty(studentId))
                {
                    ShowError(T("Student not found", "Pelajar tidak dijumpai"), T("Profile not found.", "Profil tidak dijumpai."));
                    return;
                }

                const string qzSql = @"SELECT q.quizId,q.quizTitleEN,q.quizTitleBM,q.quizType,q.levelId,q.unitId,
                    lv.levelNameEN,lv.levelNameBM,u.unitNameEN,u.unitNameBM
                    FROM Quiz q LEFT JOIN Level lv ON lv.levelId=q.levelId LEFT JOIN Unit u ON u.unitId=q.unitId
                    WHERE q.quizId=@qid AND (q.status IS NULL OR q.status IN ('Approved','Published'))";
                DataRow qzRow = null;
                using (SqlCommand command = new SqlCommand(qzSql, connection))
                {
                    command.Parameters.AddWithValue("@qid", quizId);
                    DataTable dataTable = new DataTable();
                    new SqlDataAdapter(command).Fill(dataTable);
                    if (dataTable.Rows.Count == 0)
                    {
                        ShowError(T("Quiz not found", "Kuiz tidak dijumpai"), T("This quiz does not exist.", "Kuiz ini tidak wujud."));
                        return;
                    }
                    qzRow = dataTable.Rows[0];
                }

                string quizType = S(qzRow, "quizType");
                if (string.IsNullOrWhiteSpace(quizType))
                {
                    quizType = "Practice";
                }
                string levelId = S(qzRow, "levelId");

                // Access check
                if (!string.IsNullOrEmpty(levelId) && !string.IsNullOrEmpty(currentLevelId))
                {
                    int ql = ExtractNum(levelId);
                    int sl = ExtractNum(currentLevelId);
                    if (ql > sl)
                    {
                        ShowError(T("Level Locked", "Tahap Dikunci"), T("Reach this level first.", "Capai tahap ini dahulu."));
                        return;
                    }
                }

                // Load questions — allow Approved or NULL status (admin-created)
                const string qSql = @"SELECT questionId,questionTextEN,questionTextBM,questionType,questionImageUrl,
                    optionA_EN,optionA_BM,optionB_EN,optionB_BM,optionC_EN,optionC_BM,optionD_EN,optionD_BM,
                    correctAnswer,difficulty FROM Question WHERE quizId=@qid AND (status='Approved' OR status IS NULL) ORDER BY questionId";
                DataTable questions;
                using (SqlCommand command = new SqlCommand(qSql, connection))
                {
                    command.Parameters.AddWithValue("@qid", quizId);
                    questions = new DataTable();
                    new SqlDataAdapter(command).Fill(questions);
                }
                if (questions.Rows.Count == 0)
                {
                    // Debug: try without status filter to see if questions exist at all
                    int totalAny = 0;
                    using (SqlCommand command = new SqlCommand("SELECT COUNT(*) FROM Question WHERE quizId=@qid", connection))
                    {
                        command.Parameters.AddWithValue("@qid", quizId);
                        totalAny = (int)command.ExecuteScalar();
                    }
                    string debugInfo = "<!-- DEBUG: quizId=" + quizId + ", questionsWithStatusFilter=0, totalQuestionsForQuiz=" + totalAny + " -->";
                    ShowError(T("No Questions", "Tiada Soalan"), T("No questions available for this quiz.", "Tiada soalan untuk kuiz ini.") + debugInfo);
                    return;
                }

                ViewState["QuizId"] = quizId;
                ViewState["QuizType"] = quizType;
                ViewState["StudentId"] = studentId;
                ViewState["UnitId"] = S(qzRow, "unitId");
                ViewState["LevelId"] = levelId;
                Questions = questions;
                Answers = new Dictionary<int, string>();
                CurrentIdx = 0;

                bool isBM = CurrentLanguage == "BM";
                string title;
                if (isBM)
                {
                    title = S(qzRow, "quizTitleBM");
                }
                else
                {
                    title = S(qzRow, "quizTitleEN");
                }
                if (string.IsNullOrWhiteSpace(title))
                {
                    title = S(qzRow, "quizTitleEN");
                }
                if (string.IsNullOrWhiteSpace(title))
                {
                    title = S(qzRow, "quizTitleBM");
                }
                litQuizTitle.Text = HttpUtility.HtmlEncode(title);
                litQType.Text = GetTypeLabel(quizType);
                litQuizSub.Text = GetInstructions(quizType);
                litQCount.Text = questions.Rows.Count + " " + T("questions", "soalan");
                litPageTitle.Text = GetTypeLabel(quizType);
                litProgressLabel.Text = T("Progress", "Kemajuan");
                btnPrev.Text = T("Previous", "Sebelumnya");
                btnNext.Text = T("Next", "Seterusnya");
                btnSubmit.Text = T("Submit Quiz", "Hantar Kuiz");

                pnlQuiz.Visible = true;
                pnlError.Visible = false;
                DisplayQuestion(0);
            }
        }

        private void DisplayQuestion(int idx)
        {
            DataTable dt = Questions;
            if (dt == null || idx < 0 || idx >= dt.Rows.Count)
            {
                return;
            }
            CurrentIdx = idx;
            DataRow row = dt.Rows[idx];
            int total = dt.Rows.Count;
            bool isBM = CurrentLanguage == "BM";
            pnlValMsg.Visible = false;

            // Restore saved answer
            Dictionary<int, string> answers = Answers;
            string savedAns = "";
            if (answers.ContainsKey(idx))
            {
                savedAns = answers[idx];
            }

            // Progress
            int pct = (int)((idx + 1) * 100.0 / total);
            progressFill.Style["width"] = pct + "%";
            litProgressCount.Text = (idx + 1) + " / " + total;
            litQNum.Text = T("Question ", "Soalan ") + (idx + 1) + " / " + total;

            // Text — for Practice quizzes, content may only exist in one language
            string qText;
            if (isBM)
            {
                qText = S(row, "questionTextBM");
            }
            else
            {
                qText = S(row, "questionTextEN");
            }
            if (string.IsNullOrWhiteSpace(qText))
            {
                qText = S(row, "questionTextEN");
            }
            if (string.IsNullOrWhiteSpace(qText))
            {
                qText = S(row, "questionTextBM");
            }
            litQText.Text = HttpUtility.HtmlEncode(qText);

            // Image
            string imgUrl = S(row, "questionImageUrl");
            if (!string.IsNullOrWhiteSpace(imgUrl) && imgUrl.ToLower() != "optional" && imgUrl.ToLower() != "null")
            {
                string p;
                if (imgUrl.StartsWith("~/"))
                {
                    p = imgUrl;
                }
                else if (imgUrl.StartsWith("Images/"))
                {
                    p = "~/" + imgUrl;
                }
                else
                {
                    p = "~/Images/Question/" + imgUrl;
                }
                imgQuestion.ImageUrl = ResolveUrl(p);
                imgQuestion.Visible = true;
            }
            else
            {
                imgQuestion.Visible = false;
            }

            // Difficulty
            string diff = S(row, "difficulty");
            if (!string.IsNullOrWhiteSpace(diff))
            {
                pnlQDiff.Visible = true;
                divDiff.Attributes["class"] = "st-quiz-q-diff " + diff.ToLower();
                litQDiff.Text = diff;
            }
            else
            {
                pnlQDiff.Visible = false;
            }

            // Options — for Practice quizzes, options may only exist in one language
            string optA;
            if (isBM)
            {
                optA = S(row, "optionA_BM");
            }
            else
            {
                optA = S(row, "optionA_EN");
            }
            if (string.IsNullOrWhiteSpace(optA))
            {
                optA = S(row, "optionA_EN");
            }
            if (string.IsNullOrWhiteSpace(optA))
            {
                optA = S(row, "optionA_BM");
            }

            string optB;
            if (isBM)
            {
                optB = S(row, "optionB_BM");
            }
            else
            {
                optB = S(row, "optionB_EN");
            }
            if (string.IsNullOrWhiteSpace(optB))
            {
                optB = S(row, "optionB_EN");
            }
            if (string.IsNullOrWhiteSpace(optB))
            {
                optB = S(row, "optionB_BM");
            }

            string optC;
            if (isBM)
            {
                optC = S(row, "optionC_BM");
            }
            else
            {
                optC = S(row, "optionC_EN");
            }
            if (string.IsNullOrWhiteSpace(optC))
            {
                optC = S(row, "optionC_EN");
            }
            if (string.IsNullOrWhiteSpace(optC))
            {
                optC = S(row, "optionC_BM");
            }

            string optD;
            if (isBM)
            {
                optD = S(row, "optionD_BM");
            }
            else
            {
                optD = S(row, "optionD_EN");
            }
            if (string.IsNullOrWhiteSpace(optD))
            {
                optD = S(row, "optionD_EN");
            }
            if (string.IsNullOrWhiteSpace(optD))
            {
                optD = S(row, "optionD_BM");
            }

            string qType = NormalizeQuestionType(S(row, "questionType"));
            pnlMCQ.Visible = false;
            pnlTF.Visible = false;
            pnlMulti.Visible = false;
            pnlDrag.Visible = false;

            switch (qType)
            {
                case "TF":
                    RenderTF(optA, optB, savedAns);
                    break;
                case "MULTISELECT":
                    RenderMulti(optA, optB, optC, optD, savedAns);
                    break;
                case "DRAGDROP":
                    RenderDragDrop(qText, optA, optB, optC, optD, savedAns, row);
                    break;
                default:
                    RenderMCQ(optA, optB, optC, optD, savedAns);
                    break;
            }

            // Nav
            btnPrev.Visible = idx > 0;
            bool isLast = idx == total - 1;
            btnNext.Visible = !isLast;
            btnSubmit.Visible = isLast;
        }

        private void RenderMCQ(string a, string b, string c, string d, string saved)
        {
            pnlMCQ.Visible = true;
            rblMCQ.Items.Clear();
            if (!string.IsNullOrWhiteSpace(a))
            {
                rblMCQ.Items.Add(new ListItem("A. " + a, "A"));
            }
            if (!string.IsNullOrWhiteSpace(b))
            {
                rblMCQ.Items.Add(new ListItem("B. " + b, "B"));
            }
            if (!string.IsNullOrWhiteSpace(c))
            {
                rblMCQ.Items.Add(new ListItem("C. " + c, "C"));
            }
            if (!string.IsNullOrWhiteSpace(d))
            {
                rblMCQ.Items.Add(new ListItem("D. " + d, "D"));
            }
            if (!string.IsNullOrEmpty(saved))
            {
                ListItem li = rblMCQ.Items.FindByValue(saved);
                if (li != null)
                {
                    li.Selected = true;
                }
            }
        }

        private void RenderTF(string a, string b, string saved)
        {
            pnlTF.Visible = true;
            rblTF.Items.Clear();
            string trueLabel;
            if (!string.IsNullOrWhiteSpace(a))
            {
                trueLabel = a;
            }
            else
            {
                trueLabel = T("True", "Betul");
            }
            string falseLabel;
            if (!string.IsNullOrWhiteSpace(b))
            {
                falseLabel = b;
            }
            else
            {
                falseLabel = T("False", "Salah");
            }
            rblTF.Items.Add(new ListItem("<span class=\"st-quiz-tf-ico\"><i class=\"bi bi-check-circle-fill\" style=\"color:#22C55E;\"></i></span><span class=\"st-quiz-tf-lbl\">" + HttpUtility.HtmlEncode(trueLabel) + "</span>", "A"));
            rblTF.Items.Add(new ListItem("<span class=\"st-quiz-tf-ico\"><i class=\"bi bi-x-circle-fill\" style=\"color:#EF4444;\"></i></span><span class=\"st-quiz-tf-lbl\">" + HttpUtility.HtmlEncode(falseLabel) + "</span>", "B"));
            if (!string.IsNullOrEmpty(saved))
            {
                ListItem li = rblTF.Items.FindByValue(saved);
                if (li != null)
                {
                    li.Selected = true;
                }
            }
        }

        private void RenderMulti(string a, string b, string c, string d, string saved)
        {
            pnlMulti.Visible = true;
            litMultiHint.Text = T("Select all correct answers", "Pilih semua jawapan yang betul");
            cblMulti.Items.Clear();
            if (!string.IsNullOrWhiteSpace(a))
            {
                cblMulti.Items.Add(new ListItem("A. " + a, "A"));
            }
            if (!string.IsNullOrWhiteSpace(b))
            {
                cblMulti.Items.Add(new ListItem("B. " + b, "B"));
            }
            if (!string.IsNullOrWhiteSpace(c))
            {
                cblMulti.Items.Add(new ListItem("C. " + c, "C"));
            }
            if (!string.IsNullOrWhiteSpace(d))
            {
                cblMulti.Items.Add(new ListItem("D. " + d, "D"));
            }
            if (!string.IsNullOrEmpty(saved))
            {
                var sel = saved.Split(',').Select(x => x.Trim()).ToHashSet(StringComparer.OrdinalIgnoreCase);
                foreach (ListItem li in cblMulti.Items)
                {
                    if (sel.Contains(li.Value))
                    {
                        li.Selected = true;
                    }
                }
            }
        }

        private void RenderDragDrop(string qText, string a, string b, string c, string d, string saved, DataRow row)
        {
            pnlDrag.Visible = true;
            // Count blanks
            int blanks = qText.Split(new[] { "_____" }, StringSplitOptions.None).Length - 1;
            if (blanks < 1)
            {
                blanks = 1;
            }
            if (blanks > 1)
            {
                litDragHint.Text = T("Drag or click options in order to fill " + blanks + " blanks", "Seret atau klik pilihan mengikut urutan untuk mengisi " + blanks + " tempat kosong");
            }
            else
            {
                litDragHint.Text = T("Drag or click an option to fill the blank", "Seret atau klik pilihan untuk mengisi tempat kosong");
            }
            litDDResetBtn.Text = T("Reset", "Tetapkan Semula");
            litDDPlaceholder.Text = T("Drag answers here or click them", "Seret jawapan ke sini atau klik padanya");

            // Build chips as plain HTML with draggable and onclick
            List<string> options = new List<string>();
            if (!string.IsNullOrWhiteSpace(a))
            {
                options.Add(a);
            }
            if (!string.IsNullOrWhiteSpace(b))
            {
                options.Add(b);
            }
            if (!string.IsNullOrWhiteSpace(c))
            {
                options.Add(c);
            }
            if (!string.IsNullOrWhiteSpace(d))
            {
                options.Add(d);
            }

            string chipsHtml = "";
            foreach (string opt in options)
            {
                string escaped = HttpUtility.HtmlEncode(opt);
                string jsVal = HttpUtility.JavaScriptStringEncode(opt);
                chipsHtml += string.Format(
                    "<div class=\"st-quiz-dd-chip\" draggable=\"true\" data-value=\"{0}\" " +
                    "ondragstart=\"ddStartDrag(event,'{1}')\" ondragend=\"ddEndDrag(event)\" " +
                    "onclick=\"ddChipClick('{1}')\">{0}</div>",
                    escaped, jsVal);
            }
            litDDChips.Text = chipsHtml;

            // Set hidden field value
            if (saved != null)
            {
                hdnDDAnswer.Value = saved;
            }
            else
            {
                hdnDDAnswer.Value = "";
            }

            // Register startup script to initialize the DD with correct blanks count and hidden field ID
            string initScript = string.Format("ddInit({0}, '{1}', '{2}');",
                blanks,
                hdnDDAnswer.ClientID,
                HttpUtility.JavaScriptStringEncode(saved ?? ""));
            ScriptManager.RegisterStartupScript(this, GetType(), "ddInitScript", initScript, true);

            ViewState["DDBlanks"] = blanks;
        }

        // ── Navigation ────────────────────────────────────────────────
        protected void btnPrev_Click(object sender, EventArgs e)
        {
            SaveCurrentAnswer();
            int i = CurrentIdx;
            if (i > 0)
            {
                DisplayQuestion(i - 1);
            }
        }

        protected void btnNext_Click(object sender, EventArgs e)
        {
            SaveCurrentAnswer();
            int i = CurrentIdx;
            int t = Questions != null ? Questions.Rows.Count : 0;
            if (i < t - 1)
            {
                DisplayQuestion(i + 1);
            }
        }

        private void SaveCurrentAnswer()
        {
            int idx = CurrentIdx;
            DataTable dt = Questions;
            if (dt == null || idx >= dt.Rows.Count)
            {
                return;
            }
            string qType = NormalizeQuestionType(S(dt.Rows[idx], "questionType"));
            string answer = "";

            switch (qType)
            {
                case "TF":
                    answer = rblTF.SelectedValue;
                    break;
                case "MULTISELECT":
                    List<string> sel = new List<string>();
                    foreach (ListItem li in cblMulti.Items)
                    {
                        if (li.Selected)
                        {
                            sel.Add(li.Value);
                        }
                    }
                    sel.Sort();
                    answer = string.Join(",", sel);
                    break;
                case "DRAGDROP":
                    answer = hdnDDAnswer.Value;
                    break;
                default:
                    answer = rblMCQ.SelectedValue;
                    break;
            }

            Dictionary<int, string> answers = Answers;
            answers[idx] = answer;
            Answers = answers;
        }

        // ── Submit ────────────────────────────────────────────────────
        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            SaveCurrentAnswer();
            Dictionary<int, string> answers = Answers;
            DataTable dt = Questions;
            if (dt == null || dt.Rows.Count == 0)
            {
                return;
            }

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

            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();
                LoadMarkSettings(connection);

                // Calculate
                decimal totalMarks = 0, score = 0;
                List<AnsDetail> details = new List<AnsDetail>();
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    DataRow row = dt.Rows[i];
                    string qid = row["questionId"].ToString();
                    string correct = S(row, "correctAnswer");
                    string selected = "";
                    if (answers.ContainsKey(i))
                    {
                        selected = answers[i];
                    }
                    string qType = NormalizeQuestionType(S(row, "questionType"));
                    string diff = S(row, "difficulty");
                    decimal mark = GetMarkForDifficulty(diff);
                    totalMarks += mark;
                    bool isCorrect = CheckAnswer(qType, selected, correct, row);
                    decimal awarded;
                    if (isCorrect)
                    {
                        awarded = mark;
                    }
                    else
                    {
                        awarded = 0;
                    }
                    score += awarded;
                    details.Add(new AnsDetail { QuestionId = qid, Selected = selected, IsCorrect = isCorrect, Marks = awarded });
                }

                decimal percentage;
                if (totalMarks > 0)
                {
                    percentage = Math.Round(score * 100m / totalMarks, 2);
                }
                else
                {
                    percentage = 0;
                }

                // Determine pass mark based on quiz type from ConfigurationSetting
                decimal passThreshold;
                if (quizType == "Unit")
                {
                    passThreshold = GetConfigInt(connection, null, "Passing Mark Percentage for Unit", 50);
                }
                else if (quizType == "Level")
                {
                    passThreshold = GetConfigInt(connection, null, "Passing Mark for Level", 70);
                }
                else
                {
                    // Practice quizzes - use a default threshold for display
                    passThreshold = 50;
                }

                string status;
                if (percentage >= passThreshold)
                {
                    status = "Passed";
                }
                else
                {
                    status = "Failed";
                }

                using (SqlTransaction trans = connection.BeginTransaction())
                {
                    try
                    {
                        // Attempt number
                        int attemptNo = 1;
                        using (SqlCommand command = new SqlCommand("SELECT ISNULL(MAX(attemptNo),0) FROM QuizResult WHERE studentId=@s AND quizId=@q", connection, trans))
                        {
                            command.Parameters.AddWithValue("@s", studentId);
                            command.Parameters.AddWithValue("@q", quizId);
                            attemptNo = Convert.ToInt32(command.ExecuteScalar()) + 1;
                        }

                        // Generate resultId QR###
                        string resultId = "QR001";
                        using (SqlCommand command = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING(resultId,3,LEN(resultId)-2) AS INT)),0) FROM QuizResult WHERE resultId LIKE 'QR[0-9]%'", connection, trans))
                        {
                            int last = Convert.ToInt32(command.ExecuteScalar());
                            resultId = "QR" + (last + 1).ToString("D3");
                        }

                        // Insert QuizResult
                        using (SqlCommand command = new SqlCommand(@"INSERT INTO QuizResult (resultId,studentId,quizId,score,totalMarks,percentage,resultStatus,attemptNo,attemptedDate)
                            VALUES (@rid,@sid,@qid,@sc,@tm,@pct,@st,@att,@dt)", connection, trans))
                        {
                            command.Parameters.AddWithValue("@rid", resultId);
                            command.Parameters.AddWithValue("@sid", studentId);
                            command.Parameters.AddWithValue("@qid", quizId);
                            command.Parameters.AddWithValue("@sc", score);
                            command.Parameters.AddWithValue("@tm", totalMarks);
                            command.Parameters.AddWithValue("@pct", percentage);
                            command.Parameters.AddWithValue("@st", status);
                            command.Parameters.AddWithValue("@att", attemptNo);
                            command.Parameters.AddWithValue("@dt", DateTime.Now);
                            command.ExecuteNonQuery();
                        }

                        // Generate answerId base QA###
                        int ansBase = 0;
                        using (SqlCommand command = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING(answerId,3,LEN(answerId)-2) AS INT)),0) FROM QuizAnswer WHERE answerId LIKE 'QA[0-9]%'", connection, trans))
                        {
                            ansBase = Convert.ToInt32(command.ExecuteScalar());
                        }

                        foreach (AnsDetail d in details)
                        {
                            ansBase++;
                            string aid = "QA" + ansBase.ToString("D3");
                            using (SqlCommand command = new SqlCommand(@"INSERT INTO QuizAnswer (answerId,resultId,questionId,selectedAnswer,isCorrect,marksAwarded)
                                VALUES (@aid,@rid,@qid,@sel,@cor,@m)", connection, trans))
                            {
                                command.Parameters.AddWithValue("@aid", aid);
                                command.Parameters.AddWithValue("@rid", resultId);
                                command.Parameters.AddWithValue("@qid", d.QuestionId);
                                command.Parameters.AddWithValue("@sel", (object)d.Selected ?? DBNull.Value);
                                command.Parameters.AddWithValue("@cor", d.IsCorrect ? 1 : 0);
                                command.Parameters.AddWithValue("@m", d.Marks);
                                command.ExecuteNonQuery();
                            }
                        }

                        // XP award
                        AwardXP(connection, trans, studentId, quizType, percentage, attemptNo);

                        // Badge checks
                        CheckQuizBadges(connection, trans, studentId, quizType, percentage, quizId);

                        trans.Commit();

                        // Send quiz completed notification
                        try
                        {
                            using (SqlConnection notifConn = new SqlConnection(ConnStr))
                            {
                                notifConn.Open();
                                string studentUserId = Session["userId"].ToString();
                                SendNotification(notifConn, studentUserId,
                                    "Quiz Completed", "Kuiz Selesai",
                                    "You scored " + Math.Round(percentage, 0) + "% on your quiz.",
                                    "Anda memperoleh " + Math.Round(percentage, 0) + "% pada kuiz anda.");
                            }
                        }
                        catch (Exception notifEx)
                        {
                            System.Diagnostics.Debug.WriteLine("Quiz notification error: " + notifEx.Message);
                        }

                        // Generate the analysis only after the quiz has been saved.
                        try
                        {
                            StudentLearningAnalysisService analysisService = new StudentLearningAnalysisService(ConnStr);

                            analysisService.GenerateAndSaveAnalysis(
                                studentId,
                                resultId,
                                CurrentLanguage
                            );
                        }
                        catch (Exception analysisEx)
                        {
                            System.Diagnostics.Debug.WriteLine(
                                "Learning analysis error: " +
                                analysisEx.Message
                            );
                        }

                        // Check badges after quiz completion
                        CheckQuizBadges(studentId, quizType, percentage, quizId);

                        Response.Redirect(
                            "~/Student/QuizResult.aspx?resultId=" +
                            resultId,
                            false
                        );

                        Context.ApplicationInstance.CompleteRequest();
                        return;
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine("Error: " + ex.Message);
                        trans.Rollback();
                        ShowError(T("Error", "Ralat"), T("Submission failed. Please try again.", "Penghantaran gagal. Sila cuba lagi."));
                    }
                }
            }
        }

        // ── Marking ───────────────────────────────────────────────────
        private bool CheckAnswer(string qType, string selected, string correct, DataRow row)
        {
            if (string.IsNullOrWhiteSpace(selected) || string.IsNullOrWhiteSpace(correct))
            {
                return false;
            }
            selected = selected.Trim();
            correct = correct.Trim();

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
                        {
                            if (!string.Equals(selectedParts[i], correctParts[i], StringComparison.OrdinalIgnoreCase))
                            {
                                allMatch = false;
                                break;
                            }
                        }
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
                // Determine which XP actions to award based on quiz type and result
                // XP003 = Attempt Practice Quiz (always, per attempt)
                // XP004 = Pass Unit Quiz (first attempt only, if passed)
                // XP005 = Score 80% or Above (any quiz, if >= 80%)
                // XP006 = Complete Level Assessment (if passed)

                int passMarkUnit = GetConfigInt(conn, trans, "Passing Mark Percentage for Unit", 50);
                int passMarkLevel = GetConfigInt(conn, trans, "Passing Mark for Level", 70);

                if (quizType == "Practice")
                {
                    // XP003: always award for each practice attempt
                    int xp003 = GetXpValue(conn, trans, "XP003");
                    if (xp003 > 0)
                    {
                        InsertXpTransaction(conn, trans, studentId, "XP003", xp003);
                    }
                }
                else if (quizType == "Unit")
                {
                    // XP004: only if passed AND first attempt
                    if (pct >= passMarkUnit && attemptNo == 1)
                    {
                        int xp004 = GetXpValue(conn, trans, "XP004");
                        if (xp004 > 0)
                        {
                            InsertXpTransaction(conn, trans, studentId, "XP004", xp004);
                        }
                    }
                }
                else if (quizType == "Level")
                {
                    // XP006: if passed level assessment
                    if (pct >= passMarkLevel)
                    {
                        int xp006 = GetXpValue(conn, trans, "XP006");
                        if (xp006 > 0)
                        {
                            InsertXpTransaction(conn, trans, studentId, "XP006", xp006);
                        }
                    }
                }

                // XP005: bonus for scoring 80% or above in any quiz
                if (pct >= 80)
                {
                    int xp005 = GetXpValue(conn, trans, "XP005");
                    if (xp005 > 0)
                    {
                        InsertXpTransaction(conn, trans, studentId, "XP005", xp005);
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Quiz XP error: " + ex.Message);
            }
        }

        private int GetXpValue(SqlConnection conn, SqlTransaction trans, string xpActionId)
        {
            using (SqlCommand command = new SqlCommand("SELECT xpValue FROM XPAction WHERE xpActionId=@id", conn, trans))
            {
                command.Parameters.AddWithValue("@id", xpActionId);
                object result = command.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                {
                    return Convert.ToInt32(result);
                }
            }
            return 0;
        }

        private int GetConfigInt(SqlConnection conn, SqlTransaction trans, string configKey, int defaultValue)
        {
            using (SqlCommand command = new SqlCommand("SELECT configValue FROM ConfigurationSetting WHERE configKey=@k", conn, trans))
            {
                command.Parameters.AddWithValue("@k", configKey);
                object result = command.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                {
                    return Convert.ToInt32(result);
                }
            }
            return defaultValue;
        }

        private void InsertXpTransaction(SqlConnection conn, SqlTransaction trans, string studentId, string xpActionId, int xpAmount)
        {
            // Generate next ID (XPT prefix to match database)
            string xtId = "XPT001";
            using (SqlCommand command = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING(xpTransactionId,4,LEN(xpTransactionId)-3) AS INT)),0) FROM XPTransaction WHERE xpTransactionId LIKE 'XPT[0-9]%'", conn, trans))
            {
                xtId = "XPT" + (Convert.ToInt32(command.ExecuteScalar()) + 1).ToString("D3");
            }

            // Insert transaction
            using (SqlCommand command = new SqlCommand("INSERT INTO XPTransaction(xpTransactionId,studentId,xpActionId,xpAmount,dateEarned) VALUES(@id,@s,@a,@xp,@dt)", conn, trans))
            {
                command.Parameters.AddWithValue("@id", xtId);
                command.Parameters.AddWithValue("@s", studentId);
                command.Parameters.AddWithValue("@a", xpActionId);
                command.Parameters.AddWithValue("@xp", xpAmount);
                command.Parameters.AddWithValue("@dt", DateTime.Today);
                command.ExecuteNonQuery();
            }

            // Update student total
            using (SqlCommand command = new SqlCommand("UPDATE Student SET XP=ISNULL(XP,0)+@xp WHERE studentId=@s", conn, trans))
            {
                command.Parameters.AddWithValue("@xp", xpAmount);
                command.Parameters.AddWithValue("@s", studentId);
                command.ExecuteNonQuery();
            }
        }

        // Badge checks after quiz completion
        private void CheckQuizBadges(string studentId, string quizType, decimal percentage, string quizId)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // B003 Quiz Starter — first quiz attempt ever
                    int quizCount = 0;
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM QuizResult WHERE studentId=@s", conn))
                    {
                        cmd.Parameters.AddWithValue("@s", studentId);
                        quizCount = (int)cmd.ExecuteScalar();
                    }
                    if (quizCount == 1)
                    {
                        AwardBadgeIfNotEarned(conn, studentId, "B003");
                    }

                    // B004 High Scorer — score >= 80%
                    if (percentage >= 80)
                    {
                        AwardBadgeIfNotEarned(conn, studentId, "B004");
                    }

                    // B005 Unit Master — after passing a Unit quiz, check if all lessons + lab done for that unit
                    if (quizType == "Unit" && percentage >= 50)
                    {
                        CheckUnitMasterBadge(conn, studentId, quizId);
                    }

                    // B006/B007/B008 Level Champions — after passing Level assessment
                    if (quizType == "Level" && percentage >= 70)
                    {
                        CheckLevelChampionBadge(conn, studentId, quizId);
                    }

                    // B010 Consistent Learner — 3+ distinct days
                    int distinctDays = 0;
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(DISTINCT CAST(dateEarned AS DATE)) FROM XPTransaction WHERE studentId=@s", conn))
                    {
                        cmd.Parameters.AddWithValue("@s", studentId);
                        distinctDays = (int)cmd.ExecuteScalar();
                    }
                    if (distinctDays >= 3)
                    {
                        AwardBadgeIfNotEarned(conn, studentId, "B010");
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Badge error: " + ex.Message);
            }
        }

        private void CheckUnitMasterBadge(SqlConnection conn, string studentId, string quizId)
        {
            // Get unitId from the quiz
            string unitId = null;
            using (SqlCommand cmd = new SqlCommand("SELECT unitId FROM Quiz WHERE quizId=@q", conn))
            {
                cmd.Parameters.AddWithValue("@q", quizId);
                object r = cmd.ExecuteScalar();
                if (r != null && r != DBNull.Value) unitId = r.ToString();
            }
            if (string.IsNullOrEmpty(unitId)) return;

            // Count total lessons in this unit
            int totalLessons = 0;
            using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Lesson ls JOIN Subtopic st ON st.subtopicId=ls.subtopicId WHERE st.unitId=@u", conn))
            {
                cmd.Parameters.AddWithValue("@u", unitId);
                totalLessons = (int)cmd.ExecuteScalar();
            }

            // Count completed lessons
            int completedLessons = 0;
            using (SqlCommand cmd = new SqlCommand(@"SELECT COUNT(*) FROM LessonProgress lp 
                JOIN Lesson ls ON ls.lessonId=lp.lessonId 
                JOIN Subtopic st ON st.subtopicId=ls.subtopicId 
                WHERE st.unitId=@u AND lp.studentId=@s AND lp.isCompleted=1", conn))
            {
                cmd.Parameters.AddWithValue("@u", unitId);
                cmd.Parameters.AddWithValue("@s", studentId);
                completedLessons = (int)cmd.ExecuteScalar();
            }

            if (completedLessons < totalLessons) return;

            // Check lab completion (if unit has a lab)
            int labCount = 0;
            using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM VirtualLab WHERE unitId=@u", conn))
            {
                cmd.Parameters.AddWithValue("@u", unitId);
                labCount = (int)cmd.ExecuteScalar();
            }
            if (labCount > 0)
            {
                int labDone = 0;
                using (SqlCommand cmd = new SqlCommand(@"SELECT COUNT(*) FROM LabProgress lp 
                    JOIN VirtualLab vl ON vl.labId=lp.labId 
                    WHERE vl.unitId=@u AND lp.studentId=@s AND lp.isCompleted=1", conn))
                {
                    cmd.Parameters.AddWithValue("@u", unitId);
                    cmd.Parameters.AddWithValue("@s", studentId);
                    labDone = (int)cmd.ExecuteScalar();
                }
                if (labDone < labCount) return;
            }

            // All conditions met
            AwardBadgeIfNotEarned(conn, studentId, "B005");
        }

        private void CheckLevelChampionBadge(SqlConnection conn, string studentId, string quizId)
        {
            // Get levelId from the quiz
            string levelId = null;
            using (SqlCommand cmd = new SqlCommand("SELECT levelId FROM Quiz WHERE quizId=@q", conn))
            {
                cmd.Parameters.AddWithValue("@q", quizId);
                object r = cmd.ExecuteScalar();
                if (r != null && r != DBNull.Value) levelId = r.ToString();
            }
            if (string.IsNullOrEmpty(levelId)) return;

            // Check all unit quizzes in this level are passed
            int totalUnitQuizzes = 0;
            using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Quiz WHERE levelId=@l AND quizType='Unit'", conn))
            {
                cmd.Parameters.AddWithValue("@l", levelId);
                // Actually unit quizzes use unitId not levelId, so check units in this level
            }

            // Better approach: check all units in this level have at least 1 passed Unit quiz result
            int unitsInLevel = 0;
            using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Unit WHERE levelId=@l", conn))
            {
                cmd.Parameters.AddWithValue("@l", levelId);
                unitsInLevel = (int)cmd.ExecuteScalar();
            }
            if (unitsInLevel == 0) return;

            int unitsPassed = 0;
            using (SqlCommand cmd = new SqlCommand(@"SELECT COUNT(DISTINCT q.unitId) FROM QuizResult qr 
                JOIN Quiz q ON q.quizId=qr.quizId 
                JOIN Unit u ON u.unitId=q.unitId 
                WHERE u.levelId=@l AND q.quizType='Unit' AND qr.studentId=@s AND qr.resultStatus='Passed'", conn))
            {
                cmd.Parameters.AddWithValue("@l", levelId);
                cmd.Parameters.AddWithValue("@s", studentId);
                unitsPassed = (int)cmd.ExecuteScalar();
            }

            if (unitsPassed < unitsInLevel) return;

            // Award the correct champion badge based on level
            switch (levelId)
            {
                case "LV001": AwardBadgeIfNotEarned(conn, studentId, "B006"); break;
                case "LV002": AwardBadgeIfNotEarned(conn, studentId, "B007"); break;
                case "LV003": AwardBadgeIfNotEarned(conn, studentId, "B008"); break;
            }
        }

        private void AwardBadgeIfNotEarned(SqlConnection conn, string studentId, string badgeId)
        {
            using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM StudentBadge WHERE studentId=@s AND badgeId=@b", conn))
            {
                cmd.Parameters.AddWithValue("@s", studentId);
                cmd.Parameters.AddWithValue("@b", badgeId);
                if ((int)cmd.ExecuteScalar() > 0) return;
            }

            string sbId = "SB001";
            using (SqlCommand cmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING(studentBadgeId,3,LEN(studentBadgeId)-2) AS INT)),0) FROM StudentBadge WHERE studentBadgeId LIKE 'SB[0-9]%'", conn))
            {
                sbId = "SB" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3");
            }

            using (SqlCommand cmd = new SqlCommand("INSERT INTO StudentBadge(studentBadgeId,studentId,badgeId,earnedAt) VALUES(@id,@s,@b,@dt)", conn))
            {
                cmd.Parameters.AddWithValue("@id", sbId);
                cmd.Parameters.AddWithValue("@s", studentId);
                cmd.Parameters.AddWithValue("@b", badgeId);
                cmd.Parameters.AddWithValue("@dt", DateTime.Now);
                cmd.ExecuteNonQuery();
            }
        }

        // ── Helpers ───────────────────────────────────────────────────
        private string NormalizeQuestionType(string qt)
        {
            if (string.IsNullOrWhiteSpace(qt))
            {
                return "MCQ";
            }
            string raw = qt.Trim().ToLower().Replace(" ", "").Replace("/", "").Replace("&", "").Replace("-", "");
            if (raw.Contains("truefalse") || raw == "tf")
            {
                return "TF";
            }
            if (raw.Contains("multi"))
            {
                return "MULTISELECT";
            }
            if (raw.Contains("drag") || raw.Contains("drop"))
            {
                return "DRAGDROP";
            }
            return "MCQ";
        }

        private string GetTypeLabel(string t)
        {
            switch (t)
            {
                case "Practice":
                    return T("Practice Quiz", "Kuiz Latihan");
                case "Unit":
                    return T("Unit Quiz", "Kuiz Unit");
                case "Level":
                    return T("Level Assessment", "Penilaian Tahap");
                default:
                    return T("Quiz", "Kuiz");
            }
        }

        private string GetInstructions(string t)
        {
            switch (t)
            {
                case "Practice":
                    return T("This quiz helps you practise and strengthen your Science understanding.", "Kuiz ini membantu anda berlatih dan mengukuhkan kefahaman Sains.");
                case "Unit":
                    return T("Complete this quiz to check your understanding of this unit.", "Selesaikan kuiz ini untuk menyemak kefahaman anda tentang unit ini.");
                case "Level":
                    return T("This assessment checks your understanding for the whole level.", "Penilaian ini menyemak kefahaman anda untuk keseluruhan tahap.");
                default:
                    return T("Answer all questions.", "Jawab semua soalan.");
            }
        }

        private void ShowError(string title, string desc)
        {
            pnlError.Visible = true;
            pnlQuiz.Visible = false;
            litErrorTitle.Text = HttpUtility.HtmlEncode(title);
            litErrorDesc.Text = HttpUtility.HtmlEncode(desc);
            litErrorBtn.Text = T("Back", "Kembali");
        }

        private static string S(DataRow r, string c)
        {
            if (r[c] != null && r[c] != DBNull.Value)
            {
                return r[c].ToString();
            }
            return "";
        }

        private static int ExtractNum(string id)
        {
            string n = new string(id.Where(char.IsDigit).ToArray());
            int v;
            if (int.TryParse(n, out v))
            {
                return v;
            }
            return 0;
        }

        // Badge checks after quiz submission
        private void CheckQuizBadges(SqlConnection conn, SqlTransaction trans, string studentId, string quizType, decimal pct, string quizId)
        {
            try
            {
                // B003: Quiz Starter — first quiz attempt
                int quizCount = 0;
                using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM QuizResult WHERE studentId=@s", conn, trans))
                {
                    cmd.Parameters.AddWithValue("@s", studentId);
                    quizCount = (int)cmd.ExecuteScalar();
                }
                if (quizCount == 1)
                {
                    AwardBadgeIfNotEarned(conn, trans, studentId, "B003");
                }

                // B004: High Scorer — score 80% or above
                if (pct >= 80)
                {
                    AwardBadgeIfNotEarned(conn, trans, studentId, "B004");
                }

                // B005: Unit Master — passed unit quiz + all lessons in that unit completed
                if (quizType == "Unit" && pct >= GetConfigInt(conn, trans, "Passing Mark Percentage for Unit", 50))
                {
                    CheckUnitMasterBadge(conn, trans, studentId, quizId);
                }

                // B006/B007/B008: Level Champions — passed level assessment
                if (quizType == "Level" && pct >= GetConfigInt(conn, trans, "Passing Mark for Level", 70))
                {
                    CheckLevelChampionBadge(conn, trans, studentId, quizId);
                }

                // B010: Consistent Learner
                int distinctDays = 0;
                using (SqlCommand cmd = new SqlCommand("SELECT COUNT(DISTINCT CAST(dateEarned AS DATE)) FROM XPTransaction WHERE studentId=@s", conn, trans))
                {
                    cmd.Parameters.AddWithValue("@s", studentId);
                    distinctDays = (int)cmd.ExecuteScalar();
                }
                if (distinctDays >= 3)
                {
                    AwardBadgeIfNotEarned(conn, trans, studentId, "B010");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Quiz badge error: " + ex.Message);
            }
        }

        private void CheckUnitMasterBadge(SqlConnection conn, SqlTransaction trans, string studentId, string quizId)
        {
            // Get unitId for this quiz
            string unitId = null;
            using (SqlCommand cmd = new SqlCommand("SELECT unitId FROM Quiz WHERE quizId=@q", conn, trans))
            {
                cmd.Parameters.AddWithValue("@q", quizId);
                object r = cmd.ExecuteScalar();
                if (r != null && r != DBNull.Value) unitId = r.ToString();
            }
            if (string.IsNullOrEmpty(unitId)) return;

            // Count total lessons in this unit
            int totalLessons = 0;
            using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Lesson ls JOIN Subtopic st ON st.subtopicId=ls.subtopicId WHERE st.unitId=@u", conn, trans))
            {
                cmd.Parameters.AddWithValue("@u", unitId);
                totalLessons = (int)cmd.ExecuteScalar();
            }

            // Count completed lessons by this student in this unit
            int completedLessons = 0;
            using (SqlCommand cmd = new SqlCommand(@"SELECT COUNT(*) FROM LessonProgress lp 
                JOIN Lesson ls ON ls.lessonId=lp.lessonId 
                JOIN Subtopic st ON st.subtopicId=ls.subtopicId 
                WHERE st.unitId=@u AND lp.studentId=@s AND lp.isCompleted=1", conn, trans))
            {
                cmd.Parameters.AddWithValue("@u", unitId);
                cmd.Parameters.AddWithValue("@s", studentId);
                completedLessons = (int)cmd.ExecuteScalar();
            }

            // All lessons must be done
            if (completedLessons < totalLessons) return;

            // Check if lab exists for this unit and is completed
            int labCount = 0;
            using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM VirtualLab WHERE unitId=@u", conn, trans))
            {
                cmd.Parameters.AddWithValue("@u", unitId);
                labCount = (int)cmd.ExecuteScalar();
            }
            if (labCount > 0)
            {
                int labDone = 0;
                using (SqlCommand cmd = new SqlCommand(@"SELECT COUNT(*) FROM LabProgress lbp 
                    JOIN VirtualLab vl ON vl.labId=lbp.labId 
                    WHERE vl.unitId=@u AND lbp.studentId=@s AND lbp.isCompleted=1", conn, trans))
                {
                    cmd.Parameters.AddWithValue("@u", unitId);
                    cmd.Parameters.AddWithValue("@s", studentId);
                    labDone = (int)cmd.ExecuteScalar();
                }
                if (labDone < labCount) return;
            }

            // All conditions met — award Unit Master
            AwardBadgeIfNotEarned(conn, trans, studentId, "B005");
        }

        private void CheckLevelChampionBadge(SqlConnection conn, SqlTransaction trans, string studentId, string quizId)
        {
            // Get levelId from the quiz
            string levelId = null;
            using (SqlCommand cmd = new SqlCommand("SELECT levelId FROM Quiz WHERE quizId=@q", conn, trans))
            {
                cmd.Parameters.AddWithValue("@q", quizId);
                object r = cmd.ExecuteScalar();
                if (r != null && r != DBNull.Value) levelId = r.ToString();
            }
            if (string.IsNullOrEmpty(levelId)) return;

            // Check all unit quizzes in this level are passed
            int totalUnitQuizzes = 0;
            using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Quiz WHERE unitId IN (SELECT unitId FROM Unit WHERE levelId=@l) AND quizType='Unit'", conn, trans))
            {
                cmd.Parameters.AddWithValue("@l", levelId);
                totalUnitQuizzes = (int)cmd.ExecuteScalar();
            }

            int passedUnitQuizzes = 0;
            using (SqlCommand cmd = new SqlCommand(@"SELECT COUNT(DISTINCT q.quizId) FROM QuizResult qr 
                JOIN Quiz q ON q.quizId=qr.quizId 
                WHERE qr.studentId=@s AND q.quizType='Unit' AND qr.resultStatus='Passed'
                AND q.unitId IN (SELECT unitId FROM Unit WHERE levelId=@l)", conn, trans))
            {
                cmd.Parameters.AddWithValue("@s", studentId);
                cmd.Parameters.AddWithValue("@l", levelId);
                passedUnitQuizzes = (int)cmd.ExecuteScalar();
            }

            if (passedUnitQuizzes < totalUnitQuizzes) return;

            // Award the corresponding level badge
            string badgeId = null;
            switch (levelId)
            {
                case "LV001": badgeId = "B006"; break;
                case "LV002": badgeId = "B007"; break;
                case "LV003": badgeId = "B008"; break;
            }
            if (!string.IsNullOrEmpty(badgeId))
            {
                AwardBadgeIfNotEarned(conn, trans, studentId, badgeId);

                // Auto-request certificate for level completion
                RequestCertificate(conn, trans, studentId, levelId);
            }
        }

        // Auto-request certificate when level is completed
        private void RequestCertificate(SqlConnection conn, SqlTransaction trans, string studentId, string levelId)
        {
            try
            {
                // Check if certificate already exists for this student + level
                using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Certificate WHERE studentId=@s AND levelId=@l", conn, trans))
                {
                    cmd.Parameters.AddWithValue("@s", studentId);
                    cmd.Parameters.AddWithValue("@l", levelId);
                    if ((int)cmd.ExecuteScalar() > 0) return; // already has certificate
                }

                // Get level name for certificate title
                string levelNameEN = "Level";
                string levelNameBM = "Tahap";
                using (SqlCommand cmd = new SqlCommand("SELECT levelNameEN, levelNameBM FROM Level WHERE levelId=@l", conn, trans))
                {
                    cmd.Parameters.AddWithValue("@l", levelId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            levelNameEN = reader["levelNameEN"] != DBNull.Value ? reader["levelNameEN"].ToString() : "Level";
                            levelNameBM = reader["levelNameBM"] != DBNull.Value ? reader["levelNameBM"].ToString() : "Tahap";
                        }
                    }
                }

                // Generate next certificate ID
                string certId = "CERT001";
                using (SqlCommand cmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING(certificateId,5,LEN(certificateId)-4) AS INT)),0) FROM Certificate WHERE certificateId LIKE 'CERT[0-9]%'", conn, trans))
                {
                    certId = "CERT" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3");
                }

                // Insert certificate
                string titleEN = levelNameEN + " Completion Certificate";
                string titleBM = "Sijil Penyiapan " + levelNameBM;
                string descEN = "Awarded for completing all requirements of the " + levelNameEN + " level.";
                string descBM = "Dianugerahkan kerana menyelesaikan semua keperluan tahap " + levelNameBM + ".";

                using (SqlCommand cmd = new SqlCommand(@"INSERT INTO Certificate(certificateId,studentId,levelId,certificateTitleEN,certificateTitleBM,
                    certificateDescriptionEN,certificateDescriptionBM,issuedDate,certificateUrl,status) 
                    VALUES(@id,@s,@l,@tEN,@tBM,@dEN,@dBM,@dt,NULL,'Pending')", conn, trans))
                {
                    cmd.Parameters.AddWithValue("@id", certId);
                    cmd.Parameters.AddWithValue("@s", studentId);
                    cmd.Parameters.AddWithValue("@l", levelId);
                    cmd.Parameters.AddWithValue("@tEN", titleEN);
                    cmd.Parameters.AddWithValue("@tBM", titleBM);
                    cmd.Parameters.AddWithValue("@dEN", descEN);
                    cmd.Parameters.AddWithValue("@dBM", descBM);
                    cmd.Parameters.AddWithValue("@dt", DateTime.Now);
                    cmd.ExecuteNonQuery();
                }

                // Send notification to student about certificate
                string userId = "";
                using (SqlCommand cmd = new SqlCommand("SELECT userId FROM Student WHERE studentId=@s", conn, trans))
                {
                    cmd.Parameters.AddWithValue("@s", studentId);
                    object r = cmd.ExecuteScalar();
                    if (r != null && r != DBNull.Value) userId = r.ToString();
                }
                if (!string.IsNullOrEmpty(userId))
                {
                    string nId = "NTF001";
                    using (SqlCommand cmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING(notificationId,4,LEN(notificationId)-3) AS INT)),0) FROM Notification WHERE notificationId LIKE 'NTF[0-9]%'", conn, trans))
                    {
                        nId = "NTF" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3");
                    }
                    using (SqlCommand cmd = new SqlCommand("INSERT INTO Notification(notificationId,toUserId,titleEN,titleBM,messageEN,messageBM,isRead,createdAt) VALUES(@id,@to,@tEN,@tBM,@mEN,@mBM,0,@dt)", conn, trans))
                    {
                        cmd.Parameters.AddWithValue("@id", nId);
                        cmd.Parameters.AddWithValue("@to", userId);
                        cmd.Parameters.AddWithValue("@tEN", "Certificate Pending");
                        cmd.Parameters.AddWithValue("@tBM", "Sijil Dalam Proses");
                        cmd.Parameters.AddWithValue("@mEN", "You completed the " + levelNameEN + " level. Your certificate is being prepared.");
                        cmd.Parameters.AddWithValue("@mBM", "Anda telah melengkapkan tahap " + levelNameBM + ". Sijil anda sedang disediakan.");
                        cmd.Parameters.AddWithValue("@dt", DateTime.Now);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Certificate error: " + ex.Message);
            }
        }

        private void AwardBadgeIfNotEarned(SqlConnection conn, SqlTransaction trans, string studentId, string badgeId)
        {
            using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM StudentBadge WHERE studentId=@s AND badgeId=@b", conn, trans))
            {
                cmd.Parameters.AddWithValue("@s", studentId);
                cmd.Parameters.AddWithValue("@b", badgeId);
                if ((int)cmd.ExecuteScalar() > 0) return;
            }

            string sbId = "SB001";
            using (SqlCommand cmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING(studentBadgeId,3,LEN(studentBadgeId)-2) AS INT)),0) FROM StudentBadge WHERE studentBadgeId LIKE 'SB[0-9]%'", conn, trans))
            {
                sbId = "SB" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3");
            }

            using (SqlCommand cmd = new SqlCommand("INSERT INTO StudentBadge(studentBadgeId,studentId,badgeId,earnedAt) VALUES(@id,@s,@b,@dt)", conn, trans))
            {
                cmd.Parameters.AddWithValue("@id", sbId);
                cmd.Parameters.AddWithValue("@s", studentId);
                cmd.Parameters.AddWithValue("@b", badgeId);
                cmd.Parameters.AddWithValue("@dt", DateTime.Now);
                cmd.ExecuteNonQuery();
            }
        }

        private void SendNotification(SqlConnection conn, string toUserId, string titleEN, string titleBM, string msgEN, string msgBM)
        {
            try
            {
                string nId = "NTF001";
                using (SqlCommand cmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING(notificationId,4,LEN(notificationId)-3) AS INT)),0) FROM Notification WHERE notificationId LIKE 'NTF[0-9]%'", conn))
                {
                    nId = "NTF" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3");
                }
                using (SqlCommand cmd = new SqlCommand("INSERT INTO Notification(notificationId,toUserId,titleEN,titleBM,messageEN,messageBM,isRead,createdAt) VALUES(@id,@to,@tEN,@tBM,@mEN,@mBM,0,@dt)", conn))
                {
                    cmd.Parameters.AddWithValue("@id", nId);
                    cmd.Parameters.AddWithValue("@to", toUserId);
                    cmd.Parameters.AddWithValue("@tEN", titleEN);
                    cmd.Parameters.AddWithValue("@tBM", titleBM);
                    cmd.Parameters.AddWithValue("@mEN", msgEN);
                    cmd.Parameters.AddWithValue("@mBM", msgBM);
                    cmd.Parameters.AddWithValue("@dt", DateTime.Now);
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Notification error: " + ex.Message);
            }
        }

        [Serializable]
        private class AnsDetail { public string QuestionId; public string Selected; public bool IsCorrect; public decimal Marks; }
    }
}
