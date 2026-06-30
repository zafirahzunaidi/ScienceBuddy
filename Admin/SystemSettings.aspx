<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SystemSettings.aspx.cs"
    Inherits="ScienceBuddy.Admin.SystemSettings" MasterPageFile="~/Site.Master"
    Title="System Settings" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" />
<style>
:root {
    --ss-quiz:#2563EB; --ss-quiz-light:#EFF6FF; --ss-quiz-border:#BFDBFE;
    --ss-sec:#DC2626; --ss-sec-light:#FEF2F2; --ss-sec-border:#FECACA;
    --ss-gam:#7C3AED; --ss-gam-light:#F5F3FF; --ss-gam-border:#DDD6FE;
    --ss-live:#059669; --ss-live-light:#ECFDF5; --ss-live-border:#A7F3D0;
}

/* ─── PAGE HEADER ─── */
.ss-page-hdr{display:flex;align-items:center;justify-content:space-between;padding:var(--space-lg) 0 var(--space-md);border-bottom:1.5px solid var(--border-color);margin-bottom:var(--space-xl);flex-wrap:wrap;gap:var(--space-md);}
.ss-page-left{}
.ss-page-title{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;color:var(--color-text);display:flex;align-items:center;gap:10px;}
.ss-page-sub{font-size:.875rem;color:var(--color-text-secondary);margin-top:4px;}
.ss-page-right{display:flex;align-items:center;gap:var(--space-md);flex-wrap:wrap;}
.ss-last-sync{font-size:.75rem;color:var(--color-text-muted);display:flex;align-items:center;gap:4px;background:var(--color-surface-alt);padding:6px 12px;border-radius:var(--border-radius-full);}
.ss-btn-refresh{padding:8px 16px;border-radius:var(--border-radius);border:1.5px solid var(--border-color);background:var(--color-white);color:var(--color-text);font-weight:600;font-size:.8125rem;cursor:pointer;display:inline-flex;align-items:center;gap:6px;transition:all .2s;}
.ss-btn-refresh:hover{background:var(--color-surface-alt);border-color:#94A3B8;transform:translateY(-1px);}

/* ─── SEARCH + FILTER ─── */
.ss-toolbar{position:sticky;top:0;z-index:10;background:var(--color-surface);padding:var(--space-md) 0;margin-bottom:var(--space-lg);}
.ss-search-wrap{position:relative;margin-bottom:var(--space-md);}
.ss-search-wrap i{position:absolute;left:16px;top:50%;transform:translateY(-50%);color:var(--color-text-muted);font-size:1rem;}
.ss-search{width:100%;padding:12px 16px 12px 44px;border:1.5px solid var(--border-color);border-radius:var(--border-radius-lg);font-size:.9375rem;background:var(--color-white);transition:border-color .2s,box-shadow .2s;}
.ss-search:focus{outline:none;border-color:#6366F1;box-shadow:0 0 0 3px rgba(99,102,241,.1);}
.ss-chips{display:flex;gap:8px;flex-wrap:wrap;}
.ss-chip{padding:6px 16px;border-radius:var(--border-radius-full);font-size:.8125rem;font-weight:600;cursor:pointer;border:1.5px solid var(--border-color);background:var(--color-white);color:var(--color-text-secondary);transition:all .2s;user-select:none;}
.ss-chip:hover{border-color:#6366F1;color:#6366F1;}
.ss-chip.active{background:#6366F1;color:#fff;border-color:#6366F1;box-shadow:0 2px 8px rgba(99,102,241,.25);}

/* ─── SUMMARY CARDS ─── */
.ss-summary{display:grid;grid-template-columns:repeat(4,1fr);gap:var(--space-md);margin-bottom:var(--space-xl);}
.ss-sum{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);padding:var(--space-lg);display:flex;align-items:center;gap:var(--space-md);transition:transform .2s,box-shadow .2s;}
.ss-sum:hover{transform:translateY(-3px);box-shadow:var(--shadow-md);}
.ss-sum-ico{width:48px;height:48px;border-radius:var(--border-radius-lg);display:flex;align-items:center;justify-content:center;font-size:1.2rem;flex-shrink:0;}
.ss-sum-val{font-family:var(--font-primary);font-size:1.5rem;font-weight:800;color:var(--color-text);line-height:1.15;}
.ss-sum-lbl{font-size:.8rem;color:var(--color-text-secondary);font-weight:600;}
.ss-sum-detail{font-size:.7rem;color:var(--color-text-muted);margin-top:2px;}

/* ─── COLLAPSIBLE SECTIONS ─── */
.ss-section{margin-bottom:var(--space-xl);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);overflow:hidden;transition:box-shadow .3s;}
.ss-section:hover{box-shadow:var(--shadow-md);}
.ss-sec-hdr{padding:var(--space-lg) var(--space-xl);display:flex;align-items:center;gap:var(--space-md);cursor:pointer;user-select:none;transition:opacity .2s;}
.ss-sec-hdr:hover{opacity:.9;}
.ss-sec-hdr.cat-quiz{background:linear-gradient(135deg,#1D4ED8 0%,#3B82F6 100%);color:#fff;}
.ss-sec-hdr.cat-sec{background:linear-gradient(135deg,#B91C1C 0%,#EF4444 100%);color:#fff;}
.ss-sec-hdr.cat-gam{background:linear-gradient(135deg,#5B21B6 0%,#8B5CF6 100%);color:#fff;}
.ss-sec-hdr.cat-live{background:linear-gradient(135deg,#047857 0%,#10B981 100%);color:#fff;}
.ss-sec-ico{width:44px;height:44px;border-radius:var(--border-radius);background:rgba(255,255,255,.18);display:flex;align-items:center;justify-content:center;font-size:1.25rem;}
.ss-sec-title{font-family:var(--font-primary);font-size:1.125rem;font-weight:700;flex:1;}
.ss-sec-count{font-size:.8rem;opacity:.8;background:rgba(255,255,255,.2);padding:3px 10px;border-radius:var(--border-radius-full);font-weight:600;}
.ss-sec-arrow{font-size:1.1rem;transition:transform .3s ease;}
.ss-sec-arrow.collapsed{transform:rotate(-90deg);}
.ss-sec-body{background:var(--color-white);padding:var(--space-xl);display:grid;grid-template-columns:repeat(2,1fr);gap:var(--space-lg);transition:max-height .4s ease,opacity .3s ease,padding .3s ease;}
.ss-sec-body.collapsed{max-height:0!important;padding-top:0;padding-bottom:0;opacity:0;overflow:hidden;}

/* ─── INDIVIDUAL SETTING CARD ─── */
.ss-card{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);padding:var(--space-lg);position:relative;transition:transform .25s,box-shadow .25s,border-color .25s;}
.ss-card:hover{transform:translateY(-3px);box-shadow:0 8px 25px rgba(0,0,0,.08);}
.ss-card.cat-quiz{border-left:4px solid var(--ss-quiz);}
.ss-card.cat-sec{border-left:4px solid var(--ss-sec);}
.ss-card.cat-gam{border-left:4px solid var(--ss-gam);}
.ss-card.cat-live{border-left:4px solid var(--ss-live);}
.ss-card.changed{border-color:#F59E0B;box-shadow:0 0 0 2px rgba(245,158,11,.15);}
.ss-card.changed::after{content:'Unsaved';position:absolute;top:12px;right:12px;font-size:.65rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;background:#FEF3C7;color:#92400E;padding:2px 8px;border-radius:var(--border-radius-full);}
.ss-card-top{display:flex;align-items:flex-start;gap:var(--space-sm);margin-bottom:8px;}
.ss-card-icon{width:38px;height:38px;border-radius:var(--border-radius);display:flex;align-items:center;justify-content:center;font-size:1.05rem;flex-shrink:0;}
.ss-card-info{flex:1;}
.ss-card-name{font-family:var(--font-primary);font-size:.9375rem;font-weight:700;color:var(--color-text);line-height:1.3;}
.ss-card-desc{font-size:.78rem;color:var(--color-text-muted);line-height:1.4;margin-top:3px;}
.ss-card-value{display:flex;align-items:center;gap:var(--space-sm);margin:var(--space-md) 0;}
.ss-card-value input[type=number]{width:80px;padding:9px 12px;border:1.5px solid var(--border-color);border-radius:var(--border-radius);font-size:1rem;font-weight:700;text-align:center;transition:border-color .2s,box-shadow .2s;}
.ss-card-value input:focus{outline:none;border-color:#6366F1;box-shadow:0 0 0 3px rgba(99,102,241,.12);}
.ss-card-unit{font-size:.8125rem;font-weight:600;color:var(--color-text-muted);}
.ss-card-bottom{display:flex;align-items:center;justify-content:space-between;padding-top:var(--space-sm);border-top:1px solid #F1F5F9;margin-top:var(--space-sm);}
.ss-card-ts{font-size:.72rem;color:var(--color-text-muted);display:flex;align-items:center;gap:4px;}
.ss-card-btns{display:flex;gap:6px;}
.ss-cbtn{padding:5px 12px;border-radius:var(--border-radius);font-size:.75rem;font-weight:700;cursor:pointer;border:1.5px solid var(--border-color);transition:all .2s;display:inline-flex;align-items:center;gap:4px;text-decoration:none;}
.ss-cbtn-reset{background:var(--color-white);color:var(--color-text-secondary);}
.ss-cbtn-reset:hover{background:#F8FAFC;border-color:#94A3B8;}
.ss-cbtn-save{border:none;color:#fff;box-shadow:0 2px 8px rgba(0,0,0,.15);}
.ss-cbtn-save.cat-quiz{background:linear-gradient(135deg,#2563EB,#3B82F6);}
.ss-cbtn-save.cat-sec{background:linear-gradient(135deg,#DC2626,#EF4444);}
.ss-cbtn-save.cat-gam{background:linear-gradient(135deg,#7C3AED,#8B5CF6);}
.ss-cbtn-save.cat-live{background:linear-gradient(135deg,#059669,#10B981);}
.ss-cbtn-save:hover{transform:translateY(-1px);box-shadow:0 4px 14px rgba(0,0,0,.2);}
.ss-cbtn-save.saving{opacity:.7;pointer-events:none;}

/* ─── EMPTY SEARCH ─── */
.ss-empty{display:none;flex-direction:column;align-items:center;justify-content:center;text-align:center;padding:var(--space-2xl);color:var(--color-text-muted);}
.ss-empty.visible{display:flex;}
.ss-empty-ico{font-size:3rem;opacity:.4;margin-bottom:var(--space-md);}
.ss-empty-msg{font-size:1rem;font-weight:600;color:var(--color-text-secondary);}
.ss-empty-sub{font-size:.85rem;margin-top:4px;}

/* ─── RESPONSIVE ─── */
@media(max-width:1279px){.ss-summary{grid-template-columns:repeat(2,1fr);}.ss-sec-body{grid-template-columns:repeat(2,1fr);}}
@media(max-width:767px){.ss-summary{grid-template-columns:1fr 1fr;}.ss-sec-body{grid-template-columns:1fr;}.ss-page-hdr{flex-direction:column;align-items:flex-start;}}
@media(max-width:479px){.ss-summary{grid-template-columns:1fr;}}
</style>
<script src="<%: ResolveUrl("~/Scripts/admin-signout.js") %>"></script>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Main</div>
        <a href="<%: ResolveUrl("~/Admin/Dashboard.aspx") %>" class="sb-sidebar-item">
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
        <a href="<%: ResolveUrl("~/Admin/SystemSettings.aspx") %>" class="sb-sidebar-item active">
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

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">System Settings</asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<!-- PAGE HEADER -->
<div class="ss-page-hdr">
    <div class="ss-page-left">
        <div class="ss-page-title"><i class="bi bi-gear-wide-connected" style="color:#6366F1;"></i> <%= T("System Settings", "Tetapan Sistem") %></div>
        <div class="ss-page-sub"><%= T("Manage all configurable values used throughout ScienceBuddy.", "Urus semua nilai konfigurasi yang digunakan di seluruh ScienceBuddy.") %></div>
    </div>
    <div class="ss-page-right">
        <div class="ss-last-sync"><i class="bi bi-check-circle-fill" style="color:#16A34A;"></i> <%= T("Last synchronized", "Penyegerakan terakhir") %> <strong><asp:Literal ID="litLastSync" runat="server" /></strong></div>
        <button type="button" class="ss-btn-refresh" onclick="location.reload();"><i class="bi bi-arrow-clockwise"></i> <%= T("Refresh", "Muat Semula") %></button>
    </div>
</div>

<!-- SUMMARY CARDS -->
<div class="ss-summary">
    <div class="ss-sum">
        <div class="ss-sum-ico" style="background:#EEF2FF;color:#6366F1;"><i class="bi bi-gear-fill"></i></div>
        <div><div class="ss-sum-val"><asp:Literal ID="litTotalSettings" runat="server" Text="14" /></div><div class="ss-sum-lbl"><%= T("Total Settings", "Jumlah Tetapan") %></div></div>
    </div>
    <div class="ss-sum">
        <div class="ss-sum-ico" style="background:#D1FAE5;color:#059669;"><i class="bi bi-pencil-square"></i></div>
        <div><div class="ss-sum-val"><asp:Literal ID="litUpdatedToday" runat="server" Text="0" /></div><div class="ss-sum-lbl"><%= T("Modified Today", "Diubah Hari Ini") %></div></div>
    </div>
    <div class="ss-sum">
        <div class="ss-sum-ico" style="background:#FEF3C7;color:#D97706;"><i class="bi bi-clock-history"></i></div>
        <div><div class="ss-sum-val" style="font-size:1rem;"><asp:Literal ID="litRecentName" runat="server" Text="-" /></div><div class="ss-sum-lbl"><%= T("Recently Updated", "Terkini Dikemas Kini") %></div><div class="ss-sum-detail"><asp:Literal ID="litRecentTime" runat="server" /></div></div>
    </div>
    <div class="ss-sum">
        <div class="ss-sum-ico" style="background:#DCFCE7;color:#16A34A;"><i class="bi bi-activity"></i></div>
        <div><div class="ss-sum-val" style="color:#16A34A;"><%= T("Online", "Dalam Talian") %></div><div class="ss-sum-lbl"><%= T("System Status", "Status Sistem") %></div><div class="ss-sum-detail"><%= T("Healthy", "Sihat") %></div></div>
    </div>
</div>

<!-- SEARCH + FILTER TOOLBAR -->
<div class="ss-toolbar">
    <div class="ss-search-wrap">
        <i class="bi bi-search"></i>
        <input type="text" id="ssSearch" class="ss-search" placeholder="<%= T("Search settings...", "Cari tetapan...") %>" oninput="filterSettings()" />
    </div>
    <div class="ss-chips">
        <span class="ss-chip active" data-cat="all" onclick="filterCat(this)"><%= T("All", "Semua") %></span>
        <span class="ss-chip" data-cat="quiz" onclick="filterCat(this)"><i class="bi bi-book-half"></i> <%= T("Quiz", "Kuiz") %></span>
        <span class="ss-chip" data-cat="sec" onclick="filterCat(this)"><i class="bi bi-shield-lock"></i> <%= T("Security", "Keselamatan") %></span>
        <span class="ss-chip" data-cat="gam" onclick="filterCat(this)"><i class="bi bi-trophy"></i> <%= T("Gamification", "Gamifikasi") %></span>
        <span class="ss-chip" data-cat="live" onclick="filterCat(this)"><i class="bi bi-camera-video"></i> <%= T("Live Session", "Sesi Langsung") %></span>
    </div>
</div>

<!-- EMPTY SEARCH STATE -->
<div class="ss-empty" id="ssEmpty">
    <div class="ss-empty-ico"><i class="bi bi-search"></i></div>
    <div class="ss-empty-msg"><%= T("No settings found.", "Tiada tetapan dijumpai.") %></div>
    <div class="ss-empty-sub"><%= T("Try another keyword.", "Cuba kata kunci lain.") %></div>
</div>

<!-- ═══════ QUIZ SETTINGS SECTION ═══════ -->
<div class="ss-section" data-section="quiz">
    <div class="ss-sec-hdr cat-quiz" onclick="toggleSec(this)">
        <div class="ss-sec-ico"><i class="bi bi-book-half"></i></div>
        <div class="ss-sec-title"><%= T("Quiz Settings", "Tetapan Kuiz") %></div>
        <span class="ss-sec-count"><%= T("8 settings", "8 tetapan") %></span>
        <i class="bi bi-chevron-down ss-sec-arrow"></i>
    </div>
    <div class="ss-sec-body">
        <!-- CONFIG001 -->
        <div class="ss-card cat-quiz" data-id="CONFIG001" data-search="easy question timer seconds pemasa soalan mudah saat">
            <div class="ss-card-top"><div class="ss-card-icon" style="background:var(--ss-quiz-light);color:var(--ss-quiz);"><i class="bi bi-stopwatch"></i></div><div class="ss-card-info"><div class="ss-card-name"><%= T("Easy Question Timer", "Pemasa Soalan Mudah") %></div><div class="ss-card-desc"><%= T("How long students have to answer easy questions.", "Berapa lama pelajar menjawab soalan mudah.") %></div></div></div>
            <div class="ss-card-value"><input type="number" id="val_CONFIG001" value="<%= GetVal("CONFIG001") %>" data-orig="<%= GetVal("CONFIG001") %>" oninput="detectChange(this)" min="1" /><span class="ss-card-unit"><%= T("Seconds", "Saat") %></span></div>
            <div class="ss-card-bottom"><span class="ss-card-ts"><i class="bi bi-clock"></i> <%= GetUpdated("CONFIG001") %></span><div class="ss-card-btns"><a class="ss-cbtn ss-cbtn-reset" onclick="resetCard(this)" href="javascript:;"><i class="bi bi-arrow-counterclockwise"></i> Reset</a><a class="ss-cbtn ss-cbtn-save cat-quiz" onclick="saveCard('CONFIG001')" href="javascript:;"><i class="bi bi-floppy"></i> <%= T("Save", "Simpan") %></a></div></div>
        </div>
        <!-- CONFIG002 -->
        <div class="ss-card cat-quiz" data-id="CONFIG002" data-search="medium question timer seconds pemasa soalan sederhana saat">
            <div class="ss-card-top"><div class="ss-card-icon" style="background:var(--ss-quiz-light);color:var(--ss-quiz);"><i class="bi bi-stopwatch"></i></div><div class="ss-card-info"><div class="ss-card-name"><%= T("Medium Question Timer", "Pemasa Soalan Sederhana") %></div><div class="ss-card-desc"><%= T("How long students have to answer medium questions.", "Berapa lama pelajar menjawab soalan sederhana.") %></div></div></div>
            <div class="ss-card-value"><input type="number" id="val_CONFIG002" value="<%= GetVal("CONFIG002") %>" data-orig="<%= GetVal("CONFIG002") %>" oninput="detectChange(this)" min="1" /><span class="ss-card-unit"><%= T("Seconds", "Saat") %></span></div>
            <div class="ss-card-bottom"><span class="ss-card-ts"><i class="bi bi-clock"></i> <%= GetUpdated("CONFIG002") %></span><div class="ss-card-btns"><a class="ss-cbtn ss-cbtn-reset" onclick="resetCard(this)" href="javascript:;"><i class="bi bi-arrow-counterclockwise"></i> Reset</a><a class="ss-cbtn ss-cbtn-save cat-quiz" onclick="saveCard('CONFIG002')" href="javascript:;"><i class="bi bi-floppy"></i> <%= T("Save", "Simpan") %></a></div></div>
        </div>
        <!-- CONFIG003 -->
        <div class="ss-card cat-quiz" data-id="CONFIG003" data-search="hard question timer seconds pemasa soalan sukar saat">
            <div class="ss-card-top"><div class="ss-card-icon" style="background:var(--ss-quiz-light);color:var(--ss-quiz);"><i class="bi bi-stopwatch-fill"></i></div><div class="ss-card-info"><div class="ss-card-name"><%= T("Hard Question Timer", "Pemasa Soalan Sukar") %></div><div class="ss-card-desc"><%= T("How long students have to answer hard questions.", "Berapa lama pelajar menjawab soalan sukar.") %></div></div></div>
            <div class="ss-card-value"><input type="number" id="val_CONFIG003" value="<%= GetVal("CONFIG003") %>" data-orig="<%= GetVal("CONFIG003") %>" oninput="detectChange(this)" min="1" /><span class="ss-card-unit"><%= T("Seconds", "Saat") %></span></div>
            <div class="ss-card-bottom"><span class="ss-card-ts"><i class="bi bi-clock"></i> <%= GetUpdated("CONFIG003") %></span><div class="ss-card-btns"><a class="ss-cbtn ss-cbtn-reset" onclick="resetCard(this)" href="javascript:;"><i class="bi bi-arrow-counterclockwise"></i> Reset</a><a class="ss-cbtn ss-cbtn-save cat-quiz" onclick="saveCard('CONFIG003')" href="javascript:;"><i class="bi bi-floppy"></i> <%= T("Save", "Simpan") %></a></div></div>
        </div>
        <!-- CONFIG004 -->
        <div class="ss-card cat-quiz" data-id="CONFIG004" data-search="passing mark percentage unit peratusan lulus">
            <div class="ss-card-top"><div class="ss-card-icon" style="background:var(--ss-quiz-light);color:var(--ss-quiz);"><i class="bi bi-bullseye"></i></div><div class="ss-card-info"><div class="ss-card-name"><%= T("Passing Mark Percentage for Unit", "Peratusan Lulus untuk Unit") %></div><div class="ss-card-desc"><%= T("Minimum percentage to pass a unit quiz.", "Peratusan minimum untuk lulus kuiz unit.") %></div></div></div>
            <div class="ss-card-value"><input type="number" id="val_CONFIG004" value="<%= GetVal("CONFIG004") %>" data-orig="<%= GetVal("CONFIG004") %>" oninput="detectChange(this)" min="1" max="100" /><span class="ss-card-unit">%</span></div>
            <div class="ss-card-bottom"><span class="ss-card-ts"><i class="bi bi-clock"></i> <%= GetUpdated("CONFIG004") %></span><div class="ss-card-btns"><a class="ss-cbtn ss-cbtn-reset" onclick="resetCard(this)" href="javascript:;"><i class="bi bi-arrow-counterclockwise"></i> Reset</a><a class="ss-cbtn ss-cbtn-save cat-quiz" onclick="saveCard('CONFIG004')" href="javascript:;"><i class="bi bi-floppy"></i> <%= T("Save", "Simpan") %></a></div></div>
        </div>
        <!-- CONFIG005 -->
        <div class="ss-card cat-quiz" data-id="CONFIG005" data-search="passing mark level peratusan lulus tahap">
            <div class="ss-card-top"><div class="ss-card-icon" style="background:var(--ss-quiz-light);color:var(--ss-quiz);"><i class="bi bi-trophy"></i></div><div class="ss-card-info"><div class="ss-card-name"><%= T("Passing Mark for Level", "Markah Lulus untuk Tahap") %></div><div class="ss-card-desc"><%= T("Minimum percentage to pass a level assessment.", "Peratusan minimum untuk lulus penilaian tahap.") %></div></div></div>
            <div class="ss-card-value"><input type="number" id="val_CONFIG005" value="<%= GetVal("CONFIG005") %>" data-orig="<%= GetVal("CONFIG005") %>" oninput="detectChange(this)" min="1" max="100" /><span class="ss-card-unit">%</span></div>
            <div class="ss-card-bottom"><span class="ss-card-ts"><i class="bi bi-clock"></i> <%= GetUpdated("CONFIG005") %></span><div class="ss-card-btns"><a class="ss-cbtn ss-cbtn-reset" onclick="resetCard(this)" href="javascript:;"><i class="bi bi-arrow-counterclockwise"></i> Reset</a><a class="ss-cbtn ss-cbtn-save cat-quiz" onclick="saveCard('CONFIG005')" href="javascript:;"><i class="bi bi-floppy"></i> <%= T("Save", "Simpan") %></a></div></div>
        </div>
        <!-- CONFIG007 -->
        <div class="ss-card cat-quiz" data-id="CONFIG007" data-search="easy question mark markah soalan mudah">
            <div class="ss-card-top"><div class="ss-card-icon" style="background:var(--ss-quiz-light);color:var(--ss-quiz);"><i class="bi bi-star"></i></div><div class="ss-card-info"><div class="ss-card-name"><%= T("Easy Question Mark", "Markah Soalan Mudah") %></div><div class="ss-card-desc"><%= T("Marks awarded for each correct easy question.", "Markah untuk setiap jawapan mudah yang betul.") %></div></div></div>
            <div class="ss-card-value"><input type="number" id="val_CONFIG007" value="<%= GetVal("CONFIG007") %>" data-orig="<%= GetVal("CONFIG007") %>" oninput="detectChange(this)" min="1" /><span class="ss-card-unit"><%= T("Marks", "Markah") %></span></div>
            <div class="ss-card-bottom"><span class="ss-card-ts"><i class="bi bi-clock"></i> <%= GetUpdated("CONFIG007") %></span><div class="ss-card-btns"><a class="ss-cbtn ss-cbtn-reset" onclick="resetCard(this)" href="javascript:;"><i class="bi bi-arrow-counterclockwise"></i> Reset</a><a class="ss-cbtn ss-cbtn-save cat-quiz" onclick="saveCard('CONFIG007')" href="javascript:;"><i class="bi bi-floppy"></i> <%= T("Save", "Simpan") %></a></div></div>
        </div>
        <!-- CONFIG008 -->
        <div class="ss-card cat-quiz" data-id="CONFIG008" data-search="medium question mark markah soalan sederhana">
            <div class="ss-card-top"><div class="ss-card-icon" style="background:var(--ss-quiz-light);color:var(--ss-quiz);"><i class="bi bi-star-half"></i></div><div class="ss-card-info"><div class="ss-card-name"><%= T("Medium Question Mark", "Markah Soalan Sederhana") %></div><div class="ss-card-desc"><%= T("Marks awarded for each correct medium question.", "Markah untuk setiap jawapan sederhana yang betul.") %></div></div></div>
            <div class="ss-card-value"><input type="number" id="val_CONFIG008" value="<%= GetVal("CONFIG008") %>" data-orig="<%= GetVal("CONFIG008") %>" oninput="detectChange(this)" min="1" /><span class="ss-card-unit"><%= T("Marks", "Markah") %></span></div>
            <div class="ss-card-bottom"><span class="ss-card-ts"><i class="bi bi-clock"></i> <%= GetUpdated("CONFIG008") %></span><div class="ss-card-btns"><a class="ss-cbtn ss-cbtn-reset" onclick="resetCard(this)" href="javascript:;"><i class="bi bi-arrow-counterclockwise"></i> Reset</a><a class="ss-cbtn ss-cbtn-save cat-quiz" onclick="saveCard('CONFIG008')" href="javascript:;"><i class="bi bi-floppy"></i> <%= T("Save", "Simpan") %></a></div></div>
        </div>
        <!-- CONFIG009 -->
        <div class="ss-card cat-quiz" data-id="CONFIG009" data-search="hard question mark markah soalan sukar">
            <div class="ss-card-top"><div class="ss-card-icon" style="background:var(--ss-quiz-light);color:var(--ss-quiz);"><i class="bi bi-star-fill"></i></div><div class="ss-card-info"><div class="ss-card-name"><%= T("Hard Question Mark", "Markah Soalan Sukar") %></div><div class="ss-card-desc"><%= T("Marks awarded for each correct hard question.", "Markah untuk setiap jawapan sukar yang betul.") %></div></div></div>
            <div class="ss-card-value"><input type="number" id="val_CONFIG009" value="<%= GetVal("CONFIG009") %>" data-orig="<%= GetVal("CONFIG009") %>" oninput="detectChange(this)" min="1" /><span class="ss-card-unit"><%= T("Marks", "Markah") %></span></div>
            <div class="ss-card-bottom"><span class="ss-card-ts"><i class="bi bi-clock"></i> <%= GetUpdated("CONFIG009") %></span><div class="ss-card-btns"><a class="ss-cbtn ss-cbtn-reset" onclick="resetCard(this)" href="javascript:;"><i class="bi bi-arrow-counterclockwise"></i> Reset</a><a class="ss-cbtn ss-cbtn-save cat-quiz" onclick="saveCard('CONFIG009')" href="javascript:;"><i class="bi bi-floppy"></i> <%= T("Save", "Simpan") %></a></div></div>
        </div>
    </div>
</div>

<!-- ═══════ SECURITY SETTINGS SECTION ═══════ -->
<div class="ss-section" data-section="sec">
    <div class="ss-sec-hdr cat-sec" onclick="toggleSec(this)">
        <div class="ss-sec-ico"><i class="bi bi-shield-lock-fill"></i></div>
        <div class="ss-sec-title"><%= T("Security Settings", "Tetapan Keselamatan") %></div>
        <span class="ss-sec-count"><%= T("3 settings", "3 tetapan") %></span>
        <i class="bi bi-chevron-down ss-sec-arrow"></i>
    </div>
    <div class="ss-sec-body">
        <!-- CONFIG010 -->
        <div class="ss-card cat-sec" data-id="CONFIG010" data-search="suspicious login attempt percubaan log masuk mencurigakan">
            <div class="ss-card-top"><div class="ss-card-icon" style="background:var(--ss-sec-light);color:var(--ss-sec);"><i class="bi bi-exclamation-triangle-fill"></i></div><div class="ss-card-info"><div class="ss-card-name"><%= T("Suspicious Login Attempts", "Percubaan Log Masuk Mencurigakan") %></div><div class="ss-card-desc"><%= T("Failed attempts before triggering security alert.", "Percubaan gagal sebelum amaran keselamatan.") %></div></div></div>
            <div class="ss-card-value"><input type="number" id="val_CONFIG010" value="<%= GetVal("CONFIG010") %>" data-orig="<%= GetVal("CONFIG010") %>" oninput="detectChange(this)" min="1" /><span class="ss-card-unit"><%= T("Attempts", "Percubaan") %></span></div>
            <div class="ss-card-bottom"><span class="ss-card-ts"><i class="bi bi-clock"></i> <%= GetUpdated("CONFIG010") %></span><div class="ss-card-btns"><a class="ss-cbtn ss-cbtn-reset" onclick="resetCard(this)" href="javascript:;"><i class="bi bi-arrow-counterclockwise"></i> Reset</a><a class="ss-cbtn ss-cbtn-save cat-sec" onclick="saveCard('CONFIG010')" href="javascript:;"><i class="bi bi-floppy"></i> <%= T("Save", "Simpan") %></a></div></div>
        </div>
        <!-- CONFIG011 -->
        <div class="ss-card cat-sec" data-id="CONFIG011" data-search="account lock duration minutes tempoh kunci akaun minit">
            <div class="ss-card-top"><div class="ss-card-icon" style="background:var(--ss-sec-light);color:var(--ss-sec);"><i class="bi bi-lock-fill"></i></div><div class="ss-card-info"><div class="ss-card-name"><%= T("Account Lock Duration", "Tempoh Kunci Akaun") %></div><div class="ss-card-desc"><%= T("How long an account remains locked after exceeding attempts.", "Berapa lama akaun dikunci selepas melebihi percubaan.") %></div></div></div>
            <div class="ss-card-value"><input type="number" id="val_CONFIG011" value="<%= GetVal("CONFIG011") %>" data-orig="<%= GetVal("CONFIG011") %>" oninput="detectChange(this)" min="1" /><span class="ss-card-unit"><%= T("Minutes", "Minit") %></span></div>
            <div class="ss-card-bottom"><span class="ss-card-ts"><i class="bi bi-clock"></i> <%= GetUpdated("CONFIG011") %></span><div class="ss-card-btns"><a class="ss-cbtn ss-cbtn-reset" onclick="resetCard(this)" href="javascript:;"><i class="bi bi-arrow-counterclockwise"></i> Reset</a><a class="ss-cbtn ss-cbtn-save cat-sec" onclick="saveCard('CONFIG011')" href="javascript:;"><i class="bi bi-floppy"></i> <%= T("Save", "Simpan") %></a></div></div>
        </div>
        <!-- CONFIG012 -->
        <div class="ss-card cat-sec" data-id="CONFIG012" data-search="password minimum length panjang minimum kata laluan characters aksara">
            <div class="ss-card-top"><div class="ss-card-icon" style="background:var(--ss-sec-light);color:var(--ss-sec);"><i class="bi bi-key-fill"></i></div><div class="ss-card-info"><div class="ss-card-name"><%= T("Password Minimum Length", "Panjang Minimum Kata Laluan") %></div><div class="ss-card-desc"><%= T("Minimum characters required for user passwords.", "Bilangan minimum aksara untuk kata laluan pengguna.") %></div></div></div>
            <div class="ss-card-value"><input type="number" id="val_CONFIG012" value="<%= GetVal("CONFIG012") %>" data-orig="<%= GetVal("CONFIG012") %>" oninput="detectChange(this)" min="1" /><span class="ss-card-unit"><%= T("Characters", "Aksara") %></span></div>
            <div class="ss-card-bottom"><span class="ss-card-ts"><i class="bi bi-clock"></i> <%= GetUpdated("CONFIG012") %></span><div class="ss-card-btns"><a class="ss-cbtn ss-cbtn-reset" onclick="resetCard(this)" href="javascript:;"><i class="bi bi-arrow-counterclockwise"></i> Reset</a><a class="ss-cbtn ss-cbtn-save cat-sec" onclick="saveCard('CONFIG012')" href="javascript:;"><i class="bi bi-floppy"></i> <%= T("Save", "Simpan") %></a></div></div>
        </div>
    </div>
</div>

<!-- ═══════ GAMIFICATION SETTINGS SECTION ═══════ -->
<div class="ss-section" data-section="gam">
    <div class="ss-sec-hdr cat-gam" onclick="toggleSec(this)">
        <div class="ss-sec-ico"><i class="bi bi-trophy-fill"></i></div>
        <div class="ss-sec-title"><%= T("Gamification Settings", "Tetapan Gamifikasi") %></div>
        <span class="ss-sec-count"><%= T("1 setting", "1 tetapan") %></span>
        <i class="bi bi-chevron-down ss-sec-arrow"></i>
    </div>
    <div class="ss-sec-body">
        <!-- CONFIG006 -->
        <div class="ss-card cat-gam" data-id="CONFIG006" data-search="leaderboard top count bilangan teratas papan markah students pelajar">
            <div class="ss-card-top"><div class="ss-card-icon" style="background:var(--ss-gam-light);color:var(--ss-gam);"><i class="bi bi-bar-chart-fill"></i></div><div class="ss-card-info"><div class="ss-card-name"><%= T("Leaderboard Top Count", "Bilangan Teratas Papan Markah") %></div><div class="ss-card-desc"><%= T("Number of top students shown on the leaderboard.", "Bilangan pelajar teratas di papan markah.") %></div></div></div>
            <div class="ss-card-value"><input type="number" id="val_CONFIG006" value="<%= GetVal("CONFIG006") %>" data-orig="<%= GetVal("CONFIG006") %>" oninput="detectChange(this)" min="1" /><span class="ss-card-unit"><%= T("Students", "Pelajar") %></span></div>
            <div class="ss-card-bottom"><span class="ss-card-ts"><i class="bi bi-clock"></i> <%= GetUpdated("CONFIG006") %></span><div class="ss-card-btns"><a class="ss-cbtn ss-cbtn-reset" onclick="resetCard(this)" href="javascript:;"><i class="bi bi-arrow-counterclockwise"></i> Reset</a><a class="ss-cbtn ss-cbtn-save cat-gam" onclick="saveCard('CONFIG006')" href="javascript:;"><i class="bi bi-floppy"></i> <%= T("Save", "Simpan") %></a></div></div>
        </div>
    </div>
</div>

<!-- ═══════ LIVE SESSION SETTINGS SECTION ═══════ -->
<div class="ss-section" data-section="live">
    <div class="ss-sec-hdr cat-live" onclick="toggleSec(this)">
        <div class="ss-sec-ico"><i class="bi bi-camera-video-fill"></i></div>
        <div class="ss-sec-title"><%= T("Live Session Settings", "Tetapan Sesi Langsung") %></div>
        <span class="ss-sec-count"><%= T("2 settings", "2 tetapan") %></span>
        <i class="bi bi-chevron-down ss-sec-arrow"></i>
    </div>
    <div class="ss-sec-body">
        <!-- CONFIG013 -->
        <div class="ss-card cat-live" data-id="CONFIG013" data-search="maximum students per session maksimum pelajar setiap sesi">
            <div class="ss-card-top"><div class="ss-card-icon" style="background:var(--ss-live-light);color:var(--ss-live);"><i class="bi bi-people-fill"></i></div><div class="ss-card-info"><div class="ss-card-name"><%= T("Maximum Students Per Session", "Maksimum Pelajar Setiap Sesi") %></div><div class="ss-card-desc"><%= T("Maximum students allowed in a live consultation session.", "Bilangan maksimum pelajar dalam sesi konsultasi langsung.") %></div></div></div>
            <div class="ss-card-value"><input type="number" id="val_CONFIG013" value="<%= GetVal("CONFIG013") %>" data-orig="<%= GetVal("CONFIG013") %>" oninput="detectChange(this)" min="1" /><span class="ss-card-unit"><%= T("Students", "Pelajar") %></span></div>
            <div class="ss-card-bottom"><span class="ss-card-ts"><i class="bi bi-clock"></i> <%= GetUpdated("CONFIG013") %></span><div class="ss-card-btns"><a class="ss-cbtn ss-cbtn-reset" onclick="resetCard(this)" href="javascript:;"><i class="bi bi-arrow-counterclockwise"></i> Reset</a><a class="ss-cbtn ss-cbtn-save cat-live" onclick="saveCard('CONFIG013')" href="javascript:;"><i class="bi bi-floppy"></i> <%= T("Save", "Simpan") %></a></div></div>
        </div>
        <!-- CONFIG014 -->
        <div class="ss-card cat-live" data-id="CONFIG014" data-search="consultation session duration minutes tempoh sesi konsultasi minit">
            <div class="ss-card-top"><div class="ss-card-icon" style="background:var(--ss-live-light);color:var(--ss-live);"><i class="bi bi-hourglass-split"></i></div><div class="ss-card-info"><div class="ss-card-name"><%= T("Consultation Session Duration", "Tempoh Sesi Konsultasi") %></div><div class="ss-card-desc"><%= T("Default duration for each live consultation session.", "Tempoh lalai untuk setiap sesi konsultasi langsung.") %></div></div></div>
            <div class="ss-card-value"><input type="number" id="val_CONFIG014" value="<%= GetVal("CONFIG014") %>" data-orig="<%= GetVal("CONFIG014") %>" oninput="detectChange(this)" min="1" /><span class="ss-card-unit"><%= T("Minutes", "Minit") %></span></div>
            <div class="ss-card-bottom"><span class="ss-card-ts"><i class="bi bi-clock"></i> <%= GetUpdated("CONFIG014") %></span><div class="ss-card-btns"><a class="ss-cbtn ss-cbtn-reset" onclick="resetCard(this)" href="javascript:;"><i class="bi bi-arrow-counterclockwise"></i> Reset</a><a class="ss-cbtn ss-cbtn-save cat-live" onclick="saveCard('CONFIG014')" href="javascript:;"><i class="bi bi-floppy"></i> <%= T("Save", "Simpan") %></a></div></div>
        </div>
    </div>
</div>

<!-- ═══════ JAVASCRIPT ═══════ -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>
// ── Collapse / Expand ──
function toggleSec(hdr) {
    var body = hdr.nextElementSibling;
    var arrow = hdr.querySelector('.ss-sec-arrow');
    if (body.classList.contains('collapsed')) {
        body.classList.remove('collapsed');
        body.style.maxHeight = body.scrollHeight + 'px';
        body.style.opacity = '1';
        arrow.classList.remove('collapsed');
    } else {
        body.classList.add('collapsed');
        body.style.maxHeight = '0';
        body.style.opacity = '0';
        arrow.classList.add('collapsed');
    }
}

// ── Change Detection ──
function detectChange(input) {
    var card = input.closest('.ss-card');
    if (input.value !== input.getAttribute('data-orig')) {
        card.classList.add('changed');
    } else {
        card.classList.remove('changed');
    }
}

// ── Reset ──
function resetCard(btn) {
    var card = btn.closest('.ss-card');
    var input = card.querySelector('input[type=number]');
    input.value = input.getAttribute('data-orig');
    card.classList.remove('changed');
}

// ── Save (AJAX via hidden iframe / __doPostBack) ──
function saveCard(configId) {
    var input = document.getElementById('val_' + configId);
    var newVal = input.value.trim();
    if (!newVal || parseInt(newVal) < 0) {
        Swal.fire({ icon: 'warning', title: 'Invalid', text: 'Please enter a valid number.', confirmButtonColor: '#6366F1' });
        return;
    }
    var card = input.closest('.ss-card');
    var saveBtn = card.querySelector('.ss-cbtn-save');
    saveBtn.classList.add('saving');
    saveBtn.innerHTML = '<i class="bi bi-arrow-repeat spin"></i> Saving...';

    // Use PageMethods (WebMethod) via fetch
    var formData = new FormData();
    formData.append('configId', configId);
    formData.append('newValue', newVal);

    fetch(window.location.pathname + '?handler=SaveConfig&configId=' + encodeURIComponent(configId) + '&newValue=' + encodeURIComponent(newVal), {
        method: 'POST',
        headers: { 'X-Requested-With': 'XMLHttpRequest' }
    }).then(function(r) { return r.json(); })
    .then(function(data) {
        saveBtn.classList.remove('saving');
        if (data.success) {
            saveBtn.innerHTML = '<i class="bi bi-check-lg"></i> Saved!';
            saveBtn.style.background = '#16A34A';
            input.setAttribute('data-orig', newVal);
            card.classList.remove('changed');
            // Update timestamp
            var tsEl = card.querySelector('.ss-card-ts');
            tsEl.innerHTML = '<i class="bi bi-clock"></i> ' + data.updatedAt;
            setTimeout(function() {
                saveBtn.innerHTML = '<i class="bi bi-floppy"></i> <%= T("Save", "Simpan") %>';
                saveBtn.style.background = '';
            }, 2000);
            Swal.fire({ icon: 'success', title: '<%= T("Saved!", "Disimpan!") %>', text: data.message, confirmButtonColor: '#6366F1', timer: 2500, timerProgressBar: true, showConfirmButton: false });
        } else {
            saveBtn.innerHTML = '<i class="bi bi-floppy"></i> <%= T("Save", "Simpan") %>';
            Swal.fire({ icon: 'error', title: 'Error', text: data.message || 'Failed to save.', confirmButtonColor: '#6366F1' });
        }
    }).catch(function() {
        saveBtn.classList.remove('saving');
        saveBtn.innerHTML = '<i class="bi bi-floppy"></i> <%= T("Save", "Simpan") %>';
        Swal.fire({ icon: 'error', title: 'Error', text: 'Network error. Please try again.', confirmButtonColor: '#6366F1' });
    });
}

// ── Search ──
var activeCat = 'all';
function filterSettings() {
    var q = document.getElementById('ssSearch').value.toLowerCase().trim();
    var cards = document.querySelectorAll('.ss-card');
    var sections = document.querySelectorAll('.ss-section');
    var visibleCount = 0;

    cards.forEach(function(card) {
        var search = card.getAttribute('data-search') || '';
        var name = card.querySelector('.ss-card-name').textContent.toLowerCase();
        var matchSearch = !q || search.indexOf(q) !== -1 || name.indexOf(q) !== -1;
        var sec = card.closest('.ss-section');
        var matchCat = activeCat === 'all' || sec.getAttribute('data-section') === activeCat;
        if (matchSearch && matchCat) { card.style.display = ''; visibleCount++; }
        else { card.style.display = 'none'; }
    });

    // Show/hide sections that have no visible cards
    sections.forEach(function(sec) {
        var visCards = sec.querySelectorAll('.ss-card:not([style*="display: none"])');
        if (visCards.length === 0) { sec.style.display = 'none'; }
        else { sec.style.display = ''; }
    });

    var emptyEl = document.getElementById('ssEmpty');
    if (visibleCount === 0) { emptyEl.classList.add('visible'); }
    else { emptyEl.classList.remove('visible'); }
}

function filterCat(chip) {
    document.querySelectorAll('.ss-chip').forEach(function(c) { c.classList.remove('active'); });
    chip.classList.add('active');
    activeCat = chip.getAttribute('data-cat');
    filterSettings();
}

// ── Init sections expanded ──
window.addEventListener('load', function() {
    document.querySelectorAll('.ss-sec-body').forEach(function(body) {
        body.style.maxHeight = body.scrollHeight + 'px';
        body.style.opacity = '1';
    });
});
</script>
<style>.spin{animation:spin 1s linear infinite;}@keyframes spin{from{transform:rotate(0)}to{transform:rotate(360deg)}}</style>

</asp:Content>
