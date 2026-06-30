<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GamificationManagement.aspx.cs"
    Inherits="ScienceBuddy.Admin.GamificationManagement" MasterPageFile="~/Site.Master"
    Title="Student Performance" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--gm-accent:#D97706;--gm-gold:#F59E0B;--gm-blue:#2563EB;--gm-green:#059669;--gm-purple:#7C3AED;}
.gm-header{margin-bottom:var(--space-xl);padding-bottom:var(--space-md);border-bottom:1.5px solid var(--border-color);}
.gm-title{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;color:var(--color-text);display:flex;align-items:center;gap:var(--space-sm);margin-bottom:var(--space-xs);}
.gm-sub{font-size:.9375rem;color:var(--color-text-secondary);max-width:520px;line-height:1.5;}
.gm-stats{display:grid;grid-template-columns:repeat(4,1fr);gap:var(--space-md);margin-bottom:var(--space-xl);}
.gm-stat{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);padding:var(--space-lg);display:flex;flex-direction:column;gap:var(--space-xs);transition:transform .25s,box-shadow .25s;position:relative;overflow:hidden;}
.gm-stat:hover{transform:translateY(-3px);box-shadow:var(--shadow-md);}
.gm-stat::before{content:'';position:absolute;top:0;left:0;right:0;height:3px;}
.gm-stat.s1::before{background:linear-gradient(90deg,#D97706,#FBBF24);}.gm-stat.s2::before{background:linear-gradient(90deg,#7C3AED,#A78BFA);}.gm-stat.s3::before{background:linear-gradient(90deg,#059669,#34D399);}.gm-stat.s4::before{background:linear-gradient(90deg,#2563EB,#60A5FA);}
.gm-stat-ico{font-size:1.25rem;}.gm-stat-val{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;color:var(--color-text);}.gm-stat-lbl{font-size:.75rem;color:var(--color-text-muted);font-weight:600;}
.gm-card{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);overflow:hidden;margin-bottom:var(--space-xl);}
.gm-card-hdr{padding:var(--space-md) var(--space-lg);border-bottom:1px solid var(--border-color);font-family:var(--font-primary);font-weight:800;font-size:.9375rem;display:flex;align-items:center;gap:var(--space-sm);}
.gm-xp-card{display:flex;align-items:center;gap:var(--space-lg);padding:var(--space-lg);border-bottom:1px solid var(--border-color);transition:background .15s;}
.gm-xp-card:last-child{border-bottom:none;}
.gm-xp-card:hover{background:var(--color-surface-alt);}
.gm-xp-ico{width:48px;height:48px;border-radius:var(--border-radius);display:flex;align-items:center;justify-content:center;font-size:1.25rem;flex-shrink:0;}
.gm-xp-body{flex:1;min-width:0;}
.gm-xp-name{font-weight:700;font-size:.9375rem;color:var(--color-text);}
.gm-xp-name-bm{font-size:.8125rem;color:var(--color-text-muted);}
.gm-xp-meta{display:flex;gap:var(--space-md);margin-top:4px;font-size:.75rem;color:var(--color-text-muted);}
.gm-xp-val{font-family:var(--font-primary);font-size:1.25rem;font-weight:800;color:var(--gm-gold);white-space:nowrap;}
.gm-lb-card{display:flex;align-items:center;gap:var(--space-md);padding:var(--space-md) var(--space-lg);border-bottom:1px solid var(--border-color);}
.gm-lb-card:last-child{border-bottom:none;}
.gm-lb-rank{width:32px;height:32px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:.75rem;font-weight:800;color:#fff;flex-shrink:0;}
.gm-lb-rank.r1{background:linear-gradient(135deg,#F59E0B,#FBBF24);}.gm-lb-rank.r2{background:linear-gradient(135deg,#94A3B8,#CBD5E1);color:#1E293B;}.gm-lb-rank.r3{background:linear-gradient(135deg,#92400E,#D97706);}
.gm-lb-rank.rn{background:#F1F5F9;color:#64748B;}
.gm-lb-name{font-weight:600;font-size:.875rem;color:var(--color-text);}
.gm-lb-xp{font-family:var(--font-primary);font-weight:800;font-size:.875rem;color:var(--gm-gold);margin-left:auto;}
.gm-empty{display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;padding:var(--space-2xl);}
.gm-empty-ico{font-size:3rem;margin-bottom:var(--space-md);opacity:.35;color:var(--gm-accent);}.gm-empty-msg{font-size:1rem;font-weight:700;color:var(--color-text-secondary);}

/* Podium */
.gm-podium{display:flex;align-items:flex-end;justify-content:center;gap:var(--space-md);margin-bottom:var(--space-xl);padding-top:var(--space-lg);}
.gm-podium-item{display:flex;flex-direction:column;align-items:center;text-align:center;transition:transform .3s;}
.gm-podium-item:hover{transform:translateY(-4px);}
.gm-podium-block{border-radius:var(--border-radius-xl) var(--border-radius-xl) 0 0;display:flex;flex-direction:column;align-items:center;justify-content:flex-end;padding:var(--space-lg) var(--space-md) var(--space-md);position:relative;overflow:hidden;}
.gm-podium-block::after{content:'';position:absolute;top:0;left:0;right:0;bottom:0;background:linear-gradient(180deg,rgba(255,255,255,.15) 0%,transparent 60%);pointer-events:none;}
.gm-podium-1st .gm-podium-block{width:150px;min-height:220px;background:linear-gradient(135deg,#F59E0B,#FBBF24);box-shadow:0 8px 30px rgba(245,158,11,.35);}
.gm-podium-2nd .gm-podium-block{width:125px;min-height:160px;background:linear-gradient(135deg,#94A3B8,#CBD5E1);box-shadow:0 6px 20px rgba(148,163,184,.3);}
.gm-podium-3rd .gm-podium-block{width:125px;min-height:120px;background:linear-gradient(135deg,#92400E,#D97706);box-shadow:0 6px 20px rgba(146,64,14,.3);}
.gm-podium-medal{font-size:1.75rem;margin-bottom:6px;filter:drop-shadow(0 2px 4px rgba(0,0,0,.2));}
.gm-podium-avatar{width:52px;height:52px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:1.1rem;font-weight:800;color:#fff;border:3px solid rgba(255,255,255,.5);margin-bottom:6px;background:rgba(255,255,255,.2);}
.gm-podium-name{font-size:.8rem;font-weight:700;color:#fff;line-height:1.2;max-width:110px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;}
.gm-podium-xp{font-family:var(--font-primary);font-size:1rem;font-weight:800;color:rgba(255,255,255,.9);margin-top:4px;}
.gm-podium-label{font-size:.65rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-top:8px;}

/* Rankings (4+) */
.gm-rankings{border-top:1px solid var(--border-color);padding-top:var(--space-md);}
.gm-rank-card{display:flex;align-items:center;gap:var(--space-md);padding:10px var(--space-md);border-radius:var(--border-radius);transition:background .15s;margin-bottom:2px;}
.gm-rank-card:hover{background:var(--color-surface-alt);}
.gm-rank-num{width:28px;font-family:var(--font-primary);font-size:.8rem;font-weight:800;color:var(--color-text-muted);text-align:center;}
.gm-rank-avatar{width:36px;height:36px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:.75rem;font-weight:700;color:#fff;flex-shrink:0;}
.gm-rank-name{flex:1;font-weight:600;font-size:.875rem;color:var(--color-text);}
.gm-rank-xp{font-family:var(--font-primary);font-weight:800;font-size:.875rem;color:var(--gm-gold);}

@media(max-width:767px){.gm-podium{flex-direction:column;align-items:center;}.gm-podium-item{width:100%;}.gm-podium-block{width:100%!important;min-height:auto!important;flex-direction:row;border-radius:var(--border-radius-xl);padding:var(--space-md) var(--space-lg);gap:var(--space-md);}}
@media(max-width:1279px){.gm-stats{grid-template-columns:repeat(2,1fr);}}
@media(max-width:767px){.gm-stats{grid-template-columns:1fr 1fr;}}
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
        <a href="<%: ResolveUrl("~/Admin/ParentManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-heart item-icon"></i><span class="item-label">Parents</span></a>
        <a href="<%: ResolveUrl("~/Admin/TeacherManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-badge item-icon"></i><span class="item-label">Teachers</span></a>
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
        <a href="<%: ResolveUrl("~/Admin/GamificationManagement.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-trophy item-icon"></i><span class="item-label">Student Performance</span></a>
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
        <a href="javascript:;" class="sb-sidebar-item" onclick="showSignOutModal()"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%= T("Student Performance", "Prestasi Pelajar") %></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="gm-header">
    <h1 class="gm-title"><i class="bi bi-trophy-fill" style="color:var(--gm-gold);"></i> <%= T("Student Performance", "Prestasi Pelajar") %></h1>
    <p class="gm-sub"><%= T("Monitor XP rewards, badges, student achievements, and the ScienceBuddy reward system.", "Pantau ganjaran XP, lencana, pencapaian pelajar, dan sistem ganjaran ScienceBuddy.") %></p>
</div>

<%-- TABS --%>
<div style="display:flex;gap:4px;margin-bottom:var(--space-xl);background:var(--color-surface-alt);border-radius:var(--border-radius-lg);padding:4px;flex-wrap:wrap;">
    <asp:LinkButton ID="tabOverview" runat="server" CssClass="sb-btn sb-btn-primary sb-btn-sm" OnClick="tabOverview_Click" style="border-radius:var(--border-radius);"><i class="bi bi-grid-fill"></i> <%= T("Overview", "Gambaran") %></asp:LinkButton>
    <asp:LinkButton ID="tabXP" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="tabXP_Click" style="border-radius:var(--border-radius);"><i class="bi bi-lightning-fill"></i> <%= T("XP Rules", "Peraturan XP") %></asp:LinkButton>
    <asp:LinkButton ID="tabBadges" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="tabBadges_Click" style="border-radius:var(--border-radius);"><i class="bi bi-award-fill"></i> <%= T("Badges", "Lencana") %></asp:LinkButton>
    <asp:LinkButton ID="tabStudents" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="tabStudents_Click" style="border-radius:var(--border-radius);"><i class="bi bi-people-fill"></i> <%= T("Student Rewards", "Ganjaran Pelajar") %></asp:LinkButton>
</div>

<%-- TAB: OVERVIEW --%>
<asp:Panel ID="pnlOverview" runat="server" Visible="true">

<div class="gm-stats">
    <div class="gm-stat s1"><div class="gm-stat-ico" style="color:#D97706;"><i class="bi bi-lightning-fill"></i></div><div class="gm-stat-val"><asp:Literal ID="litRules" runat="server" Text="0" /></div><div class="gm-stat-lbl"><%= T("XP Rules", "Peraturan XP") %></div></div>
    <div class="gm-stat s2"><div class="gm-stat-ico" style="color:#7C3AED;"><i class="bi bi-star-fill"></i></div><div class="gm-stat-val"><asp:Literal ID="litTotalXP" runat="server" Text="0" /></div><div class="gm-stat-lbl"><%= T("Total XP Awarded", "Jumlah XP Dianugerah") %></div></div>
    <div class="gm-stat s3"><div class="gm-stat-ico" style="color:#059669;"><i class="bi bi-award-fill"></i></div><div class="gm-stat-val"><asp:Literal ID="litCerts" runat="server" Text="0" /></div><div class="gm-stat-lbl"><%= T("Certificates Issued", "Sijil Dikeluarkan") %></div></div>
    <div class="gm-stat s4"><div class="gm-stat-ico" style="color:#2563EB;"><i class="bi bi-people-fill"></i></div><div class="gm-stat-val"><asp:Literal ID="litActiveStudents" runat="server" Text="0" /></div><div class="gm-stat-lbl"><%= T("Active Students", "Pelajar Aktif") %></div></div>
</div>

<%-- XP RULES --%>
<div class="gm-card">
    <div class="gm-card-hdr"><i class="bi bi-lightning-fill" style="color:var(--gm-gold);"></i> <%= T("XP Action Rules", "Peraturan Tindakan XP") %></div>
    <asp:Repeater ID="rptXPActions" runat="server">
        <ItemTemplate>
            <div class="gm-xp-card">
                <div class="gm-xp-ico" style='<%# Eval("icoStyle") %>'><i class='<%# Eval("icoClass") %>'></i></div>
                <div class="gm-xp-body">
                    <div class="gm-xp-name"><%# HttpUtility.HtmlEncode(Eval("nameEN")) %></div>
                    <div class="gm-xp-name-bm"><%# HttpUtility.HtmlEncode(Eval("nameBM")) %></div>
                    <div class="gm-xp-meta"><span><i class="bi bi-people"></i> <%# Eval("earnedCount") %> <%= T("students earned", "pelajar memperoleh") %></span></div>
                </div>
                <div class="gm-xp-val">+<%# Eval("xpValue") %> XP</div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</div>

<%-- STUDENT LEADERBOARD (Podium Style) --%>
<div class="gm-card">
    <div class="gm-card-hdr"><i class="bi bi-bar-chart-fill" style="color:var(--gm-purple);"></i> <%= T("Student Leaderboard", "Papan Markah Pelajar") %></div>
    <asp:Panel ID="pnlLeaderboard" runat="server" Visible="false">
        <div style="padding:var(--space-xl);">
            <!-- PODIUM -->
            <div class="gm-podium">
                <asp:Literal ID="litPodium" runat="server" />
            </div>
            <!-- REST OF RANKINGS (4+) -->
            <asp:Panel ID="pnlRankings" runat="server" Visible="false">
                <div class="gm-rankings">
                    <asp:Repeater ID="rptLeaderboard" runat="server">
                        <ItemTemplate>
                            <div class="gm-rank-card">
                                <div class="gm-rank-num">#<%# Eval("rank") %></div>
                                <div class="gm-rank-avatar" style='background:<%# Eval("avatarBg") %>;'><%# Eval("initials") %></div>
                                <div class="gm-rank-name"><%# HttpUtility.HtmlEncode(Eval("studentName")) %></div>
                                <div class="gm-rank-xp"><%# Eval("totalXP") %> XP</div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </asp:Panel>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlNoLeaderboard" runat="server">
        <div class="gm-empty"><div class="gm-empty-ico"><i class="bi bi-bar-chart"></i></div><div class="gm-empty-msg"><%= T("No XP data yet.", "Tiada data XP lagi.") %></div></div>
    </asp:Panel>
</div>
</asp:Panel><%-- /pnlOverview --%>

<%-- TAB: XP RULES (same as overview XP section but standalone) --%>
<asp:Panel ID="pnlXPTab" runat="server" Visible="false">
<div class="gm-card">
    <div class="gm-card-hdr"><i class="bi bi-lightning-fill" style="color:var(--gm-gold);"></i> <%= T("XP Action Rules", "Peraturan Tindakan XP") %></div>
    <asp:Repeater ID="rptXPTab" runat="server">
        <ItemTemplate>
            <div class="gm-xp-card">
                <div class="gm-xp-ico" style='<%# Eval("icoStyle") %>'><i class='<%# Eval("icoClass") %>'></i></div>
                <div class="gm-xp-body">
                    <div class="gm-xp-name"><%# HttpUtility.HtmlEncode(Eval("nameEN")) %></div>
                    <div class="gm-xp-name-bm"><%# HttpUtility.HtmlEncode(Eval("nameBM")) %></div>
                    <div class="gm-xp-meta"><span><i class="bi bi-people"></i> <%# Eval("earnedCount") %> <%= T("students earned", "pelajar memperoleh") %></span></div>
                </div>
                <div class="gm-xp-val">+<%# Eval("xpValue") %> XP</div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</div>
</asp:Panel>

<%-- TAB: BADGES --%>
<asp:Panel ID="pnlBadgesTab" runat="server" Visible="false">
<div class="gm-card">
    <div class="gm-card-hdr"><i class="bi bi-award-fill" style="color:var(--gm-purple);"></i> <%= T("All Badges", "Semua Lencana") %></div>
    <asp:Repeater ID="rptBadges" runat="server">
        <ItemTemplate>
            <div class="gm-xp-card">
                <div class="gm-xp-ico" style="background:#F3E8FF;color:#7C3AED;"><i class="bi bi-award-fill"></i></div>
                <div class="gm-xp-body">
                    <div class="gm-xp-name"><%# HttpUtility.HtmlEncode(Eval("nameEN")) %></div>
                    <div class="gm-xp-name-bm"><%# HttpUtility.HtmlEncode(Eval("nameBM")) %></div>
                    <div class="gm-xp-meta"><span><i class="bi bi-star"></i> <%# Eval("xpReward") %> XP | <i class="bi bi-people"></i> <%# Eval("earnedCount") %> <%= T("earned", "memperoleh") %></span></div>
                </div>
                <div style="font-size:.75rem;color:var(--color-text-muted);"><%# HttpUtility.HtmlEncode(Eval("badgeType")) %></div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</div>
</asp:Panel>

<%-- TAB: STUDENT REWARDS --%>
<asp:Panel ID="pnlStudentsTab" runat="server" Visible="false">
<div class="gm-card">
    <div class="gm-card-hdr"><i class="bi bi-people-fill" style="color:var(--gm-blue);"></i> <%= T("Student Leaderboard", "Papan Markah Pelajar") %></div>
    <asp:Repeater ID="rptStudentRewards" runat="server">
        <ItemTemplate>
            <div class="gm-lb-card">
                <div class='gm-lb-rank <%# Eval("rankCls") %>'><%# Eval("rank") %></div>
                <div style="flex:1;">
                    <div class="gm-lb-name"><%# HttpUtility.HtmlEncode(Eval("studentName")) %></div>
                    <div style="font-size:.75rem;color:var(--color-text-muted);"><i class="bi bi-award"></i> <%# Eval("badgeCount") %> <%= T("badges", "lencana") %> | <i class="bi bi-book"></i> <%# Eval("lessonsCompleted") %> <%= T("lessons", "pelajaran") %></div>
                </div>
                <div class="gm-lb-xp"><%# Eval("totalXP") %> XP</div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</div>
</asp:Panel>

</asp:Content>
