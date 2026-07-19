<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="ScienceBuddy.Admin.Dashboard" MasterPageFile="~/Site.Master" Title="Admin Dashboard" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Admin.css") %>" rel="stylesheet" />
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" />
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="<%: ResolveUrl("~/Scripts/admin-signout.js") %>"></script>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
<div class="sb-nav-section"><div class="sb-nav-section-label">Main</div><a href="<%: ResolveUrl("~/Admin/Dashboard.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label">Dashboard</span></a></div>
<div class="sb-nav-section"><div class="sb-nav-section-label">User Management</div><a href="<%: ResolveUrl("~/Admin/StudentManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-people item-icon"></i><span class="item-label">Students</span></a><a href="<%: ResolveUrl("~/Admin/ParentManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-heart item-icon"></i><span class="item-label">Parents</span></a><a href="<%: ResolveUrl("~/Admin/TeacherManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-badge item-icon"></i><span class="item-label">Teachers</span></a><a href="<%: ResolveUrl("~/Admin/TeacherCertificateApproval.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-check item-icon"></i><span class="item-label">Teacher Certificate Approval</span></a></div>
<div class="sb-nav-section"><div class="sb-nav-section-label">Learning Content</div><a href="<%: ResolveUrl("~/Admin/LessonManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label">Lessons</span></a><a href="<%: ResolveUrl("~/Admin/QuizManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label">Quizzes</span></a><a href="<%: ResolveUrl("~/Admin/QuestionBank.aspx") %>" class="sb-sidebar-item"><i class="bi bi-question-circle item-icon"></i><span class="item-label">Question Bank</span></a><a href="<%: ResolveUrl("~/Admin/TeacherMaterials.aspx") %>" class="sb-sidebar-item"><i class="bi bi-file-earmark-text item-icon"></i><span class="item-label">Material Requests</span></a><a href="<%: ResolveUrl("~/Admin/LiveSessions.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label">Live Sessions</span></a><a href="<%: ResolveUrl("~/Admin/QuestionRequests.aspx") %>" class="sb-sidebar-item"><i class="bi bi-clipboard-check item-icon"></i><span class="item-label">Question Requests</span></a><a href="<%: ResolveUrl("~/Admin/CertificateManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-award item-icon"></i><span class="item-label">Certificates</span></a></div>
<div class="sb-nav-section"><div class="sb-nav-section-label">Community</div><a href="<%: ResolveUrl("~/Admin/ForumDiscussions.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label">Forum Discussions</span></a></div>
<div class="sb-nav-section"><div class="sb-nav-section-label">Gamification</div><a href="<%: ResolveUrl("~/Admin/GamificationManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-trophy item-icon"></i><span class="item-label">Student Performance</span></a></div>
<div class="sb-nav-section"><div class="sb-nav-section-label">Configuration</div><a href="<%: ResolveUrl("~/Admin/SystemSettings.aspx") %>" class="sb-sidebar-item"><i class="bi bi-gear item-icon"></i><span class="item-label">System Settings</span></a></div>
<div class="sb-nav-section"><div class="sb-nav-section-label">Logs</div><a href="<%: ResolveUrl("~/Admin/SystemActivityLogs.aspx") %>" class="sb-sidebar-item"><i class="bi bi-clock-history item-icon"></i><span class="item-label">Activity Logs</span></a><a href="<%: ResolveUrl("~/Admin/LoginLogs.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-in-right item-icon"></i><span class="item-label">Login Logs</span></a><a href="<%: ResolveUrl("~/Admin/SuspiciousLogins.aspx") %>" class="sb-sidebar-item"><i class="bi bi-exclamation-triangle item-icon"></i><span class="item-label">Suspicious Logins</span></a></div>
<div class="sb-nav-section"><div class="sb-nav-section-label">Account</div><a href="<%: ResolveUrl("~/Admin/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span></a><a href="<%: ResolveUrl("~/Admin/Profile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a><a href="javascript:;" class="sb-sidebar-item" onclick="showSignOutModal()"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a></div>
</asp:Content>
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">Admin Dashboard</asp:Content>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<!-- ------------------- HERO SECTION ------------------- -->
<div class="ad-dashboard-hero">
    <!-- Background particles -->
    <div class="ad-dashboard-hero-particle"></div>
    <div class="ad-dashboard-hero-particle"></div>
    <div class="ad-dashboard-hero-particle"></div>
    <div class="ad-dashboard-hero-particle"></div>
    <div class="ad-dashboard-hero-particle"></div>
    <!-- Animated blobs -->
    <div class="ad-dashboard-hero-blob1"></div>
    <div class="ad-dashboard-hero-blob2"></div>
    <div class="ad-dashboard-hero-blob3"></div>

    <div class="ad-dashboard-hero-body">
        <!-- LEFT SIDE -->
        <div class="ad-dashboard-hero-left">
            <div class="ad-dashboard-hero-eyebrow"><i class="bi bi-shield-check"></i> <%= T("Administrator Console", "Konsol Pentadbir") %></div>
            <div class="ad-dashboard-hero-title"><%= T("Welcome back,", "Selamat kembali,") %> <asp:Literal ID="litAdminName" runat="server" Text="Admin" />!</div>
            <div class="ad-dashboard-hero-sub"><%= T("Manage users, monitor learning content, and keep ScienceBuddy running smoothly from your control center.", "Urus pengguna, pantau kandungan pembelajaran, dan pastikan ScienceBuddy berjalan lancar dari pusat kawalan anda.") %></div>

            <!-- Status Pills -->
            <div class="ad-dashboard-hero-pills">
                <span class="ad-dashboard-hero-pill"><i class="bi bi-calendar3"></i> <asp:Literal ID="litDate" runat="server" /></span>
                <span class="ad-dashboard-hero-pill"><i class="bi bi-hourglass-split"></i> <asp:Literal ID="litPendingRequests" runat="server" Text="0" /> <%= T("Pending Reviews", "Semakan Tertunggak") %></span>
                <span class="ad-dashboard-hero-pill"><span class="ad-dashboard-pill-dot"></span> <%= T("Database Connected", "Pangkalan Data Aktif") %></span>
                <span class="ad-dashboard-hero-pill"><span class="ad-dashboard-pill-dot"></span> <%= T("Notifications Active", "Notifikasi Aktif") %></span>
                <span class="ad-dashboard-hero-pill"><span class="ad-dashboard-pill-dot"></span> <%= T("System Healthy", "Sistem Sihat") %></span>
            </div>

            <!-- Hero Buttons -->
            <div class="ad-dashboard-hero-actions">
                <a href="<%: ResolveUrl("~/Admin/QuestionRequests.aspx") %>" class="ad-dashboard-hero-btn primary"><i class="bi bi-clipboard-check"></i> <%= T("Review Requests", "Semak Permintaan") %></a>
                <a href="<%: ResolveUrl("~/Admin/StudentManagement.aspx") %>" class="ad-dashboard-hero-btn"><i class="bi bi-people"></i> <%= T("Manage Users", "Urus Pengguna") %></a>
                <a href="<%: ResolveUrl("~/Admin/SystemSettings.aspx") %>" class="ad-dashboard-hero-btn"><i class="bi bi-gear"></i> <%= T("System Settings", "Tetapan Sistem") %></a>
            </div>
        </div>

        <!-- RIGHT SIDE � Mascot -->
        <div class="ad-dashboard-hero-right">
            <div class="ad-dashboard-mascot-circle"></div>
            <div class="ad-dashboard-mascot-circle"></div>
            <div class="ad-dashboard-mascot-circle"></div>
            <div class="ad-dashboard-mascot-circle"></div>
            <div class="ad-dashboard-hero-mascot-wrap">
                <div class="ad-dashboard-hero-mascot-breathe">
                    <img src="<%: ResolveUrl("~/Images/Personality/admin.png") %>" alt="ScienceBuddy Assistant" class="ad-dashboard-hero-mascot" />
                </div>
            </div>
        </div>
    </div>
</div>

<!-- ------------------- PLATFORM SNAPSHOT ------------------- -->
<div class="ad-dashboard-snapshot">
    <div class="ad-dashboard-snapshot-header">
        <div class="ad-dashboard-snapshot-title"><i class="bi bi-bar-chart-line-fill" style="color:var(--ad-dashboard);"></i> <%= T("Platform Snapshot", "Gambaran Platform") %></div>
        <div class="ad-dashboard-snapshot-subtitle"><%= T("Live overview of the ScienceBuddy platform.", "Gambaran langsung platform ScienceBuddy.") %></div>
    </div>
    <div class="ad-dashboard-snapshot-grid">
        <!-- Users -->
        <div class="ad-dashboard-snap-group">
            <div class="ad-dashboard-snap-group-header">
                <div class="ad-dashboard-snap-group-ico" style="background:#DBEAFE;color:#2563EB;"><i class="bi bi-people-fill"></i></div>
                <div class="ad-dashboard-snap-group-title"><%= T("Users", "Pengguna") %></div>
            </div>
            <div class="ad-dashboard-snap-items">
                <div class="ad-dashboard-snap-item"><span class="ad-dashboard-snap-item-label"><%= T("Students", "Pelajar") %></span><span class="ad-dashboard-snap-item-value"><asp:Literal ID="litStudents" runat="server" Text="0" /></span></div>
                <div class="ad-dashboard-snap-item"><span class="ad-dashboard-snap-item-label"><%= T("Parents", "Ibu Bapa") %></span><span class="ad-dashboard-snap-item-value"><asp:Literal ID="litParents" runat="server" Text="0" /></span></div>
                <div class="ad-dashboard-snap-item"><span class="ad-dashboard-snap-item-label"><%= T("Teachers", "Guru") %></span><span class="ad-dashboard-snap-item-value"><asp:Literal ID="litTeachers" runat="server" Text="0" /></span></div>
            </div>
        </div>
        <!-- Learning Content -->
        <div class="ad-dashboard-snap-group">
            <div class="ad-dashboard-snap-group-header">
                <div class="ad-dashboard-snap-group-ico" style="background:#D1FAE5;color:#059669;"><i class="bi bi-collection-fill"></i></div>
                <div class="ad-dashboard-snap-group-title"><%= T("Learning Content", "Kandungan Pembelajaran") %></div>
            </div>
            <div class="ad-dashboard-snap-items">
                <div class="ad-dashboard-snap-item"><span class="ad-dashboard-snap-item-label"><%= T("Lessons", "Pelajaran") %></span><span class="ad-dashboard-snap-item-value"><asp:Literal ID="litLessons" runat="server" Text="0" /></span></div>
                <div class="ad-dashboard-snap-item"><span class="ad-dashboard-snap-item-label"><%= T("Quizzes", "Kuiz") %></span><span class="ad-dashboard-snap-item-value"><asp:Literal ID="litQuizzes" runat="server" Text="0" /></span></div>
                <div class="ad-dashboard-snap-item"><span class="ad-dashboard-snap-item-label"><%= T("Question Bank", "Bank Soalan") %></span><span class="ad-dashboard-snap-item-value"><asp:Literal ID="litQuestions" runat="server" Text="0" /></span></div>
                <div class="ad-dashboard-snap-item"><span class="ad-dashboard-snap-item-label"><%= T("Materials", "Bahan") %></span><span class="ad-dashboard-snap-item-value"><asp:Literal ID="litMaterials" runat="server" Text="0" /></span></div>
            </div>
        </div>
        <!-- Pending Reviews -->
        <div class="ad-dashboard-snap-group">
            <div class="ad-dashboard-snap-group-header">
                <div class="ad-dashboard-snap-group-ico" style="background:#FEF3C7;color:#D97706;"><i class="bi bi-hourglass-split"></i></div>
                <div class="ad-dashboard-snap-group-title"><%= T("Pending Reviews", "Semakan Tertunggak") %></div>
            </div>
            <div class="ad-dashboard-snap-items">
                <div class="ad-dashboard-snap-item"><span class="ad-dashboard-snap-item-label"><%= T("Questions", "Soalan") %></span><span class="ad-dashboard-snap-item-value"><asp:Literal ID="litPendingQ" runat="server" Text="0" /></span></div>
                <div class="ad-dashboard-snap-item"><span class="ad-dashboard-snap-item-label"><%= T("Materials", "Bahan") %></span><span class="ad-dashboard-snap-item-value"><asp:Literal ID="litPendingM" runat="server" Text="0" /></span></div>
                <div class="ad-dashboard-snap-item"><span class="ad-dashboard-snap-item-label"><%= T("Forum Reports", "Laporan Forum") %></span><span class="ad-dashboard-snap-item-value"><asp:Literal ID="litForumReports" runat="server" Text="0" /></span></div>
            </div>
        </div>
        <!-- Platform Status -->
        <div class="ad-dashboard-snap-group">
            <div class="ad-dashboard-snap-group-header">
                <div class="ad-dashboard-snap-group-ico" style="background:#D1FAE5;color:#059669;"><i class="bi bi-shield-check"></i></div>
                <div class="ad-dashboard-snap-group-title"><%= T("Platform Status", "Status Platform") %></div>
            </div>
            <div class="ad-dashboard-snap-items">
                <div class="ad-dashboard-snap-item"><span class="ad-dashboard-snap-item-label"><%= T("Database", "Pangkalan Data") %></span><span class="ad-dashboard-snap-item-pill"><span class="ad-dashboard-snap-dot"></span> <%= T("Healthy", "Sihat") %></span></div>
                <div class="ad-dashboard-snap-item"><span class="ad-dashboard-snap-item-label"><%= T("Notifications", "Notifikasi") %></span><span class="ad-dashboard-snap-item-pill"><span class="ad-dashboard-snap-dot"></span> <%= T("Healthy", "Sihat") %></span></div>
                <div class="ad-dashboard-snap-item"><span class="ad-dashboard-snap-item-label"><%= T("Authentication", "Pengesahan") %></span><span class="ad-dashboard-snap-item-pill"><span class="ad-dashboard-snap-dot"></span> <%= T("Healthy", "Sihat") %></span></div>
                <div class="ad-dashboard-snap-item"><span class="ad-dashboard-snap-item-label"><%= T("Last Backup", "Sandaran Terakhir") %></span><span class="ad-dashboard-snap-item-value" style="font-size:.78rem;"><%= T("Today 2:00 AM", "Hari ini 2:00 AM") %></span></div>
            </div>
        </div>
        <!-- Recycle Bin -->
        <div class="ad-dashboard-snap-group" style="cursor:pointer;" onclick="window.location.href='<%: ResolveUrl("~/Admin/RecycleBin.aspx") %>'">
            <div class="ad-dashboard-snap-group-header">
                <div class="ad-dashboard-snap-group-ico" style="background:#FEE2E2;color:#DC2626;"><i class="bi bi-trash3-fill"></i></div>
                <div class="ad-dashboard-snap-group-title"><%= T("Recycle Bin", "Tong Kitar Semula") %></div>
            </div>
            <div class="ad-dashboard-snap-items">
                <div class="ad-dashboard-snap-item"><span class="ad-dashboard-snap-item-label"><%= T("Deleted Accounts", "Akaun Dipadam") %></span><span class="ad-dashboard-snap-item-value"><asp:Literal ID="litDeletedAccounts" runat="server" Text="0" /></span></div>
            </div>
        </div>
    </div>
</div>

<!-- ------------------- ADMINISTRATOR WORKSPACE ------------------- -->
<div class="ad-dashboard-workspace">
    <div class="ad-dashboard-workspace-header">
        <div class="ad-dashboard-workspace-title"><i class="bi bi-grid-1x2-fill" style="color:var(--ad-dashboard);"></i> <%= T("Administrator Workspace", "Ruang Kerja Pentadbir") %></div>
        <div class="ad-dashboard-workspace-subtitle"><%= T("The tools you use most frequently.", "Alat yang paling kerap anda gunakan.") %></div>
    </div>
    <div class="ad-dashboard-workspace-grid">
        <a href="<%: ResolveUrl("~/Admin/StudentManagement.aspx") %>" class="ad-dashboard-ws-card">
            <div class="ad-dashboard-ws-card-ico" style="background:#DBEAFE;color:#2563EB;"><i class="bi bi-people-fill"></i></div>
            <div class="ad-dashboard-ws-card-body">
                <div class="ad-dashboard-ws-card-title"><%= T("User Management", "Pengurusan Pengguna") %></div>
                <div class="ad-dashboard-ws-card-desc"><%= T("Manage students, parents & teachers", "Urus pelajar, ibu bapa & guru") %></div>
            </div>
            <div class="ad-dashboard-ws-card-arrow"><i class="bi bi-arrow-right"></i></div>
        </a>
        <a href="<%: ResolveUrl("~/Admin/LessonManagement.aspx") %>" class="ad-dashboard-ws-card">
            <div class="ad-dashboard-ws-card-ico" style="background:#D1FAE5;color:#059669;"><i class="bi bi-collection-fill"></i></div>
            <div class="ad-dashboard-ws-card-body">
                <div class="ad-dashboard-ws-card-title"><%= T("Learning Content", "Kandungan Pembelajaran") %></div>
                <div class="ad-dashboard-ws-card-desc"><%= T("Lessons, quizzes & question bank", "Pelajaran, kuiz & bank soalan") %></div>
            </div>
            <div class="ad-dashboard-ws-card-arrow"><i class="bi bi-arrow-right"></i></div>
        </a>
        <a href="<%: ResolveUrl("~/Admin/QuestionRequests.aspx") %>" class="ad-dashboard-ws-card">
            <div class="ad-dashboard-ws-card-ico" style="background:#FEF3C7;color:#D97706;"><i class="bi bi-clipboard-check-fill"></i></div>
            <div class="ad-dashboard-ws-card-body">
                <div class="ad-dashboard-ws-card-title"><%= T("Review Requests", "Semak Permintaan") %></div>
                <div class="ad-dashboard-ws-card-desc"><%= T("Approve pending questions & materials", "Luluskan soalan & bahan tertunggak") %></div>
            </div>
            <div class="ad-dashboard-ws-card-arrow"><i class="bi bi-arrow-right"></i></div>
        </a>
        <a href="<%: ResolveUrl("~/Admin/ForumDiscussions.aspx") %>" class="ad-dashboard-ws-card">
            <div class="ad-dashboard-ws-card-ico" style="background:#EDE9FE;color:#7C3AED;"><i class="bi bi-chat-dots-fill"></i></div>
            <div class="ad-dashboard-ws-card-body">
                <div class="ad-dashboard-ws-card-title"><%= T("Forum Moderation", "Moderasi Forum") %></div>
                <div class="ad-dashboard-ws-card-desc"><%= T("Monitor discussions and reported posts", "Pantau perbincangan dan pos dilaporkan") %></div>
            </div>
            <div class="ad-dashboard-ws-card-arrow"><i class="bi bi-arrow-right"></i></div>
        </a>
        <a href="<%: ResolveUrl("~/Admin/Notifications.aspx") %>" class="ad-dashboard-ws-card">
            <div class="ad-dashboard-ws-card-ico" style="background:#FCE7F3;color:#DB2777;"><i class="bi bi-bell-fill"></i></div>
            <div class="ad-dashboard-ws-card-body">
                <div class="ad-dashboard-ws-card-title"><%= T("Notifications", "Notifikasi") %></div>
                <div class="ad-dashboard-ws-card-desc"><%= T("Send platform announcements", "Hantar pengumuman platform") %></div>
            </div>
            <div class="ad-dashboard-ws-card-arrow"><i class="bi bi-arrow-right"></i></div>
        </a>
        <a href="<%: ResolveUrl("~/Admin/SystemSettings.aspx") %>" class="ad-dashboard-ws-card">
            <div class="ad-dashboard-ws-card-ico" style="background:#F0F9FF;color:#0284C7;"><i class="bi bi-gear-fill"></i></div>
            <div class="ad-dashboard-ws-card-body">
                <div class="ad-dashboard-ws-card-title"><%= T("System Settings", "Tetapan Sistem") %></div>
                <div class="ad-dashboard-ws-card-desc"><%= T("Configure ScienceBuddy settings", "Konfigurasi tetapan ScienceBuddy") %></div>
            </div>
            <div class="ad-dashboard-ws-card-arrow"><i class="bi bi-arrow-right"></i></div>
        </a>
    </div>
</div>

<!-- ------------------- ACTIVITY + PENDING REVIEWS ------------------- -->
<div class="ad-dashboard-row2">
    <!-- Recent Activity Timeline -->
    <div class="ad-dashboard-section">
        <div class="ad-dashboard-sec-hdr">
            <div class="ad-dashboard-sec-title"><i class="bi bi-clock-history" style="color:#7C3AED;"></i> <%= T("Recent Activity","Aktiviti Terkini") %></div>
            <a href="<%: ResolveUrl("~/Admin/SystemActivityLogs.aspx") %>" class="ad-dashboard-link-btn"><%= T("View All","Lihat Semua") %> <i class="bi bi-arrow-right"></i></a>
        </div>
        <div class="ad-dashboard-sec-body">
            <asp:Panel ID="pnlLogs" runat="server" Visible="false">
                <div class="ad-dashboard-timeline">
                    <asp:Repeater ID="rptLogs" runat="server">
                        <ItemTemplate>
                            <div class="ad-dashboard-timeline-item">
                                <div class='ad-dashboard-timeline-dot <%# Eval("dotColor") %>'></div>
                                <div class="ad-dashboard-timeline-body">
                                    <div class="ad-dashboard-timeline-action"><%# Eval("action") %></div>
                                    <div class="ad-dashboard-timeline-desc"><%# Eval("description") %></div>
                                    <div class="ad-dashboard-timeline-time"><i class="bi bi-person"></i> <%# Eval("username") %> &middot; <%# Eval("timeAgo") %></div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </asp:Panel>
            <asp:Panel ID="pnlLogsEmpty" runat="server">
                <div class="ad-dashboard-empty"><i class="bi bi-clock-history"></i><div class="ad-dashboard-empty-msg"><%= T("No recent activity.","Tiada aktiviti terkini.") %></div></div>
            </asp:Panel>
        </div>
    </div>

    <!-- Pending Reviews Table -->
    <div class="ad-dashboard-section">
        <div class="ad-dashboard-sec-hdr">
            <div class="ad-dashboard-sec-title"><i class="bi bi-hourglass-split" style="color:#D97706;"></i> <%= T("Pending Reviews","Semakan Tertunggak") %></div>
            <a href="<%: ResolveUrl("~/Admin/QuestionRequests.aspx") %>" class="ad-dashboard-link-btn"><%= T("View All","Lihat Semua") %> <i class="bi bi-arrow-right"></i></a>
        </div>
        <div class="ad-dashboard-sec-body">
            <asp:Panel ID="pnlRequests" runat="server" Visible="false">
                <table class="ad-dashboard-review-table">
                    <thead><tr><th><%= T("Type","Jenis") %></th><th><%= T("Submitted By","Dihantar Oleh") %></th><th><%= T("Date","Tarikh") %></th><th><%= T("Priority","Keutamaan") %></th><th></th></tr></thead>
                    <tbody>
                        <asp:Repeater ID="rptRequests" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td><span class='ad-dashboard-review-badge type-<%# Eval("badgeType") %>'><%# Eval("requestType") %></span></td>
                                    <td style="font-weight:600;"><%# Eval("requestedBy") %></td>
                                    <td style="color:var(--color-text-muted,#94a3b8);"><%# Eval("requestedDate") %></td>
                                    <td><span class='ad-dashboard-review-badge priority-<%# Eval("priority") %>'><%# Eval("priorityLabel") %></span></td>
                                    <td><a href="<%: ResolveUrl("~/Admin/QuestionRequests.aspx") %>" class="ad-dashboard-review-btn"><%= T("Review","Semak") %> <i class="bi bi-arrow-right"></i></a></td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </asp:Panel>
            <asp:Panel ID="pnlRequestsEmpty" runat="server">
                <div class="ad-dashboard-empty"><i class="bi bi-check-circle" style="color:#059669;"></i><div class="ad-dashboard-empty-msg"><%= T("No pending reviews. All caught up!","Tiada semakan tertunggak. Semuanya selesai!") %></div></div>
            </asp:Panel>
        </div>
    </div>
</div>

<!-- ------------------- NOTIFICATIONS ------------------- -->
<div class="ad-dashboard-section" style="margin-bottom:32px;">
    <div class="ad-dashboard-sec-hdr">
        <div class="ad-dashboard-sec-title"><i class="bi bi-bell-fill" style="color:#DC2626;"></i> <%= T("Recent Notifications","Notifikasi Terkini") %></div>
        <a href="<%: ResolveUrl("~/Admin/Notifications.aspx") %>" class="ad-dashboard-link-btn"><%= T("View All","Lihat Semua") %> <i class="bi bi-arrow-right"></i></a>
    </div>
    <div class="ad-dashboard-sec-body">
        <asp:Panel ID="pnlNotifs" runat="server" Visible="false">
            <asp:Repeater ID="rptNotifs" runat="server">
                <ItemTemplate>
                    <div class="ad-dashboard-notif">
                        <div class='ad-dashboard-notif-dot <%# Convert.ToBoolean(Eval("isRead")) ? "read" : "" %>'></div>
                        <div class="ad-dashboard-notif-body">
                            <div class="ad-dashboard-notif-title"><%# Eval("title") %></div>
                            <div class="ad-dashboard-notif-msg"><%# Eval("message") %></div>
                            <div class="ad-dashboard-notif-time"><i class="bi bi-clock"></i> <%# Eval("timeAgo") %></div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </asp:Panel>
        <asp:Panel ID="pnlNotifsEmpty" runat="server">
            <div class="ad-dashboard-empty"><i class="bi bi-bell-slash"></i><div class="ad-dashboard-empty-msg"><%= T("No notifications.","Tiada notifikasi.") %></div></div>
        </asp:Panel>
    </div>
</div>


</asp:Content>
