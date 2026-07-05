<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs"
    Inherits="ScienceBuddy.Teacher.Dashboard" MasterPageFile="~/Site.Master"
    Title="Teacher Dashboard" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ── Teacher Dashboard – Purple Theme ── */
:root {
    --tc-primary: #6C63FF;
    --tc-secondary: #8B5CF6;
    --tc-hover: #5A52E0;
    --tc-light-bg: #F5F3FF;
    --tc-card-bg: #FFFFFF;
    --tc-border: #E5E7EB;
    --tc-text: #374151;
    --tc-muted: #6B7280;
    --tc-info: #3B82F6;
    --tc-warning: #F59E0B;
    --tc-success: #10B981;
    --tc-error: #EF4444;
}

/* Hero */
.td-hero {
    background: linear-gradient(135deg, #4F46E5 0%, #6C63FF 45%, #8B5CF6 100%);
    border-radius: 18px; padding: 2.25rem 2.75rem; color: #fff;
    display: flex; align-items: center; justify-content: space-between;
    position: relative; overflow: hidden;
    margin-bottom: 2rem; box-shadow: 0 10px 36px rgba(108,99,255,.18);
}
/* Decorative circles */
.td-hero::before {
    content: ''; position: absolute; width: 280px; height: 280px; border-radius: 50%;
    background: rgba(255,255,255,.055); top: -80px; right: 60px; pointer-events: none;
}
.td-hero::after {
    content: ''; position: absolute; width: 160px; height: 160px; border-radius: 50%;
    background: rgba(255,255,255,.045); bottom: -40px; right: 200px; pointer-events: none;
}
.td-hero-body { position: relative; z-index: 1; max-width: 560px; }
.td-hero-eyebrow {
    font-size: .7rem; font-weight: 700; letter-spacing: 2px;
    text-transform: uppercase; opacity: .7; margin-bottom: 10px;
}
.td-hero-title {
    font-family: var(--font-primary); font-size: 1.85rem; font-weight: 800;
    line-height: 1.3; margin-bottom: .4rem;
    word-break: break-word; overflow-wrap: anywhere;
}
.td-hero-sub { font-size: .92rem; opacity: .85; line-height: 1.6; }
/* Right-side decoration: extra shapes via a child element */
.td-hero-decor {
    position: absolute; top: 0; right: 0; bottom: 0; width: 40%;
    pointer-events: none; z-index: 0;
}
.td-hero-decor-circle1 {
    position: absolute; width: 120px; height: 120px; border-radius: 50%;
    border: 2px solid rgba(255,255,255,.12);
    top: 20%; right: 8%;
}
.td-hero-decor-circle2 {
    position: absolute; width: 72px; height: 72px; border-radius: 50%;
    background: rgba(255,255,255,.06);
    bottom: 15%; right: 22%;
}
.td-hero-decor-circle3 {
    position: absolute; width: 44px; height: 44px; border-radius: 50%;
    border: 1.5px solid rgba(255,255,255,.09);
    top: 55%; right: 5%;
}
.td-hero-decor-dots {
    position: absolute; top: 18%; right: 30%; width: 60px; height: 60px;
    background-image: radial-gradient(rgba(255,255,255,.15) 1.5px, transparent 1.5px);
    background-size: 10px 10px;
}

/* Quick Actions */
.td-quick { display: grid; grid-template-columns: repeat(4,1fr); gap: 1rem; margin-bottom: 2rem; }
.td-quick-card {
    background: var(--tc-card-bg); border-radius: 14px;
    border: 1.5px solid var(--tc-border); box-shadow: 0 2px 8px rgba(0,0,0,.04);
    padding: 1.25rem; text-decoration: none;
    transition: transform .2s ease, box-shadow .2s ease, border-color .2s ease;
    display: flex; align-items: flex-start; gap: 14px;
    position: relative; min-height: 100px;
}
.td-quick-card:hover {
    transform: translateY(-3px); box-shadow: 0 10px 28px rgba(108,99,255,.12);
    border-color: var(--tc-primary); text-decoration: none;
}
.td-quick-card:hover .td-quick-arrow { opacity: 1; transform: translateX(2px); }
.td-quick-ico {
    width: 44px; height: 44px; border-radius: 12px; flex-shrink: 0;
    display: flex; align-items: center; justify-content: center; font-size: 1.15rem;
    transition: transform .2s;
}
.td-quick-card:hover .td-quick-ico { transform: scale(1.08); }
.td-quick-content { flex: 1; min-width: 0; }
.td-quick-lbl {
    font-family: var(--font-primary); font-size: .875rem; font-weight: 700;
    color: var(--tc-text); line-height: 1.3; margin-bottom: 3px;
}
.td-quick-desc { font-size: .78rem; color: var(--tc-muted); line-height: 1.4; }
.td-quick-arrow {
    position: absolute; top: 50%; right: 1rem; transform: translateY(-50%);
    font-size: .85rem; color: var(--tc-muted); opacity: .4;
    transition: opacity .2s, transform .2s, color .2s;
}
.td-quick-card:hover .td-quick-arrow { color: var(--tc-primary); }

/* Summary Cards */
.td-stats { display: grid; grid-template-columns: repeat(4,1fr); gap: 1rem; margin-bottom: 2rem; }
.td-stat {
    background: var(--tc-card-bg); border-radius: 16px;
    border: 1.5px solid var(--tc-border); box-shadow: 0 2px 8px rgba(108,99,255,.06);
    padding: 1.5rem; display: flex; flex-direction: column;
    gap: .5rem; transition: transform .2s, box-shadow .2s;
    position: relative; overflow: hidden; cursor: pointer; text-decoration: none;
}
.td-stat::before {
    content: ''; position: absolute; top: 0; left: 0; right: 0;
    height: 4px; border-radius: 16px 16px 0 0;
}
.td-stat:hover { transform: translateY(-3px); box-shadow: 0 8px 24px rgba(108,99,255,.12); text-decoration: none; }
.td-stat.c-lessons::before  { background: linear-gradient(90deg,#6C63FF,#A78BFA); }
.td-stat.c-quizzes::before  { background: linear-gradient(90deg,#F59E0B,#FCD34D); }
.td-stat.c-sessions::before { background: linear-gradient(90deg,#3B82F6,#93C5FD); }
.td-stat.c-students::before { background: linear-gradient(90deg,#10B981,#6EE7B7); }
.td-stat-icon {
    width: 42px; height: 42px; border-radius: 12px;
    display: flex; align-items: center; justify-content: center; font-size: 1.2rem;
}
.td-stat-val {
    font-family: var(--font-primary); font-size: 1.875rem; font-weight: 800;
    line-height: 1; color: var(--tc-text);
}
.td-stat-lbl { font-size: .8125rem; color: var(--tc-muted); font-weight: 600; }

/* Section heading */
.td-sec-hd {
    display: flex; align-items: center; justify-content: space-between;
    margin-bottom: 1rem; gap: 1rem;
}
.td-sec-title {
    font-family: var(--font-primary); font-size: 1.0625rem; font-weight: 800;
    color: var(--tc-text); display: flex; align-items: center; gap: .5rem;
}

/* Two-column + Three-column layouts */
.td-row2 { display: grid; grid-template-columns: 1.2fr .8fr; gap: 1.5rem; margin-bottom: 2rem; }
.td-row3 { display: grid; grid-template-columns: repeat(3,1fr); gap: 1rem; margin-bottom: 2rem; }

/* Card */
.td-card {
    background: var(--tc-card-bg); border-radius: 16px;
    border: 1.5px solid var(--tc-border); box-shadow: 0 2px 8px rgba(108,99,255,.06);
    overflow: hidden;
}
.td-card-body { padding: 1.25rem; }

/* Session list */
.td-session-list { display: flex; flex-direction: column; gap: 4px; }
.td-session-item {
    display: flex; align-items: flex-start; gap: 1rem;
    padding: 12px; border-radius: 12px; transition: background .15s;
}
.td-session-item:hover { background: var(--tc-light-bg); }
.td-session-ico {
    width: 40px; height: 40px; border-radius: 10px;
    background: #EDE9FE; color: var(--tc-primary);
    display: flex; align-items: center; justify-content: center;
    font-size: 1.1rem; flex-shrink: 0;
}
.td-session-body { flex: 1; min-width: 0; }
.td-session-title { font-weight: 700; font-size: .875rem; color: var(--tc-text); }
.td-session-meta {
    font-size: .8rem; color: var(--tc-muted); margin-top: 4px;
    display: flex; align-items: center; gap: 8px; flex-wrap: wrap;
}
.td-session-badge {
    display: inline-flex; align-items: center; padding: 2px 8px;
    border-radius: 50px; font-size: .7rem; font-weight: 700;
}
.td-badge-upcoming { background: #EDE9FE; color: var(--tc-primary); }
.td-badge-active { background: #D1FAE5; color: #059669; }

/* Mini Calendar - Large Clean Design */
.td-live-row{display:grid;grid-template-columns:1fr 300px;gap:1.25rem;margin-bottom:2rem;}
.td-cal-card{background:var(--tc-card-bg);border:1.5px solid var(--tc-border);border-radius:18px;padding:1.5rem;box-shadow:0 2px 8px rgba(0,0,0,.03);}
.td-cal-card-header{margin-bottom:1rem;}
.td-cal-card-title{font-size:.9rem;font-weight:700;color:var(--tc-text);}
.td-cal-card-body{}
.td-cal-month-row{display:flex;align-items:center;justify-content:center;margin-bottom:1rem;}
.td-cal-month-label{font-size:.88rem;font-weight:700;color:var(--tc-text);}
.td-cal-large{display:grid;grid-template-columns:repeat(7,1fr);gap:4px;text-align:center;}
.td-cal-large .cal-header{font-size:.68rem;font-weight:700;color:var(--tc-muted);padding:8px 0;}
.td-cal-large .cal-day{padding:10px 4px;border-radius:10px;font-size:.82rem;color:var(--tc-text);transition:background .15s;}
.td-cal-large .cal-day:hover{background:#F3F4F6;}
.td-cal-large .cal-today{background:var(--tc-info);color:#fff;font-weight:700;}
.td-cal-large .cal-today:hover{background:#2563EB;}
.td-cal-large .cal-session{position:relative;}
.td-cal-large .cal-session::after{content:'';position:absolute;bottom:3px;left:50%;transform:translateX(-50%);width:5px;height:5px;border-radius:50%;background:var(--tc-success);}
/* Upcoming Card */
.td-upcoming-card{background:var(--tc-card-bg);border:1.5px solid var(--tc-border);border-radius:18px;padding:1.25rem;box-shadow:0 2px 8px rgba(0,0,0,.03);display:flex;flex-direction:column;}
.td-upcoming-header{display:flex;align-items:center;justify-content:space-between;margin-bottom:1rem;}
.td-upcoming-title{font-size:.85rem;font-weight:700;color:var(--tc-text);}
.td-upcoming-viewall{font-size:.74rem;font-weight:600;color:var(--tc-primary);text-decoration:none;}
.td-upcoming-viewall:hover{text-decoration:underline;}
.td-upcoming-body{display:flex;align-items:flex-start;gap:14px;padding:1rem;background:#F9FAFB;border-radius:14px;border:1px solid var(--tc-border);}
.td-upcoming-date-badge{display:flex;flex-direction:column;align-items:center;padding:.5rem .75rem;background:var(--tc-card-bg);border-radius:12px;border:1.5px solid var(--tc-border);min-width:52px;}
.td-date-day{font-size:1.4rem;font-weight:800;color:var(--tc-text);line-height:1;}
.td-date-month{font-size:.68rem;font-weight:700;color:var(--tc-muted);text-transform:uppercase;margin-top:2px;}
.td-upcoming-info{flex:1;}
.td-upcoming-session-title{font-size:.88rem;font-weight:700;color:var(--tc-text);margin-bottom:4px;}
.td-upcoming-session-meta{font-size:.74rem;color:var(--tc-muted);display:flex;flex-direction:column;gap:3px;margin-bottom:6px;}
.td-upcoming-session-meta span{display:flex;align-items:center;gap:4px;}
.td-upcoming-empty{display:flex;flex-direction:column;align-items:center;text-align:center;padding:2rem 1rem;flex:1;justify-content:center;}
.td-upcoming-empty i{font-size:2.5rem;color:var(--tc-muted);opacity:.4;margin-bottom:.75rem;}
.td-upcoming-empty-title{font-size:.88rem;font-weight:700;color:var(--tc-text);margin-bottom:.25rem;}
.td-upcoming-empty-sub{font-size:.78rem;color:var(--tc-muted);margin-bottom:.75rem;}
.td-upcoming-empty-btn{display:inline-flex;align-items:center;gap:5px;padding:.45rem 1rem;border-radius:8px;background:var(--tc-success);color:#fff;font-size:.78rem;font-weight:700;text-decoration:none;transition:background .15s;}
.td-upcoming-empty-btn:hover{background:#059669;color:#fff;text-decoration:none;}
@media(max-width:900px){.td-live-row{grid-template-columns:1fr;}}

/* Performance cards */
.td-perf-card {
    background: var(--tc-card-bg); border-radius: 16px;
    border: 1.5px solid var(--tc-border); box-shadow: 0 2px 8px rgba(108,99,255,.06);
    padding: 1.5rem; display: flex; flex-direction: column; align-items: center;
    text-align: center; gap: .5rem;
}
.td-perf-ico {
    width: 48px; height: 48px; border-radius: 12px;
    display: flex; align-items: center; justify-content: center; font-size: 1.3rem;
    margin-bottom: .25rem;
}
.td-perf-val { font-family: var(--font-primary); font-size: 1.75rem; font-weight: 800; color: var(--tc-text); }
.td-perf-lbl { font-size: .8125rem; color: var(--tc-muted); font-weight: 600; }

/* Notification list */
.td-notif-list { display: flex; flex-direction: column; }
.td-notif-item {
    padding: 12px 1rem; border-bottom: 1px solid #F3F0FF;
    display: flex; gap: .75rem; align-items: flex-start;
}
.td-notif-item:last-child { border-bottom: none; }
.td-notif-dot {
    width: 10px; height: 10px; border-radius: 50%; margin-top: 5px; flex-shrink: 0;
    background: var(--tc-primary); box-shadow: 0 0 0 3px #EDE9FE;
}
.td-notif-dot.read { background: var(--tc-muted); box-shadow: none; }
.td-notif-body { flex: 1; min-width: 0; }
.td-notif-title { font-size: .875rem; font-weight: 600; color: var(--tc-text); line-height: 1.4; }
.td-notif-msg { font-size: .8rem; color: var(--tc-muted); margin-top: 2px; line-height: 1.4; }
.td-notif-time { font-size: .75rem; color: var(--tc-muted); margin-top: 3px; display: flex; align-items: center; gap: 4px; }

/* Empty state */
.td-empty {
    display: flex; flex-direction: column; align-items: center;
    justify-content: center; text-align: center;
    padding: 2.5rem 1.5rem; color: var(--tc-muted);
}
.td-empty-ico { font-size: 2.5rem; margin-bottom: .75rem; opacity: .55; }
.td-empty-msg { font-size: .9375rem; font-weight: 600; color: var(--tc-muted); }

/* Status panels */
.td-status-panel {
    display: flex; flex-direction: column; align-items: center;
    justify-content: center; text-align: center;
    padding: 3rem 2rem; min-height: 300px;
}
.td-status-ico { font-size: 4rem; margin-bottom: 1.5rem; }
.td-status-title {
    font-family: var(--font-primary); font-size: 1.5rem; font-weight: 800;
    color: var(--tc-text); margin-bottom: .5rem;
}
.td-status-msg { font-size: 1rem; color: var(--tc-muted); max-width: 500px; line-height: 1.6; }

/* Responsive */
@media(max-width:1279px) { .td-stats { grid-template-columns: repeat(2,1fr); } .td-quick { grid-template-columns: repeat(2,1fr); } .td-row3 { grid-template-columns: repeat(3,1fr); } }
@media(max-width:1023px) { .td-stats { grid-template-columns: repeat(2,1fr); } .td-quick { grid-template-columns: repeat(2,1fr); } .td-row2 { grid-template-columns: 1fr; } .td-row3 { grid-template-columns: 1fr 1fr 1fr; } }
@media(max-width:767px) {
    .td-hero { padding: 1.75rem 1.5rem; }
    .td-hero-title { font-size: 1.4rem; }
    .td-hero-decor { display: none; }
    .td-stats { grid-template-columns: 1fr 1fr; }
    .td-quick { grid-template-columns: 1fr; }
    .td-row3 { grid-template-columns: 1fr; }
}
@media(max-width:479px) { .td-stats { grid-template-columns: 1fr; } }
</style>
</asp:Content>

<%-- ════ SIDEBAR MENU ════ --%>
<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Teaching","Pengajaran") %></div>
        <a href="<%: ResolveUrl("~/Teacher/manageMaterials.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label"><%: T("Manage Materials","Bahan Pembelajaran") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label"><%: T("Manage Quiz","Kuiz") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/studentProgress.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bar-chart item-icon"></i><span class="item-label"><%: T("Student Progress","Prestasi Pelajar") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/liveSession.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label"><%: T("Schedule Live Class","Kelas Langsung") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Community","Komuniti") %></div>
        <a href="<%: ResolveUrl("~/Teacher/forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/privateMessages.aspx") %>" class="sb-sidebar-item"><i class="bi bi-envelope item-icon"></i><span class="item-label"><%: T("Private Message","Mesej Peribadi") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Account","Akaun") %></div>
        <a href="<%: ResolveUrl("~/Teacher/MyProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("My Profile","Profil Saya") %></span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Sign Out","Log Keluar") %></span></a></div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Teacher Dashboard","Papan Pemuka Guru") %></asp:Content>

<%-- ════ MAIN CONTENT ════ --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- Status panels for non-certified teachers --%>
<asp:Panel ID="pnlPending" runat="server" Visible="false">
    <div class="td-status-panel">
        <div class="td-status-ico">⏳</div>
        <div class="td-status-title">Verification Pending</div>
        <div class="td-status-msg">
            Your teaching certificate is currently under review. You will receive full access to the Teacher Dashboard once your certification has been approved by our admin team. Thank you for your patience!
        </div>
    </div>
</asp:Panel>

<asp:Panel ID="pnlRejected" runat="server" Visible="false">
    <div class="td-status-panel">
        <div class="td-status-ico">📋</div>
        <div class="td-status-title">Certificate Not Approved</div>
        <div class="td-status-msg">
            Unfortunately, your teaching certificate was not approved. Please contact our support team or resubmit your certification documents for review. We are here to help!
        </div>
    </div>
</asp:Panel>

<asp:Panel ID="pnlDenied" runat="server" Visible="false">
    <div class="td-status-panel">
        <div class="td-status-ico">🚫</div>
        <div class="td-status-title">Access Denied</div>
        <div class="td-status-msg">
            Your account does not currently have access to the Teacher Dashboard. If you believe this is an error, please contact the ScienceBuddy support team.
        </div>
    </div>
</asp:Panel>

<%-- Main Dashboard (visible only to Certified teachers) --%>
<asp:Panel ID="pnlDashboard" runat="server" Visible="false">

<%-- ── 1. HERO BANNER ── --%>
<div class="td-hero">
    <div class="td-hero-body">
        <div class="td-hero-eyebrow">Teacher Portal</div>
        <div class="td-hero-title">Welcome back, <asp:Literal ID="litTeacherName" runat="server" Text="Teacher" />!</div>
        <div class="td-hero-sub">Manage your lessons, quizzes, and live sessions from one place.</div>
    </div>
    <div class="td-hero-decor">
        <div class="td-hero-decor-circle1"></div>
        <div class="td-hero-decor-circle2"></div>
        <div class="td-hero-decor-circle3"></div>
        <div class="td-hero-decor-dots"></div>
    </div>
</div>

<%-- ── 2. QUICK ACTIONS ── --%>
<div class="td-sec-hd">
    <div class="td-sec-title"><i class="bi bi-lightning-fill" style="color:var(--tc-primary);"></i> Quick Actions</div>
</div>
<div class="td-quick">
    <a href="<%: ResolveUrl("~/Teacher/uploadMaterial.aspx") %>" class="td-quick-card">
        <div class="td-quick-ico" style="background:#EDE9FE;color:#6C63FF;"><i class="bi bi-file-earmark-plus"></i></div>
        <div class="td-quick-content">
            <div class="td-quick-lbl"><%: T("Upload Material","Muat Naik Bahan") %></div>
            <div class="td-quick-desc"><%: T("Add a new science lesson","Tambah bahan pembelajaran baharu") %></div>
        </div>
        <span class="td-quick-arrow"><i class="bi bi-chevron-right"></i></span>
    </a>
    <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="td-quick-card">
        <div class="td-quick-ico" style="background:#FEF3C7;color:#D97706;"><i class="bi bi-patch-question"></i></div>
        <div class="td-quick-content">
            <div class="td-quick-lbl"><%: T("Manage Quiz","Kuiz") %></div>
            <div class="td-quick-desc"><%: T("Build a new practice quiz","Cipta kuiz baharu") %></div>
        </div>
        <span class="td-quick-arrow"><i class="bi bi-chevron-right"></i></span>
    </a>
    <a href="<%: ResolveUrl("~/Teacher/liveSession.aspx") %>" class="td-quick-card">
        <div class="td-quick-ico" style="background:#DBEAFE;color:#2563EB;"><i class="bi bi-calendar-plus"></i></div>
        <div class="td-quick-content">
            <div class="td-quick-lbl"><%: T("Schedule Live Class","Kelas Langsung") %></div>
            <div class="td-quick-desc"><%: T("Plan an online learning session","Rancang sesi kelas langsung") %></div>
        </div>
        <span class="td-quick-arrow"><i class="bi bi-chevron-right"></i></span>
    </a>
    <a href="<%: ResolveUrl("~/Teacher/StudentProgress.aspx") %>" class="td-quick-card">
        <div class="td-quick-ico" style="background:#D1FAE5;color:#059669;"><i class="bi bi-graph-up-arrow"></i></div>
        <div class="td-quick-content">
            <div class="td-quick-lbl"><%: T("Student Progress","Prestasi Pelajar") %></div>
            <div class="td-quick-desc"><%: T("Review student learning data","Semak prestasi pelajar") %></div>
        </div>
        <span class="td-quick-arrow"><i class="bi bi-chevron-right"></i></span>
    </a>
</div>

<%-- ── 3. SUMMARY CARDS ── --%>
<div class="td-sec-hd">
    <div class="td-sec-title"><i class="bi bi-bar-chart-fill" style="color:var(--tc-primary);"></i> Overview</div>
</div>
<div class="td-stats">
    <a href="#" class="td-stat c-lessons">
        <div class="td-stat-icon" style="background:#EDE9FE;color:#6C63FF;"><i class="bi bi-file-earmark-text-fill"></i></div>
        <div class="td-stat-val"><asp:Literal ID="litTotalLessons" runat="server" Text="0" /></div>
        <div class="td-stat-lbl">Total Lessons</div>
    </a>
    <a href="#" class="td-stat c-quizzes">
        <div class="td-stat-icon" style="background:#FEF3C7;color:#D97706;"><i class="bi bi-patch-question-fill"></i></div>
        <div class="td-stat-val"><asp:Literal ID="litTotalQuizzes" runat="server" Text="0" /></div>
        <div class="td-stat-lbl">Total Quizzes</div>
    </a>
    <a href="#" class="td-stat c-sessions">
        <div class="td-stat-icon" style="background:#DBEAFE;color:#2563EB;"><i class="bi bi-camera-video-fill"></i></div>
        <div class="td-stat-val"><asp:Literal ID="litUpcomingSessions" runat="server" Text="0" /></div>
        <div class="td-stat-lbl">Upcoming Live Sessions</div>
    </a>
    <a href="#" class="td-stat c-students">
        <div class="td-stat-icon" style="background:#D1FAE5;color:#059669;"><i class="bi bi-people-fill"></i></div>
        <div class="td-stat-val"><asp:Literal ID="litTotalStudents" runat="server" Text="0" /></div>
        <div class="td-stat-lbl">Total Students</div>
    </a>
</div>

<%-- ── 4. UPCOMING LIVE SESSIONS ── --%>
<div class="td-live-row">
    <%-- LEFT: Calendar Card --%>
    <div class="td-cal-card">
        <div class="td-cal-card-header">
            <div class="td-cal-card-title"><%: T("Upcoming Live Sessions","Kelas Langsung Akan Datang") %></div>
        </div>
        <div class="td-cal-card-body">
            <div class="td-cal-month-row">
                <span class="td-cal-month-label"><asp:Literal ID="litCalMonth" runat="server" /></span>
            </div>
            <div class="td-cal-large"><asp:Literal ID="litCalDays" runat="server" /></div>
        </div>
    </div>

    <%-- RIGHT: Upcoming Card --%>
    <div class="td-upcoming-card">
        <div class="td-upcoming-header">
            <span class="td-upcoming-title"><%: T("Upcoming","Akan Datang") %></span>
            <a href="<%: ResolveUrl("~/Teacher/liveSession.aspx") %>" class="td-upcoming-viewall"><%: T("View All","Lihat Semua") %> →</a>
        </div>
        <asp:Panel ID="pnlSessions" runat="server" Visible="false">
            <div class="td-upcoming-body">
                <div class="td-upcoming-date-badge">
                    <span class="td-date-day"><asp:Literal ID="litNextDay" runat="server" /></span>
                    <span class="td-date-month"><asp:Literal ID="litNextMonth" runat="server" /></span>
                </div>
                <div class="td-upcoming-info">
                    <div class="td-upcoming-session-title"><asp:Literal ID="litNextTitle" runat="server" /></div>
                    <div class="td-upcoming-session-meta">
                        <span><i class="bi bi-clock"></i> <asp:Literal ID="litNextTime" runat="server" /></span>
                        <span><i class="bi bi-bookmark"></i> <asp:Literal ID="litNextTopic" runat="server" /></span>
                    </div>
                    <span class="td-session-badge td-badge-upcoming"><%: T("Upcoming","Akan Datang") %></span>
                </div>
            </div>
        </asp:Panel>
        <asp:Panel ID="pnlSessionsEmpty" runat="server">
            <div class="td-upcoming-empty">
                <i class="bi bi-calendar2-x"></i>
                <div class="td-upcoming-empty-title"><%: T("No Upcoming Live Session","Tiada Kelas Langsung Akan Datang") %></div>
                <div class="td-upcoming-empty-sub"><%: T("You don't have any scheduled live sessions.","Anda tidak mempunyai kelas langsung yang dijadualkan.") %></div>
                <a href="<%: ResolveUrl("~/Teacher/liveSession.aspx") %>" class="td-upcoming-empty-btn"><i class="bi bi-plus-lg"></i> <%: T("Schedule Live Class","Jadualkan Kelas Langsung") %></a>
            </div>
        </asp:Panel>
    </div>
</div>

<%-- ── NOTIFICATIONS ── --%>
<div class="td-row2">
<div></div>
<div>
    <div class="td-sec-hd">
        <div class="td-sec-title"><i class="bi bi-bell-fill" style="color:var(--tc-warning);"></i> <%: T("Notifications","Pemberitahuan") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Notifications.aspx") %>" style="font-size:.78rem;font-weight:600;color:var(--tc-primary);text-decoration:none;"><%: T("View All","Lihat Semua") %> →</a>
    </div>
    <div class="td-card">
        <asp:Panel ID="pnlNotifs" runat="server" Visible="false">
            <div class="td-notif-list">
                <asp:Repeater ID="rptNotifs" runat="server">
                    <ItemTemplate>
                        <div class="td-notif-item">
                            <div class='td-notif-dot <%# Convert.ToBoolean(Eval("isRead")) ? "read" : "" %>'></div>
                            <div class="td-notif-body">
                                <div class="td-notif-title"><%# HttpUtility.HtmlEncode(Eval("title")) %></div>
                                <div class="td-notif-msg"><%# HttpUtility.HtmlEncode(Eval("message")) %></div>
                                <div class="td-notif-time"><i class="bi bi-clock"></i> <%# Eval("timeAgo") %></div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </asp:Panel>
        <asp:Panel ID="pnlNotifsEmpty" runat="server">
            <div class="td-empty">
                <div class="td-empty-ico">🔔</div>
                <div class="td-empty-msg"><%: T("No new notifications.","Tiada pemberitahuan baharu.") %></div>
            </div>
        </asp:Panel>
    </div>
</div>
</div><%-- /.td-row2 --%>

<%-- ── 5. STUDENT PERFORMANCE ── --%>
<div class="td-sec-hd">
    <div class="td-sec-title"><i class="bi bi-graph-up" style="color:var(--tc-success);"></i> Student Performance</div>
</div>
<div class="td-row3">
    <div class="td-perf-card">
        <div class="td-perf-ico" style="background:#EDE9FE;color:#6C63FF;"><i class="bi bi-trophy-fill"></i></div>
        <div class="td-perf-val"><asp:Literal ID="litAvgQuizScore" runat="server" Text="—" /></div>
        <div class="td-perf-lbl">Average Quiz Score</div>
    </div>
    <div class="td-perf-card">
        <div class="td-perf-ico" style="background:#D1FAE5;color:#059669;"><i class="bi bi-check-circle-fill"></i></div>
        <div class="td-perf-val"><asp:Literal ID="litLessonCompletionRate" runat="server" Text="—" /></div>
        <div class="td-perf-lbl">Lesson Completion Rate</div>
    </div>
    <div class="td-perf-card">
        <div class="td-perf-ico" style="background:#DBEAFE;color:#2563EB;"><i class="bi bi-person-check-fill"></i></div>
        <div class="td-perf-val"><asp:Literal ID="litCompletedToday" runat="server" Text="0" /></div>
        <div class="td-perf-lbl">Students Completed Today</div>
    </div>
</div>

</asp:Panel>

</asp:Content>
