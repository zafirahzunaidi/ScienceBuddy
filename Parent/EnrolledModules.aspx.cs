using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace ScienceBuddy.Parent
{
    public partial class EnrolledModules : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        protected string CurrentLanguage = "EN";
        protected string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }

        private string _userId = "";
        private string _parentId = "";
        private string _studentId = "";

        private string ActiveFilter
        {
            get { return ViewState["Filter"] as string ?? "All"; }
            set { ViewState["Filter"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null || Session["role"].ToString() != "Parent")
            { Response.Redirect("~/Login.aspx", false); Context.ApplicationInstance.CompleteRequest(); return; }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            _userId = Session["userId"].ToString();
            LoadLanguage();
            LoadParentId();
            ResolveChild();

            if (!IsPostBack)
            {
                SetLabels();
                PopulateSidebarChild();
                if (!string.IsNullOrEmpty(_studentId))
                { pnlContent.Visible = true; pnlNoChild.Visible = false; LoadPage(); }
                else
                { pnlContent.Visible = false; pnlNoChild.Visible = true; }
            }
            else
            {
                SetLabels();
            }
        }

        private void PopulateSidebarChild()
        {
            ddlSidebarChild.Items.Clear();
            if (string.IsNullOrEmpty(_parentId)) return;
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT sp.studentId, s.name, s.nickname FROM dbo.[StudentParent] sp INNER JOIN dbo.[Student] s ON s.studentId=sp.studentId WHERE sp.parentId=@p", conn))
                {
                    cmd.Parameters.AddWithValue("@p", _parentId); conn.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            string sid = r["studentId"]?.ToString() ?? "";
                            string nm = r["nickname"]?.ToString() ?? "";
                            string n = r["name"]?.ToString() ?? "";
                            ddlSidebarChild.Items.Add(new System.Web.UI.WebControls.ListItem(!string.IsNullOrWhiteSpace(nm) ? nm : n, sid));
                        }
                    }
                }
                if (!string.IsNullOrEmpty(_studentId) && ddlSidebarChild.Items.FindByValue(_studentId) != null)
                    ddlSidebarChild.SelectedValue = _studentId;
            }
            catch (SqlException) { }
        }

        protected void SidebarChildChanged(object sender, EventArgs e)
        {
            string sel = ddlSidebarChild.SelectedValue;
            if (!string.IsNullOrEmpty(sel) && IsLinked(sel))
            {
                Session["selectedChildId"] = sel;
                Response.Redirect(Request.RawUrl, false);
                Context.ApplicationInstance.CompleteRequest();
            }
        }

        private void LoadLanguage()
        {
            string lang = Session["preferredLanguage"] as string;
            if (!string.IsNullOrEmpty(lang)) { CurrentLanguage = lang; return; }
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT preferredLanguage FROM dbo.[User] WHERE userId=@u", conn))
                { cmd.Parameters.AddWithValue("@u", _userId); conn.Open(); object r = cmd.ExecuteScalar(); if (r != null && r != DBNull.Value) { CurrentLanguage = r.ToString(); Session["preferredLanguage"] = CurrentLanguage; } }
            }
            catch (SqlException) { }
        }

        private void LoadParentId()
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT parentId FROM dbo.[Parent] WHERE userId=@u", conn))
                { cmd.Parameters.AddWithValue("@u", _userId); conn.Open(); object r = cmd.ExecuteScalar(); if (r != null && r != DBNull.Value) _parentId = r.ToString(); }
            }
            catch (SqlException) { }
        }

        private void ResolveChild()
        {
            string saved = Session["selectedChildId"] as string;
            if (!string.IsNullOrEmpty(saved) && IsLinked(saved)) { _studentId = saved; return; }
            if (string.IsNullOrEmpty(_parentId)) return;
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT TOP 1 studentId FROM dbo.[StudentParent] WHERE parentId=@p", conn))
                { cmd.Parameters.AddWithValue("@p", _parentId); conn.Open(); object r = cmd.ExecuteScalar(); if (r != null && r != DBNull.Value) { _studentId = r.ToString(); Session["selectedChildId"] = _studentId; } }
            }
            catch (SqlException) { }
        }

        private bool IsLinked(string sid)
        {
            if (string.IsNullOrEmpty(_parentId) || string.IsNullOrEmpty(sid)) return false;
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[StudentParent] WHERE parentId=@p AND studentId=@s", conn))
                { cmd.Parameters.AddWithValue("@p", _parentId); cmd.Parameters.AddWithValue("@s", sid); conn.Open(); return Convert.ToInt32(cmd.ExecuteScalar()) > 0; }
            }
            catch (SqlException) { return false; }
        }

        private void SetLabels()
        {
            litNoChild.Text = T("No linked child found. Please link a child account first.",
                                "Tiada anak dipautkan. Sila paut akaun anak terlebih dahulu.");
            litHeroTitle.Text = T("What My Child Is Learning", "Apa Yang Anak Saya Pelajari");
            litHeroSub.Text = T("Track your child's Science learning units, topics, and lesson progress.",
                                "Pantau unit pembelajaran Sains, topik, dan kemajuan pelajaran anak anda.");
            litSumUnitsLabel.Text = T("Total Units", "Jumlah Unit");
            litSumLessonsLabel.Text = T("Total Lessons", "Jumlah Pelajaran");
            litSumCompletedLabel.Text = T("Completed", "Selesai");
            litSumProgressLabel.Text = T("Progress", "Kemajuan");
            litNoUnits.Text = T("No enrolled modules found.", "Tiada modul didaftarkan ditemui.");
        }

        private void LoadPage()
        {
            LoadHeroChild();
            LoadSummary();
            LoadJourneyMap();
            LoadUnits();
        }

        private void LoadHeroChild()
        {
            try
            {
                const string sql = @"SELECT s.name, s.nickname, l.levelNameEN, l.levelNameBM
                    FROM dbo.[Student] s LEFT JOIN dbo.[Level] l ON l.levelId=s.currentLevelId
                    WHERE s.studentId=@s";
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@s", _studentId); conn.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            string name = r["name"]?.ToString() ?? "-";
                            string nick = r["nickname"]?.ToString() ?? "";
                            string lvl = CurrentLanguage == "BM" ? (r["levelNameBM"]?.ToString() ?? "-") : (r["levelNameEN"]?.ToString() ?? "-");
                            string display = !string.IsNullOrWhiteSpace(nick) ? nick : name;
                            litHeroChild.Text = Server.HtmlEncode(display) + " · " + Server.HtmlEncode(lvl);
                        }
                    }
                }
            }
            catch (SqlException) { }
        }

        private void LoadSummary()
        {
            int totalUnits = 0, totalLessons = 0, completedLessons = 0;
            try
            {
                const string sql = @"
                    SELECT
                        (SELECT COUNT(DISTINCT u.unitId) FROM dbo.[Unit] u INNER JOIN dbo.[Enrollment] e ON e.levelId=u.levelId WHERE e.studentId=@s) AS units,
                        (SELECT COUNT(*) FROM dbo.[Lesson] l INNER JOIN dbo.[Subtopic] st ON st.subtopicId=l.subtopicId INNER JOIN dbo.[Unit] u ON u.unitId=st.unitId INNER JOIN dbo.[Enrollment] e ON e.levelId=u.levelId WHERE e.studentId=@s) AS lessons,
                        (SELECT COUNT(*) FROM dbo.[LessonProgress] WHERE studentId=@s AND isCompleted=1) AS completed";
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@s", _studentId); conn.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            totalUnits = r["units"] != DBNull.Value ? Convert.ToInt32(r["units"]) : 0;
                            totalLessons = r["lessons"] != DBNull.Value ? Convert.ToInt32(r["lessons"]) : 0;
                            completedLessons = r["completed"] != DBNull.Value ? Convert.ToInt32(r["completed"]) : 0;
                        }
                    }
                }
            }
            catch (SqlException) { }

            int pct = totalLessons > 0 ? (int)Math.Round((double)completedLessons / totalLessons * 100) : 0;
            litSumUnits.Text = totalUnits.ToString();
            litSumLessons.Text = totalLessons.ToString();
            litSumCompleted.Text = completedLessons.ToString();
            litSumProgress.Text = pct + "%";
        }

        // ═══════════════════════════════════════════════════
        //  JOURNEY MAP
        // ═══════════════════════════════════════════════════

        private void LoadJourneyMap()
        {
            pnlJourneyMap.Controls.Clear();

            try
            {
                const string sql = @"
                    SELECT u.unitId, u.unitNameEN, u.unitNameBM, u.orderNo,
                        (SELECT COUNT(*) FROM dbo.[Lesson] ls INNER JOIN dbo.[Subtopic] st ON st.subtopicId=ls.subtopicId WHERE st.unitId=u.unitId) AS totalLessons,
                        (SELECT COUNT(*) FROM dbo.[LessonProgress] lp INNER JOIN dbo.[Lesson] ls ON ls.lessonId=lp.lessonId INNER JOIN dbo.[Subtopic] st ON st.subtopicId=ls.subtopicId WHERE st.unitId=u.unitId AND lp.studentId=@s AND lp.isCompleted=1) AS completedLessons
                    FROM dbo.[Unit] u
                    INNER JOIN dbo.[Enrollment] e ON e.levelId=u.levelId
                    WHERE e.studentId=@s
                    ORDER BY u.levelId, u.orderNo";

                var nodes = new List<string[]>(); // [name, status, pct, orderNo]

                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@s", _studentId);
                    conn.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        int idx = 0;
                        while (r.Read())
                        {
                            idx++;
                            string name = CurrentLanguage == "BM"
                                ? (r["unitNameBM"]?.ToString() ?? r["unitNameEN"]?.ToString() ?? "-")
                                : (r["unitNameEN"]?.ToString() ?? "-");
                            int total = r["totalLessons"] != DBNull.Value ? Convert.ToInt32(r["totalLessons"]) : 0;
                            int completed = r["completedLessons"] != DBNull.Value ? Convert.ToInt32(r["completedLessons"]) : 0;
                            string status = GetStatus(total, completed).ToLower().Replace(" ", "");
                            int pct = total > 0 ? (int)Math.Round((double)completed / total * 100) : 0;
                            nodes.Add(new string[] { name, status, pct.ToString(), idx.ToString() });
                        }
                    }
                }

                if (nodes.Count == 0) return;

                // Science icons by position (CSS-safe, no images needed)
                string[] icons = { "🔬", "🧪", "🧲", "🌱", "⚡", "🌍", "💧", "🔭", "🧬", "🪐", "☀️", "🌊", "🔥", "❄️", "🌡️" };

                string html = "<div class='em-journey'>"
                    + "<div class='em-journey-title'>" + T("Learning Journey", "Perjalanan Pembelajaran") + "</div>"
                    + "<div class='em-journey-path'>";

                for (int i = 0; i < nodes.Count; i++)
                {
                    string name = nodes[i][0];
                    string status = nodes[i][1];
                    string pct = nodes[i][2];
                    string num = nodes[i][3];
                    string icon = icons[i % icons.Length];

                    string badgeText = status == "completed" ? T("Completed", "Selesai")
                        : status == "inprogress" ? T("In Progress", "Sedang Belajar")
                        : T("Not Started", "Belum Mula");

                    string pctText = status == "completed" ? "100%"
                        : status == "notstarted" ? "0%"
                        : pct + "%";

                    // Card node
                    html += "<div class='em-jnode'>"
                        + "<div class='em-jcard " + status + "'>"
                        + "<span class='em-jcard-icon'>" + icon + "</span>"
                        + "<div class='em-jcard-num'>" + T("Unit ", "Unit ") + num + "</div>"
                        + "<div class='em-jcard-name'>" + Server.HtmlEncode(name) + "</div>"
                        + "<span class='em-jcard-badge " + status + "'>" + badgeText + "</span>"
                        + "<div class='em-jcard-pct'>" + pctText + " " + T("done", "selesai") + "</div>"
                        + "</div></div>";
                }

                html += "</div></div>";
                pnlJourneyMap.Controls.Add(new LiteralControl(html));
            }
            catch (SqlException) { }
        }

        // ═══════════════════════════════════════════════════
        //  FILTER / SEARCH
        // ═══════════════════════════════════════════════════

        protected void Filter_Click(object sender, EventArgs e)
        {
            var btn = sender as System.Web.UI.WebControls.LinkButton;
            ActiveFilter = btn?.CommandArgument ?? "All";
            SetFilterStyles();
            LoadUnits();
        }

        protected void Search_Changed(object sender, EventArgs e)
        {
            LoadUnits();
        }

        private void SetFilterStyles()
        {
            lnkAll.CssClass = ActiveFilter == "All" ? "em-filter-btn active" : "em-filter-btn";
            lnkInProgress.CssClass = ActiveFilter == "InProgress" ? "em-filter-btn active" : "em-filter-btn";
            lnkCompleted.CssClass = ActiveFilter == "Completed" ? "em-filter-btn active" : "em-filter-btn";
            lnkNotStarted.CssClass = ActiveFilter == "NotStarted" ? "em-filter-btn active" : "em-filter-btn";
        }

        // ═══════════════════════════════════════════════════
        //  UNIT CARDS
        // ═══════════════════════════════════════════════════

        private void LoadUnits()
        {
            pnlUnits.Controls.Clear();
            pnlNoUnits.Visible = false;
            SetFilterStyles();

            string keyword = txtSearch.Text.Trim();

            try
            {
                const string sql = @"
                    SELECT u.unitId, u.unitNameEN, u.unitNameBM, u.unitDescriptionEN, u.unitDescriptionBM, u.orderNo,
                        (SELECT COUNT(*) FROM dbo.[Lesson] ls INNER JOIN dbo.[Subtopic] st ON st.subtopicId=ls.subtopicId WHERE st.unitId=u.unitId) AS totalLessons,
                        (SELECT COUNT(*) FROM dbo.[LessonProgress] lp INNER JOIN dbo.[Lesson] ls ON ls.lessonId=lp.lessonId INNER JOIN dbo.[Subtopic] st ON st.subtopicId=ls.subtopicId WHERE st.unitId=u.unitId AND lp.studentId=@s AND lp.isCompleted=1) AS completedLessons
                    FROM dbo.[Unit] u
                    INNER JOIN dbo.[Enrollment] e ON e.levelId=u.levelId
                    WHERE e.studentId=@s
                    ORDER BY u.levelId, u.orderNo";

                var units = new List<UnitData>();

                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@s", _studentId);
                    conn.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            var u = new UnitData();
                            u.UnitId = r["unitId"]?.ToString() ?? "";
                            u.NameEN = r["unitNameEN"]?.ToString() ?? "";
                            u.NameBM = r["unitNameBM"]?.ToString() ?? "";
                            u.DescEN = r["unitDescriptionEN"]?.ToString() ?? "";
                            u.DescBM = r["unitDescriptionBM"]?.ToString() ?? "";
                            u.Total = r["totalLessons"] != DBNull.Value ? Convert.ToInt32(r["totalLessons"]) : 0;
                            u.Completed = r["completedLessons"] != DBNull.Value ? Convert.ToInt32(r["completedLessons"]) : 0;
                            units.Add(u);
                        }
                    }
                }

                bool hasVisible = false;
                foreach (var u in units)
                {
                    string status = GetStatus(u.Total, u.Completed);
                    if (ActiveFilter != "All" && ActiveFilter != status) continue;

                    string name = CurrentLanguage == "BM" ? (string.IsNullOrWhiteSpace(u.NameBM) ? u.NameEN : u.NameBM) : u.NameEN;
                    string desc = CurrentLanguage == "BM" ? (string.IsNullOrWhiteSpace(u.DescBM) ? u.DescEN : u.DescBM) : u.DescEN;

                    // Keyword filter
                    if (!string.IsNullOrEmpty(keyword))
                    {
                        if (name.IndexOf(keyword, StringComparison.OrdinalIgnoreCase) < 0 &&
                            desc.IndexOf(keyword, StringComparison.OrdinalIgnoreCase) < 0)
                            continue;
                    }

                    hasVisible = true;
                    int pct = u.Total > 0 ? (int)Math.Round((double)u.Completed / u.Total * 100) : 0;
                    string cssClass = "em-unit " + status.ToLower().Replace(" ", "");
                    string badgeClass = "em-unit-badge " + status.ToLower().Replace(" ", "");
                    string badgeText = status == "Completed" ? T("Completed", "Selesai")
                        : status == "InProgress" ? T("In Progress", "Sedang Belajar")
                        : T("Not Started", "Belum Mula");

                    string html = "<div class='" + cssClass + "'>"
                        + "<div class='em-unit-header'>"
                        + "<span class='em-unit-name'>" + Server.HtmlEncode(name) + "</span>"
                        + "<span class='" + badgeClass + "'>" + badgeText + "</span>"
                        + "</div>";

                    if (!string.IsNullOrWhiteSpace(desc))
                        html += "<div class='em-unit-desc'>" + Server.HtmlEncode(desc.Length > 120 ? desc.Substring(0, 120) + "..." : desc) + "</div>";

                    html += "<div class='em-unit-bar'><div class='em-unit-bar-fill' style='width:" + pct + "%'></div></div>"
                        + "<div class='em-unit-stats'><span>" + u.Completed + " / " + u.Total + " " + T("lessons", "pelajaran") + "</span><span>" + pct + "%</span></div>";

                    // Load subtopics
                    html += LoadSubtopics(u.UnitId);

                    html += "</div>";
                    pnlUnits.Controls.Add(new LiteralControl(html));
                }

                if (!hasVisible) pnlNoUnits.Visible = true;
            }
            catch (SqlException)
            {
                pnlNoUnits.Visible = true;
            }
        }

        private string LoadSubtopics(string unitId)
        {
            var subtopicNames = new List<string>();
            string html = "";

            try
            {
                // Get subtopics
                const string stSql = @"SELECT st.subtopicId, st.subtopicTitleEN, st.subtopicTitleBM
                    FROM dbo.[Subtopic] st WHERE st.unitId=@uid ORDER BY st.orderNo";

                var subtopics = new List<string[]>(); // [subtopicId, title]
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(stSql, conn))
                {
                    cmd.Parameters.AddWithValue("@uid", unitId);
                    conn.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            string stId = r["subtopicId"]?.ToString() ?? "";
                            string stTitle = CurrentLanguage == "BM"
                                ? (r["subtopicTitleBM"]?.ToString() ?? r["subtopicTitleEN"]?.ToString() ?? "-")
                                : (r["subtopicTitleEN"]?.ToString() ?? "-");
                            subtopics.Add(new string[] { stId, stTitle });
                            subtopicNames.Add(stTitle);
                        }
                    }
                }

                if (subtopics.Count == 0)
                {
                    return "<div class='em-unit-summary'>" + T("Lesson information is not available yet.", "Maklumat pelajaran belum tersedia lagi.") + "</div>";
                }

                // Generate summary
                int totalLessonsForSummary = 0;
                // First pass: count total lessons for summary text
                foreach (var st in subtopics)
                {
                    totalLessonsForSummary += CountLessonsInSubtopic(st[0]);
                }

                string summaryText = GenerateUnitSummary(subtopicNames, totalLessonsForSummary);
                html += "<div class='em-unit-summary'>" + Server.HtmlEncode(summaryText) + "</div>";

                // Subtopics & Learning Items section
                html += "<div class='em-st-section-title'>" + T("Subtopics & Learning Items", "Subtopik & Item Pembelajaran") + "</div>";

                foreach (var st in subtopics)
                {
                    string stId = st[0];
                    string stTitle = st[1];

                    // Get lessons, quizzes, materials for this subtopic
                    var lessons = GetLessonsForSubtopic(stId);
                    var quizzes = GetQuizzesForSubtopic(stId);
                    var materials = GetMaterialsForSubtopic(stId);

                    html += "<div class='em-st-row'>";
                    html += "<div class='em-st-header'><i class='bi bi-bookmark-fill' style='color:#2563EB;font-size:0.7rem;'></i> "
                        + Server.HtmlEncode(stTitle) + "</div>";

                    // Lessons
                    if (lessons.Count > 0)
                    {
                        html += "<div class='em-item-type lessons'><i class='bi bi-book-half'></i> " + T("Lessons", "Pelajaran") + "</div>";
                        html += "<div class='em-lesson-list'>";
                        foreach (var l in lessons)
                        {
                            bool isDone = l[2] == "1";
                            string icon = isDone
                                ? "<i class='bi bi-check-circle-fill done'></i>"
                                : "<i class='bi bi-circle pending'></i>";
                            html += "<div class='em-lesson-item'>" + icon + " " + Server.HtmlEncode(l[1]) + "</div>";
                        }
                        html += "</div>";
                    }

                    // Quizzes
                    if (quizzes.Count > 0)
                    {
                        html += "<div class='em-item-type quizzes'><i class='bi bi-patch-question-fill'></i> " + T("Quizzes", "Kuiz") + "</div>";
                        html += "<div class='em-lesson-list'>";
                        foreach (var q in quizzes)
                        {
                            bool attempted = q[2] == "1";
                            string icon = attempted
                                ? "<i class='bi bi-check-circle-fill done'></i>"
                                : "<i class='bi bi-circle pending'></i>";
                            html += "<div class='em-lesson-item'>" + icon + " " + Server.HtmlEncode(q[1]) + "</div>";
                        }
                        html += "</div>";
                    }

                    // Materials
                    if (materials.Count > 0)
                    {
                        html += "<div class='em-item-type materials'><i class='bi bi-file-earmark-text-fill'></i> " + T("Materials", "Bahan") + "</div>";
                        html += "<div class='em-lesson-list'>";
                        foreach (var m in materials)
                        {
                            html += "<div class='em-lesson-item'><i class='bi bi-file-earmark' style='color:#7C3AED;font-size:0.72rem;'></i> " + Server.HtmlEncode(m) + "</div>";
                        }
                        html += "</div>";
                    }

                    html += "</div>";
                }
            }
            catch (SqlException) { }

            return html;
        }

        private int CountLessonsInSubtopic(string subtopicId)
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[Lesson] WHERE subtopicId=@st", conn))
                {
                    cmd.Parameters.AddWithValue("@st", subtopicId);
                    conn.Open();
                    return Convert.ToInt32(cmd.ExecuteScalar());
                }
            }
            catch (SqlException) { return 0; }
        }

        private List<string[]> GetLessonsForSubtopic(string subtopicId)
        {
            var lessons = new List<string[]>(); // [lessonId, title, isCompleted("0"/"1")]
            try
            {
                const string sql = @"
                    SELECT l.lessonId,
                           CASE WHEN @lang='BM' THEN ISNULL(l.lessonTitleBM, l.lessonTitleEN) ELSE l.lessonTitleEN END AS lessonTitle,
                           ISNULL((SELECT CAST(lp.isCompleted AS INT) FROM dbo.[LessonProgress] lp WHERE lp.lessonId=l.lessonId AND lp.studentId=@s), 0) AS isCompleted
                    FROM dbo.[Lesson] l WHERE l.subtopicId=@st ORDER BY l.orderNo";
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@st", subtopicId);
                    cmd.Parameters.AddWithValue("@s", _studentId);
                    cmd.Parameters.AddWithValue("@lang", CurrentLanguage);
                    conn.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            lessons.Add(new string[] {
                                r["lessonId"]?.ToString() ?? "",
                                r["lessonTitle"]?.ToString() ?? "-",
                                (r["isCompleted"] != DBNull.Value && Convert.ToInt32(r["isCompleted"]) == 1) ? "1" : "0"
                            });
                        }
                    }
                }
            }
            catch (SqlException) { }
            return lessons;
        }

        private List<string[]> GetQuizzesForSubtopic(string subtopicId)
        {
            var quizzes = new List<string[]>(); // [quizId, title, attempted("0"/"1")]
            try
            {
                const string sql = @"
                    SELECT q.quizId,
                           CASE WHEN @lang='BM' THEN ISNULL(q.quizTitleBM, q.quizTitleEN) ELSE q.quizTitleEN END AS quizTitle,
                           CASE WHEN (SELECT COUNT(*) FROM dbo.[QuizResult] qr WHERE qr.quizId=q.quizId AND qr.studentId=@s) > 0 THEN 1 ELSE 0 END AS attempted
                    FROM dbo.[Quiz] q WHERE q.subtopicId=@st";
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@st", subtopicId);
                    cmd.Parameters.AddWithValue("@s", _studentId);
                    cmd.Parameters.AddWithValue("@lang", CurrentLanguage);
                    conn.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            quizzes.Add(new string[] {
                                r["quizId"]?.ToString() ?? "",
                                r["quizTitle"]?.ToString() ?? "-",
                                (r["attempted"] != DBNull.Value && Convert.ToInt32(r["attempted"]) == 1) ? "1" : "0"
                            });
                        }
                    }
                }
            }
            catch (SqlException) { }
            return quizzes;
        }

        private List<string> GetMaterialsForSubtopic(string subtopicId)
        {
            var materials = new List<string>();
            try
            {
                const string sql = "SELECT materialTitle FROM dbo.[Material] WHERE subtopicId=@st AND (status='Approved' OR status IS NULL)";
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@st", subtopicId);
                    conn.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            string title = r["materialTitle"]?.ToString() ?? "";
                            if (!string.IsNullOrWhiteSpace(title))
                                materials.Add(title);
                        }
                    }
                }
            }
            catch (SqlException) { }
            return materials;
        }

        private string GenerateUnitSummary(List<string> subtopicNames, int totalLessons)
        {
            if (subtopicNames.Count == 0)
                return T("Lesson information is not available yet.", "Maklumat pelajaran belum tersedia lagi.");

            string joined;
            if (subtopicNames.Count == 1)
                joined = subtopicNames[0];
            else if (subtopicNames.Count == 2)
                joined = subtopicNames[0] + " " + T("and", "dan") + " " + subtopicNames[1];
            else
                joined = string.Join(", ", subtopicNames.GetRange(0, subtopicNames.Count - 1))
                    + ", " + T("and", "dan") + " " + subtopicNames[subtopicNames.Count - 1];

            return T(
                "This unit helps your child learn about " + joined + " through " + totalLessons + " lessons.",
                "Unit ini membantu anak anda belajar tentang " + joined + " melalui " + totalLessons + " pelajaran.");
        }

        private bool IsSubtopicDone(string subtopicId)
        {
            try
            {
                const string sql = @"
                    SELECT CASE WHEN COUNT(*)>0 AND COUNT(*)=(SELECT COUNT(*) FROM dbo.[Lesson] WHERE subtopicId=@st)
                    THEN 1 ELSE 0 END
                    FROM dbo.[LessonProgress] lp
                    INNER JOIN dbo.[Lesson] l ON l.lessonId=lp.lessonId
                    WHERE l.subtopicId=@st AND lp.studentId=@s AND lp.isCompleted=1";
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@st", subtopicId);
                    cmd.Parameters.AddWithValue("@s", _studentId);
                    conn.Open();
                    return Convert.ToInt32(cmd.ExecuteScalar()) == 1;
                }
            }
            catch (SqlException) { return false; }
        }

        private string GetStatus(int total, int completed)
        {
            if (total == 0) return "NotStarted";
            if (completed >= total) return "Completed";
            if (completed > 0) return "InProgress";
            return "NotStarted";
        }

        private class UnitData
        {
            public string UnitId { get; set; }
            public string NameEN { get; set; }
            public string NameBM { get; set; }
            public string DescEN { get; set; }
            public string DescBM { get; set; }
            public int Total { get; set; }
            public int Completed { get; set; }
        }
    }
}
