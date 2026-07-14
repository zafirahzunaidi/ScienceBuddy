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

<div class="st-ai-page" style="--pc: <%= PersonalityColour %>;">

<%-- ═══ 1. PERSONAL PROGRESS HERO ═══ --%>
<div class="st-ai-hero">
    <div class="st-ai-hero-body">
        <div class="st-ai-hero-left">
            <div class="st-ai-hero-greeting">Hi, <asp:Literal ID="litStudentName" runat="server" />!</div>
            <div class="st-ai-hero-headline"><asp:Literal ID="litAIMessage" runat="server" /></div>
            <div class="st-ai-hero-celebration"><asp:Literal ID="litHeroSub" runat="server" /></div>

            <asp:Panel ID="pnlHealth" runat="server">
                <div class="st-ai-hero-scores">
                    <div class="st-ai-hero-score-item">
                        <span class="st-ai-hero-score-label"><asp:Literal ID="litAvgScoreLbl" runat="server" Text="Latest Score" /></span>
                        <span class="st-ai-hero-score-value"><asp:Literal ID="litAvgScore" runat="server" Text="0%" /></span>
                    </div>
                    <div class="st-ai-hero-score-item">
                        <span class="st-ai-hero-score-label"><asp:Literal ID="litTotalAttemptsLbl" runat="server" Text="Previous Avg" /></span>
                        <span class="st-ai-hero-score-value"><asp:Literal ID="litTotalAttempts" runat="server" Text="0%" /></span>
                    </div>
                    <div class="st-ai-hero-score-item">
                        <span class="st-ai-hero-score-label"><asp:Literal ID="litStrongTopicsLbl" runat="server" Text="Change" /></span>
                        <span class="st-ai-hero-score-value st-ai-hero-score-change"><asp:Literal ID="litStrongTopics" runat="server" /></span>
                    </div>
                </div>
                <div class="st-ai-hero-quiz-meta">
                    <% if (!string.IsNullOrEmpty(GeneratedQuizTitle)) { %>
                    <span class="st-ai-hero-quiz-title"><i class="bi bi-clipboard-check"></i> <%= HttpUtility.HtmlEncode(GeneratedQuizTitle) %></span>
                    <% } %>
                    <% if (!string.IsNullOrEmpty(GeneratedQuizDate)) { %>
                    <span class="st-ai-hero-quiz-date"><%= HttpUtility.HtmlEncode(GeneratedQuizDate) %></span>
                    <% } %>
                </div>
            </asp:Panel>

            <div class="st-ai-hero-tags">
                <span class="st-ai-hero-tag"><i class="bi bi-layers"></i> <asp:Literal ID="litCurrentLevel" runat="server" /></span>
                <span class="st-ai-hero-tag" style="background:var(--pc);"><i class="bi bi-stars"></i> <asp:Literal ID="litPersonality" runat="server" /></span>
                <span class="st-ai-hero-tag"><i class="bi bi-pencil-square"></i> <asp:Literal ID="litWeakTopics" runat="server" /> <asp:Literal ID="litWeakTopicsLbl" runat="server" Text="quizzes" /></span>
            </div>
        </div>
        <div class="st-ai-hero-right">
            <% if (!string.IsNullOrEmpty(PersonalityAvatar)) { %>
            <img src="<%= PersonalityAvatar %>" alt="" class="st-ai-hero-avatar" />
            <% } else { %>
            <div class="st-ai-hero-avatar-fallback"><i class="bi bi-robot"></i></div>
            <% } %>
        </div>
    </div>
    <span style="display:none;"><asp:Literal ID="litHeroTitle" runat="server" Text="AI Study Companion" /></span>
</div>

<%-- ═══ 2. AI NOTICED THIS ABOUT YOU ═══ --%>
<asp:Panel ID="pnlStatusRow" runat="server" Visible="false">
<div class="st-ai-noticed">
    <div class="st-ai-noticed-title"><i class="bi bi-lightbulb"></i> <asp:Literal ID="litHealthTitle" runat="server" Text="AI noticed this about you" /></div>
    <div class="st-ai-noticed-grid">
        <%-- Card 1: Your Win --%>
        <div class="st-ai-noticed-card st-ai-noticed-green">
            <div class="st-ai-noticed-card-label"><i class="bi bi-trophy-fill"></i> <asp:Literal ID="litStrongTitle" runat="server" Text="Your Win" /></div>
            <asp:Panel ID="pnlStrong" runat="server">
                <div class="st-ai-noticed-chips"><asp:Literal ID="litStrongList" runat="server" /></div>
            </asp:Panel>
            <asp:Panel ID="pnlStrongEmpty" runat="server" Visible="false">
                <div class="st-ai-noticed-empty"><asp:Literal ID="litStrongEmpty" runat="server" Text="Keep going to discover your strengths!" /></div>
            </asp:Panel>
        </div>
        <%-- Card 2: Your Focus --%>
        <div class="st-ai-noticed-card st-ai-noticed-orange">
            <div class="st-ai-noticed-card-label"><i class="bi bi-bullseye"></i> <asp:Literal ID="litWeakTitle" runat="server" Text="Your Focus" /></div>
            <asp:Panel ID="pnlWeak" runat="server">
                <div class="st-ai-noticed-chips"><asp:Literal ID="litWeakList" runat="server" /></div>
            </asp:Panel>
            <asp:Panel ID="pnlWeakEmpty" runat="server" Visible="false">
                <div class="st-ai-noticed-empty"><asp:Literal ID="litWeakEmpty" runat="server" Text="No weak topics yet. Great job!" /></div>
            </asp:Panel>
        </div>
        <%-- Card 3: Your Personality Style --%>
        <div class="st-ai-noticed-card st-ai-noticed-purple">
            <div class="st-ai-noticed-card-label"><i class="bi bi-person-hearts"></i> <asp:Literal ID="litPersonalityInsightLabel" runat="server" Text="Your Style" /></div>
            <asp:Panel ID="pnlPersonalityInsight" runat="server" Visible="false">
                <div class="st-ai-noticed-text"><asp:Literal ID="litPersonalityInsightText" runat="server" /></div>
                <div class="st-ai-noticed-style"><asp:Literal ID="litTopicZoneTitle" runat="server" /></div>
            </asp:Panel>
        </div>
    </div>
</div>
</asp:Panel>

<%-- ═══ 3. YOUR PLAN FOR TODAY ═══ --%>
<asp:Panel ID="pnlRecommend" runat="server">
<div class="st-ai-plan">
    <div class="st-ai-plan-title"><i class="bi bi-rocket-takeoff"></i> <asp:Literal ID="litRecommendTitle" runat="server" Text="Your plan for today" /></div>
    <div class="st-ai-plan-grid">
        <asp:Repeater ID="rptRecommendations" runat="server">
            <ItemTemplate>
                <div class="st-ai-plan-card">
                    <div class="st-ai-plan-card-category"><%# Eval("Category") %></div>
                    <div class="st-ai-plan-card-icon"><%# Eval("Icon") %></div>
                    <div class="st-ai-plan-card-title"><%# Eval("Title") %></div>
                    <div class="st-ai-plan-card-short"><%# Eval("ShortReason") %></div>
                    <details class="st-ai-plan-card-details">
                        <summary>Why this?</summary>
                        <p><%# Eval("Reason") %></p>
                    </details>
                    <a href='<%# Eval("Url") %>' class="st-ai-plan-card-btn"><i class="bi bi-arrow-right"></i> <%# Eval("BtnText") %></a>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
    <div class="st-ai-plan-tip">
        <i class="bi bi-chat-square-quote"></i>
        <span><strong>Coach Tip:</strong> <asp:Literal ID="litExplanation" runat="server" /></span>
    </div>
</div>
</asp:Panel>

<%-- ═══ 4. YOUR PERSONALITY MISSION ═══ --%>
<div class="st-ai-mission">
    <div class="st-ai-mission-title"><i class="bi bi-signpost-2"></i> <asp:Literal ID="litTipsTitle" runat="server" Text="Your 3-Step Mission" /></div>
    <div class="st-ai-mission-grid">
        <div class="st-ai-mission-step">
            <div class="st-ai-mission-step-label"><asp:Literal ID="litStrongEmptyTitle" runat="server" Text="STEP 1" /></div>
            <div class="st-ai-mission-step-text"><asp:Literal ID="litTip1" runat="server" /></div>
        </div>
        <div class="st-ai-mission-step-arrow"><i class="bi bi-chevron-right"></i></div>
        <div class="st-ai-mission-step">
            <div class="st-ai-mission-step-label"><asp:Literal ID="litTrendBadge" runat="server" Text="STEP 2" /></div>
            <div class="st-ai-mission-step-text"><asp:Literal ID="litTip2" runat="server" /></div>
        </div>
        <div class="st-ai-mission-step-arrow"><i class="bi bi-chevron-right"></i></div>
        <div class="st-ai-mission-step">
            <div class="st-ai-mission-step-label"><asp:Literal ID="litConfidenceBadge" runat="server" Text="STEP 3" /></div>
            <div class="st-ai-mission-step-text"><asp:Literal ID="litTip3" runat="server" /></div>
        </div>
    </div>
</div>

<%-- ═══ 5. ASK YOUR AI COACH ═══ --%>
<asp:Panel ID="pnlAIChat" runat="server">
    <div class="st-ai-chat-card">
        <div class="st-ai-chat-header">
            <i class="bi bi-robot st-ai-chat-header-icon"></i>
            <div>
                <div class="st-ai-chat-title"><asp:Literal ID="litChatTitle" runat="server" Text="Ask your AI Coach" /></div>
                <div class="st-ai-chat-subtitle"><asp:Literal ID="litChatSub" runat="server" Text="I know your latest results. Ask what to learn next!" /></div>
            </div>
        </div>

        <div id="chatBox" runat="server" clientidmode="Static" class="st-ai-chatbox"></div>

        <div class="st-ai-chat-chips">
            <asp:Literal ID="litChatChip1" runat="server" />
            <asp:Literal ID="litChatChip2" runat="server" />
            <asp:Literal ID="litChatChip3" runat="server" />
            <asp:Literal ID="litChatChip4" runat="server" />
        </div>

        <div class="st-ai-chat-input-row">
            <asp:TextBox ID="txtAIMessage" runat="server" CssClass="st-ai-chat-input" TextMode="MultiLine" Rows="2" placeholder="Ask your AI study question..." />
            <asp:Button ID="btnAISend" runat="server" CssClass="st-ai-chat-send" Text="Send" OnClick="btnAISend_Click" />
        </div>
        <div class="st-ai-chat-note"><i class="bi bi-info-circle"></i> <asp:Literal ID="litChatNote" runat="server" Text="AI can make mistakes, so always check with your teacher or lesson notes." /></div>
    </div>
</asp:Panel>

<%-- EMPTY STATE --%>
<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="st-ai-empty-page">
        <div class="st-ai-empty-page-icon"><i class="bi bi-rocket-takeoff-fill"></i></div>
        <h2 class="st-ai-empty-page-title"><asp:Literal ID="litEmptyTitle" runat="server" Text="Start your learning journey!" /></h2>
        <p class="st-ai-empty-page-desc"><asp:Literal ID="litEmptyDesc" runat="server" Text="Start your learning journey first to unlock your AI companion's insights." /></p>
    </div>
</asp:Panel>

<asp:Panel ID="pnlHealthEmpty" runat="server" Visible="false">
    <asp:Literal ID="litHealthEmpty" runat="server" />
</asp:Panel>

</div><%-- /st-ai-page --%>

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
