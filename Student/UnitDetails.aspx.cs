using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace ScienceBuddy.Student
{
    public partial class UnitDetails : Page
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
            if (Session["userId"] == null || Session["role"] == null || Session["role"].ToString() != "Student")
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
                    using (SqlCommand command = new SqlCommand("SELECT preferredLanguage FROM [User] WHERE userId=@userId", connection))
                    {
                        command.Parameters.AddWithValue("@userId", uid);
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

        private void LoadPage()
        {
            string unitId = Request.QueryString["unitId"];
            string userId = Session["userId"].ToString();
            if (string.IsNullOrEmpty(unitId) || !Tbl("Unit") || !Tbl("Student"))
            {
                ShowLocked(T("Invalid page", "Halaman tidak sah"), T("No unit specified.", "Tiada unit dinyatakan."));
                return;
            }

            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();
                string studentId = null;
                string curLevel = "LV001";
                using (SqlCommand command = new SqlCommand("SELECT studentId,currentlevelId FROM Student WHERE userId=@userId", connection))
                {
                    command.Parameters.AddWithValue("@userId", userId);
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            studentId = reader["studentId"].ToString();
                            if (reader["currentlevelId"] != null)
                            {
                                curLevel = reader["currentlevelId"].ToString();
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
                    ShowLocked(T("Not found", "Tidak dijumpai"), T("Student profile missing.", "Profil pelajar tiada."));
                    return;
                }

                string unitLevel = null;
                using (SqlCommand command = new SqlCommand("SELECT levelId FROM Unit WHERE unitId=@unitId", connection))
                {
                    command.Parameters.AddWithValue("@unitId", unitId);
                    object result = command.ExecuteScalar();
                    if (result != null)
                    {
                        unitLevel = result.ToString();
                    }
                }
                if (string.IsNullOrEmpty(unitLevel))
                {
                    ShowLocked(T("Unit not found", "Unit tidak dijumpai"), T("This unit does not exist.", "Unit ini tidak wujud."));
                    return;
                }

                if (Ord(unitLevel) > Ord(curLevel))
                {
                    ShowLocked(T("Unit Locked", "Unit Dikunci"), T("Complete your current level to access this unit.", "Selesaikan tahap semasa untuk akses unit ini."));
                    return;
                }

                BuildHero(connection, unitId, unitLevel);
                BuildPath(connection, unitId);
                BuildLessons(connection, unitId, studentId);
                BuildMaterials(connection, unitId);
                BuildLab(connection, unitId, studentId);
                BuildQuiz(connection, unitId, studentId);
            }
        }

        private void ShowLocked(string t, string d)
        {
            pnlLocked.Visible = true;
            pnlMain.Visible = false;
            litLockedTitle.Text = t;
            litLockedDesc.Text = d;
            litLockedBtn.Text = T("Back", "Kembali");
        }

        private void BuildHero(SqlConnection connection, string unitId, string unitLevel)
        {
            bool bm = CurrentLanguage == "BM";
            using (SqlCommand command = new SqlCommand(@"SELECT u.unitNameEN,u.unitNameBM,u.unitDescriptionEN,u.unitDescriptionBM,
                l.levelNameEN,l.levelNameBM FROM Unit u LEFT JOIN Level l ON l.levelId=u.levelId WHERE u.unitId=@unitId", connection))
            {
                command.Parameters.AddWithValue("@unitId", unitId);
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        string n;
                        if (bm)
                        {
                            n = reader["unitNameBM"].ToString();
                        }
                        else
                        {
                            n = reader["unitNameEN"].ToString();
                        }
                        if (string.IsNullOrWhiteSpace(n))
                        {
                            n = reader["unitNameEN"].ToString();
                        }

                        string d;
                        if (bm)
                        {
                            d = reader["unitDescriptionBM"].ToString();
                        }
                        else
                        {
                            d = reader["unitDescriptionEN"].ToString();
                        }
                        if (string.IsNullOrWhiteSpace(d))
                        {
                            d = reader["unitDescriptionEN"].ToString();
                        }

                        string lv;
                        if (bm)
                        {
                            lv = reader["levelNameBM"].ToString();
                        }
                        else
                        {
                            lv = reader["levelNameEN"].ToString();
                        }
                        if (string.IsNullOrWhiteSpace(lv))
                        {
                            lv = reader["levelNameEN"].ToString();
                        }

                        litPageTitle.Text = HttpUtility.HtmlEncode(n);
                        litUnitName.Text = HttpUtility.HtmlEncode(n);
                        litUnitDesc.Text = HttpUtility.HtmlEncode(d);
                        litHeroLevel.Text = HttpUtility.HtmlEncode(lv);
                    }
                }
            }
            litBack.Text = T("My Learning", "Pembelajaran Saya");
            litBarLbl.Text = T("Unit Progress", "Kemajuan Unit");
        }

        private void BuildPath(SqlConnection connection, string unitId)
        {

            int lc = 0;
            int mc = 0;
            int vc = 0;
            int qc = 0;

            if (Tbl("Lesson") && Tbl("Subtopic"))
            {
                using (SqlCommand command = new SqlCommand("SELECT COUNT(*) FROM Lesson ls JOIN Subtopic st ON st.subtopicId=ls.subtopicId WHERE st.unitId=@unitId", connection))
                {
                    command.Parameters.AddWithValue("@unitId", unitId);
                    lc = (int)command.ExecuteScalar();
                }
            }
            if (Tbl("Material") && Tbl("Subtopic"))
            {
                using (SqlCommand command = new SqlCommand("SELECT COUNT(*) FROM Material m JOIN Subtopic st ON st.subtopicId=m.subtopicId WHERE st.unitId=@unitId AND m.status='Approved'", connection))
                {
                    command.Parameters.AddWithValue("@unitId", unitId);
                    mc = (int)command.ExecuteScalar();
                }
            }
            if (Tbl("VirtualLab"))
            {
                using (SqlCommand command = new SqlCommand("SELECT COUNT(*) FROM VirtualLab WHERE unitId=@unitId", connection))
                {
                    command.Parameters.AddWithValue("@unitId", unitId);
                    vc = (int)command.ExecuteScalar();
                }
            }
            if (Tbl("Quiz"))
            {
                using (SqlCommand command = new SqlCommand("SELECT COUNT(*) FROM Quiz WHERE unitId=@unitId AND quizType='Unit'", connection))
                {
                    command.Parameters.AddWithValue("@unitId", unitId);
                    qc = (int)command.ExecuteScalar();
                }
            }

            if (vc > 0)
            {
            }
            else
            {
            }
            if (qc > 0)
            {
            }
            else
            {
            }
        }

        private void BuildLessons(SqlConnection connection, string unitId, string studentId)
        {
            litLessonHd.Text = T("Lessons", "Bahan Belajar");
            if (!Tbl("Subtopic"))
            {
                pnlLessons.Visible = false;
                return;
            }

            bool bm = CurrentLanguage == "BM";
            var doneSet = new HashSet<string>();
            if (Tbl("LessonProgress"))
            {
                using (SqlCommand command = new SqlCommand("SELECT lessonId FROM LessonProgress WHERE studentId=@s AND isCompleted=1", connection))
                {
                    command.Parameters.AddWithValue("@s", studentId);
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            doneSet.Add(reader["lessonId"].ToString());
                        }
                    }
                }
            }

            DataTable dtSt = new DataTable();
            using (SqlCommand command = new SqlCommand("SELECT subtopicId,subtopicTitleEN,subtopicTitleBM,subtopicDescriptionEN,subtopicDescriptionBM,orderNo FROM Subtopic WHERE unitId=@unitId ORDER BY orderNo", connection))
            {
                command.Parameters.AddWithValue("@unitId", unitId);
                SqlDataAdapter adapter = new SqlDataAdapter(command);
                adapter.Fill(dtSt);
            }

            if (dtSt.Rows.Count == 0)
            {
                pnlLessons.Visible = false;
                return;
            }

            DataTable dtLs = new DataTable();
            if (Tbl("Lesson"))
            {
                using (SqlCommand command = new SqlCommand("SELECT ls.lessonId,ls.subtopicId,ls.lessonTitleEN,ls.lessonTitleBM,ls.orderNo FROM Lesson ls JOIN Subtopic st ON st.subtopicId=ls.subtopicId WHERE st.unitId=@unitId ORDER BY ls.orderNo", connection))
                {
                    command.Parameters.AddWithValue("@unitId", unitId);
                    SqlDataAdapter adapter = new SqlDataAdapter(command);
                    adapter.Fill(dtLs);
                }
            }

            int totalLessons = dtLs.Rows.Count;
            int doneLessons = 0;

            var subtopics = new List<object>();
            foreach (DataRow st in dtSt.Rows)
            {
                string stId = st["subtopicId"].ToString();
                string stTitle;
                if (bm)
                {
                    stTitle = st["subtopicTitleBM"].ToString();
                }
                else
                {
                    stTitle = st["subtopicTitleEN"].ToString();
                }
                if (string.IsNullOrWhiteSpace(stTitle))
                {
                    stTitle = st["subtopicTitleEN"].ToString();
                }

                string stDesc;
                if (bm)
                {
                    stDesc = st["subtopicDescriptionBM"].ToString();
                }
                else
                {
                    stDesc = st["subtopicDescriptionEN"].ToString();
                }
                if (string.IsNullOrWhiteSpace(stDesc))
                {
                    stDesc = st["subtopicDescriptionEN"].ToString();
                }

                var lessons = new List<object>();
                foreach (DataRow ls in dtLs.Rows)
                {
                    if (ls["subtopicId"].ToString() != stId)
                    {
                        continue;
                    }
                    string lid = ls["lessonId"].ToString();
                    bool done = doneSet.Contains(lid);
                    if (done)
                    {
                        doneLessons++;
                    }

                    string lTitle;
                    if (bm)
                    {
                        lTitle = ls["lessonTitleBM"].ToString();
                    }
                    else
                    {
                        lTitle = ls["lessonTitleEN"].ToString();
                    }
                    if (string.IsNullOrWhiteSpace(lTitle))
                    {
                        lTitle = ls["lessonTitleEN"].ToString();
                    }

                    string badge;
                    if (done)
                    {
                        badge = T("Completed", "Selesai");
                    }
                    else
                    {
                        badge = T("Start", "Mula");
                    }

                    lessons.Add(new
                    {
                        Title = HttpUtility.HtmlEncode(lTitle),
                        Done = done,
                        Badge = badge,
                        Url = ResolveUrl("~/Student/Lesson.aspx?lessonId=" + lid)
                    });
                }
                subtopics.Add(new
                {
                    Title = HttpUtility.HtmlEncode(stTitle),
                    Desc = HttpUtility.HtmlEncode(stDesc),
                    Lessons = lessons
                });
            }

            rptSubtopics.DataSource = subtopics;
            rptSubtopics.DataBind();

            int pct = 0;
            if (totalLessons > 0)
            {
                pct = Math.Min(doneLessons * 100 / totalLessons, 100);
            }
            litBarPct.Text = pct + "%";
            heroBar.Style["width"] = pct + "%";
        }

        private void BuildMaterials(SqlConnection connection, string unitId)
        {
            litMatHd.Text = T("Materials", "Bahan Sokongan");

            if (!Tbl("Material") || !Tbl("Subtopic"))
            {
                pnlMats.Visible = false;
                return;
            }

            DataTable dataTable = new DataTable();
            using (SqlCommand command = new SqlCommand(@"SELECT m.materialId,m.materialTitle,m.materialType,m.fileUrl,m.language
                FROM Material m JOIN Subtopic st ON st.subtopicId=m.subtopicId
                WHERE st.unitId=@unitId AND m.status='Approved' ORDER BY m.createdDate DESC", connection))
            {
                command.Parameters.AddWithValue("@unitId", unitId);
                SqlDataAdapter adapter = new SqlDataAdapter(command);
                adapter.Fill(dataTable);
            }

            if (dataTable.Rows.Count == 0)
            {
                pnlMats.Visible = false;
                return;
            }

            var list = new List<object>();
            foreach (DataRow r in dataTable.Rows)
            {
                string fileUrl = r["fileUrl"]?.ToString() ?? "";
                string resolvedUrl = "";
                if (!string.IsNullOrEmpty(fileUrl))
                {
                    resolvedUrl = ResolveUrl("~/Images/Material/" + fileUrl);
                }

                list.Add(new
                {
                    Title = HttpUtility.HtmlEncode(r["materialTitle"].ToString()),
                    Type = r["materialType"].ToString(),
                    Lang = r["language"].ToString(),
                    ResolvedUrl = resolvedUrl,
                    ViewBtn = T("View", "Lihat"),
                    DownloadBtn = T("Download", "Muat Turun")
                });
            }
            pnlMats.Visible = true;
            rptMats.DataSource = list;
            rptMats.DataBind();
        }

        private void BuildLab(SqlConnection connection, string unitId, string studentId)
        {
            litLabHd.Text = T("Virtual Lab", "Makmal Maya");

            if (!Tbl("VirtualLab"))
            {
                pnlLab.Visible = false;
                return;
            }

            bool bm = CurrentLanguage == "BM";
            using (SqlCommand command = new SqlCommand("SELECT TOP 1 labId,labTitleEN,labTitleBM,labDescriptionEN,labDescriptionBM,difficulty " +
                "FROM VirtualLab " +
                "WHERE unitId=@unitId", 
                connection))
            {
                command.Parameters.AddWithValue("@unitId", unitId);
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        string t;
                        if (bm)
                        {
                            t = reader["labTitleBM"].ToString();
                        }
                        else
                        {
                            t = reader["labTitleEN"].ToString();
                        }
                        if (string.IsNullOrWhiteSpace(t))
                        {
                            t = reader["labTitleEN"].ToString();
                        }

                        string d;
                        if (bm)
                        {
                            d = reader["labDescriptionBM"].ToString();
                        }
                        else
                        {
                            d = reader["labDescriptionEN"].ToString();
                        }
                        if (string.IsNullOrWhiteSpace(d))
                        {
                            d = reader["labDescriptionEN"].ToString();
                        }

                        pnlLab.Visible = true;
                        litLabTitle.Text = HttpUtility.HtmlEncode(t);
                        litLabSub.Text = HttpUtility.HtmlEncode(d) + " &bull; " + reader["difficulty"].ToString();
                        litLabBtn.Text = T("Start Lab", "Mula Makmal");
                    }
                    else
                    {
                        pnlLab.Visible = false;
                    }
                }
            }
        }

        private void BuildQuiz(SqlConnection connection, string unitId, string studentId)
        {
            litQuizHd.Text = T("Unit Quiz", "Kuiz Unit");

            if (!Tbl("Quiz"))
            {
                pnlQuiz.Visible = false;
                return;
            }

            bool bm = CurrentLanguage == "BM";
            string quizId = null;
            using (SqlCommand command = new SqlCommand("SELECT TOP 1 quizId,quizTitleEN,quizTitleBM FROM Quiz WHERE unitId=@unitId AND quizType='Unit' AND (status IS NULL OR status IN ('Approved','Published')) ORDER BY createdAt DESC", connection))
            {
                command.Parameters.AddWithValue("@unitId", unitId);
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
                        litQuizTitle.Text = HttpUtility.HtmlEncode(t);
                        litQuizSub.Text = T("Test your understanding of this unit.", "Uji kefahaman anda tentang unit ini.");
                        litQuizBtn.Text = T("Start Quiz", "Mula Kuiz");
                        lnkQuizStart.HRef = ResolveUrl("~/Student/Quiz.aspx?quizId=" + quizId);
                    }
                    else
                    {
                        pnlQuiz.Visible = false;
                        return;
                    }
                }
            }

            if (!string.IsNullOrEmpty(quizId) && Tbl("QuizResult"))
            {
                using (SqlCommand command = new SqlCommand("SELECT TOP 1 resultId FROM QuizResult WHERE studentId=@s AND quizId=@q ORDER BY attemptedDate DESC", connection))
                {
                    command.Parameters.AddWithValue("@s", studentId);
                    command.Parameters.AddWithValue("@q", quizId);
                    object lastResult = command.ExecuteScalar();
                    if (lastResult != null && lastResult != DBNull.Value)
                    {
                        string rid = lastResult.ToString();
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
                case "LV001":
                    return 1;
                case "LV002":
                    return 2;
                case "LV003":
                    return 3;
                default:
                    return 0;
            }
        }

        private bool Tbl(string t)
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

