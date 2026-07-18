<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RecycleBin.aspx.cs"
    Inherits="ScienceBuddy.Admin.RecycleBin" MasterPageFile="~/Site.Master"
    Title="Recycle Bin" ValidateRequest="false" EnableEventValidation="false" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Admin.css") %>" rel="stylesheet" />
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
        <a href="<%: ResolveUrl("~/Admin/StudentManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-people item-icon"></i><span class="item-label">Students</span></a>
        <a href="<%: ResolveUrl("~/Admin/ParentManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-heart item-icon"></i><span class="item-label">Parents</span></a>
        <a href="<%: ResolveUrl("~/Admin/TeacherManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-badge item-icon"></i><span class="item-label">Teachers</span></a>
        <a href="<%: ResolveUrl("~/Admin/TeacherCertificateApproval.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-check item-icon"></i><span class="item-label">Teacher Certificate Approval</span></a>
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

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%= T("Recycle Bin", "Tong Kitar Semula") %></asp:Content>

<%-- ════ MAIN CONTENT ════ --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- PAGE HEADER --%>
<div class="ad-recycle-bin-header">
    <h1 class="ad-recycle-bin-title"><i class="bi bi-trash3-fill" style="color:#DC2626;"></i> <%= T("Recycle Bin", "Tong Kitar Semula") %></h1>
    <p class="ad-recycle-bin-sub"><%= T("Manage deleted user accounts. You can restore or permanently remove them from the system.", "Urus akaun pengguna yang dipadam. Anda boleh memulihkan atau membuang mereka secara kekal dari sistem.") %></p>
</div>

<%-- STATS CARDS --%>
<div class="ad-recycle-bin-stats">
    <div class="ad-recycle-bin-stat">
        <div class="ad-recycle-bin-stat-ico" style="color:#DC2626;"><i class="bi bi-mortarboard-fill"></i></div>
        <div class="ad-recycle-bin-stat-val"><asp:Literal ID="litDeletedStudents" runat="server" Text="0" /></div>
        <div class="ad-recycle-bin-stat-lbl"><%= T("DELETED STUDENTS", "PELAJAR DIPADAM") %></div>
    </div>
    <div class="ad-recycle-bin-stat">
        <div class="ad-recycle-bin-stat-ico" style="color:#D97706;"><i class="bi bi-person-heart"></i></div>
        <div class="ad-recycle-bin-stat-val"><asp:Literal ID="litDeletedParents" runat="server" Text="0" /></div>
        <div class="ad-recycle-bin-stat-lbl"><%= T("DELETED PARENTS", "IBU BAPA DIPADAM") %></div>
    </div>
    <div class="ad-recycle-bin-stat">
        <div class="ad-recycle-bin-stat-ico" style="color:#7C3AED;"><i class="bi bi-person-badge"></i></div>
        <div class="ad-recycle-bin-stat-val"><asp:Literal ID="litDeletedTeachers" runat="server" Text="0" /></div>
        <div class="ad-recycle-bin-stat-lbl"><%= T("DELETED TEACHERS", "GURU DIPADAM") %></div>
    </div>
    <div class="ad-recycle-bin-stat">
        <div class="ad-recycle-bin-stat-ico" style="color:#1D4ED8;"><i class="bi bi-trash3-fill"></i></div>
        <div class="ad-recycle-bin-stat-val"><asp:Literal ID="litTotalDeleted" runat="server" Text="0" /></div>
        <div class="ad-recycle-bin-stat-lbl"><%= T("TOTAL DELETED", "JUMLAH DIPADAM") %></div>
    </div>
</div>

<%-- DELETED USERS TABLE --%>
<div class="ad-recycle-bin-card">
    <div class="ad-recycle-bin-card-hdr"><i class="bi bi-table" style="color:#DC2626;"></i> <%= T("Deleted Users", "Pengguna Dipadam") %></div>

    <asp:Panel ID="pnlTable" runat="server" Visible="false">
        <div style="overflow-x:auto;">
            <table class="ad-dashboard-review-table" style="min-width:700px;">
                <thead>
                    <tr>
                        <th><%= T("User ID", "ID Pengguna") %></th>
                        <th><%= T("Username", "Nama Pengguna") %></th>
                        <th><%= T("Role", "Peranan") %></th>
                        <th><%= T("Full Name", "Nama Penuh") %></th>
                        <th><%= T("Deleted Date", "Tarikh Dipadam") %></th>
                        <th><%= T("Actions", "Tindakan") %></th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptDeleted" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td style="font-weight:600;font-size:.8rem;"><%# Eval("userId") %></td>
                                <td style="font-weight:600;"><%# Eval("username") %></td>
                                <td><span class='ad-dashboard-review-badge <%# Eval("roleCls") %>'><%# Eval("role") %></span></td>
                                <td><%# Eval("fullName") %></td>
                                <td style="color:var(--color-text-muted,#94a3b8);font-size:.8rem;"><%# Eval("deletedDate") %></td>
                                <td>
                                    <button type="button" class="ad-dashboard-review-btn" style="background:#059669;" onclick='confirmRestore("<%# Eval("userId") %>","<%# Eval("username") %>")'><i class="bi bi-arrow-counterclockwise"></i> <%= T("Restore", "Pulihkan") %></button>
                                    <button type="button" class="ad-dashboard-review-btn" style="background:#DC2626;margin-left:6px;" onclick='confirmDelete("<%# Eval("userId") %>","<%# Eval("username") %>","<%# Eval("role") %>")'><i class="bi bi-x-circle"></i> <%= T("Delete", "Padam") %></button>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlEmpty" runat="server">
        <div class="ad-recycle-bin-empty">
            <div class="ad-recycle-bin-empty-ico"><i class="bi bi-trash3"></i></div>
            <div class="ad-recycle-bin-empty-msg"><%= T("No deleted accounts found.", "Tiada akaun dipadam ditemui.") %></div>
        </div>
    </asp:Panel>
</div>

<script>
function confirmRestore(userId, username) {
    Swal.fire({
        title: '<%= T("Restore Account?", "Pulihkan Akaun?") %>',
        html: '<%= T("Are you sure you want to restore the account for", "Adakah anda pasti ingin memulihkan akaun untuk") %> <strong>' + username + '</strong>?',
        icon: 'question',
        showCancelButton: true,
        confirmButtonText: '<i class="bi bi-arrow-counterclockwise"></i> <%= T("Yes, Restore", "Ya, Pulihkan") %>',
        cancelButtonText: '<%= T("Cancel", "Batal") %>',
        confirmButtonColor: '#059669',
        reverseButtons: true
    }).then(function (r) {
        if (!r.isConfirmed) return;
        var fd = new FormData();
        fd.append('userId', userId);
        fetch(window.location.pathname + '?handler=RestoreUser', { method: 'POST', body: fd })
            .then(function (res) { return res.json(); })
            .then(function (d) {
                if (d.success) {
                    Swal.fire({ icon: 'success', title: '<%= T("Restored!", "Dipulihkan!") %>', text: d.msg, confirmButtonColor: '#059669' }).then(function () { location.reload(); });
                } else {
                    Swal.fire({ icon: 'error', title: '<%= T("Error", "Ralat") %>', text: d.msg, confirmButtonColor: '#DC2626' });
                }
            });
    });
}

function confirmDelete(userId, username, role) {
    Swal.fire({
        title: '<%= T("Delete Permanently?", "Padam Secara Kekal?") %>',
        html: '<%= T("This action CANNOT be undone. All data for", "Tindakan ini TIDAK BOLEH dibatalkan. Semua data untuk") %> <strong>' + username + '</strong> (<em>' + role + '</em>) <%= T("will be permanently removed.", "akan dibuang secara kekal.") %>',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonText: '<i class="bi bi-x-circle"></i> <%= T("Yes, Delete Permanently", "Ya, Padam Kekal") %>',
        cancelButtonText: '<%= T("Cancel", "Batal") %>',
        confirmButtonColor: '#DC2626',
        reverseButtons: true
    }).then(function (r) {
        if (!r.isConfirmed) return;
        var fd = new FormData();
        fd.append('userId', userId);
        fd.append('role', role);
        fetch(window.location.pathname + '?handler=DeletePermanently', { method: 'POST', body: fd })
            .then(function (res) { return res.json(); })
            .then(function (d) {
                if (d.success) {
                    Swal.fire({ icon: 'success', title: '<%= T("Deleted!", "Dipadam!") %>', text: d.msg, confirmButtonColor: '#059669' }).then(function () { location.reload(); });
                } else {
                    Swal.fire({ icon: 'error', title: '<%= T("Error", "Ralat") %>', text: d.msg, confirmButtonColor: '#DC2626' });
                }
            });
    });
}
</script>

</asp:Content>
