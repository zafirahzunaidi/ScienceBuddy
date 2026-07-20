<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="QuizManagement.aspx.cs"
    Inherits="ScienceBuddy.Admin.QuizManagement" MasterPageFile="~/Site.Master"
    Title="Quiz Management" %>

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
        <a href="<%: ResolveUrl("~/Admin/QuizManagement.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-patch-question item-icon"></i><span class="item-label">Quizzes</span></a>
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

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%= T("Quiz Management", "Pengurusan Kuiz") %></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="ad-quiz-management-header">
    <h1 class="ad-quiz-management-title"><i class="bi bi-patch-question-fill" style="color:var(--ad-quiz-management-accent);"></i> <%= T("Quiz Management", "Pengurusan Kuiz") %></h1>
    <p class="ad-quiz-management-sub"><%= T("Manage quizzes in the ScienceBuddy System.", "Urus kuiz di Sistem ScienceBuddy") %></p>
</div>

<div class="ad-quiz-management-stats">
    <div class="ad-quiz-management-stat s1"><div class="ad-quiz-management-stat-ico" style="color:#7C3AED;"><i class="bi bi-collection-fill"></i></div><div class="ad-quiz-management-stat-val"><asp:Literal ID="litTotal" runat="server" Text="0" /></div><div class="ad-quiz-management-stat-lbl"><%= T("Total Quizzes", "Jumlah Kuiz") %></div></div>
    <div class="ad-quiz-management-stat s2"><div class="ad-quiz-management-stat-ico" style="color:#2563EB;"><i class="bi bi-layers-fill"></i></div><div class="ad-quiz-management-stat-val"><asp:Literal ID="litUnit" runat="server" Text="0" /></div><div class="ad-quiz-management-stat-lbl"><%= T("Unit Quizzes", "Kuiz Unit") %></div></div>
    <div class="ad-quiz-management-stat s3"><div class="ad-quiz-management-stat-ico" style="color:#D97706;"><i class="bi bi-pencil-fill"></i></div><div class="ad-quiz-management-stat-val"><asp:Literal ID="litPractice" runat="server" Text="0" /></div><div class="ad-quiz-management-stat-lbl"><%= T("Practice Quizzes", "Kuiz Latihan") %></div></div>
    <div class="ad-quiz-management-stat s4"><div class="ad-quiz-management-stat-ico" style="color:#059669;"><i class="bi bi-people-fill"></i></div><div class="ad-quiz-management-stat-val"><asp:Literal ID="litAttempts" runat="server" Text="0" /></div><div class="ad-quiz-management-stat-lbl"><%= T("Student Attempts", "Percubaan Pelajar") %></div></div>
    <div class="ad-quiz-management-stat s5"><div class="ad-quiz-management-stat-ico" style="color:#DC2626;"><i class="bi bi-question-circle-fill"></i></div><div class="ad-quiz-management-stat-val"><asp:Literal ID="litQuestions" runat="server" Text="0" /></div><div class="ad-quiz-management-stat-lbl"><%= T("Total Questions", "Jumlah Soalan") %></div></div>
</div>

<div class="ad-quiz-management-search">
    <i class="bi bi-search text-muted"></i>
    <asp:TextBox ID="txtSearch" runat="server" CssClass="sb-input sb-input-sm" AutoPostBack="false" />
    <asp:DropDownList ID="ddlType" runat="server" CssClass="sb-select sb-input-sm" AutoPostBack="false">
        <asp:ListItem Value="">All Types</asp:ListItem>
        <asp:ListItem Value="Unit">Unit</asp:ListItem>
        <asp:ListItem Value="Level">Level</asp:ListItem>
        <asp:ListItem Value="Practice">Practice</asp:ListItem>
    </asp:DropDownList>
    <asp:DropDownList ID="ddlLevel" runat="server" CssClass="sb-select sb-input-sm" AutoPostBack="false" />
    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="sb-select sb-input-sm" AutoPostBack="false">
        <asp:ListItem Value="">All Status</asp:ListItem>
        <asp:ListItem Value="Approved">Approved</asp:ListItem>
        <asp:ListItem Value="Pending">Pending</asp:ListItem>
        <asp:ListItem Value="Rejected">Rejected</asp:ListItem>
    </asp:DropDownList>
    <asp:Button ID="btnSearch" runat="server" CssClass="sb-btn sb-btn-primary sb-btn-sm" OnClick="btnSearch_Click" />
    <asp:Button ID="btnReset" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnReset_Click" />
</div>

<div class="ad-quiz-management-card">
    <div class="ad-quiz-management-card-hdr"><i class="bi bi-list-ul" style="color:var(--ad-quiz-management-accent);"></i> <%= T("All Quizzes", "Semua Kuiz") %></div>
    <asp:Panel ID="pnlQuizzes" runat="server" Visible="false">
        <div class="sb-table-wrapper" style="border:none;border-radius:0;box-shadow:none;">
            <table class="sb-table"><thead><tr>
                <th><%= T("Title", "Tajuk") %></th><th><%= T("Type", "Jenis") %></th><th><%= T("Level", "Tahap") %></th><th><%= T("Questions", "Soalan") %></th><th><%= T("Attempts", "Percubaan") %></th><th><%= T("Status", "Status") %></th><th></th>
            </tr></thead><tbody>
                <asp:Repeater ID="rptQuizzes" runat="server" OnItemCommand="rptQuizzes_ItemCommand">
                    <ItemTemplate>
                        <tr>
                            <td data-label="Title"><strong><%# HttpUtility.HtmlEncode(Eval("title")) %></strong></td>
                            <td data-label="Type"><span class='sb-badge <%# Eval("typeCls") %>'><%# HttpUtility.HtmlEncode(Eval("quizType")) %></span></td>
                            <td data-label="Level"><span class="sb-badge sb-badge-gray"><%# HttpUtility.HtmlEncode(Eval("level")) %></span></td>
                            <td data-label="Questions"><%# Eval("questionCount") %></td>
                            <td data-label="Attempts"><%# Eval("attemptCount") %></td>
                            <td data-label="Status"><span class='sb-badge <%# Eval("statusCls") %>'><%# HttpUtility.HtmlEncode(Eval("statusLabel")) %></span></td>
                            <td class="col-actions">
                                <asp:LinkButton ID="lnkView" runat="server" CssClass="sb-btn sb-btn-outline-primary sb-btn-xs" CommandName="ViewQuiz" CommandArgument='<%# Eval("quizId") %>'>
                                    <i class="bi bi-eye"></i>
                                </asp:LinkButton>
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody></table>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlEmpty" runat="server">
        <div class="ad-quiz-management-empty"><div class="ad-quiz-management-empty-ico"><i class="bi bi-patch-question"></i></div><div class="ad-quiz-management-empty-msg"><%= T("No quizzes found.", "Tiada kuiz ditemui.") %></div></div>
    </asp:Panel>
</div>

<%-- VIEW MODAL --%>
<asp:Panel ID="pnlModal" runat="server" Visible="false" Cssclass="ad-quiz-management-modal-wrap">
<div class="sb-modal-overlay active" style="display:flex;">
    <div class="sb-modal" style="max-width:800px;width:92vw;max-height:90vh;overflow-y:auto;">
        <div style="background:linear-gradient(135deg,#7C3AED,#A78BFA);padding:var(--space-lg) var(--space-xl);color:#fff;border-radius:var(--border-radius-xl) var(--border-radius-xl) 0 0;">
            <div style="font-family:var(--font-primary);font-size:1.125rem;font-weight:800;display:flex;align-items:center;gap:var(--space-sm);"><i class="bi bi-patch-question-fill"></i> <asp:Literal ID="litMTitle" runat="server" /></div>
            <div style="font-size:.8125rem;opacity:.8;margin-top:4px;"><asp:Literal ID="litMInfo" runat="server" /></div>
        </div>
        <div style="padding:var(--space-xl);">
            <div style="font-family:var(--font-primary);font-weight:700;font-size:.875rem;margin-bottom:var(--space-md);display:flex;align-items:center;gap:var(--space-sm);"><i class="bi bi-list-check" style="color:var(--ad-quiz-management-accent);"></i> <%= T("Questions", "Soalan") %> (<asp:Literal ID="litMQCount" runat="server" Text="0" />)</div>
            <asp:Panel ID="pnlQuestions" runat="server" Visible="false">
                <asp:Repeater ID="rptQuestions" runat="server">
                    <ItemTemplate>
                        <div class="ad-quiz-management-q-card">
                            <div class="ad-quiz-management-q-num"><%= T("Question", "Soalan") %> <%# Eval("num") %> <span class="sb-badge sb-badge-gray" style="margin-left:4px;"><%# HttpUtility.HtmlEncode(Eval("difficulty")) %></span> <span class="sb-badge sb-badge-primary" style="margin-left:4px;"><%# HttpUtility.HtmlEncode(Eval("questionType")) %></span></div>
                            <div class="ad-quiz-management-q-text"><%# HttpUtility.HtmlEncode(Eval("questionText")) %></div>
                            <%-- MCQ / TrueFalse / Multiselect: show options with highlighting --%>
                            <div style='<%# HideIf((bool)Eval("isDragDrop") || (bool)Eval("isFillBlank")) %>'>
                                <div class='ad-quiz-management-q-opt <%# Eval("correctAnswer").ToString().Contains("A") ? "correct" : "" %>' style='<%# HideIf(string.IsNullOrWhiteSpace(Eval("optA").ToString())) %>'>A) <%# HttpUtility.HtmlEncode(Eval("optA")) %></div>
                                <div class='ad-quiz-management-q-opt <%# Eval("correctAnswer").ToString().Contains("B") ? "correct" : "" %>' style='<%# HideIf(string.IsNullOrWhiteSpace(Eval("optB").ToString())) %>'>B) <%# HttpUtility.HtmlEncode(Eval("optB")) %></div>
                                <div class='ad-quiz-management-q-opt <%# Eval("correctAnswer").ToString().Contains("C") ? "correct" : "" %>' style='<%# HideIf(string.IsNullOrWhiteSpace(Eval("optC").ToString())) %>'>C) <%# HttpUtility.HtmlEncode(Eval("optC")) %></div>
                                <div class='ad-quiz-management-q-opt <%# Eval("correctAnswer").ToString().Contains("D") ? "correct" : "" %>' style='<%# HideIf(string.IsNullOrWhiteSpace(Eval("optD").ToString())) %>'>D) <%# HttpUtility.HtmlEncode(Eval("optD")) %></div>
                            </div>
                            <%-- Fill in the Blank: show correct answer text --%>
                            <div style='<%# GetFillBlankStyle((bool)Eval("isFillBlank")) %>'>
                                <div style="font-size:.75rem;font-weight:700;color:#065F46;margin-bottom:4px;"><i class="bi bi-check-circle-fill"></i> <%= T("Correct Answer", "Jawapan Betul") %></div>
                                <div style="font-size:.875rem;font-weight:600;color:#064E3B;"><%# HttpUtility.HtmlEncode(Eval("correctAnswer")) %></div>
                            </div>
                            <%-- Drag & Drop: show correct sequence --%>
                            <div style='<%# GetDragDropStyle((bool)Eval("isDragDrop")) %>'>
                                <div style="font-size:.75rem;font-weight:700;color:#1E40AF;margin-bottom:10px;display:flex;align-items:center;gap:6px;"><i class="bi bi-sort-numeric-down"></i> <%= T("Expected Order", "Susunan Yang Betul") %></div>
                                <div style="display:flex;flex-direction:column;gap:0;"><%# FormatDragDropAnswer(Eval("correctAnswer").ToString()) %></div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </asp:Panel>
            <asp:Panel ID="pnlNoQuestions" runat="server"><p style="color:var(--color-text-muted);font-size:.875rem;text-align:center;padding:var(--space-lg);"><%= T("No questions found.", "Tiada soalan ditemui.") %></p></asp:Panel>
        </div>
        <div class="sb-modal-footer"><asp:Button ID="btnCloseModal" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnCloseModal_Click" /></div>
    </div>
</div>
</asp:Panel>
</asp:Content>
