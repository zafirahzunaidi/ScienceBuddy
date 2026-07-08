<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LevelDetails2.aspx.cs"
    Inherits="ScienceBuddy.Student.LevelDetails" MasterPageFile="~/Site.Master"
    Title="Level Details" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--student:#FF6B2C;--student-light:#FFF0E8;--student-dark:#E85B1D;}
.ld-hero{background:linear-gradient(135deg,#1D4ED8 0%,#2563EB 40%,#4DA8FF 100%);
    border-radius:var(--border-radius-xl);padding:var(--space-2xl);color:#fff;
    position:relative;overflow:hidden;margin-bottom:var(--space-xl);box-shadow:0 10px 36px rgba(37,99,235,.25);}
.ld-hero::before{content:'';position:absolute;width:300px;height:300px;border-radius:50%;
    background:rgba(255,255,255,.06);top:-80px;right:-60px;pointer-events:none;}
.ld-hero-back{display:inline-flex;align-items:center;gap:6px;font-size:.875rem;font-weight:600;
    color:rgba(255,255,255,.8);text-decoration:none;margin-bottom:var(--space-md);transition:color .15s;}
.ld-hero-back:hover{color:#fff;text-decoration:none;}
.ld-hero-name{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;margin-bottom:6px;}
.ld-hero-desc{font-size:.9375rem;opacity:.88;max-width:560px;line-height:1.55;margin-bottom:var(--space-lg);}
.ld-hero-badge{display:inline-flex;align-items:center;gap:6px;padding:5px 14px;
    border-radius:var(--border-radius-full);font-size:.8125rem;font-weight:700;
    background:rgba(255,255,255,.2);border:1.5px solid rgba(255,255,255,.35);margin-bottom:var(--space-lg);}
.ld-hero-progress{max-width:400px;}
.ld-hero-bar{height:10px;background:rgba(255,255,255,.2);border-radius:var(--border-radius-full);overflow:hidden;}
.ld-hero-fill{height:100%;background:linear-gradient(90deg,#FFD84D,#FF9A5C);border-radius:var(--border-radius-full);transition:width .8s ease;}
.ld-hero-bar-lbl{display:flex;justify-content:space-between;font-size:.75rem;opacity:.8;margin-top:5px;}
.ld-stats{display:grid;grid-template-columns:repeat(4,1fr);gap:var(--space-md);margin-bottom:var(--space-xl);}
.ld-stat{background:var(--color-white);border-radius:var(--border-radius-lg);border:1.5px solid var(--border-color);
    box-shadow:var(--shadow-sm);padding:var(--space-lg);display:flex;align-items:center;gap:var(--space-md);
    transition:transform .2s,box-shadow .2s;}
.ld-stat:hover{transform:translateY(-3px);box-shadow:var(--shadow-md);}
.ld-stat-icon{width:44px;height:44px;border-radius:var(--border-radius);display:flex;align-items:center;justify-content:center;font-size:1.25rem;flex-shrink:0;}
.ld-stat-val{font-family:var(--font-primary);font-size:1.5rem;font-weight:800;line-height:1;}
.ld-stat-lbl{font-size:.8125rem;color:var(--color-text-secondary);margin-top:3px;font-weight:600;}
.ld-sec-hd{display:flex;align-items:center;gap:var(--space-sm);margin-bottom:var(--space-lg);}
.ld-sec-title{font-family:var(--font-primary);font-size:1.25rem;font-weight:800;color:var(--color-text);}
.ld-roadmap{display:flex;flex-direction:column;gap:var(--space-md);margin-bottom:var(--space-xl);position:relative;padding-left:28px;}
.ld-roadmap::before{content:'';position:absolute;left:12px;top:16px;bottom:16px;width:3px;background:var(--border-color);border-radius:3px;}
.ld-unit{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);
    box-shadow:var(--shadow-sm);padding:var(--space-lg);display:flex;gap:var(--space-md);align-items:flex-start;
    position:relative;transition:transform .2s,box-shadow .2s;}
.ld-unit:hover{transform:translateY(-2px);box-shadow:var(--shadow-md);}
.ld-dot{position:absolute;left:-22px;top:24px;width:14px;height:14px;border-radius:50%;border:3px solid var(--color-primary);background:var(--color-white);z-index:1;}
.ld-dot.done{background:var(--color-success);border-color:var(--color-success);}
.ld-dot.active{background:var(--student);border-color:var(--student);box-shadow:0 0 0 4px rgba(255,107,44,.2);}
.ld-unit-body{flex:1;min-width:0;}
.ld-unit-name{font-family:var(--font-primary);font-size:1rem;font-weight:700;color:var(--color-text);margin-bottom:4px;}
.ld-unit-desc{font-size:.8125rem;color:var(--color-text-secondary);line-height:1.5;margin-bottom:var(--space-sm);}
.ld-unit-meta{display:flex;align-items:center;gap:var(--space-md);font-size:.8125rem;color:var(--color-text-muted);margin-bottom:var(--space-sm);}
.ld-unit-meta span{display:flex;align-items:center;gap:4px;}
.ld-unit-bar{height:6px;background:#F0F7FF;border-radius:var(--border-radius-full);overflow:hidden;margin-bottom:var(--space-sm);}
.ld-unit-bar-fill{height:100%;background:linear-gradient(90deg,var(--student),#FFD84D);border-radius:var(--border-radius-full);transition:width .6s ease;}
.ld-quiz{background:linear-gradient(135deg,var(--student) 0%,#FF9A5C 100%);border-radius:var(--border-radius-xl);
    padding:var(--space-xl);color:#fff;display:flex;align-items:center;gap:var(--space-lg);
    position:relative;overflow:hidden;margin-bottom:var(--space-xl);}
.ld-quiz::before{content:'';position:absolute;width:180px;height:180px;border-radius:50%;background:rgba(255,255,255,.08);bottom:-50px;left:-30px;pointer-events:none;}
.ld-quiz-icon{width:56px;height:56px;border-radius:var(--border-radius);background:rgba(255,255,255,.2);display:flex;align-items:center;justify-content:center;font-size:1.5rem;flex-shrink:0;}
.ld-quiz-body{flex:1;}
.ld-quiz-title{font-family:var(--font-primary);font-size:1.0625rem;font-weight:800;}
.ld-quiz-sub{font-size:.875rem;opacity:.85;margin-top:4px;}
.ld-locked{background:var(--color-white);border-radius:var(--border-radius-xl);border:2px solid var(--border-color);padding:var(--space-3xl);text-align:center;}
.ld-locked-icon{font-size:3rem;margin-bottom:var(--space-md);}
.ld-locked-title{font-family:var(--font-primary);font-size:1.25rem;font-weight:800;color:var(--color-text);margin-bottom:var(--space-sm);}
.ld-locked-desc{font-size:.9375rem;color:var(--color-text-secondary);margin-bottom:var(--space-lg);}
@media(max-width:1023px){.ld-stats{grid-template-columns:repeat(2,1fr);}}
@media(max-width:767px){.ld-stats{grid-template-columns:1fr 1fr;}.ld-quiz{flex-direction:column;align-items:flex-start;}}
@media(max-width:479px){.ld-stats{grid-template-columns:1fr;}.ld-hero{padding:var(--space-xl) var(--space-lg);}}
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
    <asp:Literal ID="litPageTitle" runat="server" Text="Level Details" />
</asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- LOCKED STATE --%>
<asp:Panel ID="pnlLocked" runat="server" Visible="false">
    <div class="ld-locked">
        <div class="ld-locked-icon">🔒</div>
        <div class="ld-locked-title"><asp:Literal ID="litLockedTitle" runat="server" /></div>
        <div class="ld-locked-desc"><asp:Literal ID="litLockedDesc" runat="server" /></div>
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="sb-btn sb-btn-primary sb-btn-sm">
            <i class="bi bi-arrow-left"></i> <asp:Literal ID="litLockedBtn" runat="server" />
        </a>
    </div>
</asp:Panel>

<%-- MAIN CONTENT --%>
<asp:Panel ID="pnlMain" runat="server">

<%-- Hero --%>
<div class="ld-hero">
    <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="ld-hero-back"><i class="bi bi-arrow-left"></i> <asp:Literal ID="litBack" runat="server" /></a>
    <div class="ld-hero-name"><asp:Literal ID="litLevelName" runat="server" /></div>
    <div class="ld-hero-desc"><asp:Literal ID="litLevelDesc" runat="server" /></div>
    <div class="ld-hero-badge"><i class="bi bi-bar-chart-fill"></i> <asp:Literal ID="litHeroBadge" runat="server" /></div>
    <div class="ld-hero-progress">
        <div class="ld-hero-bar"><div class="ld-hero-fill" id="heroFill" runat="server" style="width:0%"></div></div>
        <div class="ld-hero-bar-lbl"><span><asp:Literal ID="litProgressLbl" runat="server" /></span><span><asp:Literal ID="litProgressPct" runat="server" Text="0%" /></span></div>
    </div>
</div>

<%-- Stats --%>
<div class="ld-stats">
    <div class="ld-stat"><div class="ld-stat-icon" style="background:#DBEAFE;color:#1D4ED8;"><i class="bi bi-collection-fill"></i></div>
        <div><div class="ld-stat-val"><asp:Literal ID="litStatUnits" runat="server" Text="0" /></div><div class="ld-stat-lbl"><asp:Literal ID="litStatUnitsLbl" runat="server" /></div></div></div>
    <div class="ld-stat"><div class="ld-stat-icon" style="background:#DCFCE7;color:#15803D;"><i class="bi bi-check2-circle"></i></div>
        <div><div class="ld-stat-val"><asp:Literal ID="litStatDone" runat="server" Text="0" /></div><div class="ld-stat-lbl"><asp:Literal ID="litStatDoneLbl" runat="server" /></div></div></div>
    <div class="ld-stat"><div class="ld-stat-icon" style="background:var(--student-light);color:var(--student);"><i class="bi bi-journal-check"></i></div>
        <div><div class="ld-stat-val"><asp:Literal ID="litStatLessons" runat="server" Text="0" /></div><div class="ld-stat-lbl"><asp:Literal ID="litStatLessonsLbl" runat="server" /></div></div></div>
    <div class="ld-stat"><div class="ld-stat-icon" style="background:#FFFBEB;color:#B45309;"><i class="bi bi-patch-check-fill"></i></div>
        <div><div class="ld-stat-val"><asp:Literal ID="litStatQuiz" runat="server" Text="0" /></div><div class="ld-stat-lbl"><asp:Literal ID="litStatQuizLbl" runat="server" /></div></div></div>
</div>

<%-- Unit Roadmap --%>
<asp:Panel ID="pnlUnits" runat="server">
    <div class="ld-sec-hd"><i class="bi bi-signpost-split-fill" style="color:var(--student);font-size:1.25rem;"></i>
        <div class="ld-sec-title"><asp:Literal ID="litRoadmap" runat="server" /></div></div>
    <div class="ld-roadmap">
        <asp:Repeater ID="rptUnits" runat="server">
            <ItemTemplate>
                <div class="ld-unit">
                    <div class="ld-dot <%# Eval("Dot") %>"></div>
                    <div class="ld-unit-body">
                        <div class="ld-unit-name"><%# Eval("Name") %></div>
                        <div class="ld-unit-desc"><%# Eval("Desc") %></div>
                        <div class="ld-unit-meta">
                            <span><i class="bi bi-layers"></i> <%# Eval("Subs") %> <%# Eval("SubLbl") %></span>
                            <span><i class="bi bi-journal-text"></i> <%# Eval("Lessons") %> <%# Eval("LessonLbl") %></span>
                            <span><i class="bi bi-check2"></i> <%# Eval("Done") %>/<%# Eval("Lessons") %></span>
                        </div>
                        <div class="ld-unit-bar"><div class="ld-unit-bar-fill" style="width:<%# Eval("Pct") %>%"></div></div>
                        <a href="<%# Eval("Url") %>" class="sb-btn sb-btn-orange sb-btn-xs"><i class="bi bi-arrow-right"></i> <%# Eval("Btn") %></a>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>

<asp:Panel ID="pnlUnitsEmpty" runat="server" Visible="false">
    <div class="sb-empty-state" style="padding:var(--space-2xl) 0;">
        <div class="empty-icon" style="font-size:3rem;">📦</div>
        <div class="empty-title"><asp:Literal ID="litEmptyTitle" runat="server" /></div>
        <div class="empty-desc"><asp:Literal ID="litEmptyDesc" runat="server" /></div>
    </div>
</asp:Panel>

<%-- Level Quiz --%>
<asp:Panel ID="pnlQuiz" runat="server" Visible="false">
    <div class="ld-sec-hd"><i class="bi bi-trophy-fill" style="color:#B45309;font-size:1.25rem;"></i>
        <div class="ld-sec-title"><asp:Literal ID="litQuizHd" runat="server" /></div></div>
    <div class="ld-quiz">
        <div class="ld-quiz-icon"><i class="bi bi-patch-check-fill"></i></div>
        <div class="ld-quiz-body">
            <div class="ld-quiz-title"><asp:Literal ID="litQuizTitle" runat="server" /></div>
            <div class="ld-quiz-sub"><asp:Literal ID="litQuizSub" runat="server" /></div>
        </div>
        <a id="lnkQuizStart" runat="server" class="sb-btn sb-btn-white sb-btn-sm"><i class="bi bi-play-fill"></i> <asp:Literal ID="litQuizBtn" runat="server" /></a>
    </div>
    <asp:Panel ID="pnlQuizResult" runat="server" Visible="false" style="margin-top:var(--space-sm);display:flex;gap:8px;flex-wrap:wrap;">
        <a id="lnkQuizResult" runat="server" class="sb-btn sb-btn-outline-primary sb-btn-sm" style="font-size:.75rem;"><i class="bi bi-eye"></i> <asp:Literal ID="litQuizResultBtn" runat="server" /></a>
        <a id="lnkQuizReview" runat="server" class="sb-btn sb-btn-outline-primary sb-btn-sm" style="font-size:.75rem;"><i class="bi bi-search"></i> <asp:Literal ID="litQuizReviewBtn" runat="server" /></a>
    </asp:Panel>
</asp:Panel>

<asp:Panel ID="pnlQuizNone" runat="server" Visible="false">
    <div class="sb-alert sb-alert-info"><i class="bi bi-info-circle-fill alert-icon"></i>
        <div class="alert-content"><asp:Literal ID="litQuizNone" runat="server" /></div></div>
</asp:Panel>

</asp:Panel>
</asp:Content>
