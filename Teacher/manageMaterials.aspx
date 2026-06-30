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
    background: var(--tc-primary); border: none; border-radius: 10px;
    padding: .6rem 1.25rem; font-weight: 700; font-size: .85rem;
    color: #fff; cursor: pointer; text-decoration: none;
    transition: background .2s, box-shadow .2s;
    box-shadow: 0 2px 8px rgba(108,99,255,.15);
}
.mm-btn-upload:hover { background: var(--tc-hover); box-shadow: 0 4px 16px rgba(108,99,255,.25); color: #fff; text-decoration: none; }

/* ─── Filter bar ─── */
.mm-filter-bar {
    display: flex; align-items: center; gap: 10px;
    margin-bottom: 1.75rem; flex-wrap: nowrap;
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
    border-radius: 14px; padding: 1.35rem 1.5rem;
    margin-bottom: 1rem; box-shadow: 0 1px 3px rgba(0,0,0,.02);
    transition: box-shadow .25s, transform .25s;
}
.mm-card:hover { box-shadow: 0 6px 20px rgba(108,99,255,.09); transform: translateY(-1px); }
.mm-card-top { display: flex; align-items: flex-start; gap: 1rem; }
.mm-card-ico {
    width: 46px; height: 46px; border-radius: 12px;
    background: #EDE9FE; color: #6C63FF;
    display: flex; align-items: center; justify-content: center;
    font-size: 1.25rem; flex-shrink: 0;
}
.mm-card-info { flex: 1; min-width: 0; }
.mm-card-title { font-weight: 700; font-size: .95rem; color: var(--tc-text); margin-bottom: 3px; line-height: 1.3; }
.mm-card-desc { font-size: .82rem; color: var(--tc-muted); margin-bottom: 8px; line-height: 1.45; }
.mm-card-meta { display: flex; gap: .85rem; flex-wrap: wrap; font-size: .75rem; color: var(--tc-muted); }
.mm-card-meta span { display: inline-flex; align-items: center; gap: 3px; }
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
    font-size: .78rem; font-weight: 600; text-decoration: none;
    padding: 6px 12px; border-radius: 8px; border: 1.5px solid;
    cursor: pointer; background: transparent;
    display: inline-flex; align-items: center; gap: 5px;
    transition: background .15s, box-shadow .15s; height: 32px;
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
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Main</div>
        <a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Teaching","Pengajaran") %></div>
        <a href="<%: ResolveUrl("~/Teacher/manageMaterials.aspx") %>" class="sb-sidebar-item active">
            <i class="bi bi-book item-icon"></i><span class="item-label"><%: T("Manage Materials","Urus Bahan Pembelajaran") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label"><%: T("Manage Quiz","Urus Kuiz") %></span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-bar-chart item-icon"></i><span class="item-label"><%: T("Student Progress","Kemajuan Pelajar") %></span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label"><%: T("Schedule Live Class","Jadual Kelas Langsung") %></span></a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Community","Komuniti") %></div>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/privateMessages.aspx") %>" class="sb-sidebar-item"><i class="bi bi-envelope item-icon"></i><span class="item-label"><%: T("Private Message","Mesej Peribadi") %></span></a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Account","Akaun") %></div>
        <a href="<%: ResolveUrl("~/Teacher/MyProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("My Profile","Profil Saya") %></span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Sign Out","Log Keluar") %></span></a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Manage Materials","Urus Bahan") %></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- Status panels --%>
<asp:Panel ID="pnlPending" runat="server" Visible="false">
    <div style="display:flex;flex-direction:column;align-items:center;padding:3rem;text-align:center;">
        <div style="font-size:3rem;margin-bottom:1rem;">⏳</div>
        <h2 style="color:var(--tc-text);font-weight:800;">Verification Pending</h2>
        <p style="color:var(--tc-muted);max-width:450px;">Your certificate is under review. You will gain access once approved.</p>
    </div>
</asp:Panel>
<asp:Panel ID="pnlDenied" runat="server" Visible="false">
    <div style="display:flex;flex-direction:column;align-items:center;padding:3rem;text-align:center;">
        <div style="font-size:3rem;margin-bottom:1rem;">🚫</div>
        <h2 style="color:var(--tc-text);font-weight:800;">Access Denied</h2>
        <p style="color:var(--tc-muted);max-width:450px;">Your account cannot access this page. Please contact support.</p>
    </div>
</asp:Panel>

<asp:Panel ID="pnlMain" runat="server" Visible="false">

<%-- Page header --%>
<div style="margin-bottom:1.25rem;">
    <h1 style="font-size:1.5rem;font-weight:800;color:var(--tc-text);margin:0;"><%: T("My Materials","Bahan Saya") %></h1>
    <p style="font-size:.85rem;color:var(--tc-muted);margin:.3rem 0 0;"><%: T("Upload and manage learning materials for students.","Muat naik dan urus bahan pembelajaran untuk pelajar.") %></p>
</div>
<div style="margin-bottom:1.5rem;">
    <a href="<%: ResolveUrl("~/Teacher/uploadMaterial.aspx") %>" class="mm-btn-upload"><i class="bi bi-plus-lg"></i> <%: T("Upload Material","Muat Naik Bahan") %></a>
</div>

<%-- Search & Filter --%>
<div class="mm-filter-bar">
    <div class="mm-search-wrap">
        <i class="bi bi-search"></i>
        <asp:TextBox ID="txtSearch" runat="server" />
    </div>
    <asp:DropDownList ID="ddlFilterLevel" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterLevel_Changed" CssClass="mm-select" />
    <asp:DropDownList ID="ddlFilterUnit" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterUnit_Changed" CssClass="mm-select" />
    <asp:DropDownList ID="ddlFilterType" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterType_Changed" CssClass="mm-select" />
    <asp:DropDownList ID="ddlFilterStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterStatus_Changed" CssClass="mm-select" />
    <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="btnSearch_Click" CausesValidation="false" CssClass="mm-btn-search" />
</div>

<%-- Materials list --%>
<asp:Panel ID="pnlMaterials" runat="server" Visible="false">
    <asp:Repeater ID="rptMaterials" runat="server" OnItemCommand="rptMaterials_ItemCommand">
        <ItemTemplate>
            <div class="mm-card">
                <div class="mm-card-top">
                    <div class="mm-card-ico"><i class='bi <%# GetFileIcon(Eval("materialType").ToString()) %>'></i></div>
                    <div class="mm-card-info">
                        <div class="mm-card-title"><%# HttpUtility.HtmlEncode(Eval("materialTitle")) %></div>
                        <div class="mm-card-desc"><%# HttpUtility.HtmlEncode(TruncateText(Eval("materialContent")?.ToString(), 120)) %></div>
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
                    <a href='<%# ResolveUrl("~/") + Eval("fileUrl") %>' target="_blank" class="mm-action-btn mm-act-view"><i class="bi bi-eye"></i> View</a>
                    <a href='<%# ResolveUrl("~/") + Eval("fileUrl") %>' download class="mm-action-btn mm-act-download"><i class="bi bi-download"></i> Download</a>
                    <%# Eval("status").ToString() == "Rejected" ?
                        "<button type='button' class='mm-action-btn mm-act-resubmit' onclick=\"openEditModal('" + Eval("materialId") + "')\"><i class='bi bi-arrow-counterclockwise'></i> Resubmit</button>" :
                        "<button type='button' class='mm-action-btn mm-act-edit' onclick=\"openEditModal('" + Eval("materialId") + "')\"><i class='bi bi-pencil'></i> Edit</button>" %>
                    <button type="button" class="mm-action-btn mm-act-delete" onclick="openDeleteModal('<%# Eval("materialId") %>')"><i class="bi bi-trash"></i> Delete</button>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</asp:Panel>

<%-- Empty state --%>
<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="mm-empty">
        <div style="font-size:3rem;opacity:.5;margin-bottom:.75rem;">📂</div>
        <div style="font-size:1rem;font-weight:700;color:var(--tc-text);margin-bottom:.25rem;"><%: T("No materials uploaded yet.","Tiada bahan dimuat naik lagi.") %></div>
        <div style="font-size:.85rem;"><%: T("Click \"Upload Material\" to add your first learning resource.","Klik \"Muat Naik Bahan\" untuk menambah sumber pembelajaran pertama anda.") %></div>
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
    <div class="mm-modal mm-modal-sm">
        <div class="mm-modal-header">
            <h3 class="mm-modal-title"><%: T("Delete Material","Padam Bahan") %></h3>
            <button type="button" class="mm-modal-close" onclick="closeDeleteModal()">×</button>
        </div>
        <div class="mm-modal-body" style="text-align:center;padding:1.5rem;">
            <p style="font-size:.9rem;color:var(--tc-text);"><%: T("Are you sure you want to delete this material?<br/>This action cannot be undone.","Adakah anda pasti mahu memadam bahan ini?<br/>Tindakan ini tidak boleh dibatalkan.") %></p>
        </div>
        <div class="mm-modal-footer" style="justify-content:center;">
            <button type="button" class="mm-btn-cancel" onclick="closeDeleteModal()"><%: T("Cancel","Batal") %></button>
            <asp:Button ID="btnConfirmDelete" runat="server" Text="Delete" OnClick="btnConfirmDelete_Click" CausesValidation="false"
                CssClass="mm-btn-primary" style="background:var(--tc-error);" />
        </div>
    </div>
</div>

<asp:HiddenField ID="hidDeleteId" runat="server" Value="" />
<asp:HiddenField ID="hidShowEditModal" runat="server" Value="" />
<asp:HiddenField ID="hidToast" runat="server" Value="" />

<%-- Toast container --%>
<div id="mmToastContainer" class="mm-toast-container"></div>

</asp:Panel><%-- /pnlMain --%>
</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
function openEditModal(id) {
    document.getElementById('<%=hidMaterialId.ClientID%>').value = id;
    __doPostBack('LoadEdit', id);
}
function closeEditModal() { document.getElementById('editModal').style.display = 'none'; }
function showEditModal() { document.getElementById('editModal').style.display = 'flex'; }
function openSaveConfirm() { document.getElementById('saveConfirmModal').style.display = 'flex'; }
function closeSaveConfirm() { document.getElementById('saveConfirmModal').style.display = 'none'; }
function openDeleteModal(id) {
    document.getElementById('<%=hidDeleteId.ClientID%>').value = id;
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
