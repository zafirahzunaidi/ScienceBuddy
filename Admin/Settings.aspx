<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Settings.aspx.cs"
    Inherits="ScienceBuddy.Admin.Settings" MasterPageFile="~/Site.Master"
    Title="Settings" ValidateRequest="false" EnableEventValidation="false" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Admin.css") %>" rel="stylesheet" />
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" />
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="<%: ResolveUrl("~/Scripts/admin-signout.js") %>"></script>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
<div class="sb-nav-section"><div class="sb-nav-section-label">Main</div><a href="<%: ResolveUrl("~/Admin/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label">Dashboard</span></a></div>
<div class="sb-nav-section"><div class="sb-nav-section-label">User Management</div><a href="<%: ResolveUrl("~/Admin/StudentManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-people item-icon"></i><span class="item-label">Students</span></a><a href="<%: ResolveUrl("~/Admin/ParentManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-heart item-icon"></i><span class="item-label">Parents</span></a><a href="<%: ResolveUrl("~/Admin/TeacherManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-badge item-icon"></i><span class="item-label">Teachers</span></a></div>
<div class="sb-nav-section"><div class="sb-nav-section-label">Learning Content</div><a href="<%: ResolveUrl("~/Admin/LessonManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label">Lessons</span></a><a href="<%: ResolveUrl("~/Admin/QuizManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label">Quizzes</span></a><a href="<%: ResolveUrl("~/Admin/QuestionBank.aspx") %>" class="sb-sidebar-item"><i class="bi bi-question-circle item-icon"></i><span class="item-label">Question Bank</span></a><a href="<%: ResolveUrl("~/Admin/TeacherMaterials.aspx") %>" class="sb-sidebar-item"><i class="bi bi-file-earmark-text item-icon"></i><span class="item-label">Material Requests</span></a><a href="<%: ResolveUrl("~/Admin/LiveSessions.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label">Live Sessions</span></a><a href="<%: ResolveUrl("~/Admin/QuestionRequests.aspx") %>" class="sb-sidebar-item"><i class="bi bi-clipboard-check item-icon"></i><span class="item-label">Question Requests</span></a><a href="<%: ResolveUrl("~/Admin/CertificateManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-award item-icon"></i><span class="item-label">Certificates</span></a></div>
<div class="sb-nav-section"><div class="sb-nav-section-label">Community</div><a href="<%: ResolveUrl("~/Admin/ForumDiscussions.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label">Forum Discussions</span></a></div>
<div class="sb-nav-section"><div class="sb-nav-section-label">Gamification</div><a href="<%: ResolveUrl("~/Admin/GamificationManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-trophy item-icon"></i><span class="item-label">Student Performance</span></a></div>
<div class="sb-nav-section"><div class="sb-nav-section-label">Configuration</div><a href="<%: ResolveUrl("~/Admin/SystemSettings.aspx") %>" class="sb-sidebar-item"><i class="bi bi-gear item-icon"></i><span class="item-label">System Settings</span></a></div>
<div class="sb-nav-section"><div class="sb-nav-section-label">Logs</div><a href="<%: ResolveUrl("~/Admin/SystemActivityLogs.aspx") %>" class="sb-sidebar-item"><i class="bi bi-clock-history item-icon"></i><span class="item-label">Activity Logs</span></a><a href="<%: ResolveUrl("~/Admin/LoginLogs.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-in-right item-icon"></i><span class="item-label">Login Logs</span></a><a href="<%: ResolveUrl("~/Admin/SuspiciousLogins.aspx") %>" class="sb-sidebar-item"><i class="bi bi-exclamation-triangle item-icon"></i><span class="item-label">Suspicious Logins</span></a></div>
<div class="sb-nav-section"><div class="sb-nav-section-label">Account</div><a href="<%: ResolveUrl("~/Admin/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span></a><a href="<%: ResolveUrl("~/Admin/Profile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a><a href="javascript:;" class="sb-sidebar-item" onclick="showSignOutModal()"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a></div>
</asp:Content>
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">Settings</asp:Content>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<div class="as-page-header">
    <h1 class="as-page-title"><%= T("Settings", "Tetapan") %></h1>
    <p class="as-page-sub"><%= T("Manage your administrator account preferences and security.", "Urus keutamaan akaun pentadbir dan keselamatan anda.") %></p>
</div>

<!-- 1. GENERAL SETTINGS -->
<div class="as-section">
    <div class="as-section-title"><i class="bi bi-sliders" style="color:var(--admin);"></i> <%= T("General Settings", "Tetapan Umum") %></div>
    <div class="as-field">
        <div class="as-label"><%= T("Preferred Language", "Bahasa Pilihan") %></div>
        <div class="as-value"><asp:Literal ID="litLang" runat="server" Text="-" /></div>
        <p class="as-hint"><%= T("Use the EN / BM toggle in the header to switch language. It updates automatically.", "Gunakan suis EN / BM di pengepala untuk menukar bahasa. Ia dikemas kini secara automatik.") %></p>
    </div>
    <div class="as-field">
        <div class="as-label"><%= T("Account Status", "Status Akaun") %></div>
        <div class="as-value"><span class="as-status-badge active"><span class="as-status-dot"></span> <asp:Literal ID="litStatus" runat="server" Text="Active" /></span></div>
    </div>
    <div class="as-field">
        <div class="as-label"><%= T("User Role", "Peranan Pengguna") %></div>
        <div class="as-value"><asp:Literal ID="litRole" runat="server" Text="Administrator" /></div>
    </div>
</div>

<!-- 2. ACCOUNT SETTINGS -->
<div class="as-section">
    <div class="as-section-title"><i class="bi bi-person-lock" style="color:var(--admin);"></i> <%= T("Account Settings", "Tetapan Akaun") %></div>
    <div class="as-actions-row">
        <a href="<%: ResolveUrl("~/Admin/Profile.aspx") %>" class="as-action-btn">
            <i class="bi bi-pencil-square"></i> <%= T("Edit Profile", "Edit Profil") %>
        </a>
        <button type="button" class="as-action-btn" onclick="openChangePasswordModal()">
            <i class="bi bi-key"></i> <%= T("Change Password", "Tukar Kata Laluan") %>
        </button>
    </div>
</div>

<!-- 3. NOTIFICATION SETTINGS -->
<div class="as-section">
    <div class="as-section-title"><i class="bi bi-bell" style="color:var(--admin);"></i> <%= T("Notification Settings", "Tetapan Notifikasi") %></div>
    <div class="as-toggle-list">
        <div class="as-toggle-item">
            <div class="as-toggle-info">
                <div class="as-toggle-name"><%= T("Email Notifications", "Notifikasi E-mel") %></div>
            </div>
            <label class="as-toggle-switch"><input type="checkbox" id="chkEmailNotif" onchange="markNotifChanged()" /><span class="as-toggle-slider"></span></label>
        </div>
        <div class="as-toggle-item">
            <div class="as-toggle-info">
                <div class="as-toggle-name"><%= T("System Announcements", "Pengumuman Sistem") %></div>
            </div>
            <label class="as-toggle-switch"><input type="checkbox" id="chkSysAnnounce" onchange="markNotifChanged()" /><span class="as-toggle-slider"></span></label>
        </div>
        <div class="as-toggle-item">
            <div class="as-toggle-info">
                <div class="as-toggle-name"><%= T("New Teacher Registration Alerts", "Amaran Pendaftaran Guru Baharu") %></div>
            </div>
            <label class="as-toggle-switch"><input type="checkbox" id="chkTeacherReg" onchange="markNotifChanged()" /><span class="as-toggle-slider"></span></label>
        </div>
        <div class="as-toggle-item">
            <div class="as-toggle-info">
                <div class="as-toggle-name"><%= T("Material Request Notifications", "Notifikasi Permintaan Bahan") %></div>
            </div>
            <label class="as-toggle-switch"><input type="checkbox" id="chkMaterialReq" onchange="markNotifChanged()" /><span class="as-toggle-slider"></span></label>
        </div>
        <div class="as-toggle-item">
            <div class="as-toggle-info">
                <div class="as-toggle-name"><%= T("Question Request Notifications", "Notifikasi Permintaan Soalan") %></div>
            </div>
            <label class="as-toggle-switch"><input type="checkbox" id="chkQuestionReq" onchange="markNotifChanged()" /><span class="as-toggle-slider"></span></label>
        </div>
        <div class="as-toggle-item">
            <div class="as-toggle-info">
                <div class="as-toggle-name"><%= T("Quiz Review Notifications", "Notifikasi Semakan Kuiz") %></div>
            </div>
            <label class="as-toggle-switch"><input type="checkbox" id="chkQuizReview" onchange="markNotifChanged()" /><span class="as-toggle-slider"></span></label>
        </div>
    </div>
    <div class="as-save-row" id="notifSaveRow" style="display:none;">
        <button type="button" class="as-btn-save" onclick="saveNotificationSettings()"><i class="bi bi-floppy"></i> <%= T("Save Changes", "Simpan Perubahan") %></button>
    </div>
</div>

<!-- 4. SECURITY SETTINGS -->
<div class="as-section">
    <div class="as-section-title"><i class="bi bi-shield-lock" style="color:var(--admin);"></i> <%= T("Security", "Keselamatan") %></div>
    <div class="as-field">
        <div class="as-label"><%= T("Last Login", "Log Masuk Terakhir") %></div>
        <div class="as-value"><asp:Literal ID="litLastLogin" runat="server" Text="-" /></div>
    </div>
    <div class="as-field">
        <div class="as-label"><%= T("Last Password Change", "Perubahan Kata Laluan Terakhir") %></div>
        <div class="as-value"><asp:Literal ID="litLastPwChange" runat="server" Text="-" /></div>
    </div>
    <div class="as-field">
        <div class="as-label"><%= T("Current Session", "Sesi Semasa") %></div>
        <div class="as-value"><span class="as-status-badge active"><span class="as-status-dot"></span> <%= T("Active", "Aktif") %></span></div>
    </div>
    <div class="as-actions-row" style="margin-top:var(--space-md);">
        <button type="button" class="as-action-btn danger" onclick="signOutAllDevices()">
            <i class="bi bi-box-arrow-right"></i> <%= T("Sign Out From All Devices", "Log Keluar Dari Semua Peranti") %>
        </button>
    </div>
</div>

<!-- 5. SYSTEM INFORMATION -->
<div class="as-section">
    <div class="as-section-title"><i class="bi bi-info-circle" style="color:var(--admin);"></i> <%= T("System Information", "Maklumat Sistem") %></div>
    <div class="as-field">
        <div class="as-label"><%= T("Application", "Aplikasi") %></div>
        <div class="as-value">ScienceBuddy Admin System</div>
    </div>
    <div class="as-field">
        <div class="as-label"><%= T("Version", "Versi") %></div>
        <div class="as-value">1.0.0</div>
    </div>
    <div class="as-field">
        <div class="as-label"><%= T("Database", "Pangkalan Data") %></div>
        <div class="as-value"><asp:Literal ID="litDbName" runat="server" Text="ScienceBuddy_DB" /></div>
    </div>
    <div class="as-field">
        <div class="as-label"><%= T("Server Time", "Masa Pelayan") %></div>
        <div class="as-value"><asp:Literal ID="litServerTime" runat="server" Text="-" /></div>
    </div>
    <div class="as-field">
        <div class="as-label"><%= T("Application Status", "Status Aplikasi") %></div>
        <div class="as-value"><span class="as-status-badge active"><span class="as-status-dot"></span> <%= T("Running", "Berjalan") %></span></div>
    </div>
</div>

<!-- 6. DANGER ZONE -->
<div class="as-section as-danger-section">
    <div class="as-section-title"><i class="bi bi-exclamation-triangle-fill" style="color:#DC2626;"></i> <%= T("Danger Zone", "Zon Bahaya") %></div>
    <p class="as-danger-desc"><%= T("Once you delete your account, there is no going back. Please be certain.", "Sebaik sahaja anda memadam akaun, tiada jalan untuk kembali. Sila pastikan.") %></p>
    <button type="button" class="as-btn-danger" onclick="deleteAccount()">
        <i class="bi bi-trash3"></i> <%= T("Delete Account", "Padam Akaun") %>
    </button>
</div>

<!-- CHANGE PASSWORD MODAL -->
<div class="as-modal-overlay" id="pwdModalOverlay">
    <div class="as-modal">
        <div class="as-modal-header">
            <div class="as-modal-title"><%= T("Change Password", "Tukar Kata Laluan") %></div>
            <div class="as-modal-subtitle"><%= T("Enter your current password and choose a new one.", "Masukkan kata laluan semasa dan pilih yang baharu.") %></div>
        </div>
        <div class="as-form-group">
            <label class="as-form-label"><%= T("Current Password", "Kata Laluan Semasa") %></label>
            <input type="password" id="txtCurrentPwd" class="as-form-input" placeholder="<%= T("Enter current password", "Masukkan kata laluan semasa") %>" />
            <div class="as-form-error" id="errCurrentPwd"></div>
        </div>
        <div class="as-form-group">
            <label class="as-form-label"><%= T("New Password", "Kata Laluan Baharu") %></label>
            <input type="password" id="txtNewPwd" class="as-form-input" placeholder="<%= T("Minimum 8 characters", "Minimum 8 aksara") %>" />
            <div class="as-form-error" id="errNewPwd"></div>
        </div>
        <div class="as-form-group">
            <label class="as-form-label"><%= T("Confirm New Password", "Sahkan Kata Laluan Baharu") %></label>
            <input type="password" id="txtConfirmPwd" class="as-form-input" placeholder="<%= T("Re-enter new password", "Masukkan semula kata laluan baharu") %>" />
            <div class="as-form-error" id="errConfirmPwd"></div>
        </div>
        <div class="as-modal-actions">
            <button type="button" class="as-btn as-btn-secondary" onclick="closeChangePasswordModal()"><%= T("Cancel", "Batal") %></button>
            <button type="button" class="as-btn as-btn-primary" onclick="submitChangePassword()"><i class="bi bi-check-lg"></i> <%= T("Change Password", "Tukar Kata Laluan") %></button>
        </div>
    </div>
</div>

<script>
// ---- Notification settings original state ----
var notifOriginal = {};
function initNotifState() {
    ['chkEmailNotif','chkSysAnnounce','chkTeacherReg','chkMaterialReq','chkQuestionReq','chkQuizReview'].forEach(function(id){
        var el = document.getElementById(id);
        if(el) notifOriginal[id] = el.checked;
    });
}
function markNotifChanged() {
    var changed = false;
    Object.keys(notifOriginal).forEach(function(id){
        var el = document.getElementById(id);
        if(el && el.checked !== notifOriginal[id]) changed = true;
    });
    document.getElementById('notifSaveRow').style.display = changed ? '' : 'none';
}

// ---- Save notification settings ----
function saveNotificationSettings() {
    Swal.fire({
        title: '<%= T("Save these changes?", "Simpan perubahan ini?") %>',
        text: '<%= T("Your notification preferences will be updated.", "Keutamaan notifikasi anda akan dikemas kini.") %>',
        icon: 'question',
        showCancelButton: true,
        confirmButtonText: '<%= T("Save", "Simpan") %>',
        cancelButtonText: '<%= T("Cancel", "Batal") %>',
        confirmButtonColor: '#2563EB'
    }).then(function(result){
        if(!result.isConfirmed) return;
        var data = new FormData();
        data.append('action', 'SaveNotifications');
        data.append('emailNotif', document.getElementById('chkEmailNotif').checked ? '1' : '0');
        data.append('sysAnnounce', document.getElementById('chkSysAnnounce').checked ? '1' : '0');
        data.append('teacherReg', document.getElementById('chkTeacherReg').checked ? '1' : '0');
        data.append('materialReq', document.getElementById('chkMaterialReq').checked ? '1' : '0');
        data.append('questionReq', document.getElementById('chkQuestionReq').checked ? '1' : '0');
        data.append('quizReview', document.getElementById('chkQuizReview').checked ? '1' : '0');
        fetch(window.location.pathname + (window.location.pathname.indexOf('.aspx') === -1 ? '.aspx' : ''), { method:'POST', body: data })
        .then(function(r){ return r.json(); })
        .then(function(d){
            if(d.success){
                Swal.fire({icon:'success',title:'<%= T("Saved!", "Disimpan!") %>',text:'<%= T("Notification preferences updated.", "Keutamaan notifikasi dikemas kini.") %>',confirmButtonColor:'#2563EB',timer:2500,showConfirmButton:false});
                initNotifState();
                document.getElementById('notifSaveRow').style.display='none';
            } else {
                Swal.fire({icon:'error',title:'Error',text:d.message||'Failed.',confirmButtonColor:'#2563EB'});
            }
        }).catch(function(){ Swal.fire({icon:'error',title:'Error',text:'Network error.',confirmButtonColor:'#2563EB'}); });
    });
}

// ---- Change Password Modal ----
function openChangePasswordModal() {
    document.getElementById('pwdModalOverlay').classList.add('active');
    document.getElementById('txtCurrentPwd').value='';
    document.getElementById('txtNewPwd').value='';
    document.getElementById('txtConfirmPwd').value='';
    clearPwdErrors();
}
function closeChangePasswordModal() {
    document.getElementById('pwdModalOverlay').classList.remove('active');
}
function clearPwdErrors(){
    ['errCurrentPwd','errNewPwd','errConfirmPwd'].forEach(function(id){
        document.getElementById(id).textContent='';
        document.getElementById(id).classList.remove('visible');
    });
    document.querySelectorAll('#pwdModalOverlay .as-form-input').forEach(function(el){el.classList.remove('error');});
}
function showPwdError(id, msg){
    var el=document.getElementById(id);
    el.textContent=msg; el.classList.add('visible');
    el.previousElementSibling.classList.add('error');
}
function submitChangePassword(){
    clearPwdErrors();
    var cur=document.getElementById('txtCurrentPwd').value.trim();
    var nw=document.getElementById('txtNewPwd').value.trim();
    var cf=document.getElementById('txtConfirmPwd').value.trim();
    var valid=true;
    if(!cur){showPwdError('errCurrentPwd','<%= T("Current password is required.", "Kata laluan semasa diperlukan.") %>');valid=false;}
    if(!nw||nw.length<8){showPwdError('errNewPwd','<%= T("Minimum 8 characters required.", "Minimum 8 aksara diperlukan.") %>');valid=false;}
    if(nw!==cf){showPwdError('errConfirmPwd','<%= T("Passwords do not match.", "Kata laluan tidak sepadan.") %>');valid=false;}
    if(!valid) return;

    Swal.fire({
        title:'<%= T("Change your password?", "Tukar kata laluan anda?") %>',
        icon:'question',
        showCancelButton:true,
        confirmButtonText:'<%= T("Change Password", "Tukar Kata Laluan") %>',
        cancelButtonText:'<%= T("Cancel", "Batal") %>',
        confirmButtonColor:'#2563EB'
    }).then(function(result){
        if(!result.isConfirmed) return;
        var data=new FormData();
        data.append('action','ChangePassword');
        data.append('currentPassword',cur);
        data.append('newPassword',nw);
        fetch(window.location.pathname + (window.location.pathname.indexOf('.aspx') === -1 ? '.aspx' : ''),{method:'POST',body:data})
        .then(function(r){return r.json();})
        .then(function(d){
            if(d.success){
                closeChangePasswordModal();
                Swal.fire({icon:'success',title:'<%= T("Password Changed!", "Kata Laluan Ditukar!") %>',text:'<%= T("Your password has been updated successfully.", "Kata laluan anda telah berjaya dikemas kini.") %>',confirmButtonColor:'#2563EB'});
            } else {
                if(d.field==='current') showPwdError('errCurrentPwd',d.message);
                else Swal.fire({icon:'error',title:'Error',text:d.message||'Failed.',confirmButtonColor:'#2563EB'});
            }
        }).catch(function(){Swal.fire({icon:'error',title:'Error',text:'Network error.',confirmButtonColor:'#2563EB'});});
    });
}

// ---- Sign Out All Devices ----
function signOutAllDevices(){
    Swal.fire({
        html: '<div style="text-align:center;padding:8px 0;">' +
              '<div style="width:64px;height:64px;border-radius:50%;background:#FEE2E2;display:flex;align-items:center;justify-content:center;margin:0 auto 16px;"><i class="bi bi-box-arrow-right" style="font-size:1.5rem;color:#DC2626;"></i></div>' +
              '<h3 style="font-family:var(--font-primary,sans-serif);font-size:1.25rem;font-weight:700;color:#1E293B;margin-bottom:8px;"><%= T("Sign Out From All Devices", "Log Keluar Dari Semua Peranti") %></h3>' +
              '<p style="font-size:.9rem;color:#64748B;margin-bottom:4px;"><%= T("Are you sure you want to sign out from all devices?", "Adakah anda pasti mahu log keluar dari semua peranti?") %></p>' +
              '<p style="font-size:.8rem;color:#94A3B8;"><%= T("You will need to sign in again to continue managing the system.", "Anda perlu log masuk semula untuk terus mengurus sistem.") %></p>' +
              '</div>',
        showCancelButton: true,
        confirmButtonText: '<i class="bi bi-box-arrow-right"></i> <%= T("Sign Out", "Log Keluar") %>',
        cancelButtonText: '<%= T("Cancel", "Batal") %>',
        confirmButtonColor: '#DC2626',
        cancelButtonColor: '#E2E8F0',
        reverseButtons: true,
        customClass: {
            popup: 'sb-signout-popup',
            confirmButton: 'sb-signout-confirm',
            cancelButton: 'sb-signout-cancel'
        },
        backdrop: 'rgba(15,23,42,0.5)',
        allowOutsideClick: true,
        allowEscapeKey: true
    }).then(function(result){
        if(!result.isConfirmed) return;
        var data=new FormData();
        data.append('action','SignOutAll');
        fetch(window.location.pathname + (window.location.pathname.indexOf('.aspx') === -1 ? '.aspx' : ''),{method:'POST',body:data})
        .then(function(r){return r.json();})
        .then(function(d){
            if(d.success){ window.location.href=d.redirect||'../Login.aspx'; }
            else { Swal.fire({icon:'error',title:'Error',text:d.message||'Failed.',confirmButtonColor:'#2563EB'}); }
        }).catch(function(){Swal.fire({icon:'error',title:'Error',text:'Network error.',confirmButtonColor:'#2563EB'});});
    });
}

// ---- Delete Account ----
function deleteAccount(){
    Swal.fire({
        title:'<%= T("Are you sure?", "Adakah anda pasti?") %>',
        text:'<%= T("This action cannot be undone. Your account will be permanently deactivated.", "Tindakan ini tidak boleh dibuat asal. Akaun anda akan dinyahaktifkan secara kekal.") %>',
        icon:'warning',
        showCancelButton:true,
        confirmButtonText:'<%= T("Delete Account", "Padam Akaun") %>',
        cancelButtonText:'<%= T("Cancel", "Batal") %>',
        confirmButtonColor:'#DC2626'
    }).then(function(result){
        if(!result.isConfirmed) return;
        var data=new FormData();
        data.append('action','DeleteAccount');
        fetch(window.location.pathname + (window.location.pathname.indexOf('.aspx') === -1 ? '.aspx' : ''),{method:'POST',body:data})
        .then(function(r){return r.json();})
        .then(function(d){
            if(d.success){ window.location.href=d.redirect||'../Login.aspx'; }
            else { Swal.fire({icon:'error',title:'Error',text:d.message||'Failed.',confirmButtonColor:'#2563EB'}); }
        }).catch(function(){Swal.fire({icon:'error',title:'Error',text:'Network error.',confirmButtonColor:'#2563EB'});});
    });
}

// ---- Init ----
window.addEventListener('load', function(){
    initNotifState();
});
</script>

</asp:Content>
