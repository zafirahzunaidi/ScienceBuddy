<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SuspiciousLogins.aspx.cs"
    Inherits="ScienceBuddy.Admin.SuspiciousLogins" MasterPageFile="~/Site.Master"
    Title="Suspicious Logins" %>

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
        <a href="<%: ResolveUrl("~/Admin/LoginLogs.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-in-right item-icon"></i><span class="item-label">Login Logs</span></a>
        <a href="<%: ResolveUrl("~/Admin/SuspiciousLogins.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-exclamation-triangle item-icon"></i><span class="item-label">Suspicious Logins</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Admin/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span></a>
        <a href="<%: ResolveUrl("~/Admin/Profile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a>
        <a href="javascript:;" class="sb-sidebar-item" onclick="showSignOutModal()"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%= T("Suspicious Logins", "Log Masuk Mencurigakan") %></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="ad-suspicious-logins-header">
    <h1 class="ad-suspicious-logins-title"><i class="bi bi-shield-exclamation" style="color:var(--ad-suspicious-logins-accent);"></i> <%= T("Suspicious Login Monitoring", "Pemantauan Log Masuk Mencurigakan") %></h1>
    <p class="ad-suspicious-logins-sub"><%= T("Monitor unusual login behaviour and protect ScienceBuddy accounts from unauthorized access.", "Pantau aktiviti log masuk luar biasa dan lindungi akaun ScienceBuddy daripada akses tidak sah.") %></p>
</div>

<div class="ad-suspicious-logins-stats">
    <div class="ad-suspicious-logins-stat s1"><div class="ad-suspicious-logins-stat-ico" style="color:#DC2626;"><i class="bi bi-shield-x"></i></div><div class="ad-suspicious-logins-stat-val"><asp:Literal ID="litSuspicious" runat="server" Text="0" /></div><div class="ad-suspicious-logins-stat-lbl"><%= T("Suspicious Attempts", "Percubaan Mencurigakan") %></div></div>
    <div class="ad-suspicious-logins-stat s2"><div class="ad-suspicious-logins-stat-ico" style="color:#7C3AED;"><i class="bi bi-lock-fill"></i></div><div class="ad-suspicious-logins-stat-val"><asp:Literal ID="litBlocked" runat="server" Text="0" /></div><div class="ad-suspicious-logins-stat-lbl"><%= T("Blocked Accounts", "Akaun Disekat") %></div></div>
    <div class="ad-suspicious-logins-stat s3"><div class="ad-suspicious-logins-stat-ico" style="color:#2563EB;"><i class="bi bi-x-circle-fill"></i></div><div class="ad-suspicious-logins-stat-val"><asp:Literal ID="litFailed" runat="server" Text="0" /></div><div class="ad-suspicious-logins-stat-lbl"><%= T("Failed Logins", "Log Masuk Gagal") %></div></div>
    <div class="ad-suspicious-logins-stat s4"><div class="ad-suspicious-logins-stat-ico" style="color:#059669;"><i class="bi bi-check-circle-fill"></i></div><div class="ad-suspicious-logins-stat-val"><asp:Literal ID="litResolved" runat="server" Text="0" /></div><div class="ad-suspicious-logins-stat-lbl"><%= T("Resolved", "Diselesaikan") %></div></div>
</div>

<div class="ad-suspicious-logins-search">
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

<div class="ad-suspicious-logins-card">
    <div class="ad-suspicious-logins-card-hdr"><i class="bi bi-exclamation-triangle-fill" style="color:var(--ad-suspicious-logins-accent);"></i> <%= T("Security Events", "Peristiwa Keselamatan") %></div>
    <asp:Panel ID="pnlLogs" runat="server" Visible="false">
        <div class="sb-table-wrapper" style="border:none;border-radius:0;box-shadow:none;overflow-x:auto;">
            <table class="sb-table" style="width:100%;"><thead><tr>
                <th><%= T("User", "Pengguna") %></th><th><%= T("Action", "Tindakan") %></th><th><%= T("Description", "Penerangan") %></th><th><%= T("Date", "Tarikh") %></th><th style="text-align:center;min-width:100px;"><%= T("Status", "Status") %></th><th style="text-align:center;"><%= T("Actions", "Tindakan") %></th>
            </tr></thead><tbody>
                <asp:Repeater ID="rptLogs" runat="server" OnItemCommand="rptLogs_ItemCommand">
                    <ItemTemplate>
                        <tr>
                            <td data-label="User"><strong><%# HttpUtility.HtmlEncode(Eval("username")) %></strong></td>
                            <td data-label="Action"><%# HttpUtility.HtmlEncode(Eval("action")) %></td>
                            <td data-label="Description"><span style="font-size:.8125rem;color:var(--color-text-secondary);"><%# HttpUtility.HtmlEncode(Eval("description")) %></span></td>
                            <td data-label="Date"><span style="font-size:.8125rem;color:var(--color-text-muted);"><%# Eval("dateStr") %></span></td>
                            <td data-label="Status" style="text-align:center;"><span class='sb-badge <%# Eval("statusCls") %>'><%# HttpUtility.HtmlEncode(Eval("statusLabel")) %></span></td>
                            <td class="col-actions">
                                <asp:LinkButton ID="lnkBlock" runat="server" CssClass="sb-btn sb-btn-danger sb-btn-xs"
                                    CommandName="BlockUser" CommandArgument='<%# Eval("userId") %>'
                                    Visible='<%# Convert.ToBoolean(Eval("canBlock")) %>'
                                    OnClientClick="return swalBlock(this);">
                                    <i class="bi bi-lock"></i> <%= T("Block", "Sekat") %>
                                </asp:LinkButton>
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody></table>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlEmpty" runat="server">
        <div class="ad-suspicious-logins-empty"><div class="ad-suspicious-logins-empty-ico"><i class="bi bi-shield-check"></i></div><div class="ad-suspicious-logins-empty-msg"><%= T("No suspicious activity detected.", "Tiada aktiviti mencurigakan dikesan.") %></div></div>
    </asp:Panel>
</div>

<%-- ══ ADMINISTRATOR SECURITY ACTIONS ══ --%>
<div class="ad-suspicious-logins-card" style="margin-top:var(--space-xl);">
    <div class="ad-suspicious-logins-card-hdr"><i class="bi bi-shield-fill-check" style="color:var(--ad-suspicious-logins-purple);"></i> <%= T("Administrator Security Actions", "Tindakan Keselamatan Pentadbir") %></div>
    <asp:Panel ID="pnlActions" runat="server" Visible="false">
        <div class="sb-table-wrapper" style="border:none;border-radius:0;box-shadow:none;overflow-x:auto;">
            <table class="sb-table" style="width:100%;"><thead><tr>
                <th><%= T("User", "Pengguna") %></th><th><%= T("Action", "Tindakan") %></th><th><%= T("Reason", "Sebab") %></th><th><%= T("Admin", "Pentadbir") %></th><th><%= T("Date", "Tarikh") %></th><th style="text-align:center;"><%= T("Actions", "Tindakan") %></th>
            </tr></thead><tbody>
                <asp:Repeater ID="rptActions" runat="server" OnItemCommand="rptActions_ItemCommand">
                    <ItemTemplate>
                        <tr>
                            <td data-label="User"><strong><%# HttpUtility.HtmlEncode(Eval("targetUser")) %></strong></td>
                            <td data-label="Action"><span class='sb-badge <%# Eval("typeCls") %>'><%# HttpUtility.HtmlEncode(Eval("typeLabel")) %></span></td>
                            <td data-label="Reason"><span style="font-size:.8125rem;color:var(--color-text-secondary);"><%# HttpUtility.HtmlEncode(Eval("reason")) %></span></td>
                            <td data-label="Admin"><%# HttpUtility.HtmlEncode(Eval("adminUser")) %></td>
                            <td data-label="Date"><span style="font-size:.8125rem;color:var(--color-text-muted);"><%# Eval("dateStr") %></span></td>
                            <td class="col-actions">
                                <asp:LinkButton ID="lnkUnblock" runat="server" CssClass="sb-btn sb-btn-success sb-btn-xs"
                                    CommandName="UnblockUser" CommandArgument='<%# Eval("userId") %>'
                                    Visible='<%# (bool)Eval("canUnblock") %>'
                                    OnClientClick="return swalUnlock(this);">
                                    <i class="bi bi-unlock"></i> <%= T("Unlock", "Buka Kunci") %>
                                </asp:LinkButton>
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody></table>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlNoActions" runat="server">
        <div class="ad-suspicious-logins-empty"><div class="ad-suspicious-logins-empty-ico"><i class="bi bi-shield-fill-check"></i></div><div class="ad-suspicious-logins-empty-msg"><%= T("No security actions recorded.", "Tiada tindakan keselamatan direkodkan.") %></div></div>
    </asp:Panel>
</div>

<script>
function swalUnlock(btn) {
    Swal.fire({
        title: '<%= T("Unlock this account?","Buka kunci akaun ini?") %>',
        text: '<%= T("The user will be able to log in again.","Pengguna akan dapat log masuk semula.") %>',
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#059669',
        confirmButtonText: '<i class="bi bi-unlock"></i> <%= T("Unlock","Buka Kunci") %>',
        cancelButtonText: '<%= T("Cancel","Batal") %>',
        reverseButtons: true
    }).then(function(r) {
        if (r.isConfirmed) {
            var prev = btn.onclick;
            btn.onclick = null;
            btn.click();
            btn.onclick = prev;
        }
    });
    return false;
}
function swalBlock(btn) {
    Swal.fire({
        title: '<%= T("Block this account?","Sekat akaun ini?") %>',
        text: '<%= T("The user will not be able to log in.","Pengguna tidak akan dapat log masuk.") %>',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#DC2626',
        confirmButtonText: '<i class="bi bi-lock"></i> <%= T("Block","Sekat") %>',
        cancelButtonText: '<%= T("Cancel","Batal") %>',
        reverseButtons: true
    }).then(function(r) {
        if (r.isConfirmed) {
            var prev = btn.onclick;
            btn.onclick = null;
            btn.click();
            btn.onclick = prev;
        }
    });
    return false;
}
</script>
</asp:Content>
