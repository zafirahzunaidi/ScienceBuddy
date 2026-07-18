<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="QuestionBank.aspx.cs"
    Inherits="ScienceBuddy.Admin.QuestionBank" MasterPageFile="~/Site.Master"
    Title="Question Bank" %>

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
        <a href="<%: ResolveUrl("~/Admin/StudentManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-people item-icon"></i><span class="item-label">Students</span></a>
        <a href="<%: ResolveUrl("~/Admin/ParentManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-heart item-icon"></i><span class="item-label">Parents</span></a>
        <a href="<%: ResolveUrl("~/Admin/TeacherManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-badge item-icon"></i><span class="item-label">Teachers</span></a>
        <a href="<%: ResolveUrl("~/Admin/TeacherCertificateApproval.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-check item-icon"></i><span class="item-label">Teacher Certificate Approval</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Learning Content</div>
        <a href="<%: ResolveUrl("~/Admin/LessonManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label">Lessons</span></a>
        <a href="<%: ResolveUrl("~/Admin/QuizManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label">Quizzes</span></a>
        <a href="<%: ResolveUrl("~/Admin/QuestionBank.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-question-circle item-icon"></i><span class="item-label">Question Bank</span></a>
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

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%= T("Question Bank", "Bank Soalan") %></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<div class="ad-question-bank-hdr">
    <div>
        <div class="ad-question-bank-hdr-title"><i class="bi bi-database" style="color:var(--ad-question-bank);"></i> <%= T("Question Bank", "Bank Soalan") %></div>
        <div class="ad-question-bank-hdr-sub"><%= T("Manage all questions available in the ScienceBuddy system.", "Urus semua soalan yang tersedia dalam sistem ScienceBuddy.") %></div>
    </div>
    <a href="javascript:;" class="ad-question-bank-abtn ad-question-bank-abtn-view" onclick="location.reload();" style="padding:8px 16px;"><i class="bi bi-arrow-clockwise"></i> <%= T("Refresh", "Muat Semula") %></a>
</div>

<!-- STATS -->
<div class="ad-question-bank-stats">
    <div class="ad-question-bank-stat s1"><div class="ad-question-bank-stat-ico" style="background:#E0F2FE;color:#0EA5E9;"><i class="bi bi-collection-fill"></i></div><div><div class="ad-question-bank-stat-val"><asp:Literal ID="litTotal" runat="server" Text="0" /></div><div class="ad-question-bank-stat-lbl"><%= T("Total Questions", "Jumlah Soalan") %></div></div></div>
    <div class="ad-question-bank-stat s2"><div class="ad-question-bank-stat-ico" style="background:#EEF2FF;color:#6366F1;"><i class="bi bi-ui-radios"></i></div><div><div class="ad-question-bank-stat-val"><asp:Literal ID="litMCQ" runat="server" Text="0" /></div><div class="ad-question-bank-stat-lbl"><%= T("MCQ", "Aneka Pilihan") %></div></div></div>
    <div class="ad-question-bank-stat s3"><div class="ad-question-bank-stat-ico" style="background:#ECFDF5;color:#059669;"><i class="bi bi-check2-circle"></i></div><div><div class="ad-question-bank-stat-val"><asp:Literal ID="litTF" runat="server" Text="0" /></div><div class="ad-question-bank-stat-lbl"><%= T("True / False", "Betul / Salah") %></div></div></div>
    <div class="ad-question-bank-stat s4"><div class="ad-question-bank-stat-ico" style="background:#FEF3C7;color:#D97706;"><i class="bi bi-puzzle"></i></div><div><div class="ad-question-bank-stat-val"><asp:Literal ID="litOther" runat="server" Text="0" /></div><div class="ad-question-bank-stat-lbl"><%= T("Other Types", "Jenis Lain") %></div></div></div>
</div>

<!-- TOOLBAR -->
<div class="ad-question-bank-toolbar">
    <div class="ad-question-bank-search"><i class="bi bi-search"></i><asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" /></div>
    <asp:DropDownList ID="ddlType" runat="server" Cssclass="ad-question-bank-filter"><asp:ListItem Value="" Text="All Types" /><asp:ListItem Value="MCQ" Text="MCQ" /><asp:ListItem Value="True/False" Text="True/False" /><asp:ListItem Value="Multi Select" Text="Multi Select" /><asp:ListItem Value="Drag & Drop" Text="Drag & Drop" /><asp:ListItem Value="Fill in the Blank" Text="Fill in the Blank" /></asp:DropDownList>
    <asp:DropDownList ID="ddlDiff" runat="server" Cssclass="ad-question-bank-filter"><asp:ListItem Value="" Text="All Difficulty" /><asp:ListItem Value="Easy" Text="Easy" /><asp:ListItem Value="Medium" Text="Medium" /><asp:ListItem Value="Hard" Text="Hard" /></asp:DropDownList>
    <asp:DropDownList ID="ddlStatus" runat="server" Cssclass="ad-question-bank-filter"><asp:ListItem Value="" Text="All Status" /><asp:ListItem Value="Approved" Text="Approved" /><asp:ListItem Value="Pending" Text="Pending" /><asp:ListItem Value="Rejected" Text="Rejected" /><asp:ListItem Value="Disabled" Text="Disabled" /></asp:DropDownList>
    <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="sb-btn sb-btn-primary sb-btn-sm" OnClick="btnSearch_Click" />
    <asp:Button ID="btnReset" runat="server" Text="Reset" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnReset_Click" />
</div>

<!-- CARDS -->
<div class="ad-question-bank-grid" id="qbGrid">
    <asp:Repeater ID="rptQuestions" runat="server"><ItemTemplate>
        <div class="ad-question-bank-card">
            <div class="ad-question-bank-card-top">
                <span class="ad-question-bank-card-id"><%# Eval("questionId") %></span>
                <div class="ad-question-bank-card-badges"><span class='ad-question-bank-bdg <%# Eval("typeCls") %>'><%# Eval("questionType") %></span><span class='ad-question-bank-bdg <%# Eval("diffCls") %>'><%# Eval("difficulty") %></span></div>
            </div>
            <div class="ad-question-bank-card-text"><%# HttpUtility.HtmlEncode(Eval("questionText")) %></div>
            <div class="ad-question-bank-card-meta">
                <span><i class="bi bi-person"></i> <%# Eval("teacherName") %></span>
                <span><i class="bi bi-bookmark"></i> <%# Eval("subtopicName") %></span>
                <span><i class="bi bi-calendar3"></i> <%# Eval("createdAt") %></span>
            </div>
            <div class="ad-question-bank-card-actions">
                <a href="javascript:;" class="ad-question-bank-abtn ad-question-bank-abtn-view" data-json='<%# HttpUtility.HtmlAttributeEncode(Eval("jsonData").ToString()) %>' onclick="viewQ(JSON.parse(this.getAttribute('data-json')))"><i class="bi bi-eye"></i> <%= T("View","Lihat") %></a>
                <a href="javascript:;" class="ad-question-bank-abtn ad-question-bank-abtn-edit" onclick="editQ('<%# Eval("questionId") %>')"><i class="bi bi-pencil"></i> <%= T("Edit","Sunting") %></a>
            </div>
        </div>
    </ItemTemplate></asp:Repeater>
</div>

<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="ad-question-bank-empty"><i class="bi bi-database-slash"></i><div style="font-size:1rem;font-weight:600;color:var(--color-text-secondary);"><%= T("No questions available.", "Tiada soalan tersedia.") %></div><div style="font-size:.85rem;margin-top:4px;"><%= T("Adjust your filters or check the Question Requests page.", "Ubah penapis anda atau semak halaman Permintaan Soalan.") %></div></div>
</asp:Panel>

<!-- VIEW MODAL -->
<div class="ad-question-bank-overlay" id="qbViewModal">
    <div class="ad-question-bank-modal">
        <div class="ad-question-bank-modal-hdr"><span class="ad-question-bank-modal-title"><i class="bi bi-eye" style="color:var(--ad-question-bank);"></i> <%= T("Question Details","Butiran Soalan") %></span><button class="ad-question-bank-modal-close" onclick="document.getElementById('qbViewModal').classList.remove('active')"><i class="bi bi-x-lg"></i></button></div>
        <div class="ad-question-bank-modal-body" id="qbViewBody"></div>
    </div>
</div>

<!-- EDIT MODAL -->
<div class="ad-question-bank-overlay" id="qbEditModal">
    <div class="ad-question-bank-modal">
        <div class="ad-question-bank-modal-hdr"><span class="ad-question-bank-modal-title"><i class="bi bi-pencil" style="color:#6366F1;"></i> <%= T("Edit Question","Sunting Soalan") %></span><button class="ad-question-bank-modal-close" onclick="document.getElementById('qbEditModal').classList.remove('active')"><i class="bi bi-x-lg"></i></button></div>
        <div class="ad-question-bank-modal-body" id="qbEditBody"><p style="color:var(--color-text-muted);text-align:center;padding:2rem;"><%= T("Loading...","Memuatkan...") %></p></div>
    </div>
</div>

<script>
function viewQ(d){
    var h='<div class="ad-question-bank-info-grid">';
    h+='<div class="ad-question-bank-full" style="background:var(--ad-question-bank-light);border:1px solid var(--ad-question-bank,#BAE6FD);"><h4><i class="bi bi-chat-square-text"></i> <%= T("Question Text","Teks Soalan") %></h4><p style="margin:0;font-size:.9rem;font-weight:600;line-height:1.6;">'+d.text+'</p></div>';
    h+='<div class="ad-question-bank-info-item"><div class="lbl"><i class="bi bi-hash"></i> ID</div><div class="val">'+d.id+'</div></div>';
    h+='<div class="ad-question-bank-info-item"><div class="lbl"><i class="bi bi-person"></i> <%= T("Teacher","Guru") %></div><div class="val">'+d.teacher+'</div></div>';
    h+='<div class="ad-question-bank-info-item"><div class="lbl"><i class="bi bi-tag"></i> <%= T("Type","Jenis") %></div><div class="val">'+d.type+'</div></div>';
    h+='<div class="ad-question-bank-info-item"><div class="lbl"><i class="bi bi-speedometer2"></i> <%= T("Difficulty","Kesukaran") %></div><div class="val">'+d.diff+'</div></div>';
    h+='<div class="ad-question-bank-info-item"><div class="lbl"><i class="bi bi-bookmark"></i> <%= T("Subtopic","Subtopik") %></div><div class="val">'+d.subtopic+'</div></div>';
    h+='<div class="ad-question-bank-info-item"><div class="lbl"><i class="bi bi-translate"></i> <%= T("Language","Bahasa") %></div><div class="val">'+(d.lang||'-')+'</div></div>';
    h+='<div class="ad-question-bank-info-item"><div class="lbl"><i class="bi bi-calendar3"></i> <%= T("Created","Dicipta") %></div><div class="val">'+d.date+'</div></div>';
    h+='<div class="ad-question-bank-info-item"><div class="lbl"><i class="bi bi-info-circle"></i> <%= T("Status","Status") %></div><div class="val">'+d.status+'</div></div>';
    if(d.optA){
        h+='<div class="ad-question-bank-full"><h4><i class="bi bi-list-check"></i> <%= T("Answer Options","Pilihan Jawapan") %></h4>';
        [{l:"A",v:d.optA},{l:"B",v:d.optB},{l:"C",v:d.optC},{l:"D",v:d.optD}].forEach(function(o){
            if(!o.v)return;
            var c=(d.correct===o.l);
            h+='<div class="ad-question-bank-opt'+(c?' correct':'')+'"><strong>'+o.l+')</strong> '+o.v+(c?' <i class="bi bi-check-circle-fill" style="color:#059669;margin-left:6px;"></i>':'')+'</div>';
        });
        h+='<div style="margin-top:10px;padding:8px 12px;background:#D1FAE5;border-radius:8px;font-size:.8rem;color:#065F46;font-weight:600;"><i class="bi bi-check-circle-fill"></i> <%= T("Correct Answer","Jawapan Betul") %>: '+d.correct+'</div>';
        if(d.explanation){h+='<div style="margin-top:8px;font-size:.8rem;color:#4B5563;line-height:1.5;"><strong><%= T("Explanation","Penjelasan") %>:</strong> '+d.explanation+'</div>';}
        h+='</div>';
    }
    h+='</div>';
    document.getElementById('qbViewBody').innerHTML=h;
    document.getElementById('qbViewModal').classList.add('active');
}

function editQ(qId){
    fetch(window.location.pathname + (window.location.pathname.indexOf('.aspx') === -1 ? '.aspx' : '') + '?handler=GetQuestion&qId='+encodeURIComponent(qId),{method:'POST',headers:{'X-Requested-With':'XMLHttpRequest'}})
    .then(function(r){return r.json();}).then(function(d){
        if(!d.success){Swal.fire({icon:'error',title:'Error',text:d.msg});return;}
        var q=d.data;
        var h='<div class="ad-question-bank-edit-form">';
        h+='<div style="font-size:.8rem;color:var(--color-text-muted);margin-bottom:12px;">ID: <strong>'+q.id+'</strong></div>';
        h+='<div class="ad-question-bank-info-grid">';
        h+='<div class="ad-question-bank-info-item" style="grid-column:1/-1;"><label class="lbl"><%= T("Question Text (EN)","Teks Soalan (EN)") %></label><textarea id="eTextEN" style="width:100%;min-height:70px;padding:9px 12px;border:1.5px solid var(--border-color);border-radius:8px;font-size:.875rem;resize:vertical;">'+escH(q.textEN)+'</textarea></div>';
        h+='<div class="ad-question-bank-info-item" style="grid-column:1/-1;"><label class="lbl"><%= T("Question Text (BM)","Teks Soalan (BM)") %></label><textarea id="eTextBM" style="width:100%;min-height:70px;padding:9px 12px;border:1.5px solid var(--border-color);border-radius:8px;font-size:.875rem;resize:vertical;">'+escH(q.textBM)+'</textarea></div>';
        h+='<div class="ad-question-bank-info-item"><label class="lbl">Option A</label><input id="eOptA" value="'+escA(q.optA)+'" style="width:100%;padding:8px 12px;border:1.5px solid var(--border-color);border-radius:8px;font-size:.85rem;"/></div>';
        h+='<div class="ad-question-bank-info-item"><label class="lbl">Option B</label><input id="eOptB" value="'+escA(q.optB)+'" style="width:100%;padding:8px 12px;border:1.5px solid var(--border-color);border-radius:8px;font-size:.85rem;"/></div>';
        h+='<div class="ad-question-bank-info-item"><label class="lbl">Option C</label><input id="eOptC" value="'+escA(q.optC)+'" style="width:100%;padding:8px 12px;border:1.5px solid var(--border-color);border-radius:8px;font-size:.85rem;"/></div>';
        h+='<div class="ad-question-bank-info-item"><label class="lbl">Option D</label><input id="eOptD" value="'+escA(q.optD)+'" style="width:100%;padding:8px 12px;border:1.5px solid var(--border-color);border-radius:8px;font-size:.85rem;"/></div>';
        h+='<div class="ad-question-bank-info-item"><label class="lbl"><%= T("Correct Answer","Jawapan Betul") %></label><select id="eCorrect" style="width:100%;padding:8px;border:1.5px solid var(--border-color);border-radius:8px;"><option value="A"'+(q.correct==="A"?' selected':'')+'>A</option><option value="B"'+(q.correct==="B"?' selected':'')+'>B</option><option value="C"'+(q.correct==="C"?' selected':'')+'>C</option><option value="D"'+(q.correct==="D"?' selected':'')+'>D</option></select></div>';
        h+='<div class="ad-question-bank-info-item"><label class="lbl"><%= T("Difficulty","Kesukaran") %></label><select id="eDiff" style="width:100%;padding:8px;border:1.5px solid var(--border-color);border-radius:8px;"><option value="Easy"'+(q.diff==="Easy"?' selected':'')+'>Easy</option><option value="Medium"'+(q.diff==="Medium"?' selected':'')+'>Medium</option><option value="Hard"'+(q.diff==="Hard"?' selected':'')+'>Hard</option></select></div>';
        h+='</div>';
        h+='<div style="display:flex;gap:8px;justify-content:flex-end;margin-top:20px;padding-top:14px;border-top:1px solid var(--border-color);">';
        h+='<button type="button" onclick="document.getElementById(\'qbEditModal\').classList.remove(\'active\')" style="padding:9px 20px;border-radius:8px;border:1.5px solid var(--border-color);background:#fff;font-weight:600;cursor:pointer;"><%= T("Cancel","Batal") %></button>';
        h+='<button type="button" onclick="saveEdit(\''+q.id+'\')" style="padding:9px 24px;border-radius:8px;border:none;background:linear-gradient(135deg,#0EA5E9,#0284C7);color:#fff;font-weight:700;cursor:pointer;box-shadow:0 2px 8px rgba(14,165,233,.3);"><i class="bi bi-floppy"></i> <%= T("Save Changes","Simpan Perubahan") %></button>';
        h+='</div></div>';
        document.getElementById('qbEditBody').innerHTML=h;
        document.getElementById('qbEditModal').classList.add('active');
    });
}

function saveEdit(qId){
    Swal.fire({title:'<%= T("Update Question?","Kemas Kini Soalan?") %>',text:'<%= T("Are you sure you want to save these changes?","Adakah anda pasti mahu menyimpan perubahan ini?") %>',icon:'question',showCancelButton:true,confirmButtonColor:'#0EA5E9',confirmButtonText:'<%= T("Save","Simpan") %>',cancelButtonText:'<%= T("Cancel","Batal") %>'}).then(function(r){
        if(!r.isConfirmed)return;
        var params='qId='+encodeURIComponent(qId)+'&textEN='+encodeURIComponent(document.getElementById('eTextEN').value)+'&textBM='+encodeURIComponent(document.getElementById('eTextBM').value)+'&optA='+encodeURIComponent(document.getElementById('eOptA').value)+'&optB='+encodeURIComponent(document.getElementById('eOptB').value)+'&optC='+encodeURIComponent(document.getElementById('eOptC').value)+'&optD='+encodeURIComponent(document.getElementById('eOptD').value)+'&correct='+encodeURIComponent(document.getElementById('eCorrect').value)+'&diff='+encodeURIComponent(document.getElementById('eDiff').value);
        fetch(window.location.pathname + (window.location.pathname.indexOf('.aspx') === -1 ? '.aspx' : '') + '?handler=SaveQuestion&'+params,{method:'POST',headers:{'X-Requested-With':'XMLHttpRequest'}})
        .then(function(r){return r.json();}).then(function(d){
            document.getElementById('qbEditModal').classList.remove('active');
            if(d.success){Swal.fire({icon:'success',title:'<%= T("Saved!","Disimpan!") %>',text:'<%= T("Question updated successfully.","Soalan berjaya dikemas kini.") %>',confirmButtonColor:'#0EA5E9',timer:2500,timerProgressBar:true}).then(function(){location.reload();});}
            else{Swal.fire({icon:'error',title:'Error',text:d.msg});}
        });
    });
}

function disableQ(qId){
    Swal.fire({title:'<%= T("Disable Question?","Nyahaktifkan Soalan?") %>',text:'<%= T("This question will no longer be available for quizzes.","Soalan ini tidak lagi tersedia untuk kuiz.") %>',icon:'warning',showCancelButton:true,confirmButtonColor:'#DC2626',confirmButtonText:'<%= T("Disable","Nyahaktif") %>',cancelButtonText:'<%= T("Cancel","Batal") %>'}).then(function(r){
        if(!r.isConfirmed)return;
        fetch(window.location.pathname + (window.location.pathname.indexOf('.aspx') === -1 ? '.aspx' : '') + '?handler=DisableQuestion&qId='+encodeURIComponent(qId),{method:'POST',headers:{'X-Requested-With':'XMLHttpRequest'}})
        .then(function(r){return r.json();}).then(function(d){
            if(d.success){Swal.fire({icon:'success',title:'<%= T("Disabled!","Dinyahaktifkan!") %>',text:'<%= T("Question has been disabled.","Soalan telah dinyahaktifkan.") %>',confirmButtonColor:'#DC2626',timer:2500,timerProgressBar:true}).then(function(){location.reload();});}
            else{Swal.fire({icon:'error',title:'Error',text:d.msg});}
        });
    });
}
function escH(s){return (s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');}
function escA(s){return (s||'').replace(/&/g,'&amp;').replace(/"/g,'&quot;').replace(/</g,'&lt;').replace(/>/g,'&gt;');}
</script>
</asp:Content>
