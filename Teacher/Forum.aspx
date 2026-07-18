<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Forum.aspx.cs"
    Inherits="ScienceBuddy.Teacher.Forum" MasterPageFile="~/Site.Master" Title="Forum" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ── CSS variables ── */
:root {
    --tp:#6C63FF; --th:#5A52E0; --tl:#F5F3FF;
    --tc:#FFF;    --tb:#E5E7EB; --tt:#374151;
    --tm:#6B7280; --ts:#10B981; --te:#EF4444;
}

/* ── Page header ── */
.fr-header { margin-bottom: 1.75rem; }
.fr-header h1 { font-size: 1.5rem; font-weight: 800; color: var(--tt); margin: 0 0 .25rem; }
.fr-header p  { font-size: .85rem; color: var(--tm); margin: 0; line-height: 1.5; }

/* ── Toolbar ── */
.fr-toolbar {
    display: flex; align-items: center; gap: 10px;
    margin-bottom: 1.5rem; flex-wrap: wrap;
}
/* New Post button comes first */
.fr-new-btn {
    display: inline-flex; align-items: center; gap: 6px;
    height: 40px; padding: 0 1.1rem;
    background: var(--tp); color: #fff;
    border: none; border-radius: 10px;
    font-weight: 700; font-size: .83rem;
    cursor: pointer; white-space: nowrap;
    box-shadow: 0 2px 8px rgba(108,99,255,.18);
    transition: background .2s, box-shadow .2s;
    flex-shrink: 0;
}
.fr-new-btn:hover { background: var(--th); box-shadow: 0 4px 14px rgba(108,99,255,.28); color:#fff; }
/* Search input */
.fr-search-wrap { position: relative; flex: 1; min-width: 200px; max-width: 380px; }
.fr-search {
    width: 100%; height: 40px;
    border-radius: 10px; border: 1.5px solid var(--tb);
    padding: 0 .75rem 0 2.2rem;
    font-size: .83rem; background: var(--tc);
    transition: border-color .2s; box-sizing: border-box;
}
.fr-search:focus { border-color: var(--tp); outline: none; }
.fr-search-icon {
    position: absolute; left: 11px; top: 50%;
    transform: translateY(-50%);
    color: var(--tm); font-size: .85rem; pointer-events: none;
}
/* Search button */
.fr-search-btn {
    height: 40px; padding: 0 .9rem;
    background: var(--tc); border: 1.5px solid var(--tb);
    border-radius: 10px; color: var(--tm);
    font-size: .83rem; font-weight: 600;
    cursor: pointer; display: inline-flex; align-items: center; gap: 5px;
    transition: border-color .2s, color .2s;
    flex-shrink: 0; white-space: nowrap;
}
.fr-search-btn:hover { border-color: var(--tp); color: var(--tp); }

/* ── Cards container ── */
.fr-cards { display: flex; flex-direction: column; gap: 1rem; }

/* ── Forum card ── */
.fr-card {
    background: var(--tc); border: 1.5px solid var(--tb);
    border-radius: 16px; padding: 1.25rem 1.5rem;
    box-shadow: 0 2px 8px rgba(0,0,0,.03);
    transition: box-shadow .2s, transform .2s;
}
.fr-card:hover {
    box-shadow: 0 8px 28px rgba(108,99,255,.1);
    transform: translateY(-2px);
}
/* Role accent strip at bottom of card */
.fr-card{position:relative;overflow:hidden;}
.fr-card::after{content:'';position:absolute;bottom:0;left:0;right:0;height:3px;border-radius:0 0 16px 16px;}
.fr-card.accent-student::after{background:#818CF8;}
.fr-card.accent-parent::after{background:#FBBF24;}
.fr-card.accent-teacher::after{background:#A78BFA;}
.fr-card-top {
    display: flex; align-items: flex-start;
    gap: 12px; margin-bottom: .85rem;
}
.fr-avatar {
    width: 40px; height: 40px; border-radius: 50%;
    background: #EDE9FE; color: var(--tp);
    display: flex; align-items: center; justify-content: center;
    font-size: .82rem; font-weight: 800; flex-shrink: 0;
    border: 2px solid #D8D4FF;
}
.fr-creator-info { flex: 1; min-width: 0; }
.fr-creator-name {
    font-size: .88rem; font-weight: 800; color: var(--tt);
    display: flex; align-items: center; gap: 6px; flex-wrap: wrap;
}
.fr-role-badge {
    font-size: .63rem; font-weight: 700;
    padding: 2px 7px; border-radius: 4px;
    background: #DBEAFE; color: #1D4ED8;
}
.fr-role-badge.teacher { background: #EDE9FE; color: var(--tp); }
.fr-role-badge.student { background: #D1FAE5; color: #047857; }
.fr-role-badge.parent  { background: #FEF3C7; color: #92400E; }
.fr-date {
    font-size: .76rem; color: var(--tm); margin-top: 2px;
    display: flex; align-items: center; gap: 4px;
}
.fr-card-title {
    font-size: 1.02rem; font-weight: 800; color: var(--tt);
    margin-bottom: .35rem; line-height: 1.4;
}
.fr-card-preview {
    font-size: .86rem; color: var(--tm);
    line-height: 1.55; margin-bottom: .85rem;
    display: -webkit-box; -webkit-line-clamp: 2; line-clamp: 2;
    -webkit-box-orient: vertical; overflow: hidden;
}
/* Card footer – left stats, right button */
.fr-card-footer {
    display: flex; align-items: center;
    justify-content: space-between;
    padding-top: .85rem; border-top: 1px solid #F3F4F6;
    flex-wrap: wrap; gap: .5rem;
}
.fr-stats { display: flex; align-items: center; gap: 1rem; }
.fr-stat {
    font-size: .76rem; color: var(--tm);
    display: inline-flex; align-items: center; gap: 4px; font-weight: 600;
}
/* View Discussion button */
.fr-view-btn {
    display: inline-flex; align-items: center; gap: 6px;
    height: 34px; padding: 0 1rem;
    background: #4338CA; color: #fff;
    border: none; border-radius: 9px;
    font-size: .78rem; font-weight: 700;
    text-decoration: none; cursor: pointer;
    transition: background .2s, box-shadow .2s;
    box-shadow: 0 2px 8px rgba(67,56,202,.2);
    flex-shrink: 0;
}
.fr-view-btn:hover {
    background: #3730A3; color: #fff;
    box-shadow: 0 4px 14px rgba(67,56,202,.3);
    text-decoration: none;
}
.fr-view-btn i { font-size: .8rem; }

/* ── Empty states ── */
.fr-empty {
    display: flex; flex-direction: column; align-items: center;
    text-align: center; padding: 3.5rem 2rem;
    background: var(--tc); border: 1.5px dashed var(--tb);
    border-radius: 16px;
}
.fr-empty i { font-size: 2.75rem; color: var(--tm); opacity: .3; margin-bottom: .75rem; }
.fr-empty-title { font-size: .95rem; font-weight: 700; color: var(--tt); margin-bottom: .3rem; }
.fr-empty-sub   { font-size: .83rem; color: var(--tm); margin-bottom: 1.1rem; }
/* DB-empty CTA button */
.fr-empty-cta {
    display: inline-flex; align-items: center; gap: 6px;
    height: 38px; padding: 0 1.1rem;
    background: var(--tp); color: #fff;
    border: none; border-radius: 10px;
    font-size: .83rem; font-weight: 700;
    cursor: pointer; transition: background .2s;
}
.fr-empty-cta:hover { background: var(--th); }
/* Search-no-result reset link */
.fr-reset-link {
    display: inline-flex; align-items: center; gap: 5px;
    font-size: .78rem; font-weight: 600; color: var(--tp);
    background: none; border: none; cursor: pointer; padding: 0;
    text-decoration: underline;
}
.fr-reset-link:hover { color: var(--th); }

/* ── New Post Modal ── */
.fr-modal-overlay {
    position: fixed; inset: 0;
    background: rgba(17,24,39,.55);
    z-index: 9000; display: flex; align-items: center;
    justify-content: center; padding: 1rem;
}
.fr-modal {
    background: #fff; border-radius: 18px;
    width: 100%; max-width: 520px;
    box-shadow: 0 24px 64px rgba(0,0,0,.22);
    animation: frFadeUp .2s ease;
}
@keyframes frFadeUp {
    from { opacity: 0; transform: translateY(12px); }
    to   { opacity: 1; transform: translateY(0); }
}
.fr-modal-header {
    display: flex; align-items: center; justify-content: space-between;
    padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--tb);
}
.fr-modal-header h3 { font-size: 1rem; font-weight: 800; color: var(--tt); margin: 0; }
.fr-modal-close {
    background: none; border: none; font-size: 1.5rem;
    color: var(--tm); cursor: pointer; line-height: 1;
    padding: 0 2px;
}
.fr-modal-close:hover { color: var(--tt); }
.fr-modal-body  { padding: 1.25rem 1.5rem; }
.fr-modal-footer {
    display: flex; gap: .75rem; justify-content: flex-end;
    padding: 1rem 1.5rem; border-top: 1px solid var(--tb);
}
.fr-field       { margin-bottom: 1rem; }
.fr-label       { font-size: .78rem; font-weight: 600; color: var(--tt); display: block; margin-bottom: 4px; }
.fr-input {
    width: 100%; border-radius: 10px; border: 1.5px solid var(--tb);
    padding: .55rem .75rem; font-size: .84rem;
    transition: border-color .2s; box-sizing: border-box; font-family: inherit;
}
.fr-input:focus { border-color: var(--tp); outline: none; }
.fr-modal-val   { font-size: .76rem; color: var(--te); font-weight: 600; margin-top: .3rem; }
.fr-btn-cancel {
    background: var(--tc); border: 1.5px solid var(--tb);
    border-radius: 10px; padding: .55rem 1rem;
    font-weight: 600; font-size: .84rem; color: var(--tt); cursor: pointer;
}
.fr-btn-post {
    display: inline-flex; align-items: center; gap: 6px;
    background: var(--tp); border: none; border-radius: 10px;
    padding: .55rem 1.1rem; font-weight: 700; font-size: .84rem;
    color: #fff; cursor: pointer; transition: background .2s;
}
.fr-btn-post:hover { background: var(--th); }

/* ── Toast ── */
.fr-toast-wrap { position: fixed; top: 1.25rem; right: 1.25rem; z-index: 9999; }
.fr-toast {
    background: var(--ts); color: #fff;
    padding: .7rem 1.1rem; border-radius: 10px;
    font-size: .82rem; font-weight: 600;
    display: flex; align-items: center; gap: 6px;
    box-shadow: 0 6px 18px rgba(16,185,129,.25);
    animation: frFadeUp .3s ease;
}

/* ── Responsive ── */
@media (max-width: 640px) {
    .fr-toolbar { flex-direction: column; align-items: stretch; }
    .fr-search-wrap { max-width: 100%; }
    .fr-new-btn, .fr-search-btn { width: 100%; justify-content: center; }
    .fr-card-footer { flex-direction: column; align-items: flex-start; }
    .fr-view-btn { width: 100%; justify-content: center; }
}
/* ── Pending License Notice ── */
.fr-pending-notice{display:flex;align-items:flex-start;gap:.75rem;padding:.85rem 1.1rem;margin-bottom:1.25rem;background:#FEF2F2;border:1.5px solid #FECACA;border-left:4px solid #DC2626;border-radius:10px;}
.fr-pending-notice-icon{flex-shrink:0;width:32px;height:32px;border-radius:8px;background:#FEE2E2;color:#DC2626;display:flex;align-items:center;justify-content:center;font-size:1rem;}
.fr-pending-notice-content{flex:1;min-width:0;}
.fr-pending-notice-title{font-size:.84rem;font-weight:700;color:#991B1B;margin-bottom:2px;}
.fr-pending-notice-msg{font-size:.78rem;color:#B91C1C;line-height:1.45;}
.fr-new-btn.fr-btn-disabled{opacity:.5;cursor:not-allowed;pointer-events:none;background:#9CA3AF;box-shadow:none;}
.fr-new-btn.fr-btn-disabled:hover{background:#9CA3AF;box-shadow:none;}
</style>
</asp:Content>

<%-- ════ SIDEBAR ════ --%>
<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a></div>
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

<%-- ════ MAIN CONTENT ════ --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">
<asp:HiddenField ID="hidLicenseStatus" runat="server" Value="" />

<%-- Page header --%>
<div style="display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:1.5rem;flex-wrap:wrap;gap:.75rem;">
    <div class="fr-header" style="margin-bottom:0;">
        <h1><i class="bi bi-chat-dots" style="color:var(--tp);font-size:1.3rem;vertical-align:middle;margin-right:.4rem;"></i><%: T("Forum","Forum") %></h1>
        <p><%: T("Join public discussions, answer student questions, and support the ScienceBuddy community.","Sertai perbincangan awam, jawab soalan pelajar, dan sokong komuniti ScienceBuddy.") %></p>
    </div>
</div>

<%-- Toolbar: [Search input]  [Search button] --%>
<div class="fr-toolbar">
    <div class="fr-search-wrap">
        <i class="bi bi-search fr-search-icon"></i>
        <asp:TextBox ID="txtSearch" runat="server" CssClass="fr-search" />
    </div>
    <asp:Button ID="btnSearch" runat="server" CssClass="fr-search-btn"
        OnClick="btnSearch_Click" CausesValidation="false" />
</div>

<%-- Results: db-empty | search-no-result | card list --%>
<asp:Panel ID="pnlDbEmpty" runat="server" Visible="false">
    <div class="fr-empty">
        <i class="bi bi-chat-square-text"></i>
        <div class="fr-empty-title"><%: T("No public forum discussions yet.","Tiada perbincangan forum awam lagi.") %></div>
        <div class="fr-empty-sub"><%: T("Check back later for new discussions.","Semak kemudian untuk perbincangan baharu.") %></div>
    </div>
</asp:Panel>

<asp:Panel ID="pnlSearchEmpty" runat="server" Visible="false">
    <div class="fr-empty">
        <i class="bi bi-search"></i>
        <div class="fr-empty-title"><%: T("No discussions found.","Tiada perbincangan dijumpai.") %></div>
        <div class="fr-empty-sub"><%: T("Try another keyword.","Cuba kata kunci lain.") %></div>
        <asp:Button ID="btnReset" runat="server" CssClass="fr-reset-link"
            OnClick="btnReset_Click" CausesValidation="false" />
    </div>
</asp:Panel>

<asp:Panel ID="pnlList" runat="server" Visible="false">
    <div class="fr-cards">
        <asp:Repeater ID="rptPosts" runat="server">
            <ItemTemplate>
                <div class='fr-card accent-<%# Eval("roleCss") %>'>
                    <div class="fr-card-top">
                        <div class="fr-avatar"><%# Eval("initials") %></div>
                        <div class="fr-creator-info">
                            <div class="fr-creator-name">
                                <%# HttpUtility.HtmlEncode(Eval("creatorName").ToString()) %>
                                <span class='fr-role-badge <%# Eval("roleCss") %>'><%# Eval("roleLabel") %></span>
                            </div>
                            <div class="fr-date"><i class="bi bi-clock"></i> <%# Eval("timeAgo") %></div>
                        </div>
                    </div>
                    <div class="fr-card-title"><%# HttpUtility.HtmlEncode(Eval("title").ToString()) %></div>
                    <div class="fr-card-preview"><%# HttpUtility.HtmlEncode(Eval("msgPreview").ToString()) %></div>
                    <div class="fr-card-footer">
                        <div class="fr-stats">
                            <span class="fr-stat"><i class="bi bi-chat-text"></i> <%# Eval("replyCount") %></span>
                            <span class="fr-stat"><i class="bi bi-heart"></i> <%# Eval("likeCount") %></span>
                        </div>
                        <a href='<%# ResolveUrl("~/Teacher/ForumReply.aspx") + "?forumId=" + Eval("forumId") %>'
                           class="fr-view-btn" onclick="event.stopPropagation();">
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
<div class="fr-toast-wrap" id="frToastWrap"></div>
</asp:Content>

<%-- ════ SCRIPTS ════ --%>
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
        t.className = 'fr-toast';
        t.innerHTML = '<i class="bi bi-check-circle-fill"></i> ' + h.value;
        wrap.appendChild(t);
        h.value = '';
        setTimeout(function () { t.style.opacity = '0'; t.style.transition = 'opacity .3s'; }, 2500);
        setTimeout(function () { if (t.parentNode) t.parentNode.removeChild(t); }, 3000);
    }
});
</script>
</asp:Content>
