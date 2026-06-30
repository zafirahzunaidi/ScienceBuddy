<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="VirtualLabs.aspx.cs"
    Inherits="ScienceBuddy.Student.VirtualLabs" MasterPageFile="~/Site.Master" Title="Virtual Labs" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--student:#FF6B2C;--student-light:#FFF0E8;}
.vl-header{margin-bottom:var(--space-xl);}
.vl-title{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;color:var(--color-text);}
.vl-subtitle{font-size:.9375rem;color:var(--color-text-secondary);margin-top:4px;}
.vl-summary{display:grid;grid-template-columns:repeat(3,1fr);gap:var(--space-md);margin-bottom:var(--space-xl);}
.vl-sum{background:var(--color-white);border-radius:var(--border-radius-lg);border:1.5px solid var(--border-color);
    box-shadow:var(--shadow-sm);padding:var(--space-lg);display:flex;align-items:center;gap:var(--space-md);transition:transform .2s,box-shadow .2s;}
.vl-sum:hover{transform:translateY(-3px);box-shadow:var(--shadow-md);}
.vl-sum-icon{width:44px;height:44px;border-radius:var(--border-radius);display:flex;align-items:center;justify-content:center;font-size:1.25rem;flex-shrink:0;}
.vl-sum-val{font-family:var(--font-primary);font-size:1.5rem;font-weight:800;line-height:1;}
.vl-sum-lbl{font-size:.8125rem;color:var(--color-text-secondary);margin-top:3px;font-weight:600;}
.vl-filters{display:flex;flex-wrap:wrap;gap:var(--space-sm);margin-bottom:var(--space-xl);align-items:center;}
.vl-filters select{padding:8px 14px;border:1.5px solid var(--border-color);border-radius:var(--border-radius);font-size:.875rem;background:var(--color-white);min-width:140px;}
.vl-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));gap:var(--space-md);margin-bottom:var(--space-xl);}
.vl-card{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);overflow:hidden;display:flex;flex-direction:column;transition:transform .2s,box-shadow .2s;}
.vl-card:hover{transform:translateY(-4px);box-shadow:var(--shadow-lg);}
.vl-card-top{height:8px;}
.vl-card-top.easy{background:linear-gradient(90deg,#22C55E,#4ADE80);}
.vl-card-top.medium{background:linear-gradient(90deg,#F59E0B,#FBBF24);}
.vl-card-top.hard{background:linear-gradient(90deg,#EF4444,#F87171);}
.vl-card-body{padding:var(--space-lg);flex:1;display:flex;flex-direction:column;gap:var(--space-sm);}
.vl-card-icon{font-size:2rem;margin-bottom:var(--space-xs);}
.vl-card-title{font-family:var(--font-primary);font-size:1rem;font-weight:700;color:var(--color-text);}
.vl-card-desc{font-size:.8125rem;color:var(--color-text-secondary);line-height:1.5;flex:1;}
.vl-card-meta{display:flex;flex-wrap:wrap;gap:var(--space-sm);font-size:.75rem;color:var(--color-text-muted);}
.vl-card-meta span{display:flex;align-items:center;gap:3px;}
.vl-badge{display:inline-flex;align-items:center;gap:4px;padding:3px 10px;border-radius:var(--border-radius-full);font-size:.6875rem;font-weight:700;}
.vl-badge-done{background:#DCFCE7;color:#15803D;}
.vl-badge-new{background:#F0F7FF;color:#2563EB;}
.vl-card-footer{padding:var(--space-md) var(--space-lg);border-top:1px solid var(--border-color);display:flex;align-items:center;justify-content:space-between;}
@media(max-width:767px){.vl-summary{grid-template-columns:1fr;}.vl-grid{grid-template-columns:1fr;}}
</style>
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
<div class="vl-header">
    <div class="vl-title"><asp:Literal ID="litTitle" runat="server" /></div>
    <div class="vl-subtitle"><asp:Literal ID="litSubtitle" runat="server" /></div>
</div>
<asp:Literal ID="litAvailable" runat="server" Visible="false" /><asp:Literal ID="litAvailableLbl" runat="server" Visible="false" /><asp:Literal ID="litCompleted" runat="server" Visible="false" /><asp:Literal ID="litCompletedLbl" runat="server" Visible="false" /><asp:Literal ID="litInProgress" runat="server" Visible="false" /><asp:Literal ID="litInProgressLbl" runat="server" Visible="false" />
<div class="vl-filters">
    <asp:DropDownList ID="ddlLevel" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed" />
    <asp:DropDownList ID="ddlDifficulty" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed" />
    <asp:DropDownList ID="ddlStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed" />
</div>
<asp:Panel ID="pnlGrid" runat="server">
    <div class="vl-grid">
        <asp:Repeater ID="rptLabs" runat="server">
            <ItemTemplate>
                <div class="vl-card">
                    <div class="vl-card-top <%# Eval("DiffClass") %>"></div>
                    <div class="vl-card-body">
                        <div class="vl-card-icon"><%# Eval("Icon") %></div>
                        <div class="vl-card-title"><%# Eval("Title") %></div>
                        <div class="vl-card-desc"><%# Eval("Desc") %></div>
                        <div class="vl-card-meta">
                            <span><i class="bi bi-bar-chart-fill"></i> <%# Eval("Level") %></span>
                            <span><i class="bi bi-collection"></i> <%# Eval("Unit") %></span>
                            <span><i class="bi bi-speedometer2"></i> <%# Eval("Difficulty") %></span>
                        </div>
                    </div>
                    <div class="vl-card-footer">
                        <span class="vl-badge <%# Eval("BadgeClass") %>"><%# Eval("StatusText") %></span>
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
        <div class="empty-icon" style="font-size:3.5rem;">🧪</div>
        <div class="empty-title"><asp:Literal ID="litEmptyTitle" runat="server" /></div>
        <div class="empty-desc"><asp:Literal ID="litEmptyDesc" runat="server" /></div>
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="sb-btn sb-btn-primary sb-btn-sm mt-lg">
            <i class="bi bi-book"></i> <asp:Literal ID="litEmptyBtn" runat="server" />
        </a>
    </div>
</asp:Panel>
</asp:Content>
