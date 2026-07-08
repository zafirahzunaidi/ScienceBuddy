<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LinkChildAccount.aspx.cs"
    Inherits="ScienceBuddy.Parent.LinkChildAccount" MasterPageFile="~/Site.Master"
    Title="Link Child Account" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Parent.css") %>" rel="stylesheet" />
</asp:Content>

<%-- ════ SIDEBAR (full Parent sidebar) ════ --%>
<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <%-- Child Switcher --%>
    <div style="padding:10px 16px 6px; font-size:0.72rem; color:#94A3B8; text-transform:uppercase; letter-spacing:1px; font-weight:700;">
        <%: T("Viewing Child","Anak Dilihat") %>
    </div>
    <div style="padding:0 16px 14px;">
        <asp:DropDownList ID="ddlSidebarChild" runat="server"
            AutoPostBack="true" OnSelectedIndexChanged="SidebarChildChanged"
            style="width:100%;border:1.5px solid #E2E8F0;border-radius:10px;padding:8px 12px;font-size:0.82rem;font-weight:600;color:#1D4ED8;background:#EFF6FF;" />
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentDashboard.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-speedometer2 item-icon"></i>
            <span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("My Children","Anak Saya") %></div>
        <a href="<%: ResolveUrl("~/Parent/LinkChildAccount.aspx") %>" class="sb-sidebar-item active">
            <i class="bi bi-link-45deg item-icon"></i>
            <span class="item-label"><%: T("Link Child Account","Paut Akaun Anak") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/ChildProfile.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-person-badge item-icon"></i>
            <span class="item-label"><%: T("Child Profile","Profil Anak") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/EnrolledModules.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-journal-bookmark item-icon"></i>
            <span class="item-label"><%: T("Learning Journey","Perjalanan Pembelajaran") %></span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Child Performance","Prestasi Anak") %></div>
        <a href="<%: ResolveUrl("~/Parent/ChildProgress.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-bar-chart-line item-icon"></i>
            <span class="item-label"><%: T("Current Progress","Kemajuan Semasa") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/QuizResults.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-patch-check item-icon"></i>
            <span class="item-label"><%: T("Quiz Results","Keputusan Kuiz") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/ReportCard.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-file-earmark-bar-graph item-icon"></i>
            <span class="item-label"><%: T("Report Card","Kad Laporan") %></span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Study Plan","Pelan Pembelajaran") %></div>
        <a href="<%: ResolveUrl("~/Parent/StudyPlan.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-journal-check item-icon"></i>
            <span class="item-label"><%: T("Study Plan","Pelan Pembelajaran") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/EditStudyPlan.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-pencil-square item-icon"></i>
            <span class="item-label"><%: T("Edit Study Plan","Edit Pelan Pembelajaran") %></span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Discussions","Perbincangan") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentTeacherCommunication.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-chat-dots item-icon"></i>
            <span class="item-label"><%: T("Chat with Teachers","Sembang dengan Guru") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/Forum.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-people item-icon"></i>
            <span class="item-label"><%: T("Forum","Forum") %></span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Notifications","Notifikasi") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentNotifications.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-bell item-icon"></i>
            <span class="item-label"><%: T("Notifications","Notifikasi") %></span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Profile","Profil") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentProfile.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-person item-icon"></i>
            <span class="item-label"><%: T("Edit Profile","Edit Profil") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/AccountSettings.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-gear item-icon"></i>
            <span class="item-label"><%: T("Account Settings","Tetapan Akaun") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-box-arrow-right item-icon"></i>
            <span class="item-label"><%: T("Logout","Log Keluar") %></span>
        </a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Link Child Account","Paut Akaun Anak") %></asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="lc-page">

    <asp:Panel ID="pnlMessage" runat="server" Visible="false">
        <div class="lc-msg" id="divMsg" runat="server"></div>
    </asp:Panel>

    <%-- Link form --%>
    <div class="lc-card">
        <div class="lc-title"><i class="bi bi-link-45deg"></i> <asp:Literal ID="litTitle" runat="server" /></div>
        <div class="lc-sub"><asp:Literal ID="litSub" runat="server" /></div>

        <div class="lc-field">
            <label class="lc-label"><asp:Literal ID="litLblCode" runat="server" /></label>
            <asp:TextBox ID="txtCode" runat="server" CssClass="lc-input" MaxLength="20" placeholder="e.g. RAY468" />
        </div>

        <div class="lc-field">
            <label class="lc-label"><asp:Literal ID="litLblRelationship" runat="server" /></label>
            <asp:DropDownList ID="ddlRelationship" runat="server" CssClass="lc-select">
                <asp:ListItem Value="Mother" />
                <asp:ListItem Value="Father" />
                <asp:ListItem Value="Guardian" />
            </asp:DropDownList>
        </div>

        <asp:Button ID="btnLink" runat="server" CssClass="lc-btn"
            OnClick="BtnLink_Click" CausesValidation="false" />
    </div>

    <%-- Linked children list --%>
    <div class="lc-card">
        <div class="lc-list-title"><i class="bi bi-people-fill"></i> <asp:Literal ID="litLinkedTitle" runat="server" /></div>
        <asp:Panel ID="pnlLinkedList" runat="server"></asp:Panel>
        <asp:Panel ID="pnlNoLinked" runat="server" Visible="false">
            <div class="lc-empty">
                <i class="bi bi-person-x"></i>
                <asp:Literal ID="litNoLinked" runat="server" />
            </div>
        </asp:Panel>
    </div>

    <%-- Hidden field for unlink target --%>
    <asp:HiddenField ID="hidUnlinkArg" runat="server" />

    <%-- Unlink Confirmation Modal --%>
    <asp:Panel ID="pnlUnlinkModal" runat="server" Visible="false">
        <div class="lc-modal-overlay">
            <div class="lc-modal-card">
                <div class="lc-modal-icon">
                    <i class="bi bi-exclamation-triangle-fill"></i>
                </div>
                <div class="lc-modal-title"><asp:Literal ID="litModalTitle" runat="server" /></div>
                <div class="lc-modal-msg"><asp:Literal ID="litModalMsg" runat="server" /></div>
                <div class="lc-modal-actions">
                    <asp:Button ID="btnCancelUnlink" runat="server" CssClass="lc-modal-btn cancel"
                        OnClick="BtnCancelUnlink_Click" CausesValidation="false" />
                    <asp:Button ID="btnConfirmUnlink" runat="server" CssClass="lc-modal-btn danger"
                        OnClick="BtnConfirmUnlink_Click" CausesValidation="false" />
                </div>
            </div>
        </div>
    </asp:Panel>

</div>
</asp:Content>
