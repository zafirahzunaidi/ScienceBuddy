<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GreatSoakChallenge.aspx.cs"
    Inherits="ScienceBuddy.Student.Labs.GreatSoakChallenge" MasterPageFile="~/Site.Master" Title="The Great Soak Challenge" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--student:#FF6B2C;--student-light:#FFF0E8;--lab-color:#0EA5E9;--lab-light:#E0F2FE;}
.lab-hero{background:linear-gradient(135deg,#0EA5E9 0%,#38BDF8 100%);border-radius:var(--border-radius-xl);
    padding:var(--space-2xl);color:#fff;position:relative;overflow:hidden;margin-bottom:var(--space-xl);}
.lab-hero::before{content:'';position:absolute;font-size:6rem;opacity:.1;top:10px;right:40px;
    background:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='80' height='80' fill='white' viewBox='0 0 16 16'%3E%3Cpath d='M8 16a6 6 0 0 0 6-6c0-1.655-.59-2.906-2.47-4.78S8 0 8 0 5.59 2.34 4.47 4.22C2.59 7.094 2 8.345 2 10a6 6 0 0 0 6 6'/%3E%3C/svg%3E");
    background-repeat:no-repeat;width:80px;height:80px;}
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

/* Material Cards */
.material-cards{display:flex;flex-wrap:wrap;gap:var(--space-md);justify-content:center;margin-bottom:var(--space-lg);}
.material-card{width:130px;padding:var(--space-lg) var(--space-md);border-radius:var(--border-radius-xl);
    border:2px solid var(--border-color);background:var(--color-white);text-align:center;cursor:pointer;transition:all .2s;}
.material-card:hover{border-color:var(--lab-color);transform:translateY(-3px);box-shadow:0 4px 12px rgba(14,165,233,.2);}
.material-card.selected{border-color:var(--lab-color);background:var(--lab-light);box-shadow:0 4px 12px rgba(14,165,233,.3);}
.material-card.tested{opacity:.7;}
.material-card .mat-icon{font-size:2rem;margin-bottom:var(--space-sm);}
.material-card .mat-name{font-weight:700;font-size:.8125rem;}

/* Dropper */
.dropper-area{text-align:center;margin-bottom:var(--space-lg);padding:var(--space-xl);
    background:#F0F9FF;border-radius:var(--border-radius-xl);border:2px dashed #BAE6FD;}
.dropper-btn{width:70px;height:70px;border-radius:50%;border:3px solid var(--lab-color);background:#fff;
    font-size:2rem;cursor:pointer;transition:all .2s;display:inline-flex;align-items:center;justify-content:center;}
.dropper-btn:hover{background:var(--lab-light);transform:scale(1.1);}
.dropper-btn:active{transform:scale(0.95);}
.drop-count{font-size:.875rem;font-weight:700;color:var(--lab-color);margin-top:var(--space-sm);}

/* Absorption Meter */
.absorption-meter{width:100%;max-width:300px;height:24px;border-radius:var(--border-radius-full);
    background:#E2E8F0;margin:var(--space-md) auto;overflow:hidden;border:2px solid var(--border-color);}
.absorption-fill{height:100%;border-radius:var(--border-radius-full);background:linear-gradient(90deg,#0EA5E9,#06B6D4);
    transition:width .5s ease;width:0%;}
.absorption-label{text-align:center;font-size:.8125rem;font-weight:700;color:var(--color-text-secondary);margin-bottom:var(--space-md);}

/* Compare Section */
.compare-area{display:flex;gap:var(--space-md);justify-content:center;flex-wrap:wrap;margin-bottom:var(--space-lg);}
.compare-card{padding:var(--space-md) var(--space-lg);border-radius:var(--border-radius);border:2px solid var(--border-color);
    background:var(--color-white);cursor:pointer;font-weight:700;font-size:.9375rem;transition:all .2s;}
.compare-card:hover{border-color:var(--lab-color);background:var(--lab-light);}
.compare-card.picked{border-color:#22C55E;background:#DCFCE7;}

.lab-feedback{text-align:center;padding:var(--space-lg);border-radius:var(--border-radius);
    font-weight:700;font-size:.9375rem;margin-bottom:var(--space-md);display:none;}
.lab-feedback.show{display:block;}
.lab-feedback.correct{background:#DCFCE7;color:#15803D;}
.lab-feedback.wrong{background:#FEE2E2;color:#B91C1C;}
.lab-complete-bar{display:flex;align-items:center;justify-content:center;gap:var(--space-md);margin-bottom:var(--space-xl);}
@media(max-width:767px){.material-cards{gap:var(--space-sm);}.material-card{width:100px;}}
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

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><asp:Literal ID="litPageTitle" runat="server" Text="The Great Soak Challenge" /></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="lab-section" style="text-align:center;padding:var(--space-3xl);">
        <div style="font-size:3rem;margin-bottom:var(--space-md);">💧</div>
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

<%-- Step 1: Test Materials --%>
<div class="lab-section" id="section1">
    <div class="lab-section-title"><i class="bi bi-1-circle-fill" style="color:#0EA5E9;"></i> <asp:Literal ID="litStep1Title" runat="server" /></div>
    <div class="lab-instruction"><asp:Literal ID="litStep1Inst" runat="server" /></div>

    <div class="material-cards" id="materialCards">
        <div class="material-card" data-mat="sponge" data-abs="95" onclick="selectMaterial(this)">
            <div class="mat-icon"><i class="bi bi-moisture" style="color:#0EA5E9;"></i></div><div class="mat-name"><asp:Literal ID="litMatSponge" runat="server" Text="Sponge" /></div>
        </div>
        <div class="material-card" data-mat="tissue" data-abs="80" onclick="selectMaterial(this)">
            <div class="mat-icon"><i class="bi bi-file-earmark" style="color:#64748B;"></i></div><div class="mat-name"><asp:Literal ID="litMatTissue" runat="server" Text="Tissue" /></div>
        </div>
        <div class="material-card" data-mat="cotton" data-abs="70" onclick="selectMaterial(this)">
            <div class="mat-icon"><i class="bi bi-cloud-fill" style="color:#94A3B8;"></i></div><div class="mat-name"><asp:Literal ID="litMatCotton" runat="server" Text="Cotton" /></div>
        </div>
        <div class="material-card" data-mat="plastic" data-abs="5" onclick="selectMaterial(this)">
            <div class="mat-icon"><i class="bi bi-cup-straw" style="color:#F97316;"></i></div><div class="mat-name"><asp:Literal ID="litMatPlastic" runat="server" Text="Plastic" /></div>
        </div>
        <div class="material-card" data-mat="foil" data-abs="3" onclick="selectMaterial(this)">
            <div class="mat-icon"><i class="bi bi-diamond-fill" style="color:#A1A1AA;"></i></div><div class="mat-name"><asp:Literal ID="litMatFoil" runat="server" Text="Foil" /></div>
        </div>
    </div>

    <div class="dropper-area" id="dropperArea" style="display:none;">
        <div id="selectedMatLabel" style="font-weight:700;font-size:1rem;margin-bottom:var(--space-sm);"></div>
        <button type="button" class="dropper-btn" onclick="dropWater()" id="dropperBtn">💧</button>
        <div class="drop-count" id="dropCount"></div>
        <div class="absorption-meter"><div class="absorption-fill" id="absFill"></div></div>
        <div class="absorption-label" id="absLabel"></div>
    </div>
    <div class="lab-feedback" id="testFeedback"></div>
</div>

<%-- Step 2: Compare Materials --%>
<div class="lab-section" id="section2" style="display:none;">
    <div class="lab-section-title"><i class="bi bi-2-circle-fill" style="color:#0EA5E9;"></i> <asp:Literal ID="litStep2Title" runat="server" /></div>
    <div class="lab-instruction"><asp:Literal ID="litStep2Inst" runat="server" /></div>

    <div class="compare-area" id="compareArea"></div>
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
var starsEarned=0, selectedMat=null, dropCount=0, testedMats=[], currentAbs=0;

var materials={sponge:{abs:95},tissue:{abs:80},cotton:{abs:70},plastic:{abs:5},foil:{abs:3}};
var matNames={sponge:lang==='BM'?'Span':'Sponge',tissue:lang==='BM'?'Tisu':'Tissue',
    cotton:lang==='BM'?'Kapas':'Cotton',plastic:lang==='BM'?'Plastik':'Plastic',foil:lang==='BM'?'Kerajang':'Foil'};

function selectMaterial(el){
    if(el.classList.contains('tested'))return;
    document.querySelectorAll('.material-card').forEach(function(c){c.classList.remove('selected');});
    el.classList.add('selected');
    selectedMat=el.getAttribute('data-mat');
    currentAbs=parseInt(el.getAttribute('data-abs'));
    dropCount=0;
    document.getElementById('dropperArea').style.display='block';
    document.getElementById('selectedMatLabel').textContent=(lang==='BM'?'Bahan dipilih: ':'Selected: ')+matNames[selectedMat];
    document.getElementById('dropCount').textContent=(lang==='BM'?'Titisan: 0/3':'Drops: 0/3');
    document.getElementById('absFill').style.width='0%';
    document.getElementById('absLabel').textContent='';
}

function dropWater(){
    if(!selectedMat||dropCount>=3)return;
    dropCount++;
    document.getElementById('dropCount').textContent=(lang==='BM'?'Titisan: ':'Drops: ')+dropCount+'/3';
    var pct=Math.round((currentAbs/100)*(dropCount/3)*100);
    document.getElementById('absFill').style.width=pct+'%';
    document.getElementById('absLabel').textContent=(lang==='BM'?'Penyerapan: ':'Absorption: ')+pct+'%';

    if(dropCount>=3){
        var el=document.querySelector('.material-card[data-mat="'+selectedMat+'"]');
        el.classList.add('tested'); el.classList.remove('selected');
        testedMats.push({name:selectedMat,abs:currentAbs});
        selectedMat=null;

        var fb=document.getElementById('testFeedback');
        fb.className='lab-feedback show correct';
        fb.textContent=(lang==='BM'?'✓ Bahan diuji! ('+testedMats.length+'/5)':'✓ Material tested! ('+testedMats.length+'/5)');

        if(testedMats.length>=1&&starsEarned<1) earnStar(1);

        if(testedMats.length>=2) showCompareSection();
    }
}

function showCompareSection(){
    document.getElementById('section2').style.display='block';
    var area=document.getElementById('compareArea');
    area.innerHTML='';
    testedMats.forEach(function(m){
        var div=document.createElement('div');
        div.className='compare-card';
        div.setAttribute('data-mat',m.name);
        div.textContent=matNames[m.name]+' ('+m.abs+'%)';
        div.onclick=function(){pickMostAbsorbent(m.name);};
        area.appendChild(div);
    });
    if(starsEarned<2) earnStar(2);
}

function pickMostAbsorbent(name){
    document.querySelectorAll('.compare-card').forEach(function(c){c.classList.remove('picked');});
    document.querySelector('.compare-card[data-mat="'+name+'"]').classList.add('picked');

    var best=testedMats.reduce(function(a,b){return a.abs>b.abs?a:b;});
    var fb=document.getElementById('compareFeedback');
    if(name===best.name){
        fb.className='lab-feedback show correct';
        fb.textContent=(lang==='BM'?'🎉 Betul! '+matNames[name]+' paling menyerap!':'🎉 Correct! '+matNames[name]+' is most absorbent!');
        if(starsEarned<3) earnStar(3);
    } else {
        fb.className='lab-feedback show wrong';
        fb.textContent=(lang==='BM'?'✗ Cuba lagi! Pilih bahan dengan peratusan tertinggi.':'✗ Try again! Pick the material with highest percentage.');
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
</script>
</asp:Content>
