<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="ScienceBuddy.Student.Dashboard" %>

<asp:Content ID="HeadStyle" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%: ResolveUrl("~/Content/Student.css") %>" rel="stylesheet" />

</asp:Content>

<asp:Content ID="TopNavigationLinks" ContentPlaceHolderID="TopNavLinks" runat="server">
</asp:Content>

<asp:Content ID="TopNavActions" ContentPlaceHolderID="TopNavActions" runat="server">
</asp:Content>

<asp:Content ID="TopNavigationMainContent" ContentPlaceHolderID="MainContent" runat="server">
</asp:Content>

<%-- Student Sidebar --%>
<asp:Content ID="StudentSidebarMenu" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Main</div>
        <a href="<%: ResolveUrl("~/Student/Dashboard.aspx") %>" class="sb-sidebar-item active">
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
        <a href="<%: ResolveUrl("~/Student/ProgressRewards.aspx") %>" class="sb-sidebar-item">
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
    <asp:Panel ID="pnlNotifBadge" runat="server" Visible="false" style="display:none;"><asp:Literal ID="litNotifCount" runat="server" /></asp:Panel>
</asp:Content>

<asp:Content ID="StudentSidebarFooter" ContentPlaceHolderID="SidebarFooter" runat="server">
</asp:Content>

<asp:Content ID="DashboardPageTitle" ContentPlaceHolderID="PageTitle" runat="server">
</asp:Content>

<asp:Content ID="StudentUserDropdownMenu" ContentPlaceHolderID="UserDropdownMenu" runat="server">
</asp:Content>

<asp:Content ID="DashboardBreadcrumb" ContentPlaceHolderID="BreadcrumbContent" runat="server">
</asp:Content>

<%-- Dashboard Main Content --%>
<asp:Content ID="DashboardMainContent" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="st-dash-hero"
     style="background: linear-gradient(135deg,
            <%= PersonalityColour %> 0%,
            <%= PersonalityColour %>99 40%,
            #4DA8FF 100%);">

    <div class="st-dash-hero-blob1">
    </div>
    <div class="st-dash-hero-blob2">
    </div>
    <div class="st-dash-hero-blob3">
    </div>
    <div class="st-dash-hero-left">
        <div class="st-dash-hero-eyebrow">
            <i class="bi bi-stars">
            </i> 
            <asp:Literal ID="litHeroEyebrow" runat="server" Text="Science Learning" />
        </div>
        <div class="st-dash-hero-greeting">
            <asp:Literal ID="litGreeting" runat="server" Text="Hi there!" />
        </div>
        <div class="st-dash-hero-sub">
            <asp:Literal ID="litMotivation" runat="server" Text="Ready to explore science today?" />
        </div>
        <div class="st-dash-hero-chips">
            <span class="st-dash-hero-chip">
                <i class="bi bi-bar-chart-fill"></i> 
                <asp:Literal ID="litHeroLevel" runat="server" Text="Level: -" />
            </span>
            <span class="st-dash-hero-chip">
                <i class="bi bi-stars"></i> 
                <asp:Literal ID="litHeroPersonality" runat="server" Text="-" />
            </span>
            <span class="st-dash-hero-chip xp-chip"><i class="bi bi-lightning-charge-fill"></i> <asp:Literal ID="litHeroXP" runat="server" Text="0 XP" /></span>
        </div>
        <div class="st-dash-hero-cta">
            <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="st-dash-hero-btn st-dash-hero-btn-primary">
                <i class="bi bi-play-circle-fill"></i> <asp:Literal ID="litHeroCTA1" runat="server" Text="Continue Learning" />
            </a>
            <a href="<%: ResolveUrl("~/Student/Progress.aspx") %>" class="st-dash-hero-btn st-dash-hero-btn-secondary">
                <i class="bi bi-trophy-fill"></i> <asp:Literal ID="litHeroCTA2" runat="server" Text="My Progress" />
            </a>
        </div>
    </div>
    <div class="st-dash-hero-right">
        <div class="st-dash-hero-avatar">
            <asp:Image ID="imgPersonalityAvatar" runat="server" AlternateText="Personality avatar"
                onerror="this.style.display='none';var fb=this.nextElementSibling;if(fb&&fb.firstChild)fb.firstChild.style.display='inline';" />
            <asp:Literal ID="litAvatarFallback" runat="server" />
        </div>
        <div class="st-dash-hero-avatar-label"><asp:Literal ID="litHeroPersonality2" runat="server" /></div>
    </div>
</div>

<%-- XP Gamification Bar --%>
<div class="st-dash-xp-bar-section" style="margin-bottom:var(--space-xl);">
    <span class="st-dash-xp-bar-label"><i class="bi bi-lightning-charge-fill"></i> <asp:Literal ID="litXPBarLabel" runat="server" Text="0 XP" /></span>
    <div class="st-dash-xp-bar-wrap">
        <div class="st-dash-xp-bar">
            <div class="st-dash-xp-bar-fill" id="xpBarFill" runat="server" style="width:0%"></div>
        </div>
        <div class="st-dash-xp-bar-info">
            <span><asp:Literal ID="litXPBarProgress" runat="server" Text="Level Progress" /></span>
            <span><asp:Literal ID="litXPBarHint" runat="server" Text="Keep learning to earn more XP!" /></span>
        </div>
    </div>
</div>

<%-- Statistics Cards --%>
<div class="st-dash-stats" style="margin-bottom:var(--space-xl);">
    <div class="st-dash-stat-card sc-level">
        <div class="st-dash-stat-top">
            <div class="st-dash-stat-icon" style="background:#DBEAFE;color:#1D4ED8;">
                <i class="bi bi-mortarboard-fill"></i></div>
            <span class="st-dash-stat-badge-pill" style="background:#DBEAFE;color:#1D4ED8;">Level</span>
        </div>
        <div class="st-dash-stat-val"><asp:Literal ID="litStatLevel" runat="server" Text="-" /></div>
        <div class="st-dash-stat-lbl"><asp:Literal ID="litStatLevelLbl" runat="server" Text="Current Level" /></div>
        <div class="st-dash-stat-sub"><asp:Literal ID="litStatLevelSub" runat="server" Text="Keep going to advance!" /></div>
    </div>
    <div class="st-dash-stat-card sc-xp">
        <div class="st-dash-stat-top">
            <div class="st-dash-stat-icon" style="background:#FFF0E8;color:#FF6B2C;"><i class="bi bi-lightning-charge-fill"></i></div>
            <span class="st-dash-stat-badge-pill" style="background:#FFF0E8;color:#FF6B2C;">XP</span>
        </div>
        <div class="st-dash-stat-val"><asp:Literal ID="litStatXP" runat="server" Text="0" /></div>
        <div class="st-dash-stat-lbl"><asp:Literal ID="litStatXPLbl" runat="server" Text="Total XP Earned" /></div>
        <div class="st-dash-stat-sub"><asp:Literal ID="litStatXPSub" runat="server" Text="Every lesson earns XP" /></div>
    </div>
    <div class="st-dash-stat-card sc-badge">
        <div class="st-dash-stat-top">
            <div class="st-dash-stat-icon" style="background:#FFFBEB;color:#B45309;"><i class="bi bi-award-fill"></i></div>
            <span class="st-dash-stat-badge-pill" style="background:#FFFBEB;color:#B45309;">Badges</span>
        </div>
        <div class="st-dash-stat-val"><asp:Literal ID="litStatBadges" runat="server" Text="0" /></div>
        <div class="st-dash-stat-lbl"><asp:Literal ID="litStatBadgesLbl" runat="server" Text="Badges Earned" /></div>
        <div class="st-dash-stat-sub"><asp:Literal ID="litStatBadgesSub" runat="server" Text="Complete tasks to earn more" /></div>
    </div>
    <div class="st-dash-stat-card sc-lesson">
        <div class="st-dash-stat-top">
            <div class="st-dash-stat-icon" style="background:#DCFCE7;color:#15803D;"><i class="bi bi-check-circle-fill"></i></div>
            <span class="st-dash-stat-badge-pill" style="background:#DCFCE7;color:#15803D;">Done</span>
        </div>
        <div class="st-dash-stat-val"><asp:Literal ID="litStatLessons" runat="server" Text="0" /></div>
        <div class="st-dash-stat-lbl"><asp:Literal ID="litStatLessonsLbl" runat="server" Text="Lessons Completed" /></div>
        <div class="st-dash-stat-sub"><asp:Literal ID="litStatLessonsSub" runat="server" Text="Great job so far!" /></div>
    </div>
</div>

<%-- Personality Ordered Sections Wrapper --%>
<%-- Code-behind sets CSS order on each panel via inline style --%>
<div class="st-dash-sections" id="sdSections" runat="server">

    <%-- Personality Recommendations --%>
    <asp:Panel ID="pnlSectionRec" runat="server">
        <div class="st-dash-rec-banner" id="divRecBanner" runat="server">
            <div class="st-dash-rec-banner-icon" id="divPersonalityAvatar" runat="server">
                <asp:Image ID="imgPersonalityThumb" runat="server" AlternateText="Personality"
                    onerror="this.style.display='none';var fb=this.nextElementSibling;if(fb&&fb.firstChild)fb.firstChild.style.display='inline';" />
                <asp:Literal ID="litPersonalityThumbFallback" runat="server" />
            </div>
            <div class="st-dash-rec-banner-body">
                <div class="st-dash-rec-banner-label"><asp:Literal ID="litRecLabel" runat="server" Text="Recommended for your learning style" /></div>
                <div class="st-dash-rec-banner-title"><asp:Literal ID="litPersonalityName" runat="server" Text="Learner" /></div>
                <div class="st-dash-rec-banner-sub"><asp:Literal ID="litPersonalityRec" runat="server" Text="Keep learning at your own pace!" /></div>
                <asp:HyperLink ID="lnkPersonalityAction" runat="server" NavigateUrl="#"
                    CssClass="st-dash-hero-btn st-dash-hero-btn-primary" style="display:inline-flex;">
                    <asp:Literal ID="litPersonalityAction" runat="server" Text="Get Started" />
                    <i class="bi bi-arrow-right"></i>
                </asp:HyperLink></div></div></asp:Panel><%-- Section: Continue Learning --%><asp:Panel ID="pnlSectionContinue" runat="server">
        <div class="st-dash-section-hd">
            <div class="st-dash-section-title"><span class="ico"><i class="bi bi-play-circle-fill"></i></span> <asp:Literal ID="litSecContinue" runat="server" Text="Continue Learning" /></div>
            <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="st-dash-view-all"><asp:Literal ID="litViewAll" runat="server" Text="View All" /> <i class="bi bi-arrow-right"></i></a>
        </div>
        <div class="st-dash-continue">
            <div class="st-dash-continue-header"><i class="bi bi-play-circle-fill"></i> &nbsp;<asp:Literal ID="litContinueHeader" runat="server" Text="Pick up where you left off" /></div>
            <div class="st-dash-continue-body">
                <asp:Panel ID="pnlContinue" runat="server">
                    <div class="st-dash-continue-meta"><i class="bi bi-bookmark-fill"></i> <asp:Literal ID="litContinueMeta" runat="server" Text="Next Lesson" /></div>
                    <div class="st-dash-continue-title"><asp:Literal ID="litContinueTitle" runat="server" Text="Your next lesson is ready" /></div>
                    <div class="st-dash-continue-sub"><asp:Literal ID="litContinueSub" runat="server" Text="Continue from where you left off." /></div>
                    <div class="st-dash-continue-bar-wrap">
                        <div class="st-dash-continue-bar-lbl">
                            <span>Unit Progress</span> <span style="color:var(--student);font-weight:700;">In Progress</span> </div><div class="st-dash-continue-bar">
                            <div class="st-dash-continue-bar-fill" id="continueFill" style="width:30%"></div>
                        </div>
                    </div>
                    <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>"
                       class="sb-btn sb-btn-orange">
                        <i class="bi bi-play-fill"></i> <asp:Literal ID="litContinueBtn" runat="server" Text="Continue Learning" />
                    </a>
                </asp:Panel>
                <asp:Panel ID="pnlContinueEmpty" runat="server" Visible="false">
                    <div class="sb-empty-state" style="padding:var(--space-xl) 0;">
                        <div class="empty-icon"><i class="bi bi-rocket-takeoff-fill" style="font-size:2.5rem;color:var(--student);"></i></div>
                        <div class="empty-title"><asp:Literal ID="litEmptyTitle" runat="server" Text="Ready to begin your adventure?" /></div>
                        <div class="empty-desc"><asp:Literal ID="litEmptyDesc" runat="server" Text="You haven't started any lessons yet. Dive in and discover science!" /></div>
                        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>"
                           class="sb-btn sb-btn-orange mt-md">
                            <i class="bi bi-play-fill"></i> <asp:Literal ID="litEmptyBtn" runat="server" Text="Start Learning" />
                        </a>
                    </div>
                </asp:Panel>
            </div>
        </div>
    </asp:Panel>

    <%-- Section: Quick Actions--%>
    <asp:Panel ID="pnlSectionQuick" runat="server">
        <div class="st-dash-section-hd">
            <div class="st-dash-section-title"><span class="ico"><i class="bi bi-grid-fill"></i></span> <asp:Literal ID="litSecQuick" runat="server" Text="Quick Actions" /></div>
        </div>
        <div class="st-dash-quick-grid">
            <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="st-dash-quick-card qc-learn">
                <div class="st-dash-quick-icon" style="background:#DBEAFE;color:#1D4ED8;"><i class="bi bi-book-half"></i></div>
                <div class="st-dash-quick-label"><asp:Literal ID="litQALearn" runat="server" Text="My Learning" /></div>
                <div class="st-dash-quick-desc"><asp:Literal ID="litQALearnDesc" runat="server" Text="Lessons, subtopics &amp; units" /></div>
            </a>
            <a href="<%: ResolveUrl("~/Student/PracticeLibrary.aspx") %>" class="st-dash-quick-card qc-quiz">
                <div class="st-dash-quick-icon" style="background:#FFFBEB;color:#B45309;"><i class="bi bi-patch-question-fill"></i></div>
                <div class="st-dash-quick-label"><asp:Literal ID="litQAPractice" runat="server" Text="Practice Library" /></div>
                <div class="st-dash-quick-desc"><asp:Literal ID="litQAPracticeDesc" runat="server" Text="Quizzes &amp; self-assessment" /></div>
            </a>
            <a href="<%: ResolveUrl("~/Student/VirtualLabs.aspx") %>" class="st-dash-quick-card qc-lab">
                <div class="st-dash-quick-icon" style="background:#DCFCE7;color:#15803D;"><i class="bi bi-eyedropper"></i></div>
                <div class="st-dash-quick-label"><asp:Literal ID="litQALab" runat="server" Text="Virtual Labs" /></div>
                <div class="st-dash-quick-desc"><asp:Literal ID="litQALabDesc" runat="server" Text="Interactive science experiments" /></div>
            </a>
            <a href="#" class="st-dash-quick-card qc-live">
                <div class="st-dash-quick-icon" style="background:#E0F2FE;color:#0369A1;"><i class="bi bi-camera-video-fill"></i></div>
                <div class="st-dash-quick-label"><asp:Literal ID="litQALive" runat="server" Text="Live Sessions" /></div>
                <div class="st-dash-quick-desc"><asp:Literal ID="litQALiveDesc" runat="server" Text="Join teacher-led classes" /></div>
            </a>
            <a href="<%: ResolveUrl("~/Student/AIStudyCompanion.aspx") %>" class="st-dash-quick-card qc-ai">
                <div class="st-dash-quick-icon" style="background:#F3E8FF;color:#7C3AED;"><i class="bi bi-robot"></i></div>
                <div class="st-dash-quick-label"><asp:Literal ID="litQAAI" runat="server" Text="AI Study Companion" /></div>
                <div class="st-dash-quick-desc"><asp:Literal ID="litQAAIDesc" runat="server" Text="Personalised help &amp; hints" /></div>
            </a>
            <a href="<%: ResolveUrl("~/Student/ProgressRewards.aspx") %>" class="st-dash-quick-card qc-progress">
                <div class="st-dash-quick-icon" style="background:#FFF0E8;color:#FF6B2C;"><i class="bi bi-trophy-fill"></i></div>
                <div class="st-dash-quick-label"><asp:Literal ID="litQAProgress" runat="server" Text="Progress &amp; Rewards" /></div>
                <div class="st-dash-quick-desc"><asp:Literal ID="litQAProgressDesc" runat="server" Text="XP, badges &amp; achievements" /></div>
            </a>
            <a href="<%: ResolveUrl("~/Student/QuizHistory.aspx") %>" class="st-dash-quick-card qc-learn">
                <div class="st-dash-quick-icon" style="background:#E0F2FE;color:#0369A1;"><i class="bi bi-clock-history"></i></div>
                <div class="st-dash-quick-label"><asp:Literal ID="litQAHistory" runat="server" Text="Quiz History" /></div>
                <div class="st-dash-quick-desc"><asp:Literal ID="litQAHistoryDesc" runat="server" Text="Past attempts &amp; scores" /></div>
            </a>
        </div>
    </asp:Panel>

    <%-- Section: Social (Socializer personality) --%>
    <asp:Panel ID="pnlSectionSocial" runat="server" Visible="false">
        <div class="st-dash-section-hd">
            <div class="st-dash-section-title"><span class="ico"><i class="bi bi-people-fill"></i></span> <asp:Literal ID="litSecSocial" runat="server" Text="Learn Together" /></div>
        </div>
        <div class="st-dash-social-grid">
            <a href="<%: ResolveUrl("~/Student/Forum.aspx") %>" class="st-dash-social-card">
                <div class="st-dash-social-icon" style="background:#E0F2FE;color:#0369A1;"><i class="bi bi-chat-dots-fill"></i></div>
                <div><div class="st-dash-social-label">Forum</div><div class="st-dash-social-sub">Discuss with classmates</div></div></a><a href="#" class="st-dash-social-card"><div class="st-dash-social-icon" style="background:#DCFCE7;color:#15803D;"><i class="bi bi-camera-video-fill"></i></div>
                <div><div class="st-dash-social-label">Live Sessions</div><div class="st-dash-social-sub">Join a teacher live class</div></div></a><a href="<%: ResolveUrl("~/Student/Messages.aspx") %>" class="st-dash-social-card"><div class="st-dash-social-icon" style="background:#F3E8FF;color:#7C3AED;"><i class="bi bi-envelope-fill"></i></div>
                <div><div class="st-dash-social-label">Messages</div><div class="st-dash-social-sub">Chat with your teacher</div></div></a><a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="st-dash-social-card"><div class="st-dash-social-icon" style="background:#FFF0E8;color:#FF6B2C;"><i class="bi bi-book-fill"></i></div>
                <div><div class="st-dash-social-label">Continue Learning</div><div class="st-dash-social-sub">Pick up your next lesson</div></div></a></div></asp:Panel><%-- Section: Notifications --%><asp:Panel ID="pnlSectionNotif" runat="server">
        <div class="st-dash-section-hd">
            <div class="st-dash-section-title"><span class="ico"><i class="bi bi-bell-fill"></i></span> <asp:Literal ID="litSecNotif" runat="server" Text="Recent Notifications" /></div>
            <a href="#" class="st-dash-view-all"><asp:Literal ID="litSeeAll" runat="server" Text="See All" /> <i class="bi bi-arrow-right"></i></a>
        </div>
        <div class="st-dash-notif-card">
            <div class="st-dash-notif-hdr">
                <div class="st-dash-notif-hdr-title"><i class="bi bi-bell-fill" style="color:var(--student)"></i> Notifications</div><asp:Panel ID="pnlUnreadBadge" runat="server" Visible="false">
                    <span class="sb-badge sb-badge-error sb-badge-sm"><asp:Literal ID="litUnreadCount" runat="server" /></span>
                </asp:Panel>
            </div>
            <div class="st-dash-notif-list">
                <asp:Panel ID="pnlNotifications" runat="server">
                    <asp:Repeater ID="rptNotifications" runat="server">
                        <ItemTemplate>
                            <div class="st-dash-notif-item">
                                <div class="st-dash-notif-dot <%# (bool)Eval("isRead") ? "read" : "" %>"></div>
                                <div>
                                    <div class="st-dash-notif-title"><%# Eval("title") %></div>
                                    <div class="st-dash-notif-time"><i class="bi bi-clock"></i> <%# Eval("timeAgo") %></div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </asp:Panel>
                <asp:Panel ID="pnlNotificationsEmpty" runat="server" Visible="false">
                    <div class="sb-empty-state" style="padding:var(--space-lg) 0;">
                        <div class="empty-icon" style="font-size:2.5rem;"><i class="bi bi-inbox" style="color:var(--color-text-muted);"></i></div>
                        <div class="empty-title"><asp:Literal ID="litNotifEmpty" runat="server" Text="You're all caught up!" /></div>
                        <div class="empty-desc"><asp:Literal ID="litNotifEmptyDesc" runat="server" Text="No new notifications right now. Check back later." /></div>
                    </div>
                </asp:Panel>
            </div>
        </div>
    </asp:Panel>

</div>
</asp:Content>

<asp:Content ID="DashboardScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
</asp:Content>
