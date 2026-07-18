<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="liveSession.aspx.cs"
    Inherits="ScienceBuddy.Teacher.liveSession" MasterPageFile="~/Site.Master" Title="Live Sessions" EnableEventValidation="false" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--tp:#6C63FF;--tp2:#8B5CF6;--th:#5A52E0;--tl:#F5F3FF;--tc:#FFF;--tb:#E5E7EB;--tt:#374151;--tm:#6B7280;--ts:#10B981;--te:#EF4444;--tw:#F59E0B;--ti:#3B82F6;}
.ls-page-header{display:flex;align-items:center;justify-content:space-between;margin-bottom:1.5rem;flex-wrap:wrap;gap:1rem;}
.ls-page-header h1{font-size:1.5rem;font-weight:800;color:var(--tt);margin:0;}
.ls-page-header p{font-size:.85rem;color:var(--tm);margin:.2rem 0 0;}
.ls-btn-primary{display:inline-flex;align-items:center;gap:6px;background:var(--tp);border:none;border-radius:10px;padding:.6rem 1.25rem;font-weight:700;font-size:.85rem;color:#fff;cursor:pointer;text-decoration:none;transition:all .2s;box-shadow:0 2px 8px rgba(108,99,255,.15);}
.ls-btn-primary:hover{background:var(--th);box-shadow:0 4px 16px rgba(108,99,255,.25);color:#fff;text-decoration:none;}
/* Action Cards */
.ls-action-row{display:flex;gap:20px;margin-bottom:1.75rem;}
.ls-action-card{width:240px;height:155px;border-radius:18px;padding:1.25rem;cursor:pointer;transition:all .25s;display:flex;flex-direction:column;justify-content:space-between;position:relative;overflow:hidden;color:#fff;}
.ls-action-card:hover{transform:translateY(-4px) scale(1.02);box-shadow:0 12px 32px rgba(0,0,0,.15);}
.ls-action-card:active{transform:translateY(-1px) scale(1);}
.ls-action-schedule{background:linear-gradient(135deg,#6D5EF5,#8478FF);box-shadow:0 4px 16px rgba(109,94,245,.25);}
.ls-action-instant{background:linear-gradient(135deg,#EF4444,#F97373);box-shadow:0 4px 16px rgba(239,68,68,.25);}
.ls-action-icon{width:42px;height:42px;border-radius:12px;background:rgba(255,255,255,.2);display:flex;align-items:center;justify-content:center;font-size:1.2rem;position:relative;}
.ls-live-dot{position:absolute;top:3px;right:3px;width:9px;height:9px;border-radius:50%;background:#fff;animation:lsPulse 1.5s infinite;}
@keyframes lsPulse{0%,100%{opacity:1;}50%{opacity:.4;}}
.ls-action-title{font-size:1rem;font-weight:800;line-height:1.3;}
.ls-action-desc{font-size:.76rem;opacity:.85;line-height:1.4;}
.ls-action-cta{font-size:.75rem;font-weight:700;opacity:.9;display:flex;align-items:center;gap:4px;}
/* Live Now Badge */
.ls-badge-live{background:#DC2626;color:#fff;animation:lsPulse 1.5s infinite;}
/* Stats */
.ls-stats{display:grid;grid-template-columns:repeat(4,1fr);gap:1rem;margin-bottom:1.5rem;}
.ls-stat{background:var(--tc);border:1.5px solid var(--tb);border-radius:16px;padding:1.25rem;box-shadow:0 2px 8px rgba(0,0,0,.04);transition:transform .2s,box-shadow .2s;position:relative;overflow:hidden;}
.ls-stat::after{content:'';position:absolute;bottom:0;left:0;right:0;height:3px;border-radius:0 0 16px 16px;}
.ls-stat:hover{transform:translateY(-3px);box-shadow:0 8px 24px rgba(0,0,0,.08);}
.ls-stat.stat-upcoming::after{background:#3B82F6;}.ls-stat.stat-upcoming:hover{box-shadow:0 8px 24px rgba(59,130,246,.12);}
.ls-stat.stat-completed::after{background:#10B981;}.ls-stat.stat-completed:hover{box-shadow:0 8px 24px rgba(16,185,129,.12);}
.ls-stat.stat-cancelled::after{background:#EF4444;}.ls-stat.stat-cancelled:hover{box-shadow:0 8px 24px rgba(239,68,68,.12);}
.ls-stat.stat-students::after{background:#6366F1;}.ls-stat.stat-students:hover{box-shadow:0 8px 24px rgba(99,102,241,.12);}
.ls-stat-icon{width:40px;height:40px;border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:1.15rem;margin-bottom:.6rem;}
.ls-stat-val{font-size:1.6rem;font-weight:800;color:var(--tt);}
.ls-stat-label{font-size:.82rem;font-weight:600;color:var(--tm);margin-top:3px;}
/* Toolbar */
.ls-toolbar{display:flex;align-items:center;gap:10px;margin-bottom:1.25rem;flex-wrap:wrap;}
.ls-search{width:260px;height:40px;border-radius:10px;border:1.5px solid var(--tb);padding:0 .75rem 0 2.2rem;font-size:.82rem;background:var(--tc);position:relative;transition:border-color .2s;}
.ls-search:focus{border-color:var(--tp);outline:none;}
.ls-search-wrap{position:relative;}.ls-search-wrap i{position:absolute;left:10px;top:50%;transform:translateY(-50%);color:var(--tm);font-size:.85rem;pointer-events:none;}
.ls-select{height:40px;border-radius:10px;border:1.5px solid var(--tb);padding:0 .65rem;font-size:.82rem;background:var(--tc);min-width:130px;}
/* Tabs */
.ls-tabs{display:flex;gap:0;border:1.5px solid var(--tb);border-radius:10px;overflow:hidden;width:fit-content;margin-bottom:1.5rem;}
.ls-tab{padding:.5rem 1.25rem;font-size:.82rem;font-weight:600;border:none;background:var(--tc);color:var(--tm);cursor:pointer;transition:all .15s;}
.ls-tab.active{background:var(--tp);color:#fff;}
.ls-tab:hover:not(.active){background:var(--tl);}
/* Session Cards */
.ls-cards{display:flex;flex-direction:column;gap:1rem;}
.ls-card{background:var(--tc);border:1.5px solid var(--tb);border-radius:16px;padding:1.25rem 1.5rem;box-shadow:0 2px 6px rgba(0,0,0,.02);transition:all .2s;display:flex;align-items:flex-start;gap:1rem;flex-wrap:wrap;}
.ls-card:hover{box-shadow:0 6px 20px rgba(108,99,255,.06);transform:translateY(-1px);}
.ls-card-date{display:flex;flex-direction:column;align-items:center;padding:.5rem .75rem;background:#F9FAFB;border-radius:12px;border:1.5px solid var(--tb);min-width:54px;}
.ls-card-day{font-size:1.3rem;font-weight:800;color:var(--tt);line-height:1;}
.ls-card-month{font-size:.65rem;font-weight:700;color:var(--tm);text-transform:uppercase;margin-top:2px;}
.ls-card-body{flex:1;min-width:200px;}
.ls-card-title{font-size:.96rem;font-weight:700;color:var(--tt);margin-bottom:4px;}
.ls-card-meta{font-size:.8rem;color:var(--tm);display:flex;flex-wrap:wrap;gap:10px;margin-bottom:6px;}
.ls-card-meta span{display:inline-flex;align-items:center;gap:4px;}
.ls-badge{padding:3px 10px;border-radius:6px;font-size:.68rem;font-weight:700;}
.ls-badge-upcoming{background:#DBEAFE;color:#1D4ED8;}
.ls-badge-completed{background:#D1FAE5;color:#047857;}
.ls-badge-cancelled{background:#FEE2E2;color:#B91C1C;}
.ls-card-actions{display:flex;gap:6px;flex-shrink:0;align-self:center;}
.ls-act{font-size:.78rem;font-weight:600;padding:6px 12px;border-radius:8px;border:1.5px solid;cursor:pointer;background:transparent;text-decoration:none;display:inline-flex;align-items:center;gap:4px;transition:all .15s;}
.ls-act-view{color:var(--ti);border-color:#DBEAFE;}.ls-act-view:hover{background:#EFF6FF;}
.ls-act-edit{color:var(--tp);border-color:#EDE9FE;}.ls-act-edit:hover{background:var(--tl);}
.ls-act-cancel{color:#fff;border-color:var(--te);background:var(--te);}.ls-act-cancel:hover{background:#DC2626;border-color:#DC2626;}
/* Empty */
.ls-empty{display:flex;flex-direction:column;align-items:center;text-align:center;padding:3.5rem 2rem;}
.ls-empty i{font-size:3rem;color:var(--tm);opacity:.35;margin-bottom:1rem;}
.ls-empty-title{font-size:1rem;font-weight:700;color:var(--tt);margin-bottom:.25rem;}
.ls-empty-sub{font-size:.84rem;color:var(--tm);margin-bottom:1rem;}
.ls-empty-btn{display:inline-flex;align-items:center;gap:5px;padding:.5rem 1.25rem;border-radius:10px;background:var(--ts);color:#fff;font-size:.82rem;font-weight:700;text-decoration:none;transition:background .15s;}
.ls-empty-btn:hover{background:#059669;color:#fff;text-decoration:none;}
/* Modal */
.ls-modal-overlay{position:fixed;inset:0;background:rgba(17,24,39,.5);z-index:9000;display:flex;align-items:center;justify-content:center;padding:1rem;}
.ls-modal{background:#fff;border-radius:16px;width:100%;max-width:520px;box-shadow:0 20px 60px rgba(0,0,0,.2);animation:lsFade .2s ease;}
@keyframes lsFade{from{opacity:0;transform:translateY(10px);}to{opacity:1;transform:translateY(0);}}
.ls-modal-header{display:flex;align-items:center;justify-content:space-between;padding:1.25rem 1.5rem;border-bottom:1px solid var(--tb);}
.ls-modal-header h3{font-size:1rem;font-weight:800;color:var(--tt);margin:0;}
.ls-modal-close{background:none;border:none;font-size:1.4rem;color:var(--tm);cursor:pointer;}.ls-modal-close:hover{color:var(--tt);}
.ls-modal-body{padding:1.25rem 1.5rem;max-height:65vh;overflow-y:auto;}
.ls-modal-footer{display:flex;gap:.75rem;justify-content:flex-end;padding:1rem 1.5rem;border-top:1px solid var(--tb);}
.ls-field{margin-bottom:1.1rem;}.ls-label{font-size:.84rem;font-weight:700;color:#1E1B4B;display:block;margin-bottom:6px;}
.ls-field-error{font-size:.72rem;color:var(--te);font-weight:600;margin-top:4px;display:none;}
.ls-field-error.show{display:block;}
.ls-input.invalid{border-color:var(--te);}
.ls-form-error{font-size:.78rem;color:var(--te);font-weight:600;text-align:center;margin-top:.75rem;display:none;}
.ls-form-error.show{display:block;}
.ls-input{width:100%;border-radius:10px;border:1.5px solid var(--tb);padding:.55rem .75rem;font-size:.84rem;transition:border-color .2s;}
.ls-input:focus{border-color:var(--tp);outline:none;}
.ls-row2{display:grid;grid-template-columns:1fr 1fr;gap:1rem;}
.ls-btn-cancel-modal{background:var(--tc);border:1.5px solid var(--tb);border-radius:10px;padding:.55rem 1rem;font-weight:600;font-size:.84rem;color:var(--tt);cursor:pointer;}
.ls-btn-submit{background:var(--tp);border:none;border-radius:10px;padding:.55rem 1.25rem;font-weight:700;font-size:.84rem;color:#fff;cursor:pointer;}.ls-btn-submit:hover{background:var(--th);}
.ls-toast-wrap{position:fixed;top:1.25rem;right:1.25rem;z-index:9999;}
.ls-toast{background:var(--ts);color:#fff;padding:.65rem 1.1rem;border-radius:10px;font-size:.82rem;font-weight:600;display:flex;align-items:center;gap:6px;box-shadow:0 6px 18px rgba(16,185,129,.25);animation:lsFade .3s ease;}
@media(max-width:900px){.ls-stats{grid-template-columns:repeat(2,1fr);}.ls-toolbar{flex-direction:column;align-items:stretch;}.ls-search{width:100%;}.ls-action-row{flex-wrap:wrap;}.ls-action-card{width:100%;height:auto;min-height:150px;}}
@media(max-width:640px){.ls-stats{grid-template-columns:1fr;}.ls-card{flex-direction:column;}}
/* Pending License Notice */
.ls-pending-notice{display:flex;align-items:flex-start;gap:.75rem;padding:.85rem 1.1rem;margin-bottom:1.25rem;background:#FEF2F2;border:1.5px solid #FECACA;border-left:4px solid #DC2626;border-radius:10px;}
.ls-pending-notice-icon{flex-shrink:0;width:32px;height:32px;border-radius:8px;background:#FEE2E2;color:#DC2626;display:flex;align-items:center;justify-content:center;font-size:1rem;}
.ls-pending-notice-content{flex:1;min-width:0;}
.ls-pending-notice-title{font-size:.84rem;font-weight:700;color:#991B1B;margin-bottom:2px;}
.ls-pending-notice-msg{font-size:.78rem;color:#B91C1C;line-height:1.45;}
/* Start Live button styles */
.ls-act-start{background:linear-gradient(135deg,#10B981,#059669);color:#fff;border:none;border-radius:10px;padding:6px 14px;font-weight:700;font-size:.78rem;box-shadow:0 3px 10px rgba(16,185,129,.2);cursor:pointer;transition:transform .15s,box-shadow .15s;}
.ls-act-start:hover{transform:translateY(-2px);box-shadow:0 6px 16px rgba(16,185,129,.28);color:#fff;text-decoration:none;}
.ls-act-start:active{transform:translateY(0);}
.ls-act-notyet{background:transparent;color:#9CA3AF;border:1.5px solid #E5E7EB;border-radius:10px;padding:6px 14px;font-weight:600;font-size:.78rem;cursor:not-allowed;opacity:.6;}
.ls-act-notyet:hover{color:#9CA3AF;text-decoration:none;}
/* View Summary pill button */
.ls-view-summary{background:#F5F3FF;border:1.5px solid #DDD6FE;color:#6C63FF;font-size:.78rem;font-weight:700;cursor:pointer;padding:6px 14px;border-radius:50px;display:inline-flex;align-items:center;gap:5px;transition:all .2s;text-decoration:none;}
.ls-view-summary:hover{background:#EDE9FE;transform:translateY(-2px);box-shadow:0 4px 12px rgba(108,99,255,.12);color:#5A52E0;text-decoration:none;}
.ls-view-summary:active{transform:translateY(0);}
.ls-badge-expired{background:#F3F4F6;color:#6B7280;}
.ls-action-card.ls-disabled{opacity:.5;cursor:not-allowed;pointer-events:none;filter:grayscale(.3);}
/* Live Session Summary Panel */
.ls-summary-overlay{position:fixed;inset:0;background:rgba(17,24,39,.45);z-index:7999;animation:lsSumOverIn .25s ease;}
@keyframes lsSumOverIn{from{opacity:0;}to{opacity:1;}}
.ls-summary-panel{position:fixed;top:50%;left:50%;transform:translate(-50%,-50%);width:480px;max-width:calc(100vw - 32px);max-height:calc(100vh - 40px);background:#fff;border-radius:18px;box-shadow:0 12px 40px rgba(0,0,0,.16),0 2px 8px rgba(0,0,0,.06);overflow-y:auto;display:flex;flex-direction:column;z-index:8000;animation:lsSumIn .3s cubic-bezier(.22,1,.36,1);}
@keyframes lsSumIn{from{opacity:0;transform:translate(-50%,-48%) scale(.96);}to{opacity:1;transform:translate(-50%,-50%) scale(1);}}
.ls-summary-hdr{display:flex;align-items:flex-start;gap:12px;padding:1.1rem 1.25rem .85rem;border-bottom:1px solid #F3F4F6;}
.ls-summary-ico{width:38px;height:38px;border-radius:50%;background:#D1FAE5;color:#059669;display:flex;align-items:center;justify-content:center;font-size:1.1rem;flex-shrink:0;}
.ls-summary-hdr-text{}
.ls-summary-hdr h3{font-size:.92rem;font-weight:800;color:#374151;margin:0 0 2px;}
.ls-summary-hdr-sub{font-size:.78rem;color:#6B7280;font-weight:500;}
.ls-summary-body{flex:1;overflow-y:auto;padding:.85rem 1.25rem 0;}
.ls-summary-body::-webkit-scrollbar{width:4px;}.ls-summary-body::-webkit-scrollbar-thumb{background:#DDD6FE;border-radius:4px;}
.ls-sum-times{display:grid;grid-template-columns:1fr 1fr;gap:.5rem;margin-bottom:.75rem;}
.ls-sum-time{font-size:.8rem;color:#6B7280;background:#F9FAFB;border-radius:9px;padding:.5rem .7rem;}
.ls-sum-time span{display:block;font-weight:700;color:#374151;font-size:.92rem;margin-top:2px;}
.ls-sum-stats{display:grid;grid-template-columns:1fr 1fr;gap:.5rem;margin-bottom:.85rem;}
.ls-sum-stat{background:#F9FAFB;border:1.5px solid #F0EDF8;border-radius:12px;padding:.65rem .75rem;display:flex;align-items:center;gap:10px;}
.ls-sum-stat-ico{width:32px;height:32px;border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:.9rem;flex-shrink:0;}
.ls-sum-stat-val{font-size:1.25rem;font-weight:800;color:#1E1B4B;line-height:1.15;}
.ls-sum-stat-lbl{font-size:.75rem;color:#6B7280;font-weight:600;line-height:1.2;}
.ls-sum-parts{border-top:1px solid #F3F4F6;padding-top:.75rem;margin-bottom:.75rem;}
.ls-sum-parts-title{font-size:.85rem;font-weight:700;color:#374151;margin-bottom:.5rem;display:flex;align-items:center;gap:5px;}
.ls-sum-parts-list{display:flex;flex-direction:column;gap:5px;max-height:140px;overflow-y:auto;}
.ls-sum-parts-list::-webkit-scrollbar{width:3px;}.ls-sum-parts-list::-webkit-scrollbar-thumb{background:#DDD6FE;border-radius:4px;}
.ls-sum-part-item{display:flex;align-items:center;gap:8px;padding:.35rem .5rem;border-radius:8px;background:#F9FAFB;}
.ls-sum-part-av{width:26px;height:26px;border-radius:50%;background:#EDE9FE;color:#7C3AED;display:flex;align-items:center;justify-content:center;font-size:.68rem;font-weight:700;flex-shrink:0;}
.ls-sum-part-name{font-size:.85rem;font-weight:600;color:#374151;}
.ls-sum-no-parts{text-align:center;font-size:.84rem;color:#9CA3AF;padding:.75rem 0;}
.ls-summary-ftr{padding:.75rem 1.25rem;border-top:1px solid #F3F4F6;display:flex;justify-content:flex-end;}
.ls-sum-btn-done{background:linear-gradient(135deg,#6C63FF,#5A52E0);border:none;border-radius:10px;padding:.5rem 1.25rem;font-weight:700;font-size:.82rem;color:#fff;cursor:pointer;box-shadow:0 3px 10px rgba(108,99,255,.2);transition:transform .15s;}
.ls-sum-btn-done:hover{transform:translateY(-1px);}
@media(max-width:500px){.ls-summary-panel{width:calc(100vw - 24px);max-height:calc(100vh - 32px);}}
</style>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Teaching","Pengajaran") %></div>
        <a href="<%: ResolveUrl("~/Teacher/manageMaterials.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label"><%: T("Manage Materials","Bahan Pembelajaran") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label"><%: T("Manage Quiz","Kuiz") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/studentProgress.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bar-chart item-icon"></i><span class="item-label"><%: T("Student Progress","Prestasi Pelajar") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/liveSession.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-camera-video item-icon"></i><span class="item-label"><%: T("Schedule Live Class","Kelas Langsung") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Community","Komuniti") %></div>
        <a href="<%: ResolveUrl("~/Teacher/forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/privateMessages.aspx") %>" class="sb-sidebar-item"><i class="bi bi-envelope item-icon"></i><span class="item-label"><%: T("Private Message","Mesej Peribadi") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Account","Akaun") %></div>
        <a href="<%: ResolveUrl("~/Teacher/MyProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("My Profile","Profil Saya") %></span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Sign Out","Log Keluar") %></span></a></div>
</asp:Content>
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Live Sessions","Kelas Langsung") %></asp:Content>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">
<asp:HiddenField ID="hidLicenseStatus" runat="server" Value="" />

<%-- Header --%>
<div class="ls-page-header">
    <div><h1><%: T("Live Sessions","Kelas Langsung") %></h1><p><%: T("Manage all your online classes, schedules, and previous sessions.","Urus semua kelas dalam talian, jadual, dan sesi terdahulu anda.") %></p></div>
</div>

<%-- Pending License Notice --%>
<div id="lsPendingNotice" class="ls-pending-notice" style="display:none;">
    <div class="ls-pending-notice-icon"><i class="bi bi-shield-exclamation"></i></div>
    <div class="ls-pending-notice-content">
        <div class="ls-pending-notice-title"><%: T("Verification Pending","Pengesahan Menunggu") %></div>
        <div class="ls-pending-notice-msg"><%: T("Your Teaching License is still under review. Scheduling or starting live classes is temporarily unavailable until your verification has been approved.","Lesen Mengajar anda masih dalam semakan. Penjadualan atau permulaan kelas langsung tidak tersedia buat sementara waktu sehingga pengesahan anda diluluskan.") %></div>
    </div>
</div>

<%-- Action Cards --%>
<div class="ls-action-row">
    <div class="ls-action-card ls-action-schedule" onclick="document.getElementById('scheduleModal').style.display='flex'">
        <div class="ls-action-icon"><i class="bi bi-calendar-plus"></i></div>
        <div>
            <div class="ls-action-title"><%: T("Schedule Live Class","Jadualkan Kelas Langsung") %></div>
            <div class="ls-action-desc"><%: T("Plan a future online class","Rancang kelas dalam talian") %></div>
        </div>
        <div class="ls-action-cta"><%: T("Schedule","Jadual") %> <i class="bi bi-arrow-right"></i></div>
    </div>
    <div class="ls-action-card ls-action-instant" onclick="document.getElementById('instantModal').style.display='flex'">
        <div class="ls-action-icon"><i class="bi bi-broadcast-pin"></i><span class="ls-live-dot"></span></div>
        <div>
            <div class="ls-action-title"><%: T("Start Instant Class","Mulakan Kelas Segera") %></div>
            <div class="ls-action-desc"><%: T("Begin teaching immediately","Mula mengajar serta-merta") %></div>
        </div>
        <div class="ls-action-cta"><%: T("Start Now","Mula Sekarang") %> <i class="bi bi-arrow-right"></i></div>
    </div>
</div>

<%-- Stats --%>
<div class="ls-stats">
    <div class="ls-stat stat-upcoming"><div class="ls-stat-icon" style="background:#DBEAFE;color:#2563EB;"><i class="bi bi-calendar-event"></i></div><div class="ls-stat-val"><asp:Literal ID="litUpcoming" runat="server" Text="0" /></div><div class="ls-stat-label"><%: T("Upcoming Sessions","Sesi Akan Datang") %></div></div>
    <div class="ls-stat stat-completed"><div class="ls-stat-icon" style="background:#D1FAE5;color:#047857;"><i class="bi bi-check-circle"></i></div><div class="ls-stat-val"><asp:Literal ID="litCompleted" runat="server" Text="0" /></div><div class="ls-stat-label"><%: T("Completed Sessions","Sesi Selesai") %></div></div>
    <div class="ls-stat stat-cancelled"><div class="ls-stat-icon" style="background:#FEE2E2;color:#B91C1C;"><i class="bi bi-x-circle"></i></div><div class="ls-stat-val"><asp:Literal ID="litCancelled" runat="server" Text="0" /></div><div class="ls-stat-label"><%: T("Cancelled Sessions","Sesi Dibatalkan") %></div></div>
    <div class="ls-stat stat-students"><div class="ls-stat-icon" style="background:#E0E7FF;color:#4338CA;"><i class="bi bi-people"></i></div><div class="ls-stat-val"><asp:Literal ID="litStudentsJoined" runat="server" Text="0" /></div><div class="ls-stat-label"><%: T("Students Joined","Pelajar Menyertai") %></div></div>
</div>

<%-- Tabs (client-side switching, no postback) --%>
<div class="ls-tabs">
    <button type="button" class="ls-tab active" id="btnTabUpcoming" onclick="switchLsTab('upcoming')"><%: T("Upcoming","Akan Datang") %></button>
    <button type="button" class="ls-tab" id="btnTabHistory" onclick="switchLsTab('history')"><%: T("History","Sejarah") %></button>
</div>

<%-- Upcoming Session List --%>
<div id="lsTabUpcoming">
<asp:Panel ID="pnlListUpcoming" runat="server" Visible="false">
    <div class="ls-cards">
        <asp:Repeater ID="rptUpcoming" runat="server" OnItemCommand="rptSessions_ItemCommand">
            <ItemTemplate>
                <div class="ls-card">
                    <div class="ls-card-date"><span class="ls-card-day"><%# Eval("day") %></span><span class="ls-card-month"><%# Eval("month") %></span></div>
                    <div class="ls-card-body">
                        <div class="ls-card-title"><%# HttpUtility.HtmlEncode(Eval("title")) %></div>
                        <div class="ls-card-meta">
                            <span><i class="bi bi-clock"></i> <%# Eval("timeRange") %></span>
                            <span><i class="bi bi-bookmark"></i> <%# HttpUtility.HtmlEncode(Eval("topic")) %></span>
                        </div>
                        <span class='ls-badge <%# Eval("badgeCss") %>'><%# Eval("badgeLabel") %></span>
                    </div>
                    <div class="ls-card-actions">
                        <asp:LinkButton ID="btnStartSession" runat="server" CommandName="StartSession" CommandArgument='<%# Eval("sessionId") %>' CssClass='<%# (bool)Eval("canStart") ? "ls-act ls-act-start" : "ls-act ls-act-notyet" %>' CausesValidation="false" Enabled='<%# (bool)Eval("canStart") %>'>
                            <i class='<%# (bool)Eval("canStart") ? "bi bi-broadcast-pin" : "bi bi-clock" %>'></i> <%# (bool)Eval("canStart") ? T("Start Live","Mula Langsung") : T("Not Started Yet","Belum Bermula") %>
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnReschedule" runat="server" CommandName="Reschedule" CommandArgument='<%# Eval("sessionId") + "|" + Eval("rawStart") + "|" + Eval("rawEnd") + "|" + HttpUtility.HtmlEncode(Eval("title")) %>' CssClass="ls-act ls-act-edit" CausesValidation="false" Visible='<%# !(bool)Eval("canStart") %>'>
                            <i class="bi bi-calendar2-plus"></i> <%: T("Reschedule","Jadual Semula") %>
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnDel" runat="server" CommandName="Cancel" CommandArgument='<%# Eval("sessionId") + "|" + HttpUtility.HtmlEncode(Eval("title")) + "|" + Eval("timeRange") %>' CssClass="ls-act ls-act-cancel" CausesValidation="false">
                            <i class="bi bi-x-lg"></i> <%: T("Cancel","Batal") %>
                        </asp:LinkButton>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>
<asp:Panel ID="pnlUpcomingEmpty" runat="server" Visible="false">
    <div class="ls-empty">
        <i class="bi bi-calendar2-x"></i>
        <div class="ls-empty-title"><%: T("No Upcoming Sessions","Tiada Sesi Akan Datang") %></div>
        <div class="ls-empty-sub"><%: T("You do not have any upcoming live classes scheduled.","Anda tidak mempunyai kelas langsung yang dijadualkan.") %></div>
    </div>
</asp:Panel>
</div>

<%-- History Session List --%>
<div id="lsTabHistory" style="display:none;">
<asp:Panel ID="pnlListHistory" runat="server" Visible="false">
    <div class="ls-cards">
        <asp:Repeater ID="rptHistory" runat="server" OnItemCommand="rptSessions_ItemCommand">
            <ItemTemplate>
                <div class="ls-card">
                    <div class="ls-card-date"><span class="ls-card-day"><%# Eval("day") %></span><span class="ls-card-month"><%# Eval("month") %></span></div>
                    <div class="ls-card-body">
                        <div class="ls-card-title"><%# HttpUtility.HtmlEncode(Eval("title")) %></div>
                        <div class="ls-card-meta">
                            <span><i class="bi bi-clock"></i> <%# Eval("timeRange") %></span>
                            <span><i class="bi bi-bookmark"></i> <%# HttpUtility.HtmlEncode(Eval("topic")) %></span>
                            <%# Convert.ToInt32(Eval("students")) > 0 ? "<span><i class='bi bi-people'></i> " + Eval("students") + " students</span>" : "" %>
                            <%# Eval("duration").ToString()!="" ? "<span><i class='bi bi-hourglass-split'></i> " + Eval("duration") + "</span>" : "" %>
                        </div>
                        <span class='ls-badge <%# Eval("badgeCss") %>'><%# Eval("badgeLabel") %></span>
                    </div>
                    <div class="ls-card-actions" style='<%# (bool)Eval("isCompleted") ? "" : "display:none;" %>'>
                        <button type="button" class="ls-view-summary" onclick="viewSessionSummary('<%# Eval("sessionId") %>')">
                            <i class="bi bi-bar-chart-line"></i> <%: T("View Summary","Lihat Ringkasan") %> →
                        </button>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>
<asp:Panel ID="pnlHistoryEmpty" runat="server" Visible="false">
    <div class="ls-empty">
        <i class="bi bi-clock-history"></i>
        <div class="ls-empty-title"><%: T("No Session History","Tiada Sejarah Sesi") %></div>
        <div class="ls-empty-sub"><%: T("Your completed and cancelled live classes will appear here.","Kelas langsung yang selesai dan dibatalkan akan terpapar di sini.") %></div>
    </div>
</asp:Panel>
</div>

<%-- Start Instant Class Modal --%>
<div id="instantModal" class="ls-modal-overlay" style="display:none;">
    <div class="ls-modal">
        <div class="ls-modal-header"><h3 style="font-size:1.1rem;"><%: T("Start Instant Class","Mulakan Kelas Segera") %></h3><button type="button" class="ls-modal-close" onclick="document.getElementById('instantModal').style.display='none'">×</button></div>
        <div class="ls-modal-body">
            <p style="font-size:.82rem;color:var(--tm);margin:0 0 1rem;"><%: T("Create a live class and begin teaching immediately.","Cipta kelas langsung dan mula mengajar serta-merta.") %></p>
            <div class="ls-field"><label class="ls-label"><%: T("Session Title","Tajuk Sesi") %> <span style="color:var(--te);">*</span></label><asp:TextBox ID="txtInstantTitle" runat="server" CssClass="ls-input" MaxLength="200" /><div class="ls-field-error" id="errInstTitle">Please enter a session title.</div></div>
            <div class="ls-field"><label class="ls-label"><%: T("Description","Penerangan") %></label><asp:TextBox ID="txtInstantDesc" runat="server" CssClass="ls-input" TextMode="MultiLine" Rows="2" /></div>
            <div class="ls-row2">
                <div class="ls-field"><label class="ls-label"><%: T("Unit","Unit") %> <span style="color:var(--te);">*</span></label><asp:DropDownList ID="ddlInstantUnit" runat="server" CssClass="ls-input" /><div class="ls-field-error" id="errInstUnit">Please select a unit.</div></div>
                <div class="ls-field"><label class="ls-label"><%: T("Subtopic","Subtopik") %> <span style="color:var(--te);">*</span></label><asp:DropDownList ID="ddlInstantSubtopic" runat="server" CssClass="ls-input" /><div class="ls-field-error" id="errInstSub">Please select a subtopic.</div></div>
            </div>
            <asp:Panel ID="pnlInstantError" runat="server" Visible="false"><div style="font-size:.78rem;color:var(--te);font-weight:600;margin-top:.25rem;"><asp:Literal ID="litInstantError" runat="server" /></div></asp:Panel>
        </div>
        <div class="ls-modal-footer">
            <button type="button" class="ls-btn-cancel-modal" onclick="document.getElementById('instantModal').style.display='none'"><%: T("Cancel","Batal") %></button>
            <asp:Button ID="btnStartLive" runat="server" CssClass="ls-btn-submit" style="background:#DC2626;" OnClick="btnStartLive_Click" CausesValidation="false" OnClientClick="return validateInstantForm();" />
        </div>
    </div>
</div>
<asp:HiddenField ID="hidShowInstantModal" runat="server" Value="" OnValueChanged="hidShowInstantModal_ValueChanged" />

<%-- Reschedule Modal --%>
<div id="rescheduleModal" class="ls-modal-overlay" style="display:none;">
    <div class="ls-modal">
        <div class="ls-modal-header"><h3><%: T("Reschedule Live Session","Jadual Semula Sesi Langsung") %></h3><button type="button" class="ls-modal-close" onclick="document.getElementById('rescheduleModal').style.display='none'">×</button></div>
        <div class="ls-modal-body">
            <div style="background:#F9FAFB;border-radius:10px;padding:.75rem 1rem;margin-bottom:1rem;font-size:.82rem;color:var(--tt);">
                <strong><asp:Literal ID="litRescTitle" runat="server" /></strong><br/>
                <span style="font-size:.76rem;color:var(--tm);"><asp:Literal ID="litRescCurrent" runat="server" /></span>
            </div>
            <asp:HiddenField ID="hidRescId" runat="server" Value="" />
            <div class="ls-field"><label class="ls-label"><%: T("New Date","Tarikh Baharu") %> *</label><asp:TextBox ID="txtRescDate" runat="server" CssClass="ls-input" TextMode="Date" /></div>
            <div class="ls-row2">
                <div class="ls-field"><label class="ls-label"><%: T("New Start Time","Masa Mula Baharu") %> *</label><asp:TextBox ID="txtRescStart" runat="server" CssClass="ls-input" TextMode="Time" /></div>
                <div class="ls-field"><label class="ls-label"><%: T("New End Time","Masa Tamat Baharu") %> *</label><asp:TextBox ID="txtRescEnd" runat="server" CssClass="ls-input" TextMode="Time" /></div>
            </div>
            <asp:Panel ID="pnlRescError" runat="server" Visible="false"><div style="font-size:.76rem;color:var(--te);font-weight:600;"><asp:Literal ID="litRescError" runat="server" /></div></asp:Panel>
        </div>
        <div class="ls-modal-footer">
            <button type="button" class="ls-btn-cancel-modal" onclick="document.getElementById('rescheduleModal').style.display='none'"><%: T("Close","Tutup") %></button>
            <asp:Button ID="btnSaveReschedule" runat="server" CssClass="ls-btn-submit" OnClick="btnSaveReschedule_Click" CausesValidation="false" />
        </div>
    </div>
</div>

<%-- Cancel Confirmation Modal --%>
<div id="cancelModal" class="ls-modal-overlay" style="display:none;">
    <div class="ls-modal">
        <div class="ls-modal-header"><h3><%: T("Cancel Live Session?","Batalkan Sesi Langsung?") %></h3><button type="button" class="ls-modal-close" onclick="document.getElementById('cancelModal').style.display='none'">×</button></div>
        <div class="ls-modal-body" style="text-align:center;padding:1.5rem;">
            <p style="font-size:.88rem;color:var(--tt);margin:0 0 .5rem;"><%: T("Are you sure you want to cancel this live session?","Adakah anda pasti mahu membatalkan sesi langsung ini?") %></p>
            <div style="background:#FEF2F2;border-radius:10px;padding:.75rem 1rem;font-size:.82rem;color:#B91C1C;margin-top:.75rem;">
                <strong><asp:Literal ID="litCancelTitle" runat="server" /></strong><br/>
                <span style="font-size:.76rem;"><asp:Literal ID="litCancelTime" runat="server" /></span>
            </div>
            <asp:HiddenField ID="hidCancelId" runat="server" Value="" />
        </div>
        <div class="ls-modal-footer" style="justify-content:center;">
            <button type="button" class="ls-btn-cancel-modal" onclick="document.getElementById('cancelModal').style.display='none'"><%: T("Keep Session","Kekalkan Sesi") %></button>
            <asp:Button ID="btnConfirmCancel" runat="server" CssClass="ls-btn-submit" style="background:var(--te);" OnClick="btnConfirmCancel_Click" CausesValidation="false" />
        </div>
    </div>
</div>

<asp:HiddenField ID="hidShowRescModal" runat="server" Value="" />
<asp:HiddenField ID="hidShowCancelModal" runat="server" Value="" />

<%-- Schedule Modal --%>
<div id="scheduleModal" class="ls-modal-overlay" style="display:none;">
    <div class="ls-modal">
        <div class="ls-modal-header"><h3><%: T("Schedule Live Class","Jadualkan Kelas Langsung") %></h3><button type="button" class="ls-modal-close" onclick="document.getElementById('scheduleModal').style.display='none'">×</button></div>
        <div class="ls-modal-body">
            <div class="ls-field"><label class="ls-label"><%: T("Class Title","Tajuk Kelas") %> <span style="color:var(--te);">*</span></label><asp:TextBox ID="txtTitle" runat="server" CssClass="ls-input" MaxLength="200" /><div class="ls-field-error" id="errSchTitle">Please enter a class title.</div></div>
            <div class="ls-field"><label class="ls-label"><%: T("Date","Tarikh") %> <span style="color:var(--te);">*</span></label><asp:TextBox ID="txtDate" runat="server" CssClass="ls-input" TextMode="Date" /><div class="ls-field-error" id="errSchDate">Please select a date.</div></div>
            <div class="ls-row2">
                <div class="ls-field"><label class="ls-label"><%: T("Start Time","Masa Mula") %> <span style="color:var(--te);">*</span></label><asp:TextBox ID="txtStart" runat="server" CssClass="ls-input" TextMode="Time" /><div class="ls-field-error" id="errSchStart">Please select a start time.</div></div>
                <div class="ls-field"><label class="ls-label"><%: T("End Time","Masa Tamat") %> <span style="color:var(--te);">*</span></label><asp:TextBox ID="txtEnd" runat="server" CssClass="ls-input" TextMode="Time" /><div class="ls-field-error" id="errSchEnd">Please select an end time.</div></div>
            </div>
            <div class="ls-field"><label class="ls-label"><%: T("Unit","Unit") %> <span style="color:var(--te);">*</span></label><asp:DropDownList ID="ddlUnit" runat="server" CssClass="ls-input" /><div class="ls-field-error" id="errSchUnit">Please select a unit.</div></div>
            <div class="ls-field"><label class="ls-label"><%: T("Subtopic","Subtopik") %> <span style="color:var(--te);">*</span></label><asp:DropDownList ID="ddlSubtopic" runat="server" CssClass="ls-input" /><div class="ls-field-error" id="errSchSub">Please select a subtopic.</div></div>
            <div class="ls-field"><label class="ls-label"><%: T("Description","Penerangan") %></label><asp:TextBox ID="txtDesc" runat="server" CssClass="ls-input" TextMode="MultiLine" Rows="2" /></div>
            <asp:Panel ID="pnlError" runat="server" Visible="false"><div style="font-size:.78rem;color:var(--te);font-weight:600;margin-top:.25rem;"><asp:Literal ID="litError" runat="server" /></div></asp:Panel>
        </div>
        <div class="ls-modal-footer">
            <button type="button" class="ls-btn-cancel-modal" onclick="document.getElementById('scheduleModal').style.display='none'"><%: T("Cancel","Batal") %></button>
            <asp:Button ID="btnSchedule" runat="server" CssClass="ls-btn-submit" OnClick="btnSchedule_Click" CausesValidation="false" OnClientClick="return validateScheduleForm();" />
        </div>
    </div>
</div>

<asp:HiddenField ID="hidToast" runat="server" Value="" />
<asp:HiddenField ID="hidShowModal" runat="server" Value="" />
<asp:HiddenField ID="hidShowSummary" runat="server" Value="" />
<div class="ls-toast-wrap" id="lsToast"></div>

<%-- Live Session Summary Panel (bottom-right, shown after End Live) --%>
<asp:Panel ID="pnlSummary" runat="server">
<div class="ls-summary-overlay" id="lsSummaryOverlay" style="display:none;"></div>
<div class="ls-summary-panel" id="lsSummaryPanel" style="display:none;">
    <div class="ls-summary-hdr">
        <div class="ls-summary-ico"><i class="bi bi-check-lg"></i></div>
        <div class="ls-summary-hdr-text">
            <h3><%: T("Live Session Completed","Sesi Langsung Selesai") %></h3>
            <div class="ls-summary-hdr-sub"><asp:Literal ID="litSumTitle" runat="server" /></div>
        </div>
    </div>
    <div class="ls-summary-body">
        <div class="ls-sum-times">
            <div class="ls-sum-time"><%: T("Start","Mula") %><span><asp:Literal ID="litSumStart" runat="server" /></span></div>
            <div class="ls-sum-time"><%: T("End","Tamat") %><span><asp:Literal ID="litSumEnd" runat="server" /></span></div>
        </div>
        <div class="ls-sum-stats">
            <div class="ls-sum-stat">
                <div class="ls-sum-stat-ico" style="background:#EDE9FE;color:#7C3AED;"><i class="bi bi-clock-fill"></i></div>
                <div><div class="ls-sum-stat-val"><asp:Literal ID="litSumDuration" runat="server" /></div><div class="ls-sum-stat-lbl"><%: T("Duration","Tempoh") %></div></div>
            </div>
            <div class="ls-sum-stat">
                <div class="ls-sum-stat-ico" style="background:#D1FAE5;color:#059669;"><i class="bi bi-people-fill"></i></div>
                <div><div class="ls-sum-stat-val"><asp:Literal ID="litSumStudents" runat="server" /></div><div class="ls-sum-stat-lbl"><%: T("Students Joined","Pelajar Menyertai") %></div></div>
            </div>
        </div>
        <div class="ls-sum-parts">
            <div class="ls-sum-parts-title"><i class="bi bi-person-lines-fill" style="color:var(--tp);"></i> <%: T("Participants","Peserta") %></div>
            <asp:Panel ID="pnlSumPartsList" runat="server">
                <div class="ls-sum-parts-list">
                    <asp:Repeater ID="rptSumParticipants" runat="server">
                        <ItemTemplate>
                            <div class="ls-sum-part-item">
                                <div class="ls-sum-part-av"><%# Eval("initials") %></div>
                                <div class="ls-sum-part-name"><%# HttpUtility.HtmlEncode((string)Eval("name")) %></div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </asp:Panel>
            <asp:Panel ID="pnlSumNoParticipants" runat="server" style="display:none;">
                <div class="ls-sum-no-parts"><%: T("No students attended this live session.","Tiada pelajar menghadiri sesi langsung ini.") %></div>
            </asp:Panel>
        </div>
    </div>
    <div class="ls-summary-ftr">
        <button type="button" class="ls-sum-btn-done" onclick="closeLsSummary()"><%: T("Close","Tutup") %></button>
    </div>
</div>
</asp:Panel>

</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
function switchLsTab(tab){
    var up=document.getElementById('lsTabUpcoming');
    var hi=document.getElementById('lsTabHistory');
    var btnU=document.getElementById('btnTabUpcoming');
    var btnH=document.getElementById('btnTabHistory');
    if(tab==='history'){
        if(up)up.style.display='none';
        if(hi)hi.style.display='';
        if(btnU)btnU.className='ls-tab';
        if(btnH)btnH.className='ls-tab active';
    }else{
        if(up)up.style.display='';
        if(hi)hi.style.display='none';
        if(btnU)btnU.className='ls-tab active';
        if(btnH)btnH.className='ls-tab';
    }
}
window.addEventListener('load',function(){
    var h=document.getElementById('<%=hidToast.ClientID%>');
    if(h&&h.value){var w=document.getElementById('lsToast'),t=document.createElement('div');t.className='ls-toast';t.innerHTML='<i class="bi bi-check-circle-fill"></i> '+h.value;w.appendChild(t);h.value='';setTimeout(function(){t.style.opacity='0';t.style.transition='opacity .3s';},2500);setTimeout(function(){t.remove();},3e3);}
    var sm=document.getElementById('<%=hidShowModal.ClientID%>');
    if(sm&&sm.value==='1'){document.getElementById('scheduleModal').style.display='flex';sm.value='';}
    var rm=document.getElementById('<%=hidShowRescModal.ClientID%>');
    if(rm&&rm.value==='1'){document.getElementById('rescheduleModal').style.display='flex';rm.value='';}
    var cm=document.getElementById('<%=hidShowCancelModal.ClientID%>');
    if(cm&&cm.value==='1'){document.getElementById('cancelModal').style.display='flex';cm.value='';}
    var im=document.getElementById('<%=hidShowInstantModal.ClientID%>');
    if (im && im.value === '1') { document.getElementById('instantModal').style.display = 'flex'; im.value = ''; }

    // Show summary panel if redirected from End Live
    var ss=document.getElementById('<%=hidShowSummary.ClientID%>');
    if(ss&&ss.value==='1'){var sp=document.getElementById('lsSummaryPanel');var so=document.getElementById('lsSummaryOverlay');if(so)so.style.display='block';if(sp)sp.style.display='flex';ss.value='';}

    // Pending License: show notice + disable action cards
    var lic=document.getElementById('<%=hidLicenseStatus.ClientID%>');
    if(lic&&lic.value==='Pending'){
        var notice=document.getElementById('lsPendingNotice');if(notice)notice.style.display='flex';
        var cards=document.querySelectorAll('.ls-action-card');
        for(var i=0;i<cards.length;i++){cards[i].classList.add('ls-disabled');cards[i].removeAttribute('onclick');}
    }

    // Unit → Subtopic dependency for Schedule modal
    var ddlUnitEl=document.getElementById('<%=ddlUnit.ClientID%>');
    var ddlSubEl=document.getElementById('<%=ddlSubtopic.ClientID%>');
    if(ddlUnitEl&&ddlSubEl){
        // Initially disable if no unit selected
        if(!ddlUnitEl.value){ddlSubEl.disabled=true;}
        ddlUnitEl.addEventListener('change',function(){
            var unitId=this.value;
            ddlSubEl.innerHTML='';
            if(!unitId){
                ddlSubEl.disabled=true;
                var opt=document.createElement('option');opt.value='';opt.textContent='— Select Unit First —';ddlSubEl.appendChild(opt);
                return;
            }
            ddlSubEl.disabled=false;
            var loading=document.createElement('option');loading.value='';loading.textContent='Loading...';ddlSubEl.appendChild(loading);
            fetch(window.location.pathname+'?handler=subtopicsByUnit&unitId='+encodeURIComponent(unitId))
            .then(function(r){return r.json();})
            .then(function(data){
                ddlSubEl.innerHTML='';
                var def=document.createElement('option');def.value='';def.textContent='— Select Subtopic —';ddlSubEl.appendChild(def);
                for(var i=0;i<data.length;i++){
                    var o=document.createElement('option');o.value=data[i].id;o.textContent=data[i].name;ddlSubEl.appendChild(o);
                }
            })
            .catch(function(){
                ddlSubEl.innerHTML='';
                var err=document.createElement('option');err.value='';err.textContent='Error loading';ddlSubEl.appendChild(err);
            });
        });
    }

    // Unit → Subtopic dependency for Instant modal
    var ddlInstUnitEl=document.getElementById('<%=ddlInstantUnit.ClientID%>');
    var ddlInstSubEl=document.getElementById('<%=ddlInstantSubtopic.ClientID%>');
    if(ddlInstUnitEl&&ddlInstSubEl){
        if(!ddlInstUnitEl.value){ddlInstSubEl.disabled=true;}
        ddlInstUnitEl.addEventListener('change',function(){
            var unitId=this.value;
            ddlInstSubEl.innerHTML='';
            if(!unitId){
                ddlInstSubEl.disabled=true;
                var opt=document.createElement('option');opt.value='';opt.textContent='— Select Unit First —';ddlInstSubEl.appendChild(opt);
                return;
            }
            ddlInstSubEl.disabled=false;
            var loading=document.createElement('option');loading.value='';loading.textContent='Loading...';ddlInstSubEl.appendChild(loading);
            fetch(window.location.pathname+'?handler=subtopicsByUnit&unitId='+encodeURIComponent(unitId))
            .then(function(r){return r.json();})
            .then(function(data){
                ddlInstSubEl.innerHTML='';
                var def=document.createElement('option');def.value='';def.textContent='— Select Subtopic —';ddlInstSubEl.appendChild(def);
                for(var i=0;i<data.length;i++){
                    var o=document.createElement('option');o.value=data[i].id;o.textContent=data[i].name;ddlInstSubEl.appendChild(o);
                }
            })
            .catch(function(){
                ddlInstSubEl.innerHTML='';
                var err=document.createElement('option');err.value='';err.textContent='Error loading';ddlInstSubEl.appendChild(err);
            });
        });
    }

    // Enable dropdowns before form submit so values are posted
    var form=document.getElementById('MainForm');
    if(form){form.addEventListener('submit',function(){
        if(ddlSubEl)ddlSubEl.disabled=false;
        if(ddlInstSubEl)ddlInstSubEl.disabled=false;
    });}

});

/* ── Summary panel close ── */
function closeLsSummary(){
    var p=document.getElementById('lsSummaryPanel');
    var o=document.getElementById('lsSummaryOverlay');
    if(p){p.style.transition='opacity .25s ease,transform .25s ease';p.style.opacity='0';p.style.transform='translate(-50%,-48%) scale(.96)';setTimeout(function(){p.style.display='none';},260);}
    if(o){o.style.transition='opacity .25s ease';o.style.opacity='0';setTimeout(function(){o.style.display='none';},260);}
    if(window.history&&window.history.replaceState){
        var url=window.location.pathname;
        window.history.replaceState({},'',url);
    }
}

/* ── View Summary from History (AJAX) ── */
function viewSessionSummary(sessionId){
    fetch(window.location.pathname+'?handler=sessionSummary&id='+encodeURIComponent(sessionId))
    .then(function(r){return r.json();})
    .then(function(data){
        if(data.error)return;
        var titleEl=document.querySelector('#lsSummaryPanel .ls-summary-hdr-sub');
        var startEl=document.querySelector('#lsSummaryPanel .ls-sum-times .ls-sum-time:first-child span');
        var endEl=document.querySelector('#lsSummaryPanel .ls-sum-times .ls-sum-time:last-child span');
        var durEl=document.querySelectorAll('#lsSummaryPanel .ls-sum-stat-val')[0];
        var studEl=document.querySelectorAll('#lsSummaryPanel .ls-sum-stat-val')[1];
        if(titleEl)titleEl.textContent=data.title;
        if(startEl)startEl.textContent=data.startTime;
        if(endEl)endEl.textContent=data.endTime;
        if(durEl)durEl.textContent=data.duration;
        if(studEl)studEl.textContent=data.studentCount.toString();
        // Participants
        var listEl=document.querySelector('#lsSummaryPanel .ls-sum-parts-list');
        var noPartsEl=document.querySelector('#lsSummaryPanel .ls-sum-no-parts');
        if(listEl){
            if(data.participants.length>0){
                var html='';
                for(var i=0;i<data.participants.length;i++){
                    html+='<div class="ls-sum-part-item"><div class="ls-sum-part-av">'+data.participants[i].initials+'</div><div class="ls-sum-part-name">'+escHtml(data.participants[i].name)+'</div></div>';
                }
                listEl.innerHTML=html;
                listEl.parentElement.style.display='';
                if(noPartsEl)noPartsEl.parentElement.style.display='none';
            }else{
                listEl.parentElement.style.display='none';
                if(noPartsEl)noPartsEl.parentElement.style.display='';
            }
        }
        // Show modal
        var panel=document.getElementById('lsSummaryPanel');
        var overlay=document.getElementById('lsSummaryOverlay');
        if(overlay){overlay.style.display='block';overlay.style.opacity='1';}
        if(panel){panel.style.display='flex';panel.style.opacity='1';panel.style.transform='translate(-50%,-50%) scale(1)';}
    })
    .catch(function(){});
}
function escHtml(s){var d=document.createElement('div');d.textContent=s;return d.innerHTML;}

/* ── Client-side validation ── */
function validateScheduleForm(){
    // Enable disabled dropdowns before validation so their values can be read
    var subEl=document.getElementById('<%=ddlSubtopic.ClientID%>');
    var fields=[
        {el:document.getElementById('<%=txtTitle.ClientID%>'),err:'errSchTitle'},
        {el:document.getElementById('<%=txtDate.ClientID%>'),err:'errSchDate'},
        {el:document.getElementById('<%=txtStart.ClientID%>'),err:'errSchStart'},
        {el:document.getElementById('<%=txtEnd.ClientID%>'),err:'errSchEnd'},
        {el:document.getElementById('<%=ddlUnit.ClientID%>'),err:'errSchUnit'},
        {el:subEl,err:'errSchSub'}
    ];
    var valid=true;
    for(var i=0;i<fields.length;i++){
        var f=fields[i],val=f.el?f.el.value.trim():'';
        var errEl=document.getElementById(f.err);
        if(!val){valid=false;if(errEl)errEl.classList.add('show');if(f.el)f.el.classList.add('invalid');}
        else{if(errEl)errEl.classList.remove('show');if(f.el)f.el.classList.remove('invalid');}
    }
    var gen=document.getElementById('errSchGeneral');
    if(gen)gen.style.display='none';
    // Enable subtopic dropdown before submit so its value is POSTed
    if(valid&&subEl)subEl.disabled=false;
    return valid;
}
function validateInstantForm(){
    var instSubEl=document.getElementById('<%=ddlInstantSubtopic.ClientID%>');
    var fields=[
        {el:document.getElementById('<%=txtInstantTitle.ClientID%>'),err:'errInstTitle'},
        {el:document.getElementById('<%=ddlInstantUnit.ClientID%>'),err:'errInstUnit'},
        {el:instSubEl,err:'errInstSub'}
    ];
    var valid=true;
    for(var i=0;i<fields.length;i++){
        var f=fields[i],val=f.el?f.el.value.trim():'';
        var errEl=document.getElementById(f.err);
        if(!val){valid=false;if(errEl)errEl.classList.add('show');if(f.el)f.el.classList.add('invalid');}
        else{if(errEl)errEl.classList.remove('show');if(f.el)f.el.classList.remove('invalid');}
    }
    var gen=document.getElementById('errInstGeneral');
    if(gen)gen.style.display='none';
    // Enable subtopic dropdown before submit so its value is POSTed
    if(valid&&instSubEl)instSubEl.disabled=false;
    return valid;
}
/* Auto-clear errors on input */
document.addEventListener('input',function(e){
    var el=e.target;if(!el.classList.contains('invalid'))return;
    if(el.value.trim()){el.classList.remove('invalid');var p=el.parentElement;var err=p?p.querySelector('.ls-field-error'):null;if(err)err.classList.remove('show');}
});
document.addEventListener('change',function(e){
    var el=e.target;if(!el.classList.contains('invalid'))return;
    if(el.value.trim()){el.classList.remove('invalid');var p=el.parentElement;var err=p?p.querySelector('.ls-field-error'):null;if(err)err.classList.remove('show');}
});

</script>
</asp:Content>
