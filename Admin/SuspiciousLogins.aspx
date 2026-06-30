<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SuspiciousLogins.aspx.cs"
    Inherits="ScienceBuddy.Admin.SuspiciousLogins" MasterPageFile="~/Site.Master"
    Title="Suspicious Logins" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--sl-accent:#DC2626;--sl-blue:#2563EB;--sl-purple:#7C3AED;--sl-green:#059669;}
.sl-header{margin-bottom:var(--space-xl);padding-bottom:var(--space-md);border-bottom:1.5px solid var(--border-color);}
.sl-title{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;color:var(--color-text);display:flex;align-items:center;gap:var(--space-sm);margin-bottom:var(--space-xs);}
.sl-sub{font-size:.9375rem;color:var(--color-text-secondary);max-width:520px;line-height:1.5;}
.sl-stats{display:grid;grid-template-columns:repeat(4,1fr);gap:var(--space-md);margin-bottom:var(--space-xl);}
.sl-stat{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);padding:var(--space-lg);display:flex;flex-direction:column;gap:var(--space-xs);transition:transform .25s,box-shadow .25s;position:relative;overflow:hidden;}
.sl-stat:hover{transform:translateY(-3px);box-shadow:var(--shadow-md);}
.sl-stat::before{content:'';position:absolute;top:0;left:0;right:0;height:3px;}
.sl-stat.s1::before{background:linear-gradient(90deg,#DC2626,#F87171);}.sl-stat.s2::before{background:linear-gradient(90deg,#7C3AED,#A78BFA);}.sl-stat.s3::before{background:linear-gradient(90deg,#2563EB,#60A5FA);}.sl-stat.s4::before{background:linear-gradient(90deg,#059669,#34D399);}
.sl-stat-ico{font-size:1.25rem;}.sl-stat-val{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;color:var(--color-text);}.sl-stat-lbl{font-size:.75rem;color:var(--color-text-muted);font-weight:600;}
.sl-search{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-md);padding:var(--space-md) var(--space-xl);display:flex;align-items:center;gap:var(--space-md);flex-wrap:wrap;margin-bottom:var(--space-xl);}
.sl-search .sb-input{flex:1;min-width:160px;max-width:260px;}.sl-search .sb-select{max-width:140px;}
.sl-card{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);overflow:hidden;margin-bottom:var(--space-xl);}
.sl-card-hdr{padding:var(--space-md) var(--space-lg);border-bottom:1px solid var(--border-color);font-family:var(--font-primary);font-weight:800;font-size:.9375rem;display:flex;align-items:center;gap:var(--space-sm);}
.sl-empty{display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;padding:var(--space-2xl);}
.sl-empty-ico{font-size:3rem;margin-bottom:var(--space-md);opacity:.35;color:var(--sl-accent);}.sl-empty-msg{font-size:1rem;font-weight:700;color:var(--color-text-secondary);}
.sl-modal-wrap .sb-modal-overlay{left:var(--sidebar-width);animation:sl-ov .2s ease both;}.sidebar-collapsed .sl-modal-wrap .sb-modal-overlay{left:var(--sidebar-collapsed);}
.sl-modal-wrap .sb-modal{animation:sl-md .3s cubic-bezier(.34,1.56,.64,1) both;}
@keyframes sl-ov{from{opacity:0;}to{opacity:1;}}@keyframes sl-md{from{opacity:0;transform:scale(.92) translateY(16px);}to{opacity:1;transform:scale(1) translateY(0);}}
@media(max-width:1279px){.sl-stats{grid-template-columns:repeat(2,1fr);}}
@media(max-width:767px){.sl-stats{grid-template-columns:1fr 1fr;}.sl-search{flex-direction:column;align-items:stretch;}.sl-search .sb-input,.sl-search .sb-select{max-width:100%;}.sl-modal-wrap .sb-modal-overlay{left:0;}}
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
        <a href="#" class="sb-sidebar-item"><i class="bi bi-file-earmark-text item-icon"></i><span class="item-label">Teacher Materials</span></a>
        <a href="<%: ResolveUrl("~/Admin/LiveSessions.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label">Live Sessions</span></a>
        <a href="<%: ResolveUrl("~/Admin/ContentRequests.aspx") %>" class="sb-sidebar-item"><i class="bi bi-inbox item-icon"></i><span class="item-label">Content Requests</span></a>
        <a href="<%: ResolveUrl("~/Admin/CertificateManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-award item-icon"></i><span class="item-label">Certificates</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Gamification</div>
        <a href="<%: ResolveUrl("~/Admin/GamificationManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-trophy item-icon"></i><span class="item-label">Gamification</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Configuration</div>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-gear item-icon"></i><span class="item-label">Quiz Settings</span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-shield-lock item-icon"></i><span class="item-label">Security Settings</span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-sliders item-icon"></i><span class="item-label">XP Settings</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Logs</div>
        <a href="<%: ResolveUrl("~/Admin/SystemActivityLogs.aspx") %>" class="sb-sidebar-item"><i class="bi bi-clock-history item-icon"></i><span class="item-label">Activity Logs</span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-box-arrow-in-right item-icon"></i><span class="item-label">Login Logs</span></a>
        <a href="<%: ResolveUrl("~/Admin/SuspiciousLogins.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-exclamation-triangle item-icon"></i><span class="item-label">Suspicious Logins</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Admin/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span></a>
        <a href="<%: ResolveUrl("~/Admin/Profile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item" onclick="return confirm('Are you sure you want to sign out?');"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%= T("Suspicious Logins", "Log Masuk Mencurigakan") %></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="sl-header">
    <h1 class="sl-title"><i class="bi bi-shield-exclamation" style="color:var(--sl-accent);"></i> <%= T("Suspicious Login Monitoring", "Pemantauan Log Masuk Mencurigakan") %></h1>
    <p class="sl-sub"><%= T("Monitor unusual login behaviour and protect ScienceBuddy accounts from unauthorized access.", "Pantau aktiviti log masuk luar biasa dan lindungi akaun ScienceBuddy daripada akses tidak sah.") %></p>
</div>

<div class="sl-stats">
    <div class="sl-stat s1"><div class="sl-stat-ico" style="color:#DC2626;"><i class="bi bi-shield-x"></i></div><div class="sl-stat-val"><asp:Literal ID="litSuspicious" runat="server" Text="0" /></div><div class="sl-stat-lbl"><%= T("Suspicious Attempts", "Percubaan Mencurigakan") %></div></div>
    <div class="sl-stat s2"><div class="sl-stat-ico" style="color:#7C3AED;"><i class="bi bi-lock-fill"></i></div><div class="sl-stat-val"><asp:Literal ID="litBlocked" runat="server" Text="0" /></div><div class="sl-stat-lbl"><%= T("Blocked Accounts", "Akaun Disekat") %></div></div>
    <div class="sl-stat s3"><div class="sl-stat-ico" style="color:#2563EB;"><i class="bi bi-x-circle-fill"></i></div><div class="sl-stat-val"><asp:Literal ID="litFailed" runat="server" Text="0" /></div><div class="sl-stat-lbl"><%= T("Failed Logins", "Log Masuk Gagal") %></div></div>
    <div class="sl-stat s4"><div class="sl-stat-ico" style="color:#059669;"><i class="bi bi-check-circle-fill"></i></div><div class="sl-stat-val"><asp:Literal ID="litResolved" runat="server" Text="0" /></div><div class="sl-stat-lbl"><%= T("Resolved", "Diselesaikan") %></div></div>
</div>

<div class="sl-search">
    <i class="bi bi-search text-muted"></i>
    <asp:TextBox ID="txtSearch" runat="server" CssClass="sb-input sb-input-sm" AutoPostBack="false" />
    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="sb-select sb-input-sm" AutoPostBack="false">
        <asp:ListItem Value="">All</asp:ListItem>
        <asp:ListItem Value="Failed">Failed</asp:ListItem>
        <asp:ListItem Value="Warning">Warning</asp:ListItem>
        <asp:ListItem Value="Success">Resolved</asp:ListItem>
    </asp:DropDownList>
    <asp:Button ID="btnSearch" runat="server" CssClass="sb-btn sb-btn-primary sb-btn-sm" OnClick="btnSearch_Click" />
    <asp:Button ID="btnReset" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnReset_Click" />
</div>

<div class="sl-card">
    <div class="sl-card-hdr"><i class="bi bi-exclamation-triangle-fill" style="color:var(--sl-accent);"></i> <%= T("Security Events", "Peristiwa Keselamatan") %></div>
    <asp:Panel ID="pnlLogs" runat="server" Visible="false">
        <div class="sb-table-wrapper" style="border:none;border-radius:0;box-shadow:none;">
            <table class="sb-table"><thead><tr>
                <th><%= T("User", "Pengguna") %></th><th><%= T("Action", "Tindakan") %></th><th><%= T("Description", "Penerangan") %></th><th><%= T("Date", "Tarikh") %></th><th><%= T("Status", "Status") %></th>
            </tr></thead><tbody>
                <asp:Repeater ID="rptLogs" runat="server">
                    <ItemTemplate>
                        <tr>
                            <td data-label="User"><strong><%# HttpUtility.HtmlEncode(Eval("username")) %></strong></td>
                            <td data-label="Action"><%# HttpUtility.HtmlEncode(Eval("action")) %></td>
                            <td data-label="Description"><span style="font-size:.8125rem;color:var(--color-text-secondary);"><%# HttpUtility.HtmlEncode(Eval("description")) %></span></td>
                            <td data-label="Date"><span style="font-size:.8125rem;color:var(--color-text-muted);"><%# Eval("dateStr") %></span></td>
                            <td data-label="Status"><span class='sb-badge <%# Eval("statusCls") %>'><%# HttpUtility.HtmlEncode(Eval("statusLabel")) %></span></td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody></table>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlEmpty" runat="server">
        <div class="sl-empty"><div class="sl-empty-ico"><i class="bi bi-shield-check"></i></div><div class="sl-empty-msg"><%= T("No suspicious activity detected.", "Tiada aktiviti mencurigakan dikesan.") %></div></div>
    </asp:Panel>
</div>
</asp:Content>
