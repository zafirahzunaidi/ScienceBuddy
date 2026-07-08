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

/* Modal overlay fix — only cover content area, not sidebar */
.sm-modal-wrap .sb-modal-overlay { left:var(--sidebar-width); }
.sidebar-collapsed .sm-modal-wrap .sb-modal-overlay { left:var(--sidebar-collapsed); }
@media(max-width:767px) { .sm-modal-wrap .sb-modal-overlay { left:0; } }

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
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" />
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="<%: ResolveUrl("~/Scripts/admin-signout.js") %>"></script>
</asp:Content>

<%-- ════ SIDEBAR ════ --%>
<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label">Main</div>
        <a href="<%: ResolveUrl("~/Admin/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label">Dashboard</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">User Management</div>
        <a href="<%: ResolveUrl("~/Admin/StudentManagement.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-people item-icon"></i><span class="item-label">Students</span></a>
        <a href="<%: ResolveUrl("~/Admin/ParentManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-heart item-icon"></i><span class="item-label">Parents</span></a>
        <a href="<%: ResolveUrl("~/Admin/TeacherManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-badge item-icon"></i><span class="item-label">Teachers</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Learning Content</div>
        <a href="<%: ResolveUrl("~/Admin/LessonManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label">Lessons</span></a>
        <a href="<%: ResolveUrl("~/Admin/QuizManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label">Quizzes</span></a>
        <a href="<%: ResolveUrl("~/Admin/QuestionBank.aspx") %>" class="sb-sidebar-item"><i class="bi bi-question-circle item-icon"></i><span class="item-label">Question Bank</span></a>
        <a href="<%: ResolveUrl("~/Admin/TeacherMaterials.aspx") %>" class="sb-sidebar-item"><i class="bi bi-file-earmark-text item-icon"></i><span class="item-label">Material Requests</span></a>
        <a href="<%: ResolveUrl("~/Admin/LiveSessions.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label">Live Sessions</span></a>
        <a href="<%: ResolveUrl("~/Admin/QuestionRequests.aspx") %>" class="sb-sidebar-item"><i class="bi bi-clipboard-check item-icon"></i><span class="item-label">Question Requests</span></a>
        <a href="<%: ResolveUrl("~/Admin/CertificateManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-award item-icon"></i><span class="item-label">Certificates</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Community</div>
        <a href="<%: ResolveUrl("~/Admin/ForumDiscussions.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label">Forum Discussions</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Gamification</div>
        <a href="<%: ResolveUrl("~/Admin/GamificationManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-trophy item-icon"></i><span class="item-label">Student Performance</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Configuration</div>
        <a href="<%: ResolveUrl("~/Admin/SystemSettings.aspx") %>" class="sb-sidebar-item"><i class="bi bi-gear item-icon"></i><span class="item-label">System Settings</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Logs</div>
        <a href="<%: ResolveUrl("~/Admin/SystemActivityLogs.aspx") %>" class="sb-sidebar-item"><i class="bi bi-clock-history item-icon"></i><span class="item-label">Activity Logs</span></a>
        <a href="<%: ResolveUrl("~/Admin/LoginLogs.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-in-right item-icon"></i><span class="item-label">Login Logs</span></a>
        <a href="<%: ResolveUrl("~/Admin/SuspiciousLogins.aspx") %>" class="sb-sidebar-item"><i class="bi bi-exclamation-triangle item-icon"></i><span class="item-label">Suspicious Logins</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Admin/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span></a>
        <a href="<%: ResolveUrl("~/Admin/Profile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a>
        <a href="javascript:;" class="sb-sidebar-item" onclick="showSignOutModal()"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a>
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
    <div style="display:flex;align-items:center;gap:var(--space-md);">
        <div class="sm-header-icon"><i class="bi bi-mortarboard-fill"></i></div>
        <a href="javascript:;" onclick="openAddStudent()" style="display:inline-flex;align-items:center;gap:8px;padding:12px 24px;background:linear-gradient(135deg,#1D4ED8,#2563EB,#3B82F6);color:#fff;border-radius:12px;font-weight:700;font-size:.9rem;text-decoration:none;box-shadow:0 6px 20px rgba(37,99,235,.35);transition:all .25s;">
            <i class="bi bi-person-plus-fill"></i> <%= T("+ Add Student", "+ Tambah Pelajar") %>
        </a>
    </div>
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
        <asp:Repeater ID="rptStudents" runat="server" OnItemCommand="rptStudents_ItemCommand">
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
                        <asp:LinkButton ID="lnkViewDetails" runat="server" CssClass="sb-btn sb-btn-light sb-btn-xs"
                            CommandName="ViewStudent" CommandArgument='<%# Eval("studentId") %>'>
                            <i class="bi bi-eye"></i> <%= T("View Details", "Lihat Butiran") %>
                        </asp:LinkButton>
                        <a href='<%# ResolveUrl("~/Admin/StudentDetails.aspx?id=" + Eval("studentId")) %>' class="sb-btn sb-btn-primary sb-btn-xs" style="margin-left:6px;">
                            <i class="bi bi-gear"></i> <%= T("Manage", "Urus") %>
                        </a>
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

<%-- ══ STUDENT DETAIL MODAL ══ --%>
<asp:Panel ID="pnlModal" runat="server" Visible="false" CssClass="sm-modal-wrap">
<div class="sb-modal-overlay active" style="display:flex;margin-left:0;">
    <div class="sb-modal" style="max-width:560px;max-height:90vh;overflow-y:auto;">
        <%-- Modal gradient header --%>
        <div style="background:linear-gradient(135deg,#6366F1,#818CF8);padding:var(--space-xl);color:#fff;text-align:center;border-radius:var(--border-radius-xl) var(--border-radius-xl) 0 0;">
            <div style="width:72px;height:72px;border-radius:50%;margin:0 auto var(--space-sm);display:flex;align-items:center;justify-content:center;font-size:1.75rem;font-weight:800;background:rgba(255,255,255,.2);border:3px solid rgba(255,255,255,.4);">
                <asp:Literal ID="litMInitials" runat="server" />
            </div>
            <div style="font-family:var(--font-primary);font-size:1.25rem;font-weight:800;"><asp:Literal ID="litMName" runat="server" /></div>
            <div style="font-size:.875rem;opacity:.8;">@<asp:Literal ID="litMUsername" runat="server" /></div>
        </div>
        <%-- Stats row --%>
        <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:var(--space-xs);padding:var(--space-md);background:var(--color-surface-alt);text-align:center;">
            <div><div style="font-family:var(--font-primary);font-size:1.125rem;font-weight:800;color:var(--color-text);"><asp:Literal ID="litMLessons" runat="server" Text="0" /></div><div style="font-size:.6875rem;color:var(--color-text-muted);font-weight:600;"><%= T("Lessons", "Pelajaran") %></div></div>
            <div><div style="font-family:var(--font-primary);font-size:1.125rem;font-weight:800;color:var(--color-text);"><asp:Literal ID="litMXP" runat="server" Text="0" /></div><div style="font-size:.6875rem;color:var(--color-text-muted);font-weight:600;">XP</div></div>
            <div><div style="font-family:var(--font-primary);font-size:1.125rem;font-weight:800;color:var(--color-text);"><asp:Literal ID="litMQuizzes" runat="server" Text="0" /></div><div style="font-size:.6875rem;color:var(--color-text-muted);font-weight:600;"><%= T("Quizzes", "Kuiz") %></div></div>
            <div><div style="font-family:var(--font-primary);font-size:1.125rem;font-weight:800;color:var(--color-text);"><asp:Literal ID="litMBadges" runat="server" Text="0" /></div><div style="font-size:.6875rem;color:var(--color-text-muted);font-weight:600;"><%= T("Badges", "Lencana") %></div></div>
        </div>
        <%-- Body fields --%>
        <div style="padding:var(--space-lg);">
            <div style="margin-bottom:var(--space-md);"><div style="font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;"><%= T("Email", "E-mel") %></div><div style="font-size:.9375rem;font-weight:600;color:var(--color-text);"><asp:Literal ID="litMEmail" runat="server" Text="-" /></div></div>
            <div style="margin-bottom:var(--space-md);"><div style="font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;"><%= T("Phone", "Telefon") %></div><div style="font-size:.9375rem;font-weight:600;color:var(--color-text);"><asp:Literal ID="litMPhone" runat="server" Text="-" /></div></div>
            <div style="margin-bottom:var(--space-md);"><div style="font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;"><%= T("Level", "Tahap") %></div><div style="font-size:.9375rem;font-weight:600;color:var(--color-text);"><asp:Literal ID="litMLevel" runat="server" Text="-" /></div></div>
            <div style="margin-bottom:var(--space-md);"><div style="font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;"><%= T("Personality", "Personaliti") %></div><div style="font-size:.9375rem;font-weight:600;color:var(--color-text);"><asp:Literal ID="litMPersonality" runat="server" Text="-" /></div></div>
            <div style="margin-bottom:var(--space-md);"><div style="font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;"><%= T("Language", "Bahasa") %></div><div style="font-size:.9375rem;font-weight:600;color:var(--color-text);"><asp:Literal ID="litMLangVal" runat="server" Text="-" /></div></div>
            <div style="margin-bottom:var(--space-md);"><div style="font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;"><%= T("Status", "Status") %></div><div style="font-size:.9375rem;font-weight:600;"><asp:Literal ID="litMStatus" runat="server" Text="-" /></div></div>
            <%-- XP Progress --%>
            <div style="margin-bottom:var(--space-md);">
                <div style="font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:4px;"><%= T("XP Progress", "Kemajuan XP") %></div>
                <div style="height:8px;background:#F1F5F9;border-radius:99px;overflow:hidden;"><div style="height:100%;border-radius:99px;background:linear-gradient(90deg,#6366F1,#818CF8);width:<%= litMXPPct.Text %>%;"></div></div>
            </div>
        </div>
        <%-- Footer --%>
        <div class="sb-modal-footer">
            <asp:Button ID="btnCloseModal" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnCloseModal_Click" />
        </div>
    </div>
</div>
</asp:Panel>
<asp:Literal ID="litMXPPct" runat="server" Text="0" Visible="false" />

<%-- ADD STUDENT MODAL --%>
<div id="addStudentOverlay" style="display:none;position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,.5);z-index:2000;align-items:center;justify-content:center;padding:20px;">
<div style="background:#fff;border-radius:20px;width:100%;max-width:580px;max-height:90vh;overflow-y:auto;box-shadow:0 25px 60px rgba(0,0,0,.2);animation:smIn .3s ease;">
<style>@keyframes smIn{from{opacity:0;transform:scale(.95)}to{opacity:1;transform:scale(1)}}
.add-field{margin-bottom:16px;}.add-label{font-size:.75rem;font-weight:700;color:#64748B;text-transform:uppercase;letter-spacing:.5px;margin-bottom:4px;display:block;}
.add-input{width:100%;padding:10px 14px;border:1.5px solid #E2E8F0;border-radius:10px;font-size:.9rem;transition:border-color .2s;}.add-input:focus{outline:none;border-color:#2563EB;box-shadow:0 0 0 3px rgba(37,99,235,.1);}
.add-input.error{border-color:#DC2626;}.add-err{font-size:.75rem;color:#DC2626;margin-top:3px;display:none;}.add-grid{display:grid;grid-template-columns:1fr 1fr;gap:12px;}
</style>
<div style="padding:24px 28px;border-bottom:1px solid #F1F5F9;display:flex;align-items:center;justify-content:space-between;">
    <div><div style="font-family:var(--font-primary);font-size:1.1rem;font-weight:800;display:flex;align-items:center;gap:8px;"><i class="bi bi-person-plus-fill" style="color:#2563EB;"></i> <%= T("Add New Student","Tambah Pelajar Baharu") %></div><div style="font-size:.8rem;color:#64748B;margin-top:2px;"><%= T("Create a new student account.","Cipta akaun pelajar baharu.") %></div></div>
    <button onclick="closeAddStudent()" style="width:36px;height:36px;border:none;background:#F1F5F9;border-radius:10px;cursor:pointer;display:flex;align-items:center;justify-content:center;"><i class="bi bi-x-lg"></i></button>
</div>
<div style="padding:24px 28px;">
<div class="add-grid">
<div class="add-field"><label class="add-label"><%= T("Full Name *","Nama Penuh *") %></label><input id="s_name" class="add-input" type="text" /><div class="add-err" id="e_name">Required</div></div>
<div class="add-field"><label class="add-label"><%= T("Username *","Nama Pengguna *") %></label><input id="s_username" class="add-input" type="text" /><div class="add-err" id="e_username">Required</div></div>
<div class="add-field"><label class="add-label"><%= T("Email *","E-mel *") %></label><input id="s_email" class="add-input" type="email" /><div class="add-err" id="e_email">Required</div></div>
<div class="add-field"><label class="add-label"><%= T("Phone","Telefon") %></label><input id="s_phone" class="add-input" type="text" /></div>
<div class="add-field"><label class="add-label"><%= T("Password *","Kata Laluan *") %></label><input id="s_pw" class="add-input" type="password" /><div class="add-err" id="e_pw">Min 8 chars</div></div>
<div class="add-field"><label class="add-label"><%= T("Confirm Password *","Sahkan Kata Laluan *") %></label><input id="s_pw2" class="add-input" type="password" /><div class="add-err" id="e_pw2">Passwords do not match</div></div>
<div class="add-field"><label class="add-label"><%= T("Language","Bahasa") %></label><select id="s_lang" class="add-input"><option value="EN">English</option><option value="BM">Bahasa Melayu</option></select></div>
<div class="add-field"><label class="add-label"><%= T("Level","Tahap") %></label><select id="s_level" class="add-input"><option value="LV001">Beginner</option><option value="LV002">Intermediate</option><option value="LV003">Advanced</option></select></div>
</div>
<div style="display:flex;gap:10px;justify-content:flex-end;margin-top:20px;padding-top:16px;border-top:1px solid #F1F5F9;">
<button onclick="closeAddStudent()" style="padding:10px 22px;border-radius:10px;border:1.5px solid #E2E8F0;background:#fff;font-weight:600;cursor:pointer;"><%= T("Cancel","Batal") %></button>
<button onclick="submitAddStudent()" style="padding:10px 26px;border-radius:10px;border:none;background:linear-gradient(135deg,#1D4ED8,#3B82F6);color:#fff;font-weight:700;cursor:pointer;box-shadow:0 4px 14px rgba(37,99,235,.3);"><i class="bi bi-person-plus-fill"></i> <%= T("Create Student","Cipta Pelajar") %></button>
</div>
</div></div></div>

<script>
function openAddStudent(){var o=document.getElementById('addStudentOverlay');o.style.display='flex';}
function closeAddStudent(){document.getElementById('addStudentOverlay').style.display='none';}
function submitAddStudent(){
    var n=document.getElementById('s_name').value.trim(),u=document.getElementById('s_username').value.trim(),e=document.getElementById('s_email').value.trim(),pw=document.getElementById('s_pw').value,pw2=document.getElementById('s_pw2').value;
    var ok=true;
    ['e_name','e_username','e_email','e_pw','e_pw2'].forEach(function(id){document.getElementById(id).style.display='none';});
    if(!n){document.getElementById('e_name').style.display='block';ok=false;}
    if(!u){document.getElementById('e_username').style.display='block';ok=false;}
    if(!e||e.indexOf('@')<0){document.getElementById('e_email').style.display='block';ok=false;}
    if(pw.length<8){document.getElementById('e_pw').style.display='block';ok=false;}
    if(pw!==pw2){document.getElementById('e_pw2').style.display='block';ok=false;}
    if(!ok)return;
    // Collect extra fields before closing overlay
    var ph=document.getElementById('s_phone').value.trim(),lang=document.getElementById('s_lang').value,lv=document.getElementById('s_level').value;
    // Hide overlay so SweetAlert is visible on top
    closeAddStudent();
    Swal.fire({
        title:'<%= T("Create this student?","Cipta pelajar ini?") %>',
        html:'<div style="text-align:left;margin-top:8px;"><b><%= T("Name","Nama") %>:</b> '+n+'<br><b>Username:</b> '+u+'<br><b>Email:</b> '+e+'</div>',
        icon:'question',showCancelButton:true,
        confirmButtonText:'<i class="bi bi-person-plus-fill"></i> <%= T("Yes, Create","Ya, Cipta") %>',
        cancelButtonText:'<%= T("Cancel","Batal") %>',
        confirmButtonColor:'#2563EB',
        reverseButtons:true
    }).then(function(r){
        if(!r.isConfirmed){openAddStudent();return;} // reopen if cancelled
        fetch(window.location.pathname+'?handler=StudentCRUD&action=add&name='+encodeURIComponent(n)+'&username='+encodeURIComponent(u)+'&email='+encodeURIComponent(e)+'&password='+encodeURIComponent(pw)+'&phone='+encodeURIComponent(ph)+'&lang='+lang+'&levelId='+lv,{method:'POST',headers:{'X-Requested-With':'XMLHttpRequest'}})
        .then(function(r){return r.json();})
        .then(function(d){
            if(d.success){
                Swal.fire({icon:'success',title:'<%= T("Student Created!","Pelajar Dicipta!") %>',text:'<%= T("The account has been added to ScienceBuddy.","Akaun telah ditambah ke ScienceBuddy.") %>',confirmButtonColor:'#2563EB',timer:3000,timerProgressBar:true})
                .then(function(){location.reload();});
            } else {
                openAddStudent();
                Swal.fire({icon:'error',title:'<%= T("Error","Ralat") %>',text:d.msg,confirmButtonColor:'#DC2626'});
            }
        }).catch(function(){openAddStudent();Swal.fire({icon:'error',title:'Network Error',text:'Please try again.'});});
    });
}
</script>

</asp:Content>
