<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CreateForumPost.aspx.cs"
    Inherits="ScienceBuddy.Student.CreateForumPost" MasterPageFile="~/Site.Master"
    Title="Create Discussion" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ── Create Forum Post ── */
:root{--cfp-blue:#2563EB;--cfp-blue-light:#DBEAFE;--cfp-blue-dark:#1D4ED8;--cfp-blue-mid:#4DA8FF;
     --cfp-private:#FF6B2C;--cfp-private-light:#FFF0E8;}

/* ══ PAGE HEADER ══ */
.cfp-header{
    border-radius:var(--border-radius-xl);padding:var(--space-xl) var(--space-2xl);
    color:#fff;position:relative;overflow:hidden;margin-bottom:var(--space-xl);
    box-shadow:0 12px 40px rgba(37,99,235,.30);
}
.cfp-header.public-mode{background:linear-gradient(135deg,#1D4ED8 0%,#2563EB 40%,#4DA8FF 100%);}
.cfp-header.private-mode{background:linear-gradient(135deg,#FF6B2C 0%,#A78BFA 60%,#7C3AED 100%);
    box-shadow:0 12px 40px rgba(167,139,250,.30);}
.cfp-header-blob{position:absolute;width:260px;height:260px;border-radius:50%;
    background:rgba(255,255,255,.06);top:-80px;right:-40px;pointer-events:none;}
.cfp-header-icon{position:absolute;font-size:4rem;opacity:.12;top:20px;right:50px;pointer-events:none;}
.cfp-header-title{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;
    line-height:1.2;margin-bottom:6px;position:relative;z-index:1;}
.cfp-header-sub{font-size:.95rem;opacity:.88;position:relative;z-index:1;max-width:550px;line-height:1.5;}

/* ══ PRIVATE INFO BANNER ══ */
.cfp-private-info{display:flex;align-items:flex-start;gap:var(--space-md);padding:var(--space-lg);
    background:#FEF9F0;border:1.5px solid #FDE68A;border-radius:var(--border-radius-lg);
    margin-bottom:var(--space-lg);}
.cfp-private-info i{font-size:1.25rem;color:#D97706;margin-top:2px;flex-shrink:0;}
.cfp-private-info-text{font-size:.875rem;color:#92400E;line-height:1.5;}
.cfp-private-info-text strong{display:block;margin-bottom:4px;font-weight:700;}

/* ══ NO PARENT WARNING ══ */
.cfp-no-parent{display:flex;align-items:flex-start;gap:var(--space-md);padding:var(--space-lg);
    background:#FEF2F2;border:1.5px solid #FECACA;border-radius:var(--border-radius-lg);
    margin-bottom:var(--space-lg);}
.cfp-no-parent i{font-size:1.25rem;color:#DC2626;margin-top:2px;flex-shrink:0;}
.cfp-no-parent-text{font-size:.875rem;color:#991B1B;line-height:1.5;}

/* ══ FORM CARD ══ */
.cfp-form{
    background:var(--color-white);border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-md);
    padding:var(--space-2xl);
}
.cfp-form-group{margin-bottom:var(--space-lg);}
.cfp-form-label{display:block;font-family:var(--font-primary);font-size:.9375rem;
    font-weight:700;color:var(--color-text);margin-bottom:var(--space-sm);}
.cfp-form-label .required{color:#DC2626;margin-left:2px;}
.cfp-form-input{width:100%;padding:12px 16px;border:1.5px solid var(--border-color);
    border-radius:var(--border-radius);font-size:.9375rem;color:var(--color-text);
    transition:border-color .2s,box-shadow .2s;background:#FAFBFC;}
.cfp-form-input:focus{outline:none;border-color:var(--cfp-blue);
    box-shadow:0 0 0 3px rgba(37,99,235,.12);background:#fff;}
.cfp-form-textarea{min-height:180px;resize:vertical;line-height:1.6;}
.cfp-form-select{appearance:none;background-image:url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='%236B7280' d='M4.5 6l3.5 4 3.5-4z'/%3e%3c/svg%3e");
    background-repeat:no-repeat;background-position:right 12px center;background-size:16px;
    padding-right:40px;}
.cfp-form-hint{font-size:.75rem;color:var(--color-text-muted);margin-top:4px;}

/* ══ PRIVATE TYPE LOCKED ══ */
.cfp-private-locked{display:inline-flex;align-items:center;gap:6px;padding:10px 16px;
    background:#FEF3C7;border:1.5px solid #FDE68A;border-radius:var(--border-radius);
    font-size:.9rem;font-weight:600;color:#92400E;}
.cfp-private-locked i{font-size:1rem;}

/* ══ ERROR PANEL ══ */
.cfp-error{background:#FEF2F2;border:1.5px solid #FECACA;border-radius:var(--border-radius);
    padding:12px 16px;margin-bottom:var(--space-lg);display:flex;align-items:center;gap:10px;
    color:#991B1B;font-size:.875rem;font-weight:600;}
.cfp-error i{font-size:1.1rem;color:#DC2626;}

/* ══ BUTTONS ══ */
.cfp-btn-row{display:flex;align-items:center;gap:var(--space-md);margin-top:var(--space-xl);}
.cfp-btn-submit{display:inline-flex;align-items:center;gap:8px;padding:12px 28px;
    border-radius:var(--border-radius-full);font-weight:700;font-size:.9375rem;
    background:linear-gradient(135deg,var(--cfp-blue-dark),var(--cfp-blue));
    color:#fff;border:none;cursor:pointer;transition:all .2s;
    box-shadow:0 4px 16px rgba(37,99,235,.25);}
.cfp-btn-submit:hover{transform:translateY(-2px);box-shadow:0 8px 24px rgba(37,99,235,.35);}
.cfp-btn-submit.private-btn{background:linear-gradient(135deg,#FF6B2C,#A78BFA);}
.cfp-btn-cancel{display:inline-flex;align-items:center;gap:6px;padding:12px 24px;
    border-radius:var(--border-radius-full);font-weight:700;font-size:.9375rem;
    background:transparent;color:var(--color-text-secondary);border:1.5px solid var(--border-color);
    text-decoration:none;transition:all .2s;cursor:pointer;}
.cfp-btn-cancel:hover{background:#F3F4F6;color:var(--color-text);text-decoration:none;}

/* ══ RESPONSIVE ══ */
@media(max-width:767px){
    .cfp-header{padding:var(--space-lg) var(--space-lg);}
    .cfp-header-title{font-size:1.375rem;}
    .cfp-form{padding:var(--space-xl) var(--space-lg);}
    .cfp-btn-row{flex-direction:column;align-items:stretch;}
    .cfp-btn-submit,.cfp-btn-cancel{justify-content:center;}
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
    <asp:Literal ID="litPageTitle" runat="server" Text="Create Discussion" />
</asp:Content>

<%-- ════ MAIN CONTENT ════ --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- ── PAGE HEADER ── --%>
<div class="cfp-header" id="divHeader" runat="server">
    <div class="cfp-header-blob"></div>
    <div class="cfp-header-icon" id="divHeaderIcon" runat="server"><i class="bi bi-chat-dots-fill"></i></div>
    <div class="cfp-header-title"><asp:Literal ID="litTitle" runat="server" Text="Create Discussion" /></div>
    <div class="cfp-header-sub"><asp:Literal ID="litSubtitle" runat="server" Text="Ask a question or start a Science discussion." /></div>
</div>

<%-- ── PRIVATE INFO BANNER ── --%>
<asp:Panel ID="pnlPrivateInfo" runat="server" Visible="false">
    <div class="cfp-private-info">
        <i class="bi bi-lock-fill"></i>
        <div class="cfp-private-info-text">
            <strong><asp:Literal ID="litPrivateInfoTitle" runat="server" /></strong>
            <asp:Literal ID="litPrivateInfoDesc" runat="server" />
        </div>
    </div>
</asp:Panel>

<%-- ── NO PARENT WARNING ── --%>
<asp:Panel ID="pnlNoParent" runat="server" Visible="false">
    <div class="cfp-no-parent">
        <i class="bi bi-exclamation-triangle-fill"></i>
        <div class="cfp-no-parent-text">
            <asp:Literal ID="litNoParent" runat="server" />
        </div>
    </div>
</asp:Panel>

<%-- ── FORM CARD ── --%>
<div class="cfp-form">

    <%-- Error Panel --%>
    <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="cfp-error">
        <i class="bi bi-exclamation-circle-fill"></i>
        <asp:Literal ID="litError" runat="server" />
    </asp:Panel>

    <%-- Discussion Title --%>
    <div class="cfp-form-group">
        <label class="cfp-form-label"><asp:Literal ID="litTitleLbl" runat="server" Text="Discussion Title" /> <span class="required">*</span></label>
        <asp:TextBox ID="txtTitle" runat="server" CssClass="cfp-form-input" MaxLength="200"
            placeholder="Enter your discussion title..." />
    </div>

    <%-- Discussion Type (Public mode only) --%>
    <asp:Panel ID="pnlTypeDropdown" runat="server">
        <div class="cfp-form-group">
            <label class="cfp-form-label"><asp:Literal ID="litTypeLbl" runat="server" Text="Discussion Type" /></label>
            <asp:DropDownList ID="ddlType" runat="server" CssClass="cfp-form-input cfp-form-select">
            </asp:DropDownList>
            <div class="cfp-form-hint"><asp:Literal ID="litTypeHint" runat="server" /></div>
        </div>
    </asp:Panel>

    <%-- Private Type Locked Badge --%>
    <asp:Panel ID="pnlTypeLocked" runat="server" Visible="false">
        <div class="cfp-form-group">
            <label class="cfp-form-label"><asp:Literal ID="litTypeLockedLbl" runat="server" Text="Discussion Type" /></label>
            <div class="cfp-private-locked">
                <i class="bi bi-lock-fill"></i> <asp:Literal ID="litTypeLockedVal" runat="server" Text="Private (Student-Parent)" />
            </div>
        </div>
    </asp:Panel>

    <%-- Tag (Optional) --%>
    <div class="cfp-form-group">
        <label class="cfp-form-label"><asp:Literal ID="litTagLbl" runat="server" Text="Tag (Optional)" /></label>
        <asp:DropDownList ID="ddlTag" runat="server" CssClass="cfp-form-input cfp-form-select">
        </asp:DropDownList>
    </div>

    <%-- Message --%>
    <div class="cfp-form-group">
        <label class="cfp-form-label"><asp:Literal ID="litMsgLbl" runat="server" Text="Your Message" /> <span class="required">*</span></label>
        <asp:TextBox ID="txtMessage" runat="server" CssClass="cfp-form-input cfp-form-textarea"
            TextMode="MultiLine" placeholder="Write your question or message..." />
    </div>

    <%-- Buttons --%>
    <div class="cfp-btn-row">
        <asp:LinkButton ID="btnSubmit" runat="server" CssClass="cfp-btn-submit" OnClick="btnSubmit_Click">
            <i class="bi bi-send-fill"></i> <asp:Literal ID="litSubmitBtn" runat="server" Text="Create Discussion" />
        </asp:LinkButton>
        <a href="<%: ResolveUrl("~/Student/Forum.aspx") %>" class="cfp-btn-cancel">
            <i class="bi bi-x-lg"></i> <asp:Literal ID="litCancelBtn" runat="server" Text="Cancel" />
        </a>
    </div>
</div>

</asp:Content>
