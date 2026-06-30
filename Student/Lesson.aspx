<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Lesson.aspx.cs"
    Inherits="ScienceBuddy.Student.Lesson" MasterPageFile="~/Site.Master" Title="Lesson" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--student:#FF6B2C;--student-light:#FFF0E8;}
.ls-hero{background:linear-gradient(135deg,#1D4ED8 0%,#4DA8FF 100%);border-radius:var(--border-radius-xl);
    padding:var(--space-2xl);color:#fff;position:relative;overflow:hidden;margin-bottom:var(--space-xl);
    box-shadow:0 8px 32px rgba(37,99,235,.2);}
.ls-hero::before{content:'';position:absolute;width:260px;height:260px;border-radius:50%;
    background:rgba(255,255,255,.06);top:-80px;right:-50px;pointer-events:none;}
.ls-hero-back{display:inline-flex;align-items:center;gap:6px;font-size:.875rem;font-weight:600;
    color:rgba(255,255,255,.8);text-decoration:none;margin-bottom:var(--space-md);}
.ls-hero-back:hover{color:#fff;text-decoration:none;}
.ls-hero-crumb{font-size:.75rem;opacity:.7;margin-bottom:6px;display:flex;align-items:center;gap:4px;}
.ls-hero-title{font-family:var(--font-primary);font-size:1.5rem;font-weight:800;margin-bottom:6px;line-height:1.3;}
.ls-hero-badge{display:inline-flex;align-items:center;gap:6px;padding:5px 14px;border-radius:var(--border-radius-full);
    font-size:.8125rem;font-weight:700;margin-top:var(--space-sm);}
.ls-badge-done{background:rgba(34,197,94,.25);border:1.5px solid rgba(34,197,94,.5);color:#dcfce7;}
.ls-badge-pending{background:rgba(255,255,255,.2);border:1.5px solid rgba(255,255,255,.35);}

.ls-reading{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);
    box-shadow:var(--shadow-sm);padding:var(--space-2xl);margin-bottom:var(--space-xl);
    font-size:1.0625rem;line-height:1.85;color:var(--color-text);}
.ls-reading h1,.ls-reading h2,.ls-reading h3{font-family:var(--font-primary);color:var(--color-text);margin:var(--space-lg) 0 var(--space-md);}
.ls-reading p{margin-bottom:var(--space-md);}
.ls-reading img{border-radius:var(--border-radius);margin:var(--space-md) 0;max-width:100%;}
.ls-reading ul,.ls-reading ol{padding-left:var(--space-xl);margin-bottom:var(--space-md);}
.ls-reading li{margin-bottom:var(--space-sm);list-style:disc;}

.ls-tts{display:flex;gap:var(--space-sm);margin-bottom:var(--space-xl);flex-wrap:wrap;}

.ls-attach{background:var(--color-white);border-radius:var(--border-radius-lg);border:1.5px solid var(--border-color);
    box-shadow:var(--shadow-xs);padding:var(--space-lg);display:flex;align-items:center;gap:var(--space-md);
    margin-bottom:var(--space-xl);}
.ls-attach-icon{width:44px;height:44px;border-radius:var(--border-radius);background:#F0F7FF;color:#2563EB;
    display:flex;align-items:center;justify-content:center;font-size:1.25rem;flex-shrink:0;}
.ls-attach-name{flex:1;font-weight:600;font-size:.9375rem;color:var(--color-text);}

.ls-mats{margin-bottom:var(--space-xl);}
.ls-mat-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));gap:var(--space-md);}
.ls-mat-card{background:var(--color-white);border-radius:var(--border-radius-lg);border:1.5px solid var(--border-color);
    box-shadow:var(--shadow-sm);padding:var(--space-lg);display:flex;flex-direction:column;gap:var(--space-sm);
    transition:transform .2s,box-shadow .2s;}
.ls-mat-card:hover{transform:translateY(-2px);box-shadow:var(--shadow-md);}
.ls-mat-title{font-family:var(--font-primary);font-size:.9375rem;font-weight:700;color:var(--color-text);}
.ls-mat-meta{font-size:.75rem;color:var(--color-text-muted);display:flex;gap:var(--space-md);}

.ls-complete{background:var(--color-white);border-radius:var(--border-radius-xl);border:2px solid var(--border-color);
    padding:var(--space-xl);display:flex;align-items:center;gap:var(--space-lg);margin-bottom:var(--space-xl);}
.ls-complete-icon{width:56px;height:56px;border-radius:50%;display:flex;align-items:center;justify-content:center;
    font-size:1.5rem;flex-shrink:0;}
.ls-complete-body{flex:1;}
.ls-complete-title{font-family:var(--font-primary);font-size:1rem;font-weight:700;color:var(--color-text);}
.ls-complete-sub{font-size:.875rem;color:var(--color-text-secondary);margin-top:4px;}

.ls-sec-hd{display:flex;align-items:center;gap:var(--space-sm);margin-bottom:var(--space-md);}
.ls-sec-title{font-family:var(--font-primary);font-size:1.125rem;font-weight:800;color:var(--color-text);}

.ls-locked{background:var(--color-white);border-radius:var(--border-radius-xl);border:2px solid var(--border-color);
    padding:var(--space-3xl);text-align:center;}
.ls-locked-icon{font-size:3rem;margin-bottom:var(--space-md);}
.ls-locked-title{font-family:var(--font-primary);font-size:1.25rem;font-weight:800;margin-bottom:var(--space-sm);}
.ls-locked-desc{font-size:.9375rem;color:var(--color-text-secondary);margin-bottom:var(--space-lg);}

@media(max-width:767px){.ls-reading{padding:var(--space-xl) var(--space-lg);} .ls-complete{flex-direction:column;align-items:flex-start;}}
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
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><asp:Literal ID="litPageTitle" runat="server" Text="Lesson" /></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<asp:Panel ID="pnlLocked" runat="server" Visible="false">
    <div class="ls-locked"><div class="ls-locked-icon">🔒</div>
        <div class="ls-locked-title"><asp:Literal ID="litLockedTitle" runat="server" /></div>
        <div class="ls-locked-desc"><asp:Literal ID="litLockedDesc" runat="server" /></div>
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="sb-btn sb-btn-primary sb-btn-sm"><i class="bi bi-arrow-left"></i> <asp:Literal ID="litLockedBtn" runat="server" /></a>
    </div>
</asp:Panel>

<asp:Panel ID="pnlMain" runat="server">

<%-- Hero --%>
<div class="ls-hero">
    <asp:HyperLink ID="lnkBack" runat="server" CssClass="ls-hero-back"><i class="bi bi-arrow-left"></i> <asp:Literal ID="litBack" runat="server" /></asp:HyperLink>
    <div class="ls-hero-crumb"><asp:Literal ID="litCrumb" runat="server" /></div>
    <div class="ls-hero-title"><asp:Literal ID="litTitle" runat="server" /></div>
    <div class="ls-hero-badge <asp:Literal ID='litBadgeClass' runat='server' Text='ls-badge-pending' />">
        <i class="bi <asp:Literal ID='litBadgeIcon' runat='server' Text='bi-clock' />"></i>
        <asp:Literal ID="litBadgeText" runat="server" Text="—" />
    </div>
</div>

<%-- Reading card --%>
<div class="ls-reading" id="lessonContent">
    <asp:Literal ID="litContent" runat="server" />
</div>

<%-- Text-to-Speech --%>
<div class="ls-tts">
    <button type="button" id="btnTTS" class="sb-btn sb-btn-primary sb-btn-sm" onclick="toggleTTS()">
        <i class="bi bi-megaphone-fill"></i> <span id="ttsLabel"><asp:Literal ID="litTTSStart" runat="server" Text="Read Aloud" /></span>
    </button>
</div>

<%-- Attachment --%>
<asp:Panel ID="pnlAttach" runat="server" Visible="false">
    <div class="ls-sec-hd"><i class="bi bi-paperclip" style="color:var(--student);"></i><div class="ls-sec-title"><asp:Literal ID="litAttachHd" runat="server" /></div></div>
    <div class="ls-attach">
        <div class="ls-attach-icon"><i class="bi bi-file-earmark-fill"></i></div>
        <div class="ls-attach-name"><asp:Literal ID="litAttachName" runat="server" /></div>
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
    <div class="ls-sec-hd"><i class="bi bi-folder-fill" style="color:#B45309;"></i><div class="ls-sec-title"><asp:Literal ID="litMatHd" runat="server" /></div></div>
    <div class="ls-mat-grid">
        <asp:Repeater ID="rptMats" runat="server">
            <ItemTemplate>
                <div class="ls-mat-card">
                    <div class="ls-mat-title"><%# Eval("Title") %></div>
                    <div class="ls-mat-meta"><span><i class="bi bi-file-earmark"></i> <%# Eval("Type") %></span><span><i class="bi bi-translate"></i> <%# Eval("Lang") %></span></div>
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
<div class="ls-complete">
    <div class="ls-complete-icon" id="completeIcon" runat="server" style="background:#DCFCE7;color:#15803D;">
        <i class="bi bi-check-circle-fill"></i>
    </div>
    <div class="ls-complete-body">
        <div class="ls-complete-title"><asp:Literal ID="litCompleteTitle" runat="server" /></div>
        <div class="ls-complete-sub"><asp:Literal ID="litCompleteSub" runat="server" /></div>
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
