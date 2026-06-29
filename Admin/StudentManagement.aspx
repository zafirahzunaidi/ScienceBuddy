<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StudentManagement.aspx.cs"
    Inherits="ScienceBuddy.Admin.StudentManagement" MasterPageFile="~/Site.Master"
    Title="Student Management" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root { --sm-accent:#6366F1; --sm-accent-light:#EEF2FF; --sm-green:#10B981; --sm-orange:#F59E0B; --sm-pink:#EC4899; --sm-cyan:#06B6D4; }

/* Page header */
.sm-header { display:flex; align-items:center; justify-content:space-between; gap:var(--space-lg); margin-bottom:var(--space-xl); flex-wrap:wrap; }
.sm-header-left {}
.sm-header-title { font-family:var(--font-primary); font-size:1.75rem; font-weight:800; color:var(--color-text); display:flex; align-items:center; gap:var(--space-sm); margin-bottom:var(--space-xs); }
.sm-header-sub { font-size:.9375rem; color:var(--color-text-secondary); max-width:460px; line-height:1.5; }
.sm-badge-dir { display:inline-flex; align-items:center; gap:4px; background:var(--sm-accent-light); color:var(--sm-accent); font-size:.75rem; font-weight:700; padding:4px 12px; border-radius:var(--border-radius-full); margin-top:var(--space-sm); }
.sm-header-icon { width:72px; height:72px; border-radius:var(--border-radius-xl); background:linear-gradient(135deg,var(--sm-accent),#818CF8); display:flex; align-items:center; justify-content:center; font-size:2rem; color:#fff; box-shadow:0 8px 24px rgba(99,102,241,.3); flex-shrink:0; }

/* Insight cards */
.sm-insights { display:grid; grid-template-columns:repeat(4,1fr); gap:var(--space-md); margin-bottom:var(--space-xl); }
.sm-insight {
    border-radius:var(--border-radius-xl); padding:var(--space-lg); color:#fff;
    display:flex; flex-direction:column; gap:var(--space-sm);
    transition:transform .2s,box-shadow .2s; position:relative; overflow:hidden;
}
.sm-insight:hover { transform:translateY(-4px); box-shadow:var(--shadow-lg); }
.sm-insight::after { content:''; position:absolute; width:120px; height:120px; border-radius:50%; background:rgba(255,255,255,.08); top:-30px; right:-30px; pointer-events:none; }
.sm-insight.gi-total   { background:linear-gradient(135deg,#6366F1,#818CF8); }
.sm-insight.gi-xp      { background:linear-gradient(135deg,#F59E0B,#FBBF24); }
.sm-insight.gi-level   { background:linear-gradient(135deg,#10B981,#34D399); }
.sm-insight.gi-active  { background:linear-gradient(135deg,#EC4899,#F472B6); }
.sm-insight-ico { font-size:1.75rem; opacity:.9; }
.sm-insight-val { font-family:var(--font-primary); font-size:2rem; font-weight:800; line-height:1; }
.sm-insight-lbl { font-size:.8125rem; opacity:.85; font-weight:600; }

/* Search panel */
.sm-search-panel {
    background:var(--color-white); border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color); box-shadow:var(--shadow-md);
    padding:var(--space-lg) var(--space-xl);
    display:flex; align-items:center; gap:var(--space-md); flex-wrap:wrap;
    margin-bottom:var(--space-xl); transition:box-shadow .2s ease;
}
.sm-search-panel:focus-within { box-shadow:0 8px 32px rgba(99,102,241,.12); }
.sm-search-panel .sb-input { flex:1; min-width:200px; max-width:320px; }
.sm-search-panel .sb-select { max-width:170px; }

/* Student grid */
.sm-grid { display:grid; grid-template-columns:repeat(4,1fr); gap:var(--space-lg); }
.sm-card {
    background:var(--color-white); border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color); box-shadow:var(--shadow-sm);
    padding:var(--space-xl) var(--space-lg); display:flex; flex-direction:column;
    align-items:center; text-align:center; transition:transform .25s ease,box-shadow .25s ease;
    position:relative; animation:sm-fadeIn .4s ease both;
}
.sm-card:nth-child(2) { animation-delay:.05s; }
.sm-card:nth-child(3) { animation-delay:.1s; }
.sm-card:nth-child(4) { animation-delay:.15s; }
.sm-card:nth-child(5) { animation-delay:.2s; }
.sm-card:nth-child(6) { animation-delay:.25s; }
.sm-card:nth-child(7) { animation-delay:.3s; }
.sm-card:nth-child(8) { animation-delay:.35s; }
.sm-card:hover { transform:translateY(-6px); box-shadow:0 12px 32px rgba(99,102,241,.15); }
@keyframes sm-fadeIn { from { opacity:0; transform:translateY(12px); } to { opacity:1; transform:translateY(0); } }
.sm-avatar {
    width:64px; height:64px; border-radius:50%;
    background:linear-gradient(135deg,var(--sm-accent),#818CF8);
    display:flex; align-items:center; justify-content:center;
    color:#fff; font-size:1.375rem; font-weight:800; margin-bottom:var(--space-md);
    position:relative; flex-shrink:0;
}
.sm-avatar-status {
    position:absolute; bottom:2px; right:2px; width:14px; height:14px;
    border-radius:50%; border:2.5px solid #fff;
}
.sm-avatar-status.active { background:var(--sm-green); }
.sm-avatar-status.inactive { background:#94A3B8; }
.sm-name { font-family:var(--font-primary); font-size:1rem; font-weight:700; color:var(--color-text); margin-bottom:2px; }
.sm-username { font-size:.8125rem; color:var(--color-text-muted); margin-bottom:var(--space-sm); }
.sm-badges { display:flex; flex-wrap:wrap; gap:4px; justify-content:center; margin-bottom:var(--space-md); }
.sm-badge-pill { font-size:.6875rem; font-weight:700; padding:3px 8px; border-radius:var(--border-radius-full); transition:transform .15s ease; }
.sm-badge-pill:hover { transform:scale(1.08); }
.sm-badge-level { background:#DBEAFE; color:#1D4ED8; }
.sm-badge-personality { background:#F3E8FF; color:#7C3AED; }
.sm-badge-lang { background:#ECFDF5; color:#059669; }
.sm-progress-section { width:100%; margin-bottom:var(--space-md); text-align:left; }
.sm-progress-row { display:flex; align-items:center; justify-content:space-between; font-size:.75rem; color:var(--color-text-muted); margin-bottom:4px; }
.sm-progress-bar { height:6px; background:#F1F5F9; border-radius:var(--border-radius-full); overflow:hidden; margin-bottom:6px; }
.sm-progress-fill { height:100%; border-radius:var(--border-radius-full); background:linear-gradient(90deg,var(--sm-accent),#818CF8); transition:width .8s cubic-bezier(.4,0,.2,1); }
.sm-meta { font-size:.75rem; color:var(--color-text-muted); display:flex; gap:var(--space-md); justify-content:center; margin-bottom:var(--space-md); }
.sm-meta span { display:flex; align-items:center; gap:3px; }
.sm-card-footer { width:100%; display:flex; gap:var(--space-sm); justify-content:center; margin-top:auto; }

/* Empty state */
.sm-empty { display:flex; flex-direction:column; align-items:center; justify-content:center; text-align:center; padding:var(--space-3xl); }
.sm-empty-ico { font-size:4rem; margin-bottom:var(--space-lg); opacity:.4; }
.sm-empty-msg { font-size:1.0625rem; font-weight:700; color:var(--color-text-secondary); }
.sm-empty-sub { font-size:.875rem; color:var(--color-text-muted); margin-top:4px; }

/* Responsive */
@media(max-width:1279px) { .sm-grid { grid-template-columns:repeat(3,1fr); } .sm-insights { grid-template-columns:repeat(2,1fr); } }
@media(max-width:1023px) { .sm-grid { grid-template-columns:repeat(2,1fr); } }
@media(max-width:767px) {
    .sm-header { flex-direction:column; align-items:flex-start; }
    .sm-header-icon { display:none; }
    .sm-grid { grid-template-columns:1fr; }
    .sm-insights { grid-template-columns:1fr 1fr; }
    .sm-search-panel { flex-direction:column; align-items:stretch; }
    .sm-search-panel .sb-input,.sm-search-panel .sb-select { max-width:100%; }
    .sm-header-title { font-size:1.375rem; }
}
@media(max-width:479px) { .sm-insights { grid-template-columns:1fr; } }
</style>
</asp:Content>

<%-- ════ SIDEBAR ════ --%>
<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Main</div>
        <a href="<%: ResolveUrl("~/Admin/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label">Dashboard</span></a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">User Management</div>
        <a href="<%: ResolveUrl("~/Admin/StudentManagement.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-people item-icon"></i><span class="item-label">Students</span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-person-heart item-icon"></i><span class="item-label">Parents</span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-person-badge item-icon"></i><span class="item-label">Teachers</span></a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Learning Content</div>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label">Lessons</span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label">Quizzes</span></a>
        <a href="<%: ResolveUrl("~/Admin/ContentRequests.aspx") %>" class="sb-sidebar-item"><i class="bi bi-inbox item-icon"></i><span class="item-label">Content Requests</span></a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Admin/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span></a>
        <a href="<%: ResolveUrl("~/Admin/Profile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item" onclick="return confirm('Are you sure you want to sign out?');"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%= T("Student Management", "Pengurusan Pelajar") %></asp:Content>

<%-- ════ MAIN CONTENT ════ --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- PAGE HEADER --%>
<div class="sm-header">
    <div class="sm-header-left">
        <h1 class="sm-header-title"><i class="bi bi-mortarboard-fill" style="color:var(--sm-accent);"></i> <%= T("Student Management", "Pengurusan Pelajar") %></h1>
        <p class="sm-header-sub"><%= T("Manage, monitor and explore student learning progress across ScienceBuddy.", "Urus, pantau dan terokai kemajuan pembelajaran pelajar di ScienceBuddy.") %></p>
        <span class="sm-badge-dir"><i class="bi bi-people-fill"></i> <%= T("Student Directory", "Direktori Pelajar") %></span>
    </div>
    <div class="sm-header-icon"><i class="bi bi-mortarboard-fill"></i></div>
</div>

<%-- INSIGHT CARDS --%>
<div class="sm-insights">
    <div class="sm-insight gi-total">
        <div class="sm-insight-ico"><i class="bi bi-book-fill"></i></div>
        <div class="sm-insight-val"><asp:Literal ID="litTotal" runat="server" Text="0" /></div>
        <div class="sm-insight-lbl"><%= T("Registered learners", "Pelajar berdaftar") %></div>
    </div>
    <div class="sm-insight gi-xp">
        <div class="sm-insight-ico"><i class="bi bi-star-fill"></i></div>
        <div class="sm-insight-val"><asp:Literal ID="litAvgXP" runat="server" Text="0" /></div>
        <div class="sm-insight-lbl"><%= T("Average XP earned", "Purata XP diperoleh") %></div>
    </div>
    <div class="sm-insight gi-level">
        <div class="sm-insight-ico"><i class="bi bi-trophy-fill"></i></div>
        <div class="sm-insight-val"><asp:Literal ID="litHighLevel" runat="server" Text="-" /></div>
        <div class="sm-insight-lbl"><%= T("Highest level reached", "Tahap tertinggi dicapai") %></div>
    </div>
    <div class="sm-insight gi-active">
        <div class="sm-insight-ico"><i class="bi bi-fire"></i></div>
        <div class="sm-insight-val"><asp:Literal ID="litActive" runat="server" Text="0" /></div>
        <div class="sm-insight-lbl"><%= T("Active students", "Pelajar aktif") %></div>
    </div>
</div>

<%-- SEARCH PANEL --%>
<div class="sm-search-panel">
    <i class="bi bi-search text-muted"></i>
    <asp:TextBox ID="txtSearch" runat="server" CssClass="sb-input sb-input-sm" AutoPostBack="false" />
    <asp:DropDownList ID="ddlLevel" runat="server" CssClass="sb-select sb-input-sm" AutoPostBack="false">
        <asp:ListItem Value="">All Levels</asp:ListItem>
    </asp:DropDownList>
    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="sb-select sb-input-sm" AutoPostBack="false">
        <asp:ListItem Value="">All Status</asp:ListItem>
        <asp:ListItem Value="Active">Active</asp:ListItem>
        <asp:ListItem Value="Blocked">Blocked</asp:ListItem>
    </asp:DropDownList>
    <asp:DropDownList ID="ddlLang" runat="server" CssClass="sb-select sb-input-sm" AutoPostBack="false">
        <asp:ListItem Value="">All Languages</asp:ListItem>
        <asp:ListItem Value="EN">English</asp:ListItem>
        <asp:ListItem Value="BM">Bahasa Melayu</asp:ListItem>
    </asp:DropDownList>
    <asp:DropDownList ID="ddlSort" runat="server" CssClass="sb-select sb-input-sm" AutoPostBack="false">
        <asp:ListItem Value="name">A-Z</asp:ListItem>
        <asp:ListItem Value="name_desc">Z-A</asp:ListItem>
        <asp:ListItem Value="xp_desc">Highest XP</asp:ListItem>
        <asp:ListItem Value="xp_asc">Lowest XP</asp:ListItem>
    </asp:DropDownList>
    <asp:Button ID="btnSearch" runat="server" CssClass="sb-btn sb-btn-primary sb-btn-sm" OnClick="btnSearch_Click" />
    <asp:Button ID="btnReset" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnReset_Click" />
</div>

<%-- STUDENT CARDS --%>
<asp:Panel ID="pnlStudents" runat="server" Visible="false">
    <div class="sm-grid">
        <asp:Repeater ID="rptStudents" runat="server">
            <ItemTemplate>
                <div class="sm-card">
                    <div class="sm-avatar" style='<%# Eval("avatarGradient") %>'>
                        <%# HttpUtility.HtmlEncode(Eval("initials")) %>
                        <span class='sm-avatar-status <%# Eval("statusClass") %>'></span>
                    </div>
                    <div class="sm-name"><%# HttpUtility.HtmlEncode(Eval("displayName")) %></div>
                    <div class="sm-username">@<%# HttpUtility.HtmlEncode(Eval("username")) %></div>
                    <div class="sm-badges">
                        <span class="sm-badge-pill sm-badge-level"><%# HttpUtility.HtmlEncode(Eval("levelName")) %></span>
                        <span class="sm-badge-pill sm-badge-personality"><%# HttpUtility.HtmlEncode(Eval("personalityName")) %></span>
                        <span class="sm-badge-pill sm-badge-lang"><%# HttpUtility.HtmlEncode(Eval("language")) %></span>
                    </div>
                    <div class="sm-progress-section">
                        <div class="sm-progress-row"><span>XP</span><span><%# Eval("xp") %></span></div>
                        <div class="sm-progress-bar"><div class="sm-progress-fill" style='width:<%# Eval("xpPct") %>%'></div></div>
                    </div>
                    <div class="sm-meta">
                        <span><i class="bi bi-book"></i> <%# Eval("lessonsCompleted") %></span>
                        <span><i class="bi bi-trophy"></i> <%# Eval("badgesEarned") %></span>
                    </div>
                    <div class="sm-card-footer">
                        <button type="button" class="sb-btn sb-btn-light sb-btn-xs" onclick="alert('<%= T("Student profile coming soon.", "Profil pelajar akan datang.") %>');">
                            <i class="bi bi-eye"></i> <%= T("View Details", "Lihat Butiran") %>
                        </button>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>

<%-- EMPTY STATE --%>
<asp:Panel ID="pnlEmpty" runat="server">
    <div class="sm-empty">
        <div class="sm-empty-ico"><i class="bi bi-mortarboard-fill"></i></div>
        <div class="sm-empty-msg"><%= T("No students found.", "Tiada pelajar ditemui.") %></div>
        <div class="sm-empty-sub"><%= T("Try adjusting your search or filters.", "Cuba laraskan carian atau penapis anda.") %></div>
    </div>
</asp:Panel>

</asp:Content>
