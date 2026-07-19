<%@ Page Title="Student Progress" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="studentProgress.aspx.cs" Inherits="ScienceBuddy.Teacher.studentProgress" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--sp:#6C63FF;--sp-dk:#5A52E0;--sp-lt:#F5F3FF;--sp-w:#FFF;--sp-b:#E5E7EB;--sp-t:#374151;--sp-m:#6B7280;--sp-s:#10B981;--sp-d:#EF4444;}
.sp-header{display:none;}
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
.sp-tbl{width:100%;border-collapse:collapse;}.sp-tbl th{background:#EDE9FE;font-size:.84rem;font-weight:800;color:#4338CA;padding:.85rem .75rem;text-align:center;border-bottom:2px solid #C4B5FD;white-space:nowrap;}.sp-tbl td{padding:.8rem .75rem;font-size:.88rem;color:var(--sp-t);border-bottom:1px solid #F3F4F6;vertical-align:middle;text-align:center;transition:background .12s;}.sp-tbl tr:hover td{background:#F8F6FF;}
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
/* Podium - Clean Premium Leaderboard */
.sp-podium-section{background:#fff;border-radius:24px;padding:2.5rem 2.2rem 0;box-shadow:0 4px 28px rgba(0,0,0,.05);margin-bottom:1.8rem;position:relative;overflow:hidden;border:1.5px solid #F0F0F0;}
/* Subtle decorative background */
.sp-podium-section::before{content:'';position:absolute;top:20px;right:30px;width:60px;height:60px;border-radius:50%;background:radial-gradient(circle,rgba(251,191,36,.06) 0%,transparent 70%);pointer-events:none;}
.sp-podium-section::after{content:'';position:absolute;bottom:40px;left:25px;width:40px;height:40px;border-radius:50%;background:radial-gradient(circle,rgba(139,92,246,.05) 0%,transparent 70%);pointer-events:none;}
/* Header */
.sp-podium-hd{text-align:left;margin-bottom:2rem;position:relative;z-index:1;}
.sp-podium-hd h2{font-size:1.35rem;font-weight:800;color:var(--sp-t);margin:0 0 .5rem;display:flex;align-items:center;gap:.5rem;}
.sp-podium-hd h2 i{color:#F59E0B;font-size:1.4rem;}
.sp-podium-hd-line{width:48px;height:3.5px;border-radius:4px;background:linear-gradient(90deg,#F59E0B,#FBBF24);margin-bottom:.5rem;}
.sp-podium-hd p{font-size:.84rem;color:var(--sp-m);margin:0;}
/* Podium grid */
.sp-podium{display:grid;grid-template-columns:1fr 1.15fr 1fr;gap:1.2rem;align-items:end;position:relative;z-index:1;padding-bottom:.8rem;}
/* Podium cards */
.sp-pod{border-radius:20px;padding:1.4rem 1rem 1.2rem;text-align:center;position:relative;transition:transform .25s ease,box-shadow .25s ease;}
.sp-pod:hover{transform:translateY(-5px);}
/* Rank 2 - Silver / Light Blue */
.sp-pod.second{order:1;background:linear-gradient(160deg,#F8FAFC 0%,#E2E8F0 100%);box-shadow:0 6px 20px rgba(148,163,184,.2);border:1.5px solid #E2E8F0;}
.sp-pod.second:hover{box-shadow:0 12px 32px rgba(148,163,184,.28);}
/* Rank 1 - Gold / Yellow */
.sp-pod.first{order:2;background:linear-gradient(160deg,#FFFBEB 0%,#FEF3C7 60%,#FDE68A 100%);box-shadow:0 8px 28px rgba(251,191,36,.18);margin-top:-1.5rem;padding:1.8rem 1.2rem 1.5rem;border:1.5px solid #FDE68A;}
.sp-pod.first:hover{box-shadow:0 14px 40px rgba(251,191,36,.25);}
/* Rank 3 - Bronze / Orange */
.sp-pod.third{order:3;background:linear-gradient(160deg,#FFF7ED 0%,#FFEDD5 100%);box-shadow:0 6px 20px rgba(251,146,60,.15);border:1.5px solid #FED7AA;}
.sp-pod.third:hover{box-shadow:0 12px 32px rgba(251,146,60,.22);}
/* Medal */
.sp-pod-medal{font-size:2.2rem;display:block;margin-bottom:.5rem;line-height:1;filter:drop-shadow(0 2px 4px rgba(0,0,0,.1));animation:spMedalBounce .5s ease .2s both;}
.sp-pod.first .sp-pod-medal{font-size:2.6rem;}
@keyframes spMedalBounce{0%{transform:scale(0) rotate(-15deg);opacity:0;}70%{transform:scale(1.1) rotate(3deg);opacity:1;}100%{transform:scale(1) rotate(0);}}
/* Avatar */
.sp-pod-avatar{width:60px;height:60px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:1.1rem;font-weight:800;margin-bottom:.6rem;color:#fff;border:3px solid #fff;box-shadow:0 3px 12px rgba(0,0,0,.1);}
.sp-pod.first .sp-pod-avatar{width:72px;height:72px;font-size:1.3rem;background:linear-gradient(135deg,#F59E0B,#D97706);box-shadow:0 4px 16px rgba(245,158,11,.25);}
.sp-pod.second .sp-pod-avatar{background:linear-gradient(135deg,#6366F1,#4F46E5);}
.sp-pod.third .sp-pod-avatar{background:linear-gradient(135deg,#F97316,#EA580C);}
/* Name */
.sp-pod-name{font-size:.9rem;font-weight:700;color:var(--sp-t);margin-bottom:.4rem;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.sp-pod.first .sp-pod-name{font-size:.95rem;font-weight:800;}
/* Percentage */
.sp-pod-pct{font-size:1.5rem;font-weight:900;margin-bottom:.4rem;color:var(--sp-t);}
.sp-pod.first .sp-pod-pct{font-size:1.8rem;color:#B45309;}
.sp-pod.second .sp-pod-pct{font-size:1.5rem;color:#4338CA;}
.sp-pod.third .sp-pod-pct{font-size:1.5rem;color:#C2410C;}
/* Badge */
.sp-pod-badge{display:inline-block;font-size:.73rem;font-weight:700;padding:4px 12px;border-radius:999px;margin-bottom:.5rem;}
.sp-pod-badge.excellent{background:linear-gradient(135deg,#D1FAE5,#A7F3D0);color:#047857;border:1px solid #6EE7B7;}
.sp-pod-badge.good{background:linear-gradient(135deg,#DBEAFE,#BFDBFE);color:#1D4ED8;border:1px solid #93C5FD;}
.sp-pod-badge.fair{background:linear-gradient(135deg,#FEF3C7,#FDE68A);color:#92400E;border:1px solid #FCD34D;}
.sp-pod-badge.need{background:linear-gradient(135deg,#FEE2E2,#FECACA);color:#991B1B;border:1px solid #FCA5A5;}
.sp-pod-badge.na{background:#F3F4F6;color:#6B7280;border:1px solid #E5E7EB;}
/* Lessons */
.sp-pod-lessons{font-size:.76rem;color:var(--sp-m);display:flex;align-items:center;justify-content:center;gap:4px;}
/* Empty pod */
.sp-pod-empty{color:#9CA3AF;font-size:.84rem;padding:1.5rem .5rem;text-align:center;}
.sp-pod-empty .sp-pod-medal{opacity:.5;margin-bottom:.6rem;}
/* Podium bases - subtle platforms */
.sp-bases{display:grid;grid-template-columns:1fr 1.15fr 1fr;gap:1.2rem;position:relative;z-index:1;}
.sp-base{text-align:center;border-radius:12px 12px 0 0;font-size:0;height:12px;position:relative;}
.sp-base.b1{background:linear-gradient(180deg,#FEF3C7,#FDE68A);order:2;height:18px;box-shadow:0 -2px 8px rgba(251,191,36,.1);}
.sp-base.b2{background:linear-gradient(180deg,#F1F5F9,#E2E8F0);order:1;}
.sp-base.b3{background:linear-gradient(180deg,#FFEDD5,#FED7AA);order:3;}
@media(max-width:640px){.sp-podium,.sp-bases{grid-template-columns:1fr;}.sp-pod.first,.sp-pod.second,.sp-pod.third{order:unset;margin-top:0;}.sp-base.b1,.sp-base.b2,.sp-base.b3{order:unset;height:8px;}}
@media(max-width:768px){.sp-rank-card{padding:.9rem;overflow-x:auto;}.sp-search-row{flex-direction:column;align-items:stretch;}.sp-search-wrap{min-width:unset;}.sp-btn,.sp-btn-reset{width:100%;}}
</style>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label"><%: T("Notifications","Notifikasi") %></span></a></div>
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

<%-- Pending Verification State --%>
<asp:Panel ID="pnlPending" runat="server" Visible="false">
    <div style="display:flex;flex-direction:column;align-items:center;padding:3.5rem 2rem;text-align:center;">
        <div style="font-size:3.5rem;margin-bottom:1rem;opacity:.85;">?</div>
        <h2 style="font-size:1.15rem;font-weight:800;color:var(--sp-t);margin:0 0 .6rem;"><%: T("Verification Pending","Pengesahan Sedang Diproses") %></h2>
        <p style="font-size:.88rem;color:var(--sp-m);max-width:480px;line-height:1.65;margin:0;"><%: T("Your Teaching License is still under review. You will be able to view student progress once your verification has been approved.","Lesen Mengajar anda masih dalam semakan. Anda akan dapat melihat prestasi pelajar setelah pengesahan anda diluluskan.") %></p>
    </div>
</asp:Panel>

<%-- Main Content (hidden for Pending teachers) --%>
<asp:Panel ID="pnlContent" runat="server">

<%-- Top Performing Students Podium (always shows real top 3, ignores search) --%>
<asp:Panel ID="pnlPodium" runat="server" Visible="false">
<div class="sp-podium-section">
    <div class="sp-podium-hd">
        <h2><i class="bi bi-trophy-fill"></i> <%: T("Top Performing Students","Pelajar Terbaik") %></h2>
        <div class="sp-podium-hd-line"></div>
        <p><%: T("Top 3 students based on overall performance","3 pelajar terbaik berdasarkan prestasi keseluruhan") %></p>
    </div>
    <div class="sp-podium">
        <asp:Repeater ID="rptPodium" runat="server">
            <ItemTemplate>
                <div class='sp-pod <%# Eval("podCss") %>'>
                    <%# Convert.ToBoolean(Eval("hasData")) ? "<span class='sp-pod-medal'>" + Eval("medal") + "</span><div class='sp-pod-avatar'>" + HttpUtility.HtmlEncode(Eval("initials").ToString()) + "</div><div class='sp-pod-name'>" + HttpUtility.HtmlEncode(Eval("name").ToString()) + "</div><div class='sp-pod-pct'>" + Eval("overallStr") + "</div><span class='sp-pod-badge " + Eval("perfCss") + "'>" + Eval("perfLabel") + "</span><div class='sp-pod-lessons'><i class='bi bi-book'></i> " + Eval("lessonsStr") + "</div>" : "<div class='sp-pod-empty'><span class='sp-pod-medal'>" + Eval("medal") + "</span><br/><span style='display:block;margin-top:.4rem;font-weight:600;'>No student yet</span><span style='font-size:.72rem;color:#9CA3AF;'>Complete more quizzes to appear here.</span></div>" %>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
    <div class="sp-bases">
        <div class="sp-base b2"></div>
        <div class="sp-base b1"></div>
        <div class="sp-base b3"></div>
    </div>
</div>
</asp:Panel>

<%-- Search (client-side filter, no page reload) --%>
<div class="sp-search-card">
    <div class="sp-search-row">
        <div class="sp-search-wrap"><i class="bi bi-search"></i>
            <input type="text" id="spSearchInput" class="sp-search-input" placeholder="<%: T("Search student...","Cari pelajar...") %>" value="<%= HttpUtility.HtmlAttributeEncode(txtSearch.Text) %>" /></div>
        <asp:DropDownList ID="ddlSort" runat="server" CssClass="sp-sort" onchange="spFilterTable();return false;" />
        <button type="button" class="sp-btn" onclick="spFilterTable()"><%: T("Search","Cari") %></button>
        <button type="button" class="sp-btn-reset" onclick="spResetFilter()"><%: T("Reset","Set Semula") %></button>
    </div>
</div>
<asp:TextBox ID="txtSearch" runat="server" Style="display:none;" />

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
    </asp:Panel>
</div>
</asp:Panel>
</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
function spFilterTable(){
    var query=document.getElementById('spSearchInput').value.trim().toLowerCase();
    var sortVal=document.getElementById('<%=ddlSort.ClientID%>').value;
    var table=document.querySelector('.sp-tbl');
    if(!table)return;
    var tbody=table.querySelector('tbody');
    if(!tbody)return;
    var rows=Array.prototype.slice.call(tbody.querySelectorAll('tr'));

    // Sort rows
    if(sortVal){
        rows.sort(function(a,b){
            var nameA=(a.cells[1]?a.cells[1].textContent.trim():'').toLowerCase();
            var nameB=(b.cells[1]?b.cells[1].textContent.trim():'').toLowerCase();
            var overallA=parseFloat((a.cells[5]?a.cells[5].textContent:'0').replace('%',''))||0;
            var overallB=parseFloat((b.cells[5]?b.cells[5].textContent:'0').replace('%',''))||0;
            var lessonsA=parseInt((a.cells[2]?a.cells[2].textContent:'0').split('/')[0])||0;
            var lessonsB=parseInt((b.cells[2]?b.cells[2].textContent:'0').split('/')[0])||0;
            if(sortVal==='az') return nameA.localeCompare(nameB);
            if(sortVal==='za') return nameB.localeCompare(nameA);
            if(sortVal==='high') return overallB-overallA;
            if(sortVal==='low') return overallA-overallB;
            if(sortVal==='most') return lessonsB-lessonsA;
            if(sortVal==='least') return lessonsA-lessonsB;
            return 0;
        });
        for(var i=0;i<rows.length;i++){tbody.appendChild(rows[i]);}
    }

    // Filter by search query
    var visibleCount=0;
    for(var j=0;j<rows.length;j++){
        var name=rows[j].cells[1]?rows[j].cells[1].textContent.toLowerCase():'';
        if(!query||name.indexOf(query)>-1){rows[j].style.display='';visibleCount++;}
        else{rows[j].style.display='none';}
    }

    // Show/hide empty state
    var emptyPanel=document.getElementById('<%=pnlRankingEmpty.ClientID%>');
    var tablePanel=document.getElementById('<%=pnlTable.ClientID%>');
    if(emptyPanel&&tablePanel){
        if(visibleCount===0&&rows.length>0){emptyPanel.style.display='block';tablePanel.style.display='none';}
        else{emptyPanel.style.display='none';tablePanel.style.display='block';}
    }
}
function spResetFilter(){
    document.getElementById('spSearchInput').value='';
    document.getElementById('<%=ddlSort.ClientID%>').selectedIndex=0;
    spFilterTable();
}
document.addEventListener('DOMContentLoaded',function(){
    var inp=document.getElementById('spSearchInput');
    if(inp){
        inp.addEventListener('keydown',function(e){if(e.key==='Enter'){e.preventDefault();spFilterTable();}});
        inp.addEventListener('input',function(){spFilterTable();});
    }
});
</script>
</asp:Content>
