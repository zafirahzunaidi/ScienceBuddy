<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="QuizReview.aspx.cs" Inherits="ScienceBuddy.Student.QuizReview" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%: ResolveUrl("~/Content/Student.css") %>" rel="stylesheet" />
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
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
        <a href="<%: ResolveUrl("~/Student/QuizHistory.aspx") %>" class="sb-sidebar-item active">
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

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><asp:Literal ID="litPageTitle" runat="server" Text="Quiz Review" /></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- ERROR --%>
<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div style="background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);padding:var(--space-2xl);text-align:center;">
        <i class="bi bi-exclamation-triangle-fill" style="font-size:2.5rem;color:var(--student);"></i>
        <div style="margin-top:var(--space-md);font-size:.9375rem;color:var(--color-text);"><asp:Literal ID="litError" runat="server" /></div>
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="st-quizreview-back" style="margin-top:var(--space-lg);display:inline-flex;"><i class="bi bi-arrow-left"></i> <asp:Literal ID="litErrBtn" runat="server" Text="Back" /></a>
    </div>
</asp:Panel>

<%-- REVIEW --%>
<asp:Panel ID="pnlReview" runat="server" Visible="false">

    <%-- Back --%>
    <a href="#" id="lnkBack" runat="server" class="st-quizreview-back"><i class="bi bi-arrow-left"></i> <asp:Literal ID="litBack" runat="server" Text="Back to Result" /></a>

    <%-- Header --%>
    <div class="st-quizreview-header">
        <div class="st-quizreview-header-blob"></div>
        <div class="st-quizreview-header-title"><i class="bi bi-search"></i> <asp:Literal ID="litTitle" runat="server" /></div>
        <div class="st-quizreview-header-sub"><asp:Literal ID="litSub" runat="server" /></div>
        <div class="st-quizreview-header-meta">
            <span class="st-quizreview-header-chip"><i class="bi bi-trophy-fill"></i> <asp:Literal ID="litHeaderPct" runat="server" /></span>
            <span class="st-quizreview-header-chip"><i class="bi bi-check-circle-fill"></i> <asp:Literal ID="litHeaderCorrect" runat="server" /></span>
            <span class="st-quizreview-header-chip"><i class="bi bi-bookmark-fill"></i> <asp:Literal ID="litHeaderType" runat="server" /></span>
        </div>
    </div>

    <%-- Weak Topics --%>
    <asp:Panel ID="pnlWeakTopics" runat="server" Visible="false">
        <div class="st-quizreview-weak">
            <div class="st-quizreview-weak-title"><i class="bi bi-lightbulb-fill" style="color:var(--student);"></i> <asp:Literal ID="litWeakTitle" runat="server" Text="Topics to Review" /></div>
            <div class="st-quizreview-weak-chips">
                <asp:Literal ID="litWeakChips" runat="server" />
            </div>
        </div>
    </asp:Panel>

    <%-- Question List --%>
    <div class="st-quizreview-list">
        <asp:Repeater ID="rptQuestions" runat="server">
            <ItemTemplate>
                <div class='st-quizreview-card <%# (bool)Eval("IsCorrect") ? "correct" : "wrong" %>'>
                    <div class='st-quizreview-card-num <%# (bool)Eval("IsCorrect") ? "correct" : "wrong" %>'>
                        <%# (bool)Eval("IsCorrect") ? "<i class=\"bi bi-check-circle-fill\"></i>" : "<i class=\"bi bi-x-circle-fill\"></i>" %>
                        <%# Eval("QLabel") %>
                    </div>
                    <div class="st-quizreview-card-text"><%# Eval("QuestionText") %></div>
                    <div class="st-quizreview-answer-row">
                        <span class='st-quizreview-answer-badge yours <%# (bool)Eval("IsCorrect") ? "is-correct" : "" %>'><i class="bi bi-pencil-fill"></i> <%# Eval("YourLabel") %>: <%# Eval("SelectedDisplay") %></span>
                        <span class="st-quizreview-answer-badge correct-ans"><i class="bi bi-check-lg"></i> <%# Eval("CorrectLabel") %>: <%# Eval("CorrectDisplay") %></span>
                    </div>
                    <div class='st-quizreview-explanation <%# (bool)Eval("IsCorrect") ? "correct-exp" : "wrong-exp" %>'>
                        <i class='bi <%# (bool)Eval("IsCorrect") ? "bi-lightbulb-fill" : "bi-book-fill" %>' style="margin-right:6px;"></i><%# Eval("Explanation") %>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>

    <%-- Actions --%>
    <div class="st-quizreview-actions">
        <a href="#" id="lnkRetry" runat="server" class="st-quizreview-btn st-quizreview-btn-orange"><i class="bi bi-arrow-repeat"></i> <asp:Literal ID="litRetryBtn" runat="server" Text="Try Again" /></a>
        <a href="#" id="lnkResult" runat="server" class="st-quizreview-btn st-quizreview-btn-primary"><i class="bi bi-bar-chart-fill"></i> <asp:Literal ID="litResultBtn" runat="server" Text="Back to Result" /></a>
        <a href="<%: ResolveUrl("~/Student/PracticeLibrary.aspx") %>" class="st-quizreview-btn st-quizreview-btn-secondary"><i class="bi bi-patch-question"></i> <asp:Literal ID="litPracticeBtn" runat="server" Text="Practice Library" /></a>
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="st-quizreview-btn st-quizreview-btn-secondary"><i class="bi bi-book"></i> <asp:Literal ID="litLearningBtn" runat="server" Text="My Learning" /></a>
        <a href="<%: ResolveUrl("~/Student/QuizHistory.aspx") %>" class="st-quizreview-btn st-quizreview-btn-secondary"><i class="bi bi-clock-history"></i> <asp:Literal ID="litHistoryBtn" runat="server" Text="Quiz History" /></a>
    </div>

</asp:Panel>
</asp:Content>
