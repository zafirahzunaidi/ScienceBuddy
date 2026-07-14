<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TeacherMaterials.aspx.cs"
    Inherits="ScienceBuddy.Admin.TeacherMaterials" MasterPageFile="~/Site.Master"
    Title="Material Requests" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Admin.css") %>" rel="stylesheet" />
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" />
<script src="<%: ResolveUrl("~/Scripts/admin-signout.js") %>"></script>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Main</div>
        <a href="<%: ResolveUrl("~/Admin/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label">Dashboard</span></a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">User Management</div>
        <a href="<%: ResolveUrl("~/Admin/StudentManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-people item-icon"></i><span class="item-label">Students</span></a>
        <a href="<%: ResolveUrl("~/Admin/ParentManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-heart item-icon"></i><span class="item-label">Parents</span></a>
        <a href="<%: ResolveUrl("~/Admin/TeacherManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-badge item-icon"></i><span class="item-label">Teachers</span></a>
        <a href="<%: ResolveUrl("~/Admin/TeacherCertificateApproval.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-check item-icon"></i><span class="item-label">Teacher Certificate Approval</span></a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Learning Content</div>
        <a href="<%: ResolveUrl("~/Admin/LessonManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label">Lessons</span></a>
        <a href="<%: ResolveUrl("~/Admin/QuizManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label">Quizzes</span></a>
        <a href="<%: ResolveUrl("~/Admin/QuestionBank.aspx") %>" class="sb-sidebar-item"><i class="bi bi-question-circle item-icon"></i><span class="item-label">Question Bank</span></a>
        <a href="<%: ResolveUrl("~/Admin/TeacherMaterials.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-file-earmark-text item-icon"></i><span class="item-label">Material Requests</span></a>
        <a href="<%: ResolveUrl("~/Admin/LiveSessions.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label">Live Sessions</span></a>
        <a href="<%: ResolveUrl("~/Admin/QuestionRequests.aspx") %>" class="sb-sidebar-item"><i class="bi bi-clipboard-check item-icon"></i><span class="item-label">Question Requests</span></a>
        <a href="<%: ResolveUrl("~/Admin/CertificateManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-award item-icon"></i><span class="item-label">Certificates</span></a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Community</div>
        <a href="<%: ResolveUrl("~/Admin/ForumDiscussions.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label">Forum Discussions</span></a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Gamification</div>
        <a href="<%: ResolveUrl("~/Admin/GamificationManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-trophy item-icon"></i><span class="item-label">Student Performance</span></a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Configuration</div>
        <a href="<%: ResolveUrl("~/Admin/SystemSettings.aspx") %>" class="sb-sidebar-item"><i class="bi bi-gear item-icon"></i><span class="item-label">System Settings</span></a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Logs</div>
        <a href="<%: ResolveUrl("~/Admin/SystemActivityLogs.aspx") %>" class="sb-sidebar-item"><i class="bi bi-clock-history item-icon"></i><span class="item-label">Activity Logs</span></a>
        <a href="<%: ResolveUrl("~/Admin/LoginLogs.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-in-right item-icon"></i><span class="item-label">Login Logs</span></a>
        <a href="<%: ResolveUrl("~/Admin/SuspiciousLogins.aspx") %>" class="sb-sidebar-item"><i class="bi bi-exclamation-triangle item-icon"></i><span class="item-label">Suspicious Logins</span></a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Admin/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span></a>
        <a href="<%: ResolveUrl("~/Admin/Profile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a>
        <a href="javascript:;" class="sb-sidebar-item" onclick="showSignOutModal()"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">Material Requests</asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<!-- PAGE HEADER -->
<div class="ad-material-request-hdr">
    <div class="ad-material-request-hdr-left">
        <div class="ad-material-request-hdr-title"><i class="bi bi-file-earmark-richtext" style="color:var(--ad-material-request);"></i> <%= T("Material Requests", "Permintaan Bahan") %></div>
        <div class="ad-material-request-hdr-sub"><%= T("Review, approve and manage teacher-uploaded learning materials.", "Semak, luluskan dan urus bahan pembelajaran yang dimuat naik oleh guru.") %></div>
    </div>
    <div class="ad-material-request-hdr-right">
        <a href="javascript:;" class="ad-material-request-btn-hdr" onclick="location.reload();"><i class="bi bi-arrow-clockwise"></i> <%= T("Refresh", "Muat Semula") %></a>
    </div>
</div>

<!-- SUMMARY STATS -->
<div class="ad-material-request-stats">
    <div class="ad-material-request-stat s-pending"><div class="ad-material-request-stat-ico ad-material-request-stat-ico-pending"><i class="bi bi-hourglass-split"></i></div><div><div class="ad-material-request-stat-val"><asp:Literal ID="litPending" runat="server" Text="0" /></div><div class="ad-material-request-stat-lbl"><%= T("Pending Reviews", "Menunggu Semakan") %></div></div></div>
    <div class="ad-material-request-stat s-approved"><div class="ad-material-request-stat-ico ad-material-request-stat-ico-approved"><i class="bi bi-check-circle-fill"></i></div><div><div class="ad-material-request-stat-val"><asp:Literal ID="litApproved" runat="server" Text="0" /></div><div class="ad-material-request-stat-lbl"><%= T("Approved", "Diluluskan") %></div></div></div>
    <div class="ad-material-request-stat s-rejected"><div class="ad-material-request-stat-ico ad-material-request-stat-ico-rejected"><i class="bi bi-x-circle-fill"></i></div><div><div class="ad-material-request-stat-val"><asp:Literal ID="litRejected" runat="server" Text="0" /></div><div class="ad-material-request-stat-lbl"><%= T("Rejected", "Ditolak") %></div></div></div>
    <div class="ad-material-request-stat s-total"><div class="ad-material-request-stat-ico ad-material-request-stat-ico-total"><i class="bi bi-archive-fill"></i></div><div><div class="ad-material-request-stat-val"><asp:Literal ID="litTotal" runat="server" Text="0" /></div><div class="ad-material-request-stat-lbl"><%= T("Total Materials", "Jumlah Bahan") %></div></div></div>
</div>

<!-- TOOLBAR -->
<div class="ad-material-request-toolbar">
    <div class="ad-material-request-search"><i class="bi bi-search"></i><input type="text" id="tmSearch" placeholder="<%= T("Search material title, teacher name...", "Cari tajuk bahan, nama guru...") %>" oninput="applyFilters()" /></div>
    <select id="tmStatus" class="ad-material-request-filter" onchange="applyFilters()"><option value=""><%= T("All Status", "Semua Status") %></option><option value="Pending"><%= T("Pending", "Tertunggak") %></option><option value="Approved"><%= T("Approved", "Diluluskan") %></option><option value="Rejected"><%= T("Rejected", "Ditolak") %></option></select>
    <select id="tmType" class="ad-material-request-filter" onchange="applyFilters()"><option value=""><%= T("All Types", "Semua Jenis") %></option><option value="PDF">PDF</option><option value="Video">Video</option><option value="Image">Image</option><option value="PPTX">PPTX</option></select>
    <select id="tmLang" class="ad-material-request-filter" onchange="applyFilters()"><option value=""><%= T("All Languages", "Semua Bahasa") %></option><option value="EN">English</option><option value="BM">Bahasa Melayu</option><option value="BOTH">Both</option></select>
    <select id="tmSort" class="ad-material-request-filter" onchange="applyFilters()"><option value="newest"><%= T("Newest", "Terbaharu") %></option><option value="oldest"><%= T("Oldest", "Terlama") %></option></select>
</div>

<!-- MATERIAL CARDS -->
<div class="ad-material-request-grid" id="tmGrid">
    <asp:Repeater ID="rptMaterials" runat="server">
        <ItemTemplate>
            <div class="ad-material-request-card" data-title='<%# HttpUtility.HtmlAttributeEncode(Eval("materialTitle").ToString()) %>' data-teacher='<%# HttpUtility.HtmlAttributeEncode(Eval("teacherName").ToString()) %>' data-status='<%# Eval("status") %>' data-type='<%# Eval("materialType") %>' data-lang='<%# Eval("language") %>' data-date='<%# Eval("sortDate") %>' data-id='<%# Eval("materialId") %>'>
                <div class='ad-material-request-card-preview <%# GetPreviewClass(Eval("materialType")) %>'>
                    <i class='<%# GetPreviewIcon(Eval("materialType")) %>'></i>
                    <span class='ad-material-request-card-badge <%# GetBadgeClass(Eval("status")) %>'><%# Eval("status") %></span>
                    <span class="ad-material-request-card-type"><%# Eval("materialType") %></span>
                </div>
                <div class="ad-material-request-card-body">
                    <div class="ad-material-request-card-title"><%# HttpUtility.HtmlEncode(Eval("materialTitle")) %></div>
                    <div class="ad-material-request-card-meta">
                        <span><i class="bi bi-person"></i> <%# HttpUtility.HtmlEncode(Eval("teacherName")) %></span>
                        <span><i class="bi bi-bookmark"></i> <%# HttpUtility.HtmlEncode(Eval("subtopicName")) %></span>
                        <span><i class="bi bi-calendar3"></i> <%# Eval("createdDateStr") %></span>
                        <span><i class="bi bi-translate"></i> <%# Eval("language") %></span>
                    </div>
                    <div class="ad-material-request-card-actions">
                        <a class="ad-material-request-abtn ad-material-request-abtn-view" href="javascript:;" data-mat='<%# HttpUtility.HtmlAttributeEncode(Eval("jsonData").ToString()) %>' onclick="viewMaterial(JSON.parse(this.getAttribute('data-mat')))"><i class="bi bi-eye"></i> <%= T("View", "Lihat") %></a>
                        <%# GetActionButtons(Eval("status"), Eval("materialId")) %>
                    </div>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</div>

<!-- EMPTY STATE -->
<div class="ad-material-request-empty" id="tmEmpty"><i class="bi bi-folder2-open"></i><div class="ad-material-request-empty-msg"><%= T("No materials found.", "Tiada bahan dijumpai.") %></div><div class="ad-material-request-empty-sub"><%= T("Try adjusting your filters.", "Cuba ubah penapis anda.") %></div></div>

<!-- VIEW DETAIL MODAL -->
<div class="ad-material-request-modal-overlay" id="tmViewModal">
    <div class="ad-material-request-modal">
        <div class="ad-material-request-modal-hdr"><span class="ad-material-request-modal-title" id="modalTitle"></span><button class="ad-material-request-modal-close" onclick="closeModal()"><i class="bi bi-x-lg"></i></button></div>
        <div class="ad-material-request-modal-body">
            <div class="ad-material-request-modal-preview" id="modalPreview"></div>
            <div class="ad-material-request-modal-info" id="modalInfo"></div>
        </div>
    </div>
</div>

<!-- REJECT REASON MODAL -->
<div class="ad-material-request-reject-modal" id="tmRejectModal">
    <div class="ad-material-request-reject-box">
        <h3><i class="bi bi-x-octagon ad-material-request-reject-icon"></i> <%= T("Reject Material", "Tolak Bahan") %></h3>
        <p style="font-size:.85rem;color:var(--color-text-secondary);margin-bottom:var(--space-md);"><%= T("Please provide a reason for rejecting this material.", "Sila berikan alasan untuk menolak bahan ini.") %></p>
        <textarea id="rejectReason" placeholder="<%= T("Enter reason...", "Masukkan alasan...") %>"></textarea>
        <input type="hidden" id="rejectMatId" />
        <div class="ad-material-request-reject-btns">
            <button class="ad-material-request-reject-cancel" onclick="closeRejectModal()"><%= T("Cancel", "Batal") %></button>
            <button class="ad-material-request-reject-submit" onclick="submitReject()"><i class="bi bi-x-circle"></i> <%= T("Reject", "Tolak") %></button>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>
function applyFilters(){
    var q=document.getElementById('tmSearch').value.toLowerCase();
    var st=document.getElementById('tmStatus').value;
    var tp=document.getElementById('tmType').value;
    var ln=document.getElementById('tmLang').value;
    var sort=document.getElementById('tmSort').value;
    var cards=Array.from(document.querySelectorAll('.ad-material-request-card'));
    var visible=0;
    cards.forEach(function(c){
        var matchQ=!q||c.getAttribute('data-title').toLowerCase().indexOf(q)!==-1||c.getAttribute('data-teacher').toLowerCase().indexOf(q)!==-1||c.getAttribute('data-id').toLowerCase().indexOf(q)!==-1;
        var matchSt=!st||c.getAttribute('data-status')===st;
        var matchTp=!tp||c.getAttribute('data-type')===tp;
        var matchLn=!ln||c.getAttribute('data-lang')===ln;
        if(matchQ&&matchSt&&matchTp&&matchLn){c.style.display='';visible++;}else{c.style.display='none';}
    });
    // Sort
    var grid=document.getElementById('tmGrid');
    var sorted=cards.filter(function(c){return c.style.display!=='none';});
    sorted.sort(function(a,b){var da=a.getAttribute('data-date'),db=b.getAttribute('data-date');return sort==='newest'?db.localeCompare(da):da.localeCompare(db);});
    sorted.forEach(function(c){grid.appendChild(c);});
    cards.filter(function(c){return c.style.display==='none';}).forEach(function(c){grid.appendChild(c);});
    document.getElementById('tmEmpty').classList.toggle('visible',visible===0);
}

function viewMaterial(data){
    document.getElementById('modalTitle').textContent=data.title;
    var preview=document.getElementById('modalPreview');
    var info=document.getElementById('modalInfo');
    // Preview
    var ext=(data.fileUrl||'').split('.').pop().toLowerCase();
    if(data.type==='Image'||['png','jpg','jpeg','gif','webp'].indexOf(ext)!==-1){
        preview.innerHTML='<img src="'+data.fileUrl+'" alt="Preview" onerror="this.parentElement.innerHTML=\'<i class=\\\'bi bi-image\\\' style=\\\'font-size:3rem;color:#ccc;\\\'></i>\'" />';
    }else if(data.type==='Video'||['mp4','webm','ogg'].indexOf(ext)!==-1){
        preview.innerHTML='<video controls style="max-width:100%;max-height:350px;"><source src="'+data.fileUrl+'" /></video>';
    }else if(data.type==='PDF'||ext==='pdf'){
        preview.innerHTML='<iframe src="'+data.fileUrl+'" style="width:100%;height:350px;border:none;"></iframe>';
    }else{
        preview.innerHTML='<div style="text-align:center;padding:2rem;"><i class="bi bi-file-earmark" style="font-size:3rem;color:#94A3B8;"></i><p style="margin-top:1rem;color:var(--color-text-muted);">Preview not available. <a href="'+data.fileUrl+'" target="_blank" style="color:var(--ad-material-request);">Download file</a></p></div>';
    }
    // Info
    info.innerHTML='<div class="ad-material-request-info-item"><div class="ad-material-request-info-label">Material ID</div><div class="ad-material-request-info-value">'+data.id+'</div></div>'
        +'<div class="ad-material-request-info-item"><div class="ad-material-request-info-label">Teacher</div><div class="ad-material-request-info-value">'+data.teacher+'</div></div>'
        +'<div class="ad-material-request-info-item"><div class="ad-material-request-info-label">Subtopic</div><div class="ad-material-request-info-value">'+data.subtopic+'</div></div>'
        +'<div class="ad-material-request-info-item"><div class="ad-material-request-info-label">Type</div><div class="ad-material-request-info-value">'+data.type+'</div></div>'
        +'<div class="ad-material-request-info-item"><div class="ad-material-request-info-label">Language</div><div class="ad-material-request-info-value">'+data.lang+'</div></div>'
        +'<div class="ad-material-request-info-item"><div class="ad-material-request-info-label">Status</div><div class="ad-material-request-info-value">'+data.status+'</div></div>'
        +'<div class="ad-material-request-info-item"><div class="ad-material-request-info-label">Uploaded</div><div class="ad-material-request-info-value">'+data.date+'</div></div>'
        +'<div class="ad-material-request-info-item"><div class="ad-material-request-info-label">Reviewed</div><div class="ad-material-request-info-value">'+(data.reviewed||'-')+'</div></div>';
    document.getElementById('tmViewModal').classList.add('active');
    // Log view
    ajaxAction('view',data.id,'','Viewed material '+data.id);
}
function closeModal(){document.getElementById('tmViewModal').classList.remove('active');}

function approveMaterial(matId){
    Swal.fire({title:'<%= T("Approve this material?","Luluskan bahan ini?") %>',icon:'question',showCancelButton:true,confirmButtonColor:'#059669',confirmButtonText:'<%= T("Approve","Luluskan") %>'}).then(function(r){
        if(r.isConfirmed){ajaxAction('approve',matId,'','',function(){Swal.fire({icon:'success',title:'<%= T("Approved!","Diluluskan!") %>',text:'<%= T("Material approved successfully.","Bahan berjaya diluluskan.") %>',confirmButtonColor:'#059669',timer:2500,timerProgressBar:true});setTimeout(function(){location.reload();},2600);});}
    });
}

function openRejectModal(matId){document.getElementById('rejectMatId').value=matId;document.getElementById('rejectReason').value='';document.getElementById('tmRejectModal').classList.add('active');}
function closeRejectModal(){document.getElementById('tmRejectModal').classList.remove('active');}
function submitReject(){
    var matId=document.getElementById('rejectMatId').value;
    var reason=document.getElementById('rejectReason').value.trim();
    if(!reason){Swal.fire({icon:'warning',title:'Required',text:'<%= T("Please enter a reason.","Sila masukkan alasan.") %>',confirmButtonColor:'#DC2626'});return;}
    closeRejectModal();
    ajaxAction('reject',matId,reason,'',function(){Swal.fire({icon:'success',title:'<%= T("Rejected","Ditolak") %>',text:'<%= T("Material has been rejected.","Bahan telah ditolak.") %>',confirmButtonColor:'#DC2626',timer:2500,timerProgressBar:true});setTimeout(function(){location.reload();},2600);});
}

function reconsiderMaterial(matId){
    Swal.fire({title:'<%= T("Reconsider this material?","Pertimbang semula bahan ini?") %>',text:'<%= T("Status will change back to Pending.","Status akan bertukar semula ke Tertunggak.") %>',icon:'question',showCancelButton:true,confirmButtonColor:'#D97706',confirmButtonText:'<%= T("Reconsider","Pertimbang Semula") %>'}).then(function(r){
        if(r.isConfirmed){ajaxAction('reconsider',matId,'','',function(){Swal.fire({icon:'success',title:'<%= T("Done!","Selesai!") %>',confirmButtonColor:'#D97706',timer:2000,timerProgressBar:true});setTimeout(function(){location.reload();},2100);});}
    });
}

function ajaxAction(action,matId,reason,desc,cb){
    fetch(window.location.pathname + (window.location.pathname.indexOf('.aspx') === -1 ? '.aspx' : '') + '?handler=MaterialAction&action='+encodeURIComponent(action)+'&matId='+encodeURIComponent(matId)+'&reason='+encodeURIComponent(reason),{method:'POST',headers:{'X-Requested-With':'XMLHttpRequest'}}).then(function(r){return r.json();}).then(function(d){if(cb)cb(d);}).catch(function(){});
}
</script>

</asp:Content>
