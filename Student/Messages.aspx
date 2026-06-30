<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Messages.aspx.cs"
    Inherits="ScienceBuddy.Student.Messages" MasterPageFile="~/Site.Master"
    Title="Messages" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* -- Student Messages -- */
:root{--msg-blue:#2563EB;--msg-blue-light:#EFF6FF;--msg-blue-dark:#1D4ED8;--msg-blue-mid:#3B82F6;}

.msg-page-header{margin-bottom:var(--space-xl);}
.msg-page-title{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;
    color:var(--color-text);margin-bottom:4px;display:flex;align-items:center;gap:var(--space-sm);}
.msg-page-sub{font-size:.9rem;color:var(--color-text-secondary);line-height:1.5;}

/* Tabs */
.msg-tabs{display:flex;gap:var(--space-sm);margin-bottom:var(--space-xl);
    border-bottom:2px solid var(--border-color);padding-bottom:0;}
.msg-tab{padding:var(--space-sm) var(--space-lg);font-weight:700;font-size:.9375rem;
    color:var(--color-text-secondary);border:none;background:none;cursor:pointer;
    border-bottom:3px solid transparent;margin-bottom:-2px;transition:all .2s;
    text-decoration:none;}
.msg-tab:hover{color:var(--msg-blue);text-decoration:none;}
.msg-tab.active{color:var(--msg-blue);border-bottom-color:var(--msg-blue);
    background:var(--msg-blue-light);border-radius:var(--border-radius) var(--border-radius) 0 0;}

/* Chat list */
.msg-chat-list{display:flex;flex-direction:column;gap:var(--space-md);}
.msg-chat-card{background:var(--color-white);border-radius:var(--border-radius-lg);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);
    padding:var(--space-lg);display:flex;align-items:center;gap:var(--space-md);
    transition:transform .2s,box-shadow .2s;}
.msg-chat-card:hover{transform:translateY(-2px);box-shadow:var(--shadow-md);}
.msg-chat-avatar{width:52px;height:52px;border-radius:50%;
    background:var(--msg-blue-light);color:var(--msg-blue);
    display:flex;align-items:center;justify-content:center;
    font-size:1.25rem;font-weight:800;flex-shrink:0;}
.msg-chat-body{flex:1;min-width:0;}
.msg-chat-name{font-family:var(--font-primary);font-weight:700;font-size:1rem;
    color:var(--color-text);margin-bottom:2px;}
.msg-chat-qual{font-size:.8rem;color:var(--color-text-muted);margin-bottom:4px;}
.msg-chat-preview{font-size:.875rem;color:var(--color-text-secondary);
    white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:400px;}
.msg-chat-meta{display:flex;flex-direction:column;align-items:flex-end;gap:4px;flex-shrink:0;}
.msg-chat-date{font-size:.75rem;color:var(--color-text-muted);}
.msg-chat-badge{background:var(--msg-blue);color:#fff;font-size:.6875rem;font-weight:800;
    padding:2px 8px;border-radius:var(--border-radius-full);min-width:20px;text-align:center;}
.msg-chat-btn{display:inline-flex;align-items:center;gap:4px;padding:6px 14px;
    background:var(--msg-blue);color:#fff;border-radius:var(--border-radius-full);
    font-size:.8125rem;font-weight:700;text-decoration:none;transition:background .2s;}
.msg-chat-btn:hover{background:var(--msg-blue-dark);color:#fff;text-decoration:none;}

/* Teacher list */
.msg-teacher-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(320px,1fr));gap:var(--space-md);}
.msg-teacher-card{background:var(--color-white);border-radius:var(--border-radius-lg);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);
    padding:var(--space-lg);transition:transform .2s,box-shadow .2s;}
.msg-teacher-card:hover{transform:translateY(-2px);box-shadow:var(--shadow-md);}
.msg-teacher-top{display:flex;align-items:center;gap:var(--space-md);margin-bottom:var(--space-md);}
.msg-teacher-avatar{width:48px;height:48px;border-radius:50%;
    background:var(--msg-blue-light);color:var(--msg-blue);
    display:flex;align-items:center;justify-content:center;
    font-size:1.125rem;font-weight:800;flex-shrink:0;}
.msg-teacher-name{font-family:var(--font-primary);font-weight:700;font-size:1rem;color:var(--color-text);}
.msg-teacher-qual{font-size:.8125rem;color:var(--color-text-secondary);}
.msg-teacher-bio{font-size:.875rem;color:var(--color-text-secondary);
    line-height:1.5;margin-bottom:var(--space-md);
    display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;}
.msg-teacher-footer{display:flex;align-items:center;justify-content:space-between;}
.msg-teacher-status{font-size:.75rem;font-weight:700;padding:3px 10px;
    border-radius:var(--border-radius-full);background:#DCFCE7;color:#15803D;}
.msg-teacher-btn{display:inline-flex;align-items:center;gap:4px;padding:8px 16px;
    background:var(--msg-blue);color:#fff;border-radius:var(--border-radius-full);
    font-size:.8125rem;font-weight:700;border:none;cursor:pointer;transition:background .2s;}
.msg-teacher-btn:hover{background:var(--msg-blue-dark);}

/* Empty state */
.msg-empty{text-align:center;padding:var(--space-2xl) var(--space-xl);}
.msg-empty-icon{font-size:3rem;margin-bottom:var(--space-md);}
.msg-empty-title{font-family:var(--font-primary);font-weight:700;font-size:1.125rem;
    color:var(--color-text);margin-bottom:var(--space-sm);}
.msg-empty-desc{font-size:.9rem;color:var(--color-text-secondary);max-width:400px;margin:0 auto;}

@media(max-width:767px){
    .msg-teacher-grid{grid-template-columns:1fr;}
    .msg-chat-preview{max-width:180px;}
}
</style>
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
<div class="msg-page-header">
    <div class="msg-page-title"><i class="bi bi-envelope-fill"></i> <asp:Literal ID="litPageTitle" runat="server" Text="Messages" /></div>
    <div class="msg-page-sub"><asp:Literal ID="litPageSub" runat="server" Text="Chat privately with teachers for learning support." /></div>
</div>

<!-- Tabs -->
<asp:HiddenField ID="hfTab" runat="server" Value="chats" />
<div class="msg-tabs">
    <asp:LinkButton ID="btnTabChats" runat="server" CssClass="msg-tab active" OnClick="btnTabChats_Click">
        <i class="bi bi-chat-left-text"></i> <asp:Literal ID="litTabChats" runat="server" Text="My Chats" />
    </asp:LinkButton>
    <asp:LinkButton ID="btnTabTeachers" runat="server" CssClass="msg-tab" OnClick="btnTabTeachers_Click">
        <i class="bi bi-people"></i> <asp:Literal ID="litTabTeachers" runat="server" Text="Teachers" />
    </asp:LinkButton>
</div>

<!-- My Chats Panel -->
<asp:Panel ID="pnlChats" runat="server">
    <asp:Panel ID="pnlChatsContent" runat="server">
        <div class="msg-chat-list">
            <asp:Repeater ID="rptChats" runat="server">
                <ItemTemplate>
                    <div class="msg-chat-card">
                        <div class="msg-chat-avatar"><%# Eval("Initials") %></div>
                        <div class="msg-chat-body">
                            <div class="msg-chat-name"><%# Eval("TeacherName") %></div>
                            <div class="msg-chat-qual"><%# Eval("Qualification") %></div>
                            <div class="msg-chat-preview"><%# Eval("LastMessage") %></div>
                        </div>
                        <div class="msg-chat-meta">
                            <div class="msg-chat-date"><%# Eval("LastDate") %></div>
                            <asp:Panel ID="pnlUnread" runat="server" Visible='<%# Convert.ToInt32(Eval("UnreadCount")) > 0 %>'>
                                <span class="msg-chat-badge"><%# Eval("UnreadCount") %> <asp:Literal ID="litUnread" runat="server" Text='<%# GetUnreadLabel() %>' /></span>
                            </asp:Panel>
                            <a href='<%# Eval("ChatUrl") %>' class="msg-chat-btn">
                                <i class="bi bi-chat-dots"></i> <%# GetOpenChatLabel() %>
                            </a>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlChatsEmpty" runat="server" Visible="false">
        <div class="msg-empty">
            <div class="msg-empty-icon">💬</div>
            <div class="msg-empty-title"><asp:Literal ID="litChatsEmptyTitle" runat="server" Text="You have not started any teacher chats yet." /></div>
            <div class="msg-empty-desc"><asp:Literal ID="litChatsEmptyDesc" runat="server" Text="Chat privately with teachers for learning support." /></div>
        </div>
    </asp:Panel>
</asp:Panel>

<!-- Teachers Panel -->
<asp:Panel ID="pnlTeachers" runat="server" Visible="false">
    <asp:Panel ID="pnlTeachersContent" runat="server">
        <div class="msg-teacher-grid">
            <asp:Repeater ID="rptTeachers" runat="server" OnItemCommand="rptTeachers_ItemCommand">
                <ItemTemplate>
                    <div class="msg-teacher-card">
                        <div class="msg-teacher-top">
                            <div class="msg-teacher-avatar"><%# Eval("Initials") %></div>
                            <div>
                                <div class="msg-teacher-name"><%# Eval("TeacherName") %></div>
                                <div class="msg-teacher-qual"><%# Eval("Qualification") %></div>
                            </div>
                        </div>
                        <div class="msg-teacher-bio"><%# Eval("Bio") %></div>
                        <div class="msg-teacher-footer">
                            <span class="msg-teacher-status"><asp:Literal ID="litStatus" runat="server" Text='<%# GetCertifiedLabel() %>' /></span>
                            <asp:LinkButton ID="btnStartChat" runat="server"
                                CssClass="msg-teacher-btn"
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
        <div class="msg-empty">
            <div class="msg-empty-icon">👩‍🏫</div>
            <div class="msg-empty-title"><asp:Literal ID="litTeachersEmptyTitle" runat="server" Text="No teachers available." /></div>
            <div class="msg-empty-desc"><asp:Literal ID="litTeachersEmptyDesc" runat="server" Text="Teachers will appear here once they are certified." /></div>
        </div>
    </asp:Panel>
</asp:Panel>

</asp:Content>
