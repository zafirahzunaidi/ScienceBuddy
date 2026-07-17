<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="JourneyOfSandwich.aspx.cs"
    Inherits="ScienceBuddy.Student.Labs.JourneyOfSandwich" MasterPageFile="~/Site.Master" Title="Journey of a Sandwich" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--lab:#F97316;--lab-light:#FFF7ED;--lab-dark:#C2410C;--lab-green:#22C55E;--lab-blue:#0EA5E9;}

.js-hero{background:linear-gradient(135deg,#F97316 0%,#FBBF24 100%);border-radius:var(--border-radius-xl);
    padding:var(--space-xl) var(--space-2xl);color:#fff;position:relative;overflow:hidden;margin-bottom:var(--space-xl);}
.js-hero-back{display:inline-flex;align-items:center;gap:6px;font-size:.8rem;font-weight:600;
    color:rgba(255,255,255,.8);text-decoration:none;margin-bottom:var(--space-sm);}
.js-hero-back:hover{color:#fff;text-decoration:none;}
.js-hero-title{font-family:var(--font-primary);font-size:1.375rem;font-weight:800;margin-bottom:4px;}
.js-hero-desc{font-size:.875rem;opacity:.9;max-width:500px;line-height:1.4;}
.js-hero-diff{display:inline-flex;align-items:center;gap:4px;padding:3px 10px;border-radius:var(--border-radius-full);
    font-size:.7rem;font-weight:700;background:rgba(255,255,255,.2);margin-top:var(--space-sm);}

/* Progress Tracker */
.js-progress{display:flex;align-items:center;justify-content:center;gap:0;margin-bottom:var(--space-xl);flex-wrap:wrap;padding:0 var(--space-md);}
.js-prog-step{display:flex;flex-direction:column;align-items:center;gap:4px;position:relative;min-width:70px;}
.js-prog-dot{width:32px;height:32px;border-radius:50%;border:2.5px solid var(--border-color);background:#fff;
    display:flex;align-items:center;justify-content:center;font-size:.75rem;font-weight:700;
    color:var(--color-text-muted);transition:all .3s;z-index:1;}
.js-prog-dot.active{border-color:var(--lab);background:var(--lab-light);color:var(--lab);box-shadow:0 0 0 4px rgba(249,115,22,.15);animation:js-glow 1.5s ease-in-out infinite;}
.js-prog-dot.done{border-color:var(--lab-green);background:#DCFCE7;color:var(--lab-green);}
@keyframes js-glow{0%,100%{box-shadow:0 0 0 4px rgba(249,115,22,.15);}50%{box-shadow:0 0 0 8px rgba(249,115,22,.08);}}
.js-prog-label{font-size:.6rem;font-weight:600;color:var(--color-text-muted);text-align:center;max-width:60px;}
.js-prog-label.active{color:var(--lab);font-weight:700;}
.js-prog-label.done{color:var(--lab-green);}
.js-prog-line{width:20px;height:2px;background:var(--border-color);margin-bottom:18px;}
.js-prog-line.done{background:var(--lab-green);}

/* Lab Canvas */
.js-canvas{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);
    box-shadow:var(--shadow-md);padding:var(--space-2xl);margin-bottom:var(--space-xl);text-align:center;min-height:320px;
    position:relative;overflow:hidden;}
.js-canvas::before{content:'';position:absolute;inset:0;background:radial-gradient(ellipse at center,rgba(249,115,22,.03) 0%,transparent 70%);pointer-events:none;}

/* Food Visual */
.js-food{font-size:3.5rem;margin-bottom:var(--space-md);display:inline-block;transition:all .5s;animation:js-bounce .6s ease;}
@keyframes js-bounce{0%{transform:scale(0);}60%{transform:scale(1.2);}100%{transform:scale(1);}}

/* Organ Display */
.js-organ{margin-bottom:var(--space-lg);}
.js-organ-name{font-family:var(--font-primary);font-size:1.5rem;font-weight:800;color:var(--color-text);margin-bottom:var(--space-sm);}
.js-organ-icon{font-size:2.5rem;margin-bottom:var(--space-sm);display:block;}

/* Explanation Bubble */
.js-bubble{background:var(--lab-light);border:1.5px solid #FED7AA;border-radius:var(--border-radius-xl);
    padding:var(--space-md) var(--space-lg);max-width:500px;margin:0 auto var(--space-lg);
    font-size:.9rem;line-height:1.6;color:var(--color-text);text-align:left;position:relative;}
.js-bubble::before{content:'';position:absolute;top:-8px;left:50%;transform:translateX(-50%);
    border-left:8px solid transparent;border-right:8px solid transparent;border-bottom:8px solid #FED7AA;}
.js-bubble i{color:var(--lab);margin-right:6px;}

/* Animation effects */
.js-anim-chew{animation:js-shake .3s ease infinite;}
@keyframes js-shake{0%,100%{transform:rotate(0);}25%{transform:rotate(-3deg);}75%{transform:rotate(3deg);}}
.js-anim-down{animation:js-movedown 1s ease-in-out;}
@keyframes js-movedown{0%{transform:translateY(-20px);opacity:0;}100%{transform:translateY(0);opacity:1;}}
.js-anim-churn{animation:js-spin 2s linear infinite;}
@keyframes js-spin{0%{transform:rotate(0);}100%{transform:rotate(360deg);}}
.js-anim-sparkle{animation:js-twinkle 1s ease-in-out infinite;}
@keyframes js-twinkle{0%,100%{opacity:.5;transform:scale(.9);}50%{opacity:1;transform:scale(1.1);}}

/* Observation Table */
.js-obs{margin-bottom:var(--space-xl);}
.js-obs table{width:100%;border-collapse:separate;border-spacing:0;border-radius:var(--border-radius-lg);overflow:hidden;
    border:1.5px solid var(--border-color);font-size:.8125rem;}
.js-obs th{background:#FFF7ED;color:var(--lab-dark);padding:10px 12px;font-weight:700;text-align:left;border-bottom:1px solid var(--border-color);}
.js-obs td{padding:8px 12px;border-bottom:1px solid #F1F5F9;color:var(--color-text);}
.js-obs tr:last-child td{border-bottom:none;}
.js-obs tr.current{background:#FFFBEB;}
</style>
<style>
/* Checkpoint */
.js-checkpoint{background:#EFF6FF;border:1.5px solid #BFDBFE;border-radius:var(--border-radius-xl);
    padding:var(--space-lg);max-width:450px;margin:var(--space-md) auto var(--space-lg);text-align:left;}
.js-checkpoint-q{font-weight:700;font-size:.9rem;color:var(--color-text);margin-bottom:var(--space-sm);}
.js-checkpoint-opts{display:flex;flex-direction:column;gap:6px;}
.js-checkpoint-opt{padding:8px 14px;border:1.5px solid var(--border-color);border-radius:var(--border-radius);
    cursor:pointer;font-size:.8125rem;font-weight:600;transition:all .2s;background:#fff;}
.js-checkpoint-opt:hover{border-color:var(--lab-blue);background:#F0F9FF;}
.js-checkpoint-opt.correct{border-color:var(--lab-green);background:#DCFCE7;color:#15803D;}
.js-checkpoint-opt.wrong{border-color:#EF4444;background:#FEF2F2;color:#DC2626;}

/* Nav buttons */
.js-nav{display:flex;justify-content:center;gap:var(--space-md);flex-wrap:wrap;margin-bottom:var(--space-lg);}
.js-btn{display:inline-flex;align-items:center;gap:6px;padding:12px 24px;border-radius:var(--border-radius-full);
    font-weight:700;font-size:.9375rem;border:none;cursor:pointer;transition:all .2s;}
.js-btn-primary{background:var(--lab);color:#fff;box-shadow:0 4px 12px rgba(249,115,22,.3);}
.js-btn-primary:hover{background:var(--lab-dark);transform:translateY(-2px);}
.js-btn-secondary{background:#F3F4F6;color:var(--color-text);border:1.5px solid var(--border-color);}
.js-btn-secondary:hover{background:#E5E7EB;}
.js-btn:disabled{opacity:.5;cursor:not-allowed;transform:none!important;}

/* Completion */
.js-complete{text-align:center;padding:var(--space-xl);}
.js-complete-icon{font-size:4rem;margin-bottom:var(--space-md);}
.js-complete-title{font-family:var(--font-primary);font-size:1.5rem;font-weight:800;color:var(--color-text);margin-bottom:var(--space-sm);}
.js-complete-desc{font-size:.9rem;color:var(--color-text-secondary);margin-bottom:var(--space-lg);line-height:1.5;}
.js-summary{display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:var(--space-sm);margin-bottom:var(--space-xl);}
.js-summary-card{background:#FFF7ED;border:1.5px solid #FED7AA;border-radius:var(--border-radius-lg);
    padding:var(--space-md);text-align:center;}
.js-summary-card i{font-size:1.25rem;color:var(--lab);display:block;margin-bottom:4px;}
.js-summary-card span{font-size:.75rem;font-weight:600;color:var(--color-text);}

/* Stars */
.js-stars{display:flex;gap:4px;justify-content:center;margin-bottom:var(--space-xl);}
.js-star{width:36px;height:36px;border-radius:50%;display:flex;align-items:center;justify-content:center;
    font-size:1.1rem;border:2px solid var(--border-color);background:#fff;transition:all .3s;}
.js-star.earned{background:#FFD84D;border-color:#FFAB2C;box-shadow:0 2px 8px rgba(255,171,44,.4);}

/* Error */
.js-error{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);
    padding:var(--space-2xl);text-align:center;}

@media(max-width:767px){.js-canvas{padding:var(--space-xl);}.js-prog-step{min-width:50px;}.js-prog-dot{width:26px;height:26px;font-size:.65rem;}.js-summary{grid-template-columns:repeat(2,1fr);}}
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
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-book item-icon"></i><span class="item-label">My Learning</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/PracticeLibrary.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-patch-question item-icon"></i><span class="item-label">Practice Library</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/QuizHistory.aspx") %>" class="sb-sidebar-item active">
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

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><asp:Literal ID="litPageTitle" runat="server" Text="Journey of a Sandwich" /></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- Error --%>
<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="js-error">
        <div style="font-size:2.5rem;margin-bottom:var(--space-md);"><i class="bi bi-exclamation-triangle-fill" style="color:var(--lab);"></i></div>
        <div style="font-family:var(--font-primary);font-size:1.125rem;font-weight:700;margin-bottom:6px;"><asp:Literal ID="litErrorTitle" runat="server" /></div>
        <div style="color:var(--color-text-secondary);margin-bottom:var(--space-lg);"><asp:Literal ID="litErrorDesc" runat="server" /></div>
        <a href="<%: ResolveUrl("~/Student/VirtualLabs.aspx") %>" class="js-btn js-btn-primary"><i class="bi bi-arrow-left"></i> <asp:Literal ID="litErrorBtn" runat="server" /></a>
    </div>
</asp:Panel>

<%-- Main Lab --%>
<asp:Panel ID="pnlMain" runat="server">
<asp:HiddenField ID="hfScore" runat="server" Value="0" />

<%-- Hero --%>
<div class="js-hero">
    <a href="<%: ResolveUrl("~/Student/VirtualLabs.aspx") %>" class="js-hero-back"><i class="bi bi-arrow-left"></i> <asp:Literal ID="litBack" runat="server" /></a>
    <div class="js-hero-title"><asp:Literal ID="litLabTitle" runat="server" /></div>
    <div class="js-hero-desc"><asp:Literal ID="litLabDesc" runat="server" /></div>
    <div class="js-hero-diff"><i class="bi bi-speedometer"></i> <asp:Literal ID="litDiff" runat="server" /></div>
</div>

<%-- Stars --%>
<div class="js-stars">
    <div class="js-star" id="star1"><i class="bi bi-star-fill"></i></div>
    <div class="js-star" id="star2"><i class="bi bi-star-fill"></i></div>
    <div class="js-star" id="star3"><i class="bi bi-star-fill"></i></div>
</div>

<%-- Progress Tracker --%>
<div class="js-progress" id="progressTracker"></div>

<%-- Instruction --%>
<asp:Literal ID="litStep1Title" runat="server" Visible="false" />
<asp:Literal ID="litStep1Inst" runat="server" Visible="false" />
<asp:Literal ID="litStep2Title" runat="server" Visible="false" />
<asp:Literal ID="litStep2Inst" runat="server" Visible="false" />

<%-- Lab Canvas --%>
<div class="js-canvas" id="labCanvas"></div>

<%-- Observation Table --%>
<div class="js-obs">
    <table id="obsTable">
        <thead><tr><th id="thOrgan"></th><th id="thAction"></th><th id="thForm"></th><th id="thProcess"></th></tr></thead>
        <tbody id="obsBody"></tbody>
    </table>
</div>

<%-- Navigation --%>
<div class="js-nav">
    <button type="button" class="js-btn js-btn-secondary" id="btnReset" onclick="resetLab()"><i class="bi bi-arrow-counterclockwise"></i> <span id="lblReset"></span></button>
    <button type="button" class="js-btn js-btn-primary" id="btnNextStage" onclick="nextStage()"><i class="bi bi-arrow-right"></i> <asp:Literal ID="litNextBtn" runat="server" Text="Next" /></button>
</div>

<%-- Hidden stage labels from code-behind --%>
<asp:Literal ID="litStage0" runat="server" Visible="false" />
<asp:Literal ID="litStage1" runat="server" Visible="false" />
<asp:Literal ID="litStage2" runat="server" Visible="false" />
<asp:Literal ID="litStage3" runat="server" Visible="false" />
<asp:Literal ID="litStage4" runat="server" Visible="false" />
<asp:Literal ID="litStage5" runat="server" Visible="false" />

<%-- Complete --%>
<div style="text-align:center;margin-top:var(--space-md);">
    <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
        <div style="background:#DCFCE7;border:1.5px solid #BBF7D0;border-radius:var(--border-radius);padding:12px 18px;display:inline-block;font-weight:700;color:#15803D;margin-bottom:var(--space-md);">
            <i class="bi bi-check-circle-fill"></i> <asp:Literal ID="litSuccess" runat="server" />
        </div>
    </asp:Panel>
    <asp:Button ID="btnComplete" runat="server" CssClass="js-btn js-btn-primary" OnClick="btnComplete_Click" CausesValidation="false" style="display:none;" />
</div>

</asp:Panel>
</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
var lang='<%= CurrentLanguage %>';
var currentStage=-1;
var totalStages=6;
var checkpointAnswered={1:false,3:false};

var stages=[
    {nameEN:'Mouth',nameBM:'Mulut',food:'🥪➡️🍞',foodAnim:'js-anim-chew',icon:'bi-emoji-smile',
     explEN:'Teeth break food into smaller pieces. Saliva starts chemical digestion.',
     explBM:'Gigi memecahkan makanan kepada kepingan kecil. Air liur memulakan pencernaan kimia.',
     obsEN:['Mouth','Food is chewed','Small pieces','Mechanical'],obsBM:['Mulut','Makanan dikunyah','Kepingan kecil','Mekanikal']},
    {nameEN:'Esophagus',nameBM:'Esofagus',food:'⬇️🟤',foodAnim:'js-anim-down',icon:'bi-arrow-down-circle',
     explEN:'Muscles push food down to the stomach through peristalsis (wave-like movement).',
     explBM:'Otot menolak makanan turun ke perut melalui peristalsis (gerakan seperti gelombang).',
     obsEN:['Esophagus','Peristalsis pushes food','Food bolus','Mechanical'],obsBM:['Esofagus','Peristalsis menolak makanan','Bolus makanan','Mekanikal']},
    {nameEN:'Stomach',nameBM:'Perut',food:'🫧🟡',foodAnim:'js-anim-churn',icon:'bi-droplet-half',
     explEN:'Stomach acid and enzymes break food into a thick liquid called chyme.',
     explBM:'Asid perut dan enzim memecahkan makanan menjadi cecair pekat dipanggil kimus.',
     obsEN:['Stomach','Acid churns food','Liquid chyme','Chemical'],obsBM:['Perut','Asid mengaduk makanan','Kimus cecair','Kimia']},
    {nameEN:'Small Intestine',nameBM:'Usus Kecil',food:'✨🟢✨',foodAnim:'js-anim-sparkle',icon:'bi-stars',
     explEN:'Nutrients are absorbed into the blood through tiny villi on the intestine wall.',
     explBM:'Nutrien diserap ke dalam darah melalui vilus kecil di dinding usus.',
     obsEN:['Small Intestine','Nutrients absorbed','Nutrients + waste','Absorption'],obsBM:['Usus Kecil','Nutrien diserap','Nutrien + sisa','Penyerapan']},
    {nameEN:'Large Intestine',nameBM:'Usus Besar',food:'💧➡️🟫',foodAnim:'',icon:'bi-moisture',
     explEN:'Water is absorbed. The remaining waste becomes solid.',
     explBM:'Air diserap. Sisa yang tinggal menjadi pepejal.',
     obsEN:['Large Intestine','Water absorbed','Solid waste','Absorption'],obsBM:['Usus Besar','Air diserap','Sisa pepejal','Penyerapan']},
    {nameEN:'Anus',nameBM:'Anus',food:'🚽',foodAnim:'',icon:'bi-box-arrow-down',
     explEN:'Solid waste (faeces) leaves the body. The journey is complete!',
     explBM:'Sisa pepejal (najis) keluar dari badan. Perjalanan selesai!',
     obsEN:['Anus','Waste removed','Faeces','Excretion'],obsBM:['Anus','Sisa dikeluarkan','Najis','Perkumuhan']}
];

var checkpoints=[
    {afterStage:0,qEN:'Where is food first chewed?',qBM:'Di manakah makanan pertama kali dikunyah?',
     opts:[{en:'Mouth',bm:'Mulut',correct:true},{en:'Stomach',bm:'Perut',correct:false},{en:'Esophagus',bm:'Esofagus',correct:false}]},
    {afterStage:3,qEN:'Where are nutrients absorbed into the blood?',qBM:'Di manakah nutrien diserap ke dalam darah?',
     opts:[{en:'Stomach',bm:'Perut',correct:false},{en:'Small Intestine',bm:'Usus Kecil',correct:true},{en:'Large Intestine',bm:'Usus Besar',correct:false}]}
];

function T(en,bm){return lang==='BM'?bm:en;}

function initLab(){
    document.getElementById('thOrgan').textContent=T('Organ','Organ');
    document.getElementById('thAction').textContent=T('What Happens','Apa Berlaku');
    document.getElementById('thForm').textContent=T('Food Form','Bentuk Makanan');
    document.getElementById('thProcess').textContent=T('Process','Proses');
    document.getElementById('lblReset').textContent=T('Reset','Tetapkan Semula');
    buildProgress();
    showStart();
}

function buildProgress(){
    var html='';
    for(var i=0;i<totalStages;i++){
        var s=stages[i]; var cls=i<currentStage?'done':i===currentStage?'active':'';
        var lbl=lang==='BM'?s.nameBM:s.nameEN;
        html+='<div class="js-prog-step"><div class="js-prog-dot '+cls+'">'+(i<currentStage?'<i class="bi bi-check-lg"></i>':(i+1))+'</div><div class="js-prog-label '+cls+'">'+lbl+'</div></div>';
        if(i<totalStages-1) html+='<div class="js-prog-line'+(i<currentStage?' done':'')+'"></div>';
    }
    document.getElementById('progressTracker').innerHTML=html;
}

function showStart(){
    var cv=document.getElementById('labCanvas');
    cv.innerHTML='<div class="js-food" style="font-size:5rem;cursor:pointer;" onclick="nextStage()" title="'+T('Click to start!','Klik untuk mula!')+'">🥪</div>'+
        '<div style="font-size:1rem;font-weight:700;color:var(--color-text);margin-top:var(--space-sm);">'+T('Click the sandwich to start the journey!','Klik sandwic untuk memulakan perjalanan!')+'</div>';
    document.getElementById('btnNextStage').style.display='none';
}

function nextStage(){
    currentStage++;
    if(currentStage>=totalStages){showCompletion();return;}
    document.getElementById('btnNextStage').style.display='inline-flex';
    buildProgress();
    renderStage(currentStage);

    // Check for checkpoint after this stage
    var cp=checkpoints.find(function(c){return c.afterStage===currentStage;});
    if(cp && !checkpointAnswered[currentStage]){
        document.getElementById('btnNextStage').disabled=true;
        setTimeout(function(){showCheckpoint(cp,currentStage);},800);
    }
}

function renderStage(idx){
    var s=stages[idx];
    var name=lang==='BM'?s.nameBM:s.nameEN;
    var expl=lang==='BM'?s.explBM:s.explEN;
    var obs=lang==='BM'?s.obsBM:s.obsEN;

    var cv=document.getElementById('labCanvas');
    cv.innerHTML='<div class="js-organ"><span class="js-organ-icon"><i class="bi '+s.icon+'"></i></span>'+
        '<div class="js-organ-name">'+name+'</div></div>'+
        '<div class="js-food '+s.foodAnim+'">'+s.food+'</div>'+
        '<div class="js-bubble"><i class="bi bi-info-circle-fill"></i> '+expl+'</div>';

    // Add row to observation table
    var tbody=document.getElementById('obsBody');
    var tr=document.createElement('tr');
    tr.className='current';
    tr.innerHTML='<td><strong>'+obs[0]+'</strong></td><td>'+obs[1]+'</td><td>'+obs[2]+'</td><td>'+obs[3]+'</td>';
    // Remove current highlight from previous rows
    var rows=tbody.querySelectorAll('tr');rows.forEach(function(r){r.className='';});
    tbody.appendChild(tr);

    // Stars: 2 stages=1 star, 4=2, 6=3
    if(currentStage>=1)document.getElementById('star1').classList.add('earned');
    if(currentStage>=3)document.getElementById('star2').classList.add('earned');
    if(currentStage>=5)document.getElementById('star3').classList.add('earned');
}

function showCheckpoint(cp,stageIdx){
    var cv=document.getElementById('labCanvas');
    var q=lang==='BM'?cp.qBM:cp.qEN;
    var html='<div class="js-checkpoint"><div class="js-checkpoint-q"><i class="bi bi-question-circle-fill" style="color:var(--lab-blue);"></i> '+q+'</div><div class="js-checkpoint-opts">';
    cp.opts.forEach(function(opt,i){
        var label=lang==='BM'?opt.bm:opt.en;
        html+='<div class="js-checkpoint-opt" data-correct="'+opt.correct+'" onclick="answerCheckpoint(this,'+stageIdx+')">'+label+'</div>';
    });
    html+='</div></div>';
    cv.innerHTML+=html;
}

function answerCheckpoint(el,stageIdx){
    if(el.classList.contains('correct')||el.classList.contains('wrong'))return;
    var isCorrect=el.getAttribute('data-correct')==='true';
    el.classList.add(isCorrect?'correct':'wrong');
    if(isCorrect){
        checkpointAnswered[stageIdx]=true;
        document.getElementById('btnNextStage').disabled=false;
        // disable other options
        var siblings=el.parentElement.querySelectorAll('.js-checkpoint-opt');
        siblings.forEach(function(s){if(s!==el)s.style.pointerEvents='none';s.style.opacity=s===el?'1':'.5';});
    }
}

function showCompletion(){
    document.getElementById('btnNextStage').style.display='none';
    buildProgress();
    var cv=document.getElementById('labCanvas');
    cv.innerHTML='<div class="js-complete">'+
        '<div class="js-complete-icon"><i class="bi bi-trophy-fill" style="color:var(--lab);"></i></div>'+
        '<div class="js-complete-title">'+T('Journey Complete!','Perjalanan Selesai!')+'</div>'+
        '<div class="js-complete-desc">'+T('Great job! You followed the sandwich through the entire digestive system.','Tahniah! Anda telah mengikuti sandwic melalui keseluruhan sistem pencernaan.')+'</div>'+
        '<div class="js-summary">'+
            '<div class="js-summary-card"><i class="bi bi-gear-fill"></i><span>'+T('Mechanical Digestion','Pencernaan Mekanikal')+'</span></div>'+
            '<div class="js-summary-card"><i class="bi bi-droplet-fill"></i><span>'+T('Chemical Digestion','Pencernaan Kimia')+'</span></div>'+
            '<div class="js-summary-card"><i class="bi bi-stars"></i><span>'+T('Nutrient Absorption','Penyerapan Nutrien')+'</span></div>'+
            '<div class="js-summary-card"><i class="bi bi-box-arrow-down"></i><span>'+T('Waste Removal','Penyingkiran Sisa')+'</span></div>'+
        '</div></div>';

    // Show server-side complete button
    document.getElementById('<%= btnComplete.ClientID %>').style.display='inline-flex';
}

function resetLab(){
    currentStage=-1;
    checkpointAnswered={1:false,3:false};
    document.getElementById('obsBody').innerHTML='';
    document.getElementById('star1').classList.remove('earned');
    document.getElementById('star2').classList.remove('earned');
    document.getElementById('star3').classList.remove('earned');
    buildProgress();showStart();
}

document.addEventListener('DOMContentLoaded',initLab);
</script>
</asp:Content>
