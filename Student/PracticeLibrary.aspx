<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PracticeLibrary.aspx.cs" Inherits="ScienceBuddy.Student.PracticeLibrary1" %>
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
        <a href="<%: ResolveUrl("~/Student/PracticeLibrary.aspx") %>" class="sb-sidebar-item active">
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
    <asp:Literal ID="litPageTitle" runat="server" Text="Practice Library" />
</asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- -- PAGE HEADER -- --%>
<div class="st-practice-header">
    <div class="st-practice-title"><asp:Literal ID="litTitle" runat="server" Text="Practice Library" /></div>
    <div class="st-practice-subtitle"><asp:Literal ID="litSubtitle" runat="server" Text="Try extra quizzes to improve your Science skills." /></div>
</div>

<%-- -- AI RECOMMENDATION BANNER -- --%>
<asp:Panel ID="pnlRecommend" runat="server" CssClass="st-practice-recommend" Visible="false">
    <div class="st-practice-recommend-title"><i class="bi bi-stars"></i> <asp:Literal ID="litRecommendTitle" runat="server" /></div>
    <div class="st-practice-recommend-text"><asp:Literal ID="litRecommendText" runat="server" /></div>
</asp:Panel>

<%-- -- FILTERS -- --%>
<div class="st-practice-filters">
    <asp:DropDownList ID="ddlLevel" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed" />
    <asp:DropDownList ID="ddlUnit" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed" />
    <asp:DropDownList ID="ddlSubtopic" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed" />
    <asp:DropDownList ID="ddlLanguage" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed" />
</div>

<%-- -- QUIZ CARD GRID -- --%>
<asp:Panel ID="pnlGrid" runat="server">
    <div class="st-practice-grid">
        <asp:Repeater ID="rptQuizzes" runat="server">
            <ItemTemplate>
                <div class="st-practice-card">
                    <div class="st-practice-card-body">
                        <div class="st-practice-card-title"><%# Eval("Title") %></div>
                        <div class="st-practice-card-meta">
                            <span><i class="bi bi-bar-chart-steps"></i> <%# Eval("Level") %></span>
                            <span><i class="bi bi-layers"></i> <%# Eval("Unit") %></span>
                        </div>
                        <div class="st-practice-card-badges">
                            <span class="st-practice-badge st-practice-badge-level"><i class="bi bi-bar-chart-steps"></i> <%# Eval("Level") %></span>
                            <span class="st-practice-badge st-practice-badge-lang"><i class="bi bi-translate"></i> <%# Eval("Language") %></span>
                            <span class="st-practice-badge st-practice-badge-count"><i class="bi bi-question-circle"></i> <%# Eval("QuestionCount") %> <%# Eval("QuestionsLabel") %></span>
                            <span class='st-practice-badge <%# Eval("BadgeClass") %>'><%# Eval("StatusText") %></span>
                        </div>
                        <div class="st-practice-card-score"><%# Eval("ScoreDisplay") %></div>
                    </div>
                    <div class="st-practice-card-footer">
                        <a href='<%# Eval("Url") %>' class="st-practice-card-btn">
                            <i class="bi bi-play-fill"></i> <%# Eval("BtnText") %>
                        </a>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>

<%-- -- EMPTY STATE -- --%>
<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="st-practice-empty">
        <div class="st-practice-empty-icon"><i class="bi bi-patch-question"></i></div>
        <div class="st-practice-empty-title"><asp:Literal ID="litEmptyTitle" runat="server" Text="No practice quizzes available" /></div>
        <div class="st-practice-empty-desc"><asp:Literal ID="litEmptyDesc" runat="server" Text="No practice quizzes are available yet." /></div>
        <a href="<%: ResolveUrl("~/Student/Dashboard.aspx") %>" class="st-practice-card-btn" style="display:inline-flex;width:auto;">
            <i class="bi bi-house"></i> <asp:Literal ID="litEmptyBtn" runat="server" Text="Back to Dashboard" />
        </a>
    </div>
</asp:Panel>

</asp:Content>
