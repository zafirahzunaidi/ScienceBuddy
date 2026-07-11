<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="VirtualLabs.aspx.cs" Inherits="ScienceBuddy.Student.VirtualLabs1" %>
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
        <a href="<%: ResolveUrl("~/Student/VirtualLabs.aspx") %>" class="sb-sidebar-item active">
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

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><asp:Literal ID="litPageTitle" runat="server" Text="Virtual Labs" /></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="st-virtuallabs-header">
    <div class="st-virtuallabs-title"><asp:Literal ID="litTitle" runat="server" /></div>
    <div class="st-virtuallabs-subtitle"><asp:Literal ID="litSubtitle" runat="server" /></div>
</div>
<%-- Hidden stats for code-behind compatibility --%>
<asp:Literal ID="litAvailable" runat="server" Visible="false" /><asp:Literal ID="litAvailableLbl" runat="server" Visible="false" /><asp:Literal ID="litCompleted" runat="server" Visible="false" /><asp:Literal ID="litCompletedLbl" runat="server" Visible="false" /><asp:Literal ID="litInProgress" runat="server" Visible="false" /><asp:Literal ID="litInProgressLbl" runat="server" Visible="false" />
<div class="st-virtuallabs-filters">
    <asp:DropDownList ID="ddlLevel" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed" />
    <asp:DropDownList ID="ddlDifficulty" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed" />
    <asp:DropDownList ID="ddlStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed" />
</div>
<asp:Panel ID="pnlGrid" runat="server">
    <div class="st-virtuallabs-grid">
        <asp:Repeater ID="rptLabs" runat="server">
            <ItemTemplate>
                <div class="st-virtuallabs-card">
                    <div class="st-virtuallabs-card-top <%# Eval("DiffClass") %>"></div>
                    <div class="st-virtuallabs-card-body">
                        <div class="st-virtuallabs-card-icon"><%# Eval("Icon") %></div>
                        <div class="st-virtuallabs-card-title"><%# Eval("Title") %></div>
                        <div class="st-virtuallabs-card-desc"><%# Eval("Desc") %></div>
                        <div class="st-virtuallabs-card-meta">
                            <span><i class="bi bi-bar-chart-fill"></i> <%# Eval("Level") %></span>
                            <span><i class="bi bi-collection"></i> <%# Eval("Unit") %></span>
                            <span><i class="bi bi-speedometer2"></i> <%# Eval("Difficulty") %></span>
                        </div>
                    </div>
                    <div class="st-virtuallabs-card-footer">
                        <span class="st-virtuallabs-badge <%# Eval("BadgeClass") %>"><%# Eval("StatusText") %></span>
                        <a href="<%# Eval("Url") %>" class="sb-btn sb-btn-xs <%# Eval("BtnClass") %>">
                            <i class="bi bi-play-fill"></i> <%# Eval("BtnText") %>
                        </a>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>
<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="sb-empty-state" style="padding:var(--space-3xl) 0;">
        <div class="empty-icon" style="font-size:3.5rem;"><i class="bi bi-eyedropper"></i></div>
        <div class="empty-title"><asp:Literal ID="litEmptyTitle" runat="server" /></div>
        <div class="empty-desc"><asp:Literal ID="litEmptyDesc" runat="server" /></div>
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="sb-btn sb-btn-primary sb-btn-sm mt-lg">
            <i class="bi bi-book"></i> <asp:Literal ID="litEmptyBtn" runat="server" />
        </a>
    </div>
</asp:Panel>
</asp:Content>
