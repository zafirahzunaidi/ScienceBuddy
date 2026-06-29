<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs"
    Inherits="ScienceBuddy.Student.Dashboard" MasterPageFile="~/Site.Master"
    Title="Dashboard" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ── Student Dashboard ── */
:root{--student:#FF6B2C;--student-light:#FFF0E8;--student-dark:#E85B1D;--student-mid:#FF8C54;}

/* ══ HERO ══ */
.sd-hero{
    background:linear-gradient(135deg,#1D4ED8 0%,#2563EB 40%,#4DA8FF 100%);
    border-radius:var(--border-radius-xl);padding:var(--space-2xl) var(--space-2xl);
    color:#fff;display:flex;align-items:center;justify-content:space-between;
    gap:var(--space-xl);position:relative;overflow:hidden;margin-bottom:var(--space-xl);
    box-shadow:0 12px 40px rgba(37,99,235,.30);
}
/* decorative science blobs */
.sd-hero::before{content:'⚗️';position:absolute;font-size:7rem;opacity:.07;
    top:-16px;right:200px;pointer-events:none;line-height:1;}
.sd-hero-blob1{position:absolute;width:320px;height:320px;border-radius:50%;
    background:rgba(255,255,255,.06);top:-100px;right:-60px;pointer-events:none;}
.sd-hero-blob2{position:absolute;width:180px;height:180px;border-radius:50%;
    background:rgba(255,216,77,.08);bottom:-60px;left:60px;pointer-events:none;}
.sd-hero-blob3{position:absolute;width:100px;height:100px;border-radius:50%;
    background:rgba(255,107,44,.10);top:20px;left:38%;pointer-events:none;}
.sd-hero-left{position:relative;z-index:1;flex:1;}
.sd-hero-eyebrow{font-size:.75rem;font-weight:700;letter-spacing:1.5px;text-transform:uppercase;
    opacity:.75;margin-bottom:6px;display:flex;align-items:center;gap:6px;}
.sd-hero-greeting{font-family:var(--font-primary);font-size:2.125rem;font-weight:800;
    line-height:1.15;margin-bottom:var(--space-sm);}
.sd-hero-sub{font-size:1rem;opacity:.88;margin-bottom:var(--space-lg);max-width:460px;line-height:1.55;}
.sd-hero-chips{display:flex;gap:var(--space-sm);flex-wrap:wrap;align-items:center;}
.sd-hero-chip{background:rgba(255,255,255,.18);border:1.5px solid rgba(255,255,255,.30);
    border-radius:var(--border-radius-full);padding:5px 13px;
    font-size:.8125rem;font-weight:700;display:inline-flex;align-items:center;gap:5px;
    backdrop-filter:blur(6px);}
.sd-hero-chip.xp-chip{background:rgba(255,216,77,.22);border-color:rgba(255,216,77,.45);color:#FFF3B0;}
.sd-hero-cta{margin-top:var(--space-lg);display:flex;gap:var(--space-sm);flex-wrap:wrap;}
.sd-hero-btn{display:inline-flex;align-items:center;gap:6px;padding:10px 22px;
    border-radius:var(--border-radius-full);font-weight:700;font-size:.9375rem;
    text-decoration:none;transition:all .2s;border:2px solid transparent;}
.sd-hero-btn-primary{background:#fff;color:var(--color-primary);}
.sd-hero-btn-primary:hover{background:#DBEAFE;color:var(--color-primary-dark);transform:translateY(-2px);
    box-shadow:0 6px 20px rgba(0,0,0,.15);text-decoration:none;}
.sd-hero-btn-secondary{background:rgba(255,255,255,.15);color:#fff;border-color:rgba(255,255,255,.35);}
.sd-hero-btn-secondary:hover{background:rgba(255,255,255,.25);transform:translateY(-2px);text-decoration:none;}
.sd-hero-right{position:relative;z-index:1;flex-shrink:0;}
.sd-hero-avatar{width:130px;height:130px;border-radius:var(--border-radius-xl);
    background:rgba(255,255,255,.15);border:3px solid rgba(255,255,255,.35);
    display:flex;align-items:center;justify-content:center;font-size:3.75rem;
    overflow:hidden;box-shadow:0 10px 36px rgba(0,0,0,.20);}
.sd-hero-avatar img{width:100%;height:100%;object-fit:cover;}
.sd-hero-avatar-label{text-align:center;margin-top:var(--space-sm);font-size:.8125rem;
    font-weight:700;opacity:.85;}
</style>
<style>
/* ══ SECTION HEADING ══ */
.sd-section-hd{display:flex;align-items:center;justify-content:space-between;
    margin-bottom:var(--space-md);gap:var(--space-md);}
.sd-section-title{font-family:var(--font-primary);font-size:1.0625rem;font-weight:800;
    color:var(--color-text);display:flex;align-items:center;gap:var(--space-sm);}
.sd-section-title .ico{font-size:1.1rem;}
.sd-view-all{font-size:.8125rem;font-weight:700;color:var(--color-primary);
    text-decoration:none;display:flex;align-items:center;gap:4px;}
.sd-view-all:hover{text-decoration:underline;}

/* ══ STAT CARDS ══ */
.sd-stats{display:grid;grid-template-columns:repeat(4,1fr);gap:var(--space-md);margin-bottom:var(--space-xl);}
.sd-stat-card{background:var(--color-white);border-radius:var(--border-radius-lg);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);
    padding:var(--space-lg);display:flex;flex-direction:column;gap:var(--space-sm);
    transition:transform .2s,box-shadow .2s;position:relative;overflow:hidden;}
.sd-stat-card::before{content:'';position:absolute;top:0;left:0;right:0;
    height:4px;border-radius:var(--border-radius-lg) var(--border-radius-lg) 0 0;}
.sd-stat-card:hover{transform:translateY(-4px);box-shadow:var(--shadow-md);}
.sd-stat-card.sc-level::before{background:linear-gradient(90deg,#2563EB,#4DA8FF);}
.sd-stat-card.sc-xp::before{background:linear-gradient(90deg,#FF6B2C,#FFD84D);}
.sd-stat-card.sc-badge::before{background:linear-gradient(90deg,#FFD84D,#FFAB2C);}
.sd-stat-card.sc-lesson::before{background:linear-gradient(90deg,#22C55E,#4ADE80);}
.sd-stat-top{display:flex;align-items:center;justify-content:space-between;}
.sd-stat-icon{width:44px;height:44px;border-radius:var(--border-radius);
    display:flex;align-items:center;justify-content:center;font-size:1.375rem;}
.sd-stat-badge-pill{font-size:.6875rem;font-weight:800;padding:2px 8px;
    border-radius:var(--border-radius-full);}
.sd-stat-val{font-family:var(--font-primary);font-size:2rem;font-weight:800;
    line-height:1;color:var(--color-text);}
.sd-stat-lbl{font-size:.8125rem;color:var(--color-text-secondary);font-weight:600;}
.sd-stat-sub{font-size:.75rem;color:var(--color-text-muted);margin-top:2px;}

/* ══ PERSONALITY SECTION ORDER (flex column, JS-free) ══ */
.sd-sections{display:flex;flex-direction:column;gap:var(--space-xl);}

/* ══ PERSONALITY RECOMMENDATION BANNER ══ */
.sd-rec-banner{border-radius:var(--border-radius-xl);padding:var(--space-xl);
    display:flex;align-items:center;gap:var(--space-lg);position:relative;overflow:hidden;}
.sd-rec-banner::after{content:'';position:absolute;width:200px;height:200px;border-radius:50%;
    background:rgba(255,255,255,.08);right:-40px;bottom:-60px;pointer-events:none;}
.sd-rec-banner-icon{width:72px;height:72px;border-radius:var(--border-radius-xl);
    background:rgba(255,255,255,.22);border:2px solid rgba(255,255,255,.35);
    display:flex;align-items:center;justify-content:center;font-size:2rem;flex-shrink:0;
    overflow:hidden;box-shadow:0 4px 16px rgba(0,0,0,.12);}
.sd-rec-banner-icon img{width:100%;height:100%;object-fit:cover;}
.sd-rec-banner-body{flex:1;position:relative;z-index:1;}
.sd-rec-banner-label{font-size:.75rem;font-weight:700;letter-spacing:1px;text-transform:uppercase;
    opacity:.8;margin-bottom:4px;}
.sd-rec-banner-title{font-family:var(--font-primary);font-size:1.25rem;font-weight:800;
    color:#fff;line-height:1.25;margin-bottom:6px;}
.sd-rec-banner-sub{font-size:.9rem;color:rgba(255,255,255,.85);margin-bottom:var(--space-md);line-height:1.5;}
</style>
<style>
/* ══ CONTINUE LEARNING ══ */
.sd-continue{background:var(--color-white);border-radius:var(--border-radius-xl);
    border:2px solid var(--student-light);box-shadow:var(--shadow-md);overflow:hidden;}
.sd-continue-header{background:linear-gradient(135deg,var(--student) 0%,var(--student-mid) 100%);
    padding:var(--space-md) var(--space-xl);display:flex;align-items:center;gap:var(--space-sm);
    color:#fff;font-family:var(--font-primary);font-weight:800;font-size:1rem;}
.sd-continue-body{padding:var(--space-xl);}
.sd-continue-meta{font-size:.75rem;font-weight:700;color:var(--student);letter-spacing:.5px;
    text-transform:uppercase;margin-bottom:6px;display:flex;align-items:center;gap:6px;}
.sd-continue-title{font-family:var(--font-primary);font-size:1.125rem;font-weight:800;
    color:var(--color-text);margin-bottom:6px;line-height:1.3;}
.sd-continue-sub{font-size:.875rem;color:var(--color-text-secondary);margin-bottom:var(--space-lg);line-height:1.5;}
.sd-continue-bar-wrap{margin-bottom:var(--space-lg);}
.sd-continue-bar-lbl{display:flex;align-items:center;justify-content:space-between;
    font-size:.8125rem;font-weight:600;color:var(--color-text-secondary);margin-bottom:6px;}
.sd-continue-bar{height:10px;background:#F0F7FF;border-radius:var(--border-radius-full);overflow:hidden;}
.sd-continue-bar-fill{height:100%;background:linear-gradient(90deg,var(--student),var(--student-mid));
    border-radius:var(--border-radius-full);width:0%;transition:width .8s ease;}

/* ══ QUICK ACTIONS ══ */
.sd-quick-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:var(--space-md);}
.sd-quick-card{background:var(--color-white);border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);
    padding:var(--space-lg) var(--space-md);text-decoration:none;
    transition:transform .2s,box-shadow .2s;display:flex;flex-direction:column;
    align-items:flex-start;gap:8px;position:relative;overflow:hidden;}
.sd-quick-card::after{content:'';position:absolute;bottom:0;left:0;right:0;
    height:3px;border-radius:0 0 var(--border-radius-xl) var(--border-radius-xl);}
.sd-quick-card:hover{transform:translateY(-5px);box-shadow:var(--shadow-lg);text-decoration:none;}
.sd-quick-card.qc-learn::after{background:linear-gradient(90deg,#2563EB,#4DA8FF);}
.sd-quick-card.qc-quiz::after{background:linear-gradient(90deg,#FFD84D,#FFAB2C);}
.sd-quick-card.qc-lab::after{background:linear-gradient(90deg,#22C55E,#4ADE80);}
.sd-quick-card.qc-live::after{background:linear-gradient(90deg,#4DA8FF,#818CF8);}
.sd-quick-card.qc-ai::after{background:linear-gradient(90deg,#7C3AED,#A78BFA);}
.sd-quick-card.qc-progress::after{background:linear-gradient(90deg,#FF6B2C,#FFD84D);}
.sd-quick-icon{width:48px;height:48px;border-radius:var(--border-radius);
    font-size:1.375rem;display:flex;align-items:center;justify-content:center;margin-bottom:4px;}
.sd-quick-label{font-family:var(--font-primary);font-size:.9375rem;font-weight:800;
    color:var(--color-text);line-height:1.2;}
.sd-quick-desc{font-size:.8rem;color:var(--color-text-muted);line-height:1.4;}
</style>
<style>
/* ══ NOTIFICATIONS ══ */
.sd-notif-card{background:var(--color-white);border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);overflow:hidden;}
.sd-notif-hdr{padding:var(--space-md) var(--space-lg);border-bottom:1px solid var(--border-color);
    display:flex;align-items:center;justify-content:space-between;}
.sd-notif-hdr-title{font-family:var(--font-primary);font-weight:800;font-size:.9375rem;
    display:flex;align-items:center;gap:var(--space-sm);}
.sd-notif-list{padding:var(--space-sm) var(--space-lg);}
.sd-notif-item{padding:10px 0;border-bottom:1px solid #F0F7FF;
    display:flex;gap:var(--space-sm);align-items:flex-start;}
.sd-notif-item:last-child{border-bottom:none;}
.sd-notif-dot{width:10px;height:10px;border-radius:50%;background:var(--student);
    margin-top:5px;flex-shrink:0;box-shadow:0 0 0 3px var(--student-light);}
.sd-notif-dot.read{background:var(--color-text-muted);box-shadow:none;}
.sd-notif-title{font-size:.875rem;font-weight:600;color:var(--color-text);line-height:1.4;}
.sd-notif-time{font-size:.75rem;color:var(--color-text-muted);margin-top:3px;
    display:flex;align-items:center;gap:4px;}

/* ══ SOCIAL SHORTCUTS (Socializer) ══ */
.sd-social-grid{display:grid;grid-template-columns:repeat(2,1fr);gap:var(--space-md);}
.sd-social-card{background:var(--color-white);border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);
    padding:var(--space-lg);text-decoration:none;transition:transform .2s,box-shadow .2s;
    display:flex;align-items:center;gap:var(--space-md);}
.sd-social-card:hover{transform:translateY(-3px);box-shadow:var(--shadow-md);text-decoration:none;}
.sd-social-icon{width:48px;height:48px;border-radius:var(--border-radius);
    font-size:1.375rem;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
.sd-social-label{font-family:var(--font-primary);font-size:.9375rem;font-weight:700;color:var(--color-text);}
.sd-social-sub{font-size:.8rem;color:var(--color-text-muted);}

/* ══ GAMIFICATION XP BAR ══ */
.sd-xp-bar-section{background:linear-gradient(135deg,#1D4ED8,#2563EB);
    border-radius:var(--border-radius-xl);padding:var(--space-lg) var(--space-xl);
    color:#fff;display:flex;align-items:center;gap:var(--space-lg);}
.sd-xp-bar-label{font-family:var(--font-primary);font-weight:800;font-size:1rem;
    white-space:nowrap;}
.sd-xp-bar-wrap{flex:1;}
.sd-xp-bar{height:12px;background:rgba(255,255,255,.2);border-radius:var(--border-radius-full);overflow:hidden;}
.sd-xp-bar-fill{height:100%;background:linear-gradient(90deg,#FFD84D,#FF9A5C);
    border-radius:var(--border-radius-full);width:0%;transition:width 1s ease;}
.sd-xp-bar-info{font-size:.8125rem;opacity:.85;margin-top:5px;display:flex;
    align-items:center;justify-content:space-between;}

/* ══ RESPONSIVE ══ */
@media(max-width:1023px){
    .sd-stats{grid-template-columns:repeat(2,1fr);}
    .sd-quick-grid{grid-template-columns:repeat(2,1fr);}
}
@media(max-width:767px){
    .sd-hero{flex-direction:column;padding:var(--space-xl) var(--space-lg);}
    .sd-hero-avatar{width:96px;height:96px;font-size:2.75rem;}
    .sd-hero-greeting{font-size:1.625rem;}
    .sd-hero-right{align-self:center;}
    .sd-stats{grid-template-columns:repeat(2,1fr);}
    .sd-quick-grid{grid-template-columns:repeat(2,1fr);}
    .sd-social-grid{grid-template-columns:1fr;}
    .sd-xp-bar-section{flex-direction:column;align-items:flex-start;gap:var(--space-sm);}
}
@media(max-width:479px){
    .sd-hero{padding:var(--space-lg) var(--space-md);}
    .sd-hero-greeting{font-size:1.375rem;}
    .sd-stats{gap:var(--space-sm);}
    .sd-quick-grid{grid-template-columns:repeat(2,1fr);gap:var(--space-sm);}
    .sd-hero-cta .sd-hero-btn{width:100%;justify-content:center;}
}
</style>
</asp:Content>

<%-- ════ SIDEBAR ════ --%>
<asp:Content ID="cSidebarMenu" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Main</div>
        <a href="<%: ResolveUrl("~/Student/Dashboard.aspx") %>" class="sb-sidebar-item active">
            <i class="bi bi-speedometer2 item-icon"></i><span class="item-label">Dashboard</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/Notifications.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span>
            <asp:Panel ID="pnlNotifBadge" runat="server" Visible="false" CssClass="item-badge">
                <span class="sb-badge sb-badge-error sb-badge-sm"><asp:Literal ID="litNotifCount" runat="server" /></span>
            </asp:Panel>
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
        <a href="<%: ResolveUrl("~/Student/Profile.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span>
        </a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span>
        </a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">Dashboard</asp:Content>

<%-- ════ MAIN CONTENT ════ --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- ── HERO ── --%>
<div class="sd-hero">
    <div class="sd-hero-blob1"></div><div class="sd-hero-blob2"></div><div class="sd-hero-blob3"></div>
    <div class="sd-hero-left">
        <div class="sd-hero-eyebrow"><i class="bi bi-stars"></i> <asp:Literal ID="litHeroEyebrow" runat="server" Text="Science Learning" /></div>
        <div class="sd-hero-greeting"><asp:Literal ID="litGreeting" runat="server" Text="Hi there! 👋" /></div>
        <div class="sd-hero-sub"><asp:Literal ID="litMotivation" runat="server" Text="Ready to explore science today?" /></div>
        <div class="sd-hero-chips">
            <span class="sd-hero-chip"><i class="bi bi-bar-chart-fill"></i> <asp:Literal ID="litHeroLevel" runat="server" Text="Level: —" /></span>
            <span class="sd-hero-chip"><i class="bi bi-stars"></i> <asp:Literal ID="litHeroPersonality" runat="server" Text="—" /></span>
            <span class="sd-hero-chip xp-chip"><i class="bi bi-lightning-charge-fill"></i> <asp:Literal ID="litHeroXP" runat="server" Text="0 XP" /></span>
        </div>
        <div class="sd-hero-cta">
            <a href="<%: ResolveUrl("~/Student/Learning.aspx") %>" class="sd-hero-btn sd-hero-btn-primary">
                <i class="bi bi-play-circle-fill"></i> <asp:Literal ID="litHeroCTA1" runat="server" Text="Continue Learning" />
            </a>
            <a href="<%: ResolveUrl("~/Student/Progress.aspx") %>" class="sd-hero-btn sd-hero-btn-secondary">
                <i class="bi bi-trophy-fill"></i> <asp:Literal ID="litHeroCTA2" runat="server" Text="My Progress" />
            </a>
        </div>
    </div>
    <div class="sd-hero-right">
        <div class="sd-hero-avatar">
            <asp:Image ID="imgPersonalityAvatar" runat="server" AlternateText="Personality avatar"
                onerror="this.style.display='none';this.parentElement.innerHTML='🔬';" />
            <asp:Literal ID="litAvatarFallback" runat="server" />
        </div>
        <div class="sd-hero-avatar-label"><asp:Literal ID="litHeroPersonality2" runat="server" /></div>
    </div>
</div>

<%-- ── XP GAMIFICATION BAR ── --%>
<div class="sd-xp-bar-section" style="margin-bottom:var(--space-xl);">
    <span class="sd-xp-bar-label">⚡ <asp:Literal ID="litXPBarLabel" runat="server" Text="0 XP" /></span>
    <div class="sd-xp-bar-wrap">
        <div class="sd-xp-bar">
            <div class="sd-xp-bar-fill" id="xpBarFill" style="width:0%"
                 data-pct="<asp:Literal ID='litXPBarPct' runat='server' Text='0' />"></div>
        </div>
        <div class="sd-xp-bar-info">
            <span><asp:Literal ID="litXPBarProgress" runat="server" Text="Level Progress" /></span>
            <span><asp:Literal ID="litXPBarHint" runat="server" Text="Keep learning to earn more XP!" /></span>
        </div>
    </div>
</div>

<%-- ── STAT CARDS ── --%>
<div class="sd-stats" style="margin-bottom:var(--space-xl);">
    <div class="sd-stat-card sc-level">
        <div class="sd-stat-top">
            <div class="sd-stat-icon" style="background:#DBEAFE;color:#1D4ED8;">🎓</div>
            <span class="sd-stat-badge-pill" style="background:#DBEAFE;color:#1D4ED8;">Level</span>
        </div>
        <div class="sd-stat-val"><asp:Literal ID="litStatLevel" runat="server" Text="—" /></div>
        <div class="sd-stat-lbl"><asp:Literal ID="litStatLevelLbl" runat="server" Text="Current Level" /></div>
        <div class="sd-stat-sub"><asp:Literal ID="litStatLevelSub" runat="server" Text="Keep going to advance!" /></div>
    </div>
    <div class="sd-stat-card sc-xp">
        <div class="sd-stat-top">
            <div class="sd-stat-icon" style="background:#FFF0E8;color:#FF6B2C;">⚡</div>
            <span class="sd-stat-badge-pill" style="background:#FFF0E8;color:#FF6B2C;">XP</span>
        </div>
        <div class="sd-stat-val"><asp:Literal ID="litStatXP" runat="server" Text="0" /></div>
        <div class="sd-stat-lbl"><asp:Literal ID="litStatXPLbl" runat="server" Text="Total XP Earned" /></div>
        <div class="sd-stat-sub"><asp:Literal ID="litStatXPSub" runat="server" Text="Every lesson earns XP" /></div>
    </div>
    <div class="sd-stat-card sc-badge">
        <div class="sd-stat-top">
            <div class="sd-stat-icon" style="background:#FFFBEB;color:#B45309;">🏅</div>
            <span class="sd-stat-badge-pill" style="background:#FFFBEB;color:#B45309;">Badges</span>
        </div>
        <div class="sd-stat-val"><asp:Literal ID="litStatBadges" runat="server" Text="0" /></div>
        <div class="sd-stat-lbl"><asp:Literal ID="litStatBadgesLbl" runat="server" Text="Badges Earned" /></div>
        <div class="sd-stat-sub"><asp:Literal ID="litStatBadgesSub" runat="server" Text="Complete tasks to earn more" /></div>
    </div>
    <div class="sd-stat-card sc-lesson">
        <div class="sd-stat-top">
            <div class="sd-stat-icon" style="background:#DCFCE7;color:#15803D;">✅</div>
            <span class="sd-stat-badge-pill" style="background:#DCFCE7;color:#15803D;">Done</span>
        </div>
        <div class="sd-stat-val"><asp:Literal ID="litStatLessons" runat="server" Text="0" /></div>
        <div class="sd-stat-lbl"><asp:Literal ID="litStatLessonsLbl" runat="server" Text="Lessons Completed" /></div>
        <div class="sd-stat-sub"><asp:Literal ID="litStatLessonsSub" runat="server" Text="Great job so far!" /></div>
    </div>
</div>

<%-- ── PERSONALITY-ORDERED SECTIONS WRAPPER ── --%>
<%-- Code-behind sets CSS order on each panel via inline style --%>
<div class="sd-sections" id="sdSections" runat="server">

    <%-- ── SECTION: PERSONALITY RECOMMENDATION ── --%>
    <asp:Panel ID="pnlSectionRec" runat="server">
        <div class="sd-rec-banner" id="divRecBanner" runat="server">
            <div class="sd-rec-banner-icon" id="divPersonalityAvatar" runat="server">
                <asp:Image ID="imgPersonalityThumb" runat="server" AlternateText="Personality"
                    onerror="this.style.display='none';this.parentElement.innerHTML='🧠';" />
                <asp:Literal ID="litPersonalityThumbFallback" runat="server" />
            </div>
            <div class="sd-rec-banner-body">
                <div class="sd-rec-banner-label"><asp:Literal ID="litRecLabel" runat="server" Text="✨ Recommended for your learning style" /></div>
                <div class="sd-rec-banner-title"><asp:Literal ID="litPersonalityName" runat="server" Text="Learner" /></div>
                <div class="sd-rec-banner-sub"><asp:Literal ID="litPersonalityRec" runat="server" Text="Keep learning at your own pace!" /></div>
                <asp:HyperLink ID="lnkPersonalityAction" runat="server" NavigateUrl="#"
                    CssClass="sd-hero-btn sd-hero-btn-primary" style="display:inline-flex;">
                    <asp:Literal ID="litPersonalityAction" runat="server" Text="Get Started" />
                    <i class="bi bi-arrow-right"></i>
                </asp:HyperLink>
            </div>
        </div>
    </asp:Panel>

    <%-- ── SECTION: CONTINUE LEARNING ── --%>
    <asp:Panel ID="pnlSectionContinue" runat="server">
        <div class="sd-section-hd">
            <div class="sd-section-title"><span class="ico">📖</span> <asp:Literal ID="litSecContinue" runat="server" Text="Continue Learning" /></div>
            <a href="<%: ResolveUrl("~/Student/Learning.aspx") %>" class="sd-view-all"><asp:Literal ID="litViewAll" runat="server" Text="View All" /> <i class="bi bi-arrow-right"></i></a>
        </div>
        <div class="sd-continue">
            <div class="sd-continue-header"><i class="bi bi-play-circle-fill"></i> &nbsp;<asp:Literal ID="litContinueHeader" runat="server" Text="Pick up where you left off" /></div>
            <div class="sd-continue-body">
                <asp:Panel ID="pnlContinue" runat="server">
                    <div class="sd-continue-meta"><i class="bi bi-bookmark-fill"></i> <asp:Literal ID="litContinueMeta" runat="server" Text="Next Lesson" /></div>
                    <div class="sd-continue-title"><asp:Literal ID="litContinueTitle" runat="server" Text="Your next lesson is ready" /></div>
                    <div class="sd-continue-sub"><asp:Literal ID="litContinueSub" runat="server" Text="Continue from where you left off." /></div>
                    <div class="sd-continue-bar-wrap">
                        <div class="sd-continue-bar-lbl">
                            <span>Unit Progress</span>
                            <span style="color:var(--student);font-weight:700;">In Progress</span>
                        </div>
                        <div class="sd-continue-bar">
                            <div class="sd-continue-bar-fill" id="continueFill" style="width:30%"></div>
                        </div>
                    </div>
                    <a href="<%: ResolveUrl("~/Student/Learning.aspx") %>"
                       class="sb-btn sb-btn-orange">
                        <i class="bi bi-play-fill"></i> <asp:Literal ID="litContinueBtn" runat="server" Text="Continue Learning" />
                    </a>
                </asp:Panel>
                <asp:Panel ID="pnlContinueEmpty" runat="server" Visible="false">
                    <div class="sb-empty-state" style="padding:var(--space-xl) 0;">
                        <div class="empty-icon">🚀</div>
                        <div class="empty-title"><asp:Literal ID="litEmptyTitle" runat="server" Text="Ready to begin your adventure?" /></div>
                        <div class="empty-desc"><asp:Literal ID="litEmptyDesc" runat="server" Text="You haven't started any lessons yet. Dive in and discover science!" /></div>
                        <a href="<%: ResolveUrl("~/Student/Learning.aspx") %>"
                           class="sb-btn sb-btn-orange mt-md">
                            <i class="bi bi-play-fill"></i> <asp:Literal ID="litEmptyBtn" runat="server" Text="Start Learning" />
                        </a>
                    </div>
                </asp:Panel>
            </div>
        </div>
    </asp:Panel>

    <%-- ── SECTION: QUICK ACTIONS ── --%>
    <asp:Panel ID="pnlSectionQuick" runat="server">
        <div class="sd-section-hd">
            <div class="sd-section-title"><span class="ico">⚡</span> <asp:Literal ID="litSecQuick" runat="server" Text="Quick Actions" /></div>
        </div>
        <div class="sd-quick-grid">
            <a href="<%: ResolveUrl("~/Student/Learning.aspx") %>" class="sd-quick-card qc-learn">
                <div class="sd-quick-icon" style="background:#DBEAFE;color:#1D4ED8;"><i class="bi bi-book-half"></i></div>
                <div class="sd-quick-label"><asp:Literal ID="litQALearn" runat="server" Text="My Learning" /></div>
                <div class="sd-quick-desc"><asp:Literal ID="litQALearnDesc" runat="server" Text="Lessons, subtopics &amp; units" /></div>
            </a>
            <a href="<%: ResolveUrl("~/Student/PracticeLibrary.aspx") %>" class="sd-quick-card qc-quiz">
                <div class="sd-quick-icon" style="background:#FFFBEB;color:#B45309;"><i class="bi bi-patch-question-fill"></i></div>
                <div class="sd-quick-label"><asp:Literal ID="litQAPractice" runat="server" Text="Practice Library" /></div>
                <div class="sd-quick-desc"><asp:Literal ID="litQAPracticeDesc" runat="server" Text="Quizzes &amp; self-assessment" /></div>
            </a>
            <a href="<%: ResolveUrl("~/Student/VirtualLabs.aspx") %>" class="sd-quick-card qc-lab">
                <div class="sd-quick-icon" style="background:#DCFCE7;color:#15803D;"><i class="bi bi-eyedropper"></i></div>
                <div class="sd-quick-label"><asp:Literal ID="litQALab" runat="server" Text="Virtual Labs" /></div>
                <div class="sd-quick-desc"><asp:Literal ID="litQALabDesc" runat="server" Text="Interactive science experiments" /></div>
            </a>
            <a href="#" class="sd-quick-card qc-live">
                <div class="sd-quick-icon" style="background:#E0F2FE;color:#0369A1;"><i class="bi bi-camera-video-fill"></i></div>
                <div class="sd-quick-label"><asp:Literal ID="litQALive" runat="server" Text="Live Sessions" /></div>
                <div class="sd-quick-desc"><asp:Literal ID="litQALiveDesc" runat="server" Text="Join teacher-led classes" /></div>
            </a>
            <a href="<%: ResolveUrl("~/Student/AIStudyCompanion.aspx") %>" class="sd-quick-card qc-ai">
                <div class="sd-quick-icon" style="background:#F3E8FF;color:#7C3AED;"><i class="bi bi-robot"></i></div>
                <div class="sd-quick-label"><asp:Literal ID="litQAAI" runat="server" Text="AI Study Companion" /></div>
                <div class="sd-quick-desc"><asp:Literal ID="litQAAIDesc" runat="server" Text="Personalised help &amp; hints" /></div>
            </a>
            <a href="<%: ResolveUrl("~/Student/ProgressRewards.aspx") %>" class="sd-quick-card qc-progress">
                <div class="sd-quick-icon" style="background:#FFF0E8;color:#FF6B2C;"><i class="bi bi-trophy-fill"></i></div>
                <div class="sd-quick-label"><asp:Literal ID="litQAProgress" runat="server" Text="Progress &amp; Rewards" /></div>
                <div class="sd-quick-desc"><asp:Literal ID="litQAProgressDesc" runat="server" Text="XP, badges &amp; achievements" /></div>
            </a>
        </div>
    </asp:Panel>

    <%-- ── SECTION: SOCIAL (Socializer personality) ── --%>
    <asp:Panel ID="pnlSectionSocial" runat="server" Visible="false">
        <div class="sd-section-hd">
            <div class="sd-section-title"><span class="ico">🤝</span> <asp:Literal ID="litSecSocial" runat="server" Text="Learn Together" /></div>
        </div>
        <div class="sd-social-grid">
            <a href="<%: ResolveUrl("~/Student/Forum.aspx") %>" class="sd-social-card">
                <div class="sd-social-icon" style="background:#E0F2FE;color:#0369A1;"><i class="bi bi-chat-dots-fill"></i></div>
                <div><div class="sd-social-label">Forum</div><div class="sd-social-sub">Discuss with classmates</div></div>
            </a>
            <a href="#" class="sd-social-card">
                <div class="sd-social-icon" style="background:#DCFCE7;color:#15803D;"><i class="bi bi-camera-video-fill"></i></div>
                <div><div class="sd-social-label">Live Sessions</div><div class="sd-social-sub">Join a teacher live class</div></div>
            </a>
            <a href="<%: ResolveUrl("~/Student/Messages.aspx") %>" class="sd-social-card">
                <div class="sd-social-icon" style="background:#F3E8FF;color:#7C3AED;"><i class="bi bi-envelope-fill"></i></div>
                <div><div class="sd-social-label">Messages</div><div class="sd-social-sub">Chat with your teacher</div></div>
            </a>
            <a href="<%: ResolveUrl("~/Student/Learning.aspx") %>" class="sd-social-card">
                <div class="sd-social-icon" style="background:#FFF0E8;color:#FF6B2C;"><i class="bi bi-book-fill"></i></div>
                <div><div class="sd-social-label">Continue Learning</div><div class="sd-social-sub">Pick up your next lesson</div></div>
            </a>
        </div>
    </asp:Panel>

    <%-- ── SECTION: NOTIFICATIONS ── --%>
    <asp:Panel ID="pnlSectionNotif" runat="server">
        <div class="sd-section-hd">
            <div class="sd-section-title"><span class="ico">🔔</span> <asp:Literal ID="litSecNotif" runat="server" Text="Recent Notifications" /></div>
            <a href="#" class="sd-view-all"><asp:Literal ID="litSeeAll" runat="server" Text="See All" /> <i class="bi bi-arrow-right"></i></a>
        </div>
        <div class="sd-notif-card">
            <div class="sd-notif-hdr">
                <div class="sd-notif-hdr-title"><i class="bi bi-bell-fill" style="color:var(--student)"></i> Notifications</div>
                <asp:Panel ID="pnlUnreadBadge" runat="server" Visible="false">
                    <span class="sb-badge sb-badge-error sb-badge-sm"><asp:Literal ID="litUnreadCount" runat="server" /></span>
                </asp:Panel>
            </div>
            <div class="sd-notif-list">
                <asp:Panel ID="pnlNotifications" runat="server">
                    <asp:Repeater ID="rptNotifications" runat="server">
                        <ItemTemplate>
                            <div class="sd-notif-item">
                                <div class="sd-notif-dot <%# (bool)Eval("isRead") ? "read" : "" %>"></div>
                                <div>
                                    <div class="sd-notif-title"><%# Eval("title") %></div>
                                    <div class="sd-notif-time"><i class="bi bi-clock"></i> <%# Eval("timeAgo") %></div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </asp:Panel>
                <asp:Panel ID="pnlNotificationsEmpty" runat="server" Visible="false">
                    <div class="sb-empty-state" style="padding:var(--space-lg) 0;">
                        <div class="empty-icon" style="font-size:2.5rem;">🎉</div>
                        <div class="empty-title"><asp:Literal ID="litNotifEmpty" runat="server" Text="You're all caught up!" /></div>
                        <div class="empty-desc"><asp:Literal ID="litNotifEmptyDesc" runat="server" Text="No new notifications right now. Check back later." /></div>
                    </div>
                </asp:Panel>
            </div>
        </div>
    </asp:Panel>

</div><%-- /#sdSections --%>

</asp:Content>

<%-- ════ PAGE SCRIPTS ════ --%>
<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
document.addEventListener('DOMContentLoaded', function () {
    /* Animate stat value counters */
    document.querySelectorAll('.sd-stat-val').forEach(function (el) {
        var raw = el.textContent.trim();
        var num = parseInt(raw.replace(/[^0-9]/g, ''), 10);
        if (!isNaN(num) && num > 0) { el.setAttribute('data-count', num); }
    });
    if (window.ScienceBuddy && ScienceBuddy.Counter) ScienceBuddy.Counter.init();

    /* Animate XP bar from data-xp attribute */
    var xpFill = document.getElementById('xpBarFill');
    if (xpFill) {
        var pct = parseFloat(xpFill.getAttribute('data-pct') || 0);
        setTimeout(function(){ xpFill.style.width = Math.min(pct, 100) + '%'; }, 200);
    }
    /* Animate continue-learning bar */
    var cFill = document.getElementById('continueFill');
    if (cFill) {
        var cp = parseFloat(cFill.getAttribute('data-pct') || 30);
        setTimeout(function(){ cFill.style.width = Math.min(cp, 100) + '%'; }, 400);
    }
});
</script>
</asp:Content>
