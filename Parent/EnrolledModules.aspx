<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EnrolledModules.aspx.cs"
    Inherits="ScienceBuddy.Parent.EnrolledModules" MasterPageFile="~/Site.Master"
    Title="Learning Journey" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.em-page { padding:24px 0; }
.em-hero { background:linear-gradient(135deg,#EFF6FF 0%,#F0FDF4 100%); border-radius:20px; padding:28px 32px; margin-bottom:20px; display:flex; align-items:center; gap:20px; flex-wrap:wrap; position:relative; overflow:hidden; }
.em-hero::after { content:''; position:absolute; width:140px; height:140px; border-radius:50%; background:rgba(37,99,235,0.05); top:-40px; right:20px; pointer-events:none; }
.em-hero-icon { width:56px; height:56px; border-radius:16px; background:#DBEAFE; color:#1D4ED8; display:flex; align-items:center; justify-content:center; font-size:1.5rem; flex-shrink:0; }
.em-hero-body { flex:1; }
.em-hero-title { font-size:1.2rem; font-weight:800; color:#1E293B; margin:0 0 4px; }
.em-hero-sub { font-size:0.85rem; color:#64748B; line-height:1.4; }
.em-hero-child { font-size:0.82rem; font-weight:700; color:#2563EB; margin-top:4px; }

/* Summary */
.em-summary { display:grid; grid-template-columns:repeat(4,1fr); gap:12px; margin-bottom:20px; }
@media(max-width:640px){ .em-summary{grid-template-columns:repeat(2,1fr);} }
.em-sum-card { background:#fff; border-radius:14px; padding:16px; text-align:center; box-shadow:0 2px 10px rgba(0,0,0,0.04); }
.em-sum-value { font-size:1.3rem; font-weight:800; color:#1E293B; display:block; }
.em-sum-label { font-size:0.72rem; color:#64748B; margin-top:3px; }

/* Filters */
.em-filters { display:flex; gap:8px; flex-wrap:wrap; align-items:center; margin-bottom:20px; }
.em-filter-btn { border:1.5px solid #E2E8F0; background:#fff; border-radius:999px; padding:7px 14px; font-size:0.78rem; font-weight:700; color:#334155; cursor:pointer; text-decoration:none; display:inline-flex; align-items:center; gap:4px; transition:background 0.15s,border-color 0.15s; }
.em-filter-btn:hover { border-color:#2563EB; color:#2563EB; text-decoration:none; }
.em-filter-btn.active { background:#2563EB; color:#fff; border-color:#2563EB; }
.em-filter-search { border:1.5px solid #E2E8F0; border-radius:10px; padding:7px 12px; font-size:0.8rem; min-width:140px; flex:1; max-width:220px; }
.em-filter-search:focus { border-color:#2563EB; outline:none; }

/* Unit cards */
.em-unit { background:#fff; border-radius:18px; box-shadow:0 2px 14px rgba(0,0,0,0.04); padding:20px 22px; margin-bottom:16px; border-left:4px solid #DBEAFE; }
.em-unit.completed { border-left-color:#A7F3D0; }
.em-unit.inprogress { border-left-color:#93C5FD; }
.em-unit.notstarted { border-left-color:#E2E8F0; }
.em-unit-header { display:flex; align-items:center; justify-content:space-between; gap:10px; margin-bottom:8px; flex-wrap:wrap; }
.em-unit-name { font-size:0.95rem; font-weight:700; color:#1E293B; }
.em-unit-badge { font-size:0.68rem; font-weight:700; padding:3px 10px; border-radius:999px; }
.em-unit-badge.completed { background:#DCFCE7; color:#065F46; }
.em-unit-badge.inprogress { background:#DBEAFE; color:#1D4ED8; }
.em-unit-badge.notstarted { background:#F1F5F9; color:#64748B; }
.em-unit-desc { font-size:0.8rem; color:#64748B; margin-bottom:10px; line-height:1.4; }
.em-unit-bar { height:6px; background:#E2E8F0; border-radius:999px; overflow:hidden; margin-bottom:6px; }
.em-unit-bar-fill { height:100%; border-radius:999px; background:linear-gradient(90deg,#2563EB,#60A5FA); }
.em-unit-stats { font-size:0.75rem; color:#64748B; margin-bottom:10px; display:flex; justify-content:space-between; }
.em-subtopics { padding-left:6px; margin-bottom:8px; }
.em-subtopic { display:flex; align-items:center; gap:6px; padding:4px 0; font-size:0.8rem; color:#334155; }
.em-subtopic i { font-size:0.7rem; }
.em-subtopic i.done { color:#10B981; }
.em-subtopic i.pending { color:#CBD5E1; }
.em-unit-footer { font-size:0.75rem; color:#64748B; border-top:1px solid #F1F5F9; padding-top:8px; margin-top:6px; }

/* unit summary box */
.em-unit-summary { background:#F0F9FF; border-radius:10px; padding:10px 14px; margin-bottom:12px; font-size:0.8rem; color:#334155; line-height:1.5; border-left:3px solid #93C5FD; }
/* subtopic section title */
.em-st-section-title { font-size:0.75rem; font-weight:700; color:#94A3B8; text-transform:uppercase; letter-spacing:0.6px; margin:10px 0 8px; }
/* subtopic row */
.em-st-row { margin-bottom:12px; }
.em-st-header { font-size:0.84rem; font-weight:700; color:#1E293B; display:flex; align-items:center; gap:6px; margin-bottom:6px; }
/* item type label */
.em-item-type { font-size:0.68rem; font-weight:700; color:#94A3B8; text-transform:uppercase; letter-spacing:0.5px; margin:6px 0 3px 18px; display:flex; align-items:center; gap:4px; }
.em-item-type i { font-size:0.72rem; }
.em-item-type.lessons i { color:#2563EB; }
.em-item-type.quizzes i { color:#D97706; }
.em-item-type.materials i { color:#7C3AED; }
/* lesson list */
.em-lesson-list { padding-left:18px; }
.em-lesson-item { display:flex; align-items:center; gap:6px; padding:3px 0; font-size:0.78rem; color:#475569; }
.em-lesson-item i.done { color:#10B981; font-size:0.72rem; }
.em-lesson-item i.pending { color:#CBD5E1; font-size:0.72rem; }

/* Empty */
.em-empty { text-align:center; padding:32px 20px; color:#94A3B8; }
.em-empty i { font-size:2.5rem; color:#CBD5E1; display:block; margin-bottom:10px; }

/* ── Journey Map ───────────────────────────────────────── */
.em-journey { background:#fff; border-radius:18px; box-shadow:0 2px 12px rgba(0,0,0,0.04); padding:22px 24px 18px; margin-bottom:22px; }
.em-journey-title { font-size:0.82rem; font-weight:700; color:#94A3B8; text-transform:uppercase; letter-spacing:0.8px; margin-bottom:16px; }
.em-journey-path { display:grid; grid-template-columns:repeat(auto-fit, minmax(150px, 1fr)); gap:16px; align-items:stretch; }
/* unit card node */
.em-jnode { display:flex; flex-direction:column; }
.em-jcard { flex:1; background:#F8FAFC; border:2px solid #E2E8F0; border-radius:16px; padding:14px 12px 12px; text-align:center; transition:box-shadow 0.2s; display:flex; flex-direction:column; align-items:center; justify-content:center; }
.em-jcard:hover { box-shadow:0 4px 14px rgba(0,0,0,0.06); }
.em-jcard.completed { background:#F0FDF4; border-color:#86EFAC; }
.em-jcard.inprogress { background:#EFF6FF; border-color:#93C5FD; box-shadow:0 0 0 3px rgba(37,99,235,0.08); }
.em-jcard.notstarted { background:#FAFAFA; border-color:#E2E8F0; }
.em-jcard-icon { font-size:1.3rem; margin-bottom:4px; display:block; }
.em-jcard-num { font-size:0.65rem; font-weight:700; color:#94A3B8; text-transform:uppercase; letter-spacing:0.5px; margin-bottom:2px; }
.em-jcard-name { font-size:0.78rem; font-weight:700; color:#1E293B; line-height:1.3; min-height:2.2em; display:flex; align-items:center; justify-content:center; margin-bottom:6px; word-break:break-word; text-align:center; }
.em-jcard-badge { display:inline-block; font-size:0.62rem; font-weight:700; padding:2px 8px; border-radius:999px; margin-bottom:4px; }
.em-jcard-badge.completed { background:#DCFCE7; color:#065F46; }
.em-jcard-badge.inprogress { background:#DBEAFE; color:#1D4ED8; }
.em-jcard-badge.notstarted { background:#F1F5F9; color:#64748B; }
.em-jcard-pct { font-size:0.72rem; font-weight:800; color:#334155; }
</style>
</asp:Content>

<%-- ════ SIDEBAR ════ --%>
<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <%-- Child Switcher --%>
    <div style="padding:10px 16px 6px; font-size:0.72rem; color:#94A3B8; text-transform:uppercase; letter-spacing:1px; font-weight:700;">
        <%: T("Viewing Child","Anak Dilihat") %>
    </div>
    <div style="padding:0 16px 14px;">
        <asp:DropDownList ID="ddlSidebarChild" runat="server"
            AutoPostBack="true" OnSelectedIndexChanged="SidebarChildChanged"
            style="width:100%;border:1.5px solid #E2E8F0;border-radius:10px;padding:8px 12px;font-size:0.82rem;font-weight:600;color:#1D4ED8;background:#EFF6FF;" />
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentDashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("My Children","Anak Saya") %></div>
        <a href="<%: ResolveUrl("~/Parent/LinkChildAccount.aspx") %>" class="sb-sidebar-item"><i class="bi bi-link-45deg item-icon"></i><span class="item-label"><%: T("Link Child Account","Paut Akaun Anak") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/ChildProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-badge item-icon"></i><span class="item-label"><%: T("Child Profile","Profil Anak") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/EnrolledModules.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-journal-bookmark item-icon"></i><span class="item-label"><%: T("Learning Journey","Perjalanan Pembelajaran") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Child Performance","Prestasi Anak") %></div>
        <a href="<%: ResolveUrl("~/Parent/ChildProgress.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bar-chart-line item-icon"></i><span class="item-label"><%: T("Current Progress","Kemajuan Semasa") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/QuizResults.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-check item-icon"></i><span class="item-label"><%: T("Quiz Results","Keputusan Kuiz") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/ReportCard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-file-earmark-bar-graph item-icon"></i><span class="item-label"><%: T("Report Card","Kad Laporan") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Study Plan","Pelan Pembelajaran") %></div>
        <a href="<%: ResolveUrl("~/Parent/StudyPlan.aspx") %>" class="sb-sidebar-item"><i class="bi bi-journal-check item-icon"></i><span class="item-label"><%: T("Study Plan","Pelan Pembelajaran") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/EditStudyPlan.aspx") %>" class="sb-sidebar-item"><i class="bi bi-journal-pen item-icon"></i><span class="item-label"><%: T("Edit Study Plan","Edit Pelan Pembelajaran") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Discussions","Perbincangan") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentTeacherCommunication.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Chat with Teachers","Sembang dengan Guru") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/Forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-people item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Notifications","Notifikasi") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentNotifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label"><%: T("Notifications","Notifikasi") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Profile","Profil") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("Edit Profile","Edit Profil") %></span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Logout","Log Keluar") %></span></a></div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Learning Journey","Perjalanan Pembelajaran") %></asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="em-page">

    <asp:Panel ID="pnlNoChild" runat="server" Visible="false">
        <div class="em-empty"><i class="bi bi-person-x-fill"></i><p><asp:Literal ID="litNoChild" runat="server" /></p></div>
    </asp:Panel>

    <asp:Panel ID="pnlContent" runat="server" Visible="false">

        <%-- Hero --%>
        <div class="em-hero">
            <div class="em-hero-icon"><i class="bi bi-rocket-takeoff-fill"></i></div>
            <div class="em-hero-body">
                <div class="em-hero-title"><asp:Literal ID="litHeroTitle" runat="server" /></div>
                <div class="em-hero-sub"><asp:Literal ID="litHeroSub" runat="server" /></div>
                <div class="em-hero-child"><i class="bi bi-person-fill"></i> <asp:Literal ID="litHeroChild" runat="server" /></div>
            </div>
        </div>

        <%-- Summary --%>
        <div class="em-summary">
            <div class="em-sum-card"><span class="em-sum-value"><asp:Literal ID="litSumUnits" runat="server" /></span><span class="em-sum-label"><asp:Literal ID="litSumUnitsLabel" runat="server" /></span></div>
            <div class="em-sum-card"><span class="em-sum-value"><asp:Literal ID="litSumLessons" runat="server" /></span><span class="em-sum-label"><asp:Literal ID="litSumLessonsLabel" runat="server" /></span></div>
            <div class="em-sum-card"><span class="em-sum-value"><asp:Literal ID="litSumCompleted" runat="server" /></span><span class="em-sum-label"><asp:Literal ID="litSumCompletedLabel" runat="server" /></span></div>
            <div class="em-sum-card"><span class="em-sum-value"><asp:Literal ID="litSumProgress" runat="server" /></span><span class="em-sum-label"><asp:Literal ID="litSumProgressLabel" runat="server" /></span></div>
        </div>

        <%-- Filters --%>
        <div class="em-filters">
            <asp:LinkButton ID="lnkAll" runat="server" CssClass="em-filter-btn active" OnClick="Filter_Click" CommandArgument="All" CausesValidation="false"><%: T("All","Semua") %></asp:LinkButton>
            <asp:LinkButton ID="lnkInProgress" runat="server" CssClass="em-filter-btn" OnClick="Filter_Click" CommandArgument="InProgress" CausesValidation="false"><%: T("In Progress","Sedang Belajar") %></asp:LinkButton>
            <asp:LinkButton ID="lnkCompleted" runat="server" CssClass="em-filter-btn" OnClick="Filter_Click" CommandArgument="Completed" CausesValidation="false"><%: T("Completed","Selesai") %></asp:LinkButton>
            <asp:LinkButton ID="lnkNotStarted" runat="server" CssClass="em-filter-btn" OnClick="Filter_Click" CommandArgument="NotStarted" CausesValidation="false"><%: T("Not Started","Belum Mula") %></asp:LinkButton>
            <asp:TextBox ID="txtSearch" runat="server" CssClass="em-filter-search" AutoPostBack="true" OnTextChanged="Search_Changed" placeholder="Search" />
        </div>

        <%-- Journey Map --%>
        <asp:Panel ID="pnlJourneyMap" runat="server"></asp:Panel>

        <%-- Unit list --%>
        <asp:Panel ID="pnlUnits" runat="server"></asp:Panel>
        <asp:Panel ID="pnlNoUnits" runat="server" Visible="false">
            <div class="em-empty"><i class="bi bi-journal-x"></i><p><asp:Literal ID="litNoUnits" runat="server" /></p></div>
        </asp:Panel>

    </asp:Panel>

</div>
</asp:Content>
