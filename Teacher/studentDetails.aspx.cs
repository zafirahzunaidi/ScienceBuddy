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
            if (string.IsNullOrEmpty(resultId)) { Response.Write("<div class=\"sd-empty\">Invalid request.</div>"); Response.End(); return; }
            try
            {
                using (var c = new SqlConnection(ConnStr))
                {
                    c.Open();
                    var sb = new System.Text.StringBuilder();
                    using (var cmd = new SqlCommand(@"SELECT qst.[questionTextEN], qa.[selectedAnswer], qst.[correctAnswer], qa.[isCorrect]
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
                                string qText = r["questionTextEN"]?.ToString() ?? "";
                                string selected = r["selectedAnswer"] != DBNull.Value ? r["selectedAnswer"].ToString() : "-";
                                string correct = r["correctAnswer"]?.ToString() ?? "-";
                                bool isCorrect = r["isCorrect"] != DBNull.Value && Convert.ToBoolean(r["isCorrect"]);
                                string statusLabel = isCorrect ? T("Correct", "Betul") : T("Wrong", "Salah");
                                string badgeCss = isCorrect ? "correct" : "wrong";

                                sb.Append("<div class=\"sd-ans-card\">");
                                sb.AppendFormat("<div class=\"sd-ans-q\">Q{0}. {1}</div>", qNum, HttpUtility.HtmlEncode(qText));
                                sb.Append("<div class=\"sd-ans-row\">");
                                sb.AppendFormat("<span><strong>{0}:</strong> {1}</span>", T("Student's Answer", "Jawapan Pelajar"), HttpUtility.HtmlEncode(selected));
                                sb.AppendFormat("<span><strong>{0}:</strong> {1}</span>", T("Correct Answer", "Jawapan Betul"), HttpUtility.HtmlEncode(correct));
                                sb.AppendFormat("<span class=\"sd-ans-badge {0}\">{1}</span>", badgeCss, statusLabel);
                                sb.Append("</div></div>");
                            }
                            if (qNum == 0) sb.AppendFormat("<div class=\"sd-empty\">{0}</div>", T("No answer records found.", "Tiada rekod jawapan dijumpai."));
                        }
                    }
                    Response.Write(sb.ToString());
                }
            }
            catch { Response.Write("<div class=\"sd-empty\">" + T("Error loading answers.", "Ralat memuatkan jawapan.") + "</div>"); }
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
                    using (var cmd = new SqlCommand("SELECT les.[lessonTitleEN],lp.[isCompleted],lp.[completedDate] FROM dbo.[LessonProgress] lp INNER JOIN dbo.[Lesson] les ON les.[lessonId]=lp.[lessonId] WHERE lp.[studentId]=@s ORDER BY lp.[completedDate] DESC", c))
                    { cmd.Parameters.AddWithValue("@s", sid); using (var r = cmd.ExecuteReader()) while (r.Read()) { bool d = r["isCompleted"] != DBNull.Value && Convert.ToBoolean(r["isCompleted"]); string dt = r["completedDate"] != DBNull.Value ? Convert.ToDateTime(r["completedDate"]).ToString("d MMM yyyy") : "-"; lRows.Add(new { lesson = r["lessonTitleEN"].ToString(), status = d ? T("Completed", "Selesai") : T("Incomplete", "Belum Selesai"), statusCss = d ? "done" : "inc", date = dt }); } }
                    if (lRows.Count > 0) { rptLessons.DataSource = lRows; rptLessons.DataBind(); }

                    BindQuiz(c, sid, "Unit", rptUnitQuiz);
                    BindQuiz(c, sid, "Level", rptLevelQuiz);

                    // Weak Subtopics
                    var wRows = new List<object>();
                    using (var cmd = new SqlCommand(@"SELECT COALESCE(st.[subtopicTitleEN],'Subtopic') AS sub, SUM(CASE WHEN qa.[isCorrect]=1 THEN 1 ELSE 0 END) AS cor, SUM(CASE WHEN qa.[isCorrect]=0 THEN 1 ELSE 0 END) AS wrg FROM dbo.[QuizAnswer] qa INNER JOIN dbo.[QuizResult] qr ON qr.[resultId]=qa.[resultId] INNER JOIN dbo.[Quiz] q ON q.[quizId]=qr.[quizId] INNER JOIN dbo.[Question] qst ON qst.[questionId]=qa.[questionId] INNER JOIN dbo.[Subtopic] st ON st.[subtopicId]=qst.[subtopicId] WHERE qr.[studentId]=@s AND q.[quizType] IN ('Unit','Level') GROUP BY st.[subtopicId],st.[subtopicTitleEN] HAVING SUM(CASE WHEN qa.[isCorrect]=0 THEN 1 ELSE 0 END)>0 ORDER BY wrg DESC", c))
                    { cmd.Parameters.AddWithValue("@s", sid); using (var r = cmd.ExecuteReader()) while (r.Read()) { int cor = Convert.ToInt32(r["cor"]), wrg = Convert.ToInt32(r["wrg"]), tot = cor + wrg; int gPct = tot > 0 ? (int)Math.Round((decimal)cor / tot * 100) : 0; wRows.Add(new { subtopic = r["sub"].ToString(), correctCount = cor, wrongCount = wrg, greenPct = gPct, redPct = 100 - gPct }); } }
                    if (wRows.Count > 0) { rptWeak.DataSource = wRows; rptWeak.DataBind(); pnlWeakEmpty.Visible = false; } else { pnlWeakEmpty.Visible = true; }

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

                    Insight(name, uAvg, lAvg, wRows, LessonPct);
                }
                pnlMain.Visible = true; pnlError.Visible = false;
            }
            catch { ShowError(T("Error loading student data.", "Ralat memuatkan data pelajar.")); }
        }

        private decimal Avg(SqlConnection c, string sid, string qt) { using (var cmd = new SqlCommand("SELECT AVG(CAST(qr.[percentage] AS DECIMAL(5,2))) FROM dbo.[QuizResult] qr INNER JOIN dbo.[Quiz] q ON q.[quizId]=qr.[quizId] WHERE qr.[studentId]=@s AND q.[quizType]=@t", c)) { cmd.Parameters.AddWithValue("@s", sid); cmd.Parameters.AddWithValue("@t", qt); var v = cmd.ExecuteScalar(); return (v != null && v != DBNull.Value) ? Convert.ToDecimal(v) : -1; } }

        private void BindQuiz(SqlConnection c, string sid, string qt, Repeater rpt) { var rows = new List<object>(); using (var cmd = new SqlCommand(@"SELECT quizName,score,totalMarks,percentage,resultStatus,attemptNo,attemptedDate,resultId,correctCount,wrongCount FROM(SELECT COALESCE(q.[quizTitleEN],'Quiz') AS quizName,qr.[score],qr.[totalMarks],qr.[percentage],qr.[resultStatus],qr.[attemptNo],qr.[attemptedDate],qr.[resultId],(SELECT COUNT(*) FROM dbo.[QuizAnswer] qa WHERE qa.[resultId]=qr.[resultId] AND qa.[isCorrect]=1) AS correctCount,(SELECT COUNT(*) FROM dbo.[QuizAnswer] qa WHERE qa.[resultId]=qr.[resultId] AND qa.[isCorrect]=0) AS wrongCount,ROW_NUMBER() OVER(PARTITION BY qr.[quizId] ORDER BY qr.[attemptedDate] DESC,qr.[attemptNo] DESC) AS rn FROM dbo.[QuizResult] qr INNER JOIN dbo.[Quiz] q ON q.[quizId]=qr.[quizId] WHERE qr.[studentId]=@s AND q.[quizType]=@t) sub WHERE rn=1 ORDER BY attemptedDate DESC", c)) { cmd.Parameters.AddWithValue("@s", sid); cmd.Parameters.AddWithValue("@t", qt); using (var r = cmd.ExecuteReader()) while (r.Read()) { string dt = r["attemptedDate"] != DBNull.Value ? Convert.ToDateTime(r["attemptedDate"]).ToString("d MMM yyyy") : "-"; string pct = r["percentage"] != DBNull.Value ? Convert.ToDecimal(r["percentage"]).ToString("0.0") + "%" : "-"; string sc = r["score"] != DBNull.Value ? Convert.ToDecimal(r["score"]).ToString("0") + "/" + Convert.ToDecimal(r["totalMarks"]).ToString("0") : "-"; string res = r["resultStatus"]?.ToString() ?? "-"; int corr = r["correctCount"] != DBNull.Value ? Convert.ToInt32(r["correctCount"]) : 0; int wrng = r["wrongCount"] != DBNull.Value ? Convert.ToInt32(r["wrongCount"]) : 0; rows.Add(new { quizName = r["quizName"].ToString(), score = sc, pct, result = res, resCss = res == "Passed" ? "pass" : "fail", attempts = r["attemptNo"]?.ToString() ?? "1", date = dt, resultId = r["resultId"].ToString(), correctCount = corr, wrongCount = wrng }); } } if (rows.Count > 0) { rpt.DataSource = rows; rpt.DataBind(); } }

        private void Insight(string name, decimal u, decimal l, List<object> weak, int lPct) { var ins = new List<string>(); if (u >= 80 && l >= 80) ins.Add(T("Excellent! " + name + " is performing strongly in main quizzes.", "Cemerlang! " + name + " menunjukkan prestasi mantap.")); else if (u >= 60 && l >= 60) ins.Add(T(name + " shows good progress.", name + " menunjukkan kemajuan baik.")); if (u >= 0 && u < 50) ins.Add(T("Unit Quiz below 50%. Targeted revision recommended.", "Kuiz Unit bawah 50%. Ulang kaji bersasar disyorkan.")); if (l >= 0 && l < 50) ins.Add(T("Level Quiz needs improvement.", "Kuiz Tahap perlu ditingkatkan.")); if (lPct >= 80) ins.Add(T("Great lesson completion!", "Penyelesaian pelajaran hebat!")); else if (lPct < 30) ins.Add(T("Low lesson completion.", "Penyelesaian pelajaran rendah.")); if (weak.Count > 0) { string top = ((dynamic)weak[0]).subtopic; ins.Add(T("Weak in: " + top + ". Assign revision materials.", "Lemah dalam: " + top + ". Berikan bahan ulang kaji.")); } else ins.Add(T("No weak subtopics detected.", "Tiada subtopik lemah dikesan.")); if (ins.Count == 0) ins.Add(T("No issues detected.", "Tiada isu dikesan.")); litInsight.Text = string.Join("<br/>", ins); }

        private void ShowError(string m) { pnlError.Visible = true; pnlMain.Visible = false; litErrMsg.Text = HttpUtility.HtmlEncode(m); }
        private static string Ini(string n) { if (string.IsNullOrWhiteSpace(n)) return "S"; var p = n.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries); return p.Length >= 2 ? (p[0][0].ToString() + p[p.Length - 1][0].ToString()).ToUpper() : n.Trim()[0].ToString().ToUpper(); }
    }
}
