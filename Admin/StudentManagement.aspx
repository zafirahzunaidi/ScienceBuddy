<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StudentManagement.aspx.cs"
    Inherits="ScienceBuddy.Admin.StudentManagement" MasterPageFile="~/Site.Master"
    Title="Student Management" ValidateRequest="false" EnableEventValidation="false" %>

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
        <a href="<%: ResolveUrl("~/Admin/StudentManagement.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-people item-icon"></i><span class="item-label">Students</span></a>
        <a href="<%: ResolveUrl("~/Admin/ParentManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-heart item-icon"></i><span class="item-label">Parents</span></a>
        <a href="<%: ResolveUrl("~/Admin/TeacherManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-badge item-icon"></i><span class="item-label">Teachers</span></a>
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

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%= T("Student Management", "Pengurusan Pelajar") %></asp:Content>

<%-- ════ MAIN CONTENT ════ --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- PAGE HEADER --%>
<div class="ad-student-management-header">
    <div class="ad-student-management-header-left">
        <h1 class="ad-student-management-header-title"><i class="bi bi-mortarboard-fill" style="color:var(--ad-student-management-accent);"></i> <%= T("Student Management", "Pengurusan Pelajar") %></h1>
        <p class="ad-student-management-header-sub"><%= T("Manage, monitor and explore student learning progress across ScienceBuddy.", "Urus, pantau dan terokai kemajuan pembelajaran pelajar di ScienceBuddy.") %></p>
        <span class="ad-student-management-badge-dir"><i class="bi bi-people-fill"></i> <%= T("Student Directory", "Direktori Pelajar") %></span>
    </div>
    <div style="display:flex;align-items:center;gap:var(--space-md);">
        <div class="ad-student-management-header-icon"><i class="bi bi-mortarboard-fill"></i></div>
        <a href="javascript:;" onclick="openAddStudent()" style="display:inline-flex;align-items:center;gap:8px;padding:12px 24px;background:linear-gradient(135deg,#1D4ED8,#2563EB,#3B82F6);color:#fff;border-radius:12px;font-weight:700;font-size:.9rem;text-decoration:none;box-shadow:0 6px 20px rgba(37,99,235,.35);transition:all .25s;">
            <i class="bi bi-person-plus-fill"></i> <%= T("+ Add Student", "+ Tambah Pelajar") %>
        </a>
    </div>
</div>

<%-- INSIGHT CARDS --%>
<div class="ad-student-management-insights">
    <div class="ad-student-management-insight ad-student-management-gi-total">
        <div class="ad-student-management-insight-ico"><i class="bi bi-book-fill"></i></div>
        <div class="ad-student-management-insight-val"><asp:Literal ID="litTotal" runat="server" Text="0" /></div>
        <div class="ad-student-management-insight-lbl"><%= T("Registered learners", "Pelajar berdaftar") %></div>
    </div>
    <div class="ad-student-management-insight ad-student-management-gi-xp">
        <div class="ad-student-management-insight-ico"><i class="bi bi-star-fill"></i></div>
        <div class="ad-student-management-insight-val"><asp:Literal ID="litAvgXP" runat="server" Text="0" /></div>
        <div class="ad-student-management-insight-lbl"><%= T("Average XP earned", "Purata XP diperoleh") %></div>
    </div>
    <div class="ad-student-management-insight ad-student-management-gi-level">
        <div class="ad-student-management-insight-ico"><i class="bi bi-trophy-fill"></i></div>
        <div class="ad-student-management-insight-val"><asp:Literal ID="litHighLevel" runat="server" Text="-" /></div>
        <div class="ad-student-management-insight-lbl"><%= T("Highest level reached", "Tahap tertinggi dicapai") %></div>
    </div>
    <div class="ad-student-management-insight ad-student-management-gi-active">
        <div class="ad-student-management-insight-ico"><i class="bi bi-fire"></i></div>
        <div class="ad-student-management-insight-val"><asp:Literal ID="litActive" runat="server" Text="0" /></div>
        <div class="ad-student-management-insight-lbl"><%= T("Active students", "Pelajar aktif") %></div>
    </div>
</div>

<%-- SEARCH PANEL --%>
<div class="ad-student-management-search-panel">
    <i class="bi bi-search text-muted"></i>
    <asp:TextBox ID="txtSearch" runat="server" CssClass="sb-input sb-input-sm" AutoPostBack="false" />
    <asp:DropDownList ID="ddlLevel" runat="server" CssClass="sb-select sb-input-sm" AutoPostBack="false">
        <asp:ListItem Value="">All Levels</asp:ListItem>
    </asp:DropDownList>
    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="sb-select sb-input-sm" AutoPostBack="false">
        <asp:ListItem Value="">All Status</asp:ListItem>
        <asp:ListItem Value="Active">Active</asp:ListItem>
        <asp:ListItem Value="Blocked">Blocked</asp:ListItem>
    </asp:DropDownList>
    <asp:DropDownList ID="ddlLang" runat="server" CssClass="sb-select sb-input-sm" AutoPostBack="false">
        <asp:ListItem Value="">All Languages</asp:ListItem>
        <asp:ListItem Value="EN">English</asp:ListItem>
        <asp:ListItem Value="BM">Bahasa Melayu</asp:ListItem>
    </asp:DropDownList>
    <asp:DropDownList ID="ddlSort" runat="server" CssClass="sb-select sb-input-sm" AutoPostBack="false">
        <asp:ListItem Value="name">A-Z</asp:ListItem>
        <asp:ListItem Value="name_desc">Z-A</asp:ListItem>
        <asp:ListItem Value="xp_desc">Highest XP</asp:ListItem>
        <asp:ListItem Value="xp_asc">Lowest XP</asp:ListItem>
    </asp:DropDownList>
    <asp:Button ID="btnSearch" runat="server" CssClass="sb-btn sb-btn-primary sb-btn-sm" OnClick="btnSearch_Click" />
    <asp:Button ID="btnReset" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnReset_Click" />
</div>

<%-- STUDENT CARDS --%>
<asp:Panel ID="pnlStudents" runat="server" Visible="false">
    <div class="ad-student-management-grid">
        <asp:Repeater ID="rptStudents" runat="server" OnItemCommand="rptStudents_ItemCommand">
            <ItemTemplate>
                <div class="ad-student-management-card">
                    <div class="ad-student-management-avatar" style='<%# Eval("avatarGradient") %>'>
                        <%# HttpUtility.HtmlEncode(Eval("initials")) %>
                        <span class='ad-student-management-avatar-status <%# Eval("statusClass") %>'></span>
                    </div>
                    <div class="ad-student-management-name"><%# HttpUtility.HtmlEncode(Eval("displayName")) %></div>
                    <div class="ad-student-management-username">@<%# HttpUtility.HtmlEncode(Eval("username")) %></div>
                    <div class="ad-student-management-badges">
                        <span class="ad-student-management-badge-pill ad-student-management-badge-level"><%# HttpUtility.HtmlEncode(Eval("levelName")) %></span>
                        <span class="ad-student-management-badge-pill ad-student-management-badge-personality"><%# HttpUtility.HtmlEncode(Eval("personalityName")) %></span>
                        <span class="ad-student-management-badge-pill ad-student-management-badge-lang"><%# HttpUtility.HtmlEncode(Eval("language")) %></span>
                    </div>
                    <div class="ad-student-management-progress-section">
                        <div class="ad-student-management-progress-row"><span>XP</span><span><%# Eval("xp") %></span></div>
                        <div class="ad-student-management-progress-bar"><div class="ad-student-management-progress-fill" style='width:<%# Eval("xpPct") %>%'></div></div>
                    </div>
                    <div class="ad-student-management-meta">
                        <span><i class="bi bi-book"></i> <%# Eval("lessonsCompleted") %></span>
                        <span><i class="bi bi-trophy"></i> <%# Eval("badgesEarned") %></span>
                    </div>
                    <div class="ad-student-management-card-footer">
                        <asp:LinkButton ID="lnkViewDetails" runat="server" CssClass="sb-btn sb-btn-light sb-btn-xs"
                            CommandName="ViewStudent" CommandArgument='<%# Eval("studentId") %>'>
                            <i class="bi bi-eye"></i> <%= T("View Details", "Lihat Butiran") %>
                        </asp:LinkButton>
                        <a href='<%# ResolveUrl("~/Admin/StudentDetails.aspx?id=" + Eval("studentId")) %>' class="sb-btn sb-btn-primary sb-btn-xs" style="margin-left:6px;">
                            <i class="bi bi-gear"></i> <%= T("Manage", "Urus") %>
                        </a>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>

<%-- EMPTY STATE --%>
<asp:Panel ID="pnlEmpty" runat="server">
    <div class="ad-student-management-empty">
        <div class="ad-student-management-empty-ico"><i class="bi bi-mortarboard-fill"></i></div>
        <div class="ad-student-management-empty-msg"><%= T("No students found.", "Tiada pelajar ditemui.") %></div>
        <div class="ad-student-management-empty-sub"><%= T("Try adjusting your search or filters.", "Cuba laraskan carian atau penapis anda.") %></div>
    </div>
</asp:Panel>

<%-- ══ STUDENT DETAIL MODAL ══ --%>
<asp:Panel ID="pnlModal" runat="server" Visible="false" CssClass="ad-student-management-modal-wrap">
<div class="sb-modal-overlay active" style="display:flex;margin-left:0;">
    <div class="sb-modal" style="max-width:560px;max-height:90vh;overflow-y:auto;">
        <%-- Modal gradient header --%>
        <div style="background:linear-gradient(135deg,#6366F1,#818CF8);padding:var(--space-xl);color:#fff;text-align:center;border-radius:var(--border-radius-xl) var(--border-radius-xl) 0 0;">
            <div style="width:72px;height:72px;border-radius:50%;margin:0 auto var(--space-sm);display:flex;align-items:center;justify-content:center;font-size:1.75rem;font-weight:800;background:rgba(255,255,255,.2);border:3px solid rgba(255,255,255,.4);">
                <asp:Literal ID="litMInitials" runat="server" />
            </div>
            <div style="font-family:var(--font-primary);font-size:1.25rem;font-weight:800;"><asp:Literal ID="litMName" runat="server" /></div>
            <div style="font-size:.875rem;opacity:.8;">@<asp:Literal ID="litMUsername" runat="server" /></div>
        </div>
        <%-- Stats row --%>
        <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:var(--space-xs);padding:var(--space-md);background:var(--color-surface-alt);text-align:center;">
            <div><div style="font-family:var(--font-primary);font-size:1.125rem;font-weight:800;color:var(--color-text);"><asp:Literal ID="litMLessons" runat="server" Text="0" /></div><div style="font-size:.6875rem;color:var(--color-text-muted);font-weight:600;"><%= T("Lessons", "Pelajaran") %></div></div>
            <div><div style="font-family:var(--font-primary);font-size:1.125rem;font-weight:800;color:var(--color-text);"><asp:Literal ID="litMXP" runat="server" Text="0" /></div><div style="font-size:.6875rem;color:var(--color-text-muted);font-weight:600;">XP</div></div>
            <div><div style="font-family:var(--font-primary);font-size:1.125rem;font-weight:800;color:var(--color-text);"><asp:Literal ID="litMQuizzes" runat="server" Text="0" /></div><div style="font-size:.6875rem;color:var(--color-text-muted);font-weight:600;"><%= T("Quizzes", "Kuiz") %></div></div>
            <div><div style="font-family:var(--font-primary);font-size:1.125rem;font-weight:800;color:var(--color-text);"><asp:Literal ID="litMBadges" runat="server" Text="0" /></div><div style="font-size:.6875rem;color:var(--color-text-muted);font-weight:600;"><%= T("Badges", "Lencana") %></div></div>
        </div>
        <%-- Body fields --%>
        <div style="padding:var(--space-lg);">
            <div style="margin-bottom:var(--space-md);"><div style="font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;"><%= T("Email", "E-mel") %></div><div style="font-size:.9375rem;font-weight:600;color:var(--color-text);"><asp:Literal ID="litMEmail" runat="server" Text="-" /></div></div>
            <div style="margin-bottom:var(--space-md);"><div style="font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;"><%= T("Phone", "Telefon") %></div><div style="font-size:.9375rem;font-weight:600;color:var(--color-text);"><asp:Literal ID="litMPhone" runat="server" Text="-" /></div></div>
            <div style="margin-bottom:var(--space-md);"><div style="font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;"><%= T("Level", "Tahap") %></div><div style="font-size:.9375rem;font-weight:600;color:var(--color-text);"><asp:Literal ID="litMLevel" runat="server" Text="-" /></div></div>
            <div style="margin-bottom:var(--space-md);"><div style="font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;"><%= T("Personality", "Personaliti") %></div><div style="font-size:.9375rem;font-weight:600;color:var(--color-text);"><asp:Literal ID="litMPersonality" runat="server" Text="-" /></div></div>
            <div style="margin-bottom:var(--space-md);"><div style="font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;"><%= T("Language", "Bahasa") %></div><div style="font-size:.9375rem;font-weight:600;color:var(--color-text);"><asp:Literal ID="litMLangVal" runat="server" Text="-" /></div></div>
            <div style="margin-bottom:var(--space-md);"><div style="font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;"><%= T("Status", "Status") %></div><div style="font-size:.9375rem;font-weight:600;"><asp:Literal ID="litMStatus" runat="server" Text="-" /></div></div>
            <%-- XP Progress --%>
            <div style="margin-bottom:var(--space-md);">
                <div style="font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:4px;"><%= T("XP Progress", "Kemajuan XP") %></div>
                <div style="height:8px;background:#F1F5F9;border-radius:99px;overflow:hidden;"><div style="height:100%;border-radius:99px;background:linear-gradient(90deg,#6366F1,#818CF8);width:<%= litMXPPct.Text %>%;"></div></div>
            </div>
        </div>
        <%-- Footer --%>
        <div class="sb-modal-footer">
            <asp:Button ID="btnCloseModal" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnCloseModal_Click" />
        </div>
    </div>
</div>
</asp:Panel>
<asp:Literal ID="litMXPPct" runat="server" Text="0" Visible="false" />

<%-- ADD STUDENT MODAL --%>
<div id="addStudentOverlay" style="display:none;position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,.5);z-index:2000;align-items:center;justify-content:center;padding:20px;">
<div style="background:#fff;border-radius:20px;width:100%;max-width:580px;max-height:90vh;overflow-y:auto;box-shadow:0 25px 60px rgba(0,0,0,.2);animation:ad-student-management-modalIn .3s ease;">
<div style="padding:24px 28px;border-bottom:1px solid #F1F5F9;display:flex;align-items:center;justify-content:space-between;">
    <div><div style="font-family:var(--font-primary);font-size:1.1rem;font-weight:800;display:flex;align-items:center;gap:8px;"><i class="bi bi-person-plus-fill" style="color:#2563EB;"></i> <%= T("Add New Student","Tambah Pelajar Baharu") %></div><div style="font-size:.8rem;color:#64748B;margin-top:2px;"><%= T("Create a new student account.","Cipta akaun pelajar baharu.") %></div></div>
    <button onclick="closeAddStudent()" style="width:36px;height:36px;border:none;background:#F1F5F9;border-radius:10px;cursor:pointer;display:flex;align-items:center;justify-content:center;"><i class="bi bi-x-lg"></i></button>
</div>
<div style="padding:24px 28px;">
<div class="ad-student-management-add-grid">
<div class="ad-student-management-add-field"><label class="ad-student-management-add-label"><%= T("Full Name *","Nama Penuh *") %></label><input id="s_name" class="ad-student-management-add-input" type="text" /><div class="ad-student-management-add-err" id="e_name">Required</div></div>
<div class="ad-student-management-add-field"><label class="ad-student-management-add-label"><%= T("Username *","Nama Pengguna *") %></label><input id="s_username" class="ad-student-management-add-input" type="text" /><div class="ad-student-management-add-err" id="e_username">Required</div></div>
<div class="ad-student-management-add-field"><label class="ad-student-management-add-label"><%= T("Email *","E-mel *") %></label><input id="s_email" class="ad-student-management-add-input" type="email" /><div class="ad-student-management-add-err" id="e_email">Required</div></div>
<div class="ad-student-management-add-field"><label class="ad-student-management-add-label"><%= T("Phone *","Telefon *") %></label><input id="s_phone" class="ad-student-management-add-input" type="text" /><div class="ad-student-management-add-err" id="e_phone">Required</div></div>
<div class="ad-student-management-add-field"><label class="ad-student-management-add-label"><%= T("Password *","Kata Laluan *") %></label><input id="s_pw" class="ad-student-management-add-input" type="password" /><div class="ad-student-management-add-err" id="e_pw"><%= T("Password must be at least 8 characters.","Kata laluan mestilah sekurang-kurangnya 8 aksara.") %></div></div>
<div class="ad-student-management-add-field"><label class="ad-student-management-add-label"><%= T("Confirm Password *","Sahkan Kata Laluan *") %></label><input id="s_pw2" class="ad-student-management-add-input" type="password" /><div class="ad-student-management-add-err" id="e_pw2">Passwords do not match</div></div>
<div class="ad-student-management-add-field"><label class="ad-student-management-add-label"><%= T("Language","Bahasa") %></label><select id="s_lang" class="ad-student-management-add-input"><option value="EN">English</option><option value="BM">Bahasa Melayu</option></select></div>
<div class="ad-student-management-add-field"><label class="ad-student-management-add-label"><%= T("Nickname","Nama Panggilan") %></label><input id="s_nickname" class="ad-student-management-add-input" type="text" placeholder="<%= T("Optional - auto-generated if empty","Pilihan - dijana automatik jika kosong") %>" /></div>
</div>
<div style="display:flex;gap:10px;justify-content:flex-end;margin-top:20px;padding-top:16px;border-top:1px solid #F1F5F9;">
<button type="button" onclick="closeAddStudent()" style="padding:10px 22px;border-radius:10px;border:1.5px solid #E2E8F0;background:#fff;font-weight:600;cursor:pointer;"><%= T("Cancel","Batal") %></button>
<button type="button" onclick="submitAddStudent()" style="padding:10px 26px;border-radius:10px;border:none;background:linear-gradient(135deg,#1D4ED8,#3B82F6);color:#fff;font-weight:700;cursor:pointer;box-shadow:0 4px 14px rgba(37,99,235,.3);"><i class="bi bi-person-plus-fill"></i> <%= T("Create Student","Cipta Pelajar") %></button>
</div>
</div></div></div>

<script>
function openAddStudent(){var o=document.getElementById('addStudentOverlay');o.style.display='flex';}
function closeAddStudent(){document.getElementById('addStudentOverlay').style.display='none';}
function submitAddStudent(){
    var n=document.getElementById('s_name').value.trim(),u=document.getElementById('s_username').value.trim(),e=document.getElementById('s_email').value.trim(),ph=document.getElementById('s_phone').value.trim(),pw=document.getElementById('s_pw').value,pw2=document.getElementById('s_pw2').value;
    var ok=true;
    ['e_name','e_username','e_email','e_phone','e_pw','e_pw2'].forEach(function(id){var el=document.getElementById(id);if(el)el.style.display='none';});
    document.querySelectorAll('#addStudentOverlay .ad-student-management-add-input').forEach(function(el){el.classList.remove('error');});
    if(!n){document.getElementById('e_name').style.display='block';document.getElementById('s_name').classList.add('error');ok=false;}
    if(!u){document.getElementById('e_username').style.display='block';document.getElementById('s_username').classList.add('error');ok=false;}
    if(!e||e.indexOf('@')<0){document.getElementById('e_email').style.display='block';document.getElementById('s_email').classList.add('error');ok=false;}
    if(!ph){document.getElementById('e_phone').style.display='block';document.getElementById('s_phone').classList.add('error');ok=false;}
    if(pw.length<8){document.getElementById('e_pw').style.display='block';document.getElementById('s_pw').classList.add('error');ok=false;}
    if(pw!==pw2){document.getElementById('e_pw2').style.display='block';document.getElementById('s_pw2').classList.add('error');ok=false;}
    if(!ok)return;
    var lang=document.getElementById('s_lang').value;
    var nickname=document.getElementById('s_nickname').value.trim();
    closeAddStudent();
    Swal.fire({
        title:'<%= T("Create Student Account?","Cipta Akaun Pelajar?") %>',
        text:'<%= T("Are you sure you want to create this student account?","Adakah anda pasti ingin mencipta akaun pelajar ini?") %>',
        icon:'question',showCancelButton:true,
        confirmButtonText:'<i class="bi bi-person-plus-fill"></i> <%= T("Create","Cipta") %>',
        cancelButtonText:'<%= T("Cancel","Batal") %>',
        confirmButtonColor:'#2563EB',
        reverseButtons:true
    }).then(function(r){
        if(!r.isConfirmed){openAddStudent();return;}
        var fd=new FormData();fd.append('name',n);fd.append('username',u);fd.append('email',e);fd.append('password',pw);fd.append('phone',ph);fd.append('lang',lang);fd.append('nickname',nickname);
        fetch(window.location.pathname + (window.location.pathname.indexOf('.aspx') === -1 ? '.aspx' : '') + '?handler=StudentCRUD&action=add',{method:'POST',body:fd})
        .then(function(r){return r.json();})
        .then(function(d){
            if(d.success){
                var copyBtnHtml = '<button type="button" id="swalCopyBtn" style="padding:3px 10px;border-radius:6px;border:1px solid #DBEAFE;background:#EFF6FF;color:#2563EB;font-size:.7rem;font-weight:700;cursor:pointer;margin-left:6px;"><i class="bi bi-clipboard"></i> Copy</button>';
                var successHtml = '<div style="text-align:left;font-size:.88rem;line-height:1.7;color:#334155;">' +
                    '<p style="margin-bottom:12px;color:#475569;"><%= T("The new student account has been created successfully.","Akaun pelajar baharu telah berjaya dicipta.") %></p>' +
                    '<div style="background:#F8FAFC;border-radius:10px;padding:14px 16px;margin-bottom:14px;border:1px solid #E2E8F0;">' +
                    '<div style="font-size:.7rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:#94A3B8;margin-bottom:8px;"><%= T("Student Details","Butiran Pelajar") %></div>' +
                    '<div><strong><%= T("Student ID","ID Pelajar") %>:</strong> ' + d.studentId + '</div>' +
                    '<div><strong><%= T("User ID","ID Pengguna") %>:</strong> ' + d.userId + '</div>' +
                    '<div><strong><%= T("Username","Nama Pengguna") %>:</strong> ' + d.username + '</div>' +
                    '<div><strong><%= T("Full Name","Nama Penuh") %>:</strong> ' + d.name + '</div>' +
                    '<div><strong><%= T("Parent Code","Kod Ibu Bapa") %>:</strong> <span id="swalParentCode" style="font-weight:800;color:#2563EB;font-size:1rem;">' + d.parentCode + '</span> ' + copyBtnHtml + '</div></div>' +
                    '<div style="background:#EFF6FF;border-radius:10px;padding:12px 14px;border:1px solid #BFDBFE;display:flex;gap:8px;align-items:flex-start;">' +
                    '<i class="bi bi-info-circle-fill" style="color:#2563EB;margin-top:2px;flex-shrink:0;"></i>' +
                    '<div style="font-size:.8rem;color:#1E40AF;"><strong><%= T("Parent Code","Kod Ibu Bapa") %></strong><br/><%= T("Please provide this Parent Code to the student parent. The parent will use this code to link their account inside ScienceBuddy.","Sila berikan Kod Ibu Bapa ini kepada ibu bapa pelajar. Ibu bapa akan menggunakan kod ini untuk menghubungkan akaun mereka di dalam ScienceBuddy.") %></div>' +
                    '</div></div>';
                Swal.fire({
                    icon:'success',
                    title:'<%= T("Student Created Successfully","Pelajar Berjaya Dicipta") %>',
                    html:successHtml,
                    confirmButtonText:'<%= T("Done","Selesai") %>',
                    confirmButtonColor:'#2563EB',
                    allowOutsideClick:false,
                    width:520,
                    didOpen:function(){
                        var btn=document.getElementById('swalCopyBtn');
                        if(btn){btn.addEventListener('click',function(){
                            navigator.clipboard.writeText(d.parentCode).then(function(){
                                btn.innerHTML='<i class="bi bi-check-lg"></i> Copied';
                                setTimeout(function(){btn.innerHTML='<i class="bi bi-clipboard"></i> Copy';},2000);
                            });
                        });}
                    }
                }).then(function(){
                    document.getElementById('s_name').value='';document.getElementById('s_username').value='';document.getElementById('s_email').value='';document.getElementById('s_phone').value='';document.getElementById('s_pw').value='';document.getElementById('s_pw2').value='';document.getElementById('s_nickname').value='';
                    __doPostBack('<%= btnSearch.UniqueID %>','');
                });
            } else {
                openAddStudent();
                Swal.fire({icon:'error',title:'<%= T("Error","Ralat") %>',text:d.msg,confirmButtonColor:'#DC2626'});
            }
        }).catch(function(err){openAddStudent();Swal.fire({icon:'error',title:'<%= T("Network Error","Ralat Rangkaian") %>',text:'<%= T("Please try again.","Sila cuba lagi.") %>',confirmButtonColor:'#DC2626'});});
    });
}
</script>

</asp:Content>
