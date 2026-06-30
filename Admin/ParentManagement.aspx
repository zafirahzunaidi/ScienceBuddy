<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ParentManagement.aspx.cs"
    Inherits="ScienceBuddy.Admin.ParentManagement" MasterPageFile="~/Site.Master"
    Title="Parent Management" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root { --pm-accent:#0891B2; --pm-accent-light:#ECFEFF; --pm-teal:#14B8A6; --pm-orange:#F97316; --pm-blue:#3B82F6; --pm-mint:#34D399; }

.pm-header { display:flex; align-items:center; justify-content:space-between; gap:var(--space-lg); margin-bottom:var(--space-xl); flex-wrap:wrap; }
.pm-header-title { font-family:var(--font-primary); font-size:1.75rem; font-weight:800; color:var(--color-text); display:flex; align-items:center; gap:var(--space-sm); margin-bottom:var(--space-xs); }
.pm-header-sub { font-size:.9375rem; color:var(--color-text-secondary); max-width:500px; line-height:1.5; }
.pm-header-badge { display:inline-flex; align-items:center; gap:4px; background:var(--pm-accent-light); color:var(--pm-accent); font-size:.75rem; font-weight:700; padding:4px 12px; border-radius:var(--border-radius-full); margin-top:var(--space-sm); }
.pm-header-icon { width:72px; height:72px; border-radius:var(--border-radius-xl); background:linear-gradient(135deg,var(--pm-accent),var(--pm-teal)); display:flex; align-items:center; justify-content:center; font-size:1.75rem; color:#fff; box-shadow:0 8px 24px rgba(8,145,178,.25); flex-shrink:0; }

.pm-insights { display:grid; grid-template-columns:repeat(4,1fr); gap:var(--space-md); margin-bottom:var(--space-xl); }
.pm-insight { border-radius:var(--border-radius-xl); padding:var(--space-lg); color:#fff; display:flex; flex-direction:column; gap:var(--space-sm); transition:transform .25s,box-shadow .25s; position:relative; overflow:hidden; }
.pm-insight:hover { transform:translateY(-4px); box-shadow:var(--shadow-lg); }
.pm-insight::after { content:''; position:absolute; width:100px; height:100px; border-radius:50%; background:rgba(255,255,255,.08); top:-25px; right:-25px; pointer-events:none; }
.pm-insight.gi-total { background:linear-gradient(135deg,#0891B2,#22D3EE); }
.pm-insight.gi-linked { background:linear-gradient(135deg,#14B8A6,#5EEAD4); }
.pm-insight.gi-discuss { background:linear-gradient(135deg,#F97316,#FB923C); }
.pm-insight.gi-active { background:linear-gradient(135deg,#3B82F6,#60A5FA); }
.pm-insight-ico { font-size:1.5rem; opacity:.9; }
.pm-insight-val { font-family:var(--font-primary); font-size:2rem; font-weight:800; line-height:1; }
.pm-insight-lbl { font-size:.8125rem; opacity:.85; font-weight:600; }

.pm-search { background:var(--color-white); border-radius:var(--border-radius-xl); border:1.5px solid var(--border-color); box-shadow:var(--shadow-md); padding:var(--space-lg) var(--space-xl); display:flex; align-items:center; gap:var(--space-md); flex-wrap:wrap; margin-bottom:var(--space-xl); transition:box-shadow .2s; }
.pm-search:focus-within { box-shadow:0 8px 32px rgba(8,145,178,.1); }
.pm-search .sb-input { flex:1; min-width:180px; max-width:300px; }
.pm-search .sb-select { max-width:160px; }

.pm-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:var(--space-lg); margin-bottom:var(--space-xl); }
.pm-card { background:var(--color-white); border-radius:var(--border-radius-xl); border:1.5px solid var(--border-color); box-shadow:var(--shadow-sm); padding:var(--space-xl) var(--space-lg); display:flex; flex-direction:column; align-items:center; text-align:center; transition:transform .25s ease,box-shadow .25s ease; animation:pm-fadeIn .4s ease both; }
.pm-card:nth-child(2){animation-delay:.05s;}.pm-card:nth-child(3){animation-delay:.1s;}.pm-card:nth-child(4){animation-delay:.15s;}.pm-card:nth-child(5){animation-delay:.2s;}.pm-card:nth-child(6){animation-delay:.25s;}
.pm-card:hover { transform:translateY(-5px); box-shadow:0 12px 32px rgba(8,145,178,.12); }
.pm-card:hover .pm-avatar { transform:scale(1.08); }
@keyframes pm-fadeIn { from{opacity:0;transform:translateY(12px);} to{opacity:1;transform:translateY(0);} }
.pm-avatar { width:60px; height:60px; border-radius:50%; display:flex; align-items:center; justify-content:center; color:#fff; font-size:1.25rem; font-weight:800; margin-bottom:var(--space-md); position:relative; transition:transform .25s ease; }
.pm-avatar-dot { position:absolute; bottom:2px; right:2px; width:13px; height:13px; border-radius:50%; border:2.5px solid #fff; }
.pm-avatar-dot.active { background:#10B981; box-shadow:0 0 6px rgba(16,185,129,.5); }
.pm-avatar-dot.inactive { background:#94A3B8; }
.pm-name { font-family:var(--font-primary); font-size:1rem; font-weight:700; color:var(--color-text); margin-bottom:2px; }
.pm-username { font-size:.8125rem; color:var(--color-text-muted); margin-bottom:var(--space-sm); }
.pm-pills { display:flex; flex-wrap:wrap; gap:4px; justify-content:center; margin-bottom:var(--space-md); }
.pm-pill { font-size:.6875rem; font-weight:700; padding:3px 9px; border-radius:var(--border-radius-full); transition:transform .15s; }
.pm-pill:hover { transform:scale(1.06); }
.pm-pill-status { background:#ECFDF5; color:#059669; }
.pm-pill-status.blocked { background:#FEE2E2; color:#DC2626; }
.pm-pill-lang { background:#EFF6FF; color:#2563EB; }
.pm-pill-children { background:#FEF3C7; color:#B45309; }
.pm-meta { font-size:.75rem; color:var(--color-text-muted); display:flex; gap:var(--space-md); justify-content:center; margin-bottom:var(--space-md); }
.pm-meta span { display:flex; align-items:center; gap:3px; }
.pm-card-actions { display:flex; gap:var(--space-sm); }
.pm-card-actions .sb-btn { transition:all .2s; }
.pm-card-actions .sb-btn:hover { transform:translateY(-1px); box-shadow:var(--shadow-sm); }

.pm-empty { display:flex; flex-direction:column; align-items:center; justify-content:center; text-align:center; padding:var(--space-3xl); }
.pm-empty-ico { font-size:3.5rem; margin-bottom:var(--space-lg); opacity:.4; color:var(--pm-accent); }
.pm-empty-msg { font-size:1.0625rem; font-weight:700; color:var(--color-text-secondary); }
.pm-empty-sub { font-size:.875rem; color:var(--color-text-muted); margin-top:4px; }

/* Modal styles */
.pm-modal-hdr { background:linear-gradient(135deg,var(--pm-accent),var(--pm-teal)); padding:var(--space-xl); color:#fff; text-align:center; border-radius:var(--border-radius-xl) var(--border-radius-xl) 0 0; }
.pm-modal-avatar { width:80px; height:80px; border-radius:50%; margin:0 auto var(--space-md); display:flex; align-items:center; justify-content:center; font-size:1.75rem; font-weight:800; color:#fff; background:rgba(255,255,255,.2); border:3px solid rgba(255,255,255,.4); }
.pm-modal-name { font-family:var(--font-primary); font-size:1.25rem; font-weight:800; }
.pm-modal-user { font-size:.875rem; opacity:.8; }
.pm-modal-stats { display:grid; grid-template-columns:repeat(3,1fr); gap:var(--space-sm); padding:var(--space-lg); background:var(--color-surface-alt); }
.pm-modal-stat { text-align:center; }
.pm-modal-stat-val { font-family:var(--font-primary); font-size:1.25rem; font-weight:800; color:var(--color-text); }
.pm-modal-stat-lbl { font-size:.6875rem; font-weight:600; color:var(--color-text-muted); text-transform:uppercase; letter-spacing:.5px; }
.pm-modal-body { padding:var(--space-lg); }
.pm-modal-field { margin-bottom:var(--space-md); }
.pm-modal-label { font-size:.6875rem; font-weight:700; text-transform:uppercase; letter-spacing:.5px; color:var(--color-text-muted); margin-bottom:2px; }
.pm-modal-value { font-size:.9375rem; font-weight:600; color:var(--color-text); }
/* Children modal */
.pm-child-card { display:flex; align-items:center; gap:var(--space-md); padding:var(--space-md); border-radius:var(--border-radius-lg); border:1.5px solid var(--border-color); margin-bottom:var(--space-sm); transition:background .15s; }
.pm-child-card:hover { background:var(--color-surface-alt); }
.pm-child-avatar { width:44px; height:44px; border-radius:50%; display:flex; align-items:center; justify-content:center; color:#fff; font-size:.875rem; font-weight:700; flex-shrink:0; }
.pm-child-info { flex:1; min-width:0; }
.pm-child-name { font-weight:700; font-size:.875rem; color:var(--color-text); }
.pm-child-meta { font-size:.75rem; color:var(--color-text-muted); display:flex; gap:var(--space-md); margin-top:2px; }
.pm-child-xp-bar { height:5px; background:#F1F5F9; border-radius:99px; overflow:hidden; margin-top:4px; max-width:120px; }
.pm-child-xp-fill { height:100%; border-radius:99px; background:linear-gradient(90deg,var(--pm-accent),var(--pm-teal)); }

@media(max-width:1279px) { .pm-grid { grid-template-columns:repeat(2,1fr); } .pm-insights { grid-template-columns:repeat(2,1fr); } }
@media(max-width:767px) { .pm-header { flex-direction:column; align-items:flex-start; } .pm-header-icon { display:none; } .pm-grid { grid-template-columns:1fr; } .pm-insights { grid-template-columns:1fr 1fr; } .pm-search { flex-direction:column; align-items:stretch; } .pm-search .sb-input,.pm-search .sb-select { max-width:100%; } .pm-header-title { font-size:1.375rem; } .pm-modal-stats { grid-template-columns:1fr; } }
@media(max-width:479px) { .pm-insights { grid-template-columns:1fr; } }
</style>
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
        <a href="<%: ResolveUrl("~/Admin/ParentManagement.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-person-heart item-icon"></i><span class="item-label">Parents</span></a>
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

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%= T("Parent Management", "Pengurusan Ibu Bapa") %></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<div class="pm-header">
    <div>
        <h1 class="pm-header-title"><i class="bi bi-person-heart" style="color:var(--pm-accent);"></i> <%= T("Parent Management", "Pengurusan Ibu Bapa") %></h1>
        <p class="pm-header-sub"><%= T("Manage parent accounts, monitor engagement and parent-child communication.", "Urus akaun ibu bapa, pantau penglibatan dan komunikasi ibu bapa-anak.") %></p>
        <span class="pm-header-badge"><i class="bi bi-house-heart-fill"></i> <%= T("Family Directory", "Direktori Keluarga") %></span>
    </div>
    <div class="pm-header-icon"><i class="bi bi-people-fill"></i></div>
</div>

<div class="pm-insights">
    <div class="pm-insight gi-total"><div class="pm-insight-ico"><i class="bi bi-person-heart"></i></div><div class="pm-insight-val"><asp:Literal ID="litTotal" runat="server" Text="0" /></div><div class="pm-insight-lbl"><%= T("Total Parents", "Jumlah Ibu Bapa") %></div></div>
    <div class="pm-insight gi-linked"><div class="pm-insight-ico"><i class="bi bi-link-45deg"></i></div><div class="pm-insight-val"><asp:Literal ID="litLinked" runat="server" Text="0" /></div><div class="pm-insight-lbl"><%= T("Linked Children", "Anak yang Dihubungkan") %></div></div>
    <div class="pm-insight gi-discuss"><div class="pm-insight-ico"><i class="bi bi-chat-dots-fill"></i></div><div class="pm-insight-val"><asp:Literal ID="litDiscuss" runat="server" Text="0" /></div><div class="pm-insight-lbl"><%= T("Forum Discussions", "Perbincangan Forum") %></div></div>
    <div class="pm-insight gi-active"><div class="pm-insight-ico"><i class="bi bi-lightning-fill"></i></div><div class="pm-insight-val"><asp:Literal ID="litActive" runat="server" Text="0" /></div><div class="pm-insight-lbl"><%= T("Active Parents", "Ibu Bapa Aktif") %></div></div>
</div>

<div class="pm-search">
    <i class="bi bi-search text-muted"></i>
    <asp:TextBox ID="txtSearch" runat="server" CssClass="sb-input sb-input-sm" AutoPostBack="false" />
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
        <asp:ListItem Value="children_desc">Most Children</asp:ListItem>
    </asp:DropDownList>
    <asp:Button ID="btnSearch" runat="server" CssClass="sb-btn sb-btn-primary sb-btn-sm" OnClick="btnSearch_Click" />
    <asp:Button ID="btnReset" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnReset_Click" />
</div>

<asp:Panel ID="pnlParents" runat="server" Visible="false">
    <div class="pm-grid">
        <asp:Repeater ID="rptParents" runat="server" OnItemCommand="rptParents_ItemCommand">
            <ItemTemplate>
                <div class="pm-card">
                    <div class="pm-avatar" style='<%# Eval("gradient") %>'><%# HttpUtility.HtmlEncode(Eval("initials")) %><span class='pm-avatar-dot <%# Eval("dotClass") %>'></span></div>
                    <div class="pm-name"><%# HttpUtility.HtmlEncode(Eval("displayName")) %></div>
                    <div class="pm-username">@<%# HttpUtility.HtmlEncode(Eval("username")) %></div>
                    <div class="pm-pills">
                        <span class='pm-pill pm-pill-status <%# Eval("statusPillClass") %>'><%# HttpUtility.HtmlEncode(Eval("statusLabel")) %></span>
                        <span class="pm-pill pm-pill-lang"><%# HttpUtility.HtmlEncode(Eval("language")) %></span>
                        <span class="pm-pill pm-pill-children"><i class="bi bi-people-fill"></i> <%# Eval("childCount") %></span>
                    </div>
                    <div class="pm-meta">
                        <span><i class="bi bi-telephone"></i> <%# HttpUtility.HtmlEncode(Eval("phone")) %></span>
                    </div>
                    <div class="pm-card-actions">
                        <asp:LinkButton ID="lnkProfile" runat="server" CssClass="sb-btn sb-btn-light sb-btn-xs"
                            CommandName="ViewProfile" CommandArgument='<%# Eval("parentId") %>'
                            data-tooltip="View parent profile">
                            <i class="bi bi-eye"></i> <%= T("View Profile", "Lihat Profil") %>
                        </asp:LinkButton>
                        <asp:LinkButton ID="lnkChildren" runat="server" CssClass="sb-btn sb-btn-light sb-btn-xs"
                            CommandName="ViewChildren" CommandArgument='<%# Eval("parentId") %>'
                            data-tooltip="View linked children">
                            <i class="bi bi-link-45deg"></i> <%= T("Children", "Anak") %>
                        </asp:LinkButton>
                        <a href='<%# ResolveUrl("~/Admin/ParentDetails.aspx?id=" + Eval("parentId")) %>' class="sb-btn sb-btn-primary sb-btn-xs">
                            <i class="bi bi-gear"></i> <%= T("Manage", "Urus") %>
                        </a>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>

<asp:Panel ID="pnlEmpty" runat="server">
    <div class="pm-empty">
        <div class="pm-empty-ico"><i class="bi bi-person-heart"></i></div>
        <div class="pm-empty-msg"><%= T("No parents found.", "Tiada ibu bapa ditemui.") %></div>
        <div class="pm-empty-sub"><%= T("Try adjusting your search or filters.", "Cuba laraskan carian atau penapis anda.") %></div>
    </div>
</asp:Panel>

<%-- ══ PROFILE MODAL ══ --%>
<asp:Panel ID="pnlProfileModal" runat="server" Visible="false">
    <div class="sb-modal-overlay active" style="display:flex;">
        <div class="sb-modal" style="max-width:520px;">
            <div class="pm-modal-hdr">
                <div class="pm-modal-avatar"><asp:Literal ID="litModalInitials" runat="server" /></div>
                <div class="pm-modal-name"><asp:Literal ID="litModalName" runat="server" /></div>
                <div class="pm-modal-user">@<asp:Literal ID="litModalUsername" runat="server" /></div>
            </div>
            <div class="pm-modal-stats">
                <div class="pm-modal-stat"><div class="pm-modal-stat-val"><asp:Literal ID="litModalChildren" runat="server" Text="0" /></div><div class="pm-modal-stat-lbl"><%= T("Children", "Anak") %></div></div>
                <div class="pm-modal-stat"><div class="pm-modal-stat-val"><asp:Literal ID="litModalForums" runat="server" Text="0" /></div><div class="pm-modal-stat-lbl"><%= T("Discussions", "Perbincangan") %></div></div>
                <div class="pm-modal-stat"><div class="pm-modal-stat-val"><asp:Literal ID="litModalLang" runat="server" Text="-" /></div><div class="pm-modal-stat-lbl"><%= T("Language", "Bahasa") %></div></div>
            </div>
            <div class="pm-modal-body">
                <div class="pm-modal-field"><div class="pm-modal-label"><%= T("Email", "E-mel") %></div><div class="pm-modal-value"><asp:Literal ID="litModalEmail" runat="server" Text="-" /></div></div>
                <div class="pm-modal-field"><div class="pm-modal-label"><%= T("Phone", "Telefon") %></div><div class="pm-modal-value"><asp:Literal ID="litModalPhone" runat="server" Text="-" /></div></div>
                <div class="pm-modal-field"><div class="pm-modal-label"><%= T("Status", "Status") %></div><div class="pm-modal-value"><asp:Literal ID="litModalStatus" runat="server" Text="-" /></div></div>
            </div>
            <div class="sb-modal-footer">
                <asp:Button ID="btnCloseProfile" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnCloseModal_Click" />
            </div>
        </div>
    </div>
</asp:Panel>

<%-- ══ CHILDREN MODAL ══ --%>
<asp:Panel ID="pnlChildrenModal" runat="server" Visible="false">
    <div class="sb-modal-overlay active" style="display:flex;">
        <div class="sb-modal" style="max-width:560px;">
            <div class="sb-modal-header">
                <span class="sb-modal-title"><i class="bi bi-link-45deg"></i> <%= T("Linked Children", "Anak yang Dihubungkan") %></span>
                <asp:LinkButton ID="lnkCloseChildren" runat="server" CssClass="sb-modal-close" OnClick="btnCloseModal_Click"><i class="bi bi-x-lg"></i></asp:LinkButton>
            </div>
            <div class="sb-modal-body">
                <asp:Panel ID="pnlChildrenList" runat="server" Visible="false">
                    <asp:Repeater ID="rptChildren" runat="server">
                        <ItemTemplate>
                            <div class="pm-child-card">
                                <div class="pm-child-avatar" style='<%# Eval("gradient") %>'><%# HttpUtility.HtmlEncode(Eval("initials")) %></div>
                                <div class="pm-child-info">
                                    <div class="pm-child-name"><%# HttpUtility.HtmlEncode(Eval("name")) %></div>
                                    <div class="pm-child-meta">
                                        <span><i class="bi bi-bar-chart"></i> <%# HttpUtility.HtmlEncode(Eval("level")) %></span>
                                        <span><i class="bi bi-lightning"></i> <%# Eval("xp") %> XP</span>
                                    </div>
                                    <div class="pm-child-xp-bar"><div class="pm-child-xp-fill" style='width:<%# Eval("xpPct") %>%'></div></div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </asp:Panel>
                <asp:Panel ID="pnlNoChildren" runat="server">
                    <div class="pm-empty" style="padding:var(--space-xl);">
                        <div class="pm-empty-ico" style="font-size:2rem;"><i class="bi bi-person-x"></i></div>
                        <div class="pm-empty-msg"><%= T("No linked children.", "Tiada anak dipautkan.") %></div>
                    </div>
                </asp:Panel>
            </div>
        </div>
    </div>
</asp:Panel>

</asp:Content>
