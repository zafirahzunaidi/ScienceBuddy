<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ParentDashboard.aspx.cs"
    Inherits="ScienceBuddy.Parent.ParentDashboard" MasterPageFile="~/Site.Master"
    Title="Parent Dashboard" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root {
    --parent-primary: #2563EB;
    --parent-secondary: #F59E0B;
    --parent-light: #EFF6FF;
    --parent-card-bg: #FFFFFF;
    --parent-text: #1E293B;
    --parent-muted: #64748B;
    --parent-success: #10B981;
    --parent-warning: #F59E0B;
    --parent-danger: #EF4444;
    --parent-radius: 16px;
    --parent-radius-sm: 10px;
    --parent-shadow: 0 4px 20px rgba(0,0,0,0.06);
    --parent-shadow-hover: 0 8px 30px rgba(0,0,0,0.10);
}
.pd-page { padding: 24px 0; }

/* ── Redesigned Hero Card ───────────────────────────────────── */
.pd-hero {
    background: linear-gradient(135deg, #1D4ED8 0%, #2563EB 40%, #3B82F6 70%, #60A5FA 100%);
    border-radius: 24px;
    padding: 36px 40px 32px;
    color: #fff;
    position: relative;
    overflow: hidden;
    margin-bottom: 24px;
    box-shadow: 0 16px 48px rgba(37,99,235,0.22);
}
/* large soft blob top-right */
.pd-hero::before {
    content: '';
    position: absolute;
    width: 260px; height: 260px;
    border-radius: 50%;
    background: rgba(255,255,255,0.06);
    top: -80px; right: -40px;
    pointer-events: none;
}
/* warm yellow blob bottom-left */
.pd-hero::after {
    content: '';
    position: absolute;
    width: 180px; height: 180px;
    border-radius: 50%;
    background: rgba(245,158,11,0.12);
    bottom: -60px; left: 40px;
    pointer-events: none;
}
/* decorative sparkle shapes (CSS only, no JS) */
.pd-hero-spark1 {
    position: absolute; top: 18px; right: 120px;
    width: 10px; height: 10px; border-radius: 50%;
    background: rgba(255,255,255,0.22);
    pointer-events: none;
}
.pd-hero-spark2 {
    position: absolute; top: 52px; right: 80px;
    width: 6px; height: 6px; border-radius: 50%;
    background: rgba(255,255,255,0.15);
    pointer-events: none;
}
.pd-hero-spark3 {
    position: absolute; bottom: 30px; right: 200px;
    width: 8px; height: 8px; border-radius: 50%;
    background: rgba(245,158,11,0.30);
    pointer-events: none;
}
.pd-hero-spark4 {
    position: absolute; top: 80px; left: 200px;
    width: 5px; height: 5px; border-radius: 50%;
    background: rgba(255,255,255,0.18);
    pointer-events: none;
}
/* eyebrow label */
.pd-hero-eyebrow {
    font-size: 0.72rem;
    font-weight: 700;
    letter-spacing: 1.5px;
    text-transform: uppercase;
    opacity: 0.80;
    margin-bottom: 8px;
    display: flex;
    align-items: center;
    gap: 6px;
}
/* main greeting */
.pd-hero-greeting {
    font-size: 1.85rem;
    font-weight: 800;
    line-height: 1.15;
    margin-bottom: 6px;
    text-shadow: 0 2px 10px rgba(0,0,0,0.12);
}
/* currently viewing subtitle */
.pd-hero-viewing {
    font-size: 0.92rem;
    opacity: 0.88;
    margin-bottom: 18px;
    display: flex;
    align-items: center;
    gap: 6px;
}
/* pill row */
.pd-hero-pills {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-bottom: 20px;
}
.pd-hero-pill {
    background: rgba(255,255,255,0.18);
    border: 1.5px solid rgba(255,255,255,0.28);
    border-radius: 999px;
    padding: 5px 14px;
    font-size: 0.80rem;
    font-weight: 700;
    display: inline-flex;
    align-items: center;
    gap: 5px;
    backdrop-filter: blur(4px);
}
.pd-hero-pill.xp { background: rgba(245,158,11,0.22); border-color: rgba(245,158,11,0.40); }
.pd-hero-pill.badge { background: rgba(139,92,246,0.22); border-color: rgba(139,92,246,0.35); }
/* hero action row — selector + button side by side */
.pd-hero-action-row {
    display: flex;
    align-items: center;
    gap: 12px;
    flex-wrap: wrap;
    margin-top: 14px;
}
/* hero child dropdown — styled pill */
.pd-hero-ddl {
    min-width: 150px;
    max-width: 260px;
    width: auto;
    background: rgba(255,255,255,0.92);
    border: 2px solid rgba(255,255,255,0.95);
    border-radius: 999px;
    color: #1D4ED8;
    font-size: 0.88rem;
    font-weight: 700;
    padding: 9px 18px 9px 14px;
    cursor: pointer;
    box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    appearance: auto;
    transition: box-shadow 0.2s;
}
.pd-hero-ddl:focus {
    outline: none;
    box-shadow: 0 0 0 3px rgba(255,255,255,0.40);
}
.pd-hero-ddl option {
    background: #fff;
    color: #1E293B;
    font-weight: 600;
    padding: 8px 12px;
}
/* link new child button */
.pd-hero-link-btn {
    display: inline-flex;
    align-items: center;
    gap: 7px;
    background: rgba(255,255,255,0.16);
    border: 2px solid rgba(255,255,255,0.35);
    border-radius: 999px;
    color: #fff;
    font-size: 0.85rem;
    font-weight: 700;
    padding: 9px 20px;
    text-decoration: none;
    backdrop-filter: blur(4px);
    transition: background 0.2s, border-color 0.2s;
    white-space: nowrap;
}
.pd-hero-link-btn:hover {
    background: rgba(255,255,255,0.26);
    border-color: rgba(255,255,255,0.60);
    color: #fff;
    text-decoration: none;
}
/* no-child state inside hero */
.pd-hero-nochild {
    background: rgba(255,255,255,0.12);
    border: 1.5px dashed rgba(255,255,255,0.35);
    border-radius: 16px;
    padding: 20px 24px;
    margin-bottom: 16px;
    font-size: 0.88rem;
    opacity: 0.92;
}
.pd-selector-card { display:none; } /* removed — duplicate selector */
.pd-child-overview { display:none; } /* removed — replaced by snapshot card */

/* ── Hero dropdown label ─────────────────────────────────── */
.pd-hero-ddl-label {
    font-size: 0.72rem;
    font-weight: 700;
    letter-spacing: 1px;
    text-transform: uppercase;
    opacity: 0.75;
    margin-bottom: 6px;
    display: flex;
    align-items: center;
    gap: 5px;
}

/* ── Child Snapshot Card ─────────────────────────────────── */
.pd-snapshot {
    background: #fff;
    border-radius: 20px;
    box-shadow: 0 4px 24px rgba(37,99,235,0.08);
    margin-bottom: 24px;
    overflow: hidden;
}
.pd-snapshot-header {
    background: linear-gradient(135deg, #EFF6FF 0%, #F0FDF4 100%);
    padding: 18px 24px 14px;
    border-bottom: 1px solid #E2E8F0;
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 8px;
}
.pd-snapshot-title {
    font-size: 1rem;
    font-weight: 700;
    color: #1E293B;
    display: flex;
    align-items: center;
    gap: 7px;
}
.pd-snapshot-title i { color: #2563EB; font-size: 1.1rem; }
.pd-snapshot-sub {
    font-size: 0.8rem;
    color: #64748B;
}
.pd-snapshot-body {
    padding: 20px 24px;
}
/* identity row */
.pd-snap-identity {
    display: flex;
    align-items: center;
    gap: 16px;
    margin-bottom: 16px;
    flex-wrap: wrap;
}
.pd-snap-avatar {
    width: 56px;
    height: 56px;
    border-radius: 50%;
    background: linear-gradient(135deg, #2563EB 0%, #60A5FA 100%);
    color: #fff;
    font-size: 1.3rem;
    font-weight: 800;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    box-shadow: 0 4px 12px rgba(37,99,235,0.20);
}
.pd-snap-name {
    flex: 1;
}
.pd-snap-name h3 {
    font-size: 1.1rem;
    font-weight: 700;
    color: #1E293B;
    margin: 0 0 2px;
}
.pd-snap-name .pd-snap-rel {
    font-size: 0.80rem;
    color: #64748B;
    display: flex;
    align-items: center;
    gap: 5px;
}
.pd-snap-name .pd-snap-rel i { color: #F59E0B; }
/* learning status badge */
.pd-snap-status {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    background: #ECFDF5;
    color: #065F46;
    border: 1px solid #A7F3D0;
    border-radius: 999px;
    padding: 4px 12px;
    font-size: 0.78rem;
    font-weight: 600;
}
/* divider */
.pd-snap-divider {
    height: 1px;
    background: #F1F5F9;
    margin: 14px 0;
}
/* activity rows */
.pd-snap-activity {
    display: flex;
    flex-direction: column;
    gap: 10px;
    margin-bottom: 18px;
}
.pd-snap-activity-row {
    display: flex;
    align-items: flex-start;
    gap: 12px;
    padding: 10px 14px;
    background: #F8FAFC;
    border-radius: 12px;
    border-left: 3px solid #DBEAFE;
}
.pd-snap-activity-row.quiz { border-left-color: #FEF3C7; }
.pd-snap-activity-icon {
    width: 34px;
    height: 34px;
    border-radius: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1rem;
    flex-shrink: 0;
}
.pd-snap-activity-icon.lesson { background: #DBEAFE; color: #1D4ED8; }
.pd-snap-activity-icon.quiz   { background: #FEF3C7; color: #D97706; }
.pd-snap-activity-body { flex: 1; }
.pd-snap-activity-label {
    font-size: 0.72rem;
    font-weight: 700;
    color: #94A3B8;
    text-transform: uppercase;
    letter-spacing: 0.8px;
    margin-bottom: 2px;
}
.pd-snap-activity-text {
    font-size: 0.88rem;
    font-weight: 600;
    color: #1E293B;
}
.pd-snap-activity-meta {
    font-size: 0.75rem;
    color: #64748B;
    margin-top: 2px;
}
.pd-snap-no-activity {
    text-align: center;
    padding: 18px 0 10px;
    color: #94A3B8;
    font-size: 0.85rem;
}
.pd-snap-no-activity i { font-size: 1.8rem; display: block; margin-bottom: 6px; color: #CBD5E1; }
/* quick action buttons */
.pd-snap-actions {
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
}
.pd-snap-btn {
    flex: 1;
    min-width: 100px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 6px;
    padding: 9px 14px;
    border-radius: 999px;
    font-size: 0.80rem;
    font-weight: 700;
    text-decoration: none;
    transition: transform 0.15s, box-shadow 0.15s;
    white-space: nowrap;
}
.pd-snap-btn:hover { transform: translateY(-2px); text-decoration: none; }
.pd-snap-btn.primary {
    background: #2563EB;
    color: #fff;
    box-shadow: 0 4px 12px rgba(37,99,235,0.25);
}
.pd-snap-btn.primary:hover { background: #1D4ED8; color: #fff; box-shadow: 0 6px 18px rgba(37,99,235,0.30); }
.pd-snap-btn.soft {
    background: #F1F5F9;
    color: #334155;
    box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}
.pd-snap-btn.soft:hover { background: #E2E8F0; color: #1E293B; }
.pd-summary-grid { display:grid; grid-template-columns:repeat(3, 1fr); gap:16px; margin-bottom:24px; }
@media(max-width:640px){ .pd-summary-grid{grid-template-columns:1fr;} }
.pd-summary-card {
    border-radius: 18px;
    padding: 22px 20px;
    text-align: center;
    transition: transform 0.2s, box-shadow 0.2s;
    box-shadow: 0 2px 12px rgba(0,0,0,0.04);
}
.pd-summary-card:hover { transform:translateY(-2px); box-shadow:0 6px 20px rgba(0,0,0,0.08); }
.pd-summary-card.progress-card { background: #EFF6FF; }
.pd-summary-card.quiz-card { background: #FEF9EE; }
.pd-summary-card.badge-card { background: #F3F0FF; }
.pd-summary-icon {
    width: 44px; height: 44px;
    border-radius: 12px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-size: 1.2rem;
    margin-bottom: 10px;
}
.pd-summary-card.progress-card .pd-summary-icon { background:#DBEAFE; color:#1D4ED8; }
.pd-summary-card.quiz-card .pd-summary-icon { background:#FDE68A; color:#B45309; }
.pd-summary-card.badge-card .pd-summary-icon { background:#E9D5FF; color:#7C3AED; }
.pd-summary-value { font-size:1.6rem; font-weight:800; color:#1E293B; display:block; margin-bottom:4px; }
.pd-summary-label { font-size:0.78rem; color:#64748B; font-weight:500; }
.pd-two-col { display:grid; grid-template-columns:1fr 1fr; gap:20px; margin-bottom:24px; }
@media(max-width:768px){ .pd-two-col{grid-template-columns:1fr;} }

/* ── Lower cards: Study Plan + Recent Activities ───────── */
.pd-lower-card {
    background: #fff;
    border-radius: 18px;
    box-shadow: 0 2px 16px rgba(0,0,0,0.05);
    display: flex;
    flex-direction: column;
    max-height: 420px;
    overflow: hidden;
}
.pd-lower-card-header {
    padding: 16px 20px 12px;
    border-bottom: 1px solid #F1F5F9;
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-shrink: 0;
}
.pd-lower-card-title {
    font-size: 0.95rem;
    font-weight: 700;
    color: #1E293B;
    display: flex;
    align-items: center;
    gap: 7px;
}
.pd-lower-card-title i { color: #2563EB; }
.pd-lower-card-body {
    flex: 1;
    overflow-y: auto;
    padding: 14px 20px 18px;
}
/* day nav arrows */
.pd-day-nav {
    display: flex;
    align-items: center;
    gap: 6px;
}
.pd-day-btn {
    border: none;
    background: #F1F5F9;
    border-radius: 8px;
    width: 28px; height: 28px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-size: 0.75rem;
    color: #475569;
    cursor: pointer;
    transition: background 0.15s;
}
.pd-day-btn:hover { background: #E2E8F0; }

/* ── Study Plan task rows ──────────────────────────────── */
.pd-sp-task-row {
    display: flex;
    align-items: flex-start;
    gap: 10px;
    padding: 10px 12px;
    margin-bottom: 6px;
    background: #F8FAFC;
    border-radius: 12px;
    border-left: 3px solid #DBEAFE;
    transition: background 0.15s;
}
.pd-sp-task-row:hover { background: #EFF6FF; }
.pd-sp-task-row.overdue { border-left-color: #FCA5A5; background: #FEF2F2; }
.pd-sp-task-icon {
    width: 28px; height: 28px;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 0.8rem;
    flex-shrink: 0;
    background: #DBEAFE;
    color: #1D4ED8;
}
.pd-sp-task-row.overdue .pd-sp-task-icon { background: #FEE2E2; color: #DC2626; }
.pd-sp-task-body { flex: 1; }
.pd-sp-task-title { font-size: 0.85rem; font-weight: 600; color: #1E293B; margin-bottom: 2px; }
.pd-sp-task-sub { font-size: 0.75rem; color: #64748B; }
.pd-sp-task-badge {
    font-size: 0.68rem;
    font-weight: 700;
    padding: 2px 8px;
    border-radius: 999px;
    white-space: nowrap;
}
.pd-sp-task-badge.overdue { background: #FEE2E2; color: #DC2626; }
.pd-sp-task-badge.pending { background: #FEF3C7; color: #92400E; }

/* ── Recent Activities timeline ────────────────────────── */
.pd-timeline-group { margin-bottom: 16px; }
.pd-timeline-date {
    font-size: 0.72rem;
    font-weight: 700;
    color: #94A3B8;
    text-transform: uppercase;
    letter-spacing: 0.8px;
    margin-bottom: 10px;
    margin-left: 28px;
}
.pd-timeline-item {
    display: flex;
    align-items: flex-start;
    padding: 10px 0 10px 28px;
    position: relative;
    border-bottom: 1px solid #F1F5F9;
}
.pd-timeline-item:last-child { border-bottom: none; }
/* vertical line on far left */
.pd-timeline-item::before {
    content: '';
    position: absolute;
    left: 9px;
    top: 0;
    bottom: 0;
    width: 2px;
    background: #E2E8F0;
}
.pd-timeline-group .pd-timeline-item:first-child::before { top: 14px; }
.pd-timeline-group .pd-timeline-item:last-child::before { bottom: 50%; }
/* dot on the line */
.pd-timeline-dot {
    position: absolute;
    left: 5px;
    top: 14px;
    width: 10px;
    height: 10px;
    border-radius: 50%;
    border: 2px solid #fff;
    box-shadow: 0 0 0 2px #E2E8F0;
    z-index: 1;
}
.pd-timeline-dot.lesson { background: #3B82F6; box-shadow: 0 0 0 2px #BFDBFE; }
.pd-timeline-dot.quiz   { background: #F59E0B; box-shadow: 0 0 0 2px #FDE68A; }
.pd-timeline-dot.badge  { background: #8B5CF6; box-shadow: 0 0 0 2px #DDD6FE; }
/* content area */
.pd-timeline-content {
    flex: 1;
    min-width: 0;
}
.pd-timeline-text {
    font-size: 0.84rem;
    font-weight: 500;
    color: #334155;
    line-height: 1.3;
}
.pd-timeline-time {
    font-size: 0.72rem;
    color: #94A3B8;
    white-space: nowrap;
    margin-left: 12px;
    flex-shrink: 0;
    padding-top: 1px;
}

/* ── Section title row (consistent black bold + icon) ──── */
.pd-section-title-row {
    font-size: 1.1rem;
    font-weight: 800;
    color: #1E293B;
    display: flex;
    align-items: center;
    gap: 8px;
}
.pd-section-title-row i { color: #2563EB; font-size: 1.15rem; }

/* ── Forum Section ─────────────────────────────────────── */
.pd-forum-section {
    background: #fff;
    border-radius: 20px;
    box-shadow: 0 2px 16px rgba(0,0,0,0.05);
    margin-bottom: 24px;
    overflow: hidden;
}
.pd-forum-header {
    background: linear-gradient(135deg, #2563EB 0%, #3B82F6 60%, #60A5FA 100%);
    padding: 22px 24px 18px;
    color: #fff;
    border-radius: 20px 20px 0 0;
    position: relative;
    overflow: hidden;
}
.pd-forum-header::after {
    content: '';
    position: absolute;
    width: 120px; height: 120px;
    border-radius: 50%;
    background: rgba(255,255,255,0.06);
    top: -40px; right: 20px;
    pointer-events: none;
}
.pd-forum-header .pd-section-title-row { color: #fff; }
.pd-forum-header .pd-section-title-row i { color: rgba(255,255,255,0.85); }
.pd-forum-sub { font-size: 0.82rem; opacity: 0.88; margin-top: 4px; }
/* tabs */
.pd-forum-tabs {
    display: flex;
    gap: 0;
    padding: 0 24px;
    border-bottom: 1px solid #E2E8F0;
    background: #F8FAFC;
}
.pd-forum-tab {
    padding: 10px 18px;
    font-size: 0.82rem;
    font-weight: 600;
    color: #64748B;
    border: none;
    background: none;
    border-bottom: 3px solid transparent;
    cursor: pointer;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    gap: 5px;
    transition: color 0.15s, border-color 0.15s;
}
.pd-forum-tab:hover { color: #2563EB; text-decoration: none; }
.pd-forum-tab.active { color: #2563EB; border-bottom-color: #2563EB; }
/* filters */
.pd-forum-filters {
    display: flex;
    gap: 8px;
    padding: 12px 24px;
    flex-wrap: wrap;
    align-items: center;
}
.pd-forum-filter-ddl {
    border: 1.5px solid #E2E8F0;
    border-radius: 8px;
    padding: 7px 12px;
    font-size: 0.8rem;
    color: #334155;
    background: #fff;
    min-width: 100px;
}
.pd-forum-filter-ddl:focus { border-color: #2563EB; outline: none; }
.pd-forum-filter-search {
    border: 1.5px solid #E2E8F0;
    border-radius: 8px;
    padding: 7px 12px;
    font-size: 0.8rem;
    color: #334155;
    min-width: 120px;
    flex: 1;
    max-width: 200px;
}
.pd-forum-filter-search:focus { border-color: #2563EB; outline: none; }
/* scrollable post list */
.pd-forum-list {
    max-height: 380px;
    overflow-y: auto;
    padding: 12px 24px;
}
/* forum post card */
.pd-forum-post {
    border: 1.5px solid #E2E8F0;
    border-radius: 14px;
    padding: 16px 18px;
    margin-bottom: 12px;
    background: #fff;
    transition: box-shadow 0.15s;
}
.pd-forum-post:hover { box-shadow: 0 4px 14px rgba(0,0,0,0.06); }
.pd-forum-post-header {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 8px;
}
.pd-forum-post-avatar {
    width: 34px; height: 34px;
    border-radius: 50%;
    background: #DBEAFE;
    color: #1D4ED8;
    font-size: 0.8rem;
    font-weight: 700;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
}
.pd-forum-post-info { flex: 1; }
.pd-forum-post-title { font-size: 0.92rem; font-weight: 700; color: #1E293B; margin: 0 0 2px; }
.pd-forum-post-meta { font-size: 0.72rem; color: #94A3B8; display: flex; align-items: center; gap: 6px; flex-wrap: wrap; }
.pd-forum-post-badge {
    font-size: 0.65rem;
    font-weight: 700;
    padding: 2px 8px;
    border-radius: 999px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}
.pd-forum-post-badge.public { background: #DCFCE7; color: #15803D; }
.pd-forum-post-badge.private { background: #FEE2E2; color: #991B1B; }
.pd-forum-post-preview { font-size: 0.82rem; color: #475569; margin: 6px 0 10px; line-height: 1.4; }
.pd-forum-post-tags { display: flex; gap: 5px; flex-wrap: wrap; margin-bottom: 10px; }
.pd-forum-post-tag {
    font-size: 0.68rem;
    font-weight: 600;
    background: #EFF6FF;
    color: #2563EB;
    border-radius: 999px;
    padding: 2px 9px;
}
.pd-forum-post-footer {
    display: flex;
    align-items: center;
    gap: 14px;
    font-size: 0.75rem;
    color: #64748B;
}
.pd-forum-post-footer i { font-size: 0.8rem; }
.pd-forum-post-footer .stat { display: inline-flex; align-items: center; gap: 3px; }
.pd-forum-open-btn {
    margin-left: auto;
    font-size: 0.75rem;
    font-weight: 700;
    color: #2563EB;
    border: 1.5px solid #DBEAFE;
    border-radius: 999px;
    padding: 4px 12px;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    gap: 4px;
    transition: background 0.15s;
}
.pd-forum-open-btn:hover { background: #EFF6FF; text-decoration: none; }
/* forum footer */
.pd-forum-footer {
    padding: 12px 24px 16px;
    text-align: center;
    border-top: 1px solid #F1F5F9;
}
.pd-forum-goto-btn {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    font-size: 0.85rem;
    font-weight: 700;
    color: #2563EB;
    text-decoration: none;
    padding: 8px 20px;
    border: 2px solid #DBEAFE;
    border-radius: 999px;
    transition: background 0.15s, border-color 0.15s;
}
.pd-forum-goto-btn:hover { background: #EFF6FF; border-color: #2563EB; text-decoration: none; }
.pd-actions-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(160px,1fr)); gap:14px; margin-bottom:24px; }
.pd-action-card { background:var(--parent-card-bg); border-radius:var(--parent-radius); padding:20px 16px; box-shadow:var(--parent-shadow); text-align:center; text-decoration:none; color:var(--parent-text); transition:transform 0.2s,box-shadow 0.2s; display:block; }
.pd-action-card:hover { transform:translateY(-3px); box-shadow:var(--parent-shadow-hover); text-decoration:none; color:var(--parent-primary); }
.pd-action-card i { font-size:1.5rem; color:var(--parent-primary); display:block; margin-bottom:8px; }
.pd-action-card span { font-size:0.82rem; font-weight:600; }
.pd-empty { text-align:center; padding:32px 20px; color:var(--parent-muted); }
.pd-empty i { font-size:2.5rem; color:#CBD5E1; display:block; margin-bottom:12px; }
.pd-empty p { margin:0; font-size:0.9rem; }
.pd-empty a { color:var(--parent-primary); font-weight:600; text-decoration:none; }
.pd-empty a:hover { text-decoration:underline; }
.pd-msg { border-radius:var(--parent-radius-sm); padding:12px 16px; margin-bottom:16px; font-size:0.9rem; }
.pd-msg.error { background:#FEE2E2; color:#991B1B; }
.pd-msg.info { background:#EFF6FF; color:#1E40AF; }
</style>
</asp:Content>

<%-- ════ SIDEBAR MENU ════ --%>
<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">

    <%-- Currently Viewing child name (populated from code-behind via litSidebarChild) --%>
    <div style="padding:10px 16px 6px; font-size:0.72rem; color:#94A3B8; text-transform:uppercase; letter-spacing:1px; font-weight:700;">
        <%: T("Currently viewing","Sedang melihat") %>
    </div>
    <div style="padding:0 16px 12px; font-size:0.85rem; color:#2563EB; font-weight:700; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">
        <i class="bi bi-person-fill" style="margin-right:5px;"></i><asp:Literal ID="litSidebarChild" runat="server" Text="—" />
    </div>

    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentDashboard.aspx") %>" class="sb-sidebar-item active">
            <i class="bi bi-speedometer2 item-icon"></i>
            <span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span>
        </a>
    </div>

    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("My Children","Anak Saya") %></div>
        <a href="<%: ResolveUrl("~/Parent/LinkChildAccount.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-link-45deg item-icon"></i>
            <span class="item-label"><%: T("Link Child Account","Paut Akaun Anak") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/ChildProfile.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-person-badge item-icon"></i>
            <span class="item-label"><%: T("Child Profile","Profil Anak") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/EnrolledModules.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-journal-bookmark item-icon"></i>
            <span class="item-label"><%: T("Enrolled Modules","Modul Didaftarkan") %></span>
        </a>
    </div>

    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Child Performance","Prestasi Anak") %></div>
        <a href="<%: ResolveUrl("~/Parent/ChildProgress.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-bar-chart-line item-icon"></i>
            <span class="item-label"><%: T("Current Progress","Kemajuan Semasa") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/QuizResults.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-patch-check item-icon"></i>
            <span class="item-label"><%: T("Quiz Results","Keputusan Kuiz") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/ReportCard.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-file-earmark-bar-graph item-icon"></i>
            <span class="item-label"><%: T("Report Card","Kad Laporan") %></span>
        </a>
    </div>

    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Study Plan","Pelan Pembelajaran") %></div>
        <a href="<%: ResolveUrl("~/Parent/StudyPlan.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-journal-check item-icon"></i>
            <span class="item-label"><%: T("Study Plan","Pelan Pembelajaran") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/EditStudyPlan.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-journal-pen item-icon"></i>
            <span class="item-label"><%: T("Edit Study Plan","Edit Pelan Pembelajaran") %></span>
        </a>
    </div>

    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Discussions","Perbincangan") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentTeacherCommunication.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-chat-dots item-icon"></i>
            <span class="item-label"><%: T("Chat with Teachers","Sembang dengan Guru") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/Forum.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-people item-icon"></i>
            <span class="item-label"><%: T("Forum","Forum") %></span>
        </a>
    </div>

    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Notifications","Notifikasi") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentNotifications.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-bell item-icon"></i>
            <span class="item-label"><%: T("Notifications","Notifikasi") %></span>
        </a>
    </div>

    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Profile","Profil") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentProfile.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-person item-icon"></i>
            <span class="item-label"><%: T("Edit Profile","Edit Profil") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/AccountSettings.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-gear item-icon"></i>
            <span class="item-label"><%: T("Account Settings","Tetapan Akaun") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-box-arrow-right item-icon"></i>
            <span class="item-label"><%: T("Logout","Log Keluar") %></span>
        </a>
    </div>

</asp:Content>

<%-- ════ PAGE TITLE ════ --%>
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Parent Dashboard","Papan Pemuka Ibu Bapa") %></asp:Content>

<%-- ════ MAIN CONTENT ════ --%>
<asp:Content ID="cBody" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="pd-page">

    <asp:Panel ID="pnlMessage" runat="server" Visible="false">
        <div class="pd-msg" id="divMessage" runat="server"></div>
    </asp:Panel>

    <%-- ── Redesigned Hero Card ── --%>
    <div class="pd-hero">
        <%-- decorative sparkles (CSS only) --%>
        <div class="pd-hero-spark1"></div>
        <div class="pd-hero-spark2"></div>
        <div class="pd-hero-spark3"></div>
        <div class="pd-hero-spark4"></div>

        <%-- eyebrow --%>
        <div class="pd-hero-eyebrow">
            <i class="bi bi-stars"></i>
            <asp:Literal ID="litHeroEyebrow" runat="server" />
        </div>

        <%-- main greeting --%>
        <div class="pd-hero-greeting">
            <asp:Literal ID="litHeroGreeting" runat="server" />
        </div>

        <%-- currently viewing subtitle (hidden when no child) --%>
        <asp:Panel ID="pnlHeroViewing" runat="server" Visible="false">
            <div class="pd-hero-viewing">
                <i class="bi bi-eye-fill"></i>
                <asp:Literal ID="litHeroViewing" runat="server" />
            </div>
            <%-- learning pills --%>
            <div class="pd-hero-pills">
                <span class="pd-hero-pill">
                    <i class="bi bi-mortarboard-fill"></i>
                    <asp:Literal ID="litHeroLevel" runat="server" />
                </span>
                <span class="pd-hero-pill xp">
                    <i class="bi bi-lightning-charge-fill"></i>
                    <asp:Literal ID="litHeroXP" runat="server" />
                </span>
                <asp:Panel ID="pnlHeroBadges" runat="server" Visible="false">
                    <span class="pd-hero-pill badge">
                        <i class="bi bi-award-fill"></i>
                        <asp:Literal ID="litHeroBadges" runat="server" />
                    </span>
                </asp:Panel>
            </div>
            <%-- action row: dropdown + link button side by side --%>
            <div class="pd-hero-ddl-label">
                <i class="bi bi-person-check-fill"></i>
                <asp:Literal ID="litHeroDdlLabel" runat="server" />
            </div>
            <div class="pd-hero-action-row">
                <asp:DropDownList ID="ddlHeroChildren" runat="server"
                    CssClass="pd-hero-ddl"
                    AutoPostBack="true"
                    OnSelectedIndexChanged="DdlHeroChildren_SelectedIndexChanged" />
                <a href="<%: ResolveUrl("~/Parent/LinkChildAccount.aspx") %>" class="pd-hero-link-btn">
                    <i class="bi bi-plus-circle-fill"></i>
                    <asp:Literal ID="litHeroLinkChild" runat="server" />
                </a>
            </div>
        </asp:Panel>

        <%-- no child state inside hero --%>
        <asp:Panel ID="pnlHeroNoChild" runat="server" Visible="false">
            <div class="pd-hero-nochild">
                <i class="bi bi-person-x-fill"></i>
                <asp:Literal ID="litHeroNoChild" runat="server" />
            </div>
            <%-- link button shown when no child linked --%>
            <a href="<%: ResolveUrl("~/Parent/LinkChildAccount.aspx") %>" class="pd-hero-link-btn" style="margin-top:10px;display:inline-flex;">
                <i class="bi bi-plus-circle-fill"></i>
                <asp:Literal ID="litHeroLinkChildNoChild" runat="server" />
            </a>
        </asp:Panel>
    </div>

    <asp:Panel ID="pnlNoChild" runat="server" Visible="false">
        <div class="pd-section-card">
            <div class="pd-empty">
                <i class="bi bi-people"></i>
                <p><asp:Literal ID="litNoChildMsg" runat="server" /></p>
                <br />
                <a href="LinkChildAccount.aspx"><asp:Literal ID="litLinkChildBtn" runat="server" /></a>
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlDashboard" runat="server" Visible="false">

        <%-- ── Child Snapshot Card ── --%>
        <div class="pd-snapshot">
            <div class="pd-snapshot-header">
                <div>
                    <div class="pd-snapshot-title">
                        <i class="bi bi-person-heart"></i>
                        <asp:Literal ID="litSnapshotTitle" runat="server" />
                    </div>
                    <div class="pd-snapshot-sub"><asp:Literal ID="litSnapshotSub" runat="server" /></div>
                </div>
            </div>
            <div class="pd-snapshot-body">

                <%-- identity row --%>
                <div class="pd-snap-identity">
                    <div class="pd-snap-avatar">
                        <asp:Literal ID="litSnapInitials" runat="server" />
                    </div>
                    <div class="pd-snap-name">
                        <h3><asp:Literal ID="litSnapName" runat="server" /></h3>
                        <div class="pd-snap-rel">
                            <i class="bi bi-heart-fill"></i>
                            <asp:Literal ID="litSnapRel" runat="server" />
                        </div>
                    </div>
                    <span class="pd-snap-status">
                        <i class="bi bi-book-fill"></i>
                        <asp:Literal ID="litSnapStatus" runat="server" />
                    </span>
                </div>

                <div class="pd-snap-divider"></div>

                <%-- recent activity --%>
                <asp:Panel ID="pnlSnapActivity" runat="server">
                    <div class="pd-snap-activity">
                        <%-- latest lesson row --%>
                        <asp:Panel ID="pnlSnapLesson" runat="server" Visible="false">
                            <div class="pd-snap-activity-row">
                                <div class="pd-snap-activity-icon lesson">
                                    <i class="bi bi-book-half"></i>
                                </div>
                                <div class="pd-snap-activity-body">
                                    <div class="pd-snap-activity-label">
                                        <asp:Literal ID="litSnapLessonLabel" runat="server" />
                                    </div>
                                    <div class="pd-snap-activity-text">
                                        <asp:Literal ID="litSnapLessonTitle" runat="server" />
                                    </div>
                                    <div class="pd-snap-activity-meta">
                                        <asp:Literal ID="litSnapLessonDate" runat="server" />
                                    </div>
                                </div>
                            </div>
                        </asp:Panel>
                        <%-- latest quiz row --%>
                        <asp:Panel ID="pnlSnapQuiz" runat="server" Visible="false">
                            <div class="pd-snap-activity-row quiz">
                                <div class="pd-snap-activity-icon quiz">
                                    <i class="bi bi-patch-question-fill"></i>
                                </div>
                                <div class="pd-snap-activity-body">
                                    <div class="pd-snap-activity-label">
                                        <asp:Literal ID="litSnapQuizLabel" runat="server" />
                                    </div>
                                    <div class="pd-snap-activity-text">
                                        <asp:Literal ID="litSnapQuizTitle" runat="server" />
                                    </div>
                                    <div class="pd-snap-activity-meta">
                                        <asp:Literal ID="litSnapQuizMeta" runat="server" />
                                    </div>
                                </div>
                            </div>
                        </asp:Panel>
                    </div>
                </asp:Panel>

                <%-- no activity empty state --%>
                <asp:Panel ID="pnlSnapNoActivity" runat="server" Visible="false">
                    <div class="pd-snap-no-activity">
                        <i class="bi bi-hourglass-split"></i>
                        <span><asp:Literal ID="litSnapNoActivity" runat="server" /></span>
                    </div>
                </asp:Panel>

                <div class="pd-snap-divider"></div>

                <%-- quick action buttons --%>
                <div class="pd-snap-actions">
                    <a href="<%: ResolveUrl("~/Parent/ChildProfile.aspx") %>" class="pd-snap-btn primary">
                        <i class="bi bi-person-badge"></i>
                        <asp:Literal ID="litSnapBtnProfile" runat="server" />
                    </a>
                    <a href="<%: ResolveUrl("~/Parent/ChildProgress.aspx") %>" class="pd-snap-btn soft">
                        <i class="bi bi-bar-chart-line"></i>
                        <asp:Literal ID="litSnapBtnProgress" runat="server" />
                    </a>
                    <a href="<%: ResolveUrl("~/Parent/ReportCard.aspx") %>" class="pd-snap-btn soft">
                        <i class="bi bi-file-earmark-bar-graph"></i>
                        <asp:Literal ID="litSnapBtnReport" runat="server" />
                    </a>
                </div>

            </div>
        </div>

        <%-- ── Summary Cards (3 pastel cards) ── --%>
        <div class="pd-summary-grid">
            <div class="pd-summary-card progress-card">
                <div class="pd-summary-icon"><i class="bi bi-bar-chart-fill"></i></div>
                <span class="pd-summary-value"><asp:Literal ID="litProgressValue" runat="server" /></span>
                <span class="pd-summary-label"><asp:Literal ID="litProgressLabel" runat="server" /></span>
            </div>
            <div class="pd-summary-card quiz-card">
                <div class="pd-summary-icon"><i class="bi bi-pencil-square"></i></div>
                <span class="pd-summary-value"><asp:Literal ID="litQuizScoreValue" runat="server" /></span>
                <span class="pd-summary-label"><asp:Literal ID="litQuizScoreLabel" runat="server" /></span>
            </div>
            <div class="pd-summary-card badge-card">
                <div class="pd-summary-icon"><i class="bi bi-award-fill"></i></div>
                <span class="pd-summary-value"><asp:Literal ID="litBadgeValue" runat="server" /></span>
                <span class="pd-summary-label"><asp:Literal ID="litBadgeLabel" runat="server" /></span>
            </div>
        </div>

        <%-- ── Two-column: Study Plan + Recent Activities ── --%>
        <div class="pd-two-col">

            <%-- LEFT: Study Plan --%>
            <div class="pd-lower-card">
                <div class="pd-lower-card-header">
                    <div class="pd-lower-card-title">
                        <i class="bi bi-journal-check"></i>
                        <asp:Literal ID="litStudyPlanTitle" runat="server" />
                    </div>
                </div>
                <div class="pd-lower-card-body">
                    <asp:Panel ID="pnlStudyPlanCard" runat="server" Visible="false">
                        <asp:Panel ID="pnlSPTaskList" runat="server"></asp:Panel>
                    </asp:Panel>
                    <asp:Panel ID="pnlNoStudyPlan" runat="server" Visible="false">
                        <div class="pd-empty">
                            <i class="bi bi-journal-x"></i>
                            <p><asp:Literal ID="litNoStudyPlanMsg" runat="server" /></p>
                        </div>
                    </asp:Panel>
                </div>
            </div>

            <%-- RIGHT: Recent Activities --%>
            <div class="pd-lower-card">
                <div class="pd-lower-card-header">
                    <div class="pd-lower-card-title">
                        <i class="bi bi-clock-history"></i>
                        <asp:Literal ID="litRecentActivitiesTitle" runat="server" />
                    </div>
                </div>
                <div class="pd-lower-card-body">
                    <asp:Panel ID="pnlRecentActivities" runat="server"></asp:Panel>
                    <asp:Panel ID="pnlNoActivities" runat="server" Visible="false">
                        <div class="pd-empty">
                            <i class="bi bi-hourglass-split"></i>
                            <p><asp:Literal ID="litNoActivitiesMsg" runat="server" /></p>
                        </div>
                    </asp:Panel>
                </div>
            </div>

        </div>

        <%-- ── Forum Preview Section ── --%>
        <div class="pd-forum-section">
            <div class="pd-forum-header">
                <div class="pd-section-title-row">
                    <i class="bi bi-chat-square-text-fill"></i>
                    <span><asp:Literal ID="litForumTitle" runat="server" /></span>
                </div>
                <div class="pd-forum-sub"><asp:Literal ID="litForumSub" runat="server" /></div>
            </div>

            <%-- Tabs --%>
            <div class="pd-forum-tabs">
                <asp:LinkButton ID="lnkTabPublic" runat="server" CssClass="pd-forum-tab active"
                    OnClick="ForumTabPublic_Click" CausesValidation="false">
                    <i class="bi bi-globe2"></i> <asp:Literal ID="litTabPublic" runat="server" />
                </asp:LinkButton>
                <asp:LinkButton ID="lnkTabPrivate" runat="server" CssClass="pd-forum-tab"
                    OnClick="ForumTabPrivate_Click" CausesValidation="false">
                    <i class="bi bi-people-fill"></i> <asp:Literal ID="litTabPrivate" runat="server" />
                </asp:LinkButton>
            </div>

            <%-- Filters row --%>
            <div class="pd-forum-filters">
                <asp:DropDownList ID="ddlForumTag" runat="server" CssClass="pd-forum-filter-ddl"
                    AutoPostBack="true" OnSelectedIndexChanged="ForumFilter_Changed" />
                <asp:DropDownList ID="ddlForumSort" runat="server" CssClass="pd-forum-filter-ddl"
                    AutoPostBack="true" OnSelectedIndexChanged="ForumFilter_Changed" />
                <asp:TextBox ID="txtForumSearch" runat="server" CssClass="pd-forum-filter-search"
                    placeholder="Search" AutoPostBack="true" OnTextChanged="ForumFilter_Changed" />
            </div>

            <%-- Scrollable post list --%>
            <div class="pd-forum-list">
                <asp:Panel ID="pnlForumPosts" runat="server"></asp:Panel>
                <asp:Panel ID="pnlNoForumPosts" runat="server" Visible="false">
                    <div class="pd-empty">
                        <i class="bi bi-chat-square-dots"></i>
                        <p><asp:Literal ID="litNoForumMsg" runat="server" /></p>
                    </div>
                </asp:Panel>
            </div>

            <%-- Go to Forum button --%>
            <div class="pd-forum-footer">
                <a href="<%: ResolveUrl("~/Parent/Forum.aspx") %>" class="pd-forum-goto-btn">
                    <i class="bi bi-arrow-right-circle"></i>
                    <asp:Literal ID="litGoToForum" runat="server" />
                </a>
            </div>
        </div>

    </asp:Panel>

</div>
</asp:Content>
