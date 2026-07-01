<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Forum.aspx.cs"
    Inherits="ScienceBuddy.Student.ForumPage" MasterPageFile="~/Site.Master"
    Title="Forum" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ── Student Forum ── */
:root{--fm-primary:#2563EB;--fm-light:#EFF6FF;--fm-dark:#1D4ED8;--fm-accent:#3B82F6;}

/* ══ PAGE HEADER ══ */
.fm-header{
    background:linear-gradient(135deg,#1D4ED8 0%,#2563EB 40%,#60A5FA 100%);
    border-radius:var(--border-radius-xl);padding:var(--space-xl) var(--space-2xl);
    color:#fff;position:relative;overflow:hidden;margin-bottom:var(--space-xl);
    box-shadow:0 8px 32px rgba(37,99,235,.25);
}
.fm-header::before{content:'💬';position:absolute;font-size:6rem;opacity:.06;
    top:-10px;right:40px;pointer-events:none;}
.fm-header-blob{position:absolute;width:200px;height:200px;border-radius:50%;
    background:rgba(255,255,255,.06);top:-60px;right:-40px;pointer-events:none;}
.fm-header-title{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;margin-bottom:6px;}
.fm-header-sub{font-size:.9375rem;opacity:.85;max-width:500px;line-height:1.5;}

/* ══ SUMMARY CARDS ══ */
.fm-stats{display:grid;grid-template-columns:repeat(3,1fr);gap:var(--space-md);margin-bottom:var(--space-xl);}
.fm-stat-card{background:var(--color-white);border-radius:var(--border-radius-lg);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);
    padding:var(--space-lg);display:flex;flex-direction:column;gap:6px;
    transition:transform .2s,box-shadow .2s;position:relative;overflow:hidden;}
.fm-stat-card::before{content:'';position:absolute;top:0;left:0;right:0;height:4px;
    border-radius:var(--border-radius-lg) var(--border-radius-lg) 0 0;}
.fm-stat-card:hover{transform:translateY(-3px);box-shadow:var(--shadow-md);}
.fm-stat-card.sc-total::before{background:linear-gradient(90deg,#2563EB,#60A5FA);}
.fm-stat-card.sc-mine::before{background:linear-gradient(90deg,#7C3AED,#A78BFA);}
.fm-stat-card.sc-replies::before{background:linear-gradient(90deg,#22C55E,#4ADE80);}
.fm-stat-icon{width:40px;height:40px;border-radius:var(--border-radius);
    display:flex;align-items:center;justify-content:center;font-size:1.25rem;margin-bottom:4px;}
.fm-stat-val{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;color:var(--color-text);}
.fm-stat-lbl{font-size:.8125rem;color:var(--color-text-secondary);font-weight:600;}

/* ══ CATEGORY TABS ══ */
.fm-category-tabs{display:flex;align-items:center;gap:var(--space-sm);margin-bottom:var(--space-xl);}
.fm-cat-tab{display:inline-flex;align-items:center;gap:6px;padding:10px 22px;
    border-radius:var(--border-radius-full);font-weight:700;font-size:.9375rem;
    background:var(--color-white);color:var(--color-text-secondary);
    border:1.5px solid var(--border-color);cursor:pointer;transition:all .2s;text-decoration:none;}
.fm-cat-tab:hover{background:var(--fm-light);color:var(--fm-primary);border-color:#BFDBFE;text-decoration:none;}
.fm-cat-tab.active{background:var(--fm-primary);color:#fff;border-color:var(--fm-primary);
    box-shadow:0 4px 12px rgba(37,99,235,.3);}
.fm-cat-tab.active:hover{background:var(--fm-dark);text-decoration:none;color:#fff;}

/* ══ CTA CARD ══ */
.fm-cta{background:linear-gradient(135deg,#EFF6FF,#DBEAFE);border-radius:var(--border-radius-xl);
    border:2px solid #BFDBFE;padding:var(--space-xl);display:flex;align-items:center;
    justify-content:space-between;gap:var(--space-lg);margin-bottom:var(--space-xl);}
.fm-cta-text{font-family:var(--font-primary);font-size:1.0625rem;font-weight:700;color:var(--color-text);}
.fm-cta-btn{display:inline-flex;align-items:center;gap:6px;padding:10px 22px;
    border-radius:var(--border-radius-full);font-weight:700;font-size:.9375rem;
    background:var(--fm-primary);color:#fff;text-decoration:none;
    transition:all .2s;border:none;box-shadow:0 4px 12px rgba(37,99,235,.3);}
.fm-cta-btn:hover{background:var(--fm-dark);transform:translateY(-2px);
    box-shadow:0 6px 20px rgba(37,99,235,.4);text-decoration:none;color:#fff;}

/* ══ FILTERS ══ */
.fm-filters{display:flex;align-items:center;gap:var(--space-sm);flex-wrap:wrap;margin-bottom:var(--space-lg);}
.fm-filters select,.fm-filters input[type="text"]{
    padding:8px 14px;border:1.5px solid var(--border-color);border-radius:var(--border-radius);
    font-size:.875rem;background:var(--color-white);min-width:160px;transition:border-color .2s;}
.fm-filters select:focus,.fm-filters input[type="text"]:focus{border-color:var(--fm-primary);outline:none;}
.fm-filter-btn{display:inline-flex;align-items:center;gap:5px;padding:8px 18px;
    border-radius:var(--border-radius);font-weight:700;font-size:.875rem;
    background:var(--fm-primary);color:#fff;border:none;cursor:pointer;transition:all .2s;}
.fm-filter-btn:hover{background:var(--fm-dark);}

/* ══ DISCUSSION LIST ══ */
.fm-list{display:flex;flex-direction:column;gap:var(--space-md);}
.fm-disc-card{background:var(--color-white);border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);
    padding:var(--space-lg);transition:transform .2s,box-shadow .2s;}
.fm-disc-card:hover{transform:translateY(-2px);box-shadow:var(--shadow-md);}
.fm-disc-top{display:flex;align-items:flex-start;gap:var(--space-md);margin-bottom:var(--space-sm);}
.fm-disc-avatar{width:42px;height:42px;border-radius:50%;background:var(--fm-light);
    color:var(--fm-primary);font-weight:800;font-size:.9375rem;
    display:flex;align-items:center;justify-content:center;flex-shrink:0;
    border:2px solid #BFDBFE;}
.fm-disc-meta{flex:1;min-width:0;}
.fm-disc-title{font-family:var(--font-primary);font-size:1.0625rem;font-weight:700;
    color:var(--color-text);line-height:1.3;margin-bottom:4px;
    white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.fm-disc-creator{font-size:.8125rem;color:var(--color-text-secondary);display:flex;align-items:center;gap:6px;}
.fm-disc-badge{display:inline-block;padding:2px 8px;border-radius:var(--border-radius-full);
    font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;}
.fm-disc-badge.public{background:#DCFCE7;color:#15803D;}
.fm-disc-badge.private{background:#FEF3C7;color:#92400E;}
.fm-disc-preview{font-size:.875rem;color:var(--color-text-secondary);line-height:1.5;
    margin-bottom:var(--space-sm);display:-webkit-box;-webkit-line-clamp:2;
    -webkit-box-orient:vertical;overflow:hidden;}
.fm-disc-tags{display:flex;flex-wrap:wrap;gap:6px;margin-bottom:var(--space-sm);}
.fm-disc-tag{background:#F0F7FF;color:var(--fm-primary);padding:3px 10px;
    border-radius:var(--border-radius-full);font-size:.75rem;font-weight:600;}
.fm-disc-footer{display:flex;align-items:center;gap:var(--space-md);flex-wrap:wrap;}
.fm-disc-stat{display:flex;align-items:center;gap:4px;font-size:.8125rem;
    color:var(--color-text-muted);font-weight:600;}
.fm-disc-stat i{font-size:.9rem;}
.fm-like-btn{display:inline-flex;align-items:center;gap:4px;padding:5px 12px;
    border-radius:var(--border-radius-full);font-size:.8125rem;font-weight:700;
    background:#F0F7FF;color:var(--fm-primary);border:1.5px solid #BFDBFE;
    cursor:pointer;transition:all .2s;text-decoration:none;}
.fm-like-btn:hover{background:#DBEAFE;border-color:var(--fm-primary);}
.fm-like-btn.liked{background:var(--fm-primary);color:#fff;border-color:var(--fm-primary);}
.fm-open-btn{display:inline-flex;align-items:center;gap:4px;padding:5px 14px;
    border-radius:var(--border-radius-full);font-size:.8125rem;font-weight:700;
    background:var(--fm-light);color:var(--fm-primary);text-decoration:none;
    border:1.5px solid #BFDBFE;transition:all .2s;}
.fm-open-btn:hover{background:var(--fm-primary);color:#fff;text-decoration:none;}

/* ══ EMPTY STATE ══ */
.fm-empty{background:var(--color-white);border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);
    padding:var(--space-2xl);text-align:center;}
.fm-empty-icon{font-size:3rem;margin-bottom:var(--space-md);}
.fm-empty-title{font-family:var(--font-primary);font-size:1.125rem;font-weight:700;
    color:var(--color-text);margin-bottom:6px;}
.fm-empty-desc{font-size:.875rem;color:var(--color-text-secondary);line-height:1.5;}

/* ══ RESPONSIVE ══ */
@media(max-width:767px){
    .fm-stats{grid-template-columns:1fr;}
    .fm-cta{flex-direction:column;align-items:flex-start;}
    .fm-filters{flex-direction:column;align-items:stretch;}
    .fm-filters select,.fm-filters input[type="text"]{min-width:100%;}
    .fm-disc-footer{flex-direction:column;align-items:flex-start;}
    .fm-category-tabs{flex-wrap:wrap;}
}
</style>
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
<div class="fm-header">
    <div class="fm-header-blob"></div>
    <div class="fm-header-title"><asp:Literal ID="litTitle" runat="server" Text="Forum" /></div>
    <div class="fm-header-sub"><asp:Literal ID="litSubtitle" runat="server" Text="Ask questions, share ideas, and learn Science together." /></div>
</div>

<%-- ── SUMMARY CARDS ── --%>
<%-- Stats hidden for cleaner UI --%>
<asp:Literal ID="litTotalDisc" runat="server" Visible="false" /><asp:Literal ID="litTotalDiscLbl" runat="server" Visible="false" />
<asp:Literal ID="litMyDisc" runat="server" Visible="false" /><asp:Literal ID="litMyDiscLbl" runat="server" Visible="false" />
<asp:Literal ID="litTotalReplies" runat="server" Visible="false" /><asp:Literal ID="litTotalRepliesLbl" runat="server" Visible="false" />

<%-- ── CATEGORY TABS ── --%>
<div class="fm-category-tabs">
    <asp:LinkButton ID="btnTabPublic" runat="server" CssClass="fm-cat-tab active" OnClick="btnTabPublic_Click">
        <asp:Literal ID="litTabPublic" runat="server" />
    </asp:LinkButton>
    <asp:LinkButton ID="btnTabPrivate" runat="server" CssClass="fm-cat-tab" OnClick="btnTabPrivate_Click">
        <asp:Literal ID="litTabPrivate" runat="server" />
    </asp:LinkButton>
    <asp:HiddenField ID="hfCategory" runat="server" Value="public" />
</div>

<%-- ── CREATE DISCUSSION CTA ── --%>
<div class="fm-cta">
    <div class="fm-cta-text"><asp:Literal ID="litCTAText" runat="server" Text="Have a Science question?" /></div>
    <a href="<%= ResolveUrl("~/Student/CreateForumPost.aspx?type=" + (hfCategory.Value == "private" ? "Private" : "Public")) %>" class="fm-cta-btn">
        <i class="bi bi-plus-circle-fill"></i> <asp:Literal ID="litCTABtn" runat="server" Text="Create Discussion" />
    </a>
</div>

<%-- ── FILTERS ── --%>
<div class="fm-filters">
    <asp:DropDownList ID="ddlTag" runat="server" CssClass="fm-filter-select" AutoPostBack="false" />
    <asp:DropDownList ID="ddlSort" runat="server" CssClass="fm-filter-select" AutoPostBack="false">
        <asp:ListItem Value="Latest" Text="Latest" />
        <asp:ListItem Value="MostLiked" Text="Most Liked" />
        <asp:ListItem Value="MostReplies" Text="Most Replies" />
    </asp:DropDownList>
    <asp:TextBox ID="txtSearch" runat="server" CssClass="fm-filter-search" placeholder="Search..." />
    <asp:Button ID="btnFilter" runat="server" Text="Filter" CssClass="fm-filter-btn" OnClick="btnFilter_Click" />
</div>

<%-- ── DISCUSSION LIST ── --%>
<asp:Panel ID="pnlList" runat="server">
    <div class="fm-list">
        <asp:Repeater ID="rptDiscussions" runat="server" OnItemCommand="rptDiscussions_ItemCommand">
            <ItemTemplate>
                <div class="fm-disc-card">
                    <div class="fm-disc-top">
                        <div class="fm-disc-avatar"><%# Eval("CreatorInitial") %></div>
                        <div class="fm-disc-meta">
                            <div class="fm-disc-title"><%# Server.HtmlEncode(Eval("Title").ToString()) %></div>
                            <div class="fm-disc-creator">
                                <span><%# Server.HtmlEncode(Eval("CreatorName").ToString()) %></span>
                                <span>•</span>
                                <span><%# Eval("Date") %></span>
                                <span class='<%# Eval("BadgeCss") %>'><%# Eval("DiscussionType") %></span>
                            </div>
                        </div>
                    </div>
                    <div class="fm-disc-preview"><%# Server.HtmlEncode(Eval("MessagePreview").ToString()) %></div>
                    <div class="fm-disc-tags">
                        <%# !string.IsNullOrEmpty(Eval("Tags").ToString()) ?
                            string.Join("", Array.ConvertAll(Eval("Tags").ToString().Split(','),
                                t => "<span class='fm-disc-tag'>" + Server.HtmlEncode(t.Trim()) + "</span>")) : "" %>
                    </div>
                    <div class="fm-disc-footer">
                        <span class="fm-disc-stat"><i class="bi bi-chat-left-text"></i> <%# Eval("ReplyCount") %> <asp:Literal runat="server" Text='<%# T("replies","balasan") %>' /></span>
                        <span class="fm-disc-stat"><i class="bi bi-heart-fill"></i> <%# Eval("LikeCount") %></span>
                        <asp:LinkButton runat="server" CommandName="Like" CommandArgument='<%# Eval("ForumId") %>'
                            CssClass='<%# Convert.ToBoolean(Eval("IsLiked")) ? "fm-like-btn liked" : "fm-like-btn" %>'>
                            <i class='<%# Convert.ToBoolean(Eval("IsLiked")) ? "bi bi-heart-fill" : "bi bi-heart" %>'></i>
                            <%# Convert.ToBoolean(Eval("IsLiked")) ? T("Liked","Disukai") : T("Like","Suka") %>
                        </asp:LinkButton>
                        <a href='<%# ResolveUrl("~/Student/ForumThread.aspx?forumId=" + Eval("ForumId")) %>' class="fm-open-btn">
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
    <div class="fm-empty">
        <div class="fm-empty-icon">💬</div>
        <div class="fm-empty-title"><asp:Literal ID="litEmptyTitle" runat="server" Text="No discussions yet." /></div>
        <div class="fm-empty-desc"><asp:Literal ID="litEmptyDesc" runat="server" Text="Be the first to ask a Science question!" /></div>
    </div>
</asp:Panel>

</asp:Content>
