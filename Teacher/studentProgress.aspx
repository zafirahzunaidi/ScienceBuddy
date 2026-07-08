<%@ Page Title="Student Progress" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="studentProgress.aspx.cs" Inherits="ScienceBuddy.Teacher.studentProgress" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--sp:#6C63FF;--sp-dk:#5A52E0;--sp-lt:#F5F3FF;--sp-w:#FFF;--sp-b:#E5E7EB;--sp-t:#374151;--sp-m:#6B7280;--sp-s:#10B981;--sp-d:#EF4444;}
.sp-header{margin-bottom:1.5rem;}.sp-header h1{font-size:1.4rem;font-weight:800;color:var(--sp-t);margin:0 0 .2rem;display:flex;align-items:center;gap:.4rem;}.sp-header h1 i{color:var(--sp);font-size:1.2rem;}.sp-header p{font-size:.83rem;color:var(--sp-m);margin:0;line-height:1.5;}
/* Search */
.sp-search-card{background:var(--sp-w);border:1.5px solid var(--sp-b);border-radius:14px;padding:.85rem 1.1rem;box-shadow:0 2px 6px rgba(0,0,0,.03);margin-bottom:1.1rem;}
.sp-search-row{display:flex;align-items:center;gap:.6rem;flex-wrap:wrap;}
.sp-search-wrap{position:relative;flex:1;min-width:200px;}
.sp-search-wrap i{position:absolute;left:11px;top:50%;transform:translateY(-50%);color:var(--sp-m);font-size:.85rem;pointer-events:none;}
.sp-search-input{width:100%;height:38px;border:1.5px solid var(--sp-b);border-radius:9px;padding:0 .75rem 0 2.1rem;font-size:.84rem;background:#fff;color:var(--sp-t);box-sizing:border-box;transition:border-color .2s;}
.sp-search-input:focus{outline:none;border-color:var(--sp);box-shadow:0 0 0 3px rgba(108,99,255,.08);}
.sp-btn{height:38px;padding:0 1rem;border:none;border-radius:9px;background:var(--sp);color:#fff;font-size:.82rem;font-weight:700;cursor:pointer;box-shadow:0 2px 6px rgba(108,99,255,.18);transition:background .15s;white-space:nowrap;}.sp-btn:hover{background:var(--sp-dk);}
.sp-btn-reset{height:38px;padding:0 .9rem;border:1.5px solid var(--sp-b);border-radius:9px;background:var(--sp-w);color:var(--sp-m);font-size:.82rem;font-weight:700;cursor:pointer;transition:border-color .15s,color .15s;white-space:nowrap;}.sp-btn-reset:hover{border-color:var(--sp);color:var(--sp);}
/* Table card */
.sp-rank-card{background:var(--sp-w);border:1.5px solid var(--sp-b);border-radius:16px;padding:1.2rem;box-shadow:0 2px 8px rgba(0,0,0,.03);}
.sp-rank-hd{display:flex;align-items:center;gap:.6rem;margin-bottom:1rem;}.sp-rank-hd h2{font-size:1rem;font-weight:800;color:var(--sp-t);margin:0;}.sp-rank-hd i{color:var(--sp);font-size:1.1rem;}
.sp-tbl{width:100%;border-collapse:collapse;border-radius:12px;overflow:hidden;}.sp-tbl th{background:#F9FAFB;font-size:.78rem;font-weight:700;color:var(--sp-t);padding:.7rem .6rem;text-align:left;border-bottom:1px solid var(--sp-b);white-space:nowrap;}.sp-tbl td{padding:.75rem .6rem;font-size:.84rem;color:var(--sp-t);border-bottom:1px solid #F3F4F6;vertical-align:middle;transition:background .15s;}.sp-tbl tr:hover td{background:#EEEAFF;cursor:pointer;}
/* Top 3 row highlights */
.sp-tbl tr.sp-row-gold td{background:#FFFBEB;}.sp-tbl tr.sp-row-gold:hover td{background:#FEF3C7;}
.sp-tbl tr.sp-row-silver td{background:#F9FAFB;}.sp-tbl tr.sp-row-silver:hover td{background:#F3F4F6;}
.sp-tbl tr.sp-row-bronze td{background:#FFF7ED;}.sp-tbl tr.sp-row-bronze:hover td{background:#FFEDD5;}
/* Medal rank badges */
.sp-rank-badge{width:32px;height:32px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:.8rem;font-weight:800;}
.sp-rank-badge.gold{background:linear-gradient(135deg,#FEF3C7,#FDE68A);color:#92400E;border:2px solid #FCD34D;box-shadow:0 2px 8px rgba(252,211,77,.3);}
.sp-rank-badge.silver{background:linear-gradient(135deg,#F9FAFB,#E5E7EB);color:#374151;border:2px solid #D1D5DB;box-shadow:0 2px 6px rgba(0,0,0,.06);}
.sp-rank-badge.bronze{background:linear-gradient(135deg,#FFF7ED,#FED7AA);color:#9A3412;border:2px solid #FDBA74;box-shadow:0 2px 6px rgba(253,186,116,.25);}
.sp-rank-badge.purple{background:var(--sp-lt);color:var(--sp);border:1.5px solid #DDD8FF;}
.sp-q-badge{font-size:.7rem;padding:2px 8px;border-radius:4px;font-weight:700;display:inline-block;margin-left:5px;}
.sp-q-badge.good{background:#D1FAE5;color:#047857;}.sp-q-badge.fair{background:#FEF3C7;color:#92400E;}.sp-q-badge.need{background:#FEE2E2;color:#991B1B;}.sp-q-badge.na{background:#F3F4F6;color:#6B7280;}
.sp-vd-btn{display:inline-flex;align-items:center;gap:4px;font-size:.78rem;padding:6px 14px;border-radius:8px;background:var(--sp);color:#fff;font-weight:700;text-decoration:none;transition:background .15s;box-shadow:0 2px 6px rgba(108,99,255,.2);}.sp-vd-btn:hover{background:var(--sp-dk);color:#fff;text-decoration:none;}
.sp-rank-empty{text-align:center;padding:2rem;color:var(--sp-m);font-size:.84rem;}
.sp-note{margin-top:.7rem;font-size:.69rem;color:#9CA3AF;font-style:italic;}
@media(max-width:768px){.sp-rank-card{padding:.9rem;overflow-x:auto;}.sp-search-row{flex-direction:column;align-items:stretch;}.sp-search-wrap{min-width:unset;}.sp-btn,.sp-btn-reset{width:100%;}}
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

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Student Progress","Prestasi Pelajar") %></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="sp-header"><h1><i class="bi bi-bar-chart"></i> <%: T("Student Progress","Prestasi Pelajar") %></h1>
<p><%: T("Monitor lesson completion and quiz performance across all students.","Pantau penyelesaian pelajaran dan prestasi kuiz semua pelajar.") %></p></div>

<%-- Search filter --%>
<div class="sp-search-card">
    <div class="sp-search-row">
        <div class="sp-search-wrap"><i class="bi bi-search"></i>
            <asp:TextBox ID="txtSearch" runat="server" CssClass="sp-search-input" /></div>
        <asp:Button ID="btnSearch" runat="server" CssClass="sp-btn" OnClick="btnSearch_Click" CausesValidation="false" />
        <asp:Button ID="btnReset" runat="server" CssClass="sp-btn-reset" OnClick="btnReset_Click" CausesValidation="false" />
    </div>
</div>

<%-- Ranking table --%>
<div class="sp-rank-card">
    <div class="sp-rank-hd"><i class="bi bi-trophy"></i><h2><%: T("Student Progress Summary","Ringkasan Prestasi Pelajar") %></h2></div>
    <asp:Panel ID="pnlRankingEmpty" runat="server" Visible="false"><div class="sp-rank-empty"><%: T("No students found.","Tiada pelajar ditemui.") %></div></asp:Panel>
    <table class="sp-tbl"><thead><tr>
        <th>#</th><th><%: T("Student","Pelajar") %></th><th><%: T("Lessons","Pelajaran") %></th>
        <th><%: T("Unit Quiz Average","Purata Kuiz Unit") %></th><th><%: T("Level Quiz Average","Purata Kuiz Tahap") %></th>
        <th><%: T("Action","Tindakan") %></th>
    </tr></thead><tbody>
    <asp:Repeater ID="rptRanking" runat="server">
        <ItemTemplate>
        <tr class='<%# Eval("rowCss") %>'>
            <td><span class='sp-rank-badge <%# Eval("rankCss") %>'><%# Eval("medalIcon") %></span></td>
            <td><%# HttpUtility.HtmlEncode(Eval("name").ToString()) %></td>
            <td><%# Eval("lessonsStr") %></td>
            <td><%# Eval("unitQuizStr") %><span class='sp-q-badge <%# Eval("unitBadge") %>'><%# BadgeLabel(Eval("unitBadge").ToString()) %></span></td>
            <td><%# Eval("levelQuizStr") %><span class='sp-q-badge <%# Eval("levelBadge") %>'><%# BadgeLabel(Eval("levelBadge").ToString()) %></span></td>
            <td><a href='<%# ResolveUrl("~/Teacher/studentDetails.aspx") + "?studentId=" + Eval("studentId") %>' class="sp-vd-btn"><i class="bi bi-eye"></i> <%: T("View Details","Lihat Butiran") %></a></td>
        </tr>
        </ItemTemplate>
    </asp:Repeater>
    </tbody></table>
    <div class="sp-note"><%: T("Ranked by quiz performance. Practice quizzes excluded.","Dikedudukan mengikut prestasi kuiz. Kuiz latihan dikecualikan.") %></div>
</div>
</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
document.addEventListener('DOMContentLoaded', function () {
    var txt = document.getElementById('<%=txtSearch.ClientID%>');
    if (txt) txt.addEventListener('keydown', function (e) {
        if (e.key === 'Enter') { e.preventDefault(); document.getElementById('<%=btnSearch.ClientID%>').click(); }
    });
});
</script>
</asp:Content>
