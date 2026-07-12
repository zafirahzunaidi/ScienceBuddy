<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Messages.aspx.cs"
    Inherits="ScienceBuddy.Student.Messages1" MasterPageFile="~/Site.Master"
    Title="Messages" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Student.css") %>" rel="stylesheet" />
</asp:Content>

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
        <a href="<%: ResolveUrl("~/Student/Messages.aspx") %>" class="sb-sidebar-item active">
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

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">Messages</asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<!-- Page Header -->
<div class="st-messages-page-header">
    <div class="st-messages-page-title"><i class="bi bi-envelope-fill"></i> <asp:Literal ID="litPageTitle" runat="server" Text="Messages" /></div>
    <div class="st-messages-page-sub"><asp:Literal ID="litPageSub" runat="server" Text="Chat privately with teachers for learning support." /></div>
</div>

<!-- Tabs -->
<asp:HiddenField ID="hfTab" runat="server" Value="chats" />
<div class="st-messages-tabs">
    <asp:LinkButton ID="btnTabChats" runat="server" CssClass="st-messages-tab active" OnClick="btnTabChats_Click">
        <i class="bi bi-chat-left-text"></i> <asp:Literal ID="litTabChats" runat="server" Text="My Chats" />
    </asp:LinkButton>
    <asp:LinkButton ID="btnTabTeachers" runat="server" CssClass="st-messages-tab" OnClick="btnTabTeachers_Click">
        <i class="bi bi-people"></i> <asp:Literal ID="litTabTeachers" runat="server" Text="Teachers" />
    </asp:LinkButton>
</div>

<!-- My Chats Panel -->
<asp:Panel ID="pnlChats" runat="server">
    <asp:Panel ID="pnlChatsContent" runat="server">
        <div class="st-messages-chat-list">
            <asp:Repeater ID="rptChats" runat="server">
                <ItemTemplate>
                    <div class="st-messages-chat-card">
                        <div class="st-messages-chat-avatar"><%# Eval("Initials") %></div>
                        <div class="st-messages-chat-body">
                            <div class="st-messages-chat-name"><%# Eval("TeacherName") %></div>
                            <div class="st-messages-chat-qual"><%# Eval("Qualification") %></div>
                            <div class="st-messages-chat-preview"><%# Eval("LastMessage") %></div>
                        </div>
                        <div class="st-messages-chat-meta">
                            <div class="st-messages-chat-date"><%# Eval("LastDate") %></div>
                            <asp:Panel ID="pnlUnread" runat="server" Visible='<%# Convert.ToInt32(Eval("UnreadCount")) > 0 %>'>
                                <span class="st-messages-chat-badge"><%# Eval("UnreadCount") %> <asp:Literal ID="litUnread" runat="server" Text='<%# GetUnreadLabel() %>' /></span>
                            </asp:Panel>
                            <a href='<%# Eval("ChatUrl") %>' class="st-messages-chat-btn">
                                <i class="bi bi-chat-dots"></i> <%# GetOpenChatLabel() %>
                            </a>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlChatsEmpty" runat="server" Visible="false">
        <div class="st-messages-empty">
            <div class="st-messages-empty-icon"><i class="bi bi-chat-dots" style="font-size:3.5rem;color:#2563EB;"></i></div>
            <div class="st-messages-empty-title"><asp:Literal ID="litChatsEmptyTitle" runat="server" Text="You have not started any teacher chats yet." /></div>
            <div class="st-messages-empty-desc"><asp:Literal ID="litChatsEmptyDesc" runat="server" Text="Chat privately with teachers for learning support." /></div>
        </div>
    </asp:Panel>
</asp:Panel>

<!-- Teachers Panel -->
<asp:Panel ID="pnlTeachers" runat="server" Visible="false">
    <asp:Panel ID="pnlTeachersContent" runat="server">
        <div class="st-messages-teacher-grid">
            <asp:Repeater ID="rptTeachers" runat="server" OnItemCommand="rptTeachers_ItemCommand">
                <ItemTemplate>
                    <div class="st-messages-teacher-card">
                        <div class="st-messages-teacher-top">
                            <div class="st-messages-teacher-avatar"><%# Eval("Initials") %></div>
                            <div>
                                <div class="st-messages-teacher-name"><%# Eval("TeacherName") %></div>
                                <div class="st-messages-teacher-qual"><%# Eval("Qualification") %></div>
                            </div>
                        </div>
                        <div class="st-messages-teacher-bio"><%# Eval("Bio") %></div>
                        <div class="st-messages-teacher-footer">
                            <span class="st-messages-teacher-status"><asp:Literal ID="litStatus" runat="server" Text='<%# GetCertifiedLabel() %>' /></span>
                            <asp:LinkButton ID="btnStartChat" runat="server"
                                CssClass="st-messages-teacher-btn"
                                CommandName="StartChat"
                                CommandArgument='<%# Eval("TeacherUserId") %>'>
                                <i class="bi bi-chat-dots"></i> <%# GetStartChatLabel() %>
                            </asp:LinkButton>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlTeachersEmpty" runat="server" Visible="false">
        <div class="st-messages-empty">
            <div class="st-messages-empty-icon"><i class="bi bi-person-workspace" style="font-size:3.5rem;color:#2563EB;"></i></div>
            <div class="st-messages-empty-title"><asp:Literal ID="litTeachersEmptyTitle" runat="server" Text="No teachers available." /></div>
            <div class="st-messages-empty-desc"><asp:Literal ID="litTeachersEmptyDesc" runat="server" Text="Teachers will appear here once they are certified." /></div>
        </div>
    </asp:Panel>
</asp:Panel>

</asp:Content>
