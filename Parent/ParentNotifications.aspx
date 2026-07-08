<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ParentNotifications.aspx.cs"
    Inherits="ScienceBuddy.Parent.ParentNotifications" MasterPageFile="~/Site.Master"
    Title="Notifications" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Parent.css") %>" rel="stylesheet" />
</asp:Content>

<%-- ════ SIDEBAR ════ --%>
<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div style="padding:10px 16px 6px; font-size:0.72rem; color:#94A3B8; text-transform:uppercase; letter-spacing:1px; font-weight:700;"><%: T("Viewing Child","Anak Dilihat") %></div>
    <div style="padding:0 16px 14px;"><asp:DropDownList ID="ddlSidebarChild" runat="server" AutoPostBack="true" OnSelectedIndexChanged="SidebarChildChanged" CssClass="sb-sidebar-child-ddl" /></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentDashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("My Children","Anak Saya") %></div>
        <a href="<%: ResolveUrl("~/Parent/LinkChildAccount.aspx") %>" class="sb-sidebar-item"><i class="bi bi-link-45deg item-icon"></i><span class="item-label"><%: T("Link Child Account","Paut Akaun Anak") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/ChildProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-badge item-icon"></i><span class="item-label"><%: T("Child Profile","Profil Anak") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/EnrolledModules.aspx") %>" class="sb-sidebar-item"><i class="bi bi-journal-bookmark item-icon"></i><span class="item-label"><%: T("Learning Journey","Perjalanan Pembelajaran") %></span></a></div>
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
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Notifications","Notifikasi") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentNotifications.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-bell item-icon"></i><span class="item-label"><%: T("Notifications","Notifikasi") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Profile","Profil") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("Edit Profile","Edit Profil") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/AccountSettings.aspx") %>" class="sb-sidebar-item"><i class="bi bi-gear item-icon"></i><span class="item-label"><%: T("Account Settings","Tetapan Akaun") %></span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Logout","Log Keluar") %></span></a></div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Notifications","Notifikasi") %></asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="pd-page">

    <%-- No Child --%>
    <asp:Panel ID="pnlNoChild" runat="server" Visible="false">
        <div class="pd-empty"><i class="bi bi-person-x-fill"></i><p><asp:Literal ID="litNoChildMsg" runat="server" /></p></div>
    </asp:Panel>

    <asp:Panel ID="pnlContent" runat="server" Visible="false">

        <%-- ══ HEADER ══ --%>
        <div class="pt-progress-hero" style="margin-bottom:20px;">
            <div class="pt-progress-hero-body">
                <h2 class="pt-progress-hero-title"><i class="bi bi-bell-fill"></i> <%: T("Notifications","Notifikasi") %></h2>
                <p class="pt-progress-hero-sub"><%: T("Stay updated on your child's learning journey.","Kekal dikemas kini tentang perjalanan pembelajaran anak anda.") %></p>
            </div>
        </div>

        <%-- ══ SINCE YOUR LAST VISIT ══ --%>
        <div class="pt-since-visit-card">
            <div class="pt-since-visit-title"><i class="bi bi-stars"></i> <%: T("Since Your Last Visit","Sejak Lawatan Terakhir Anda") %></div>
            <asp:Panel ID="pnlSinceVisit" runat="server"></asp:Panel>
            <asp:Panel ID="pnlAllCaughtUp" runat="server" Visible="false">
                <div class="pt-caught-up"><i class="bi bi-check-circle-fill"></i> <%: T("You're all caught up!","Anda sudah kemas kini!") %></div>
            </asp:Panel>
        </div>

        <%-- ══ FILTERS ══ --%>
        <div class="pt-filter-row" style="margin-bottom:16px;">
            <asp:TextBox ID="txtSearch" runat="server" CssClass="pt-filter-search" placeholder="Search..." AutoPostBack="true" OnTextChanged="Filter_Changed" />
            <asp:LinkButton ID="lnkAll" runat="server" CssClass="pt-filter-chip active" OnClick="Filter_Changed" CommandArgument="All" CausesValidation="false"><%: T("All","Semua") %></asp:LinkButton>
            <asp:LinkButton ID="lnkRead" runat="server" CssClass="pt-filter-chip" OnClick="Filter_Changed" CommandArgument="Read" CausesValidation="false"><%: T("Read","Dibaca") %></asp:LinkButton>
            <asp:LinkButton ID="lnkUnread" runat="server" CssClass="pt-filter-chip" OnClick="Filter_Changed" CommandArgument="Unread" CausesValidation="false"><%: T("Unread","Belum Dibaca") %></asp:LinkButton>
        </div>

        <%-- Mark All as Read + Sort Order --%>
        <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:12px;flex-wrap:wrap;gap:8px;">
            <div style="display:flex;align-items:center;gap:12px;">
                <asp:LinkButton ID="lnkSortLatest" runat="server" CssClass="pt-sort-btn active" OnClick="LnkSortLatest_Click" CausesValidation="false">
                    <i class="bi bi-sort-down"></i> <%: T("Latest","Terkini") %>
                </asp:LinkButton>
                <asp:LinkButton ID="lnkSortOldest" runat="server" CssClass="pt-sort-btn" OnClick="LnkSortOldest_Click" CausesValidation="false">
                    <i class="bi bi-sort-up"></i> <%: T("Oldest","Terlama") %>
                </asp:LinkButton>
            </div>
            <asp:LinkButton ID="lnkMarkAllRead" runat="server" CssClass="pt-mark-all-read" OnClick="LnkMarkAllRead_Click" CausesValidation="false">
                <i class="bi bi-check2-all"></i> <%: T("Mark all as read","Tandai semua dibaca") %>
            </asp:LinkButton>
        </div>

        <%-- ══ NOTIFICATION FEED ══ --%>
        <asp:Panel ID="pnlFeed" runat="server"></asp:Panel>
        <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
            <div class="pt-empty-notif"><i class="bi bi-bell-slash"></i><p><asp:Literal ID="litEmptyMsg" runat="server" /></p></div>
        </asp:Panel>

        <%-- Hidden for mark-read single --%>
        <asp:HiddenField ID="hidMarkReadId" runat="server" />
        <asp:Button ID="btnMarkRead" runat="server" CssClass="d-none" OnClick="BtnMarkRead_Click" CausesValidation="false" />

    </asp:Panel>
</div>
</asp:Content>
