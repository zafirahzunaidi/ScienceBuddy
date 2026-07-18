using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;
using System.Web.UI;
using System.IO; //for AI
using System.Net;
using System.Web.Script.Serialization;

namespace ScienceBuddy.Student
{
    public partial class UnitDetails : Page
    {
        private string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString; }
        }

        private string CurrentLanguage = "EN";

        // Flashcard label properties for Repeater binding
        protected string FlashcardQuestionLabel { get { return T("KEY IDEA", "IDEA UTAMA"); } }
        protected string FlashcardAnswerLabel { get { return T("LEARN THIS", "INGAT INI"); } }
        protected string FlashcardTapToReveal { get { return T("Tap to reveal", "Tekan untuk lihat"); } }
        protected string FlashcardTapToQuestion { get { return T("Tap to see front", "Tekan untuk lihat depan"); } }
        protected string FlashcardPrevText { get { return T("Previous", "Sebelum"); } }
        protected string FlashcardNextText { get { return T("Next", "Seterusnya"); } }
        protected string FlashcardFinishedText { get { return T("Finished!", "Selesai!"); } }

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

            InitLang();

            if (!IsPostBack)
            {
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

            // AI Flashcard labels
            btnGenerateFlashcards.Text = T("Try AI Study Flashcards!", "Cuba Kad Imbas AI");
            btnGenerateFlashcards.Attributes["data-creating"] = T("Creating\u2026", "Sedang mencipta\u2026");
            litFlashcardTitle.Text = T("Quick Cards", "Kad Pantas");
            litFlashcardDesc.Text = "";
            btnRegenerateFlashcards.Text = T("Create New Cards", "Cipta Kad Baharu");
            litFlashcardLoading.Text = T("Creating your flashcards\u2026", "Sedang mencipta kad imbas anda\u2026");
            litFlashcardLoadingSub.Text = T("This may take a few seconds.", "Proses ini mungkin mengambil beberapa saat.");
            litFlashcardError.Text = T("Flashcards could not be created. Please try again.", "Kad imbas tidak dapat dicipta. Sila cuba lagi.");
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
                        lnkQuizReview.HRef = ResolveUrl("~/Student/QuizResult.aspx?resultId=" + rid);
                    }
                }
            }
        }

        protected void btnGenerateFlashcards_Click(object sender, EventArgs e)
        {
            pnlAIFlashcards.Visible = true;
            pnlFlashcardError.Visible = false;
            litFlashcardError.Text = "";

            string unitId =
                Request.QueryString["unitId"];

            if (string.IsNullOrWhiteSpace(unitId))
            {
                pnlFlashcardError.Visible = true;

                litFlashcardError.Text = T(
                    "The unit could not be identified.",
                    "Unit tidak dapat dikenal pasti.");

                OpenFlashcardModal();
                return;
            }

            try
            {
                string lessonContent =
                    GetLessonContentForFlashcards(unitId);

                if (string.IsNullOrWhiteSpace(lessonContent))
                {
                    pnlFlashcardError.Visible = true;

                    litFlashcardError.Text = T(
                        "No lesson content is available for this unit.",
                        "Tiada kandungan pelajaran tersedia untuk unit ini.");

                    OpenFlashcardModal();
                    return;
                }

                List<AIFlashcard> flashcards = GenerateAIFlashcards(lessonContent);

                rptAIFlashcards.DataSource =flashcards;

                rptAIFlashcards.DataBind();

                pnlFlashcardLoading.Visible = false;

                pnlFlashcardError.Visible = false;

                OpenFlashcardModal();
            }
            catch (SqlException ex)
            {
                System.Diagnostics.Debug.WriteLine(
                    "Flashcard database error: " +
                    ex.Message);

                pnlFlashcardLoading.Visible = false;

                pnlFlashcardError.Visible = true;

                litFlashcardError.Text = T(
                    "The lesson content could not be loaded.",
                    "Kandungan pelajaran tidak dapat dimuatkan.");

                OpenFlashcardModal();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(
                    "AI flashcard error: " +
                    ex.Message);

                pnlFlashcardLoading.Visible =
                    false;

                pnlFlashcardError.Visible =
                    true;

                litFlashcardError.Text = T(
                    "Flashcards could not be created. Please try again.",
                    "Kad imbas tidak dapat dicipta. Sila cuba lagi.");

                OpenFlashcardModal();
            }
        }

        private void OpenFlashcardModal()
        {
            ClientScript.RegisterStartupScript(
                GetType(),
                "openFlashcardModal",
                "openFlashcardModal();",
                true);
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

        //-AI Flashcard-

        //Lesson-content method
        private string GetLessonContentForFlashcards(string unitId)
        {
            StringBuilder lessonText =
                new StringBuilder();

            const string sql = @"
                SELECT
                    l.lessonTitleEN,
                    l.lessonTitleBM,
                    l.lessonContentEN,
                    l.lessonContentBM
                FROM Lesson l
                INNER JOIN Subtopic st
                    ON st.subtopicId = l.subtopicId
                WHERE st.unitId = @unitId
                ORDER BY
                    st.orderNo,
                    l.orderNo,
                    l.lessonId";

            using (SqlConnection connection = new SqlConnection(ConnStr))
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@unitId",unitId);

                connection.Open();

                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string title = "";
                        string content = "";

                        if (CurrentLanguage == "BM")
                        {
                            if (reader["lessonTitleBM"] != DBNull.Value)
                            {
                                title = reader["lessonTitleBM"].ToString();
                            }

                            if (reader["lessonContentBM"] != DBNull.Value)
                            {
                                content = reader["lessonContentBM"].ToString();
                            }

                            if (string.IsNullOrWhiteSpace(title) &&
                                reader["lessonTitleEN"] != DBNull.Value)
                            {
                                title = reader["lessonTitleEN"].ToString();
                            }

                            if (string.IsNullOrWhiteSpace(content) &&
                                reader["lessonContentEN"] != DBNull.Value)
                            {
                                content = reader["lessonContentEN"].ToString();
                            }
                        }
                        else
                        {
                            if (reader["lessonTitleEN"] != DBNull.Value)
                            {
                                title = reader["lessonTitleEN"].ToString();
                            }

                            if (reader["lessonContentEN"] != DBNull.Value)
                            {
                                content = reader["lessonContentEN"].ToString();
                            }
                        }

                        content = CleanLessonHtml(content);

                        if (!string.IsNullOrWhiteSpace(content))
                        {
                            lessonText.AppendLine(
                                "LESSON: " + title);

                            lessonText.AppendLine(content);
                            lessonText.AppendLine();
                        }
                    }

                }
            }

            return lessonText.ToString();
        }

        //Generate AI Flashcards
        private List<AIFlashcard> GenerateAIFlashcards(string lessonContent)
        {
            string apiKey =
                ConfigurationManager.AppSettings[
                    "NvidiaApiKey"];

            string model =
                ConfigurationManager.AppSettings[
                    "NvidiaModel"];

            string endpoint =
                ConfigurationManager.AppSettings[
                    "NvidiaApiEndpoint"];

            if (string.IsNullOrWhiteSpace(model))
            {
                model = "meta/llama-3.1-8b-instruct";
            }

            if (string.IsNullOrWhiteSpace(endpoint))
            {
                endpoint =
                    "https://integrate.api.nvidia.com/" +
                    "v1/chat/completions";
            }

            if (string.IsNullOrWhiteSpace(apiKey) ||
                apiKey == "YOUR_NVIDIA_API_KEY_HERE")
            {
                throw new Exception(
                    "The NVIDIA API key is missing.");
            }

            string outputLanguage;

            if (CurrentLanguage == "BM")
            {
                outputLanguage = "Bahasa Melayu";
            }
            else
            {
                outputLanguage = "English";
            }

            string systemPrompt = @"
                You create short study flashcards for primary school Science students.

                Use only the lesson content supplied by the system.

                The flashcards are for learning and revision.
                They should not feel like an examination.

                FLASHCARD STYLE
                1. Create exactly 6 study flashcards.
                2. The front of each card should be a short learning cue,
                   concept name, process name or important idea.
                3. The front does not need to be written as a question.
                4. The back should teach or explain the idea clearly
                   in one or two short sentences.
                5. Use a useful mixture of:
                   - important concepts
                   - simple definitions
                   - functions
                   - processes
                   - examples
                   - comparisons
                   - healthy habits or important rules
                6. Cover different lessons from the unit when possible.
                7. Use only facts found in the supplied lesson content.
                8. Do not invent outside information.
                9. Do not combine quantities from different stages into one misleading total.
                10. Use simple language suitable for children aged 7 to 12.
                11. Keep the front below 8 words.
                12. Keep the back below 30 words.
                13. Avoid duplicate cards.
                14. Avoid yes-or-no cards.
                15. Do not use formal or difficult language.
                16. Use the requested language.

                Return valid JSON only.
                Do not include Markdown or code fences.

                Keep exactly these JSON property names because the system
                uses them:

                [
                    {
                        ""Question"": ""Short learning cue for the front"",
                        ""Answer"": ""Simple explanation for the back""
                    }
                ]";

            string userPrompt =
                "OUTPUT LANGUAGE: " +
                outputLanguage +
                "\n\nLESSON CONTENT:\n" +
                lessonContent;

            List<Dictionary<string, string>> messages =
                new List<Dictionary<string, string>>();

            messages.Add(
                new Dictionary<string, string>
                {
            { "role", "system" },
            { "content", systemPrompt }
                });

            messages.Add(
                new Dictionary<string, string>
                {
            { "role", "user" },
            { "content", userPrompt }
                });

            Dictionary<string, object> payload =
                new Dictionary<string, object>();

            payload["model"] = model;
            payload["messages"] = messages;
            payload["temperature"] = 0.5;
            payload["top_p"] = 0.9;
            payload["max_tokens"] = 900;
            payload["stream"] = false;

            JavaScriptSerializer serializer =
                new JavaScriptSerializer();

            serializer.MaxJsonLength =
                int.MaxValue;

            string jsonPayload =
                serializer.Serialize(payload);

            byte[] requestBytes =
                Encoding.UTF8.GetBytes(jsonPayload);

            HttpWebRequest request =
                (HttpWebRequest)
                WebRequest.Create(endpoint);

            request.Method = "POST";
            request.ContentType = "application/json";
            request.Accept = "application/json";

            request.Headers["Authorization"] =
                "Bearer " + apiKey;

            request.Timeout = 60000;
            request.ContentLength =
                requestBytes.Length;

            using (Stream requestStream =
                request.GetRequestStream())
            {
                requestStream.Write(
                    requestBytes,
                    0,
                    requestBytes.Length);
            }

            string responseBody;

            try
            {
                using (HttpWebResponse response =
                    (HttpWebResponse)
                    request.GetResponse())
                using (StreamReader reader =
                    new StreamReader(
                        response.GetResponseStream(),
                        Encoding.UTF8))
                {
                    responseBody =
                        reader.ReadToEnd();
                }
            }
            catch (WebException ex)
            {
                if (ex.Response != null)
                {
                    using (Stream errorStream =
                        ex.Response.GetResponseStream())
                    using (StreamReader reader =
                        new StreamReader(
                            errorStream,
                            Encoding.UTF8))
                    {
                        string errorBody =
                            reader.ReadToEnd();

                        System.Diagnostics.Debug.WriteLine(
                            "NVIDIA flashcard API error: " +
                            errorBody);
                    }
                }

                throw new Exception(
                    "The AI service could not create flashcards.");
            }

            Dictionary<string, object> responseData =
                serializer.DeserializeObject(
                    responseBody)
                as Dictionary<string, object>;

            if (responseData == null ||
                !responseData.ContainsKey("choices"))
            {
                throw new Exception(
                    "The AI response did not contain choices.");
            }

            object[] choices =
                responseData["choices"] as object[];

            if (choices == null ||
                choices.Length == 0)
            {
                throw new Exception(
                    "The AI returned no flashcards.");
            }

            Dictionary<string, object> firstChoice =
                choices[0]
                as Dictionary<string, object>;

            if (firstChoice == null ||
                !firstChoice.ContainsKey("message"))
            {
                throw new Exception(
                    "The AI response had no message.");
            }

            Dictionary<string, object> message =
                firstChoice["message"]
                as Dictionary<string, object>;

            if (message == null ||
                !message.ContainsKey("content"))
            {
                throw new Exception(
                    "The AI response had no content.");
            }

            string aiContent =
                Convert.ToString(
                    message["content"]);

            if (string.IsNullOrWhiteSpace(aiContent))
            {
                throw new Exception(
                    "The AI returned empty flashcards.");
            }

            string cleanJson =
                RemoveFlashcardCodeFences(aiContent);

            List<AIFlashcard> generatedCards =
                serializer.Deserialize<
                    List<AIFlashcard>>(cleanJson);

            if (generatedCards == null)
            {
                throw new Exception(
                    "The flashcard JSON could not be read.");
            }

            List<AIFlashcard> validCards =
                new List<AIFlashcard>();

            foreach (AIFlashcard card in generatedCards)
            {
                if (card == null)
                {
                    continue;
                }

                if (string.IsNullOrWhiteSpace(
                        card.Question) ||
                    string.IsNullOrWhiteSpace(
                        card.Answer))
                {
                    continue;
                }

                validCards.Add(card);

                if (validCards.Count == 6)
                {
                    break;
                }
            }

            if (validCards.Count != 6)
            {
                throw new Exception(
                    "The AI did not return exactly six valid flashcards.");
            }

            for (int index = 0;
                 index < validCards.Count;
                 index++)
            {
                validCards[index].CardNumber =
                    index + 1;
            }

            return validCards;
        }

        //Code-fence cleaner. Bcs sometimes AI return '''json[...]'''. but serializer needs only [...]
        private string RemoveFlashcardCodeFences(string text)
        {
            string cleanedText =
                text.Trim();

            if (cleanedText.StartsWith("```"))
            {
                int firstNewLine =
                    cleanedText.IndexOf('\n');

                if (firstNewLine >= 0)
                {
                    cleanedText =
                        cleanedText.Substring(
                            firstNewLine + 1);
                }

                int finalFence =
                    cleanedText.LastIndexOf("```");

                if (finalFence >= 0)
                {
                    cleanedText =
                        cleanedText.Substring(
                            0,
                            finalFence);
                }
            }

            return cleanedText.Trim();
        }

        //Flashcard structure
        public class AIFlashcard
        {
            public int CardNumber { get; set; }
            public string Question { get; set; }
            public string Answer { get; set; }
        }

        //To remove HTML from lesson content
        private string CleanLessonHtml(string html)
        {
            if (string.IsNullOrWhiteSpace(html))
            {
                return "";
            }

            string decodedText =
                HttpUtility.HtmlDecode(html);

            string textWithoutTags =
                System.Text.RegularExpressions.Regex.Replace(
                    decodedText,
                    "<.*?>",
                    " ");

            string cleanedText =
                System.Text.RegularExpressions.Regex.Replace(
                    textWithoutTags,
                    @"\s+",
                    " ");

            return cleanedText.Trim();
        }


    }
}

