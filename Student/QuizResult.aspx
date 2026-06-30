<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="QuizResult.aspx.cs"
    Inherits="ScienceBuddy.Student.QuizResultPage" MasterPageFile="~/Site.Master" Title="Quiz Result" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--qr-green:#22C55E;--qr-red:#EF4444;--qr-orange:#FF6B2C;--qr-blue:#2563EB;--qr-gold:#FFD84D;}

.qr-hero{border-radius:var(--border-radius-xl);padding:var(--space-2xl);color:#fff;text-align:center;
    position:relative;overflow:hidden;margin-bottom:var(--space-xl);box-shadow:0 12px 40px rgba(0,0,0,.15);}
.qr-hero.passed{background:linear-gradient(135deg,#15803D 0%,var(--qr-green) 50%,#4ADE80 100%);}
.qr-hero.failed{background:linear-gradient(135deg,#991B1B 0%,var(--qr-red) 50%,#FCA5A5 100%);}
.qr-hero-blob{position:absolute;width:220px;height:220px;border-radius:50%;
    background:rgba(255,255,255,.07);top:-70px;right:-50px;pointer-events:none;}
.qr-hero-icon{font-size:3.5rem;margin-bottom:var(--space-sm);}
.qr-hero-title{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;margin-bottom:4px;}
.qr-hero-sub{font-size:.95rem;opacity:.9;margin-bottom:var(--space-lg);max-width:500px;margin-left:auto;margin-right:auto;line-height:1.5;}

/* Score Ring */
.qr-score-wrap{display:flex;flex-direction:column;align-items:center;gap:var(--space-sm);margin-bottom:var(--space-md);}
.qr-score-ring{display:inline-flex;align-items:center;justify-content:center;width:130px;height:130px;
    border-radius:50%;background:rgba(255,255,255,.18);border:6px solid rgba(255,255,255,.5);
    font-family:var(--font-primary);font-size:2.5rem;font-weight:800;}
.qr-stars{display:flex;gap:4px;font-size:1.5rem;}
.qr-star-on{color:var(--qr-gold);filter:drop-shadow(0 2px 4px rgba(0,0,0,.15));}
.qr-star-off{color:rgba(255,255,255,.3);}

/* Summary Cards */
.qr-stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:var(--space-md);margin-bottom:var(--space-xl);}
.qr-stat{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);
    box-shadow:var(--shadow-sm);padding:var(--space-lg);text-align:center;transition:transform .2s;}
.qr-stat:hover{transform:translateY(-3px);box-shadow:var(--shadow-md);}
.qr-stat-icon{width:44px;height:44px;border-radius:var(--border-radius);display:flex;align-items:center;
    justify-content:center;font-size:1.25rem;margin:0 auto var(--space-sm);}
.qr-stat-val{font-family:var(--font-primary);font-size:1.5rem;font-weight:800;color:var(--color-text);}
.qr-stat-lbl{font-size:.8125rem;color:var(--color-text-secondary);font-weight:600;margin-top:4px;}

/* Message Card */
.qr-msg{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);
    box-shadow:var(--shadow-sm);padding:var(--space-xl);margin-bottom:var(--space-xl);
    display:flex;align-items:flex-start;gap:var(--space-md);}
.qr-msg-icon{width:48px;height:48px;border-radius:var(--border-radius);display:flex;align-items:center;
    justify-content:center;font-size:1.5rem;flex-shrink:0;}
.qr-msg-body{flex:1;}
.qr-msg-title{font-family:var(--font-primary);font-weight:700;font-size:.9375rem;color:var(--color-text);margin-bottom:4px;}
.qr-msg-text{font-size:.875rem;color:var(--color-text-secondary);line-height:1.6;}

/* Actions */
.qr-actions{display:flex;gap:var(--space-md);justify-content:center;flex-wrap:wrap;}
.qr-btn{display:inline-flex;align-items:center;gap:8px;padding:12px 28px;border-radius:var(--border-radius-full);
    font-weight:700;font-size:.9375rem;text-decoration:none;transition:all .2s;border:none;cursor:pointer;}
.qr-btn-primary{background:var(--qr-blue);color:#fff;box-shadow:0 4px 12px rgba(37,99,235,.3);}
.qr-btn-primary:hover{background:#1D4ED8;transform:translateY(-2px);color:#fff;text-decoration:none;}
.qr-btn-retry{background:var(--qr-orange);color:#fff;box-shadow:0 4px 12px rgba(255,107,44,.3);}
.qr-btn-retry:hover{transform:translateY(-2px);color:#fff;text-decoration:none;}
.qr-btn-secondary{background:#F3F4F6;color:var(--color-text);border:1.5px solid var(--border-color);}
.qr-btn-secondary:hover{background:#E5E7EB;text-decoration:none;color:var(--color-text);}
.qr-btn-green{background:var(--qr-green);color:#fff;box-shadow:0 4px 12px rgba(34,197,94,.3);}
.qr-btn-green:hover{transform:translateY(-2px);color:#fff;text-decoration:none;}

/* Error */
.qr-error{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);
    box-shadow:var(--shadow-sm);padding:var(--space-2xl);text-align:center;}

@media(max-width:767px){
    .qr-hero{padding:var(--space-xl);}
    .qr-hero-title{font-size:1.375rem;}
    .qr-score-ring{width:100px;height:100px;font-size:2rem;}
    .qr-stats{grid-template-columns:repeat(2,1fr);}
    .qr-actions{flex-direction:column;align-items:stretch;}
    .qr-btn{justify-content:center;}
}
</style>
</asp:Content>

<asp:Content ID="cSidebarMenu" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label">Main</div>
        <a href="<%: ResolveUrl("~/Student/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label">Dashboard</span></a>
        <a href="<%: ResolveUrl("~/Student/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Learn</div>
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label">My Learning</span></a>
        <a href="<%: ResolveUrl("~/Student/PracticeLibrary.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label">Practice Library</span></a>
        <a href="<%: ResolveUrl("~/Student/VirtualLabs.aspx") %>" class="sb-sidebar-item"><i class="bi bi-eyedropper item-icon"></i><span class="item-label">Virtual Labs</span></a>
        <a href="<%: ResolveUrl("~/Student/LiveSessions.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label">Live Sessions</span></a>
        <a href="<%: ResolveUrl("~/Student/AIStudyCompanion.aspx") %>" class="sb-sidebar-item"><i class="bi bi-robot item-icon"></i><span class="item-label">AI Study Companion</span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Progress</div>
        <a href="<%: ResolveUrl("~/Student/ProgressRewards.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bar-chart-line item-icon"></i><span class="item-label">Progress &amp; Rewards</span></a>
        <a href="<%: ResolveUrl("~/Student/Forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label">Forum</span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Student/Messages.aspx") %>" class="sb-sidebar-item"><i class="bi bi-envelope item-icon"></i><span class="item-label">Messages</span></a>
        <a href="<%: ResolveUrl("~/Student/MyProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a></div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <asp:Literal ID="litPageTitle" runat="server" Text="Quiz Result" />
</asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- ERROR --%>
<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="qr-error">
        <div style="font-size:3rem;margin-bottom:var(--space-md);"><i class="bi bi-exclamation-triangle-fill" style="color:var(--qr-orange);"></i></div>
        <div style="font-family:var(--font-primary);font-size:1.25rem;font-weight:700;margin-bottom:8px;"><asp:Literal ID="litErrorTitle" runat="server" /></div>
        <div style="color:var(--color-text-secondary);margin-bottom:var(--space-lg);"><asp:Literal ID="litError" runat="server" /></div>
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="qr-btn qr-btn-primary"><i class="bi bi-arrow-left"></i> <asp:Literal ID="litErrBtn" runat="server" Text="Back" /></a>
    </div>
</asp:Panel>

<%-- RESULT --%>
<asp:Panel ID="pnlResult" runat="server" Visible="false">

    <%-- Hero --%>
    <div class="qr-hero" id="divHero" runat="server">
        <div class="qr-hero-blob"></div>
        <div class="qr-hero-icon"><asp:Literal ID="litHeroIcon" runat="server" /></div>
        <div class="qr-hero-title"><asp:Literal ID="litHeroTitle" runat="server" /></div>
        <div class="qr-hero-sub"><asp:Literal ID="litHeroSub" runat="server" /></div>
        <div class="qr-score-wrap">
            <div class="qr-score-ring"><asp:Literal ID="litScorePct" runat="server" /></div>
            <div class="qr-stars"><asp:Literal ID="litStars" runat="server" /></div>
        </div>
    </div>

    <%-- Stats --%>
    <div class="qr-stats">
        <div class="qr-stat">
            <div class="qr-stat-icon" style="background:#DCFCE7;color:#15803D;"><i class="bi bi-check-circle-fill"></i></div>
            <div class="qr-stat-val"><asp:Literal ID="litStatCorrect" runat="server" /></div>
            <div class="qr-stat-lbl"><asp:Literal ID="litStatCorrectLbl" runat="server" Text="Correct" /></div>
        </div>
        <div class="qr-stat">
            <div class="qr-stat-icon" style="background:#FEF2F2;color:#DC2626;"><i class="bi bi-x-circle-fill"></i></div>
            <div class="qr-stat-val"><asp:Literal ID="litStatWrong" runat="server" /></div>
            <div class="qr-stat-lbl"><asp:Literal ID="litStatWrongLbl" runat="server" Text="Wrong" /></div>
        </div>
        <div class="qr-stat">
            <div class="qr-stat-icon" style="background:#EFF6FF;color:#2563EB;"><i class="bi bi-list-check"></i></div>
            <div class="qr-stat-val"><asp:Literal ID="litStatTotal" runat="server" /></div>
            <div class="qr-stat-lbl"><asp:Literal ID="litStatTotalLbl" runat="server" Text="Questions" /></div>
        </div>
        <div class="qr-stat">
            <div class="qr-stat-icon" style="background:#FFF0E8;color:#FF6B2C;"><i class="bi bi-trophy-fill"></i></div>
            <div class="qr-stat-val"><asp:Literal ID="litStatScore" runat="server" /></div>
            <div class="qr-stat-lbl"><asp:Literal ID="litStatScoreLbl" runat="server" Text="Score" /></div>
        </div>
        <div class="qr-stat">
            <div class="qr-stat-icon" style="background:#F3E8FF;color:#7C3AED;"><i class="bi bi-arrow-repeat"></i></div>
            <div class="qr-stat-val"><asp:Literal ID="litStatAttempt" runat="server" /></div>
            <div class="qr-stat-lbl"><asp:Literal ID="litStatAttemptLbl" runat="server" Text="Attempt" /></div>
        </div>
    </div>

    <%-- Quiz Type Message --%>
    <asp:Panel ID="pnlMessage" runat="server" Visible="false">
        <div class="qr-msg">
            <div class="qr-msg-icon" id="divMsgIcon" runat="server" style="background:#EFF6FF;color:#2563EB;"><i class="bi bi-info-circle-fill"></i></div>
            <div class="qr-msg-body">
                <div class="qr-msg-title"><asp:Literal ID="litMsgTitle" runat="server" /></div>
                <div class="qr-msg-text"><asp:Literal ID="litMessage" runat="server" /></div>
            </div>
        </div>
    </asp:Panel>

    <%-- Actions --%>
    <div class="qr-actions">
        <a href="#" id="lnkReview" runat="server" class="qr-btn qr-btn-primary"><i class="bi bi-search"></i> <asp:Literal ID="litReviewBtn" runat="server" Text="Review Answers" /></a>
        <asp:Panel ID="pnlRetry" runat="server" style="display:inline;">
            <a href="#" id="lnkRetry" runat="server" class="qr-btn qr-btn-retry"><i class="bi bi-arrow-repeat"></i> <asp:Literal ID="litRetryBtn" runat="server" Text="Try Again" /></a>
        </asp:Panel>
        <a href="#" id="lnkBack" runat="server" class="qr-btn qr-btn-secondary"><i class="bi bi-arrow-left"></i> <asp:Literal ID="litBackBtn" runat="server" Text="Back" /></a>
        <a href="<%: ResolveUrl("~/Student/ProgressRewards.aspx") %>" class="qr-btn qr-btn-green"><i class="bi bi-bar-chart-line-fill"></i> <asp:Literal ID="litProgressBtn" runat="server" Text="Progress" /></a>
        <a href="<%: ResolveUrl("~/Student/QuizHistory.aspx") %>" class="qr-btn qr-btn-secondary"><i class="bi bi-clock-history"></i> <asp:Literal ID="litHistoryBtn" runat="server" Text="Quiz History" /></a>
    </div>

</asp:Panel>
</asp:Content>
