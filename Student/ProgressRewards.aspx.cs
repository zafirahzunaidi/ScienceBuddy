using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Student
{
    public partial class ProgressReward : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        public string CurrentLanguage = "EN";
        public string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null || Session["role"].ToString() != "Student")
            { Response.Redirect("~/Login.aspx", false); return; }
            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            if (!IsPostBack) { InitLang(); LoadPage(); }
        }

        private void InitLang()
        {
            string lang = Session["preferredLanguage"] as string;
            if (!string.IsNullOrEmpty(lang)) { CurrentLanguage = lang; return; }
            string userId = Session["userId"] as string;
            if (!string.IsNullOrEmpty(userId))
            {
                try
                {
                    using (var conn = new SqlConnection(ConnStr))
                    using (var cmd = new SqlCommand("SELECT preferredLanguage FROM [User] WHERE userId=@u", conn))
                    { cmd.Parameters.AddWithValue("@u", userId); conn.Open(); var r = cmd.ExecuteScalar();
                      if (r != null && r != DBNull.Value) { lang = r.ToString(); Session["preferredLanguage"] = lang; CurrentLanguage = lang; return; } }
                } catch { }
            }
            CurrentLanguage = "EN"; Session["preferredLanguage"] = "EN";
        }

        private void LoadPage()
        {
            SetLabels();
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                string studentId = GetStudentId(conn);
                if (string.IsNullOrEmpty(studentId)) { pnlMain.Visible = false; pnlEmpty.Visible = true; return; }

                int totalXP = GetInt(conn, "SELECT ISNULL(XP,0) FROM Student WHERE studentId=@s", studentId);
                int lessonsCompleted = GetInt(conn, "SELECT COUNT(*) FROM LessonProgress WHERE studentId=@s AND isCompleted=1", studentId);
                int quizzesAttempted = GetInt(conn, "SELECT COUNT(*) FROM QuizResult WHERE studentId=@s", studentId);
                int badgesEarned = GetInt(conn, "SELECT COUNT(*) FROM StudentBadge WHERE studentId=@s", studentId);

                if (totalXP == 0 && lessonsCompleted == 0 && quizzesAttempted == 0 && badgesEarned == 0)
                { pnlMain.Visible = false; pnlEmpty.Visible = true; return; }

                litStatXP.Text = totalXP.ToString("N0");
                litStatLessons.Text = lessonsCompleted.ToString();
                litStatQuizzes.Text = quizzesAttempted.ToString();
                litStatBadges.Text = badgesEarned.ToString();

                BuildWeeklyChart(conn, studentId);
                BuildQuizPerformance(conn, studentId);
                BuildWeakTopics(conn, studentId);
                LoadBadges(conn, studentId);
                BuildCertificates(conn, studentId);
                BuildAIHint(conn, studentId);
            }
        }

        private void SetLabels()
        {
            litPageTitle.Text = T("Progress &amp; Rewards", "Kemajuan &amp; Ganjaran");
            litHeroTitle.Text = T("My Progress &amp; Rewards", "Kemajuan &amp; Ganjaran Saya");
            litHeroSubtitle.Text = T("See your learning journey, badges, quiz results, and certificates in one place.",
                "Lihat perjalanan pembelajaran, lencana, keputusan kuiz dan sijil anda di satu tempat.");
            litStatXPLabel.Text = T("Total XP", "Jumlah XP");
            litStatLessonsLabel.Text = T("Lessons Completed", "Pelajaran Selesai");
            litStatQuizzesLabel.Text = T("Quizzes Attempted", "Kuiz Dijawab");
            litStatBadgesLabel.Text = T("Badges Earned", "Lencana Diperolehi");
            litWeeklyTitle.Text = T("Weekly Activity", "Aktiviti Mingguan");
            litChartLegend.Text = T("Activities include completed lessons, labs, quizzes, and study plan tasks.",
                "Aktiviti termasuk pelajaran, makmal, kuiz dan tugasan pelan belajar yang selesai.");
            litQuizPerfTitle.Text = T("Quiz Performance by Unit", "Prestasi Kuiz Mengikut Unit");
            litWeakTitle.Text = T("Topics to Review", "Topik untuk Ulangkaji");
            litBadgeTitle.Text = T("Badge Collection", "Koleksi Lencana");
            litCertTitle.Text = T("Certificate Status", "Status Sijil");
            litAIHintTitle.Text = T("Buddy's Study Tip", "Tip Kajian Buddy");
            litEmptyTitle.Text = T("No Progress Yet", "Tiada Kemajuan Lagi");
            litEmptyDesc.Text = T("Start your learning journey to see your progress here!", "Mulakan perjalanan pembelajaran anda untuk melihat kemajuan di sini!");
            litEmptyBtn.Text = T("Start Learning", "Mula Belajar");
        }

        private void BuildWeeklyChart(SqlConnection conn, string studentId)
        {
            DateTime today = DateTime.Today;
            DateTime weekAgo = today.AddDays(-6);

            // Include SPTask if table exists
            bool hasSPTask = Tbl(conn, "SPTask");
            string spTaskUnion = hasSPTask ? @"
                UNION ALL
                SELECT spt.completedAt AS actDate FROM SPTask spt
                INNER JOIN StudyPlan sp ON sp.studyPlanId = spt.studyPlanId
                INNER JOIN StudentParent stp ON stp.studentParentId = sp.studentParentId
                WHERE stp.studentId = @s AND spt.isCompleted = 1
                  AND spt.completedAt >= @startDate AND spt.completedAt < @endDate" : "";

            string sql = string.Format(@"
                SELECT CAST(actDate AS DATE) AS actDay, COUNT(*) AS cnt FROM (
                    SELECT completedDate AS actDate FROM LessonProgress WHERE studentId=@s AND isCompleted=1 AND completedDate>=@startDate AND completedDate<@endDate
                    UNION ALL
                    SELECT completedDate AS actDate FROM LabProgress WHERE studentId=@s AND isCompleted=1 AND completedDate>=@startDate AND completedDate<@endDate
                    UNION ALL
                    SELECT attemptedDate AS actDate FROM QuizResult WHERE studentId=@s AND attemptedDate>=@startDate AND attemptedDate<@endDate
                    {0}
                ) AS combined GROUP BY CAST(actDate AS DATE)", spTaskUnion);

            var dailyCounts = new Dictionary<DateTime, int>();
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@s", studentId);
                cmd.Parameters.AddWithValue("@startDate", weekAgo);
                cmd.Parameters.AddWithValue("@endDate", today.AddDays(1));
                using (var rdr = cmd.ExecuteReader())
                { while (rdr.Read()) { dailyCounts[rdr.GetDateTime(0).Date] = rdr.GetInt32(1); } }
            }

            int maxCount = 0;
            foreach (var v in dailyCounts.Values) { if (v > maxCount) maxCount = v; }
            bool allZero = maxCount == 0;
            if (maxCount == 0) maxCount = 1;

            string[] dayEN = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" };
            string[] dayBM = { "Ahd", "Isn", "Sel", "Rab", "Kha", "Jum", "Sab" };

            var html = new System.Text.StringBuilder();
            if (allZero)
            {
                html.Append("<div class=\"st-progress-chart-empty-msg\"><i class=\"bi bi-bar-chart\"></i> ");
                html.Append(T("No learning activity recorded this week yet. Complete a lesson or quiz to fill this chart!",
                    "Belum ada aktiviti pembelajaran minggu ini. Selesaikan pelajaran atau kuiz untuk mengisi carta ini!"));
                html.Append("</div>");
            }
            html.Append("<div class=\"st-progress-chart-bars\">");
            for (int i = 0; i < 7; i++)
            {
                DateTime day = weekAgo.AddDays(i);
                int count; dailyCounts.TryGetValue(day.Date, out count);
                int heightPct = (int)((double)count / maxCount * 100);
                if (count > 0 && heightPct < 10) heightPct = 10;
                string barClass = count > 0 ? "st-progress-chart-bar active" : "st-progress-chart-bar";
                string dayLabel = CurrentLanguage == "BM" ? dayBM[(int)day.DayOfWeek] : dayEN[(int)day.DayOfWeek];

                html.Append("<div class=\"st-progress-chart-col\">");
                html.AppendFormat("<div class=\"st-progress-chart-value\">{0}</div>", count);
                html.Append("<div class=\"st-progress-chart-bar-wrap\">");
                html.AppendFormat("<div class=\"{0}\" style=\"height:{1}%;\"></div>", barClass, allZero ? 4 : heightPct);
                html.Append("</div>");
                html.AppendFormat("<div class=\"st-progress-chart-label\">{0}</div>", dayLabel);
                html.Append("</div>");
            }
            html.Append("</div>");
            litWeeklyChart.Text = html.ToString();
        }

        private void BuildQuizPerformance(SqlConnection conn, string studentId)
        {
            string col = CurrentLanguage == "BM" ? "u.unitNameBM" : "u.unitNameEN";
            string sql = string.Format(@"SELECT {0} AS unitName, AVG(qr.percentage) AS avgPct, MAX(qr.percentage) AS bestPct
                FROM QuizResult qr INNER JOIN Quiz q ON q.quizId=qr.quizId INNER JOIN Unit u ON u.unitId=q.unitId
                WHERE qr.studentId=@s GROUP BY {0} ORDER BY bestPct DESC", col);

            var dt = new DataTable();
            using (var cmd = new SqlCommand(sql, conn)) { cmd.Parameters.AddWithValue("@s", studentId); new SqlDataAdapter(cmd).Fill(dt); }
            if (dt.Rows.Count == 0) { pnlQuizPerf.Visible = false; pnlNoQuizPerf.Visible = true;
                litNoQuizPerf.Text = T("No quiz attempts yet. Take a quiz to see your performance!", "Tiada percubaan kuiz lagi. Jawab kuiz untuk melihat prestasi anda!"); return; }

            var html = new System.Text.StringBuilder("<div class=\"st-progress-quiz-perf-list\">");
            foreach (DataRow row in dt.Rows)
            {
                string name = row["unitName"] != DBNull.Value ? row["unitName"].ToString() : "\u2014";
                int best = row["bestPct"] != DBNull.Value ? (int)Convert.ToDecimal(row["bestPct"]) : 0;
                string cls, lbl;
                if (best >= 80) { cls = "excellent"; lbl = T("Excellent", "Cemerlang"); }
                else if (best >= 60) { cls = "good"; lbl = T("Good", "Baik"); }
                else { cls = "needs-revision"; lbl = T("Needs Revision", "Perlu Ulangkaji"); }

                html.Append("<div class=\"st-progress-quiz-perf-item\">");
                html.AppendFormat("<div class=\"st-progress-quiz-perf-info\"><span class=\"st-progress-quiz-perf-name\">{0}</span><span class=\"st-progress-quiz-perf-badge {1}\">{2}</span></div>", HttpUtility.HtmlEncode(name), cls, lbl);
                html.AppendFormat("<div class=\"st-progress-quiz-perf-bar-wrap\"><div class=\"st-progress-quiz-perf-bar {0}\" style=\"width:{1}%;\"></div></div>", cls, best);
                html.AppendFormat("<div class=\"st-progress-quiz-perf-pct\">{0}%</div>", best);
                html.Append("</div>");
            }
            html.Append("</div>");
            litQuizPerfContent.Text = html.ToString();
        }

        private void BuildWeakTopics(SqlConnection conn, string studentId)
        {
            string col = CurrentLanguage == "BM" ? "st.subtopicTitleBM" : "st.subtopicTitleEN";
            string sql = string.Format(@"SELECT TOP 3 {0} AS subtopicName, COUNT(*) AS wrongCount
                FROM QuizAnswer qa INNER JOIN QuizResult qr ON qr.resultId=qa.resultId
                INNER JOIN Question q ON q.questionId=qa.questionId
                INNER JOIN Subtopic st ON st.subtopicId=q.subtopicId
                WHERE qr.studentId=@s AND qa.isCorrect=0
                GROUP BY {0} ORDER BY COUNT(*) DESC", col);

            var dt = new DataTable();
            using (var cmd = new SqlCommand(sql, conn)) { cmd.Parameters.AddWithValue("@s", studentId); new SqlDataAdapter(cmd).Fill(dt); }
            if (dt.Rows.Count == 0) { pnlWeakTopics.Visible = false; pnlNoWeakTopics.Visible = true;
                litNoWeakTopics.Text = T("No weak topics found yet. Keep attempting quizzes!", "Tiada topik lemah ditemui lagi. Teruskan menjawab kuiz!"); return; }

            string reviewText = T("Review Lesson", "Ulangkaji Pelajaran");
            var html = new System.Text.StringBuilder("<div class=\"st-progress-weak-list\">");
            foreach (DataRow row in dt.Rows)
            {
                string name = row["subtopicName"] != DBNull.Value ? row["subtopicName"].ToString() : "\u2014";
                int cnt = Convert.ToInt32(row["wrongCount"]);
                html.Append("<div class=\"st-progress-weak-item\">");
                html.AppendFormat("<div class=\"st-progress-weak-info\"><div class=\"st-progress-weak-name\"><i class=\"bi bi-exclamation-circle\"></i> {0}</div><div class=\"st-progress-weak-count\">{1} {2}</div></div>",
                    HttpUtility.HtmlEncode(name), cnt, T("wrong answers", "jawapan salah"));
                html.AppendFormat("<a href=\"{0}\" class=\"st-progress-weak-btn\"><i class=\"bi bi-arrow-repeat\"></i> {1}</a>", ResolveUrl("~/Student/MyLearning.aspx"), reviewText);
                html.Append("</div>");
            }
            html.Append("</div>");
            litWeakTopicsContent.Text = html.ToString();
        }

        private void LoadBadges(SqlConnection conn, string studentId)
        {
            string sql = @"SELECT b.badgeId,b.badgeNameEN,b.badgeNameBM,b.badgeDescriptionEN,b.badgeDescriptionBM,b.badgeIcon,
                sb.studentBadgeId,sb.earnedAt FROM Badge b LEFT JOIN StudentBadge sb ON sb.badgeId=b.badgeId AND sb.studentId=@s
                ORDER BY CASE WHEN sb.studentBadgeId IS NOT NULL THEN 0 ELSE 1 END, b.badgeId";
            var dt = new DataTable();
            using (var cmd = new SqlCommand(sql, conn)) { cmd.Parameters.AddWithValue("@s", studentId); new SqlDataAdapter(cmd).Fill(dt); }
            if (dt.Rows.Count == 0) { pnlBadges.Visible = false; pnlNoBadges.Visible = true;
                litNoBadges.Text = T("No badges available yet.", "Tiada lencana tersedia lagi."); return; }

            bool isBM = CurrentLanguage == "BM";
            string earnedLbl = T("Earned", "Diperoleh"); string lockedLbl = T("Locked", "Dikunci");
            var list = new List<object>();
            foreach (DataRow row in dt.Rows)
            {
                bool earned = row["studentBadgeId"] != DBNull.Value;
                string name = isBM ? (row["badgeNameBM"]?.ToString() ?? row["badgeNameEN"]?.ToString() ?? "") : (row["badgeNameEN"]?.ToString() ?? "");
                string desc = isBM ? (row["badgeDescriptionBM"]?.ToString() ?? row["badgeDescriptionEN"]?.ToString() ?? "") : (row["badgeDescriptionEN"]?.ToString() ?? "");
                string icon = row["badgeIcon"] != DBNull.Value ? row["badgeIcon"].ToString() : "";
                string iconUrl = "";
                if (!string.IsNullOrWhiteSpace(icon))
                    iconUrl = icon.StartsWith("~/") ? ResolveUrl(icon) : icon.StartsWith("Images/") ? ResolveUrl("~/" + icon) : ResolveUrl("~/Images/Badge/" + icon);
                string earnedDate = earned && row["earnedAt"] != DBNull.Value ? Convert.ToDateTime(row["earnedAt"]).ToString("dd MMM yyyy") : "";
                string earnedText = earned && !string.IsNullOrEmpty(earnedDate) ? earnedLbl + " &bull; " + earnedDate : earnedLbl;

                list.Add(new { Name = HttpUtility.HtmlEncode(name), Description = HttpUtility.HtmlEncode(desc), IconUrl = iconUrl, IsEarned = earned, EarnedText = earnedText, LockedText = lockedLbl });
            }
            rptBadges.DataSource = list; rptBadges.DataBind();
        }

        private void BuildCertificates(SqlConnection conn, string studentId)
        {
            string lvCol = CurrentLanguage == "BM" ? "l.levelNameBM" : "l.levelNameEN";
            string ctCol = CurrentLanguage == "BM" ? "c.certificateTitleBM" : "c.certificateTitleEN";
            string sql = string.Format(@"SELECT l.levelId, {0} AS levelName, {1} AS certTitle, c.issuedDate, c.status AS certStatus, c.certificateUrl, c.certificateCode
                FROM Level l LEFT JOIN Certificate c ON c.levelId=l.levelId AND c.studentId=@s ORDER BY l.levelId", lvCol, ctCol);
            var dt = new DataTable();
            using (var cmd = new SqlCommand(sql, conn)) { cmd.Parameters.AddWithValue("@s", studentId); new SqlDataAdapter(cmd).Fill(dt); }

            var html = new System.Text.StringBuilder("<div class=\"st-progress-cert-grid\">");
            if (dt.Rows.Count == 0)
            { html.Append("<div class=\"st-progress-empty-state\"><i class=\"bi bi-file-earmark-check\"></i><p>"); html.Append(T("Complete levels to unlock certificates!", "Selesaikan tahap untuk membuka sijil!")); html.Append("</p></div>"); }
            else
            {
                string viewText = T("View Certificate", "Lihat Sijil");
                string downloadText = T("Download Certificate", "Muat Turun Sijil");
                string pendingText = T("Certificate pending approval", "Sijil menunggu kelulusan");
                string lockedText = T("Complete level to unlock", "Selesaikan tahap untuk membuka sijil");

                foreach (DataRow row in dt.Rows)
                {
                    string levelName = row["levelName"] != DBNull.Value ? row["levelName"].ToString() : "\u2014";
                    bool hasCert = row["certTitle"] != DBNull.Value;
                    string certStatus = hasCert ? (row["certStatus"]?.ToString() ?? "") : "";

                    // Certificate is available if status is Active, Approved, or Available
                    bool isAvailable = hasCert && (certStatus == "Active" || certStatus == "Approved" || certStatus == "Available");
                    bool isPending = hasCert && certStatus == "Pending";

                    // Resolve certificate URL - ensure it uses Images/Certificate/ path
                    string certUrl = "";
                    if (isAvailable && row["certificateUrl"] != DBNull.Value)
                    {
                        string rawUrl = row["certificateUrl"].ToString().Trim();
                        if (!string.IsNullOrEmpty(rawUrl))
                        {
                            if (rawUrl.StartsWith("~/")) certUrl = ResolveUrl(rawUrl);
                            else if (rawUrl.StartsWith("Images/")) certUrl = ResolveUrl("~/" + rawUrl);
                            else certUrl = ResolveUrl("~/Images/Certificate/" + rawUrl);
                        }
                    }
                    bool canView = !string.IsNullOrEmpty(certUrl);

                    html.AppendFormat("<div class=\"st-progress-cert-card {0}\">", isAvailable ? "earned" : "locked");
                    html.AppendFormat("<div class=\"st-progress-cert-icon-wrap\"><i class=\"bi {0}\"></i></div>", isAvailable ? "bi-file-earmark-check-fill" : isPending ? "bi-hourglass-split" : "bi-lock-fill");
                    html.AppendFormat("<div class=\"st-progress-cert-level\">{0}</div>", HttpUtility.HtmlEncode(levelName));

                    if (isAvailable)
                    {
                        string certTitle = row["certTitle"].ToString();
                        string issuedDate = row["issuedDate"] != DBNull.Value ? Convert.ToDateTime(row["issuedDate"]).ToString("dd MMM yyyy") : "";
                        html.AppendFormat("<div class=\"st-progress-cert-title\">{0}</div>", HttpUtility.HtmlEncode(certTitle));
                        if (!string.IsNullOrEmpty(issuedDate))
                            html.AppendFormat("<div class=\"st-progress-cert-date\"><i class=\"bi bi-calendar3\"></i> {0}</div>", issuedDate);
                        if (canView)
                            html.AppendFormat("<button type=\"button\" class=\"st-progress-cert-download\" onclick=\"openCertModal('{0}')\"><i class=\"bi bi-eye-fill\"></i> {1}</button>", HttpUtility.JavaScriptStringEncode(certUrl), viewText);
                    }
                    else if (isPending)
                    { html.AppendFormat("<div class=\"st-progress-cert-pending\">{0}</div>", pendingText); }
                    else
                    { html.AppendFormat("<div class=\"st-progress-cert-locked-msg\">{0}</div>", lockedText); }
                    html.Append("</div>");
                }
            }
            html.Append("</div>");
            litCertContent.Text = html.ToString();
        }

        private void BuildAIHint(SqlConnection conn, string studentId)
        {
            string col = CurrentLanguage == "BM" ? "u.unitNameBM" : "u.unitNameEN";
            string sql = string.Format(@"SELECT {0} AS unitName, AVG(qr.percentage) AS avgPct FROM QuizResult qr
                INNER JOIN Quiz q ON q.quizId=qr.quizId INNER JOIN Unit u ON u.unitId=q.unitId
                WHERE qr.studentId=@s GROUP BY {0} ORDER BY avgPct", col);
            var dt = new DataTable();
            using (var cmd = new SqlCommand(sql, conn)) { cmd.Parameters.AddWithValue("@s", studentId); new SqlDataAdapter(cmd).Fill(dt); }

            if (dt.Rows.Count < 1) { pnlAIHint.Visible = false; return; }
            string weakest = dt.Rows[0]["unitName"]?.ToString() ?? "\u2014";
            string strongest = dt.Rows[dt.Rows.Count - 1]["unitName"]?.ToString() ?? "\u2014";

            if (dt.Rows.Count == 1)
                litAIHintText.Text = T("Keep practising <strong>" + HttpUtility.HtmlEncode(weakest) + "</strong> to improve your score!",
                    "Teruskan berlatih <strong>" + HttpUtility.HtmlEncode(weakest) + "</strong> untuk meningkatkan markah!");
            else
                litAIHintText.Text = T("You're doing great in <strong>" + HttpUtility.HtmlEncode(strongest) + "</strong>! Buddy suggests revising <strong>" + HttpUtility.HtmlEncode(weakest) + "</strong> before your next quiz.",
                    "Anda cemerlang dalam <strong>" + HttpUtility.HtmlEncode(strongest) + "</strong>! Buddy cadangkan ulangkaji <strong>" + HttpUtility.HtmlEncode(weakest) + "</strong> sebelum kuiz seterusnya.");
        }

        private string GetStudentId(SqlConnection conn)
        {
            string uid = Session["userId"] as string; if (string.IsNullOrEmpty(uid)) return null;
            using (var cmd = new SqlCommand("SELECT studentId FROM Student WHERE userId=@u", conn))
            { cmd.Parameters.AddWithValue("@u", uid); var r = cmd.ExecuteScalar(); return r != null && r != DBNull.Value ? r.ToString() : null; }
        }
        private int GetInt(SqlConnection conn, string sql, string studentId)
        { using (var cmd = new SqlCommand(sql, conn)) { cmd.Parameters.AddWithValue("@s", studentId); var r = cmd.ExecuteScalar(); return r != null && r != DBNull.Value ? Convert.ToInt32(r) : 0; } }
        private static bool Tbl(SqlConnection conn, string t)
        { using (var cmd = new SqlCommand("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME=@t AND TABLE_TYPE='BASE TABLE'", conn))
          { cmd.Parameters.AddWithValue("@t", t); return (int)cmd.ExecuteScalar() > 0; } }
    }
}
