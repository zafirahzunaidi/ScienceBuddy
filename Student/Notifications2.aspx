<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Notifications2.aspx.cs"
    Inherits="ScienceBuddy.Student.Notifications" MasterPageFile="~/Site.Master"
    Title="Notifications" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--student:#FF6B2C;--student-light:#FFF0E8;}
.sn-header{margin-bottom:var(--space-lg);}
.sn-title{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;color:var(--color-text);}
.sn-subtitle{font-size:.9375rem;color:var(--color-text-secondary);margin-top:4px;}
/* Search + Filters */
.sn-bar{display:flex;align-items:center;gap:var(--space-md);margin-bottom:var(--space-lg);flex-wrap:wrap;}
.sn-search{flex:1;min-width:180px;position:relative;}
.sn-search input{width:100%;padding:10px 14px 10px 36px;border:1.5px solid var(--border-color);
    border-radius:var(--border-radius-full);font-size:.875rem;background:#FAFBFC;transition:border-color .2s;}
.sn-search input:focus{border-color:#2563EB;outline:none;box-shadow:0 0 0 3px rgba(37,99,235,.08);}
.sn-search i{position:absolute;left:12px;top:50%;transform:translateY(-50%);color:var(--color-text-muted);font-size:.9rem;}
.sn-chips{display:flex;gap:6px;flex-wrap:wrap;}
.sn-chip{padding:6px 16px;border-radius:var(--border-radius-full);font-size:.8rem;font-weight:700;
    border:1.5px solid var(--border-color);background:var(--color-white);color:var(--color-text-secondary);
    cursor:pointer;transition:all .2s;text-decoration:none;}
.sn-chip:hover{border-color:var(--student);color:var(--student);text-decoration:none;}
.sn-chip.active{background:var(--student);color:#fff;border-color:var(--student);}
.sn-toolbar{display:flex;align-items:center;justify-content:space-between;
    margin-bottom:var(--space-lg);flex-wrap:wrap;gap:var(--space-sm);}
.sn-list{display:flex;flex-direction:column;gap:var(--space-md);}
.sn-item{background:var(--color-white);border-radius:var(--border-radius-lg);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-xs);
    padding:var(--space-lg);display:flex;gap:var(--space-md);align-items:flex-start;
    transition:transform .15s,box-shadow .15s;}
.sn-item:hover{transform:translateY(-2px);box-shadow:var(--shadow-sm);}
.sn-item.unread{border-left:4px solid var(--student);background:#FFFBF8;}
.sn-item-icon{width:42px;height:42px;border-radius:var(--border-radius);
    display:flex;align-items:center;justify-content:center;font-size:1.25rem;flex-shrink:0;}
.sn-item-body{flex:1;min-width:0;}
.sn-item-title{font-family:var(--font-primary);font-size:.9375rem;font-weight:700;
    color:var(--color-text);margin-bottom:4px;display:flex;align-items:center;gap:var(--space-sm);}
.sn-item-msg{font-size:.875rem;color:var(--color-text-secondary);line-height:1.5;margin-bottom:6px;}
.sn-item-time{font-size:.75rem;color:var(--color-text-muted);display:flex;align-items:center;gap:4px;}
.sn-item-actions{flex-shrink:0;display:flex;align-items:center;}
.sn-unread-dot{width:8px;height:8px;border-radius:50%;background:var(--student);flex-shrink:0;}
@media(max-width:767px){.sn-bar{flex-direction:column;align-items:stretch;}}
@media(max-width:479px){.sn-item{flex-direction:column;}}
</style>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
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
<div class="sn-header">
    <div class="sn-title"><asp:Literal ID="litTitle" runat="server" /></div>
    <div class="sn-subtitle"><asp:Literal ID="litSubtitle" runat="server" /></div>
</div>

<%-- Search Bar + Filter Chips --%>
<div class="sn-bar">
    <div class="sn-search">
        <i class="bi bi-search"></i>
        <asp:TextBox ID="txtSearch" runat="server" placeholder="Search..." />
    </div>
    <div class="sn-chips">
        <asp:LinkButton ID="btnFilterAll" runat="server" CssClass="sn-chip active" OnClick="btnFilter_Click" CommandArgument="all" CausesValidation="false"><asp:Literal ID="litFilterAll" runat="server" Text="All" /></asp:LinkButton>
        <asp:LinkButton ID="btnFilterUnread" runat="server" CssClass="sn-chip" OnClick="btnFilter_Click" CommandArgument="unread" CausesValidation="false"><asp:Literal ID="litFilterUnread" runat="server" Text="Unread" /></asp:LinkButton>
        <asp:LinkButton ID="btnFilterRead" runat="server" CssClass="sn-chip" OnClick="btnFilter_Click" CommandArgument="read" CausesValidation="false"><asp:Literal ID="litFilterRead" runat="server" Text="Read" /></asp:LinkButton>
    </div>
    <asp:LinkButton ID="btnMarkAllRead" runat="server" CssClass="sb-btn sb-btn-primary sb-btn-sm"
        OnClick="btnMarkAllRead_Click" CausesValidation="false">
        <i class="bi bi-check2-all"></i> <asp:Literal ID="litMarkAll" runat="server" Text="Mark All Read" />
    </asp:LinkButton>
</div>

<%-- Notification List --%>
<asp:Panel ID="pnlList" runat="server">
    <div class="sn-list">
        <asp:Repeater ID="rptNotifications" runat="server" OnItemCommand="rptNotifications_ItemCommand">
            <ItemTemplate>
                <div class="sn-item <%# !(bool)Eval("IsRead") ? "unread" : "" %>">
                    <div class="sn-item-icon" style="background:<%# Eval("IconBg") %>;color:<%# Eval("IconColor") %>;">
                        <i class="bi <%# Eval("Icon") %>"></i>
                    </div>
                    <div class="sn-item-body">
                        <div class="sn-item-title">
                            <%# Eval("Title") %>
                            <%# !(bool)Eval("IsRead") ? "<span class='sn-unread-dot'></span>" : "" %>
                        </div>
                        <div class="sn-item-msg"><%# Eval("Message") %></div>
                        <div class="sn-item-time"><i class="bi bi-clock"></i> <%# Eval("TimeAgo") %></div>
                    </div>
                    <div class="sn-item-actions">
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
        <div class="empty-icon" style="font-size:3.5rem;">🔔</div>
        <div class="empty-title"><asp:Literal ID="litEmptyTitle" runat="server" /></div>
        <div class="empty-desc"><asp:Literal ID="litEmptyDesc" runat="server" /></div>
        <a href="<%: ResolveUrl("~/Student/Dashboard.aspx") %>" class="sb-btn sb-btn-primary sb-btn-sm mt-lg">
            <i class="bi bi-house"></i> <asp:Literal ID="litEmptyBtn" runat="server" Text="Dashboard" />
        </a>
    </div>
</asp:Panel>

</asp:Content>
