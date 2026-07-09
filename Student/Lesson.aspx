<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Lesson.aspx.cs"
    Inherits="ScienceBuddy.Student.Lesson1" MasterPageFile="~/Site.Master" Title="Lesson" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Student.css") %>" rel="stylesheet" />
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
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><asp:Literal ID="litPageTitle" runat="server" Text="Lesson" /></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<asp:Panel ID="pnlLocked" runat="server" Visible="false">
    <div class="st-lesson-locked"><div class="st-lesson-locked-icon"><i class="bi bi-lock-fill"></i></div>
        <div class="st-lesson-locked-title"><asp:Literal ID="litLockedTitle" runat="server" /></div>
        <div class="st-lesson-locked-desc"><asp:Literal ID="litLockedDesc" runat="server" /></div>
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="sb-btn sb-btn-primary sb-btn-sm"><i class="bi bi-arrow-left"></i> <asp:Literal ID="litLockedBtn" runat="server" /></a>
    </div>
</asp:Panel>

<asp:Panel ID="pnlMain" runat="server">

<%-- Hero --%>
<div class="st-lesson-hero">
    <asp:HyperLink ID="lnkBack" runat="server" CssClass="st-lesson-hero-back"><i class="bi bi-arrow-left"></i> <asp:Literal ID="litBack" runat="server" /></asp:HyperLink>
    <div class="st-lesson-hero-crumb"><asp:Literal ID="litCrumb" runat="server" /></div>
    <div class="st-lesson-hero-title"><asp:Literal ID="litTitle" runat="server" /></div>
    <div id="heroBadgeDiv" runat="server" class="st-lesson-hero-badge st-lesson-badge-pending">
        <i id="heroBadgeIcon" runat="server" class="bi bi-clock"></i>
        <asp:Literal ID="litBadgeText" runat="server" Text="&#x2014;" />
    </div>
</div>

<%-- Reading card --%>
<div class="st-lesson-reading" id="lessonContent">
    <asp:Literal ID="litContent" runat="server" />
</div>

<%-- Text-to-Speech --%>
<div class="st-lesson-tts">
    <button type="button" id="btnTTS" class="sb-btn sb-btn-primary sb-btn-sm" onclick="toggleTTS()">
        <i class="bi bi-megaphone-fill"></i> <span id="ttsLabel"><asp:Literal ID="litTTSStart" runat="server" Text="Read Aloud" /></span>
    </button>
</div>

<%-- Attachment --%>
<asp:Panel ID="pnlAttach" runat="server" Visible="false">
    <div class="st-lesson-sec-hd"><i class="bi bi-paperclip" style="color:var(--student);"></i><div class="st-lesson-sec-title"><asp:Literal ID="litAttachHd" runat="server" /></div></div>
    <div class="st-lesson-attach">
        <div class="st-lesson-attach-icon"><i class="bi bi-file-earmark-fill"></i></div>
        <div class="st-lesson-attach-name"><asp:Literal ID="litAttachName" runat="server" /></div>
        <asp:HyperLink ID="lnkAttach" runat="server" CssClass="sb-btn sb-btn-xs sb-btn-primary" Target="_blank">
            <i class="bi bi-box-arrow-up-right"></i> <asp:Literal ID="litAttachBtn" runat="server" />
        </asp:HyperLink>
    </div>
</asp:Panel>
<asp:Panel ID="pnlAttachEmpty" runat="server" Visible="false">
    <p style="font-size:.8125rem;color:var(--color-text-muted);margin-bottom:var(--space-xl);"><asp:Literal ID="litAttachEmpty" runat="server" /></p>
</asp:Panel>

<%-- Materials --%>
<asp:Panel ID="pnlMats" runat="server" Visible="false">
    <div class="st-lesson-sec-hd"><i class="bi bi-folder-fill" style="color:#B45309;"></i><div class="st-lesson-sec-title"><asp:Literal ID="litMatHd" runat="server" /></div></div>
    <div class="st-lesson-mat-grid">
        <asp:Repeater ID="rptMats" runat="server">
            <ItemTemplate>
                <div class="st-lesson-mat-card">
                    <div class="st-lesson-mat-title"><%# Eval("Title") %></div>
                    <div class="st-lesson-mat-meta"><span><i class="bi bi-file-earmark"></i> <%# Eval("Type") %></span><span><i class="bi bi-translate"></i> <%# Eval("Lang") %></span></div>
                    <a href="<%# Eval("Url") %>" class="sb-btn sb-btn-xs sb-btn-primary" target="_blank"><i class="bi bi-box-arrow-up-right"></i> <%# Eval("Btn") %></a>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>
<asp:Panel ID="pnlMatsEmpty" runat="server" Visible="false">
    <p style="font-size:.8125rem;color:var(--color-text-muted);margin-bottom:var(--space-xl);"><asp:Literal ID="litMatsEmpty" runat="server" /></p>
</asp:Panel>

<%-- Mark Complete --%>
<div class="st-lesson-complete">
    <div class="st-lesson-complete-icon" id="completeIcon" runat="server" style="background:#DCFCE7;color:#15803D;">
        <i class="bi bi-check-circle-fill"></i>
    </div>
    <div class="st-lesson-complete-body">
        <div class="st-lesson-complete-title"><asp:Literal ID="litCompleteTitle" runat="server" /></div>
        <div class="st-lesson-complete-sub"><asp:Literal ID="litCompleteSub" runat="server" /></div>
    </div>
    <asp:Button ID="btnComplete" runat="server" CssClass="sb-btn sb-btn-orange sb-btn-sm" OnClick="btnComplete_Click" CausesValidation="false" />
</div>

<%-- Success message --%>
<asp:Panel ID="pnlSuccess" runat="server" Visible="false">
    <div class="sb-alert sb-alert-success mb-lg"><i class="bi bi-check-circle-fill alert-icon"></i>
        <div class="alert-content"><asp:Literal ID="litSuccess" runat="server" /></div></div>
</asp:Panel>

</asp:Panel>
</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
var speaking = false, utterance = null;
function toggleTTS() {
    if (speaking) { window.speechSynthesis.cancel(); speaking = false; updateTTSBtn(); return; }
    var text = document.getElementById('lessonContent').innerText;
    if (!text) return;
    utterance = new SpeechSynthesisUtterance(text);
    utterance.lang = '<%= CurrentLanguage == "BM" ? "ms-MY" : "en-US" %>';
    utterance.rate = 0.9;
    utterance.onend = function(){ speaking = false; updateTTSBtn(); };
    window.speechSynthesis.speak(utterance);
    speaking = true; updateTTSBtn();
}
function updateTTSBtn() {
    var lbl = document.getElementById('ttsLabel');
    if (lbl) lbl.textContent = speaking
        ? '<%= T("Stop Reading","Henti Bacaan") %>'
        : '<%= T("Read Aloud","Baca Kuat") %>';
}
</script>
</asp:Content>
