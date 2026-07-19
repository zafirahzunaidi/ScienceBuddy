using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace ScienceBuddy.Parent
{
    public partial class ChildProfile : Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected string CurrentLanguage = "EN";

        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        private string _userId = "";
        private string _parentId = "";
        private string _studentId = "";

        // --- Page Load ---
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!CheckAuth())
            {
                return;
            }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            _userId = Session["userId"].ToString();
            LoadLang();
            LoadParentId();
            LoadSelectedChild();
            SetLabels();

            if (!IsPostBack)
            {
                LoadChildren();
                ShowProfile();
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

        private void ShowProfile()
        {
            if (!string.IsNullOrEmpty(_studentId))
            {
                pnlProfile.Visible = true;
                pnlNoChild.Visible = false;
                LoadAllProfileSections();
            }
            else
            {
                pnlProfile.Visible = false;
                pnlNoChild.Visible = true;
            }
        }

        // --- Sidebar Child Selector ---
        private void LoadChildren()
        {
            ddlSidebarChild.Items.Clear();
            if (string.IsNullOrEmpty(_parentId))
            {
                return;
            }

            try
            {
                const string sql = @"SELECT sp.studentId, s.name, s.nickname 
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
                            string studentId = reader["studentId"]?.ToString() ?? "";
                            string nickname = reader["nickname"]?.ToString() ?? "";
                            string fullName = reader["name"]?.ToString() ?? "";

                            string displayLabel = !string.IsNullOrWhiteSpace(nickname)
                                ? nickname
                                : fullName;

                            ddlSidebarChild.Items.Add(
                                new System.Web.UI.WebControls.ListItem(displayLabel, studentId));
                        }
                    }
                }

                if (!string.IsNullOrEmpty(_studentId) &&
                    ddlSidebarChild.Items.FindByValue(_studentId) != null)
                {
                    ddlSidebarChild.SelectedValue = _studentId;
                }
            }
            catch (SqlException) { }
        }

        protected void SidebarChildChanged(object sender, EventArgs e)
        {
            string selected = ddlSidebarChild.SelectedValue;
            if (!string.IsNullOrEmpty(selected) && IsLinked(selected))
            {
                Session["selectedChildId"] = selected;
                _studentId = selected;
                ShowProfile();
            }
        }

        // --- Language & Parent Resolution ---
        private void LoadLang()
        {
            string cached = Session["preferredLanguage"] as string;
            if (!string.IsNullOrEmpty(cached))
            {
                CurrentLanguage = cached;
                return;
            }

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(
                    "SELECT preferredLanguage FROM dbo.[User] WHERE userId = @userId", conn))
                {
                    cmd.Parameters.AddWithValue("@userId", _userId);
                    conn.Open();
                    object result = cmd.ExecuteScalar();

                    if (result != null && result != DBNull.Value)
                    {
                        CurrentLanguage = result.ToString();
                        Session["preferredLanguage"] = CurrentLanguage;
                    }
                }
            }
            catch (SqlException) { }
        }

        private void LoadParentId()
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(
                    "SELECT parentId FROM dbo.[Parent] WHERE userId = @userId", conn))
                {
                    cmd.Parameters.AddWithValue("@userId", _userId);
                    conn.Open();
                    object result = cmd.ExecuteScalar();

                    if (result != null && result != DBNull.Value)
                    {
                        _parentId = result.ToString();
                    }
                }
            }
            catch (SqlException) { }
        }

        // Checks session first, falls back to first linked child
        private void LoadSelectedChild()
        {
            string saved = Session["selectedChildId"] as string;
            if (!string.IsNullOrEmpty(saved) && IsLinked(saved))
            {
                _studentId = saved;
                return;
            }

            if (string.IsNullOrEmpty(_parentId))
            {
                return;
            }

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(
                    "SELECT TOP 1 studentId FROM dbo.[StudentParent] WHERE parentId = @parentId", conn))
                {
                    cmd.Parameters.AddWithValue("@parentId", _parentId);
                    conn.Open();
                    object result = cmd.ExecuteScalar();

                    if (result != null && result != DBNull.Value)
                    {
                        _studentId = result.ToString();
                        Session["selectedChildId"] = _studentId;
                    }
                }
            }
            catch (SqlException) { }
        }

        // Prevents unauthorized access to unlinked student profiles
        private bool IsLinked(string studentId)
        {
            if (string.IsNullOrEmpty(_parentId) || string.IsNullOrEmpty(studentId))
            {
                return false;
            }

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(
                    "SELECT COUNT(*) FROM dbo.[StudentParent] WHERE parentId = @parentId AND studentId = @studentId",
                    conn))
                {
                    cmd.Parameters.AddWithValue("@parentId", _parentId);
                    cmd.Parameters.AddWithValue("@studentId", studentId);
                    conn.Open();
                    return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
                }
            }
            catch (SqlException)
            {
                return false;
            }
        }

        // --- Labels ---
        private void SetLabels()
        {
            litNoChildMsg.Text = T("No linked child found.", "Tiada anak dipautkan.");
            litNoChildLink.Text = T("Link Child Account", "Paut Akaun Anak");
            litAchieveTitle.Text = T("Achievement Snapshot", "Ringkasan Pencapaian");
            litXPLabel.Text = T("XP Points", "Mata XP");
            litBadgeCountLabel.Text = T("Badges Earned", "Lencana Diperoleh");
        }

        // --- Profile Sections ---
        private void LoadAllProfileSections()
        {
            LoadStudentIdentity();
            LoadPersonalityCard();
            LoadLevelCard();
            LoadAchievementSnapshot();
            LoadBadgeCollection();
        }

        // --- Identity ---
        private void LoadStudentIdentity()
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
                            string nickname = reader["nickname"]?.ToString() ?? "";
                            string relationship = reader["relationship"]?.ToString() ?? "";
                            string levelName = CurrentLanguage == "BM"
                                ? (reader["levelNameBM"]?.ToString() ?? "-")
                                : (reader["levelNameEN"]?.ToString() ?? "-");
                            int xp = reader["XP"] != DBNull.Value
                                ? Convert.ToInt32(reader["XP"])
                                : 0;

                            litName.Text = Server.HtmlEncode(name);
                            litNickname.Text = !string.IsNullOrWhiteSpace(nickname)
                                ? T("Nickname: ", "Nama panggilan: ") + Server.HtmlEncode(nickname)
                                : "";
                            litLevel.Text = Server.HtmlEncode(levelName);
                            litRelationship.Text = Server.HtmlEncode(
                                !string.IsNullOrWhiteSpace(relationship) ? relationship : T("Family", "Keluarga"));
                            litXP.Text = xp.ToString("N0");

                            litInitials.Text = Server.HtmlEncode(GetInitials(name));
                        }
                    }
                }
            }
            catch (SqlException) { }
        }

        private string GetInitials(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName))
            {
                return "?";
            }

            string[] parts = fullName.Trim().Split(' ');
            if (parts.Length >= 2)
            {
                return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
            }

            return fullName[0].ToString().ToUpper();
        }

        // --- Personality Card ---
        private void LoadPersonalityCard()
        {
            pnlPersonality.Visible = false;
            pnlNoPersonality.Visible = false;

            try
            {
                const string sql = @"SELECT s.name, s.nickname, s.personalityId, sp.relationship,
                    p.personalityNameEN, p.personalityNameBM, p.descriptionEN, p.descriptionBM,
                    p.avatar, p.learningStyleEN, p.learningStyleBM
                    FROM dbo.[Student] s
                    INNER JOIN dbo.[StudentParent] sp ON sp.studentId = s.studentId AND sp.parentId = @parentId
                    LEFT JOIN dbo.[Personality] p ON p.personalityId = s.personalityId
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
                            string personalityName = CurrentLanguage == "BM"
                                ? (reader["personalityNameBM"]?.ToString() ?? "")
                                : (reader["personalityNameEN"]?.ToString() ?? "");
                            string desc = CurrentLanguage == "BM"
                                ? (reader["descriptionBM"]?.ToString() ?? "")
                                : (reader["descriptionEN"]?.ToString() ?? "");
                            string avatarPath = reader["avatar"] != DBNull.Value
                                ? reader["avatar"].ToString()
                                : "";
                            string learningStyle = CurrentLanguage == "BM"
                                ? (reader["learningStyleBM"]?.ToString() ?? "")
                                : (reader["learningStyleEN"]?.ToString() ?? "");
                            string childName = reader["name"]?.ToString() ?? "-";
                            string childNickname = reader["nickname"]?.ToString() ?? "-";
                            string rel = reader["relationship"]?.ToString()
                                ?? T("Family", "Keluarga");

                            if (!string.IsNullOrWhiteSpace(personalityName))
                            {
                                pnlPersonality.Visible = true;
                                litPersonalityTitle.Text = string.Format(
                                    T("Your child is a {0}:", "Anak anda ialah {0}:"),
                                    Server.HtmlEncode(personalityName));
                                litPersonalityDesc.Text = Server.HtmlEncode(desc);
                                litInfoFullName.Text = Server.HtmlEncode(childName);
                                litInfoNickname.Text = Server.HtmlEncode(
                                    !string.IsNullOrWhiteSpace(childNickname) ? childNickname : "-");
                                litInfoRelationship.Text = Server.HtmlEncode(rel);
                                litInfoLearningStyle.Text = Server.HtmlEncode(
                                    !string.IsNullOrWhiteSpace(learningStyle) ? learningStyle : "-");

                                if (!string.IsNullOrWhiteSpace(avatarPath))
                                {
                                    imgPersonality.ImageUrl = ResolveUrl("~/" + avatarPath);
                                }
                                else
                                {
                                    imgPersonality.Visible = false;
                                }
                            }
                            else
                            {
                                pnlNoPersonality.Visible = true;
                            }
                        }
                        else
                        {
                            pnlNoPersonality.Visible = true;
                        }
                    }
                }
            }
            catch
            {
                pnlNoPersonality.Visible = true;
            }
        }

        // --- Level Card ---
        private void LoadLevelCard()
        {
            pnlLevelInfo.Visible = false;
            pnlNoLevel.Visible = false;

            try
            {
                const string sql = @"SELECT l.levelNameEN, l.levelNameBM, 
                    l.levelDescriptionEN, l.levelDescriptionBM, e.enrolledDate
                    FROM dbo.[Student] s
                    LEFT JOIN dbo.[Level] l ON l.levelId = s.currentLevelId
                    LEFT JOIN dbo.[Enrollment] e ON e.studentId = s.studentId 
                        AND e.levelId = s.currentLevelId AND e.status = 'Active'
                    WHERE s.studentId = @studentId";

                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@studentId", _studentId);
                    conn.Open();

                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read() && reader["levelNameEN"] != DBNull.Value)
                        {
                            pnlLevelInfo.Visible = true;

                            string levelName = CurrentLanguage == "BM"
                                ? (reader["levelNameBM"]?.ToString() ?? "-")
                                : (reader["levelNameEN"]?.ToString() ?? "-");
                            string levelDesc = CurrentLanguage == "BM"
                                ? (reader["levelDescriptionBM"] != DBNull.Value ? reader["levelDescriptionBM"].ToString() : "")
                                : (reader["levelDescriptionEN"] != DBNull.Value ? reader["levelDescriptionEN"].ToString() : "");
                            string enrollDate = reader["enrolledDate"] != DBNull.Value
                                ? Convert.ToDateTime(reader["enrolledDate"]).ToString("dd MMM yyyy")
                                : T("Not available", "Tidak tersedia");

                            litLevelName.Text = Server.HtmlEncode(levelName);
                            litLevelDesc.Text = Server.HtmlEncode(levelDesc);
                            litEnrolledSince.Text = T("Enrolled Since: ", "Didaftarkan Sejak: ")
                                + Server.HtmlEncode(enrollDate);
                        }
                        else
                        {
                            pnlNoLevel.Visible = true;
                        }
                    }
                }
            }
            catch
            {
                pnlNoLevel.Visible = true;
            }
        }

        // --- Achievements ---
        private void LoadAchievementSnapshot()
        {
            LoadBadgeCount();
            LoadLatestBadgeName();
        }

        private void LoadBadgeCount()
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(
                    "SELECT COUNT(*) FROM dbo.[StudentBadge] WHERE studentId = @studentId", conn))
                {
                    cmd.Parameters.AddWithValue("@studentId", _studentId);
                    conn.Open();
                    litBadgeCount.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString();
                }
            }
            catch (SqlException)
            {
                litBadgeCount.Text = "0";
            }
        }

        private void LoadLatestBadgeName()
        {
            pnlLatestBadge.Visible = false;

            try
            {
                const string sql = @"SELECT TOP 1 b.badgeNameEN, b.badgeNameBM
                    FROM dbo.[StudentBadge] sb 
                    INNER JOIN dbo.[Badge] b ON b.badgeId = sb.badgeId
                    WHERE sb.studentId = @studentId 
                    ORDER BY sb.earnedAt DESC";

                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@studentId", _studentId);
                    conn.Open();

                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string badgeName = CurrentLanguage == "BM"
                                ? (reader["badgeNameBM"]?.ToString() ?? reader["badgeNameEN"]?.ToString() ?? "")
                                : (reader["badgeNameEN"]?.ToString() ?? "");

                            if (!string.IsNullOrWhiteSpace(badgeName))
                            {
                                litLatestBadge.Text = T("Latest: ", "Terkini: ")
                                    + Server.HtmlEncode(badgeName);
                                pnlLatestBadge.Visible = true;
                            }
                        }
                    }
                }
            }
            catch (SqlException) { }
        }

        // --- Badge Collection Grid ---
        private void LoadBadgeCollection()
        {
            pnlBadgeGrid.Controls.Clear();

            try
            {
                const string sql = @"SELECT b.badgeId, b.badgeNameEN, b.badgeNameBM, 
                    b.badgeDescriptionEN, b.badgeDescriptionBM,
                    b.requirementDescriptionEN, b.xpReward, sb.earnedAt
                    FROM dbo.[Badge] b
                    LEFT JOIN dbo.[StudentBadge] sb ON b.badgeId = sb.badgeId AND sb.studentId = @studentId
                    ORDER BY CASE WHEN sb.earnedAt IS NOT NULL THEN 0 ELSE 1 END, 
                             sb.earnedAt DESC, b.badgeNameEN";

                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@studentId", _studentId);
                    conn.Open();

                    using (var reader = cmd.ExecuteReader())
                    {
                        var html = new System.Text.StringBuilder();
                        html.Append("<div class=\"pt-badge-grid\">");
                        bool hasRecords = false;

                        while (reader.Read())
                        {
                            hasRecords = true;
                            bool earned = reader["earnedAt"] != DBNull.Value;

                            string badgeName = CurrentLanguage == "BM"
                                && reader["badgeNameBM"] != DBNull.Value
                                && !string.IsNullOrEmpty(reader["badgeNameBM"].ToString())
                                    ? reader["badgeNameBM"].ToString()
                                    : reader["badgeNameEN"] != DBNull.Value
                                        ? reader["badgeNameEN"].ToString()
                                        : "";

                            string badgeDesc = CurrentLanguage == "BM"
                                && reader["badgeDescriptionBM"] != DBNull.Value
                                && !string.IsNullOrEmpty(reader["badgeDescriptionBM"].ToString())
                                    ? reader["badgeDescriptionBM"].ToString()
                                    : reader["badgeDescriptionEN"] != DBNull.Value
                                        ? reader["badgeDescriptionEN"].ToString()
                                        : "";

                            string reqText = reader["requirementDescriptionEN"] != DBNull.Value
                                ? reader["requirementDescriptionEN"].ToString()
                                : "";
                            int xpReward = reader["xpReward"] != DBNull.Value
                                ? Convert.ToInt32(reader["xpReward"])
                                : 0;
                            string earnedDate = earned
                                ? Convert.ToDateTime(reader["earnedAt"]).ToString("dd MMM yyyy")
                                : "";

                            string shortDesc = badgeDesc.Length > 100
                                ? badgeDesc.Substring(0, 100) + "..."
                                : badgeDesc;
                            string shortReq = reqText.Length > 80
                                ? reqText.Substring(0, 80) + "..."
                                : reqText;

                            string cardClass = earned
                                ? "pt-badge-card pt-badge-card-earned"
                                : "pt-badge-card pt-badge-card-locked";
                            string lockOverlay = earned
                                ? ""
                                : "<div class=\"pt-badge-lock-icon\"><i class=\"bi bi-lock-fill\"></i></div>";
                            string iconMarkup = earned
                                ? "<div class=\"pt-badge-icon-wrap pt-badge-icon-earned\"><i class=\"bi bi-award-fill\"></i></div>"
                                : "<div class=\"pt-badge-icon-wrap pt-badge-icon-locked\"><i class=\"bi bi-award-fill\"></i></div>";
                            string statusPill = earned
                                ? "<div class=\"pt-badge-status-pill pt-badge-pill-earned\">"
                                    + T("Earned", "Diperoleh") + " &bull; " + earnedDate + "</div>"
                                : "<div class=\"pt-badge-status-pill pt-badge-pill-locked\">"
                                    + T("Locked", "Terkunci") + "</div>";

                            html.Append("<div class=\"" + cardClass + "\">");
                            html.Append(lockOverlay);
                            html.Append(iconMarkup);
                            html.Append("<div class=\"pt-badge-card-name\">"
                                + Server.HtmlEncode(badgeName) + "</div>");
                            html.Append("<div class=\"pt-badge-card-desc\">"
                                + Server.HtmlEncode(shortDesc) + "</div>");
                            html.Append("<div class=\"pt-badge-card-req\">"
                                + Server.HtmlEncode(shortReq) + "</div>");
                            html.Append("<div class=\"pt-badge-card-xp\">+"
                                + xpReward + " XP</div>");
                            html.Append(statusPill);
                            html.Append("</div>");
                        }

                        html.Append("</div>");

                        if (hasRecords)
                        {
                            pnlBadgeGrid.Controls.Add(new LiteralControl(html.ToString()));
                            pnlNoBadges.Visible = false;
                        }
                        else
                        {
                            pnlNoBadges.Visible = true;
                        }
                    }
                }
            }
            catch
            {
                pnlNoBadges.Visible = true;
            }
        }

        // --- Notification Badge ---
        private void LoadUnreadBadge()
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(
                    "SELECT COUNT(*) FROM dbo.Notification WHERE toUserId = @userId AND isRead = 0",
                    conn))
                {
                    cmd.Parameters.AddWithValue("@userId", Session["userId"].ToString());
                    conn.Open();
                    int count = (int)cmd.ExecuteScalar();

                    litUnreadBadge.Text = count > 0
                        ? "<span class='pt-sidebar-badge'>" + count + "</span>"
                        : "";
                }
            }
            catch { }
        }
    }
}
