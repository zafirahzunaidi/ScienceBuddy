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
        public string CorrectAnswer { get; set; } = "";   // MCQ: "A"-"D" | True/False: "A"/"B" | Multiselect: "A,B" | D&D: built at submit
        public string CorrectExplanationEN { get; set; } = "";
        public string CorrectExplanationBM { get; set; } = "";
        public string WrongExplanationEN { get; set; } = "";
        public string WrongExplanationBM { get; set; } = "";
        public bool IsSaved { get; set; } = false;
        // Extended fields populated from JS store
        public string QuestionImageUrl { get; set; } = "";  // filename only, not full path/data-URL
        public string MsChk { get; set; } = "";             // Multiselect checked letters "A,C"
        public string MsAEN { get; set; } = ""; public string MsABM { get; set; } = "";
        public string MsBEN { get; set; } = ""; public string MsBBM { get; set; } = "";
        public string MsCEN { get; set; } = ""; public string MsCBM { get; set; } = "";
        public string MsDEN { get; set; } = ""; public string MsDBM { get; set; } = "";
        public string[] FibEN { get; set; } = new string[4]; // D&D word bank EN
        public string[] FibBM { get; set; } = new string[4]; // D&D word bank BM
        public string[] FibMapEN { get; set; } = new string[0]; // D&D mapping order EN (words in blank order)
        public string[] FibMapBM { get; set; } = new string[0]; // D&D mapping order BM (words in blank order)
        // D&D mapping indices serialised as JSON strings for round-tripping through the hidden field
        public string FibIdxENJson { get; set; } = "{}";
        public string FibIdxBMJson { get; set; } = "{}";
    }

    public partial class createUnitLevelQuiz : Page
    {
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

        protected string CurrentLanguage
        { get { string l = Session["preferredLanguage"] as string; return string.IsNullOrEmpty(l) ? "EN" : l; } }
        protected string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }

        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

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

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"]?.ToString() != "Teacher")
            { Response.Redirect("~/Login.aspx", false); Context.ApplicationInstance.CompleteRequest(); return; }

            var master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                if (!Authorize()) { ShowError(T("Access denied.", "Akses ditolak.")); return; }
                if (!InitContext()) return;
                if (Questions.Count == 0) { var qs = new List<QuestionData> { new QuestionData() }; Questions = qs; }
                LoadCurrentQuestion();
                // Localize dropdown display text
                ddlQDiff.Items.FindByValue("Easy").Text = T("Easy", "Mudah");
                ddlQDiff.Items.FindByValue("Medium").Text = T("Medium", "Sederhana");
                ddlQDiff.Items.FindByValue("Hard").Text = T("Hard", "Sukar");
                ddlQType.Items.FindByValue("MCQ").Text = T("MCQ", "Aneka Pilihan");
                ddlQType.Items.FindByValue("True/False").Text = T("True / False", "Betul / Salah");
                ddlQType.Items.FindByValue("Multiselect").Text = T("Multiselect", "Pelbagai Pilihan");
                ddlQType.Items.FindByValue("Drag & Drop").Text = T("Drag & Drop", "Seret & Letak");
            }
        }

        private bool Authorize()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [status] FROM dbo.[Teacher] WHERE [userId]=@u", conn))
                { cmd.Parameters.AddWithValue("@u", Session["userId"].ToString()); var v = cmd.ExecuteScalar(); return v != null && v.ToString().Equals("Certified", StringComparison.OrdinalIgnoreCase); }
            }
        }

        private bool InitContext()
        {
            string quizIdParam = Request.QueryString["quizId"];

            // NEW FLOW: quizId passed directly from Manage Quizzes
            if (!string.IsNullOrEmpty(quizIdParam))
            {
                return InitFromQuizId(quizIdParam);
            }

            // LEGACY FLOW: mode + subtopicId + unitId/level
            string mode = Request.QueryString["mode"];
            string subtopicId = Request.QueryString["subtopicId"];
            if (string.IsNullOrEmpty(mode) || string.IsNullOrEmpty(subtopicId))
            { ShowError(T("Invalid parameters.", "Parameter tidak sah.")); return false; }

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                string subName = "";
                using (var cmd = new SqlCommand("SELECT [subtopicTitleEN] FROM dbo.[Subtopic] WHERE [subtopicId]=@s", conn))
                { cmd.Parameters.AddWithValue("@s", subtopicId); var v = cmd.ExecuteScalar(); subName = v?.ToString() ?? ""; }
                litSubtopic.Text = HttpUtility.HtmlEncode(subName);
                litPropSubtopic.Text = HttpUtility.HtmlEncode(subName);
                pnlSubtopicSelect.Visible = false;

                if (mode == "unit")
                {
                    string unitId = Request.QueryString["unitId"];
                    if (string.IsNullOrEmpty(unitId)) { ShowError(T("Unit not specified.", "Unit tidak dinyatakan.")); return false; }
                    string unitName = "";
                    using (var cmd = new SqlCommand("SELECT [unitNameEN] FROM dbo.[Unit] WHERE [unitId]=@u", conn))
                    { cmd.Parameters.AddWithValue("@u", unitId); var v = cmd.ExecuteScalar(); unitName = v?.ToString() ?? ""; }
                    litMode.Text = T("Unit Quiz", "Kuiz Unit");
                    litScope.Text = HttpUtility.HtmlEncode(unitName);
                    litScopeLabel.Text = T("Unit", "Unit");
                }
                else if (mode == "level")
                {
                    string levelId = Request.QueryString["level"];
                    if (string.IsNullOrEmpty(levelId)) { ShowError(T("Level not specified.", "Tahap tidak dinyatakan.")); return false; }
                    string levelName = "";
                    using (var cmd = new SqlCommand("SELECT [levelNameEN] FROM dbo.[Level] WHERE [levelId]=@l", conn))
                    { cmd.Parameters.AddWithValue("@l", levelId); var v = cmd.ExecuteScalar(); levelName = v?.ToString() ?? ""; }
                    litMode.Text = T("Level Quiz", "Kuiz Tahap");
                    litScope.Text = HttpUtility.HtmlEncode(levelName);
                    litScopeLabel.Text = T("Level", "Tahap");
                }
                else { ShowError(T("Invalid mode.", "Mod tidak sah.")); return false; }

                string quizId = GetQuizId(conn, mode);
                if (string.IsNullOrEmpty(quizId))
                { ShowError(T("No matching quiz found for the selected criteria.", "Tiada kuiz yang sepadan ditemui untuk kriteria yang dipilih.")); return false; }

                ViewState["QuizId"] = quizId;
                ViewState["SubtopicId"] = subtopicId;
                // Store the scope name as a fallback quiz title for the notification message
                ViewState["QuizTitleEN"] = litScope.Text;
                ViewState["QuizTitleBM"] = litScope.Text;
            }

            pnlBuilder.Visible = true;
            btnAddQuestion.Text = T("+ Add Question", "+ Tambah Soalan");
            btnSubmitQuiz.Text = T("Submit Quiz", "Hantar Kuiz");
            return true;
        }

        private bool InitFromQuizId(string quizId)
        {
            string subtopicId = (Request.QueryString["subtopicId"] ?? "").Trim();

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                string quizType = "", unitId = "", levelId = "", titleEN = "", titleBM = "";
                using (var cmd = new SqlCommand("SELECT [quizType],[unitId],[levelId],[quizTitleEN],[quizTitleBM] FROM dbo.[Quiz] WHERE [quizId]=@qid", conn))
                {
                    cmd.Parameters.AddWithValue("@qid", quizId);
                    using (var r = cmd.ExecuteReader())
                    {
                        if (!r.Read()) { ShowError(T("Quiz not found.", "Kuiz tidak ditemui.")); return false; }
                        quizType = r["quizType"]?.ToString() ?? "";
                        unitId = r["unitId"]?.ToString() ?? "";
                        levelId = r["levelId"]?.ToString() ?? "";
                        titleEN = r["quizTitleEN"]?.ToString() ?? "";
                        titleBM = r["quizTitleBM"]?.ToString() ?? "";
                    }
                }

                if (quizType != "Unit" && quizType != "Level")
                { ShowError(T("Invalid quiz type. Only Unit or Level quizzes are supported.", "Jenis kuiz tidak sah. Hanya kuiz Unit atau Tahap disokong.")); return false; }

                // Validate subtopicId
                if (string.IsNullOrEmpty(subtopicId))
                { ShowError(T("Subtopic not specified. Please select a subtopic from Manage Quizzes.", "Subtopik tidak dinyatakan. Sila pilih subtopik dari Urus Kuiz.")); return false; }

                // Verify subtopic exists and belongs to the correct unit
                string subName = "";
                using (var cmd = new SqlCommand("SELECT [subtopicTitleEN],[unitId] FROM dbo.[Subtopic] WHERE [subtopicId]=@s", conn))
                {
                    cmd.Parameters.AddWithValue("@s", subtopicId);
                    using (var r = cmd.ExecuteReader())
                    {
                        if (!r.Read()) { ShowError(T("Subtopic not found.", "Subtopik tidak ditemui.")); return false; }
                        subName = r["subtopicTitleEN"]?.ToString() ?? "";
                        string subUnitId = r["unitId"]?.ToString() ?? "";
                        // For Unit quizzes, verify subtopic belongs to the quiz's unit
                        if (quizType == "Unit" && !string.IsNullOrEmpty(unitId) && subUnitId != unitId)
                        { ShowError(T("Selected subtopic does not belong to this quiz's unit.", "Subtopik yang dipilih bukan milik unit kuiz ini.")); return false; }
                    }
                }

                // Set display info
                if (quizType == "Unit")
                {
                    litMode.Text = T("Unit Quiz", "Kuiz Unit");
                    string unitName = "";
                    using (var cmd = new SqlCommand("SELECT [unitNameEN] FROM dbo.[Unit] WHERE [unitId]=@u", conn))
                    { cmd.Parameters.AddWithValue("@u", unitId); var v = cmd.ExecuteScalar(); unitName = v?.ToString() ?? "-"; }
                    litScope.Text = HttpUtility.HtmlEncode(unitName);
                    litScopeLabel.Text = T("Unit", "Unit");
                }
                else
                {
                    litMode.Text = T("Level Quiz", "Kuiz Tahap");
                    string levelName = "";
                    using (var cmd = new SqlCommand("SELECT [levelNameEN] FROM dbo.[Level] WHERE [levelId]=@l", conn))
                    { cmd.Parameters.AddWithValue("@l", levelId); var v = cmd.ExecuteScalar(); levelName = v?.ToString() ?? "-"; }
                    litScope.Text = HttpUtility.HtmlEncode(levelName);
                    litScopeLabel.Text = T("Level", "Tahap");
                }

                // Display subtopic as read-only
                litSubtopic.Text = HttpUtility.HtmlEncode(subName);
                litPropSubtopic.Text = HttpUtility.HtmlEncode(subName);
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
            using (cmd) { var v = cmd.ExecuteScalar(); return v?.ToString(); }
        }

        // -- UI Loading -----------------------------------------------
        private void LoadCurrentQuestion()
        {
            var qs = Questions;
            if (CurrentIndex >= qs.Count) CurrentIndex = qs.Count - 1;
            if (CurrentIndex < 0) CurrentIndex = 0;
            var q = qs[CurrentIndex];

            litQNum.Text = (CurrentIndex + 1).ToString();
            ddlQType.SelectedValue = q.QuestionType ?? "MCQ";
            ddlQDiff.SelectedValue = q.Difficulty ?? "Medium";

            bool isEN = CurrentTab == "EN";
            btnTabEN.CssClass = isEN ? "tc-question-builder-tab active" : "tc-question-builder-tab";
            btnTabBM.CssClass = isEN ? "tc-question-builder-tab" : "tc-question-builder-tab active";
            litQTextLabel.Text = isEN ? T("Question (English)", "Soalan (Bahasa Inggeris)") : T("Question (Bahasa Melayu)", "Soalan (Bahasa Melayu)");
            litOptionsLabel.Text = isEN ? T("Options (English)", "Pilihan (Bahasa Inggeris)") : T("Options (Bahasa Melayu)", "Pilihan (Bahasa Melayu)");
            litCorrectExpLabel.Text = isEN ? T("Correct Explanation (EN)", "Penjelasan Betul (EN)") : T("Correct Explanation (BM)", "Penjelasan Betul (BM)");
            litWrongExpLabel.Text = isEN ? T("Wrong Explanation (EN)", "Penjelasan Salah (EN)") : T("Wrong Explanation (BM)", "Penjelasan Salah (BM)");

            txtQuestionText.Text = isEN ? q.QuestionTextEN : q.QuestionTextBM;
            txtOptA.Text = isEN ? q.OptionA_EN : q.OptionA_BM;
            txtOptB.Text = isEN ? q.OptionB_EN : q.OptionB_BM;
            txtOptC.Text = isEN ? q.OptionC_EN : q.OptionC_BM;
            txtOptD.Text = isEN ? q.OptionD_EN : q.OptionD_BM;
            txtCorrectExp.Text = isEN ? q.CorrectExplanationEN : q.CorrectExplanationBM;
            txtWrongExp.Text = isEN ? q.WrongExplanationEN : q.WrongExplanationBM;

            radA.Checked = q.CorrectAnswer == "A";
            radB.Checked = q.CorrectAnswer == "B";
            radC.Checked = q.CorrectAnswer == "C";
            radD.Checked = q.CorrectAnswer == "D";

            BindNav();
            btnPrev.Enabled = CurrentIndex > 0;
            btnNext.Enabled = CurrentIndex < qs.Count - 1;

            // Emit JS bootstrap data so the client engine starts with correct state
            EmitJsBootstrap();
        }

        private string JsEscape(string s)
        {
            if (string.IsNullOrEmpty(s)) return "";
            return s.Replace("\\", "\\\\").Replace("'", "\\'").Replace("\r", "\\r").Replace("\n", "\\n");
        }

        private void EmitJsBootstrap()
        {
            var qs = Questions;
            var ser = new System.Web.Script.Serialization.JavaScriptSerializer();
            var arr = new List<object>();
            foreach (var q in qs)
            {
                arr.Add(new {
                    qEN=q.QuestionTextEN, qBM=q.QuestionTextBM,
                    aEN=q.OptionA_EN, aBM=q.OptionA_BM,
                    bEN=q.OptionB_EN, bBM=q.OptionB_BM,
                    cEN=q.OptionC_EN, cBM=q.OptionC_BM,
                    dEN=q.OptionD_EN, dBM=q.OptionD_BM,
                    ceEN=q.CorrectExplanationEN, ceBM=q.CorrectExplanationBM,
                    weEN=q.WrongExplanationEN,  weBM=q.WrongExplanationBM,
                    correct=q.CorrectAnswer, type=q.QuestionType,
                    diff=q.Difficulty, saved=q.IsSaved,
                    fibIdxEN=q.FibIdxENJson, fibIdxBM=q.FibIdxBMJson
                });
            }
            string jsonData = ser.Serialize(arr);
            string tab = CurrentTab ?? "EN";
            int idx = CurrentIndex;
            litQuestionsJson.Text = string.Format(
                "<script>window.__QD={0};window.__CI={1};window.__CT='{2}';</s"+"cript>",
                jsonData, idx, tab == "BM" ? "BM" : "EN");
        }

        private void SaveCurrentToMemory()
        {
            // If JS has sent us the full serialised store, use that as the authoritative source
            if (!string.IsNullOrEmpty(hidQuestionsJson.Value))
            {
                try
                {
                    var parsed = SimpleJsonDeserialize(hidQuestionsJson.Value);
                    if (parsed != null && parsed.Count > 0)
                    {
                        Questions = parsed;
                        if (!string.IsNullOrEmpty(hidCurrentIndex.Value) &&
                            int.TryParse(hidCurrentIndex.Value, out int jsIdx))
                            CurrentIndex = jsIdx;
                        if (!string.IsNullOrEmpty(hidCurrentTab.Value))
                            hidCurrentTab.Value = hidCurrentTab.Value; // already set
                        return; // JS store is the truth, no need to read individual controls
                    }
                }
                catch { /* fall through to control-based save */ }
            }

            // Fallback: read from individual server controls (original behaviour)
            var qs = Questions;
            if (CurrentIndex >= qs.Count) return;
            var q = qs[CurrentIndex];
            bool isEN = CurrentTab == "EN";

            if (isEN)
            {
                q.QuestionTextEN = txtQuestionText.Text;
                q.OptionA_EN = txtOptA.Text; q.OptionB_EN = txtOptB.Text;
                q.OptionC_EN = txtOptC.Text; q.OptionD_EN = txtOptD.Text;
                q.CorrectExplanationEN = txtCorrectExp.Text;
                q.WrongExplanationEN = txtWrongExp.Text;
            }
            else
            {
                q.QuestionTextBM = txtQuestionText.Text;
                q.OptionA_BM = txtOptA.Text; q.OptionB_BM = txtOptB.Text;
                q.OptionC_BM = txtOptC.Text; q.OptionD_BM = txtOptD.Text;
                q.CorrectExplanationBM = txtCorrectExp.Text;
                q.WrongExplanationBM = txtWrongExp.Text;
            }

            q.QuestionType = NormalizeQuestionType(ddlQType.SelectedValue);
            q.Difficulty = NormalizeDifficulty(ddlQDiff.SelectedValue);
            if (radA.Checked) q.CorrectAnswer = "A";
            else if (radB.Checked) q.CorrectAnswer = "B";
            else if (radC.Checked) q.CorrectAnswer = "C";
            else if (radD.Checked) q.CorrectAnswer = "D";

            Questions = qs;
        }

        // Minimal JSON deserialiser — parses the array of question objects emitted by JS
        private List<QuestionData> SimpleJsonDeserialize(string json)
        {
            var result = new List<QuestionData>();
            try
            {
                var ser = new System.Web.Script.Serialization.JavaScriptSerializer();
                var raw = ser.Deserialize<List<System.Collections.Generic.Dictionary<string, object>>>(json);
                foreach (var d in raw)
                {
                    string g(string k) => d.ContainsKey(k) ? (d[k] ?? "").ToString() : "";
                    bool   b(string k) => d.ContainsKey(k) && d[k] is bool bv && bv;

                    // Parse fibEN / fibBM arrays (JS sends as ArrayList)
                    string[] getFib(string k)
                    {
                        var arr = new string[4];
                        if (d.ContainsKey(k) && d[k] is System.Collections.ArrayList al)
                            for (int i = 0; i < Math.Min(al.Count, 4); i++)
                                arr[i] = al[i]?.ToString() ?? "";
                        return arr;
                    }

                    // img field: keep if it looks like a plain filename, discard data-URLs
                    string imgUrl = "";
                    string imgRaw = g("img");
                    if (!string.IsNullOrEmpty(imgRaw) && !imgRaw.StartsWith("data:"))
                        imgUrl = imgRaw; // plain filename stored by JS after upload

                    result.Add(new QuestionData
                    {
                        QuestionTextEN = g("qEN"), QuestionTextBM = g("qBM"),
                        OptionA_EN = g("aEN"), OptionA_BM = g("aBM"),
                        OptionB_EN = g("bEN"), OptionB_BM = g("bBM"),
                        OptionC_EN = g("cEN"), OptionC_BM = g("cBM"),
                        OptionD_EN = g("dEN"), OptionD_BM = g("dBM"),
                        CorrectExplanationEN = g("ceEN"), CorrectExplanationBM = g("ceBM"),
                        WrongExplanationEN = g("weEN"), WrongExplanationBM = g("weBM"),
                        CorrectAnswer = g("correct"),
                        QuestionType = NormalizeQuestionType(g("type")),
                        Difficulty = NormalizeDifficulty(g("diff")),
                        IsSaved = b("saved"),
                        QuestionImageUrl = imgUrl,
                        MsChk = g("msChk"),
                        MsAEN = g("msAEN"), MsABM = g("msABM"),
                        MsBEN = g("msBEN"), MsBBM = g("msBBM"),
                        MsCEN = g("msCEN"), MsCBM = g("msCBM"),
                        MsDEN = g("msDEN"), MsDBM = g("msDBM"),
                        FibEN = getFib("fibEN"),
                        FibBM = getFib("fibBM"),
                        FibMapEN = getFib("fibMapEN"),
                        FibMapBM = getFib("fibMapBM"),
                        // Serialise the index dictionaries back to JSON strings for re-emission
                        FibIdxENJson = d.ContainsKey("fibIdxEN") ? ser.Serialize(d["fibIdxEN"]) : "{}",
                        FibIdxBMJson = d.ContainsKey("fibIdxBM") ? ser.Serialize(d["fibIdxBM"]) : "{}"
                    });
                }
            }
            catch { return null; }
            return result;
        }

        private void BindNav()
        {
            var list = new List<object>();
            var qs = Questions;
            for (int i = 0; i < qs.Count; i++)
                list.Add(new { Index = i, Done = qs[i].IsSaved });
            rptNav.DataSource = list; rptNav.DataBind();
        }

        // -- Event Handlers -------------------------------------------
        // Tab switching is now client-side only — these handlers kept for fallback/non-JS
        protected void btnTabEN_Click(object sender, EventArgs e) { SaveCurrentToMemory(); CurrentTab = "EN"; LoadCurrentQuestion(); }
        protected void btnTabBM_Click(object sender, EventArgs e) { SaveCurrentToMemory(); CurrentTab = "BM"; LoadCurrentQuestion(); }

        // Prev/Next are now client-side — these are no longer triggered but kept for safety
        protected void btnPrev_Click(object sender, EventArgs e) { SaveCurrentToMemory(); if (CurrentIndex > 0) CurrentIndex--; LoadCurrentQuestion(); }
        protected void btnNext_Click(object sender, EventArgs e) { SaveCurrentToMemory(); var qs = Questions; if (CurrentIndex < qs.Count - 1) CurrentIndex++; LoadCurrentQuestion(); }

        protected void btnNav_Command(object sender, CommandEventArgs e)
        { SaveCurrentToMemory(); CurrentIndex = Convert.ToInt32(e.CommandArgument); LoadCurrentQuestion(); }

        // btnNavGo is a hidden button kept for potential future server-side nav; not used by JS engine
        protected void btnNavGo_Click(object sender, EventArgs e) { SaveCurrentToMemory(); LoadCurrentQuestion(); }

        protected void btnAddQuestion_Click(object sender, EventArgs e)
        {
            SaveCurrentToMemory();
            var qs = Questions; qs.Add(new QuestionData()); Questions = qs;
            CurrentIndex = qs.Count - 1; LoadCurrentQuestion();
        }

        protected void btnDeleteQuestion_Click(object sender, EventArgs e)
        {
            var qs = Questions;
            if (qs.Count <= 1) return; // safety: never delete last question
            int delIdx;
            if (!int.TryParse(hidDeleteIndex.Value, out delIdx)) return;
            if (delIdx < 0 || delIdx >= qs.Count) return;

            qs.RemoveAt(delIdx);
            Questions = qs;

            // Adjust current index so we don't go out of bounds
            if (CurrentIndex >= qs.Count) CurrentIndex = qs.Count - 1;
            if (CurrentIndex == delIdx && CurrentIndex > 0) CurrentIndex--;

            hidDeleteIndex.Value = "-1";
            hidToast.Value = T("Question deleted.", "Soalan dipadam.");
            LoadCurrentQuestion();
        }

        protected void btnSaveQ_Click(object sender, EventArgs e)
        {
            SaveCurrentToMemory();
            var qs = Questions; qs[CurrentIndex].IsSaved = true; Questions = qs;
            LoadCurrentQuestion();
        }

        protected void btnSubmitQuiz_Click(object sender, EventArgs e)
        {
            SaveCurrentToMemory();
            var qs = Questions;
            string quizId   = ViewState["QuizId"]    as string;
            string subtopicId = ViewState["SubtopicId"] as string;
            string userId   = Session["userId"].ToString();

            if (string.IsNullOrEmpty(quizId))    { ShowError(T("Quiz not found.", "Kuiz tidak ditemui.")); return; }
            if (string.IsNullOrEmpty(subtopicId)) { ShowError(T("Subtopic not specified.", "Subtopik tidak dinyatakan.")); return; }

            // -- Save uploaded image once (optional — applies to current question) --
            string uploadedImageFileName = SaveQuestionImage();
            // If an image was uploaded, assign its filename to the current question
            if (!string.IsNullOrEmpty(uploadedImageFileName) && qs.Count > 0)
            {
                int imgQIdx = CurrentIndex < qs.Count ? CurrentIndex : 0;
                qs[imgQIdx].QuestionImageUrl = uploadedImageFileName;
            }
            // Also handle filenames that came from the JS store (already-named, no new upload)
            // Those are already in q.QuestionImageUrl from SimpleJsonDeserialize

            // -- Per-question validation ------------------------------
            for (int qi = 0; qi < qs.Count; qi++)
            {
                var q     = qs[qi];
                string qLabel = T($"Question {qi + 1}", $"Soalan {qi + 1}");
                string qType  = q.QuestionType ?? "MCQ";

                // Question text — required for all types
                if (string.IsNullOrWhiteSpace(q.QuestionTextEN))
                { ShowError($"{qLabel}: {T("English question text is required.", "Teks soalan Bahasa Inggeris diperlukan.")}"); return; }
                if (string.IsNullOrWhiteSpace(q.QuestionTextBM))
                { ShowError($"{qLabel}: {T("Bahasa Melayu question text is required.", "Teks soalan Bahasa Melayu diperlukan.")}"); return; }

                // Explanations — required for all types
                if (string.IsNullOrWhiteSpace(q.CorrectExplanationEN))
                { ShowError($"{qLabel}: {T("Correct explanation (English) is required.", "Penjelasan betul (Bahasa Inggeris) diperlukan.")}"); return; }
                if (string.IsNullOrWhiteSpace(q.CorrectExplanationBM))
                { ShowError($"{qLabel}: {T("Correct explanation (Bahasa Melayu) is required.", "Penjelasan betul (Bahasa Melayu) diperlukan.")}"); return; }
                if (string.IsNullOrWhiteSpace(q.WrongExplanationEN))
                { ShowError($"{qLabel}: {T("Wrong explanation (English) is required.", "Penjelasan salah (Bahasa Inggeris) diperlukan.")}"); return; }
                if (string.IsNullOrWhiteSpace(q.WrongExplanationBM))
                { ShowError($"{qLabel}: {T("Wrong explanation (Bahasa Melayu) is required.", "Penjelasan salah (Bahasa Melayu) diperlukan.")}"); return; }

                switch (qType)
                {
                    case "MCQ":
                        if (string.IsNullOrWhiteSpace(q.OptionA_EN) || string.IsNullOrWhiteSpace(q.OptionB_EN))
                        { ShowError($"{qLabel}: {T("Options A and B (English) are required.", "Pilihan A dan B (Bahasa Inggeris) diperlukan.")}"); return; }
                        if (string.IsNullOrWhiteSpace(q.OptionA_BM) || string.IsNullOrWhiteSpace(q.OptionB_BM))
                        { ShowError($"{qLabel}: {T("Options A and B (Bahasa Melayu) are required.", "Pilihan A dan B (Bahasa Melayu) diperlukan.")}"); return; }
                        if (string.IsNullOrEmpty(q.CorrectAnswer))
                        { ShowError($"{qLabel}: {T("Please select the correct answer.", "Sila pilih jawapan yang betul.")}"); return; }
                        string mcqOptEN = q.CorrectAnswer == "A" ? q.OptionA_EN : q.CorrectAnswer == "B" ? q.OptionB_EN :
                                          q.CorrectAnswer == "C" ? q.OptionC_EN : q.OptionD_EN;
                        if (string.IsNullOrWhiteSpace(mcqOptEN))
                        { ShowError($"{qLabel}: {T("The selected correct answer option must not be empty.", "Pilihan jawapan betul yang dipilih tidak boleh kosong.")}"); return; }
                        break;

                    case "True/False":
                        if (string.IsNullOrEmpty(q.CorrectAnswer))
                        { ShowError($"{qLabel}: {T("Please select the correct answer.", "Sila pilih jawapan yang betul.")}"); return; }
                        break;

                    case "Multiselect":
                        if (string.IsNullOrWhiteSpace(q.MsAEN) || string.IsNullOrWhiteSpace(q.MsBEN) || string.IsNullOrWhiteSpace(q.MsCEN))
                        { ShowError($"{qLabel}: {T("Options A, B and C (English) are required for Multiselect.", "Pilihan A, B dan C (Bahasa Inggeris) diperlukan untuk Berbilang Pilihan.")}"); return; }
                        if (string.IsNullOrWhiteSpace(q.MsABM) || string.IsNullOrWhiteSpace(q.MsBBM) || string.IsNullOrWhiteSpace(q.MsCBM))
                        { ShowError($"{qLabel}: {T("Options A, B and C (Bahasa Melayu) are required for Multiselect.", "Pilihan A, B dan C (Bahasa Melayu) diperlukan untuk Berbilang Pilihan.")}"); return; }
                        var msLetters = (q.MsChk ?? "").Split(new[]{','}, StringSplitOptions.RemoveEmptyEntries);
                        if (msLetters.Length == 0)
                        { ShowError($"{qLabel}: {T("Please select the correct answers.", "Sila pilih jawapan yang betul.")}"); return; }
                        if (msLetters.Length == 1)
                        { ShowError($"{qLabel}: {T("Please select at least 2 correct answers.", "Sila pilih sekurang-kurangnya 2 jawapan betul.")}"); return; }
                        var msOptMapEN = new System.Collections.Generic.Dictionary<string,string>{
                            {"A",q.MsAEN},{"B",q.MsBEN},{"C",q.MsCEN},{"D",q.MsDEN}};
                        foreach (var letter in msLetters)
                            if (!msOptMapEN.ContainsKey(letter) || string.IsNullOrWhiteSpace(msOptMapEN[letter]))
                            { ShowError($"{qLabel}: {T("A selected correct answer option is empty.", "Pilihan jawapan betul yang dipilih adalah kosong.")}"); return; }
                        break;

                    case "Drag & Drop":
                        var fibENWords = (q.FibEN ?? new string[4]).Where((string s) => !string.IsNullOrWhiteSpace(s)).ToList();
                        var fibBMWords = (q.FibBM ?? new string[4]).Where((string s) => !string.IsNullOrWhiteSpace(s)).ToList();
                        if (fibENWords.Count < 2)
                        { ShowError($"{qLabel}: {T("At least two answer options are required.", "Sekurang-kurangnya dua pilihan jawapan diperlukan.")}"); return; }
                        if (fibBMWords.Count < 2)
                        { ShowError($"{qLabel}: {T("At least two answer options are required.", "Sekurang-kurangnya dua pilihan jawapan diperlukan.")}"); return; }
                        var blankRe = new System.Text.RegularExpressions.Regex(@"\[Blank \d\]");
                        int enBlanks = blankRe.Matches(q.QuestionTextEN ?? "").Count;
                        int bmBlanks = blankRe.Matches(q.QuestionTextBM ?? "").Count;
                        if (enBlanks < 1 || bmBlanks < 1)
                        { ShowError($"{qLabel}: {T("At least one blank is required.", "Sekurang-kurangnya satu tempat kosong diperlukan.")}"); return; }
                        if (enBlanks != bmBlanks)
                        { ShowError($"{qLabel}: {T("The number of blanks in English and Bahasa Melayu must match.", "Bilangan tempat kosong dalam Bahasa Inggeris dan Bahasa Melayu mesti sepadan.")}"); return; }
                        // Mapping count must match blank count
                        var enMappedWords = (q.FibMapEN ?? new string[0]).Where((string s) => !string.IsNullOrWhiteSpace(s)).ToList();
                        var bmMappedWords = (q.FibMapBM ?? new string[0]).Where((string s) => !string.IsNullOrWhiteSpace(s)).ToList();
                        if (enMappedWords.Count == 0 || bmMappedWords.Count == 0)
                        { ShowError($"{qLabel}: {T("Please select the correct mapping order.", "Sila pilih susunan pemetaan yang betul.")}"); return; }
                        if (enMappedWords.Count != enBlanks)
                        { ShowError($"{qLabel}: {T("The number of mappings must match the number of blanks.", "Bilangan pemetaan mesti sepadan dengan bilangan tempat kosong.")}"); return; }
                        if (bmMappedWords.Count != bmBlanks)
                        { ShowError($"{qLabel}: {T("The number of mappings must match the number of blanks.", "Bilangan pemetaan mesti sepadan dengan bilangan tempat kosong.")}"); return; }
                        break;
                }
            }

            // -- Build save values per question type ------------------
            string BuildCorrectAnswer(QuestionData q)
            {
                switch (q.QuestionType ?? "MCQ")
                {
                    case "True/False":
                        return q.CorrectAnswer ?? "";

                    case "Multiselect":
                        return q.MsChk ?? "";

                    case "Drag & Drop":
                        // Build from mapping order only: EN mapped words first, then BM mapped words
                        var enMapped = (q.FibMapEN ?? new string[0])
                            .Where((string s) => !string.IsNullOrWhiteSpace(s)).ToList();
                        var bmMapped = (q.FibMapBM ?? new string[0])
                            .Where((string s) => !string.IsNullOrWhiteSpace(s)).ToList();
                        return string.Join(",", enMapped.Concat(bmMapped));

                    default:
                        return q.CorrectAnswer ?? "";
                }
            }

            // -- Insert all questions in a single transaction ----------
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var txn = conn.BeginTransaction())
                    {
                        try
                        {
                            int maxId = 0;
                            using (var cmd = new SqlCommand(
                                "SELECT ISNULL(MAX(CAST(SUBSTRING([questionId],4,LEN([questionId])-3) AS INT)),0) FROM dbo.[Question]",
                                conn, txn))
                            { maxId = Convert.ToInt32(cmd.ExecuteScalar()); }

                            foreach (var q in qs)
                            {
                                maxId++;
                                string qid = "QST" + maxId.ToString("D3");
                                string qType = q.QuestionType ?? "MCQ";

                                // Resolve per-type option values
                                string aEN, aBM, bEN, bBM, cEN, cBM, dEN, dBM;
                                if (qType == "Multiselect")
                                {
                                    aEN = q.MsAEN; aBM = q.MsABM;
                                    bEN = q.MsBEN; bBM = q.MsBBM;
                                    cEN = q.MsCEN; cBM = q.MsCBM;
                                    dEN = q.MsDEN; dBM = q.MsDBM;
                                }
                                else if (qType == "True/False")
                                {
                                    // Fixed bilingual option text; C and D are NULL
                                    aEN = "True";  aBM = "Betul";
                                    bEN = "False"; bBM = "Salah";
                                    cEN = null;    cBM = null;
                                    dEN = null;    dBM = null;
                                }
                                else if (qType == "Drag & Drop")
                                {
                                    // Store each FIB word in the option slots (up to 4 words)
                                    var fe = q.FibEN ?? new string[4];
                                    var fb = q.FibBM ?? new string[4];
                                    aEN = fe.Length > 0 ? fe[0] : null; aBM = fb.Length > 0 ? fb[0] : null;
                                    bEN = fe.Length > 1 ? fe[1] : null; bBM = fb.Length > 1 ? fb[1] : null;
                                    cEN = fe.Length > 2 ? fe[2] : null; cBM = fb.Length > 2 ? fb[2] : null;
                                    dEN = fe.Length > 3 ? fe[3] : null; dBM = fb.Length > 3 ? fb[3] : null;
                                }
                                else
                                {
                                    aEN = q.OptionA_EN; aBM = q.OptionA_BM;
                                    bEN = q.OptionB_EN; bBM = q.OptionB_BM;
                                    cEN = q.OptionC_EN; cBM = q.OptionC_BM;
                                    dEN = q.OptionD_EN; dBM = q.OptionD_BM;
                                }

                                // For Drag & Drop, replace [Blank N] markers with _____ before saving
                                string textEN = q.QuestionTextEN ?? "";
                                string textBM = q.QuestionTextBM ?? "";
                                if (qType == "Drag & Drop")
                                {
                                    var blankPattern = new System.Text.RegularExpressions.Regex(@"\[Blank \d+\]");
                                    textEN = blankPattern.Replace(textEN, "_____");
                                    textBM = blankPattern.Replace(textBM, "_____");
                                }

                                string correctAnswer = BuildCorrectAnswer(q);

                                // Image: use the stored filename directly (original name, no path)
                                string imgFileName = Nv(q.QuestionImageUrl);

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
                                    cmd.Parameters.AddWithValue("@qid",    qid);
                                    cmd.Parameters.AddWithValue("@quiz",   quizId);
                                    cmd.Parameters.AddWithValue("@sub",    subtopicId);
                                    cmd.Parameters.AddWithValue("@uid",    userId);
                                    cmd.Parameters.AddWithValue("@tEN",    textEN);
                                    cmd.Parameters.AddWithValue("@tBM",    textBM);
                                    cmd.Parameters.AddWithValue("@type",   qType);
                                    cmd.Parameters.AddWithValue("@imgUrl", (object)imgFileName ?? DBNull.Value);
                                    cmd.Parameters.AddWithValue("@aEN",    (object)Nv(aEN) ?? DBNull.Value);
                                    cmd.Parameters.AddWithValue("@aBM",    (object)Nv(aBM) ?? DBNull.Value);
                                    cmd.Parameters.AddWithValue("@bEN",    (object)Nv(bEN) ?? DBNull.Value);
                                    cmd.Parameters.AddWithValue("@bBM",    (object)Nv(bBM) ?? DBNull.Value);
                                    cmd.Parameters.AddWithValue("@cEN",    (object)Nv(cEN) ?? DBNull.Value);
                                    cmd.Parameters.AddWithValue("@cBM",    (object)Nv(cBM) ?? DBNull.Value);
                                    cmd.Parameters.AddWithValue("@dEN",    (object)Nv(dEN) ?? DBNull.Value);
                                    cmd.Parameters.AddWithValue("@dBM",    (object)Nv(dBM) ?? DBNull.Value);
                                    cmd.Parameters.AddWithValue("@ans",    correctAnswer);
                                    cmd.Parameters.AddWithValue("@ceEN",   (object)Nv(q.CorrectExplanationEN) ?? DBNull.Value);
                                    cmd.Parameters.AddWithValue("@ceBM",   (object)Nv(q.CorrectExplanationBM) ?? DBNull.Value);
                                    cmd.Parameters.AddWithValue("@weEN",   (object)Nv(q.WrongExplanationEN) ?? DBNull.Value);
                                    cmd.Parameters.AddWithValue("@weBM",   (object)Nv(q.WrongExplanationBM) ?? DBNull.Value);
                                    cmd.Parameters.AddWithValue("@diff",   q.Difficulty ?? "Medium");
                                    cmd.ExecuteNonQuery();
                                }
                            }

                            txn.Commit();

                            // -- Insert ONE notification for the teacher ----------
                            string titleEN = T("Question Submitted Successfully", "Soalan Berjaya Dihantar");
                            string titleBM = "Soalan Berjaya Dihantar";
                            string quizTitleEN = ViewState["QuizTitleEN"] as string ?? quizId;
                            string quizTitleBM = ViewState["QuizTitleBM"] as string ?? quizId;
                            string msgEN = $"Your questions for {quizTitleEN} were submitted successfully and are pending review.";
                            string msgBM = $"Soalan anda untuk {quizTitleBM} telah berjaya dihantar dan sedang menunggu semakan.";
                            try
                            {
                                string nid = GenerateNotificationId(conn);
                                const string notifSql = @"INSERT INTO dbo.[Notification]
                                    ([notificationId],[toUserId],[titleEN],[titleBM],[messageEN],[messageBM],[isRead],[createdAt])
                                    VALUES(@nid,@uid,@tEN,@tBM,@mEN,@mBM,0,GETDATE())";
                                using (var ncmd = new SqlCommand(notifSql, conn))
                                {
                                    ncmd.Parameters.AddWithValue("@nid", nid);
                                    ncmd.Parameters.AddWithValue("@uid", userId);
                                    ncmd.Parameters.AddWithValue("@tEN", titleEN);
                                    ncmd.Parameters.AddWithValue("@tBM", titleBM);
                                    ncmd.Parameters.AddWithValue("@mEN", msgEN);
                                    ncmd.Parameters.AddWithValue("@mBM", msgBM);
                                    ncmd.ExecuteNonQuery();
                                }
                            }
                            catch { /* notification failure must not block success */ }

                            // -- Signal the success modal (no redirect) ----------
                            hidSubmitSuccess.Value = "1";
                        }
                        catch (Exception ex)
                        {
                            txn.Rollback();
                            ShowError(T("Failed to submit quiz. Please try again.", "Gagal menghantar kuiz. Sila cuba lagi.") + " (" + ex.Message + ")");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowError(T("Database error occurred.", "Ralat pangkalan data berlaku.") + " (" + ex.Message + ")");
            }
        }

        private void ShowError(string msg)
        {
            pnlError.Visible = true; pnlBuilder.Visible = false;
            litError.Text = HttpUtility.HtmlEncode(msg);
        }

        /// <summary>
        /// Ensures the question type stored in the database is always the English standard value,
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
        /// Ensures the difficulty stored in the database is always the English standard value,
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

        // Saves the uploaded question image to ~/Images/Question/ and returns just the filename.
        // Returns null if nothing was uploaded.
        private string SaveQuestionImage()
        {
            if (fuQuestionImage == null || !fuQuestionImage.HasFile)
                return null;

            // Save with the original filename only (no timestamp prefix)
            string originalName = Path.GetFileName(fuQuestionImage.FileName);
            if (string.IsNullOrWhiteSpace(originalName))
                return null;

            string fileName = originalName; // store exactly as-is
            string folder   = Server.MapPath("~/Images/Question/");
            if (!Directory.Exists(folder))
                Directory.CreateDirectory(folder);

            fuQuestionImage.SaveAs(Path.Combine(folder, fileName));
            return fileName;
        }

        // Returns null for blank/whitespace strings, otherwise trims and returns the value
        private static string Nv(string s) => string.IsNullOrWhiteSpace(s) ? null : s.Trim();

        // Generates the next notification ID in the format N001, N002, ...
        private string GenerateNotificationId(SqlConnection conn)
        {
            const string sql = "SELECT TOP 1 [notificationId] FROM dbo.[Notification] ORDER BY [notificationId] DESC";
            using (var cmd = new SqlCommand(sql, conn))
            {
                var v = cmd.ExecuteScalar();
                if (v == null || v == DBNull.Value) return "N001";
                string last = v.ToString();
                if (last.Length > 1 && int.TryParse(last.Substring(1), out int n))
                    return "N" + (n + 1).ToString().PadLeft(last.Length - 1, '0');
                return "N001";
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
    }
}
