<%@ Page Title="Student Details" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="studentDetails.aspx.cs" Inherits="ScienceBuddy.Teacher.studentDetails" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--sd:#6C63FF;--sd-dk:#5A52E0;--sd-lt:#F5F3FF;--sd-w:#FFF;--sd-b:#E5E7EB;--sd-t:#374151;--sd-m:#6B7280;--sd-s:#10B981;--sd-d:#EF4444;}
.sd-back{display:inline-flex;align-items:center;gap:6px;font-size:.82rem;font-weight:700;color:var(--sd);text-decoration:none;margin-bottom:1.25rem;transition:color .15s;}.sd-back:hover{color:var(--sd-dk);text-decoration:none;}
.sd-err{background:#FEF2F2;border:1.5px solid #FECACA;border-radius:16px;padding:2.5rem;text-align:center;}.sd-err i{font-size:2.5rem;color:var(--sd-d);opacity:.5;display:block;margin-bottom:.6rem;}.sd-err-title{font-size:.95rem;font-weight:800;color:#991B1B;margin-bottom:.3rem;}.sd-err-sub{font-size:.82rem;color:#B91C1C;margin-bottom:1rem;}.sd-err-link{display:inline-flex;align-items:center;gap:5px;background:var(--sd);color:#fff;border:none;border-radius:9px;padding:.5rem 1rem;font-size:.8rem;font-weight:700;text-decoration:none;}.sd-err-link:hover{background:var(--sd-dk);color:#fff;}
/* Profile card */
.sd-profile{background:var(--sd-w);border:1.5px solid var(--sd-b);border-radius:16px;padding:1.3rem;box-shadow:0 2px 8px rgba(0,0,0,.03);margin-bottom:1.2rem;display:flex;align-items:center;gap:1rem;flex-wrap:wrap;}
.sd-avatar{width:52px;height:52px;border-radius:14px;background:var(--sd-lt);color:var(--sd);display:flex;align-items:center;justify-content:center;font-size:1rem;font-weight:800;border:2px solid #DDD8FF;flex-shrink:0;}
.sd-info h2{margin:0;font-size:1.05rem;font-weight:800;color:var(--sd-t);}.sd-info p{margin:.15rem 0 0;font-size:.76rem;color:var(--sd-m);}
.sd-pills{display:flex;gap:.35rem;flex-wrap:wrap;margin-top:.3rem;}.sd-pill{display:inline-flex;align-items:center;gap:.2rem;padding:.18rem .5rem;border-radius:999px;background:#F9FAFB;border:1px solid var(--sd-b);color:var(--sd-m);font-size:.66rem;font-weight:700;}
/* Stats */
.sd-stats{display:grid;grid-template-columns:repeat(5,1fr);gap:.7rem;margin-bottom:1.2rem;}
.sd-stat{background:var(--sd-w);border:1.5px solid var(--sd-b);border-radius:14px;padding:.8rem;text-align:center;box-shadow:0 2px 6px rgba(0,0,0,.02);}
.sd-stat-icon{width:28px;height:28px;border-radius:8px;display:inline-flex;align-items:center;justify-content:center;color:var(--sd);background:var(--sd-lt);margin-bottom:.25rem;font-size:.8rem;}
.sd-stat h3{margin:.1rem 0;font-size:1.15rem;color:var(--sd-t);font-weight:800;}.sd-stat p{margin:0;font-size:.68rem;color:var(--sd-m);font-weight:600;}
/* Card */
.sd-card{background:var(--sd-w);border:1.5px solid var(--sd-b);border-radius:16px;padding:1.1rem;box-shadow:0 2px 8px rgba(0,0,0,.03);margin-bottom:1.1rem;}
.sd-card-hd{display:flex;align-items:center;gap:.5rem;margin-bottom:.8rem;}.sd-card-hd h3{margin:0;font-size:.9rem;font-weight:800;color:var(--sd-t);display:flex;align-items:center;gap:.35rem;}.sd-card-hd h3 i{color:var(--sd);}
/* Table */
.sd-tbl{width:100%;border-collapse:collapse;}.sd-tbl th{background:#F9FAFB;font-size:.7rem;font-weight:700;color:var(--sd-t);padding:.55rem .45rem;text-align:left;border-bottom:1px solid var(--sd-b);white-space:nowrap;}.sd-tbl td{padding:.55rem .45rem;font-size:.76rem;color:var(--sd-t);border-bottom:1px solid #F3F4F6;vertical-align:middle;}.sd-tbl tr:hover td{background:#FAFAFF;}
.sd-badge-done{font-size:.64rem;padding:2px 6px;border-radius:4px;background:#D1FAE5;color:#047857;font-weight:700;}.sd-badge-inc{font-size:.64rem;padding:2px 6px;border-radius:4px;background:#FEE2E2;color:#991B1B;font-weight:700;}
.sd-badge-pass{font-size:.64rem;padding:2px 6px;border-radius:4px;background:#D1FAE5;color:#047857;font-weight:700;}.sd-badge-fail{font-size:.64rem;padding:2px 6px;border-radius:4px;background:#FEE2E2;color:#991B1B;font-weight:700;}
/* Weak & Insight */
.sd-wk-item{display:flex;justify-content:space-between;align-items:center;padding:.5rem .6rem;border:1px solid var(--sd-b);border-radius:8px;background:#FAFAFA;margin-bottom:.4rem;}.sd-wk-name{font-size:.76rem;font-weight:700;color:var(--sd-t);}.sd-wk-cnt{font-size:.7rem;font-weight:800;color:var(--sd-d);background:#FEE2E2;padding:2px 7px;border-radius:5px;}
.sd-insight{background:#F0FDF4;border:1px solid #A7F3D0;border-radius:12px;padding:.9rem;font-size:.78rem;color:#065F46;line-height:1.55;}
.sd-empty{text-align:center;padding:1.3rem;font-size:.8rem;color:var(--sd-m);}
.sd-grid{display:grid;grid-template-columns:1fr 1fr;gap:1rem;}
@media(max-width:980px){.sd-stats{grid-template-columns:repeat(2,1fr);}.sd-grid{grid-template-columns:1fr;}}
@media(max-width:640px){.sd-stats{grid-template-columns:1fr 1fr;}.sd-profile{flex-direction:column;align-items:flex-start;}}
</style>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Teaching","Pengajaran") %></div>
        <a href="<%: ResolveUrl("~/Teacher/manageMaterials.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label"><%: T("Manage Materials","Bahan Pembelajaran") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label"><%: T("Manage Quiz","Kuiz") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/studentProgress.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-bar-chart item-icon"></i><span class="item-label"><%: T("Student Progress","Prestasi Pelajar") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/liveSession.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label"><%: T("Schedule Live Class","Kelas Langsung") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Community","Komuniti") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/privateMessages.aspx") %>" class="sb-sidebar-item"><i class="bi bi-envelope item-icon"></i><span class="item-label"><%: T("Private Message","Mesej Peribadi") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Account","Akaun") %></div>
        <a href="<%: ResolveUrl("~/Teacher/MyProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("My Profile","Profil Saya") %></span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Sign Out","Log Keluar") %></span></a></div>
</asp:Content>
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Student Details","Butiran Pelajar") %></asp:Content>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">
<a href="<%: ResolveUrl("~/Teacher/studentProgress.aspx") %>" class="sd-back"><i class="bi bi-arrow-left"></i> <%: T("Back to Student Progress","Kembali ke Prestasi Pelajar") %></a>

<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="sd-err"><i class="bi bi-exclamation-triangle-fill"></i><div class="sd-err-title"><%: T("Error","Ralat") %></div><div class="sd-err-sub"><asp:Literal ID="litErrMsg" runat="server" /></div>
    <a href="<%: ResolveUrl("~/Teacher/studentProgress.aspx") %>" class="sd-err-link"><i class="bi bi-arrow-left"></i> <%: T("Back","Kembali") %></a></div>
</asp:Panel>

<asp:Panel ID="pnlMain" runat="server" Visible="false">
<%-- Profile --%>
<div class="sd-profile">
    <div class="sd-avatar"><asp:Literal ID="litInitials" runat="server" /></div>
    <div class="sd-info"><h2><asp:Literal ID="litName" runat="server" /></h2><p>ID: <asp:Literal ID="litStudentId" runat="server" /></p>
    <div class="sd-pills"><span class="sd-pill"><i class="bi bi-mortarboard"></i> <asp:Literal ID="litLevel" runat="server" /></span></div></div>
</div>

<%-- Summary Stats --%>
<div class="sd-stats">
    <div class="sd-stat"><div class="sd-stat-icon"><i class="bi bi-journal-check"></i></div><h3><asp:Literal ID="litLessons" runat="server" /></h3><p><%: T("Lessons","Pelajaran") %></p></div>
    <div class="sd-stat"><div class="sd-stat-icon"><i class="bi bi-trophy"></i></div><h3><asp:Literal ID="litUnitAvg" runat="server" /></h3><p><%: T("Unit Quiz","Kuiz Unit") %></p></div>
    <div class="sd-stat"><div class="sd-stat-icon"><i class="bi bi-award"></i></div><h3><asp:Literal ID="litLevelAvg" runat="server" /></h3><p><%: T("Level Quiz","Kuiz Tahap") %></p></div>
    <div class="sd-stat"><div class="sd-stat-icon"><i class="bi bi-x-circle"></i></div><h3><asp:Literal ID="litFailedQ" runat="server" /></h3><p><%: T("Failed Q","Soalan Gagal") %></p></div>
    <div class="sd-stat"><div class="sd-stat-icon"><i class="bi bi-exclamation-triangle"></i></div><h3><asp:Literal ID="litWeakSub" runat="server" /></h3><p><%: T("Weak Sub","Subtopik Lemah") %></p></div>
</div>

<%-- Lesson Progress --%>
<div class="sd-card"><div class="sd-card-hd"><h3><i class="bi bi-book"></i> <%: T("Lesson Progress","Kemajuan Pelajaran") %></h3></div>
<table class="sd-tbl"><thead><tr><th><%: T("Lesson","Pelajaran") %></th><th><%: T("Status","Status") %></th><th><%: T("Date","Tarikh") %></th></tr></thead><tbody>
<asp:Repeater ID="rptLessons" runat="server"><ItemTemplate>
<tr><td><%# HttpUtility.HtmlEncode(Eval("lesson").ToString()) %></td>
<td><span class='<%# "sd-badge-" + Eval("statusCss") %>'><%# Eval("status") %></span></td>
<td style="font-size:.72rem;color:#6B7280;"><%# Eval("date") %></td></tr>
</ItemTemplate></asp:Repeater>
</tbody></table></div>

<%-- Quiz Results Grid --%>
<div class="sd-grid">
<div class="sd-card"><div class="sd-card-hd"><h3><i class="bi bi-trophy"></i> <%: T("Unit Quiz Results","Keputusan Kuiz Unit") %></h3></div>
<table class="sd-tbl"><thead><tr><th><%: T("Quiz","Kuiz") %></th><th><%: T("Score","Markah") %></th><th>%</th><th><%: T("Result","Keputusan") %></th><th>#</th><th><%: T("Date","Tarikh") %></th></tr></thead><tbody>
<asp:Repeater ID="rptUnitQuiz" runat="server"><ItemTemplate>
<tr><td><%# HttpUtility.HtmlEncode(Eval("quizName").ToString()) %></td><td><%# Eval("score") %></td><td><%# Eval("pct") %></td>
<td><span class='<%# "sd-badge-" + Eval("resCss") %>'><%# Eval("result") %></span></td><td><%# Eval("attempt") %></td><td style="font-size:.72rem;color:#6B7280;"><%# Eval("date") %></td></tr>
</ItemTemplate></asp:Repeater>
</tbody></table></div>

<div class="sd-card"><div class="sd-card-hd"><h3><i class="bi bi-award"></i> <%: T("Level Quiz Results","Keputusan Kuiz Tahap") %></h3></div>
<table class="sd-tbl"><thead><tr><th><%: T("Quiz","Kuiz") %></th><th><%: T("Score","Markah") %></th><th>%</th><th><%: T("Result","Keputusan") %></th><th>#</th><th><%: T("Date","Tarikh") %></th></tr></thead><tbody>
<asp:Repeater ID="rptLevelQuiz" runat="server"><ItemTemplate>
<tr><td><%# HttpUtility.HtmlEncode(Eval("quizName").ToString()) %></td><td><%# Eval("score") %></td><td><%# Eval("pct") %></td>
<td><span class='<%# "sd-badge-" + Eval("resCss") %>'><%# Eval("result") %></span></td><td><%# Eval("attempt") %></td><td style="font-size:.72rem;color:#6B7280;"><%# Eval("date") %></td></tr>
</ItemTemplate></asp:Repeater>
</tbody></table></div>
</div>

<%-- Failed Questions & Weak Subtopics --%>
<div class="sd-grid">
<div class="sd-card"><div class="sd-card-hd"><h3><i class="bi bi-x-circle"></i> <%: T("Failed Questions","Soalan Gagal") %></h3></div>
<asp:Panel ID="pnlFailedEmpty" runat="server" Visible="false"><div class="sd-empty"><%: T("No failed questions recorded.","Tiada soalan gagal direkodkan.") %></div></asp:Panel>
<table class="sd-tbl"><thead><tr><th><%: T("Question","Soalan") %></th><th><%: T("Correct","Betul") %></th><th><%: T("Student Answer","Jawapan Pelajar") %></th><th><%: T("Subtopic","Subtopik") %></th></tr></thead><tbody>
<asp:Repeater ID="rptFailed" runat="server"><ItemTemplate>
<tr><td><%# HttpUtility.HtmlEncode(Eval("question").ToString()) %></td><td style="color:#047857;font-weight:700;"><%# HttpUtility.HtmlEncode(Eval("correctAnswer").ToString()) %></td>
<td style="color:#991B1B;"><%# HttpUtility.HtmlEncode(Eval("studentAnswer").ToString()) %></td><td style="font-size:.72rem;"><%# HttpUtility.HtmlEncode(Eval("subtopic").ToString()) %></td></tr>
</ItemTemplate></asp:Repeater>
</tbody></table></div>

<div class="sd-card"><div class="sd-card-hd"><h3><i class="bi bi-exclamation-triangle"></i> <%: T("Weak Subtopics","Subtopik Lemah") %></h3></div>
<asp:Panel ID="pnlWeakEmpty" runat="server" Visible="false"><div class="sd-empty"><%: T("No weak subtopics detected.","Tiada subtopik lemah dikesan.") %></div></asp:Panel>
<asp:Repeater ID="rptWeak" runat="server"><ItemTemplate>
<div class="sd-wk-item"><span class="sd-wk-name"><%# HttpUtility.HtmlEncode(Eval("subtopic").ToString()) %></span><span class="sd-wk-cnt"><%# Eval("wrongCount") %> <%: T("wrong","salah") %></span></div>
</ItemTemplate></asp:Repeater>
</div>
</div>

<%-- Teacher Insight --%>
<div class="sd-card"><div class="sd-card-hd"><h3><i class="bi bi-lightbulb"></i> <%: T("Teacher Insight","Maklumat Guru") %></h3></div>
<div class="sd-insight"><asp:Literal ID="litInsight" runat="server" /></div></div>

</asp:Panel>
</asp:Content>
<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server"></asp:Content>
