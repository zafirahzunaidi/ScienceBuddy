<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="manageMaterials.aspx.cs"
    Inherits="ScienceBuddy.Teacher.manageMaterials" MasterPageFile="~/Site.Master"
    Title="Manage Materials" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root {
    --tc-primary: #6C63FF; --tc-secondary: #8B5CF6; --tc-hover: #5A52E0;
    --tc-light-bg: #F5F3FF; --tc-card-bg: #FFFFFF; --tc-border: #E5E7EB;
    --tc-text: #374151; --tc-muted: #6B7280;
    --tc-info: #3B82F6; --tc-warning: #F59E0B; --tc-success: #10B981; --tc-error: #EF4444;
}

/* Upload button */
.mm-btn-upload {
    display: inline-flex; align-items: center; gap: 6px;
    background: #F97316; border: none; border-radius: 10px;
    padding: .6rem 1.25rem; font-weight: 700; font-size: .85rem;
    color: #fff; cursor: pointer; text-decoration: none;
    transition: background .2s, box-shadow .2s, transform .2s;
    box-shadow: 0 2px 8px rgba(249,115,22,.2);
}
.mm-btn-upload:hover { background: #EA580C; box-shadow: 0 4px 16px rgba(249,115,22,.3); transform: translateY(-1px); color: #fff; text-decoration: none; }
.mm-btn-upload-disabled {
    display: inline-flex; align-items: center; gap: 6px;
    background: #D1D5DB; border: none; border-radius: 10px;
    padding: .6rem 1.25rem; font-weight: 700; font-size: .85rem;
    color: #9CA3AF; cursor: not-allowed; text-decoration: none;
    box-shadow: none; pointer-events: none;
}

/* ─── Tabs (underline style) ─── */
.mm-tabs{display:flex;gap:0;border-bottom:2px solid var(--tc-border);margin-bottom:1.25rem;}
.mm-tab{display:inline-flex;align-items:center;gap:6px;padding:.75rem 1.3rem;font-size:.9rem;font-weight:700;cursor:pointer;border:none;border-radius:0;background:transparent;color:var(--tc-muted);transition:color .15s;text-decoration:none;position:relative;margin-bottom:-2px;border-bottom:2.5px solid transparent;}
.mm-tab:hover{color:var(--tc-primary);text-decoration:none;}
.mm-tab.active{color:var(--tc-primary);border-bottom-color:var(--tc-primary);}
.mm-tab.active:hover{color:var(--tc-primary);}

/* ─── Status chips ─── */
.mm-chips{display:flex;gap:6px;margin-bottom:1rem;flex-wrap:wrap;}
.mm-chip{display:inline-flex;align-items:center;padding:.4rem .9rem;border-radius:999px;font-size:.82rem;font-weight:600;cursor:pointer;border:1.5px solid var(--tc-border);background:var(--tc-card-bg);color:var(--tc-muted);transition:all .15s;text-decoration:none;}
.mm-chip:hover{background:#F3F4F6;text-decoration:none;}
.mm-chip.active{font-weight:700;}
/* Per-status chip colours */
.mm-chip[data-status="all"].active{background:#F3F4F6;color:#374151;border-color:#9CA3AF;}
.mm-chip[data-status="approved"].active{background:#D1FAE5;color:#047857;border-color:#6EE7B7;}
.mm-chip[data-status="pending"].active{background:#FEF3C7;color:#B45309;border-color:#FCD34D;}
.mm-chip[data-status="rejected"].active{background:#FEE2E2;color:#B91C1C;border-color:#FCA5A5;}

/* ─── Filter bar ─── */
.mm-filter-bar {
    display: flex; align-items: center; gap: 10px;
    margin-bottom: 1.25rem; flex-wrap: wrap;
}
.mm-search-wrap {
    position: relative; width: 320px; flex-shrink: 0;
}
.mm-search-wrap i {
    position: absolute; left: 12px; top: 50%; transform: translateY(-50%);
    font-size: .85rem; color: var(--tc-muted); pointer-events: none;
}
.mm-search-wrap input {
    width: 100%; height: 40px; padding: 0 .75rem 0 2.2rem;
    border-radius: 10px; border: 1.5px solid var(--tc-border);
    font-size: .83rem; background: var(--tc-card-bg);
    transition: border-color .2s, box-shadow .2s;
}
.mm-search-wrap input:focus { border-color: var(--tc-primary); box-shadow: 0 0 0 3px rgba(108,99,255,.1); outline: none; }
.mm-select {
    width: 155px; height: 40px; flex-shrink: 0;
    border-radius: 10px; border: 1.5px solid var(--tc-border);
    padding: 0 .65rem; font-size: .82rem;
    background: var(--tc-card-bg); color: var(--tc-text); cursor: pointer;
    transition: border-color .2s, box-shadow .2s;
    appearance: none; -webkit-appearance: none;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%236B7280' d='M2 4l4 4 4-4'/%3E%3C/svg%3E");
    background-repeat: no-repeat; background-position: right 10px center;
    padding-right: 28px;
}
.mm-select:focus { border-color: var(--tc-primary); box-shadow: 0 0 0 3px rgba(108,99,255,.1); outline: none; }
.mm-btn-search {
    width: 100px; height: 40px; flex-shrink: 0;
    background: var(--tc-primary); border: none; border-radius: 10px;
    font-weight: 700; font-size: .83rem; color: #fff; cursor: pointer;
    transition: background .2s;
}
.mm-btn-search:hover { background: var(--tc-hover); }

/* ─── Material cards ─── */
.mm-card {
    background: var(--tc-card-bg); border: 1.5px solid var(--tc-border);
    border-radius: 14px; padding: 1.5rem 1.6rem;
    margin-bottom: 1rem; box-shadow: 0 1px 3px rgba(0,0,0,.02);
    transition: box-shadow .25s, transform .25s;
}
.mm-card:hover { box-shadow: 0 6px 20px rgba(108,99,255,.09); transform: translateY(-1px); }
.mm-card-top { display: flex; align-items: flex-start; gap: 1.1rem; }
.mm-card-ico {
    width: 50px; height: 50px; border-radius: 14px;
    display: flex; align-items: center; justify-content: center;
    font-size: 1.3rem; flex-shrink: 0; box-shadow: 0 2px 6px rgba(0,0,0,.06);
}
.mm-ico-pdf{background:#FEE2E2;color:#DC2626;}.mm-ico-doc{background:#DBEAFE;color:#2563EB;}.mm-ico-ppt{background:#FFEDD5;color:#EA580C;}.mm-ico-image{background:#D1FAE5;color:#059669;}.mm-ico-video{background:#DBEAFE;color:#2563EB;}.mm-ico-default{background:#F3F4F6;color:#6B7280;}
.mm-card-info { flex: 1; min-width: 0; }
.mm-card-title { font-weight: 800; font-size: 1rem; color: var(--tc-text); margin-bottom: 4px; line-height: 1.3; }
.mm-card-desc { font-size: .86rem; color: var(--tc-muted); margin-bottom: 10px; line-height: 1.5; }
.mm-card-desc.collapsed { display: -webkit-box; -webkit-line-clamp: 3; line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden; }
.mm-view-more { font-size: .78rem; font-weight: 600; color: var(--tc-primary); cursor: pointer; display: inline-block; margin-bottom: 8px; }
.mm-view-more:hover { color: var(--tc-hover); text-decoration: underline; }
.mm-card-meta { display: flex; gap: .9rem; flex-wrap: wrap; font-size: .8rem; color: var(--tc-muted); }
.mm-card-meta span { display: inline-flex; align-items: center; gap: 4px; }
.mm-badge {
    display: inline-block; padding: 4px 12px; border-radius: 50px;
    font-size: .72rem; font-weight: 700; flex-shrink: 0; align-self: flex-start;
}
.mm-badge-pending { background: #FEF3C7; color: #B45309; }
.mm-badge-approved { background: #D1FAE5; color: #047857; }
.mm-badge-rejected { background: #FEE2E2; color: #B91C1C; }
.mm-card-actions {
    display: flex; gap: 8px; margin-top: 1rem; padding-top: .875rem;
    border-top: 1px solid #F0EDFF; flex-wrap: wrap; align-items: center;
}
.mm-action-btn {
    font-size: .82rem; font-weight: 600; text-decoration: none;
    padding: 7px 14px; border-radius: 8px; border: 1.5px solid;
    cursor: pointer; background: transparent;
    display: inline-flex; align-items: center; gap: 5px;
    transition: background .15s, box-shadow .15s; height: 34px;
}
.mm-action-btn:hover { box-shadow: 0 2px 8px rgba(0,0,0,.06); }
.mm-act-view { color: var(--tc-info); border-color: #DBEAFE; background: #F0F7FF; }
.mm-act-view:hover { background: #DBEAFE; }
.mm-act-download { color: var(--tc-success); border-color: #D1FAE5; background: #ECFDF5; }
.mm-act-download:hover { background: #D1FAE5; }
.mm-act-edit { color: var(--tc-primary); border-color: #EDE9FE; background: #F5F3FF; }
.mm-act-edit:hover { background: #EDE9FE; }
.mm-act-resubmit { color: #B45309; border-color: #FEF3C7; background: #FFFBEB; }
.mm-act-resubmit:hover { background: #FEF3C7; }
.mm-act-delete { color: var(--tc-error); border-color: #FEE2E2; background: #FEF2F2; }
.mm-act-delete:hover { background: #FEE2E2; }
.mm-empty { display: flex; flex-direction: column; align-items: center; padding: 3.5rem; text-align: center; color: var(--tc-muted); }

/* ─── Modal ─── */
.mm-modal-overlay { position: fixed; inset: 0; background: rgba(17,24,39,.5); z-index: 9000; display: flex; align-items: center; justify-content: center; padding: 1rem; }
.mm-modal { background: #fff; border-radius: 16px; width: 100%; max-width: 600px; box-shadow: 0 24px 64px rgba(0,0,0,.2); animation: mmFadeIn .2s ease; }
.mm-modal-sm { max-width: 420px; }
@keyframes mmFadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
.mm-modal-header { display: flex; align-items: flex-start; justify-content: space-between; padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--tc-border); }
.mm-modal-title { font-size: 1.1rem; font-weight: 800; color: var(--tc-text); margin: 0; }
.mm-modal-sub { font-size: .8rem; color: var(--tc-muted); margin-top: 2px; }
.mm-modal-close { background: none; border: none; font-size: 1.5rem; line-height: 1; color: var(--tc-muted); cursor: pointer; padding: 0 4px; transition: color .15s; }
.mm-modal-close:hover { color: var(--tc-text); }
.mm-modal-body { padding: 1.25rem 1.5rem; max-height: 60vh; overflow-y: auto; }
.mm-modal-footer { display: flex; gap: .75rem; justify-content: flex-end; padding: 1rem 1.5rem; border-top: 1px solid var(--tc-border); }
.mm-btn-primary { background: var(--tc-primary); border: none; border-radius: 10px; padding: .55rem 1.25rem; font-weight: 700; font-size: .84rem; color: #fff; cursor: pointer; transition: background .2s; }
.mm-btn-primary:hover { background: var(--tc-hover); }
.mm-btn-cancel { background: #fff; border: 1.5px solid var(--tc-border); border-radius: 10px; padding: .55rem 1.1rem; font-weight: 600; font-size: .84rem; color: var(--tc-text); cursor: pointer; transition: border-color .15s; }
.mm-btn-cancel:hover { border-color: var(--tc-muted); }

/* ─── Form ─── */
.mm-label { font-size: .79rem; font-weight: 600; color: var(--tc-text); display: block; margin-bottom: 4px; }
.mm-input { width: 100%; border-radius: 10px; border: 1.5px solid var(--tc-border); padding: .55rem .75rem; font-size: .84rem; transition: border-color .2s, box-shadow .2s; }
.mm-input:focus { border-color: var(--tc-primary); box-shadow: 0 0 0 3px rgba(108,99,255,.08); outline: none; }
.mm-form-grid2 { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 1rem; }
.mm-form-grid3 { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 1rem; margin-bottom: 1rem; }

/* ─── Toast ─── */
.mm-toast-container { position: fixed; top: 1.25rem; right: 1.25rem; z-index: 9999; display: flex; flex-direction: column; gap: .5rem; }
.mm-toast { background: var(--tc-primary); color: #fff; padding: .75rem 1.25rem; border-radius: 10px; font-size: .84rem; font-weight: 600; display: flex; align-items: center; gap: 8px; box-shadow: 0 8px 24px rgba(108,99,255,.3); animation: mmSlideIn .3s ease; }
.mm-toast-out { animation: mmSlideOut .4s ease forwards; }
@keyframes mmSlideIn { from { opacity: 0; transform: translateX(30px); } to { opacity: 1; transform: translateX(0); } }
@keyframes mmSlideOut { from { opacity: 1; transform: translateX(0); } to { opacity: 0; transform: translateX(30px); } }

/* ─── Responsive ─── */
@media (max-width: 1100px) {
    .mm-filter-bar { flex-wrap: wrap; }
    .mm-search-wrap { width: 100%; }
    .mm-select { flex: 1; min-width: 130px; width: auto; }
}
@media (max-width: 767px) {
    .mm-filter-bar { flex-direction: column; align-items: stretch; }
    .mm-select { width: 100%; }
    .mm-btn-search { width: 100%; }
    .mm-card { padding: 1rem 1.1rem; }
    .mm-card-top { flex-wrap: wrap; }
    .mm-form-grid2, .mm-form-grid3 { grid-template-columns: 1fr; }
    .mm-modal { max-width: 95vw; }
}
</style>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Teaching","Pengajaran") %></div>
        <a href="<%: ResolveUrl("~/Teacher/manageMaterials.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-book item-icon"></i><span class="item-label"><%: T("Manage Materials","Bahan Pembelajaran") %></span></a>
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

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Manage Materials","Urus Bahan") %></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- Status panels --%>
<asp:Panel ID="pnlDenied" runat="server" Visible="false">
    <div style="display:flex;flex-direction:column;align-items:center;padding:3rem;text-align:center;">
        <div style="font-size:3rem;margin-bottom:1rem;">🚫</div>
        <h2 style="color:var(--tc-text);font-weight:800;">Access Denied</h2>
        <p style="color:var(--tc-muted);max-width:450px;">Your account cannot access this page. Please contact support.</p>
    </div>
</asp:Panel>

<asp:Panel ID="pnlMain" runat="server" Visible="false">

<%-- Page header with upload button on right --%>
<div style="display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:1rem;flex-wrap:wrap;gap:.75rem;">
    <div>
        <h1 style="font-size:1.5rem;font-weight:800;color:var(--tc-text);margin:0;"><%: T("Manage Materials","Urus Bahan") %></h1>
        <p style="font-size:.85rem;color:var(--tc-muted);margin:.3rem 0 0;"><%: T("Upload, manage, and discover learning materials.","Muat naik, urus, dan terokai bahan pembelajaran.") %></p>
    </div>
    <asp:Panel ID="pnlUploadBtn" runat="server">
        <%-- Shown when Certified --%>
        <asp:Panel ID="pnlUploadEnabled" runat="server">
            <a href="<%: ResolveUrl("~/Teacher/uploadMaterial.aspx") %>" class="mm-btn-upload"><i class="bi bi-plus-lg"></i> <%: T("Upload Material","Muat Naik Bahan") %></a>
        </asp:Panel>
        <%-- Shown when Pending --%>
        <asp:Panel ID="pnlUploadDisabled" runat="server" Visible="false">
            <button type="button" class="mm-btn-upload-disabled" disabled
                title="<%: T("Your teaching certificate is pending verification.","Sijil pengajaran anda sedang dalam semakan.") %>">
                <i class="bi bi-plus-lg"></i> <%: T("Upload Material","Muat Naik Bahan") %>
            </button>
        </asp:Panel>
    </asp:Panel></div>

<%-- Tabs --%>
<div class="mm-tabs">
    <asp:LinkButton ID="btnTabMine" runat="server" CssClass="mm-tab active" OnClick="btnTabMine_Click" CausesValidation="false"><i class="bi bi-folder2-open"></i> <%: T("My Materials","Bahan Saya") %></asp:LinkButton>
    <asp:LinkButton ID="btnTabDiscover" runat="server" CssClass="mm-tab" OnClick="btnTabDiscover_Click" CausesValidation="false"><i class="bi bi-globe2"></i> <%: T("Discover Materials","Terokai Bahan") %></asp:LinkButton>
</div>

<%-- Search & Filter — hidden for pending teachers and on Discover tab --%>
<asp:Panel ID="pnlFilterBar" runat="server">
<div class="mm-filter-bar">
    <div class="mm-search-wrap">
        <i class="bi bi-search"></i>
        <asp:TextBox ID="txtSearch" runat="server" />
    </div>
    <asp:DropDownList ID="ddlFilterLevel" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterLevel_Changed" CssClass="mm-select" />
    <asp:DropDownList ID="ddlFilterUnit" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterUnit_Changed" CssClass="mm-select" />
    <asp:DropDownList ID="ddlFilterType" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterType_Changed" CssClass="mm-select" />
    <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="btnSearch_Click" CausesValidation="false" CssClass="mm-btn-search" />
</div>
</asp:Panel>

<%-- Status chips (My Materials only) --%>
<asp:Panel ID="pnlStatusChips" runat="server">
<div class="mm-chips">
    <asp:LinkButton ID="btnChipAll" runat="server" CssClass="mm-chip active" OnClick="btnChip_Click" CommandArgument="" CausesValidation="false" data-status="all"><%: T("All","Semua") %></asp:LinkButton>
    <asp:LinkButton ID="btnChipApproved" runat="server" CssClass="mm-chip" OnClick="btnChip_Click" CommandArgument="Approved" CausesValidation="false" data-status="approved"><%: T("Approved","Diluluskan") %></asp:LinkButton>
    <asp:LinkButton ID="btnChipPending" runat="server" CssClass="mm-chip" OnClick="btnChip_Click" CommandArgument="Pending" CausesValidation="false" data-status="pending"><%: T("Pending","Menunggu") %></asp:LinkButton>
    <asp:LinkButton ID="btnChipRejected" runat="server" CssClass="mm-chip" OnClick="btnChip_Click" CommandArgument="Rejected" CausesValidation="false" data-status="rejected"><%: T("Rejected","Ditolak") %></asp:LinkButton>
</div>
</asp:Panel>
<asp:DropDownList ID="ddlFilterStatus" runat="server" Visible="false" />

<%-- Pending verification state (My Materials tab only) --%>
<asp:Panel ID="pnlMyMaterialsPending" runat="server" Visible="false">
    <div style="display:flex;flex-direction:column;align-items:center;padding:3.5rem 2rem;text-align:center;">
        <div style="font-size:3.5rem;margin-bottom:1rem;opacity:.85;">⏳</div>
        <h2 style="font-size:1.15rem;font-weight:800;color:var(--tc-text);margin:0 0 .6rem;"><%: T("Verification Pending","Pengesahan Sedang Diproses") %></h2>
        <p style="font-size:.88rem;color:var(--tc-muted);max-width:480px;line-height:1.65;margin:0;"><%: T("Your teaching certificate is under review. You'll be able to upload and manage learning materials once your verification is approved.","Sijil pengajaran anda sedang dalam semakan. Anda boleh memuat naik dan mengurus bahan pembelajaran setelah pengesahan anda diluluskan.") %></p>
    </div>
</asp:Panel>

<%-- Materials list --%>
<asp:Panel ID="pnlMaterials" runat="server" Visible="false">
    <asp:Repeater ID="rptMaterials" runat="server" OnItemCommand="rptMaterials_ItemCommand">
        <ItemTemplate>
            <div class="mm-card">
                <div class="mm-card-top">
                    <div class='mm-card-ico <%# GetIconCss(Eval("materialType").ToString()) %>'><i class='bi <%# GetFileIcon(Eval("materialType").ToString()) %>'></i></div>
                    <div class="mm-card-info">
                        <div class="mm-card-title"><%# HttpUtility.HtmlEncode(Eval("materialTitle")) %></div>
                        <div class='mm-card-desc<%# (Eval("materialContent")?.ToString() ?? "").Length > 120 ? " collapsed" : "" %>'><%# HttpUtility.HtmlEncode(Eval("materialContent")?.ToString() ?? "") %></div>
                        <%# (Eval("materialContent")?.ToString() ?? "").Length > 120 ? "<span class='mm-view-more' onclick='toggleDesc(this)'>View More</span>" : "" %>
                        <div class="mm-card-meta">
                            <span><i class="bi bi-folder2"></i> <%# HttpUtility.HtmlEncode(Eval("subtopicName")) %></span>
                            <span><i class="bi bi-file-earmark"></i> <%# HttpUtility.HtmlEncode(Eval("materialType")) %></span>
                            <span><i class="bi bi-calendar3"></i> <%# Eval("createdDate", "{0:d MMM yyyy}") %></span>
                            <span><i class="bi bi-translate"></i> <%# HttpUtility.HtmlEncode(Eval("language")) %></span>
                        </div>
                    </div>
                    <span class='mm-badge <%# GetStatusCss(Eval("status").ToString()) %>'><%# HttpUtility.HtmlEncode(Eval("status")) %></span>
                </div>
                <div class="mm-card-actions">
                    <asp:LinkButton ID="lnkView" runat="server" CommandName="ViewMaterial" CommandArgument='<%# Eval("fileUrl") %>' CssClass="mm-action-btn mm-act-view" CausesValidation="false"><i class="bi bi-eye"></i> View</asp:LinkButton>
                    <asp:LinkButton ID="lnkDownload" runat="server" CommandName="DownloadMaterial" CommandArgument='<%# Eval("fileUrl") %>' CssClass="mm-action-btn mm-act-download" CausesValidation="false"><i class="bi bi-download"></i> Download</asp:LinkButton>
                    <%# Eval("status").ToString() == "Rejected" ?
                        "<button type='button' class='mm-action-btn mm-act-resubmit' onclick=\"openEditModal('" + Eval("materialId") + "')\"><i class='bi bi-arrow-counterclockwise'></i> Resubmit</button>" :
                        "<button type='button' class='mm-action-btn mm-act-edit' onclick=\"openEditModal('" + Eval("materialId") + "')\"><i class='bi bi-pencil'></i> Edit</button>" %>
                    <button type="button" class="mm-action-btn mm-act-delete" onclick="openDeleteModal('<%# Eval("materialId") %>','<%# HttpUtility.JavaScriptStringEncode(Eval("materialTitle").ToString()) %>')"><i class="bi bi-trash"></i> Delete</button>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</asp:Panel>

<%-- Empty state (My Materials) --%>
<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="mm-empty">
        <div style="font-size:3rem;opacity:.5;margin-bottom:.75rem;">📂</div>
        <div style="font-size:1rem;font-weight:700;color:var(--tc-text);margin-bottom:.25rem;"><%: T("You haven't uploaded any learning materials yet.","Anda belum memuat naik sebarang bahan pembelajaran.") %></div>
        <div style="font-size:.85rem;margin-bottom:1rem;"><%: T("Click \"Upload Material\" to add your first learning resource.","Klik \"Muat Naik Bahan\" untuk menambah sumber pembelajaran pertama anda.") %></div>
        <a href="<%: ResolveUrl("~/Teacher/uploadMaterial.aspx") %>" class="mm-btn-upload"><i class="bi bi-plus-lg"></i> <%: T("Upload Material","Muat Naik Bahan") %></a>
    </div>
</asp:Panel>

<%-- ═══ DISCOVER MATERIALS ═══ --%>
<asp:Panel ID="pnlDiscover" runat="server" Visible="false">
    <asp:Repeater ID="rptDiscover" runat="server" OnItemCommand="rptDiscover_ItemCommand">
        <ItemTemplate>
            <div class="mm-card">
                <div class="mm-card-top">
                    <div class='mm-card-ico <%# GetIconCss(Eval("materialType").ToString()) %>'><i class='bi <%# GetFileIcon(Eval("materialType").ToString()) %>'></i></div>
                    <div class="mm-card-info">
                        <div class="mm-card-title"><%# HttpUtility.HtmlEncode(Eval("materialTitle")) %></div>
                        <div style="font-size:.78rem;color:var(--tc-primary);font-weight:600;margin-bottom:4px;"><%: T("By","Oleh") %> <%# HttpUtility.HtmlEncode(Eval("teacherName")) %></div>
                        <div class='mm-card-desc<%# (Eval("materialContent")?.ToString() ?? "").Length > 120 ? " collapsed" : "" %>'><%# HttpUtility.HtmlEncode(Eval("materialContent")?.ToString() ?? "") %></div>
                        <%# (Eval("materialContent")?.ToString() ?? "").Length > 120 ? "<span class='mm-view-more' onclick='toggleDesc(this)'>View More</span>" : "" %>
                        <div class="mm-card-meta">
                            <span><i class="bi bi-folder2"></i> <%# HttpUtility.HtmlEncode(Eval("subtopicName")) %></span>
                            <span><i class="bi bi-file-earmark"></i> <%# HttpUtility.HtmlEncode(Eval("materialType")) %></span>
                            <span><i class="bi bi-calendar3"></i> <%# Eval("createdDate", "{0:d MMM yyyy}") %></span>
                            <span><i class="bi bi-translate"></i> <%# HttpUtility.HtmlEncode(Eval("language")) %></span>
                        </div>
                    </div>
                </div>
                <div class="mm-card-actions">
                    <asp:LinkButton ID="lnkViewD" runat="server" CommandName="ViewMaterial" CommandArgument='<%# Eval("fileUrl") %>' CssClass="mm-action-btn mm-act-view" CausesValidation="false"><i class="bi bi-eye"></i> <%: T("View","Lihat") %></asp:LinkButton>
                    <asp:LinkButton ID="lnkDownloadD" runat="server" CommandName="DownloadMaterial" CommandArgument='<%# Eval("fileUrl") %>' CssClass="mm-action-btn mm-act-download" CausesValidation="false"><i class="bi bi-download"></i> <%: T("Download","Muat Turun") %></asp:LinkButton>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</asp:Panel>

<%-- Empty state (Discover) --%>
<asp:Panel ID="pnlDiscoverEmpty" runat="server" Visible="false">
    <div class="mm-empty">
        <div style="font-size:3rem;opacity:.5;margin-bottom:.75rem;">🔍</div>
        <div style="font-size:1rem;font-weight:700;color:var(--tc-text);margin-bottom:.25rem;"><%: T("No shared materials are available at the moment.","Tiada bahan kongsi tersedia buat masa ini.") %></div>
        <div style="font-size:.85rem;"><%: T("Check back later for materials shared by other teachers.","Semak kemudian untuk bahan yang dikongsi oleh guru lain.") %></div>
    </div>
</asp:Panel>

<%-- ═══ EDIT MODAL ═══ --%>
<div id="editModal" class="mm-modal-overlay" style="display:none;">
    <div class="mm-modal">
        <div class="mm-modal-header">
            <div>
                <h3 class="mm-modal-title"><asp:Literal ID="litFormTitle" runat="server" Text="Edit Material" /></h3>
                <p class="mm-modal-sub">Update your learning material information.</p>
            </div>
            <button type="button" class="mm-modal-close" onclick="closeEditModal()">×</button>
        </div>
        <div class="mm-modal-body">
            <asp:HiddenField ID="hidMaterialId" runat="server" Value="" />
            <div class="mm-form-grid2">
                <div>
                    <label class="mm-label">Title *</label>
                    <asp:TextBox ID="txtTitle" runat="server" MaxLength="150" CssClass="mm-input" />
                </div>
                <div>
                    <label class="mm-label">Language *</label>
                    <asp:DropDownList ID="ddlLanguage" runat="server" CssClass="mm-input">
                        <asp:ListItem Value="EN" Text="English" />
                        <asp:ListItem Value="BM" Text="Bahasa Melayu" />
                        <asp:ListItem Value="BOTH" Text="Both" />
                    </asp:DropDownList>
                </div>
            </div>
            <div style="margin-bottom:1rem;">
                <label class="mm-label">Description</label>
                <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="3" CssClass="mm-input" style="resize:vertical;" />
            </div>
            <div class="mm-form-grid3">
                <div>
                    <label class="mm-label">Level</label>
                    <asp:DropDownList ID="ddlLevel" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlLevel_Changed" CssClass="mm-input" />
                </div>
                <div>
                    <label class="mm-label">Unit</label>
                    <asp:DropDownList ID="ddlUnit" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlUnit_Changed" CssClass="mm-input" />
                </div>
                <div>
                    <label class="mm-label">Subtopic *</label>
                    <asp:DropDownList ID="ddlSubtopic" runat="server" CssClass="mm-input" />
                </div>
            </div>
            <div style="margin-bottom:.5rem;">
                <label class="mm-label">Replace File (optional)</label>
                <asp:FileUpload ID="fuFile" runat="server" CssClass="mm-input" style="padding:.4rem .6rem;background:#FAFAFA;" />
                <div style="font-size:.72rem;color:var(--tc-muted);margin-top:3px;">PDF, DOC, DOCX, PPT, PPTX, JPG, JPEG, PNG (max 10 MB)</div>
                <asp:Panel ID="pnlCurrentFile" runat="server" Visible="false">
                    <div style="font-size:.78rem;color:var(--tc-info);margin-top:4px;"><i class="bi bi-paperclip"></i> Current: <asp:Literal ID="litCurrentFile" runat="server" /></div>
                </asp:Panel>
            </div>
        </div>
        <div class="mm-modal-footer">
            <button type="button" class="mm-btn-cancel" onclick="closeEditModal()"><%: T("Cancel","Batal") %></button>
            <button type="button" class="mm-btn-primary" onclick="openSaveConfirm()">
                <asp:Literal ID="litSaveBtnText" runat="server" Text="Save Material" /></button>
        </div>
    </div>
</div>

<%-- ═══ SAVE CONFIRMATION MODAL ═══ --%>
<div id="saveConfirmModal" class="mm-modal-overlay" style="display:none;">
    <div class="mm-modal mm-modal-sm">
        <div class="mm-modal-header">
            <h3 class="mm-modal-title"><%: T("Confirm Changes","Sahkan Perubahan") %></h3>
            <button type="button" class="mm-modal-close" onclick="closeSaveConfirm()">×</button>
        </div>
        <div class="mm-modal-body" style="text-align:center;padding:1.5rem;">
            <p style="font-size:.9rem;color:var(--tc-text);"><%: T("Are you sure you want to save these changes?","Adakah anda pasti mahu menyimpan perubahan ini?") %></p>
        </div>
        <div class="mm-modal-footer" style="justify-content:center;">
            <button type="button" class="mm-btn-cancel" onclick="closeSaveConfirm()"><%: T("Cancel","Batal") %></button>
            <asp:Button ID="btnSave" runat="server" Text="Save" OnClick="btnSave_Click" CausesValidation="false" CssClass="mm-btn-primary" />
        </div>
    </div>
</div>

<%-- ═══ DELETE CONFIRMATION MODAL ═══ --%>
<div id="deleteConfirmModal" class="mm-modal-overlay" style="display:none;">
    <div class="mm-modal mm-modal-sm" style="border-radius:16px;overflow:hidden;box-shadow:0 20px 60px rgba(0,0,0,.18);">
        <div style="background:#FEF2F2;padding:1.1rem 1.5rem;display:flex;align-items:center;justify-content:space-between;border-bottom:1px solid #FECACA;">
            <h3 style="margin:0;font-size:1rem;font-weight:800;color:#991B1B;display:flex;align-items:center;gap:7px;">
                <i class="bi bi-trash3" style="font-size:1rem;"></i> <%: T("Confirm Deletion","Sahkan Pemadaman") %>
            </h3>
            <button type="button" class="mm-modal-close" onclick="closeDeleteModal()">&#215;</button>
        </div>
        <div style="padding:1.4rem 1.5rem;text-align:left;">
            <p style="font-size:.92rem;color:var(--tc-text);margin:0;line-height:1.6;">
                <%: T("Are you sure you want to delete","Adakah anda pasti mahu memadam") %>
                <br/><strong id="delMaterialTitle" style="color:var(--tc-text);"></strong>?
            </p>
        </div>
        <div style="display:flex;justify-content:flex-end;gap:.6rem;padding:1rem 1.5rem;border-top:1px solid var(--tc-border);">
            <button type="button" class="mm-btn-cancel" onclick="closeDeleteModal()" style="border-radius:10px;"><%: T("Cancel","Batal") %></button>
            <asp:Button ID="btnConfirmDelete" runat="server" Text="Delete" OnClick="btnConfirmDelete_Click" CausesValidation="false"
                CssClass="mm-btn-primary" style="background:#DC2626;border-radius:10px;" />
        </div>
    </div>
</div>

<asp:HiddenField ID="hidDeleteId" runat="server" Value="" />
<asp:HiddenField ID="hidShowEditModal" runat="server" Value="" />
<asp:HiddenField ID="hidToast" runat="server" Value="" />
<asp:HiddenField ID="hidActiveTab" runat="server" Value="mine" />

<%-- Toast container --%>
<div id="mmToastContainer" class="mm-toast-container"></div>

</asp:Panel><%-- /pnlMain --%>
</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
function toggleDesc(el) {
    var desc = el.previousElementSibling;
    if (desc.classList.contains('collapsed')) {
        desc.classList.remove('collapsed');
        el.textContent = 'View Less';
    } else {
        desc.classList.add('collapsed');
        el.textContent = 'View More';
    }
}
function openEditModal(id) {
    document.getElementById('<%=hidMaterialId.ClientID%>').value = id;
    __doPostBack('LoadEdit', id);
}
function closeEditModal() { document.getElementById('editModal').style.display = 'none'; }
function showEditModal() { document.getElementById('editModal').style.display = 'flex'; }
function openSaveConfirm() { document.getElementById('saveConfirmModal').style.display = 'flex'; }
function closeSaveConfirm() { document.getElementById('saveConfirmModal').style.display = 'none'; }
function openDeleteModal(id, title) {
    document.getElementById('<%=hidDeleteId.ClientID%>').value = id;
    document.getElementById('delMaterialTitle').textContent = '"' + (title || 'this material') + '"';
    document.getElementById('deleteConfirmModal').style.display = 'flex';
}
function closeDeleteModal() { document.getElementById('deleteConfirmModal').style.display = 'none'; }
function showToast(msg) {
    var c = document.getElementById('mmToastContainer');
    var t = document.createElement('div');
    t.className = 'mm-toast';
    t.innerHTML = '<i class="bi bi-check-circle-fill"></i> ' + msg;
    c.appendChild(t);
    setTimeout(function() { t.classList.add('mm-toast-out'); }, 3500);
    setTimeout(function() { t.remove(); }, 4000);
}
window.addEventListener('load', function() {
    var h = document.getElementById('<%=hidShowEditModal.ClientID%>');
    if (h && h.value === '1') { showEditModal(); h.value = ''; }
    var toast = document.getElementById('<%=hidToast.ClientID%>');
    if (toast && toast.value) { showToast(toast.value); toast.value = ''; }
});
</script>
</asp:Content>
