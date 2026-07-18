<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="LiveSessions.aspx.cs" Inherits="ScienceBuddy.Student.LiveSessions1" %>
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
        <a href="<%: ResolveUrl("~/Student/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label">Dashboard</span></a>
        <a href="<%: ResolveUrl("~/Student/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span></a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Learn</div>
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label">My Learning</span></a>
        <a href="<%: ResolveUrl("~/Student/PracticeLibrary.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label">Practice Library</span></a>
        <a href="<%: ResolveUrl("~/Student/QuizHistory.aspx") %>" class="sb-sidebar-item"><i class="bi bi-clock-history item-icon"></i><span class="item-label">Quiz History</span></a>
        <a href="<%: ResolveUrl("~/Student/VirtualLabs.aspx") %>" class="sb-sidebar-item"><i class="bi bi-eyedropper item-icon"></i><span class="item-label">Virtual Labs</span></a>
        <a href="<%: ResolveUrl("~/Student/LiveSessions.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-camera-video item-icon"></i><span class="item-label">Live Sessions</span></a>
        <a href="<%: ResolveUrl("~/Student/AIStudyCompanion.aspx") %>" class="sb-sidebar-item"><i class="bi bi-robot item-icon"></i><span class="item-label">AI Study Companion</span></a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Communication</div>
        <a href="<%: ResolveUrl("~/Student/Messages.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label">Messages</span></a>
        <a href="<%: ResolveUrl("~/Student/Forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-people item-icon"></i><span class="item-label">Forum</span></a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Progress</div>
        <a href="<%: ResolveUrl("~/Student/ProgressRewards.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bar-chart-line item-icon"></i><span class="item-label">Progress &amp; Rewards</span></a>
        <a href="<%: ResolveUrl("~/Student/MyRanking.aspx") %>" class="sb-sidebar-item"><i class="bi bi-trophy item-icon"></i><span class="item-label">My Ranking</span></a>
        <a href="<%: ResolveUrl("~/Student/RevisionPlan.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-calendar-check item-icon"></i><span class="item-label">Revision Plan</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Student/MyProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a>
    </div>
</asp:Content>

<asp:Content ID="StudentSidebarFooter" ContentPlaceHolderID="SidebarFooter" runat="server">
</asp:Content>

<asp:Content ID="LiveSessionsPageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <asp:Literal ID="litPageTitle" runat="server" Text="Live Sessions" />
</asp:Content>

<asp:Content ID="StudentUserDropdownMenu" ContentPlaceHolderID="UserDropdownMenu" runat="server">
</asp:Content>

<asp:Content ID="LiveSessionsBreadcrumb" ContentPlaceHolderID="BreadcrumbContent" runat="server">
</asp:Content>

<%-- Live Main Content --%>
<asp:Content ID="LiveSessionsMainContent" ContentPlaceHolderID="MainContentSidebar" runat="server">

<div class="st-livesessions-header">
    <div class="st-livesessions-title"><i class="bi bi-camera-video-fill" style="color:#2563EB;"></i> <asp:Literal ID="litTitle" runat="server" Text="Live Sessions" /></div>
    <div class="st-livesessions-subtitle"><asp:Literal ID="litSubtitle" runat="server" Text="Join teacher-led learning sessions and ask questions in real time." /></div>
</div>

<%-- Hidden stats for code-behind --%>
<asp:Literal ID="litUpcoming" runat="server" Visible="false" /><asp:Literal ID="litUpcomingLbl" runat="server" Visible="false" />
<asp:Literal ID="litJoined" runat="server" Visible="false" /><asp:Literal ID="litJoinedLbl" runat="server" Visible="false" />
<asp:Literal ID="litCompleted" runat="server" Visible="false" /><asp:Literal ID="litCompletedLbl" runat="server" Visible="false" />

<%-- Filter Tabs --%>
<div class="st-livesessions-filters">
    <asp:LinkButton ID="btnFilterAll" runat="server" CssClass="st-livesessions-filter-btn active" OnClick="btnFilterAll_Click" Text="All" />
    <asp:LinkButton ID="btnFilterUpcoming" runat="server" CssClass="st-livesessions-filter-btn" OnClick="btnFilterUpcoming_Click" Text="Upcoming" />
    <asp:LinkButton ID="btnFilterOngoing" runat="server" CssClass="st-livesessions-filter-btn" OnClick="btnFilterOngoing_Click" Text="Ongoing" />
    <asp:LinkButton ID="btnFilterCompleted" runat="server" CssClass="st-livesessions-filter-btn" OnClick="btnFilterCompleted_Click" Text="Completed" />
    <asp:HiddenField ID="hfFilter" runat="server" Value="all" />
</div>

<%-- Session Card Grid --%>
<asp:Panel ID="pnlGrid" runat="server">
    <div class="st-livesessions-grid">
        <asp:Repeater ID="rptSessions" runat="server" OnItemCommand="rptSessions_ItemCommand">
            <ItemTemplate>
                <div class="st-livesessions-card">
                    <div class="st-livesessions-card-body">
                        <div class="st-livesessions-card-title"><%# Eval("Title") %></div>
                        <div class="st-livesessions-card-desc"><%# Eval("Description") %></div>
                        <div class="st-livesessions-card-meta">
                            <span><i class="bi bi-person-workspace"></i> <%# Eval("TeacherName") %></span>
                            <span><i class="bi bi-layers"></i> <%# Eval("Unit") %></span>
                            <span><i class="bi bi-bookmark"></i> <%# Eval("Subtopic") %></span>
                            <span><i class="bi bi-calendar3"></i> <%# Eval("Date") %></span>
                            <span><i class="bi bi-clock"></i> <%# Eval("Time") %></span>
                        </div>
                        <div class="st-livesessions-card-badges">
                            <span class='st-livesessions-badge <%# Eval("StatusBadgeClass") %>'><%# Eval("Status") %></span>
                            <span class='st-livesessions-badge <%# (bool)Eval("HasJoined") ? "st-livesessions-badge-joined" : "st-livesessions-badge-notjoined" %>'><%# (bool)Eval("HasJoined") ? Eval("JoinedLabel") : Eval("NotJoinedLabel") %></span>
                        </div>
                    </div>
                    <div class="st-livesessions-card-footer">
                        <%# !(bool)Eval("HasLink") ? "<span class='st-livesessions-card-btn disabled'><i class=\"bi bi-link-45deg\"></i> " + Eval("NoLinkText") + "</span>" :
                            Eval("Status").ToString() == Eval("CompletedLabel").ToString() ? "" :
                            "" %>
                        <asp:LinkButton runat="server" CommandName="Join" CommandArgument='<%# Eval("SessionId") %>'
                            CssClass="st-livesessions-card-btn"
                            Visible='<%# (bool)Eval("HasLink") && Eval("Status").ToString() != Eval("CompletedLabel").ToString() %>'>
                            <i class="bi bi-box-arrow-up-right"></i> <%# Eval("JoinBtnText") %>
                        </asp:LinkButton>
                        <asp:LinkButton runat="server" CommandName="Reminder" CommandArgument='<%# Eval("SessionId") %>'
                            CssClass='<%# (bool)Eval("HasJoined") ? "st-livesessions-card-btn secondary disabled" : "st-livesessions-card-btn st-livesessions-reminder-btn" %>'
                            Visible='<%# Eval("Status").ToString() == Eval("UpcomingLabel").ToString() %>'
                            Enabled='<%# !(bool)Eval("HasJoined") %>'>
                            <i class='bi <%# (bool)Eval("HasJoined") ? "bi-check-circle-fill" : "bi-bell-fill" %>'></i> <%# (bool)Eval("HasJoined") ? Eval("ReminderSentLabel") : Eval("GetReminderLabel") %>
                        </asp:LinkButton>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>

<%-- Embedded Live Call --%>
<asp:Panel ID="pnlJoinedRoom" runat="server" Visible="false">
    <div class="sb-flex-between mb-md">
        <h3><asp:Literal ID="litRoomTitle" runat="server" /></h3>
        <asp:Button ID="btnLeaveRoom" runat="server" Text="Leave Session"
            CssClass="sb-btn sb-btn-ghost" OnClick="btnLeaveRoom_Click" />
    </div>
    <div id="jitsi-container" style="width:100%; height:600px; border-radius:12px; overflow:hidden;"></div>

    <asp:HiddenField ID="hidRoomName" runat="server" />
    <asp:HiddenField ID="hidDisplayName" runat="server" />
</asp:Panel>

<%-- Empty State --%>
<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="st-livesessions-empty">
        <div class="st-livesessions-empty-icon"><i class="bi bi-camera-video"></i></div>
        <div class="st-livesessions-empty-title"><asp:Literal ID="litEmptyTitle" runat="server" Text="No live sessions available" /></div>
        <div class="st-livesessions-empty-desc"><asp:Literal ID="litEmptyDesc" runat="server" Text="No live sessions are available yet." /></div>
        <a href="<%: ResolveUrl("~/Student/Dashboard.aspx") %>" class="st-livesessions-card-btn" style="display:inline-flex;width:auto;">
            <i class="bi bi-house"></i> <asp:Literal ID="litEmptyBtn" runat="server" Text="Back to Dashboard" />
        </a>
    </div>
</asp:Panel>

</asp:Content>

<asp:Content ID="LiveSessionsScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script src="https://meet.jit.si/external_api.js"></script>
    <script>
    document.addEventListener('DOMContentLoaded', function () {
        var container = document.getElementById('jitsi-container');
        if (!container) return;

        var roomName = document.getElementById('<%= hidRoomName.ClientID %>').value;
        var displayName = document.getElementById('<%= hidDisplayName.ClientID %>').value;

        var api = new JitsiMeetExternalAPI("meet.jit.si", {
            roomName: roomName,
            width: "100%",
            height: 600,
            parentNode: container,
            userInfo: { displayName: displayName }
        });
    });
    </script>
</asp:Content>