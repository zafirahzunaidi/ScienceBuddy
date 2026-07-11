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
                _studentId = sel;
                if (!string.IsNullOrEmpty(_studentId))
                { pnlProfile.Visible = true; pnlNoChild.Visible = false; LoadAll(); }
                else
                { pnlProfile.Visible = false; pnlNoChild.Visible = true; }
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
            litAchieveTitle.Text = T("Achievement Snapshot", "Ringkasan Pencapaian");
            litXPLabel.Text = T("XP Points", "Mata XP");
            litBadgeCountLabel.Text = T("Badges Earned", "Lencana Diperoleh");
        }

        private void LoadAll()
        {
            LoadIdentity();
            LoadPersonalityCard();
            LoadLevelCard();
            LoadAchievements();
            LoadBadgeCollection();
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
        //  PERSONALITY CARD
        // ═══════════════════════════════════════════════════
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
                    INNER JOIN dbo.[StudentParent] sp ON sp.studentId=s.studentId AND sp.parentId=@parentId
                    LEFT JOIN dbo.[Personality] p ON p.personalityId=s.personalityId
                    WHERE s.studentId=@studentId";
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@studentId", _studentId);
                    cmd.Parameters.AddWithValue("@parentId", _parentId);
                    conn.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            string pName = CurrentLanguage == "BM" ? (r["personalityNameBM"]?.ToString() ?? "") : (r["personalityNameEN"]?.ToString() ?? "");
                            string pDesc = CurrentLanguage == "BM" ? (r["descriptionBM"]?.ToString() ?? "") : (r["descriptionEN"]?.ToString() ?? "");
                            string avatar = r["avatar"] != DBNull.Value ? r["avatar"].ToString() : "";
                            string learnStyle = CurrentLanguage == "BM" ? (r["learningStyleBM"]?.ToString() ?? "") : (r["learningStyleEN"]?.ToString() ?? "");
                            string fullName = r["name"]?.ToString() ?? "-";
                            string nick = r["nickname"]?.ToString() ?? "-";
                            string rel = r["relationship"]?.ToString() ?? T("Family", "Keluarga");

                            if (!string.IsNullOrWhiteSpace(pName))
                            {
                                pnlPersonality.Visible = true;
                                litPersonalityTitle.Text = string.Format(T("Your child is a {0}:", "Anak anda ialah {0}:"), Server.HtmlEncode(pName));
                                litPersonalityDesc.Text = Server.HtmlEncode(pDesc);
                                litInfoFullName.Text = Server.HtmlEncode(fullName);
                                litInfoNickname.Text = Server.HtmlEncode(!string.IsNullOrWhiteSpace(nick) ? nick : "-");
                                litInfoRelationship.Text = Server.HtmlEncode(rel);
                                litInfoLearningStyle.Text = Server.HtmlEncode(!string.IsNullOrWhiteSpace(learnStyle) ? learnStyle : "-");
                                if (!string.IsNullOrWhiteSpace(avatar))
                                    imgPersonality.ImageUrl = ResolveUrl("~/" + avatar);
                                else
                                    imgPersonality.Visible = false;
                            }
                            else { pnlNoPersonality.Visible = true; }
                        }
                        else { pnlNoPersonality.Visible = true; }
                    }
                }
            }
            catch { pnlNoPersonality.Visible = true; }
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
                const string sql = @"SELECT l.levelNameEN, l.levelNameBM, l.levelDescriptionEN, l.levelDescriptionBM,
                    e.enrolledDate
                    FROM dbo.[Student] s
                    LEFT JOIN dbo.[Level] l ON l.levelId=s.currentLevelId
                    LEFT JOIN dbo.[Enrollment] e ON e.studentId=s.studentId AND e.levelId=s.currentLevelId AND e.status='Active'
                    WHERE s.studentId=@studentId";
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@studentId", _studentId);
                    conn.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        if (r.Read() && r["levelNameEN"] != DBNull.Value)
                        {
                            pnlLevelInfo.Visible = true;
                            string lvlName = CurrentLanguage == "BM" ? (r["levelNameBM"]?.ToString() ?? "-") : (r["levelNameEN"]?.ToString() ?? "-");
                            string lvlDesc = CurrentLanguage == "BM" ? (r["levelDescriptionBM"]?.ToString() ?? "") : (r["levelDescriptionEN"]?.ToString() ?? "");
                            string enrolled = r["enrolledDate"] != DBNull.Value ? Convert.ToDateTime(r["enrolledDate"]).ToString("dd MMM yyyy") : T("Not available", "Tidak tersedia");
                            litLevelName.Text = Server.HtmlEncode(lvlName);
                            litLevelDesc.Text = Server.HtmlEncode(lvlDesc);
                            litEnrolledSince.Text = T("Enrolled Since: ", "Didaftarkan Sejak: ") + Server.HtmlEncode(enrolled);
                        }
                        else { pnlNoLevel.Visible = true; }
                    }
                }
            }
            catch { pnlNoLevel.Visible = true; }
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

        private void LoadBadgeCollection()
        {
            pnlBadgeGrid.Controls.Clear();
            try
            {
                const string sql = @"SELECT b.badgeId, b.badgeNameEN, b.badgeNameBM, b.badgeDescriptionEN, b.badgeDescriptionBM,
                    b.requirementDescriptionEN, b.xpReward,
                    sb.earnedAt
                    FROM dbo.[Badge] b
                    LEFT JOIN dbo.[StudentBadge] sb ON b.badgeId=sb.badgeId AND sb.studentId=@s
                    ORDER BY CASE WHEN sb.earnedAt IS NOT NULL THEN 0 ELSE 1 END, sb.earnedAt DESC, b.badgeNameEN";
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@s", _studentId);
                    conn.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        var html = new System.Text.StringBuilder();
                        html.Append("<div class=\"pt-badge-grid\">");
                        bool hasBadges = false;
                        while (r.Read())
                        {
                            hasBadges = true;
                            bool earned = r["earnedAt"] != DBNull.Value;
                            string bname = CurrentLanguage == "BM" && r["badgeNameBM"] != DBNull.Value && !string.IsNullOrEmpty(r["badgeNameBM"].ToString()) ? r["badgeNameBM"].ToString() : r["badgeNameEN"] != DBNull.Value ? r["badgeNameEN"].ToString() : "";
                            string desc = CurrentLanguage == "BM" && r["badgeDescriptionBM"] != DBNull.Value && !string.IsNullOrEmpty(r["badgeDescriptionBM"].ToString()) ? r["badgeDescriptionBM"].ToString() : r["badgeDescriptionEN"] != DBNull.Value ? r["badgeDescriptionEN"].ToString() : "";
                            string req = r["requirementDescriptionEN"] != DBNull.Value ? r["requirementDescriptionEN"].ToString() : "";
                            int xp = r["xpReward"] != DBNull.Value ? Convert.ToInt32(r["xpReward"]) : 0;
                            string earnedDate = earned ? Convert.ToDateTime(r["earnedAt"]).ToString("dd MMM yyyy") : "";

                            string cardClass = earned ? "pt-badge-card pt-badge-card-earned" : "pt-badge-card pt-badge-card-locked";
                            string lockIcon = earned ? "" : "<div class=\"pt-badge-lock-icon\"><i class=\"bi bi-lock-fill\"></i></div>";
                            string badgeIcon = earned
                                ? "<div class=\"pt-badge-icon-wrap pt-badge-icon-earned\"><i class=\"bi bi-award-fill\"></i></div>"
                                : "<div class=\"pt-badge-icon-wrap pt-badge-icon-locked\"><i class=\"bi bi-award-fill\"></i></div>";
                            string statusPill = earned
                                ? "<div class=\"pt-badge-status-pill pt-badge-pill-earned\">" + T("Earned", "Diperoleh") + " &bull; " + earnedDate + "</div>"
                                : "<div class=\"pt-badge-status-pill pt-badge-pill-locked\">" + T("Locked", "Terkunci") + "</div>";

                            html.Append("<div class=\"" + cardClass + "\">");
                            html.Append(lockIcon);
                            html.Append(badgeIcon);
                            html.Append("<div class=\"pt-badge-card-name\">" + Server.HtmlEncode(bname) + "</div>");
                            html.Append("<div class=\"pt-badge-card-desc\">" + Server.HtmlEncode(desc.Length > 100 ? desc.Substring(0, 100) + "..." : desc) + "</div>");
                            html.Append("<div class=\"pt-badge-card-req\">" + Server.HtmlEncode(req.Length > 80 ? req.Substring(0, 80) + "..." : req) + "</div>");
                            html.Append("<div class=\"pt-badge-card-xp\">+" + xp + " XP</div>");
                            html.Append(statusPill);
                            html.Append("</div>");
                        }
                        html.Append("</div>");
                        if (hasBadges) { pnlBadgeGrid.Controls.Add(new LiteralControl(html.ToString())); pnlNoBadges.Visible = false; }
                        else { pnlNoBadges.Visible = true; }
                    }
                }
            }
            catch { pnlNoBadges.Visible = true; }
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