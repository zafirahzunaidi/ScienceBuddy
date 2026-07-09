using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace ScienceBuddy.Parent
{
    public partial class ParentDashboard : Page
    {
        // ── Connection string ─────────────────────────────────────────
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        // ── Language ──────────────────────────────────────────────────
        protected string CurrentLanguage = "EN";

        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        // ── State ─────────────────────────────────────────────────────
        private string _parentId = "";
        private string _parentName = "";
        private string _parentUserId = "";

        // ── Public property for ASPX data-binding expressions ─────────
        public string SelectedChildId
        {
            get { return Session["selectedChildId"] as string ?? ""; }
        }

        // ══════════════════════════════════════════════════════════════
        //  PAGE LOAD
        // ══════════════════════════════════════════════════════════════

        protected void Page_Load(object sender, EventArgs e)
        {
            // Authorization
            if (!EnsureParentAuthorized())
                return;

            // Sidebar layout
            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";

            // Language
            LoadCurrentLanguage(); LoadUnreadBadge();

            // Parent info
            _parentUserId = Session["userId"].ToString();
            LoadParentProfile();

            if (!IsPostBack)
            {
                SetLabels();
                LoadLinkedChildren();

                if (_hasLinkedChildren)
                {
                    // Restore previously selected child from session if valid
                    string savedChild = Session["selectedChildId"] as string;
                    if (!string.IsNullOrEmpty(savedChild) && IsChildLinkedToParent(_parentId, savedChild))
                    {
                        ddlSidebarChild.SelectedValue = savedChild;
                    }
                    else
                    {
                        Session["selectedChildId"] = ddlSidebarChild.Items[0].Value;
                    }

                    pnlDashboard.Visible   = true;
                    pnlNoChild.Visible     = false;
                    pnlHeroNoChild.Visible = false;
                    pnlHeroViewing.Visible = true;
                    LoadDashboardForChild(ddlSidebarChild.SelectedValue);
                }
                else
                {
                    ShowNoLinkedChildState();
                }
            }
            else
            {
                SetLabels();
            }
        }

        // ══════════════════════════════════════════════════════════════
        //  AUTHORIZATION
        // ══════════════════════════════════════════════════════════════

        private bool EnsureParentAuthorized()
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

        // ══════════════════════════════════════════════════════════════
        //  LANGUAGE
        // ══════════════════════════════════════════════════════════════

        private void LoadCurrentLanguage()
        {
            string lang = Session["preferredLanguage"] as string;
            if (!string.IsNullOrEmpty(lang))
            {
                CurrentLanguage = lang;
                return;
            }

            string userId = Session["userId"] as string;
            if (!string.IsNullOrEmpty(userId))
            {
                try
                {
                    const string sql = "SELECT preferredLanguage FROM dbo.[User] WHERE userId = @userId";
                    using (var conn = new SqlConnection(ConnStr))
                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@userId", userId);
                        conn.Open();
                        object result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            lang = result.ToString();
                            Session["preferredLanguage"] = lang;
                            CurrentLanguage = lang;
                            return;
                        }
                    }
                }
                catch (SqlException) { }
            }

            CurrentLanguage = "EN";
        }

        // ══════════════════════════════════════════════════════════════
        //  PARENT PROFILE
        // ══════════════════════════════════════════════════════════════

        private void LoadParentProfile()
        {
            try
            {
                const string sql = "SELECT parentId, name FROM dbo.[Parent] WHERE userId = @userId";
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", _parentUserId);
                    conn.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            _parentId = reader["parentId"]?.ToString() ?? "";
                            _parentName = reader["name"]?.ToString() ?? "";
                        }
                    }
                }
            }
            catch (SqlException) { }
        }

        // ══════════════════════════════════════════════════════════════
        //  SET UI LABELS (EN/BM)
        // ══════════════════════════════════════════════════════════════

        private void SetLabels()
        {
            // ── New hero labels ───────────────────────────────────────
            litHeroEyebrow.Text      = T("My Child's Science Journey", "Perjalanan Sains Anak Saya");
            litHeroGreeting.Text     = T("Hi, ", "Hai, ") + Server.HtmlEncode(_parentName) + "!";
            litHeroLinkChild.Text      = T("Link New Child", "Paut Anak Baharu");
            litHeroLinkChildNoChild.Text = T("Link New Child", "Paut Anak Baharu");
            litHeroNoChild.Text  = T(
                "No linked child found. Link a child account to start monitoring progress.",
                "Tiada akaun anak dipautkan. Paut akaun anak untuk mula memantau kemajuan.");

            // ── Child Snapshot labels ─────────────────────────────────
            litSnapshotTitle.Text   = T("Child Snapshot", "Ringkasan Anak");
            litSnapshotSub.Text     = T("A quick look at your child's learning journey.",
                                        "Ringkasan ringkas perjalanan pembelajaran anak anda.");
            litSnapLessonLabel.Text = T("Latest Lesson", "Pelajaran Terkini");
            litSnapQuizLabel.Text   = T("Latest Quiz", "Kuiz Terkini");
            litSnapNoActivity.Text  = T("No recent activity yet.", "Tiada aktiviti terkini lagi.");
            litSnapBtnProfile.Text  = T("View Profile", "Lihat Profil");
            litSnapBtnProgress.Text = T("View Progress", "Lihat Kemajuan");
            litSnapBtnReport.Text   = T("Report Card", "Kad Laporan");
            litHeroNoChild.Text   = T(
                "No linked child found. Link a child account to start monitoring progress.",
                "Tiada akaun anak dipautkan. Paut akaun anak untuk mula memantau kemajuan.");

            // Child selector — removed (now only hero ddl used)
            // litSelectChildLabel removed

            // No child state (panel below hero)
            litNoChildMsg.Text  = T("No linked child found.", "Tiada akaun anak dipautkan.");
            litLinkChildBtn.Text = T("Link Child Account", "Paut Akaun Anak");

            // Summary card labels
            litProgressLabel.Text   = T("Lessons completed", "Pelajaran selesai");
            litQuizScoreLabel.Text  = T("Average Quiz Score", "Purata Markah Kuiz");
            litBadgeLabel.Text      = T("Badges collected", "Lencana dikumpul");

            // Child overview labels — removed (Level/XP shown in hero pills; overview replaced by snapshot)
            // litChildLevelLabel, litChildXPLabel removed

            // Section headers
            litStudyPlanTitle.Text       = T("Study Plan", "Pelan Pembelajaran");
            litRecentActivitiesTitle.Text = T("Recent Activities", "Aktiviti Terkini");

            // No data messages
            litNoStudyPlanMsg.Text  = T("No study plan yet.", "Tiada pelan pembelajaran lagi.");
            litNoActivitiesMsg.Text = T("No recent activities yet.", "Tiada aktiviti terkini lagi.");

            // Forum section labels
            litForumTitle.Text   = T("Forum", "Forum");
            litForumSub.Text     = T("Ask questions, share ideas, and support your child's Science learning.",
                                     "Tanya soalan, kongsi idea, dan sokong pembelajaran Sains anak anda.");
            litTabPublic.Text    = T("Public", "Awam");
            litTabPrivate.Text   = T("Student-Parent", "Pelajar-Ibu Bapa");
            litNoForumMsg.Text   = T("No discussions yet.", "Tiada perbincangan lagi.");
            litGoToForum.Text    = T("Go to Forum", "Pergi ke Forum");
        }

        // ══════════════════════════════════════════════════════════════
        //  LOAD LINKED CHILDREN
        // ══════════════════════════════════════════════════════════════

        private bool _hasLinkedChildren = false;

        private void LoadLinkedChildren()
        {
            ddlSidebarChild.Items.Clear();
            _hasLinkedChildren = false;

            if (string.IsNullOrEmpty(_parentId))
            {
                ShowNoLinkedChildState();
                return;
            }

            try
            {
                const string sql = @"
                    SELECT sp.studentParentId, sp.studentId, s.name, s.nickname, sp.relationship
                    FROM dbo.[StudentParent] sp
                    INNER JOIN dbo.[Student] s ON s.studentId = sp.studentId
                    WHERE sp.parentId = @parentId";

                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@parentId", _parentId);
                    conn.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string studentId   = reader["studentId"]?.ToString() ?? "";
                            string name        = reader["name"]?.ToString() ?? "";
                            string nickname    = reader["nickname"]?.ToString() ?? "";
                            string displayName = !string.IsNullOrWhiteSpace(nickname) ? nickname : name;

                            ddlSidebarChild.Items.Add(new System.Web.UI.WebControls.ListItem(displayName, studentId));
                        }
                    }
                }
            }
            catch (SqlException) { }

            if (ddlSidebarChild.Items.Count == 0)
            {
                ShowNoLinkedChildState();
            }
            else
            {
                _hasLinkedChildren = true;
            }
        }

        // ══════════════════════════════════════════════════════════════
        //  CHILD SELECTOR CHANGE
        // ══════════════════════════════════════════════════════════════

        protected void SidebarChildChanged(object sender, EventArgs e)
        {
            string selectedStudentId = ddlSidebarChild.SelectedValue;

            if (!IsChildLinkedToParent(_parentId, selectedStudentId))
            {
                return;
            }

            Session["selectedChildId"] = selectedStudentId;
            Response.Redirect(Request.RawUrl, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        // ══════════════════════════════════════════════════════════════
        //  VALIDATE CHILD-PARENT LINK
        // ══════════════════════════════════════════════════════════════

        private bool IsChildLinkedToParent(string parentId, string studentId)
        {
            if (string.IsNullOrEmpty(parentId) || string.IsNullOrEmpty(studentId))
                return false;

            try
            {
                const string sql = @"
                    SELECT COUNT(*) FROM dbo.[StudentParent]
                    WHERE parentId = @parentId AND studentId = @studentId";

                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@parentId", parentId);
                    cmd.Parameters.AddWithValue("@studentId", studentId);
                    conn.Open();
                    int count = Convert.ToInt32(cmd.ExecuteScalar());
                    return count > 0;
                }
            }
            catch (SqlException)
            {
                return false;
            }
        }

        // ══════════════════════════════════════════════════════════════
        //  LOAD DASHBOARD DATA FOR SELECTED CHILD
        // ══════════════════════════════════════════════════════════════

        private void LoadDashboardForChild(string studentId)
        {
            if (string.IsNullOrEmpty(studentId)) return;

            LoadChildOverview(studentId);
            LoadChildSnapshot(studentId);
            LoadSummaryCounts(studentId);
            LoadStudyPlanCard(studentId);
            LoadRecentActivities(studentId);
            LoadForumPosts();
        }

        // ══════════════════════════════════════════════════════════════
        //  CHILD OVERVIEW
        // ══════════════════════════════════════════════════════════════

        private void LoadChildOverview(string studentId)
        {
            try
            {
                const string sql = @"
                    SELECT s.name, s.nickname, s.XP, s.currentLevelId,
                           l.levelNameEN, l.levelNameBM,
                           sp.relationship
                    FROM dbo.[Student] s
                    LEFT JOIN dbo.[Level] l ON l.levelId = s.currentLevelId
                    INNER JOIN dbo.[StudentParent] sp ON sp.studentId = s.studentId AND sp.parentId = @parentId
                    WHERE s.studentId = @studentId";

                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@studentId", studentId);
                    cmd.Parameters.AddWithValue("@parentId", _parentId);
                    conn.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string name         = reader["name"]?.ToString() ?? "-";
                            string nickname     = reader["nickname"]?.ToString() ?? "";
                            string relationship = reader["relationship"]?.ToString() ?? "";
                            string levelNameEN  = reader["levelNameEN"]?.ToString() ?? "-";
                            string levelNameBM  = reader["levelNameBM"]?.ToString() ?? "-";
                            string levelName    = CurrentLanguage == "BM" ? levelNameBM : levelNameEN;
                            int xp = reader["XP"] != DBNull.Value ? Convert.ToInt32(reader["XP"]) : 0;

                            string displayName = !string.IsNullOrWhiteSpace(nickname)
                                ? name + " (" + nickname + ")" : name;
                            string sidebarName = !string.IsNullOrWhiteSpace(nickname) ? nickname : name;

                            // ── Hero card ────────────────────────────
                            litHeroViewing.Text = T("Currently viewing: ", "Sedang melihat: ")
                                                  + Server.HtmlEncode(sidebarName);
                            litHeroLevel.Text = T("Level: ", "Tahap: ") + Server.HtmlEncode(levelName);
                            litHeroXP.Text    = xp.ToString("N0") + " XP";

                            // ── Sidebar ──────────────────────────────
                            // (sidebar now uses ddlSidebarChild, no literal needed)

                            // ── Child Snapshot card ───────────────────
                            // Initials
                            string initials = "?";
                            if (!string.IsNullOrWhiteSpace(name))
                            {
                                var parts = name.Trim().Split(' ');
                                initials = parts.Length >= 2
                                    ? (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper()
                                    : name[0].ToString().ToUpper();
                            }
                            litSnapInitials.Text = Server.HtmlEncode(initials);
                            litSnapName.Text     = Server.HtmlEncode(displayName);
                            litSnapRel.Text      = !string.IsNullOrWhiteSpace(relationship)
                                ? Server.HtmlEncode(relationship)
                                : T("Family", "Keluarga");
                            litSnapStatus.Text   = T("Currently Learning", "Sedang Belajar");
                        }
                    }
                }
            }
            catch (SqlException) { }

            // Badge count for hero pill
            LoadHeroBadgeCount(studentId);
        }

        // ══════════════════════════════════════════════════════════════
        //  CHILD SNAPSHOT — RECENT LESSON + LATEST QUIZ
        // ══════════════════════════════════════════════════════════════

        private void LoadChildSnapshot(string studentId)
        {
            bool hasActivity = false;

            // ── Latest completed lesson ───────────────────────────────
            pnlSnapLesson.Visible = false;
            try
            {
                const string sql = @"
                    SELECT TOP 1 l.lessonTitleEN, l.lessonTitleBM, lp.completedDate
                    FROM dbo.[LessonProgress] lp
                    INNER JOIN dbo.[Lesson] l ON l.lessonId = lp.lessonId
                    WHERE lp.studentId = @studentId AND lp.isCompleted = 1
                    ORDER BY lp.completedDate DESC";

                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@studentId", studentId);
                    conn.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string title = CurrentLanguage == "BM"
                                ? (reader["lessonTitleBM"]?.ToString() ?? reader["lessonTitleEN"]?.ToString() ?? "-")
                                : (reader["lessonTitleEN"]?.ToString() ?? "-");
                            string date = reader["completedDate"] != DBNull.Value
                                ? Convert.ToDateTime(reader["completedDate"]).ToString("dd MMM yyyy")
                                : "";

                            litSnapLessonTitle.Text = Server.HtmlEncode(title);
                            litSnapLessonDate.Text  = Server.HtmlEncode(date);
                            pnlSnapLesson.Visible   = true;
                            hasActivity             = true;
                        }
                    }
                }
            }
            catch (SqlException) { }

            // ── Latest quiz result ────────────────────────────────────
            pnlSnapQuiz.Visible = false;
            try
            {
                const string sql = @"
                    SELECT TOP 1 q.quizTitleEN, q.quizTitleBM,
                                 qr.percentage, qr.resultStatus, qr.attemptedDate
                    FROM dbo.[QuizResult] qr
                    INNER JOIN dbo.[Quiz] q ON q.quizId = qr.quizId
                    WHERE qr.studentId = @studentId
                    ORDER BY qr.attemptedDate DESC";

                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@studentId", studentId);
                    conn.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string title = CurrentLanguage == "BM"
                                ? (reader["quizTitleBM"]?.ToString() ?? reader["quizTitleEN"]?.ToString() ?? "-")
                                : (reader["quizTitleEN"]?.ToString() ?? "-");
                            string pct    = reader["percentage"] != DBNull.Value
                                ? Convert.ToDecimal(reader["percentage"]).ToString("F0") + "%" : "-";
                            string status = reader["resultStatus"]?.ToString() ?? "";
                            string date   = reader["attemptedDate"] != DBNull.Value
                                ? Convert.ToDateTime(reader["attemptedDate"]).ToString("dd MMM yyyy") : "";

                            litSnapQuizTitle.Text = Server.HtmlEncode(title);
                            litSnapQuizMeta.Text  = Server.HtmlEncode(pct
                                + (!string.IsNullOrWhiteSpace(status) ? " · " + status : "")
                                + (!string.IsNullOrWhiteSpace(date)   ? " · " + date   : ""));
                            pnlSnapQuiz.Visible   = true;
                            hasActivity           = true;
                        }
                    }
                }
            }
            catch (SqlException) { }

            pnlSnapActivity.Visible   = hasActivity;
            pnlSnapNoActivity.Visible = !hasActivity;
        }

        private void LoadHeroBadgeCount(string studentId)
        {
            pnlHeroBadges.Visible = false;
            try
            {
                const string sql = "SELECT COUNT(*) FROM dbo.[StudentBadge] WHERE studentId = @studentId";
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@studentId", studentId);
                    conn.Open();
                    int count = Convert.ToInt32(cmd.ExecuteScalar());
                    if (count > 0)
                    {
                        litHeroBadges.Text    = count.ToString() + " " + T("Badges", "Lencana");
                        pnlHeroBadges.Visible = true;
                    }
                }
            }
            catch (SqlException) { }
        }

        // ══════════════════════════════════════════════════════════════
        //  SUMMARY COUNTS
        // ══════════════════════════════════════════════════════════════

        private void LoadSummaryCounts(string studentId)
        {
            // Defaults
            litProgressValue.Text   = "0%";
            litQuizScoreValue.Text  = "-";
            litBadgeValue.Text      = "0";

            try
            {
                const string sql = @"
                    SELECT
                        (SELECT COUNT(*) FROM dbo.[LessonProgress]
                         WHERE studentId = @studentId AND isCompleted = 1) AS completedLessons,
                        (SELECT COUNT(DISTINCT l.lessonId)
                         FROM dbo.[Enrollment] e
                         INNER JOIN dbo.[Unit] u ON u.levelId = e.levelId
                         INNER JOIN dbo.[Subtopic] st ON st.unitId = u.unitId
                         INNER JOIN dbo.[Lesson] l ON l.subtopicId = st.subtopicId
                         WHERE e.studentId = @studentId) AS totalLessons,
                        (SELECT AVG(percentage) FROM dbo.[QuizResult]
                         WHERE studentId = @studentId) AS avgPercentage,
                        (SELECT COUNT(*) FROM dbo.[StudentBadge]
                         WHERE studentId = @studentId) AS badgeCount";

                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@studentId", studentId);
                    conn.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            int completed = reader["completedLessons"] != DBNull.Value ? Convert.ToInt32(reader["completedLessons"]) : 0;
                            int total     = reader["totalLessons"] != DBNull.Value ? Convert.ToInt32(reader["totalLessons"]) : 0;
                            decimal avg   = reader["avgPercentage"] != DBNull.Value ? Convert.ToDecimal(reader["avgPercentage"]) : -1;
                            int badges    = reader["badgeCount"] != DBNull.Value ? Convert.ToInt32(reader["badgeCount"]) : 0;

                            // Overall progress
                            int progressPct = total > 0 ? (int)Math.Round((double)completed / total * 100) : 0;
                            litProgressValue.Text = progressPct.ToString() + "%";

                            // Average quiz score
                            litQuizScoreValue.Text = avg >= 0
                                ? avg.ToString("F1") + "%"
                                : T("No attempts yet", "Tiada percubaan lagi");

                            // Badges
                            litBadgeValue.Text = badges.ToString();
                        }
                    }
                }
            }
            catch (SqlException) { }
        }

        // ══════════════════════════════════════════════════════════════
        //  STUDY PLAN CARD
        // ══════════════════════════════════════════════════════════════

        private void LoadStudyPlanCard(string studentId)
        {
            pnlStudyPlanCard.Visible = false;
            pnlNoStudyPlan.Visible   = false;
            pnlSPTaskList.Controls.Clear();

            try
            {
                // Find studentParentId
                string studentParentId = "";
                const string spSql = @"
                    SELECT studentParentId FROM dbo.[StudentParent]
                    WHERE parentId = @parentId AND studentId = @studentId";

                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(spSql, conn))
                {
                    cmd.Parameters.AddWithValue("@parentId", _parentId);
                    cmd.Parameters.AddWithValue("@studentId", studentId);
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                        studentParentId = result.ToString();
                }

                if (string.IsNullOrEmpty(studentParentId))
                {
                    pnlNoStudyPlan.Visible = true;
                    return;
                }

                // Get latest study plan
                string studyPlanId = "";
                string planTitle   = "";
                DateTime planEnd   = DateTime.MaxValue;

                const string planSql = @"
                    SELECT TOP 1 studyPlanId, planTitle, endDate
                    FROM dbo.[StudyPlan]
                    WHERE studentParentId = @studentParentId
                    ORDER BY createdAt DESC";

                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(planSql, conn))
                {
                    cmd.Parameters.AddWithValue("@studentParentId", studentParentId);
                    conn.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            studyPlanId = reader["studyPlanId"]?.ToString() ?? "";
                            planTitle   = reader["planTitle"]?.ToString() ?? "";
                            if (reader["endDate"] != DBNull.Value)
                                planEnd = Convert.ToDateTime(reader["endDate"]);
                        }
                    }
                }

                if (string.IsNullOrEmpty(studyPlanId))
                {
                    pnlNoStudyPlan.Visible = true;
                    return;
                }

                // Set plan title in card header
                litStudyPlanTitle.Text = Server.HtmlEncode(planTitle);

                // Load ALL tasks (completed + pending) ordered by orderNo
                const string taskSql = @"
                    SELECT taskTitle, suggestedAction, isCompleted, completedAt, orderNo
                    FROM dbo.[SPTask]
                    WHERE studyPlanId = @studyPlanId
                    ORDER BY orderNo ASC";

                int totalTasks    = 0;
                int completedCount = 0;
                bool hasOverdue   = false;
                var taskHtmlList  = new System.Collections.Generic.List<string>();

                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(taskSql, conn))
                {
                    cmd.Parameters.AddWithValue("@studyPlanId", studyPlanId);
                    conn.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            totalTasks++;
                            string taskTitle  = reader["taskTitle"]?.ToString() ?? "-";
                            string suggested  = reader["suggestedAction"]?.ToString() ?? "";
                            bool isCompleted  = reader["isCompleted"] != DBNull.Value && Convert.ToBoolean(reader["isCompleted"]);
                            DateTime? completedAt = reader["completedAt"] != DBNull.Value
                                ? (DateTime?)Convert.ToDateTime(reader["completedAt"]) : null;

                            if (isCompleted)
                            {
                                completedCount++;

                                // Completed task row — softer style
                                string completedDateText = completedAt.HasValue
                                    ? T("Completed on ", "Selesai pada ") + completedAt.Value.ToString("dd MMM yyyy")
                                    : T("Completed", "Selesai");

                                string html = "<div class='pd-sp-task-row' style='opacity:0.75; border-left-color:#A7F3D0;'>"
                                    + "<div class='pd-sp-task-icon' style='background:#DCFCE7;color:#15803D;'><i class='bi bi-check-circle-fill'></i></div>"
                                    + "<div class='pd-sp-task-body'>"
                                    + "<div class='pd-sp-task-title' style='text-decoration:line-through;color:#64748B;'>" + Server.HtmlEncode(taskTitle) + "</div>"
                                    + (!string.IsNullOrWhiteSpace(suggested) ? "<div class='pd-sp-task-sub'>" + Server.HtmlEncode(suggested) + "</div>" : "")
                                    + "</div>"
                                    + "<span class='pd-sp-task-badge' style='background:#DCFCE7;color:#065F46;'>" + Server.HtmlEncode(completedDateText) + "</span>"
                                    + "</div>";

                                taskHtmlList.Add(html);
                            }
                            else
                            {
                                // Pending or overdue
                                bool isOverdue = planEnd < DateTime.Today;
                                if (isOverdue) hasOverdue = true;

                                string rowClass  = isOverdue ? "pd-sp-task-row overdue" : "pd-sp-task-row";
                                string badgeText = isOverdue ? T("Overdue", "Lewat") : T("Pending", "Belum selesai");
                                string badgeClass = isOverdue ? "pd-sp-task-badge overdue" : "pd-sp-task-badge pending";

                                string html = "<div class='" + rowClass + "'>"
                                    + "<div class='pd-sp-task-icon'><i class='bi bi-square'></i></div>"
                                    + "<div class='pd-sp-task-body'>"
                                    + "<div class='pd-sp-task-title'>" + Server.HtmlEncode(taskTitle) + "</div>"
                                    + (!string.IsNullOrWhiteSpace(suggested) ? "<div class='pd-sp-task-sub'>" + Server.HtmlEncode(suggested) + "</div>" : "")
                                    + "</div>"
                                    + "<span class='" + badgeClass + "'>" + badgeText + "</span>"
                                    + "</div>";

                                taskHtmlList.Add(html);
                            }
                        }
                    }
                }

                if (totalTasks == 0)
                {
                    pnlNoStudyPlan.Visible = true;
                    return;
                }

                // Status summary message above the checklist
                string statusHtml;
                if (completedCount == totalTasks)
                {
                    statusHtml = "<div style='display:flex;align-items:center;gap:6px;padding:8px 12px;margin-bottom:10px;"
                        + "background:#ECFDF5;border-radius:10px;font-size:0.82rem;font-weight:600;color:#065F46;'>"
                        + "<i class='bi bi-check-circle-fill'></i> "
                        + T("All tasks completed", "Semua tugasan selesai")
                        + "</div>";
                }
                else if (hasOverdue)
                {
                    statusHtml = "<div style='display:flex;align-items:center;gap:6px;padding:8px 12px;margin-bottom:10px;"
                        + "background:#FEF2F2;border-radius:10px;font-size:0.82rem;font-weight:600;color:#991B1B;'>"
                        + "<i class='bi bi-exclamation-triangle-fill'></i> "
                        + T("Some tasks are overdue", "Beberapa tugasan lewat")
                        + "</div>";
                }
                else
                {
                    statusHtml = "<div style='display:flex;align-items:center;gap:6px;padding:8px 12px;margin-bottom:10px;"
                        + "background:#FEF9EE;border-radius:10px;font-size:0.82rem;font-weight:600;color:#92400E;'>"
                        + "<i class='bi bi-clock'></i> "
                        + T("Some tasks are still pending", "Beberapa tugasan masih belum selesai")
                        + "</div>";
                }

                pnlSPTaskList.Controls.Add(new LiteralControl(statusHtml));

                // Render all task rows
                foreach (string taskHtml in taskHtmlList)
                {
                    pnlSPTaskList.Controls.Add(new LiteralControl(taskHtml));
                }

                pnlStudyPlanCard.Visible = true;
            }
            catch (SqlException)
            {
                pnlNoStudyPlan.Visible = true;
            }
        }

        // ══════════════════════════════════════════════════════════════
        //  RECENT ACTIVITIES (timeline)
        // ══════════════════════════════════════════════════════════════

        private void LoadRecentActivities(string studentId)
        {
            pnlRecentActivities.Controls.Clear();
            pnlNoActivities.Visible = false;

            try
            {
                // UNION of recent child activities — top 12 ordered by date desc
                const string sql = @"
                    SELECT TOP 12 actType, actTitle, actDate FROM (
                        SELECT 'lesson' AS actType,
                               CASE WHEN @lang = 'BM' THEN ISNULL(l.lessonTitleBM, l.lessonTitleEN) ELSE l.lessonTitleEN END AS actTitle,
                               CAST(lp.completedDate AS DATETIME) AS actDate
                        FROM dbo.[LessonProgress] lp
                        INNER JOIN dbo.[Lesson] l ON l.lessonId = lp.lessonId
                        WHERE lp.studentId = @studentId AND lp.isCompleted = 1 AND lp.completedDate IS NOT NULL
                    UNION ALL
                        SELECT 'quiz' AS actType,
                               CASE WHEN @lang = 'BM' THEN ISNULL(q.quizTitleBM, q.quizTitleEN) ELSE q.quizTitleEN END
                               + ' (' + CAST(CAST(qr.percentage AS INT) AS NVARCHAR) + '%)' AS actTitle,
                               CAST(qr.attemptedDate AS DATETIME) AS actDate
                        FROM dbo.[QuizResult] qr
                        INNER JOIN dbo.[Quiz] q ON q.quizId = qr.quizId
                        WHERE qr.studentId = @studentId AND qr.attemptedDate IS NOT NULL
                    UNION ALL
                        SELECT 'badge' AS actType,
                               CASE WHEN @lang = 'BM' THEN ISNULL(b.badgeNameBM, b.badgeNameEN) ELSE b.badgeNameEN END AS actTitle,
                               CAST(sb.earnedAt AS DATETIME) AS actDate
                        FROM dbo.[StudentBadge] sb
                        INNER JOIN dbo.[Badge] b ON b.badgeId = sb.badgeId
                        WHERE sb.studentId = @studentId AND sb.earnedAt IS NOT NULL
                    ) AS activities
                    ORDER BY actDate DESC";

                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@studentId", studentId);
                    cmd.Parameters.AddWithValue("@lang", CurrentLanguage);
                    conn.Open();

                    using (var reader = cmd.ExecuteReader())
                    {
                        bool hasRows      = false;
                        string lastDateStr = "";

                        while (reader.Read())
                        {
                            hasRows = true;
                            string actType  = reader["actType"]?.ToString() ?? "lesson";
                            string actTitle = reader["actTitle"]?.ToString() ?? "-";
                            DateTime actDate = reader["actDate"] != DBNull.Value
                                ? Convert.ToDateTime(reader["actDate"]) : DateTime.MinValue;

                            // Date heading
                            string dateLabel = FormatDateLabel(actDate);
                            if (dateLabel != lastDateStr)
                            {
                                if (!string.IsNullOrEmpty(lastDateStr))
                                    pnlRecentActivities.Controls.Add(new LiteralControl("</div>")); // close prev group
                                pnlRecentActivities.Controls.Add(new LiteralControl(
                                    "<div class='pd-timeline-group'><div class='pd-timeline-date'>" + Server.HtmlEncode(dateLabel) + "</div>"));
                                lastDateStr = dateLabel;
                            }

                            string dotClass = "pd-timeline-dot " + actType;
                            string time = actDate != DateTime.MinValue ? actDate.ToString("HH:mm") : "";

                            string html = "<div class='pd-timeline-item'>"
                                + "<div class='" + dotClass + "'></div>"
                                + "<div class='pd-timeline-content'>"
                                + "<div class='pd-timeline-text'>" + Server.HtmlEncode(actTitle) + "</div>"
                                + "</div>"
                                + (!string.IsNullOrEmpty(time) ? "<span class='pd-timeline-time'>" + time + "</span>" : "")
                                + "</div>";

                            pnlRecentActivities.Controls.Add(new LiteralControl(html));
                        }

                        if (hasRows)
                            pnlRecentActivities.Controls.Add(new LiteralControl("</div>")); // close last group
                        else
                            pnlNoActivities.Visible = true;
                    }
                }
            }
            catch (SqlException)
            {
                pnlNoActivities.Visible = true;
            }
        }

        private string FormatDateLabel(DateTime date)
        {
            if (date.Date == DateTime.Today)
                return T("Today", "Hari ini");
            if (date.Date == DateTime.Today.AddDays(-1))
                return T("Yesterday", "Semalam");
            return date.ToString("dd MMM yyyy");
        }

        // ══════════════════════════════════════════════════════════════
        //  FORUM PREVIEW (read-only)
        // ══════════════════════════════════════════════════════════════

        private string ForumActiveTab
        {
            get { return ViewState["ForumTab"] as string ?? "Public"; }
            set { ViewState["ForumTab"] = value; }
        }

        protected void ForumTabPublic_Click(object sender, EventArgs e)
        {
            ForumActiveTab = "Public";
            lnkTabPublic.CssClass  = "pd-forum-tab active";
            lnkTabPrivate.CssClass = "pd-forum-tab";
            LoadForumPosts();
        }

        protected void ForumTabPrivate_Click(object sender, EventArgs e)
        {
            ForumActiveTab = "Private";
            lnkTabPublic.CssClass  = "pd-forum-tab";
            lnkTabPrivate.CssClass = "pd-forum-tab active";
            LoadForumPosts();
        }

        protected void ForumFilter_Changed(object sender, EventArgs e)
        {
            LoadForumPosts();
        }

        private void LoadForumPosts()
        {
            pnlForumPosts.Controls.Clear();
            pnlNoForumPosts.Visible = false;

            // Populate tag dropdown if empty
            if (ddlForumTag.Items.Count == 0)
            {
                ddlForumTag.Items.Add(new System.Web.UI.WebControls.ListItem(T("All Tags", "Semua Tag"), ""));
                try
                {
                    const string tagSql = "SELECT tagId, tagName FROM dbo.[Tag] ORDER BY tagName";
                    using (var conn = new SqlConnection(ConnStr))
                    using (var cmd = new SqlCommand(tagSql, conn))
                    {
                        conn.Open();
                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                ddlForumTag.Items.Add(new System.Web.UI.WebControls.ListItem(
                                    reader["tagName"]?.ToString() ?? "", reader["tagId"]?.ToString() ?? ""));
                            }
                        }
                    }
                }
                catch (SqlException) { }
            }

            // Populate sort dropdown if empty
            if (ddlForumSort.Items.Count == 0)
            {
                ddlForumSort.Items.Add(new System.Web.UI.WebControls.ListItem(T("Latest", "Terkini"), "DESC"));
                ddlForumSort.Items.Add(new System.Web.UI.WebControls.ListItem(T("Oldest", "Terlama"), "ASC"));
            }

            // Build query
            string tab      = ForumActiveTab;
            string tagId    = ddlForumTag.SelectedValue;
            string sortDir  = ddlForumSort.SelectedValue == "ASC" ? "ASC" : "DESC";
            string keyword  = txtForumSearch.Text.Trim();

            try
            {
                string whereClause;
                var parameters = new System.Collections.Generic.List<SqlParameter>();

                if (tab == "Public")
                {
                    whereClause = "f.discussionType = 'Public'";
                }
                else
                {
                    // Private: createdBy is parent or linked child users
                    whereClause = "f.discussionType = 'Private' AND f.createdBy IN (SELECT s.userId FROM dbo.[StudentParent] sp INNER JOIN dbo.[Student] s ON s.studentId = sp.studentId WHERE sp.parentId = @parentId UNION ALL SELECT @parentUserId)";
                    parameters.Add(new SqlParameter("@parentId", _parentId));
                    parameters.Add(new SqlParameter("@parentUserId", _parentUserId));
                }

                // Tag filter
                if (!string.IsNullOrEmpty(tagId))
                {
                    whereClause += " AND f.forumId IN (SELECT ft.forumId FROM dbo.[ForumTag] ft WHERE ft.tagId = @tagId)";
                    parameters.Add(new SqlParameter("@tagId", tagId));
                }

                // Keyword filter
                if (!string.IsNullOrEmpty(keyword))
                {
                    whereClause += " AND (f.title LIKE @kw OR f.message LIKE @kw)";
                    parameters.Add(new SqlParameter("@kw", "%" + keyword + "%"));
                }

                string sql = @"
                    SELECT TOP 10 f.forumId, f.title, f.message, f.discussionType, f.createdAt, f.createdBy,
                           u.username,
                           (SELECT COUNT(*) FROM dbo.[ForumChat] fc WHERE fc.forumId = f.forumId) AS replyCount,
                           (SELECT COUNT(*) FROM dbo.[ForumLike] fl WHERE fl.forumId = f.forumId) AS likeCount
                    FROM dbo.[Forum] f
                    INNER JOIN dbo.[User] u ON u.userId = f.createdBy
                    WHERE " + whereClause + @"
                    ORDER BY f.createdAt " + sortDir;

                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    foreach (var p in parameters)
                        cmd.Parameters.Add(p);

                    conn.Open();
                    bool hasRows = false;

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            hasRows = true;
                            string forumId   = reader["forumId"]?.ToString() ?? "";
                            string title     = reader["title"]?.ToString() ?? "";
                            string message   = reader["message"]?.ToString() ?? "";
                            string discType  = reader["discussionType"]?.ToString() ?? "";
                            string username  = reader["username"]?.ToString() ?? "";
                            string createdAt = reader["createdAt"] != DBNull.Value
                                ? Convert.ToDateTime(reader["createdAt"]).ToString("dd MMM yyyy") : "";
                            int replies = reader["replyCount"] != DBNull.Value ? Convert.ToInt32(reader["replyCount"]) : 0;
                            int likes   = reader["likeCount"] != DBNull.Value ? Convert.ToInt32(reader["likeCount"]) : 0;

                            // Preview (first 100 chars)
                            string preview = message.Length > 100 ? message.Substring(0, 100) + "..." : message;

                            // Author initials
                            string initials = username.Length > 0 ? username[0].ToString().ToUpper() : "?";

                            // Badge
                            string badgeClass = discType == "Public" ? "pd-forum-post-badge public" : "pd-forum-post-badge private";
                            string badgeText  = discType == "Public" ? "PUBLIC" : "PRIVATE";

                            string html = "<div class='pd-forum-post'>"
                                + "<div class='pd-forum-post-header'>"
                                + "<div class='pd-forum-post-avatar'>" + Server.HtmlEncode(initials) + "</div>"
                                + "<div class='pd-forum-post-info'>"
                                + "<div class='pd-forum-post-title'>" + Server.HtmlEncode(title) + "</div>"
                                + "<div class='pd-forum-post-meta'>"
                                + Server.HtmlEncode(username) + " &bull; " + Server.HtmlEncode(createdAt)
                                + " <span class='" + badgeClass + "'>" + badgeText + "</span>"
                                + "</div></div></div>"
                                + "<div class='pd-forum-post-preview'>" + Server.HtmlEncode(preview) + "</div>"
                                + "<div class='pd-forum-post-tags' id='tags_" + Server.HtmlEncode(forumId) + "'></div>"
                                + "<div class='pd-forum-post-footer'>"
                                + "<span class='stat'><i class='bi bi-chat-dots'></i> " + replies + " " + T("replies", "balasan") + "</span>"
                                + "<span class='stat'><i class='bi bi-heart'></i> " + likes + "</span>"
                                + "<a href='" + ResolveUrl("~/Parent/ForumThread.aspx") + "?forumId=" + Server.UrlEncode(forumId) + "' class='pd-forum-open-btn'>"
                                + "<i class='bi bi-arrow-right-circle'></i> " + T("Open Thread", "Buka Perbincangan") + "</a>"
                                + "</div></div>";

                            pnlForumPosts.Controls.Add(new LiteralControl(html));
                        }
                    }

                    // Load tags for each post (lightweight second pass)
                    if (hasRows)
                        LoadForumPostTags(conn);

                    if (!hasRows)
                        pnlNoForumPosts.Visible = true;
                }
            }
            catch (SqlException)
            {
                pnlNoForumPosts.Visible = true;
            }
        }

        private void LoadForumPostTags(SqlConnection conn)
        {
            // Tags are rendered inline via a placeholder div; for simplicity we skip
            // a second query and accept that tags won't show in the mini preview.
            // Full tag display will be on ~/Parent/Forum.aspx.
        }

        // ══════════════════════════════════════════════════════════════
        //  EMPTY STATE / MESSAGES
        // ══════════════════════════════════════════════════════════════

        private void ShowNoLinkedChildState()
        {
            pnlNoChild.Visible       = false; // panel below hero kept hidden
            pnlDashboard.Visible     = false;
            pnlHeroNoChild.Visible   = true;
            pnlHeroViewing.Visible   = false;
        }

        private void ShowMessage(string message, bool isError)
        {
            pnlMessage.Visible = true;
            divMessage.InnerHtml = Server.HtmlEncode(message);
            divMessage.Attributes["class"] = isError ? "pd-msg error" : "pd-msg info";
        }
        private void LoadUnreadBadge()
        {
            try
            {
                using (var c = new System.Data.SqlClient.SqlConnection(ConnStr))
                using (var cmd = new System.Data.SqlClient.SqlCommand("SELECT COUNT(*) FROM dbo.Notification WHERE toUserId=@uid AND isRead=0", c))
                {
                    cmd.Parameters.AddWithValue("@uid", Session["userId"].ToString());
                    c.Open();
                    int count = (int)cmd.ExecuteScalar();
                    if (count > 0) litUnreadBadge.Text = "<span class='pt-sidebar-badge'>" + count + "</span>";
                    else litUnreadBadge.Text = "";
                }
            }
            catch { }
        }
    }
}