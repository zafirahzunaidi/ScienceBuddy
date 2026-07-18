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
        <a href="<%: ResolveUrl("~/Student/RevisionPlan.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-calendar-check item-icon"></i><span class="item-label">Revision Plan</span>
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

    <%-- Inline Attachment --%>
    <asp:Panel ID="pnlAttach" runat="server" Visible="false">
        <div class="st-lesson-inline-attach">
            <asp:Literal ID="litAttachInline" runat="server" />
        </div>
    </asp:Panel>

    <%-- Text-to-Speech --%>
    <div class="st-lesson-tts">
        <button type="button" id="btnTTS" class="sb-btn sb-btn-primary sb-btn-sm" onclick="toggleTTS()">
            <i class="bi bi-megaphone-fill"></i> <span id="ttsLabel"><asp:Literal ID="litTTSStart" runat="server" Text="Read Aloud" /></span>
        </button>
    </div>

    <%-- Hidden controls kept for compatibility --%>
    <asp:Literal ID="litAttachHd" runat="server" Visible="false" />
    <asp:Literal ID="litAttachName" runat="server" Visible="false" />
    <asp:HyperLink ID="lnkAttach" runat="server" Visible="false" />
    <asp:Literal ID="litAttachBtn" runat="server" Visible="false" />
    <asp:Panel ID="pnlAttachEmpty" runat="server" Visible="false" />
    <asp:Literal ID="litAttachEmpty" runat="server" Visible="false" />
    <asp:Panel ID="pnlMats" runat="server" Visible="false" />
    <asp:Panel ID="pnlMatsEmpty" runat="server" Visible="false" />
    <asp:Literal ID="litMatHd" runat="server" Visible="false" />
    <asp:Literal ID="litMatsEmpty" runat="server" Visible="false" />
    <asp:Repeater ID="rptMats" runat="server" Visible="false" />

    <%-- Navigation: Previous / Next --%>
    <div class="st-lesson-nav">
        <asp:HyperLink ID="lnkPrev" runat="server" CssClass="st-lesson-nav-btn st-lesson-nav-prev" Visible="false">
            <i class="bi bi-arrow-left"></i> <asp:Literal ID="litPrevBtn" runat="server" Text="Previous" />
        </asp:HyperLink>
        <asp:LinkButton ID="btnNext" runat="server" CssClass="st-lesson-nav-btn st-lesson-nav-next" Visible="false" OnClick="btnNext_Click">
            <asp:Literal ID="litNextBtn" runat="server" Text="Next" /> <i class="bi bi-arrow-right"></i>
        </asp:LinkButton>
    </div>

    <%-- Mark Complete (hidden, kept for existing logic) --%>
    <div style="display:none;">
        <asp:Literal ID="litCompleteTitle" runat="server" />
        <asp:Literal ID="litCompleteSub" runat="server" />
        <asp:Button ID="btnComplete" runat="server" OnClick="btnComplete_Click" CausesValidation="false" />
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
