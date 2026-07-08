<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Forum.aspx.cs"
    Inherits="ScienceBuddy.Student.Forum" MasterPageFile="~/Site.Master"
    Title="Forum" %>
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
    <asp:Literal ID="litPageTitle" runat="server" Text="Forum" />
</asp:Content>

<%-- ════ MAIN CONTENT ════ --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- ── PAGE HEADER ── --%>
<div class="st-forum-header">
    <div class="st-forum-header-blob"></div>
    <div class="st-forum-header-title"><asp:Literal ID="litTitle" runat="server" Text="Forum" /></div>
    <div class="st-forum-header-sub"><asp:Literal ID="litSubtitle" runat="server" Text="Ask questions, share ideas, and learn Science together." /></div>
</div>

<%-- ── SUMMARY CARDS ── --%>
<%-- Stats hidden for cleaner UI --%>
<asp:Literal ID="litTotalDisc" runat="server" Visible="false" /><asp:Literal ID="litTotalDiscLbl" runat="server" Visible="false" />
<asp:Literal ID="litMyDisc" runat="server" Visible="false" /><asp:Literal ID="litMyDiscLbl" runat="server" Visible="false" />
<asp:Literal ID="litTotalReplies" runat="server" Visible="false" /><asp:Literal ID="litTotalRepliesLbl" runat="server" Visible="false" />

<%-- ── CATEGORY TABS ── --%>
<div class="st-forum-category-tabs">
    <asp:LinkButton ID="btnTabPublic" runat="server" CssClass="st-forum-cat-tab active" OnClick="btnTabPublic_Click">
        <asp:Literal ID="litTabPublic" runat="server" />
    </asp:LinkButton>
    <asp:LinkButton ID="btnTabPrivate" runat="server" CssClass="st-forum-cat-tab" OnClick="btnTabPrivate_Click">
        <asp:Literal ID="litTabPrivate" runat="server" />
    </asp:LinkButton>
    <asp:HiddenField ID="hfCategory" runat="server" Value="public" />
</div>

<%-- ── CREATE DISCUSSION CTA ── --%>
<div class="st-forum-cta">
    <div class="st-forum-cta-text"><asp:Literal ID="litCTAText" runat="server" Text="Have a Science question?" /></div>
    <a href="<%= ResolveUrl("~/Student/CreateForumPost.aspx?type=" + (hfCategory.Value == "private" ? "Private" : "Public")) %>" class="st-forum-cta-btn">
        <i class="bi bi-plus-circle-fill"></i> <asp:Literal ID="litCTABtn" runat="server" Text="Create Discussion" />
    </a>
</div>

<%-- ── FILTERS ── --%>
<div class="st-forum-filters">
    <asp:DropDownList ID="ddlTag" runat="server" CssClass="st-forum-filter-select" AutoPostBack="false" />
    <asp:DropDownList ID="ddlSort" runat="server" CssClass="st-forum-filter-select" AutoPostBack="false">
        <asp:ListItem Value="Latest" Text="Latest" />
        <asp:ListItem Value="MostLiked" Text="Most Liked" />
        <asp:ListItem Value="MostReplies" Text="Most Replies" />
    </asp:DropDownList>
    <asp:TextBox ID="txtSearch" runat="server" CssClass="st-forum-filter-search" placeholder="Search..." />
    <asp:Button ID="btnFilter" runat="server" Text="Filter" CssClass="st-forum-filter-btn" OnClick="btnFilter_Click" />
</div>

<%-- ── DISCUSSION LIST ── --%>
<asp:Panel ID="pnlList" runat="server">
    <div class="st-forum-list">
        <asp:Repeater ID="rptDiscussions" runat="server" OnItemCommand="rptDiscussions_ItemCommand">
            <ItemTemplate>
                <div class="st-forum-disc-card">
                    <div class="st-forum-disc-top">
                        <div class="st-forum-disc-avatar"><%# Eval("CreatorInitial") %></div>
                        <div class="st-forum-disc-meta">
                            <div class="st-forum-disc-title"><%# Server.HtmlEncode(Eval("Title").ToString()) %></div>
                            <div class="st-forum-disc-creator">
                                <span><%# Server.HtmlEncode(Eval("CreatorName").ToString()) %></span>
                                <span class="st-forum-meta-sep">&bull;</span>
                                <span><%# Eval("Date") %></span>
                                <span class='<%# Eval("BadgeCss") %>'><%# Eval("DiscussionType") %></span>
                            </div>
                        </div>
                    </div>
                    <div class="st-forum-disc-preview"><%# Server.HtmlEncode(Eval("MessagePreview").ToString()) %></div>
                    <div class="st-forum-disc-tags">
                        <%# !string.IsNullOrEmpty(Eval("Tags").ToString()) ?
                            string.Join("", Array.ConvertAll(Eval("Tags").ToString().Split(','),
                                t => "<span class='st-forum-disc-tag'>" + Server.HtmlEncode(t.Trim()) + "</span>")) : "" %>
                    </div>
                    <div class="st-forum-disc-footer">
                        <span class="st-forum-disc-stat"><i class="bi bi-chat-left-text"></i> <%# Eval("ReplyCount") %> <asp:Literal runat="server" Text='<%# T("replies","balasan") %>' /></span>
                        <span class="st-forum-disc-stat"><i class="bi bi-heart-fill"></i> <%# Eval("LikeCount") %></span>
                        <asp:LinkButton runat="server" CommandName="Like" CommandArgument='<%# Eval("ForumId") %>'
                            CssClass='<%# Convert.ToBoolean(Eval("IsLiked")) ? "st-forum-like-btn liked" : "st-forum-like-btn" %>'>
                            <i class='<%# Convert.ToBoolean(Eval("IsLiked")) ? "bi bi-heart-fill" : "bi bi-heart" %>'></i>
                            <%# Convert.ToBoolean(Eval("IsLiked")) ? T("Liked","Disukai") : T("Like","Suka") %>
                        </asp:LinkButton>
                        <a href='<%# ResolveUrl("~/Student/ForumThread.aspx?forumId=" + Eval("ForumId")) %>' class="st-forum-open-btn">
                            <i class="bi bi-arrow-right-circle"></i> <asp:Literal runat="server" Text='<%# T("Open Thread","Buka Perbincangan") %>' />
                        </a>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>

<%-- ── EMPTY STATE ── --%>
<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="st-forum-empty">
        <div class="st-forum-empty-icon"><i class="bi bi-chat-dots" style="font-size:3rem;color:var(--student);"></i></div>
        <div class="st-forum-empty-title"><asp:Literal ID="litEmptyTitle" runat="server" Text="No discussions yet." /></div>
        <div class="st-forum-empty-desc"><asp:Literal ID="litEmptyDesc" runat="server" Text="Be the first to ask a Science question!" /></div>
    </div>
</asp:Panel>

</asp:Content>
