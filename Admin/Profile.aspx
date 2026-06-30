<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Profile.aspx.cs"
    Inherits="ScienceBuddy.Admin.Profile" MasterPageFile="~/Site.Master"
    Title="My Profile" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root { --admin:#2563EB; --admin-light:#DBEAFE; }
.ap-page-header { margin-bottom:var(--space-xl); padding-bottom:var(--space-md); border-bottom:1.5px solid var(--border-color); }
.ap-page-title { font-family:var(--font-primary); font-size:1.75rem; font-weight:800; color:var(--color-text); margin-bottom:var(--space-xs); }
.ap-page-sub { font-size:.9375rem; color:var(--color-text-secondary); max-width:480px; line-height:1.5; }
.ap-card {
    background:var(--color-white); border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color); box-shadow:var(--shadow-sm);
    padding:var(--space-2xl); max-width:640px;
}
.ap-avatar {
    width:80px; height:80px; border-radius:var(--border-radius-full);
    background:linear-gradient(135deg,var(--admin),#60A5FA);
    display:flex; align-items:center; justify-content:center;
    color:#fff; font-size:2rem; font-weight:800; margin-bottom:var(--space-lg);
}
.ap-field { margin-bottom:var(--space-lg); }
.ap-label { font-size:.75rem; font-weight:700; text-transform:uppercase; letter-spacing:.5px; color:var(--color-text-muted); margin-bottom:var(--space-xs); }
.ap-value { font-size:1rem; font-weight:600; color:var(--color-text); }
</style>
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
        <a href="#" class="sb-sidebar-item"><i class="bi bi-question-circle item-icon"></i><span class="item-label">Questions</span></a>
        <a href="<%: ResolveUrl("~/Admin/TeacherMaterials.aspx") %>" class="sb-sidebar-item"><i class="bi bi-file-earmark-text item-icon"></i><span class="item-label">Material Requests</span></a>
        <a href="<%: ResolveUrl("~/Admin/LiveSessions.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label">Live Sessions</span></a>
        <a href="<%: ResolveUrl("~/Admin/QuestionRequests.aspx") %>" class="sb-sidebar-item"><i class="bi bi-clipboard-check item-icon"></i><span class="item-label">Question Requests</span></a>
        <a href="<%: ResolveUrl("~/Admin/CertificateManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-award item-icon"></i><span class="item-label">Certificates</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Gamification</div>
        <a href="<%: ResolveUrl("~/Admin/GamificationManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-trophy item-icon"></i><span class="item-label">Gamification</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Configuration</div>
        <a href="<%: ResolveUrl("~/Admin/SystemSettings.aspx") %>" class="sb-sidebar-item"><i class="bi bi-gear item-icon"></i><span class="item-label">System Settings</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Logs</div>
        <a href="<%: ResolveUrl("~/Admin/SystemActivityLogs.aspx") %>" class="sb-sidebar-item"><i class="bi bi-clock-history item-icon"></i><span class="item-label">Activity Logs</span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-box-arrow-in-right item-icon"></i><span class="item-label">Login Logs</span></a>
        <a href="<%: ResolveUrl("~/Admin/SuspiciousLogins.aspx") %>" class="sb-sidebar-item"><i class="bi bi-exclamation-triangle item-icon"></i><span class="item-label">Suspicious Logins</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Admin/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span></a>
        <a href="<%: ResolveUrl("~/Admin/Profile.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item" onclick="return confirm('Are you sure you want to sign out?');"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%= T("My Profile", "Profil Saya") %></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="ap-page-header">
    <h1 class="ap-page-title"><%= T("My Profile", "Profil Saya") %></h1>
    <p class="ap-page-sub"><%= T("View your administrator account information.", "Lihat maklumat akaun pentadbir anda.") %></p>
</div>

<div class="ap-card">
    <div class="ap-avatar"><asp:Literal ID="litInitials" runat="server" Text="A" /></div>

    <div class="ap-field">
        <div class="ap-label"><%= T("Username", "Nama Pengguna") %></div>
        <div class="ap-value"><asp:Literal ID="litUsername" runat="server" Text="-" /></div>
    </div>
    <div class="ap-field">
        <div class="ap-label"><%= T("Email Address", "Alamat E-mel") %></div>
        <div class="ap-value"><asp:Literal ID="litEmail" runat="server" Text="-" /></div>
    </div>
    <div class="ap-field">
        <div class="ap-label"><%= T("Role", "Peranan") %></div>
        <div class="ap-value"><asp:Literal ID="litRole" runat="server" Text="Administrator" /></div>
    </div>
    <div class="ap-field">
        <div class="ap-label"><%= T("Preferred Language", "Bahasa Pilihan") %></div>
        <div class="ap-value"><asp:Literal ID="litLanguage" runat="server" Text="-" /></div>
    </div>
    <div class="ap-field">
        <div class="ap-label"><%= T("Account Status", "Status Akaun") %></div>
        <div class="ap-value"><asp:Literal ID="litStatus" runat="server" Text="-" /></div>
    </div>
</div>
</asp:Content>
