<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RevisionPlan.aspx.cs"
    Inherits="ScienceBuddy.Student.RevisionPlan" MasterPageFile="~/Site.Master" Title="Revision Plan" %>

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
        <a href="<%: ResolveUrl("~/Student/RevisionPlan.aspx") %>" class="sb-sidebar-item active">
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
    <asp:Literal ID="litPageTitle" runat="server" Text="Revision Plan" />
</asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- ═══ HERO ═══ --%>
<div class="st-revision-hero">
    <div class="st-revision-hero-blob"></div>
    <div class="st-revision-hero-icon"><i class="bi bi-rocket-takeoff-fill"></i></div>
    <h1 class="st-revision-hero-title"><asp:Literal ID="litHeroTitle" runat="server" /></h1>
    <p class="st-revision-hero-sub"><asp:Literal ID="litHeroSub" runat="server" /></p>
</div>

<%-- ═══ EMPTY STATE ═══ --%>
<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="st-revision-empty">
        <div class="st-revision-empty-icon"><i class="bi bi-journal-x"></i></div>
        <div class="st-revision-empty-title"><asp:Literal ID="litEmptyTitle" runat="server" /></div>
        <div class="st-revision-empty-desc"><asp:Literal ID="litEmptyDesc" runat="server" /></div>
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="st-revision-empty-btn">
            <i class="bi bi-book"></i> <asp:Literal ID="litEmptyBtn" runat="server" />
        </a>
    </div>
</asp:Panel>

<%-- ═══ PLAN CONTENT ═══ --%>
<asp:Panel ID="pnlPlan" runat="server" Visible="false">

<%-- Alert --%>
<asp:Panel ID="pnlAlert" runat="server" Visible="false">
    <div id="divAlert" runat="server" class="st-revision-alert">
        <i id="iAlertIcon" runat="server" class="bi bi-exclamation-triangle-fill"></i>
        <asp:Literal ID="litAlert" runat="server" />
    </div>
</asp:Panel>

<%-- Summary Card --%>
<div class="st-revision-summary st-revision-summary-wow">
    <div class="st-revision-summary-deco"></div>
    <div class="st-revision-summary-top">
        <div class="st-revision-summary-title"><i class="bi bi-flag-fill"></i> <asp:Literal ID="litPlanTitle" runat="server" /></div>
        <span id="spanStatus" runat="server" class="st-revision-status-badge"><asp:Literal ID="litStatus" runat="server" /></span>
    </div>
    <div class="st-revision-summary-meta">
        <span><i class="bi bi-calendar3"></i> <asp:Literal ID="litDateRange" runat="server" /></span>
        <span><i class="bi bi-clock"></i> <asp:Literal ID="litRemaining" runat="server" /></span>
        <span><i class="bi bi-person-heart"></i> <asp:Literal ID="litParentLabel" runat="server" /></span>
    </div>

    <%-- Progress Badge + Bar --%>
    <div class="st-revision-progress-section">
        <div class="st-revision-progress-top-row">
            <div class="st-revision-progress-label">
                <i class="bi bi-lightning-charge-fill" style="color:#F59E0B;"></i> <asp:Literal ID="litProgressLabel" runat="server" />
            </div>
            <div id="divProgressBadge" runat="server" class="st-revision-progress-badge">
                <span class="st-revision-progress-badge-pct"><asp:Literal ID="litProgressPct" runat="server" /></span>
            </div>
        </div>
        <div class="st-revision-milestone-track">
            <div class="st-revision-progress-bar">
                <div class="st-revision-progress-fill" id="divProgressFill" runat="server"></div>
            </div>
            <asp:Literal ID="litMilestones" runat="server" />
        </div>
        <div class="st-revision-progress-counts"><asp:Literal ID="litTaskCounts" runat="server" /></div>
        <div class="st-revision-motivate-text"><asp:Literal ID="litMotivate" runat="server" /></div>
    </div>

    <%-- Reward Summary Cards --%>
    <div class="st-revision-reward-boxes">
        <div class="st-revision-reward-box st-revision-reward-box-next">
            <div class="st-revision-reward-box-img"><asp:Literal ID="litNextRewardImg" runat="server" /></div>
            <div class="st-revision-reward-box-body">
                <div class="st-revision-reward-box-label"><asp:Literal ID="litNextRewardLabel" runat="server" /></div>
                <div class="st-revision-reward-box-name"><asp:Literal ID="litNextReward" runat="server" /></div>
            </div>
        </div>
        <div class="st-revision-reward-box st-revision-reward-box-final">
            <div class="st-revision-reward-box-img"><asp:Literal ID="litFinalRewardImg" runat="server" /></div>
            <div class="st-revision-reward-box-body">
                <div class="st-revision-reward-box-label"><asp:Literal ID="litFinalRewardLabel" runat="server" /></div>
                <div class="st-revision-reward-box-name"><asp:Literal ID="litFinalReward" runat="server" /></div>
            </div>
        </div>
    </div>
</div>

<%-- Success Message --%>
<asp:Panel ID="pnlSuccess" runat="server" Visible="false">
    <div class="st-revision-success"><i class="bi bi-check-circle-fill"></i> <asp:Literal ID="litSuccess" runat="server" /></div>
</asp:Panel>

<%-- Task Filter Tabs --%>
<div class="st-revision-section-hd"><i class="bi bi-rocket-takeoff"></i> <asp:Literal ID="litTasksTitle" runat="server" /></div>
<div class="st-revision-filter-tabs">
    <asp:LinkButton ID="btnFilterPending" runat="server" CssClass="st-revision-tab active" OnClick="btnFilter_Click" CommandArgument="pending" CausesValidation="false" />
    <asp:LinkButton ID="btnFilterCompleted" runat="server" CssClass="st-revision-tab" OnClick="btnFilter_Click" CommandArgument="completed" CausesValidation="false" />
    <asp:LinkButton ID="btnFilterAll" runat="server" CssClass="st-revision-tab" OnClick="btnFilter_Click" CommandArgument="all" CausesValidation="false" />
</div>

<%-- Task Empty State --%>
<asp:Panel ID="pnlTaskEmpty" runat="server" Visible="false">
    <div class="st-revision-task-empty"><i class="bi bi-emoji-smile"></i> <asp:Literal ID="litTaskEmpty" runat="server" /></div>
</asp:Panel>

<%-- Tasks --%>
<div class="st-revision-tasks">
    <asp:Repeater ID="rptTasks" runat="server" OnItemCommand="rptTasks_ItemCommand">
        <ItemTemplate>
            <div class='st-revision-task-card <%# (bool)Eval("IsCompleted") ? "completed" : "" %>'>
                <div class="st-revision-task-num"><%# Eval("OrderNo") %></div>
                <div class="st-revision-task-body">
                    <div class="st-revision-task-title"><%# Eval("TaskTitle") %></div>
                    <div class="st-revision-task-action"><%# Eval("SuggestedAction") %></div>
                    <div class="st-revision-task-status">
                        <%# (bool)Eval("IsCompleted")
                            ? "<span class='st-revision-badge-done'><i class='bi bi-check-circle-fill'></i> " + Eval("CompletedLabel") + "</span><span class='st-revision-task-date'>" + Eval("CompletedDate") + "</span>"
                            : "<span class='st-revision-badge-pending'><i class='bi bi-circle'></i> " + Eval("PendingLabel") + "</span>" %>
                    </div>
                </div>
                <div class="st-revision-task-btn-area">
                    <asp:LinkButton ID="btnMarkDone" runat="server" Visible='<%# !(bool)Eval("IsCompleted") %>'
                        CommandName="MarkDone" CommandArgument='<%# Eval("SpTaskId") %>'
                        CssClass="st-revision-task-btn">
                        <i class="bi bi-check2-circle"></i> <%# Eval("BtnText") %>
                    </asp:LinkButton>
                    <span class='<%# (bool)Eval("IsCompleted") ? "st-revision-task-check" : "" %>'>
                        <%# (bool)Eval("IsCompleted") ? "<i class='bi bi-patch-check-fill'></i>" : "" %>
                    </span>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</div>

<%-- Rewards Section --%>
<div class="st-revision-section-hd"><i class="bi bi-gift"></i> <asp:Literal ID="litRewardsTitle" runat="server" /></div>
<div class="st-revision-rewards">
    <asp:Repeater ID="rptRewards" runat="server">
        <ItemTemplate>
            <div class='st-revision-reward-card <%# (bool)Eval("IsUnlocked") ? "unlocked" : "locked" %>'>
                <div class="st-revision-reward-icon">
                    <%# !string.IsNullOrEmpty((string)Eval("ImageUrl"))
                        ? "<img src='" + Eval("ImageUrl") + "' alt='" + Eval("RewardName") + "' onerror=\"this.style.display='none';this.nextElementSibling.style.display='flex';\" /><span style='display:none;' class='st-revision-reward-fallback'><i class='bi bi-gift-fill'></i></span>"
                        : "<i class='bi bi-gift-fill'></i>" %>
                </div>
                <div class="st-revision-reward-body">
                    <div class="st-revision-reward-name"><%# Eval("RewardName") %></div>
                    <div class="st-revision-reward-progress"><%# Eval("ProgressLabel") %></div>
                    <%# (bool)Eval("IsUnlocked") && !string.IsNullOrEmpty((string)Eval("UnlockedDate"))
                        ? "<div class='st-revision-reward-date'><i class='bi bi-check-circle-fill'></i> " + Eval("UnlockedDate") + "</div>" : "" %>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</div>

<%-- Navigation --%>
<div class="st-revision-nav">
    <a href="<%: ResolveUrl("~/Student/ProgressRewards.aspx") %>" class="st-revision-nav-btn">
        <i class="bi bi-bar-chart-line"></i> <asp:Literal ID="litNavProgress" runat="server" />
    </a>
    <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="st-revision-nav-btn st-revision-nav-btn-primary">
        <i class="bi bi-play-circle-fill"></i> <asp:Literal ID="litNavLearning" runat="server" />
    </a>
</div>

</asp:Panel>
</asp:Content>
