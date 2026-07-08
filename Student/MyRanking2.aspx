<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MyRanking2.aspx.cs"
    Inherits="ScienceBuddy.Student.MyRanking" MasterPageFile="~/Site.Master"
    Title="My Ranking" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ── My Ranking Page ── */
:root{--rk-gold:#FACC15;--rk-blue:#2563EB;--rk-indigo:#4F46E5;--rk-purple:#7C3AED;--rk-gold-light:#FEF3C7;--rk-bronze:#CD7F32;--rk-silver:#C0C0C0;}

/* ══ HERO ══ */
.rk-hero{
    background:linear-gradient(135deg,#2563EB 0%,#4F46E5 45%,#7C3AED 100%);
    border-radius:var(--border-radius-xl);padding:var(--space-2xl);
    color:#fff;display:flex;align-items:center;justify-content:space-between;
    gap:var(--space-xl);position:relative;overflow:hidden;margin-bottom:var(--space-xl);
    box-shadow:0 12px 40px rgba(79,70,229,.25);
}
.rk-hero::before{content:'';position:absolute;width:100px;height:100px;border-radius:50%;
    background:rgba(250,204,21,.12);top:-20px;right:80px;pointer-events:none;}
.rk-hero-blob1{position:absolute;width:300px;height:300px;border-radius:50%;
    background:rgba(255,255,255,.08);top:-100px;right:-60px;pointer-events:none;}
.rk-hero-blob2{position:absolute;width:160px;height:160px;border-radius:50%;
    background:rgba(255,255,255,.06);bottom:-50px;left:40px;pointer-events:none;}
.rk-hero-left{position:relative;z-index:1;flex:1;}
.rk-hero-title{font-family:var(--font-primary);font-size:2rem;font-weight:800;
    line-height:1.15;margin-bottom:var(--space-sm);color:#fff;text-shadow:0 2px 8px rgba(0,0,0,.15);}
.rk-hero-sub{font-size:1rem;opacity:.92;margin-bottom:var(--space-lg);max-width:460px;line-height:1.55;}
.rk-hero-chips{display:flex;gap:var(--space-sm);flex-wrap:wrap;align-items:center;}
.rk-hero-chip{background:rgba(255,255,255,.22);border:1.5px solid rgba(255,255,255,.35);
    border-radius:var(--border-radius-full);padding:6px 14px;
    font-size:.8125rem;font-weight:700;display:inline-flex;align-items:center;gap:5px;
    backdrop-filter:blur(6px);}
.rk-hero-chip.rk-rank-chip{background:rgba(255,255,255,.30);border-color:rgba(255,255,255,.50);font-size:.9375rem;}
.rk-hero-right{position:relative;z-index:1;flex-shrink:0;text-align:center;}
.rk-hero-trophy{font-size:4.5rem;filter:drop-shadow(0 4px 12px rgba(0,0,0,.2));}

/* ══ PERSONAL RANK CARD ══ */
.rk-personal{background:var(--color-white);border-radius:var(--border-radius-xl);
    border:2px solid var(--rk-gold-light);box-shadow:var(--shadow-md);
    padding:var(--space-xl);display:flex;align-items:center;gap:var(--space-lg);
    margin-bottom:var(--space-xl);position:relative;overflow:hidden;}
.rk-personal::before{content:'';position:absolute;top:0;left:0;right:0;height:4px;
    background:linear-gradient(90deg,var(--rk-gold),var(--rk-indigo));border-radius:var(--border-radius-xl) var(--border-radius-xl) 0 0;}
.rk-personal-avatar{width:64px;height:64px;border-radius:50%;
    background:linear-gradient(135deg,var(--rk-blue),var(--rk-purple));
    display:flex;align-items:center;justify-content:center;
    font-size:1.75rem;font-weight:800;color:#fff;flex-shrink:0;
    box-shadow:0 4px 16px rgba(255,107,44,.25);}
.rk-personal-info{flex:1;}
.rk-personal-name{font-family:var(--font-primary);font-size:1.125rem;font-weight:800;
    color:var(--color-text);margin-bottom:4px;}
.rk-personal-stats{display:flex;gap:var(--space-lg);flex-wrap:wrap;}
.rk-personal-stat{display:flex;flex-direction:column;align-items:flex-start;}
.rk-personal-stat-val{font-family:var(--font-primary);font-size:1.25rem;font-weight:800;color:var(--rk-indigo);}
.rk-personal-stat-lbl{font-size:.75rem;color:var(--color-text-muted);font-weight:600;}

/* ══ PODIUM ══ */
.rk-podium-section{margin-bottom:var(--space-lg);}
.rk-podium-title{font-family:var(--font-primary);font-size:1.125rem;font-weight:800;
    color:var(--color-text);margin-bottom:12px;text-align:center;
    display:flex;align-items:center;justify-content:center;gap:8px;}
.rk-podium{display:flex;align-items:flex-end;justify-content:center;gap:var(--space-md);padding-top:8px;}
.rk-podium-player{display:flex;flex-direction:column;align-items:center;text-align:center;transition:transform .2s;}
.rk-podium-player:hover{transform:translateY(-6px);}
.rk-podium-crown{font-size:1.75rem;margin-bottom:4px;color:#FACC15;filter:drop-shadow(0 2px 6px rgba(250,204,21,.5));animation:rk-sparkle 2s ease-in-out infinite;}
@keyframes rk-sparkle{0%,100%{transform:scale(1);filter:drop-shadow(0 2px 6px rgba(250,204,21,.5));}50%{transform:scale(1.1);filter:drop-shadow(0 4px 12px rgba(250,204,21,.8));}}
.rk-podium-avatar{width:52px;height:52px;border-radius:50%;display:flex;align-items:center;justify-content:center;
    font-size:1.25rem;font-weight:800;color:#fff;margin-bottom:6px;border:3px solid #fff;}
.rk-podium-player.first .rk-podium-avatar{width:68px;height:68px;font-size:1.6rem;
    background:linear-gradient(135deg,#FACC15,#F59E0B);box-shadow:0 0 20px rgba(250,204,21,.5),0 4px 16px rgba(250,204,21,.35);}
.rk-podium-player.second .rk-podium-avatar{background:linear-gradient(135deg,#CBD5E1,#94A3B8);box-shadow:0 0 12px rgba(148,163,184,.4);}
.rk-podium-player.third .rk-podium-avatar{background:linear-gradient(135deg,#FDBA74,#CD7F32);box-shadow:0 0 12px rgba(205,127,50,.4);}
.rk-podium-name{font-size:.8rem;font-weight:700;color:var(--color-text);margin-bottom:2px;max-width:90px;
    white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.rk-podium-xp{font-size:.7rem;font-weight:700;color:var(--rk-purple);margin-bottom:6px;}
.rk-podium-you{font-size:.6rem;font-weight:700;padding:2px 8px;border-radius:var(--border-radius-full);
    background:linear-gradient(135deg,#FACC15,#F59E0B);color:#fff;margin-bottom:4px;box-shadow:0 2px 6px rgba(250,204,21,.3);}
.rk-podium-block{width:90px;border-radius:14px 14px 0 0;display:flex;align-items:center;justify-content:center;
    font-family:var(--font-primary);font-size:1.75rem;font-weight:800;color:#fff;position:relative;overflow:hidden;}
.rk-podium-block::after{content:'';position:absolute;inset:0;background:linear-gradient(180deg,rgba(255,255,255,.2) 0%,transparent 50%);pointer-events:none;}
.rk-podium-player.first .rk-podium-block{height:140px;width:105px;
    background:linear-gradient(180deg,#FACC15,#D97706);box-shadow:0 -6px 24px rgba(250,204,21,.35),0 4px 20px rgba(217,119,6,.2);}
.rk-podium-player.second .rk-podium-block{height:105px;
    background:linear-gradient(180deg,#E2E8F0,#64748B);box-shadow:0 -4px 16px rgba(100,116,139,.2);}
.rk-podium-player.third .rk-podium-block{height:80px;
    background:linear-gradient(180deg,#FDBA74,#92400E);box-shadow:0 -4px 16px rgba(146,64,14,.2);}

/* ══ FILTERS ══ */
.rk-filters{margin-bottom:var(--space-lg);text-align:center;}
.rk-filters-label{font-size:.75rem;font-weight:600;color:var(--color-text-muted);margin-bottom:8px;}
.rk-filter-chips{display:flex;gap:8px;justify-content:center;flex-wrap:wrap;}
.rk-filter-chip{padding:8px 18px;border-radius:var(--border-radius-full);font-size:.8rem;font-weight:700;
    border:1.5px solid var(--border-color);background:#fff;color:var(--color-text-secondary);
    cursor:pointer;transition:all .2s;text-decoration:none;}
.rk-filter-chip:hover{border-color:var(--rk-indigo);color:var(--rk-indigo);text-decoration:none;}
.rk-filter-chip.active{background:linear-gradient(135deg,var(--rk-blue),var(--rk-purple));color:#fff;border-color:transparent;
    box-shadow:0 3px 12px rgba(79,70,229,.25);}

@media(max-width:479px){.rk-podium{gap:var(--space-sm);}.rk-podium-block{width:70px;}.rk-podium-player.first .rk-podium-block{width:80px;height:110px;}.rk-podium-player.second .rk-podium-block{height:85px;}.rk-podium-player.third .rk-podium-block{height:65px;}.rk-podium-avatar{width:40px;height:40px;font-size:1rem;}.rk-podium-player.first .rk-podium-avatar{width:50px;height:50px;}}

/* ══ LEADERBOARD ══ */
.rk-board{background:var(--color-white);border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-md);
    overflow:hidden;margin-bottom:var(--space-xl);}
.rk-board-header{background:linear-gradient(135deg,var(--rk-blue) 0%,var(--rk-indigo) 100%);
    padding:var(--space-md) var(--space-xl);display:flex;align-items:center;gap:var(--space-sm);
    color:#fff;font-family:var(--font-primary);font-weight:800;font-size:1rem;}
.rk-board-list{padding:var(--space-sm) 0;}
.rk-board-row{display:flex;align-items:center;gap:var(--space-md);
    padding:var(--space-sm) var(--space-xl);border-bottom:1px solid #FFF8E1;
    transition:background .2s;}
.rk-board-row:last-child{border-bottom:none;}
.rk-board-row:hover{background:#F8FAFC;}
.rk-board-row.rk-current{background:#EFF6FF;border-left:4px solid var(--rk-indigo);}
.rk-board-rank{width:36px;height:36px;border-radius:50%;
    display:flex;align-items:center;justify-content:center;
    font-weight:800;font-size:.875rem;flex-shrink:0;}
.rk-board-rank.rk-gold{background:linear-gradient(135deg,#FACC15,#F59E0B);color:#fff;box-shadow:0 3px 10px rgba(250,204,21,.3);}
.rk-board-rank.rk-silver{background:linear-gradient(135deg,#E8E8E8,#C0C0C0);color:#555;box-shadow:0 3px 10px rgba(192,192,192,.3);}
.rk-board-rank.rk-bronze{background:linear-gradient(135deg,#E8A96D,#CD7F32);color:#fff;box-shadow:0 3px 10px rgba(205,127,50,.3);}
.rk-board-rank.rk-normal{background:#F5F5F5;color:var(--color-text-secondary);}
.rk-board-avatar{width:40px;height:40px;border-radius:50%;
    background:#DBEAFE;display:flex;align-items:center;justify-content:center;
    font-size:1rem;font-weight:700;color:#1D4ED8;flex-shrink:0;}
.rk-board-name{flex:1;font-weight:700;font-size:.9375rem;color:var(--color-text);}
.rk-board-level{font-size:.8125rem;color:var(--color-text-secondary);font-weight:600;min-width:80px;}
.rk-board-xp{font-family:var(--font-primary);font-weight:800;font-size:.9375rem;
    color:var(--rk-purple);min-width:70px;text-align:right;}
.rk-board-badges{font-size:.8125rem;color:var(--color-text-muted);min-width:50px;text-align:center;
    display:flex;align-items:center;gap:4px;justify-content:center;}

/* ══ YOUR POSITION (outside top 10) ══ */
.rk-yourpos{background:var(--color-white);border-radius:var(--border-radius-xl);
    border:2px dashed var(--rk-gold);box-shadow:var(--shadow-sm);
    padding:var(--space-lg) var(--space-xl);margin-bottom:var(--space-xl);
    display:flex;align-items:center;gap:var(--space-lg);}
.rk-yourpos-title{font-family:var(--font-primary);font-weight:800;font-size:.9375rem;
    color:var(--rk-indigo);margin-bottom:4px;}
.rk-yourpos-info{display:flex;gap:var(--space-lg);align-items:center;flex-wrap:wrap;}
.rk-yourpos-rank{font-family:var(--font-primary);font-size:1.5rem;font-weight:800;color:var(--rk-indigo);}
.rk-yourpos-name{font-weight:700;color:var(--color-text);}
.rk-yourpos-xp{font-weight:700;color:var(--color-text-secondary);}

/* ══ MOTIVATIONAL SECTION ══ */
.rk-motivate{background:linear-gradient(135deg,#FFF8E1 0%,#FFF0E8 100%);
    border-radius:var(--border-radius-xl);border:1.5px solid #FFE4B8;
    padding:var(--space-xl);margin-bottom:var(--space-xl);
    text-align:center;}
.rk-motivate-icon{font-size:2.5rem;margin-bottom:var(--space-sm);}
.rk-motivate-msg{font-family:var(--font-primary);font-size:1.0625rem;font-weight:700;
    color:var(--color-text);line-height:1.5;}

/* ══ XP TIPS ══ */
.rk-tips{margin-bottom:var(--space-xl);}
.rk-tips-title{font-family:var(--font-primary);font-size:1.0625rem;font-weight:800;
    color:var(--color-text);margin-bottom:var(--space-md);display:flex;align-items:center;gap:var(--space-sm);}
.rk-tips-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:var(--space-md);}
.rk-tip-card{background:var(--color-white);border-radius:var(--border-radius-lg);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);
    padding:var(--space-lg);text-align:center;transition:transform .2s,box-shadow .2s;}
.rk-tip-card:hover{transform:translateY(-4px);box-shadow:var(--shadow-md);}
.rk-tip-icon{font-size:1.75rem;margin-bottom:var(--space-sm);}
.rk-tip-label{font-size:.875rem;font-weight:700;color:var(--color-text);}

/* ══ NAVIGATION BUTTONS ══ */
.rk-nav{display:flex;gap:var(--space-md);flex-wrap:wrap;margin-bottom:var(--space-xl);}
.rk-nav-btn{display:inline-flex;align-items:center;gap:6px;padding:12px 24px;
    border-radius:var(--border-radius-full);font-weight:700;font-size:.9375rem;
    text-decoration:none;transition:all .2s;border:2px solid transparent;}
.rk-nav-btn-primary{background:linear-gradient(135deg,var(--rk-blue),var(--rk-purple));color:#fff;
    box-shadow:0 4px 16px rgba(79,70,229,.25);}
.rk-nav-btn-primary:hover{transform:translateY(-2px);box-shadow:0 6px 20px rgba(79,70,229,.35);text-decoration:none;color:#fff;}
.rk-nav-btn-secondary{background:var(--color-white);color:var(--color-text);
    border-color:var(--border-color);box-shadow:var(--shadow-sm);}
.rk-nav-btn-secondary:hover{transform:translateY(-2px);box-shadow:var(--shadow-md);text-decoration:none;color:var(--color-text);}

/* ══ RESPONSIVE ══ */
@media(max-width:1023px){
    .rk-tips-grid{grid-template-columns:repeat(2,1fr);}
}
@media(max-width:767px){
    .rk-hero{flex-direction:column;padding:var(--space-xl) var(--space-lg);}
    .rk-hero-title{font-size:1.5rem;}
    .rk-personal{flex-direction:column;text-align:center;}
    .rk-personal-stats{justify-content:center;}
    .rk-board-row{padding:var(--space-sm) var(--space-md);gap:var(--space-sm);}
    .rk-board-level{display:none;}
    .rk-tips-grid{grid-template-columns:repeat(2,1fr);}
    .rk-nav{flex-direction:column;}
    .rk-nav-btn{justify-content:center;}
    .rk-yourpos{flex-direction:column;text-align:center;}
}
@media(max-width:479px){
    .rk-hero{padding:var(--space-lg) var(--space-md);}
    .rk-hero-title{font-size:1.25rem;}
    .rk-tips-grid{grid-template-columns:1fr 1fr;gap:var(--space-sm);}
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
        <a href="<%: ResolveUrl("~/Student/MyRanking.aspx") %>" class="sb-sidebar-item active">
            <i class="bi bi-trophy item-icon"></i><span class="item-label">My Ranking</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Student/MyProfile.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span>
        </a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <asp:Literal ID="litPageTitle" runat="server" Text="My Ranking" />
</asp:Content>

<%-- ════ MAIN CONTENT ════ --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- ── RANKING HERO ── --%>
<div class="rk-hero">
    <div class="rk-hero-blob1"></div><div class="rk-hero-blob2"></div>
    <div class="rk-hero-left">
        <div class="rk-hero-title"><i class="bi bi-trophy-fill" style="color:var(--rk-gold);"></i> <asp:Literal ID="litHeroRank" runat="server" Text="#1" /></div>
        <div class="rk-hero-sub"><asp:Literal ID="litHeroMessage" runat="server" Text="See your position and keep improving step by step." /></div>
        <div class="rk-hero-chips">
            <span class="rk-hero-chip rk-rank-chip"><i class="bi bi-trophy-fill"></i> <asp:Literal ID="litHeroXP" runat="server" Text="0 XP" /></span>
            <span class="rk-hero-chip"><i class="bi bi-bar-chart-fill"></i> <asp:Literal ID="litHeroLevel" runat="server" Text="Level: —" /></span>
        </div>
    </div>
    <div class="rk-hero-right">
        <div class="rk-hero-trophy"><i class="bi bi-trophy-fill" style="font-size:4.5rem;color:var(--rk-gold);filter:drop-shadow(0 4px 12px rgba(0,0,0,.2));"></i></div>
    </div>
</div>

<%-- ── PERSONAL RANK CARD ── --%>
<div class="rk-personal">
    <div class="rk-personal-avatar"><asp:Literal ID="litPersonalInitial" runat="server" Text="S" /></div>
    <div class="rk-personal-info">
        <div class="rk-personal-name"><asp:Literal ID="litPersonalName" runat="server" Text="Student" /></div>
        <div class="rk-personal-stats">
            <div class="rk-personal-stat">
                <span class="rk-personal-stat-val"><asp:Literal ID="litPersonalRank" runat="server" Text="#—" /></span>
                <span class="rk-personal-stat-lbl"><asp:Literal ID="litPersonalRankLbl" runat="server" Text="Rank" /></span>
            </div>
            <div class="rk-personal-stat">
                <span class="rk-personal-stat-val"><asp:Literal ID="litPersonalXP" runat="server" Text="0" /></span>
                <span class="rk-personal-stat-lbl">XP</span>
            </div>
            <div class="rk-personal-stat">
                <span class="rk-personal-stat-val"><asp:Literal ID="litPersonalLevel" runat="server" Text="—" /></span>
                <span class="rk-personal-stat-lbl"><asp:Literal ID="litPersonalLevelLbl" runat="server" Text="Level" /></span>
            </div>
            <div class="rk-personal-stat">
                <span class="rk-personal-stat-val"><asp:Literal ID="litPersonalBadges" runat="server" Text="0" /></span>
                <span class="rk-personal-stat-lbl"><asp:Literal ID="litPersonalBadgesLbl" runat="server" Text="Badges" /></span>
            </div>
        </div>
    </div>
</div>

<%-- ── TOP 3 PODIUM ── --%>
<div class="rk-podium-section">
    <div class="rk-podium-title"><i class="bi bi-trophy-fill" style="color:var(--rk-gold);"></i> <asp:Literal ID="litPodiumTitle" runat="server" Text="Top 3 Champions" /></div>
    <asp:Literal ID="litPodium" runat="server" />
</div>

<%-- ── FILTERS ── --%>
<div class="rk-filters">
    <div class="rk-filters-label"><asp:Literal ID="litFilterLabel" runat="server" Text="Filter leaderboard" /></div>
    <div class="rk-filter-chips">
        <asp:LinkButton ID="btnFilterAll" runat="server" CssClass="rk-filter-chip active" OnClick="btnFilter_Click" CommandArgument="all" CausesValidation="false"><asp:Literal ID="litFAll" runat="server" Text="All Students" /></asp:LinkButton>
        <asp:LinkButton ID="btnFilterLevel" runat="server" CssClass="rk-filter-chip" OnClick="btnFilter_Click" CommandArgument="level" CausesValidation="false"><asp:Literal ID="litFLevel" runat="server" Text="My Level" /></asp:LinkButton>
        <asp:LinkButton ID="btnFilterPers" runat="server" CssClass="rk-filter-chip" OnClick="btnFilter_Click" CommandArgument="personality" CausesValidation="false"><asp:Literal ID="litFPers" runat="server" Text="My Personality" /></asp:LinkButton>
    </div>
</div>

<%-- ── TOP 10 LEADERBOARD ── --%>
<div class="rk-board">
    <div class="rk-board-header"><i class="bi bi-trophy-fill"></i> &nbsp;<asp:Literal ID="litBoardTitle" runat="server" Text="Top 10 Leaderboard" /></div>
    <div class="rk-board-list">
        <asp:Panel ID="pnlBoard" runat="server">
            <asp:Repeater ID="rptLeaderboard" runat="server">
                <ItemTemplate>
                    <div class='<%# (bool)Eval("IsCurrentUser") ? "rk-board-row rk-current" : "rk-board-row" %>'>
                        <div class='<%# GetRankClass((int)Eval("Rank")) %>'><%# Eval("Rank") %></div>
                        <div class="rk-board-avatar"><%# Eval("Initial") %></div>
                        <div class="rk-board-name"><%# Eval("DisplayName") %></div>
                        <div class="rk-board-level"><%# Eval("LevelName") %></div>
                        <div class="rk-board-xp"><%# Eval("XP") %> XP</div>
                        <div class="rk-board-badges"><i class="bi bi-award-fill"></i> <%# Eval("BadgeCount") %></div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </asp:Panel>
    </div>
</div>

<%-- ── YOUR POSITION (shown if not in top 10) ── --%>
<asp:Panel ID="pnlYourPosition" runat="server" Visible="false">
    <div class="rk-yourpos">
        <div>
            <div class="rk-yourpos-title"><asp:Literal ID="litYourPosTitle" runat="server" Text="Your Position" /></div>
            <div class="rk-yourpos-info">
                <span class="rk-yourpos-rank"><asp:Literal ID="litYourPosRank" runat="server" Text="#—" /></span>
                <span class="rk-yourpos-name"><asp:Literal ID="litYourPosName" runat="server" Text="—" /></span>
                <span class="rk-yourpos-xp"><asp:Literal ID="litYourPosXP" runat="server" Text="0 XP" /></span>
            </div>
        </div>
    </div>
</asp:Panel>

<%-- ── MOTIVATIONAL SECTION ── --%>
<div class="rk-motivate">
    <div class="rk-motivate-icon">💪</div>
    <div class="rk-motivate-msg"><asp:Literal ID="litMotivateMsg" runat="server" Text="Every lesson gives you XP. Keep learning and your rank will improve." /></div>
</div>

<%-- ── XP TIPS ── --%>
<div class="rk-tips">
    <div class="rk-tips-title"><span>💡</span> <asp:Literal ID="litTipsTitle" runat="server" Text="Ways to Earn XP" /></div>
    <div class="rk-tips-grid">
        <div class="rk-tip-card">
            <div class="rk-tip-icon">📖</div>
            <div class="rk-tip-label"><asp:Literal ID="litTip1" runat="server" Text="Complete lessons" /></div>
        </div>
        <div class="rk-tip-card">
            <div class="rk-tip-icon">🧪</div>
            <div class="rk-tip-label"><asp:Literal ID="litTip2" runat="server" Text="Complete virtual labs" /></div>
        </div>
        <div class="rk-tip-card">
            <div class="rk-tip-icon">❓</div>
            <div class="rk-tip-label"><asp:Literal ID="litTip3" runat="server" Text="Attempt practice quizzes" /></div>
        </div>
        <div class="rk-tip-card">
            <div class="rk-tip-icon">✅</div>
            <div class="rk-tip-label"><asp:Literal ID="litTip4" runat="server" Text="Pass unit quizzes" /></div>
        </div>
    </div>
</div>

<%-- ── NAVIGATION BUTTONS ── --%>
<div class="rk-nav">
    <a href="<%: ResolveUrl("~/Student/ProgressRewards.aspx") %>" class="rk-nav-btn rk-nav-btn-secondary">
        <i class="bi bi-arrow-left"></i> <asp:Literal ID="litNavBack" runat="server" Text="Back to Progress & Rewards" />
    </a>
    <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="rk-nav-btn rk-nav-btn-primary">
        <i class="bi bi-play-circle-fill"></i> <asp:Literal ID="litNavLearn" runat="server" Text="Continue Learning" />
    </a>
    <a href="<%: ResolveUrl("~/Student/PracticeLibrary.aspx") %>" class="rk-nav-btn rk-nav-btn-secondary">
        <i class="bi bi-patch-question-fill"></i> <asp:Literal ID="litNavPractice" runat="server" Text="Practice Library" />
    </a>
</div>

</asp:Content>
