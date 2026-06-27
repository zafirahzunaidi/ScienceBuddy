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

        // ── Page Load ─────────────────────────────────────────────────
        protected void Page_Load(object sender, EventArgs e)
        {
            // 1. Authorization
            if (Session["userId"] == null || Session["role"] == null ||
                Session["role"].ToString() != "Student")
            {
                Response.Redirect("~/Login.aspx", false);
                return;
            }

            // 2. Tell master page to use Sidebar layout
            var master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                LoadDashboard(Session["userId"].ToString());
            }
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
            }
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
            string displayName  = string.IsNullOrWhiteSpace(nickname) ? name : nickname;
            litGreeting.Text    = "Hi, " + System.Web.HttpUtility.HtmlEncode(displayName) + "! 👋";
            litMotivation.Text  = GetMotivation(personalityId);
            litHeroLevel.Text   = "Level: " + System.Web.HttpUtility.HtmlEncode(levelEN);
            litHeroPersonality.Text  = System.Web.HttpUtility.HtmlEncode(personalityEN);
            litHeroPersonality2.Text = System.Web.HttpUtility.HtmlEncode(personalityEN);

            if (!string.IsNullOrWhiteSpace(avatar))
            {
                imgPersonalityAvatar.ImageUrl = ResolveUrl("~/Images/Personality/" + avatar);
                imgPersonalityAvatar.Visible  = true;
                litAvatarFallback.Visible     = false;
            }
            else
            {
                imgPersonalityAvatar.Visible = false;
                litAvatarFallback.Text       = "🔬";
                litAvatarFallback.Visible    = true;
            }
        }

        private void SetStats(string levelEN, int xp, int badges, int lessons)
        {
            litHeroXP.Text     = xp.ToString("N0") + " XP";
            litStatLevel.Text  = System.Web.HttpUtility.HtmlEncode(levelEN);
            litStatXP.Text     = xp.ToString("N0");
            litStatBadges.Text = badges.ToString();
            litStatLessons.Text = lessons.ToString();

            // XP bar — simple 0-500 scale per level
            litXPBarLabel.Text = xp.ToString("N0") + " XP";
            int pct = Math.Min((xp % 500) * 100 / 500, 100);
            litXPBarHint.Text  = (500 - (xp % 500)) + " XP to next milestone";
            // Pass pct to the bar via a Literal that writes data-pct
            litXPBarPct.Text   = pct.ToString();
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
                imgPersonalityThumb.ImageUrl = ResolveUrl("~/Images/Personality/" + avatar);
                imgPersonalityThumb.Visible  = true;
                litPersonalityThumbFallback.Visible = false;
            }
            else
            {
                imgPersonalityThumb.Visible = false;
                litPersonalityThumbFallback.Text    = "🧠";
                litPersonalityThumbFallback.Visible = true;
            }

            // Recommendation text and link per personality
            switch (personalityId)
            {
                case "P001": // Achiever
                    litPersonalityRec.Text        = "You're a goal-getter! Try your next unit quiz to earn a badge.";
                    litPersonalityAction.Text     = "Go to Quiz";
                    lnkPersonalityAction.NavigateUrl = ResolveUrl("~/Student/Quiz.aspx");
                    break;
                case "P002": // Creative
                    litPersonalityRec.Text        = "Explore science your colourful way! Try a virtual lab.";
                    litPersonalityAction.Text     = "Open Virtual Lab";
                    lnkPersonalityAction.NavigateUrl = "#";
                    break;
                case "P003": // Thinker
                    litPersonalityRec.Text        = "Let's understand the why. Review a lesson or quiz explanation.";
                    litPersonalityAction.Text     = "Review Lessons";
                    lnkPersonalityAction.NavigateUrl = ResolveUrl("~/Student/Learning.aspx");
                    break;
                case "P004": // Go-Getter
                    litPersonalityRec.Text        = "Challenge yourself today! Jump into the practice library.";
                    litPersonalityAction.Text     = "Practice Now";
                    lnkPersonalityAction.NavigateUrl = ResolveUrl("~/Student/Quiz.aspx");
                    break;
                case "P005": // Chill Learner
                    litPersonalityRec.Text        = "Take it step by step. Continue where you left off.";
                    litPersonalityAction.Text     = "Continue Learning";
                    lnkPersonalityAction.NavigateUrl = ResolveUrl("~/Student/Learning.aspx");
                    break;
                case "P006": // Socializer
                    litPersonalityRec.Text        = "Learn together! Join a forum discussion or live session.";
                    litPersonalityAction.Text     = "Go to Forum";
                    lnkPersonalityAction.NavigateUrl = ResolveUrl("~/Student/Forum.aspx");
                    break;
                default:
                    litPersonalityRec.Text        = "Keep exploring science at your own pace!";
                    litPersonalityAction.Text     = "Start Learning";
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

        private static string GetMotivation(string personalityId)
        {
            switch (personalityId)
            {
                case "P001": return "Ready to earn your next badge? 🏅";
                case "P002": return "Explore science in your own colourful way! 🎨";
                case "P003": return "Let's understand the why behind science. 🔍";
                case "P004": return "Challenge yourself today! ⚡";
                case "P005": return "Take it step by step. You're doing great! 😊";
                case "P006": return "Learn together with friends and teachers! 🤝";
                default:     return "Ready to explore science today? 🚀";
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
