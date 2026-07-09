<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EditDiscussion.aspx.cs"
    Inherits="ScienceBuddy.Parent.EditDiscussion" MasterPageFile="~/Site.Master"
    Title="Edit Discussion" MaintainScrollPositionOnPostback="true" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server"><link href="<%: ResolveUrl("~/Content/Parent.css") %>" rel="stylesheet" /></asp:Content>
<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div style="padding:10px 16px 6px; font-size:0.72rem; color:#94A3B8; text-transform:uppercase; letter-spacing:1px; font-weight:700;"><%: T("Viewing Child","Anak Dilihat") %></div>
    <div style="padding:0 16px 14px;"><asp:DropDownList ID="ddlSidebarChild2" runat="server" CssClass="sb-sidebar-child-ddl" /></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentDashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/ParentNotifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label"><%: T("Notifications","Notifikasi") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("My Children","Anak Saya") %></div>
        <a href="<%: ResolveUrl("~/Parent/LinkChildAccount.aspx") %>" class="sb-sidebar-item"><i class="bi bi-link-45deg item-icon"></i><span class="item-label"><%: T("Link Child Account","Paut Akaun Anak") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/ChildProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-badge item-icon"></i><span class="item-label"><%: T("Child Profile","Profil Anak") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/EnrolledModules.aspx") %>" class="sb-sidebar-item"><i class="bi bi-journal-bookmark item-icon"></i><span class="item-label"><%: T("Learning Journey","Perjalanan Pembelajaran") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Child Performance","Prestasi Anak") %></div>
        <a href="<%: ResolveUrl("~/Parent/ChildProgress.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bar-chart-line item-icon"></i><span class="item-label"><%: T("Current Progress","Kemajuan Semasa") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/QuizResults.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-check item-icon"></i><span class="item-label"><%: T("Quiz Results","Keputusan Kuiz") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Study Plan","Pelan Pembelajaran") %></div>
        <a href="<%: ResolveUrl("~/Parent/StudyPlan.aspx") %>" class="sb-sidebar-item"><i class="bi bi-journal-check item-icon"></i><span class="item-label"><%: T("Study Plan","Pelan Pembelajaran") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/EditStudyPlan.aspx") %>" class="sb-sidebar-item"><i class="bi bi-pencil-square item-icon"></i><span class="item-label"><%: T("Edit Study Plan","Edit Pelan Pembelajaran") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Discussions","Perbincangan") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentTeacherCommunication.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Chat with Teachers","Sembang dengan Guru") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/Forum.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-people item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Profile","Profil") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("My Profile","Profil Saya") %></span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Logout","Log Keluar") %></span></a></div>
</asp:Content>
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Edit Discussion","Edit Perbincangan") %></asp:Content>
<asp:Content ID="cBody" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="pd-page">
    <asp:Panel ID="pnlMessage" runat="server" Visible="false"><div class="pt-success-popup-overlay"><div class="pt-success-popup"><div class="pt-success-popup-icon"><i class="bi" id="iMsgIcon" runat="server"></i></div><div class="pt-success-popup-text" id="divMsg" runat="server"></div><asp:Button ID="btnCloseMsg" runat="server" Text="X" CssClass="pt-success-popup-close" OnClick="BtnCloseMsg_Click" CausesValidation="false" /></div></div></asp:Panel>
    <asp:Panel ID="pnlForm" runat="server" Visible="false">
        <div class="pt-study-plan-header"><div class="pt-study-plan-header-left"><h2 class="pt-study-plan-title"><i class="bi bi-pencil-square"></i> <%: T("Edit Discussion","Edit Perbincangan") %></h2></div>
            <a href="" id="lnkBack" runat="server" class="pt-btn soft"><i class="bi bi-arrow-left"></i> <%: T("Back","Kembali") %></a></div>
        <div class="pt-profile-section">
            <div class="pt-field"><label class="pt-label"><%: T("Discussion Type","Jenis Perbincangan") %></label>
                <asp:DropDownList ID="ddlType" runat="server" CssClass="pt-select"><asp:ListItem Value="Public" Text="Public" /><asp:ListItem Value="Private" Text="Student-Parent" /></asp:DropDownList></div>
            <div class="pt-field"><label class="pt-label"><%: T("Title","Tajuk") %></label><asp:TextBox ID="txtTitle" runat="server" CssClass="pt-input" MaxLength="200" /></div>
            <div class="pt-field"><label class="pt-label"><%: T("Message","Mesej") %></label><asp:TextBox ID="txtMessage" runat="server" CssClass="pt-input" TextMode="MultiLine" Rows="5" /></div>
            <div class="pt-field"><label class="pt-label"><%: T("Current Tags","Tag Semasa") %></label>
                <asp:Panel ID="pnlCurrentTags" runat="server" style="margin-bottom:8px;"></asp:Panel>
                <label class="pt-label" style="margin-top:10px;"><%: T("Add more tags (comma separated)","Tambah tag lain (dipisahkan koma)") %></label>
                <asp:TextBox ID="txtNewTags" runat="server" CssClass="pt-input" placeholder="e.g. Magnets, Homework" />
            </div>
            <asp:Button ID="btnSave" runat="server" CssClass="pt-btn primary" OnClick="BtnSave_Click" CausesValidation="false" />
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlDenied" runat="server" Visible="false"><div class="pd-empty"><i class="bi bi-shield-x"></i><p><%: T("You do not have permission to edit this discussion.","Anda tidak mempunyai kebenaran untuk mengedit perbincangan ini.") %></p></div></asp:Panel>
</div>
</asp:Content>
