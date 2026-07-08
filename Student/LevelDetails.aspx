<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="LevelDetails.aspx.cs" Inherits="ScienceBuddy.Student.LevelDetails1" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%: ResolveUrl("~/Content/Student.css") %>" rel="stylesheet" />
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
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
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="sb-sidebar-item active">
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
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <asp:Literal ID="litPageTitle" runat="server" Text="Level Details" />
</asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- LOCKED STATE --%>
<asp:Panel ID="pnlLocked" runat="server" Visible="false">
    <div class="st-leveldetails-locked">
        <div class="st-leveldetails-locked-icon">🔒</div>
        <div class="st-leveldetails-locked-title"><asp:Literal ID="litLockedTitle" runat="server" /></div>
        <div class="st-leveldetails-locked-desc"><asp:Literal ID="litLockedDesc" runat="server" /></div>
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="sb-btn sb-btn-primary sb-btn-sm">
            <i class="bi bi-arrow-left"></i> <asp:Literal ID="litLockedBtn" runat="server" />
        </a>
    </div>
</asp:Panel>

<%-- MAIN CONTENT --%>
<asp:Panel ID="pnlMain" runat="server">

<%-- Hero --%>
<div class="st-leveldetails-hero">
    <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="st-leveldetails-hero-back"><i class="bi bi-arrow-left"></i> <asp:Literal ID="litBack" runat="server" /></a>
    <div class="st-leveldetails-hero-name"><asp:Literal ID="litLevelName" runat="server" /></div>
    <div class="st-leveldetails-hero-desc"><asp:Literal ID="litLevelDesc" runat="server" /></div>
    <div class="st-leveldetails-hero-badge"><i class="bi bi-bar-chart-fill"></i> <asp:Literal ID="litHeroBadge" runat="server" /></div>
    <div class="st-leveldetails-hero-progress">
        <div class="st-leveldetails-hero-bar"><div class="st-leveldetails-hero-fill" id="heroFill" runat="server" style="width:0%"></div></div>
        <div class="st-leveldetails-hero-bar-lbl"><span><asp:Literal ID="litProgressLbl" runat="server" /></span><span><asp:Literal ID="litProgressPct" runat="server" Text="0%" /></span></div>
    </div>
</div>

<%-- Stats --%>
<div class="st-leveldetails-stats">
    <div class="st-leveldetails-stat"><div class="st-leveldetails-stat-icon" style="background:#DBEAFE;color:#1D4ED8;"><i class="bi bi-collection-fill"></i></div>
        <div><div class="st-leveldetails-stat-val"><asp:Literal ID="litStatUnits" runat="server" Text="0" /></div><div class="st-leveldetails-stat-lbl"><asp:Literal ID="litStatUnitsLbl" runat="server" /></div></div></div>
    <div class="st-leveldetails-stat"><div class="st-leveldetails-stat-icon" style="background:#DCFCE7;color:#15803D;"><i class="bi bi-check2-circle"></i></div>
        <div><div class="st-leveldetails-stat-val"><asp:Literal ID="litStatDone" runat="server" Text="0" /></div><div class="st-leveldetails-stat-lbl"><asp:Literal ID="litStatDoneLbl" runat="server" /></div></div></div>
    <div class="st-leveldetails-stat"><div class="st-leveldetails-stat-icon" style="background:var(--student-light);color:var(--student);"><i class="bi bi-journal-check"></i></div>
        <div><div class="st-leveldetails-stat-val"><asp:Literal ID="litStatLessons" runat="server" Text="0" /></div><div class="st-leveldetails-stat-lbl"><asp:Literal ID="litStatLessonsLbl" runat="server" /></div></div></div>
    <div class="st-leveldetails-stat"><div class="st-leveldetails-stat-icon" style="background:#FFFBEB;color:#B45309;"><i class="bi bi-patch-check-fill"></i></div>
        <div><div class="st-leveldetails-stat-val"><asp:Literal ID="litStatQuiz" runat="server" Text="0" /></div><div class="st-leveldetails-stat-lbl"><asp:Literal ID="litStatQuizLbl" runat="server" /></div></div></div>
</div>

<%-- Unit Roadmap --%>
<asp:Panel ID="pnlUnits" runat="server">
    <div class="st-leveldetails-sec-hd"><i class="bi bi-signpost-split-fill" style="color:var(--student);font-size:1.25rem;"></i>
        <div class="st-leveldetails-sec-title"><asp:Literal ID="litRoadmap" runat="server" /></div></div>
    <div class="st-leveldetails-roadmap">
        <asp:Repeater ID="rptUnits" runat="server">
            <ItemTemplate>
                <div class="st-leveldetails-unit">
                    <div class="st-leveldetails-dot <%# Eval("Dot") %>"></div>
                    <div class="st-leveldetails-unit-body">
                        <div class="st-leveldetails-unit-name"><%# Eval("Name") %></div>
                        <div class="st-leveldetails-unit-desc"><%# Eval("Desc") %></div>
                        <div class="st-leveldetails-unit-meta">
                            <span><i class="bi bi-layers"></i> <%# Eval("Subs") %> <%# Eval("SubLbl") %></span>
                            <span><i class="bi bi-journal-text"></i> <%# Eval("Lessons") %> <%# Eval("LessonLbl") %></span>
                            <span><i class="bi bi-check2"></i> <%# Eval("Done") %>/<%# Eval("Lessons") %></span>
                        </div>
                        <div class="st-leveldetails-unit-bar"><div class="st-leveldetails-unit-bar-fill" style="width:<%# Eval("Pct") %>%"></div></div>
                        <a href="<%# Eval("Url") %>" class="sb-btn sb-btn-orange sb-btn-xs"><i class="bi bi-arrow-right"></i> <%# Eval("Btn") %></a>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>

<asp:Panel ID="pnlUnitsEmpty" runat="server" Visible="false">
    <div class="sb-empty-state" style="padding:var(--space-2xl) 0;">
        <div class="empty-icon" style="font-size:3rem;">📦</div>
        <div class="empty-title"><asp:Literal ID="litEmptyTitle" runat="server" /></div>
        <div class="empty-desc"><asp:Literal ID="litEmptyDesc" runat="server" /></div>
    </div>
</asp:Panel>

<%-- Level Quiz --%>
<asp:Panel ID="pnlQuiz" runat="server" Visible="false">
    <div class="st-leveldetails-sec-hd"><i class="bi bi-trophy-fill" style="color:#B45309;font-size:1.25rem;"></i>
        <div class="st-leveldetails-sec-title"><asp:Literal ID="litQuizHd" runat="server" /></div></div>
    <div class="st-leveldetails-quiz">
        <div class="st-leveldetails-quiz-icon"><i class="bi bi-patch-check-fill"></i></div>
        <div class="st-leveldetails-quiz-body">
            <div class="st-leveldetails-quiz-title"><asp:Literal ID="litQuizTitle" runat="server" /></div>
            <div class="st-leveldetails-quiz-sub"><asp:Literal ID="litQuizSub" runat="server" /></div>
        </div>
        <a id="lnkQuizStart" runat="server" class="sb-btn sb-btn-white sb-btn-sm"><i class="bi bi-play-fill"></i> <asp:Literal ID="litQuizBtn" runat="server" /></a>
    </div>
    <asp:Panel ID="pnlQuizResult" runat="server" Visible="false" style="margin-top:var(--space-sm);display:flex;gap:8px;flex-wrap:wrap;">
        <a id="lnkQuizResult" runat="server" class="sb-btn sb-btn-outline-primary sb-btn-sm" style="font-size:.75rem;"><i class="bi bi-eye"></i> <asp:Literal ID="litQuizResultBtn" runat="server" /></a>
        <a id="lnkQuizReview" runat="server" class="sb-btn sb-btn-outline-primary sb-btn-sm" style="font-size:.75rem;"><i class="bi bi-search"></i> <asp:Literal ID="litQuizReviewBtn" runat="server" /></a>
    </asp:Panel>
</asp:Panel>

<asp:Panel ID="pnlQuizNone" runat="server" Visible="false">
    <div class="sb-alert sb-alert-info"><i class="bi bi-info-circle-fill alert-icon"></i>
        <div class="alert-content"><asp:Literal ID="litQuizNone" runat="server" /></div></div>
</asp:Panel>

</asp:Panel>
</asp:Content>
