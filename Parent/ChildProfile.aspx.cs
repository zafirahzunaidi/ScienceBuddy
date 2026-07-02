using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace ScienceBuddy.Parent
{
    public partial class ChildProfile : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        protected string CurrentLanguage = "EN";
        protected string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }

        private string _userId = "";
        private string _parentId = "";
        private string _studentId = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null || Session["role"].ToString() != "Parent")
            { Response.Redirect("~/Login.aspx", false); Context.ApplicationInstance.CompleteRequest(); return; }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            _userId = Session["userId"].ToString();
            LoadLanguage();
            LoadParentId();
            ResolveChild();
            SetLabels();

            if (!IsPostBack)
            {
                PopulateSidebarChild();
                if (!string.IsNullOrEmpty(_studentId))
                { pnlProfile.Visible = true; pnlNoChild.Visible = false; LoadAll(); }
                else
                { pnlProfile.Visible = false; pnlNoChild.Visible = true; }
            }
        }

        private void PopulateSidebarChild()
        {
            ddlSidebarChild.Items.Clear();
            if (string.IsNullOrEmpty(_parentId)) return;
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT sp.studentId, s.name, s.nickname FROM dbo.[StudentParent] sp INNER JOIN dbo.[Student] s ON s.studentId=sp.studentId WHERE sp.parentId=@p", conn))
                {
                    cmd.Parameters.AddWithValue("@p", _parentId); conn.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            string sid = r["studentId"]?.ToString() ?? "";
                            string nm = r["nickname"]?.ToString() ?? "";
                            string n = r["name"]?.ToString() ?? "";
                            ddlSidebarChild.Items.Add(new System.Web.UI.WebControls.ListItem(!string.IsNullOrWhiteSpace(nm) ? nm : n, sid));
                        }
                    }
                }
                if (!string.IsNullOrEmpty(_studentId) && ddlSidebarChild.Items.FindByValue(_studentId) != null)
                    ddlSidebarChild.SelectedValue = _studentId;
            }
            catch (SqlException) { }
        }

        protected void SidebarChildChanged(object sender, EventArgs e)
        {
            string sel = ddlSidebarChild.SelectedValue;
            if (!string.IsNullOrEmpty(sel) && IsLinked(sel))
            {
                Session["selectedChildId"] = sel;
                Response.Redirect(Request.RawUrl, false);
                Context.ApplicationInstance.CompleteRequest();
            }
        }

        private void LoadLanguage()
        {
            string lang = Session["preferredLanguage"] as string;
            if (!string.IsNullOrEmpty(lang)) { CurrentLanguage = lang; return; }
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT preferredLanguage FROM dbo.[User] WHERE userId=@u", conn))
                { cmd.Parameters.AddWithValue("@u", _userId); conn.Open(); object r = cmd.ExecuteScalar(); if (r != null && r != DBNull.Value) { CurrentLanguage = r.ToString(); Session["preferredLanguage"] = CurrentLanguage; } }
            }
            catch (SqlException) { }
        }

        private void LoadParentId()
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT parentId FROM dbo.[Parent] WHERE userId=@u", conn))
                { cmd.Parameters.AddWithValue("@u", _userId); conn.Open(); object r = cmd.ExecuteScalar(); if (r != null && r != DBNull.Value) _parentId = r.ToString(); }
            }
            catch (SqlException) { }
        }

        private void ResolveChild()
        {
            string saved = Session["selectedChildId"] as string;
            if (!string.IsNullOrEmpty(saved) && IsLinked(saved)) { _studentId = saved; return; }
            if (string.IsNullOrEmpty(_parentId)) return;
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT TOP 1 studentId FROM dbo.[StudentParent] WHERE parentId=@p", conn))
                { cmd.Parameters.AddWithValue("@p", _parentId); conn.Open(); object r = cmd.ExecuteScalar(); if (r != null && r != DBNull.Value) { _studentId = r.ToString(); Session["selectedChildId"] = _studentId; } }
            }
            catch (SqlException) { }
        }

        private bool IsLinked(string sid)
        {
            if (string.IsNullOrEmpty(_parentId) || string.IsNullOrEmpty(sid)) return false;
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[StudentParent] WHERE parentId=@p AND studentId=@s", conn))
                { cmd.Parameters.AddWithValue("@p", _parentId); cmd.Parameters.AddWithValue("@s", sid); conn.Open(); return Convert.ToInt32(cmd.ExecuteScalar()) > 0; }
            }
            catch (SqlException) { return false; }
        }

        private void SetLabels()
        {
            litNoChildMsg.Text = T("No linked child found.", "Tiada anak dipautkan.");
            litNoChildLink.Text = T("Link Child Account", "Paut Akaun Anak");
            litPathTitle.Text = T("Learning Path", "Laluan Pembelajaran");
            litNoUnits.Text = T("No enrolled modules yet.", "Tiada modul didaftarkan lagi.");
            litRecentTitle.Text = T("Recent Learning Summary", "Ringkasan Pembelajaran Terkini");
            litNoRecent.Text = T("No recent activity yet.", "Tiada aktiviti terkini lagi.");
            litAchieveTitle.Text = T("Achievement Snapshot", "Ringkasan Pencapaian");
            litXPLabel.Text = T("XP Points", "Mata XP");
            litBadgeCountLabel.Text = T("Badges Earned", "Lencana Diperoleh");
        }

        private void LoadAll()
        {
            LoadIdentity();
            LoadLearningPath();
            LoadRecentSummary();
            LoadAchievements();
        }

        // ═══════════════════════════════════════════════════
        //  IDENTITY
        // ═══════════════════════════════════════════════════
        private void LoadIdentity()
        {
            try
            {
                const string sql = @"SELECT s.name, s.nickname, s.currentLevelId, s.XP,
                    l.levelNameEN, l.levelNameBM, sp.relationship
                    FROM dbo.[Student] s
                    LEFT JOIN dbo.[Level] l ON l.levelId = s.currentLevelId
                    INNER JOIN dbo.[StudentParent] sp ON sp.studentId = s.studentId AND sp.parentId = @parentId
                    WHERE s.studentId = @studentId";
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@studentId", _studentId);
                    cmd.Parameters.AddWithValue("@parentId", _parentId);
                    conn.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string name = reader["name"]?.ToString() ?? "-";
                            string nick = reader["nickname"]?.ToString() ?? "";
                            string rel = reader["relationship"]?.ToString() ?? "";
                            string lvl = CurrentLanguage == "BM" ? (reader["levelNameBM"]?.ToString() ?? "-") : (reader["levelNameEN"]?.ToString() ?? "-");
                            int xp = reader["XP"] != DBNull.Value ? Convert.ToInt32(reader["XP"]) : 0;

                            litName.Text = Server.HtmlEncode(name);
                            litNickname.Text = !string.IsNullOrWhiteSpace(nick) ? T("Nickname: ", "Nama panggilan: ") + Server.HtmlEncode(nick) : "";
                            litLevel.Text = Server.HtmlEncode(lvl);
                            litRelationship.Text = Server.HtmlEncode(!string.IsNullOrWhiteSpace(rel) ? rel : T("Family", "Keluarga"));
                            litXP.Text = xp.ToString("N0");

                            string initials = "?";
                            if (!string.IsNullOrWhiteSpace(name))
                            { var p = name.Trim().Split(' '); initials = p.Length >= 2 ? (p[0][0].ToString() + p[p.Length - 1][0].ToString()).ToUpper() : name[0].ToString().ToUpper(); }
                            litInitials.Text = Server.HtmlEncode(initials);
                        }
                    }
                }
            }
            catch (SqlException) { }
        }

        // ═══════════════════════════════════════════════════
        //  LEARNING PATH
        // ═══════════════════════════════════════════════════
        private void LoadLearningPath()
        {
            pnlUnits.Controls.Clear();
            pnlNoUnits.Visible = false;
            bool hasUnits = false;

            try
            {
                const string sql = @"
                    SELECT u.unitId, u.unitNameEN, u.unitNameBM, u.orderNo,
                        (SELECT COUNT(*) FROM dbo.[Lesson] ls INNER JOIN dbo.[Subtopic] st ON st.subtopicId=ls.subtopicId WHERE st.unitId=u.unitId) AS totalLessons,
                        (SELECT COUNT(*) FROM dbo.[LessonProgress] lp INNER JOIN dbo.[Lesson] ls ON ls.lessonId=lp.lessonId INNER JOIN dbo.[Subtopic] st ON st.subtopicId=ls.subtopicId WHERE st.unitId=u.unitId AND lp.studentId=@studentId AND lp.isCompleted=1) AS completedLessons
                    FROM dbo.[Unit] u
                    INNER JOIN dbo.[Enrollment] e ON e.levelId = u.levelId
                    WHERE e.studentId = @studentId
                    ORDER BY u.levelId, u.orderNo";

                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@studentId", _studentId);
                    conn.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            hasUnits = true;
                            string unitId = reader["unitId"]?.ToString() ?? "";
                            string unitName = CurrentLanguage == "BM" ? (reader["unitNameBM"]?.ToString() ?? reader["unitNameEN"]?.ToString() ?? "-") : (reader["unitNameEN"]?.ToString() ?? "-");
                            int total = reader["totalLessons"] != DBNull.Value ? Convert.ToInt32(reader["totalLessons"]) : 0;
                            int completed = reader["completedLessons"] != DBNull.Value ? Convert.ToInt32(reader["completedLessons"]) : 0;
                            int pct = total > 0 ? (int)Math.Round((double)completed / total * 100) : 0;

                            string html = "<div class='cp-unit'>"
                                + "<div class='cp-unit-header'>"
                                + "<span class='cp-unit-name'>" + Server.HtmlEncode(unitName) + "</span>"
                                + "<span class='cp-unit-pct'>" + pct + "%</span>"
                                + "</div>"
                                + "<div class='cp-unit-bar'><div class='cp-unit-bar-fill' style='width:" + pct + "%'></div></div>"
                                + "<div class='cp-unit-stats'>" + completed + " / " + total + " " + T("lessons completed", "pelajaran selesai") + "</div>"
                                + "</div>";

                            pnlUnits.Controls.Add(new LiteralControl(html));
                        }
                    }
                }
            }
            catch (SqlException) { }

            if (!hasUnits) pnlNoUnits.Visible = true;
        }

        // ═══════════════════════════════════════════════════
        //  RECENT LEARNING SUMMARY
        // ═══════════════════════════════════════════════════
        private void LoadRecentSummary()
        {
            pnlRecent.Controls.Clear();
            pnlNoRecent.Visible = false;
            bool hasData = false;

            // Latest lesson
            try
            {
                const string sql = @"SELECT TOP 1 l.lessonTitleEN, l.lessonTitleBM, lp.completedDate
                    FROM dbo.[LessonProgress] lp INNER JOIN dbo.[Lesson] l ON l.lessonId=lp.lessonId
                    WHERE lp.studentId=@s AND lp.isCompleted=1 ORDER BY lp.completedDate DESC";
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@s", _studentId); conn.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            hasData = true;
                            string title = CurrentLanguage == "BM" ? (r["lessonTitleBM"]?.ToString() ?? r["lessonTitleEN"]?.ToString() ?? "-") : (r["lessonTitleEN"]?.ToString() ?? "-");
                            string date = r["completedDate"] != DBNull.Value ? Convert.ToDateTime(r["completedDate"]).ToString("dd MMM yyyy") : "";
                            pnlRecent.Controls.Add(new LiteralControl(
                                "<div class='cp-activity-row'><div class='cp-activity-icon lesson'><i class='bi bi-book-half'></i></div>"
                                + "<div class='cp-activity-body'><div class='cp-activity-label'>" + T("Latest Lesson", "Pelajaran Terkini") + "</div>"
                                + "<div class='cp-activity-text'>" + Server.HtmlEncode(title) + "</div>"
                                + "<div class='cp-activity-meta'>" + Server.HtmlEncode(date) + "</div></div></div>"));
                        }
                    }
                }
            }
            catch (SqlException) { }

            // Latest quiz
            try
            {
                const string sql = @"SELECT TOP 1 q.quizTitleEN, q.quizTitleBM, qr.percentage, qr.resultStatus, qr.attemptedDate
                    FROM dbo.[QuizResult] qr INNER JOIN dbo.[Quiz] q ON q.quizId=qr.quizId
                    WHERE qr.studentId=@s ORDER BY qr.attemptedDate DESC";
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@s", _studentId); conn.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            hasData = true;
                            string title = CurrentLanguage == "BM" ? (r["quizTitleBM"]?.ToString() ?? r["quizTitleEN"]?.ToString() ?? "-") : (r["quizTitleEN"]?.ToString() ?? "-");
                            string pct = r["percentage"] != DBNull.Value ? Convert.ToDecimal(r["percentage"]).ToString("F0") + "%" : "-";
                            string status = r["resultStatus"]?.ToString() ?? "";
                            string date = r["attemptedDate"] != DBNull.Value ? Convert.ToDateTime(r["attemptedDate"]).ToString("dd MMM yyyy") : "";
                            pnlRecent.Controls.Add(new LiteralControl(
                                "<div class='cp-activity-row quiz'><div class='cp-activity-icon quiz'><i class='bi bi-patch-question-fill'></i></div>"
                                + "<div class='cp-activity-body'><div class='cp-activity-label'>" + T("Latest Quiz", "Kuiz Terkini") + "</div>"
                                + "<div class='cp-activity-text'>" + Server.HtmlEncode(title) + "</div>"
                                + "<div class='cp-activity-meta'>" + Server.HtmlEncode(pct + (!string.IsNullOrWhiteSpace(status) ? " · " + status : "") + (!string.IsNullOrWhiteSpace(date) ? " · " + date : "")) + "</div></div></div>"));
                        }
                    }
                }
            }
            catch (SqlException) { }

            // Latest badge
            try
            {
                const string sql = @"SELECT TOP 1 b.badgeNameEN, b.badgeNameBM, sb.earnedAt
                    FROM dbo.[StudentBadge] sb INNER JOIN dbo.[Badge] b ON b.badgeId=sb.badgeId
                    WHERE sb.studentId=@s ORDER BY sb.earnedAt DESC";
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@s", _studentId); conn.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            hasData = true;
                            string bname = CurrentLanguage == "BM" ? (r["badgeNameBM"]?.ToString() ?? r["badgeNameEN"]?.ToString() ?? "-") : (r["badgeNameEN"]?.ToString() ?? "-");
                            string date = r["earnedAt"] != DBNull.Value ? Convert.ToDateTime(r["earnedAt"]).ToString("dd MMM yyyy") : "";
                            pnlRecent.Controls.Add(new LiteralControl(
                                "<div class='cp-activity-row badgerow'><div class='cp-activity-icon badge-icon'><i class='bi bi-award-fill'></i></div>"
                                + "<div class='cp-activity-body'><div class='cp-activity-label'>" + T("Latest Badge", "Lencana Terkini") + "</div>"
                                + "<div class='cp-activity-text'>" + Server.HtmlEncode(bname) + "</div>"
                                + "<div class='cp-activity-meta'>" + Server.HtmlEncode(date) + "</div></div></div>"));
                        }
                    }
                }
            }
            catch (SqlException) { }

            if (!hasData) pnlNoRecent.Visible = true;
        }

        // ═══════════════════════════════════════════════════
        //  ACHIEVEMENTS
        // ═══════════════════════════════════════════════════
        private void LoadAchievements()
        {
            // Badge count
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[StudentBadge] WHERE studentId=@s", conn))
                { cmd.Parameters.AddWithValue("@s", _studentId); conn.Open(); litBadgeCount.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString(); }
            }
            catch (SqlException) { litBadgeCount.Text = "0"; }

            // Latest badge name
            pnlLatestBadge.Visible = false;
            try
            {
                const string sql = @"SELECT TOP 1 b.badgeNameEN, b.badgeNameBM
                    FROM dbo.[StudentBadge] sb INNER JOIN dbo.[Badge] b ON b.badgeId=sb.badgeId
                    WHERE sb.studentId=@s ORDER BY sb.earnedAt DESC";
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@s", _studentId); conn.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            string bname = CurrentLanguage == "BM" ? (r["badgeNameBM"]?.ToString() ?? r["badgeNameEN"]?.ToString() ?? "") : (r["badgeNameEN"]?.ToString() ?? "");
                            if (!string.IsNullOrWhiteSpace(bname))
                            {
                                litLatestBadge.Text = T("Latest: ", "Terkini: ") + Server.HtmlEncode(bname);
                                pnlLatestBadge.Visible = true;
                            }
                        }
                    }
                }
            }
            catch (SqlException) { }
        }
    }
}
