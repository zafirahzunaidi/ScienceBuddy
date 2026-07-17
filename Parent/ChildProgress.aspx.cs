using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Parent
{
    public partial class ChildProgress : Page
    {
        private string DatabaseConnectionString =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected string CurrentLanguage = "EN";

        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        private string _parentRecordId = "";
        private string _authenticatedUserId = "";
        private string _selectedChildId = "";
        private string _selectedChildName = "";
        private string _studentParentLinkId = "";

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
            LoadLanguagePreference();
            LoadUnreadNotificationBadge();
            _authenticatedUserId = Session["userId"].ToString();
            LoadParentRecordId();

            if (!IsPostBack)
            {
                ApplyPageLabels();
                LoadLinkedChildrenDropdown();

                if (!string.IsNullOrEmpty(_selectedChildId))
                {
                    pnlContent.Visible = true;
                    pnlNoChild.Visible = false;
                    PopulateMonthSelector();
                    RefreshAllPageData();
                }
                else
                {
                    ShowNoLinkedChildState();
                }
            }
            else
            {
                ApplyPageLabels();
                // On postback, dropdown items persist via ViewState
                _selectedChildId = ddlSidebarChild.SelectedValue;
                _selectedChildName = ddlSidebarChild.SelectedItem != null
                    ? ddlSidebarChild.SelectedItem.Text
                    : "";
                LoadStudentParentLinkId();

                if (!string.IsNullOrEmpty(_selectedChildId))
                {
                    pnlContent.Visible = true;
                    pnlNoChild.Visible = false;
                    BuildLearningHeatmap();
                }
            }
        }

        // ══════════════════════════════════════════════════════════════
        //  AUTHORIZATION & LANGUAGE
        // ══════════════════════════════════════════════════════════════
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
                    "SELECT preferredLanguage FROM dbo.[User] WHERE userId=@uid", connection))
                {
                    command.Parameters.AddWithValue("@uid", Session["userId"].ToString());
                    connection.Open();
                    object result = command.ExecuteScalar();

                    if (result != null && result != DBNull.Value)
                    {
                        string languageCode = result.ToString();
                        Session["preferredLanguage"] = languageCode;
                        CurrentLanguage = languageCode;
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
                    "SELECT parentId, name FROM dbo.[Parent] WHERE userId=@uid", connection))
                {
                    command.Parameters.AddWithValue("@uid", _authenticatedUserId);
                    connection.Open();

                    using (var reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            _parentRecordId = reader["parentId"].ToString();
                        }
                    }
                }
            }
            catch { }
        }

        // ══════════════════════════════════════════════════════════════
        //  LINKED CHILDREN
        // ══════════════════════════════════════════════════════════════
        private void LoadLinkedChildrenDropdown()
        {
            ddlSidebarChild.Items.Clear();

            try
            {
                const string childListQuery = @"SELECT sp.studentParentId, s.studentId, 
                    ISNULL(s.nickname, s.name) AS displayName
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
                string savedChildId = Session["selectedChildId"] as string;
                if (!string.IsNullOrEmpty(savedChildId) &&
                    ddlSidebarChild.Items.FindByValue(savedChildId) != null)
                {
                    ddlSidebarChild.SelectedValue = savedChildId;
                }
                else
                {
                    Session["selectedChildId"] = ddlSidebarChild.Items[0].Value;
                }

                _selectedChildId = ddlSidebarChild.SelectedValue;
                _selectedChildName = ddlSidebarChild.SelectedItem.Text;
                LoadStudentParentLinkId();
            }
        }

        private void LoadStudentParentLinkId()
        {
            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(
                    "SELECT studentParentId FROM dbo.StudentParent WHERE parentId=@pid AND studentId=@sid",
                    connection))
                {
                    command.Parameters.AddWithValue("@pid", _parentRecordId);
                    command.Parameters.AddWithValue("@sid", _selectedChildId);
                    connection.Open();
                    object result = command.ExecuteScalar();

                    if (result != null)
                    {
                        _studentParentLinkId = result.ToString();
                    }
                }
            }
            catch { }
        }

        protected void SidebarChildChanged(object sender, EventArgs e)
        {
            Session["selectedChildId"] = ddlSidebarChild.SelectedValue;
            _selectedChildId = ddlSidebarChild.SelectedValue;
            _selectedChildName = ddlSidebarChild.SelectedItem.Text;
            LoadStudentParentLinkId();
            pnlContent.Visible = true;
            pnlNoChild.Visible = false;
            pnlDailyModal.Visible = false;
            PopulateMonthSelector();
            RefreshAllPageData();
        }

        private void ShowNoLinkedChildState()
        {
            pnlContent.Visible = false;
            pnlNoChild.Visible = true;
            litNoChildMsg.Text = T(
                "No linked child found. Please link a child account first.",
                "Tiada anak dipautkan. Sila pautkan akaun anak terlebih dahulu.");
        }

        // ══════════════════════════════════════════════════════════════
        //  LABELS
        // ══════════════════════════════════════════════════════════════
        private void ApplyPageLabels()
        {
            litHeatmapTitle.Text = T("Learning Calendar", "Kalendar Pembelajaran");
            litCoachTitle.Text = T("Be a Coach!", "Jadi Pembimbing!");
            litAddToPlanBtn.Text = T("Add to Study Plan", "Tambah ke Pelan Belajar");
            litTaskModalTitle.Text = T("Add Quick Task to Study Plan", "Tambah Tugasan Ringkas ke Pelan Belajar");
            litLblTaskName.Text = T("Task Name", "Nama Tugasan");
            litLblSuggestedAction.Text = T("Suggested Action", "Cadangan Tindakan");
            litBtnCancel.Text = T("Cancel", "Batal");
            btnAddTask.Text = T("Add Task", "Tambah Tugasan");
            litDailyEmpty.Text = T(
                "No learning activity recorded on this day.",
                "Tiada aktiviti pembelajaran direkodkan pada hari ini.");
        }

        // ══════════════════════════════════════════════════════════════
        //  MONTH SELECTOR
        // ══════════════════════════════════════════════════════════════
        private void PopulateMonthSelector()
        {
            ddlMonth.Items.Clear();
            DateTime currentDate = DateTime.Now;

            for (int monthOffset = 0; monthOffset < 12; monthOffset++)
            {
                DateTime targetMonth = currentDate.AddMonths(-monthOffset);
                string displayLabel = targetMonth.ToString("MMMM yyyy", CultureInfo.InvariantCulture);
                string monthValue = targetMonth.ToString("yyyy-MM");
                ddlMonth.Items.Add(new ListItem(displayLabel, monthValue));
            }
            ddlMonth.SelectedIndex = 0;
        }

        protected void DdlMonth_Changed(object sender, EventArgs e)
        {
            RefreshAllPageData();
        }

        private DateTime GetSelectedMonthStart()
        {
            if (ddlMonth.SelectedValue != null && ddlMonth.SelectedValue.Contains("-"))
            {
                string[] dateParts = ddlMonth.SelectedValue.Split('-');
                return new DateTime(int.Parse(dateParts[0]), int.Parse(dateParts[1]), 1);
            }
            return new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
        }

        // ══════════════════════════════════════════════════════════════
        //  MAIN DATA ORCHESTRATOR
        // ══════════════════════════════════════════════════════════════
        private void RefreshAllPageData()
        {
            if (string.IsNullOrEmpty(_selectedChildId))
            {
                _selectedChildId = ddlSidebarChild.SelectedValue;
                _selectedChildName = ddlSidebarChild.SelectedItem != null
                    ? ddlSidebarChild.SelectedItem.Text : "";
                LoadStudentParentLinkId();
            }

            // Fetch fresh nickname from database
            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(
                    "SELECT ISNULL(nickname, name) FROM dbo.Student WHERE studentId=@sid", connection))
                {
                    command.Parameters.AddWithValue("@sid", _selectedChildId);
                    connection.Open();
                    object result = command.ExecuteScalar();

                    if (result != null && result != DBNull.Value)
                    {
                        _selectedChildName = result.ToString();
                    }
                }
            }
            catch { }

            // Hero section
            litHeroTitle.Text = string.Format(
                T("{0}'s Learning Progress", "Kemajuan Pembelajaran {0}"), _selectedChildName);
            litHeroSub.Text = T(
                "How is your child doing this month?",
                "Bagaimana perkembangan anak anda bulan ini?");
            litTaskModalSub.Text = string.Format(
                T("Help {0} continue learning today.", "Bantu {0} teruskan pembelajaran hari ini."),
                _selectedChildName);

            BuildLearningHeatmap();
            BuildCoachingSection();
        }

        // ══════════════════════════════════════════════════════════════
        //  LEARNING HEATMAP
        // ══════════════════════════════════════════════════════════════

        /// <summary>
        /// Builds the monthly heatmap calendar showing daily activity intensity.
        /// Color grades: none (grey), low (1 activity), medium (2-3), high (4+).
        /// </summary>
        private void BuildLearningHeatmap()
        {
            DateTime monthStart = GetSelectedMonthStart();
            int daysInMonth = DateTime.DaysInMonth(monthStart.Year, monthStart.Month);
            DateTime today = DateTime.Today;
            bool viewingCurrentMonth = (monthStart.Year == today.Year && monthStart.Month == today.Month);

            Dictionary<int, int> dailyActivityCounts = FetchActivityCountsForMonth(monthStart);

            RenderMonthlySummaryStats(monthStart, dailyActivityCounts);
            RenderHeatmapGrid(monthStart, daysInMonth, today, viewingCurrentMonth, dailyActivityCounts);
        }

        private void RenderMonthlySummaryStats(DateTime monthStart,
            Dictionary<int, int> dailyActivityCounts)
        {
            int activeDayCount = dailyActivityCounts.Count(kv => kv.Value > 0);
            int totalActivityCount = dailyActivityCounts.Values.Sum();
            int lessonsCompletedCount = 0;
            int quizAttemptCount = 0;

            try
            {
                DateTime monthEnd = monthStart.AddMonths(1).AddDays(-1);
                using (var connection = new SqlConnection(DatabaseConnectionString))
                {
                    connection.Open();

                    using (var command = new SqlCommand(
                        @"SELECT COUNT(*) FROM dbo.LessonProgress 
                        WHERE studentId=@sid AND isCompleted=1 
                        AND completedDate>=@start AND completedDate<=@end", connection))
                    {
                        command.Parameters.AddWithValue("@sid", _selectedChildId);
                        command.Parameters.AddWithValue("@start", monthStart);
                        command.Parameters.AddWithValue("@end", monthEnd);
                        lessonsCompletedCount = (int)command.ExecuteScalar();
                    }

                    using (var command = new SqlCommand(
                        @"SELECT COUNT(*) FROM dbo.QuizAttempt 
                        WHERE studentId=@sid AND attemptDate>=@start AND attemptDate<=@end",
                        connection))
                    {
                        command.Parameters.AddWithValue("@sid", _selectedChildId);
                        command.Parameters.AddWithValue("@start", monthStart);
                        command.Parameters.AddWithValue("@end", monthEnd);
                        quizAttemptCount = (int)command.ExecuteScalar();
                    }
                }
            }
            catch { }

            // Calculate consecutive learning streak
            int currentStreak = 0;
            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                {
                    connection.Open();
                    currentStreak = CalculateLearningStreak(connection);
                }
            }
            catch { }

            litMonthlySummary.Text = string.Format(
                "<div class='pt-monthly-stat'><div class='pt-monthly-stat-value'>{0}</div><div class='pt-monthly-stat-label'>{1}</div></div>"
                + "<div class='pt-monthly-stat'><div class='pt-monthly-stat-value'>{2}</div><div class='pt-monthly-stat-label'>{3}</div></div>"
                + "<div class='pt-monthly-stat'><div class='pt-monthly-stat-value'>{4}</div><div class='pt-monthly-stat-label'>{5}</div></div>"
                + "<div class='pt-monthly-stat'><div class='pt-monthly-stat-value'>{6}</div><div class='pt-monthly-stat-label'>{7}</div></div>",
                activeDayCount, T("Active Days", "Hari Aktif"),
                currentStreak, T("Day Streak", "Kesinambungan Hari"),
                lessonsCompletedCount, T("Lessons Done", "Pelajaran Selesai"),
                quizAttemptCount, T("Quiz Attempts", "Percubaan Kuiz"));
        }

        private void RenderHeatmapGrid(DateTime monthStart, int daysInMonth,
            DateTime today, bool viewingCurrentMonth, Dictionary<int, int> dailyActivityCounts)
        {
            // Monday-based week: Monday=0 ... Sunday=6
            int firstDayOffset = ((int)monthStart.DayOfWeek + 6) % 7;

            StringBuilder heatmapHtml = new StringBuilder();

            // Empty cells before the 1st of the month
            for (int emptySlot = 0; emptySlot < firstDayOffset; emptySlot++)
            {
                heatmapHtml.Append("<span class=\"pt-heatmap-day pt-heatmap-day-empty\"></span>");
            }

            // Render each day cell
            for (int dayNumber = 1; dayNumber <= daysInMonth; dayNumber++)
            {
                DateTime cellDate = new DateTime(monthStart.Year, monthStart.Month, dayNumber);
                bool isFutureDate = cellDate > today;
                bool isTodayDate = cellDate == today && viewingCurrentMonth;

                int activityCount = dailyActivityCounts.ContainsKey(dayNumber)
                    ? dailyActivityCounts[dayNumber]
                    : 0;

                string cellCssClass = DetermineHeatmapCellClass(isFutureDate, isTodayDate, activityCount);
                string dateString = cellDate.ToString("yyyy-MM-dd");

                string clickHandler = isFutureDate
                    ? ""
                    : string.Format(
                        " onclick=\"document.getElementById('{0}').value='{1}';document.getElementById('{2}').click();\"",
                        hidSelectedDate.ClientID, dateString, btnDayClick.ClientID);

                heatmapHtml.AppendFormat(
                    "<span class=\"{0}\" data-date=\"{1}\"{2}>{3}</span>",
                    cellCssClass, dateString, clickHandler, dayNumber);
            }

            pnlHeatmapDays.Controls.Clear();
            pnlHeatmapDays.Controls.Add(new LiteralControl(heatmapHtml.ToString()));
        }

        private string DetermineHeatmapCellClass(bool isFuture, bool isToday, int activityCount)
        {
            string cssClass = "pt-heatmap-day";

            if (isFuture)
            {
                cssClass += " pt-heatmap-day-disabled";
            }
            else if (isToday)
            {
                cssClass += " pt-heatmap-day-today";
            }

            if (!isFuture)
            {
                if (activityCount == 0)
                    cssClass += " pt-heatmap-day-none";
                else if (activityCount == 1)
                    cssClass += " pt-heatmap-day-low";
                else if (activityCount <= 3)
                    cssClass += " pt-heatmap-day-medium";
                else
                    cssClass += " pt-heatmap-day-high";
            }

            return cssClass;
        }

        /// <summary>
        /// Aggregates activity counts from multiple learning sources (lessons, labs,
        /// study plan tasks, live sessions, XP transactions) into a per-day dictionary.
        /// </summary>
        private Dictionary<int, int> FetchActivityCountsForMonth(DateTime monthStart)
        {
            var dailyCounts = new Dictionary<int, int>();
            DateTime monthEnd = monthStart.AddMonths(1).AddDays(-1);

            try
            {
                string aggregateQuery = @"
                    SELECT actDate, SUM(cnt) AS total FROM (
                        SELECT CAST(completedDate AS DATE) AS actDate, COUNT(*) AS cnt
                        FROM dbo.LessonProgress WHERE studentId=@sid AND isCompleted=1
                            AND completedDate >= @start AND completedDate <= @end GROUP BY CAST(completedDate AS DATE)
                        UNION ALL
                        SELECT CAST(completedDate AS DATE), COUNT(*)
                        FROM dbo.LabProgress WHERE studentId=@sid AND isCompleted=1
                            AND completedDate >= @start AND completedDate <= @end GROUP BY CAST(completedDate AS DATE)
                        UNION ALL
                        SELECT CAST(completedAt AS DATE), COUNT(*)
                        FROM dbo.SPTask t INNER JOIN dbo.StudyPlan sp ON t.studyPlanId=sp.studyPlanId
                        WHERE sp.studentParentId=@spid AND t.isCompleted=1
                            AND t.completedAt >= @start AND t.completedAt <= @end GROUP BY CAST(completedAt AS DATE)
                        UNION ALL
                        SELECT CAST(joinedAt AS DATE), COUNT(*)
                        FROM dbo.LiveSessionParticipant WHERE studentId=@sid
                            AND joinedAt >= @start AND joinedAt <= @end GROUP BY CAST(joinedAt AS DATE)
                        UNION ALL
                        SELECT CAST(dateEarned AS DATE), COUNT(*)
                        FROM dbo.XPTransaction WHERE studentId=@sid
                            AND dateEarned >= @start AND dateEarned <= @end GROUP BY CAST(dateEarned AS DATE)
                    ) AS combined GROUP BY actDate";

                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(aggregateQuery, connection))
                {
                    command.Parameters.AddWithValue("@sid", _selectedChildId);
                    command.Parameters.AddWithValue("@spid", _studentParentLinkId);
                    command.Parameters.AddWithValue("@start", monthStart);
                    command.Parameters.AddWithValue("@end", monthEnd);
                    connection.Open();

                    using (var reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            if (reader["actDate"] != DBNull.Value)
                            {
                                DateTime activityDate = Convert.ToDateTime(reader["actDate"]);
                                dailyCounts[activityDate.Day] = Convert.ToInt32(reader["total"]);
                            }
                        }
                    }
                }
            }
            catch { }

            return dailyCounts;
        }

        // ══════════════════════════════════════════════════════════════
        //  DAILY ACTIVITY DETAIL POPUP
        // ══════════════════════════════════════════════════════════════
        protected void BtnDayClick_Click(object sender, EventArgs e)
        {
            string dateString = hidSelectedDate.Value;
            if (string.IsNullOrEmpty(dateString))
            {
                return;
            }

            DateTime targetDate;
            if (!DateTime.TryParse(dateString, out targetDate))
            {
                return;
            }

            CultureInfo displayCulture = new CultureInfo(CurrentLanguage == "BM" ? "ms-MY" : "en-US");
            litDailyTitle.Text = string.Format(
                T("Learning Activity on {0}", "Aktiviti Pembelajaran pada {0}"),
                targetDate.ToString("d MMMM yyyy", displayCulture));

            var dailyActivities = FetchDailyActivityDetails(targetDate);

            pnlDailyActivities.Controls.Clear();
            if (dailyActivities.Count == 0)
            {
                pnlDailyEmpty.Visible = true;
            }
            else
            {
                pnlDailyEmpty.Visible = false;
                StringBuilder activitiesHtml = new StringBuilder();

                foreach (var activity in dailyActivities)
                {
                    string iconCssClass = ResolveActivityIcon(activity.ActivityType);
                    string backgroundCssClass = ResolveActivityBackground(activity.ActivityType);

                    activitiesHtml.AppendFormat(@"<div class=""pt-daily-activity-row"">
                        <div class=""pt-daily-activity-icon {0}""><i class=""bi {1}""></i></div>
                        <div class=""pt-daily-activity-text"">{2}</div>
                    </div>", backgroundCssClass, iconCssClass, activity.Description);
                }

                pnlDailyActivities.Controls.Add(new LiteralControl(activitiesHtml.ToString()));
            }

            pnlDailyModal.Visible = true;
        }

        private string ResolveActivityIcon(string activityType)
        {
            switch (activityType)
            {
                case "lesson": return "bi-book-half";
                case "lab": return "bi-cpu";
                case "task": return "bi-check2-circle";
                case "session": return "bi-camera-video";
                case "quiz": return "bi-patch-question";
                default: return "bi-lightning-charge";
            }
        }

        private string ResolveActivityBackground(string activityType)
        {
            switch (activityType)
            {
                case "lesson": return "pt-act-icon-lesson";
                case "lab": return "pt-act-icon-lab";
                case "task": return "pt-act-icon-task";
                case "session": return "pt-act-icon-session";
                case "quiz": return "pt-act-icon-quiz";
                default: return "pt-act-icon-xp";
            }
        }

        protected void BtnCloseDailyModal_Click(object sender, EventArgs e)
        {
            pnlDailyModal.Visible = false;
            BuildLearningHeatmap();
        }

        private List<LearningActivityRecord> FetchDailyActivityDetails(DateTime targetDate)
        {
            var activityList = new List<LearningActivityRecord>();

            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                {
                    connection.Open();
                    FetchCompletedLessonsForDate(connection, targetDate, activityList);
                    FetchCompletedLabsForDate(connection, targetDate, activityList);
                    FetchCompletedTasksForDate(connection, targetDate, activityList);
                    FetchLiveSessionsForDate(connection, targetDate, activityList);
                    FetchQuizActivityForDate(connection, targetDate, activityList);
                }
            }
            catch { }

            return activityList;
        }

        private void FetchCompletedLessonsForDate(SqlConnection connection,
            DateTime targetDate, List<LearningActivityRecord> activityList)
        {
            const string lessonQuery = @"SELECT l.lessonTitleEN, l.lessonTitleBM 
                FROM dbo.LessonProgress lp
                INNER JOIN dbo.Lesson l ON lp.lessonId=l.lessonId
                WHERE lp.studentId=@sid AND lp.isCompleted=1 AND CAST(lp.completedDate AS DATE)=@d";

            using (var command = new SqlCommand(lessonQuery, connection))
            {
                command.Parameters.AddWithValue("@sid", _selectedChildId);
                command.Parameters.AddWithValue("@d", targetDate.Date);

                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string lessonTitle = CurrentLanguage == "BM" && reader["lessonTitleBM"] != DBNull.Value
                            ? reader["lessonTitleBM"].ToString()
                            : reader["lessonTitleEN"].ToString();

                        activityList.Add(new LearningActivityRecord("lesson",
                            string.Format(T("Completed lesson: {0}", "Selesai pelajaran: {0}"), lessonTitle)));
                    }
                }
            }
        }

        private void FetchCompletedLabsForDate(SqlConnection connection,
            DateTime targetDate, List<LearningActivityRecord> activityList)
        {
            const string labQuery = @"SELECT vl.labTitleEN, vl.labTitleBM 
                FROM dbo.LabProgress lp
                INNER JOIN dbo.VirtualLab vl ON lp.labId=vl.labId
                WHERE lp.studentId=@sid AND lp.isCompleted=1 AND CAST(lp.completedDate AS DATE)=@d";

            using (var command = new SqlCommand(labQuery, connection))
            {
                command.Parameters.AddWithValue("@sid", _selectedChildId);
                command.Parameters.AddWithValue("@d", targetDate.Date);

                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string labTitle = CurrentLanguage == "BM" && reader["labTitleBM"] != DBNull.Value
                            ? reader["labTitleBM"].ToString()
                            : reader["labTitleEN"].ToString();

                        activityList.Add(new LearningActivityRecord("lab",
                            string.Format(T("Completed virtual lab: {0}", "Selesai makmal maya: {0}"), labTitle)));
                    }
                }
            }
        }

        private void FetchCompletedTasksForDate(SqlConnection connection,
            DateTime targetDate, List<LearningActivityRecord> activityList)
        {
            const string taskQuery = @"SELECT t.taskTitle FROM dbo.SPTask t
                INNER JOIN dbo.StudyPlan sp ON t.studyPlanId=sp.studyPlanId
                WHERE sp.studentParentId=@spid AND t.isCompleted=1 AND CAST(t.completedAt AS DATE)=@d";

            using (var command = new SqlCommand(taskQuery, connection))
            {
                command.Parameters.AddWithValue("@spid", _studentParentLinkId);
                command.Parameters.AddWithValue("@d", targetDate.Date);

                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        activityList.Add(new LearningActivityRecord("task",
                            string.Format(T("Study plan task completed: {0}",
                                "Tugasan pelan belajar selesai: {0}"), reader["taskTitle"].ToString())));
                    }
                }
            }
        }

        private void FetchLiveSessionsForDate(SqlConnection connection,
            DateTime targetDate, List<LearningActivityRecord> activityList)
        {
            const string sessionQuery = @"SELECT lcs.sessionTitle 
                FROM dbo.LiveSessionParticipant lsp
                INNER JOIN dbo.LiveConsultationSession lcs ON lsp.sessionId=lcs.sessionId
                WHERE lsp.studentId=@sid AND CAST(lsp.joinedAt AS DATE)=@d";

            using (var command = new SqlCommand(sessionQuery, connection))
            {
                command.Parameters.AddWithValue("@sid", _selectedChildId);
                command.Parameters.AddWithValue("@d", targetDate.Date);

                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        activityList.Add(new LearningActivityRecord("session",
                            string.Format(T("Joined live session: {0}",
                                "Menyertai sesi langsung: {0}"), reader["sessionTitle"].ToString())));
                    }
                }
            }
        }

        private void FetchQuizActivityForDate(SqlConnection connection,
            DateTime targetDate, List<LearningActivityRecord> activityList)
        {
            using (var command = new SqlCommand(
                @"SELECT COUNT(*) FROM dbo.QuizResult
                WHERE studentId=@sid AND CAST(attemptedDate AS DATE)=@d", connection))
            {
                command.Parameters.AddWithValue("@sid", _selectedChildId);
                command.Parameters.AddWithValue("@d", targetDate.Date);
                int quizCount = (int)command.ExecuteScalar();

                if (quizCount > 0)
                {
                    activityList.Add(new LearningActivityRecord("quiz",
                        T("Quiz activity recorded. View Quiz Results for marks and details.",
                          "Aktiviti kuiz direkodkan. Lihat Keputusan Kuiz untuk markah dan butiran.")));
                }
            }
        }

        private class LearningActivityRecord
        {
            public string ActivityType;
            public string Description;

            public LearningActivityRecord(string type, string description)
            {
                ActivityType = type;
                Description = description;
            }
        }

        // ══════════════════════════════════════════════════════════════
        //  COACHING SECTION ("Be a Coach!")
        // ══════════════════════════════════════════════════════════════

        /// <summary>
        /// Analyzes child activity patterns to determine engagement level (none/slow/good/amazing)
        /// and renders personalized coaching advice with a matching illustration.
        /// </summary>
        private void BuildCoachingSection()
        {
            DateTime now = DateTime.Now;
            DateTime monthStart = new DateTime(now.Year, now.Month, 1);
            DateTime weekStart = now.AddDays(
                -(int)(now.DayOfWeek == DayOfWeek.Sunday ? 6 : (int)now.DayOfWeek - 1));

            int weeklyActivityCount = 0;
            int monthlyActivityCount = 0;
            int activeLearningDaysThisMonth = 0;
            int daysSinceLastActivity = 999;
            int overdueTaskCount = 0;
            int consecutiveStreak = 0;

            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                {
                    connection.Open();

                    weeklyActivityCount = CountActivitiesSince(connection, weekStart);
                    FetchMonthlyActivityStats(connection, monthStart,
                        out monthlyActivityCount, out activeLearningDaysThisMonth);
                    daysSinceLastActivity = CalculateDaysSinceLastActivity(connection);
                    overdueTaskCount = CountOverdueTasks(connection);
                    consecutiveStreak = CalculateLearningStreak(connection);
                }
            }
            catch { }

            string engagementLevel = DetermineEngagementLevel(
                weeklyActivityCount, monthlyActivityCount, daysSinceLastActivity);

            RenderCoachIllustration(engagementLevel);
            RenderCoachMessage(engagementLevel, monthlyActivityCount);
        }

        private int CountActivitiesSince(SqlConnection connection, DateTime sinceDate)
        {
            using (var command = new SqlCommand(@"SELECT COUNT(*) FROM (
                SELECT completedDate AS d FROM dbo.LessonProgress WHERE studentId=@sid AND isCompleted=1 AND completedDate>=@ws
                UNION ALL SELECT completedDate FROM dbo.LabProgress WHERE studentId=@sid AND isCompleted=1 AND completedDate>=@ws
                UNION ALL SELECT completedAt FROM dbo.SPTask t INNER JOIN dbo.StudyPlan sp ON t.studyPlanId=sp.studyPlanId
                    WHERE sp.studentParentId=@spid AND t.isCompleted=1 AND t.completedAt>=@ws
                ) x", connection))
            {
                command.Parameters.AddWithValue("@sid", _selectedChildId);
                command.Parameters.AddWithValue("@spid", _studentParentLinkId);
                command.Parameters.AddWithValue("@ws", sinceDate);
                return (int)command.ExecuteScalar();
            }
        }

        private void FetchMonthlyActivityStats(SqlConnection connection, DateTime monthStart,
            out int totalCount, out int activeDays)
        {
            totalCount = 0;
            activeDays = 0;

            using (var command = new SqlCommand(@"SELECT COUNT(*) AS total, COUNT(DISTINCT CAST(d AS DATE)) AS days FROM (
                SELECT completedDate AS d FROM dbo.LessonProgress WHERE studentId=@sid AND isCompleted=1 AND completedDate>=@ms
                UNION ALL SELECT completedDate FROM dbo.LabProgress WHERE studentId=@sid AND isCompleted=1 AND completedDate>=@ms
                UNION ALL SELECT completedAt FROM dbo.SPTask t INNER JOIN dbo.StudyPlan sp ON t.studyPlanId=sp.studyPlanId
                    WHERE sp.studentParentId=@spid AND t.isCompleted=1 AND t.completedAt>=@ms
            ) x", connection))
            {
                command.Parameters.AddWithValue("@sid", _selectedChildId);
                command.Parameters.AddWithValue("@spid", _studentParentLinkId);
                command.Parameters.AddWithValue("@ms", monthStart);

                using (var reader = command.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        totalCount = reader["total"] != DBNull.Value ? Convert.ToInt32(reader["total"]) : 0;
                        activeDays = reader["days"] != DBNull.Value ? Convert.ToInt32(reader["days"]) : 0;
                    }
                }
            }
        }

        private int CalculateDaysSinceLastActivity(SqlConnection connection)
        {
            using (var command = new SqlCommand(@"SELECT MAX(d) FROM (
                SELECT MAX(completedDate) AS d FROM dbo.LessonProgress WHERE studentId=@sid AND isCompleted=1
                UNION ALL SELECT MAX(completedDate) FROM dbo.LabProgress WHERE studentId=@sid AND isCompleted=1
            ) x", connection))
            {
                command.Parameters.AddWithValue("@sid", _selectedChildId);
                object result = command.ExecuteScalar();

                if (result != null && result != DBNull.Value)
                {
                    return (DateTime.Today - Convert.ToDateTime(result).Date).Days;
                }
            }
            return 999;
        }

        private int CountOverdueTasks(SqlConnection connection)
        {
            using (var command = new SqlCommand(@"SELECT COUNT(*) FROM dbo.SPTask t
                INNER JOIN dbo.StudyPlan sp ON t.studyPlanId=sp.studyPlanId
                WHERE sp.studentParentId=@spid AND t.isCompleted=0 AND sp.endDate < @today",
                connection))
            {
                command.Parameters.AddWithValue("@spid", _studentParentLinkId);
                command.Parameters.AddWithValue("@today", DateTime.Today);
                return (int)command.ExecuteScalar();
            }
        }

        private string DetermineEngagementLevel(int weeklyActivities,
            int monthlyActivities, int daysSinceLastActivity)
        {
            if (daysSinceLastActivity > 14 || daysSinceLastActivity == 999)
            {
                return "none";
            }
            else if (weeklyActivities >= 2 && monthlyActivities >= 6 && daysSinceLastActivity <= 3)
            {
                return "amazing";
            }
            else if (weeklyActivities >= 1 && monthlyActivities >= 3 && daysSinceLastActivity <= 7)
            {
                return "good";
            }
            else
            {
                return "slow";
            }
        }

        private void RenderCoachIllustration(string engagementLevel)
        {
            string illustrationPath;
            string altText;

            if (engagementLevel == "slow" || engagementLevel == "none")
            {
                illustrationPath = "../Images/Parent/low-progress.png";
                altText = "😴 🦊";
            }
            else if (engagementLevel == "amazing")
            {
                illustrationPath = "../Images/Parent/amazing-progress.png";
                altText = "🎉 🦊";
            }
            else
            {
                illustrationPath = "../Images/Parent/good-progress.png";
                altText = "😊 🦊";
            }

            imgFox.ImageUrl = illustrationPath;
            imgFox.AlternateText = altText;
        }

        private void RenderCoachMessage(string engagementLevel, int monthlyActivityCount)
        {
            if (engagementLevel == "none")
            {
                litCoachMessage.Text = string.Format(
                    T("{0} has not been active for a while. A gentle reminder might help restart their learning!",
                      "{0} tidak aktif sejak sekian lama. Peringatan lembut mungkin membantu memulakan semula pembelajaran!"),
                    _selectedChildName);
                pnlCoachTip.Visible = true;
                litCoachTip.Text = T(
                    "Try setting a small daily goal or exploring a new topic together.",
                    "Cuba tetapkan matlamat harian kecil atau terokai topik baharu bersama.");
                pnlAddStudyPlanBtn.Visible = true;
            }
            else if (engagementLevel == "slow")
            {
                string personalizedTip = BuildPersonalizedRecommendation();
                litCoachMessage.Text = string.Format(
                    T("{0} needs a little encouragement. Activity has been low this month.",
                      "{0} memerlukan sedikit galakan. Aktiviti masih rendah bulan ini."),
                    _selectedChildName);
                pnlCoachTip.Visible = true;
                litCoachTip.Text = personalizedTip;
                pnlAddStudyPlanBtn.Visible = true;
            }
            else if (engagementLevel == "amazing")
            {
                litCoachMessage.Text = string.Format(
                    T("Amazing! {0} has completed {1} learning activities this month. Keep the streak going!",
                      "Luar biasa! {0} telah menyelesaikan {1} aktiviti pembelajaran bulan ini. Teruskan momentum!"),
                    _selectedChildName, monthlyActivityCount);
                pnlCoachTip.Visible = false;
                pnlAddStudyPlanBtn.Visible = false;
            }
            else
            {
                litCoachMessage.Text = string.Format(
                    T("Good progress! {0} is building a steady learning habit with {1} activities this month.",
                      "Kemajuan baik! {0} sedang membina tabiat pembelajaran yang stabil dengan {1} aktiviti bulan ini."),
                    _selectedChildName, monthlyActivityCount);
                pnlCoachTip.Visible = false;
                pnlAddStudyPlanBtn.Visible = false;
            }
        }

        /// <summary>
        /// Calculates consecutive days with learning activity, ending today or yesterday.
        /// Used for the streak display in the monthly summary.
        /// </summary>
        private int CalculateLearningStreak(SqlConnection connection)
        {
            int streakCount = 0;

            try
            {
                using (var command = new SqlCommand(@"SELECT DISTINCT CAST(d AS DATE) AS actDate FROM (
                    SELECT completedDate AS d FROM dbo.LessonProgress WHERE studentId=@sid AND isCompleted=1 AND completedDate >= @start
                    UNION ALL SELECT completedDate FROM dbo.LabProgress WHERE studentId=@sid AND isCompleted=1 AND completedDate >= @start
                ) x ORDER BY actDate DESC", connection))
                {
                    command.Parameters.AddWithValue("@sid", _selectedChildId);
                    command.Parameters.AddWithValue("@start", DateTime.Today.AddDays(-30));

                    using (var reader = command.ExecuteReader())
                    {
                        DateTime expectedDate = DateTime.Today;
                        bool isFirstRecord = true;

                        while (reader.Read())
                        {
                            DateTime activityDate = Convert.ToDateTime(reader["actDate"]).Date;

                            if (isFirstRecord)
                            {
                                // Streak must start from today or yesterday
                                if (activityDate != DateTime.Today &&
                                    activityDate != DateTime.Today.AddDays(-1))
                                {
                                    break;
                                }
                                expectedDate = activityDate;
                                isFirstRecord = false;
                            }

                            if (activityDate == expectedDate)
                            {
                                streakCount++;
                                expectedDate = expectedDate.AddDays(-1);
                            }
                            else
                            {
                                break;
                            }
                        }
                    }
                }
            }
            catch { }

            return streakCount;
        }

        /// <summary>
        /// Generates a personalized learning recommendation based on priority:
        /// 1. AI-identified weak topics, 2. Next unfinished lesson, 3. Generic advice.
        /// </summary>
        private string BuildPersonalizedRecommendation()
        {
            string recommendation = "";

            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                {
                    connection.Open();

                    // Priority 1: AI-detected weak topics from learning analysis
                    using (var command = new SqlCommand(
                        @"SELECT TOP 1 weakTopics FROM dbo.AILearningAnalysis
                        WHERE studentId=@sid AND isLatest=1 AND weakTopics IS NOT NULL AND weakTopics <> ''",
                        connection))
                    {
                        command.Parameters.AddWithValue("@sid", _selectedChildId);
                        object result = command.ExecuteScalar();

                        if (result != null && result != DBNull.Value)
                        {
                            string weakTopicsList = result.ToString();
                            string topWeakTopic = weakTopicsList.Contains(",")
                                ? weakTopicsList.Split(',')[0].Trim()
                                : weakTopicsList.Trim();

                            recommendation = string.Format(
                                T("Try asking {0} to spend 20 minutes reviewing: {1}",
                                  "Cuba minta {0} luangkan 20 minit mengulangkaji: {1}"),
                                _selectedChildName, topWeakTopic);
                            return recommendation;
                        }
                    }

                    // Priority 2: Next lesson the child hasn't completed
                    using (var command = new SqlCommand(
                        @"SELECT TOP 1 l.lessonTitleEN, l.lessonTitleBM, u.unitNameEN, u.unitNameBM
                        FROM dbo.Lesson l
                        INNER JOIN dbo.Subtopic st ON l.subtopicId=st.subtopicId
                        INNER JOIN dbo.Unit u ON st.unitId=u.unitId
                        WHERE l.lessonId NOT IN (SELECT lessonId FROM dbo.LessonProgress WHERE studentId=@sid AND isCompleted=1)
                        ORDER BY u.orderNo, st.orderNo, l.orderNo", connection))
                    {
                        command.Parameters.AddWithValue("@sid", _selectedChildId);

                        using (var reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string unitName = CurrentLanguage == "BM" && reader["unitNameBM"] != DBNull.Value
                                    ? reader["unitNameBM"].ToString()
                                    : reader["unitNameEN"].ToString();

                                recommendation = string.Format(
                                    T("Try asking {0} to spend 15 minutes reviewing {1}.",
                                      "Cuba minta {0} luangkan 15 minit mengulangkaji {1}."),
                                    _selectedChildName, unitName);
                                return recommendation;
                            }
                        }
                    }
                }
            }
            catch { }

            // Fallback: general encouragement
            if (string.IsNullOrEmpty(recommendation))
            {
                recommendation = string.Format(
                    T("Try asking {0} to spend 15 minutes on a science revision activity.",
                      "Cuba minta {0} luangkan 15 minit untuk aktiviti ulangkaji sains."),
                    _selectedChildName);
            }

            return recommendation;
        }

        // ══════════════════════════════════════════════════════════════
        //  ADD TASK TO STUDY PLAN
        // ══════════════════════════════════════════════════════════════
        protected void BtnAddTask_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtTaskName.Text))
            {
                ShowFeedbackMessage(
                    T("Please enter a task name.", "Sila masukkan nama tugasan."), false);
                return;
            }

            if (string.IsNullOrEmpty(_selectedChildId))
            {
                _selectedChildId = ddlSidebarChild.SelectedValue;
                _selectedChildName = ddlSidebarChild.SelectedItem != null
                    ? ddlSidebarChild.SelectedItem.Text : "";
                LoadStudentParentLinkId();
            }

            if (string.IsNullOrEmpty(_studentParentLinkId))
            {
                ShowFeedbackMessage(
                    T("Unable to find child link.", "Tidak dapat mencari pautan anak."), false);
                return;
            }

            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                {
                    connection.Open();

                    // Find active/ongoing study plan for this parent-child pair
                    string activePlanId = FindActiveStudyPlan(connection);

                    using (var transaction = connection.BeginTransaction())
                    {
                        try
                        {
                            // Create a new plan if none exists
                            if (string.IsNullOrEmpty(activePlanId))
                            {
                                activePlanId = CreateQuickSupportPlan(connection, transaction);
                            }

                            int nextOrderNumber = GetMaxTaskOrder(connection, transaction, activePlanId) + 1;
                            string newTaskId = GenerateSequentialId(connection, transaction, "SPTask", "spTaskId", "SPT");

                            InsertStudyPlanTask(connection, transaction, newTaskId,
                                activePlanId, nextOrderNumber);

                            // Notify the child about the new task
                            string childUserId = LookupChildUserId(connection, transaction);
                            if (!string.IsNullOrEmpty(childUserId))
                            {
                                SendTaskAddedNotification(connection, transaction, childUserId);
                            }

                            transaction.Commit();

                            txtTaskName.Text = "";
                            txtSuggestedAction.Text = "";
                            pnlTaskModal.CssClass = "pt-task-modal-overlay pt-task-modal-hidden";
                            ShowFeedbackMessage(
                                T("The task has been added to the study plan.",
                                  "Tugasan telah ditambah ke pelan belajar."), true);
                            BuildLearningHeatmap();
                            BuildCoachingSection();
                        }
                        catch
                        {
                            transaction.Rollback();
                            throw;
                        }
                    }
                }
            }
            catch
            {
                ShowFeedbackMessage(
                    T("An error occurred while adding the task.",
                      "Ralat berlaku semasa menambah tugasan."), false);
            }
        }

        private string FindActiveStudyPlan(SqlConnection connection)
        {
            using (var command = new SqlCommand(
                @"SELECT TOP 1 studyPlanId FROM dbo.StudyPlan
                WHERE studentParentId=@spid AND status='Ongoing' ORDER BY createdAt DESC",
                connection))
            {
                command.Parameters.AddWithValue("@spid", _studentParentLinkId);
                object result = command.ExecuteScalar();

                if (result != null && result != DBNull.Value)
                {
                    return result.ToString();
                }
            }
            return null;
        }

        private string CreateQuickSupportPlan(SqlConnection connection, SqlTransaction transaction)
        {
            string planId = GenerateSequentialId(connection, transaction, "StudyPlan", "studyPlanId", "STP");

            using (var command = new SqlCommand(@"INSERT INTO dbo.StudyPlan
                (studyPlanId, studentParentId, createdByUserId, planTitle, startDate, endDate, status, createdAt)
                VALUES (@id, @spid, @uid, @title, @start, @end, 'Ongoing', @now)",
                connection, transaction))
            {
                command.Parameters.AddWithValue("@id", planId);
                command.Parameters.AddWithValue("@spid", _studentParentLinkId);
                command.Parameters.AddWithValue("@uid", _authenticatedUserId);
                command.Parameters.AddWithValue("@title", "Quick Support Plan");
                command.Parameters.AddWithValue("@start", DateTime.Today);
                command.Parameters.AddWithValue("@end", DateTime.Today.AddDays(7));
                command.Parameters.AddWithValue("@now", DateTime.Now);
                command.ExecuteNonQuery();
            }

            return planId;
        }

        private int GetMaxTaskOrder(SqlConnection connection, SqlTransaction transaction, string planId)
        {
            using (var command = new SqlCommand(
                "SELECT ISNULL(MAX(orderNo),0) FROM dbo.SPTask WHERE studyPlanId=@spid",
                connection, transaction))
            {
                command.Parameters.AddWithValue("@spid", planId);
                return (int)command.ExecuteScalar();
            }
        }

        private void InsertStudyPlanTask(SqlConnection connection, SqlTransaction transaction,
            string taskId, string planId, int orderNumber)
        {
            using (var command = new SqlCommand(@"INSERT INTO dbo.SPTask
                (spTaskId, studyPlanId, taskTitle, suggestedAction, orderNo, isCompleted, completedAt)
                VALUES (@id, @spid, @title, @action, @order, 0, NULL)",
                connection, transaction))
            {
                command.Parameters.AddWithValue("@id", taskId);
                command.Parameters.AddWithValue("@spid", planId);
                command.Parameters.AddWithValue("@title", txtTaskName.Text.Trim());
                command.Parameters.AddWithValue("@action",
                    string.IsNullOrEmpty(txtSuggestedAction.Text)
                        ? (object)DBNull.Value
                        : txtSuggestedAction.Text.Trim());
                command.Parameters.AddWithValue("@order", orderNumber);
                command.ExecuteNonQuery();
            }
        }

        private void SendTaskAddedNotification(SqlConnection connection,
            SqlTransaction transaction, string childUserId)
        {
            CreateNotificationRecord(connection, transaction, childUserId,
                "New study task added", "Tugasan belajar baharu ditambah",
                "Your parent added a new study task: " + txtTaskName.Text.Trim() + ".",
                "Ibu bapa anda menambah tugasan belajar baharu: " + txtTaskName.Text.Trim() + ".");
        }

        // ══════════════════════════════════════════════════════════════
        //  SHARED UTILITIES
        // ══════════════════════════════════════════════════════════════
        private string GenerateSequentialId(SqlConnection connection, SqlTransaction transaction,
            string tableName, string columnName, string prefix)
        {
            int nextSequence = 1;
            string maxIdQuery = string.Format("SELECT MAX({0}) FROM dbo.[{1}]", columnName, tableName);

            using (var command = new SqlCommand(maxIdQuery, connection, transaction))
            {
                object result = command.ExecuteScalar();

                if (result != null && result != DBNull.Value)
                {
                    string lastId = result.ToString();
                    if (lastId.Length > prefix.Length)
                    {
                        int numericPart;
                        if (int.TryParse(lastId.Substring(prefix.Length), out numericPart))
                        {
                            nextSequence = numericPart + 1;
                        }
                    }
                }
            }

            return prefix + nextSequence.ToString("D3");
        }

        private void CreateNotificationRecord(SqlConnection connection, SqlTransaction transaction,
            string recipientUserId, string titleEN, string titleBM, string messageEN, string messageBM)
        {
            try
            {
                string notificationId = GenerateSequentialId(
                    connection, transaction, "Notification", "notificationId", "N");

                using (var command = new SqlCommand(
                    @"INSERT INTO dbo.Notification(notificationId,toUserId,titleEN,titleBM,messageEN,messageBM,isRead,createdAt)
                    VALUES(@id,@to,@te,@tb,@me,@mb,0,@now)", connection, transaction))
                {
                    command.Parameters.AddWithValue("@id", notificationId);
                    command.Parameters.AddWithValue("@to", recipientUserId);
                    command.Parameters.AddWithValue("@te", titleEN);
                    command.Parameters.AddWithValue("@tb", titleBM);
                    command.Parameters.AddWithValue("@me", messageEN);
                    command.Parameters.AddWithValue("@mb", messageBM);
                    command.Parameters.AddWithValue("@now", DateTime.Now);
                    command.ExecuteNonQuery();
                }
            }
            catch { }
        }

        private string LookupChildUserId(SqlConnection connection, SqlTransaction transaction)
        {
            try
            {
                using (var command = new SqlCommand(
                    @"SELECT u.userId FROM dbo.Student s 
                    INNER JOIN dbo.[User] u ON s.userId=u.userId 
                    WHERE s.studentId=@sid", connection, transaction))
                {
                    command.Parameters.AddWithValue("@sid", _selectedChildId);
                    var result = command.ExecuteScalar();

                    if (result != null && result != DBNull.Value)
                    {
                        return result.ToString();
                    }
                }
            }
            catch { }
            return null;
        }

        private void ShowFeedbackMessage(string messageText, bool isSuccess)
        {
            pnlMessage.Visible = true;
            divMessage.InnerHtml = messageText;
            iMsgIcon.Attributes["class"] = isSuccess
                ? "bi bi-check-circle-fill"
                : "bi bi-exclamation-circle-fill";
        }

        protected void BtnCloseMsg_Click(object sender, EventArgs e)
        {
            pnlMessage.Visible = false;
            BuildLearningHeatmap();
        }

        private void LoadUnreadNotificationBadge()
        {
            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(
                    "SELECT COUNT(*) FROM dbo.Notification WHERE toUserId=@uid AND isRead=0",
                    connection))
                {
                    command.Parameters.AddWithValue("@uid", Session["userId"].ToString());
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
