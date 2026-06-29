<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LitmusTest.aspx.cs"
    Inherits="ScienceBuddy.Student.Labs.LitmusTest" MasterPageFile="~/Site.Master" Title="Litmus Test Lab" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--lab-red:#DC2626;--lab-blue:#2563EB;}
.lab-hero{background:linear-gradient(135deg,#DC2626 0%,#2563EB 100%);border-radius:var(--border-radius-xl);
    padding:var(--space-2xl);color:#fff;position:relative;overflow:hidden;margin-bottom:var(--space-xl);}
.lab-hero::before{content:'🧪';position:absolute;font-size:6rem;opacity:.1;top:10px;right:40px;}
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

/* Test Tubes */
.tubes-row{display:flex;flex-wrap:wrap;gap:var(--space-md);justify-content:center;margin-bottom:var(--space-xl);}
.tube-card{width:100px;text-align:center;cursor:pointer;padding:var(--space-md);border-radius:var(--border-radius);
    border:2px solid var(--border-color);transition:all .2s;background:var(--color-white);}
.tube-card:hover{border-color:var(--lab-red);transform:translateY(-3px);box-shadow:0 4px 12px rgba(220,38,38,.15);}
.tube-card.selected{border-color:var(--lab-red);background:#FEF2F2;}
.tube-card.tested{opacity:.6;}
.tube-visual{width:32px;height:70px;margin:0 auto var(--space-sm);border-radius:0 0 16px 16px;border:2px solid #ccc;
    border-top:none;position:relative;overflow:hidden;}
.tube-visual::before{content:'';position:absolute;bottom:0;left:0;right:0;height:60%;border-radius:0 0 14px 14px;}
.tube-visual.c-yellow::before{background:#FBBF24;}
.tube-visual.c-blue::before{background:#93C5FD;}
.tube-visual.c-clear::before{background:#E5E7EB;}
.tube-visual.c-red::before{background:#FCA5A5;}
.tube-visual.c-white::before{background:#F3F4F6;}
.tube-visual.c-transparent::before{background:#DBEAFE;}
.tube-label{font-size:.75rem;font-weight:600;color:var(--color-text-secondary);}

/* Litmus Strips */
.litmus-area{display:flex;gap:var(--space-lg);justify-content:center;flex-wrap:wrap;margin-bottom:var(--space-xl);}
.litmus-strip{width:120px;padding:var(--space-lg) var(--space-md);border-radius:var(--border-radius);text-align:center;
    cursor:pointer;border:2px solid var(--border-color);transition:all .2s;}
.litmus-strip:hover{transform:translateY(-2px);box-shadow:0 4px 12px rgba(0,0,0,.1);}
.litmus-strip.blue-strip{background:#BFDBFE;border-color:#93C5FD;}
.litmus-strip.red-strip{background:#FECACA;border-color:#FCA5A5;}
.litmus-strip.blue-strip.reacted{background:#FCA5A5;border-color:#DC2626;}
.litmus-strip.red-strip.reacted{background:#93C5FD;border-color:#2563EB;}
.litmus-strip-label{font-size:.8125rem;font-weight:700;margin-top:var(--space-sm);}
.litmus-icon{font-size:2rem;}

/* Result display */
.test-result{text-align:center;padding:var(--space-md);border-radius:var(--border-radius);margin-bottom:var(--space-md);
    font-weight:700;font-size:.9375rem;display:none;}
.test-result.show{display:block;}
.test-result.acid{background:#FEF2F2;color:#DC2626;}
.test-result.alkaline{background:#EFF6FF;color:#2563EB;}
.test-result.neutral{background:#F0FDF4;color:#15803D;}

/* Classification Buckets */
.classify-zone{display:flex;gap:var(--space-md);flex-wrap:wrap;justify-content:center;margin-bottom:var(--space-lg);}
.classify-bucket{min-width:150px;min-height:120px;border:3px dashed var(--border-color);border-radius:var(--border-radius-xl);
    padding:var(--space-md);text-align:center;flex:1;cursor:pointer;transition:all .2s;}
.classify-bucket:hover{border-color:#7C3AED;background:#FAFAFE;}
.classify-bucket.acid-bucket{border-color:#FECACA;}
.classify-bucket.alkaline-bucket{border-color:#BFDBFE;}
.classify-bucket.neutral-bucket{border-color:#BBF7D0;}
.classify-bucket-title{font-size:.875rem;font-weight:700;padding:4px 10px;border-radius:var(--border-radius-full);
    display:inline-block;margin-bottom:var(--space-sm);}
.acid-bucket .classify-bucket-title{background:#FEE2E2;color:#DC2626;}
.alkaline-bucket .classify-bucket-title{background:#DBEAFE;color:#2563EB;}
.neutral-bucket .classify-bucket-title{background:#DCFCE7;color:#15803D;}
.classified-item{display:inline-flex;align-items:center;gap:4px;padding:4px 10px;border-radius:var(--border-radius);
    font-size:.75rem;font-weight:600;margin:3px;background:#F8FAFC;border:1px solid var(--border-color);}

.lab-feedback{text-align:center;padding:var(--space-lg);border-radius:var(--border-radius);
    font-weight:700;font-size:.9375rem;margin-bottom:var(--space-md);display:none;}
.lab-feedback.show{display:block;}
.lab-feedback.correct{background:#DCFCE7;color:#15803D;}
.lab-feedback.wrong{background:#FEE2E2;color:#B91C1C;}
.lab-complete-bar{display:flex;align-items:center;justify-content:center;gap:var(--space-md);margin-bottom:var(--space-xl);}
@media(max-width:767px){.tubes-row{gap:var(--space-sm);}.classify-zone{flex-direction:column;}}
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
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><asp:Literal ID="litPageTitle" runat="server" Text="Litmus Test Lab" /></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="lab-section" style="text-align:center;padding:var(--space-3xl);">
        <div style="font-size:3rem;margin-bottom:var(--space-md);">🧪</div>
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

<%-- Step 1: Select Substance & Test with Litmus --%>
<div class="lab-section" id="section1">
    <div class="lab-section-title"><i class="bi bi-1-circle-fill" style="color:#DC2626;"></i> <asp:Literal ID="litStep1Title" runat="server" /></div>
    <div class="lab-instruction"><asp:Literal ID="litStep1Inst" runat="server" /></div>

    <div class="tubes-row" id="tubesRow">
        <div class="tube-card" data-sub="lemon" data-type="acid" onclick="selectSubstance(this)">
            <div class="tube-visual c-yellow"></div>
            <div class="tube-label"><asp:Literal ID="litSub1" runat="server" Text="Lemon Juice" /></div>
        </div>
        <div class="tube-card" data-sub="soap" data-type="alkaline" onclick="selectSubstance(this)">
            <div class="tube-visual c-blue"></div>
            <div class="tube-label"><asp:Literal ID="litSub2" runat="server" Text="Soap Water" /></div>
        </div>
        <div class="tube-card" data-sub="salt" data-type="neutral" onclick="selectSubstance(this)">
            <div class="tube-visual c-clear"></div>
            <div class="tube-label"><asp:Literal ID="litSub3" runat="server" Text="Salt Water" /></div>
        </div>
        <div class="tube-card" data-sub="vinegar" data-type="acid" onclick="selectSubstance(this)">
            <div class="tube-visual c-red"></div>
            <div class="tube-label"><asp:Literal ID="litSub4" runat="server" Text="Vinegar" /></div>
        </div>
        <div class="tube-card" data-sub="baking" data-type="alkaline" onclick="selectSubstance(this)">
            <div class="tube-visual c-white"></div>
            <div class="tube-label"><asp:Literal ID="litSub5" runat="server" Text="Baking Soda" /></div>
        </div>
        <div class="tube-card" data-sub="water" data-type="neutral" onclick="selectSubstance(this)">
            <div class="tube-visual c-transparent"></div>
            <div class="tube-label"><asp:Literal ID="litSub6" runat="server" Text="Plain Water" /></div>
        </div>
    </div>

    <div class="litmus-area" id="litmusArea">
        <div class="litmus-strip blue-strip" id="blueStrip" onclick="testLitmus('blue')">
            <div class="litmus-icon">📄</div>
            <div class="litmus-strip-label"><asp:Literal ID="litBlueStrip" runat="server" Text="Blue Litmus" /></div>
        </div>
        <div class="litmus-strip red-strip" id="redStrip" onclick="testLitmus('red')">
            <div class="litmus-icon">📄</div>
            <div class="litmus-strip-label"><asp:Literal ID="litRedStrip" runat="server" Text="Red Litmus" /></div>
        </div>
    </div>

    <div class="test-result" id="testResult"></div>
    <div class="lab-feedback" id="testFeedback"></div>
</div>

<%-- Step 2: Classify Substances --%>
<div class="lab-section" id="section2">
    <div class="lab-section-title"><i class="bi bi-2-circle-fill" style="color:#2563EB;"></i> <asp:Literal ID="litStep2Title" runat="server" /></div>
    <div class="lab-instruction"><asp:Literal ID="litStep2Inst" runat="server" /></div>

    <div class="tubes-row" id="classifyItems">
        <div class="tube-card" data-sub="lemon" data-type="acid" onclick="selectForClassify(this)">
            <div class="tube-visual c-yellow"></div>
            <div class="tube-label"><%= T("Lemon Juice","Jus Lemon") %></div>
        </div>
        <div class="tube-card" data-sub="soap" data-type="alkaline" onclick="selectForClassify(this)">
            <div class="tube-visual c-blue"></div>
            <div class="tube-label"><%= T("Soap Water","Air Sabun") %></div>
        </div>
        <div class="tube-card" data-sub="salt" data-type="neutral" onclick="selectForClassify(this)">
            <div class="tube-visual c-clear"></div>
            <div class="tube-label"><%= T("Salt Water","Air Garam") %></div>
        </div>
        <div class="tube-card" data-sub="vinegar" data-type="acid" onclick="selectForClassify(this)">
            <div class="tube-visual c-red"></div>
            <div class="tube-label"><%= T("Vinegar","Cuka") %></div>
        </div>
        <div class="tube-card" data-sub="baking" data-type="alkaline" onclick="selectForClassify(this)">
            <div class="tube-visual c-white"></div>
            <div class="tube-label"><%= T("Baking Soda","Soda Bikarbonat") %></div>
        </div>
        <div class="tube-card" data-sub="water" data-type="neutral" onclick="selectForClassify(this)">
            <div class="tube-visual c-transparent"></div>
            <div class="tube-label"><%= T("Plain Water","Air Kosong") %></div>
        </div>
    </div>

    <div class="classify-zone">
        <div class="classify-bucket acid-bucket" id="acidBucket" onclick="classifyPlace('acid')">
            <div class="classify-bucket-title"><asp:Literal ID="litAcidic" runat="server" Text="Acidic" /></div>
            <div id="acidItems"></div>
        </div>
        <div class="classify-bucket alkaline-bucket" id="alkalineBucket" onclick="classifyPlace('alkaline')">
            <div class="classify-bucket-title"><asp:Literal ID="litAlkaline" runat="server" Text="Alkaline" /></div>
            <div id="alkalineItems"></div>
        </div>
        <div class="classify-bucket neutral-bucket" id="neutralBucket" onclick="classifyPlace('neutral')">
            <div class="classify-bucket-title"><asp:Literal ID="litNeutral" runat="server" Text="Neutral" /></div>
            <div id="neutralItems"></div>
        </div>
    </div>
    <div class="lab-feedback" id="classifyFeedback"></div>
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
var selectedSub=null, testedSubs={}, usedBlue=false, usedRed=false;
var classifySelected=null, classifyCorrect=0, classifyTotal=6, classified=0;

// Step 1: Test with litmus
function selectSubstance(el){
    document.querySelectorAll('#tubesRow .tube-card').forEach(function(c){c.classList.remove('selected');});
    el.classList.add('selected');
    selectedSub=el;
    // Reset litmus strips visually
    document.getElementById('blueStrip').classList.remove('reacted');
    document.getElementById('redStrip').classList.remove('reacted');
    document.getElementById('testResult').className='test-result';
}

function testLitmus(strip){
    if(!selectedSub){
        var fb=document.getElementById('testFeedback');
        fb.className='lab-feedback show wrong';
        fb.textContent=lang==='BM'?'Sila pilih bahan dahulu!':'Please select a substance first!';
        setTimeout(function(){fb.className='lab-feedback';},2000);
        return;
    }
    var type=selectedSub.getAttribute('data-type');
    var subName=selectedSub.getAttribute('data-sub');
    var res=document.getElementById('testResult');

    if(strip==='blue'){
        usedBlue=true;
        if(type==='acid'){
            document.getElementById('blueStrip').classList.add('reacted');
            res.className='test-result show acid';
            res.textContent=lang==='BM'?'🔴 Litmus biru bertukar MERAH → Asid!':'🔴 Blue litmus turns RED → Acid!';
        } else {
            document.getElementById('blueStrip').classList.remove('reacted');
            res.className='test-result show neutral';
            res.textContent=lang==='BM'?'— Tiada perubahan pada litmus biru':'— No change on blue litmus';
        }
    } else {
        usedRed=true;
        if(type==='alkaline'){
            document.getElementById('redStrip').classList.add('reacted');
            res.className='test-result show alkaline';
            res.textContent=lang==='BM'?'🔵 Litmus merah bertukar BIRU → Alkali!':'🔵 Red litmus turns BLUE → Alkaline!';
        } else {
            document.getElementById('redStrip').classList.remove('reacted');
            res.className='test-result show neutral';
            res.textContent=lang==='BM'?'— Tiada perubahan pada litmus merah':'— No change on red litmus';
        }
    }

    // Track tested substances
    if(!testedSubs[subName]) testedSubs[subName]=[];
    if(testedSubs[subName].indexOf(strip)===-1) testedSubs[subName].push(strip);
    selectedSub.classList.add('tested');

    checkStar1();
}

function checkStar1(){
    var count=Object.keys(testedSubs).length;
    if(count>=3 && starsEarned<1) earnStar(1);
    if(usedBlue && usedRed && starsEarned<2) earnStar(2);
}

// Step 2: Classify
function selectForClassify(el){
    if(el.classList.contains('placed'))return;
    document.querySelectorAll('#classifyItems .tube-card').forEach(function(c){c.style.outline='';});
    el.style.outline='3px solid #7C3AED';
    classifySelected=el;
}

function classifyPlace(bucket){
    if(!classifySelected)return;
    var type=classifySelected.getAttribute('data-type');
    var label=classifySelected.querySelector('.tube-label').textContent.trim();
    var correct=(bucket===type);
    var target=document.getElementById(bucket+'Items');
    var span=document.createElement('div');
    span.className='classified-item';
    span.textContent=label;

    if(correct){
        classifyCorrect++;
        span.style.background='#DCFCE7';
        classifySelected.classList.add('placed');
        classifySelected.style.opacity='.5';
    } else {
        span.style.background='#FEE2E2';
        classifySelected.classList.add('placed');
        classifySelected.style.opacity='.5';
    }
    target.appendChild(span);
    classifySelected.style.outline='';
    classifySelected=null;
    classified++;

    var fb=document.getElementById('classifyFeedback');
    if(correct){fb.className='lab-feedback show correct';fb.textContent=lang==='BM'?'✓ Betul!':'✓ Correct!';}
    else{fb.className='lab-feedback show wrong';fb.textContent=lang==='BM'?'✗ Tidak betul!':'✗ Incorrect!';}
    setTimeout(function(){fb.className='lab-feedback';},1500);

    if(classified>=classifyTotal){
        if(classifyCorrect>=classifyTotal) earnStar(3);
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
