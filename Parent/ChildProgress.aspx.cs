using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
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
        protected string T(string en, string bm) => CurrentLanguage == "BM" ? bm : en;

        private string _parentId = "";
        private string _parentUserId = "";
        private string _selectedChildId = "";
        private string _selectedChildName = "";
        private string _studentParentId = "";

        // ══════════════════════════════════════════════════════════════
        //  PAGE LOAD
        // ══════════════════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!EnsureParentAuthorized()) return;
            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            LoadCurrentLanguage(); LoadUnreadBadge();
            _parentUserId = Session["userId"].ToString();
            LoadParentProfile();

            if (!IsPostBack)
            {
                SetLabels();
                LoadLinkedChildren();
                if (!string.IsNullOrEmpty(_selectedChildId))
                {
                    pnlContent.Visible = true;
                    pnlNoChild.Visible = false;
                    PopulateMonthDropdown();
                    LoadPageData();
                }
                else
                {
                    ShowNoChildState();
                }
            }
            else
            {
                SetLabels();
                // On postback, dropdown items persist via ViewState - just read selected value
                _selectedChildId = ddlSidebarChild.SelectedValue;
                _selectedChildName = ddlSidebarChild.SelectedItem != null ? ddlSidebarChild.SelectedItem.Text : "";
                LoadStudentParentId();
                if (!string.IsNullOrEmpty(_selectedChildId))
                {
                    pnlContent.Visible = true;
                    pnlNoChild.Visible = false;
                    BuildHeatmap();
                }
            }
        }

        // ══════════════════════════════════════════════════════════════
        //  AUTHORIZATION & LANGUAGE
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

        private void LoadCurrentLanguage()
        {
            string lang = Session["preferredLanguage"] as string;
            if (!string.IsNullOrEmpty(lang)) { CurrentLanguage = lang; return; }
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT preferredLanguage FROM dbo.[User] WHERE userId=@uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", Session["userId"].ToString());
                    conn.Open();
                    object r = cmd.ExecuteScalar();
                    if (r != null && r != DBNull.Value) { lang = r.ToString(); Session["preferredLanguage"] = lang; CurrentLanguage = lang; }
                }
            }
            catch { }
        }

        private void LoadParentProfile()
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT parentId, name FROM dbo.[Parent] WHERE userId=@uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", _parentUserId);
                    conn.Open();
                    using (var rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read()) { _parentId = rdr["parentId"].ToString(); }
                    }
                }
            }
            catch { }
        }

        // ══════════════════════════════════════════════════════════════
        //  LINKED CHILDREN
        // ══════════════════════════════════════════════════════════════
        private void LoadLinkedChildren()
        {
            ddlSidebarChild.Items.Clear();
            try
            {
                const string sql = @"SELECT sp.studentParentId, s.studentId, ISNULL(s.nickname, s.name) AS displayName
                    FROM dbo.StudentParent sp INNER JOIN dbo.Student s ON sp.studentId = s.studentId
                    WHERE sp.parentId = @pid ORDER BY s.name";
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@pid", _parentId);
                    conn.Open();
                    using (var rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            ddlSidebarChild.Items.Add(new ListItem(rdr["displayName"].ToString(), rdr["studentId"].ToString()));
                        }
                    }
                }
            }
            catch { }

            if (ddlSidebarChild.Items.Count > 0)
            {
                string saved = Session["selectedChildId"] as string;
                if (!string.IsNullOrEmpty(saved) && ddlSidebarChild.Items.FindByValue(saved) != null)
                    ddlSidebarChild.SelectedValue = saved;
                else
                    Session["selectedChildId"] = ddlSidebarChild.Items[0].Value;

                _selectedChildId = ddlSidebarChild.SelectedValue;
                _selectedChildName = ddlSidebarChild.SelectedItem.Text;
                LoadStudentParentId();
            }
        }

        private void LoadStudentParentId()
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT studentParentId FROM dbo.StudentParent WHERE parentId=@pid AND studentId=@sid", conn))
                {
                    cmd.Parameters.AddWithValue("@pid", _parentId);
                    cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                    conn.Open();
                    object r = cmd.ExecuteScalar();
                    if (r != null) _studentParentId = r.ToString();
                }
            }
            catch { }
        }

        protected void SidebarChildChanged(object sender, EventArgs e)
        {
            Session["selectedChildId"] = ddlSidebarChild.SelectedValue;
            _selectedChildId = ddlSidebarChild.SelectedValue;
            _selectedChildName = ddlSidebarChild.SelectedItem.Text;
            LoadStudentParentId();
            pnlContent.Visible = true;
            pnlNoChild.Visible = false;
            pnlDailyModal.Visible = false;
            PopulateMonthDropdown();
            LoadPageData();
        }

        private void ShowNoChildState()
        {
            pnlContent.Visible = false;
            pnlNoChild.Visible = true;
            litNoChildMsg.Text = T("No linked child found. Please link a child account first.",
                "Tiada anak dipautkan. Sila pautkan akaun anak terlebih dahulu.");
        }

        // ══════════════════════════════════════════════════════════════
        //  LABELS
        // ══════════════════════════════════════════════════════════════
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
            litDailyEmpty.Text = T("No learning activity recorded on this day.",
                "Tiada aktiviti pembelajaran direkodkan pada hari ini.");
        }

        // ══════════════════════════════════════════════════════════════
        //  MONTH DROPDOWN
        // ══════════════════════════════════════════════════════════════
        private void PopulateMonthDropdown()
        {
            ddlMonth.Items.Clear();
            DateTime now = DateTime.Now;
            for (int i = 0; i < 12; i++)
            {
                DateTime m = now.AddMonths(-i);
                string label = m.ToString("MMMM yyyy", CultureInfo.InvariantCulture);
                string val = m.ToString("yyyy-MM");
                ddlMonth.Items.Add(new ListItem(label, val));
            }
            ddlMonth.SelectedIndex = 0;
        }

        protected void DdlMonth_Changed(object sender, EventArgs e)
        {
            LoadPageData();
        }

        private DateTime GetSelectedMonth()
        {
            if (ddlMonth.SelectedValue != null && ddlMonth.SelectedValue.Contains("-"))
            {
                string[] parts = ddlMonth.SelectedValue.Split('-');
                return new DateTime(int.Parse(parts[0]), int.Parse(parts[1]), 1);
            }
            return new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
        }

        // ══════════════════════════════════════════════════════════════
        //  MAIN DATA LOAD
        // ══════════════════════════════════════════════════════════════
        private void LoadPageData()
        {
            if (string.IsNullOrEmpty(_selectedChildId))
            {
                _selectedChildId = ddlSidebarChild.SelectedValue;
                _selectedChildName = ddlSidebarChild.SelectedItem != null ? ddlSidebarChild.SelectedItem.Text : "";
                LoadStudentParentId();
            }

            // Always fetch nickname fresh from DB
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT ISNULL(nickname, name) FROM dbo.Student WHERE studentId=@sid", conn))
                {
                    cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                    conn.Open();
                    object r = cmd.ExecuteScalar();
                    if (r != null && r != DBNull.Value) _selectedChildName = r.ToString();
                }
            }
            catch { }

            // Hero
            litHeroTitle.Text = string.Format(T("{0}'s Learning Progress", "Kemajuan Pembelajaran {0}"), _selectedChildName);
            litHeroSub.Text = T("How is your child doing this month?", "Bagaimana perkembangan anak anda bulan ini?");
            litTaskModalSub.Text = string.Format(T("Help {0} continue learning today.", "Bantu {0} teruskan pembelajaran hari ini."), _selectedChildName);

            // Heatmap
            BuildHeatmap();

            // Coach
            BuildCoachSection();
        }

        // ══════════════════════════════════════════════════════════════
        //  HEATMAP
        // ══════════════════════════════════════════════════════════════
        private void BuildHeatmap()
        {
            DateTime monthStart = GetSelectedMonth();
            int daysInMonth = DateTime.DaysInMonth(monthStart.Year, monthStart.Month);
            DateTime today = DateTime.Today;
            bool isCurrentMonth = (monthStart.Year == today.Year && monthStart.Month == today.Month);

            // Get activity counts per day
            Dictionary<int, int> activityCounts = GetActivityCountsForMonth(monthStart);

            // Determine what weekday day 1 falls on (Monday=0 ... Sunday=6)
            int firstDayOfWeek = ((int)monthStart.DayOfWeek + 6) % 7; // Convert Sunday=0 to Monday-based

            StringBuilder sb = new StringBuilder();

            // Empty cells before day 1
            for (int i = 0; i < firstDayOfWeek; i++)
            {
                sb.Append("<span class=\"pt-heatmap-day pt-heatmap-day-empty\"></span>");
            }

            // Day cells
            for (int d = 1; d <= daysInMonth; d++)
            {
                DateTime cellDate = new DateTime(monthStart.Year, monthStart.Month, d);
                bool isFuture = cellDate > today;
                bool isToday = cellDate == today && isCurrentMonth;

                int count = activityCounts.ContainsKey(d) ? activityCounts[d] : 0;

                string cssClass = "pt-heatmap-day";
                if (isFuture)
                    cssClass += " pt-heatmap-day-disabled";
                else if (isToday)
                    cssClass += " pt-heatmap-day-today";

                if (!isFuture)
                {
                    if (count == 0) cssClass += " pt-heatmap-day-none";
                    else if (count == 1) cssClass += " pt-heatmap-day-low";
                    else if (count <= 3) cssClass += " pt-heatmap-day-medium";
                    else cssClass += " pt-heatmap-day-high";
                }

                string dateStr = cellDate.ToString("yyyy-MM-dd");
                string clickAttr = isFuture ? "" :
                    string.Format(" onclick=\"document.getElementById('{0}').value='{1}';document.getElementById('{2}').click();\"",
                        hidSelectedDate.ClientID, dateStr, btnDayClick.ClientID);

                sb.AppendFormat("<span class=\"{0}\" data-date=\"{1}\"{2}>{3}</span>",
                    cssClass, dateStr, clickAttr, d);
            }

            pnlHeatmapDays.Controls.Clear();
            pnlHeatmapDays.Controls.Add(new LiteralControl(sb.ToString()));
        }

        private Dictionary<int, int> GetActivityCountsForMonth(DateTime monthStart)
        {
            var counts = new Dictionary<int, int>();
            DateTime monthEnd = monthStart.AddMonths(1).AddDays(-1);

            try
            {
                string sql = @"
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

                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                    cmd.Parameters.AddWithValue("@spid", _studentParentId);
                    cmd.Parameters.AddWithValue("@start", monthStart);
                    cmd.Parameters.AddWithValue("@end", monthEnd);
                    conn.Open();
                    using (var rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            if (rdr["actDate"] != DBNull.Value)
                            {
                                DateTime dt = Convert.ToDateTime(rdr["actDate"]);
                                counts[dt.Day] = Convert.ToInt32(rdr["total"]);
                            }
                        }
                    }
                }
            }
            catch { }
            return counts;
        }

        // ══════════════════════════════════════════════════════════════
        //  DAILY ACTIVITY POPUP
        // ══════════════════════════════════════════════════════════════
        protected void BtnDayClick_Click(object sender, EventArgs e)
        {
            string dateStr = hidSelectedDate.Value;
            if (string.IsNullOrEmpty(dateStr)) return;

            DateTime date;
            if (!DateTime.TryParse(dateStr, out date)) return;

            litDailyTitle.Text = string.Format(T("Learning Activity on {0}", "Aktiviti Pembelajaran pada {0}"),
                date.ToString("d MMMM yyyy", new CultureInfo(CurrentLanguage == "BM" ? "ms-MY" : "en-US")));

            var activities = GetDailyActivities(date);

            pnlDailyActivities.Controls.Clear();
            if (activities.Count == 0)
            {
                pnlDailyEmpty.Visible = true;
            }
            else
            {
                pnlDailyEmpty.Visible = false;
                StringBuilder sb = new StringBuilder();
                foreach (var act in activities)
                {
                    string iconClass = act.Type == "lesson" ? "bi-book-half" :
                                       act.Type == "lab" ? "bi-cpu" :
                                       act.Type == "task" ? "bi-check2-circle" :
                                       act.Type == "session" ? "bi-camera-video" :
                                       act.Type == "quiz" ? "bi-patch-question" : "bi-lightning-charge";
                    string bgClass = act.Type == "lesson" ? "pt-act-icon-lesson" :
                                     act.Type == "lab" ? "pt-act-icon-lab" :
                                     act.Type == "task" ? "pt-act-icon-task" :
                                     act.Type == "session" ? "pt-act-icon-session" :
                                     act.Type == "quiz" ? "pt-act-icon-quiz" : "pt-act-icon-xp";

                    sb.AppendFormat(@"<div class=""pt-daily-activity-row"">
                        <div class=""pt-daily-activity-icon {0}""><i class=""bi {1}""></i></div>
                        <div class=""pt-daily-activity-text"">{2}</div>
                    </div>", bgClass, iconClass, act.Description);
                }
                pnlDailyActivities.Controls.Add(new LiteralControl(sb.ToString()));
            }

            pnlDailyModal.Visible = true;
        }

        protected void BtnCloseDailyModal_Click(object sender, EventArgs e)
        {
            pnlDailyModal.Visible = false;
            BuildHeatmap();
        }

        private List<ActivityItem> GetDailyActivities(DateTime date)
        {
            var list = new List<ActivityItem>();
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // Lessons
                    using (var cmd = new SqlCommand(@"SELECT l.lessonTitleEN, l.lessonTitleBM FROM dbo.LessonProgress lp
                        INNER JOIN dbo.Lesson l ON lp.lessonId=l.lessonId
                        WHERE lp.studentId=@sid AND lp.isCompleted=1 AND CAST(lp.completedDate AS DATE)=@d", conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                        cmd.Parameters.AddWithValue("@d", date.Date);
                        using (var rdr = cmd.ExecuteReader())
                        {
                            while (rdr.Read())
                            {
                                string title = CurrentLanguage == "BM" && rdr["lessonTitleBM"] != DBNull.Value
                                    ? rdr["lessonTitleBM"].ToString() : rdr["lessonTitleEN"].ToString();
                                list.Add(new ActivityItem("lesson",
                                    string.Format(T("Completed lesson: {0}", "Selesai pelajaran: {0}"), title)));
                            }
                        }
                    }

                    // Labs
                    using (var cmd = new SqlCommand(@"SELECT vl.labTitleEN, vl.labTitleBM FROM dbo.LabProgress lp
                        INNER JOIN dbo.VirtualLab vl ON lp.labId=vl.labId
                        WHERE lp.studentId=@sid AND lp.isCompleted=1 AND CAST(lp.completedDate AS DATE)=@d", conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                        cmd.Parameters.AddWithValue("@d", date.Date);
                        using (var rdr = cmd.ExecuteReader())
                        {
                            while (rdr.Read())
                            {
                                string title = CurrentLanguage == "BM" && rdr["labTitleBM"] != DBNull.Value
                                    ? rdr["labTitleBM"].ToString() : rdr["labTitleEN"].ToString();
                                list.Add(new ActivityItem("lab",
                                    string.Format(T("Completed virtual lab: {0}", "Selesai makmal maya: {0}"), title)));
                            }
                        }
                    }

                    // SPTasks
                    using (var cmd = new SqlCommand(@"SELECT t.taskTitle FROM dbo.SPTask t
                        INNER JOIN dbo.StudyPlan sp ON t.studyPlanId=sp.studyPlanId
                        WHERE sp.studentParentId=@spid AND t.isCompleted=1 AND CAST(t.completedAt AS DATE)=@d", conn))
                    {
                        cmd.Parameters.AddWithValue("@spid", _studentParentId);
                        cmd.Parameters.AddWithValue("@d", date.Date);
                        using (var rdr = cmd.ExecuteReader())
                        {
                            while (rdr.Read())
                            {
                                list.Add(new ActivityItem("task",
                                    string.Format(T("Study plan task completed: {0}", "Tugasan pelan belajar selesai: {0}"), rdr["taskTitle"].ToString())));
                            }
                        }
                    }

                    // Live sessions
                    using (var cmd = new SqlCommand(@"SELECT lcs.sessionTitle FROM dbo.LiveSessionParticipant lsp
                        INNER JOIN dbo.LiveConsultationSession lcs ON lsp.sessionId=lcs.sessionId
                        WHERE lsp.studentId=@sid AND CAST(lsp.joinedAt AS DATE)=@d", conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                        cmd.Parameters.AddWithValue("@d", date.Date);
                        using (var rdr = cmd.ExecuteReader())
                        {
                            while (rdr.Read())
                            {
                                list.Add(new ActivityItem("session",
                                    string.Format(T("Joined live session: {0}", "Menyertai sesi langsung: {0}"), rdr["sessionTitle"].ToString())));
                            }
                        }
                    }

                    // Quiz attempts (no score shown)
                    using (var cmd = new SqlCommand(@"SELECT COUNT(*) FROM dbo.QuizResult
                        WHERE studentId=@sid AND CAST(attemptedDate AS DATE)=@d", conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                        cmd.Parameters.AddWithValue("@d", date.Date);
                        int quizCount = (int)cmd.ExecuteScalar();
                        if (quizCount > 0)
                        {
                            list.Add(new ActivityItem("quiz",
                                T("Quiz activity recorded. View Quiz Results for marks and details.",
                                  "Aktiviti kuiz direkodkan. Lihat Keputusan Kuiz untuk markah dan butiran.")));
                        }
                    }
                }
            }
            catch { }
            return list;
        }

        private class ActivityItem
        {
            public string Type;
            public string Description;
            public ActivityItem(string type, string desc) { Type = type; Description = desc; }
        }

        // ══════════════════════════════════════════════════════════════
        //  BE A COACH SECTION
        // ══════════════════════════════════════════════════════════════
        private void BuildCoachSection()
        {
            DateTime now = DateTime.Now;
            DateTime monthStart = new DateTime(now.Year, now.Month, 1);
            DateTime weekStart = now.AddDays(-(int)(now.DayOfWeek == DayOfWeek.Sunday ? 6 : (int)now.DayOfWeek - 1));

            int activitiesThisWeek = 0, activitiesThisMonth = 0, activeLearningDaysMonth = 0;
            int daysSinceLastActivity = 999;
            int overdueTasks = 0;
            int streak = 0;

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // Activities this week
                    using (var cmd = new SqlCommand(@"SELECT COUNT(*) FROM (
                        SELECT completedDate AS d FROM dbo.LessonProgress WHERE studentId=@sid AND isCompleted=1 AND completedDate>=@ws
                        UNION ALL SELECT completedDate FROM dbo.LabProgress WHERE studentId=@sid AND isCompleted=1 AND completedDate>=@ws
                    ) x", conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                        cmd.Parameters.AddWithValue("@ws", weekStart);
                        activitiesThisWeek = (int)cmd.ExecuteScalar();
                    }

                    // Activities this month + active days
                    using (var cmd = new SqlCommand(@"SELECT COUNT(*) AS total, COUNT(DISTINCT CAST(d AS DATE)) AS days FROM (
                        SELECT completedDate AS d FROM dbo.LessonProgress WHERE studentId=@sid AND isCompleted=1 AND completedDate>=@ms
                        UNION ALL SELECT completedDate FROM dbo.LabProgress WHERE studentId=@sid AND isCompleted=1 AND completedDate>=@ms
                        UNION ALL SELECT completedAt FROM dbo.SPTask t INNER JOIN dbo.StudyPlan sp ON t.studyPlanId=sp.studyPlanId
                            WHERE sp.studentParentId=@spid AND t.isCompleted=1 AND t.completedAt>=@ms
                    ) x", conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                        cmd.Parameters.AddWithValue("@spid", _studentParentId);
                        cmd.Parameters.AddWithValue("@ms", monthStart);
                        using (var rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                activitiesThisMonth = rdr["total"] != DBNull.Value ? Convert.ToInt32(rdr["total"]) : 0;
                                activeLearningDaysMonth = rdr["days"] != DBNull.Value ? Convert.ToInt32(rdr["days"]) : 0;
                            }
                        }
                    }

                    // Days since last activity
                    using (var cmd = new SqlCommand(@"SELECT MAX(d) FROM (
                        SELECT MAX(completedDate) AS d FROM dbo.LessonProgress WHERE studentId=@sid AND isCompleted=1
                        UNION ALL SELECT MAX(completedDate) FROM dbo.LabProgress WHERE studentId=@sid AND isCompleted=1
                    ) x", conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                        object r = cmd.ExecuteScalar();
                        if (r != null && r != DBNull.Value)
                        {
                            daysSinceLastActivity = (DateTime.Today - Convert.ToDateTime(r).Date).Days;
                        }
                    }

                    // Overdue tasks (incomplete tasks in plans that have passed endDate)
                    using (var cmd = new SqlCommand(@"SELECT COUNT(*) FROM dbo.SPTask t
                        INNER JOIN dbo.StudyPlan sp ON t.studyPlanId=sp.studyPlanId
                        WHERE sp.studentParentId=@spid AND t.isCompleted=0 AND sp.endDate < @today", conn))
                    {
                        cmd.Parameters.AddWithValue("@spid", _studentParentId);
                        cmd.Parameters.AddWithValue("@today", DateTime.Today);
                        overdueTasks = (int)cmd.ExecuteScalar();
                    }

                    // Learning streak (consecutive days with activity ending today or yesterday)
                    streak = CalculateStreak(conn);
                }
            }
            catch { }

            // Determine progress level
            string level; // slow, good, amazing
            if (activitiesThisWeek < 2 || daysSinceLastActivity >= 5 || overdueTasks > 0)
                level = "slow";
            else if (activeLearningDaysMonth >= 8 || activitiesThisMonth >= 8 || streak >= 3)
                level = "amazing";
            else
                level = "good";

            // Set fox image
            string imgPath = level == "slow" ? "../Images/Parent/low-progress.png" :
                             level == "amazing" ? "../Images/Parent/amazing-progress.png" :
                             "../Images/Parent/good-progress.png";
            imgFox.ImageUrl = imgPath;
            imgFox.AlternateText = level == "slow" ? "😴 🦊" : level == "amazing" ? "🎉 🦊" : "😊 🦊";

            // Set message
            if (level == "slow")
            {
                string recommendation = GetRecommendation();
                litCoachMessage.Text = string.Format(
                    T("{0} has low activity this month.", "{0} mempunyai aktiviti rendah bulan ini."), _selectedChildName);
                pnlCoachTip.Visible = true;
                litCoachTip.Text = recommendation;
                pnlAddStudyPlanBtn.Visible = true;
            }
            else if (level == "amazing")
            {
                litCoachMessage.Text = string.Format(
                    T("Great job! {0} has completed {1} learning activities this month. Keep the streak going!",
                      "Tahniah! {0} telah menyelesaikan {1} aktiviti pembelajaran bulan ini. Teruskan momentum!"),
                    _selectedChildName, activitiesThisMonth);
                pnlCoachTip.Visible = false;
                pnlAddStudyPlanBtn.Visible = false;
            }
            else
            {
                litCoachMessage.Text = string.Format(
                    T("Good progress! {0} is building a steady learning habit. Keep supporting the routine.",
                      "Kemajuan yang baik! {0} sedang membina tabiat pembelajaran yang stabil. Teruskan sokongan."),
                    _selectedChildName);
                pnlCoachTip.Visible = false;
                pnlAddStudyPlanBtn.Visible = false;
            }
        }

        private int CalculateStreak(SqlConnection conn)
        {
            int streak = 0;
            try
            {
                using (var cmd = new SqlCommand(@"SELECT DISTINCT CAST(d AS DATE) AS actDate FROM (
                    SELECT completedDate AS d FROM dbo.LessonProgress WHERE studentId=@sid AND isCompleted=1 AND completedDate >= @start
                    UNION ALL SELECT completedDate FROM dbo.LabProgress WHERE studentId=@sid AND isCompleted=1 AND completedDate >= @start
                ) x ORDER BY actDate DESC", conn))
                {
                    cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                    cmd.Parameters.AddWithValue("@start", DateTime.Today.AddDays(-30));
                    using (var rdr = cmd.ExecuteReader())
                    {
                        DateTime expected = DateTime.Today;
                        bool first = true;
                        while (rdr.Read())
                        {
                            DateTime actDate = Convert.ToDateTime(rdr["actDate"]).Date;
                            if (first)
                            {
                                if (actDate != DateTime.Today && actDate != DateTime.Today.AddDays(-1)) break;
                                expected = actDate;
                                first = false;
                            }
                            if (actDate == expected) { streak++; expected = expected.AddDays(-1); }
                            else break;
                        }
                    }
                }
            }
            catch { }
            return streak;
        }

        private string GetRecommendation()
        {
            string recommendation = "";
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // Priority 1: AILearningAnalysis weak topics
                    using (var cmd = new SqlCommand(@"SELECT TOP 1 weakTopics FROM dbo.AILearningAnalysis
                        WHERE studentId=@sid AND isLatest=1 AND weakTopics IS NOT NULL AND weakTopics <> ''", conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                        object r = cmd.ExecuteScalar();
                        if (r != null && r != DBNull.Value)
                        {
                            string weakTopics = r.ToString();
                            string firstTopic = weakTopics.Contains(",") ? weakTopics.Split(',')[0].Trim() : weakTopics.Trim();
                            recommendation = string.Format(
                                T("Try asking {0} to spend 20 minutes reviewing: {1}",
                                  "Cuba minta {0} luangkan 20 minit mengulangkaji: {1}"),
                                _selectedChildName, firstTopic);
                            return recommendation;
                        }
                    }

                    // Priority 2: Latest unfinished lesson
                    using (var cmd = new SqlCommand(@"SELECT TOP 1 l.lessonTitleEN, l.lessonTitleBM, u.unitNameEN, u.unitNameBM
                        FROM dbo.Lesson l
                        INNER JOIN dbo.Subtopic st ON l.subtopicId=st.subtopicId
                        INNER JOIN dbo.Unit u ON st.unitId=u.unitId
                        WHERE l.lessonId NOT IN (SELECT lessonId FROM dbo.LessonProgress WHERE studentId=@sid AND isCompleted=1)
                        ORDER BY u.orderNo, st.orderNo, l.orderNo", conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                        using (var rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                string unitName = CurrentLanguage == "BM" && rdr["unitNameBM"] != DBNull.Value
                                    ? rdr["unitNameBM"].ToString() : rdr["unitNameEN"].ToString();
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

            // Priority 4: General
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
                ShowMessage(T("Please enter a task name.", "Sila masukkan nama tugasan."), false);
                return;
            }

            if (string.IsNullOrEmpty(_selectedChildId))
            {
                _selectedChildId = ddlSidebarChild.SelectedValue;
                _selectedChildName = ddlSidebarChild.SelectedItem != null ? ddlSidebarChild.SelectedItem.Text : "";
                LoadStudentParentId();
            }

            if (string.IsNullOrEmpty(_studentParentId))
            {
                ShowMessage(T("Unable to find child link.", "Tidak dapat mencari pautan anak."), false);
                return;
            }

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // Find active/Ongoing study plan
                    string studyPlanId = null;
                    using (var cmd = new SqlCommand(@"SELECT TOP 1 studyPlanId FROM dbo.StudyPlan
                        WHERE studentParentId=@spid AND status='Ongoing' ORDER BY createdAt DESC", conn))
                    {
                        cmd.Parameters.AddWithValue("@spid", _studentParentId);
                        object r = cmd.ExecuteScalar();
                        if (r != null && r != DBNull.Value) studyPlanId = r.ToString();
                    }

                    using (var txn = conn.BeginTransaction())
                    {
                        try
                        {
                            // If no active plan, create one
                            if (string.IsNullOrEmpty(studyPlanId))
                            {
                                studyPlanId = GenerateId(conn, txn, "StudyPlan", "studyPlanId", "STP");
                                using (var cmd = new SqlCommand(@"INSERT INTO dbo.StudyPlan
                                    (studyPlanId, studentParentId, createdByUserId, planTitle, startDate, endDate, status, createdAt)
                                    VALUES (@id, @spid, @uid, @title, @start, @end, 'Ongoing', @now)", conn, txn))
                                {
                                    cmd.Parameters.AddWithValue("@id", studyPlanId);
                                    cmd.Parameters.AddWithValue("@spid", _studentParentId);
                                    cmd.Parameters.AddWithValue("@uid", _parentUserId);
                                    cmd.Parameters.AddWithValue("@title", "Quick Support Plan");
                                    cmd.Parameters.AddWithValue("@start", DateTime.Today);
                                    cmd.Parameters.AddWithValue("@end", DateTime.Today.AddDays(7));
                                    cmd.Parameters.AddWithValue("@now", DateTime.Now);
                                    cmd.ExecuteNonQuery();
                                }
                            }

                            // Get max orderNo
                            int maxOrder = 0;
                            using (var cmd = new SqlCommand("SELECT ISNULL(MAX(orderNo),0) FROM dbo.SPTask WHERE studyPlanId=@spid", conn, txn))
                            {
                                cmd.Parameters.AddWithValue("@spid", studyPlanId);
                                maxOrder = (int)cmd.ExecuteScalar();
                            }

                            // Generate SPTask ID
                            string taskId = GenerateId(conn, txn, "SPTask", "spTaskId", "SPT");

                            // Insert task
                            using (var cmd = new SqlCommand(@"INSERT INTO dbo.SPTask
                                (spTaskId, studyPlanId, taskTitle, suggestedAction, orderNo, isCompleted, completedAt)
                                VALUES (@id, @spid, @title, @action, @order, 0, NULL)", conn, txn))
                            {
                                cmd.Parameters.AddWithValue("@id", taskId);
                                cmd.Parameters.AddWithValue("@spid", studyPlanId);
                                cmd.Parameters.AddWithValue("@title", txtTaskName.Text.Trim());
                                cmd.Parameters.AddWithValue("@action", string.IsNullOrEmpty(txtSuggestedAction.Text) ? (object)DBNull.Value : txtSuggestedAction.Text.Trim());
                                cmd.Parameters.AddWithValue("@order", maxOrder + 1);
                                cmd.ExecuteNonQuery();
                            }

                            txn.Commit();

                            txtTaskName.Text = "";
                            txtSuggestedAction.Text = "";
                            // Hide modal after success and rebuild page
                            pnlTaskModal.CssClass = "pt-task-modal-overlay pt-task-modal-hidden";
                            ShowMessage(T("The task has been added to the study plan.",
                                "Tugasan telah ditambah ke pelan belajar."), true);
                            BuildHeatmap();
                            BuildCoachSection();
                        }
                        catch
                        {
                            txn.Rollback();
                            throw;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage(T("An error occurred while adding the task.", "Ralat berlaku semasa menambah tugasan."), false);
            }
        }

        private string GenerateId(SqlConnection conn, SqlTransaction txn, string table, string column, string prefix)
        {
            int nextNum = 1;
            string sql = string.Format("SELECT MAX({0}) FROM dbo.[{1}]", column, table);
            using (var cmd = new SqlCommand(sql, conn, txn))
            {
                object r = cmd.ExecuteScalar();
                if (r != null && r != DBNull.Value)
                {
                    string lastId = r.ToString();
                    if (lastId.Length > prefix.Length)
                    {
                        int num;
                        if (int.TryParse(lastId.Substring(prefix.Length), out num))
                            nextNum = num + 1;
                    }
                }
            }
            return prefix + nextNum.ToString("D3");
        }

        private void ShowMessage(string msg, bool success)
        {
            pnlMessage.Visible = true;
            divMessage.InnerHtml = msg;
            iMsgIcon.Attributes["class"] = success ? "bi bi-check-circle-fill" : "bi bi-exclamation-circle-fill";
        }

        protected void BtnCloseMsg_Click(object sender, EventArgs e)
        {
            pnlMessage.Visible = false;
            BuildHeatmap();
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