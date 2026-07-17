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
        private string DatabaseConnectionString =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected string CurrentLanguage = "EN";

        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        private string _authenticatedUserId = "";
        private string _parentRecordId = "";
        private string _viewedStudentId = "";

        // ══════════════════════════════════════════════════════════════
        //  PAGE LIFECYCLE
        // ══════════════════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!ValidateParentSession())
            {
                return;
            }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            _authenticatedUserId = Session["userId"].ToString();
            LoadLanguagePreference();
            LoadParentRecordId();
            ResolveActiveChild();
            LoadUnreadNotificationBadge();

            if (!IsPostBack)
            {
                PopulateSidebarChildDropdown();
                DetermineAndRenderView();
            }
            else
            {
                DetermineAndRenderView();
            }
        }

        private bool ValidateParentSession()
        {
            if (Session["userId"] == null || Session["role"] == null ||
                Session["role"].ToString() != "Parent")
            {
                Response.Redirect("~/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return false;
            }
            return true;
        }

        protected void SidebarChildChanged(object sender, EventArgs e)
        {
            string selectedStudentId = ddlSidebarChild.SelectedValue;
            if (!string.IsNullOrEmpty(selectedStudentId) && IsChildLinkedToParent(selectedStudentId))
            {
                Session["selectedChildId"] = selectedStudentId;
                _viewedStudentId = selectedStudentId;
            }
            DetermineAndRenderView();
        }

        /// <summary>
        /// Routes to the appropriate view based on query string parameters.
        /// Supports three navigation depths: all levels, level detail, and unit detail.
        /// </summary>
        private void DetermineAndRenderView()
        {
            pnlLevels.Visible = false;
            pnlLevelDetail.Visible = false;
            pnlUnitDetail.Visible = false;
            pnlNoChild.Visible = false;

            if (string.IsNullOrEmpty(_viewedStudentId))
            {
                pnlNoChild.Visible = true;
                return;
            }

            string requestedLevelId = Request.QueryString["levelId"];
            string requestedUnitId = Request.QueryString["unitId"];

            if (!string.IsNullOrEmpty(requestedUnitId) && !string.IsNullOrEmpty(requestedLevelId))
            {
                RenderUnitDetailView(requestedUnitId, requestedLevelId);
            }
            else if (!string.IsNullOrEmpty(requestedLevelId))
            {
                RenderLevelDetailView(requestedLevelId);
            }
            else
            {
                RenderAllLevelsView();
            }
        }

        // ══════════════════════════════════════════════════════════════
        //  ALL LEVELS VIEW
        // ══════════════════════════════════════════════════════════════
        private void RenderAllLevelsView()
        {
            pnlLevels.Visible = true;
            pnlLevelsGrid.Controls.Clear();

            string[] cardBackgroundColors = { "#E0F7FA", "#FFF3E0", "#F3E5F5" };
            string[] levelEmojis = { "🔬", "🚀", "⚡" };
            int colorIndex = 0;

            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                {
                    connection.Open();

                    const string levelsQuery = @"SELECT levelId, levelNameEN, levelNameBM, 
                        levelDescriptionEN, levelDescriptionBM 
                        FROM dbo.[Level] ORDER BY levelId";

                    using (var command = new SqlCommand(levelsQuery, connection))
                    using (var reader = command.ExecuteReader())
                    {
                        StringBuilder cardsHtml = new StringBuilder();

                        while (reader.Read())
                        {
                            string levelId = reader["levelId"].ToString();
                            string levelName = CurrentLanguage == "BM"
                                ? reader["levelNameBM"].ToString()
                                : reader["levelNameEN"].ToString();
                            string levelDescription = CurrentLanguage == "BM"
                                ? (reader["levelDescriptionBM"] != DBNull.Value
                                    ? reader["levelDescriptionBM"].ToString() : "")
                                : (reader["levelDescriptionEN"] != DBNull.Value
                                    ? reader["levelDescriptionEN"].ToString() : "");

                            bool isUnlocked = IsLevelAccessibleByChild(levelId);
                            int unitCount = CountUnitsInLevel(levelId);
                            string backgroundColor = cardBackgroundColors[colorIndex % 3];
                            string emoji = levelEmojis[colorIndex % 3];
                            colorIndex++;

                            string truncatedDesc = levelDescription.Length > 80
                                ? levelDescription.Substring(0, 80) + "..."
                                : levelDescription;

                            if (isUnlocked)
                            {
                                AppendUnlockedLevelCard(cardsHtml, levelId, backgroundColor,
                                    emoji, levelName, unitCount, truncatedDesc);
                            }
                            else
                            {
                                AppendLockedLevelCard(cardsHtml, emoji, levelName, unitCount);
                            }
                        }

                        if (cardsHtml.Length > 0)
                        {
                            pnlLevelsGrid.Controls.Add(new LiteralControl(cardsHtml.ToString()));
                        }
                    }
                }
            }
            catch { }
        }

        private void AppendUnlockedLevelCard(StringBuilder html, string levelId,
            string backgroundColor, string emoji, string levelName, int unitCount, string description)
        {
            html.AppendFormat(@"<a href='EnrolledModules.aspx?levelId={0}' class='pt-level-card pt-level-card-unlocked' style='--card-bg:{1};'>
                <div class='pt-level-image'><span class='pt-level-emoji'>{2}</span></div>
                <div class='pt-level-body'>
                    <div class='pt-level-name'>{3}</div>
                    <div class='pt-level-count'>{4} {5}</div>
                    <div class='pt-level-desc'>{6}</div>
                    <span class='pt-learning-badge pt-badge-unlocked'><i class='bi bi-unlock-fill'></i> {7}</span>
                </div>
            </a>", levelId, backgroundColor, emoji, Server.HtmlEncode(levelName),
                unitCount, T("units", "unit"), Server.HtmlEncode(description), T("Unlocked", "Dibuka"));
        }

        private void AppendLockedLevelCard(StringBuilder html, string emoji,
            string levelName, int unitCount)
        {
            html.AppendFormat(@"<div class='pt-level-card pt-level-card-locked'>
                <div class='pt-level-lock-overlay'><i class='bi bi-lock-fill'></i></div>
                <div class='pt-level-image'><span class='pt-level-emoji'>{0}</span></div>
                <div class='pt-level-body'>
                    <div class='pt-level-name'>{1}</div>
                    <div class='pt-level-count'>{2} {3}</div>
                    <span class='pt-learning-badge pt-badge-locked'><i class='bi bi-lock-fill'></i> {4}</span>
                    <div class='pt-level-locked-msg'>{5}</div>
                </div>
            </div>", emoji, Server.HtmlEncode(levelName), unitCount, T("units", "unit"),
                T("Locked", "Dikunci"),
                T("This level has not been unlocked by your child yet.",
                  "Tahap ini belum dibuka oleh anak anda."));
        }

        // ══════════════════════════════════════════════════════════════
        //  LEVEL DETAIL VIEW
        // ══════════════════════════════════════════════════════════════
        private void RenderLevelDetailView(string levelId)
        {
            if (!IsLevelAccessibleByChild(levelId))
            {
                RenderAllLevelsView();
                return;
            }
            pnlLevelDetail.Visible = true;

            RenderLevelDetailHero(levelId);

            int unitCount = CountUnitsInLevel(levelId);
            litUnitCountInfo.Text = string.Format(
                T("This level contains {0} units.", "Tahap ini mengandungi {0} unit."), unitCount);

            RenderUnitsGrid(levelId);
        }

        private void RenderLevelDetailHero(string levelId)
        {
            try
            {
                const string heroQuery = @"SELECT levelNameEN, levelNameBM, 
                    levelDescriptionEN, levelDescriptionBM 
                    FROM dbo.[Level] WHERE levelId = @levelId";

                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(heroQuery, connection))
                {
                    command.Parameters.AddWithValue("@levelId", levelId);
                    connection.Open();

                    using (var reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string levelName = CurrentLanguage == "BM"
                                ? reader["levelNameBM"].ToString()
                                : reader["levelNameEN"].ToString();
                            string levelDescription = CurrentLanguage == "BM"
                                ? (reader["levelDescriptionBM"] != DBNull.Value
                                    ? reader["levelDescriptionBM"].ToString() : "")
                                : (reader["levelDescriptionEN"] != DBNull.Value
                                    ? reader["levelDescriptionEN"].ToString() : "");

                            pnlLevelHero.Controls.Clear();
                            pnlLevelHero.Controls.Add(new LiteralControl(string.Format(
                                @"<div class='pt-level-detail-illustration'><i class='bi bi-stars'></i></div>
                                <div class='pt-level-detail-content'><h2>{0}</h2><p>{1}</p></div>",
                                Server.HtmlEncode(levelName), Server.HtmlEncode(levelDescription))));
                        }
                    }
                }
            }
            catch { }
        }

        private void RenderUnitsGrid(string levelId)
        {
            pnlUnitsGrid.Controls.Clear();
            pnlNoUnits.Visible = false;

            try
            {
                const string unitsQuery = @"SELECT unitId, unitNameEN, unitNameBM, 
                    unitDescriptionEN, unitDescriptionBM, orderNo 
                    FROM dbo.[Unit] WHERE levelId = @levelId ORDER BY orderNo";

                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(unitsQuery, connection))
                {
                    command.Parameters.AddWithValue("@levelId", levelId);
                    connection.Open();

                    using (var reader = command.ExecuteReader())
                    {
                        StringBuilder unitsHtml = new StringBuilder();
                        bool hasUnits = false;
                        string[] cardAccentColors = { "#FFF8E1", "#E8F5E9", "#E3F2FD",
                            "#FCE4EC", "#F3E5F5", "#E0F2F1" };
                        int accentIndex = 0;

                        while (reader.Read())
                        {
                            hasUnits = true;
                            string unitId = reader["unitId"].ToString();
                            string unitName = CurrentLanguage == "BM"
                                ? reader["unitNameBM"].ToString()
                                : reader["unitNameEN"].ToString();
                            string unitDescription = CurrentLanguage == "BM"
                                ? (reader["unitDescriptionBM"] != DBNull.Value
                                    ? reader["unitDescriptionBM"].ToString() : "")
                                : (reader["unitDescriptionEN"] != DBNull.Value
                                    ? reader["unitDescriptionEN"].ToString() : "");

                            int subtopicCount = CountSubtopicsInUnit(unitId);
                            int totalLessons = CountLessonsInUnit(unitId);
                            int completedLessons = CountCompletedLessonsInUnit(unitId);
                            int progressPercent = totalLessons > 0
                                ? (int)Math.Round((double)completedLessons / totalLessons * 100)
                                : 0;

                            string progressLabel = progressPercent == 0
                                ? T("Not Started", "Belum Mula")
                                : progressPercent >= 100
                                    ? T("Completed", "Selesai")
                                    : T("In Progress", "Sedang Berjalan");

                            string cardBackground = cardAccentColors[accentIndex % cardAccentColors.Length];
                            accentIndex++;

                            string truncatedUnitDesc = unitDescription.Length > 60
                                ? unitDescription.Substring(0, 60) + "..."
                                : unitDescription;

                            unitsHtml.AppendFormat(@"<a href='EnrolledModules.aspx?levelId={0}&unitId={1}' class='pt-unit-card' style='--card-bg:{2};'>
                                <div class='pt-unit-card-header'><span class='pt-unit-card-icon'><i class='bi bi-book-half'></i></span><span class='pt-unit-card-order'>#{3}</span></div>
                                <div class='pt-unit-card-name'>{4}</div>
                                <div class='pt-unit-card-desc'>{5}</div>
                                <div class='pt-unit-stat-chips'>
                                    <span class='pt-unit-stat-chip'><i class='bi bi-layers'></i> {6} {7}</span>
                                    <span class='pt-unit-stat-chip'><i class='bi bi-file-text'></i> {8} {9}</span>
                                </div>
                                <div class='pt-unit-progress-bar'><div class='pt-unit-progress-fill' style='width:{10}%;'></div></div>
                                <div class='pt-unit-progress-label'>{10}% &bull; {11}</div>
                            </a>", levelId, unitId, cardBackground, reader["orderNo"],
                                Server.HtmlEncode(unitName), Server.HtmlEncode(truncatedUnitDesc),
                                subtopicCount, T("subtopics", "subtopik"),
                                totalLessons, T("lessons", "pelajaran"),
                                progressPercent, progressLabel);
                        }

                        if (hasUnits)
                        {
                            pnlUnitsGrid.Controls.Add(new LiteralControl(unitsHtml.ToString()));
                        }
                        else
                        {
                            pnlNoUnits.Visible = true;
                        }
                    }
                }
            }
            catch
            {
                pnlNoUnits.Visible = true;
            }
        }

        // ══════════════════════════════════════════════════════════════
        //  UNIT DETAIL VIEW
        // ══════════════════════════════════════════════════════════════
        private void RenderUnitDetailView(string unitId, string levelId)
        {
            if (!IsLevelAccessibleByChild(levelId))
            {
                RenderAllLevelsView();
                return;
            }
            pnlUnitDetail.Visible = true;
            lnkBackToUnits.HRef = "EnrolledModules.aspx?levelId=" + Server.UrlEncode(levelId);

            RenderUnitHeroSection(unitId);
            RenderSubtopicsGrid(unitId);
        }

        private void RenderUnitHeroSection(string unitId)
        {
            pnlUnitHero.Controls.Clear();

            try
            {
                const string unitHeroQuery = @"SELECT unitNameEN, unitNameBM, 
                    unitDescriptionEN, unitDescriptionBM 
                    FROM dbo.[Unit] WHERE unitId = @unitId";

                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(unitHeroQuery, connection))
                {
                    command.Parameters.AddWithValue("@unitId", unitId);
                    connection.Open();

                    using (var reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string unitName = CurrentLanguage == "BM"
                                ? reader["unitNameBM"].ToString()
                                : reader["unitNameEN"].ToString();
                            string unitDescription = CurrentLanguage == "BM"
                                ? (reader["unitDescriptionBM"] != DBNull.Value
                                    ? reader["unitDescriptionBM"].ToString() : "")
                                : (reader["unitDescriptionEN"] != DBNull.Value
                                    ? reader["unitDescriptionEN"].ToString() : "");

                            int totalLessons = CountLessonsInUnit(unitId);
                            int completedLessons = CountCompletedLessonsInUnit(unitId);
                            int progressPercent = totalLessons > 0
                                ? (int)Math.Round((double)completedLessons / totalLessons * 100)
                                : 0;
                            string progressStatus = progressPercent == 0
                                ? T("Not Started", "Belum Mula")
                                : progressPercent >= 100
                                    ? T("Completed", "Selesai")
                                    : T("In Progress", "Sedang Berjalan");
                            string statusBadgeCss = progressPercent >= 100
                                ? "pt-badge-complete"
                                : progressPercent > 0
                                    ? "pt-badge-progress"
                                    : "pt-badge-notstarted";

                            pnlUnitHero.Controls.Add(new LiteralControl(string.Format(
                                @"<h2 class='pt-unit-hero-title'>{0}</h2>
                                <div class='pt-unit-hero-stats'>
                                    <span class='pt-unit-hero-stat'><i class='bi bi-journal-text'></i> {1} / {2} {3}</span>
                                    <span class='pt-unit-hero-pct'>{4}%</span>
                                    <span class='pt-learning-badge {5}'>{6}</span>
                                </div>
                                <div class='pt-unit-hero-progress'><div class='pt-unit-hero-progress-fill' style='width:{4}%;'></div></div>",
                                Server.HtmlEncode(unitName), completedLessons, totalLessons,
                                T("Lessons", "Pelajaran"), progressPercent,
                                statusBadgeCss, progressStatus)));

                            litUnitDescription.Text = Server.HtmlEncode(unitDescription);
                        }
                    }
                }
            }
            catch { }
        }

        private void RenderSubtopicsGrid(string unitId)
        {
            pnlSubtopicsGrid.Controls.Clear();
            pnlNoSubtopics.Visible = false;

            try
            {
                int quizCountForUnit = CountQuizzesInUnit(unitId);

                const string subtopicsQuery = @"SELECT subtopicId, subtopicTitleEN, subtopicTitleBM, 
                    subtopicDescriptionEN, subtopicDescriptionBM 
                    FROM dbo.[Subtopic] WHERE unitId = @unitId ORDER BY subtopicId";

                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(subtopicsQuery, connection))
                {
                    command.Parameters.AddWithValue("@unitId", unitId);
                    connection.Open();

                    using (var reader = command.ExecuteReader())
                    {
                        StringBuilder subtopicsHtml = new StringBuilder();
                        bool hasSubtopics = false;
                        string[] subtopicCardColors = { "#FFFDE7", "#E8F5E9", "#E3F2FD",
                            "#FFF3E0", "#F3E5F5", "#E0F2F1" };
                        int colorIdx = 0;

                        while (reader.Read())
                        {
                            hasSubtopics = true;
                            string subtopicId = reader["subtopicId"].ToString();
                            string subtopicTitle = CurrentLanguage == "BM"
                                ? reader["subtopicTitleBM"].ToString()
                                : reader["subtopicTitleEN"].ToString();
                            string subtopicDescription = CurrentLanguage == "BM"
                                ? (reader["subtopicDescriptionBM"] != DBNull.Value
                                    ? reader["subtopicDescriptionBM"].ToString() : "")
                                : (reader["subtopicDescriptionEN"] != DBNull.Value
                                    ? reader["subtopicDescriptionEN"].ToString() : "");

                            int lessonCount = CountLessonsInSubtopic(subtopicId);
                            int materialCount = CountMaterialsInSubtopic(subtopicId);
                            string cardBg = subtopicCardColors[colorIdx % subtopicCardColors.Length];
                            colorIdx++;

                            string truncatedSubtopicDesc = subtopicDescription.Length > 80
                                ? subtopicDescription.Substring(0, 80) + "..."
                                : subtopicDescription;

                            subtopicsHtml.AppendFormat(@"<div class='pt-subtopic-card' style='--card-bg:{0};'>
                                <div class='pt-subtopic-card-icon'><i class='bi bi-lightbulb-fill'></i></div>
                                <div class='pt-subtopic-card-name'>{1}</div>
                                <div class='pt-subtopic-card-desc'>{2}</div>
                                <div class='pt-subtopic-stat-row'>
                                    <span><i class='bi bi-file-text'></i> {3} {4}</span>
                                    <span><i class='bi bi-paperclip'></i> {5} {6}</span>
                                </div>
                            </div>", cardBg, Server.HtmlEncode(subtopicTitle),
                                Server.HtmlEncode(truncatedSubtopicDesc),
                                lessonCount, T("Lessons", "Pelajaran"),
                                materialCount, T("Materials", "Bahan"));
                        }

                        // Append quiz card at the end if quizzes exist for this unit
                        if (hasSubtopics && quizCountForUnit > 0)
                        {
                            subtopicsHtml.AppendFormat(@"<div class='pt-subtopic-card' style='--card-bg:#FCE4EC;'>
                                <div class='pt-subtopic-card-icon'><i class='bi bi-patch-question-fill'></i></div>
                                <div class='pt-subtopic-card-name'>{0}</div>
                                <div class='pt-subtopic-card-desc'>{1}</div>
                                <div class='pt-subtopic-stat-row'><span><i class='bi bi-ui-checks'></i> {2} {0}</span></div>
                            </div>", T("Quizzes", "Kuiz"),
                                T("Quizzes available for this unit.", "Kuiz yang tersedia untuk unit ini."),
                                quizCountForUnit);
                        }

                        if (hasSubtopics)
                        {
                            pnlSubtopicsGrid.Controls.Add(new LiteralControl(subtopicsHtml.ToString()));
                        }
                        else
                        {
                            pnlNoSubtopics.Visible = true;
                        }
                    }
                }
            }
            catch
            {
                pnlNoSubtopics.Visible = true;
            }
        }

        // ══════════════════════════════════════════════════════════════
        //  DATA ACCESS HELPERS
        // ══════════════════════════════════════════════════════════════

        /// <summary>
        /// Checks if a level is accessible by the child through either their current level
        /// assignment or an active enrollment record.
        /// </summary>
        private bool IsLevelAccessibleByChild(string levelId)
        {
            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                {
                    connection.Open();

                    // Check if level is at or below child's current assigned level
                    using (var command = new SqlCommand(
                        "SELECT currentLevelId FROM dbo.[Student] WHERE studentId = @studentId",
                        connection))
                    {
                        command.Parameters.AddWithValue("@studentId", _viewedStudentId);
                        var result = command.ExecuteScalar();

                        if (result != null && result != DBNull.Value)
                        {
                            string currentLevelId = result.ToString();
                            if (string.Compare(levelId, currentLevelId, StringComparison.OrdinalIgnoreCase) <= 0)
                            {
                                return true;
                            }
                        }
                    }

                    // Also check active enrollment as a fallback
                    using (var command = new SqlCommand(
                        "SELECT COUNT(*) FROM dbo.[Enrollment] WHERE studentId = @studentId AND levelId = @levelId AND status = 'Active'",
                        connection))
                    {
                        command.Parameters.AddWithValue("@studentId", _viewedStudentId);
                        command.Parameters.AddWithValue("@levelId", levelId);
                        return (int)command.ExecuteScalar() > 0;
                    }
                }
            }
            catch
            {
                return false;
            }
        }

        private int CountUnitsInLevel(string levelId)
        {
            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(
                    "SELECT COUNT(*) FROM dbo.[Unit] WHERE levelId = @levelId", connection))
                {
                    command.Parameters.AddWithValue("@levelId", levelId);
                    connection.Open();
                    return (int)command.ExecuteScalar();
                }
            }
            catch
            {
                return 0;
            }
        }

        private int CountSubtopicsInUnit(string unitId)
        {
            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(
                    "SELECT COUNT(*) FROM dbo.[Subtopic] WHERE unitId = @unitId", connection))
                {
                    command.Parameters.AddWithValue("@unitId", unitId);
                    connection.Open();
                    return (int)command.ExecuteScalar();
                }
            }
            catch
            {
                return 0;
            }
        }

        private int CountLessonsInUnit(string unitId)
        {
            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(
                    @"SELECT COUNT(*) FROM dbo.[Lesson] l 
                    INNER JOIN dbo.[Subtopic] s ON l.subtopicId = s.subtopicId 
                    WHERE s.unitId = @unitId", connection))
                {
                    command.Parameters.AddWithValue("@unitId", unitId);
                    connection.Open();
                    return (int)command.ExecuteScalar();
                }
            }
            catch
            {
                return 0;
            }
        }

        private int CountCompletedLessonsInUnit(string unitId)
        {
            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(
                    @"SELECT COUNT(*) FROM dbo.[LessonProgress] lp 
                    INNER JOIN dbo.[Lesson] l ON lp.lessonId = l.lessonId 
                    INNER JOIN dbo.[Subtopic] s ON l.subtopicId = s.subtopicId 
                    WHERE s.unitId = @unitId AND lp.studentId = @studentId AND lp.isCompleted = 1",
                    connection))
                {
                    command.Parameters.AddWithValue("@unitId", unitId);
                    command.Parameters.AddWithValue("@studentId", _viewedStudentId);
                    connection.Open();
                    return (int)command.ExecuteScalar();
                }
            }
            catch
            {
                return 0;
            }
        }

        private int CountLessonsInSubtopic(string subtopicId)
        {
            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(
                    "SELECT COUNT(*) FROM dbo.[Lesson] WHERE subtopicId = @subtopicId", connection))
                {
                    command.Parameters.AddWithValue("@subtopicId", subtopicId);
                    connection.Open();
                    return (int)command.ExecuteScalar();
                }
            }
            catch
            {
                return 0;
            }
        }

        private int CountMaterialsInSubtopic(string subtopicId)
        {
            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(
                    "SELECT COUNT(*) FROM dbo.[Material] WHERE subtopicId = @subtopicId", connection))
                {
                    command.Parameters.AddWithValue("@subtopicId", subtopicId);
                    connection.Open();
                    return (int)command.ExecuteScalar();
                }
            }
            catch
            {
                return 0;
            }
        }

        private int CountQuizzesInUnit(string unitId)
        {
            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(
                    "SELECT COUNT(*) FROM dbo.[Quiz] WHERE unitId = @unitId", connection))
                {
                    command.Parameters.AddWithValue("@unitId", unitId);
                    connection.Open();
                    return (int)command.ExecuteScalar();
                }
            }
            catch
            {
                return 0;
            }
        }

        // ══════════════════════════════════════════════════════════════
        //  SHARED INFRASTRUCTURE
        // ══════════════════════════════════════════════════════════════
        private void LoadLanguagePreference()
        {
            string cachedLanguage = Session["preferredLanguage"] as string;
            if (!string.IsNullOrEmpty(cachedLanguage))
            {
                CurrentLanguage = cachedLanguage;
                return;
            }

            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(
                    "SELECT preferredLanguage FROM dbo.[User] WHERE userId = @userId", connection))
                {
                    command.Parameters.AddWithValue("@userId", _authenticatedUserId);
                    connection.Open();
                    var result = command.ExecuteScalar();

                    if (result != null && result != DBNull.Value)
                    {
                        CurrentLanguage = result.ToString();
                        Session["preferredLanguage"] = CurrentLanguage;
                    }
                }
            }
            catch { }
        }

        private void LoadParentRecordId()
        {
            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(
                    "SELECT parentId FROM dbo.[Parent] WHERE userId = @userId", connection))
                {
                    command.Parameters.AddWithValue("@userId", _authenticatedUserId);
                    connection.Open();
                    var result = command.ExecuteScalar();

                    if (result != null)
                    {
                        _parentRecordId = result.ToString();
                    }
                }
            }
            catch { }
        }

        private void ResolveActiveChild()
        {
            string savedChildId = Session["selectedChildId"] as string;
            if (!string.IsNullOrEmpty(savedChildId) && IsChildLinkedToParent(savedChildId))
            {
                _viewedStudentId = savedChildId;
                return;
            }

            if (string.IsNullOrEmpty(_parentRecordId))
            {
                return;
            }

            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(
                    "SELECT TOP 1 studentId FROM dbo.[StudentParent] WHERE parentId = @parentId",
                    connection))
                {
                    command.Parameters.AddWithValue("@parentId", _parentRecordId);
                    connection.Open();
                    var result = command.ExecuteScalar();

                    if (result != null && result != DBNull.Value)
                    {
                        _viewedStudentId = result.ToString();
                        Session["selectedChildId"] = _viewedStudentId;
                    }
                }
            }
            catch { }
        }

        private bool IsChildLinkedToParent(string studentId)
        {
            if (string.IsNullOrEmpty(_parentRecordId))
            {
                return false;
            }

            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(
                    "SELECT COUNT(*) FROM dbo.[StudentParent] WHERE parentId = @parentId AND studentId = @studentId",
                    connection))
                {
                    command.Parameters.AddWithValue("@parentId", _parentRecordId);
                    command.Parameters.AddWithValue("@studentId", studentId);
                    connection.Open();
                    return (int)command.ExecuteScalar() > 0;
                }
            }
            catch
            {
                return false;
            }
        }

        private void PopulateSidebarChildDropdown()
        {
            ddlSidebarChild.Items.Clear();

            try
            {
                const string childListQuery = @"SELECT s.studentId, ISNULL(s.nickname, s.name) AS displayName 
                    FROM dbo.StudentParent sp 
                    INNER JOIN dbo.Student s ON sp.studentId = s.studentId 
                    WHERE sp.parentId = @parentId ORDER BY s.name";

                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(childListQuery, connection))
                {
                    command.Parameters.AddWithValue("@parentId", _parentRecordId);
                    connection.Open();

                    using (var reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            ddlSidebarChild.Items.Add(new ListItem(
                                reader["displayName"].ToString(),
                                reader["studentId"].ToString()));
                        }
                    }
                }
            }
            catch { }

            if (ddlSidebarChild.Items.Count > 0)
            {
                if (!string.IsNullOrEmpty(_viewedStudentId) &&
                    ddlSidebarChild.Items.FindByValue(_viewedStudentId) != null)
                {
                    ddlSidebarChild.SelectedValue = _viewedStudentId;
                }
            }
        }

        private void LoadUnreadNotificationBadge()
        {
            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(
                    "SELECT COUNT(*) FROM dbo.Notification WHERE toUserId = @userId AND isRead = 0",
                    connection))
                {
                    command.Parameters.AddWithValue("@userId", _authenticatedUserId);
                    connection.Open();
                    int unreadCount = (int)command.ExecuteScalar();

                    litUnreadBadge.Text = unreadCount > 0
                        ? "<span class='pt-sidebar-badge'>" + unreadCount + "</span>"
                        : "";
                }
            }
            catch { }
        }
    }
}
