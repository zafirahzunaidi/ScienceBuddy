<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MyLearning.aspx.cs"
    Inherits="ScienceBuddy.Student.MyLearning" MasterPageFile="~/Site.Master"
    Title="My Learning" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--student:#FF6B2C;--student-light:#FFF0E8;--student-dark:#E85B1D;}
.ml-header{margin-bottom:var(--space-xl);}
.ml-title{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;color:var(--color-text);}
.ml-subtitle{font-size:.9375rem;color:var(--color-text-secondary);margin-top:4px;}
.ml-levels{display:grid;grid-template-columns:repeat(3,1fr);gap:var(--space-md);margin-bottom:var(--space-xl);}
.ml-level-card{background:var(--color-white);border-radius:var(--border-radius-xl);
    border:2px solid var(--border-color);box-shadow:var(--shadow-sm);padding:var(--space-xl);
    display:flex;flex-direction:column;gap:var(--space-sm);position:relative;
    transition:transform .2s,box-shadow .2s;overflow:hidden;}
.ml-level-card:hover{transform:translateY(-3px);box-shadow:var(--shadow-md);}
.ml-level-card.current{border-color:var(--student);box-shadow:0 4px 20px rgba(255,107,44,.18);}
.ml-level-card.current::before{content:'';position:absolute;top:0;left:0;right:0;
    height:4px;background:linear-gradient(90deg,var(--student),var(--color-yellow));}
.ml-level-card.locked{opacity:.6;pointer-events:none;background:#FAFBFD;}
.ml-level-card.locked::after{content:'';position:absolute;inset:0;
    background:rgba(255,255,255,.3);pointer-events:none;}
.ml-level-icon{width:52px;height:52px;border-radius:var(--border-radius);
    display:flex;align-items:center;justify-content:center;font-size:1.5rem;}
.ml-level-name{font-family:var(--font-primary);font-size:1.125rem;font-weight:800;color:var(--color-text);}
.ml-level-desc{font-size:.8125rem;color:var(--color-text-secondary);line-height:1.5;}
.ml-level-badge{display:inline-flex;align-items:center;gap:4px;padding:3px 10px;
    border-radius:var(--border-radius-full);font-size:.75rem;font-weight:700;width:fit-content;}
.ml-badge-current{background:var(--student-light);color:var(--student);}
.ml-badge-unlocked{background:#DCFCE7;color:#15803D;}
.ml-badge-locked{background:#F1F5F9;color:#64748B;}
.ml-section-hd{display:flex;align-items:center;justify-content:space-between;
    margin-bottom:var(--space-lg);flex-wrap:wrap;gap:var(--space-sm);}
.ml-section-title{font-family:var(--font-primary);font-size:1.25rem;font-weight:800;
    color:var(--color-text);display:flex;align-items:center;gap:var(--space-sm);}
.ml-units{display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));
    gap:var(--space-md);margin-bottom:var(--space-xl);}
.ml-unit-card{background:var(--color-white);border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);padding:var(--space-lg);
    display:flex;flex-direction:column;gap:var(--space-sm);transition:transform .2s,box-shadow .2s;}
.ml-unit-card:hover{transform:translateY(-3px);box-shadow:var(--shadow-md);}
.ml-unit-name{font-family:var(--font-primary);font-size:1rem;font-weight:700;color:var(--color-text);}
.ml-unit-desc{font-size:.8125rem;color:var(--color-text-secondary);line-height:1.5;flex:1;}
.ml-unit-meta{display:flex;align-items:center;gap:var(--space-md);font-size:.8125rem;color:var(--color-text-muted);}
.ml-unit-meta span{display:flex;align-items:center;gap:4px;}
.ml-unit-progress{margin-top:var(--space-sm);}
.ml-unit-progress-bar{height:8px;background:#F0F7FF;border-radius:var(--border-radius-full);overflow:hidden;}
.ml-unit-progress-fill{height:100%;background:linear-gradient(90deg,var(--student),#FFD84D);
    border-radius:var(--border-radius-full);transition:width .6s ease;}
.ml-unit-progress-lbl{display:flex;justify-content:space-between;font-size:.75rem;
    color:var(--color-text-muted);margin-top:4px;}
.ml-quiz-card{background:linear-gradient(135deg,#1D4ED8,#4DA8FF);border-radius:var(--border-radius-xl);
    padding:var(--space-xl);color:#fff;display:flex;align-items:center;gap:var(--space-lg);
    position:relative;overflow:hidden;margin-bottom:var(--space-xl);}
.ml-quiz-card::before{content:'';position:absolute;width:200px;height:200px;border-radius:50%;
    background:rgba(255,255,255,.06);top:-60px;right:-40px;pointer-events:none;}
.ml-quiz-icon{width:56px;height:56px;border-radius:var(--border-radius);
    background:rgba(255,255,255,.18);display:flex;align-items:center;justify-content:center;
    font-size:1.5rem;flex-shrink:0;}
.ml-quiz-body{flex:1;}
.ml-quiz-title{font-family:var(--font-primary);font-size:1.0625rem;font-weight:800;}
.ml-quiz-sub{font-size:.875rem;opacity:.85;margin-top:4px;}
@media(max-width:767px){.ml-levels{grid-template-columns:1fr;}}
@media(max-width:479px){.ml-units{grid-template-columns:1fr;}}
</style>
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
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Student/MyProfile.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span>
        </a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <asp:Literal ID="litPageTitle" runat="server" Text="My Learning" />
</asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<div class="ml-header">
    <div class="ml-title"><asp:Literal ID="litTitle" runat="server" /></div>
    <div class="ml-subtitle"><asp:Literal ID="litSubtitle" runat="server" /></div>
</div>

<%-- Level Cards --%>
<div class="ml-levels">
    <asp:Repeater ID="rptLevels" runat="server">
        <ItemTemplate>
            <div class="ml-level-card <%# Eval("CssClass") %>">
                <div class="ml-level-icon" style="background:<%# Eval("IconBg") %>;color:<%# Eval("IconColor") %>;">
                    <%# Eval("Icon") %>
                </div>
                <div class="ml-level-name"><%# Eval("Name") %></div>
                <div class="ml-level-desc"><%# Eval("Description") %></div>
                <span class="ml-level-badge <%# Eval("BadgeClass") %>"><%# Eval("BadgeText") %></span>
                <asp:HyperLink runat="server"
                    NavigateUrl='<%# Eval("LinkUrl") %>'
                    CssClass='<%# Eval("BtnClass") %>'
                    Enabled='<%# !(bool)Eval("IsLocked") %>'>
                    <i class="bi <%# (bool)Eval("IsLocked") ? "bi-lock-fill" : "bi-arrow-right" %>"></i>
                    <%# Eval("BtnText") %>
                </asp:HyperLink>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</div>

<%-- Current Level Section --%>
<asp:Panel ID="pnlUnits" runat="server">
    <div class="ml-section-hd">
        <div class="ml-section-title">
            <i class="bi bi-collection-fill" style="color:var(--student)"></i>
            <asp:Literal ID="litUnitsTitle" runat="server" />
        </div>
    </div>
    <div class="ml-units">
        <asp:Repeater ID="rptUnits" runat="server">
            <ItemTemplate>
                <div class="ml-unit-card">
                    <div class="ml-unit-name"><%# Eval("Name") %></div>
                    <div class="ml-unit-desc"><%# Eval("Description") %></div>
                    <div class="ml-unit-meta">
                        <span><i class="bi bi-layers"></i> <%# Eval("SubtopicCount") %> <%# Eval("SubtopicLabel") %></span>
                        <span><i class="bi bi-journal-text"></i> <%# Eval("LessonCount") %> <%# Eval("LessonLabel") %></span>
                    </div>
                    <div class="ml-unit-progress">
                        <div class="ml-unit-progress-bar">
                            <div class="ml-unit-progress-fill" style="width:<%# Eval("ProgressPct") %>%"></div>
                        </div>
                        <div class="ml-unit-progress-lbl">
                            <span><%# Eval("ProgressText") %></span>
                            <span><%# Eval("ProgressPct") %>%</span>
                        </div>
                    </div>
                    <a href="<%# Eval("LinkUrl") %>" class="sb-btn sb-btn-orange sb-btn-sm" style="margin-top:var(--space-sm);">
                        <i class="bi bi-arrow-right"></i> <%# Eval("BtnText") %>
                    </a>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>

<%-- Level Quiz --%>
<asp:Panel ID="pnlQuiz" runat="server" Visible="false">
    <div class="ml-quiz-card">
        <div class="ml-quiz-icon"><i class="bi bi-patch-check-fill"></i></div>
        <div class="ml-quiz-body">
            <div class="ml-quiz-title"><asp:Literal ID="litQuizTitle" runat="server" /></div>
            <div class="ml-quiz-sub"><asp:Literal ID="litQuizSub" runat="server" /></div>
        </div>
        <a href="#" class="sb-btn sb-btn-white sb-btn-sm">
            <i class="bi bi-play-fill"></i> <asp:Literal ID="litQuizBtn" runat="server" Text="Start" />
        </a>
    </div>
</asp:Panel>

<asp:Panel ID="pnlQuizEmpty" runat="server" Visible="false">
    <div class="sb-alert sb-alert-info" style="margin-bottom:var(--space-xl);">
        <i class="bi bi-info-circle-fill alert-icon"></i>
        <div class="alert-content"><asp:Literal ID="litQuizEmpty" runat="server" /></div>
    </div>
</asp:Panel>

<%-- Empty state if no levels --%>
<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="sb-empty-state" style="padding:var(--space-3xl) 0;">
        <div class="empty-icon" style="font-size:3.5rem;">📚</div>
        <div class="empty-title"><asp:Literal ID="litEmptyTitle" runat="server" /></div>
        <div class="empty-desc"><asp:Literal ID="litEmptyDesc" runat="server" /></div>
    </div>
</asp:Panel>

</asp:Content>
