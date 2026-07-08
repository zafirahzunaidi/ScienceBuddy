<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LiveSessions2.aspx.cs"
    Inherits="ScienceBuddy.Student.LiveSessions" MasterPageFile="~/Site.Master"
    Title="Live Sessions" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ── Live Sessions ── */
:root{--lss-primary:#2563EB;--lss-light:#EFF6FF;--lss-dark:#1D4ED8;--lss-mid:#60A5FA;}

/* ══ PAGE HEADER ══ */
.lss-header{margin-bottom:var(--space-xl);}
.lss-title{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;
    color:var(--color-text);margin-bottom:var(--space-xs);line-height:1.2;
    display:flex;align-items:center;gap:var(--space-sm);}
.lss-title::before{content:'\f4e2';font-family:'bootstrap-icons';font-size:1.5rem;
    color:var(--lss-primary);}
.lss-subtitle{font-size:.9375rem;color:var(--color-text-secondary);line-height:1.5;}

/* ══ SUMMARY CARDS ══ */
.lss-summary{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));
    gap:var(--space-md);margin-bottom:var(--space-xl);}
.lss-summary-card{background:var(--color-white);border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);
    padding:var(--space-lg);text-align:center;position:relative;overflow:hidden;
    transition:transform .2s,box-shadow .2s;}
.lss-summary-card:hover{transform:translateY(-3px);box-shadow:var(--shadow-md);}
.lss-summary-card::before{content:'';position:absolute;top:0;left:0;right:0;height:4px;
    background:linear-gradient(90deg,var(--lss-primary),var(--lss-mid));}
.lss-summary-icon{font-size:1.75rem;color:var(--lss-primary);margin-bottom:var(--space-xs);}
.lss-summary-count{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;
    color:var(--color-text);line-height:1;}
.lss-summary-label{font-size:.8125rem;color:var(--color-text-secondary);font-weight:600;
    margin-top:var(--space-xs);}

/* ══ FILTER TABS ══ */
.lss-filters{display:flex;flex-wrap:wrap;gap:var(--space-xs);
    margin-bottom:var(--space-xl);padding:var(--space-sm) var(--space-md);
    background:var(--color-white);border-radius:var(--border-radius-lg);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);}
.lss-filter-btn{padding:8px 18px;border-radius:var(--border-radius-full);
    font-weight:700;font-size:.8125rem;border:1.5px solid var(--border-color);
    background:var(--color-white);color:var(--color-text-secondary);cursor:pointer;
    transition:all .2s;text-decoration:none;}
.lss-filter-btn:hover{border-color:var(--lss-primary);color:var(--lss-primary);
    background:var(--lss-light);}
.lss-filter-btn.active{background:var(--lss-primary);color:#fff;
    border-color:var(--lss-primary);box-shadow:0 4px 12px rgba(37,99,235,.25);}

/* ══ SESSION CARD GRID ══ */
.lss-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(320px,1fr));
    gap:var(--space-lg);}

/* ══ SESSION CARD ══ */
.lss-card{background:var(--color-white);border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);
    overflow:hidden;transition:transform .2s,box-shadow .2s;
    display:flex;flex-direction:column;position:relative;}
.lss-card::before{content:'';position:absolute;top:0;left:0;right:0;height:4px;
    background:linear-gradient(90deg,var(--lss-primary),var(--lss-mid));}
.lss-card:hover{transform:translateY(-5px);box-shadow:var(--shadow-lg);}
.lss-card-body{padding:var(--space-lg);flex:1;display:flex;flex-direction:column;}
.lss-card-title{font-family:var(--font-primary);font-size:1.0625rem;font-weight:800;
    color:var(--color-text);margin-bottom:var(--space-xs);line-height:1.3;
    display:flex;align-items:flex-start;gap:var(--space-sm);}
.lss-card-title::before{content:'\f4e2';font-family:'bootstrap-icons';font-size:1rem;
    color:var(--lss-primary);margin-top:2px;flex-shrink:0;}
.lss-card-desc{font-size:.8125rem;color:var(--color-text-secondary);
    margin-bottom:var(--space-md);line-height:1.5;}
.lss-card-meta{font-size:.8125rem;color:var(--color-text-secondary);
    margin-bottom:var(--space-sm);display:flex;flex-direction:column;gap:4px;}
.lss-card-meta span{display:flex;align-items:center;gap:6px;}
.lss-card-badges{display:flex;flex-wrap:wrap;gap:6px;margin-bottom:var(--space-md);margin-top:auto;}
.lss-badge{font-size:.6875rem;font-weight:700;padding:3px 10px;
    border-radius:var(--border-radius-full);display:inline-flex;align-items:center;gap:4px;}
.lss-badge-upcoming{background:#DBEAFE;color:#1D4ED8;}
.lss-badge-ongoing{background:#DCFCE7;color:#15803D;}
.lss-badge-completed{background:#F3F4F6;color:#6B7280;}
.lss-badge-joined{background:#DCFCE7;color:#15803D;}
.lss-badge-notjoined{background:#FEF3C7;color:#92400E;}
.lss-card-footer{padding:0 var(--space-lg) var(--space-lg);margin-top:auto;}
.lss-card-btn{display:inline-flex;align-items:center;gap:6px;padding:10px 20px;
    border-radius:var(--border-radius-full);font-weight:700;font-size:.875rem;
    text-decoration:none;background:var(--lss-primary);color:#fff;
    transition:all .2s;border:none;cursor:pointer;width:100%;justify-content:center;}
.lss-card-btn:hover{background:var(--lss-dark);transform:translateY(-2px);
    box-shadow:0 6px 20px rgba(37,99,235,.30);text-decoration:none;color:#fff;}
.lss-card-btn.disabled{background:#E5E7EB;color:#9CA3AF;cursor:not-allowed;
    pointer-events:none;}
.lss-card-btn.secondary{background:var(--lss-light);color:var(--lss-primary);
    border:1.5px solid var(--lss-primary);}
.lss-card-btn.secondary:hover{background:var(--lss-primary);color:#fff;}

/* ══ EMPTY STATE ══ */
.lss-empty{text-align:center;padding:var(--space-3xl) var(--space-xl);
    background:var(--color-white);border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);}
.lss-empty-icon{font-size:3.5rem;margin-bottom:var(--space-md);}
.lss-empty-title{font-family:var(--font-primary);font-size:1.25rem;font-weight:800;
    color:var(--color-text);margin-bottom:var(--space-sm);}
.lss-empty-desc{font-size:.9375rem;color:var(--color-text-secondary);margin-bottom:var(--space-lg);
    max-width:400px;margin-left:auto;margin-right:auto;line-height:1.5;}

/* ══ RESPONSIVE ══ */
@media(max-width:767px){
    .lss-grid{grid-template-columns:1fr;}
    .lss-summary{grid-template-columns:1fr;}
    .lss-filters{flex-direction:column;}
    .lss-title{font-size:1.375rem;}
}
@media(max-width:479px){
    .lss-summary-card{padding:var(--space-md);}
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
        <a href="<%: ResolveUrl("~/Student/LiveSessions.aspx") %>" class="sb-sidebar-item active">
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

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <asp:Literal ID="litPageTitle" runat="server" Text="Live Sessions" />
</asp:Content>

<%-- ════ MAIN CONTENT ════ --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- ── PAGE HEADER ── --%>
<div class="lss-header">
    <div class="lss-title"><asp:Literal ID="litTitle" runat="server" Text="Live Sessions" /></div>
    <div class="lss-subtitle"><asp:Literal ID="litSubtitle" runat="server" Text="Join teacher-led learning sessions and ask questions in real time." /></div>
</div>

<%-- Stats (hidden - kept for code-behind compatibility) --%>
<asp:Literal ID="litUpcoming" runat="server" Visible="false" /><asp:Literal ID="litUpcomingLbl" runat="server" Visible="false" />
<asp:Literal ID="litJoined" runat="server" Visible="false" /><asp:Literal ID="litJoinedLbl" runat="server" Visible="false" />
<asp:Literal ID="litCompleted" runat="server" Visible="false" /><asp:Literal ID="litCompletedLbl" runat="server" Visible="false" />

<%-- ── FILTER TABS ── --%>
<div class="lss-filters">
    <asp:LinkButton ID="btnFilterAll" runat="server" CssClass="lss-filter-btn active" OnClick="btnFilterAll_Click" Text="All" />
    <asp:LinkButton ID="btnFilterUpcoming" runat="server" CssClass="lss-filter-btn" OnClick="btnFilterUpcoming_Click" Text="Upcoming" />
    <asp:LinkButton ID="btnFilterOngoing" runat="server" CssClass="lss-filter-btn" OnClick="btnFilterOngoing_Click" Text="Ongoing" />
    <asp:LinkButton ID="btnFilterCompleted" runat="server" CssClass="lss-filter-btn" OnClick="btnFilterCompleted_Click" Text="Completed" />
    <asp:HiddenField ID="hfFilter" runat="server" Value="all" />
</div>

<%-- ── SESSION CARD GRID ── --%>
<asp:Panel ID="pnlGrid" runat="server">
    <div class="lss-grid">
        <asp:Repeater ID="rptSessions" runat="server" OnItemCommand="rptSessions_ItemCommand">
            <ItemTemplate>
                <div class="lss-card">
                    <div class="lss-card-body">
                        <div class="lss-card-title"><%# Eval("Title") %></div>
                        <div class="lss-card-desc"><%# Eval("Description") %></div>
                        <div class="lss-card-meta">
                            <span><i class="bi bi-person-workspace"></i> <%# Eval("TeacherName") %></span>
                            <span><i class="bi bi-layers"></i> <%# Eval("Unit") %></span>
                            <span><i class="bi bi-bookmark"></i> <%# Eval("Subtopic") %></span>
                            <span><i class="bi bi-calendar3"></i> <%# Eval("Date") %></span>
                            <span><i class="bi bi-clock"></i> <%# Eval("Time") %></span>
                        </div>
                        <div class="lss-card-badges">
                            <span class='lss-badge <%# Eval("StatusBadgeClass") %>'><%# Eval("Status") %></span>
                            <span class='lss-badge <%# (bool)Eval("HasJoined") ? "lss-badge-joined" : "lss-badge-notjoined" %>'><%# (bool)Eval("HasJoined") ? Eval("JoinedLabel") : Eval("NotJoinedLabel") %></span>
                        </div>
                    </div>
                    <div class="lss-card-footer">
                        <%# !(bool)Eval("HasLink") ? "<span class='lss-card-btn disabled'><i class=\"bi bi-link-45deg\"></i> " + Eval("NoLinkText") + "</span>" :
                            Eval("Status").ToString() == Eval("CompletedLabel").ToString() ? "<a href='#' class='lss-card-btn secondary'><i class=\"bi bi-eye\"></i> " + Eval("ViewDetailsText") + "</a>" :
                            "" %>
                        <asp:LinkButton runat="server" CommandName="Join" CommandArgument='<%# Eval("SessionId") %>'
                            CssClass="lss-card-btn"
                            Visible='<%# (bool)Eval("HasLink") && Eval("Status").ToString() != Eval("CompletedLabel").ToString() %>'>
                            <i class="bi bi-box-arrow-up-right"></i> <%# Eval("JoinBtnText") %>
                        </asp:LinkButton>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>

<%-- ── EMPTY STATE ── --%>
<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="lss-empty">
        <div class="lss-empty-icon">📹</div>
        <div class="lss-empty-title"><asp:Literal ID="litEmptyTitle" runat="server" Text="No live sessions available" /></div>
        <div class="lss-empty-desc"><asp:Literal ID="litEmptyDesc" runat="server" Text="No live sessions are available yet." /></div>
        <a href="<%: ResolveUrl("~/Student/Dashboard.aspx") %>" class="lss-card-btn" style="display:inline-flex;width:auto;">
            <i class="bi bi-house"></i> <asp:Literal ID="litEmptyBtn" runat="server" Text="Back to Dashboard" />
        </a>
    </div>
</asp:Panel>

</asp:Content>
