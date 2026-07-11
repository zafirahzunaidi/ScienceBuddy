using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
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
        public string CorrectAnswer { get; set; } = "";
        public string CorrectExplanationEN { get; set; } = "";
        public string CorrectExplanationBM { get; set; } = "";
        public string WrongExplanationEN { get; set; } = "";
        public string WrongExplanationBM { get; set; } = "";
        public bool IsSaved { get; set; } = false;
    }

    public partial class createUnitLevelQuiz : Page
    {
        protected global::System.Web.UI.WebControls.Panel pnlSubtopicSelect;
        protected global::System.Web.UI.WebControls.DropDownList ddlSubtopic;
        protected global::System.Web.UI.WebControls.Panel pnlQuizTitles;
        protected global::System.Web.UI.WebControls.Literal litQuizTitleEN;
        protected global::System.Web.UI.WebControls.Literal litQuizTitleBM;

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
                }
                else { ShowError(T("Invalid mode.", "Mod tidak sah.")); return false; }

                string quizId = GetQuizId(conn, mode);
                if (string.IsNullOrEmpty(quizId))
                { ShowError(T("No matching quiz found for the selected criteria.", "Tiada kuiz yang sepadan ditemui untuk kriteria yang dipilih.")); return false; }

                ViewState["QuizId"] = quizId;
                ViewState["SubtopicId"] = subtopicId;
            }

            pnlBuilder.Visible = true;
            btnAddQuestion.Text = T("+ Add Question", "+ Tambah Soalan");
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
                }
                else
                {
                    litMode.Text = T("Level Quiz", "Kuiz Tahap");
                    string levelName = "";
                    using (var cmd = new SqlCommand("SELECT [levelNameEN] FROM dbo.[Level] WHERE [levelId]=@l", conn))
                    { cmd.Parameters.AddWithValue("@l", levelId); var v = cmd.ExecuteScalar(); levelName = v?.ToString() ?? "-"; }
                    litScope.Text = HttpUtility.HtmlEncode(levelName);
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
            }

            pnlBuilder.Visible = true;
            btnAddQuestion.Text = T("+ Add Question", "+ Tambah Soalan");
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

        // ── UI Loading ───────────────────────────────────────────────
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
            btnTabEN.CssClass = isEN ? "qb-tab active" : "qb-tab";
            btnTabBM.CssClass = isEN ? "qb-tab" : "qb-tab active";
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

            // Correct answer radio
            radA.Checked = q.CorrectAnswer == "A";
            radB.Checked = q.CorrectAnswer == "B";
            radC.Checked = q.CorrectAnswer == "C";
            radD.Checked = q.CorrectAnswer == "D";

            // Nav
            BindNav();
            btnPrev.Enabled = CurrentIndex > 0;
            btnNext.Enabled = CurrentIndex < qs.Count - 1;
        }

        private void SaveCurrentToMemory()
        {
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

            q.QuestionType = ddlQType.SelectedValue;
            q.Difficulty = ddlQDiff.SelectedValue;
            if (radA.Checked) q.CorrectAnswer = "A";
            else if (radB.Checked) q.CorrectAnswer = "B";
            else if (radC.Checked) q.CorrectAnswer = "C";
            else if (radD.Checked) q.CorrectAnswer = "D";

            Questions = qs;
        }

        private void BindNav()
        {
            var list = new List<object>();
            var qs = Questions;
            for (int i = 0; i < qs.Count; i++)
                list.Add(new { Index = i, Done = qs[i].IsSaved });
            rptNav.DataSource = list; rptNav.DataBind();
        }

        // ── Event Handlers ───────────────────────────────────────────
        protected void btnTabEN_Click(object sender, EventArgs e) { SaveCurrentToMemory(); CurrentTab = "EN"; LoadCurrentQuestion(); }
        protected void btnTabBM_Click(object sender, EventArgs e) { SaveCurrentToMemory(); CurrentTab = "BM"; LoadCurrentQuestion(); }

        protected void btnPrev_Click(object sender, EventArgs e) { SaveCurrentToMemory(); if (CurrentIndex > 0) CurrentIndex--; LoadCurrentQuestion(); }
        protected void btnNext_Click(object sender, EventArgs e) { SaveCurrentToMemory(); var qs = Questions; if (CurrentIndex < qs.Count - 1) CurrentIndex++; LoadCurrentQuestion(); }

        protected void btnNav_Command(object sender, CommandEventArgs e)
        { SaveCurrentToMemory(); CurrentIndex = Convert.ToInt32(e.CommandArgument); LoadCurrentQuestion(); }

        protected void btnAddQuestion_Click(object sender, EventArgs e)
        {
            SaveCurrentToMemory();
            var qs = Questions; qs.Add(new QuestionData()); Questions = qs;
            CurrentIndex = qs.Count - 1; LoadCurrentQuestion();
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
            string quizId = ViewState["QuizId"] as string;
            string subtopicId = ViewState["SubtopicId"] as string;
            string userId = Session["userId"].ToString();

            if (string.IsNullOrEmpty(quizId)) { ShowError(T("Quiz not found.", "Kuiz tidak ditemui.")); return; }
            if (string.IsNullOrEmpty(subtopicId)) { ShowError(T("Subtopic not specified.", "Subtopik tidak dinyatakan.")); return; }

            // Validate all questions
            foreach (var q in qs)
            {
                if (string.IsNullOrWhiteSpace(q.QuestionTextEN) || string.IsNullOrWhiteSpace(q.QuestionTextBM))
                { ShowError(T("All questions must have EN and BM text.", "Semua soalan mesti ada teks EN dan BM.")); return; }
                if (string.IsNullOrEmpty(q.CorrectAnswer))
                { ShowError(T("All questions must have a correct answer selected.", "Semua soalan mesti ada jawapan betul dipilih.")); return; }
            }

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var txn = conn.BeginTransaction())
                    {
                        try
                        {
                            // Get max questionId
                            int maxId = 0;
                            using (var cmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING([questionId],4,LEN([questionId])-3) AS INT)),0) FROM dbo.[Question]", conn, txn))
                            { maxId = Convert.ToInt32(cmd.ExecuteScalar()); }

                            foreach (var q in qs)
                            {
                                maxId++;
                                string qid = "QST" + maxId.ToString("D3");
                                const string sql = @"INSERT INTO dbo.[Question]
                                    ([questionId],[quizId],[subtopicId],[createdByUserId],[questionTextEN],[questionTextBM],
                                     [questionType],[optionA_EN],[optionA_BM],[optionB_EN],[optionB_BM],[optionC_EN],[optionC_BM],
                                     [optionD_EN],[optionD_BM],[correctAnswer],[correctExplanationEN],[correctExplanationBM],
                                     [wrongExplanationEN],[wrongExplanationBM],[difficulty],[status],[createdAt])
                                    VALUES(@qid,@quiz,@sub,@uid,@tEN,@tBM,@type,@aEN,@aBM,@bEN,@bBM,@cEN,@cBM,@dEN,@dBM,
                                           @ans,@ceEN,@ceBM,@weEN,@weBM,@diff,'Pending',GETDATE())";
                                using (var cmd = new SqlCommand(sql, conn, txn))
                                {
                                    cmd.Parameters.AddWithValue("@qid", qid);
                                    cmd.Parameters.AddWithValue("@quiz", quizId);
                                    cmd.Parameters.AddWithValue("@sub", subtopicId);
                                    cmd.Parameters.AddWithValue("@uid", userId);
                                    cmd.Parameters.AddWithValue("@tEN", q.QuestionTextEN ?? "");
                                    cmd.Parameters.AddWithValue("@tBM", q.QuestionTextBM ?? "");
                                    cmd.Parameters.AddWithValue("@type", q.QuestionType ?? "MCQ");
                                    cmd.Parameters.AddWithValue("@aEN", (object)q.OptionA_EN ?? DBNull.Value);
                                    cmd.Parameters.AddWithValue("@aBM", (object)q.OptionA_BM ?? DBNull.Value);
                                    cmd.Parameters.AddWithValue("@bEN", (object)q.OptionB_EN ?? DBNull.Value);
                                    cmd.Parameters.AddWithValue("@bBM", (object)q.OptionB_BM ?? DBNull.Value);
                                    cmd.Parameters.AddWithValue("@cEN", (object)q.OptionC_EN ?? DBNull.Value);
                                    cmd.Parameters.AddWithValue("@cBM", (object)q.OptionC_BM ?? DBNull.Value);
                                    cmd.Parameters.AddWithValue("@dEN", (object)q.OptionD_EN ?? DBNull.Value);
                                    cmd.Parameters.AddWithValue("@dBM", (object)q.OptionD_BM ?? DBNull.Value);
                                    cmd.Parameters.AddWithValue("@ans", q.CorrectAnswer ?? "");
                                    cmd.Parameters.AddWithValue("@ceEN", (object)q.CorrectExplanationEN ?? DBNull.Value);
                                    cmd.Parameters.AddWithValue("@ceBM", (object)q.CorrectExplanationBM ?? DBNull.Value);
                                    cmd.Parameters.AddWithValue("@weEN", (object)q.WrongExplanationEN ?? DBNull.Value);
                                    cmd.Parameters.AddWithValue("@weBM", (object)q.WrongExplanationBM ?? DBNull.Value);
                                    cmd.Parameters.AddWithValue("@diff", q.Difficulty ?? "Medium");
                                    cmd.ExecuteNonQuery();
                                }
                            }
                            txn.Commit();
                            hidToast.Value = T("Quiz submitted successfully!", "Kuiz berjaya dihantar!");
                            Response.Redirect("~/Teacher/manageQuiz.aspx", false);
                            Context.ApplicationInstance.CompleteRequest();
                        }
                        catch { txn.Rollback(); ShowError(T("Failed to submit quiz. Please try again.", "Gagal menghantar kuiz. Sila cuba lagi.")); }
                    }
                }
            }
            catch { ShowError(T("Database error occurred.", "Ralat pangkalan data berlaku.")); }
        }

        private void ShowError(string msg)
        {
            pnlError.Visible = true; pnlBuilder.Visible = false;
            litError.Text = HttpUtility.HtmlEncode(msg);
        }
    }
}
