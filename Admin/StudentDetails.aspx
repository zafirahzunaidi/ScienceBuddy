<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StudentDetails.aspx.cs"
    Inherits="ScienceBuddy.Admin.StudentDetails" MasterPageFile="~/Site.Master"
    Title="Student Details" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%: ResolveUrl("~/Content/Admin.css") %>" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" />
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="<%: ResolveUrl("~/Scripts/admin-signout.js") %>"></script>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label">Main</div>
        <a href="<%: ResolveUrl("~/Admin/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label">Dashboard</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">User Management</div>
        <a href="<%: ResolveUrl("~/Admin/StudentManagement.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-people item-icon"></i><span class="item-label">Students</span></a>
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

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">Student Details</asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<a href="<%: ResolveUrl("~/Admin/StudentManagement.aspx") %>" class="ad-student-details-back"><i class="bi bi-arrow-left"></i> <%= T("Back to Students", "Kembali ke Pelajar") %></a>

<!-- Profile Card -->
<div class="ad-student-details-profile">
    <div class="ad-student-details-avatar"><asp:Literal ID="litInitials" runat="server" /></div>
    <div class="ad-student-details-info">
        <div class="ad-student-details-name"><asp:Literal ID="litName" runat="server" /></div>
        <div class="ad-student-details-meta">
            <span><i class="bi bi-hash"></i> <asp:Literal ID="litStudentId" runat="server" /></span>
            <span><i class="bi bi-person"></i> <asp:Literal ID="litUsername" runat="server" /></span>
            <span><i class="bi bi-envelope"></i> <asp:Literal ID="litEmail" runat="server" /></span>
            <span><asp:Literal ID="litStatusBadge" runat="server" /></span>
        </div>
    </div>
    <div class="ad-student-details-quick">
        <div class="ad-student-details-quick-item"><div class="ad-student-details-quick-val"><asp:Literal ID="litXP" runat="server" Text="0" /></div><div class="ad-student-details-quick-lbl">XP</div></div>
        <div class="ad-student-details-quick-item"><div class="ad-student-details-quick-val"><asp:Literal ID="litBadges" runat="server" Text="0" /></div><div class="ad-student-details-quick-lbl"><%= T("Badges","Lencana") %></div></div>
        <div class="ad-student-details-quick-item"><div class="ad-student-details-quick-val"><asp:Literal ID="litLessons" runat="server" Text="0" /></div><div class="ad-student-details-quick-lbl"><%= T("Lessons","Pelajaran") %></div></div>
    </div>
</div>

<!-- Tabs -->
<div class="ad-student-details-tabs">
    <div class="ad-student-details-tab active" onclick="switchTab('profile')"><i class="bi bi-person"></i> <%= T("Profile","Profil") %></div>
    <div class="ad-student-details-tab" onclick="switchTab('account')"><i class="bi bi-gear"></i> <%= T("Account","Akaun") %></div>
    <div class="ad-student-details-tab" onclick="switchTab('activity')"><i class="bi bi-clock-history"></i> <%= T("Activity","Aktiviti") %></div>
</div>

<!-- Profile Tab -->
<div class="ad-student-details-panel active" id="tab-profile">
    <asp:Literal ID="litProfileFields" runat="server" />
    <div class="ad-student-details-actions">
        <a href="javascript:;" class="ad-student-details-btn ad-student-details-btn-primary" onclick="editProfile()"><i class="bi bi-pencil"></i> <%= T("Edit Profile","Sunting Profil") %></a>
    </div>
</div>

<!-- Account Tab -->
<div class="ad-student-details-panel" id="tab-account">
    <asp:Literal ID="litAccountFields" runat="server" />
    <div class="ad-student-details-actions">
        <a href="javascript:;" class="ad-student-details-btn ad-student-details-btn-success" id="btnActivate" onclick="changeStatus('Active')"><i class="bi bi-check-circle"></i> <%= T("Activate","Aktifkan") %></a>
        <a href="javascript:;" class="ad-student-details-btn ad-student-details-btn-warning" id="btnBlock" onclick="changeStatus('Blocked')"><i class="bi bi-slash-circle"></i> <%= T("Block","Sekat") %></a>
        <a href="javascript:;" class="ad-student-details-btn" onclick="resetPassword()"><i class="bi bi-key"></i> <%= T("Reset Password","Tetapkan Semula Kata Laluan") %></a>
    </div>
</div>

<!-- Activity Tab -->
<div class="ad-student-details-panel" id="tab-activity">
    <asp:Literal ID="litActivityLog" runat="server" />
</div>



<asp:HiddenField ID="hfStudentId" runat="server" />
<asp:HiddenField ID="hfUserId" runat="server" />
<asp:HiddenField ID="hfStatus" runat="server" />

<script>
var studentId = document.getElementById('<%= hfStudentId.ClientID %>').value;
var userId = document.getElementById('<%= hfUserId.ClientID %>').value;
var basePath = window.location.pathname;
var currentStatus = document.getElementById('<%= hfStatus.ClientID %>').value;

function switchTab(tab){
    document.querySelectorAll('.ad-student-details-tab').forEach(function(t,i){t.classList.remove('active');});
    document.querySelectorAll('.ad-student-details-panel').forEach(function(p){p.classList.remove('active');});
    event.currentTarget.classList.add('active');
    document.getElementById('tab-'+tab).classList.add('active');
}

function editProfile(){
    Swal.fire({title:'<%= T("Edit Profile","Sunting Profil") %>',html:'<div style="text-align:left;"><label style="font-size:.75rem;font-weight:600;display:block;margin-bottom:4px;">Name</label><input id="swalName" class="swal2-input" style="width:100%;margin:0 0 12px;" /><label style="font-size:.75rem;font-weight:600;display:block;margin-bottom:4px;">Email</label><input id="swalEmail" class="swal2-input" style="width:100%;margin:0 0 12px;" /><label style="font-size:.75rem;font-weight:600;display:block;margin-bottom:4px;">Phone</label><input id="swalPhone" class="swal2-input" style="width:100%;margin:0;" /></div>',
        showCancelButton:true,confirmButtonText:'<%= T("Save","Simpan") %>',confirmButtonColor:'#2563EB',
        didOpen:function(){fetch(basePath+'?handler=StudentCRUD&action=getStudent&studentId='+studentId,{method:'POST'}).then(function(r){return r.json();}).then(function(d){if(d.success){document.getElementById('swalName').value=d.data.name;document.getElementById('swalEmail').value=d.data.email;document.getElementById('swalPhone').value=d.data.phone;}});}
    }).then(function(r){if(!r.isConfirmed)return;var params='studentId='+studentId+'&name='+encodeURIComponent(document.getElementById('swalName').value)+'&email='+encodeURIComponent(document.getElementById('swalEmail').value)+'&phone='+encodeURIComponent(document.getElementById('swalPhone').value)+'&levelId=';
        fetch(basePath+'?handler=StudentCRUD&action=edit&'+params,{method:'POST'}).then(function(r){return r.json();}).then(function(d){if(d.success){Swal.fire({icon:'success',title:'<%= T("Updated!","Dikemas Kini!") %>',timer:2000,timerProgressBar:true}).then(function(){location.reload();});}else{Swal.fire({icon:'error',title:'Error',text:d.msg});}});
    });
}

// Disable button based on current status
if(currentStatus==='Active'){document.getElementById('btnActivate').classList.add('ad-details-btn-disabled');}
if(currentStatus==='Blocked'){document.getElementById('btnBlock').classList.add('ad-details-btn-disabled');}

function changeStatus(newStatus){
    if(newStatus==='Active'&&currentStatus==='Active')return;
    if(newStatus==='Blocked'&&currentStatus==='Blocked')return;
    Swal.fire({title:'<%= T("Change Status?","Tukar Status?") %>',input:'textarea',inputPlaceholder:'<%= T("Reason...","Alasan...") %>',showCancelButton:true,confirmButtonText:newStatus,confirmButtonColor:newStatus==='Active'?'#059669':'#D97706'}).then(function(r){
        if(!r.isConfirmed)return;
        fetch(basePath+'?handler=StudentCRUD&action=changeStatus&studentId='+studentId+'&newStatus='+newStatus+'&reason='+encodeURIComponent(r.value||''),{method:'POST'}).then(function(r){return r.json();}).then(function(d){if(d.success){Swal.fire({icon:'success',title:'<%= T("Status Changed!","Status Ditukar!") %>',html:'<div style="text-align:left;font-size:.85rem;margin-top:12px;"><p style="margin-bottom:8px;"><strong><%= T("Email sent to:","E-mel dihantar ke:") %></strong></p><p style="color:#2563EB;font-weight:600;">'+d.emailSent+'</p><p style="margin-top:8px;color:#64748B;"><%= T("Subject:","Subjek:") %> '+(d.emailStatus==='Blocked'?'ScienceBuddy Account Blocked':'ScienceBuddy Account Reactivated')+'</p></div>',confirmButtonColor:'#2563EB'}).then(function(){location.reload();});}else{Swal.fire({icon:'error',title:'Error',text:d.msg});}});
    });
}

function resetPassword(){
    Swal.fire({title:'<%= T("Reset Password?","Tetapkan Semula Kata Laluan?") %>',text:'<%= T("A new temporary password will be generated.","Kata laluan sementara baharu akan dijana.") %>',icon:'question',showCancelButton:true,confirmButtonText:'<%= T("Reset","Tetapkan Semula") %>',confirmButtonColor:'#2563EB'}).then(function(r){
        if(!r.isConfirmed)return;
        fetch(basePath+'?handler=StudentCRUD&action=resetPw&studentId='+studentId,{method:'POST'}).then(function(r){return r.json();}).then(function(d){if(d.success){Swal.fire({icon:'success',title:'<%= T("Password Reset!","Kata Laluan Ditetapkan Semula!") %>',text:'New password: '+d.newPw,confirmButtonColor:'#2563EB'});}else{Swal.fire({icon:'error',title:'Error',text:d.msg});}});
    });
}
</script>
</asp:Content>
