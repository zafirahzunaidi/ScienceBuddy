<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MyRanking.aspx.cs"
    Inherits="ScienceBuddy.Student.MyRanking1" MasterPageFile="~/Site.Master"
    Title="My Ranking" %>
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
        <a href="<%: ResolveUrl("~/Student/ProgressRewards.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-bar-chart-line item-icon"></i><span class="item-label">Progress &amp; Rewards</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/MyRanking.aspx") %>" class="sb-sidebar-item active">
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
    <asp:Literal ID="litPageTitle" runat="server" Text="My Ranking" />
</asp:Content>

<%-- ════ MAIN CONTENT ════ --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- ── RANKING HERO ── --%>
<div class="st-ranking-hero">
    <div class="st-ranking-hero-blob1"></div><div class="st-ranking-hero-blob2"></div>
    <div class="st-ranking-hero-left">
        <div class="st-ranking-hero-title"><i class="bi bi-trophy-fill" style="color:#FACC15;"></i> <asp:Literal ID="litHeroRank" runat="server" Text="#1" /></div>
        <div class="st-ranking-hero-sub"><asp:Literal ID="litHeroMessage" runat="server" Text="See your position and keep improving step by step." /></div>
        <div class="st-ranking-hero-chips">
            <span class="st-ranking-hero-chip st-ranking-rank-chip"><i class="bi bi-trophy-fill"></i> <asp:Literal ID="litHeroXP" runat="server" Text="0 XP" /></span>
            <span class="st-ranking-hero-chip"><i class="bi bi-bar-chart-fill"></i> <asp:Literal ID="litHeroLevel" runat="server" Text="Level: &#x2014;" /></span>
        </div>
    </div>
    <div class="st-ranking-hero-right">
        <div class="st-ranking-hero-trophy"><i class="bi bi-trophy-fill" style="font-size:4.5rem;color:#FACC15;filter:drop-shadow(0 4px 12px rgba(0,0,0,.2));"></i></div>
    </div>
</div>

<%-- ── PERSONAL RANK CARD ── --%>
<div class="st-ranking-personal">
    <div class="st-ranking-personal-avatar"><asp:Literal ID="litPersonalInitial" runat="server" Text="S" /></div>
    <div class="st-ranking-personal-info">
        <div class="st-ranking-personal-name"><asp:Literal ID="litPersonalName" runat="server" Text="Student" /></div>
        <div class="st-ranking-personal-stats">
            <div class="st-ranking-personal-stat">
                <span class="st-ranking-personal-stat-val"><asp:Literal ID="litPersonalRank" runat="server" Text="#&#x2014;" /></span>
                <span class="st-ranking-personal-stat-lbl"><asp:Literal ID="litPersonalRankLbl" runat="server" Text="Rank" /></span>
            </div>
            <div class="st-ranking-personal-stat">
                <span class="st-ranking-personal-stat-val"><asp:Literal ID="litPersonalXP" runat="server" Text="0" /></span>
                <span class="st-ranking-personal-stat-lbl">XP</span>
            </div>
            <div class="st-ranking-personal-stat">
                <span class="st-ranking-personal-stat-val"><asp:Literal ID="litPersonalLevel" runat="server" Text="&#x2014;" /></span>
                <span class="st-ranking-personal-stat-lbl"><asp:Literal ID="litPersonalLevelLbl" runat="server" Text="Level" /></span>
            </div>
            <div class="st-ranking-personal-stat">
                <span class="st-ranking-personal-stat-val"><asp:Literal ID="litPersonalBadges" runat="server" Text="0" /></span>
                <span class="st-ranking-personal-stat-lbl"><asp:Literal ID="litPersonalBadgesLbl" runat="server" Text="Badges" /></span>
            </div>
        </div>
    </div>
</div>

<%-- ── TOP 3 PODIUM ── --%>
<div class="st-ranking-podium-section">
    <div class="st-ranking-podium-title"><i class="bi bi-trophy-fill" style="color:#FACC15;"></i> <asp:Literal ID="litPodiumTitle" runat="server" Text="Top 3 Champions" /></div>
    <asp:Literal ID="litPodium" runat="server" />
</div>

<%-- ── FILTERS ── --%>
<div class="st-ranking-filters">
    <div class="st-ranking-filters-label"><asp:Literal ID="litFilterLabel" runat="server" Text="Filter leaderboard" /></div>
    <div class="st-ranking-filter-chips">
        <asp:LinkButton ID="btnFilterAll" runat="server" CssClass="st-ranking-filter-chip active" OnClick="btnFilter_Click" CommandArgument="all" CausesValidation="false"><asp:Literal ID="litFAll" runat="server" Text="All Students" /></asp:LinkButton>
        <asp:LinkButton ID="btnFilterLevel" runat="server" CssClass="st-ranking-filter-chip" OnClick="btnFilter_Click" CommandArgument="level" CausesValidation="false"><asp:Literal ID="litFLevel" runat="server" Text="My Level" /></asp:LinkButton>
        <asp:LinkButton ID="btnFilterPers" runat="server" CssClass="st-ranking-filter-chip" OnClick="btnFilter_Click" CommandArgument="personality" CausesValidation="false"><asp:Literal ID="litFPers" runat="server" Text="My Personality" /></asp:LinkButton>
    </div>
</div>

<%-- ── TOP 10 LEADERBOARD ── --%>
<div class="st-ranking-board">
    <div class="st-ranking-board-header"><i class="bi bi-trophy-fill"></i> &nbsp;<asp:Literal ID="litBoardTitle" runat="server" Text="Top 10 Leaderboard" /></div>
    <div class="st-ranking-board-list">
        <asp:Panel ID="pnlBoard" runat="server">
            <asp:Repeater ID="rptLeaderboard" runat="server">
                <ItemTemplate>
                    <div class='<%# (bool)Eval("IsCurrentUser") ? "st-ranking-board-row st-ranking-current" : "st-ranking-board-row" %>'>
                        <div class='<%# GetRankClass((int)Eval("Rank")) %>'><%# Eval("Rank") %></div>
                        <div class="st-ranking-board-avatar"><%# Eval("Initial") %></div>
                        <div class="st-ranking-board-name"><%# Eval("DisplayName") %></div>
                        <div class="st-ranking-board-level"><%# Eval("LevelName") %></div>
                        <div class="st-ranking-board-xp"><%# Eval("XP") %> XP</div>
                        <div class="st-ranking-board-badges"><i class="bi bi-award-fill"></i> <%# Eval("BadgeCount") %></div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </asp:Panel>
    </div>
</div>

<%-- ── YOUR POSITION (shown if not in top 10) ── --%>
<asp:Panel ID="pnlYourPosition" runat="server" Visible="false">
    <div class="st-ranking-yourpos">
        <div>
            <div class="st-ranking-yourpos-title"><asp:Literal ID="litYourPosTitle" runat="server" Text="Your Position" /></div>
            <div class="st-ranking-yourpos-info">
                <span class="st-ranking-yourpos-rank"><asp:Literal ID="litYourPosRank" runat="server" Text="#&#x2014;" /></span>
                <span class="st-ranking-yourpos-name"><asp:Literal ID="litYourPosName" runat="server" Text="&#x2014;" /></span>
                <span class="st-ranking-yourpos-xp"><asp:Literal ID="litYourPosXP" runat="server" Text="0 XP" /></span>
            </div>
        </div>
    </div>
</asp:Panel>

<%-- ── MOTIVATIONAL SECTION ── --%>
<div class="st-ranking-motivate">
    <div class="st-ranking-motivate-icon"><i class="bi bi-lightning-charge-fill"></i></div>
    <div class="st-ranking-motivate-msg"><asp:Literal ID="litMotivateMsg" runat="server" Text="Every lesson gives you XP. Keep learning and your rank will improve." /></div>
</div>

<%-- ── XP TIPS ── --%>
<div class="st-ranking-tips">
    <div class="st-ranking-tips-title"><i class="bi bi-lightbulb-fill"></i> <asp:Literal ID="litTipsTitle" runat="server" Text="Ways to Earn XP" /></div>
    <div class="st-ranking-tips-grid">
        <div class="st-ranking-tip-card">
            <div class="st-ranking-tip-icon"><i class="bi bi-book-fill"></i></div>
            <div class="st-ranking-tip-label"><asp:Literal ID="litTip1" runat="server" Text="Complete lessons" /></div>
        </div>
        <div class="st-ranking-tip-card">
            <div class="st-ranking-tip-icon"><i class="bi bi-eyedropper"></i></div>
            <div class="st-ranking-tip-label"><asp:Literal ID="litTip2" runat="server" Text="Complete virtual labs" /></div>
        </div>
        <div class="st-ranking-tip-card">
            <div class="st-ranking-tip-icon"><i class="bi bi-patch-question-fill"></i></div>
            <div class="st-ranking-tip-label"><asp:Literal ID="litTip3" runat="server" Text="Attempt practice quizzes" /></div>
        </div>
        <div class="st-ranking-tip-card">
            <div class="st-ranking-tip-icon"><i class="bi bi-check-circle-fill"></i></div>
            <div class="st-ranking-tip-label"><asp:Literal ID="litTip4" runat="server" Text="Pass unit quizzes" /></div>
        </div>
    </div>
</div>

<%-- ── NAVIGATION BUTTONS ── --%>
<div class="st-ranking-nav">
    <a href="<%: ResolveUrl("~/Student/ProgressRewards.aspx") %>" class="st-ranking-nav-btn st-ranking-nav-btn-secondary">
        <i class="bi bi-arrow-left"></i> <asp:Literal ID="litNavBack" runat="server" Text="Back to Progress &amp; Rewards" />
    </a>
    <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="st-ranking-nav-btn st-ranking-nav-btn-primary">
        <i class="bi bi-play-circle-fill"></i> <asp:Literal ID="litNavLearn" runat="server" Text="Continue Learning" />
    </a>
    <a href="<%: ResolveUrl("~/Student/PracticeLibrary.aspx") %>" class="st-ranking-nav-btn st-ranking-nav-btn-secondary">
        <i class="bi bi-patch-question-fill"></i> <asp:Literal ID="litNavPractice" runat="server" Text="Practice Library" />
    </a>
</div>

</asp:Content>
