<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="QuestionRequests.aspx.cs"
    Inherits="ScienceBuddy.Admin.QuestionRequests" MasterPageFile="~/Site.Master"
    Title="Question Requests" ValidateRequest="false" EnableEventValidation="false" %>

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
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Learning Content</div>
        <a href="<%: ResolveUrl("~/Admin/LessonManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label">Lessons</span></a>
        <a href="<%: ResolveUrl("~/Admin/QuizManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label">Quizzes</span></a>
        <a href="<%: ResolveUrl("~/Admin/QuestionBank.aspx") %>" class="sb-sidebar-item"><i class="bi bi-question-circle item-icon"></i><span class="item-label">Question Bank</span></a>
        <a href="<%: ResolveUrl("~/Admin/TeacherMaterials.aspx") %>" class="sb-sidebar-item"><i class="bi bi-file-earmark-text item-icon"></i><span class="item-label">Material Requests</span></a>
        <a href="<%: ResolveUrl("~/Admin/LiveSessions.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label">Live Sessions</span></a>
        <a href="<%: ResolveUrl("~/Admin/QuestionRequests.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-clipboard-check item-icon"></i><span class="item-label">Question Requests</span></a>
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

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">Question Requests</asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<!-- HEADER -->
<div class="ad-question-request-hdr">
    <div>
        <div class="ad-question-request-hdr-title"><i class="bi bi-clipboard-check" style="color:var(--ad-question-request);"></i> <%= T("Question Requests", "Permintaan Soalan") %></div>
        <div class="ad-question-request-hdr-sub"><%= T("Review, approve or reject teacher-submitted questions. Approved questions become available for Practice Quiz creation.", "Semak, luluskan atau tolak soalan yang dihantar guru. Soalan yang diluluskan boleh digunakan dalam Kuiz Latihan.") %></div>
    </div>
    <div class="ad-question-request-hdr-right">
        <a href="javascript:;" class="ad-question-request-btn-refresh" onclick="location.reload();"><i class="bi bi-arrow-clockwise"></i> <%= T("Refresh", "Muat Semula") %></a>
    </div>
</div>

<!-- STATS -->
<div class="ad-question-request-stats">
    <div class="ad-question-request-stat s-pending"><div class="ad-question-request-stat-ico" style="background:#FEF3C7;color:#D97706;"><i class="bi bi-hourglass-split"></i></div><div><div class="ad-question-request-stat-val" id="statPending"><asp:Literal ID="litPending" runat="server" Text="0" /></div><div class="ad-question-request-stat-lbl"><%= T("Pending Questions", "Soalan Tertunggak") %></div></div></div>
    <div class="ad-question-request-stat s-approved"><div class="ad-question-request-stat-ico" style="background:#D1FAE5;color:#059669;"><i class="bi bi-check-circle-fill"></i></div><div><div class="ad-question-request-stat-val" id="statApproved"><asp:Literal ID="litApproved" runat="server" Text="0" /></div><div class="ad-question-request-stat-lbl"><%= T("Approved", "Diluluskan") %></div></div></div>
    <div class="ad-question-request-stat s-rejected"><div class="ad-question-request-stat-ico" style="background:#FEE2E2;color:#DC2626;"><i class="bi bi-x-circle-fill"></i></div><div><div class="ad-question-request-stat-val" id="statRejected"><asp:Literal ID="litRejected" runat="server" Text="0" /></div><div class="ad-question-request-stat-lbl"><%= T("Rejected", "Ditolak") %></div></div></div>
    <div class="ad-question-request-stat s-today"><div class="ad-question-request-stat-ico" style="background:var(--ad-question-request-light);color:var(--ad-question-request);"><i class="bi bi-calendar-check"></i></div><div><div class="ad-question-request-stat-val" id="statToday"><asp:Literal ID="litToday" runat="server" Text="0" /></div><div class="ad-question-request-stat-lbl"><%= T("Reviewed Today", "Disemak Hari Ini") %></div></div></div>
</div>

<!-- SEARCH/FILTER -->
<div class="ad-question-request-toolbar">
    <div class="ad-question-request-search"><i class="bi bi-search"></i><asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" /></div>
    <asp:DropDownList ID="fStatus" runat="server" Cssclass="ad-question-request-filter">
        <asp:ListItem Value="" Text="All Status" />
        <asp:ListItem Value="Pending" Text="Pending" />
        <asp:ListItem Value="Approved" Text="Approved" />
        <asp:ListItem Value="Rejected" Text="Rejected" />
    </asp:DropDownList>
    <asp:DropDownList ID="fDifficulty" runat="server" Cssclass="ad-question-request-filter">
        <asp:ListItem Value="" Text="All Difficulty" />
        <asp:ListItem Value="Easy" Text="Easy" />
        <asp:ListItem Value="Medium" Text="Medium" />
        <asp:ListItem Value="Hard" Text="Hard" />
    </asp:DropDownList>
    <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="sb-btn sb-btn-primary sb-btn-sm" OnClick="btnSearch_Click" />
    <asp:Button ID="btnReset" runat="server" Text="Reset" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnReset_Click" />
</div>

<!-- PENDING SECTION -->
<div class="ad-question-request-sec-hd"><div class="ad-question-request-sec-title"><i class="bi bi-hourglass-split" style="color:#D97706;"></i> <%= T("Pending Question Requests", "Permintaan Soalan Tertunggak") %> <span id="pendingBadge"><asp:Literal ID="litBadge" runat="server" /></span></div></div>
<div class="ad-question-request-card">
    <asp:Panel ID="pnlPending" runat="server" Visible="false">
        <div id="pnlPendingWrap" class="sb-table-wrapper" style="border:none;border-radius:0;box-shadow:none;"><table id="pendingTable" class="sb-table"><thead><tr>
            <th>ID</th><th><%= T("Question","Soalan") %></th><th><%= T("Type","Jenis") %></th><th><%= T("Teacher","Guru") %></th><th><%= T("Subtopic","Subtopik") %></th><th><%= T("Difficulty","Kesukaran") %></th><th><%= T("Submitted","Dihantar") %></th><th class="col-actions"><%= T("Actions","Tindakan") %></th>
        </tr></thead><tbody>
        <asp:Repeater ID="rptPending" runat="server" OnItemCommand="rptPending_ItemCommand"><ItemTemplate><tr>
            <td><span style="font-size:.75rem;font-family:monospace;color:var(--color-text-muted);"><%# Eval("questionId") %></span></td>
            <td><div class="ad-question-request-qtext"><%# HttpUtility.HtmlEncode(Eval("questionText")) %></div></td>
            <td><span class="sb-badge sb-badge-gray"><%# Eval("questionType") %></span></td>
            <td><%# HttpUtility.HtmlEncode(Eval("teacherName")) %></td>
            <td><%# HttpUtility.HtmlEncode(Eval("subtopicName")) %></td>
            <td><span class='<%# GetDiffClass(Eval("difficulty")) %>'><%# Eval("difficulty") %></span></td>
            <td><span style="font-size:.8rem;color:var(--color-text-muted);"><%# Eval("createdAt") %></span></td>
            <td class="col-actions"><div class="ad-question-request-actions">
                <a href="javascript:;" class="sb-btn sb-btn-primary sb-btn-xs" onclick='viewQuestion(<%# Eval("jsonData") %>)'><i class="bi bi-eye"></i></a>
                <a href="javascript:;" class="sb-btn sb-btn-success sb-btn-xs" onclick='reviewQuestion("<%# Eval("questionId") %>","Approve","<%# Eval("teacherUserId") %>",this)'><i class="bi bi-check-lg"></i></a>
                <a href="javascript:;" class="sb-btn sb-btn-danger sb-btn-xs" onclick='reviewQuestion("<%# Eval("questionId") %>","Reject","<%# Eval("teacherUserId") %>",this)'><i class="bi bi-x-lg"></i></a>
            </div></td>
        </tr></ItemTemplate></asp:Repeater>
        </tbody></table></div>
    </asp:Panel>
    <asp:Panel ID="pnlPendingEmpty" runat="server"><div id="pnlPendingEmptyWrap" class="ad-question-request-empty"><i class="bi bi-check-circle" style="color:#059669;"></i><div class="ad-question-request-empty-msg"><%= T("No pending question requests.", "Tiada permintaan soalan tertunggak.") %></div><div class="ad-question-request-empty-sub"><%= T("All submitted questions have been reviewed.", "Semua soalan yang dihantar telah disemak.") %></div></div></asp:Panel>
</div>

<!-- HISTORY SECTION -->
<div class="ad-question-request-sec-hd"><div class="ad-question-request-sec-title"><i class="bi bi-clock-history" style="color:#7C3AED;"></i> <%= T("Review History", "Sejarah Semakan") %></div></div>
<div class="ad-question-request-card">
    <asp:Panel ID="pnlHistory" runat="server" Visible="false">
        <div id="pnlHistoryWrap" class="sb-table-wrapper" style="border:none;border-radius:0;box-shadow:none;"><table id="historyTable" class="sb-table"><thead><tr>
            <th>ID</th><th><%= T("Question","Soalan") %></th><th><%= T("Type","Jenis") %></th><th><%= T("Teacher","Guru") %></th><th><%= T("Difficulty","Kesukaran") %></th><th><%= T("Reviewed","Disemak") %></th><th><%= T("Status","Status") %></th>
        </tr></thead><tbody>
        <asp:Repeater ID="rptHistory" runat="server"><ItemTemplate><tr>
            <td><span style="font-size:.75rem;font-family:monospace;color:var(--color-text-muted);"><%# Eval("questionId") %></span></td>
            <td><div class="ad-question-request-qtext"><%# HttpUtility.HtmlEncode(Eval("questionText")) %></div></td>
            <td><span class="sb-badge sb-badge-gray"><%# Eval("questionType") %></span></td>
            <td><%# HttpUtility.HtmlEncode(Eval("teacherName")) %></td>
            <td><span class='<%# GetDiffClass(Eval("difficulty")) %>'><%# Eval("difficulty") %></span></td>
            <td><span style="font-size:.8rem;color:var(--color-text-muted);"><%# Eval("reviewedDate") %></span></td>
            <td><%# BuildBadge(Eval("status").ToString()) %></td>
        </tr></ItemTemplate></asp:Repeater>
        </tbody></table></div>
    </asp:Panel>
    <asp:Panel ID="pnlHistoryEmpty" runat="server"><div id="pnlHistoryEmptyWrap" class="ad-question-request-empty"><i class="bi bi-clipboard-data" style="color:var(--ad-question-request);"></i><div class="ad-question-request-empty-msg"><%= T("No reviewed questions yet.", "Belum ada soalan yang disemak.") %></div><div class="ad-question-request-empty-sub"><%= T("Approved and rejected questions will appear here.", "Soalan yang diluluskan dan ditolak akan dipaparkan di sini.") %></div></div></asp:Panel>
</div>

<!-- VIEW MODAL -->
<div class="ad-question-request-modal-overlay" id="qrModal">
    <div class="ad-question-request-modal">
        <div class="ad-question-request-modal-hdr"><span class="ad-question-request-modal-title"><i class="bi bi-eye" style="color:var(--ad-question-request);margin-right:8px;"></i><%= T("Question Details", "Butiran Soalan") %></span><button class="ad-question-request-modal-close" onclick="document.getElementById('qrModal').classList.remove('active')"><i class="bi bi-x-lg"></i></button></div>
        <div class="ad-question-request-modal-body" id="qrDetails"></div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>
function reviewQuestion(qId, action, tUid, btn) {
    var row = btn ? btn.closest('tr') : null;
    var msg = action === 'Approve'
        ? '<%= T("Approve this question?","Luluskan soalan ini?") %>'
        : '<%= T("Reject this question?","Tolak soalan ini?") %>';
    Swal.fire({
        title: msg, icon: 'question', showCancelButton: true,
        confirmButtonColor: action === 'Approve' ? '#059669' : '#DC2626',
        confirmButtonText: action === 'Approve' ? '<%= T("Approve","Luluskan") %>' : '<%= T("Reject","Tolak") %>',
        cancelButtonText: '<%= T("Cancel","Batal") %>'
    }).then(function(r) {
        if (!r.isConfirmed) return;
        var basePath = window.location.pathname;
        if (basePath.indexOf('.aspx') === -1) basePath += '.aspx';
        var url = basePath + '?handler=ReviewQuestion&qId=' + encodeURIComponent(qId) + '&action=' + action + '&tUid=' + encodeURIComponent(tUid);
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
            // 1. Remove row from pending with animation
            if (row) {
                row.style.transition = 'opacity .4s, transform .4s';
                row.style.opacity = '0';
                row.style.transform = 'translateX(30px)';
            }
            setTimeout(function() {
                if (row) row.remove();
                // Check if pending table is empty
                var pendingBody = document.querySelector('#pendingTable tbody');
                if (pendingBody && pendingBody.children.length === 0) {
                    document.getElementById('pnlPendingWrap').style.display = 'none';
                    document.getElementById('pnlPendingEmptyWrap').style.display = '';
                }
            }, 400);

            // 2. Update stats
            document.getElementById('statPending').textContent = data.pending;
            document.getElementById('statApproved').textContent = data.approved;
            document.getElementById('statRejected').textContent = data.rejected;
            document.getElementById('statToday').textContent = data.today;
            var badge = document.getElementById('pendingBadge');
            if (badge) badge.innerHTML = data.pending > 0 ? '<span class="sb-badge sb-badge-warning" style="margin-left:6px;">' + data.pending + '</span>' : '';

            // 3. Add row to history table at top with highlight
            var histTable = document.getElementById('historyTable');
            var histBody = histTable ? histTable.querySelector('tbody') : null;
            if (histBody) {
                document.getElementById('pnlHistoryWrap').style.display = '';
                document.getElementById('pnlHistoryEmptyWrap').style.display = 'none';
                var cells = row.querySelectorAll('td');
                var qIdText = cells[0] ? cells[0].innerHTML : '';
                var qText = cells[1] ? cells[1].innerHTML : '';
                var qType = cells[2] ? cells[2].innerHTML : '';
                var teacher = cells[3] ? cells[3].innerHTML : '';
                var diff = cells[4] ? cells[4].innerHTML : '';
                var statusBadge = action === 'Approve'
                    ? '<span class="sb-badge sb-badge-success"><i class="bi bi-check-circle-fill"></i> Approved</span>'
                    : '<span class="sb-badge sb-badge-error"><i class="bi bi-x-circle-fill"></i> Rejected</span>';
                var justBadge = action === 'Approve'
                    ? '<span class="ad-question-request-just-badge qr-just-approved">Just Approved</span>'
                    : '<span class="ad-question-request-just-badge qr-just-rejected">Just Rejected</span>';

                var newRow = document.createElement('tr');
                newRow.className = action === 'Approve' ? 'ad-question-request-highlight-approved' : 'ad-question-request-highlight-rejected';
                newRow.innerHTML = '<td>' + qIdText + '</td><td>' + qText + '</td><td>' + qType + '</td><td>' + teacher + '</td><td>' + diff + '</td><td><span style="font-size:.8rem;color:var(--color-text-muted);">' + data.reviewedAt + '</span></td><td>' + statusBadge + ' ' + justBadge + '</td>';
                histBody.insertBefore(newRow, histBody.firstChild);

                // 4. Scroll to history
                setTimeout(function() {
                    newRow.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }, 100);

                // 5. Remove highlight after 5s
                setTimeout(function() {
                    newRow.classList.remove('ad-question-request-highlight-approved', 'ad-question-request-highlight-rejected');
                    var jb = newRow.querySelector('.ad-question-request-just-badge');
                    if (jb) jb.style.opacity = '0';
                    setTimeout(function() { if (jb) jb.remove(); }, 500);
                }, 5000);
            }

            // 6. Toast
            var toastMsg = action === 'Approve'
                ? '<%= T("Question approved successfully.","Soalan berjaya diluluskan.") %>'
                : '<%= T("Question rejected successfully.","Soalan berjaya ditolak.") %>';
            Swal.fire({ icon: 'success', title: toastMsg, confirmButtonColor: '#6366F1', timer: 2500, timerProgressBar: true, showConfirmButton: false,
                position: 'top-end', toast: true });
        }).catch(function(err) {
            Swal.fire({ icon: 'error', title: 'Error', text: err.message || 'Network error. Please try again.' });
        });
    });
}

function viewQuestion(d){
    var h='<div class="ad-question-request-detail-grid">';
    h+='<div style="grid-column:1/-1;background:var(--ad-question-request-light);border-radius:12px;padding:16px 20px;margin-bottom:12px;border:1px solid var(--ad-question-request-border);">';
    h+='<div style="font-size:.7rem;font-weight:700;color:var(--ad-question-request);text-transform:uppercase;letter-spacing:.5px;margin-bottom:6px;"><i class="bi bi-chat-square-text"></i> Question Text</div>';
    h+='<div style="font-size:.95rem;font-weight:600;color:var(--color-text);line-height:1.5;">'+d.text+'</div></div>';
    h+='<div class="ad-question-request-detail-item"><div class="ad-question-request-detail-label"><i class="bi bi-hash"></i> Question ID</div><div class="ad-question-request-detail-value">'+d.id+'</div></div>';
    h+='<div class="ad-question-request-detail-item"><div class="ad-question-request-detail-label"><i class="bi bi-person"></i> Teacher</div><div class="ad-question-request-detail-value">'+d.teacher+'</div></div>';
    h+='<div class="ad-question-request-detail-item"><div class="ad-question-request-detail-label"><i class="bi bi-tag"></i> Type</div><div class="ad-question-request-detail-value">'+d.type+'</div></div>';
    h+='<div class="ad-question-request-detail-item"><div class="ad-question-request-detail-label"><i class="bi bi-speedometer2"></i> Difficulty</div><div class="ad-question-request-detail-value">'+d.diff+'</div></div>';
    h+='<div class="ad-question-request-detail-item"><div class="ad-question-request-detail-label"><i class="bi bi-layers"></i> Level</div><div class="ad-question-request-detail-value">'+(d.level||'-')+'</div></div>';
    h+='<div class="ad-question-request-detail-item"><div class="ad-question-request-detail-label"><i class="bi bi-folder"></i> Unit</div><div class="ad-question-request-detail-value">'+(d.unit||'-')+'</div></div>';
    h+='<div class="ad-question-request-detail-item"><div class="ad-question-request-detail-label"><i class="bi bi-bookmark"></i> Subtopic</div><div class="ad-question-request-detail-value">'+d.subtopic+'</div></div>';
    h+='<div class="ad-question-request-detail-item"><div class="ad-question-request-detail-label"><i class="bi bi-calendar3"></i> Submitted</div><div class="ad-question-request-detail-value">'+d.date+'</div></div>';
    if(d.optA){
        h+='<div style="grid-column:1/-1;margin-top:8px;"><div style="font-size:.75rem;font-weight:700;color:var(--color-text-secondary);text-transform:uppercase;letter-spacing:.5px;margin-bottom:8px;"><i class="bi bi-list-check"></i> Answer Options</div>';
        [{l:"A",v:d.optA},{l:"B",v:d.optB},{l:"C",v:d.optC},{l:"D",v:d.optD}].forEach(function(o){
            if(!o.v)return;
            var isC=(d.correct===o.l);
            h+='<div class="ad-question-request-opt'+(isC?" correct":"")+'"><strong>'+o.l+')</strong> '+o.v+(isC?' <i class="bi bi-check-circle-fill" style="color:#059669;margin-left:6px;"></i>':'')+'</div>';
        });
        h+='</div>';
    }
    h+='<div style="grid-column:1/-1;margin-top:8px;background:#D1FAE5;border-radius:10px;padding:12px 16px;border:1px solid #A7F3D0;">';
    h+='<div style="font-size:.75rem;font-weight:700;color:#065F46;margin-bottom:4px;"><i class="bi bi-check-circle-fill"></i> Correct Answer</div>';
    h+='<div style="font-size:.9rem;font-weight:700;color:#065F46;">'+d.correct+'</div>';
    if(d.explanation){h+='<div style="margin-top:8px;font-size:.8rem;color:#047857;line-height:1.4;"><strong>Explanation:</strong> '+d.explanation+'</div>';}
    h+='</div>';
    h+='<div style="grid-column:1/-1;margin-top:8px;display:flex;align-items:center;gap:8px;">';
    h+='<span style="font-size:.75rem;font-weight:600;color:var(--color-text-muted);">Status:</span>';
    if(d.status==="Approved") h+='<span class="sb-badge sb-badge-success"><i class="bi bi-check-circle-fill"></i> Approved</span>';
    else if(d.status==="Rejected") h+='<span class="sb-badge sb-badge-error"><i class="bi bi-x-circle-fill"></i> Rejected</span>';
    else h+='<span class="sb-badge sb-badge-warning"><i class="bi bi-hourglass-split"></i> Pending</span>';
    h+='</div>';
    h+='</div>';
    document.getElementById('qrDetails').innerHTML=h;
    document.getElementById('qrModal').classList.add('active');
}
</script>
</asp:Content>
