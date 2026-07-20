<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Notifications.aspx.cs"
    Inherits="ScienceBuddy.Admin.Notifications" MasterPageFile="~/Site.Master"
    Title="Notifications" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%: ResolveUrl("~/Content/Admin.css") %>" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" />
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="<%: ResolveUrl("~/Scripts/admin-signout.js") %>"></script>
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
        <a href="<%: ResolveUrl("~/Admin/LoginLogs.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-in-right item-icon"></i><span class="item-label">Login Logs</span></a>
        <a href="<%: ResolveUrl("~/Admin/SuspiciousLogins.aspx") %>" class="sb-sidebar-item"><i class="bi bi-exclamation-triangle item-icon"></i><span class="item-label">Suspicious Logins</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Admin/Notifications.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span></a>
        <a href="<%: ResolveUrl("~/Admin/Profile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a>
        <a href="javascript:;" class="sb-sidebar-item" onclick="showSignOutModal()"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%= T("Notifications", "Notifikasi") %></asp:Content>

<%-- ════ MAIN CONTENT ════ --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- PAGE HEADER --%>
<div class="ad-notification-page-header">
    <h1 class="ad-notification-page-title"><%= T("Notifications", "Notifikasi") %></h1>
    <p class="ad-notification-page-sub"><%= T("Send notifications to users and manage all sent notifications.", "Hantar notifikasi kepada pengguna dan urus semua notifikasi yang dihantar.") %></p>
</div>

<%-- ══ SECTION 1: SEND NOTIFICATION ══ --%>
<div class="ad-notification-send-card">
    <div class="ad-notification-send-title"><i class="bi bi-send-fill" style="color:var(--ad-notification-accent);"></i> <%= T("Send Notification", "Hantar Notifikasi") %></div>

    <div class="ad-notification-form-full">
        <label class="ad-notification-form-label"><%= T("Recipient", "Penerima") %></label>
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
        <div class="ad-notification-form-full">
            <label class="ad-notification-form-label"><%= T("Select Recipient", "Pilih Penerima") %></label>
            <asp:DropDownList ID="ddlUser" runat="server" CssClass="sb-select" />
        </div>
    </asp:Panel>

    <div class="ad-notification-form-row">
        <div>
            <label class="ad-notification-form-label"><%= T("Title (EN)", "Tajuk (EN)") %></label>
            <asp:TextBox ID="txtTitleEN" runat="server" CssClass="sb-input" />
        </div>
        <div>
            <label class="ad-notification-form-label"><%= T("Title (BM)", "Tajuk (BM)") %></label>
            <asp:TextBox ID="txtTitleBM" runat="server" CssClass="sb-input" />
        </div>
    </div>
    <div class="ad-notification-form-row">
        <div>
            <label class="ad-notification-form-label"><%= T("Message (EN)", "Mesej (EN)") %></label>
            <asp:TextBox ID="txtMsgEN" runat="server" CssClass="sb-textarea" TextMode="MultiLine" Rows="3" />
        </div>
        <div>
            <label class="ad-notification-form-label"><%= T("Message (BM)", "Mesej (BM)") %></label>
            <asp:TextBox ID="txtMsgBM" runat="server" CssClass="sb-textarea" TextMode="MultiLine" Rows="3" />
        </div>
    </div>

    <asp:Button ID="btnSend" runat="server" CssClass="sb-btn sb-btn-primary" OnClick="btnSend_Click"
        OnClientClick="return confirm('Send this notification?');" />
    <asp:Label ID="lblSendMsg" runat="server" CssClass="sb-field-error" Visible="false" style="margin-left:var(--space-md);" />
</div>

<%-- ══ SECTION 2: SENT NOTIFICATIONS ══ --%>
<div class="ad-notification-sec-hd">
    <div>
        <div class="ad-notification-sec-title"><i class="bi bi-clock-history" style="color:#7C3AED;"></i> <%= T("Sent Notifications", "Notifikasi Dihantar") %></div>
        <div class="ad-notification-sec-sub"><%= T("All notifications sent from the admin panel.", "Semua notifikasi yang dihantar daripada panel pentadbir.") %></div>
    </div>
</div>

<div class="ad-notification-filter-bar">
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

<div class="ad-notification-card">
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
                        <th style="text-align:center;"><%= T("Action", "Tindakan") %></th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptSent" runat="server" OnItemCommand="rptSent_ItemCommand">
                        <ItemTemplate>
                            <tr>
                                <td data-label="Recipient"><%# HttpUtility.HtmlEncode(Eval("recipient")) %></td>
                                <td data-label="Type"><span class="sb-badge sb-badge-primary"><%# HttpUtility.HtmlEncode(Eval("recipientType")) %></span></td>
                                <td data-label="Title"><strong><%# HttpUtility.HtmlEncode(Eval("title")) %></strong></td>
                                <td data-label="Date"><span style="font-size:.8125rem;color:var(--color-text-muted);"><%# Eval("dateStr") %></span></td>
                                <td data-label="Status"><%# BuildReadBadge(Eval("isRead")) %></td>
                                <td class="col-actions" style="text-align:center;">
                                    <asp:LinkButton ID="lnkView" runat="server" CssClass="sb-btn sb-btn-outline-primary sb-btn-xs" CommandName="ViewNotification" CommandArgument='<%# Eval("notificationId") %>'>
                                        <i class="bi bi-eye"></i> <%= T("View", "Lihat") %>
                                    </asp:LinkButton>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlEmpty" runat="server">
        <div class="ad-notification-empty">
            <div class="ad-notification-empty-ico">🔔</div>
            <div class="ad-notification-empty-msg"><%= T("No notifications sent yet.", "Tiada notifikasi yang dihantar lagi.") %></div>
        </div>
    </asp:Panel>
</div>

<%-- Toast --%>
<asp:Panel ID="pnlToast" runat="server" Visible="false">
    <asp:Literal ID="litToast" runat="server" />
</asp:Panel>

<%-- VIEW NOTIFICATION MODAL --%>
<asp:Panel ID="pnlModal" runat="server" Visible="false" CssClass="ad-lesson-management-modal-wrap">
<div class="sb-modal-overlay active" style="display:flex;">
    <div class="sb-modal" style="max-width:720px;width:94vw;max-height:92vh;overflow-y:auto;">
        <%-- Gradient Header --%>
        <div style="background:linear-gradient(135deg,#2563EB,#7C3AED);padding:var(--space-lg) var(--space-xl);color:#fff;border-radius:var(--border-radius-xl) var(--border-radius-xl) 0 0;display:flex;align-items:center;gap:var(--space-md);">
            <div style="width:44px;height:44px;border-radius:var(--border-radius);background:rgba(255,255,255,.2);display:flex;align-items:center;justify-content:center;font-size:1.25rem;"><i class="bi bi-bell-fill"></i></div>
            <div>
                <div style="font-family:var(--font-primary);font-size:1.125rem;font-weight:800;"><%= T("Notification Details", "Maklumat Notifikasi") %></div>
                <div style="font-size:.8125rem;opacity:.8;"><asp:Literal ID="litMNotifId" runat="server" /></div>
            </div>
        </div>

        <%-- Section 1: Notification Information --%>
        <div style="padding:var(--space-xl);">
            <div style="font-size:.75rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:var(--space-md);display:flex;align-items:center;gap:4px;"><i class="bi bi-info-circle"></i> <%= T("Notification Information", "Maklumat Notifikasi") %></div>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:var(--space-md);">
                <div><div style="font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;"><%= T("Notification ID", "ID Notifikasi") %></div><div style="font-size:.9375rem;font-weight:600;color:var(--color-text);"><asp:Literal ID="litMId" runat="server" /></div></div>
                <div><div style="font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;"><%= T("Recipient Name", "Nama Penerima") %></div><div style="font-size:.9375rem;font-weight:600;color:var(--color-text);"><asp:Literal ID="litMRecipientName" runat="server" /></div></div>
                <div><div style="font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;"><%= T("Recipient Username", "Nama Pengguna") %></div><div style="font-size:.9375rem;font-weight:600;color:var(--color-text);"><asp:Literal ID="litMRecipientUsername" runat="server" /></div></div>
                <div><div style="font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;"><%= T("Recipient Role", "Peranan Penerima") %></div><div style="font-size:.9375rem;font-weight:600;color:var(--color-text);"><asp:Literal ID="litMRecipientRole" runat="server" /></div></div>
                <div><div style="font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;"><%= T("Status", "Status") %></div><div style="font-size:.9375rem;font-weight:600;"><asp:Literal ID="litMStatus" runat="server" /></div></div>
                <div><div style="font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;"><%= T("Date Sent", "Tarikh Dihantar") %></div><div style="font-size:.9375rem;font-weight:600;color:var(--color-text);"><asp:Literal ID="litMDateSent" runat="server" /></div></div>
            </div>
        </div>

        <%-- Section 2: Notification Content --%>
        <div style="padding:0 var(--space-xl) var(--space-xl);">
            <div style="font-size:.75rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:var(--space-md);display:flex;align-items:center;gap:4px;"><i class="bi bi-chat-text"></i> <%= T("Notification Content", "Kandungan Notifikasi") %></div>

            <%-- Icon + Title EN --%>
            <div style="margin-bottom:var(--space-md);">
                <div style="font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;"><%= T("Title (English)", "Tajuk (Bahasa Inggeris)") %></div>
                <div style="font-size:.9375rem;font-weight:600;color:var(--color-text);display:flex;align-items:center;gap:6px;"><asp:Literal ID="litMIconTitle" runat="server" /></div>
            </div>

            <%-- Title BM --%>
            <div style="margin-bottom:var(--space-md);">
                <div style="font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;"><%= T("Title (Bahasa Melayu)", "Tajuk (Bahasa Melayu)") %></div>
                <div style="font-size:.9375rem;font-weight:600;color:var(--color-text);"><asp:Literal ID="litMTitleBM" runat="server" /></div>
            </div>

            <%-- Message EN --%>
            <div style="margin-bottom:var(--space-md);">
                <div style="font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:var(--space-sm);"><%= T("Message (English)", "Mesej (Bahasa Inggeris)") %></div>
                <div style="background:var(--color-surface-alt);border-radius:var(--border-radius-lg);padding:var(--space-lg);font-size:.875rem;color:var(--color-text);line-height:1.7;max-height:200px;overflow-y:auto;">
                    <asp:Literal ID="litMMsgEN" runat="server" />
                </div>
            </div>

            <%-- Message BM --%>
            <div>
                <div style="font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:var(--space-sm);"><%= T("Message (Bahasa Melayu)", "Mesej (Bahasa Melayu)") %></div>
                <div style="background:var(--color-surface-alt);border-radius:var(--border-radius-lg);padding:var(--space-lg);font-size:.875rem;color:var(--color-text);line-height:1.7;max-height:200px;overflow-y:auto;">
                    <asp:Literal ID="litMMsgBM" runat="server" />
                </div>
            </div>
        </div>

        <%-- Footer --%>
        <div class="sb-modal-footer"><asp:Button ID="btnCloseModal" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnCloseModal_Click" /></div>
    </div>
</div>
</asp:Panel>

</asp:Content>
