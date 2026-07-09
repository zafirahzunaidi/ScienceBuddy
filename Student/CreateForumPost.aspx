<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CreateForumPost.aspx.cs"
    Inherits="ScienceBuddy.Student.CreateForumPost1" MasterPageFile="~/Site.Master"
    Title="Create Discussion" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Student.css") %>" rel="stylesheet" />
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
        <a href="<%: ResolveUrl("~/Student/Forum.aspx") %>" class="sb-sidebar-item active">
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

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <asp:Literal ID="litPageTitle" runat="server" Text="Create Discussion" />
</asp:Content>

<%-- ════ MAIN CONTENT ════ --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- ── PAGE HEADER ── --%>
<div class="st-createpost-header" id="divHeader" runat="server">
    <div class="st-createpost-header-blob"></div>
    <div class="st-createpost-header-icon" id="divHeaderIcon" runat="server"><i class="bi bi-chat-dots-fill"></i></div>
    <div class="st-createpost-header-title"><asp:Literal ID="litTitle" runat="server" Text="Create Discussion" /></div>
    <div class="st-createpost-header-sub"><asp:Literal ID="litSubtitle" runat="server" Text="Ask a question or start a Science discussion." /></div>
</div>

<%-- ── PRIVATE INFO BANNER ── --%>
<asp:Panel ID="pnlPrivateInfo" runat="server" Visible="false">
    <div class="st-createpost-private-info">
        <i class="bi bi-lock-fill"></i>
        <div class="st-createpost-private-info-text">
            <strong><asp:Literal ID="litPrivateInfoTitle" runat="server" /></strong>
            <asp:Literal ID="litPrivateInfoDesc" runat="server" />
        </div>
    </div>
</asp:Panel>

<%-- ── NO PARENT WARNING ── --%>
<asp:Panel ID="pnlNoParent" runat="server" Visible="false">
    <div class="st-createpost-no-parent">
        <i class="bi bi-exclamation-triangle-fill"></i>
        <div class="st-createpost-no-parent-text">
            <asp:Literal ID="litNoParent" runat="server" />
        </div>
    </div>
</asp:Panel>

<%-- ── FORM CARD ── --%>
<div class="st-createpost-form">

    <%-- Error Panel --%>
    <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="st-createpost-error">
        <i class="bi bi-exclamation-circle-fill"></i>
        <asp:Literal ID="litError" runat="server" />
    </asp:Panel>

    <%-- Discussion Title --%>
    <div class="st-createpost-form-group">
        <label class="st-createpost-form-label"><asp:Literal ID="litTitleLbl" runat="server" Text="Discussion Title" /> <span class="required">*</span></label>
        <asp:TextBox ID="txtTitle" runat="server" CssClass="st-createpost-form-input" MaxLength="200"
            placeholder="Enter your discussion title..." />
    </div>

    <%-- Discussion Type (Public mode only) --%>
    <asp:Panel ID="pnlTypeDropdown" runat="server">
        <div class="st-createpost-form-group">
            <label class="st-createpost-form-label"><asp:Literal ID="litTypeLbl" runat="server" Text="Discussion Type" /></label>
            <asp:DropDownList ID="ddlType" runat="server" CssClass="st-createpost-form-input st-createpost-form-select">
            </asp:DropDownList>
            <div class="st-createpost-form-hint"><asp:Literal ID="litTypeHint" runat="server" /></div>
        </div>
    </asp:Panel>

    <%-- Private Type Locked Badge --%>
    <asp:Panel ID="pnlTypeLocked" runat="server" Visible="false">
        <div class="st-createpost-form-group">
            <label class="st-createpost-form-label"><asp:Literal ID="litTypeLockedLbl" runat="server" Text="Discussion Type" /></label>
            <div class="st-createpost-private-locked">
                <i class="bi bi-lock-fill"></i> <asp:Literal ID="litTypeLockedVal" runat="server" Text="Private (Student-Parent)" />
            </div>
        </div>
    </asp:Panel>

    <%-- Tag (Optional) --%>
    <div class="st-createpost-form-group">
        <label class="st-createpost-form-label"><asp:Literal ID="litTagLbl" runat="server" Text="Tag (Optional)" /></label>
        <asp:DropDownList ID="ddlTag" runat="server" CssClass="st-createpost-form-input st-createpost-form-select">
        </asp:DropDownList>
    </div>

    <%-- Message --%>
    <div class="st-createpost-form-group">
        <label class="st-createpost-form-label"><asp:Literal ID="litMsgLbl" runat="server" Text="Your Message" /> <span class="required">*</span></label>
        <asp:TextBox ID="txtMessage" runat="server" CssClass="st-createpost-form-input st-createpost-form-textarea"
            TextMode="MultiLine" placeholder="Write your question or message..." />
    </div>

    <%-- Buttons --%>
    <div class="st-createpost-btn-row">
        <asp:LinkButton ID="btnSubmit" runat="server" CssClass="st-createpost-btn-submit" OnClick="btnSubmit_Click">
            <i class="bi bi-send-fill"></i> <asp:Literal ID="litSubmitBtn" runat="server" Text="Create Discussion" />
        </asp:LinkButton>
        <a href="<%: ResolveUrl("~/Student/Forum.aspx") %>" class="st-createpost-btn-cancel">
            <i class="bi bi-x-lg"></i> <asp:Literal ID="litCancelBtn" runat="server" Text="Cancel" />
        </a>
    </div>
</div>

</asp:Content>
