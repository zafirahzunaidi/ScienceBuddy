<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CertificateManagement.aspx.cs"
    Inherits="ScienceBuddy.Admin.CertificateManagement" MasterPageFile="~/Site.Master"
    Title="Certificate Management" %>

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
        <a href="<%: ResolveUrl("~/Admin/LessonManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label">Lessons</span></a>
        <a href="<%: ResolveUrl("~/Admin/QuizManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label">Quizzes</span></a>
        <a href="<%: ResolveUrl("~/Admin/QuestionBank.aspx") %>" class="sb-sidebar-item"><i class="bi bi-question-circle item-icon"></i><span class="item-label">Question Bank</span></a>
        <a href="<%: ResolveUrl("~/Admin/TeacherMaterials.aspx") %>" class="sb-sidebar-item"><i class="bi bi-file-earmark-text item-icon"></i><span class="item-label">Material Requests</span></a>
        <a href="<%: ResolveUrl("~/Admin/LiveSessions.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label">Live Sessions</span></a>
        <a href="<%: ResolveUrl("~/Admin/QuestionRequests.aspx") %>" class="sb-sidebar-item"><i class="bi bi-clipboard-check item-icon"></i><span class="item-label">Question Requests</span></a>
        <a href="<%: ResolveUrl("~/Admin/CertificateManagement.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-award item-icon"></i><span class="item-label">Certificates</span></a>
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

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%= T("Certificate Management", "Pengurusan Sijil") %></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<div class="ad-certificate-management-header">
    <h1 class="ad-certificate-management-title"><%= T("Certificate Management", "Pengurusan Sijil") %></h1>
    <p class="ad-certificate-management-sub"><%= T("Automatically generate and issue level completion certificates.", "Menjana dan mengeluarkan sijil tamat tahap secara automatik.") %></p>
</div>

<div class="ad-certificate-management-stats">
    <div class="ad-certificate-management-stat s1"><div class="ad-certificate-management-stat-ico" style="color:#2563EB;"><i class="bi bi-file-earmark-check"></i></div><div class="ad-certificate-management-stat-val"><asp:Literal ID="litReady" runat="server" Text="0" /></div><div class="ad-certificate-management-stat-lbl"><%= T("Ready to Generate", "Sedia Dijana") %></div></div>
    <div class="ad-certificate-management-stat s2"><div class="ad-certificate-management-stat-ico" style="color:#059669;"><i class="bi bi-award-fill"></i></div><div class="ad-certificate-management-stat-val"><asp:Literal ID="litGenerated" runat="server" Text="0" /></div><div class="ad-certificate-management-stat-lbl"><%= T("Generated", "Dijana") %></div></div>
    <div class="ad-certificate-management-stat s3"><div class="ad-certificate-management-stat-ico" style="color:#7C3AED;"><i class="bi bi-send-fill"></i></div><div class="ad-certificate-management-stat-val"><asp:Literal ID="litSent" runat="server" Text="0" /></div><div class="ad-certificate-management-stat-lbl"><%= T("Sent", "Dihantar") %></div></div>
    <div class="ad-certificate-management-stat s4"><div class="ad-certificate-management-stat-ico" style="color:#D97706;"><i class="bi bi-collection-fill"></i></div><div class="ad-certificate-management-stat-val"><asp:Literal ID="litTotal" runat="server" Text="0" /></div><div class="ad-certificate-management-stat-lbl"><%= T("Total Certificates", "Jumlah Sijil") %></div></div>
</div>

<%-- CERTIFICATES TABLE --%>
<div class="ad-certificate-management-card">
    <div class="ad-certificate-management-card-hdr"><i class="bi bi-award" style="color:var(--ad-certificate-management-accent);"></i> <%= T("All Certificates", "Semua Sijil") %></div>
    <asp:Panel ID="pnlCerts" runat="server" Visible="false">
        <div class="sb-table-wrapper" style="border:none;border-radius:0;box-shadow:none;">
            <table class="sb-table">
                <thead><tr>
                    <th><%= T("Student", "Pelajar") %></th>
                    <th><%= T("Level", "Tahap") %></th>
                    <th><%= T("Title", "Tajuk") %></th>
                    <th><%= T("Issued", "Dikeluarkan") %></th>
                    <th><%= T("Code", "Kod") %></th>
                    <th><%= T("Status", "Status") %></th>
                    <th><%= T("Actions", "Tindakan") %></th>
                </tr></thead>
                <tbody>
                    <asp:Repeater ID="rptCerts" runat="server" OnItemCommand="rptCerts_ItemCommand">
                        <ItemTemplate>
                            <tr>
                                <td data-label="Student"><strong><%# HttpUtility.HtmlEncode(Eval("studentName")) %></strong></td>
                                <td data-label="Level"><span class="sb-badge sb-badge-primary"><%# HttpUtility.HtmlEncode(Eval("levelName")) %></span></td>
                                <td data-label="Title"><%# HttpUtility.HtmlEncode(Eval("title")) %></td>
                                <td data-label="Issued"><span style="font-size:.8125rem;color:var(--color-text-muted);"><%# Eval("issuedStr") %></span></td>
                                <td data-label="Code"><code style="font-size:.75rem;"><%# HttpUtility.HtmlEncode(Eval("code")) %></code></td>
                                <td data-label="Status"><span class='sb-badge <%# Eval("statusCls") %>'><%# HttpUtility.HtmlEncode(Eval("statusLabel")) %></span></td>
                                <td class="col-actions">
                                    <div class="ad-certificate-management-actions">
                                        <asp:LinkButton ID="lnkView" runat="server" CssClass="sb-btn sb-btn-light sb-btn-xs" CommandName="ViewCert" CommandArgument='<%# Eval("certId") %>' ToolTip="View">
                                            <i class="bi bi-eye"></i>
                                        </asp:LinkButton>
                                        <asp:LinkButton ID="lnkSend" runat="server" CssClass="sb-btn sb-btn-primary sb-btn-xs" CommandName="SendCert" CommandArgument='<%# Eval("certId") + "|" + Eval("studentUserId") + "|" + Eval("studentName") + "|" + Eval("levelName") %>'
                                            Visible='<%# Eval("canSend") %>' OnClientClick="return confirm('Send this certificate?');" ToolTip="Send">
                                            <i class="bi bi-send"></i> <%= T("Send", "Hantar") %>
                                        </asp:LinkButton>
                                    </div>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlEmpty" runat="server">
        <div class="ad-certificate-management-empty">
            <div class="ad-certificate-management-empty-ico"><i class="bi bi-award"></i></div>
            <div class="ad-certificate-management-empty-msg"><%= T("No certificates found.", "Tiada sijil dijumpai.") %></div>
        </div>
    </asp:Panel>
</div>

<%-- ELIGIBLE STUDENTS (no cert yet) --%>
<div class="ad-certificate-management-card">
    <div class="ad-certificate-management-card-hdr"><i class="bi bi-person-check" style="color:#059669;"></i> <%= T("Students Eligible for Certificate", "Pelajar Layak untuk Sijil") %></div>
    <asp:Panel ID="pnlEligible" runat="server" Visible="false">
        <div class="sb-table-wrapper" style="border:none;border-radius:0;box-shadow:none;">
            <table class="sb-table">
                <thead><tr>
                    <th><%= T("Student", "Pelajar") %></th>
                    <th><%= T("Level", "Tahap") %></th>
                    <th><%= T("Action", "Tindakan") %></th>
                </tr></thead>
                <tbody>
                    <asp:Repeater ID="rptEligible" runat="server" OnItemCommand="rptEligible_ItemCommand">
                        <ItemTemplate>
                            <tr>
                                <td data-label="Student"><strong><%# HttpUtility.HtmlEncode(Eval("studentName")) %></strong></td>
                                <td data-label="Level"><span class="sb-badge sb-badge-success"><%# HttpUtility.HtmlEncode(Eval("levelName")) %></span></td>
                                <td class="col-actions">
                                    <asp:LinkButton ID="lnkGenerate" runat="server" CssClass="sb-btn sb-btn-success sb-btn-xs" CommandName="Generate"
                                        CommandArgument='<%# Eval("studentId") + "|" + Eval("levelId") + "|" + Eval("studentName") + "|" + Eval("levelName") + "|" + Eval("studentUserId") %>'
                                        OnClientClick="return confirm('Generate certificate?');">
                                        <i class="bi bi-plus-circle"></i> <%= T("Generate", "Jana") %>
                                    </asp:LinkButton>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlNoEligible" runat="server">
        <div class="ad-certificate-management-empty">
            <div class="ad-certificate-management-empty-ico"><i class="bi bi-person-check"></i></div>
            <div class="ad-certificate-management-empty-msg"><%= T("No eligible students at this time.", "Tiada pelajar layak pada masa ini.") %></div>
        </div>
    </asp:Panel>
</div>

<%-- CERTIFICATE PREVIEW MODAL --%>
<asp:Panel ID="pnlModal" runat="server" Visible="false" Cssclass="ad-certificate-management-modal-wrap">
<div class="sb-modal-overlay active" style="display:flex;">
    <div class="sb-modal" style="max-width:94vw;width:94vw;height:94vh;overflow:hidden;padding:var(--space-xs);display:flex;flex-direction:column;">

        <%-- Embedded certificate preview --%>
        <div style="border-radius:var(--border-radius-lg);overflow:auto;border:1.5px solid var(--border-color);flex:1;min-height:0;background:#EDE8E0;">
            <asp:Panel ID="pnlIframe" runat="server" Visible="false" style="width:100%;height:100%;">
                <asp:Literal ID="litIframe" runat="server" />
            </asp:Panel>
            <asp:Panel ID="pnlInlineCert" runat="server" Visible="true" style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;">
                <div style="text-align:center;color:var(--color-text-muted);padding:var(--space-xl);"><i class="bi bi-hourglass-split" style="font-size:2rem;opacity:.4;"></i><p style="margin-top:var(--space-sm);font-size:.875rem;"><%= T("Generating preview...", "Menjana pratonton...") %></p></div>
            </asp:Panel>
        </div>

        <%-- Action buttons --%>
        <div style="display:flex;align-items:center;justify-content:center;gap:var(--space-md);flex-wrap:wrap;padding:4px 0;flex-shrink:0;">
            <asp:Button ID="btnCloseModal" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnCloseModal_Click" />
            <asp:HyperLink ID="lnkDownload" runat="server" CssClass="sb-btn sb-btn-outline-primary sb-btn-sm" Target="_blank" Visible="false">
                <i class="bi bi-download"></i> <%= T("Download", "Muat Turun") %>
            </asp:HyperLink>
            <asp:LinkButton ID="btnModalSend" runat="server" CssClass="sb-btn sb-btn-primary sb-btn-sm"
                OnClick="btnModalSend_Click" OnClientClick="return confirm('Send this certificate?');"
                Visible="false">
                <i class="bi bi-send"></i> <%= T("Send Certificate", "Hantar Sijil") %>
            </asp:LinkButton>
        </div>

    </div>
</div>
</asp:Panel>
<asp:HiddenField ID="hfModalCertId" runat="server" />
<asp:HiddenField ID="hfModalStudentUserId" runat="server" />
<asp:HiddenField ID="hfModalStudentName" runat="server" />
<asp:HiddenField ID="hfModalLevelName" runat="server" />
<asp:HiddenField ID="hfCertUrl" runat="server" />

<%-- TOAST --%>
<asp:Panel ID="pnlToast" runat="server" Visible="false"><asp:Literal ID="litToast" runat="server" /></asp:Panel>

</asp:Content>
