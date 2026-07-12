<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TeacherCertificateApproval.aspx.cs"
    Inherits="ScienceBuddy.Admin.TeacherCertificateApproval" MasterPageFile="~/Site.Master"
    Title="Teacher Certificate Approval" ValidateRequest="false" EnableEventValidation="false" %>

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
        <a href="<%: ResolveUrl("~/Admin/TeacherCertificateApproval.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-patch-check item-icon"></i><span class="item-label">Teacher Certificate Approval</span></a>
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
        <a href="<%: ResolveUrl("~/Admin/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span></a>
        <a href="<%: ResolveUrl("~/Admin/Profile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a>
        <a href="javascript:;" class="sb-sidebar-item" onclick="showSignOutModal()"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%= T("Teacher Certificate Approval", "Kelulusan Sijil Guru") %></asp:Content>

<%-- ════ MAIN CONTENT ════ --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- PAGE HEADER --%>
<div class="ad-teacher-cert-header">
    <div class="ad-teacher-cert-header-left">
        <h1 class="ad-teacher-cert-header-title"><i class="bi bi-patch-check-fill" style="color:var(--ad-teacher-cert-accent);"></i> <%= T("Teacher Certificate Approval", "Kelulusan Sijil Guru") %></h1>
        <p class="ad-teacher-cert-header-sub"><%= T("Review and manage teacher qualification certificate submissions.", "Semak dan urus penghantaran sijil kelayakan guru.") %></p>
    </div>
    <div class="ad-teacher-cert-header-icon"><i class="bi bi-patch-check-fill"></i></div>
</div>

<%-- SUMMARY CARDS --%>
<div class="ad-teacher-cert-summary">
    <div class="ad-teacher-cert-summary-card s1">
        <div class="ad-teacher-cert-summary-ico"><i class="bi bi-hourglass-split"></i></div>
        <div class="ad-teacher-cert-summary-val"><asp:Literal ID="litPending" runat="server" Text="0" /></div>
        <div class="ad-teacher-cert-summary-lbl"><%= T("Pending Reviews", "Semakan Tertunggak") %></div>
    </div>
    <div class="ad-teacher-cert-summary-card s2">
        <div class="ad-teacher-cert-summary-ico"><i class="bi bi-check-circle-fill"></i></div>
        <div class="ad-teacher-cert-summary-val"><asp:Literal ID="litCertified" runat="server" Text="0" /></div>
        <div class="ad-teacher-cert-summary-lbl"><%= T("Certified Teachers", "Guru Bertauliah") %></div>
    </div>
    <div class="ad-teacher-cert-summary-card s3">
        <div class="ad-teacher-cert-summary-ico"><i class="bi bi-x-circle-fill"></i></div>
        <div class="ad-teacher-cert-summary-val"><asp:Literal ID="litNotCertified" runat="server" Text="0" /></div>
        <div class="ad-teacher-cert-summary-lbl"><%= T("Not Certified", "Tidak Bertauliah") %></div>
    </div>
    <div class="ad-teacher-cert-summary-card s4">
        <div class="ad-teacher-cert-summary-ico"><i class="bi bi-file-earmark-check-fill"></i></div>
        <div class="ad-teacher-cert-summary-val"><asp:Literal ID="litTotal" runat="server" Text="0" /></div>
        <div class="ad-teacher-cert-summary-lbl"><%= T("Total Certificates", "Jumlah Sijil") %></div>
    </div>
</div>

<%-- SEARCH PANEL --%>
<div class="ad-teacher-cert-search">
    <i class="bi bi-search text-muted"></i>
    <asp:TextBox ID="txtSearch" runat="server" CssClass="sb-input sb-input-sm" AutoPostBack="false" />
    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="sb-select sb-input-sm" AutoPostBack="false">
        <asp:ListItem Value="">All Status</asp:ListItem>
        <asp:ListItem Value="Pending">Pending</asp:ListItem>
        <asp:ListItem Value="Certified">Certified</asp:ListItem>
        <asp:ListItem Value="Not Certified">Not Certified</asp:ListItem>
    </asp:DropDownList>
    <asp:DropDownList ID="ddlSort" runat="server" CssClass="sb-select sb-input-sm" AutoPostBack="false">
        <asp:ListItem Value="newest">Newest</asp:ListItem>
        <asp:ListItem Value="oldest">Oldest</asp:ListItem>
    </asp:DropDownList>
    <asp:Button ID="btnSearch" runat="server" CssClass="sb-btn sb-btn-primary sb-btn-sm" OnClick="btnSearch_Click" />
    <asp:Button ID="btnReset" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnReset_Click" />
</div>

<%-- TEACHER CARDS --%>
<asp:Panel ID="pnlCards" runat="server" Visible="false">
    <div class="ad-teacher-cert-grid">
        <asp:Repeater ID="rptTeachers" runat="server">
            <ItemTemplate>
                <div class="ad-teacher-cert-card">
                    <div class="ad-teacher-cert-card-top">
                        <div class="ad-teacher-cert-avatar" style='<%# Eval("avatarGradient") %>'>
                            <%# HttpUtility.HtmlEncode(Eval("initials")) %>
                        </div>
                        <div class="ad-teacher-cert-card-info">
                            <div class="ad-teacher-cert-card-name"><%# HttpUtility.HtmlEncode(Eval("name")) %></div>
                            <div class="ad-teacher-cert-card-id"><i class="bi bi-person-badge"></i> <%# HttpUtility.HtmlEncode(Eval("teacherId")) %></div>
                        </div>
                        <span class='ad-teacher-cert-badge <%# Eval("badgeClass") %>'><%# HttpUtility.HtmlEncode(Eval("statusLabel")) %></span>
                    </div>
                    <div class="ad-teacher-cert-card-body">
                        <div class="ad-teacher-cert-card-field">
                            <span class="ad-teacher-cert-card-field-lbl"><%= T("Qualification", "Kelayakan") %></span>
                            <span class="ad-teacher-cert-card-field-val"><%# HttpUtility.HtmlEncode(Eval("qualification")) %></span>
                        </div>
                        <div class="ad-teacher-cert-card-field">
                            <span class="ad-teacher-cert-card-field-lbl"><%= T("Certificate File", "Fail Sijil") %></span>
                            <span class="ad-teacher-cert-card-field-val"><%# HttpUtility.HtmlEncode(Eval("certFile")) %></span>
                        </div>
                        <div class="ad-teacher-cert-card-field">
                            <span class="ad-teacher-cert-card-field-lbl"><%= T("Submitted", "Dihantar") %></span>
                            <span class="ad-teacher-cert-card-field-val"><%# HttpUtility.HtmlEncode(Eval("submittedDate")) %></span>
                        </div>
                    </div>
                    <div class="ad-teacher-cert-actions">
                        <button type="button" class="sb-btn sb-btn-light sb-btn-xs ad-teacher-cert-btn-view"
                            onclick='openTCModal("<%# HttpUtility.HtmlAttributeEncode(Eval("teacherId").ToString()) %>","<%# HttpUtility.HtmlAttributeEncode(Eval("name").ToString()) %>","<%# HttpUtility.HtmlAttributeEncode(Eval("qualification").ToString()) %>","<%# HttpUtility.HtmlAttributeEncode(Eval("certFile").ToString()) %>","<%# HttpUtility.HtmlAttributeEncode(Eval("certUrl").ToString()) %>")'>
                            <i class="bi bi-eye"></i> <%= T("View Certificate", "Lihat Sijil") %>
                        </button>
                        <button type="button" class="sb-btn sb-btn-xs ad-teacher-cert-btn-approve"
                            onclick='tcApprove("<%# HttpUtility.HtmlAttributeEncode(Eval("teacherId").ToString()) %>")'
                            <%# Eval("status").ToString() == "Pending" ? "" : "disabled" %>>
                            <i class="bi bi-check-lg"></i> <%= T("Approve", "Luluskan") %>
                        </button>
                        <button type="button" class="sb-btn sb-btn-xs ad-teacher-cert-btn-reject"
                            onclick='tcReject("<%# HttpUtility.HtmlAttributeEncode(Eval("teacherId").ToString()) %>")'
                            <%# Eval("status").ToString() == "Pending" ? "" : "disabled" %>>
                            <i class="bi bi-x-lg"></i> <%= T("Reject", "Tolak") %>
                        </button>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>

<%-- EMPTY STATE --%>
<asp:Panel ID="pnlEmpty" runat="server">
    <div class="ad-teacher-cert-empty">
        <div class="ad-teacher-cert-empty-ico"><i class="bi bi-patch-check"></i></div>
        <div class="ad-teacher-cert-empty-msg"><%= T("No teacher certificates found.", "Tiada sijil guru ditemui.") %></div>
        <div class="ad-teacher-cert-empty-sub"><%= T("Try adjusting your search or filters.", "Cuba laraskan carian atau penapis anda.") %></div>
    </div>
</asp:Panel>

<%-- VIEW CERTIFICATE MODAL --%>
<div id="tcModalOverlay" class="ad-teacher-cert-modal-overlay" style="display:none;">
    <div class="ad-teacher-cert-modal">
        <div class="ad-teacher-cert-modal-hdr">
            <div class="ad-teacher-cert-modal-hdr-title"><i class="bi bi-file-earmark-check"></i> <%= T("Certificate Preview", "Pratonton Sijil") %></div>
            <button type="button" class="ad-teacher-cert-modal-close" onclick="closeTCModal()"><i class="bi bi-x-lg"></i></button>
        </div>
        <div class="ad-teacher-cert-modal-body">
            <div class="ad-teacher-cert-modal-field">
                <span class="ad-teacher-cert-modal-lbl"><%= T("Teacher Name", "Nama Guru") %></span>
                <span class="ad-teacher-cert-modal-val" id="tcModalName">-</span>
            </div>
            <div class="ad-teacher-cert-modal-field">
                <span class="ad-teacher-cert-modal-lbl"><%= T("Qualification", "Kelayakan") %></span>
                <span class="ad-teacher-cert-modal-val" id="tcModalQual">-</span>
            </div>
            <div class="ad-teacher-cert-modal-field">
                <span class="ad-teacher-cert-modal-lbl"><%= T("Certificate File", "Fail Sijil") %></span>
                <span class="ad-teacher-cert-modal-val" id="tcModalFile">-</span>
            </div>
            <div class="ad-teacher-cert-preview" id="tcPreviewArea">
                <div class="ad-teacher-cert-preview-ph">
                    <i class="bi bi-file-earmark-pdf"></i>
                    <span><%= T("Certificate Preview", "Pratonton Sijil") %></span>
                </div>
            </div>
            <div class="ad-teacher-cert-modal-footer">
                <a id="tcDownloadBtn" href="#" target="_blank" class="sb-btn sb-btn-primary sb-btn-sm"><i class="bi bi-download"></i> <%= T("Download", "Muat Turun") %></a>
                <button type="button" class="sb-btn sb-btn-ghost sb-btn-sm" onclick="closeTCModal()"><%= T("Close", "Tutup") %></button>
            </div>
        </div>
    </div>
</div>

<%-- HIDDEN POSTBACK --%>
<asp:HiddenField ID="hfAction" runat="server" />
<asp:HiddenField ID="hfTeacherId" runat="server" />
<asp:Button ID="btnDoAction" runat="server" Style="display:none;" OnClick="btnDoAction_Click" />

<%-- TOAST --%>
<asp:Panel ID="pnlToast" runat="server" Visible="false"><asp:Literal ID="litToast" runat="server" /></asp:Panel>

<script>
function openTCModal(tid, name, qual, certFile, certUrl) {
    document.getElementById('tcModalName').textContent = name;
    document.getElementById('tcModalQual').textContent = qual;
    document.getElementById('tcModalFile').textContent = certFile || '<%= T("No file uploaded","Tiada fail dimuat naik") %>';
    var area = document.getElementById('tcPreviewArea');
    var dlBtn = document.getElementById('tcDownloadBtn');
    if (certUrl && certUrl.trim() !== '') {
        var fullUrl = '<%: ResolveUrl("~/") %>' + certUrl;
        var ext = certUrl.split('.').pop().toLowerCase();
        if (ext === 'pdf') {
            area.innerHTML = '<iframe src="' + fullUrl + '" style="width:100%;height:400px;border:none;border-radius:12px;"></iframe>';
        } else if (['jpg','jpeg','png','gif','webp'].indexOf(ext) >= 0) {
            area.innerHTML = '<img src="' + fullUrl + '" alt="Certificate" style="max-width:100%;max-height:400px;border-radius:12px;object-fit:contain;" />';
        } else {
            area.innerHTML = '<div class="ad-teacher-cert-preview-ph"><i class="bi bi-file-earmark"></i><span>' + certFile + '</span></div>';
        }
        dlBtn.href = fullUrl;
        dlBtn.style.display = 'inline-flex';
    } else {
        area.innerHTML = '<div class="ad-teacher-cert-preview-ph"><i class="bi bi-file-earmark-x"></i><span><%= T("No certificate file available","Tiada fail sijil tersedia") %></span></div>';
        dlBtn.style.display = 'none';
    }
    document.getElementById('tcModalOverlay').style.display = 'flex';
}
function closeTCModal() { document.getElementById('tcModalOverlay').style.display = 'none'; }

function tcApprove(tid) {
    Swal.fire({
        title: '<%= T("Approve Teacher Certificate?","Luluskan Sijil Guru?") %>',
        text: '<%= T("This teacher will become a Certified Teacher.","Guru ini akan menjadi Guru Bertauliah.") %>',
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#059669',
        cancelButtonColor: '#64748B',
        confirmButtonText: '<i class="bi bi-check-lg"></i> <%= T("Approve","Luluskan") %>',
        cancelButtonText: '<%= T("Cancel","Batal") %>',
        reverseButtons: true
    }).then(function(r) {
        if (r.isConfirmed) {
            document.getElementById('<%= hfAction.ClientID %>').value = 'approve';
            document.getElementById('<%= hfTeacherId.ClientID %>').value = tid;
            document.getElementById('<%= btnDoAction.ClientID %>').click();
        }
    });
}
function tcReject(tid) {
    Swal.fire({
        title: '<%= T("Reject Teacher Certificate?","Tolak Sijil Guru?") %>',
        text: '<%= T("This certificate submission will be rejected.","Penghantaran sijil ini akan ditolak.") %>',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#DC2626',
        cancelButtonColor: '#64748B',
        confirmButtonText: '<i class="bi bi-x-lg"></i> <%= T("Reject","Tolak") %>',
        cancelButtonText: '<%= T("Cancel","Batal") %>',
        reverseButtons: true
    }).then(function(r) {
        if (r.isConfirmed) {
            document.getElementById('<%= hfAction.ClientID %>').value = 'reject';
            document.getElementById('<%= hfTeacherId.ClientID %>').value = tid;
            document.getElementById('<%= btnDoAction.ClientID %>').click();
        }
    });
}
document.getElementById('tcModalOverlay').addEventListener('click', function(e) { if (e.target === this) closeTCModal(); });
</script>

</asp:Content>
