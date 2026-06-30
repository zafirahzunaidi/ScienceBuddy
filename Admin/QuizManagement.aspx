<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="QuizManagement.aspx.cs"
    Inherits="ScienceBuddy.Admin.QuizManagement" MasterPageFile="~/Site.Master"
    Title="Quiz Management" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--qm-accent:#7C3AED;--qm-blue:#2563EB;--qm-green:#059669;--qm-orange:#D97706;--qm-red:#DC2626;--qm-cyan:#0891B2;}
.qm-header{margin-bottom:var(--space-xl);padding-bottom:var(--space-md);border-bottom:1.5px solid var(--border-color);}
.qm-title{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;color:var(--color-text);display:flex;align-items:center;gap:var(--space-sm);margin-bottom:var(--space-xs);}
.qm-sub{font-size:.9375rem;color:var(--color-text-secondary);max-width:520px;line-height:1.5;}
.qm-stats{display:grid;grid-template-columns:repeat(5,1fr);gap:var(--space-md);margin-bottom:var(--space-xl);}
.qm-stat{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);padding:var(--space-lg);display:flex;flex-direction:column;gap:var(--space-xs);transition:transform .25s,box-shadow .25s;position:relative;overflow:hidden;}
.qm-stat:hover{transform:translateY(-3px);box-shadow:var(--shadow-md);}
.qm-stat::before{content:'';position:absolute;top:0;left:0;right:0;height:3px;}
.qm-stat.s1::before{background:linear-gradient(90deg,#7C3AED,#A78BFA);}.qm-stat.s2::before{background:linear-gradient(90deg,#2563EB,#60A5FA);}.qm-stat.s3::before{background:linear-gradient(90deg,#D97706,#FBBF24);}.qm-stat.s4::before{background:linear-gradient(90deg,#059669,#34D399);}.qm-stat.s5::before{background:linear-gradient(90deg,#DC2626,#F87171);}
.qm-stat-ico{font-size:1.25rem;}.qm-stat-val{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;color:var(--color-text);}.qm-stat-lbl{font-size:.75rem;color:var(--color-text-muted);font-weight:600;}
.qm-search{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-md);padding:var(--space-md) var(--space-xl);display:flex;align-items:center;gap:var(--space-md);flex-wrap:wrap;margin-bottom:var(--space-xl);transition:box-shadow .2s;}
.qm-search:focus-within{box-shadow:0 8px 32px rgba(124,58,237,.08);}
.qm-search .sb-input{flex:1;min-width:160px;max-width:260px;}.qm-search .sb-select{max-width:140px;}
.qm-card{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);overflow:hidden;margin-bottom:var(--space-xl);}
.qm-card-hdr{padding:var(--space-md) var(--space-lg);border-bottom:1px solid var(--border-color);font-family:var(--font-primary);font-weight:800;font-size:.9375rem;display:flex;align-items:center;gap:var(--space-sm);}
.qm-empty{display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;padding:var(--space-2xl);}
.qm-empty-ico{font-size:3rem;margin-bottom:var(--space-md);opacity:.35;color:var(--qm-accent);}.qm-empty-msg{font-size:1rem;font-weight:700;color:var(--color-text-secondary);}
.qm-modal-wrap .sb-modal-overlay{left:var(--sidebar-width);animation:qm-ov .2s ease both;}.sidebar-collapsed .qm-modal-wrap .sb-modal-overlay{left:var(--sidebar-collapsed);}
.qm-modal-wrap .sb-modal{animation:qm-md .3s cubic-bezier(.34,1.56,.64,1) both;}
@keyframes qm-ov{from{opacity:0;}to{opacity:1;}}@keyframes qm-md{from{opacity:0;transform:scale(.92) translateY(16px);}to{opacity:1;transform:scale(1) translateY(0);}}
.qm-q-card{background:var(--color-surface-alt);border-radius:var(--border-radius-lg);padding:var(--space-md);margin-bottom:var(--space-sm);border-left:3px solid var(--qm-accent);}
.qm-q-num{font-size:.6875rem;font-weight:700;color:var(--qm-accent);text-transform:uppercase;letter-spacing:.5px;margin-bottom:4px;}
.qm-q-text{font-size:.875rem;font-weight:600;color:var(--color-text);margin-bottom:var(--space-sm);}
.qm-q-opts{display:grid;grid-template-columns:1fr 1fr;gap:4px;font-size:.8125rem;}
.qm-q-opt{padding:4px 8px;border-radius:var(--border-radius-sm);background:var(--color-white);border:1px solid var(--border-color);}
.qm-q-opt.correct{background:#ECFDF5;border-color:#059669;color:#059669;font-weight:600;}
@media(max-width:1279px){.qm-stats{grid-template-columns:repeat(3,1fr);}}
@media(max-width:767px){.qm-stats{grid-template-columns:1fr 1fr;}.qm-search{flex-direction:column;align-items:stretch;}.qm-search .sb-input,.qm-search .sb-select{max-width:100%;}.qm-modal-wrap .sb-modal-overlay{left:0;}.qm-q-opts{grid-template-columns:1fr;}}
</style>
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
        <a href="<%: ResolveUrl("~/Admin/QuizManagement.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-patch-question item-icon"></i><span class="item-label">Quizzes</span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-question-circle item-icon"></i><span class="item-label">Questions</span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-file-earmark-text item-icon"></i><span class="item-label">Teacher Materials</span></a>
        <a href="<%: ResolveUrl("~/Admin/LiveSessions.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label">Live Sessions</span></a>
        <a href="<%: ResolveUrl("~/Admin/ContentRequests.aspx") %>" class="sb-sidebar-item"><i class="bi bi-inbox item-icon"></i><span class="item-label">Content Requests</span></a>
        <a href="<%: ResolveUrl("~/Admin/CertificateManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-award item-icon"></i><span class="item-label">Certificates</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Gamification</div>
        <a href="<%: ResolveUrl("~/Admin/GamificationManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-trophy item-icon"></i><span class="item-label">Gamification</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Configuration</div>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-gear item-icon"></i><span class="item-label">Quiz Settings</span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-shield-lock item-icon"></i><span class="item-label">Security Settings</span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-sliders item-icon"></i><span class="item-label">XP Settings</span></a>
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

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%= T("Quiz Management", "Pengurusan Kuiz") %></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="qm-header">
    <h1 class="qm-title"><i class="bi bi-patch-question-fill" style="color:var(--qm-accent);"></i> <%= T("Quiz Management", "Pengurusan Kuiz") %></h1>
    <p class="qm-sub"><%= T("Manage quizzes, approve teacher requests and monitor student performance.", "Urus kuiz, luluskan permintaan guru dan pantau prestasi pelajar.") %></p>
</div>

<div class="qm-stats">
    <div class="qm-stat s1"><div class="qm-stat-ico" style="color:#7C3AED;"><i class="bi bi-collection-fill"></i></div><div class="qm-stat-val"><asp:Literal ID="litTotal" runat="server" Text="0" /></div><div class="qm-stat-lbl"><%= T("Total Quizzes", "Jumlah Kuiz") %></div></div>
    <div class="qm-stat s2"><div class="qm-stat-ico" style="color:#2563EB;"><i class="bi bi-layers-fill"></i></div><div class="qm-stat-val"><asp:Literal ID="litUnit" runat="server" Text="0" /></div><div class="qm-stat-lbl"><%= T("Unit Quizzes", "Kuiz Unit") %></div></div>
    <div class="qm-stat s3"><div class="qm-stat-ico" style="color:#D97706;"><i class="bi bi-pencil-fill"></i></div><div class="qm-stat-val"><asp:Literal ID="litPractice" runat="server" Text="0" /></div><div class="qm-stat-lbl"><%= T("Practice Quizzes", "Kuiz Latihan") %></div></div>
    <div class="qm-stat s4"><div class="qm-stat-ico" style="color:#059669;"><i class="bi bi-people-fill"></i></div><div class="qm-stat-val"><asp:Literal ID="litAttempts" runat="server" Text="0" /></div><div class="qm-stat-lbl"><%= T("Student Attempts", "Percubaan Pelajar") %></div></div>
    <div class="qm-stat s5"><div class="qm-stat-ico" style="color:#DC2626;"><i class="bi bi-question-circle-fill"></i></div><div class="qm-stat-val"><asp:Literal ID="litQuestions" runat="server" Text="0" /></div><div class="qm-stat-lbl"><%= T("Total Questions", "Jumlah Soalan") %></div></div>
</div>

<div class="qm-search">
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

<div class="qm-card">
    <div class="qm-card-hdr"><i class="bi bi-list-ul" style="color:var(--qm-accent);"></i> <%= T("All Quizzes", "Semua Kuiz") %></div>
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
        <div class="qm-empty"><div class="qm-empty-ico"><i class="bi bi-patch-question"></i></div><div class="qm-empty-msg"><%= T("No quizzes found.", "Tiada kuiz ditemui.") %></div></div>
    </asp:Panel>
</div>

<%-- VIEW MODAL --%>
<asp:Panel ID="pnlModal" runat="server" Visible="false" CssClass="qm-modal-wrap">
<div class="sb-modal-overlay active" style="display:flex;">
    <div class="sb-modal" style="max-width:800px;width:92vw;max-height:90vh;overflow-y:auto;">
        <div style="background:linear-gradient(135deg,#7C3AED,#A78BFA);padding:var(--space-lg) var(--space-xl);color:#fff;border-radius:var(--border-radius-xl) var(--border-radius-xl) 0 0;">
            <div style="font-family:var(--font-primary);font-size:1.125rem;font-weight:800;display:flex;align-items:center;gap:var(--space-sm);"><i class="bi bi-patch-question-fill"></i> <asp:Literal ID="litMTitle" runat="server" /></div>
            <div style="font-size:.8125rem;opacity:.8;margin-top:4px;"><asp:Literal ID="litMInfo" runat="server" /></div>
        </div>
        <div style="padding:var(--space-xl);">
            <div style="font-family:var(--font-primary);font-weight:700;font-size:.875rem;margin-bottom:var(--space-md);display:flex;align-items:center;gap:var(--space-sm);"><i class="bi bi-list-check" style="color:var(--qm-accent);"></i> <%= T("Questions", "Soalan") %> (<asp:Literal ID="litMQCount" runat="server" Text="0" />)</div>
            <asp:Panel ID="pnlQuestions" runat="server" Visible="false">
                <asp:Repeater ID="rptQuestions" runat="server">
                    <ItemTemplate>
                        <div class="qm-q-card">
                            <div class="qm-q-num"><%= T("Question", "Soalan") %> <%# Eval("num") %> <span class="sb-badge sb-badge-gray" style="margin-left:4px;"><%# HttpUtility.HtmlEncode(Eval("difficulty")) %></span></div>
                            <div class="qm-q-text"><%# HttpUtility.HtmlEncode(Eval("questionText")) %></div>
                            <div class="qm-q-opts">
                                <div class='qm-q-opt <%# Eval("correctAnswer").ToString()=="A" ? "correct" : "" %>'>A) <%# HttpUtility.HtmlEncode(Eval("optA")) %></div>
                                <div class='qm-q-opt <%# Eval("correctAnswer").ToString()=="B" ? "correct" : "" %>'>B) <%# HttpUtility.HtmlEncode(Eval("optB")) %></div>
                                <div class='qm-q-opt <%# Eval("correctAnswer").ToString()=="C" ? "correct" : "" %>'>C) <%# HttpUtility.HtmlEncode(Eval("optC")) %></div>
                                <div class='qm-q-opt <%# Eval("correctAnswer").ToString()=="D" ? "correct" : "" %>'>D) <%# HttpUtility.HtmlEncode(Eval("optD")) %></div>
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
