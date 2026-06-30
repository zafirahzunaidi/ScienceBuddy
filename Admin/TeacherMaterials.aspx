<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TeacherMaterials.aspx.cs"
    Inherits="ScienceBuddy.Admin.TeacherMaterials" MasterPageFile="~/Site.Master"
    Title="Material Requests" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" />
<style>
:root{--tm:#0EA5E9;--tm-dark:#0284C7;--tm-light:#F0F9FF;--tm-pdf:#DC2626;--tm-vid:#7C3AED;--tm-img:#059669;--tm-pptx:#D97706;}

.tm-hdr{display:flex;align-items:center;justify-content:space-between;padding:var(--space-xl) 0 var(--space-lg);border-bottom:1.5px solid var(--border-color);margin-bottom:var(--space-xl);flex-wrap:wrap;gap:var(--space-md);}
.tm-hdr-left{}
.tm-hdr-title{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;color:var(--color-text);display:flex;align-items:center;gap:10px;}
.tm-hdr-sub{font-size:.875rem;color:var(--color-text-secondary);margin-top:4px;}
.tm-hdr-right{display:flex;gap:var(--space-sm);}
.tm-btn-hdr{padding:8px 16px;border-radius:var(--border-radius);border:1.5px solid var(--border-color);background:var(--color-white);color:var(--color-text);font-weight:600;font-size:.8125rem;cursor:pointer;display:inline-flex;align-items:center;gap:6px;transition:all .2s;text-decoration:none;}
.tm-btn-hdr:hover{background:var(--color-surface-alt);transform:translateY(-1px);}

/* Summary */
.tm-stats{display:grid;grid-template-columns:repeat(4,1fr);gap:var(--space-md);margin-bottom:var(--space-xl);}
.tm-stat{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);padding:var(--space-lg);display:flex;align-items:center;gap:var(--space-md);transition:transform .2s,box-shadow .2s;position:relative;overflow:hidden;}
.tm-stat:hover{transform:translateY(-3px);box-shadow:var(--shadow-md);}
.tm-stat::before{content:'';position:absolute;top:0;left:0;right:0;height:3px;}
.tm-stat.s-pending::before{background:linear-gradient(90deg,#F59E0B,#FBBF24);}
.tm-stat.s-approved::before{background:linear-gradient(90deg,#059669,#34D399);}
.tm-stat.s-rejected::before{background:linear-gradient(90deg,#DC2626,#F87171);}
.tm-stat.s-total::before{background:linear-gradient(90deg,#0EA5E9,#38BDF8);}
.tm-stat-ico{width:48px;height:48px;border-radius:var(--border-radius-lg);display:flex;align-items:center;justify-content:center;font-size:1.25rem;flex-shrink:0;}
.tm-stat-val{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;color:var(--color-text);}
.tm-stat-lbl{font-size:.8rem;color:var(--color-text-secondary);font-weight:600;}

/* Toolbar */
.tm-toolbar{display:flex;gap:var(--space-md);margin-bottom:var(--space-xl);flex-wrap:wrap;align-items:center;}
.tm-search{flex:1;min-width:220px;position:relative;}
.tm-search i{position:absolute;left:14px;top:50%;transform:translateY(-50%);color:var(--color-text-muted);}
.tm-search input{width:100%;padding:10px 14px 10px 40px;border:1.5px solid var(--border-color);border-radius:var(--border-radius);font-size:.875rem;transition:border-color .2s,box-shadow .2s;}
.tm-search input:focus{outline:none;border-color:var(--tm);box-shadow:0 0 0 3px rgba(14,165,233,.1);}
.tm-filter{padding:8px 14px;border:1.5px solid var(--border-color);border-radius:var(--border-radius);font-size:.8125rem;font-weight:600;background:var(--color-white);cursor:pointer;transition:all .2s;}
.tm-filter:hover{border-color:var(--tm);}
.tm-filter:focus{outline:none;border-color:var(--tm);}

/* Card grid */
.tm-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:var(--space-lg);margin-bottom:var(--space-xl);}
.tm-card{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);overflow:hidden;transition:transform .25s,box-shadow .25s;}
.tm-card:hover{transform:translateY(-4px);box-shadow:0 12px 30px rgba(0,0,0,.08);}
.tm-card-preview{height:140px;display:flex;align-items:center;justify-content:center;position:relative;overflow:hidden;}
.tm-card-preview.pdf{background:linear-gradient(135deg,#FEF2F2,#FECACA);}
.tm-card-preview.video{background:linear-gradient(135deg,#F5F3FF,#DDD6FE);}
.tm-card-preview.image{background:linear-gradient(135deg,#ECFDF5,#A7F3D0);}
.tm-card-preview.pptx{background:linear-gradient(135deg,#FFFBEB,#FDE68A);}
.tm-card-preview i{font-size:3rem;}
.tm-card-preview.pdf i{color:#DC2626;}
.tm-card-preview.video i{color:#7C3AED;}
.tm-card-preview.image i{color:#059669;}
.tm-card-preview.pptx i{color:#D97706;}
.tm-card-badge{position:absolute;top:10px;right:10px;padding:4px 10px;border-radius:var(--border-radius-full);font-size:.7rem;font-weight:700;text-transform:uppercase;letter-spacing:.3px;}
.tm-badge-pending{background:#FEF3C7;color:#92400E;}
.tm-badge-approved{background:#D1FAE5;color:#065F46;}
.tm-badge-rejected{background:#FEE2E2;color:#991B1B;}
.tm-card-type{position:absolute;top:10px;left:10px;padding:3px 8px;border-radius:var(--border-radius-full);font-size:.65rem;font-weight:700;background:rgba(255,255,255,.9);color:var(--color-text);}
.tm-card-body{padding:var(--space-md) var(--space-lg) var(--space-lg);}
.tm-card-title{font-family:var(--font-primary);font-size:.9375rem;font-weight:700;color:var(--color-text);line-height:1.3;margin-bottom:6px;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;}
.tm-card-meta{font-size:.78rem;color:var(--color-text-muted);display:flex;flex-direction:column;gap:3px;margin-bottom:var(--space-sm);}
.tm-card-meta span{display:flex;align-items:center;gap:5px;}
.tm-card-actions{display:flex;gap:6px;flex-wrap:wrap;padding-top:var(--space-sm);border-top:1px solid #F1F5F9;}
.tm-abtn{padding:5px 12px;border-radius:var(--border-radius);font-size:.75rem;font-weight:700;cursor:pointer;border:1.5px solid var(--border-color);transition:all .2s;display:inline-flex;align-items:center;gap:4px;text-decoration:none;background:var(--color-white);color:var(--color-text-secondary);}
.tm-abtn:hover{transform:translateY(-1px);box-shadow:var(--shadow-sm);}
.tm-abtn-view{border-color:var(--tm);color:var(--tm);}
.tm-abtn-view:hover{background:var(--tm-light);}
.tm-abtn-approve{border-color:#059669;color:#059669;}
.tm-abtn-approve:hover{background:#ECFDF5;}
.tm-abtn-reject{border-color:#DC2626;color:#DC2626;}
.tm-abtn-reject:hover{background:#FEF2F2;}
.tm-abtn-reconsider{border-color:#D97706;color:#D97706;}
.tm-abtn-reconsider:hover{background:#FFFBEB;}
.tm-abtn-download{border-color:#6366F1;color:#6366F1;}
.tm-abtn-download:hover{background:#EEF2FF;}

/* Modal */
.tm-modal-overlay{display:none;position:fixed;top:0;left:var(--sidebar-width,0px);right:0;bottom:0;background:rgba(0,0,0,.5);z-index:1000;align-items:center;justify-content:center;padding:var(--space-xl);}
.tm-modal-overlay.active{display:flex;}
.tm-modal{background:var(--color-white);border-radius:var(--border-radius-xl);width:100%;max-width:750px;max-height:90vh;overflow-y:auto;box-shadow:0 25px 60px rgba(0,0,0,.2);animation:modalIn .3s ease;}
@keyframes modalIn{from{opacity:0;transform:translateY(20px)}to{opacity:1;transform:translateY(0)}}
.tm-modal-hdr{padding:var(--space-lg) var(--space-xl);border-bottom:1px solid var(--border-color);display:flex;align-items:center;justify-content:space-between;}
.tm-modal-title{font-family:var(--font-primary);font-size:1.125rem;font-weight:700;}
.tm-modal-close{width:36px;height:36px;border-radius:var(--border-radius);border:none;background:var(--color-surface-alt);cursor:pointer;display:flex;align-items:center;justify-content:center;font-size:1.1rem;transition:background .2s;}
.tm-modal-close:hover{background:#E2E8F0;}
.tm-modal-body{padding:var(--space-xl);}
.tm-modal-preview{width:100%;min-height:200px;max-height:350px;border-radius:var(--border-radius-lg);overflow:hidden;margin-bottom:var(--space-lg);display:flex;align-items:center;justify-content:center;background:#F8FAFC;border:1px solid var(--border-color);}
.tm-modal-preview img{max-width:100%;max-height:350px;object-fit:contain;}
.tm-modal-preview video{max-width:100%;max-height:350px;}
.tm-modal-preview iframe{width:100%;height:350px;border:none;}
.tm-modal-info{display:grid;grid-template-columns:1fr 1fr;gap:var(--space-md);}
.tm-info-item{padding:var(--space-sm) 0;}
.tm-info-label{font-size:.75rem;font-weight:600;color:var(--color-text-muted);text-transform:uppercase;letter-spacing:.5px;margin-bottom:3px;}
.tm-info-value{font-size:.9rem;font-weight:600;color:var(--color-text);}

/* Reject Modal */
.tm-reject-modal{display:none;position:fixed;top:0;left:var(--sidebar-width,0px);right:0;bottom:0;background:rgba(0,0,0,.5);z-index:1001;align-items:center;justify-content:center;padding:var(--space-xl);}
.tm-reject-modal.active{display:flex;}
.tm-reject-box{background:var(--color-white);border-radius:var(--border-radius-xl);width:100%;max-width:480px;padding:var(--space-xl);box-shadow:0 25px 60px rgba(0,0,0,.2);animation:modalIn .3s ease;}
.tm-reject-box h3{font-family:var(--font-primary);font-size:1.125rem;font-weight:700;margin-bottom:var(--space-md);display:flex;align-items:center;gap:8px;}
.tm-reject-box textarea{width:100%;min-height:100px;padding:12px;border:1.5px solid var(--border-color);border-radius:var(--border-radius);font-size:.875rem;resize:vertical;transition:border-color .2s;}
.tm-reject-box textarea:focus{outline:none;border-color:#DC2626;box-shadow:0 0 0 3px rgba(220,38,38,.1);}
.tm-reject-btns{display:flex;gap:var(--space-sm);justify-content:flex-end;margin-top:var(--space-md);}
.tm-reject-cancel{padding:8px 20px;border-radius:var(--border-radius);border:1.5px solid var(--border-color);background:var(--color-white);font-weight:600;cursor:pointer;transition:all .2s;}
.tm-reject-submit{padding:8px 20px;border-radius:var(--border-radius);border:none;background:linear-gradient(135deg,#DC2626,#EF4444);color:#fff;font-weight:700;cursor:pointer;box-shadow:0 2px 8px rgba(220,38,38,.25);transition:all .2s;}
.tm-reject-submit:hover{transform:translateY(-1px);}

/* Empty */
.tm-empty{display:none;flex-direction:column;align-items:center;justify-content:center;text-align:center;padding:var(--space-2xl);color:var(--color-text-muted);}
.tm-empty.visible{display:flex;}
.tm-empty i{font-size:3rem;opacity:.4;margin-bottom:var(--space-md);}

@media(max-width:1279px){.tm-grid{grid-template-columns:repeat(2,1fr);}.tm-stats{grid-template-columns:repeat(2,1fr);}}
@media(max-width:767px){.tm-grid{grid-template-columns:1fr;}.tm-stats{grid-template-columns:1fr 1fr;}.tm-toolbar{flex-direction:column;}.tm-modal-info{grid-template-columns:1fr;}}
</style>
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
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Learning Content</div>
        <a href="<%: ResolveUrl("~/Admin/LessonManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label">Lessons</span></a>
        <a href="<%: ResolveUrl("~/Admin/QuizManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label">Quizzes</span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-question-circle item-icon"></i><span class="item-label">Questions</span></a>
        <a href="<%: ResolveUrl("~/Admin/TeacherMaterials.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-file-earmark-text item-icon"></i><span class="item-label">Material Requests</span></a>
        <a href="<%: ResolveUrl("~/Admin/LiveSessions.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label">Live Sessions</span></a>
        <a href="<%: ResolveUrl("~/Admin/QuestionRequests.aspx") %>" class="sb-sidebar-item"><i class="bi bi-clipboard-check item-icon"></i><span class="item-label">Question Requests</span></a>
        <a href="<%: ResolveUrl("~/Admin/CertificateManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-award item-icon"></i><span class="item-label">Certificates</span></a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Gamification</div>
        <a href="<%: ResolveUrl("~/Admin/GamificationManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-trophy item-icon"></i><span class="item-label">Gamification</span></a>
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
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item" onclick="return confirm('Are you sure you want to sign out?');"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">Material Requests</asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<!-- PAGE HEADER -->
<div class="tm-hdr">
    <div class="tm-hdr-left">
        <div class="tm-hdr-title"><i class="bi bi-file-earmark-richtext" style="color:var(--tm);"></i> <%= T("Material Requests", "Permintaan Bahan") %></div>
        <div class="tm-hdr-sub"><%= T("Review, approve and manage teacher-uploaded learning materials.", "Semak, luluskan dan urus bahan pembelajaran yang dimuat naik oleh guru.") %></div>
    </div>
    <div class="tm-hdr-right">
        <a href="javascript:;" class="tm-btn-hdr" onclick="location.reload();"><i class="bi bi-arrow-clockwise"></i> <%= T("Refresh", "Muat Semula") %></a>
    </div>
</div>

<!-- SUMMARY STATS -->
<div class="tm-stats">
    <div class="tm-stat s-pending"><div class="tm-stat-ico" style="background:#FEF3C7;color:#D97706;"><i class="bi bi-hourglass-split"></i></div><div><div class="tm-stat-val"><asp:Literal ID="litPending" runat="server" Text="0" /></div><div class="tm-stat-lbl"><%= T("Pending Reviews", "Menunggu Semakan") %></div></div></div>
    <div class="tm-stat s-approved"><div class="tm-stat-ico" style="background:#D1FAE5;color:#059669;"><i class="bi bi-check-circle-fill"></i></div><div><div class="tm-stat-val"><asp:Literal ID="litApproved" runat="server" Text="0" /></div><div class="tm-stat-lbl"><%= T("Approved", "Diluluskan") %></div></div></div>
    <div class="tm-stat s-rejected"><div class="tm-stat-ico" style="background:#FEE2E2;color:#DC2626;"><i class="bi bi-x-circle-fill"></i></div><div><div class="tm-stat-val"><asp:Literal ID="litRejected" runat="server" Text="0" /></div><div class="tm-stat-lbl"><%= T("Rejected", "Ditolak") %></div></div></div>
    <div class="tm-stat s-total"><div class="tm-stat-ico" style="background:#E0F2FE;color:#0EA5E9;"><i class="bi bi-archive-fill"></i></div><div><div class="tm-stat-val"><asp:Literal ID="litTotal" runat="server" Text="0" /></div><div class="tm-stat-lbl"><%= T("Total Materials", "Jumlah Bahan") %></div></div></div>
</div>

<!-- TOOLBAR -->
<div class="tm-toolbar">
    <div class="tm-search"><i class="bi bi-search"></i><input type="text" id="tmSearch" placeholder="<%= T("Search material title, teacher name...", "Cari tajuk bahan, nama guru...") %>" oninput="applyFilters()" /></div>
    <select id="tmStatus" class="tm-filter" onchange="applyFilters()"><option value=""><%= T("All Status", "Semua Status") %></option><option value="Pending"><%= T("Pending", "Tertunggak") %></option><option value="Approved"><%= T("Approved", "Diluluskan") %></option><option value="Rejected"><%= T("Rejected", "Ditolak") %></option></select>
    <select id="tmType" class="tm-filter" onchange="applyFilters()"><option value=""><%= T("All Types", "Semua Jenis") %></option><option value="PDF">PDF</option><option value="Video">Video</option><option value="Image">Image</option><option value="PPTX">PPTX</option></select>
    <select id="tmLang" class="tm-filter" onchange="applyFilters()"><option value=""><%= T("All Languages", "Semua Bahasa") %></option><option value="EN">English</option><option value="BM">Bahasa Melayu</option><option value="BOTH">Both</option></select>
    <select id="tmSort" class="tm-filter" onchange="applyFilters()"><option value="newest"><%= T("Newest", "Terbaharu") %></option><option value="oldest"><%= T("Oldest", "Terlama") %></option></select>
</div>

<!-- MATERIAL CARDS -->
<div class="tm-grid" id="tmGrid">
    <asp:Repeater ID="rptMaterials" runat="server">
        <ItemTemplate>
            <div class="tm-card" data-title='<%# HttpUtility.HtmlAttributeEncode(Eval("materialTitle").ToString()) %>' data-teacher='<%# HttpUtility.HtmlAttributeEncode(Eval("teacherName").ToString()) %>' data-status='<%# Eval("status") %>' data-type='<%# Eval("materialType") %>' data-lang='<%# Eval("language") %>' data-date='<%# Eval("sortDate") %>' data-id='<%# Eval("materialId") %>'>
                <div class='tm-card-preview <%# GetPreviewClass(Eval("materialType")) %>'>
                    <i class='<%# GetPreviewIcon(Eval("materialType")) %>'></i>
                    <span class='tm-card-badge <%# GetBadgeClass(Eval("status")) %>'><%# Eval("status") %></span>
                    <span class="tm-card-type"><%# Eval("materialType") %></span>
                </div>
                <div class="tm-card-body">
                    <div class="tm-card-title"><%# HttpUtility.HtmlEncode(Eval("materialTitle")) %></div>
                    <div class="tm-card-meta">
                        <span><i class="bi bi-person"></i> <%# HttpUtility.HtmlEncode(Eval("teacherName")) %></span>
                        <span><i class="bi bi-bookmark"></i> <%# HttpUtility.HtmlEncode(Eval("subtopicName")) %></span>
                        <span><i class="bi bi-calendar3"></i> <%# Eval("createdDateStr") %></span>
                        <span><i class="bi bi-translate"></i> <%# Eval("language") %></span>
                    </div>
                    <div class="tm-card-actions">
                        <a class="tm-abtn tm-abtn-view" href="javascript:;" onclick='viewMaterial(<%# Eval("jsonData") %>)'><i class="bi bi-eye"></i> <%= T("View", "Lihat") %></a>
                        <%# GetActionButtons(Eval("status"), Eval("materialId")) %>
                    </div>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</div>

<!-- EMPTY STATE -->
<div class="tm-empty" id="tmEmpty"><i class="bi bi-folder2-open"></i><div style="font-size:1rem;font-weight:600;color:var(--color-text-secondary);"><%= T("No materials found.", "Tiada bahan dijumpai.") %></div><div style="font-size:.85rem;margin-top:4px;"><%= T("Try adjusting your filters.", "Cuba ubah penapis anda.") %></div></div>

<!-- VIEW DETAIL MODAL -->
<div class="tm-modal-overlay" id="tmViewModal">
    <div class="tm-modal">
        <div class="tm-modal-hdr"><span class="tm-modal-title" id="modalTitle"></span><button class="tm-modal-close" onclick="closeModal()"><i class="bi bi-x-lg"></i></button></div>
        <div class="tm-modal-body">
            <div class="tm-modal-preview" id="modalPreview"></div>
            <div class="tm-modal-info" id="modalInfo"></div>
        </div>
    </div>
</div>

<!-- REJECT REASON MODAL -->
<div class="tm-reject-modal" id="tmRejectModal">
    <div class="tm-reject-box">
        <h3><i class="bi bi-x-octagon" style="color:#DC2626;"></i> <%= T("Reject Material", "Tolak Bahan") %></h3>
        <p style="font-size:.85rem;color:var(--color-text-secondary);margin-bottom:var(--space-md);"><%= T("Please provide a reason for rejecting this material.", "Sila berikan alasan untuk menolak bahan ini.") %></p>
        <textarea id="rejectReason" placeholder="<%= T("Enter reason...", "Masukkan alasan...") %>"></textarea>
        <input type="hidden" id="rejectMatId" />
        <div class="tm-reject-btns">
            <button class="tm-reject-cancel" onclick="closeRejectModal()"><%= T("Cancel", "Batal") %></button>
            <button class="tm-reject-submit" onclick="submitReject()"><i class="bi bi-x-circle"></i> <%= T("Reject", "Tolak") %></button>
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
    var cards=Array.from(document.querySelectorAll('.tm-card'));
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
        preview.innerHTML='<div style="text-align:center;padding:2rem;"><i class="bi bi-file-earmark" style="font-size:3rem;color:#94A3B8;"></i><p style="margin-top:1rem;color:var(--color-text-muted);">Preview not available. <a href="'+data.fileUrl+'" target="_blank" style="color:var(--tm);">Download file</a></p></div>';
    }
    // Info
    info.innerHTML='<div class="tm-info-item"><div class="tm-info-label">Material ID</div><div class="tm-info-value">'+data.id+'</div></div>'
        +'<div class="tm-info-item"><div class="tm-info-label">Teacher</div><div class="tm-info-value">'+data.teacher+'</div></div>'
        +'<div class="tm-info-item"><div class="tm-info-label">Subtopic</div><div class="tm-info-value">'+data.subtopic+'</div></div>'
        +'<div class="tm-info-item"><div class="tm-info-label">Type</div><div class="tm-info-value">'+data.type+'</div></div>'
        +'<div class="tm-info-item"><div class="tm-info-label">Language</div><div class="tm-info-value">'+data.lang+'</div></div>'
        +'<div class="tm-info-item"><div class="tm-info-label">Status</div><div class="tm-info-value">'+data.status+'</div></div>'
        +'<div class="tm-info-item"><div class="tm-info-label">Uploaded</div><div class="tm-info-value">'+data.date+'</div></div>'
        +'<div class="tm-info-item"><div class="tm-info-label">Reviewed</div><div class="tm-info-value">'+(data.reviewed||'-')+'</div></div>';
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

function downloadMaterial(url){
    if(url){window.open(url,'_blank');}
}

function ajaxAction(action,matId,reason,desc,cb){
    fetch(window.location.pathname+'?handler=MaterialAction&action='+encodeURIComponent(action)+'&matId='+encodeURIComponent(matId)+'&reason='+encodeURIComponent(reason),{method:'POST',headers:{'X-Requested-With':'XMLHttpRequest'}}).then(function(r){return r.json();}).then(function(d){if(cb)cb(d);}).catch(function(){});
}
</script>

</asp:Content>
