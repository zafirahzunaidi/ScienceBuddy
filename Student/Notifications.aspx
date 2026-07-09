<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Notifications.aspx.cs" Inherits="ScienceBuddy.Student.Notifications1" %>
<asp:Content ID="HeadStyle" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%: ResolveUrl("~/Content/Student.css") %>" rel="stylesheet" />
</asp:Content>

<asp:Content ID="TopNavigationLinks" ContentPlaceHolderID="TopNavLinks" runat="server">
</asp:Content>

<asp:Content ID="TopNavigationActions" ContentPlaceHolderID="TopNavActions" runat="server">
</asp:Content>

<asp:Content ID="TopNavigationMainContent" ContentPlaceHolderID="MainContent" runat="server">
</asp:Content>

<%-- Student Sidebar --%>
<asp:Content ID="StudentSidebarMenu" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Main</div>
        <a href="<%: ResolveUrl("~/Student/Dashboard.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-speedometer2 item-icon"></i><span class="item-label">Dashboard</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/Notifications.aspx") %>" class="sb-sidebar-item active">
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
    <asp:Literal ID="litPageTitle" runat="server" Text="Notifications" />
</asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- Page Header --%>
<div class="st-notifications-header">
    <div class="st-notifications-title"><asp:Literal ID="litTitle" runat="server" /></div>
    <div class="st-notifications-subtitle"><asp:Literal ID="litSubtitle" runat="server" /></div>
</div>

<%-- Search Bar + Filter Chips --%>
<div class="st-notifications-bar">
    <div class="st-notifications-search">
        <i class="bi bi-search"></i>
        <asp:TextBox ID="txtSearch" runat="server" placeholder="Search..." />
    </div>
    <div class="st-notifications-chips">
        <asp:LinkButton ID="btnFilterAll" runat="server" CssClass="st-notifications-chip active" OnClick="btnFilter_Click" CommandArgument="all" CausesValidation="false"><asp:Literal ID="litFilterAll" runat="server" Text="All" /></asp:LinkButton>
        <asp:LinkButton ID="btnFilterUnread" runat="server" CssClass="st-notifications-chip" OnClick="btnFilter_Click" CommandArgument="unread" CausesValidation="false"><asp:Literal ID="litFilterUnread" runat="server" Text="Unread" /></asp:LinkButton>
        <asp:LinkButton ID="btnFilterRead" runat="server" CssClass="st-notifications-chip" OnClick="btnFilter_Click" CommandArgument="read" CausesValidation="false"><asp:Literal ID="litFilterRead" runat="server" Text="Read" /></asp:LinkButton>
    </div>
    <asp:LinkButton ID="btnMarkAllRead" runat="server" CssClass="sb-btn sb-btn-primary sb-btn-sm"
        OnClick="btnMarkAllRead_Click" CausesValidation="false">
        <i class="bi bi-check2-all"></i> <asp:Literal ID="litMarkAll" runat="server" Text="Mark All Read" />
    </asp:LinkButton>
</div>

<%-- Notification List --%>
<asp:Panel ID="pnlList" runat="server">
    <div class="st-notifications-list">
        <asp:Repeater ID="rptNotifications" runat="server" OnItemCommand="rptNotifications_ItemCommand">
            <ItemTemplate>
                <div class="st-notifications-item <%# !(bool)Eval("IsRead") ? "unread" : "" %>">
                    <div class="st-notifications-item-icon" style="background:<%# Eval("IconBg") %>;color:<%# Eval("IconColor") %>;">
                        <i class="bi <%# Eval("Icon") %>"></i>
                    </div>
                    <div class="st-notifications-item-body">
                        <div class="st-notifications-item-title">
                            <%# Eval("Title") %>
                            <%# !(bool)Eval("IsRead") ? "<span class='st-notifications-unread-dot'></span>" : "" %>
                        </div>
                        <div class="st-notifications-item-msg"><%# Eval("Message") %></div>
                        <div class="st-notifications-item-time"><i class="bi bi-clock"></i> <%# Eval("TimeAgo") %></div>
                    </div>
                    <div class="st-notifications-item-actions">
                        <asp:LinkButton runat="server" CommandName="MarkRead" CommandArgument='<%# Eval("Id") %>'
                            CssClass="sb-btn sb-btn-light sb-btn-xs"
                            Visible='<%# !(bool)Eval("IsRead") %>' CausesValidation="false">
                            <i class="bi bi-check2"></i>
                        </asp:LinkButton>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>

<%-- Empty State --%>
<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="sb-empty-state" style="padding:var(--space-3xl) 0;">
        <div class="empty-icon" style="font-size:3.5rem;">??</div>
        <div class="empty-title"><asp:Literal ID="litEmptyTitle" runat="server" /></div>
        <div class="empty-desc"><asp:Literal ID="litEmptyDesc" runat="server" /></div>
        <a href="<%: ResolveUrl("~/Student/Dashboard.aspx") %>" class="sb-btn sb-btn-primary sb-btn-sm mt-lg">
            <i class="bi bi-house"></i> <asp:Literal ID="litEmptyBtn" runat="server" Text="Dashboard" />
        </a>
    </div>
</asp:Panel>

</asp:Content>
