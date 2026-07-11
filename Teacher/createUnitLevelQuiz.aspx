<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="createUnitLevelQuiz.aspx.cs"
    Inherits="ScienceBuddy.Teacher.createUnitLevelQuiz" MasterPageFile="~/Site.Master"
    Title="Create Quiz" EnableViewState="true" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ═══ DESIGN TOKENS — Purple/Blue Premium Theme ══════════ */
:root{
  --tc-primary:#6D5EF7;--tc-hover:#5B47F5;--tc-light-bg:#F6F4FF;
  --tc-card-bg:#FFF;--tc-border:#E4E0FC;--tc-text:#1E1B3A;
  --tc-muted:#7B7499;--tc-error:#E53E5E;--tc-success:#22C27A;
  --tc-accent:#4F8CFF;--tc-purple-soft:#EEF2FF;
}
/* ═══ LAYOUT ══════════════════════════════════════════════ */
.qb-layout{display:grid;grid-template-columns:220px 1fr 260px;gap:1.5rem;min-height:75vh;align-items:start;}


/* ═══ PROGRESS BAR ════════════════════════════════════════ */
.qb-progress{background:#fff;border:1.5px solid var(--tc-border);border-radius:18px;padding:1.1rem 1.6rem;margin-bottom:1.5rem;box-shadow:0 2px 12px rgba(109,94,247,.06);display:flex;align-items:center;gap:1.25rem;}
.qb-progress-icon{width:36px;height:36px;border-radius:10px;background:linear-gradient(135deg,#B8B0FA,#9B8FF5);display:flex;align-items:center;justify-content:center;font-size:1rem;color:#fff;flex-shrink:0;}
.qb-progress-bar{flex:1;height:10px;background:#ECEAFC;border-radius:20px;overflow:hidden;}
.qb-progress-fill{height:100%;background:linear-gradient(90deg,#6D5EF7,#4F8CFF);border-radius:20px;transition:width .5s cubic-bezier(.4,0,.2,1);}
.qb-progress-text{font-size:.82rem;font-weight:700;color:var(--tc-text);white-space:nowrap;letter-spacing:.01em;}
/* ═══ LEFT NAV — Question Navigator ══════════════════════ */
.qb-nav{
  background:#fff;border:1.5px solid var(--tc-border);border-radius:20px;
  padding:0;box-shadow:0 4px 20px rgba(109,94,247,.08);overflow:hidden;
}
.qb-nav-header{
  padding:1rem 1.2rem .85rem;border-bottom:1.5px solid #EDEAFC;
  background:linear-gradient(135deg,#F6F4FF,#EEF2FF);
}
.qb-nav-title{
  font-size:.68rem;font-weight:800;color:var(--tc-muted);
  text-transform:uppercase;letter-spacing:1.5px;
  display:flex;align-items:center;justify-content:space-between;
}
.qb-nav-count{
  font-size:.68rem;font-weight:700;color:var(--tc-primary);
  background:#EEF2FF;border:1px solid #C8C2F8;
  padding:2px 8px;border-radius:10px;
}
.qb-nav-list{display:flex;flex-direction:column;gap:4px;padding:.75rem .75rem 0;}
.qb-nav-row{
  position:relative;display:flex;align-items:stretch;
  border-radius:13px;overflow:hidden;
}
.qb-nav-item{
  flex:1;padding:.7rem .9rem;
  font-size:.83rem;font-weight:600;color:var(--tc-text);
  cursor:pointer;display:flex;align-items:center;gap:9px;
  transition:all .2s;border:1.5px solid transparent;
  background:transparent;text-align:left;border-radius:13px;
  text-decoration:none;
}
.qb-nav-item:hover{background:#F0EEFF;border-color:#C8C2F8;}
.qb-nav-item.active{
  background:linear-gradient(135deg,#6D5EF7,#5B47F5);color:#fff;
  border-color:#6D5EF7;
  box-shadow:0 4px 16px rgba(109,94,247,.35);
}
.qb-nav-badge{
  width:24px;height:24px;border-radius:8px;
  background:rgba(109,94,247,.1);color:var(--tc-primary);
  display:flex;align-items:center;justify-content:center;
  font-size:.7rem;font-weight:800;flex-shrink:0;
  transition:all .2s;
}
.qb-nav-item.active .qb-nav-badge{background:rgba(255,255,255,.22);color:#fff;}
.qb-nav-item.done .qb-nav-badge{background:#D0F5E8;color:#0E7A4A;}
.qb-nav-check{
  margin-left:auto;font-size:.78rem;color:var(--tc-success);
  opacity:0;transition:opacity .2s;flex-shrink:0;
}
.qb-nav-item.done .qb-nav-check{opacity:1;}
.qb-nav-item.active .qb-nav-check{color:rgba(255,255,255,.8);}
.qb-nav-del{
  position:absolute;right:5px;top:50%;transform:translateY(-50%);
  width:24px;height:24px;border-radius:7px;border:none;
  background:transparent;color:var(--tc-error);
  display:flex;align-items:center;justify-content:center;
  font-size:.75rem;cursor:pointer;
  opacity:0;transition:opacity .18s,background .18s;
  z-index:2;padding:0;
}
.qb-nav-row:hover .qb-nav-del{opacity:.5;}
.qb-nav-del:hover{opacity:1!important;background:#FEF2F5;}
.qb-nav-row:has(.qb-nav-item.active) .qb-nav-del{color:rgba(255,255,255,.7);}
.qb-nav-row:has(.qb-nav-item.active) .qb-nav-del:hover{background:rgba(255,255,255,.15);}
.qb-nav-del.disabled{display:none;}

.qb-nav-footer{padding:.75rem;}
.qb-nav-add{
  width:100%;padding:.8rem;border-radius:13px;
  font-size:.82rem;font-weight:700;color:#fff;
  cursor:pointer;border:none;
  background:linear-gradient(135deg,#6D5EF7,#4F8CFF);
  display:flex;align-items:center;justify-content:center;gap:7px;
  transition:all .22s;
  box-shadow:0 3px 12px rgba(109,94,247,.28);
}
.qb-nav-add:hover{
  background:linear-gradient(135deg,#5B47F5,#3A7AFF);
  box-shadow:0 6px 20px rgba(109,94,247,.40);
  transform:translateY(-2px);
}

/* Delete confirmation modal */
.qb-del-overlay{
  position:fixed;inset:0;background:rgba(30,27,58,.50);z-index:9998;
  display:flex;align-items:center;justify-content:center;
  opacity:0;pointer-events:none;transition:opacity .22s;
}
.qb-del-overlay.open{opacity:1;pointer-events:all;}
.qb-del-modal{
  background:#fff;border-radius:20px;padding:2rem;
  width:340px;max-width:90vw;
  box-shadow:0 20px 60px rgba(109,94,247,.18);
  transform:translateY(10px) scale(.97);transition:transform .22s;
}
.qb-del-overlay.open .qb-del-modal{transform:translateY(0) scale(1);}
.qb-del-modal-icon{
  width:52px;height:52px;border-radius:14px;
  background:#FEF2F5;border:1.5px solid #F5C0CC;
  display:flex;align-items:center;justify-content:center;
  font-size:1.35rem;color:var(--tc-error);margin-bottom:1rem;
}
.qb-del-modal h3{font-size:1rem;font-weight:800;color:var(--tc-text);margin:0 0 6px;}
.qb-del-modal p{font-size:.84rem;color:var(--tc-muted);margin:0 0 1.5rem;line-height:1.6;}
.qb-del-modal-actions{display:flex;gap:.7rem;}
.qb-del-btn-cancel{
  flex:1;padding:.65rem;border-radius:11px;border:1.5px solid var(--tc-border);
  background:#fff;font-size:.84rem;font-weight:700;color:var(--tc-text);
  cursor:pointer;transition:all .18s;
}
.qb-del-btn-cancel:hover{border-color:var(--tc-primary);color:var(--tc-primary);}
.qb-del-btn-confirm{
  flex:1;padding:.65rem;border-radius:11px;border:none;
  background:var(--tc-error);color:#fff;
  font-size:.84rem;font-weight:700;cursor:pointer;transition:all .18s;
  box-shadow:0 3px 10px rgba(229,62,94,.22);
}
.qb-del-btn-confirm:hover{background:#C02050;box-shadow:0 5px 16px rgba(229,62,94,.32);}

/* ── Submit success modal ────────────────────────────── */
.qb-success-overlay{
  position:fixed;inset:0;background:rgba(30,27,58,.55);z-index:9998;
  display:flex;align-items:center;justify-content:center;
  opacity:0;pointer-events:none;transition:opacity .25s;
}
.qb-success-overlay.open{opacity:1;pointer-events:all;}
.qb-success-modal{
  background:#fff;border-radius:22px;padding:2.5rem 2rem 2rem;
  width:380px;max-width:92vw;text-align:center;
  box-shadow:0 24px 64px rgba(109,94,247,.22);
  transform:translateY(14px) scale(.96);transition:transform .25s;
}
.qb-success-overlay.open .qb-success-modal{transform:translateY(0) scale(1);}
.qb-success-icon{
  width:64px;height:64px;border-radius:50%;
  background:linear-gradient(135deg,#22C27A,#14A860);
  display:flex;align-items:center;justify-content:center;
  font-size:1.8rem;color:#fff;margin:0 auto 1.1rem;
  box-shadow:0 6px 20px rgba(34,194,122,.30);
}
.qb-success-modal h3{font-size:1.1rem;font-weight:800;color:var(--tc-text);margin:0 0 .6rem;}
.qb-success-modal p{font-size:.88rem;color:var(--tc-muted);margin:0;line-height:1.65;}

/* ═══ CENTER EDITOR CARD ══════════════════════════════════ */
.qb-center{background:#fff;border:1.5px solid var(--tc-border);border-radius:22px;padding:0;box-shadow:0 6px 32px rgba(109,94,247,.09);display:flex;flex-direction:column;min-height:580px;overflow:hidden;}

.qb-header{display:flex;align-items:center;justify-content:space-between;padding:1.25rem 2rem;background:linear-gradient(135deg,#F6F4FF,#EEF2FF);border-bottom:2px solid #EDEAFC;}
.qb-qnum{font-size:.72rem;font-weight:800;color:var(--tc-muted);text-transform:uppercase;letter-spacing:1.4px;display:flex;align-items:center;gap:8px;}
.qb-qnum::before{content:'';display:inline-block;width:8px;height:8px;border-radius:50%;background:var(--tc-primary);box-shadow:0 0 0 3px rgba(109,94,247,.20);}

.qb-tabs{display:flex;gap:0;background:#E8E4FC;border-radius:14px;padding:4px;border:none;box-shadow:inset 0 1px 3px rgba(109,94,247,.10);}
.qb-tab{padding:.5rem 1.35rem;font-size:.82rem;font-weight:700;cursor:pointer;border:none;background:transparent;color:var(--tc-muted);border-radius:10px;transition:all .22s cubic-bezier(.4,0,.2,1);letter-spacing:.01em;display:flex;align-items:center;gap:6px;}
.qb-tab::before{content:'';display:inline-block;width:7px;height:7px;border-radius:50%;background:currentColor;opacity:.30;transition:opacity .22s;}
.qb-tab.active{background:#fff;color:var(--tc-primary);box-shadow:0 2px 10px rgba(109,94,247,.18),0 1px 2px rgba(0,0,0,.06);}
.qb-tab.active::before{opacity:.9;}
.qb-tab:hover:not(.active){background:rgba(255,255,255,.55);color:var(--tc-text);}

.qb-editor-body{padding:1.75rem 2rem;flex:1;display:flex;flex-direction:column;}

.qb-question-hero{background:linear-gradient(145deg,#F8F6FF,#F0EEFF);border:2px solid #D8D2F8;border-radius:18px;padding:0;margin-bottom:1.4rem;overflow:hidden;transition:border-color .2s,box-shadow .2s;}
.qb-question-hero:focus-within{border-color:var(--tc-primary);box-shadow:0 0 0 4px rgba(109,94,247,.10);}
.qb-question-hero-header{display:flex;align-items:center;justify-content:space-between;padding:.7rem 1.1rem .55rem;border-bottom:1.5px solid #D8D2F8;}
.qb-question-hero-label{display:flex;align-items:center;gap:7px;font-size:.73rem;font-weight:800;color:#4A3AAA;text-transform:uppercase;letter-spacing:.8px;}
.qb-question-hero-label i{font-size:.85rem;color:var(--tc-primary);}
.qb-question-hero textarea.qb-input{border:none;border-radius:0;background:transparent;padding:1rem 1.1rem;font-size:.96rem;font-weight:500;line-height:1.7;min-height:110px;resize:vertical;box-shadow:none;}
.qb-question-hero textarea.qb-input:focus{border:none;box-shadow:none;outline:none;}

/* ── Question Image Upload ─────────────────────────────── */
.qb-img-zone{border:2px dashed #C8C2F8;border-radius:14px;background:#F8F6FF;margin-bottom:1.4rem;transition:border-color .2s,background .2s;overflow:hidden;}
.qb-img-upload{display:flex;flex-direction:column;align-items:center;justify-content:center;gap:8px;padding:1.4rem 1rem;cursor:pointer;}
.qb-img-upload:hover,.qb-img-zone:hover{border-color:var(--tc-primary);}
.qb-img-upload:hover{background:#F0EEFF;}
.qb-img-upload-icon{width:40px;height:40px;border-radius:11px;background:linear-gradient(135deg,#C8C2F8,#A8A0F5);display:flex;align-items:center;justify-content:center;font-size:1.1rem;color:#fff;}
.qb-img-upload-text{font-size:.8rem;font-weight:700;color:var(--tc-primary);}
.qb-img-upload-sub{font-size:.7rem;color:var(--tc-muted);}
.qb-img-upload input[type="file"]{display:none;}
.qb-img-preview{position:relative;display:none;}
.qb-img-preview img{width:100%;max-height:200px;object-fit:cover;display:block;}
.qb-img-remove{position:absolute;top:8px;right:8px;width:26px;height:26px;border-radius:50%;border:none;background:rgba(0,0,0,.55);color:#fff;display:flex;align-items:center;justify-content:center;font-size:.75rem;cursor:pointer;transition:background .18s;}
.qb-img-remove:hover{background:rgba(229,62,94,.85);}

/* ── Section divider header ────────────────────────────── */
.qb-section-header{display:flex;align-items:center;gap:10px;margin-bottom:1rem;margin-top:.25rem;}
.qb-section-header-icon{width:28px;height:28px;border-radius:8px;background:#F0EEFF;border:1.5px solid #C8C2F8;display:flex;align-items:center;justify-content:center;font-size:.85rem;color:var(--tc-primary);flex-shrink:0;}
.qb-section-header-text{font-size:.8rem;font-weight:800;color:var(--tc-text);letter-spacing:.3px;}
.qb-section-header-sub{font-size:.71rem;color:var(--tc-muted);font-weight:500;margin-left:auto;}
.qb-section-divider{flex:1;height:1.5px;background:linear-gradient(90deg,#D8D2F8,transparent);margin-left:6px;}

/* ═══ FIELDS ══════════════════════════════════════════════ */
.qb-field{margin-bottom:1.4rem;position:relative;}
.qb-label{font-size:.75rem;font-weight:700;color:var(--tc-text);margin-bottom:6px;display:flex;align-items:center;justify-content:space-between;letter-spacing:.02em;text-transform:uppercase;}
.qb-input{width:100%;border-radius:14px;border:1.5px solid var(--tc-border);padding:.75rem 1rem;font-size:.88rem;transition:all .2s;background:#fff;color:var(--tc-text);}
.qb-input:focus{border-color:var(--tc-primary);outline:none;box-shadow:0 0 0 3px rgba(109,94,247,.10);}
.qb-input.invalid{border-color:var(--tc-error);box-shadow:0 0 0 3px rgba(229,62,94,.08);}
.qb-textarea{min-height:90px;resize:vertical;line-height:1.65;}
.qb-char-count{font-size:.68rem;color:var(--tc-muted);font-weight:600;background:#F0EEFF;padding:2px 8px;border-radius:6px;text-transform:none;letter-spacing:0;}

/* ═══ MCQ OPTIONS — Premium cards ════════════════════════ */
.qb-opts{display:grid;grid-template-columns:1fr 1fr;gap:.85rem;margin-bottom:1.4rem;}
.qb-opt{display:flex;align-items:stretch;gap:0;border-radius:16px;border:2px solid var(--tc-border);transition:all .25s cubic-bezier(.4,0,.2,1);position:relative;background:#fff;overflow:hidden;cursor:text;min-height:64px;}
.qb-opt-band{width:52px;flex-shrink:0;display:flex;align-items:center;justify-content:center;font-size:1.05rem;font-weight:900;color:#fff;letter-spacing:.02em;transition:filter .2s;user-select:none;}
.qb-opt:nth-child(1) .qb-opt-band{background:#E53E5E;}
.qb-opt:nth-child(2) .qb-opt-band{background:#F6A623;}
.qb-opt:nth-child(3) .qb-opt-band{background:#6D5EF7;}
.qb-opt:nth-child(4) .qb-opt-band{background:#4F8CFF;}
.qb-opt:nth-child(1){border-color:#F8D0D8;background:#FFF8FA;}
.qb-opt:nth-child(2){border-color:#FAE0B0;background:#FFFBF2;}
.qb-opt:nth-child(3){border-color:#C8C2F8;background:#F8F6FF;}
.qb-opt:nth-child(4){border-color:#B8D4FA;background:#F6FAFF;}
.qb-opt-body{flex:1;display:flex;align-items:center;padding:.75rem 1rem;}
.qb-opt input[type="radio"],.qb-opt input[type="checkbox"]{display:none;}
.qb-opt-input{flex:1;border:none;background:transparent;font-size:.88rem;outline:none;font-weight:500;color:var(--tc-text);padding:0;line-height:1.5;cursor:text;}
.qb-opt-input::placeholder{color:#B8B4CC;font-weight:400;}
.qb-opt:hover{transform:translateY(-3px);box-shadow:0 8px 22px rgba(109,94,247,.12);}
.qb-opt:nth-child(1):hover{border-color:#E53E5E;}
.qb-opt:nth-child(2):hover{border-color:#F6A623;}
.qb-opt:nth-child(3):hover{border-color:#6D5EF7;}
.qb-opt:nth-child(4):hover{border-color:#4F8CFF;}
.qb-opt.correct{border-color:var(--tc-success)!important;background:#EDFBF4!important;box-shadow:0 6px 20px rgba(34,194,122,.18);}
.qb-opt.correct .qb-opt-band{filter:brightness(1.1);}
.qb-opt.correct::after{content:'\2713';position:absolute;right:10px;top:50%;transform:translateY(-50%);font-size:.75rem;font-weight:900;color:#fff;background:var(--tc-success);width:22px;height:22px;border-radius:50%;display:flex;align-items:center;justify-content:center;box-shadow:0 2px 6px rgba(34,194,122,.35);}

/* ═══ EXPLANATION CONTAINERS ══════════════════════════════ */
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
.qb-exp-correct textarea.qb-input{background:transparent;border:none;border-radius:0;padding:.85rem 1.1rem;box-shadow:none;min-height:80px;font-size:.88rem;line-height:1.65;}
.qb-exp-correct textarea.qb-input:focus{border:none;box-shadow:none;outline:none;}
.qb-exp-wrong{background:#FEF4F7;border:1.5px solid #F0AABB;}
.qb-exp-wrong .qb-exp-block-header{background:#FDEAEF;border-bottom:1.5px solid #F0AABB;}
.qb-exp-wrong .qb-exp-block-icon{background:#FAC8D4;color:#8A0A2A;}
.qb-exp-wrong .qb-exp-block-label{color:#7A0A22;}
.qb-exp-wrong .qb-exp-block-count{background:#FAC8D4;color:#7A0A22;}
.qb-exp-wrong textarea.qb-input{background:transparent;border:none;border-radius:0;padding:.85rem 1.1rem;box-shadow:none;min-height:80px;font-size:.88rem;line-height:1.65;}
.qb-exp-wrong textarea.qb-input:focus{border:none;box-shadow:none;outline:none;}
/* ═══ ACTIONS BAR ═════════════════════════════════════════ */
.qb-actions{display:flex;gap:.85rem;margin-top:auto;padding:1.25rem 2rem 1.5rem;border-top:1.5px solid #EDEAFC;flex-wrap:wrap;align-items:center;background:linear-gradient(135deg,#FAFAFF,#F6F4FF);}
.qb-btn{padding:.65rem 1.35rem;border-radius:14px;font-size:.84rem;font-weight:700;cursor:pointer;border:none;transition:all .22s;display:inline-flex;align-items:center;gap:7px;letter-spacing:.01em;}
.qb-btn:hover{transform:translateY(-2px);}
.qb-btn-primary{background:linear-gradient(135deg,#6D5EF7,#5B47F5);color:#fff;box-shadow:0 3px 12px rgba(109,94,247,.28);}
.qb-btn-primary:hover{background:linear-gradient(135deg,#5B47F5,#4A38E0);box-shadow:0 6px 20px rgba(109,94,247,.40);}
.qb-btn-outline{background:#fff;color:var(--tc-text);border:1.5px solid var(--tc-border);}
.qb-btn-outline:hover{border-color:var(--tc-primary);color:var(--tc-primary);}
.qb-btn-success{background:linear-gradient(135deg,#22C27A,#14A860);color:#fff;box-shadow:0 3px 12px rgba(34,194,122,.22);}
.qb-btn-success:hover{background:linear-gradient(135deg,#14A860,#0A8A50);box-shadow:0 6px 20px rgba(34,194,122,.32);}

/* ═══ RIGHT PROPS PANEL — Settings Card ══════════════════ */
.qb-props{background:#fff;border:1.5px solid var(--tc-border);border-radius:20px;padding:0;box-shadow:0 4px 20px rgba(109,94,247,.08);overflow:hidden;}
.qb-props-header{padding:1rem 1.2rem .85rem;border-bottom:1.5px solid #EDEAFC;background:linear-gradient(135deg,#F6F4FF,#EEF2FF);display:flex;align-items:center;gap:9px;}
.qb-props-header-icon{width:26px;height:26px;border-radius:7px;background:linear-gradient(135deg,#C8C2F8,#A8A0F5);display:flex;align-items:center;justify-content:center;font-size:.8rem;color:#fff;flex-shrink:0;}
.qb-props-title{font-size:.68rem;font-weight:800;color:var(--tc-muted);text-transform:uppercase;letter-spacing:1.5px;}
.qb-props-body{padding:1rem 1.1rem 1.1rem;}
.qb-prop-field{margin-bottom:1.1rem;}
.qb-prop-field:last-child{margin-bottom:0;}
.qb-prop-label{display:flex;align-items:center;gap:7px;font-size:.72rem;font-weight:700;color:var(--tc-text);margin-bottom:6px;text-transform:uppercase;letter-spacing:.5px;}
.qb-prop-label-icon{width:20px;height:20px;border-radius:5px;display:flex;align-items:center;justify-content:center;font-size:.72rem;flex-shrink:0;}
.qb-prop-label-icon.type{background:#EEF2FF;color:var(--tc-primary);}
.qb-prop-label-icon.diff{background:#FEF0D8;color:#8A5000;}
.qb-prop-label-icon.sub{background:#EEF2FF;color:var(--tc-accent);}
.qb-prop-subtopic-val{font-size:.82rem;font-weight:600;color:var(--tc-text);padding:.55rem .85rem;background:#F6F4FF;border-radius:10px;border:1.5px solid #D8D2F8;line-height:1.45;}
.qb-prop-diff-wrap{position:relative;}
.qb-prop-diff-wrap select.qb-input{padding-right:2.5rem;}
/* ═══ SAVE STATUS ═════════════════════════════════════════ */
.qb-save-status{display:flex;align-items:center;gap:9px;padding:.7rem 1.1rem;border-radius:12px;font-size:.79rem;font-weight:700;margin-bottom:1.1rem;background:#FEF8E6;color:#8A5E00;border:1.5px solid #F0D88A;transition:all .3s;}
.qb-save-status.ready{background:#EDFBF4;color:#0E6840;border-color:#90DFB8;}
/* ═══ ANSWER SECTION TRANSITIONS ═════════════════════════ */
.qb-answer-section{animation:qbFadeIn .25s ease;}
@keyframes qbFadeIn{from{opacity:0;transform:translateY(8px);}to{opacity:1;transform:translateY(0);}}
/* ═══ TRUE / FALSE ════════════════════════════════════════ */
.qb-tf-grid{display:grid;grid-template-columns:1fr 1fr;gap:1.1rem;margin-bottom:1.4rem;}
.qb-tf-card{display:flex;flex-direction:column;align-items:center;gap:10px;padding:2rem 1rem;border-radius:18px;border:2px solid var(--tc-border);cursor:pointer;transition:all .25s;text-align:center;background:#fff;}
.qb-tf-card:hover{transform:translateY(-3px);box-shadow:0 8px 24px rgba(109,94,247,.10);}
.qb-tf-card input[type="radio"]{display:none;}
.qb-tf-card i{font-size:2.1rem;color:var(--tc-muted);transition:color .2s;}
.qb-tf-card span{font-size:1rem;font-weight:800;color:var(--tc-text);}
.qb-tf-card.selected{border-color:var(--tc-primary);background:#F0EEFF;box-shadow:0 8px 24px rgba(109,94,247,.18);}
.qb-tf-card.selected i{color:var(--tc-primary);}
/* ═══ MULTISELECT ═════════════════════════════════════════ */
.qb-ms-opt.selected{border-color:var(--tc-success)!important;background:#EDFBF4;box-shadow:0 4px 14px rgba(34,194,122,.10);}
.qb-ms-count{font-size:.72rem;font-weight:700;color:var(--tc-primary);background:#F0EEFF;padding:3px 9px;border-radius:7px;margin-left:8px;}

/* ═══ FILL IN THE BLANK ═══════════════════════════════════ */
.fib-add-row{display:flex;align-items:center;gap:12px;margin-bottom:.85rem;}
.fib-add-btn{display:inline-flex;align-items:center;gap:6px;padding:.55rem 1.1rem;border-radius:11px;font-size:.81rem;font-weight:700;color:var(--tc-primary);background:#F0EEFF;border:1.5px solid #C8C2F8;cursor:pointer;transition:all .2s;}
.fib-add-btn:hover{background:#E8E4FC;border-color:var(--tc-primary);transform:translateY(-1px);box-shadow:0 3px 10px rgba(109,94,247,.12);}
.fib-add-btn.disabled{color:var(--tc-muted);background:#F5F5F5;border-color:var(--tc-border);cursor:not-allowed;opacity:.55;transform:none;box-shadow:none;}
.fib-counter{font-size:.79rem;font-weight:600;color:var(--tc-muted);}.fib-counter.full{color:var(--tc-error);}
.fib-warning{display:flex;align-items:center;gap:8px;padding:.65rem 1rem;border-radius:11px;background:#FEF4F7;border:1px solid #F0AABB;color:#8A0A2A;font-size:.77rem;font-weight:700;margin-bottom:1rem;animation:qbFadeIn .2s ease;}
.fib-section-label{font-size:.81rem;font-weight:700;color:var(--tc-text);margin-bottom:9px;display:flex;align-items:center;gap:6px;}
.fib-section-label i{color:var(--tc-primary);}.fib-sub-label{font-size:.71rem;color:var(--tc-muted);font-weight:500;}
.fib-mapping-wrap{margin-top:1.3rem;padding-top:1.3rem;border-top:1.5px dashed #D8D2F8;}
.fib-preview-wrap{margin-top:1.3rem;}
.qb-fib-words{display:grid;grid-template-columns:1fr 1fr;gap:.85rem;margin-bottom:1.1rem;}
.qb-fib-word{display:flex;align-items:center;gap:10px;padding:.65rem 1rem;border-radius:13px;border:1.5px solid var(--tc-border);background:#fff;transition:all .2s;}
.qb-fib-word:focus-within{border-color:var(--tc-primary);box-shadow:0 0 0 3px rgba(109,94,247,.08);}
.qb-fib-num{width:26px;height:26px;border-radius:50%;background:#F0EEFF;color:var(--tc-primary);display:flex;align-items:center;justify-content:center;font-size:.73rem;font-weight:800;flex-shrink:0;}
.qb-fib-mappings{display:flex;flex-direction:column;gap:8px;}
.qb-fib-map-row{display:flex;align-items:center;gap:10px;padding:.65rem 1rem;border-radius:13px;border:1.5px solid var(--tc-border);background:#fff;transition:all .25s;}
.qb-fib-map-row.valid{border-color:var(--tc-success);background:#EDFBF4;}
.qb-fib-map-row.invalid{border-color:var(--tc-error);background:#FEF4F7;}
.qb-fib-map-label{font-size:.79rem;font-weight:700;color:var(--tc-primary);white-space:nowrap;min-width:65px;}
.qb-fib-map-arrow{color:var(--tc-muted);font-size:.86rem;}
.qb-fib-map-select{flex:1;border-radius:9px;border:1.5px solid var(--tc-border);padding:.45rem .7rem;font-size:.81rem;background:#fff;transition:border-color .2s;}
.qb-fib-map-select:focus{border-color:var(--tc-primary);outline:none;}
.qb-fib-map-select.invalid{border-color:var(--tc-error);}
.qb-fib-map-check{color:var(--tc-success);font-size:.9rem;opacity:0;transition:opacity .2s;}
.qb-fib-map-row.valid .qb-fib-map-check{opacity:1;}
.qb-fib-preview-card{background:linear-gradient(135deg,#F6F4FF 0%,#EEF2FF 100%);border:1.5px solid #C8C2F8;border-radius:16px;padding:1.3rem 1.6rem;}
.qb-fib-preview-title{font-size:.83rem;font-weight:700;color:var(--tc-primary);margin-bottom:4px;display:flex;align-items:center;gap:6px;}
.qb-fib-preview-sub{font-size:.73rem;color:var(--tc-muted);margin-bottom:.9rem;}
.qb-fib-preview-text{font-size:.91rem;color:var(--tc-text);line-height:1.85;}
.qb-fib-preview-text .fib-blank{display:inline-block;min-width:90px;border-bottom:2.5px dashed var(--tc-primary);text-align:center;padding:3px 10px;margin:0 4px;color:var(--tc-primary);font-size:.83rem;font-weight:600;background:rgba(109,94,247,.05);border-radius:4px;}
.qb-fib-preview-words{display:flex;flex-wrap:wrap;gap:8px;}
.qb-fib-chip{display:inline-flex;align-items:center;padding:6px 16px;border-radius:20px;background:#fff;border:1.5px solid #C8C2F8;font-size:.81rem;font-weight:600;color:var(--tc-primary);box-shadow:0 2px 6px rgba(109,94,247,.10);transition:transform .15s;}
.qb-fib-chip:hover{transform:translateY(-1px);box-shadow:0 4px 10px rgba(109,94,247,.14);}
.qb-fib-hint{font-size:.77rem;color:var(--tc-muted);display:flex;align-items:flex-start;gap:6px;padding:.7rem .9rem;background:#F6F4FF;border-radius:11px;margin-top:1.3rem;line-height:1.55;}

/* ═══ MISC ════════════════════════════════════════════════ */
.qb-msg{padding:.8rem 1.1rem;border-radius:12px;margin-bottom:1rem;font-size:.85rem;font-weight:600;}
.qb-msg-error{background:#FEF2F2;color:#B01C1C;border:1px solid #F8C8C8;}
.qb-msg-success{background:#EDFBF4;color:#0E6840;border:1px solid #90DFB8;}
.qb-toast-container{position:fixed;top:1.25rem;right:1.25rem;z-index:9999;display:flex;flex-direction:column;gap:.5rem;}
.qb-toast{background:linear-gradient(135deg,#6D5EF7,#4F8CFF);color:#fff;padding:.8rem 1.3rem;border-radius:12px;font-size:.85rem;font-weight:700;display:flex;align-items:center;gap:9px;box-shadow:0 8px 28px rgba(109,94,247,.30);animation:qbSlide .3s ease;}
@keyframes qbSlide{from{opacity:0;transform:translateX(30px);}to{opacity:1;transform:translateX(0);}}
/* ═══ INLINE FIELD VALIDATION ═════════════════════════════ */
/* Red border only — no background tint on the invalid control */
.qb-err{border-color:#DC3545!important;box-shadow:0 0 0 2px rgba(220,53,69,.15)!important;}
/* Error message — sits OUTSIDE the field/card, below it, with breathing room before next section */
.qb-err-msg{
  display:flex;align-items:center;gap:6px;
  font-size:13px;font-weight:500;color:#DC3545;
  margin-top:7px;       /* 6–8px gap from the field/card above  */
  margin-bottom:18px;   /* 16–20px gap before the next section  */
  padding:0;line-height:1.4;
  animation:qbFadeIn .15s ease;
}
/* ═══ RESPONSIVE ══════════════════════════════════════════ */
@media(max-width:1100px){.qb-layout{grid-template-columns:1fr;}.qb-nav,.qb-props{display:none;}}
@media(max-width:640px){.qb-opts{grid-template-columns:1fr;}.qb-tf-grid{grid-template-columns:1fr;}.qb-fib-words{grid-template-columns:1fr;}.qb-actions{flex-direction:column;padding:1rem 1.25rem 1.25rem;}.qb-editor-body{padding:1.25rem;}.qb-header{padding:1rem 1.25rem;}}

/* ═══════════════════════════════════════════════════════════
   HERO — Warm educational premium, ScienceBuddy palette
   ═══════════════════════════════════════════════════════════ */
.cq-hero{position:relative;background:#FCFBF7;border-radius:24px;padding:2.75rem 2.8rem 2.2rem;margin-bottom:1.5rem;overflow:hidden;border:1.5px solid #DDD5C0;box-shadow:0 8px 40px rgba(95,143,99,.10),0 2px 0 rgba(255,255,255,.95) inset;}
.cq-hero-bg{position:absolute;inset:0;pointer-events:none;overflow:hidden;}
.cq-hero-bg svg{position:absolute;top:0;right:0;width:68%;height:100%;opacity:.10;}
.cq-hero::before{content:'';position:absolute;top:-70px;right:-70px;width:300px;height:300px;border-radius:50%;background:radial-gradient(circle,#5F8F63 0%,transparent 68%);opacity:.16;pointer-events:none;}
.cq-hero::after{content:'';position:absolute;bottom:-55px;left:25%;width:240px;height:240px;border-radius:50%;background:radial-gradient(circle,#D8A53A 0%,transparent 68%);opacity:.14;pointer-events:none;}
.cq-hero-bg::before{content:'';position:absolute;top:30%;left:-55px;width:200px;height:200px;border-radius:50%;background:radial-gradient(circle,#D97B6C 0%,transparent 68%);opacity:.13;pointer-events:none;}
.cq-hero-bg::after{content:'';position:absolute;inset:0;background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='200' height='200'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.75' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='200' height='200' filter='url(%23n)' opacity='1'/%3E%3C/svg%3E");background-size:180px 180px;opacity:.022;mix-blend-mode:multiply;pointer-events:none;}
.cq-hero-left::after{content:'';position:absolute;inset:0;border-radius:22px;background:radial-gradient(ellipse at 50% 50%,transparent 55%,rgba(252,251,247,.55) 100%);pointer-events:none;z-index:0;}
.cq-hero-left{position:relative;z-index:2;display:flex;flex-direction:column;gap:1.4rem;}
.cq-hero-top{display:flex;align-items:flex-start;gap:18px;}
.cq-hero-icon{width:62px;height:62px;border-radius:18px;background:linear-gradient(145deg,#D8A53A,#B07820);display:flex;align-items:center;justify-content:center;font-size:1.65rem;flex-shrink:0;box-shadow:0 6px 22px rgba(184,120,32,.35),0 1px 0 rgba(255,255,255,.22) inset;}
.cq-hero-icon i{color:#fff;}
.cq-hero-title{font-size:2rem;font-weight:900;color:#1E2818;margin:0;letter-spacing:-.5px;line-height:1.15;}
.cq-hero-desc{font-size:.93rem;color:#7A7060;margin:5px 0 0;font-weight:500;}
.cq-hero-meta{display:inline-flex;align-items:stretch;gap:0;background:rgba(255,252,244,.90);border-radius:16px;border:1.5px solid #CECCA0;overflow:hidden;width:fit-content;backdrop-filter:blur(8px);box-shadow:0 3px 14px rgba(95,143,99,.10);}
.cq-meta-item{display:flex;align-items:center;gap:12px;padding:.85rem 1.4rem;}
.cq-meta-item:not(:last-child){border-right:1.5px solid #D8D0B8;}
.cq-meta-pill{width:38px;height:38px;border-radius:11px;display:flex;align-items:center;justify-content:center;font-size:1.05rem;flex-shrink:0;}
.cq-meta-pill-unit{background:linear-gradient(135deg,#C4DAB0,#9EC480);color:#2E5A30;box-shadow:0 2px 8px rgba(72,111,75,.22);}
.cq-meta-pill-level{background:linear-gradient(135deg,#C4DAB0,#9EC480);color:#2E5A30;box-shadow:0 2px 8px rgba(72,111,75,.22);}
.cq-meta-pill-subtopic{background:linear-gradient(135deg,#F4C4B4,#E8A090);color:#8A2810;box-shadow:0 2px 8px rgba(217,123,108,.22);}
.cq-meta-label{font-size:.67rem;font-weight:700;color:#8A7A60;text-transform:uppercase;letter-spacing:.6px;display:block;line-height:1;margin-bottom:3px;}
.cq-meta-val{font-size:.95rem;font-weight:800;color:#1E2818;display:block;line-height:1.15;max-width:220px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}

/* ── Quiz Titles Panel ─────────────────────────────────── */
.cq-titles-panel{display:grid;grid-template-columns:1fr 1fr;background:#fff;border-radius:18px;border:1.5px solid #EAE2D4;margin-bottom:1.5rem;overflow:hidden;box-shadow:0 3px 14px rgba(0,0,0,.04);}
.cq-title-col{padding:1.5rem 1.8rem;position:relative;}
.cq-title-col:first-child{border-right:1.5px solid #F0E8DC;}
.cq-title-col:first-child::before{content:'';position:absolute;top:0;left:0;right:0;height:4px;background:linear-gradient(90deg,#5F8F63,#8ABF70);border-radius:0 0 4px 4px;}
.cq-title-col:last-child::before{content:'';position:absolute;top:0;left:0;right:0;height:4px;background:linear-gradient(90deg,#D97B6C,#E89888);border-radius:0 0 4px 4px;}
.cq-title-badge{display:inline-flex;align-items:center;gap:5px;font-size:.71rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;padding:4px 10px;border-radius:6px;margin-bottom:10px;}
.cq-title-badge-en{background:#D4EAC8;color:#2E5A30;}
.cq-title-badge-bm{background:#F8D8D0;color:#902810;}
.cq-title-val{font-size:1.05rem;font-weight:700;color:#1F2418;line-height:1.5;}
/* ── Info Notice ───────────────────────────────────────── */
.cq-info-notice{display:flex;align-items:flex-start;gap:16px;background:#FFFBF2;border-left:5px solid #D8A53A;border-radius:0 16px 16px 0;padding:1.25rem 1.6rem;margin-bottom:1.75rem;box-shadow:0 3px 16px rgba(216,165,58,.12);}
.cq-info-icon{width:44px;height:44px;background:linear-gradient(135deg,#F8E090,#E8C040);border-radius:13px;display:flex;align-items:center;justify-content:center;font-size:1.2rem;color:#7A5000;flex-shrink:0;box-shadow:0 3px 12px rgba(216,165,58,.28);}
.cq-info-body{flex:1;}
.cq-info-title{font-size:.9rem;font-weight:800;color:#6A4400;margin-bottom:5px;letter-spacing:.01em;}
.cq-info-text{font-size:.83rem;color:#5A3C10;line-height:1.65;}
/* ── Responsive ────────────────────────────────────────── */
@media(max-width:900px){.cq-hero{padding:2rem 1.75rem 1.75rem;}.cq-hero-meta{flex-direction:column;width:100%;}.cq-meta-item:not(:last-child){border-right:none;border-bottom:1.5px solid #EDE0CC;}}
@media(max-width:640px){.cq-hero-title{font-size:1.55rem;}.cq-titles-panel{grid-template-columns:1fr;}.cq-title-col:first-child{border-right:none;border-bottom:1.5px solid #F0E8DC;}.cq-title-col:first-child::before,.cq-title-col:last-child::before{display:none;}.cq-hero{padding:1.5rem 1.25rem 1.5rem;}}
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
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Create Quiz","Cipta Kuiz") %></asp:Content>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="qb-msg qb-msg-error"><i class="bi bi-exclamation-circle"></i> <asp:Literal ID="litError" runat="server" /></div>
    <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="qb-btn qb-btn-outline"><%: T("Back to Quizzes","Kembali ke Kuiz") %></a>
</asp:Panel>

<asp:Panel ID="pnlBuilder" runat="server" Visible="false">

<%-- ══════════════════════════════════════════════════════
     HERO HEADER
     ══════════════════════════════════════════════════════ --%>
<div class="cq-hero">
    <div class="cq-hero-bg">
        <svg viewBox="0 0 820 260" fill="none" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMaxYMid slice">
            <circle cx="550" cy="62" r="10" fill="#D97B6C"/>
            <ellipse cx="550" cy="62" rx="36" ry="15" stroke="#D97B6C" stroke-width="2.2" fill="none"/>
            <ellipse cx="550" cy="62" rx="36" ry="15" stroke="#D97B6C" stroke-width="2.2" fill="none" transform="rotate(60 550 62)"/>
            <ellipse cx="550" cy="62" rx="36" ry="15" stroke="#D97B6C" stroke-width="2.2" fill="none" transform="rotate(120 550 62)"/>
            <path d="M650 18 C660 36 672 36 682 18 C692 0 704 0 714 18" stroke="#486F4B" stroke-width="2.2" fill="none" stroke-linecap="round"/>
            <path d="M650 36 C660 54 672 54 682 36 C692 18 704 18 714 36" stroke="#486F4B" stroke-width="2.2" fill="none" stroke-linecap="round"/>
            <line x1="659" y1="27" x2="659" y2="43" stroke="#486F4B" stroke-width="1.6"/>
            <line x1="673" y1="36" x2="673" y2="52" stroke="#486F4B" stroke-width="1.6"/>
            <line x1="687" y1="27" x2="687" y2="43" stroke="#486F4B" stroke-width="1.6"/>
            <line x1="701" y1="18" x2="701" y2="34" stroke="#486F4B" stroke-width="1.6"/>
            <path d="M760 28 L760 66 L780 98 L740 98 Z" stroke="#5F8F63" stroke-width="2.2" fill="none" stroke-linejoin="round"/>
            <line x1="752" y1="28" x2="768" y2="28" stroke="#5F8F63" stroke-width="2.2"/>
            <ellipse cx="760" cy="90" rx="13" ry="5" fill="#5F8F63" opacity=".45"/>
            <circle cx="754" cy="78" r="4" fill="#D97B6C" opacity=".55"/>
            <circle cx="764" cy="84" r="3" fill="#D8A53A" opacity=".5"/>
            <rect x="790" y="110" width="24" height="38" rx="4" stroke="#D8A53A" stroke-width="2" fill="none"/>
            <line x1="802" y1="110" x2="802" y2="96" stroke="#D8A53A" stroke-width="2.2"/>
            <circle cx="802" cy="92" r="7" stroke="#D8A53A" stroke-width="2" fill="none"/>
            <line x1="786" y1="148" x2="818" y2="148" stroke="#D8A53A" stroke-width="2.2" stroke-linecap="round"/>
            <circle cx="700" cy="170" r="7" fill="#D97B6C"/><circle cx="726" cy="150" r="5" fill="#5F8F63"/>
            <circle cx="748" cy="172" r="7" fill="#D97B6C"/><circle cx="726" cy="192" r="4.5" fill="#D8A53A"/>
            <line x1="707" y1="170" x2="721" y2="153" stroke="#D97B6C" stroke-width="1.8"/>
            <line x1="731" y1="153" x2="743" y2="169" stroke="#D97B6C" stroke-width="1.8"/>
            <line x1="726" y1="155" x2="726" y2="187" stroke="#5F8F63" stroke-width="1.8"/>
            <path d="M610 110 Q632 88 644 110 Q632 134 610 110 Z" stroke="#486F4B" stroke-width="1.8" fill="none"/>
            <line x1="610" y1="110" x2="642" y2="110" stroke="#486F4B" stroke-width="1.2"/>
            <path d="M618 130 Q628 118 636 130 Q628 142 618 130 Z" stroke="#486F4B" stroke-width="1.5" fill="none" opacity=".6"/>
            <line x1="460" y1="200" x2="520" y2="160" stroke="#D97B6C" stroke-width="2.5" stroke-linecap="round"/>
            <ellipse cx="461" cy="201" rx="10" ry="6" stroke="#D97B6C" stroke-width="2" fill="none" transform="rotate(-35 461 201)"/>
            <line x1="520" y1="160" x2="536" y2="158" stroke="#D97B6C" stroke-width="2.5" stroke-linecap="round"/>
            <line x1="490" y1="220" x2="490" y2="200" stroke="#D97B6C" stroke-width="2" stroke-linecap="round"/>
            <line x1="476" y1="220" x2="504" y2="220" stroke="#D97B6C" stroke-width="2.5" stroke-linecap="round"/>
            <path d="M575 155 C580 138 596 135 598 148 C593 140 581 143 575 155 Z" fill="#D8A53A"/>
            <path d="M420 45 L422.5 52 L430 54.5 L422.5 57 L420 64 L417.5 57 L410 54.5 L417.5 52 Z" fill="#D8A53A" opacity=".75"/>
            <path d="M668 70 L669.8 75.5 L675.5 77.3 L669.8 79.1 L668 84.6 L666.2 79.1 L660.5 77.3 L666.2 75.5 Z" fill="#D8A53A" opacity=".65"/>
            <path d="M495 130 L496.4 134 L500.5 135.4 L496.4 136.8 L495 140.8 L493.6 136.8 L489.5 135.4 L493.6 134 Z" fill="#D97B6C" opacity=".6"/>
            <circle cx="438" cy="105" r="3.2" fill="#D8A53A" opacity=".6"/>
            <circle cx="462" cy="72" r="2.4" fill="#D97B6C" opacity=".55"/>
            <circle cx="582" cy="200" r="2.8" fill="#5F8F63" opacity=".5"/>
            <circle cx="640" cy="230" r="2" fill="#D8A53A" opacity=".5"/>
            <circle cx="772" cy="60" r="3" fill="#D97B6C" opacity=".45"/>
            <path d="M380 260 Q470 228 565 242 Q650 256 750 236 Q790 228 820 234 L820 260 Z" fill="#D8A53A" opacity=".18"/>
            <path d="M0 220 Q80 200 160 215 Q240 230 300 210 L300 260 L0 260 Z" fill="#5F8F63" opacity=".15"/>
        </svg>
    </div>
    <div class="cq-hero-left">
        <div class="cq-hero-top">
            <div class="cq-hero-icon"><i class="bi bi-journal-bookmark-fill"></i></div>
            <div>
                <h1 class="cq-hero-title"><asp:Literal ID="litMode" runat="server" /></h1>
                <p class="cq-hero-desc"><%: T("Create and manage questions for this quiz.","Cipta dan urus soalan untuk kuiz ini.") %></p>
            </div>
        </div>
        <div class="cq-hero-meta">
            <div class="cq-meta-item">
                <div class="cq-meta-pill cq-meta-pill-unit"><i class="bi bi-layers-fill"></i></div>
                <div>
                    <span class="cq-meta-label"><asp:Literal ID="litScopeLabel" runat="server" /></span>
                    <span class="cq-meta-val"><asp:Literal ID="litScope" runat="server" /></span>
                </div>
            </div>
            <div class="cq-meta-item">
                <div class="cq-meta-pill cq-meta-pill-subtopic"><i class="bi bi-bookmark-fill"></i></div>
                <div>
                    <span class="cq-meta-label"><%: T("Subtopic","Subtopik") %></span>
                    <span class="cq-meta-val"><asp:Literal ID="litSubtopic" runat="server" /></span>
                </div>
            </div>
        </div>
    </div>
</div><%-- /.cq-hero --%>

<%-- Quiz Titles Panel --%>
<asp:Panel ID="pnlQuizTitles" runat="server" Visible="false">
<div class="cq-titles-panel">
    <div class="cq-title-col">
        <span class="cq-title-badge cq-title-badge-en"><i class="bi bi-translate"></i>&nbsp;English</span>
        <div class="cq-title-val"><asp:Literal ID="litQuizTitleEN" runat="server" /></div>
    </div>
    <div class="cq-title-col">
        <span class="cq-title-badge cq-title-badge-bm"><i class="bi bi-translate"></i>&nbsp;Bahasa Melayu</span>
        <div class="cq-title-val"><asp:Literal ID="litQuizTitleBM" runat="server" /></div>
    </div>
</div>
</asp:Panel>

<%-- Subtopic Selection (legacy flow fallback) --%>
<asp:Panel ID="pnlSubtopicSelect" runat="server" Visible="false">
<div style="margin-bottom:1.5rem;padding:1.1rem 1.3rem;background:#FAFAF8;border-radius:14px;border:1.5px solid var(--tc-border);">
    <div style="font-size:.8rem;font-weight:700;color:var(--tc-text);margin-bottom:7px;"><%: T("Select Subtopic","Pilih Subtopik") %> *</div>
    <asp:DropDownList ID="ddlSubtopic" runat="server" CssClass="qb-input" style="padding:.55rem .75rem;" />
</div>
</asp:Panel>

<%-- Information Notice --%>
<div class="cq-info-notice">
    <div class="cq-info-icon"><i class="bi bi-info-circle-fill"></i></div>
    <div class="cq-info-body">
        <div class="cq-info-title"><%: T("Unit Quiz Information","Maklumat Kuiz Unit") %></div>
        <div class="cq-info-text"><%: T("Each question must include both English and Bahasa Melayu versions before it can be submitted successfully. Complete both language tabs before saving each question.","Setiap soalan mesti mengandungi kedua-dua versi Bahasa Inggeris dan Bahasa Melayu sebelum boleh dihantar. Lengkapkan kedua-dua tab bahasa sebelum menyimpan setiap soalan.") %></div>
    </div>
</div>

<%-- Progress Bar --%>
<div class="qb-progress">
    <div class="qb-progress-icon"><i class="bi bi-check2-all"></i></div>
    <div class="qb-progress-bar"><div class="qb-progress-fill" id="progressFill" style="width:0%"></div></div>
    <div class="qb-progress-text" id="progressText">0 / 0 <%: T("Questions Saved","Soalan Disimpan") %></div>
</div>

<%-- Builder Layout --%>
<div class="qb-layout">

<%-- Left Nav --%>
<div class="qb-nav">
    <div class="qb-nav-header">
        <div class="qb-nav-title">
            <%: T("Questions","Soalan") %>
            <span class="qb-nav-count" id="navCount">0</span>
        </div>
    </div>
    <div class="qb-nav-list">
        <asp:Repeater ID="rptNav" runat="server">
            <ItemTemplate>
                <div class="qb-nav-row">
                    <asp:LinkButton ID="btnNavQ" runat="server"
                        CssClass='<%# "qb-nav-item" + (Convert.ToInt32(Eval("Index")) == CurrentIndex ? " active" : "") + (Convert.ToBoolean(Eval("Done")) ? " done" : "") %>'
                        CommandName="GoTo" CommandArgument='<%# Eval("Index") %>'
                        OnCommand="btnNav_Command" CausesValidation="false"
                        data-qidx='<%# Eval("Index") %>'>
                        <span class="qb-nav-badge"><%# Convert.ToInt32(Eval("Index")) + 1 %></span>
                        <span>Q<%# Convert.ToInt32(Eval("Index")) + 1 %></span>
                        <i class="bi bi-check-circle-fill qb-nav-check"></i>
                    </asp:LinkButton>
                    <button type="button" class="qb-nav-del"
                        data-idx="<%# Convert.ToInt32(Eval("Index")) %>"
                        onclick="confirmDeleteQuestion(+this.dataset.idx)"
                        title="Delete question">
                        <i class="bi bi-trash3"></i>
                    </button>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
    <div class="qb-nav-footer">
        <asp:Button ID="btnAddQuestion" runat="server" CssClass="qb-nav-add"
            OnClientClick="clientAddQuestion();return false;"
            OnClick="btnAddQuestion_Click" CausesValidation="false" />
    </div>
</div>

<%-- Delete confirmation modal (pure UI — no backend wired yet) --%>
<div class="qb-del-overlay" id="qbDelOverlay" onclick="closeDeleteModal(event)">
    <div class="qb-del-modal">
        <div class="qb-del-modal-icon"><i class="bi bi-trash3-fill"></i></div>
        <h3><%: T("Delete Question?","Padam Soalan?") %></h3>
        <p id="qbDelMsg"><%: T("This question will be permanently removed. This action cannot be undone.","Soalan ini akan dipadam secara kekal. Tindakan ini tidak boleh dibatalkan.") %></p>
        <div class="qb-del-modal-actions">
            <button type="button" class="qb-del-btn-cancel" onclick="closeDeleteModal()"><%: T("Cancel","Batal") %></button>
            <button type="button" class="qb-del-btn-confirm" id="qbDelConfirm"><%: T("Delete","Padam") %></button>
        </div>
    </div>
</div>

<%-- Center Editor --%>
<div class="qb-center">
    <div class="qb-header">
        <div class="qb-qnum"><%: T("Question","Soalan") %> <asp:Literal ID="litQNum" runat="server" /></div>
        <div class="qb-tabs">
            <asp:Button ID="btnTabEN" runat="server" Text="English" CssClass="qb-tab active" OnClientClick="switchTab('EN');return false;" CausesValidation="false" />
            <asp:Button ID="btnTabBM" runat="server" Text="Bahasa Melayu" CssClass="qb-tab" OnClientClick="switchTab('BM');return false;" CausesValidation="false" />
        </div>
    </div>

    <div class="qb-editor-body">

    <%-- Question Text --%>
    <div class="qb-question-hero">
        <div class="qb-question-hero-header">
            <span class="qb-question-hero-label"><i class="bi bi-pencil-fill"></i><asp:Literal ID="litQTextLabel" runat="server" /></span>
            <span class="qb-char-count" id="qCharCount">0 / 500</span>
        </div>
        <asp:TextBox ID="txtQuestionText" runat="server" TextMode="MultiLine" Rows="3" CssClass="qb-input qb-textarea" MaxLength="500" />
    </div>

    <%-- Question Image (1 image per question, client-side only preview) --%>
    <div class="qb-img-zone" id="qbImgZone">
        <div class="qb-img-upload" id="qbImgUploadLabel" onclick="document.getElementById('qbImgInput').click()">
            <div class="qb-img-upload-icon"><i class="bi bi-image"></i></div>
            <span class="qb-img-upload-text"><%: T("Upload Image","Muat Naik Imej") %></span>
            <span class="qb-img-upload-sub"><%: T("Optional · PNG, JPG, GIF up to 5 MB","Pilihan · PNG, JPG, GIF sehingga 5 MB") %></span>
        </div>
        <%-- Server-side file upload control (hidden; triggered by JS click) --%>
        <asp:FileUpload ID="fuQuestionImage" runat="server" Style="display:none;" />
        <input type="file" id="qbImgInput" accept="image/*" onchange="handleQImgUpload(this)" style="display:none;" />
        <div class="qb-img-preview" id="qbImgPreview">
            <img id="qbImgPreviewSrc" src="" alt="" />
            <button type="button" class="qb-img-remove" onclick="removeQImg()"><i class="bi bi-x"></i></button>
        </div>
    </div>
    <asp:HiddenField ID="hidImgFileName" runat="server" Value="" />

    <%-- Answer Section: MCQ (default) --%>
    <div id="sectionMCQ" class="qb-answer-section">
        <div class="qb-section-header">
            <div class="qb-section-header-icon"><i class="bi bi-ui-radios"></i></div>
            <span class="qb-section-header-text"><asp:Literal ID="litOptionsLabel" runat="server" /></span>
            <span class="qb-section-header-sub"><%: T("Select one correct answer","Pilih satu jawapan betul") %></span>
            <div class="qb-section-divider"></div>
        </div>
        <div class="qb-opts">
            <div class="qb-opt" id="optAWrap" runat="server">
                <div class="qb-opt-band">A</div>
                <div class="qb-opt-body"><asp:RadioButton ID="radA" runat="server" GroupName="correct" /><asp:TextBox ID="txtOptA" runat="server" CssClass="qb-opt-input" /></div>
            </div>
            <div class="qb-opt" id="optBWrap" runat="server">
                <div class="qb-opt-band">B</div>
                <div class="qb-opt-body"><asp:RadioButton ID="radB" runat="server" GroupName="correct" /><asp:TextBox ID="txtOptB" runat="server" CssClass="qb-opt-input" /></div>
            </div>
            <div class="qb-opt" id="optCWrap" runat="server">
                <div class="qb-opt-band">C</div>
                <div class="qb-opt-body"><asp:RadioButton ID="radC" runat="server" GroupName="correct" /><asp:TextBox ID="txtOptC" runat="server" CssClass="qb-opt-input" /></div>
            </div>
            <div class="qb-opt" id="optDWrap" runat="server">
                <div class="qb-opt-band">D</div>
                <div class="qb-opt-body"><asp:RadioButton ID="radD" runat="server" GroupName="correct" /><asp:TextBox ID="txtOptD" runat="server" CssClass="qb-opt-input" /></div>
            </div>
        </div>
    </div>

    <%-- Answer Section: True/False --%>
    <div id="sectionTF" class="qb-answer-section" style="display:none;">
        <div class="qb-section-header">
            <div class="qb-section-header-icon"><i class="bi bi-toggles"></i></div>
            <span class="qb-section-header-text"><%: T("Select the correct answer","Pilih jawapan yang betul") %></span>
            <div class="qb-section-divider"></div>
        </div>
        <div class="qb-tf-grid">
            <label class="qb-tf-card" id="tfTrueCard"><input type="radio" name="tfAnswer" value="A" onchange="updateTFCards()"/><i class="bi bi-check-circle-fill"></i><span>TRUE</span></label>
            <label class="qb-tf-card" id="tfFalseCard"><input type="radio" name="tfAnswer" value="B" onchange="updateTFCards()"/><i class="bi bi-x-circle-fill"></i><span>FALSE</span></label>
        </div>
    </div>

    <%-- Answer Section: Multiselect --%>
    <div id="sectionMS" class="qb-answer-section" style="display:none;">
        <div class="qb-section-header">
            <div class="qb-section-header-icon"><i class="bi bi-check2-square"></i></div>
            <span class="qb-section-header-text"><%: T("Select all correct answers","Pilih semua jawapan betul") %></span>
            <span class="qb-ms-count" id="msCount" style="margin-left:0;">0 <%: T("selected","dipilih") %></span>
            <div class="qb-section-divider"></div>
        </div>
        <div class="qb-opts">
            <div class="qb-opt qb-ms-opt">
                <div class="qb-opt-band">A</div>
                <div class="qb-opt-body"><input type="checkbox" class="ms-check" onchange="updateMSCards()"/><input type="text" class="qb-opt-input ms-text" placeholder="<%: T("Type option A...","Taip pilihan A...") %>" /></div>
            </div>
            <div class="qb-opt qb-ms-opt">
                <div class="qb-opt-band">B</div>
                <div class="qb-opt-body"><input type="checkbox" class="ms-check" onchange="updateMSCards()"/><input type="text" class="qb-opt-input ms-text" placeholder="<%: T("Type option B...","Taip pilihan B...") %>" /></div>
            </div>
            <div class="qb-opt qb-ms-opt">
                <div class="qb-opt-band">C</div>
                <div class="qb-opt-body"><input type="checkbox" class="ms-check" onchange="updateMSCards()"/><input type="text" class="qb-opt-input ms-text" placeholder="<%: T("Type option C...","Taip pilihan C...") %>" /></div>
            </div>
            <div class="qb-opt qb-ms-opt">
                <div class="qb-opt-band">D</div>
                <div class="qb-opt-body"><input type="checkbox" class="ms-check" onchange="updateMSCards()"/><input type="text" class="qb-opt-input ms-text" placeholder="<%: T("Type option D...","Taip pilihan D...") %>" /></div>
            </div>
        </div>
    </div>

    <%-- Answer Section: Fill in the Blank --%>
    <div id="sectionFIB" class="qb-answer-section" style="display:none;">
        <div class="qb-section-header">
            <div class="qb-section-header-icon"><i class="bi bi-input-cursor-text"></i></div>
            <span class="qb-section-header-text"><%: T("Fill in the Blank","Isi Tempat Kosong") %></span>
            <div class="qb-section-divider"></div>
        </div>
        <div class="fib-add-row">
            <button type="button" class="fib-add-btn" id="btnAddBlank" onclick="addBlank()"><i class="bi bi-plus-square-dotted"></i> <%: T("Add Blank","Tambah Kosong") %></button>
            <span class="fib-counter" id="blankCounter"><%: T("Blanks","Kosong") %>: <strong id="blankNum">0</strong> / 4</span>
        </div>
        <div class="fib-warning" id="blankWarning" style="display:none;">
            <i class="bi bi-exclamation-triangle-fill"></i> <%: T("Maximum of 4 blanks reached. Remove an existing blank before adding another.","Maksimum 4 tempat kosong dicapai. Buang kosong sedia ada sebelum menambah yang lain.") %>
        </div>
        <div class="fib-section-label"><i class="bi bi-collection"></i> <%: T("Word Bank","Bank Perkataan") %> * <span class="fib-sub-label">(<%: T("Max 4 words","Maks 4 perkataan") %>)</span></div>
        <div class="qb-fib-words" id="fibWordsContainer">
            <div class="qb-fib-word"><span class="qb-fib-num">1</span><input type="text" class="qb-opt-input fib-word-input" placeholder="<%: T("Word 1","Perkataan 1") %>" oninput="onFibWordChange()" /></div>
            <div class="qb-fib-word"><span class="qb-fib-num">2</span><input type="text" class="qb-opt-input fib-word-input" placeholder="<%: T("Word 2","Perkataan 2") %>" oninput="onFibWordChange()" /></div>
            <div class="qb-fib-word"><span class="qb-fib-num">3</span><input type="text" class="qb-opt-input fib-word-input" placeholder="<%: T("Word 3","Perkataan 3") %>" oninput="onFibWordChange()" /></div>
            <div class="qb-fib-word"><span class="qb-fib-num">4</span><input type="text" class="qb-opt-input fib-word-input" placeholder="<%: T("Word 4","Perkataan 4") %>" oninput="onFibWordChange()" /></div>
        </div>
        <div id="fibMappingSection" class="fib-mapping-wrap" style="display:none;">
            <div class="fib-section-label"><i class="bi bi-arrow-left-right"></i> <%: T("Correct Answer Mapping","Pemetaan Jawapan Betul") %> *</div>
            <div class="qb-fib-mappings" id="fibMappings"></div>
            <div class="fib-warning" id="fibMappingError" style="display:none;margin-top:6px;">
                <i class="bi bi-exclamation-circle-fill"></i> <%: T("Each blank must map to a unique word.","Setiap kosong mesti dipetakan kepada perkataan unik.") %>
            </div>
        </div>
        <div id="fibPreviewSection" class="fib-preview-wrap" style="display:none;">
            <div class="qb-fib-preview-card">
                <div class="qb-fib-preview-title"><i class="bi bi-eye"></i> <%: T("Student Preview","Pratonton Pelajar") %></div>
                <div class="qb-fib-preview-sub"><%: T("Students will drag the correct words into the blanks below.","Pelajar akan menyeret perkataan betul ke dalam kosong di bawah.") %></div>
                <div class="qb-fib-preview-text" id="fibPreviewText"></div>
                <div style="margin-top:.75rem;">
                    <div style="font-size:.72rem;font-weight:600;color:var(--tc-muted);margin-bottom:6px;text-transform:uppercase;letter-spacing:.5px;"><%: T("Available Words","Perkataan Tersedia") %></div>
                    <div class="qb-fib-preview-words" id="fibPreviewWords"></div>
                </div>
            </div>
        </div>
        <div class="qb-fib-hint"><i class="bi bi-lightbulb"></i> <%: T("Click 'Add Blank' to insert blanks into your question text. Then assign each blank to a correct word from the Word Bank above.","Klik 'Tambah Kosong' untuk memasukkan kosong ke dalam teks soalan. Kemudian tetapkan setiap kosong kepada perkataan betul dari Bank Perkataan di atas.") %></div>
    </div>

    <%-- Explanations --%>
    <div class="qb-section-header" style="margin-top:.5rem;">
        <div class="qb-section-header-icon"><i class="bi bi-chat-quote-fill"></i></div>
        <span class="qb-section-header-text"><%: T("Explanations","Penjelasan") %></span>
        <div class="qb-section-divider"></div>
    </div>
    <%-- Correct Explanation — soft green --%>
    <div class="qb-exp-block qb-exp-correct">
        <div class="qb-exp-block-header">
            <div class="qb-exp-block-icon"><i class="bi bi-check-circle-fill"></i></div>
            <span class="qb-exp-block-label"><asp:Literal ID="litCorrectExpLabel" runat="server" /> *</span>
            <span class="qb-exp-block-count" id="ceCharCount">0 / 500</span>
        </div>
        <asp:TextBox ID="txtCorrectExp" runat="server" TextMode="MultiLine" Rows="2" CssClass="qb-input qb-textarea" MaxLength="500" />
    </div>
    <%-- Wrong Explanation — soft red --%>
    <div class="qb-exp-block qb-exp-wrong">
        <div class="qb-exp-block-header">
            <div class="qb-exp-block-icon"><i class="bi bi-x-circle-fill"></i></div>
            <span class="qb-exp-block-label"><asp:Literal ID="litWrongExpLabel" runat="server" /> *</span>
            <span class="qb-exp-block-count" id="weCharCount">0 / 500</span>
        </div>
        <asp:TextBox ID="txtWrongExp" runat="server" TextMode="MultiLine" Rows="2" CssClass="qb-input qb-textarea" MaxLength="500" />
    </div>

    <%-- Save Status --%>
    <div class="qb-save-status" id="saveStatus"><i class="bi bi-circle"></i> <span id="saveStatusText"><%: T("Question Incomplete","Soalan Tidak Lengkap") %></span></div>

    </div><%-- /.qb-editor-body --%>

    <div class="qb-actions">
        <asp:Button ID="btnPrev" runat="server" Text="← Previous" CssClass="qb-btn qb-btn-outline" OnClientClick="return navGoTo(window.__CI-1);" CausesValidation="false" />
        <asp:Button ID="btnNext" runat="server" Text="Next →" CssClass="qb-btn qb-btn-outline" OnClientClick="return navGoTo(window.__CI+1);" CausesValidation="false" />
        <asp:Button ID="btnSaveQ" runat="server" Text="Save Question" CssClass="qb-btn qb-btn-primary" OnClientClick="flushToServer();" OnClick="btnSaveQ_Click" CausesValidation="false" />
        <asp:Button ID="btnSubmitQuiz" runat="server" Text="Submit Quiz" CssClass="qb-btn qb-btn-success" OnClientClick="return validateFibBlanksAndFlush();" OnClick="btnSubmitQuiz_Click" CausesValidation="false" />
    </div>
</div><%-- /.qb-center --%>

<%-- Right Props --%>
<div class="qb-props">
    <div class="qb-props-header">
        <div class="qb-props-header-icon"><i class="bi bi-sliders"></i></div>
        <div class="qb-props-title"><%: T("Properties","Sifat") %></div>
    </div>
    <div class="qb-props-body">
        <div class="qb-prop-field">
            <div class="qb-prop-label">
                <span class="qb-prop-label-icon type"><i class="bi bi-ui-checks"></i></span>
                <%: T("Question Type","Jenis Soalan") %>
            </div>
            <asp:DropDownList ID="ddlQType" runat="server" CssClass="qb-input">
                <asp:ListItem Value="MCQ" Text="MCQ" />
                <asp:ListItem Value="True/False" Text="True / False" />
                <asp:ListItem Value="Multiselect" Text="Multiselect" />
                <asp:ListItem Value="Drag & Drop" Text="Drag & Drop" />
            </asp:DropDownList>
        </div>
        <div class="qb-prop-field">
            <div class="qb-prop-label">
                <span class="qb-prop-label-icon diff"><i class="bi bi-bar-chart-fill"></i></span>
                <%: T("Difficulty","Kesukaran") %>
            </div>
            <asp:DropDownList ID="ddlQDiff" runat="server" CssClass="qb-input">
                <asp:ListItem Value="Easy" Text="Easy" />
                <asp:ListItem Value="Medium" Text="Medium" />
                <asp:ListItem Value="Hard" Text="Hard" />
            </asp:DropDownList>
        </div>
        <div class="qb-prop-field">
            <div class="qb-prop-label">
                <span class="qb-prop-label-icon sub"><i class="bi bi-bookmark-fill"></i></span>
                <%: T("Subtopic","Subtopik") %>
            </div>
            <div class="qb-prop-subtopic-val"><asp:Literal ID="litPropSubtopic" runat="server" /></div>
        </div>
    </div>
</div>

</div><%-- /.qb-layout --%>

<asp:HiddenField ID="hidCurrentTab" runat="server" Value="EN" />
<asp:HiddenField ID="hidCurrentIndex" runat="server" Value="0" />
<asp:HiddenField ID="hidQuestionsJson" runat="server" Value="" />
<asp:HiddenField ID="hidToast" runat="server" Value="" />
<asp:HiddenField ID="hidDeleteIndex" runat="server" Value="-1" />
<asp:HiddenField ID="hidSubmitSuccess" runat="server" Value="" />
<asp:Button ID="btnDeleteQuestion" runat="server" Style="display:none;" OnClick="btnDeleteQuestion_Click" CausesValidation="false" />
<asp:Button ID="btnNavGo" runat="server" Style="display:none;" OnClick="btnNavGo_Click" CausesValidation="false" />
<asp:Literal ID="litQuestionsJson" runat="server" />
</asp:Panel>

<%-- ── Submit Success Modal ─────────────────────────────── --%>
<div class="qb-success-overlay" id="qbSuccessOverlay">
    <div class="qb-success-modal">
        <div class="qb-success-icon"><i class="bi bi-patch-check-fill"></i></div>
        <h3><%: T("Quiz Submitted Successfully","Kuiz Berjaya Dihantar") %></h3>
        <p><%: T("Your questions have been submitted and are now pending review.","Soalan anda telah dihantar dan sedang menunggu semakan.") %></p>
        <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="qb-btn qb-btn-primary" style="margin-top:.5rem;text-decoration:none;">
            <%: T("Back to Manage Quizzes","Kembali ke Urus Kuiz") %>
        </a>
    </div>
</div>

<div id="qbToast" class="qb-toast-container"></div>
</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
/* ═══════════════════════════════════════════════════════════
   CLIENT-SIDE QUIZ ENGINE — no postback for tab/nav switch
   ═══════════════════════════════════════════════════════════ */
function $id(s){return document.getElementById(s);}
function $qs(s){return document.querySelector(s);}

var SRV={
    txtQ:'<%=txtQuestionText.ClientID%>',txtA:'<%=txtOptA.ClientID%>',
    txtB:'<%=txtOptB.ClientID%>',txtC:'<%=txtOptC.ClientID%>',txtD:'<%=txtOptD.ClientID%>',
    txtCE:'<%=txtCorrectExp.ClientID%>',txtWE:'<%=txtWrongExp.ClientID%>',
    radA:'<%=radA.ClientID%>',radB:'<%=radB.ClientID%>',
    radC:'<%=radC.ClientID%>',radD:'<%=radD.ClientID%>',
    ddlType:'<%=ddlQType.ClientID%>',ddlDiff:'<%=ddlQDiff.ClientID%>',
    hidTab:'<%=hidCurrentTab.ClientID%>',hidIdx:'<%=hidCurrentIndex.ClientID%>',
    hidJson:'<%=hidQuestionsJson.ClientID%>',hidDel:'<%=hidDeleteIndex.ClientID%>',
    btnDel:'<%=btnDeleteQuestion.ClientID%>',toast:'<%=hidToast.ClientID%>',
    fuImg:'<%=fuQuestionImage.ClientID%>',hidImgFile:'<%=hidImgFileName.ClientID%>'
};

window.__QD=window.__QD||[];
window.__CI=window.__CI||0;
window.__CT=window.__CT||'EN';

/* After server postback, fibIdxEN/fibIdxBM arrive as JSON strings — parse them back to objects */
(function normFibIdx(){
    window.__QD.forEach(function(q){
        if(typeof q.fibIdxEN==='string'){try{q.fibIdxEN=JSON.parse(q.fibIdxEN);}catch(e){q.fibIdxEN={};}}
        else if(!q.fibIdxEN)q.fibIdxEN={};
        if(typeof q.fibIdxBM==='string'){try{q.fibIdxBM=JSON.parse(q.fibIdxBM);}catch(e){q.fibIdxBM={};}}
        else if(!q.fibIdxBM)q.fibIdxBM={};
        if(!q.fibMapEN)q.fibMapEN=[];
        if(!q.fibMapBM)q.fibMapBM=[];
    });
})();

function emptyQ(){return{
    qEN:'',qBM:'',
    aEN:'',aBM:'',bEN:'',bBM:'',cEN:'',cBM:'',dEN:'',dBM:'',
    ceEN:'',ceBM:'',weEN:'',weBM:'',
    correct:'',type:'MCQ',diff:'Medium',saved:false,img:'',
    /* Multiselect — per-language option text, SHARED checked state */
    msAEN:'',msABM:'',msBEN:'',msBBM:'',msCEN:'',msCBM:'',msDEN:'',msDBM:'',
    msChk:'',  /* shared comma-separated checked letters e.g. "A,C" — same for both languages */
    /* Drag & Drop (FIB) — per-language word bank (4 slots) */
    fibEN:['','','',''],fibBM:['','','',''],
    /* FIB mapping indices per blank per language: {blank_label: slot_index_string} */
    fibIdxEN:{},fibIdxBM:{},
    /* FIB mapping resolved word text per blank in order (for correctAnswer) */
    fibMapEN:[],fibMapBM:[]
};}

function captureCurrentFields(){
    if(!window.__QD.length)return;
    var q=window.__QD[window.__CI],tab=window.__CT;
    var g=function(id){var e=$id(id);return e?e.value:'';};

    /* ── MCQ / shared text fields ─────────────────────────── */
    if(tab==='EN'){q.qEN=g(SRV.txtQ);q.aEN=g(SRV.txtA);q.bEN=g(SRV.txtB);q.cEN=g(SRV.txtC);q.dEN=g(SRV.txtD);q.ceEN=g(SRV.txtCE);q.weEN=g(SRV.txtWE);}
    else{q.qBM=g(SRV.txtQ);q.aBM=g(SRV.txtA);q.bBM=g(SRV.txtB);q.cBM=g(SRV.txtC);q.dBM=g(SRV.txtD);q.ceBM=g(SRV.txtCE);q.weBM=g(SRV.txtWE);}

    /* ── MCQ correct answer ───────────────────────────────── */
    ['A','B','C','D'].forEach(function(l){var r=$id(SRV['rad'+l]);if(r&&r.checked)q.correct=l;});

    /* ── True/False correct answer (separate radio group) ─── */
    if(q.type==='True/False'||($id(SRV.ddlType)&&$id(SRV.ddlType).value==='True/False')){
        var tfRadios=document.querySelectorAll('.qb-tf-card input[type="radio"]');
        tfRadios.forEach(function(r){if(r.checked)q.correct=r.value;});
    }

    /* ── Multiselect option texts (per language) ─────────── */
    var msInputs=document.querySelectorAll('#sectionMS .ms-text');
    var msKeys=(tab==='EN')?['msAEN','msBEN','msCEN','msDEN']:['msABM','msBBM','msCBM','msDBM'];
    msInputs.forEach(function(inp,i){if(msKeys[i]!==undefined)q[msKeys[i]]=inp.value||'';});
    /* Multiselect checked letters — SHARED across languages */
    var msChecked=[];
    document.querySelectorAll('#sectionMS .ms-check').forEach(function(cb,i){
        if(cb.checked)msChecked.push(['A','B','C','D'][i]);
    });
    /* store as single shared field — same selection applies to both EN and BM */
    q.msChk=msChecked.join(',');

    /* ── FIB word bank (per language) ────────────────────── */
    var fibInputs=document.querySelectorAll('#sectionFIB .fib-word-input');
    var fibArr=[];
    fibInputs.forEach(function(inp){fibArr.push(inp.value||'');});
    if(tab==='EN')q.fibEN=fibArr;
    else q.fibBM=fibArr;

    /* ── FIB mapping — capture selected slot indices + resolved word text per language ─── */
    var fibWordInputsAll=document.querySelectorAll('#sectionFIB .fib-word-input');
    var allWords=[];
    fibWordInputsAll.forEach(function(inp){allWords.push(inp.value||'');});
    /* Save the numeric slot index (1-based string) for each blank, keyed by blank label */
    var fibIdxMap={};
    var fibMappings=[];
    document.querySelectorAll('#fibMappings .fib-map-dd').forEach(function(sel){
        fibIdxMap[sel.dataset.blank]=sel.value||''; /* e.g. {"[Blank 1]":"2"} */
        var idx=sel.value?parseInt(sel.value,10)-1:-1;
        fibMappings.push(idx>=0&&allWords[idx]?allWords[idx]:'');
    });
    if(tab==='EN'){q.fibIdxEN=fibIdxMap;q.fibMapEN=fibMappings;}
    else{q.fibIdxBM=fibIdxMap;q.fibMapBM=fibMappings;}

    var dt=$id(SRV.ddlType);if(dt)q.type=dt.value;
    var dd=$id(SRV.ddlDiff);if(dd)q.diff=dd.value;

    /* ── Image ───────────────────────────────────────────── */
    var imgSrc=$id('qbImgPreviewSrc');
    var imgPreview=$id('qbImgPreview');
    if(imgSrc&&imgPreview&&imgPreview.style.display!=='none'&&imgSrc.src&&imgSrc.src!==window.location.href){
        q.img=imgSrc.src;
    }
}

function populateFields(q,tab){
    var isEN=(tab==='EN');
    var s=function(id,v){var e=$id(id);if(e)e.value=v||'';};

    /* ── MCQ / shared text fields ─────────────────────────── */
    s(SRV.txtQ,isEN?q.qEN:q.qBM);
    s(SRV.txtA,isEN?q.aEN:q.aBM);s(SRV.txtB,isEN?q.bEN:q.bBM);
    s(SRV.txtC,isEN?q.cEN:q.cBM);s(SRV.txtD,isEN?q.dEN:q.dBM);
    s(SRV.txtCE,isEN?q.ceEN:q.ceBM);s(SRV.txtWE,isEN?q.weEN:q.weBM);

    /* ── MCQ correct answer radio ────────────────────────── */
    ['A','B','C','D'].forEach(function(l){var r=$id(SRV['rad'+l]);if(r)r.checked=(q.correct===l);});

    /* ── True/False correct answer (separate radio group) ─── */
    document.querySelectorAll('.qb-tf-card input[type="radio"]').forEach(function(r){
        r.checked=(q.correct===r.value);
    });
    updateTFCards();

    /* ── Multiselect option texts (per language) ─────────── */
    var msInputs=document.querySelectorAll('#sectionMS .ms-text');
    var msVals=isEN?[q.msAEN,q.msBEN,q.msCEN,q.msDEN]:[q.msABM,q.msBBM,q.msCBM,q.msDBM];
    msInputs.forEach(function(inp,i){inp.value=msVals[i]||'';});
    /* Restore multiselect checked state — SHARED, same for both languages */
    var chkStr=q.msChk||'';
    var chkLetters=chkStr?chkStr.split(','):[];
    var letters=['A','B','C','D'];
    document.querySelectorAll('#sectionMS .ms-check').forEach(function(cb,i){
        cb.checked=chkLetters.indexOf(letters[i])>-1;
    });
    updateMSCards();

    /* ── FIB word bank (per language) ────────────────────── */
    var fibArr=isEN?(q.fibEN||['','','','']):(q.fibBM||['','','','']);
    document.querySelectorAll('#sectionFIB .fib-word-input').forEach(function(inp,i){
        inp.value=fibArr[i]||'';
    });
    /* Rebuild the mapping dropdowns using this language's stored indices */
    /* (updateFibUI calls updateFibMappings which reads fibIdxEN/fibIdxBM from the store) */

    /* ── Type / Difficulty ───────────────────────────────── */
    var dt=$id(SRV.ddlType);if(dt&&q.type)dt.value=q.type;
    var dd=$id(SRV.ddlDiff);if(dd&&q.diff)dd.value=q.diff;

    /* ── Image ───────────────────────────────────────────── */
    var imgPreview=$id('qbImgPreview');
    var imgSrc=$id('qbImgPreviewSrc');
    var imgLabel=$id('qbImgUploadLabel');
    if(q.img){
        if(imgSrc)imgSrc.src=q.img;
        if(imgPreview)imgPreview.style.display='block';
        if(imgLabel)imgLabel.style.display='none';
    } else {
        if(imgSrc)imgSrc.src='';
        if(imgPreview)imgPreview.style.display='none';
        if(imgLabel)imgLabel.style.display='flex';
    }

    switchQuestionType();updateAnswerCards();updateCharCounts();updateFibUI();
}

function updateLabels(tab){
    var isEN=(tab==='EN');
    var ql=$qs('.qb-question-hero-label');
    if(ql){var ic=ql.querySelector('i');ql.innerHTML='';if(ic)ql.appendChild(ic);ql.appendChild(document.createTextNode(isEN?' Question (English)':' Question (Bahasa Melayu)'));}
    var ol=$qs('#sectionMCQ .qb-section-header-text');
    if(ol)ol.textContent=isEN?'Options (English)':'Options (Bahasa Melayu)';
    var ce=$qs('.qb-exp-correct .qb-exp-block-label');
    if(ce)ce.textContent=(isEN?'Correct Explanation (EN)':'Correct Explanation (BM)')+' *';
    var we=$qs('.qb-exp-wrong .qb-exp-block-label');
    if(we)we.textContent=(isEN?'Wrong Explanation (EN)':'Wrong Explanation (BM)')+' *';
}

function switchTab(tab){
    captureCurrentFields();window.__CT=tab;
    var q=window.__QD[window.__CI]||emptyQ();
    populateFields(q,tab);updateLabels(tab);
    var en=$qs('[id$="btnTabEN"]'),bm=$qs('[id$="btnTabBM"]');
    if(en)en.className=(tab==='EN')?'qb-tab active':'qb-tab';
    if(bm)bm.className=(tab==='BM')?'qb-tab active':'qb-tab';
    var ht=$id(SRV.hidTab);if(ht)ht.value=tab;
}

function navGoTo(idx){
    if(idx<0||idx>=window.__QD.length)return false;
    captureCurrentFields();window.__CI=idx;
    var q=window.__QD[idx];populateFields(q,window.__CT);updateLabels(window.__CT);
    var qn=$qs('[id$="litQNum"]');if(qn)qn.textContent=idx+1;
    document.querySelectorAll('.qb-nav-item').forEach(function(el,i){
        el.className='qb-nav-item'+(i===idx?' active':'')+(window.__QD[i]&&window.__QD[i].saved?' done':'');
    });
    var bp=$qs('[id$="btnPrev"]'),bn=$qs('[id$="btnNext"]');
    if(bp)bp.disabled=(idx===0);if(bn)bn.disabled=(idx===window.__QD.length-1);
    updateProgress();return false;
}

/* ── Inline field validation helpers ─────────────────────── */
var ERR_MSG='Please fill in the required field.';

/* Returns the element after which the message should be inserted.
   We always want the message OUTSIDE the coloured container card. */
function qbMsgAnchor(el){
    var expBlock=el.closest ? el.closest('.qb-exp-block') : null;
    if(expBlock)return expBlock;
    var heroBlock=el.closest ? el.closest('.qb-question-hero') : null;
    if(heroBlock)return heroBlock;
    return el;
}

function qbSetErr(el,customMsg){
    if(!el)return;
    el.classList.add('qb-err');
    var anchor=qbMsgAnchor(el);
    var next=anchor.nextElementSibling;
    if(next&&next.classList.contains('qb-err-msg'))next.remove();
    var msg=document.createElement('div');
    msg.className='qb-err-msg';
    msg.innerHTML='<i class="bi bi-exclamation-circle-fill" style="font-size:13px;flex-shrink:0;"></i> '+(customMsg||ERR_MSG);
    anchor.parentNode.insertBefore(msg,anchor.nextSibling);
}

/* Mark individual empty inputs with red border; place ONE message after the grid */
function qbSetGridErr(gridEl,inputs,customMsg){
    if(!gridEl)return;
    inputs.forEach(function(inp){if(inp)inp.classList.add('qb-err');});
    var next=gridEl.nextElementSibling;
    if(next&&next.classList.contains('qb-err-msg'))next.remove();
    var msg=document.createElement('div');
    msg.className='qb-err-msg';
    msg.innerHTML='<i class="bi bi-exclamation-circle-fill" style="font-size:13px;flex-shrink:0;"></i> '+(customMsg||ERR_MSG);
    gridEl.parentNode.insertBefore(msg,gridEl.nextSibling);
}

function qbClearErr(el){
    if(!el)return;
    el.classList.remove('qb-err');
    var anchor=qbMsgAnchor(el);
    var next=anchor.nextElementSibling;
    if(next&&next.classList.contains('qb-err-msg'))next.remove();
    if(anchor!==el){next=el.nextElementSibling;if(next&&next.classList.contains('qb-err-msg'))next.remove();}
}
function qbClearAllErrors(){
    document.querySelectorAll('.qb-err').forEach(function(el){el.classList.remove('qb-err');});
    document.querySelectorAll('.qb-err-msg').forEach(function(el){el.remove();});
}
function qbWireAutoClears(){
    document.querySelectorAll('textarea,input[type="text"],select').forEach(function(el){
        el.addEventListener('input',function(){
            qbClearErr(el);
            var grid=el.closest('.qb-opts,.qb-tf-grid,.qb-fib-words');
            if(grid){var next=grid.nextElementSibling;if(next&&next.classList.contains('qb-err-msg'))next.remove();}
        });
        el.addEventListener('change',function(){qbClearErr(el);});
    });
    document.querySelectorAll('.ms-check,input[type="radio"]').forEach(function(el){
        el.addEventListener('change',function(){
            var grid=el.closest('.qb-opts,.qb-tf-grid');
            if(grid){var next=grid.nextElementSibling;if(next&&next.classList.contains('qb-err-msg'))next.remove();}
        });
    });
}

/* ── Full client-side submit validation ───────────────────── */
function validateAllQuestions(){
    for(var i=0;i<window.__QD.length;i++){
        var q=window.__QD[i];
        var qType=q.type||'MCQ';
        navGoTo(i);

        /* ── EN question text ─── */
        switchTab('EN');
        var txQ=$id(SRV.txtQ);
        if(!txQ||!txQ.value.trim()){qbSetErr(txQ);return{ok:false,qIdx:i,tab:'EN',firstEl:txQ};}

        /* ── BM question text ─── */
        switchTab('BM');
        txQ=$id(SRV.txtQ);
        if(!txQ||!txQ.value.trim()){qbSetErr(txQ);return{ok:false,qIdx:i,tab:'BM',firstEl:txQ};}

        /* ── EN explanations ─── */
        switchTab('EN');
        var txCE=$id(SRV.txtCE);
        if(!txCE||!txCE.value.trim()){qbSetErr(txCE);return{ok:false,qIdx:i,tab:'EN',firstEl:txCE};}
        var txWE=$id(SRV.txtWE);
        if(!txWE||!txWE.value.trim()){qbSetErr(txWE);return{ok:false,qIdx:i,tab:'EN',firstEl:txWE};}

        /* ── BM explanations ─── */
        switchTab('BM');
        txCE=$id(SRV.txtCE);
        if(!txCE||!txCE.value.trim()){qbSetErr(txCE);return{ok:false,qIdx:i,tab:'BM',firstEl:txCE};}
        txWE=$id(SRV.txtWE);
        if(!txWE||!txWE.value.trim()){qbSetErr(txWE);return{ok:false,qIdx:i,tab:'BM',firstEl:txWE};}

        /* ── MCQ ─── */
        if(qType==='MCQ'){
            switchTab('EN');
            var mcqGrid=$qs('#sectionMCQ .qb-opts');
            var tA=$id(SRV.txtA),tB=$id(SRV.txtB);
            var emptyEN=[];
            if(!tA||!tA.value.trim())emptyEN.push(tA);
            if(!tB||!tB.value.trim())emptyEN.push(tB);
            if(emptyEN.length){qbSetGridErr(mcqGrid,emptyEN);return{ok:false,qIdx:i,tab:'EN',firstEl:emptyEN[0]};}
            switchTab('BM');
            var tAbm=$id(SRV.txtA),tBbm=$id(SRV.txtB);
            var emptyBM=[];
            if(!tAbm||!tAbm.value.trim())emptyBM.push(tAbm);
            if(!tBbm||!tBbm.value.trim())emptyBM.push(tBbm);
            if(emptyBM.length){qbSetGridErr($qs('#sectionMCQ .qb-opts'),emptyBM);return{ok:false,qIdx:i,tab:'BM',firstEl:emptyBM[0]};}
            /* No correct answer selected */
            switchTab('EN');
            if(!q.correct){
                qbSetGridErr($qs('#sectionMCQ .qb-opts'),[],'Please select the correct answer.');
                return{ok:false,qIdx:i,tab:'EN',firstEl:$qs('#sectionMCQ .qb-opts')};
            }
            /* Correct answer points to an empty option */
            var correctInput=$id({'A':SRV.txtA,'B':SRV.txtB,'C':SRV.txtC,'D':SRV.txtD}[q.correct]);
            if(!correctInput||!correctInput.value.trim()){
                qbSetGridErr($qs('#sectionMCQ .qb-opts'),[correctInput],'Please fill in the required field.');
                return{ok:false,qIdx:i,tab:'EN',firstEl:correctInput||$qs('#sectionMCQ .qb-opts')};
            }
        }

        /* ── True / False ─── */
        if(qType==='True/False'){
            switchTab('EN');
            if(!q.correct){
                var tfGrid=$qs('#sectionTF .qb-tf-grid');
                qbSetGridErr(tfGrid,[],'Please select the correct answer.');
                return{ok:false,qIdx:i,tab:'EN',firstEl:tfGrid};
            }
        }

        /* ── Multiselect ─── */
        if(qType==='Multiselect'){
            /* Required option text A, B, C */
            switchTab('EN');
            var msGrid=$qs('#sectionMS .qb-opts');
            var msTxEN=document.querySelectorAll('#sectionMS .ms-text');
            var emptyMsEN=[];
            [0,1,2].forEach(function(j){if(msTxEN[j]&&!msTxEN[j].value.trim())emptyMsEN.push(msTxEN[j]);});
            if(emptyMsEN.length){qbSetGridErr(msGrid,emptyMsEN);return{ok:false,qIdx:i,tab:'EN',firstEl:emptyMsEN[0]};}
            switchTab('BM');
            var msTxBM=document.querySelectorAll('#sectionMS .ms-text');
            var emptyMsBM=[];
            [0,1,2].forEach(function(j){if(msTxBM[j]&&!msTxBM[j].value.trim())emptyMsBM.push(msTxBM[j]);});
            if(emptyMsBM.length){qbSetGridErr($qs('#sectionMS .qb-opts'),emptyMsBM);return{ok:false,qIdx:i,tab:'BM',firstEl:emptyMsBM[0]};}
            /* Correct answer count */
            switchTab('EN');
            var chkLetters=(q.msChk||'').split(',').filter(function(l){return l.trim();});
            if(chkLetters.length===0){
                qbSetGridErr($qs('#sectionMS .qb-opts'),[],'Please select the correct answers.');
                return{ok:false,qIdx:i,tab:'EN',firstEl:$qs('#sectionMS .qb-opts')};
            }
            if(chkLetters.length===1){
                qbSetGridErr($qs('#sectionMS .qb-opts'),[],'Please select at least 2 correct answers.');
                return{ok:false,qIdx:i,tab:'EN',firstEl:$qs('#sectionMS .qb-opts')};
            }
            /* Ensure each selected letter points to a non-empty EN option */
            var msMap={'A':0,'B':1,'C':2,'D':3};
            var msTxCheck=document.querySelectorAll('#sectionMS .ms-text');
            var badChk=[];
            chkLetters.forEach(function(l){
                var j=msMap[l];
                if(j!==undefined&&msTxCheck[j]&&!msTxCheck[j].value.trim())badChk.push(msTxCheck[j]);
            });
            if(badChk.length){qbSetGridErr($qs('#sectionMS .qb-opts'),badChk);return{ok:false,qIdx:i,tab:'EN',firstEl:badChk[0]};}
        }

        /* ── Drag & Drop ─── */
        if(qType==='Drag & Drop'){
            var blankRe=/\[Blank \d\]/g;
            var enC=((q.qEN||'').match(blankRe)||[]).length;
            var bmC=((q.qBM||'').match(blankRe)||[]).length;

            /* EN/BM blank count mismatch */
            if(enC!==bmC){
                switchTab('EN');
                var tqMismatch=$id(SRV.txtQ);
                qbSetErr(tqMismatch,'The number of blanks in English and Bahasa Melayu must match.');
                return{ok:false,qIdx:i,tab:'EN',firstEl:tqMismatch};
            }

            /* At least 1 blank required */
            if(enC<1){
                switchTab('EN');
                var tqBlank=$id(SRV.txtQ);
                qbSetErr(tqBlank,'At least one blank is required.');
                return{ok:false,qIdx:i,tab:'EN',firstEl:tqBlank};
            }

            /* EN word bank: min 2 */
            switchTab('EN');
            var fibGridEN=$qs('#sectionFIB .qb-fib-words');
            var enW=(q.fibEN||[]).filter(function(s){return s&&s.trim();});
            if(enW.length<2){
                var fibInEN=document.querySelectorAll('#sectionFIB .fib-word-input');
                var emptyFibEN=Array.prototype.slice.call(fibInEN).filter(function(el){return!el.value.trim();});
                qbSetGridErr(fibGridEN,emptyFibEN.slice(0,Math.max(1,2-enW.length)),
                    'At least two answer options are required.');
                return{ok:false,qIdx:i,tab:'EN',firstEl:emptyFibEN[0]||fibGridEN};
            }

            /* BM word bank: min 2 */
            switchTab('BM');
            var fibGridBM=$qs('#sectionFIB .qb-fib-words');
            var bmW=(q.fibBM||[]).filter(function(s){return s&&s.trim();});
            if(bmW.length<2){
                var fibInBM=document.querySelectorAll('#sectionFIB .fib-word-input');
                var emptyFibBM=Array.prototype.slice.call(fibInBM).filter(function(el){return!el.value.trim();});
                qbSetGridErr(fibGridBM,emptyFibBM.slice(0,Math.max(1,2-bmW.length)),
                    'At least two answer options are required.');
                return{ok:false,qIdx:i,tab:'BM',firstEl:emptyFibBM[0]||fibGridBM};
            }

            /* EN mapping: count must equal blank count */
            switchTab('EN');
            var enMapped=(q.fibMapEN||[]).filter(function(s){return s&&s.trim();});
            if(enMapped.length===0){
                var mapSectionEN=$id('fibMappingSection');
                qbSetGridErr(mapSectionEN||$qs('#sectionFIB .qb-fib-words'),[],
                    'Please select the correct mapping order.');
                return{ok:false,qIdx:i,tab:'EN',firstEl:mapSectionEN};
            }
            if(enMapped.length!==enC){
                var mapSectionEN2=$id('fibMappingSection');
                qbSetGridErr(mapSectionEN2||$qs('#sectionFIB .qb-fib-words'),[],
                    'The number of mappings must match the number of blanks.');
                return{ok:false,qIdx:i,tab:'EN',firstEl:mapSectionEN2};
            }

            /* BM mapping: count must equal blank count */
            switchTab('BM');
            var bmMapped=(q.fibMapBM||[]).filter(function(s){return s&&s.trim();});
            if(bmMapped.length===0){
                var mapSectionBM=$id('fibMappingSection');
                qbSetGridErr(mapSectionBM||$qs('#sectionFIB .qb-fib-words'),[],
                    'Please select the correct mapping order.');
                return{ok:false,qIdx:i,tab:'BM',firstEl:mapSectionBM};
            }
            if(bmMapped.length!==bmC){
                var mapSectionBM2=$id('fibMappingSection');
                qbSetGridErr(mapSectionBM2||$qs('#sectionFIB .qb-fib-words'),[],
                    'The number of mappings must match the number of blanks.');
                return{ok:false,qIdx:i,tab:'BM',firstEl:mapSectionBM2};
            }
        }
    }
    return{ok:true};
}

/* ── Validate then flush ──────────────────────────────────── */
function validateFibBlanksAndFlush(){
    captureCurrentFields();
    qbClearAllErrors();
    var result=validateAllQuestions();
    if(!result.ok){
        navGoTo(result.qIdx);
        switchTab(result.tab);
        if(result.firstEl){
            try{result.firstEl.scrollIntoView({behavior:'smooth',block:'center'});}catch(e){}
            try{result.firstEl.focus();}catch(e){}
        }
        return false;
    }
    flushToServer();
    return true;
}

function flushToServer(){
    captureCurrentFields();
    /* Sync Multiselect / FIB text into the server txtOpt* controls for the active tab */
    var dt=$id(SRV.ddlType);
    if(dt){
        var isEN=(window.__CT==='EN');
        var q=window.__QD[window.__CI];
        if(q&&dt.value==='Multiselect'){
            var s=function(id,v){var e=$id(id);if(e)e.value=v||'';};
            s(SRV.txtA,isEN?q.msAEN:q.msABM);s(SRV.txtB,isEN?q.msBEN:q.msBBM);
            s(SRV.txtC,isEN?q.msCEN:q.msCBM);s(SRV.txtD,isEN?q.msDEN:q.msDBM);
        }
        if(q&&dt.value==='Drag & Drop'){
            var fibArr=isEN?(q.fibEN||[]):(q.fibBM||[]);
            var fibIds=[SRV.txtA,SRV.txtB,SRV.txtC,SRV.txtD];
            fibIds.forEach(function(id,i){var e=$id(id);if(e)e.value=fibArr[i]||'';});
        }
    }
    var hj=$id(SRV.hidJson);if(hj)hj.value=JSON.stringify(window.__QD);
    var hi=$id(SRV.hidIdx);if(hi)hi.value=window.__CI;
    var ht=$id(SRV.hidTab);if(ht)ht.value=window.__CT;
}

function showToast(m){var c=$id('qbToast'),t=document.createElement('div');t.className='qb-toast';t.innerHTML='<i class="bi bi-check-circle-fill"></i> '+m;c.appendChild(t);setTimeout(function(){t.style.opacity='0';},3e3);setTimeout(function(){t.remove();},3500);}

function switchQuestionType(){
    var sel=$id(SRV.ddlType);if(!sel)return;var v=sel.value;
    $id('sectionMCQ').style.display=(v==='MCQ')?'block':'none';
    $id('sectionTF').style.display=(v==='True/False')?'block':'none';
    $id('sectionMS').style.display=(v==='Multiselect')?'block':'none';
    $id('sectionFIB').style.display=(v==='Drag & Drop')?'block':'none';
}
function updateAnswerCards(){
    document.querySelectorAll('#sectionMCQ .qb-opt').forEach(function(o){o.classList.remove('correct');});
    document.querySelectorAll('#sectionMCQ .qb-opt input[type="radio"]').forEach(function(r){if(r.checked)r.closest('.qb-opt').classList.add('correct');});
}
function updateTFCards(){
    document.querySelectorAll('.qb-tf-card').forEach(function(c){c.classList.remove('selected');});
    document.querySelectorAll('.qb-tf-card input[type="radio"]').forEach(function(r){if(r.checked)r.closest('.qb-tf-card').classList.add('selected');});
}
function updateMSCards(){
    var count=0;
    document.querySelectorAll('.qb-ms-opt').forEach(function(o){var cb=o.querySelector('.ms-check');if(cb&&cb.checked){o.classList.add('selected');count++;}else o.classList.remove('selected');});
    var el=$id('msCount');if(el)el.textContent=count+' <%: T("selected","dipilih") %>';
}
function addBlank(){
    var btn=$id('btnAddBlank');if(btn.classList.contains('disabled'))return;
    var ta=$id(SRV.txtQ);if(!ta)return;
    var text=ta.value,count=(text.match(/\[Blank \d\]/g)||[]).length;
    if(count>=4)return;var ins='[Blank '+(count+1)+']';
    var s=ta.selectionStart,e=ta.selectionEnd;
    ta.value=text.substring(0,s)+ins+text.substring(e);
    ta.selectionStart=ta.selectionEnd=s+ins.length;ta.focus();updateFibUI();
}
function onFibWordChange(){updateFibMappings();updateFibPreview();}
function updateFibUI(){
    var ta=$id(SRV.txtQ);if(!ta)return;
    var blanks=(ta.value.match(/\[Blank \d\]/g)||[]),count=blanks.length;
    var numEl=$id('blankNum');if(numEl)numEl.textContent=count;
    var ctr=$qs('.fib-counter');if(ctr)ctr.classList.toggle('full',count>=4);
    var btn=$id('btnAddBlank');
    if(btn){if(count>=4){btn.classList.add('disabled');$id('blankWarning').style.display='flex';}else{btn.classList.remove('disabled');$id('blankWarning').style.display='none';}}
    var ms=$id('fibMappingSection'),ps=$id('fibPreviewSection');
    if(count>0){ms.style.display='block';ps.style.display='block';updateFibMappings();updateFibPreview();}
    else{ms.style.display='none';ps.style.display='none';}
}
function updateFibMappings(){
    var ta=$id(SRV.txtQ);if(!ta)return;
    var blanks=(ta.value.match(/\[Blank \d\]/g)||[]),words=[];
    document.querySelectorAll('.fib-word-input').forEach(function(i){if(i.value.trim())words.push(i.value.trim());});
    var container=$id('fibMappings');
    /* Use the stored index map for the current language — not the live DOM — so EN and BM are independent */
    var q=window.__QD[window.__CI];
    var storedIdx=(window.__CT==='EN')?((q&&q.fibIdxEN)||{}):((q&&q.fibIdxBM)||{});
    var html='';
    blanks.forEach(function(b){
        var selectedVal=storedIdx[b]||'';
        var opts='<option value="">-- <%: T("Select word","Pilih perkataan") %> --</option>';
        words.forEach(function(w,wi){opts+='<option value="'+(wi+1)+'"'+(selectedVal===''+(wi+1)?' selected':'')+'>'+w+'</option>';});
        html+='<div class="qb-fib-map-row'+(selectedVal?' valid':'')+'"><span class="qb-fib-map-label">'+b+'</span><span class="qb-fib-map-arrow"><i class="bi bi-arrow-right"></i></span><select class="qb-fib-map-select fib-map-dd" data-blank="'+b+'" onchange="validateFibMapping()">'+opts+'</select><span class="qb-fib-map-check"><i class="bi bi-check-circle-fill"></i></span></div>';
    });
    container.innerHTML=html;updateFibPreview();
}
function validateFibMapping(){
    var selects=document.querySelectorAll('.fib-map-dd'),vals=[],dup=false;
    selects.forEach(function(s){var row=s.closest('.qb-fib-map-row');row.classList.remove('invalid');s.classList.remove('invalid');if(s.value){if(vals.indexOf(s.value)>-1){dup=true;row.classList.add('invalid');s.classList.add('invalid');}else row.classList.add('valid');vals.push(s.value);}else row.classList.remove('valid');});
    $id('fibMappingError').style.display=dup?'flex':'none';
}
function updateFibPreview(){
    var ta=$id(SRV.txtQ);if(!ta)return;
    var text=ta.value||'',html=text.replace(/\[Blank \d\]/g,'<span class="fib-blank">_____</span>');
    $id('fibPreviewText').innerHTML=html||'<em style="color:var(--tc-muted);"><%: T("Type your question with blanks...","Taip soalan anda dengan tempat kosong...") %></em>';
    var words=[];document.querySelectorAll('.fib-word-input').forEach(function(i){if(i.value.trim())words.push(i.value.trim());});
    $id('fibPreviewWords').innerHTML=words.length?words.map(function(w){return'<span class="qb-fib-chip">'+w+'</span>';}).join(''):'<em style="font-size:.78rem;color:var(--tc-muted);"><%: T("Add words to Word Bank above","Tambah perkataan ke Bank Perkataan di atas") %></em>';
}
function updateCharCounts(){
    var q=$id(SRV.txtQ),ce=$id(SRV.txtCE),we=$id(SRV.txtWE);
    if(q)$id('qCharCount').textContent=q.value.length+' / 500';
    if(ce)$id('ceCharCount').textContent=ce.value.length+' / 500';
    if(we)$id('weCharCount').textContent=we.value.length+' / 500';
}
function updateProgress(){
    var done=window.__QD.filter(function(q){return q.saved;}).length,total=window.__QD.length;
    var pct=total>0?Math.round(done/total*100):0;
    var fill=$id('progressFill'),txt=$id('progressText');
    if(fill)fill.style.width=pct+'%';
    if(txt)txt.textContent=done+' / '+total+' <%: T("Questions Saved","Soalan Disimpan") %>';
    var nc=$id('navCount');if(nc)nc.textContent=total;
    document.querySelectorAll('.qb-nav-del').forEach(function(b){total<=1?b.classList.add('disabled'):b.classList.remove('disabled');});
}

/* ── Delete modal ────────────────────────────────────────── */
var _pendingDeleteIndex=-1;

function confirmDeleteQuestion(idx){
    if(window.__QD.length<=1)return; /* never delete the last question */
    _pendingDeleteIndex=idx;
    var msg=$id('qbDelMsg');
    if(msg)msg.textContent='Question '+(idx+1)+' will be permanently removed. This action cannot be undone.';
    $id('qbDelOverlay').classList.add('open');
}
function closeDeleteModal(e){
    if(e&&e.target!==$id('qbDelOverlay'))return;
    $id('qbDelOverlay').classList.remove('open');_pendingDeleteIndex=-1;
}
function executeDelete(){
    if(_pendingDeleteIndex<0)return;
    var delIdx=_pendingDeleteIndex;
    $id('qbDelOverlay').classList.remove('open');
    _pendingDeleteIndex=-1;

    if(window.__QD.length<=1)return; /* safety guard */

    /* 1. Capture the currently displayed question BEFORE touching anything */
    captureCurrentFields();

    /* 2. Remove the target question from the store by exact index */
    window.__QD.splice(delIdx,1);

    /* 3. Work out which question to show next:
          - if delIdx < length → show delIdx (now the question that was after it)
          - otherwise show the new last question                                  */
    var nextIdx=delIdx<window.__QD.length ? delIdx : window.__QD.length-1;
    window.__CI=nextIdx;

    /* 4. Populate the editor with the question we're switching to */
    var q=window.__QD[nextIdx];
    populateFields(q,window.__CT);
    updateLabels(window.__CT);

    /* 5. Update question number header */
    var qn=$qs('[id$="litQNum"]');if(qn)qn.textContent=nextIdx+1;

    /* 6. Rebuild the nav list (re-numbers sequentially from the new __QD) */
    rebuildNavList();

    /* 7. Update prev/next button states */
    var bp=$qs('[id$="btnPrev"]'),bn=$qs('[id$="btnNext"]');
    if(bp)bp.disabled=(nextIdx===0);
    if(bn)bn.disabled=(nextIdx>=window.__QD.length-1);

    /* 8. Sync progress bar */
    updateProgress();

    /* 9. Keep hidden fields up to date so the next Save/Submit postback is aware */
    var hIdx=$id(SRV.hidIdx);if(hIdx)hIdx.value=nextIdx;
    var hTab=$id(SRV.hidTab);if(hTab)hTab.value=window.__CT;
    /* Write the updated store into the JSON hidden field so the server
       rebuilds Questions from the correct post-delete state on next postback */
    var hJson=$id(SRV.hidJson);if(hJson)hJson.value=JSON.stringify(window.__QD);
}

/* ── Image upload — per-question, stored in __QD[idx].img ─── */
function handleQImgUpload(input){
    if(!input.files||!input.files[0])return;
    var file=input.files[0];
    if(file.size>5*1024*1024){alert('<%: T("Image must be under 5 MB.","Imej mesti di bawah 5 MB.") %>');input.value='';return;}
    /* Store just the filename in the question store — the server FileUpload saves the file */
    var fileName=file.name;
    if(window.__QD[window.__CI])window.__QD[window.__CI].img=fileName;
    /* Copy the selected file to the server-side FileUpload control so it uploads on submit */
    try{
        var dt=new DataTransfer();dt.items.add(file);
        var fu=$id(SRV.fuImg);if(fu)fu.files=dt.files;
    }catch(e){/* DataTransfer not supported in all browsers — file still previews */}
    /* Also write filename into the hidden server field for fallback */
    var hf=$id(SRV.hidImgFile);if(hf)hf.value=fileName;
    /* Show preview using data-URL (display only) */
    var reader=new FileReader();
    reader.onload=function(ev){
        $id('qbImgPreviewSrc').src=ev.target.result;
        $id('qbImgUploadLabel').style.display='none';
        $id('qbImgPreview').style.display='block';
    };
    reader.readAsDataURL(file);
}
function removeQImg(){
    /* clear only this question's image */
    if(window.__QD[window.__CI])window.__QD[window.__CI].img='';
    var hf=$id(SRV.hidImgFile);if(hf)hf.value='';
    $id('qbImgInput').value='';$id('qbImgPreviewSrc').src='';
    $id('qbImgPreview').style.display='none';$id('qbImgUploadLabel').style.display='flex';
}

/* ── Add question client-side (no postback) ──────────────── */
function clientAddQuestion(){
    captureCurrentFields();
    window.__QD.push(emptyQ());
    var newIdx=window.__QD.length-1;
    window.__CI=newIdx;
    populateFields(window.__QD[newIdx],window.__CT);
    updateLabels(window.__CT);
    /* Rebuild the nav list in-place */
    rebuildNavList();
    /* Update header question number */
    var qn=$qs('[id$="litQNum"]');if(qn)qn.textContent=newIdx+1;
    /* Update prev/next states */
    var bp=$qs('[id$="btnPrev"]'),bn=$qs('[id$="btnNext"]');
    if(bp)bp.disabled=(newIdx===0);
    if(bn)bn.disabled=(newIdx>=window.__QD.length-1);
    updateProgress();
}

/* Rebuild the left nav list entirely from __QD (no server call) */
function rebuildNavList(){
    var list=$qs('.qb-nav-list');if(!list)return;
    list.innerHTML='';
    window.__QD.forEach(function(q,i){
        var row=document.createElement('div');
        row.className='qb-nav-row';
        /* nav item */
        var btn=document.createElement('button');
        btn.type='button';
        btn.className='qb-nav-item'+(i===window.__CI?' active':'')+(q.saved?' done':'');
        btn.dataset.qidx=i;
        btn.innerHTML='<span class="qb-nav-badge">'+(i+1)+'</span><span>Q'+(i+1)+'</span><i class="bi bi-check-circle-fill qb-nav-check"></i>';
        btn.addEventListener('click',function(e){
            e.preventDefault();e.stopPropagation();
            navGoTo(parseInt(btn.dataset.qidx,10));
        });
        /* delete button */
        var del=document.createElement('button');
        del.type='button';
        del.className='qb-nav-del'+(window.__QD.length<=1?' disabled':'');
        del.dataset.idx=i;
        del.innerHTML='<i class="bi bi-trash3"></i>';
        del.title='Delete question';
        del.addEventListener('click',function(){confirmDeleteQuestion(parseInt(del.dataset.idx,10));});
        row.appendChild(btn);row.appendChild(del);
        list.appendChild(row);
    });
    var nc=$id('navCount');if(nc)nc.textContent=window.__QD.length;
}

/* ── Bootstrap ────────────────────────────────────────────── */
function wireNavItems(){
    /* Wire server-rendered nav items (initial load / after postback) */
    document.querySelectorAll('.qb-nav-item').forEach(function(el){
        /* Remove any old listener by replacing with a clone */
        var clone=el.cloneNode(true);
        el.parentNode.replaceChild(clone,el);
        clone.addEventListener('click',function(e){
            e.preventDefault();e.stopPropagation();
            var idx=parseInt(clone.dataset.qidx,10);
            if(!isNaN(idx))navGoTo(idx);
        });
    });
}

window.addEventListener('load',function(){
    var h=$id(SRV.toast);if(h&&h.value){showToast(h.value);h.value='';}

    /* Show submit-success modal if the server flagged it */
    var hSuccess=$id('<%=hidSubmitSuccess.ClientID%>');
    if(hSuccess&&hSuccess.value==='1'){
        hSuccess.value='';
        var overlay=$id('qbSuccessOverlay');
        if(overlay)overlay.classList.add('open');
    }

    var ddl=$id(SRV.ddlType);
    if(ddl){ddl.addEventListener('change',switchQuestionType);switchQuestionType();}

    document.querySelectorAll('#sectionMCQ .qb-opt').forEach(function(card){
        card.addEventListener('click',function(e){
            if(e.target.tagName==='INPUT'&&e.target.type==='text')return;
            if(e.target.tagName==='TEXTAREA')return;
            var radio=card.querySelector('input[type="radio"]');
            if(radio){radio.checked=true;updateAnswerCards();}
            if(window.__QD[window.__CI]&&radio)window.__QD[window.__CI].correct=radio.value;
        });
        card.style.cursor='pointer';
    });
    document.querySelectorAll('#sectionMS .qb-ms-opt').forEach(function(card){
        card.addEventListener('click',function(e){
            if(e.target.tagName==='INPUT'&&e.target.type==='text')return;
            var cb=card.querySelector('.ms-check');
            if(cb){cb.checked=!cb.checked;updateMSCards();}
        });
        card.style.cursor='pointer';
    });
    document.querySelectorAll('#sectionMCQ .qb-opt input[type="radio"]').forEach(function(r){r.addEventListener('change',updateAnswerCards);});
    document.querySelectorAll('textarea').forEach(function(ta){ta.addEventListener('input',function(){updateCharCounts();updateFibUI();});});

    var form=document.querySelector('form');
    if(form)form.addEventListener('submit',flushToServer);

    var delBtn=$id('qbDelConfirm');
    if(delBtn)delBtn.addEventListener('click',executeDelete);

    document.addEventListener('keydown',function(e){
        if(e.key==='Escape'&&$id('qbDelOverlay').classList.contains('open'))closeDeleteModal();
    });

    /* Wire nav items (server-rendered on load/postback) */
    wireNavItems();

    updateAnswerCards();updateProgress();updateCharCounts();updateFibUI();updateLabels(window.__CT);

    qbWireAutoClears();

    var bp=$qs('[id$="btnPrev"]'),bn=$qs('[id$="btnNext"]');
    if(bp)bp.disabled=(window.__CI===0);
    if(bn)bn.disabled=(window.__CI>=window.__QD.length-1);
});
</script>
</asp:Content>

