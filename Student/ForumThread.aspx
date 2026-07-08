<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ForumThread.aspx.cs"
    Inherits="ScienceBuddy.Student.ForumThread1" MasterPageFile="~/Site.Master"
    Title="Forum Thread" %>
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
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Student/MyProfile.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span>
        </a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <asp:Literal ID="litPageTitle" runat="server" Text="Forum Thread" />
</asp:Content>

<%-- ════ MAIN CONTENT ════ --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- ── ERROR PANEL ── --%>
<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="st-forumthread-error">
        <div class="st-forumthread-error-icon"><i class="bi bi-shield-lock" style="color:var(--ft-primary);"></i></div>
        <div class="st-forumthread-error-title"><asp:Literal ID="litErrorTitle" runat="server" Text="Discussion not found" /></div>
        <div class="st-forumthread-error-desc"><asp:Literal ID="litErrorDesc" runat="server" Text="This discussion does not exist or you don't have access." /></div>
        <a href="<%: ResolveUrl("~/Student/Forum.aspx") %>" class="st-forumthread-error-btn">
            <i class="bi bi-arrow-left"></i> <asp:Literal ID="litErrorBtn" runat="server" Text="Back" />
        </a>
    </div>
</asp:Panel>

<%-- ── RESTRICTED PANEL ── --%>
<asp:Panel ID="pnlRestricted" runat="server" Visible="false">
    <div class="st-forumthread-error">
        <div class="st-forumthread-error-icon"><i class="bi bi-lock-fill" style="color:#D97706;"></i></div>
        <div class="st-forumthread-error-title"><asp:Literal ID="litRestrictedTitle" runat="server" Text="Private Discussion" /></div>
        <div class="st-forumthread-error-desc"><asp:Literal ID="litRestrictedDesc" runat="server" /></div>
        <a href="<%: ResolveUrl("~/Student/Forum.aspx") %>" class="st-forumthread-error-btn">
            <i class="bi bi-arrow-left"></i> <asp:Literal ID="litRestrictedBtn" runat="server" Text="Back to Forum" />
        </a>
    </div>
</asp:Panel>

<%-- ── MAIN PANEL ── --%>
<asp:Panel ID="pnlMain" runat="server" Visible="false">

    <%-- Back Button --%>
    <a href="<%: ResolveUrl("~/Student/Forum.aspx") %>" class="st-forumthread-back">
        <i class="bi bi-arrow-left"></i> <asp:Literal ID="litBack" runat="server" Text="Back to Forum" />
    </a>

    <%-- Private Notice --%>
    <asp:Panel ID="pnlPrivateNotice" runat="server" Visible="false">
        <div class="st-forumthread-private-notice">
            <i class="bi bi-lock-fill"></i>
            <asp:Literal ID="litPrivateNotice" runat="server" />
        </div>
    </asp:Panel>

    <%-- Thread Header --%>
    <div class="st-forumthread-header" id="divHeader" runat="server">
        <div class="st-forumthread-header-title"><asp:Literal ID="litThreadTitle" runat="server" /></div>
        <div class="st-forumthread-header-meta">
            <span class="st-forumthread-disc-badge" id="spnDiscBadge" runat="server"><asp:Literal ID="litDiscType" runat="server" /></span>
            <span><i class="bi bi-person-fill"></i> <asp:Literal ID="litCreatorName" runat="server" /></span>
            <span>&#8226;</span>
            <span><i class="bi bi-clock"></i> <asp:Literal ID="litCreatorDate" runat="server" /></span>
        </div>
        <div class="st-forumthread-header-tags">
            <asp:Literal ID="litTags" runat="server" />
        </div>
        <div class="st-forumthread-header-stats">
            <span class="st-forumthread-stat"><i class="bi bi-heart-fill" style="color:#EF4444;"></i> <asp:Literal ID="litLikeCount" runat="server" Text="0" /> <asp:Literal ID="litLikesLabel" runat="server" Text="likes" /></span>
            <span class="st-forumthread-stat"><i class="bi bi-chat-left-text" style="color:var(--ft-primary);"></i> <asp:Literal ID="litReplyCount" runat="server" Text="0" /> <asp:Literal ID="litRepliesLabel" runat="server" Text="replies" /></span>
            <asp:LinkButton ID="btnLike" runat="server" CssClass="st-forumthread-like-btn" OnClick="btnLike_Click">
                <i class="bi bi-heart"></i> <asp:Literal ID="litLikeText" runat="server" Text="Like" />
            </asp:LinkButton>
        </div>
    </div>

    <%-- Original Message --%>
    <div class="st-forumthread-message">
        <div class="st-forumthread-message-label"><i class="bi bi-chat-square-text"></i> <asp:Literal ID="litOrigMsgLabel" runat="server" Text="Original Message" /></div>
        <div class="st-forumthread-message-body"><asp:Literal ID="litOrigMessage" runat="server" /></div>
    </div>

    <%-- Reply List --%>
    <div class="st-forumthread-replies">
        <div class="st-forumthread-replies-title"><i class="bi bi-chat-left-text"></i> <asp:Literal ID="litRepliesTitle" runat="server" Text="Replies" /></div>
        <div class="st-forumthread-reply-list">
            <asp:Repeater ID="rptReplies" runat="server">
                <ItemTemplate>
                    <div class="st-forumthread-reply-card">
                        <div class="st-forumthread-reply-top">
                            <div class="st-forumthread-reply-avatar"><%# Eval("SenderInitial") %></div>
                            <div class="st-forumthread-reply-info">
                                <div class="st-forumthread-reply-name">
                                    <%# Server.HtmlEncode(Eval("SenderName").ToString()) %>
                                    <span class='st-forumthread-reply-role <%# Eval("SenderRole").ToString().ToLower() %>'><%# Eval("SenderRoleLabel") %></span>
                                </div>
                                <div class="st-forumthread-reply-date"><i class="bi bi-clock"></i> <%# Eval("Date") %></div>
                            </div>
                        </div>
                        <div class="st-forumthread-reply-body"><%# Server.HtmlEncode(Eval("Message").ToString()) %></div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
            <asp:Panel ID="pnlNoReplies" runat="server" Visible="false">
                <div class="st-forumthread-no-replies">
                    <i class="bi bi-chat-square" style="font-size:1.5rem;display:block;margin-bottom:8px;"></i>
                    <asp:Literal ID="litNoReplies" runat="server" Text="No replies yet. Be the first to respond!" />
                </div>
            </asp:Panel>
        </div>
    </div>

    <%-- Reply Form --%>
    <div class="st-forumthread-reply-form">
        <div class="st-forumthread-reply-form-title"><i class="bi bi-reply"></i> <asp:Literal ID="litReplyFormTitle" runat="server" Text="Post Reply" /></div>

        <%-- Success Panel --%>
        <asp:Panel ID="pnlReplySuccess" runat="server" Visible="false">
            <div class="st-forumthread-alert st-forumthread-alert-success">
                <i class="bi bi-check-circle-fill"></i> <asp:Literal ID="litReplySuccess" runat="server" Text="Reply posted successfully!" />
            </div>
        </asp:Panel>

        <%-- Error Panel --%>
        <asp:Panel ID="pnlReplyError" runat="server" Visible="false">
            <div class="st-forumthread-alert st-forumthread-alert-error">
                <i class="bi bi-exclamation-circle-fill"></i> <asp:Literal ID="litReplyError" runat="server" Text="Please write something before posting." />
            </div>
        </asp:Panel>

        <asp:TextBox ID="txtReply" runat="server" TextMode="MultiLine" CssClass="st-forumthread-reply-textarea"
            placeholder="Write your reply..." />
        <asp:Button ID="btnReply" runat="server" CssClass="st-forumthread-reply-submit" OnClick="btnReply_Click"
            Text="Post Reply" />
    </div>

</asp:Panel>

</asp:Content>
