<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PersonalityTest2.aspx.cs"
    Inherits="ScienceBuddy.Student.PersonalityTest" MasterPageFile="~/Site.Master" Title="Personality Test" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--pt-blue:#2563EB;--pt-sky:#4DA8FF;--pt-orange:#FF6B2C;--pt-gold:#FFD84D;--pt-bg:#F5FAFF;}

/* Hero */
.pt-hero{background:linear-gradient(135deg,#2563EB 0%,#4DA8FF 50%,#FFD84D 100%);border-radius:var(--border-radius-xl);
    padding:var(--space-xl) var(--space-2xl);color:#fff;margin-bottom:var(--space-xl);position:relative;overflow:hidden;
    box-shadow:0 10px 36px rgba(37,99,235,.2);text-align:center;}
.pt-hero::before,.pt-hero::after{content:'';position:absolute;border-radius:50%;pointer-events:none;}
.pt-hero::before{width:160px;height:160px;background:rgba(255,255,255,.07);top:-50px;right:-30px;}
.pt-hero::after{width:90px;height:90px;background:rgba(255,216,77,.1);bottom:-20px;left:60px;}
.pt-hero-deco{position:absolute;opacity:.15;color:#fff;font-size:1.2rem;pointer-events:none;animation:pt-twinkle 4s ease-in-out infinite;}
.pt-hero-deco:nth-child(1){top:12px;left:10%;animation-delay:0s;}
.pt-hero-deco:nth-child(2){top:50%;right:8%;animation-delay:1s;}
.pt-hero-deco:nth-child(3){bottom:10px;left:30%;animation-delay:2s;}
@keyframes pt-twinkle{0%,100%{opacity:.1;transform:scale(.8);}50%{opacity:.25;transform:scale(1.1);}}
.pt-hero h1{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;margin-bottom:6px;position:relative;z-index:1;color:#fff;}
.pt-hero p{font-size:.95rem;opacity:.92;max-width:520px;margin:0 auto;line-height:1.5;position:relative;z-index:1;}

/* Layout */
.pt-main{display:grid;grid-template-columns:34% 1fr;gap:var(--space-xl);margin-bottom:var(--space-xl);align-items:start;}

/* Buddy Scene - NO box */
.pt-buddy{position:sticky;top:90px;text-align:center;padding:var(--space-md) 0;}
.pt-buddy-blob{width:340px;height:340px;margin:0 auto;border-radius:50%;
    background:radial-gradient(circle,#FFF7ED 30%,#DBEAFE 100%);display:flex;align-items:center;justify-content:center;
    position:relative;box-shadow:0 12px 40px rgba(37,99,235,.08);}
.pt-buddy-blob::before{content:'';position:absolute;inset:-6px;border-radius:50%;
    border:2.5px dashed rgba(37,99,235,.08);animation:pt-spin 30s linear infinite;}
@keyframes pt-spin{from{transform:rotate(0);}to{transform:rotate(360deg);}}
.pt-buddy-blob img{width:72%;height:72%;object-fit:contain;filter:drop-shadow(0 6px 16px rgba(0,0,0,.1));
    animation:pt-float 4s ease-in-out infinite;}
@keyframes pt-float{0%,100%{transform:translateY(0);}50%{transform:translateY(-8px);}}
/* Stickers */
.pt-sticker{position:absolute;font-size:.7rem;font-weight:700;padding:4px 10px;border-radius:var(--border-radius-full);
    box-shadow:0 2px 6px rgba(0,0,0,.08);animation:pt-float 5s ease-in-out infinite;}
.pt-sticker:nth-child(2){top:20px;right:15px;background:#DBEAFE;color:#1D4ED8;animation-delay:.5s;}
.pt-sticker:nth-child(3){bottom:50px;left:10px;background:#FEF3C7;color:#92400E;animation-delay:1s;}
.pt-sticker:nth-child(4){top:45%;left:-10px;background:#DCFCE7;color:#15803D;animation-delay:1.5s;}
.pt-sticker:nth-child(5){bottom:20px;right:30px;background:#F3E8FF;color:#7C3AED;animation-delay:2s;}
/* Speech bubble */
.pt-speech{position:relative;margin-top:var(--space-md);background:#fff;border:1.5px solid #BFDBFE;
    border-radius:20px;padding:14px 20px;font-size:.9rem;color:var(--color-text);line-height:1.5;
    box-shadow:0 4px 12px rgba(37,99,235,.06);max-width:300px;margin-left:auto;margin-right:auto;}
.pt-speech::before{content:'';position:absolute;top:-8px;left:50%;transform:translateX(-50%);
    border-left:8px solid transparent;border-right:8px solid transparent;border-bottom:8px solid #BFDBFE;}
.pt-vibe{margin-top:var(--space-sm);font-size:.8rem;font-weight:700;color:var(--pt-blue);
    background:#EFF6FF;padding:8px 16px;border-radius:var(--border-radius-full);display:inline-block;}

/* Sliders */
.pt-sliders{display:flex;flex-direction:column;gap:14px;max-width:1080px;}
.pt-row{background:#fff;border-radius:16px;border:1.5px solid var(--border-color);
    padding:18px 22px;display:grid;grid-template-columns:auto 1fr;gap:14px;align-items:center;
    transition:transform .15s,box-shadow .15s;}
.pt-row:hover{transform:translateY(-2px);box-shadow:0 6px 20px rgba(0,0,0,.06);}
.pt-row-icon{width:44px;height:44px;border-radius:12px;display:flex;align-items:center;justify-content:center;
    font-size:1.15rem;flex-shrink:0;}
.pt-row-body{display:grid;grid-template-columns:1fr;gap:4px;}
.pt-row-name{font-family:var(--font-primary);font-size:1.2rem;font-weight:700;color:var(--color-text);}
.pt-row-hint{font-size:.82rem;color:var(--color-text-muted);}
.pt-row-scale{display:grid;grid-template-columns:minmax(90px,130px) auto minmax(90px,130px);gap:12px;align-items:center;margin-top:6px;}
.pt-row-lbl{font-size:.9rem;font-weight:600;color:#1E293B;}
.pt-row-lbl.r{text-align:right;}
.pt-pills{display:flex;gap:8px;justify-content:center;}
.pt-pill{width:38px;height:38px;border-radius:50%;border:2.5px solid #E2E8F0;background:#F8FAFC;
    cursor:pointer;transition:all .2s;display:flex;align-items:center;justify-content:center;font-size:0;}
.pt-pill:hover{border-color:var(--pt-orange);background:#FFF7ED;transform:scale(1.1);}
.pt-pill.active{border-color:var(--pt-orange);background:var(--pt-orange);
    box-shadow:0 3px 12px rgba(255,107,44,.35);transform:scale(1.12);}

/* Button */
.pt-btn-area{text-align:center;margin-bottom:var(--space-md);}
.pt-btn{display:inline-flex;align-items:center;gap:10px;padding:16px 44px;border-radius:var(--border-radius-full);
    font-weight:800;font-size:1.1rem;background:linear-gradient(135deg,var(--pt-orange),var(--pt-gold));color:#fff;
    border:none;cursor:pointer;box-shadow:0 6px 24px rgba(255,107,44,.3);transition:all .25s;}
.pt-btn:hover{transform:translateY(-4px) scale(1.03);box-shadow:0 12px 36px rgba(255,107,44,.4);}
.pt-btn-hint{font-size:.78rem;color:var(--color-text-muted);margin-top:8px;}
</style>
<style>
/* Result */
.pt-res{padding:var(--space-2xl) var(--space-xl);text-align:center;position:relative;overflow:hidden;}
.pt-res-bg{position:absolute;inset:0;background:radial-gradient(ellipse at 50% 30%,rgba(255,216,77,.08),transparent 60%),
    radial-gradient(ellipse at 20% 80%,rgba(37,99,235,.04),transparent 50%);pointer-events:none;}
.pt-confetti{position:absolute;top:0;left:0;right:0;height:100px;overflow:hidden;pointer-events:none;}
.pt-confetti i{position:absolute;font-size:.9rem;animation:pt-fall 2.5s ease-in infinite;}
.pt-confetti i:nth-child(1){color:#FF6B2C;left:8%;animation-delay:0s;}
.pt-confetti i:nth-child(2){color:#2563EB;left:20%;animation-delay:.4s;}
.pt-confetti i:nth-child(3){color:#FFD84D;left:35%;animation-delay:.7s;}
.pt-confetti i:nth-child(4){color:#22C55E;left:50%;animation-delay:.2s;}
.pt-confetti i:nth-child(5){color:#7C3AED;left:65%;animation-delay:.9s;}
.pt-confetti i:nth-child(6){color:#FF6B2C;left:80%;animation-delay:.5s;}
.pt-confetti i:nth-child(7){color:#FFD84D;left:92%;animation-delay:1.1s;}
@keyframes pt-fall{0%{top:-20px;opacity:1;transform:rotate(0);}100%{top:100px;opacity:0;transform:rotate(200deg);}}
.pt-res-unlock{font-size:1rem;font-weight:700;color:var(--pt-orange);margin-bottom:var(--space-sm);position:relative;z-index:1;}
.pt-res-avatar{width:360px;height:360px;margin:0 auto var(--space-lg);border-radius:50%;
    background:radial-gradient(circle,#FFF7ED 30%,#DBEAFE 100%);display:flex;align-items:center;justify-content:center;
    box-shadow:0 12px 40px rgba(37,99,235,.12);overflow:visible;position:relative;z-index:1;animation:pt-pop .6s ease;}
@keyframes pt-pop{from{transform:scale(.8);opacity:0;}to{transform:scale(1);opacity:1;}}
.pt-res-avatar img{width:120%;height:120%;object-fit:contain;}
.pt-res-name{font-family:var(--font-primary);font-size:2.5rem;font-weight:800;
    background:linear-gradient(135deg,var(--pt-blue),var(--pt-orange));-webkit-background-clip:text;-webkit-text-fill-color:transparent;
    margin-bottom:8px;position:relative;z-index:1;}
.pt-res-desc{font-size:.95rem;color:var(--color-text-secondary);line-height:1.6;max-width:480px;
    margin:0 auto var(--space-xl);position:relative;z-index:1;}
.pt-res-cards{display:grid;grid-template-columns:repeat(3,1fr);gap:var(--space-md);margin-bottom:var(--space-xl);
    max-width:550px;margin-left:auto;margin-right:auto;position:relative;z-index:1;}
.pt-res-card{background:#fff;border:1.5px solid var(--border-color);border-radius:var(--border-radius-xl);
    padding:var(--space-lg) var(--space-md);text-align:center;box-shadow:var(--shadow-sm);}
.pt-res-card i{font-size:1.5rem;color:var(--pt-blue);display:block;margin-bottom:6px;}
.pt-res-card-t{font-size:.7rem;font-weight:700;color:var(--color-text-muted);margin-bottom:4px;text-transform:uppercase;letter-spacing:.5px;}
.pt-res-card-v{font-size:.82rem;font-weight:600;color:var(--color-text);line-height:1.3;}
.pt-res-btns{display:flex;gap:var(--space-md);justify-content:center;flex-wrap:wrap;position:relative;z-index:1;}
.pt-res-btn{display:inline-flex;align-items:center;gap:6px;padding:14px 30px;border-radius:var(--border-radius-full);
    font-weight:700;font-size:.95rem;text-decoration:none;transition:all .2s;}
.pt-res-btn.primary{background:var(--pt-blue);color:#fff;box-shadow:0 4px 16px rgba(37,99,235,.25);}
.pt-res-btn.primary:hover{transform:translateY(-2px);color:#fff;text-decoration:none;}
.pt-res-btn.secondary{background:#F3F4F6;color:var(--color-text);border:1.5px solid var(--border-color);}
.pt-res-btn.secondary:hover{background:#E5E7EB;text-decoration:none;color:var(--color-text);}

@media(max-width:767px){.pt-main{grid-template-columns:1fr;}.pt-buddy{position:static;}.pt-buddy-blob{width:220px;height:220px;}
    .pt-row-scale{grid-template-columns:1fr auto 1fr;gap:8px;}
    .pt-res-cards{grid-template-columns:1fr;}.pt-res-name{font-size:1.75rem;}.pt-res-avatar{width:260px;height:260px;}}
</style>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label">Main</div>
        <a href="<%: ResolveUrl("~/Student/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label">Dashboard</span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Student/MyProfile.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a></div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><asp:Literal ID="litPageTitle" runat="server" Text="Personality Test" /></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<asp:Panel ID="pnlQuiz" runat="server">
<%-- Hero --%>
<div class="pt-hero">
    <i class="bi bi-stars pt-hero-deco"></i><i class="bi bi-lightbulb-fill pt-hero-deco"></i><i class="bi bi-mortarboard-fill pt-hero-deco"></i>
    <h1><i class="bi bi-stars"></i> <asp:Literal ID="litHeroTitle" runat="server" /></h1>
    <p><asp:Literal ID="litHeroSub" runat="server" /></p>
</div>

<%-- Main --%>
<div class="pt-main">
    <%-- Buddy --%>
    <div class="pt-buddy">
        <div class="pt-buddy-blob">
            <asp:Image ID="imgMascot" runat="server" ImageUrl="~/Images/Personality/achiever.png" AlternateText="Buddy" />
            <span class="pt-sticker">XP</span>
            <span class="pt-sticker">Quiz</span>
            <span class="pt-sticker">Lab</span>
            <span class="pt-sticker">Badge</span>
        </div>
        <div class="pt-speech" id="buddySpeech"><asp:Literal ID="litBubble" runat="server" /></div>
        <div class="pt-vibe" id="vibeText"><asp:Literal ID="litPreview" runat="server" /></div>
    </div>

    <%-- Sliders --%>
    <div class="pt-sliders">
        <div class="pt-row"><div class="pt-row-icon" style="background:#DBEAFE;color:#2563EB;"><i class="bi bi-speedometer2"></i></div><div class="pt-row-body"><div class="pt-row-name"><asp:Literal ID="litS1" runat="server" /></div><div class="pt-row-hint"><asp:Literal ID="litH1" runat="server" /></div><div class="pt-row-scale"><span class="pt-row-lbl"><asp:Literal ID="litS1L" runat="server" /></span><div class="pt-pills" data-name="slider1"><div class="pt-pill" data-v="1"></div><div class="pt-pill" data-v="2"></div><div class="pt-pill active" data-v="3"></div><div class="pt-pill" data-v="4"></div><div class="pt-pill" data-v="5"></div></div><span class="pt-row-lbl r"><asp:Literal ID="litS1R" runat="server" /></span></div></div></div>
        <div class="pt-row"><div class="pt-row-icon" style="background:#FFF0E8;color:#FF6B2C;"><i class="bi bi-bullseye"></i></div><div class="pt-row-body"><div class="pt-row-name"><asp:Literal ID="litS2" runat="server" /></div><div class="pt-row-hint"><asp:Literal ID="litH2" runat="server" /></div><div class="pt-row-scale"><span class="pt-row-lbl"><asp:Literal ID="litS2L" runat="server" /></span><div class="pt-pills" data-name="slider2"><div class="pt-pill" data-v="1"></div><div class="pt-pill" data-v="2"></div><div class="pt-pill active" data-v="3"></div><div class="pt-pill" data-v="4"></div><div class="pt-pill" data-v="5"></div></div><span class="pt-row-lbl r"><asp:Literal ID="litS2R" runat="server" /></span></div></div></div>
        <div class="pt-row"><div class="pt-row-icon" style="background:#F3E8FF;color:#7C3AED;"><i class="bi bi-lightbulb"></i></div><div class="pt-row-body"><div class="pt-row-name"><asp:Literal ID="litS3" runat="server" /></div><div class="pt-row-hint"><asp:Literal ID="litH3" runat="server" /></div><div class="pt-row-scale"><span class="pt-row-lbl"><asp:Literal ID="litS3L" runat="server" /></span><div class="pt-pills" data-name="slider3"><div class="pt-pill" data-v="1"></div><div class="pt-pill" data-v="2"></div><div class="pt-pill active" data-v="3"></div><div class="pt-pill" data-v="4"></div><div class="pt-pill" data-v="5"></div></div><span class="pt-row-lbl r"><asp:Literal ID="litS3R" runat="server" /></span></div></div></div>
        <div class="pt-row"><div class="pt-row-icon" style="background:#DCFCE7;color:#15803D;"><i class="bi bi-emoji-smile"></i></div><div class="pt-row-body"><div class="pt-row-name"><asp:Literal ID="litS4" runat="server" /></div><div class="pt-row-hint"><asp:Literal ID="litH4" runat="server" /></div><div class="pt-row-scale"><span class="pt-row-lbl"><asp:Literal ID="litS4L" runat="server" /></span><div class="pt-pills" data-name="slider4"><div class="pt-pill" data-v="1"></div><div class="pt-pill" data-v="2"></div><div class="pt-pill active" data-v="3"></div><div class="pt-pill" data-v="4"></div><div class="pt-pill" data-v="5"></div></div><span class="pt-row-lbl r"><asp:Literal ID="litS4R" runat="server" /></span></div></div></div>
        <div class="pt-row"><div class="pt-row-icon" style="background:#E0F2FE;color:#0369A1;"><i class="bi bi-people"></i></div><div class="pt-row-body"><div class="pt-row-name"><asp:Literal ID="litS5" runat="server" /></div><div class="pt-row-hint"><asp:Literal ID="litH5" runat="server" /></div><div class="pt-row-scale"><span class="pt-row-lbl"><asp:Literal ID="litS5L" runat="server" /></span><div class="pt-pills" data-name="slider5"><div class="pt-pill" data-v="1"></div><div class="pt-pill" data-v="2"></div><div class="pt-pill active" data-v="3"></div><div class="pt-pill" data-v="4"></div><div class="pt-pill" data-v="5"></div></div><span class="pt-row-lbl r"><asp:Literal ID="litS5R" runat="server" /></span></div></div></div>
        <div class="pt-row"><div class="pt-row-icon" style="background:#FEF3C7;color:#92400E;"><i class="bi bi-controller"></i></div><div class="pt-row-body"><div class="pt-row-name"><asp:Literal ID="litS6" runat="server" /></div><div class="pt-row-hint"><asp:Literal ID="litH6" runat="server" /></div><div class="pt-row-scale"><span class="pt-row-lbl"><asp:Literal ID="litS6L" runat="server" /></span><div class="pt-pills" data-name="slider6"><div class="pt-pill" data-v="1"></div><div class="pt-pill" data-v="2"></div><div class="pt-pill active" data-v="3"></div><div class="pt-pill" data-v="4"></div><div class="pt-pill" data-v="5"></div></div><span class="pt-row-lbl r"><asp:Literal ID="litS6R" runat="server" /></span></div></div></div>
    </div>
</div>

<input type="hidden" name="slider1" value="3"/><input type="hidden" name="slider2" value="3"/><input type="hidden" name="slider3" value="3"/>
<input type="hidden" name="slider4" value="3"/><input type="hidden" name="slider5" value="3"/><input type="hidden" name="slider6" value="3"/>

<div class="pt-btn-area">
    <asp:Button ID="btnDiscover" runat="server" CssClass="pt-btn" OnClick="btnDiscover_Click" CausesValidation="false" />
    <div class="pt-btn-hint"><asp:Literal ID="litBtnHint" runat="server" /></div>
</div>
</asp:Panel>

<%-- Result --%>
<asp:Panel ID="pnlResult" runat="server" Visible="false">
<div class="pt-res">
    <div class="pt-res-bg"></div>
    <div class="pt-confetti"><i class="bi bi-star-fill"></i><i class="bi bi-circle-fill"></i><i class="bi bi-diamond-fill"></i><i class="bi bi-heart-fill"></i><i class="bi bi-star-fill"></i><i class="bi bi-circle-fill"></i><i class="bi bi-diamond-fill"></i></div>
    <div class="pt-res-unlock"><asp:Literal ID="litUnlock" runat="server" /></div>
    <div class="pt-res-avatar"><asp:Image ID="imgResult" runat="server" AlternateText="Personality" /></div>
    <div class="pt-res-name"><asp:Literal ID="litResultName" runat="server" /></div>
    <div class="pt-res-desc"><asp:Literal ID="litResultDesc" runat="server" /></div>
    <div class="pt-res-cards">
        <div class="pt-res-card"><i class="bi bi-layout-text-sidebar-reverse"></i><div class="pt-res-card-t"><asp:Literal ID="litCard1Title" runat="server" /></div><div class="pt-res-card-v"><asp:Literal ID="litCard1Val" runat="server" /></div></div>
        <div class="pt-res-card"><i class="bi bi-star-fill" style="color:var(--pt-orange);"></i><div class="pt-res-card-t"><asp:Literal ID="litCard2Title" runat="server" /></div><div class="pt-res-card-v"><asp:Literal ID="litCard2Val" runat="server" /></div></div>
        <div class="pt-res-card"><i class="bi bi-lightbulb-fill" style="color:var(--pt-gold);"></i><div class="pt-res-card-t"><asp:Literal ID="litCard3Title" runat="server" /></div><div class="pt-res-card-v"><asp:Literal ID="litCard3Val" runat="server" /></div></div>
    </div>
    <div class="pt-res-btns">
        <a href="<%: ResolveUrl("~/Student/Dashboard.aspx") %>" class="pt-res-btn primary"><i class="bi bi-house-fill"></i> <asp:Literal ID="litResultBtn" runat="server" /></a>
        <a href="<%: ResolveUrl("~/Student/PersonalityTest.aspx") %>" class="pt-res-btn secondary"><i class="bi bi-arrow-repeat"></i> <asp:Literal ID="litRetakeBtn" runat="server" /></a>
    </div>
</div>
</asp:Panel>

<script>
var msgs=['<%= T("Nice choice! Buddy is learning your style.","Pilihan bagus! Buddy sedang mempelajari gaya anda.") %>',
          '<%= T("Great! Your dashboard will feel more like you.","Hebat! Papan pemuka anda akan lebih sesuai.") %>',
          '<%= T("Awesome! Keep going!","Hebat! Teruskan!") %>',
          '<%= T("Buddy likes that choice!","Buddy suka pilihan itu!") %>'];
document.querySelectorAll('.pt-pills').forEach(function(g){
    g.querySelectorAll('.pt-pill').forEach(function(p){
        p.addEventListener('click',function(){
            g.querySelectorAll('.pt-pill').forEach(function(x){x.classList.remove('active');});
            p.classList.add('active');
            document.querySelector('input[name="'+g.dataset.name+'"]').value=p.dataset.v;
            document.getElementById('buddySpeech').textContent=msgs[Math.floor(Math.random()*msgs.length)];
        });
    });
});
</script>
</asp:Content>
