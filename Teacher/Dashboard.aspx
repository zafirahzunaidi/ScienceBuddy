<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs"
    Inherits="ScienceBuddy.Teacher.Dashboard" MasterPageFile="~/Site.Master"
    Title="Teacher Dashboard" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Teacher.css") %>" rel="stylesheet" />
</asp:Content>

<%-- ---- SIDEBAR MENU ---- --%>
<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label"><%: T("Notifications","Notifikasi") %></span></a></div>
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

<%-- ---- MAIN CONTENT ---- --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- Status panels for non-certified teachers --%>
<asp:Panel ID="pnlPending" runat="server" Visible="false">
    <div class="tc-dashboard-status-panel">
        <div class="tc-dashboard-status-ico">?</div>
        <div class="tc-dashboard-status-title">Verification Pending</div>
        <div class="tc-dashboard-status-msg">
            Your teaching certificate is currently under review. You will receive full access to the Teacher Dashboard once your certification has been approved by our admin team. Thank you for your patience!
        </div>
    </div>
</asp:Panel>

<asp:Panel ID="pnlRejected" runat="server" Visible="false">
    <div class="tc-dashboard-status-panel">
        <div class="tc-dashboard-status-ico">??</div>
        <div class="tc-dashboard-status-title">Certificate Not Approved</div>
        <div class="tc-dashboard-status-msg">
            Unfortunately, your teaching certificate was not approved. Please contact our support team or resubmit your certification documents for review. We are here to help!
        </div>
    </div>
</asp:Panel>

<asp:Panel ID="pnlDenied" runat="server" Visible="false">
    <div class="tc-dashboard-status-panel">
        <div class="tc-dashboard-status-ico">??</div>
        <div class="tc-dashboard-status-title">Access Denied</div>
        <div class="tc-dashboard-status-msg">
            Your account does not currently have access to the Teacher Dashboard. If you believe this is an error, please contact the ScienceBuddy support team.
        </div>
    </div>
</asp:Panel>

<%-- Main Dashboard (visible only to Certified teachers) --%>
<asp:Panel ID="pnlDashboard" runat="server" Visible="false">

<%-- -- 1. HERO BANNER -- --%>
<div class="tc-dashboard-hero">
    <div class="tc-dashboard-hero-body">
        <div class="tc-dashboard-hero-eyebrow">Teacher Portal</div>
        <div class="tc-dashboard-hero-title">Welcome back, <asp:Literal ID="litTeacherName" runat="server" Text="Teacher" />!</div>
        <div class="tc-dashboard-hero-sub">Manage your quizzes, teaching resources and classroom activities from one place.</div>
        <div class="tc-dashboard-hero-actions">
            <button type="button" class="tc-dashboard-hero-btn-topics" onclick="openTopicsModal()"><i class="bi bi-book"></i> Available Topics</button>
        </div>
    </div>
    <div class="tc-dashboard-hero-illustration">
        <div class="tc-dashboard-hero-mascot-wrap">
            <img src="<%: ResolveUrl("~/Images/Teacher/fox-teacher.png") %>" alt="Teacher mascot" />
            <div class="tc-dashboard-hero-ground-shadow"></div>
        </div>
        <div class="tc-dashboard-hero-decor-bulb"></div>
        <div class="tc-dashboard-hero-decor-heart"></div>
    </div>
    <div class="tc-dashboard-hero-decor">
        <div class="tc-dashboard-hero-decor-circle1"></div>
        <div class="tc-dashboard-hero-decor-circle2"></div>
        <div class="tc-dashboard-hero-decor-circle3"></div>
        <div class="tc-dashboard-hero-decor-dots"></div>
        <div class="tc-dashboard-hero-decor-curve"></div>
        <div class="tc-dashboard-hero-decor-glow"></div>
    </div>
</div>

<%-- Available Topics Modal --%>
<div class="tc-dashboard-topics-overlay" id="tdTopicsOverlay" onclick="if(event.target===this)closeTopicsModal()">
    <div class="tc-dashboard-topics-modal" role="dialog" aria-labelledby="tdTopicsTitle" aria-modal="true">
        <div class="tc-dashboard-topics-header">
            <div class="tc-dashboard-topics-header-left">
                <div class="tc-dashboard-topics-header-ico"><i class="bi bi-journal-bookmark-fill"></i></div>
                <div class="tc-dashboard-topics-header-text">
                    <div class="tc-dashboard-topics-title" id="tdTopicsTitle">Available Topics <span class="tc-dashboard-topics-title-sparkle">?</span></div>
                    <div class="tc-dashboard-topics-subtitle">Explore available units and subtopics by level.</div>
                </div>
            </div>
            <button type="button" class="tc-dashboard-topics-close" onclick="closeTopicsModal()" aria-label="Close"><i class="bi bi-x-lg"></i></button>
        </div>
        <div class="tc-dashboard-topics-search">
            <input type="text" id="tdTopicsSearch" placeholder="Search units or subtopics..." oninput="filterTopics(this.value)" />
        </div>
        <div class="tc-dashboard-topics-body" id="tdTopicsBody">
            <div class="tc-dashboard-topics-loading"><i class="bi bi-arrow-repeat"></i><span>Loading topics...</span></div>
        </div>
        <div class="tc-dashboard-topics-footer">
            <button type="button" class="tc-dashboard-topics-footer-btn" onclick="closeTopicsModal()">Close</button>
        </div>
    </div>
</div>

<%-- -- 2. QUIZ CREATION -- --%>
<div class="tc-dashboard-sec-hd">
    <div class="tc-dashboard-sec-title"><i class="bi bi-mortarboard-fill" style="color:var(--tc-primary);"></i> <%: T("Quiz Creation","Cipta Kuiz") %></div>
    <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx?tab=unit-level") %>" style="font-size:.85rem;font-weight:600;color:var(--tc-primary);text-decoration:none;transition:color .15s;" onmouseover="this.style.textDecoration='underline'" onmouseout="this.style.textDecoration='none'"><%: T("View all quizzes","Lihat semua kuiz") %> ?</a>
</div>
<div class="tc-dashboard-quiz-row">
    <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx?tab=unit-level&type=unit") %>" class="tc-dashboard-quiz-card tc-dashboard-quiz-purple">
        <div class="tc-dashboard-quiz-bg-icons"><i class="bi bi-droplet"></i><i class="bi bi-diagram-3"></i><i class="bi bi-moisture"></i><i class="bi bi-virus"></i><i class="bi bi-stars"></i></div>
        <div class="tc-dashboard-quiz-ico"><i class="bi bi-funnel-fill"></i></div>
        <div class="tc-dashboard-quiz-title"><%: T("Unit Quiz","Kuiz Unit") %></div>
        <div class="tc-dashboard-quiz-desc"><%: T("Create quizzes based on a specific unit or topic.","Cipta kuiz berdasarkan unit atau topik tertentu.") %></div>
        <span class="tc-dashboard-quiz-btn"><%: T("Create Quiz","Cipta Kuiz") %> ?</span>
    </a>
    <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx?tab=unit-level&type=level") %>" class="tc-dashboard-quiz-card tc-dashboard-quiz-orange">
        <div class="tc-dashboard-quiz-bg-icons"><i class="bi bi-journal-bookmark"></i><i class="bi bi-layers"></i><i class="bi bi-lightning"></i><i class="bi bi-globe-americas"></i><i class="bi bi-sun"></i></div>
        <div class="tc-dashboard-quiz-ico"><i class="bi bi-book-half"></i></div>
        <div class="tc-dashboard-quiz-title"><%: T("Level Quiz","Kuiz Tahap") %></div>
        <div class="tc-dashboard-quiz-desc"><%: T("Create quizzes based on difficulty levels.","Cipta kuiz berdasarkan tahap kesukaran.") %></div>
        <span class="tc-dashboard-quiz-btn"><%: T("Create Quiz","Cipta Kuiz") %> ?</span>
    </a>
    <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx?tab=practice") %>" class="tc-dashboard-quiz-card tc-dashboard-quiz-teal">
        <div class="tc-dashboard-quiz-bg-icons"><i class="bi bi-gear"></i><i class="bi bi-bullseye"></i><i class="bi bi-flower1"></i><i class="bi bi-thermometer-half"></i><i class="bi bi-rocket"></i></div>
        <div class="tc-dashboard-quiz-ico"><i class="bi bi-clipboard2-pulse-fill"></i></div>
        <div class="tc-dashboard-quiz-title"><%: T("Practice Quiz","Kuiz Latihan") %></div>
        <div class="tc-dashboard-quiz-desc"><%: T("Create practice quizzes for revision and exercises.","Cipta kuiz latihan untuk ulangkaji dan latihan.") %></div>
        <span class="tc-dashboard-quiz-btn"><%: T("Create Quiz","Cipta Kuiz") %> ?</span>
    </a>
</div>

<%-- -- QUIZ CONTRIBUTION -- --%>
<div class="tc-dashboard-sec-hd">
    <div class="tc-dashboard-sec-title"><i class="bi bi-pie-chart-fill" style="color:var(--tc-primary);"></i> <%: T("Your Quiz Contribution","Sumbangan Kuiz Anda") %>
        <span class="tc-dashboard-contrib-info" tabindex="0" aria-label="Quiz contribution information">
            <i class="bi bi-info-circle"></i>
            <span class="tc-dashboard-contrib-tooltip">Your Quiz Contribution shows the number of approved quiz questions you have contributed compared to the total approved quiz questions currently available in ScienceBuddy.<br/><br/>Only approved questions are included in the calculation.<br/><br/>• Unit Quiz Contribution counts approved Unit Quiz questions.<br/>• Level Quiz Contribution counts approved Level Quiz questions.</span>
        </span>
    </div>
</div>
<%-- Unit Quiz Card --%>
<div class="tc-dashboard-qc-card tc-dashboard-qc-purple">
    <div class="tc-dashboard-qc-header">
        <div class="tc-dashboard-qc-ico"><i class="bi bi-funnel-fill"></i></div>
        <div class="tc-dashboard-qc-header-text">
            <div class="tc-dashboard-qc-title"><%: T("Unit Quiz Contribution","Sumbangan Kuiz Unit") %></div>
            <div class="tc-dashboard-qc-sub"><%: T("Approved Unit Questions","Soalan Unit Diluluskan") %></div>
        </div>
    </div>
    <div class="tc-dashboard-qc-count">
        <span class="tc-dashboard-qc-count-num"><asp:Literal ID="litUnitMyCount" runat="server" Text="0" /></span>
        <span class="tc-dashboard-qc-count-of">of <asp:Literal ID="litUnitTotal" runat="server" Text="0" /></span>
        <span class="tc-dashboard-qc-count-unit">Questions</span>
    </div>
    <div class="tc-dashboard-qc-bar"><div class="tc-dashboard-qc-bar-fill" id="qcBarUnit" style="width:0%;"></div></div>
</div>
<%-- Level Quiz Card --%>
<div class="tc-dashboard-qc-card tc-dashboard-qc-blue">
    <div class="tc-dashboard-qc-header">
        <div class="tc-dashboard-qc-ico"><i class="bi bi-book-half"></i></div>
        <div class="tc-dashboard-qc-header-text">
            <div class="tc-dashboard-qc-title"><%: T("Level Quiz Contribution","Sumbangan Kuiz Tahap") %></div>
            <div class="tc-dashboard-qc-sub"><%: T("Approved Level Questions","Soalan Tahap Diluluskan") %></div>
        </div>
    </div>
    <div class="tc-dashboard-qc-count">
        <span class="tc-dashboard-qc-count-num"><asp:Literal ID="litLevelMyCount" runat="server" Text="0" /></span>
        <span class="tc-dashboard-qc-count-of">of <asp:Literal ID="litLevelTotal" runat="server" Text="0" /></span>
        <span class="tc-dashboard-qc-count-unit">Questions</span>
    </div>
    <div class="tc-dashboard-qc-bar"><div class="tc-dashboard-qc-bar-fill" id="qcBarLevel" style="width:0%;"></div></div>
</div>
<%-- Hidden data for JS animation --%>
<asp:HiddenField ID="hidUnitPct" runat="server" Value="0" />
<asp:HiddenField ID="hidLevelPct" runat="server" Value="0" />
<asp:Literal ID="litUnitPct" runat="server" Text="" Visible="false" />
<asp:Literal ID="litLevelPct" runat="server" Text="" Visible="false" />
<asp:Literal ID="litUnitCount" runat="server" Text="" Visible="false" />
<asp:Literal ID="litLevelCount" runat="server" Text="" Visible="false" />

<%-- -- 3. QUICK ACTIONS -- --%>
<div class="tc-dashboard-sec-hd">
    <div class="tc-dashboard-sec-title"><i class="bi bi-lightning-fill" style="color:var(--tc-primary);"></i> <%: T("Quick Actions","Tindakan Pantas") %></div>
</div>
<div class="tc-dashboard-quick">
    <a href="<%: ResolveUrl("~/Teacher/uploadMaterial.aspx") %>" class="tc-dashboard-quick-card">
        <div class="tc-dashboard-quick-ico" style="background:#EDE9FE;color:#6C63FF;"><i class="bi bi-file-earmark-plus"></i></div>
        <div class="tc-dashboard-quick-content">
            <div class="tc-dashboard-quick-lbl"><%: T("Upload Material","Muat Naik Bahan") %></div>
            <div class="tc-dashboard-quick-desc"><%: T("Add a new science lesson or material.","Tambah bahan pembelajaran sains baharu.") %></div>
        </div>
        <span class="tc-dashboard-quick-arrow"><i class="bi bi-chevron-right"></i></span>
    </a>
    <a href="<%: ResolveUrl("~/Teacher/liveSession.aspx") %>" class="tc-dashboard-quick-card">
        <div class="tc-dashboard-quick-ico" style="background:#DBEAFE;color:#2563EB;"><i class="bi bi-calendar-plus"></i></div>
        <div class="tc-dashboard-quick-content">
            <div class="tc-dashboard-quick-lbl"><%: T("Schedule Live Class","Jadualkan Kelas Langsung") %></div>
            <div class="tc-dashboard-quick-desc"><%: T("Plan and schedule an online class session.","Rancang dan jadualkan sesi kelas dalam talian.") %></div>
        </div>
        <span class="tc-dashboard-quick-arrow"><i class="bi bi-chevron-right"></i></span>
    </a>
    <a href="<%: ResolveUrl("~/Teacher/studentProgress.aspx") %>" class="tc-dashboard-quick-card">
        <div class="tc-dashboard-quick-ico" style="background:#D1FAE5;color:#059669;"><i class="bi bi-graph-up-arrow"></i></div>
        <div class="tc-dashboard-quick-content">
            <div class="tc-dashboard-quick-lbl"><%: T("Student Progress","Prestasi Pelajar") %></div>
            <div class="tc-dashboard-quick-desc"><%: T("Review student learning data and performance.","Semak prestasi dan data pembelajaran pelajar.") %></div>
        </div>
        <span class="tc-dashboard-quick-arrow"><i class="bi bi-chevron-right"></i></span>
    </a>
    <a href="<%: ResolveUrl("~/Teacher/privateMessages.aspx") %>" class="tc-dashboard-quick-card">
        <div class="tc-dashboard-quick-ico" style="background:#FEF3C7;color:#D97706;"><i class="bi bi-envelope"></i></div>
        <div class="tc-dashboard-quick-content">
            <div class="tc-dashboard-quick-lbl"><%: T("Private Message","Mesej Peribadi") %></div>
            <div class="tc-dashboard-quick-desc"><%: T("Send and receive messages with students and parents.","Hantar dan terima mesej dengan pelajar dan ibu bapa.") %></div>
        </div>
        <span class="tc-dashboard-quick-arrow"><i class="bi bi-chevron-right"></i></span>
    </a>
</div>

<%-- -- 4. UPCOMING SESSIONS & NOTIFICATIONS -- --%>
<div class="tc-dashboard-twin-row">
    <%-- Upcoming Live Sessions --%>
    <div class="tc-dashboard-card" style="flex:1.3;">
        <div class="tc-dashboard-card-body">
            <div class="tc-dashboard-sec-hd" style="margin-bottom:.75rem;">
                <div class="tc-dashboard-sec-title" style="font-size:.92rem;"><i class="bi bi-camera-video-fill" style="color:var(--tc-info);"></i> <%: T("Upcoming Live Sessions","Kelas Langsung Akan Datang") %></div>
                <a href="<%: ResolveUrl("~/Teacher/liveSession.aspx") %>" style="font-size:.78rem;font-weight:600;color:var(--tc-primary);text-decoration:none;"><%: T("View All","Lihat Semua") %> ?</a>
            </div>
            <asp:Panel ID="pnlTimelineSessions" runat="server" Visible="false">
                <div class="tc-dashboard-timeline">
                    <asp:Repeater ID="rptTimelineSessions" runat="server">
                        <ItemTemplate>
                            <div class="tc-dashboard-tl-item">
                                <div class='tc-dashboard-tl-dot <%# Eval("dotCss") %>'></div>
                                <div class="tc-dashboard-tl-content">
                                    <div class="tc-dashboard-tl-time"><%# Eval("friendlyDate") %></div>
                                    <div class="tc-dashboard-tl-title"><%# HttpUtility.HtmlEncode(Eval("title")) %></div>
                                    <div class="tc-dashboard-tl-topic"><i class="bi bi-bookmark"></i> <%# HttpUtility.HtmlEncode(Eval("topic")) %></div>
                                    <div class="tc-dashboard-tl-footer">
                                        <span class='tc-dashboard-tl-badge <%# Eval("badgeCss") %>'><%# Eval("statusLabel") %></span>
                                        <a href='<%# ResolveUrl("~/Teacher/liveSession.aspx") %>' class='tc-dashboard-tl-btn <%# Eval("btnCss") %>'><%# Eval("btnLabel") %></a>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </asp:Panel>
            <asp:Panel ID="pnlTimelineEmpty" runat="server">
                <div class="tc-dashboard-empty" style="padding:2rem;">
                    <i class="bi bi-calendar2-check" style="font-size:2rem;"></i>
                    <div style="font-size:.88rem;font-weight:700;color:var(--tc-text);margin-top:.5rem;"><%: T("No upcoming live sessions.","Tiada kelas langsung akan datang.") %></div>
                    <div style="font-size:.78rem;color:var(--tc-muted);margin-bottom:.75rem;"><%: T("You're all caught up.","Anda telah selesai.") %></div>
                    <a href="<%: ResolveUrl("~/Teacher/liveSession.aspx") %>" style="display:inline-flex;align-items:center;gap:5px;padding:.45rem 1rem;border-radius:8px;background:var(--tc-primary);color:#fff;font-size:.78rem;font-weight:700;text-decoration:none;">
                        <i class="bi bi-plus-lg"></i> <%: T("Schedule Session","Jadualkan Sesi") %></a>
                </div>
            </asp:Panel>
        </div>
    </div>
    <%-- Notifications --%>
    <div class="tc-dashboard-card" style="flex:0.7;">
        <div class="tc-dashboard-card-body">
            <div class="tc-dashboard-sec-hd" style="margin-bottom:.75rem;">
                <div class="tc-dashboard-sec-title" style="font-size:.92rem;"><i class="bi bi-bell-fill" style="color:var(--tc-warning);"></i> <%: T("Notifications","Notifikasi") %></div>
                <a href="<%: ResolveUrl("~/Teacher/Notifications.aspx") %>" style="font-size:.78rem;font-weight:600;color:var(--tc-primary);text-decoration:none;"><%: T("View All","Lihat Semua") %> ?</a>
            </div>
            <asp:Panel ID="pnlDashNotifs" runat="server" Visible="false">
                <div class="tc-dashboard-notif-list-v2">
                    <asp:Repeater ID="rptDashNotifs" runat="server">
                        <ItemTemplate>
                            <div class='tc-dashboard-nv2-item <%# Convert.ToBoolean(Eval("isRead")) ? "" : "unread" %>'>
                                <div class="tc-dashboard-nv2-ico"><i class="bi bi-bell"></i></div>
                                <div class="tc-dashboard-nv2-body">
                                    <div class="tc-dashboard-nv2-title"><%# HttpUtility.HtmlEncode(Eval("title")) %></div>
                                    <div class="tc-dashboard-nv2-msg"><%# HttpUtility.HtmlEncode(Eval("message")) %></div>
                                    <div class="tc-dashboard-nv2-time"><i class="bi bi-clock"></i> <%# Eval("timeAgo") %></div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </asp:Panel>
            <asp:Panel ID="pnlDashNotifsEmpty" runat="server">
                <div class="tc-dashboard-empty" style="padding:2rem;">
                    <i class="bi bi-bell-slash" style="font-size:2rem;"></i>
                    <div style="font-size:.88rem;font-weight:700;color:var(--tc-text);margin-top:.5rem;"><%: T("No new notifications.","Tiada pemberitahuan baharu.") %></div>
                    <div style="font-size:.78rem;color:var(--tc-muted);"><%: T("You're all caught up.","Anda telah selesai.") %></div>
                </div>
            </asp:Panel>
        </div>
    </div>
</div>

<%-- -- 5. OVERVIEW -- --%>
<div class="tc-dashboard-sec-hd">
    <div class="tc-dashboard-sec-title"><i class="bi bi-bar-chart-fill" style="color:var(--tc-primary);"></i> <%: T("Overview","Ringkasan") %></div>
</div>
<div class="tc-dashboard-stats">
    <a href="#" class="tc-dashboard-stat tc-dashboard-stat-lessons">
        <div class="tc-dashboard-stat-icon" style="background:#EDE9FE;color:#6C63FF;"><i class="bi bi-file-earmark-text-fill"></i></div>
        <div class="tc-dashboard-stat-val"><asp:Literal ID="litTotalLessons" runat="server" Text="0" /></div>
        <div class="tc-dashboard-stat-lbl"><%: T("Total Materials","Jumlah Bahan") %></div>
    </a>
    <a href="#" class="tc-dashboard-stat tc-dashboard-stat-quizzes">
        <div class="tc-dashboard-stat-icon" style="background:#FEF3C7;color:#D97706;"><i class="bi bi-patch-question-fill"></i></div>
        <div class="tc-dashboard-stat-val"><asp:Literal ID="litTotalQuizzes" runat="server" Text="0" /></div>
        <div class="tc-dashboard-stat-lbl"><%: T("Total Quizzes","Jumlah Kuiz") %></div>
    </a>
    <a href="#" class="tc-dashboard-stat tc-dashboard-stat-sessions">
        <div class="tc-dashboard-stat-icon" style="background:#DBEAFE;color:#2563EB;"><i class="bi bi-camera-video-fill"></i></div>
        <div class="tc-dashboard-stat-val"><asp:Literal ID="litUpcomingSessions" runat="server" Text="0" /></div>
        <div class="tc-dashboard-stat-lbl"><%: T("Upcoming Live Sessions","Kelas Langsung Akan Datang") %></div>
    </a>
    <a href="#" class="tc-dashboard-stat tc-dashboard-stat-students">
        <div class="tc-dashboard-stat-icon" style="background:#D1FAE5;color:#059669;"><i class="bi bi-people-fill"></i></div>
        <div class="tc-dashboard-stat-val"><asp:Literal ID="litTotalStudents" runat="server" Text="0" /></div>
        <div class="tc-dashboard-stat-lbl"><%: T("Total Students","Jumlah Pelajar") %></div>
    </a>
</div>

<%-- -- 5. PRACTICE QUIZ ENGAGEMENT -- --%>
<div class="tc-dashboard-sec-hd">
    <div class="tc-dashboard-sec-title"><i class="bi bi-clipboard2-pulse-fill" style="color:var(--tc-primary);"></i> Practice Quiz Engagement</div>
</div>
<p style="font-size:.82rem;color:var(--tc-muted);margin-top:-.5rem;margin-bottom:1.25rem;">Track student participation and performance for each of your approved practice quizzes.</p>

<asp:Panel ID="pnlPQCards" runat="server" Visible="false">
    <div class="tc-dashboard-pq-carousel-wrap">
        <button type="button" class="tc-dashboard-pq-arrow tc-dashboard-pq-arrow-left disabled" id="pqArrowLeft" onclick="pqSlide(-1)"><i class="bi bi-chevron-left"></i></button>
        <button type="button" class="tc-dashboard-pq-arrow tc-dashboard-pq-arrow-right" id="pqArrowRight" onclick="pqSlide(1)"><i class="bi bi-chevron-right"></i></button>
        <div class="tc-dashboard-pq-carousel">
            <div class="tc-dashboard-pq-track" id="pqTrack">
                <asp:Repeater ID="rptPracticeQuizCards" runat="server">
                    <ItemTemplate>
                        <div class="tc-dashboard-pq-slide">
                            <div class="tc-dashboard-pq-card">
                                <div class="tc-dashboard-pq-card-top">
                                    <span class="tc-dashboard-pq-badge-top tc-dashboard-pq-badge-questions"><%# Eval("questionCount") %> Questions</span>
                                    <span class="tc-dashboard-pq-badge-top tc-dashboard-pq-badge-lang-top"><%# Eval("langLabel") %></span>
                                </div>
                                <div class="tc-dashboard-pq-card-body">
                                    <div class="tc-dashboard-pq-title"><%# HttpUtility.HtmlEncode(Eval("title")) %></div>
                                    <div class="tc-dashboard-pq-info-row">
                                        <div class="tc-dashboard-pq-info-item">
                                            <i class="bi bi-mortarboard-fill"></i>
                                            <div><div class="tc-dashboard-pq-info-label">Level</div><div class="tc-dashboard-pq-info-value"><%# HttpUtility.HtmlEncode(Eval("levelName")) %></div></div>
                                        </div>
                                        <div class="tc-dashboard-pq-info-item">
                                            <i class="bi bi-bookmark-fill"></i>
                                            <div><div class="tc-dashboard-pq-info-label">Subtopic</div><div class="tc-dashboard-pq-info-value"><%# HttpUtility.HtmlEncode(Eval("subtopicName")) %></div></div>
                                        </div>
                                    </div>
                                    <div class="tc-dashboard-pq-metrics">
                                        <div class="tc-dashboard-pq-metric">
                                            <div class="tc-dashboard-pq-metric-ico" style="background:#EDE9FE;color:#6C63FF;"><i class="bi bi-people-fill"></i></div>
                                            <div class="tc-dashboard-pq-metric-text"><div class="tc-dashboard-pq-metric-val"><%# Eval("studentsAttempted") %></div><div class="tc-dashboard-pq-metric-lbl">Students Attempted</div></div>
                                        </div>
                                        <div class="tc-dashboard-pq-metric">
                                            <div class="tc-dashboard-pq-metric-ico" style="background:#DBEAFE;color:#2563EB;"><i class="bi bi-arrow-repeat"></i></div>
                                            <div class="tc-dashboard-pq-metric-text"><div class="tc-dashboard-pq-metric-val"><%# Eval("totalAttempts") %></div><div class="tc-dashboard-pq-metric-lbl">Total Attempts</div></div>
                                        </div>
                                        <div class="tc-dashboard-pq-metric">
                                            <div class="tc-dashboard-pq-metric-ico" style="background:#D1FAE5;color:#059669;"><i class="bi bi-trophy-fill"></i></div>
                                            <div class="tc-dashboard-pq-metric-text"><div class="tc-dashboard-pq-metric-val"><%# Eval("avgScore") %></div><div class="tc-dashboard-pq-metric-lbl">Average Score</div></div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
        <div class="tc-dashboard-pq-dots" id="pqDots"></div>
    </div>
</asp:Panel>

<asp:Panel ID="pnlPQEmpty" runat="server">
    <div class="tc-dashboard-pq-empty">
        <div class="tc-dashboard-pq-empty-ico"><i class="bi bi-clipboard2-pulse"></i></div>
        <div class="tc-dashboard-pq-empty-title">No Approved Practice Quizzes Yet</div>
        <div class="tc-dashboard-pq-empty-sub">Your approved Practice Quiz engagement will appear here once a quiz has been approved.</div>
    </div>
</asp:Panel>

</asp:Panel>

</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
window.addEventListener('load',function(){
    var uPct=parseInt(document.querySelector('[id$="hidUnitPct"]').value)||0;
    var lPct=parseInt(document.querySelector('[id$="hidLevelPct"]').value)||0;
    var barU=document.getElementById('qcBarUnit');
    var barL=document.getElementById('qcBarLevel');
    setTimeout(function(){
        if(barU)barU.style.width=Math.min(uPct,100)+'%';
        if(barL)barL.style.width=Math.min(lPct,100)+'%';
    },150);
});

/* -- Available Topics Modal -- */
var _topicsData = null;
var _topicsLoaded = false;

function openTopicsModal() {
    document.getElementById('tdTopicsOverlay').classList.add('open');
    document.body.style.overflow = 'hidden';
    if (!_topicsLoaded) loadTopicsData();
}
function closeTopicsModal() {
    document.getElementById('tdTopicsOverlay').classList.remove('open');
    document.body.style.overflow = '';
}
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape' && document.getElementById('tdTopicsOverlay').classList.contains('open')) closeTopicsModal();
});

function loadTopicsData() {
    var body = document.getElementById('tdTopicsBody');
    body.innerHTML = '<div class="tc-dashboard-topics-loading"><i class="bi bi-arrow-repeat"></i><span>Loading topics...</span></div>';
    fetch(window.location.pathname.split('?')[0] + '/GetAvailableTopics', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    })
    .then(function(r) { return r.json(); })
    .then(function(resp) {
        _topicsData = resp.d || resp;
        _topicsLoaded = true;
        renderTopics(_topicsData);
    })
    .catch(function() {
        body.innerHTML = '<div class="tc-dashboard-topics-empty"><div class="tc-dashboard-topics-empty-ico"><i class="bi bi-wifi-off"></i></div><div class="tc-dashboard-topics-empty-title">Unable to load topics</div><div class="tc-dashboard-topics-empty-sub">Please try again later.</div></div>';
    });
}

function renderTopics(data) {
    var body = document.getElementById('tdTopicsBody');
    if (!data || !data.length) { body.innerHTML = '<div class="tc-dashboard-topics-empty"><div class="tc-dashboard-topics-empty-ico"><i class="bi bi-journal-x"></i></div><div class="tc-dashboard-topics-empty-title">No topics available</div><div class="tc-dashboard-topics-empty-sub">Topics will appear here once added.</div></div>'; return; }
    var levelIcons = ['bi-star','bi-rocket-takeoff','bi-lightning','bi-trophy','bi-gem'];
    var levelLabels = ['Foundation Level','Intermediate Level','Advanced Level','Expert Level','Master Level'];
    var html = '';
    for (var i = 0; i < data.length; i++) {
        var level = data[i];
        var lvlIdx = i % 5;
        var unitCount = level.Units ? level.Units.length : 0;
        html += '<div class="tc-dashboard-level-item" data-search="' + esc(level.LevelName).toLowerCase() + '">';
        html += '<div class="tc-dashboard-level-header tc-dashboard-lvl-' + lvlIdx + '" onclick="toggleAcc(this)">';
        html += '<div class="tc-dashboard-level-ico"><i class="bi ' + levelIcons[lvlIdx] + '"></i></div>';
        html += '<div class="tc-dashboard-level-name-wrap"><span class="tc-dashboard-level-name">' + esc(level.LevelName) + '</span><span class="tc-dashboard-level-sublabel">' + levelLabels[lvlIdx] + '</span></div>';
        html += '<span class="tc-dashboard-level-badge">' + unitCount + ' unit' + (unitCount !== 1 ? 's' : '') + '</span>';
        html += '<span class="tc-dashboard-acc-arrow"><i class="bi bi-chevron-right"></i></span>';
        html += '</div>';
        html += '<div class="tc-dashboard-level-content">';
        if (level.Units && level.Units.length) {
            for (var j = 0; j < level.Units.length; j++) {
                var unit = level.Units[j];
                var subCount = unit.Subtopics ? unit.Subtopics.length : 0;
                html += '<div class="tc-dashboard-unit-item" data-search="' + esc(unit.UnitName).toLowerCase() + '">';
                html += '<div class="tc-dashboard-unit-header" onclick="toggleAcc(this)">';
                html += '<div class="tc-dashboard-unit-ico"><i class="bi bi-bookmark-fill"></i></div>';
                html += '<span class="tc-dashboard-unit-name">' + esc(unit.UnitName) + '</span>';
                html += '<span class="tc-dashboard-unit-count">' + subCount + ' topic' + (subCount !== 1 ? 's' : '') + '</span>';
                html += '<span class="tc-dashboard-acc-arrow"><i class="bi bi-chevron-right"></i></span>';
                html += '</div>';
                html += '<div class="tc-dashboard-unit-content">';
                if (unit.Subtopics && unit.Subtopics.length) {
                    for (var k = 0; k < unit.Subtopics.length; k++) {
                        html += '<div class="tc-dashboard-subtopic-item" data-search="' + esc(unit.Subtopics[k]).toLowerCase() + '">' + esc(unit.Subtopics[k]) + '</div>';
                    }
                }
                html += '</div></div>';
            }
        }
        html += '</div></div>';
    }
    body.innerHTML = html;
}

function toggleAcc(header) {
    var parent = header.parentElement;
    var isOpen = parent.classList.contains('open');
    parent.classList.toggle('open');
    header.classList.toggle('open');
}

function filterTopics(query) {
    var q = query.toLowerCase().trim();
    var levels = document.querySelectorAll('.tc-dashboard-level-item');
    var anyVisible = false;
    for (var i = 0; i < levels.length; i++) {
        var level = levels[i];
        var units = level.querySelectorAll('.tc-dashboard-unit-item');
        var levelMatch = false;
        for (var j = 0; j < units.length; j++) {
            var unit = units[j];
            var subtopics = unit.querySelectorAll('.tc-dashboard-subtopic-item');
            var unitMatch = unit.getAttribute('data-search').indexOf(q) > -1;
            var anySubMatch = false;
            for (var k = 0; k < subtopics.length; k++) {
                var subMatch = subtopics[k].getAttribute('data-search').indexOf(q) > -1;
                subtopics[k].style.display = (!q || subMatch || unitMatch) ? '' : 'none';
                if (subMatch) anySubMatch = true;
            }
            var show = !q || unitMatch || anySubMatch;
            unit.style.display = show ? '' : 'none';
            if (show && q) { unit.classList.add('open'); unit.querySelector('.tc-dashboard-unit-header').classList.add('open'); }
            if (show) levelMatch = true;
        }
        var levelNameMatch = level.getAttribute('data-search').indexOf(q) > -1;
        var showLevel = !q || levelMatch || levelNameMatch;
        level.style.display = showLevel ? '' : 'none';
        if (showLevel) anyVisible = true;
        if ((levelMatch || levelNameMatch) && q) { level.classList.add('open'); level.querySelector('.tc-dashboard-level-header').classList.add('open'); }
        if (!q) {
            level.classList.remove('open'); level.querySelector('.tc-dashboard-level-header').classList.remove('open');
            var us = level.querySelectorAll('.tc-dashboard-unit-item');
            for (var m = 0; m < us.length; m++) { us[m].classList.remove('open'); us[m].querySelector('.tc-dashboard-unit-header').classList.remove('open'); }
        }
    }
    // Show/hide empty search state
    var emptyEl = document.getElementById('tdTopicsSearchEmpty');
    if (q && !anyVisible) {
        if (!emptyEl) {
            emptyEl = document.createElement('div');
            emptyEl.id = 'tdTopicsSearchEmpty';
            emptyEl.className = 'tc-dashboard-topics-empty';
            emptyEl.innerHTML = '<div class="tc-dashboard-topics-empty-ico"><i class="bi bi-search"></i></div><div class="tc-dashboard-topics-empty-title">No topics found</div><div class="tc-dashboard-topics-empty-sub">Try another keyword.</div>';
            document.getElementById('tdTopicsBody').appendChild(emptyEl);
        }
        emptyEl.style.display = '';
    } else if (emptyEl) {
        emptyEl.style.display = 'none';
    }
}

function esc(s) { var d = document.createElement('div'); d.textContent = s || ''; return d.innerHTML; }

/* -- Practice Quiz Carousel -- */
(function(){
    var track = document.getElementById('pqTrack');
    if (!track) return;
    var slides = track.querySelectorAll('.tc-dashboard-pq-slide');
    if (!slides.length) return;
    var total = slides.length;
    var idx = 0;

    function getVisible() {
        if (window.innerWidth <= 767) return 1;
        if (window.innerWidth <= 1023) return 2;
        return 3;
    }

    function setSlideWidths() {
        var vis = getVisible();
        var pct = 100 / vis;
        for (var i = 0; i < slides.length; i++) slides[i].style.width = pct + '%';
    }

    function render() {
        var vis = getVisible();
        var maxIdx = Math.max(0, total - vis);
        if (idx > maxIdx) idx = maxIdx;
        var pct = -(idx * (100 / vis));
        track.style.transform = 'translateX(' + pct + '%)';
        var left = document.getElementById('pqArrowLeft');
        var right = document.getElementById('pqArrowRight');
        if (left) { if (idx <= 0) left.classList.add('disabled'); else left.classList.remove('disabled'); }
        if (right) { if (idx >= maxIdx) right.classList.add('disabled'); else right.classList.remove('disabled'); }
        // Hide arrows if all fit
        if (total <= vis) { if (left) left.style.display='none'; if (right) right.style.display='none'; }
        else { if (left) left.style.display=''; if (right) right.style.display=''; }
        renderDots(vis, maxIdx);
    }

    function renderDots(vis, maxIdx) {
        var dotsEl = document.getElementById('pqDots');
        if (!dotsEl) return;
        var count = maxIdx + 1;
        if (count <= 1) { dotsEl.innerHTML = ''; return; }
        var html = '';
        for (var i = 0; i < count; i++) {
            html += '<span class="tc-dashboard-pq-dot' + (i === idx ? ' active' : '') + '" onclick="pqGoTo(' + i + ')"></span>';
        }
        dotsEl.innerHTML = html;
    }

    window.pqSlide = function(dir) { idx += dir; render(); };
    window.pqGoTo = function(i) { idx = i; render(); };

    setSlideWidths();
    render();
    window.addEventListener('resize', function() { setSlideWidths(); render(); });
})();
</script>
</asp:Content>