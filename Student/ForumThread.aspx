<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ForumThread.aspx.cs"
    Inherits="ScienceBuddy.Student.ForumThread" MasterPageFile="~/Site.Master"
    Title="Forum Thread" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ── Student Forum Thread ── */
:root{--ft-primary:#2563EB;--ft-light:#EFF6FF;--ft-dark:#1D4ED8;--ft-accent:#3B82F6;}

/* ══ BACK BUTTON ══ */
.ft-back{display:inline-flex;align-items:center;gap:6px;padding:8px 18px;
    border-radius:var(--border-radius-full);font-size:.875rem;font-weight:700;
    color:var(--ft-primary);background:var(--ft-light);border:1.5px solid #BFDBFE;
    text-decoration:none;transition:all .2s;margin-bottom:var(--space-lg);}
.ft-back:hover{background:var(--ft-primary);color:#fff;text-decoration:none;}

/* ══ THREAD HEADER ══ */
.ft-header{background:var(--color-white);border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);
    padding:var(--space-xl);margin-bottom:var(--space-lg);position:relative;overflow:hidden;}
.ft-header.public-thread::before{content:'';position:absolute;top:0;left:0;right:0;height:4px;
    background:linear-gradient(90deg,#2563EB,#60A5FA);border-radius:var(--border-radius-xl) var(--border-radius-xl) 0 0;}
.ft-header.private-thread::before{content:'';position:absolute;top:0;left:0;right:0;height:4px;
    background:linear-gradient(90deg,#FF6B2C,#A78BFA);border-radius:var(--border-radius-xl) var(--border-radius-xl) 0 0;}
.ft-header-title{font-family:var(--font-primary);font-size:1.5rem;font-weight:800;
    color:var(--color-text);line-height:1.3;margin-bottom:var(--space-sm);}
.ft-header-meta{display:flex;align-items:center;gap:var(--space-sm);flex-wrap:wrap;
    margin-bottom:var(--space-md);font-size:.8125rem;color:var(--color-text-secondary);}
.ft-disc-badge{display:inline-flex;align-items:center;gap:4px;padding:3px 10px;border-radius:var(--border-radius-full);
    font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;}
.ft-disc-badge.public{background:#DCFCE7;color:#15803D;}
.ft-disc-badge.private{background:#FEF3C7;color:#92400E;}
.ft-disc-badge.question{background:#DBEAFE;color:#1D4ED8;}
.ft-disc-badge.sharing{background:#E0F2FE;color:#0369A1;}
.ft-disc-badge.help{background:#FCE7F3;color:#9D174D;}
.ft-header-tags{display:flex;flex-wrap:wrap;gap:6px;margin-bottom:var(--space-md);}
.ft-tag{background:#F0F7FF;color:var(--ft-primary);padding:3px 10px;
    border-radius:var(--border-radius-full);font-size:.75rem;font-weight:600;}
.ft-header-stats{display:flex;align-items:center;gap:var(--space-lg);flex-wrap:wrap;}
.ft-stat{display:flex;align-items:center;gap:4px;font-size:.8125rem;
    color:var(--color-text-muted);font-weight:600;}
.ft-stat i{font-size:.9rem;}
.ft-like-btn{display:inline-flex;align-items:center;gap:5px;padding:6px 16px;
    border-radius:var(--border-radius-full);font-size:.8125rem;font-weight:700;
    background:#F0F7FF;color:var(--ft-primary);border:1.5px solid #BFDBFE;
    cursor:pointer;transition:all .2s;text-decoration:none;}
.ft-like-btn:hover{background:#DBEAFE;border-color:var(--ft-primary);}
.ft-like-btn.liked{background:var(--ft-primary);color:#fff;border-color:var(--ft-primary);}

/* ══ PRIVATE NOTICE ══ */
.ft-private-notice{display:flex;align-items:center;gap:var(--space-sm);padding:var(--space-md) var(--space-lg);
    background:#FEF9F0;border:1.5px solid #FDE68A;border-radius:var(--border-radius-lg);
    margin-bottom:var(--space-lg);font-size:.8125rem;color:#92400E;font-weight:600;}
.ft-private-notice i{font-size:1.1rem;color:#D97706;}

/* ══ ORIGINAL MESSAGE ══ */
.ft-message{background:var(--color-white);border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);
    padding:var(--space-xl);margin-bottom:var(--space-xl);}
.ft-message-label{font-size:.75rem;font-weight:700;color:var(--ft-primary);
    letter-spacing:.5px;text-transform:uppercase;margin-bottom:var(--space-sm);
    display:flex;align-items:center;gap:6px;}
.ft-message-body{font-size:.9375rem;color:var(--color-text);line-height:1.7;
    white-space:pre-wrap;word-wrap:break-word;}

/* ══ REPLIES SECTION ══ */
.ft-replies{margin-bottom:var(--space-xl);}
.ft-replies-title{font-family:var(--font-primary);font-size:1.0625rem;font-weight:800;
    color:var(--color-text);margin-bottom:var(--space-md);display:flex;align-items:center;gap:8px;}
.ft-reply-list{display:flex;flex-direction:column;gap:var(--space-md);}
.ft-reply-card{background:var(--color-white);border-radius:var(--border-radius-lg);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);
    padding:var(--space-lg);transition:transform .15s;}
.ft-reply-card:hover{transform:translateY(-1px);box-shadow:var(--shadow-md);}
.ft-reply-top{display:flex;align-items:center;gap:var(--space-sm);margin-bottom:var(--space-sm);}
.ft-reply-avatar{width:38px;height:38px;border-radius:50%;background:var(--ft-light);
    color:var(--ft-primary);font-weight:800;font-size:.875rem;
    display:flex;align-items:center;justify-content:center;flex-shrink:0;
    border:2px solid #BFDBFE;}
.ft-reply-info{flex:1;}
.ft-reply-name{font-size:.875rem;font-weight:700;color:var(--color-text);
    display:flex;align-items:center;gap:6px;}
.ft-reply-role{display:inline-block;padding:2px 7px;border-radius:var(--border-radius-full);
    font-size:.625rem;font-weight:700;text-transform:uppercase;letter-spacing:.3px;}
.ft-reply-role.student{background:#DBEAFE;color:#1D4ED8;}
.ft-reply-role.teacher{background:#DCFCE7;color:#15803D;}
.ft-reply-role.parent{background:#FEF3C7;color:#92400E;}
.ft-reply-date{font-size:.75rem;color:var(--color-text-muted);}
.ft-reply-body{font-size:.875rem;color:var(--color-text);line-height:1.6;
    white-space:pre-wrap;word-wrap:break-word;}

/* ══ REPLY FORM ══ */
.ft-reply-form{background:var(--color-white);border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);
    padding:var(--space-xl);}
.ft-reply-form-title{font-family:var(--font-primary);font-size:1rem;font-weight:700;
    color:var(--color-text);margin-bottom:var(--space-md);}
.ft-reply-textarea{width:100%;min-height:120px;padding:var(--space-md);
    border:1.5px solid var(--border-color);border-radius:var(--border-radius-lg);
    font-size:.9rem;line-height:1.6;resize:vertical;transition:border-color .2s;
    font-family:inherit;}
.ft-reply-textarea:focus{border-color:var(--ft-primary);outline:none;
    box-shadow:0 0 0 3px rgba(37,99,235,.1);}
.ft-reply-submit{display:inline-flex;align-items:center;gap:6px;padding:10px 24px;
    border-radius:var(--border-radius-full);font-weight:700;font-size:.9375rem;
    background:var(--ft-primary);color:#fff;border:none;cursor:pointer;
    transition:all .2s;margin-top:var(--space-md);
    box-shadow:0 4px 12px rgba(37,99,235,.3);}
.ft-reply-submit:hover{background:var(--ft-dark);transform:translateY(-2px);
    box-shadow:0 6px 20px rgba(37,99,235,.4);}

/* ══ SUCCESS / ERROR PANELS ══ */
.ft-alert{padding:var(--space-md) var(--space-lg);border-radius:var(--border-radius-lg);
    font-size:.875rem;font-weight:600;margin-top:var(--space-md);
    display:flex;align-items:center;gap:8px;}
.ft-alert-success{background:#DCFCE7;color:#15803D;border:1.5px solid #BBF7D0;}
.ft-alert-error{background:#FEF2F2;color:#DC2626;border:1.5px solid #FECACA;}

/* ══ ERROR PAGE ══ */
.ft-error{background:var(--color-white);border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);
    padding:var(--space-2xl);text-align:center;}
.ft-error-icon{font-size:3rem;margin-bottom:var(--space-md);}
.ft-error-title{font-family:var(--font-primary);font-size:1.25rem;font-weight:700;
    color:var(--color-text);margin-bottom:8px;}
.ft-error-desc{font-size:.9rem;color:var(--color-text-secondary);line-height:1.5;
    margin-bottom:var(--space-lg);}
.ft-error-btn{display:inline-flex;align-items:center;gap:6px;padding:10px 22px;
    border-radius:var(--border-radius-full);font-weight:700;font-size:.9375rem;
    background:var(--ft-primary);color:#fff;text-decoration:none;transition:all .2s;}
.ft-error-btn:hover{background:var(--ft-dark);text-decoration:none;color:#fff;}

/* ══ EMPTY REPLIES ══ */
.ft-no-replies{text-align:center;padding:var(--space-xl);color:var(--color-text-muted);
    font-size:.9rem;}

/* ══ RESPONSIVE ══ */
@media(max-width:767px){
    .ft-header-stats{flex-direction:column;align-items:flex-start;}
    .ft-reply-top{flex-wrap:wrap;}
    .ft-header-title{font-size:1.25rem;}
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
    <asp:Literal ID="litPageTitle" runat="server" Text="Forum Thread" />
</asp:Content>

<%-- ════ MAIN CONTENT ════ --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- ── ERROR PANEL ── --%>
<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="ft-error">
        <div class="ft-error-icon"><i class="bi bi-shield-lock" style="color:var(--ft-primary);"></i></div>
        <div class="ft-error-title"><asp:Literal ID="litErrorTitle" runat="server" Text="Discussion not found" /></div>
        <div class="ft-error-desc"><asp:Literal ID="litErrorDesc" runat="server" Text="This discussion does not exist or you don't have access." /></div>
        <a href="<%: ResolveUrl("~/Student/Forum.aspx") %>" class="ft-error-btn">
            <i class="bi bi-arrow-left"></i> <asp:Literal ID="litErrorBtn" runat="server" Text="Back" />
        </a>
    </div>
</asp:Panel>

<%-- ── RESTRICTED PANEL ── --%>
<asp:Panel ID="pnlRestricted" runat="server" Visible="false">
    <div class="ft-error">
        <div class="ft-error-icon"><i class="bi bi-lock-fill" style="color:#D97706;"></i></div>
        <div class="ft-error-title"><asp:Literal ID="litRestrictedTitle" runat="server" Text="Private Discussion" /></div>
        <div class="ft-error-desc"><asp:Literal ID="litRestrictedDesc" runat="server" /></div>
        <a href="<%: ResolveUrl("~/Student/Forum.aspx") %>" class="ft-error-btn">
            <i class="bi bi-arrow-left"></i> <asp:Literal ID="litRestrictedBtn" runat="server" Text="Back to Forum" />
        </a>
    </div>
</asp:Panel>

<%-- ── MAIN PANEL ── --%>
<asp:Panel ID="pnlMain" runat="server" Visible="false">

    <%-- Back Button --%>
    <a href="<%: ResolveUrl("~/Student/Forum.aspx") %>" class="ft-back">
        <i class="bi bi-arrow-left"></i> <asp:Literal ID="litBack" runat="server" Text="Back to Forum" />
    </a>

    <%-- Private Notice --%>
    <asp:Panel ID="pnlPrivateNotice" runat="server" Visible="false">
        <div class="ft-private-notice">
            <i class="bi bi-lock-fill"></i>
            <asp:Literal ID="litPrivateNotice" runat="server" />
        </div>
    </asp:Panel>

    <%-- Thread Header --%>
    <div class="ft-header" id="divHeader" runat="server">
        <div class="ft-header-title"><asp:Literal ID="litThreadTitle" runat="server" /></div>
        <div class="ft-header-meta">
            <span class="ft-disc-badge" id="spnDiscBadge" runat="server"><asp:Literal ID="litDiscType" runat="server" /></span>
            <span><i class="bi bi-person-fill"></i> <asp:Literal ID="litCreatorName" runat="server" /></span>
            <span>&#8226;</span>
            <span><i class="bi bi-clock"></i> <asp:Literal ID="litCreatorDate" runat="server" /></span>
        </div>
        <div class="ft-header-tags">
            <asp:Literal ID="litTags" runat="server" />
        </div>
        <div class="ft-header-stats">
            <span class="ft-stat"><i class="bi bi-heart-fill" style="color:#EF4444;"></i> <asp:Literal ID="litLikeCount" runat="server" Text="0" /> <asp:Literal ID="litLikesLabel" runat="server" Text="likes" /></span>
            <span class="ft-stat"><i class="bi bi-chat-left-text" style="color:var(--ft-primary);"></i> <asp:Literal ID="litReplyCount" runat="server" Text="0" /> <asp:Literal ID="litRepliesLabel" runat="server" Text="replies" /></span>
            <asp:LinkButton ID="btnLike" runat="server" CssClass="ft-like-btn" OnClick="btnLike_Click">
                <i class="bi bi-heart"></i> <asp:Literal ID="litLikeText" runat="server" Text="Like" />
            </asp:LinkButton>
        </div>
    </div>

    <%-- Original Message --%>
    <div class="ft-message">
        <div class="ft-message-label"><i class="bi bi-chat-square-text"></i> <asp:Literal ID="litOrigMsgLabel" runat="server" Text="Original Message" /></div>
        <div class="ft-message-body"><asp:Literal ID="litOrigMessage" runat="server" /></div>
    </div>

    <%-- Reply List --%>
    <div class="ft-replies">
        <div class="ft-replies-title"><i class="bi bi-chat-left-text"></i> <asp:Literal ID="litRepliesTitle" runat="server" Text="Replies" /></div>
        <div class="ft-reply-list">
            <asp:Repeater ID="rptReplies" runat="server">
                <ItemTemplate>
                    <div class="ft-reply-card">
                        <div class="ft-reply-top">
                            <div class="ft-reply-avatar"><%# Eval("SenderInitial") %></div>
                            <div class="ft-reply-info">
                                <div class="ft-reply-name">
                                    <%# Server.HtmlEncode(Eval("SenderName").ToString()) %>
                                    <span class='ft-reply-role <%# Eval("SenderRole").ToString().ToLower() %>'><%# Eval("SenderRoleLabel") %></span>
                                </div>
                                <div class="ft-reply-date"><i class="bi bi-clock"></i> <%# Eval("Date") %></div>
                            </div>
                        </div>
                        <div class="ft-reply-body"><%# Server.HtmlEncode(Eval("Message").ToString()) %></div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
            <asp:Panel ID="pnlNoReplies" runat="server" Visible="false">
                <div class="ft-no-replies">
                    <i class="bi bi-chat-square" style="font-size:1.5rem;display:block;margin-bottom:8px;"></i>
                    <asp:Literal ID="litNoReplies" runat="server" Text="No replies yet. Be the first to respond!" />
                </div>
            </asp:Panel>
        </div>
    </div>

    <%-- Reply Form --%>
    <div class="ft-reply-form">
        <div class="ft-reply-form-title"><i class="bi bi-reply"></i> <asp:Literal ID="litReplyFormTitle" runat="server" Text="Post Reply" /></div>

        <%-- Success Panel --%>
        <asp:Panel ID="pnlReplySuccess" runat="server" Visible="false">
            <div class="ft-alert ft-alert-success">
                <i class="bi bi-check-circle-fill"></i> <asp:Literal ID="litReplySuccess" runat="server" Text="Reply posted successfully!" />
            </div>
        </asp:Panel>

        <%-- Error Panel --%>
        <asp:Panel ID="pnlReplyError" runat="server" Visible="false">
            <div class="ft-alert ft-alert-error">
                <i class="bi bi-exclamation-circle-fill"></i> <asp:Literal ID="litReplyError" runat="server" Text="Please write something before posting." />
            </div>
        </asp:Panel>

        <asp:TextBox ID="txtReply" runat="server" TextMode="MultiLine" CssClass="ft-reply-textarea"
            placeholder="Write your reply..." />
        <asp:Button ID="btnReply" runat="server" CssClass="ft-reply-submit" OnClick="btnReply_Click"
            Text="Post Reply" />
    </div>

</asp:Panel>

</asp:Content>
