<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MyProfile.aspx.cs"
    Inherits="ScienceBuddy.Student.MyProfile" MasterPageFile="~/Site.Master"
    Title="My Profile" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ── Student My Profile ── */
:root{--mp-orange:#FF6B2C;--mp-orange-light:#FFF0E8;--mp-orange-dark:#E85B1D;--mp-orange-mid:#FF8C54;}

/* ══ HERO CARD ══ */
.mp-hero{
    background:linear-gradient(135deg,var(--mp-orange) 0%,var(--mp-orange-mid) 50%,#FFD84D 100%);
    border-radius:var(--border-radius-xl);padding:var(--space-2xl);
    color:#fff;display:flex;align-items:center;gap:var(--space-xl);
    position:relative;overflow:hidden;margin-bottom:var(--space-xl);
    box-shadow:0 12px 40px rgba(255,107,44,.25);
}
.mp-hero::before{content:'';position:absolute;width:300px;height:300px;border-radius:50%;
    background:rgba(255,255,255,.08);top:-80px;right:-60px;pointer-events:none;}
.mp-hero::after{content:'';position:absolute;width:180px;height:180px;border-radius:50%;
    background:rgba(255,255,255,.06);bottom:-50px;left:40px;pointer-events:none;}
.mp-hero-avatar{width:100px;height:100px;border-radius:50%;
    background:rgba(255,255,255,.2);border:4px solid rgba(255,255,255,.5);
    display:flex;align-items:center;justify-content:center;font-size:2.5rem;
    font-weight:800;color:#fff;flex-shrink:0;position:relative;z-index:1;
    text-transform:uppercase;}
.mp-hero-info{flex:1;position:relative;z-index:1;}
.mp-hero-name{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;line-height:1.2;margin-bottom:4px;}
.mp-hero-role{display:inline-flex;align-items:center;gap:6px;background:rgba(255,255,255,.2);
    border:1.5px solid rgba(255,255,255,.35);border-radius:var(--border-radius-full);
    padding:4px 14px;font-size:.8125rem;font-weight:700;margin-bottom:var(--space-md);}
.mp-hero-chips{display:flex;flex-wrap:wrap;gap:var(--space-sm);}
.mp-hero-chip{background:rgba(255,255,255,.18);border:1.5px solid rgba(255,255,255,.30);
    border-radius:var(--border-radius-full);padding:5px 13px;
    font-size:.8125rem;font-weight:700;display:inline-flex;align-items:center;gap:5px;}
.mp-hero-chip.xp{background:rgba(255,216,77,.22);border-color:rgba(255,216,77,.45);color:#FFF3B0;}

/* ══ FORM SECTION ══ */
.mp-form{background:var(--color-white);border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);
    padding:var(--space-xl);margin-bottom:var(--space-xl);}
.mp-form-title{font-family:var(--font-primary);font-size:1.125rem;font-weight:800;
    color:var(--color-text);margin-bottom:var(--space-lg);display:flex;align-items:center;gap:var(--space-sm);}
.mp-form-grid{display:grid;grid-template-columns:repeat(2,1fr);gap:var(--space-lg);}
.mp-field{display:flex;flex-direction:column;gap:6px;}
.mp-field label{font-size:.8125rem;font-weight:700;color:var(--color-text-secondary);}
.mp-field input,.mp-field select{padding:10px 14px;border-radius:var(--border-radius);
    border:1.5px solid var(--border-color);font-size:.9375rem;color:var(--color-text);
    transition:border-color .2s,box-shadow .2s;background:#fff;}
.mp-field input:focus,.mp-field select:focus{outline:none;border-color:var(--mp-orange);
    box-shadow:0 0 0 3px rgba(255,107,44,.12);}
.mp-field input:disabled,.mp-field input[readonly]{background:#F8FAFC;color:var(--color-text-muted);cursor:not-allowed;}

/* ══ LANGUAGE SECTION ══ */
.mp-lang{background:var(--color-white);border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);
    padding:var(--space-xl);margin-bottom:var(--space-xl);}
.mp-lang-title{font-family:var(--font-primary);font-size:1.125rem;font-weight:800;
    color:var(--color-text);margin-bottom:var(--space-lg);display:flex;align-items:center;gap:var(--space-sm);}

/* ══ PERSONALITY SECTION ══ */
.mp-personality{background:var(--color-white);border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);
    padding:var(--space-xl);margin-bottom:var(--space-xl);}
.mp-personality-title{font-family:var(--font-primary);font-size:1.125rem;font-weight:800;
    color:var(--color-text);margin-bottom:var(--space-lg);display:flex;align-items:center;gap:var(--space-sm);}
.mp-pers-card{background:var(--mp-orange-light);border-radius:var(--border-radius-lg);
    padding:var(--space-lg);display:flex;align-items:flex-start;gap:var(--space-lg);}
.mp-pers-avatar{width:64px;height:64px;border-radius:var(--border-radius);
    background:var(--mp-orange);display:flex;align-items:center;justify-content:center;
    font-size:1.75rem;flex-shrink:0;overflow:hidden;}
.mp-pers-avatar img{width:100%;height:100%;object-fit:cover;}
.mp-pers-body{flex:1;}
.mp-pers-name{font-family:var(--font-primary);font-size:1rem;font-weight:800;
    color:var(--color-text);margin-bottom:4px;}
.mp-pers-desc{font-size:.875rem;color:var(--color-text-secondary);line-height:1.5;margin-bottom:var(--space-sm);}
.mp-pers-style{font-size:.8125rem;font-weight:700;color:var(--mp-orange);margin-bottom:var(--space-md);}
.mp-pers-retake{padding:8px 16px;border-radius:var(--border-radius-full);
    font-size:.8125rem;font-weight:700;border:1.5px solid var(--border-color);
    background:#F8FAFC;color:var(--color-text-muted);cursor:not-allowed;display:inline-flex;align-items:center;gap:6px;}

/* ══ STATUS SECTION ══ */
.mp-status{background:var(--color-white);border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);
    padding:var(--space-xl);margin-bottom:var(--space-xl);}
.mp-status-title{font-family:var(--font-primary);font-size:1.125rem;font-weight:800;
    color:var(--color-text);margin-bottom:var(--space-lg);display:flex;align-items:center;gap:var(--space-sm);}
.mp-status-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:var(--space-lg);}
.mp-status-item{display:flex;flex-direction:column;gap:4px;}
.mp-status-item label{font-size:.8125rem;font-weight:700;color:var(--color-text-secondary);}
.mp-status-item span{font-size:.9375rem;font-weight:600;color:var(--color-text);}

/* ══ SAVE AREA ══ */
.mp-save-area{display:flex;align-items:center;gap:var(--space-md);flex-wrap:wrap;margin-bottom:var(--space-xl);}
.mp-btn-save{padding:12px 28px;border-radius:var(--border-radius-full);
    font-size:1rem;font-weight:700;border:none;cursor:pointer;
    background:linear-gradient(135deg,var(--mp-orange),var(--mp-orange-mid));
    color:#fff;transition:all .2s;box-shadow:0 4px 16px rgba(255,107,44,.25);}
.mp-btn-save:hover{transform:translateY(-2px);box-shadow:0 8px 24px rgba(255,107,44,.35);}
.mp-alert-success{background:#DCFCE7;border:1.5px solid #86EFAC;border-radius:var(--border-radius);
    padding:10px 16px;font-size:.875rem;font-weight:600;color:#15803D;display:flex;align-items:center;gap:8px;}
.mp-alert-error{background:#FEF2F2;border:1.5px solid #FECACA;border-radius:var(--border-radius);
    padding:10px 16px;font-size:.875rem;font-weight:600;color:#DC2626;display:flex;align-items:center;gap:8px;}

/* ══ RESPONSIVE ══ */
@media(max-width:767px){
    .mp-hero{flex-direction:column;text-align:center;padding:var(--space-xl) var(--space-lg);}
    .mp-hero-chips{justify-content:center;}
    .mp-form-grid{grid-template-columns:1fr;}
    .mp-status-grid{grid-template-columns:1fr;}
    .mp-pers-card{flex-direction:column;align-items:center;text-align:center;}
}
</style>
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
        <div class="sb-nav-section-label">Progress</div>
        <a href="<%: ResolveUrl("~/Student/ProgressRewards.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-bar-chart-line item-icon"></i><span class="item-label">Progress &amp; Rewards</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/Forum.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-chat-dots item-icon"></i><span class="item-label">Forum</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Student/MyProfile.aspx") %>" class="sb-sidebar-item active">
            <i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span>
        </a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span>
        </a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <asp:Literal ID="litPageTitle" runat="server" Text="My Profile" />
</asp:Content>

<%-- ════ MAIN CONTENT ════ --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- ── HERO CARD ── --%>
<div class="mp-hero">
    <div class="mp-hero-avatar"><asp:Literal ID="litHeroInitial" runat="server" Text="S" /></div>
    <div class="mp-hero-info">
        <div class="mp-hero-name"><asp:Literal ID="litHeroName" runat="server" Text="Student" /></div>
        <div class="mp-hero-role"><i class="bi bi-mortarboard-fill"></i> <asp:Literal ID="litHeroRole" runat="server" Text="Student" /></div>
        <div class="mp-hero-chips">
            <span class="mp-hero-chip"><i class="bi bi-bar-chart-fill"></i> <asp:Literal ID="litLevelLbl" runat="server" Text="Current Level" />: <asp:Literal ID="litHeroLevel" runat="server" Text="—" /></span>
            <span class="mp-hero-chip"><i class="bi bi-stars"></i> <asp:Literal ID="litHeroPersonality" runat="server" Text="—" /></span>
            <span class="mp-hero-chip xp"><i class="bi bi-lightning-charge-fill"></i> <asp:Literal ID="litXPLbl" runat="server" Text="Total XP" />: <asp:Literal ID="litHeroXP" runat="server" Text="0 XP" /></span>
            <span class="mp-hero-chip"><i class="bi bi-people-fill"></i> <asp:Literal ID="litParentCodeLbl" runat="server" Text="Parent Code" />: <asp:Literal ID="litHeroParentCode" runat="server" Text="—" /></span>
        </div>
    </div>
</div>

<%-- ── PERSONAL INFORMATION FORM ── --%>
<div class="mp-form">
    <div class="mp-form-title"><i class="bi bi-person-lines-fill"></i> <asp:Literal ID="litPersonalTitle" runat="server" Text="Personal Information" /></div>
    <div class="mp-form-grid">
        <div class="mp-field">
            <label><asp:Literal ID="litUsernameLbl" runat="server" Text="Username" /></label>
            <asp:TextBox ID="txtUsername" runat="server" CssClass="mp-input" Enabled="false" ReadOnly="true" />
        </div>
        <div class="mp-field">
            <label><asp:Literal ID="litNameLbl" runat="server" Text="Name" /></label>
            <asp:TextBox ID="txtName" runat="server" CssClass="mp-input" />
        </div>
        <div class="mp-field">
            <label><asp:Literal ID="litNicknameLbl" runat="server" Text="Nickname" /></label>
            <asp:TextBox ID="txtNickname" runat="server" CssClass="mp-input" />
        </div>
        <div class="mp-field">
            <label><asp:Literal ID="litPhoneLbl" runat="server" Text="Phone Number" /></label>
            <asp:TextBox ID="txtPhone" runat="server" CssClass="mp-input" />
        </div>
        <div class="mp-field">
            <label><asp:Literal ID="litEmailLbl" runat="server" Text="Email" /></label>
            <asp:TextBox ID="txtEmail" runat="server" CssClass="mp-input" TextMode="Email" />
        </div>
    </div>
</div>

<%-- ── LANGUAGE PREFERENCE ── --%>
<div class="mp-lang">
    <div class="mp-lang-title"><i class="bi bi-translate"></i> <asp:Literal ID="litLangTitle" runat="server" Text="Language Preference" /></div>
    <div class="mp-field" style="max-width:320px;">
        <label><asp:Literal ID="litLangLbl" runat="server" Text="Language Preference" /></label>
        <asp:DropDownList ID="ddlLanguage" runat="server" CssClass="mp-input">
            <asp:ListItem Value="EN" Text="English" />
            <asp:ListItem Value="BM" Text="Bahasa Melayu" />
        </asp:DropDownList>
    </div>
</div>

<%-- ── PERSONALITY SECTION ── --%>
<div class="mp-personality">
    <div class="mp-personality-title"><i class="bi bi-puzzle-fill"></i> <asp:Literal ID="litPersonalityTitle" runat="server" Text="Personality" /></div>
    <div class="mp-pers-card">
        <div class="mp-pers-avatar">
            <asp:Literal ID="litPersAvatarFallback" runat="server" Text="🧠" />
        </div>
        <div class="mp-pers-body">
            <div class="mp-pers-name"><asp:Literal ID="litPersName" runat="server" Text="—" /></div>
            <div class="mp-pers-desc"><asp:Literal ID="litPersDesc" runat="server" Text="—" /></div>
            <div class="mp-pers-style"><asp:Literal ID="litPersStyleLbl" runat="server" Text="Learning Style" />: <asp:Literal ID="litPersStyle" runat="server" Text="—" /></div>
            <span class="mp-pers-retake"><i class="bi bi-arrow-repeat"></i> <asp:Literal ID="litRetakeBtn" runat="server" Text="Retake Personality Test" /> — <asp:Literal ID="litComingSoon" runat="server" Text="Coming Soon" /></span>
        </div>
    </div>
</div>

<%-- ── ACCOUNT STATUS ── --%>
<div class="mp-status">
    <div class="mp-status-title"><i class="bi bi-shield-check"></i> <asp:Literal ID="litStatusTitle" runat="server" Text="Account Status" /></div>
    <div class="mp-status-grid">
        <div class="mp-status-item">
            <label><asp:Literal ID="litStatusRoleLbl" runat="server" Text="Role" /></label>
            <span><asp:Literal ID="litStatusRole" runat="server" Text="—" /></span>
        </div>
        <div class="mp-status-item">
            <label><asp:Literal ID="litStatusStatusLbl" runat="server" Text="Status" /></label>
            <span><asp:Literal ID="litStatusStatus" runat="server" Text="—" /></span>
        </div>
        <div class="mp-status-item">
            <label><asp:Literal ID="litStatusLangLbl" runat="server" Text="Language" /></label>
            <span><asp:Literal ID="litStatusLang" runat="server" Text="—" /></span>
        </div>
    </div>
</div>

<%-- ── SAVE BUTTON & ALERTS ── --%>
<div class="mp-save-area">
    <asp:Button ID="btnSave" runat="server" CssClass="mp-btn-save" Text="Save Changes" OnClick="btnSave_Click" />
    <asp:Literal ID="litSaveBtn" runat="server" Visible="false" />
    <asp:Panel ID="pnlSuccess" runat="server" Visible="false" CssClass="mp-alert-success">
        <i class="bi bi-check-circle-fill"></i> <asp:Literal ID="litSuccess" runat="server" Text="Profile updated successfully." />
    </asp:Panel>
    <asp:Panel ID="pnlSaveError" runat="server" Visible="false" CssClass="mp-alert-error">
        <i class="bi bi-exclamation-triangle-fill"></i> <asp:Literal ID="litSaveError" runat="server" Text="Please fill in all required fields." />
    </asp:Panel>
</div>

</asp:Content>
