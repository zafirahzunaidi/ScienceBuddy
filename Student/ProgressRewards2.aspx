<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ProgressRewards2.aspx.cs"
    Inherits="ScienceBuddy.Student.ProgressRewards" MasterPageFile="~/Site.Master"
    Title="Progress & Rewards" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ── Progress & Rewards ── */
:root{--pr-blue:#2563EB;--pr-indigo:#4F46E5;--pr-purple:#7C3AED;--pr-gold:#FACC15;--pr-gold-soft:#FEF3C7;--pr-green:#22C55E;--pr-light:#EFF6FF;}

/* ══ HERO SECTION ══ */
.pr-hero{background:linear-gradient(135deg,#2563EB 0%,#4F46E5 45%,#7C3AED 100%);
    border-radius:var(--border-radius-xl);padding:var(--space-xl) var(--space-2xl);
    color:#fff;margin-bottom:var(--space-xl);position:relative;overflow:hidden;
    box-shadow:0 8px 32px rgba(79,70,229,.25);}
.pr-hero::before{content:'';position:absolute;width:120px;height:120px;top:-20px;right:40px;
    background:rgba(250,204,21,.15);border-radius:50%;pointer-events:none;}
.pr-hero::after{content:'';position:absolute;width:80px;height:80px;bottom:20px;right:140px;
    background:rgba(255,255,255,.06);border-radius:50%;pointer-events:none;}
.pr-hero-name{font-family:var(--font-primary);font-size:1.5rem;font-weight:800;
    margin-bottom:var(--space-xs);}
.pr-hero-meta{display:flex;flex-wrap:wrap;gap:var(--space-md);margin-bottom:var(--space-sm);
    font-size:.9375rem;opacity:.95;}
.pr-hero-meta span{display:flex;align-items:center;gap:6px;}
.pr-hero-motivate{font-size:.875rem;opacity:.88;font-style:italic;margin-top:var(--space-sm);}

/* ══ XP PROGRESS BAR ══ */
.pr-xp{background:var(--color-white);border-radius:var(--border-radius-xl);
    padding:var(--space-lg) var(--space-xl);margin-bottom:var(--space-xl);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);}
.pr-xp-header{display:flex;justify-content:space-between;align-items:center;
    margin-bottom:var(--space-md);}
.pr-xp-title{font-family:var(--font-primary);font-size:1.125rem;font-weight:800;
    color:var(--color-text);}
.pr-xp-milestone{font-size:.8125rem;color:var(--color-text-secondary);font-weight:600;}
.pr-xp-bar-outer{width:100%;height:24px;background:#F3F4F6;border-radius:12px;
    overflow:hidden;position:relative;}
.pr-xp-bar-inner{height:100%;border-radius:12px;
    background:linear-gradient(90deg,#2563EB,#7C3AED);
    transition:width .8s cubic-bezier(.4,0,.2,1);position:relative;min-width:2%;}
.pr-xp-bar-inner::after{content:'';position:absolute;top:0;left:0;right:0;bottom:0;
    background:linear-gradient(180deg,rgba(255,255,255,.25) 0%,transparent 50%);
    border-radius:12px;}
.pr-xp-labels{display:flex;justify-content:space-between;margin-top:var(--space-xs);
    font-size:.75rem;color:var(--color-text-secondary);font-weight:600;}

/* ══ PROGRESS SUMMARY CARDS ══ */
.pr-summary{display:grid;grid-template-columns:repeat(auto-fill,minmax(180px,1fr));
    gap:var(--space-md);margin-bottom:var(--space-xl);}
.pr-stat-card{background:var(--color-white);border-radius:var(--border-radius-lg);
    padding:var(--space-lg);border:1.5px solid var(--border-color);
    box-shadow:var(--shadow-sm);text-align:center;transition:transform .2s,box-shadow .2s;}
.pr-stat-card:hover{transform:translateY(-3px);box-shadow:var(--shadow-md);}
.pr-stat-icon{font-size:2rem;margin-bottom:var(--space-sm);}
.pr-stat-value{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;
    color:var(--pr-indigo);line-height:1;}
.pr-stat-label{font-size:.8125rem;color:var(--color-text-secondary);font-weight:600;
    margin-top:var(--space-xs);}

/* ══ SECTION TITLES ══ */
.pr-section-title{font-family:var(--font-primary);font-size:1.25rem;font-weight:800;
    color:var(--color-text);margin-bottom:var(--space-lg);display:flex;
    align-items:center;gap:var(--space-sm);}

/* ══ BADGE COLLECTION ══ */
.pr-badges{margin-bottom:var(--space-xl);}
.pr-badge-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));
    gap:var(--space-md);}
.pr-badge-card{background:var(--color-white);border-radius:var(--border-radius-lg);
    padding:var(--space-lg);border:1.5px solid var(--border-color);
    box-shadow:var(--shadow-sm);text-align:center;position:relative;
    transition:transform .2s,box-shadow .2s;}
.pr-badge-card:hover{transform:translateY(-3px);box-shadow:var(--shadow-md);}
.pr-badge-card.earned{border-color:var(--pr-gold);
    box-shadow:0 4px 16px rgba(250,204,21,.20);}
.pr-badge-card.earned::before{content:'';position:absolute;top:0;left:0;right:0;height:3px;
    background:linear-gradient(90deg,var(--pr-gold),#F59E0B);}
.pr-badge-card.locked{opacity:.6;filter:grayscale(.5);}
.pr-badge-icon{font-size:2.5rem;margin-bottom:var(--space-sm);}
.pr-badge-name{font-family:var(--font-primary);font-size:.9375rem;font-weight:700;
    color:var(--color-text);margin-bottom:var(--space-xs);}
.pr-badge-desc{font-size:.75rem;color:var(--color-text-secondary);
    margin-bottom:var(--space-xs);line-height:1.4;}
.pr-badge-req{font-size:.6875rem;color:var(--color-text-secondary);
    font-style:italic;margin-bottom:var(--space-sm);}
.pr-badge-xp{font-size:.75rem;font-weight:700;color:var(--pr-purple);}
.pr-badge-status{display:inline-block;font-size:.6875rem;font-weight:700;
    padding:3px 10px;border-radius:var(--border-radius-full);margin-top:var(--space-sm);}
.pr-badge-status.earned-tag{background:#DCFCE7;color:#15803D;}
.pr-badge-status.locked-tag{background:#F1F5F9;color:#94A3B8;}
.pr-lock-icon{font-size:1.5rem;color:#CBD5E1;position:absolute;top:12px;right:12px;}

/* ══ XP ACTIVITY ══ */
.pr-xp-activity{margin-bottom:var(--space-xl);}
.pr-activity-list{background:var(--color-white);border-radius:var(--border-radius-lg);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);overflow:hidden;}
.pr-activity-item{display:flex;align-items:center;justify-content:space-between;
    padding:var(--space-md) var(--space-lg);border-bottom:1px solid var(--border-color);
    transition:background .15s;}
.pr-activity-item:last-child{border-bottom:none;}
.pr-activity-item:hover{background:var(--pr-light);}
.pr-activity-left{display:flex;align-items:center;gap:var(--space-md);}
.pr-activity-icon{width:36px;height:36px;border-radius:50%;
    background:linear-gradient(135deg,var(--pr-blue),var(--pr-purple));
    display:flex;align-items:center;justify-content:center;color:#fff;font-size:.875rem;}
.pr-activity-name{font-size:.875rem;font-weight:600;color:var(--color-text);}
.pr-activity-date{font-size:.75rem;color:var(--color-text-secondary);}
.pr-activity-xp{font-size:.9375rem;font-weight:800;color:var(--pr-purple);}
.pr-empty-state{text-align:center;padding:var(--space-2xl);color:var(--color-text-secondary);
    font-size:.9375rem;}
.pr-empty-state i{font-size:2.5rem;display:block;margin-bottom:var(--space-sm);opacity:.5;}

/* ══ CERTIFICATES ══ */
.pr-certs{margin-bottom:var(--space-xl);}
.pr-cert-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));
    gap:var(--space-md);}
.pr-cert-card{background:var(--color-white);border-radius:var(--border-radius-lg);
    padding:var(--space-lg);border:1.5px solid var(--border-color);
    box-shadow:var(--shadow-sm);position:relative;overflow:hidden;
    transition:transform .2s,box-shadow .2s;}
.pr-cert-card:hover{transform:translateY(-3px);box-shadow:var(--shadow-md);}
.pr-cert-card::before{content:'';position:absolute;top:0;left:0;right:0;height:4px;
    background:linear-gradient(90deg,var(--pr-blue),var(--pr-purple));}
.pr-cert-icon{font-size:2rem;margin-bottom:var(--space-sm);}
.pr-cert-title{font-family:var(--font-primary);font-size:1rem;font-weight:700;
    color:var(--color-text);margin-bottom:var(--space-xs);}
.pr-cert-level{font-size:.8125rem;color:var(--color-text-secondary);margin-bottom:var(--space-xs);}
.pr-cert-date{font-size:.75rem;color:var(--color-text-secondary);margin-bottom:var(--space-md);}
.pr-cert-btn{display:inline-flex;align-items:center;gap:6px;padding:8px 16px;
    border-radius:var(--border-radius-full);font-weight:700;font-size:.8125rem;
    text-decoration:none;background:var(--pr-blue);color:#fff;
    transition:all .2s;border:none;cursor:pointer;}
.pr-cert-btn:hover{background:var(--pr-indigo);transform:translateY(-1px);
    box-shadow:0 4px 12px rgba(79,70,229,.30);text-decoration:none;color:#fff;}

/* ══ RESPONSIVE ══ */
@media(max-width:767px){
    .pr-summary{grid-template-columns:repeat(2,1fr);}
    .pr-badge-grid{grid-template-columns:repeat(auto-fill,minmax(160px,1fr));}
    .pr-cert-grid{grid-template-columns:1fr;}
    .pr-hero{padding:var(--space-lg);}
    .pr-hero-name{font-size:1.25rem;}
}
@media(max-width:479px){
    .pr-summary{grid-template-columns:1fr 1fr;}
    .pr-badge-grid{grid-template-columns:1fr 1fr;}
    .pr-xp-header{flex-direction:column;align-items:flex-start;gap:var(--space-xs);}
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
        <a href="<%: ResolveUrl("~/Student/ProgressRewards.aspx") %>" class="sb-sidebar-item active">
            <i class="bi bi-bar-chart-line item-icon"></i><span class="item-label">Progress &amp; Rewards</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/MyRanking.aspx") %>" class="sb-sidebar-item">
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
    <asp:Literal ID="litPageTitle" runat="server" Text="Progress &amp; Rewards" />
</asp:Content>

<%-- ════ MAIN CONTENT ════ --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- ── HERO SECTION ── --%>
<div class="pr-hero">
    <div class="pr-hero-name">🏆 <asp:Literal ID="litHeroName" runat="server" /></div>
    <div class="pr-hero-meta">
        <span><i class="bi bi-trophy"></i> <asp:Literal ID="litHeroLevel" runat="server" /></span>
        <span><i class="bi bi-star-fill"></i> <asp:Literal ID="litHeroXP" runat="server" /> XP</span>
        <span><i class="bi bi-emoji-smile"></i> <asp:Literal ID="litHeroPersonality" runat="server" /></span>
    </div>
    <div class="pr-hero-motivate"><asp:Literal ID="litHeroMotivate" runat="server" /></div>
</div>

<%-- ── XP PROGRESS BAR ── --%>
<div class="pr-xp">
    <div class="pr-xp-header">
        <div class="pr-xp-title"><i class="bi bi-lightning-charge-fill" style="color:var(--pr-orange);"></i> <asp:Literal ID="litXpTitle" runat="server" Text="XP Progress" /></div>
        <div class="pr-xp-milestone"><asp:Literal ID="litXpMilestone" runat="server" /></div>
    </div>
    <div class="pr-xp-bar-outer">
        <div class="pr-xp-bar-inner" style="width:<%= XpPercent %>%;"></div>
    </div>
    <div class="pr-xp-labels">
        <span><asp:Literal ID="litXpCurrent" runat="server" /></span>
        <span><asp:Literal ID="litXpNext" runat="server" /></span>
    </div>
</div>

<%-- ── PROGRESS SUMMARY CARDS ── --%>
<div class="pr-summary">
    <div class="pr-stat-card">
        <div class="pr-stat-icon"><i class="bi bi-book-fill" style="color:#2563EB;"></i></div>
        <div class="pr-stat-value"><asp:Literal ID="litLessonsCount" runat="server" Text="0" /></div>
        <div class="pr-stat-label"><asp:Literal ID="litLessonsLabel" runat="server" Text="Lessons Completed" /></div>
    </div>
    <div class="pr-stat-card">
        <div class="pr-stat-icon"><i class="bi bi-eyedropper" style="color:#7C3AED;"></i></div>
        <div class="pr-stat-value"><asp:Literal ID="litLabsCount" runat="server" Text="0" /></div>
        <div class="pr-stat-label"><asp:Literal ID="litLabsLabel" runat="server" Text="Labs Completed" /></div>
    </div>
    <div class="pr-stat-card">
        <div class="pr-stat-icon"><i class="bi bi-patch-question-fill" style="color:#0EA5E9;"></i></div>
        <div class="pr-stat-value"><asp:Literal ID="litQuizzesCount" runat="server" Text="0" /></div>
        <div class="pr-stat-label"><asp:Literal ID="litQuizzesLabel" runat="server" Text="Quizzes Attempted" /></div>
    </div>
    <div class="pr-stat-card">
        <div class="pr-stat-icon"><i class="bi bi-award-fill" style="color:#F59E0B;"></i></div>
        <div class="pr-stat-value"><asp:Literal ID="litBadgesCount" runat="server" Text="0" /></div>
        <div class="pr-stat-label"><asp:Literal ID="litBadgesLabel" runat="server" Text="Badges Earned" /></div>
    </div>
    <div class="pr-stat-card">
        <div class="pr-stat-icon"><i class="bi bi-file-earmark-check-fill" style="color:#15803D;"></i></div>
        <div class="pr-stat-value"><asp:Literal ID="litCertsCount" runat="server" Text="0" /></div>
        <div class="pr-stat-label"><asp:Literal ID="litCertsLabel" runat="server" Text="Certificates Earned" /></div>
    </div>
    <asp:Literal ID="litTotalXP" runat="server" Visible="false" /><asp:Literal ID="litTotalXPLabel" runat="server" Visible="false" />
</div>

<%-- ── BADGE COLLECTION ── --%>
<div class="pr-badges">
    <div class="pr-section-title"><i class="bi bi-award"></i> <asp:Literal ID="litBadgeSection" runat="server" Text="Badge Collection" /></div>
    <asp:Panel ID="pnlBadges" runat="server">
        <div class="pr-badge-grid">
            <asp:Repeater ID="rptBadges" runat="server">
                <ItemTemplate>
                    <div class='pr-badge-card <%# (bool)Eval("IsEarned") ? "earned" : "locked" %>'>
                        <%# !(bool)Eval("IsEarned") ? "<i class=\"bi bi-lock-fill pr-lock-icon\"></i>" : "" %>
                        <div class="pr-badge-icon"><img src='<%# Eval("IconUrl") %>' alt='<%# Eval("Name") %>' style="width:80px;height:80px;object-fit:contain;" onerror="this.style.display='none';this.nextElementSibling.style.display='inline';" /><i class="bi bi-award-fill" style="display:none;font-size:2.5rem;color:#F59E0B;"></i></div>
                        <div class="pr-badge-name"><%# Eval("Name") %></div>
                        <div class="pr-badge-desc"><%# Eval("Description") %></div>
                        <div class="pr-badge-req"><%# Eval("Requirement") %></div>
                        <div class="pr-badge-xp">+<%# Eval("XpReward") %> XP</div>
                        <span class='pr-badge-status <%# (bool)Eval("IsEarned") ? "earned-tag" : "locked-tag" %>'>
                            <%# (bool)Eval("IsEarned") ? Eval("EarnedText") : Eval("LockedText") %>
                        </span>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlNoBadges" runat="server" Visible="false">
        <div class="pr-empty-state">
            <i class="bi bi-award"></i>
            <asp:Literal ID="litNoBadges" runat="server" Text="No badges available yet." />
        </div>
    </asp:Panel>
</div>

<%-- ── RECENT XP ACTIVITY ── --%>
<div class="pr-xp-activity">
    <div class="pr-section-title"><i class="bi bi-lightning-charge"></i> <asp:Literal ID="litActivitySection" runat="server" Text="Recent XP Activity" /></div>
    <asp:Panel ID="pnlActivity" runat="server">
        <div class="pr-activity-list">
            <asp:Repeater ID="rptActivity" runat="server">
                <ItemTemplate>
                    <div class="pr-activity-item">
                        <div class="pr-activity-left">
                            <div class="pr-activity-icon"><i class="bi bi-star-fill"></i></div>
                            <div>
                                <div class="pr-activity-name"><%# Eval("ActionName") %></div>
                                <div class="pr-activity-date"><%# Eval("Date") %></div>
                            </div>
                        </div>
                        <div class="pr-activity-xp">+<%# Eval("XpAmount") %> XP</div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlNoActivity" runat="server" Visible="false">
        <div class="pr-empty-state">
            <i class="bi bi-lightning-charge"></i>
            <asp:Literal ID="litNoActivity" runat="server" Text="No XP activity yet." />
        </div>
    </asp:Panel>
</div>

<%-- ── CERTIFICATES ── --%>
<div class="pr-certs">
    <div class="pr-section-title"><i class="bi bi-file-earmark-check"></i> <asp:Literal ID="litCertSection" runat="server" Text="Certificates" /></div>
    <asp:Panel ID="pnlCerts" runat="server">
        <div class="pr-cert-grid">
            <asp:Repeater ID="rptCerts" runat="server">
                <ItemTemplate>
                    <div class="pr-cert-card">
                        <div class="pr-cert-icon"><i class="bi bi-file-earmark-check-fill" style="color:var(--pr-orange);"></i></div>
                        <div class="pr-cert-title"><%# Eval("Title") %></div>
                        <div class="pr-cert-level"><i class="bi bi-bar-chart-steps"></i> <%# Eval("Level") %></div>
                        <div class="pr-cert-date"><i class="bi bi-calendar3"></i> <%# Eval("IssuedDate") %></div>
                        <%# (bool)Eval("HasUrl") ? "<a href='" + Eval("Url") + "' target='_blank' class='pr-cert-btn'><i class='bi bi-download'></i> " + Eval("ViewText") + "</a>" : "" %>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlNoCerts" runat="server" Visible="false">
        <div class="pr-empty-state">
            <i class="bi bi-file-earmark-check"></i>
            <asp:Literal ID="litNoCerts" runat="server" Text="No certificates yet." />
        </div>
    </asp:Panel>
</div>

<%-- Navigation (hidden - kept for code-behind) --%>
<asp:Literal ID="litNavRanking" runat="server" Visible="false" />
<asp:Literal ID="litNavLearning" runat="server" Visible="false" />
<asp:Literal ID="litNavPractice" runat="server" Visible="false" />
<asp:Literal ID="litNavLabs" runat="server" Visible="false" />

</asp:Content>
