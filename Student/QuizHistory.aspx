<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="QuizHistory.aspx.cs"
    Inherits="ScienceBuddy.Student.QuizHistory" MasterPageFile="~/Site.Master" Title="Quiz History" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--qh-primary:#FF6B2C;--qh-blue:#2563EB;--qh-green:#22C55E;--qh-red:#EF4444;--qh-gold:#FFD84D;}
.qh-header{background:linear-gradient(135deg,var(--qh-blue),#4DA8FF);border-radius:var(--border-radius-xl);
    padding:var(--space-xl) var(--space-2xl);color:#fff;margin-bottom:var(--space-xl);position:relative;overflow:hidden;
    box-shadow:0 12px 40px rgba(37,99,235,.2);}
.qh-header-blob{position:absolute;width:200px;height:200px;border-radius:50%;background:rgba(255,255,255,.06);top:-60px;right:-30px;pointer-events:none;}
.qh-header-title{font-family:var(--font-primary);font-size:1.5rem;font-weight:800;position:relative;z-index:1;}
.qh-header-sub{font-size:.9rem;opacity:.85;position:relative;z-index:1;margin-top:4px;}
.qh-stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:var(--space-md);margin-bottom:var(--space-xl);}
.qh-stat{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);
    box-shadow:var(--shadow-sm);padding:var(--space-lg);text-align:center;transition:transform .2s;}
.qh-stat:hover{transform:translateY(-3px);box-shadow:var(--shadow-md);}
.qh-stat-icon{width:44px;height:44px;border-radius:var(--border-radius);display:flex;align-items:center;
    justify-content:center;font-size:1.25rem;margin:0 auto var(--space-sm);}
.qh-stat-val{font-family:var(--font-primary);font-size:1.5rem;font-weight:800;color:var(--color-text);}
.qh-stat-lbl{font-size:.8125rem;color:var(--color-text-secondary);font-weight:600;margin-top:2px;}
.qh-filters{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);
    box-shadow:var(--shadow-sm);padding:var(--space-lg);margin-bottom:var(--space-xl);
    display:flex;flex-wrap:wrap;gap:var(--space-sm);align-items:end;}
.qh-filter-group{display:flex;flex-direction:column;gap:4px;}
.qh-filter-lbl{font-size:.75rem;font-weight:700;color:var(--color-text-secondary);}
.qh-filter-input{padding:8px 12px;border:1.5px solid var(--border-color);border-radius:var(--border-radius);
    font-size:.8125rem;min-width:130px;background:#FAFBFC;}
.qh-filter-input:focus{border-color:var(--qh-blue);outline:none;}
.qh-filter-btn{padding:8px 18px;border-radius:var(--border-radius-full);font-size:.8125rem;font-weight:700;
    background:var(--qh-blue);color:#fff;border:none;cursor:pointer;transition:all .2s;}
.qh-filter-btn:hover{background:#1D4ED8;}
.qh-list{display:flex;flex-direction:column;gap:var(--space-md);}
.qh-card{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);
    box-shadow:var(--shadow-sm);padding:var(--space-lg);display:flex;align-items:center;gap:var(--space-lg);
    transition:transform .15s,box-shadow .15s;position:relative;overflow:hidden;}
.qh-card:hover{transform:translateY(-2px);box-shadow:var(--shadow-md);}
.qh-card::before{content:'';position:absolute;top:0;left:0;bottom:0;width:4px;}
.qh-card.passed::before{background:var(--qh-green);}
.qh-card.failed::before{background:var(--qh-red);}
.qh-card-score{width:64px;height:64px;border-radius:50%;display:flex;align-items:center;justify-content:center;
    font-family:var(--font-primary);font-size:1.125rem;font-weight:800;flex-shrink:0;border:3px solid;}
.qh-card-score.passed{background:#DCFCE7;color:#15803D;border-color:#BBF7D0;}
.qh-card-score.failed{background:#FEF2F2;color:#DC2626;border-color:#FECACA;}
.qh-card-body{flex:1;min-width:0;}
.qh-card-title{font-family:var(--font-primary);font-size:1rem;font-weight:700;color:var(--color-text);
    white-space:nowrap;overflow:hidden;text-overflow:ellipsis;margin-bottom:4px;}
.qh-card-meta{display:flex;flex-wrap:wrap;gap:6px;align-items:center;font-size:.75rem;color:var(--color-text-secondary);}
.qh-badge{display:inline-flex;align-items:center;gap:3px;padding:2px 8px;border-radius:var(--border-radius-full);
    font-size:.6875rem;font-weight:700;text-transform:uppercase;letter-spacing:.3px;}
.qh-badge-practice{background:#EFF6FF;color:#2563EB;}
.qh-badge-unit{background:#FFF0E8;color:#FF6B2C;}
.qh-badge-level{background:#F3E8FF;color:#7C3AED;}
.qh-badge-passed{background:#DCFCE7;color:#15803D;}
.qh-badge-failed{background:#FEF2F2;color:#DC2626;}
.qh-card-actions{display:flex;gap:6px;flex-shrink:0;flex-wrap:wrap;}
.qh-btn-sm{display:inline-flex;align-items:center;gap:4px;padding:6px 14px;border-radius:var(--border-radius-full);
    font-size:.75rem;font-weight:700;text-decoration:none;transition:all .2s;white-space:nowrap;}
.qh-btn-blue{background:var(--qh-blue);color:#fff;}.qh-btn-blue:hover{background:#1D4ED8;color:#fff;text-decoration:none;}
.qh-btn-orange{background:var(--qh-primary);color:#fff;}.qh-btn-orange:hover{color:#fff;text-decoration:none;}
.qh-btn-outline{background:transparent;color:var(--color-text-secondary);border:1.5px solid var(--border-color);}
.qh-btn-outline:hover{background:#F3F4F6;text-decoration:none;color:var(--color-text);}
.qh-empty{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);
    box-shadow:var(--shadow-sm);padding:var(--space-2xl);text-align:center;}
.qh-empty-icon{font-size:3rem;color:var(--color-text-muted);margin-bottom:var(--space-md);}
.qh-empty-title{font-family:var(--font-primary);font-size:1.125rem;font-weight:700;margin-bottom:6px;}
.qh-empty-desc{font-size:.9rem;color:var(--color-text-secondary);margin-bottom:var(--space-lg);}
.qh-empty-btn{display:inline-flex;align-items:center;gap:6px;padding:10px 24px;border-radius:var(--border-radius-full);
    font-weight:700;background:var(--qh-blue);color:#fff;text-decoration:none;}
.qh-empty-btn:hover{background:#1D4ED8;text-decoration:none;color:#fff;}
@media(max-width:767px){.qh-card{flex-direction:column;align-items:flex-start;}.qh-card-actions{width:100%;}.qh-filters{flex-direction:column;}}
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

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><asp:Literal ID="litPageTitle" runat="server" Text="Quiz History" /></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- Header --%>
<a href="<%: ResolveUrl("~/Student/PracticeLibrary.aspx") %>" style="display:inline-flex;align-items:center;gap:6px;padding:8px 18px;border-radius:var(--border-radius-full);font-size:.875rem;font-weight:700;color:#2563EB;background:#EFF6FF;border:1.5px solid #BFDBFE;text-decoration:none;margin-bottom:var(--space-lg);transition:all .2s;" onmouseover="this.style.background='#2563EB';this.style.color='#fff';" onmouseout="this.style.background='#EFF6FF';this.style.color='#2563EB';">
    <i class="bi bi-arrow-left"></i> <asp:Literal ID="litBackToPractice" runat="server" Text="Back to Practice Library" />
</a>
<div class="qh-header"><div class="qh-header-blob"></div>
    <div class="qh-header-title"><i class="bi bi-clock-history"></i> <asp:Literal ID="litTitle" runat="server" /></div>
    <div class="qh-header-sub"><asp:Literal ID="litSubtitle" runat="server" /></div>
</div>

<%-- Stats --%>
<div class="qh-stats">
    <div class="qh-stat"><div class="qh-stat-icon" style="background:#EFF6FF;color:#2563EB;"><i class="bi bi-list-check"></i></div>
        <div class="qh-stat-val"><asp:Literal ID="litStatTotal" runat="server" Text="0" /></div>
        <div class="qh-stat-lbl"><asp:Literal ID="litStatTotalLbl" runat="server" /></div></div>
    <div class="qh-stat"><div class="qh-stat-icon" style="background:#DCFCE7;color:#15803D;"><i class="bi bi-check-circle-fill"></i></div>
        <div class="qh-stat-val"><asp:Literal ID="litStatPassed" runat="server" Text="0" /></div>
        <div class="qh-stat-lbl"><asp:Literal ID="litStatPassedLbl" runat="server" /></div></div>
    <div class="qh-stat"><div class="qh-stat-icon" style="background:#FFF0E8;color:#FF6B2C;"><i class="bi bi-trophy-fill"></i></div>
        <div class="qh-stat-val"><asp:Literal ID="litStatBest" runat="server" Text="0%" /></div>
        <div class="qh-stat-lbl"><asp:Literal ID="litStatBestLbl" runat="server" /></div></div>
    <div class="qh-stat"><div class="qh-stat-icon" style="background:#F3E8FF;color:#7C3AED;"><i class="bi bi-calendar-check"></i></div>
        <div class="qh-stat-val"><asp:Literal ID="litStatLatest" runat="server" Text="-" /></div>
        <div class="qh-stat-lbl"><asp:Literal ID="litStatLatestLbl" runat="server" /></div></div>
</div>

<%-- Filters --%>
<div class="qh-filters">
    <div class="qh-filter-group"><span class="qh-filter-lbl"><asp:Literal ID="litFType" runat="server" Text="Type" /></span>
        <asp:DropDownList ID="ddlType" runat="server" CssClass="qh-filter-input" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed" /></div>
    <div class="qh-filter-group"><span class="qh-filter-lbl"><asp:Literal ID="litFStatus" runat="server" Text="Status" /></span>
        <asp:DropDownList ID="ddlStatus" runat="server" CssClass="qh-filter-input" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed" /></div>
    <div class="qh-filter-group"><span class="qh-filter-lbl"><asp:Literal ID="litFSort" runat="server" Text="Sort" /></span>
        <asp:DropDownList ID="ddlSort" runat="server" CssClass="qh-filter-input" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed" /></div>
    <div class="qh-filter-group"><span class="qh-filter-lbl"><asp:Literal ID="litFSearch" runat="server" Text="Search" /></span>
        <asp:TextBox ID="txtSearch" runat="server" CssClass="qh-filter-input" placeholder="..." /></div>
    <asp:Button ID="btnFilter" runat="server" CssClass="qh-filter-btn" Text="Filter" OnClick="btnFilter_Click" />
</div>

<%-- List --%>
<asp:Panel ID="pnlList" runat="server">
    <div class="qh-list">
        <asp:Repeater ID="rptHistory" runat="server">
            <ItemTemplate>
                <div class='qh-card <%# Eval("StatusClass") %>'>
                    <div class='qh-card-score <%# Eval("StatusClass") %>'><%# Eval("PctDisplay") %></div>
                    <div class="qh-card-body">
                        <div class="qh-card-title"><%# Eval("QuizTitle") %></div>
                        <div class="qh-card-meta">
                            <span class='qh-badge <%# Eval("TypeBadgeClass") %>'><%# Eval("TypeLabel") %></span>
                            <span class='qh-badge <%# Eval("StatusBadgeClass") %>'><%# Eval("StatusLabel") %></span>
                            <span><i class="bi bi-hash"></i><%# Eval("AttemptNo") %></span>
                            <span><i class="bi bi-calendar3"></i> <%# Eval("DateDisplay") %></span>
                            <span><%# Eval("ScoreDisplay") %></span>
                        </div>
                    </div>
                    <div class="qh-card-actions">
                        <a href='<%# Eval("ResultUrl") %>' class="qh-btn-sm qh-btn-blue"><i class="bi bi-eye"></i> <%# Eval("ViewLbl") %></a>
                        <a href='<%# Eval("ReviewUrl") %>' class="qh-btn-sm qh-btn-outline"><i class="bi bi-search"></i> <%# Eval("ReviewLbl") %></a>
                        <a href='<%# Eval("RetryUrl") %>' class="qh-btn-sm qh-btn-orange"><i class="bi bi-arrow-repeat"></i> <%# Eval("RetryLbl") %></a>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>

<%-- Empty --%>
<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="qh-empty">
        <div class="qh-empty-icon"><i class="bi bi-journal-x"></i></div>
        <div class="qh-empty-title"><asp:Literal ID="litEmptyTitle" runat="server" /></div>
        <div class="qh-empty-desc"><asp:Literal ID="litEmptyDesc" runat="server" /></div>
        <a href="<%: ResolveUrl("~/Student/PracticeLibrary.aspx") %>" class="qh-empty-btn"><i class="bi bi-patch-question"></i> <asp:Literal ID="litEmptyBtn" runat="server" /></a>
    </div>
</asp:Panel>
</asp:Content>
