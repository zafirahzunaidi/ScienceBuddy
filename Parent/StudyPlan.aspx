<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StudyPlan.aspx.cs"
    Inherits="ScienceBuddy.Parent.StudyPlan" MasterPageFile="~/Site.Master"
    Title="Study Plan" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Parent.css") %>" rel="stylesheet" />
</asp:Content>

<%-- ════ SIDEBAR ════ --%>
<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div style="padding:10px 16px 6px; font-size:0.72rem; color:#94A3B8; text-transform:uppercase; letter-spacing:1px; font-weight:700;">
        <%: T("Viewing Child","Anak Dilihat") %>
    </div>
    <div style="padding:0 16px 14px;">
        <asp:DropDownList ID="ddlSidebarChild" runat="server" AutoPostBack="true" OnSelectedIndexChanged="SidebarChildChanged" CssClass="sb-sidebar-child-ddl" />
    </div>
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
        <a href="<%: ResolveUrl("~/Parent/StudyPlan.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-journal-check item-icon"></i><span class="item-label"><%: T("Study Plan","Pelan Pembelajaran") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/EditStudyPlan.aspx") %>" class="sb-sidebar-item"><i class="bi bi-pencil-square item-icon"></i><span class="item-label"><%: T("Edit Study Plan","Edit Pelan Pembelajaran") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Discussions","Perbincangan") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentTeacherCommunication.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Chat with Teachers","Sembang dengan Guru") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/Forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-people item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Notifications","Notifikasi") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentNotifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label"><%: T("Notifications","Notifikasi") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Profile","Profil") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("Edit Profile","Edit Profil") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/AccountSettings.aspx") %>" class="sb-sidebar-item"><i class="bi bi-gear item-icon"></i><span class="item-label"><%: T("Account Settings","Tetapan Akaun") %></span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Logout","Log Keluar") %></span></a></div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Study Plan","Pelan Pembelajaran") %></asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="pd-page">

    <%-- No Child --%>
    <asp:Panel ID="pnlNoChild" runat="server" Visible="false">
        <div class="pd-empty"><i class="bi bi-person-x-fill"></i><p><asp:Literal ID="litNoChildMsg" runat="server" /></p></div>
    </asp:Panel>

    <%-- No Plan --%>
    <asp:Panel ID="pnlNoPlan" runat="server" Visible="false">
        <div class="pd-empty"><i class="bi bi-journal-x"></i>
            <p><asp:Literal ID="litNoPlanMsg" runat="server" /></p>
            <a href="<%: ResolveUrl("~/Parent/EditStudyPlan.aspx") %>" class="pt-btn primary" style="margin-top:14px;">
                <i class="bi bi-plus-circle"></i> <%: T("Create Study Plan","Buat Pelan Belajar") %>
            </a>
        </div>
    </asp:Panel>

    <%-- Main Content --%>
    <asp:Panel ID="pnlContent" runat="server" Visible="false">

        <%-- ══ HEADER ══ --%>
        <div class="pt-study-plan-header">
            <div class="pt-study-plan-header-left">
                <h2 class="pt-study-plan-title"><i class="bi bi-rocket-takeoff-fill"></i> <asp:Literal ID="litPlanTitle" runat="server" /></h2>
                <p class="pt-study-plan-sub"><asp:Literal ID="litPlanSub" runat="server" /></p>
            </div>
            <a href="<%: ResolveUrl("~/Parent/EditStudyPlan.aspx") %>" class="pt-btn primary">
                <i class="bi bi-pencil-square"></i> <%: T("Edit Plan","Edit Pelan") %>
            </a>
        </div>

        <%-- ══ PROGRESS BAR WITH REWARDS ══ --%>
        <div class="pt-mission-progress-card">
            <div class="pt-mission-progress-label">
                <span><i class="bi bi-trophy-fill"></i> <%: T("Mission Progress","Kemajuan Misi") %></span>
            </div>
            <div class="pt-progress-track-wrap">
                <%-- Reward markers rendered here --%>
                <asp:Panel ID="pnlRewardMarkers" runat="server" CssClass="pt-reward-markers"></asp:Panel>
                <div class="pt-progress-track">
                    <div class="pt-progress-fill" id="divProgressFill" runat="server"><asp:Literal ID="litProgressPct" runat="server" /></div>
                </div>
            </div>
        </div>

        <%-- Reward details popover (hidden by default) --%>
        <asp:Panel ID="pnlRewardPopover" runat="server" Visible="false">
            <div class="pt-reward-popover">
                <asp:Image ID="imgPopoverReward" runat="server" CssClass="pt-reward-popover-img" />
                <div class="pt-reward-popover-name"><asp:Literal ID="litPopoverName" runat="server" /></div>
                <div class="pt-reward-popover-pct"><asp:Literal ID="litPopoverPct" runat="server" /></div>
                <div class="pt-reward-popover-status"><asp:Literal ID="litPopoverStatus" runat="server" /></div>
                <asp:Button ID="btnClosePopover" runat="server" Text="X" CssClass="pt-reward-popover-close" OnClick="BtnClosePopover_Click" CausesValidation="false" />
            </div>
        </asp:Panel>
        <asp:HiddenField ID="hidRewardClick" runat="server" />
        <asp:Button ID="btnRewardClick" runat="server" CssClass="d-none" OnClick="BtnRewardClick_Click" CausesValidation="false" />

        <%-- ══ TASK LIST ══ --%>
        <div class="pt-quiz-section-title" style="margin-top:24px;"><i class="bi bi-list-check"></i> <%: T("Tasks","Tugasan") %></div>
        <asp:Panel ID="pnlTasks" runat="server"></asp:Panel>
        <asp:Panel ID="pnlNoTasks" runat="server" Visible="false">
            <div class="pt-no-data"><%: T("No tasks in this study plan yet.","Belum ada tugasan dalam pelan belajar ini.") %></div>
        </asp:Panel>

        <%-- ══ REWARD SUMMARY ══ --%>
        <div class="pt-reward-summary-card">
            <div class="pt-reward-summary-row">
                <span class="pt-reward-summary-label"><i class="bi bi-gift-fill"></i> <%: T("Next Reward","Ganjaran Seterusnya") %></span>
                <span class="pt-reward-summary-value"><asp:Literal ID="litNextReward" runat="server" /></span>
            </div>
            <div class="pt-reward-summary-row">
                <span class="pt-reward-summary-label"><i class="bi bi-star-fill"></i> <%: T("Final Reward","Ganjaran Akhir") %></span>
                <span class="pt-reward-summary-value"><asp:Literal ID="litFinalReward" runat="server" /></span>
            </div>
            <div class="pt-reward-summary-row">
                <span class="pt-reward-summary-label"><i class="bi bi-check2-all"></i> <%: T("Completed","Selesai") %></span>
                <span class="pt-reward-summary-value"><asp:Literal ID="litCompletedCount" runat="server" /></span>
            </div>
            <asp:Panel ID="pnlRemainingDays" runat="server" Visible="false">
                <div class="pt-reward-summary-row">
                    <span class="pt-reward-summary-label"><i class="bi bi-calendar-event"></i> <%: T("Remaining Days","Hari Berbaki") %></span>
                    <span class="pt-reward-summary-value"><asp:Literal ID="litRemainingDays" runat="server" /></span>
                </div>
            </asp:Panel>
        </div>

        <%-- Days Left Banner --%>
        <asp:Panel ID="pnlDaysLeftBanner" runat="server" Visible="false">
            <div class="pt-days-left-banner">
                <i class="bi bi-hourglass-split"></i>
                <asp:Literal ID="litDaysLeftBanner" runat="server" />
            </div>
        </asp:Panel>

    </asp:Panel>
</div>
</asp:Content>
