<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SystemSettings.aspx.cs"
    Inherits="ScienceBuddy.Admin.SystemSettings" MasterPageFile="~/Site.Master"
    Title="System Settings" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%: ResolveUrl("~/Content/Admin.css") %>" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" />
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
        <a href="<%: ResolveUrl("~/Admin/TeacherCertificateApproval.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-check item-icon"></i><span class="item-label">Teacher Certificate Approval</span></a>
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
        <a href="<%: ResolveUrl("~/Admin/QuestionBank.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-question-circle item-icon"></i>
            <span class="item-label">Question Bank</span>
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
        <div class="sb-nav-section-label">Community</div>
        <a href="<%: ResolveUrl("~/Admin/ForumDiscussions.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-chat-dots item-icon"></i>
            <span class="item-label">Forum Discussions</span>
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
<div class="ad-system-settings-page-hdr">
    <div class="ad-system-settings-page-left">
        <div class="ad-system-settings-page-title"><i class="bi bi-gear-wide-connected" style="color:#6366F1;"></i> <%= T("System Settings", "Tetapan Sistem") %></div>
        <div class="ad-system-settings-page-sub"><%= T("Manage all configurable values used throughout ScienceBuddy.", "Urus semua nilai konfigurasi yang digunakan di seluruh ScienceBuddy.") %></div>
    </div>
    <div class="ad-system-settings-page-right">
        <div class="ad-system-settings-last-sync"><i class="bi bi-check-circle-fill" style="color:#16A34A;"></i> <%= T("Last synchronized", "Penyegerakan terakhir") %> <strong><asp:Literal ID="litLastSync" runat="server" /></strong></div>
        <button type="button" class="ad-system-settings-btn-refresh" onclick="location.reload();"><i class="bi bi-arrow-clockwise"></i> <%= T("Refresh", "Muat Semula") %></button>
    </div>
</div>

<!-- SUMMARY CARDS -->
<div class="ad-system-settings-summary">
    <div class="ad-system-settings-sum">
        <div class="ad-system-settings-sum-ico" style="background:#EEF2FF;color:#6366F1;"><i class="bi bi-gear-fill"></i></div>
        <div><div class="ad-system-settings-sum-val"><asp:Literal ID="litTotalSettings" runat="server" Text="14" /></div><div class="ad-system-settings-sum-lbl"><%= T("Total Settings", "Jumlah Tetapan") %></div></div>
    </div>
    <div class="ad-system-settings-sum">
        <div class="ad-system-settings-sum-ico" style="background:#D1FAE5;color:#059669;"><i class="bi bi-pencil-square"></i></div>
        <div><div class="ad-system-settings-sum-val"><asp:Literal ID="litUpdatedToday" runat="server" Text="0" /></div><div class="ad-system-settings-sum-lbl"><%= T("Modified Today", "Diubah Hari Ini") %></div></div>
    </div>
    <div class="ad-system-settings-sum">
        <div class="ad-system-settings-sum-ico" style="background:#FEF3C7;color:#D97706;"><i class="bi bi-clock-history"></i></div>
        <div><div class="ad-system-settings-sum-val" style="font-size:1rem;"><asp:Literal ID="litRecentName" runat="server" Text="-" /></div><div class="ad-system-settings-sum-lbl"><%= T("Recently Updated", "Terkini Dikemas Kini") %></div><div class="ad-system-settings-sum-detail"><asp:Literal ID="litRecentTime" runat="server" /></div></div>
    </div>
    <div class="ad-system-settings-sum">
        <div class="ad-system-settings-sum-ico" style="background:#DCFCE7;color:#16A34A;"><i class="bi bi-activity"></i></div>
        <div><div class="ad-system-settings-sum-val" style="color:#16A34A;"><%= T("Online", "Dalam Talian") %></div><div class="ad-system-settings-sum-lbl"><%= T("System Status", "Status Sistem") %></div><div class="ad-system-settings-sum-detail"><%= T("Healthy", "Sihat") %></div></div>
    </div>
</div>

<!-- SEARCH + FILTER TOOLBAR -->
<div class="ad-system-settings-toolbar">
    <div class="ad-system-settings-search-wrap">
        <i class="bi bi-search"></i>
        <input type="text" id="ssSearch" class="ad-system-settings-search" placeholder="<%= T("Search settings...", "Cari tetapan...") %>" oninput="filterSettings()" />
    </div>
    <div class="ad-system-settings-chips">
        <span class="ad-system-settings-chip active" data-cat="all" onclick="filterCat(this)"><%= T("All", "Semua") %></span>
        <span class="ad-system-settings-chip" data-cat="quiz" onclick="filterCat(this)"><i class="bi bi-book-half"></i> <%= T("Quiz", "Kuiz") %></span>
        <span class="ad-system-settings-chip" data-cat="sec" onclick="filterCat(this)"><i class="bi bi-shield-lock"></i> <%= T("Security", "Keselamatan") %></span>
        <span class="ad-system-settings-chip" data-cat="gam" onclick="filterCat(this)"><i class="bi bi-trophy"></i> <%= T("Gamification", "Gamifikasi") %></span>
        <span class="ad-system-settings-chip" data-cat="live" onclick="filterCat(this)"><i class="bi bi-camera-video"></i> <%= T("Live Session", "Sesi Langsung") %></span>
    </div>
</div>

<!-- EMPTY SEARCH STATE -->
<div class="ad-system-settings-empty" id="ssEmpty">
    <div class="ad-system-settings-empty-ico"><i class="bi bi-search"></i></div>
    <div class="ad-system-settings-empty-msg"><%= T("No settings found.", "Tiada tetapan dijumpai.") %></div>
    <div class="ad-system-settings-empty-sub"><%= T("Try another keyword.", "Cuba kata kunci lain.") %></div>
</div>

<!-- ═══════ QUIZ SETTINGS SECTION ═══════ -->
<div class="ad-system-settings-section" data-section="quiz">
    <div class="ad-system-settings-sec-hdr cat-quiz" onclick="toggleSec(this)">
        <div class="ad-system-settings-sec-ico"><i class="bi bi-book-half"></i></div>
        <div class="ad-system-settings-sec-title"><%= T("Quiz Settings", "Tetapan Kuiz") %></div>
        <span class="ad-system-settings-sec-count"><%= T("8 settings", "8 tetapan") %></span>
        <i class="bi bi-chevron-down ad-system-settings-sec-arrow"></i>
    </div>
    <div class="ad-system-settings-sec-body">
        <!-- CONFIG001 -->
        <div class="ad-system-settings-card cat-quiz" data-id="CONFIG001" data-search="easy question timer seconds pemasa soalan mudah saat">
            <div class="ad-system-settings-card-top"><div class="ad-system-settings-card-icon" style="background:var(--ad-system-settings-quiz-light);color:var(--ad-system-settings-quiz);"><i class="bi bi-stopwatch"></i></div><div class="ad-system-settings-card-info"><div class="ad-system-settings-card-name"><%= T("Easy Question Timer", "Pemasa Soalan Mudah") %></div><div class="ad-system-settings-card-desc"><%= T("How long students have to answer easy questions.", "Berapa lama pelajar menjawab soalan mudah.") %></div></div></div>
            <div class="ad-system-settings-card-value"><input type="number" id="val_CONFIG001" value="<%= GetVal("CONFIG001") %>" data-orig="<%= GetVal("CONFIG001") %>" oninput="detectChange(this)" min="1" /><span class="ad-system-settings-card-unit"><%= T("Seconds", "Saat") %></span></div>
            <div class="ad-system-settings-card-bottom"><span class="ad-system-settings-card-ts"><i class="bi bi-clock"></i> <%= GetUpdated("CONFIG001") %></span><div class="ad-system-settings-card-btns"><a class="ad-system-settings-cbtn ad-system-settings-cbtn-reset" onclick="resetCard(this)" href="javascript:;"><i class="bi bi-arrow-counterclockwise"></i> Reset</a><a class="ad-system-settings-cbtn ad-system-settings-cbtn-save cat-quiz" onclick="saveCard('CONFIG001')" href="javascript:;"><i class="bi bi-floppy"></i> <%= T("Save", "Simpan") %></a></div></div>
        </div>
        <!-- CONFIG002 -->
        <div class="ad-system-settings-card cat-quiz" data-id="CONFIG002" data-search="medium question timer seconds pemasa soalan sederhana saat">
            <div class="ad-system-settings-card-top"><div class="ad-system-settings-card-icon" style="background:var(--ad-system-settings-quiz-light);color:var(--ad-system-settings-quiz);"><i class="bi bi-stopwatch"></i></div><div class="ad-system-settings-card-info"><div class="ad-system-settings-card-name"><%= T("Medium Question Timer", "Pemasa Soalan Sederhana") %></div><div class="ad-system-settings-card-desc"><%= T("How long students have to answer medium questions.", "Berapa lama pelajar menjawab soalan sederhana.") %></div></div></div>
            <div class="ad-system-settings-card-value"><input type="number" id="val_CONFIG002" value="<%= GetVal("CONFIG002") %>" data-orig="<%= GetVal("CONFIG002") %>" oninput="detectChange(this)" min="1" /><span class="ad-system-settings-card-unit"><%= T("Seconds", "Saat") %></span></div>
            <div class="ad-system-settings-card-bottom"><span class="ad-system-settings-card-ts"><i class="bi bi-clock"></i> <%= GetUpdated("CONFIG002") %></span><div class="ad-system-settings-card-btns"><a class="ad-system-settings-cbtn ad-system-settings-cbtn-reset" onclick="resetCard(this)" href="javascript:;"><i class="bi bi-arrow-counterclockwise"></i> Reset</a><a class="ad-system-settings-cbtn ad-system-settings-cbtn-save cat-quiz" onclick="saveCard('CONFIG002')" href="javascript:;"><i class="bi bi-floppy"></i> <%= T("Save", "Simpan") %></a></div></div>
        </div>
        <!-- CONFIG003 -->
        <div class="ad-system-settings-card cat-quiz" data-id="CONFIG003" data-search="hard question timer seconds pemasa soalan sukar saat">
            <div class="ad-system-settings-card-top"><div class="ad-system-settings-card-icon" style="background:var(--ad-system-settings-quiz-light);color:var(--ad-system-settings-quiz);"><i class="bi bi-stopwatch-fill"></i></div><div class="ad-system-settings-card-info"><div class="ad-system-settings-card-name"><%= T("Hard Question Timer", "Pemasa Soalan Sukar") %></div><div class="ad-system-settings-card-desc"><%= T("How long students have to answer hard questions.", "Berapa lama pelajar menjawab soalan sukar.") %></div></div></div>
            <div class="ad-system-settings-card-value"><input type="number" id="val_CONFIG003" value="<%= GetVal("CONFIG003") %>" data-orig="<%= GetVal("CONFIG003") %>" oninput="detectChange(this)" min="1" /><span class="ad-system-settings-card-unit"><%= T("Seconds", "Saat") %></span></div>
            <div class="ad-system-settings-card-bottom"><span class="ad-system-settings-card-ts"><i class="bi bi-clock"></i> <%= GetUpdated("CONFIG003") %></span><div class="ad-system-settings-card-btns"><a class="ad-system-settings-cbtn ad-system-settings-cbtn-reset" onclick="resetCard(this)" href="javascript:;"><i class="bi bi-arrow-counterclockwise"></i> Reset</a><a class="ad-system-settings-cbtn ad-system-settings-cbtn-save cat-quiz" onclick="saveCard('CONFIG003')" href="javascript:;"><i class="bi bi-floppy"></i> <%= T("Save", "Simpan") %></a></div></div>
        </div>
        <!-- CONFIG004 -->
        <div class="ad-system-settings-card cat-quiz" data-id="CONFIG004" data-search="passing mark percentage unit peratusan lulus">
            <div class="ad-system-settings-card-top"><div class="ad-system-settings-card-icon" style="background:var(--ad-system-settings-quiz-light);color:var(--ad-system-settings-quiz);"><i class="bi bi-bullseye"></i></div><div class="ad-system-settings-card-info"><div class="ad-system-settings-card-name"><%= T("Passing Mark Percentage for Unit", "Peratusan Lulus untuk Unit") %></div><div class="ad-system-settings-card-desc"><%= T("Minimum percentage to pass a unit quiz.", "Peratusan minimum untuk lulus kuiz unit.") %></div></div></div>
            <div class="ad-system-settings-card-value"><input type="number" id="val_CONFIG004" value="<%= GetVal("CONFIG004") %>" data-orig="<%= GetVal("CONFIG004") %>" oninput="detectChange(this)" min="1" max="100" /><span class="ad-system-settings-card-unit">%</span></div>
            <div class="ad-system-settings-card-bottom"><span class="ad-system-settings-card-ts"><i class="bi bi-clock"></i> <%= GetUpdated("CONFIG004") %></span><div class="ad-system-settings-card-btns"><a class="ad-system-settings-cbtn ad-system-settings-cbtn-reset" onclick="resetCard(this)" href="javascript:;"><i class="bi bi-arrow-counterclockwise"></i> Reset</a><a class="ad-system-settings-cbtn ad-system-settings-cbtn-save cat-quiz" onclick="saveCard('CONFIG004')" href="javascript:;"><i class="bi bi-floppy"></i> <%= T("Save", "Simpan") %></a></div></div>
        </div>
        <!-- CONFIG005 -->
        <div class="ad-system-settings-card cat-quiz" data-id="CONFIG005" data-search="passing mark level peratusan lulus tahap">
            <div class="ad-system-settings-card-top"><div class="ad-system-settings-card-icon" style="background:var(--ad-system-settings-quiz-light);color:var(--ad-system-settings-quiz);"><i class="bi bi-trophy"></i></div><div class="ad-system-settings-card-info"><div class="ad-system-settings-card-name"><%= T("Passing Mark for Level", "Markah Lulus untuk Tahap") %></div><div class="ad-system-settings-card-desc"><%= T("Minimum percentage to pass a level assessment.", "Peratusan minimum untuk lulus penilaian tahap.") %></div></div></div>
            <div class="ad-system-settings-card-value"><input type="number" id="val_CONFIG005" value="<%= GetVal("CONFIG005") %>" data-orig="<%= GetVal("CONFIG005") %>" oninput="detectChange(this)" min="1" max="100" /><span class="ad-system-settings-card-unit">%</span></div>
            <div class="ad-system-settings-card-bottom"><span class="ad-system-settings-card-ts"><i class="bi bi-clock"></i> <%= GetUpdated("CONFIG005") %></span><div class="ad-system-settings-card-btns"><a class="ad-system-settings-cbtn ad-system-settings-cbtn-reset" onclick="resetCard(this)" href="javascript:;"><i class="bi bi-arrow-counterclockwise"></i> Reset</a><a class="ad-system-settings-cbtn ad-system-settings-cbtn-save cat-quiz" onclick="saveCard('CONFIG005')" href="javascript:;"><i class="bi bi-floppy"></i> <%= T("Save", "Simpan") %></a></div></div>
        </div>
        <!-- CONFIG007 -->
        <div class="ad-system-settings-card cat-quiz" data-id="CONFIG007" data-search="easy question mark markah soalan mudah">
            <div class="ad-system-settings-card-top"><div class="ad-system-settings-card-icon" style="background:var(--ad-system-settings-quiz-light);color:var(--ad-system-settings-quiz);"><i class="bi bi-star"></i></div><div class="ad-system-settings-card-info"><div class="ad-system-settings-card-name"><%= T("Easy Question Mark", "Markah Soalan Mudah") %></div><div class="ad-system-settings-card-desc"><%= T("Marks awarded for each correct easy question.", "Markah untuk setiap jawapan mudah yang betul.") %></div></div></div>
            <div class="ad-system-settings-card-value"><input type="number" id="val_CONFIG007" value="<%= GetVal("CONFIG007") %>" data-orig="<%= GetVal("CONFIG007") %>" oninput="detectChange(this)" min="1" /><span class="ad-system-settings-card-unit"><%= T("Marks", "Markah") %></span></div>
            <div class="ad-system-settings-card-bottom"><span class="ad-system-settings-card-ts"><i class="bi bi-clock"></i> <%= GetUpdated("CONFIG007") %></span><div class="ad-system-settings-card-btns"><a class="ad-system-settings-cbtn ad-system-settings-cbtn-reset" onclick="resetCard(this)" href="javascript:;"><i class="bi bi-arrow-counterclockwise"></i> Reset</a><a class="ad-system-settings-cbtn ad-system-settings-cbtn-save cat-quiz" onclick="saveCard('CONFIG007')" href="javascript:;"><i class="bi bi-floppy"></i> <%= T("Save", "Simpan") %></a></div></div>
        </div>
        <!-- CONFIG008 -->
        <div class="ad-system-settings-card cat-quiz" data-id="CONFIG008" data-search="medium question mark markah soalan sederhana">
            <div class="ad-system-settings-card-top"><div class="ad-system-settings-card-icon" style="background:var(--ad-system-settings-quiz-light);color:var(--ad-system-settings-quiz);"><i class="bi bi-star-half"></i></div><div class="ad-system-settings-card-info"><div class="ad-system-settings-card-name"><%= T("Medium Question Mark", "Markah Soalan Sederhana") %></div><div class="ad-system-settings-card-desc"><%= T("Marks awarded for each correct medium question.", "Markah untuk setiap jawapan sederhana yang betul.") %></div></div></div>
            <div class="ad-system-settings-card-value"><input type="number" id="val_CONFIG008" value="<%= GetVal("CONFIG008") %>" data-orig="<%= GetVal("CONFIG008") %>" oninput="detectChange(this)" min="1" /><span class="ad-system-settings-card-unit"><%= T("Marks", "Markah") %></span></div>
            <div class="ad-system-settings-card-bottom"><span class="ad-system-settings-card-ts"><i class="bi bi-clock"></i> <%= GetUpdated("CONFIG008") %></span><div class="ad-system-settings-card-btns"><a class="ad-system-settings-cbtn ad-system-settings-cbtn-reset" onclick="resetCard(this)" href="javascript:;"><i class="bi bi-arrow-counterclockwise"></i> Reset</a><a class="ad-system-settings-cbtn ad-system-settings-cbtn-save cat-quiz" onclick="saveCard('CONFIG008')" href="javascript:;"><i class="bi bi-floppy"></i> <%= T("Save", "Simpan") %></a></div></div>
        </div>
        <!-- CONFIG009 -->
        <div class="ad-system-settings-card cat-quiz" data-id="CONFIG009" data-search="hard question mark markah soalan sukar">
            <div class="ad-system-settings-card-top"><div class="ad-system-settings-card-icon" style="background:var(--ad-system-settings-quiz-light);color:var(--ad-system-settings-quiz);"><i class="bi bi-star-fill"></i></div><div class="ad-system-settings-card-info"><div class="ad-system-settings-card-name"><%= T("Hard Question Mark", "Markah Soalan Sukar") %></div><div class="ad-system-settings-card-desc"><%= T("Marks awarded for each correct hard question.", "Markah untuk setiap jawapan sukar yang betul.") %></div></div></div>
            <div class="ad-system-settings-card-value"><input type="number" id="val_CONFIG009" value="<%= GetVal("CONFIG009") %>" data-orig="<%= GetVal("CONFIG009") %>" oninput="detectChange(this)" min="1" /><span class="ad-system-settings-card-unit"><%= T("Marks", "Markah") %></span></div>
            <div class="ad-system-settings-card-bottom"><span class="ad-system-settings-card-ts"><i class="bi bi-clock"></i> <%= GetUpdated("CONFIG009") %></span><div class="ad-system-settings-card-btns"><a class="ad-system-settings-cbtn ad-system-settings-cbtn-reset" onclick="resetCard(this)" href="javascript:;"><i class="bi bi-arrow-counterclockwise"></i> Reset</a><a class="ad-system-settings-cbtn ad-system-settings-cbtn-save cat-quiz" onclick="saveCard('CONFIG009')" href="javascript:;"><i class="bi bi-floppy"></i> <%= T("Save", "Simpan") %></a></div></div>
        </div>
    </div>
</div>

<!-- ═══════ SECURITY SETTINGS SECTION ═══════ -->
<div class="ad-system-settings-section" data-section="sec">
    <div class="ad-system-settings-sec-hdr cat-sec" onclick="toggleSec(this)">
        <div class="ad-system-settings-sec-ico"><i class="bi bi-shield-lock-fill"></i></div>
        <div class="ad-system-settings-sec-title"><%= T("Security Settings", "Tetapan Keselamatan") %></div>
        <span class="ad-system-settings-sec-count"><%= T("3 settings", "3 tetapan") %></span>
        <i class="bi bi-chevron-down ad-system-settings-sec-arrow"></i>
    </div>
    <div class="ad-system-settings-sec-body">
        <!-- CONFIG010 -->
        <div class="ad-system-settings-card cat-sec" data-id="CONFIG010" data-search="suspicious login attempt percubaan log masuk mencurigakan">
            <div class="ad-system-settings-card-top"><div class="ad-system-settings-card-icon" style="background:var(--ad-system-settings-sec-light);color:var(--ad-system-settings-sec);"><i class="bi bi-exclamation-triangle-fill"></i></div><div class="ad-system-settings-card-info"><div class="ad-system-settings-card-name"><%= T("Suspicious Login Attempts", "Percubaan Log Masuk Mencurigakan") %></div><div class="ad-system-settings-card-desc"><%= T("Failed attempts before triggering security alert.", "Percubaan gagal sebelum amaran keselamatan.") %></div></div></div>
            <div class="ad-system-settings-card-value"><input type="number" id="val_CONFIG010" value="<%= GetVal("CONFIG010") %>" data-orig="<%= GetVal("CONFIG010") %>" oninput="detectChange(this)" min="1" /><span class="ad-system-settings-card-unit"><%= T("Attempts", "Percubaan") %></span></div>
            <div class="ad-system-settings-card-bottom"><span class="ad-system-settings-card-ts"><i class="bi bi-clock"></i> <%= GetUpdated("CONFIG010") %></span><div class="ad-system-settings-card-btns"><a class="ad-system-settings-cbtn ad-system-settings-cbtn-reset" onclick="resetCard(this)" href="javascript:;"><i class="bi bi-arrow-counterclockwise"></i> Reset</a><a class="ad-system-settings-cbtn ad-system-settings-cbtn-save cat-sec" onclick="saveCard('CONFIG010')" href="javascript:;"><i class="bi bi-floppy"></i> <%= T("Save", "Simpan") %></a></div></div>
        </div>
        <!-- CONFIG011 -->
        <div class="ad-system-settings-card cat-sec" data-id="CONFIG011" data-search="account lock duration minutes tempoh kunci akaun minit">
            <div class="ad-system-settings-card-top"><div class="ad-system-settings-card-icon" style="background:var(--ad-system-settings-sec-light);color:var(--ad-system-settings-sec);"><i class="bi bi-lock-fill"></i></div><div class="ad-system-settings-card-info"><div class="ad-system-settings-card-name"><%= T("Account Lock Duration", "Tempoh Kunci Akaun") %></div><div class="ad-system-settings-card-desc"><%= T("How long an account remains locked after exceeding attempts.", "Berapa lama akaun dikunci selepas melebihi percubaan.") %></div></div></div>
            <div class="ad-system-settings-card-value"><input type="number" id="val_CONFIG011" value="<%= GetVal("CONFIG011") %>" data-orig="<%= GetVal("CONFIG011") %>" oninput="detectChange(this)" min="1" /><span class="ad-system-settings-card-unit"><%= T("Minutes", "Minit") %></span></div>
            <div class="ad-system-settings-card-bottom"><span class="ad-system-settings-card-ts"><i class="bi bi-clock"></i> <%= GetUpdated("CONFIG011") %></span><div class="ad-system-settings-card-btns"><a class="ad-system-settings-cbtn ad-system-settings-cbtn-reset" onclick="resetCard(this)" href="javascript:;"><i class="bi bi-arrow-counterclockwise"></i> Reset</a><a class="ad-system-settings-cbtn ad-system-settings-cbtn-save cat-sec" onclick="saveCard('CONFIG011')" href="javascript:;"><i class="bi bi-floppy"></i> <%= T("Save", "Simpan") %></a></div></div>
        </div>
        <!-- CONFIG012 -->
        <div class="ad-system-settings-card cat-sec" data-id="CONFIG012" data-search="password minimum length panjang minimum kata laluan characters aksara">
            <div class="ad-system-settings-card-top"><div class="ad-system-settings-card-icon" style="background:var(--ad-system-settings-sec-light);color:var(--ad-system-settings-sec);"><i class="bi bi-key-fill"></i></div><div class="ad-system-settings-card-info"><div class="ad-system-settings-card-name"><%= T("Password Minimum Length", "Panjang Minimum Kata Laluan") %></div><div class="ad-system-settings-card-desc"><%= T("Minimum characters required for user passwords.", "Bilangan minimum aksara untuk kata laluan pengguna.") %></div></div></div>
            <div class="ad-system-settings-card-value"><input type="number" id="val_CONFIG012" value="<%= GetVal("CONFIG012") %>" data-orig="<%= GetVal("CONFIG012") %>" oninput="detectChange(this)" min="1" /><span class="ad-system-settings-card-unit"><%= T("Characters", "Aksara") %></span></div>
            <div class="ad-system-settings-card-bottom"><span class="ad-system-settings-card-ts"><i class="bi bi-clock"></i> <%= GetUpdated("CONFIG012") %></span><div class="ad-system-settings-card-btns"><a class="ad-system-settings-cbtn ad-system-settings-cbtn-reset" onclick="resetCard(this)" href="javascript:;"><i class="bi bi-arrow-counterclockwise"></i> Reset</a><a class="ad-system-settings-cbtn ad-system-settings-cbtn-save cat-sec" onclick="saveCard('CONFIG012')" href="javascript:;"><i class="bi bi-floppy"></i> <%= T("Save", "Simpan") %></a></div></div>
        </div>
    </div>
</div>

<!-- ═══════ GAMIFICATION SETTINGS SECTION ═══════ -->
<div class="ad-system-settings-section" data-section="gam">
    <div class="ad-system-settings-sec-hdr cat-gam" onclick="toggleSec(this)">
        <div class="ad-system-settings-sec-ico"><i class="bi bi-trophy-fill"></i></div>
        <div class="ad-system-settings-sec-title"><%= T("Gamification Settings", "Tetapan Gamifikasi") %></div>
        <span class="ad-system-settings-sec-count"><%= T("1 setting", "1 tetapan") %></span>
        <i class="bi bi-chevron-down ad-system-settings-sec-arrow"></i>
    </div>
    <div class="ad-system-settings-sec-body">
        <!-- CONFIG006 -->
        <div class="ad-system-settings-card cat-gam" data-id="CONFIG006" data-search="leaderboard top count bilangan teratas papan markah students pelajar">
            <div class="ad-system-settings-card-top"><div class="ad-system-settings-card-icon" style="background:var(--ad-system-settings-gam-light);color:var(--ad-system-settings-gam);"><i class="bi bi-bar-chart-fill"></i></div><div class="ad-system-settings-card-info"><div class="ad-system-settings-card-name"><%= T("Leaderboard Top Count", "Bilangan Teratas Papan Markah") %></div><div class="ad-system-settings-card-desc"><%= T("Number of top students shown on the leaderboard.", "Bilangan pelajar teratas di papan markah.") %></div></div></div>
            <div class="ad-system-settings-card-value"><input type="number" id="val_CONFIG006" value="<%= GetVal("CONFIG006") %>" data-orig="<%= GetVal("CONFIG006") %>" oninput="detectChange(this)" min="1" /><span class="ad-system-settings-card-unit"><%= T("Students", "Pelajar") %></span></div>
            <div class="ad-system-settings-card-bottom"><span class="ad-system-settings-card-ts"><i class="bi bi-clock"></i> <%= GetUpdated("CONFIG006") %></span><div class="ad-system-settings-card-btns"><a class="ad-system-settings-cbtn ad-system-settings-cbtn-reset" onclick="resetCard(this)" href="javascript:;"><i class="bi bi-arrow-counterclockwise"></i> Reset</a><a class="ad-system-settings-cbtn ad-system-settings-cbtn-save cat-gam" onclick="saveCard('CONFIG006')" href="javascript:;"><i class="bi bi-floppy"></i> <%= T("Save", "Simpan") %></a></div></div>
        </div>
    </div>
</div>

<!-- ═══════ LIVE SESSION SETTINGS SECTION ═══════ -->
<div class="ad-system-settings-section" data-section="live">
    <div class="ad-system-settings-sec-hdr cat-live" onclick="toggleSec(this)">
        <div class="ad-system-settings-sec-ico"><i class="bi bi-camera-video-fill"></i></div>
        <div class="ad-system-settings-sec-title"><%= T("Live Session Settings", "Tetapan Sesi Langsung") %></div>
        <span class="ad-system-settings-sec-count"><%= T("2 settings", "2 tetapan") %></span>
        <i class="bi bi-chevron-down ad-system-settings-sec-arrow"></i>
    </div>
    <div class="ad-system-settings-sec-body">
        <!-- CONFIG013 -->
        <div class="ad-system-settings-card cat-live" data-id="CONFIG013" data-search="maximum students per session maksimum pelajar setiap sesi">
            <div class="ad-system-settings-card-top"><div class="ad-system-settings-card-icon" style="background:var(--ad-system-settings-live-light);color:var(--ad-system-settings-live);"><i class="bi bi-people-fill"></i></div><div class="ad-system-settings-card-info"><div class="ad-system-settings-card-name"><%= T("Maximum Students Per Session", "Maksimum Pelajar Setiap Sesi") %></div><div class="ad-system-settings-card-desc"><%= T("Maximum students allowed in a live consultation session.", "Bilangan maksimum pelajar dalam sesi konsultasi langsung.") %></div></div></div>
            <div class="ad-system-settings-card-value"><input type="number" id="val_CONFIG013" value="<%= GetVal("CONFIG013") %>" data-orig="<%= GetVal("CONFIG013") %>" oninput="detectChange(this)" min="1" /><span class="ad-system-settings-card-unit"><%= T("Students", "Pelajar") %></span></div>
            <div class="ad-system-settings-card-bottom"><span class="ad-system-settings-card-ts"><i class="bi bi-clock"></i> <%= GetUpdated("CONFIG013") %></span><div class="ad-system-settings-card-btns"><a class="ad-system-settings-cbtn ad-system-settings-cbtn-reset" onclick="resetCard(this)" href="javascript:;"><i class="bi bi-arrow-counterclockwise"></i> Reset</a><a class="ad-system-settings-cbtn ad-system-settings-cbtn-save cat-live" onclick="saveCard('CONFIG013')" href="javascript:;"><i class="bi bi-floppy"></i> <%= T("Save", "Simpan") %></a></div></div>
        </div>
        <!-- CONFIG014 -->
        <div class="ad-system-settings-card cat-live" data-id="CONFIG014" data-search="consultation session duration minutes tempoh sesi konsultasi minit">
            <div class="ad-system-settings-card-top"><div class="ad-system-settings-card-icon" style="background:var(--ad-system-settings-live-light);color:var(--ad-system-settings-live);"><i class="bi bi-hourglass-split"></i></div><div class="ad-system-settings-card-info"><div class="ad-system-settings-card-name"><%= T("Consultation Session Duration", "Tempoh Sesi Konsultasi") %></div><div class="ad-system-settings-card-desc"><%= T("Default duration for each live consultation session.", "Tempoh lalai untuk setiap sesi konsultasi langsung.") %></div></div></div>
            <div class="ad-system-settings-card-value"><input type="number" id="val_CONFIG014" value="<%= GetVal("CONFIG014") %>" data-orig="<%= GetVal("CONFIG014") %>" oninput="detectChange(this)" min="1" /><span class="ad-system-settings-card-unit"><%= T("Minutes", "Minit") %></span></div>
            <div class="ad-system-settings-card-bottom"><span class="ad-system-settings-card-ts"><i class="bi bi-clock"></i> <%= GetUpdated("CONFIG014") %></span><div class="ad-system-settings-card-btns"><a class="ad-system-settings-cbtn ad-system-settings-cbtn-reset" onclick="resetCard(this)" href="javascript:;"><i class="bi bi-arrow-counterclockwise"></i> Reset</a><a class="ad-system-settings-cbtn ad-system-settings-cbtn-save cat-live" onclick="saveCard('CONFIG014')" href="javascript:;"><i class="bi bi-floppy"></i> <%= T("Save", "Simpan") %></a></div></div>
        </div>
    </div>
</div>

<!-- ═══════ JAVASCRIPT ═══════ -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>
// ── Collapse / Expand ──
function toggleSec(hdr) {
    var body = hdr.nextElementSibling;
    var arrow = hdr.querySelector('.ad-system-settings-sec-arrow');
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
    var card = input.closest('.ad-system-settings-card');
    if (input.value !== input.getAttribute('data-orig')) {
        card.classList.add('changed');
    } else {
        card.classList.remove('changed');
    }
}

// ── Reset ──
function resetCard(btn) {
    var card = btn.closest('.ad-system-settings-card');
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
    var card = input.closest('.ad-system-settings-card');
    var saveBtn = card.querySelector('.ad-system-settings-cbtn-save');
    saveBtn.classList.add('saving');
    saveBtn.innerHTML = '<i class="bi bi-arrow-repeat ad-system-settings-spin"></i> Saving...';

    // Use PageMethods (WebMethod) via fetch
    var formData = new FormData();
    formData.append('configId', configId);
    formData.append('newValue', newVal);

    fetch(window.location.pathname + (window.location.pathname.indexOf('.aspx') === -1 ? '.aspx' : '') + '?handler=SaveConfig&configId=' + encodeURIComponent(configId) + '&newValue=' + encodeURIComponent(newVal), {
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
            var tsEl = card.querySelector('.ad-system-settings-card-ts');
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
    var cards = document.querySelectorAll('.ad-system-settings-card');
    var sections = document.querySelectorAll('.ad-system-settings-section');
    var visibleCount = 0;

    cards.forEach(function(card) {
        var search = card.getAttribute('data-search') || '';
        var name = card.querySelector('.ad-system-settings-card-name').textContent.toLowerCase();
        var matchSearch = !q || search.indexOf(q) !== -1 || name.indexOf(q) !== -1;
        var sec = card.closest('.ad-system-settings-section');
        var matchCat = activeCat === 'all' || sec.getAttribute('data-section') === activeCat;
        if (matchSearch && matchCat) { card.style.display = ''; visibleCount++; }
        else { card.style.display = 'none'; }
    });

    // Show/hide sections that have no visible cards
    sections.forEach(function(sec) {
        var visCards = sec.querySelectorAll('.ad-system-settings-card:not([style*="display: none"])');
        if (visCards.length === 0) { sec.style.display = 'none'; }
        else { sec.style.display = ''; }
    });

    var emptyEl = document.getElementById('ssEmpty');
    if (visibleCount === 0) { emptyEl.classList.add('visible'); }
    else { emptyEl.classList.remove('visible'); }
}

function filterCat(chip) {
    document.querySelectorAll('.ad-system-settings-chip').forEach(function(c) { c.classList.remove('active'); });
    chip.classList.add('active');
    activeCat = chip.getAttribute('data-cat');
    filterSettings();
}

// ── Init sections expanded ──
window.addEventListener('load', function() {
    document.querySelectorAll('.ad-system-settings-sec-body').forEach(function(body) {
        body.style.maxHeight = body.scrollHeight + 'px';
        body.style.opacity = '1';
    });
});
</script>

</asp:Content>
