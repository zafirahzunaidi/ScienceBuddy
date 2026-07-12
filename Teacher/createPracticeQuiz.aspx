<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="createPracticeQuiz.aspx.cs" Inherits="ScienceBuddy.Teacher.createPracticeQuiz" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ═══ DESIGN TOKENS — Blue-Purple Practice Quiz Theme ═════ */
:root{
  --pq-primary:#6D5EF7;--pq-hover:#5B47F5;--pq-accent:#4F8CFF;
  --pq-light:#F5F7FF;--pq-lavender:#EEEAFE;--pq-border:#D4CDFA;
  --pq-text:#1E1B3A;--pq-muted:#7B7499;--pq-error:#E53E5E;--pq-success:#22C27A;
}
/* ═══ HERO ════════════════════════════════════════════════ */
.pq-hero{position:relative;background:#F0EEFF;border-radius:24px;padding:2.75rem 2.8rem 2.2rem;margin-bottom:1.5rem;overflow:hidden;border:1.5px solid #C8C2F8;box-shadow:0 8px 40px rgba(109,94,247,.12),0 2px 0 rgba(255,255,255,.90) inset;}
.pq-hero-bg{position:absolute;inset:0;pointer-events:none;overflow:hidden;}
.pq-hero-bg svg{position:absolute;top:0;right:0;width:68%;height:100%;opacity:.11;}
.pq-hero::before{content:'';position:absolute;top:-70px;right:-70px;width:300px;height:300px;border-radius:50%;background:radial-gradient(circle,#6D5EF7 0%,transparent 68%);opacity:.13;pointer-events:none;}
.pq-hero::after{content:'';position:absolute;bottom:-55px;left:25%;width:240px;height:240px;border-radius:50%;background:radial-gradient(circle,#4F8CFF 0%,transparent 68%);opacity:.12;pointer-events:none;}
.pq-hero-bg::before{content:'';position:absolute;top:30%;left:-55px;width:200px;height:200px;border-radius:50%;background:radial-gradient(circle,#A78BFA 0%,transparent 68%);opacity:.10;pointer-events:none;}
.pq-hero-left{position:relative;z-index:2;display:flex;flex-direction:column;gap:1.4rem;}
.pq-hero-top{display:flex;align-items:flex-start;justify-content:space-between;gap:18px;}
.pq-hero-top-left{display:flex;align-items:flex-start;gap:18px;}
.pq-hero-icon{width:62px;height:62px;border-radius:18px;background:linear-gradient(145deg,#6D5EF7,#4F8CFF);display:flex;align-items:center;justify-content:center;font-size:1.65rem;flex-shrink:0;box-shadow:0 6px 22px rgba(109,94,247,.38),0 1px 0 rgba(255,255,255,.22) inset;}
.pq-hero-icon i{color:#fff;}
.pq-hero-title{font-size:2rem;font-weight:900;color:#1E1B3A;margin:0;letter-spacing:-.5px;line-height:1.15;}
.pq-hero-desc{font-size:.93rem;color:#7B7499;margin:5px 0 0;font-weight:500;}
.pq-hero-meta{display:inline-flex;align-items:stretch;gap:0;background:rgba(240,238,255,.92);border-radius:16px;border:1.5px solid #C8C2F8;overflow:hidden;width:fit-content;backdrop-filter:blur(8px);box-shadow:0 3px 14px rgba(109,94,247,.10);}
.pq-meta-item{display:flex;align-items:center;gap:12px;padding:.85rem 1.4rem;}
.pq-meta-item:not(:last-child){border-right:1.5px solid #D4CDFA;}
.pq-meta-pill{width:38px;height:38px;border-radius:11px;display:flex;align-items:center;justify-content:center;font-size:1.05rem;flex-shrink:0;}
.pq-meta-pill-level{background:linear-gradient(135deg,#C8C2F8,#A89AF5);color:#3D2AAA;box-shadow:0 2px 8px rgba(109,94,247,.22);}
.pq-meta-pill-unit{background:linear-gradient(135deg,#BAD5FF,#8AB8FF);color:#1A4DAA;box-shadow:0 2px 8px rgba(79,140,255,.22);}
.pq-meta-pill-subtopic{background:linear-gradient(135deg,#D4C8FC,#B8A8F8);color:#4A28CC;box-shadow:0 2px 8px rgba(109,94,247,.18);}
.pq-meta-pill-lang{background:linear-gradient(135deg,#B8D9FF,#7FB8FF);color:#1840AA;box-shadow:0 2px 8px rgba(79,140,255,.18);}
.pq-meta-label{font-size:.67rem;font-weight:700;color:#8078AA;text-transform:uppercase;letter-spacing:.6px;display:block;line-height:1;margin-bottom:3px;}
.pq-meta-val{font-size:.95rem;font-weight:800;color:#1E1B3A;display:block;line-height:1.15;max-width:200px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
/* ═══ SETTINGS BUTTON ═══════════════════════════════════ */
.pq-btn-settings{display:inline-flex;align-items:center;gap:7px;padding:.6rem 1.1rem;border-radius:12px;border:1.5px solid #C8C2F8;background:rgba(255,255,255,.75);font-size:.82rem;font-weight:700;color:#4A28CC;cursor:pointer;transition:all .18s;backdrop-filter:blur(4px);flex-shrink:0;white-space:nowrap;}
.pq-btn-settings:hover{background:#fff;border-color:#A89AF5;box-shadow:0 4px 14px rgba(109,94,247,.18);}
/* ═══ SETTINGS MODAL ════════════════════════════════════ */
.pq-modal-overlay{position:fixed;inset:0;background:rgba(30,27,58,.50);z-index:9000;display:flex;align-items:center;justify-content:center;padding:1rem;}
.pq-modal{background:#fff;border-radius:20px;width:100%;max-width:460px;box-shadow:0 20px 60px rgba(109,94,247,.20);animation:pqFade .2s ease;}
@keyframes pqFade{from{opacity:0;transform:translateY(10px);}to{opacity:1;transform:translateY(0);}}
.pq-modal-header{display:flex;align-items:flex-start;justify-content:space-between;padding:1.25rem 1.5rem;border-bottom:1px solid #EEE9FD;}
.pq-modal-header h3{font-size:1rem;font-weight:800;color:var(--pq-text);margin:0;}
.pq-modal-header p{font-size:.78rem;color:var(--pq-muted);margin:3px 0 0;}
.pq-modal-close{background:none;border:none;font-size:1.4rem;color:var(--pq-muted);cursor:pointer;padding:0 4px;line-height:1;}
.pq-modal-close:hover{color:var(--pq-text);}
.pq-modal-body{padding:1.25rem 1.5rem;}
.pq-modal-footer{display:flex;gap:.75rem;justify-content:flex-end;padding:1rem 1.5rem;border-top:1px solid #EEE9FD;}
.pq-form-row{margin-bottom:1rem;}
.pq-form-label{font-size:.79rem;font-weight:700;color:var(--pq-text);display:block;margin-bottom:5px;}
.pq-form-select{width:100%;height:42px;border-radius:10px;border:1.5px solid #D4CDFA;padding:0 .75rem;font-size:.84rem;background:#fff;color:var(--pq-text);transition:border-color .2s;}
.pq-form-select:focus{border-color:var(--pq-primary);outline:none;box-shadow:0 0 0 3px rgba(109,94,247,.10);}
.pq-btn-cancel{background:#fff;border:1.5px solid #E5E7EB;border-radius:10px;padding:.55rem 1.1rem;font-weight:600;font-size:.84rem;color:var(--pq-text);cursor:pointer;}
.pq-btn-apply{background:linear-gradient(135deg,var(--pq-primary),var(--pq-accent));border:none;border-radius:10px;padding:.55rem 1.25rem;font-weight:700;font-size:.84rem;color:#fff;cursor:pointer;box-shadow:0 3px 12px rgba(109,94,247,.28);}
.pq-btn-apply:hover{background:linear-gradient(135deg,var(--pq-hover),#3A7AFF);}
/* ═══ CONFIRM MODAL ══════════════════════════════════════ */
.pq-confirm-overlay{position:fixed;inset:0;background:rgba(30,27,58,.55);z-index:9500;display:flex;align-items:center;justify-content:center;padding:1rem;}
.pq-confirm-modal{background:#fff;border-radius:18px;width:100%;max-width:380px;box-shadow:0 20px 60px rgba(0,0,0,.18);animation:pqFade .2s ease;}
.pq-confirm-modal .pq-modal-body{text-align:left;}
/* ═══ MISC ═══════════════════════════════════════════════ */
.pq-denied{display:flex;flex-direction:column;align-items:center;padding:3rem;text-align:center;}
.pq-back{display:inline-flex;align-items:center;gap:5px;font-size:.83rem;font-weight:600;color:var(--pq-primary);text-decoration:none;padding:.45rem .9rem;border:1.5px solid #C8C2F8;border-radius:9px;background:#fff;transition:background .15s;}
.pq-back:hover{background:var(--pq-lavender);text-decoration:none;}
@media(max-width:900px){.pq-hero{padding:2rem 1.75rem 1.75rem;}.pq-hero-meta{flex-direction:column;width:100%;}.pq-meta-item:not(:last-child){border-right:none;border-bottom:1.5px solid #D4CDFA;}}
@media(max-width:640px){.pq-hero-title{font-size:1.55rem;}.pq-hero-top{flex-direction:column;gap:1rem;}.pq-hero{padding:1.5rem 1.25rem 1.5rem;}}
/* ═══ SCIENCE DOODLES ════════════════════════════════════ */
.pq-doodle{position:absolute;pointer-events:none;opacity:.10;line-height:1;display:inline-flex;z-index:1;}
@media(max-width:900px){.pq-doodle-sm{display:none;}}
@media(max-width:640px){.pq-doodle-hide{display:none;}.pq-doodle{opacity:.07;}}
</style>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Teaching","Pengajaran") %></div>
        <a href="<%: ResolveUrl("~/Teacher/manageMaterials.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label"><%: T("Manage Materials","Bahan Pembelajaran") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-patch-question item-icon"></i><span class="item-label"><%: T("Manage Quiz","Kuiz") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/studentProgress.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bar-chart item-icon"></i><span class="item-label"><%: T("Student Progress","Prestasi Pelajar") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/liveSession.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label"><%: T("Schedule Live Class","Kelas Langsung") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Community","Komuniti") %></div>
        <a href="<%: ResolveUrl("~/Teacher/forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/privateMessages.aspx") %>" class="sb-sidebar-item"><i class="bi bi-envelope item-icon"></i><span class="item-label"><%: T("Private Message","Mesej Peribadi") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Account","Akaun") %></div>
        <a href="<%: ResolveUrl("~/Teacher/MyProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("My Profile","Profil Saya") %></span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Sign Out","Log Keluar") %></span></a></div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Create Practice Quiz","Cipta Kuiz Latihan") %></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- Access Denied --%>
<asp:Panel ID="pnlDenied" runat="server" Visible="false">
    <div class="pq-denied">
        <div style="font-size:3rem;margin-bottom:1rem;">🚫</div>
        <h2 style="color:var(--pq-text);font-weight:800;"><%: T("Access Denied","Akses Ditolak") %></h2>
        <p style="color:var(--pq-muted);max-width:450px;"><%: T("Your account cannot access this page.","Akaun anda tidak boleh mengakses halaman ini.") %></p>
        <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="pq-back" style="margin-top:1rem;"><i class="bi bi-arrow-left"></i> <%: T("Back","Kembali") %></a>
    </div>
</asp:Panel>

<%-- Invalid Parameters --%>
<asp:Panel ID="pnlInvalid" runat="server" Visible="false">
    <div class="pq-denied">
        <div style="font-size:3rem;margin-bottom:1rem;">⚠️</div>
        <h2 style="color:var(--pq-text);font-weight:800;"><%: T("Invalid Selection","Pilihan Tidak Sah") %></h2>
        <p style="color:var(--pq-muted);max-width:450px;"><asp:Literal ID="litInvalidMsg" runat="server" /></p>
        <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="pq-back" style="margin-top:1rem;"><i class="bi bi-arrow-left"></i> <%: T("Back to Manage Quizzes","Kembali ke Urus Kuiz") %></a>
    </div>
</asp:Panel>

<%-- Main content --%>
<asp:Panel ID="pnlMain" runat="server" Visible="false">

<%-- ══════════════════════════════════════════════════════
     HERO HEADER
     ══════════════════════════════════════════════════════ --%>
<div class="pq-hero">
    <div class="pq-hero-bg">
        <%-- Science doodle icons — decorative only, not clickable --%>
        <span class="pq-doodle" style="top:12%;right:38%;font-size:2.8rem;transform:rotate(-18deg);color:#A78BFA;"><i class="bi bi-rocket-takeoff" style="pointer-events:none;"></i></span>
        <span class="pq-doodle" style="top:8%;right:28%;font-size:2.2rem;transform:rotate(12deg);color:#6D5EF7;"><i class="bi bi-lightbulb" style="pointer-events:none;"></i></span>
        <span class="pq-doodle pq-doodle-sm" style="top:55%;right:22%;font-size:3rem;transform:rotate(-8deg);color:#4F8CFF;"><i class="bi bi-book" style="pointer-events:none;"></i></span>
        <span class="pq-doodle pq-doodle-sm" style="top:20%;right:18%;font-size:2.4rem;transform:rotate(22deg);color:#C4B5FD;"><i class="bi bi-eyedropper" style="pointer-events:none;"></i></span>
        <span class="pq-doodle pq-doodle-sm" style="top:65%;right:42%;font-size:2rem;transform:rotate(-30deg);color:#818CF8;"><i class="bi bi-search" style="pointer-events:none;"></i></span>
        <span class="pq-doodle pq-doodle-hide" style="top:30%;right:8%;font-size:3.5rem;transform:rotate(6deg);color:#A78BFA;"><i class="bi bi-globe2" style="pointer-events:none;"></i></span>
        <span class="pq-doodle pq-doodle-hide" style="top:5%;right:12%;font-size:2rem;transform:rotate(-14deg);color:#60A5FA;"><i class="bi bi-diagram-3" style="pointer-events:none;"></i></span>
        <span class="pq-doodle pq-doodle-hide" style="top:72%;right:14%;font-size:2.6rem;transform:rotate(18deg);color:#C4B5FD;"><i class="bi bi-clipboard2-pulse" style="pointer-events:none;"></i></span>
        <span class="pq-doodle pq-doodle-hide" style="top:45%;right:32%;font-size:2.2rem;transform:rotate(-22deg);color:#93C5FD;"><i class="bi bi-thermometer-half" style="pointer-events:none;"></i></span>
        <span class="pq-doodle pq-doodle-hide" style="top:80%;right:38%;font-size:1.8rem;transform:rotate(10deg);color:#A78BFA;"><i class="bi bi-stars" style="pointer-events:none;"></i></span>
        <svg viewBox="0 0 820 260" fill="none" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMaxYMid slice">
            <circle cx="550" cy="62" r="10" fill="#6D5EF7"/>
            <ellipse cx="550" cy="62" rx="36" ry="15" stroke="#6D5EF7" stroke-width="2.2" fill="none"/>
            <ellipse cx="550" cy="62" rx="36" ry="15" stroke="#6D5EF7" stroke-width="2.2" fill="none" transform="rotate(60 550 62)"/>
            <ellipse cx="550" cy="62" rx="36" ry="15" stroke="#6D5EF7" stroke-width="2.2" fill="none" transform="rotate(120 550 62)"/>
            <path d="M650 18 C660 36 672 36 682 18 C692 0 704 0 714 18" stroke="#4F8CFF" stroke-width="2.2" fill="none" stroke-linecap="round"/>
            <path d="M650 36 C660 54 672 54 682 36 C692 18 704 18 714 36" stroke="#4F8CFF" stroke-width="2.2" fill="none" stroke-linecap="round"/>
            <line x1="659" y1="27" x2="659" y2="43" stroke="#4F8CFF" stroke-width="1.6"/>
            <line x1="673" y1="36" x2="673" y2="52" stroke="#4F8CFF" stroke-width="1.6"/>
            <line x1="687" y1="27" x2="687" y2="43" stroke="#4F8CFF" stroke-width="1.6"/>
            <line x1="701" y1="18" x2="701" y2="34" stroke="#4F8CFF" stroke-width="1.6"/>
            <path d="M760 28 L760 66 L780 98 L740 98 Z" stroke="#6D5EF7" stroke-width="2.2" fill="none" stroke-linejoin="round"/>
            <line x1="752" y1="28" x2="768" y2="28" stroke="#6D5EF7" stroke-width="2.2"/>
            <ellipse cx="760" cy="90" rx="13" ry="5" fill="#6D5EF7" opacity=".45"/>
            <circle cx="754" cy="78" r="4" fill="#4F8CFF" opacity=".55"/>
            <circle cx="764" cy="84" r="3" fill="#A78BFA" opacity=".5"/>
            <rect x="790" y="110" width="24" height="38" rx="4" stroke="#4F8CFF" stroke-width="2" fill="none"/>
            <line x1="802" y1="110" x2="802" y2="96" stroke="#4F8CFF" stroke-width="2.2"/>
            <circle cx="802" cy="92" r="7" stroke="#4F8CFF" stroke-width="2" fill="none"/>
            <line x1="786" y1="148" x2="818" y2="148" stroke="#4F8CFF" stroke-width="2.2" stroke-linecap="round"/>
            <circle cx="700" cy="170" r="7" fill="#6D5EF7"/><circle cx="726" cy="150" r="5" fill="#4F8CFF"/>
            <circle cx="748" cy="172" r="7" fill="#6D5EF7"/><circle cx="726" cy="192" r="4.5" fill="#A78BFA"/>
            <line x1="707" y1="170" x2="721" y2="153" stroke="#6D5EF7" stroke-width="1.8"/>
            <line x1="731" y1="153" x2="743" y2="169" stroke="#6D5EF7" stroke-width="1.8"/>
            <line x1="726" y1="155" x2="726" y2="187" stroke="#4F8CFF" stroke-width="1.8"/>
            <path d="M610 110 Q632 88 644 110 Q632 134 610 110 Z" stroke="#6D5EF7" stroke-width="1.8" fill="none"/>
            <line x1="610" y1="110" x2="642" y2="110" stroke="#6D5EF7" stroke-width="1.2"/>
            <path d="M618 130 Q628 118 636 130 Q628 142 618 130 Z" stroke="#6D5EF7" stroke-width="1.5" fill="none" opacity=".6"/>
            <path d="M420 45 L422.5 52 L430 54.5 L422.5 57 L420 64 L417.5 57 L410 54.5 L417.5 52 Z" fill="#A78BFA" opacity=".75"/>
            <path d="M668 70 L669.8 75.5 L675.5 77.3 L669.8 79.1 L668 84.6 L666.2 79.1 L660.5 77.3 L666.2 75.5 Z" fill="#4F8CFF" opacity=".65"/>
            <path d="M495 130 L496.4 134 L500.5 135.4 L496.4 136.8 L495 140.8 L493.6 136.8 L489.5 135.4 L493.6 134 Z" fill="#6D5EF7" opacity=".6"/>
            <circle cx="438" cy="105" r="3.2" fill="#4F8CFF" opacity=".6"/>
            <circle cx="462" cy="72" r="2.4" fill="#6D5EF7" opacity=".55"/>
            <circle cx="582" cy="200" r="2.8" fill="#A78BFA" opacity=".5"/>
            <circle cx="640" cy="230" r="2" fill="#4F8CFF" opacity=".5"/>
            <path d="M380 260 Q470 228 565 242 Q650 256 750 236 Q790 228 820 234 L820 260 Z" fill="#6D5EF7" opacity=".15"/>
            <path d="M0 220 Q80 200 160 215 Q240 230 300 210 L300 260 L0 260 Z" fill="#4F8CFF" opacity=".12"/>
        </svg>
    </div>
    <div class="pq-hero-left">
        <div class="pq-hero-top">
            <div class="pq-hero-top-left">
                <div class="pq-hero-icon"><i class="bi bi-pencil-square"></i></div>
                <div>
                    <h1 class="pq-hero-title"><%: T("Practice Quiz","Kuiz Latihan") %></h1>
                    <p class="pq-hero-desc"><%: T("Create questions for the selected learning area.","Cipta soalan untuk kawasan pembelajaran yang dipilih.") %></p>
                </div>
            </div>
            <button type="button" class="pq-btn-settings" onclick="openSettingsModal()">
                <i class="bi bi-gear-fill"></i> <%: T("Settings","Tetapan") %>
            </button>
        </div>
        <div class="pq-hero-meta">
            <div class="pq-meta-item">
                <div class="pq-meta-pill pq-meta-pill-level"><i class="bi bi-bar-chart-steps"></i></div>
                <div>
                    <span class="pq-meta-label"><%: T("Level","Tahap") %></span>
                    <span class="pq-meta-val" id="heroLevel"><asp:Literal ID="litLevel" runat="server" /></span>
                </div>
            </div>
            <div class="pq-meta-item">
                <div class="pq-meta-pill pq-meta-pill-unit"><i class="bi bi-layers-fill"></i></div>
                <div>
                    <span class="pq-meta-label"><%: T("Unit","Unit") %></span>
                    <span class="pq-meta-val" id="heroUnit"><asp:Literal ID="litUnit" runat="server" /></span>
                </div>
            </div>
            <div class="pq-meta-item">
                <div class="pq-meta-pill pq-meta-pill-subtopic"><i class="bi bi-bookmark-fill"></i></div>
                <div>
                    <span class="pq-meta-label"><%: T("Subtopic","Subtopik") %></span>
                    <span class="pq-meta-val" id="heroSubtopic"><asp:Literal ID="litSubtopic" runat="server" /></span>
                </div>
            </div>
            <div class="pq-meta-item">
                <div class="pq-meta-pill pq-meta-pill-lang"><i class="bi bi-translate"></i></div>
                <div>
                    <span class="pq-meta-label"><%: T("Language","Bahasa") %></span>
                    <span class="pq-meta-val" id="heroLanguage"><asp:Literal ID="litLanguage" runat="server" /></span>
                </div>
            </div>
        </div>
    </div>
</div><%-- /.pq-hero --%>

<%-- Quiz builder placeholder --%>
<div style="background:#fff;border:1.5px solid #D4CDFA;border-radius:14px;padding:2rem;text-align:center;color:var(--pq-muted);">
    <i class="bi bi-tools" style="font-size:2.5rem;opacity:.4;display:block;margin-bottom:.75rem;color:var(--pq-primary);"></i>
    <p style="font-size:.9rem;font-weight:600;margin:0;"><%: T("Quiz builder will be displayed here.","Pembina kuiz akan dipaparkan di sini.") %></p>
</div>


<%-- ══════════════════════════════════════════════════════
     SETTINGS MODAL
     ══════════════════════════════════════════════════════ --%>
<div id="pqSettingsModal" class="pq-modal-overlay" style="display:none;" onclick="if(event.target===this)closeSettingsModal()">
    <div class="pq-modal">
        <div class="pq-modal-header">
            <div>
                <h3><%: T("Quiz Settings","Tetapan Kuiz") %></h3>
                <p><%: T("Change the learning area for this practice quiz.","Tukar kawasan pembelajaran untuk kuiz latihan ini.") %></p>
            </div>
            <button type="button" class="pq-modal-close" onclick="closeSettingsModal()">×</button>
        </div>
        <div class="pq-modal-body">
            <div class="pq-form-row">
                <label class="pq-form-label"><%: T("Level","Tahap") %> *</label>
                <select id="stgLevel" class="pq-form-select" onchange="stgOnLevelChange(this.value)">
                    <option value=""><%: T("— Select Level —","— Pilih Tahap —") %></option>
                </select>
            </div>
            <div class="pq-form-row">
                <label class="pq-form-label"><%: T("Unit","Unit") %> *</label>
                <select id="stgUnit" class="pq-form-select" onchange="stgOnUnitChange(this.value)" disabled>
                    <option value=""><%: T("— Select Unit —","— Pilih Unit —") %></option>
                </select>
            </div>
            <div class="pq-form-row">
                <label class="pq-form-label"><%: T("Subtopic","Subtopik") %> *</label>
                <select id="stgSubtopic" class="pq-form-select" onchange="_stgCheckApply()" disabled>
                    <option value=""><%: T("— Select Subtopic —","— Pilih Subtopik —") %></option>
                </select>
            </div>
            <div class="pq-form-row" style="margin-bottom:0;">
                <label class="pq-form-label"><%: T("Language","Bahasa") %> *</label>
                <select id="stgLanguage" class="pq-form-select" onchange="_stgCheckApply()">
                    <option value=""><%: T("— Select Language —","— Pilih Bahasa —") %></option>
                    <option value="EN">English</option>
                    <option value="BM">Bahasa Melayu</option>
                </select>
            </div>
        </div>
        <div class="pq-modal-footer">
            <button type="button" class="pq-btn-cancel" onclick="closeSettingsModal()"><%: T("Cancel","Batal") %></button>
            <button type="button" id="stgApplyBtn" class="pq-btn-apply" disabled style="opacity:.5;" onclick="stgApply()"><%: T("Apply Changes","Guna Perubahan") %></button>
        </div>
    </div>
</div>

<%-- ══════════════════════════════════════════════════════
     CONFIRM RESET MODAL
     ══════════════════════════════════════════════════════ --%>
<div id="pqConfirmModal" class="pq-confirm-overlay" style="display:none;" onclick="if(event.target===this)closeConfirmModal()">
    <div class="pq-confirm-modal">
        <div class="pq-modal-header">
            <div>
                <h3><%: T("Confirm Settings Change","Sahkan Perubahan Tetapan") %></h3>
            </div>
            <button type="button" class="pq-modal-close" onclick="closeConfirmModal()">×</button>
        </div>
        <div class="pq-modal-body">
            <p style="font-size:.88rem;color:#374151;line-height:1.65;margin:0;"><%: T("Changing these settings may reset your current unsaved quiz data. Continue?","Menukar tetapan ini mungkin menetapkan semula data kuiz anda yang belum disimpan. Teruskan?") %></p>
        </div>
        <div class="pq-modal-footer">
            <button type="button" class="pq-btn-cancel" onclick="closeConfirmModal()"><%: T("Cancel","Batal") %></button>
            <button type="button" class="pq-btn-apply" onclick="stgApplyConfirmed()"><%: T("Continue","Teruskan") %></button>
        </div>
    </div>
</div>

<%-- Hidden fields to track current values server-side --%>
<asp:HiddenField ID="hidLevelId"    runat="server" />
<asp:HiddenField ID="hidUnitId"     runat="server" />
<asp:HiddenField ID="hidSubtopicId" runat="server" />
<asp:HiddenField ID="hidLanguage"   runat="server" />

</asp:Panel><%-- /pnlMain --%>

</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
// ── Tracked current selections ─────────────────────────────────
var _pqCur = { levelId:'', levelName:'', unitId:'', unitName:'', subtopicId:'', subtopicName:'', language:'', languageName:'' };

window.addEventListener('load', function() {
    var hLv = document.getElementById('<%=hidLevelId.ClientID%>');
    var hUn = document.getElementById('<%=hidUnitId.ClientID%>');
    var hSt = document.getElementById('<%=hidSubtopicId.ClientID%>');
    var hLg = document.getElementById('<%=hidLanguage.ClientID%>');
    if (!hLv) return; // not on main panel
    _pqCur.levelId      = hLv.value;
    _pqCur.unitId       = hUn.value;
    _pqCur.subtopicId   = hSt.value;
    _pqCur.language     = hLg.value;
    _pqCur.levelName    = (document.getElementById('heroLevel')    || {}).textContent || '';
    _pqCur.unitName     = (document.getElementById('heroUnit')     || {}).textContent || '';
    _pqCur.subtopicName = (document.getElementById('heroSubtopic') || {}).textContent || '';
    _pqCur.languageName = (document.getElementById('heroLanguage') || {}).textContent || '';
    // Trim whitespace from Literal renders
    _pqCur.levelName    = _pqCur.levelName.trim();
    _pqCur.unitName     = _pqCur.unitName.trim();
    _pqCur.subtopicName = _pqCur.subtopicName.trim();
    _pqCur.languageName = _pqCur.languageName.trim();
});

// ── Settings modal open / close ────────────────────────────────
function openSettingsModal() {
    var lvDd = document.getElementById('stgLevel');
    if (lvDd.options.length <= 1) {
        lvDd.innerHTML = '<option value="">Loading\u2026</option>';
        var xhr = new XMLHttpRequest();
        xhr.open('GET', 'createPracticeQuiz.aspx?handler=levels', true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== 4 || xhr.status !== 200) return;
            try {
                var data = JSON.parse(xhr.responseText);
                lvDd.innerHTML = '<option value="">— Select Level —</option>';
                for (var i = 0; i < data.length; i++) {
                    var o = document.createElement('option');
                    o.value = data[i].id; o.textContent = data[i].name;
                    if (data[i].id === _pqCur.levelId) o.selected = true;
                    lvDd.appendChild(o);
                }
                if (_pqCur.levelId) _stgLoadUnits(_pqCur.levelId, _pqCur.unitId);
            } catch(e) { lvDd.innerHTML = '<option value="">Error</option>'; }
        };
        xhr.send();
    } else {
        lvDd.value = _pqCur.levelId;
        _stgLoadUnits(_pqCur.levelId, _pqCur.unitId);
    }
    document.getElementById('stgLanguage').value = _pqCur.language;
    _stgCheckApply();
    document.getElementById('pqSettingsModal').style.display = 'flex';
}

function closeSettingsModal() {
    document.getElementById('pqSettingsModal').style.display = 'none';
}

// ── Cascading loads ────────────────────────────────────────────
function stgOnLevelChange(levelId) {
    var stDd = document.getElementById('stgSubtopic');
    stDd.innerHTML = '<option value="">— Select Subtopic —</option>';
    stDd.disabled = true;
    _stgCheckApply();
    _stgLoadUnits(levelId, '');
}

function _stgLoadUnits(levelId, preselect) {
    var unDd = document.getElementById('stgUnit');
    var stDd = document.getElementById('stgSubtopic');
    stDd.innerHTML = '<option value="">— Select Subtopic —</option>';
    stDd.disabled = true;
    unDd.innerHTML = '<option value="">— Select Unit —</option>';
    _stgCheckApply();
    if (!levelId) { unDd.disabled = true; return; }
    unDd.innerHTML = '<option value="">Loading\u2026</option>';
    unDd.disabled = true;
    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'createPracticeQuiz.aspx?handler=units&levelId=' + encodeURIComponent(levelId), true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState !== 4 || xhr.status !== 200) return;
        try {
            var data = JSON.parse(xhr.responseText);
            unDd.innerHTML = '<option value="">— Select Unit —</option>';
            for (var i = 0; i < data.length; i++) {
                var o = document.createElement('option');
                o.value = data[i].id; o.textContent = data[i].name;
                if (data[i].id === preselect) o.selected = true;
                unDd.appendChild(o);
            }
            unDd.disabled = false;
            if (preselect) _stgLoadSubtopics(preselect, _pqCur.subtopicId);
            else _stgCheckApply();
        } catch(e) { unDd.innerHTML = '<option value="">Error</option>'; unDd.disabled = false; }
    };
    xhr.send();
}

function stgOnUnitChange(unitId) {
    _stgLoadSubtopics(unitId, '');
}

function _stgLoadSubtopics(unitId, preselect) {
    var stDd = document.getElementById('stgSubtopic');
    stDd.innerHTML = '<option value="">— Select Subtopic —</option>';
    stDd.disabled = true;
    _stgCheckApply();
    if (!unitId) return;
    stDd.innerHTML = '<option value="">Loading\u2026</option>';
    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'createPracticeQuiz.aspx?handler=subtopics&unitId=' + encodeURIComponent(unitId), true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState !== 4 || xhr.status !== 200) return;
        try {
            var data = JSON.parse(xhr.responseText);
            stDd.innerHTML = '<option value="">— Select Subtopic —</option>';
            for (var i = 0; i < data.length; i++) {
                var o = document.createElement('option');
                o.value = data[i].id; o.textContent = data[i].name;
                if (data[i].id === preselect) o.selected = true;
                stDd.appendChild(o);
            }
            stDd.disabled = false;
            _stgCheckApply();
        } catch(e) { stDd.innerHTML = '<option value="">Error</option>'; stDd.disabled = false; }
    };
    xhr.send();
}

function _stgCheckApply() {
    var ok = !!(document.getElementById('stgLevel').value &&
                document.getElementById('stgUnit').value &&
                document.getElementById('stgSubtopic').value &&
                document.getElementById('stgLanguage').value);
    var btn = document.getElementById('stgApplyBtn');
    btn.disabled = !ok;
    btn.style.opacity = ok ? '1' : '.5';
    btn.style.pointerEvents = ok ? 'auto' : 'none';
}
// expose for inline onchange
function stgCheckApply() { _stgCheckApply(); }

// ── Apply ──────────────────────────────────────────────────────
var _stgPending = null;

function stgApply() {
    var lv = document.getElementById('stgLevel');
    var un = document.getElementById('stgUnit');
    var st = document.getElementById('stgSubtopic');
    var lg = document.getElementById('stgLanguage');
    if (!lv.value || !un.value || !st.value || !lg.value) return;

    _stgPending = {
        levelId:      lv.value,
        levelName:    lv.options[lv.selectedIndex].text,
        unitId:       un.value,
        unitName:     un.options[un.selectedIndex].text,
        subtopicId:   st.value,
        subtopicName: st.options[st.selectedIndex].text,
        language:     lg.value,
        languageName: lg.options[lg.selectedIndex].text
    };

    var changed = (_stgPending.levelId    !== _pqCur.levelId    ||
                   _stgPending.unitId     !== _pqCur.unitId     ||
                   _stgPending.subtopicId !== _pqCur.subtopicId ||
                   _stgPending.language   !== _pqCur.language);

    if (changed) {
        // Warn before discarding unsaved data
        closeSettingsModal();
        document.getElementById('pqConfirmModal').style.display = 'flex';
    } else {
        // Nothing changed — just close
        closeSettingsModal();
        _stgPending = null;
    }
}

function closeConfirmModal() {
    document.getElementById('pqConfirmModal').style.display = 'none';
    _stgPending = null;
}

function stgApplyConfirmed() {
    document.getElementById('pqConfirmModal').style.display = 'none';
    if (!_stgPending) return;

    // ── Update hero spans ──
    document.getElementById('heroLevel').textContent    = _stgPending.levelName;
    document.getElementById('heroUnit').textContent     = _stgPending.unitName;
    document.getElementById('heroSubtopic').textContent = _stgPending.subtopicName;
    document.getElementById('heroLanguage').textContent = _stgPending.languageName;

    // ── Update hidden fields ──
    document.getElementById('<%=hidLevelId.ClientID%>').value    = _stgPending.levelId;
    document.getElementById('<%=hidUnitId.ClientID%>').value     = _stgPending.unitId;
    document.getElementById('<%=hidSubtopicId.ClientID%>').value = _stgPending.subtopicId;
    document.getElementById('<%=hidLanguage.ClientID%>').value   = _stgPending.language;

    // ── Sync in-memory state ──
    _pqCur.levelId      = _stgPending.levelId;
    _pqCur.levelName    = _stgPending.levelName;
    _pqCur.unitId       = _stgPending.unitId;
    _pqCur.unitName     = _stgPending.unitName;
    _pqCur.subtopicId   = _stgPending.subtopicId;
    _pqCur.subtopicName = _stgPending.subtopicName;
    _pqCur.language     = _stgPending.language;
    _pqCur.languageName = _stgPending.languageName;

    // ── Update URL without reload ──
    if (window.history && window.history.replaceState) {
        window.history.replaceState(null, '',
            'createPracticeQuiz.aspx?levelId='    + encodeURIComponent(_stgPending.levelId)
            + '&unitId='     + encodeURIComponent(_stgPending.unitId)
            + '&subtopicId=' + encodeURIComponent(_stgPending.subtopicId)
            + '&language='   + encodeURIComponent(_stgPending.language));
    }
    _stgPending = null;
}
</script>
</asp:Content>

