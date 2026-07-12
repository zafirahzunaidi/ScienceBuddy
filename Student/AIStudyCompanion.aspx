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

<%-- 1. HERO --%>
<div class="st-ai-hero">
    <div class="st-ai-hero-decor"></div>
    <div class="st-ai-hero-body">
        <div class="st-ai-hero-left">
            <span class="st-ai-hero-label">YOUR AI SCIENCE COACH</span>
            <div class="st-ai-hero-sub"><asp:Literal ID="litHeroSub" runat="server" Text="Your smart learning buddy is here to guide your next step." /></div>
            <div class="st-ai-hero-msg"><asp:Literal ID="litAIMessage" runat="server" /></div>
            <div class="st-ai-hero-tags">
                <span class="st-ai-hero-tag"><i class="bi bi-book"></i> <asp:Literal ID="litCurrentLevel" runat="server" /></span>
                <span class="st-ai-hero-tag"><i class="bi bi-stars"></i> <asp:Literal ID="litPersonality" runat="server" /></span>
            </div>
        </div>
        <div class="st-ai-hero-right">
            <% if (!string.IsNullOrEmpty(PersonalityAvatar)) { %>
            <img src="<%= PersonalityAvatar %>" alt="" class="st-ai-hero-avatar" />
            <% } else { %>
            <div class="st-ai-hero-avatar-fallback"><i class="bi bi-robot"></i></div>
            <% } %>
            <span class="st-ai-hero-name"><asp:Literal ID="litStudentName" runat="server" /></span>
        </div>
    </div>
    <span style="display:none;"><asp:Literal ID="litHeroTitle" runat="server" Text="AI Study Companion" /></span>
</div>

<%-- 2. PERSONALITY INSIGHT --%>
<asp:Panel ID="pnlPersonalityInsight" runat="server" Visible="false">
    <div class="st-ai-insight">
        <i class="bi bi-lightbulb-fill st-ai-insight-icon"></i>
        <div class="st-ai-insight-body">
            <div class="st-ai-insight-label"><asp:Literal ID="litPersonalityInsightLabel" runat="server" Text="Why this fits you" /></div>
            <div class="st-ai-insight-text"><asp:Literal ID="litPersonalityInsightText" runat="server" /></div>
        </div>
    </div>
</asp:Panel>

<%-- 3. LEARNING SNAPSHOT --%>
<div class="st-ai-section-card">
    <div class="st-ai-section-header"><i class="bi bi-graph-up"></i> <asp:Literal ID="litHealthTitle" runat="server" Text="Learning Health" /></div>
    <asp:Panel ID="pnlStatusRow" runat="server" Visible="false">
        <div class="st-ai-status-badges">
            <span class="st-ai-badge st-ai-badge-green"><i class="bi bi-graph-up-arrow"></i> <asp:Literal ID="litTrendBadge" runat="server" /></span>
            <span class="st-ai-badge st-ai-badge-purple"><i class="bi bi-shield-check"></i> <asp:Literal ID="litConfidenceBadge" runat="server" /></span>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlHealth" runat="server">
        <div class="st-ai-stats-grid">
            <div class="st-ai-stat-card st-ai-stat-blue">
                <div class="st-ai-stat-value"><asp:Literal ID="litAvgScore" runat="server" Text="0%" /></div>
                <div class="st-ai-stat-label"><asp:Literal ID="litAvgScoreLbl" runat="server" Text="Average Score" /></div>
            </div>
            <div class="st-ai-stat-card st-ai-stat-purple">
                <div class="st-ai-stat-value"><asp:Literal ID="litTotalAttempts" runat="server" Text="0" /></div>
                <div class="st-ai-stat-label"><asp:Literal ID="litTotalAttemptsLbl" runat="server" Text="Quizzes Tried" /></div>
            </div>
            <div class="st-ai-stat-card st-ai-stat-green">
                <div class="st-ai-stat-value"><asp:Literal ID="litStrongTopics" runat="server" /></div>
                <div class="st-ai-stat-label"><asp:Literal ID="litStrongTopicsLbl" runat="server" Text="Current Trend" /></div>
            </div>
            <div class="st-ai-stat-card st-ai-stat-orange">
                <div class="st-ai-stat-value"><asp:Literal ID="litWeakTopics" runat="server" /></div>
                <div class="st-ai-stat-label"><asp:Literal ID="litWeakTopicsLbl" runat="server" Text="Learning Picture" /></div>
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlHealthEmpty" runat="server" Visible="false">
        <div class="st-ai-empty-state">
            <i class="bi bi-clipboard2-data"></i>
            <p><asp:Literal ID="litHealthEmpty" runat="server" Text="Complete more quizzes to unlock your personalised learning analysis." /></p>
        </div>
    </asp:Panel>
</div>

<%-- 4. TOPIC ZONE --%>
<div class="st-ai-section-card">
    <div class="st-ai-section-header"><i class="bi bi-map"></i> <asp:Literal ID="litTopicZoneTitle" runat="server" Text="My Topic Zone" /></div>
    <div class="st-ai-topics-grid">
        <%-- Strong --%>
        <div>
            <asp:Panel ID="pnlStrong" runat="server">
                <div class="st-ai-topic-card st-ai-topic-green">
                    <div class="st-ai-topic-title"><i class="bi bi-hand-thumbs-up-fill"></i> <asp:Literal ID="litStrongTitle" runat="server" Text="Strong Topics" /></div>
                    <div class="st-ai-topic-chips"><asp:Literal ID="litStrongList" runat="server" /></div>
                </div>
            </asp:Panel>
            <asp:Panel ID="pnlStrongEmpty" runat="server" Visible="false">
                <div class="st-ai-topic-card st-ai-topic-green st-ai-topic-empty">
                    <div class="st-ai-topic-title"><i class="bi bi-hand-thumbs-up-fill"></i> <asp:Literal ID="litStrongEmptyTitle" runat="server" Text="Strong Topics" /></div>
                    <div class="st-ai-topic-desc"><asp:Literal ID="litStrongEmpty" runat="server" Text="Your strong topics will appear here after you attempt more quizzes." /></div>
                </div>
            </asp:Panel>
        </div>
        <%-- Weak --%>
        <div>
            <asp:Panel ID="pnlWeak" runat="server">
                <div class="st-ai-topic-card st-ai-topic-orange">
                    <div class="st-ai-topic-title"><i class="bi bi-bullseye"></i> <asp:Literal ID="litWeakTitle" runat="server" Text="Weak Topics" /></div>
                    <div class="st-ai-topic-chips"><asp:Literal ID="litWeakList" runat="server" /></div>
                </div>
            </asp:Panel>
            <asp:Panel ID="pnlWeakEmpty" runat="server" Visible="false">
                <div class="st-ai-topic-card st-ai-topic-orange st-ai-topic-empty">
                    <div class="st-ai-topic-title"><i class="bi bi-bullseye"></i> <asp:Literal ID="litWeakEmptyTitle" runat="server" Text="Weak Topics" /></div>
                    <div class="st-ai-topic-desc"><asp:Literal ID="litWeakEmpty" runat="server" Text="No weak topics detected yet. Keep learning!" /></div>
                </div>
            </asp:Panel>
        </div>
    </div>
</div>

<%-- 5. NEXT ADVENTURE --%>
<asp:Panel ID="pnlRecommend" runat="server">
    <div class="st-ai-section-card">
        <div class="st-ai-section-header"><i class="bi bi-rocket-takeoff"></i> <asp:Literal ID="litRecommendTitle" runat="server" Text="Recommended Next Steps" /></div>
        <div class="st-ai-recommend-grid">
            <asp:Repeater ID="rptRecommendations" runat="server">
                <ItemTemplate>
                    <div class="st-ai-recommend-card">
                        <div class="st-ai-recommend-icon"><%# Eval("Icon") %></div>
                        <div class="st-ai-recommend-body">
                            <div class="st-ai-recommend-title"><%# Eval("Title") %></div>
                            <div class="st-ai-recommend-reason"><%# Eval("Reason") %></div>
                        </div>
                        <a href='<%# Eval("Url") %>' class="st-ai-recommend-btn"><i class="bi bi-arrow-right"></i> <%# Eval("BtnText") %></a>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
        <div class="st-ai-coach-says">
            <i class="bi bi-chat-square-quote"></i>
            <span><asp:Literal ID="litExplanation" runat="server" /></span>
        </div>
    </div>
</asp:Panel>

<%-- 6. MISSION PATH --%>
<div class="st-ai-section-card st-ai-mission-card">
    <div class="st-ai-section-header"><i class="bi bi-signpost-2"></i> <asp:Literal ID="litTipsTitle" runat="server" Text="Your 3-Step Mission" /></div>
    <div class="st-ai-mission-steps">
        <div class="st-ai-step">
            <div class="st-ai-step-num">1</div>
            <div class="st-ai-step-text"><asp:Literal ID="litTip1" runat="server" /></div>
        </div>
        <div class="st-ai-step-chevron"><i class="bi bi-chevron-right"></i></div>
        <div class="st-ai-step">
            <div class="st-ai-step-num">2</div>
            <div class="st-ai-step-text"><asp:Literal ID="litTip2" runat="server" /></div>
        </div>
        <div class="st-ai-step-chevron"><i class="bi bi-chevron-right"></i></div>
        <div class="st-ai-step">
            <div class="st-ai-step-num">3</div>
            <div class="st-ai-step-text"><asp:Literal ID="litTip3" runat="server" /></div>
        </div>
    </div>
</div>

<%-- 7. AI CHATBOT --%>
<asp:Panel ID="pnlAIChat" runat="server">
    <div class="st-ai-chat-card">
        <div class="st-ai-chat-header">
            <i class="bi bi-robot st-ai-chat-header-icon"></i>
            <div>
                <div class="st-ai-chat-title"><asp:Literal ID="litChatTitle" runat="server" Text="Ask ScienceBuddy AI" /></div>
                <div class="st-ai-chat-subtitle"><asp:Literal ID="litChatSub" runat="server" Text="Ask me anything about your Science lessons." /></div>
            </div>
        </div>

        <div id="chatBox" runat="server" clientidmode="Static" class="st-ai-chatbox"></div>

        <div class="st-ai-chat-chips">
            <button type="button" class="st-ai-chip" onclick="document.getElementById('<%= txtAIMessage.ClientID %>').value = 'What should I learn next?';">
                <i class="bi bi-signpost-split"></i> What next?
            </button>
            <button type="button" class="st-ai-chip" onclick="document.getElementById('<%= txtAIMessage.ClientID %>').value = 'Help me with my focus topic';">
                <i class="bi bi-bullseye"></i> Focus topic
            </button>
            <button type="button" class="st-ai-chip" onclick="document.getElementById('<%= txtAIMessage.ClientID %>').value = 'Give me a 10-minute mission';">
                <i class="bi bi-lightning-charge"></i> 10-min mission
            </button>
        </div>

        <div class="st-ai-chat-input-row">
            <asp:TextBox ID="txtAIMessage" runat="server" CssClass="st-ai-chat-input" TextMode="MultiLine" Rows="2" placeholder="Ask your AI study question..." />
            <asp:Button ID="btnAISend" runat="server" CssClass="st-ai-chat-send" Text="Send" OnClick="btnAISend_Click" />
        </div>
        <div class="st-ai-chat-note"><i class="bi bi-info-circle"></i> <asp:Literal ID="litChatNote" runat="server" Text="AI can make mistakes, so always check with your teacher or lesson notes." /></div>
    </div>
</asp:Panel>

<%-- 8. EMPTY STATE --%>
<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="st-ai-empty-page">
        <div class="st-ai-empty-page-icon"><i class="bi bi-rocket-takeoff-fill"></i></div>
        <h2 class="st-ai-empty-page-title"><asp:Literal ID="litEmptyTitle" runat="server" Text="Start your learning journey!" /></h2>
        <p class="st-ai-empty-page-desc"><asp:Literal ID="litEmptyDesc" runat="server" Text="Start your learning journey first to unlock your AI companion's insights." /></p>
    </div>
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
