<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LiveSessions.aspx.cs"
    Inherits="ScienceBuddy.Admin.LiveSessions" MasterPageFile="~/Site.Master"
    Title="Live Sessions" %>

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
        <a href="<%: ResolveUrl("~/Admin/LiveSessions.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-camera-video item-icon"></i><span class="item-label">Live Sessions</span></a>
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
        <a href="<%: ResolveUrl("~/Admin/LoginLogs.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-in-right item-icon"></i><span class="item-label">Login Logs</span></a>
        <a href="<%: ResolveUrl("~/Admin/SuspiciousLogins.aspx") %>" class="sb-sidebar-item"><i class="bi bi-exclamation-triangle item-icon"></i><span class="item-label">Suspicious Logins</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Admin/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span></a>
        <a href="<%: ResolveUrl("~/Admin/Profile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a>
        <a href="javascript:;" class="sb-sidebar-item" onclick="showSignOutModal()"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%= T("Live Session Monitoring", "Pemantauan Sesi Langsung") %></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<div style="margin-bottom:var(--space-xl);padding-bottom:var(--space-md);border-bottom:1.5px solid var(--border-color);">
    <h1 style="font-family:var(--font-primary);font-size:1.75rem;font-weight:800;color:var(--color-text);margin-bottom:var(--space-xs);"><%= T("Live Session Monitoring", "Pemantauan Sesi Langsung") %></h1>
    <p style="font-size:.9375rem;color:var(--color-text-secondary);max-width:560px;line-height:1.5;"><%= T("Monitor teacher-led live consultation sessions across ScienceBuddy.", "Pantau semua sesi pembelajaran langsung yang dikendalikan oleh guru di ScienceBuddy.") %></p>
</div>

<%-- STATS --%>
<div class="ad-live-session-stats">
    <div class="ad-live-session-stat s1"><div class="ad-live-session-stat-ico"><i class="bi bi-camera-video-fill"></i></div><div class="ad-live-session-stat-val"><asp:Literal ID="litTotalSessions" runat="server" Text="0" /></div><div class="ad-live-session-stat-lbl"><%= T("Total Sessions", "Jumlah Sesi") %></div></div>
    <div class="ad-live-session-stat s2"><div class="ad-live-session-stat-ico" style="color:#3B82F6;"><i class="bi bi-calendar-event"></i></div><div class="ad-live-session-stat-val"><asp:Literal ID="litUpcoming" runat="server" Text="0" /></div><div class="ad-live-session-stat-lbl"><%= T("Upcoming", "Akan Datang") %></div></div>
    <div class="ad-live-session-stat s3"><div class="ad-live-session-stat-ico" style="color:#10B981;"><i class="bi bi-check-circle-fill"></i></div><div class="ad-live-session-stat-val"><asp:Literal ID="litCompleted" runat="server" Text="0" /></div><div class="ad-live-session-stat-lbl"><%= T("Completed", "Selesai") %></div></div>
    <div class="ad-live-session-stat s4"><div class="ad-live-session-stat-ico" style="color:#F59E0B;"><i class="bi bi-person-badge-fill"></i></div><div class="ad-live-session-stat-val"><asp:Literal ID="litTeachers" runat="server" Text="0" /></div><div class="ad-live-session-stat-lbl"><%= T("Active Teachers", "Guru Aktif") %></div></div>
    <div class="ad-live-session-stat s5"><div class="ad-live-session-stat-ico" style="color:#06B6D4;"><i class="bi bi-people-fill"></i></div><div class="ad-live-session-stat-val"><asp:Literal ID="litAttendance" runat="server" Text="0" /></div><div class="ad-live-session-stat-lbl"><%= T("Total Attendance", "Jumlah Kehadiran") %></div></div>
    <div class="ad-live-session-stat s6"><div class="ad-live-session-stat-ico" style="color:#EC4899;"><i class="bi bi-graph-up-arrow"></i></div><div class="ad-live-session-stat-val"><asp:Literal ID="litAvgAttendance" runat="server" Text="0" /></div><div class="ad-live-session-stat-lbl"><%= T("Avg / Session", "Purata / Sesi") %></div></div>
</div>

<%-- SEARCH --%>
<div class="ad-live-session-search">
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
<div class="ad-live-session-table-card">
    <div class="ad-live-session-table-hdr"><i class="bi bi-list-ul" style="color:var(--ad-live-session-accent);"></i> <%= T("All Sessions", "Semua Sesi") %></div>
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
    <div class="ad-live-session-empty">
        <div class="ad-live-session-empty-ico"><i class="bi bi-camera-video-off"></i></div>
        <div class="ad-live-session-empty-msg"><%= T("No Live Sessions Found", "Tiada Sesi Langsung Dijumpai") %></div>
        <div class="ad-live-session-empty-sub"><%= T("No teacher consultation sessions are currently available.", "Tiada sesi konsultasi guru tersedia pada masa ini.") %></div>
    </div>
</asp:Panel>

<%-- DETAIL MODAL --%>
<asp:Panel ID="pnlModal" runat="server" Visible="false" Cssclass="ad-live-session-modal-wrap">
<div class="sb-modal-overlay active" style="display:flex;">
    <div class="sb-modal">
        <div class="ad-live-session-modal-hdr">
            <div class="ad-live-session-modal-hdr-ico"><i class="bi bi-camera-video-fill"></i></div>
            <div class="ad-live-session-modal-hdr-title"><%= T("Live Session Details", "Butiran Sesi Langsung") %></div>
        </div>
        <div class="ad-live-session-modal-body">
            <div class="ad-live-session-field"><div class="ad-live-session-label"><%= T("Session Title", "Tajuk Sesi") %></div><div class="ad-live-session-value"><asp:Literal ID="litMTitle" runat="server" /></div></div>
            <div class="ad-live-session-field"><div class="ad-live-session-label"><%= T("Description", "Penerangan") %></div><div class="ad-live-session-value"><asp:Literal ID="litMDesc" runat="server" /></div></div>
            <div class="ad-live-session-field"><div class="ad-live-session-label"><%= T("Teacher", "Guru") %></div><div class="ad-live-session-value"><asp:Literal ID="litMTeacher" runat="server" /></div></div>
            <div class="ad-live-session-field"><div class="ad-live-session-label"><%= T("Unit / Subtopic", "Unit / Subtopik") %></div><div class="ad-live-session-value"><asp:Literal ID="litMUnit" runat="server" /></div></div>
            <div class="ad-live-session-field"><div class="ad-live-session-label"><%= T("Schedule", "Jadual") %></div><div class="ad-live-session-value"><asp:Literal ID="litMSchedule" runat="server" /></div></div>
            <div class="ad-live-session-field"><div class="ad-live-session-label"><%= T("Meeting Link", "Pautan Mesyuarat") %></div><div class="ad-live-session-value"><asp:Literal ID="litMLink" runat="server" /></div></div>
            <div class="ad-live-session-field"><div class="ad-live-session-label"><%= T("Status", "Status") %></div><div class="ad-live-session-value"><asp:Literal ID="litMStatus" runat="server" /></div></div>
            <div class="ad-live-session-field"><div class="ad-live-session-label"><%= T("Participants", "Peserta") %> (<asp:Literal ID="litMCount" runat="server" Text="0" />)</div></div>
            <asp:Panel ID="pnlParticipants" runat="server" Visible="false">
                <asp:Repeater ID="rptParticipants" runat="server">
                    <ItemTemplate>
                        <div class="ad-live-session-participant">
                            <div class="ad-live-session-participant-avatar" style='<%# Eval("gradient") %>'><%# HttpUtility.HtmlEncode(Eval("initials")) %></div>
                            <span class="ad-live-session-participant-name"><%# HttpUtility.HtmlEncode(Eval("studentName")) %></span>
                            <span class="ad-live-session-participant-time"><%# Eval("joinedStr") %></span>
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
