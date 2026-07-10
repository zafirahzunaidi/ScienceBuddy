<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LessonManagement.aspx.cs"
    Inherits="ScienceBuddy.Admin.LessonManagement" MasterPageFile="~/Site.Master"
    Title="Lesson Management" %>

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
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Learning Content</div>
        <a href="<%: ResolveUrl("~/Admin/LessonManagement.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-book item-icon"></i><span class="item-label">Lessons</span></a>
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

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%= T("Lesson Management", "Pengurusan Pelajaran") %></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="ad-lesson-management-header">
    <h1 class="ad-lesson-management-title"><i class="bi bi-book-fill" style="color:var(--ad-lesson-management-accent);"></i> <%= T("Lesson Management", "Pengurusan Pelajaran") %></h1>
    <p class="ad-lesson-management-sub"><%= T("Manage all learning lessons available in ScienceBuddy.", "Urus semua pelajaran yang tersedia dalam ScienceBuddy.") %></p>
</div>

<div class="ad-lesson-management-stats">
    <div class="ad-lesson-management-stat s1"><div class="ad-lesson-management-stat-ico" style="color:#2563EB;"><i class="bi bi-book-fill"></i></div><div class="ad-lesson-management-stat-val"><asp:Literal ID="litTotal" runat="server" Text="0" /></div><div class="ad-lesson-management-stat-lbl"><%= T("Total Lessons", "Jumlah Pelajaran") %></div></div>
    <div class="ad-lesson-management-stat s2"><div class="ad-lesson-management-stat-ico" style="color:#7C3AED;"><i class="bi bi-camera-video-fill"></i></div><div class="ad-lesson-management-stat-val"><asp:Literal ID="litVideo" runat="server" Text="0" /></div><div class="ad-lesson-management-stat-lbl"><%= T("Video Lessons", "Pelajaran Video") %></div></div>
    <div class="ad-lesson-management-stat s3"><div class="ad-lesson-management-stat-ico" style="color:#059669;"><i class="bi bi-image-fill"></i></div><div class="ad-lesson-management-stat-val"><asp:Literal ID="litImage" runat="server" Text="0" /></div><div class="ad-lesson-management-stat-lbl"><%= T("Image Lessons", "Pelajaran Imej") %></div></div>
    <div class="ad-lesson-management-stat s4"><div class="ad-lesson-management-stat-ico" style="color:#D97706;"><i class="bi bi-grid-fill"></i></div><div class="ad-lesson-management-stat-val"><asp:Literal ID="litUnits" runat="server" Text="0" /></div><div class="ad-lesson-management-stat-lbl"><%= T("Learning Units", "Unit Pembelajaran") %></div></div>
</div>

<div class="ad-lesson-management-search">
    <i class="bi bi-search text-muted"></i>
    <asp:TextBox ID="txtSearch" runat="server" CssClass="sb-input sb-input-sm" AutoPostBack="false" />
    <asp:DropDownList ID="ddlLevel" runat="server" CssClass="sb-select sb-input-sm" AutoPostBack="false" />
    <asp:DropDownList ID="ddlUnit" runat="server" CssClass="sb-select sb-input-sm" AutoPostBack="false" />
    <asp:Button ID="btnSearch" runat="server" CssClass="sb-btn sb-btn-primary sb-btn-sm" OnClick="btnSearch_Click" />
    <asp:Button ID="btnReset" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnReset_Click" />
</div>

<div class="ad-lesson-management-card">
    <div class="ad-lesson-management-card-hdr"><i class="bi bi-list-ul" style="color:var(--ad-lesson-management-accent);"></i> <%= T("All Lessons", "Semua Pelajaran") %></div>
    <asp:Panel ID="pnlLessons" runat="server" Visible="false">
        <div class="sb-table-wrapper" style="border:none;border-radius:0;box-shadow:none;">
            <table class="sb-table"><thead><tr>
                <th>#</th><th><%= T("Title", "Tajuk") %></th><th><%= T("Subtopic", "Subtopik") %></th><th><%= T("Unit", "Unit") %></th><th><%= T("Level", "Tahap") %></th><th><%= T("Type", "Jenis") %></th><th></th>
            </tr></thead><tbody>
                <asp:Repeater ID="rptLessons" runat="server" OnItemCommand="rptLessons_ItemCommand">
                    <ItemTemplate>
                        <tr>
                            <td data-label="#"><%# HttpUtility.HtmlEncode(Eval("orderNo")) %></td>
                            <td data-label="Title"><strong><%# HttpUtility.HtmlEncode(Eval("title")) %></strong></td>
                            <td data-label="Subtopic"><span style="font-size:.8125rem;"><%# HttpUtility.HtmlEncode(Eval("subtopic")) %></span></td>
                            <td data-label="Unit"><span class="sb-badge sb-badge-primary"><%# HttpUtility.HtmlEncode(Eval("unit")) %></span></td>
                            <td data-label="Level"><span class="sb-badge sb-badge-gray"><%# HttpUtility.HtmlEncode(Eval("level")) %></span></td>
                            <td data-label="Type"><span class='sb-badge <%# Eval("typeCls") %>'><%# HttpUtility.HtmlEncode(Eval("attachType")) %></span></td>
                            <td class="col-actions">
                                <asp:LinkButton ID="lnkView" runat="server" CssClass="sb-btn sb-btn-outline-primary sb-btn-xs" CommandName="ViewLesson" CommandArgument='<%# Eval("lessonId") %>'>
                                    <i class="bi bi-eye"></i> <%= T("View", "Lihat") %>
                                </asp:LinkButton>
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody></table>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlEmpty" runat="server">
        <div class="ad-lesson-management-empty"><div class="ad-lesson-management-empty-ico"><i class="bi bi-book"></i></div><div class="ad-lesson-management-empty-msg"><%= T("No lessons found.", "Tiada pelajaran ditemui.") %></div></div>
    </asp:Panel>
</div>

<%-- VIEW MODAL --%>
<asp:Panel ID="pnlModal" runat="server" Visible="false" Cssclass="ad-lesson-management-modal-wrap">
<div class="sb-modal-overlay active" style="display:flex;">
    <div class="sb-modal" style="max-width:1000px;width:94vw;max-height:92vh;overflow-y:auto;">
        <%-- Gradient Header --%>
        <div style="background:linear-gradient(135deg,#2563EB,#7C3AED);padding:var(--space-lg) var(--space-xl);color:#fff;border-radius:var(--border-radius-xl) var(--border-radius-xl) 0 0;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:var(--space-md);">
            <div style="display:flex;align-items:center;gap:var(--space-md);">
                <div style="width:44px;height:44px;border-radius:var(--border-radius);background:rgba(255,255,255,.2);display:flex;align-items:center;justify-content:center;font-size:1.25rem;"><i class="bi bi-book-fill"></i></div>
                <div>
                    <div style="font-family:var(--font-primary);font-size:1.125rem;font-weight:800;"><asp:Literal ID="litMTitleEN" runat="server" /></div>
                    <div style="font-size:.8125rem;opacity:.8;"><asp:Literal ID="litMSubtopic" runat="server" /></div>
                </div>
            </div>
            <div style="display:flex;gap:var(--space-xs);">
                <span class="sb-badge" style="background:rgba(255,255,255,.2);color:#fff;"><asp:Literal ID="litMLevel" runat="server" /></span>
                <span class="sb-badge" style="background:rgba(255,255,255,.2);color:#fff;"><asp:Literal ID="litMUnit" runat="server" /></span>
                <span class="sb-badge" style="background:rgba(255,255,255,.2);color:#fff;">#<asp:Literal ID="litMOrder" runat="server" /></span>
            </div>
        </div>

        <%-- Media Preview --%>
        <div style="background:#F1F5F9;padding:var(--space-lg);text-align:center;border-bottom:1px solid var(--border-color);">
            <asp:Literal ID="litMMedia" runat="server" />
            <div style="margin-top:var(--space-sm);font-size:.75rem;color:var(--color-text-muted);"><i class="bi bi-file-earmark"></i> <asp:Literal ID="litMAttachType" runat="server" /></div>
        </div>

        <%-- Content Body --%>
        <div style="padding:var(--space-xl);display:grid;grid-template-columns:1fr 1fr;gap:var(--space-lg);">
            <%-- English Content --%>
            <div>
                <div style="font-size:.75rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:var(--space-sm);display:flex;align-items:center;gap:4px;"><i class="bi bi-globe"></i> <%= T("English Content", "Kandungan Bahasa Inggeris") %></div>
                <div style="background:var(--color-surface-alt);border-radius:var(--border-radius-lg);padding:var(--space-lg);font-size:.875rem;color:var(--color-text);line-height:1.7;max-height:280px;overflow-y:auto;">
                    <asp:Literal ID="litMContentEN" runat="server" />
                </div>
            </div>
            <%-- BM Content --%>
            <div>
                <div style="font-size:.75rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:var(--space-sm);display:flex;align-items:center;gap:4px;"><i class="bi bi-translate"></i> <%= T("Bahasa Melayu Content", "Kandungan Bahasa Melayu") %></div>
                <div style="background:var(--color-surface-alt);border-radius:var(--border-radius-lg);padding:var(--space-lg);font-size:.875rem;color:var(--color-text);line-height:1.7;max-height:280px;overflow-y:auto;">
                    <asp:Literal ID="litMContentBM" runat="server" />
                </div>
            </div>
        </div>

        <%-- BM Title --%>
        <div style="padding:0 var(--space-xl) var(--space-lg);"><div style="font-size:.75rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;"><%= T("Title (BM)", "Tajuk (BM)") %></div><div style="font-size:.9375rem;font-weight:600;color:var(--color-text);"><asp:Literal ID="litMTitleBM" runat="server" /></div></div>

        <%-- Footer --%>
        <div class="sb-modal-footer"><asp:Button ID="btnCloseModal" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnCloseModal_Click" /></div>
    </div>
</div>
</asp:Panel>
</asp:Content>
