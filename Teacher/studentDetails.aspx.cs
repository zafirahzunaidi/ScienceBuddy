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
    public partial class studentDetails : Page
    {
        protected string CurrentLanguage
        { get { string l = Session["preferredLanguage"] as string; return string.IsNullOrEmpty(l) ? "EN" : l; } }
        protected string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"]?.ToString() != "Teacher")
            { Response.Redirect("~/Login.aspx", false); Context.ApplicationInstance.CompleteRequest(); return; }
            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                string sid = (Request.QueryString["studentId"] ?? "").Trim();
                if (string.IsNullOrEmpty(sid)) { ShowError(T("No student specified.", "Tiada pelajar dinyatakan.")); return; }
                LoadStudentDetails(sid);
            }
        }

        private void LoadStudentDetails(string studentId)
        {
            try
            {
                using (var c = new SqlConnection(ConnStr))
                {
                    c.Open();
                    // ── Student Profile ───────────────────────────────
                    string name = "", sid = studentId, levelName = "-";
                    using (var cmd = new SqlCommand(@"
                        SELECT s.[name], s.[studentId],
                            COALESCE(lv.[levelNameEN],'-') AS levelName
                        FROM dbo.[Student] s
                        INNER JOIN dbo.[User] u ON u.[userId]=s.[userId]
                        LEFT JOIN dbo.[Level] lv ON lv.[levelId]=s.[currentLevelId]
                        WHERE s.[studentId]=@sid AND u.[status]='Active'", c))
                    {
                        cmd.Parameters.AddWithValue("@sid", studentId);
                        using (var r = cmd.ExecuteReader())
                        {
                            if (!r.Read()) { ShowError(T("Student not found.", "Pelajar tidak dijumpai.")); return; }
                            name = r["name"]?.ToString() ?? "Student";
                            sid = r["studentId"].ToString();
                            levelName = r["levelName"].ToString();
                        }
                    }
                    litName.Text = HttpUtility.HtmlEncode(name);
                    litStudentId.Text = HttpUtility.HtmlEncode(sid);
                    litLevel.Text = HttpUtility.HtmlEncode(levelName);
                    litInitials.Text = HttpUtility.HtmlEncode(Ini(name));

                    // Total lessons
                    int totalL = 0;
                    using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[Lesson]", c))
                        totalL = Convert.ToInt32(cmd.ExecuteScalar());

                    // Completed lessons
                    int doneL = 0;
                    using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[LessonProgress] WHERE [studentId]=@s AND [isCompleted]=1", c))
                    { cmd.Parameters.AddWithValue("@s", studentId); doneL = Convert.ToInt32(cmd.ExecuteScalar()); }
                    litLessons.Text = doneL + " / " + totalL;

                    // Unit Quiz Avg
                    decimal uAvg = GetAvg(c, studentId, "Unit");
                    litUnitAvg.Text = uAvg >= 0 ? uAvg.ToString("0.0") + "%" : T("No Attempt", "Tiada Cubaan");

                    // Level Quiz Avg
                    decimal lAvg = GetAvg(c, studentId, "Level");
                    litLevelAvg.Text = lAvg >= 0 ? lAvg.ToString("0.0") + "%" : T("No Attempt", "Tiada Cubaan");

                    // Failed Questions
                    int failedQ = 0;
                    using (var cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM dbo.[QuizAnswer] qa INNER JOIN dbo.[QuizResult] qr ON qr.[resultId]=qa.[resultId] INNER JOIN dbo.[Quiz] q ON q.[quizId]=qr.[quizId] WHERE qr.[studentId]=@s AND qa.[isCorrect]=0 AND q.[quizType] IN ('Unit','Level')", c))
                    { cmd.Parameters.AddWithValue("@s", studentId); failedQ = Convert.ToInt32(cmd.ExecuteScalar()); }
                    litFailedQ.Text = failedQ.ToString();

                    // Weak Subtopics count
                    int weakCnt = 0;
                    using (var cmd = new SqlCommand(
                        "SELECT COUNT(DISTINCT qst.[subtopicId]) FROM dbo.[QuizAnswer] qa INNER JOIN dbo.[QuizResult] qr ON qr.[resultId]=qa.[resultId] INNER JOIN dbo.[Quiz] q ON q.[quizId]=qr.[quizId] INNER JOIN dbo.[Question] qst ON qst.[questionId]=qa.[questionId] WHERE qr.[studentId]=@s AND qa.[isCorrect]=0 AND q.[quizType] IN ('Unit','Level') AND qst.[subtopicId] IS NOT NULL", c))
                    { cmd.Parameters.AddWithValue("@s", studentId); weakCnt = Convert.ToInt32(cmd.ExecuteScalar()); }
                    litWeakSub.Text = weakCnt.ToString();

                    // ── Lesson Progress Table ─────────────────────────
                    var lessonRows = new List<object>();
                    using (var cmd = new SqlCommand(@"
                        SELECT les.[lessonTitleEN], lp.[isCompleted], lp.[completedDate]
                        FROM dbo.[LessonProgress] lp
                        INNER JOIN dbo.[Lesson] les ON les.[lessonId]=lp.[lessonId]
                        WHERE lp.[studentId]=@s ORDER BY lp.[completedDate] DESC", c))
                    {
                        cmd.Parameters.AddWithValue("@s", studentId);
                        using (var r = cmd.ExecuteReader())
                            while (r.Read())
                            {
                                bool done = r["isCompleted"] != DBNull.Value && Convert.ToBoolean(r["isCompleted"]);
                                string dt = r["completedDate"] != DBNull.Value ? Convert.ToDateTime(r["completedDate"]).ToString("d MMM yyyy") : "-";
                                lessonRows.Add(new { lesson = r["lessonTitleEN"].ToString(), status = done ? "Completed" : "Incomplete", statusCss = done ? "done" : "inc", date = dt });
                            }
                    }
                    if (lessonRows.Count > 0) { rptLessons.DataSource = lessonRows; rptLessons.DataBind(); }

                    // ── Unit Quiz Results ──────────────────────────────
                    BindQuizResults(c, studentId, "Unit", rptUnitQuiz);

                    // ── Level Quiz Results ─────────────────────────────
                    BindQuizResults(c, studentId, "Level", rptLevelQuiz);

                    // ── Failed Questions Detail ───────────────────────
                    var failedRows = new List<object>();
                    using (var cmd = new SqlCommand(@"
                        SELECT qst.[questionTextEN] AS question,
                            qst.[correctAnswer], qa.[selectedAnswer],
                            COALESCE(st.[subtopicTitleEN],'') AS subtopic
                        FROM dbo.[QuizAnswer] qa
                        INNER JOIN dbo.[QuizResult] qr ON qr.[resultId]=qa.[resultId]
                        INNER JOIN dbo.[Quiz] q ON q.[quizId]=qr.[quizId]
                        INNER JOIN dbo.[Question] qst ON qst.[questionId]=qa.[questionId]
                        LEFT JOIN dbo.[Subtopic] st ON st.[subtopicId]=qst.[subtopicId]
                        WHERE qr.[studentId]=@s AND qa.[isCorrect]=0 AND q.[quizType] IN ('Unit','Level')
                        ORDER BY st.[subtopicTitleEN]", c))
                    {
                        cmd.Parameters.AddWithValue("@s", studentId);
                        using (var r = cmd.ExecuteReader())
                            while (r.Read())
                                failedRows.Add(new { question = r["question"]?.ToString() ?? "", correctAnswer = r["correctAnswer"]?.ToString() ?? "", studentAnswer = r["selectedAnswer"]?.ToString() ?? "", subtopic = r["subtopic"]?.ToString() ?? "-" });
                    }
                    if (failedRows.Count > 0) { rptFailed.DataSource = failedRows; rptFailed.DataBind(); pnlFailedEmpty.Visible = false; }
                    else { pnlFailedEmpty.Visible = true; }

                    // ── Weak Subtopics ─────────────────────────────────
                    var weakRows = new List<object>();
                    using (var cmd = new SqlCommand(@"
                        SELECT COALESCE(st.[subtopicTitleEN],'Subtopic') AS subtopic, COUNT(*) AS wrongCount
                        FROM dbo.[QuizAnswer] qa
                        INNER JOIN dbo.[QuizResult] qr ON qr.[resultId]=qa.[resultId]
                        INNER JOIN dbo.[Quiz] q ON q.[quizId]=qr.[quizId]
                        INNER JOIN dbo.[Question] qst ON qst.[questionId]=qa.[questionId]
                        INNER JOIN dbo.[Subtopic] st ON st.[subtopicId]=qst.[subtopicId]
                        WHERE qr.[studentId]=@s AND qa.[isCorrect]=0 AND q.[quizType] IN ('Unit','Level')
                        GROUP BY st.[subtopicId], st.[subtopicTitleEN]
                        ORDER BY wrongCount DESC", c))
                    {
                        cmd.Parameters.AddWithValue("@s", studentId);
                        using (var r = cmd.ExecuteReader())
                            while (r.Read())
                                weakRows.Add(new { subtopic = r["subtopic"].ToString(), wrongCount = Convert.ToInt32(r["wrongCount"]) });
                    }
                    if (weakRows.Count > 0) { rptWeak.DataSource = weakRows; rptWeak.DataBind(); pnlWeakEmpty.Visible = false; }
                    else { pnlWeakEmpty.Visible = true; }

                    // ── Teacher Insight ────────────────────────────────
                    GenerateInsight(doneL, totalL, uAvg, lAvg, failedQ, weakCnt);
                }
                pnlMain.Visible = true; pnlError.Visible = false;
            }
            catch (Exception ex)
            {
                ShowError(T("Error loading student data.", "Ralat memuatkan data pelajar."));
            }
        }

        private decimal GetAvg(SqlConnection c, string studentId, string quizType)
        {
            using (var cmd = new SqlCommand(
                "SELECT AVG(CAST(qr.[percentage] AS DECIMAL(5,2))) FROM dbo.[QuizResult] qr INNER JOIN dbo.[Quiz] q ON q.[quizId]=qr.[quizId] WHERE qr.[studentId]=@s AND q.[quizType]=@t", c))
            {
                cmd.Parameters.AddWithValue("@s", studentId);
                cmd.Parameters.AddWithValue("@t", quizType);
                var v = cmd.ExecuteScalar();
                return (v != null && v != DBNull.Value) ? Convert.ToDecimal(v) : -1;
            }
        }

        private void BindQuizResults(SqlConnection c, string studentId, string quizType, Repeater rpt)
        {
            var rows = new List<object>();
            using (var cmd = new SqlCommand(@"
                SELECT COALESCE(q.[quizTitleEN],'Quiz') AS quizName,
                    qr.[score], qr.[totalMarks], qr.[percentage],
                    qr.[resultStatus], qr.[attemptNo], qr.[attemptedDate]
                FROM dbo.[QuizResult] qr
                INNER JOIN dbo.[Quiz] q ON q.[quizId]=qr.[quizId]
                WHERE qr.[studentId]=@s AND q.[quizType]=@t
                ORDER BY qr.[attemptedDate] DESC", c))
            {
                cmd.Parameters.AddWithValue("@s", studentId);
                cmd.Parameters.AddWithValue("@t", quizType);
                using (var r = cmd.ExecuteReader())
                    while (r.Read())
                    {
                        string dt = r["attemptedDate"] != DBNull.Value ? Convert.ToDateTime(r["attemptedDate"]).ToString("d MMM yyyy") : "-";
                        string pct = r["percentage"] != DBNull.Value ? Convert.ToDecimal(r["percentage"]).ToString("0.0") + "%" : "-";
                        string score = r["score"] != DBNull.Value ? Convert.ToDecimal(r["score"]).ToString("0") + "/" + Convert.ToDecimal(r["totalMarks"]).ToString("0") : "-";
                        string result = r["resultStatus"]?.ToString() ?? "-";
                        string resCss = result == "Passed" ? "pass" : "fail";
                        rows.Add(new { quizName = r["quizName"].ToString(), score, pct, result, resCss, attempt = r["attemptNo"]?.ToString() ?? "1", date = dt });
                    }
            }
            if (rows.Count > 0) { rpt.DataSource = rows; rpt.DataBind(); }
        }

        private void GenerateInsight(int doneL, int totalL, decimal uAvg, decimal lAvg, int failedQ, int weakCnt)
        {
            var insights = new List<string>();
            decimal pct = totalL > 0 ? (decimal)doneL / totalL * 100 : 0;
            if (pct >= 80) insights.Add(T("Excellent lesson completion.", "Penyelesaian pelajaran cemerlang."));
            else if (pct < 30) insights.Add(T("Low lesson completion. Encourage the student.", "Penyelesaian pelajaran rendah. Galakkan pelajar."));

            if (uAvg >= 0 && uAvg < 50) insights.Add(T("Needs improvement in Unit Quiz.", "Perlu peningkatan dalam Kuiz Unit."));
            if (lAvg >= 0 && lAvg < 50) insights.Add(T("Needs improvement in Level Quiz.", "Perlu peningkatan dalam Kuiz Tahap."));
            if (uAvg >= 80 && lAvg >= 80) insights.Add(T("Strong quiz performance overall.", "Prestasi kuiz keseluruhan mantap."));

            if (weakCnt > 0) insights.Add(T("Consider assigning revision materials for weak subtopics.", "Pertimbangkan bahan ulang kaji untuk subtopik lemah."));
            if (failedQ > 10) insights.Add(T("Frequently incorrect answers detected. Schedule a review session.", "Jawapan salah yang kerap dikesan. Jadualkan sesi ulang kaji."));

            if (insights.Count == 0) insights.Add(T("No major issues detected.", "Tiada isu besar dikesan."));
            litInsight.Text = string.Join("<br/>", insights);
        }

        private void ShowError(string msg)
        {
            pnlError.Visible = true; pnlMain.Visible = false;
            litErrMsg.Text = HttpUtility.HtmlEncode(msg);
        }

        private static string Ini(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "S";
            var p = name.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            return p.Length >= 2 ? (p[0][0].ToString() + p[p.Length - 1][0].ToString()).ToUpper() : name.Trim()[0].ToString().ToUpper();
        }
    }
}
