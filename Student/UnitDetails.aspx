<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UnitDetails.aspx.cs"
    Inherits="ScienceBuddy.Student.UnitDetails" MasterPageFile="~/Site.Master"
    Title="Unit Details" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--student:#FF6B2C;--student-light:#FFF0E8;}
.ud-hero{background:linear-gradient(135deg,var(--student) 0%,#FF9A5C 50%,#FFD84D 100%);
    border-radius:var(--border-radius-xl);padding:var(--space-2xl);color:#fff;position:relative;
    overflow:hidden;margin-bottom:var(--space-xl);box-shadow:0 10px 36px rgba(255,107,44,.2);}
.ud-hero::before{content:'';position:absolute;width:280px;height:280px;border-radius:50%;
    background:rgba(255,255,255,.07);top:-80px;right:-60px;pointer-events:none;}
.ud-hero-back{display:inline-flex;align-items:center;gap:6px;font-size:.875rem;font-weight:600;
    color:rgba(255,255,255,.8);text-decoration:none;margin-bottom:var(--space-md);}
.ud-hero-back:hover{color:#fff;text-decoration:none;}
.ud-hero-name{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;margin-bottom:6px;}
.ud-hero-desc{font-size:.9375rem;opacity:.88;max-width:520px;line-height:1.55;margin-bottom:var(--space-md);}
.ud-hero-level{display:inline-flex;align-items:center;gap:6px;padding:5px 14px;border-radius:var(--border-radius-full);
    font-size:.8125rem;font-weight:700;background:rgba(255,255,255,.2);border:1.5px solid rgba(255,255,255,.35);margin-bottom:var(--space-lg);}
.ud-hero-bar{max-width:360px;}
.ud-bar{height:10px;background:rgba(255,255,255,.25);border-radius:var(--border-radius-full);overflow:hidden;}
.ud-bar-fill{height:100%;background:#fff;border-radius:var(--border-radius-full);transition:width .8s ease;}
.ud-bar-lbl{display:flex;justify-content:space-between;font-size:.75rem;opacity:.8;margin-top:5px;}

.ud-path{display:grid;grid-template-columns:repeat(4,1fr);gap:var(--space-md);margin-bottom:var(--space-xl);}
.ud-path-card{background:var(--color-white);border-radius:var(--border-radius-lg);border:1.5px solid var(--border-color);
    box-shadow:var(--shadow-sm);padding:var(--space-lg);text-align:center;transition:transform .2s,box-shadow .2s;}
.ud-path-card:hover{transform:translateY(-3px);box-shadow:var(--shadow-md);}
.ud-path-icon{font-size:1.75rem;margin-bottom:var(--space-sm);}
.ud-path-label{font-family:var(--font-primary);font-size:.875rem;font-weight:700;color:var(--color-text);}
.ud-path-count{font-size:.75rem;color:var(--color-text-muted);margin-top:2px;}

.ud-sec-hd{display:flex;align-items:center;gap:var(--space-sm);margin-bottom:var(--space-lg);}
.ud-sec-title{font-family:var(--font-primary);font-size:1.125rem;font-weight:800;color:var(--color-text);}

.ud-subtopic{margin-bottom:var(--space-xl);}
.ud-subtopic-title{font-family:var(--font-primary);font-size:1rem;font-weight:700;color:var(--color-text);
    margin-bottom:var(--space-sm);display:flex;align-items:center;gap:var(--space-sm);}
.ud-subtopic-desc{font-size:.8125rem;color:var(--color-text-secondary);margin-bottom:var(--space-md);line-height:1.5;}
.ud-lessons{display:flex;flex-direction:column;gap:var(--space-sm);}
.ud-lesson{background:var(--color-white);border-radius:var(--border-radius-lg);border:1.5px solid var(--border-color);
    box-shadow:var(--shadow-xs);padding:12px var(--space-md);display:flex;align-items:center;gap:var(--space-md);
    transition:transform .15s,box-shadow .15s;}
.ud-lesson:hover{transform:translateY(-2px);box-shadow:var(--shadow-sm);}
.ud-lesson-icon{width:36px;height:36px;border-radius:50%;display:flex;align-items:center;
    justify-content:center;font-size:1rem;flex-shrink:0;}
.ud-lesson-icon.done{background:#DCFCE7;color:#15803D;}
.ud-lesson-icon.pending{background:#F0F7FF;color:#2563EB;}
.ud-lesson-name{flex:1;font-weight:600;font-size:.9375rem;color:var(--color-text);}
.ud-lesson-badge{font-size:.6875rem;font-weight:700;padding:2px 8px;border-radius:var(--border-radius-full);}

.ud-mat-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));gap:var(--space-md);margin-bottom:var(--space-xl);}
.ud-mat-card{background:var(--color-white);border-radius:var(--border-radius-lg);border:1.5px solid var(--border-color);
    box-shadow:var(--shadow-sm);padding:var(--space-lg);display:flex;flex-direction:column;gap:var(--space-sm);
    transition:transform .2s,box-shadow .2s;}
.ud-mat-card:hover{transform:translateY(-2px);box-shadow:var(--shadow-md);}
.ud-mat-title{font-family:var(--font-primary);font-size:.9375rem;font-weight:700;color:var(--color-text);}
.ud-mat-meta{font-size:.75rem;color:var(--color-text-muted);display:flex;gap:var(--space-md);}

.ud-lab{background:linear-gradient(135deg,#15803D,#22C55E);border-radius:var(--border-radius-xl);
    padding:var(--space-xl);color:#fff;display:flex;align-items:center;gap:var(--space-lg);
    margin-bottom:var(--space-xl);position:relative;overflow:hidden;}
.ud-lab::before{content:'';position:absolute;width:160px;height:160px;border-radius:50%;
    background:rgba(255,255,255,.08);bottom:-40px;right:-20px;pointer-events:none;}
.ud-lab-icon{width:56px;height:56px;border-radius:var(--border-radius);background:rgba(255,255,255,.2);
    display:flex;align-items:center;justify-content:center;font-size:1.5rem;flex-shrink:0;}
.ud-lab-body{flex:1;}
.ud-lab-title{font-family:var(--font-primary);font-size:1.0625rem;font-weight:800;}
.ud-lab-sub{font-size:.875rem;opacity:.85;margin-top:4px;}

.ud-quiz{background:linear-gradient(135deg,#1D4ED8,#4DA8FF);border-radius:var(--border-radius-xl);
    padding:var(--space-xl);color:#fff;display:flex;align-items:center;gap:var(--space-lg);
    margin-bottom:var(--space-xl);position:relative;overflow:hidden;}
.ud-quiz::before{content:'';position:absolute;width:160px;height:160px;border-radius:50%;
    background:rgba(255,255,255,.06);top:-40px;left:-20px;pointer-events:none;}
.ud-quiz-icon{width:56px;height:56px;border-radius:var(--border-radius);background:rgba(255,255,255,.2);
    display:flex;align-items:center;justify-content:center;font-size:1.5rem;flex-shrink:0;}
.ud-quiz-body{flex:1;}
.ud-quiz-title{font-family:var(--font-primary);font-size:1.0625rem;font-weight:800;}
.ud-quiz-sub{font-size:.875rem;opacity:.85;margin-top:4px;}

.ud-locked{background:var(--color-white);border-radius:var(--border-radius-xl);border:2px solid var(--border-color);
    padding:var(--space-3xl);text-align:center;}
.ud-locked-icon{font-size:3rem;margin-bottom:var(--space-md);}
.ud-locked-title{font-family:var(--font-primary);font-size:1.25rem;font-weight:800;margin-bottom:var(--space-sm);}
.ud-locked-desc{font-size:.9375rem;color:var(--color-text-secondary);margin-bottom:var(--space-lg);}

@media(max-width:1023px){.ud-path{grid-template-columns:repeat(2,1fr);}}
@media(max-width:767px){.ud-path{grid-template-columns:repeat(2,1fr);}.ud-lab,.ud-quiz{flex-direction:column;align-items:flex-start;}}
@media(max-width:479px){.ud-path{grid-template-columns:1fr;}.ud-hero{padding:var(--space-xl) var(--space-lg);}}
</style>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label">Main</div>
        <a href="<%: ResolveUrl("~/Student/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label">Dashboard</span></a>
        <a href="<%: ResolveUrl("~/Student/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Learn</div>
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-book item-icon"></i><span class="item-label">My Learning</span></a>
        <a href="<%: ResolveUrl("~/Student/Quiz.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label">Practice Library</span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-eyedropper item-icon"></i><span class="item-label">Virtual Labs</span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label">Live Sessions</span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-robot item-icon"></i><span class="item-label">AI Study Companion</span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Progress</div>
        <a href="<%: ResolveUrl("~/Student/Progress.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bar-chart-line item-icon"></i><span class="item-label">Progress &amp; Rewards</span></a>
        <a href="<%: ResolveUrl("~/Student/Forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label">Forum</span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Student/Profile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a></div>
</asp:Content>
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><asp:Literal ID="litPageTitle" runat="server" Text="Unit Details" /></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<asp:Panel ID="pnlLocked" runat="server" Visible="false">
    <div class="ud-locked"><div class="ud-locked-icon">🔒</div>
        <div class="ud-locked-title"><asp:Literal ID="litLockedTitle" runat="server" /></div>
        <div class="ud-locked-desc"><asp:Literal ID="litLockedDesc" runat="server" /></div>
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="sb-btn sb-btn-primary sb-btn-sm"><i class="bi bi-arrow-left"></i> <asp:Literal ID="litLockedBtn" runat="server" /></a>
    </div>
</asp:Panel>

<asp:Panel ID="pnlMain" runat="server">

<div class="ud-hero">
    <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="ud-hero-back"><i class="bi bi-arrow-left"></i> <asp:Literal ID="litBack" runat="server" /></a>
    <div class="ud-hero-name"><asp:Literal ID="litUnitName" runat="server" /></div>
    <div class="ud-hero-desc"><asp:Literal ID="litUnitDesc" runat="server" /></div>
    <div class="ud-hero-level"><i class="bi bi-bar-chart-fill"></i> <asp:Literal ID="litHeroLevel" runat="server" /></div>
    <div class="ud-hero-bar">
        <div class="ud-bar"><div class="ud-bar-fill" id="heroBar" runat="server" style="width:0%"></div></div>
        <div class="ud-bar-lbl"><span><asp:Literal ID="litBarLbl" runat="server" /></span><span><asp:Literal ID="litBarPct" runat="server" Text="0%" /></span></div>
    </div>
</div>

<div class="ud-path">
    <div class="ud-path-card"><div class="ud-path-icon">📖</div><div class="ud-path-label"><asp:Literal ID="litPathLessons" runat="server" /></div><div class="ud-path-count"><asp:Literal ID="litPathLessonsCt" runat="server" /></div></div>
    <div class="ud-path-card"><div class="ud-path-icon">📂</div><div class="ud-path-label"><asp:Literal ID="litPathMats" runat="server" /></div><div class="ud-path-count"><asp:Literal ID="litPathMatsCt" runat="server" /></div></div>
    <div class="ud-path-card"><div class="ud-path-icon">🧪</div><div class="ud-path-label"><asp:Literal ID="litPathLab" runat="server" /></div><div class="ud-path-count"><asp:Literal ID="litPathLabCt" runat="server" /></div></div>
    <div class="ud-path-card"><div class="ud-path-icon">📝</div><div class="ud-path-label"><asp:Literal ID="litPathQuiz" runat="server" /></div><div class="ud-path-count"><asp:Literal ID="litPathQuizCt" runat="server" /></div></div>
</div>

<%-- Subtopics & Lessons --%>
<asp:Panel ID="pnlLessons" runat="server">
    <div class="ud-sec-hd"><i class="bi bi-journal-text" style="color:var(--student);font-size:1.1rem;"></i><div class="ud-sec-title"><asp:Literal ID="litLessonHd" runat="server" /></div></div>
    <asp:Repeater ID="rptSubtopics" runat="server">
        <ItemTemplate>
            <div class="ud-subtopic">
                <div class="ud-subtopic-title"><i class="bi bi-bookmark-fill" style="color:var(--student);"></i> <%# Eval("Title") %></div>
                <div class="ud-subtopic-desc"><%# Eval("Desc") %></div>
                <div class="ud-lessons">
                    <asp:Repeater ID="rptLessons" runat="server" DataSource='<%# Eval("Lessons") %>'>
                        <ItemTemplate>
                            <div class="ud-lesson">
                                <div class="ud-lesson-icon <%# (bool)Eval("Done") ? "done" : "pending" %>">
                                    <i class="bi <%# (bool)Eval("Done") ? "bi-check-lg" : "bi-play-fill" %>"></i>
                                </div>
                                <div class="ud-lesson-name"><%# Eval("Title") %></div>
                                <span class="ud-lesson-badge" style="background:<%# (bool)Eval("Done") ? "#DCFCE7" : "#F0F7FF" %>;color:<%# (bool)Eval("Done") ? "#15803D" : "#2563EB" %>;">
                                    <%# Eval("Badge") %>
                                </span>
                                <a href="<%# Eval("Url") %>" class="sb-btn sb-btn-xs <%# (bool)Eval("Done") ? "sb-btn-light" : "sb-btn-orange" %>">
                                    <i class="bi bi-arrow-right"></i>
                                </a>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</asp:Panel>

<%-- Materials --%>
<asp:Panel ID="pnlMats" runat="server">
    <div class="ud-sec-hd"><i class="bi bi-folder-fill" style="color:#B45309;font-size:1.1rem;"></i><div class="ud-sec-title"><asp:Literal ID="litMatHd" runat="server" /></div></div>
    <div class="ud-mat-grid">
        <asp:Repeater ID="rptMats" runat="server">
            <ItemTemplate>
                <div class="ud-mat-card">
                    <div class="ud-mat-title"><%# Eval("Title") %></div>
                    <div class="ud-mat-meta"><span><i class="bi bi-file-earmark"></i> <%# Eval("Type") %></span><span><i class="bi bi-translate"></i> <%# Eval("Lang") %></span></div>
                    <a href="<%# Eval("Url") %>" class="sb-btn sb-btn-xs sb-btn-primary" target="_blank"><i class="bi bi-box-arrow-up-right"></i> <%# Eval("Btn") %></a>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>
<asp:Panel ID="pnlMatsEmpty" runat="server" Visible="false">
    <div class="sb-alert sb-alert-info mb-lg"><i class="bi bi-info-circle-fill alert-icon"></i><div class="alert-content"><asp:Literal ID="litMatsEmpty" runat="server" /></div></div>
</asp:Panel>

<%-- Virtual Lab --%>
<asp:Panel ID="pnlLab" runat="server" Visible="false">
    <div class="ud-sec-hd"><i class="bi bi-eyedropper" style="color:#15803D;font-size:1.1rem;"></i><div class="ud-sec-title"><asp:Literal ID="litLabHd" runat="server" /></div></div>
    <div class="ud-lab">
        <div class="ud-lab-icon"><i class="bi bi-eyedropper"></i></div>
        <div class="ud-lab-body"><div class="ud-lab-title"><asp:Literal ID="litLabTitle" runat="server" /></div><div class="ud-lab-sub"><asp:Literal ID="litLabSub" runat="server" /></div></div>
        <a href="#" class="sb-btn sb-btn-white sb-btn-sm"><i class="bi bi-play-fill"></i> <asp:Literal ID="litLabBtn" runat="server" /></a>
    </div>
</asp:Panel>
<asp:Panel ID="pnlLabEmpty" runat="server" Visible="false">
    <div class="sb-alert sb-alert-info mb-lg"><i class="bi bi-info-circle-fill alert-icon"></i><div class="alert-content"><asp:Literal ID="litLabEmpty" runat="server" /></div></div>
</asp:Panel>

<%-- Unit Quiz --%>
<asp:Panel ID="pnlQuiz" runat="server" Visible="false">
    <div class="ud-sec-hd"><i class="bi bi-patch-question-fill" style="color:#1D4ED8;font-size:1.1rem;"></i><div class="ud-sec-title"><asp:Literal ID="litQuizHd" runat="server" /></div></div>
    <div class="ud-quiz">
        <div class="ud-quiz-icon"><i class="bi bi-patch-question-fill"></i></div>
        <div class="ud-quiz-body"><div class="ud-quiz-title"><asp:Literal ID="litQuizTitle" runat="server" /></div><div class="ud-quiz-sub"><asp:Literal ID="litQuizSub" runat="server" /></div></div>
        <a href="#" class="sb-btn sb-btn-white sb-btn-sm"><i class="bi bi-play-fill"></i> <asp:Literal ID="litQuizBtn" runat="server" /></a>
    </div>
</asp:Panel>
<asp:Panel ID="pnlQuizEmpty" runat="server" Visible="false">
    <div class="sb-alert sb-alert-info mb-lg"><i class="bi bi-info-circle-fill alert-icon"></i><div class="alert-content"><asp:Literal ID="litQuizEmpty" runat="server" /></div></div>
</asp:Panel>

</asp:Panel>
</asp:Content>
