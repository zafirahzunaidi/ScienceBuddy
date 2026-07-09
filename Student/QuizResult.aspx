<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="QuizResult.aspx.cs" Inherits="ScienceBuddy.Student.QuizResult" %>
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
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-book item-icon"></i><span class="item-label">My Learning</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/PracticeLibrary.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-patch-question item-icon"></i><span class="item-label">Practice Library</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/QuizHistory.aspx") %>" class="sb-sidebar-item active">
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
        <a href="<%: ResolveUrl("~/Student/RevisionPlan.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-calendar-check item-icon"></i><span class="item-label">Revision Plan</span>
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
    <asp:Literal ID="litPageTitle" runat="server" Text="Quiz Result" />
</asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- ERROR --%>
<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="st-quizresult-error">
        <div style="font-size:3rem;margin-bottom:var(--space-md);"><i class="bi bi-exclamation-triangle-fill" style="color:var(--student);"></i></div>
        <div style="font-family:var(--font-primary);font-size:1.25rem;font-weight:700;margin-bottom:8px;"><asp:Literal ID="litErrorTitle" runat="server" /></div>
        <div style="color:var(--color-text-secondary);margin-bottom:var(--space-lg);"><asp:Literal ID="litError" runat="server" /></div>
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="st-quizresult-btn st-quizresult-btn-primary"><i class="bi bi-arrow-left"></i> <asp:Literal ID="litErrBtn" runat="server" Text="Back" /></a>
    </div>
</asp:Panel>

<%-- RESULT --%>
<asp:Panel ID="pnlResult" runat="server" Visible="false">

    <%-- Hero --%>
    <div class="st-quizresult-hero" id="divHero" runat="server">
        <div class="st-quizresult-hero-blob"></div>
        <div class="st-quizresult-hero-icon"><asp:Literal ID="litHeroIcon" runat="server" /></div>
        <div class="st-quizresult-hero-title"><asp:Literal ID="litHeroTitle" runat="server" /></div>
        <div class="st-quizresult-hero-sub"><asp:Literal ID="litHeroSub" runat="server" /></div>
        <div class="st-quizresult-score-wrap">
            <div class="st-quizresult-score-ring"><asp:Literal ID="litScorePct" runat="server" /></div>
            <div class="st-quizresult-stars"><asp:Literal ID="litStars" runat="server" /></div>
        </div>
    </div>

    <%-- Stats --%>
    <div class="st-quizresult-stats">
        <div class="st-quizresult-stat">
            <div class="st-quizresult-stat-icon" style="background:#DCFCE7;color:#15803D;"><i class="bi bi-check-circle-fill"></i></div>
            <div class="st-quizresult-stat-val"><asp:Literal ID="litStatCorrect" runat="server" /></div>
            <div class="st-quizresult-stat-lbl"><asp:Literal ID="litStatCorrectLbl" runat="server" Text="Correct" /></div>
        </div>
        <div class="st-quizresult-stat">
            <div class="st-quizresult-stat-icon" style="background:#FEF2F2;color:#DC2626;"><i class="bi bi-x-circle-fill"></i></div>
            <div class="st-quizresult-stat-val"><asp:Literal ID="litStatWrong" runat="server" /></div>
            <div class="st-quizresult-stat-lbl"><asp:Literal ID="litStatWrongLbl" runat="server" Text="Wrong" /></div>
        </div>
        <div class="st-quizresult-stat">
            <div class="st-quizresult-stat-icon" style="background:#EFF6FF;color:#2563EB;"><i class="bi bi-list-check"></i></div>
            <div class="st-quizresult-stat-val"><asp:Literal ID="litStatTotal" runat="server" /></div>
            <div class="st-quizresult-stat-lbl"><asp:Literal ID="litStatTotalLbl" runat="server" Text="Questions" /></div>
        </div>
        <div class="st-quizresult-stat">
            <div class="st-quizresult-stat-icon" style="background:#FFF0E8;color:#FF6B2C;"><i class="bi bi-trophy-fill"></i></div>
            <div class="st-quizresult-stat-val"><asp:Literal ID="litStatScore" runat="server" /></div>
            <div class="st-quizresult-stat-lbl"><asp:Literal ID="litStatScoreLbl" runat="server" Text="Score" /></div>
        </div>
        <div class="st-quizresult-stat">
            <div class="st-quizresult-stat-icon" style="background:#F3E8FF;color:#7C3AED;"><i class="bi bi-arrow-repeat"></i></div>
            <div class="st-quizresult-stat-val"><asp:Literal ID="litStatAttempt" runat="server" /></div>
            <div class="st-quizresult-stat-lbl"><asp:Literal ID="litStatAttemptLbl" runat="server" Text="Attempt" /></div>
        </div>
    </div>

    <%-- Quiz Type Message --%>
    <asp:Panel ID="pnlMessage" runat="server" Visible="false">
        <div class="st-quizresult-msg">
            <div class="st-quizresult-msg-icon" id="divMsgIcon" runat="server" style="background:#EFF6FF;color:#2563EB;"><i class="bi bi-info-circle-fill"></i></div>
            <div class="st-quizresult-msg-body">
                <div class="st-quizresult-msg-title"><asp:Literal ID="litMsgTitle" runat="server" /></div>
                <div class="st-quizresult-msg-text"><asp:Literal ID="litMessage" runat="server" /></div>
            </div>
        </div>
    </asp:Panel>

    <%-- Actions --%>
    <div class="st-quizresult-actions">
        <a href="#" id="lnkReview" runat="server" class="st-quizresult-btn st-quizresult-btn-primary"><i class="bi bi-search"></i> <asp:Literal ID="litReviewBtn" runat="server" Text="Review Answers" /></a>
        <asp:Panel ID="pnlRetry" runat="server" style="display:inline;">
            <a href="#" id="lnkRetry" runat="server" class="st-quizresult-btn st-quizresult-btn-retry"><i class="bi bi-arrow-repeat"></i> <asp:Literal ID="litRetryBtn" runat="server" Text="Try Again" /></a>
        </asp:Panel>
        <a href="#" id="lnkBack" runat="server" class="st-quizresult-btn st-quizresult-btn-secondary"><i class="bi bi-arrow-left"></i> <asp:Literal ID="litBackBtn" runat="server" Text="Back" /></a>
        <a href="<%: ResolveUrl("~/Student/ProgressRewards.aspx") %>" class="st-quizresult-btn st-quizresult-btn-green"><i class="bi bi-bar-chart-line-fill"></i> <asp:Literal ID="litProgressBtn" runat="server" Text="Progress" /></a>
        <a href="<%: ResolveUrl("~/Student/QuizHistory.aspx") %>" class="st-quizresult-btn st-quizresult-btn-secondary"><i class="bi bi-clock-history"></i> <asp:Literal ID="litHistoryBtn" runat="server" Text="Quiz History" /></a>
    </div>

</asp:Panel>
</asp:Content>
