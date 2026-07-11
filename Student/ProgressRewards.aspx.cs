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
        private string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString; }
        }

        public string CurrentLanguage = "EN";

        public string T(string en, string bm)
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
            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            if (!IsPostBack)
            {
                InitLang();
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
            string userId = Session["userId"] as string;
            if (!string.IsNullOrEmpty(userId))
            {
                try
                {
                    using (SqlConnection connection = new SqlConnection(ConnStr))
                    using (SqlCommand command = new SqlCommand("SELECT preferredLanguage FROM [User] WHERE userId=@u", connection))
                    {
                        command.Parameters.AddWithValue("@u", userId);
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
            SetLabels();
            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();
                string studentId = GetStudentId(connection);
                if (string.IsNullOrEmpty(studentId))
                {
                    pnlMain.Visible = false;
                    pnlEmpty.Visible = true;
                    return;
                }

                int totalXP = GetInt(connection, "SELECT ISNULL(XP,0) FROM Student WHERE studentId=@s", studentId);
                int lessonsCompleted = GetInt(connection, "SELECT COUNT(*) FROM LessonProgress WHERE studentId=@s AND isCompleted=1", studentId);
                int quizzesAttempted = GetInt(connection, "SELECT COUNT(*) FROM QuizResult WHERE studentId=@s", studentId);
                int badgesEarned = GetInt(connection, "SELECT COUNT(*) FROM StudentBadge WHERE studentId=@s", studentId);

                if (totalXP == 0 && lessonsCompleted == 0 && quizzesAttempted == 0 && badgesEarned == 0)
                {
                    pnlMain.Visible = false;
                    pnlEmpty.Visible = true;
                    return;
                }

                litStatXP.Text = totalXP.ToString("N0");
                litStatLessons.Text = lessonsCompleted.ToString();
                litStatQuizzes.Text = quizzesAttempted.ToString();
                litStatBadges.Text = badgesEarned.ToString();

                BuildWeeklyChart(connection, studentId);
                BuildQuizPerformance(connection, studentId);
                BuildWeakTopics(connection, studentId);
                LoadBadges(connection, studentId);
                BuildCertificates(connection, studentId);
                BuildAIHint(connection, studentId);
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
            string spTaskUnion = "";
            if (hasSPTask)
            {
                spTaskUnion = @"
                UNION ALL
                SELECT spt.completedAt AS actDate FROM SPTask spt
                INNER JOIN StudyPlan sp ON sp.studyPlanId = spt.studyPlanId
                INNER JOIN StudentParent stp ON stp.studentParentId = sp.studentParentId
                WHERE stp.studentId = @s AND spt.isCompleted = 1
                  AND spt.completedAt >= @startDate AND spt.completedAt < @endDate";
            }

            string sql = string.Format(@"
                SELECT CAST(actDate AS DATE) AS actDay, COUNT(*) AS cnt FROM (
                    SELECT completedDate AS actDate FROM LessonProgress WHERE studentId=@s AND isCompleted=1 AND completedDate>=@startDate AND completedDate<@endDate
                    UNION ALL
                    SELECT completedDate AS actDate FROM LabProgress WHERE studentId=@s AND isCompleted=1 AND completedDate>=@startDate AND completedDate<@endDate
                    UNION ALL
                    SELECT attemptedDate AS actDate FROM QuizResult WHERE studentId=@s AND attemptedDate>=@startDate AND attemptedDate<@endDate
                    {0}
                ) AS combined GROUP BY CAST(actDate AS DATE)", spTaskUnion);

            Dictionary<DateTime, int> dailyCounts = new Dictionary<DateTime, int>();
            using (SqlCommand command = new SqlCommand(sql, conn))
            {
                command.Parameters.AddWithValue("@s", studentId);
                command.Parameters.AddWithValue("@startDate", weekAgo);
                command.Parameters.AddWithValue("@endDate", today.AddDays(1));
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        dailyCounts[reader.GetDateTime(0).Date] = reader.GetInt32(1);
                    }
                }
            }

            int maxCount = 0;
            foreach (int v in dailyCounts.Values)
            {
                if (v > maxCount)
                {
                    maxCount = v;
                }
            }
            bool allZero = maxCount == 0;
            if (maxCount == 0)
            {
                maxCount = 1;
            }

            string[] dayEN = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" };
            string[] dayBM = { "Ahd", "Isn", "Sel", "Rab", "Kha", "Jum", "Sab" };

            System.Text.StringBuilder htmlBuilder = new System.Text.StringBuilder();
            if (allZero)
            {
                htmlBuilder.Append("<div class=\"st-progress-chart-empty-msg\"><i class=\"bi bi-bar-chart\"></i> ");
                htmlBuilder.Append(T("No learning activity recorded this week yet. Complete a lesson or quiz to fill this chart!",
                    "Belum ada aktiviti pembelajaran minggu ini. Selesaikan pelajaran atau kuiz untuk mengisi carta ini!"));
                htmlBuilder.Append("</div>");
            }
            htmlBuilder.Append("<div class=\"st-progress-chart-bars\">");
            for (int i = 0; i < 7; i++)
            {
                DateTime day = weekAgo.AddDays(i);
                int count;
                dailyCounts.TryGetValue(day.Date, out count);
                int heightPct = (int)((double)count / maxCount * 100);
                if (count > 0 && heightPct < 10)
                {
                    heightPct = 10;
                }
                string barClass;
                if (count > 0)
                {
                    barClass = "st-progress-chart-bar active";
                }
                else
                {
                    barClass = "st-progress-chart-bar";
                }
                string dayLabel;
                if (CurrentLanguage == "BM")
                {
                    dayLabel = dayBM[(int)day.DayOfWeek];
                }
                else
                {
                    dayLabel = dayEN[(int)day.DayOfWeek];
                }

                htmlBuilder.Append("<div class=\"st-progress-chart-col\">");
                htmlBuilder.AppendFormat("<div class=\"st-progress-chart-value\">{0}</div>", count);
                htmlBuilder.Append("<div class=\"st-progress-chart-bar-wrap\">");
                htmlBuilder.AppendFormat("<div class=\"{0}\" style=\"height:{1}%;\"></div>", barClass, allZero ? 4 : heightPct);
                htmlBuilder.Append("</div>");
                htmlBuilder.AppendFormat("<div class=\"st-progress-chart-label\">{0}</div>", dayLabel);
                htmlBuilder.Append("</div>");
            }
            htmlBuilder.Append("</div>");
            litWeeklyChart.Text = htmlBuilder.ToString();
        }

        private void BuildQuizPerformance(SqlConnection conn, string studentId)
        {
            string col;
            if (CurrentLanguage == "BM")
            {
                col = "u.unitNameBM";
            }
            else
            {
                col = "u.unitNameEN";
            }
            string sql = string.Format(@"SELECT {0} AS unitName, AVG(qr.percentage) AS avgPct, MAX(qr.percentage) AS bestPct
                FROM QuizResult qr INNER JOIN Quiz q ON q.quizId=qr.quizId INNER JOIN Unit u ON u.unitId=q.unitId
                WHERE qr.studentId=@s GROUP BY {0} ORDER BY bestPct DESC", col);

            DataTable dataTable = new DataTable();
            using (SqlCommand command = new SqlCommand(sql, conn))
            {
                command.Parameters.AddWithValue("@s", studentId);
                new SqlDataAdapter(command).Fill(dataTable);
            }
            if (dataTable.Rows.Count == 0)
            {
                pnlQuizPerf.Visible = false;
                pnlNoQuizPerf.Visible = true;
                litNoQuizPerf.Text = T("No quiz attempts yet. Take a quiz to see your performance!", "Tiada percubaan kuiz lagi. Jawab kuiz untuk melihat prestasi anda!");
                return;
            }

            System.Text.StringBuilder htmlBuilder = new System.Text.StringBuilder("<div class=\"st-progress-quiz-perf-list\">");
            foreach (DataRow row in dataTable.Rows)
            {
                string name;
                if (row["unitName"] != DBNull.Value)
                {
                    name = row["unitName"].ToString();
                }
                else
                {
                    name = "\u2014";
                }

                int best;
                if (row["bestPct"] != DBNull.Value)
                {
                    best = (int)Convert.ToDecimal(row["bestPct"]);
                }
                else
                {
                    best = 0;
                }

                string cls, lbl;
                if (best >= 80)
                {
                    cls = "excellent";
                    lbl = T("Excellent", "Cemerlang");
                }
                else if (best >= 60)
                {
                    cls = "good";
                    lbl = T("Good", "Baik");
                }
                else
                {
                    cls = "needs-revision";
                    lbl = T("Needs Revision", "Perlu Ulangkaji");
                }

                htmlBuilder.Append("<div class=\"st-progress-quiz-perf-item\">");
                htmlBuilder.AppendFormat("<div class=\"st-progress-quiz-perf-info\"><span class=\"st-progress-quiz-perf-name\">{0}</span><span class=\"st-progress-quiz-perf-badge {1}\">{2}</span></div>", HttpUtility.HtmlEncode(name), cls, lbl);
                htmlBuilder.AppendFormat("<div class=\"st-progress-quiz-perf-bar-wrap\"><div class=\"st-progress-quiz-perf-bar {0}\" style=\"width:{1}%;\"></div></div>", cls, best);
                htmlBuilder.AppendFormat("<div class=\"st-progress-quiz-perf-pct\">{0}%</div>", best);
                htmlBuilder.Append("</div>");
            }
            htmlBuilder.Append("</div>");
            litQuizPerfContent.Text = htmlBuilder.ToString();
        }

        private void BuildWeakTopics(SqlConnection conn, string studentId)
        {
            string col;
            if (CurrentLanguage == "BM")
            {
                col = "st.subtopicTitleBM";
            }
            else
            {
                col = "st.subtopicTitleEN";
            }
            string sql = string.Format(@"SELECT TOP 3 {0} AS subtopicName, COUNT(*) AS wrongCount
                FROM QuizAnswer qa INNER JOIN QuizResult qr ON qr.resultId=qa.resultId
                INNER JOIN Question q ON q.questionId=qa.questionId
                INNER JOIN Subtopic st ON st.subtopicId=q.subtopicId
                WHERE qr.studentId=@s AND qa.isCorrect=0
                GROUP BY {0} ORDER BY COUNT(*) DESC", col);

            DataTable dataTable = new DataTable();
            using (SqlCommand command = new SqlCommand(sql, conn))
            {
                command.Parameters.AddWithValue("@s", studentId);
                new SqlDataAdapter(command).Fill(dataTable);
            }
            if (dataTable.Rows.Count == 0)
            {
                pnlWeakTopics.Visible = false;
                pnlNoWeakTopics.Visible = true;
                litNoWeakTopics.Text = T("No weak topics found yet. Keep attempting quizzes!", "Tiada topik lemah ditemui lagi. Teruskan menjawab kuiz!");
                return;
            }

            string reviewText = T("Review Lesson", "Ulangkaji Pelajaran");
            System.Text.StringBuilder htmlBuilder = new System.Text.StringBuilder("<div class=\"st-progress-weak-list\">");
            foreach (DataRow row in dataTable.Rows)
            {
                string name;
                if (row["subtopicName"] != DBNull.Value)
                {
                    name = row["subtopicName"].ToString();
                }
                else
                {
                    name = "\u2014";
                }
                int cnt = Convert.ToInt32(row["wrongCount"]);
                htmlBuilder.Append("<div class=\"st-progress-weak-item\">");
                htmlBuilder.AppendFormat("<div class=\"st-progress-weak-info\"><div class=\"st-progress-weak-name\"><i class=\"bi bi-exclamation-circle\"></i> {0}</div><div class=\"st-progress-weak-count\">{1} {2}</div></div>",
                    HttpUtility.HtmlEncode(name), cnt, T("wrong answers", "jawapan salah"));
                htmlBuilder.AppendFormat("<a href=\"{0}\" class=\"st-progress-weak-btn\"><i class=\"bi bi-arrow-repeat\"></i> {1}</a>", ResolveUrl("~/Student/MyLearning.aspx"), reviewText);
                htmlBuilder.Append("</div>");
            }
            htmlBuilder.Append("</div>");
            litWeakTopicsContent.Text = htmlBuilder.ToString();
        }

        private void LoadBadges(SqlConnection conn, string studentId)
        {
            string sql = @"SELECT b.badgeId,b.badgeNameEN,b.badgeNameBM,b.badgeDescriptionEN,b.badgeDescriptionBM,b.badgeIcon,
                sb.studentBadgeId,sb.earnedAt FROM Badge b LEFT JOIN StudentBadge sb ON sb.badgeId=b.badgeId AND sb.studentId=@s
                ORDER BY CASE WHEN sb.studentBadgeId IS NOT NULL THEN 0 ELSE 1 END, b.badgeId";
            DataTable dataTable = new DataTable();
            using (SqlCommand command = new SqlCommand(sql, conn))
            {
                command.Parameters.AddWithValue("@s", studentId);
                new SqlDataAdapter(command).Fill(dataTable);
            }
            if (dataTable.Rows.Count == 0)
            {
                pnlBadges.Visible = false;
                pnlNoBadges.Visible = true;
                litNoBadges.Text = T("No badges available yet.", "Tiada lencana tersedia lagi.");
                return;
            }

            bool isBM = CurrentLanguage == "BM";
            string earnedLbl = T("Earned", "Diperoleh");
            string lockedLbl = T("Locked", "Dikunci");
            List<object> list = new List<object>();
            foreach (DataRow row in dataTable.Rows)
            {
                bool earned = row["studentBadgeId"] != DBNull.Value;
                string name;
                if (isBM)
                {
                    name = row["badgeNameBM"] != null ? row["badgeNameBM"].ToString() : "";
                    if (string.IsNullOrEmpty(name))
                    {
                        name = row["badgeNameEN"] != null ? row["badgeNameEN"].ToString() : "";
                    }
                }
                else
                {
                    name = row["badgeNameEN"] != null ? row["badgeNameEN"].ToString() : "";
                }

                string desc;
                if (isBM)
                {
                    desc = row["badgeDescriptionBM"] != null ? row["badgeDescriptionBM"].ToString() : "";
                    if (string.IsNullOrEmpty(desc))
                    {
                        desc = row["badgeDescriptionEN"] != null ? row["badgeDescriptionEN"].ToString() : "";
                    }
                }
                else
                {
                    desc = row["badgeDescriptionEN"] != null ? row["badgeDescriptionEN"].ToString() : "";
                }

                string icon;
                if (row["badgeIcon"] != DBNull.Value)
                {
                    icon = row["badgeIcon"].ToString();
                }
                else
                {
                    icon = "";
                }

                string iconUrl = "";
                if (!string.IsNullOrWhiteSpace(icon))
                {
                    if (icon.StartsWith("~/"))
                    {
                        iconUrl = ResolveUrl(icon);
                    }
                    else if (icon.StartsWith("Images/"))
                    {
                        iconUrl = ResolveUrl("~/" + icon);
                    }
                    else
                    {
                        iconUrl = ResolveUrl("~/Images/Badge/" + icon);
                    }
                }

                string earnedDate = "";
                if (earned && row["earnedAt"] != DBNull.Value)
                {
                    earnedDate = Convert.ToDateTime(row["earnedAt"]).ToString("dd MMM yyyy");
                }

                string earnedText;
                if (earned && !string.IsNullOrEmpty(earnedDate))
                {
                    earnedText = earnedLbl + " &bull; " + earnedDate;
                }
                else
                {
                    earnedText = earnedLbl;
                }

                list.Add(new { Name = HttpUtility.HtmlEncode(name), Description = HttpUtility.HtmlEncode(desc), IconUrl = iconUrl, IsEarned = earned, EarnedText = earnedText, LockedText = lockedLbl });
            }
            rptBadges.DataSource = list;
            rptBadges.DataBind();
        }

        private void BuildCertificates(SqlConnection conn, string studentId)
        {
            string lvCol;
            if (CurrentLanguage == "BM")
            {
                lvCol = "l.levelNameBM";
            }
            else
            {
                lvCol = "l.levelNameEN";
            }

            string ctCol;
            if (CurrentLanguage == "BM")
            {
                ctCol = "c.certificateTitleBM";
            }
            else
            {
                ctCol = "c.certificateTitleEN";
            }

            string sql = string.Format(@"SELECT l.levelId, {0} AS levelName, {1} AS certTitle, c.issuedDate, c.status AS certStatus, c.certificateUrl, c.certificateCode
                FROM Level l LEFT JOIN Certificate c ON c.levelId=l.levelId AND c.studentId=@s ORDER BY l.levelId", lvCol, ctCol);
            DataTable dataTable = new DataTable();
            using (SqlCommand command = new SqlCommand(sql, conn))
            {
                command.Parameters.AddWithValue("@s", studentId);
                new SqlDataAdapter(command).Fill(dataTable);
            }

            System.Text.StringBuilder htmlBuilder = new System.Text.StringBuilder("<div class=\"st-progress-cert-grid\">");
            if (dataTable.Rows.Count == 0)
            {
                htmlBuilder.Append("<div class=\"st-progress-empty-state\"><i class=\"bi bi-file-earmark-check\"></i><p>");
                htmlBuilder.Append(T("Complete levels to unlock certificates!", "Selesaikan tahap untuk membuka sijil!"));
                htmlBuilder.Append("</p></div>");
            }
            else
            {
                string viewText = T("View Certificate", "Lihat Sijil");
                string downloadText = T("Download Certificate", "Muat Turun Sijil");
                string pendingText = T("Certificate pending approval", "Sijil menunggu kelulusan");
                string lockedText = T("Complete level to unlock", "Selesaikan tahap untuk membuka sijil");

                foreach (DataRow row in dataTable.Rows)
                {
                    string levelName;
                    if (row["levelName"] != DBNull.Value)
                    {
                        levelName = row["levelName"].ToString();
                    }
                    else
                    {
                        levelName = "\u2014";
                    }
                    bool hasCert = row["certTitle"] != DBNull.Value;
                    string certStatus = "";
                    if (hasCert)
                    {
                        certStatus = row["certStatus"] != null ? row["certStatus"].ToString() : "";
                    }

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
                            if (rawUrl.StartsWith("~/"))
                            {
                                certUrl = ResolveUrl(rawUrl);
                            }
                            else if (rawUrl.StartsWith("Images/"))
                            {
                                certUrl = ResolveUrl("~/" + rawUrl);
                            }
                            else
                            {
                                certUrl = ResolveUrl("~/Images/Certificate/" + rawUrl);
                            }
                        }
                    }
                    bool canView = !string.IsNullOrEmpty(certUrl);

                    htmlBuilder.AppendFormat("<div class=\"st-progress-cert-card {0}\">", isAvailable ? "earned" : "locked");
                    string certIcon;
                    if (isAvailable)
                    {
                        certIcon = "bi-file-earmark-check-fill";
                    }
                    else if (isPending)
                    {
                        certIcon = "bi-hourglass-split";
                    }
                    else
                    {
                        certIcon = "bi-lock-fill";
                    }
                    htmlBuilder.AppendFormat("<div class=\"st-progress-cert-icon-wrap\"><i class=\"bi {0}\"></i></div>", certIcon);
                    htmlBuilder.AppendFormat("<div class=\"st-progress-cert-level\">{0}</div>", HttpUtility.HtmlEncode(levelName));

                    if (isAvailable)
                    {
                        string certTitle = row["certTitle"].ToString();
                        string issuedDate = "";
                        if (row["issuedDate"] != DBNull.Value)
                        {
                            issuedDate = Convert.ToDateTime(row["issuedDate"]).ToString("dd MMM yyyy");
                        }
                        htmlBuilder.AppendFormat("<div class=\"st-progress-cert-title\">{0}</div>", HttpUtility.HtmlEncode(certTitle));
                        if (!string.IsNullOrEmpty(issuedDate))
                        {
                            htmlBuilder.AppendFormat("<div class=\"st-progress-cert-date\"><i class=\"bi bi-calendar3\"></i> {0}</div>", issuedDate);
                        }
                        if (canView)
                        {
                            htmlBuilder.AppendFormat("<button type=\"button\" class=\"st-progress-cert-download\" onclick=\"openCertModal('{0}')\"><i class=\"bi bi-eye-fill\"></i> {1}</button>", HttpUtility.JavaScriptStringEncode(certUrl), viewText);
                        }
                    }
                    else if (isPending)
                    {
                        htmlBuilder.AppendFormat("<div class=\"st-progress-cert-pending\">{0}</div>", pendingText);
                    }
                    else
                    {
                        htmlBuilder.AppendFormat("<div class=\"st-progress-cert-locked-msg\">{0}</div>", lockedText);
                    }
                    htmlBuilder.Append("</div>");
                }
            }
            htmlBuilder.Append("</div>");
            litCertContent.Text = htmlBuilder.ToString();
        }

        private void BuildAIHint(SqlConnection conn, string studentId)
        {
            string col;
            if (CurrentLanguage == "BM")
            {
                col = "u.unitNameBM";
            }
            else
            {
                col = "u.unitNameEN";
            }
            string sql = string.Format(@"SELECT {0} AS unitName, AVG(qr.percentage) AS avgPct FROM QuizResult qr
                INNER JOIN Quiz q ON q.quizId=qr.quizId INNER JOIN Unit u ON u.unitId=q.unitId
                WHERE qr.studentId=@s GROUP BY {0} ORDER BY avgPct", col);
            DataTable dataTable = new DataTable();
            using (SqlCommand command = new SqlCommand(sql, conn))
            {
                command.Parameters.AddWithValue("@s", studentId);
                new SqlDataAdapter(command).Fill(dataTable);
            }

            if (dataTable.Rows.Count < 1)
            {
                pnlAIHint.Visible = false;
                return;
            }

            string weakest;
            if (dataTable.Rows[0]["unitName"] != null)
            {
                weakest = dataTable.Rows[0]["unitName"].ToString();
            }
            else
            {
                weakest = "\u2014";
            }

            string strongest;
            if (dataTable.Rows[dataTable.Rows.Count - 1]["unitName"] != null)
            {
                strongest = dataTable.Rows[dataTable.Rows.Count - 1]["unitName"].ToString();
            }
            else
            {
                strongest = "\u2014";
            }

            if (dataTable.Rows.Count == 1)
            {
                litAIHintText.Text = T("Keep practising <strong>" + HttpUtility.HtmlEncode(weakest) + "</strong> to improve your score!",
                    "Teruskan berlatih <strong>" + HttpUtility.HtmlEncode(weakest) + "</strong> untuk meningkatkan markah!");
            }
            else
            {
                litAIHintText.Text = T("You're doing great in <strong>" + HttpUtility.HtmlEncode(strongest) + "</strong>! Buddy suggests revising <strong>" + HttpUtility.HtmlEncode(weakest) + "</strong> before your next quiz.",
                    "Anda cemerlang dalam <strong>" + HttpUtility.HtmlEncode(strongest) + "</strong>! Buddy cadangkan ulangkaji <strong>" + HttpUtility.HtmlEncode(weakest) + "</strong> sebelum kuiz seterusnya.");
            }
        }

        private string GetStudentId(SqlConnection conn)
        {
            string uid = Session["userId"] as string;
            if (string.IsNullOrEmpty(uid))
            {
                return null;
            }
            using (SqlCommand command = new SqlCommand("SELECT studentId FROM Student WHERE userId=@u", conn))
            {
                command.Parameters.AddWithValue("@u", uid);
                object result = command.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                {
                    return result.ToString();
                }
                return null;
            }
        }

        private int GetInt(SqlConnection conn, string sql, string studentId)
        {
            using (SqlCommand command = new SqlCommand(sql, conn))
            {
                command.Parameters.AddWithValue("@s", studentId);
                object result = command.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                {
                    return Convert.ToInt32(result);
                }
                return 0;
            }
        }

        private static bool Tbl(SqlConnection conn, string t)
        {
            using (SqlCommand command = new SqlCommand("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME=@t AND TABLE_TYPE='BASE TABLE'", conn))
            {
                command.Parameters.AddWithValue("@t", t);
                return (int)command.ExecuteScalar() > 0;
            }
        }
    }
}
