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
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected string CurrentLanguage = "EN";

        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        private string _parentId = "";
        private string _userId = "";
        private string _childId = "";
        private string _childName = "";
        private string _spId = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!CheckAuth())
            {
                return;
            }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            LoadLang();
            LoadUnreadBadge();
            _userId = Session["userId"].ToString();
            LoadParentId();

            if (!IsPostBack)
            {
                SetLabels();
                LoadLinkedChildrenDropdown();

                if (!string.IsNullOrEmpty(_childId))
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
                SetLabels();
                // On postback, dropdown items persist via ViewState
                _childId = ddlSidebarChild.SelectedValue;
                _childName = ddlSidebarChild.SelectedItem != null
                    ? ddlSidebarChild.SelectedItem.Text
                    : "";
                LoadSpId();

                if (!string.IsNullOrEmpty(_childId))
                {
                    pnlContent.Visible = true;
                    pnlNoChild.Visible = false;
                    BuildLearningHeatmap();
                }
            }
        }

        private bool CheckAuth()
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

        private void LoadLang()
        {
            string cachedLanguage = Session["preferredLanguage"] as string;
            if (!string.IsNullOrEmpty(cachedLanguage))
            {
                CurrentLanguage = cachedLanguage;
                return;
            }

            try
            {
                using (var connection = new SqlConnection(ConnStr))
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

        private void LoadParentId()
        {
            try
            {
                using (var connection = new SqlConnection(ConnStr))
                using (var command = new SqlCommand(
                    "SELECT parentId, name FROM dbo.[Parent] WHERE userId=@uid", connection))
                {
                    command.Parameters.AddWithValue("@uid", _userId);
                    connection.Open();

                    using (var reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            _parentId = reader["parentId"].ToString();
                        }
                    }
                }
            }
            catch { }
        }

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

                using (var connection = new SqlConnection(ConnStr))
                using (var command = new SqlCommand(childListQuery, connection))
                {
                    command.Parameters.AddWithValue("@parentId", _parentId);
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

                _childId = ddlSidebarChild.SelectedValue;
                _childName = ddlSidebarChild.SelectedItem.Text;
                LoadSpId();
            }
        }

        private void LoadSpId()
        {
            try
            {
                using (var connection = new SqlConnection(ConnStr))
                using (var command = new SqlCommand(
                    "SELECT studentParentId FROM dbo.StudentParent WHERE parentId=@pid AND studentId=@sid",
                    connection))
                {
                    command.Parameters.AddWithValue("@pid", _parentId);
                    command.Parameters.AddWithValue("@sid", _childId);
                    connection.Open();
                    object result = command.ExecuteScalar();

                    if (result != null)
                    {
                        _spId = result.ToString();
                    }
                }
            }
            catch { }
        }

        protected void SidebarChildChanged(object sender, EventArgs e)
        {
            Session["selectedChildId"] = ddlSidebarChild.SelectedValue;
            _childId = ddlSidebarChild.SelectedValue;
            _childName = ddlSidebarChild.SelectedItem.Text;
            LoadSpId();
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

        private void SetLabels()
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

        private void RefreshAllPageData()
        {
            if (string.IsNullOrEmpty(_childId))
            {
                _childId = ddlSidebarChild.SelectedValue;
                _childName = ddlSidebarChild.SelectedItem != null
                    ? ddlSidebarChild.SelectedItem.Text : "";
                LoadSpId();
            }

            // Fetch fresh nickname from database
            try
            {
                using (var connection = new SqlConnection(ConnStr))
                using (var command = new SqlCommand(
                    "SELECT ISNULL(nickname, name) FROM dbo.Student WHERE studentId=@sid", connection))
                {
                    command.Parameters.AddWithValue("@sid", _childId);
                    connection.Open();
                    object result = command.ExecuteScalar();

                    if (result != null && result != DBNull.Value)
                    {
                        _childName = result.ToString();
                    }
                }
            }
            catch { }

            // Hero section
            litHeroTitle.Text = string.Format(
                T("{0}'s Learning Progress", "Kemajuan Pembelajaran {0}"), _childName);
            litHeroSub.Text = T(
                "How is your child doing this month?",
                "Bagaimana perkembangan anak anda bulan ini?");
            litTaskModalSub.Text = string.Format(
                T("Help {0} continue learning today.", "Bantu {0} teruskan pembelajaran hari ini."),
                _childName);

            BuildLearningHeatmap();
            BuildCoachingSection();
            BuildSciencePowerMap();
        }

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
                using (var connection = new SqlConnection(ConnStr))
                {
                    connection.Open();

                    using (var command = new SqlCommand(
                        @"SELECT COUNT(*) FROM dbo.LessonProgress 
                        WHERE studentId=@sid AND isCompleted=1 
                        AND completedDate>=@start AND completedDate<=@end", connection))
                    {
                        command.Parameters.AddWithValue("@sid", _childId);
                        command.Parameters.AddWithValue("@start", monthStart);
                        command.Parameters.AddWithValue("@end", monthEnd);
                        lessonsCompletedCount = (int)command.ExecuteScalar();
                    }

                    using (var command = new SqlCommand(
                        @"SELECT COUNT(*) FROM dbo.QuizAttempt 
                        WHERE studentId=@sid AND attemptDate>=@start AND attemptDate<=@end",
                        connection))
                    {
                        command.Parameters.AddWithValue("@sid", _childId);
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
                using (var connection = new SqlConnection(ConnStr))
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

                using (var connection = new SqlConnection(ConnStr))
                using (var command = new SqlCommand(aggregateQuery, connection))
                {
                    command.Parameters.AddWithValue("@sid", _childId);
                    command.Parameters.AddWithValue("@spid", _spId);
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
                using (var connection = new SqlConnection(ConnStr))
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
                command.Parameters.AddWithValue("@sid", _childId);
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
                command.Parameters.AddWithValue("@sid", _childId);
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
                command.Parameters.AddWithValue("@spid", _spId);
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
                command.Parameters.AddWithValue("@sid", _childId);
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
                command.Parameters.AddWithValue("@sid", _childId);
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

        //  COACHING SECTION ("Be a Coach!")
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
                using (var connection = new SqlConnection(ConnStr))
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
                command.Parameters.AddWithValue("@sid", _childId);
                command.Parameters.AddWithValue("@spid", _spId);
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
                command.Parameters.AddWithValue("@sid", _childId);
                command.Parameters.AddWithValue("@spid", _spId);
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
                command.Parameters.AddWithValue("@sid", _childId);
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
                command.Parameters.AddWithValue("@spid", _spId);
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
                    _childName);
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
                    _childName);
                pnlCoachTip.Visible = true;
                litCoachTip.Text = personalizedTip;
                pnlAddStudyPlanBtn.Visible = true;
            }
            else if (engagementLevel == "amazing")
            {
                litCoachMessage.Text = string.Format(
                    T("Amazing! {0} has completed {1} learning activities this month. Keep the streak going!",
                      "Luar biasa! {0} telah menyelesaikan {1} aktiviti pembelajaran bulan ini. Teruskan momentum!"),
                    _childName, monthlyActivityCount);
                pnlCoachTip.Visible = false;
                pnlAddStudyPlanBtn.Visible = false;
            }
            else
            {
                litCoachMessage.Text = string.Format(
                    T("Good progress! {0} is building a steady learning habit with {1} activities this month.",
                      "Kemajuan baik! {0} sedang membina tabiat pembelajaran yang stabil dengan {1} aktiviti bulan ini."),
                    _childName, monthlyActivityCount);
                pnlCoachTip.Visible = false;
                pnlAddStudyPlanBtn.Visible = false;
            }
        }
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
                    command.Parameters.AddWithValue("@sid", _childId);
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
        private string BuildPersonalizedRecommendation()
        {
            string recommendation = "";

            try
            {
                using (var connection = new SqlConnection(ConnStr))
                {
                    connection.Open();

                    // Priority 1: AI-detected weak topics from learning analysis
                    using (var command = new SqlCommand(
                        @"SELECT TOP 1 weakTopics FROM dbo.AILearningAnalysis
                        WHERE studentId=@sid AND isLatest=1 AND weakTopics IS NOT NULL AND weakTopics <> ''",
                        connection))
                    {
                        command.Parameters.AddWithValue("@sid", _childId);
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
                                _childName, topWeakTopic);
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
                        command.Parameters.AddWithValue("@sid", _childId);

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
                                    _childName, unitName);
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
                    _childName);
            }

            return recommendation;
        }

        private void BuildSciencePowerMap()
        {
            pnlPowerMap.Visible = false;

            if (string.IsNullOrEmpty(_childId))
                return;

            int brainPower = 0, missionStreak = 0, explorerEnergy = 0;
            int challengeCourage = 0, bounceBack = 0, teamSpirit = 0;

            try
            {
                using (var connection = new SqlConnection(ConnStr))
                {
                    connection.Open();
                    brainPower = CalculateBrainPower(connection);
                    missionStreak = CalculateMissionStreak(connection);
                    explorerEnergy = CalculateExplorerEnergy(connection);
                    challengeCourage = CalculateChallengeCourage(connection);
                    bounceBack = CalculateBounceBackPower(connection);
                    teamSpirit = CalculateTeamSpirit(connection);
                }
            }
            catch { }

            // Show the chart even with low scores — only hide if there's literally no child selected
            if (string.IsNullOrEmpty(_childId))
                return;

            // Render the section
            pnlPowerMap.Visible = true;
            litPowerMapTitle.Text = string.Format(
                T("{0}'s Science Power Map", "Peta Kuasa Sains {0}"), _childName);
            litPowerMapFooter.Text = T(
                "Scores are calculated from real learning activity — not invented by AI.",
                "Skor dikira daripada aktiviti pembelajaran sebenar — bukan rekaan AI.");

            // Generate the SVG radar (no numeric scores shown)
            int[] scores = { brainPower, missionStreak, explorerEnergy,
                challengeCourage, bounceBack, teamSpirit };
            string[] labels = {
                T("Brain Power", "Kuasa Minda"),
                T("Mission Streak", "Misi Berterusan"),
                T("Explorer Energy", "Tenaga Peneroka"),
                T("Challenge Courage", "Keberanian Cabaran"),
                T("Bounce-Back", "Kuasa Bangkit"),
                T("Team Spirit", "Semangat Pasukan")
            };
            litPowerMapSvg.Text = RenderRadarSvg(scores, labels);

            // Determine explorer identity
            DetermineExplorerIdentity(scores, labels);

            // Output skill data as JS for the interactive popup
            OutputSkillDataScript(scores, labels);
        }

        private void OutputSkillDataScript(int[] scores, string[] labels)
        {
            string[] meanings = {
                T("How well the child understands science ideas, remembers concepts and applies what they learned.",
                  "Sejauh mana anak memahami idea sains, mengingat konsep dan mengaplikasikan apa yang dipelajari."),
                T("How regularly the child logs in and completes learning activities throughout the week.",
                  "Seberapa kerap anak log masuk dan menyelesaikan aktiviti pembelajaran sepanjang minggu."),
                T("How much of the available learning content the child has explored and completed.",
                  "Berapa banyak kandungan pembelajaran yang tersedia telah diterokai dan diselesaikan oleh anak."),
                T("The child's willingness to attempt quizzes and try harder content, even without being certain.",
                  "Kesediaan anak mencuba kuiz dan kandungan lebih sukar, walaupun tanpa kepastian."),
                T("Whether the child improves after getting something wrong — retrying and revisiting weak areas.",
                  "Sama ada anak bertambah baik selepas melakukan kesilapan — mencuba semula dan mengulangkaji."),
                T("How actively the child participates in discussions, asks questions, or communicates with teachers.",
                  "Seberapa aktif anak menyertai perbincangan, bertanya soalan, atau berkomunikasi dengan guru.")
            };

            string[] helpTips = {
                string.Format(T("Ask {0} to explain one lesson idea in her own words after completing a topic.",
                    "Minta {0} menerangkan satu idea pelajaran dengan ayat sendiri selepas selesai satu topik."), _childName),
                string.Format(T("Set a simple routine: 15 minutes of ScienceBuddy on three evenings this week.",
                    "Tetapkan rutin mudah: 15 minit ScienceBuddy pada tiga malam minggu ini."), _childName),
                string.Format(T("Encourage {0} to open a new lesson or try a virtual lab they haven't seen yet.",
                    "Galakkan {0} membuka pelajaran baru atau mencuba makmal maya yang belum pernah dicuba."), _childName),
                T("Praise the effort of trying, not just the result. Say \"I'm proud you gave it a go!\"",
                    "Puji usaha mencuba, bukan hanya hasilnya. Katakan \"Saya bangga kamu mencuba!\""),
                string.Format(T("After a low result, say \"Let's look at which questions were tricky — we can figure them out together.\"",
                    "Selepas keputusan rendah, katakan \"Jom tengok soalan mana yang susah — kita boleh selesaikan bersama.\""), _childName),
                string.Format(T("Ask {0} to share one thing they learned this week in the forum or with their teacher.",
                    "Minta {0} berkongsi satu perkara yang dipelajari minggu ini di forum atau dengan guru."), _childName)
            };

            var sb = new System.Text.StringBuilder();
            sb.Append("<script>window._skillData=[");

            for (int i = 0; i < 6; i++)
            {
                string status = GetFriendlyStatus(scores[i]);
                string progress = GetProgressSentence(scores[i]);

                if (i > 0) sb.Append(",");
                sb.Append("{");
                sb.AppendFormat("name:{0},", JavaScriptStringEncode(labels[i]));
                sb.AppendFormat("status:{0},", JavaScriptStringEncode(status));
                sb.AppendFormat("meaning:{0},", JavaScriptStringEncode(meanings[i]));
                sb.AppendFormat("progress:{0},", JavaScriptStringEncode(progress));
                sb.AppendFormat("help:{0}", JavaScriptStringEncode(helpTips[i]));
                sb.Append("}");
            }

            sb.Append("];</script>");
            litSkillDataScript.Text = sb.ToString();
        }

        private string GetFriendlyStatus(int score)
        {
            if (score >= 71) return T("Strong", "Mantap");
            if (score >= 46) return T("Steady", "Stabil");
            if (score >= 21) return T("Developing", "Berkembang");
            return T("Growing", "Bermula");
        }

        private string GetProgressSentence(int score)
        {
            if (score >= 71)
                return string.Format(T("{0} is showing real confidence in this area!", "{0} menunjukkan keyakinan sebenar dalam bidang ini!"), _childName);
            if (score >= 46)
                return string.Format(T("{0} is practising this skill regularly and making progress.", "{0} sedang mengamalkan kemahiran ini secara tetap dan menunjukkan kemajuan."), _childName);
            if (score >= 21)
                return string.Format(T("{0} is beginning to show this skill and building confidence.", "{0} mula menunjukkan kemahiran ini dan membina keyakinan."), _childName);
            return string.Format(T("{0} is just getting started with this skill.", "{0} baru sahaja bermula dengan kemahiran ini."), _childName);
        }

        private string JavaScriptStringEncode(string value)
        {
            if (string.IsNullOrEmpty(value)) return "\"\"";
            return "\"" + value.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "") + "\"";
        }

        // ── Individual power calculations ────────────────────────────

        private int CalculateBrainPower(SqlConnection conn)
        {
            // Average quiz percentage (0-100)
            using (var cmd = new SqlCommand(
                "SELECT AVG(percentage) FROM dbo.QuizResult WHERE studentId = @sid", conn))
            {
                cmd.Parameters.AddWithValue("@sid", _childId);
                object result = cmd.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                    return Math.Min(100, (int)Math.Round(Convert.ToDecimal(result)));
            }
            return 0;
        }

        private int CalculateMissionStreak(SqlConnection conn)
        {
            // Active days in last 20 days as percentage
            DateTime since = DateTime.Today.AddDays(-20);
            using (var cmd = new SqlCommand(
                @"SELECT COUNT(DISTINCT CAST(d AS DATE)) FROM (
                    SELECT completedDate AS d FROM dbo.LessonProgress 
                    WHERE studentId=@sid AND isCompleted=1 AND completedDate>=@since
                    UNION ALL SELECT completedDate FROM dbo.LabProgress 
                    WHERE studentId=@sid AND isCompleted=1 AND completedDate>=@since
                ) x", conn))
            {
                cmd.Parameters.AddWithValue("@sid", _childId);
                cmd.Parameters.AddWithValue("@since", since);
                int activeDays = (int)cmd.ExecuteScalar();
                return Math.Min(100, (int)Math.Round((double)activeDays / 20 * 100));
            }
        }

        private int CalculateExplorerEnergy(SqlConnection conn)
        {
            // Lessons completed / total available lessons (enrolled level)
            int completed = 0, total = 0;
            using (var cmd = new SqlCommand(
                "SELECT COUNT(*) FROM dbo.LessonProgress WHERE studentId=@sid AND isCompleted=1", conn))
            {
                cmd.Parameters.AddWithValue("@sid", _childId);
                completed = (int)cmd.ExecuteScalar();
            }
            using (var cmd = new SqlCommand(
                @"SELECT COUNT(DISTINCT l.lessonId) FROM dbo.Enrollment e
                INNER JOIN dbo.Unit u ON u.levelId=e.levelId
                INNER JOIN dbo.Subtopic st ON st.unitId=u.unitId
                INNER JOIN dbo.Lesson l ON l.subtopicId=st.subtopicId
                WHERE e.studentId=@sid", conn))
            {
                cmd.Parameters.AddWithValue("@sid", _childId);
                total = (int)cmd.ExecuteScalar();
            }
            if (total == 0) return 0;
            return Math.Min(100, (int)Math.Round((double)completed / total * 100));
        }

        private int CalculateChallengeCourage(SqlConnection conn)
        {
            // Quiz attempts / available quizzes (willingness to try)
            int attempted = 0, available = 0;
            using (var cmd = new SqlCommand(
                "SELECT COUNT(DISTINCT quizId) FROM dbo.QuizResult WHERE studentId=@sid", conn))
            {
                cmd.Parameters.AddWithValue("@sid", _childId);
                attempted = (int)cmd.ExecuteScalar();
            }
            using (var cmd = new SqlCommand(
                @"SELECT COUNT(*) FROM dbo.Quiz q
                INNER JOIN dbo.Unit u ON q.unitId=u.unitId
                INNER JOIN dbo.Enrollment e ON e.levelId=u.levelId AND e.studentId=@sid", conn))
            {
                cmd.Parameters.AddWithValue("@sid", _childId);
                available = (int)cmd.ExecuteScalar();
            }
            if (available == 0) return 0;
            return Math.Min(100, (int)Math.Round((double)attempted / available * 100));
        }

        private int CalculateBounceBackPower(SqlConnection conn)
        {
            // Score improvement between first and latest quiz attempts
            decimal firstAvg = 0, latestAvg = 0;
            int attemptCount = 0;
            using (var cmd = new SqlCommand(
                "SELECT COUNT(*) FROM dbo.QuizResult WHERE studentId=@sid", conn))
            {
                cmd.Parameters.AddWithValue("@sid", _childId);
                attemptCount = (int)cmd.ExecuteScalar();
            }
            if (attemptCount < 2) return 0;

            // Average of first 3 attempts
            using (var cmd = new SqlCommand(
                @"SELECT AVG(percentage) FROM (
                    SELECT TOP 3 percentage FROM dbo.QuizResult 
                    WHERE studentId=@sid ORDER BY attemptedDate ASC
                ) x", conn))
            {
                cmd.Parameters.AddWithValue("@sid", _childId);
                object r = cmd.ExecuteScalar();
                if (r != null && r != DBNull.Value) firstAvg = Convert.ToDecimal(r);
            }

            // Average of latest 3 attempts
            using (var cmd = new SqlCommand(
                @"SELECT AVG(percentage) FROM (
                    SELECT TOP 3 percentage FROM dbo.QuizResult 
                    WHERE studentId=@sid ORDER BY attemptedDate DESC
                ) x", conn))
            {
                cmd.Parameters.AddWithValue("@sid", _childId);
                object r = cmd.ExecuteScalar();
                if (r != null && r != DBNull.Value) latestAvg = Convert.ToDecimal(r);
            }

            // Improvement scaled to 0-100 (30+ point improvement = 100)
            decimal improvement = latestAvg - firstAvg;
            if (improvement <= 0) return 20; // baseline if no decline
            return Math.Min(100, (int)Math.Round((double)improvement / 30 * 100));
        }

        private int CalculateTeamSpirit(SqlConnection conn)
        {
            // Forum posts + chat messages in last 30 days
            int forumPosts = 0, chatMessages = 0;
            string childUserId = "";

            // Get child's userId for forum/chat lookup
            using (var cmd = new SqlCommand(
                "SELECT userId FROM dbo.Student WHERE studentId=@sid", conn))
            {
                cmd.Parameters.AddWithValue("@sid", _childId);
                object r = cmd.ExecuteScalar();
                if (r != null && r != DBNull.Value) childUserId = r.ToString();
            }

            if (string.IsNullOrEmpty(childUserId)) return 0;

            DateTime since = DateTime.Today.AddDays(-30);

            using (var cmd = new SqlCommand(
                "SELECT COUNT(*) FROM dbo.ForumReply WHERE createdByUserId=@uid AND createdAt>=@since", conn))
            {
                cmd.Parameters.AddWithValue("@uid", childUserId);
                cmd.Parameters.AddWithValue("@since", since);
                forumPosts = (int)cmd.ExecuteScalar();
            }

            using (var cmd = new SqlCommand(
                "SELECT COUNT(*) FROM dbo.privateMessage WHERE senderUserId=@uid AND sentAt>=@since", conn))
            {
                cmd.Parameters.AddWithValue("@uid", childUserId);
                cmd.Parameters.AddWithValue("@since", since);
                chatMessages = (int)cmd.ExecuteScalar();
            }

            // Scale: 10+ interactions = 100
            int totalInteractions = forumPosts + chatMessages;
            return Math.Min(100, (int)Math.Round((double)totalInteractions / 10 * 100));
        }

        // ── SVG Radar Rendering ──────────────────────────────────────

        private string RenderRadarSvg(int[] scores, string[] labels)
        {
            // Hexagonal radar — center (200,200), radius 90, viewBox 400x400
            double cx = 200, cy = 200, maxR = 90;
            int axes = 6;
            double angleStep = 2 * Math.PI / axes;

            // Each power has its own vibrant color
            string[] fillColors = {
                "rgba(99,102,241,0.55)",   // Brain Power — indigo
                "rgba(20,184,166,0.55)",    // Mission Streak — teal
                "rgba(245,158,11,0.55)",    // Explorer Energy — amber
                "rgba(239,68,68,0.55)",     // Challenge Courage — red
                "rgba(168,85,247,0.55)",    // Bounce-Back — violet
                "rgba(16,185,129,0.55)"     // Team Spirit — emerald
            };
            string[] strokeColors = {
                "#6366F1", "#14B8A6", "#F59E0B",
                "#EF4444", "#A855F7", "#10B981"
            };
            string[] dotColors = {
                "#6366F1", "#14B8A6", "#F59E0B",
                "#EF4444", "#A855F7", "#10B981"
            };

            var svg = new System.Text.StringBuilder();
            svg.Append("<svg viewBox='0 0 400 400' class='pt-power-map-svg'>");

            // Background grid rings
            for (int ring = 1; ring <= 4; ring++)
            {
                double ringR = maxR * ring / 4.0;
                svg.Append("<polygon points='");
                for (int i = 0; i < axes; i++)
                {
                    double angle = -Math.PI / 2 + i * angleStep;
                    double px = cx + ringR * Math.Cos(angle);
                    double py = cy + ringR * Math.Sin(angle);
                    if (i > 0) svg.Append(" ");
                    svg.AppendFormat("{0:F1},{1:F1}", px, py);
                }
                svg.Append("' fill='none' stroke='#CBD5E1' stroke-width='0.7' stroke-dasharray='4,4'/>");
            }

            // Axis lines
            for (int i = 0; i < axes; i++)
            {
                double angle = -Math.PI / 2 + i * angleStep;
                double px = cx + maxR * Math.Cos(angle);
                double py = cy + maxR * Math.Sin(angle);
                svg.AppendFormat("<line x1='{0}' y1='{1}' x2='{2:F1}' y2='{3:F1}' stroke='#E2E8F0' stroke-width='0.7'/>",
                    cx, cy, px, py);
            }

            // Draw one colored triangle per axis — each power fills from center to its two neighbours
            // This creates overlapping color zones like the reference image
            for (int i = 0; i < axes; i++)
            {
                int next = (i + 1) % axes;
                double scoreR = maxR * scores[i] / 100.0;
                double nextScoreR = maxR * scores[next] / 100.0;

                double angle1 = -Math.PI / 2 + i * angleStep;
                double angle2 = -Math.PI / 2 + next * angleStep;

                double px1 = cx + scoreR * Math.Cos(angle1);
                double py1 = cy + scoreR * Math.Sin(angle1);
                double px2 = cx + nextScoreR * Math.Cos(angle2);
                double py2 = cy + nextScoreR * Math.Sin(angle2);

                svg.AppendFormat(
                    "<polygon points='{0:F1},{1:F1} {2:F1},{3:F1} {4:F1},{5:F1}' fill='{6}' stroke='{7}' stroke-width='1.5' stroke-linejoin='round'/>",
                    cx, cy, px1, py1, px2, py2,
                    fillColors[i], strokeColors[i]);
            }

            // Score value dots — clickable
            for (int i = 0; i < axes; i++)
            {
                double angle = -Math.PI / 2 + i * angleStep;
                double scoreR = maxR * scores[i] / 100.0;
                double px = cx + scoreR * Math.Cos(angle);
                double py = cy + scoreR * Math.Sin(angle);
                svg.AppendFormat(
                    "<circle cx='{0:F1}' cy='{1:F1}' r='6' fill='{2}' stroke='#fff' stroke-width='2.5' style='cursor:pointer;' onclick='openSkillPanel({3})'/>",
                    px, py, dotColors[i], i);
            }

            // Labels — clickable buttons, no numeric score shown
            for (int i = 0; i < axes; i++)
            {
                double angle = -Math.PI / 2 + i * angleStep;
                double labelR = maxR + 40;
                double px = cx + labelR * Math.Cos(angle);
                double py = cy + labelR * Math.Sin(angle);
                string anchor = px < cx - 8 ? "end" : px > cx + 8 ? "start" : "middle";

                svg.AppendFormat(
                    "<text x='{0:F1}' y='{1:F1}' text-anchor='{2}' font-size='12' font-weight='700' fill='{3}' font-family='inherit' class='pt-power-skill-btn' style='cursor:pointer;' onclick='openSkillPanel({4})'>{5}</text>",
                    px, py, anchor, strokeColors[i], i, labels[i]);
            }

            svg.Append("</svg>");
            return svg.ToString();
        }

        // ── Explorer Identity ────────────────────────────────────────

        private void DetermineExplorerIdentity(int[] scores, string[] labels)
        {
            // Find strongest and weakest power
            int maxIdx = 0, minIdx = 0;
            for (int i = 1; i < scores.Length; i++)
            {
                if (scores[i] > scores[maxIdx]) maxIdx = i;
                if (scores[i] < scores[minIdx]) minIdx = i;
            }

            string superpowerLabel = labels[maxIdx];
            string powerUpLabel = labels[minIdx];

            // Determine explorer type based on dominant powers
            string explorerType = DetermineExplorerType(scores, maxIdx);

            litExplorerType.Text = string.Format(
                T("Explorer Type: {0}", "Jenis Peneroka: {0}"), explorerType);
            litSuperpower.Text = string.Format(
                T("Superpower: {0}", "Kuasa Istimewa: {0}"), superpowerLabel);
            litPowerUp.Text = string.Format(
                T("Next Power-Up: {0}", "Kuasa Seterusnya: {0}"), powerUpLabel);

            // Build advice from analysisJson ParentGuidance or template
            string advice = BuildPowerMapAdvice(explorerType, superpowerLabel, powerUpLabel);
            if (!string.IsNullOrEmpty(advice))
            {
                litPowerMapAdvice.Text = advice;
                pnlPowerMapAdvice.Visible = true;
            }
        }

        private string DetermineExplorerType(int[] scores, int strongestIndex)
        {
            // Check if scores are balanced (all within 20 points of each other)
            int maxScore = scores[0], minScore = scores[0];
            for (int i = 1; i < scores.Length; i++)
            {
                if (scores[i] > maxScore) maxScore = scores[i];
                if (scores[i] < minScore) minScore = scores[i];
            }
            if (maxScore - minScore <= 20 && maxScore >= 40)
                return T("All-Round Science Star", "Bintang Sains Serba Boleh");

            // Assign based on strongest power
            switch (strongestIndex)
            {
                case 0: return T("Brainy Inventor", "Pencipta Bijak");
                case 1: return T("Mission Master", "Penguasa Misi");
                case 2: return T("Curious Trailblazer", "Perintis Ingin Tahu");
                case 3: return T("Brave Challenger", "Pencabar Berani");
                case 4: return T("Comeback Champion", "Juara Bangkit Semula");
                case 5: return T("Teamwork Scientist", "Saintis Kerjasama");
                default: return T("Science Explorer", "Peneroka Sains");
            }
        }

        private string BuildPowerMapAdvice(string explorerType, string superpower, string powerUp)
        {
            // Try to read ParentGuidance from analysisJson first
            try
            {
                using (var connection = new SqlConnection(ConnStr))
                using (var command = new SqlCommand(
                    "SELECT TOP 1 analysisJson FROM dbo.AILearningAnalysis WHERE studentId=@sid AND isLatest=1",
                    connection))
                {
                    command.Parameters.AddWithValue("@sid", _childId);
                    connection.Open();
                    object result = command.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        string json = result.ToString();
                        if (!string.IsNullOrEmpty(json))
                        {
                            var parsed = Newtonsoft.Json.Linq.JObject.Parse(json);
                            string parentGuidance = parsed["ParentGuidance"]?.ToString() ?? "";
                            if (!string.IsNullOrEmpty(parentGuidance))
                                return Server.HtmlEncode(parentGuidance);
                        }
                    }
                }
            }
            catch { }

            // Fallback: template-based advice
            return Server.HtmlEncode(string.Format(
                T("{0} is a {1}! Their strongest power is {2}. To grow their {3}, try setting short daily learning missions this week.",
                  "{0} ialah {1}! Kuasa terkuat mereka ialah {2}. Untuk mengembangkan {3}, cuba tetapkan misi pembelajaran harian pendek minggu ini."),
                _childName, explorerType, superpower, powerUp));
        }

        protected void BtnAddTask_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtTaskName.Text))
            {
                ShowMsg(
                    T("Please enter a task name.", "Sila masukkan nama tugasan."), false);
                return;
            }

            if (string.IsNullOrEmpty(_childId))
            {
                _childId = ddlSidebarChild.SelectedValue;
                _childName = ddlSidebarChild.SelectedItem != null
                    ? ddlSidebarChild.SelectedItem.Text : "";
                LoadSpId();
            }

            if (string.IsNullOrEmpty(_spId))
            {
                ShowMsg(
                    T("Unable to find child link.", "Tidak dapat mencari pautan anak."), false);
                return;
            }

            try
            {
                using (var connection = new SqlConnection(ConnStr))
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
                            ShowMsg(
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
                ShowMsg(
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
                command.Parameters.AddWithValue("@spid", _spId);
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
                command.Parameters.AddWithValue("@spid", _spId);
                command.Parameters.AddWithValue("@uid", _userId);
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
                    command.Parameters.AddWithValue("@sid", _childId);
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

        private void ShowMsg(string messageText, bool isSuccess)
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

        private void LoadUnreadBadge()
        {
            try
            {
                using (var connection = new SqlConnection(ConnStr))
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
