<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GamificationManagement.aspx.cs"
    Inherits="ScienceBuddy.Admin.GamificationManagement" MasterPageFile="~/Site.Master"
    Title="Student Performance" %>

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
        <a href="<%: ResolveUrl("~/Admin/GamificationManagement.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-trophy item-icon"></i><span class="item-label">Student Performance</span></a>
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

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%= T("Student Performance", "Prestasi Pelajar") %></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="ad-student-performance-header">
    <h1 class="ad-student-performance-title"><i class="bi bi-trophy-fill" style="color:var(--ad-student-performance-gold);"></i> <%= T("Student Performance", "Prestasi Pelajar") %></h1>
    <p class="ad-student-performance-sub"><%= T("Monitor XP rewards, badges, student achievements, and the ScienceBuddy reward system.", "Pantau ganjaran XP, lencana, pencapaian pelajar, dan sistem ganjaran ScienceBuddy.") %></p>
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

<div class="ad-student-performance-stats">
    <div class="ad-student-performance-stat s1"><div class="ad-student-performance-stat-ico" style="color:#D97706;"><i class="bi bi-lightning-fill"></i></div><div class="ad-student-performance-stat-val"><asp:Literal ID="litRules" runat="server" Text="0" /></div><div class="ad-student-performance-stat-lbl"><%= T("XP Rules", "Peraturan XP") %></div></div>
    <div class="ad-student-performance-stat s2"><div class="ad-student-performance-stat-ico" style="color:#7C3AED;"><i class="bi bi-star-fill"></i></div><div class="ad-student-performance-stat-val"><asp:Literal ID="litTotalXP" runat="server" Text="0" /></div><div class="ad-student-performance-stat-lbl"><%= T("Total XP Awarded", "Jumlah XP Dianugerah") %></div></div>
    <div class="ad-student-performance-stat s3"><div class="ad-student-performance-stat-ico" style="color:#059669;"><i class="bi bi-award-fill"></i></div><div class="ad-student-performance-stat-val"><asp:Literal ID="litCerts" runat="server" Text="0" /></div><div class="ad-student-performance-stat-lbl"><%= T("Certificates Issued", "Sijil Dikeluarkan") %></div></div>
    <div class="ad-student-performance-stat s4"><div class="ad-student-performance-stat-ico" style="color:#2563EB;"><i class="bi bi-people-fill"></i></div><div class="ad-student-performance-stat-val"><asp:Literal ID="litActiveStudents" runat="server" Text="0" /></div><div class="ad-student-performance-stat-lbl"><%= T("Active Students", "Pelajar Aktif") %></div></div>
</div>

<%-- XP RULES --%>
<div class="ad-student-performance-card">
    <div class="ad-student-performance-card-hdr"><i class="bi bi-lightning-fill" style="color:var(--ad-student-performance-gold);"></i> <%= T("XP Action Rules", "Peraturan Tindakan XP") %></div>
    <asp:Repeater ID="rptXPActions" runat="server">
        <ItemTemplate>
            <div class="ad-student-performance-xp-card">
                <div class="ad-student-performance-xp-ico" style='<%# Eval("icoStyle") %>'><i class='<%# Eval("icoClass") %>'></i></div>
                <div class="ad-student-performance-xp-body">
                    <div class="ad-student-performance-xp-name"><%# HttpUtility.HtmlEncode(Eval("nameEN")) %></div>
                    <div class="ad-student-performance-xp-name-bm"><%# HttpUtility.HtmlEncode(Eval("nameBM")) %></div>
                    <div class="ad-student-performance-xp-meta"><span><i class="bi bi-people"></i> <%# Eval("earnedCount") %> <%= T("students earned", "pelajar memperoleh") %></span></div>
                </div>
                <div class="ad-student-performance-xp-val">+<%# Eval("xpValue") %> XP</div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</div>

<%-- STUDENT LEADERBOARD (Podium Style) --%>
<div class="ad-student-performance-card">
    <div class="ad-student-performance-card-hdr"><i class="bi bi-bar-chart-fill" style="color:var(--ad-student-performance-purple);"></i> <%= T("Student Leaderboard", "Papan Markah Pelajar") %></div>
    <asp:Panel ID="pnlLeaderboard" runat="server" Visible="false">
        <div style="padding:var(--space-xl);">
            <!-- PODIUM -->
            <div class="ad-student-performance-podium">
                <asp:Literal ID="litPodium" runat="server" />
            </div>
            <!-- REST OF RANKINGS (4+) -->
            <asp:Panel ID="pnlRankings" runat="server" Visible="false">
                <div class="ad-student-performance-rankings">
                    <asp:Repeater ID="rptLeaderboard" runat="server">
                        <ItemTemplate>
                            <div class="ad-student-performance-rank-card">
                                <div class="ad-student-performance-rank-num">#<%# Eval("rank") %></div>
                                <div class="ad-student-performance-rank-avatar" style='background:<%# Eval("avatarBg") %>;'><%# Eval("initials") %></div>
                                <div class="ad-student-performance-rank-name"><%# HttpUtility.HtmlEncode(Eval("studentName")) %></div>
                                <div class="ad-student-performance-rank-xp"><%# Eval("totalXP") %> XP</div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </asp:Panel>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlNoLeaderboard" runat="server">
        <div class="ad-student-performance-empty"><div class="ad-student-performance-empty-ico"><i class="bi bi-bar-chart"></i></div><div class="ad-student-performance-empty-msg"><%= T("No XP data yet.", "Tiada data XP lagi.") %></div></div>
    </asp:Panel>
</div>
</asp:Panel><%-- /pnlOverview --%>

<%-- TAB: XP RULES (same as overview XP section but standalone) --%>
<asp:Panel ID="pnlXPTab" runat="server" Visible="false">
<div class="ad-student-performance-card">
    <div class="ad-student-performance-card-hdr"><i class="bi bi-lightning-fill" style="color:var(--ad-student-performance-gold);"></i> <%= T("XP Action Rules", "Peraturan Tindakan XP") %></div>
    <asp:Repeater ID="rptXPTab" runat="server">
        <ItemTemplate>
            <div class="ad-student-performance-xp-card">
                <div class="ad-student-performance-xp-ico" style='<%# Eval("icoStyle") %>'><i class='<%# Eval("icoClass") %>'></i></div>
                <div class="ad-student-performance-xp-body">
                    <div class="ad-student-performance-xp-name"><%# HttpUtility.HtmlEncode(Eval("nameEN")) %></div>
                    <div class="ad-student-performance-xp-name-bm"><%# HttpUtility.HtmlEncode(Eval("nameBM")) %></div>
                    <div class="ad-student-performance-xp-meta"><span><i class="bi bi-people"></i> <%# Eval("earnedCount") %> <%= T("students earned", "pelajar memperoleh") %></span></div>
                </div>
                <div class="ad-student-performance-xp-val">+<%# Eval("xpValue") %> XP</div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</div>
</asp:Panel>

<%-- TAB: BADGES --%>
<asp:Panel ID="pnlBadgesTab" runat="server" Visible="false">
<div class="ad-student-performance-card">
    <div class="ad-student-performance-card-hdr"><i class="bi bi-award-fill" style="color:var(--ad-student-performance-purple);"></i> <%= T("All Badges", "Semua Lencana") %></div>
    <asp:Repeater ID="rptBadges" runat="server">
        <ItemTemplate>
            <div class="ad-student-performance-xp-card">
                <div class="ad-student-performance-xp-ico" style="background:#F3E8FF;color:#7C3AED;"><i class="bi bi-award-fill"></i></div>
                <div class="ad-student-performance-xp-body">
                    <div class="ad-student-performance-xp-name"><%# HttpUtility.HtmlEncode(Eval("nameEN")) %></div>
                    <div class="ad-student-performance-xp-name-bm"><%# HttpUtility.HtmlEncode(Eval("nameBM")) %></div>
                    <div class="ad-student-performance-xp-meta"><span><i class="bi bi-star"></i> <%# Eval("xpReward") %> XP | <i class="bi bi-people"></i> <%# Eval("earnedCount") %> <%= T("earned", "memperoleh") %></span></div>
                </div>
                <div style="font-size:.75rem;color:var(--color-text-muted);"><%# HttpUtility.HtmlEncode(Eval("badgeType")) %></div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</div>
</asp:Panel>

<%-- TAB: STUDENT REWARDS --%>
<asp:Panel ID="pnlStudentsTab" runat="server" Visible="false">
<div class="ad-student-performance-card">
    <div class="ad-student-performance-card-hdr"><i class="bi bi-people-fill" style="color:var(--ad-student-performance-blue);"></i> <%= T("Student Leaderboard", "Papan Markah Pelajar") %></div>
    <asp:Repeater ID="rptStudentRewards" runat="server">
        <ItemTemplate>
            <div class="ad-student-performance-lb-card">
                <div class='ad-student-performance-lb-rank <%# Eval("rankCls") %>'><%# Eval("rank") %></div>
                <div style="flex:1;">
                    <div class="ad-student-performance-lb-name"><%# HttpUtility.HtmlEncode(Eval("studentName")) %></div>
                    <div style="font-size:.75rem;color:var(--color-text-muted);"><i class="bi bi-award"></i> <%# Eval("badgeCount") %> <%= T("badges", "lencana") %> | <i class="bi bi-book"></i> <%# Eval("lessonsCompleted") %> <%= T("lessons", "pelajaran") %></div>
                </div>
                <div class="ad-student-performance-lb-xp"><%# Eval("totalXP") %> XP</div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</div>
</asp:Panel>

</asp:Content>
