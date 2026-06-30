<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TeacherManagement.aspx.cs"
    Inherits="ScienceBuddy.Admin.TeacherManagement" MasterPageFile="~/Site.Master"
    Title="Teacher Management" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--tm-accent:#059669;--tm-accent-light:#ECFDF5;--tm-emerald:#10B981;--tm-lime:#84CC16;--tm-teal:#14B8A6;}
.tm-header{display:flex;align-items:center;justify-content:space-between;gap:var(--space-lg);margin-bottom:var(--space-xl);flex-wrap:wrap;}
.tm-header-title{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;color:var(--color-text);display:flex;align-items:center;gap:var(--space-sm);margin-bottom:var(--space-xs);}
.tm-header-sub{font-size:.9375rem;color:var(--color-text-secondary);max-width:500px;line-height:1.5;}
.tm-header-badge{display:inline-flex;align-items:center;gap:4px;background:var(--tm-accent-light);color:var(--tm-accent);font-size:.75rem;font-weight:700;padding:4px 12px;border-radius:var(--border-radius-full);margin-top:var(--space-sm);}
.tm-header-icon{width:72px;height:72px;border-radius:var(--border-radius-xl);background:linear-gradient(135deg,var(--tm-accent),var(--tm-emerald));display:flex;align-items:center;justify-content:center;font-size:1.75rem;color:#fff;box-shadow:0 8px 24px rgba(5,150,105,.25);flex-shrink:0;}
.tm-insights{display:grid;grid-template-columns:repeat(4,1fr);gap:var(--space-md);margin-bottom:var(--space-xl);}
.tm-insight{border-radius:var(--border-radius-xl);padding:var(--space-lg);color:#fff;display:flex;flex-direction:column;gap:var(--space-sm);transition:transform .25s,box-shadow .25s;position:relative;overflow:hidden;}
.tm-insight:hover{transform:translateY(-4px);box-shadow:var(--shadow-lg);}
.tm-insight::after{content:'';position:absolute;width:100px;height:100px;border-radius:50%;background:rgba(255,255,255,.08);top:-25px;right:-25px;pointer-events:none;}
.tm-insight.gi-total{background:linear-gradient(135deg,#059669,#34D399);}.tm-insight.gi-active{background:linear-gradient(135deg,#0891B2,#22D3EE);}.tm-insight.gi-lessons{background:linear-gradient(135deg,#7C3AED,#A78BFA);}.tm-insight.gi-materials{background:linear-gradient(135deg,#D97706,#FBBF24);}
.tm-insight-ico{font-size:1.5rem;opacity:.9;}.tm-insight-val{font-family:var(--font-primary);font-size:2rem;font-weight:800;line-height:1;}.tm-insight-lbl{font-size:.8125rem;opacity:.85;font-weight:600;}
.tm-search{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-md);padding:var(--space-lg) var(--space-xl);display:flex;align-items:center;gap:var(--space-md);flex-wrap:wrap;margin-bottom:var(--space-xl);transition:box-shadow .2s;}
.tm-search:focus-within{box-shadow:0 8px 32px rgba(5,150,105,.1);}.tm-search .sb-input{flex:1;min-width:180px;max-width:300px;}.tm-search .sb-select{max-width:160px;}
.tm-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:var(--space-lg);margin-bottom:var(--space-xl);}
.tm-card{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);padding:var(--space-xl) var(--space-lg);display:flex;flex-direction:column;align-items:center;text-align:center;transition:transform .25s ease,box-shadow .25s ease;animation:tm-fadeIn .4s ease both;}
.tm-card:nth-child(2){animation-delay:.05s;}.tm-card:nth-child(3){animation-delay:.1s;}.tm-card:nth-child(4){animation-delay:.15s;}.tm-card:nth-child(5){animation-delay:.2s;}.tm-card:nth-child(6){animation-delay:.25s;}
.tm-card:hover{transform:translateY(-5px);box-shadow:0 12px 32px rgba(5,150,105,.12);}
.tm-card:hover .tm-avatar{transform:scale(1.08);}
@keyframes tm-fadeIn{from{opacity:0;transform:translateY(12px);}to{opacity:1;transform:translateY(0);}}
.tm-avatar{width:60px;height:60px;border-radius:50%;display:flex;align-items:center;justify-content:center;color:#fff;font-size:1.25rem;font-weight:800;margin-bottom:var(--space-md);position:relative;transition:transform .25s;}
.tm-avatar-dot{position:absolute;bottom:2px;right:2px;width:13px;height:13px;border-radius:50%;border:2.5px solid #fff;}
.tm-avatar-dot.certified{background:#10B981;box-shadow:0 0 6px rgba(16,185,129,.5);}.tm-avatar-dot.pending{background:#F59E0B;}.tm-avatar-dot.rejected{background:#EF4444;}
.tm-name{font-family:var(--font-primary);font-size:1rem;font-weight:700;color:var(--color-text);margin-bottom:2px;}
.tm-username{font-size:.8125rem;color:var(--color-text-muted);margin-bottom:var(--space-sm);}
.tm-pills{display:flex;flex-wrap:wrap;gap:4px;justify-content:center;margin-bottom:var(--space-md);}
.tm-pill{font-size:.6875rem;font-weight:700;padding:3px 9px;border-radius:var(--border-radius-full);transition:transform .15s;}.tm-pill:hover{transform:scale(1.06);}
.tm-pill-certified{background:#ECFDF5;color:#059669;}.tm-pill-pending{background:#FEF3C7;color:#B45309;}.tm-pill-rejected{background:#FEE2E2;color:#DC2626;}.tm-pill-lang{background:#EFF6FF;color:#2563EB;}
.tm-meta{font-size:.75rem;color:var(--color-text-muted);display:flex;gap:var(--space-md);justify-content:center;margin-bottom:var(--space-md);flex-wrap:wrap;}
.tm-meta span{display:flex;align-items:center;gap:3px;}
.tm-card-actions{display:flex;gap:var(--space-sm);}.tm-card-actions .sb-btn{transition:all .2s;}.tm-card-actions .sb-btn:hover{transform:translateY(-1px);box-shadow:var(--shadow-sm);}
.tm-empty{display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;padding:var(--space-3xl);}
.tm-empty-ico{font-size:3.5rem;margin-bottom:var(--space-lg);opacity:.4;color:var(--tm-accent);}.tm-empty-msg{font-size:1.0625rem;font-weight:700;color:var(--color-text-secondary);}.tm-empty-sub{font-size:.875rem;color:var(--color-text-muted);margin-top:4px;}
/* Modal fix — don't block sidebar */
.tm-modal-wrap .sb-modal-overlay{left:var(--sidebar-width);}.sidebar-collapsed .tm-modal-wrap .sb-modal-overlay{left:var(--sidebar-collapsed);}
@media(max-width:767px){.tm-modal-wrap .sb-modal-overlay{left:0;}}
/* Modal internals */
.tm-modal-hdr{background:linear-gradient(135deg,var(--tm-accent),var(--tm-emerald));padding:var(--space-xl);color:#fff;text-align:center;border-radius:var(--border-radius-xl) var(--border-radius-xl) 0 0;}
.tm-modal-avatar{width:72px;height:72px;border-radius:50%;margin:0 auto var(--space-sm);display:flex;align-items:center;justify-content:center;font-size:1.75rem;font-weight:800;background:rgba(255,255,255,.2);border:3px solid rgba(255,255,255,.4);}
.tm-modal-name{font-family:var(--font-primary);font-size:1.25rem;font-weight:800;}.tm-modal-user{font-size:.875rem;opacity:.8;}
.tm-modal-stats{display:grid;grid-template-columns:repeat(4,1fr);gap:var(--space-xs);padding:var(--space-md);background:var(--color-surface-alt);text-align:center;}
.tm-modal-stat-val{font-family:var(--font-primary);font-size:1.125rem;font-weight:800;color:var(--color-text);}.tm-modal-stat-lbl{font-size:.6875rem;font-weight:600;color:var(--color-text-muted);text-transform:uppercase;letter-spacing:.5px;}
.tm-modal-body{padding:var(--space-lg);}.tm-modal-field{margin-bottom:var(--space-md);}.tm-modal-label{font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;}.tm-modal-value{font-size:.9375rem;font-weight:600;color:var(--color-text);}
/* Content modal */
.tm-content-item{display:flex;align-items:center;gap:var(--space-md);padding:var(--space-md);border-radius:var(--border-radius-lg);border:1.5px solid var(--border-color);margin-bottom:var(--space-sm);transition:background .15s;}.tm-content-item:hover{background:var(--color-surface-alt);}
.tm-content-type{font-size:.6875rem;font-weight:700;padding:3px 8px;border-radius:var(--border-radius-full);}.tm-content-title{font-weight:700;font-size:.875rem;color:var(--color-text);flex:1;}.tm-content-date{font-size:.75rem;color:var(--color-text-muted);}
@media(max-width:1279px){.tm-grid{grid-template-columns:repeat(2,1fr);}.tm-insights{grid-template-columns:repeat(2,1fr);}}
@media(max-width:767px){.tm-header{flex-direction:column;align-items:flex-start;}.tm-header-icon{display:none;}.tm-grid{grid-template-columns:1fr;}.tm-insights{grid-template-columns:1fr 1fr;}.tm-search{flex-direction:column;align-items:stretch;}.tm-search .sb-input,.tm-search .sb-select{max-width:100%;}.tm-header-title{font-size:1.375rem;}.tm-modal-stats{grid-template-columns:repeat(2,1fr);}}
@media(max-width:479px){.tm-insights{grid-template-columns:1fr;}}

/* ═══ UX ENHANCEMENTS ═══ */

/* Modal animations */
.tm-modal-wrap .sb-modal-overlay { animation:tm-overlayIn .25s ease both; }
.tm-modal-wrap .sb-modal { animation:tm-modalIn .3s cubic-bezier(.34,1.56,.64,1) both; }
@keyframes tm-overlayIn { from{opacity:0;} to{opacity:1;} }
@keyframes tm-modalIn { from{opacity:0;transform:scale(.92) translateY(16px);} to{opacity:1;transform:scale(1) translateY(0);} }

/* Modal content fade-in */
.tm-modal-hdr,.tm-modal-stats,.tm-modal-body,.sb-modal-header,.sb-modal-body { animation:tm-contentFade .35s ease .15s both; }
@keyframes tm-contentFade { from{opacity:0;transform:translateY(8px);} to{opacity:1;transform:translateY(0);} }

/* Button enhancements */
.sb-btn { transition:all .2s ease; }
.sb-btn:hover { transform:translateY(-1px) scale(1.03); }
.sb-btn:active { transform:translateY(0) scale(.97); transition-duration:.1s; }

/* Card lift refinement */
.tm-card { will-change:transform,box-shadow; }

/* Pill hover glow */
.tm-pill:hover { box-shadow:0 2px 8px rgba(0,0,0,.08); }

/* Search button loading state (applied via JS) */
.tm-btn-loading { pointer-events:none; opacity:.7; }
.tm-btn-loading::after { content:''; display:inline-block; width:12px; height:12px; border:2px solid rgba(255,255,255,.4); border-top-color:#fff; border-radius:50%; animation:tm-spin .6s linear infinite; margin-left:6px; vertical-align:middle; }
@keyframes tm-spin { to{transform:rotate(360deg);} }

/* Sidebar item smooth transition */
.sb-sidebar-item { transition:background .2s ease,color .2s ease,transform .15s ease; }
.sb-sidebar-item:hover { transform:translateX(2px); }

/* Smooth scroll inside modals */
.sb-modal { scroll-behavior:smooth; }

/* Content items stagger */
.tm-content-item { animation:tm-fadeIn .3s ease both; }
.tm-content-item:nth-child(2){animation-delay:.05s;}.tm-content-item:nth-child(3){animation-delay:.1s;}.tm-content-item:nth-child(4){animation-delay:.15s;}.tm-content-item:nth-child(5){animation-delay:.2s;}

/* Reduced motion */
@media(prefers-reduced-motion:reduce) {
    .tm-card,.tm-insight,.tm-modal-wrap .sb-modal,.tm-modal-wrap .sb-modal-overlay,
    .tm-content-item,.sb-btn,.sb-sidebar-item,.tm-avatar,.tm-pill {
        animation:none !important; transition-duration:.01ms !important;
    }
}
</style>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label">Main</div>
        <a href="<%: ResolveUrl("~/Admin/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label">Dashboard</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">User Management</div>
        <a href="<%: ResolveUrl("~/Admin/StudentManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-people item-icon"></i><span class="item-label">Students</span></a>
        <a href="<%: ResolveUrl("~/Admin/ParentManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-heart item-icon"></i><span class="item-label">Parents</span></a>
        <a href="<%: ResolveUrl("~/Admin/TeacherManagement.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-person-badge item-icon"></i><span class="item-label">Teachers</span></a>
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
        <a href="<%: ResolveUrl("~/Admin/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span></a>
        <a href="<%: ResolveUrl("~/Admin/Profile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item" onclick="return confirm('Are you sure you want to sign out?');"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%= T("Teacher Management", "Pengurusan Guru") %></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<div class="tm-header">
    <div>
        <h1 class="tm-header-title"><i class="bi bi-person-badge-fill" style="color:var(--tm-accent);"></i> <%= T("Teacher Management", "Pengurusan Guru") %></h1>
        <p class="tm-header-sub"><%= T("Manage teacher accounts, monitor teaching activity and review educator performance.", "Urus akaun guru, pantau aktiviti pengajaran dan semak prestasi pendidik.") %></p>
        <span class="tm-header-badge"><i class="bi bi-mortarboard-fill"></i> <%= T("Educator Directory", "Direktori Pendidik") %></span>
    </div>
    <div class="tm-header-icon"><i class="bi bi-person-workspace"></i></div>
</div>

<div class="tm-insights">
    <div class="tm-insight gi-total"><div class="tm-insight-ico"><i class="bi bi-person-badge"></i></div><div class="tm-insight-val"><asp:Literal ID="litTotal" runat="server" Text="0" /></div><div class="tm-insight-lbl"><%= T("Total Teachers", "Jumlah Guru") %></div></div>
    <div class="tm-insight gi-active"><div class="tm-insight-ico"><i class="bi bi-shield-check"></i></div><div class="tm-insight-val"><asp:Literal ID="litActive" runat="server" Text="0" /></div><div class="tm-insight-lbl"><%= T("Certified Teachers", "Guru Bertauliah") %></div></div>
    <div class="tm-insight gi-lessons"><div class="tm-insight-ico"><i class="bi bi-journal-text"></i></div><div class="tm-insight-val"><asp:Literal ID="litLessons" runat="server" Text="0" /></div><div class="tm-insight-lbl"><%= T("Materials Created", "Bahan Dicipta") %></div></div>
    <div class="tm-insight gi-materials"><div class="tm-insight-ico"><i class="bi bi-patch-question"></i></div><div class="tm-insight-val"><asp:Literal ID="litQuizzes" runat="server" Text="0" /></div><div class="tm-insight-lbl"><%= T("Quizzes Created", "Kuiz Dicipta") %></div></div>
</div>

<div class="tm-search">
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
    <div class="tm-grid">
        <asp:Repeater ID="rptTeachers" runat="server" OnItemCommand="rptTeachers_ItemCommand">
            <ItemTemplate>
                <div class="tm-card">
                    <div class="tm-avatar" style='<%# Eval("gradient") %>'><%# HttpUtility.HtmlEncode(Eval("initials")) %><span class='tm-avatar-dot <%# Eval("dotClass") %>'></span></div>
                    <div class="tm-name"><%# HttpUtility.HtmlEncode(Eval("displayName")) %></div>
                    <div class="tm-username">@<%# HttpUtility.HtmlEncode(Eval("username")) %></div>
                    <div class="tm-pills">
                        <span class='tm-pill <%# Eval("statusPillClass") %>'><%# HttpUtility.HtmlEncode(Eval("statusLabel")) %></span>
                        <span class="tm-pill tm-pill-lang"><%# HttpUtility.HtmlEncode(Eval("language")) %></span>
                    </div>
                    <div class="tm-meta">
                        <span><i class="bi bi-telephone"></i> <%# HttpUtility.HtmlEncode(Eval("phone")) %></span>
                        <span><i class="bi bi-file-earmark-text"></i> <%# Eval("materialsCount") %></span>
                        <span><i class="bi bi-patch-question"></i> <%# Eval("quizzesCount") %></span>
                    </div>
                    <div class="tm-card-actions">
                        <asp:LinkButton ID="lnkProfile" runat="server" CssClass="sb-btn sb-btn-light sb-btn-xs" CommandName="ViewProfile" CommandArgument='<%# Eval("teacherId") %>' ToolTip="View Profile">
                            <i class="bi bi-eye"></i> <%= T("View Profile", "Lihat Profil") %>
                        </asp:LinkButton>
                        <asp:LinkButton ID="lnkContent" runat="server" CssClass="sb-btn sb-btn-light sb-btn-xs" CommandName="ViewContent" CommandArgument='<%# Eval("teacherId") %>' ToolTip="Submitted Content">
                            <i class="bi bi-collection"></i> <%= T("Content", "Kandungan") %>
                        </asp:LinkButton>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>

<asp:Panel ID="pnlEmpty" runat="server">
    <div class="tm-empty">
        <div class="tm-empty-ico"><i class="bi bi-person-badge"></i></div>
        <div class="tm-empty-msg"><%= T("No teachers found.", "Tiada guru ditemui.") %></div>
        <div class="tm-empty-sub"><%= T("Try adjusting your search or filters.", "Cuba laraskan carian atau penapis anda.") %></div>
    </div>
</asp:Panel>

<%-- ══ PROFILE MODAL ══ --%>
<asp:Panel ID="pnlProfileModal" runat="server" Visible="false" CssClass="tm-modal-wrap">
<div class="sb-modal-overlay active" style="display:flex;">
    <div class="sb-modal" style="max-width:540px;max-height:90vh;overflow-y:auto;">
        <div class="tm-modal-hdr">
            <div class="tm-modal-avatar"><asp:Literal ID="litMInitials" runat="server" /></div>
            <div class="tm-modal-name"><asp:Literal ID="litMName" runat="server" /></div>
            <div class="tm-modal-user">@<asp:Literal ID="litMUsername" runat="server" /></div>
        </div>
        <div class="tm-modal-stats">
            <div><div class="tm-modal-stat-val"><asp:Literal ID="litMMaterials" runat="server" Text="0" /></div><div class="tm-modal-stat-lbl"><%= T("Materials", "Bahan") %></div></div>
            <div><div class="tm-modal-stat-val"><asp:Literal ID="litMQuizzes" runat="server" Text="0" /></div><div class="tm-modal-stat-lbl"><%= T("Quizzes", "Kuiz") %></div></div>
            <div><div class="tm-modal-stat-val"><asp:Literal ID="litMSessions" runat="server" Text="0" /></div><div class="tm-modal-stat-lbl"><%= T("Sessions", "Sesi") %></div></div>
            <div><div class="tm-modal-stat-val"><asp:Literal ID="litMPending" runat="server" Text="0" /></div><div class="tm-modal-stat-lbl"><%= T("Pending", "Menunggu") %></div></div>
        </div>
        <div class="tm-modal-body">
            <div class="tm-modal-field"><div class="tm-modal-label"><%= T("Email", "E-mel") %></div><div class="tm-modal-value"><asp:Literal ID="litMEmail" runat="server" Text="-" /></div></div>
            <div class="tm-modal-field"><div class="tm-modal-label"><%= T("Phone", "Telefon") %></div><div class="tm-modal-value"><asp:Literal ID="litMPhone" runat="server" Text="-" /></div></div>
            <div class="tm-modal-field"><div class="tm-modal-label"><%= T("Qualification", "Kelayakan") %></div><div class="tm-modal-value"><asp:Literal ID="litMQual" runat="server" Text="-" /></div></div>
            <div class="tm-modal-field"><div class="tm-modal-label"><%= T("Status", "Status") %></div><div class="tm-modal-value"><asp:Literal ID="litMStatus" runat="server" Text="-" /></div></div>
            <div class="tm-modal-field"><div class="tm-modal-label"><%= T("Language", "Bahasa") %></div><div class="tm-modal-value"><asp:Literal ID="litMLang" runat="server" Text="-" /></div></div>
            <div class="tm-modal-field"><div class="tm-modal-label"><%= T("Approved Date", "Tarikh Diluluskan") %></div><div class="tm-modal-value"><asp:Literal ID="litMDate" runat="server" Text="-" /></div></div>
        </div>
        <div class="sb-modal-footer">
            <asp:Button ID="btnCloseProfile" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnCloseModal_Click" />
        </div>
    </div>
</div>
</asp:Panel>

<%-- ══ CONTENT MODAL ══ --%>
<asp:Panel ID="pnlContentModal" runat="server" Visible="false" CssClass="tm-modal-wrap">
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
                        <div class="tm-content-item">
                            <span class='tm-content-type <%# Eval("typeCls") %>'><%# HttpUtility.HtmlEncode(Eval("contentType")) %></span>
                            <span class="tm-content-title"><%# HttpUtility.HtmlEncode(Eval("title")) %></span>
                            <span class="tm-content-date"><%# Eval("dateStr") %></span>
                            <span class='sb-badge <%# Eval("statusCls") %>'><%# HttpUtility.HtmlEncode(Eval("statusLabel")) %></span>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </asp:Panel>
            <asp:Panel ID="pnlNoContent" runat="server">
                <div class="tm-empty" style="padding:var(--space-xl);">
                    <div class="tm-empty-ico" style="font-size:2rem;"><i class="bi bi-file-earmark-x"></i></div>
                    <div class="tm-empty-msg"><%= T("No submitted content.", "Tiada kandungan dihantar.") %></div>
                </div>
            </asp:Panel>
        </div>
    </div>
</div>
</asp:Panel>

</asp:Content>
