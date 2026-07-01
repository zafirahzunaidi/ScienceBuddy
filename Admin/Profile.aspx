<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Profile.aspx.cs"
    Inherits="ScienceBuddy.Admin.Profile" MasterPageFile="~/Site.Master"
    Title="My Profile" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--ap:#2563EB;--ap-light:#EFF6FF;}
.ap-hero{background:linear-gradient(135deg,#1E3A5F 0%,#2563EB 60%,#3B82F6 100%);border-radius:var(--border-radius-xl);padding:var(--space-2xl);color:#fff;position:relative;overflow:hidden;margin-bottom:var(--space-xl);box-shadow:0 12px 40px rgba(37,99,235,.2);}
.ap-hero::before{content:'';position:absolute;width:300px;height:300px;border-radius:50%;background:rgba(255,255,255,.04);top:-100px;right:-60px;}
.ap-hero::after{content:'';position:absolute;width:150px;height:150px;border-radius:50%;background:rgba(255,255,255,.03);bottom:-40px;left:30px;}
.ap-hero-body{position:relative;z-index:1;display:flex;align-items:center;gap:var(--space-xl);flex-wrap:wrap;}
.ap-avatar{width:100px;height:100px;border-radius:50%;background:rgba(255,255,255,.15);border:4px solid rgba(255,255,255,.4);display:flex;align-items:center;justify-content:center;font-size:2.5rem;font-weight:800;color:#fff;flex-shrink:0;box-shadow:0 8px 24px rgba(0,0,0,.15);}
.ap-hero-info{flex:1;min-width:200px;}
.ap-hero-name{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;margin-bottom:4px;}
.ap-hero-role{display:inline-flex;align-items:center;gap:6px;background:rgba(255,255,255,.18);border:1px solid rgba(255,255,255,.3);border-radius:var(--border-radius-full);padding:4px 14px;font-size:.75rem;font-weight:700;margin-bottom:8px;}
.ap-hero-meta{display:flex;gap:var(--space-lg);flex-wrap:wrap;font-size:.8rem;opacity:.85;}
.ap-hero-meta span{display:flex;align-items:center;gap:5px;}
.ap-grid{display:grid;grid-template-columns:1fr 1fr;gap:var(--space-xl);margin-bottom:var(--space-xl);}
.ap-card{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);padding:var(--space-xl);transition:box-shadow .2s;}
.ap-card:hover{box-shadow:var(--shadow-md);}
.ap-card-title{font-family:var(--font-primary);font-size:1rem;font-weight:800;color:var(--color-text);margin-bottom:var(--space-lg);display:flex;align-items:center;gap:8px;padding-bottom:var(--space-sm);border-bottom:1px solid var(--border-color);}
.ap-field{display:flex;align-items:center;padding:14px 0;border-bottom:1px solid #F1F5F9;}
.ap-field:last-child{border-bottom:none;}
.ap-field-ico{width:36px;height:36px;border-radius:var(--border-radius);background:var(--ap-light);color:var(--ap);display:flex;align-items:center;justify-content:center;font-size:.9rem;flex-shrink:0;margin-right:var(--space-md);}
.ap-field-body{flex:1;}
.ap-label{font-size:.7rem;font-weight:600;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;}
.ap-value{font-size:.9375rem;font-weight:600;color:var(--color-text);}
.ap-status{display:inline-flex;align-items:center;gap:5px;padding:4px 12px;border-radius:var(--border-radius-full);font-size:.75rem;font-weight:700;background:#D1FAE5;color:#065F46;}
.ap-status-dot{width:7px;height:7px;border-radius:50%;background:#16A34A;}
@media(max-width:767px){.ap-grid{grid-template-columns:1fr;}.ap-hero-body{flex-direction:column;align-items:flex-start;}}
</style>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" />
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="<%: ResolveUrl("~/Scripts/admin-signout.js") %>"></script>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label">Main</div>
        <a href="<%: ResolveUrl("~/Admin/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label">Dashboard</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">User Management</div>
        <a href="<%: ResolveUrl("~/Admin/StudentManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-people item-icon"></i><span class="item-label">Students</span></a>
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
        <a href="<%: ResolveUrl("~/Admin/Profile.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a>
        <a href="javascript:;" class="sb-sidebar-item" onclick="showSignOutModal()"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%= T("My Profile", "Profil Saya") %></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<!-- HERO PROFILE BANNER -->
<div class="ap-hero">
    <div class="ap-hero-body">
        <div class="ap-avatar"><asp:Literal ID="litInitials" runat="server" Text="A" /></div>
        <div class="ap-hero-info">
            <div class="ap-hero-name"><asp:Literal ID="litUsername" runat="server" Text="-" /></div>
            <div class="ap-hero-role"><i class="bi bi-shield-check"></i> <asp:Literal ID="litRole" runat="server" Text="Administrator" /></div>
            <div class="ap-hero-meta">
                <span><i class="bi bi-envelope"></i> <asp:Literal ID="litEmail" runat="server" Text="-" /></span>
                <span><i class="bi bi-translate"></i> <asp:Literal ID="litLanguage" runat="server" Text="-" /></span>
            </div>
        </div>
    </div>
</div>

<!-- INFO CARDS -->
<div class="ap-grid">
    <!-- Account Information -->
    <div class="ap-card">
        <div class="ap-card-title"><i class="bi bi-person-circle" style="color:var(--ap);"></i> <%= T("Account Information", "Maklumat Akaun") %></div>
        <div class="ap-field">
            <div class="ap-field-ico"><i class="bi bi-person"></i></div>
            <div class="ap-field-body"><div class="ap-label"><%= T("Username", "Nama Pengguna") %></div><div class="ap-value"><asp:Literal ID="litUsernameVal" runat="server" Text="-" /></div></div>
        </div>
        <div class="ap-field">
            <div class="ap-field-ico"><i class="bi bi-envelope"></i></div>
            <div class="ap-field-body"><div class="ap-label"><%= T("Email Address", "Alamat E-mel") %></div><div class="ap-value"><asp:Literal ID="litEmailVal" runat="server" Text="-" /></div></div>
        </div>
        <div class="ap-field">
            <div class="ap-field-ico"><i class="bi bi-shield-lock"></i></div>
            <div class="ap-field-body"><div class="ap-label"><%= T("Role", "Peranan") %></div><div class="ap-value"><asp:Literal ID="litRoleVal" runat="server" Text="Administrator" /></div></div>
        </div>
    </div>

    <!-- Preferences -->
    <div class="ap-card">
        <div class="ap-card-title"><i class="bi bi-gear" style="color:var(--ap);"></i> <%= T("Preferences", "Keutamaan") %></div>
        <div class="ap-field">
            <div class="ap-field-ico"><i class="bi bi-translate"></i></div>
            <div class="ap-field-body"><div class="ap-label"><%= T("Preferred Language", "Bahasa Pilihan") %></div><div class="ap-value"><asp:Literal ID="litLangVal" runat="server" Text="-" /></div></div>
        </div>
        <div class="ap-field">
            <div class="ap-field-ico"><i class="bi bi-activity"></i></div>
            <div class="ap-field-body"><div class="ap-label"><%= T("Account Status", "Status Akaun") %></div><div class="ap-value"><asp:Literal ID="litStatus" runat="server" Text="-" /></div></div>
        </div>
        <div class="ap-field">
            <div class="ap-field-ico"><i class="bi bi-calendar3"></i></div>
            <div class="ap-field-body"><div class="ap-label"><%= T("System", "Sistem") %></div><div class="ap-value">ScienceBuddy Admin v1.0</div></div>
        </div>
    </div>
</div>
</asp:Content>
