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
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddyDB"].ConnectionString;
        private string CurrentLanguage = "EN";
        private string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }
        protected int LevelProgressPct = 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null ||
                Session["role"].ToString() != "Student")
            { Response.Redirect("~/Login.aspx", false); return; }

            ((SiteMaster)Master).LayoutMode = "Sidebar";

            if (!IsPostBack) { InitLanguage(); LoadPage(); }
        }

        private void InitLanguage()
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
                    { cmd.Parameters.AddWithValue("@u", uid); c.Open();
                      var r = cmd.ExecuteScalar();
                      if (r != null && r != DBNull.Value) { lang = r.ToString(); Session["preferredLanguage"] = lang; CurrentLanguage = lang; return; }
                    }
                } catch (SqlException) {}
            }
            CurrentLanguage = "EN"; Session["preferredLanguage"] = "EN";
        }

        private void LoadPage()
        {
            string levelId = Request.QueryString["levelId"];
            string userId = Session["userId"].ToString();

            if (string.IsNullOrEmpty(levelId) || !TableExists("Level") || !TableExists("Student"))
            { ShowLocked(T("Invalid page", "Halaman tidak sah"),
                         T("No level specified. Go back to My Learning.", "Tiada tahap dinyatakan. Kembali ke Pembelajaran Saya.")); return; }

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Get student
                string studentId = null; string currentLevelId = "LV001";
                using (var cmd = new SqlCommand("SELECT studentId, currentlevelId FROM Student WHERE userId=@u", conn))
                { cmd.Parameters.AddWithValue("@u", userId);
                  using (var rdr = cmd.ExecuteReader()) { if (rdr.Read()) { studentId = rdr["studentId"].ToString(); currentLevelId = rdr["currentlevelId"]?.ToString() ?? "LV001"; } } }

                if (string.IsNullOrEmpty(studentId))
                { ShowLocked(T("Profile not found","Profil tidak dijumpai"), T("Student profile is missing.","Profil pelajar tiada.")); return; }

                // Access check
                if (GetOrder(levelId) > GetOrder(currentLevelId))
                { ShowLocked(T("Level Locked","Tahap Dikunci"),
                             T("Complete your current level to unlock this one.","Selesaikan tahap semasa untuk membuka tahap ini.")); return; }

                // Load level info
                LoadHero(conn, levelId, currentLevelId);
                LoadStats(conn, levelId, studentId);
                LoadUnits(conn, levelId, studentId);
                LoadQuiz(conn, levelId, studentId);
            }
        }

        private void ShowLocked(string title, string desc)
        {
            pnlLocked.Visible = true; pnlMain.Visible = false;
            litLockedTitle.Text = title; litLockedDesc.Text = desc;
            litLockedBtn.Text = T("Back to My Learning","Kembali ke Pembelajaran Saya");
        }

        private void LoadHero(SqlConnection conn, string levelId, string currentLevelId)
        {
            bool isBM = CurrentLanguage == "BM";
            using (var cmd = new SqlCommand("SELECT levelNameEN,levelNameBM,levelDescriptionEN,levelDescriptionBM FROM Level WHERE levelId=@l", conn))
            {
                cmd.Parameters.AddWithValue("@l", levelId);
                using (var rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        string name = isBM ? rdr["levelNameBM"].ToString() : rdr["levelNameEN"].ToString();
                        if (string.IsNullOrWhiteSpace(name)) name = rdr["levelNameEN"].ToString();
                        string desc = isBM ? rdr["levelDescriptionBM"].ToString() : rdr["levelDescriptionEN"].ToString();
                        if (string.IsNullOrWhiteSpace(desc)) desc = rdr["levelDescriptionEN"].ToString();

                        litPageTitle.Text = HttpUtility.HtmlEncode(name);
                        litLevelName.Text = HttpUtility.HtmlEncode(name);
                        litLevelDesc.Text = HttpUtility.HtmlEncode(desc);
                    }
                }
            }

            litBackText.Text = T("My Learning", "Pembelajaran Saya");
            string badge = levelId == currentLevelId ? T("Current Level","Tahap Semasa")
                         : T("Completed","Selesai");
            litHeroBadge.Text = badge;
            litProgressLabel.Text = T("Level Progress","Kemajuan Tahap");
        }

        private void LoadStats(SqlConnection conn, string levelId, string studentId)
        {
            litStatUnitsLbl.Text     = T("Total Units","Jumlah Unit");
            litStatUnitsDoneLbl.Text = T("Units Completed","Unit Selesai");
            litStatLessonsLbl.Text   = T("Lessons Done","Pelajaran Selesai");
            litStatQuizzesLbl.Text   = T("Quizzes Passed","Kuiz Lulus");

            // Total units
            int totalUnits = 0;
            if (TableExists("Unit"))
            {
                using (var cmd = new SqlCommand("SELECT COUNT(*) FROM Unit WHERE levelId=@l", conn))
                { cmd.Parameters.AddWithValue("@l", levelId); totalUnits = (int)cmd.ExecuteScalar(); }
            }
            litStatUnits.Text = totalUnits.ToString();

            // Total lessons in this level
            int totalLessons = 0;
            if (TableExists("Lesson") && TableExists("Subtopic") && TableExists("Unit"))
            {
                using (var cmd = new SqlCommand(@"SELECT COUNT(*) FROM Lesson ls
                    JOIN Subtopic st ON st.subtopicId=ls.subtopicId
                    JOIN Unit u ON u.unitId=st.unitId WHERE u.levelId=@l", conn))
                { cmd.Parameters.AddWithValue("@l", levelId); totalLessons = (int)cmd.ExecuteScalar(); }
            }

            // Completed lessons
            int completedLessons = 0;
            if (TableExists("LessonProgress") && TableExists("Lesson") && TableExists("Subtopic") && TableExists("Unit"))
            {
                using (var cmd = new SqlCommand(@"SELECT COUNT(*) FROM LessonProgress lp
                    JOIN Lesson ls ON ls.lessonId=lp.lessonId
                    JOIN Subtopic st ON st.subtopicId=ls.subtopicId
                    JOIN Unit u ON u.unitId=st.unitId
                    WHERE u.levelId=@l AND lp.studentId=@s AND lp.isCompleted=1", conn))
                { cmd.Parameters.AddWithValue("@l", levelId); cmd.Parameters.AddWithValue("@s", studentId);
                  completedLessons = (int)cmd.ExecuteScalar(); }
            }
            litStatLessons.Text = completedLessons.ToString();
            LevelProgressPct = totalLessons > 0 ? Math.Min(completedLessons * 100 / totalLessons, 100) : 0;

            // Units completed (all lessons in unit done)
            litStatUnitsDone.Text = "0"; // simplified — full logic requires per-unit check
            // Quizzes passed
            int quizzesPassed = 0;
            if (TableExists("QuizResult") && TableExists("Quiz"))
            {
                using (var cmd = new SqlCommand(@"SELECT COUNT(DISTINCT qr.quizId) FROM QuizResult qr
                    JOIN Quiz q ON q.quizId=qr.quizId
                    WHERE q.levelId=@l AND qr.studentId=@s AND qr.resultStatus='Pass'", conn))
                { cmd.Parameters.AddWithValue("@l", levelId); cmd.Parameters.AddWithValue("@s", studentId);
                  quizzesPassed = (int)cmd.ExecuteScalar(); }
            }
            litStatQuizzes.Text = quizzesPassed.ToString();
        }

        private void LoadUnits(SqlConnection conn, string levelId, string studentId)
        {
            litRoadmapTitle.Text = T("Unit Roadmap","Peta Unit");
            litUnitsEmptyTitle.Text = T("No units yet","Tiada unit lagi");
            litUnitsEmptyDesc.Text = T("No units have been added to this level yet.",
                                       "Tiada unit ditambah ke tahap ini lagi.");

            if (!TableExists("Unit")) { pnlUnits.Visible = false; pnlUnitsEmpty.Visible = true; return; }

            bool isBM = CurrentLanguage == "BM";
            const string sql = @"SELECT u.unitId, u.unitNameEN, u.unitNameBM,
                u.unitDescriptionEN, u.unitDescriptionBM, u.orderNo,
                (SELECT COUNT(*) FROM Subtopic WHERE unitId=u.unitId) AS subs,
                (SELECT COUNT(*) FROM Lesson ls JOIN Subtopic st ON st.subtopicId=ls.subtopicId WHERE st.unitId=u.unitId) AS lessons
                FROM Unit u WHERE u.levelId=@l ORDER BY u.orderNo";

            var dt = new DataTable();
            using (var cmd = new SqlCommand(sql, conn))
            { cmd.Parameters.AddWithValue("@l", levelId); var da = new SqlDataAdapter(cmd); da.Fill(dt); }

            if (dt.Rows.Count == 0) { pnlUnits.Visible = false; pnlUnitsEmpty.Visible = true; return; }

            // Completed lessons per unit
            var doneMap = new Dictionary<string, int>();
            if (TableExists("LessonProgress"))
            {
                using (var cmd = new SqlCommand(@"SELECT st.unitId, COUNT(*) AS cnt FROM LessonProgress lp
                    JOIN Lesson ls ON ls.lessonId=lp.lessonId
                    JOIN Subtopic st ON st.subtopicId=ls.subtopicId
                    WHERE lp.studentId=@s AND lp.isCompleted=1 GROUP BY st.unitId", conn))
                { cmd.Parameters.AddWithValue("@s", studentId);
                  using (var rdr = cmd.ExecuteReader()) { while (rdr.Read()) doneMap[rdr["unitId"].ToString()] = Convert.ToInt32(rdr["cnt"]); } }
            }

            var list = new List<object>();
            foreach (DataRow row in dt.Rows)
            {
                string uid = row["unitId"].ToString();
                string name = isBM ? row["unitNameBM"].ToString() : row["unitNameEN"].ToString();
                if (string.IsNullOrWhiteSpace(name)) name = row["unitNameEN"].ToString();
                string desc = isBM ? row["unitDescriptionBM"].ToString() : row["unitDescriptionEN"].ToString();
                if (string.IsNullOrWhiteSpace(desc)) desc = row["unitDescriptionEN"].ToString();

                int subs = Convert.ToInt32(row["subs"]);
                int lessons = Convert.ToInt32(row["lessons"]);
                int done = doneMap.ContainsKey(uid) ? doneMap[uid] : 0;
                int pct = lessons > 0 ? Math.Min(done * 100 / lessons, 100) : 0;
                string dot = pct >= 100 ? "done" : (pct > 0 ? "current" : "");

                list.Add(new {
                    Name = HttpUtility.HtmlEncode(name),
                    Description = HttpUtility.HtmlEncode(desc),
                    Subtopics = subs, SubLabel = T("subtopics","subtopik"),
                    Lessons = lessons, LessonLabel = T("lessons","pelajaran"),
                    Completed = done, Pct = pct, DotClass = dot,
                    BtnText = T("Open Unit","Buka Unit"),
                    Url = ResolveUrl("~/Student/UnitDetails.aspx?unitId=" + uid)
                });
            }

            pnlUnits.Visible = true; pnlUnitsEmpty.Visible = false;
            rptUnits.DataSource = list; rptUnits.DataBind();
        }

        private void LoadQuiz(SqlConnection conn, string levelId, string studentId)
        {
            litQuizSection.Text = T("Level Assessment","Penilaian Tahap");
            litQuizNone.Text = T("Level assessment is not available yet.",
                                 "Penilaian tahap belum tersedia lagi.");

            if (!TableExists("Quiz")) { pnlQuiz.Visible = false; pnlQuizNone.Visible = true; return; }

            bool isBM = CurrentLanguage == "BM";
            using (var cmd = new SqlCommand(@"SELECT TOP 1 quizId,quizTitleEN,quizTitleBM
                FROM Quiz WHERE levelId=@l AND quizType='Level' ORDER BY createdAt DESC", conn))
            {
                cmd.Parameters.AddWithValue("@l", levelId);
                using (var rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        string title = isBM ? rdr["quizTitleBM"].ToString() : rdr["quizTitleEN"].ToString();
                        if (string.IsNullOrWhiteSpace(title)) title = rdr["quizTitleEN"].ToString();
                        pnlQuiz.Visible = true; pnlQuizNone.Visible = false;
                        litQuizTitle.Text = HttpUtility.HtmlEncode(title);
                        litQuizSub.Text = T("Recommended after completing all units.",
                                            "Disyorkan selepas menyelesaikan semua unit.");
                        litQuizBtn.Text = T("Start Level Quiz","Mula Kuiz Tahap");
                    }
                    else { pnlQuiz.Visible = false; pnlQuizNone.Visible = true; }
                }
            }
        }

        private static int GetOrder(string id)
        {
            switch (id) { case "LV001": return 1; case "LV002": return 2; case "LV003": return 3; default: return 0; }
        }

        private bool TableExists(string t)
        {
            using (var c = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME=@t AND TABLE_TYPE='BASE TABLE'", c))
            { cmd.Parameters.AddWithValue("@t", t); c.Open(); return (int)cmd.ExecuteScalar() > 0; }
        }
    }
}
