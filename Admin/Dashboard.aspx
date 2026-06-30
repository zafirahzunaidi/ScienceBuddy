<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs"
    Inherits="ScienceBuddy.Admin.Dashboard" MasterPageFile="~/Site.Master"
    Title="Admin Dashboard" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* -- Admin Dashboard page-scoped styles -- */
:root { --admin: #2563EB; --admin-dark: #1D4ED8; --admin-light: #DBEAFE; }

/* Hero */
.ad-hero {
    background: linear-gradient(135deg, #1D4ED8 0%, #2563EB 55%, #3B82F6 100%);
    border-radius: var(--border-radius-xl);
    padding: var(--space-2xl) var(--space-2xl);
    color: #fff;
    display: flex; align-items: center; justify-content: space-between;
    gap: var(--space-xl); position: relative; overflow: hidden;
    margin-bottom: var(--space-xl);
    box-shadow: 0 12px 40px rgba(37,99,235,.30);
}
.ad-hero::before {
    content: ''; position: absolute; width: 380px; height: 380px; border-radius: 50%;
    background: rgba(255,255,255,.06); top: -120px; right: -80px; pointer-events: none;
}
.ad-hero::after {
    content: ''; position: absolute; width: 200px; height: 200px; border-radius: 50%;
    background: rgba(255,255,255,.04); bottom: -60px; left: 40px; pointer-events: none;
}
.ad-hero-body { position: relative; z-index: 1; }
.ad-hero-eyebrow {
    font-size: .75rem; font-weight: 700; letter-spacing: 1.5px;
    text-transform: uppercase; opacity: .75; margin-bottom: 6px;
    display: flex; align-items: center; gap: 6px;
}
.ad-hero-title {
    font-family: var(--font-primary); font-size: 2rem; font-weight: 800;
    line-height: 1.2; margin-bottom: var(--space-sm);
    /* Wrap gracefully ? don't let a long admin name overflow the hero card */
    word-break: break-word;
    overflow-wrap: anywhere;
}
.ad-hero-sub { font-size: 1rem; opacity: .88; max-width: 480px; line-height: 1.55; }
.ad-hero-meta {
    margin-top: var(--space-md); display: flex; gap: var(--space-md);
    flex-wrap: wrap; align-items: center;
}
.ad-hero-chip {
    background: rgba(255,255,255,.18); border: 1.5px solid rgba(255,255,255,.30);
    border-radius: var(--border-radius-full); padding: 5px 14px;
    font-size: .8125rem; font-weight: 700;
    display: inline-flex; align-items: center; gap: 5px;
}
.ad-hero-icon {
    position: relative; z-index: 1; flex-shrink: 0;
    width: 90px; height: 90px; border-radius: var(--border-radius-xl);
    background: rgba(255,255,255,.15); border: 2px solid rgba(255,255,255,.30);
    display: flex; align-items: center; justify-content: center;
    font-size: 2.75rem;
}

/* Summary stat cards */
.ad-stats { display: grid; grid-template-columns: repeat(6,1fr); gap: var(--space-md); margin-bottom: var(--space-xl); }
.ad-stat {
    background: var(--color-white); border-radius: var(--border-radius-lg);
    border: 1.5px solid var(--border-color); box-shadow: var(--shadow-sm);
    padding: var(--space-lg); display: flex; flex-direction: column;
    gap: var(--space-sm); transition: transform .2s, box-shadow .2s;
    position: relative; overflow: hidden;
}
.ad-stat::before {
    content: ''; position: absolute; top: 0; left: 0; right: 0;
    height: 4px; border-radius: var(--border-radius-lg) var(--border-radius-lg) 0 0;
}
.ad-stat:hover { transform: translateY(-3px); box-shadow: var(--shadow-md); }
.ad-stat.c-students::before { background: linear-gradient(90deg,#2563EB,#60A5FA); }
.ad-stat.c-parents::before  { background: linear-gradient(90deg,#059669,#34D399); }
.ad-stat.c-teachers::before { background: linear-gradient(90deg,#7C3AED,#A78BFA); }
.ad-stat.c-lessons::before  { background: linear-gradient(90deg,#D97706,#FCD34D); }
.ad-stat.c-quizzes::before  { background: linear-gradient(90deg,#DC2626,#F87171); }
.ad-stat.c-requests::before { background: linear-gradient(90deg,#0891B2,#67E8F9); }
.ad-stat-icon {
    width: 42px; height: 42px; border-radius: var(--border-radius);
    display: flex; align-items: center; justify-content: center; font-size: 1.25rem;
}
.ad-stat-val {
    font-family: var(--font-primary); font-size: 1.875rem; font-weight: 800;
    line-height: 1; color: var(--color-text);
}
.ad-stat-lbl { font-size: .8125rem; color: var(--color-text-secondary); font-weight: 600; }

/* Quick actions */
.ad-quick { display: grid; grid-template-columns: repeat(5,1fr); gap: var(--space-md); margin-bottom: var(--space-xl); }
.ad-quick-card {
    background: var(--color-white); border-radius: var(--border-radius-xl);
    border: 1.5px solid var(--border-color); box-shadow: var(--shadow-sm);
    padding: var(--space-lg) var(--space-md); text-decoration: none;
    transition: transform .2s, box-shadow .2s;
    display: flex; flex-direction: column; align-items: flex-start;
    gap: 8px; position: relative; overflow: hidden;
}
.ad-quick-card::after {
    content: ''; position: absolute; bottom: 0; left: 0; right: 0;
    height: 3px; border-radius: 0 0 var(--border-radius-xl) var(--border-radius-xl);
}
.ad-quick-card:hover { transform: translateY(-4px); box-shadow: var(--shadow-lg); text-decoration: none; }
.ad-qc-users::after    { background: linear-gradient(90deg,#2563EB,#60A5FA); }
.ad-qc-content::after  { background: linear-gradient(90deg,#D97706,#FCD34D); }
.ad-qc-requests::after { background: linear-gradient(90deg,#0891B2,#67E8F9); }
.ad-qc-gamify::after   { background: linear-gradient(90deg,#7C3AED,#A78BFA); }
.ad-qc-notif::after    { background: linear-gradient(90deg,#DC2626,#F87171); }
.ad-quick-ico {
    width: 46px; height: 46px; border-radius: var(--border-radius);
    font-size: 1.25rem; display: flex; align-items: center; justify-content: center;
}
.ad-quick-lbl { font-family: var(--font-primary); font-size: .9375rem; font-weight: 800; color: var(--color-text); line-height: 1.2; }
.ad-quick-desc { font-size: .8rem; color: var(--color-text-muted); line-height: 1.4; }

/* Section heading */
.ad-sec-hd {
    display: flex; align-items: center; justify-content: space-between;
    margin-bottom: var(--space-md); gap: var(--space-md);
}
.ad-sec-title {
    font-family: var(--font-primary); font-size: 1.0625rem; font-weight: 800;
    color: var(--color-text); display: flex; align-items: center; gap: var(--space-sm);
}

/* Two-column layout row */
.ad-row2 { display: grid; grid-template-columns: 1fr 1fr; gap: var(--space-xl); margin-bottom: var(--space-xl); }
.ad-row3 { margin-bottom: var(--space-xl); }

/* Card wrapper */
.ad-card {
    background: var(--color-white); border-radius: var(--border-radius-xl);
    border: 1.5px solid var(--border-color); box-shadow: var(--shadow-sm); overflow: hidden;
}
.ad-card-hdr {
    padding: var(--space-md) var(--space-lg); border-bottom: 1px solid var(--border-color);
    display: flex; align-items: center; justify-content: space-between; gap: var(--space-md);
}
.ad-card-body { padding: var(--space-lg); }

/* Log / activity list */
.ad-log-list { display: flex; flex-direction: column; gap: 2px; }
.ad-log-item {
    display: flex; align-items: flex-start; gap: var(--space-md);
    padding: 10px var(--space-md); border-radius: var(--border-radius);
    transition: background .15s;
}
.ad-log-item:hover { background: var(--color-surface-alt); }
.ad-log-ico {
    width: 34px; height: 34px; border-radius: var(--border-radius);
    display: flex; align-items: center; justify-content: center;
    font-size: 1rem; flex-shrink: 0; margin-top: 2px;
}
.ad-log-body { flex: 1; min-width: 0; }
.ad-log-action { font-weight: 700; font-size: .875rem; color: var(--color-text); }
.ad-log-desc { font-size: .8125rem; color: var(--color-text-secondary); margin-top: 2px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.ad-log-meta { font-size: .75rem; color: var(--color-text-muted); margin-top: 3px; display: flex; align-items: center; gap: 6px; }

/* Notification list */
.ad-notif-list { display: flex; flex-direction: column; }
.ad-notif-item {
    padding: var(--space-md) var(--space-lg); border-bottom: 1px solid #F0F7FF;
    display: flex; gap: var(--space-md); align-items: flex-start;
}
.ad-notif-item:last-child { border-bottom: none; }
.ad-notif-dot {
    width: 10px; height: 10px; border-radius: 50%; margin-top: 5px; flex-shrink: 0;
    background: var(--admin); box-shadow: 0 0 0 3px var(--admin-light);
}
.ad-notif-dot.read { background: var(--color-text-muted); box-shadow: none; }
.ad-notif-title { font-size: .875rem; font-weight: 600; color: var(--color-text); line-height: 1.4; }
.ad-notif-msg { font-size: .8125rem; color: var(--color-text-secondary); margin-top: 2px; line-height: 1.45; }
.ad-notif-time { font-size: .75rem; color: var(--color-text-muted); margin-top: 4px; display: flex; align-items: center; gap: 4px; }

/* Empty state */
.ad-empty {
    display: flex; flex-direction: column; align-items: center;
    justify-content: center; text-align: center;
    padding: var(--space-2xl) var(--space-xl); color: var(--color-text-muted);
}
.ad-empty-ico { font-size: 2.5rem; margin-bottom: var(--space-md); opacity: .55; }
.ad-empty-msg { font-size: .9375rem; font-weight: 600; color: var(--color-text-secondary); }

/* Responsive */
@media(max-width:1279px) { .ad-stats { grid-template-columns: repeat(3,1fr); } .ad-quick { grid-template-columns: repeat(3,1fr); } }
@media(max-width:1023px) { .ad-stats { grid-template-columns: repeat(2,1fr); } .ad-quick { grid-template-columns: repeat(2,1fr); } .ad-row2 { grid-template-columns: 1fr; } }
@media(max-width:767px)  {
    .ad-hero { flex-direction: column; padding: var(--space-xl) var(--space-lg); }
    .ad-hero-icon { display: none; }
    .ad-stats { grid-template-columns: repeat(2,1fr); }
    .ad-quick { grid-template-columns: 1fr 1fr; }
    .ad-hero-title { font-size: 1.5rem; }
}
@media(max-width:479px)  { .ad-stats { grid-template-columns: 1fr 1fr; } .ad-quick { grid-template-columns: 1fr; } }
</style>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" />
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="<%: ResolveUrl("~/Scripts/admin-signout.js") %>"></script>
</asp:Content>

<%-- ---- SIDEBAR MENU ---- --%>
<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Main</div>
        <a href="<%: ResolveUrl("~/Admin/Dashboard.aspx") %>" class="sb-sidebar-item active">
            <i class="bi bi-speedometer2 item-icon"></i>
            <span class="item-label">Dashboard</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">User Management</div>
        <a href="<%: ResolveUrl("~/Admin/StudentManagement.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-people item-icon"></i>
            <span class="item-label">Students</span>
        </a>
        <a href="<%: ResolveUrl("~/Admin/ParentManagement.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-person-heart item-icon"></i>
            <span class="item-label">Parents</span>
        </a>
        <a href="<%: ResolveUrl("~/Admin/TeacherManagement.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-person-badge item-icon"></i>
            <span class="item-label">Teachers</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Learning Content</div>
        <a href="<%: ResolveUrl("~/Admin/LessonManagement.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-book item-icon"></i>
            <span class="item-label">Lessons</span>
        </a>
        <a href="<%: ResolveUrl("~/Admin/QuizManagement.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-patch-question item-icon"></i>
            <span class="item-label">Quizzes</span>
        </a>
        <a href="#" class="sb-sidebar-item">
            <i class="bi bi-question-circle item-icon"></i>
            <span class="item-label">Questions</span>
        </a>
        <a href="<%: ResolveUrl("~/Admin/TeacherMaterials.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-file-earmark-text item-icon"></i>
            <span class="item-label">Material Requests</span>
        </a>
        <a href="<%: ResolveUrl("~/Admin/LiveSessions.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-camera-video item-icon"></i>
            <span class="item-label">Live Sessions</span>
        </a>
        <a href="<%: ResolveUrl("~/Admin/QuestionRequests.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-clipboard-check item-icon"></i>
            <span class="item-label">Question Requests</span>
        </a>
        <a href="<%: ResolveUrl("~/Admin/CertificateManagement.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-award item-icon"></i>
            <span class="item-label">Certificates</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Gamification</div>
        <a href="<%: ResolveUrl("~/Admin/GamificationManagement.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-trophy item-icon"></i>
            <span class="item-label">Student Performance</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Configuration</div>
        <a href="<%: ResolveUrl("~/Admin/SystemSettings.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-gear item-icon"></i>
            <span class="item-label">System Settings</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Logs</div>
        <a href="<%: ResolveUrl("~/Admin/SystemActivityLogs.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-clock-history item-icon"></i>
            <span class="item-label">Activity Logs</span>
        </a>
        <a href="<%: ResolveUrl("~/Admin/LoginLogs.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-box-arrow-in-right item-icon"></i>
            <span class="item-label">Login Logs</span>
        </a>
        <a href="<%: ResolveUrl("~/Admin/SuspiciousLogins.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-exclamation-triangle item-icon"></i>
            <span class="item-label">Suspicious Logins</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Admin/Notifications.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-bell item-icon"></i>
            <span class="item-label">Notifications</span>
        </a>
        <a href="<%: ResolveUrl("~/Admin/Profile.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-person item-icon"></i>
            <span class="item-label">My Profile</span>
        </a>
        <a href="javascript:;" class="sb-sidebar-item" onclick="showSignOutModal()">
            <i class="bi bi-box-arrow-right item-icon"></i>
            <span class="item-label">Sign Out</span>
        </a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">Admin Dashboard</asp:Content>

<%-- ---- MAIN CONTENT ---- --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- -- 1. HERO -- --%>
<div class="ad-hero">
    <div class="ad-hero-body">
        <div class="ad-hero-eyebrow"><i class="bi bi-shield-check"></i> <%= T("Administrator Console", "Konsol Pentadbir") %></div>
        <div class="ad-hero-title"><%= T("Welcome back,", "Selamat kembali,") %> <asp:Literal ID="litAdminName" runat="server" Text="Admin" />!</div>
        <div class="ad-hero-sub"><%= T("Manage users, monitor learning content, and keep ScienceBuddy running smoothly.", "Urus pengguna, pantau kandungan pembelajaran, dan pastikan ScienceBuddy berjalan lancar.") %></div>
        <div class="ad-hero-meta">
            <span class="ad-hero-chip"><i class="bi bi-calendar3"></i> <asp:Literal ID="litDate" runat="server" /></span>
            <span class="ad-hero-chip"><i class="bi bi-person-fill-check"></i> <%= T("Administrator", "Pentadbir") %></span>
        </div>
    </div>
    <div class="ad-hero-icon">???</div>
</div>

<%-- -- 2. SUMMARY STAT CARDS -- --%>
<div class="ad-stats">
    <div class="ad-stat c-students">
        <div class="ad-stat-icon" style="background:#DBEAFE;color:#1D4ED8;"><i class="bi bi-people-fill"></i></div>
        <div class="ad-stat-val"><asp:Literal ID="litStudents" runat="server" Text="0" /></div>
        <div class="ad-stat-lbl"><%= T("Total Students", "Jumlah Pelajar") %></div>
    </div>
    <div class="ad-stat c-parents">
        <div class="ad-stat-icon" style="background:#D1FAE5;color:#059669;"><i class="bi bi-person-heart"></i></div>
        <div class="ad-stat-val"><asp:Literal ID="litParents" runat="server" Text="0" /></div>
        <div class="ad-stat-lbl"><%= T("Total Parents", "Jumlah Ibu Bapa") %></div>
    </div>
    <div class="ad-stat c-teachers">
        <div class="ad-stat-icon" style="background:#EDE9FE;color:#7C3AED;"><i class="bi bi-person-badge-fill"></i></div>
        <div class="ad-stat-val"><asp:Literal ID="litTeachers" runat="server" Text="0" /></div>
        <div class="ad-stat-lbl"><%= T("Total Teachers", "Jumlah Guru") %></div>
    </div>
    <div class="ad-stat c-lessons">
        <div class="ad-stat-icon" style="background:#FEF3C7;color:#D97706;"><i class="bi bi-book-fill"></i></div>
        <div class="ad-stat-val"><asp:Literal ID="litLessons" runat="server" Text="0" /></div>
        <div class="ad-stat-lbl"><%= T("Total Lessons", "Jumlah Pelajaran") %></div>
    </div>
    <div class="ad-stat c-quizzes">
        <div class="ad-stat-icon" style="background:#FEE2E2;color:#DC2626;"><i class="bi bi-patch-question-fill"></i></div>
        <div class="ad-stat-val"><asp:Literal ID="litQuizzes" runat="server" Text="0" /></div>
        <div class="ad-stat-lbl"><%= T("Total Quizzes", "Jumlah Kuiz") %></div>
    </div>
    <div class="ad-stat c-requests">
        <div class="ad-stat-icon" style="background:#CFFAFE;color:#0891B2;"><i class="bi bi-inbox-fill"></i></div>
        <div class="ad-stat-val"><asp:Literal ID="litPendingRequests" runat="server" Text="0" /></div>
        <div class="ad-stat-lbl"><%= T("Pending Question Requests", "Permintaan Soalan Tertunggak") %></div>
    </div>
</div>

<%-- -- 3. QUICK ACTIONS -- --%>
<div class="ad-sec-hd">
    <div class="ad-sec-title"><i class="bi bi-lightning-fill" style="color:#2563EB;"></i> <%= T("Quick Actions", "Tindakan Pantas") %></div>
</div>
<div class="ad-quick" style="margin-bottom:var(--space-xl);">
    <a href="#" class="ad-quick-card ad-qc-users">
        <div class="ad-quick-ico" style="background:#DBEAFE;color:#1D4ED8;"><i class="bi bi-people-fill"></i></div>
        <div class="ad-quick-lbl"><%= T("User Management", "Pengurusan Pengguna") %></div>
        <div class="ad-quick-desc"><%= T("Students, parents &amp; teachers", "Pelajar, ibu bapa &amp; guru") %></div>
    </a>
    <a href="#" class="ad-quick-card ad-qc-content">
        <div class="ad-quick-ico" style="background:#FEF3C7;color:#D97706;"><i class="bi bi-collection-fill"></i></div>
        <div class="ad-quick-lbl"><%= T("Learning Content", "Kandungan Pembelajaran") %></div>
        <div class="ad-quick-desc"><%= T("Lessons, quizzes &amp; questions", "Pelajaran, kuiz &amp; soalan") %></div>
    </a>
    <a href="<%: ResolveUrl("~/Admin/QuestionRequests.aspx") %>" class="ad-quick-card ad-qc-requests">
        <div class="ad-quick-ico" style="background:#CFFAFE;color:#0891B2;"><i class="bi bi-clipboard-check-fill"></i></div>
        <div class="ad-quick-lbl"><%= T("Question Requests", "Permintaan Soalan") %></div>
        <div class="ad-quick-desc"><%= T("Review pending question submissions", "Semak penghantaran soalan tertunggak") %></div>
    </a>
    <a href="#" class="ad-quick-card ad-qc-gamify">
        <div class="ad-quick-ico" style="background:#EDE9FE;color:#7C3AED;"><i class="bi bi-trophy-fill"></i></div>
        <div class="ad-quick-lbl"><%= T("Gamification", "Gamifikasi") %></div>
        <div class="ad-quick-desc"><%= T("Badges &amp; XP configuration", "Lencana &amp; konfigurasi XP") %></div>
    </a>
    <a href="#" class="ad-quick-card ad-qc-notif">
        <div class="ad-quick-ico" style="background:#FEE2E2;color:#DC2626;"><i class="bi bi-bell-fill"></i></div>
        <div class="ad-quick-lbl"><%= T("Notifications", "Notifikasi") %></div>
        <div class="ad-quick-desc"><%= T("Send &amp; manage alerts", "Hantar &amp; urus makluman") %></div>
    </a>
</div>

<%-- -- 4 & 5. PENDING REQUESTS + RECENT ACTIVITIES -- --%>
<div class="ad-row2">

    <%-- Pending Question Requests --%>
    <div>
        <div class="ad-sec-hd">
            <div class="ad-sec-title"><i class="bi bi-clipboard-check" style="color:#0891B2;"></i> <%= T("Pending Question Requests", "Permintaan Soalan Tertunggak") %></div>
        </div>
        <div class="ad-card">
            <asp:Panel ID="pnlRequests" runat="server" Visible="false">
                <div class="sb-table-wrapper" style="border:none;border-radius:0;box-shadow:none;">
                    <table class="sb-table">
                        <thead>
                            <tr>
                                <th>Type</th>
                                <th>Requested By</th>
                                <th>Date</th>
                                <th>Status</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptRequests" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td data-label="Type">
                                            <span class="sb-badge sb-badge-secondary">
                                                <%# HtmlEncode(Eval("requestType")) %>
                                            </span>
                                        </td>
                                        <td data-label="Requested By"><%# HtmlEncode(Eval("requestedBy")) %></td>
                                        <td data-label="Date"><%# Eval("requestedDate") %></td>
                                        <td data-label="Status">
                                            <span class="sb-badge sb-badge-warning">Pending</span>
                                        </td>
                                        <td class="col-actions">
                                            <a href="<%: ResolveUrl("~/Admin/QuestionRequests.aspx") %>" class="sb-btn sb-btn-primary sb-btn-xs"><%= T("Review", "Semak") %></a>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>
            </asp:Panel>
            <asp:Panel ID="pnlRequestsEmpty" runat="server">
                <div class="ad-empty">
                    <div class="ad-empty-ico">??</div>
                    <div class="ad-empty-msg"><%= T("No pending question requests.", "Tiada permintaan soalan tertunggak.") %></div>
                </div>
            </asp:Panel>
        </div>
    </div>

    <%-- Recent Notifications --%>
    <div>
        <div class="ad-sec-hd">
            <div class="ad-sec-title"><i class="bi bi-bell" style="color:#DC2626;"></i> <%= T("Recent Notifications", "Notifikasi Terkini") %></div>
        </div>
        <div class="ad-card">
            <asp:Panel ID="pnlNotifs" runat="server" Visible="false">
                <div class="ad-notif-list">
                    <asp:Repeater ID="rptNotifs" runat="server">
                        <ItemTemplate>
                            <div class="ad-notif-item">
                                <div class='ad-notif-dot <%# Convert.ToBoolean(Eval("isRead")) ? "read" : "" %>'></div>
                                <div>
                                    <div class="ad-notif-title"><%# HtmlEncode(Eval("title")) %></div>
                                    <div class="ad-notif-msg"><%# HtmlEncode(Eval("message")) %></div>
                                    <div class="ad-notif-time"><i class="bi bi-clock"></i> <%# Eval("timeAgo") %></div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </asp:Panel>
            <asp:Panel ID="pnlNotifsEmpty" runat="server">
                <div class="ad-empty">
                    <div class="ad-empty-ico">??</div>
                    <div class="ad-empty-msg"><%= T("No new notifications.", "Tiada notifikasi baharu.") %></div>
                </div>
            </asp:Panel>
        </div>
    </div>

</div><%-- /.ad-row2 --%>

<%-- -- 5. RECENT SYSTEM ACTIVITIES -- --%>
<div class="ad-row3">
    <div class="ad-sec-hd">
        <div class="ad-sec-title"><i class="bi bi-clock-history" style="color:#7C3AED;"></i> <%= T("Recent System Activities", "Aktiviti Sistem Terkini") %></div>
    </div>
    <div class="ad-card">
        <asp:Panel ID="pnlLogs" runat="server" Visible="false">
            <div class="ad-card-body" style="padding:var(--space-sm) var(--space-md);">
                <div class="ad-log-list">
                    <asp:Repeater ID="rptLogs" runat="server">
                        <ItemTemplate>
                            <div class="ad-log-item">
                                <div class="ad-log-ico" style='<%# Eval("iconStyle") %>'>
                                    <i class='<%# Eval("iconClass") %>'></i>
                                </div>
                                <div class="ad-log-body">
                                    <div class="ad-log-action"><%# HtmlEncode(Eval("action")) %></div>
                                    <div class="ad-log-desc"><%# HtmlEncode(Eval("description")) %></div>
                                    <div class="ad-log-meta">
                                        <i class="bi bi-person"></i> <%# HtmlEncode(Eval("username")) %>
                                        <i class="bi bi-dot"></i>
                                        <i class="bi bi-clock"></i> <%# Eval("timeAgo") %>
                                        <asp:Literal ID="litLogStatus" runat="server"
                                            Text='<%# BuildStatusBadge(Convert.ToString(Eval("status"))) %>' />
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </asp:Panel>
        <asp:Panel ID="pnlLogsEmpty" runat="server">
            <div class="ad-empty">
                <div class="ad-empty-ico">??</div>
                <div class="ad-empty-msg"><%= T("No recent system activities.", "Tiada aktiviti sistem terkini.") %></div>
            </div>
        </asp:Panel>
    </div>
</div>

</asp:Content>
