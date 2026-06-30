<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LoginLogs.aspx.cs"
    Inherits="ScienceBuddy.Admin.LoginLogs" MasterPageFile="~/Site.Master"
    Title="Login Logs" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--ll-accent:#0891B2;--ll-green:#059669;--ll-red:#DC2626;--ll-purple:#7C3AED;--ll-orange:#D97706;}
.ll-header{margin-bottom:var(--space-xl);padding-bottom:var(--space-md);border-bottom:1.5px solid var(--border-color);}
.ll-title{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;color:var(--color-text);display:flex;align-items:center;gap:var(--space-sm);margin-bottom:var(--space-xs);}
.ll-sub{font-size:.9375rem;color:var(--color-text-secondary);max-width:560px;line-height:1.5;}
.ll-stats{display:grid;grid-template-columns:repeat(4,1fr);gap:var(--space-md);margin-bottom:var(--space-xl);}
.ll-stat{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);padding:var(--space-lg);display:flex;flex-direction:column;gap:var(--space-xs);transition:transform .25s,box-shadow .25s;position:relative;overflow:hidden;}
.ll-stat:hover{transform:translateY(-3px);box-shadow:var(--shadow-md);}
.ll-stat::before{content:'';position:absolute;top:0;left:0;right:0;height:3px;}
.ll-stat.s1::before{background:linear-gradient(90deg,#059669,#34D399);}.ll-stat.s2::before{background:linear-gradient(90deg,#DC2626,#F87171);}.ll-stat.s3::before{background:linear-gradient(90deg,#7C3AED,#A78BFA);}.ll-stat.s4::before{background:linear-gradient(90deg,#D97706,#FBBF24);}
.ll-stat-ico{font-size:1.25rem;}.ll-stat-val{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;color:var(--color-text);}.ll-stat-lbl{font-size:.75rem;color:var(--color-text-muted);font-weight:600;}
.ll-search{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-md);padding:var(--space-md) var(--space-xl);display:flex;align-items:center;gap:var(--space-md);flex-wrap:wrap;margin-bottom:var(--space-xl);}
.ll-search .sb-input{flex:1;min-width:160px;max-width:240px;}.ll-search .sb-select{max-width:150px;}
.ll-card{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);overflow:hidden;margin-bottom:var(--space-xl);}
.ll-card-hdr{padding:var(--space-md) var(--space-lg);border-bottom:1px solid var(--border-color);font-family:var(--font-primary);font-weight:800;font-size:.9375rem;display:flex;align-items:center;gap:var(--space-sm);}
.ll-item{display:flex;align-items:center;gap:var(--space-md);padding:var(--space-md) var(--space-lg);border-bottom:1px solid var(--border-color);transition:background .15s;}
.ll-item:last-child{border-bottom:none;}.ll-item:hover{background:var(--color-surface-alt);}
.ll-ico{width:38px;height:38px;border-radius:var(--border-radius);display:flex;align-items:center;justify-content:center;font-size:1rem;flex-shrink:0;}
.ll-body{flex:1;min-width:0;}
.ll-action{font-weight:700;font-size:.875rem;color:var(--color-text);}
.ll-desc{font-size:.8125rem;color:var(--color-text-secondary);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.ll-meta{font-size:.75rem;color:var(--color-text-muted);margin-top:2px;display:flex;gap:var(--space-md);}
.ll-empty{display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;padding:var(--space-2xl);}
.ll-empty-ico{font-size:3rem;margin-bottom:var(--space-md);opacity:.35;color:var(--ll-accent);}.ll-empty-msg{font-size:1rem;font-weight:700;color:var(--color-text-secondary);}.ll-empty-sub{font-size:.875rem;color:var(--color-text-muted);margin-top:4px;}
.ll-modal-wrap .sb-modal-overlay{left:var(--sidebar-width);animation:ll-ov .2s ease both;}.sidebar-collapsed .ll-modal-wrap .sb-modal-overlay{left:var(--sidebar-collapsed);}
.ll-modal-wrap .sb-modal{animation:ll-md .3s cubic-bezier(.34,1.56,.64,1) both;}
@keyframes ll-ov{from{opacity:0;}to{opacity:1;}}@keyframes ll-md{from{opacity:0;transform:scale(.92) translateY(16px);}to{opacity:1;transform:scale(1) translateY(0);}}
@media(max-width:1279px){.ll-stats{grid-template-columns:repeat(2,1fr);}}
@media(max-width:767px){.ll-stats{grid-template-columns:1fr 1fr;}.ll-search{flex-direction:column;align-items:stretch;}.ll-search .sb-input,.ll-search .sb-select{max-width:100%;}.ll-modal-wrap .sb-modal-overlay{left:0;}}
</style>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label">Main</div>
        <a href="<%: ResolveUrl("~/Admin/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label">Dashboard</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">User Management</div>
        <a href="<%: ResolveUrl("~/Admin/StudentManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-people item-icon"></i><span class="item-label">Students</span></a>
        <a href="<%: ResolveUrl("~/Admin/ParentManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-heart item-icon"></i><span class="item-label">Parents</span></a>
        <a href="<%: ResolveUrl("~/Admin/TeacherManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-badge item-icon"></i><span class="item-label">Teachers</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Learning Content</div>
        <a href="<%: ResolveUrl("~/Admin/LessonManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label">Lessons</span></a>
        <a href="<%: ResolveUrl("~/Admin/QuizManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label">Quizzes</span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-question-circle item-icon"></i><span class="item-label">Questions</span></a>
        <a href="<%: ResolveUrl("~/Admin/TeacherMaterials.aspx") %>" class="sb-sidebar-item"><i class="bi bi-file-earmark-text item-icon"></i><span class="item-label">Material Requests</span></a>
        <a href="<%: ResolveUrl("~/Admin/LiveSessions.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label">Live Sessions</span></a>
        <a href="<%: ResolveUrl("~/Admin/QuestionRequests.aspx") %>" class="sb-sidebar-item"><i class="bi bi-clipboard-check item-icon"></i><span class="item-label">Question Requests</span></a>
        <a href="<%: ResolveUrl("~/Admin/CertificateManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-award item-icon"></i><span class="item-label">Certificates</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Gamification</div>
        <a href="<%: ResolveUrl("~/Admin/GamificationManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-trophy item-icon"></i><span class="item-label">Gamification</span></a>
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
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item" onclick="return confirm('Are you sure you want to sign out?');"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%= T("Login Logs", "Log Log Masuk") %></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="ll-header">
    <h1 class="ll-title"><i class="bi bi-shield-lock-fill" style="color:var(--ll-accent);"></i> <%= T("Login Logs", "Log Log Masuk") %></h1>
    <p class="ll-sub"><%= T("Monitor every authentication activity across ScienceBuddy including successful logins, failed login attempts, suspicious logins and account lock events.", "Pantau setiap aktiviti pengesahan di ScienceBuddy termasuk log masuk berjaya, percubaan gagal, log masuk mencurigakan dan peristiwa kunci akaun.") %></p>
</div>

<div class="ll-stats">
    <div class="ll-stat s1"><div class="ll-stat-ico" style="color:#059669;"><i class="bi bi-box-arrow-in-right"></i></div><div class="ll-stat-val"><asp:Literal ID="litSuccess" runat="server" Text="0" /></div><div class="ll-stat-lbl"><%= T("Successful Logins", "Log Masuk Berjaya") %></div></div>
    <div class="ll-stat s2"><div class="ll-stat-ico" style="color:#DC2626;"><i class="bi bi-x-circle-fill"></i></div><div class="ll-stat-val"><asp:Literal ID="litFailed" runat="server" Text="0" /></div><div class="ll-stat-lbl"><%= T("Failed Logins", "Log Masuk Gagal") %></div></div>
    <div class="ll-stat s3"><div class="ll-stat-ico" style="color:#7C3AED;"><i class="bi bi-lock-fill"></i></div><div class="ll-stat-val"><asp:Literal ID="litLocked" runat="server" Text="0" /></div><div class="ll-stat-lbl"><%= T("Account Locked", "Akaun Dikunci") %></div></div>
    <div class="ll-stat s4"><div class="ll-stat-ico" style="color:#D97706;"><i class="bi bi-exclamation-triangle-fill"></i></div><div class="ll-stat-val"><asp:Literal ID="litSuspicious" runat="server" Text="0" /></div><div class="ll-stat-lbl"><%= T("Suspicious Attempts", "Percubaan Mencurigakan") %></div></div>
</div>

<div class="ll-search">
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

<div class="ll-card">
    <div class="ll-card-hdr"><i class="bi bi-list-check" style="color:var(--ll-accent);"></i> <%= T("Authentication Events", "Peristiwa Pengesahan") %></div>
    <asp:Panel ID="pnlLogs" runat="server" Visible="false">
        <asp:Repeater ID="rptLogs" runat="server" OnItemCommand="rptLogs_ItemCommand">
            <ItemTemplate>
                <div class="ll-item">
                    <div class="ll-ico" style='<%# Eval("icoStyle") %>'><i class='<%# Eval("icoClass") %>'></i></div>
                    <div class="ll-body">
                        <div class="ll-action"><%# HttpUtility.HtmlEncode(Eval("action")) %></div>
                        <div class="ll-desc"><%# HttpUtility.HtmlEncode(Eval("description")) %></div>
                        <div class="ll-meta"><span><i class="bi bi-person"></i> <%# HttpUtility.HtmlEncode(Eval("username")) %></span><span><i class="bi bi-clock"></i> <%# Eval("dateStr") %></span></div>
                    </div>
                    <span class='sb-badge <%# Eval("statusCls") %>'><%# HttpUtility.HtmlEncode(Eval("statusLabel")) %></span>
                    <asp:LinkButton ID="lnkView" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-xs" CommandName="ViewLog" CommandArgument='<%# Eval("logId") %>' ToolTip="View"><i class="bi bi-eye"></i></asp:LinkButton>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </asp:Panel>
    <asp:Panel ID="pnlEmpty" runat="server">
        <div class="ll-empty"><div class="ll-empty-ico"><i class="bi bi-shield-check"></i></div><div class="ll-empty-msg"><%= T("No login activity found.", "Tiada aktiviti log masuk ditemui.") %></div><div class="ll-empty-sub"><%= T("Adjust your filters or search again.", "Laraskan penapis atau cari semula.") %></div></div>
    </asp:Panel>
</div>

<%-- VIEW MODAL --%>
<asp:Panel ID="pnlModal" runat="server" Visible="false" CssClass="ll-modal-wrap">
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
