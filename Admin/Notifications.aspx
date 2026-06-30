<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Notifications.aspx.cs"
    Inherits="ScienceBuddy.Admin.Notifications" MasterPageFile="~/Site.Master"
    Title="Notifications" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root { --admin:#2563EB; --admin-dark:#1D4ED8; --admin-light:#DBEAFE; }

/* Page header */
.an-page-header { margin-bottom:var(--space-xl); padding-bottom:var(--space-md); border-bottom:1.5px solid var(--border-color); }
.an-page-title { font-family:var(--font-primary); font-size:1.75rem; font-weight:800; color:var(--color-text); margin-bottom:var(--space-xs); }
.an-page-sub { font-size:.9375rem; color:var(--color-text-secondary); max-width:560px; line-height:1.5; }

/* Send card */
.an-send-card {
    background:var(--color-white); border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color); box-shadow:var(--shadow-sm);
    padding:var(--space-xl); margin-bottom:var(--space-xl);
}
.an-send-title {
    font-family:var(--font-primary); font-size:1.0625rem; font-weight:800;
    color:var(--color-text); margin-bottom:var(--space-lg);
    display:flex; align-items:center; gap:var(--space-sm);
}
.an-form-row { display:grid; grid-template-columns:1fr 1fr; gap:var(--space-md); margin-bottom:var(--space-md); }
.an-form-full { margin-bottom:var(--space-md); }
.an-form-label { display:block; font-weight:600; font-size:.875rem; color:var(--color-text); margin-bottom:var(--space-xs); }

/* Section header */
.an-sec-hd { display:flex; align-items:flex-start; justify-content:space-between; margin-bottom:var(--space-md); margin-top:var(--space-lg); flex-wrap:wrap; gap:var(--space-md); }
.an-sec-title { font-family:var(--font-primary); font-size:1.0625rem; font-weight:800; color:var(--color-text); display:flex; align-items:center; gap:var(--space-sm); }
.an-sec-sub { font-size:.8125rem; color:var(--color-text-muted); margin-top:2px; }

/* Filter bar */
.an-filter-bar {
    background:var(--color-white); border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color); box-shadow:var(--shadow-sm);
    padding:var(--space-md) var(--space-lg);
    display:flex; align-items:center; gap:var(--space-md); flex-wrap:wrap;
    margin-bottom:var(--space-md);
}
.an-filter-bar .sb-input { flex:1; min-width:160px; max-width:280px; }
.an-filter-bar .sb-select { max-width:160px; }

/* Table card */
.an-card {
    background:var(--color-white); border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color); box-shadow:var(--shadow-sm);
    overflow:hidden; margin-bottom:var(--space-xl);
}

/* Empty */
.an-empty { display:flex; flex-direction:column; align-items:center; justify-content:center; text-align:center; padding:var(--space-2xl) var(--space-xl); color:var(--color-text-muted); }
.an-empty-ico { font-size:2.75rem; margin-bottom:var(--space-md); opacity:.5; }
.an-empty-msg { font-size:.9375rem; font-weight:600; color:var(--color-text-secondary); }

/* Toast */
.an-toast { position:fixed; bottom:24px; right:24px; z-index:3000; max-width:400px; }

/* Responsive */
@media(max-width:767px) {
    .an-page-title { font-size:1.375rem; }
    .an-form-row { grid-template-columns:1fr; }
    .an-filter-bar { flex-direction:column; align-items:stretch; }
    .an-filter-bar .sb-input, .an-filter-bar .sb-select { max-width:100%; }
}
</style>
</asp:Content>

<%-- ════ SIDEBAR ════ --%>
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
        <a href="#" class="sb-sidebar-item"><i class="bi bi-box-arrow-in-right item-icon"></i><span class="item-label">Login Logs</span></a>
        <a href="<%: ResolveUrl("~/Admin/SuspiciousLogins.aspx") %>" class="sb-sidebar-item"><i class="bi bi-exclamation-triangle item-icon"></i><span class="item-label">Suspicious Logins</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Admin/Notifications.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span></a>
        <a href="<%: ResolveUrl("~/Admin/Profile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item" onclick="return confirm('Are you sure you want to sign out?');"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%= T("Notifications", "Notifikasi") %></asp:Content>

<%-- ════ MAIN CONTENT ════ --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- PAGE HEADER --%>
<div class="an-page-header">
    <h1 class="an-page-title"><%= T("Notifications", "Notifikasi") %></h1>
    <p class="an-page-sub"><%= T("Send notifications to users and manage all sent notifications.", "Hantar notifikasi kepada pengguna dan urus semua notifikasi yang dihantar.") %></p>
</div>

<%-- ══ SECTION 1: SEND NOTIFICATION ══ --%>
<div class="an-send-card">
    <div class="an-send-title"><i class="bi bi-send-fill" style="color:var(--admin);"></i> <%= T("Send Notification", "Hantar Notifikasi") %></div>

    <div class="an-form-full">
        <label class="an-form-label"><%= T("Recipient", "Penerima") %></label>
        <asp:DropDownList ID="ddlRecipient" runat="server" CssClass="sb-select" AutoPostBack="true" OnSelectedIndexChanged="ddlRecipient_Changed">
            <asp:ListItem Value="AllStudents">All Students / Semua Pelajar</asp:ListItem>
            <asp:ListItem Value="AllParents">All Parents / Semua Ibu Bapa</asp:ListItem>
            <asp:ListItem Value="AllTeachers">All Teachers / Semua Guru</asp:ListItem>
            <asp:ListItem Value="SpecificStudent">Specific Student / Pelajar Tertentu</asp:ListItem>
            <asp:ListItem Value="SpecificParent">Specific Parent / Ibu Bapa Tertentu</asp:ListItem>
            <asp:ListItem Value="SpecificTeacher">Specific Teacher / Guru Tertentu</asp:ListItem>
        </asp:DropDownList>
    </div>

    <asp:Panel ID="pnlIndividual" runat="server" Visible="false">
        <div class="an-form-full">
            <label class="an-form-label"><%= T("Select Recipient", "Pilih Penerima") %></label>
            <asp:DropDownList ID="ddlUser" runat="server" CssClass="sb-select" />
        </div>
    </asp:Panel>

    <div class="an-form-row">
        <div>
            <label class="an-form-label"><%= T("Title (EN)", "Tajuk (EN)") %></label>
            <asp:TextBox ID="txtTitleEN" runat="server" CssClass="sb-input" />
        </div>
        <div>
            <label class="an-form-label"><%= T("Title (BM)", "Tajuk (BM)") %></label>
            <asp:TextBox ID="txtTitleBM" runat="server" CssClass="sb-input" />
        </div>
    </div>
    <div class="an-form-row">
        <div>
            <label class="an-form-label"><%= T("Message (EN)", "Mesej (EN)") %></label>
            <asp:TextBox ID="txtMsgEN" runat="server" CssClass="sb-textarea" TextMode="MultiLine" Rows="3" />
        </div>
        <div>
            <label class="an-form-label"><%= T("Message (BM)", "Mesej (BM)") %></label>
            <asp:TextBox ID="txtMsgBM" runat="server" CssClass="sb-textarea" TextMode="MultiLine" Rows="3" />
        </div>
    </div>

    <asp:Button ID="btnSend" runat="server" CssClass="sb-btn sb-btn-primary" OnClick="btnSend_Click"
        OnClientClick="return confirm('Send this notification?');" />
    <asp:Label ID="lblSendMsg" runat="server" CssClass="sb-field-error" Visible="false" style="margin-left:var(--space-md);" />
</div>

<%-- ══ SECTION 2: SENT NOTIFICATIONS ══ --%>
<div class="an-sec-hd">
    <div>
        <div class="an-sec-title"><i class="bi bi-clock-history" style="color:#7C3AED;"></i> <%= T("Sent Notifications", "Notifikasi Dihantar") %></div>
        <div class="an-sec-sub"><%= T("All notifications sent from the admin panel.", "Semua notifikasi yang dihantar daripada panel pentadbir.") %></div>
    </div>
</div>

<div class="an-filter-bar">
    <i class="bi bi-search text-muted" style="font-size:1rem;flex-shrink:0;"></i>
    <asp:TextBox ID="txtSearch" runat="server" CssClass="sb-input sb-input-sm" AutoPostBack="false" />
    <asp:DropDownList ID="ddlFilter" runat="server" CssClass="sb-select sb-input-sm" AutoPostBack="false">
        <asp:ListItem Value="">All</asp:ListItem>
        <asp:ListItem Value="Unread">Unread</asp:ListItem>
        <asp:ListItem Value="Read">Read</asp:ListItem>
    </asp:DropDownList>
    <asp:Button ID="btnSearch" runat="server" CssClass="sb-btn sb-btn-primary sb-btn-sm" OnClick="btnSearch_Click" />
    <asp:Button ID="btnReset" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnReset_Click" />
</div>

<div class="an-card">
    <asp:Panel ID="pnlSent" runat="server" Visible="false">
        <div class="sb-table-wrapper" style="border:none;border-radius:0;box-shadow:none;">
            <table class="sb-table">
                <thead>
                    <tr>
                        <th><%= T("Recipient", "Penerima") %></th>
                        <th><%= T("Recipient Type", "Jenis Penerima") %></th>
                        <th><%= T("Title", "Tajuk") %></th>
                        <th><%= T("Date Sent", "Tarikh Dihantar") %></th>
                        <th><%= T("Status", "Status") %></th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptSent" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td data-label="Recipient"><%# HttpUtility.HtmlEncode(Eval("recipient")) %></td>
                                <td data-label="Type"><span class="sb-badge sb-badge-primary"><%# HttpUtility.HtmlEncode(Eval("recipientType")) %></span></td>
                                <td data-label="Title"><strong><%# HttpUtility.HtmlEncode(Eval("title")) %></strong></td>
                                <td data-label="Date"><span style="font-size:.8125rem;color:var(--color-text-muted);"><%# Eval("dateStr") %></span></td>
                                <td data-label="Status"><%# BuildReadBadge(Eval("isRead")) %></td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlEmpty" runat="server">
        <div class="an-empty">
            <div class="an-empty-ico">🔔</div>
            <div class="an-empty-msg"><%= T("No notifications sent yet.", "Tiada notifikasi yang dihantar lagi.") %></div>
        </div>
    </asp:Panel>
</div>

<%-- Toast --%>
<asp:Panel ID="pnlToast" runat="server" Visible="false">
    <asp:Literal ID="litToast" runat="server" />
</asp:Panel>

</asp:Content>
