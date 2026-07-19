using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Teacher
{
    public partial class studentDetails : Page
    {
        protected string CurrentLanguage
        { get { string l = Session["preferredLanguage"] as string; return string.IsNullOrEmpty(l) ? "EN" : l; } }
        protected string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        protected int LessonPct = 0, UnitPct = 0, LevelPct = 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"]?.ToString() != "Teacher")
            { Response.Redirect("~/Login.aspx", false); Context.ApplicationInstance.CompleteRequest(); return; }

            // Handle AJAX request for answer details
            if (Request.QueryString["handler"] == "answers")
            { HandleAnswerRequest(); return; }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            if (!IsPostBack)
            {
                string sid = (Request.QueryString["studentId"] ?? "").Trim();
                if (string.IsNullOrEmpty(sid)) { ShowError(T("No student specified.", "Tiada pelajar dinyatakan.")); return; }
                LoadStudentDetails(sid);
            }
        }

        private void HandleAnswerRequest()
        {
            Response.Clear();
            Response.ContentType = "text/html";
            string resultId = (Request.QueryString["resultId"] ?? "").Trim();
            if (string.IsNullOrEmpty(resultId)) { Response.Write("<div class=\"tc-student-details-empty\">Invalid request.</div>"); Response.End(); return; }
            try
            {
                using (var c = new SqlConnection(ConnStr))
                {
                    c.Open();
                    var sb = new System.Text.StringBuilder();
                    using (var cmd = new SqlCommand(@"SELECT qst.[questionTextEN], qst.[questionTextBM], qst.[questionType],
                        qst.[optionA_EN], qst.[optionA_BM], qst.[optionB_EN], qst.[optionB_BM],
                        qst.[optionC_EN], qst.[optionC_BM], qst.[optionD_EN], qst.[optionD_BM],
                        qa.[selectedAnswer], qst.[correctAnswer], qa.[isCorrect]
                        FROM dbo.[QuizAnswer] qa
                        INNER JOIN dbo.[Question] qst ON qst.[questionId]=qa.[questionId]
                        WHERE qa.[resultId]=@rid
                        ORDER BY qa.[answerId]", c))
                    {
                        cmd.Parameters.AddWithValue("@rid", resultId);
                        using (var r = cmd.ExecuteReader())
                        {
                            int qNum = 0;
                            while (r.Read())
                            {
                                qNum++;
                                string qEN = r["questionTextEN"]?.ToString() ?? "";
                                string qBM = r["questionTextBM"]?.ToString() ?? "";
                                string qType = r["questionType"]?.ToString() ?? "MCQ";
                                string aEN = r["optionA_EN"]?.ToString() ?? "";
                                string aBM = r["optionA_BM"]?.ToString() ?? "";
                                string bEN = r["optionB_EN"]?.ToString() ?? "";
                                string bBM = r["optionB_BM"]?.ToString() ?? "";
                                string cEN = r["optionC_EN"]?.ToString() ?? "";
                                string cBM = r["optionC_BM"]?.ToString() ?? "";
                                string dEN = r["optionD_EN"]?.ToString() ?? "";
                                string dBM = r["optionD_BM"]?.ToString() ?? "";
                                string selected = r["selectedAnswer"] != DBNull.Value ? r["selectedAnswer"].ToString() : "-";
                                string correct = r["correctAnswer"]?.ToString() ?? "-";
                                bool isCorrect = r["isCorrect"] != DBNull.Value && Convert.ToBoolean(r["isCorrect"]);
                                string statusLabel = isCorrect ? T("Correct", "Betul") : T("Wrong", "Salah");
                                string badgeCss = isCorrect ? "correct" : "wrong";

                                sb.Append("<div class=\"tc-student-details-ans-card\">");
                                sb.AppendFormat("<div class=\"tc-student-details-ans-header\"><span class=\"tc-student-details-ans-num\">Q{0}</span><span class=\"tc-student-details-ans-badge {1}\">{2}</span></div>", qNum, badgeCss, statusLabel);

                                // Language sections side by side
                                sb.Append("<div class=\"tc-student-details-ans-langs\">");

                                // English section
                                sb.Append("<div class=\"tc-student-details-ans-lang-section\">");
                                sb.AppendFormat("<div class=\"tc-student-details-ans-lang-label\">{0}</div>", T("English", "Bahasa Inggeris"));
                                if (!string.IsNullOrEmpty(qEN))
                                {
                                    sb.AppendFormat("<div class=\"tc-student-details-ans-q\">{0}</div>", HttpUtility.HtmlEncode(qEN));
                                    sb.Append("<div class=\"tc-student-details-ans-options\">");
                                    if (!string.IsNullOrEmpty(aEN)) sb.AppendFormat("<div class=\"tc-student-details-ans-opt{0}\"><span class=\"tc-student-details-opt-label\">A</span>{1}</div>", correct == "A" ? " tc-student-details-opt-correct" : (selected == "A" && !isCorrect ? " tc-student-details-opt-wrong" : ""), HttpUtility.HtmlEncode(aEN));
                                    if (!string.IsNullOrEmpty(bEN)) sb.AppendFormat("<div class=\"tc-student-details-ans-opt{0}\"><span class=\"tc-student-details-opt-label\">B</span>{1}</div>", correct == "B" ? " tc-student-details-opt-correct" : (selected == "B" && !isCorrect ? " tc-student-details-opt-wrong" : ""), HttpUtility.HtmlEncode(bEN));
                                    if (!string.IsNullOrEmpty(cEN)) sb.AppendFormat("<div class=\"tc-student-details-ans-opt{0}\"><span class=\"tc-student-details-opt-label\">C</span>{1}</div>", correct == "C" ? " tc-student-details-opt-correct" : (selected == "C" && !isCorrect ? " tc-student-details-opt-wrong" : ""), HttpUtility.HtmlEncode(cEN));
                                    if (!string.IsNullOrEmpty(dEN)) sb.AppendFormat("<div class=\"tc-student-details-ans-opt{0}\"><span class=\"tc-student-details-opt-label\">D</span>{1}</div>", correct == "D" ? " tc-student-details-opt-correct" : (selected == "D" && !isCorrect ? " tc-student-details-opt-wrong" : ""), HttpUtility.HtmlEncode(dEN));
                                    sb.Append("</div>");
                                }
                                else
                                {
                                    sb.AppendFormat("<div class=\"tc-student-details-ans-unavail\">{0}</div>", T("Translation unavailable", "Terjemahan tidak tersedia"));
                                }
                                sb.Append("</div>");

                                // Bahasa Melayu section
                                sb.Append("<div class=\"tc-student-details-ans-lang-section\">");
                                sb.AppendFormat("<div class=\"tc-student-details-ans-lang-label\">{0}</div>", T("Bahasa Melayu", "Bahasa Melayu"));
                                if (!string.IsNullOrEmpty(qBM))
                                {
                                    sb.AppendFormat("<div class=\"tc-student-details-ans-q\">{0}</div>", HttpUtility.HtmlEncode(qBM));
                                    sb.Append("<div class=\"tc-student-details-ans-options\">");
                                    if (!string.IsNullOrEmpty(aBM)) sb.AppendFormat("<div class=\"tc-student-details-ans-opt{0}\"><span class=\"tc-student-details-opt-label\">A</span>{1}</div>", correct == "A" ? " tc-student-details-opt-correct" : (selected == "A" && !isCorrect ? " tc-student-details-opt-wrong" : ""), HttpUtility.HtmlEncode(aBM));
                                    if (!string.IsNullOrEmpty(bBM)) sb.AppendFormat("<div class=\"tc-student-details-ans-opt{0}\"><span class=\"tc-student-details-opt-label\">B</span>{1}</div>", correct == "B" ? " tc-student-details-opt-correct" : (selected == "B" && !isCorrect ? " tc-student-details-opt-wrong" : ""), HttpUtility.HtmlEncode(bBM));
                                    if (!string.IsNullOrEmpty(cBM)) sb.AppendFormat("<div class=\"tc-student-details-ans-opt{0}\"><span class=\"tc-student-details-opt-label\">C</span>{1}</div>", correct == "C" ? " tc-student-details-opt-correct" : (selected == "C" && !isCorrect ? " tc-student-details-opt-wrong" : ""), HttpUtility.HtmlEncode(cBM));
                                    if (!string.IsNullOrEmpty(dBM)) sb.AppendFormat("<div class=\"tc-student-details-ans-opt{0}\"><span class=\"tc-student-details-opt-label\">D</span>{1}</div>", correct == "D" ? " tc-student-details-opt-correct" : (selected == "D" && !isCorrect ? " tc-student-details-opt-wrong" : ""), HttpUtility.HtmlEncode(dBM));
                                    sb.Append("</div>");
                                }
                                else
                                {
                                    sb.AppendFormat("<div class=\"tc-student-details-ans-unavail\">{0}</div>", T("Translation unavailable", "Terjemahan tidak tersedia"));
                                }
                                sb.Append("</div>"); // tc-student-details-ans-lang-section BM
                                sb.Append("</div>"); // tc-student-details-ans-langs

                                // Student answer summary — varies by question type
                                string notAnswered = T("Not Answered", "Tidak Dijawab");
                                string selectedDisplay = string.IsNullOrEmpty(selected) || selected == "-" ? notAnswered : selected;
                                string correctDisplay = correct;

                                sb.Append("<div class=\"tc-student-details-ans-summary\">");

                                if (qType.Equals("DragDrop", StringComparison.OrdinalIgnoreCase) || qType.Equals("Drag and Drop", StringComparison.OrdinalIgnoreCase) || qType.Equals("DnD", StringComparison.OrdinalIgnoreCase))
                                {
                                    // Drag and Drop: display answer text in both languages
                                    sb.Append("<div class=\"tc-student-details-ans-dd-block\">");
                                    sb.AppendFormat("<div class=\"tc-student-details-ans-dd-title\">{0}</div>", T("Student's Answer", "Jawapan Pelajar"));
                                    if (string.IsNullOrEmpty(selected) || selected == "-")
                                    {
                                        sb.AppendFormat("<div class=\"tc-student-details-ans-dd-val\">{0}</div>", notAnswered);
                                    }
                                    else
                                    {
                                        sb.AppendFormat("<div class=\"tc-student-details-ans-dd-lang\"><span class=\"tc-student-details-ans-dd-lang-label\">{0}:</span> {1}</div>", T("English", "Bahasa Inggeris"), HttpUtility.HtmlEncode(selected));
                                        sb.AppendFormat("<div class=\"tc-student-details-ans-dd-lang\"><span class=\"tc-student-details-ans-dd-lang-label\">{0}:</span> {1}</div>", T("Bahasa Melayu", "Bahasa Melayu"), HttpUtility.HtmlEncode(selected));
                                    }
                                    sb.Append("</div>");
                                    sb.Append("<div class=\"tc-student-details-ans-dd-block\">");
                                    sb.AppendFormat("<div class=\"tc-student-details-ans-dd-title\">{0}</div>", T("Correct Answer", "Jawapan Betul"));
                                    sb.AppendFormat("<div class=\"tc-student-details-ans-dd-lang\"><span class=\"tc-student-details-ans-dd-lang-label\">{0}:</span> {1}</div>", T("English", "Bahasa Inggeris"), HttpUtility.HtmlEncode(correct));
                                    sb.AppendFormat("<div class=\"tc-student-details-ans-dd-lang\"><span class=\"tc-student-details-ans-dd-lang-label\">{0}:</span> {1}</div>", T("Bahasa Melayu", "Bahasa Melayu"), HttpUtility.HtmlEncode(correct));
                                    sb.Append("</div>");
                                }
                                else if (qType.Equals("MultiSelect", StringComparison.OrdinalIgnoreCase) || qType.Equals("Multi-select", StringComparison.OrdinalIgnoreCase) || qType.Equals("MS", StringComparison.OrdinalIgnoreCase))
                                {
                                    // Multi-select: sort letters alphabetically, display with commas
                                    string sortedSelected = SortLetters(selected, notAnswered);
                                    string sortedCorrect = SortLetters(correct, "-");
                                    sb.AppendFormat("<div class=\"tc-student-details-ans-pair\"><span class=\"tc-student-details-ans-pair-label\">{0}:</span><span class=\"tc-student-details-ans-pair-val\">{1}</span></div>", T("Student's Answer", "Jawapan Pelajar"), HttpUtility.HtmlEncode(sortedSelected));
                                    sb.AppendFormat("<div class=\"tc-student-details-ans-pair\"><span class=\"tc-student-details-ans-pair-label\">{0}:</span><span class=\"tc-student-details-ans-pair-val\">{1}</span></div>", T("Correct Answer", "Jawapan Betul"), HttpUtility.HtmlEncode(sortedCorrect));
                                }
                                else
                                {
                                    // MCQ / True-False: display option letter only
                                    sb.AppendFormat("<div class=\"tc-student-details-ans-pair\"><span class=\"tc-student-details-ans-pair-label\">{0}:</span><span class=\"tc-student-details-ans-pair-val\">{1}</span></div>", T("Student's Answer", "Jawapan Pelajar"), HttpUtility.HtmlEncode(selectedDisplay));
                                    sb.AppendFormat("<div class=\"tc-student-details-ans-pair\"><span class=\"tc-student-details-ans-pair-label\">{0}:</span><span class=\"tc-student-details-ans-pair-val\">{1}</span></div>", T("Correct Answer", "Jawapan Betul"), HttpUtility.HtmlEncode(correctDisplay));
                                }

                                sb.Append("</div>");

                                sb.Append("</div>"); // tc-student-details-ans-card
                            }
                            if (qNum == 0) sb.AppendFormat("<div class=\"tc-student-details-empty\">{0}</div>", T("No answer records found.", "Tiada rekod jawapan dijumpai."));
                        }
                    }
                    Response.Write(sb.ToString());
                }
            }
            catch { Response.Write("<div class=\"tc-student-details-empty\">" + T("Error loading answers.", "Ralat memuatkan jawapan.") + "</div>"); }
            Response.End();
        }

        private void LoadStudentDetails(string sid)
        {
            try
            {
                using (var c = new SqlConnection(ConnStr))
                {
                    c.Open();
                    string name = "", levelName = "-";
                    using (var cmd = new SqlCommand("SELECT s.[name],COALESCE(lv.[levelNameEN],'-') AS lvl FROM dbo.[Student] s INNER JOIN dbo.[User] u ON u.[userId]=s.[userId] LEFT JOIN dbo.[Level] lv ON lv.[levelId]=s.[currentLevelId] WHERE s.[studentId]=@sid AND u.[status]='Active'", c))
                    { cmd.Parameters.AddWithValue("@sid", sid); using (var r = cmd.ExecuteReader()) { if (!r.Read()) { ShowError(T("Student not found.", "Pelajar tidak dijumpai.")); return; } name = r["name"]?.ToString() ?? "Student"; levelName = r["lvl"].ToString(); } }
                    litName.Text = HttpUtility.HtmlEncode(name); litStudentId.Text = HttpUtility.HtmlEncode(sid); litLevel.Text = HttpUtility.HtmlEncode(levelName); litInitials.Text = HttpUtility.HtmlEncode(Ini(name));

                    int totalL = 0, doneL = 0;
                    using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[Lesson]", c)) totalL = Convert.ToInt32(cmd.ExecuteScalar());
                    using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[LessonProgress] WHERE [studentId]=@s AND [isCompleted]=1", c)) { cmd.Parameters.AddWithValue("@s", sid); doneL = Convert.ToInt32(cmd.ExecuteScalar()); }
                    litLessons.Text = doneL + " / " + totalL;
                    LessonPct = totalL > 0 ? (int)Math.Round((decimal)doneL / totalL * 100) : 0;

                    decimal uAvg = Avg(c, sid, "Unit"), lAvg = Avg(c, sid, "Level");
                    litUnitAvg.Text = uAvg >= 0 ? uAvg.ToString("0.0") + "%" : T("No Attempt", "Tiada Cubaan");
                    litLevelAvg.Text = lAvg >= 0 ? lAvg.ToString("0.0") + "%" : T("No Attempt", "Tiada Cubaan");
                    UnitPct = uAvg >= 0 ? (int)Math.Round(uAvg) : 0;
                    LevelPct = lAvg >= 0 ? (int)Math.Round(lAvg) : 0;

                    // Lesson Progress
                    var lRows = new List<object>();
                    using (var cmd = new SqlCommand("SELECT les.[lessonTitleEN],les.[lessonTitleBM],lp.[isCompleted],lp.[completedDate] FROM dbo.[LessonProgress] lp INNER JOIN dbo.[Lesson] les ON les.[lessonId]=lp.[lessonId] WHERE lp.[studentId]=@s ORDER BY lp.[completedDate] DESC", c))
                    { cmd.Parameters.AddWithValue("@s", sid); using (var r = cmd.ExecuteReader()) while (r.Read()) { bool d = r["isCompleted"] != DBNull.Value && Convert.ToBoolean(r["isCompleted"]); string dt = r["completedDate"] != DBNull.Value ? Convert.ToDateTime(r["completedDate"]).ToString("d MMM yyyy") : "-"; string lessonTitle = CurrentLanguage == "BM" ? (r["lessonTitleBM"]?.ToString() ?? r["lessonTitleEN"]?.ToString() ?? "") : (r["lessonTitleEN"]?.ToString() ?? r["lessonTitleBM"]?.ToString() ?? ""); lRows.Add(new { lesson = lessonTitle, status = d ? T("Completed", "Selesai") : T("Incomplete", "Belum Selesai"), statusCss = d ? "done" : "inc", date = dt }); } }
                    if (lRows.Count > 0) { pnlLessonTable.Visible = true; pnlLessonEmpty.Visible = false; rptLessons.DataSource = lRows; rptLessons.DataBind(); } else { pnlLessonTable.Visible = false; pnlLessonEmpty.Visible = true; }

                    BindQuiz(c, sid, "Unit", rptUnitQuiz, pnlUnitQuizTable, pnlUnitQuizEmpty);
                    BindQuiz(c, sid, "Level", rptLevelQuiz, pnlLevelQuizTable, pnlLevelQuizEmpty);

                    // Weak Topics — based on latest quiz attempt vs passing mark from Configuration
                    decimal unitPassMark = 50, levelPassMark = 50; // defaults
                    using (var cfgCmd = new SqlCommand("SELECT [configId],[configValue] FROM dbo.[ConfigurationSetting] WHERE [configId] IN ('CONFIG004','CONFIG005')", c))
                    {
                        using (var cfgR = cfgCmd.ExecuteReader())
                        {
                            while (cfgR.Read())
                            {
                                string cfgId = cfgR["configId"]?.ToString() ?? "";
                                decimal cfgVal;
                                if (decimal.TryParse(cfgR["configValue"]?.ToString(), out cfgVal))
                                {
                                    if (cfgId == "CONFIG004") unitPassMark = cfgVal;
                                    else if (cfgId == "CONFIG005") levelPassMark = cfgVal;
                                }
                            }
                        }
                    }
                    string weakTitleCol = CurrentLanguage == "BM"
                        ? "COALESCE(q.[quizTitleBM], q.[quizTitleEN], 'Quiz')"
                        : "COALESCE(q.[quizTitleEN], q.[quizTitleBM], 'Quiz')";
                    string weakUnitCol = CurrentLanguage == "BM"
                        ? "COALESCE(u.[unitNameBM], u.[unitNameEN], '')"
                        : "COALESCE(u.[unitNameEN], u.[unitNameBM], '')";
                    string weakLevelCol = CurrentLanguage == "BM"
                        ? "COALESCE(lv.[levelNameBM], lv.[levelNameEN], '')"
                        : "COALESCE(lv.[levelNameEN], lv.[levelNameBM], '')";
                    var wRows = new List<object>();
                    bool hasNoQuizAttempts = false;
                    using (var wCmd = new SqlCommand(@"
                        SELECT quizName, quizType, percentage, scopeName FROM (
                            SELECT " + weakTitleCol + @" AS quizName, q.[quizType],
                                   qr.[percentage],
                                   CASE WHEN q.[quizType]='Unit' THEN " + weakUnitCol + @"
                                        ELSE " + weakLevelCol + @" END AS scopeName,
                                   ROW_NUMBER() OVER(PARTITION BY qr.[quizId] ORDER BY qr.[attemptedDate] DESC, qr.[attemptNo] DESC) AS rn
                            FROM dbo.[QuizResult] qr
                            INNER JOIN dbo.[Quiz] q ON q.[quizId]=qr.[quizId]
                            LEFT JOIN dbo.[Unit] u ON u.[unitId]=q.[unitId]
                            LEFT JOIN dbo.[Level] lv ON lv.[levelId]=q.[levelId]
                            WHERE qr.[studentId]=@s AND q.[quizType] IN ('Unit','Level')
                        ) sub WHERE rn=1
                        ORDER BY quizType, quizName", c))
                    {
                        wCmd.Parameters.AddWithValue("@s", sid);
                        int totalAttemptedQuizzes = 0;
                        using (var wR = wCmd.ExecuteReader())
                        {
                            while (wR.Read())
                            {
                                totalAttemptedQuizzes++;
                                string qName = wR["quizName"]?.ToString() ?? "";
                                string qType = wR["quizType"]?.ToString() ?? "";
                                string scopeName = wR["scopeName"]?.ToString() ?? "";
                                decimal pctVal = wR["percentage"] != DBNull.Value ? Convert.ToDecimal(wR["percentage"]) : 0;
                                decimal passMark = qType == "Unit" ? unitPassMark : levelPassMark;
                                if (pctVal < passMark)
                                {
                                    wRows.Add(new {
                                        quizType = qType,
                                        scopeLabel = qType == "Unit" ? T("Unit Quiz","Kuiz Unit") : T("Level Quiz","Kuiz Tahap"),
                                        scopeName = scopeName,
                                        quizName = qName,
                                        latestPct = pctVal.ToString("0.0") + "%",
                                        passMarkStr = passMark.ToString("0") + "%",
                                        statusLabel = T("Needs Improvement","Perlu Peningkatan")
                                    });
                                }
                            }
                        }
                        // Three states: no attempts, has weak topics, all passed
                        bool hasNoAttemptsLocal = (totalAttemptedQuizzes == 0);
                        hasNoQuizAttempts = hasNoAttemptsLocal;
                        if (hasNoAttemptsLocal)
                        {
                            pnlWeakNoAttempts.Visible = true; pnlWeakEmpty.Visible = false;
                        }
                        else if (wRows.Count > 0)
                        {
                            rptWeak.DataSource = wRows; rptWeak.DataBind();
                            pnlWeakEmpty.Visible = false; pnlWeakNoAttempts.Visible = false;
                        }
                        else
                        {
                            pnlWeakEmpty.Visible = true; pnlWeakNoAttempts.Visible = false;
                        }
                    }

                    // Certificates
                    var certs = new List<object>();
                    try
                    {
                        string titleCol = CurrentLanguage == "BM" ? "c.[certificateTitleBM]" : "c.[certificateTitleEN]";
                        string descCol = CurrentLanguage == "BM" ? "c.[certificateDescriptionBM]" : "c.[certificateDescriptionEN]";
                        using (var cmd = new SqlCommand("SELECT COALESCE(" + titleCol + ",c.[certificateTitleEN],'Certificate') AS title, COALESCE(" + descCol + ",c.[certificateDescriptionEN],'') AS descr, COALESCE(lv.[levelNameEN],'-') AS lvl, c.[issuedDate], c.[status] FROM dbo.[Certificate] c LEFT JOIN dbo.[Level] lv ON lv.[levelId]=c.[levelId] WHERE c.[studentId]=@s ORDER BY c.[issuedDate] DESC", c))
                        { cmd.Parameters.AddWithValue("@s", sid); using (var r = cmd.ExecuteReader()) while (r.Read()) { string dt = r["issuedDate"] != DBNull.Value ? Convert.ToDateTime(r["issuedDate"]).ToString("d MMM yyyy") : "-"; string st = r["status"]?.ToString() ?? ""; certs.Add(new { title = r["title"].ToString(), description = r["descr"].ToString(), level = r["lvl"].ToString(), date = dt, status = st, statusCss = st == "Active" ? "active" : "pending" }); } }
                    }
                    catch { }
                    if (certs.Count > 0) { rptCerts.DataSource = certs; rptCerts.DataBind(); pnlCertEmpty.Visible = false; } else { pnlCertEmpty.Visible = true; }

                    // Populate performance summary
                    litInsLessons.Text = HttpUtility.HtmlEncode(doneL + " / " + totalL);
                    int weakUnitCount = 0, weakLevelCount = 0;
                    foreach (var w in wRows)
                    {
                        string wt = ((dynamic)w).quizType;
                        if (wt == "Unit") weakUnitCount++; else weakLevelCount++;
                    }
                    litInsWeakUnit.Text = weakUnitCount.ToString();
                    litInsWeakLevel.Text = weakLevelCount.ToString();
                    litInsCerts.Text = certs.Count.ToString();

                    Insight(weakUnitCount, weakLevelCount, hasNoQuizAttempts);
                }
                pnlMain.Visible = true; pnlError.Visible = false;
            }
            catch { ShowError(T("Error loading student data.", "Ralat memuatkan data pelajar.")); }
        }

        private decimal Avg(SqlConnection c, string sid, string qt) { using (var cmd = new SqlCommand("SELECT AVG(CAST(qr.[percentage] AS DECIMAL(5,2))) FROM dbo.[QuizResult] qr INNER JOIN dbo.[Quiz] q ON q.[quizId]=qr.[quizId] WHERE qr.[studentId]=@s AND q.[quizType]=@t", c)) { cmd.Parameters.AddWithValue("@s", sid); cmd.Parameters.AddWithValue("@t", qt); var v = cmd.ExecuteScalar(); return (v != null && v != DBNull.Value) ? Convert.ToDecimal(v) : -1; } }

        private void BindQuiz(SqlConnection c, string sid, string qt, Repeater rpt, System.Web.UI.WebControls.Panel pnlTable, System.Web.UI.WebControls.Panel pnlEmpty) { bool isBM = CurrentLanguage == "BM"; string titleCol = isBM ? "COALESCE(q.[quizTitleBM], q.[quizTitleEN], 'Quiz')" : "COALESCE(q.[quizTitleEN], q.[quizTitleBM], 'Quiz')"; var rows = new List<object>(); using (var cmd = new SqlCommand(@"SELECT quizName,score,totalMarks,percentage,resultStatus,attemptNo,attemptedDate,resultId,correctCount,wrongCount FROM(SELECT " + titleCol + @" AS quizName,qr.[score],qr.[totalMarks],qr.[percentage],qr.[resultStatus],qr.[attemptNo],qr.[attemptedDate],qr.[resultId],(SELECT COUNT(*) FROM dbo.[QuizAnswer] qa WHERE qa.[resultId]=qr.[resultId] AND qa.[isCorrect]=1) AS correctCount,(SELECT COUNT(*) FROM dbo.[QuizAnswer] qa WHERE qa.[resultId]=qr.[resultId] AND qa.[isCorrect]=0) AS wrongCount,ROW_NUMBER() OVER(PARTITION BY qr.[quizId] ORDER BY qr.[attemptedDate] DESC,qr.[attemptNo] DESC) AS rn FROM dbo.[QuizResult] qr INNER JOIN dbo.[Quiz] q ON q.[quizId]=qr.[quizId] WHERE qr.[studentId]=@s AND q.[quizType]=@t) sub WHERE rn=1 ORDER BY attemptedDate DESC", c)) { cmd.Parameters.AddWithValue("@s", sid); cmd.Parameters.AddWithValue("@t", qt); using (var r = cmd.ExecuteReader()) while (r.Read()) { string dt = r["attemptedDate"] != DBNull.Value ? Convert.ToDateTime(r["attemptedDate"]).ToString("d MMM yyyy") : "-"; string pct = r["percentage"] != DBNull.Value ? Convert.ToDecimal(r["percentage"]).ToString("0.0") + "%" : "-"; string sc = r["score"] != DBNull.Value ? Convert.ToDecimal(r["score"]).ToString("0") + "/" + Convert.ToDecimal(r["totalMarks"]).ToString("0") : "-"; string res = r["resultStatus"]?.ToString() ?? "-"; int corr = r["correctCount"] != DBNull.Value ? Convert.ToInt32(r["correctCount"]) : 0; int wrng = r["wrongCount"] != DBNull.Value ? Convert.ToInt32(r["wrongCount"]) : 0; rows.Add(new { quizName = r["quizName"].ToString(), score = sc, pct, result = res == "Passed" ? T("Passed","Lulus") : T("Failed","Gagal"), resCss = res == "Passed" ? "pass" : "fail", attempts = r["attemptNo"]?.ToString() ?? "1", date = dt, resultId = r["resultId"].ToString(), correctCount = corr, wrongCount = wrng }); } } if (rows.Count > 0) { pnlTable.Visible = true; pnlEmpty.Visible = false; rpt.DataSource = rows; rpt.DataBind(); } else { pnlTable.Visible = false; pnlEmpty.Visible = true; } }

        private void Insight(int weakUnit, int weakLevel, bool noAttempts)
        {
            string rec;
            if (noAttempts)
                rec = T("Encourage the student to attempt a Unit or Level quiz so their performance can be evaluated.", "Galakkan pelajar mencuba Kuiz Unit atau Kuiz Level supaya prestasi mereka dapat dinilai.");
            else if (weakUnit > 0 && weakLevel > 0)
                rec = T("Review the failed Unit and Level topics before reattempting the quizzes.", "Ulang kaji topik Unit dan Level yang gagal sebelum mencuba semula kuiz.");
            else if (weakUnit > 0)
                rec = T("Review the failed Unit topics before reattempting the Unit quizzes.", "Ulang kaji topik Unit yang gagal sebelum mencuba semula Kuiz Unit.");
            else if (weakLevel > 0)
                rec = T("Review the failed Level topics before reattempting the Level quizzes.", "Ulang kaji topik Level yang gagal sebelum mencuba semula Kuiz Level.");
            else
                rec = T("Excellent progress. Continue completing the remaining lessons and maintain your performance.", "Prestasi yang cemerlang. Teruskan menyelesaikan pelajaran yang masih belum lengkap dan kekalkan prestasi anda.");
            litInsight.Text = HttpUtility.HtmlEncode(rec);
        }

        private void ShowError(string m) { pnlError.Visible = true; pnlMain.Visible = false; litErrMsg.Text = HttpUtility.HtmlEncode(m); }
        private static string Ini(string n) { if (string.IsNullOrWhiteSpace(n)) return "S"; var p = n.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries); return p.Length >= 2 ? (p[0][0].ToString() + p[p.Length - 1][0].ToString()).ToUpper() : n.Trim()[0].ToString().ToUpper(); }

        private static string SortLetters(string val, string fallback)
        {
            if (string.IsNullOrEmpty(val) || val == "-") return fallback;
            // Split by common delimiters, filter to single letters, sort alphabetically
            var letters = val.Split(new[] { ',', ';', ' ', '|' }, StringSplitOptions.RemoveEmptyEntries);
            var sorted = new List<string>();
            foreach (var l in letters) { string t = l.Trim().ToUpper(); if (!string.IsNullOrEmpty(t)) sorted.Add(t); }
            sorted.Sort();
            return sorted.Count > 0 ? string.Join(", ", sorted) : fallback;
        }
    }
}
