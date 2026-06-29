<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="JourneyOfSandwich.aspx.cs"
    Inherits="ScienceBuddy.Student.Labs.JourneyOfSandwich" MasterPageFile="~/Site.Master" Title="Journey of a Sandwich" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--student:#FF6B2C;--student-light:#FFF0E8;--lab-color:#F59E0B;--lab-light:#FEF3C7;}
.lab-hero{background:linear-gradient(135deg,#F59E0B 0%,#FBBF24 100%);border-radius:var(--border-radius-xl);
    padding:var(--space-2xl);color:#fff;position:relative;overflow:hidden;margin-bottom:var(--space-xl);}
.lab-hero::before{content:'🥪';position:absolute;font-size:6rem;opacity:.1;top:10px;right:40px;}
.lab-hero-back{display:inline-flex;align-items:center;gap:6px;font-size:.875rem;font-weight:600;
    color:rgba(255,255,255,.8);text-decoration:none;margin-bottom:var(--space-md);}
.lab-hero-back:hover{color:#fff;text-decoration:none;}
.lab-hero-title{font-family:var(--font-primary);font-size:1.5rem;font-weight:800;margin-bottom:6px;}
.lab-hero-desc{font-size:.9375rem;opacity:.88;max-width:500px;line-height:1.5;margin-bottom:var(--space-md);}
.lab-hero-diff{display:inline-flex;align-items:center;gap:6px;padding:4px 12px;border-radius:var(--border-radius-full);
    font-size:.75rem;font-weight:700;background:rgba(255,255,255,.2);border:1.5px solid rgba(255,255,255,.3);}
.lab-stars{display:flex;gap:4px;margin-bottom:var(--space-xl);}
.lab-star{width:36px;height:36px;border-radius:50%;display:flex;align-items:center;justify-content:center;
    font-size:1.125rem;border:2px solid var(--border-color);background:var(--color-white);transition:all .3s;}
.lab-star.earned{background:#FFD84D;border-color:#FFAB2C;box-shadow:0 2px 8px rgba(255,171,44,.4);}
.lab-section{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);
    box-shadow:var(--shadow-sm);padding:var(--space-xl);margin-bottom:var(--space-xl);}
.lab-section-title{font-family:var(--font-primary);font-size:1.125rem;font-weight:800;color:var(--color-text);
    margin-bottom:var(--space-md);display:flex;align-items:center;gap:var(--space-sm);}
.lab-instruction{font-size:.9375rem;color:var(--color-text-secondary);line-height:1.6;margin-bottom:var(--space-lg);
    padding:var(--space-md);background:var(--lab-light);border-radius:var(--border-radius);border-left:4px solid var(--lab-color);}

/* Digestive Path */
.digest-path{display:flex;flex-direction:column;align-items:center;gap:0;margin-bottom:var(--space-lg);}
.digest-stage{width:100%;max-width:400px;padding:var(--space-md) var(--space-lg);border-radius:var(--border-radius-xl);
    border:2px solid var(--border-color);background:var(--color-white);text-align:center;cursor:pointer;
    transition:all .2s;position:relative;}
.digest-stage:hover{border-color:var(--lab-color);transform:scale(1.02);}
.digest-stage.active{border-color:var(--lab-color);background:var(--lab-light);box-shadow:0 4px 12px rgba(245,158,11,.2);}
.digest-stage.visited{border-color:#22C55E;background:#F0FDF4;}
.digest-stage.locked{opacity:.5;cursor:not-allowed;}
.digest-stage .stage-icon{font-size:1.5rem;margin-bottom:4px;}
.digest-stage .stage-name{font-weight:700;font-size:.9375rem;}
.digest-arrow{font-size:1.25rem;color:var(--lab-color);padding:4px 0;}

/* Stage Detail */
.stage-detail{background:var(--lab-light);border-radius:var(--border-radius-xl);padding:var(--space-xl);
    margin-bottom:var(--space-lg);display:none;border:2px solid var(--lab-color);}
.stage-detail.show{display:block;}
.stage-detail-title{font-family:var(--font-primary);font-size:1.125rem;font-weight:800;margin-bottom:var(--space-sm);}
.stage-detail-text{font-size:.9375rem;line-height:1.7;color:var(--color-text-secondary);}
.stage-next-btn{margin-top:var(--space-md);padding:8px 20px;border-radius:var(--border-radius);
    border:2px solid var(--lab-color);background:var(--lab-color);color:#fff;font-weight:700;cursor:pointer;transition:all .2s;}
.stage-next-btn:hover{background:#D97706;}

/* Quiz */
.quiz-area{margin-top:var(--space-lg);}
.quiz-q{font-weight:700;font-size:1rem;margin-bottom:var(--space-md);}
.quiz-options{display:flex;flex-direction:column;gap:var(--space-sm);margin-bottom:var(--space-lg);}
.quiz-opt{padding:12px 16px;border-radius:var(--border-radius);border:2px solid var(--border-color);
    background:var(--color-white);cursor:pointer;font-weight:600;font-size:.875rem;transition:all .2s;}
.quiz-opt:hover{border-color:var(--lab-color);background:var(--lab-light);}
.quiz-opt.correct{border-color:#22C55E;background:#DCFCE7;}
.quiz-opt.wrong{border-color:#EF4444;background:#FEE2E2;}
.quiz-opt.disabled{pointer-events:none;opacity:.7;}

.lab-feedback{text-align:center;padding:var(--space-lg);border-radius:var(--border-radius);
    font-weight:700;font-size:.9375rem;margin-bottom:var(--space-md);display:none;}
.lab-feedback.show{display:block;}
.lab-feedback.correct{background:#DCFCE7;color:#15803D;}
.lab-feedback.wrong{background:#FEE2E2;color:#B91C1C;}
.lab-complete-bar{display:flex;align-items:center;justify-content:center;gap:var(--space-md);margin-bottom:var(--space-xl);}
@media(max-width:767px){.digest-stage{max-width:100%;}}
</style>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label">Main</div>
        <a href="<%: ResolveUrl("~/Student/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label">Dashboard</span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Learn</div>
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label">My Learning</span></a>
        <a href="<%: ResolveUrl("~/Student/VirtualLabs.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-eyedropper item-icon"></i><span class="item-label">Virtual Labs</span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Student/Profile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a></div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><asp:Literal ID="litPageTitle" runat="server" Text="Journey of a Sandwich" /></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="lab-section" style="text-align:center;padding:var(--space-3xl);">
        <div style="font-size:3rem;margin-bottom:var(--space-md);">🥪</div>
        <div style="font-family:var(--font-primary);font-size:1.25rem;font-weight:800;margin-bottom:var(--space-sm);"><asp:Literal ID="litErrorTitle" runat="server" /></div>
        <div style="color:var(--color-text-secondary);margin-bottom:var(--space-lg);"><asp:Literal ID="litErrorDesc" runat="server" /></div>
        <a href="<%: ResolveUrl("~/Student/VirtualLabs.aspx") %>" class="sb-btn sb-btn-primary sb-btn-sm"><i class="bi bi-arrow-left"></i> <asp:Literal ID="litErrorBtn" runat="server" /></a>
    </div>
</asp:Panel>

<asp:Panel ID="pnlMain" runat="server">

<div class="lab-hero">
    <a href="<%: ResolveUrl("~/Student/VirtualLabs.aspx") %>" class="lab-hero-back"><i class="bi bi-arrow-left"></i> <asp:Literal ID="litBack" runat="server" /></a>
    <div class="lab-hero-title"><asp:Literal ID="litLabTitle" runat="server" /></div>
    <div class="lab-hero-desc"><asp:Literal ID="litLabDesc" runat="server" /></div>
    <div class="lab-hero-diff"><i class="bi bi-speedometer2"></i> <asp:Literal ID="litDiff" runat="server" /></div>
</div>

<%-- Stars --%>
<div class="lab-stars" id="starsBar">
    <div class="lab-star" id="star1">⭐</div>
    <div class="lab-star" id="star2">⭐</div>
    <div class="lab-star" id="star3">⭐</div>
</div>

<%-- Step 1: Digestive Journey --%>
<div class="lab-section" id="section1">
    <div class="lab-section-title"><i class="bi bi-1-circle-fill" style="color:#F59E0B;"></i> <asp:Literal ID="litStep1Title" runat="server" /></div>
    <div class="lab-instruction"><asp:Literal ID="litStep1Inst" runat="server" /></div>

    <div class="digest-path" id="digestPath">
        <div class="digest-stage active" id="stage0" onclick="clickStage(0)"><div class="stage-icon">👄</div><div class="stage-name"><asp:Literal ID="litStage0" runat="server" Text="Mouth" /></div></div>
        <div class="digest-arrow">⬇️</div>
        <div class="digest-stage locked" id="stage1" onclick="clickStage(1)"><div class="stage-icon">🔽</div><div class="stage-name"><asp:Literal ID="litStage1" runat="server" Text="Esophagus" /></div></div>
        <div class="digest-arrow">⬇️</div>
        <div class="digest-stage locked" id="stage2" onclick="clickStage(2)"><div class="stage-icon">🫙</div><div class="stage-name"><asp:Literal ID="litStage2" runat="server" Text="Stomach" /></div></div>
        <div class="digest-arrow">⬇️</div>
        <div class="digest-stage locked" id="stage3" onclick="clickStage(3)"><div class="stage-icon">🌀</div><div class="stage-name"><asp:Literal ID="litStage3" runat="server" Text="Small Intestine" /></div></div>
        <div class="digest-arrow">⬇️</div>
        <div class="digest-stage locked" id="stage4" onclick="clickStage(4)"><div class="stage-icon">💧</div><div class="stage-name"><asp:Literal ID="litStage4" runat="server" Text="Large Intestine" /></div></div>
        <div class="digest-arrow">⬇️</div>
        <div class="digest-stage locked" id="stage5" onclick="clickStage(5)"><div class="stage-icon">🚪</div><div class="stage-name"><asp:Literal ID="litStage5" runat="server" Text="Anus" /></div></div>
    </div>

    <div class="stage-detail" id="stageDetail">
        <div class="stage-detail-title" id="stageDetailTitle"></div>
        <div class="stage-detail-text" id="stageDetailText"></div>
        <button type="button" class="stage-next-btn" id="stageNextBtn" onclick="nextStage()"><asp:Literal ID="litNextBtn" runat="server" Text="Next →" /></button>
    </div>
    <div class="lab-feedback" id="pathFeedback"></div>
</div>

<%-- Step 2: Quiz --%>
<div class="lab-section" id="section2" style="display:none;">
    <div class="lab-section-title"><i class="bi bi-2-circle-fill" style="color:#F59E0B;"></i> <asp:Literal ID="litStep2Title" runat="server" /></div>
    <div class="lab-instruction"><asp:Literal ID="litStep2Inst" runat="server" /></div>
    <div class="quiz-area" id="quizArea"></div>
    <div class="lab-feedback" id="quizFeedback"></div>
</div>

<%-- Complete --%>
<div class="lab-complete-bar">
    <asp:Button ID="btnComplete" runat="server" CssClass="sb-btn sb-btn-orange" OnClick="btnComplete_Click" CausesValidation="false" Enabled="false" />
</div>

<asp:Panel ID="pnlSuccess" runat="server" Visible="false">
    <div class="sb-alert sb-alert-success"><i class="bi bi-check-circle-fill alert-icon"></i>
        <div class="alert-content"><asp:Literal ID="litSuccess" runat="server" /></div></div>
</asp:Panel>

<asp:HiddenField ID="hfScore" runat="server" Value="0" />
<asp:HiddenField ID="hfStars" runat="server" Value="0" />

</asp:Panel>
</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
var lang='<%= CurrentLanguage %>';
var starsEarned=0, currentStage=0, visitedStages=0, quizCorrect=0, totalQuiz=3;

var stages=[
    {icon:'👄',nameEN:'Mouth',nameBM:'Mulut',
     descEN:'Food is chewed by teeth and mixed with saliva. Saliva contains enzymes that start breaking down starch into sugar.',
     descBM:'Makanan dikunyah oleh gigi dan dicampur dengan air liur. Air liur mengandungi enzim yang mula memecahkan kanji menjadi gula.'},
    {icon:'🔽',nameEN:'Esophagus',nameBM:'Esofagus',
     descEN:'The food ball (bolus) travels down the esophagus through wave-like muscle contractions called peristalsis.',
     descBM:'Bebola makanan (bolus) bergerak turun melalui esofagus dengan pengecutan otot seperti gelombang yang dipanggil peristalsis.'},
    {icon:'🫙',nameEN:'Stomach',nameBM:'Perut',
     descEN:'Strong acid and enzymes break food into a thick liquid called chyme. The stomach churns for 2-4 hours.',
     descBM:'Asid kuat dan enzim memecahkan makanan menjadi cecair pekat yang dipanggil kim. Perut mengaduk selama 2-4 jam.'},
    {icon:'🌀',nameEN:'Small Intestine',nameBM:'Usus Kecil',
     descEN:'Nutrients are absorbed through tiny finger-like projections called villi into the blood. This is where most digestion happens!',
     descBM:'Nutrien diserap melalui unjuran kecil seperti jari yang dipanggil vili ke dalam darah. Di sinilah kebanyakan pencernaan berlaku!'},
    {icon:'💧',nameEN:'Large Intestine',nameBM:'Usus Besar',
     descEN:'Water is absorbed from the remaining waste. Helpful bacteria live here and produce vitamins.',
     descBM:'Air diserap daripada sisa bahan buangan. Bakteria berguna hidup di sini dan menghasilkan vitamin.'},
    {icon:'🚪',nameEN:'Anus',nameBM:'Anus',
     descEN:'Undigested waste is stored in the rectum and exits the body through the anus. Journey complete!',
     descBM:'Sisa yang tidak dicerna disimpan dalam rektum dan keluar dari badan melalui anus. Perjalanan selesai!'}
];

var quizData=[
    {qEN:'Where does most nutrient absorption happen?',qBM:'Di mana kebanyakan penyerapan nutrien berlaku?',
     opts:[{en:'Stomach',bm:'Perut'},{en:'Small Intestine',bm:'Usus Kecil'},{en:'Large Intestine',bm:'Usus Besar'}],ans:1},
    {qEN:'What is the wave-like muscle movement called?',qBM:'Apakah nama pergerakan otot seperti gelombang?',
     opts:[{en:'Peristalsis',bm:'Peristalsis'},{en:'Digestion',bm:'Pencernaan'},{en:'Absorption',bm:'Penyerapan'}],ans:0},
    {qEN:'What does the large intestine mainly absorb?',qBM:'Apakah yang diserap oleh usus besar?',
     opts:[{en:'Protein',bm:'Protein'},{en:'Fat',bm:'Lemak'},{en:'Water',bm:'Air'}],ans:2}
];

function clickStage(idx){
    if(idx>currentStage)return;
    showStageDetail(idx);
}

function showStageDetail(idx){
    var s=stages[idx];
    var det=document.getElementById('stageDetail');
    det.className='stage-detail show';
    document.getElementById('stageDetailTitle').textContent=s.icon+' '+(lang==='BM'?s.nameBM:s.nameEN);
    document.getElementById('stageDetailText').textContent=lang==='BM'?s.descBM:s.descEN;
    document.getElementById('stageNextBtn').style.display=(idx<5)?'inline-block':'none';

    document.querySelectorAll('.digest-stage').forEach(function(el){el.classList.remove('active');});
    document.getElementById('stage'+idx).classList.add('active');
}

function nextStage(){
    var el=document.getElementById('stage'+currentStage);
    el.classList.remove('active'); el.classList.add('visited');
    currentStage++;
    visitedStages++;
    if(currentStage<=5){
        var next=document.getElementById('stage'+currentStage);
        next.classList.remove('locked'); next.classList.add('active');
        showStageDetail(currentStage);
    }

    if(currentStage===1&&starsEarned<1) earnStar(1);

    if(currentStage>=5){
        document.getElementById('stage5').classList.remove('locked');
        document.getElementById('stage5').classList.add('visited');
        var fb=document.getElementById('pathFeedback');
        fb.className='lab-feedback show correct';
        fb.textContent=lang==='BM'?'⭐ Tahniah! Anda telah menjelajah semua peringkat!':'⭐ Great! You explored all stages!';
        if(starsEarned<2) earnStar(2);
        document.getElementById('stageDetail').className='stage-detail';
        showQuiz();
    }
}

function showQuiz(){
    document.getElementById('section2').style.display='block';
    var area=document.getElementById('quizArea');
    area.innerHTML='';
    quizData.forEach(function(q,qi){
        var div=document.createElement('div');
        div.innerHTML='<div class="quiz-q">'+(qi+1)+'. '+(lang==='BM'?q.qBM:q.qEN)+'</div><div class="quiz-options" id="qopts'+qi+'"></div>';
        area.appendChild(div);
        var opts=div.querySelector('.quiz-options');
        q.opts.forEach(function(o,oi){
            var btn=document.createElement('div');
            btn.className='quiz-opt';
            btn.textContent=lang==='BM'?o.bm:o.en;
            btn.onclick=function(){answerQuiz(qi,oi,btn);};
            opts.appendChild(btn);
        });
    });
}

function answerQuiz(qi,oi,btn){
    var opts=document.getElementById('qopts'+qi).querySelectorAll('.quiz-opt');
    if(opts[0].classList.contains('disabled'))return;
    opts.forEach(function(o){o.classList.add('disabled');});
    if(oi===quizData[qi].ans){btn.classList.add('correct');quizCorrect++;}
    else{btn.classList.add('wrong');opts[quizData[qi].ans].classList.add('correct');}

    var answered=document.querySelectorAll('.quiz-opt.disabled').length/3;
    if(answered>=totalQuiz){
        var fb=document.getElementById('quizFeedback');
        if(quizCorrect>=totalQuiz){
            fb.className='lab-feedback show correct';
            fb.textContent=lang==='BM'?'🎉 Semua betul! Cemerlang!':'🎉 All correct! Excellent!';
            if(starsEarned<3) earnStar(3);
        } else {
            fb.className='lab-feedback show wrong';
            fb.textContent=(lang==='BM'?'Anda dapat ':'You got ')+quizCorrect+'/'+totalQuiz+(lang==='BM'?' betul.'  :' correct.');
        }
        enableComplete();
    }
}

function earnStar(n){
    if(n>starsEarned){starsEarned=n;
        for(var i=1;i<=starsEarned;i++){document.getElementById('star'+i).classList.add('earned');}
        document.getElementById('<%= hfStars.ClientID %>').value=starsEarned;
        var score=starsEarned===3?100:(starsEarned===2?70:40);
        document.getElementById('<%= hfScore.ClientID %>').value=score;
    }
}

function enableComplete(){document.getElementById('<%= btnComplete.ClientID %>').disabled=false;}

// Auto-show first stage
document.addEventListener('DOMContentLoaded',function(){showStageDetail(0);});
</script>
</asp:Content>
