using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace ScienceBuddy.Student
{
    public partial class Dashboard : Page
    {
        // ── Connection string ─────────────────────────────────────────
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        // ── Language helper ────────────────────────────────────────────
        private string CurrentLanguage = "EN";

        // ── Personality colour for ASPX hero styling ──────────────────
        public string PersonalityColour = "#2563EB";

        private string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        // ── Page Load ─────────────────────────────────────────────────
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null ||
                Session["role"].ToString() != "Student")
            {
                Response.Redirect("~/Login.aspx", false);
                return;
            }

            var master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                InitLanguage();
                LoadDashboard(Session["userId"].ToString());
            }
        }

        /// <summary>
        /// Reads language from Session → DB → defaults to EN.
        /// </summary>
        private void InitLanguage()
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
                    const string sql = "SELECT preferredLanguage FROM [User] WHERE userId = @userId";
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
            Session["preferredLanguage"] = "EN";
        }

        // ── Load all dashboard data ───────────────────────────────────
        private void LoadDashboard(string userId)
        {
            // All data fetched in a single open connection for efficiency.
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                var studentData = GetStudentData(conn, userId);
                if (studentData == null)
                {
                    SetHero("Student", "Student", "Beginner", "🔬", null, null, null, "EN");
                    SetStats("Beginner", 0, 0, 0);
                    ShowContinueEmpty();
                    ShowNotificationsEmpty();
                    SetPersonalityCard(null, "Learner", null, null, "EN");
                    ApplyPersonalityOrder(null);
                    SetBilingualLabels();
                    return;
                }

                string studentId   = studentData["studentId"].ToString();
                string name        = studentData["name"].ToString();
                string nickname    = studentData["nickname"].ToString();
                int    xp          = studentData["XP"] == DBNull.Value ? 0 : Convert.ToInt32(studentData["XP"]);
                string levelId     = studentData["currentlevelId"]?.ToString();
                string levelEN     = studentData["levelNameEN"]?.ToString()  ?? "Beginner";
                string personalityId = studentData["personalityId"]?.ToString();
                string personalityEN = studentData["personalityNameEN"]?.ToString() ?? "Learner";
                string avatar      = studentData["avatar"]?.ToString();
                string colour      = studentData["colour"]?.ToString() ?? "#F5F5F5";
                string lang        = studentData["preferredLanguage"]?.ToString() ?? "EN";

                // Counts
                int badgeCount  = GetBadgeCount(conn, studentId);
                int lessonCount = GetLessonCount(conn, studentId);

                // Hero + master user widget
                SetHero(name, nickname, levelEN, personalityEN, avatar, colour, personalityId, lang);
                SetStats(levelEN, xp, badgeCount, lessonCount);

                var master = (ScienceBuddy.SiteMaster)Master;
                string initials = GetInitials(string.IsNullOrWhiteSpace(nickname) ? name : nickname);
                master.SetUserInfo(string.IsNullOrWhiteSpace(nickname) ? name : nickname, "Student", initials);

                // Continue learning
                LoadContinueLearning(conn, studentId, lang);

                // Notifications
                int unread = GetUnreadNotifCount(conn, userId);
                LoadNotifications(conn, userId, lang, unread);

                // Personality recommendation banner + section ordering
                SetPersonalityCard(personalityId, personalityEN, avatar, colour, lang);
                ApplyPersonalityOrder(personalityId);

                // Sidebar unread badge
                if (unread > 0)
                {
                    pnlNotifBadge.Visible = true;
                    litNotifCount.Text    = unread > 99 ? "99+" : unread.ToString();
                }

                // Set all remaining bilingual UI labels
                SetBilingualLabels();
            }
        }

        /// <summary>
        /// Sets all remaining bilingual dashboard text that uses T().
        /// Called once during LoadDashboard after CurrentLanguage is set.
        /// </summary>
        private void SetBilingualLabels()
        {
            // Section headings
            litSecContinue.Text     = T("Continue Learning", "Teruskan Pembelajaran");
            litSecQuick.Text        = T("Quick Actions", "Tindakan Pantas");
            litSecNotif.Text        = T("Recent Notifications", "Pemberitahuan Terkini");
            litSecSocial.Text       = T("Learn Together", "Belajar Bersama");
            litRecLabel.Text        = T("✨ Recommended for your learning style", "✨ Disyorkan untuk gaya pembelajaran anda");

            // Quick action labels
            litQALearn.Text         = T("My Learning", "Pembelajaran Saya");
            litQALearnDesc.Text     = T("Lessons, subtopics &amp; units", "Pelajaran, subtopik &amp; unit");
            litQAPractice.Text      = T("Practice Library", "Perpustakaan Latihan");
            litQAPracticeDesc.Text  = T("Quizzes &amp; self-assessment", "Kuiz &amp; penilaian kendiri");
            litQALab.Text           = T("Virtual Labs", "Makmal Maya");
            litQALabDesc.Text       = T("Interactive science experiments", "Eksperimen Sains interaktif");
            litQALive.Text          = T("Live Sessions", "Sesi Langsung");
            litQALiveDesc.Text      = T("Join teacher-led classes", "Sertai kelas yang dipimpin guru");
            litQAAI.Text            = T("AI Study Companion", "Rakan Belajar AI");
            litQAAIDesc.Text        = T("Personalised help &amp; hints", "Bantuan &amp; petunjuk peribadi");
            litQAProgress.Text      = T("Progress &amp; Rewards", "Kemajuan &amp; Ganjaran");
            litQAProgressDesc.Text  = T("XP, badges &amp; achievements", "XP, lencana &amp; pencapaian");
            litQAHistory.Text       = T("Quiz History", "Sejarah Kuiz");
            litQAHistoryDesc.Text   = T("Past attempts &amp; scores", "Percubaan &amp; skor terdahulu");

            // Continue learning card
            litContinueHeader.Text  = T("Pick up where you left off", "Sambung dari tempat anda berhenti");
            litContinueMeta.Text    = T("Next Lesson", "Pelajaran Seterusnya");
            litContinueBtn.Text     = T("Continue Learning", "Teruskan Belajar");

            // Empty states
            litEmptyTitle.Text      = T("Ready to begin your adventure?", "Bersedia untuk memulakan pengembaraan?");
            litEmptyDesc.Text       = T("You haven't started any lessons yet. Dive in and discover science!", "Anda belum memulakan sebarang pelajaran. Mulakan dan terokai Sains!");
            litEmptyBtn.Text        = T("Start Learning", "Mula Belajar");
            litNotifEmpty.Text      = T("You're all caught up!", "Tiada pemberitahuan baharu!");
            litNotifEmptyDesc.Text  = T("No new notifications right now. Check back later.", "Tiada pemberitahuan baharu. Semak semula nanti.");

            // XP bar
            litXPBarProgress.Text   = T("Level Progress", "Kemajuan Tahap");

            // Hero CTA buttons
            litHeroCTA1.Text        = T("Continue Learning", "Teruskan Belajar");
            litHeroCTA2.Text        = T("My Progress", "Kemajuan Saya");

            // Hero eyebrow
            litHeroEyebrow.Text     = T("Science Learning", "Pembelajaran Sains");

            // View All links
            litViewAll.Text         = T("View All", "Lihat Semua");
            litSeeAll.Text          = T("See All", "Lihat Semua");
        }

        // ── Data retrieval helpers ────────────────────────────────────

        /// <summary>
        /// Returns a single row joining Student + Level + Personality + User.
        /// Uses Student.userId = @userId to ensure no cross-student access.
        /// </summary>
        private DataRow GetStudentData(SqlConnection conn, string userId)
        {
            const string sql = @"
                SELECT  s.studentId, s.name, s.nickname, s.XP,
                        s.currentlevelId, s.personalityId,
                        lv.levelNameEN, lv.levelNameBM,
                        p.personalityNameEN, p.personalityNameBM,
                        p.avatar, p.colour,
                        p.learningStyleEN, p.learningStyleBM,
                        u.preferredLanguage
                FROM    Student  s
                JOIN    [User]   u  ON u.userId        = s.userId
                LEFT JOIN Level  lv ON lv.levelId      = s.currentlevelId
                LEFT JOIN Personality p ON p.personalityId = s.personalityId
                WHERE   s.userId = @userId";

            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                var da = new SqlDataAdapter(cmd);
                var dt = new DataTable();
                da.Fill(dt);
                return dt.Rows.Count > 0 ? dt.Rows[0] : null;
            }
        }

        private int GetBadgeCount(SqlConnection conn, string studentId)
        {
            if (!TableExists(conn, "StudentBadge")) return 0;
            const string sql = "SELECT COUNT(*) FROM StudentBadge WHERE studentId = @studentId";
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@studentId", studentId);
                return (int)cmd.ExecuteScalar();
            }
        }

        private int GetLessonCount(SqlConnection conn, string studentId)
        {
            if (!TableExists(conn, "LessonProgress")) return 0;
            const string sql = @"
                SELECT COUNT(*) FROM LessonProgress
                WHERE  studentId   = @studentId
                AND    isCompleted = 1";
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@studentId", studentId);
                return (int)cmd.ExecuteScalar();
            }
        }

        private int GetUnreadNotifCount(SqlConnection conn, string userId)
        {
            if (!TableExists(conn, "Notification")) return 0;
            const string sql = @"
                SELECT COUNT(*) FROM Notification
                WHERE  toUserId = @userId AND isRead = 0";
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                return (int)cmd.ExecuteScalar();
            }
        }

        private void LoadContinueLearning(SqlConnection conn, string studentId, string lang)
        {
            // If Lesson/Subtopic/Unit tables don't exist yet, show empty state.
            if (!TableExists(conn, "Lesson") ||
                !TableExists(conn, "Subtopic") ||
                !TableExists(conn, "Unit"))
            {
                ShowContinueEmpty();
                return;
            }

            // Find the first lesson not yet completed by this student.
            string sql = @"
                SELECT TOP 1
                    l.lessonId,
                    l.lessonTitleEN, l.lessonTitleBM,
                    st.subtopicTitleEN, st.subtopicTitleBM,
                    un.unitNameEN, un.unitNameBM
                FROM   Lesson   l
                JOIN   Subtopic st ON st.subtopicId = l.subtopicId
                JOIN   Unit     un ON un.unitId      = st.unitId";

            // Only subtract completed lessons if LessonProgress exists.
            if (TableExists(conn, "LessonProgress"))
            {
                sql += @"
                WHERE  l.lessonId NOT IN (
                    SELECT lessonId FROM LessonProgress
                    WHERE  studentId   = @studentId
                    AND    isCompleted = 1
                )";
            }

            sql += " ORDER BY un.orderNo, st.orderNo, l.orderNo";

            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@studentId", studentId);
                var da = new SqlDataAdapter(cmd);
                var dt = new DataTable();
                da.Fill(dt);

                if (dt.Rows.Count == 0)
                {
                    ShowContinueEmpty();
                    return;
                }

                var row       = dt.Rows[0];
                bool isBM     = lang == "BM";
                string title  = isBM ? row["lessonTitleBM"].ToString()    : row["lessonTitleEN"].ToString();
                string unit   = isBM ? row["unitNameBM"].ToString()       : row["unitNameEN"].ToString();
                string sub    = isBM ? row["subtopicTitleBM"].ToString()  : row["subtopicTitleEN"].ToString();

                if (string.IsNullOrWhiteSpace(title)) title = isBM ? row["lessonTitleEN"].ToString() : row["lessonTitleBM"].ToString();

                pnlContinue.Visible      = true;
                pnlContinueEmpty.Visible = false;
                litContinueTitle.Text    = System.Web.HttpUtility.HtmlEncode(title);
                litContinueSub.Text      = System.Web.HttpUtility.HtmlEncode(unit + (string.IsNullOrWhiteSpace(sub) ? "" : " › " + sub));
            }
        }

        private void LoadNotifications(SqlConnection conn, string userId, string lang, int unread = 0)
        {
            if (!TableExists(conn, "Notification"))
            {
                ShowNotificationsEmpty();
                return;
            }

            if (unread > 0)
            {
                pnlUnreadBadge.Visible  = true;
                litUnreadCount.Text     = unread > 99 ? "99+" : unread.ToString();
            }
            const string sql = @"
                SELECT TOP 3
                    notificationId, titleEN, titleBM,
                    messageEN, messageBM, isRead, createdAt
                FROM   Notification
                WHERE  toUserId = @userId
                ORDER  BY createdAt DESC";

            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                var da = new SqlDataAdapter(cmd);
                var dt = new DataTable();
                da.Fill(dt);

                if (dt.Rows.Count == 0)
                {
                    ShowNotificationsEmpty();
                    return;
                }

                bool isBM = lang == "BM";
                var list  = new System.Collections.Generic.List<object>();
                foreach (DataRow row in dt.Rows)
                {
                    string title = isBM ? row["titleBM"].ToString() : row["titleEN"].ToString();
                    if (string.IsNullOrWhiteSpace(title)) title = row["titleEN"].ToString();

                    DateTime created = row["createdAt"] == DBNull.Value
                        ? DateTime.Now
                        : Convert.ToDateTime(row["createdAt"]);

                    list.Add(new
                    {
                        title   = System.Web.HttpUtility.HtmlEncode(title),
                        isRead  = Convert.ToBoolean(row["isRead"]),
                        timeAgo = FormatTimeAgo(created)
                    });
                }

                pnlNotifications.Visible      = true;
                pnlNotificationsEmpty.Visible = false;
                rptNotifications.DataSource   = list;
                rptNotifications.DataBind();
            }
        }

        // ── UI setters ────────────────────────────────────────────────

        private void SetHero(string name, string nickname, string levelEN,
                              string personalityEN, string avatar, string colour,
                              string personalityId, string lang)
        {
            // Set personality colour for hero gradient
            if (!string.IsNullOrWhiteSpace(colour)) PersonalityColour = colour;

            string displayName  = string.IsNullOrWhiteSpace(nickname) ? name : nickname;
            litGreeting.Text    = T("Hi, ", "Hai, ") + System.Web.HttpUtility.HtmlEncode(displayName) + "! 👋";
            litMotivation.Text  = GetMotivation(personalityId);
            litHeroLevel.Text   = T("Level: ", "Tahap: ") + System.Web.HttpUtility.HtmlEncode(levelEN);
            litHeroPersonality.Text  = System.Web.HttpUtility.HtmlEncode(personalityEN);
            litHeroPersonality2.Text = System.Web.HttpUtility.HtmlEncode(personalityEN);

            if (!string.IsNullOrWhiteSpace(avatar))
            {
                // Avatar path from DB may already include "Images/Personality/" or just the filename
                string avatarPath = avatar.StartsWith("~/") ? avatar
                    : avatar.StartsWith("Images/") ? "~/" + avatar
                    : "~/Images/Personality/" + avatar;
                imgPersonalityAvatar.ImageUrl = ResolveUrl(avatarPath);
                imgPersonalityAvatar.Visible  = true;
                // Keep fallback rendered but hidden so JS onerror can show it
                litAvatarFallback.Text = "<span style=\"display:none;\"><i class=\"bi bi-person-hearts\" style=\"font-size:2.5rem;\"></i></span>";
            }
            else
            {
                imgPersonalityAvatar.Visible = false;
                litAvatarFallback.Text = "<i class=\"bi bi-person-hearts\" style=\"font-size:2.5rem;\"></i>";
            }
        }

        private void SetStats(string levelEN, int xp, int badges, int lessons)
        {
            litHeroXP.Text     = xp.ToString("N0") + " XP";
            litStatLevel.Text  = System.Web.HttpUtility.HtmlEncode(levelEN);
            litStatXP.Text     = xp.ToString("N0");
            litStatBadges.Text = badges.ToString();
            litStatLessons.Text = lessons.ToString();

            // XP bar
            litXPBarLabel.Text = xp.ToString("N0") + " XP";
            int pct = Math.Min((xp % 500) * 100 / 500, 100);
            litXPBarHint.Text  = (500 - (xp % 500)) + T(" XP to next milestone", " XP ke pencapaian seterusnya");
            litXPBarPct.Text   = pct.ToString();

            // Bilingual stat labels
            litStatLevelLbl.Text   = T("Current Level", "Tahap Semasa");
            litStatXPLbl.Text      = T("Total XP Earned", "Jumlah XP Diperolehi");
            litStatBadgesLbl.Text  = T("Badges Earned", "Lencana Diperolehi");
            litStatLessonsLbl.Text = T("Lessons Completed", "Pelajaran Selesai");
            litStatLevelSub.Text   = T("Keep going to advance!", "Teruskan untuk maju!");
            litStatXPSub.Text      = T("Every lesson earns XP", "Setiap pelajaran memberi XP");
            litStatBadgesSub.Text  = T("Complete tasks to earn more", "Selesaikan tugasan untuk lebih banyak");
            litStatLessonsSub.Text = T("Great job so far!", "Kerja bagus setakat ini!");
        }

        private void SetPersonalityCard(string personalityId, string personalityEN,
                                        string avatar, string colour, string lang)
        {
            // Banner gradient background based on personality colour
            string bannerBg = string.IsNullOrWhiteSpace(colour)
                ? "linear-gradient(135deg,#2563EB,#4DA8FF)"
                : "linear-gradient(135deg," + colour + ",#4DA8FF)";
            divRecBanner.Style["background"] = bannerBg;

            // Avatar background
            divPersonalityAvatar.Style["background"] =
                string.IsNullOrWhiteSpace(colour) ? "rgba(255,255,255,.2)" : colour;

            litPersonalityName.Text = System.Web.HttpUtility.HtmlEncode(personalityEN ?? "Learner");

            if (!string.IsNullOrWhiteSpace(avatar))
            {
                string avatarPath = avatar.StartsWith("~/") ? avatar
                    : avatar.StartsWith("Images/") ? "~/" + avatar
                    : "~/Images/Personality/" + avatar;
                imgPersonalityThumb.ImageUrl = ResolveUrl(avatarPath);
                imgPersonalityThumb.Visible  = true;
                litPersonalityThumbFallback.Text = "<span style=\"display:none;\"><i class=\"bi bi-person-hearts\" style=\"font-size:1.5rem;\"></i></span>";
            }
            else
            {
                imgPersonalityThumb.Visible = false;
                litPersonalityThumbFallback.Text = "<i class=\"bi bi-person-hearts\" style=\"font-size:1.5rem;\"></i>";
            }

            // Recommendation text and link per personality
            switch (personalityId)
            {
                case "P001":
                    litPersonalityRec.Text        = T("You're a goal-getter! Try your next unit quiz to earn a badge.", "Anda seorang pencapai! Cuba kuiz unit seterusnya untuk memperoleh lencana.");
                    litPersonalityAction.Text     = T("Go to Quiz", "Pergi ke Kuiz");
                    lnkPersonalityAction.NavigateUrl = ResolveUrl("~/Student/Quiz.aspx");
                    break;
                case "P002":
                    litPersonalityRec.Text        = T("Explore science your colourful way! Try a virtual lab.", "Terokai Sains dengan cara kreatif! Cuba makmal maya.");
                    litPersonalityAction.Text     = T("Open Virtual Lab", "Buka Makmal Maya");
                    lnkPersonalityAction.NavigateUrl = "#";
                    break;
                case "P003":
                    litPersonalityRec.Text        = T("Let's understand the why. Review a lesson or quiz explanation.", "Jom fahami sebab. Semak semula pelajaran atau penjelasan kuiz.");
                    litPersonalityAction.Text     = T("Review Lessons", "Semak Pelajaran");
                    lnkPersonalityAction.NavigateUrl = ResolveUrl("~/Student/Learning.aspx");
                    break;
                case "P004":
                    litPersonalityRec.Text        = T("Challenge yourself today! Jump into the practice library.", "Cabar diri anda hari ini! Masuk ke perpustakaan latihan.");
                    litPersonalityAction.Text     = T("Practice Now", "Latihan Sekarang");
                    lnkPersonalityAction.NavigateUrl = ResolveUrl("~/Student/Quiz.aspx");
                    break;
                case "P005":
                    litPersonalityRec.Text        = T("Take it step by step. Continue where you left off.", "Langkah demi langkah. Teruskan dari tempat anda berhenti.");
                    litPersonalityAction.Text     = T("Continue Learning", "Teruskan Belajar");
                    lnkPersonalityAction.NavigateUrl = ResolveUrl("~/Student/Learning.aspx");
                    break;
                case "P006":
                    litPersonalityRec.Text        = T("Learn together! Join a forum discussion or live session.", "Belajar bersama! Sertai perbincangan forum atau sesi langsung.");
                    litPersonalityAction.Text     = T("Go to Forum", "Pergi ke Forum");
                    lnkPersonalityAction.NavigateUrl = ResolveUrl("~/Student/Forum.aspx");
                    break;
                default:
                    litPersonalityRec.Text        = T("Keep exploring science at your own pace!", "Teruskan meneroka Sains mengikut rentak anda!");
                    litPersonalityAction.Text     = T("Start Learning", "Mula Belajar");
                    lnkPersonalityAction.NavigateUrl = ResolveUrl("~/Student/Learning.aspx");
                    break;
            }
        }

        private void ShowContinueEmpty()
        {
            pnlContinue.Visible      = false;
            pnlContinueEmpty.Visible = true;
        }

        private void ShowNotificationsEmpty()
        {
            pnlNotifications.Visible      = false;
            pnlNotificationsEmpty.Visible = true;
        }

        /// <summary>
        /// Sets CSS order on each section Panel so the dashboard reflows
        /// by personality priority without JavaScript or new DB tables.
        /// Sections wrapper is a flex-column — CSS order property controls sequence.
        /// </summary>
        private void ApplyPersonalityOrder(string personalityId)
        {
            // Default order values (1=top … 6=bottom)
            int oRec = 1, oContinue = 2, oQuick = 3, oSocial = 5, oNotif = 4;

            switch (personalityId)
            {
                case "P001": // Achiever: rec(badges/quiz) → stats already at top → continue → quick → notif
                    oRec = 1; oContinue = 3; oQuick = 2; oNotif = 4; oSocial = 5;
                    break;
                case "P002": // Creative: rec(lab) → continue → quick → notif
                    oRec = 1; oContinue = 2; oQuick = 3; oNotif = 4; oSocial = 5;
                    break;
                case "P003": // Thinker: rec(AI/review) → continue → quick → notif
                    oRec = 1; oContinue = 2; oQuick = 3; oNotif = 4; oSocial = 5;
                    break;
                case "P004": // Go-Getter: quick(challenge first) → rec → continue → notif
                    oQuick = 1; oRec = 2; oContinue = 3; oNotif = 4; oSocial = 5;
                    break;
                case "P005": // Chill Learner: continue first → rec → notif → quick
                    oContinue = 1; oRec = 2; oNotif = 3; oQuick = 4; oSocial = 5;
                    break;
                case "P006": // Socializer: social links → continue → rec → notif → quick
                    pnlSectionSocial.Visible = true;
                    oSocial = 1; oContinue = 2; oRec = 3; oNotif = 4; oQuick = 5;
                    break;
                default:     // No personality — safe default
                    oContinue = 1; oRec = 2; oQuick = 3; oNotif = 4; oSocial = 5;
                    break;
            }

            pnlSectionRec.Style["order"]      = oRec.ToString();
            pnlSectionContinue.Style["order"] = oContinue.ToString();
            pnlSectionQuick.Style["order"]    = oQuick.ToString();
            pnlSectionSocial.Style["order"]   = oSocial.ToString();
            pnlSectionNotif.Style["order"]    = oNotif.ToString();
        }

        // ── Utility helpers ───────────────────────────────────────────

        private string GetMotivation(string personalityId)
        {
            switch (personalityId)
            {
                case "P001": return T("Ready to earn your next badge? 🏅", "Bersedia untuk memperoleh lencana seterusnya? 🏅");
                case "P002": return T("Explore science in your own colourful way! 🎨", "Terokai Sains dengan cara kreatif anda sendiri! 🎨");
                case "P003": return T("Let's understand the why behind science. 🔍", "Jom fahami sebab di sebalik konsep Sains. 🔍");
                case "P004": return T("Challenge yourself today! ⚡", "Cabar diri anda hari ini! ⚡");
                case "P005": return T("Take it step by step. You're doing great! 😊", "Belajar langkah demi langkah. Anda sedang melakukan yang terbaik! 😊");
                case "P006": return T("Learn together with friends and teachers! 🤝", "Belajar bersama rakan dan guru! 🤝");
                default:     return T("Ready to explore science today? 🚀", "Bersedia untuk meneroka Sains hari ini? 🚀");
            }
        }

        private static string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "S";
            var parts = name.Trim().Split(' ');
            return parts.Length >= 2
                ? (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper()
                : name[0].ToString().ToUpper();
        }

        private static string FormatTimeAgo(DateTime dt)
        {
            var span = DateTime.Now - dt;
            if (span.TotalMinutes < 1)  return "Just now";
            if (span.TotalHours   < 1)  return (int)span.TotalMinutes + " min ago";
            if (span.TotalDays    < 1)  return (int)span.TotalHours   + " hr ago";
            if (span.TotalDays    < 7)  return (int)span.TotalDays    + " day" + ((int)span.TotalDays == 1 ? "" : "s") + " ago";
            return dt.ToString("d MMM yyyy");
        }

        /// <summary>
        /// Returns true if the given table exists in the current database.
        /// Uses INFORMATION_SCHEMA so it never throws on a missing table.
        /// </summary>
        private static bool TableExists(SqlConnection conn, string tableName)
        {
            const string sql = @"
                SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
                WHERE  TABLE_NAME = @tableName
                AND    TABLE_TYPE = 'BASE TABLE'";
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@tableName", tableName);
                return (int)cmd.ExecuteScalar() > 0;
            }
        }
    }
}
