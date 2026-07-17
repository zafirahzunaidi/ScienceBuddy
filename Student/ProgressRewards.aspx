<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ProgressRewards.aspx.cs"
    Inherits="ScienceBuddy.Student.ProgressReward" MasterPageFile="~/Site.Master"
    Title="Progress &amp; Rewards" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Student.css") %>" rel="stylesheet" />
</asp:Content>

<asp:Content ID="cSidebarMenu" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Main</div>
        <a href="<%: ResolveUrl("~/Student/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label">Dashboard</span></a>
        <a href="<%: ResolveUrl("~/Student/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span></a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Learn</div>
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label">My Learning</span></a>
        <a href="<%: ResolveUrl("~/Student/PracticeLibrary.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label">Practice Library</span></a>
        <a href="<%: ResolveUrl("~/Student/QuizHistory.aspx") %>" class="sb-sidebar-item"><i class="bi bi-clock-history item-icon"></i><span class="item-label">Quiz History</span></a>
        <a href="<%: ResolveUrl("~/Student/VirtualLabs.aspx") %>" class="sb-sidebar-item"><i class="bi bi-eyedropper item-icon"></i><span class="item-label">Virtual Labs</span></a>
        <a href="<%: ResolveUrl("~/Student/LiveSessions.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label">Live Sessions</span></a>
        <a href="<%: ResolveUrl("~/Student/AIStudyCompanion.aspx") %>" class="sb-sidebar-item"><i class="bi bi-robot item-icon"></i><span class="item-label">AI Study Companion</span></a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Communication</div>
        <a href="<%: ResolveUrl("~/Student/Messages.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label">Messages</span></a>
        <a href="<%: ResolveUrl("~/Student/Forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-people item-icon"></i><span class="item-label">Forum</span></a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Progress</div>
        <a href="<%: ResolveUrl("~/Student/ProgressRewards.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-bar-chart-line item-icon"></i><span class="item-label">Progress &amp; Rewards</span></a>
        <a href="<%: ResolveUrl("~/Student/MyRanking.aspx") %>" class="sb-sidebar-item"><i class="bi bi-trophy item-icon"></i><span class="item-label">My Ranking</span></a>
        <a href="<%: ResolveUrl("~/Student/RevisionPlan.aspx") %>" class="sb-sidebar-item"><i class="bi bi-calendar-check item-icon"></i><span class="item-label">Revision Plan</span></a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Student/MyProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <asp:Literal ID="litPageTitle" runat="server" Text="Progress &amp; Rewards" />
</asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

    <%-- EMPTY STATE --%>
    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="st-progress-empty-page">
            <div class="st-progress-empty-icon"><i class="bi bi-rocket-takeoff-fill"></i></div>
            <h2 class="st-progress-empty-title"><asp:Literal ID="litEmptyTitle" runat="server" /></h2>
            <p class="st-progress-empty-desc"><asp:Literal ID="litEmptyDesc" runat="server" /></p>
            <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="st-progress-empty-btn"><i class="bi bi-book"></i> <asp:Literal ID="litEmptyBtn" runat="server" /></a>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlMain" runat="server">

    <%-- HERO --%>
    <div class="st-progress-hero">
        <div class="st-progress-hero-decor"></div>
        <div class="st-progress-hero-content">
            <h1 class="st-progress-hero-title"><i class="bi bi-trophy-fill"></i> <asp:Literal ID="litHeroTitle" runat="server" /></h1>
            <p class="st-progress-hero-subtitle"><asp:Literal ID="litHeroSubtitle" runat="server" /></p>
        </div>
    </div>

    <%-- STAT CARDS --%>
    <div class="st-progress-stats-grid">
        <div class="st-progress-stat-card st-progress-stat-xp">
            <div class="st-progress-stat-icon"><i class="bi bi-lightning-charge-fill"></i></div>
            <div class="st-progress-stat-value"><asp:Literal ID="litStatXP" runat="server" Text="0" /></div>
            <div class="st-progress-stat-label"><asp:Literal ID="litStatXPLabel" runat="server" /></div>
        </div>
        <div class="st-progress-stat-card st-progress-stat-lessons">
            <div class="st-progress-stat-icon"><i class="bi bi-book-fill"></i></div>
            <div class="st-progress-stat-value"><asp:Literal ID="litStatLessons" runat="server" Text="0" /></div>
            <div class="st-progress-stat-label"><asp:Literal ID="litStatLessonsLabel" runat="server" /></div>
        </div>
        <div class="st-progress-stat-card st-progress-stat-quizzes">
            <div class="st-progress-stat-icon"><i class="bi bi-patch-question-fill"></i></div>
            <div class="st-progress-stat-value"><asp:Literal ID="litStatQuizzes" runat="server" Text="0" /></div>
            <div class="st-progress-stat-label"><asp:Literal ID="litStatQuizzesLabel" runat="server" /></div>
        </div>
        <div class="st-progress-stat-card st-progress-stat-badges">
            <div class="st-progress-stat-icon"><i class="bi bi-award-fill"></i></div>
            <div class="st-progress-stat-value"><asp:Literal ID="litStatBadges" runat="server" Text="0" /></div>
            <div class="st-progress-stat-label"><asp:Literal ID="litStatBadgesLabel" runat="server" /></div>
        </div>
    </div>

    <%-- WEEKLY ACTIVITY --%>
    <div class="st-progress-section-card">
        <div class="st-progress-section-header"><i class="bi bi-graph-up"></i> <asp:Literal ID="litWeeklyTitle" runat="server" /></div>
        <asp:Literal ID="litWeeklyChart" runat="server" />
        <div class="st-progress-chart-legend"><asp:Literal ID="litChartLegend" runat="server" /></div>
    </div>


    <%-- BADGE COLLECTION --%>
    <div class="st-progress-section-card">
        <div class="st-progress-section-header"><i class="bi bi-award"></i> <asp:Literal ID="litBadgeTitle" runat="server" /></div>
        <asp:Panel ID="pnlBadges" runat="server">
            <div class="st-progress-badge-grid">
                <asp:Repeater ID="rptBadges" runat="server">
                    <ItemTemplate>
                        <div class='st-progress-badge-card <%# (bool)Eval("IsEarned") ? "earned" : "locked" %>'>
                            <div class="st-progress-badge-icon-wrap">
                                <%# !string.IsNullOrEmpty((string)Eval("IconUrl"))
                                    ? "<img src='" + Eval("IconUrl") + "' alt='" + Eval("Name") + "' onerror=\"this.style.display='none';this.nextElementSibling.style.display='flex';\" /><div class='st-progress-badge-fallback' style='display:none;'><i class='bi bi-award-fill'></i></div>"
                                    : "<div class='st-progress-badge-fallback'><i class='bi bi-award-fill'></i></div>" %>
                            </div>
                            <div class="st-progress-badge-info">
                                <div class="st-progress-badge-name"><%# Eval("Name") %></div>
                                <div class="st-progress-badge-desc"><%# Eval("Description") %></div>
                            </div>
                            <div class='st-progress-badge-status <%# (bool)Eval("IsEarned") ? "earned" : "locked" %>'>
                                <i class='bi <%# (bool)Eval("IsEarned") ? "bi-check-circle-fill" : "bi-lock-fill" %>'></i>
                                <%# (bool)Eval("IsEarned") ? Eval("EarnedText") : Eval("LockedText") %>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </asp:Panel>
        <asp:Panel ID="pnlNoBadges" runat="server" Visible="false">
            <div class="st-progress-empty-state"><i class="bi bi-award"></i><p><asp:Literal ID="litNoBadges" runat="server" /></p></div>
        </asp:Panel>
    </div>

    <%-- CERTIFICATES --%>
    <div class="st-progress-section-card">
        <div class="st-progress-section-header"><i class="bi bi-file-earmark-check-fill"></i> <asp:Literal ID="litCertTitle" runat="server" /></div>
        <asp:Literal ID="litCertContent" runat="server" />
    </div>

    <%-- BUDDY TIP --%>
    <asp:Panel ID="pnlAIHint" runat="server">
        <div class="st-progress-ai-hint">
            <div class="st-progress-ai-hint-icon"><i class="bi bi-robot"></i></div>
            <div class="st-progress-ai-hint-body">
                <div class="st-progress-ai-hint-title"><asp:Literal ID="litAIHintTitle" runat="server" /></div>
                <div class="st-progress-ai-hint-text"><asp:Literal ID="litAIHintText" runat="server" /></div>
            </div>
        </div>
    </asp:Panel>

    <%-- CERTIFICATE MODAL --%>
    <div id="certModal" class="st-progress-cert-modal" style="display:none;" onclick="closeCertModal(event)">
        <div class="st-progress-cert-modal-content" onclick="event.stopPropagation();">
            <button type="button" class="st-progress-cert-modal-close" onclick="closeCertModal(event)"><i class="bi bi-x-lg"></i></button>
            <iframe id="certFrame" class="st-progress-cert-modal-frame" src="about:blank"></iframe>
        </div>
    </div>
    <script>
    function openCertModal(url){
        document.getElementById('certFrame').src=url;
        document.getElementById('certModal').style.display='flex';
        document.body.style.overflow='hidden';
    }
    function closeCertModal(e){
        document.getElementById('certModal').style.display='none';
        document.getElementById('certFrame').src='about:blank';
        document.body.style.overflow='';
    }
    </script>

    </asp:Panel>
</asp:Content>
