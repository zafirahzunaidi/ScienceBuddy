<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="QuizHistory.aspx.cs" Inherits="ScienceBuddy.Student.QuizHistory1" %>
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
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Student/MyProfile.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span>
        </a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><asp:Literal ID="litPageTitle" runat="server" Text="Quiz History" /></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- Header --%>
<a href="<%: ResolveUrl("~/Student/PracticeLibrary.aspx") %>" class="st-quizhistory-back-btn"
    onmouseover="this.style.background='#2563EB';this.style.color='#fff';"
    onmouseout="this.style.background='#EFF6FF';this.style.color='#2563EB';">
    <i class="bi bi-arrow-left"></i> <asp:Literal ID="litBackToPractice" runat="server" Text="Back to Practice Library" />
</a>
<div class="st-quizhistory-header"><div class="st-quizhistory-header-blob"></div>
    <div class="st-quizhistory-header-title"><i class="bi bi-clock-history"></i> <asp:Literal ID="litTitle" runat="server" /></div>
    <div class="st-quizhistory-header-sub"><asp:Literal ID="litSubtitle" runat="server" /></div>
</div>

<%-- Filters --%>
<div class="st-quizhistory-filters">
    <div class="st-quizhistory-filter-group"><span class="st-quizhistory-filter-lbl"><asp:Literal ID="litFType" runat="server" Text="Type" /></span>
        <asp:DropDownList ID="ddlType" runat="server" CssClass="st-quizhistory-filter-input" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed" /></div>
    <div class="st-quizhistory-filter-group"><span class="st-quizhistory-filter-lbl"><asp:Literal ID="litFStatus" runat="server" Text="Status" /></span>
        <asp:DropDownList ID="ddlStatus" runat="server" CssClass="st-quizhistory-filter-input" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed" /></div>
    <div class="st-quizhistory-filter-group"><span class="st-quizhistory-filter-lbl"><asp:Literal ID="litFSort" runat="server" Text="Sort" /></span>
        <asp:DropDownList ID="ddlSort" runat="server" CssClass="st-quizhistory-filter-input" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed" /></div>
    <div class="st-quizhistory-filter-group"><span class="st-quizhistory-filter-lbl"><asp:Literal ID="litFSearch" runat="server" Text="Search" /></span>
        <asp:TextBox ID="txtSearch" runat="server" CssClass="st-quizhistory-filter-input" placeholder="..." /></div>
    <asp:Button ID="btnFilter" runat="server" CssClass="st-quizhistory-filter-btn" Text="Filter" OnClick="btnFilter_Click" />
</div>

<%-- List --%>
<asp:Panel ID="pnlList" runat="server">
    <div class="st-quizhistory-list">
        <asp:Repeater ID="rptHistory" runat="server">
            <ItemTemplate>
                <div class='st-quizhistory-card <%# Eval("StatusClass") %>'>
                    <div class='st-quizhistory-card-score <%# Eval("StatusClass") %>'><%# Eval("PctDisplay") %></div>
                    <div class="st-quizhistory-card-body">
                        <div class="st-quizhistory-card-title"><%# Eval("QuizTitle") %></div>
                        <div class="st-quizhistory-card-meta">
                            <span class='st-quizhistory-badge <%# Eval("TypeBadgeClass") %>'><%# Eval("TypeLabel") %></span>
                            <span class='st-quizhistory-badge <%# Eval("StatusBadgeClass") %>'><%# Eval("StatusLabel") %></span>
                            <span><i class="bi bi-hash"></i><%# Eval("AttemptNo") %></span>
                            <span><i class="bi bi-calendar3"></i> <%# Eval("DateDisplay") %></span>
                            <span><%# Eval("ScoreDisplay") %></span>
                        </div>
                    </div>
                    <div class="st-quizhistory-card-actions">
                        <a href='<%# Eval("ResultUrl") %>' class="st-quizhistory-btn-sm st-quizhistory-btn-blue"><i class="bi bi-eye"></i> <%# Eval("ViewLbl") %></a>
                        <a href='<%# Eval("ReviewUrl") %>' class="st-quizhistory-btn-sm st-quizhistory-btn-outline"><i class="bi bi-search"></i> <%# Eval("ReviewLbl") %></a>
                        <a href='<%# Eval("RetryUrl") %>' class="st-quizhistory-btn-sm st-quizhistory-btn-orange"><i class="bi bi-arrow-repeat"></i> <%# Eval("RetryLbl") %></a>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>

<%-- Empty --%>
<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="st-quizhistory-empty">
        <div class="st-quizhistory-empty-icon"><i class="bi bi-journal-x"></i></div>
        <div class="st-quizhistory-empty-title"><asp:Literal ID="litEmptyTitle" runat="server" /></div>
        <div class="st-quizhistory-empty-desc"><asp:Literal ID="litEmptyDesc" runat="server" /></div>
        <a href="<%: ResolveUrl("~/Student/PracticeLibrary.aspx") %>" class="st-quizhistory-empty-btn"><i class="bi bi-patch-question"></i> <asp:Literal ID="litEmptyBtn" runat="server" /></a>
    </div>
</asp:Panel>
</asp:Content>
