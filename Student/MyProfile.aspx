<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MyProfile.aspx.cs"
    Inherits="ScienceBuddy.Student.MyProfile1" MasterPageFile="~/Site.Master"
    Title="My Profile" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Student.css") %>" rel="stylesheet" />
</asp:Content>

<%-- ════ SIDEBAR ════ --%>
<asp:Content ID="cSidebarMenu" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Main</div>
        <a href="<%: ResolveUrl("~/Student/Dashboard.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-speedometer2 item-icon"></i><span class="item-label">Dashboard</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/Notifications.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Learn</div>
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-book item-icon"></i><span class="item-label">My Learning</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/PracticeLibrary.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-patch-question item-icon"></i><span class="item-label">Practice Library</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/QuizHistory.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-clock-history item-icon"></i><span class="item-label">Quiz History</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/VirtualLabs.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-eyedropper item-icon"></i><span class="item-label">Virtual Labs</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/LiveSessions.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-camera-video item-icon"></i><span class="item-label">Live Sessions</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/AIStudyCompanion.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-robot item-icon"></i><span class="item-label">AI Study Companion</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Communication</div>
        <a href="<%: ResolveUrl("~/Student/Messages.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-chat-dots item-icon"></i><span class="item-label">Messages</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/Forum.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-people item-icon"></i><span class="item-label">Forum</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Progress</div>
        <a href="<%: ResolveUrl("~/Student/ProgressRewards.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-bar-chart-line item-icon"></i><span class="item-label">Progress &amp; Rewards</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/MyRanking.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-trophy item-icon"></i><span class="item-label">My Ranking</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Student/MyProfile.aspx") %>" class="sb-sidebar-item active">
            <i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span>
        </a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <asp:Literal ID="litPageTitle" runat="server" Text="My Profile" />
</asp:Content>

<%-- ════ MAIN CONTENT ════ --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- ── HERO CARD ── --%>
<div class="st-profile-hero">
    <div class="st-profile-hero-avatar"><asp:Literal ID="litHeroInitial" runat="server" Text="S" /></div>
    <div class="st-profile-hero-info">
        <div class="st-profile-hero-name"><asp:Literal ID="litHeroName" runat="server" Text="Student" /></div>
        <div class="st-profile-hero-role"><i class="bi bi-mortarboard-fill"></i> <asp:Literal ID="litHeroRole" runat="server" Text="Student" /></div>
        <div class="st-profile-hero-chips">
            <span class="st-profile-hero-chip"><i class="bi bi-bar-chart-fill"></i> <asp:Literal ID="litLevelLbl" runat="server" Text="Current Level" />: <asp:Literal ID="litHeroLevel" runat="server" Text="&#x2014;" /></span>
            <span class="st-profile-hero-chip"><i class="bi bi-stars"></i> <asp:Literal ID="litHeroPersonality" runat="server" Text="&#x2014;" /></span>
            <span class="st-profile-hero-chip xp"><i class="bi bi-lightning-charge-fill"></i> <asp:Literal ID="litXPLbl" runat="server" Text="Total XP" />: <asp:Literal ID="litHeroXP" runat="server" Text="0 XP" /></span>
            <span class="st-profile-hero-chip"><i class="bi bi-people-fill"></i> <asp:Literal ID="litParentCodeLbl" runat="server" Text="Parent Code" />: <asp:Literal ID="litHeroParentCode" runat="server" Text="&#x2014;" /></span>
        </div>
    </div>
</div>

<%-- ── PERSONAL INFORMATION FORM ── --%>
<div class="st-profile-form">
    <div class="st-profile-form-title"><i class="bi bi-person-lines-fill"></i> <asp:Literal ID="litPersonalTitle" runat="server" Text="Personal Information" /></div>
    <div class="st-profile-form-grid">
        <div class="st-profile-field">
            <label><asp:Literal ID="litUsernameLbl" runat="server" Text="Username" /></label>
            <asp:TextBox ID="txtUsername" runat="server" CssClass="st-profile-input" Enabled="false" ReadOnly="true" />
        </div>
        <div class="st-profile-field">
            <label><asp:Literal ID="litNameLbl" runat="server" Text="Name" /></label>
            <asp:TextBox ID="txtName" runat="server" CssClass="st-profile-input" />
        </div>
        <div class="st-profile-field">
            <label><asp:Literal ID="litNicknameLbl" runat="server" Text="Nickname" /></label>
            <asp:TextBox ID="txtNickname" runat="server" CssClass="st-profile-input" />
        </div>
        <div class="st-profile-field">
            <label><asp:Literal ID="litPhoneLbl" runat="server" Text="Phone Number" /></label>
            <asp:TextBox ID="txtPhone" runat="server" CssClass="st-profile-input" />
        </div>
        <div class="st-profile-field">
            <label><asp:Literal ID="litEmailLbl" runat="server" Text="Email" /></label>
            <asp:TextBox ID="txtEmail" runat="server" CssClass="st-profile-input" TextMode="Email" />
        </div>
    </div>
</div>

<%-- ── LANGUAGE PREFERENCE ── --%>
<div class="st-profile-lang">
    <div class="st-profile-lang-title"><i class="bi bi-translate"></i> <asp:Literal ID="litLangTitle" runat="server" Text="Language Preference" /></div>
    <div class="st-profile-field" style="max-width:320px;">
        <label><asp:Literal ID="litLangLbl" runat="server" Text="Language Preference" /></label>
        <asp:DropDownList ID="ddlLanguage" runat="server" CssClass="st-profile-input">
            <asp:ListItem Value="EN" Text="English" />
            <asp:ListItem Value="BM" Text="Bahasa Melayu" />
        </asp:DropDownList>
    </div>
</div>

<%-- ── PERSONALITY SECTION ── --%>
<div class="st-profile-personality">
    <div class="st-profile-personality-title"><i class="bi bi-puzzle-fill"></i> <asp:Literal ID="litPersonalityTitle" runat="server" Text="Personality" /></div>
    <div class="st-profile-pers-card">
        <div class="st-profile-pers-avatar">
            <asp:Literal ID="litPersAvatarFallback" runat="server" Text="&#x1F9E0;" />
        </div>
        <div class="st-profile-pers-body">
            <div class="st-profile-pers-name"><asp:Literal ID="litPersName" runat="server" Text="&#x2014;" /></div>
            <div class="st-profile-pers-desc"><asp:Literal ID="litPersDesc" runat="server" Text="&#x2014;" /></div>
            <div class="st-profile-pers-style"><asp:Literal ID="litPersStyleLbl" runat="server" Text="Learning Style" />: <asp:Literal ID="litPersStyle" runat="server" Text="&#x2014;" /></div>
            <a href="<%: ResolveUrl("~/Student/PersonalityTest.aspx") %>" class="st-profile-pers-retake" style="text-decoration:none;color:var(--color-primary);cursor:pointer;"><i class="bi bi-arrow-repeat"></i> <asp:Literal ID="litRetakeBtn" runat="server" Text="Retake Personality Test" /></a>
            <asp:Literal ID="litComingSoon" runat="server" Visible="false" />
        </div>
    </div>
</div>

<%-- ── ACCOUNT STATUS ── --%>
<div class="st-profile-status">
    <div class="st-profile-status-title"><i class="bi bi-shield-check"></i> <asp:Literal ID="litStatusTitle" runat="server" Text="Account Status" /></div>
    <div class="st-profile-status-grid">
        <div class="st-profile-status-item">
            <label><asp:Literal ID="litStatusRoleLbl" runat="server" Text="Role" /></label>
            <span><asp:Literal ID="litStatusRole" runat="server" Text="&#x2014;" /></span>
        </div>
        <div class="st-profile-status-item">
            <label><asp:Literal ID="litStatusStatusLbl" runat="server" Text="Status" /></label>
            <span><asp:Literal ID="litStatusStatus" runat="server" Text="&#x2014;" /></span>
        </div>
        <div class="st-profile-status-item">
            <label><asp:Literal ID="litStatusLangLbl" runat="server" Text="Language" /></label>
            <span><asp:Literal ID="litStatusLang" runat="server" Text="&#x2014;" /></span>
        </div>
    </div>
</div>

<%-- ── SAVE BUTTON & ALERTS ── --%>
<div class="st-profile-save-area">
    <asp:Button ID="btnSave" runat="server" CssClass="st-profile-btn-save" Text="Save Changes" OnClick="btnSave_Click" />
    <asp:Literal ID="litSaveBtn" runat="server" Visible="false" />
    <asp:Panel ID="pnlSuccess" runat="server" Visible="false" CssClass="st-profile-alert-success">
        <i class="bi bi-check-circle-fill"></i> <asp:Literal ID="litSuccess" runat="server" Text="Profile updated successfully." />
    </asp:Panel>
    <asp:Panel ID="pnlSaveError" runat="server" Visible="false" CssClass="st-profile-alert-error">
        <i class="bi bi-exclamation-triangle-fill"></i> <asp:Literal ID="litSaveError" runat="server" Text="Please fill in all required fields." />
    </asp:Panel>
</div>

</asp:Content>
