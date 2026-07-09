<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="ScienceBuddy.Admin.Dashboard" MasterPageFile="~/Site.Master" Title="Admin Dashboard" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" />
<style>
:root{--db:#2563EB;--db-dark:#1D4ED8;--db-light:#EFF6FF;--db-gradient:linear-gradient(135deg,#1a237e 0%,#1565c0 30%,#2563EB 60%,#42a5f5 100%);}

/* ═══════════════════════════════════════════════════════════
   HERO SECTION — Premium Glassmorphism Command Center
   ═══════════════════════════════════════════════════════════ */
.db-hero{
    background:var(--db-gradient);
    border-radius:28px;
    padding:clamp(32px,5vw,56px) clamp(28px,4vw,48px);
    color:#fff;
    position:relative;
    overflow:hidden;
    margin-bottom:32px;
    min-height:340px;
    box-shadow:0 24px 80px rgba(37,99,235,.35),inset 0 1px 0 rgba(255,255,255,.15);
    transition:box-shadow .4s ease;
}
.db-hero:hover{box-shadow:0 28px 90px rgba(37,99,235,.45),inset 0 1px 0 rgba(255,255,255,.2);}

/* Animated background blobs */
.db-hero::before{content:'';position:absolute;width:600px;height:600px;border-radius:50%;background:radial-gradient(circle,rgba(255,255,255,.1) 0%,transparent 70%);top:-250px;right:-150px;animation:heroFloat 8s ease-in-out infinite;}
.db-hero::after{content:'';position:absolute;width:400px;height:400px;border-radius:50%;background:radial-gradient(circle,rgba(255,255,255,.06) 0%,transparent 70%);bottom:-150px;left:30px;animation:heroFloat 6s ease-in-out infinite reverse;}

.db-hero-blob1{position:absolute;width:200px;height:200px;border-radius:50%;background:radial-gradient(circle,rgba(96,165,250,.2) 0%,transparent 70%);top:60%;left:40%;animation:heroFloat 10s ease-in-out infinite 2s;}
.db-hero-blob2{position:absolute;width:150px;height:150px;border-radius:50%;background:radial-gradient(circle,rgba(255,255,255,.05) 0%,transparent 70%);top:20%;left:55%;animation:heroFloat 7s ease-in-out infinite 1s;}
.db-hero-blob3{position:absolute;width:100px;height:100px;border-radius:50%;background:radial-gradient(circle,rgba(147,197,253,.15) 0%,transparent 70%);bottom:30%;right:30%;animation:heroFloat 9s ease-in-out infinite 3s;}

/* Floating particles */
.db-hero-particle{position:absolute;border-radius:50%;background:rgba(255,255,255,.08);animation:particleDrift 12s linear infinite;}
.db-hero-particle:nth-child(1){width:6px;height:6px;top:20%;left:15%;animation-delay:0s;animation-duration:14s;}
.db-hero-particle:nth-child(2){width:4px;height:4px;top:60%;left:35%;animation-delay:2s;animation-duration:11s;}
.db-hero-particle:nth-child(3){width:8px;height:8px;top:40%;left:70%;animation-delay:4s;animation-duration:16s;}
.db-hero-particle:nth-child(4){width:5px;height:5px;top:75%;left:25%;animation-delay:1s;animation-duration:13s;}
.db-hero-particle:nth-child(5){width:3px;height:3px;top:30%;left:85%;animation-delay:3s;animation-duration:10s;}

@keyframes heroFloat{0%,100%{transform:translateY(0) scale(1)}50%{transform:translateY(-25px) scale(1.02)}}
@keyframes particleDrift{0%{transform:translateY(0) translateX(0);opacity:.6}25%{opacity:1}50%{transform:translateY(-30px) translateX(15px);opacity:.8}75%{opacity:.4}100%{transform:translateY(-60px) translateX(-10px);opacity:0}}
@keyframes mascotFloat{0%,100%{transform:translateY(0) rotate(0deg)}25%{transform:translateY(-8px) rotate(1deg)}50%{transform:translateY(-14px) rotate(0deg)}75%{transform:translateY(-6px) rotate(-1.5deg)}}
@keyframes mascotBreathe{0%,100%{transform:scale(1)}50%{transform:scale(1.015)}}
@keyframes floatingCircle{0%,100%{transform:translate(0,0) scale(1);opacity:.15}50%{transform:translate(10px,-15px) scale(1.1);opacity:.25}}
@keyframes pulseGlow{0%,100%{box-shadow:0 0 20px rgba(96,165,250,.2)}50%{box-shadow:0 0 40px rgba(96,165,250,.4)}}
@keyframes ripple{0%{transform:scale(0);opacity:.6}100%{transform:scale(4);opacity:0}}

/* Hero body layout */
.db-hero-body{position:relative;z-index:2;display:flex;align-items:center;justify-content:space-between;gap:32px;}

/* Left side */
.db-hero-left{flex:1;min-width:0;}
.db-hero-eyebrow{font-size:.72rem;font-weight:800;letter-spacing:2.5px;text-transform:uppercase;opacity:.75;margin-bottom:8px;display:flex;align-items:center;gap:8px;}
.db-hero-title{font-family:var(--font-primary);font-size:clamp(1.6rem,3.2vw,2.5rem);font-weight:900;line-height:1.1;margin-bottom:10px;text-shadow:0 2px 12px rgba(0,0,0,.12);}
.db-hero-sub{font-size:.88rem;opacity:.8;max-width:460px;line-height:1.7;margin-bottom:20px;}

/* Status pills */
.db-hero-pills{display:flex;gap:10px;flex-wrap:wrap;margin-bottom:24px;}
.db-hero-pill{background:rgba(255,255,255,.1);backdrop-filter:blur(12px);border:1px solid rgba(255,255,255,.18);border-radius:50px;padding:8px 16px;font-size:.75rem;font-weight:700;display:inline-flex;align-items:center;gap:7px;transition:all .3s cubic-bezier(.4,0,.2,1);cursor:default;}
.db-hero-pill:hover{background:rgba(255,255,255,.18);transform:translateY(-2px);box-shadow:0 8px 20px rgba(0,0,0,.1);}
.db-hero-pill .pill-dot{width:8px;height:8px;border-radius:50%;background:#4ade80;box-shadow:0 0 6px rgba(74,222,128,.5);animation:pulseGlow 3s ease-in-out infinite;}

/* Hero buttons */
.db-hero-actions{display:flex;gap:12px;flex-wrap:wrap;}
.db-hero-btn{padding:12px 24px;border-radius:14px;font-size:.82rem;font-weight:700;text-decoration:none;transition:all .3s cubic-bezier(.4,0,.2,1);display:inline-flex;align-items:center;gap:8px;background:rgba(255,255,255,.1);backdrop-filter:blur(12px);color:#fff;border:1px solid rgba(255,255,255,.22);position:relative;overflow:hidden;}
.db-hero-btn::after{content:'';position:absolute;inset:0;background:rgba(255,255,255,0);transition:background .3s;}
.db-hero-btn:hover{background:rgba(255,255,255,.2);transform:translateY(-3px);box-shadow:0 12px 30px rgba(0,0,0,.15);text-decoration:none;color:#fff;}
.db-hero-btn:hover::after{background:rgba(255,255,255,.05);}
.db-hero-btn:active{transform:translateY(-1px);}
.db-hero-btn.primary{background:#fff;color:#1D4ED8;border-color:#fff;box-shadow:0 6px 24px rgba(255,255,255,.25);}
.db-hero-btn.primary:hover{background:#F0F9FF;color:#1D4ED8;transform:translateY(-3px);box-shadow:0 12px 35px rgba(255,255,255,.35);}

/* Right side — Mascot */
.db-hero-right{flex-shrink:0;position:relative;width:220px;height:220px;display:flex;align-items:center;justify-content:center;}
.db-hero-mascot-wrap{position:relative;animation:mascotFloat 7s ease-in-out infinite;}
.db-hero-mascot-breathe{animation:mascotBreathe 4s ease-in-out infinite;}
.db-hero-mascot{width:180px;height:180px;object-fit:contain;filter:drop-shadow(0 12px 30px rgba(0,0,0,.2));transition:transform .4s cubic-bezier(.4,0,.2,1);position:relative;z-index:2;}
.db-hero:hover .db-hero-mascot{transform:rotate(-2deg) scale(1.03);}

/* Floating circles behind mascot */
.db-mascot-circle{position:absolute;border-radius:50%;border:2px solid rgba(255,255,255,.12);animation:floatingCircle 6s ease-in-out infinite;}
.db-mascot-circle:nth-child(1){width:60px;height:60px;top:10px;left:10px;animation-delay:0s;}
.db-mascot-circle:nth-child(2){width:40px;height:40px;bottom:20px;right:20px;animation-delay:2s;}
.db-mascot-circle:nth-child(3){width:50px;height:50px;top:50%;left:-10px;animation-delay:4s;}
.db-mascot-circle:nth-child(4){width:30px;height:30px;top:15px;right:5px;animation-delay:1s;}

/* ═══════════════════════════════════════════════════════════
   PLATFORM SNAPSHOT — Executive Summary Card
   ═══════════════════════════════════════════════════════════ */
.db-snapshot{background:var(--color-white,#fff);border-radius:24px;border:1px solid rgba(0,0,0,.05);box-shadow:0 4px 24px rgba(0,0,0,.04);padding:32px;margin-bottom:32px;transition:all .3s cubic-bezier(.4,0,.2,1);}
.db-snapshot:hover{box-shadow:0 12px 36px rgba(0,0,0,.07);}
.db-snapshot-header{margin-bottom:24px;}
.db-snapshot-title{font-family:var(--font-primary);font-size:1.15rem;font-weight:800;color:var(--color-text,#1e293b);display:flex;align-items:center;gap:10px;margin-bottom:4px;}
.db-snapshot-subtitle{font-size:.82rem;color:var(--color-text-muted,#94a3b8);font-weight:500;}
.db-snapshot-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:20px;}
.db-snap-group{background:var(--color-white,#fff);border-radius:18px;border:1px solid rgba(0,0,0,.05);padding:20px;transition:all .3s cubic-bezier(.4,0,.2,1);}
.db-snap-group:hover{border-color:rgba(37,99,235,.15);box-shadow:0 8px 24px rgba(0,0,0,.05);transform:translateY(-2px);}
.db-snap-group-header{display:flex;align-items:center;gap:8px;margin-bottom:16px;padding-bottom:12px;border-bottom:1px solid rgba(0,0,0,.04);}
.db-snap-group-ico{width:32px;height:32px;border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:.85rem;flex-shrink:0;}
.db-snap-group-title{font-size:.78rem;font-weight:700;color:var(--color-text,#1e293b);letter-spacing:.2px;}
.db-snap-items{display:flex;flex-direction:column;gap:12px;}
.db-snap-item{display:flex;align-items:center;justify-content:space-between;}
.db-snap-item-label{font-size:.76rem;font-weight:600;color:var(--color-text-secondary,#64748b);}
.db-snap-item-value{font-family:var(--font-primary);font-size:1.05rem;font-weight:800;color:var(--color-text,#1e293b);}
.db-snap-item-pill{display:inline-flex;align-items:center;gap:5px;padding:4px 12px;border-radius:50px;font-size:.7rem;font-weight:700;background:#D1FAE5;color:#065F46;}
.db-snap-item-pill .snap-dot{width:7px;height:7px;border-radius:50%;background:#22C55E;box-shadow:0 0 4px rgba(34,197,94,.4);}

/* ═══════════════════════════════════════════════════════════
   ADMINISTRATOR WORKSPACE — Premium Horizontal Cards
   ═══════════════════════════════════════════════════════════ */
.db-workspace{margin-bottom:36px;}
.db-workspace-header{margin-bottom:20px;}
.db-workspace-title{font-family:var(--font-primary);font-size:1.15rem;font-weight:800;color:var(--color-text,#1e293b);display:flex;align-items:center;gap:10px;margin-bottom:4px;}
.db-workspace-subtitle{font-size:.82rem;color:var(--color-text-muted,#94a3b8);font-weight:500;}
.db-workspace-grid{display:grid;grid-template-columns:repeat(2,1fr);gap:16px;}
.db-ws-card{display:flex;align-items:center;gap:18px;background:var(--color-white,#fff);border-radius:24px;border:1px solid rgba(0,0,0,.06);padding:22px 26px;text-decoration:none;transition:all .3s cubic-bezier(.4,0,.2,1);box-shadow:0 2px 12px rgba(0,0,0,.03);}
.db-ws-card:hover{transform:translateY(-4px);box-shadow:0 16px 36px rgba(37,99,235,.1);border-color:rgba(37,99,235,.3);text-decoration:none;}
.db-ws-card:active{transform:translateY(-2px);}
.db-ws-card-ico{width:52px;height:52px;border-radius:16px;display:flex;align-items:center;justify-content:center;font-size:1.3rem;flex-shrink:0;transition:transform .3s;}
.db-ws-card:hover .db-ws-card-ico{transform:scale(1.08);}
.db-ws-card-body{flex:1;min-width:0;}
.db-ws-card-title{font-family:var(--font-primary);font-size:.88rem;font-weight:800;color:var(--color-text,#1e293b);margin-bottom:3px;}
.db-ws-card-desc{font-size:.76rem;color:var(--color-text-muted,#94a3b8);font-weight:500;line-height:1.4;}
.db-ws-card-arrow{width:32px;height:32px;border-radius:10px;background:var(--db-light,#EFF6FF);color:var(--db);display:flex;align-items:center;justify-content:center;font-size:.85rem;flex-shrink:0;transition:all .3s;}
.db-ws-card:hover .db-ws-card-arrow{background:var(--db);color:#fff;transform:translateX(3px);}

/* ═══════════════════════════════════════════════════════════
   TWO-COLUMN SECTIONS
   ═══════════════════════════════════════════════════════════ */
.db-row2{display:grid;grid-template-columns:1fr 1fr;gap:24px;margin-bottom:28px;}
.db-section{background:var(--color-white,#fff);border-radius:24px;border:1px solid rgba(0,0,0,.05);box-shadow:0 4px 24px rgba(0,0,0,.04);overflow:hidden;transition:all .3s cubic-bezier(.4,0,.2,1);}
.db-section:hover{box-shadow:0 12px 32px rgba(0,0,0,.06);}
.db-sec-hdr{padding:18px 24px;border-bottom:1px solid rgba(0,0,0,.04);display:flex;align-items:center;justify-content:space-between;}
.db-sec-title{font-family:var(--font-primary);font-size:.92rem;font-weight:800;color:var(--color-text,#1e293b);display:flex;align-items:center;gap:8px;}
.db-sec-body{padding:20px 24px;max-height:400px;overflow-y:auto;}

/* Activity Timeline */
.db-timeline{position:relative;padding-left:20px;}
.db-timeline::before{content:'';position:absolute;left:8px;top:12px;bottom:12px;width:2px;background:linear-gradient(180deg,rgba(37,99,235,.2) 0%,rgba(37,99,235,.05) 100%);border-radius:2px;}
.db-timeline-item{display:flex;align-items:flex-start;gap:14px;padding:12px 0;position:relative;transition:background .15s;border-radius:10px;margin:0 -8px;padding-left:8px;padding-right:8px;}
.db-timeline-item:hover{background:rgba(37,99,235,.02);}
.db-timeline-dot{width:10px;height:10px;border-radius:50%;flex-shrink:0;margin-top:5px;position:relative;z-index:1;box-shadow:0 0 0 3px var(--color-white,#fff);}
.db-timeline-dot.green{background:#22c55e;}
.db-timeline-dot.orange{background:#f59e0b;}
.db-timeline-dot.blue{background:#3b82f6;}
.db-timeline-dot.red{background:#ef4444;}
.db-timeline-dot.purple{background:#8b5cf6;}
.db-timeline-body{flex:1;min-width:0;}
.db-timeline-action{font-weight:700;font-size:.82rem;color:var(--color-text,#1e293b);}
.db-timeline-desc{font-size:.75rem;color:var(--color-text-muted,#94a3b8);margin-top:2px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.db-timeline-time{font-size:.7rem;color:var(--color-text-muted,#94a3b8);margin-top:4px;display:flex;align-items:center;gap:5px;}

/* Notifications */
.db-notif{display:flex;gap:14px;padding:14px 0;border-bottom:1px solid rgba(0,0,0,.03);align-items:flex-start;transition:background .15s;border-radius:10px;margin:0 -8px;padding-left:8px;padding-right:8px;}
.db-notif:last-child{border-bottom:none;}
.db-notif:hover{background:rgba(37,99,235,.02);}
.db-notif-dot{width:10px;height:10px;border-radius:50%;margin-top:6px;flex-shrink:0;background:var(--db);box-shadow:0 0 0 3px rgba(37,99,235,.12);}
.db-notif-dot.read{background:#CBD5E1;box-shadow:none;}
.db-notif-body{flex:1;min-width:0;}
.db-notif-title{font-size:.82rem;font-weight:700;color:var(--color-text,#1e293b);}
.db-notif-msg{font-size:.75rem;color:var(--color-text-muted,#94a3b8);margin-top:2px;line-height:1.4;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;}
.db-notif-time{font-size:.7rem;color:var(--color-text-muted,#94a3b8);margin-top:4px;display:flex;align-items:center;gap:4px;}

/* Pending Reviews Table */
.db-review-table{width:100%;border-collapse:separate;border-spacing:0;font-size:.8rem;}
.db-review-table thead th{font-size:.7rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted,#94a3b8);padding:8px 12px;border-bottom:1px solid rgba(0,0,0,.05);text-align:left;}
.db-review-table tbody tr{transition:background .15s;}
.db-review-table tbody tr:hover{background:rgba(37,99,235,.02);}
.db-review-table tbody td{padding:12px;border-bottom:1px solid rgba(0,0,0,.03);color:var(--color-text,#1e293b);}
.db-review-table tbody tr:last-child td{border-bottom:none;}
.db-review-badge{display:inline-flex;align-items:center;gap:4px;padding:4px 10px;border-radius:8px;font-size:.7rem;font-weight:700;}
.db-review-badge.type-question{background:#FEF3C7;color:#92400E;}
.db-review-badge.type-material{background:#DBEAFE;color:#1E40AF;}
.db-review-badge.priority-high{background:#FEE2E2;color:#991B1B;}
.db-review-badge.priority-medium{background:#FEF3C7;color:#92400E;}
.db-review-badge.priority-low{background:#D1FAE5;color:#065F46;}
.db-review-btn{display:inline-flex;align-items:center;gap:4px;padding:6px 14px;border-radius:8px;font-size:.72rem;font-weight:700;background:var(--db);color:#fff;text-decoration:none;transition:all .2s;border:none;cursor:pointer;}
.db-review-btn:hover{background:var(--db-dark);transform:translateY(-1px);box-shadow:0 4px 12px rgba(37,99,235,.3);text-decoration:none;color:#fff;}

/* Empty states */
.db-empty{display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;padding:40px 20px;color:var(--color-text-muted,#94a3b8);}
.db-empty i{font-size:2.5rem;opacity:.3;margin-bottom:12px;}
.db-empty-msg{font-size:.88rem;font-weight:600;color:var(--color-text-secondary,#64748b);}

/* Link button */
.db-link-btn{font-size:.78rem;font-weight:700;color:var(--db);text-decoration:none;display:inline-flex;align-items:center;gap:4px;transition:gap .2s,color .2s;}
.db-link-btn:hover{gap:8px;color:var(--db-dark);text-decoration:none;}

/* ═══════════════════════════════════════════════════════════
   RESPONSIVE
   ═══════════════════════════════════════════════════════════ */
@media(max-width:1279px){.db-snapshot-grid{grid-template-columns:repeat(2,1fr);}.db-workspace-grid{grid-template-columns:repeat(2,1fr);}}
@media(max-width:1023px){.db-row2{grid-template-columns:1fr;}.db-hero-body{flex-direction:column;align-items:flex-start;}.db-hero-right{width:160px;height:160px;align-self:center;}}
@media(max-width:767px){.db-snapshot-grid{grid-template-columns:1fr;}.db-workspace-grid{grid-template-columns:1fr;}.db-hero-mascot{width:140px;height:140px;}.db-hero-right{width:140px;height:140px;}}
@media(max-width:479px){.db-workspace-grid{grid-template-columns:1fr;}.db-hero-right{display:none;}}
</style>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="<%: ResolveUrl("~/Scripts/admin-signout.js") %>"></script>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
<div class="sb-nav-section"><div class="sb-nav-section-label">Main</div><a href="<%: ResolveUrl("~/Admin/Dashboard.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label">Dashboard</span></a></div>
<div class="sb-nav-section"><div class="sb-nav-section-label">User Management</div><a href="<%: ResolveUrl("~/Admin/StudentManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-people item-icon"></i><span class="item-label">Students</span></a><a href="<%: ResolveUrl("~/Admin/ParentManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-heart item-icon"></i><span class="item-label">Parents</span></a><a href="<%: ResolveUrl("~/Admin/TeacherManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-badge item-icon"></i><span class="item-label">Teachers</span></a></div>
<div class="sb-nav-section"><div class="sb-nav-section-label">Learning Content</div><a href="<%: ResolveUrl("~/Admin/LessonManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label">Lessons</span></a><a href="<%: ResolveUrl("~/Admin/QuizManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label">Quizzes</span></a><a href="<%: ResolveUrl("~/Admin/QuestionBank.aspx") %>" class="sb-sidebar-item"><i class="bi bi-question-circle item-icon"></i><span class="item-label">Question Bank</span></a><a href="<%: ResolveUrl("~/Admin/TeacherMaterials.aspx") %>" class="sb-sidebar-item"><i class="bi bi-file-earmark-text item-icon"></i><span class="item-label">Material Requests</span></a><a href="<%: ResolveUrl("~/Admin/LiveSessions.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label">Live Sessions</span></a><a href="<%: ResolveUrl("~/Admin/QuestionRequests.aspx") %>" class="sb-sidebar-item"><i class="bi bi-clipboard-check item-icon"></i><span class="item-label">Question Requests</span></a><a href="<%: ResolveUrl("~/Admin/CertificateManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-award item-icon"></i><span class="item-label">Certificates</span></a></div>
<div class="sb-nav-section"><div class="sb-nav-section-label">Community</div><a href="<%: ResolveUrl("~/Admin/ForumDiscussions.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label">Forum Discussions</span></a></div>
<div class="sb-nav-section"><div class="sb-nav-section-label">Gamification</div><a href="<%: ResolveUrl("~/Admin/GamificationManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-trophy item-icon"></i><span class="item-label">Student Performance</span></a></div>
<div class="sb-nav-section"><div class="sb-nav-section-label">Configuration</div><a href="<%: ResolveUrl("~/Admin/SystemSettings.aspx") %>" class="sb-sidebar-item"><i class="bi bi-gear item-icon"></i><span class="item-label">System Settings</span></a></div>
<div class="sb-nav-section"><div class="sb-nav-section-label">Logs</div><a href="<%: ResolveUrl("~/Admin/SystemActivityLogs.aspx") %>" class="sb-sidebar-item"><i class="bi bi-clock-history item-icon"></i><span class="item-label">Activity Logs</span></a><a href="<%: ResolveUrl("~/Admin/LoginLogs.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-in-right item-icon"></i><span class="item-label">Login Logs</span></a><a href="<%: ResolveUrl("~/Admin/SuspiciousLogins.aspx") %>" class="sb-sidebar-item"><i class="bi bi-exclamation-triangle item-icon"></i><span class="item-label">Suspicious Logins</span></a></div>
<div class="sb-nav-section"><div class="sb-nav-section-label">Account</div><a href="<%: ResolveUrl("~/Admin/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span></a><a href="<%: ResolveUrl("~/Admin/Profile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a><a href="javascript:;" class="sb-sidebar-item" onclick="showSignOutModal()"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a></div>
</asp:Content>
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">Admin Dashboard</asp:Content>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<!-- ═══════════════════ HERO SECTION ═══════════════════ -->
<div class="db-hero">
    <!-- Background particles -->
    <div class="db-hero-particle"></div>
    <div class="db-hero-particle"></div>
    <div class="db-hero-particle"></div>
    <div class="db-hero-particle"></div>
    <div class="db-hero-particle"></div>
    <!-- Animated blobs -->
    <div class="db-hero-blob1"></div>
    <div class="db-hero-blob2"></div>
    <div class="db-hero-blob3"></div>

    <div class="db-hero-body">
        <!-- LEFT SIDE -->
        <div class="db-hero-left">
            <div class="db-hero-eyebrow"><i class="bi bi-shield-check"></i> <%= T("Administrator Console", "Konsol Pentadbir") %></div>
            <div class="db-hero-title"><%= T("Welcome back,", "Selamat kembali,") %> <asp:Literal ID="litAdminName" runat="server" Text="Admin" />!</div>
            <div class="db-hero-sub"><%= T("Manage users, monitor learning content, and keep ScienceBuddy running smoothly from your control center.", "Urus pengguna, pantau kandungan pembelajaran, dan pastikan ScienceBuddy berjalan lancar dari pusat kawalan anda.") %></div>

            <!-- Status Pills -->
            <div class="db-hero-pills">
                <span class="db-hero-pill"><i class="bi bi-calendar3"></i> <asp:Literal ID="litDate" runat="server" /></span>
                <span class="db-hero-pill"><i class="bi bi-hourglass-split"></i> <asp:Literal ID="litPendingRequests" runat="server" Text="0" /> <%= T("Pending Reviews", "Semakan Tertunggak") %></span>
                <span class="db-hero-pill"><span class="pill-dot"></span> <%= T("Database Connected", "Pangkalan Data Aktif") %></span>
                <span class="db-hero-pill"><span class="pill-dot"></span> <%= T("Notifications Active", "Notifikasi Aktif") %></span>
                <span class="db-hero-pill"><span class="pill-dot"></span> <%= T("System Healthy", "Sistem Sihat") %></span>
            </div>

            <!-- Hero Buttons -->
            <div class="db-hero-actions">
                <a href="<%: ResolveUrl("~/Admin/QuestionRequests.aspx") %>" class="db-hero-btn primary"><i class="bi bi-clipboard-check"></i> <%= T("Review Requests", "Semak Permintaan") %></a>
                <a href="<%: ResolveUrl("~/Admin/StudentManagement.aspx") %>" class="db-hero-btn"><i class="bi bi-people"></i> <%= T("Manage Users", "Urus Pengguna") %></a>
                <a href="<%: ResolveUrl("~/Admin/SystemSettings.aspx") %>" class="db-hero-btn"><i class="bi bi-gear"></i> <%= T("System Settings", "Tetapan Sistem") %></a>
            </div>
        </div>

        <!-- RIGHT SIDE — Mascot -->
        <div class="db-hero-right">
            <div class="db-mascot-circle"></div>
            <div class="db-mascot-circle"></div>
            <div class="db-mascot-circle"></div>
            <div class="db-mascot-circle"></div>
            <div class="db-hero-mascot-wrap">
                <div class="db-hero-mascot-breathe">
                    <img src="<%: ResolveUrl("~/Images/Personality/chill-learner.png") %>" alt="ScienceBuddy Assistant" class="db-hero-mascot" />
                </div>
            </div>
        </div>
    </div>
</div>

<!-- ═══════════════════ PLATFORM SNAPSHOT ═══════════════════ -->
<div class="db-snapshot">
    <div class="db-snapshot-header">
        <div class="db-snapshot-title"><i class="bi bi-bar-chart-line-fill" style="color:var(--db);"></i> <%= T("Platform Snapshot", "Gambaran Platform") %></div>
        <div class="db-snapshot-subtitle"><%= T("Live overview of the ScienceBuddy platform.", "Gambaran langsung platform ScienceBuddy.") %></div>
    </div>
    <div class="db-snapshot-grid">
        <!-- Users -->
        <div class="db-snap-group">
            <div class="db-snap-group-header">
                <div class="db-snap-group-ico" style="background:#DBEAFE;color:#2563EB;"><i class="bi bi-people-fill"></i></div>
                <div class="db-snap-group-title"><%= T("Users", "Pengguna") %></div>
            </div>
            <div class="db-snap-items">
                <div class="db-snap-item"><span class="db-snap-item-label"><%= T("Students", "Pelajar") %></span><span class="db-snap-item-value"><asp:Literal ID="litStudents" runat="server" Text="0" /></span></div>
                <div class="db-snap-item"><span class="db-snap-item-label"><%= T("Parents", "Ibu Bapa") %></span><span class="db-snap-item-value"><asp:Literal ID="litParents" runat="server" Text="0" /></span></div>
                <div class="db-snap-item"><span class="db-snap-item-label"><%= T("Teachers", "Guru") %></span><span class="db-snap-item-value"><asp:Literal ID="litTeachers" runat="server" Text="0" /></span></div>
            </div>
        </div>
        <!-- Learning Content -->
        <div class="db-snap-group">
            <div class="db-snap-group-header">
                <div class="db-snap-group-ico" style="background:#D1FAE5;color:#059669;"><i class="bi bi-collection-fill"></i></div>
                <div class="db-snap-group-title"><%= T("Learning Content", "Kandungan Pembelajaran") %></div>
            </div>
            <div class="db-snap-items">
                <div class="db-snap-item"><span class="db-snap-item-label"><%= T("Lessons", "Pelajaran") %></span><span class="db-snap-item-value"><asp:Literal ID="litLessons" runat="server" Text="0" /></span></div>
                <div class="db-snap-item"><span class="db-snap-item-label"><%= T("Quizzes", "Kuiz") %></span><span class="db-snap-item-value"><asp:Literal ID="litQuizzes" runat="server" Text="0" /></span></div>
                <div class="db-snap-item"><span class="db-snap-item-label"><%= T("Question Bank", "Bank Soalan") %></span><span class="db-snap-item-value"><asp:Literal ID="litQuestions" runat="server" Text="0" /></span></div>
                <div class="db-snap-item"><span class="db-snap-item-label"><%= T("Materials", "Bahan") %></span><span class="db-snap-item-value"><asp:Literal ID="litMaterials" runat="server" Text="0" /></span></div>
            </div>
        </div>
        <!-- Pending Reviews -->
        <div class="db-snap-group">
            <div class="db-snap-group-header">
                <div class="db-snap-group-ico" style="background:#FEF3C7;color:#D97706;"><i class="bi bi-hourglass-split"></i></div>
                <div class="db-snap-group-title"><%= T("Pending Reviews", "Semakan Tertunggak") %></div>
            </div>
            <div class="db-snap-items">
                <div class="db-snap-item"><span class="db-snap-item-label"><%= T("Questions", "Soalan") %></span><span class="db-snap-item-value"><asp:Literal ID="litPendingQ" runat="server" Text="0" /></span></div>
                <div class="db-snap-item"><span class="db-snap-item-label"><%= T("Materials", "Bahan") %></span><span class="db-snap-item-value"><asp:Literal ID="litPendingM" runat="server" Text="0" /></span></div>
                <div class="db-snap-item"><span class="db-snap-item-label"><%= T("Forum Reports", "Laporan Forum") %></span><span class="db-snap-item-value"><asp:Literal ID="litForumReports" runat="server" Text="0" /></span></div>
            </div>
        </div>
        <!-- Platform Status -->
        <div class="db-snap-group">
            <div class="db-snap-group-header">
                <div class="db-snap-group-ico" style="background:#D1FAE5;color:#059669;"><i class="bi bi-shield-check"></i></div>
                <div class="db-snap-group-title"><%= T("Platform Status", "Status Platform") %></div>
            </div>
            <div class="db-snap-items">
                <div class="db-snap-item"><span class="db-snap-item-label"><%= T("Database", "Pangkalan Data") %></span><span class="db-snap-item-pill"><span class="snap-dot"></span> <%= T("Healthy", "Sihat") %></span></div>
                <div class="db-snap-item"><span class="db-snap-item-label"><%= T("Notifications", "Notifikasi") %></span><span class="db-snap-item-pill"><span class="snap-dot"></span> <%= T("Healthy", "Sihat") %></span></div>
                <div class="db-snap-item"><span class="db-snap-item-label"><%= T("Authentication", "Pengesahan") %></span><span class="db-snap-item-pill"><span class="snap-dot"></span> <%= T("Healthy", "Sihat") %></span></div>
                <div class="db-snap-item"><span class="db-snap-item-label"><%= T("Last Backup", "Sandaran Terakhir") %></span><span class="db-snap-item-value" style="font-size:.78rem;"><%= T("Today 2:00 AM", "Hari ini 2:00 AM") %></span></div>
            </div>
        </div>
    </div>
</div>

<!-- ═══════════════════ ADMINISTRATOR WORKSPACE ═══════════════════ -->
<div class="db-workspace">
    <div class="db-workspace-header">
        <div class="db-workspace-title"><i class="bi bi-grid-1x2-fill" style="color:var(--db);"></i> <%= T("Administrator Workspace", "Ruang Kerja Pentadbir") %></div>
        <div class="db-workspace-subtitle"><%= T("The tools you use most frequently.", "Alat yang paling kerap anda gunakan.") %></div>
    </div>
    <div class="db-workspace-grid">
        <a href="<%: ResolveUrl("~/Admin/StudentManagement.aspx") %>" class="db-ws-card">
            <div class="db-ws-card-ico" style="background:#DBEAFE;color:#2563EB;"><i class="bi bi-people-fill"></i></div>
            <div class="db-ws-card-body">
                <div class="db-ws-card-title"><%= T("User Management", "Pengurusan Pengguna") %></div>
                <div class="db-ws-card-desc"><%= T("Manage students, parents & teachers", "Urus pelajar, ibu bapa & guru") %></div>
            </div>
            <div class="db-ws-card-arrow"><i class="bi bi-arrow-right"></i></div>
        </a>
        <a href="<%: ResolveUrl("~/Admin/LessonManagement.aspx") %>" class="db-ws-card">
            <div class="db-ws-card-ico" style="background:#D1FAE5;color:#059669;"><i class="bi bi-collection-fill"></i></div>
            <div class="db-ws-card-body">
                <div class="db-ws-card-title"><%= T("Learning Content", "Kandungan Pembelajaran") %></div>
                <div class="db-ws-card-desc"><%= T("Lessons, quizzes & question bank", "Pelajaran, kuiz & bank soalan") %></div>
            </div>
            <div class="db-ws-card-arrow"><i class="bi bi-arrow-right"></i></div>
        </a>
        <a href="<%: ResolveUrl("~/Admin/QuestionRequests.aspx") %>" class="db-ws-card">
            <div class="db-ws-card-ico" style="background:#FEF3C7;color:#D97706;"><i class="bi bi-clipboard-check-fill"></i></div>
            <div class="db-ws-card-body">
                <div class="db-ws-card-title"><%= T("Review Requests", "Semak Permintaan") %></div>
                <div class="db-ws-card-desc"><%= T("Approve pending questions & materials", "Luluskan soalan & bahan tertunggak") %></div>
            </div>
            <div class="db-ws-card-arrow"><i class="bi bi-arrow-right"></i></div>
        </a>
        <a href="<%: ResolveUrl("~/Admin/ForumDiscussions.aspx") %>" class="db-ws-card">
            <div class="db-ws-card-ico" style="background:#EDE9FE;color:#7C3AED;"><i class="bi bi-chat-dots-fill"></i></div>
            <div class="db-ws-card-body">
                <div class="db-ws-card-title"><%= T("Forum Moderation", "Moderasi Forum") %></div>
                <div class="db-ws-card-desc"><%= T("Monitor discussions and reported posts", "Pantau perbincangan dan pos dilaporkan") %></div>
            </div>
            <div class="db-ws-card-arrow"><i class="bi bi-arrow-right"></i></div>
        </a>
        <a href="<%: ResolveUrl("~/Admin/Notifications.aspx") %>" class="db-ws-card">
            <div class="db-ws-card-ico" style="background:#FCE7F3;color:#DB2777;"><i class="bi bi-bell-fill"></i></div>
            <div class="db-ws-card-body">
                <div class="db-ws-card-title"><%= T("Notifications", "Notifikasi") %></div>
                <div class="db-ws-card-desc"><%= T("Send platform announcements", "Hantar pengumuman platform") %></div>
            </div>
            <div class="db-ws-card-arrow"><i class="bi bi-arrow-right"></i></div>
        </a>
        <a href="<%: ResolveUrl("~/Admin/SystemSettings.aspx") %>" class="db-ws-card">
            <div class="db-ws-card-ico" style="background:#F0F9FF;color:#0284C7;"><i class="bi bi-gear-fill"></i></div>
            <div class="db-ws-card-body">
                <div class="db-ws-card-title"><%= T("System Settings", "Tetapan Sistem") %></div>
                <div class="db-ws-card-desc"><%= T("Configure ScienceBuddy settings", "Konfigurasi tetapan ScienceBuddy") %></div>
            </div>
            <div class="db-ws-card-arrow"><i class="bi bi-arrow-right"></i></div>
        </a>
    </div>
</div>

<!-- ═══════════════════ ACTIVITY + PENDING REVIEWS ═══════════════════ -->
<div class="db-row2">
    <!-- Recent Activity Timeline -->
    <div class="db-section">
        <div class="db-sec-hdr">
            <div class="db-sec-title"><i class="bi bi-clock-history" style="color:#7C3AED;"></i> <%= T("Recent Activity","Aktiviti Terkini") %></div>
            <a href="<%: ResolveUrl("~/Admin/SystemActivityLogs.aspx") %>" class="db-link-btn"><%= T("View All","Lihat Semua") %> <i class="bi bi-arrow-right"></i></a>
        </div>
        <div class="db-sec-body">
            <asp:Panel ID="pnlLogs" runat="server" Visible="false">
                <div class="db-timeline">
                    <asp:Repeater ID="rptLogs" runat="server">
                        <ItemTemplate>
                            <div class="db-timeline-item">
                                <div class='db-timeline-dot <%# Eval("dotColor") %>'></div>
                                <div class="db-timeline-body">
                                    <div class="db-timeline-action"><%# Eval("action") %></div>
                                    <div class="db-timeline-desc"><%# Eval("description") %></div>
                                    <div class="db-timeline-time"><i class="bi bi-person"></i> <%# Eval("username") %> &middot; <%# Eval("timeAgo") %></div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </asp:Panel>
            <asp:Panel ID="pnlLogsEmpty" runat="server">
                <div class="db-empty"><i class="bi bi-clock-history"></i><div class="db-empty-msg"><%= T("No recent activity.","Tiada aktiviti terkini.") %></div></div>
            </asp:Panel>
        </div>
    </div>

    <!-- Pending Reviews Table -->
    <div class="db-section">
        <div class="db-sec-hdr">
            <div class="db-sec-title"><i class="bi bi-hourglass-split" style="color:#D97706;"></i> <%= T("Pending Reviews","Semakan Tertunggak") %></div>
            <a href="<%: ResolveUrl("~/Admin/QuestionRequests.aspx") %>" class="db-link-btn"><%= T("View All","Lihat Semua") %> <i class="bi bi-arrow-right"></i></a>
        </div>
        <div class="db-sec-body">
            <asp:Panel ID="pnlRequests" runat="server" Visible="false">
                <table class="db-review-table">
                    <thead><tr><th><%= T("Type","Jenis") %></th><th><%= T("Submitted By","Dihantar Oleh") %></th><th><%= T("Date","Tarikh") %></th><th><%= T("Priority","Keutamaan") %></th><th></th></tr></thead>
                    <tbody>
                        <asp:Repeater ID="rptRequests" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td><span class='db-review-badge type-<%# Eval("badgeType") %>'><%# Eval("requestType") %></span></td>
                                    <td style="font-weight:600;"><%# Eval("requestedBy") %></td>
                                    <td style="color:var(--color-text-muted,#94a3b8);"><%# Eval("requestedDate") %></td>
                                    <td><span class='db-review-badge priority-<%# Eval("priority") %>'><%# Eval("priorityLabel") %></span></td>
                                    <td><a href="<%: ResolveUrl("~/Admin/QuestionRequests.aspx") %>" class="db-review-btn"><%= T("Review","Semak") %> <i class="bi bi-arrow-right"></i></a></td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </asp:Panel>
            <asp:Panel ID="pnlRequestsEmpty" runat="server">
                <div class="db-empty"><i class="bi bi-check-circle" style="color:#059669;"></i><div class="db-empty-msg"><%= T("No pending reviews. All caught up!","Tiada semakan tertunggak. Semuanya selesai!") %></div></div>
            </asp:Panel>
        </div>
    </div>
</div>

<!-- ═══════════════════ NOTIFICATIONS ═══════════════════ -->
<div class="db-section" style="margin-bottom:32px;">
    <div class="db-sec-hdr">
        <div class="db-sec-title"><i class="bi bi-bell-fill" style="color:#DC2626;"></i> <%= T("Recent Notifications","Notifikasi Terkini") %></div>
        <a href="<%: ResolveUrl("~/Admin/Notifications.aspx") %>" class="db-link-btn"><%= T("View All","Lihat Semua") %> <i class="bi bi-arrow-right"></i></a>
    </div>
    <div class="db-sec-body">
        <asp:Panel ID="pnlNotifs" runat="server" Visible="false">
            <asp:Repeater ID="rptNotifs" runat="server">
                <ItemTemplate>
                    <div class="db-notif">
                        <div class='db-notif-dot <%# Convert.ToBoolean(Eval("isRead")) ? "read" : "" %>'></div>
                        <div class="db-notif-body">
                            <div class="db-notif-title"><%# Eval("title") %></div>
                            <div class="db-notif-msg"><%# Eval("message") %></div>
                            <div class="db-notif-time"><i class="bi bi-clock"></i> <%# Eval("timeAgo") %></div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </asp:Panel>
        <asp:Panel ID="pnlNotifsEmpty" runat="server">
            <div class="db-empty"><i class="bi bi-bell-slash"></i><div class="db-empty-msg"><%= T("No notifications.","Tiada notifikasi.") %></div></div>
        </asp:Panel>
    </div>
</div>


</asp:Content>
