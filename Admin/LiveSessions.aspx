<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LiveSessions.aspx.cs"
    Inherits="ScienceBuddy.Admin.LiveSessions" MasterPageFile="~/Site.Master"
    Title="Live Sessions" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--ls-accent:#4F46E5;--ls-accent-light:#EEF2FF;--ls-indigo:#6366F1;--ls-blue:#3B82F6;--ls-green:#10B981;--ls-red:#EF4444;--ls-cyan:#06B6D4;}
/* Header */
.ls-hero{background:linear-gradient(135deg,#4F46E5 0%,#6366F1 50%,#818CF8 100%);border-radius:var(--border-radius-xl);padding:var(--space-xl) var(--space-2xl);color:#fff;display:flex;align-items:center;justify-content:space-between;gap:var(--space-xl);margin-bottom:var(--space-xl);position:relative;overflow:hidden;box-shadow:0 12px 40px rgba(79,70,229,.25);}
.ls-hero::before{content:'';position:absolute;width:250px;height:250px;border-radius:50%;background:rgba(255,255,255,.05);top:-60px;right:-40px;pointer-events:none;}
.ls-hero::after{content:'';position:absolute;width:150px;height:150px;border-radius:50%;background:rgba(255,255,255,.04);bottom:-40px;left:60px;pointer-events:none;}
.ls-hero-title{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;line-height:1.2;margin-bottom:var(--space-xs);position:relative;z-index:1;}
.ls-hero-sub{font-size:.9375rem;opacity:.88;max-width:480px;line-height:1.5;position:relative;z-index:1;}
.ls-hero-icon{width:72px;height:72px;border-radius:var(--border-radius-xl);background:rgba(255,255,255,.15);border:2px solid rgba(255,255,255,.3);display:flex;align-items:center;justify-content:center;font-size:1.75rem;flex-shrink:0;position:relative;z-index:1;transition:transform .25s;}.ls-hero-icon:hover{transform:scale(1.05);}
/* Stats */
.ls-stats{display:grid;grid-template-columns:repeat(6,1fr);gap:var(--space-md);margin-bottom:var(--space-xl);}
.ls-stat{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);padding:var(--space-lg);display:flex;flex-direction:column;gap:var(--space-xs);transition:transform .25s,box-shadow .25s;position:relative;overflow:hidden;}
.ls-stat:hover{transform:translateY(-3px);box-shadow:var(--shadow-md);}
.ls-stat::before{content:'';position:absolute;top:0;left:0;right:0;height:3px;border-radius:3px 3px 0 0;}
.ls-stat.s1::before{background:linear-gradient(90deg,#4F46E5,#818CF8);}.ls-stat.s2::before{background:linear-gradient(90deg,#3B82F6,#60A5FA);}.ls-stat.s3::before{background:linear-gradient(90deg,#10B981,#34D399);}.ls-stat.s4::before{background:linear-gradient(90deg,#F59E0B,#FBBF24);}.ls-stat.s5::before{background:linear-gradient(90deg,#06B6D4,#22D3EE);}.ls-stat.s6::before{background:linear-gradient(90deg,#EC4899,#F472B6);}
.ls-stat-ico{font-size:1.25rem;color:var(--ls-accent);}.ls-stat-val{font-family:var(--font-primary);font-size:1.5rem;font-weight:800;color:var(--color-text);}.ls-stat-lbl{font-size:.75rem;color:var(--color-text-muted);font-weight:600;}
/* Search */
.ls-search{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-md);padding:var(--space-md) var(--space-xl);display:flex;align-items:center;gap:var(--space-md);flex-wrap:wrap;margin-bottom:var(--space-xl);transition:box-shadow .2s;position:sticky;top:calc(var(--topnav-height) + var(--space-sm));z-index:50;}
.ls-search:focus-within{box-shadow:0 8px 32px rgba(79,70,229,.1);}
.ls-search .sb-input{flex:1;min-width:160px;max-width:260px;}.ls-search .sb-select{max-width:150px;}
/* Table card */
.ls-table-card{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);overflow:hidden;margin-bottom:var(--space-xl);}
.ls-table-hdr{padding:var(--space-md) var(--space-lg);border-bottom:1px solid var(--border-color);font-family:var(--font-primary);font-weight:800;font-size:.9375rem;display:flex;align-items:center;gap:var(--space-sm);}
/* Modal fix */
.ls-modal-wrap .sb-modal-overlay{left:var(--sidebar-width);animation:ls-ovIn .2s ease both;}.sidebar-collapsed .ls-modal-wrap .sb-modal-overlay{left:var(--sidebar-collapsed);}
.ls-modal-wrap .sb-modal{animation:ls-mdIn .3s cubic-bezier(.34,1.56,.64,1) both;max-width:620px;max-height:90vh;overflow-y:auto;}
@keyframes ls-ovIn{from{opacity:0;}to{opacity:1;}}@keyframes ls-mdIn{from{opacity:0;transform:scale(.92) translateY(16px);}to{opacity:1;transform:scale(1) translateY(0);}}
.ls-modal-hdr{background:linear-gradient(135deg,var(--ls-accent),var(--ls-indigo));padding:var(--space-lg) var(--space-xl);color:#fff;border-radius:var(--border-radius-xl) var(--border-radius-xl) 0 0;display:flex;align-items:center;gap:var(--space-md);}
.ls-modal-hdr-ico{width:48px;height:48px;border-radius:var(--border-radius);background:rgba(255,255,255,.2);display:flex;align-items:center;justify-content:center;font-size:1.25rem;}
.ls-modal-hdr-title{font-family:var(--font-primary);font-size:1.125rem;font-weight:800;}
.ls-modal-body{padding:var(--space-xl);animation:ls-cFade .3s ease .1s both;}
@keyframes ls-cFade{from{opacity:0;transform:translateY(6px);}to{opacity:1;transform:translateY(0);}}
.ls-field{margin-bottom:var(--space-md);}.ls-label{font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;}.ls-value{font-size:.9375rem;font-weight:600;color:var(--color-text);}
.ls-participant{display:flex;align-items:center;gap:var(--space-sm);padding:var(--space-sm) var(--space-md);border-radius:var(--border-radius);border:1px solid var(--border-color);margin-bottom:var(--space-xs);transition:background .15s;}.ls-participant:hover{background:var(--color-surface-alt);}
.ls-participant-avatar{width:32px;height:32px;border-radius:50%;display:flex;align-items:center;justify-content:center;color:#fff;font-size:.75rem;font-weight:700;flex-shrink:0;}
.ls-participant-name{font-weight:600;font-size:.8125rem;color:var(--color-text);}.ls-participant-time{font-size:.75rem;color:var(--color-text-muted);margin-left:auto;}
/* Empty */
.ls-empty{display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;padding:var(--space-3xl);background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);}
.ls-empty-ico{font-size:3.5rem;margin-bottom:var(--space-lg);opacity:.3;color:var(--ls-accent);}.ls-empty-msg{font-size:1.125rem;font-weight:700;color:var(--color-text-secondary);}.ls-empty-sub{font-size:.875rem;color:var(--color-text-muted);margin-top:4px;max-width:380px;}
/* Responsive */
@media(max-width:1279px){.ls-stats{grid-template-columns:repeat(3,1fr);}}
@media(max-width:767px){.ls-hero{flex-direction:column;align-items:flex-start;padding:var(--space-lg);}.ls-hero-icon{display:none;}.ls-stats{grid-template-columns:repeat(2,1fr);}.ls-search{flex-direction:column;align-items:stretch;position:static;}.ls-search .sb-input,.ls-search .sb-select{max-width:100%;}.ls-modal-wrap .sb-modal-overlay{left:0;}}
@media(max-width:479px){.ls-stats{grid-template-columns:1fr;}}
@media(prefers-reduced-motion:reduce){.ls-hero-icon,.ls-stat,.ls-modal-wrap .sb-modal,.ls-modal-wrap .sb-modal-overlay{animation:none!important;transition-duration:.01ms!important;}}
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
        <a href="<%: ResolveUrl("~/Admin/LiveSessions.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-camera-video item-icon"></i><span class="item-label">Live Sessions</span></a>
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
        <a href="<%: ResolveUrl("~/Admin/SuspiciousLogins.aspx") %>" class="sb-sidebar-item"><i class="bi bi-exclamation-triangle item-icon"></i><span class="item-label">Suspicious Logins</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Admin/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span></a>
        <a href="<%: ResolveUrl("~/Admin/Profile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item" onclick="return confirm('Are you sure you want to sign out?');"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%= T("Live Session Monitoring", "Pemantauan Sesi Langsung") %></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<div style="margin-bottom:var(--space-xl);padding-bottom:var(--space-md);border-bottom:1.5px solid var(--border-color);">
    <h1 style="font-family:var(--font-primary);font-size:1.75rem;font-weight:800;color:var(--color-text);margin-bottom:var(--space-xs);"><%= T("Live Session Monitoring", "Pemantauan Sesi Langsung") %></h1>
    <p style="font-size:.9375rem;color:var(--color-text-secondary);max-width:560px;line-height:1.5;"><%= T("Monitor teacher-led live consultation sessions across ScienceBuddy.", "Pantau semua sesi pembelajaran langsung yang dikendalikan oleh guru di ScienceBuddy.") %></p>
</div>

<%-- STATS --%>
<div class="ls-stats">
    <div class="ls-stat s1"><div class="ls-stat-ico"><i class="bi bi-camera-video-fill"></i></div><div class="ls-stat-val"><asp:Literal ID="litTotalSessions" runat="server" Text="0" /></div><div class="ls-stat-lbl"><%= T("Total Sessions", "Jumlah Sesi") %></div></div>
    <div class="ls-stat s2"><div class="ls-stat-ico" style="color:#3B82F6;"><i class="bi bi-calendar-event"></i></div><div class="ls-stat-val"><asp:Literal ID="litUpcoming" runat="server" Text="0" /></div><div class="ls-stat-lbl"><%= T("Upcoming", "Akan Datang") %></div></div>
    <div class="ls-stat s3"><div class="ls-stat-ico" style="color:#10B981;"><i class="bi bi-check-circle-fill"></i></div><div class="ls-stat-val"><asp:Literal ID="litCompleted" runat="server" Text="0" /></div><div class="ls-stat-lbl"><%= T("Completed", "Selesai") %></div></div>
    <div class="ls-stat s4"><div class="ls-stat-ico" style="color:#F59E0B;"><i class="bi bi-person-badge-fill"></i></div><div class="ls-stat-val"><asp:Literal ID="litTeachers" runat="server" Text="0" /></div><div class="ls-stat-lbl"><%= T("Active Teachers", "Guru Aktif") %></div></div>
    <div class="ls-stat s5"><div class="ls-stat-ico" style="color:#06B6D4;"><i class="bi bi-people-fill"></i></div><div class="ls-stat-val"><asp:Literal ID="litAttendance" runat="server" Text="0" /></div><div class="ls-stat-lbl"><%= T("Total Attendance", "Jumlah Kehadiran") %></div></div>
    <div class="ls-stat s6"><div class="ls-stat-ico" style="color:#EC4899;"><i class="bi bi-graph-up-arrow"></i></div><div class="ls-stat-val"><asp:Literal ID="litAvgAttendance" runat="server" Text="0" /></div><div class="ls-stat-lbl"><%= T("Avg / Session", "Purata / Sesi") %></div></div>
</div>

<%-- SEARCH --%>
<div class="ls-search">
    <i class="bi bi-search text-muted"></i>
    <asp:TextBox ID="txtSearch" runat="server" CssClass="sb-input sb-input-sm" AutoPostBack="false" />
    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="sb-select sb-input-sm" AutoPostBack="false">
        <asp:ListItem Value="">All Status</asp:ListItem>
        <asp:ListItem Value="Upcoming">Upcoming</asp:ListItem>
        <asp:ListItem Value="Completed">Completed</asp:ListItem>
        <asp:ListItem Value="Cancelled">Cancelled</asp:ListItem>
    </asp:DropDownList>
    <asp:DropDownList ID="ddlTeacher" runat="server" CssClass="sb-select sb-input-sm" AutoPostBack="false" />
    <asp:DropDownList ID="ddlUnit" runat="server" CssClass="sb-select sb-input-sm" AutoPostBack="false" />
    <asp:Button ID="btnSearch" runat="server" CssClass="sb-btn sb-btn-primary sb-btn-sm" OnClick="btnSearch_Click" />
    <asp:Button ID="btnReset" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnReset_Click" />
</div>

<%-- TABLE --%>
<asp:Panel ID="pnlSessions" runat="server" Visible="false">
<div class="ls-table-card">
    <div class="ls-table-hdr"><i class="bi bi-list-ul" style="color:var(--ls-accent);"></i> <%= T("All Sessions", "Semua Sesi") %></div>
    <div class="sb-table-wrapper" style="border:none;border-radius:0;box-shadow:none;">
        <table class="sb-table">
            <thead><tr>
                <th><%= T("Title", "Tajuk") %></th>
                <th><%= T("Teacher", "Guru") %></th>
                <th><%= T("Unit", "Unit") %></th>
                <th><%= T("Start", "Mula") %></th>
                <th><%= T("Participants", "Peserta") %></th>
                <th><%= T("Status", "Status") %></th>
                <th></th>
            </tr></thead>
            <tbody>
                <asp:Repeater ID="rptSessions" runat="server" OnItemCommand="rptSessions_ItemCommand">
                    <ItemTemplate>
                        <tr>
                            <td data-label="Title"><strong><%# HttpUtility.HtmlEncode(Eval("title")) %></strong></td>
                            <td data-label="Teacher"><%# HttpUtility.HtmlEncode(Eval("teacherName")) %></td>
                            <td data-label="Unit"><%# HttpUtility.HtmlEncode(Eval("unitName")) %></td>
                            <td data-label="Start"><span style="font-size:.8125rem;color:var(--color-text-muted);"><%# Eval("startStr") %></span></td>
                            <td data-label="Participants"><span class="sb-badge sb-badge-primary"><%# Eval("participantCount") %> <%= T("students", "pelajar") %></span></td>
                            <td data-label="Status"><span class='sb-badge <%# Eval("statusCls") %>'><%# HttpUtility.HtmlEncode(Eval("statusLabel")) %></span></td>
                            <td class="col-actions">
                                <asp:LinkButton ID="lnkView" runat="server" CssClass="sb-btn sb-btn-outline-primary sb-btn-xs" CommandName="ViewSession" CommandArgument='<%# Eval("sessionId") %>' ToolTip="View Details">
                                    <i class="bi bi-eye"></i> <%= T("View", "Lihat") %>
                                </asp:LinkButton>
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody>
        </table>
    </div>
</div>
</asp:Panel>

<asp:Panel ID="pnlEmpty" runat="server">
    <div class="ls-empty">
        <div class="ls-empty-ico"><i class="bi bi-camera-video-off"></i></div>
        <div class="ls-empty-msg"><%= T("No Live Sessions Found", "Tiada Sesi Langsung Dijumpai") %></div>
        <div class="ls-empty-sub"><%= T("No teacher consultation sessions are currently available.", "Tiada sesi konsultasi guru tersedia pada masa ini.") %></div>
    </div>
</asp:Panel>

<%-- DETAIL MODAL --%>
<asp:Panel ID="pnlModal" runat="server" Visible="false" CssClass="ls-modal-wrap">
<div class="sb-modal-overlay active" style="display:flex;">
    <div class="sb-modal">
        <div class="ls-modal-hdr">
            <div class="ls-modal-hdr-ico"><i class="bi bi-camera-video-fill"></i></div>
            <div class="ls-modal-hdr-title"><%= T("Live Session Details", "Butiran Sesi Langsung") %></div>
        </div>
        <div class="ls-modal-body">
            <div class="ls-field"><div class="ls-label"><%= T("Session Title", "Tajuk Sesi") %></div><div class="ls-value"><asp:Literal ID="litMTitle" runat="server" /></div></div>
            <div class="ls-field"><div class="ls-label"><%= T("Description", "Penerangan") %></div><div class="ls-value"><asp:Literal ID="litMDesc" runat="server" /></div></div>
            <div class="ls-field"><div class="ls-label"><%= T("Teacher", "Guru") %></div><div class="ls-value"><asp:Literal ID="litMTeacher" runat="server" /></div></div>
            <div class="ls-field"><div class="ls-label"><%= T("Unit / Subtopic", "Unit / Subtopik") %></div><div class="ls-value"><asp:Literal ID="litMUnit" runat="server" /></div></div>
            <div class="ls-field"><div class="ls-label"><%= T("Schedule", "Jadual") %></div><div class="ls-value"><asp:Literal ID="litMSchedule" runat="server" /></div></div>
            <div class="ls-field"><div class="ls-label"><%= T("Meeting Link", "Pautan Mesyuarat") %></div><div class="ls-value"><asp:Literal ID="litMLink" runat="server" /></div></div>
            <div class="ls-field"><div class="ls-label"><%= T("Status", "Status") %></div><div class="ls-value"><asp:Literal ID="litMStatus" runat="server" /></div></div>
            <div class="ls-field"><div class="ls-label"><%= T("Participants", "Peserta") %> (<asp:Literal ID="litMCount" runat="server" Text="0" />)</div></div>
            <asp:Panel ID="pnlParticipants" runat="server" Visible="false">
                <asp:Repeater ID="rptParticipants" runat="server">
                    <ItemTemplate>
                        <div class="ls-participant">
                            <div class="ls-participant-avatar" style='<%# Eval("gradient") %>'><%# HttpUtility.HtmlEncode(Eval("initials")) %></div>
                            <span class="ls-participant-name"><%# HttpUtility.HtmlEncode(Eval("studentName")) %></span>
                            <span class="ls-participant-time"><%# Eval("joinedStr") %></span>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </asp:Panel>
            <asp:Panel ID="pnlNoParticipants" runat="server">
                <p style="font-size:.875rem;color:var(--color-text-muted);text-align:center;padding:var(--space-md) 0;"><%= T("No students joined this session.", "Tiada pelajar menyertai sesi ini.") %></p>
            </asp:Panel>
        </div>
        <div class="sb-modal-footer">
            <asp:Button ID="btnCloseModal" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnCloseModal_Click" />
        </div>
    </div>
</div>
</asp:Panel>

</asp:Content>
