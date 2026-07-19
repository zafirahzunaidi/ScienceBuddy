<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="liveClass.aspx.cs"
    Inherits="ScienceBuddy.Teacher.liveClass" MasterPageFile="~/Site.Master"
    Title="Live Class" EnableEventValidation="false" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Teacher.css") %>" rel="stylesheet" />
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label"><%: T("Notifications","Notifikasi") %></span></a></div>
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
    <div class="tc-live-class-access-denied">
        <i class="bi bi-shield-exclamation"></i>
        <h2><%: T("Access Denied","Akses Ditolak") %></h2>
        <p><%: T("This live session does not exist or you do not have permission to access it.","Sesi langsung ini tidak wujud atau anda tidak mempunyai kebenaran untuk mengaksesnya.") %></p>
        <a href="<%: ResolveUrl("~/Teacher/liveSession.aspx") %>"><i class="bi bi-arrow-left"></i> <%: T("Back to Live Sessions","Kembali ke Sesi Langsung") %></a>
    </div>
</asp:Panel>

<asp:Panel ID="pnlLiveRoom" runat="server" Visible="false">
    <div class="tc-live-class-page-header">
        <div style="display:flex;align-items:center;gap:12px;">
            <h1><asp:Literal ID="litLiveRoomTitle" runat="server" /></h1>
            <span class="tc-live-class-badge-live"><i class="bi bi-broadcast-pin"></i> LIVE</span>
        </div>
        <asp:Button ID="btnEndLive" runat="server" CssClass="tc-live-class-btn-end"
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