<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="QuestionRequests.aspx.cs"
    Inherits="ScienceBuddy.Admin.QuestionRequests" MasterPageFile="~/Site.Master"
    Title="Question Requests" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" />
<style>
:root{--qr:#6366F1;--qr-dark:#4F46E5;--qr-light:#EEF2FF;--qr-border:#C7D2FE;}
.qr-hdr{display:flex;align-items:center;justify-content:space-between;padding:var(--space-xl) 0 var(--space-lg);border-bottom:1.5px solid var(--border-color);margin-bottom:var(--space-xl);flex-wrap:wrap;gap:var(--space-md);}
.qr-hdr-title{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;color:var(--color-text);display:flex;align-items:center;gap:10px;}
.qr-hdr-sub{font-size:.875rem;color:var(--color-text-secondary);margin-top:4px;max-width:520px;}
.qr-hdr-right{display:flex;gap:var(--space-sm);}
.qr-btn-refresh{padding:8px 16px;border-radius:var(--border-radius);border:1.5px solid var(--border-color);background:var(--color-white);color:var(--color-text);font-weight:600;font-size:.8125rem;cursor:pointer;display:inline-flex;align-items:center;gap:6px;transition:all .2s;text-decoration:none;}
.qr-btn-refresh:hover{background:var(--color-surface-alt);transform:translateY(-1px);}

.qr-stats{display:grid;grid-template-columns:repeat(4,1fr);gap:var(--space-md);margin-bottom:var(--space-xl);}
.qr-stat{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);padding:var(--space-lg);display:flex;align-items:center;gap:var(--space-md);transition:transform .2s,box-shadow .2s;position:relative;overflow:hidden;}
.qr-stat:hover{transform:translateY(-3px);box-shadow:var(--shadow-md);}
.qr-stat::before{content:'';position:absolute;top:0;left:0;right:0;height:4px;}
.qr-stat.s-pending::before{background:linear-gradient(90deg,#D97706,#FCD34D);}
.qr-stat.s-approved::before{background:linear-gradient(90deg,#059669,#34D399);}
.qr-stat.s-rejected::before{background:linear-gradient(90deg,#DC2626,#F87171);}
.qr-stat.s-today::before{background:linear-gradient(90deg,#6366F1,#818CF8);}
.qr-stat-ico{width:48px;height:48px;border-radius:var(--border-radius-lg);display:flex;align-items:center;justify-content:center;font-size:1.25rem;flex-shrink:0;}
.qr-stat-val{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;color:var(--color-text);}
.qr-stat-lbl{font-size:.8rem;color:var(--color-text-secondary);font-weight:600;}

.qr-toolbar{display:flex;gap:var(--space-md);margin-bottom:var(--space-xl);flex-wrap:wrap;align-items:center;background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);padding:var(--space-md) var(--space-lg);}
.qr-search{flex:1;min-width:200px;position:relative;}
.qr-search i{position:absolute;left:12px;top:50%;transform:translateY(-50%);color:var(--color-text-muted);}
.qr-search input{width:100%;padding:9px 12px 9px 38px;border:1.5px solid var(--border-color);border-radius:var(--border-radius);font-size:.875rem;transition:border-color .2s,box-shadow .2s;}
.qr-search input:focus{outline:none;border-color:var(--qr);box-shadow:0 0 0 3px rgba(99,102,241,.1);}
.qr-filter{padding:8px 12px;border:1.5px solid var(--border-color);border-radius:var(--border-radius);font-size:.8125rem;background:var(--color-white);cursor:pointer;}
.qr-filter:focus{outline:none;border-color:var(--qr);}

.qr-sec-hd{display:flex;align-items:center;gap:var(--space-sm);margin-bottom:var(--space-md);margin-top:var(--space-lg);}
.qr-sec-title{font-family:var(--font-primary);font-size:1.0625rem;font-weight:800;color:var(--color-text);display:flex;align-items:center;gap:8px;}
.qr-sec-sub{font-size:.8rem;color:var(--color-text-muted);margin-left:auto;}

.qr-card{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);overflow:hidden;margin-bottom:var(--space-xl);}
.qr-empty{display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;padding:var(--space-2xl);color:var(--color-text-muted);}
.qr-empty i{font-size:2.75rem;margin-bottom:var(--space-md);opacity:.5;}
.qr-empty-msg{font-size:.9375rem;font-weight:600;color:var(--color-text-secondary);}
.qr-empty-sub{font-size:.85rem;margin-top:4px;}

.qr-qtext{max-width:300px;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;font-weight:600;color:var(--color-text);font-size:.85rem;line-height:1.4;}
.qr-diff-easy{background:#D1FAE5;color:#065F46;padding:3px 8px;border-radius:var(--border-radius-full);font-size:.7rem;font-weight:700;}
.qr-diff-medium{background:#FEF3C7;color:#92400E;padding:3px 8px;border-radius:var(--border-radius-full);font-size:.7rem;font-weight:700;}
.qr-diff-hard{background:#FEE2E2;color:#991B1B;padding:3px 8px;border-radius:var(--border-radius-full);font-size:.7rem;font-weight:700;}
.qr-actions{display:flex;gap:5px;flex-wrap:nowrap;}

/* Modal */
.qr-modal-overlay{display:none;position:fixed;top:0;left:var(--sidebar-width,0px);right:0;bottom:0;background:rgba(0,0,0,.5);z-index:1000;align-items:center;justify-content:center;padding:var(--space-xl);}
.qr-modal-overlay.active{display:flex;}
.qr-modal{background:var(--color-white);border-radius:var(--border-radius-xl);width:100%;max-width:680px;max-height:90vh;overflow-y:auto;box-shadow:0 25px 60px rgba(0,0,0,.2);animation:qrModalIn .3s ease;}
@keyframes qrModalIn{from{opacity:0;transform:translateY(20px)}to{opacity:1;transform:translateY(0)}}
.qr-modal-hdr{padding:var(--space-lg) var(--space-xl);border-bottom:1px solid var(--border-color);display:flex;align-items:center;justify-content:space-between;}
.qr-modal-title{font-family:var(--font-primary);font-size:1.125rem;font-weight:700;}
.qr-modal-close{width:36px;height:36px;border-radius:var(--border-radius);border:none;background:var(--color-surface-alt);cursor:pointer;display:flex;align-items:center;justify-content:center;font-size:1.1rem;transition:background .2s;}
.qr-modal-close:hover{background:#E2E8F0;}
.qr-modal-body{padding:var(--space-xl);}
.qr-detail-grid{display:grid;grid-template-columns:1fr 1fr;gap:var(--space-md);}
.qr-detail-item{padding:var(--space-sm) 0;}
.qr-detail-label{font-size:.7rem;font-weight:600;color:var(--color-text-muted);text-transform:uppercase;letter-spacing:.5px;margin-bottom:3px;}
.qr-detail-value{font-size:.9rem;font-weight:600;color:var(--color-text);}
.qr-detail-full{grid-column:1/-1;background:var(--color-surface-alt);border-radius:var(--border-radius);padding:var(--space-md);margin-top:var(--space-sm);}
.qr-detail-full h4{font-size:.8rem;font-weight:700;color:var(--color-text-secondary);margin-bottom:6px;}
.qr-opt{padding:6px 10px;border-radius:var(--border-radius);margin-bottom:4px;font-size:.85rem;border:1px solid var(--border-color);}
.qr-opt.correct{background:#D1FAE5;border-color:#6EE7B7;font-weight:700;}

@media(max-width:1279px){.qr-stats{grid-template-columns:repeat(2,1fr);}}
@media(max-width:767px){.qr-stats{grid-template-columns:1fr 1fr;}.qr-toolbar{flex-direction:column;align-items:stretch;}.qr-detail-grid{grid-template-columns:1fr;}}

/* Highlight animations */
.qr-highlight-approved{background:#ECFDF5;border-left:3px solid #059669;animation:qrGlowGreen 3s ease;transition:background 1s,border-color 1s;}
.qr-highlight-rejected{background:#FEF2F2;border-left:3px solid #DC2626;animation:qrGlowRed 3s ease;transition:background 1s,border-color 1s;}
@keyframes qrGlowGreen{0%{box-shadow:0 0 12px rgba(5,150,105,.4)}50%{box-shadow:0 0 6px rgba(5,150,105,.2)}100%{box-shadow:none}}
@keyframes qrGlowRed{0%{box-shadow:0 0 12px rgba(220,38,38,.4)}50%{box-shadow:0 0 6px rgba(220,38,38,.2)}100%{box-shadow:none}}
.qr-just-badge{font-size:.65rem;font-weight:700;text-transform:uppercase;letter-spacing:.3px;padding:2px 8px;border-radius:var(--border-radius-full);margin-left:6px;transition:opacity .5s;}
.qr-just-approved{background:#D1FAE5;color:#065F46;}
.qr-just-rejected{background:#FEE2E2;color:#991B1B;}
</style>
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
<div class="qr-hdr">
    <div>
        <div class="qr-hdr-title"><i class="bi bi-clipboard-check" style="color:var(--qr);"></i> <%= T("Question Requests", "Permintaan Soalan") %></div>
        <div class="qr-hdr-sub"><%= T("Review, approve or reject teacher-submitted questions. Approved questions become available for Practice Quiz creation.", "Semak, luluskan atau tolak soalan yang dihantar guru. Soalan yang diluluskan boleh digunakan dalam Kuiz Latihan.") %></div>
    </div>
    <div class="qr-hdr-right">
        <a href="javascript:;" class="qr-btn-refresh" onclick="location.reload();"><i class="bi bi-arrow-clockwise"></i> <%= T("Refresh", "Muat Semula") %></a>
    </div>
</div>

<!-- STATS -->
<div class="qr-stats">
    <div class="qr-stat s-pending"><div class="qr-stat-ico" style="background:#FEF3C7;color:#D97706;"><i class="bi bi-hourglass-split"></i></div><div><div class="qr-stat-val" id="statPending"><asp:Literal ID="litPending" runat="server" Text="0" /></div><div class="qr-stat-lbl"><%= T("Pending Questions", "Soalan Tertunggak") %></div></div></div>
    <div class="qr-stat s-approved"><div class="qr-stat-ico" style="background:#D1FAE5;color:#059669;"><i class="bi bi-check-circle-fill"></i></div><div><div class="qr-stat-val" id="statApproved"><asp:Literal ID="litApproved" runat="server" Text="0" /></div><div class="qr-stat-lbl"><%= T("Approved", "Diluluskan") %></div></div></div>
    <div class="qr-stat s-rejected"><div class="qr-stat-ico" style="background:#FEE2E2;color:#DC2626;"><i class="bi bi-x-circle-fill"></i></div><div><div class="qr-stat-val" id="statRejected"><asp:Literal ID="litRejected" runat="server" Text="0" /></div><div class="qr-stat-lbl"><%= T("Rejected", "Ditolak") %></div></div></div>
    <div class="qr-stat s-today"><div class="qr-stat-ico" style="background:var(--qr-light);color:var(--qr);"><i class="bi bi-calendar-check"></i></div><div><div class="qr-stat-val" id="statToday"><asp:Literal ID="litToday" runat="server" Text="0" /></div><div class="qr-stat-lbl"><%= T("Reviewed Today", "Disemak Hari Ini") %></div></div></div>
</div>

<!-- SEARCH/FILTER -->
<div class="qr-toolbar">
    <div class="qr-search"><i class="bi bi-search"></i><asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" /></div>
    <asp:DropDownList ID="fStatus" runat="server" CssClass="qr-filter">
        <asp:ListItem Value="" Text="All Status" />
        <asp:ListItem Value="Pending" Text="Pending" />
        <asp:ListItem Value="Approved" Text="Approved" />
        <asp:ListItem Value="Rejected" Text="Rejected" />
    </asp:DropDownList>
    <asp:DropDownList ID="fDifficulty" runat="server" CssClass="qr-filter">
        <asp:ListItem Value="" Text="All Difficulty" />
        <asp:ListItem Value="Easy" Text="Easy" />
        <asp:ListItem Value="Medium" Text="Medium" />
        <asp:ListItem Value="Hard" Text="Hard" />
    </asp:DropDownList>
    <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="sb-btn sb-btn-primary sb-btn-sm" OnClick="btnSearch_Click" />
    <asp:Button ID="btnReset" runat="server" Text="Reset" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnReset_Click" />
</div>

<!-- PENDING SECTION -->
<div class="qr-sec-hd"><div class="qr-sec-title"><i class="bi bi-hourglass-split" style="color:#D97706;"></i> <%= T("Pending Question Requests", "Permintaan Soalan Tertunggak") %> <span id="pendingBadge"><asp:Literal ID="litBadge" runat="server" /></span></div></div>
<div class="qr-card">
    <asp:Panel ID="pnlPending" runat="server" Visible="false">
        <div id="pnlPendingWrap" class="sb-table-wrapper" style="border:none;border-radius:0;box-shadow:none;"><table id="pendingTable" class="sb-table"><thead><tr>
            <th>ID</th><th><%= T("Question","Soalan") %></th><th><%= T("Type","Jenis") %></th><th><%= T("Teacher","Guru") %></th><th><%= T("Subtopic","Subtopik") %></th><th><%= T("Difficulty","Kesukaran") %></th><th><%= T("Submitted","Dihantar") %></th><th class="col-actions"><%= T("Actions","Tindakan") %></th>
        </tr></thead><tbody>
        <asp:Repeater ID="rptPending" runat="server" OnItemCommand="rptPending_ItemCommand"><ItemTemplate><tr>
            <td><span style="font-size:.75rem;font-family:monospace;color:var(--color-text-muted);"><%# Eval("questionId") %></span></td>
            <td><div class="qr-qtext"><%# HttpUtility.HtmlEncode(Eval("questionText")) %></div></td>
            <td><span class="sb-badge sb-badge-gray"><%# Eval("questionType") %></span></td>
            <td><%# HttpUtility.HtmlEncode(Eval("teacherName")) %></td>
            <td><%# HttpUtility.HtmlEncode(Eval("subtopicName")) %></td>
            <td><span class='<%# GetDiffClass(Eval("difficulty")) %>'><%# Eval("difficulty") %></span></td>
            <td><span style="font-size:.8rem;color:var(--color-text-muted);"><%# Eval("createdAt") %></span></td>
            <td class="col-actions"><div class="qr-actions">
                <a href="javascript:;" class="sb-btn sb-btn-primary sb-btn-xs" onclick='viewQuestion(<%# Eval("jsonData") %>)'><i class="bi bi-eye"></i></a>
                <a href="javascript:;" class="sb-btn sb-btn-success sb-btn-xs" onclick='reviewQuestion("<%# Eval("questionId") %>","Approve","<%# Eval("teacherUserId") %>",this)'><i class="bi bi-check-lg"></i></a>
                <a href="javascript:;" class="sb-btn sb-btn-danger sb-btn-xs" onclick='reviewQuestion("<%# Eval("questionId") %>","Reject","<%# Eval("teacherUserId") %>",this)'><i class="bi bi-x-lg"></i></a>
            </div></td>
        </tr></ItemTemplate></asp:Repeater>
        </tbody></table></div>
    </asp:Panel>
    <asp:Panel ID="pnlPendingEmpty" runat="server"><div id="pnlPendingEmptyWrap" class="qr-empty"><i class="bi bi-check-circle" style="color:#059669;"></i><div class="qr-empty-msg"><%= T("No pending question requests.", "Tiada permintaan soalan tertunggak.") %></div><div class="qr-empty-sub"><%= T("All submitted questions have been reviewed.", "Semua soalan yang dihantar telah disemak.") %></div></div></asp:Panel>
</div>

<!-- HISTORY SECTION -->
<div class="qr-sec-hd"><div class="qr-sec-title"><i class="bi bi-clock-history" style="color:#7C3AED;"></i> <%= T("Review History", "Sejarah Semakan") %></div></div>
<div class="qr-card">
    <asp:Panel ID="pnlHistory" runat="server" Visible="false">
        <div id="pnlHistoryWrap" class="sb-table-wrapper" style="border:none;border-radius:0;box-shadow:none;"><table id="historyTable" class="sb-table"><thead><tr>
            <th>ID</th><th><%= T("Question","Soalan") %></th><th><%= T("Type","Jenis") %></th><th><%= T("Teacher","Guru") %></th><th><%= T("Difficulty","Kesukaran") %></th><th><%= T("Reviewed","Disemak") %></th><th><%= T("Status","Status") %></th>
        </tr></thead><tbody>
        <asp:Repeater ID="rptHistory" runat="server"><ItemTemplate><tr>
            <td><span style="font-size:.75rem;font-family:monospace;color:var(--color-text-muted);"><%# Eval("questionId") %></span></td>
            <td><div class="qr-qtext"><%# HttpUtility.HtmlEncode(Eval("questionText")) %></div></td>
            <td><span class="sb-badge sb-badge-gray"><%# Eval("questionType") %></span></td>
            <td><%# HttpUtility.HtmlEncode(Eval("teacherName")) %></td>
            <td><span class='<%# GetDiffClass(Eval("difficulty")) %>'><%# Eval("difficulty") %></span></td>
            <td><span style="font-size:.8rem;color:var(--color-text-muted);"><%# Eval("reviewedDate") %></span></td>
            <td><%# BuildBadge(Eval("status").ToString()) %></td>
        </tr></ItemTemplate></asp:Repeater>
        </tbody></table></div>
    </asp:Panel>
    <asp:Panel ID="pnlHistoryEmpty" runat="server"><div id="pnlHistoryEmptyWrap" class="qr-empty"><i class="bi bi-clipboard-data" style="color:var(--qr);"></i><div class="qr-empty-msg"><%= T("No reviewed questions yet.", "Belum ada soalan yang disemak.") %></div><div class="qr-empty-sub"><%= T("Approved and rejected questions will appear here.", "Soalan yang diluluskan dan ditolak akan dipaparkan di sini.") %></div></div></asp:Panel>
</div>

<!-- VIEW MODAL -->
<div class="qr-modal-overlay" id="qrModal">
    <div class="qr-modal">
        <div class="qr-modal-hdr"><span class="qr-modal-title"><i class="bi bi-eye" style="color:var(--qr);margin-right:8px;"></i><%= T("Question Details", "Butiran Soalan") %></span><button class="qr-modal-close" onclick="document.getElementById('qrModal').classList.remove('active')"><i class="bi bi-x-lg"></i></button></div>
        <div class="qr-modal-body" id="qrDetails"></div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>
function reviewQuestion(qId, action, tUid, btn) {
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
        var row = btn.closest('tr');
        var url = window.location.pathname + '?handler=ReviewQuestion&qId=' + encodeURIComponent(qId) + '&action=' + action + '&tUid=' + encodeURIComponent(tUid);
        fetch(url, { method: 'POST', headers: { 'X-Requested-With': 'XMLHttpRequest' } })
        .then(function(resp) { return resp.json(); })
        .then(function(data) {
            if (!data.success) { Swal.fire({ icon: 'error', title: 'Error', text: data.msg }); return; }
            // 1. Remove row from pending with animation
            row.style.transition = 'opacity .4s, transform .4s';
            row.style.opacity = '0';
            row.style.transform = 'translateX(30px)';
            setTimeout(function() {
                row.remove();
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
                    ? '<span class="qr-just-badge qr-just-approved">Just Approved</span>'
                    : '<span class="qr-just-badge qr-just-rejected">Just Rejected</span>';

                var newRow = document.createElement('tr');
                newRow.className = action === 'Approve' ? 'qr-highlight-approved' : 'qr-highlight-rejected';
                newRow.innerHTML = '<td>' + qIdText + '</td><td>' + qText + '</td><td>' + qType + '</td><td>' + teacher + '</td><td>' + diff + '</td><td><span style="font-size:.8rem;color:var(--color-text-muted);">' + data.reviewedAt + '</span></td><td>' + statusBadge + ' ' + justBadge + '</td>';
                histBody.insertBefore(newRow, histBody.firstChild);

                // 4. Scroll to history
                setTimeout(function() {
                    newRow.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }, 100);

                // 5. Remove highlight after 5s
                setTimeout(function() {
                    newRow.classList.remove('qr-highlight-approved', 'qr-highlight-rejected');
                    var jb = newRow.querySelector('.qr-just-badge');
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
        }).catch(function() {
            Swal.fire({ icon: 'error', title: 'Network Error', text: 'Please try again.' });
        });
    });
}

function viewQuestion(d){
    var h='<div class="qr-detail-grid">';
    h+='<div style="grid-column:1/-1;background:var(--qr-light);border-radius:12px;padding:16px 20px;margin-bottom:12px;border:1px solid var(--qr-border);">';
    h+='<div style="font-size:.7rem;font-weight:700;color:var(--qr);text-transform:uppercase;letter-spacing:.5px;margin-bottom:6px;"><i class="bi bi-chat-square-text"></i> Question Text</div>';
    h+='<div style="font-size:.95rem;font-weight:600;color:var(--color-text);line-height:1.5;">'+d.text+'</div></div>';
    h+='<div class="qr-detail-item"><div class="qr-detail-label"><i class="bi bi-hash"></i> Question ID</div><div class="qr-detail-value">'+d.id+'</div></div>';
    h+='<div class="qr-detail-item"><div class="qr-detail-label"><i class="bi bi-person"></i> Teacher</div><div class="qr-detail-value">'+d.teacher+'</div></div>';
    h+='<div class="qr-detail-item"><div class="qr-detail-label"><i class="bi bi-tag"></i> Type</div><div class="qr-detail-value">'+d.type+'</div></div>';
    h+='<div class="qr-detail-item"><div class="qr-detail-label"><i class="bi bi-speedometer2"></i> Difficulty</div><div class="qr-detail-value">'+d.diff+'</div></div>';
    h+='<div class="qr-detail-item"><div class="qr-detail-label"><i class="bi bi-layers"></i> Level</div><div class="qr-detail-value">'+(d.level||'-')+'</div></div>';
    h+='<div class="qr-detail-item"><div class="qr-detail-label"><i class="bi bi-folder"></i> Unit</div><div class="qr-detail-value">'+(d.unit||'-')+'</div></div>';
    h+='<div class="qr-detail-item"><div class="qr-detail-label"><i class="bi bi-bookmark"></i> Subtopic</div><div class="qr-detail-value">'+d.subtopic+'</div></div>';
    h+='<div class="qr-detail-item"><div class="qr-detail-label"><i class="bi bi-calendar3"></i> Submitted</div><div class="qr-detail-value">'+d.date+'</div></div>';
    if(d.optA){
        h+='<div style="grid-column:1/-1;margin-top:8px;"><div style="font-size:.75rem;font-weight:700;color:var(--color-text-secondary);text-transform:uppercase;letter-spacing:.5px;margin-bottom:8px;"><i class="bi bi-list-check"></i> Answer Options</div>';
        [{l:"A",v:d.optA},{l:"B",v:d.optB},{l:"C",v:d.optC},{l:"D",v:d.optD}].forEach(function(o){
            if(!o.v)return;
            var isC=(d.correct===o.l);
            h+='<div class="qr-opt'+(isC?" correct":"")+'"><strong>'+o.l+')</strong> '+o.v+(isC?' <i class="bi bi-check-circle-fill" style="color:#059669;margin-left:6px;"></i>':'')+'</div>';
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
