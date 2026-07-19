<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="createPracticeQuiz.aspx.cs" Inherits="ScienceBuddy.Teacher.createPracticeQuiz" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* --- DESIGN TOKENS ? Blue-Purple Practice Quiz Theme ----- */
:root{
  --pq-primary:#6D5EF7;--pq-hover:#5B47F5;--pq-accent:#4F8CFF;
  --pq-light:#F5F7FF;--pq-lavender:#EEEAFE;--pq-border:#D4CDFA;
  --pq-text:#1E1B3A;--pq-muted:#7B7499;--pq-error:#E53E5E;--pq-success:#22C27A;
}
/* --- HERO ------------------------------------------------ */
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
/* --- SETTINGS BUTTON ----------------------------------- */
.pq-btn-settings{display:inline-flex;align-items:center;gap:7px;padding:.6rem 1.1rem;border-radius:12px;border:1.5px solid #C8C2F8;background:rgba(255,255,255,.75);font-size:.82rem;font-weight:700;color:#4A28CC;cursor:pointer;transition:all .18s;backdrop-filter:blur(4px);flex-shrink:0;white-space:nowrap;}
.pq-btn-settings:hover{background:#fff;border-color:#A89AF5;box-shadow:0 4px 14px rgba(109,94,247,.18);}
/* --- TOAST -------------------------------------------- */
.pq-toast-container{position:fixed;top:1.25rem;right:1.25rem;z-index:9999;display:flex;flex-direction:column;gap:.5rem;}
.pq-toast{background:linear-gradient(135deg,#22C27A,#14A860);color:#fff;padding:.85rem 1.4rem;border-radius:12px;font-size:.85rem;font-weight:700;display:flex;align-items:center;gap:9px;box-shadow:0 8px 28px rgba(34,194,122,.30);animation:pqToastSlide .3s ease;transition:opacity .3s;}
@keyframes pqToastSlide{from{opacity:0;transform:translateX(30px);}to{opacity:1;transform:translateX(0);}}
/* --- SETTINGS MODAL ------------------------------------ */
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
/* --- CONFIRM MODAL -------------------------------------- */
.pq-confirm-overlay{position:fixed;inset:0;background:rgba(30,27,58,.55);z-index:9500;display:flex;align-items:center;justify-content:center;padding:1rem;}
.pq-confirm-modal{background:#fff;border-radius:18px;width:100%;max-width:380px;box-shadow:0 20px 60px rgba(0,0,0,.18);animation:pqFade .2s ease;}
.pq-confirm-modal .pq-modal-body{text-align:left;}
/* --- MISC ----------------------------------------------- */
.pq-denied{display:flex;flex-direction:column;align-items:center;padding:3rem;text-align:center;}
.pq-back{display:inline-flex;align-items:center;gap:5px;font-size:.83rem;font-weight:600;color:var(--pq-primary);text-decoration:none;padding:.45rem .9rem;border:1.5px solid #C8C2F8;border-radius:9px;background:#fff;transition:background .15s;}
.pq-back:hover{background:var(--pq-lavender);text-decoration:none;}
/* -- Quiz Title Field ----------------------------------- */
.pq-title-field{background:#fff;border:1.5px solid #D4CDFA;border-radius:16px;padding:1.25rem 1.5rem;margin-bottom:1.5rem;box-shadow:0 3px 14px rgba(109,94,247,.06);}
.pq-title-label{font-size:.88rem;font-weight:800;color:var(--pq-text);margin-bottom:6px;display:flex;align-items:center;gap:6px;}
.pq-title-input{width:100%;border-radius:12px;border:1.5px solid #D4CDFA;padding:.75rem 1rem;font-size:.9rem;transition:all .2s;background:#FAFAFF;color:var(--pq-text);}
.pq-title-input:focus{border-color:var(--pq-primary);outline:none;box-shadow:0 0 0 3px rgba(109,94,247,.10);}
.pq-title-input::placeholder{color:#B8B4CC;font-weight:400;}
.pq-title-err{display:inline-flex;align-items:center;gap:6px;font-size:13px;font-weight:500;color:#DC3545;margin-top:4px;padding:0;line-height:1.4;}
/* --- QUESTION BUILDER (shared with Unit/Level Quiz) ----- */
.qb-layout{display:grid;grid-template-columns:220px 1fr 260px;gap:1.5rem;min-height:75vh;align-items:start;}
.qb-nav{background:#fff;border:1.5px solid #E4E0FC;border-radius:20px;padding:0;box-shadow:0 4px 20px rgba(109,94,247,.08);overflow:hidden;}
.qb-nav-header{padding:1rem 1.2rem .85rem;border-bottom:1.5px solid #EDEAFC;background:linear-gradient(135deg,#F6F4FF,#EEF2FF);}
.qb-nav-title{font-size:.68rem;font-weight:800;color:#7B7499;text-transform:uppercase;letter-spacing:1.5px;display:flex;align-items:center;justify-content:space-between;}
.qb-nav-count{font-size:.68rem;font-weight:700;color:#6D5EF7;background:#EEF2FF;border:1px solid #C8C2F8;padding:2px 8px;border-radius:10px;}
.qb-nav-list{display:flex;flex-direction:column;gap:4px;padding:.75rem .75rem 0;}
.qb-nav-row{position:relative;display:flex;align-items:stretch;border-radius:13px;overflow:hidden;}
.qb-nav-item{flex:1;padding:.7rem .9rem;font-size:.83rem;font-weight:600;color:#1E1B3A;cursor:pointer;display:flex;align-items:center;gap:9px;transition:all .2s;border:1.5px solid transparent;background:transparent;text-align:left;border-radius:13px;text-decoration:none;}
.qb-nav-item:hover{background:#F0EEFF;border-color:#C8C2F8;}
.qb-nav-item.active{background:linear-gradient(135deg,#6D5EF7,#5B47F5);color:#fff;border-color:#6D5EF7;box-shadow:0 4px 16px rgba(109,94,247,.35);}
.qb-nav-badge{width:24px;height:24px;border-radius:8px;background:rgba(109,94,247,.1);color:#6D5EF7;display:flex;align-items:center;justify-content:center;font-size:.7rem;font-weight:800;flex-shrink:0;}
.qb-nav-item.active .qb-nav-badge{background:rgba(255,255,255,.22);color:#fff;}
.qb-nav-del{position:absolute;right:5px;top:50%;transform:translateY(-50%);width:24px;height:24px;border-radius:7px;border:none;background:transparent;color:#E53E5E;display:flex;align-items:center;justify-content:center;font-size:.75rem;cursor:pointer;opacity:0;transition:opacity .18s;z-index:2;padding:0;}
.qb-nav-row:hover .qb-nav-del{opacity:.5;}
.qb-nav-del:hover{opacity:1!important;background:#FEF2F5;}
.qb-nav-del.disabled{display:none;}
.qb-nav-footer{padding:.75rem;}
.qb-nav-add{width:100%;padding:.8rem;border-radius:13px;font-size:.82rem;font-weight:700;color:#fff;cursor:pointer;border:none;background:linear-gradient(135deg,#6D5EF7,#4F8CFF);display:flex;align-items:center;justify-content:center;gap:7px;transition:all .22s;box-shadow:0 3px 12px rgba(109,94,247,.28);}
.qb-nav-add:hover{background:linear-gradient(135deg,#5B47F5,#3A7AFF);box-shadow:0 6px 20px rgba(109,94,247,.40);transform:translateY(-2px);}
.qb-center{background:#fff;border:1.5px solid #E4E0FC;border-radius:22px;padding:0;box-shadow:0 6px 32px rgba(109,94,247,.09);display:flex;flex-direction:column;min-height:580px;overflow:hidden;}
.qb-toolbar{display:flex;align-items:center;justify-content:space-between;padding:.85rem 1.75rem;background:linear-gradient(135deg,#F6F4FF,#EEF2FF);border-radius:22px 22px 0 0;gap:.75rem;flex-wrap:wrap;}
.qb-toolbar-nav{display:flex;align-items:center;gap:10px;}
.qb-toolbar-arrow{width:34px;height:34px;border-radius:10px;border:1.5px solid #E4E0FC;background:#fff;display:flex;align-items:center;justify-content:center;font-size:1rem;color:#6D5EF7;cursor:pointer;transition:all .18s;}
.qb-toolbar-arrow:hover:not(:disabled){background:#F0EEFF;border-color:#6D5EF7;transform:translateY(-1px);}
.qb-toolbar-arrow:disabled{opacity:.35;cursor:not-allowed;}
.qb-toolbar-label{font-size:.92rem;font-weight:700;color:#1E1B3A;white-space:nowrap;}
.qb-toolbar-lang{display:flex;align-items:center;padding:.6rem 1.75rem .75rem;background:#fff;border-bottom:1.5px solid #EDEAFC;}
.qb-tabs{display:flex;gap:0;background:#E8E4FC;border-radius:14px;padding:4px;}
.qb-tab{padding:.5rem 1.35rem;font-size:.82rem;font-weight:700;cursor:pointer;border:none;background:transparent;color:#7B7499;border-radius:10px;transition:all .22s;}
.qb-tab.active{background:#fff;color:#6D5EF7;box-shadow:0 2px 10px rgba(109,94,247,.18);}
.qb-tab:hover:not(.active){background:rgba(255,255,255,.55);color:#1E1B3A;}
.qb-editor-body{padding:1.75rem 2rem;flex:1;display:flex;flex-direction:column;}
.qb-field{margin-bottom:1.4rem;position:relative;}
.qb-label{font-size:.88rem;font-weight:800;color:#1E1B3A;margin-bottom:6px;display:flex;align-items:center;justify-content:space-between;}
.qb-input{width:100%;border-radius:14px;border:1.5px solid #E4E0FC;padding:.75rem 1rem;font-size:.88rem;transition:all .2s;background:#fff;color:#1E1B3A;}
.qb-input:focus{border-color:#6D5EF7;outline:none;box-shadow:0 0 0 3px rgba(109,94,247,.10);}
.qb-textarea{min-height:90px;resize:vertical;line-height:1.65;}
.qb-char-count{font-size:.68rem;color:#7B7499;font-weight:600;background:#F0EEFF;padding:2px 8px;border-radius:6px;}
.qb-rte-wrap{border:1.5px solid #E4E0FC;border-radius:14px;overflow:hidden;background:#fff;transition:border-color .2s;}
.qb-rte-wrap:focus-within{border-color:#6D5EF7;box-shadow:0 0 0 3px rgba(109,94,247,.10);}
.qb-rte-toolbar{display:flex;align-items:center;gap:2px;padding:6px 10px;background:#F9F8FF;border-bottom:1.5px solid #E4E0FC;}
.qb-rte-btn{width:34px;height:34px;border:none;background:transparent;border-radius:7px;display:flex;align-items:center;justify-content:center;font-size:1.1rem;color:#7B7499;cursor:pointer;transition:all .15s;}
.qb-rte-btn:hover{background:#EDE9FE;color:#6D5EF7;}
.qb-rte-sep{width:1px;height:20px;background:#E4E0FC;margin:0 6px;}
.qb-rte-editor{min-height:110px;padding:.85rem 1rem;font-size:.9rem;line-height:1.7;color:#1E1B3A;outline:none;overflow-y:auto;max-height:300px;}
.qb-rte-editor:empty::before{content:attr(data-placeholder);color:#B8B4CC;font-weight:400;pointer-events:none;display:block;}
.qb-img-zone{border:2px dashed #C8C2F8;border-radius:14px;background:#F8F6FF;margin-bottom:1.4rem;transition:border-color .2s;}
.qb-img-upload{display:flex;flex-direction:column;align-items:center;gap:8px;padding:1.4rem 1rem;cursor:pointer;}
.qb-img-upload:hover{background:#F0EEFF;border-color:#6D5EF7;}
.qb-img-upload-icon{width:40px;height:40px;border-radius:11px;background:linear-gradient(135deg,#C8C2F8,#A8A0F5);display:flex;align-items:center;justify-content:center;font-size:1.1rem;color:#fff;}
.qb-img-upload-text{font-size:.8rem;font-weight:700;color:#6D5EF7;}
.qb-img-upload-sub{font-size:.7rem;color:#7B7499;}
.qb-img-preview{position:relative;display:none;}
.qb-img-preview img{width:100%;max-height:200px;object-fit:cover;display:block;}
.qb-img-remove{position:absolute;top:8px;right:8px;width:26px;height:26px;border-radius:50%;border:none;background:rgba(0,0,0,.55);color:#fff;display:flex;align-items:center;justify-content:center;font-size:.75rem;cursor:pointer;}
.qb-section-header{display:flex;align-items:center;gap:10px;margin-bottom:1rem;margin-top:.25rem;}
.qb-section-header-icon{width:28px;height:28px;border-radius:8px;background:#F0EEFF;border:1.5px solid #C8C2F8;display:flex;align-items:center;justify-content:center;font-size:.85rem;color:#6D5EF7;flex-shrink:0;}
.qb-section-header-text{font-size:.92rem;font-weight:800;color:#1E1B3A;}
.qb-section-header-sub{font-size:.71rem;color:#7B7499;font-weight:500;margin-left:auto;}
.qb-section-divider{flex:1;height:1.5px;background:linear-gradient(90deg,#D8D2F8,transparent);margin-left:6px;}
.qb-opts{display:grid;grid-template-columns:1fr 1fr;gap:.85rem;margin-bottom:1.4rem;}
.qb-opt{display:flex;align-items:stretch;gap:0;border-radius:16px;border:2px solid #E4E0FC;transition:all .25s;position:relative;background:#fff;overflow:hidden;cursor:text;min-height:64px;}
.qb-opt-band{width:52px;flex-shrink:0;display:flex;align-items:center;justify-content:center;font-size:1.05rem;font-weight:900;color:#fff;}
.qb-opt:nth-child(1) .qb-opt-band{background:#E53E5E;}.qb-opt:nth-child(2) .qb-opt-band{background:#F6A623;}.qb-opt:nth-child(3) .qb-opt-band{background:#6D5EF7;}.qb-opt:nth-child(4) .qb-opt-band{background:#4F8CFF;}
.qb-opt:nth-child(1){border-color:#F8D0D8;background:#FFF8FA;}.qb-opt:nth-child(2){border-color:#FAE0B0;background:#FFFBF2;}.qb-opt:nth-child(3){border-color:#C8C2F8;background:#F8F6FF;}.qb-opt:nth-child(4){border-color:#B8D4FA;background:#F6FAFF;}
.qb-opt-body{flex:1;display:flex;align-items:center;padding:.75rem 1rem;}
.qb-opt-input{flex:1;border:none;background:transparent;font-size:.88rem;outline:none;font-weight:500;color:#1E1B3A;padding:0;line-height:1.5;}
.qb-opt-input::placeholder{color:#B8B4CC;}
.qb-opt:hover{transform:translateY(-3px);box-shadow:0 8px 22px rgba(109,94,247,.12);}
.qb-opt-selector{width:28px;height:28px;border-radius:50%;flex-shrink:0;align-self:center;margin-right:10px;border:2.5px solid #C8C2F8;background:#fff;display:flex;align-items:center;justify-content:center;cursor:pointer;transition:all .2s;opacity:0;pointer-events:none;}
.qb-opt.has-text .qb-opt-selector{opacity:1;pointer-events:auto;}
.qb-opt-selector:hover{border-color:#6D5EF7;transform:scale(1.08);}
.qb-opt.correct .qb-opt-selector{border-color:#22C27A;background:#22C27A;box-shadow:0 0 0 4px rgba(34,194,122,.18);}
.qb-opt.correct .qb-opt-selector::after{content:'\2713';color:#fff;font-size:.75rem;font-weight:900;}
.qb-tf-grid{display:grid;grid-template-columns:1fr 1fr;gap:1.1rem;margin-bottom:1.4rem;}
.qb-tf-card{display:flex;flex-direction:column;align-items:center;gap:10px;padding:2rem 1rem;border-radius:18px;border:2px solid #E4E0FC;cursor:pointer;transition:all .25s;text-align:center;background:#fff;}
.qb-tf-card:hover{transform:translateY(-3px);box-shadow:0 8px 24px rgba(109,94,247,.10);}
.qb-tf-card input[type="radio"]{display:none;}
.qb-tf-card i{font-size:2.1rem;color:#7B7499;transition:color .2s;}
.qb-tf-card span{font-size:1rem;font-weight:800;color:#1E1B3A;}
.qb-tf-card.selected{border-color:#6D5EF7;background:#F0EEFF;box-shadow:0 8px 24px rgba(109,94,247,.18);}
.qb-tf-card.selected i{color:#6D5EF7;}
.qb-ms-opt.selected{border-color:#22C27A!important;background:#EDFBF4;}
.qb-ms-count{font-size:.72rem;font-weight:700;color:#6D5EF7;background:#F0EEFF;padding:3px 9px;border-radius:7px;margin-left:8px;}
.qb-exp-block{border-radius:16px;overflow:hidden;margin-bottom:1.25rem;}
.qb-exp-block-header{display:flex;align-items:center;gap:10px;padding:.7rem 1.1rem;}
.qb-exp-block-icon{width:28px;height:28px;border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:.9rem;flex-shrink:0;}
.qb-exp-block-label{font-size:.73rem;font-weight:800;text-transform:uppercase;letter-spacing:.6px;flex:1;}
.qb-exp-block-count{font-size:.68rem;font-weight:600;padding:2px 8px;border-radius:6px;}
.qb-exp-correct{background:#F0FBF6;border:1.5px solid #90DFB8;}
.qb-exp-correct .qb-exp-block-header{background:#DFF6EC;border-bottom:1.5px solid #90DFB8;}
.qb-exp-correct .qb-exp-block-icon{background:#C0F0D8;color:#0E7A4A;}
.qb-exp-correct .qb-exp-block-label{color:#0A5E38;}
.qb-exp-correct .qb-exp-block-count{background:#C0F0D8;color:#0A5E38;}
.qb-exp-correct textarea.qb-input{background:transparent;border:none;border-radius:0;padding:.85rem 1.1rem;box-shadow:none;min-height:80px;}
.qb-exp-correct textarea.qb-input:focus{border:none;box-shadow:none;outline:none;}
.qb-exp-wrong{background:#FEF4F7;border:1.5px solid #F0AABB;}
.qb-exp-wrong .qb-exp-block-header{background:#FDEAEF;border-bottom:1.5px solid #F0AABB;}
.qb-exp-wrong .qb-exp-block-icon{background:#FAC8D4;color:#8A0A2A;}
.qb-exp-wrong .qb-exp-block-label{color:#7A0A22;}
.qb-exp-wrong .qb-exp-block-count{background:#FAC8D4;color:#7A0A22;}
.qb-exp-wrong textarea.qb-input{background:transparent;border:none;border-radius:0;padding:.85rem 1.1rem;box-shadow:none;min-height:80px;}
.qb-exp-wrong textarea.qb-input:focus{border:none;box-shadow:none;outline:none;}
.qb-btn{padding:.65rem 1.35rem;border-radius:14px;font-size:.84rem;font-weight:700;cursor:pointer;border:none;transition:all .22s;display:inline-flex;align-items:center;gap:7px;}
.qb-btn:hover{transform:translateY(-2px);}
.qb-btn-success{background:linear-gradient(135deg,#22C27A,#14A860);color:#fff;box-shadow:0 3px 12px rgba(34,194,122,.22);}
.qb-btn-success:hover{background:linear-gradient(135deg,#14A860,#0A8A50);box-shadow:0 6px 20px rgba(34,194,122,.32);}
.qb-props{background:#fff;border:1.5px solid #E4E0FC;border-radius:20px;padding:0;box-shadow:0 4px 20px rgba(109,94,247,.08);overflow:hidden;}
.qb-props-header{padding:1rem 1.2rem .85rem;border-bottom:1.5px solid #EDEAFC;background:linear-gradient(135deg,#F6F4FF,#EEF2FF);display:flex;align-items:center;gap:9px;}
.qb-props-header-icon{width:26px;height:26px;border-radius:7px;background:linear-gradient(135deg,#C8C2F8,#A8A0F5);display:flex;align-items:center;justify-content:center;font-size:.8rem;color:#fff;flex-shrink:0;}
.qb-props-title{font-size:.68rem;font-weight:800;color:#7B7499;text-transform:uppercase;letter-spacing:1.5px;}
.qb-props-body{padding:1rem 1.1rem 1.1rem;}
.qb-prop-field{margin-bottom:1.1rem;}.qb-prop-field:last-child{margin-bottom:0;}
.qb-prop-label{display:flex;align-items:center;gap:7px;font-size:.82rem;font-weight:800;color:#1E1B3A;margin-bottom:6px;}
.qb-prop-label-icon{width:20px;height:20px;border-radius:5px;display:flex;align-items:center;justify-content:center;font-size:.72rem;flex-shrink:0;}
.qb-prop-label-icon.type{background:#EEF2FF;color:#6D5EF7;}
.qb-prop-label-icon.diff{background:#FEF0D8;color:#8A5000;}
.qb-err-msg{display:inline-flex;align-items:center;gap:6px;font-size:13px;font-weight:500;color:#DC3545;margin-top:4px;margin-bottom:6px;padding:0;line-height:1.4;width:fit-content;max-width:100%;}
.fib-add-btn{display:inline-flex;align-items:center;gap:6px;padding:.55rem 1.1rem;border-radius:11px;font-size:.81rem;font-weight:700;color:#6D5EF7;background:#F0EEFF;border:1.5px solid #C8C2F8;cursor:pointer;transition:all .2s;}
.fib-add-btn:hover{background:#E8E4FC;border-color:#6D5EF7;transform:translateY(-1px);box-shadow:0 3px 10px rgba(109,94,247,.12);}
.fib-add-btn.disabled{color:#7B7499;background:#F5F5F5;border-color:#E4E0FC;cursor:not-allowed;opacity:.55;transform:none;box-shadow:none;}
.rte-blank-chip{display:inline-block;padding:2px 12px;margin:0 2px;background:#F0EEFF;border:1.5px solid #C8C2F8;border-radius:8px;color:#6D5EF7;font-weight:700;font-size:.85rem;letter-spacing:2px;vertical-align:baseline;cursor:default;user-select:none;}
@media(max-width:1100px){.qb-layout{grid-template-columns:1fr;}.qb-nav,.qb-props{display:none;}}
@media(max-width:640px){.qb-opts{grid-template-columns:1fr;}.qb-tf-grid{grid-template-columns:1fr;}.qb-editor-body{padding:1.25rem;}.qb-toolbar{flex-direction:column;align-items:stretch;gap:.6rem;padding:.7rem 1rem;}.qb-toolbar-nav{justify-content:center;}.qb-toolbar-lang{padding:.5rem 1rem;justify-content:center;}}
@media(max-width:900px){.pq-hero{padding:2rem 1.75rem 1.75rem;}.pq-hero-meta{flex-direction:column;width:100%;}.pq-meta-item:not(:last-child){border-right:none;border-bottom:1.5px solid #D4CDFA;}}
@media(max-width:640px){.pq-hero-title{font-size:1.55rem;}.pq-hero-top{flex-direction:column;gap:1rem;}.pq-hero{padding:1.5rem 1.25rem 1.5rem;}}
/* --- SCIENCE DOODLES ------------------------------------ */
.pq-doodle{position:absolute;pointer-events:none;opacity:.10;line-height:1;display:inline-flex;z-index:1;}
@media(max-width:900px){.pq-doodle-sm{display:none;}}
@media(max-width:640px){.pq-doodle-hide{display:none;}.pq-doodle{opacity:.07;}}
</style>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label"><%: T("Notifications","Notifikasi") %></span></a></div>
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
        <div style="font-size:3rem;margin-bottom:1rem;">??</div>
        <h2 style="color:var(--pq-text);font-weight:800;"><%: T("Access Denied","Akses Ditolak") %></h2>
        <p style="color:var(--pq-muted);max-width:450px;"><%: T("Your account cannot access this page.","Akaun anda tidak boleh mengakses halaman ini.") %></p>
        <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="pq-back" style="margin-top:1rem;"><i class="bi bi-arrow-left"></i> <%: T("Back","Kembali") %></a>
    </div>
</asp:Panel>

<%-- Invalid Parameters --%>
<asp:Panel ID="pnlInvalid" runat="server" Visible="false">
    <div class="pq-denied">
        <div style="font-size:3rem;margin-bottom:1rem;">??</div>
        <h2 style="color:var(--pq-text);font-weight:800;"><%: T("Invalid Selection","Pilihan Tidak Sah") %></h2>
        <p style="color:var(--pq-muted);max-width:450px;"><asp:Literal ID="litInvalidMsg" runat="server" /></p>
        <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="pq-back" style="margin-top:1rem;"><i class="bi bi-arrow-left"></i> <%: T("Back to Manage Quizzes","Kembali ke Urus Kuiz") %></a>
    </div>
</asp:Panel>

<%-- Main content --%>
<asp:Panel ID="pnlMain" runat="server" Visible="false">

<%-- ------------------------------------------------------
     HERO HEADER
     ------------------------------------------------------ --%>
<div class="pq-hero">
    <div class="pq-hero-bg">
        <%-- Science doodle icons ? decorative only, not clickable --%>
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

<%-- Quiz Title --%>
<div class="pq-title-field">
    <label class="pq-title-label" id="pqTitleLabel"><%: T("Quiz Title","Tajuk Kuiz") %> *</label>
    <input type="text" id="pqTitleInput" class="pq-title-input" placeholder="<%: T("Enter quiz title...","Masukkan tajuk kuiz...") %>" maxlength="200" />
    <div id="pqTitleErr" class="pq-title-err" style="display:none;">
        <i class="bi bi-exclamation-circle-fill" style="font-size:13px;flex-shrink:0;"></i>
        <span id="pqTitleErrMsg"></span>
    </div>
</div>

<%-- Quiz builder --%>
<div id="pqValMsg" class="qb-err-msg" style="display:none;margin-bottom:1rem;padding:.75rem 1rem;background:#FEF2F2;border:1.5px solid #F8C8C8;border-radius:12px;font-size:.85rem;max-width:100%;width:auto;">
    <i class="bi bi-exclamation-circle-fill" style="font-size:14px;flex-shrink:0;"></i>
    <span id="pqValMsgText"></span>
</div>
<div class="qb-layout">

<%-- Left Nav ? Question Navigator --%>
<div class="qb-nav">
    <div class="qb-nav-header">
        <div class="qb-nav-title"><%: T("Questions","Soalan") %> <span class="qb-nav-count" id="navCount">1</span></div>
    </div>
    <div class="qb-nav-list" id="qbNavList"></div>
    <div class="qb-nav-footer">
        <button type="button" class="qb-nav-add" id="pqBtnAdd" onclick="pqAddQuestion()"><%: T("+ Add Question","+ Tambah Soalan") %></button>
    </div>
</div>

<%-- Center Editor --%>
<div class="qb-center">
    <%-- Toolbar --%>
    <div class="qb-toolbar">
        <div class="qb-toolbar-nav">
            <button type="button" id="qbNavPrev" class="qb-toolbar-arrow" onclick="pqNavGoTo(window.__PQ_CI-1)"><i class="bi bi-chevron-left"></i></button>
            <span id="qbNavLabel" class="qb-toolbar-label"></span>
            <button type="button" id="qbNavNext" class="qb-toolbar-arrow" onclick="pqNavGoTo(window.__PQ_CI+1)"><i class="bi bi-chevron-right"></i></button>
        </div>
        <button type="button" class="qb-btn qb-btn-success" style="margin:0;padding:.55rem 1.2rem;font-size:.82rem;" onclick="return pqSubmitQuiz()"><%: T("Submit Quiz","Hantar Kuiz") %></button>
    </div>

    <div class="qb-editor-body">

    <%-- Question Text --%>
    <div class="qb-field" style="margin-bottom:1.2rem;">
        <div class="qb-label">
            <span><%: T("Question","Soalan") %> *</span>
            <span class="qb-char-count" id="pqQCharCount">0 / 500</span>
        </div>
        <div class="qb-rte-wrap">
            <div class="qb-rte-toolbar">
                <button type="button" class="qb-rte-btn" onmousedown="event.preventDefault();pqRteExec('bold')" title="Bold"><i class="bi bi-type-bold"></i></button>
                <button type="button" class="qb-rte-btn" onmousedown="event.preventDefault();pqRteExec('italic')" title="Italic"><i class="bi bi-type-italic"></i></button>
                <button type="button" class="qb-rte-btn" onmousedown="event.preventDefault();pqRteExec('underline')" title="Underline"><i class="bi bi-type-underline"></i></button>
                <span class="qb-rte-sep"></span>
                <button type="button" class="qb-rte-btn" onmousedown="event.preventDefault();pqRteExec('insertUnorderedList')" title="Bullet List"><i class="bi bi-list-ul"></i></button>
                <button type="button" class="qb-rte-btn" onmousedown="event.preventDefault();pqRteExec('insertOrderedList')" title="Numbered List"><i class="bi bi-list-ol"></i></button>
                <span class="qb-rte-sep" id="pqFibSep" style="display:none;"></span>
                <span id="pqBlankCounter" style="display:none;margin-left:auto;font-size:.75rem;font-weight:600;color:#7B7499;"><%: T("Blanks","Kosong") %>: <strong id="pqBlankNum">0</strong> / 4</span>
                <button type="button" id="pqBtnAddBlank" style="display:none;margin-left:6px;padding:.4rem .8rem;font-size:.76rem;" class="fib-add-btn" onclick="pqAddBlank()"><i class="bi bi-plus-square-dotted"></i> <%: T("Add Blank","Tambah Kosong") %></button>
            </div>
            <div id="pqRteEditor" class="qb-rte-editor" contenteditable="true" data-placeholder="<%: T("Type your question here...","Taip soalan anda di sini...") %>"></div>
        </div>
        <textarea id="pqTxtQuestion" style="display:none;" maxlength="500"></textarea>
    </div>

    <%-- Question Image --%>
    <div class="qb-img-zone" id="pqImgZone">
        <div class="qb-img-upload" onclick="document.getElementById('pqImgInput').click()">
            <div class="qb-img-upload-icon"><i class="bi bi-image"></i></div>
            <span class="qb-img-upload-text"><%: T("Upload Image","Muat Naik Imej") %></span>
            <span class="qb-img-upload-sub"><%: T("Optional ? PNG, JPG, GIF up to 5 MB","Pilihan ? PNG, JPG, GIF sehingga 5 MB") %></span>
        </div>
        <input type="file" id="pqImgInput" accept="image/*" onchange="pqHandleImg(this)" style="display:none;" />
        <div class="qb-img-preview" id="pqImgPreview">
            <img id="pqImgPreviewSrc" src="" alt="" />
            <button type="button" class="qb-img-remove" onclick="pqRemoveImg()"><i class="bi bi-x"></i></button>
        </div>
    </div>

    <%-- MCQ Options --%>
    <div id="pqSectionMCQ" class="qb-answer-section">
        <div class="qb-section-header">
            <div class="qb-section-header-icon"><i class="bi bi-ui-radios"></i></div>
            <span class="qb-section-header-text" id="pqOptsLabel"><%: T("Options","Pilihan") %></span>
            <span class="qb-section-header-sub"><%: T("Select one correct answer","Pilih satu jawapan betul") %></span>
            <div class="qb-section-divider"></div>
        </div>
        <div class="qb-opts" id="pqMcqOpts">
            <div class="qb-opt"><div class="qb-opt-band">A</div><div class="qb-opt-body"><input type="text" class="qb-opt-input pq-opt-text" placeholder="<%: T("Enter option A...","Masukkan pilihan A...") %>" /></div><div class="qb-opt-selector" onclick="pqSelectCorrect(this)"></div></div>
            <div class="qb-opt"><div class="qb-opt-band">B</div><div class="qb-opt-body"><input type="text" class="qb-opt-input pq-opt-text" placeholder="<%: T("Enter option B...","Masukkan pilihan B...") %>" /></div><div class="qb-opt-selector" onclick="pqSelectCorrect(this)"></div></div>
            <div class="qb-opt"><div class="qb-opt-band">C</div><div class="qb-opt-body"><input type="text" class="qb-opt-input pq-opt-text" placeholder="<%: T("Enter option C...","Masukkan pilihan C...") %>" /></div><div class="qb-opt-selector" onclick="pqSelectCorrect(this)"></div></div>
            <div class="qb-opt"><div class="qb-opt-band">D</div><div class="qb-opt-body"><input type="text" class="qb-opt-input pq-opt-text" placeholder="<%: T("Enter option D...","Masukkan pilihan D...") %>" /></div><div class="qb-opt-selector" onclick="pqSelectCorrect(this)"></div></div>
        </div>
        <div id="pqMcqErr" class="qb-err-msg" style="display:none;"><i class="bi bi-exclamation-circle-fill" style="font-size:13px;flex-shrink:0;"></i> <span id="pqMcqErrMsg"></span></div>
    </div>

    <%-- True/False --%>
    <div id="pqSectionTF" class="qb-answer-section" style="display:none;">
        <div class="qb-section-header">
            <div class="qb-section-header-icon"><i class="bi bi-toggles"></i></div>
            <span class="qb-section-header-text"><%: T("Select the correct answer","Pilih jawapan yang betul") %></span>
            <div class="qb-section-divider"></div>
        </div>
        <div class="qb-tf-grid">
            <label class="qb-tf-card" id="pqTfTrue"><input type="radio" name="pqTfAnswer" value="A" onchange="pqUpdateTF()"/><i class="bi bi-check-circle-fill"></i><span>TRUE</span></label>
            <label class="qb-tf-card" id="pqTfFalse"><input type="radio" name="pqTfAnswer" value="B" onchange="pqUpdateTF()"/><i class="bi bi-x-circle-fill"></i><span>FALSE</span></label>
        </div>
        <div id="pqTfErr" class="qb-err-msg" style="display:none;"><i class="bi bi-exclamation-circle-fill" style="font-size:13px;flex-shrink:0;"></i> <span id="pqTfErrMsg"></span></div>
    </div>

    <%-- Multiselect --%>
    <div id="pqSectionMS" class="qb-answer-section" style="display:none;">
        <div class="qb-section-header">
            <div class="qb-section-header-icon"><i class="bi bi-check2-square"></i></div>
            <span class="qb-section-header-text"><%: T("Select all correct answers","Pilih semua jawapan betul") %></span>
            <span class="qb-ms-count" id="pqMsCount" style="margin-left:0;">0 <%: T("selected","dipilih") %></span>
            <div class="qb-section-divider"></div>
        </div>
        <div class="qb-opts" id="pqMsOpts">
            <div class="qb-opt qb-ms-opt"><div class="qb-opt-band">A</div><div class="qb-opt-body"><input type="checkbox" class="pq-ms-check" onchange="pqUpdateMS()"/><input type="text" class="qb-opt-input pq-ms-text" placeholder="<%: T("Type option A...","Taip pilihan A...") %>" /></div></div>
            <div class="qb-opt qb-ms-opt"><div class="qb-opt-band">B</div><div class="qb-opt-body"><input type="checkbox" class="pq-ms-check" onchange="pqUpdateMS()"/><input type="text" class="qb-opt-input pq-ms-text" placeholder="<%: T("Type option B...","Taip pilihan B...") %>" /></div></div>
            <div class="qb-opt qb-ms-opt"><div class="qb-opt-band">C</div><div class="qb-opt-body"><input type="checkbox" class="pq-ms-check" onchange="pqUpdateMS()"/><input type="text" class="qb-opt-input pq-ms-text" placeholder="<%: T("Type option C...","Taip pilihan C...") %>" /></div></div>
            <div class="qb-opt qb-ms-opt"><div class="qb-opt-band">D</div><div class="qb-opt-body"><input type="checkbox" class="pq-ms-check" onchange="pqUpdateMS()"/><input type="text" class="qb-opt-input pq-ms-text" placeholder="<%: T("Type option D...","Taip pilihan D...") %>" /></div></div>
        </div>
    </div>

    <%-- Drag & Drop --%>
    <div id="pqSectionFIB" class="qb-answer-section" style="display:none;">
        <div class="qb-section-header">
            <div class="qb-section-header-icon"><i class="bi bi-arrows-move"></i></div>
            <span class="qb-section-header-text"><%: T("Answer Options","Pilihan Jawapan") %> *</span>
            <span class="qb-section-header-sub">(<%: T("Max 4 words","Maks 4 perkataan") %>)</span>
            <div class="qb-section-divider"></div>
        </div>
        <div style="display:flex;align-items:flex-start;gap:10px;padding:.75rem 1rem;margin-bottom:1.1rem;background:#FFFBEB;border:1.5px solid #FDE68A;border-left:4px solid #D97706;border-radius:10px;">
            <span style="flex-shrink:0;width:26px;height:26px;border-radius:7px;background:#FEF3C7;color:#D97706;display:flex;align-items:center;justify-content:center;font-size:.85rem;"><i class="bi bi-info-circle-fill"></i></span>
            <span style="font-size:.74rem;color:#A16207;line-height:1.5;"><%: T("Use the toolbar above to insert [Blank] placeholders in your question text. Then fill in the word bank below and map each blank to its correct answer.","Gunakan bar alat di atas untuk memasukkan ruang kosong [Blank] dalam teks soalan anda. Kemudian isikan bank perkataan di bawah dan petakan setiap kosong kepada jawapan yang betul.") %></span>
        </div>
        <div id="pqDndBlankErr" class="qb-err-msg" style="display:none;"><i class="bi bi-exclamation-circle-fill" style="font-size:13px;flex-shrink:0;"></i> <span id="pqDndBlankErrMsg"></span></div>
        <div id="pqFibWords" style="display:grid;grid-template-columns:1fr 1fr;gap:.85rem;margin-bottom:1.1rem;">
            <div style="display:flex;align-items:center;gap:10px;padding:.65rem 1rem;border-radius:13px;border:1.5px solid #E4E0FC;background:#fff;"><span style="width:26px;height:26px;border-radius:50%;background:#F0EEFF;color:#6D5EF7;display:flex;align-items:center;justify-content:center;font-size:.73rem;font-weight:800;flex-shrink:0;">1</span><input type="text" class="qb-opt-input pq-fib-word" placeholder="<%: T("Word 1","Perkataan 1") %>" oninput="pqOnFibChange()" /></div>
            <div style="display:flex;align-items:center;gap:10px;padding:.65rem 1rem;border-radius:13px;border:1.5px solid #E4E0FC;background:#fff;"><span style="width:26px;height:26px;border-radius:50%;background:#F0EEFF;color:#6D5EF7;display:flex;align-items:center;justify-content:center;font-size:.73rem;font-weight:800;flex-shrink:0;">2</span><input type="text" class="qb-opt-input pq-fib-word" placeholder="<%: T("Word 2","Perkataan 2") %>" oninput="pqOnFibChange()" /></div>
            <div style="display:flex;align-items:center;gap:10px;padding:.65rem 1rem;border-radius:13px;border:1.5px solid #E4E0FC;background:#fff;"><span style="width:26px;height:26px;border-radius:50%;background:#F0EEFF;color:#6D5EF7;display:flex;align-items:center;justify-content:center;font-size:.73rem;font-weight:800;flex-shrink:0;">3</span><input type="text" class="qb-opt-input pq-fib-word" placeholder="<%: T("Word 3","Perkataan 3") %>" oninput="pqOnFibChange()" /></div>
            <div style="display:flex;align-items:center;gap:10px;padding:.65rem 1rem;border-radius:13px;border:1.5px solid #E4E0FC;background:#fff;"><span style="width:26px;height:26px;border-radius:50%;background:#F0EEFF;color:#6D5EF7;display:flex;align-items:center;justify-content:center;font-size:.73rem;font-weight:800;flex-shrink:0;">4</span><input type="text" class="qb-opt-input pq-fib-word" placeholder="<%: T("Word 4","Perkataan 4") %>" oninput="pqOnFibChange()" /></div>
        </div>
        <div id="pqDndWordsErr" class="qb-err-msg" style="display:none;"><i class="bi bi-exclamation-circle-fill" style="font-size:13px;flex-shrink:0;"></i> <span id="pqDndWordsErrMsg"></span></div>
        <%-- Mapping Section --%>
        <div id="pqFibMappingSection" style="display:none;margin-top:1.3rem;padding-top:1.3rem;border-top:1.5px dashed #D8D2F8;">
            <div style="font-size:.92rem;font-weight:800;color:#1E1B3A;margin-bottom:9px;display:flex;align-items:center;gap:6px;"><i class="bi bi-arrow-left-right" style="color:#6D5EF7;"></i> <%: T("Correct Answer Mapping","Pemetaan Jawapan Betul") %> *</div>
            <div id="pqFibMappings" style="display:flex;flex-direction:column;gap:8px;"></div>
            <div id="pqFibMapError" style="display:none;margin-top:6px;display:flex;align-items:center;gap:8px;padding:.65rem 1rem;border-radius:11px;background:#FEF4F7;border:1px solid #F0AABB;color:#8A0A2A;font-size:.77rem;font-weight:700;">
                <i class="bi bi-exclamation-circle-fill"></i> <%: T("Each blank must map to a unique word.","Setiap kosong mesti dipetakan kepada perkataan unik.") %>
            </div>
            <div id="pqDndMapErr" class="qb-err-msg" style="display:none;margin-top:6px;"><i class="bi bi-exclamation-circle-fill" style="font-size:13px;flex-shrink:0;"></i> <span id="pqDndMapErrMsg"></span></div>
        </div>
    </div>

    <%-- Explanations --%>
    <div class="qb-section-header" style="margin-top:.5rem;">
        <div class="qb-section-header-icon"><i class="bi bi-chat-quote-fill"></i></div>
        <span class="qb-section-header-text"><%: T("Explanations","Penjelasan") %></span>
        <div class="qb-section-divider"></div>
    </div>
    <div class="qb-exp-block qb-exp-correct">
        <div class="qb-exp-block-header">
            <div class="qb-exp-block-icon"><i class="bi bi-check-circle-fill"></i></div>
            <span class="qb-exp-block-label" id="pqCeLabel"><%: T("Correct Explanation","Penjelasan Betul") %> *</span>
            <span class="qb-exp-block-count" id="pqCeCount">0 / 500</span>
        </div>
        <textarea id="pqTxtCE" class="qb-input qb-textarea" maxlength="500" placeholder="<%: T("Explain why this answer is correct...","Terangkan mengapa jawapan ini betul...") %>"></textarea>
    </div>
    <div class="qb-exp-block qb-exp-wrong">
        <div class="qb-exp-block-header">
            <div class="qb-exp-block-icon"><i class="bi bi-x-circle-fill"></i></div>
            <span class="qb-exp-block-label" id="pqWeLabel"><%: T("Wrong Explanation","Penjelasan Salah") %> *</span>
            <span class="qb-exp-block-count" id="pqWeCount">0 / 500</span>
        </div>
        <textarea id="pqTxtWE" class="qb-input qb-textarea" maxlength="500" placeholder="<%: T("Explain why the other answers are incorrect...","Terangkan mengapa jawapan lain salah...") %>"></textarea>
    </div>

    </div><%-- /.qb-editor-body --%>
</div><%-- /.qb-center --%>

<%-- Right Props --%>
<div class="qb-props">
    <div class="qb-props-header">
        <div class="qb-props-header-icon"><i class="bi bi-sliders"></i></div>
        <div class="qb-props-title"><%: T("Properties","Sifat") %></div>
    </div>
    <div class="qb-props-body">
        <div class="qb-prop-field">
            <div class="qb-prop-label"><span class="qb-prop-label-icon type"><i class="bi bi-ui-checks"></i></span> <%: T("Question Type","Jenis Soalan") %></div>
            <select id="pqDdlType" class="qb-input" onchange="pqSwitchType()">
                <option value="MCQ"><%: T("MCQ","Aneka Pilihan") %></option>
                <option value="True/False"><%: T("True / False","Betul / Salah") %></option>
                <option value="Multiselect"><%: T("Multiselect","Pelbagai Pilihan") %></option>
                <option value="Drag & Drop"><%: T("Drag & Drop","Seret & Letak") %></option>
            </select>
        </div>
        <div class="qb-prop-field">
            <div class="qb-prop-label"><span class="qb-prop-label-icon diff"><i class="bi bi-bar-chart-fill"></i></span> <%: T("Difficulty","Kesukaran") %></div>
            <select id="pqDdlDiff" class="qb-input">
                <option value="Easy"><%: T("Easy","Mudah") %></option>
                <option value="Medium" selected><%: T("Medium","Sederhana") %></option>
                <option value="Hard"><%: T("Hard","Sukar") %></option>
            </select>
        </div>
    </div>
</div>

</div><%-- /.qb-layout --%>


<div id="pqToast" class="pq-toast-container"></div>

<%-- ------------------------------------------------------
     SETTINGS MODAL
     ------------------------------------------------------ --%>
<div id="pqSettingsModal" class="pq-modal-overlay" style="display:none;" onclick="if(event.target===this)closeSettingsModal()">
    <div class="pq-modal">
        <div class="pq-modal-header">
            <div>
                <h3><%: T("Quiz Settings","Tetapan Kuiz") %></h3>
                <p><%: T("Change the learning area for this practice quiz.","Tukar kawasan pembelajaran untuk kuiz latihan ini.") %></p>
            </div>
            <button type="button" class="pq-modal-close" onclick="closeSettingsModal()">?</button>
        </div>
        <div class="pq-modal-body">
            <div class="pq-form-row">
                <label class="pq-form-label"><%: T("Level","Tahap") %> *</label>
                <select id="stgLevel" class="pq-form-select" onchange="stgOnLevelChange(this.value)">
                    <option value=""><%: T("? Select Level ?","? Pilih Tahap ?") %></option>
                </select>
            </div>
            <div class="pq-form-row">
                <label class="pq-form-label"><%: T("Unit","Unit") %> *</label>
                <select id="stgUnit" class="pq-form-select" onchange="stgOnUnitChange(this.value)" disabled>
                    <option value=""><%: T("? Select Unit ?","? Pilih Unit ?") %></option>
                </select>
            </div>
            <div class="pq-form-row">
                <label class="pq-form-label"><%: T("Subtopic","Subtopik") %> *</label>
                <select id="stgSubtopic" class="pq-form-select" onchange="_stgCheckApply()" disabled>
                    <option value=""><%: T("? Select Subtopic ?","? Pilih Subtopik ?") %></option>
                </select>
            </div>
            <div class="pq-form-row" style="margin-bottom:0;">
                <label class="pq-form-label"><%: T("Language","Bahasa") %> *</label>
                <select id="stgLanguage" class="pq-form-select" onchange="_stgCheckApply()">
                    <option value=""><%: T("? Select Language ?","? Pilih Bahasa ?") %></option>
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

<%-- ------------------------------------------------------
     CONFIRM RESET MODAL
     ------------------------------------------------------ --%>
<div id="pqConfirmModal" class="pq-confirm-overlay" style="display:none;" onclick="if(event.target===this)closeConfirmModal()">
    <div class="pq-confirm-modal">
        <div class="pq-modal-header">
            <div>
                <h3><%: T("Confirm Settings Change","Sahkan Perubahan Tetapan") %></h3>
            </div>
            <button type="button" class="pq-modal-close" onclick="closeConfirmModal()">?</button>
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
<asp:HiddenField ID="hidQuizTitle"  runat="server" />
<asp:HiddenField ID="hidQuestionsJson" runat="server" />
<asp:HiddenField ID="hidSubmitSuccess" runat="server" />
<asp:Button ID="btnSubmitPQ" runat="server" Style="display:none;" OnClick="btnSubmitPQ_Click" CausesValidation="false" />

</asp:Panel><%-- /pnlMain --%>

</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
var __PQ_SITE_LANG='<%= CurrentLanguage %>';
function _pqT(en,bm){return __PQ_SITE_LANG==='BM'?bm:en;}

// -- Tracked current selections ---------------------------------
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

// -- Settings modal open / close --------------------------------
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
                lvDd.innerHTML = '<option value="">? Select Level ?</option>';
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

// -- Cascading loads --------------------------------------------
function stgOnLevelChange(levelId) {
    var stDd = document.getElementById('stgSubtopic');
    stDd.innerHTML = '<option value="">? Select Subtopic ?</option>';
    stDd.disabled = true;
    _stgCheckApply();
    _stgLoadUnits(levelId, '');
}

function _stgLoadUnits(levelId, preselect) {
    var unDd = document.getElementById('stgUnit');
    var stDd = document.getElementById('stgSubtopic');
    stDd.innerHTML = '<option value="">? Select Subtopic ?</option>';
    stDd.disabled = true;
    unDd.innerHTML = '<option value="">? Select Unit ?</option>';
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
            unDd.innerHTML = '<option value="">? Select Unit ?</option>';
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
    stDd.innerHTML = '<option value="">? Select Subtopic ?</option>';
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
            stDd.innerHTML = '<option value="">? Select Subtopic ?</option>';
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

// -- Apply ------------------------------------------------------
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
        // Nothing changed ? just close
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

    // -- Update hero spans --
    document.getElementById('heroLevel').textContent    = _stgPending.levelName;
    document.getElementById('heroUnit').textContent     = _stgPending.unitName;
    document.getElementById('heroSubtopic').textContent = _stgPending.subtopicName;
    document.getElementById('heroLanguage').textContent = _stgPending.languageName;

    // -- Update hidden fields --
    document.getElementById('<%=hidLevelId.ClientID%>').value    = _stgPending.levelId;
    document.getElementById('<%=hidUnitId.ClientID%>').value     = _stgPending.unitId;
    document.getElementById('<%=hidSubtopicId.ClientID%>').value = _stgPending.subtopicId;
    document.getElementById('<%=hidLanguage.ClientID%>').value   = _stgPending.language;

    // -- Sync in-memory state --
    _pqCur.levelId      = _stgPending.levelId;
    _pqCur.levelName    = _stgPending.levelName;
    _pqCur.unitId       = _stgPending.unitId;
    _pqCur.unitName     = _stgPending.unitName;
    _pqCur.subtopicId   = _stgPending.subtopicId;
    _pqCur.subtopicName = _stgPending.subtopicName;
    _pqCur.language     = _stgPending.language;
    _pqCur.languageName = _stgPending.languageName;

    // -- Update URL without reload --
    if (window.history && window.history.replaceState) {
        window.history.replaceState(null, '',
            'createPracticeQuiz.aspx?levelId='    + encodeURIComponent(_stgPending.levelId)
            + '&unitId='     + encodeURIComponent(_stgPending.unitId)
            + '&subtopicId=' + encodeURIComponent(_stgPending.subtopicId)
            + '&language='   + encodeURIComponent(_stgPending.language));
    }
    _stgPending = null;
}

/* --- PRACTICE QUIZ ? QUESTION BUILDER ENGINE ------------- */
window.__PQ_QD=[{qEN:'',qBM:'',aEN:'',aBM:'',bEN:'',bBM:'',cEN:'',cBM:'',dEN:'',dBM:'',ceEN:'',ceBM:'',weEN:'',weBM:'',correct:'',type:'MCQ',diff:'Medium',img:'',imgDataUrl:'',msAEN:'',msABM:'',msBEN:'',msBBM:'',msCEN:'',msCBM:'',msDEN:'',msDBM:'',msChk:'',fibEN:['','','',''],fibBM:['','','',''],fibMapEN:[],fibMapBM:[]}];
window.__PQ_CI=0;
/* Content language ? determined by the hero Language field, NOT by a tab */
window.__PQ_CT=(document.getElementById('<%=hidLanguage.ClientID%>')||{}).value||'EN';

function pqEmptyQ(){return{qEN:'',qBM:'',aEN:'',aBM:'',bEN:'',bBM:'',cEN:'',cBM:'',dEN:'',dBM:'',ceEN:'',ceBM:'',weEN:'',weBM:'',correct:'',type:'MCQ',diff:'Medium',img:'',imgDataUrl:'',msAEN:'',msABM:'',msBEN:'',msBBM:'',msCEN:'',msCBM:'',msDEN:'',msDBM:'',msChk:'',fibEN:['','','',''],fibBM:['','','',''],fibMapEN:[],fibMapBM:[]};}

/* -- RTE helpers -- */
function pqRteExec(cmd){document.execCommand(cmd,false,null);pqRteSync();}
function pqRteSync(){var ed=document.getElementById('pqRteEditor'),ta=document.getElementById('pqTxtQuestion');if(ed&&ta){ta.value=ed.innerHTML;var cc=document.getElementById('pqQCharCount');if(cc)cc.textContent=(ed.textContent||'').length+' / 500';}pqUpdateBlankCount();}
function pqRteSetContent(html){var ed=document.getElementById('pqRteEditor');if(ed){ed.innerHTML=html||'';pqRteSync();}}

/* -- Capture & Populate -- */
function pqCapture(){
    var q=window.__PQ_QD[window.__PQ_CI],tab=window.__PQ_CT;
    pqRteSync();
    var ta=document.getElementById('pqTxtQuestion');
    if(tab==='EN'){q.qEN=ta?ta.value:'';} else{q.qBM=ta?ta.value:'';}
    var opts=document.querySelectorAll('#pqMcqOpts .pq-opt-text');
    var letters=['a','b','c','d'];
    opts.forEach(function(inp,i){q[letters[i]+(tab==='EN'?'EN':'BM')]=inp.value;});
    var ce=document.getElementById('pqTxtCE'),we=document.getElementById('pqTxtWE');
    if(tab==='EN'){q.ceEN=ce?ce.value:'';q.weEN=we?we.value:'';} else{q.ceBM=ce?ce.value:'';q.weBM=we?we.value:'';}
    q.type=document.getElementById('pqDdlType').value;
    q.diff=document.getElementById('pqDdlDiff').value;
    /* Multiselect */
    var msInputs=document.querySelectorAll('#pqMsOpts .pq-ms-text');
    var msKeys=(tab==='EN')?['msAEN','msBEN','msCEN','msDEN']:['msABM','msBBM','msCBM','msDBM'];
    msInputs.forEach(function(inp,i){if(msKeys[i])q[msKeys[i]]=inp.value;});
    var msChecked=[];
    document.querySelectorAll('#pqMsOpts .pq-ms-check').forEach(function(cb,i){if(cb.checked)msChecked.push(['A','B','C','D'][i]);});
    q.msChk=msChecked.join(',');
    /* True/False */
    var tfR=document.querySelector('input[name="pqTfAnswer"]:checked');
    if(q.type==='True/False'&&tfR)q.correct=tfR.value;
    /* Drag & Drop word bank */
    var fibInputs=document.querySelectorAll('#pqFibWords .pq-fib-word');
    var fibArr=[];fibInputs.forEach(function(inp){fibArr.push(inp.value||'');});
    if(tab==='EN')q.fibEN=fibArr; else q.fibBM=fibArr;
    /* Drag & Drop mappings */
    var mapSelects=document.querySelectorAll('#pqFibMappings .pq-fib-map-dd');
    if(mapSelects.length>0){
        var mapArr=[];mapSelects.forEach(function(sel){mapArr.push(sel.value);});
        if(tab==='EN')q.fibMapEN=mapArr; else q.fibMapBM=mapArr;
    }
}

function pqPopulate(q,tab){
    var isEN=(tab==='EN');
    pqRteSetContent(isEN?q.qEN:q.qBM);
    var opts=document.querySelectorAll('#pqMcqOpts .pq-opt-text');
    var vals=isEN?[q.aEN,q.bEN,q.cEN,q.dEN]:[q.aBM,q.bBM,q.cBM,q.dBM];
    opts.forEach(function(inp,i){inp.value=vals[i]||'';});
    document.getElementById('pqTxtCE').value=isEN?q.ceEN||'':q.ceBM||'';
    document.getElementById('pqTxtWE').value=isEN?q.weEN||'':q.weBM||'';
    document.getElementById('pqDdlType').value=q.type||'MCQ';
    document.getElementById('pqDdlDiff').value=q.diff||'Medium';
    pqSwitchType();pqUpdateCorrectUI(q);pqUpdateCharCounts();
    /* Multiselect */
    var msInputs=document.querySelectorAll('#pqMsOpts .pq-ms-text');
    var msVals=isEN?[q.msAEN,q.msBEN,q.msCEN,q.msDEN]:[q.msABM,q.msBBM,q.msCBM,q.msDBM];
    msInputs.forEach(function(inp,i){inp.value=msVals[i]||'';});
    var chkStr=q.msChk||'';var chkLetters=chkStr?chkStr.split(','):[];
    document.querySelectorAll('#pqMsOpts .pq-ms-check').forEach(function(cb,i){cb.checked=chkLetters.indexOf(['A','B','C','D'][i])>-1;});
    pqUpdateMS();
    /* True/False */
    document.querySelectorAll('input[name="pqTfAnswer"]').forEach(function(r){r.checked=(q.type==='True/False'&&r.value===q.correct);});
    pqUpdateTF();
    /* Drag & Drop word bank */
    var fibInputs=document.querySelectorAll('#pqFibWords .pq-fib-word');
    var fibVals=isEN?(q.fibEN||['','','','']):(q.fibBM||['','','','']);
    fibInputs.forEach(function(inp,i){inp.value=fibVals[i]||'';});
    /* Rebuild D&D mappings */
    if(q.type==='Drag & Drop')pqBuildMappings();
    /* Image */
    var imgPreview=document.getElementById('pqImgPreview');
    var imgSrc=document.getElementById('pqImgPreviewSrc');
    var imgUpload=document.querySelector('#pqImgZone .qb-img-upload');
    if(q.imgDataUrl){
        imgSrc.src=q.imgDataUrl;
        imgPreview.style.display='block';
        imgUpload.style.display='none';
    }else{
        imgPreview.style.display='none';
        imgSrc.src='';
        imgUpload.style.display='flex';
    }
    document.getElementById('pqImgInput').value='';
    /* Labels */
    pqUpdateLabels();
}

/* -- Navigation -- */
function pqNavGoTo(idx){
    if(idx<0||idx>=window.__PQ_QD.length)return;
    pqCapture();
    pqClearInlineErr();
    window.__PQ_CI=idx;
    pqPopulate(window.__PQ_QD[idx],window.__PQ_CT);
    pqRebuildNav();pqUpdateNavLabel();
}

function pqAddQuestion(){
    pqCapture();
    window.__PQ_QD.push(pqEmptyQ());
    window.__PQ_CI=window.__PQ_QD.length-1;
    pqPopulate(window.__PQ_QD[window.__PQ_CI],window.__PQ_CT);
    pqRebuildNav();pqUpdateNavLabel();
}

function pqUpdateLabels(){
    var ol=document.getElementById('pqOptsLabel');
    if(ol)ol.textContent=_pqT('Options','Pilihan');
    var ce=document.getElementById('pqCeLabel');
    if(ce)ce.textContent=_pqT('Correct Explanation','Penjelasan Betul')+' *';
    var we=document.getElementById('pqWeLabel');
    if(we)we.textContent=_pqT('Wrong Explanation','Penjelasan Salah')+' *';
}

function pqUpdateNavLabel(){
    var lbl=document.getElementById('qbNavLabel');
    var total=window.__PQ_QD.length,current=window.__PQ_CI+1;
    if(lbl)lbl.textContent=_pqT('Question '+current+' of '+total,'Soalan '+current+' daripada '+total);
    var prev=document.getElementById('qbNavPrev'),next=document.getElementById('qbNavNext');
    if(prev){prev.disabled=(current<=1);prev.style.opacity=(current<=1)?'.35':'1';}
    if(next){next.disabled=(current>=total);next.style.opacity=(current>=total)?'.35':'1';}
    var nc=document.getElementById('navCount');if(nc)nc.textContent=total;
}

function pqRebuildNav(){
    var list=document.getElementById('qbNavList');if(!list)return;
    var html='';
    window.__PQ_QD.forEach(function(q,i){
        var active=i===window.__PQ_CI?' active':'';
        html+='<div class="qb-nav-row"><button type="button" class="qb-nav-item'+active+'" onclick="pqNavGoTo('+i+')"><span class="qb-nav-badge">'+(i+1)+'</span> Q'+(i+1)+'</button>';
        html+='<button type="button" class="qb-nav-del'+(window.__PQ_QD.length<=1?' disabled':'')+'" title="'+_pqT('Delete','Padam')+'" onclick="pqDeleteQ('+i+')"><i class="bi bi-trash3"></i></button></div>';
    });
    list.innerHTML=html;
}

function pqDeleteQ(idx){
    if(window.__PQ_QD.length<=1)return;
    window.__PQ_QD.splice(idx,1);
    if(window.__PQ_CI>=window.__PQ_QD.length)window.__PQ_CI=window.__PQ_QD.length-1;
    pqPopulate(window.__PQ_QD[window.__PQ_CI],window.__PQ_CT);
    pqRebuildNav();pqUpdateNavLabel();
}

/* -- Question Type -- */
function pqSwitchType(){
    var v=document.getElementById('pqDdlType').value;
    document.getElementById('pqSectionMCQ').style.display=(v==='MCQ')?'block':'none';
    document.getElementById('pqSectionTF').style.display=(v==='True/False')?'block':'none';
    document.getElementById('pqSectionMS').style.display=(v==='Multiselect')?'block':'none';
    document.getElementById('pqSectionFIB').style.display=(v==='Drag & Drop')?'block':'none';
    /* Show/hide Add Blank toolbar items */
    var isFib=(v==='Drag & Drop');
    document.getElementById('pqFibSep').style.display=isFib?'':'none';
    document.getElementById('pqBlankCounter').style.display=isFib?'':'none';
    document.getElementById('pqBtnAddBlank').style.display=isFib?'':'none';
    if(isFib)pqUpdateBlankCount();
}

/* -- Add Blank -- */
function pqAddBlank(){
    var btn=document.getElementById('pqBtnAddBlank');
    if(btn.classList.contains('disabled'))return;
    var ed=document.getElementById('pqRteEditor');if(!ed)return;
    var text=ed.innerText||'';
    var blankRe=/\[Blank \d+\]/g;
    var existing=(text.match(blankRe)||[]).length;
    if(existing>=4)return;
    var nextNum=existing+1;
    /* Insert blank chip at cursor or end */
    ed.focus();
    var chip='<span class="rte-blank-chip" contenteditable="false">[Blank '+nextNum+']</span>&nbsp;';
    document.execCommand('insertHTML',false,chip);
    pqRteSync();
    pqUpdateBlankCount();
}

function pqUpdateBlankCount(){
    var ed=document.getElementById('pqRteEditor');
    var text=ed?(ed.innerText||''):'';
    var count=(text.match(/\[Blank \d+\]/g)||[]).length;
    var numEl=document.getElementById('pqBlankNum');if(numEl)numEl.textContent=count;
    var ctr=document.getElementById('pqBlankCounter');if(ctr)ctr.style.color=count>=4?'#E53E5E':'#7B7499';
    var btn=document.getElementById('pqBtnAddBlank');
    if(btn){if(count>=4)btn.classList.add('disabled');else btn.classList.remove('disabled');}
    /* Rebuild mappings when blanks change */
    if(document.getElementById('pqDdlType').value==='Drag & Drop')pqBuildMappings();
}

/* -- Correct answer (MCQ) -- */
function pqSelectCorrect(el){
    var opt=el.closest('.qb-opt');
    document.querySelectorAll('#pqMcqOpts .qb-opt').forEach(function(o){o.classList.remove('correct');});
    opt.classList.add('correct');
    var idx=Array.prototype.indexOf.call(opt.parentNode.children,opt);
    window.__PQ_QD[window.__PQ_CI].correct=['A','B','C','D'][idx];
    var errEl=document.getElementById('pqMcqErr');if(errEl)errEl.style.display='none';
}
function pqUpdateCorrectUI(q){
    var letters=['A','B','C','D'];
    document.querySelectorAll('#pqMcqOpts .qb-opt').forEach(function(o,i){
        o.classList.toggle('correct',q.correct===letters[i]);
        var inp=o.querySelector('.pq-opt-text');
        o.classList.toggle('has-text',inp&&inp.value.trim().length>0);
    });
}

/* -- True/False -- */
function pqUpdateTF(){
    document.querySelectorAll('.qb-tf-card').forEach(function(c){c.classList.remove('selected');});
    document.querySelectorAll('.qb-tf-card input[type="radio"]').forEach(function(r){if(r.checked)r.closest('.qb-tf-card').classList.add('selected');});
    var errEl=document.getElementById('pqTfErr');if(errEl)errEl.style.display='none';
}

/* -- Multiselect -- */
function pqUpdateMS(){
    var count=0;
    document.querySelectorAll('#pqMsOpts .qb-ms-opt').forEach(function(o){var cb=o.querySelector('.pq-ms-check');if(cb&&cb.checked){o.classList.add('selected');count++;}else o.classList.remove('selected');});
    var el=document.getElementById('pqMsCount');if(el)el.textContent=count+' '+_pqT('selected','dipilih');
}

/* -- Drag & Drop -- */
function pqOnFibChange(){
    pqBuildMappings();
}

function pqBuildMappings(){
    var ed=document.getElementById('pqRteEditor');
    var text=ed?(ed.innerText||''):'';
    var blanks=(text.match(/\[Blank \d+\]/g)||[]);
    var words=[];
    document.querySelectorAll('#pqFibWords .pq-fib-word').forEach(function(inp){
        if(inp.value.trim())words.push(inp.value.trim());
    });
    var mapSection=document.getElementById('pqFibMappingSection');
    var container=document.getElementById('pqFibMappings');
    if(blanks.length>0&&words.length>=2){
        mapSection.style.display='block';
        var q=window.__PQ_QD[window.__PQ_CI];
        var CL=window.__PQ_CT;
        var storedMap=(CL==='EN')?(q.fibMapEN||[]):(q.fibMapBM||[]);
        var html='';
        blanks.forEach(function(b,bi){
            var selectedVal=storedMap[bi]||'';
            var opts='<option value="">-- '+_pqT('Select word','Pilih perkataan')+' --</option>';
            words.forEach(function(w,wi){
                opts+='<option value="'+(wi+1)+'"'+(selectedVal===''+(wi+1)?' selected':'')+'>'+w+'</option>';
            });
            html+='<div style="display:flex;align-items:center;gap:10px;padding:.65rem 1rem;border-radius:13px;border:1.5px solid #E4E0FC;background:#fff;transition:all .25s;">';
            html+='<span style="font-size:.79rem;font-weight:700;color:#6D5EF7;white-space:nowrap;min-width:65px;">'+b+'</span>';
            html+='<span style="color:#7B7499;font-size:.86rem;"><i class="bi bi-arrow-right"></i></span>';
            html+='<select class="qb-input pq-fib-map-dd" style="flex:1;border-radius:9px;border:1.5px solid #E4E0FC;padding:.45rem .7rem;font-size:.81rem;" data-blank-idx="'+bi+'" onchange="pqOnMapChange()">';
            html+=opts+'</select></div>';
        });
        container.innerHTML=html;
    }else{
        mapSection.style.display='none';
        container.innerHTML='';
    }
}

function pqOnMapChange(){
    /* Clear inline D&D mapping error */
    var dndMapErr=document.getElementById('pqDndMapErr');if(dndMapErr)dndMapErr.style.display='none';
    /* Save mapping selections to question data */
    var q=window.__PQ_QD[window.__PQ_CI];
    var CL=window.__PQ_CT;
    var mapKey=(CL==='EN')?'fibMapEN':'fibMapBM';
    var selects=document.querySelectorAll('#pqFibMappings .pq-fib-map-dd');
    var mappings=[];
    selects.forEach(function(sel){mappings.push(sel.value);});
    q[mapKey]=mappings;
    /* Check for duplicates */
    var errEl=document.getElementById('pqFibMapError');
    var filled=mappings.filter(function(v){return v;});
    var unique=[];var hasDup=false;
    filled.forEach(function(v){if(unique.indexOf(v)>-1)hasDup=true;else unique.push(v);});
    if(errEl)errEl.style.display=hasDup?'flex':'none';
}

/* -- Char counts -- */
function pqUpdateCharCounts(){
    var ce=document.getElementById('pqTxtCE'),we=document.getElementById('pqTxtWE');
    var cec=document.getElementById('pqCeCount'),wec=document.getElementById('pqWeCount');
    if(ce&&cec)cec.textContent=ce.value.length+' / 500';
    if(we&&wec)wec.textContent=we.value.length+' / 500';
}

/* -- Image -- */
function pqHandleImg(input){
    if(!input.files||!input.files[0])return;
    var file=input.files[0];
    if(file.size>5*1024*1024){pqShowErr(_pqT('Image must be under 5 MB.','Imej mestilah kurang daripada 5 MB.'));return;}
    var reader=new FileReader();
    reader.onload=function(e){
        var dataUrl=e.target.result;
        document.getElementById('pqImgPreviewSrc').src=dataUrl;
        document.getElementById('pqImgPreview').style.display='block';
        document.querySelector('#pqImgZone .qb-img-upload').style.display='none';
        window.__PQ_QD[window.__PQ_CI].img=file.name;
        window.__PQ_QD[window.__PQ_CI].imgDataUrl=dataUrl;
    };
    reader.readAsDataURL(file);
}
function pqRemoveImg(){
    document.getElementById('pqImgPreview').style.display='none';
    document.querySelector('#pqImgZone .qb-img-upload').style.display='flex';
    document.getElementById('pqImgInput').value='';
    window.__PQ_QD[window.__PQ_CI].img='';
    window.__PQ_QD[window.__PQ_CI].imgDataUrl='';
}

/* ── Inline validation message (no alert) ── */
function pqShowErr(msg){
    var el=document.getElementById('pqValMsg');
    var txt=document.getElementById('pqValMsgText');
    if(el&&txt){txt.textContent=msg;el.style.display='inline-flex';
        setTimeout(function(){el.scrollIntoView({behavior:'smooth',block:'center'});},50);
    }
}
function pqClearErr(){
    var el=document.getElementById('pqValMsg');
    if(el)el.style.display='none';
    pqClearInlineErr();
}
function pqInlineErr(containerId,msg){
    var el=document.getElementById(containerId);
    var span=document.getElementById(containerId+'Msg');
    if(el&&span){span.textContent=msg;el.style.display='inline-flex';
        setTimeout(function(){el.scrollIntoView({behavior:'smooth',block:'center'});},50);
    }
}
function pqClearInlineErr(){
    ['pqMcqErr','pqTfErr','pqDndBlankErr','pqDndWordsErr','pqDndMapErr'].forEach(function(id){
        var el=document.getElementById(id);if(el)el.style.display='none';
    });
}

/* -- Submit -- */
function pqSubmitQuiz(){
    pqCapture();
    pqClearErr();
    /* Validate title */
    if(!pqValidateTitle())return false;
    /* Validate all questions */
    for(var i=0;i<window.__PQ_QD.length;i++){
        var q=window.__PQ_QD[i];
        var qType=q.type||'MCQ';
        var lbl=_pqT('Question '+(i+1),'Soalan '+(i+1));
        var CL=window.__PQ_CT; /* content language: 'EN' or 'BM' */
        var qSuf=(CL==='EN')?'EN':'BM';

        /* -- Required question text -- */
        var qText=q['q'+qSuf]||'';
        if(!qText.trim()){pqNavGoTo(i);pqShowErr(lbl+': '+_pqT('Please fill in the required field.','Sila isi ruangan yang diperlukan.'));return false;}

        /* -- Required explanations -- */
        if(!(q['ce'+qSuf]||'').trim()){pqNavGoTo(i);pqShowErr(lbl+': '+_pqT('Please fill in the required field.','Sila isi ruangan yang diperlukan.'));return false;}
        if(!(q['we'+qSuf]||'').trim()){pqNavGoTo(i);pqShowErr(lbl+': '+_pqT('Please fill in the required field.','Sila isi ruangan yang diperlukan.'));return false;}

        /* -- MCQ -- */
        if(qType==='MCQ'){
            /* Min 2 options */
            var mcqOpts=[q['a'+qSuf],q['b'+qSuf]].filter(function(v){return v&&v.trim();}).length;
            if(mcqOpts<2){pqNavGoTo(i);pqShowErr(lbl+': '+_pqT('Please fill in the required field.','Sila isi ruangan yang diperlukan.'));return false;}
            /* Correct answer selected */
            if(!q.correct){pqNavGoTo(i);pqInlineErr('pqMcqErr',_pqT('Please select the correct answer.','Sila pilih jawapan yang betul.'));return false;}
            /* Correct answer option has text */
            var cVal={'A':q['a'+qSuf],'B':q['b'+qSuf],'C':q['c'+qSuf],'D':q['d'+qSuf]}[q.correct]||'';
            if(!cVal.trim()){pqNavGoTo(i);pqInlineErr('pqMcqErr',_pqT('The selected correct answer must contain answer text.','Jawapan betul yang dipilih mesti mempunyai teks jawapan.'));return false;}
        }

        /* -- True/False -- */
        if(qType==='True/False'){
            if(!q.correct){pqNavGoTo(i);pqInlineErr('pqTfErr',_pqT('Please select the correct answer.','Sila pilih jawapan yang betul.'));return false;}
        }

        /* -- Multiselect -- */
        if(qType==='Multiselect'){
            /* Min 3 options */
            var msKeys=CL==='EN'?[q.msAEN,q.msBEN,q.msCEN,q.msDEN]:[q.msABM,q.msBBM,q.msCBM,q.msDBM];
            var msFilled=msKeys.filter(function(v){return v&&v.trim();}).length;
            if(msFilled<3){pqNavGoTo(i);pqShowErr(lbl+': '+_pqT('Multi-select questions must contain at least three answer options.','Soalan Aneka Pilihan Berbilang mesti mempunyai sekurang-kurangnya tiga pilihan jawapan.'));return false;}
            /* Min 2 correct answers */
            var chkLetters=(q.msChk||'').split(',').filter(function(l){return l.trim();});
            if(chkLetters.length<2){pqNavGoTo(i);pqShowErr(lbl+': '+_pqT('Please select at least two correct answers for a Multi-select question.','Sila pilih sekurang-kurangnya dua jawapan yang betul.'));return false;}
            /* Each selected correct answer has text */
            var msMap={'A':0,'B':1,'C':2,'D':3};
            var msBad=false;
            chkLetters.forEach(function(l){var j=msMap[l];if(j!==undefined&&!(msKeys[j]||'').trim())msBad=true;});
            if(msBad){pqNavGoTo(i);pqShowErr(lbl+': '+_pqT('All selected correct answers must contain answer text.','Semua jawapan betul yang dipilih mesti mempunyai teks jawapan.'));return false;}
        }

        /* -- Drag & Drop -- */
        if(qType==='Drag & Drop'){
            var blankRe=/\[Blank \d\]/g;
            var blankCount=((q['q'+qSuf]||'').match(blankRe)||[]).length;
            /* At least 1 blank required */
            if(blankCount<1){pqNavGoTo(i);pqInlineErr('pqDndBlankErr',_pqT('At least one blank is required.','Sekurang-kurangnya satu kosong diperlukan.'));return false;}
            /* Min 2 answer options */
            var fibKey=CL==='EN'?'fibEN':'fibBM';
            var fibArr=q[fibKey]||[];
            var wordCount=fibArr.filter(function(s){return s&&s.trim();}).length;
            if(wordCount<2){pqNavGoTo(i);pqInlineErr('pqDndWordsErr',_pqT('At least two answer options are required.','Sekurang-kurangnya dua pilihan jawapan diperlukan.'));return false;}
            /* Any answer option is empty (has slot but no text) */
            var hasEmpty=false;
            for(var fi=0;fi<fibArr.length;fi++){
                if(fi<wordCount+1&&fibArr[fi]!==undefined&&fibArr[fi]!==''&&!fibArr[fi].trim()){hasEmpty=true;break;}
            }
            /* Check for truly empty slots among the first N used slots */
            var usedSlots=fibArr.slice(0,4);
            var filledPositions=[];
            for(var fi=0;fi<usedSlots.length;fi++){
                if(usedSlots[fi]&&usedSlots[fi].trim())filledPositions.push(fi);
            }
            /* Check gaps: if a later slot has text but an earlier one doesn't */
            if(filledPositions.length>0){
                var maxFilledIdx=filledPositions[filledPositions.length-1];
                for(var fi=0;fi<=maxFilledIdx;fi++){
                    if(!usedSlots[fi]||!usedSlots[fi].trim()){hasEmpty=true;break;}
                }
            }
            if(hasEmpty){pqNavGoTo(i);pqInlineErr('pqDndWordsErr',_pqT('Answer options cannot be empty.','Pilihan jawapan tidak boleh kosong.'));return false;}
            /* Mapping: each blank must have a correct mapping */
            var mapKey=CL==='EN'?'fibMapEN':'fibMapBM';
            var mappings=q[mapKey]||[];
            var mappedCount=mappings.filter(function(s){return s&&s.trim();}).length;
            if(mappedCount===0){pqNavGoTo(i);pqInlineErr('pqDndMapErr',_pqT('Please select the correct mapping order.','Sila pilih susunan pemetaan yang betul.'));return false;}
            /* Each blank must have a mapping */
            var hasUnmapped=false;
            for(var mi=0;mi<blankCount;mi++){
                if(!mappings[mi]||!mappings[mi].trim()){hasUnmapped=true;break;}
            }
            if(hasUnmapped){pqNavGoTo(i);pqInlineErr('pqDndMapErr',_pqT('Each blank must have a correct answer mapping.','Setiap kosong mesti mempunyai pemetaan jawapan yang betul.'));return false;}
            /* Mapping count must match blank count */
            if(mappedCount!==blankCount){pqNavGoTo(i);pqInlineErr('pqDndMapErr',_pqT('The number of mappings must match the number of blanks.','Bilangan pemetaan mesti sama dengan bilangan kosong.'));return false;}
            /* Duplicate check: each blank maps to unique word */
            var mapFilled=mappings.slice(0,blankCount);
            var mapUnique=[];var mapHasDup=false;
            mapFilled.forEach(function(v){if(v&&mapUnique.indexOf(v)>-1)mapHasDup=true;else if(v)mapUnique.push(v);});
            if(mapHasDup){pqNavGoTo(i);pqInlineErr('pqDndMapErr',_pqT('Each blank must map to a unique word.','Setiap kosong mesti dipetakan kepada perkataan unik.'));return false;}
        }
    }
    /* All validation passed — flush to server */
    pqClearErr();
    document.getElementById('<%=hidQuizTitle.ClientID%>').value=document.getElementById('pqTitleInput').value.trim();
    document.getElementById('<%=hidQuestionsJson.ClientID%>').value=JSON.stringify(window.__PQ_QD);
    document.getElementById('<%=btnSubmitPQ.ClientID%>').click();
    return false;
}

/* -- Init -- */
(function(){
    /* Wire has-text class on MCQ inputs + auto-clear errors */
    document.querySelectorAll('#pqMcqOpts .pq-opt-text').forEach(function(inp){
        inp.addEventListener('input',function(){
            inp.closest('.qb-opt').classList.toggle('has-text',inp.value.trim().length>0);
            pqClearErr();
        });
    });
    /* Wire char count updates + auto-clear */
    document.getElementById('pqTxtCE').addEventListener('input',function(){pqUpdateCharCounts();pqClearErr();});
    document.getElementById('pqTxtWE').addEventListener('input',function(){pqUpdateCharCounts();pqClearErr();});
    /* Wire RTE input + auto-clear */
    var ed=document.getElementById('pqRteEditor');
    if(ed)ed.addEventListener('input',function(){pqRteSync();pqClearErr();});
    /* Wire multiselect inputs + checkboxes */
    document.querySelectorAll('#pqMsOpts .pq-ms-text').forEach(function(inp){
        inp.addEventListener('input',function(){pqClearErr();});
    });
    document.querySelectorAll('#pqMsOpts .pq-ms-check').forEach(function(cb){
        cb.addEventListener('change',function(){pqClearErr();});
    });
    /* Wire FIB word inputs */
    document.querySelectorAll('#pqFibWords .pq-fib-word').forEach(function(inp){
        inp.addEventListener('input',function(){pqClearErr();});
    });
    /* Initial state */
    pqRebuildNav();pqUpdateNavLabel();pqUpdateLabels();

    /* Check for successful submission (set by server after commit) */
    var successFlag=document.getElementById('<%=hidSubmitSuccess.ClientID%>');
    if(successFlag&&successFlag.value==='1'){
        successFlag.value='';
        var toastMsg=_pqT('Practice Quiz submitted successfully.','Kuiz Latihan berjaya dihantar.');
        var tc=document.getElementById('pqToast');
        if(tc){
            var t=document.createElement('div');
            t.className='pq-toast';
            t.innerHTML='<i class="bi bi-check-circle-fill"></i> '+toastMsg;
            tc.appendChild(t);
            setTimeout(function(){t.style.opacity='0';},2500);
            setTimeout(function(){window.location.href='<%=ResolveUrl("~/Teacher/manageQuiz.aspx")%>';},3000);
        }else{
            window.location.href='<%=ResolveUrl("~/Teacher/manageQuiz.aspx")%>';
        }
    }
})();

/* --- QUIZ TITLE ? VALIDATION & LANGUAGE SWITCH ----------- */

function pqValidateTitle(){
    var input=document.getElementById('pqTitleInput');
    var errDiv=document.getElementById('pqTitleErr');
    var errMsg=document.getElementById('pqTitleErrMsg');
    if(!input||!input.value.trim()){
        if(errMsg)errMsg.textContent=_pqT('Please enter the quiz title.','Sila masukkan tajuk kuiz.');
        if(errDiv)errDiv.style.display='inline-flex';
        if(input)input.focus();
        return false;
    }
    if(errDiv)errDiv.style.display='none';
    return true;
}

/* Clear error on input */
(function(){
    var input=document.getElementById('pqTitleInput');
    if(input)input.addEventListener('input',function(){
        var errDiv=document.getElementById('pqTitleErr');
        if(errDiv)errDiv.style.display='none';
    });
})();

/* Intercept language toggle for this page ? no reload */
(function(){
    function interceptLangBtns(){
        var btns=document.querySelectorAll('[id$="btnLangEN_Top"],[id$="btnLangBM_Top"],[id$="btnLangEN_Header"],[id$="btnLangBM_Header"]');
        btns.forEach(function(btn){
            btn.addEventListener('click',function(e){
                e.preventDefault();e.stopPropagation();e.stopImmediatePropagation();
                var newLang=btn.id.indexOf('LangEN')>-1?'EN':'BM';
                if(newLang===__PQ_SITE_LANG)return;
                pqSwitchSiteLang(newLang);
                return false;
            },true);
            btn.removeAttribute('href');
            btn.style.cursor='pointer';
        });
    }

    function pqSwitchSiteLang(lang){
        var xhr=new XMLHttpRequest();
        xhr.open('POST','<%= ResolveUrl("~/Teacher/createPracticeQuiz.aspx/SetLanguage") %>',true);
        xhr.setRequestHeader('Content-Type','application/json; charset=utf-8');
        xhr.send(JSON.stringify({lang:lang}));

        __PQ_SITE_LANG=lang;

        document.querySelectorAll('.sb-lang-btn').forEach(function(b){
            var isEN=b.id.indexOf('LangEN')>-1;
            b.className=(isEN&&lang==='EN')||(!isEN&&lang==='BM')?'sb-lang-btn active':'sb-lang-btn';
        });

        /* Update title field */
        var lbl=document.getElementById('pqTitleLabel');
        if(lbl)lbl.textContent=_pqT('Quiz Title','Tajuk Kuiz')+' *';
        var inp=document.getElementById('pqTitleInput');
        if(inp)inp.placeholder=_pqT('Enter quiz title...','Masukkan tajuk kuiz...');
        var errDiv=document.getElementById('pqTitleErr');
        if(errDiv)errDiv.style.display='none';

        /* Update question builder labels */
        pqUpdateLabels();
        pqUpdateNavLabel();
    }

    interceptLangBtns();
})();

function pqValidateTitle(){
    var input=document.getElementById('pqTitleInput');
    var errDiv=document.getElementById('pqTitleErr');
    var errMsg=document.getElementById('pqTitleErrMsg');
    if(!input||!input.value.trim()){
        if(errMsg)errMsg.textContent=_pqT('Please enter the quiz title.','Sila masukkan tajuk kuiz.');
        if(errDiv)errDiv.style.display='inline-flex';
        if(input)input.focus();
        return false;
    }
    if(errDiv)errDiv.style.display='none';
    return true;
}

/* Clear error on input */
(function(){
    var input=document.getElementById('pqTitleInput');
    if(input)input.addEventListener('input',function(){
        var errDiv=document.getElementById('pqTitleErr');
        if(errDiv)errDiv.style.display='none';
    });
})();
</script>
</asp:Content>
