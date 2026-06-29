<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MatterStateChanger.aspx.cs"
    Inherits="ScienceBuddy.Student.Labs.MatterStateChanger" MasterPageFile="~/Site.Master" Title="Matter State Changer" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--lab-purple:#7C3AED;--lab-purple-light:#A78BFA;}
.lab-hero{background:linear-gradient(135deg,#7C3AED 0%,#5B21B6 100%);border-radius:var(--border-radius-xl);
    padding:var(--space-2xl);color:#fff;position:relative;overflow:hidden;margin-bottom:var(--space-xl);}
.lab-hero::before{content:'🧊';position:absolute;font-size:6rem;opacity:.1;top:10px;right:40px;}
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
    padding:var(--space-md);background:#F5F3FF;border-radius:var(--border-radius);border-left:4px solid #7C3AED;}

/* Beaker & experiment */
.experiment-zone{display:flex;flex-direction:column;align-items:center;padding:var(--space-xl);
    background:#F8F5FF;border-radius:var(--border-radius-xl);margin-bottom:var(--space-xl);position:relative;}
.beaker{width:120px;height:160px;border:4px solid #6B7280;border-top:none;border-radius:0 0 20px 20px;
    position:relative;overflow:hidden;background:#fff;margin-bottom:var(--space-lg);}
.beaker-content{position:absolute;bottom:0;left:0;right:0;transition:all .8s ease;}
.beaker-content.solid{height:40%;background:linear-gradient(180deg,#BFDBFE 0%,#93C5FD 100%);border-radius:0 0 16px 16px;}
.beaker-content.liquid{height:60%;background:linear-gradient(180deg,#60A5FA 0%,#3B82F6 100%);border-radius:0 0 16px 16px;}
.beaker-content.gas{height:80%;background:linear-gradient(180deg,rgba(156,163,175,.2) 0%,rgba(156,163,175,.05) 100%);border-radius:0 0 16px 16px;}

/* Ice cube in solid */
.ice-cube{position:absolute;bottom:20%;left:50%;transform:translateX(-50%);width:30px;height:30px;
    background:linear-gradient(135deg,#DBEAFE,#BFDBFE);border:2px solid #93C5FD;border-radius:4px;transition:all .8s;}
.ice-cube.melted{opacity:0;transform:translateX(-50%) scale(0);}

/* Steam */
.steam-container{position:absolute;top:-40px;left:0;right:0;display:flex;justify-content:center;gap:8px;opacity:0;transition:opacity .8s;}
.steam-container.show{opacity:1;}
.steam-puff{width:20px;height:20px;background:rgba(156,163,175,.4);border-radius:50%;animation:rise 2s infinite;}
.steam-puff:nth-child(2){animation-delay:.5s;width:16px;height:16px;}
.steam-puff:nth-child(3){animation-delay:1s;width:14px;height:14px;}
@keyframes rise{0%{transform:translateY(0) scale(1);opacity:.6;}100%{transform:translateY(-30px) scale(1.5);opacity:0;}}

/* Burner */
.burner{width:80px;height:30px;background:linear-gradient(180deg,#EF4444,#B91C1C);border-radius:6px;
    position:relative;margin-bottom:var(--space-sm);opacity:.3;transition:opacity .3s;}
.burner.active{opacity:1;}
.burner-flame{position:absolute;top:-20px;left:50%;transform:translateX(-50%);width:20px;height:25px;
    background:linear-gradient(180deg,#FDE047,#F97316);border-radius:50% 50% 50% 50%/60% 60% 40% 40%;
    opacity:0;transition:opacity .3s;animation:flicker .3s infinite alternate;}
.burner.active .burner-flame{opacity:1;}
@keyframes flicker{0%{transform:translateX(-50%) scaleY(1);}100%{transform:translateX(-50%) scaleY(1.1);}}

/* Thermometer */
.thermometer{width:24px;height:120px;background:#F3F4F6;border:2px solid #9CA3AF;border-radius:12px;
    position:absolute;right:20px;top:20px;overflow:hidden;}
.thermo-fill{position:absolute;bottom:0;left:2px;right:2px;background:linear-gradient(180deg,#EF4444,#DC2626);
    border-radius:0 0 10px 10px;transition:height .8s;height:10%;}
.thermo-label{position:absolute;right:50px;top:50%;transform:translateY(-50%);font-size:.75rem;font-weight:700;
    color:#7C3AED;white-space:nowrap;}

/* State badge */
.state-badge{display:inline-flex;align-items:center;gap:6px;padding:8px 16px;border-radius:var(--border-radius-full);
    font-weight:700;font-size:.9375rem;margin:var(--space-md) 0;transition:all .3s;}
.state-badge.solid-b{background:#DBEAFE;color:#1D4ED8;}
.state-badge.liquid-b{background:#BFDBFE;color:#1E40AF;}
.state-badge.gas-b{background:#E5E7EB;color:#4B5563;}

/* Controls */
.exp-controls{display:flex;gap:var(--space-md);justify-content:center;flex-wrap:wrap;margin-top:var(--space-lg);}
.exp-btn{padding:12px 24px;border-radius:var(--border-radius);font-weight:700;font-size:.9375rem;
    cursor:pointer;border:2px solid var(--border-color);background:var(--color-white);transition:all .2s;}
.exp-btn.heat{border-color:#EF4444;color:#EF4444;}
.exp-btn.heat:hover{background:#FEF2F2;}
.exp-btn.cool{border-color:#3B82F6;color:#3B82F6;}
.exp-btn.cool:hover{background:#EFF6FF;}
.exp-btn:disabled{opacity:.4;cursor:not-allowed;}

/* Match process names */
.match-zone{margin-top:var(--space-xl);}
.match-row{display:flex;align-items:center;gap:var(--space-md);margin-bottom:var(--space-md);flex-wrap:wrap;}
.match-change{padding:8px 14px;border-radius:var(--border-radius);font-weight:600;font-size:.875rem;
    background:#F5F3FF;border:1.5px solid #DDD6FE;min-width:140px;text-align:center;}
.match-arrow{font-size:1.25rem;color:var(--lab-purple);}
.match-options{display:flex;gap:var(--space-sm);flex-wrap:wrap;}
.match-opt{padding:8px 14px;border-radius:var(--border-radius);font-weight:600;font-size:.8125rem;
    border:2px solid var(--border-color);background:var(--color-white);cursor:pointer;transition:all .2s;}
.match-opt:hover{border-color:#7C3AED;background:#F5F3FF;}
.match-opt.correct{border-color:#22C55E;background:#DCFCE7;pointer-events:none;}
.match-opt.wrong{border-color:#EF4444;background:#FEE2E2;}
.match-opt.used{opacity:.4;pointer-events:none;}

.lab-feedback{text-align:center;padding:var(--space-lg);border-radius:var(--border-radius);
    font-weight:700;font-size:.9375rem;margin-bottom:var(--space-md);display:none;}
.lab-feedback.show{display:block;}
.lab-feedback.correct{background:#DCFCE7;color:#15803D;}
.lab-feedback.wrong{background:#FEE2E2;color:#B91C1C;}
.lab-complete-bar{display:flex;align-items:center;justify-content:center;gap:var(--space-md);margin-bottom:var(--space-xl);}
@media(max-width:767px){.match-row{flex-direction:column;align-items:flex-start;}}
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
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><asp:Literal ID="litPageTitle" runat="server" Text="Matter State Changer" /></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="lab-section" style="text-align:center;padding:var(--space-3xl);">
        <div style="font-size:3rem;margin-bottom:var(--space-md);">🧊</div>
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

<%-- Step 1: Heat & Cool Experiment --%>
<div class="lab-section" id="section1">
    <div class="lab-section-title"><i class="bi bi-1-circle-fill" style="color:#7C3AED;"></i> <asp:Literal ID="litStep1Title" runat="server" /></div>
    <div class="lab-instruction"><asp:Literal ID="litStep1Inst" runat="server" /></div>

    <div class="experiment-zone">
        <div class="thermometer">
            <div class="thermo-fill" id="thermoFill"></div>
        </div>
        <div class="thermo-label" id="thermoLabel">0°C</div>

        <div class="steam-container" id="steamContainer">
            <div class="steam-puff"></div>
            <div class="steam-puff"></div>
            <div class="steam-puff"></div>
        </div>

        <div class="beaker" id="beaker">
            <div class="beaker-content solid" id="beakerContent"></div>
            <div class="ice-cube" id="iceCube">🧊</div>
        </div>

        <div class="burner" id="burner">
            <div class="burner-flame"></div>
        </div>

        <div class="state-badge solid-b" id="stateBadge">🧊 <asp:Literal ID="litStateSolid" runat="server" Text="Solid" /></div>

        <div class="exp-controls">
            <button type="button" class="exp-btn heat" id="btnHeat" onclick="heatUp()">🔥 <asp:Literal ID="litHeatBtn" runat="server" Text="Heat" /></button>
            <button type="button" class="exp-btn cool" id="btnCool" onclick="coolDown()" disabled>❄️ <asp:Literal ID="litCoolBtn" runat="server" Text="Cool" /></button>
        </div>
    </div>

    <div class="lab-feedback" id="expFeedback"></div>
</div>

<%-- Step 2: Match Process Names --%>
<div class="lab-section" id="section2" style="display:none;">
    <div class="lab-section-title"><i class="bi bi-2-circle-fill" style="color:#7C3AED;"></i> <asp:Literal ID="litStep2Title" runat="server" /></div>
    <div class="lab-instruction"><asp:Literal ID="litStep2Inst" runat="server" /></div>

    <div class="match-zone" id="matchZone">
        <div class="match-row" id="matchRow1">
            <div class="match-change"><%= T("Solid → Liquid","Pepejal → Cecair") %></div>
            <div class="match-arrow">→</div>
            <div class="match-options" id="opts1">
                <button type="button" class="match-opt" onclick="matchAnswer(1,'melting',this)"><%= T("Melting","Peleburan") %></button>
                <button type="button" class="match-opt" onclick="matchAnswer(1,'evaporation',this)"><%= T("Evaporation","Penyejatan") %></button>
                <button type="button" class="match-opt" onclick="matchAnswer(1,'condensation',this)"><%= T("Condensation","Kondensasi") %></button>
            </div>
        </div>
        <div class="match-row" id="matchRow2">
            <div class="match-change"><%= T("Liquid → Gas","Cecair → Gas") %></div>
            <div class="match-arrow">→</div>
            <div class="match-options" id="opts2">
                <button type="button" class="match-opt" onclick="matchAnswer(2,'melting',this)"><%= T("Melting","Peleburan") %></button>
                <button type="button" class="match-opt" onclick="matchAnswer(2,'evaporation',this)"><%= T("Evaporation","Penyejatan") %></button>
                <button type="button" class="match-opt" onclick="matchAnswer(2,'condensation',this)"><%= T("Condensation","Kondensasi") %></button>
            </div>
        </div>
        <div class="match-row" id="matchRow3">
            <div class="match-change"><%= T("Gas → Liquid","Gas → Cecair") %></div>
            <div class="match-arrow">→</div>
            <div class="match-options" id="opts3">
                <button type="button" class="match-opt" onclick="matchAnswer(3,'melting',this)"><%= T("Melting","Peleburan") %></button>
                <button type="button" class="match-opt" onclick="matchAnswer(3,'evaporation',this)"><%= T("Evaporation","Penyejatan") %></button>
                <button type="button" class="match-opt" onclick="matchAnswer(3,'condensation',this)"><%= T("Condensation","Kondensasi") %></button>
            </div>
        </div>
    </div>

    <div class="lab-feedback" id="matchFeedback"></div>
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
var currentState='solid'; // solid, liquid, gas
var temp=0;
var meltedDone=false, boiledDone=false, condensedDone=false;
var matchCorrect=0, matchTotal=3, matchAnswered=0;
var answers={1:'melting',2:'evaporation',3:'condensation'};

function heatUp(){
    if(currentState==='solid'){
        // Melt: solid → liquid
        temp=50;
        currentState='liquid';
        meltedDone=true;
        document.getElementById('iceCube').classList.add('melted');
        document.getElementById('beakerContent').className='beaker-content liquid';
        document.getElementById('stateBadge').className='state-badge liquid-b';
        document.getElementById('stateBadge').innerHTML='💧 '+(lang==='BM'?'Cecair':'Liquid');
        document.getElementById('thermoFill').style.height='40%';
        document.getElementById('thermoLabel').textContent='50°C';
        document.getElementById('burner').classList.add('active');

        var fb=document.getElementById('expFeedback');
        fb.className='lab-feedback show correct';
        fb.textContent=lang==='BM'?'⭐ Ais mencair menjadi cecair! (Peleburan)':'⭐ Ice melts to liquid! (Melting)';
        earnStar(1);

    } else if(currentState==='liquid'){
        // Boil: liquid → gas
        temp=100;
        currentState='gas';
        boiledDone=true;
        document.getElementById('beakerContent').className='beaker-content gas';
        document.getElementById('stateBadge').className='state-badge gas-b';
        document.getElementById('stateBadge').innerHTML='💨 '+(lang==='BM'?'Gas':'Gas');
        document.getElementById('steamContainer').classList.add('show');
        document.getElementById('thermoFill').style.height='85%';
        document.getElementById('thermoLabel').textContent='100°C';
        document.getElementById('btnHeat').disabled=true;
        document.getElementById('btnCool').disabled=false;

        var fb=document.getElementById('expFeedback');
        fb.className='lab-feedback show correct';
        fb.textContent=lang==='BM'?'⭐ Air mendidih menjadi wap! (Penyejatan)':'⭐ Water boils to steam! (Evaporation)';
        earnStar(2);
        showMatchSection();
    }
}

function coolDown(){
    if(currentState==='gas'){
        // Condense: gas → liquid
        temp=30;
        currentState='liquid';
        condensedDone=true;
        document.getElementById('beakerContent').className='beaker-content liquid';
        document.getElementById('stateBadge').className='state-badge liquid-b';
        document.getElementById('stateBadge').innerHTML='💧 '+(lang==='BM'?'Cecair (Titisan Air)':'Liquid (Water Droplets)');
        document.getElementById('steamContainer').classList.remove('show');
        document.getElementById('thermoFill').style.height='25%';
        document.getElementById('thermoLabel').textContent='30°C';
        document.getElementById('burner').classList.remove('active');
        document.getElementById('btnCool').disabled=true;

        var fb=document.getElementById('expFeedback');
        fb.className='lab-feedback show correct';
        fb.textContent=lang==='BM'?'✓ Wap terkondensasi menjadi titisan air! (Kondensasi)':'✓ Steam condenses to water droplets! (Condensation)';
    }
}

function showMatchSection(){
    document.getElementById('section2').style.display='block';
}

function matchAnswer(row,answer,btn){
    var correct=(answers[row]===answer);
    if(correct){
        btn.classList.add('correct');
        matchCorrect++;
        // Disable other options in this row
        var opts=document.getElementById('opts'+row).querySelectorAll('.match-opt');
        opts.forEach(function(o){o.style.pointerEvents='none';});
    } else {
        btn.classList.add('wrong');
        setTimeout(function(){btn.classList.remove('wrong');},1000);
    }
    matchAnswered++;

    if(matchCorrect>=matchTotal){
        earnStar(3);
        var fb=document.getElementById('matchFeedback');
        fb.className='lab-feedback show correct';
        fb.textContent=lang==='BM'?'⭐ Cemerlang! Semua proses dipadankan dengan betul!':'⭐ Excellent! All processes matched correctly!';
        enableComplete();
    } else if(matchAnswered>=matchTotal*2){
        // Too many wrong attempts, enable complete anyway
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
