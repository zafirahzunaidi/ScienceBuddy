<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TeacherManagement.aspx.cs"
    Inherits="ScienceBuddy.Admin.TeacherManagement" MasterPageFile="~/Site.Master"
    Title="Teacher Management" ValidateRequest="false" EnableEventValidation="false" %>

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
        <a href="<%: ResolveUrl("~/Admin/TeacherManagement.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-person-badge item-icon"></i><span class="item-label">Teachers</span></a>
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
        <a href="<%: ResolveUrl("~/Admin/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span></a>
        <a href="<%: ResolveUrl("~/Admin/Profile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a>
        <a href="javascript:;" class="sb-sidebar-item" onclick="showSignOutModal()"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%= T("Teacher Management", "Pengurusan Guru") %></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<div class="ad-teacher-management-header">
    <div>
        <h1 class="ad-teacher-management-header-title"><i class="bi bi-person-badge-fill" style="color:var(--ad-teacher-management-accent);"></i> <%= T("Teacher Management", "Pengurusan Guru") %></h1>
        <p class="ad-teacher-management-header-sub"><%= T("Manage teacher accounts, monitor teaching activity and review educator performance.", "Urus akaun guru, pantau aktiviti pengajaran dan semak prestasi pendidik.") %></p>
        <span class="ad-teacher-management-header-badge"><i class="bi bi-mortarboard-fill"></i> <%= T("Educator Directory", "Direktori Pendidik") %></span>
    </div>
    <div style="display:flex;align-items:center;gap:var(--space-md);">
        <div class="ad-teacher-management-header-icon"><i class="bi bi-person-workspace"></i></div>
        <a href="javascript:;" onclick="openAddTeacher()" style="display:inline-flex;align-items:center;gap:8px;padding:12px 24px;background:linear-gradient(135deg,#047857,#059669,#10B981);color:#fff;border-radius:12px;font-weight:700;font-size:.9rem;text-decoration:none;box-shadow:0 6px 20px rgba(5,150,105,.35);transition:all .25s;">
            <i class="bi bi-person-plus-fill"></i> <%= T("+ Add Teacher", "+ Tambah Guru") %>
        </a>
    </div>
</div>

<div class="ad-teacher-management-insights">
    <div class="ad-teacher-management-insight ad-teacher-management-gi-total"><div class="ad-teacher-management-insight-ico"><i class="bi bi-person-badge"></i></div><div class="ad-teacher-management-insight-val"><asp:Literal ID="litTotal" runat="server" Text="0" /></div><div class="ad-teacher-management-insight-lbl"><%= T("Total Teachers", "Jumlah Guru") %></div></div>
    <div class="ad-teacher-management-insight ad-teacher-management-gi-active"><div class="ad-teacher-management-insight-ico"><i class="bi bi-shield-check"></i></div><div class="ad-teacher-management-insight-val"><asp:Literal ID="litActive" runat="server" Text="0" /></div><div class="ad-teacher-management-insight-lbl"><%= T("Certified Teachers", "Guru Bertauliah") %></div></div>
    <div class="ad-teacher-management-insight ad-teacher-management-gi-lessons"><div class="ad-teacher-management-insight-ico"><i class="bi bi-journal-text"></i></div><div class="ad-teacher-management-insight-val"><asp:Literal ID="litLessons" runat="server" Text="0" /></div><div class="ad-teacher-management-insight-lbl"><%= T("Materials Created", "Bahan Dicipta") %></div></div>
    <div class="ad-teacher-management-insight ad-teacher-management-gi-materials"><div class="ad-teacher-management-insight-ico"><i class="bi bi-patch-question"></i></div><div class="ad-teacher-management-insight-val"><asp:Literal ID="litQuizzes" runat="server" Text="0" /></div><div class="ad-teacher-management-insight-lbl"><%= T("Quizzes Created", "Kuiz Dicipta") %></div></div>
</div>

<div class="ad-teacher-management-search">
    <i class="bi bi-search text-muted"></i>
    <asp:TextBox ID="txtSearch" runat="server" CssClass="sb-input sb-input-sm" AutoPostBack="false" />
    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="sb-select sb-input-sm" AutoPostBack="false">
        <asp:ListItem Value="">All Status</asp:ListItem>
        <asp:ListItem Value="Certified">Certified</asp:ListItem>
        <asp:ListItem Value="Pending">Pending</asp:ListItem>
        <asp:ListItem Value="Not Certified">Not Certified</asp:ListItem>
    </asp:DropDownList>
    <asp:DropDownList ID="ddlLang" runat="server" CssClass="sb-select sb-input-sm" AutoPostBack="false">
        <asp:ListItem Value="">All Languages</asp:ListItem>
        <asp:ListItem Value="EN">English</asp:ListItem>
        <asp:ListItem Value="BM">Bahasa Melayu</asp:ListItem>
    </asp:DropDownList>
    <asp:DropDownList ID="ddlSort" runat="server" CssClass="sb-select sb-input-sm" AutoPostBack="false">
        <asp:ListItem Value="name">A-Z</asp:ListItem>
        <asp:ListItem Value="name_desc">Z-A</asp:ListItem>
    </asp:DropDownList>
    <asp:Button ID="btnSearch" runat="server" CssClass="sb-btn sb-btn-primary sb-btn-sm" OnClick="btnSearch_Click" />
    <asp:Button ID="btnReset" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnReset_Click" />
</div>

<asp:Panel ID="pnlTeachers" runat="server" Visible="false">
    <div class="ad-teacher-management-grid">
        <asp:Repeater ID="rptTeachers" runat="server" OnItemCommand="rptTeachers_ItemCommand">
            <ItemTemplate>
                <div class="ad-teacher-management-card">
                    <div class="ad-teacher-management-avatar" style='<%# Eval("gradient") %>'><%# HttpUtility.HtmlEncode(Eval("initials")) %><span class='ad-teacher-management-avatar-dot <%# Eval("dotClass") %>'></span></div>
                    <div class="ad-teacher-management-name"><%# HttpUtility.HtmlEncode(Eval("displayName")) %></div>
                    <div class="ad-teacher-management-username">@<%# HttpUtility.HtmlEncode(Eval("username")) %></div>
                    <div class="ad-teacher-management-pills">
                        <span class='ad-teacher-management-pill <%# Eval("statusPillClass") %>'><%# HttpUtility.HtmlEncode(Eval("statusLabel")) %></span>
                        <span class="ad-teacher-management-pill ad-teacher-management-pill-lang"><%# HttpUtility.HtmlEncode(Eval("language")) %></span>
                    </div>
                    <div class="ad-teacher-management-meta">
                        <span><i class="bi bi-telephone"></i> <%# HttpUtility.HtmlEncode(Eval("phone")) %></span>
                        <span><i class="bi bi-file-earmark-text"></i> <%# Eval("materialsCount") %></span>
                        <span><i class="bi bi-patch-question"></i> <%# Eval("quizzesCount") %></span>
                    </div>
                    <div class="ad-teacher-management-card-actions">
                        <asp:LinkButton ID="lnkProfile" runat="server" CssClass="sb-btn sb-btn-light sb-btn-xs" CommandName="ViewProfile" CommandArgument='<%# Eval("teacherId") %>' ToolTip="View Profile">
                            <i class="bi bi-eye"></i> <%= T("View Profile", "Lihat Profil") %>
                        </asp:LinkButton>
                        <asp:LinkButton ID="lnkContent" runat="server" CssClass="sb-btn sb-btn-light sb-btn-xs" CommandName="ViewContent" CommandArgument='<%# Eval("teacherId") %>' ToolTip="Submitted Content">
                            <i class="bi bi-collection"></i> <%= T("Content", "Kandungan") %>
                        </asp:LinkButton>
                        <a href='<%# ResolveUrl("~/Admin/TeacherDetails.aspx?id=" + Eval("teacherId")) %>' class="sb-btn sb-btn-primary sb-btn-xs">
                            <i class="bi bi-gear"></i> <%= T("Manage", "Urus") %>
                        </a>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>

<asp:Panel ID="pnlEmpty" runat="server">
    <div class="ad-teacher-management-empty">
        <div class="ad-teacher-management-empty-ico"><i class="bi bi-person-badge"></i></div>
        <div class="ad-teacher-management-empty-msg"><%= T("No teachers found.", "Tiada guru ditemui.") %></div>
        <div class="ad-teacher-management-empty-sub"><%= T("Try adjusting your search or filters.", "Cuba laraskan carian atau penapis anda.") %></div>
    </div>
</asp:Panel>

<%-- ══ PROFILE MODAL ══ --%>
<asp:Panel ID="pnlProfileModal" runat="server" Visible="false" CssClass="ad-teacher-management-modal-wrap">
<div class="sb-modal-overlay active" style="display:flex;">
    <div class="sb-modal" style="max-width:540px;max-height:90vh;overflow-y:auto;">
        <div class="ad-teacher-management-modal-hdr">
            <div class="ad-teacher-management-modal-avatar"><asp:Literal ID="litMInitials" runat="server" /></div>
            <div class="ad-teacher-management-modal-name"><asp:Literal ID="litMName" runat="server" /></div>
            <div class="ad-teacher-management-modal-user">@<asp:Literal ID="litMUsername" runat="server" /></div>
        </div>
        <div class="ad-teacher-management-modal-stats">
            <div><div class="ad-teacher-management-modal-stat-val"><asp:Literal ID="litMMaterials" runat="server" Text="0" /></div><div class="ad-teacher-management-modal-stat-lbl"><%= T("Materials", "Bahan") %></div></div>
            <div><div class="ad-teacher-management-modal-stat-val"><asp:Literal ID="litMQuizzes" runat="server" Text="0" /></div><div class="ad-teacher-management-modal-stat-lbl"><%= T("Quizzes", "Kuiz") %></div></div>
            <div><div class="ad-teacher-management-modal-stat-val"><asp:Literal ID="litMSessions" runat="server" Text="0" /></div><div class="ad-teacher-management-modal-stat-lbl"><%= T("Sessions", "Sesi") %></div></div>
            <div><div class="ad-teacher-management-modal-stat-val"><asp:Literal ID="litMPending" runat="server" Text="0" /></div><div class="ad-teacher-management-modal-stat-lbl"><%= T("Pending", "Menunggu") %></div></div>
        </div>
        <div class="ad-teacher-management-modal-body">
            <div class="ad-teacher-management-modal-field"><div class="ad-teacher-management-modal-label"><%= T("Email", "E-mel") %></div><div class="ad-teacher-management-modal-value"><asp:Literal ID="litMEmail" runat="server" Text="-" /></div></div>
            <div class="ad-teacher-management-modal-field"><div class="ad-teacher-management-modal-label"><%= T("Phone", "Telefon") %></div><div class="ad-teacher-management-modal-value"><asp:Literal ID="litMPhone" runat="server" Text="-" /></div></div>
            <div class="ad-teacher-management-modal-field"><div class="ad-teacher-management-modal-label"><%= T("Qualification", "Kelayakan") %></div><div class="ad-teacher-management-modal-value"><asp:Literal ID="litMQual" runat="server" Text="-" /></div></div>
            <div class="ad-teacher-management-modal-field"><div class="ad-teacher-management-modal-label"><%= T("Status", "Status") %></div><div class="ad-teacher-management-modal-value"><asp:Literal ID="litMStatus" runat="server" Text="-" /></div></div>
            <div class="ad-teacher-management-modal-field"><div class="ad-teacher-management-modal-label"><%= T("Language", "Bahasa") %></div><div class="ad-teacher-management-modal-value"><asp:Literal ID="litMLang" runat="server" Text="-" /></div></div>
            <div class="ad-teacher-management-modal-field"><div class="ad-teacher-management-modal-label"><%= T("Approved Date", "Tarikh Diluluskan") %></div><div class="ad-teacher-management-modal-value"><asp:Literal ID="litMDate" runat="server" Text="-" /></div></div>
        </div>
        <div class="sb-modal-footer">
            <asp:Button ID="btnCloseProfile" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnCloseModal_Click" />
        </div>
    </div>
</div>
</asp:Panel>

<%-- ══ CONTENT MODAL ══ --%>
<asp:Panel ID="pnlContentModal" runat="server" Visible="false" CssClass="ad-teacher-management-modal-wrap">
<div class="sb-modal-overlay active" style="display:flex;">
    <div class="sb-modal" style="max-width:580px;max-height:90vh;overflow-y:auto;">
        <div class="sb-modal-header">
            <span class="sb-modal-title"><i class="bi bi-collection"></i> <%= T("Submitted Content", "Kandungan Dihantar") %></span>
            <asp:LinkButton ID="lnkCloseContent" runat="server" CssClass="sb-modal-close" OnClick="btnCloseModal_Click"><i class="bi bi-x-lg"></i></asp:LinkButton>
        </div>
        <div class="sb-modal-body">
            <asp:Panel ID="pnlContentList" runat="server" Visible="false">
                <asp:Repeater ID="rptContent" runat="server">
                    <ItemTemplate>
                        <div class="ad-teacher-management-content-item">
                            <span class='ad-teacher-management-content-type <%# Eval("typeCls") %>'><%# HttpUtility.HtmlEncode(Eval("contentType")) %></span>
                            <span class="ad-teacher-management-content-title"><%# HttpUtility.HtmlEncode(Eval("title")) %></span>
                            <span class="ad-teacher-management-content-date"><%# Eval("dateStr") %></span>
                            <span class='sb-badge <%# Eval("statusCls") %>'><%# HttpUtility.HtmlEncode(Eval("statusLabel")) %></span>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </asp:Panel>
            <asp:Panel ID="pnlNoContent" runat="server">
                <div class="ad-teacher-management-empty" style="padding:var(--space-xl);">
                    <div class="ad-teacher-management-empty-ico" style="font-size:2rem;"><i class="bi bi-file-earmark-x"></i></div>
                    <div class="ad-teacher-management-empty-msg"><%= T("No submitted content.", "Tiada kandungan dihantar.") %></div>
                </div>
            </asp:Panel>
        </div>
    </div>
</div>
</asp:Panel>

<%-- ADD TEACHER MODAL --%>
<div id="addTeacherOverlay" style="display:none;position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,.5);z-index:2000;align-items:center;justify-content:center;padding:20px;">
<div style="background:#fff;border-radius:20px;width:100%;max-width:620px;max-height:90vh;overflow-y:auto;box-shadow:0 25px 60px rgba(0,0,0,.2);animation:ad-teacher-management-modalIn .3s ease;">
<div style="padding:24px 28px;border-bottom:1px solid #F1F5F9;display:flex;align-items:center;justify-content:space-between;">
    <div><div style="font-family:var(--font-primary);font-size:1.1rem;font-weight:800;display:flex;align-items:center;gap:8px;"><i class="bi bi-person-plus-fill" style="color:#059669;"></i> <%= T("Add New Teacher","Tambah Guru Baharu") %></div><div style="font-size:.8rem;color:#64748B;margin-top:2px;"><%= T("Create a new teacher account.","Cipta akaun guru baharu.") %></div></div>
    <button type="button" onclick="closeAddTeacher()" style="width:36px;height:36px;border:none;background:#F1F5F9;border-radius:10px;cursor:pointer;display:flex;align-items:center;justify-content:center;"><i class="bi bi-x-lg"></i></button>
</div>
<div style="padding:24px 28px;">
<div class="ad-teacher-management-add-grid">
<div class="ad-teacher-management-add-field"><label class="ad-teacher-management-add-label"><%= T("Full Name *","Nama Penuh *") %></label><input id="t_name" class="ad-teacher-management-add-input" type="text" /><div class="ad-teacher-management-add-err" id="te_name"><%= T("Required","Diperlukan") %></div></div>
<div class="ad-teacher-management-add-field"><label class="ad-teacher-management-add-label"><%= T("Username *","Nama Pengguna *") %></label><input id="t_username" class="ad-teacher-management-add-input" type="text" /><div class="ad-teacher-management-add-err" id="te_username"><%= T("Required","Diperlukan") %></div></div>
<div class="ad-teacher-management-add-field"><label class="ad-teacher-management-add-label"><%= T("Email *","E-mel *") %></label><input id="t_email" class="ad-teacher-management-add-input" type="email" /><div class="ad-teacher-management-add-err" id="te_email"><%= T("Required","Diperlukan") %></div></div>
<div class="ad-teacher-management-add-field"><label class="ad-teacher-management-add-label"><%= T("Phone Number *","Nombor Telefon *") %></label><input id="t_phone" class="ad-teacher-management-add-input" type="text" /><div class="ad-teacher-management-add-err" id="te_phone"><%= T("Required","Diperlukan") %></div></div>
<div class="ad-teacher-management-add-field"><label class="ad-teacher-management-add-label"><%= T("Password *","Kata Laluan *") %></label><input id="t_pw" class="ad-teacher-management-add-input" type="password" /><div class="ad-teacher-management-add-err" id="te_pw"><%= T("Password must be at least 8 characters.","Kata laluan mestilah sekurang-kurangnya 8 aksara.") %></div></div>
<div class="ad-teacher-management-add-field"><label class="ad-teacher-management-add-label"><%= T("Confirm Password *","Sahkan Kata Laluan *") %></label><input id="t_pw2" class="ad-teacher-management-add-input" type="password" /><div class="ad-teacher-management-add-err" id="te_pw2"><%= T("Passwords do not match","Kata laluan tidak sama") %></div></div>
<div class="ad-teacher-management-add-field"><label class="ad-teacher-management-add-label"><%= T("Academic Qualification *","Kelayakan Akademik *") %></label><input id="t_qual" class="ad-teacher-management-add-input" type="text" placeholder="<%= T("e.g. B.Ed (Science)","cth. B.Pend (Sains)") %>" /><div class="ad-teacher-management-add-err" id="te_qual"><%= T("Required","Diperlukan") %></div></div>
<div class="ad-teacher-management-add-field"><label class="ad-teacher-management-add-label"><%= T("Preferred Language","Bahasa Pilihan") %></label><select id="t_lang" class="ad-teacher-management-add-input"><option value="EN">English</option><option value="BM">Bahasa Melayu</option></select></div>
</div>
<div class="ad-teacher-management-add-field" style="margin-top:12px;"><label class="ad-teacher-management-add-label"><%= T("Bio *","Bio *") %></label><textarea id="t_bio" class="ad-teacher-management-add-input" rows="3" style="resize:vertical;min-height:80px;" placeholder="<%= T("Brief description about this teacher...","Penerangan ringkas tentang guru ini...") %>"></textarea><div class="ad-teacher-management-add-err" id="te_bio"><%= T("Required","Diperlukan") %></div></div>
<div class="ad-teacher-management-add-field" style="margin-top:4px;"><label class="ad-teacher-management-add-label"><%= T("Teaching Certificate (PDF) *","Sijil Pengajaran (PDF) *") %></label><input id="t_cert" class="ad-teacher-management-add-input" type="file" accept=".pdf" style="padding:8px 12px;" /><div class="ad-teacher-management-add-err" id="te_cert"><%= T("PDF certificate is required.","Sijil PDF diperlukan.") %></div></div>
<div style="display:flex;gap:10px;justify-content:flex-end;margin-top:20px;padding-top:16px;border-top:1px solid #F1F5F9;">
<button type="button" onclick="closeAddTeacher()" style="padding:10px 22px;border-radius:10px;border:1.5px solid #E2E8F0;background:#fff;font-weight:600;cursor:pointer;"><%= T("Cancel","Batal") %></button>
<button type="button" onclick="submitAddTeacher()" style="padding:10px 26px;border-radius:10px;border:none;background:linear-gradient(135deg,#047857,#059669);color:#fff;font-weight:700;cursor:pointer;box-shadow:0 4px 14px rgba(5,150,105,.3);"><i class="bi bi-person-plus-fill"></i> <%= T("Create Teacher","Cipta Guru") %></button>
</div>
</div></div></div>

<script>
function openAddTeacher(){document.getElementById('addTeacherOverlay').style.display='flex';}
function closeAddTeacher(){document.getElementById('addTeacherOverlay').style.display='none';}
function submitAddTeacher(){
    var n=document.getElementById('t_name').value.trim(),u=document.getElementById('t_username').value.trim(),e=document.getElementById('t_email').value.trim(),ph=document.getElementById('t_phone').value.trim(),pw=document.getElementById('t_pw').value,pw2=document.getElementById('t_pw2').value,qual=document.getElementById('t_qual').value.trim(),bio=document.getElementById('t_bio').value.trim();
    var certFile=document.getElementById('t_cert').files[0];
    var ok=true;
    ['te_name','te_username','te_email','te_phone','te_pw','te_pw2','te_qual','te_bio','te_cert'].forEach(function(id){var el=document.getElementById(id);if(el)el.style.display='none';});
    document.querySelectorAll('#addTeacherOverlay .ad-teacher-management-add-input').forEach(function(el){el.classList.remove('error');});
    if(!n){document.getElementById('te_name').style.display='block';document.getElementById('t_name').classList.add('error');ok=false;}
    if(!u){document.getElementById('te_username').style.display='block';document.getElementById('t_username').classList.add('error');ok=false;}
    if(!e||e.indexOf('@')<0){document.getElementById('te_email').style.display='block';document.getElementById('t_email').classList.add('error');ok=false;}
    if(!ph){document.getElementById('te_phone').style.display='block';document.getElementById('t_phone').classList.add('error');ok=false;}
    if(pw.length<8){document.getElementById('te_pw').style.display='block';document.getElementById('t_pw').classList.add('error');ok=false;}
    if(pw!==pw2){document.getElementById('te_pw2').style.display='block';document.getElementById('t_pw2').classList.add('error');ok=false;}
    if(!qual){document.getElementById('te_qual').style.display='block';document.getElementById('t_qual').classList.add('error');ok=false;}
    if(!bio){document.getElementById('te_bio').style.display='block';document.getElementById('t_bio').classList.add('error');ok=false;}
    if(!certFile){document.getElementById('te_cert').style.display='block';document.getElementById('t_cert').classList.add('error');ok=false;}
    else if(certFile.type!=='application/pdf'&&!certFile.name.toLowerCase().endsWith('.pdf')){document.getElementById('te_cert').textContent='<%= T("Only PDF files are accepted.","Hanya fail PDF diterima.") %>';document.getElementById('te_cert').style.display='block';document.getElementById('t_cert').classList.add('error');ok=false;}
    if(!ok)return;
    var lang=document.getElementById('t_lang').value;
    closeAddTeacher();
    Swal.fire({
        title:'<%= T("Create Teacher Account?","Cipta Akaun Guru?") %>',
        text:'<%= T("Are you sure you want to create this teacher account?","Adakah anda pasti ingin mencipta akaun guru ini?") %>',
        icon:'question',showCancelButton:true,
        confirmButtonText:'<i class="bi bi-person-plus-fill"></i> <%= T("Create","Cipta") %>',
        cancelButtonText:'<%= T("Cancel","Batal") %>',
        confirmButtonColor:'#059669',reverseButtons:true
    }).then(function(r){
        if(!r.isConfirmed){openAddTeacher();return;}
        var fd=new FormData();fd.append('name',n);fd.append('username',u);fd.append('email',e);fd.append('password',pw);fd.append('phone',ph);fd.append('qualification',qual);fd.append('bio',bio);fd.append('lang',lang);fd.append('cert',certFile);
        fetch(window.location.pathname+(window.location.pathname.indexOf('.aspx')===-1?'.aspx':'')+'?handler=TeacherCRUD&action=addTeacher',{method:'POST',body:fd})
        .then(function(r){return r.json();})
        .then(function(d){
            if(d.success){
                var successHtml='<div style="text-align:left;font-size:.88rem;line-height:1.7;color:#334155;">' +
                    '<p style="margin-bottom:12px;color:#475569;"><%= T("The new teacher account has been created successfully.","Akaun guru baharu telah berjaya dicipta.") %></p>' +
                    '<div style="background:#F8FAFC;border-radius:10px;padding:14px 16px;margin-bottom:14px;border:1px solid #E2E8F0;">' +
                    '<div style="font-size:.7rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:#94A3B8;margin-bottom:8px;"><%= T("Teacher Details","Butiran Guru") %></div>' +
                    '<div><strong><%= T("Teacher ID","ID Guru") %>:</strong> '+d.teacherId+'</div>' +
                    '<div><strong><%= T("User ID","ID Pengguna") %>:</strong> '+d.userId+'</div>' +
                    '<div><strong><%= T("Username","Nama Pengguna") %>:</strong> '+d.username+'</div>' +
                    '<div><strong><%= T("Full Name","Nama Penuh") %>:</strong> '+d.name+'</div>' +
                    '<div><strong><%= T("Status","Status") %>:</strong> <span style="background:#FEF3C7;color:#92400E;padding:2px 8px;border-radius:6px;font-weight:700;font-size:.75rem;"><%= T("Pending Review","Menunggu Semakan") %></span></div>' +
                    '</div>' +
                    '<div style="background:#ECFDF5;border-radius:10px;padding:12px 14px;border:1px solid #A7F3D0;display:flex;gap:8px;align-items:flex-start;">' +
                    '<i class="bi bi-info-circle-fill" style="color:#059669;margin-top:2px;flex-shrink:0;"></i>' +
                    '<div style="font-size:.8rem;color:#065F46;"><%= T("This teacher account has been created successfully. The uploaded certificate is awaiting administrator verification before the teacher can become Certified.","Akaun guru ini telah berjaya dicipta. Sijil yang dimuat naik menunggu pengesahan pentadbir sebelum guru boleh menjadi Bertauliah.") %></div>' +
                    '</div></div>';
                Swal.fire({
                    icon:'success',
                    title:'<%= T("Teacher Created Successfully","Guru Berjaya Dicipta") %>',
                    html:successHtml,
                    confirmButtonText:'<%= T("Done","Selesai") %>',
                    confirmButtonColor:'#059669',
                    allowOutsideClick:false,
                    width:520
                }).then(function(){
                    document.getElementById('t_name').value='';document.getElementById('t_username').value='';document.getElementById('t_email').value='';document.getElementById('t_phone').value='';document.getElementById('t_pw').value='';document.getElementById('t_pw2').value='';document.getElementById('t_qual').value='';document.getElementById('t_bio').value='';document.getElementById('t_cert').value='';
                    __doPostBack('<%= btnSearch.UniqueID %>','');
                });
            } else {
                openAddTeacher();
                Swal.fire({icon:'error',title:'<%= T("Error","Ralat") %>',text:d.msg,confirmButtonColor:'#DC2626'});
            }
        }).catch(function(){openAddTeacher();Swal.fire({icon:'error',title:'<%= T("Network Error","Ralat Rangkaian") %>',text:'<%= T("Please try again.","Sila cuba lagi.") %>',confirmButtonColor:'#DC2626'});});
    });
}
</script>
</asp:Content>
