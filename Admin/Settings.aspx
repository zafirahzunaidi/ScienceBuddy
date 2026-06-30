<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Settings.aspx.cs"
    Inherits="ScienceBuddy.Admin.Settings" MasterPageFile="~/Site.Master"
    Title="Settings" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root { --admin:#2563EB; --admin-light:#DBEAFE; }
.as-page-header { margin-bottom:var(--space-xl); padding-bottom:var(--space-md); border-bottom:1.5px solid var(--border-color); }
.as-page-title { font-family:var(--font-primary); font-size:1.75rem; font-weight:800; color:var(--color-text); margin-bottom:var(--space-xs); }
.as-page-sub { font-size:.9375rem; color:var(--color-text-secondary); max-width:480px; line-height:1.5; }
.as-section {
    background:var(--color-white); border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color); box-shadow:var(--shadow-sm);
    padding:var(--space-xl); margin-bottom:var(--space-lg); max-width:640px;
}
.as-section-title {
    font-family:var(--font-primary); font-size:1rem; font-weight:800;
    color:var(--color-text); margin-bottom:var(--space-md);
    display:flex; align-items:center; gap:var(--space-sm);
}
.as-field { margin-bottom:var(--space-md); }
.as-label { font-size:.75rem; font-weight:700; text-transform:uppercase; letter-spacing:.5px; color:var(--color-text-muted); margin-bottom:var(--space-xs); }
.as-value { font-size:.9375rem; font-weight:600; color:var(--color-text); }
.as-info {
    font-size:.875rem; color:var(--color-text-secondary); line-height:1.5;
    background:var(--color-surface-alt); border-radius:var(--border-radius);
    padding:var(--space-md); border-left:3px solid var(--admin);
}
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
        <a href="#" class="sb-sidebar-item"><i class="bi bi-question-circle item-icon"></i><span class="item-label">Questions</span></a>
        <a href="<%: ResolveUrl("~/Admin/TeacherMaterials.aspx") %>" class="sb-sidebar-item"><i class="bi bi-file-earmark-text item-icon"></i><span class="item-label">Material Requests</span></a>
        <a href="<%: ResolveUrl("~/Admin/LiveSessions.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label">Live Sessions</span></a>
        <a href="<%: ResolveUrl("~/Admin/QuestionRequests.aspx") %>" class="sb-sidebar-item"><i class="bi bi-clipboard-check item-icon"></i><span class="item-label">Question Requests</span></a>
        <a href="<%: ResolveUrl("~/Admin/CertificateManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-award item-icon"></i><span class="item-label">Certificates</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Gamification</div>
        <a href="<%: ResolveUrl("~/Admin/GamificationManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-trophy item-icon"></i><span class="item-label">Student Performance</span></a>
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
        <a href="<%: ResolveUrl("~/Admin/Profile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a>
        <a href="javascript:;" class="sb-sidebar-item" onclick="showSignOutModal()"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%= T("Settings", "Tetapan") %></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="as-page-header">
    <h1 class="as-page-title"><%= T("Settings", "Tetapan") %></h1>
    <p class="as-page-sub"><%= T("Manage your administrator preferences.", "Urus keutamaan pentadbir anda.") %></p>
</div>

<%-- General --%>
<div class="as-section">
    <div class="as-section-title"><i class="bi bi-sliders" style="color:var(--admin);"></i> <%= T("General", "Umum") %></div>
    <div class="as-field">
        <div class="as-label"><%= T("Preferred Language", "Bahasa Pilihan") %></div>
        <div class="as-value"><asp:Literal ID="litLang" runat="server" Text="-" /></div>
    </div>
    <p style="font-size:.8125rem;color:var(--color-text-muted);"><%= T("Use the EN / BM toggle in the header to switch language.", "Gunakan suis EN / BM di pengepala untuk menukar bahasa.") %></p>
</div>

<%-- Account --%>
<div class="as-section">
    <div class="as-section-title"><i class="bi bi-person-lock" style="color:var(--admin);"></i> <%= T("Account", "Akaun") %></div>
    <div style="display:flex;gap:var(--space-md);flex-wrap:wrap;">
        <button type="button" class="sb-btn sb-btn-outline-primary sb-btn-sm" disabled>
            <i class="bi bi-key"></i> <%= T("Change Password", "Tukar Kata Laluan") %>
        </button>
        <button type="button" class="sb-btn sb-btn-outline-primary sb-btn-sm" disabled>
            <i class="bi bi-envelope"></i> <%= T("Change Email", "Tukar E-mel") %>
        </button>
    </div>
    <p style="font-size:.8125rem;color:var(--color-text-muted);margin-top:var(--space-md);"><%= T("Password and email changes will be available in a future update.", "Perubahan kata laluan dan e-mel akan tersedia dalam kemaskini akan datang.") %></p>
</div>

<%-- Notifications --%>
<div class="as-section">
    <div class="as-section-title"><i class="bi bi-bell" style="color:var(--admin);"></i> <%= T("Notifications", "Notifikasi") %></div>
    <div class="as-info"><%= T("Notification preferences can be configured in a future update.", "Keutamaan notifikasi boleh dikonfigurasi dalam kemaskini akan datang.") %></div>
</div>

<%-- Security --%>
<div class="as-section">
    <div class="as-section-title"><i class="bi bi-shield-lock" style="color:var(--admin);"></i> <%= T("Security", "Keselamatan") %></div>
    <div class="as-info"><%= T("Security settings will be implemented in a future update.", "Tetapan keselamatan akan dilaksanakan dalam kemaskini akan datang.") %></div>
</div>
</asp:Content>
