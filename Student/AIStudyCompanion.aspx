<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AIStudyCompanion.aspx.cs"
    Inherits="ScienceBuddy.Student.AIStudyCompanion" MasterPageFile="~/Site.Master"
    Title="AI Study Companion" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ── AI Study Companion ── */
:root{--student:#FF6B2C;--student-light:#FFF0E8;--student-dark:#E85B1D;--student-mid:#FF8C54;
    --ai-purple:#7C3AED;--ai-blue:#2563EB;--ai-purple-light:#EDE9FE;--ai-blue-light:#DBEAFE;
    --ai-green:#10B981;--ai-green-light:#D1FAE5;--ai-orange:#F59E0B;--ai-orange-light:#FEF3C7;}

/* ══ AI HERO CARD ══ */
.ai-hero{background:linear-gradient(135deg,var(--ai-purple) 0%,var(--ai-blue) 100%);
    border-radius:var(--border-radius-xl);padding:var(--space-xl) var(--space-2xl);
    color:#fff;margin-bottom:var(--space-xl);position:relative;overflow:hidden;
    box-shadow:0 8px 32px rgba(124,58,237,.25);}
.ai-hero::before{content:'🤖';position:absolute;font-size:6rem;opacity:.10;
    top:-10px;right:30px;pointer-events:none;line-height:1;}
.ai-hero::after{content:'';position:absolute;bottom:-40px;left:-40px;width:120px;height:120px;
    background:rgba(255,255,255,.06);border-radius:50%;pointer-events:none;}
.ai-hero-icon{font-size:2.5rem;margin-bottom:var(--space-sm);}
.ai-hero-title{font-family:var(--font-primary);font-size:1.5rem;font-weight:800;
    margin-bottom:var(--space-xs);line-height:1.2;}
.ai-hero-sub{font-size:.9375rem;opacity:.88;margin-bottom:var(--space-lg);line-height:1.5;}
.ai-hero-info{display:flex;flex-wrap:wrap;gap:var(--space-md);margin-bottom:var(--space-md);}
.ai-hero-chip{background:rgba(255,255,255,.18);backdrop-filter:blur(4px);
    padding:6px 14px;border-radius:var(--border-radius-full);font-size:.8125rem;
    font-weight:600;display:inline-flex;align-items:center;gap:6px;}
.ai-hero-message{background:rgba(255,255,255,.12);border-radius:var(--border-radius-lg);
    padding:var(--space-md) var(--space-lg);font-size:.875rem;line-height:1.5;
    border-left:3px solid rgba(255,255,255,.5);margin-top:var(--space-sm);}

/* ══ LEARNING HEALTH SUMMARY ══ */
.ai-health{margin-bottom:var(--space-xl);}
.ai-health-title{font-family:var(--font-primary);font-size:1.25rem;font-weight:800;
    color:var(--color-text);margin-bottom:var(--space-lg);}
.ai-health-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));
    gap:var(--space-md);}
.ai-health-card{background:var(--color-white);border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);
    padding:var(--space-lg);text-align:center;transition:transform .2s,box-shadow .2s;}
.ai-health-card:hover{transform:translateY(-3px);box-shadow:var(--shadow-md);}
.ai-health-card-icon{font-size:1.75rem;margin-bottom:var(--space-xs);}
.ai-health-card-value{font-family:var(--font-primary);font-size:1.5rem;font-weight:800;
    color:var(--color-text);margin-bottom:2px;}
.ai-health-card-label{font-size:.8125rem;color:var(--color-text-secondary);font-weight:600;}
.ai-health-card--score .ai-health-card-value{color:var(--ai-purple);}
.ai-health-card--attempts .ai-health-card-value{color:var(--ai-blue);}
.ai-health-card--strong{border-color:var(--ai-green-light);}
.ai-health-card--strong .ai-health-card-value{color:var(--ai-green);font-size:1rem;
    line-height:1.4;}
.ai-health-card--weak{border-color:var(--ai-orange-light);}
.ai-health-card--weak .ai-health-card-value{color:var(--ai-orange);font-size:1rem;
    line-height:1.4;}
.ai-health-empty{background:var(--color-white);border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);
    padding:var(--space-xl);text-align:center;color:var(--color-text-secondary);
    font-size:.9375rem;}
.ai-chip{display:inline-block;padding:3px 10px;border-radius:var(--border-radius-full);
    font-size:.75rem;font-weight:700;margin:2px 3px;}
.ai-chip--green{background:var(--ai-green-light);color:#065F46;}
.ai-chip--orange{background:var(--ai-orange-light);color:#92400E;}

/* ══ STRONG TOPICS ══ */
.ai-strong{margin-bottom:var(--space-xl);}
.ai-strong-card{background:linear-gradient(135deg,#ECFDF5 0%,#D1FAE5 100%);
    border-radius:var(--border-radius-xl);border:1.5px solid #A7F3D0;
    padding:var(--space-lg) var(--space-xl);box-shadow:var(--shadow-sm);}
.ai-strong-title{font-family:var(--font-primary);font-size:1.125rem;font-weight:800;
    color:#065F46;margin-bottom:var(--space-md);display:flex;align-items:center;gap:8px;}
.ai-strong-list{font-size:.9375rem;color:#047857;line-height:1.8;}
.ai-strong-empty{font-size:.875rem;color:#6EE7B7;font-style:italic;}

/* ══ WEAK TOPICS ══ */
.ai-weak{margin-bottom:var(--space-xl);}
.ai-weak-card{background:linear-gradient(135deg,#FFFBEB 0%,#FEF3C7 100%);
    border-radius:var(--border-radius-xl);border:1.5px solid #FDE68A;
    padding:var(--space-lg) var(--space-xl);box-shadow:var(--shadow-sm);}
.ai-weak-title{font-family:var(--font-primary);font-size:1.125rem;font-weight:800;
    color:#92400E;margin-bottom:var(--space-md);display:flex;align-items:center;gap:8px;}
.ai-weak-list{font-size:.9375rem;color:#B45309;line-height:1.8;}
.ai-weak-empty{font-size:.875rem;color:#F59E0B;font-style:italic;}

/* ══ RECOMMENDED NEXT STEPS ══ */
.ai-recommend{margin-bottom:var(--space-xl);}
.ai-recommend-title{font-family:var(--font-primary);font-size:1.25rem;font-weight:800;
    color:var(--color-text);margin-bottom:var(--space-lg);}
.ai-recommend-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));
    gap:var(--space-md);}
.ai-recommend-card{background:var(--color-white);border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);
    padding:var(--space-lg);transition:transform .2s,box-shadow .2s;
    display:flex;flex-direction:column;}
.ai-recommend-card:hover{transform:translateY(-3px);box-shadow:var(--shadow-md);}
.ai-recommend-card-icon{font-size:2rem;margin-bottom:var(--space-sm);}
.ai-recommend-card-title{font-family:var(--font-primary);font-size:1rem;font-weight:700;
    color:var(--color-text);margin-bottom:var(--space-xs);}
.ai-recommend-card-reason{font-size:.8125rem;color:var(--color-text-secondary);
    line-height:1.5;margin-bottom:var(--space-md);flex:1;}
.ai-recommend-card-btn{display:inline-flex;align-items:center;gap:6px;padding:8px 16px;
    border-radius:var(--border-radius-full);font-weight:700;font-size:.8125rem;
    text-decoration:none;background:linear-gradient(135deg,var(--ai-purple),var(--ai-blue));
    color:#fff;transition:all .2s;border:none;cursor:pointer;justify-content:center;}
.ai-recommend-card-btn:hover{transform:translateY(-2px);
    box-shadow:0 6px 20px rgba(124,58,237,.30);text-decoration:none;color:#fff;}
.ai-explanation{background:var(--ai-purple-light);border-radius:var(--border-radius-lg);
    padding:var(--space-md) var(--space-lg);font-size:.875rem;color:#5B21B6;
    line-height:1.6;margin-top:var(--space-lg);border-left:3px solid var(--ai-purple);}

/* ══ STUDY TIPS ══ */
.ai-tips{margin-bottom:var(--space-xl);}
.ai-tips-title{font-family:var(--font-primary);font-size:1.25rem;font-weight:800;
    color:var(--color-text);margin-bottom:var(--space-lg);}
.ai-tips-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));
    gap:var(--space-md);}
.ai-tip-card{background:var(--color-white);border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);
    padding:var(--space-lg);position:relative;overflow:hidden;}
.ai-tip-card::before{content:'';position:absolute;top:0;left:0;right:0;height:3px;
    background:linear-gradient(90deg,var(--ai-purple),var(--ai-blue));}
.ai-tip-card-num{font-family:var(--font-primary);font-size:2rem;font-weight:800;
    color:var(--ai-purple-light);margin-bottom:var(--space-xs);}
.ai-tip-card-text{font-size:.875rem;color:var(--color-text);line-height:1.6;}

/* ══ EMPTY STATE ══ */
.ai-empty{text-align:center;padding:var(--space-3xl) var(--space-xl);
    background:var(--color-white);border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);}
.ai-empty-icon{font-size:4rem;margin-bottom:var(--space-md);}
.ai-empty-title{font-family:var(--font-primary);font-size:1.25rem;font-weight:800;
    color:var(--color-text);margin-bottom:var(--space-sm);}
.ai-empty-desc{font-size:.9375rem;color:var(--color-text-secondary);
    max-width:420px;margin-left:auto;margin-right:auto;line-height:1.6;}

/* ══ RESPONSIVE ══ */
@media(max-width:767px){
    .ai-hero{padding:var(--space-lg);}
    .ai-hero-title{font-size:1.25rem;}
    .ai-hero-info{flex-direction:column;gap:var(--space-xs);}
    .ai-health-grid{grid-template-columns:repeat(2,1fr);}
    .ai-recommend-grid{grid-template-columns:1fr;}
    .ai-tips-grid{grid-template-columns:1fr;}
}
@media(max-width:479px){
    .ai-health-grid{grid-template-columns:1fr;}
    .ai-hero-icon{font-size:2rem;}
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
        <a href="#" class="sb-sidebar-item">
            <i class="bi bi-camera-video item-icon"></i><span class="item-label">Live Sessions</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/AIStudyCompanion.aspx") %>" class="sb-sidebar-item active">
            <i class="bi bi-robot item-icon"></i><span class="item-label">AI Study Companion</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Progress</div>
        <a href="<%: ResolveUrl("~/Student/Progress.aspx") %>" class="sb-sidebar-item">
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

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <asp:Literal ID="litPageTitle" runat="server" Text="AI Study Companion" />
</asp:Content>

<%-- ════ MAIN CONTENT ════ --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- ── AI HERO CARD ── --%>
<div class="ai-hero">
    <div class="ai-hero-icon">🤖</div>
    <div class="ai-hero-title"><asp:Literal ID="litHeroTitle" runat="server" Text="AI Study Companion" /></div>
    <div class="ai-hero-sub"><asp:Literal ID="litHeroSub" runat="server" Text="Your smart learning buddy is here to guide your next step." /></div>
    <div class="ai-hero-info">
        <span class="ai-hero-chip">👤 <asp:Literal ID="litStudentName" runat="server" /></span>
        <span class="ai-hero-chip">📚 <asp:Literal ID="litCurrentLevel" runat="server" /></span>
        <span class="ai-hero-chip">🧠 <asp:Literal ID="litPersonality" runat="server" /></span>
    </div>
    <div class="ai-hero-message">
        <asp:Literal ID="litAIMessage" runat="server" />
    </div>
</div>

<%-- ── LEARNING HEALTH SUMMARY ── --%>
<div class="ai-health">
    <div class="ai-health-title"><asp:Literal ID="litHealthTitle" runat="server" Text="Learning Health" /></div>

    <asp:Panel ID="pnlHealth" runat="server">
        <div class="ai-health-grid">
            <div class="ai-health-card ai-health-card--score">
                <div class="ai-health-card-icon">📊</div>
                <div class="ai-health-card-value"><asp:Literal ID="litAvgScore" runat="server" Text="0%" /></div>
                <div class="ai-health-card-label"><asp:Literal ID="litAvgScoreLbl" runat="server" Text="Average Quiz Score" /></div>
            </div>
            <div class="ai-health-card ai-health-card--attempts">
                <div class="ai-health-card-icon">✏️</div>
                <div class="ai-health-card-value"><asp:Literal ID="litTotalAttempts" runat="server" Text="0" /></div>
                <div class="ai-health-card-label"><asp:Literal ID="litTotalAttemptsLbl" runat="server" Text="Total Quiz Attempts" /></div>
            </div>
            <div class="ai-health-card ai-health-card--strong">
                <div class="ai-health-card-icon">💪</div>
                <div class="ai-health-card-value"><asp:Literal ID="litStrongTopics" runat="server" /></div>
                <div class="ai-health-card-label"><asp:Literal ID="litStrongTopicsLbl" runat="server" Text="Strong Topics" /></div>
            </div>
            <div class="ai-health-card ai-health-card--weak">
                <div class="ai-health-card-icon">🎯</div>
                <div class="ai-health-card-value"><asp:Literal ID="litWeakTopics" runat="server" /></div>
                <div class="ai-health-card-label"><asp:Literal ID="litWeakTopicsLbl" runat="server" Text="Weak Topics" /></div>
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlHealthEmpty" runat="server" Visible="false">
        <div class="ai-health-empty">
            <asp:Literal ID="litHealthEmpty" runat="server" Text="Complete more quizzes to unlock your personalised learning analysis." />
        </div>
    </asp:Panel>
</div>

<%-- ── STRONG TOPICS ── --%>
<div class="ai-strong">
    <asp:Panel ID="pnlStrong" runat="server">
        <div class="ai-strong-card">
            <div class="ai-strong-title">💪 <asp:Literal ID="litStrongTitle" runat="server" Text="Strong Topics" /></div>
            <div class="ai-strong-list"><asp:Literal ID="litStrongList" runat="server" /></div>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlStrongEmpty" runat="server" Visible="false">
        <div class="ai-strong-card" style="opacity:.7;">
            <div class="ai-strong-title">💪 <asp:Literal ID="litStrongEmptyTitle" runat="server" Text="Strong Topics" /></div>
            <div class="ai-strong-empty"><asp:Literal ID="litStrongEmpty" runat="server" Text="Your strong topics will appear here after you attempt more quizzes." /></div>
        </div>
    </asp:Panel>
</div>

<%-- ── WEAK TOPICS ── --%>
<div class="ai-weak">
    <asp:Panel ID="pnlWeak" runat="server">
        <div class="ai-weak-card">
            <div class="ai-weak-title">🎯 <asp:Literal ID="litWeakTitle" runat="server" Text="Weak Topics" /></div>
            <div class="ai-weak-list"><asp:Literal ID="litWeakList" runat="server" /></div>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlWeakEmpty" runat="server" Visible="false">
        <div class="ai-weak-card" style="opacity:.7;">
            <div class="ai-weak-title">🎯 <asp:Literal ID="litWeakEmptyTitle" runat="server" Text="Weak Topics" /></div>
            <div class="ai-weak-empty"><asp:Literal ID="litWeakEmpty" runat="server" Text="No weak topics detected yet. Keep learning!" /></div>
        </div>
    </asp:Panel>
</div>

<%-- ── RECOMMENDED NEXT STEPS ── --%>
<asp:Panel ID="pnlRecommend" runat="server">
    <div class="ai-recommend">
        <div class="ai-recommend-title"><asp:Literal ID="litRecommendTitle" runat="server" Text="Recommended Next Steps" /></div>
        <div class="ai-recommend-grid">
            <asp:Repeater ID="rptRecommendations" runat="server">
                <ItemTemplate>
                    <div class="ai-recommend-card">
                        <div class="ai-recommend-card-icon"><%# Eval("Icon") %></div>
                        <div class="ai-recommend-card-title"><%# Eval("Title") %></div>
                        <div class="ai-recommend-card-reason"><%# Eval("Reason") %></div>
                        <a href='<%# Eval("Url") %>' class="ai-recommend-card-btn">
                            <i class="bi bi-arrow-right"></i> <%# Eval("BtnText") %>
                        </a>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
        <div class="ai-explanation"><asp:Literal ID="litExplanation" runat="server" /></div>
    </div>
</asp:Panel>

<%-- ── STUDY TIPS ── --%>
<div class="ai-tips">
    <div class="ai-tips-title"><asp:Literal ID="litTipsTitle" runat="server" Text="Study Tips" /></div>
    <div class="ai-tips-grid">
        <div class="ai-tip-card">
            <div class="ai-tip-card-num">01</div>
            <div class="ai-tip-card-text"><asp:Literal ID="litTip1" runat="server" /></div>
        </div>
        <div class="ai-tip-card">
            <div class="ai-tip-card-num">02</div>
            <div class="ai-tip-card-text"><asp:Literal ID="litTip2" runat="server" /></div>
        </div>
        <div class="ai-tip-card">
            <div class="ai-tip-card-num">03</div>
            <div class="ai-tip-card-text"><asp:Literal ID="litTip3" runat="server" /></div>
        </div>
    </div>
</div>

<%-- ── EMPTY STATE (no data at all) ── --%>
<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="ai-empty">
        <div class="ai-empty-icon">🚀</div>
        <div class="ai-empty-title"><asp:Literal ID="litEmptyTitle" runat="server" Text="Start your learning journey!" /></div>
        <div class="ai-empty-desc"><asp:Literal ID="litEmptyDesc" runat="server" Text="Start your learning journey first to unlock your AI companion's insights." /></div>
    </div>
</asp:Panel>

</asp:Content>
