<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CertificateManagement.aspx.cs"
    Inherits="ScienceBuddy.Admin.CertificateManagement" MasterPageFile="~/Site.Master"
    Title="Certificate Management" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--cm-accent:#2563EB;--cm-green:#059669;--cm-purple:#7C3AED;--cm-orange:#D97706;}
.cm-header{margin-bottom:var(--space-xl);padding-bottom:var(--space-md);border-bottom:1.5px solid var(--border-color);}
.cm-title{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;color:var(--color-text);margin-bottom:var(--space-xs);}
.cm-sub{font-size:.9375rem;color:var(--color-text-secondary);max-width:520px;line-height:1.5;}
.cm-stats{display:grid;grid-template-columns:repeat(4,1fr);gap:var(--space-md);margin-bottom:var(--space-xl);}
.cm-stat{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);padding:var(--space-lg);display:flex;flex-direction:column;gap:var(--space-xs);transition:transform .25s,box-shadow .25s;position:relative;overflow:hidden;}
.cm-stat:hover{transform:translateY(-3px);box-shadow:var(--shadow-md);}
.cm-stat::before{content:'';position:absolute;top:0;left:0;right:0;height:3px;}
.cm-stat.s1::before{background:linear-gradient(90deg,#2563EB,#60A5FA);}.cm-stat.s2::before{background:linear-gradient(90deg,#059669,#34D399);}.cm-stat.s3::before{background:linear-gradient(90deg,#7C3AED,#A78BFA);}.cm-stat.s4::before{background:linear-gradient(90deg,#D97706,#FBBF24);}
.cm-stat-ico{font-size:1.25rem;}.cm-stat-val{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;color:var(--color-text);}.cm-stat-lbl{font-size:.75rem;color:var(--color-text-muted);font-weight:600;}
.cm-card{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);overflow:hidden;margin-bottom:var(--space-xl);}
.cm-card-hdr{padding:var(--space-md) var(--space-lg);border-bottom:1px solid var(--border-color);font-family:var(--font-primary);font-weight:800;font-size:.9375rem;display:flex;align-items:center;gap:var(--space-sm);}
.cm-actions{display:flex;gap:var(--space-xs);flex-wrap:wrap;}
.cm-empty{display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;padding:var(--space-2xl);}
.cm-empty-ico{font-size:3rem;margin-bottom:var(--space-md);opacity:.35;color:var(--cm-accent);}.cm-empty-msg{font-size:1rem;font-weight:700;color:var(--color-text-secondary);}
/* Modal fix */
.cm-modal-wrap .sb-modal-overlay{left:var(--sidebar-width);animation:cm-ovIn .2s ease both;}.sidebar-collapsed .cm-modal-wrap .sb-modal-overlay{left:var(--sidebar-collapsed);}
.cm-modal-wrap .sb-modal{animation:cm-mdIn .3s cubic-bezier(.34,1.56,.64,1) both;max-width:520px;max-height:90vh;overflow-y:auto;}
@keyframes cm-ovIn{from{opacity:0;}to{opacity:1;}}@keyframes cm-mdIn{from{opacity:0;transform:scale(.92) translateY(16px);}to{opacity:1;transform:scale(1) translateY(0);}}
.cm-modal-hdr{background:linear-gradient(135deg,#2563EB,#3B82F6);padding:var(--space-lg) var(--space-xl);color:#fff;border-radius:var(--border-radius-xl) var(--border-radius-xl) 0 0;}
.cm-modal-hdr-title{font-family:var(--font-primary);font-size:1.125rem;font-weight:800;display:flex;align-items:center;gap:var(--space-sm);}
.cm-modal-body{padding:var(--space-xl);}
.cm-field{margin-bottom:var(--space-md);}.cm-label{font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;}.cm-value{font-size:.9375rem;font-weight:600;color:var(--color-text);}
@media(max-width:1279px){.cm-stats{grid-template-columns:repeat(2,1fr);}}
@media(max-width:767px){.cm-stats{grid-template-columns:1fr 1fr;}.cm-actions{flex-direction:column;}.cm-modal-wrap .sb-modal-overlay{left:0;}}

/* Certificate Preview */
.cert-preview{background:linear-gradient(135deg,#FFFEF7 0%,#FDF8F0 50%,#FFF9E6 100%);border:3px solid #C8A96E;border-radius:6px;padding:36px 48px;position:relative;overflow:hidden;box-shadow:inset 0 0 60px rgba(200,169,110,.05);aspect-ratio:1.414/1;display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;max-width:100%;}
.cert-preview::before{content:'';position:absolute;inset:10px;border:1.5px solid #D4B88C;border-radius:4px;pointer-events:none;}
.cert-preview::after{content:'SCIENCEBUDDY';position:absolute;font-size:80px;font-weight:900;color:rgba(37,99,235,.02);letter-spacing:12px;pointer-events:none;z-index:0;}
.cert-logo{width:52px;height:52px;margin-bottom:8px;opacity:.85;}
.cert-brand{font-family:Arial,sans-serif;font-size:16px;font-weight:900;letter-spacing:1px;margin-bottom:8px;}.cert-brand-sci{color:#2563EB;}.cert-brand-buddy{color:#FF6B2C;}
.cert-heading{font-family:'Georgia',serif;font-size:1.5rem;font-weight:700;color:#1D4ED8;letter-spacing:3px;text-transform:uppercase;margin-bottom:6px;}
.cert-presented{font-size:.8125rem;color:#64748B;font-style:italic;margin-bottom:12px;}
.cert-student-name{font-family:'Georgia',serif;font-size:1.75rem;font-weight:700;color:#0F172A;letter-spacing:1px;margin-bottom:4px;}
.cert-gold-divider{width:160px;height:2px;background:linear-gradient(90deg,transparent,#C8A96E,transparent);margin:6px auto 12px;}
.cert-for{font-size:.8125rem;color:#64748B;margin-bottom:6px;}
.cert-level{display:inline-block;padding:5px 24px;border-radius:4px;font-size:.75rem;font-weight:700;letter-spacing:2px;text-transform:uppercase;color:#fff;background:#2563EB;margin-bottom:10px;}
.cert-desc{font-size:.75rem;color:#475569;max-width:380px;line-height:1.6;margin-bottom:16px;}
.cert-footer{display:flex;align-items:flex-end;justify-content:space-between;width:100%;margin-top:auto;padding-top:12px;border-top:1px solid #E2E8F0;}
.cert-footer-col{text-align:center;font-size:.6rem;color:#64748B;min-width:80px;}
.cert-footer-col strong{display:block;font-size:.75rem;color:#1E293B;margin-bottom:1px;}
.cert-seal{width:48px;height:48px;border-radius:50%;border:2.5px solid #C8A96E;background:linear-gradient(135deg,#1D4ED8,#2563EB);display:flex;align-items:center;justify-content:center;color:#fff;font-size:1.125rem;box-shadow:0 0 0 2px #fff,0 0 0 4px #C8A96E;}
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
        <a href="<%: ResolveUrl("~/Admin/CertificateManagement.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-award item-icon"></i><span class="item-label">Certificates</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Gamification</div>
        <a href="<%: ResolveUrl("~/Admin/GamificationManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-trophy item-icon"></i><span class="item-label">Student Performance</span></a>
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

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%= T("Certificate Management", "Pengurusan Sijil") %></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<div class="cm-header">
    <h1 class="cm-title"><%= T("Certificate Management", "Pengurusan Sijil") %></h1>
    <p class="cm-sub"><%= T("Automatically generate and issue level completion certificates.", "Menjana dan mengeluarkan sijil tamat tahap secara automatik.") %></p>
</div>

<div class="cm-stats">
    <div class="cm-stat s1"><div class="cm-stat-ico" style="color:#2563EB;"><i class="bi bi-file-earmark-check"></i></div><div class="cm-stat-val"><asp:Literal ID="litReady" runat="server" Text="0" /></div><div class="cm-stat-lbl"><%= T("Ready to Generate", "Sedia Dijana") %></div></div>
    <div class="cm-stat s2"><div class="cm-stat-ico" style="color:#059669;"><i class="bi bi-award-fill"></i></div><div class="cm-stat-val"><asp:Literal ID="litGenerated" runat="server" Text="0" /></div><div class="cm-stat-lbl"><%= T("Generated", "Dijana") %></div></div>
    <div class="cm-stat s3"><div class="cm-stat-ico" style="color:#7C3AED;"><i class="bi bi-send-fill"></i></div><div class="cm-stat-val"><asp:Literal ID="litSent" runat="server" Text="0" /></div><div class="cm-stat-lbl"><%= T("Sent", "Dihantar") %></div></div>
    <div class="cm-stat s4"><div class="cm-stat-ico" style="color:#D97706;"><i class="bi bi-collection-fill"></i></div><div class="cm-stat-val"><asp:Literal ID="litTotal" runat="server" Text="0" /></div><div class="cm-stat-lbl"><%= T("Total Certificates", "Jumlah Sijil") %></div></div>
</div>

<%-- CERTIFICATES TABLE --%>
<div class="cm-card">
    <div class="cm-card-hdr"><i class="bi bi-award" style="color:var(--cm-accent);"></i> <%= T("All Certificates", "Semua Sijil") %></div>
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
                                    <div class="cm-actions">
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
        <div class="cm-empty">
            <div class="cm-empty-ico"><i class="bi bi-award"></i></div>
            <div class="cm-empty-msg"><%= T("No certificates found.", "Tiada sijil dijumpai.") %></div>
        </div>
    </asp:Panel>
</div>

<%-- ELIGIBLE STUDENTS (no cert yet) --%>
<div class="cm-card">
    <div class="cm-card-hdr"><i class="bi bi-person-check" style="color:#059669;"></i> <%= T("Students Eligible for Certificate", "Pelajar Layak untuk Sijil") %></div>
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
        <div class="cm-empty">
            <div class="cm-empty-ico"><i class="bi bi-person-check"></i></div>
            <div class="cm-empty-msg"><%= T("No eligible students at this time.", "Tiada pelajar layak pada masa ini.") %></div>
        </div>
    </asp:Panel>
</div>

<%-- CERTIFICATE PREVIEW MODAL --%>
<asp:Panel ID="pnlModal" runat="server" Visible="false" CssClass="cm-modal-wrap">
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
