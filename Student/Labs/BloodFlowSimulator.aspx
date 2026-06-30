<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BloodFlowSimulator.aspx.cs"
    Inherits="ScienceBuddy.Student.Labs.BloodFlowSimulator" MasterPageFile="~/Site.Master" Title="Blood Flow Simulator" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--lab-red:#DC2626;--lab-blue:#1D4ED8;}
.lab-hero{background:linear-gradient(135deg,#DC2626 0%,#991B1B 100%);border-radius:var(--border-radius-xl);
    padding:var(--space-2xl);color:#fff;position:relative;overflow:hidden;margin-bottom:var(--space-xl);}
.lab-hero::before{content:'❤️';position:absolute;font-size:6rem;opacity:.1;top:10px;right:40px;}
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
    padding:var(--space-md);background:#FEF2F2;border-radius:var(--border-radius);border-left:4px solid #DC2626;}

/* Body diagram */
.body-diagram{position:relative;width:100%;max-width:500px;margin:0 auto var(--space-xl);padding:var(--space-xl);
    background:#FFF5F5;border-radius:var(--border-radius-xl);border:2px solid #FECACA;min-height:320px;}
.flow-node{position:absolute;padding:12px 18px;border-radius:var(--border-radius);font-weight:700;font-size:.875rem;
    cursor:pointer;transition:all .3s;border:2px solid var(--border-color);background:var(--color-white);text-align:center;}
.flow-node:hover{transform:scale(1.05);box-shadow:0 4px 16px rgba(0,0,0,.12);}
.flow-node.active{border-color:#DC2626;background:#FEE2E2;box-shadow:0 0 20px rgba(220,38,38,.3);animation:pulse 1.5s infinite;}
.flow-node.completed{border-color:#22C55E;background:#DCFCE7;cursor:default;}
.flow-node.locked{opacity:.5;cursor:not-allowed;}
.flow-node .node-icon{font-size:1.5rem;display:block;margin-bottom:4px;}
@keyframes pulse{0%,100%{box-shadow:0 0 10px rgba(220,38,38,.2);}50%{box-shadow:0 0 25px rgba(220,38,38,.5);}}

.flow-arrow{position:absolute;font-size:1.5rem;color:#DC2626;font-weight:700;}
.flow-arrow.blue{color:#1D4ED8;}

/* Blood drops */
.blood-legend{display:flex;gap:var(--space-lg);justify-content:center;margin-bottom:var(--space-lg);flex-wrap:wrap;}
.blood-drop{display:inline-flex;align-items:center;gap:6px;padding:6px 12px;border-radius:var(--border-radius-full);
    font-size:.8125rem;font-weight:600;}
.blood-drop.red{background:#FEE2E2;color:#DC2626;}
.blood-drop.blue{background:#DBEAFE;color:#1D4ED8;}

/* Quiz */
.quiz-area{margin-top:var(--space-xl);}
.quiz-q{font-weight:700;font-size:.9375rem;margin-bottom:var(--space-md);color:var(--color-text);}
.quiz-options{display:flex;flex-wrap:wrap;gap:var(--space-sm);margin-bottom:var(--space-lg);}
.quiz-opt{padding:10px 18px;border-radius:var(--border-radius);border:2px solid var(--border-color);
    background:var(--color-white);font-weight:600;font-size:.875rem;cursor:pointer;transition:all .2s;}
.quiz-opt:hover{border-color:#DC2626;background:#FEF2F2;}
.quiz-opt.correct{border-color:#22C55E;background:#DCFCE7;pointer-events:none;}
.quiz-opt.wrong{border-color:#EF4444;background:#FEE2E2;pointer-events:none;}

.lab-feedback{text-align:center;padding:var(--space-lg);border-radius:var(--border-radius);
    font-weight:700;font-size:.9375rem;margin-bottom:var(--space-md);display:none;}
.lab-feedback.show{display:block;}
.lab-feedback.correct{background:#DCFCE7;color:#15803D;}
.lab-feedback.wrong{background:#FEE2E2;color:#B91C1C;}
.lab-complete-bar{display:flex;align-items:center;justify-content:center;gap:var(--space-md);margin-bottom:var(--space-xl);}
@media(max-width:767px){.body-diagram{min-height:400px;}.flow-node{padding:8px 12px;font-size:.75rem;}}
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
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><asp:Literal ID="litPageTitle" runat="server" Text="Blood Flow Simulator" /></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="lab-section" style="text-align:center;padding:var(--space-3xl);">
        <div style="font-size:3rem;margin-bottom:var(--space-md);">❤️</div>
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

<%-- Step 1: Blood Flow Pathway --%>
<div class="lab-section" id="section1">
    <div class="lab-section-title"><i class="bi bi-1-circle-fill" style="color:#DC2626;"></i> <asp:Literal ID="litStep1Title" runat="server" /></div>
    <div class="lab-instruction"><asp:Literal ID="litStep1Inst" runat="server" /></div>

    <div class="blood-legend">
        <div class="blood-drop red">🔴 <asp:Literal ID="litOxyRich" runat="server" Text="Oxygen-rich (Red)" /></div>
        <div class="blood-drop blue">🔵 <asp:Literal ID="litCO2Rich" runat="server" Text="CO₂-rich (Blue)" /></div>
    </div>

    <div class="body-diagram" id="bodyDiagram">
        <div class="flow-node active" id="node0" style="top:20px;left:50%;transform:translateX(-50%);" onclick="clickNode(0)">
            <span class="node-icon">🫁</span><asp:Literal ID="litNode1" runat="server" Text="Lungs" />
        </div>
        <div class="flow-arrow" style="top:85px;left:50%;transform:translateX(-50%);">↓</div>
        <div class="flow-node locked" id="node1" style="top:110px;left:50%;transform:translateX(-50%);" onclick="clickNode(1)">
            <span class="node-icon">❤️</span><asp:Literal ID="litNode2" runat="server" Text="Heart" />
        </div>
        <div class="flow-arrow" style="top:185px;left:50%;transform:translateX(-50%);">↓</div>
        <div class="flow-node locked" id="node2" style="top:210px;left:50%;transform:translateX(-50%);" onclick="clickNode(2)">
            <span class="node-icon">🦵</span><asp:Literal ID="litNode3" runat="server" Text="Body" />
        </div>
        <div class="flow-arrow blue" style="top:285px;left:50%;transform:translateX(-50%);">↓</div>
        <div class="flow-node locked" id="node3" style="top:310px;left:30%;transform:translateX(-50%);" onclick="clickNode(3)">
            <span class="node-icon">❤️</span><asp:Literal ID="litNode4" runat="server" Text="Heart" />
        </div>
        <div class="flow-arrow blue" style="top:310px;left:70%;transform:translateX(-50%);">→</div>
        <div class="flow-node locked" id="node4" style="top:310px;left:70%;transform:translateX(-50%);" onclick="clickNode(4)">
            <span class="node-icon">🫁</span><asp:Literal ID="litNode5" runat="server" Text="Lungs" />
        </div>
    </div>

    <div class="lab-feedback" id="pathFeedback"></div>
</div>

<%-- Step 2: Quiz --%>
<div class="lab-section" id="section2" style="display:none;">
    <div class="lab-section-title"><i class="bi bi-2-circle-fill" style="color:#DC2626;"></i> <asp:Literal ID="litStep2Title" runat="server" /></div>
    <div class="lab-instruction"><asp:Literal ID="litStep2Inst" runat="server" /></div>

    <div class="quiz-area" id="quizArea">
        <div id="quiz1" class="quiz-q"></div>
        <div class="quiz-options" id="quiz1Opts"></div>
        <div id="quiz2" class="quiz-q" style="display:none;"></div>
        <div class="quiz-options" id="quiz2Opts" style="display:none;"></div>
        <div id="quiz3" class="quiz-q" style="display:none;"></div>
        <div class="quiz-options" id="quiz3Opts" style="display:none;"></div>
    </div>

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
var starsEarned=0, currentStep=0, pathComplete=false;
var quizCorrect=0, quizTotal=3, quizAnswered=0;

// Flow path: 0=Lungs, 1=Heart, 2=Body, 3=Heart, 4=Lungs
function clickNode(idx){
    if(idx===currentStep){
        var node=document.getElementById('node'+idx);
        node.classList.remove('active','locked');
        node.classList.add('completed');
        currentStep++;
        if(currentStep<5){
            var next=document.getElementById('node'+currentStep);
            next.classList.remove('locked');
            next.classList.add('active');
        } else {
            pathComplete=true;
            earnStar(1);
            var fb=document.getElementById('pathFeedback');
            fb.className='lab-feedback show correct';
            fb.textContent=lang==='BM'?'⭐ Hebat! Anda melengkapkan laluan aliran darah!':'⭐ Great! You completed the blood flow pathway!';
            showQuiz();
        }
    } else {
        var fb=document.getElementById('pathFeedback');
        fb.className='lab-feedback show wrong';
        fb.textContent=lang==='BM'?'Cuba lagi! Klik nod seterusnya yang betul.':'Try again! Click the correct next node.';
        setTimeout(function(){fb.className='lab-feedback';},2000);
    }
}

function showQuiz(){
    document.getElementById('section2').style.display='block';
    var q1=lang==='BM'?'Organ mana yang menambah oksigen ke dalam darah?':'Which organ adds oxygen to the blood?';
    var q2=lang==='BM'?'Organ mana yang mengepam darah?':'Which organ pumps blood?';
    var q3=lang==='BM'?'Warna mana mewakili darah kaya oksigen?':'What colour represents oxygen-rich blood?';

    document.getElementById('quiz1').textContent='1. '+q1;
    buildOpts('quiz1Opts',[
        {text:lang==='BM'?'Jantung':'Heart',correct:false},
        {text:lang==='BM'?'Paru-paru':'Lungs',correct:true},
        {text:lang==='BM'?'Otak':'Brain',correct:false}
    ],1);

    document.getElementById('quiz2').textContent='2. '+q2;
    buildOpts('quiz2Opts',[
        {text:lang==='BM'?'Paru-paru':'Lungs',correct:false},
        {text:lang==='BM'?'Jantung':'Heart',correct:true},
        {text:lang==='BM'?'Hati':'Liver',correct:false}
    ],2);

    document.getElementById('quiz3').textContent='3. '+q3;
    buildOpts('quiz3Opts',[
        {text:lang==='BM'?'Biru':'Blue',correct:false},
        {text:lang==='BM'?'Hijau':'Green',correct:false},
        {text:lang==='BM'?'Merah':'Red',correct:true}
    ],3);
}

function buildOpts(containerId,options,qNum){
    var container=document.getElementById(containerId);
    container.innerHTML='';
    options.forEach(function(opt){
        var btn=document.createElement('button');
        btn.type='button';
        btn.className='quiz-opt';
        btn.textContent=opt.text;
        btn.setAttribute('data-correct',opt.correct);
        btn.onclick=function(){answerQuiz(btn,qNum);};
        container.appendChild(btn);
    });
}

function answerQuiz(btn,qNum){
    var correct=btn.getAttribute('data-correct')==='true';
    var parent=btn.parentElement;
    parent.querySelectorAll('.quiz-opt').forEach(function(b){
        if(b.getAttribute('data-correct')==='true') b.classList.add('correct');
        else b.classList.add('wrong');
        b.style.pointerEvents='none';
    });
    if(correct) quizCorrect++;
    quizAnswered++;

    // Show next question
    if(qNum===1){document.getElementById('quiz2').style.display='block';document.getElementById('quiz2Opts').style.display='flex';}
    if(qNum===2){document.getElementById('quiz3').style.display='block';document.getElementById('quiz3Opts').style.display='flex';}

    // O2/CO2 concept star after Q1 or Q3
    if(quizAnswered>=1 && quizCorrect>=1 && starsEarned<2) earnStar(2);

    if(quizAnswered>=quizTotal){
        if(quizCorrect>=quizTotal) earnStar(3);
        var fb=document.getElementById('quizFeedback');
        fb.className='lab-feedback show correct';
        fb.textContent=(lang==='BM'?'Anda menjawab ':'You answered ')+quizCorrect+'/'+quizTotal+(lang==='BM'?' soalan dengan betul!':' questions correctly!');
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
</script>
</asp:Content>
