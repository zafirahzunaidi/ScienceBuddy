<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MyProfile.aspx.cs"
    Inherits="ScienceBuddy.Teacher.MyProfile" MasterPageFile="~/Site.Master"
    Title="My Profile" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--tp:#6C63FF;--tp2:#8B5CF6;--tp-h:#5A52E0;--tl:#F5F3FF;--tc:#FFF;--tb:#E5E7EB;--tt:#1F2937;--tm:#6B7280;--ts:#10B981;--te:#EF4444;--tw:#F59E0B;--cyan:#06B6D4;}
/* Hero Banner - Premium Purple/Lavender */
.mp-hero{background:linear-gradient(135deg,#4C1D95 0%,#6D28D9 25%,#7C3AED 45%,#6366F1 70%,#A5B4FC 100%);border-radius:24px;padding:2.8rem 2.8rem;color:#fff;display:flex;align-items:center;gap:2.4rem;position:relative;overflow:hidden;margin-bottom:2rem;box-shadow:0 20px 60px rgba(109,40,217,.25);animation:mpHeroFadeIn .6s ease;}
@keyframes mpHeroFadeIn{from{opacity:0;transform:translateY(10px);}to{opacity:1;transform:translateY(0);}}
.mp-hero:hover{box-shadow:0 24px 68px rgba(109,40,217,.32);}
/* Glow effects */
.mp-hero::before{content:'';position:absolute;width:320px;height:320px;border-radius:50%;background:radial-gradient(circle,rgba(196,181,253,.2),transparent 65%);top:-100px;right:-60px;pointer-events:none;}
.mp-hero::after{content:'';position:absolute;width:220px;height:220px;border-radius:50%;background:radial-gradient(circle,rgba(244,114,182,.12),transparent 65%);bottom:-80px;left:60px;pointer-events:none;}
/* Decorative SVG overlay */
.mp-hero-decor{position:absolute;inset:0;pointer-events:none;z-index:0;background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='500' height='200'%3E%3Ccircle cx='420' cy='40' r='22' fill='none' stroke='rgba(255,255,255,.08)' stroke-width='1.2'/%3E%3Ccircle cx='420' cy='40' r='12' fill='none' stroke='rgba(255,255,255,.06)' stroke-width='1'/%3E%3Ccircle cx='420' cy='40' r='34' fill='none' stroke='rgba(255,255,255,.05)' stroke-width='.8'/%3E%3Ccircle cx='432' cy='40' r='2' fill='rgba(255,255,255,.12)'/%3E%3Ccircle cx='400' cy='28' r='1.5' fill='rgba(255,255,255,.1)'/%3E%3Cpath d='M60 160 L60 166 M57 163 L63 163' stroke='rgba(255,255,255,.1)' stroke-width='1.2' stroke-linecap='round'/%3E%3Cpath d='M460 150 L460 156 M457 153 L463 153' stroke='rgba(255,255,255,.08)' stroke-width='1' stroke-linecap='round'/%3E%3Cpath d='M350 170 L351.5 176 L350 182 L348.5 176 Z' fill='rgba(255,255,255,.08)'/%3E%3Cpath d='M350 170 L356 171.5 L350 173 L344 171.5 Z' fill='rgba(255,255,255,.08)'/%3E%3Ccircle cx='80' cy='30' r='1.5' fill='rgba(255,255,255,.09)'/%3E%3Ccircle cx='300' cy='20' r='1.2' fill='rgba(255,255,255,.07)'/%3E%3Ccircle cx='150' cy='170' r='1.8' fill='rgba(255,255,255,.06)'/%3E%3Cpath d='M250 25 Q260 15 270 25' fill='none' stroke='rgba(255,255,255,.06)' stroke-width='1'/%3E%3C/svg%3E");background-size:cover;background-position:center;}
/* Avatar */
.mp-avatar{width:110px;height:110px;border-radius:50%;background:linear-gradient(135deg,rgba(255,255,255,.18),rgba(255,255,255,.06));border:3px solid rgba(255,255,255,.25);display:flex;align-items:center;justify-content:center;font-size:2.4rem;font-weight:800;flex-shrink:0;position:relative;z-index:1;backdrop-filter:blur(10px);box-shadow:0 10px 40px rgba(0,0,0,.2);}
.mp-avatar-verified{position:absolute;bottom:2px;right:2px;width:26px;height:26px;border-radius:50%;background:#10B981;border:3px solid #4C1D95;display:flex;align-items:center;justify-content:center;font-size:.7rem;color:#fff;z-index:2;}
.mp-hero-info{position:relative;z-index:1;flex:1;}
.mp-hero-name{font-size:1.9rem;font-weight:800;margin-bottom:4px;letter-spacing:-.4px;background:linear-gradient(90deg,#fff 0%,#E0E7FF 50%,#fff 100%);background-size:200% auto;-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;animation:mpShimmer 4s ease-in-out infinite;}
@keyframes mpShimmer{0%,100%{background-position:0% center;}50%{background-position:200% center;}}
.mp-hero-subtitle{font-size:.85rem;opacity:.7;font-weight:600;margin-bottom:12px;letter-spacing:.3px;}
.mp-hero-meta{display:flex;gap:.6rem;flex-wrap:wrap;align-items:center;margin-bottom:14px;}
.mp-badge{padding:6px 14px;border-radius:50px;font-size:.76rem;font-weight:700;display:inline-flex;align-items:center;gap:5px;backdrop-filter:blur(4px);}
.mp-badge-green{background:rgba(16,185,129,.2);color:#6EE7B7;border:1px solid rgba(16,185,129,.35);}
.mp-badge-orange{background:rgba(245,158,11,.2);color:#FCD34D;border:1px solid rgba(245,158,11,.35);}
.mp-badge-red{background:rgba(239,68,68,.2);color:#FCA5A5;border:1px solid rgba(239,68,68,.35);}
.mp-badge-grey{background:rgba(255,255,255,.1);color:rgba(255,255,255,.85);border:1px solid rgba(255,255,255,.2);}
.mp-badge-lavender{background:rgba(196,181,253,.2);color:#E9D5FF;border:1px solid rgba(196,181,253,.3);}
.mp-hero-tagline{font-size:.88rem;opacity:.78;line-height:1.6;max-width:520px;font-style:italic;}
.mp-hero-info-row{display:flex;gap:1rem;flex-wrap:wrap;align-items:center;margin-top:12px;font-size:.78rem;font-weight:600;opacity:.7;}
.mp-hero-info-row span{display:inline-flex;align-items:center;gap:4px;}
/* Tabs */
.mp-tabs{display:flex;gap:0;border-bottom:2px solid var(--tb);margin-bottom:1.5rem;overflow-x:auto;-ms-overflow-style:none;scrollbar-width:none;}
.mp-tabs::-webkit-scrollbar{display:none;}
.mp-tab{padding:.75rem 1.3rem;font-size:.88rem;font-weight:700;cursor:pointer;border:none;background:transparent;color:var(--tm);transition:color .15s;text-decoration:none;margin-bottom:-2px;border-bottom:2.5px solid transparent;display:inline-flex;align-items:center;gap:6px;white-space:nowrap;}
.mp-tab:hover{color:var(--tp);}
.mp-tab-active{color:var(--tp);border-bottom-color:var(--tp);}
/* Tab content */
.mp-tab-content{display:none;animation:mpTabFadeIn .3s ease;}
.mp-tab-visible{display:block;}
@keyframes mpTabFadeIn{from{opacity:0;transform:translateY(6px);}to{opacity:1;transform:translateY(0);}}
/* Cards */
.mp-card{background:var(--tc);border:1.5px solid var(--tb);border-radius:18px;padding:1.8rem;box-shadow:0 4px 16px rgba(0,0,0,.05);transition:transform .2s,box-shadow .2s;}
.mp-card:hover{transform:translateY(-2px);box-shadow:0 8px 28px rgba(108,99,255,.1);}
.mp-card-title{font-size:1rem;font-weight:800;color:var(--tt);margin-bottom:1.2rem;display:flex;align-items:center;gap:9px;}
.mp-card-title i{color:var(--tp);font-size:1.15rem;}
.mp-field{margin-bottom:1.1rem;}.mp-field:last-child{margin-bottom:0;}
.mp-field-label{font-size:.78rem;font-weight:700;color:var(--tm);text-transform:uppercase;letter-spacing:.5px;margin-bottom:5px;}
.mp-field-value{font-size:.94rem;font-weight:600;color:var(--tt);}
.mp-input{width:100%;border-radius:10px;border:1.5px solid var(--tb);padding:.65rem .9rem;font-size:.9rem;transition:all .2s;}
.mp-input:focus{border-color:var(--tp);outline:none;box-shadow:0 0 0 3px rgba(108,99,255,.08);}
.mp-input.invalid{border-color:var(--te);box-shadow:0 0 0 3px rgba(239,68,68,.08);}
.mp-textarea{min-height:110px;resize:vertical;line-height:1.6;}
.mp-char{font-size:.74rem;color:var(--tm);text-align:right;margin-top:4px;}
.mp-val-msg{font-size:.76rem;color:var(--te);margin-top:4px;display:none;}.mp-val-msg.show{display:block;}
/* Progress - Cyan/Teal */
.mp-progress-card{background:var(--tc);border:1.5px solid var(--tb);border-radius:18px;padding:1.4rem 1.6rem;margin-bottom:1.5rem;display:flex;align-items:center;gap:1.4rem;box-shadow:0 4px 16px rgba(0,0,0,.05);}
.mp-pct{font-size:1.6rem;font-weight:800;color:#0891B2;}
.mp-progress-bar{flex:1;height:10px;background:#ECFEFF;border-radius:10px;overflow:hidden;}
.mp-progress-fill{height:100%;background:linear-gradient(90deg,#06B6D4,#22D3EE);border-radius:10px;transition:width .6s ease;}
.mp-progress-msg{font-size:.82rem;color:var(--tm);font-weight:600;}
/* Certificate */
.mp-cert-file{display:flex;align-items:center;gap:14px;padding:1.1rem 1.3rem;background:#FAFAFA;border-radius:14px;border:1.5px solid #F0F0F0;}
.mp-cert-icon{width:50px;height:50px;border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:1.5rem;flex-shrink:0;}
.mp-cert-icon.pdf{background:#FEF2F2;color:#DC2626;}
.mp-cert-icon.img{background:#ECFDF5;color:#059669;}
.mp-cert-icon.doc{background:#EFF6FF;color:#2563EB;}
.mp-cert-icon.ppt{background:#FFF7ED;color:#EA580C;}
.mp-cert-icon.other{background:#F3F4F6;color:#6B7280;}
.mp-cert-name{font-size:.95rem;font-weight:700;color:var(--tt);}
.mp-cert-btn{font-size:.82rem;font-weight:700;color:var(--tp);text-decoration:none;padding:8px 16px;border-radius:10px;border:1.5px solid var(--tb);background:var(--tc);transition:all .2s;cursor:pointer;}
.mp-cert-btn:hover{border-color:var(--tp);background:var(--tl);color:var(--tp-h);}
.mp-cert-date{font-size:.78rem;font-weight:700;color:var(--ts);margin-top:4px;display:flex;align-items:center;gap:4px;}
/* Certificate Modal */
.mp-cert-modal-overlay{position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,.6);z-index:9999;display:none;align-items:center;justify-content:center;padding:1.5rem;}
.mp-cert-modal-overlay.active{display:flex;}
.mp-cert-modal{background:#fff;border-radius:18px;width:100%;max-width:820px;max-height:88vh;display:flex;flex-direction:column;box-shadow:0 24px 64px rgba(0,0,0,.25);}
.mp-cert-modal-hd{display:flex;align-items:center;justify-content:space-between;padding:1.2rem 1.6rem;border-bottom:1px solid var(--tb);}
.mp-cert-modal-hd h4{margin:0;font-size:1rem;font-weight:800;color:var(--tt);}
.mp-cert-modal-close{background:none;border:none;font-size:1.5rem;color:var(--tm);cursor:pointer;line-height:1;padding:4px;border-radius:6px;transition:background .15s;}
.mp-cert-modal-close:hover{background:#F3F4F6;color:var(--tt);}
.mp-cert-modal-body{flex:1;overflow:auto;padding:0;}
.mp-cert-modal-body iframe,.mp-cert-modal-body img{width:100%;height:100%;min-height:500px;border:none;display:block;}
/* Permissions - Minimal */
.mp-perm-list{list-style:none;padding:0;margin:0;}
.mp-perm-list li{display:flex;align-items:center;padding:.7rem 0;font-size:.88rem;border-bottom:1px solid #F3F4F6;transition:background .12s,padding .12s;}
.mp-perm-list li:last-child{border-bottom:none;}
.mp-perm-list li:hover{background:#FAFAFA;padding-left:.5rem;padding-right:.5rem;border-radius:8px;}
.mp-perm-ico{width:22px;height:22px;display:flex;align-items:center;justify-content:center;font-size:.82rem;flex-shrink:0;margin-right:10px;}
.mp-perm-name{flex:1;font-weight:600;color:var(--tt);}
.mp-perm-status{font-size:.78rem;font-weight:700;padding:3px 10px;border-radius:6px;}
.mp-perm-status.allowed{color:#047857;background:#ECFDF5;}
.mp-perm-status.restricted{color:#6B7280;background:#F3F4F6;}
.mp-perm-list li.enabled .mp-perm-ico{color:#059669;}
.mp-perm-list li.restricted .mp-perm-ico{color:#9CA3AF;}
/* Actions */
.mp-actions{display:flex;gap:.85rem;justify-content:flex-end;margin-top:1.8rem;}
.mp-btn{padding:.7rem 1.6rem;border-radius:12px;font-size:.9rem;font-weight:700;cursor:pointer;border:none;transition:all .2s;}
.mp-btn:hover{transform:translateY(-1px);}
.mp-btn-primary{background:linear-gradient(135deg,var(--tp),var(--tp2));color:#fff;box-shadow:0 4px 14px rgba(108,99,255,.25);}
.mp-btn-primary:hover{box-shadow:0 6px 22px rgba(108,99,255,.35);}
.mp-btn-cancel{background:var(--tc);color:var(--tt);border:1.5px solid var(--tb);}
/* Toast */
.mp-toast-container{position:fixed;top:1.25rem;right:1.25rem;z-index:9999;display:flex;flex-direction:column;gap:.5rem;}
.mp-toast{background:#10B981;color:#fff;padding:.8rem 1.3rem;border-radius:12px;font-size:.88rem;font-weight:600;display:flex;align-items:center;gap:8px;box-shadow:0 8px 24px rgba(16,185,129,.3);animation:mpSlide .3s ease;}
.mp-toast-out{opacity:0;transform:translateX(30px);transition:all .4s;}
@keyframes mpSlide{from{opacity:0;transform:translateX(30px);}to{opacity:1;transform:translateX(0);}}
/* Password field */
.mp-pw-wrap{position:relative;}
.mp-pw-input{padding-right:2.5rem;}
.mp-pw-toggle{position:absolute;right:10px;top:50%;transform:translateY(-50%);background:none;border:none;color:var(--tm);cursor:pointer;font-size:1rem;padding:4px;border-radius:4px;transition:color .15s;}
.mp-pw-toggle:hover{color:var(--tp);}
/* Delete account */
.mp-card-danger{border-color:#FECACA;background:#FFFBFB;}
.mp-btn-delete-account{background:#FEF2F2;color:#DC2626;border:1.5px solid #FECACA;border-radius:10px;padding:.6rem 1.4rem;font-size:.84rem;font-weight:700;cursor:pointer;display:inline-flex;align-items:center;gap:6px;transition:background .15s,border-color .15s;}
.mp-btn-delete-account:hover{background:#FEE2E2;border-color:#FCA5A5;}
.mp-btn-delete-confirm{background:#DC2626;color:#fff;border:none;border-radius:10px;padding:.6rem 1.4rem;font-size:.84rem;font-weight:700;cursor:pointer;display:inline-flex;align-items:center;gap:6px;transition:background .15s;}
.mp-btn-delete-confirm:hover{background:#B91C1C;}
/* Delete Account Modal */
.da-modal-body{padding:1.5rem;text-align:left;}
.da-msg{font-size:.9rem;color:#374151;font-weight:600;margin:0 0 .85rem;line-height:1.55;}
.da-warning{display:flex;align-items:flex-start;gap:.6rem;padding:.7rem .9rem;background:#FEF2F2;border:1px solid #FECACA;border-radius:10px;margin-bottom:1.2rem;font-size:.82rem;color:#B91C1C;font-weight:600;line-height:1.5;}
.da-warning i{font-size:1rem;flex-shrink:0;margin-top:1px;}
.da-reasons{display:flex;flex-direction:column;gap:.5rem;margin-bottom:1rem;}
.da-reason{display:flex;align-items:center;gap:.6rem;padding:.6rem .85rem;border-radius:10px;border:1.5px solid #E5E7EB;background:#FAFAFA;cursor:pointer;transition:border-color .15s,background .15s;font-size:.86rem;font-weight:600;color:#374151;}
.da-reason:hover{border-color:#FCA5A5;background:#FEF2F2;}
.da-reason input[type="radio"]{accent-color:#DC2626;width:16px;height:16px;flex-shrink:0;}
.da-reason input[type="radio"]:checked ~ span{color:#B91C1C;}
.da-other-wrap{margin-bottom:.75rem;animation:mpTabFadeIn .2s ease;}
.da-val-msg{font-size:.8rem;font-weight:600;color:#B91C1C;padding:.4rem .6rem;background:#FEF2F2;border-radius:8px;margin-top:.5rem;}
/* Modal overlay (reuse from manage quiz if not available) */
.mq-modal-overlay{position:fixed;inset:0;background:rgba(17,24,39,.5);z-index:9000;display:flex;align-items:center;justify-content:center;padding:1rem;}
.mq-modal{background:#fff;border-radius:16px;width:100%;max-width:420px;box-shadow:0 20px 60px rgba(0,0,0,.2);animation:mpModalFade .2s ease;}
@keyframes mpModalFade{from{opacity:0;transform:translateY(10px);}to{opacity:1;transform:translateY(0);}}
.mq-modal-header{display:flex;align-items:center;justify-content:space-between;padding:1.25rem 1.5rem;border-bottom:1px solid var(--tb);}
.mq-modal-header h3{font-size:1.05rem;font-weight:800;color:var(--tt);margin:0;}
.mq-modal-close{background:none;border:none;font-size:1.4rem;color:var(--tm);cursor:pointer;}.mq-modal-close:hover{color:var(--tt);}
.mq-modal-body{padding:1.5rem;text-align:center;}
.mq-modal-footer{display:flex;gap:.75rem;justify-content:flex-end;padding:1rem 1.5rem;border-top:1px solid var(--tb);}
.mq-btn-cancel{background:#fff;border:1.5px solid var(--tb);border-radius:10px;padding:.55rem 1.1rem;font-weight:600;font-size:.84rem;color:var(--tt);cursor:pointer;}
@media(max-width:768px){.mp-hero{flex-direction:column;text-align:center;padding:2rem 1.5rem;}.mp-hero-meta{justify-content:center;}.mp-hero-tagline{margin-left:auto;margin-right:auto;}.mp-hero-info-row{justify-content:center;}.mp-tabs{gap:0;}.mp-tab{padding:.7rem 1rem;font-size:.82rem;}.mp-actions{flex-direction:column;}.mp-cert-modal{max-width:100%;border-radius:12px;}}
</style>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label"><%: T("Notifications","Notifikasi") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Teaching","Pengajaran") %></div>
        <a href="<%: ResolveUrl("~/Teacher/manageMaterials.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label"><%: T("Manage Materials","Bahan Pembelajaran") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label"><%: T("Manage Quiz","Kuiz") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/studentProgress.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bar-chart item-icon"></i><span class="item-label"><%: T("Student Progress","Prestasi Pelajar") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/liveSession.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label"><%: T("Schedule Live Class","Kelas Langsung") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Community","Komuniti") %></div>
        <a href="<%: ResolveUrl("~/Teacher/forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/privateMessages.aspx") %>" class="sb-sidebar-item"><i class="bi bi-envelope item-icon"></i><span class="item-label"><%: T("Private Message","Mesej Peribadi") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Account","Akaun") %></div>
        <a href="<%: ResolveUrl("~/Teacher/MyProfile.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("My Profile","Profil Saya") %></span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Sign Out","Log Keluar") %></span></a></div>
</asp:Content>
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("My Profile","Profil Saya") %></asp:Content>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- Hero --%>
<div class="mp-hero">
    <div class="mp-hero-decor"></div>
    <div class="mp-avatar">
        <asp:Literal ID="litInitials" runat="server" Text="T" />
        <asp:Panel ID="pnlAvatarVerified" runat="server" CssClass="mp-avatar-verified" Visible="false"><i class="bi bi-check-lg"></i></asp:Panel>
    </div>
    <div class="mp-hero-info">
        <div class="mp-hero-name"><asp:Literal ID="litName" runat="server" /></div>
        <div class="mp-hero-subtitle">ScienceBuddy Teacher</div>
        <div class="mp-hero-meta">
            <asp:Literal ID="litStatusBadge" runat="server" />
            <span class="mp-badge mp-badge-grey"><i class="bi bi-hash"></i> <asp:Literal ID="litTeacherId" runat="server" /></span>
        </div>
        <div class="mp-hero-tagline"><%: T("Inspiring young minds to explore, question and discover the world of science.","Menginspirasi minda muda untuk meneroka, menyoal dan menemui dunia sains.") %></div>
        <div class="mp-hero-info-row">
            <span><i class="bi bi-briefcase"></i> <%: T("Educator","Pendidik") %></span>
            <span><i class="bi bi-shield-check"></i> <asp:Literal ID="litProfileStatus" runat="server" Text="Active" /></span>
            <span><i class="bi bi-person-badge"></i> <asp:Literal ID="litMemberId" runat="server" /></span>
        </div>
    </div>
</div>

<%-- Tabs --%>
<div class="mp-tabs">
    <button type="button" class="mp-tab mp-tab-active" onclick="switchTab('personal',this)"><i class="bi bi-person-circle"></i> <%: T("Personal Information","Maklumat Peribadi") %></button>
    <button type="button" class="mp-tab" onclick="switchTab('certificate',this)"><i class="bi bi-file-earmark-check"></i> <%: T("Teaching Certificate","Sijil Pengajaran") %></button>
    <button type="button" class="mp-tab" onclick="switchTab('permissions',this)"><i class="bi bi-shield-check"></i> <%: T("Teaching Permissions","Kebenaran Pengajaran") %></button>
    <button type="button" class="mp-tab" onclick="switchTab('settings',this)"><i class="bi bi-gear"></i> <%: T("Account Settings","Tetapan Akaun") %></button>
</div>

<%-- Tab: Personal Information --%>
<div class="mp-tab-content mp-tab-visible" id="tab-personal">
<div class="mp-card">
    <div class="mp-field"><div class="mp-field-label"><%: T("Full Name","Nama Penuh") %> *</div>
        <asp:TextBox ID="txtName" runat="server" CssClass="mp-input" MaxLength="100" />
        <div class="mp-val-msg" id="valName"></div>
    </div>
    <div class="mp-field"><div class="mp-field-label"><%: T("Teacher ID","ID Guru") %></div><div class="mp-field-value"><asp:Literal ID="litTID" runat="server" /></div></div>
    <div class="mp-field"><div class="mp-field-label"><%: T("Academic Qualification","Kelayakan Akademik") %></div><div class="mp-field-value"><asp:Literal ID="litQual" runat="server" /></div></div>
    <div class="mp-field">
        <div class="mp-field-label"><%: T("Phone Number","Nombor Telefon") %> *</div>
        <asp:TextBox ID="txtPhone" runat="server" CssClass="mp-input" MaxLength="15" />
        <div class="mp-val-msg" id="valPhone"></div>
    </div>
    <div class="mp-field">
        <div class="mp-field-label"><%: T("Biography","Biografi") %></div>
        <asp:TextBox ID="txtBio" runat="server" TextMode="MultiLine" Rows="4" CssClass="mp-input mp-textarea" MaxLength="500" />
        <div class="mp-char" id="bioCounter">0 / 500</div>
    </div>
</div>
<div class="mp-actions">
    <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="mp-btn mp-btn-cancel" OnClick="btnCancel_Click" CausesValidation="false" />
    <asp:Button ID="btnSave" runat="server" Text="Save Changes" CssClass="mp-btn mp-btn-primary" OnClick="btnSave_Click" CausesValidation="false" />
</div>
</div>

<%-- Tab: Teaching Certificate --%>
<div class="mp-tab-content" id="tab-certificate">
<div class="mp-card">
    <asp:Panel ID="pnlCertExists" runat="server" Visible="false">
        <div class="mp-cert-file">
            <div class="mp-cert-icon" id="certIconDiv" runat="server"><i id="certIconI" runat="server" class="bi bi-file-earmark-fill"></i></div>
            <div style="flex:1;">
                <div class="mp-cert-name"><asp:Literal ID="litCertName" runat="server" /></div>
                <asp:Panel ID="pnlApprovedDate" runat="server" Visible="false">
                    <div class="mp-cert-date"><i class="bi bi-calendar-check"></i> <%: T("Approved","Diluluskan") %>: <asp:Literal ID="litApprovedDate" runat="server" /></div>
                </asp:Panel>
            </div>
            <a id="lnkCert" runat="server" class="mp-cert-btn" onclick="openCertModal(event);return false;"><i class="bi bi-eye"></i> <%: T("View","Lihat") %></a>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlCertEmpty" runat="server" Visible="false">
        <div style="text-align:center;padding:2rem;color:var(--tm);">
            <i class="bi bi-file-earmark-x" style="font-size:2.5rem;opacity:.4;"></i>
            <p style="font-size:.88rem;margin-top:.6rem;font-weight:600;"><%: T("No teaching certificate uploaded.","Tiada sijil pengajaran dimuat naik.") %></p>
        </div>
    </asp:Panel>
</div>
</div>

<%-- Tab: Teaching Permissions --%>
<div class="mp-tab-content" id="tab-permissions">
<div class="mp-card">
    <asp:Panel ID="pnlVerCertified" runat="server" Visible="false">
        <div style="display:inline-flex;align-items:center;gap:6px;padding:5px 12px;background:#ECFDF5;border-radius:8px;font-size:.82rem;font-weight:700;color:#047857;margin-bottom:1rem;">
            <i class="bi bi-patch-check-fill"></i> <%: T("Verified Educator","Pendidik Disahkan") %>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlVerPending" runat="server" Visible="false">
        <div style="display:inline-flex;align-items:center;gap:6px;padding:5px 12px;background:#FEF3C7;border-radius:8px;font-size:.82rem;font-weight:700;color:#92400E;margin-bottom:1rem;">
            <i class="bi bi-hourglass-split"></i> <%: T("Pending Verification","Pengesahan Belum Selesai") %>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlVerRejected" runat="server" Visible="false">
        <div style="display:inline-flex;align-items:center;gap:6px;padding:5px 12px;background:#FEF2F2;border-radius:8px;font-size:.82rem;font-weight:700;color:#B91C1C;margin-bottom:1rem;">
            <i class="bi bi-x-circle-fill"></i> <%: T("Verification Rejected","Pengesahan Ditolak") %>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlVerUnknown" runat="server" Visible="false">
        <div style="display:inline-flex;align-items:center;gap:6px;padding:5px 12px;background:#F3F4F6;border-radius:8px;font-size:.82rem;font-weight:700;color:var(--tm);margin-bottom:1rem;">
            <i class="bi bi-question-circle"></i> <%: T("Status unavailable","Status tidak tersedia") %>
        </div>
    </asp:Panel>
    <asp:Literal ID="litPermissions" runat="server" />
</div>
</div>

<%-- Tab: Account Settings --%>
<div class="mp-tab-content" id="tab-settings">

<%-- Preferred Language --%>
<div class="mp-card" style="margin-bottom:1.5rem;">
    <div class="mp-card-title"><i class="bi bi-translate"></i> <%: T("Preferred Language","Bahasa Pilihan") %></div>
    <p style="font-size:.84rem;color:var(--tm);margin:0 0 1rem;line-height:1.5;"><%: T("Choose your preferred display language for ScienceBuddy.","Pilih bahasa paparan pilihan anda untuk ScienceBuddy.") %></p>
    <div class="mp-field">
        <select id="selLanguage" class="mp-input" style="height:42px;">
            <option value="EN" <%= CurrentLanguage == "EN" ? "selected" : "" %>>English</option>
            <option value="BM" <%= CurrentLanguage == "BM" ? "selected" : "" %>>Bahasa Melayu</option>
        </select>
    </div>
    <div style="margin-top:1rem;">
        <button type="button" class="mp-btn mp-btn-primary" style="padding:.6rem 1.4rem;font-size:.84rem;" onclick="saveLanguage()"><i class="bi bi-check-lg"></i> <%: T("Save Language","Simpan Bahasa") %></button>
    </div>
</div>

<%-- Change Password --%>
<div class="mp-card" style="margin-bottom:1.5rem;">
    <div class="mp-card-title"><i class="bi bi-key"></i> <%: T("Change Password","Tukar Kata Laluan") %></div>
    <div class="mp-field">
        <div class="mp-field-label"><%: T("Current Password","Kata Laluan Semasa") %> *</div>
        <div class="mp-pw-wrap">
            <input type="password" id="pwCurrent" class="mp-input mp-pw-input" autocomplete="current-password" />
            <button type="button" class="mp-pw-toggle" onclick="togglePw('pwCurrent',this)"><i class="bi bi-eye"></i></button>
        </div>
    </div>
    <div class="mp-field">
        <div class="mp-field-label"><%: T("New Password","Kata Laluan Baharu") %> *</div>
        <div class="mp-pw-wrap">
            <input type="password" id="pwNew" class="mp-input mp-pw-input" autocomplete="new-password" />
            <button type="button" class="mp-pw-toggle" onclick="togglePw('pwNew',this)"><i class="bi bi-eye"></i></button>
        </div>
    </div>
    <div class="mp-field">
        <div class="mp-field-label"><%: T("Confirm New Password","Sahkan Kata Laluan Baharu") %> *</div>
        <div class="mp-pw-wrap">
            <input type="password" id="pwConfirm" class="mp-input mp-pw-input" autocomplete="new-password" />
            <button type="button" class="mp-pw-toggle" onclick="togglePw('pwConfirm',this)"><i class="bi bi-eye"></i></button>
        </div>
    </div>
    <div id="pwMsg" style="font-size:.8rem;margin-top:.5rem;font-weight:600;display:none;"></div>
    <div style="margin-top:1.2rem;">
        <button type="button" class="mp-btn mp-btn-primary" style="padding:.6rem 1.4rem;font-size:.84rem;" onclick="changePassword()"><i class="bi bi-shield-lock"></i> <%: T("Save Password","Simpan Kata Laluan") %></button>
    </div>
</div>

<%-- Delete Account --%>
<div class="mp-card mp-card-danger">
    <div class="mp-card-title" style="color:#B91C1C;"><i class="bi bi-exclamation-triangle-fill" style="color:#EF4444;"></i> <%: T("Delete Account","Padam Akaun") %></div>
    <p style="font-size:.88rem;color:#6B7280;margin:0 0 1.2rem;line-height:1.6;"><%: T("Deleting your account is permanent and cannot be undone.","Pemadaman akaun anda adalah kekal dan tidak boleh dibatalkan.") %></p>
    <button type="button" class="mp-btn-delete-account" onclick="openDeleteAccountModal()"><i class="bi bi-trash3"></i> <%: T("Delete Account","Padam Akaun") %></button>
</div>

</div>

<%-- Delete Account Confirmation Modal --%>
<div id="deleteAccountModal" class="mq-modal-overlay" style="display:none;" onclick="if(event.target===this)closeDeleteAccountModal()">
    <div class="mq-modal" style="max-width:500px;">
        <div class="mq-modal-header" style="background:#FEF2F2;border-bottom:1px solid #FECACA;">
            <h3 style="color:#B91C1C;display:flex;align-items:center;gap:8px;font-size:1.1rem;"><i class="bi bi-exclamation-triangle-fill" style="color:#EF4444;"></i> <%: T("Delete Account","Padam Akaun") %></h3>
            <button type="button" class="mq-modal-close" onclick="closeDeleteAccountModal()">×</button>
        </div>
        <div class="da-modal-body">
            <p class="da-msg"><%: T("We're sorry to see you go. Please tell us why you're leaving before deleting your account.","Kami sedih melihat anda pergi. Sila beritahu kami mengapa anda meninggalkan sebelum memadam akaun anda.") %></p>
            <div class="da-warning">
                <i class="bi bi-shield-exclamation"></i>
                <span><%: T("Deleting your account is permanent and cannot be undone.","Pemadaman akaun anda adalah kekal dan tidak boleh dibatalkan.") %></span>
            </div>

            <div class="da-reasons">
                <label class="da-reason"><input type="radio" name="daReason" value="no_longer_use" /><span><%: T("I no longer use ScienceBuddy","Saya tidak lagi menggunakan ScienceBuddy") %></span></label>
                <label class="da-reason"><input type="radio" name="daReason" value="another_account" /><span><%: T("I created another account","Saya mencipta akaun lain") %></span></label>
                <label class="da-reason"><input type="radio" name="daReason" value="privacy" /><span><%: T("I have privacy concerns","Saya mempunyai kebimbangan privasi") %></span></label>
                <label class="da-reason"><input type="radio" name="daReason" value="technical" /><span><%: T("I am experiencing technical issues","Saya mengalami masalah teknikal") %></span></label>
                <label class="da-reason"><input type="radio" name="daReason" value="not_meet_needs" /><span><%: T("The platform does not meet my needs","Platform ini tidak memenuhi keperluan saya") %></span></label>
                <label class="da-reason"><input type="radio" name="daReason" value="other" /><span><%: T("Other","Lain-lain") %></span></label>
            </div>

            <div id="daOtherWrap" class="da-other-wrap" style="display:none;">
                <textarea id="daOtherText" class="mp-input mp-textarea" rows="3" placeholder="<%: T("Please share your reason.","Sila kongsi alasan anda.") %>" style="min-height:80px;"></textarea>
            </div>

            <div id="daValMsg" class="da-val-msg" style="display:none;"></div>
        </div>
        <div class="mq-modal-footer">
            <button type="button" class="mq-btn-cancel" onclick="closeDeleteAccountModal()"><%: T("Cancel","Batal") %></button>
            <button type="button" class="mp-btn-delete-confirm" onclick="confirmDeleteAccount()"><i class="bi bi-trash3"></i> <%: T("Delete Account","Padam Akaun") %></button>
        </div>
    </div>
</div>

<asp:HiddenField ID="hidToast" runat="server" Value="" />
<div id="mpToast" class="mp-toast-container"></div>

<%-- Certificate View Modal --%>
<div id="certModal" class="mp-cert-modal-overlay" onclick="if(event.target===this)closeCertModal()">
    <div class="mp-cert-modal">
        <div class="mp-cert-modal-hd">
            <h4><i class="bi bi-file-earmark-text"></i> <%: T("Teaching Certificate","Sijil Pengajaran") %></h4>
            <button type="button" class="mp-cert-modal-close" onclick="closeCertModal()">&times;</button>
        </div>
        <div class="mp-cert-modal-body" id="certModalBody"></div>
    </div>
</div>
</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
// Tab switching
function switchTab(tabId, btn){
    var contents=document.querySelectorAll('.mp-tab-content');
    for(var i=0;i<contents.length;i++){contents[i].classList.remove('mp-tab-visible');}
    var target=document.getElementById('tab-'+tabId);
    if(target){target.classList.add('mp-tab-visible');}
    var tabs=document.querySelectorAll('.mp-tab');
    for(var j=0;j<tabs.length;j++){tabs[j].classList.remove('mp-tab-active');}
    btn.classList.add('mp-tab-active');
}
// Password toggle
function togglePw(id,btn){
    var inp=document.getElementById(id);
    if(inp.type==='password'){inp.type='text';btn.innerHTML='<i class="bi bi-eye-slash"></i>';}
    else{inp.type='password';btn.innerHTML='<i class="bi bi-eye"></i>';}
}
// Save Language
function saveLanguage(){
    var lang=document.getElementById('selLanguage').value;
    var xhr=new XMLHttpRequest();
    xhr.open('POST','MyProfile.aspx?handler=savelang&lang='+encodeURIComponent(lang),true);
    xhr.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
    xhr.onreadystatechange=function(){
        if(xhr.readyState===4){
            if(xhr.status===200){showMpToast('<%: T("Language saved successfully.","Bahasa berjaya disimpan.") %>');setTimeout(function(){location.reload();},1200);}
            else{alert('Error saving language.');}
        }
    };
    xhr.send('');
}
// Change Password
function changePassword(){
    var cur=document.getElementById('pwCurrent').value;
    var nw=document.getElementById('pwNew').value;
    var cf=document.getElementById('pwConfirm').value;
    var msg=document.getElementById('pwMsg');
    msg.style.display='none';
    if(!cur||!nw||!cf){msg.textContent='<%: T("All fields are required.","Semua medan diperlukan.") %>';msg.style.color='#B91C1C';msg.style.display='block';return;}
    if(nw.length<6){msg.textContent='<%: T("New password must be at least 6 characters.","Kata laluan baharu mestilah sekurang-kurangnya 6 aksara.") %>';msg.style.color='#B91C1C';msg.style.display='block';return;}
    if(nw!==cf){msg.textContent='<%: T("Passwords do not match.","Kata laluan tidak sepadan.") %>';msg.style.color='#B91C1C';msg.style.display='block';return;}
    var xhr=new XMLHttpRequest();
    xhr.open('POST','MyProfile.aspx?handler=changepw',true);
    xhr.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
    xhr.onreadystatechange=function(){
        if(xhr.readyState===4){
            if(xhr.status===200){
                msg.textContent='<%: T("Password changed successfully.","Kata laluan berjaya ditukar.") %>';msg.style.color='#047857';msg.style.display='block';
                document.getElementById('pwCurrent').value='';document.getElementById('pwNew').value='';document.getElementById('pwConfirm').value='';
                showMpToast('<%: T("Password changed.","Kata laluan ditukar.") %>');
            }else{
                msg.textContent=xhr.responseText||'<%: T("Error changing password.","Ralat menukar kata laluan.") %>';msg.style.color='#B91C1C';msg.style.display='block';
            }
        }
    };
    xhr.send('current='+encodeURIComponent(cur)+'&newpw='+encodeURIComponent(nw));
}
// Delete Account Modal
function openDeleteAccountModal(){
    document.getElementById('deleteAccountModal').style.display='flex';
    // Reset state
    var radios=document.querySelectorAll('input[name="daReason"]');
    for(var i=0;i<radios.length;i++){radios[i].checked=false;}
    document.getElementById('daOtherWrap').style.display='none';
    document.getElementById('daOtherText').value='';
    var msg=document.getElementById('daValMsg');msg.style.display='none';msg.textContent='';
}
function closeDeleteAccountModal(){document.getElementById('deleteAccountModal').style.display='none';}
// Show/hide Other textbox based on radio selection
document.addEventListener('change',function(e){
    if(e.target.name==='daReason'){
        var otherWrap=document.getElementById('daOtherWrap');
        if(e.target.value==='other'){otherWrap.style.display='block';}
        else{otherWrap.style.display='none';document.getElementById('daOtherText').value='';}
        document.getElementById('daValMsg').style.display='none';
    }
});
function confirmDeleteAccount(){
    var msg=document.getElementById('daValMsg');
    msg.style.display='none';msg.textContent='';
    // Get selected reason
    var selected=document.querySelector('input[name="daReason"]:checked');
    if(!selected){
        msg.textContent='<%: T("Please select a reason.","Sila pilih alasan.") %>';
        msg.style.display='block';return;
    }
    if(selected.value==='other'){
        var otherText=document.getElementById('daOtherText').value.trim();
        if(!otherText){
            msg.textContent='<%: T("Please enter your reason.","Sila masukkan alasan anda.") %>';
            msg.style.display='block';return;
        }
    }
    // Validation passed — call server to set status to Deleted
    msg.style.display='none';
    var xhr=new XMLHttpRequest();
    xhr.open('POST','MyProfile.aspx?handler=deleteaccount',true);
    xhr.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
    xhr.onreadystatechange=function(){
        if(xhr.readyState===4){
            if(xhr.status===200){
                closeDeleteAccountModal();
                window.location.href='<%: ResolveUrl("~/Login.aspx") %>';
            }else{
                msg.textContent=xhr.responseText||'<%: T("Error deleting account.","Ralat memadam akaun.") %>';
                msg.style.display='block';
            }
        }
    };
    xhr.send('reason='+encodeURIComponent(selected.value)+(selected.value==='other'?'&detail='+encodeURIComponent(document.getElementById('daOtherText').value.trim()):''));
}
function showMpToast(msg){var c=document.getElementById('mpToast'),t=document.createElement('div');t.className='mp-toast';t.innerHTML='<i class="bi bi-check-circle-fill"></i> '+msg;c.appendChild(t);setTimeout(function(){t.classList.add('mp-toast-out');},3e3);setTimeout(function(){t.remove();},3500);}
var bio=document.querySelector('[id$="txtBio"]');
if(bio){bio.addEventListener('input',function(){document.getElementById('bioCounter').textContent=this.value.length+' / 500';});}
// Certificate modal
function openCertModal(e){
    e.preventDefault();
    var link=e.currentTarget;
    var url=link.getAttribute('href');
    var body=document.getElementById('certModalBody');
    var ext=(url.split('.').pop()||'').toLowerCase().split('?')[0];
    if(ext==='pdf'){body.innerHTML='<iframe src="'+url+'" style="width:100%;height:560px;border:none;"></iframe>';}
    else if(['png','jpg','jpeg','gif','webp'].indexOf(ext)>-1){body.innerHTML='<img src="'+url+'" style="width:100%;height:auto;min-height:auto;padding:1.5rem;" alt="Certificate"/>';}
    else{body.innerHTML='<div style="text-align:center;padding:3rem;"><p style="font-size:.94rem;color:#6B7280;margin-bottom:1rem;"><%: T("Cannot preview this file type.","Tidak dapat pratonton jenis fail ini.") %></p><a href="'+url+'" target="_blank" style="color:#6C63FF;font-weight:700;text-decoration:none;"><%: T("Download File","Muat Turun Fail") %> <i class="bi bi-download"></i></a></div>';}
    document.getElementById('certModal').classList.add('active');
}
function closeCertModal(){document.getElementById('certModal').classList.remove('active');}
document.addEventListener('keydown',function(e){if(e.key==='Escape')closeCertModal();});
// Client-side validation highlighting
function validateProfile(){
    var valid=true;
    var nameEl=document.querySelector('[id$="txtName"]');
    var phoneEl=document.querySelector('[id$="txtPhone"]');
    var valName=document.getElementById('valName');
    var valPhone=document.getElementById('valPhone');
    nameEl.classList.remove('invalid');phoneEl.classList.remove('invalid');
    valName.classList.remove('show');valName.textContent='';
    valPhone.classList.remove('show');valPhone.textContent='';
    if(!nameEl.value.trim()){nameEl.classList.add('invalid');valName.textContent='<%: T("Full Name is required.","Nama Penuh diperlukan.") %>';valName.classList.add('show');valid=false;}
    if(!phoneEl.value.trim()){phoneEl.classList.add('invalid');valPhone.textContent='<%: T("Phone Number is required.","Nombor Telefon diperlukan.") %>';valPhone.classList.add('show');valid=false;}
    else if(!/^\d+$/.test(phoneEl.value.trim())){phoneEl.classList.add('invalid');valPhone.textContent='<%: T("Phone Number must contain digits only.","Nombor Telefon mesti mengandungi digit sahaja.") %>';valPhone.classList.add('show');valid=false;}
    if(!valid){var first=document.querySelector('.mp-input.invalid');if(first)first.focus();}
    return valid;
}
document.addEventListener('input',function(e){
    if(e.target.id&&e.target.id.indexOf('txtName')>-1){e.target.classList.remove('invalid');document.getElementById('valName').classList.remove('show');}
    if(e.target.id&&e.target.id.indexOf('txtPhone')>-1){e.target.classList.remove('invalid');document.getElementById('valPhone').classList.remove('show');}
});
window.addEventListener('load',function(){
    var h=document.getElementById('<%=hidToast.ClientID%>');
    if(h&&h.value){var c=document.getElementById('mpToast'),t=document.createElement('div');t.className='mp-toast';t.innerHTML='<i class="bi bi-check-circle-fill"></i> '+h.value;c.appendChild(t);setTimeout(function(){t.classList.add('mp-toast-out');},3e3);setTimeout(function(){t.remove();},3500);h.value='';}
    if(bio)document.getElementById('bioCounter').textContent=bio.value.length+' / 500';
    var saveBtn=document.querySelector('[id$="btnSave"]');
    if(saveBtn){saveBtn.addEventListener('click',function(e){if(!validateProfile())e.preventDefault();});}
});
</script>
</asp:Content>
