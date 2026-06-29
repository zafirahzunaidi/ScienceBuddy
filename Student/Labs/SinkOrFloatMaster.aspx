<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SinkOrFloatMaster.aspx.cs"
    Inherits="ScienceBuddy.Student.Labs.SinkOrFloatMaster" MasterPageFile="~/Site.Master" Title="Sink or Float Master" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--student:#FF6B2C;--student-light:#FFF0E8;--lab-color:#06B6D4;--lab-light:#ECFEFF;}
.lab-hero{background:linear-gradient(135deg,#06B6D4 0%,#22D3EE 100%);border-radius:var(--border-radius-xl);
    padding:var(--space-2xl);color:#fff;position:relative;overflow:hidden;margin-bottom:var(--space-xl);}
.lab-hero::before{content:'🌊';position:absolute;font-size:6rem;opacity:.1;top:10px;right:40px;}
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

/* Water Tank */
.tank-container{display:flex;justify-content:center;margin-bottom:var(--space-lg);}
.water-tank{width:280px;height:220px;border:4px solid #0891B2;border-top:none;border-radius:0 0 20px 20px;
    background:linear-gradient(180deg,rgba(6,182,212,.1) 0%,rgba(6,182,212,.4) 100%);position:relative;overflow:hidden;}
.water-level{position:absolute;bottom:0;left:0;right:0;height:70%;background:linear-gradient(180deg,rgba(6,182,212,.3) 0%,rgba(6,182,212,.6) 100%);
    transition:all .5s;border-top:3px wavy #22D3EE;}
.tank-label{position:absolute;top:8px;left:50%;transform:translateX(-50%);font-size:.75rem;font-weight:700;color:#0891B2;}
.tank-object{position:absolute;font-size:1.5rem;transition:all 1s ease;left:50%;transform:translateX(-50%);}
.tank-object.floating{top:25%;animation:bob 2s ease-in-out infinite;}
.tank-object.sinking{top:75%;animation:none;}
@keyframes bob{0%,100%{transform:translateX(-50%) translateY(0);}50%{transform:translateX(-50%) translateY(-8px);}}

/* Objects */
.object-cards{display:flex;flex-wrap:wrap;gap:var(--space-sm);justify-content:center;margin-bottom:var(--space-lg);}
.object-card{padding:12px 16px;border-radius:var(--border-radius);border:2px solid var(--border-color);
    background:var(--color-white);cursor:pointer;text-align:center;transition:all .2s;min-width:100px;}
.object-card:hover{border-color:var(--lab-color);transform:translateY(-2px);}
.object-card.active{border-color:var(--lab-color);background:var(--lab-light);}
.object-card.tested{opacity:.6;}
.object-card .obj-icon{font-size:1.5rem;margin-bottom:4px;}
.object-card .obj-name{font-weight:700;font-size:.75rem;}

/* Predict Buttons */
.predict-btns{display:flex;gap:var(--space-md);justify-content:center;margin-bottom:var(--space-lg);}
.predict-btn{padding:12px 28px;border-radius:var(--border-radius);border:2px solid var(--border-color);
    background:var(--color-white);font-weight:700;font-size:.9375rem;cursor:pointer;transition:all .2s;}
.predict-btn:hover{transform:scale(1.05);}
.predict-btn.sink{border-color:#EF4444;color:#EF4444;}
.predict-btn.sink:hover{background:#FEE2E2;}
.predict-btn.float{border-color:#22C55E;color:#22C55E;}
.predict-btn.float:hover{background:#DCFCE7;}
.predict-btn.selected{box-shadow:0 0 0 3px rgba(6,182,212,.3);}

/* Density Control */
.density-control{background:var(--lab-light);border-radius:var(--border-radius-xl);padding:var(--space-lg);
    margin-bottom:var(--space-lg);text-align:center;}
.density-label{font-weight:700;font-size:.875rem;margin-bottom:var(--space-sm);color:var(--color-text);}
.density-slider{width:80%;max-width:300px;margin:var(--space-sm) auto;display:block;accent-color:var(--lab-color);}
.density-value{font-size:.8125rem;font-weight:600;color:var(--lab-color);margin-top:4px;}

.lab-feedback{text-align:center;padding:var(--space-lg);border-radius:var(--border-radius);
    font-weight:700;font-size:.9375rem;margin-bottom:var(--space-md);display:none;}
.lab-feedback.show{display:block;}
.lab-feedback.correct{background:#DCFCE7;color:#15803D;}
.lab-feedback.wrong{background:#FEE2E2;color:#B91C1C;}
.lab-complete-bar{display:flex;align-items:center;justify-content:center;gap:var(--space-md);margin-bottom:var(--space-xl);}
@media(max-width:767px){.object-cards{gap:6px;}.object-card{min-width:80px;padding:8px 10px;}}
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

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><asp:Literal ID="litPageTitle" runat="server" Text="Sink or Float Master" /></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="lab-section" style="text-align:center;padding:var(--space-3xl);">
        <div style="font-size:3rem;margin-bottom:var(--space-md);">🌊</div>
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

<%-- Step 1: Predict & Test --%>
<div class="lab-section" id="section1">
    <div class="lab-section-title"><i class="bi bi-1-circle-fill" style="color:#06B6D4;"></i> <asp:Literal ID="litStep1Title" runat="server" /></div>
    <div class="lab-instruction"><asp:Literal ID="litStep1Inst" runat="server" /></div>

    <div class="object-cards" id="objectCards">
        <div class="object-card" data-obj="marble" data-sink="1" data-icon="🔮" onclick="selectObject(this)">
            <div class="obj-icon">🔮</div><div class="obj-name"><asp:Literal ID="litObjMarble" runat="server" Text="Marble" /></div>
        </div>
        <div class="object-card" data-obj="cork" data-sink="0" data-icon="🪵" onclick="selectObject(this)">
            <div class="obj-icon">🪵</div><div class="obj-name"><asp:Literal ID="litObjCork" runat="server" Text="Cork" /></div>
        </div>
        <div class="object-card" data-obj="ball" data-sink="0" data-icon="⚽" onclick="selectObject(this)">
            <div class="obj-icon">⚽</div><div class="obj-name"><asp:Literal ID="litObjBall" runat="server" Text="Plastic Ball" /></div>
        </div>
        <div class="object-card" data-obj="spoon" data-sink="1" data-icon="🥄" onclick="selectObject(this)">
            <div class="obj-icon">🥄</div><div class="obj-name"><asp:Literal ID="litObjSpoon" runat="server" Text="Metal Spoon" /></div>
        </div>
        <div class="object-card" data-obj="wood" data-sink="0" data-icon="🪵" onclick="selectObject(this)">
            <div class="obj-icon">🧱</div><div class="obj-name"><asp:Literal ID="litObjWood" runat="server" Text="Wood Block" /></div>
        </div>
    </div>

    <div id="predictArea" style="display:none;">
        <div style="text-align:center;font-weight:700;margin-bottom:var(--space-sm);" id="predictLabel"></div>
        <div class="predict-btns">
            <button type="button" class="predict-btn sink" onclick="predict('sink')">⬇️ <asp:Literal ID="litSink" runat="server" Text="Sink" /></button>
            <button type="button" class="predict-btn float" onclick="predict('float')">⬆️ <asp:Literal ID="litFloat" runat="server" Text="Float" /></button>
        </div>
    </div>

    <div class="tank-container">
        <div class="water-tank" id="waterTank">
            <div class="water-level" id="waterLevel"></div>
            <div class="tank-label" id="tankLabel"></div>
            <div class="tank-object" id="tankObj" style="display:none;"></div>
        </div>
    </div>
    <div class="lab-feedback" id="testFeedback"></div>
</div>

<%-- Step 2: Density Control --%>
<div class="lab-section" id="section2" style="display:none;">
    <div class="lab-section-title"><i class="bi bi-2-circle-fill" style="color:#06B6D4;"></i> <asp:Literal ID="litStep2Title" runat="server" /></div>
    <div class="lab-instruction"><asp:Literal ID="litStep2Inst" runat="server" /></div>

    <div class="density-control">
        <div class="density-label"><asp:Literal ID="litDensityLabel" runat="server" Text="Add Salt/Sugar to Water" /></div>
        <input type="range" class="density-slider" id="densitySlider" min="1" max="3" step="0.5" value="1" oninput="changeDensity(this.value)" />
        <div class="density-value" id="densityValue"></div>
    </div>

    <div class="tank-container">
        <div class="water-tank" id="waterTank2">
            <div class="water-level" id="waterLevel2" style="height:70%;"></div>
            <div class="tank-label" id="tankLabel2"></div>
            <div class="tank-object floating" id="tankObj2" style="display:none;"></div>
        </div>
    </div>
    <div class="lab-feedback" id="densityFeedback"></div>
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
var starsEarned=0, selectedObj=null, predictions=0, correctPredictions=0, testedCount=0, densityChanged=false;

var objects={
    marble:{sink:true,icon:'🔮',nameEN:'Marble',nameBM:'Guli'},
    cork:{sink:false,icon:'🪵',nameEN:'Cork',nameBM:'Gabus'},
    ball:{sink:false,icon:'⚽',nameEN:'Plastic Ball',nameBM:'Bola Plastik'},
    spoon:{sink:true,icon:'🥄',nameEN:'Metal Spoon',nameBM:'Sudu Logam'},
    wood:{sink:false,icon:'🧱',nameEN:'Wood Block',nameBM:'Blok Kayu'}
};

function selectObject(el){
    if(el.classList.contains('tested'))return;
    document.querySelectorAll('.object-card').forEach(function(c){c.classList.remove('active');});
    el.classList.add('active');
    selectedObj=el.getAttribute('data-obj');
    document.getElementById('predictArea').style.display='block';
    var name=lang==='BM'?objects[selectedObj].nameBM:objects[selectedObj].nameEN;
    document.getElementById('predictLabel').textContent=(lang==='BM'?'Ramalan anda untuk ':'Your prediction for ')+name+':';
    document.querySelectorAll('.predict-btn').forEach(function(b){b.classList.remove('selected');});
}

function predict(choice){
    if(!selectedObj)return;
    document.querySelectorAll('.predict-btn').forEach(function(b){b.classList.remove('selected');});
    event.target.closest('.predict-btn').classList.add('selected');

    predictions++;
    var obj=objects[selectedObj];
    var willSink=obj.sink;
    var correct=(choice==='sink'&&willSink)||(choice==='float'&&!willSink);
    if(correct) correctPredictions++;

    if(predictions===1&&starsEarned<1) earnStar(1);

    // Animate in tank
    var tankObj=document.getElementById('tankObj');
    tankObj.textContent=obj.icon;
    tankObj.style.display='block';
    tankObj.className='tank-object';
    tankObj.style.top='5%';

    setTimeout(function(){
        if(willSink){tankObj.className='tank-object sinking';}
        else{tankObj.className='tank-object floating';}
    },100);

    var fb=document.getElementById('testFeedback');
    if(correct){
        fb.className='lab-feedback show correct';
        fb.textContent=(lang==='BM'?'✓ Betul! ':'✓ Correct! ')+(willSink?(lang==='BM'?'Ia tenggelam!':'It sinks!'):(lang==='BM'?'Ia terapung!':'It floats!'));
    } else {
        fb.className='lab-feedback show wrong';
        fb.textContent=(lang==='BM'?'✗ Sebenarnya, ':'✗ Actually, ')+(willSink?(lang==='BM'?'ia tenggelam!':'it sinks!'):(lang==='BM'?'ia terapung!':'it floats!'));
    }

    // Mark tested
    var card=document.querySelector('.object-card[data-obj="'+selectedObj+'"]');
    card.classList.add('tested'); card.classList.remove('active');
    testedCount++;
    selectedObj=null;
    document.getElementById('predictArea').style.display='none';

    if(testedCount>=3&&starsEarned<2){earnStar(2); showDensitySection();}
    if(testedCount>=5) showDensitySection();
}

function showDensitySection(){
    document.getElementById('section2').style.display='block';
    document.getElementById('densityValue').textContent=(lang==='BM'?'Ketumpatan air: 1.0 g/cm³':'Water density: 1.0 g/cm³');
    document.getElementById('tankLabel2').textContent=(lang==='BM'?'Air Biasa':'Normal Water');
    // Show marble in tank2
    var t2=document.getElementById('tankObj2');
    t2.textContent='🔮'; t2.style.display='block'; t2.className='tank-object sinking';
}

function changeDensity(val){
    var d=parseFloat(val);
    document.getElementById('densityValue').textContent=(lang==='BM'?'Ketumpatan air: ':'Water density: ')+d.toFixed(1)+' g/cm³';

    var label=document.getElementById('tankLabel2');
    if(d<=1){label.textContent=lang==='BM'?'Air Biasa':'Normal Water';}
    else if(d<=2){label.textContent=lang==='BM'?'Air Garam':'Salt Water';}
    else{label.textContent=lang==='BM'?'Air Sangat Pekat':'Very Dense Water';}

    // Change water color
    var wl=document.getElementById('waterLevel2');
    var opacity=0.3+((d-1)/2)*0.4;
    wl.style.background='linear-gradient(180deg,rgba(6,182,212,'+opacity+') 0%,rgba(6,182,212,'+(opacity+0.2)+') 100%)';

    // Marble floats in dense water (density > 2.5)
    var t2=document.getElementById('tankObj2');
    if(d>=2.5){t2.className='tank-object floating';}
    else{t2.className='tank-object sinking';}

    if(!densityChanged){
        densityChanged=true;
        if(starsEarned<3) earnStar(3);
        var fb=document.getElementById('densityFeedback');
        fb.className='lab-feedback show correct';
        fb.textContent=lang==='BM'?'⭐ Hebat! Anda mengubah ketumpatan air! Objek boleh terapung dalam air yang lebih pekat.':'⭐ Great! You changed the water density! Objects can float in denser water.';
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
