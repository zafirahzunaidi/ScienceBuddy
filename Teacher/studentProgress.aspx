<%@ Page Title="Student Progress" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="studentProgress.aspx.cs" Inherits="ScienceBuddy.Teacher.studentProgress" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--sp:#6C63FF;--sp-dk:#5A52E0;--sp-lt:#F5F3FF;--sp-w:#FFF;--sp-b:#E5E7EB;--sp-t:#374151;--sp-m:#6B7280;--sp-s:#10B981;--sp-d:#EF4444;}
.sp-header{margin-bottom:1.5rem;}.sp-header h1{font-size:1.4rem;font-weight:800;color:var(--sp-t);margin:0 0 .2rem;display:flex;align-items:center;gap:.4rem;}.sp-header h1 i{color:var(--sp);font-size:1.2rem;}.sp-header p{font-size:.84rem;color:var(--sp-m);margin:0;line-height:1.5;}
/* Search */
.sp-search-card{background:var(--sp-w);border:1.5px solid var(--sp-b);border-radius:14px;padding:.85rem 1.1rem;box-shadow:0 2px 6px rgba(0,0,0,.03);margin-bottom:1.1rem;}
.sp-search-row{display:flex;align-items:center;gap:.6rem;flex-wrap:wrap;}
.sp-search-wrap{position:relative;flex:1;min-width:220px;}
.sp-search-wrap i{position:absolute;left:12px;top:50%;transform:translateY(-50%);color:var(--sp-m);font-size:.88rem;pointer-events:none;}
.sp-search-input{width:100%;height:40px;border:1.5px solid var(--sp-b);border-radius:10px;padding:0 .8rem 0 2.2rem;font-size:.86rem;background:#fff;color:var(--sp-t);box-sizing:border-box;transition:border-color .2s;}
.sp-search-input:focus{outline:none;border-color:var(--sp);box-shadow:0 0 0 3px rgba(108,99,255,.08);}
.sp-btn{height:40px;padding:0 1.1rem;border:none;border-radius:10px;background:var(--sp);color:#fff;font-size:.84rem;font-weight:700;cursor:pointer;box-shadow:0 2px 6px rgba(108,99,255,.18);transition:background .15s;white-space:nowrap;}.sp-btn:hover{background:var(--sp-dk);}
.sp-sort{height:40px;border-radius:10px;border:1.5px solid var(--sp-b);padding:0 .7rem;font-size:.84rem;background:#fff;color:var(--sp-t);min-width:160px;cursor:pointer;}.sp-sort:focus{border-color:var(--sp);outline:none;}
.sp-btn-reset{height:40px;padding:0 1rem;border:1.5px solid var(--sp-b);border-radius:10px;background:var(--sp-w);color:var(--sp-m);font-size:.84rem;font-weight:700;cursor:pointer;transition:border-color .15s,color .15s;white-space:nowrap;}.sp-btn-reset:hover{border-color:var(--sp);color:var(--sp);}
/* Table card */
.sp-rank-card{background:var(--sp-w);border:1.5px solid var(--sp-b);border-radius:16px;padding:1.3rem;box-shadow:0 2px 8px rgba(0,0,0,.03);}
.sp-rank-hd{display:flex;align-items:center;gap:.6rem;margin-bottom:1.1rem;}.sp-rank-hd h2{font-size:1.05rem;font-weight:800;color:var(--sp-t);margin:0;}.sp-rank-hd i{color:var(--sp);font-size:1.15rem;}
.sp-tbl{width:100%;border-collapse:collapse;}.sp-tbl th{background:#EDE9FE;font-size:.84rem;font-weight:800;color:#4338CA;padding:.85rem .75rem;text-align:left;border-bottom:2px solid #C4B5FD;white-space:nowrap;}.sp-tbl td{padding:.8rem .75rem;font-size:.88rem;color:var(--sp-t);border-bottom:1px solid #F3F4F6;vertical-align:middle;transition:background .12s;}.sp-tbl tr:hover td{background:#F8F6FF;}
/* No. column plain number */
.sp-no{font-size:.88rem;font-weight:700;color:var(--sp-m);}
/* Quiz badges */
.sp-q-badge{font-size:.72rem;padding:2px 8px;border-radius:4px;font-weight:700;display:inline-block;margin-left:5px;}
.sp-q-badge.good{background:#D1FAE5;color:#047857;}.sp-q-badge.fair{background:#FEF3C7;color:#92400E;}.sp-q-badge.need{background:#FEE2E2;color:#991B1B;}.sp-q-badge.na{background:#F3F4F6;color:#6B7280;}
/* View Details button */
.sp-vd-btn{display:inline-flex;align-items:center;gap:5px;font-size:.8rem;padding:7px 15px;border-radius:9px;background:var(--sp);color:#fff;font-weight:700;text-decoration:none;transition:background .15s,box-shadow .15s;box-shadow:0 2px 6px rgba(108,99,255,.2);}.sp-vd-btn:hover{background:var(--sp-dk);color:#fff;text-decoration:none;box-shadow:0 4px 12px rgba(108,99,255,.28);}
/* Empty state */
.sp-empty{text-align:center;padding:2.5rem 1.5rem;color:var(--sp-m);}.sp-empty i{font-size:2.2rem;opacity:.3;display:block;margin-bottom:.6rem;}.sp-empty-title{font-size:.92rem;font-weight:700;color:var(--sp-t);margin-bottom:.25rem;}.sp-empty-sub{font-size:.8rem;color:var(--sp-m);}
.sp-note{margin-top:.8rem;font-size:.72rem;color:#9CA3AF;font-style:italic;}
/* Podium */
.sp-podium-section{background:linear-gradient(145deg,#5A4BDB 0%,#6D5EF7 40%,#7B61FF 100%);border-radius:22px;padding:2.2rem 1.5rem 0;box-shadow:0 10px 36px rgba(90,75,219,.25);margin-bottom:1.5rem;position:relative;overflow:hidden;}
.sp-podium-section::before{content:'✦';position:absolute;top:14px;left:20px;font-size:1rem;color:rgba(255,255,255,.15);}.sp-podium-section::after{content:'✦';position:absolute;top:20px;right:30px;font-size:.8rem;color:rgba(255,255,255,.12);}
.sp-podium-hd{text-align:center;margin-bottom:1.6rem;position:relative;z-index:1;}.sp-podium-hd h2{font-size:1.2rem;font-weight:800;color:#fff;margin:0 0 .25rem;display:flex;align-items:center;justify-content:center;gap:.5rem;}.sp-podium-hd h2 i{color:#FCD34D;font-size:1.3rem;}.sp-podium-hd p{font-size:.82rem;color:rgba(255,255,255,.7);margin:0;}
.sp-podium{display:grid;grid-template-columns:1fr 1.15fr 1fr;gap:1rem;align-items:end;position:relative;z-index:1;}
.sp-pod{background:var(--sp-w);border-radius:16px;padding:1.2rem .9rem 1rem;text-align:center;position:relative;transition:transform .2s,box-shadow .2s;box-shadow:0 4px 16px rgba(0,0,0,.12);}
.sp-pod:hover{transform:translateY(-4px);box-shadow:0 12px 32px rgba(0,0,0,.16);}
.sp-pod.first{order:2;padding:1.5rem 1rem 1.3rem;margin-top:-1.2rem;border:2px solid #FCD34D;box-shadow:0 6px 20px rgba(252,211,77,.2);}
.sp-pod.second{order:1;}
.sp-pod.third{order:3;}
.sp-pod-medal{font-size:2rem;display:block;margin-bottom:.4rem;line-height:1;}
.sp-pod.first .sp-pod-medal{font-size:2.4rem;}
.sp-pod-avatar{width:52px;height:52px;border-radius:50%;background:#EDE9FE;color:var(--sp);display:inline-flex;align-items:center;justify-content:center;font-size:1rem;font-weight:800;margin-bottom:.5rem;border:3px solid #D8D4FF;}
.sp-pod.first .sp-pod-avatar{width:62px;height:62px;font-size:1.15rem;border-color:#FCD34D;box-shadow:0 0 12px rgba(252,211,77,.3);}
.sp-pod-name{font-size:.88rem;font-weight:800;color:var(--sp-t);margin-bottom:.35rem;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.sp-pod-pct{font-size:1.4rem;font-weight:800;margin-bottom:.3rem;}
.sp-pod.first .sp-pod-pct{color:var(--sp-s);font-size:1.6rem;}
.sp-pod.second .sp-pod-pct{color:#3B82F6;}
.sp-pod.third .sp-pod-pct{color:#F59E0B;}
.sp-pod-badge{display:inline-block;font-size:.72rem;font-weight:700;padding:3px 11px;border-radius:999px;margin-bottom:.4rem;}
.sp-pod-badge.excellent{background:#D1FAE5;color:#047857;}.sp-pod-badge.good{background:#DBEAFE;color:#1D4ED8;}.sp-pod-badge.fair{background:#FEF3C7;color:#92400E;}
.sp-pod-lessons{font-size:.76rem;color:var(--sp-m);display:flex;align-items:center;justify-content:center;gap:4px;}
.sp-pod-empty{color:#9CA3AF;font-size:.84rem;padding:1.5rem .5rem;border:2px dashed #E5E7EB;border-radius:12px;margin:.5rem;}
/* Podium bases with 3D effect */
.sp-bases{display:grid;grid-template-columns:1fr 1.15fr 1fr;gap:1rem;position:relative;z-index:1;}
.sp-base{text-align:center;border-radius:12px 12px 0 0;font-size:1.5rem;font-weight:900;color:rgba(255,255,255,.9);position:relative;}
.sp-base.b1{background:linear-gradient(180deg,rgba(255,255,255,.2) 0%,rgba(255,255,255,.08) 100%);padding:.85rem 0;order:2;border-bottom:3px solid rgba(255,255,255,.15);}
.sp-base.b2{background:linear-gradient(180deg,rgba(255,255,255,.12) 0%,rgba(255,255,255,.04) 100%);padding:.65rem 0;order:1;border-bottom:3px solid rgba(255,255,255,.1);}
.sp-base.b3{background:linear-gradient(180deg,rgba(255,255,255,.12) 0%,rgba(255,255,255,.04) 100%);padding:.65rem 0;order:3;border-bottom:3px solid rgba(255,255,255,.1);}
@media(max-width:640px){.sp-podium,.sp-bases{grid-template-columns:1fr;}.sp-pod.first,.sp-pod.second,.sp-pod.third{order:unset;margin-top:0;}.sp-base.b1,.sp-base.b2,.sp-base.b3{order:unset;}}
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

<%-- Top Performing Students Podium (always shows real top 3, ignores search) --%>
<asp:Panel ID="pnlPodium" runat="server" Visible="false">
<div class="sp-podium-section">
    <div class="sp-podium-hd"><h2><i class="bi bi-trophy-fill"></i> <%: T("Top Performing Students","Pelajar Terbaik") %></h2><p><%: T("Top 3 students based on overall performance","3 pelajar terbaik berdasarkan prestasi keseluruhan") %></p></div>
    <div class="sp-podium">
        <asp:Repeater ID="rptPodium" runat="server">
            <ItemTemplate>
                <div class='sp-pod <%# Eval("podCss") %>'>
                    <%# Convert.ToBoolean(Eval("hasData")) ? "<span class='sp-pod-medal'>" + Eval("medal") + "</span><div class='sp-pod-avatar'>" + HttpUtility.HtmlEncode(Eval("initials").ToString()) + "</div><div class='sp-pod-name'>" + HttpUtility.HtmlEncode(Eval("name").ToString()) + "</div><div class='sp-pod-pct'>" + Eval("overallStr") + "</div><span class='sp-pod-badge " + Eval("perfCss") + "'>" + Eval("perfLabel") + "</span><div class='sp-pod-lessons'><i class='bi bi-book'></i> " + Eval("lessonsStr") + "</div>" : "<div class='sp-pod-empty'><span class='sp-pod-medal'>" + Eval("medal") + "</span><br/>No student yet</div>" %>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
    <div class="sp-bases">
        <div class="sp-base b2">2</div>
        <div class="sp-base b1">🏆 1</div>
        <div class="sp-base b3">3</div>
    </div>
</div>
</asp:Panel>

<%-- Search (only filters table, not leaderboard) --%>
<div class="sp-search-card">
    <div class="sp-search-row">
        <div class="sp-search-wrap"><i class="bi bi-search"></i>
            <asp:TextBox ID="txtSearch" runat="server" CssClass="sp-search-input" /></div>
        <asp:DropDownList ID="ddlSort" runat="server" CssClass="sp-sort" />
        <asp:Button ID="btnSearch" runat="server" CssClass="sp-btn" OnClick="btnSearch_Click" CausesValidation="false" />
        <asp:Button ID="btnReset" runat="server" CssClass="sp-btn-reset" OnClick="btnReset_Click" CausesValidation="false" />
    </div>
</div>

<div class="sp-rank-card">
    <div class="sp-rank-hd"><i class="bi bi-trophy"></i><h2><%: T("Student Progress Summary","Ringkasan Prestasi Pelajar") %></h2></div>

    <asp:Panel ID="pnlRankingEmpty" runat="server" Visible="false">
        <div class="sp-empty"><i class="bi bi-people"></i>
            <div class="sp-empty-title"><%: T("No students found.","Tiada pelajar ditemui.") %></div>
            <div class="sp-empty-sub"><%: T("Try searching another student name.","Cuba cari nama pelajar lain.") %></div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlTable" runat="server" Visible="false">
    <table class="sp-tbl"><thead><tr>
        <th style="width:50px;">No.</th><th><%: T("Student","Pelajar") %></th><th><%: T("Lessons","Pelajaran") %></th>
        <th><%: T("Unit Quiz Average","Purata Kuiz Unit") %></th><th><%: T("Level Quiz Average","Purata Kuiz Tahap") %></th>
        <th><%: T("Overall","Keseluruhan") %></th><th><%: T("Action","Tindakan") %></th>
    </tr></thead><tbody>
    <asp:Repeater ID="rptRanking" runat="server">
        <ItemTemplate>
        <tr>
            <td><span class="sp-no"><%# Eval("rowNum") %></span></td>
            <td><%# HttpUtility.HtmlEncode(Eval("name").ToString()) %></td>
            <td><%# Eval("lessonsStr") %></td>
            <td><%# Eval("unitQuizStr") %><span class='sp-q-badge <%# Eval("unitBadge") %>'><%# BadgeLabel(Eval("unitBadge").ToString()) %></span></td>
            <td><%# Eval("levelQuizStr") %><span class='sp-q-badge <%# Eval("levelBadge") %>'><%# BadgeLabel(Eval("levelBadge").ToString()) %></span></td>
            <td><strong><%# Eval("overallStr") %></strong></td>
            <td><a href='<%# ResolveUrl("~/Teacher/studentDetails.aspx") + "?studentId=" + Eval("studentId") %>' class="sp-vd-btn"><i class="bi bi-eye"></i> <%: T("View Details","Lihat Butiran") %></a></td>
        </tr>
        </ItemTemplate>
    </asp:Repeater>
    </tbody></table>
    <div class="sp-note"><%: T("Ranked by quiz performance. Only students with quiz attempts receive a rank. Practice quizzes excluded.","Dikedudukan mengikut prestasi kuiz. Hanya pelajar dengan cubaan kuiz menerima kedudukan. Kuiz latihan dikecualikan.") %></div>
    </asp:Panel>
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
