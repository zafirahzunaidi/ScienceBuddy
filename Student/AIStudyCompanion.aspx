<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AIStudyCompanion.aspx.cs"
    Inherits="ScienceBuddy.Student.AIStudyCompanion1" MasterPageFile="~/Site.Master"
    Title="AI Study Companion" %>
<asp:Content ID="HeadStyle" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%: ResolveUrl("~/Content/Student.css") %>" rel="stylesheet" />
</asp:Content>

<asp:Content ID="TopNavigationLinks" ContentPlaceHolderID="TopNavLinks" runat="server">
</asp:Content>

<asp:Content ID="TopNavActions" ContentPlaceHolderID="TopNavActions" runat="server">
</asp:Content>

<asp:Content ID="TopNavigationMainContent" ContentPlaceHolderID="MainContent" runat="server">
</asp:Content>

<%-- Student Sidebar --%>
<asp:Content ID="StudentSidebarMenu" ContentPlaceHolderID="SidebarMenu" runat="server">
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
        <a href="<%: ResolveUrl("~/Student/AIStudyCompanion.aspx") %>" class="sb-sidebar-item active">
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
        <a href="<%: ResolveUrl("~/Student/RevisionPlan.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-calendar-check item-icon"></i><span class="item-label">Revision Plan</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Student/MyProfile.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span>
        </a>
    </div>
</asp:Content>

<asp:Content ID="StudentSidebarFooter" ContentPlaceHolderID="SidebarFooter" runat="server">
</asp:Content>

<asp:Content ID="AIStudyCompanionPageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <asp:Literal ID="litPageTitle" runat="server" Text="AI Study Companion" />
</asp:Content>

<asp:Content ID="StudentUserDropdownMenu" ContentPlaceHolderID="UserDropdownMenu" runat="server">
</asp:Content>

<asp:Content ID="AIStudyCompanionBreadcrumb" ContentPlaceHolderID="BreadcrumbContent" runat="server">
</asp:Content>

<%-- AIStudyCompanion Main Content --%>
<asp:Content ID="AIStudyCompanionMainContent" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- ── AI HERO CARD ── --%>
<div class="st-ai-hero">
    <div class="st-ai-hero-icon"><i class="bi bi-robot" style="font-size:2.5rem;"></i></div>
    <div class="st-ai-hero-title"><asp:Literal ID="litHeroTitle" runat="server" Text="AI Study Companion" /></div>
    <div class="st-ai-hero-sub"><asp:Literal ID="litHeroSub" runat="server" Text="Your smart learning buddy is here to guide your next step." /></div>
    <div class="st-ai-hero-info">
        <span class="st-ai-hero-chip"><i class="bi bi-person-circle"></i> <asp:Literal ID="litStudentName" runat="server" /></span>
        <span class="st-ai-hero-chip"><i class="bi bi-book"></i> <asp:Literal ID="litCurrentLevel" runat="server" /></span>
        <span class="st-ai-hero-chip"><i class="bi bi-stars"></i> <asp:Literal ID="litPersonality" runat="server" /></span>
    </div>
    <div class="st-ai-hero-message">
        <asp:Literal ID="litAIMessage" runat="server" />
    </div>
</div>

<%-- ── ASK SCIENCEBUDDY AI CHAT ── --%>
<asp:Panel ID="pnlAIChat" runat="server" CssClass="st-ai-chat" style="background:#fff;border-radius:16px;border:1.5px solid #E5E7EB;box-shadow:0 4px 20px rgba(124,58,237,.08);padding:24px;margin-bottom:24px;position:relative;overflow:hidden;border-top:4px solid #7C3AED;">
    <div class="st-ai-chat-header">
        <div>
            <div class="st-ai-chat-title">
                <i class="bi bi-robot"></i>
                <asp:Literal ID="litChatTitle" runat="server" Text="Ask ScienceBuddy AI" />
            </div>
            <div class="st-ai-chat-sub">
                <asp:Literal ID="litChatSub" runat="server" Text="Ask me anything about your Science lessons." />
            </div>
        </div>
    </div>

    <div id="chatBox" runat="server" clientidmode="Static" class="st-ai-chat-box" style="background:linear-gradient(180deg,#FAFBFF,#F5F3FF);border:1.5px solid #E5E7EB;border-radius:16px;padding:16px;min-height:260px;max-height:360px;overflow-y:auto;display:flex;flex-direction:column;gap:12px;margin-bottom:12px;"></div>

    <div class="st-ai-chat-input-row" style="display:flex;gap:8px;align-items:stretch;">
        <asp:TextBox ID="txtAIMessage" runat="server"
            CssClass="st-ai-chat-input"
            TextMode="MultiLine"
            Rows="2"
            style="flex:1;resize:none;min-height:48px;border:2px solid #E5E7EB;border-radius:24px;padding:12px 18px;font-size:.9rem;font-family:inherit;"
            placeholder="Ask your AI study question..." />

        <asp:Button ID="btnAISend" runat="server"
            CssClass="st-ai-chat-send"
            style="border:none;border-radius:24px;padding:12px 28px;font-weight:700;background:linear-gradient(135deg,#7C3AED,#2563EB);color:#fff;cursor:pointer;"
            Text="Send"
            OnClick="btnAISend_Click" />
    </div>
    <div class="st-ai-chat-note" style="font-size:.75rem;color:#9CA3AF;margin-top:8px;display:flex;align-items:center;gap:4px;font-style:italic;"><i class="bi bi-info-circle"></i> <asp:Literal ID="litChatNote" runat="server" Text="AI can make mistakes, so always check with your teacher or lesson notes." /></div>
</asp:Panel>

<%-- ── LEARNING HEALTH SUMMARY ── --%>
<div class="st-ai-health">
    <div class="st-ai-health-title"><asp:Literal ID="litHealthTitle" runat="server" Text="Learning Health" /></div>

    <asp:Panel ID="pnlHealth" runat="server">
        <div class="st-ai-health-grid">
            <div class="st-ai-health-card st-ai-health-card--score">
                <div class="st-ai-health-card-icon"><i class="bi bi-bar-chart-line-fill"></i></div>
                <div class="st-ai-health-card-value"><asp:Literal ID="litAvgScore" runat="server" Text="0%" /></div>
                <div class="st-ai-health-card-label"><asp:Literal ID="litAvgScoreLbl" runat="server" Text="Average Quiz Score" /></div>
            </div>
            <div class="st-ai-health-card st-ai-health-card--attempts">
                <div class="st-ai-health-card-icon"><i class="bi bi-pencil-fill"></i></div>
                <div class="st-ai-health-card-value"><asp:Literal ID="litTotalAttempts" runat="server" Text="0" /></div>
                <div class="st-ai-health-card-label"><asp:Literal ID="litTotalAttemptsLbl" runat="server" Text="Total Quiz Attempts" /></div>
            </div>
            <div class="st-ai-health-card st-ai-health-card--strong">
                <div class="st-ai-health-card-icon"><i class="bi bi-hand-thumbs-up-fill"></i></div>
                <div class="st-ai-health-card-value"><asp:Literal ID="litStrongTopics" runat="server" /></div>
                <div class="st-ai-health-card-label"><asp:Literal ID="litStrongTopicsLbl" runat="server" Text="Strong Topics" /></div>
            </div>
            <div class="st-ai-health-card st-ai-health-card--weak">
                <div class="st-ai-health-card-icon"><i class="bi bi-bullseye"></i></div>
                <div class="st-ai-health-card-value"><asp:Literal ID="litWeakTopics" runat="server" /></div>
                <div class="st-ai-health-card-label"><asp:Literal ID="litWeakTopicsLbl" runat="server" Text="Weak Topics" /></div>
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlHealthEmpty" runat="server" Visible="false">
        <div class="st-ai-health-empty">
            <asp:Literal ID="litHealthEmpty" runat="server" Text="Complete more quizzes to unlock your personalised learning analysis." />
        </div>
    </asp:Panel>
</div>

<%-- ── STRONG TOPICS ── --%>
<div class="st-ai-strong">
    <asp:Panel ID="pnlStrong" runat="server">
        <div class="st-ai-strong-card">
            <div class="st-ai-strong-title"><i class="bi bi-hand-thumbs-up-fill" style="color:#10B981;"></i> <asp:Literal ID="litStrongTitle" runat="server" Text="Strong Topics" /></div>
            <div class="st-ai-strong-list"><asp:Literal ID="litStrongList" runat="server" /></div>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlStrongEmpty" runat="server" Visible="false">
        <div class="st-ai-strong-card" style="opacity:.7;">
            <div class="st-ai-strong-title"><i class="bi bi-hand-thumbs-up-fill" style="color:#10B981;"></i> <asp:Literal ID="litStrongEmptyTitle" runat="server" Text="Strong Topics" /></div>
            <div class="st-ai-strong-empty"><asp:Literal ID="litStrongEmpty" runat="server" Text="Your strong topics will appear here after you attempt more quizzes." /></div>
        </div>
    </asp:Panel>
</div>

<%-- ── WEAK TOPICS ── --%>
<div class="st-ai-weak">
    <asp:Panel ID="pnlWeak" runat="server">
        <div class="st-ai-weak-card">
            <div class="st-ai-weak-title"><i class="bi bi-bullseye" style="color:#F59E0B;"></i> <asp:Literal ID="litWeakTitle" runat="server" Text="Weak Topics" /></div>
            <div class="st-ai-weak-list"><asp:Literal ID="litWeakList" runat="server" /></div>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlWeakEmpty" runat="server" Visible="false">
        <div class="st-ai-weak-card" style="opacity:.7;">
            <div class="st-ai-weak-title"><i class="bi bi-bullseye" style="color:#F59E0B;"></i> <asp:Literal ID="litWeakEmptyTitle" runat="server" Text="Weak Topics" /></div>
            <div class="st-ai-weak-empty"><asp:Literal ID="litWeakEmpty" runat="server" Text="No weak topics detected yet. Keep learning!" /></div>
        </div>
    </asp:Panel>
</div>

<%-- ── RECOMMENDED NEXT STEPS ── --%>
<asp:Panel ID="pnlRecommend" runat="server">
    <div class="st-ai-recommend">
        <div class="st-ai-recommend-title"><asp:Literal ID="litRecommendTitle" runat="server" Text="Recommended Next Steps" /></div>
        <div class="st-ai-recommend-grid">
            <asp:Repeater ID="rptRecommendations" runat="server">
                <ItemTemplate>
                    <div class="st-ai-recommend-card">
                        <div class="st-ai-recommend-card-icon"><%# Eval("Icon") %></div>
                        <div class="st-ai-recommend-card-title"><%# Eval("Title") %></div>
                        <div class="st-ai-recommend-card-reason"><%# Eval("Reason") %></div>
                        <a href='<%# Eval("Url") %>' class="st-ai-recommend-card-btn">
                            <i class="bi bi-arrow-right"></i> <%# Eval("BtnText") %>
                        </a>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
        <div class="st-ai-explanation"><asp:Literal ID="litExplanation" runat="server" /></div>
    </div>
</asp:Panel>

<%-- ── STUDY TIPS ── --%>
<div class="st-ai-tips">
    <div class="st-ai-tips-title"><asp:Literal ID="litTipsTitle" runat="server" Text="Study Tips" /></div>
    <div class="st-ai-tips-grid">
        <div class="st-ai-tip-card">
            <div class="st-ai-tip-card-num">01</div>
            <div class="st-ai-tip-card-text"><asp:Literal ID="litTip1" runat="server" /></div>
        </div>
        <div class="st-ai-tip-card">
            <div class="st-ai-tip-card-num">02</div>
            <div class="st-ai-tip-card-text"><asp:Literal ID="litTip2" runat="server" /></div>
        </div>
        <div class="st-ai-tip-card">
            <div class="st-ai-tip-card-num">03</div>
            <div class="st-ai-tip-card-text"><asp:Literal ID="litTip3" runat="server" /></div>
        </div>
    </div>
</div>

<%-- Chat section --%>
<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="st-ai-empty">
        <div class="st-ai-empty-icon"><i class="bi bi-rocket-takeoff-fill" style="font-size:4rem;color:var(--ai-purple);"></i></div>
        <div class="st-ai-empty-title"><asp:Literal ID="litEmptyTitle" runat="server" Text="Start your learning journey!" /></div>
        <div class="st-ai-empty-desc"><asp:Literal ID="litEmptyDesc" runat="server" Text="Start your learning journey first to unlock your AI companion's insights." /></div>
    </div>
</asp:Panel>


</asp:Content>

<asp:Content ID="AIStudyCompanionScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script type="text/javascript">
        window.onload = function () {
        var box = document.getElementById('chatBox');
        if (box) {
            box.scrollTop = box.scrollHeight;
        }
    };
</script>

</asp:Content>