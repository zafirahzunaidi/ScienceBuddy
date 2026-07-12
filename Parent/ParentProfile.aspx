<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ParentProfile.aspx.cs"
    Inherits="ScienceBuddy.Parent.ParentProfile" MasterPageFile="~/Site.Master"
    Title="Parent Profile" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Parent.css") %>?v=4" rel="stylesheet" />
<script type="text/javascript">
function toggleChildPopover(e){e.stopPropagation();var pop=document.getElementById('divChildPopover');if(!pop)return;if(pop.classList.contains('pt-popover-open')){pop.classList.remove('pt-popover-open');return;}var ddl=document.querySelector('.sb-sidebar-child-ddl');if(!ddl)return;var html='<div class="pt-child-popover-title">Select Child</div>';for(var i=0;i<ddl.options.length;i++){var o=ddl.options[i];var init=o.text.charAt(0).toUpperCase();var ac=o.selected?' pt-popover-active':'';html+='<div class="pt-child-popover-item'+ac+'" onclick="selectChildFromPopover(\''+o.value+'\')"><span class="pt-popover-avatar">'+init+'</span>'+o.text+'</div>';}pop.innerHTML=html;pop.classList.add('pt-popover-open');}
function selectChildFromPopover(v){var ddl=document.querySelector('.sb-sidebar-child-ddl');if(ddl&&ddl.value!==v){ddl.value=v;__doPostBack(ddl.id.replace(/_/g,'$'),'');}var pop=document.getElementById('divChildPopover');if(pop)pop.classList.remove('pt-popover-open');}
document.addEventListener('DOMContentLoaded',function(){var ddl=document.querySelector('.sb-sidebar-child-ddl');var btn=document.querySelector('.pt-child-compact-btn');if(ddl&&btn&&ddl.options.length>0){btn.textContent=ddl.options[ddl.selectedIndex].text.charAt(0).toUpperCase();}});
document.addEventListener('click',function(e){var pop=document.getElementById('divChildPopover');if(pop&&!e.target.closest('.pt-child-selector-compact')){pop.classList.remove('pt-popover-open');}});
</script>
</asp:Content>

<%-- ════ SIDEBAR ════ --%>
<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="pt-child-selector">
        <div class="pt-child-selector-label"><%: T("Viewing Child","Anak Dilihat") %></div>
        <div class="pt-child-selector-full"><asp:DropDownList ID="ddlSidebarChild" runat="server" AutoPostBack="true" OnSelectedIndexChanged="SidebarChildChanged" CssClass="sb-sidebar-child-ddl" /></div>
        <div class="pt-child-selector-compact"><button type="button" class="pt-child-compact-btn" onclick="toggleChildPopover(event);"></button><div class="pt-child-popover" id="divChildPopover"></div></div>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentDashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/ParentNotifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label"><%: T("Notifications","Notifikasi") %></span><asp:Literal ID="litUnreadBadge" runat="server" /></a></div>
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
        <a href="<%: ResolveUrl("~/Parent/Forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-people item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Profile","Profil") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentProfile.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("My Profile","Profil Saya") %></span></a>        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Logout","Log Keluar") %></span></a></div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("My Profile","Profil Saya") %></asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="pd-page">

    <%-- Success/Error Popup --%>
    <asp:Panel ID="pnlMessage" runat="server" Visible="false">
        <div class="pt-success-popup-overlay"><div class="pt-success-popup">
            <div class="pt-success-popup-icon"><i class="bi" id="iMsgIcon" runat="server"></i></div>
            <div class="pt-success-popup-text" id="divMsg" runat="server"></div>
            <asp:Button ID="btnCloseMsg" runat="server" Text="X" CssClass="pt-success-popup-close" OnClick="BtnCloseMsg_Click" CausesValidation="false" />
        </div></div>
    </asp:Panel>

    <%-- ══ HERO CARD ══ --%>
    <div class="pt-profile-hero-card">
        <div class="pt-profile-hero-avatar"><asp:Literal ID="litInitials" runat="server" /></div>
        <div class="pt-profile-hero-info">
            <div class="pt-profile-hero-name"><asp:Literal ID="litHeroName" runat="server" /></div>
            <div class="pt-profile-hero-role"><i class="bi bi-person-heart"></i> <%: T("Parent","Ibu Bapa") %></div>
            <div class="pt-profile-hero-chips">
                <span class="pt-profile-hero-chip"><i class="bi bi-people-fill"></i> <asp:Literal ID="litChildrenCount" runat="server" /></span>
                <span class="pt-profile-hero-chip"><i class="bi bi-envelope-fill"></i> <asp:Literal ID="litHeroEmail" runat="server" /></span>
            </div>
        </div>
    </div>

    <%-- ══ PERSONAL INFORMATION ══ --%>
    <div class="pt-profile-section">
        <div class="pt-profile-section-title"><i class="bi bi-person-lines-fill"></i> <%: T("Personal Information","Maklumat Peribadi") %></div>
        <div class="pt-profile-form-grid">
            <div class="pt-field">
                <label class="pt-label"><%: T("Username","Nama Pengguna") %></label>
                <asp:TextBox ID="txtUsername" runat="server" CssClass="pt-input" ReadOnly="true" />
            </div>
            <div class="pt-field">
                <label class="pt-label"><%: T("Full Name","Nama Penuh") %></label>
                <asp:TextBox ID="txtName" runat="server" CssClass="pt-input" MaxLength="100" />
            </div>
            <div class="pt-field">
                <label class="pt-label"><%: T("Email","E-mel") %></label>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="pt-input" MaxLength="100" TextMode="Email" />
            </div>
            <div class="pt-field">
                <label class="pt-label"><%: T("Phone Number","Nombor Telefon") %></label>
                <asp:TextBox ID="txtPhone" runat="server" CssClass="pt-input" MaxLength="20" />
            </div>
        </div>
    </div>

    <%-- ══ LANGUAGE PREFERENCE ══ --%>
    <div class="pt-profile-section">
        <div class="pt-profile-section-title"><i class="bi bi-translate"></i> <%: T("Language Preference","Pilihan Bahasa") %></div>
        <div class="pt-field" style="max-width:300px;">
            <label class="pt-label"><%: T("Preferred Language","Bahasa Pilihan") %></label>
            <asp:DropDownList ID="ddlLang" runat="server" CssClass="pt-select">
                <asp:ListItem Value="EN" Text="English" />
                <asp:ListItem Value="BM" Text="Bahasa Melayu" />
            </asp:DropDownList>
        </div>
    </div>

    <%-- ══ CHANGE PASSWORD ══ --%>
    <div class="pt-profile-section">
        <div class="pt-profile-section-title"><i class="bi bi-shield-lock-fill"></i> <%: T("Change Password","Tukar Kata Laluan") %></div>
        <div class="pt-profile-form-grid">
            <div class="pt-field">
                <label class="pt-label"><%: T("Current Password","Kata Laluan Semasa") %></label>
                <asp:TextBox ID="txtCurrentPwd" runat="server" CssClass="pt-input" TextMode="Password" MaxLength="50" />
            </div>
            <div class="pt-field">
                <label class="pt-label"><%: T("New Password","Kata Laluan Baharu") %></label>
                <asp:TextBox ID="txtNewPwd" runat="server" CssClass="pt-input" TextMode="Password" MaxLength="50" />
            </div>
            <div class="pt-field">
                <label class="pt-label"><%: T("Confirm New Password","Sahkan Kata Laluan Baharu") %></label>
                <asp:TextBox ID="txtConfirmPwd" runat="server" CssClass="pt-input" TextMode="Password" MaxLength="50" />
            </div>
        </div>
        <asp:Button ID="btnChangePwd" runat="server" CssClass="pt-btn soft" style="margin-top:12px;"
            OnClick="BtnChangePwd_Click" CausesValidation="false" />
    </div>

    <%-- ══ ACCOUNT STATUS ══ --%>
    <div class="pt-profile-section">
        <div class="pt-profile-section-title"><i class="bi bi-shield-check"></i> <%: T("Account Status","Status Akaun") %></div>
        <div class="pt-profile-status-grid">
            <div class="pt-profile-status-item">
                <span class="pt-profile-status-label"><%: T("Role","Peranan") %></span>
                <span class="pt-profile-status-value"><asp:Literal ID="litStatusRole" runat="server" /></span>
            </div>
            <div class="pt-profile-status-item">
                <span class="pt-profile-status-label"><%: T("Account Status","Status Akaun") %></span>
                <span class="pt-profile-status-value"><asp:Literal ID="litStatusStatus" runat="server" /></span>
            </div>
            <div class="pt-profile-status-item">
                <span class="pt-profile-status-label"><%: T("Language","Bahasa") %></span>
                <span class="pt-profile-status-value"><asp:Literal ID="litStatusLang" runat="server" /></span>
            </div>
        </div>
    </div>

    <%-- ══ SAVE BUTTON ══ --%>
    <div style="margin-top:20px;">
        <asp:Button ID="btnSave" runat="server" CssClass="pt-btn primary" OnClick="BtnSave_Click" CausesValidation="false" />
    </div>

</div>
</asp:Content>
