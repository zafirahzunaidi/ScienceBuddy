<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="QuestionRequests.aspx.cs"
    Inherits="ScienceBuddy.Admin.QuestionRequests" MasterPageFile="~/Site.Master"
    Title="Quiz Requests" ValidateRequest="false" EnableEventValidation="false" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Admin.css") %>" rel="stylesheet" />
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" />
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
        <a href="<%: ResolveUrl("~/Admin/QuestionRequests.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-clipboard-check item-icon"></i><span class="item-label">Quiz Requests</span></a>
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

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">Quiz Requests</asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<!-- HEADER -->
<div class="ad-question-request-hdr">
    <div>
        <div class="ad-question-request-hdr-title"><i class="bi bi-clipboard-check" style="color:var(--ad-question-request);"></i> <%= T("Quiz Requests", "Permintaan Kuiz") %></div>
        <div class="ad-question-request-hdr-sub"><%= T("Review, approve or reject teacher-submitted quizzes. Approving a quiz also approves all its questions and notifies eligible students.", "Semak, luluskan atau tolak kuiz yang dihantar guru. Meluluskan kuiz turut meluluskan semua soalannya dan memberitahu pelajar yang layak.") %></div>
    </div>
    <div class="ad-question-request-hdr-right">
        <a href="javascript:;" class="ad-question-request-btn-refresh" onclick="location.reload();"><i class="bi bi-arrow-clockwise"></i> <%= T("Refresh", "Muat Semula") %></a>
    </div>
</div>

<!-- STATS -->
<div class="ad-question-request-stats">
    <div class="ad-question-request-stat s-pending"><div class="ad-question-request-stat-ico" style="background:#FEF3C7;color:#D97706;"><i class="bi bi-hourglass-split"></i></div><div><div class="ad-question-request-stat-val" id="statPending"><asp:Literal ID="litPending" runat="server" Text="0" /></div><div class="ad-question-request-stat-lbl"><%= T("Pending Quiz Requests", "Kuiz Tertunggak") %></div></div></div>
    <div class="ad-question-request-stat s-approved"><div class="ad-question-request-stat-ico" style="background:#D1FAE5;color:#059669;"><i class="bi bi-check-circle-fill"></i></div><div><div class="ad-question-request-stat-val" id="statApproved"><asp:Literal ID="litApproved" runat="server" Text="0" /></div><div class="ad-question-request-stat-lbl"><%= T("Approved Quizzes", "Kuiz Diluluskan") %></div></div></div>
    <div class="ad-question-request-stat s-rejected"><div class="ad-question-request-stat-ico" style="background:#FEE2E2;color:#DC2626;"><i class="bi bi-x-circle-fill"></i></div><div><div class="ad-question-request-stat-val" id="statRejected"><asp:Literal ID="litRejected" runat="server" Text="0" /></div><div class="ad-question-request-stat-lbl"><%= T("Rejected Quizzes", "Kuiz Ditolak") %></div></div></div>
    <div class="ad-question-request-stat s-today"><div class="ad-question-request-stat-ico" style="background:var(--ad-question-request-light);color:var(--ad-question-request);"><i class="bi bi-calendar-check"></i></div><div><div class="ad-question-request-stat-val" id="statToday"><asp:Literal ID="litToday" runat="server" Text="0" /></div><div class="ad-question-request-stat-lbl"><%= T("Reviewed Today", "Disemak Hari Ini") %></div></div></div>
</div>

<!-- SEARCH/FILTER -->
<div class="ad-question-request-toolbar">
    <div class="ad-question-request-search"><i class="bi bi-search"></i><asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" /></div>
    <asp:DropDownList ID="fStatus" runat="server" CssClass="ad-question-request-filter">
        <asp:ListItem Value="" Text="All Status" />
        <asp:ListItem Value="Pending" Text="Pending" />
        <asp:ListItem Value="Approved" Text="Approved" />
        <asp:ListItem Value="Rejected" Text="Rejected" />
    </asp:DropDownList>
    <asp:DropDownList ID="fType" runat="server" CssClass="ad-question-request-filter">
        <asp:ListItem Value="" Text="All Quiz Types" />
        <asp:ListItem Value="Unit" Text="Unit" />
        <asp:ListItem Value="Practice" Text="Practice" />
        <asp:ListItem Value="Level" Text="Level" />
    </asp:DropDownList>
    <asp:DropDownList ID="fLang" runat="server" CssClass="ad-question-request-filter">
        <asp:ListItem Value="" Text="All Languages" />
        <asp:ListItem Value="EN" Text="English" />
        <asp:ListItem Value="BM" Text="Bahasa Melayu" />
        <asp:ListItem Value="BOTH" Text="Both" />
    </asp:DropDownList>
    <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="sb-btn sb-btn-primary sb-btn-sm" OnClick="btnSearch_Click" />
    <asp:Button ID="btnReset" runat="server" Text="Reset" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnReset_Click" />
</div>

<!-- PENDING SECTION -->
<div class="ad-question-request-sec-hd"><div class="ad-question-request-sec-title"><i class="bi bi-hourglass-split" style="color:#D97706;"></i> <%= T("Pending Quiz Requests", "Permintaan Kuiz Tertunggak") %> <span id="pendingBadge"><asp:Literal ID="litBadge" runat="server" /></span></div></div>
<div class="ad-question-request-card">
    <asp:Panel ID="pnlPending" runat="server" Visible="false">
        <div id="pnlPendingWrap" class="sb-table-wrapper" style="border:none;border-radius:0;box-shadow:none;"><table id="pendingTable" class="sb-table"><thead><tr>
            <th>ID</th><th><%= T("Quiz Title","Tajuk Kuiz") %></th><th><%= T("Type","Jenis") %></th><th><%= T("Language","Bahasa") %></th><th><%= T("Teacher","Guru") %></th><th><%= T("Questions","Soalan") %></th><th><%= T("Created","Dicipta") %></th><th class="col-actions"><%= T("Actions","Tindakan") %></th>
        </tr></thead><tbody>
        <asp:Repeater ID="rptPending" runat="server"><ItemTemplate><tr>
            <td><span style="font-size:.75rem;font-family:monospace;color:var(--color-text-muted);"><%# Eval("quizId") %></span></td>
            <td><div class="ad-question-request-qtext"><%# HttpUtility.HtmlEncode(Eval("quizTitle")) %></div></td>
            <td><span class='<%# GetTypeClass(Eval("quizType")) %>'><%# Eval("quizType") %></span></td>
            <td><span class="sb-badge sb-badge-gray"><%# Eval("language") %></span></td>
            <td><%# HttpUtility.HtmlEncode(Eval("teacherName")) %></td>
            <td><span class="sb-badge sb-badge-gray"><%# Eval("questionCount") %></span></td>
            <td><span style="font-size:.8rem;color:var(--color-text-muted);"><%# Eval("createdAt") %></span></td>
            <td class="col-actions"><div class="ad-question-request-actions">
                <a href="javascript:;" class="sb-btn sb-btn-primary sb-btn-xs" onclick='viewQuiz("<%# Eval("quizId") %>")'><i class="bi bi-eye"></i></a>
                <a href="javascript:;" class="sb-btn sb-btn-success sb-btn-xs" onclick='reviewQuiz("<%# Eval("quizId") %>","Approve",this)'><i class="bi bi-check-lg"></i></a>
                <a href="javascript:;" class="sb-btn sb-btn-danger sb-btn-xs" onclick='reviewQuiz("<%# Eval("quizId") %>","Reject",this)'><i class="bi bi-x-lg"></i></a>
            </div></td>
        </tr></ItemTemplate></asp:Repeater>
        </tbody></table></div>
    </asp:Panel>
    <asp:Panel ID="pnlPendingEmpty" runat="server"><div id="pnlPendingEmptyWrap" class="ad-question-request-empty"><i class="bi bi-check-circle" style="color:#059669;"></i><div class="ad-question-request-empty-msg"><%= T("No pending quiz requests.", "Tiada permintaan kuiz tertunggak.") %></div><div class="ad-question-request-empty-sub"><%= T("All submitted quizzes have been reviewed.", "Semua kuiz yang dihantar telah disemak.") %></div></div></asp:Panel>
</div>

<!-- HISTORY SECTION -->
<div class="ad-question-request-sec-hd"><div class="ad-question-request-sec-title"><i class="bi bi-clock-history" style="color:#7C3AED;"></i> <%= T("Review History", "Sejarah Semakan") %></div></div>
<div class="ad-question-request-card">
    <asp:Panel ID="pnlHistory" runat="server" Visible="false">
        <div id="pnlHistoryWrap" class="sb-table-wrapper" style="border:none;border-radius:0;box-shadow:none;"><table id="historyTable" class="sb-table"><thead><tr>
            <th>ID</th><th><%= T("Quiz Title","Tajuk Kuiz") %></th><th><%= T("Type","Jenis") %></th><th><%= T("Teacher","Guru") %></th><th><%= T("Questions","Soalan") %></th><th><%= T("Reviewed","Disemak") %></th><th><%= T("Status","Status") %></th>
        </tr></thead><tbody>
        <asp:Repeater ID="rptHistory" runat="server"><ItemTemplate><tr>
            <td><span style="font-size:.75rem;font-family:monospace;color:var(--color-text-muted);"><%# Eval("quizId") %></span></td>
            <td><div class="ad-question-request-qtext"><%# HttpUtility.HtmlEncode(Eval("quizTitle")) %></div></td>
            <td><span class='<%# GetTypeClass(Eval("quizType")) %>'><%# Eval("quizType") %></span></td>
            <td><%# HttpUtility.HtmlEncode(Eval("teacherName")) %></td>
            <td><span class="sb-badge sb-badge-gray"><%# Eval("questionCount") %></span></td>
            <td><span style="font-size:.8rem;color:var(--color-text-muted);"><%# Eval("reviewedDate") %></span></td>
            <td><%# BuildBadge(Eval("status").ToString()) %></td>
        </tr></ItemTemplate></asp:Repeater>
        </tbody></table></div>
    </asp:Panel>
    <asp:Panel ID="pnlHistoryEmpty" runat="server"><div id="pnlHistoryEmptyWrap" class="ad-question-request-empty"><i class="bi bi-clipboard-data" style="color:var(--ad-question-request);"></i><div class="ad-question-request-empty-msg"><%= T("No reviewed quizzes yet.", "Belum ada kuiz yang disemak.") %></div><div class="ad-question-request-empty-sub"><%= T("Approved and rejected quizzes will appear here.", "Kuiz yang diluluskan dan ditolak akan dipaparkan di sini.") %></div></div></asp:Panel>
</div>

<!-- VIEW MODAL -->
<div class="ad-question-request-modal-overlay" id="qrModal">
    <div class="ad-question-request-modal">
        <div class="ad-question-request-modal-hdr"><span class="ad-question-request-modal-title"><i class="bi bi-eye" style="color:var(--ad-question-request);margin-right:8px;"></i><%= T("Quiz Details", "Butiran Kuiz") %></span><button class="ad-question-request-modal-close" onclick="document.getElementById('qrModal').classList.remove('active')"><i class="bi bi-x-lg"></i></button></div>
        <div class="ad-question-request-modal-body" id="qrDetails"></div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>
function reviewQuiz(quizId, action, btn) {
    var row = btn ? btn.closest('tr') : null;
    var msg = action === 'Approve'
        ? '<%= T("Approve this quiz and all its questions?","Luluskan kuiz ini dan semua soalannya?") %>'
        : '<%= T("Reject this quiz and all its questions?","Tolak kuiz ini dan semua soalannya?") %>';
    Swal.fire({
        title: msg, icon: 'question', showCancelButton: true,
        confirmButtonColor: action === 'Approve' ? '#059669' : '#DC2626',
        confirmButtonText: action === 'Approve' ? '<%= T("Approve","Luluskan") %>' : '<%= T("Reject","Tolak") %>',
        cancelButtonText: '<%= T("Cancel","Batal") %>'
    }).then(function(r) {
        if (!r.isConfirmed) return;
        var basePath = window.location.pathname;
        if (basePath.indexOf('.aspx') === -1) basePath += '.aspx';
        var url = basePath + '?handler=ReviewQuiz&quizId=' + encodeURIComponent(quizId) + '&action=' + action;

        var cells = row ? row.querySelectorAll('td') : [];
        var qIdText = cells[0] ? cells[0].innerHTML : '';
        var qTitle = cells[1] ? cells[1].innerHTML : '';
        var qType = cells[2] ? cells[2].innerHTML : '';
        var teacher = cells[3] ? cells[3].innerHTML : '';
        var qCount = cells[4] ? cells[4].innerHTML : '';

        fetch(url, { method: 'POST', headers: { 'X-Requested-With': 'XMLHttpRequest' } })
        .then(function(resp) {
            if (!resp.ok) throw new Error('Server returned ' + resp.status);
            return resp.text().then(function(t) {
                try { return JSON.parse(t); }
                catch(e) { throw new Error('Invalid response: ' + t.substring(0, 200)); }
            });
        })
        .then(function(data) {
            if (!data.success) { Swal.fire({ icon: 'error', title: 'Error', text: data.msg }); return; }

            if (row) {
                row.style.transition = 'opacity .4s, transform .4s';
                row.style.opacity = '0';
                row.style.transform = 'translateX(30px)';
            }
            setTimeout(function() {
                if (row) row.remove();
                var pendingBody = document.querySelector('#pendingTable tbody');
                if (pendingBody && pendingBody.children.length === 0) {
                    var pendingWrap = document.getElementById('pnlPendingWrap');
                    var pendingEmptyWrap = document.getElementById('pnlPendingEmptyWrap');
                    if (pendingWrap) pendingWrap.style.display = 'none';
                    if (pendingEmptyWrap) pendingEmptyWrap.style.display = '';
                }
            }, 400);

            var elPending = document.getElementById('statPending');
            var elApproved = document.getElementById('statApproved');
            var elRejected = document.getElementById('statRejected');
            var elToday = document.getElementById('statToday');
            if (elPending) elPending.textContent = data.pending;
            if (elApproved) elApproved.textContent = data.approved;
            if (elRejected) elRejected.textContent = data.rejected;
            if (elToday) elToday.textContent = data.today;
            var badge = document.getElementById('pendingBadge');
            if (badge) badge.innerHTML = data.pending > 0 ? '<span class="sb-badge sb-badge-warning" style="margin-left:6px;">' + data.pending + '</span>' : '';

            var histTable = document.getElementById('historyTable');
            var histBody = histTable ? histTable.querySelector('tbody') : null;
            if (histBody) {
                var histWrap = document.getElementById('pnlHistoryWrap');
                var histEmptyWrap = document.getElementById('pnlHistoryEmptyWrap');
                if (histWrap) histWrap.style.display = '';
                if (histEmptyWrap) histEmptyWrap.style.display = 'none';

                var statusBadge = action === 'Approve'
                    ? '<span class="sb-badge sb-badge-success"><i class="bi bi-check-circle-fill"></i> Approved</span>'
                    : '<span class="sb-badge sb-badge-error"><i class="bi bi-x-circle-fill"></i> Rejected</span>';

                var newRow = document.createElement('tr');
                newRow.className = action === 'Approve' ? 'ad-question-request-highlight-approved' : 'ad-question-request-highlight-rejected';
                newRow.innerHTML = '<td>' + qIdText + '</td><td>' + qTitle + '</td><td>' + qType + '</td><td>' + teacher + '</td><td>' + qCount + '</td><td><span style="font-size:.8rem;color:var(--color-text-muted);">' + data.reviewedAt + '</span></td><td>' + statusBadge + '</td>';
                histBody.insertBefore(newRow, histBody.firstChild);
                setTimeout(function() { newRow.scrollIntoView({ behavior: 'smooth', block: 'center' }); }, 100);
                setTimeout(function() { newRow.classList.remove('ad-question-request-highlight-approved', 'ad-question-request-highlight-rejected'); }, 5000);
            }

            var toastMsg = action === 'Approve'
                ? '<%= T("Quiz approved successfully.","Kuiz berjaya diluluskan.") %>'
                : '<%= T("Quiz rejected successfully.","Kuiz berjaya ditolak.") %>';
            Swal.fire({ icon: 'success', title: toastMsg, confirmButtonColor: '#6366F1', timer: 2500, timerProgressBar: true, showConfirmButton: false, position: 'top-end', toast: true });
        }).catch(function(err) {
            Swal.fire({ icon: 'error', title: 'Error', text: err.message || 'Network error. Please try again.' });
        });
    });
}

function viewQuiz(quizId) {
    document.getElementById('qrDetails').innerHTML = '<div style="text-align:center;padding:40px;"><i class="bi bi-arrow-repeat" style="font-size:2rem;color:var(--ad-question-request);animation:spin 1s linear infinite;"></i><div style="margin-top:12px;color:var(--color-text-muted);">Loading...</div></div>';
    document.getElementById('qrModal').classList.add('active');

    var basePath = window.location.pathname;
    if (basePath.indexOf('.aspx') === -1) basePath += '.aspx';
    var url = basePath + '?handler=ViewQuiz&quizId=' + encodeURIComponent(quizId);

    fetch(url, { method: 'POST', headers: { 'X-Requested-With': 'XMLHttpRequest' } })
    .then(function(resp) { return resp.json(); })
    .then(function(data) {
        if (!data.success) { document.getElementById('qrDetails').innerHTML = '<div style="color:red;">Error: ' + (data.msg || 'Unknown') + '</div>'; return; }
        var q = data.quiz;
        var h = '<div class="ad-question-request-detail-grid">';
        h += '<div style="grid-column:1/-1;background:var(--ad-question-request-light);border-radius:12px;padding:16px 20px;margin-bottom:12px;border:1px solid var(--ad-question-request-border);">';
        h += '<div style="font-size:.7rem;font-weight:700;color:var(--ad-question-request);text-transform:uppercase;letter-spacing:.5px;margin-bottom:6px;"><i class="bi bi-patch-question"></i> Quiz Information</div>';
        h += '<div style="font-size:.95rem;font-weight:600;color:var(--color-text);line-height:1.5;">' + q.title + '</div></div>';
        h += '<div class="ad-question-request-detail-item"><div class="ad-question-request-detail-label"><i class="bi bi-hash"></i> Quiz ID</div><div class="ad-question-request-detail-value">' + q.quizId + '</div></div>';
        h += '<div class="ad-question-request-detail-item"><div class="ad-question-request-detail-label"><i class="bi bi-person"></i> Teacher</div><div class="ad-question-request-detail-value">' + q.teacher + '</div></div>';
        h += '<div class="ad-question-request-detail-item"><div class="ad-question-request-detail-label"><i class="bi bi-tag"></i> Type</div><div class="ad-question-request-detail-value">' + q.quizType + '</div></div>';
        h += '<div class="ad-question-request-detail-item"><div class="ad-question-request-detail-label"><i class="bi bi-translate"></i> Language</div><div class="ad-question-request-detail-value">' + q.language + '</div></div>';
        h += '<div class="ad-question-request-detail-item"><div class="ad-question-request-detail-label"><i class="bi bi-calendar3"></i> Created</div><div class="ad-question-request-detail-value">' + q.createdAt + '</div></div>';
        h += '<div class="ad-question-request-detail-item"><div class="ad-question-request-detail-label"><i class="bi bi-list-ol"></i> Questions</div><div class="ad-question-request-detail-value">' + q.questionCount + '</div></div>';
        h += '</div>';

        if (data.questions && data.questions.length > 0) {
            h += '<div style="margin-top:20px;"><div style="font-size:.8rem;font-weight:700;color:var(--color-text-secondary);text-transform:uppercase;letter-spacing:.5px;margin-bottom:12px;"><i class="bi bi-list-check"></i> Questions in this Quiz</div>';
            data.questions.forEach(function(qn, idx) {
                h += '<div style="background:#f8fafc;border:1px solid #e2e8f0;border-radius:10px;padding:14px 18px;margin-bottom:10px;">';
                h += '<div style="font-weight:700;color:var(--color-text);margin-bottom:6px;">Q' + (idx + 1) + '. ' + qn.text + '</div>';
                if (qn.difficulty) { h += '<span class="sb-badge sb-badge-gray" style="margin-bottom:8px;">' + qn.difficulty + '</span> '; }
                var opts = [{l:'A',v:qn.optA},{l:'B',v:qn.optB},{l:'C',v:qn.optC},{l:'D',v:qn.optD}];
                opts.forEach(function(o) {
                    if (!o.v) return;
                    var isC = (qn.correct === o.l);
                    h += '<div class="ad-question-request-opt' + (isC ? ' correct' : '') + '"><strong>' + o.l + ')</strong> ' + o.v + (isC ? ' <i class="bi bi-check-circle-fill" style="color:#059669;margin-left:6px;"></i>' : '') + '</div>';
                });
                if (qn.explanation) {
                    h += '<div style="margin-top:8px;background:#D1FAE5;border-radius:8px;padding:8px 12px;font-size:.8rem;color:#047857;"><strong>Explanation:</strong> ' + qn.explanation + '</div>';
                }
                h += '</div>';
            });
            h += '</div>';
        }
        document.getElementById('qrDetails').innerHTML = h;
        // Trigger AI analysis
        requestQuizAIReview(quizId, data);
    }).catch(function(err) {
        document.getElementById('qrDetails').innerHTML = '<div style="color:red;">Error loading quiz details.</div>';
    });
}

function requestQuizAIReview(quizId, data) {
    var section = document.getElementById('qrDetails');
    section.innerHTML += '<div id="quizAISection"><div style="background:#F0F9FF;border:1px solid #BAE6FD;border-radius:12px;padding:16px 20px;margin-top:20px;"><div style="display:flex;align-items:center;gap:8px;margin-bottom:8px;"><i class="bi bi-robot" style="font-size:1.2rem;color:#0284C7;"></i><strong style="color:#0369A1;">AI Quiz Review</strong></div><div style="display:flex;align-items:center;gap:8px;color:#64748B;font-size:.85rem;"><i class="bi bi-arrow-repeat" style="animation:spin 1s linear infinite;"></i> AI is analysing this quiz... Please wait...</div></div></div>';

    var fd = new FormData();
    fd.append('quizId', quizId);
    var basePath = window.location.pathname;
    if (basePath.indexOf('.aspx') === -1) basePath += '.aspx';

    fetch(basePath + '?handler=AIAnalyzeQuiz', { method: 'POST', body: fd })
    .then(function(r) { return r.json(); })
    .then(function(d) {
        var aiDiv = document.getElementById('quizAISection');
        if (!aiDiv) return;
        if (!d.success) {
            var errMsg = d.error || d.msg || 'Unknown error';
            aiDiv.innerHTML = '<div style="background:#FEF2F2;border:1px solid #FECACA;border-radius:12px;padding:16px 20px;margin-top:20px;"><div style="display:flex;align-items:center;gap:8px;"><i class="bi bi-robot" style="font-size:1.2rem;color:#DC2626;"></i><strong style="color:#991B1B;">AI Quiz Review</strong></div><p style="margin-top:8px;font-size:.85rem;color:#7F1D1D;"><strong>Error:</strong> ' + errMsg + '</p></div>';
            return;
        }
        var ai = d.data || {};
        var recColor = ai.recommendation === 'Approve' ? '#059669' : ai.recommendation === 'Reject' ? '#DC2626' : '#D97706';
        var h = '<div style="background:#F0F9FF;border:1px solid #BAE6FD;border-radius:12px;padding:16px 20px;margin-top:20px;">';
        h += '<div style="display:flex;align-items:center;gap:8px;margin-bottom:12px;"><i class="bi bi-robot" style="font-size:1.2rem;color:#0284C7;"></i><strong style="color:#0369A1;">AI Quiz Review</strong></div>';
        h += '<div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;font-size:.85rem;">';
        h += '<div><span style="color:#64748B;font-weight:600;">Recommendation</span><div style="font-weight:700;color:' + recColor + ';">' + (ai.recommendation || 'Not Available') + '</div></div>';
        h += '<div><span style="color:#64748B;font-weight:600;">Confidence</span><div style="font-weight:600;">' + (ai.confidence || 'Not Available') + '</div></div>';
        h += '<div><span style="color:#64748B;font-weight:600;">Scientific Accuracy</span><div>' + (ai.scientificAccuracy || 'Not Available') + '</div></div>';
        h += '<div><span style="color:#64748B;font-weight:600;">Correct Answers</span><div>' + (ai.correctAnswers || 'Not Available') + '</div></div>';
        h += '<div><span style="color:#64748B;font-weight:600;">Duplicate Questions</span><div>' + (ai.duplicateQuestions || 'Not Available') + '</div></div>';
        h += '<div><span style="color:#64748B;font-weight:600;">Question Clarity</span><div>' + (ai.questionClarity || 'Not Available') + '</div></div>';
        h += '</div>';
        if (ai.summary) { h += '<div style="margin-top:12px;padding-top:10px;border-top:1px solid #E0F2FE;"><span style="color:#64748B;font-weight:600;font-size:.8rem;">Summary</span><p style="margin-top:4px;font-size:.85rem;color:#334155;">' + ai.summary + '</p></div>'; }
        h += '<p style="margin-top:10px;font-size:.75rem;color:#94A3B8;font-style:italic;"><i class="bi bi-info-circle"></i> AI recommendations are advisory only. The administrator makes the final decision.</p>';
        h += '</div>';
        aiDiv.innerHTML = h;
    })
    .catch(function() {
        var aiDiv = document.getElementById('quizAISection');
        if (aiDiv) aiDiv.innerHTML = '<div style="background:#FEF2F2;border:1px solid #FECACA;border-radius:12px;padding:16px 20px;margin-top:20px;"><div style="display:flex;align-items:center;gap:8px;"><i class="bi bi-robot" style="font-size:1.2rem;color:#DC2626;"></i><strong style="color:#991B1B;">AI Quiz Review</strong></div><p style="margin-top:8px;font-size:.85rem;color:#7F1D1D;">AI review is currently unavailable.</p></div>';
    });
}
</script>
</asp:Content>
