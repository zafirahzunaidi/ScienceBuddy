<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ProgressRewards.aspx.cs"
    Inherits="ScienceBuddy.Student.ProgressReward" MasterPageFile="~/Site.Master"
    Title="Progress &amp; Rewards" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Student.css") %>" rel="stylesheet" />
</asp:Content>

<%-- ════ SIDEBAR ════ --%>
<asp:Content ID="cSidebarMenu" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Main</div>
        <a href="<%: ResolveUrl("~/Student/Dashboard.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-speedometer2 item-icon"></i><span class="item-label">Dashboard</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/Notifications.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Learn</div>
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-book item-icon"></i><span class="item-label">My Learning</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/PracticeLibrary.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-patch-question item-icon"></i><span class="item-label">Practice Library</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/QuizHistory.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-clock-history item-icon"></i><span class="item-label">Quiz History</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/VirtualLabs.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-eyedropper item-icon"></i><span class="item-label">Virtual Labs</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/LiveSessions.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-camera-video item-icon"></i><span class="item-label">Live Sessions</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/AIStudyCompanion.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-robot item-icon"></i><span class="item-label">AI Study Companion</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Communication</div>
        <a href="<%: ResolveUrl("~/Student/Messages.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-chat-dots item-icon"></i><span class="item-label">Messages</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/Forum.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-people item-icon"></i><span class="item-label">Forum</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Progress</div>
        <a href="<%: ResolveUrl("~/Student/ProgressRewards.aspx") %>" class="sb-sidebar-item active">
            <i class="bi bi-bar-chart-line item-icon"></i><span class="item-label">Progress &amp; Rewards</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/MyRanking.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-trophy item-icon"></i><span class="item-label">My Ranking</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Student/MyProfile.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span>
        </a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <asp:Literal ID="litPageTitle" runat="server" Text="Progress &amp; Rewards" />
</asp:Content>

<%-- ════ MAIN CONTENT ════ --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- ── HERO SECTION ── --%>
<div class="st-progress-hero">
    <div class="st-progress-hero-name"><i class="bi bi-trophy-fill"></i> <asp:Literal ID="litHeroName" runat="server" /></div>
    <div class="st-progress-hero-meta">
        <span><i class="bi bi-trophy"></i> <asp:Literal ID="litHeroLevel" runat="server" /></span>
        <span><i class="bi bi-star-fill"></i> <asp:Literal ID="litHeroXP" runat="server" /> XP</span>
        <span><i class="bi bi-emoji-smile"></i> <asp:Literal ID="litHeroPersonality" runat="server" /></span>
    </div>
    <div class="st-progress-hero-motivate"><asp:Literal ID="litHeroMotivate" runat="server" /></div>
</div>

<%-- ── XP PROGRESS BAR ── --%>
<div class="st-progress-xp">
    <div class="st-progress-xp-header">
        <div class="st-progress-xp-title"><i class="bi bi-lightning-charge-fill" style="color:#F59E0B;"></i> <asp:Literal ID="litXpTitle" runat="server" Text="XP Progress" /></div>
        <div class="st-progress-xp-milestone"><asp:Literal ID="litXpMilestone" runat="server" /></div>
    </div>
    <div class="st-progress-xp-bar-outer">
        <div class="st-progress-xp-bar-inner" style="width:<%= XpPercent %>%;"></div>
    </div>
    <div class="st-progress-xp-labels">
        <span><asp:Literal ID="litXpCurrent" runat="server" /></span>
        <span><asp:Literal ID="litXpNext" runat="server" /></span>
    </div>
</div>

<%-- ── PROGRESS SUMMARY CARDS ── --%>
<div class="st-progress-summary">
    <div class="st-progress-stat-card">
        <div class="st-progress-stat-icon"><i class="bi bi-book-fill" style="color:#2563EB;"></i></div>
        <div class="st-progress-stat-value"><asp:Literal ID="litLessonsCount" runat="server" Text="0" /></div>
        <div class="st-progress-stat-label"><asp:Literal ID="litLessonsLabel" runat="server" Text="Lessons Completed" /></div>
    </div>
    <div class="st-progress-stat-card">
        <div class="st-progress-stat-icon"><i class="bi bi-eyedropper" style="color:#7C3AED;"></i></div>
        <div class="st-progress-stat-value"><asp:Literal ID="litLabsCount" runat="server" Text="0" /></div>
        <div class="st-progress-stat-label"><asp:Literal ID="litLabsLabel" runat="server" Text="Labs Completed" /></div>
    </div>
    <div class="st-progress-stat-card">
        <div class="st-progress-stat-icon"><i class="bi bi-patch-question-fill" style="color:#0EA5E9;"></i></div>
        <div class="st-progress-stat-value"><asp:Literal ID="litQuizzesCount" runat="server" Text="0" /></div>
        <div class="st-progress-stat-label"><asp:Literal ID="litQuizzesLabel" runat="server" Text="Quizzes Attempted" /></div>
    </div>
    <div class="st-progress-stat-card">
        <div class="st-progress-stat-icon"><i class="bi bi-award-fill" style="color:#F59E0B;"></i></div>
        <div class="st-progress-stat-value"><asp:Literal ID="litBadgesCount" runat="server" Text="0" /></div>
        <div class="st-progress-stat-label"><asp:Literal ID="litBadgesLabel" runat="server" Text="Badges Earned" /></div>
    </div>
    <div class="st-progress-stat-card">
        <div class="st-progress-stat-icon"><i class="bi bi-file-earmark-check-fill" style="color:#15803D;"></i></div>
        <div class="st-progress-stat-value"><asp:Literal ID="litCertsCount" runat="server" Text="0" /></div>
        <div class="st-progress-stat-label"><asp:Literal ID="litCertsLabel" runat="server" Text="Certificates Earned" /></div>
    </div>
    <asp:Literal ID="litTotalXP" runat="server" Visible="false" /><asp:Literal ID="litTotalXPLabel" runat="server" Visible="false" />
</div>

<%-- ── BADGE COLLECTION ── --%>
<div class="st-progress-badges">
    <div class="st-progress-section-title"><i class="bi bi-award"></i> <asp:Literal ID="litBadgeSection" runat="server" Text="Badge Collection" /></div>
    <asp:Panel ID="pnlBadges" runat="server">
        <div class="st-progress-badge-grid">
            <asp:Repeater ID="rptBadges" runat="server">
                <ItemTemplate>
                    <div class='st-progress-badge-card <%# (bool)Eval("IsEarned") ? "earned" : "locked" %>'>
                        <%# !(bool)Eval("IsEarned") ? "<i class=\"bi bi-lock-fill st-progress-lock-icon\"></i>" : "" %>
                        <div class="st-progress-badge-icon"><img src='<%# Eval("IconUrl") %>' alt='<%# Eval("Name") %>' style="width:80px;height:80px;object-fit:contain;" onerror="this.style.display='none';this.nextElementSibling.style.display='inline';" /><i class="bi bi-award-fill" style="display:none;font-size:2.5rem;color:#F59E0B;"></i></div>
                        <div class="st-progress-badge-name"><%# Eval("Name") %></div>
                        <div class="st-progress-badge-desc"><%# Eval("Description") %></div>
                        <div class="st-progress-badge-req"><%# Eval("Requirement") %></div>
                        <div class="st-progress-badge-xp">+<%# Eval("XpReward") %> XP</div>
                        <span class='st-progress-badge-status <%# (bool)Eval("IsEarned") ? "earned-tag" : "locked-tag" %>'>
                            <%# (bool)Eval("IsEarned") ? Eval("EarnedText") : Eval("LockedText") %>
                        </span>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlNoBadges" runat="server" Visible="false">
        <div class="st-progress-empty-state">
            <i class="bi bi-award"></i>
            <asp:Literal ID="litNoBadges" runat="server" Text="No badges available yet." />
        </div>
    </asp:Panel>
</div>

<%-- ── RECENT XP ACTIVITY ── --%>
<div class="st-progress-xp-activity">
    <div class="st-progress-section-title"><i class="bi bi-lightning-charge"></i> <asp:Literal ID="litActivitySection" runat="server" Text="Recent XP Activity" /></div>
    <asp:Panel ID="pnlActivity" runat="server">
        <div class="st-progress-activity-list">
            <asp:Repeater ID="rptActivity" runat="server">
                <ItemTemplate>
                    <div class="st-progress-activity-item">
                        <div class="st-progress-activity-left">
                            <div class="st-progress-activity-icon"><i class="bi bi-star-fill"></i></div>
                            <div>
                                <div class="st-progress-activity-name"><%# Eval("ActionName") %></div>
                                <div class="st-progress-activity-date"><%# Eval("Date") %></div>
                            </div>
                        </div>
                        <div class="st-progress-activity-xp">+<%# Eval("XpAmount") %> XP</div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlNoActivity" runat="server" Visible="false">
        <div class="st-progress-empty-state">
            <i class="bi bi-lightning-charge"></i>
            <asp:Literal ID="litNoActivity" runat="server" Text="No XP activity yet." />
        </div>
    </asp:Panel>
</div>

<%-- ── CERTIFICATES ── --%>
<div class="st-progress-certs">
    <div class="st-progress-section-title"><i class="bi bi-file-earmark-check"></i> <asp:Literal ID="litCertSection" runat="server" Text="Certificates" /></div>
    <asp:Panel ID="pnlCerts" runat="server">
        <div class="st-progress-cert-grid">
            <asp:Repeater ID="rptCerts" runat="server">
                <ItemTemplate>
                    <div class="st-progress-cert-card">
                        <div class="st-progress-cert-icon"><i class="bi bi-file-earmark-check-fill" style="color:#F59E0B;"></i></div>
                        <div class="st-progress-cert-title"><%# Eval("Title") %></div>
                        <div class="st-progress-cert-level"><i class="bi bi-bar-chart-steps"></i> <%# Eval("Level") %></div>
                        <div class="st-progress-cert-date"><i class="bi bi-calendar3"></i> <%# Eval("IssuedDate") %></div>
                        <%# (bool)Eval("HasUrl") ? "<a href='" + Eval("Url") + "' target='_blank' class='st-progress-cert-btn'><i class='bi bi-download'></i> " + Eval("ViewText") + "</a>" : "" %>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlNoCerts" runat="server" Visible="false">
        <div class="st-progress-empty-state">
            <i class="bi bi-file-earmark-check"></i>
            <asp:Literal ID="litNoCerts" runat="server" Text="No certificates yet." />
        </div>
    </asp:Panel>
</div>

<%-- Navigation (hidden - kept for code-behind) --%>
<asp:Literal ID="litNavRanking" runat="server" Visible="false" />
<asp:Literal ID="litNavLearning" runat="server" Visible="false" />
<asp:Literal ID="litNavPractice" runat="server" Visible="false" />
<asp:Literal ID="litNavLabs" runat="server" Visible="false" />

</asp:Content>
