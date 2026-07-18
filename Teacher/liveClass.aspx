<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="liveClass.aspx.cs"
    Inherits="ScienceBuddy.Teacher.liveClass" MasterPageFile="~/Site.Master"
    Title="Live Class" EnableEventValidation="false" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--tp:#6C63FF;--th:#5A52E0;--tl:#F5F3FF;--tc:#FFF;--tb:#E5E7EB;--tt:#374151;--tm:#6B7280;--te:#EF4444;--ts:#10B981;}
.lc-page-header{display:flex;align-items:center;justify-content:space-between;margin-bottom:1.25rem;flex-wrap:wrap;gap:1rem;}
.lc-page-header h1{font-size:1.4rem;font-weight:800;color:var(--tt);margin:0;}
.lc-badge-live{display:inline-flex;align-items:center;gap:6px;background:#DC2626;color:#fff;padding:4px 12px;border-radius:6px;font-size:.75rem;font-weight:700;animation:lcPulse 1.5s infinite;}
@keyframes lcPulse{0%,100%{opacity:1;}50%{opacity:.6;}}
.lc-btn-end{display:inline-flex;align-items:center;gap:6px;background:#EF4444;border:none;border-radius:10px;padding:.6rem 1.25rem;font-weight:700;font-size:.85rem;color:#fff;cursor:pointer;text-decoration:none;transition:all .2s;}
.lc-btn-end:hover{background:#DC2626;}
.lc-access-denied{display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;padding:4rem 2rem;}
.lc-access-denied i{font-size:3rem;color:var(--tm);opacity:.4;margin-bottom:1rem;}
.lc-access-denied h2{font-size:1.25rem;font-weight:800;color:var(--tt);margin-bottom:.5rem;}
.lc-access-denied p{font-size:.9rem;color:var(--tm);margin-bottom:1.5rem;}
.lc-access-denied a{display:inline-flex;align-items:center;gap:6px;padding:.55rem 1.25rem;border-radius:10px;background:var(--tp);color:#fff;font-size:.84rem;font-weight:700;text-decoration:none;}
/* Summary modal */
.lc-modal-overlay{position:fixed;inset:0;background:rgba(17,24,39,.5);z-index:9000;display:none;align-items:center;justify-content:center;padding:1rem;}
.lc-modal-overlay.open{display:flex;}
.lc-modal{background:#fff;border-radius:20px;width:100%;max-width:520px;box-shadow:0 24px 60px rgba(0,0,0,.18);animation:lcFade .25s ease;}
@keyframes lcFade{from{opacity:0;transform:translateY(12px);}to{opacity:1;transform:translateY(0);}}
.lc-modal-header{text-align:center;padding:2rem 1.75rem 1rem;}
.lc-modal-success-ico{width:64px;height:64px;border-radius:50%;background:#D1FAE5;display:flex;align-items:center;justify-content:center;font-size:1.8rem;color:#059669;margin:0 auto 1rem;}
.lc-modal-header h2{font-size:1.2rem;font-weight:800;color:var(--tt);margin:0 0 .25rem;}
.lc-modal-header .lc-session-name{font-size:.88rem;color:var(--tm);font-weight:500;}
.lc-modal-body{padding:0 1.75rem 1.5rem;}
.lc-summary-stats{display:grid;grid-template-columns:1fr 1fr;gap:.75rem;margin-bottom:1.25rem;}
.lc-stat-card{background:#F9FAFB;border:1.5px solid var(--tb);border-radius:14px;padding:1rem;text-align:center;}
.lc-stat-card i{font-size:1.3rem;color:var(--tp);margin-bottom:.5rem;display:block;}
.lc-stat-val{font-size:1.4rem;font-weight:800;color:var(--tt);line-height:1.2;}
.lc-stat-lbl{font-size:.74rem;color:var(--tm);font-weight:600;margin-top:3px;}
.lc-participants-section{border-top:1px solid var(--tb);padding-top:1rem;}
.lc-participants-title{font-size:.82rem;font-weight:700;color:var(--tt);margin-bottom:.65rem;display:flex;align-items:center;gap:6px;}
.lc-participants-list{max-height:180px;overflow-y:auto;display:flex;flex-direction:column;gap:6px;}
.lc-participants-list::-webkit-scrollbar{width:4px;}.lc-participants-list::-webkit-scrollbar-thumb{background:#DDD6FE;border-radius:4px;}
.lc-participant-item{display:flex;align-items:center;gap:10px;padding:.45rem .6rem;border-radius:10px;background:#F9FAFB;}
.lc-participant-avatar{width:30px;height:30px;border-radius:50%;background:#EDE9FE;color:#7C3AED;display:flex;align-items:center;justify-content:center;font-size:.78rem;font-weight:700;flex-shrink:0;}
.lc-participant-name{font-size:.82rem;font-weight:600;color:var(--tt);}
.lc-empty-participants{text-align:center;padding:1rem;color:var(--tm);font-size:.82rem;}
.lc-modal-footer{padding:1rem 1.75rem 1.75rem;display:flex;justify-content:center;}
.lc-btn-done{background:linear-gradient(135deg,#6C63FF,#5A52E0);border:none;border-radius:12px;padding:.65rem 2rem;font-weight:700;font-size:.9rem;color:#fff;cursor:pointer;box-shadow:0 4px 12px rgba(108,99,255,.2);transition:transform .2s,box-shadow .2s;}
.lc-btn-done:hover{transform:translateY(-2px);box-shadow:0 6px 18px rgba(108,99,255,.28);}
.lc-times{display:grid;grid-template-columns:1fr 1fr;gap:.5rem;margin-bottom:1rem;}
.lc-time-item{font-size:.76rem;color:var(--tm);background:#F9FAFB;border-radius:10px;padding:.5rem .75rem;}
.lc-time-item span{display:block;font-weight:700;color:var(--tt);font-size:.84rem;margin-top:2px;}
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

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Live Class","Kelas Langsung") %></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<asp:Panel ID="pnlDenied" runat="server" Visible="false">
    <div class="lc-access-denied">
        <i class="bi bi-shield-exclamation"></i>
        <h2><%: T("Access Denied","Akses Ditolak") %></h2>
        <p><%: T("This live session does not exist or you do not have permission to access it.","Sesi langsung ini tidak wujud atau anda tidak mempunyai kebenaran untuk mengaksesnya.") %></p>
        <a href="<%: ResolveUrl("~/Teacher/liveSession.aspx") %>"><i class="bi bi-arrow-left"></i> <%: T("Back to Live Sessions","Kembali ke Sesi Langsung") %></a>
    </div>
</asp:Panel>

<asp:Panel ID="pnlLiveRoom" runat="server" Visible="false">
    <div class="lc-page-header">
        <div style="display:flex;align-items:center;gap:12px;">
            <h1><asp:Literal ID="litLiveRoomTitle" runat="server" /></h1>
            <span class="lc-badge-live"><i class="bi bi-broadcast-pin"></i> LIVE</span>
        </div>
        <asp:Button ID="btnEndLive" runat="server" CssClass="lc-btn-end"
            Text="End Live Session" OnClick="btnEndLive_Click" CausesValidation="false" />
    </div>
    <div id="jitsi-container-teacher" style="width:100%; height:600px; border-radius:16px; overflow:hidden;"></div>
    <asp:HiddenField ID="hidLiveRoomName" runat="server" />
    <asp:HiddenField ID="hidLiveDisplayName" runat="server" />
    <asp:HiddenField ID="hidLiveSessionId" runat="server" />
</asp:Panel>

<%-- Live Session Summary Modal removed — summary now shown on LiveSession.aspx --%>

</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script src="https://meet.jit.si/external_api.js"></script>  <%-- embedded live session --%>
<script>
window.addEventListener('load', function () {
    var jc = document.getElementById('jitsi-container-teacher');  <%-- embedded live session --%>
    if (jc) {
        var roomName = document.getElementById('<%= hidLiveRoomName.ClientID %>').value;
        var displayName = document.getElementById('<%= hidLiveDisplayName.ClientID %>').value;
        var api = new JitsiMeetExternalAPI("meet.jit.si", {
            roomName: roomName,
            width: "100%",
            height: 600,
            parentNode: jc,
            userInfo: { displayName: displayName }
        });
    }
});
</script>
</asp:Content>
