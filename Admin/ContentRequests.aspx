<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ContentRequests.aspx.cs"
    Inherits="ScienceBuddy.Admin.ContentRequests" MasterPageFile="~/Site.Master"
    Title="Content Requests" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ── Content Requests page-scoped styles ── */
:root { --admin:#2563EB; --admin-dark:#1D4ED8; --admin-light:#DBEAFE; }

/* Re-use dashboard stat/card/section patterns */
.ad-stats { display:grid; grid-template-columns:repeat(4,1fr); gap:var(--space-md); margin-bottom:var(--space-xl); }
.ad-stat {
    background:var(--color-white); border-radius:var(--border-radius-lg);
    border:1.5px solid var(--border-color); box-shadow:var(--shadow-sm);
    padding:var(--space-lg); display:flex; flex-direction:column;
    gap:var(--space-sm); transition:transform .2s,box-shadow .2s;
    position:relative; overflow:hidden;
}
.ad-stat::before {
    content:''; position:absolute; top:0; left:0; right:0;
    height:4px; border-radius:var(--border-radius-lg) var(--border-radius-lg) 0 0;
}
.ad-stat:hover { transform:translateY(-3px); box-shadow:var(--shadow-md); }
.ad-stat.c-pending::before  { background:linear-gradient(90deg,#D97706,#FCD34D); }
.ad-stat.c-approved::before { background:linear-gradient(90deg,#059669,#34D399); }
.ad-stat.c-rejected::before { background:linear-gradient(90deg,#DC2626,#F87171); }
.ad-stat.c-total::before    { background:linear-gradient(90deg,#2563EB,#60A5FA); }
.ad-stat-icon {
    width:42px; height:42px; border-radius:var(--border-radius);
    display:flex; align-items:center; justify-content:center; font-size:1.25rem;
}
.ad-stat-val {
    font-family:var(--font-primary); font-size:1.875rem; font-weight:800;
    line-height:1; color:var(--color-text);
}
.ad-stat-lbl { font-size:.8125rem; color:var(--color-text-secondary); font-weight:600; }

/* Section header */
.ad-sec-hd {
    display:flex; align-items:flex-start; justify-content:space-between;
    margin-bottom:var(--space-md); gap:var(--space-md); flex-wrap:wrap;
    margin-top:var(--space-lg);
}
.ad-sec-title {
    font-family:var(--font-primary); font-size:1.0625rem; font-weight:800;
    color:var(--color-text); display:flex; align-items:center; gap:var(--space-sm);
}
.ad-sec-sub {
    font-size:.8125rem; color:var(--color-text-muted); margin-top:2px; font-weight:500;
}

/* Filter bar */
.cr-filter-bar {
    background:var(--color-white); border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color); box-shadow:var(--shadow-sm);
    padding:var(--space-md) var(--space-lg);
    display:flex; align-items:center; gap:var(--space-md);
    flex-wrap:wrap; margin-bottom:var(--space-xl);
}
.cr-filter-bar .sb-input,
.cr-filter-bar .sb-select { max-width:220px; }
.cr-filter-bar .sb-input  { flex:1; min-width:180px; max-width:320px; }

/* Card wrapper */
.ad-card {
    background:var(--color-white); border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color); box-shadow:var(--shadow-sm);
    overflow:hidden; margin-bottom:var(--space-xl);
}
.ad-card-hdr {
    padding:var(--space-md) var(--space-lg); border-bottom:1px solid var(--border-color);
    display:flex; align-items:center; justify-content:space-between; gap:var(--space-md);
}
.ad-card-hdr-title {
    font-family:var(--font-primary); font-weight:800; font-size:.9375rem;
    display:flex; align-items:center; gap:var(--space-sm);
}

/* Empty state */
.ad-empty {
    display:flex; flex-direction:column; align-items:center;
    justify-content:center; text-align:center;
    padding:var(--space-2xl) var(--space-xl); color:var(--color-text-muted);
}
.ad-empty-ico { font-size:2.75rem; margin-bottom:var(--space-md); }
.ad-empty-msg { font-size:.9375rem; font-weight:600; color:var(--color-text-secondary); }
.ad-empty-sub { font-size:.875rem; color:var(--color-text-muted); margin-top:4px; }

/* Action buttons inline */
.cr-actions { display:flex; gap:var(--space-xs); flex-wrap:nowrap; }

/* Page header (clean, no hero banner) */
.cr-page-header {
    margin-bottom:var(--space-xl);
    padding-bottom:var(--space-md);
    border-bottom:1.5px solid var(--border-color);
}
.cr-page-title {
    font-family:var(--font-primary); font-size:1.75rem; font-weight:800;
    color:var(--color-text); line-height:1.2; margin-bottom:var(--space-xs);
}
.cr-page-sub {
    font-size:.9375rem; color:var(--color-text-secondary); line-height:1.5;
    max-width:560px;
}

/* Responsive */
@media(max-width:1279px) { .ad-stats { grid-template-columns:repeat(2,1fr); } }
@media(max-width:767px) {
    .cr-page-title { font-size:1.375rem; }
    .ad-stats { grid-template-columns:repeat(2,1fr); }
    .cr-filter-bar { flex-direction:column; align-items:stretch; }
    .cr-filter-bar .sb-input,
    .cr-filter-bar .sb-select { max-width:100%; }
    .cr-actions { flex-wrap:wrap; }
}
@media(max-width:479px) { .ad-stats { grid-template-columns:1fr 1fr; } }
</style>
</asp:Content>

<%-- ════ SIDEBAR ════ --%>
<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Main</div>
        <a href="<%: ResolveUrl("~/Admin/Dashboard.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-speedometer2 item-icon"></i><span class="item-label">Dashboard</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">User Management</div>
        <a href="<%: ResolveUrl("~/Admin/StudentManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-people item-icon"></i><span class="item-label">Students</span></a>
        <a href="<%: ResolveUrl("~/Admin/ParentManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-heart item-icon"></i><span class="item-label">Parents</span></a>
        <a href="<%: ResolveUrl("~/Admin/TeacherManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-badge item-icon"></i><span class="item-label">Teachers</span></a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Learning Content</div>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label">Lessons</span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label">Quizzes</span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-question-circle item-icon"></i><span class="item-label">Questions</span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-file-earmark-text item-icon"></i><span class="item-label">Teacher Materials</span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label">Live Sessions</span></a>
        <a href="<%: ResolveUrl("~/Admin/ContentRequests.aspx") %>" class="sb-sidebar-item active">
            <i class="bi bi-inbox item-icon"></i><span class="item-label">Content Requests</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Gamification</div>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-trophy item-icon"></i><span class="item-label">Badges</span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-lightning item-icon"></i><span class="item-label">XP Actions</span></a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Configuration</div>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-gear item-icon"></i><span class="item-label">Quiz Settings</span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-shield-lock item-icon"></i><span class="item-label">Security Settings</span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-sliders item-icon"></i><span class="item-label">XP Settings</span></a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Logs</div>
        <a href="<%: ResolveUrl("~/Admin/SystemActivityLogs.aspx") %>" class="sb-sidebar-item"><i class="bi bi-clock-history item-icon"></i><span class="item-label">Activity Logs</span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-box-arrow-in-right item-icon"></i><span class="item-label">Login Logs</span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-exclamation-triangle item-icon"></i><span class="item-label">Suspicious Logins</span></a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Admin/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span></a>
        <a href="<%: ResolveUrl("~/Admin/Profile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item" onclick="return confirm('Are you sure you want to sign out?');"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">Content Requests</asp:Content>

<%-- ════ MAIN CONTENT ════ --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- ── 1. PAGE HEADER ── --%>
<div class="cr-page-header">
    <h1 class="cr-page-title"><%= T("Content Requests", "Permintaan Kandungan") %></h1>
    <p class="cr-page-sub"><%= T("Review, approve, or reject teacher-submitted learning content.", "Semak, luluskan, atau tolak kandungan pembelajaran yang dihantar oleh guru.") %></p>
</div>

<%-- ── 2. SUMMARY CARDS ── --%>
<div class="ad-stats">
    <div class="ad-stat c-pending">
        <div class="ad-stat-icon" style="background:#FEF3C7;color:#D97706;"><i class="bi bi-hourglass-split"></i></div>
        <div class="ad-stat-val"><asp:Literal ID="litPending" runat="server" Text="0" /></div>
        <div class="ad-stat-lbl"><%= T("Pending Requests", "Permintaan Tertunggak") %></div>
    </div>
    <div class="ad-stat c-approved">
        <div class="ad-stat-icon" style="background:#D1FAE5;color:#059669;"><i class="bi bi-check-circle-fill"></i></div>
        <div class="ad-stat-val"><asp:Literal ID="litApproved" runat="server" Text="0" /></div>
        <div class="ad-stat-lbl"><%= T("Approved", "Diluluskan") %></div>
    </div>
    <div class="ad-stat c-rejected">
        <div class="ad-stat-icon" style="background:#FEE2E2;color:#DC2626;"><i class="bi bi-x-circle-fill"></i></div>
        <div class="ad-stat-val"><asp:Literal ID="litRejected" runat="server" Text="0" /></div>
        <div class="ad-stat-lbl"><%= T("Rejected", "Ditolak") %></div>
    </div>
    <div class="ad-stat c-total">
        <div class="ad-stat-icon" style="background:#DBEAFE;color:#2563EB;"><i class="bi bi-collection-fill"></i></div>
        <div class="ad-stat-val"><asp:Literal ID="litTotal" runat="server" Text="0" /></div>
        <div class="ad-stat-lbl"><%= T("Total Requests", "Jumlah Permintaan") %></div>
    </div>
</div>

<%-- ── 3. SEARCH & FILTER ── --%>
<div class="cr-filter-bar">
    <i class="bi bi-search text-muted" style="font-size:1rem;flex-shrink:0;"></i>
    <asp:TextBox ID="txtSearch" runat="server" CssClass="sb-input sb-input-sm"
        AutoPostBack="false" />
    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="sb-select sb-input-sm"
        AutoPostBack="false">
        <asp:ListItem Value="">All Statuses</asp:ListItem>
        <asp:ListItem Value="Pending">Pending</asp:ListItem>
        <asp:ListItem Value="Approved">Approved</asp:ListItem>
        <asp:ListItem Value="Rejected">Rejected</asp:ListItem>
    </asp:DropDownList>
    <asp:DropDownList ID="ddlType" runat="server" CssClass="sb-select sb-input-sm"
        AutoPostBack="false">
        <asp:ListItem Value="">All Types</asp:ListItem>
        <asp:ListItem Value="Material">Material</asp:ListItem>
        <asp:ListItem Value="Practice Quiz">Practice Quiz</asp:ListItem>
    </asp:DropDownList>
    <asp:Button ID="btnSearch" runat="server" Text="Search"
        CssClass="sb-btn sb-btn-primary sb-btn-sm"
        OnClick="btnSearch_Click" />
    <asp:Button ID="btnReset" runat="server" Text="Reset"
        CssClass="sb-btn sb-btn-ghost sb-btn-sm"
        OnClick="btnReset_Click" />
</div>

<%-- ── 4. PENDING REQUESTS TABLE ── --%>
<div class="ad-sec-hd">
    <div>
        <div class="ad-sec-title">
            <i class="bi bi-hourglass-split" style="color:#D97706;"></i>
            <%= T("Pending Requests", "Permintaan Tertunggak") %>
            <asp:Literal ID="litPendingBadge" runat="server" />
        </div>
        <div class="ad-sec-sub"><%= T("Review new learning content awaiting approval.", "Semak kandungan pembelajaran baharu yang menunggu kelulusan.") %></div>
    </div>
</div>
<div class="ad-card">
    <asp:Panel ID="pnlPending" runat="server" Visible="false">
        <div class="sb-table-wrapper" style="border:none;border-radius:0;box-shadow:none;">
            <table class="sb-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Type</th>
                        <th>Title</th>
                        <th>Teacher</th>
                        <th>Unit</th>
                        <th>Subtopic</th>
                        <th>Language</th>
                        <th>Submitted</th>
                        <th>Status</th>
                        <th class="col-actions">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptPending" runat="server"
                        OnItemCommand="rptPending_ItemCommand">
                        <ItemTemplate>
                            <tr>
                                <td data-label="ID">
                                    <span style="font-size:.75rem;color:var(--color-text-muted);font-family:monospace;">
                                        <%# HtmlEncode(Eval("requestId")) %>
                                    </span>
                                </td>
                                <td data-label="Type">
                                    <span class='sb-badge <%# Eval("sourceType").ToString()=="Material" ? "sb-badge-secondary" : "sb-badge-yellow" %>'>
                                        <i class='bi <%# Eval("sourceType").ToString()=="Material" ? "bi-file-earmark-text" : "bi-patch-question" %>'></i>
                                        <%# HtmlEncode(Eval("sourceType")) %>
                                    </span>
                                </td>
                                <td data-label="Title">
                                    <span style="font-weight:600;color:var(--color-text);">
                                        <%# HtmlEncode(Eval("title")) %>
                                    </span>
                                </td>
                                <td data-label="Teacher"><%# HtmlEncode(Eval("teacherName")) %></td>
                                <td data-label="Unit"><%# HtmlEncode(Eval("unitName")) %></td>
                                <td data-label="Subtopic"><%# HtmlEncode(Eval("subtopicTitle")) %></td>
                                <td data-label="Language">
                                    <span class="sb-badge sb-badge-gray"><%# HtmlEncode(Eval("language")) %></span>
                                </td>
                                <td data-label="Submitted">
                                    <span style="font-size:.8125rem;color:var(--color-text-muted);">
                                        <%# Eval("submittedDate") %>
                                    </span>
                                </td>
                                <td data-label="Status">
                                    <span class="sb-badge sb-badge-warning">
                                        <i class="bi bi-hourglass-split"></i> Pending
                                    </span>
                                </td>
                                <td class="col-actions">
                                    <div class="cr-actions">
                                        <asp:LinkButton ID="lnkApprove" runat="server"
                                            CommandName="Approve"
                                            CommandArgument='<%# Eval("sourceType") + "|" + Eval("requestId") + "|" + Eval("teacherUserId") + "|" + Eval("teacherName") + "|" + Eval("title") %>'
                                            CssClass="sb-btn sb-btn-success sb-btn-xs"
                                            OnClientClick="return confirm('Approve this submission?');">
                                            <i class="bi bi-check-lg"></i> <%= T("Approve", "Luluskan") %>
                                        </asp:LinkButton>
                                        <asp:LinkButton ID="lnkReject" runat="server"
                                            CommandName="Reject"
                                            CommandArgument='<%# Eval("sourceType") + "|" + Eval("requestId") + "|" + Eval("teacherUserId") + "|" + Eval("teacherName") + "|" + Eval("title") %>'
                                            CssClass="sb-btn sb-btn-danger sb-btn-xs"
                                            OnClientClick="return confirm('Reject this submission?');">
                                            <i class="bi bi-x-lg"></i> <%= T("Reject", "Tolak") %>
                                        </asp:LinkButton>
                                    </div>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlPendingEmpty" runat="server">
        <div class="ad-empty">
            <div class="ad-empty-ico">🎉</div>
            <div class="ad-empty-msg"><%= T("Great! There are no pending content requests.", "Hebat! Tiada permintaan kandungan tertunggak.") %></div>
            <div class="ad-empty-sub"><%= T("All teacher submissions have been reviewed.", "Semua penghantaran guru telah disemak.") %></div>
        </div>
    </asp:Panel>
</div>

<%-- ── 5. REVIEWED HISTORY TABLE ── --%>
<div class="ad-sec-hd">
    <div>
        <div class="ad-sec-title">
            <i class="bi bi-clock-history" style="color:#7C3AED;"></i>
            <%= T("Approved / Rejected History", "Sejarah Diluluskan / Ditolak") %>
        </div>
        <div class="ad-sec-sub"><%= T("Previously reviewed teacher submissions.", "Penghantaran guru yang telah disemak sebelum ini.") %></div>
    </div>
</div>
<div class="ad-card">
    <asp:Panel ID="pnlHistory" runat="server" Visible="false">
        <div class="sb-table-wrapper" style="border:none;border-radius:0;box-shadow:none;">
            <table class="sb-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Type</th>
                        <th>Title</th>
                        <th>Teacher</th>
                        <th>Reviewed Date</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptHistory" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td data-label="ID">
                                    <span style="font-size:.75rem;color:var(--color-text-muted);font-family:monospace;">
                                        <%# HtmlEncode(Eval("requestId")) %>
                                    </span>
                                </td>
                                <td data-label="Type">
                                    <span class='sb-badge <%# Eval("sourceType").ToString()=="Material" ? "sb-badge-secondary" : "sb-badge-yellow" %>'>
                                        <i class='bi <%# Eval("sourceType").ToString()=="Material" ? "bi-file-earmark-text" : "bi-patch-question" %>'></i>
                                        <%# HtmlEncode(Eval("sourceType")) %>
                                    </span>
                                </td>
                                <td data-label="Title">
                                    <span style="font-weight:600;"><%# HtmlEncode(Eval("title")) %></span>
                                </td>
                                <td data-label="Teacher"><%# HtmlEncode(Eval("teacherName")) %></td>
                                <td data-label="Reviewed Date">
                                    <span style="font-size:.8125rem;color:var(--color-text-muted);">
                                        <%# Eval("reviewedDate") %>
                                    </span>
                                </td>
                                <td data-label="Status">
                                    <asp:Literal ID="litHistStatus" runat="server"
                                        Text='<%# BuildStatusBadge(Convert.ToString(Eval("status"))) %>' />
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlHistoryEmpty" runat="server">
        <div class="ad-empty">
            <div class="ad-empty-ico">📋</div>
            <div class="ad-empty-msg"><%= T("No reviewed requests yet.", "Tiada permintaan yang telah disemak.") %></div>
            <div class="ad-empty-sub"><%= T("Approved and rejected submissions will appear here.", "Penghantaran yang diluluskan dan ditolak akan dipaparkan di sini.") %></div>
        </div>
    </asp:Panel>
</div>

<%-- Toast notification --%>
<asp:Panel ID="pnlToast" runat="server" Visible="false">
    <div id="crToast" class="sb-alert" style="position:fixed;bottom:24px;right:24px;z-index:3000;max-width:380px;animation:sb-alert-in .3s ease;">
        <asp:Literal ID="litToast" runat="server" />
    </div>
</asp:Panel>

</asp:Content>
