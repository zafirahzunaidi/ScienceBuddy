<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Forum.aspx.cs"
    Inherits="ScienceBuddy.Teacher.Forum" MasterPageFile="~/Site.Master" Title="Forum" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Teacher.css") %>" rel="stylesheet" />
</asp:Content>

<%-- ---- SIDEBAR ---- --%>
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
        <a href="<%: ResolveUrl("~/Teacher/Forum.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/privateMessages.aspx") %>" class="sb-sidebar-item"><i class="bi bi-envelope item-icon"></i><span class="item-label"><%: T("Private Message","Mesej Peribadi") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Account","Akaun") %></div>
        <a href="<%: ResolveUrl("~/Teacher/MyProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("My Profile","Profil Saya") %></span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Sign Out","Log Keluar") %></span></a></div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Forum","Forum") %></asp:Content>

<%-- ---- MAIN CONTENT ---- --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">
<asp:HiddenField ID="hidLicenseStatus" runat="server" Value="" />

<%-- Page header --%>
<div style="display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:1.5rem;flex-wrap:wrap;gap:.75rem;">
    <div class="tc-forum-header" style="margin-bottom:0;">
        <h1><i class="bi bi-chat-dots" style="color:var(--tp);font-size:1.3rem;vertical-align:middle;margin-right:.4rem;"></i><%: T("Forum","Forum") %></h1>
        <p><%: T("Join public discussions, answer student questions, and support the ScienceBuddy community.","Sertai perbincangan awam, jawab soalan pelajar, dan sokong komuniti ScienceBuddy.") %></p>
    </div>
</div>

<%-- Toolbar: [Search input]  [Search button] --%>
<div class="tc-forum-toolbar">
    <div class="tc-forum-search-wrap">
        <i class="bi bi-search tc-forum-search-icon"></i>
        <asp:TextBox ID="txtSearch" runat="server" CssClass="tc-forum-search" />
    </div>
    <asp:Button ID="btnSearch" runat="server" CssClass="tc-forum-search-btn"
        OnClick="btnSearch_Click" CausesValidation="false" />
</div>

<%-- Results: db-empty | search-no-result | card list --%>
<asp:Panel ID="pnlDbEmpty" runat="server" Visible="false">
    <div class="tc-forum-empty">
        <i class="bi bi-chat-square-text"></i>
        <div class="tc-forum-empty-title"><%: T("No public forum discussions yet.","Tiada perbincangan forum awam lagi.") %></div>
        <div class="tc-forum-empty-sub"><%: T("Check back later for new discussions.","Semak kemudian untuk perbincangan baharu.") %></div>
    </div>
</asp:Panel>

<asp:Panel ID="pnlSearchEmpty" runat="server" Visible="false">
    <div class="tc-forum-empty">
        <i class="bi bi-search"></i>
        <div class="tc-forum-empty-title"><%: T("No discussions found.","Tiada perbincangan dijumpai.") %></div>
        <div class="tc-forum-empty-sub"><%: T("Try another keyword.","Cuba kata kunci lain.") %></div>
        <asp:Button ID="btnReset" runat="server" CssClass="tc-forum-reset-link"
            OnClick="btnReset_Click" CausesValidation="false" />
    </div>
</asp:Panel>

<asp:Panel ID="pnlList" runat="server" Visible="false">
    <div class="tc-forum-cards">
        <asp:Repeater ID="rptPosts" runat="server">
            <ItemTemplate>
                <div class='tc-forum-card accent-<%# Eval("roleCss") %>'>
                    <div class="tc-forum-card-top">
                        <div class="tc-forum-avatar"><%# Eval("initials") %></div>
                        <div class="tc-forum-creator-info">
                            <div class="tc-forum-creator-name">
                                <%# HttpUtility.HtmlEncode(Eval("creatorName").ToString()) %>
                                <span class='tc-forum-role-badge <%# Eval("roleCss") %>'><%# Eval("roleLabel") %></span>
                            </div>
                            <div class="tc-forum-date"><i class="bi bi-clock"></i> <%# Eval("timeAgo") %></div>
                        </div>
                    </div>
                    <div class="tc-forum-card-title"><%# HttpUtility.HtmlEncode(Eval("title").ToString()) %></div>
                    <div class="tc-forum-card-preview"><%# HttpUtility.HtmlEncode(Eval("msgPreview").ToString()) %></div>
                    <div class="tc-forum-card-footer">
                        <div class="tc-forum-stats">
                            <span class="tc-forum-stat"><i class="bi bi-chat-text"></i> <%# Eval("replyCount") %></span>
                            <span class="tc-forum-stat"><i class="bi bi-heart"></i> <%# Eval("likeCount") %></span>
                        </div>
                        <a href='<%# ResolveUrl("~/Teacher/ForumReply.aspx") + "?forumId=" + Eval("forumId") %>'
                           class="tc-forum-view-btn" onclick="event.stopPropagation();">
                            <%: T("View Discussion","Lihat Perbincangan") %> <i class="bi bi-arrow-right"></i>
                        </a>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>

<%-- Hidden controls (retained for code-behind compatibility) --%>
<asp:TextBox ID="txtTitle" runat="server" Visible="false" />
<asp:TextBox ID="txtMessage" runat="server" Visible="false" />
<asp:Panel ID="pnlModalVal" runat="server" Visible="false"><asp:Literal ID="litModalVal" runat="server" /></asp:Panel>
<asp:Button ID="btnPost" runat="server" OnClick="btnPost_Click" CausesValidation="false" Visible="false" />

<asp:HiddenField ID="hidToast"     runat="server" Value="" />
<asp:HiddenField ID="hidShowModal" runat="server" Value="" />
<div class="tc-forum-toast-wrap" id="frToastWrap"></div>
</asp:Content>

<%-- ---- SCRIPTS ---- --%>
<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
// Search on Enter key
document.addEventListener('DOMContentLoaded', function () {
    var txt = document.getElementById('<%=txtSearch.ClientID%>');
    if (txt) {
        txt.addEventListener('keydown', function (e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                document.getElementById('<%=btnSearch.ClientID%>').click();
            }
        });
    }
});

window.addEventListener('load', function () {
    // Toast
    var h = document.getElementById('<%=hidToast.ClientID%>');
    if (h && h.value) {
        var wrap = document.getElementById('frToastWrap');
        var t = document.createElement('div');
        t.className = 'tc-forum-toast';
        t.innerHTML = '<i class="bi bi-check-circle-fill"></i> ' + h.value;
        wrap.appendChild(t);
        h.value = '';
        setTimeout(function () { t.style.opacity = '0'; t.style.transition = 'opacity .3s'; }, 2500);
        setTimeout(function () { if (t.parentNode) t.parentNode.removeChild(t); }, 3000);
    }
});
</script>
</asp:Content>
