<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="manageQuiz.aspx.cs"
    Inherits="ScienceBuddy.Teacher.manageQuiz" MasterPageFile="~/Site.Master"
    Title="Manage Quizzes" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--tc-primary:#6C63FF;--tc-hover:#5A52E0;--tc-light-bg:#F5F3FF;--tc-card-bg:#FFF;--tc-border:#E5E7EB;--tc-text:#374151;--tc-muted:#6B7280;--tc-info:#3B82F6;--tc-success:#10B981;--tc-error:#EF4444;--tc-warning:#F59E0B;}
.mq-page-title{font-size:1.5rem;font-weight:800;color:var(--tc-text);margin:0;}
.mq-page-sub{font-size:.85rem;color:var(--tc-muted);margin:.3rem 0 0;}
.mq-btn-create{display:inline-flex;align-items:center;gap:6px;background:#2563EB;border:none;border-radius:10px;padding:.6rem 1.25rem;font-weight:700;font-size:.85rem;color:#fff;cursor:pointer;text-decoration:none;transition:background .2s,box-shadow .2s;box-shadow:0 2px 8px rgba(37,99,235,.18);}
.mq-btn-create:hover{background:#1D4ED8;box-shadow:0 4px 16px rgba(37,99,235,.28);color:#fff;text-decoration:none;}
/* Tabs */
.mq-tabs{display:flex;gap:0;border-bottom:2px solid var(--tc-border);margin-bottom:1.25rem;}
.mq-tab{padding:.7rem 1.3rem;font-size:.9rem;font-weight:700;cursor:pointer;border:none;background:transparent;color:var(--tc-muted);transition:color .15s;text-decoration:none;margin-bottom:-2px;border-bottom:2.5px solid transparent;display:inline-flex;align-items:center;gap:5px;}
.mq-tab:hover{color:var(--tc-primary);text-decoration:none;}
.mq-tab.active{color:var(--tc-primary);border-bottom-color:var(--tc-primary);}
/* Filter */
.mq-filter-bar{display:flex;align-items:center;gap:10px;margin-bottom:1.75rem;flex-wrap:nowrap;}
.mq-search-wrap{position:relative;width:280px;flex-shrink:0;}
.mq-search-wrap i{position:absolute;left:12px;top:50%;transform:translateY(-50%);font-size:.85rem;color:var(--tc-muted);pointer-events:none;}
.mq-search-input{width:100%;height:40px;padding:0 .75rem 0 2.2rem;border-radius:10px;border:1.5px solid var(--tc-border);font-size:.83rem;background:var(--tc-card-bg);transition:border-color .2s;}
.mq-search-input:focus{border-color:var(--tc-primary);outline:none;box-shadow:0 0 0 3px rgba(108,99,255,.08);}
.mq-select{width:145px;height:40px;flex-shrink:0;border-radius:10px;border:1.5px solid var(--tc-border);padding:0 .65rem;font-size:.82rem;background:var(--tc-card-bg);color:var(--tc-text);cursor:pointer;}
.mq-select:focus{border-color:var(--tc-primary);outline:none;}
.mq-btn-search{width:90px;height:40px;background:var(--tc-primary);border:none;border-radius:10px;font-weight:700;font-size:.83rem;color:#fff;cursor:pointer;transition:background .2s;}
.mq-btn-search:hover{background:var(--tc-hover);}
/* Segmented Filter */
.mq-seg-wrap{margin-bottom:1.25rem;}
.mq-seg{display:inline-flex;border-radius:10px;border:1.5px solid var(--tc-border);background:#F9FAFB;padding:3px;gap:0;}
.mq-seg-btn{padding:.5rem 1.1rem;border:none;border-radius:8px;background:transparent;font-size:.84rem;font-weight:600;color:var(--tc-text);cursor:pointer;transition:all .15s;white-space:nowrap;}
.mq-seg-btn:hover{background:#F3F4F6;}
.mq-seg-active{background:var(--tc-primary) !important;color:#fff !important;box-shadow:0 2px 6px rgba(108,99,255,.2);}
/* Carousel (Discover only) */
.mq-carousel-wrap{position:relative;overflow:hidden;padding:.25rem 0;}
.mq-carousel{display:flex;gap:1rem;overflow-x:auto;scroll-behavior:smooth;padding:.5rem .25rem;-ms-overflow-style:none;scrollbar-width:none;}
.mq-carousel::-webkit-scrollbar{display:none;}
.mq-arrow{position:absolute;top:50%;transform:translateY(-50%);width:38px;height:38px;border-radius:50%;border:1.5px solid var(--tc-border);background:var(--tc-card-bg);display:flex;align-items:center;justify-content:center;cursor:pointer;font-size:1rem;color:var(--tc-text);transition:all .2s;z-index:2;box-shadow:0 2px 8px rgba(0,0,0,.08);opacity:0;}
.mq-carousel-wrap:hover .mq-arrow{opacity:1;}
.mq-arrow:hover{border-color:var(--tc-primary);color:var(--tc-primary);box-shadow:0 4px 14px rgba(108,99,255,.15);}
.mq-arrow-left{left:6px;}
.mq-arrow-right{right:6px;}
/* Discover cards keep fixed width for slider */
.mq-carousel .mq-dcard{min-width:280px;max-width:280px;flex-shrink:0;}
.mq-carousel .mq-card{min-width:270px;max-width:270px;flex-shrink:0;}
/* Discover Card */
.mq-dcard{background:var(--tc-card-bg);border-radius:16px;overflow:hidden;box-shadow:0 3px 12px rgba(0,0,0,.06);transition:transform .25s ease,box-shadow .25s ease;border:1px solid #F0F0F0;display:flex;flex-direction:column;}
.mq-dcard:hover{transform:translateY(-5px);box-shadow:0 12px 36px rgba(108,99,255,.14);}
.mq-dcard-img-wrap{position:relative;width:100%;height:160px;overflow:hidden;border-radius:16px 16px 0 0;}
.mq-dcard-cover{
    width:100%;height:100%;position:relative;
    background:linear-gradient(135deg,#0F766E 0%,#0D9488 35%,#14B8A6 70%,#2DD4BF 100%);
    transition:transform .4s ease;
}
/* Layered radial depth */
.mq-dcard-cover::before{
    content:'';position:absolute;inset:0;
    background:
        radial-gradient(ellipse 130% 90% at 25% 40%, rgba(255,255,255,.1) 0%, transparent 55%),
        radial-gradient(circle 70px at 75% 35%, rgba(255,255,255,.08) 0%, transparent 65%),
        radial-gradient(circle 100px at 50% 130%, rgba(0,0,0,.07) 0%, transparent 55%);
    pointer-events:none;z-index:1;
}
/* Pattern 1 (default): Atom + Orbit Rings + Sparkles — centre focal point */
.mq-dcard-cover::after{
    content:'';position:absolute;inset:0;z-index:2;pointer-events:none;
    background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='400' height='200'%3E%3C!-- Central atom nucleus --%3E%3Ccircle cx='200' cy='95' r='8' fill='rgba(255,255,255,.15)'/%3E%3C!-- Orbit ring 1 (horizontal ellipse) --%3E%3Cellipse cx='200' cy='95' rx='55' ry='22' fill='none' stroke='rgba(255,255,255,.16)' stroke-width='1.3'/%3E%3C!-- Orbit ring 2 (tilted) --%3E%3Cellipse cx='200' cy='95' rx='55' ry='22' fill='none' stroke='rgba(255,255,255,.13)' stroke-width='1.1' transform='rotate(60 200 95)'/%3E%3C!-- Orbit ring 3 (tilted opposite) --%3E%3Cellipse cx='200' cy='95' rx='55' ry='22' fill='none' stroke='rgba(255,255,255,.11)' stroke-width='1' transform='rotate(-60 200 95)'/%3E%3C!-- Electron dots on orbits --%3E%3Ccircle cx='255' cy='95' r='4' fill='rgba(255,255,255,.2)'/%3E%3Ccircle cx='172' cy='72' r='3.5' fill='rgba(255,255,255,.18)'/%3E%3Ccircle cx='220' cy='115' r='3' fill='rgba(255,255,255,.15)'/%3E%3C!-- Sparkle crosses --%3E%3Cpath d='M320 35 L320 43 M316 39 L324 39' stroke='rgba(255,255,255,.18)' stroke-width='1.3' stroke-linecap='round'/%3E%3Cpath d='M80 45 L80 53 M76 49 L84 49' stroke='rgba(255,255,255,.15)' stroke-width='1.2' stroke-linecap='round'/%3E%3Cpath d='M340 140 L340 146 M337 143 L343 143' stroke='rgba(255,255,255,.13)' stroke-width='1' stroke-linecap='round'/%3E%3Cpath d='M60 145 L60 151 M57 148 L63 148' stroke='rgba(255,255,255,.12)' stroke-width='1' stroke-linecap='round'/%3E%3C!-- Small floating dots --%3E%3Ccircle cx='100' cy='30' r='2' fill='rgba(255,255,255,.12)'/%3E%3Ccircle cx='350' cy='90' r='1.5' fill='rgba(255,255,255,.1)'/%3E%3Ccircle cx='45' cy='110' r='1.8' fill='rgba(255,255,255,.09)'/%3E%3Ccircle cx='310' cy='165' r='1.5' fill='rgba(255,255,255,.08)'/%3E%3C!-- Curved wave --%3E%3Cpath d='M0 170 Q100 150 200 165 T400 158' fill='none' stroke='rgba(255,255,255,.08)' stroke-width='1'/%3E%3C/svg%3E");
    background-size:cover;background-position:center;
    animation:pqHeaderShimmer 12s ease-in-out infinite alternate;
}
/* Pattern 2: Flask + Bubbles + Molecule nodes */
.mq-dcard:nth-child(3n+2) .mq-dcard-cover::after{
    background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='400' height='200'%3E%3C!-- Flask body (centre) --%3E%3Cpath d='M185 45 L185 100 L165 155 Q160 168 175 170 L225 170 Q240 168 235 155 L215 100 L215 45' fill='none' stroke='rgba(255,255,255,.18)' stroke-width='1.5' stroke-linecap='round' stroke-linejoin='round'/%3E%3C!-- Flask neck --%3E%3Cline x1='185' y1='45' x2='215' y2='45' stroke='rgba(255,255,255,.16)' stroke-width='1.5' stroke-linecap='round'/%3E%3C!-- Flask rim --%3E%3Cline x1='180' y1='40' x2='220' y2='40' stroke='rgba(255,255,255,.2)' stroke-width='2' stroke-linecap='round'/%3E%3C!-- Liquid level inside flask --%3E%3Cpath d='M172 135 Q185 128 200 132 Q215 136 228 130' fill='none' stroke='rgba(255,255,255,.12)' stroke-width='1'/%3E%3C!-- Bubbles inside flask --%3E%3Ccircle cx='195' cy='148' r='3.5' fill='none' stroke='rgba(255,255,255,.15)' stroke-width='1'/%3E%3Ccircle cx='205' cy='138' r='2.5' fill='none' stroke='rgba(255,255,255,.13)' stroke-width='1'/%3E%3Ccircle cx='190' cy='125' r='2' fill='rgba(255,255,255,.12)'/%3E%3C!-- Bubbles floating above flask --%3E%3Ccircle cx='200' cy='28' r='3' fill='none' stroke='rgba(255,255,255,.14)' stroke-width='1'/%3E%3Ccircle cx='210' cy='18' r='2' fill='none' stroke='rgba(255,255,255,.11)' stroke-width='.8'/%3E%3Ccircle cx='192' cy='22' r='1.5' fill='rgba(255,255,255,.1)'/%3E%3C!-- Molecule nodes (right side) --%3E%3Ccircle cx='320' cy='60' r='6' fill='rgba(255,255,255,.14)'/%3E%3Ccircle cx='350' cy='80' r='4.5' fill='rgba(255,255,255,.12)'/%3E%3Ccircle cx='330' cy='100' r='5' fill='rgba(255,255,255,.1)'/%3E%3Cline x1='320' y1='60' x2='350' y2='80' stroke='rgba(255,255,255,.12)' stroke-width='1.2'/%3E%3Cline x1='350' y1='80' x2='330' y2='100' stroke='rgba(255,255,255,.1)' stroke-width='1'/%3E%3Cline x1='320' y1='60' x2='330' y2='100' stroke='rgba(255,255,255,.08)' stroke-width='1'/%3E%3C!-- Molecule nodes (left side) --%3E%3Ccircle cx='65' cy='80' r='5' fill='rgba(255,255,255,.12)'/%3E%3Ccircle cx='85' cy='60' r='3.5' fill='rgba(255,255,255,.1)'/%3E%3Ccircle cx='50' cy='110' r='4' fill='rgba(255,255,255,.09)'/%3E%3Cline x1='65' y1='80' x2='85' y2='60' stroke='rgba(255,255,255,.1)' stroke-width='1'/%3E%3Cline x1='65' y1='80' x2='50' y2='110' stroke='rgba(255,255,255,.08)' stroke-width='1'/%3E%3C!-- Sparkle --%3E%3Cpath d='M350 150 L350 156 M347 153 L353 153' stroke='rgba(255,255,255,.14)' stroke-width='1.2' stroke-linecap='round'/%3E%3Cpath d='M60 150 L60 156 M57 153 L63 153' stroke='rgba(255,255,255,.11)' stroke-width='1' stroke-linecap='round'/%3E%3C/svg%3E");
}
/* Pattern 3: Planet + Stars + Hexagons */
.mq-dcard:nth-child(3n+3) .mq-dcard-cover::after{
    background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='400' height='200'%3E%3C!-- Planet (centre) --%3E%3Ccircle cx='200' cy='100' r='32' fill='none' stroke='rgba(255,255,255,.18)' stroke-width='1.5'/%3E%3C!-- Planet ring --%3E%3Cellipse cx='200' cy='100' rx='55' ry='14' fill='none' stroke='rgba(255,255,255,.15)' stroke-width='1.3' transform='rotate(-20 200 100)'/%3E%3C!-- Planet surface detail --%3E%3Cpath d='M175 90 Q190 85 210 92' fill='none' stroke='rgba(255,255,255,.1)' stroke-width='1'/%3E%3Cpath d='M180 110 Q195 115 215 108' fill='none' stroke='rgba(255,255,255,.08)' stroke-width='1'/%3E%3C!-- Stars (4-point) --%3E%3Cpath d='M80 40 L82 48 L80 56 L78 48 Z' fill='rgba(255,255,255,.16)'/%3E%3Cpath d='M80 40 L88 42 L80 44 L72 42 Z' fill='rgba(255,255,255,.16)'/%3E%3Cpath d='M330 30 L331.5 36 L330 42 L328.5 36 Z' fill='rgba(255,255,255,.14)'/%3E%3Cpath d='M330 30 L336 31.5 L330 33 L324 31.5 Z' fill='rgba(255,255,255,.14)'/%3E%3Cpath d='M60 140 L61 144 L60 148 L59 144 Z' fill='rgba(255,255,255,.12)'/%3E%3Cpath d='M60 140 L64 141 L60 142 L56 141 Z' fill='rgba(255,255,255,.12)'/%3E%3Cpath d='M350 120 L351 124 L350 128 L349 124 Z' fill='rgba(255,255,255,.11)'/%3E%3Cpath d='M350 120 L354 121 L350 122 L346 121 Z' fill='rgba(255,255,255,.11)'/%3E%3C!-- Small dot stars --%3E%3Ccircle cx='100' cy='25' r='1.5' fill='rgba(255,255,255,.13)'/%3E%3Ccircle cx='300' cy='165' r='1.8' fill='rgba(255,255,255,.1)'/%3E%3Ccircle cx='140' cy='160' r='1.3' fill='rgba(255,255,255,.09)'/%3E%3Ccircle cx='370' cy='55' r='1.5' fill='rgba(255,255,255,.08)'/%3E%3C!-- Hexagons (right) --%3E%3Cpath d='M320 130 L333 137 L333 151 L320 158 L307 151 L307 137 Z' fill='none' stroke='rgba(255,255,255,.14)' stroke-width='1.2'/%3E%3Cpath d='M340 155 L350 160 L350 170 L340 175 L330 170 L330 160 Z' fill='none' stroke='rgba(255,255,255,.1)' stroke-width='1'/%3E%3C!-- Hexagons (left) --%3E%3Cpath d='M55 60 L66 66 L66 78 L55 84 L44 78 L44 66 Z' fill='none' stroke='rgba(255,255,255,.12)' stroke-width='1.1'/%3E%3Cpath d='M75 80 L83 84 L83 92 L75 96 L67 92 L67 84 Z' fill='none' stroke='rgba(255,255,255,.09)' stroke-width='1'/%3E%3C!-- Wave --%3E%3Cpath d='M0 180 Q100 165 200 175 T400 170' fill='none' stroke='rgba(255,255,255,.07)' stroke-width='1'/%3E%3C/svg%3E");
}
/* Floating circles — decorative elements with animation */
.mq-dcard-img-wrap::before{
    content:'';position:absolute;z-index:3;pointer-events:none;
    width:70px;height:70px;border-radius:50%;
    top:-15px;right:25%;
    background:radial-gradient(circle, rgba(255,255,255,.1) 0%, rgba(255,255,255,.04) 50%, transparent 70%);
    border:1px solid rgba(255,255,255,.08);
    animation:pqFloat1 10s ease-in-out infinite;
}
.mq-dcard-img-wrap::after{
    content:'';position:absolute;z-index:3;pointer-events:none;
    width:45px;height:45px;border-radius:50%;
    bottom:15px;left:35%;
    background:radial-gradient(circle, rgba(255,255,255,.08) 0%, transparent 60%);
    border:1px solid rgba(255,255,255,.06);
    filter:blur(1px);
    animation:pqFloat2 13s ease-in-out infinite;
}
@keyframes pqFloat1{
    0%,100%{transform:translate(0,0) scale(1);}
    50%{transform:translate(8px,10px) scale(1.05);}
}
@keyframes pqFloat2{
    0%,100%{transform:translate(0,0) scale(1);}
    33%{transform:translate(-6px,-8px) scale(0.95);}
    66%{transform:translate(5px,-4px) scale(1.03);}
}
@keyframes pqHeaderShimmer{
    0%{opacity:.85;transform:translateX(0);}
    100%{opacity:1;transform:translateX(-2px);}
}
.mq-dcard:hover .mq-dcard-cover{transform:scale(1.04);}
.mq-dcard-badge{position:absolute;bottom:10px;padding:4px 11px;border-radius:50px;background:rgba(255,255,255,.95);font-size:.72rem;font-weight:700;color:var(--tc-text);box-shadow:0 2px 8px rgba(0,0,0,.1);backdrop-filter:blur(4px);z-index:5;}
.mq-dcard-badge-left{left:10px;}
.mq-dcard-badge-right{right:10px;}
.mq-dcard-body{padding:1.1rem 1.2rem;flex:1;display:flex;flex-direction:column;gap:8px;}
.mq-dcard-title{font-size:.95rem;font-weight:800;color:var(--tc-text);line-height:1.35;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;}
.mq-dcard-teacher{display:flex;align-items:center;gap:8px;margin-top:auto;}
.mq-dcard-teacher-avatar{width:28px;height:28px;border-radius:50%;background:#F3F4F6;color:#6C63FF;display:flex;align-items:center;justify-content:center;font-size:.85rem;flex-shrink:0;border:1.5px solid #E5E7EB;}
.mq-dcard-teacher-name{font-size:.8rem;font-weight:600;color:var(--tc-muted);}
.mq-dcard-actions{padding:.75rem 1.2rem;border-top:1px solid #F3F4F6;}
.mq-dcard-view{display:flex;align-items:center;justify-content:center;gap:5px;width:100%;padding:.55rem 0;border-radius:10px;background:#F0F7FF;color:var(--tc-info);font-size:.82rem;font-weight:700;text-decoration:none;border:1.5px solid #DBEAFE;transition:background .15s,border-color .15s;}
.mq-dcard-view:hover{background:#DBEAFE;border-color:#93C5FD;text-decoration:none;color:var(--tc-info);}
/* Practice Quiz card extras (metadata + edit/delete inside mq-dcard-body) */
.pqm-meta{display:flex;flex-wrap:wrap;align-items:center;gap:5px;margin-top:6px;}
.pqm-diff,.pqm-lang,.pqm-count{display:inline-flex;align-items:center;gap:3px;padding:2px 8px;border-radius:6px;font-size:.72rem;font-weight:600;}
.pqm-diff-easy{background:#D1FAE5;color:#047857;}
.pqm-diff-medium{background:#FEF3C7;color:#B45309;}
.pqm-diff-hard{background:#FEE2E2;color:#B91C1C;}
.pqm-lang{background:#EFF6FF;color:#1D4ED8;}
.pqm-count{background:#F3F4F6;color:#374151;}
.pqm-actions{display:flex;align-items:center;justify-content:flex-end;gap:6px;margin-top:8px;}
.pqm-btn{font-size:.75rem;font-weight:600;text-decoration:none;padding:4px 10px;border-radius:7px;border:1.5px solid;cursor:pointer;background:transparent;display:inline-flex;align-items:center;gap:3px;transition:background .15s;}
.pqm-btn-edit{color:#6C63FF;border-color:#EDE9FE;background:#F5F3FF;}.pqm-btn-edit:hover{background:#EDE9FE;text-decoration:none;color:#6C63FF;}
.pqm-btn-delete{color:#EF4444;border-color:#FEE2E2;background:#FEF2F2;}.pqm-btn-delete:hover{background:#FEE2E2;}
/* Pending License Notice (Unit/Level tab — soft red) */
.mq-pending-notice{display:flex;align-items:flex-start;gap:.75rem;padding:.85rem 1.1rem;margin-bottom:1.25rem;background:#FEF2F2;border:1.5px solid #FECACA;border-left:4px solid #DC2626;border-radius:10px;}
.mq-pending-notice-icon{flex-shrink:0;width:32px;height:32px;border-radius:8px;background:#FEE2E2;color:#DC2626;display:flex;align-items:center;justify-content:center;font-size:1rem;}
.mq-pending-notice-content{flex:1;min-width:0;}
.mq-pending-notice-title{font-size:.84rem;font-weight:700;color:#991B1B;margin-bottom:2px;}
.mq-pending-notice-msg{font-size:.78rem;color:#B91C1C;line-height:1.45;}
/* Disabled Add button */
.mq-ulq-btn-add.mq-btn-disabled{opacity:.5;cursor:not-allowed;pointer-events:none;background:#D1D5DB;border-color:#D1D5DB;color:#6B7280;box-shadow:none;}
.mq-ulq-btn-add.mq-btn-disabled:hover{background:#D1D5DB;border-color:#D1D5DB;transform:none;box-shadow:none;}
/* Disabled Create button */
.mq-btn-create.mq-btn-disabled{opacity:.5;cursor:not-allowed;pointer-events:none;background:#9CA3AF;box-shadow:none;}
/* View Quiz button — new class, replaces mq-dcard-view on both card types */
.pq-btn-view{display:flex;align-items:center;justify-content:center;gap:6px;width:100%;padding:.55rem 0;border-radius:10px;background:#F0F7FF;color:var(--tc-info);font-size:.82rem;font-weight:700;text-decoration:none;border:1.5px solid #DBEAFE;transition:background .15s,border-color .15s;box-sizing:border-box;}
.pq-btn-view:hover{background:#DBEAFE;border-color:#93C5FD;text-decoration:none;color:var(--tc-info);}
/* Practice Quiz card — status badge */
/* Practice Quiz card — status badge (top-left of header) */
.pq-status-pill{position:absolute;top:10px;left:10px;z-index:5;display:inline-block;padding:5px 14px;border-radius:50px;font-size:.78rem;font-weight:700;backdrop-filter:blur(4px);box-shadow:0 2px 6px rgba(0,0,0,.1);}
.pq-status-approved{background:rgba(204,251,241,.92);color:#0D9488;}
.pq-status-pending{background:rgba(254,243,199,.92);color:#B45309;}
.pq-status-rejected{background:rgba(254,226,226,.92);color:#B91C1C;}
/* Legacy body badge — hidden */
.pq-status-badge{display:none;}
/* Practice Quiz card — action buttons wrap */
.pq-card-actions-wrap{display:flex;flex-direction:column;gap:8px;padding:.75rem 1.2rem 1rem;}
.pq-action-view{display:flex;align-items:center;justify-content:center;gap:6px;width:100%;padding:.6rem 0;border-radius:10px;background:var(--tc-primary);color:#fff;font-size:.82rem;font-weight:700;text-decoration:none;border:none;cursor:pointer;transition:background .15s,box-shadow .15s;box-shadow:0 2px 8px rgba(108,99,255,.2);}
.pq-action-view:hover{background:var(--tc-hover);box-shadow:0 4px 14px rgba(108,99,255,.3);text-decoration:none;color:#fff;}
.pq-action-delete{display:flex;align-items:center;justify-content:center;gap:6px;width:100%;padding:.55rem 0;border-radius:10px;background:#FEF2F2;color:#EF4444;font-size:.82rem;font-weight:700;border:1.5px solid #FECACA;cursor:pointer;transition:background .15s,border-color .15s;}
.pq-action-delete:hover{background:#FEE2E2;border-color:#FCA5A5;}
.pq-action-resubmit{display:flex;align-items:center;justify-content:center;gap:6px;width:100%;padding:.55rem 0;border-radius:10px;background:#FFFBEB;color:#D97706;font-size:.82rem;font-weight:700;border:1.5px solid #FDE68A;cursor:pointer;transition:background .15s,border-color .15s;}
.pq-action-resubmit:hover{background:#FEF3C7;border-color:#FBBF24;}
/* Resubmit Modal */
.rsm-header{display:flex;align-items:flex-start;gap:1rem;padding:1.25rem 1.5rem;border-bottom:1px solid #FDE68A;background:linear-gradient(135deg,#FFFBEB,#FEF3C7);border-radius:16px 16px 0 0;}
.rsm-icon-wrap{width:44px;height:44px;border-radius:12px;background:#FEF3C7;border:1.5px solid #FDE68A;display:flex;align-items:center;justify-content:center;font-size:1.3rem;color:#D97706;flex-shrink:0;}
.rsm-header-text{flex:1;min-width:0;}
.rsm-title{font-size:1.1rem;font-weight:800;color:#92400E;margin:0;padding-top:4px;}
.rsm-body{padding:1.5rem 1.5rem 1rem;text-align:left;}
.rsm-msg{font-size:.92rem;font-weight:600;color:#1F2937;margin:0 0 .5rem;line-height:1.5;}
.rsm-sub{font-size:.84rem;color:#6B7280;margin:0;line-height:1.5;padding:.6rem .85rem;background:#FFFBEB;border:1px solid #FDE68A;border-radius:8px;}
.rsm-footer{display:flex;gap:.75rem;justify-content:flex-end;padding:1rem 1.5rem;border-top:1px solid #F3F4F6;}
.rsm-btn-cancel{background:#fff;border:1.5px solid #E5E7EB;border-radius:10px;padding:.6rem 1.2rem;font-weight:600;font-size:.84rem;color:#374151;cursor:pointer;transition:background .15s;}
.rsm-btn-cancel:hover{background:#F9FAFB;}
.rsm-btn-confirm{background:#F59E0B;border:none;border-radius:10px;padding:.6rem 1.3rem;font-weight:700;font-size:.84rem;color:#fff;cursor:pointer;display:inline-flex;align-items:center;gap:6px;transition:background .15s;box-shadow:0 2px 8px rgba(245,158,11,.25);}
.rsm-btn-confirm:hover{background:#D97706;box-shadow:0 4px 14px rgba(245,158,11,.35);}
.mq-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:1.1rem;padding:.25rem 0;}
@media(max-width:1200px){.mq-grid{grid-template-columns:repeat(3,1fr);}}
@media(max-width:900px){.mq-grid{grid-template-columns:repeat(2,1fr);}}
@media(max-width:600px){.mq-grid{grid-template-columns:1fr;}}
/* Status chips (filter bar) */
.mq-chips{display:flex;gap:6px;margin-bottom:1rem;flex-wrap:wrap;}
.mq-chip{display:inline-flex;align-items:center;padding:.4rem .9rem;border-radius:999px;font-size:.82rem;font-weight:600;cursor:pointer;border:1.5px solid var(--tc-border);background:var(--tc-card-bg);color:var(--tc-muted);transition:all .15s;text-decoration:none;}
.mq-chip:hover{background:#F3F4F6;text-decoration:none;}
.mq-chip.active{font-weight:700;}
.mq-chip[data-s="all"].active{background:#F3F4F6;color:#374151;border-color:#9CA3AF;}
.mq-chip[data-s="approved"].active{background:#D1FAE5;color:#047857;border-color:#6EE7B7;}
.mq-chip[data-s="pending"].active{background:#FEF3C7;color:#B45309;border-color:#FCD34D;}
.mq-chip[data-s="rejected"].active{background:#FEE2E2;color:#B91C1C;border-color:#FCA5A5;}
/* Shared badges used by other sections */
.mq-badge{padding:3px 10px;border-radius:50px;font-size:.7rem;font-weight:700;}
.mq-badge-pending{background:#FEF3C7;color:#B45309;}.mq-badge-approved{background:#CCFBF1;color:#0D9488;}.mq-badge-rejected{background:#FEE2E2;color:#B91C1C;}.mq-badge-active{background:#CCFBF1;color:#0D9488;}
.mq-diff{padding:2px 8px;border-radius:6px;font-size:.7rem;font-weight:700;}
.mq-diff-easy{background:#D1FAE5;color:#047857;}.mq-diff-medium{background:#FEF3C7;color:#B45309;}.mq-diff-hard{background:#FEE2E2;color:#B91C1C;}
/* Empty state */
.mq-empty{display:flex;flex-direction:column;align-items:center;padding:3.5rem;text-align:center;}
.mq-empty-title{font-size:1rem;font-weight:700;color:var(--tc-text);}
/* Table */
.mq-tbl{width:100%;border-collapse:collapse;font-size:.86rem;}
.mq-tbl th{background:#F9FAFB;font-weight:700;color:var(--tc-text);padding:.75rem .85rem;text-align:left;border-bottom:2px solid var(--tc-border);font-size:.8rem;text-transform:uppercase;letter-spacing:.3px;}
.mq-tbl td{padding:.75rem .85rem;border-bottom:1px solid #F3F4F6;color:var(--tc-text);vertical-align:middle;}
.mq-tbl tr:hover td{background:#FAFAFA;}
/* -- Practice Quiz Card -- */
.pq-card{
    background:#fff;border-radius:16px;border:1.5px solid #E5E7EB;
    box-shadow:0 2px 10px rgba(0,0,0,.05);
    display:flex;flex-direction:column;
    overflow:hidden;min-width:0;
    transition:transform .2s ease,box-shadow .2s ease;
    position:relative;
}
.pq-card:hover{transform:translateY(-4px);box-shadow:0 10px 28px rgba(13,148,136,.13);}
/* teal accent top bar — varies by status */
.pq-card::before{content:'';position:absolute;top:0;left:0;right:0;height:4px;background:#0D9488;}
.pq-card.pq-accent-approved::before{background:#0D9488;}
.pq-card.pq-accent-pending::before{background:#F59E0B;}
.pq-card.pq-accent-rejected::before{background:#EF4444;}
/* card top: icon left + status badge right */
.pq-card-top{
    padding:1.1rem 1.2rem .4rem;
    display:flex;align-items:flex-start;justify-content:space-between;
    gap:.5rem;
}
.pq-card-icon{
    width:42px;height:42px;border-radius:12px;flex-shrink:0;
    background:linear-gradient(135deg,#CCFBF1,#99F6E4);
    color:#0D9488;
    display:flex;align-items:center;justify-content:center;
    font-size:1.25rem;
}
/* status badge */
.pq-badge{padding:3px 10px;border-radius:50px;font-size:.7rem;font-weight:700;white-space:nowrap;}
.pq-badge-approved{background:#D1FAE5;color:#047857;}
.pq-badge-pending{background:#FEF3C7;color:#B45309;}
.pq-badge-rejected{background:#FEE2E2;color:#B91C1C;}
/* card body */
.pq-card-body{padding:.3rem 1.2rem .9rem;flex:1;display:flex;flex-direction:column;gap:4px;}
.pq-card-title{font-size:.98rem;font-weight:800;color:#1F2937;line-height:1.35;margin-bottom:2px;}
.pq-card-category{font-size:.75rem;color:#6B7280;font-weight:600;letter-spacing:.2px;}
/* metadata row */
.pq-card-meta{
    display:flex;flex-wrap:wrap;align-items:center;gap:6px;
    margin-top:6px;
}
.pq-meta-chip{
    display:inline-flex;align-items:center;gap:4px;
    padding:3px 9px;border-radius:7px;
    font-size:.74rem;font-weight:600;
}
.pq-meta-diff-easy{background:#D1FAE5;color:#047857;}
.pq-meta-diff-medium{background:#FEF3C7;color:#B45309;}
.pq-meta-diff-hard{background:#FEE2E2;color:#B91C1C;}
.pq-meta-lang{background:#EFF6FF;color:#1D4ED8;}
.pq-meta-count{background:#F3F4F6;color:#374151;}
/* divider */
.pq-card-divider{height:1px;background:#F3F4F6;margin:0 1.2rem;}
/* edit / delete row */
.pq-card-actions{
    display:flex;align-items:center;justify-content:flex-end;
    gap:6px;padding:.65rem 1.2rem .5rem;
}
.pq-act{
    font-size:.77rem;font-weight:600;
    text-decoration:none;padding:5px 11px;
    border-radius:8px;border:1.5px solid;cursor:pointer;
    background:transparent;
    display:inline-flex;align-items:center;gap:4px;
    transition:background .15s;
}
.pq-act-edit{color:#6C63FF;border-color:#EDE9FE;background:#F5F3FF;}
.pq-act-edit:hover{background:#EDE9FE;text-decoration:none;color:#6C63FF;}
.pq-act-delete{color:#EF4444;border-color:#FEE2E2;background:#FEF2F2;}
.pq-act-delete:hover{background:#FEE2E2;}
/* View Quiz button */
.pq-view-btn{
    display:flex;align-items:center;justify-content:center;gap:6px;
    margin:.1rem 1.2rem .9rem;
    padding:.6rem 0;border-radius:10px;
    background:linear-gradient(135deg,#0D9488,#14B8A6);
    color:#fff;font-size:.84rem;font-weight:700;
    text-decoration:none;border:none;cursor:pointer;
    transition:opacity .15s,box-shadow .15s;
    box-shadow:0 2px 8px rgba(13,148,136,.25);
}
.pq-view-btn:hover{opacity:.9;box-shadow:0 4px 14px rgba(13,148,136,.35);text-decoration:none;color:#fff;}
/* Unit/Level Cards - Horizontal layout with mini-cards */
.mq-ulq-card{
    display:flex;
    align-items:center;
    gap:1.25rem;
    padding:1.5rem 1.75rem;
    border-radius:22px;
    border:1.5px solid #F0EDF8;
    background:#fff;
    margin-bottom:1rem;
    box-shadow:0 2px 10px rgba(108,99,255,.04);
    transition:box-shadow .25s ease,transform .25s ease;
    width:100%;max-width:100%;box-sizing:border-box;min-width:0;
    overflow:hidden;position:relative;
}
.mq-ulq-card::after{
    content:'';position:absolute;bottom:0;left:0;right:0;height:5px;
    background:var(--card-accent,#6C63FF);border-radius:0 0 22px 22px;
}
.mq-ulq-card:nth-child(5n+1){--card-accent:#6C63FF;}
.mq-ulq-card:nth-child(5n+2){--card-accent:#2563EB;}
.mq-ulq-card:nth-child(5n+3){--card-accent:#0D9488;}
.mq-ulq-card:nth-child(5n+4){--card-accent:#EA580C;}
.mq-ulq-card:nth-child(5n+5){--card-accent:#DB2777;}
.mq-ulq-card:hover{
    box-shadow:0 12px 36px rgba(108,99,255,.10);
    transform:translateY(-3px);
}
.mq-ulq-left{display:flex;align-items:center;gap:14px;min-width:0;overflow:hidden;flex-shrink:0;max-width:200px;}
.mq-ulq-icon{
    width:50px;height:50px;border-radius:14px;
    display:flex;align-items:center;justify-content:center;
    font-size:1.3rem;flex-shrink:0;
    background:linear-gradient(135deg,#EDE9FE,#DDD6FE);color:#6C63FF;
    box-shadow:0 3px 10px rgba(108,99,255,.12);
}
.mq-ulq-icon-unit{background:linear-gradient(135deg,#EDE9FE,#DDD6FE);color:#6C63FF;}
.mq-ulq-icon-level{background:linear-gradient(135deg,#DBEAFE,#BFDBFE);color:#2563EB;}
.mq-ulq-info{min-width:0;overflow:hidden;}
.mq-ulq-title{font-size:1.05rem;font-weight:800;color:#1E1B4B;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.mq-ulq-labels{display:none;}

/* Statistic mini-cards container — CSS Grid with 5 equal columns */
.mq-ulq-stats{
    display:grid;
    grid-template-columns:repeat(5, minmax(0, 1fr));
    gap:.6rem;
    flex:1;
    min-width:0;
    align-items:stretch;
}

/* stat mini-card — uniform size box */
.mq-ulq-col{
    text-align:center;
    min-width:0;
    width:100%;
    min-height:90px;
    padding:.7rem .6rem;
    border-radius:12px;
    border:none;
    box-sizing:border-box;
    display:flex;flex-direction:column;
    align-items:center;justify-content:center;
}
/* Mini-card colour variants */
.mq-ulq-col--overall{background:#F3F0FF;}
.mq-ulq-col--submitted{background:#EFF6FF;}
.mq-ulq-col--approved{background:#F0FDFA;}
.mq-ulq-col--pending{background:#FFF7ED;}
.mq-ulq-col--rejected{background:#FEF2F2;}

.mq-ulq-col-label{
    font-size:.68rem;font-weight:600;color:#6B7280;
    margin-bottom:5px;line-height:1.3;
    display:flex;align-items:center;justify-content:center;gap:3px;
    text-align:center;
    white-space:normal;text-transform:uppercase;letter-spacing:.3px;
}
.mq-ulq-col-val{font-size:1.5rem;font-weight:900;color:#1E1B4B;line-height:1.1;}
.mq-val-overall{color:#6C63FF !important;}
.mq-val-approved{color:#0D9488 !important;}
.mq-val-pending{color:#B45309 !important;}
.mq-val-rejected{color:#B91C1C !important;}
/* Legacy badge classes — hidden, kept for backwards compat */
.mq-ulq-badge{display:none;}
.mq-ulq-badge-green,.mq-ulq-badge-amber,.mq-ulq-badge-red{display:none;}
.mq-ulq-badge-count{font-size:1.5rem;font-weight:900;margin-top:0;text-align:center;line-height:1.1;display:block;}
.mq-ulq-badge-count-green{color:#0D9488;}
.mq-ulq-badge-count-amber{color:#B45309;}
.mq-ulq-badge-count-red{color:#B91C1C;}

/* button column — fixed width, never overflows */
.mq-ulq-btn-col{
    display:flex;flex-direction:column;gap:8px;
    align-items:stretch;justify-content:center;
    padding-left:1rem;
    min-width:0;width:162px;flex-shrink:0;
}
.mq-ulq-btn{
    display:inline-flex;align-items:center;justify-content:center;
    gap:5px;padding:.55rem .75rem;
    border-radius:10px;border:1.5px solid #DDD6FE;
    background:#F5F3FF;color:#6C63FF;
    font-size:.8rem;font-weight:700;
    cursor:pointer;white-space:nowrap;text-decoration:none;
    transition:background .18s,border-color .18s,transform .18s,box-shadow .18s;
    width:100%;box-sizing:border-box;
}
.mq-ulq-btn:hover{
    background:#EDE9FE;border-color:#C4B5FD;
    text-decoration:none;color:#6C63FF;
    transform:translateY(-1px);box-shadow:0 3px 10px rgba(108,99,255,.14);
}
.mq-ulq-btn-add{
    border-color:#6C63FF;background:linear-gradient(135deg,#6C63FF,#5A52E0);color:#fff;
}
.mq-ulq-btn-add:hover{
    background:linear-gradient(135deg,#5A52E0,#4F46E5);border-color:#5A52E0;color:#fff;
    box-shadow:0 4px 14px rgba(108,99,255,.30);
    transform:translateY(-2px);
}
.mq-ul-empty{text-align:center;padding:2rem;font-size:.9rem;color:var(--tc-muted);background:#FAFAFA;border-radius:12px;border:1.5px dashed #E5E7EB;}
.mq-unit-group{margin-bottom:1.5rem;}
.mq-unit-group-hd{margin-bottom:.6rem;padding-bottom:.4rem;border-bottom:1.5px solid #EEF2FF;}
.mq-unit-group-num{display:none;}
.mq-unit-group-label{font-size:1.3rem;font-weight:800;color:#1E3A8A;}

/* Mid — compress stat mini-card spacing */
@media(max-width:1200px){
    .mq-ulq-card{padding:1.25rem 1.1rem;gap:1rem;}
    .mq-ulq-stats{gap:.5rem;}
    .mq-ulq-col{padding:.6rem .4rem;min-height:84px;}
    .mq-ulq-btn-col{width:140px;padding-left:.75rem;}
    .mq-ulq-left{max-width:170px;}
}
/* Wrap — card becomes column, stats grid to 3 cols */
@media(max-width:900px){
    .mq-ulq-card{
        flex-wrap:wrap;
        padding:1.1rem;
        gap:.75rem;
    }
    .mq-ulq-left{flex:0 0 100%;max-width:100%;border-bottom:1.5px solid #F3F4F6;padding-bottom:.75rem;}
    .mq-ulq-stats{grid-template-columns:repeat(3, minmax(0, 1fr));flex:1 1 100%;gap:.5rem;}
    .mq-ulq-col{min-height:80px;}
    .mq-ulq-btn-col{
        flex:0 0 auto;
        padding-left:0;
        width:100%;
        flex-direction:row;
        justify-content:flex-end;
    }
    .mq-ulq-btn{width:auto;flex:0 1 160px;}
}
/* Full collapse — stack everything, stats grid to 2 cols */
@media(max-width:600px){
    .mq-ulq-card{
        flex-direction:column;
        align-items:stretch;
        gap:.85rem;padding:1rem;
    }
    .mq-ulq-left{max-width:100%;border-bottom:1.5px solid #F3F4F6;padding-bottom:.75rem;}
    .mq-ulq-stats{grid-template-columns:repeat(2, minmax(0, 1fr));gap:.5rem;}
    .mq-ulq-col{min-height:78px;padding:.6rem .5rem;}
    .mq-ulq-btn-col{
        display:flex;flex-direction:row;gap:8px;
        align-items:center;justify-content:flex-end;
        padding-left:0;
        width:100%;
    }
    .mq-ulq-btn{width:auto;flex:1;max-width:160px;}
}
/* Modal */
.mq-modal-overlay{position:fixed;inset:0;background:rgba(17,24,39,.5);z-index:9000;display:flex;align-items:center;justify-content:center;padding:1rem;}
.mq-modal{background:#fff;border-radius:16px;width:100%;max-width:420px;box-shadow:0 20px 60px rgba(0,0,0,.2);animation:mqFade .2s ease;}
@keyframes mqFade{from{opacity:0;transform:translateY(10px);}to{opacity:1;transform:translateY(0);}}
.mq-modal-header{display:flex;align-items:center;justify-content:space-between;padding:1.25rem 1.5rem;border-bottom:1px solid var(--tc-border);}
.mq-modal-header h3{font-size:1.05rem;font-weight:800;color:var(--tc-text);margin:0;}
.mq-modal-close{background:none;border:none;font-size:1.4rem;color:var(--tc-muted);cursor:pointer;}.mq-modal-close:hover{color:var(--tc-text);}
.mq-modal-body{padding:1.5rem;text-align:center;}.mq-modal-body p{font-size:.9rem;color:var(--tc-text);margin:0;}
/* View Questions Popup */
.vq-header{margin-bottom:1.2rem;padding:1rem 1.1rem;background:#F8FAFC;border-radius:10px;border:1px solid #E2E8F0;}
.vq-header-titles{display:grid;grid-template-columns:1fr 1fr;gap:1rem;margin-bottom:8px;}
.vq-header-col{}
.vq-header-lang{font-size:.7rem;font-weight:700;color:#6B7280;text-transform:uppercase;letter-spacing:.3px;margin-bottom:3px;}
.vq-header-title{font-size:.92rem;font-weight:700;color:#1F2937;}
.vq-header-sub{font-size:.84rem;color:#6B7280;margin-top:2px;}
.vq-header-meta{font-size:.78rem;color:#6B7280;padding-top:6px;border-top:1px solid #E5E7EB;}
/* Practice Quiz View Modal */
.pq-overlay{
    position:fixed;inset:0;background:rgba(17,24,39,.55);
    z-index:9200;display:none;align-items:flex-start;justify-content:center;
    padding:2rem 1rem;overflow-y:auto;
}
.pq-overlay.open{display:flex;}
.pq-modal{
    background:#fff;border-radius:18px;width:100%;max-width:720px;
    display:flex;flex-direction:column;max-height:calc(100vh - 4rem);
    box-shadow:0 24px 64px rgba(0,0,0,.22);
    animation:pqFadeIn .22s ease;
    margin:auto;
}
@keyframes pqFadeIn{from{opacity:0;transform:translateY(14px);}to{opacity:1;transform:translateY(0);}}
.pq-modal-header{
    display:flex;align-items:flex-start;gap:1rem;
    padding:1.25rem 1.5rem;
    border-bottom:1.5px solid #E5E7EB;
    background:linear-gradient(135deg,#F5F3FF,#EEF2FF);
    border-radius:18px 18px 0 0;
    flex-shrink:0;
}
.pq-header-main{flex:1;min-width:0;}
.pq-header-title{
    font-size:1.05rem;font-weight:800;color:var(--tc-text);
    margin-bottom:.35rem;word-break:break-word;
    display:flex;align-items:center;gap:.5rem;flex-wrap:wrap;
}
/* status badge inside popup header */
.pq-header-status{padding:3px 10px;border-radius:50px;font-size:.7rem;font-weight:700;white-space:nowrap;flex-shrink:0;}
.pq-header-status-approved{background:#D1FAE5;color:#047857;}
.pq-header-status-pending{background:#FEF3C7;color:#B45309;}
.pq-header-status-rejected{background:#FEE2E2;color:#B91C1C;}
.pq-header-meta{
    display:flex;flex-wrap:wrap;gap:.5rem .9rem;
    font-size:.8rem;font-weight:600;color:var(--tc-muted);
}
.pq-header-meta span{display:inline-flex;align-items:center;gap:4px;}
.pq-close-btn{
    flex-shrink:0;width:34px;height:34px;border-radius:8px;border:1.5px solid #D1D5DB;
    background:#fff;display:flex;align-items:center;justify-content:center;
    font-size:.9rem;color:var(--tc-muted);cursor:pointer;
    transition:background .15s,border-color .15s,color .15s;
}
.pq-close-btn:hover{background:#FEF2F2;border-color:#FCA5A5;color:#B91C1C;}
.pq-modal-body{flex:1;overflow-y:auto;padding:1.25rem 1.5rem;}
/* Single-language question card header: Q# left, difficulty badge right */
.pq-card-hd{display:flex;align-items:center;padding:.8rem 1rem;cursor:pointer;user-select:none;transition:background .12s;}
.pq-card-hd:hover{background:#F9FAFB;}
.pq-card-hd .vq-card-num{flex:1;font-size:.92rem;font-weight:800;color:#1F2937;}
.pq-card-hd .pq-diff-badge{margin-left:auto;flex-shrink:0;}
.pq-card-hd .vq-chevron{margin-left:10px;flex-shrink:0;}
/* Single-language content — full width, no two-column grid */
.pq-single-col{width:100%;}
@media(max-width:600px){
    .pq-overlay{padding:.5rem;}
    .pq-modal{border-radius:14px;max-height:calc(100vh - 1rem);}
    .pq-modal-header{padding:1rem;}
    .pq-modal-body{padding:1rem;}
}
.vq-card{border:1.5px solid #E5E7EB;border-radius:12px;margin-bottom:.7rem;background:#fff;overflow:hidden;box-shadow:0 1px 4px rgba(0,0,0,.03);}
.vq-card-hd{display:flex;align-items:center;gap:8px;padding:.8rem 1rem;cursor:pointer;user-select:none;transition:background .12s;}
.vq-card-hd:hover{background:#F9FAFB;}
.vq-card-num{font-size:.92rem;font-weight:800;color:#1F2937;}
.vq-status-badge{margin-left:auto;}
.vq-chevron{font-size:.85rem;color:#9CA3AF;transition:transform .2s;margin-left:8px;}
.vq-expanded .vq-chevron{transform:rotate(180deg);}
.vq-card-body{display:none;padding:1rem 1.1rem;border-top:1px solid #F3F4F6;}
.vq-expanded .vq-card-body{display:block;}
.vq-badge{padding:3px 9px;border-radius:6px;font-size:.7rem;font-weight:700;}
.vq-badge-blue{background:#DBEAFE;color:#1D4ED8;}
.vq-badge-green{background:#D1FAE5;color:#047857;}
.vq-badge-amber{background:#FEF3C7;color:#B45309;}
.vq-badge-red{background:#FEE2E2;color:#B91C1C;}
.vq-format-row{margin-bottom:12px;display:flex;align-items:center;gap:6px;font-size:.84rem;}
.vq-format-label{font-weight:700;color:#374151;}
.vq-format-val{font-weight:600;color:#374151;}
/* Drag & Drop */
.vq-dd-section{margin-bottom:10px;}
.vq-dd-label{font-size:.76rem;font-weight:700;color:#6B7280;margin-bottom:5px;}
.vq-dd-items{display:flex;flex-wrap:wrap;gap:6px;}
.vq-dd-item{padding:6px 12px;border-radius:8px;border:1.5px solid #E5E7EB;background:#F9FAFB;font-size:.82rem;font-weight:600;color:#374151;}
.vq-dd-order{margin-bottom:10px;padding:.6rem .8rem;border-radius:8px;background:#F0FDF4;border:1px solid #BBF7D0;}
.vq-dd-order-list{margin:0;padding:0 0 0 1.4rem;font-size:.82rem;font-weight:600;color:#047857;line-height:1.9;list-style-type:decimal;}
.vq-cols{display:grid;grid-template-columns:1fr 1fr;gap:1.2rem;}
.vq-col-hd{font-size:.82rem;font-weight:700;color:#374151;margin-bottom:8px;padding-bottom:5px;border-bottom:1px solid #F3F4F6;}
.vq-question{font-size:.88rem;font-weight:600;color:#374151;margin-bottom:10px;line-height:1.5;}
.vq-options{display:flex;flex-direction:column;gap:5px;margin-bottom:10px;}
.vq-opt{display:flex;align-items:center;gap:8px;padding:7px 10px;border-radius:8px;border:1.5px solid #E5E7EB;background:#fff;font-size:.82rem;color:#374151;transition:background .12s;}
.vq-opt-correct{background:#ECFDF5;border-color:#A7F3D0;color:#047857;font-weight:600;}
.vq-opt-correct i{color:#059669;margin-left:auto;font-size:.85rem;}
.vq-opt-label{width:22px;height:22px;border-radius:6px;background:#F3F4F6;display:flex;align-items:center;justify-content:center;font-size:.72rem;font-weight:800;color:#6B7280;flex-shrink:0;}
.vq-opt-correct .vq-opt-label{background:#D1FAE5;color:#047857;}
.vq-opt-text{flex:1;min-width:0;}
.vq-expl{padding:.6rem .8rem;border-radius:8px;margin-bottom:8px;font-size:.8rem;line-height:1.5;}
.vq-expl-title{font-size:.74rem;font-weight:700;margin-bottom:3px;display:flex;align-items:center;gap:4px;}
.vq-expl-correct{background:#F0FDF4;border:1px solid #BBF7D0;}.vq-expl-correct .vq-expl-title{color:#047857;}
.vq-expl-wrong{background:#FEF2F2;border:1px solid #FECACA;}.vq-expl-wrong .vq-expl-title{color:#B91C1C;}
.vq-img-row{margin-top:8px;font-size:.8rem;color:#6B7280;display:flex;align-items:center;gap:5px;}
.vq-img-link{color:#2563EB;font-weight:600;text-decoration:none;}.vq-img-link:hover{text-decoration:underline;}
/* Image Preview Modal */
.vq-img-modal{position:fixed;inset:0;background:rgba(0,0,0,.7);z-index:9500;display:none;align-items:center;justify-content:center;padding:2rem;}
.vq-img-modal.active{display:flex;}
.vq-img-modal-box{background:#fff;border-radius:14px;max-width:680px;width:100%;max-height:85vh;display:flex;flex-direction:column;box-shadow:0 20px 60px rgba(0,0,0,.3);}
.vq-img-modal-hd{display:flex;align-items:center;justify-content:space-between;padding:.8rem 1.2rem;border-bottom:1px solid #E5E7EB;}
.vq-img-modal-hd span{font-size:.88rem;font-weight:700;color:#374151;}
.vq-img-modal-close{background:none;border:none;font-size:1.3rem;color:#6B7280;cursor:pointer;}.vq-img-modal-close:hover{color:#374151;}
.vq-img-modal-body{flex:1;overflow:auto;padding:1rem;text-align:center;}
.vq-img-modal-body img{max-width:100%;max-height:65vh;border-radius:8px;}
@media(max-width:700px){.vq-cols{grid-template-columns:1fr;}.vq-header-titles{grid-template-columns:1fr;}}
.mq-modal-footer{display:flex;gap:.75rem;justify-content:center;padding:1rem 1.5rem;border-top:1px solid var(--tc-border);}
.mq-btn-cancel{background:#fff;border:1.5px solid var(--tc-border);border-radius:10px;padding:.55rem 1.1rem;font-weight:600;font-size:.84rem;color:var(--tc-text);cursor:pointer;}
.mq-btn-danger{background:var(--tc-error);border:none;border-radius:10px;padding:.55rem 1.25rem;font-weight:700;font-size:.84rem;color:#fff;cursor:pointer;}
/* Toast */
.mq-toast-container{position:fixed;top:1.25rem;right:1.25rem;z-index:9999;display:flex;flex-direction:column;gap:.5rem;}
.mq-toast{background:var(--tc-primary);color:#fff;padding:.75rem 1.25rem;border-radius:10px;font-size:.84rem;font-weight:600;display:flex;align-items:center;gap:8px;box-shadow:0 8px 24px rgba(108,99,255,.3);animation:mqSlideIn .3s ease;}
.mq-toast-out{animation:mqSlideOut .4s ease forwards;}
@keyframes mqSlideIn{from{opacity:0;transform:translateX(30px);}to{opacity:1;transform:translateX(0);}}
@keyframes mqSlideOut{from{opacity:1;}to{opacity:0;transform:translateX(30px);}}
.mq-val-msg{font-size:.72rem;color:var(--tc-error);margin-top:3px;min-height:14px;}
/* -- Discover Quiz View Modal ------------------------- */
.dq-overlay{
    position:fixed;inset:0;background:rgba(17,24,39,.55);
    z-index:9100;display:none;align-items:flex-start;justify-content:center;
    padding:2rem 1rem;overflow-y:auto;
}
.dq-overlay.open{display:flex;}
.dq-modal{
    background:#fff;border-radius:18px;width:100%;max-width:860px;
    display:flex;flex-direction:column;max-height:calc(100vh - 4rem);
    box-shadow:0 24px 64px rgba(0,0,0,.22);
    animation:dqFadeIn .22s ease;
    margin:auto;
}
@keyframes dqFadeIn{from{opacity:0;transform:translateY(14px);}to{opacity:1;transform:translateY(0);}}
.dq-modal-header{
    display:flex;align-items:flex-start;gap:1rem;
    padding:1.25rem 1.5rem;
    border-bottom:1.5px solid #E5E7EB;
    background:linear-gradient(135deg,#F0F7FF,#EEF2FF);
    border-radius:18px 18px 0 0;
    flex-shrink:0;
}
.dq-header-main{flex:1;min-width:0;}
.dq-header-title{
    font-size:1.05rem;font-weight:800;color:var(--tc-text);
    margin-bottom:.35rem;word-break:break-word;
}
.dq-header-meta{
    display:flex;flex-wrap:wrap;gap:.5rem .9rem;
    font-size:.8rem;font-weight:600;color:var(--tc-muted);
}
.dq-header-meta span{display:inline-flex;align-items:center;gap:4px;}
.dq-close-btn{
    flex-shrink:0;width:34px;height:34px;border-radius:8px;border:1.5px solid #D1D5DB;
    background:#fff;display:flex;align-items:center;justify-content:center;
    font-size:.9rem;color:var(--tc-muted);cursor:pointer;
    transition:background .15s,border-color .15s,color .15s;
}
.dq-close-btn:hover{background:#FEF2F2;border-color:#FCA5A5;color:#B91C1C;}
.dq-modal-body{
    flex:1;overflow-y:auto;padding:1.25rem 1.5rem;
    /* keep page behind fixed when modal is open */
}
@media(max-width:600px){
    .dq-overlay{padding:.5rem;}
    .dq-modal{border-radius:14px;max-height:calc(100vh - 1rem);}
    .dq-modal-header{padding:1rem;}
    .dq-modal-body{padding:1rem;}
}
/* Info icon — pointer cursor, white-bg tooltip */
.mq-info-icon{
    display:inline-flex;align-items:center;justify-content:center;
    color:#9CA3AF;
    font-size:.75rem;cursor:pointer;
    position:relative;vertical-align:middle;margin-left:3px;flex-shrink:0;
    transition:color .15s;
}
.mq-info-icon:hover,.mq-info-icon:focus{color:#6C63FF;outline:none;}
.mq-info-icon::after{
    content:attr(data-tip);
    position:absolute;top:calc(100% + 9px);left:50%;transform:translateX(-50%);
    background:#fff;color:#374151;
    font-size:.75rem;font-weight:500;line-height:1.5;
    padding:8px 12px;border-radius:10px;
    border:1px solid #E5E7EB;
    white-space:normal;width:240px;text-align:left;
    pointer-events:none;opacity:0;transition:opacity .2s ease,transform .2s ease;
    z-index:200;
    box-shadow:0 6px 20px rgba(0,0,0,.10);
    transform:translateX(-50%) translateY(4px);
}
.mq-info-icon::before{
    content:'';position:absolute;top:calc(100% + 4px);left:50%;
    transform:translateX(-50%);
    border:5px solid transparent;border-bottom-color:#E5E7EB;
    pointer-events:none;opacity:0;transition:opacity .2s ease;z-index:200;
}
.mq-info-icon:hover::before,.mq-info-icon:focus::before{opacity:1;}
.mq-info-icon:hover::after,.mq-info-icon:focus::after{opacity:1;transform:translateX(-50%) translateY(0);}
@media(max-width:900px){.mq-filter-bar{flex-wrap:wrap;}.mq-search-wrap{width:100%;}.mq-select{flex:1;min-width:120px;width:auto;}.mq-btn-search{flex:0;}}
@media(max-width:640px){.mq-filter-bar{flex-direction:column;align-items:stretch;}.mq-select{width:100%;}.mq-btn-search{width:100%;}.mq-card{min-width:260px;max-width:260px;}}
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
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Manage Quizzes","Urus Kuiz") %></asp:Content>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<asp:Panel ID="pnlDenied" runat="server" Visible="false">
    <div style="display:flex;flex-direction:column;align-items:center;padding:3rem;text-align:center;">
        <div style="font-size:3rem;margin-bottom:1rem;">??</div>
        <h2 style="color:var(--tc-text);font-weight:800;"><%: T("Access Denied","Akses Ditolak") %></h2>
        <p style="color:var(--tc-muted);max-width:450px;"><%: T("Your account cannot access this page.","Akaun anda tidak boleh mengakses halaman ini.") %></p>
    </div>
</asp:Panel>

<asp:Panel ID="pnlMain" runat="server" Visible="false">

<%-- Header with Create button on right --%>
<div style="display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:1rem;flex-wrap:wrap;gap:.75rem;">
    <div>
        <h1 class="mq-page-title"><%: T("Manage Quizzes","Urus Kuiz") %></h1>
        <p class="mq-page-sub"><%: T("Create, manage, and discover quizzes.","Cipta, urus, dan terokai kuiz.") %></p>
    </div>
    <asp:Panel ID="pnlCreateBtn" runat="server">
        <button type="button" class="mq-btn-create" onclick="openPracticeModal()"><i class="bi bi-plus-lg"></i> <%: T("Create Quiz","Cipta Kuiz") %></button>
    </asp:Panel>
    <asp:Panel ID="pnlCreateULBtn" runat="server" Visible="false"></asp:Panel>
</div>

<%-- Tabs --%>
<div class="mq-tabs">
    <asp:LinkButton ID="btnTabUnitLevel" runat="server" CssClass="mq-tab active" OnClick="btnTabUnitLevel_Click" CausesValidation="false"><i class="bi bi-journal-text"></i> <%: T("Unit / Level Quizzes","Kuiz Unit / Tahap") %></asp:LinkButton>
    <asp:LinkButton ID="btnTabMine" runat="server" CssClass="mq-tab" OnClick="btnTabMine_Click" CausesValidation="false"><i class="bi bi-folder2-open"></i> <%: T("Practice Quizzes","Kuiz Latihan") %></asp:LinkButton>
    <asp:LinkButton ID="btnTabDiscover" runat="server" CssClass="mq-tab" OnClick="btnTabDiscover_Click" CausesValidation="false"><i class="bi bi-globe2"></i> <%: T("Discover Quizzes","Terokai Kuiz") %></asp:LinkButton>
</div>

<%-- Segmented Filter (Unit/Level tab only, client-side) --%>
<div id="ulSegFilter" class="mq-seg-wrap" style="display:none;">
    <div class="mq-seg">
        <button type="button" class="mq-seg-btn mq-seg-active" onclick="filterUL('all',this)"><%: T("All Quizzes","Semua Kuiz") %></button>
        <button type="button" class="mq-seg-btn" onclick="filterUL('unit',this)"><%: T("Unit Quizzes","Kuiz Unit") %></button>
        <button type="button" class="mq-seg-btn" onclick="filterUL('level',this)"><%: T("Level Quizzes","Kuiz Tahap") %></button>
    </div>
</div>

<%-- Search & Filter --%>
<div class="mq-filter-bar" id="mqFilterBar">
    <div class="mq-search-wrap"><i class="bi bi-search"></i>
        <asp:TextBox ID="txtSearch" runat="server" CssClass="mq-search-input" /></div>
    <asp:DropDownList ID="ddlDifficulty" runat="server" CssClass="mq-select" Visible="false" />
    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="mq-select" Visible="false" />
    <asp:DropDownList ID="ddlLanguage" runat="server" CssClass="mq-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed" />
    <asp:Button ID="btnSearch" runat="server" CssClass="mq-btn-search" OnClick="btnSearch_Click" CausesValidation="false" />
</div>

<%-- Status chips (My Quizzes only) --%>
<asp:Panel ID="pnlStatusChips" runat="server">
<div class="mq-chips">
    <asp:LinkButton ID="btnChipAll" runat="server" CssClass="mq-chip active" OnClick="btnChip_Click" CommandArgument="" CausesValidation="false" data-s="all"><%: T("All","Semua") %></asp:LinkButton>
    <asp:LinkButton ID="btnChipApproved" runat="server" CssClass="mq-chip" OnClick="btnChip_Click" CommandArgument="Approved" CausesValidation="false" data-s="approved"><%: T("Approved","Diluluskan") %></asp:LinkButton>
    <asp:LinkButton ID="btnChipPending" runat="server" CssClass="mq-chip" OnClick="btnChip_Click" CommandArgument="Pending" CausesValidation="false" data-s="pending"><%: T("Pending","Menunggu") %></asp:LinkButton>
    <asp:LinkButton ID="btnChipRejected" runat="server" CssClass="mq-chip" OnClick="btnChip_Click" CommandArgument="Rejected" CausesValidation="false" data-s="rejected"><%: T("Rejected","Ditolak") %></asp:LinkButton>
</div>
</asp:Panel>

<%-- Quiz Grid --%>
<asp:Panel ID="pnlQuizzes" runat="server" Visible="false">
    <div class="mq-grid">
        <asp:Repeater ID="rptQuizzes" runat="server">
            <ItemTemplate>
                <div class="mq-dcard">
                    <%-- Teal cover header --%>
                    <div class="mq-dcard-img-wrap">
                        <div class="mq-dcard-cover"></div>
                        <span class="pq-status-pill pq-status-<%# (Eval("status") ?? "Pending").ToString().ToLower() %>"><%# HttpUtility.HtmlEncode(Eval("status") ?? "Pending") %></span>
                        <span class="mq-dcard-badge mq-dcard-badge-left"><i class="bi bi-list-check"></i> <%# Eval("questionCount") %> Qs</span>
                        <span class="mq-dcard-badge mq-dcard-badge-right"><%# HttpUtility.HtmlEncode(Eval("language")?.ToString() ?? "") %></span>
                    </div>
                    <%-- Body: title only --%>
                    <div class="mq-dcard-body">
                        <div class="mq-dcard-title"><%# HttpUtility.HtmlEncode(Eval("quizTitle")) %></div>
                    </div>
                    <%-- Action buttons --%>
                    <div class="pq-card-actions-wrap">
                        <span class="pq-hidden-data" style="display:none;"
                              data-qid='<%# Eval("quizId") %>'
                              data-title='<%# HttpUtility.HtmlAttributeEncode((Eval("quizTitle") ?? "").ToString()) %>'
                              data-lang='<%# HttpUtility.HtmlAttributeEncode((Eval("language") ?? "").ToString()) %>'
                              data-count='<%# Eval("questionCount") %>'
                              data-status='<%# HttpUtility.HtmlAttributeEncode((Eval("status") ?? "").ToString()) %>'></span>
                        <a href="#" class="pq-action-view" onclick="openPracticeViewModal(this.closest('.pq-card-actions-wrap').querySelector('.pq-hidden-data'));return false;"><i class="bi bi-eye"></i> <%: T("View Quiz","Lihat Kuiz") %></a>
                        <button type="button" class="pq-action-resubmit" style='<%# (Eval("status") ?? "").ToString().Equals("Rejected", StringComparison.OrdinalIgnoreCase) ? "" : "display:none;" %>' onclick="resubmitQuiz('<%# Eval("quizId") %>')"><i class="bi bi-arrow-repeat"></i> <%: T("Resubmit","Hantar Semula") %></button>
                        <button type="button" class="pq-action-delete" onclick="openDeleteModal('<%# Eval("quizId") %>')"><i class="bi bi-trash"></i> <%: T("Delete Quiz","Padam Kuiz") %></button>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>

<%-- Empty state --%>
<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="mq-empty">
        <div style="font-size:3.5rem;opacity:.5;margin-bottom:1rem;">??</div>
        <div class="mq-empty-title"><asp:Literal ID="litEmptyMsg" runat="server" /></div>
    </div>
</asp:Panel>

<%-- Practice Quiz Pending State (shown when teacher has Pending license — mirrors manageMaterials.aspx style) --%>
<div id="pqPendingState" style="display:none;">
    <div style="display:flex;flex-direction:column;align-items:center;padding:3.5rem 2rem;text-align:center;">
        <div style="font-size:3.5rem;margin-bottom:1rem;opacity:.85;">?</div>
        <h2 style="font-size:1.15rem;font-weight:800;color:var(--tc-text);margin:0 0 .6rem;"><%: T("Verification Pending","Pengesahan Sedang Diproses") %></h2>
        <p style="font-size:.88rem;color:var(--tc-muted);max-width:480px;line-height:1.65;margin:0;"><%: T("Your Teaching License is still under review. You will be able to create and manage Practice Quizzes once your verification has been approved.","Lesen Mengajar anda masih dalam semakan. Anda akan dapat mencipta dan mengurus Kuiz Latihan setelah pengesahan anda diluluskan.") %></p>
    </div>
</div>

<%-- --- UNIT / LEVEL QUESTIONS --- --%>
<asp:Panel ID="pnlUnitLevel" runat="server" Visible="false">

<%-- Pending License Notice (Unit/Level only) --%>
<div id="pendingNoticeUL" class="mq-pending-notice" style="display:none;">
    <div class="mq-pending-notice-icon"><i class="bi bi-shield-exclamation"></i></div>
    <div class="mq-pending-notice-content">
        <div class="mq-pending-notice-title"><%: T("Verification Pending","Pengesahan Menunggu") %></div>
        <div class="mq-pending-notice-msg"><%: T("Your Teaching License is still under review. Adding questions to Unit & Level Quizzes is temporarily unavailable until your verification has been approved.","Lesen Mengajar anda masih dalam semakan. Penambahan soalan ke Kuiz Unit & Tahap tidak tersedia buat sementara waktu sehingga pengesahan anda diluluskan.") %></div>
    </div>
</div>

<%-- Unit Quiz Section --%>
<div id="ulSectionUnit" style="margin-bottom:2.5rem;">
    <h3 style="font-size:1.05rem;font-weight:800;color:var(--tc-text);margin:0 0 1rem;display:flex;align-items:center;gap:8px;"><i class="bi bi-layers" style="color:#2563EB;"></i> <%: T("Unit Quiz Questions","Soalan Kuiz Unit") %></h3>
    <asp:Literal ID="litUnitGrouped" runat="server" />
</div>

<%-- Level Quiz Section --%>
<div id="ulSectionLevel">
    <h3 style="font-size:1.05rem;font-weight:800;color:var(--tc-text);margin:0 0 1rem;display:flex;align-items:center;gap:8px;"><i class="bi bi-trophy" style="color:#D97706;"></i> <%: T("Level Quiz Questions","Soalan Kuiz Tahap") %></h3>
    <asp:Repeater ID="rptLevelQs" runat="server">
        <ItemTemplate>
            <div class="mq-ulq-card">
                <div class="mq-ulq-left">
                    <div class="mq-ulq-icon mq-ulq-icon-level"><i class="bi bi-trophy-fill"></i></div>
                    <div class="mq-ulq-info">
                        <div class="mq-ulq-title"><%# HttpUtility.HtmlEncode(Eval("levelName")) %></div>
                    </div>
                </div>
                <div class="mq-ulq-stats">
                    <div class="mq-ulq-col mq-ulq-col--overall">
                        <div class="mq-ulq-col-label"><%: T("Overall Approved","Diluluskan Semua") %> <span class="mq-info-icon" tabindex="0" data-tip="<%: T("Total approved questions available for this quiz from all teachers.","Jumlah soalan yang diluluskan tersedia untuk kuiz ini daripada semua guru.") %>"><i class="bi bi-info-circle"></i></span></div>
                        <div class="mq-ulq-col-val mq-val-overall"><%# Eval("overallApproved") %></div>
                    </div>
                    <div class="mq-ulq-col mq-ulq-col--submitted">
                        <div class="mq-ulq-col-label"><%: T("Your Submitted","Hantar Anda") %> <span class="mq-info-icon" tabindex="0" data-tip="<%: T("Total questions you have submitted for this quiz, including approved, pending and rejected questions.","Jumlah soalan yang telah anda hantar untuk kuiz ini, termasuk yang diluluskan, menunggu dan ditolak.") %>"><i class="bi bi-info-circle"></i></span></div>
                        <div class="mq-ulq-col-val"><%# Eval("yourCount") %></div>
                    </div>
                    <div class="mq-ulq-col mq-ulq-col--approved">
                        <div class="mq-ulq-col-label"><%: T("Approved","Diluluskan") %></div>
                        <div class="mq-ulq-col-val mq-val-approved"><%# Eval("approvedCount") %></div>
                    </div>
                    <div class="mq-ulq-col mq-ulq-col--pending">
                        <div class="mq-ulq-col-label"><%: T("Pending","Menunggu") %></div>
                        <div class="mq-ulq-col-val mq-val-pending"><%# Eval("pendingCount") %></div>
                    </div>
                    <div class="mq-ulq-col mq-ulq-col--rejected">
                        <div class="mq-ulq-col-label"><%: T("Rejected","Ditolak") %></div>
                        <div class="mq-ulq-col-val mq-val-rejected"><%# Eval("rejectedCount") %></div>
                    </div>
                </div>
                <div class="mq-ulq-btn-col">
                    <a href="#" class="mq-ulq-btn mq-ulq-btn-add" onclick='openSubtopicModal("<%# Eval("quizId") %>");return false;'><i class="bi bi-plus-lg"></i> <%: T("Add Questions","Tambah Soalan") %></a>
                    <button type="button" class="mq-ulq-btn" onclick='openULModal("<%# Eval("quizId") %>")'><i class="bi bi-eye"></i> <%: T("View Questions","Lihat Soalan") %></button>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</div>

</asp:Panel>

<asp:Panel ID="pnlUnitLevelEmpty" runat="server" Visible="false"></asp:Panel>
<asp:Panel ID="pnlUnitCards" runat="server" Visible="false"></asp:Panel>
<asp:Panel ID="pnlUnitEmpty" runat="server" Visible="false"></asp:Panel>
<asp:Panel ID="pnlLevelCards" runat="server" Visible="false"></asp:Panel>
<asp:Panel ID="pnlLevelEmpty" runat="server" Visible="false"></asp:Panel>

<%-- Unit/Level Question Detail Modal --%>
<div id="ulModal" class="mq-modal-overlay" style="display:none;" onclick="if(event.target===this)closeULModal()">
    <div class="mq-modal" style="max-width:880px;max-height:88vh;display:flex;flex-direction:column;">
        <div class="mq-modal-header" style="background:linear-gradient(135deg,#EFF6FF,#DBEAFE);border-bottom:1px solid #BFDBFE;">
            <h3 style="color:#1E40AF;"><i class="bi bi-journal-text" style="color:#2563EB;"></i> <%: T("Submitted Questions","Soalan Dihantar") %></h3>
            <button type="button" class="mq-modal-close" onclick="closeULModal()">×</button>
        </div>
        <div class="mq-modal-body" id="ulModalBody" style="text-align:left;overflow-y:auto;padding:1.25rem 1.5rem;">
            <div class="mq-empty"><%: T("Loading...","Memuatkan...") %></div>
        </div>
    </div>
</div>

<%-- Image Preview Modal --%>
<div id="vqImgModal" class="vq-img-modal" onclick="if(event.target===this)closeImgPreview()">
    <div class="vq-img-modal-box">
        <div class="vq-img-modal-hd"><span id="vqImgName"></span><button type="button" class="vq-img-modal-close" onclick="closeImgPreview()">×</button></div>
        <div class="vq-img-modal-body"><img id="vqImgPreview" src="" alt="Preview" /></div>
    </div>
</div>

<%-- Subtopic Selection Modal --%>
<div id="subtopicModal" class="mq-modal-overlay" style="display:none;" onclick="if(event.target===this)closeSubtopicModal()">
    <div class="mq-modal" style="max-width:460px;">
        <div class="mq-modal-header">
            <div>
                <h3><%: T("Select Subtopic","Pilih Subtopik") %></h3>
                <p style="font-size:.78rem;color:var(--tc-muted);margin:3px 0 0;"><%: T("Choose the subtopic for the questions you want to add.","Pilih subtopik untuk soalan yang ingin ditambah.") %></p>
            </div>
            <button type="button" class="mq-modal-close" onclick="closeSubtopicModal()">×</button>
        </div>
        <div class="mq-modal-body" style="text-align:left;padding:1.25rem 1.5rem;">
            <div id="stScopeInfo" style="font-size:.84rem;font-weight:600;color:var(--tc-text);margin-bottom:1rem;padding:.6rem .85rem;background:#F9FAFB;border-radius:8px;border:1px solid #E5E7EB;"></div>
            <label style="font-size:.8rem;font-weight:700;color:var(--tc-text);display:block;margin-bottom:5px;"><%: T("Subtopic","Subtopik") %> *</label>
            <select id="stDropdown" class="mq-select" style="width:100%;height:42px;">
                <option value=""><%: T("— Select Subtopic —","— Pilih Subtopik —") %></option>
            </select>
        </div>
        <div class="mq-modal-footer">
            <button type="button" class="mq-btn-cancel" onclick="closeSubtopicModal()"><%: T("Cancel","Batal") %></button>
            <button type="button" id="stContinueBtn" class="mq-btn-create" style="box-shadow:none;opacity:.5;pointer-events:none;" onclick="goToCreatePage()"><%: T("Continue","Teruskan") %></button>
        </div>
    </div>
</div>

<%-- --- DISCOVER QUIZZES --- --%>
<asp:Panel ID="pnlDiscover" runat="server" Visible="false">
    <div class="mq-carousel-wrap">
        <button type="button" class="mq-arrow mq-arrow-left" onclick="scrollDiscover(-1)"><i class="bi bi-chevron-left"></i></button>
        <div class="mq-carousel" id="discoverCarousel">
            <asp:Repeater ID="rptDiscover" runat="server">
                <ItemTemplate>
                    <div class="mq-dcard">
                        <div class="mq-dcard-img-wrap">
                            <div class="mq-dcard-cover"></div>
                            <span class="mq-dcard-badge mq-dcard-badge-left"><i class="bi bi-list-check"></i> <%# Eval("questionCount") %> Qs</span>
                            <span class="mq-dcard-badge mq-dcard-badge-right"><%# HttpUtility.HtmlEncode(Eval("language")?.ToString() ?? "") %></span>
                        </div>
                        <div class="mq-dcard-body">
                            <div class="mq-dcard-title"><%# HttpUtility.HtmlEncode(Eval("quizTitle")) %></div>
                            <div class="mq-dcard-teacher">
                                <div class="mq-dcard-teacher-avatar"><i class="bi bi-person-fill"></i></div>
                                <span class="mq-dcard-teacher-name"><%# HttpUtility.HtmlEncode(Eval("teacherName")) %></span>
                            </div>
                        </div>
                        <div style="padding:.6rem 1.2rem .8rem;">
                            <span class="dq-hidden-data" style="display:none;"
                                  data-qid='<%# Eval("quizId") %>'
                                  data-title='<%# HttpUtility.HtmlAttributeEncode(Eval("quizTitle").ToString()) %>'
                                  data-teacher='<%# HttpUtility.HtmlAttributeEncode(Eval("teacherName").ToString()) %>'
                                  data-lang='<%# HttpUtility.HtmlAttributeEncode(Eval("language")?.ToString() ?? "") %>'
                                  data-count='<%# Eval("questionCount") %>'></span>
                            <a href="#" class="pq-btn-view" onclick="openDiscoverModal(this.previousElementSibling);return false;"><i class="bi bi-eye"></i> View Quiz</a>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
        <button type="button" class="mq-arrow mq-arrow-right" onclick="scrollDiscover(1)"><i class="bi bi-chevron-right"></i></button>
    </div>
</asp:Panel>

<asp:Panel ID="pnlDiscoverEmpty" runat="server" Visible="false">
    <div class="mq-empty">
        <div style="font-size:3rem;opacity:.4;margin-bottom:.75rem;">??</div>
        <div class="mq-empty-title"><%: T("No shared quizzes available.","Tiada kuiz kongsi tersedia.") %></div>
    </div>
</asp:Panel>

<asp:HiddenField ID="hidActiveTab" runat="server" Value="mine" />
<asp:HiddenField ID="hidTeacherLicenseStatus" runat="server" Value="" />

<%-- --- PRACTICE QUIZ VIEW MODAL --- --%>
<div id="pqViewModal" class="pq-overlay" onclick="if(event.target===this)closePracticeViewModal()">
    <div class="pq-modal">
        <div class="pq-modal-header">
            <div class="pq-header-main">
                <div class="pq-header-title" id="pqViewTitle"></div>
                <div class="pq-header-meta" id="pqViewMeta"></div>
            </div>
            <button type="button" class="pq-close-btn" onclick="closePracticeViewModal()" title="Close">
                <i class="bi bi-x-lg"></i>
            </button>
        </div>
        <div class="pq-modal-body" id="pqViewBody">
            <div class="mq-empty"><div style="font-size:2rem;opacity:.4;">?</div><div class="mq-empty-title" style="margin-top:.5rem;"><%: T("Loading...","Memuatkan...") %></div></div>
        </div>
    </div>
</div>
<%-- --- DISCOVER QUIZ VIEW MODAL --- --%>
<div id="dqModal" class="dq-overlay" onclick="if(event.target===this)closeDiscoverModal()">
    <div class="dq-modal">
        <div class="dq-modal-header" id="dqHeader">
            <div class="dq-header-main">
                <div class="dq-header-title" id="dqTitle"></div>
                <div class="dq-header-meta" id="dqMeta"></div>
            </div>
            <button type="button" class="dq-close-btn" onclick="closeDiscoverModal()" title="Close">
                <i class="bi bi-x-lg"></i>
            </button>
        </div>
        <div class="dq-modal-body" id="dqBody">
            <div class="mq-empty"><div style="font-size:2rem;opacity:.4;">?</div><div class="mq-empty-title" style="margin-top:.5rem;"><%: T("Loading...","Memuatkan...") %></div></div>
        </div>
    </div>
</div>
<%-- Practice Quiz Selection Modal --%>
<div id="practiceModal" class="mq-modal-overlay" style="display:none;" onclick="if(event.target===this)closePracticeModal()">
    <div class="mq-modal" style="max-width:460px;">
        <div class="mq-modal-header">
            <div>
                <h3><%: T("Create Practice Quiz","Cipta Kuiz Latihan") %></h3>
                <p style="font-size:.78rem;color:var(--tc-muted);margin:3px 0 0;"><%: T("Select the learning area for this practice quiz.","Pilih kawasan pembelajaran untuk kuiz latihan ini.") %></p>
            </div>
            <button type="button" class="mq-modal-close" onclick="closePracticeModal()">×</button>
        </div>
        <div class="mq-modal-body" style="text-align:left;padding:1.25rem 1.5rem;">
            <div style="margin-bottom:1rem;">
                <label style="font-size:.8rem;font-weight:700;color:var(--tc-text);display:block;margin-bottom:5px;"><%: T("Level","Tahap") %> *</label>
                <select id="pqLevel" class="mq-select" style="width:100%;height:42px;" onchange="pqOnLevelChange(this.value)">
                    <option value=""><%: T("— Select Level —","— Pilih Tahap —") %></option>
                </select>
            </div>
            <div style="margin-bottom:1rem;">
                <label style="font-size:.8rem;font-weight:700;color:var(--tc-text);display:block;margin-bottom:5px;"><%: T("Unit","Unit") %> *</label>
                <select id="pqUnit" class="mq-select" style="width:100%;height:42px;" onchange="pqOnUnitChange(this.value)" disabled>
                    <option value=""><%: T("— Select Unit —","— Pilih Unit —") %></option>
                </select>
            </div>
            <div style="margin-bottom:1rem;">
                <label style="font-size:.8rem;font-weight:700;color:var(--tc-text);display:block;margin-bottom:5px;"><%: T("Subtopic","Subtopik") %> *</label>
                <select id="pqSubtopic" class="mq-select" style="width:100%;height:42px;" onchange="pqOnSubtopicChange(this.value)" disabled>
                    <option value=""><%: T("— Select Subtopic —","— Pilih Subtopik —") %></option>
                </select>
            </div>
            <div style="margin-bottom:.25rem;">
                <label style="font-size:.8rem;font-weight:700;color:var(--tc-text);display:block;margin-bottom:5px;"><%: T("Language","Bahasa") %> *</label>
                <select id="pqLanguage" class="mq-select" style="width:100%;height:42px;" onchange="pqUpdateContinue()">
                    <option value=""><%: T("— Select Language —","— Pilih Bahasa —") %></option>
                    <option value="EN">English</option>
                    <option value="BM">Bahasa Melayu</option>
                </select>
            </div>
        </div>
        <div class="mq-modal-footer">
            <button type="button" class="mq-btn-cancel" onclick="closePracticeModal()"><%: T("Cancel","Batal") %></button>
            <button type="button" id="pqContinueBtn" class="mq-btn-create" style="box-shadow:none;opacity:.5;pointer-events:none;" onclick="pqContinue()"><%: T("Continue","Teruskan") %></button>
        </div>
    </div>
</div>

<%-- Create Quiz Setup Modal --%>
<div id="createModal" class="mq-modal-overlay" style="display:none;">
    <div class="mq-modal" style="max-width:520px;">
        <div class="mq-modal-header">
            <div><h3><%: T("Create Quiz","Cipta Kuiz") %></h3><p style="font-size:.8rem;color:var(--tc-muted);margin:2px 0 0;"><%: T("Choose your quiz setup before building questions.","Pilih tetapan kuiz sebelum membina soalan.") %></p></div>
            <button type="button" class="mq-modal-close" onclick="document.getElementById('createModal').style.display='none'">×</button>
        </div>
        <div class="mq-modal-body" style="text-align:left;padding:1.25rem 1.5rem;">
            <div style="margin-bottom:1rem;">
                <label style="font-size:.8rem;font-weight:600;color:var(--tc-text);display:block;margin-bottom:5px;"><%: T("Quiz Type","Jenis Kuiz") %> *</label>
                <asp:DropDownList ID="ddlCreateType" runat="server" CssClass="mq-select" style="width:100%;" AutoPostBack="true" OnSelectedIndexChanged="ddlCreateType_Changed" />
                <div class="mq-val-msg" id="valType"></div>
            </div>
            <asp:Panel ID="pnlCreateLevel" runat="server" Visible="false">
                <div style="margin-bottom:1rem;">
                    <label style="font-size:.8rem;font-weight:600;color:var(--tc-text);display:block;margin-bottom:5px;"><%: T("Level","Tahap") %> *</label>
                    <asp:DropDownList ID="ddlCreateLevel" runat="server" CssClass="mq-select" style="width:100%;" AutoPostBack="true" OnSelectedIndexChanged="ddlCreateLevel_Changed" />
                    <div class="mq-val-msg" id="valLevel"></div>
                </div>
            </asp:Panel>
            <asp:Panel ID="pnlCreateUnit" runat="server" Visible="false">
                <div style="margin-bottom:1rem;">
                    <label style="font-size:.8rem;font-weight:600;color:var(--tc-text);display:block;margin-bottom:5px;"><%: T("Unit","Unit") %> *</label>
                    <asp:DropDownList ID="ddlCreateUnit" runat="server" CssClass="mq-select" style="width:100%;" AutoPostBack="true" OnSelectedIndexChanged="ddlCreateUnit_Changed" />
                    <div class="mq-val-msg" id="valUnit"></div>
                </div>
            </asp:Panel>
            <asp:Panel ID="pnlCreateSubtopic" runat="server" Visible="false">
                <div style="margin-bottom:1rem;">
                    <label style="font-size:.8rem;font-weight:600;color:var(--tc-text);display:block;margin-bottom:5px;"><%: T("Subtopic","Subtopik") %> *</label>
                    <asp:DropDownList ID="ddlCreateSubtopic" runat="server" CssClass="mq-select" style="width:100%;" />
                    <div class="mq-val-msg" id="valSubtopic"></div>
                </div>
            </asp:Panel>
            <asp:Panel ID="pnlCreateLang" runat="server" Visible="false">
                <div style="margin-bottom:1rem;">
                    <label style="font-size:.8rem;font-weight:600;color:var(--tc-text);display:block;margin-bottom:5px;"><%: T("Language","Bahasa") %> *</label>
                    <asp:DropDownList ID="ddlCreateLang" runat="server" CssClass="mq-select" style="width:100%;">
                        <asp:ListItem Value="" Text="— Select —" />
                        <asp:ListItem Value="EN" Text="English" />
                        <asp:ListItem Value="BM" Text="Bahasa Melayu" />
                    </asp:DropDownList>
                    <div class="mq-val-msg" id="valLang"></div>
                </div>
            </asp:Panel>
        </div>
        <div class="mq-modal-footer">
            <button type="button" class="mq-btn-cancel" onclick="document.getElementById('createModal').style.display='none'"><%: T("Cancel","Batal") %></button>
            <asp:Button ID="btnContinue" runat="server" CssClass="mq-btn-create" style="box-shadow:none;" Text="Continue" OnClick="btnContinue_Click" CausesValidation="false" />
        </div>
    </div>
</div>
<asp:HiddenField ID="hidShowCreateModal" runat="server" Value="" />

<%-- Delete Modal --%>
<div id="deleteModal" class="mq-modal-overlay" style="display:none;">
    <div class="mq-modal">
        <div class="mq-modal-header"><h3><%: T("Delete Quiz","Padam Kuiz") %></h3><button type="button" class="mq-modal-close" onclick="closeDeleteModal()">×</button></div>
        <div class="mq-modal-body"><p><%: T("Are you sure you want to delete this quiz? This action cannot be undone.","Adakah anda pasti mahu memadam kuiz ini? Tindakan ini tidak boleh dibatalkan.") %></p></div>
        <div class="mq-modal-footer">
            <button type="button" class="mq-btn-cancel" onclick="closeDeleteModal()"><%: T("Cancel","Batal") %></button>
            <asp:Button ID="btnConfirmDelete" runat="server" CssClass="mq-btn-danger" OnClick="btnConfirmDelete_Click" CausesValidation="false" />
        </div>
    </div>
</div>

<%-- Resubmit Confirmation Modal --%>
<div id="resubmitModal" class="mq-modal-overlay" style="display:none;" onclick="if(event.target===this)closeResubmitModal()">
    <div class="mq-modal" style="max-width:440px;">
        <div class="rsm-header">
            <div class="rsm-icon-wrap"><i class="bi bi-arrow-repeat"></i></div>
            <div class="rsm-header-text">
                <h3 class="rsm-title"><%: T("Resubmit Quiz","Hantar Semula Kuiz") %></h3>
            </div>
            <button type="button" class="mq-modal-close" onclick="closeResubmitModal()">×</button>
        </div>
        <div class="rsm-body">
            <p class="rsm-msg"><%: T("Are you sure you want to resubmit this quiz for review?","Adakah anda pasti mahu menghantar semula kuiz ini untuk semakan?") %></p>
            <p class="rsm-sub"><%: T("The quiz and all questions inside it will be changed to Pending.","Kuiz dan semua soalan di dalamnya akan ditukar kepada Menunggu.") %></p>
        </div>
        <div class="rsm-footer">
            <button type="button" class="rsm-btn-cancel" onclick="closeResubmitModal()"><%: T("Cancel","Batal") %></button>
            <button type="button" class="rsm-btn-confirm" onclick="confirmResubmit()"><i class="bi bi-arrow-repeat"></i> <%: T("Confirm Resubmit","Sahkan Hantar Semula") %></button>
        </div>
    </div>
</div>
<asp:HiddenField ID="hidDeleteId" runat="server" Value="" />
<asp:HiddenField ID="hidToast" runat="server" Value="" />
<div id="mqToast" class="mq-toast-container"></div>

</asp:Panel>
</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
function scrollCarousel(dir){var c=document.getElementById('quizCarousel');if(c)c.scrollBy({left:dir*320,behavior:'smooth'});}
function scrollDiscover(dir){var c=document.getElementById('discoverCarousel');if(c)c.scrollBy({left:dir*320,behavior:'smooth'});}
function openDeleteModal(id){document.getElementById('<%=hidDeleteId.ClientID%>').value=id;document.getElementById('deleteModal').style.display='flex';}
function closeDeleteModal(){document.getElementById('deleteModal').style.display='none';}
var _resubmitQuizId='';
function resubmitQuiz(quizId){
    _resubmitQuizId=quizId;
    document.getElementById('resubmitModal').style.display='flex';
}
function closeResubmitModal(){document.getElementById('resubmitModal').style.display='none';_resubmitQuizId='';}
function confirmResubmit(){
    if(!_resubmitQuizId)return;
    var xhr=new XMLHttpRequest();
    xhr.open('POST','manageQuiz.aspx?handler=resubmit&quizId='+encodeURIComponent(_resubmitQuizId),true);
    xhr.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
    xhr.onreadystatechange=function(){
        if(xhr.readyState===4){
            closeResubmitModal();
            if(xhr.status===200){showToast('<%: T("Quiz resubmitted for review.","Kuiz dihantar semula untuk semakan.") %>');setTimeout(function(){location.reload();},1200);}
            else{alert('Error resubmitting quiz.');}
        }
    };
    xhr.send('');
}
/* -- Practice Quiz Selection Modal -- */
function openPracticeModal(){
    var modal=document.getElementById('practiceModal');
    var lvDd=document.getElementById('pqLevel');
    // Load levels if not already loaded
    if(lvDd.options.length<=1){
        lvDd.innerHTML='<option value="">Loading...</option>';
        var xhr=new XMLHttpRequest();
        xhr.open('GET','manageQuiz.aspx?handler=pqlevels',true);
        xhr.onreadystatechange=function(){
            if(xhr.readyState===4&&xhr.status===200){
                try{
                    var data=JSON.parse(xhr.responseText);
                    lvDd.innerHTML='<option value="">— <%: T("Select Level","Pilih Tahap") %> —</option>';
                    for(var i=0;i<data.length;i++){
                        var o=document.createElement('option');o.value=data[i].id;o.textContent=data[i].name;lvDd.appendChild(o);
                    }
                }catch(e){lvDd.innerHTML='<option value="">Error</option>';}
            }
        };
        xhr.send();
    }
    // Reset Unit, Subtopic, and Language
    var unDd=document.getElementById('pqUnit');
    var stDd=document.getElementById('pqSubtopic');
    unDd.innerHTML='<option value="">— <%: T("Select Unit","Pilih Unit") %> —</option>';
    unDd.disabled=true;
    stDd.innerHTML='<option value="">— <%: T("Select Subtopic","Pilih Subtopik") %> —</option>';
    stDd.disabled=true;
    document.getElementById('pqLanguage').value='';
    pqUpdateContinue();
    modal.style.display='flex';}
function closePracticeModal(){
    document.getElementById('practiceModal').style.display='none';
    document.getElementById('pqLevel').value='';
    document.getElementById('pqUnit').innerHTML='<option value="">— <%: T("Select Unit","Pilih Unit") %> —</option>';
    document.getElementById('pqUnit').disabled=true;
    document.getElementById('pqSubtopic').innerHTML='<option value="">— <%: T("Select Subtopic","Pilih Subtopik") %> —</option>';
    document.getElementById('pqSubtopic').disabled=true;
    document.getElementById('pqLanguage').value='';
    pqUpdateContinue();
}
function pqOnLevelChange(levelId){
    var unDd=document.getElementById('pqUnit');
    var stDd=document.getElementById('pqSubtopic');
    stDd.innerHTML='<option value="">— <%: T("Select Subtopic","Pilih Subtopik") %> —</option>';
    stDd.disabled=true;
    unDd.innerHTML='<option value="">— <%: T("Select Unit","Pilih Unit") %> —</option>';
    pqUpdateContinue();
    if(!levelId){unDd.disabled=true;return;}
    unDd.innerHTML='<option value="">Loading...</option>';
    unDd.disabled=true;
    var xhr=new XMLHttpRequest();
    xhr.open('GET','manageQuiz.aspx?handler=pqunits&levelId='+encodeURIComponent(levelId),true);
    xhr.onreadystatechange=function(){
        if(xhr.readyState===4&&xhr.status===200){
            try{
                var data=JSON.parse(xhr.responseText);
                unDd.innerHTML='<option value="">— <%: T("Select Unit","Pilih Unit") %> —</option>';
                for(var i=0;i<data.length;i++){
                    var o=document.createElement('option');o.value=data[i].id;o.textContent=data[i].name;unDd.appendChild(o);
                }
                unDd.disabled=false;
            }catch(e){unDd.innerHTML='<option value="">Error</option>';unDd.disabled=false;}
        }
    };
    xhr.send();
}
function pqOnUnitChange(unitId){
    var stDd=document.getElementById('pqSubtopic');
    stDd.innerHTML='<option value="">— <%: T("Select Subtopic","Pilih Subtopik") %> —</option>';
    stDd.disabled=true;
    pqUpdateContinue();
    if(!unitId)return;
    stDd.innerHTML='<option value="">Loading...</option>';
    var xhr=new XMLHttpRequest();
    xhr.open('GET','manageQuiz.aspx?handler=pqsubtopics&unitId='+encodeURIComponent(unitId),true);
    xhr.onreadystatechange=function(){
        if(xhr.readyState===4&&xhr.status===200){
            try{
                var data=JSON.parse(xhr.responseText);
                stDd.innerHTML='<option value="">— <%: T("Select Subtopic","Pilih Subtopik") %> —</option>';
                for(var i=0;i<data.length;i++){
                    var o=document.createElement('option');o.value=data[i].id;o.textContent=data[i].name;stDd.appendChild(o);
                }
                stDd.disabled=false;
            }catch(e){stDd.innerHTML='<option value="">Error</option>';stDd.disabled=false;}
        }
    };
    xhr.send();
}
function pqOnSubtopicChange(val){pqUpdateContinue();}
function pqUpdateContinue(){
    var btn=document.getElementById('pqContinueBtn');
    var lv=document.getElementById('pqLevel').value;
    var un=document.getElementById('pqUnit').value;
    var st=document.getElementById('pqSubtopic').value;
    var lg=document.getElementById('pqLanguage').value;
    var ok=(lv&&un&&st&&lg);
    btn.style.opacity=ok?'1':'.5';
    btn.style.pointerEvents=ok?'auto':'none';
}
function pqContinue(){
    var lv=document.getElementById('pqLevel').value;
    var un=document.getElementById('pqUnit').value;
    var st=document.getElementById('pqSubtopic').value;
    var lg=document.getElementById('pqLanguage').value;
    if(!lv||!un||!st||!lg)return;
    window.location.href='createPracticeQuiz.aspx?levelId='+encodeURIComponent(lv)+'&unitId='+encodeURIComponent(un)+'&subtopicId='+encodeURIComponent(st)+'&language='+encodeURIComponent(lg);
}
function openULModal(quizId){
    var modal=document.getElementById('ulModal');var body=document.getElementById('ulModalBody');
    body.innerHTML='<div class="mq-empty">Loading...</div>';modal.style.display='flex';
    var xhr=new XMLHttpRequest();
    xhr.open('GET','manageQuiz.aspx?handler=ulquestions&quizId='+encodeURIComponent(quizId),true);
    xhr.onreadystatechange=function(){if(xhr.readyState===4){body.innerHTML=xhr.status===200?xhr.responseText:'<div class="mq-empty">Error</div>';}};
    xhr.send();
}
function closeULModal(){document.getElementById('ulModal').style.display='none';}
function toggleVQ(el){var card=el.parentElement;card.classList.toggle('vq-expanded');}
function openImgPreview(url){var m=document.getElementById('vqImgModal');document.getElementById('vqImgPreview').src=url;document.getElementById('vqImgName').textContent=url.split('/').pop();m.classList.add('active');}
function closeImgPreview(){document.getElementById('vqImgModal').classList.remove('active');}
var _stQuizId='';
function openSubtopicModal(quizId){
    _stQuizId=quizId;
    var modal=document.getElementById('subtopicModal');
    var dd=document.getElementById('stDropdown');
    var info=document.getElementById('stScopeInfo');
    var btn=document.getElementById('stContinueBtn');
    dd.innerHTML='<option value="">Loading...</option>';
    info.textContent='Loading...';
    btn.style.opacity='.5';btn.style.pointerEvents='none';
    modal.style.display='flex';
    var xhr=new XMLHttpRequest();
    xhr.open('GET','manageQuiz.aspx?handler=subtopics&quizId='+encodeURIComponent(quizId),true);
    xhr.onreadystatechange=function(){
        if(xhr.readyState===4&&xhr.status===200){
            try{
                var data=JSON.parse(xhr.responseText);
                info.textContent=data.quizType+' — '+data.scopeName;
                dd.innerHTML='<option value="">— <%: T("Select Subtopic","Pilih Subtopik") %> —</option>';
                for(var i=0;i<data.subtopics.length;i++){
                    var o=document.createElement('option');o.value=data.subtopics[i].id;o.textContent=data.subtopics[i].name;dd.appendChild(o);
                }
            }catch(e){info.textContent='Error';dd.innerHTML='<option value="">Error</option>';}
        }
    };
    xhr.send();
    dd.onchange=function(){
        if(this.value){btn.style.opacity='1';btn.style.pointerEvents='auto';}
        else{btn.style.opacity='.5';btn.style.pointerEvents='none';}
    };
}
function closeSubtopicModal(){document.getElementById('subtopicModal').style.display='none';_stQuizId='';}
function goToCreatePage(){
    var st=document.getElementById('stDropdown').value;
    if(!st||!_stQuizId)return;
    window.location.href='createUnitLevelQuiz.aspx?quizId='+encodeURIComponent(_stQuizId)+'&subtopicId='+encodeURIComponent(st);
}
function filterUL(mode,btn){
    var u=document.getElementById('ulSectionUnit'),l=document.getElementById('ulSectionLevel');
    if(u)u.style.display=(mode==='level'?'none':'');
    if(l)l.style.display=(mode==='unit'?'none':'');
    var btns=btn.parentElement.querySelectorAll('.mq-seg-btn');
    for(var i=0;i<btns.length;i++)btns[i].classList.remove('mq-seg-active');
    btn.classList.add('mq-seg-active');
}
function showToast(msg){var c=document.getElementById('mqToast'),t=document.createElement('div');t.className='mq-toast';t.innerHTML='<i class="bi bi-check-circle-fill"></i> '+msg;c.appendChild(t);setTimeout(function(){t.classList.add('mq-toast-out');},3e3);setTimeout(function(){t.remove();},3500);}
/* -- Discover Quiz View Modal --------------------------- */
function openDiscoverModal(el){
    var quizId  = el.dataset.qid;
    var title   = el.dataset.title;
    var teacher = el.dataset.teacher;
    var lang    = el.dataset.lang;
    var count   = parseInt(el.dataset.count, 10) || 0;
    var overlay = document.getElementById('dqModal');
    var body    = document.getElementById('dqBody');
    var titleEl = document.getElementById('dqTitle');
    var metaEl  = document.getElementById('dqMeta');

    var langLabel = lang === 'BM' ? 'Bahasa Melayu' : 'English';
    // Populate header
    titleEl.textContent = title;
    metaEl.innerHTML =
        '<span><i class="bi bi-person-fill"></i> ' + escHtml(teacher) + '</span>' +
        '<span><i class="bi bi-translate"></i> ' + escHtml(langLabel) + '</span>' +
        '<span><i class="bi bi-list-check"></i> ' + count + ' question' + (count === 1 ? '' : 's') + '</span>';

    // Show loading state
    body.innerHTML = '<div class="mq-empty"><div style="font-size:2rem;opacity:.4;">?</div><div class="mq-empty-title" style="margin-top:.5rem;">Loading questions...</div></div>';
    overlay.classList.add('open');
    document.body.style.overflow = 'hidden';

    // Fetch questions and apply single-language transform
    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'manageQuiz.aspx?handler=discoverquiz&quizId=' + encodeURIComponent(quizId), true);
    xhr.onreadystatechange = function(){
        if(xhr.readyState === 4){
            body.innerHTML = xhr.status === 200
                ? transformToSingleLang(xhr.responseText, lang)
                : '<div class="mq-empty"><div class="mq-empty-title">Could not load questions. Please try again.</div></div>';
        }
    };
    xhr.send();
}
function closeDiscoverModal(){
    var overlay = document.getElementById('dqModal');
    overlay.classList.remove('open');
    document.body.style.overflow = '';
}
function escHtml(str){
    var d = document.createElement('div');
    d.textContent = str;
    return d.innerHTML;
}
/* -- Practice Quiz View Modal --------------------------- */
function openPracticeViewModal(el) {
    var quizId  = el.dataset.qid;
    var title   = el.dataset.title;
    var lang    = el.dataset.lang;
    var count   = parseInt(el.dataset.count, 10) || 0;
    var status  = (el.dataset.status || '').toLowerCase();
    var overlay = document.getElementById('pqViewModal');
    var body    = document.getElementById('pqViewBody');
    var titleEl = document.getElementById('pqViewTitle');
    var metaEl  = document.getElementById('pqViewMeta');

    // Title without status badge
    titleEl.innerHTML = escHtml(title);

    var langLabel = lang === 'BM' ? 'Bahasa Melayu' : 'English';
    metaEl.innerHTML =
        '<span><i class="bi bi-translate"></i> ' + escHtml(langLabel) + '</span>' +
        '<span><i class="bi bi-list-check"></i> ' + count + ' question' + (count === 1 ? '' : 's') + '</span>';

    body.innerHTML = '<div class="mq-empty"><div style="font-size:2rem;opacity:.4;">?</div><div class="mq-empty-title" style="margin-top:.5rem;">Loading questions...</div></div>';
    overlay.classList.add('open');
    document.body.style.overflow = 'hidden';

    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'manageQuiz.aspx?handler=discoverquiz&quizId=' + encodeURIComponent(quizId), true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) {
            body.innerHTML = xhr.status === 200
                ? transformToSingleLang(xhr.responseText, lang)
                : '<div class="mq-empty"><div class="mq-empty-title">Could not load questions. Please try again.</div></div>';
        }
    };
    xhr.send();
}

function closePracticeViewModal() {
    var overlay = document.getElementById('pqViewModal');
    overlay.classList.remove('open');
    document.body.style.overflow = '';
}

/**
 * Transform bilingual two-column HTML from handler=discoverquiz into
 * single-language layout.
 *
 * Input per card:
 *   vq-card-hd:  Q# | diffBadge | chevron
 *   vq-card-body:
 *     vq-format-row
 *     vq-cols > [vq-col(EN), vq-col(BM)]    ? col contains: question, options, explanations
 *     vq-img-row  (outside vq-cols, at end of body)
 *
 * Output per card:
 *   pq-card-hd:  Q#  [flex-1]  diffBadge[ml-auto]  chevron
 *   vq-card-body:
 *     vq-format-row
 *     question text   (full width)
 *     vq-img-row      (image right after question, if present)
 *     options         (full width)
 *     correct expl    (full width)
 *     wrong expl      (full width)
 */
function transformToSingleLang(html, quizLang) {
    var isBM = (quizLang === 'BM');

    // Use a temporary container to parse the HTML safely
    var tmp = document.createElement('div');
    tmp.innerHTML = html;

    var cards = tmp.querySelectorAll('.vq-card');
    if (!cards.length) return html; // nothing to transform

    cards.forEach(function(card) {
        /* -- 1. Rebuild card header -- */
        var oldHd = card.querySelector('.vq-card-hd');
        if (oldHd) {
            var numEl    = oldHd.querySelector('.vq-card-num');
            var badges   = oldHd.querySelectorAll('.vq-badge');
            var chevron  = oldHd.querySelector('.vq-chevron');
            var numText  = numEl ? numEl.textContent : '';
            var diffBadgeClass = '';
            var diffBadgeText  = '';
            if (badges.length > 0) {
                diffBadgeClass = badges[0].className;
                diffBadgeText  = badges[0].textContent.trim();
            }
            var chevronClass = chevron ? chevron.className : 'bi bi-chevron-down vq-chevron';

            var newHd = document.createElement('div');
            newHd.className = 'pq-card-hd';
            newHd.setAttribute('onclick', 'toggleVQ(this)');
            newHd.innerHTML =
                '<span class="vq-card-num">' + escHtml(numText) + '</span>' +
                (diffBadgeText ? '<span class="' + escHtml(diffBadgeClass) + ' pq-diff-badge">' + escHtml(diffBadgeText) + '</span>' : '') +
                '<i class="' + escHtml(chevronClass) + '"></i>';

            oldHd.parentNode.replaceChild(newHd, oldHd);
        }

        /* -- 2. Extract content from the matching language column -- */
        var body = card.querySelector('.vq-card-body');
        if (!body) return;

        var formatRow = body.querySelector('.vq-format-row');
        var cols      = body.querySelector('.vq-cols');
        var imgRow    = body.querySelector('.vq-img-row');  // sits outside vq-cols

        if (!cols) return; // nothing to transform

        var colDivs = cols.querySelectorAll('.vq-col');
        var keepIndex = isBM ? 1 : 0;
        if (colDivs.length <= keepIndex) keepIndex = 0;
        var targetCol = colDivs[keepIndex];
        if (!targetCol) return;

        // Remove language heading inside the column
        var colHd = targetCol.querySelector('.vq-col-hd');
        if (colHd) colHd.remove();

        // Collect ordered content: question, options/dd, correct-expl, wrong-expl
        var questionEl  = targetCol.querySelector('.vq-question');
        var optionsEl   = targetCol.querySelector('.vq-options');         // MCQ/TF/MS
        var ddSection   = targetCol.querySelector('.vq-dd-section');      // Drag & Drop
        var ddOrder     = targetCol.querySelector('.vq-dd-order');
        var explCorrect = targetCol.querySelector('.vq-expl-correct');
        var explWrong   = targetCol.querySelector('.vq-expl-wrong');

        // Build new body content in order:
        // format-row ? question ? image ? options ? correct-expl ? wrong-expl
        var newBody = document.createElement('div');
        newBody.className = 'vq-card-body';

        if (formatRow) newBody.appendChild(formatRow.cloneNode(true));
        if (questionEl) newBody.appendChild(questionEl.cloneNode(true));
        if (imgRow)     newBody.appendChild(imgRow.cloneNode(true));    // image after question
        if (optionsEl)  newBody.appendChild(optionsEl.cloneNode(true));
        if (ddSection)  newBody.appendChild(ddSection.cloneNode(true));
        if (ddOrder)    newBody.appendChild(ddOrder.cloneNode(true));
        if (explCorrect) newBody.appendChild(explCorrect.cloneNode(true));
        if (explWrong)   newBody.appendChild(explWrong.cloneNode(true));

        body.parentNode.replaceChild(newBody, body);
    });

    return tmp.innerHTML;
}
window.addEventListener('load',function(){var h=document.getElementById('<%=hidToast.ClientID%>');if(h&&h.value){showToast(h.value);h.value='';}
var cm=document.getElementById('<%=hidShowCreateModal.ClientID%>');if(cm&&cm.value==='1'){document.getElementById('createModal').style.display='flex';cm.value='';}
// Show/hide segmented filter and search bar based on active tab
var activeTab=document.getElementById('<%=hidActiveTab.ClientID%>');
var seg=document.getElementById('ulSegFilter');var fb=document.getElementById('mqFilterBar');
if(activeTab&&activeTab.value==='unitlevel'){if(seg)seg.style.display='';if(fb)fb.style.display='none';}
else{if(seg)seg.style.display='none';if(fb)fb.style.display='';}
// Pending License restrictions
var licStatus=document.getElementById('<%=hidTeacherLicenseStatus.ClientID%>');
if(licStatus&&licStatus.value==='Pending'){
    var tipText='<%: T("Adding questions is unavailable while your Teaching License verification is pending.","Penambahan soalan tidak tersedia semasa pengesahan Lesen Mengajar anda masih menunggu.") %>';
    // 1. Unit/Level tab: show notice + disable Add buttons
    var noticeUL=document.getElementById('pendingNoticeUL');if(noticeUL)noticeUL.style.display='flex';
    var addBtns=document.querySelectorAll('.mq-ulq-btn-add');
    for(var i=0;i<addBtns.length;i++){
        addBtns[i].classList.add('mq-btn-disabled');
        addBtns[i].removeAttribute('onclick');
        addBtns[i].setAttribute('title',tipText);
        addBtns[i].href='javascript:void(0)';
    }
    // 2. Practice Quizzes tab: hide cards, show pending state, disable Create button
    var pqGrid=document.querySelector('#<%=pnlQuizzes.ClientID%>');if(pqGrid)pqGrid.style.display='none';
    var pqEmpty=document.querySelector('#<%=pnlEmpty.ClientID%>');if(pqEmpty)pqEmpty.style.display='none';
    var pqPending=document.getElementById('pqPendingState');
    if(pqPending){
        if(activeTab&&activeTab.value==='mine')pqPending.style.display='block';
        else pqPending.style.display='none';
    }
    // Hide filter bar and status chips on Practice tab for Pending teachers
    if(activeTab&&activeTab.value==='mine'){
        if(fb)fb.style.display='none';
        var chips=document.querySelector('#<%=pnlStatusChips.ClientID%>');if(chips)chips.style.display='none';
    }
    // Disable Create Quiz button at top
    var createBtns=document.querySelectorAll('#<%=pnlCreateBtn.ClientID%> .mq-btn-create');
    for(var j=0;j<createBtns.length;j++){createBtns[j].classList.add('mq-btn-disabled');createBtns[j].removeAttribute('onclick');createBtns[j].setAttribute('title',tipText);}
    // 3. Discover tab: no restrictions — fully accessible
}
});
</script>
</asp:Content>
