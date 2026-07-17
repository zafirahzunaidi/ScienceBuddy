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

    <%-- Thread Header with Avatar --%>
    <div class="st-forumthread-header" id="divHeader" runat="server">
        <div class="st-forumthread-header-top">
            <div class="st-forumthread-header-avatar"><asp:Literal ID="litCreatorInitial" runat="server" /></div>
            <div class="st-forumthread-header-info">
                <div class="st-forumthread-header-name">
                    <asp:Literal ID="litCreatorName" runat="server" />
                    <span class="st-forumthread-disc-badge" id="spnDiscBadge" runat="server"><asp:Literal ID="litDiscType" runat="server" /></span>
                </div>
                <div class="st-forumthread-header-date"><i class="bi bi-clock"></i> <asp:Literal ID="litCreatorDate" runat="server" /></div>
            </div>
        </div>
        <div class="st-forumthread-header-title"><asp:Literal ID="litThreadTitle" runat="server" /></div>
        <div class="st-forumthread-header-tags">
            <asp:Literal ID="litTags" runat="server" />
        </div>
    </div>

    <%-- Original Message --%>
    <div class="st-forumthread-message">
        <asp:Literal ID="litOrigMsgLabel" runat="server" Visible="false" />
        <div class="st-forumthread-message-body"><asp:Literal ID="litOrigMessage" runat="server" /></div>
    </div>

    <%-- Stats & Like --%>
    <div class="st-forumthread-header-stats">
        <span class="st-forumthread-stat"><i class="bi bi-chat-left-text"></i> <asp:Literal ID="litReplyCount" runat="server" Text="0" /> <asp:Literal ID="litRepliesLabel" runat="server" Text="replies" /></span>
        <span class="st-forumthread-stat"><i class="bi bi-heart"></i> <asp:Literal ID="litLikeCount" runat="server" Text="0" /> <asp:Literal ID="litLikesLabel" runat="server" Text="Like" /></span>
        <asp:LinkButton ID="btnLike" runat="server" CssClass="st-forumthread-like-btn" OnClick="btnLike_Click" />
        <asp:Literal ID="litLikeText" runat="server" Visible="false" />
        <asp:Panel ID="pnlOwnerActions" runat="server" Visible="false" CssClass="st-forumthread-owner-actions">
            <a id="lnkEditPost" runat="server" class="st-forum-action-btn st-forum-action-edit" title="Edit"><i class="bi bi-pencil-square"></i></a>
            <asp:LinkButton ID="btnDeletePost" runat="server" CssClass="st-forum-action-btn st-forum-action-delete"
                OnClick="btnDeletePost_Click" OnClientClick="return confirm('Are you sure you want to delete this forum post?');"
                ToolTip="Delete"><i class="bi bi-trash"></i></asp:LinkButton>
        </asp:Panel>
    </div>

    <%-- Reply List (Comments) --%>
    <div class="st-forumthread-replies">
        <div class="st-forumthread-replies-title"><asp:Literal ID="litRepliesTitle" runat="server" Text="Comments" /> <span class="st-forumthread-replies-count"><asp:Literal ID="litReplyCountFooter" runat="server" Text="0" /></span></div>
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
                    <asp:Literal ID="litNoReplies" runat="server" Text="No replies yet." />
                </div>
            </asp:Panel>
        </div>
    </div>

    <%-- Reply Form --%>
    <div class="st-forumthread-reply-form">
        <asp:Literal ID="litReplyFormTitle" runat="server" Visible="false" />
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
        <div class="st-forumthread-reply-actions">
            <asp:Button ID="btnReply" runat="server" CssClass="st-forumthread-reply-submit" OnClick="btnReply_Click"
                Text="Post" />
        </div>
    </div>

</asp:Panel>

</asp:Content>
