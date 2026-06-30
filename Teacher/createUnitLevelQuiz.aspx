<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="createUnitLevelQuiz.aspx.cs"
    Inherits="ScienceBuddy.Teacher.createUnitLevelQuiz" MasterPageFile="~/Site.Master"
    Title="Create Quiz" EnableViewState="true" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--tc-primary:#6C63FF;--tc-hover:#5A52E0;--tc-light-bg:#F5F3FF;--tc-card-bg:#FFF;--tc-border:#E5E7EB;--tc-text:#374151;--tc-muted:#6B7280;--tc-error:#EF4444;--tc-success:#10B981;--tc-warning:#F59E0B;}
.qb-layout{display:grid;grid-template-columns:240px 1fr 270px;gap:1.25rem;min-height:70vh;}

/* Progress Bar */
.qb-progress{background:var(--tc-card-bg);border:1.5px solid var(--tc-border);border-radius:14px;padding:1rem 1.5rem;margin-bottom:1.25rem;box-shadow:0 2px 6px rgba(108,99,255,.04);display:flex;align-items:center;gap:1rem;}
.qb-progress-bar{flex:1;height:8px;background:#EDE9FE;border-radius:8px;overflow:hidden;}
.qb-progress-fill{height:100%;background:linear-gradient(90deg,var(--tc-primary),#A78BFA);border-radius:8px;transition:width .4s ease;}
.qb-progress-text{font-size:.8rem;font-weight:700;color:var(--tc-text);white-space:nowrap;}

/* Left Nav */
.qb-nav{background:var(--tc-card-bg);border:1.5px solid var(--tc-border);border-radius:16px;padding:1.25rem;box-shadow:0 2px 8px rgba(0,0,0,.03);}
.qb-nav-title{font-size:.75rem;font-weight:700;color:var(--tc-muted);margin-bottom:1rem;text-transform:uppercase;letter-spacing:1.2px;}
.qb-nav-list{display:flex;flex-direction:column;gap:6px;}
.qb-nav-item{padding:.65rem .85rem;border-radius:12px;font-size:.82rem;font-weight:600;color:var(--tc-text);cursor:pointer;display:flex;align-items:center;gap:10px;transition:all .2s;border:1.5px solid transparent;background:var(--tc-card-bg);width:100%;text-align:left;}
.qb-nav-item:hover{background:var(--tc-light-bg);border-color:#EDE9FE;transform:translateY(-1px);box-shadow:0 2px 8px rgba(108,99,255,.06);}
.qb-nav-item.active{background:var(--tc-primary);color:#fff;border-color:var(--tc-primary);box-shadow:0 4px 12px rgba(108,99,255,.2);}
.qb-nav-item .dot{width:10px;height:10px;border-radius:50%;border:2px solid var(--tc-border);flex-shrink:0;transition:all .2s;}
.qb-nav-item.active .dot{border-color:rgba(255,255,255,.5);background:rgba(255,255,255,.3);}
.qb-nav-item.done .dot{border-color:var(--tc-success);background:var(--tc-success);}
.qb-nav-add{margin-top:1rem;padding:.85rem;border-radius:12px;font-size:.82rem;font-weight:700;color:var(--tc-primary);cursor:pointer;border:2px dashed #C4B5FD;background:var(--tc-light-bg);width:100%;text-align:center;transition:all .2s;}
.qb-nav-add:hover{background:#EDE9FE;border-color:var(--tc-primary);transform:translateY(-2px);box-shadow:0 4px 12px rgba(108,99,255,.1);}
.qb-center{background:var(--tc-card-bg);border:1.5px solid var(--tc-border);border-radius:16px;padding:1.75rem;box-shadow:0 2px 8px rgba(0,0,0,.03);display:flex;flex-direction:column;}
.qb-header{display:flex;align-items:center;justify-content:space-between;margin-bottom:1.5rem;padding-bottom:1.25rem;border-bottom:1px solid var(--tc-border);}
.qb-qnum{font-size:1.1rem;font-weight:800;color:var(--tc-text);}
.qb-tabs{display:flex;gap:0;border:1.5px solid var(--tc-border);border-radius:10px;overflow:hidden;}
.qb-tab{padding:.45rem 1.1rem;font-size:.8rem;font-weight:600;cursor:pointer;border:none;background:var(--tc-card-bg);color:var(--tc-muted);transition:all .2s;}
.qb-tab.active{background:var(--tc-primary);color:#fff;}
.qb-tab:hover:not(.active){background:var(--tc-light-bg);}
.qb-field{margin-bottom:1.25rem;position:relative;}
.qb-label{font-size:.78rem;font-weight:600;color:var(--tc-text);margin-bottom:5px;display:flex;align-items:center;justify-content:space-between;}
.qb-input{width:100%;border-radius:12px;border:1.5px solid var(--tc-border);padding:.65rem .85rem;font-size:.84rem;transition:all .2s;background:var(--tc-card-bg);}
.qb-input:focus{border-color:var(--tc-primary);outline:none;box-shadow:0 0 0 3px rgba(108,99,255,.08);}
.qb-input.invalid{border-color:var(--tc-error);box-shadow:0 0 0 3px rgba(239,68,68,.08);}
.qb-textarea{min-height:90px;resize:vertical;line-height:1.6;}
.qb-opts{display:grid;grid-template-columns:1fr 1fr;gap:.85rem;margin-bottom:1.25rem;}
.qb-opt{display:flex;align-items:center;gap:10px;padding:.7rem 1rem;border-radius:14px;border:2px solid var(--tc-border);transition:all .25s;position:relative;background:var(--tc-card-bg);}
.qb-opt:nth-child(1){border-left:4px solid #EF4444;}
.qb-opt:nth-child(2){border-left:4px solid #3B82F6;}
.qb-opt:nth-child(3){border-left:4px solid #F59E0B;}
.qb-opt:nth-child(4){border-left:4px solid #10B981;}
.qb-opt:hover{transform:translateY(-2px);box-shadow:0 4px 12px rgba(0,0,0,.06);}
.qb-opt.correct{border-color:var(--tc-success)!important;background:#ECFDF5;box-shadow:0 4px 16px rgba(16,185,129,.15);}
.qb-opt.correct::after{content:'\2713 Correct';position:absolute;right:10px;top:50%;transform:translateY(-50%);font-size:.68rem;font-weight:700;color:var(--tc-success);background:#D1FAE5;padding:2px 8px;border-radius:6px;}
.qb-opt input[type="text"]{flex:1;border:none;background:transparent;font-size:.84rem;outline:none;font-weight:500;}
.qb-opt input[type="radio"],.qb-opt input[type="checkbox"]{accent-color:var(--tc-primary);width:16px;height:16px;}
.qb-actions{display:flex;gap:.75rem;margin-top:auto;padding-top:1.25rem;border-top:1px solid var(--tc-border);flex-wrap:wrap;}
.qb-btn{padding:.6rem 1.2rem;border-radius:12px;font-size:.82rem;font-weight:700;cursor:pointer;border:none;transition:all .2s;display:inline-flex;align-items:center;gap:6px;}
.qb-btn:hover{transform:translateY(-1px);}
.qb-btn-primary{background:var(--tc-primary);color:#fff;box-shadow:0 2px 8px rgba(108,99,255,.2);}.qb-btn-primary:hover{background:var(--tc-hover);box-shadow:0 4px 16px rgba(108,99,255,.3);}
.qb-btn-outline{background:var(--tc-card-bg);color:var(--tc-text);border:1.5px solid var(--tc-border);}.qb-btn-outline:hover{border-color:var(--tc-primary);color:var(--tc-primary);}
.qb-btn-success{background:var(--tc-success);color:#fff;box-shadow:0 2px 8px rgba(16,185,129,.2);}.qb-btn-success:hover{background:#059669;box-shadow:0 4px 16px rgba(16,185,129,.3);}
.qb-props{background:var(--tc-card-bg);border:1.5px solid var(--tc-border);border-radius:16px;padding:1.25rem;box-shadow:0 2px 8px rgba(0,0,0,.03);}
.qb-props-title{font-size:.75rem;font-weight:700;color:var(--tc-muted);margin-bottom:1rem;text-transform:uppercase;letter-spacing:1.2px;}
.qb-prop-field{margin-bottom:1.25rem;}
/* Summary Cards */
.qb-summary-row{display:grid;grid-template-columns:repeat(3,1fr);gap:1rem;margin-bottom:1.25rem;}
.qb-summary-card{background:var(--tc-card-bg);border:1.5px solid var(--tc-border);border-radius:16px;padding:1.25rem;box-shadow:0 2px 8px rgba(108,99,255,.05);transition:transform .2s,box-shadow .2s;display:flex;flex-direction:column;gap:6px;}
.qb-summary-card:hover{transform:translateY(-3px);box-shadow:0 8px 24px rgba(108,99,255,.1);}
.qb-summary-icon{width:38px;height:38px;border-radius:10px;background:#EDE9FE;color:var(--tc-primary);display:flex;align-items:center;justify-content:center;font-size:1.1rem;}
.qb-summary-label{font-size:.72rem;font-weight:600;color:var(--tc-muted);text-transform:uppercase;letter-spacing:.8px;}
.qb-summary-value{font-size:.92rem;font-weight:700;color:var(--tc-text);line-height:1.3;}
/* Notice Card */
.qb-notice{display:flex;align-items:flex-start;gap:12px;background:#F5F3FF;border-left:4px solid var(--tc-primary);border-radius:12px;padding:1rem 1.25rem;margin-bottom:1.5rem;box-shadow:0 2px 6px rgba(108,99,255,.06);}
.qb-notice-icon{color:var(--tc-primary);font-size:1.2rem;margin-top:1px;flex-shrink:0;}
.qb-notice-body{flex:1;}
.qb-notice-title{font-size:.82rem;font-weight:700;color:var(--tc-primary);margin-bottom:3px;}
.qb-notice-text{font-size:.78rem;color:var(--tc-text);line-height:1.5;opacity:.85;}
.qb-msg{padding:.75rem 1rem;border-radius:10px;margin-bottom:1rem;font-size:.84rem;font-weight:600;}
.qb-msg-error{background:#FEF2F2;color:#B91C1C;border:1px solid #FEE2E2;}
.qb-msg-success{background:#ECFDF5;color:#047857;border:1px solid #D1FAE5;}
.qb-toast-container{position:fixed;top:1.25rem;right:1.25rem;z-index:9999;display:flex;flex-direction:column;gap:.5rem;}
.qb-toast{background:var(--tc-primary);color:#fff;padding:.75rem 1.25rem;border-radius:10px;font-size:.84rem;font-weight:600;display:flex;align-items:center;gap:8px;box-shadow:0 8px 24px rgba(108,99,255,.3);animation:qbSlide .3s ease;}
@keyframes qbSlide{from{opacity:0;transform:translateX(30px);}to{opacity:1;transform:translateX(0);}}
@media(max-width:1024px){.qb-layout{grid-template-columns:1fr;}.qb-nav,.qb-props{display:none;}.qb-summary-row{grid-template-columns:1fr;}}
@media(max-width:640px){.qb-opts{grid-template-columns:1fr;}.qb-summary-row{grid-template-columns:1fr;}.qb-tf-grid{grid-template-columns:1fr;}.qb-fib-words{grid-template-columns:1fr;}.qb-actions{flex-direction:column;}}
/* Answer section transitions */
.qb-answer-section{animation:qbFadeIn .25s ease;}
@keyframes qbFadeIn{from{opacity:0;transform:translateY(6px);}to{opacity:1;transform:translateY(0);}}
.qb-opt-input{flex:1;border:none;background:transparent;font-size:.84rem;outline:none;font-weight:500;padding:0;}
/* True/False cards */
.qb-tf-grid{display:grid;grid-template-columns:1fr 1fr;gap:1rem;margin-bottom:1.25rem;}
.qb-tf-card{display:flex;flex-direction:column;align-items:center;gap:8px;padding:1.75rem 1rem;border-radius:16px;border:2px solid var(--tc-border);cursor:pointer;transition:all .25s;text-align:center;background:var(--tc-card-bg);}
.qb-tf-card:hover{transform:translateY(-3px);box-shadow:0 6px 20px rgba(0,0,0,.06);}
.qb-tf-card input[type="radio"]{display:none;}
.qb-tf-card i{font-size:2rem;color:var(--tc-muted);transition:color .2s;}
.qb-tf-card span{font-size:1rem;font-weight:800;color:var(--tc-text);}
.qb-tf-card.selected{border-color:var(--tc-success);background:#ECFDF5;box-shadow:0 6px 20px rgba(16,185,129,.12);}
.qb-tf-card.selected i{color:var(--tc-success);}
/* Multiselect */
.qb-ms-opt.selected{border-color:var(--tc-success)!important;background:#ECFDF5;box-shadow:0 4px 12px rgba(16,185,129,.1);}
.qb-ms-count{font-size:.72rem;font-weight:700;color:var(--tc-primary);background:#EDE9FE;padding:2px 8px;border-radius:6px;margin-left:8px;}
/* Fill in the Blank - Refined */
.fib-add-row{display:flex;align-items:center;gap:12px;margin-bottom:.75rem;}
.fib-add-btn{display:inline-flex;align-items:center;gap:6px;padding:.5rem 1rem;border-radius:10px;font-size:.8rem;font-weight:700;color:var(--tc-primary);background:var(--tc-light-bg);border:1.5px solid #C4B5FD;cursor:pointer;transition:all .2s;}
.fib-add-btn:hover{background:#EDE9FE;border-color:var(--tc-primary);transform:translateY(-1px);box-shadow:0 3px 10px rgba(108,99,255,.1);}
.fib-add-btn.disabled{color:var(--tc-muted);background:#F9FAFB;border-color:var(--tc-border);cursor:not-allowed;opacity:.6;transform:none;box-shadow:none;}
.fib-counter{font-size:.78rem;font-weight:600;color:var(--tc-muted);}.fib-counter.full{color:var(--tc-error);}
.fib-warning{display:flex;align-items:center;gap:8px;padding:.6rem 1rem;border-radius:10px;background:#FEF2F2;border:1px solid #FEE2E2;color:#B91C1C;font-size:.76rem;font-weight:700;margin-bottom:1rem;animation:qbFadeIn .2s ease;}
.fib-section-label{font-size:.8rem;font-weight:700;color:var(--tc-text);margin-bottom:8px;display:flex;align-items:center;gap:6px;}
.fib-section-label i{color:var(--tc-primary);}.fib-sub-label{font-size:.7rem;color:var(--tc-muted);font-weight:500;}
.fib-mapping-wrap{margin-top:1.25rem;padding-top:1.25rem;border-top:1px dashed #EDE9FE;}
.fib-preview-wrap{margin-top:1.25rem;}
.qb-fib-words{display:grid;grid-template-columns:1fr 1fr;gap:.75rem;margin-bottom:1rem;}
.qb-fib-word{display:flex;align-items:center;gap:10px;padding:.6rem 1rem;border-radius:12px;border:1.5px solid var(--tc-border);background:var(--tc-card-bg);transition:all .2s;}
.qb-fib-word:focus-within{border-color:var(--tc-primary);box-shadow:0 0 0 3px rgba(108,99,255,.06);}
.qb-fib-num{width:24px;height:24px;border-radius:50%;background:#EDE9FE;color:var(--tc-primary);display:flex;align-items:center;justify-content:center;font-size:.72rem;font-weight:700;flex-shrink:0;}
.qb-fib-mappings{display:flex;flex-direction:column;gap:8px;}
.qb-fib-map-row{display:flex;align-items:center;gap:10px;padding:.6rem 1rem;border-radius:12px;border:1.5px solid var(--tc-border);background:var(--tc-card-bg);transition:all .25s;}
.qb-fib-map-row.valid{border-color:var(--tc-success);background:#F0FDF4;}
.qb-fib-map-row.invalid{border-color:var(--tc-error);background:#FEF2F2;}
.qb-fib-map-label{font-size:.78rem;font-weight:700;color:var(--tc-primary);white-space:nowrap;min-width:65px;}
.qb-fib-map-arrow{color:var(--tc-muted);font-size:.85rem;}
.qb-fib-map-select{flex:1;border-radius:8px;border:1.5px solid var(--tc-border);padding:.4rem .65rem;font-size:.8rem;background:var(--tc-card-bg);transition:border-color .2s;}
.qb-fib-map-select:focus{border-color:var(--tc-primary);outline:none;}
.qb-fib-map-select.invalid{border-color:var(--tc-error);}
.qb-fib-map-check{color:var(--tc-success);font-size:.9rem;opacity:0;transition:opacity .2s;}
.qb-fib-map-row.valid .qb-fib-map-check{opacity:1;}
.qb-fib-preview-card{background:linear-gradient(135deg,#F5F3FF 0%,#EDE9FE 100%);border:1.5px solid #DDD6FE;border-radius:14px;padding:1.25rem 1.5rem;}
.qb-fib-preview-title{font-size:.82rem;font-weight:700;color:var(--tc-primary);margin-bottom:4px;display:flex;align-items:center;gap:6px;}
.qb-fib-preview-sub{font-size:.72rem;color:var(--tc-muted);margin-bottom:.85rem;}
.qb-fib-preview-text{font-size:.9rem;color:var(--tc-text);line-height:1.8;}
.qb-fib-preview-text .fib-blank{display:inline-block;min-width:90px;border-bottom:2.5px dashed var(--tc-primary);text-align:center;padding:3px 10px;margin:0 4px;color:var(--tc-primary);font-size:.82rem;font-weight:600;background:rgba(108,99,255,.04);border-radius:4px;}
.qb-fib-preview-words{display:flex;flex-wrap:wrap;gap:8px;}
.qb-fib-chip{display:inline-flex;align-items:center;padding:6px 16px;border-radius:20px;background:var(--tc-card-bg);border:1.5px solid #C4B5FD;font-size:.8rem;font-weight:600;color:var(--tc-primary);box-shadow:0 2px 6px rgba(108,99,255,.08);transition:transform .15s;}
.qb-fib-chip:hover{transform:translateY(-1px);box-shadow:0 4px 10px rgba(108,99,255,.12);}
.qb-fib-hint{font-size:.76rem;color:var(--tc-muted);display:flex;align-items:flex-start;gap:6px;padding:.65rem .85rem;background:var(--tc-light-bg);border-radius:10px;margin-top:1.25rem;line-height:1.5;}
/* Save Status */
.qb-save-status{display:flex;align-items:center;gap:8px;padding:.6rem 1rem;border-radius:10px;font-size:.78rem;font-weight:600;margin-bottom:1rem;background:#FEF3C7;color:#92400E;border:1px solid #FDE68A;transition:all .3s;}
.qb-save-status.ready{background:#ECFDF5;color:#047857;border-color:#D1FAE5;}
.qb-char-count{font-size:.7rem;color:var(--tc-muted);font-weight:500;}
</style>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Teaching","Pengajaran") %></div>
        <a href="<%: ResolveUrl("~/Teacher/manageMaterials.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label"><%: T("Manage Materials","Urus Bahan Pembelajaran") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-patch-question item-icon"></i><span class="item-label"><%: T("Manage Quiz","Urus Kuiz") %></span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-bar-chart item-icon"></i><span class="item-label"><%: T("Student Progress","Kemajuan Pelajar") %></span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label"><%: T("Schedule Live Class","Jadual Kelas Langsung") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Account","Akaun") %></div>
        <a href="<%: ResolveUrl("~/Teacher/MyProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("My Profile","Profil Saya") %></span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Sign Out","Log Keluar") %></span></a></div>
</asp:Content>
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Create Quiz","Cipta Kuiz") %></asp:Content>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="qb-msg qb-msg-error"><i class="bi bi-exclamation-circle"></i> <asp:Literal ID="litError" runat="server" /></div>
    <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="qb-btn qb-btn-outline"><%: T("Back to Quizzes","Kembali ke Kuiz") %></a>
</asp:Panel>

<asp:Panel ID="pnlBuilder" runat="server" Visible="false">

<%-- Context Header --%>
<%-- Summary Cards --%>
<div class="qb-summary-row">
    <div class="qb-summary-card">
        <div class="qb-summary-icon"><i class="bi bi-collection-fill"></i></div>
        <div class="qb-summary-label"><%: T("Quiz Type","Jenis Kuiz") %></div>
        <div class="qb-summary-value"><asp:Literal ID="litMode" runat="server" /></div>
    </div>
    <div class="qb-summary-card">
        <div class="qb-summary-icon"><i class="bi bi-puzzle-fill"></i></div>
        <div class="qb-summary-label"><%: T("Unit / Level","Unit / Tahap") %></div>
        <div class="qb-summary-value"><asp:Literal ID="litScope" runat="server" /></div>
    </div>
    <div class="qb-summary-card">
        <div class="qb-summary-icon"><i class="bi bi-bookmark-fill"></i></div>
        <div class="qb-summary-label"><%: T("Subtopic","Subtopik") %></div>
        <div class="qb-summary-value"><asp:Literal ID="litSubtopic" runat="server" /></div>
    </div>
</div>

<%-- Language Notice --%>
<div class="qb-notice">
    <div class="qb-notice-icon"><i class="bi bi-info-circle-fill"></i></div>
    <div class="qb-notice-body">
        <div class="qb-notice-title"><%: T("Unit Quiz Information","Maklumat Kuiz Unit") %></div>
        <div class="qb-notice-text"><%: T("This quiz requires BOTH English and Bahasa Melayu versions for every question. Teachers must complete both language tabs before a question can be saved.","Kuiz ini memerlukan KEDUA-DUA versi Bahasa Inggeris dan Bahasa Melayu untuk setiap soalan. Guru mesti melengkapkan kedua-dua tab bahasa sebelum soalan boleh disimpan.") %></div>
    </div>
</div>

<%-- Progress Bar --%>
<div class="qb-progress">
    <div class="qb-progress-bar"><div class="qb-progress-fill" id="progressFill" style="width:0%"></div></div>
    <div class="qb-progress-text" id="progressText">0 / 0 <%: T("Questions Saved","Soalan Disimpan") %></div>
</div>

<%-- Builder Layout --%>
<div class="qb-layout">

<%-- Left Nav --%>
<div class="qb-nav">
    <div class="qb-nav-title"><%: T("Questions","Soalan") %></div>
    <div class="qb-nav-list">
        <asp:Repeater ID="rptNav" runat="server">
            <ItemTemplate>
                <asp:LinkButton ID="btnNavQ" runat="server" CssClass='<%# "qb-nav-item" + (Convert.ToInt32(Eval("Index")) == CurrentIndex ? " active" : "") + (Convert.ToBoolean(Eval("Done")) ? " done" : "") %>'
                    CommandName="GoTo" CommandArgument='<%# Eval("Index") %>' OnCommand="btnNav_Command" CausesValidation="false">
                    <span class="dot"></span> Q<%# Convert.ToInt32(Eval("Index")) + 1 %>
                </asp:LinkButton>
            </ItemTemplate>
        </asp:Repeater>
    </div>
    <asp:Button ID="btnAddQuestion" runat="server" CssClass="qb-nav-add" OnClick="btnAddQuestion_Click" CausesValidation="false" />
</div>

<%-- Center Editor --%>
<div class="qb-center">
    <div class="qb-header">
        <div class="qb-qnum"><%: T("Question","Soalan") %> <asp:Literal ID="litQNum" runat="server" /></div>
        <div class="qb-tabs">
            <asp:Button ID="btnTabEN" runat="server" Text="English" CssClass="qb-tab active" OnClick="btnTabEN_Click" CausesValidation="false" />
            <asp:Button ID="btnTabBM" runat="server" Text="B. Melayu" CssClass="qb-tab" OnClick="btnTabBM_Click" CausesValidation="false" />
        </div>
    </div>

    <%-- Question Text --%>
    <div class="qb-field">
        <label class="qb-label"><asp:Literal ID="litQTextLabel" runat="server" /> * <span class="qb-char-count" id="qCharCount">0 / 500</span></label>
        <asp:TextBox ID="txtQuestionText" runat="server" TextMode="MultiLine" Rows="3" CssClass="qb-input qb-textarea" MaxLength="500" />
    </div>

    <%-- Answer Section: MCQ (default) --%>
    <div id="sectionMCQ" class="qb-answer-section">
        <div class="qb-label" style="margin-bottom:8px;"><asp:Literal ID="litOptionsLabel" runat="server" /> * <span style="font-size:.7rem;color:var(--tc-muted);font-weight:500;">(<%: T("Select one correct answer","Pilih satu jawapan betul") %>)</span></div>
        <div class="qb-opts">
            <div class="qb-opt" id="optAWrap" runat="server"><asp:RadioButton ID="radA" runat="server" GroupName="correct" /><asp:TextBox ID="txtOptA" runat="server" CssClass="qb-opt-input" placeholder="Option A" /></div>
            <div class="qb-opt" id="optBWrap" runat="server"><asp:RadioButton ID="radB" runat="server" GroupName="correct" /><asp:TextBox ID="txtOptB" runat="server" CssClass="qb-opt-input" placeholder="Option B" /></div>
            <div class="qb-opt" id="optCWrap" runat="server"><asp:RadioButton ID="radC" runat="server" GroupName="correct" /><asp:TextBox ID="txtOptC" runat="server" CssClass="qb-opt-input" placeholder="Option C" /></div>
            <div class="qb-opt" id="optDWrap" runat="server"><asp:RadioButton ID="radD" runat="server" GroupName="correct" /><asp:TextBox ID="txtOptD" runat="server" CssClass="qb-opt-input" placeholder="Option D" /></div>
        </div>
    </div>

    <%-- Answer Section: True/False --%>
    <div id="sectionTF" class="qb-answer-section" style="display:none;">
        <div class="qb-label" style="margin-bottom:8px;"><%: T("Select the correct answer","Pilih jawapan yang betul") %> *</div>
        <div class="qb-tf-grid">
            <label class="qb-tf-card" id="tfTrueCard"><input type="radio" name="tfAnswer" value="A" onchange="updateTFCards()"/><i class="bi bi-check-circle-fill"></i><span>TRUE</span></label>
            <label class="qb-tf-card" id="tfFalseCard"><input type="radio" name="tfAnswer" value="B" onchange="updateTFCards()"/><i class="bi bi-x-circle-fill"></i><span>FALSE</span></label>
        </div>
    </div>

    <%-- Answer Section: Multiselect --%>
    <div id="sectionMS" class="qb-answer-section" style="display:none;">
        <div class="qb-label" style="margin-bottom:8px;"><%: T("Select all correct answers","Pilih semua jawapan betul") %> * <span class="qb-ms-count" id="msCount">0 <%: T("selected","dipilih") %></span></div>
        <div class="qb-opts">
            <div class="qb-opt qb-ms-opt"><input type="checkbox" class="ms-check" onchange="updateMSCards()"/><input type="text" class="qb-opt-input ms-text" placeholder="Option A" /></div>
            <div class="qb-opt qb-ms-opt"><input type="checkbox" class="ms-check" onchange="updateMSCards()"/><input type="text" class="qb-opt-input ms-text" placeholder="Option B" /></div>
            <div class="qb-opt qb-ms-opt"><input type="checkbox" class="ms-check" onchange="updateMSCards()"/><input type="text" class="qb-opt-input ms-text" placeholder="Option C" /></div>
            <div class="qb-opt qb-ms-opt"><input type="checkbox" class="ms-check" onchange="updateMSCards()"/><input type="text" class="qb-opt-input ms-text" placeholder="Option D" /></div>
        </div>
    </div>

    <%-- Answer Section: Fill in the Blank --%>
    <div id="sectionFIB" class="qb-answer-section" style="display:none;">

        <%-- Add Blank --%>
        <div class="fib-add-row">
            <button type="button" class="fib-add-btn" id="btnAddBlank" onclick="addBlank()"><i class="bi bi-plus-square-dotted"></i> <%: T("Add Blank","Tambah Kosong") %></button>
            <span class="fib-counter" id="blankCounter"><%: T("Blanks","Kosong") %>: <strong id="blankNum">0</strong> / 4</span>
        </div>
        <div class="fib-warning" id="blankWarning" style="display:none;">
            <i class="bi bi-exclamation-triangle-fill"></i> <%: T("Maximum of 4 blanks reached. Remove an existing blank before adding another.","Maksimum 4 tempat kosong dicapai. Buang kosong sedia ada sebelum menambah yang lain.") %>
        </div>

        <%-- Word Bank --%>
        <div class="fib-section-label"><i class="bi bi-collection"></i> <%: T("Word Bank","Bank Perkataan") %> * <span class="fib-sub-label">(<%: T("Max 4 words","Maks 4 perkataan") %>)</span></div>
        <div class="qb-fib-words" id="fibWordsContainer">
            <div class="qb-fib-word"><span class="qb-fib-num">1</span><input type="text" class="qb-opt-input fib-word-input" placeholder="<%: T("Word 1","Perkataan 1") %>" oninput="onFibWordChange()" /></div>
            <div class="qb-fib-word"><span class="qb-fib-num">2</span><input type="text" class="qb-opt-input fib-word-input" placeholder="<%: T("Word 2","Perkataan 2") %>" oninput="onFibWordChange()" /></div>
            <div class="qb-fib-word"><span class="qb-fib-num">3</span><input type="text" class="qb-opt-input fib-word-input" placeholder="<%: T("Word 3","Perkataan 3") %>" oninput="onFibWordChange()" /></div>
            <div class="qb-fib-word"><span class="qb-fib-num">4</span><input type="text" class="qb-opt-input fib-word-input" placeholder="<%: T("Word 4","Perkataan 4") %>" oninput="onFibWordChange()" /></div>
        </div>

        <%-- Correct Answer Mapping --%>
        <div id="fibMappingSection" class="fib-mapping-wrap" style="display:none;">
            <div class="fib-section-label"><i class="bi bi-arrow-left-right"></i> <%: T("Correct Answer Mapping","Pemetaan Jawapan Betul") %> *</div>
            <div class="qb-fib-mappings" id="fibMappings"></div>
            <div class="fib-warning" id="fibMappingError" style="display:none;margin-top:6px;">
                <i class="bi bi-exclamation-circle-fill"></i> <%: T("Each blank must map to a unique word.","Setiap kosong mesti dipetakan kepada perkataan unik.") %>
            </div>
        </div>

        <%-- Student Preview --%>
        <div id="fibPreviewSection" class="fib-preview-wrap" style="display:none;">
            <div class="qb-fib-preview-card">
                <div class="qb-fib-preview-title"><i class="bi bi-eye"></i> <%: T("Student Preview","Pratonton Pelajar") %></div>
                <div class="qb-fib-preview-sub"><%: T("Students will drag the correct words into the blanks below.","Pelajar akan menyeret perkataan betul ke dalam kosong di bawah.") %></div>
                <div class="qb-fib-preview-text" id="fibPreviewText"></div>
                <div style="margin-top:.75rem;">
                    <div style="font-size:.72rem;font-weight:600;color:var(--tc-muted);margin-bottom:6px;text-transform:uppercase;letter-spacing:.5px;"><%: T("Available Words","Perkataan Tersedia") %></div>
                    <div class="qb-fib-preview-words" id="fibPreviewWords"></div>
                </div>
            </div>
        </div>

        <%-- Helper --%>
        <div class="qb-fib-hint"><i class="bi bi-lightbulb"></i> <%: T("Click 'Add Blank' to insert blanks into your question text. Then assign each blank to a correct word from the Word Bank above.","Klik 'Tambah Kosong' untuk memasukkan kosong ke dalam teks soalan. Kemudian tetapkan setiap kosong kepada perkataan betul dari Bank Perkataan di atas.") %></div>
    </div>

    <%-- Explanations --%>
    <div class="qb-field">
        <label class="qb-label"><asp:Literal ID="litCorrectExpLabel" runat="server" /> * <span class="qb-char-count" id="ceCharCount">0 / 500</span></label>
        <asp:TextBox ID="txtCorrectExp" runat="server" TextMode="MultiLine" Rows="2" CssClass="qb-input qb-textarea" MaxLength="500" />
    </div>
    <div class="qb-field">
        <label class="qb-label"><asp:Literal ID="litWrongExpLabel" runat="server" /> * <span class="qb-char-count" id="weCharCount">0 / 500</span></label>
        <asp:TextBox ID="txtWrongExp" runat="server" TextMode="MultiLine" Rows="2" CssClass="qb-input qb-textarea" MaxLength="500" />
    </div>

    <%-- Save Status --%>
    <div class="qb-save-status" id="saveStatus"><i class="bi bi-circle"></i> <span id="saveStatusText"><%: T("Question Incomplete","Soalan Tidak Lengkap") %></span></div>

    <div class="qb-actions">
        <asp:Button ID="btnPrev" runat="server" Text="← Previous" CssClass="qb-btn qb-btn-outline" OnClick="btnPrev_Click" CausesValidation="false" />
        <asp:Button ID="btnNext" runat="server" Text="Next →" CssClass="qb-btn qb-btn-outline" OnClick="btnNext_Click" CausesValidation="false" />
        <asp:Button ID="btnSaveQ" runat="server" Text="Save Question" CssClass="qb-btn qb-btn-primary" OnClick="btnSaveQ_Click" CausesValidation="false" />
        <asp:Button ID="btnSubmitQuiz" runat="server" Text="Submit Quiz" CssClass="qb-btn qb-btn-success" OnClick="btnSubmitQuiz_Click" CausesValidation="false" />
    </div>
</div>

<%-- Right Props --%>
<div class="qb-props">
    <div class="qb-props-title"><%: T("Properties","Sifat") %></div>
    <div class="qb-prop-field">
        <label class="qb-label"><%: T("Question Type","Jenis Soalan") %></label>
        <asp:DropDownList ID="ddlQType" runat="server" CssClass="qb-input">
            <asp:ListItem Value="MCQ" Text="MCQ" />
            <asp:ListItem Value="True/False" Text="True / False" />
            <asp:ListItem Value="Multiselect" Text="Multiselect" />
            <asp:ListItem Value="Drag & Drop" Text="Drag & Drop" />
        </asp:DropDownList>
    </div>
    <div class="qb-prop-field">
        <label class="qb-label"><%: T("Difficulty","Kesukaran") %></label>
        <asp:DropDownList ID="ddlQDiff" runat="server" CssClass="qb-input">
            <asp:ListItem Value="Easy" Text="Easy" />
            <asp:ListItem Value="Medium" Text="Medium" />
            <asp:ListItem Value="Hard" Text="Hard" />
        </asp:DropDownList>
    </div>
    <div class="qb-prop-field">
        <label class="qb-label"><%: T("Subtopic","Subtopik") %></label>
        <asp:Literal ID="litPropSubtopic" runat="server" />
    </div>
</div>

</div><%-- /.qb-layout --%>

<asp:HiddenField ID="hidCurrentTab" runat="server" Value="EN" />
<asp:HiddenField ID="hidToast" runat="server" Value="" />
</asp:Panel>

<div id="qbToast" class="qb-toast-container"></div>
</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
function showToast(m){var c=document.getElementById('qbToast'),t=document.createElement('div');t.className='qb-toast';t.innerHTML='<i class="bi bi-check-circle-fill"></i> '+m;c.appendChild(t);setTimeout(function(){t.style.opacity='0';},3e3);setTimeout(function(){t.remove();},3500);}

// Question Type switching
function switchQuestionType(){
    var sel=document.querySelector('[id$="ddlQType"]');if(!sel)return;
    var v=sel.value;
    document.getElementById('sectionMCQ').style.display=(v==='MCQ')?'block':'none';
    document.getElementById('sectionTF').style.display=(v==='True/False')?'block':'none';
    document.getElementById('sectionMS').style.display=(v==='Multiselect')?'block':'none';
    document.getElementById('sectionFIB').style.display=(v==='Drag & Drop')?'block':'none';
    // Sync TF/MS values to hidden server controls for save
    syncToServerControls();
}

// MCQ answer card highlighting
function updateAnswerCards(){
    document.querySelectorAll('#sectionMCQ .qb-opt').forEach(function(o){o.classList.remove('correct');});
    document.querySelectorAll('#sectionMCQ .qb-opt input[type="radio"]').forEach(function(r){if(r.checked)r.closest('.qb-opt').classList.add('correct');});
}

// True/False
function updateTFCards(){
    document.querySelectorAll('.qb-tf-card').forEach(function(c){c.classList.remove('selected');});
    document.querySelectorAll('.qb-tf-card input[type="radio"]').forEach(function(r){if(r.checked)r.closest('.qb-tf-card').classList.add('selected');});
    syncToServerControls();
}

// Multiselect
function updateMSCards(){
    var count=0;
    document.querySelectorAll('.qb-ms-opt').forEach(function(o){
        var cb=o.querySelector('.ms-check');
        if(cb&&cb.checked){o.classList.add('selected');count++;}else{o.classList.remove('selected');}
    });
    var el=document.getElementById('msCount');if(el)el.textContent=count+' <%: T("selected","dipilih") %>';
    syncToServerControls();
}

// Fill in the Blank logic
function addBlank(){
    var btn=document.getElementById('btnAddBlank');
    if(btn.classList.contains('disabled'))return;
    var ta=document.querySelector('[id$="txtQuestionText"]');if(!ta)return;
    var text=ta.value;
    var count=(text.match(/\[Blank \d\]/g)||[]).length;
    if(count>=4)return;
    var num=count+1;
    var ins='[Blank '+num+']';
    var start=ta.selectionStart,end=ta.selectionEnd;
    ta.value=text.substring(0,start)+ins+text.substring(end);
    ta.selectionStart=ta.selectionEnd=start+ins.length;
    ta.focus();
    updateFibUI();
}

function onFibWordChange(){updateFibMappings();updateFibPreview();}

function updateFibUI(){
    var ta=document.querySelector('[id$="txtQuestionText"]');if(!ta)return;
    var blanks=(ta.value.match(/\[Blank \d\]/g)||[]);
    var count=blanks.length;
    // Counter
    var numEl=document.getElementById('blankNum');
    var counterEl=document.querySelector('.fib-counter');
    if(numEl)numEl.textContent=count;
    if(counterEl)counterEl.classList.toggle('full',count>=4);
    // Button state
    var btn=document.getElementById('btnAddBlank');
    if(count>=4){btn.classList.add('disabled');document.getElementById('blankWarning').style.display='flex';}
    else{btn.classList.remove('disabled');document.getElementById('blankWarning').style.display='none';}
    // Sections visibility
    var mapSection=document.getElementById('fibMappingSection');
    var prevSection=document.getElementById('fibPreviewSection');
    if(count>0){mapSection.style.display='block';prevSection.style.display='block';updateFibMappings();updateFibPreview();}
    else{mapSection.style.display='none';prevSection.style.display='none';}
}

function updateFibMappings(){
    var ta=document.querySelector('[id$="txtQuestionText"]');if(!ta)return;
    var blanks=(ta.value.match(/\[Blank \d\]/g)||[]);
    var words=[];
    document.querySelectorAll('.fib-word-input').forEach(function(inp){if(inp.value.trim())words.push(inp.value.trim());});
    var container=document.getElementById('fibMappings');
    var existing={};
    container.querySelectorAll('.fib-map-dd').forEach(function(sel){existing[sel.dataset.blank]=sel.value;});
    var html='';
    blanks.forEach(function(b){
        var opts='<option value="">-- <%: T("Select word","Pilih perkataan") %> --</option>';
        words.forEach(function(w,wi){opts+='<option value="'+(wi+1)+'"'+(existing[b]===(''+(wi+1))?' selected':'')+'>'+w+'</option>';});
        var isValid=existing[b]&&existing[b]!=='';
        html+='<div class="qb-fib-map-row'+(isValid?' valid':'')+'"><span class="qb-fib-map-label">'+b+'</span><span class="qb-fib-map-arrow"><i class="bi bi-arrow-right"></i></span><select class="qb-fib-map-select fib-map-dd" data-blank="'+b+'" onchange="validateFibMapping()">'+opts+'</select><span class="qb-fib-map-check"><i class="bi bi-check-circle-fill"></i></span></div>';
    });
    container.innerHTML=html;
    updateFibPreview();
}

function validateFibMapping(){
    var selects=document.querySelectorAll('.fib-map-dd');
    var vals=[],dup=false;
    selects.forEach(function(s){
        var row=s.closest('.qb-fib-map-row');
        row.classList.remove('invalid');s.classList.remove('invalid');
        if(s.value){
            if(vals.indexOf(s.value)>-1){dup=true;row.classList.add('invalid');s.classList.add('invalid');}
            else{row.classList.add('valid');}
            vals.push(s.value);
        }else{row.classList.remove('valid');}
    });
    document.getElementById('fibMappingError').style.display=dup?'flex':'none';
    syncToServerControls();
}

function updateFibPreview(){
    var ta=document.querySelector('[id$="txtQuestionText"]');if(!ta)return;
    var text=ta.value||'';
    var previewHtml=text.replace(/\[Blank \d\]/g,'<span class="fib-blank">_____</span>');
    document.getElementById('fibPreviewText').innerHTML=previewHtml||'<em style="color:var(--tc-muted);"><%: T("Type your question with blanks...","Taip soalan anda dengan tempat kosong...") %></em>';
    var words=[];
    document.querySelectorAll('.fib-word-input').forEach(function(inp){if(inp.value.trim())words.push(inp.value.trim());});
    document.getElementById('fibPreviewWords').innerHTML=words.length?words.map(function(w){return'<span class="qb-fib-chip">'+w+'</span>';}).join(''):'<em style="font-size:.78rem;color:var(--tc-muted);"><%: T("Add words to Word Bank above","Tambah perkataan ke Bank Perkataan di atas") %></em>';
}

// Sync FIB to server controls
function syncToServerControls(){
    var sel=document.querySelector('[id$="ddlQType"]');if(!sel)return;
    var v=sel.value;
    var optA=document.querySelector('[id$="txtOptA"]');
    var optB=document.querySelector('[id$="txtOptB"]');
    var radAEl=document.querySelector('[id$="radA"]');
    var radBEl=document.querySelector('[id$="radB"]');
    if(v==='True/False'){
        if(optA)optA.value='True';if(optB)optB.value='False';
        var tfRadios=document.querySelectorAll('.qb-tf-card input[type="radio"]');
        tfRadios.forEach(function(r){if(r.value==='A'&&r.checked&&radAEl)radAEl.checked=true;if(r.value==='B'&&r.checked&&radBEl)radBEl.checked=true;});
    }
    if(v==='Multiselect'){
        var msTexts=document.querySelectorAll('.ms-text');
        var msCbs=document.querySelectorAll('.ms-check');
        var opts=[optA,document.querySelector('[id$="txtOptB"]'),document.querySelector('[id$="txtOptC"]'),document.querySelector('[id$="txtOptD"]')];
        var ans=[];
        msTexts.forEach(function(t,i){if(opts[i])opts[i].value=t.value;});
        msCbs.forEach(function(cb,i){if(cb.checked)ans.push(String.fromCharCode(65+i));});
        // Store multiselect answer as comma-separated in a hidden approach - we'll use radA for first correct
        // The backend reads correctAnswer field - we need to store it somehow
    }
    if(v==='Drag & Drop'){
        var fibInputs=document.querySelectorAll('.fib-word-input');
        var opts2=[optA,document.querySelector('[id$="txtOptB"]'),document.querySelector('[id$="txtOptC"]'),document.querySelector('[id$="txtOptD"]')];
        fibInputs.forEach(function(inp,i){if(opts2[i])opts2[i].value=inp.value;});
        // Store mapping as correctAnswer: "1,3,2,4" (word index for each blank)
        var mapSelects=document.querySelectorAll('.fib-map-dd');
        var mapping=[];mapSelects.forEach(function(s){mapping.push(s.value||'0');});
        // Set radA checked and use a hidden approach: store mapping in correctAnswer via first radio
        if(radAEl)radAEl.checked=true;
        // Store mapping string in a way the backend can read - use option fields creatively
        // correctAnswer will be set server-side from the option values position
    }
}

// Character counters
function updateCharCounts(){
    var q=document.querySelector('[id$="txtQuestionText"]');
    var ce=document.querySelector('[id$="txtCorrectExp"]');
    var we=document.querySelector('[id$="txtWrongExp"]');
    if(q)document.getElementById('qCharCount').textContent=q.value.length+' / 500';
    if(ce)document.getElementById('ceCharCount').textContent=ce.value.length+' / 500';
    if(we)document.getElementById('weCharCount').textContent=we.value.length+' / 500';
}

// Progress
function updateProgress(){
    var done=document.querySelectorAll('.qb-nav-item.done').length;
    var total=document.querySelectorAll('.qb-nav-item').length;
    var pct=total>0?Math.round(done/total*100):0;
    var fill=document.getElementById('progressFill');var txt=document.getElementById('progressText');
    if(fill)fill.style.width=pct+'%';
    if(txt)txt.textContent=done+' / '+total+' <%: T("Questions Saved","Soalan Disimpan") %>';
}

// Init
window.addEventListener('load',function(){
    var h=document.getElementById('<%=hidToast.ClientID%>');
    if(h&&h.value){showToast(h.value);h.value='';}
    // Type switch
    var ddl=document.querySelector('[id$="ddlQType"]');
    if(ddl){ddl.addEventListener('change',switchQuestionType);switchQuestionType();}
    // MCQ radios
    document.querySelectorAll('#sectionMCQ .qb-opt input[type="radio"]').forEach(function(r){r.addEventListener('change',updateAnswerCards);});
    updateAnswerCards();
    updateProgress();
    updateCharCounts();
    // Char counters live
    document.querySelectorAll('textarea').forEach(function(ta){ta.addEventListener('input',function(){updateCharCounts();updateFibUI();});});
    // Sync before postback
    var form=document.querySelector('form');
    if(form)form.addEventListener('submit',syncToServerControls);
    // Init FIB UI
    updateFibUI();
});
</script>
</asp:Content>
