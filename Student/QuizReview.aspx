<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="QuizReview.aspx.cs"
    Inherits="ScienceBuddy.Student.QuizReviewPage" MasterPageFile="~/Site.Master" Title="Quiz Review" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--rv-green:#22C55E;--rv-red:#EF4444;--rv-blue:#2563EB;--rv-orange:#FF6B2C;--rv-gold:#FFD84D;}

.rv-header{background:linear-gradient(135deg,var(--rv-blue),#4DA8FF);border-radius:var(--border-radius-xl);
    padding:var(--space-xl) var(--space-2xl);color:#fff;margin-bottom:var(--space-xl);position:relative;overflow:hidden;
    box-shadow:0 12px 40px rgba(37,99,235,.2);}
.rv-header-blob{position:absolute;width:180px;height:180px;border-radius:50%;background:rgba(255,255,255,.07);top:-50px;right:-30px;pointer-events:none;}
.rv-header-title{font-family:var(--font-primary);font-size:1.375rem;font-weight:800;margin-bottom:4px;position:relative;z-index:1;}
.rv-header-sub{font-size:.9rem;opacity:.85;position:relative;z-index:1;}
.rv-header-meta{display:flex;gap:var(--space-md);margin-top:var(--space-sm);flex-wrap:wrap;position:relative;z-index:1;}
.rv-header-chip{background:rgba(255,255,255,.2);border:1px solid rgba(255,255,255,.3);border-radius:var(--border-radius-full);
    padding:4px 12px;font-size:.75rem;font-weight:700;display:inline-flex;align-items:center;gap:4px;}

.rv-back{display:inline-flex;align-items:center;gap:6px;padding:8px 18px;border-radius:var(--border-radius-full);
    font-size:.875rem;font-weight:700;color:var(--rv-blue);background:#EFF6FF;border:1.5px solid #BFDBFE;
    text-decoration:none;transition:all .2s;margin-bottom:var(--space-lg);}
.rv-back:hover{background:var(--rv-blue);color:#fff;text-decoration:none;}

/* Question Cards */
.rv-list{display:flex;flex-direction:column;gap:var(--space-lg);margin-bottom:var(--space-xl);}
.rv-card{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);
    box-shadow:var(--shadow-sm);padding:var(--space-xl);position:relative;overflow:hidden;transition:transform .15s;}
.rv-card:hover{transform:translateY(-2px);box-shadow:var(--shadow-md);}
.rv-card::before{content:'';position:absolute;top:0;left:0;right:0;height:4px;border-radius:var(--border-radius-xl) var(--border-radius-xl) 0 0;}
.rv-card.correct::before{background:var(--rv-green);}
.rv-card.wrong::before{background:var(--rv-red);}
.rv-card-num{font-size:.75rem;font-weight:700;letter-spacing:1px;text-transform:uppercase;margin-bottom:var(--space-sm);
    display:flex;align-items:center;gap:6px;}
.rv-card-num.correct{color:var(--rv-green);}
.rv-card-num.wrong{color:var(--rv-red);}
.rv-card-text{font-family:var(--font-primary);font-size:1rem;font-weight:700;color:var(--color-text);
    line-height:1.5;margin-bottom:var(--space-md);}
.rv-card-img{max-width:100%;max-height:200px;border-radius:var(--border-radius);margin-bottom:var(--space-md);border:1px solid var(--border-color);}
.rv-answer-row{display:flex;gap:var(--space-md);flex-wrap:wrap;margin-bottom:var(--space-md);}
.rv-answer-badge{display:inline-flex;align-items:center;gap:4px;padding:8px 14px;border-radius:var(--border-radius-lg);
    font-size:.8125rem;font-weight:700;line-height:1.3;}
.rv-answer-badge.yours{background:#FFF0E8;color:var(--rv-orange);border:1.5px solid #FFCBA4;}
.rv-answer-badge.correct-ans{background:#DCFCE7;color:#15803D;border:1.5px solid #BBF7D0;}
.rv-answer-badge.yours.is-correct{background:#DCFCE7;color:#15803D;border:1.5px solid #BBF7D0;}
.rv-explanation{background:#F8FAFC;border-radius:var(--border-radius);padding:var(--space-md) var(--space-lg);
    font-size:.875rem;color:var(--color-text-secondary);line-height:1.6;
    border-left:3px solid var(--rv-blue);}
.rv-explanation.correct-exp{border-left-color:var(--rv-green);}
.rv-explanation.wrong-exp{border-left-color:var(--rv-orange);}

/* Weak Topics */
.rv-weak{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);
    box-shadow:var(--shadow-sm);padding:var(--space-xl);margin-bottom:var(--space-xl);}
.rv-weak-title{font-family:var(--font-primary);font-size:1rem;font-weight:700;color:var(--color-text);
    margin-bottom:var(--space-md);display:flex;align-items:center;gap:8px;}
.rv-weak-chips{display:flex;flex-wrap:wrap;gap:var(--space-sm);}
.rv-weak-chip{display:inline-flex;align-items:center;gap:4px;padding:6px 14px;border-radius:var(--border-radius-full);
    font-size:.8125rem;font-weight:600;background:#FFF0E8;color:var(--rv-orange);border:1.5px solid #FFCBA4;}

/* Actions */
.rv-actions{display:flex;gap:var(--space-md);flex-wrap:wrap;margin-bottom:var(--space-xl);}
.rv-btn{display:inline-flex;align-items:center;gap:8px;padding:12px 24px;border-radius:var(--border-radius-full);
    font-weight:700;font-size:.9375rem;text-decoration:none;transition:all .2s;}
.rv-btn-primary{background:var(--rv-blue);color:#fff;box-shadow:0 4px 12px rgba(37,99,235,.3);}
.rv-btn-primary:hover{background:#1D4ED8;transform:translateY(-2px);color:#fff;text-decoration:none;}
.rv-btn-orange{background:var(--rv-orange);color:#fff;box-shadow:0 4px 12px rgba(255,107,44,.3);}
.rv-btn-orange:hover{transform:translateY(-2px);color:#fff;text-decoration:none;}
.rv-btn-secondary{background:#F3F4F6;color:var(--color-text);border:1.5px solid var(--border-color);}
.rv-btn-secondary:hover{background:#E5E7EB;text-decoration:none;color:var(--color-text);}

@media(max-width:767px){.rv-header{padding:var(--space-lg);}.rv-header-title{font-size:1.125rem;}.rv-card{padding:var(--space-lg);}
    .rv-actions{flex-direction:column;}.rv-btn{justify-content:center;}}
</style>
</asp:Content>

<asp:Content ID="cSidebarMenu" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label">Main</div>
        <a href="<%: ResolveUrl("~/Student/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label">Dashboard</span></a>
        <a href="<%: ResolveUrl("~/Student/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Learn</div>
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label">My Learning</span></a>
        <a href="<%: ResolveUrl("~/Student/PracticeLibrary.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label">Practice Library</span></a>
        <a href="<%: ResolveUrl("~/Student/VirtualLabs.aspx") %>" class="sb-sidebar-item"><i class="bi bi-eyedropper item-icon"></i><span class="item-label">Virtual Labs</span></a>
        <a href="<%: ResolveUrl("~/Student/LiveSessions.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label">Live Sessions</span></a>
        <a href="<%: ResolveUrl("~/Student/AIStudyCompanion.aspx") %>" class="sb-sidebar-item"><i class="bi bi-robot item-icon"></i><span class="item-label">AI Study Companion</span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Progress</div>
        <a href="<%: ResolveUrl("~/Student/ProgressRewards.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bar-chart-line item-icon"></i><span class="item-label">Progress &amp; Rewards</span></a>
        <a href="<%: ResolveUrl("~/Student/Forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label">Forum</span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Student/Messages.aspx") %>" class="sb-sidebar-item"><i class="bi bi-envelope item-icon"></i><span class="item-label">Messages</span></a>
        <a href="<%: ResolveUrl("~/Student/MyProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a></div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><asp:Literal ID="litPageTitle" runat="server" Text="Quiz Review" /></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- ERROR --%>
<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div style="background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);padding:var(--space-2xl);text-align:center;">
        <i class="bi bi-exclamation-triangle-fill" style="font-size:2.5rem;color:var(--rv-orange);"></i>
        <div style="margin-top:var(--space-md);font-size:.9375rem;color:var(--color-text);"><asp:Literal ID="litError" runat="server" /></div>
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="rv-back" style="margin-top:var(--space-lg);display:inline-flex;"><i class="bi bi-arrow-left"></i> <asp:Literal ID="litErrBtn" runat="server" Text="Back" /></a>
    </div>
</asp:Panel>

<%-- REVIEW --%>
<asp:Panel ID="pnlReview" runat="server" Visible="false">

    <%-- Back --%>
    <a href="#" id="lnkBack" runat="server" class="rv-back"><i class="bi bi-arrow-left"></i> <asp:Literal ID="litBack" runat="server" Text="Back to Result" /></a>

    <%-- Header --%>
    <div class="rv-header">
        <div class="rv-header-blob"></div>
        <div class="rv-header-title"><i class="bi bi-search"></i> <asp:Literal ID="litTitle" runat="server" /></div>
        <div class="rv-header-sub"><asp:Literal ID="litSub" runat="server" /></div>
        <div class="rv-header-meta">
            <span class="rv-header-chip"><i class="bi bi-trophy-fill"></i> <asp:Literal ID="litHeaderPct" runat="server" /></span>
            <span class="rv-header-chip"><i class="bi bi-check-circle-fill"></i> <asp:Literal ID="litHeaderCorrect" runat="server" /></span>
            <span class="rv-header-chip"><i class="bi bi-bookmark-fill"></i> <asp:Literal ID="litHeaderType" runat="server" /></span>
        </div>
    </div>

    <%-- Weak Topics --%>
    <asp:Panel ID="pnlWeakTopics" runat="server" Visible="false">
        <div class="rv-weak">
            <div class="rv-weak-title"><i class="bi bi-lightbulb-fill" style="color:var(--rv-orange);"></i> <asp:Literal ID="litWeakTitle" runat="server" Text="Topics to Review" /></div>
            <div class="rv-weak-chips">
                <asp:Literal ID="litWeakChips" runat="server" />
            </div>
        </div>
    </asp:Panel>

    <%-- Question List --%>
    <div class="rv-list">
        <asp:Repeater ID="rptQuestions" runat="server">
            <ItemTemplate>
                <div class='rv-card <%# (bool)Eval("IsCorrect") ? "correct" : "wrong" %>'>
                    <div class='rv-card-num <%# (bool)Eval("IsCorrect") ? "correct" : "wrong" %>'>
                        <%# (bool)Eval("IsCorrect") ? "<i class=\"bi bi-check-circle-fill\"></i>" : "<i class=\"bi bi-x-circle-fill\"></i>" %>
                        <%# Eval("QLabel") %>
                    </div>
                    <div class="rv-card-text"><%# Eval("QuestionText") %></div>
                    <div class="rv-answer-row">
                        <span class='rv-answer-badge yours <%# (bool)Eval("IsCorrect") ? "is-correct" : "" %>'><i class="bi bi-pencil-fill"></i> <%# Eval("YourLabel") %>: <%# Eval("SelectedDisplay") %></span>
                        <span class="rv-answer-badge correct-ans"><i class="bi bi-check-lg"></i> <%# Eval("CorrectLabel") %>: <%# Eval("CorrectDisplay") %></span>
                    </div>
                    <div class='rv-explanation <%# (bool)Eval("IsCorrect") ? "correct-exp" : "wrong-exp" %>'>
                        <i class='bi <%# (bool)Eval("IsCorrect") ? "bi-lightbulb-fill" : "bi-book-fill" %>' style="margin-right:6px;"></i><%# Eval("Explanation") %>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>

    <%-- Actions --%>
    <div class="rv-actions">
        <a href="#" id="lnkRetry" runat="server" class="rv-btn rv-btn-orange"><i class="bi bi-arrow-repeat"></i> <asp:Literal ID="litRetryBtn" runat="server" Text="Try Again" /></a>
        <a href="#" id="lnkResult" runat="server" class="rv-btn rv-btn-primary"><i class="bi bi-bar-chart-fill"></i> <asp:Literal ID="litResultBtn" runat="server" Text="Back to Result" /></a>
        <a href="<%: ResolveUrl("~/Student/PracticeLibrary.aspx") %>" class="rv-btn rv-btn-secondary"><i class="bi bi-patch-question"></i> <asp:Literal ID="litPracticeBtn" runat="server" Text="Practice Library" /></a>
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="rv-btn rv-btn-secondary"><i class="bi bi-book"></i> <asp:Literal ID="litLearningBtn" runat="server" Text="My Learning" /></a>
        <a href="<%: ResolveUrl("~/Student/QuizHistory.aspx") %>" class="rv-btn rv-btn-secondary"><i class="bi bi-clock-history"></i> <asp:Literal ID="litHistoryBtn" runat="server" Text="Quiz History" /></a>
    </div>

</asp:Panel>
</asp:Content>
