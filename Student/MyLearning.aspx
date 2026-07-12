<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MyLearning.aspx.cs" Inherits="ScienceBuddy.Student.MyLearning1" %>
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
    <asp:Literal ID="litPageTitle" runat="server" Text="My Learning" />
</asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<div class="st-mylearning-header">
    <div class="st-mylearning-title"><asp:Literal ID="litTitle" runat="server" /></div>
    <div class="st-mylearning-subtitle"><asp:Literal ID="litSubtitle" runat="server" /></div>
</div>

<%-- Level Cards --%>
<div class="st-mylearning-levels">
    <asp:Repeater ID="rptLevels" runat="server">
        <ItemTemplate>
            <div class="st-mylearning-level-card <%# Eval("CssClass") %>">
                <div class="st-mylearning-level-icon" style="background:<%# Eval("IconBg") %>;color:<%# Eval("IconColor") %>;">
                    <%# Eval("Icon") %>
                </div>
                <div class="st-mylearning-level-name"><%# Eval("Name") %></div>
                <div class="st-mylearning-level-desc"><%# Eval("Description") %></div>
                <span class="st-mylearning-level-badge <%# Eval("BadgeClass") %>"><%# Eval("BadgeText") %></span>
                <asp:HyperLink runat="server"
                    NavigateUrl='<%# Eval("LinkUrl") %>'
                    CssClass='<%# Eval("BtnClass") %>'
                    Enabled='<%# !(bool)Eval("IsLocked") %>'>
                    <i class="bi <%# (bool)Eval("IsLocked") ? "bi-lock-fill" : "bi-arrow-right" %>"></i>
                    <%# Eval("BtnText") %>
                </asp:HyperLink>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</div>

<%-- Current Level Section --%>
<asp:Panel ID="pnlUnits" runat="server">
    <div class="st-mylearning-section-hd">
        <div class="st-mylearning-section-title">
            <i class="bi bi-collection-fill" style="color:var(--student)"></i>
            <asp:Literal ID="litUnitsTitle" runat="server" />
        </div>
    </div>
    <div class="st-mylearning-units">
        <asp:Repeater ID="rptUnits" runat="server">
            <ItemTemplate>
                <div class="st-mylearning-unit-card">
                    <div class="st-mylearning-unit-name"><%# Eval("Name") %></div>
                    <div class="st-mylearning-unit-desc"><%# Eval("Description") %></div>
                    <div class="st-mylearning-unit-meta">
                        <span><i class="bi bi-layers"></i> <%# Eval("SubtopicCount") %> <%# Eval("SubtopicLabel") %></span>
                        <span><i class="bi bi-journal-text"></i> <%# Eval("LessonCount") %> <%# Eval("LessonLabel") %></span>
                    </div>
                    <div class="st-mylearning-unit-progress">
                        <div class="st-mylearning-unit-progress-bar">
                            <div class="st-mylearning-unit-progress-fill" style="width:<%# Eval("ProgressPct") %>%"></div>
                        </div>
                        <div class="st-mylearning-unit-progress-lbl">
                            <span><%# Eval("ProgressText") %></span>
                            <span><%# Eval("ProgressPct") %>%</span>
                        </div>
                    </div>
                    <a href="<%# Eval("LinkUrl") %>" class="sb-btn sb-btn-orange sb-btn-sm" style="margin-top:var(--space-sm);">
                        <i class="bi bi-arrow-right"></i> <%# Eval("BtnText") %>
                    </a>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>

<%-- Level Quiz --%>
<asp:Panel ID="pnlQuiz" runat="server" Visible="false">
    <div class="st-mylearning-quiz-card">
        <div class="st-mylearning-quiz-icon"><i class="bi bi-patch-check-fill"></i></div>
        <div class="st-mylearning-quiz-body">
            <div class="st-mylearning-quiz-title"><asp:Literal ID="litQuizTitle" runat="server" /></div>
            <div class="st-mylearning-quiz-sub"><asp:Literal ID="litQuizSub" runat="server" /></div>
        </div>
        <a href="#" class="sb-btn sb-btn-white sb-btn-sm">
            <i class="bi bi-play-fill"></i> <asp:Literal ID="litQuizBtn" runat="server" Text="Start" />
        </a>
    </div>
</asp:Panel>

<asp:Panel ID="pnlQuizEmpty" runat="server" Visible="false">
    <div class="sb-alert sb-alert-info" style="margin-bottom:var(--space-xl);">
        <i class="bi bi-info-circle-fill alert-icon"></i>
        <div class="alert-content"><asp:Literal ID="litQuizEmpty" runat="server" /></div>
    </div>
</asp:Panel>

<%-- Empty state if no levels --%>
<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="sb-empty-state" style="padding:var(--space-3xl) 0;">
        <div class="empty-icon" style="font-size:3.5rem;"><i class="bi bi-book"></i></div>
        <div class="empty-title"><asp:Literal ID="litEmptyTitle" runat="server" /></div>
        <div class="empty-desc"><asp:Literal ID="litEmptyDesc" runat="server" /></div>
    </div>
</asp:Panel>

</asp:Content>
