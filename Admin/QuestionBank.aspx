<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="QuestionBank.aspx.cs"
    Inherits="ScienceBuddy.Admin.QuestionBank" MasterPageFile="~/Site.Master"
    Title="Question Bank" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" />
<style>
:root{--qb:#0EA5E9;--qb-dark:#0284C7;--qb-light:#F0F9FF;}
.qb-hdr{display:flex;align-items:center;justify-content:space-between;padding:var(--space-xl) 0 var(--space-lg);border-bottom:1.5px solid var(--border-color);margin-bottom:var(--space-xl);flex-wrap:wrap;gap:var(--space-md);}
.qb-hdr-title{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;color:var(--color-text);display:flex;align-items:center;gap:10px;}
.qb-hdr-sub{font-size:.875rem;color:var(--color-text-secondary);margin-top:4px;max-width:520px;}
.qb-stats{display:grid;grid-template-columns:repeat(4,1fr);gap:var(--space-md);margin-bottom:var(--space-xl);}
.qb-stat{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);padding:var(--space-lg);display:flex;align-items:center;gap:var(--space-md);transition:transform .2s,box-shadow .2s;position:relative;overflow:hidden;}
.qb-stat:hover{transform:translateY(-3px);box-shadow:var(--shadow-md);}
.qb-stat::before{content:'';position:absolute;top:0;left:0;right:0;height:3px;}
.qb-stat.s1::before{background:linear-gradient(90deg,#0EA5E9,#38BDF8);}
.qb-stat.s2::before{background:linear-gradient(90deg,#6366F1,#818CF8);}
.qb-stat.s3::before{background:linear-gradient(90deg,#059669,#34D399);}
.qb-stat.s4::before{background:linear-gradient(90deg,#D97706,#FBBF24);}
.qb-stat-ico{width:46px;height:46px;border-radius:var(--border-radius-lg);display:flex;align-items:center;justify-content:center;font-size:1.2rem;flex-shrink:0;}
.qb-stat-val{font-family:var(--font-primary);font-size:1.6rem;font-weight:800;color:var(--color-text);}
.qb-stat-lbl{font-size:.78rem;color:var(--color-text-secondary);font-weight:600;}
.qb-toolbar{display:flex;gap:var(--space-md);margin-bottom:var(--space-xl);flex-wrap:wrap;align-items:center;background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);padding:var(--space-md) var(--space-lg);}
.qb-search{flex:1;min-width:200px;position:relative;}
.qb-search i{position:absolute;left:12px;top:50%;transform:translateY(-50%);color:var(--color-text-muted);}
.qb-search input{width:100%;padding:9px 12px 9px 38px;border:1.5px solid var(--border-color);border-radius:var(--border-radius);font-size:.875rem;transition:border-color .2s;}
.qb-search input:focus{outline:none;border-color:var(--qb);box-shadow:0 0 0 3px rgba(14,165,233,.1);}
.qb-filter{padding:8px 12px;border:1.5px solid var(--border-color);border-radius:var(--border-radius);font-size:.8rem;background:var(--color-white);}
.qb-filter:focus{outline:none;border-color:var(--qb);}
.qb-grid{display:grid;grid-template-columns:repeat(2,1fr);gap:var(--space-lg);margin-bottom:var(--space-xl);}
.qb-card{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);padding:var(--space-lg);transition:transform .2s,box-shadow .2s;display:flex;flex-direction:column;}
.qb-card:hover{transform:translateY(-3px);box-shadow:var(--shadow-md);}
.qb-card-top{display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:8px;}
.qb-card-id{font-size:.7rem;font-family:monospace;color:var(--color-text-muted);background:var(--color-surface-alt);padding:2px 8px;border-radius:var(--border-radius-full);}
.qb-card-badges{display:flex;gap:4px;flex-wrap:wrap;}
.qb-bdg{padding:3px 8px;border-radius:var(--border-radius-full);font-size:.65rem;font-weight:700;text-transform:uppercase;letter-spacing:.3px;}
.qb-bdg-mcq{background:#EEF2FF;color:#4F46E5;}.qb-bdg-tf{background:#ECFDF5;color:#065F46;}.qb-bdg-multi{background:#FEF3C7;color:#92400E;}.qb-bdg-drag{background:#FDF2F8;color:#9D174D;}.qb-bdg-fill{background:#F0F9FF;color:#0C4A6E;}.qb-bdg-other{background:#F1F5F9;color:#475569;}
.qb-bdg-easy{background:#D1FAE5;color:#065F46;}.qb-bdg-medium{background:#FEF3C7;color:#92400E;}.qb-bdg-hard{background:#FEE2E2;color:#991B1B;}
.qb-card-text{font-size:.9rem;font-weight:600;color:var(--color-text);line-height:1.5;margin-bottom:var(--space-sm);display:-webkit-box;-webkit-line-clamp:3;-webkit-box-orient:vertical;overflow:hidden;flex:1;}
.qb-card-meta{display:flex;flex-wrap:wrap;gap:8px;font-size:.75rem;color:var(--color-text-muted);margin-bottom:var(--space-md);}
.qb-card-meta span{display:flex;align-items:center;gap:3px;}
.qb-card-actions{display:flex;gap:6px;padding-top:var(--space-sm);border-top:1px solid #F1F5F9;}
.qb-abtn{padding:6px 14px;border-radius:var(--border-radius);font-size:.75rem;font-weight:700;cursor:pointer;border:1.5px solid var(--border-color);transition:all .2s;display:inline-flex;align-items:center;gap:4px;text-decoration:none;background:var(--color-white);color:var(--color-text-secondary);}
.qb-abtn:hover{transform:translateY(-1px);box-shadow:var(--shadow-sm);}
.qb-abtn-view{border-color:var(--qb);color:var(--qb);}.qb-abtn-view:hover{background:var(--qb-light);}
.qb-abtn-edit{border-color:#6366F1;color:#6366F1;}.qb-abtn-edit:hover{background:#EEF2FF;}
.qb-abtn-disable{border-color:#DC2626;color:#DC2626;}.qb-abtn-disable:hover{background:#FEF2F2;}
.qb-overlay{display:none;position:fixed;top:0;left:var(--sidebar-width,0px);right:0;bottom:0;background:rgba(0,0,0,.5);z-index:1000;align-items:center;justify-content:center;padding:var(--space-xl);}
.qb-overlay.active{display:flex;}
.qb-modal{background:var(--color-white);border-radius:var(--border-radius-xl);width:100%;max-width:700px;max-height:90vh;overflow-y:auto;box-shadow:0 25px 60px rgba(0,0,0,.2);animation:qbIn .3s ease;}
@keyframes qbIn{from{opacity:0;transform:scale(.95)}to{opacity:1;transform:scale(1)}}
.qb-modal-hdr{padding:var(--space-lg) var(--space-xl);border-bottom:1px solid var(--border-color);display:flex;align-items:center;justify-content:space-between;}
.qb-modal-title{font-family:var(--font-primary);font-size:1.1rem;font-weight:700;display:flex;align-items:center;gap:8px;}
.qb-modal-close{width:36px;height:36px;border-radius:var(--border-radius);border:none;background:var(--color-surface-alt);cursor:pointer;display:flex;align-items:center;justify-content:center;font-size:1.1rem;transition:background .2s;}
.qb-modal-close:hover{background:#E2E8F0;}
.qb-modal-body{padding:var(--space-xl);}
.qb-info-grid{display:grid;grid-template-columns:1fr 1fr;gap:12px;}
.qb-info-item .lbl{font-size:.7rem;font-weight:600;color:var(--color-text-muted);text-transform:uppercase;letter-spacing:.5px;margin-bottom:2px;}
.qb-info-item .val{font-size:.875rem;font-weight:600;color:var(--color-text);}
.qb-full{grid-column:1/-1;background:var(--color-surface-alt);border-radius:var(--border-radius-lg);padding:var(--space-md);margin-top:8px;}
.qb-full h4{font-size:.75rem;font-weight:700;color:var(--color-text-secondary);text-transform:uppercase;letter-spacing:.5px;margin-bottom:8px;}
.qb-opt{padding:8px 12px;border-radius:var(--border-radius);margin-bottom:4px;font-size:.85rem;border:1px solid var(--border-color);background:var(--color-white);}
.qb-opt.correct{background:#D1FAE5;border-color:#6EE7B7;font-weight:700;}
.qb-empty{display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;padding:var(--space-2xl);color:var(--color-text-muted);}
.qb-empty i{font-size:3.5rem;opacity:.4;margin-bottom:var(--space-md);}
@media(max-width:1279px){.qb-stats{grid-template-columns:repeat(2,1fr);}.qb-grid{grid-template-columns:repeat(2,1fr);}}
@media(max-width:767px){.qb-stats{grid-template-columns:1fr 1fr;}.qb-grid{grid-template-columns:1fr;}.qb-toolbar{flex-direction:column;align-items:stretch;}.qb-info-grid{grid-template-columns:1fr;}}
</style>
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

<div class="qb-hdr">
    <div>
        <div class="qb-hdr-title"><i class="bi bi-database" style="color:var(--qb);"></i> <%= T("Question Bank", "Bank Soalan") %></div>
        <div class="qb-hdr-sub"><%= T("Manage all questions available in the ScienceBuddy system.", "Urus semua soalan yang tersedia dalam sistem ScienceBuddy.") %></div>
    </div>
    <a href="javascript:;" class="qb-abtn qb-abtn-view" onclick="location.reload();" style="padding:8px 16px;"><i class="bi bi-arrow-clockwise"></i> <%= T("Refresh", "Muat Semula") %></a>
</div>

<!-- STATS -->
<div class="qb-stats">
    <div class="qb-stat s1"><div class="qb-stat-ico" style="background:#E0F2FE;color:#0EA5E9;"><i class="bi bi-collection-fill"></i></div><div><div class="qb-stat-val"><asp:Literal ID="litTotal" runat="server" Text="0" /></div><div class="qb-stat-lbl"><%= T("Total Questions", "Jumlah Soalan") %></div></div></div>
    <div class="qb-stat s2"><div class="qb-stat-ico" style="background:#EEF2FF;color:#6366F1;"><i class="bi bi-ui-radios"></i></div><div><div class="qb-stat-val"><asp:Literal ID="litMCQ" runat="server" Text="0" /></div><div class="qb-stat-lbl"><%= T("MCQ", "Aneka Pilihan") %></div></div></div>
    <div class="qb-stat s3"><div class="qb-stat-ico" style="background:#ECFDF5;color:#059669;"><i class="bi bi-check2-circle"></i></div><div><div class="qb-stat-val"><asp:Literal ID="litTF" runat="server" Text="0" /></div><div class="qb-stat-lbl"><%= T("True / False", "Betul / Salah") %></div></div></div>
    <div class="qb-stat s4"><div class="qb-stat-ico" style="background:#FEF3C7;color:#D97706;"><i class="bi bi-puzzle"></i></div><div><div class="qb-stat-val"><asp:Literal ID="litOther" runat="server" Text="0" /></div><div class="qb-stat-lbl"><%= T("Other Types", "Jenis Lain") %></div></div></div>
</div>

<!-- TOOLBAR -->
<div class="qb-toolbar">
    <div class="qb-search"><i class="bi bi-search"></i><asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" /></div>
    <asp:DropDownList ID="ddlType" runat="server" CssClass="qb-filter"><asp:ListItem Value="" Text="All Types" /><asp:ListItem Value="MCQ" Text="MCQ" /><asp:ListItem Value="True/False" Text="True/False" /><asp:ListItem Value="Multi Select" Text="Multi Select" /><asp:ListItem Value="Drag & Drop" Text="Drag & Drop" /><asp:ListItem Value="Fill in the Blank" Text="Fill in the Blank" /></asp:DropDownList>
    <asp:DropDownList ID="ddlDiff" runat="server" CssClass="qb-filter"><asp:ListItem Value="" Text="All Difficulty" /><asp:ListItem Value="Easy" Text="Easy" /><asp:ListItem Value="Medium" Text="Medium" /><asp:ListItem Value="Hard" Text="Hard" /></asp:DropDownList>
    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="qb-filter"><asp:ListItem Value="" Text="All Status" /><asp:ListItem Value="Approved" Text="Approved" /><asp:ListItem Value="Pending" Text="Pending" /><asp:ListItem Value="Rejected" Text="Rejected" /><asp:ListItem Value="Disabled" Text="Disabled" /></asp:DropDownList>
    <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="sb-btn sb-btn-primary sb-btn-sm" OnClick="btnSearch_Click" />
    <asp:Button ID="btnReset" runat="server" Text="Reset" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnReset_Click" />
</div>

<!-- CARDS -->
<div class="qb-grid" id="qbGrid">
    <asp:Repeater ID="rptQuestions" runat="server"><ItemTemplate>
        <div class="qb-card">
            <div class="qb-card-top">
                <span class="qb-card-id"><%# Eval("questionId") %></span>
                <div class="qb-card-badges"><span class='qb-bdg <%# Eval("typeCls") %>'><%# Eval("questionType") %></span><span class='qb-bdg <%# Eval("diffCls") %>'><%# Eval("difficulty") %></span></div>
            </div>
            <div class="qb-card-text"><%# HttpUtility.HtmlEncode(Eval("questionText")) %></div>
            <div class="qb-card-meta">
                <span><i class="bi bi-person"></i> <%# Eval("teacherName") %></span>
                <span><i class="bi bi-bookmark"></i> <%# Eval("subtopicName") %></span>
                <span><i class="bi bi-calendar3"></i> <%# Eval("createdAt") %></span>
                <span><i class="bi bi-translate"></i> <%# Eval("language") %></span>
            </div>
            <div class="qb-card-actions">
                <a href="javascript:;" class="qb-abtn qb-abtn-view" data-json='<%# HttpUtility.HtmlAttributeEncode(Eval("jsonData").ToString()) %>' onclick="viewQ(JSON.parse(this.getAttribute('data-json')))"><i class="bi bi-eye"></i> <%= T("View","Lihat") %></a>
                <a href="javascript:;" class="qb-abtn qb-abtn-edit" onclick="editQ('<%# Eval("questionId") %>')"><i class="bi bi-pencil"></i> <%= T("Edit","Sunting") %></a>
                <a href="javascript:;" class="qb-abtn qb-abtn-disable" onclick="disableQ('<%# Eval("questionId") %>')"><i class="bi bi-slash-circle"></i> <%= T("Disable","Nyahaktif") %></a>
            </div>
        </div>
    </ItemTemplate></asp:Repeater>
</div>

<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="qb-empty"><i class="bi bi-database-slash"></i><div style="font-size:1rem;font-weight:600;color:var(--color-text-secondary);"><%= T("No questions available.", "Tiada soalan tersedia.") %></div><div style="font-size:.85rem;margin-top:4px;"><%= T("Adjust your filters or check the Question Requests page.", "Ubah penapis anda atau semak halaman Permintaan Soalan.") %></div></div>
</asp:Panel>

<!-- VIEW MODAL -->
<div class="qb-overlay" id="qbViewModal">
    <div class="qb-modal">
        <div class="qb-modal-hdr"><span class="qb-modal-title"><i class="bi bi-eye" style="color:var(--qb);"></i> <%= T("Question Details","Butiran Soalan") %></span><button class="qb-modal-close" onclick="document.getElementById('qbViewModal').classList.remove('active')"><i class="bi bi-x-lg"></i></button></div>
        <div class="qb-modal-body" id="qbViewBody"></div>
    </div>
</div>

<!-- EDIT MODAL -->
<div class="qb-overlay" id="qbEditModal">
    <div class="qb-modal">
        <div class="qb-modal-hdr"><span class="qb-modal-title"><i class="bi bi-pencil" style="color:#6366F1;"></i> <%= T("Edit Question","Sunting Soalan") %></span><button class="qb-modal-close" onclick="document.getElementById('qbEditModal').classList.remove('active')"><i class="bi bi-x-lg"></i></button></div>
        <div class="qb-modal-body" id="qbEditBody"><p style="color:var(--color-text-muted);text-align:center;padding:2rem;"><%= T("Loading...","Memuatkan...") %></p></div>
    </div>
</div>

<script>
function viewQ(d){
    var h='<div class="qb-info-grid">';
    h+='<div class="qb-full" style="background:var(--qb-light);border:1px solid var(--qb,#BAE6FD);"><h4><i class="bi bi-chat-square-text"></i> <%= T("Question Text","Teks Soalan") %></h4><p style="margin:0;font-size:.9rem;font-weight:600;line-height:1.6;">'+d.text+'</p></div>';
    h+='<div class="qb-info-item"><div class="lbl"><i class="bi bi-hash"></i> ID</div><div class="val">'+d.id+'</div></div>';
    h+='<div class="qb-info-item"><div class="lbl"><i class="bi bi-person"></i> <%= T("Teacher","Guru") %></div><div class="val">'+d.teacher+'</div></div>';
    h+='<div class="qb-info-item"><div class="lbl"><i class="bi bi-tag"></i> <%= T("Type","Jenis") %></div><div class="val">'+d.type+'</div></div>';
    h+='<div class="qb-info-item"><div class="lbl"><i class="bi bi-speedometer2"></i> <%= T("Difficulty","Kesukaran") %></div><div class="val">'+d.diff+'</div></div>';
    h+='<div class="qb-info-item"><div class="lbl"><i class="bi bi-bookmark"></i> <%= T("Subtopic","Subtopik") %></div><div class="val">'+d.subtopic+'</div></div>';
    h+='<div class="qb-info-item"><div class="lbl"><i class="bi bi-translate"></i> <%= T("Language","Bahasa") %></div><div class="val">'+(d.lang||'-')+'</div></div>';
    h+='<div class="qb-info-item"><div class="lbl"><i class="bi bi-calendar3"></i> <%= T("Created","Dicipta") %></div><div class="val">'+d.date+'</div></div>';
    h+='<div class="qb-info-item"><div class="lbl"><i class="bi bi-info-circle"></i> <%= T("Status","Status") %></div><div class="val">'+d.status+'</div></div>';
    if(d.optA){
        h+='<div class="qb-full"><h4><i class="bi bi-list-check"></i> <%= T("Answer Options","Pilihan Jawapan") %></h4>';
        [{l:"A",v:d.optA},{l:"B",v:d.optB},{l:"C",v:d.optC},{l:"D",v:d.optD}].forEach(function(o){
            if(!o.v)return;
            var c=(d.correct===o.l);
            h+='<div class="qb-opt'+(c?' correct':'')+'"><strong>'+o.l+')</strong> '+o.v+(c?' <i class="bi bi-check-circle-fill" style="color:#059669;margin-left:6px;"></i>':'')+'</div>';
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
    fetch(window.location.pathname+'?handler=GetQuestion&qId='+encodeURIComponent(qId),{method:'POST',headers:{'X-Requested-With':'XMLHttpRequest'}})
    .then(function(r){return r.json();}).then(function(d){
        if(!d.success){Swal.fire({icon:'error',title:'Error',text:d.msg});return;}
        var q=d.data;
        var h='<div class="qb-edit-form">';
        h+='<div style="font-size:.8rem;color:var(--color-text-muted);margin-bottom:12px;">ID: <strong>'+q.id+'</strong></div>';
        h+='<div class="qb-info-grid">';
        h+='<div class="qb-info-item" style="grid-column:1/-1;"><label class="lbl"><%= T("Question Text (EN)","Teks Soalan (EN)") %></label><textarea id="eTextEN" style="width:100%;min-height:70px;padding:9px 12px;border:1.5px solid var(--border-color);border-radius:8px;font-size:.875rem;resize:vertical;">'+escH(q.textEN)+'</textarea></div>';
        h+='<div class="qb-info-item" style="grid-column:1/-1;"><label class="lbl"><%= T("Question Text (BM)","Teks Soalan (BM)") %></label><textarea id="eTextBM" style="width:100%;min-height:70px;padding:9px 12px;border:1.5px solid var(--border-color);border-radius:8px;font-size:.875rem;resize:vertical;">'+escH(q.textBM)+'</textarea></div>';
        h+='<div class="qb-info-item"><label class="lbl">Option A</label><input id="eOptA" value="'+escA(q.optA)+'" style="width:100%;padding:8px 12px;border:1.5px solid var(--border-color);border-radius:8px;font-size:.85rem;"/></div>';
        h+='<div class="qb-info-item"><label class="lbl">Option B</label><input id="eOptB" value="'+escA(q.optB)+'" style="width:100%;padding:8px 12px;border:1.5px solid var(--border-color);border-radius:8px;font-size:.85rem;"/></div>';
        h+='<div class="qb-info-item"><label class="lbl">Option C</label><input id="eOptC" value="'+escA(q.optC)+'" style="width:100%;padding:8px 12px;border:1.5px solid var(--border-color);border-radius:8px;font-size:.85rem;"/></div>';
        h+='<div class="qb-info-item"><label class="lbl">Option D</label><input id="eOptD" value="'+escA(q.optD)+'" style="width:100%;padding:8px 12px;border:1.5px solid var(--border-color);border-radius:8px;font-size:.85rem;"/></div>';
        h+='<div class="qb-info-item"><label class="lbl"><%= T("Correct Answer","Jawapan Betul") %></label><select id="eCorrect" style="width:100%;padding:8px;border:1.5px solid var(--border-color);border-radius:8px;"><option value="A"'+(q.correct==="A"?' selected':'')+'>A</option><option value="B"'+(q.correct==="B"?' selected':'')+'>B</option><option value="C"'+(q.correct==="C"?' selected':'')+'>C</option><option value="D"'+(q.correct==="D"?' selected':'')+'>D</option></select></div>';
        h+='<div class="qb-info-item"><label class="lbl"><%= T("Difficulty","Kesukaran") %></label><select id="eDiff" style="width:100%;padding:8px;border:1.5px solid var(--border-color);border-radius:8px;"><option value="Easy"'+(q.diff==="Easy"?' selected':'')+'>Easy</option><option value="Medium"'+(q.diff==="Medium"?' selected':'')+'>Medium</option><option value="Hard"'+(q.diff==="Hard"?' selected':'')+'>Hard</option></select></div>';
        h+='</div>';
        h+='<div style="display:flex;gap:8px;justify-content:flex-end;margin-top:20px;padding-top:14px;border-top:1px solid var(--border-color);">';
        h+='<button onclick="document.getElementById(\'qbEditModal\').classList.remove(\'active\')" style="padding:9px 20px;border-radius:8px;border:1.5px solid var(--border-color);background:#fff;font-weight:600;cursor:pointer;"><%= T("Cancel","Batal") %></button>';
        h+='<button onclick="saveEdit(\''+q.id+'\')" style="padding:9px 24px;border-radius:8px;border:none;background:linear-gradient(135deg,#0EA5E9,#0284C7);color:#fff;font-weight:700;cursor:pointer;box-shadow:0 2px 8px rgba(14,165,233,.3);"><i class="bi bi-floppy"></i> <%= T("Save Changes","Simpan Perubahan") %></button>';
        h+='</div></div>';
        document.getElementById('qbEditBody').innerHTML=h;
        document.getElementById('qbEditModal').classList.add('active');
    });
}

function saveEdit(qId){
    Swal.fire({title:'<%= T("Update Question?","Kemas Kini Soalan?") %>',text:'<%= T("Are you sure you want to save these changes?","Adakah anda pasti mahu menyimpan perubahan ini?") %>',icon:'question',showCancelButton:true,confirmButtonColor:'#0EA5E9',confirmButtonText:'<%= T("Save","Simpan") %>',cancelButtonText:'<%= T("Cancel","Batal") %>'}).then(function(r){
        if(!r.isConfirmed)return;
        var params='qId='+encodeURIComponent(qId)+'&textEN='+encodeURIComponent(document.getElementById('eTextEN').value)+'&textBM='+encodeURIComponent(document.getElementById('eTextBM').value)+'&optA='+encodeURIComponent(document.getElementById('eOptA').value)+'&optB='+encodeURIComponent(document.getElementById('eOptB').value)+'&optC='+encodeURIComponent(document.getElementById('eOptC').value)+'&optD='+encodeURIComponent(document.getElementById('eOptD').value)+'&correct='+encodeURIComponent(document.getElementById('eCorrect').value)+'&diff='+encodeURIComponent(document.getElementById('eDiff').value);
        fetch(window.location.pathname+'?handler=SaveQuestion&'+params,{method:'POST',headers:{'X-Requested-With':'XMLHttpRequest'}})
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
        fetch(window.location.pathname+'?handler=DisableQuestion&qId='+encodeURIComponent(qId),{method:'POST',headers:{'X-Requested-With':'XMLHttpRequest'}})
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
