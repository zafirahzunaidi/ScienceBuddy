<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Notifications.aspx.cs"
    Inherits="ScienceBuddy.Teacher.Notifications" MasterPageFile="~/Site.Master" Title="Notifications" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--tp:#6C63FF;--tp2:#8B5CF6;--th:#5A52E0;--tl:#F5F3FF;--tc:#FFF;--tb:#E5E7EB;--tt:#374151;--tm:#6B7280;--ts:#10B981;--te:#EF4444;}
.nt-header{margin-bottom:1.5rem;}.nt-header h1{font-size:1.5rem;font-weight:800;color:var(--tt);margin:0;}.nt-header p{font-size:.85rem;color:var(--tm);margin:.3rem 0 0;}
.nt-tabs{display:flex;gap:0;border:1.5px solid var(--tb);border-radius:12px;overflow:hidden;width:fit-content;margin-bottom:1.75rem;box-shadow:0 1px 4px rgba(0,0,0,.03);}
.nt-tab{padding:.55rem 1.1rem;font-size:.82rem;font-weight:600;border:none;background:var(--tc);color:var(--tm);cursor:pointer;transition:all .2s;display:inline-flex;align-items:center;gap:8px;text-decoration:none;}
.nt-tab.active{background:linear-gradient(135deg,var(--tp),var(--tp2));color:#fff;}
.nt-tab:hover:not(.active){background:var(--tl);}
.nt-tab-count{display:inline-flex;align-items:center;justify-content:center;min-width:22px;height:22px;padding:0 7px;border-radius:11px;font-size:.7rem;font-weight:700;background:rgba(108,99,255,.1);color:var(--tp);}
.nt-tab.active .nt-tab-count{background:rgba(255,255,255,.25);color:#fff;}
.nt-list{display:flex;flex-direction:column;gap:.75rem;}
.nt-card{display:flex;align-items:flex-start;gap:14px;padding:1rem 1.25rem;border-radius:14px;border:1.5px solid var(--tb);background:var(--tc);transition:all .2s;box-shadow:0 1px 4px rgba(0,0,0,.02);}
.nt-card:hover{box-shadow:0 4px 14px rgba(108,99,255,.06);transform:translateY(-1px);}
.nt-card.unread{background:var(--tl);border-left:4px solid var(--tp);}
.nt-card-icon{width:38px;height:38px;border-radius:10px;background:#EDE9FE;color:var(--tp);display:flex;align-items:center;justify-content:center;font-size:1.1rem;flex-shrink:0;}
.nt-card-body{flex:1;min-width:0;}
.nt-card-title{font-size:.88rem;font-weight:700;color:var(--tt);margin-bottom:3px;display:flex;align-items:center;gap:8px;}
.nt-card-msg{font-size:.82rem;color:var(--tm);line-height:1.5;}
.nt-card-time{font-size:.72rem;color:var(--tm);margin-top:6px;display:flex;align-items:center;gap:4px;}
.nt-dot{width:8px;height:8px;border-radius:50%;background:var(--tp);flex-shrink:0;}
.nt-mark-btn{font-size:.74rem;font-weight:700;color:var(--tp);background:var(--tc);border:1.5px solid #EDE9FE;border-radius:8px;padding:5px 12px;cursor:pointer;transition:all .15s;white-space:nowrap;text-decoration:none;display:inline-flex;align-items:center;gap:4px;flex-shrink:0;}
.nt-mark-btn:hover{background:var(--tl);border-color:var(--tp);}
.nt-empty{display:flex;flex-direction:column;align-items:center;padding:4rem 2rem;text-align:center;}
.nt-empty-icon{width:80px;height:80px;border-radius:50%;background:#D1FAE5;display:flex;align-items:center;justify-content:center;margin-bottom:1.25rem;}
.nt-empty-icon i{font-size:2rem;color:#15803D;}
.nt-empty-title{font-size:1.1rem;font-weight:800;color:#15803D;margin-bottom:.35rem;}
.nt-empty-sub{font-size:.88rem;color:var(--tm);margin-bottom:.25rem;}
.nt-empty-caption{font-size:.78rem;color:var(--tm);opacity:.7;}
.nt-toast-wrap{position:fixed;top:1.25rem;right:1.25rem;z-index:9999;}
.nt-toast{background:var(--ts);color:#fff;padding:.65rem 1.1rem;border-radius:10px;font-size:.82rem;font-weight:600;display:flex;align-items:center;gap:6px;box-shadow:0 6px 18px rgba(16,185,129,.25);animation:ntSlide .3s ease;}
@keyframes ntSlide{from{opacity:0;transform:translateX(20px);}to{opacity:1;transform:translateX(0);}}
</style>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Teaching","Pengajaran") %></div>
        <a href="<%: ResolveUrl("~/Teacher/manageMaterials.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label"><%: T("Manage Materials","Bahan Pembelajaran") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label"><%: T("Manage Quiz","Kuiz") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/studentProgress.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bar-chart item-icon"></i><span class="item-label"><%: T("Student Progress","Prestasi Pelajar") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/liveSession.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label"><%: T("Schedule Live Class","Kelas Langsung") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Community","Komuniti") %></div>
        <a href="<%: ResolveUrl("~/Teacher/forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/privateMessages.aspx") %>" class="sb-sidebar-item"><i class="bi bi-envelope item-icon"></i><span class="item-label"><%: T("Private Message","Mesej Peribadi") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Account","Akaun") %></div>
        <a href="<%: ResolveUrl("~/Teacher/MyProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("My Profile","Profil Saya") %></span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Sign Out","Log Keluar") %></span></a></div>
</asp:Content>
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Notifications","Pemberitahuan") %></asp:Content>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<div class="nt-header"><h1><%: T("Notifications","Pemberitahuan") %></h1><p><%: T("Stay updated with your latest ScienceBuddy activities.","Kekal dikemas kini dengan aktiviti ScienceBuddy terkini anda.") %></p></div>

<%-- Segmented Tabs with counts --%>
<div class="nt-tabs">
    <asp:LinkButton ID="btnTabAll" runat="server" CssClass="nt-tab active" OnClick="btnTab_Click" CommandArgument="All" CausesValidation="false">
        <%: T("All","Semua") %> <span class="nt-tab-count"><asp:Literal ID="litCountAll" runat="server" Text="0" /></span>
    </asp:LinkButton>
    <asp:LinkButton ID="btnTabUnread" runat="server" CssClass="nt-tab" OnClick="btnTab_Click" CommandArgument="Unread" CausesValidation="false">
        <%: T("Unread","Belum Dibaca") %> <span class="nt-tab-count"><asp:Literal ID="litCountUnread" runat="server" Text="0" /></span>
    </asp:LinkButton>
    <asp:LinkButton ID="btnTabRead" runat="server" CssClass="nt-tab" OnClick="btnTab_Click" CommandArgument="Read" CausesValidation="false">
        <%: T("Read","Dibaca") %> <span class="nt-tab-count"><asp:Literal ID="litCountRead" runat="server" Text="0" /></span>
    </asp:LinkButton>
</div>

<%-- Notification List --%>
<asp:Panel ID="pnlList" runat="server" Visible="false">
    <div class="nt-list">
        <asp:Repeater ID="rptNotifs" runat="server" OnItemCommand="rptNotifs_ItemCommand">
            <ItemTemplate>
                <div class='nt-card <%# Convert.ToBoolean(Eval("isRead")) ? "" : "unread" %>'>
                    <div class="nt-card-icon"><i class="bi bi-bell-fill"></i></div>
                    <div class="nt-card-body">
                        <div class="nt-card-title"><%# !Convert.ToBoolean(Eval("isRead")) ? "<span class='nt-dot'></span>" : "" %><%# HttpUtility.HtmlEncode(Eval("title")) %></div>
                        <div class="nt-card-msg"><%# HttpUtility.HtmlEncode(Eval("message")) %></div>
                        <div class="nt-card-time"><i class="bi bi-clock"></i> <%# Eval("timeDisplay") %></div>
                    </div>
                    <asp:LinkButton ID="btnMark" runat="server" CommandName="MarkRead" CommandArgument='<%# Eval("notificationId") %>'
                        CssClass="nt-mark-btn" CausesValidation="false" Visible='<%# !Convert.ToBoolean(Eval("isRead")) %>'>
                        <i class="bi bi-check2"></i> <%# CurrentLanguage=="BM"?"Tandai Dibaca":"Mark as Read" %>
                    </asp:LinkButton>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>

<%-- Empty State --%>
<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="nt-empty">
        <div class="nt-empty-icon"><i class="bi bi-check-lg"></i></div>
        <div class="nt-empty-title"><%: T("You're all caught up!","Anda sudah dikemas kini!") %></div>
        <div class="nt-empty-sub"><%: T("There are no notifications yet.","Tiada pemberitahuan lagi.") %></div>
        <div class="nt-empty-caption"><%: T("We'll notify you whenever there's something new.","Kami akan memberitahu anda apabila ada sesuatu yang baharu.") %></div>
    </div>
</asp:Panel>

<asp:HiddenField ID="hidToast" runat="server" Value="" />
<div class="nt-toast-wrap" id="ntToastWrap"></div>
</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
window.addEventListener('load',function(){
    var h=document.getElementById('<%=hidToast.ClientID%>');
    if(h&&h.value){
        var w=document.getElementById('ntToastWrap'),t=document.createElement('div');
        t.className='nt-toast';t.innerHTML='<i class="bi bi-check-circle-fill"></i> '+h.value;
        w.appendChild(t);h.value='';
        setTimeout(function(){t.style.opacity='0';t.style.transition='opacity .3s';},2e3);
        setTimeout(function(){t.remove();},2500);
    }
});
</script>
</asp:Content>
