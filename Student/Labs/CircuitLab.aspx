<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CircuitLab.aspx.cs"
    Inherits="ScienceBuddy.Student.Labs.CircuitLab" MasterPageFile="~/Site.Master" Title="Circuit Lab" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--lab-yellow:#F59E0B;--lab-yellow-dark:#D97706;}
.lab-hero{background:linear-gradient(135deg,#F59E0B 0%,#D97706 100%);border-radius:var(--border-radius-xl);
    padding:var(--space-2xl);color:#fff;position:relative;overflow:hidden;margin-bottom:var(--space-xl);}
.lab-hero::before{content:'⚡';position:absolute;font-size:6rem;opacity:.1;top:10px;right:40px;}
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
    padding:var(--space-md);background:#FFFBEB;border-radius:var(--border-radius);border-left:4px solid #F59E0B;}

/* Circuit board */
.circuit-board{background:#1F2937;border-radius:var(--border-radius-xl);padding:var(--space-xl);margin-bottom:var(--space-lg);
    position:relative;min-height:200px;}
.circuit-components{display:flex;flex-wrap:wrap;gap:var(--space-md);justify-content:center;margin-bottom:var(--space-lg);}
.circuit-comp{width:80px;height:80px;border-radius:var(--border-radius);display:flex;flex-direction:column;
    align-items:center;justify-content:center;gap:4px;cursor:pointer;border:2px solid #374151;
    background:#111827;color:#F9FAFB;font-size:.7rem;font-weight:600;transition:all .2s;}
.circuit-comp:hover{border-color:#F59E0B;transform:scale(1.05);}
.circuit-comp.placed{border-color:#22C55E;background:#064E3B;}
.circuit-comp.next{border-color:#F59E0B;animation:glow 1.5s infinite;background:#1C1917;}
.circuit-comp .comp-icon{font-size:1.5rem;}
@keyframes glow{0%,100%{box-shadow:0 0 5px rgba(245,158,11,.3);}50%{box-shadow:0 0 20px rgba(245,158,11,.6);}}

/* Built circuit display */
.circuit-visual{display:flex;align-items:center;justify-content:center;gap:var(--space-sm);flex-wrap:wrap;
    padding:var(--space-lg);min-height:60px;}
.cv-item{padding:6px 12px;border-radius:var(--border-radius);font-size:.75rem;font-weight:700;
    background:#374151;color:#F9FAFB;border:1px solid #4B5563;}
.cv-wire{width:30px;height:3px;background:#F59E0B;}

/* Bulbs */
.bulbs-display{display:flex;gap:var(--space-xl);justify-content:center;margin:var(--space-lg) 0;flex-wrap:wrap;}
.bulb{width:60px;height:80px;position:relative;text-align:center;}
.bulb-glass{width:50px;height:50px;border-radius:50%;border:3px solid #6B7280;margin:0 auto 6px;
    display:flex;align-items:center;justify-content:center;font-size:1.25rem;transition:all .4s;}
.bulb-glass.lit-dim{background:#FEF3C7;border-color:#F59E0B;box-shadow:0 0 15px rgba(245,158,11,.4);}
.bulb-glass.lit-bright{background:#FDE68A;border-color:#F59E0B;box-shadow:0 0 30px rgba(245,158,11,.7);}
.bulb-label{font-size:.7rem;font-weight:600;color:#D1D5DB;}

/* Switch */
.switch-toggle{display:flex;align-items:center;justify-content:center;gap:var(--space-md);margin:var(--space-lg) 0;}
.switch-btn{padding:10px 24px;border-radius:var(--border-radius-full);font-weight:700;font-size:.875rem;
    cursor:pointer;border:2px solid #374151;background:#111827;color:#F9FAFB;transition:all .2s;}
.switch-btn:hover{border-color:#F59E0B;}
.switch-btn.on{background:#F59E0B;border-color:#D97706;color:#1F2937;}

/* Mode tabs */
.mode-tabs{display:flex;gap:var(--space-sm);margin-bottom:var(--space-lg);flex-wrap:wrap;}
.mode-tab{padding:10px 20px;border-radius:var(--border-radius);font-weight:700;font-size:.875rem;
    border:2px solid var(--border-color);background:var(--color-white);cursor:pointer;transition:all .2s;}
.mode-tab:hover{border-color:#F59E0B;background:#FFFBEB;}
.mode-tab.active{border-color:#F59E0B;background:#FEF3C7;color:#92400E;}
.mode-tab.done{border-color:#22C55E;background:#DCFCE7;color:#15803D;}

/* Comparison question */
.compare-q{font-weight:700;font-size:1rem;text-align:center;margin:var(--space-lg) 0 var(--space-md);color:var(--color-text);}
.compare-opts{display:flex;gap:var(--space-md);justify-content:center;flex-wrap:wrap;margin-bottom:var(--space-lg);}
.compare-opt{padding:12px 24px;border-radius:var(--border-radius);font-weight:700;font-size:.9375rem;
    border:2px solid var(--border-color);background:var(--color-white);cursor:pointer;transition:all .2s;}
.compare-opt:hover{border-color:#F59E0B;background:#FFFBEB;}
.compare-opt.correct{border-color:#22C55E;background:#DCFCE7;pointer-events:none;}
.compare-opt.wrong{border-color:#EF4444;background:#FEE2E2;pointer-events:none;}

.lab-feedback{text-align:center;padding:var(--space-lg);border-radius:var(--border-radius);
    font-weight:700;font-size:.9375rem;margin-bottom:var(--space-md);display:none;}
.lab-feedback.show{display:block;}
.lab-feedback.correct{background:#DCFCE7;color:#15803D;}
.lab-feedback.wrong{background:#FEE2E2;color:#B91C1C;}
.lab-complete-bar{display:flex;align-items:center;justify-content:center;gap:var(--space-md);margin-bottom:var(--space-xl);}
@media(max-width:767px){.circuit-comp{width:65px;height:65px;}.bulb{width:50px;height:70px;}}
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
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><asp:Literal ID="litPageTitle" runat="server" Text="Circuit Lab" /></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="lab-section" style="text-align:center;padding:var(--space-3xl);">
        <div style="font-size:3rem;margin-bottom:var(--space-md);">⚡</div>
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

<%-- Mode Selection --%>
<div class="lab-section" id="sectionMode">
    <div class="lab-section-title"><i class="bi bi-lightning-fill" style="color:#F59E0B;"></i> <asp:Literal ID="litModeTitle" runat="server" /></div>
    <div class="lab-instruction"><asp:Literal ID="litModeInst" runat="server" /></div>
    <div class="mode-tabs">
        <button type="button" class="mode-tab active" id="tabSeries" onclick="switchMode('series')"><asp:Literal ID="litSeries" runat="server" Text="Series Circuit" /></button>
        <button type="button" class="mode-tab" id="tabParallel" onclick="switchMode('parallel')"><asp:Literal ID="litParallel" runat="server" Text="Parallel Circuit" /></button>
    </div>
</div>

<%-- Build Circuit --%>
<div class="lab-section" id="sectionBuild">
    <div class="lab-section-title"><i class="bi bi-tools" style="color:#F59E0B;"></i> <asp:Literal ID="litBuildTitle" runat="server" /></div>
    <div class="lab-instruction"><asp:Literal ID="litBuildInst" runat="server" /></div>

    <div class="circuit-board">
        <div class="circuit-components" id="compPalette">
            <div class="circuit-comp" data-comp="battery" onclick="placeComp(this)">
                <span class="comp-icon">🔋</span><asp:Literal ID="litBattery" runat="server" Text="Battery" />
            </div>
            <div class="circuit-comp" data-comp="wire1" onclick="placeComp(this)">
                <span class="comp-icon">〰️</span><asp:Literal ID="litWire1" runat="server" Text="Wire" />
            </div>
            <div class="circuit-comp" data-comp="switch" onclick="placeComp(this)">
                <span class="comp-icon">🔘</span><asp:Literal ID="litSwitch" runat="server" Text="Switch" />
            </div>
            <div class="circuit-comp" data-comp="bulb1" onclick="placeComp(this)">
                <span class="comp-icon">💡</span><asp:Literal ID="litBulb1" runat="server" Text="Bulb 1" />
            </div>
            <div class="circuit-comp" data-comp="bulb2" onclick="placeComp(this)">
                <span class="comp-icon">💡</span><asp:Literal ID="litBulb2" runat="server" Text="Bulb 2" />
            </div>
        </div>

        <div class="circuit-visual" id="circuitVisual"></div>

        <div class="bulbs-display" id="bulbsDisplay" style="display:none;">
            <div class="bulb"><div class="bulb-glass" id="bulbGlass1">💡</div><div class="bulb-label">Bulb 1</div></div>
            <div class="bulb"><div class="bulb-glass" id="bulbGlass2">💡</div><div class="bulb-label">Bulb 2</div></div>
        </div>

        <div class="switch-toggle" id="switchArea" style="display:none;">
            <button type="button" class="switch-btn" id="switchBtn" onclick="toggleSwitch()">OFF</button>
        </div>
    </div>

    <div class="lab-feedback" id="buildFeedback"></div>
</div>

<%-- Comparison Question --%>
<div class="lab-section" id="sectionCompare" style="display:none;">
    <div class="lab-section-title"><i class="bi bi-question-circle-fill" style="color:#F59E0B;"></i> <asp:Literal ID="litCompareTitle" runat="server" /></div>
    <div class="compare-q" id="compareQuestion"></div>
    <div class="compare-opts" id="compareOpts">
        <button type="button" class="compare-opt" onclick="answerCompare('series')"><%= T("Series Circuit","Litar Sesiri") %></button>
        <button type="button" class="compare-opt" onclick="answerCompare('parallel')"><%= T("Parallel Circuit","Litar Selari") %></button>
    </div>
    <div class="lab-feedback" id="compareFeedback"></div>
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
var starsEarned=0;
var currentMode='series';
var seriesOrder=['battery','wire1','switch','bulb1','bulb2'];
var parallelOrder=['battery','wire1','switch','bulb1','bulb2'];
var placedComps=[];
var switchOn=false;
var seriesDone=false, parallelDone=false;

function switchMode(mode){
    currentMode=mode;
    document.getElementById('tabSeries').className='mode-tab'+(mode==='series'?' active':'')+(seriesDone?' done':'');
    document.getElementById('tabParallel').className='mode-tab'+(mode==='parallel'?' active':'')+(parallelDone?' done':'');
    resetBuild();
}

function resetBuild(){
    placedComps=[];
    switchOn=false;
    document.getElementById('circuitVisual').innerHTML='';
    document.getElementById('bulbsDisplay').style.display='none';
    document.getElementById('switchArea').style.display='none';
    document.getElementById('switchBtn').className='switch-btn';
    document.getElementById('switchBtn').textContent='OFF';
    document.getElementById('bulbGlass1').className='bulb-glass';
    document.getElementById('bulbGlass2').className='bulb-glass';
    var comps=document.querySelectorAll('.circuit-comp');
    comps.forEach(function(c){c.classList.remove('placed','next');});
    highlightNext();
}

function highlightNext(){
    var order=currentMode==='series'?seriesOrder:parallelOrder;
    var idx=placedComps.length;
    if(idx>=order.length)return;
    var nextComp=order[idx];
    var comps=document.querySelectorAll('.circuit-comp');
    comps.forEach(function(c){
        c.classList.remove('next');
        if(c.getAttribute('data-comp')===nextComp) c.classList.add('next');
    });
}

function placeComp(el){
    var comp=el.getAttribute('data-comp');
    var order=currentMode==='series'?seriesOrder:parallelOrder;
    var idx=placedComps.length;
    if(idx>=order.length)return;

    if(comp===order[idx]){
        el.classList.remove('next');
        el.classList.add('placed');
        placedComps.push(comp);

        // Add to visual
        var visual=document.getElementById('circuitVisual');
        var item=document.createElement('div');
        item.className='cv-item';
        var icons={battery:'🔋',wire1:'〰️',switch:'🔘',bulb1:'💡',bulb2:'💡'};
        item.textContent=icons[comp]||comp;
        if(visual.children.length>0){
            var wire=document.createElement('div');
            wire.className='cv-wire';
            visual.appendChild(wire);
        }
        visual.appendChild(item);

        var fb=document.getElementById('buildFeedback');
        fb.className='lab-feedback show correct';
        fb.textContent=lang==='BM'?'✓ Betul! Komponen dipasang.':'✓ Correct! Component placed.';
        setTimeout(function(){fb.className='lab-feedback';},1200);

        if(placedComps.length>=order.length){
            circuitComplete();
        } else {
            highlightNext();
        }
    } else {
        var fb=document.getElementById('buildFeedback');
        fb.className='lab-feedback show wrong';
        fb.textContent=lang==='BM'?'Cuba lagi! Pilih komponen seterusnya yang betul.':'Try again! Pick the correct next component.';
        setTimeout(function(){fb.className='lab-feedback';},1500);
    }
}

function circuitComplete(){
    document.getElementById('bulbsDisplay').style.display='flex';
    document.getElementById('switchArea').style.display='flex';
    var fb=document.getElementById('buildFeedback');
    fb.className='lab-feedback show correct';
    fb.textContent=lang==='BM'?'⚡ Litar siap! Togol suis untuk menguji.':'⚡ Circuit complete! Toggle the switch to test.';

    if(currentMode==='series' && !seriesDone){
        seriesDone=true;
        document.getElementById('tabSeries').classList.add('done');
        earnStar(1);
    }
    if(currentMode==='parallel' && !parallelDone){
        parallelDone=true;
        document.getElementById('tabParallel').classList.add('done');
        earnStar(2);
    }
    if(seriesDone && parallelDone){
        showCompare();
    }
}

function toggleSwitch(){
    switchOn=!switchOn;
    var btn=document.getElementById('switchBtn');
    btn.textContent=switchOn?'ON':'OFF';
    btn.className=switchOn?'switch-btn on':'switch-btn';

    var b1=document.getElementById('bulbGlass1');
    var b2=document.getElementById('bulbGlass2');
    if(switchOn){
        if(currentMode==='series'){
            b1.className='bulb-glass lit-dim';
            b2.className='bulb-glass lit-dim';
        } else {
            b1.className='bulb-glass lit-bright';
            b2.className='bulb-glass lit-bright';
        }
    } else {
        b1.className='bulb-glass';
        b2.className='bulb-glass';
    }
}

function showCompare(){
    document.getElementById('sectionCompare').style.display='block';
    var q=lang==='BM'?'Litar mana memberikan mentol yang lebih terang?':'Which circuit gives brighter bulbs?';
    document.getElementById('compareQuestion').textContent=q;
}

function answerCompare(answer){
    var opts=document.querySelectorAll('.compare-opt');
    opts.forEach(function(o){
        o.style.pointerEvents='none';
        if(o.textContent.toLowerCase().indexOf('parallel')>-1||o.textContent.toLowerCase().indexOf('selari')>-1){
            o.classList.add('correct');
        } else {
            o.classList.add('wrong');
        }
    });
    var fb=document.getElementById('compareFeedback');
    if(answer==='parallel'){
        fb.className='lab-feedback show correct';
        fb.textContent=lang==='BM'?'⭐ Betul! Litar selari memberikan mentol lebih terang.':'⭐ Correct! Parallel circuit gives brighter bulbs.';
        earnStar(3);
    } else {
        fb.className='lab-feedback show wrong';
        fb.textContent=lang==='BM'?'Jawapan betul ialah Litar Selari.':'The correct answer is Parallel Circuit.';
    }
    enableComplete();
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

// Init
highlightNext();
</script>
</asp:Content>
