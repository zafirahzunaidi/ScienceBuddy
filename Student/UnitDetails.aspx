<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="UnitDetails.aspx.cs" Inherits="ScienceBuddy.Student.UnitDetails" %>

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
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="sb-sidebar-item active">
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

<asp:Content ID="UnitDetailsPageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <asp:Literal ID="litPageTitle" runat="server" Text="Unit Details" />
</asp:Content>

<asp:Content ID="StudentUserDropdownMenu" ContentPlaceHolderID="UserDropdownMenu" runat="server">
</asp:Content>

<asp:Content ID="UnitDetailsBreadcrumb" ContentPlaceHolderID="BreadcrumbContent" runat="server">
</asp:Content>

<%-- UnitDetails Main Content --%>
<asp:Content ID="UnitDetailsMainContent" ContentPlaceHolderID="MainContentSidebar" runat="server">

    <asp:Panel ID="pnlLocked" runat="server" Visible="false">
        <div class="st-unitdetails-locked"><div class="st-unitdetails-locked-icon"><i class="bi bi-lock-fill"></i></div>
            <div class="st-unitdetails-locked-title"><asp:Literal ID="litLockedTitle" runat="server" /></div>
            <div class="st-unitdetails-locked-desc"><asp:Literal ID="litLockedDesc" runat="server" /></div>
            <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="sb-btn sb-btn-primary sb-btn-sm"><i class="bi bi-arrow-left"></i> <asp:Literal ID="litLockedBtn" runat="server" /></a>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlMain" runat="server">

    <div class="st-unitdetails-hero">
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="st-unitdetails-hero-back"><i class="bi bi-arrow-left"></i> <asp:Literal ID="litBack" runat="server" /></a>
        <div class="st-unitdetails-hero-name"><asp:Literal ID="litUnitName" runat="server" /></div>
        <div class="st-unitdetails-hero-desc"><asp:Literal ID="litUnitDesc" runat="server" /></div>
        <div class="st-unitdetails-hero-level"><i class="bi bi-bar-chart-fill"></i> <asp:Literal ID="litHeroLevel" runat="server" /></div>
        <div class="st-unitdetails-hero-bar">
            <div class="st-unitdetails-bar"><div class="st-unitdetails-bar-fill" id="heroBar" runat="server" style="width:0%"></div></div>
            <div class="st-unitdetails-bar-lbl"><span><asp:Literal ID="litBarLbl" runat="server" /></span><span><asp:Literal ID="litBarPct" runat="server" Text="0%" /></span></div>
        </div>
    </div>


    <%-- Subtopics & Lessons --%>
    <asp:Panel ID="pnlLessons" runat="server">
        <div class="st-unitdetails-sec-hd"><i class="bi bi-journal-text" style="color:var(--student);font-size:1.1rem;"></i><div class="st-unitdetails-sec-title"><asp:Literal ID="litLessonHd" runat="server" /></div></div>
        <asp:Repeater ID="rptSubtopics" runat="server">
            <ItemTemplate>
                <div class="st-unitdetails-subtopic">
                    <div class="st-unitdetails-subtopic-title"><i class="bi bi-bookmark-fill" style="color:var(--student);"></i> <%# Eval("Title") %></div>
                    <div class="st-unitdetails-subtopic-desc"><%# Eval("Desc") %></div>
                    <div class="st-unitdetails-lessons st-unitdetails-road">
                        <asp:Repeater ID="rptLessons" runat="server" DataSource='<%# Eval("Lessons") %>'>
                            <ItemTemplate>
                                <a href="<%# Eval("Url") %>" class="st-unitdetails-lesson-link">
                                    <div class="st-unitdetails-lesson-node <%# (bool)Eval("Done") ? "done" : "pending" %>">
                                        <i class="bi <%# (bool)Eval("Done") ? "bi-check-lg" : "bi-play-fill" %>"></i>
                                    </div>
                                    <div class="st-unitdetails-lesson-content">
                                        <div class="st-unitdetails-lesson-name"><%# Eval("Title") %></div>
                                        <span class="st-unitdetails-lesson-badge" style="background:<%# (bool)Eval("Done") ? "#DCFCE7" : "#F0F7FF" %>;color:<%# (bool)Eval("Done") ? "#15803D" : "#2563EB" %>;">
                                            <%# Eval("Badge") %>
                                        </span>
                                    </div>
                                </a>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </asp:Panel>

    <%-- Materials --%>
    <asp:Panel ID="pnlMats" runat="server">
        <div class="st-unitdetails-sec-hd"><i class="bi bi-folder-fill" style="color:#B45309;font-size:1.1rem;"></i><div class="st-unitdetails-sec-title"><asp:Literal ID="litMatHd" runat="server" /></div></div>
        <div class="st-unitdetails-mat-grid">
            <asp:Repeater ID="rptMats" runat="server">
                <ItemTemplate>
                    <div class="st-unitdetails-mat-card">
                        <div class="st-unitdetails-mat-title"><%# Eval("Title") %></div>
                        <div class="st-unitdetails-mat-meta"><span><i class="bi bi-file-earmark"></i> <%# Eval("Type") %></span><span><i class="bi bi-translate"></i> <%# Eval("Lang") %></span></div>
                        <div class="st-unitdetails-mat-actions">
                            <button type="button" class="sb-btn sb-btn-xs sb-btn-primary st-unitdetails-mat-view-btn" onclick="openMaterialPreview('<%# Eval("ResolvedUrl") %>', '<%# Eval("Title").ToString().Replace("'","\\'") %>')"><i class="bi bi-eye"></i> <%# Eval("ViewBtn") %></button>
                            <a href="<%# Eval("ResolvedUrl") %>" class="sb-btn sb-btn-xs sb-btn-outline-primary" download><i class="bi bi-download"></i> <%# Eval("DownloadBtn") %></a>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlMatsEmpty" runat="server" Visible="false">
        <div class="sb-alert sb-alert-info mb-lg"><i class="bi bi-info-circle-fill alert-icon"></i><div class="alert-content"><asp:Literal ID="litMatsEmpty" runat="server" /></div></div>
    </asp:Panel>

    <%-- Material Preview Modal --%>
    <div id="materialPreviewModal" class="st-unitdetails-mat-modal" style="display:none;" onclick="if(event.target===this)closeMaterialPreview();">
        <div class="st-unitdetails-mat-modal-content">
            <div class="st-unitdetails-mat-modal-header">
                <span id="materialPreviewTitle"></span>
                <button type="button" onclick="closeMaterialPreview();" class="st-unitdetails-mat-modal-close"><i class="bi bi-x-lg"></i></button>
            </div>
            <iframe id="materialPreviewFrame" class="st-unitdetails-mat-modal-frame" src="about:blank"></iframe>
        </div>
    </div>

    <%-- Virtual Lab --%>
    <asp:Panel ID="pnlLab" runat="server" Visible="false">
        <div class="st-unitdetails-sec-hd"><i class="bi bi-eyedropper" style="color:#15803D;font-size:1.1rem;"></i><div class="st-unitdetails-sec-title"><asp:Literal ID="litLabHd" runat="server" /></div></div>
        <div class="st-unitdetails-lab">
            <div class="st-unitdetails-lab-icon"><i class="bi bi-eyedropper"></i></div>
            <div class="st-unitdetails-lab-body"><div class="st-unitdetails-lab-title"><asp:Literal ID="litLabTitle" runat="server" /></div><div class="st-unitdetails-lab-sub"><asp:Literal ID="litLabSub" runat="server" /></div></div>
            <a href="#" class="sb-btn sb-btn-white sb-btn-sm"><i class="bi bi-play-fill"></i> <asp:Literal ID="litLabBtn" runat="server" /></a>
        </div>
    </asp:Panel>

    <%-- Unit Quiz --%>
    <asp:Panel ID="pnlQuiz" runat="server" Visible="false">
        <div class="st-unitdetails-sec-hd"><i class="bi bi-patch-question-fill" style="color:#1D4ED8;font-size:1.1rem;"></i><div class="st-unitdetails-sec-title"><asp:Literal ID="litQuizHd" runat="server" /></div></div>
        <div class="st-unitdetails-quiz">
            <div class="st-unitdetails-quiz-icon"><i class="bi bi-patch-question-fill"></i></div>
            <div class="st-unitdetails-quiz-body"><div class="st-unitdetails-quiz-title"><asp:Literal ID="litQuizTitle" runat="server" /></div><div class="st-unitdetails-quiz-sub"><asp:Literal ID="litQuizSub" runat="server" /></div></div>
            <a id="lnkQuizStart" runat="server" class="sb-btn sb-btn-white sb-btn-sm"><i class="bi bi-play-fill"></i> <asp:Literal ID="litQuizBtn" runat="server" /></a>
        </div>
        <asp:Panel ID="pnlQuizResult" runat="server" Visible="false" style="margin-top:var(--space-sm);display:flex;gap:8px;flex-wrap:wrap;">
            <a id="lnkQuizResult" runat="server" class="sb-btn sb-btn-outline-primary sb-btn-sm" style="font-size:.75rem;"><i class="bi bi-eye"></i> <asp:Literal ID="litQuizResultBtn" runat="server" /></a>
            <a id="lnkQuizReview" runat="server" class="sb-btn sb-btn-outline-primary sb-btn-sm" style="font-size:.75rem;"><i class="bi bi-search"></i> <asp:Literal ID="litQuizReviewBtn" runat="server" /></a>
        </asp:Panel>
    </asp:Panel>

    </asp:Panel>

    <script type="text/javascript">
    function openMaterialPreview(url, title) {
        document.getElementById('materialPreviewTitle').innerText = title;
        document.getElementById('materialPreviewFrame').src = url;
        document.getElementById('materialPreviewModal').style.display = 'flex';
    }
    function closeMaterialPreview() {
        document.getElementById('materialPreviewModal').style.display = 'none';
        document.getElementById('materialPreviewFrame').src = 'about:blank';
    }
    </script>

</asp:Content>

<asp:Content ID="UnitDetailsScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
</asp:Content>

