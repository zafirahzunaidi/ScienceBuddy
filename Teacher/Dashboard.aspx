<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs"
    Inherits="ScienceBuddy.Teacher.Dashboard" MasterPageFile="~/Site.Master"
    Title="Teacher Dashboard" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ── Teacher Dashboard – Purple Theme ── */
:root {
    --tc-primary: #6C63FF;
    --tc-secondary: #8B5CF6;
    --tc-hover: #5A52E0;
    --tc-light-bg: #F5F3FF;
    --tc-card-bg: #FFFFFF;
    --tc-border: #E5E7EB;
    --tc-text: #374151;
    --tc-muted: #6B7280;
    --tc-info: #3B82F6;
    --tc-warning: #F59E0B;
    --tc-success: #10B981;
    --tc-error: #EF4444;
}

/* Hero */
.td-hero {
    background: linear-gradient(135deg, #4338CA 0%, #6D28D9 50%, #9333EA 100%);
    border-radius: 28px; padding: 3rem 3.5rem; color: #fff;
    display: flex; align-items: center; justify-content: space-between;
    position: relative; overflow: hidden;
    margin-top: .5rem; margin-bottom: 2rem;
    box-shadow: 0 18px 50px rgba(67,56,202,.22), 0 4px 14px rgba(109,40,217,.10);
    min-height: 310px; max-height: 340px;
}
/* Decorative background shapes */
.td-hero::before {
    content: ''; position: absolute; width: 360px; height: 360px; border-radius: 50%;
    background: radial-gradient(circle, rgba(196,181,253,.12) 0%, transparent 70%);
    top: -120px; left: -100px; pointer-events: none;
}
.td-hero::after {
    content: ''; position: absolute; width: 220px; height: 220px; border-radius: 50%;
    background: radial-gradient(circle, rgba(236,72,153,.07) 0%, transparent 70%);
    bottom: -70px; right: 30%; pointer-events: none;
}
.td-hero-body { position: relative; z-index: 2; max-width: 520px; flex: 1; }
.td-hero-eyebrow {
    font-size: .72rem; font-weight: 700; letter-spacing: 2.5px;
    text-transform: uppercase; color: #DDD6FE; margin-bottom: 12px;
    display: inline-flex; align-items: center; gap: 6px;
}
.td-hero-eyebrow::before {
    content: ''; width: 8px; height: 8px; border-radius: 50%;
    background: #A78BFA; display: inline-block;
    box-shadow: 0 0 8px rgba(167,139,250,.6);
}
.td-hero-title {
    font-family: var(--font-primary); font-size: 2.1rem; font-weight: 800;
    line-height: 1.25; margin-bottom: .6rem; color: #FFFFFF;
    word-break: break-word; overflow-wrap: anywhere;
}
.td-hero-sub { font-size: .95rem; color: #EDE9FE; line-height: 1.7; margin-bottom: 1.5rem; }
/* Hero Button */
.td-hero-actions { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
.td-hero-btn-topics {
    display: inline-flex; align-items: center; gap: 8px;
    padding: .7rem 1.4rem; border-radius: 12px;
    background: #FFFFFF; color: #5B21B6;
    font-size: .875rem; font-weight: 700; text-decoration: none;
    box-shadow: 0 4px 14px rgba(0,0,0,.10);
    border: none; cursor: pointer;
    transition: transform .22s ease, box-shadow .22s ease, background .2s;
}
.td-hero-btn-topics:hover {
    transform: translateY(-3px) scale(1.02);
    box-shadow: 0 8px 26px rgba(91,33,182,.18);
    background: #F5F3FF;
}
.td-hero-btn-topics:active { transform: translateY(0) scale(1); }
/* Illustration on the right */
.td-hero-illustration {
    position: relative; z-index: 2; flex-shrink: 0;
    display: flex; align-items: flex-end; justify-content: center;
    width: 38%; align-self: stretch;
}
.td-hero-mascot-wrap {
    position: relative; display: flex; align-items: flex-end; justify-content: center;
    width: 100%; height: 100%;
    animation: tdHeroFloat 4s ease-in-out infinite;
}
.td-hero-mascot-wrap img {
    height: 180%; max-height: 620px; width: auto; object-fit: contain;
    object-position: bottom center;
    margin-bottom: -3rem;
}
/* Ground shadow beneath the desk */
.td-hero-ground-shadow {
    position: absolute; bottom: -8px; left: 50%; transform: translateX(-50%);
    width: 70%; height: 18px; border-radius: 50%;
    background: radial-gradient(ellipse, rgba(30,10,60,.25) 0%, transparent 70%);
    filter: blur(4px); pointer-events: none;
    animation: tdShadowPulse 4s ease-in-out infinite;
}
/* Float animation */
@keyframes tdHeroFloat {
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(-8px); }
}
@keyframes tdShadowPulse {
    0%, 100% { opacity: 1; transform: translateX(-50%) scaleX(1); }
    50% { opacity: .7; transform: translateX(-50%) scaleX(.92); }
}
/* Decorative light bulb glow */
.td-hero-decor-bulb {
    position: absolute; top: 8%; right: 28%; width: 22px; height: 22px;
    border-radius: 50%; pointer-events: none; z-index: 3;
    background: radial-gradient(circle, rgba(253,224,71,.35) 0%, transparent 70%);
    animation: tdBulbGlow 3s ease-in-out infinite;
}
@keyframes tdBulbGlow {
    0%, 100% { opacity: .6; transform: scale(1); }
    50% { opacity: 1; transform: scale(1.2); }
}
/* Decorative heart bubble */
.td-hero-decor-heart {
    position: absolute; top: 14%; right: 12%; width: 12px; height: 12px;
    pointer-events: none; z-index: 3; opacity: .5;
    animation: tdHeartFloat 5s ease-in-out infinite;
}
.td-hero-decor-heart::before {
    content: '♥'; font-size: 12px; color: rgba(244,114,182,.6);
}
@keyframes tdHeartFloat {
    0%, 100% { transform: translateY(0); opacity: .5; }
    50% { transform: translateY(-5px); opacity: .8; }
}
/* Right-side decoration: shapes */
.td-hero-decor {
    position: absolute; top: 0; right: 0; bottom: 0; width: 55%;
    pointer-events: none; z-index: 1;
}
.td-hero-decor-circle1 {
    position: absolute; width: 180px; height: 180px; border-radius: 50%;
    border: 1.5px solid rgba(255,255,255,.07);
    top: 8%; right: 4%;
    animation: tdCirclePulse 6s ease-in-out infinite;
}
.td-hero-decor-circle2 {
    position: absolute; width: 100px; height: 100px; border-radius: 50%;
    background: radial-gradient(circle, rgba(167,139,250,.10) 0%, transparent 70%);
    bottom: 12%; right: 28%;
}
.td-hero-decor-circle3 {
    position: absolute; width: 60px; height: 60px; border-radius: 50%;
    border: 1.5px solid rgba(255,255,255,.05);
    top: 58%; right: 2%;
    animation: tdCirclePulse 8s ease-in-out infinite 2s;
}
@keyframes tdCirclePulse {
    0%, 100% { opacity: 1; }
    50% { opacity: .5; }
}
.td-hero-decor-dots {
    position: absolute; top: 15%; right: 38%; width: 70px; height: 70px;
    background-image: radial-gradient(rgba(255,255,255,.08) 1.5px, transparent 1.5px);
    background-size: 12px 12px;
}
.td-hero-decor-curve {
    position: absolute; bottom: 22%; left: 28%; width: 120px; height: 60px;
    border: 1.5px solid rgba(255,255,255,.04);
    border-radius: 0 0 60px 60px; border-top: none;
}
.td-hero-decor-glow {
    position: absolute; top: -30px; right: 15%; width: 160px; height: 160px;
    border-radius: 50%;
    background: radial-gradient(circle, rgba(236,72,153,.05) 0%, transparent 60%);
}
/* Reduced motion */
@media (prefers-reduced-motion: reduce) {
    .td-hero-mascot-wrap { animation: none; }
    .td-hero-ground-shadow { animation: none; opacity: 1; }
    .td-hero-decor-bulb { animation: none; opacity: .6; }
    .td-hero-decor-heart { animation: none; opacity: .5; }
    .td-hero-decor-circle1, .td-hero-decor-circle3 { animation: none; }
}

/* ── Available Topics Modal ── */
.td-topics-overlay {
    display: none; position: fixed; inset: 0; z-index: 9999;
    background: rgba(30,15,60,.5); backdrop-filter: blur(4px);
    align-items: center; justify-content: center; padding: 1.5rem;
    opacity: 0; transition: opacity .25s ease;
}
.td-topics-overlay.open { display: flex; opacity: 1; }
.td-topics-modal {
    background: #FFFFFF; border-radius: 26px; width: 100%; max-width: 720px;
    max-height: 82vh; display: flex; flex-direction: column;
    box-shadow: 0 8px 24px rgba(99,72,210,.08), 0 24px 64px rgba(30,15,60,.16), 0 0 80px rgba(139,92,246,.08);
    animation: tdModalIn .28s cubic-bezier(.22,1,.36,1);
    position: relative; overflow: hidden;
}
@keyframes tdModalIn { from { opacity: 0; transform: translateY(12px) scale(.96); } to { opacity: 1; transform: translateY(0) scale(1); } }
/* Modal decorative elements */
.td-topics-modal::before {
    content: ''; position: absolute; top: -40px; right: -40px;
    width: 140px; height: 140px; border-radius: 50%;
    background: radial-gradient(circle, rgba(196,181,253,.15) 0%, transparent 70%);
    pointer-events: none; z-index: 0;
}
.td-topics-modal::after {
    content: ''; position: absolute; bottom: -30px; left: -30px;
    width: 100px; height: 100px; border-radius: 50%;
    background: radial-gradient(circle, rgba(236,72,153,.06) 0%, transparent 70%);
    pointer-events: none; z-index: 0;
}
/* Header */
.td-topics-header {
    display: flex; align-items: flex-start; justify-content: space-between;
    padding: 1.5rem 1.75rem 1.25rem; border-bottom: 1px solid #F3F0FF;
    position: relative; z-index: 1;
    background: linear-gradient(180deg, #FDFCFF 0%, #FFFFFF 100%);
}
.td-topics-header-left { display: flex; align-items: flex-start; gap: 14px; }
.td-topics-header-ico {
    width: 46px; height: 46px; border-radius: 14px; flex-shrink: 0;
    background: linear-gradient(135deg, #EDE9FE, #DDD6FE);
    display: flex; align-items: center; justify-content: center;
    font-size: 1.2rem; color: #7C3AED;
    box-shadow: 0 2px 8px rgba(124,58,237,.10);
}
.td-topics-header-text { display: flex; flex-direction: column; gap: 3px; }
.td-topics-title {
    font-size: 1.2rem; font-weight: 800; color: #1E1B4B;
    display: flex; align-items: center; gap: 8px; line-height: 1.3;
}
.td-topics-title-sparkle {
    display: inline-flex; color: #A78BFA; font-size: .7rem; opacity: .7;
    animation: tdSparkle 2s ease-in-out infinite;
}
@keyframes tdSparkle { 0%,100%{ opacity:.5; transform:scale(1); } 50%{ opacity:1; transform:scale(1.2); } }
.td-topics-subtitle {
    font-size: .8rem; color: #6B7280; font-weight: 500; line-height: 1.4;
}
.td-topics-close {
    width: 36px; height: 36px; border-radius: 50%; border: none;
    background: #F5F3FF; color: #7C3AED; font-size: 1rem;
    cursor: pointer; display: flex; align-items: center; justify-content: center;
    transition: background .15s, transform .15s, box-shadow .15s;
    flex-shrink: 0; margin-top: 2px;
}
.td-topics-close:hover { background: #EDE9FE; transform: scale(1.08); box-shadow: 0 2px 8px rgba(124,58,237,.12); }
/* Search */
.td-topics-search {
    padding: 1rem 1.75rem; border-bottom: 1px solid #F5F3FF;
    position: relative; z-index: 1;
}
.td-topics-search input {
    width: 100%; padding: .75rem 1.1rem .75rem 2.8rem; border-radius: 14px;
    border: 1.5px solid #E9E5F5; font-size: .88rem; color: #1E1B4B;
    background: #F9F8FE url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' fill='%237C3AED' viewBox='0 0 16 16'%3E%3Cpath d='M11.742 10.344a6.5 6.5 0 1 0-1.397 1.398h-.001l3.85 3.85a1 1 0 0 0 1.415-1.414l-3.85-3.85zm-5.242.656a5 5 0 1 1 0-10 5 5 0 0 1 0 10z'/%3E%3C/svg%3E") no-repeat 1rem center;
    transition: border-color .2s, box-shadow .2s, background .2s;
}
.td-topics-search input:focus {
    outline: none; border-color: #7C3AED;
    box-shadow: 0 0 0 3px rgba(124,58,237,.08);
    background-color: #FFFFFF;
}
.td-topics-search input::placeholder { color: #A1A1AA; }
/* Body */
.td-topics-body {
    flex: 1; overflow-y: auto; padding: 1.25rem 1.75rem 2rem;
    position: relative; z-index: 1;
}
.td-topics-body::-webkit-scrollbar { width: 5px; }
.td-topics-body::-webkit-scrollbar-track { background: transparent; }
.td-topics-body::-webkit-scrollbar-thumb { background: #DDD6FE; border-radius: 4px; }
.td-topics-body::-webkit-scrollbar-thumb:hover { background: #C4B5FD; }
/* Level accordion */
.td-level-item { margin-bottom: .75rem; }
.td-level-header {
    display: flex; align-items: center; gap: 10px; padding: .85rem 1.1rem;
    border-radius: 14px; cursor: pointer; user-select: none;
    transition: transform .15s, box-shadow .15s;
    border: 1.5px solid transparent;
}
.td-level-header:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(0,0,0,.04); }
/* Level colour variants */
.td-level-header.td-lvl-0 { background: linear-gradient(135deg, #F5F3FF, #EDE9FE); border-color: #DDD6FE; }
.td-level-header.td-lvl-1 { background: linear-gradient(135deg, #ECFDF5, #D1FAE5); border-color: #A7F3D0; }
.td-level-header.td-lvl-2 { background: linear-gradient(135deg, #FFF7ED, #FED7AA); border-color: #FDBA74; }
.td-level-header.td-lvl-3 { background: linear-gradient(135deg, #EFF6FF, #DBEAFE); border-color: #BFDBFE; }
.td-level-header.td-lvl-4 { background: linear-gradient(135deg, #FDF2F8, #FCE7F3); border-color: #FBCFE8; }
.td-level-header .td-level-ico {
    width: 32px; height: 32px; border-radius: 10px; flex-shrink: 0;
    display: flex; align-items: center; justify-content: center;
    font-size: .9rem; background: rgba(255,255,255,.7); backdrop-filter: blur(2px);
}
.td-lvl-0 .td-level-ico { color: #7C3AED; }
.td-lvl-1 .td-level-ico { color: #059669; }
.td-lvl-2 .td-level-ico { color: #EA580C; }
.td-lvl-3 .td-level-ico { color: #2563EB; }
.td-lvl-4 .td-level-ico { color: #DB2777; }
.td-level-header .td-acc-arrow {
    font-size: .7rem; color: #6B7280; transition: transform .25s ease;
    flex-shrink: 0;
}
.td-level-header.open .td-acc-arrow { transform: rotate(90deg); }
.td-level-header .td-level-name-wrap { flex: 1; min-width: 0; }
.td-level-header .td-level-name { font-size: 1rem; font-weight: 700; color: #1E1B4B; display: block; }
.td-level-header .td-level-sublabel { font-size: .78rem; color: #6B7280; font-weight: 500; margin-top: 2px; }
.td-level-header .td-level-badge {
    font-size: .68rem; font-weight: 700; padding: 3px 9px; border-radius: 50px;
    background: rgba(255,255,255,.8); color: #374151;
    backdrop-filter: blur(2px); white-space: nowrap;
}
.td-level-content {
    display: none; padding: .75rem 0 0 .5rem;
    animation: tdAccordionIn .2s ease;
}
@keyframes tdAccordionIn { from { opacity: 0; transform: translateY(-4px); } to { opacity: 1; transform: translateY(0); } }
.td-level-item.open > .td-level-content { display: block; }
/* Unit accordion */
.td-unit-item { margin-bottom: .5rem; }
.td-unit-header {
    display: flex; align-items: center; gap: 10px; padding: .7rem 1rem;
    background: #FFFFFF; border-radius: 14px; cursor: pointer;
    border: 1.5px solid #F0EDF8; user-select: none;
    box-shadow: 0 1px 4px rgba(0,0,0,.03);
    transition: transform .2s, box-shadow .2s, border-color .2s;
}
.td-unit-header:hover {
    transform: translateY(-2px); box-shadow: 0 6px 16px rgba(124,58,237,.06);
    border-color: #DDD6FE;
}
.td-unit-header .td-unit-ico {
    width: 30px; height: 30px; border-radius: 9px; flex-shrink: 0;
    display: flex; align-items: center; justify-content: center;
    font-size: .8rem; background: #F5F3FF; color: #7C3AED;
}
.td-unit-header .td-acc-arrow { font-size: .6rem; color: #A1A1AA; transition: transform .25s ease; flex-shrink: 0; }
.td-unit-header.open .td-acc-arrow { transform: rotate(90deg); }
.td-unit-header .td-unit-name { font-size: .92rem; font-weight: 650; color: #1E1B4B; flex: 1; line-height: 1.3; }
.td-unit-header .td-unit-count {
    font-size: .68rem; font-weight: 700; padding: 3px 9px; border-radius: 50px;
    background: #F0EAFF; color: #6D28D9; white-space: nowrap;
}
.td-unit-content {
    display: none; padding: .6rem .5rem .4rem 1rem;
    animation: tdAccordionIn .2s ease;
}
.td-unit-item.open > .td-unit-content { display: block; }
/* Subtopic chips */
.td-subtopic-item {
    font-size: .88rem; color: #1E1B4B; padding: .5rem .85rem;
    display: flex; align-items: center; gap: 8px; line-height: 1.4;
    background: #F9F8FE; border-radius: 10px; margin: 4px 0;
    border: 1px solid #F0EDF8; transition: background .15s, border-color .15s;
}
.td-subtopic-item:hover { background: #F0EAFF; border-color: #DDD6FE; }
.td-subtopic-item::before {
    content: '✦'; font-size: .6rem; color: #A78BFA; flex-shrink: 0; opacity: .7;
}
/* Loading & empty states */
.td-topics-loading {
    text-align: center; padding: 3.5rem 1rem; color: var(--tc-muted);
    display: flex; flex-direction: column; align-items: center; gap: .75rem;
}
.td-topics-loading i { font-size: 1.5rem; animation: spin 1s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }
.td-topics-empty {
    text-align: center; padding: 3rem 1rem; color: var(--tc-muted);
    display: flex; flex-direction: column; align-items: center; gap: .5rem;
}
.td-topics-empty-ico {
    width: 52px; height: 52px; border-radius: 16px; background: #F5F3FF;
    display: flex; align-items: center; justify-content: center;
    font-size: 1.4rem; color: #A78BFA; margin-bottom: .25rem;
}
.td-topics-empty-title { font-size: .92rem; font-weight: 700; color: #1E1B4B; }
.td-topics-empty-sub { font-size: .8rem; color: #6B7280; }
/* Footer */
.td-topics-footer {
    padding: 1rem 1.75rem; border-top: 1px solid #F3F0FF;
    display: flex; justify-content: flex-end;
    background: #FDFCFF; position: relative; z-index: 1;
}
.td-topics-footer-btn {
    padding: .6rem 1.4rem; border-radius: 12px; border: none;
    background: linear-gradient(135deg, #7C3AED, #6D28D9);
    color: #fff; font-size: .84rem; font-weight: 700; cursor: pointer;
    box-shadow: 0 4px 12px rgba(109,40,217,.18);
    transition: transform .2s, box-shadow .2s;
}
.td-topics-footer-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 20px rgba(109,40,217,.25);
}
/* Responsive modal */
@media(max-width:767px) {
    .td-topics-modal { max-width: 95%; max-height: 85vh; border-radius: 20px; }
    .td-topics-header { padding: 1.25rem 1.25rem 1rem; }
    .td-topics-search { padding: .75rem 1.25rem; }
    .td-topics-body { padding: 1rem 1.25rem 1.5rem; }
    .td-topics-footer { padding: .85rem 1.25rem; }
    .td-topics-header-ico { width: 38px; height: 38px; font-size: 1rem; }
    .td-topics-title { font-size: 1.05rem; }
}

/* Quick Actions */
.td-quick { display: grid; grid-template-columns: repeat(4,1fr); gap: 1rem; margin-bottom: 2rem; }
.td-quick-card {
    background: var(--tc-card-bg); border-radius: 14px;
    border: 1.5px solid var(--tc-border); box-shadow: 0 2px 8px rgba(0,0,0,.04);
    padding: 1.25rem; text-decoration: none;
    transition: transform .2s ease, box-shadow .2s ease, border-color .2s ease;
    display: flex; align-items: flex-start; gap: 14px;
    position: relative; min-height: 100px;
}
.td-quick-card:hover {
    transform: translateY(-3px); box-shadow: 0 10px 28px rgba(108,99,255,.12);
    border-color: var(--tc-primary); text-decoration: none;
}
.td-quick-card:hover .td-quick-arrow { opacity: 1; transform: translateX(2px); }
.td-quick-ico {
    width: 44px; height: 44px; border-radius: 12px; flex-shrink: 0;
    display: flex; align-items: center; justify-content: center; font-size: 1.15rem;
    transition: transform .2s;
}
.td-quick-card:hover .td-quick-ico { transform: scale(1.08); }
.td-quick-content { flex: 1; min-width: 0; }
.td-quick-lbl {
    font-family: var(--font-primary); font-size: .875rem; font-weight: 700;
    color: var(--tc-text); line-height: 1.3; margin-bottom: 3px;
}
.td-quick-desc { font-size: .78rem; color: var(--tc-muted); line-height: 1.4; }
.td-quick-arrow {
    position: absolute; top: 50%; right: 1rem; transform: translateY(-50%);
    font-size: .85rem; color: var(--tc-muted); opacity: .4;
    transition: opacity .2s, transform .2s, color .2s;
}
.td-quick-card:hover .td-quick-arrow { color: var(--tc-primary); }

/* Summary Cards */
.td-stats { display: grid; grid-template-columns: repeat(4,1fr); gap: 1rem; margin-bottom: 2rem; }
.td-stat {
    background: var(--tc-card-bg); border-radius: 16px;
    border: 1.5px solid var(--tc-border); box-shadow: 0 2px 8px rgba(108,99,255,.06);
    padding: 1.5rem; display: flex; flex-direction: column;
    gap: .5rem; transition: transform .2s, box-shadow .2s;
    position: relative; overflow: hidden; cursor: pointer; text-decoration: none;
}
.td-stat::before {
    content: ''; position: absolute; top: 0; left: 0; right: 0;
    height: 4px; border-radius: 16px 16px 0 0;
}
.td-stat:hover { transform: translateY(-3px); box-shadow: 0 8px 24px rgba(108,99,255,.12); text-decoration: none; }
.td-stat.c-lessons::before  { background: linear-gradient(90deg,#6C63FF,#A78BFA); }
.td-stat.c-quizzes::before  { background: linear-gradient(90deg,#F59E0B,#FCD34D); }
.td-stat.c-sessions::before { background: linear-gradient(90deg,#3B82F6,#93C5FD); }
.td-stat.c-students::before { background: linear-gradient(90deg,#10B981,#6EE7B7); }
.td-stat-icon {
    width: 42px; height: 42px; border-radius: 12px;
    display: flex; align-items: center; justify-content: center; font-size: 1.2rem;
}
.td-stat-val {
    font-family: var(--font-primary); font-size: 1.875rem; font-weight: 800;
    line-height: 1; color: var(--tc-text);
}
.td-stat-lbl { font-size: .8125rem; color: var(--tc-muted); font-weight: 600; }

/* Section heading */
.td-sec-hd {
    display: flex; align-items: center; justify-content: space-between;
    margin-bottom: 1rem; gap: 1rem;
}
.td-sec-title {
    font-family: var(--font-primary); font-size: 1.0625rem; font-weight: 800;
    color: var(--tc-text); display: flex; align-items: center; gap: .5rem;
}

/* Two-column + Three-column layouts */
.td-row2 { display: grid; grid-template-columns: 1.2fr .8fr; gap: 1.5rem; margin-bottom: 2rem; }
.td-row3 { display: grid; grid-template-columns: repeat(3,1fr); gap: 1rem; margin-bottom: 2rem; }

/* Card */
.td-card {
    background: var(--tc-card-bg); border-radius: 16px;
    border: 1.5px solid var(--tc-border); box-shadow: 0 2px 8px rgba(108,99,255,.06);
    overflow: hidden;
}
.td-card-body { padding: 1.25rem; }

/* Session list */
.td-session-list { display: flex; flex-direction: column; gap: 4px; }
.td-session-item {
    display: flex; align-items: flex-start; gap: 1rem;
    padding: 12px; border-radius: 12px; transition: background .15s;
}
.td-session-item:hover { background: var(--tc-light-bg); }
.td-session-ico {
    width: 40px; height: 40px; border-radius: 10px;
    background: #EDE9FE; color: var(--tc-primary);
    display: flex; align-items: center; justify-content: center;
    font-size: 1.1rem; flex-shrink: 0;
}
.td-session-body { flex: 1; min-width: 0; }
.td-session-title { font-weight: 700; font-size: .875rem; color: var(--tc-text); }
.td-session-meta {
    font-size: .8rem; color: var(--tc-muted); margin-top: 4px;
    display: flex; align-items: center; gap: 8px; flex-wrap: wrap;
}
.td-session-badge {
    display: inline-flex; align-items: center; padding: 2px 8px;
    border-radius: 50px; font-size: .7rem; font-weight: 700;
}
.td-badge-upcoming { background: #EDE9FE; color: var(--tc-primary); }
.td-badge-active { background: #D1FAE5; color: #059669; }

/* Mini Calendar - Large Clean Design */
.td-live-row{display:grid;grid-template-columns:1fr 300px;gap:1.25rem;margin-bottom:2rem;}
.td-cal-card{background:var(--tc-card-bg);border:1.5px solid var(--tc-border);border-radius:18px;padding:1.5rem;box-shadow:0 2px 8px rgba(0,0,0,.03);}
.td-cal-card-header{margin-bottom:1rem;}
.td-cal-card-title{font-size:.9rem;font-weight:700;color:var(--tc-text);}
.td-cal-card-body{}
.td-cal-month-row{display:flex;align-items:center;justify-content:center;margin-bottom:1rem;}
.td-cal-month-label{font-size:.88rem;font-weight:700;color:var(--tc-text);}
.td-cal-large{display:grid;grid-template-columns:repeat(7,1fr);gap:4px;text-align:center;}
.td-cal-large .cal-header{font-size:.68rem;font-weight:700;color:var(--tc-muted);padding:8px 0;}
.td-cal-large .cal-day{padding:10px 4px;border-radius:10px;font-size:.82rem;color:var(--tc-text);transition:background .15s;}
.td-cal-large .cal-day:hover{background:#F3F4F6;}
.td-cal-large .cal-today{background:var(--tc-info);color:#fff;font-weight:700;}
.td-cal-large .cal-today:hover{background:#2563EB;}
.td-cal-large .cal-session{position:relative;}
.td-cal-large .cal-session::after{content:'';position:absolute;bottom:3px;left:50%;transform:translateX(-50%);width:5px;height:5px;border-radius:50%;background:var(--tc-success);}
/* Upcoming Card */
.td-upcoming-card{background:var(--tc-card-bg);border:1.5px solid var(--tc-border);border-radius:18px;padding:1.25rem;box-shadow:0 2px 8px rgba(0,0,0,.03);display:flex;flex-direction:column;}
.td-upcoming-header{display:flex;align-items:center;justify-content:space-between;margin-bottom:1rem;}
.td-upcoming-title{font-size:.85rem;font-weight:700;color:var(--tc-text);}
.td-upcoming-viewall{font-size:.74rem;font-weight:600;color:var(--tc-primary);text-decoration:none;}
.td-upcoming-viewall:hover{text-decoration:underline;}
.td-upcoming-body{display:flex;align-items:flex-start;gap:14px;padding:1rem;background:#F9FAFB;border-radius:14px;border:1px solid var(--tc-border);}
.td-upcoming-date-badge{display:flex;flex-direction:column;align-items:center;padding:.5rem .75rem;background:var(--tc-card-bg);border-radius:12px;border:1.5px solid var(--tc-border);min-width:52px;}
.td-date-day{font-size:1.4rem;font-weight:800;color:var(--tc-text);line-height:1;}
.td-date-month{font-size:.68rem;font-weight:700;color:var(--tc-muted);text-transform:uppercase;margin-top:2px;}
.td-upcoming-info{flex:1;}
.td-upcoming-session-title{font-size:.88rem;font-weight:700;color:var(--tc-text);margin-bottom:4px;}
.td-upcoming-session-meta{font-size:.74rem;color:var(--tc-muted);display:flex;flex-direction:column;gap:3px;margin-bottom:6px;}
.td-upcoming-session-meta span{display:flex;align-items:center;gap:4px;}
.td-upcoming-empty{display:flex;flex-direction:column;align-items:center;text-align:center;padding:2rem 1rem;flex:1;justify-content:center;}
.td-upcoming-empty i{font-size:2.5rem;color:var(--tc-muted);opacity:.4;margin-bottom:.75rem;}
.td-upcoming-empty-title{font-size:.88rem;font-weight:700;color:var(--tc-text);margin-bottom:.25rem;}
.td-upcoming-empty-sub{font-size:.78rem;color:var(--tc-muted);margin-bottom:.75rem;}
.td-upcoming-empty-btn{display:inline-flex;align-items:center;gap:5px;padding:.45rem 1rem;border-radius:8px;background:var(--tc-success);color:#fff;font-size:.78rem;font-weight:700;text-decoration:none;transition:background .15s;}
.td-upcoming-empty-btn:hover{background:#059669;color:#fff;text-decoration:none;}
@media(max-width:900px){.td-live-row{grid-template-columns:1fr;}}

/* Practice Quiz Engagement – Carousel */
.td-pq-carousel-wrap { position: relative; margin-bottom: 2rem; }
.td-pq-carousel { overflow: hidden; border-radius: 8px; }
.td-pq-track {
    display: flex; transition: transform .4s cubic-bezier(.4,0,.2,1);
}
.td-pq-slide { flex-shrink: 0; padding: 0 .625rem; box-sizing: border-box; }
.td-pq-arrow {
    position: absolute; top: 50%; transform: translateY(-50%); z-index: 2;
    width: 38px; height: 38px; border-radius: 50%; border: 1.5px solid #E9E5F5;
    background: #fff; color: #7C3AED; font-size: 1rem; cursor: pointer;
    display: flex; align-items: center; justify-content: center;
    box-shadow: 0 2px 10px rgba(0,0,0,.08); transition: background .15s, box-shadow .15s, opacity .2s;
}
.td-pq-arrow:hover { background: #F5F3FF; box-shadow: 0 4px 14px rgba(124,58,237,.12); }
.td-pq-arrow.disabled { opacity: .3; pointer-events: none; }
.td-pq-arrow-left { left: -12px; }
.td-pq-arrow-right { right: -12px; }
.td-pq-dots { display: flex; align-items: center; justify-content: center; gap: 6px; margin-top: 1rem; }
.td-pq-dot {
    width: 8px; height: 8px; border-radius: 50%; background: #DDD6FE;
    cursor: pointer; transition: background .2s, transform .2s;
}
.td-pq-dot.active { background: #7C3AED; transform: scale(1.25); }
/* Card */
.td-pq-card {
    background: #fff; border-radius: 18px; border: 1.5px solid #F0EDF8;
    box-shadow: 0 2px 10px rgba(108,99,255,.05); display: flex; flex-direction: column;
    overflow: hidden; transition: transform .2s ease, box-shadow .2s ease; height: 100%;
}
.td-pq-card:hover { transform: translateY(-4px); box-shadow: 0 10px 28px rgba(108,99,255,.10); }
.td-pq-card-top {
    background: linear-gradient(135deg, #6D28D9, #4338CA); padding: 1.1rem 1.25rem;
    position: relative; overflow: hidden; display: flex; align-items: center; justify-content: space-between;
}
.td-pq-card-top::before {
    content: ''; position: absolute; width: 80px; height: 80px; border-radius: 50%;
    background: rgba(255,255,255,.06); top: -20px; right: -20px; pointer-events: none;
}
.td-pq-card-top::after {
    content: ''; position: absolute; width: 40px; height: 40px; border-radius: 50%;
    background: rgba(255,255,255,.04); bottom: -10px; left: 20px; pointer-events: none;
}
.td-pq-badge-top { font-size: .68rem; font-weight: 700; padding: 4px 10px; border-radius: 50px; position: relative; z-index: 1; }
.td-pq-badge-questions { background: rgba(255,255,255,.18); color: #fff; }
.td-pq-badge-lang-top { background: rgba(255,255,255,.18); color: #fff; }
.td-pq-card-body { padding: 1.25rem; display: flex; flex-direction: column; gap: .9rem; flex: 1; }
.td-pq-title { font-size: .95rem; font-weight: 700; color: #1E1B4B; line-height: 1.35; }
.td-pq-info-row {
    display: grid; grid-template-columns: 1fr 1fr; gap: .75rem;
}
.td-pq-info-item { display: flex; align-items: flex-start; gap: 8px; }
.td-pq-info-item i { color: #7C3AED; font-size: .85rem; margin-top: 2px; flex-shrink: 0; }
.td-pq-info-label { font-size: .7rem; color: #6B7280; line-height: 1.2; }
.td-pq-info-value { font-size: .82rem; font-weight: 600; color: #1E1B4B; line-height: 1.3; }
.td-pq-metrics {
    display: grid; grid-template-columns: repeat(auto-fit, minmax(120px, 1fr)); gap: 8px;
    padding: .85rem 0 0; margin-top: auto;
}
.td-pq-metric {
    display: flex; align-items: center; gap: 8px;
    padding: .55rem .65rem; border-radius: 12px;
    background: #F9FAFB; box-sizing: border-box;
    min-width: 0; overflow: hidden; width: 100%;
}
.td-pq-metric-ico {
    width: 32px; height: 32px; border-radius: 9px; flex-shrink: 0;
    display: flex; align-items: center; justify-content: center; font-size: .82rem;
}
.td-pq-metric-text { min-width: 0; overflow: hidden; }
.td-pq-metric-val { font-size: .95rem; font-weight: 800; color: #1E1B4B; line-height: 1.2; overflow-wrap: anywhere; word-wrap: break-word; }
.td-pq-metric-lbl { font-size: .63rem; color: #6B7280; font-weight: 600; line-height: 1.2; overflow-wrap: anywhere; word-wrap: break-word; }
@media(max-width:767px) { .td-pq-metrics { grid-template-columns: 1fr; } }
.td-pq-empty {
    display: flex; flex-direction: column; align-items: center; justify-content: center;
    text-align: center; padding: 3rem 1.5rem; color: #6B7280;
    background: #fff; border-radius: 18px; border: 1.5px solid #F0EDF8;
    box-shadow: 0 2px 8px rgba(108,99,255,.04); margin-bottom: 2rem;
}
.td-pq-empty-ico { font-size: 2.5rem; margin-bottom: .75rem; opacity: .45; color: var(--tc-primary); }
.td-pq-empty-title { font-size: 1rem; font-weight: 700; color: #1E1B4B; margin-bottom: .25rem; }
.td-pq-empty-sub { font-size: .85rem; color: #6B7280; max-width: 360px; line-height: 1.5; }
@media(max-width:1023px) { .td-pq-slide { width: 50%; } }
@media(max-width:767px) { .td-pq-slide { width: 100%; } .td-pq-arrow { display: none; } }

/* Notification list */
.td-notif-list { display: flex; flex-direction: column; }
.td-notif-item {
    padding: 12px 1rem; border-bottom: 1px solid #F3F0FF;
    display: flex; gap: .75rem; align-items: flex-start;
}
.td-notif-item:last-child { border-bottom: none; }
.td-notif-dot {
    width: 10px; height: 10px; border-radius: 50%; margin-top: 5px; flex-shrink: 0;
    background: var(--tc-primary); box-shadow: 0 0 0 3px #EDE9FE;
}
.td-notif-dot.read { background: var(--tc-muted); box-shadow: none; }
.td-notif-body { flex: 1; min-width: 0; }
.td-notif-title { font-size: .875rem; font-weight: 600; color: var(--tc-text); line-height: 1.4; }
.td-notif-msg { font-size: .8rem; color: var(--tc-muted); margin-top: 2px; line-height: 1.4; }
.td-notif-time { font-size: .75rem; color: var(--tc-muted); margin-top: 3px; display: flex; align-items: center; gap: 4px; }

/* Empty state */
.td-empty {
    display: flex; flex-direction: column; align-items: center;
    justify-content: center; text-align: center;
    padding: 2.5rem 1.5rem; color: var(--tc-muted);
}
.td-empty-ico { font-size: 2.5rem; margin-bottom: .75rem; opacity: .55; }
.td-empty-msg { font-size: .9375rem; font-weight: 600; color: var(--tc-muted); }

/* Status panels */
.td-status-panel {
    display: flex; flex-direction: column; align-items: center;
    justify-content: center; text-align: center;
    padding: 3rem 2rem; min-height: 300px;
}
.td-status-ico { font-size: 4rem; margin-bottom: 1.5rem; }
.td-status-title {
    font-family: var(--font-primary); font-size: 1.5rem; font-weight: 800;
    color: var(--tc-text); margin-bottom: .5rem;
}
.td-status-msg { font-size: 1rem; color: var(--tc-muted); max-width: 500px; line-height: 1.6; }

/* Quiz Contribution Cards — coloured */
.td-qc-card{border-radius:18px;padding:1.35rem 1.4rem;margin-bottom:1rem;position:relative;overflow:hidden;transition:transform .2s ease,box-shadow .2s ease;}
.td-qc-card:hover{transform:translateY(-3px);box-shadow:0 8px 24px rgba(0,0,0,.08);}
.td-qc-purple{background:linear-gradient(135deg,#F5F3FF 0%,#EDE9FE 60%,#DDD6FE 100%);border:1.5px solid #C4B5FD;box-shadow:0 2px 10px rgba(124,58,237,.06);}
.td-qc-blue{background:linear-gradient(135deg,#EFF6FF 0%,#DBEAFE 60%,#BFDBFE 100%);border:1.5px solid #93C5FD;box-shadow:0 2px 10px rgba(37,99,235,.06);}
.td-qc-card::before{content:'';position:absolute;width:100px;height:100px;border-radius:50%;top:-30px;right:-30px;pointer-events:none;}
.td-qc-card::after{content:'';position:absolute;width:60px;height:60px;border-radius:50%;bottom:-20px;left:30%;pointer-events:none;}
.td-qc-purple::before{background:rgba(124,58,237,.06);}
.td-qc-purple::after{background:rgba(167,139,250,.05);}
.td-qc-blue::before{background:rgba(37,99,235,.05);}
.td-qc-blue::after{background:rgba(96,165,250,.04);}
.td-qc-header{display:flex;align-items:center;gap:12px;margin-bottom:.6rem;position:relative;z-index:1;}
.td-qc-ico{width:42px;height:42px;border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:1.1rem;flex-shrink:0;}
.td-qc-purple .td-qc-ico{background:rgba(124,58,237,.12);color:#7C3AED;}
.td-qc-blue .td-qc-ico{background:rgba(37,99,235,.10);color:#2563EB;}
.td-qc-header-text{position:relative;z-index:1;}
.td-qc-title{font-size:.9rem;font-weight:700;color:#1E1B4B;line-height:1.3;}
.td-qc-sub{font-size:.74rem;color:#4B5563;margin-top:1px;}
.td-qc-count{position:relative;z-index:1;margin-bottom:.75rem;}
.td-qc-count-num{font-size:1.5rem;font-weight:800;color:#1E1B4B;letter-spacing:-.5px;}
.td-qc-count-of{font-size:.85rem;font-weight:600;color:#4B5563;margin-left:2px;}
.td-qc-count-unit{font-size:.75rem;color:#6B7280;margin-left:4px;}
.td-qc-bar{width:100%;height:9px;background:rgba(0,0,0,.06);border-radius:9px;overflow:hidden;position:relative;z-index:1;}
.td-qc-bar-fill{height:100%;border-radius:9px;transition:width .8s cubic-bezier(.4,0,.2,1);}
.td-qc-purple .td-qc-bar-fill{background:linear-gradient(90deg,#7C3AED,#A78BFA);}
.td-qc-blue .td-qc-bar-fill{background:linear-gradient(90deg,#2563EB,#60A5FA);}
/* Tooltip */
.td-contrib-info{position:relative;display:inline-flex;align-items:center;margin-left:8px;cursor:help;}
.td-contrib-info i{font-size:.88rem;color:#A1A1AA;transition:color .15s;}
.td-contrib-info:hover i{color:#7C3AED;}
.td-contrib-tooltip{position:absolute;bottom:calc(100% + 12px);left:50%;transform:translateX(-50%) translateY(4px);background:#fff;color:#374151;font-size:.78rem;font-weight:500;padding:1rem 1.15rem;border-radius:14px;white-space:normal;width:310px;text-align:left;line-height:1.55;opacity:0;visibility:hidden;pointer-events:none;transition:opacity .2s,visibility .2s,transform .2s;z-index:50;box-shadow:0 8px 28px rgba(0,0,0,.12);border:1px solid #F0EDF8;}
.td-contrib-tooltip::after{content:'';position:absolute;top:100%;left:50%;transform:translateX(-50%);border:6px solid transparent;border-top-color:#fff;}
.td-contrib-info:hover .td-contrib-tooltip,.td-contrib-info:focus .td-contrib-tooltip{opacity:1;visibility:visible;transform:translateX(-50%) translateY(0);}

/* Twin row layout */
.td-twin-row{display:flex;gap:1.25rem;margin-bottom:2rem;}
@media(max-width:900px){.td-twin-row{flex-direction:column;}}

/* Timeline */
.td-timeline{position:relative;padding-left:20px;}
.td-timeline::before{content:'';position:absolute;left:7px;top:8px;bottom:8px;width:2px;background:#E5E7EB;border-radius:2px;}
.td-tl-item{position:relative;padding-bottom:1.1rem;padding-left:18px;}
.td-tl-item:last-child{padding-bottom:0;}
.td-tl-dot{position:absolute;left:-16px;top:6px;width:12px;height:12px;border-radius:50%;border:2.5px solid;background:#fff;}
.td-tl-dot.dot-blue{border-color:#3B82F6;}
.td-tl-dot.dot-yellow{border-color:#F59E0B;background:#FEF3C7;}
.td-tl-dot.dot-green{border-color:#10B981;background:#D1FAE5;}
.td-tl-content{background:#F9FAFB;border:1px solid var(--tc-border);border-radius:12px;padding:.85rem 1rem;}
.td-tl-time{font-size:.72rem;font-weight:600;color:var(--tc-muted);margin-bottom:3px;}
.td-tl-title{font-size:.88rem;font-weight:700;color:var(--tc-text);margin-bottom:3px;}
.td-tl-topic{font-size:.74rem;color:var(--tc-muted);display:flex;align-items:center;gap:4px;margin-bottom:.5rem;}
.td-tl-footer{display:flex;align-items:center;gap:.5rem;}
.td-tl-badge{font-size:.65rem;font-weight:700;padding:2px 8px;border-radius:50px;}
.td-tl-badge.badge-blue{background:#DBEAFE;color:#1D4ED8;}
.td-tl-badge.badge-yellow{background:#FEF3C7;color:#92400E;}
.td-tl-badge.badge-green{background:#D1FAE5;color:#047857;}
.td-tl-btn{font-size:.72rem;font-weight:700;padding:4px 10px;border-radius:7px;text-decoration:none;transition:background .15s;}
.td-tl-btn.btn-blue{background:#EFF6FF;color:#2563EB;}.td-tl-btn.btn-blue:hover{background:#DBEAFE;}
.td-tl-btn.btn-yellow{background:#FFFBEB;color:#D97706;}.td-tl-btn.btn-yellow:hover{background:#FEF3C7;}
.td-tl-btn.btn-green{background:#ECFDF5;color:#059669;}.td-tl-btn.btn-green:hover{background:#D1FAE5;}

/* Dashboard Notifications v2 */
.td-notif-list-v2{display:flex;flex-direction:column;gap:2px;}
.td-nv2-item{display:flex;align-items:flex-start;gap:10px;padding:.7rem .75rem;border-radius:10px;transition:background .12s;}
.td-nv2-item.unread{background:#F5F3FF;}
.td-nv2-item:hover{background:#F3F4F6;}
.td-nv2-ico{width:32px;height:32px;border-radius:8px;background:#EDE9FE;color:var(--tc-primary);display:flex;align-items:center;justify-content:center;font-size:.85rem;flex-shrink:0;}
.td-nv2-body{flex:1;min-width:0;}
.td-nv2-title{font-size:.82rem;font-weight:700;color:var(--tc-text);line-height:1.3;}
.td-nv2-msg{font-size:.76rem;color:var(--tc-muted);margin-top:2px;line-height:1.4;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;}
.td-nv2-time{font-size:.68rem;color:var(--tc-muted);margin-top:3px;display:flex;align-items:center;gap:3px;}

/* Quiz Creation Cards */
.td-quiz-row{display:grid;grid-template-columns:repeat(3,1fr);gap:1.25rem;margin-bottom:2rem;}
.td-quiz-card{display:flex;flex-direction:column;border-radius:18px;padding:1.75rem 1.5rem;position:relative;overflow:hidden;text-decoration:none;transition:transform .2s,box-shadow .2s;min-height:200px;}
.td-quiz-card:hover{transform:translateY(-4px);box-shadow:0 12px 32px rgba(0,0,0,.12);text-decoration:none;}
.td-quiz-bg-icons{position:absolute;top:0;right:0;bottom:0;width:60%;pointer-events:none;opacity:.10;}
.td-quiz-bg-icons i{position:absolute;font-size:2.2rem;}
.td-quiz-bg-icons i:nth-child(1){top:10%;right:8%;}
.td-quiz-bg-icons i:nth-child(2){bottom:18%;right:22%;}
.td-quiz-bg-icons i:nth-child(3){top:45%;right:5%;font-size:1.8rem;}
.td-quiz-bg-icons i:nth-child(4){top:15%;right:35%;font-size:1.6rem;}
.td-quiz-bg-icons i:nth-child(5){bottom:8%;right:6%;font-size:1.5rem;}
.td-quiz-ico{width:56px;height:56px;border-radius:16px;background:rgba(255,255,255,.25);display:flex;align-items:center;justify-content:center;font-size:1.5rem;color:#fff;margin-bottom:1rem;backdrop-filter:blur(4px);}
.td-quiz-title{font-size:1.1rem;font-weight:800;color:#fff;margin-bottom:.35rem;position:relative;z-index:1;}
.td-quiz-desc{font-size:.82rem;color:rgba(255,255,255,.85);line-height:1.5;margin-bottom:1rem;position:relative;z-index:1;flex:1;}
.td-quiz-btn{display:inline-flex;align-items:center;gap:5px;padding:.5rem 1.1rem;border-radius:10px;background:#fff;color:#374151;font-size:.82rem;font-weight:700;align-self:flex-start;position:relative;z-index:1;transition:box-shadow .15s;}
.td-quiz-card:hover .td-quiz-btn{box-shadow:0 4px 12px rgba(0,0,0,.1);}
/* Purple card */
.td-quiz-purple{background:linear-gradient(135deg,#4F46E5,#7C3AED);box-shadow:0 6px 20px rgba(79,70,229,.2);}
.td-quiz-purple .td-quiz-bg-icons i{color:#fff;}
/* Orange card */
.td-quiz-orange{background:linear-gradient(135deg,#F59E0B,#F97316);box-shadow:0 6px 20px rgba(245,158,11,.2);}
.td-quiz-orange .td-quiz-bg-icons i{color:#fff;}
/* Teal card */
.td-quiz-teal{background:linear-gradient(135deg,#0D9488,#6366F1);box-shadow:0 6px 20px rgba(13,148,136,.2);}
.td-quiz-teal .td-quiz-bg-icons i{color:#fff;}

/* Responsive */
@media(max-width:1279px) { .td-stats { grid-template-columns: repeat(2,1fr); } .td-quick { grid-template-columns: repeat(2,1fr); } .td-row3 { grid-template-columns: repeat(3,1fr); } }
@media(max-width:1023px) { .td-stats { grid-template-columns: repeat(2,1fr); } .td-quick { grid-template-columns: repeat(2,1fr); } .td-row2 { grid-template-columns: 1fr; } .td-row3 { grid-template-columns: 1fr 1fr 1fr; } .td-quiz-row{grid-template-columns:repeat(2,1fr);} }
@media(max-width:991px) {
    .td-hero { flex-direction: column; padding: 2.5rem 2rem; text-align: center; min-height: auto; max-height: none; }
    .td-hero-body { max-width: 100%; }
    .td-hero-actions { justify-content: center; }
    .td-hero-illustration { width: 55%; max-width: 280px; margin-top: 1.5rem; align-self: center; }
    .td-hero-mascot-wrap img { height: auto; max-height: 240px; margin-bottom: -2.5rem; }
    .td-hero-decor { display: none; }
    .td-hero-decor-bulb, .td-hero-decor-heart { display: none; }
}
@media(max-width:767px) {
    .td-hero { padding: 2rem 1.5rem; border-radius: 22px; }
    .td-hero-title { font-size: 1.5rem; }
    .td-hero-sub { font-size: .88rem; }
    .td-hero-illustration { width: 65%; max-width: 240px; }
    .td-hero-mascot-wrap img { max-height: 200px; margin-bottom: -2rem; }
    .td-stats { grid-template-columns: 1fr 1fr; }
    .td-quick { grid-template-columns: 1fr; }
    .td-row3 { grid-template-columns: 1fr; }
    .td-quiz-row{grid-template-columns:1fr;}
    .td-topics-modal { max-width: 95%; max-height: 85vh; border-radius: 16px; }
}
@media(max-width:479px) {
    .td-hero { padding: 1.75rem 1.25rem; }
    .td-hero-title { font-size: 1.3rem; }
    .td-hero-illustration { width: 75%; }
    .td-stats { grid-template-columns: 1fr; }
}
</style>
</asp:Content>

<%-- ════ SIDEBAR MENU ════ --%>
<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Teaching","Pengajaran") %></div>
        <a href="<%: ResolveUrl("~/Teacher/manageMaterials.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label"><%: T("Manage Materials","Bahan Pembelajaran") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label"><%: T("Manage Quiz","Kuiz") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/studentProgress.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bar-chart item-icon"></i><span class="item-label"><%: T("Student Progress","Prestasi Pelajar") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/liveSession.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label"><%: T("Schedule Live Class","Kelas Langsung") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Community","Komuniti") %></div>
        <a href="<%: ResolveUrl("~/Teacher/forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/privateMessages.aspx") %>" class="sb-sidebar-item"><i class="bi bi-envelope item-icon"></i><span class="item-label"><%: T("Private Message","Mesej Peribadi") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Account","Akaun") %></div>
        <a href="<%: ResolveUrl("~/Teacher/MyProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("My Profile","Profil Saya") %></span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Sign Out","Log Keluar") %></span></a></div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Teacher Dashboard","Papan Pemuka Guru") %></asp:Content>

<%-- ════ MAIN CONTENT ════ --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- Status panels for non-certified teachers --%>
<asp:Panel ID="pnlPending" runat="server" Visible="false">
    <div class="td-status-panel">
        <div class="td-status-ico">⏳</div>
        <div class="td-status-title">Verification Pending</div>
        <div class="td-status-msg">
            Your teaching certificate is currently under review. You will receive full access to the Teacher Dashboard once your certification has been approved by our admin team. Thank you for your patience!
        </div>
    </div>
</asp:Panel>

<asp:Panel ID="pnlRejected" runat="server" Visible="false">
    <div class="td-status-panel">
        <div class="td-status-ico">📋</div>
        <div class="td-status-title">Certificate Not Approved</div>
        <div class="td-status-msg">
            Unfortunately, your teaching certificate was not approved. Please contact our support team or resubmit your certification documents for review. We are here to help!
        </div>
    </div>
</asp:Panel>

<asp:Panel ID="pnlDenied" runat="server" Visible="false">
    <div class="td-status-panel">
        <div class="td-status-ico">🚫</div>
        <div class="td-status-title">Access Denied</div>
        <div class="td-status-msg">
            Your account does not currently have access to the Teacher Dashboard. If you believe this is an error, please contact the ScienceBuddy support team.
        </div>
    </div>
</asp:Panel>

<%-- Main Dashboard (visible only to Certified teachers) --%>
<asp:Panel ID="pnlDashboard" runat="server" Visible="false">

<%-- ── 1. HERO BANNER ── --%>
<div class="td-hero">
    <div class="td-hero-body">
        <div class="td-hero-eyebrow">Teacher Portal</div>
        <div class="td-hero-title">Welcome back, <asp:Literal ID="litTeacherName" runat="server" Text="Teacher" />!</div>
        <div class="td-hero-sub">Manage your quizzes, teaching resources and classroom activities from one place.</div>
        <div class="td-hero-actions">
            <button type="button" class="td-hero-btn-topics" onclick="openTopicsModal()"><i class="bi bi-book"></i> Available Topics</button>
        </div>
    </div>
    <div class="td-hero-illustration">
        <div class="td-hero-mascot-wrap">
            <img src="<%: ResolveUrl("~/Images/Teacher/fox-teacher.png") %>" alt="Teacher mascot" />
            <div class="td-hero-ground-shadow"></div>
        </div>
        <div class="td-hero-decor-bulb"></div>
        <div class="td-hero-decor-heart"></div>
    </div>
    <div class="td-hero-decor">
        <div class="td-hero-decor-circle1"></div>
        <div class="td-hero-decor-circle2"></div>
        <div class="td-hero-decor-circle3"></div>
        <div class="td-hero-decor-dots"></div>
        <div class="td-hero-decor-curve"></div>
        <div class="td-hero-decor-glow"></div>
    </div>
</div>

<%-- Available Topics Modal --%>
<div class="td-topics-overlay" id="tdTopicsOverlay" onclick="if(event.target===this)closeTopicsModal()">
    <div class="td-topics-modal" role="dialog" aria-labelledby="tdTopicsTitle" aria-modal="true">
        <div class="td-topics-header">
            <div class="td-topics-header-left">
                <div class="td-topics-header-ico"><i class="bi bi-journal-bookmark-fill"></i></div>
                <div class="td-topics-header-text">
                    <div class="td-topics-title" id="tdTopicsTitle">Available Topics <span class="td-topics-title-sparkle">✦</span></div>
                    <div class="td-topics-subtitle">Explore available units and subtopics by level.</div>
                </div>
            </div>
            <button type="button" class="td-topics-close" onclick="closeTopicsModal()" aria-label="Close"><i class="bi bi-x-lg"></i></button>
        </div>
        <div class="td-topics-search">
            <input type="text" id="tdTopicsSearch" placeholder="Search units or subtopics..." oninput="filterTopics(this.value)" />
        </div>
        <div class="td-topics-body" id="tdTopicsBody">
            <div class="td-topics-loading"><i class="bi bi-arrow-repeat"></i><span>Loading topics...</span></div>
        </div>
        <div class="td-topics-footer">
            <button type="button" class="td-topics-footer-btn" onclick="closeTopicsModal()">Close</button>
        </div>
    </div>
</div>

<%-- ── 2. QUIZ CREATION ── --%>
<div class="td-sec-hd">
    <div class="td-sec-title"><i class="bi bi-mortarboard-fill" style="color:var(--tc-primary);"></i> <%: T("Quiz Creation","Cipta Kuiz") %></div>
    <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx?tab=unit-level") %>" style="font-size:.85rem;font-weight:600;color:var(--tc-primary);text-decoration:none;transition:color .15s;" onmouseover="this.style.textDecoration='underline'" onmouseout="this.style.textDecoration='none'"><%: T("View all quizzes","Lihat semua kuiz") %> →</a>
</div>
<div class="td-quiz-row">
    <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx?tab=unit-level&type=unit") %>" class="td-quiz-card td-quiz-purple">
        <div class="td-quiz-bg-icons"><i class="bi bi-droplet"></i><i class="bi bi-diagram-3"></i><i class="bi bi-moisture"></i><i class="bi bi-virus"></i><i class="bi bi-stars"></i></div>
        <div class="td-quiz-ico"><i class="bi bi-funnel-fill"></i></div>
        <div class="td-quiz-title"><%: T("Unit Quiz","Kuiz Unit") %></div>
        <div class="td-quiz-desc"><%: T("Create quizzes based on a specific unit or topic.","Cipta kuiz berdasarkan unit atau topik tertentu.") %></div>
        <span class="td-quiz-btn"><%: T("Create Quiz","Cipta Kuiz") %> →</span>
    </a>
    <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx?tab=unit-level&type=level") %>" class="td-quiz-card td-quiz-orange">
        <div class="td-quiz-bg-icons"><i class="bi bi-journal-bookmark"></i><i class="bi bi-layers"></i><i class="bi bi-lightning"></i><i class="bi bi-globe-americas"></i><i class="bi bi-sun"></i></div>
        <div class="td-quiz-ico"><i class="bi bi-book-half"></i></div>
        <div class="td-quiz-title"><%: T("Level Quiz","Kuiz Tahap") %></div>
        <div class="td-quiz-desc"><%: T("Create quizzes based on difficulty levels.","Cipta kuiz berdasarkan tahap kesukaran.") %></div>
        <span class="td-quiz-btn"><%: T("Create Quiz","Cipta Kuiz") %> →</span>
    </a>
    <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx?tab=practice") %>" class="td-quiz-card td-quiz-teal">
        <div class="td-quiz-bg-icons"><i class="bi bi-gear"></i><i class="bi bi-bullseye"></i><i class="bi bi-flower1"></i><i class="bi bi-thermometer-half"></i><i class="bi bi-rocket"></i></div>
        <div class="td-quiz-ico"><i class="bi bi-clipboard2-pulse-fill"></i></div>
        <div class="td-quiz-title"><%: T("Practice Quiz","Kuiz Latihan") %></div>
        <div class="td-quiz-desc"><%: T("Create practice quizzes for revision and exercises.","Cipta kuiz latihan untuk ulangkaji dan latihan.") %></div>
        <span class="td-quiz-btn"><%: T("Create Quiz","Cipta Kuiz") %> →</span>
    </a>
</div>

<%-- ── QUIZ CONTRIBUTION ── --%>
<div class="td-sec-hd">
    <div class="td-sec-title"><i class="bi bi-pie-chart-fill" style="color:var(--tc-primary);"></i> <%: T("Your Quiz Contribution","Sumbangan Kuiz Anda") %>
        <span class="td-contrib-info" tabindex="0" aria-label="Quiz contribution information">
            <i class="bi bi-info-circle"></i>
            <span class="td-contrib-tooltip">Your Quiz Contribution shows the number of approved quiz questions you have contributed compared to the total approved quiz questions currently available in ScienceBuddy.<br/><br/>Only approved questions are included in the calculation.<br/><br/>• Unit Quiz Contribution counts approved Unit Quiz questions.<br/>• Level Quiz Contribution counts approved Level Quiz questions.</span>
        </span>
    </div>
</div>
<%-- Unit Quiz Card --%>
<div class="td-qc-card td-qc-purple">
    <div class="td-qc-header">
        <div class="td-qc-ico"><i class="bi bi-funnel-fill"></i></div>
        <div class="td-qc-header-text">
            <div class="td-qc-title"><%: T("Unit Quiz Contribution","Sumbangan Kuiz Unit") %></div>
            <div class="td-qc-sub"><%: T("Approved Unit Questions","Soalan Unit Diluluskan") %></div>
        </div>
    </div>
    <div class="td-qc-count">
        <span class="td-qc-count-num"><asp:Literal ID="litUnitMyCount" runat="server" Text="0" /></span>
        <span class="td-qc-count-of">of <asp:Literal ID="litUnitTotal" runat="server" Text="0" /></span>
        <span class="td-qc-count-unit">Questions</span>
    </div>
    <div class="td-qc-bar"><div class="td-qc-bar-fill" id="qcBarUnit" style="width:0%;"></div></div>
</div>
<%-- Level Quiz Card --%>
<div class="td-qc-card td-qc-blue">
    <div class="td-qc-header">
        <div class="td-qc-ico"><i class="bi bi-book-half"></i></div>
        <div class="td-qc-header-text">
            <div class="td-qc-title"><%: T("Level Quiz Contribution","Sumbangan Kuiz Tahap") %></div>
            <div class="td-qc-sub"><%: T("Approved Level Questions","Soalan Tahap Diluluskan") %></div>
        </div>
    </div>
    <div class="td-qc-count">
        <span class="td-qc-count-num"><asp:Literal ID="litLevelMyCount" runat="server" Text="0" /></span>
        <span class="td-qc-count-of">of <asp:Literal ID="litLevelTotal" runat="server" Text="0" /></span>
        <span class="td-qc-count-unit">Questions</span>
    </div>
    <div class="td-qc-bar"><div class="td-qc-bar-fill" id="qcBarLevel" style="width:0%;"></div></div>
</div>
<%-- Hidden data for JS animation --%>
<asp:HiddenField ID="hidUnitPct" runat="server" Value="0" />
<asp:HiddenField ID="hidLevelPct" runat="server" Value="0" />
<asp:Literal ID="litUnitPct" runat="server" Text="" Visible="false" />
<asp:Literal ID="litLevelPct" runat="server" Text="" Visible="false" />
<asp:Literal ID="litUnitCount" runat="server" Text="" Visible="false" />
<asp:Literal ID="litLevelCount" runat="server" Text="" Visible="false" />

<%-- ── 3. QUICK ACTIONS ── --%>
<div class="td-sec-hd">
    <div class="td-sec-title"><i class="bi bi-lightning-fill" style="color:var(--tc-primary);"></i> <%: T("Quick Actions","Tindakan Pantas") %></div>
</div>
<div class="td-quick">
    <a href="<%: ResolveUrl("~/Teacher/uploadMaterial.aspx") %>" class="td-quick-card">
        <div class="td-quick-ico" style="background:#EDE9FE;color:#6C63FF;"><i class="bi bi-file-earmark-plus"></i></div>
        <div class="td-quick-content">
            <div class="td-quick-lbl"><%: T("Upload Material","Muat Naik Bahan") %></div>
            <div class="td-quick-desc"><%: T("Add a new science lesson or material.","Tambah bahan pembelajaran sains baharu.") %></div>
        </div>
        <span class="td-quick-arrow"><i class="bi bi-chevron-right"></i></span>
    </a>
    <a href="<%: ResolveUrl("~/Teacher/liveSession.aspx") %>" class="td-quick-card">
        <div class="td-quick-ico" style="background:#DBEAFE;color:#2563EB;"><i class="bi bi-calendar-plus"></i></div>
        <div class="td-quick-content">
            <div class="td-quick-lbl"><%: T("Schedule Live Class","Jadualkan Kelas Langsung") %></div>
            <div class="td-quick-desc"><%: T("Plan and schedule an online class session.","Rancang dan jadualkan sesi kelas dalam talian.") %></div>
        </div>
        <span class="td-quick-arrow"><i class="bi bi-chevron-right"></i></span>
    </a>
    <a href="<%: ResolveUrl("~/Teacher/studentProgress.aspx") %>" class="td-quick-card">
        <div class="td-quick-ico" style="background:#D1FAE5;color:#059669;"><i class="bi bi-graph-up-arrow"></i></div>
        <div class="td-quick-content">
            <div class="td-quick-lbl"><%: T("Student Progress","Prestasi Pelajar") %></div>
            <div class="td-quick-desc"><%: T("Review student learning data and performance.","Semak prestasi dan data pembelajaran pelajar.") %></div>
        </div>
        <span class="td-quick-arrow"><i class="bi bi-chevron-right"></i></span>
    </a>
    <a href="<%: ResolveUrl("~/Teacher/privateMessages.aspx") %>" class="td-quick-card">
        <div class="td-quick-ico" style="background:#FEF3C7;color:#D97706;"><i class="bi bi-envelope"></i></div>
        <div class="td-quick-content">
            <div class="td-quick-lbl"><%: T("Private Message","Mesej Peribadi") %></div>
            <div class="td-quick-desc"><%: T("Send and receive messages with students and parents.","Hantar dan terima mesej dengan pelajar dan ibu bapa.") %></div>
        </div>
        <span class="td-quick-arrow"><i class="bi bi-chevron-right"></i></span>
    </a>
</div>

<%-- ── 4. UPCOMING SESSIONS & NOTIFICATIONS ── --%>
<div class="td-twin-row">
    <%-- Upcoming Live Sessions --%>
    <div class="td-card" style="flex:1.3;">
        <div class="td-card-body">
            <div class="td-sec-hd" style="margin-bottom:.75rem;">
                <div class="td-sec-title" style="font-size:.92rem;"><i class="bi bi-camera-video-fill" style="color:var(--tc-info);"></i> <%: T("Upcoming Live Sessions","Kelas Langsung Akan Datang") %></div>
                <a href="<%: ResolveUrl("~/Teacher/liveSession.aspx") %>" style="font-size:.78rem;font-weight:600;color:var(--tc-primary);text-decoration:none;"><%: T("View All","Lihat Semua") %> →</a>
            </div>
            <asp:Panel ID="pnlTimelineSessions" runat="server" Visible="false">
                <div class="td-timeline">
                    <asp:Repeater ID="rptTimelineSessions" runat="server">
                        <ItemTemplate>
                            <div class="td-tl-item">
                                <div class='td-tl-dot <%# Eval("dotCss") %>'></div>
                                <div class="td-tl-content">
                                    <div class="td-tl-time"><%# Eval("friendlyDate") %></div>
                                    <div class="td-tl-title"><%# HttpUtility.HtmlEncode(Eval("title")) %></div>
                                    <div class="td-tl-topic"><i class="bi bi-bookmark"></i> <%# HttpUtility.HtmlEncode(Eval("topic")) %></div>
                                    <div class="td-tl-footer">
                                        <span class='td-tl-badge <%# Eval("badgeCss") %>'><%# Eval("statusLabel") %></span>
                                        <a href='<%# ResolveUrl("~/Teacher/liveSession.aspx") %>' class='td-tl-btn <%# Eval("btnCss") %>'><%# Eval("btnLabel") %></a>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </asp:Panel>
            <asp:Panel ID="pnlTimelineEmpty" runat="server">
                <div class="td-empty" style="padding:2rem;">
                    <i class="bi bi-calendar2-check" style="font-size:2rem;"></i>
                    <div style="font-size:.88rem;font-weight:700;color:var(--tc-text);margin-top:.5rem;"><%: T("No upcoming live sessions.","Tiada kelas langsung akan datang.") %></div>
                    <div style="font-size:.78rem;color:var(--tc-muted);margin-bottom:.75rem;"><%: T("You're all caught up.","Anda telah selesai.") %></div>
                    <a href="<%: ResolveUrl("~/Teacher/liveSession.aspx") %>" style="display:inline-flex;align-items:center;gap:5px;padding:.45rem 1rem;border-radius:8px;background:var(--tc-primary);color:#fff;font-size:.78rem;font-weight:700;text-decoration:none;">
                        <i class="bi bi-plus-lg"></i> <%: T("Schedule Session","Jadualkan Sesi") %></a>
                </div>
            </asp:Panel>
        </div>
    </div>
    <%-- Notifications --%>
    <div class="td-card" style="flex:0.7;">
        <div class="td-card-body">
            <div class="td-sec-hd" style="margin-bottom:.75rem;">
                <div class="td-sec-title" style="font-size:.92rem;"><i class="bi bi-bell-fill" style="color:var(--tc-warning);"></i> <%: T("Notifications","Pemberitahuan") %></div>
                <a href="<%: ResolveUrl("~/Teacher/Notifications.aspx") %>" style="font-size:.78rem;font-weight:600;color:var(--tc-primary);text-decoration:none;"><%: T("View All","Lihat Semua") %> →</a>
            </div>
            <asp:Panel ID="pnlDashNotifs" runat="server" Visible="false">
                <div class="td-notif-list-v2">
                    <asp:Repeater ID="rptDashNotifs" runat="server">
                        <ItemTemplate>
                            <div class='td-nv2-item <%# Convert.ToBoolean(Eval("isRead")) ? "" : "unread" %>'>
                                <div class="td-nv2-ico"><i class="bi bi-bell"></i></div>
                                <div class="td-nv2-body">
                                    <div class="td-nv2-title"><%# HttpUtility.HtmlEncode(Eval("title")) %></div>
                                    <div class="td-nv2-msg"><%# HttpUtility.HtmlEncode(Eval("message")) %></div>
                                    <div class="td-nv2-time"><i class="bi bi-clock"></i> <%# Eval("timeAgo") %></div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </asp:Panel>
            <asp:Panel ID="pnlDashNotifsEmpty" runat="server">
                <div class="td-empty" style="padding:2rem;">
                    <i class="bi bi-bell-slash" style="font-size:2rem;"></i>
                    <div style="font-size:.88rem;font-weight:700;color:var(--tc-text);margin-top:.5rem;"><%: T("No new notifications.","Tiada pemberitahuan baharu.") %></div>
                    <div style="font-size:.78rem;color:var(--tc-muted);"><%: T("You're all caught up.","Anda telah selesai.") %></div>
                </div>
            </asp:Panel>
        </div>
    </div>
</div>

<%-- ── 5. OVERVIEW ── --%>
<div class="td-sec-hd">
    <div class="td-sec-title"><i class="bi bi-bar-chart-fill" style="color:var(--tc-primary);"></i> <%: T("Overview","Ringkasan") %></div>
</div>
<div class="td-stats">
    <a href="#" class="td-stat c-lessons">
        <div class="td-stat-icon" style="background:#EDE9FE;color:#6C63FF;"><i class="bi bi-file-earmark-text-fill"></i></div>
        <div class="td-stat-val"><asp:Literal ID="litTotalLessons" runat="server" Text="0" /></div>
        <div class="td-stat-lbl"><%: T("Total Materials","Jumlah Bahan") %></div>
    </a>
    <a href="#" class="td-stat c-quizzes">
        <div class="td-stat-icon" style="background:#FEF3C7;color:#D97706;"><i class="bi bi-patch-question-fill"></i></div>
        <div class="td-stat-val"><asp:Literal ID="litTotalQuizzes" runat="server" Text="0" /></div>
        <div class="td-stat-lbl"><%: T("Total Quizzes","Jumlah Kuiz") %></div>
    </a>
    <a href="#" class="td-stat c-sessions">
        <div class="td-stat-icon" style="background:#DBEAFE;color:#2563EB;"><i class="bi bi-camera-video-fill"></i></div>
        <div class="td-stat-val"><asp:Literal ID="litUpcomingSessions" runat="server" Text="0" /></div>
        <div class="td-stat-lbl"><%: T("Upcoming Live Sessions","Kelas Langsung Akan Datang") %></div>
    </a>
    <a href="#" class="td-stat c-students">
        <div class="td-stat-icon" style="background:#D1FAE5;color:#059669;"><i class="bi bi-people-fill"></i></div>
        <div class="td-stat-val"><asp:Literal ID="litTotalStudents" runat="server" Text="0" /></div>
        <div class="td-stat-lbl"><%: T("Total Students","Jumlah Pelajar") %></div>
    </a>
</div>

<%-- ── 5. PRACTICE QUIZ ENGAGEMENT ── --%>
<div class="td-sec-hd">
    <div class="td-sec-title"><i class="bi bi-clipboard2-pulse-fill" style="color:var(--tc-primary);"></i> Practice Quiz Engagement</div>
</div>
<p style="font-size:.82rem;color:var(--tc-muted);margin-top:-.5rem;margin-bottom:1.25rem;">Track student participation and performance for each of your approved practice quizzes.</p>

<asp:Panel ID="pnlPQCards" runat="server" Visible="false">
    <div class="td-pq-carousel-wrap">
        <button type="button" class="td-pq-arrow td-pq-arrow-left disabled" id="pqArrowLeft" onclick="pqSlide(-1)"><i class="bi bi-chevron-left"></i></button>
        <button type="button" class="td-pq-arrow td-pq-arrow-right" id="pqArrowRight" onclick="pqSlide(1)"><i class="bi bi-chevron-right"></i></button>
        <div class="td-pq-carousel">
            <div class="td-pq-track" id="pqTrack">
                <asp:Repeater ID="rptPracticeQuizCards" runat="server">
                    <ItemTemplate>
                        <div class="td-pq-slide">
                            <div class="td-pq-card">
                                <div class="td-pq-card-top">
                                    <span class="td-pq-badge-top td-pq-badge-questions"><%# Eval("questionCount") %> Questions</span>
                                    <span class="td-pq-badge-top td-pq-badge-lang-top"><%# Eval("langLabel") %></span>
                                </div>
                                <div class="td-pq-card-body">
                                    <div class="td-pq-title"><%# HttpUtility.HtmlEncode(Eval("title")) %></div>
                                    <div class="td-pq-info-row">
                                        <div class="td-pq-info-item">
                                            <i class="bi bi-mortarboard-fill"></i>
                                            <div><div class="td-pq-info-label">Level</div><div class="td-pq-info-value"><%# HttpUtility.HtmlEncode(Eval("levelName")) %></div></div>
                                        </div>
                                        <div class="td-pq-info-item">
                                            <i class="bi bi-bookmark-fill"></i>
                                            <div><div class="td-pq-info-label">Subtopic</div><div class="td-pq-info-value"><%# HttpUtility.HtmlEncode(Eval("subtopicName")) %></div></div>
                                        </div>
                                    </div>
                                    <div class="td-pq-metrics">
                                        <div class="td-pq-metric">
                                            <div class="td-pq-metric-ico" style="background:#EDE9FE;color:#6C63FF;"><i class="bi bi-people-fill"></i></div>
                                            <div class="td-pq-metric-text"><div class="td-pq-metric-val"><%# Eval("studentsAttempted") %></div><div class="td-pq-metric-lbl">Students Attempted</div></div>
                                        </div>
                                        <div class="td-pq-metric">
                                            <div class="td-pq-metric-ico" style="background:#DBEAFE;color:#2563EB;"><i class="bi bi-arrow-repeat"></i></div>
                                            <div class="td-pq-metric-text"><div class="td-pq-metric-val"><%# Eval("totalAttempts") %></div><div class="td-pq-metric-lbl">Total Attempts</div></div>
                                        </div>
                                        <div class="td-pq-metric">
                                            <div class="td-pq-metric-ico" style="background:#D1FAE5;color:#059669;"><i class="bi bi-trophy-fill"></i></div>
                                            <div class="td-pq-metric-text"><div class="td-pq-metric-val"><%# Eval("avgScore") %></div><div class="td-pq-metric-lbl">Average Score</div></div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
        <div class="td-pq-dots" id="pqDots"></div>
    </div>
</asp:Panel>

<asp:Panel ID="pnlPQEmpty" runat="server">
    <div class="td-pq-empty">
        <div class="td-pq-empty-ico"><i class="bi bi-clipboard2-pulse"></i></div>
        <div class="td-pq-empty-title">No Approved Practice Quizzes Yet</div>
        <div class="td-pq-empty-sub">Your approved Practice Quiz engagement will appear here once a quiz has been approved.</div>
    </div>
</asp:Panel>

</asp:Panel>

</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
window.addEventListener('load',function(){
    var uPct=parseInt(document.querySelector('[id$="hidUnitPct"]').value)||0;
    var lPct=parseInt(document.querySelector('[id$="hidLevelPct"]').value)||0;
    var barU=document.getElementById('qcBarUnit');
    var barL=document.getElementById('qcBarLevel');
    setTimeout(function(){
        if(barU)barU.style.width=Math.min(uPct,100)+'%';
        if(barL)barL.style.width=Math.min(lPct,100)+'%';
    },150);
});

/* ── Available Topics Modal ── */
var _topicsData = null;
var _topicsLoaded = false;

function openTopicsModal() {
    document.getElementById('tdTopicsOverlay').classList.add('open');
    document.body.style.overflow = 'hidden';
    if (!_topicsLoaded) loadTopicsData();
}
function closeTopicsModal() {
    document.getElementById('tdTopicsOverlay').classList.remove('open');
    document.body.style.overflow = '';
}
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape' && document.getElementById('tdTopicsOverlay').classList.contains('open')) closeTopicsModal();
});

function loadTopicsData() {
    var body = document.getElementById('tdTopicsBody');
    body.innerHTML = '<div class="td-topics-loading"><i class="bi bi-arrow-repeat"></i><span>Loading topics...</span></div>';
    fetch(window.location.pathname.split('?')[0] + '/GetAvailableTopics', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    })
    .then(function(r) { return r.json(); })
    .then(function(resp) {
        _topicsData = resp.d || resp;
        _topicsLoaded = true;
        renderTopics(_topicsData);
    })
    .catch(function() {
        body.innerHTML = '<div class="td-topics-empty"><div class="td-topics-empty-ico"><i class="bi bi-wifi-off"></i></div><div class="td-topics-empty-title">Unable to load topics</div><div class="td-topics-empty-sub">Please try again later.</div></div>';
    });
}

function renderTopics(data) {
    var body = document.getElementById('tdTopicsBody');
    if (!data || !data.length) { body.innerHTML = '<div class="td-topics-empty"><div class="td-topics-empty-ico"><i class="bi bi-journal-x"></i></div><div class="td-topics-empty-title">No topics available</div><div class="td-topics-empty-sub">Topics will appear here once added.</div></div>'; return; }
    var levelIcons = ['bi-star','bi-rocket-takeoff','bi-lightning','bi-trophy','bi-gem'];
    var levelLabels = ['Foundation Level','Intermediate Level','Advanced Level','Expert Level','Master Level'];
    var html = '';
    for (var i = 0; i < data.length; i++) {
        var level = data[i];
        var lvlIdx = i % 5;
        var unitCount = level.Units ? level.Units.length : 0;
        html += '<div class="td-level-item" data-search="' + esc(level.LevelName).toLowerCase() + '">';
        html += '<div class="td-level-header td-lvl-' + lvlIdx + '" onclick="toggleAcc(this)">';
        html += '<div class="td-level-ico"><i class="bi ' + levelIcons[lvlIdx] + '"></i></div>';
        html += '<div class="td-level-name-wrap"><span class="td-level-name">' + esc(level.LevelName) + '</span><span class="td-level-sublabel">' + levelLabels[lvlIdx] + '</span></div>';
        html += '<span class="td-level-badge">' + unitCount + ' unit' + (unitCount !== 1 ? 's' : '') + '</span>';
        html += '<span class="td-acc-arrow"><i class="bi bi-chevron-right"></i></span>';
        html += '</div>';
        html += '<div class="td-level-content">';
        if (level.Units && level.Units.length) {
            for (var j = 0; j < level.Units.length; j++) {
                var unit = level.Units[j];
                var subCount = unit.Subtopics ? unit.Subtopics.length : 0;
                html += '<div class="td-unit-item" data-search="' + esc(unit.UnitName).toLowerCase() + '">';
                html += '<div class="td-unit-header" onclick="toggleAcc(this)">';
                html += '<div class="td-unit-ico"><i class="bi bi-bookmark-fill"></i></div>';
                html += '<span class="td-unit-name">' + esc(unit.UnitName) + '</span>';
                html += '<span class="td-unit-count">' + subCount + ' topic' + (subCount !== 1 ? 's' : '') + '</span>';
                html += '<span class="td-acc-arrow"><i class="bi bi-chevron-right"></i></span>';
                html += '</div>';
                html += '<div class="td-unit-content">';
                if (unit.Subtopics && unit.Subtopics.length) {
                    for (var k = 0; k < unit.Subtopics.length; k++) {
                        html += '<div class="td-subtopic-item" data-search="' + esc(unit.Subtopics[k]).toLowerCase() + '">' + esc(unit.Subtopics[k]) + '</div>';
                    }
                }
                html += '</div></div>';
            }
        }
        html += '</div></div>';
    }
    body.innerHTML = html;
}

function toggleAcc(header) {
    var parent = header.parentElement;
    var isOpen = parent.classList.contains('open');
    parent.classList.toggle('open');
    header.classList.toggle('open');
}

function filterTopics(query) {
    var q = query.toLowerCase().trim();
    var levels = document.querySelectorAll('.td-level-item');
    var anyVisible = false;
    for (var i = 0; i < levels.length; i++) {
        var level = levels[i];
        var units = level.querySelectorAll('.td-unit-item');
        var levelMatch = false;
        for (var j = 0; j < units.length; j++) {
            var unit = units[j];
            var subtopics = unit.querySelectorAll('.td-subtopic-item');
            var unitMatch = unit.getAttribute('data-search').indexOf(q) > -1;
            var anySubMatch = false;
            for (var k = 0; k < subtopics.length; k++) {
                var subMatch = subtopics[k].getAttribute('data-search').indexOf(q) > -1;
                subtopics[k].style.display = (!q || subMatch || unitMatch) ? '' : 'none';
                if (subMatch) anySubMatch = true;
            }
            var show = !q || unitMatch || anySubMatch;
            unit.style.display = show ? '' : 'none';
            if (show && q) { unit.classList.add('open'); unit.querySelector('.td-unit-header').classList.add('open'); }
            if (show) levelMatch = true;
        }
        var levelNameMatch = level.getAttribute('data-search').indexOf(q) > -1;
        var showLevel = !q || levelMatch || levelNameMatch;
        level.style.display = showLevel ? '' : 'none';
        if (showLevel) anyVisible = true;
        if ((levelMatch || levelNameMatch) && q) { level.classList.add('open'); level.querySelector('.td-level-header').classList.add('open'); }
        if (!q) {
            level.classList.remove('open'); level.querySelector('.td-level-header').classList.remove('open');
            var us = level.querySelectorAll('.td-unit-item');
            for (var m = 0; m < us.length; m++) { us[m].classList.remove('open'); us[m].querySelector('.td-unit-header').classList.remove('open'); }
        }
    }
    // Show/hide empty search state
    var emptyEl = document.getElementById('tdTopicsSearchEmpty');
    if (q && !anyVisible) {
        if (!emptyEl) {
            emptyEl = document.createElement('div');
            emptyEl.id = 'tdTopicsSearchEmpty';
            emptyEl.className = 'td-topics-empty';
            emptyEl.innerHTML = '<div class="td-topics-empty-ico"><i class="bi bi-search"></i></div><div class="td-topics-empty-title">No topics found</div><div class="td-topics-empty-sub">Try another keyword.</div>';
            document.getElementById('tdTopicsBody').appendChild(emptyEl);
        }
        emptyEl.style.display = '';
    } else if (emptyEl) {
        emptyEl.style.display = 'none';
    }
}

function esc(s) { var d = document.createElement('div'); d.textContent = s || ''; return d.innerHTML; }

/* ── Practice Quiz Carousel ── */
(function(){
    var track = document.getElementById('pqTrack');
    if (!track) return;
    var slides = track.querySelectorAll('.td-pq-slide');
    if (!slides.length) return;
    var total = slides.length;
    var idx = 0;

    function getVisible() {
        if (window.innerWidth <= 767) return 1;
        if (window.innerWidth <= 1023) return 2;
        return 3;
    }

    function setSlideWidths() {
        var vis = getVisible();
        var pct = 100 / vis;
        for (var i = 0; i < slides.length; i++) slides[i].style.width = pct + '%';
    }

    function render() {
        var vis = getVisible();
        var maxIdx = Math.max(0, total - vis);
        if (idx > maxIdx) idx = maxIdx;
        var pct = -(idx * (100 / vis));
        track.style.transform = 'translateX(' + pct + '%)';
        var left = document.getElementById('pqArrowLeft');
        var right = document.getElementById('pqArrowRight');
        if (left) { if (idx <= 0) left.classList.add('disabled'); else left.classList.remove('disabled'); }
        if (right) { if (idx >= maxIdx) right.classList.add('disabled'); else right.classList.remove('disabled'); }
        // Hide arrows if all fit
        if (total <= vis) { if (left) left.style.display='none'; if (right) right.style.display='none'; }
        else { if (left) left.style.display=''; if (right) right.style.display=''; }
        renderDots(vis, maxIdx);
    }

    function renderDots(vis, maxIdx) {
        var dotsEl = document.getElementById('pqDots');
        if (!dotsEl) return;
        var count = maxIdx + 1;
        if (count <= 1) { dotsEl.innerHTML = ''; return; }
        var html = '';
        for (var i = 0; i < count; i++) {
            html += '<span class="td-pq-dot' + (i === idx ? ' active' : '') + '" onclick="pqGoTo(' + i + ')"></span>';
        }
        dotsEl.innerHTML = html;
    }

    window.pqSlide = function(dir) { idx += dir; render(); };
    window.pqGoTo = function(i) { idx = i; render(); };

    setSlideWidths();
    render();
    window.addEventListener('resize', function() { setSlideWidths(); render(); });
})();
</script>
</asp:Content>