using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Parent
{
    public partial class EnrolledModules : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        protected string CurrentLanguage = "EN";
        protected string T(string en, string bm) => CurrentLanguage == "BM" ? bm : en;
        private string _userId = "", _parentId = "", _studentId = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null || Session["role"].ToString() != "Parent")
            { Response.Redirect("~/Login.aspx", false); Context.ApplicationInstance.CompleteRequest(); return; }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            _userId = Session["userId"].ToString();
            LoadLanguage(); LoadParentId(); ResolveChild(); LoadUnreadBadge();

            if (!IsPostBack)
            {
                PopulateSidebarChild();
                LoadView();
            }
            else { LoadView(); }
        }

        protected void SidebarChildChanged(object sender, EventArgs e)
        {
            string sel = ddlSidebarChild.SelectedValue;
            if (!string.IsNullOrEmpty(sel) && IsLinked(sel))
            {
                Session["selectedChildId"] = sel;
                _studentId = sel;
            }
            LoadView();
        }

        private void LoadView()
        {
            pnlLevels.Visible = false; pnlLevelDetail.Visible = false; pnlUnitDetail.Visible = false; pnlNoChild.Visible = false;
            if (string.IsNullOrEmpty(_studentId)) { pnlNoChild.Visible = true; return; }

            string qsLevel = Request.QueryString["levelId"];
            string qsUnit = Request.QueryString["unitId"];

            if (!string.IsNullOrEmpty(qsUnit) && !string.IsNullOrEmpty(qsLevel))
            { LoadUnitDetailView(qsUnit, qsLevel); }
            else if (!string.IsNullOrEmpty(qsLevel))
            { LoadLevelDetailView(qsLevel); }
            else
            { LoadLevelsView(); }
        }

        // ══════════════════════════════════════════════════════════════
        //  LEVELS VIEW
        // ══════════════════════════════════════════════════════════════
        private void LoadLevelsView()
        {
            pnlLevels.Visible = true;
            pnlLevelsGrid.Controls.Clear();
            string[] bgColors = { "#E0F7FA", "#FFF3E0", "#F3E5F5" };
            string[] icons = { "🔬", "🚀", "⚡" };
            int idx = 0;
            try
            {
                using (var c = new SqlConnection(ConnStr))
                {
                    c.Open();
                    using (var cmd = new SqlCommand("SELECT levelId, levelNameEN, levelNameBM, levelDescriptionEN, levelDescriptionBM FROM dbo.[Level] ORDER BY levelId", c))
                    using (var r = cmd.ExecuteReader())
                    {
                        StringBuilder sb = new StringBuilder();
                        while (r.Read())
                        {
                            string levelId = r["levelId"].ToString();
                            string name = CurrentLanguage == "BM" ? r["levelNameBM"].ToString() : r["levelNameEN"].ToString();
                            string desc = CurrentLanguage == "BM" ? (r["levelDescriptionBM"] != DBNull.Value ? r["levelDescriptionBM"].ToString() : "") : (r["levelDescriptionEN"] != DBNull.Value ? r["levelDescriptionEN"].ToString() : "");
                            bool unlocked = IsLevelUnlocked(levelId);
                            int unitCount = GetUnitCount(levelId);
                            string bg = bgColors[idx % 3];
                            string icon = icons[idx % 3];
                            idx++;

                            if (unlocked)
                            {
                                sb.AppendFormat(@"<a href='EnrolledModules.aspx?levelId={0}' class='pt-level-card pt-level-card-unlocked' style='--card-bg:{1};'>
                                    <div class='pt-level-image'><span class='pt-level-emoji'>{2}</span></div>
                                    <div class='pt-level-body'>
                                        <div class='pt-level-name'>{3}</div>
                                        <div class='pt-level-count'>{4} {5}</div>
                                        <div class='pt-level-desc'>{6}</div>
                                        <span class='pt-learning-badge pt-badge-unlocked'><i class='bi bi-unlock-fill'></i> {7}</span>
                                    </div>
                                </a>", levelId, bg, icon, Server.HtmlEncode(name), unitCount, T("units", "unit"), Server.HtmlEncode(desc.Length > 80 ? desc.Substring(0, 80) + "..." : desc), T("Unlocked", "Dibuka"));
                            }
                            else
                            {
                                sb.AppendFormat(@"<div class='pt-level-card pt-level-card-locked'>
                                    <div class='pt-level-lock-overlay'><i class='bi bi-lock-fill'></i></div>
                                    <div class='pt-level-image'><span class='pt-level-emoji'>{0}</span></div>
                                    <div class='pt-level-body'>
                                        <div class='pt-level-name'>{1}</div>
                                        <div class='pt-level-count'>{2} {3}</div>
                                        <span class='pt-learning-badge pt-badge-locked'><i class='bi bi-lock-fill'></i> {4}</span>
                                        <div class='pt-level-locked-msg'>{5}</div>
                                    </div>
                                </div>", icon, Server.HtmlEncode(name), unitCount, T("units", "unit"), T("Locked", "Dikunci"), T("This level has not been unlocked by your child yet.", "Tahap ini belum dibuka oleh anak anda."));
                            }
                        }
                        if (sb.Length > 0) pnlLevelsGrid.Controls.Add(new LiteralControl(sb.ToString()));
                    }
                }
            }
            catch { }
        }

        // ══════════════════════════════════════════════════════════════
        //  LEVEL DETAILS VIEW
        // ══════════════════════════════════════════════════════════════
        private void LoadLevelDetailView(string levelId)
        {
            if (!IsLevelUnlocked(levelId)) { LoadLevelsView(); return; }
            pnlLevelDetail.Visible = true;

            // Hero
            try
            {
                using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT levelNameEN, levelNameBM, levelDescriptionEN, levelDescriptionBM FROM dbo.[Level] WHERE levelId=@id", c))
                {
                    cmd.Parameters.AddWithValue("@id", levelId); c.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            string name = CurrentLanguage == "BM" ? r["levelNameBM"].ToString() : r["levelNameEN"].ToString();
                            string desc = CurrentLanguage == "BM" ? (r["levelDescriptionBM"] != DBNull.Value ? r["levelDescriptionBM"].ToString() : "") : (r["levelDescriptionEN"] != DBNull.Value ? r["levelDescriptionEN"].ToString() : "");
                            pnlLevelHero.Controls.Clear();
                            pnlLevelHero.Controls.Add(new LiteralControl(string.Format(
                                @"<div class='pt-level-detail-illustration'><i class='bi bi-stars'></i></div>
                                <div class='pt-level-detail-content'><h2>{0}</h2><p>{1}</p></div>", Server.HtmlEncode(name), Server.HtmlEncode(desc))));
                        }
                    }
                }
            }
            catch { }

            // Unit count info
            int unitCount = GetUnitCount(levelId);
            litUnitCountInfo.Text = string.Format(T("This level contains {0} units.", "Tahap ini mengandungi {0} unit."), unitCount);

            // Units grid
            pnlUnitsGrid.Controls.Clear();
            pnlNoUnits.Visible = false;
            try
            {
                using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT unitId, unitNameEN, unitNameBM, unitDescriptionEN, unitDescriptionBM, orderNo FROM dbo.[Unit] WHERE levelId=@id ORDER BY orderNo", c))
                {
                    cmd.Parameters.AddWithValue("@id", levelId); c.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        StringBuilder sb = new StringBuilder(); bool has = false;
                        string[] cardColors = { "#FFF8E1", "#E8F5E9", "#E3F2FD", "#FCE4EC", "#F3E5F5", "#E0F2F1" };
                        int ci = 0;
                        while (r.Read())
                        {
                            has = true;
                            string unitId = r["unitId"].ToString();
                            string uName = CurrentLanguage == "BM" ? r["unitNameBM"].ToString() : r["unitNameEN"].ToString();
                            string uDesc = CurrentLanguage == "BM" ? (r["unitDescriptionBM"] != DBNull.Value ? r["unitDescriptionBM"].ToString() : "") : (r["unitDescriptionEN"] != DBNull.Value ? r["unitDescriptionEN"].ToString() : "");
                            int subtopicCount = GetSubtopicCount(unitId);
                            int lessonCount = GetLessonCountForUnit(unitId);
                            int completed = GetCompletedLessonsForUnit(unitId);
                            int pct = lessonCount > 0 ? (int)Math.Round((double)completed / lessonCount * 100) : 0;
                            string progressStatus = pct == 0 ? T("Not Started", "Belum Mula") : pct >= 100 ? T("Completed", "Selesai") : T("In Progress", "Sedang Berjalan");
                            string cardBg = cardColors[ci % cardColors.Length]; ci++;

                            sb.AppendFormat(@"<a href='EnrolledModules.aspx?levelId={0}&unitId={1}' class='pt-unit-card' style='--card-bg:{2};'>
                                <div class='pt-unit-card-header'><span class='pt-unit-card-icon'><i class='bi bi-book-half'></i></span><span class='pt-unit-card-order'>#{3}</span></div>
                                <div class='pt-unit-card-name'>{4}</div>
                                <div class='pt-unit-card-desc'>{5}</div>
                                <div class='pt-unit-stat-chips'>
                                    <span class='pt-unit-stat-chip'><i class='bi bi-layers'></i> {6} {7}</span>
                                    <span class='pt-unit-stat-chip'><i class='bi bi-file-text'></i> {8} {9}</span>
                                </div>
                                <div class='pt-unit-progress-bar'><div class='pt-unit-progress-fill' style='width:{10}%;'></div></div>
                                <div class='pt-unit-progress-label'>{10}% &bull; {11}</div>
                            </a>", levelId, unitId, cardBg, r["orderNo"], Server.HtmlEncode(uName),
                                Server.HtmlEncode(uDesc.Length > 60 ? uDesc.Substring(0, 60) + "..." : uDesc),
                                subtopicCount, T("subtopics", "subtopik"), lessonCount, T("lessons", "pelajaran"), pct, progressStatus);
                        }
                        if (has) pnlUnitsGrid.Controls.Add(new LiteralControl(sb.ToString()));
                        else pnlNoUnits.Visible = true;
                    }
                }
            }
            catch { pnlNoUnits.Visible = true; }
        }

        // ══════════════════════════════════════════════════════════════
        //  UNIT DETAILS VIEW
        // ══════════════════════════════════════════════════════════════
        private void LoadUnitDetailView(string unitId, string levelId)
        {
            if (!IsLevelUnlocked(levelId)) { LoadLevelsView(); return; }
            pnlUnitDetail.Visible = true;
            lnkBackToUnits.HRef = "EnrolledModules.aspx?levelId=" + Server.UrlEncode(levelId);

            // Unit hero
            pnlUnitHero.Controls.Clear();
            try
            {
                using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT unitNameEN, unitNameBM, unitDescriptionEN, unitDescriptionBM FROM dbo.[Unit] WHERE unitId=@id", c))
                {
                    cmd.Parameters.AddWithValue("@id", unitId); c.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            string uName = CurrentLanguage == "BM" ? r["unitNameBM"].ToString() : r["unitNameEN"].ToString();
                            string uDesc = CurrentLanguage == "BM" ? (r["unitDescriptionBM"] != DBNull.Value ? r["unitDescriptionBM"].ToString() : "") : (r["unitDescriptionEN"] != DBNull.Value ? r["unitDescriptionEN"].ToString() : "");
                            int totalLessons = GetLessonCountForUnit(unitId);
                            int completedLessons = GetCompletedLessonsForUnit(unitId);
                            int pct = totalLessons > 0 ? (int)Math.Round((double)completedLessons / totalLessons * 100) : 0;
                            string status = pct == 0 ? T("Not Started", "Belum Mula") : pct >= 100 ? T("Completed", "Selesai") : T("In Progress", "Sedang Berjalan");

                            pnlUnitHero.Controls.Add(new LiteralControl(string.Format(
                                @"<h2 class='pt-unit-hero-title'>{0}</h2>
                                <div class='pt-unit-hero-stats'>
                                    <span class='pt-unit-hero-stat'><i class='bi bi-journal-text'></i> {1} / {2} {3}</span>
                                    <span class='pt-unit-hero-pct'>{4}%</span>
                                    <span class='pt-learning-badge {5}'>{6}</span>
                                </div>
                                <div class='pt-unit-hero-progress'><div class='pt-unit-hero-progress-fill' style='width:{4}%;'></div></div>",
                                Server.HtmlEncode(uName), completedLessons, totalLessons, T("Lessons", "Pelajaran"), pct,
                                pct >= 100 ? "pt-badge-complete" : pct > 0 ? "pt-badge-progress" : "pt-badge-notstarted", status)));

                            litUnitDescription.Text = Server.HtmlEncode(uDesc);
                        }
                    }
                }
            }
            catch { }

            // Subtopics
            pnlSubtopicsGrid.Controls.Clear();
            pnlNoSubtopics.Visible = false;
            try
            {
                int quizCountForUnit = 0;
                using (var c2 = new SqlConnection(ConnStr)) using (var cmd2 = new SqlCommand("SELECT COUNT(*) FROM dbo.[Quiz] WHERE unitId=@uid", c2))
                { cmd2.Parameters.AddWithValue("@uid", unitId); c2.Open(); quizCountForUnit = (int)cmd2.ExecuteScalar(); }

                using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT subtopicId, subtopicTitleEN, subtopicTitleBM, subtopicDescriptionEN, subtopicDescriptionBM FROM dbo.[Subtopic] WHERE unitId=@id ORDER BY subtopicId", c))
                {
                    cmd.Parameters.AddWithValue("@id", unitId); c.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        StringBuilder sb = new StringBuilder(); bool has = false;
                        string[] stColors = { "#FFFDE7", "#E8F5E9", "#E3F2FD", "#FFF3E0", "#F3E5F5", "#E0F2F1" };
                        int si = 0;
                        while (r.Read())
                        {
                            has = true;
                            string stId = r["subtopicId"].ToString();
                            string stName = CurrentLanguage == "BM" ? r["subtopicTitleBM"].ToString() : r["subtopicTitleEN"].ToString();
                            string stDesc = CurrentLanguage == "BM" ? (r["subtopicDescriptionBM"] != DBNull.Value ? r["subtopicDescriptionBM"].ToString() : "") : (r["subtopicDescriptionEN"] != DBNull.Value ? r["subtopicDescriptionEN"].ToString() : "");
                            int lessonCnt = GetLessonCountForSubtopic(stId);
                            int materialCnt = GetMaterialCountForSubtopic(stId);
                            string cardBg = stColors[si % stColors.Length]; si++;

                            sb.AppendFormat(@"<div class='pt-subtopic-card' style='--card-bg:{0};'>
                                <div class='pt-subtopic-card-icon'><i class='bi bi-lightbulb-fill'></i></div>
                                <div class='pt-subtopic-card-name'>{1}</div>
                                <div class='pt-subtopic-card-desc'>{2}</div>
                                <div class='pt-subtopic-stat-row'>
                                    <span><i class='bi bi-file-text'></i> {3} {4}</span>
                                    <span><i class='bi bi-paperclip'></i> {5} {6}</span>
                                </div>
                            </div>", cardBg, Server.HtmlEncode(stName),
                                Server.HtmlEncode(stDesc.Length > 80 ? stDesc.Substring(0, 80) + "..." : stDesc),
                                lessonCnt, T("Lessons", "Pelajaran"), materialCnt, T("Materials", "Bahan"));
                        }
                        // Show quiz count for the unit at the end
                        if (has && quizCountForUnit > 0)
                        {
                            sb.AppendFormat(@"<div class='pt-subtopic-card' style='--card-bg:#FCE4EC;'>
                                <div class='pt-subtopic-card-icon'><i class='bi bi-patch-question-fill'></i></div>
                                <div class='pt-subtopic-card-name'>{0}</div>
                                <div class='pt-subtopic-card-desc'>{1}</div>
                                <div class='pt-subtopic-stat-row'><span><i class='bi bi-ui-checks'></i> {2} {0}</span></div>
                            </div>", T("Quizzes", "Kuiz"), T("Quizzes available for this unit.", "Kuiz yang tersedia untuk unit ini."), quizCountForUnit);
                        }
                        if (has) pnlSubtopicsGrid.Controls.Add(new LiteralControl(sb.ToString()));
                        else pnlNoSubtopics.Visible = true;
                    }
                }
            }
            catch { pnlNoSubtopics.Visible = true; }
        }

        // ══════════════════════════════════════════════════════════════
        //  HELPER METHODS
        // ══════════════════════════════════════════════════════════════
        private bool IsLevelUnlocked(string levelId)
        {
            try
            {
                using (var c = new SqlConnection(ConnStr))
                {
                    c.Open();
                    // Check if level is at or below child's current level
                    using (var cmd = new SqlCommand("SELECT currentLevelId FROM dbo.[Student] WHERE studentId=@sid", c))
                    {
                        cmd.Parameters.AddWithValue("@sid", _studentId);
                        var result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            string currentLevelId = result.ToString();
                            if (string.Compare(levelId, currentLevelId, StringComparison.OrdinalIgnoreCase) <= 0)
                                return true;
                        }
                    }
                    // Also check Enrollment
                    using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[Enrollment] WHERE studentId=@sid AND levelId=@lid AND status='Active'", c))
                    {
                        cmd.Parameters.AddWithValue("@sid", _studentId);
                        cmd.Parameters.AddWithValue("@lid", levelId);
                        return (int)cmd.ExecuteScalar() > 0;
                    }
                }
            }
            catch { return false; }
        }
        private int GetUnitCount(string levelId)
        {
            try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[Unit] WHERE levelId=@id", c)) { cmd.Parameters.AddWithValue("@id", levelId); c.Open(); return (int)cmd.ExecuteScalar(); } } catch { return 0; }
        }
        private int GetSubtopicCount(string unitId)
        {
            try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[Subtopic] WHERE unitId=@id", c)) { cmd.Parameters.AddWithValue("@id", unitId); c.Open(); return (int)cmd.ExecuteScalar(); } } catch { return 0; }
        }
        private int GetLessonCountForUnit(string unitId)
        {
            try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[Lesson] l INNER JOIN dbo.[Subtopic] s ON l.subtopicId=s.subtopicId WHERE s.unitId=@id", c)) { cmd.Parameters.AddWithValue("@id", unitId); c.Open(); return (int)cmd.ExecuteScalar(); } } catch { return 0; }
        }
        private int GetCompletedLessonsForUnit(string unitId)
        {
            try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[LessonProgress] lp INNER JOIN dbo.[Lesson] l ON lp.lessonId=l.lessonId INNER JOIN dbo.[Subtopic] s ON l.subtopicId=s.subtopicId WHERE s.unitId=@uid AND lp.studentId=@sid AND lp.isCompleted=1", c)) { cmd.Parameters.AddWithValue("@uid", unitId); cmd.Parameters.AddWithValue("@sid", _studentId); c.Open(); return (int)cmd.ExecuteScalar(); } } catch { return 0; }
        }
        private int GetLessonCountForSubtopic(string subtopicId)
        {
            try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[Lesson] WHERE subtopicId=@id", c)) { cmd.Parameters.AddWithValue("@id", subtopicId); c.Open(); return (int)cmd.ExecuteScalar(); } } catch { return 0; }
        }
        private int GetMaterialCountForSubtopic(string subtopicId)
        {
            try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[Material] WHERE subtopicId=@id", c)) { cmd.Parameters.AddWithValue("@id", subtopicId); c.Open(); return (int)cmd.ExecuteScalar(); } } catch { return 0; }
        }

        // ══════════════════════════════════════════════════════════════
        //  SHARED INFRASTRUCTURE
        // ══════════════════════════════════════════════════════════════
        private void LoadLanguage() { string l = Session["preferredLanguage"] as string; if (!string.IsNullOrEmpty(l)) { CurrentLanguage = l; return; } try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT preferredLanguage FROM dbo.[User] WHERE userId=@u", c)) { cmd.Parameters.AddWithValue("@u", _userId); c.Open(); var r = cmd.ExecuteScalar(); if (r != null && r != DBNull.Value) { CurrentLanguage = r.ToString(); Session["preferredLanguage"] = CurrentLanguage; } } } catch { } }
        private void LoadParentId() { try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT parentId FROM dbo.[Parent] WHERE userId=@u", c)) { cmd.Parameters.AddWithValue("@u", _userId); c.Open(); var r = cmd.ExecuteScalar(); if (r != null) _parentId = r.ToString(); } } catch { } }
        private void ResolveChild() { string saved = Session["selectedChildId"] as string; if (!string.IsNullOrEmpty(saved) && IsLinked(saved)) { _studentId = saved; return; } if (string.IsNullOrEmpty(_parentId)) return; try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT TOP 1 studentId FROM dbo.[StudentParent] WHERE parentId=@p", c)) { cmd.Parameters.AddWithValue("@p", _parentId); c.Open(); var r = cmd.ExecuteScalar(); if (r != null && r != DBNull.Value) { _studentId = r.ToString(); Session["selectedChildId"] = _studentId; } } } catch { } }
        private bool IsLinked(string studentId) { if (string.IsNullOrEmpty(_parentId)) return false; try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[StudentParent] WHERE parentId=@p AND studentId=@s", c)) { cmd.Parameters.AddWithValue("@p", _parentId); cmd.Parameters.AddWithValue("@s", studentId); c.Open(); return (int)cmd.ExecuteScalar() > 0; } } catch { return false; } }
        private void PopulateSidebarChild() { ddlSidebarChild.Items.Clear(); try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT s.studentId, ISNULL(s.nickname,s.name) AS n FROM dbo.StudentParent sp INNER JOIN dbo.Student s ON sp.studentId=s.studentId WHERE sp.parentId=@p ORDER BY s.name", c)) { cmd.Parameters.AddWithValue("@p", _parentId); c.Open(); using (var r = cmd.ExecuteReader()) { while (r.Read()) ddlSidebarChild.Items.Add(new ListItem(r["n"].ToString(), r["studentId"].ToString())); } } } catch { } if (ddlSidebarChild.Items.Count > 0) { if (!string.IsNullOrEmpty(_studentId) && ddlSidebarChild.Items.FindByValue(_studentId) != null) ddlSidebarChild.SelectedValue = _studentId; } }
        private void LoadUnreadBadge() { try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.Notification WHERE toUserId=@uid AND isRead=0", c)) { cmd.Parameters.AddWithValue("@uid", _userId); c.Open(); int count = (int)cmd.ExecuteScalar(); litUnreadBadge.Text = count > 0 ? "<span class='pt-sidebar-badge'>" + count + "</span>" : ""; } } catch { } }
    }
}
