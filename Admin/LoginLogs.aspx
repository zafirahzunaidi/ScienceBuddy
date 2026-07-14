<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LoginLogs.aspx.cs"
    Inherits="ScienceBuddy.Admin.LoginLogs" MasterPageFile="~/Site.Master"
    Title="Login Logs" %>

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
        <a href="<%: ResolveUrl("~/Admin/SystemActivityLogs.aspx") %>" class="sb-sidebar-item"><i class="bi bi-clock-history item-icon"></i><span class="item-label">Activity Logs</span></a>
        <a href="<%: ResolveUrl("~/Admin/LoginLogs.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-box-arrow-in-right item-icon"></i><span class="item-label">Login Logs</span></a>
        <a href="<%: ResolveUrl("~/Admin/SuspiciousLogins.aspx") %>" class="sb-sidebar-item"><i class="bi bi-exclamation-triangle item-icon"></i><span class="item-label">Suspicious Logins</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Admin/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span></a>
        <a href="<%: ResolveUrl("~/Admin/Profile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a>
        <a href="javascript:;" class="sb-sidebar-item" onclick="showSignOutModal()"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%= T("Login Logs", "Log Log Masuk") %></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="ad-login-logs-header">
    <h1 class="ad-login-logs-title"><i class="bi bi-shield-lock-fill" style="color:var(--ad-login-logs-accent);"></i> <%= T("Login Logs", "Log Log Masuk") %></h1>
    <p class="ad-login-logs-sub"><%= T("Monitor every authentication activity across ScienceBuddy including successful logins, failed login attempts, suspicious logins and account lock events.", "Pantau setiap aktiviti pengesahan di ScienceBuddy termasuk log masuk berjaya, percubaan gagal, log masuk mencurigakan dan peristiwa kunci akaun.") %></p>
</div>

<div class="ad-login-logs-stats">
    <div class="ad-login-logs-stat s1"><div class="ad-login-logs-stat-ico" style="color:#059669;"><i class="bi bi-box-arrow-in-right"></i></div><div class="ad-login-logs-stat-val"><asp:Literal ID="litSuccess" runat="server" Text="0" /></div><div class="ad-login-logs-stat-lbl"><%= T("Successful Logins", "Log Masuk Berjaya") %></div></div>
    <div class="ad-login-logs-stat s2"><div class="ad-login-logs-stat-ico" style="color:#DC2626;"><i class="bi bi-x-circle-fill"></i></div><div class="ad-login-logs-stat-val"><asp:Literal ID="litFailed" runat="server" Text="0" /></div><div class="ad-login-logs-stat-lbl"><%= T("Failed Logins", "Log Masuk Gagal") %></div></div>
    <div class="ad-login-logs-stat s3"><div class="ad-login-logs-stat-ico" style="color:#7C3AED;"><i class="bi bi-lock-fill"></i></div><div class="ad-login-logs-stat-val"><asp:Literal ID="litLocked" runat="server" Text="0" /></div><div class="ad-login-logs-stat-lbl"><%= T("Account Locked", "Akaun Dikunci") %></div></div>
    <div class="ad-login-logs-stat s4"><div class="ad-login-logs-stat-ico" style="color:#D97706;"><i class="bi bi-exclamation-triangle-fill"></i></div><div class="ad-login-logs-stat-val"><asp:Literal ID="litSuspicious" runat="server" Text="0" /></div><div class="ad-login-logs-stat-lbl"><%= T("Suspicious Attempts", "Percubaan Mencurigakan") %></div></div>
</div>

<div class="ad-login-logs-search">
    <i class="bi bi-search text-muted"></i>
    <asp:TextBox ID="txtSearch" runat="server" CssClass="sb-input sb-input-sm" AutoPostBack="false" />
    <asp:DropDownList ID="ddlAction" runat="server" CssClass="sb-select sb-input-sm" AutoPostBack="false">
        <asp:ListItem Value="">All Actions</asp:ListItem>
        <asp:ListItem Value="Login">Login</asp:ListItem>
        <asp:ListItem Value="Logout">Logout</asp:ListItem>
        <asp:ListItem Value="Failed Login">Failed Login</asp:ListItem>
        <asp:ListItem Value="Suspicious Login Attempt">Suspicious</asp:ListItem>
        <asp:ListItem Value="Account Locked">Account Locked</asp:ListItem>
    </asp:DropDownList>
    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="sb-select sb-input-sm" AutoPostBack="false">
        <asp:ListItem Value="">All Status</asp:ListItem>
        <asp:ListItem Value="Success">Success</asp:ListItem>
        <asp:ListItem Value="Failed">Failed</asp:ListItem>
        <asp:ListItem Value="Warning">Warning</asp:ListItem>
    </asp:DropDownList>
    <asp:Button ID="btnSearch" runat="server" CssClass="sb-btn sb-btn-primary sb-btn-sm" OnClick="btnSearch_Click" />
    <asp:Button ID="btnReset" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnReset_Click" />
</div>

<div class="ad-login-logs-card">
    <div class="ad-login-logs-card-hdr"><i class="bi bi-list-check" style="color:var(--ad-login-logs-accent);"></i> <%= T("Authentication Events", "Peristiwa Pengesahan") %></div>
    <asp:Panel ID="pnlLogs" runat="server" Visible="false">
        <asp:Repeater ID="rptLogs" runat="server" OnItemCommand="rptLogs_ItemCommand">
            <ItemTemplate>
                <div class="ad-login-logs-item">
                    <div class="ad-login-logs-ico" style='<%# Eval("icoStyle") %>'><i class='<%# Eval("icoClass") %>'></i></div>
                    <div class="ad-login-logs-body">
                        <div class="ad-login-logs-action"><%# HttpUtility.HtmlEncode(Eval("action")) %></div>
                        <div class="ad-login-logs-desc"><%# HttpUtility.HtmlEncode(Eval("description")) %></div>
                        <div class="ad-login-logs-meta"><span><i class="bi bi-person"></i> <%# HttpUtility.HtmlEncode(Eval("username")) %></span><span><i class="bi bi-clock"></i> <%# Eval("dateStr") %></span></div>
                    </div>
                    <span class='sb-badge <%# Eval("statusCls") %>'><%# HttpUtility.HtmlEncode(Eval("statusLabel")) %></span>
                    <asp:LinkButton ID="lnkView" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-xs" CommandName="ViewLog" CommandArgument='<%# Eval("logId") %>' ToolTip="View"><i class="bi bi-eye"></i></asp:LinkButton>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </asp:Panel>
    <asp:Panel ID="pnlEmpty" runat="server">
        <div class="ad-login-logs-empty"><div class="ad-login-logs-empty-ico"><i class="bi bi-shield-check"></i></div><div class="ad-login-logs-empty-msg"><%= T("No login activity found.", "Tiada aktiviti log masuk ditemui.") %></div><div class="ad-login-logs-empty-sub"><%= T("Adjust your filters or search again.", "Laraskan penapis atau cari semula.") %></div></div>
    </asp:Panel>
</div>

<%-- VIEW MODAL --%>
<asp:Panel ID="pnlModal" runat="server" Visible="false" CssClass="ad-login-logs-modal-wrap">
<div class="sb-modal-overlay active" style="display:flex;">
    <div class="sb-modal" style="max-width:520px;max-height:90vh;overflow-y:auto;">
        <div style="background:linear-gradient(135deg,#0891B2,#06B6D4);padding:var(--space-lg) var(--space-xl);color:#fff;border-radius:var(--border-radius-xl) var(--border-radius-xl) 0 0;display:flex;align-items:center;gap:var(--space-md);">
            <div style="width:44px;height:44px;border-radius:var(--border-radius);background:rgba(255,255,255,.2);display:flex;align-items:center;justify-content:center;font-size:1.2rem;"><i class="bi bi-shield-lock-fill"></i></div>
            <div style="font-family:var(--font-primary);font-size:1.125rem;font-weight:800;"><%= T("Login Event Details", "Butiran Peristiwa Log Masuk") %></div>
        </div>
        <div style="padding:var(--space-xl);">
            <div style="margin-bottom:var(--space-md);"><div style="font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;"><%= T("Log ID", "ID Log") %></div><div style="font-size:.9375rem;font-weight:600;color:var(--color-text);"><asp:Literal ID="litMLogId" runat="server" /></div></div>
            <div style="margin-bottom:var(--space-md);"><div style="font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;"><%= T("User", "Pengguna") %></div><div style="font-size:.9375rem;font-weight:600;color:var(--color-text);"><asp:Literal ID="litMUser" runat="server" /></div></div>
            <div style="margin-bottom:var(--space-md);"><div style="font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;"><%= T("Action", "Tindakan") %></div><div style="font-size:.9375rem;font-weight:600;color:var(--color-text);"><asp:Literal ID="litMAction" runat="server" /></div></div>
            <div style="margin-bottom:var(--space-md);"><div style="font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;"><%= T("Description", "Penerangan") %></div><div style="font-size:.9375rem;font-weight:600;color:var(--color-text);"><asp:Literal ID="litMDesc" runat="server" /></div></div>
            <div style="margin-bottom:var(--space-md);"><div style="font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;"><%= T("Status", "Status") %></div><div style="font-size:.9375rem;font-weight:600;"><asp:Literal ID="litMStatus" runat="server" /></div></div>
            <div style="margin-bottom:var(--space-md);"><div style="font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;"><%= T("Date & Time", "Tarikh & Masa") %></div><div style="font-size:.9375rem;font-weight:600;color:var(--color-text);"><asp:Literal ID="litMDate" runat="server" /></div></div>
        </div>
        <div class="sb-modal-footer"><asp:Button ID="btnCloseModal" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnCloseModal_Click" /></div>
    </div>
</div>
</asp:Panel>
</asp:Content>
