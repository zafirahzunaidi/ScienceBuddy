<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EnrolledModules.aspx.cs"
    Inherits="ScienceBuddy.Parent.EnrolledModules" MasterPageFile="~/Site.Master"
    Title="Learning Journey" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Parent.css") %>" rel="stylesheet" />
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
        <a href="<%: ResolveUrl("~/Parent/ParentDashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/ParentNotifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label"><%: T("Notifications","Notifikasi") %></span><asp:Literal ID="litUnreadBadge" runat="server" /></a></div>
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
        <a href="<%: ResolveUrl("~/Parent/EditStudyPlan.aspx") %>" class="sb-sidebar-item"><i class="bi bi-pencil-square item-icon"></i><span class="item-label"><%: T("Edit Study Plan","Edit Pelan Pembelajaran") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Discussions","Perbincangan") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentTeacherCommunication.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Chat with Teachers","Sembang dengan Guru") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/Forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-people item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a></div>
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
        <div class="pt-stat-grid">
            <div class="pt-stat-card">
                <div class="pt-stat-icon" style="color:#2563EB;"><i class="bi bi-journal-bookmark-fill"></i></div>
                <div class="pt-stat-number"><asp:Literal ID="litSumUnits" runat="server" /></div>
                <div class="pt-stat-label"><asp:Literal ID="litSumUnitsLabel" runat="server" /></div>
            </div>
            <div class="pt-stat-card">
                <div class="pt-stat-icon" style="color:#7C3AED;"><i class="bi bi-file-earmark-text-fill"></i></div>
                <div class="pt-stat-number"><asp:Literal ID="litSumLessons" runat="server" /></div>
                <div class="pt-stat-label"><asp:Literal ID="litSumLessonsLabel" runat="server" /></div>
            </div>
            <div class="pt-stat-card">
                <div class="pt-stat-icon" style="color:#16A34A;"><i class="bi bi-check2-square"></i></div>
                <div class="pt-stat-number"><asp:Literal ID="litSumCompleted" runat="server" /></div>
                <div class="pt-stat-label"><asp:Literal ID="litSumCompletedLabel" runat="server" /></div>
            </div>
            <div class="pt-stat-card">
                <div class="pt-stat-icon" style="color:#F59E0B;"><i class="bi bi-pie-chart-fill"></i></div>
                <div class="pt-stat-number"><asp:Literal ID="litSumProgress" runat="server" /></div>
                <div class="pt-stat-label"><asp:Literal ID="litSumProgressLabel" runat="server" /></div>
            </div>
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
