<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PersonalityTest.aspx.cs"
    Inherits="ScienceBuddy.Student.PersonalityTest1" MasterPageFile="~/Site.Master" Title="Personality Test" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Student.css") %>" rel="stylesheet" />
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
       <div class="sb-nav-section">
        <div class="sb-nav-section-label">Main</div>
        <a href="<%: ResolveUrl("~/Student/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label">Dashboard</span></a>
        <a href="<%: ResolveUrl("~/Student/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span></a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Learn</div>
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label">My Learning</span></a>
        <a href="<%: ResolveUrl("~/Student/PracticeLibrary.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label">Practice Library</span></a>
        <a href="<%: ResolveUrl("~/Student/QuizHistory.aspx") %>" class="sb-sidebar-item"><i class="bi bi-clock-history item-icon"></i><span class="item-label">Quiz History</span></a>
        <a href="<%: ResolveUrl("~/Student/VirtualLabs.aspx") %>" class="sb-sidebar-item"><i class="bi bi-eyedropper item-icon"></i><span class="item-label">Virtual Labs</span></a>
        <a href="<%: ResolveUrl("~/Student/LiveSessions.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label">Live Sessions</span></a>
        <a href="<%: ResolveUrl("~/Student/AIStudyCompanion.aspx") %>" class="sb-sidebar-item"><i class="bi bi-robot item-icon"></i><span class="item-label">AI Study Companion</span></a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Communication</div>
        <a href="<%: ResolveUrl("~/Student/Messages.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label">Messages</span></a>
        <a href="<%: ResolveUrl("~/Student/Forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-people item-icon"></i><span class="item-label">Forum</span></a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Progress</div>
        <a href="<%: ResolveUrl("~/Student/ProgressRewards.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-bar-chart-line item-icon"></i><span class="item-label">Progress &amp; Rewards</span></a>
        <a href="<%: ResolveUrl("~/Student/MyRanking.aspx") %>" class="sb-sidebar-item"><i class="bi bi-trophy item-icon"></i><span class="item-label">My Ranking</span></a>
        <a href="<%: ResolveUrl("~/Student/RevisionPlan.aspx") %>" class="sb-sidebar-item"><i class="bi bi-calendar-check item-icon"></i><span class="item-label">Revision Plan</span></a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Student/MyProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><asp:Literal ID="litPageTitle" runat="server" Text="Personality Test" /></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<asp:Panel ID="pnlQuiz" runat="server">
<%-- Hero --%>
<div class="st-perstest-hero">
    <i class="bi bi-stars st-perstest-hero-deco"></i><i class="bi bi-lightbulb-fill st-perstest-hero-deco"></i><i class="bi bi-mortarboard-fill st-perstest-hero-deco"></i>
    <h1><i class="bi bi-stars"></i> <asp:Literal ID="litHeroTitle" runat="server" /></h1>
    <p><asp:Literal ID="litHeroSub" runat="server" /></p>
</div>

<%-- Main --%>
<div class="st-perstest-main">
    <%-- Buddy --%>
    <div class="st-perstest-buddy">
        <div class="st-perstest-buddy-blob">
            <asp:Image ID="imgMascot" runat="server" ImageUrl="~/Images/Personality/achiever.png" AlternateText="Buddy" />
            <span class="st-perstest-sticker">XP</span>
            <span class="st-perstest-sticker">Quiz</span>
            <span class="st-perstest-sticker">Lab</span>
            <span class="st-perstest-sticker">Badge</span>
        </div>
        <div class="st-perstest-speech" id="buddySpeech"><asp:Literal ID="litBubble" runat="server" /></div>
        <div class="st-perstest-vibe" id="vibeText"><asp:Literal ID="litPreview" runat="server" /></div>
    </div>

    <%-- Sliders --%>
    <div class="st-perstest-sliders">
        <div class="st-perstest-row"><div class="st-perstest-row-icon" style="background:#DBEAFE;color:#2563EB;"><i class="bi bi-speedometer2"></i></div><div class="st-perstest-row-body"><div class="st-perstest-row-name"><asp:Literal ID="litS1" runat="server" /></div><div class="st-perstest-row-hint"><asp:Literal ID="litH1" runat="server" /></div><div class="st-perstest-row-scale"><span class="st-perstest-row-lbl"><asp:Literal ID="litS1L" runat="server" /></span><div class="st-perstest-pills" data-name="slider1"><div class="st-perstest-pill" data-v="1"></div><div class="st-perstest-pill" data-v="2"></div><div class="st-perstest-pill active" data-v="3"></div><div class="st-perstest-pill" data-v="4"></div><div class="st-perstest-pill" data-v="5"></div></div><span class="st-perstest-row-lbl r"><asp:Literal ID="litS1R" runat="server" /></span></div></div></div>
        <div class="st-perstest-row"><div class="st-perstest-row-icon" style="background:#FFF0E8;color:#FF6B2C;"><i class="bi bi-bullseye"></i></div><div class="st-perstest-row-body"><div class="st-perstest-row-name"><asp:Literal ID="litS2" runat="server" /></div><div class="st-perstest-row-hint"><asp:Literal ID="litH2" runat="server" /></div><div class="st-perstest-row-scale"><span class="st-perstest-row-lbl"><asp:Literal ID="litS2L" runat="server" /></span><div class="st-perstest-pills" data-name="slider2"><div class="st-perstest-pill" data-v="1"></div><div class="st-perstest-pill" data-v="2"></div><div class="st-perstest-pill active" data-v="3"></div><div class="st-perstest-pill" data-v="4"></div><div class="st-perstest-pill" data-v="5"></div></div><span class="st-perstest-row-lbl r"><asp:Literal ID="litS2R" runat="server" /></span></div></div></div>
        <div class="st-perstest-row"><div class="st-perstest-row-icon" style="background:#F3E8FF;color:#7C3AED;"><i class="bi bi-lightbulb"></i></div><div class="st-perstest-row-body"><div class="st-perstest-row-name"><asp:Literal ID="litS3" runat="server" /></div><div class="st-perstest-row-hint"><asp:Literal ID="litH3" runat="server" /></div><div class="st-perstest-row-scale"><span class="st-perstest-row-lbl"><asp:Literal ID="litS3L" runat="server" /></span><div class="st-perstest-pills" data-name="slider3"><div class="st-perstest-pill" data-v="1"></div><div class="st-perstest-pill" data-v="2"></div><div class="st-perstest-pill active" data-v="3"></div><div class="st-perstest-pill" data-v="4"></div><div class="st-perstest-pill" data-v="5"></div></div><span class="st-perstest-row-lbl r"><asp:Literal ID="litS3R" runat="server" /></span></div></div></div>
        <div class="st-perstest-row"><div class="st-perstest-row-icon" style="background:#DCFCE7;color:#15803D;"><i class="bi bi-emoji-smile"></i></div><div class="st-perstest-row-body"><div class="st-perstest-row-name"><asp:Literal ID="litS4" runat="server" /></div><div class="st-perstest-row-hint"><asp:Literal ID="litH4" runat="server" /></div><div class="st-perstest-row-scale"><span class="st-perstest-row-lbl"><asp:Literal ID="litS4L" runat="server" /></span><div class="st-perstest-pills" data-name="slider4"><div class="st-perstest-pill" data-v="1"></div><div class="st-perstest-pill" data-v="2"></div><div class="st-perstest-pill active" data-v="3"></div><div class="st-perstest-pill" data-v="4"></div><div class="st-perstest-pill" data-v="5"></div></div><span class="st-perstest-row-lbl r"><asp:Literal ID="litS4R" runat="server" /></span></div></div></div>
        <div class="st-perstest-row"><div class="st-perstest-row-icon" style="background:#E0F2FE;color:#0369A1;"><i class="bi bi-people"></i></div><div class="st-perstest-row-body"><div class="st-perstest-row-name"><asp:Literal ID="litS5" runat="server" /></div><div class="st-perstest-row-hint"><asp:Literal ID="litH5" runat="server" /></div><div class="st-perstest-row-scale"><span class="st-perstest-row-lbl"><asp:Literal ID="litS5L" runat="server" /></span><div class="st-perstest-pills" data-name="slider5"><div class="st-perstest-pill" data-v="1"></div><div class="st-perstest-pill" data-v="2"></div><div class="st-perstest-pill active" data-v="3"></div><div class="st-perstest-pill" data-v="4"></div><div class="st-perstest-pill" data-v="5"></div></div><span class="st-perstest-row-lbl r"><asp:Literal ID="litS5R" runat="server" /></span></div></div></div>
        <div class="st-perstest-row"><div class="st-perstest-row-icon" style="background:#FEF3C7;color:#92400E;"><i class="bi bi-controller"></i></div><div class="st-perstest-row-body"><div class="st-perstest-row-name"><asp:Literal ID="litS6" runat="server" /></div><div class="st-perstest-row-hint"><asp:Literal ID="litH6" runat="server" /></div><div class="st-perstest-row-scale"><span class="st-perstest-row-lbl"><asp:Literal ID="litS6L" runat="server" /></span><div class="st-perstest-pills" data-name="slider6"><div class="st-perstest-pill" data-v="1"></div><div class="st-perstest-pill" data-v="2"></div><div class="st-perstest-pill active" data-v="3"></div><div class="st-perstest-pill" data-v="4"></div><div class="st-perstest-pill" data-v="5"></div></div><span class="st-perstest-row-lbl r"><asp:Literal ID="litS6R" runat="server" /></span></div></div></div>
    </div>
</div>

<input type="hidden" name="slider1" value="3"/><input type="hidden" name="slider2" value="3"/><input type="hidden" name="slider3" value="3"/>
<input type="hidden" name="slider4" value="3"/><input type="hidden" name="slider5" value="3"/><input type="hidden" name="slider6" value="3"/>

<div class="st-perstest-btn-area">
    <asp:Button ID="btnDiscover" runat="server" CssClass="st-perstest-btn" OnClick="btnDiscover_Click" CausesValidation="false" />
    <div class="st-perstest-btn-hint"><asp:Literal ID="litBtnHint" runat="server" /></div>
</div>
</asp:Panel>

<%-- Result --%>
<asp:Panel ID="pnlResult" runat="server" Visible="false">
<div class="st-perstest-res">
    <div class="st-perstest-res-bg"></div>
    <div class="st-perstest-confetti"><i class="bi bi-star-fill"></i><i class="bi bi-circle-fill"></i><i class="bi bi-diamond-fill"></i><i class="bi bi-heart-fill"></i><i class="bi bi-star-fill"></i><i class="bi bi-circle-fill"></i><i class="bi bi-diamond-fill"></i></div>
    <div class="st-perstest-res-unlock"><asp:Literal ID="litUnlock" runat="server" /></div>
    <div class="st-perstest-res-avatar"><asp:Image ID="imgResult" runat="server" AlternateText="Personality" /></div>
    <div class="st-perstest-res-name"><asp:Literal ID="litResultName" runat="server" /></div>
    <div class="st-perstest-res-desc"><asp:Literal ID="litResultDesc" runat="server" /></div>
    <div class="st-perstest-res-cards">
        <div class="st-perstest-res-card"><i class="bi bi-layout-text-sidebar-reverse"></i><div class="st-perstest-res-card-t"><asp:Literal ID="litCard1Title" runat="server" /></div><div class="st-perstest-res-card-v"><asp:Literal ID="litCard1Val" runat="server" /></div></div>
        <div class="st-perstest-res-card"><i class="bi bi-star-fill" style="color:#FF6B2C;"></i><div class="st-perstest-res-card-t"><asp:Literal ID="litCard2Title" runat="server" /></div><div class="st-perstest-res-card-v"><asp:Literal ID="litCard2Val" runat="server" /></div></div>
        <div class="st-perstest-res-card"><i class="bi bi-lightbulb-fill" style="color:#FFD84D;"></i><div class="st-perstest-res-card-t"><asp:Literal ID="litCard3Title" runat="server" /></div><div class="st-perstest-res-card-v"><asp:Literal ID="litCard3Val" runat="server" /></div></div>
    </div>
    <div class="st-perstest-res-btns">
        <a href="<%: ResolveUrl("~/Student/Dashboard.aspx") %>" class="st-perstest-res-btn primary"><i class="bi bi-house-fill"></i> <asp:Literal ID="litResultBtn" runat="server" /></a>
        <a href="<%: ResolveUrl("~/Student/PersonalityTest.aspx") %>" class="st-perstest-res-btn secondary"><i class="bi bi-arrow-repeat"></i> <asp:Literal ID="litRetakeBtn" runat="server" /></a>
    </div>
</div>
</asp:Panel>

<script>
var msgs=['<%= T("Nice choice! Buddy is learning your style.","Pilihan bagus! Buddy sedang mempelajari gaya anda.") %>',
          '<%= T("Great! Your dashboard will feel more like you.","Hebat! Papan pemuka anda akan lebih sesuai.") %>',
          '<%= T("Awesome! Keep going!","Hebat! Teruskan!") %>',
          '<%= T("Buddy likes that choice!","Buddy suka pilihan itu!") %>'];
document.querySelectorAll('.st-perstest-pills').forEach(function(g){
    g.querySelectorAll('.st-perstest-pill').forEach(function(p){
        p.addEventListener('click',function(){
            g.querySelectorAll('.st-perstest-pill').forEach(function(x){x.classList.remove('active');});
            p.classList.add('active');
            document.querySelector('input[name="'+g.dataset.name+'"]').value=p.dataset.v;
            document.getElementById('buddySpeech').textContent=msgs[Math.floor(Math.random()*msgs.length)];
        });
    });
});
</script>
</asp:Content>
