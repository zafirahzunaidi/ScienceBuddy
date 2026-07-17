using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace ScienceBuddy.Parent
{
    public partial class ChildProfile : Page
    {
        private string DatabaseConnectionString =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected string CurrentLanguage = "EN";

        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        private string _authenticatedUserId = "";
        private string _parentRecordId = "";
        private string _viewedStudentId = "";

        // ═══════════════════════════════════════════════════
        //  PAGE LIFECYCLE
        // ═══════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!ValidateParentSession())
            {
                return;
            }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            _authenticatedUserId = Session["userId"].ToString();
            LoadLanguagePreference();
            LoadParentRecordId();
            ResolveActiveChild();
            ApplyPageLabels();

            if (!IsPostBack)
            {
                PopulateSidebarChildDropdown();
                RenderChildProfileOrPlaceholder();
            }
        }

        /// <summary>
        /// Validates that the current session belongs to an authenticated parent user.
        /// Redirects to login if session is missing or role mismatch.
        /// </summary>
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

        private void RenderChildProfileOrPlaceholder()
        {
            if (!string.IsNullOrEmpty(_viewedStudentId))
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

        // ═══════════════════════════════════════════════════
        //  SIDEBAR CHILD SELECTOR
        // ═══════════════════════════════════════════════════
        private void PopulateSidebarChildDropdown()
        {
            ddlSidebarChild.Items.Clear();
            if (string.IsNullOrEmpty(_parentRecordId))
            {
                return;
            }

            try
            {
                const string childListQuery = @"SELECT sp.studentId, s.name, s.nickname 
                    FROM dbo.[StudentParent] sp 
                    INNER JOIN dbo.[Student] s ON s.studentId = sp.studentId 
                    WHERE sp.parentId = @parentId";

                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(childListQuery, connection))
                {
                    command.Parameters.AddWithValue("@parentId", _parentRecordId);
                    connection.Open();

                    using (var reader = command.ExecuteReader())
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

                if (!string.IsNullOrEmpty(_viewedStudentId) &&
                    ddlSidebarChild.Items.FindByValue(_viewedStudentId) != null)
                {
                    ddlSidebarChild.SelectedValue = _viewedStudentId;
                }
            }
            catch (SqlException) { }
        }

        protected void SidebarChildChanged(object sender, EventArgs e)
        {
            string selectedStudentId = ddlSidebarChild.SelectedValue;
            if (!string.IsNullOrEmpty(selectedStudentId) && IsChildLinkedToParent(selectedStudentId))
            {
                Session["selectedChildId"] = selectedStudentId;
                _viewedStudentId = selectedStudentId;
                RenderChildProfileOrPlaceholder();
            }
        }

        // ═══════════════════════════════════════════════════
        //  LANGUAGE & PARENT RESOLUTION
        // ═══════════════════════════════════════════════════
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
                    "SELECT preferredLanguage FROM dbo.[User] WHERE userId = @userId", connection))
                {
                    command.Parameters.AddWithValue("@userId", _authenticatedUserId);
                    connection.Open();
                    object result = command.ExecuteScalar();

                    if (result != null && result != DBNull.Value)
                    {
                        CurrentLanguage = result.ToString();
                        Session["preferredLanguage"] = CurrentLanguage;
                    }
                }
            }
            catch (SqlException) { }
        }

        private void LoadParentRecordId()
        {
            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(
                    "SELECT parentId FROM dbo.[Parent] WHERE userId = @userId", connection))
                {
                    command.Parameters.AddWithValue("@userId", _authenticatedUserId);
                    connection.Open();
                    object result = command.ExecuteScalar();

                    if (result != null && result != DBNull.Value)
                    {
                        _parentRecordId = result.ToString();
                    }
                }
            }
            catch (SqlException) { }
        }

        /// <summary>
        /// Resolves which child to display: checks session cache first, then falls back
        /// to the first linked child from the StudentParent relationship table.
        /// </summary>
        private void ResolveActiveChild()
        {
            string savedChildId = Session["selectedChildId"] as string;
            if (!string.IsNullOrEmpty(savedChildId) && IsChildLinkedToParent(savedChildId))
            {
                _viewedStudentId = savedChildId;
                return;
            }

            if (string.IsNullOrEmpty(_parentRecordId))
            {
                return;
            }

            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(
                    "SELECT TOP 1 studentId FROM dbo.[StudentParent] WHERE parentId = @parentId", connection))
                {
                    command.Parameters.AddWithValue("@parentId", _parentRecordId);
                    connection.Open();
                    object result = command.ExecuteScalar();

                    if (result != null && result != DBNull.Value)
                    {
                        _viewedStudentId = result.ToString();
                        Session["selectedChildId"] = _viewedStudentId;
                    }
                }
            }
            catch (SqlException) { }
        }

        /// <summary>
        /// Verifies parent-child relationship exists in StudentParent table
        /// to prevent unauthorized access to unlinked student profiles.
        /// </summary>
        private bool IsChildLinkedToParent(string studentId)
        {
            if (string.IsNullOrEmpty(_parentRecordId) || string.IsNullOrEmpty(studentId))
            {
                return false;
            }

            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(
                    "SELECT COUNT(*) FROM dbo.[StudentParent] WHERE parentId = @parentId AND studentId = @studentId",
                    connection))
                {
                    command.Parameters.AddWithValue("@parentId", _parentRecordId);
                    command.Parameters.AddWithValue("@studentId", studentId);
                    connection.Open();
                    return Convert.ToInt32(command.ExecuteScalar()) > 0;
                }
            }
            catch (SqlException)
            {
                return false;
            }
        }

        // ═══════════════════════════════════════════════════
        //  PAGE LABELS
        // ═══════════════════════════════════════════════════
        private void ApplyPageLabels()
        {
            litNoChildMsg.Text = T("No linked child found.", "Tiada anak dipautkan.");
            litNoChildLink.Text = T("Link Child Account", "Paut Akaun Anak");
            litAchieveTitle.Text = T("Achievement Snapshot", "Ringkasan Pencapaian");
            litXPLabel.Text = T("XP Points", "Mata XP");
            litBadgeCountLabel.Text = T("Badges Earned", "Lencana Diperoleh");
        }

        // ═══════════════════════════════════════════════════
        //  PROFILE SECTION ORCHESTRATOR
        // ═══════════════════════════════════════════════════
        private void LoadAllProfileSections()
        {
            LoadStudentIdentity();
            LoadPersonalityCard();
            LoadLevelCard();
            LoadAchievementSnapshot();
            LoadBadgeCollection();
        }

        // ═══════════════════════════════════════════════════
        //  IDENTITY SECTION
        // ═══════════════════════════════════════════════════
        private void LoadStudentIdentity()
        {
            try
            {
                const string identityQuery = @"SELECT s.name, s.nickname, s.currentLevelId, s.XP,
                    l.levelNameEN, l.levelNameBM, sp.relationship
                    FROM dbo.[Student] s
                    LEFT JOIN dbo.[Level] l ON l.levelId = s.currentLevelId
                    INNER JOIN dbo.[StudentParent] sp ON sp.studentId = s.studentId AND sp.parentId = @parentId
                    WHERE s.studentId = @studentId";

                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(identityQuery, connection))
                {
                    command.Parameters.AddWithValue("@studentId", _viewedStudentId);
                    command.Parameters.AddWithValue("@parentId", _parentRecordId);
                    connection.Open();

                    using (var reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string studentName = reader["name"]?.ToString() ?? "-";
                            string studentNickname = reader["nickname"]?.ToString() ?? "";
                            string relationship = reader["relationship"]?.ToString() ?? "";
                            string levelName = CurrentLanguage == "BM"
                                ? (reader["levelNameBM"]?.ToString() ?? "-")
                                : (reader["levelNameEN"]?.ToString() ?? "-");
                            int experiencePoints = reader["XP"] != DBNull.Value
                                ? Convert.ToInt32(reader["XP"])
                                : 0;

                            litName.Text = Server.HtmlEncode(studentName);
                            litNickname.Text = !string.IsNullOrWhiteSpace(studentNickname)
                                ? T("Nickname: ", "Nama panggilan: ") + Server.HtmlEncode(studentNickname)
                                : "";
                            litLevel.Text = Server.HtmlEncode(levelName);
                            litRelationship.Text = Server.HtmlEncode(
                                !string.IsNullOrWhiteSpace(relationship) ? relationship : T("Family", "Keluarga"));
                            litXP.Text = experiencePoints.ToString("N0");

                            string avatarInitials = BuildNameInitials(studentName);
                            litInitials.Text = Server.HtmlEncode(avatarInitials);
                        }
                    }
                }
            }
            catch (SqlException) { }
        }

        private string BuildNameInitials(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName))
            {
                return "?";
            }

            string[] nameParts = fullName.Trim().Split(' ');
            if (nameParts.Length >= 2)
            {
                return (nameParts[0][0].ToString() + nameParts[nameParts.Length - 1][0].ToString()).ToUpper();
            }

            return fullName[0].ToString().ToUpper();
        }

        // ═══════════════════════════════════════════════════
        //  PERSONALITY CARD
        // ═══════════════════════════════════════════════════
        private void LoadPersonalityCard()
        {
            pnlPersonality.Visible = false;
            pnlNoPersonality.Visible = false;

            try
            {
                const string personalityQuery = @"SELECT s.name, s.nickname, s.personalityId, sp.relationship,
                    p.personalityNameEN, p.personalityNameBM, p.descriptionEN, p.descriptionBM,
                    p.avatar, p.learningStyleEN, p.learningStyleBM
                    FROM dbo.[Student] s
                    INNER JOIN dbo.[StudentParent] sp ON sp.studentId = s.studentId AND sp.parentId = @parentId
                    LEFT JOIN dbo.[Personality] p ON p.personalityId = s.personalityId
                    WHERE s.studentId = @studentId";

                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(personalityQuery, connection))
                {
                    command.Parameters.AddWithValue("@studentId", _viewedStudentId);
                    command.Parameters.AddWithValue("@parentId", _parentRecordId);
                    connection.Open();

                    using (var reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string personalityName = CurrentLanguage == "BM"
                                ? (reader["personalityNameBM"]?.ToString() ?? "")
                                : (reader["personalityNameEN"]?.ToString() ?? "");
                            string personalityDescription = CurrentLanguage == "BM"
                                ? (reader["descriptionBM"]?.ToString() ?? "")
                                : (reader["descriptionEN"]?.ToString() ?? "");
                            string avatarPath = reader["avatar"] != DBNull.Value
                                ? reader["avatar"].ToString()
                                : "";
                            string learningStyle = CurrentLanguage == "BM"
                                ? (reader["learningStyleBM"]?.ToString() ?? "")
                                : (reader["learningStyleEN"]?.ToString() ?? "");
                            string childFullName = reader["name"]?.ToString() ?? "-";
                            string childNickname = reader["nickname"]?.ToString() ?? "-";
                            string familyRelationship = reader["relationship"]?.ToString()
                                ?? T("Family", "Keluarga");

                            if (!string.IsNullOrWhiteSpace(personalityName))
                            {
                                pnlPersonality.Visible = true;
                                litPersonalityTitle.Text = string.Format(
                                    T("Your child is a {0}:", "Anak anda ialah {0}:"),
                                    Server.HtmlEncode(personalityName));
                                litPersonalityDesc.Text = Server.HtmlEncode(personalityDescription);
                                litInfoFullName.Text = Server.HtmlEncode(childFullName);
                                litInfoNickname.Text = Server.HtmlEncode(
                                    !string.IsNullOrWhiteSpace(childNickname) ? childNickname : "-");
                                litInfoRelationship.Text = Server.HtmlEncode(familyRelationship);
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

        // ═══════════════════════════════════════════════════
        //  LEVEL CARD
        // ═══════════════════════════════════════════════════
        private void LoadLevelCard()
        {
            pnlLevelInfo.Visible = false;
            pnlNoLevel.Visible = false;

            try
            {
                const string levelQuery = @"SELECT l.levelNameEN, l.levelNameBM, 
                    l.levelDescriptionEN, l.levelDescriptionBM, e.enrolledDate
                    FROM dbo.[Student] s
                    LEFT JOIN dbo.[Level] l ON l.levelId = s.currentLevelId
                    LEFT JOIN dbo.[Enrollment] e ON e.studentId = s.studentId 
                        AND e.levelId = s.currentLevelId AND e.status = 'Active'
                    WHERE s.studentId = @studentId";

                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(levelQuery, connection))
                {
                    command.Parameters.AddWithValue("@studentId", _viewedStudentId);
                    connection.Open();

                    using (var reader = command.ExecuteReader())
                    {
                        if (reader.Read() && reader["levelNameEN"] != DBNull.Value)
                        {
                            pnlLevelInfo.Visible = true;

                            string levelDisplayName = CurrentLanguage == "BM"
                                ? (reader["levelNameBM"]?.ToString() ?? "-")
                                : (reader["levelNameEN"]?.ToString() ?? "-");
                            string levelDescription = CurrentLanguage == "BM"
                                ? (reader["levelDescriptionBM"] != DBNull.Value ? reader["levelDescriptionBM"].ToString() : "")
                                : (reader["levelDescriptionEN"] != DBNull.Value ? reader["levelDescriptionEN"].ToString() : "");
                            string enrollmentDate = reader["enrolledDate"] != DBNull.Value
                                ? Convert.ToDateTime(reader["enrolledDate"]).ToString("dd MMM yyyy")
                                : T("Not available", "Tidak tersedia");

                            litLevelName.Text = Server.HtmlEncode(levelDisplayName);
                            litLevelDesc.Text = Server.HtmlEncode(levelDescription);
                            litEnrolledSince.Text = T("Enrolled Since: ", "Didaftarkan Sejak: ")
                                + Server.HtmlEncode(enrollmentDate);
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

        // ═══════════════════════════════════════════════════
        //  ACHIEVEMENTS
        // ═══════════════════════════════════════════════════
        private void LoadAchievementSnapshot()
        {
            LoadBadgeCount();
            LoadLatestBadgeName();
        }

        private void LoadBadgeCount()
        {
            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(
                    "SELECT COUNT(*) FROM dbo.[StudentBadge] WHERE studentId = @studentId", connection))
                {
                    command.Parameters.AddWithValue("@studentId", _viewedStudentId);
                    connection.Open();
                    litBadgeCount.Text = Convert.ToInt32(command.ExecuteScalar()).ToString();
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
                const string latestBadgeQuery = @"SELECT TOP 1 b.badgeNameEN, b.badgeNameBM
                    FROM dbo.[StudentBadge] sb 
                    INNER JOIN dbo.[Badge] b ON b.badgeId = sb.badgeId
                    WHERE sb.studentId = @studentId 
                    ORDER BY sb.earnedAt DESC";

                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(latestBadgeQuery, connection))
                {
                    command.Parameters.AddWithValue("@studentId", _viewedStudentId);
                    connection.Open();

                    using (var reader = command.ExecuteReader())
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

        // ═══════════════════════════════════════════════════
        //  BADGE COLLECTION GRID
        // ═══════════════════════════════════════════════════

        /// <summary>
        /// Renders the complete badge collection showing both earned and locked badges.
        /// Earned badges appear first (sorted by most recent), followed by locked badges.
        /// </summary>
        private void LoadBadgeCollection()
        {
            pnlBadgeGrid.Controls.Clear();

            try
            {
                const string badgeCollectionQuery = @"SELECT b.badgeId, b.badgeNameEN, b.badgeNameBM, 
                    b.badgeDescriptionEN, b.badgeDescriptionBM,
                    b.requirementDescriptionEN, b.xpReward, sb.earnedAt
                    FROM dbo.[Badge] b
                    LEFT JOIN dbo.[StudentBadge] sb ON b.badgeId = sb.badgeId AND sb.studentId = @studentId
                    ORDER BY CASE WHEN sb.earnedAt IS NOT NULL THEN 0 ELSE 1 END, 
                             sb.earnedAt DESC, b.badgeNameEN";

                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(badgeCollectionQuery, connection))
                {
                    command.Parameters.AddWithValue("@studentId", _viewedStudentId);
                    connection.Open();

                    using (var reader = command.ExecuteReader())
                    {
                        var badgeGridHtml = new System.Text.StringBuilder();
                        badgeGridHtml.Append("<div class=\"pt-badge-grid\">");
                        bool hasBadgeRecords = false;

                        while (reader.Read())
                        {
                            hasBadgeRecords = true;
                            bool hasBeenEarned = reader["earnedAt"] != DBNull.Value;

                            string badgeDisplayName = CurrentLanguage == "BM"
                                && reader["badgeNameBM"] != DBNull.Value
                                && !string.IsNullOrEmpty(reader["badgeNameBM"].ToString())
                                    ? reader["badgeNameBM"].ToString()
                                    : reader["badgeNameEN"] != DBNull.Value
                                        ? reader["badgeNameEN"].ToString()
                                        : "";

                            string badgeDescription = CurrentLanguage == "BM"
                                && reader["badgeDescriptionBM"] != DBNull.Value
                                && !string.IsNullOrEmpty(reader["badgeDescriptionBM"].ToString())
                                    ? reader["badgeDescriptionBM"].ToString()
                                    : reader["badgeDescriptionEN"] != DBNull.Value
                                        ? reader["badgeDescriptionEN"].ToString()
                                        : "";

                            string requirementText = reader["requirementDescriptionEN"] != DBNull.Value
                                ? reader["requirementDescriptionEN"].ToString()
                                : "";
                            int xpReward = reader["xpReward"] != DBNull.Value
                                ? Convert.ToInt32(reader["xpReward"])
                                : 0;
                            string earnedDateFormatted = hasBeenEarned
                                ? Convert.ToDateTime(reader["earnedAt"]).ToString("dd MMM yyyy")
                                : "";

                            string truncatedDescription = badgeDescription.Length > 100
                                ? badgeDescription.Substring(0, 100) + "..."
                                : badgeDescription;
                            string truncatedRequirement = requirementText.Length > 80
                                ? requirementText.Substring(0, 80) + "..."
                                : requirementText;

                            string cardCssClass = hasBeenEarned
                                ? "pt-badge-card pt-badge-card-earned"
                                : "pt-badge-card pt-badge-card-locked";
                            string lockOverlay = hasBeenEarned
                                ? ""
                                : "<div class=\"pt-badge-lock-icon\"><i class=\"bi bi-lock-fill\"></i></div>";
                            string badgeIconMarkup = hasBeenEarned
                                ? "<div class=\"pt-badge-icon-wrap pt-badge-icon-earned\"><i class=\"bi bi-award-fill\"></i></div>"
                                : "<div class=\"pt-badge-icon-wrap pt-badge-icon-locked\"><i class=\"bi bi-award-fill\"></i></div>";
                            string statusPillMarkup = hasBeenEarned
                                ? "<div class=\"pt-badge-status-pill pt-badge-pill-earned\">"
                                    + T("Earned", "Diperoleh") + " &bull; " + earnedDateFormatted + "</div>"
                                : "<div class=\"pt-badge-status-pill pt-badge-pill-locked\">"
                                    + T("Locked", "Terkunci") + "</div>";

                            badgeGridHtml.Append("<div class=\"" + cardCssClass + "\">");
                            badgeGridHtml.Append(lockOverlay);
                            badgeGridHtml.Append(badgeIconMarkup);
                            badgeGridHtml.Append("<div class=\"pt-badge-card-name\">"
                                + Server.HtmlEncode(badgeDisplayName) + "</div>");
                            badgeGridHtml.Append("<div class=\"pt-badge-card-desc\">"
                                + Server.HtmlEncode(truncatedDescription) + "</div>");
                            badgeGridHtml.Append("<div class=\"pt-badge-card-req\">"
                                + Server.HtmlEncode(truncatedRequirement) + "</div>");
                            badgeGridHtml.Append("<div class=\"pt-badge-card-xp\">+"
                                + xpReward + " XP</div>");
                            badgeGridHtml.Append(statusPillMarkup);
                            badgeGridHtml.Append("</div>");
                        }

                        badgeGridHtml.Append("</div>");

                        if (hasBadgeRecords)
                        {
                            pnlBadgeGrid.Controls.Add(new LiteralControl(badgeGridHtml.ToString()));
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

        // ═══════════════════════════════════════════════════
        //  NOTIFICATION BADGE
        // ═══════════════════════════════════════════════════
        private void LoadUnreadBadge()
        {
            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(
                    "SELECT COUNT(*) FROM dbo.Notification WHERE toUserId = @userId AND isRead = 0",
                    connection))
                {
                    command.Parameters.AddWithValue("@userId", Session["userId"].ToString());
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
