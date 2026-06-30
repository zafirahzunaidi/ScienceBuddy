<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SinkOrFloatMaster.aspx.cs"
    Inherits="ScienceBuddy.Student.Labs.SinkOrFloatMaster" MasterPageFile="~/Site.Master" Title="Sink or Float Master" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--lab:#0EA5E9;--lab-light:#E0F2FE;--lab-dark:#0369A1;--lab-green:#22C55E;--lab-orange:#F97316;}

.sf-hero{background:linear-gradient(135deg,#0EA5E9 0%,#38BDF8 50%,#7DD3FC 100%);border-radius:var(--border-radius-xl);
    padding:var(--space-xl) var(--space-2xl);color:#fff;position:relative;overflow:hidden;margin-bottom:var(--space-xl);}
.sf-hero-back{display:inline-flex;align-items:center;gap:6px;font-size:.8rem;font-weight:600;
    color:rgba(255,255,255,.8);text-decoration:none;margin-bottom:var(--space-sm);}
.sf-hero-back:hover{color:#fff;text-decoration:none;}
.sf-hero-title{font-family:var(--font-primary);font-size:1.375rem;font-weight:800;margin-bottom:4px;}
.sf-hero-desc{font-size:.875rem;opacity:.9;max-width:500px;line-height:1.4;}
.sf-hero-diff{display:inline-flex;align-items:center;gap:4px;padding:3px 10px;border-radius:var(--border-radius-full);
    font-size:.7rem;font-weight:700;background:rgba(255,255,255,.2);margin-top:var(--space-sm);}

/* Tank */
.sf-tank-wrap{display:flex;justify-content:center;margin-bottom:var(--space-xl);}
.sf-tank{width:280px;height:320px;border:4px solid #94A3B8;border-top:none;border-radius:0 0 20px 20px;
    position:relative;background:linear-gradient(180deg,transparent 25%,rgba(14,165,233,.15) 25%,rgba(14,165,233,.3) 100%);
    overflow:hidden;box-shadow:inset 0 0 30px rgba(14,165,233,.08);}
.sf-waterline{position:absolute;top:25%;left:0;right:0;height:3px;background:rgba(14,165,233,.5);z-index:2;
    box-shadow:0 0 6px rgba(14,165,233,.3);}
.sf-waterline::after{content:'';position:absolute;top:-1px;left:0;right:0;height:5px;
    background:repeating-linear-gradient(90deg,transparent,transparent 10px,rgba(255,255,255,.3) 10px,rgba(255,255,255,.3) 20px);
    animation:sf-wave 3s linear infinite;}
@keyframes sf-wave{from{background-position:0 0;}to{background-position:40px 0;}}
.sf-water-label{position:absolute;top:22%;right:8px;font-size:.6rem;font-weight:700;color:var(--lab);
    background:rgba(255,255,255,.8);padding:2px 6px;border-radius:4px;z-index:3;}
.sf-tank-floor{position:absolute;bottom:0;left:0;right:0;height:8px;background:#CBD5E1;border-radius:0 0 16px 16px;}

/* Object in tank */
.sf-obj-in-tank{position:absolute;left:50%;transform:translateX(-50%);font-size:2.5rem;z-index:5;
    transition:top 1.5s cubic-bezier(.25,.46,.45,.94);opacity:0;}
.sf-obj-in-tank.dropping{opacity:1;top:5%;}
.sf-obj-in-tank.floating{top:18%;animation:sf-bob 2s ease-in-out infinite;}
.sf-obj-in-tank.sinking{top:75%;}
@keyframes sf-bob{0%,100%{transform:translateX(-50%) translateY(0);}50%{transform:translateX(-50%) translateY(-6px);}}

/* Splash */
.sf-splash{position:absolute;top:23%;left:50%;transform:translateX(-50%);width:60px;height:20px;z-index:10;opacity:0;}
.sf-splash.show{animation:sf-splash-anim .6s ease-out forwards;}
@keyframes sf-splash-anim{0%{opacity:1;transform:translateX(-50%) scale(.5);}50%{opacity:.8;transform:translateX(-50%) scale(1.3);}100%{opacity:0;transform:translateX(-50%) scale(1.5);}}
.sf-splash-dot{position:absolute;width:6px;height:6px;border-radius:50%;background:var(--lab);}
.sf-splash-dot:nth-child(1){left:10px;top:5px;}
.sf-splash-dot:nth-child(2){left:25px;top:0;}
.sf-splash-dot:nth-child(3){left:40px;top:5px;}
.sf-splash-dot:nth-child(4){left:15px;top:12px;}
.sf-splash-dot:nth-child(5){left:35px;top:12px;}

/* Objects panel */
.sf-objects{display:flex;flex-wrap:wrap;gap:var(--space-sm);justify-content:center;margin-bottom:var(--space-lg);}
.sf-obj-card{width:90px;padding:var(--space-md) var(--space-sm);border-radius:var(--border-radius-xl);
    border:2px solid var(--border-color);background:#fff;text-align:center;cursor:pointer;transition:all .2s;}
.sf-obj-card:hover{border-color:var(--lab);transform:translateY(-3px);box-shadow:0 4px 12px rgba(14,165,233,.2);}
.sf-obj-card.selected{border-color:var(--lab);background:var(--lab-light);box-shadow:0 4px 12px rgba(14,165,233,.3);}
.sf-obj-card.tested{opacity:.6;}
.sf-obj-card .obj-icon{font-size:1.75rem;display:block;margin-bottom:4px;}
.sf-obj-card .obj-name{font-size:.7rem;font-weight:700;color:var(--color-text);}
</style>
<style>
/* Controls */
.sf-controls{display:flex;flex-wrap:wrap;gap:var(--space-md);justify-content:center;align-items:center;margin-bottom:var(--space-lg);}
.sf-water-btns{display:flex;gap:6px;flex-wrap:wrap;}
.sf-water-btn{padding:8px 16px;border-radius:var(--border-radius-full);font-size:.8rem;font-weight:700;
    border:1.5px solid var(--border-color);background:#fff;cursor:pointer;transition:all .2s;}
.sf-water-btn:hover{border-color:var(--lab);}
.sf-water-btn.active{background:var(--lab);color:#fff;border-color:var(--lab);}
.sf-predict{display:flex;gap:6px;}
.sf-predict-btn{padding:8px 16px;border-radius:var(--border-radius-full);font-size:.8rem;font-weight:700;
    border:1.5px solid var(--border-color);background:#fff;cursor:pointer;transition:all .2s;}
.sf-predict-btn:hover{border-color:var(--lab-orange);}
.sf-predict-btn.active{border-color:var(--lab-orange);background:#FFF7ED;color:var(--lab-orange);}
.sf-drop-btn{padding:10px 24px;border-radius:var(--border-radius-full);font-size:.9rem;font-weight:700;
    background:var(--lab);color:#fff;border:none;cursor:pointer;transition:all .2s;
    box-shadow:0 4px 12px rgba(14,165,233,.3);}
.sf-drop-btn:hover{background:var(--lab-dark);transform:translateY(-2px);}
.sf-drop-btn:disabled{opacity:.5;cursor:not-allowed;transform:none!important;}

/* Observation */
.sf-observation{background:#fff;border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);
    box-shadow:var(--shadow-sm);padding:var(--space-lg);margin-bottom:var(--space-xl);}
.sf-obs-title{font-family:var(--font-primary);font-size:1rem;font-weight:700;margin-bottom:var(--space-md);
    display:flex;align-items:center;gap:6px;color:var(--color-text);}
.sf-obs-grid{display:grid;grid-template-columns:1fr 1fr;gap:var(--space-sm);margin-bottom:var(--space-md);}
.sf-obs-item{padding:8px 12px;background:#F8FAFC;border-radius:var(--border-radius);border:1px solid var(--border-color);}
.sf-obs-item label{font-size:.7rem;font-weight:600;color:var(--color-text-muted);display:block;margin-bottom:2px;}
.sf-obs-item span{font-size:.85rem;font-weight:700;color:var(--color-text);}
.sf-obs-expl{background:var(--lab-light);border-radius:var(--border-radius);padding:var(--space-md);
    font-size:.8125rem;line-height:1.5;color:var(--color-text);border-left:3px solid var(--lab);}

/* Results table */
.sf-results{margin-bottom:var(--space-xl);}
.sf-results table{width:100%;border-collapse:separate;border-spacing:0;border-radius:var(--border-radius-lg);
    overflow:hidden;border:1.5px solid var(--border-color);font-size:.75rem;}
.sf-results th{background:var(--lab-light);color:var(--lab-dark);padding:8px 10px;font-weight:700;text-align:left;}
.sf-results td{padding:6px 10px;border-top:1px solid #F1F5F9;}
.sf-results .badge-float{background:#DCFCE7;color:#15803D;padding:2px 8px;border-radius:var(--border-radius-full);font-weight:700;font-size:.65rem;}
.sf-results .badge-sink{background:#FEE2E2;color:#B91C1C;padding:2px 8px;border-radius:var(--border-radius-full);font-weight:700;font-size:.65rem;}

/* Section */
.sf-section{background:#fff;border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);
    box-shadow:var(--shadow-sm);padding:var(--space-xl);margin-bottom:var(--space-xl);}
.sf-section-title{font-family:var(--font-primary);font-size:1rem;font-weight:700;margin-bottom:var(--space-sm);
    display:flex;align-items:center;gap:8px;color:var(--color-text);}
.sf-instruction{font-size:.875rem;color:var(--color-text-secondary);line-height:1.5;margin-bottom:var(--space-lg);
    padding:var(--space-md);background:var(--lab-light);border-radius:var(--border-radius);border-left:3px solid var(--lab);}

/* Hidden code-behind controls */
.sf-hidden{display:none;}
/* Error */
.sf-error{background:#fff;border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);padding:var(--space-2xl);text-align:center;}

@media(max-width:767px){.sf-tank{width:220px;height:260px;}.sf-obj-card{width:75px;}.sf-obs-grid{grid-template-columns:1fr;}.sf-controls{flex-direction:column;}}
</style>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label">Main</div>
        <a href="<%: ResolveUrl("~/Student/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label">Dashboard</span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Learn</div>
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label">My Learning</span></a>
        <a href="<%: ResolveUrl("~/Student/VirtualLabs.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-eyedropper item-icon"></i><span class="item-label">Virtual Labs</span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Student/MyProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a></div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><asp:Literal ID="litPageTitle" runat="server" Text="Sink or Float" /></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="sf-error">
        <div style="font-size:2.5rem;margin-bottom:var(--space-md);"><i class="bi bi-exclamation-triangle-fill" style="color:var(--lab-orange);"></i></div>
        <div style="font-family:var(--font-primary);font-size:1.125rem;font-weight:700;margin-bottom:6px;"><asp:Literal ID="litErrorTitle" runat="server" /></div>
        <div style="color:var(--color-text-secondary);margin-bottom:var(--space-lg);"><asp:Literal ID="litErrorDesc" runat="server" /></div>
        <a href="<%: ResolveUrl("~/Student/VirtualLabs.aspx") %>" class="sf-drop-btn"><i class="bi bi-arrow-left"></i> <asp:Literal ID="litErrorBtn" runat="server" /></a>
    </div>
</asp:Panel>

<asp:Panel ID="pnlMain" runat="server">

<div class="sf-hero">
    <a href="<%: ResolveUrl("~/Student/VirtualLabs.aspx") %>" class="sf-hero-back"><i class="bi bi-arrow-left"></i> <asp:Literal ID="litBack" runat="server" /></a>
    <div class="sf-hero-title"><asp:Literal ID="litLabTitle" runat="server" /></div>
    <div class="sf-hero-desc"><asp:Literal ID="litLabDesc" runat="server" /></div>
    <div class="sf-hero-diff"><i class="bi bi-speedometer"></i> <asp:Literal ID="litDiff" runat="server" /></div>
</div>

<%-- Hidden code-behind Literals --%>
<span class="sf-hidden"><asp:Literal ID="litStep1Title" runat="server" /><asp:Literal ID="litStep1Inst" runat="server" /><asp:Literal ID="litStep2Title" runat="server" /><asp:Literal ID="litStep2Inst" runat="server" /><asp:Literal ID="litObjMarble" runat="server" /><asp:Literal ID="litObjCork" runat="server" /><asp:Literal ID="litObjBall" runat="server" /><asp:Literal ID="litObjSpoon" runat="server" /><asp:Literal ID="litObjWood" runat="server" /><asp:Literal ID="litSink" runat="server" /><asp:Literal ID="litFloat" runat="server" /><asp:Literal ID="litDensityLabel" runat="server" /></span>

<%-- Objects --%>
<div class="sf-section">
    <div class="sf-section-title"><i class="bi bi-box-seam" style="color:var(--lab);"></i> <span id="lblSelectObj"></span></div>
    <div class="sf-instruction" id="instrText"></div>
    <div class="sf-objects" id="objectsPanel"></div>
</div>

<%-- Prediction + Drop --%>
<div class="sf-controls">
    <div><span id="lblPredict" style="font-size:.85rem;font-weight:700;margin-right:8px;"></span>
        <div class="sf-predict" id="predictBtns"></div>
    </div>
    <button type="button" class="sf-drop-btn" id="btnDrop" disabled onclick="dropObject()"><i class="bi bi-droplet-fill"></i> <span id="lblDrop"></span></button>
</div>

<%-- Tank --%>
<div class="sf-tank-wrap">
    <div class="sf-tank" id="tank">
        <div class="sf-waterline"></div>
        <div class="sf-water-label" id="waterLabel">H₂O</div>
        <div class="sf-tank-floor"></div>
        <div class="sf-splash" id="splash"><div class="sf-splash-dot"></div><div class="sf-splash-dot"></div><div class="sf-splash-dot"></div><div class="sf-splash-dot"></div><div class="sf-splash-dot"></div></div>
        <div class="sf-obj-in-tank" id="objInTank"></div>
    </div>
</div>

<%-- Observation --%>
<div class="sf-observation" id="obsPanel" style="display:none;">
    <div class="sf-obs-title"><i class="bi bi-eye-fill" style="color:var(--lab);"></i> <span id="lblObservation"></span></div>
    <div class="sf-obs-grid">
        <div class="sf-obs-item"><label id="lblObsObj"></label><span id="obsObjVal">-</span></div>
        <div class="sf-obs-item"><label id="lblObsWater"></label><span id="obsWaterVal">-</span></div>
        <div class="sf-obs-item"><label id="lblObsPred"></label><span id="obsPredVal">-</span></div>
        <div class="sf-obs-item"><label id="lblObsResult"></label><span id="obsResultVal">-</span></div>
    </div>
    <div class="sf-obs-expl" id="obsExpl"></div>
</div>

<%-- Results Table --%>
<div class="sf-results" id="resultsSection" style="display:none;">
    <div class="sf-section-title"><i class="bi bi-table" style="color:var(--lab);"></i> <span id="lblResults"></span></div>
    <table><thead><tr><th id="rthObj"></th><th id="rthWater"></th><th id="rthPred"></th><th id="rthResult"></th></tr></thead>
        <tbody id="resultsBody"></tbody>
    </table>
</div>

<%-- Complete --%>
<div style="text-align:center;">
    <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
        <div style="background:#DCFCE7;border:1.5px solid #BBF7D0;border-radius:var(--border-radius);padding:12px 18px;display:inline-block;font-weight:700;color:#15803D;margin-bottom:var(--space-md);">
            <i class="bi bi-check-circle-fill"></i> <asp:Literal ID="litSuccess" runat="server" />
        </div>
    </asp:Panel>
    <asp:Button ID="btnComplete" runat="server" CssClass="sf-drop-btn" OnClick="btnComplete_Click" CausesValidation="false" />
</div>

</asp:Panel>
</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
var lang='<%= CurrentLanguage %>';
function T(en,bm){return lang==='BM'?bm:en;}

var objects=[
    {id:'marble',icon:'🔮',nameEN:'Marble',nameBM:'Guli',sinks:true,
     explEN:'A marble is heavy and small. It sinks!',explBM:'Guli berat dan kecil. Ia tenggelam!'},
    {id:'cork',icon:'🟤',nameEN:'Cork',nameBM:'Gabus',sinks:false,
     explEN:'Cork is very light. It floats on water!',explBM:'Gabus sangat ringan. Ia terapung di atas air!'},
    {id:'ball',icon:'🏐',nameEN:'Plastic Ball',nameBM:'Bola Plastik',sinks:false,
     explEN:'A plastic ball has air inside. It floats!',explBM:'Bola plastik ada udara di dalam. Ia terapung!'},
    {id:'spoon',icon:'🥄',nameEN:'Metal Spoon',nameBM:'Sudu Logam',sinks:true,
     explEN:'Metal is heavy. The spoon sinks to the bottom.',explBM:'Logam berat. Sudu tenggelam ke dasar.'},
    {id:'wood',icon:'🪵',nameEN:'Wood Block',nameBM:'Blok Kayu',sinks:false,
     explEN:'Wood is lighter than water. It floats!',explBM:'Kayu lebih ringan daripada air. Ia terapung!'}
];

var selectedObj=null,prediction='',experiments=0;

function init(){
    document.getElementById('lblSelectObj').textContent=T('Pick an object','Pilih satu objek');
    document.getElementById('instrText').textContent=T('Choose an object, guess if it will sink or float, then drop it in the water to find out!','Pilih objek, teka sama ada ia tenggelam atau terapung, kemudian jatuhkan ke dalam air untuk ketahui!');
    document.getElementById('lblPredict').textContent=T('Will it sink or float?','Adakah ia tenggelam atau terapung?');
    document.getElementById('lblDrop').textContent=T('Drop it!','Jatuhkan!');
    document.getElementById('lblObservation').textContent=T('What happened?','Apa yang berlaku?');
    document.getElementById('lblObsObj').textContent=T('Object','Objek');
    document.getElementById('lblObsWater').textContent=T('Water','Air');
    document.getElementById('lblObsPred').textContent=T('Your Guess','Tekaan Anda');
    document.getElementById('lblObsResult').textContent=T('What Happened','Apa Berlaku');
    document.getElementById('lblResults').textContent=T('My Experiments','Eksperimen Saya');
    document.getElementById('rthObj').textContent=T('Object','Objek');
    document.getElementById('rthWater').textContent=T('Water','Air');
    document.getElementById('rthPred').textContent=T('Guess','Tekaan');
    document.getElementById('rthResult').textContent=T('Result','Keputusan');
    document.getElementById('waterLabel').textContent=T('Water','Air');

    // Render objects
    var html='';
    objects.forEach(function(o){
        html+='<div class="sf-obj-card" data-id="'+o.id+'" onclick="selectObject(\''+o.id+'\')">'+
            '<span class="obj-icon">'+o.icon+'</span><span class="obj-name">'+T(o.nameEN,o.nameBM)+'</span></div>';
    });
    document.getElementById('objectsPanel').innerHTML=html;

    // Predict buttons
    document.getElementById('predictBtns').innerHTML=
        '<button type="button" class="sf-predict-btn" onclick="setPrediction(\'float\')"><i class="bi bi-arrow-up"></i> '+T('Float','Terapung')+'</button>'+
        '<button type="button" class="sf-predict-btn" onclick="setPrediction(\'sink\')"><i class="bi bi-arrow-down"></i> '+T('Sink','Tenggelam')+'</button>';
}

function selectObject(id){
    selectedObj=objects.find(function(o){return o.id===id;});
    document.querySelectorAll('.sf-obj-card').forEach(function(c){c.classList.remove('selected');});
    document.querySelector('.sf-obj-card[data-id="'+id+'"]').classList.add('selected');
    resetTank();checkReady();
}

function setPrediction(p){
    prediction=p;
    document.querySelectorAll('.sf-predict-btn').forEach(function(b){b.classList.remove('active');});
    event.target.closest('.sf-predict-btn').classList.add('active');
    checkReady();
}

function checkReady(){document.getElementById('btnDrop').disabled=!(selectedObj&&prediction);}

function resetTank(){
    var obj=document.getElementById('objInTank');
    obj.className='sf-obj-in-tank';obj.style.top='5%';obj.innerHTML='';
    document.getElementById('splash').classList.remove('show');
}

function dropObject(){
    if(!selectedObj||!prediction)return;
    document.getElementById('btnDrop').disabled=true;

    var objEl=document.getElementById('objInTank');
    var splash=document.getElementById('splash');
    objEl.innerHTML=selectedObj.icon;
    objEl.className='sf-obj-in-tank';
    objEl.style.top='-10%';objEl.style.opacity='1';

    var floats=!selectedObj.sinks;
    var resultText=floats?T('Float!','Terapung!'):T('Sink!','Tenggelam!');

    setTimeout(function(){objEl.style.top='20%';objEl.className='sf-obj-in-tank dropping';},50);
    setTimeout(function(){splash.classList.add('show');},800);
    setTimeout(function(){
        splash.classList.remove('show');
        if(floats){objEl.className='sf-obj-in-tank floating';objEl.style.top='18%';}
        else{objEl.className='sf-obj-in-tank sinking';objEl.style.top='75%';}
    },1400);
    setTimeout(function(){
        showObservation(floats,resultText);
        addToLog(resultText,floats);
        document.getElementById('btnDrop').disabled=false;
    },2500);
}

function showObservation(floats,resultText){
    var panel=document.getElementById('obsPanel');panel.style.display='block';
    document.getElementById('obsObjVal').textContent=T(selectedObj.nameEN,selectedObj.nameBM);
    document.getElementById('obsWaterVal').textContent=T('Plain Water','Air Biasa');
    document.getElementById('obsPredVal').textContent=prediction==='float'?T('Float','Terapung'):T('Sink','Tenggelam');
    document.getElementById('obsResultVal').innerHTML='<span class="'+(floats?'badge-float':'badge-sink')+'">'+resultText+'</span>';
    document.getElementById('obsExpl').innerHTML='<i class="bi bi-lightbulb-fill" style="color:var(--lab-orange);margin-right:6px;"></i>'+T(selectedObj.explEN,selectedObj.explBM);
}

function addToLog(resultText,floats){
    experiments++;
    document.getElementById('resultsSection').style.display='block';
    var tbody=document.getElementById('resultsBody');
    var tr=document.createElement('tr');
    tr.innerHTML='<td>'+selectedObj.icon+' '+T(selectedObj.nameEN,selectedObj.nameBM)+'</td>'+
        '<td>'+T('Water','Air')+'</td>'+
        '<td>'+(prediction==='float'?T('Float','Terapung'):T('Sink','Tenggelam'))+'</td>'+
        '<td><span class="'+(floats?'badge-float':'badge-sink')+'">'+resultText+'</span></td>';
    tbody.insertBefore(tr,tbody.firstChild);
    if(experiments>=3){document.getElementById('<%= btnComplete.ClientID %>').style.display='inline-block';}
}

document.addEventListener('DOMContentLoaded',init);
</script>
</asp:Content>
