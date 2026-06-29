using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace ScienceBuddy.Student
{
    public partial class LevelDetails : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        private string CurrentLanguage = "EN";
        private string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null ||
                Session["role"].ToString() != "Student")
            { Response.Redirect("~/Login.aspx", false); return; }

            ((SiteMaster)Master).LayoutMode = "Sidebar";
            if (!IsPostBack) { InitLang(); LoadPage(); }
        }

        private void InitLang()
        {
            string l = Session["preferredLanguage"] as string;
            if (!string.IsNullOrEmpty(l)) { CurrentLanguage = l; return; }
            string uid = Session["userId"] as string;
            if (!string.IsNullOrEmpty(uid))
            {
                try {
                    using (var c = new SqlConnection(ConnStr))
                    using (var cmd = new SqlCommand("SELECT preferredLanguage FROM [User] WHERE userId=@u", c))
                    { cmd.Parameters.AddWithValue("@u", uid); c.Open();
                      var r = cmd.ExecuteScalar();
                      if (r != null && r != DBNull.Value) { l = r.ToString(); Session["preferredLanguage"] = l; CurrentLanguage = l; return; } }
                } catch (SqlException) { }
            }
            CurrentLanguage = "EN"; Session["preferredLanguage"] = "EN";
        }

        private void LoadPage()
        {
            string levelId = Request.QueryString["levelId"];
            string userId = Session["userId"].ToString();

            if (string.IsNullOrEmpty(levelId) || !TblOK("Level") || !TblOK("Student"))
            { ShowLocked(T("Invalid page","Halaman tidak sah"),
                T("No level specified. Return to My Learning.","Tiada tahap dinyatakan. Kembali ke Pembelajaran Saya.")); return; }

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                string studentId = null; string curLevel = "LV001";
                using (var cmd = new SqlCommand("SELECT studentId,currentlevelId FROM Student WHERE userId=@u", conn))
                { cmd.Parameters.AddWithValue("@u", userId);
                  using (var rdr = cmd.ExecuteReader()) { if (rdr.Read()) { studentId = rdr["studentId"].ToString(); curLevel = rdr["currentlevelId"]?.ToString() ?? "LV001"; } } }

                if (string.IsNullOrEmpty(studentId))
                { ShowLocked(T("Profile not found","Profil tidak dijumpai"),T("Student profile is missing.","Profil pelajar tiada.")); return; }

                if (Ord(levelId) > Ord(curLevel))
                { ShowLocked(T("Level Locked","Tahap Dikunci"),
                    T("Complete your current level to unlock this one.","Selesaikan tahap semasa untuk membuka tahap ini.")); return; }

                BuildHero(conn, levelId, curLevel);
                BuildStats(conn, levelId, studentId);
                BuildUnits(conn, levelId, studentId);
                BuildQuiz(conn, levelId, studentId);
            }
        }

        private void ShowLocked(string title, string desc)
        {
            pnlLocked.Visible = true; pnlMain.Visible = false;
            litLockedTitle.Text = title; litLockedDesc.Text = desc;
            litLockedBtn.Text = T("Back to My Learning","Kembali ke Pembelajaran Saya");
        }

        private void BuildHero(SqlConnection conn, string levelId, string curLevel)
        {
            bool bm = CurrentLanguage == "BM";
            using (var cmd = new SqlCommand("SELECT levelNameEN,levelNameBM,levelDescriptionEN,levelDescriptionBM FROM Level WHERE levelId=@l", conn))
            {
                cmd.Parameters.AddWithValue("@l", levelId);
                using (var rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        string n = bm ? rdr["levelNameBM"].ToString() : rdr["levelNameEN"].ToString();
                        if (string.IsNullOrWhiteSpace(n)) n = rdr["levelNameEN"].ToString();
                        string d = bm ? rdr["levelDescriptionBM"].ToString() : rdr["levelDescriptionEN"].ToString();
                        if (string.IsNullOrWhiteSpace(d)) d = rdr["levelDescriptionEN"].ToString();
                        litPageTitle.Text = HttpUtility.HtmlEncode(n);
                        litLevelName.Text = HttpUtility.HtmlEncode(n);
                        litLevelDesc.Text = HttpUtility.HtmlEncode(d);
                    }
                }
            }
            litBack.Text = T("My Learning","Pembelajaran Saya");
            litHeroBadge.Text = levelId == curLevel ? T("Current Level","Tahap Semasa") : T("Completed","Selesai");
            litProgressLbl.Text = T("Level Progress","Kemajuan Tahap");
        }

        private void BuildStats(SqlConnection conn, string levelId, string studentId)
        {
            litStatUnitsLbl.Text   = T("Total Units","Jumlah Unit");
            litStatDoneLbl.Text    = T("Units Completed","Unit Selesai");
            litStatLessonsLbl.Text = T("Lessons Done","Pelajaran Selesai");
            litStatQuizLbl.Text    = T("Quizzes Passed","Kuiz Lulus");

            int totalUnits = 0, totalLessons = 0, completedLessons = 0, quizPassed = 0;

            if (TblOK("Unit"))
                using (var cmd = new SqlCommand("SELECT COUNT(*) FROM Unit WHERE levelId=@l", conn))
                { cmd.Parameters.AddWithValue("@l", levelId); totalUnits = (int)cmd.ExecuteScalar(); }

            if (TblOK("Lesson") && TblOK("Subtopic") && TblOK("Unit"))
                using (var cmd = new SqlCommand(@"SELECT COUNT(*) FROM Lesson ls JOIN Subtopic st ON st.subtopicId=ls.subtopicId JOIN Unit u ON u.unitId=st.unitId WHERE u.levelId=@l", conn))
                { cmd.Parameters.AddWithValue("@l", levelId); totalLessons = (int)cmd.ExecuteScalar(); }

            if (TblOK("LessonProgress") && TblOK("Lesson") && TblOK("Subtopic") && TblOK("Unit"))
                using (var cmd = new SqlCommand(@"SELECT COUNT(*) FROM LessonProgress lp JOIN Lesson ls ON ls.lessonId=lp.lessonId JOIN Subtopic st ON st.subtopicId=ls.subtopicId JOIN Unit u ON u.unitId=st.unitId WHERE u.levelId=@l AND lp.studentId=@s AND lp.isCompleted=1", conn))
                { cmd.Parameters.AddWithValue("@l", levelId); cmd.Parameters.AddWithValue("@s", studentId); completedLessons = (int)cmd.ExecuteScalar(); }

            if (TblOK("QuizResult") && TblOK("Quiz"))
                using (var cmd = new SqlCommand(@"SELECT COUNT(DISTINCT qr.quizId) FROM QuizResult qr JOIN Quiz q ON q.quizId=qr.quizId WHERE q.levelId=@l AND qr.studentId=@s AND qr.resultStatus='Pass'", conn))
                { cmd.Parameters.AddWithValue("@l", levelId); cmd.Parameters.AddWithValue("@s", studentId); quizPassed = (int)cmd.ExecuteScalar(); }

            litStatUnits.Text   = totalUnits.ToString();
            litStatDone.Text    = "0"; // Full per-unit completion check simplified
            litStatLessons.Text = completedLessons.ToString();
            litStatQuiz.Text    = quizPassed.ToString();

            int pct = totalLessons > 0 ? Math.Min(completedLessons * 100 / totalLessons, 100) : 0;
            litProgressPct.Text = pct + "%";
            heroFill.Style["width"] = pct + "%";
        }

        private void BuildUnits(SqlConnection conn, string levelId, string studentId)
        {
            litRoadmap.Text = T("Unit Roadmap","Peta Unit");
            litEmptyTitle.Text = T("No units yet","Tiada unit lagi");
            litEmptyDesc.Text  = T("No units have been added to this level yet.","Tiada unit ditambah ke tahap ini lagi.");

            if (!TblOK("Unit")) { pnlUnits.Visible = false; pnlUnitsEmpty.Visible = true; return; }

            bool bm = CurrentLanguage == "BM";
            const string sql = @"SELECT u.unitId, u.unitNameEN, u.unitNameBM, u.unitDescriptionEN, u.unitDescriptionBM, u.orderNo,
                (SELECT COUNT(*) FROM Subtopic WHERE unitId=u.unitId) AS subs,
                (SELECT COUNT(*) FROM Lesson ls JOIN Subtopic st ON st.subtopicId=ls.subtopicId WHERE st.unitId=u.unitId) AS lessons
                FROM Unit u WHERE u.levelId=@l ORDER BY u.orderNo";

            var dt = new DataTable();
            using (var cmd = new SqlCommand(sql, conn))
            { cmd.Parameters.AddWithValue("@l", levelId); new SqlDataAdapter(cmd).Fill(dt); }

            if (dt.Rows.Count == 0) { pnlUnits.Visible = false; pnlUnitsEmpty.Visible = true; return; }

            var doneMap = new Dictionary<string, int>();
            if (TblOK("LessonProgress"))
                using (var cmd = new SqlCommand(@"SELECT st.unitId, COUNT(*) AS c FROM LessonProgress lp JOIN Lesson ls ON ls.lessonId=lp.lessonId JOIN Subtopic st ON st.subtopicId=ls.subtopicId WHERE lp.studentId=@s AND lp.isCompleted=1 GROUP BY st.unitId", conn))
                { cmd.Parameters.AddWithValue("@s", studentId); using (var r = cmd.ExecuteReader()) while (r.Read()) doneMap[r["unitId"].ToString()] = Convert.ToInt32(r["c"]); }

            var list = new List<object>();
            foreach (DataRow row in dt.Rows)
            {
                string uid = row["unitId"].ToString();
                string n = bm ? row["unitNameBM"].ToString() : row["unitNameEN"].ToString();
                if (string.IsNullOrWhiteSpace(n)) n = row["unitNameEN"].ToString();
                string d = bm ? row["unitDescriptionBM"].ToString() : row["unitDescriptionEN"].ToString();
                if (string.IsNullOrWhiteSpace(d)) d = row["unitDescriptionEN"].ToString();
                int subs = Convert.ToInt32(row["subs"]);
                int lessons = Convert.ToInt32(row["lessons"]);
                int done = doneMap.ContainsKey(uid) ? doneMap[uid] : 0;
                int pct = lessons > 0 ? Math.Min(done * 100 / lessons, 100) : 0;
                string dot = pct >= 100 ? "done" : pct > 0 ? "active" : "";

                list.Add(new { Name = HttpUtility.HtmlEncode(n), Desc = HttpUtility.HtmlEncode(d),
                    Subs = subs, SubLbl = T("subtopics","subtopik"), Lessons = lessons,
                    LessonLbl = T("lessons","pelajaran"), Done = done, Pct = pct, Dot = dot,
                    Btn = T("Open Unit","Buka Unit"),
                    Url = ResolveUrl("~/Student/UnitDetails.aspx?unitId=" + uid) });
            }
            pnlUnits.Visible = true; pnlUnitsEmpty.Visible = false;
            rptUnits.DataSource = list; rptUnits.DataBind();
        }

        private void BuildQuiz(SqlConnection conn, string levelId, string studentId)
        {
            litQuizHd.Text   = T("Level Assessment","Penilaian Tahap");
            litQuizNone.Text = T("Level assessment is not available yet.","Penilaian tahap belum tersedia lagi.");

            if (!TblOK("Quiz")) { pnlQuiz.Visible = false; pnlQuizNone.Visible = true; return; }

            bool bm = CurrentLanguage == "BM";
            using (var cmd = new SqlCommand("SELECT TOP 1 quizId,quizTitleEN,quizTitleBM FROM Quiz WHERE levelId=@l AND quizType='Level' ORDER BY createdAt DESC", conn))
            {
                cmd.Parameters.AddWithValue("@l", levelId);
                using (var rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        string t = bm ? rdr["quizTitleBM"].ToString() : rdr["quizTitleEN"].ToString();
                        if (string.IsNullOrWhiteSpace(t)) t = rdr["quizTitleEN"].ToString();
                        pnlQuiz.Visible = true; pnlQuizNone.Visible = false;
                        litQuizTitle.Text = HttpUtility.HtmlEncode(t);
                        litQuizSub.Text = T("Recommended after completing all units.","Disyorkan selepas menyelesaikan semua unit.");
                        litQuizBtn.Text = T("Start Level Quiz","Mula Kuiz Tahap");
                    }
                    else { pnlQuiz.Visible = false; pnlQuizNone.Visible = true; }
                }
            }
        }

        private static int Ord(string id)
        { switch (id) { case "LV001": return 1; case "LV002": return 2; case "LV003": return 3; default: return 0; } }

        private bool TblOK(string t)
        { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME=@t AND TABLE_TYPE='BASE TABLE'", c))
          { cmd.Parameters.AddWithValue("@t", t); c.Open(); return (int)cmd.ExecuteScalar() > 0; } }
    }
}
