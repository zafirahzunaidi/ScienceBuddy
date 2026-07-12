<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SystemActivityLogs.aspx.cs"
    Inherits="ScienceBuddy.Admin.SystemActivityLogs" MasterPageFile="~/Site.Master"
    Title="Activity Logs" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%: ResolveUrl("~/Content/Admin.css") %>" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" />
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="<%: ResolveUrl("~/Scripts/admin-signout.js") %>"></script>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label">Main</div>
        <a href="<%: ResolveUrl("~/Admin/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label">Dashboard</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">User Management</div>
        <a href="<%: ResolveUrl("~/Admin/StudentManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-people item-icon"></i><span class="item-label">Students</span></a>
        <a href="<%: ResolveUrl("~/Admin/ParentManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-heart item-icon"></i><span class="item-label">Parents</span></a>
        <a href="<%: ResolveUrl("~/Admin/TeacherManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-badge item-icon"></i><span class="item-label">Teachers</span></a>
        <a href="<%: ResolveUrl("~/Admin/TeacherCertificateApproval.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-check item-icon"></i><span class="item-label">Teacher Certificate Approval</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Learning Content</div>
        <a href="<%: ResolveUrl("~/Admin/LessonManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label">Lessons</span></a>
        <a href="<%: ResolveUrl("~/Admin/QuizManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label">Quizzes</span></a>
        <a href="<%: ResolveUrl("~/Admin/QuestionBank.aspx") %>" class="sb-sidebar-item"><i class="bi bi-question-circle item-icon"></i><span class="item-label">Question Bank</span></a>
        <a href="<%: ResolveUrl("~/Admin/TeacherMaterials.aspx") %>" class="sb-sidebar-item"><i class="bi bi-file-earmark-text item-icon"></i><span class="item-label">Material Requests</span></a>
        <a href="<%: ResolveUrl("~/Admin/LiveSessions.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label">Live Sessions</span></a>
        <a href="<%: ResolveUrl("~/Admin/QuestionRequests.aspx") %>" class="sb-sidebar-item"><i class="bi bi-clipboard-check item-icon"></i><span class="item-label">Question Requests</span></a>
        <a href="<%: ResolveUrl("~/Admin/CertificateManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-award item-icon"></i><span class="item-label">Certificates</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Community</div>
        <a href="<%: ResolveUrl("~/Admin/ForumDiscussions.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label">Forum Discussions</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Gamification</div>
        <a href="<%: ResolveUrl("~/Admin/GamificationManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-trophy item-icon"></i><span class="item-label">Student Performance</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Configuration</div>
        <a href="<%: ResolveUrl("~/Admin/SystemSettings.aspx") %>" class="sb-sidebar-item"><i class="bi bi-gear item-icon"></i><span class="item-label">System Settings</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Logs</div>
        <a href="<%: ResolveUrl("~/Admin/SystemActivityLogs.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-clock-history item-icon"></i><span class="item-label">Activity Logs</span></a>
        <a href="<%: ResolveUrl("~/Admin/LoginLogs.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-in-right item-icon"></i><span class="item-label">Login Logs</span></a>
        <a href="<%: ResolveUrl("~/Admin/SuspiciousLogins.aspx") %>" class="sb-sidebar-item"><i class="bi bi-exclamation-triangle item-icon"></i><span class="item-label">Suspicious Logins</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Admin/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span></a>
        <a href="<%: ResolveUrl("~/Admin/Profile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a>
        <a href="javascript:;" class="sb-sidebar-item" onclick="showSignOutModal()"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%= T("Activity Logs", "Log Aktiviti") %></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- HEADER --%>
<div class="ad-system-activity-logs-header-card">
    <div>
        <h1 class="ad-system-activity-logs-header-title"><%= T("Activity Logs", "Log Aktiviti") %></h1>
        <p class="ad-system-activity-logs-header-sub"><%= T("Monitor every important activity happening across ScienceBuddy.", "Pantau setiap aktiviti penting yang berlaku di ScienceBuddy.") %></p>
    </div>
    <div class="ad-system-activity-logs-header-icon"><i class="bi bi-activity"></i></div>
</div>

<%-- STATS --%>
<div class="ad-system-activity-logs-stats">
    <div class="ad-system-activity-logs-stat s-total"><div class="ad-system-activity-logs-stat-ico"><i class="bi bi-list-check"></i></div><div class="ad-system-activity-logs-stat-val"><asp:Literal ID="litTotal" runat="server" Text="0" /></div><div class="ad-system-activity-logs-stat-lbl"><%= T("Total Logs", "Jumlah Log") %></div><div class="ad-system-activity-logs-stat-trend"><asp:Literal ID="litTotalTrend" runat="server" /></div></div>
    <div class="ad-system-activity-logs-stat s-today"><div class="ad-system-activity-logs-stat-ico"><i class="bi bi-calendar-check"></i></div><div class="ad-system-activity-logs-stat-val"><asp:Literal ID="litToday" runat="server" Text="0" /></div><div class="ad-system-activity-logs-stat-lbl"><%= T("Today's Activities", "Aktiviti Hari Ini") %></div><div class="ad-system-activity-logs-stat-trend"><asp:Literal ID="litTodayTrend" runat="server" /></div></div>
    <div class="ad-system-activity-logs-stat s-success"><div class="ad-system-activity-logs-stat-ico"><i class="bi bi-check-circle"></i></div><div class="ad-system-activity-logs-stat-val"><asp:Literal ID="litSuccess" runat="server" Text="0" /></div><div class="ad-system-activity-logs-stat-lbl"><%= T("Successful", "Berjaya") %></div><div class="ad-system-activity-logs-stat-trend"><asp:Literal ID="litSuccessTrend" runat="server" /></div></div>
    <div class="ad-system-activity-logs-stat s-warn"><div class="ad-system-activity-logs-stat-ico"><i class="bi bi-exclamation-triangle"></i></div><div class="ad-system-activity-logs-stat-val"><asp:Literal ID="litWarn" runat="server" Text="0" /></div><div class="ad-system-activity-logs-stat-lbl"><%= T("Warnings & Failed", "Amaran & Gagal") %></div><div class="ad-system-activity-logs-stat-trend"><asp:Literal ID="litWarnTrend" runat="server" /></div></div>
</div>

<%-- SEARCH --%>
<div class="ad-system-activity-logs-search">
    <i class="bi bi-search text-muted"></i>
    <asp:TextBox ID="txtSearch" runat="server" CssClass="sb-input sb-input-sm" AutoPostBack="false" />
    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="sb-select sb-input-sm" AutoPostBack="false">
        <asp:ListItem Value="">All Status</asp:ListItem>
        <asp:ListItem Value="Success">Success</asp:ListItem>
        <asp:ListItem Value="Warning">Warning</asp:ListItem>
        <asp:ListItem Value="Failed">Failed</asp:ListItem>
    </asp:DropDownList>
    <asp:DropDownList ID="ddlAction" runat="server" CssClass="sb-select sb-input-sm" AutoPostBack="false">
        <asp:ListItem Value="">All Actions</asp:ListItem>
        <asp:ListItem Value="Login">Login</asp:ListItem>
        <asp:ListItem Value="Logout">Logout</asp:ListItem>
        <asp:ListItem Value="Notification">Notification</asp:ListItem>
        <asp:ListItem Value="Lesson">Lesson</asp:ListItem>
        <asp:ListItem Value="Quiz">Quiz</asp:ListItem>
        <asp:ListItem Value="Forum">Forum</asp:ListItem>
        <asp:ListItem Value="Teacher">Teacher</asp:ListItem>
        <asp:ListItem Value="Configuration">Configuration</asp:ListItem>
        <asp:ListItem Value="Security">Security</asp:ListItem>
        <asp:ListItem Value="Content Request">Content Request</asp:ListItem>
    </asp:DropDownList>
    <asp:Button ID="btnSearch" runat="server" CssClass="sb-btn sb-btn-primary sb-btn-sm" OnClick="btnSearch_Click" />
    <asp:Button ID="btnReset" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnReset_Click" />
</div>

<%-- TIMELINE --%>
<asp:Panel ID="pnlTimeline" runat="server" Visible="false">
    <div class="ad-system-activity-logs-timeline">
        <asp:Repeater ID="rptLogs" runat="server" OnItemCommand="rptLogs_ItemCommand">
            <ItemTemplate>
                <asp:Panel ID="pnlDateHeader" runat="server" Visible='<%# Convert.ToBoolean(Eval("showDateHeader")) %>'>
                    <div class="ad-system-activity-logs-date-label"><%# HttpUtility.HtmlEncode(Eval("dateLabel")) %></div>
                </asp:Panel>
                <div class="ad-system-activity-logs-item">
                    <div class="ad-system-activity-logs-ico" style='<%# Eval("icoStyle") %>'><i class='<%# Eval("icoClass") %>'></i></div>
                    <div class="ad-system-activity-logs-body">
                        <div class="ad-system-activity-logs-action"><%# HttpUtility.HtmlEncode(Eval("action")) %></div>
                        <div class="ad-system-activity-logs-desc"><%# HttpUtility.HtmlEncode(Eval("description")) %></div>
                    </div>
                    <div class="ad-system-activity-logs-meta">
                        <div class="ad-system-activity-logs-time"><%# Eval("timeStr") %></div>
                        <span class='sb-badge <%# Eval("statusCls") %>'><%# HttpUtility.HtmlEncode(Eval("statusLabel")) %></span>
                    </div>
                    <asp:LinkButton ID="lnkView" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-xs" CommandName="ViewLog" CommandArgument='<%# Eval("logId") %>' ToolTip="View Details" style="margin-left:var(--space-xs);">
                        <i class="bi bi-eye"></i>
                    </asp:LinkButton>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>

<%-- EMPTY --%>
<asp:Panel ID="pnlEmpty" runat="server">
    <div class="ad-system-activity-logs-empty">
        <div class="ad-system-activity-logs-empty-ico"><i class="bi bi-clock-history"></i></div>
        <div class="ad-system-activity-logs-empty-msg"><%= T("No Activity Yet", "Tiada Aktiviti Lagi") %></div>
        <div class="ad-system-activity-logs-empty-sub"><%= T("System activities will appear here once users begin interacting with ScienceBuddy.", "Aktiviti sistem akan dipaparkan di sini setelah pengguna mula berinteraksi dengan ScienceBuddy.") %></div>
    </div>
</asp:Panel>

<%-- DETAIL MODAL --%>
<asp:Panel ID="pnlModal" runat="server" Visible="false" CssClass="ad-system-activity-logs-modal-wrap">
<div class="sb-modal-overlay active" style="display:flex;">
    <div class="sb-modal" style="max-width:480px;">
        <div class="ad-system-activity-logs-modal-hdr">
            <div class="ad-system-activity-logs-modal-hdr-ico"><i class="bi bi-journal-text"></i></div>
            <div class="ad-system-activity-logs-modal-hdr-title"><%= T("Activity Detail", "Butiran Aktiviti") %></div>
        </div>
        <div class="ad-system-activity-logs-modal-body">
            <div class="ad-system-activity-logs-modal-field"><div class="ad-system-activity-logs-modal-label"><%= T("Log ID", "ID Log") %></div><div class="ad-system-activity-logs-modal-value"><asp:Literal ID="litMLogId" runat="server" /></div></div>
            <div class="ad-system-activity-logs-modal-field"><div class="ad-system-activity-logs-modal-label"><%= T("User ID", "ID Pengguna") %></div><div class="ad-system-activity-logs-modal-value"><asp:Literal ID="litMUserId" runat="server" /></div></div>
            <div class="ad-system-activity-logs-modal-field"><div class="ad-system-activity-logs-modal-label"><%= T("Action", "Tindakan") %></div><div class="ad-system-activity-logs-modal-value"><asp:Literal ID="litMAction" runat="server" /></div></div>
            <div class="ad-system-activity-logs-modal-field"><div class="ad-system-activity-logs-modal-label"><%= T("Description", "Penerangan") %></div><div class="ad-system-activity-logs-modal-value"><asp:Literal ID="litMDesc" runat="server" /></div></div>
            <div class="ad-system-activity-logs-modal-field"><div class="ad-system-activity-logs-modal-label"><%= T("Status", "Status") %></div><div class="ad-system-activity-logs-modal-value"><asp:Literal ID="litMStatus" runat="server" /></div></div>
            <div class="ad-system-activity-logs-modal-field"><div class="ad-system-activity-logs-modal-label"><%= T("Date & Time", "Tarikh & Masa") %></div><div class="ad-system-activity-logs-modal-value"><asp:Literal ID="litMDateTime" runat="server" /></div></div>
        </div>
        <div class="sb-modal-footer">
            <asp:Button ID="btnCloseModal" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnCloseModal_Click" />
        </div>
    </div>
</div>
</asp:Panel>

</asp:Content>
