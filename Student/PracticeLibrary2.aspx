<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PracticeLibrary2.aspx.cs"
    Inherits="ScienceBuddy.Student.PracticeLibrary" MasterPageFile="~/Site.Master"
    Title="Practice Library" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ── Practice Library ── */
:root{--student:#FF6B2C;--student-light:#FFF0E8;--student-dark:#E85B1D;--student-mid:#FF8C54;}

/* ══ PAGE HEADER ══ */
.pl-header{margin-bottom:var(--space-xl);}
.pl-title{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;
    color:var(--color-text);margin-bottom:var(--space-xs);line-height:1.2;}
.pl-subtitle{font-size:.9375rem;color:var(--color-text-secondary);line-height:1.5;}

/* ══ AI RECOMMENDATION BANNER ══ */
.pl-recommend{background:linear-gradient(135deg,#FF6B2C 0%,#FF8C54 50%,#FFD84D 100%);
    border-radius:var(--border-radius-xl);padding:var(--space-lg) var(--space-xl);
    color:#fff;margin-bottom:var(--space-xl);position:relative;overflow:hidden;
    box-shadow:0 8px 32px rgba(255,107,44,.20);}
.pl-recommend::before{content:'🤖';position:absolute;font-size:5rem;opacity:.10;
    top:-10px;right:20px;pointer-events:none;line-height:1;}
.pl-recommend-title{font-family:var(--font-primary);font-size:1rem;font-weight:800;
    margin-bottom:var(--space-xs);display:flex;align-items:center;gap:var(--space-sm);}
.pl-recommend-text{font-size:.875rem;opacity:.92;line-height:1.5;}

/* ══ FILTER SECTION ══ */
.pl-filters{display:flex;flex-wrap:wrap;gap:var(--space-sm);
    margin-bottom:var(--space-xl);padding:var(--space-md) var(--space-lg);
    background:var(--color-white);border-radius:var(--border-radius-lg);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);}
.pl-filters select{padding:8px 14px;border-radius:var(--border-radius);
    border:1.5px solid var(--border-color);font-size:.875rem;font-weight:600;
    color:var(--color-text);background:var(--color-white);min-width:160px;
    cursor:pointer;transition:border-color .2s;}
.pl-filters select:focus{border-color:var(--student);outline:none;
    box-shadow:0 0 0 3px rgba(255,107,44,.12);}

/* ══ QUIZ CARD GRID ══ */
.pl-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));
    gap:var(--space-lg);}

/* ══ QUIZ CARD ══ */
.pl-card{background:var(--color-white);border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);
    overflow:hidden;transition:transform .2s,box-shadow .2s;
    display:flex;flex-direction:column;position:relative;}
.pl-card::before{content:'';position:absolute;top:0;left:0;right:0;height:4px;
    background:linear-gradient(90deg,var(--student),var(--student-mid));}
.pl-card:hover{transform:translateY(-5px);box-shadow:var(--shadow-lg);}
.pl-card-body{padding:var(--space-lg);flex:1;display:flex;flex-direction:column;}
.pl-card-title{font-family:var(--font-primary);font-size:1.0625rem;font-weight:800;
    color:var(--color-text);margin-bottom:var(--space-sm);line-height:1.3;}
.pl-card-meta{font-size:.8125rem;color:var(--color-text-secondary);margin-bottom:var(--space-sm);
    display:flex;flex-direction:column;gap:4px;}
.pl-card-meta span{display:flex;align-items:center;gap:6px;}
.pl-card-badges{display:flex;flex-wrap:wrap;gap:6px;margin-bottom:var(--space-md);}
.pl-badge{font-size:.6875rem;font-weight:700;padding:3px 10px;
    border-radius:var(--border-radius-full);display:inline-flex;align-items:center;gap:4px;}
.pl-badge-level{background:#DBEAFE;color:#1D4ED8;}
.pl-badge-lang{background:#F3E8FF;color:#7C3AED;}
.pl-badge-count{background:#FEF3C7;color:#92400E;}
.pl-badge-attempted{background:#DCFCE7;color:#15803D;}
.pl-badge-new{background:#DBEAFE;color:#1D4ED8;}
.pl-card-score{font-size:.8125rem;color:var(--color-text-secondary);
    margin-bottom:var(--space-md);font-weight:600;}
.pl-card-footer{padding:0 var(--space-lg) var(--space-lg);margin-top:auto;}
.pl-card-btn{display:inline-flex;align-items:center;gap:6px;padding:10px 20px;
    border-radius:var(--border-radius-full);font-weight:700;font-size:.875rem;
    text-decoration:none;background:var(--student);color:#fff;
    transition:all .2s;border:none;cursor:pointer;width:100%;justify-content:center;}
.pl-card-btn:hover{background:var(--student-dark);transform:translateY(-2px);
    box-shadow:0 6px 20px rgba(255,107,44,.30);text-decoration:none;color:#fff;}

/* ══ EMPTY STATE ══ */
.pl-empty{text-align:center;padding:var(--space-3xl) var(--space-xl);
    background:var(--color-white);border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);}
.pl-empty-icon{font-size:3.5rem;margin-bottom:var(--space-md);}
.pl-empty-title{font-family:var(--font-primary);font-size:1.25rem;font-weight:800;
    color:var(--color-text);margin-bottom:var(--space-sm);}
.pl-empty-desc{font-size:.9375rem;color:var(--color-text-secondary);margin-bottom:var(--space-lg);
    max-width:400px;margin-left:auto;margin-right:auto;line-height:1.5;}

/* ══ RESPONSIVE ══ */
@media(max-width:767px){
    .pl-grid{grid-template-columns:1fr;}
    .pl-filters{flex-direction:column;}
    .pl-filters select{width:100%;}
    .pl-title{font-size:1.375rem;}
}
@media(max-width:479px){
    .pl-recommend{padding:var(--space-md);}
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
        <a href="<%: ResolveUrl("~/Student/PracticeLibrary.aspx") %>" class="sb-sidebar-item active">
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
        <a href="<%: ResolveUrl("~/Student/MyProfile.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span>
        </a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <asp:Literal ID="litPageTitle" runat="server" Text="Practice Library" />
</asp:Content>

<%-- ════ MAIN CONTENT ════ --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- ── PAGE HEADER ── --%>
<div class="pl-header">
    <div class="pl-title"><asp:Literal ID="litTitle" runat="server" Text="Practice Library" /></div>
    <div class="pl-subtitle"><asp:Literal ID="litSubtitle" runat="server" Text="Try extra quizzes to improve your Science skills." /></div>
</div>

<%-- ── AI RECOMMENDATION BANNER ── --%>
<asp:Panel ID="pnlRecommend" runat="server" CssClass="pl-recommend" Visible="false">
    <div class="pl-recommend-title"><i class="bi bi-stars"></i> <asp:Literal ID="litRecommendTitle" runat="server" /></div>
    <div class="pl-recommend-text"><asp:Literal ID="litRecommendText" runat="server" /></div>
</asp:Panel>

<%-- ── FILTERS ── --%>
<div class="pl-filters">
    <asp:DropDownList ID="ddlLevel" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed" />
    <asp:DropDownList ID="ddlUnit" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed" />
    <asp:DropDownList ID="ddlSubtopic" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed" />
    <asp:DropDownList ID="ddlLanguage" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed" />
</div>

<%-- ── QUIZ CARD GRID ── --%>
<asp:Panel ID="pnlGrid" runat="server">
    <div class="pl-grid">
        <asp:Repeater ID="rptQuizzes" runat="server">
            <ItemTemplate>
                <div class="pl-card">
                    <div class="pl-card-body">
                        <div class="pl-card-title"><%# Eval("Title") %></div>
                        <div class="pl-card-meta">
                            <span><i class="bi bi-layers"></i> <%# Eval("Unit") %></span>
                            <span><i class="bi bi-bookmark"></i> <%# Eval("Subtopic") %></span>
                        </div>
                        <div class="pl-card-badges">
                            <span class="pl-badge pl-badge-level"><i class="bi bi-bar-chart-steps"></i> <%# Eval("Level") %></span>
                            <span class="pl-badge pl-badge-lang"><i class="bi bi-translate"></i> <%# Eval("Language") %></span>
                            <span class="pl-badge pl-badge-count"><i class="bi bi-question-circle"></i> <%# Eval("QuestionCount") %> <%# Eval("QuestionsLabel") %></span>
                            <span class='pl-badge <%# Eval("BadgeClass") %>'><%# Eval("StatusText") %></span>
                        </div>
                        <div class="pl-card-score"><%# Eval("ScoreDisplay") %></div>
                    </div>
                    <div class="pl-card-footer">
                        <a href='<%# Eval("Url") %>' class="pl-card-btn">
                            <i class="bi bi-play-fill"></i> <%# Eval("BtnText") %>
                        </a>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>

<%-- ── EMPTY STATE ── --%>
<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="pl-empty">
        <div class="pl-empty-icon">📝</div>
        <div class="pl-empty-title"><asp:Literal ID="litEmptyTitle" runat="server" Text="No practice quizzes available" /></div>
        <div class="pl-empty-desc"><asp:Literal ID="litEmptyDesc" runat="server" Text="No practice quizzes are available yet." /></div>
        <a href="<%: ResolveUrl("~/Student/Dashboard.aspx") %>" class="pl-card-btn" style="display:inline-flex;width:auto;">
            <i class="bi bi-house"></i> <asp:Literal ID="litEmptyBtn" runat="server" Text="Back to Dashboard" />
        </a>
    </div>
</asp:Panel>

</asp:Content>
