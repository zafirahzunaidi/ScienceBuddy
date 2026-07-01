<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ParentProfile.aspx.cs"
    Inherits="ScienceBuddy.Parent.ParentProfile" MasterPageFile="~/Site.Master"
    Title="Parent Profile" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.pp-page { padding: 24px 0; max-width: 680px; margin: 0 auto; }
.pp-card {
    background: #fff;
    border-radius: 20px;
    box-shadow: 0 2px 16px rgba(0,0,0,0.05);
    padding: 32px 36px;
}
.pp-title {
    font-size: 1.2rem;
    font-weight: 800;
    color: #1E293B;
    margin: 0 0 4px;
    display: flex;
    align-items: center;
    gap: 8px;
}
.pp-title i { color: #2563EB; }
.pp-sub { font-size: 0.85rem; color: #64748B; margin-bottom: 24px; }
.pp-field { margin-bottom: 18px; }
.pp-label {
    display: block;
    font-size: 0.8rem;
    font-weight: 700;
    color: #334155;
    margin-bottom: 5px;
}
.pp-input {
    width: 100%;
    border: 1.5px solid #E2E8F0;
    border-radius: 10px;
    padding: 10px 14px;
    font-size: 0.9rem;
    color: #1E293B;
    transition: border-color 0.15s;
    box-sizing: border-box;
}
.pp-input:focus { border-color: #2563EB; outline: none; }
.pp-input[readonly] { background: #F8FAFC; color: #64748B; cursor: not-allowed; }
.pp-select {
    width: 100%;
    border: 1.5px solid #E2E8F0;
    border-radius: 10px;
    padding: 10px 14px;
    font-size: 0.9rem;
    color: #1E293B;
    background: #fff;
    appearance: auto;
}
.pp-select:focus { border-color: #2563EB; outline: none; }
.pp-actions { margin-top: 24px; display: flex; gap: 12px; }
.pp-btn {
    border: none;
    border-radius: 999px;
    padding: 10px 28px;
    font-size: 0.88rem;
    font-weight: 700;
    cursor: pointer;
    transition: background 0.15s, transform 0.1s;
}
.pp-btn:hover { transform: translateY(-1px); }
.pp-btn.primary { background: #2563EB; color: #fff; }
.pp-btn.primary:hover { background: #1D4ED8; }
.pp-msg {
    border-radius: 10px;
    padding: 12px 16px;
    margin-bottom: 18px;
    font-size: 0.85rem;
    font-weight: 500;
}
.pp-msg.success { background: #ECFDF5; color: #065F46; }
.pp-msg.error { background: #FEF2F2; color: #991B1B; }
</style>
</asp:Content>

<%-- ════ SIDEBAR (full Parent sidebar) ════ --%>
<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">

    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentDashboard.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-speedometer2 item-icon"></i>
            <span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span>
        </a>
    </div>

    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("My Children","Anak Saya") %></div>
        <a href="<%: ResolveUrl("~/Parent/LinkChildAccount.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-link-45deg item-icon"></i>
            <span class="item-label"><%: T("Link Child Account","Paut Akaun Anak") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/ChildProfile.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-person-badge item-icon"></i>
            <span class="item-label"><%: T("Child Profile","Profil Anak") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/EnrolledModules.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-journal-bookmark item-icon"></i>
            <span class="item-label"><%: T("Enrolled Modules","Modul Didaftarkan") %></span>
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
            <i class="bi bi-journal-pen item-icon"></i>
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
        <a href="<%: ResolveUrl("~/Parent/ParentProfile.aspx") %>" class="sb-sidebar-item active">
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

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Parent Profile","Profil Ibu Bapa") %></asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="pp-page">

    <asp:Panel ID="pnlMessage" runat="server" Visible="false">
        <div class="pp-msg" id="divMsg" runat="server"></div>
    </asp:Panel>

    <div class="pp-card">
        <div class="pp-title"><i class="bi bi-person-circle"></i> <asp:Literal ID="litTitle" runat="server" /></div>
        <div class="pp-sub"><asp:Literal ID="litSub" runat="server" /></div>

        <%-- Username (read-only) --%>
        <div class="pp-field">
            <label class="pp-label"><asp:Literal ID="litLblUsername" runat="server" /></label>
            <asp:TextBox ID="txtUsername" runat="server" CssClass="pp-input" ReadOnly="true" />
        </div>

        <%-- Name --%>
        <div class="pp-field">
            <label class="pp-label"><asp:Literal ID="litLblName" runat="server" /></label>
            <asp:TextBox ID="txtName" runat="server" CssClass="pp-input" MaxLength="150" />
        </div>

        <%-- Email --%>
        <div class="pp-field">
            <label class="pp-label"><asp:Literal ID="litLblEmail" runat="server" /></label>
            <asp:TextBox ID="txtEmail" runat="server" CssClass="pp-input" MaxLength="100" />
        </div>

        <%-- Phone --%>
        <div class="pp-field">
            <label class="pp-label"><asp:Literal ID="litLblPhone" runat="server" /></label>
            <asp:TextBox ID="txtPhone" runat="server" CssClass="pp-input" MaxLength="20" />
        </div>

        <%-- Preferred Language --%>
        <div class="pp-field">
            <label class="pp-label"><asp:Literal ID="litLblLang" runat="server" /></label>
            <asp:DropDownList ID="ddlLang" runat="server" CssClass="pp-select">
                <asp:ListItem Value="EN" Text="English" />
                <asp:ListItem Value="BM" Text="Bahasa Melayu" />
            </asp:DropDownList>
        </div>

        <div class="pp-actions">
            <asp:Button ID="btnSave" runat="server" CssClass="pp-btn primary"
                OnClick="BtnSave_Click" CausesValidation="false" />
        </div>
    </div>

</div>
</asp:Content>
