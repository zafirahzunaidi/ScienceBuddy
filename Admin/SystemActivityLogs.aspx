<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SystemActivityLogs.aspx.cs"
    Inherits="ScienceBuddy.Admin.SystemActivityLogs" MasterPageFile="~/Site.Master"
    Title="Activity Logs" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--al-accent:#7C3AED;--al-accent-light:#F5F3FF;--al-purple:#8B5CF6;--al-blue:#3B82F6;--al-green:#10B981;--al-red:#EF4444;--al-orange:#F59E0B;}

/* Header card */
.al-header-card{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);padding:var(--space-xl) var(--space-2xl);display:flex;align-items:center;justify-content:space-between;gap:var(--space-lg);margin-bottom:var(--space-xl);flex-wrap:wrap;}
.al-header-title{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;color:var(--color-text);margin-bottom:var(--space-xs);}
.al-header-sub{font-size:.9375rem;color:var(--color-text-secondary);max-width:460px;line-height:1.5;}
.al-header-icon{width:72px;height:72px;border-radius:var(--border-radius-xl);background:linear-gradient(135deg,var(--al-accent),var(--al-purple));display:flex;align-items:center;justify-content:center;font-size:1.75rem;color:#fff;box-shadow:0 8px 24px rgba(124,58,237,.25);flex-shrink:0;transition:transform .25s;}.al-header-icon:hover{transform:scale(1.05);}

/* Stats */
.al-stats{display:grid;grid-template-columns:repeat(4,1fr);gap:var(--space-md);margin-bottom:var(--space-xl);}
.al-stat{border-radius:var(--border-radius-xl);padding:var(--space-lg);color:#fff;display:flex;flex-direction:column;gap:var(--space-xs);transition:transform .25s,box-shadow .25s;position:relative;overflow:hidden;}
.al-stat:hover{transform:translateY(-4px);box-shadow:var(--shadow-lg);}
.al-stat::after{content:'';position:absolute;width:90px;height:90px;border-radius:50%;background:rgba(255,255,255,.07);top:-20px;right:-20px;pointer-events:none;}
.al-stat.s-total{background:linear-gradient(135deg,#3B82F6,#60A5FA);}.al-stat.s-today{background:linear-gradient(135deg,#10B981,#34D399);}.al-stat.s-success{background:linear-gradient(135deg,#7C3AED,#A78BFA);}.al-stat.s-warn{background:linear-gradient(135deg,#EF4444,#F87171);}
.al-stat-ico{font-size:1.375rem;opacity:.85;}.al-stat-val{font-family:var(--font-primary);font-size:2rem;font-weight:800;line-height:1;}.al-stat-lbl{font-size:.8125rem;opacity:.85;font-weight:600;}.al-stat-trend{font-size:.6875rem;opacity:.7;margin-top:2px;}

/* Search */
.al-search{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-md);padding:var(--space-md) var(--space-xl);display:flex;align-items:center;gap:var(--space-md);flex-wrap:wrap;margin-bottom:var(--space-xl);transition:box-shadow .2s;position:sticky;top:calc(var(--topnav-height) + var(--space-sm));z-index:50;}
.al-search:focus-within{box-shadow:0 8px 32px rgba(124,58,237,.1);}
.al-search .sb-input{flex:1;min-width:160px;max-width:280px;}.al-search .sb-select{max-width:150px;}

/* Timeline */
.al-timeline{position:relative;padding-left:40px;}
.al-timeline::before{content:'';position:absolute;left:18px;top:0;bottom:0;width:2px;background:linear-gradient(180deg,var(--al-accent-light),var(--border-color));border-radius:2px;}
.al-date-group{margin-bottom:var(--space-xl);}
.al-date-label{font-family:var(--font-primary);font-size:.8125rem;font-weight:700;text-transform:uppercase;letter-spacing:1px;color:var(--al-accent);margin-bottom:var(--space-md);padding:4px 12px;background:var(--al-accent-light);border-radius:var(--border-radius-full);display:inline-block;position:relative;left:-40px;margin-left:40px;}
.al-item{background:var(--color-white);border-radius:var(--border-radius-lg);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);padding:var(--space-md) var(--space-lg);margin-bottom:var(--space-sm);display:flex;align-items:center;gap:var(--space-md);transition:transform .2s,box-shadow .2s,border-color .2s;position:relative;cursor:pointer;animation:al-slideIn .3s ease both;}
.al-item:nth-child(2){animation-delay:.03s;}.al-item:nth-child(3){animation-delay:.06s;}.al-item:nth-child(4){animation-delay:.09s;}.al-item:nth-child(5){animation-delay:.12s;}
.al-item:hover{transform:translateX(4px);box-shadow:0 6px 20px rgba(124,58,237,.08);border-color:var(--al-accent);}
@keyframes al-slideIn{from{opacity:0;transform:translateX(-12px);}to{opacity:1;transform:translateX(0);}}
/* Timeline dot */
.al-item::before{content:'';position:absolute;left:-30px;top:50%;transform:translateY(-50%);width:12px;height:12px;border-radius:50%;background:var(--al-accent-light);border:2.5px solid var(--al-accent);transition:transform .2s;}.al-item:hover::before{transform:translateY(-50%) scale(1.3);}
.al-ico{width:40px;height:40px;border-radius:var(--border-radius);display:flex;align-items:center;justify-content:center;font-size:1.1rem;flex-shrink:0;transition:transform .2s;}.al-item:hover .al-ico{transform:scale(1.1);}
.al-body{flex:1;min-width:0;}
.al-action{font-weight:700;font-size:.875rem;color:var(--color-text);}
.al-desc{font-size:.8125rem;color:var(--color-text-secondary);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;margin-top:1px;}
.al-meta{display:flex;align-items:center;gap:var(--space-sm);flex-shrink:0;}
.al-time{font-size:.75rem;color:var(--color-text-muted);white-space:nowrap;}

/* Modal */
.al-modal-wrap .sb-modal-overlay{left:var(--sidebar-width);animation:al-ovIn .2s ease both;}
.sidebar-collapsed .al-modal-wrap .sb-modal-overlay{left:var(--sidebar-collapsed);}
.al-modal-wrap .sb-modal{animation:al-mdIn .3s cubic-bezier(.34,1.56,.64,1) both;}
@keyframes al-ovIn{from{opacity:0;}to{opacity:1;}}
@keyframes al-mdIn{from{opacity:0;transform:scale(.92) translateY(16px);}to{opacity:1;transform:scale(1) translateY(0);}}
.al-modal-hdr{background:linear-gradient(135deg,var(--al-accent),var(--al-purple));padding:var(--space-lg) var(--space-xl);color:#fff;border-radius:var(--border-radius-xl) var(--border-radius-xl) 0 0;display:flex;align-items:center;gap:var(--space-md);}
.al-modal-hdr-ico{width:48px;height:48px;border-radius:var(--border-radius);background:rgba(255,255,255,.2);display:flex;align-items:center;justify-content:center;font-size:1.25rem;}
.al-modal-hdr-title{font-family:var(--font-primary);font-size:1.125rem;font-weight:800;}
.al-modal-body{padding:var(--space-xl);animation:al-contentFade .3s ease .1s both;}
@keyframes al-contentFade{from{opacity:0;transform:translateY(6px);}to{opacity:1;transform:translateY(0);}}
.al-modal-field{margin-bottom:var(--space-md);}.al-modal-label{font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;}.al-modal-value{font-size:.9375rem;font-weight:600;color:var(--color-text);}

/* Empty */
.al-empty{display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;padding:var(--space-3xl);background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);}
.al-empty-ico{font-size:4rem;margin-bottom:var(--space-lg);opacity:.3;color:var(--al-accent);}.al-empty-msg{font-size:1.125rem;font-weight:700;color:var(--color-text-secondary);}.al-empty-sub{font-size:.875rem;color:var(--color-text-muted);margin-top:4px;max-width:380px;}

/* Responsive */
@media(max-width:1279px){.al-stats{grid-template-columns:repeat(2,1fr);}}
@media(max-width:767px){.al-header-card{flex-direction:column;align-items:flex-start;}.al-header-icon{display:none;}.al-stats{grid-template-columns:1fr 1fr;}.al-search{flex-direction:column;align-items:stretch;position:static;}.al-search .sb-input,.al-search .sb-select{max-width:100%;}.al-timeline{padding-left:28px;}.al-item::before{left:-20px;}.al-timeline::before{left:8px;}.al-modal-wrap .sb-modal-overlay{left:0;}}
@media(max-width:479px){.al-stats{grid-template-columns:1fr;}}
@media(prefers-reduced-motion:reduce){.al-item,.al-stat,.al-modal-wrap .sb-modal,.al-modal-wrap .sb-modal-overlay,.al-ico,.al-header-icon{animation:none!important;transition-duration:.01ms!important;}}
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
        <a href="<%: ResolveUrl("~/Admin/ContentRequests.aspx") %>" class="sb-sidebar-item"><i class="bi bi-inbox item-icon"></i><span class="item-label">Content Requests</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Logs</div>
        <a href="<%: ResolveUrl("~/Admin/SystemActivityLogs.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-clock-history item-icon"></i><span class="item-label">Activity Logs</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Admin/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span></a>
        <a href="<%: ResolveUrl("~/Admin/Profile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item" onclick="return confirm('Are you sure you want to sign out?');"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%= T("Activity Logs", "Log Aktiviti") %></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- HEADER --%>
<div class="al-header-card">
    <div>
        <h1 class="al-header-title"><%= T("Activity Logs", "Log Aktiviti") %></h1>
        <p class="al-header-sub"><%= T("Monitor every important activity happening across ScienceBuddy.", "Pantau setiap aktiviti penting yang berlaku di ScienceBuddy.") %></p>
    </div>
    <div class="al-header-icon"><i class="bi bi-activity"></i></div>
</div>

<%-- STATS --%>
<div class="al-stats">
    <div class="al-stat s-total"><div class="al-stat-ico"><i class="bi bi-list-check"></i></div><div class="al-stat-val"><asp:Literal ID="litTotal" runat="server" Text="0" /></div><div class="al-stat-lbl"><%= T("Total Logs", "Jumlah Log") %></div><div class="al-stat-trend"><asp:Literal ID="litTotalTrend" runat="server" /></div></div>
    <div class="al-stat s-today"><div class="al-stat-ico"><i class="bi bi-calendar-check"></i></div><div class="al-stat-val"><asp:Literal ID="litToday" runat="server" Text="0" /></div><div class="al-stat-lbl"><%= T("Today's Activities", "Aktiviti Hari Ini") %></div><div class="al-stat-trend"><asp:Literal ID="litTodayTrend" runat="server" /></div></div>
    <div class="al-stat s-success"><div class="al-stat-ico"><i class="bi bi-check-circle"></i></div><div class="al-stat-val"><asp:Literal ID="litSuccess" runat="server" Text="0" /></div><div class="al-stat-lbl"><%= T("Successful", "Berjaya") %></div><div class="al-stat-trend"><asp:Literal ID="litSuccessTrend" runat="server" /></div></div>
    <div class="al-stat s-warn"><div class="al-stat-ico"><i class="bi bi-exclamation-triangle"></i></div><div class="al-stat-val"><asp:Literal ID="litWarn" runat="server" Text="0" /></div><div class="al-stat-lbl"><%= T("Warnings & Failed", "Amaran & Gagal") %></div><div class="al-stat-trend"><asp:Literal ID="litWarnTrend" runat="server" /></div></div>
</div>

<%-- SEARCH --%>
<div class="al-search">
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
    <div class="al-timeline">
        <asp:Repeater ID="rptLogs" runat="server" OnItemCommand="rptLogs_ItemCommand">
            <ItemTemplate>
                <asp:Panel ID="pnlDateHeader" runat="server" Visible='<%# Convert.ToBoolean(Eval("showDateHeader")) %>'>
                    <div class="al-date-label"><%# HttpUtility.HtmlEncode(Eval("dateLabel")) %></div>
                </asp:Panel>
                <div class="al-item">
                    <div class="al-ico" style='<%# Eval("icoStyle") %>'><i class='<%# Eval("icoClass") %>'></i></div>
                    <div class="al-body">
                        <div class="al-action"><%# HttpUtility.HtmlEncode(Eval("action")) %></div>
                        <div class="al-desc"><%# HttpUtility.HtmlEncode(Eval("description")) %></div>
                    </div>
                    <div class="al-meta">
                        <div class="al-time"><%# Eval("timeStr") %></div>
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
    <div class="al-empty">
        <div class="al-empty-ico"><i class="bi bi-clock-history"></i></div>
        <div class="al-empty-msg"><%= T("No Activity Yet", "Tiada Aktiviti Lagi") %></div>
        <div class="al-empty-sub"><%= T("System activities will appear here once users begin interacting with ScienceBuddy.", "Aktiviti sistem akan dipaparkan di sini setelah pengguna mula berinteraksi dengan ScienceBuddy.") %></div>
    </div>
</asp:Panel>

<%-- DETAIL MODAL --%>
<asp:Panel ID="pnlModal" runat="server" Visible="false" CssClass="al-modal-wrap">
<div class="sb-modal-overlay active" style="display:flex;">
    <div class="sb-modal" style="max-width:480px;">
        <div class="al-modal-hdr">
            <div class="al-modal-hdr-ico"><i class="bi bi-journal-text"></i></div>
            <div class="al-modal-hdr-title"><%= T("Activity Detail", "Butiran Aktiviti") %></div>
        </div>
        <div class="al-modal-body">
            <div class="al-modal-field"><div class="al-modal-label"><%= T("Log ID", "ID Log") %></div><div class="al-modal-value"><asp:Literal ID="litMLogId" runat="server" /></div></div>
            <div class="al-modal-field"><div class="al-modal-label"><%= T("User ID", "ID Pengguna") %></div><div class="al-modal-value"><asp:Literal ID="litMUserId" runat="server" /></div></div>
            <div class="al-modal-field"><div class="al-modal-label"><%= T("Action", "Tindakan") %></div><div class="al-modal-value"><asp:Literal ID="litMAction" runat="server" /></div></div>
            <div class="al-modal-field"><div class="al-modal-label"><%= T("Description", "Penerangan") %></div><div class="al-modal-value"><asp:Literal ID="litMDesc" runat="server" /></div></div>
            <div class="al-modal-field"><div class="al-modal-label"><%= T("Status", "Status") %></div><div class="al-modal-value"><asp:Literal ID="litMStatus" runat="server" /></div></div>
            <div class="al-modal-field"><div class="al-modal-label"><%= T("Date & Time", "Tarikh & Masa") %></div><div class="al-modal-value"><asp:Literal ID="litMDateTime" runat="server" /></div></div>
        </div>
        <div class="sb-modal-footer">
            <asp:Button ID="btnCloseModal" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnCloseModal_Click" />
        </div>
    </div>
</div>
</asp:Panel>

</asp:Content>
