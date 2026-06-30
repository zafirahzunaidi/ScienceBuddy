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
    public partial class ProgressRewards : Page
    {
        // ── Connection string ─────────────────────────────────────────
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        // ── Language helper ────────────────────────────────────────────
        public string CurrentLanguage = "EN";

        public string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        // ── XP progress percentage (used in aspx) ─────────────────────
        public int XpPercent = 0;

        // ── Page Load ─────────────────────────────────────────────────
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null ||
                Session["role"].ToString() != "Student")
            {
                Response.Redirect("~/Login.aspx", false);
                return;
            }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                InitLang();
                SetLabels();
                LoadPage();
            }
        }

        // ── Language initialisation ───────────────────────────────────
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

        // ── Set bilingual labels ──────────────────────────────────────
        private void SetLabels()
        {
            litPageTitle.Text = T("Progress &amp; Rewards", "Kemajuan &amp; Ganjaran");
            litXpTitle.Text = T("XP Progress", "Kemajuan XP");
            litLessonsLabel.Text = T("Lessons Completed", "Pelajaran Selesai");
            litLabsLabel.Text = T("Labs Completed", "Makmal Selesai");
            litQuizzesLabel.Text = T("Quizzes Attempted", "Kuiz Dijawab");
            litBadgesLabel.Text = T("Badges Earned", "Lencana Diperolehi");
            litCertsLabel.Text = T("Certificates Earned", "Sijil Diperolehi");
            litTotalXPLabel.Text = T("Total XP", "Jumlah XP");
            litBadgeSection.Text = T("Badge Collection", "Koleksi Lencana");
            litActivitySection.Text = T("Recent XP Activity", "Aktiviti XP Terkini");
            litNoActivity.Text = T("No XP activity yet.", "Tiada aktiviti XP lagi.");
            litCertSection.Text = T("Certificates", "Sijil");
            litNoCerts.Text = T("No certificates yet.", "Tiada sijil lagi.");
            litNavRanking.Text = T("View Ranking", "Lihat Kedudukan");
            litNavLearning.Text = T("Continue Learning", "Teruskan Pembelajaran");
            litNavPractice.Text = T("Practice Library", "Perpustakaan Latihan");
            litNavLabs.Text = T("Virtual Labs", "Makmal Maya");
            litHeroMotivate.Text = T("Amazing progress!", "Kemajuan yang hebat!");
        }

        // ── Main data loading ─────────────────────────────────────────
        private void LoadPage()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Get studentId
                string studentId = GetStudentId(conn);
                if (string.IsNullOrEmpty(studentId))
                {
                    litHeroName.Text = T("Welcome, Student!", "Selamat Datang, Pelajar!");
                    return;
                }

                // 1. Get student info
                int xp = 0;
                string studentName = "";
                string nickname = "";
                string currentLevelId = "";
                string personalityId = "";

                if (Tbl(conn, "Student"))
                {
                    const string sqlStudent = @"
                        SELECT studentId, name, nickname, XP, currentlevelId, personalityId
                        FROM   Student
                        WHERE  studentId = @s";
                    using (var cmd = new SqlCommand(sqlStudent, conn))
                    {
                        cmd.Parameters.AddWithValue("@s", studentId);
                        using (var rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                studentName = rdr["name"] != DBNull.Value ? rdr["name"].ToString() : "";
                                nickname = rdr["nickname"] != DBNull.Value ? rdr["nickname"].ToString() : "";
                                xp = rdr["XP"] != DBNull.Value ? Convert.ToInt32(rdr["XP"]) : 0;
                                currentLevelId = rdr["currentlevelId"] != DBNull.Value ? rdr["currentlevelId"].ToString() : "";
                                personalityId = rdr["personalityId"] != DBNull.Value ? rdr["personalityId"].ToString() : "";
                            }
                        }
                    }
                }

                // 2. Get level name
                string levelName = "";
                if (!string.IsNullOrEmpty(currentLevelId) && Tbl(conn, "Level"))
                {
                    string sqlLevel = CurrentLanguage == "BM"
                        ? "SELECT levelNameBM FROM Level WHERE levelId = @lid"
                        : "SELECT levelNameEN FROM Level WHERE levelId = @lid";
                    using (var cmd = new SqlCommand(sqlLevel, conn))
                    {
                        cmd.Parameters.AddWithValue("@lid", currentLevelId);
                        object result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                            levelName = result.ToString();
                    }
                }

                // 3. Get personality name
                string personalityName = "";
                if (!string.IsNullOrEmpty(personalityId) && Tbl(conn, "Personality"))
                {
                    string sqlPers = CurrentLanguage == "BM"
                        ? "SELECT personalityNameBM FROM Personality WHERE personalityId = @pid"
                        : "SELECT personalityNameEN FROM Personality WHERE personalityId = @pid";
                    using (var cmd = new SqlCommand(sqlPers, conn))
                    {
                        cmd.Parameters.AddWithValue("@pid", personalityId);
                        object result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                            personalityName = result.ToString();
                    }
                }

                // 4. Set hero section
                string displayName = !string.IsNullOrEmpty(nickname) ? nickname : studentName;
                litHeroName.Text = HttpUtility.HtmlEncode(displayName);
                litHeroLevel.Text = HttpUtility.HtmlEncode(levelName);
                litHeroXP.Text = xp.ToString("N0");
                litHeroPersonality.Text = HttpUtility.HtmlEncode(personalityName);
                litTotalXP.Text = xp.ToString("N0");

                // 5. Set XP progress bar (milestones: 100, 250, 500, 1000)
                int[] milestones = { 100, 250, 500, 1000 };
                int nextMilestone = milestones[milestones.Length - 1];
                int prevMilestone = 0;
                foreach (int m in milestones)
                {
                    if (xp < m)
                    {
                        nextMilestone = m;
                        break;
                    }
                    prevMilestone = m;
                }
                if (xp >= milestones[milestones.Length - 1])
                {
                    // Beyond all milestones — show full bar
                    prevMilestone = 0;
                    nextMilestone = xp;
                    XpPercent = 100;
                }
                else
                {
                    int range = nextMilestone - prevMilestone;
                    int progress = xp - prevMilestone;
                    XpPercent = range > 0 ? (int)((double)progress / range * 100) : 0;
                    if (XpPercent < 2) XpPercent = 2;
                }

                litXpCurrent.Text = xp.ToString("N0") + " XP";
                litXpNext.Text = nextMilestone.ToString("N0") + " XP";
                litXpMilestone.Text = T("Next Milestone", "Pencapaian Seterusnya") + ": " + nextMilestone.ToString("N0") + " XP";

                // 6. Count lessons completed
                int lessonsCount = 0;
                if (Tbl(conn, "LessonProgress"))
                {
                    const string sqlLessons = "SELECT COUNT(*) FROM LessonProgress WHERE studentId = @s AND isCompleted = 1";
                    using (var cmd = new SqlCommand(sqlLessons, conn))
                    {
                        cmd.Parameters.AddWithValue("@s", studentId);
                        lessonsCount = (int)cmd.ExecuteScalar();
                    }
                }
                litLessonsCount.Text = lessonsCount.ToString();

                // 7. Count labs completed
                int labsCount = 0;
                if (Tbl(conn, "LabProgress"))
                {
                    const string sqlLabs = "SELECT COUNT(*) FROM LabProgress WHERE studentId = @s AND isCompleted = 1";
                    using (var cmd = new SqlCommand(sqlLabs, conn))
                    {
                        cmd.Parameters.AddWithValue("@s", studentId);
                        labsCount = (int)cmd.ExecuteScalar();
                    }
                }
                litLabsCount.Text = labsCount.ToString();

                // 8. Count quiz attempts
                int quizCount = 0;
                if (Tbl(conn, "QuizResult"))
                {
                    const string sqlQuiz = "SELECT COUNT(*) FROM QuizResult WHERE studentId = @s";
                    using (var cmd = new SqlCommand(sqlQuiz, conn))
                    {
                        cmd.Parameters.AddWithValue("@s", studentId);
                        quizCount = (int)cmd.ExecuteScalar();
                    }
                }
                litQuizzesCount.Text = quizCount.ToString();

                // 9. Count badges earned
                int badgesCount = 0;
                if (Tbl(conn, "StudentBadge"))
                {
                    const string sqlBadges = "SELECT COUNT(*) FROM StudentBadge WHERE studentId = @s";
                    using (var cmd = new SqlCommand(sqlBadges, conn))
                    {
                        cmd.Parameters.AddWithValue("@s", studentId);
                        badgesCount = (int)cmd.ExecuteScalar();
                    }
                }
                litBadgesCount.Text = badgesCount.ToString();

                // 10. Count certificates
                int certsCount = 0;
                if (Tbl(conn, "Certificate"))
                {
                    const string sqlCerts = "SELECT COUNT(*) FROM Certificate WHERE studentId = @s";
                    using (var cmd = new SqlCommand(sqlCerts, conn))
                    {
                        cmd.Parameters.AddWithValue("@s", studentId);
                        certsCount = (int)cmd.ExecuteScalar();
                    }
                }
                litCertsCount.Text = certsCount.ToString();

                // 11. Load badge collection
                LoadBadgeCollection(conn, studentId);

                // 12. Load XP transactions
                LoadXPActivity(conn, studentId);

                // 13. Load certificates
                LoadCertificates(conn, studentId);
            }
        }

        // ── Load badge collection ─────────────────────────────────────
        private void LoadBadgeCollection(SqlConnection conn, string studentId)
        {
            if (!Tbl(conn, "Badge"))
            {
                pnlBadges.Visible = false;
                pnlNoBadges.Visible = true;
                litNoBadges.Text = T("No badges available yet.", "Tiada lencana tersedia lagi.");
                return;
            }

            bool hasStudentBadge = Tbl(conn, "StudentBadge");

            string sql = @"
                SELECT  b.badgeId, b.badgeNameEN, b.badgeNameBM,
                        b.badgeDescriptionEN, b.badgeDescriptionBM,
                        b.requirementDescriptionEN, b.requirementDescriptionBM,
                        b.xpReward, b.badgeIcon, b.badgeType"
                + (hasStudentBadge ? @",
                        sb.studentBadgeId, sb.earnedAt" : @",
                        NULL AS studentBadgeId, NULL AS earnedAt")
                + @"
                FROM    Badge b"
                + (hasStudentBadge ? @"
                LEFT JOIN StudentBadge sb ON sb.badgeId = b.badgeId AND sb.studentId = @s" : "")
                + @"
                ORDER BY b.badgeId";

            using (var cmd = new SqlCommand(sql, conn))
            {
                if (hasStudentBadge)
                    cmd.Parameters.AddWithValue("@s", studentId);

                var da = new SqlDataAdapter(cmd);
                var dt = new DataTable();
                da.Fill(dt);

                if (dt.Rows.Count == 0)
                {
                    pnlBadges.Visible = false;
                    pnlNoBadges.Visible = true;
                    litNoBadges.Text = T("No badges available yet.", "Tiada lencana tersedia lagi.");
                    return;
                }

                pnlBadges.Visible = true;
                pnlNoBadges.Visible = false;

                bool isBM = CurrentLanguage == "BM";
                string earnedText = T("Earned", "Diperolehi");
                string lockedText = T("Locked", "Dikunci");

                var badgeList = new List<object>();
                foreach (DataRow row in dt.Rows)
                {
                    bool isEarned = row["studentBadgeId"] != DBNull.Value;

                    string name = isBM
                        ? (row["badgeNameBM"] != DBNull.Value ? row["badgeNameBM"].ToString() : row["badgeNameEN"].ToString())
                        : (row["badgeNameEN"] != DBNull.Value ? row["badgeNameEN"].ToString() : "");

                    string description = isBM
                        ? (row["badgeDescriptionBM"] != DBNull.Value ? row["badgeDescriptionBM"].ToString() : row["badgeDescriptionEN"]?.ToString() ?? "")
                        : (row["badgeDescriptionEN"] != DBNull.Value ? row["badgeDescriptionEN"].ToString() : "");

                    string requirement = isBM
                        ? (row["requirementDescriptionBM"] != DBNull.Value ? row["requirementDescriptionBM"].ToString() : row["requirementDescriptionEN"]?.ToString() ?? "")
                        : (row["requirementDescriptionEN"] != DBNull.Value ? row["requirementDescriptionEN"].ToString() : "");

                    int xpReward = row["xpReward"] != DBNull.Value ? Convert.ToInt32(row["xpReward"]) : 0;
                    string icon = row["badgeIcon"] != DBNull.Value ? row["badgeIcon"].ToString() : "🎖️";
                    string badgeType = row["badgeType"] != DBNull.Value ? row["badgeType"].ToString() : "";

                    string earnedDate = "";
                    if (isEarned && row["earnedAt"] != DBNull.Value)
                    {
                        earnedDate = Convert.ToDateTime(row["earnedAt"]).ToString("dd MMM yyyy");
                    }

                    badgeList.Add(new
                    {
                        Name = HttpUtility.HtmlEncode(name),
                        Description = HttpUtility.HtmlEncode(description),
                        Requirement = HttpUtility.HtmlEncode(requirement),
                        XpReward = xpReward,
                        Icon = HttpUtility.HtmlEncode(icon),
                        IsEarned = isEarned,
                        EarnedDate = earnedDate,
                        BadgeType = HttpUtility.HtmlEncode(badgeType),
                        EarnedText = earnedText + (isEarned && !string.IsNullOrEmpty(earnedDate) ? " • " + earnedDate : ""),
                        LockedText = lockedText
                    });
                }

                rptBadges.DataSource = badgeList;
                rptBadges.DataBind();
            }
        }

        // ── Load XP Activity ──────────────────────────────────────────
        private void LoadXPActivity(SqlConnection conn, string studentId)
        {
            if (!Tbl(conn, "XPTransaction") || !Tbl(conn, "XPAction"))
            {
                pnlActivity.Visible = false;
                pnlNoActivity.Visible = true;
                return;
            }

            const string sql = @"
                SELECT TOP 10 xt.xpAmount, xt.dateEarned,
                       xa.actionNameEN, xa.actionNameBM
                FROM   XPTransaction xt
                INNER JOIN XPAction xa ON xa.xpActionId = xt.xpActionId
                WHERE  xt.studentId = @s
                ORDER BY xt.dateEarned DESC";

            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@s", studentId);
                var da = new SqlDataAdapter(cmd);
                var dt = new DataTable();
                da.Fill(dt);

                if (dt.Rows.Count == 0)
                {
                    pnlActivity.Visible = false;
                    pnlNoActivity.Visible = true;
                    return;
                }

                pnlActivity.Visible = true;
                pnlNoActivity.Visible = false;

                bool isBM = CurrentLanguage == "BM";

                var activityList = new List<object>();
                foreach (DataRow row in dt.Rows)
                {
                    string actionName = isBM
                        ? (row["actionNameBM"] != DBNull.Value ? row["actionNameBM"].ToString() : row["actionNameEN"].ToString())
                        : (row["actionNameEN"] != DBNull.Value ? row["actionNameEN"].ToString() : "");

                    int xpAmount = row["xpAmount"] != DBNull.Value ? Convert.ToInt32(row["xpAmount"]) : 0;

                    string date = "";
                    if (row["dateEarned"] != DBNull.Value)
                    {
                        date = Convert.ToDateTime(row["dateEarned"]).ToString("dd MMM yyyy");
                    }

                    activityList.Add(new
                    {
                        ActionName = HttpUtility.HtmlEncode(actionName),
                        XpAmount = xpAmount,
                        Date = date
                    });
                }

                rptActivity.DataSource = activityList;
                rptActivity.DataBind();
            }
        }

        // ── Load Certificates ─────────────────────────────────────────
        private void LoadCertificates(SqlConnection conn, string studentId)
        {
            if (!Tbl(conn, "Certificate"))
            {
                pnlCerts.Visible = false;
                pnlNoCerts.Visible = true;
                return;
            }

            bool hasLevel = Tbl(conn, "Level");

            string sql = @"
                SELECT  c.certificateId, c.certificateTitleEN, c.certificateTitleBM,
                        c.certificateDescriptionEN, c.certificateDescriptionBM,
                        c.issuedDate, c.certificateUrl, c.certificateCode, c.status"
                + (hasLevel ? @",
                        l.levelNameEN, l.levelNameBM" : @",
                        NULL AS levelNameEN, NULL AS levelNameBM")
                + @"
                FROM    Certificate c"
                + (hasLevel ? @"
                LEFT JOIN Level l ON l.levelId = c.levelId" : "")
                + @"
                WHERE   c.studentId = @s
                ORDER BY c.issuedDate DESC";

            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@s", studentId);
                var da = new SqlDataAdapter(cmd);
                var dt = new DataTable();
                da.Fill(dt);

                if (dt.Rows.Count == 0)
                {
                    pnlCerts.Visible = false;
                    pnlNoCerts.Visible = true;
                    return;
                }

                pnlCerts.Visible = true;
                pnlNoCerts.Visible = false;

                bool isBM = CurrentLanguage == "BM";
                string viewCertText = T("View Certificate", "Lihat Sijil");

                var certList = new List<object>();
                foreach (DataRow row in dt.Rows)
                {
                    string title = isBM
                        ? (row["certificateTitleBM"] != DBNull.Value ? row["certificateTitleBM"].ToString() : row["certificateTitleEN"]?.ToString() ?? "")
                        : (row["certificateTitleEN"] != DBNull.Value ? row["certificateTitleEN"].ToString() : "");

                    string levelN = isBM
                        ? (row["levelNameBM"] != DBNull.Value ? row["levelNameBM"].ToString() : row["levelNameEN"]?.ToString() ?? "")
                        : (row["levelNameEN"] != DBNull.Value ? row["levelNameEN"].ToString() : "");

                    string issuedDate = "";
                    if (row["issuedDate"] != DBNull.Value)
                    {
                        issuedDate = Convert.ToDateTime(row["issuedDate"]).ToString("dd MMM yyyy");
                    }

                    string url = row["certificateUrl"] != DBNull.Value ? row["certificateUrl"].ToString() : "";
                    bool hasUrl = !string.IsNullOrEmpty(url);

                    certList.Add(new
                    {
                        Title = HttpUtility.HtmlEncode(title),
                        Level = HttpUtility.HtmlEncode(levelN),
                        IssuedDate = issuedDate,
                        Url = HttpUtility.HtmlAttributeEncode(url),
                        HasUrl = hasUrl,
                        ViewText = viewCertText
                    });
                }

                rptCerts.DataSource = certList;
                rptCerts.DataBind();
            }
        }

        // ── Get studentId for the logged-in user ──────────────────────
        private string GetStudentId(SqlConnection conn)
        {
            if (!Tbl(conn, "Student")) return null;
            string userId = Session["userId"] as string;
            if (string.IsNullOrEmpty(userId)) return null;

            const string sql = "SELECT studentId FROM Student WHERE userId = @userId";
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                object result = cmd.ExecuteScalar();
                return result != null && result != DBNull.Value ? result.ToString() : null;
            }
        }

        // ── Table exists helper ───────────────────────────────────────
        /// <summary>
        /// Returns true if the given table exists in the current database.
        /// Uses INFORMATION_SCHEMA so it never throws on a missing table.
        /// </summary>
        private static bool Tbl(SqlConnection conn, string tableName)
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
