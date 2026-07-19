<%@ Page Title="Student Details" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="studentDetails.aspx.cs" Inherits="ScienceBuddy.Teacher.studentDetails" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--blue:#3B82F6;--green:#10B981;--orange:#F59E0B;--red:#EF4444;--purple:#6C63FF;--purp-dk:#5A52E0;--w:#FFF;--b:#E5E7EB;--t:#1F2937;--m:#6B7280;}
.sd-back{display:inline-flex;align-items:center;gap:6px;font-size:.9rem;font-weight:700;color:var(--purple);text-decoration:none;margin-bottom:1.4rem;}.sd-back:hover{color:var(--purp-dk);}
.sd-err{background:#FEF2F2;border:1.5px solid #FECACA;border-radius:18px;padding:2.5rem;text-align:center;}.sd-err i{font-size:2.5rem;color:var(--red);opacity:.5;display:block;margin-bottom:.6rem;}.sd-err-t{font-size:1rem;font-weight:800;color:#991B1B;}.sd-err-s{font-size:.88rem;color:#B91C1C;margin:.3rem 0 1rem;}.sd-err-link{background:var(--purple);color:#fff;border:none;border-radius:10px;padding:.55rem 1.1rem;font-size:.86rem;font-weight:700;text-decoration:none;display:inline-flex;align-items:center;gap:5px;}.sd-err-link:hover{background:var(--purp-dk);color:#fff;}
.sd-profile{background:linear-gradient(135deg,#1E3A8A 0%,#2563EB 40%,#3B82F6 70%,#60A5FA 100%);border-radius:22px;padding:1.8rem 2.2rem;color:#fff;display:flex;align-items:center;gap:1.4rem;flex-wrap:wrap;margin-bottom:1.7rem;box-shadow:0 10px 32px rgba(37,99,235,.22);position:relative;overflow:hidden;}.sd-profile::before{content:'';position:absolute;width:240px;height:240px;border-radius:50%;background:rgba(255,255,255,.06);top:-80px;right:20px;}.sd-profile::after{content:'';position:absolute;width:120px;height:120px;border-radius:50%;background:rgba(255,255,255,.04);bottom:-40px;left:40px;}
.sd-avatar{width:62px;height:62px;border-radius:18px;background:rgba(255,255,255,.2);color:#fff;display:flex;align-items:center;justify-content:center;font-size:1.35rem;font-weight:800;border:2.5px solid rgba(255,255,255,.35);flex-shrink:0;}
.sd-pinfo h2{margin:0;font-size:1.25rem;font-weight:800;}.sd-pinfo p{margin:.2rem 0 0;font-size:.88rem;opacity:.85;}.sd-pills{display:flex;gap:.4rem;margin-top:.5rem;}.sd-pill{padding:.25rem .7rem;border-radius:999px;background:rgba(255,255,255,.18);color:#fff;font-size:.75rem;font-weight:700;border:1px solid rgba(255,255,255,.25);display:inline-flex;align-items:center;gap:.3rem;}
/* Donuts */
.sd-donuts{display:grid;grid-template-columns:repeat(3,1fr);gap:1.1rem;margin-bottom:1.7rem;}
.sd-dc{background:var(--w);border:1.5px solid var(--b);border-radius:18px;padding:1.4rem 1rem;text-align:center;box-shadow:0 3px 12px rgba(0,0,0,.04);transition:transform .2s,box-shadow .2s;position:relative;overflow:hidden;}.sd-dc:hover{transform:translateY(-3px);box-shadow:0 8px 24px rgba(0,0,0,.08);}
.sd-dc::after{content:'';position:absolute;top:0;left:0;right:0;height:4px;}
.sd-dc.accent-blue::after{background:linear-gradient(90deg,#3B82F6,#60A5FA);}
.sd-dc.accent-green::after{background:linear-gradient(90deg,#10B981,#6EE7B7);}
.sd-dc.accent-orange::after{background:linear-gradient(90deg,#F59E0B,#FCD34D);}
.sd-donut{width:110px;height:110px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;margin:0 auto .9rem;}
.sd-donut-inner{width:76px;height:76px;border-radius:50%;background:var(--w);display:flex;align-items:center;justify-content:center;}.sd-donut-val{font-size:1.4rem;font-weight:800;color:var(--t);}
.sd-dc-label{font-size:.95rem;font-weight:800;color:var(--t);margin-bottom:.2rem;}.sd-dc-meta{font-size:.84rem;color:var(--m);}
/* Section */
.sd-section{background:var(--w);border:1.5px solid var(--b);border-radius:18px;padding:1.5rem 1.6rem;box-shadow:0 3px 12px rgba(0,0,0,.04);margin-bottom:1.5rem;}
.sd-sec-hd{margin-bottom:1.1rem;}.sd-sec-hd h3{margin:0;font-size:1.1rem;font-weight:800;color:var(--t);display:flex;align-items:center;gap:.45rem;}.sd-sec-hd h3 i{font-size:1.1rem;}
.sd-tbl{width:100%;border-collapse:collapse;}.sd-tbl th{background:#EDE9FE;font-size:.88rem;font-weight:800;color:#4338CA;padding:.85rem .75rem;text-align:left;border-bottom:2px solid #C4B5FD;}.sd-tbl td{padding:.85rem .75rem;font-size:.92rem;color:var(--t);border-bottom:1px solid #F1F5F9;transition:background .15s;}.sd-tbl tr:hover td{background:#F8F6FF;}
.sd-badge{font-size:.78rem;padding:4px 11px;border-radius:6px;font-weight:700;}.sd-badge.done{background:#D1FAE5;color:#047857;}.sd-badge.inc{background:#FEF3C7;color:#92400E;}.sd-badge.pass{background:#D1FAE5;color:#047857;}.sd-badge.fail{background:#FEE2E2;color:#991B1B;}
/* Weak Topics + Insight layout */
.sd-weak-insight-row{display:grid;grid-template-columns:7fr 3fr;gap:1.2rem;align-items:start;margin-bottom:1.5rem;}
.sd-weak-col{min-width:0;}
.sd-insight-col{min-width:0;}
.sd-insight-col .sd-insight{position:sticky;top:1rem;}
/* Weak Topics */
.sd-wk-grid{display:grid;grid-template-columns:1fr 1fr;gap:.8rem;}
.sd-wk-card{background:#fff;border:1.5px solid #FEE2E2;border-radius:12px;padding:.9rem 1.1rem;display:flex;flex-direction:column;gap:.4rem;}
.sd-wk-row{display:flex;align-items:baseline;gap:.5rem;}
.sd-wk-lbl{font-size:.72rem;font-weight:700;color:#6B7280;text-transform:uppercase;letter-spacing:.3px;min-width:85px;flex-shrink:0;}
.sd-wk-val{font-size:.92rem;font-weight:700;color:var(--t);}
.sd-wk-val-title{font-size:.95rem;font-weight:800;}
.sd-wk-scores{display:flex;gap:1.5rem;padding:.3rem 0;}
.sd-wk-score-item{display:flex;flex-direction:column;gap:1px;}
.sd-wk-score-val{font-size:1.05rem;font-weight:800;color:var(--t);}
.sd-wk-val-red{color:#DC2626 !important;}
.sd-wk-status{font-size:.74rem;font-weight:700;color:#B45309;background:#FEF3C7;padding:3px 9px;border-radius:6px;display:inline-block;width:fit-content;}
@media(max-width:768px){.sd-wk-grid{grid-template-columns:1fr;}.sd-weak-insight-row{grid-template-columns:1fr;}}
/* Certificates */
.sd-cert-list{display:flex;flex-direction:column;gap:1rem;}
.sd-cert{background:linear-gradient(135deg,#FFFBEB,#FEF3C7);border:1.5px solid #FDE68A;border-radius:16px;padding:1.4rem 1.6rem;display:flex;align-items:flex-start;gap:1.1rem;box-shadow:0 3px 12px rgba(245,158,11,.08);transition:box-shadow .15s;}.sd-cert:hover{box-shadow:0 6px 20px rgba(245,158,11,.14);}
.sd-cert-icon{width:48px;height:48px;border-radius:14px;background:rgba(245,158,11,.15);color:#D97706;display:flex;align-items:center;justify-content:center;font-size:1.4rem;flex-shrink:0;}
.sd-cert-body{flex:1;min-width:0;}
.sd-cert-title{font-size:1.05rem;font-weight:800;color:var(--t);margin-bottom:.3rem;}
.sd-cert-desc{font-size:.88rem;color:#4B5563;line-height:1.55;margin-bottom:.5rem;}
.sd-cert-meta{display:flex;align-items:center;gap:.8rem;flex-wrap:wrap;font-size:.82rem;color:var(--m);font-weight:600;}
.sd-cert-meta i{margin-right:3px;}
.sd-cbadge{font-size:.72rem;padding:3px 9px;border-radius:5px;font-weight:700;}.sd-cbadge.active{background:#D1FAE5;color:#047857;}.sd-cbadge.pending{background:#FEF3C7;color:#92400E;}
.sd-empty{text-align:center;padding:2rem;font-size:.94rem;color:var(--m);}
.sd-insight{background:linear-gradient(135deg,#ECFDF5,#F0FDF4);border:1.5px solid #86EFAC;border-radius:16px;padding:1.2rem 1.3rem;}
.sd-insight h4{margin:0 0 .8rem;font-size:.95rem;font-weight:800;color:#047857;display:flex;align-items:center;gap:.4rem;}.sd-insight h4 i{font-size:1rem;}
.sd-ins-items{display:flex;flex-direction:column;gap:.5rem;margin-bottom:.8rem;}
.sd-ins-item{display:flex;align-items:center;justify-content:space-between;gap:.5rem;padding:.4rem .6rem;background:rgba(255,255,255,.7);border-radius:8px;border:1px solid #D1FAE5;}
.sd-ins-lbl{font-size:.76rem;font-weight:700;color:#374151;text-transform:uppercase;letter-spacing:.3px;}
.sd-ins-val{font-size:1rem;font-weight:800;color:#047857;}
.sd-ins-val-red{color:#DC2626 !important;}
.sd-ins-rec{padding-top:.6rem;border-top:1px solid #BBF7D0;}
.sd-ins-rec-lbl{font-size:.74rem;font-weight:700;color:#047857;display:flex;align-items:center;gap:.3rem;margin-bottom:.3rem;}
.sd-ins-rec-text{margin:0;font-size:.84rem;color:#065F46;line-height:1.6;}
.sd-grid{display:grid;grid-template-columns:1fr 1fr;gap:1.2rem;}
.sd-view-btn{background:var(--purple);color:#fff;border:none;border-radius:8px;padding:.4rem .85rem;font-size:.82rem;font-weight:700;cursor:pointer;transition:background .15s;}.sd-view-btn:hover{background:var(--purp-dk);}
.sd-modal-overlay{position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,.5);z-index:9999;display:flex;align-items:center;justify-content:center;padding:1rem;}
.sd-modal{background:#fff;border-radius:18px;width:100%;max-width:960px;max-height:85vh;display:flex;flex-direction:column;box-shadow:0 20px 60px rgba(0,0,0,.2);}
.sd-modal-hd{display:flex;align-items:center;justify-content:space-between;padding:1.2rem 1.6rem;border-bottom:1.5px solid var(--b);}.sd-modal-hd h3{margin:0;font-size:1.05rem;font-weight:800;color:var(--t);display:flex;align-items:center;gap:.4rem;}.sd-modal-hd h3 i{color:var(--purple);}
.sd-modal-close{background:none;border:none;font-size:1.6rem;color:var(--m);cursor:pointer;line-height:1;}.sd-modal-close:hover{color:var(--t);}
.sd-modal-body{overflow-y:auto;padding:1.4rem 1.6rem;}
.sd-ans-card{background:#fff;border:1.5px solid #E8EAF0;border-radius:18px;padding:1.5rem 1.6rem;margin-bottom:1.3rem;box-shadow:0 3px 12px rgba(0,0,0,.04),0 1px 3px rgba(0,0,0,.02);}
.sd-ans-header{display:flex;align-items:center;justify-content:space-between;margin-bottom:1.1rem;padding-bottom:.75rem;border-bottom:1.5px solid #F3F4F6;}
.sd-ans-num{font-size:1.02rem;font-weight:800;color:var(--purple);letter-spacing:-.2px;}
.sd-ans-q{font-size:.9rem;font-weight:600;color:var(--t);margin-bottom:.75rem;line-height:1.6;}
.sd-ans-row{display:flex;gap:1rem;flex-wrap:wrap;font-size:.86rem;}.sd-ans-row span{display:inline-flex;align-items:center;gap:.3rem;}
.sd-ans-badge{font-size:.77rem;padding:5px 13px;border-radius:8px;font-weight:700;letter-spacing:.2px;}.sd-ans-badge.correct{background:#D1FAE5;color:#047857;}.sd-ans-badge.wrong{background:#FEE2E2;color:#991B1B;}
/* Language sections grid */
.sd-ans-langs{display:grid;grid-template-columns:1fr 1fr;gap:1.1rem;margin-bottom:0;}
/* English section - soft blue accent */
.sd-ans-lang-section{padding:1.1rem 1.2rem;border-radius:14px;}
.sd-ans-lang-section:first-child{background:#EFF6FF;border:1.5px solid #BFDBFE;}
/* Bahasa Melayu section - soft orange accent */
.sd-ans-lang-section:last-child{background:#FFF7ED;border:1.5px solid #FDBA74;}
.sd-ans-lang-label{font-size:.75rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;margin-bottom:.65rem;padding-bottom:.45rem;border-bottom:1px solid rgba(0,0,0,.05);display:flex;align-items:center;gap:5px;}
.sd-ans-langs > .sd-ans-lang-section:first-child .sd-ans-lang-label{color:#2563EB;}
.sd-ans-langs > .sd-ans-lang-section:last-child .sd-ans-lang-label{color:#EA580C;}
.sd-ans-options{display:flex;flex-direction:column;gap:7px;}
.sd-ans-opt{display:flex;align-items:center;gap:10px;padding:8px 12px;border-radius:10px;font-size:.85rem;color:#374151;border:1.5px solid #E5E7EB;background:#fff;transition:background .12s;}
.sd-opt-label{width:26px;height:26px;border-radius:8px;background:#F3F4F6;display:flex;align-items:center;justify-content:center;font-size:.75rem;font-weight:800;color:#6B7280;flex-shrink:0;}
.sd-opt-correct{background:#ECFDF5;border-color:#86EFAC;color:#047857;font-weight:600;}.sd-opt-correct .sd-opt-label{background:#BBF7D0;color:#047857;}
.sd-opt-wrong{background:#FEF2F2;border-color:#FCA5A5;color:#991B1B;font-weight:600;}.sd-opt-wrong .sd-opt-label{background:#FECACA;color:#991B1B;}
/* Answer summary - below both columns */
.sd-ans-summary{display:flex;flex-direction:column;gap:.65rem;padding:1rem 1.2rem;margin-top:1.1rem;background:#F9FAFB;border:1.5px solid #F0F0F0;border-radius:14px;}
.sd-ans-summary span{display:inline-flex;align-items:center;gap:.3rem;color:#374151;}
.sd-ans-pair{display:flex;align-items:center;gap:.7rem;font-size:.87rem;}
.sd-ans-pair-label{font-weight:700;color:#374151;min-width:135px;}
.sd-ans-pair-val{font-weight:700;color:#1F2937;padding:5px 14px;background:#fff;border:1.5px solid #E5E7EB;border-radius:9px;letter-spacing:.3px;}
.sd-ans-dd-block{margin-bottom:.7rem;padding:.7rem .9rem;background:#fff;border:1.5px solid #E5E7EB;border-radius:10px;}
.sd-ans-dd-title{font-size:.83rem;font-weight:700;color:#374151;margin-bottom:.4rem;padding-bottom:.35rem;border-bottom:1px solid #F3F4F6;}
.sd-ans-dd-lang{font-size:.84rem;color:#374151;padding:4px 0;display:flex;align-items:center;gap:.5rem;}
.sd-ans-dd-lang-label{font-weight:700;color:#6B7280;font-size:.79rem;min-width:125px;}
.sd-ans-dd-val{font-size:.84rem;color:#9CA3AF;font-style:italic;}
.sd-ans-unavail{font-size:.83rem;color:#9CA3AF;font-style:italic;padding:.7rem 0;text-align:center;}
/* Quiz empty state */
.sd-quiz-empty{display:flex;flex-direction:column;align-items:center;justify-content:center;padding:2.5rem 1.5rem;text-align:center;color:#9CA3AF;}
.sd-quiz-empty i{font-size:2.5rem;opacity:.4;margin-bottom:.6rem;}
.sd-quiz-empty-msg{font-size:.9rem;font-weight:600;color:#6B7280;}
@media(max-width:980px){.sd-donuts{grid-template-columns:1fr 1fr 1fr;}.sd-grid{grid-template-columns:1fr;}}
@media(max-width:640px){.sd-donuts{grid-template-columns:1fr;}.sd-profile{flex-direction:column;align-items:flex-start;padding:1.3rem;}.sd-cert{flex-direction:column;}.sd-modal{max-width:100%;border-radius:12px;}.sd-ans-langs{grid-template-columns:1fr;}}
</style>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div><a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a><a href="<%: ResolveUrl("~/Teacher/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label"><%: T("Notifications","Notifikasi") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Teaching","Pengajaran") %></div><a href="<%: ResolveUrl("~/Teacher/manageMaterials.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label"><%: T("Manage Materials","Bahan Pembelajaran") %></span></a><a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label"><%: T("Manage Quiz","Kuiz") %></span></a><a href="<%: ResolveUrl("~/Teacher/studentProgress.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-bar-chart item-icon"></i><span class="item-label"><%: T("Student Progress","Prestasi Pelajar") %></span></a><a href="<%: ResolveUrl("~/Teacher/liveSession.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label"><%: T("Schedule Live Class","Kelas Langsung") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Community","Komuniti") %></div><a href="<%: ResolveUrl("~/Teacher/Forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a><a href="<%: ResolveUrl("~/Teacher/privateMessages.aspx") %>" class="sb-sidebar-item"><i class="bi bi-envelope item-icon"></i><span class="item-label"><%: T("Private Message","Mesej Peribadi") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Account","Akaun") %></div><a href="<%: ResolveUrl("~/Teacher/MyProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("My Profile","Profil Saya") %></span></a><a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Sign Out","Log Keluar") %></span></a></div>
</asp:Content>
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Student Details","Butiran Pelajar") %></asp:Content>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">
<a href="<%: ResolveUrl("~/Teacher/studentProgress.aspx") %>" class="sd-back"><i class="bi bi-arrow-left"></i> <%: T("Back to Student Progress","Kembali ke Prestasi Pelajar") %></a>
<asp:Panel ID="pnlError" runat="server" Visible="false"><div class="sd-err"><i class="bi bi-exclamation-triangle-fill"></i><div class="sd-err-t"><%: T("Error","Ralat") %></div><div class="sd-err-s"><asp:Literal ID="litErrMsg" runat="server" /></div><a href="<%: ResolveUrl("~/Teacher/studentProgress.aspx") %>" class="sd-err-link"><i class="bi bi-arrow-left"></i> <%: T("Back","Kembali") %></a></div></asp:Panel>
<asp:Panel ID="pnlMain" runat="server" Visible="false">

<div class="sd-profile"><div class="sd-avatar"><asp:Literal ID="litInitials" runat="server" /></div><div class="sd-pinfo"><h2><asp:Literal ID="litName" runat="server" /></h2><p>ID: <asp:Literal ID="litStudentId" runat="server" /> · <%: T("Detailed learning analytics","Analitik pembelajaran terperinci") %></p><div class="sd-pills"><span class="sd-pill"><i class="bi bi-mortarboard"></i> <asp:Literal ID="litLevel" runat="server" /></span></div></div></div>

<%-- 3 Donut Cards (percentage only inside) --%>
<div class="sd-donuts">
    <div class="sd-dc accent-blue"><div class="sd-donut" style="background:conic-gradient(#3B82F6 0% <%=LessonPct%>%, #E2E8F0 <%=LessonPct%>% 100%);"><div class="sd-donut-inner"><span class="sd-donut-val"><%=LessonPct%>%</span></div></div><div class="sd-dc-label"><%: T("Lesson Completion","Penyelesaian Pelajaran") %></div><div class="sd-dc-meta"><asp:Literal ID="litLessons" runat="server" /></div></div>
    <div class="sd-dc accent-green"><div class="sd-donut" style="background:conic-gradient(#10B981 0% <%=UnitPct%>%, #E2E8F0 <%=UnitPct%>% 100%);"><div class="sd-donut-inner"><span class="sd-donut-val"><%=UnitPct%>%</span></div></div><div class="sd-dc-label"><%: T("Unit Quiz Average","Purata Kuiz Unit") %></div><div class="sd-dc-meta"><asp:Literal ID="litUnitAvg" runat="server" /></div></div>
    <div class="sd-dc accent-orange"><div class="sd-donut" style="background:conic-gradient(#F59E0B 0% <%=LevelPct%>%, #E2E8F0 <%=LevelPct%>% 100%);"><div class="sd-donut-inner"><span class="sd-donut-val"><%=LevelPct%>%</span></div></div><div class="sd-dc-label"><%: T("Level Quiz Average","Purata Kuiz Tahap") %></div><div class="sd-dc-meta"><asp:Literal ID="litLevelAvg" runat="server" /></div></div>
</div>

<%-- Lesson Progress --%>
<div class="sd-section"><div class="sd-sec-hd"><h3><i class="bi bi-book-half" style="color:var(--blue);"></i> <%: T("Lesson Progress","Kemajuan Pelajaran") %></h3></div>
<asp:Panel ID="pnlLessonTable" runat="server" Visible="false">
<table class="sd-tbl"><thead><tr><th><%: T("Lesson","Pelajaran") %></th><th><%: T("Status","Status") %></th><th><%: T("Date","Tarikh") %></th></tr></thead><tbody>
<asp:Repeater ID="rptLessons" runat="server"><ItemTemplate><tr><td><%# HttpUtility.HtmlEncode(Eval("lesson").ToString()) %></td><td><span class='sd-badge <%# Eval("statusCss") %>'><%# Eval("status") %></span></td><td style="color:var(--m);"><%# Eval("date") %></td></tr></ItemTemplate></asp:Repeater></tbody></table>
</asp:Panel>
<asp:Panel ID="pnlLessonEmpty" runat="server" Visible="false">
<div class="sd-quiz-empty"><i class="bi bi-book"></i><div class="sd-quiz-empty-msg"><%: T("No lesson progress yet.","Belum ada kemajuan pelajaran.") %></div></div>
</asp:Panel>
</div>

<%-- Quiz Results --%>
<div class="sd-section"><div class="sd-sec-hd"><h3><i class="bi bi-trophy-fill" style="color:var(--green);"></i> <%: T("Unit Quiz Results","Keputusan Kuiz Unit") %></h3></div>
<asp:Panel ID="pnlUnitQuizTable" runat="server" Visible="false">
<table class="sd-tbl"><thead><tr><th><%: T("Quiz","Kuiz") %></th><th><%: T("Score","Markah") %></th><th><%: T("Correct","Betul") %></th><th><%: T("Wrong","Salah") %></th><th><%: T("Percentage","Peratus") %></th><th><%: T("Result","Keputusan") %></th><th><%: T("No. of Attempt","Bil. Cubaan") %></th><th><%: T("Date","Tarikh") %></th><th><%: T("Action","Tindakan") %></th></tr></thead><tbody>
<asp:Repeater ID="rptUnitQuiz" runat="server"><ItemTemplate><tr><td><%# HttpUtility.HtmlEncode(Eval("quizName").ToString()) %></td><td><%# Eval("score") %></td><td style="color:var(--green);font-weight:700;"><%# Eval("correctCount") %></td><td style="color:var(--red);font-weight:700;"><%# Eval("wrongCount") %></td><td><strong><%# Eval("pct") %></strong></td><td><span class='sd-badge <%# Eval("resCss") %>'><%# Eval("result") %></span></td><td><%# Eval("attempts") %></td><td style="color:var(--m);"><%# Eval("date") %></td><td><button type="button" class="sd-view-btn" onclick='openAnswerModal("<%# Eval("resultId") %>")'><%# T("View","Lihat") %></button></td></tr></ItemTemplate></asp:Repeater></tbody></table>
</asp:Panel>
<asp:Panel ID="pnlUnitQuizEmpty" runat="server" Visible="false">
<div class="sd-quiz-empty"><i class="bi bi-clipboard2-x"></i><div class="sd-quiz-empty-msg"><%: T("No quiz attempts yet.","Belum ada cubaan kuiz.") %></div></div>
</asp:Panel>
</div>

<div class="sd-section"><div class="sd-sec-hd"><h3><i class="bi bi-award-fill" style="color:var(--orange);"></i> <%: T("Level Quiz Results","Keputusan Kuiz Tahap") %></h3></div>
<asp:Panel ID="pnlLevelQuizTable" runat="server" Visible="false">
<table class="sd-tbl"><thead><tr><th><%: T("Quiz","Kuiz") %></th><th><%: T("Score","Markah") %></th><th><%: T("Correct","Betul") %></th><th><%: T("Wrong","Salah") %></th><th><%: T("Percentage","Peratus") %></th><th><%: T("Result","Keputusan") %></th><th><%: T("No. of Attempt","Bil. Cubaan") %></th><th><%: T("Date","Tarikh") %></th><th><%: T("Action","Tindakan") %></th></tr></thead><tbody>
<asp:Repeater ID="rptLevelQuiz" runat="server"><ItemTemplate><tr><td><%# HttpUtility.HtmlEncode(Eval("quizName").ToString()) %></td><td><%# Eval("score") %></td><td style="color:var(--green);font-weight:700;"><%# Eval("correctCount") %></td><td style="color:var(--red);font-weight:700;"><%# Eval("wrongCount") %></td><td><strong><%# Eval("pct") %></strong></td><td><span class='sd-badge <%# Eval("resCss") %>'><%# Eval("result") %></span></td><td><%# Eval("attempts") %></td><td style="color:var(--m);"><%# Eval("date") %></td><td><button type="button" class="sd-view-btn" onclick='openAnswerModal("<%# Eval("resultId") %>")'><%# T("View","Lihat") %></button></td></tr></ItemTemplate></asp:Repeater></tbody></table>
</asp:Panel>
<asp:Panel ID="pnlLevelQuizEmpty" runat="server" Visible="false">
<div class="sd-quiz-empty"><i class="bi bi-clipboard2-x"></i><div class="sd-quiz-empty-msg"><%: T("No quiz attempts yet.","Belum ada cubaan kuiz.") %></div></div>
</asp:Panel>
</div>

<%-- Answer Detail Modal --%>
<div id="answerModal" class="sd-modal-overlay" style="display:none;" onclick="if(event.target===this)closeAnswerModal();">
<div class="sd-modal">
<div class="sd-modal-hd"><h3><i class="bi bi-eye-fill"></i> <%: T("Quiz Answers","Jawapan Kuiz") %></h3><button type="button" class="sd-modal-close" onclick="closeAnswerModal();">&times;</button></div>
<div class="sd-modal-body" id="answerModalBody"><div class="sd-empty"><%: T("Loading...","Memuatkan...") %></div></div>
</div>
</div>

<%-- Weak Topics + Teacher Insight side by side --%>
<div class="sd-weak-insight-row">
<div class="sd-weak-col">
<div class="sd-section"><div class="sd-sec-hd"><h3><i class="bi bi-exclamation-triangle-fill" style="color:var(--red);"></i> <%: T("Weak Topics","Topik Lemah") %></h3></div>
<asp:Panel ID="pnlWeakNoAttempts" runat="server" Visible="false"><div class="sd-empty" style="padding:2rem;"><div style="font-size:2rem;margin-bottom:.5rem;">??</div><div style="font-size:1rem;font-weight:800;color:var(--t);margin-bottom:.3rem;"><%: T("No Quiz Attempts Yet","Belum Ada Cubaan Kuiz") %></div><div style="font-size:.86rem;color:var(--m);"><%: T("This student has not attempted any Unit or Level quizzes.","Pelajar ini belum mencuba sebarang Kuiz Unit atau Kuiz Level.") %></div></div></asp:Panel>
<asp:Panel ID="pnlWeakEmpty" runat="server" Visible="false"><div class="sd-empty" style="padding:2rem;"><div style="font-size:2rem;margin-bottom:.5rem;">??</div><div style="font-size:1rem;font-weight:800;color:var(--t);margin-bottom:.3rem;"><%: T("No Weak Topics","Tiada Topik Lemah") %></div><div style="font-size:.86rem;color:var(--m);"><%: T("The student has passed all attempted Unit and Level quizzes.","Pelajar telah lulus semua Kuiz Unit dan Kuiz Level yang telah dicuba.") %></div></div></asp:Panel>
<div class="sd-wk-grid">
<asp:Repeater ID="rptWeak" runat="server"><ItemTemplate>
<div class="sd-wk-card">
    <div class="sd-wk-row"><span class="sd-wk-lbl"><%: T("Quiz","Kuiz") %></span><span class="sd-wk-val sd-wk-val-title"><%# HttpUtility.HtmlEncode(Eval("quizName").ToString()) %></span></div>
    <div class="sd-wk-row"><span class="sd-wk-lbl"><%# Eval("quizType").ToString() == "Unit" ? T("Unit","Unit") : T("Level","Tahap") %></span><span class="sd-wk-val"><%# HttpUtility.HtmlEncode(Eval("scopeName").ToString()) %></span></div>
    <div class="sd-wk-scores">
        <div class="sd-wk-score-item"><span class="sd-wk-lbl"><%: T("Latest Score","Markah Terkini") %></span><span class="sd-wk-score-val sd-wk-val-red"><%# Eval("latestPct") %></span></div>
        <div class="sd-wk-score-item"><span class="sd-wk-lbl"><%: T("Passing Mark","Markah Lulus") %></span><span class="sd-wk-score-val"><%# Eval("passMarkStr") %></span></div>
    </div>
    <div class="sd-wk-row"><span class="sd-wk-lbl"><%: T("Status","Status") %></span><span class="sd-wk-status"><%# Eval("statusLabel") %></span></div>
</div>
</ItemTemplate></asp:Repeater>
</div></div>
</div>
<div class="sd-insight-col">
<div class="sd-insight">
    <h4><i class="bi bi-lightbulb-fill"></i> <%: T("Performance Summary","Ringkasan Prestasi") %></h4>
    <div class="sd-ins-items">
        <div class="sd-ins-item"><span class="sd-ins-lbl"><%: T("Completed Lessons","Pelajaran Selesai") %></span><span class="sd-ins-val"><asp:Literal ID="litInsLessons" runat="server" /></span></div>
        <div class="sd-ins-item"><span class="sd-ins-lbl"><%: T("Weak Unit Topics","Topik Unit Lemah") %></span><span class="sd-ins-val sd-ins-val-red"><asp:Literal ID="litInsWeakUnit" runat="server" Text="0" /></span></div>
        <div class="sd-ins-item"><span class="sd-ins-lbl"><%: T("Weak Level Topics","Topik Tahap Lemah") %></span><span class="sd-ins-val sd-ins-val-red"><asp:Literal ID="litInsWeakLevel" runat="server" Text="0" /></span></div>
        <div class="sd-ins-item"><span class="sd-ins-lbl"><%: T("Certificates Earned","Sijil Diperolehi") %></span><span class="sd-ins-val"><asp:Literal ID="litInsCerts" runat="server" Text="0" /></span></div>
    </div>
    <div class="sd-ins-rec">
        <span class="sd-ins-rec-lbl"><i class="bi bi-chat-quote"></i> <%: T("Recommendation","Cadangan") %></span>
        <p class="sd-ins-rec-text"><asp:Literal ID="litInsight" runat="server" /></p>
    </div>
</div>
</div>
</div>

<%-- Certificates --%>
<div class="sd-section"><div class="sd-sec-hd"><h3><i class="bi bi-patch-check-fill" style="color:var(--orange);"></i> <%: T("Certificates Earned","Sijil Diperolehi") %></h3></div>
<asp:Panel ID="pnlCertEmpty" runat="server" Visible="false"><div class="sd-empty"><%: T("This student has not earned any certificate yet.","Pelajar ini belum memperolehi sebarang sijil.") %></div></asp:Panel>
<div class="sd-cert-list">
<asp:Repeater ID="rptCerts" runat="server"><ItemTemplate>
<div class="sd-cert">
    <div class="sd-cert-icon"><i class="bi bi-award"></i></div>
    <div class="sd-cert-body">
        <div class="sd-cert-title"><%# HttpUtility.HtmlEncode(Eval("title").ToString()) %></div>
        <div class="sd-cert-desc"><%# HttpUtility.HtmlEncode(Eval("description").ToString()) %></div>
        <div class="sd-cert-meta">
            <span><i class="bi bi-mortarboard"></i> <%# HttpUtility.HtmlEncode(Eval("level").ToString()) %></span>
            <span><i class="bi bi-calendar3"></i> <%# Eval("date") %></span>
            <span class='sd-cbadge <%# Eval("statusCss") %>'><%# Eval("status") %></span>
        </div>
    </div>
</div>
</ItemTemplate></asp:Repeater>
</div></div>

</asp:Panel>
</asp:Content>
<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
function openAnswerModal(resultId){
    var modal=document.getElementById('answerModal');
    var body=document.getElementById('answerModalBody');
    body.innerHTML='<div class="sd-empty"><%: T("Loading...","Memuatkan...") %></div>';
    modal.style.display='flex';
    var xhr=new XMLHttpRequest();
    xhr.open('GET','studentDetails.aspx?handler=answers&resultId='+encodeURIComponent(resultId),true);
    xhr.onreadystatechange=function(){
        if(xhr.readyState===4){
            if(xhr.status===200){body.innerHTML=xhr.responseText;}
            else{body.innerHTML='<div class="sd-empty"><%: T("Error loading answers.","Ralat memuatkan jawapan.") %></div>';}
        }
    };
    xhr.send();
}
function closeAnswerModal(){document.getElementById('answerModal').style.display='none';}
document.addEventListener('keydown',function(e){if(e.key==='Escape')closeAnswerModal();});
</script>
</asp:Content>
