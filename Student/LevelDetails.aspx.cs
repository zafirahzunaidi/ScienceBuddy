using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace ScienceBuddy.Student
{
    public partial class LevelDetails1 : Page
    {
        private string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString; }
        }

        private string CurrentLanguage = "EN";

        private string T(string en, string bm)
        {
            if (CurrentLanguage == "BM")
            {
                return bm;
            }
            return en;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null ||
                Session["role"].ToString() != "Student")
            {
                Response.Redirect("~/Login.aspx", false);
                return;
            }

            ((SiteMaster)Master).LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                InitLang();
                LoadPage();
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
                catch (SqlException ex)
                {
                    System.Diagnostics.Debug.WriteLine("Database error: " + ex.Message);
                }
            }

            CurrentLanguage = "EN";
            Session["preferredLanguage"] = "EN";
        }

        private void LoadPage()
        {
            string levelId = Request.QueryString["levelId"];
            string userId = Session["userId"].ToString();

            if (string.IsNullOrEmpty(levelId) || !TblOK("Level") || !TblOK("Student"))
            {
                ShowLocked(T("Invalid page", "Halaman tidak sah"),
                    T("No level specified. Return to My Learning.", "Tiada tahap dinyatakan. Kembali ke Pembelajaran Saya."));
                return;
            }

            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();
                string studentId = null;
                string curLevel = "LV001";
                using (SqlCommand command = new SqlCommand("SELECT studentId,currentlevelId FROM Student WHERE userId=@u", connection))
                {
                    command.Parameters.AddWithValue("@u", userId);
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            studentId = reader["studentId"].ToString();
                            string levelValue = "";
                            if (reader["currentlevelId"] != null && reader["currentlevelId"] != DBNull.Value)
                            {
                                levelValue = reader["currentlevelId"].ToString();
                            }
                            if (!string.IsNullOrEmpty(levelValue))
                            {
                                curLevel = levelValue;
                            }
                            else
                            {
                                curLevel = "LV001";
                            }
                        }
                    }
                }

                if (string.IsNullOrEmpty(studentId))
                {
                    ShowLocked(T("Profile not found", "Profil tidak dijumpai"), T("Student profile is missing.", "Profil pelajar tiada."));
                    return;
                }

                if (Ord(levelId) > Ord(curLevel))
                {
                    ShowLocked(T("Level Locked", "Tahap Dikunci"),
                        T("Complete your current level to unlock this one.", "Selesaikan tahap semasa untuk membuka tahap ini."));
                    return;
                }

                BuildHero(connection, levelId, curLevel);
                BuildStats(connection, levelId, studentId);
                BuildUnits(connection, levelId, studentId);
                BuildQuiz(connection, levelId, studentId);
            }
        }

        private void ShowLocked(string title, string desc)
        {
            pnlLocked.Visible = true;
            pnlMain.Visible = false;
            litLockedTitle.Text = title;
            litLockedDesc.Text = desc;
            litLockedBtn.Text = T("Back to My Learning", "Kembali ke Pembelajaran Saya");
        }

        private void BuildHero(SqlConnection conn, string levelId, string curLevel)
        {
            bool bm = CurrentLanguage == "BM";
            using (SqlCommand command = new SqlCommand("SELECT levelNameEN,levelNameBM,levelDescriptionEN,levelDescriptionBM FROM Level WHERE levelId=@l", conn))
            {
                command.Parameters.AddWithValue("@l", levelId);
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        string n;
                        if (bm)
                        {
                            n = reader["levelNameBM"].ToString();
                        }
                        else
                        {
                            n = reader["levelNameEN"].ToString();
                        }
                        if (string.IsNullOrWhiteSpace(n))
                        {
                            n = reader["levelNameEN"].ToString();
                        }

                        string d;
                        if (bm)
                        {
                            d = reader["levelDescriptionBM"].ToString();
                        }
                        else
                        {
                            d = reader["levelDescriptionEN"].ToString();
                        }
                        if (string.IsNullOrWhiteSpace(d))
                        {
                            d = reader["levelDescriptionEN"].ToString();
                        }

                        litPageTitle.Text = HttpUtility.HtmlEncode(n);
                        litLevelName.Text = HttpUtility.HtmlEncode(n);
                        litLevelDesc.Text = HttpUtility.HtmlEncode(d);
                    }
                }
            }

            litBack.Text = T("My Learning", "Pembelajaran Saya");

            string heroBadgeText;
            if (levelId == curLevel)
            {
                heroBadgeText = T("Current Level", "Tahap Semasa");
            }
            else
            {
                heroBadgeText = T("Completed", "Selesai");
            }
            litHeroBadge.Text = heroBadgeText;

            litProgressLbl.Text = T("Level Progress", "Kemajuan Tahap");
        }

        private void BuildStats(SqlConnection conn, string levelId, string studentId)
        {
            litStatUnitsLbl.Text = T("Total Units", "Jumlah Unit");
            litStatDoneLbl.Text = T("Units Completed", "Unit Selesai");
            litStatLessonsLbl.Text = T("Lessons Done", "Pelajaran Selesai");
            litStatQuizLbl.Text = T("Quizzes Passed", "Kuiz Lulus");

            int totalUnits = 0, totalLessons = 0, completedLessons = 0, quizPassed = 0;

            if (TblOK("Unit"))
            {
                using (SqlCommand command = new SqlCommand("SELECT COUNT(*) FROM Unit WHERE levelId=@l", conn))
                {
                    command.Parameters.AddWithValue("@l", levelId);
                    totalUnits = (int)command.ExecuteScalar();
                }
            }

            if (TblOK("Lesson") && TblOK("Subtopic") && TblOK("Unit"))
            {
                using (SqlCommand command = new SqlCommand(@"SELECT COUNT(*) FROM Lesson ls JOIN Subtopic st ON st.subtopicId=ls.subtopicId JOIN Unit u ON u.unitId=st.unitId WHERE u.levelId=@l", conn))
                {
                    command.Parameters.AddWithValue("@l", levelId);
                    totalLessons = (int)command.ExecuteScalar();
                }
            }

            if (TblOK("LessonProgress") && TblOK("Lesson") && TblOK("Subtopic") && TblOK("Unit"))
            {
                using (SqlCommand command = new SqlCommand(@"SELECT COUNT(*) FROM LessonProgress lp JOIN Lesson ls ON ls.lessonId=lp.lessonId JOIN Subtopic st ON st.subtopicId=ls.subtopicId JOIN Unit u ON u.unitId=st.unitId WHERE u.levelId=@l AND lp.studentId=@s AND lp.isCompleted=1", conn))
                {
                    command.Parameters.AddWithValue("@l", levelId);
                    command.Parameters.AddWithValue("@s", studentId);
                    completedLessons = (int)command.ExecuteScalar();
                }
            }

            if (TblOK("QuizResult") && TblOK("Quiz"))
            {
                using (SqlCommand command = new SqlCommand(@"SELECT COUNT(DISTINCT qr.quizId) FROM QuizResult qr JOIN Quiz q ON q.quizId=qr.quizId WHERE q.levelId=@l AND qr.studentId=@s AND qr.resultStatus='Pass'", conn))
                {
                    command.Parameters.AddWithValue("@l", levelId);
                    command.Parameters.AddWithValue("@s", studentId);
                    quizPassed = (int)command.ExecuteScalar();
                }
            }

            litStatUnits.Text = totalUnits.ToString();
            litStatDone.Text = "0";
            litStatLessons.Text = completedLessons.ToString();
            litStatQuiz.Text = quizPassed.ToString();

            int pct;
            if (totalLessons > 0)
            {
                pct = Math.Min(completedLessons * 100 / totalLessons, 100);
            }
            else
            {
                pct = 0;
            }
            litProgressPct.Text = pct + "%";
            heroFill.Style["width"] = pct + "%";
        }

        private void BuildUnits(SqlConnection conn, string levelId, string studentId)
        {
            litRoadmap.Text = T("Unit Roadmap", "Peta Unit");
            litEmptyTitle.Text = T("No units yet", "Tiada unit lagi");
            litEmptyDesc.Text = T("No units have been added to this level yet.", "Tiada unit ditambah ke tahap ini lagi.");

            if (!TblOK("Unit"))
            {
                pnlUnits.Visible = false;
                pnlUnitsEmpty.Visible = true;
                return;
            }

            bool bm = CurrentLanguage == "BM";
            const string sql = @"SELECT u.unitId, u.unitNameEN, u.unitNameBM, u.unitDescriptionEN, u.unitDescriptionBM, u.orderNo,
                (SELECT COUNT(*) FROM Subtopic WHERE unitId=u.unitId) AS subs,
                (SELECT COUNT(*) FROM Lesson ls JOIN Subtopic st ON st.subtopicId=ls.subtopicId WHERE st.unitId=u.unitId) AS lessons
                FROM Unit u WHERE u.levelId=@l ORDER BY u.orderNo";

            DataTable dataTable = new DataTable();
            using (SqlCommand command = new SqlCommand(sql, conn))
            {
                command.Parameters.AddWithValue("@l", levelId);
                new SqlDataAdapter(command).Fill(dataTable);
            }

            if (dataTable.Rows.Count == 0)
            {
                pnlUnits.Visible = false;
                pnlUnitsEmpty.Visible = true;
                return;
            }

            Dictionary<string, int> doneMap = new Dictionary<string, int>();
            if (TblOK("LessonProgress"))
            {
                using (SqlCommand command = new SqlCommand(@"SELECT st.unitId, COUNT(*) AS c FROM LessonProgress lp JOIN Lesson ls ON ls.lessonId=lp.lessonId JOIN Subtopic st ON st.subtopicId=ls.subtopicId WHERE lp.studentId=@s AND lp.isCompleted=1 GROUP BY st.unitId", conn))
                {
                    command.Parameters.AddWithValue("@s", studentId);
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            doneMap[reader["unitId"].ToString()] = Convert.ToInt32(reader["c"]);
                        }
                    }
                }
            }

            List<object> list = new List<object>();
            foreach (DataRow row in dataTable.Rows)
            {
                string uid = row["unitId"].ToString();

                string n;
                if (bm)
                {
                    n = row["unitNameBM"].ToString();
                }
                else
                {
                    n = row["unitNameEN"].ToString();
                }
                if (string.IsNullOrWhiteSpace(n))
                {
                    n = row["unitNameEN"].ToString();
                }

                string d;
                if (bm)
                {
                    d = row["unitDescriptionBM"].ToString();
                }
                else
                {
                    d = row["unitDescriptionEN"].ToString();
                }
                if (string.IsNullOrWhiteSpace(d))
                {
                    d = row["unitDescriptionEN"].ToString();
                }

                int subs = Convert.ToInt32(row["subs"]);
                int lessons = Convert.ToInt32(row["lessons"]);
                int done;
                if (doneMap.ContainsKey(uid))
                {
                    done = doneMap[uid];
                }
                else
                {
                    done = 0;
                }

                int pct;
                if (lessons > 0)
                {
                    pct = Math.Min(done * 100 / lessons, 100);
                }
                else
                {
                    pct = 0;
                }

                string dot;
                if (pct >= 100)
                {
                    dot = "done";
                }
                else if (pct > 0)
                {
                    dot = "active";
                }
                else
                {
                    dot = "";
                }

                list.Add(new
                {
                    Name = HttpUtility.HtmlEncode(n),
                    Desc = HttpUtility.HtmlEncode(d),
                    Subs = subs,
                    SubLbl = T("subtopics", "subtopik"),
                    Lessons = lessons,
                    LessonLbl = T("lessons", "pelajaran"),
                    Done = done,
                    Pct = pct,
                    Dot = dot,
                    Btn = T("Open Unit", "Buka Unit"),
                    Url = ResolveUrl("~/Student/UnitDetails.aspx?unitId=" + uid)
                });
            }

            pnlUnits.Visible = true;
            pnlUnitsEmpty.Visible = false;
            rptUnits.DataSource = list;
            rptUnits.DataBind();
        }

        private void BuildQuiz(SqlConnection conn, string levelId, string studentId)
        {
            litQuizHd.Text = T("Level Assessment", "Penilaian Tahap");
            litQuizNone.Text = T("Level assessment is not available yet.", "Penilaian tahap belum tersedia lagi.");

            if (!TblOK("Quiz"))
            {
                pnlQuiz.Visible = false;
                pnlQuizNone.Visible = true;
                return;
            }

            bool bm = CurrentLanguage == "BM";
            string quizId = null;
            using (SqlCommand command = new SqlCommand("SELECT TOP 1 quizId,quizTitleEN,quizTitleBM FROM Quiz WHERE levelId=@l AND quizType='Level' ORDER BY createdAt DESC", conn))
            {
                command.Parameters.AddWithValue("@l", levelId);
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        quizId = reader["quizId"].ToString();

                        string t;
                        if (bm)
                        {
                            t = reader["quizTitleBM"].ToString();
                        }
                        else
                        {
                            t = reader["quizTitleEN"].ToString();
                        }
                        if (string.IsNullOrWhiteSpace(t))
                        {
                            t = reader["quizTitleEN"].ToString();
                        }

                        pnlQuiz.Visible = true;
                        pnlQuizNone.Visible = false;
                        litQuizTitle.Text = HttpUtility.HtmlEncode(t);
                        litQuizSub.Text = T("Recommended after completing all units.", "Disyorkan selepas menyelesaikan semua unit.");
                        litQuizBtn.Text = T("Start Level Quiz", "Mula Kuiz Tahap");
                        lnkQuizStart.HRef = ResolveUrl("~/Student/Quiz.aspx?quizId=" + quizId);
                    }
                    else
                    {
                        pnlQuiz.Visible = false;
                        pnlQuizNone.Visible = true;
                        return;
                    }
                }
            }

            if (!string.IsNullOrEmpty(quizId) && TblOK("QuizResult"))
            {
                using (SqlCommand command = new SqlCommand("SELECT TOP 1 resultId FROM QuizResult WHERE studentId=@s AND quizId=@q ORDER BY attemptedDate DESC", conn))
                {
                    command.Parameters.AddWithValue("@s", studentId);
                    command.Parameters.AddWithValue("@q", quizId);
                    object result = command.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        string rid = result.ToString();
                        pnlQuizResult.Visible = true;
                        litQuizResultBtn.Text = T("View Last Result", "Lihat Keputusan Terkini");
                        litQuizReviewBtn.Text = T("Review Answers", "Semak Jawapan");
                        lnkQuizResult.HRef = ResolveUrl("~/Student/QuizResult.aspx?resultId=" + rid);
                        lnkQuizReview.HRef = ResolveUrl("~/Student/QuizReview.aspx?resultId=" + rid);
                    }
                }
            }
        }

        private static int Ord(string id)
        {
            switch (id)
            {
                case "LV001": return 1;
                case "LV002": return 2;
                case "LV003": return 3;
                default: return 0;
            }
        }

        private bool TblOK(string t)
        {
            using (SqlConnection connection = new SqlConnection(ConnStr))
            using (SqlCommand command = new SqlCommand("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME=@t AND TABLE_TYPE='BASE TABLE'", connection))
            {
                command.Parameters.AddWithValue("@t", t);
                connection.Open();
                return (int)command.ExecuteScalar() > 0;
            }
        }
    }
}
