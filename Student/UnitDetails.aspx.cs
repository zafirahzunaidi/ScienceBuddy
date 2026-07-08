using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace ScienceBuddy.Student
{
    public partial class UnitDetails1 : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        private string CurrentLanguage = "EN";
        private string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null || Session["role"].ToString() != "Student")
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
            { try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT preferredLanguage FROM [User] WHERE userId=@u", c))
              { cmd.Parameters.AddWithValue("@u", uid); c.Open(); var r = cmd.ExecuteScalar();
                if (r != null && r != DBNull.Value) { l = r.ToString(); Session["preferredLanguage"] = l; CurrentLanguage = l; return; } } } catch {} }
            CurrentLanguage = "EN"; Session["preferredLanguage"] = "EN";
        }

        private void LoadPage()
        {
            string unitId = Request.QueryString["unitId"];
            string userId = Session["userId"].ToString();
            if (string.IsNullOrEmpty(unitId) || !Tbl("Unit") || !Tbl("Student"))
            { ShowLocked(T("Invalid page","Halaman tidak sah"), T("No unit specified.","Tiada unit dinyatakan.")); return; }

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                string studentId = null, curLevel = "LV001";
                using (var cmd = new SqlCommand("SELECT studentId,currentlevelId FROM Student WHERE userId=@u", conn))
                { cmd.Parameters.AddWithValue("@u", userId);
                  using (var r = cmd.ExecuteReader()) { if (r.Read()) { studentId = r["studentId"].ToString(); curLevel = r["currentlevelId"]?.ToString() ?? "LV001"; } } }
                if (string.IsNullOrEmpty(studentId)) { ShowLocked(T("Not found","Tidak dijumpai"), T("Student profile missing.","Profil pelajar tiada.")); return; }

                string unitLevel = null;
                using (var cmd = new SqlCommand("SELECT levelId FROM Unit WHERE unitId=@u", conn))
                { cmd.Parameters.AddWithValue("@u", unitId); var r = cmd.ExecuteScalar(); unitLevel = r?.ToString(); }
                if (string.IsNullOrEmpty(unitLevel)) { ShowLocked(T("Unit not found","Unit tidak dijumpai"), T("This unit does not exist.","Unit ini tidak wujud.")); return; }

                if (Ord(unitLevel) > Ord(curLevel))
                { ShowLocked(T("Unit Locked","Unit Dikunci"), T("Complete your current level to access this unit.","Selesaikan tahap semasa untuk akses unit ini.")); return; }

                BuildHero(conn, unitId, unitLevel);
                BuildPath(conn, unitId);
                BuildLessons(conn, unitId, studentId);
                BuildMaterials(conn, unitId);
                BuildLab(conn, unitId, studentId);
                BuildQuiz(conn, unitId, studentId);
            }
        }

        private void ShowLocked(string t, string d)
        { pnlLocked.Visible = true; pnlMain.Visible = false; litLockedTitle.Text = t; litLockedDesc.Text = d; litLockedBtn.Text = T("Back","Kembali"); }

        private void BuildHero(SqlConnection conn, string unitId, string unitLevel)
        {
            bool bm = CurrentLanguage == "BM";
            using (var cmd = new SqlCommand(@"SELECT u.unitNameEN,u.unitNameBM,u.unitDescriptionEN,u.unitDescriptionBM,
                l.levelNameEN,l.levelNameBM FROM Unit u LEFT JOIN Level l ON l.levelId=u.levelId WHERE u.unitId=@u", conn))
            {
                cmd.Parameters.AddWithValue("@u", unitId);
                using (var r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        string n = bm ? r["unitNameBM"].ToString() : r["unitNameEN"].ToString();
                        if (string.IsNullOrWhiteSpace(n)) n = r["unitNameEN"].ToString();
                        string d = bm ? r["unitDescriptionBM"].ToString() : r["unitDescriptionEN"].ToString();
                        if (string.IsNullOrWhiteSpace(d)) d = r["unitDescriptionEN"].ToString();
                        string lv = bm ? r["levelNameBM"].ToString() : r["levelNameEN"].ToString();
                        if (string.IsNullOrWhiteSpace(lv)) lv = r["levelNameEN"].ToString();
                        litPageTitle.Text = HttpUtility.HtmlEncode(n);
                        litUnitName.Text = HttpUtility.HtmlEncode(n);
                        litUnitDesc.Text = HttpUtility.HtmlEncode(d);
                        litHeroLevel.Text = HttpUtility.HtmlEncode(lv);
                    }
                }
            }
            litBack.Text = T("My Learning","Pembelajaran Saya");
            litBarLbl.Text = T("Unit Progress","Kemajuan Unit");
        }

        private void BuildPath(SqlConnection conn, string unitId)
        {
            litPathLessons.Text = T("Lessons","Pelajaran");
            litPathMats.Text = T("Materials","Bahan");
            litPathLab.Text = T("Virtual Lab","Makmal Maya");
            litPathQuiz.Text = T("Unit Quiz","Kuiz Unit");

            int lc = 0, mc = 0, vc = 0, qc = 0;
            if (Tbl("Lesson") && Tbl("Subtopic"))
                using (var cmd = new SqlCommand("SELECT COUNT(*) FROM Lesson ls JOIN Subtopic st ON st.subtopicId=ls.subtopicId WHERE st.unitId=@u", conn))
                { cmd.Parameters.AddWithValue("@u", unitId); lc = (int)cmd.ExecuteScalar(); }
            if (Tbl("Material") && Tbl("Subtopic"))
                using (var cmd = new SqlCommand("SELECT COUNT(*) FROM Material m JOIN Subtopic st ON st.subtopicId=m.subtopicId WHERE st.unitId=@u AND m.status='Approved'", conn))
                { cmd.Parameters.AddWithValue("@u", unitId); mc = (int)cmd.ExecuteScalar(); }
            if (Tbl("VirtualLab"))
                using (var cmd = new SqlCommand("SELECT COUNT(*) FROM VirtualLab WHERE unitId=@u", conn))
                { cmd.Parameters.AddWithValue("@u", unitId); vc = (int)cmd.ExecuteScalar(); }
            if (Tbl("Quiz"))
                using (var cmd = new SqlCommand("SELECT COUNT(*) FROM Quiz WHERE unitId=@u AND quizType='Unit'", conn))
                { cmd.Parameters.AddWithValue("@u", unitId); qc = (int)cmd.ExecuteScalar(); }

            litPathLessonsCt.Text = lc + " " + T("available","tersedia");
            litPathMatsCt.Text = mc + " " + T("available","tersedia");
            litPathLabCt.Text = vc > 0 ? T("Available","Tersedia") : T("None","Tiada");
            litPathQuizCt.Text = qc > 0 ? T("Available","Tersedia") : T("None","Tiada");
        }

        private void BuildLessons(SqlConnection conn, string unitId, string studentId)
        {
            litLessonHd.Text = T("Subtopics & Lessons","Subtopik & Pelajaran");
            if (!Tbl("Subtopic")) { pnlLessons.Visible = false; return; }

            bool bm = CurrentLanguage == "BM";
            var doneSet = new HashSet<string>();
            if (Tbl("LessonProgress"))
                using (var cmd = new SqlCommand("SELECT lessonId FROM LessonProgress WHERE studentId=@s AND isCompleted=1", conn))
                { cmd.Parameters.AddWithValue("@s", studentId); using (var r = cmd.ExecuteReader()) while (r.Read()) doneSet.Add(r["lessonId"].ToString()); }

            var dtSt = new DataTable();
            using (var cmd = new SqlCommand("SELECT subtopicId,subtopicTitleEN,subtopicTitleBM,subtopicDescriptionEN,subtopicDescriptionBM,orderNo FROM Subtopic WHERE unitId=@u ORDER BY orderNo", conn))
            { cmd.Parameters.AddWithValue("@u", unitId); new SqlDataAdapter(cmd).Fill(dtSt); }

            if (dtSt.Rows.Count == 0) { pnlLessons.Visible = false; return; }

            var dtLs = new DataTable();
            if (Tbl("Lesson"))
                using (var cmd = new SqlCommand("SELECT ls.lessonId,ls.subtopicId,ls.lessonTitleEN,ls.lessonTitleBM,ls.orderNo FROM Lesson ls JOIN Subtopic st ON st.subtopicId=ls.subtopicId WHERE st.unitId=@u ORDER BY ls.orderNo", conn))
                { cmd.Parameters.AddWithValue("@u", unitId); new SqlDataAdapter(cmd).Fill(dtLs); }

            int totalLessons = dtLs.Rows.Count;
            int doneLessons = 0;

            var subtopics = new List<object>();
            foreach (DataRow st in dtSt.Rows)
            {
                string stId = st["subtopicId"].ToString();
                string stTitle = bm ? st["subtopicTitleBM"].ToString() : st["subtopicTitleEN"].ToString();
                if (string.IsNullOrWhiteSpace(stTitle)) stTitle = st["subtopicTitleEN"].ToString();
                string stDesc = bm ? st["subtopicDescriptionBM"].ToString() : st["subtopicDescriptionEN"].ToString();
                if (string.IsNullOrWhiteSpace(stDesc)) stDesc = st["subtopicDescriptionEN"].ToString();

                var lessons = new List<object>();
                foreach (DataRow ls in dtLs.Rows)
                {
                    if (ls["subtopicId"].ToString() != stId) continue;
                    string lid = ls["lessonId"].ToString();
                    bool done = doneSet.Contains(lid);
                    if (done) doneLessons++;
                    string lTitle = bm ? ls["lessonTitleBM"].ToString() : ls["lessonTitleEN"].ToString();
                    if (string.IsNullOrWhiteSpace(lTitle)) lTitle = ls["lessonTitleEN"].ToString();
                    lessons.Add(new { Title = HttpUtility.HtmlEncode(lTitle), Done = done,
                        Badge = done ? T("Completed","Selesai") : T("Start","Mula"),
                        Url = ResolveUrl("~/Student/Lesson.aspx?lessonId=" + lid) });
                }
                subtopics.Add(new { Title = HttpUtility.HtmlEncode(stTitle), Desc = HttpUtility.HtmlEncode(stDesc), Lessons = lessons });
            }

            rptSubtopics.DataSource = subtopics; rptSubtopics.DataBind();

            int pct = totalLessons > 0 ? Math.Min(doneLessons * 100 / totalLessons, 100) : 0;
            litBarPct.Text = pct + "%"; heroBar.Style["width"] = pct + "%";
        }

        private void BuildMaterials(SqlConnection conn, string unitId)
        {
            litMatHd.Text = T("Materials","Bahan Sokongan");
            litMatsEmpty.Text = T("No extra materials are available for this unit yet.","Tiada bahan tambahan tersedia untuk unit ini lagi.");

            if (!Tbl("Material") || !Tbl("Subtopic")) { pnlMats.Visible = false; pnlMatsEmpty.Visible = true; return; }

            var dt = new DataTable();
            using (var cmd = new SqlCommand(@"SELECT m.materialId,m.materialTitle,m.materialType,m.fileUrl,m.language
                FROM Material m JOIN Subtopic st ON st.subtopicId=m.subtopicId
                WHERE st.unitId=@u AND m.status='Approved' ORDER BY m.createdDate DESC", conn))
            { cmd.Parameters.AddWithValue("@u", unitId); new SqlDataAdapter(cmd).Fill(dt); }

            if (dt.Rows.Count == 0) { pnlMats.Visible = false; pnlMatsEmpty.Visible = true; return; }

            var list = new List<object>();
            foreach (DataRow r in dt.Rows)
            {
                list.Add(new { Title = HttpUtility.HtmlEncode(r["materialTitle"].ToString()),
                    Type = r["materialType"].ToString(), Lang = r["language"].ToString(),
                    Url = r["fileUrl"]?.ToString() ?? "#", Btn = T("Open","Buka") });
            }
            pnlMats.Visible = true; pnlMatsEmpty.Visible = false;
            rptMats.DataSource = list; rptMats.DataBind();
        }

        private void BuildLab(SqlConnection conn, string unitId, string studentId)
        {
            litLabHd.Text = T("Virtual Lab","Makmal Maya");
            litLabEmpty.Text = T("No virtual lab is available for this unit yet.","Tiada makmal maya tersedia untuk unit ini lagi.");

            if (!Tbl("VirtualLab")) { pnlLab.Visible = false; pnlLabEmpty.Visible = true; return; }

            bool bm = CurrentLanguage == "BM";
            using (var cmd = new SqlCommand("SELECT TOP 1 labId,labTitleEN,labTitleBM,labDescriptionEN,labDescriptionBM,difficulty FROM VirtualLab WHERE unitId=@u", conn))
            {
                cmd.Parameters.AddWithValue("@u", unitId);
                using (var r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        string t = bm ? r["labTitleBM"].ToString() : r["labTitleEN"].ToString();
                        if (string.IsNullOrWhiteSpace(t)) t = r["labTitleEN"].ToString();
                        string d = bm ? r["labDescriptionBM"].ToString() : r["labDescriptionEN"].ToString();
                        if (string.IsNullOrWhiteSpace(d)) d = r["labDescriptionEN"].ToString();
                        pnlLab.Visible = true; pnlLabEmpty.Visible = false;
                        litLabTitle.Text = HttpUtility.HtmlEncode(t);
                        litLabSub.Text = HttpUtility.HtmlEncode(d) + " • " + r["difficulty"].ToString();
                        litLabBtn.Text = T("Start Lab","Mula Makmal");
                    }
                    else { pnlLab.Visible = false; pnlLabEmpty.Visible = true; }
                }
            }
        }

        private void BuildQuiz(SqlConnection conn, string unitId, string studentId)
        {
            litQuizHd.Text = T("Unit Quiz","Kuiz Unit");
            litQuizEmpty.Text = T("Unit quiz is not available yet.","Kuiz unit belum tersedia lagi.");

            if (!Tbl("Quiz")) { pnlQuiz.Visible = false; pnlQuizEmpty.Visible = true; return; }

            bool bm = CurrentLanguage == "BM";
            string quizId = null;
            using (var cmd = new SqlCommand("SELECT TOP 1 quizId,quizTitleEN,quizTitleBM FROM Quiz WHERE unitId=@u AND quizType='Unit' AND (status IS NULL OR status IN ('Approved','Published')) ORDER BY createdAt DESC", conn))
            {
                cmd.Parameters.AddWithValue("@u", unitId);
                using (var r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        quizId = r["quizId"].ToString();
                        string t = bm ? r["quizTitleBM"].ToString() : r["quizTitleEN"].ToString();
                        if (string.IsNullOrWhiteSpace(t)) t = r["quizTitleEN"].ToString();
                        pnlQuiz.Visible = true; pnlQuizEmpty.Visible = false;
                        litQuizTitle.Text = HttpUtility.HtmlEncode(t);
                        litQuizSub.Text = T("Test your understanding of this unit.","Uji kefahaman anda tentang unit ini.");
                        litQuizBtn.Text = T("Start Quiz","Mula Kuiz");
                        lnkQuizStart.HRef = ResolveUrl("~/Student/Quiz.aspx?quizId=" + quizId);
                    }
                    else { pnlQuiz.Visible = false; pnlQuizEmpty.Visible = true; return; }
                }
            }

            if (!string.IsNullOrEmpty(quizId) && Tbl("QuizResult"))
            {
                using (var cmd = new SqlCommand("SELECT TOP 1 resultId FROM QuizResult WHERE studentId=@s AND quizId=@q ORDER BY attemptedDate DESC", conn))
                {
                    cmd.Parameters.AddWithValue("@s", studentId); cmd.Parameters.AddWithValue("@q", quizId);
                    object lastResult = cmd.ExecuteScalar();
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

        private static int Ord(string id) { switch (id) { case "LV001": return 1; case "LV002": return 2; case "LV003": return 3; default: return 0; } }
        private bool Tbl(string t) { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME=@t AND TABLE_TYPE='BASE TABLE'", c)) { cmd.Parameters.AddWithValue("@t", t); c.Open(); return (int)cmd.ExecuteScalar() > 0; } }
    }
}
