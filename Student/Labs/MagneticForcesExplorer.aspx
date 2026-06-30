<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MagneticForcesExplorer.aspx.cs"
    Inherits="ScienceBuddy.Student.Labs.MagneticForcesExplorer" MasterPageFile="~/Site.Master" Title="Magnetic Forces Explorer" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--student:#FF6B2C;--student-light:#FFF0E8;}
.lab-hero{background:linear-gradient(135deg,#7C3AED 0%,#A78BFA 100%);border-radius:var(--border-radius-xl);
    padding:var(--space-2xl);color:#fff;position:relative;overflow:hidden;margin-bottom:var(--space-xl);}
.lab-hero::before{content:'🧲';position:absolute;font-size:6rem;opacity:.1;top:10px;right:40px;}
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
    padding:var(--space-md);background:#F8F0FF;border-radius:var(--border-radius);border-left:4px solid #7C3AED;}

/* Magnets */
.magnet-zone{display:flex;justify-content:center;align-items:center;gap:var(--space-xl);margin-bottom:var(--space-lg);flex-wrap:wrap;}
.magnet{width:120px;height:60px;border-radius:var(--border-radius);display:flex;overflow:hidden;
    box-shadow:0 4px 12px rgba(0,0,0,.15);cursor:pointer;transition:transform .2s;}
.magnet:hover{transform:scale(1.05);}
.magnet-n{background:#EF4444;color:#fff;flex:1;display:flex;align-items:center;justify-content:center;font-weight:800;font-size:1.25rem;}
.magnet-s{background:#2563EB;color:#fff;flex:1;display:flex;align-items:center;justify-content:center;font-weight:800;font-size:1.25rem;}
.pole-btns{display:flex;gap:var(--space-sm);justify-content:center;flex-wrap:wrap;margin-bottom:var(--space-lg);}
.pole-btn{padding:10px 20px;border-radius:var(--border-radius);font-weight:700;font-size:.9375rem;
    border:2px solid var(--border-color);background:var(--color-white);cursor:pointer;transition:all .2s;}
.pole-btn:hover{border-color:var(--color-primary);background:var(--color-primary-light);}
.pole-btn.selected{border-color:#7C3AED;background:#F3E8FF;color:#7C3AED;}
.pole-result{text-align:center;padding:var(--space-lg);border-radius:var(--border-radius);margin-bottom:var(--space-lg);
    font-family:var(--font-primary);font-size:1.25rem;font-weight:800;display:none;}
.pole-result.attract{background:#DCFCE7;color:#15803D;display:block;}
.pole-result.repel{background:#FEE2E2;color:#B91C1C;display:block;}

/* Sort objects */
.sort-zone{display:flex;gap:var(--space-xl);flex-wrap:wrap;justify-content:center;margin-bottom:var(--space-lg);}
.sort-bucket{min-width:200px;min-height:200px;border:3px dashed var(--border-color);border-radius:var(--border-radius-xl);
    padding:var(--space-md);text-align:center;flex:1;}
.sort-bucket-title{font-family:var(--font-primary);font-size:.875rem;font-weight:700;margin-bottom:var(--space-sm);
    padding:6px 12px;border-radius:var(--border-radius-full);display:inline-block;}
.sort-bucket.magnetic .sort-bucket-title{background:#DCFCE7;color:#15803D;}
.sort-bucket.non-magnetic .sort-bucket-title{background:#FEE2E2;color:#B91C1C;}
.sort-items{display:flex;flex-wrap:wrap;gap:var(--space-sm);justify-content:center;margin-bottom:var(--space-lg);}
.sort-item{padding:10px 16px;border-radius:var(--border-radius);background:var(--color-white);
    border:2px solid var(--border-color);font-weight:600;font-size:.875rem;cursor:pointer;
    transition:all .2s;display:flex;align-items:center;gap:6px;}
.sort-item:hover{border-color:#7C3AED;background:#F3E8FF;transform:translateY(-2px);}
.sort-item.placed{opacity:.5;pointer-events:none;}
.sort-item.correct{border-color:#22C55E;background:#DCFCE7;}
.sort-item.wrong{border-color:#EF4444;background:#FEE2E2;}
.sorted-item{display:inline-flex;align-items:center;gap:4px;padding:6px 12px;border-radius:var(--border-radius);
    font-size:.8125rem;font-weight:600;margin:4px;background:#F0F7FF;border:1px solid var(--border-color);}

.lab-feedback{text-align:center;padding:var(--space-lg);border-radius:var(--border-radius);
    font-weight:700;font-size:.9375rem;margin-bottom:var(--space-md);display:none;}
.lab-feedback.show{display:block;}
.lab-feedback.correct{background:#DCFCE7;color:#15803D;}
.lab-feedback.wrong{background:#FEE2E2;color:#B91C1C;}
.lab-complete-bar{display:flex;align-items:center;justify-content:center;gap:var(--space-md);margin-bottom:var(--space-xl);}
@media(max-width:767px){.magnet-zone{flex-direction:column;}.sort-zone{flex-direction:column;}}
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
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><asp:Literal ID="litPageTitle" runat="server" Text="Magnetic Forces Explorer" /></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="lab-section" style="text-align:center;padding:var(--space-3xl);">
        <div style="font-size:3rem;margin-bottom:var(--space-md);">🧲</div>
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

<%-- Step 1: Pole Testing --%>
<div class="lab-section" id="section1">
    <div class="lab-section-title"><i class="bi bi-1-circle-fill" style="color:#7C3AED;"></i> <asp:Literal ID="litStep1Title" runat="server" /></div>
    <div class="lab-instruction"><asp:Literal ID="litStep1Inst" runat="server" /></div>
    <div class="magnet-zone">
        <div class="magnet"><div class="magnet-n">N</div><div class="magnet-s">S</div></div>
        <div class="magnet"><div class="magnet-s">S</div><div class="magnet-n">N</div></div>
    </div>
    <div class="pole-btns">
        <button type="button" class="pole-btn" onclick="testPole('NN')">N — N</button>
        <button type="button" class="pole-btn" onclick="testPole('SS')">S — S</button>
        <button type="button" class="pole-btn" onclick="testPole('NS')">N — S</button>
    </div>
    <div class="pole-result" id="poleResult"></div>
    <div class="lab-feedback" id="poleFeedback"></div>
</div>

<%-- Step 2: Sort Objects --%>
<div class="lab-section" id="section2">
    <div class="lab-section-title"><i class="bi bi-2-circle-fill" style="color:#7C3AED;"></i> <asp:Literal ID="litStep2Title" runat="server" /></div>
    <div class="lab-instruction"><asp:Literal ID="litStep2Inst" runat="server" /></div>

    <div class="sort-items" id="objectItems">
        <div class="sort-item" data-obj="nail" data-mag="1" draggable="true" ondragstart="dragStart(event)" onclick="selectObj(this)"><i class="bi bi-nut-fill"></i> <asp:Literal ID="litObjNail" runat="server" Text="Nail" /></div>
        <div class="sort-item" data-obj="clip" data-mag="1" draggable="true" ondragstart="dragStart(event)" onclick="selectObj(this)"><i class="bi bi-paperclip"></i> <asp:Literal ID="litObjClip" runat="server" Text="Paperclip" /></div>
        <div class="sort-item" data-obj="coin" data-mag="1" draggable="true" ondragstart="dragStart(event)" onclick="selectObj(this)"><i class="bi bi-coin"></i> <asp:Literal ID="litObjCoin" runat="server" Text="Coin" /></div>
        <div class="sort-item" data-obj="pencil" data-mag="0" draggable="true" ondragstart="dragStart(event)" onclick="selectObj(this)"><i class="bi bi-pencil-fill"></i> <asp:Literal ID="litObjPencil" runat="server" Text="Pencil" /></div>
        <div class="sort-item" data-obj="eraser" data-mag="0" draggable="true" ondragstart="dragStart(event)" onclick="selectObj(this)"><i class="bi bi-eraser-fill"></i> <asp:Literal ID="litObjEraser" runat="server" Text="Eraser" /></div>
        <div class="sort-item" data-obj="ruler" data-mag="0" draggable="true" ondragstart="dragStart(event)" onclick="selectObj(this)"><i class="bi bi-rulers"></i> <asp:Literal ID="litObjRuler" runat="server" Text="Plastic Ruler" /></div>
    </div>

    <div class="sort-zone">
        <div class="sort-bucket magnetic" id="bucketMag" onclick="placeObj('mag')"
             ondragover="event.preventDefault();this.style.borderColor='#22C55E';this.style.background='#F0FDF4';"
             ondragleave="this.style.borderColor='';this.style.background='';"
             ondrop="dropObj(event,'mag');this.style.borderColor='';this.style.background='';">
            <div class="sort-bucket-title"><i class="bi bi-magnet-fill"></i> <asp:Literal ID="litMagnetic" runat="server" Text="Magnetic" /></div>
            <div id="magItems"></div>
        </div>
        <div class="sort-bucket non-magnetic" id="bucketNon" onclick="placeObj('non')"
             ondragover="event.preventDefault();this.style.borderColor='#EF4444';this.style.background='#FEF2F2';"
             ondragleave="this.style.borderColor='';this.style.background='';"
             ondrop="dropObj(event,'non');this.style.borderColor='';this.style.background='';">
            <div class="sort-bucket-title"><i class="bi bi-x-circle-fill"></i> <asp:Literal ID="litNonMagnetic" runat="server" Text="Non-Magnetic" /></div>
            <div id="nonItems"></div>
        </div>
    </div>
    <div class="lab-feedback" id="sortFeedback"></div>
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
var poleTested=false, sortCorrect=0, sortTotal=6, selectedObj=null, starsEarned=0;
var lang='<%= CurrentLanguage %>';

function testPole(combo){
    var res=document.getElementById('poleResult');
    var fb=document.getElementById('poleFeedback');
    document.querySelectorAll('.pole-btn').forEach(function(b){b.classList.remove('selected');});
    event.target.classList.add('selected');

    if(combo==='NS'){
        res.className='pole-result attract'; res.innerHTML='🧲 '+(lang==='BM'?'Menarik! (Kutub berbeza)':'Attract! (Different poles)');
    } else {
        res.className='pole-result repel'; res.innerHTML='↔️ '+(lang==='BM'?'Menolak! (Kutub sama)':'Repel! (Same poles)');
    }
    if(!poleTested){ poleTested=true; earnStar(1);
        fb.className='lab-feedback show correct'; fb.textContent=lang==='BM'?'⭐ Hebat! Anda faham kutub magnet.':'⭐ Great! You understand magnet poles.'; }
}

function dragStart(e){
    e.dataTransfer.setData('text/plain',e.target.getAttribute('data-obj'));
    e.dataTransfer.effectAllowed='move';
    selectedObj=e.target;
    e.target.style.opacity='0.5';
    setTimeout(function(){e.target.style.opacity='1';},300);
}

function dropObj(e,bucket){
    e.preventDefault();
    var objId=e.dataTransfer.getData('text/plain');
    var el=document.querySelector('.sort-item[data-obj="'+objId+'"]');
    if(el && !el.classList.contains('placed')){selectedObj=el;placeObj(bucket);}
}

function selectObj(el){ if(el.classList.contains('placed'))return; selectedObj=el; 
    document.querySelectorAll('.sort-item').forEach(function(i){i.style.outline='';});
    el.style.outline='3px solid #7C3AED'; }

function placeObj(bucket){
    if(!selectedObj)return;
    var isMag=selectedObj.getAttribute('data-mag')==='1';
    var correct=(bucket==='mag'&&isMag)||(bucket==='non'&&!isMag);
    var name=selectedObj.textContent.trim();
    var target=bucket==='mag'?document.getElementById('magItems'):document.getElementById('nonItems');
    var span=document.createElement('div'); span.className='sorted-item';
    span.textContent=name;

    if(correct){ selectedObj.classList.add('placed','correct'); span.style.background='#DCFCE7'; sortCorrect++; }
    else { selectedObj.classList.add('placed','wrong'); span.style.background='#FEE2E2'; }
    target.appendChild(span); selectedObj.style.outline=''; selectedObj=null;

    var fb=document.getElementById('sortFeedback');
    if(correct){fb.className='lab-feedback show correct';fb.textContent=lang==='BM'?'✓ Betul!':'✓ Correct!';}
    else{fb.className='lab-feedback show wrong';fb.textContent=lang==='BM'?'✗ Cuba lagi!':'✗ Try again!';}
    setTimeout(function(){fb.className='lab-feedback';},1500);

    // Check if all placed
    if(document.querySelectorAll('.sort-item.placed').length>=sortTotal){
        if(sortCorrect>=sortTotal) earnStar(3);
        else earnStar(2);
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
