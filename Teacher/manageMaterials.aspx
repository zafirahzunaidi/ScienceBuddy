<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="manageMaterials.aspx.cs"
    Inherits="ScienceBuddy.Teacher.manageMaterials" MasterPageFile="~/Site.Master"
    Title="Manage Materials" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%: ResolveUrl("~/Content/Teacher.css") %>" rel="stylesheet" />
</asp:Content>

<%-- Sidebar --%>
<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">

    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-speedometer2 item-icon"></i>
            <span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Teacher/Notifications.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-bell item-icon"></i>
            <span class="item-label"><%: T("Notifications","Notifikasi") %></span>
        </a>
    </div>

    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Teaching","Pengajaran") %></div>
        <a href="<%: ResolveUrl("~/Teacher/manageMaterials.aspx") %>" class="sb-sidebar-item active">
            <i class="bi bi-book item-icon"></i>
            <span class="item-label"><%: T("Manage Materials","Bahan Pembelajaran") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-patch-question item-icon"></i>
            <span class="item-label"><%: T("Manage Quiz","Kuiz") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Teacher/studentProgress.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-bar-chart item-icon"></i>
            <span class="item-label"><%: T("Student Progress","Prestasi Pelajar") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Teacher/liveSession.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-camera-video item-icon"></i>
            <span class="item-label"><%: T("Schedule Live Class","Kelas Langsung") %></span>
        </a>
    </div>

    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Community","Komuniti") %></div>
        <a href="<%: ResolveUrl("~/Teacher/forum.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-chat-dots item-icon"></i>
            <span class="item-label"><%: T("Forum","Forum") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Teacher/privateMessages.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-envelope item-icon"></i>
            <span class="item-label"><%: T("Private Message","Mesej Peribadi") %></span>
        </a>
    </div>

    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Account","Akaun") %></div>
        <a href="<%: ResolveUrl("~/Teacher/MyProfile.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-person item-icon"></i>
            <span class="item-label"><%: T("My Profile","Profil Saya") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-box-arrow-right item-icon"></i>
            <span class="item-label"><%: T("Sign Out","Log Keluar") %></span>
        </a>
    </div>

</asp:Content>

<%-- Page Title --%>
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <%: T("Manage Materials","Urus Bahan") %>
</asp:Content>

<%-- Main Content --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

    <%-- Access Denied Panel --%>
    <asp:Panel ID="pnlDenied" runat="server" Visible="false">
        <div style="display:flex;flex-direction:column;align-items:center;padding:3rem;text-align:center;">
            <div style="font-size:3rem;margin-bottom:1rem;">??</div>
            <h2 style="color:var(--tc-text);font-weight:800;">Access Denied</h2>
            <p style="color:var(--tc-muted);max-width:450px;">Your account cannot access this page. Please contact support.</p>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlMain" runat="server" Visible="false">

        <%-- Page Header --%>
        <div style="display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:1rem;flex-wrap:wrap;gap:.75rem;">
            <div>
                <h1 style="font-size:1.5rem;font-weight:800;color:var(--tc-text);margin:0;">
                    <%: T("Manage Materials","Urus Bahan") %>
                </h1>
                <p style="font-size:.85rem;color:var(--tc-muted);margin:.3rem 0 0;">
                    <%: T("Upload, manage, and discover learning materials.","Muat naik, urus, dan terokai bahan pembelajaran.") %>
                </p>
            </div>
            <asp:Panel ID="pnlUploadBtn" runat="server">
                <asp:Panel ID="pnlUploadEnabled" runat="server">
                    <a href="<%: ResolveUrl("~/Teacher/uploadMaterial.aspx") %>"
                        class="tc-manage-materials-btn-upload">
                        <i class="bi bi-plus-lg"></i> <%: T("Upload Material","Muat Naik Bahan") %>
                    </a>
                </asp:Panel>
                <asp:Panel ID="pnlUploadDisabled" runat="server" Visible="false">
                    <button type="button"
                        class="tc-manage-materials-btn-upload-disabled"
                        disabled
                        title="<%: T("Your teaching certificate is pending verification.","Sijil pengajaran anda sedang dalam semakan.") %>">
                        <i class="bi bi-plus-lg"></i> <%: T("Upload Material","Muat Naik Bahan") %>
                    </button>
                </asp:Panel>
            </asp:Panel>
        </div>

        <%-- Tabs --%>
        <div class="tc-manage-materials-tabs">
            <asp:LinkButton ID="btnTabMine" runat="server"
                CssClass="tc-manage-materials-tab active"
                OnClick="btnTabMine_Click"
                CausesValidation="false">
                <i class="bi bi-folder2-open"></i> <%: T("My Materials","Bahan Saya") %>
            </asp:LinkButton>
            <asp:LinkButton ID="btnTabDiscover" runat="server"
                CssClass="tc-manage-materials-tab"
                OnClick="btnTabDiscover_Click"
                CausesValidation="false">
                <i class="bi bi-globe2"></i> <%: T("Discover Materials","Terokai Bahan") %>
            </asp:LinkButton>
        </div>

        <%-- Search & Filter --%>
        <asp:Panel ID="pnlFilterBar" runat="server">
            <div class="tc-manage-materials-filter-bar">
                <div class="tc-manage-materials-search-wrap">
                    <i class="bi bi-search"></i>
                    <asp:TextBox ID="txtSearch" runat="server" />
                </div>
                <asp:DropDownList ID="ddlFilterLevel" runat="server"
                    AutoPostBack="true"
                    OnSelectedIndexChanged="ddlFilterLevel_Changed"
                    CssClass="tc-manage-materials-select" />
                <asp:DropDownList ID="ddlFilterUnit" runat="server"
                    AutoPostBack="true"
                    OnSelectedIndexChanged="ddlFilterUnit_Changed"
                    CssClass="tc-manage-materials-select" />
                <asp:DropDownList ID="ddlFilterType" runat="server"
                    AutoPostBack="true"
                    OnSelectedIndexChanged="ddlFilterType_Changed"
                    CssClass="tc-manage-materials-select" />
                <asp:Button ID="btnSearch" runat="server"
                    Text="Search"
                    OnClick="btnSearch_Click"
                    CausesValidation="false"
                    CssClass="tc-manage-materials-btn-search" />
            </div>
        </asp:Panel>

        <%-- Status Chips (My Materials only) --%>
        <asp:Panel ID="pnlStatusChips" runat="server">
            <div class="tc-manage-materials-chips">
                <asp:LinkButton ID="btnChipAll" runat="server"
                    CssClass="tc-manage-materials-chip active"
                    OnClick="btnChip_Click"
                    CommandArgument=""
                    CausesValidation="false"
                    data-status="all">
                    <%: T("All","Semua") %>
                </asp:LinkButton>
                <asp:LinkButton ID="btnChipApproved" runat="server"
                    CssClass="tc-manage-materials-chip"
                    OnClick="btnChip_Click"
                    CommandArgument="Approved"
                    CausesValidation="false"
                    data-status="approved">
                    <%: T("Approved","Diluluskan") %>
                </asp:LinkButton>
                <asp:LinkButton ID="btnChipPending" runat="server"
                    CssClass="tc-manage-materials-chip"
                    OnClick="btnChip_Click"
                    CommandArgument="Pending"
                    CausesValidation="false"
                    data-status="pending">
                    <%: T("Pending","Menunggu") %>
                </asp:LinkButton>
                <asp:LinkButton ID="btnChipRejected" runat="server"
                    CssClass="tc-manage-materials-chip"
                    OnClick="btnChip_Click"
                    CommandArgument="Rejected"
                    CausesValidation="false"
                    data-status="rejected">
                    <%: T("Rejected","Ditolak") %>
                </asp:LinkButton>
            </div>
        </asp:Panel>
        <asp:DropDownList ID="ddlFilterStatus" runat="server" Visible="false" />

        <%-- Pending Verification State (My Materials tab only) --%>
        <asp:Panel ID="pnlMyMaterialsPending" runat="server" Visible="false">
            <div style="display:flex;flex-direction:column;align-items:center;padding:3.5rem 2rem;text-align:center;">
                <div style="font-size:3.5rem;margin-bottom:1rem;opacity:.85;">?</div>
                <h2 style="font-size:1.15rem;font-weight:800;color:var(--tc-text);margin:0 0 .6rem;">
                    <%: T("Verification Pending","Pengesahan Sedang Diproses") %>
                </h2>
                <p style="font-size:.88rem;color:var(--tc-muted);max-width:480px;line-height:1.65;margin:0;">
                    <%: T("Your teaching certificate is under review. You'll be able to upload and manage learning materials once your verification is approved.","Sijil pengajaran anda sedang dalam semakan. Anda boleh memuat naik dan mengurus bahan pembelajaran setelah pengesahan anda diluluskan.") %>
                </p>
            </div>
        </asp:Panel>

        <%-- Material Cards (My Materials) --%>
        <asp:Panel ID="pnlMaterials" runat="server" Visible="false">
            <asp:Repeater ID="rptMaterials" runat="server" OnItemCommand="rptMaterials_ItemCommand">
                <ItemTemplate>
                    <div class="tc-manage-materials-card">
                        <div class="tc-manage-materials-card-top">
                            <div class='tc-manage-materials-card-ico <%# GetIconCss(Eval("materialType").ToString()) %>'>
                                <i class='bi <%# GetFileIcon(Eval("materialType").ToString()) %>'></i>
                            </div>
                            <div class="tc-manage-materials-card-info">
                                <div class="tc-manage-materials-card-title">
                                    <%# HttpUtility.HtmlEncode(Eval("materialTitle")) %>
                                </div>
                                <div class="tc-manage-materials-card-desc">
                                    <%# (Eval("materialContent")?.ToString() ?? "").Length > 250 ? "<span class='tc-manage-materials-desc-short'>" + HttpUtility.HtmlEncode((Eval("materialContent")?.ToString() ?? "").Substring(0,250)) + "...</span><span class='tc-manage-materials-desc-full'>" + HttpUtility.HtmlEncode(Eval("materialContent")?.ToString() ?? "") + "</span>" : HttpUtility.HtmlEncode(Eval("materialContent")?.ToString() ?? "") %>
                                </div>
                                <%# (Eval("materialContent")?.ToString() ?? "").Length > 250 ? "<span class='tc-manage-materials-view-more' onclick='toggleDesc(this)'>View More</span>" : "" %>
                                <div class="tc-manage-materials-card-meta">
                                    <span><i class="bi bi-folder2-open"></i> <%# HttpUtility.HtmlEncode(Eval("subtopicName")) %></span>
                                    <span><i class="bi bi-file-earmark"></i> <%# HttpUtility.HtmlEncode(Eval("materialType")) %></span>
                                    <span><i class="bi bi-calendar-event"></i> <%# Eval("createdDate", "{0:d MMM yyyy}") %></span>
                                    <span><i class="bi bi-translate"></i> <%# HttpUtility.HtmlEncode(Eval("language")) %></span>
                                </div>
                            </div>
                            <span class='tc-manage-materials-badge <%# GetStatusCss(Eval("status").ToString()) %>'>
                                <%# HttpUtility.HtmlEncode(Eval("status")) %>
                            </span>
                        </div>
                        <div class="tc-manage-materials-card-actions">
                            <button type="button"
                                class="tc-manage-materials-action-btn tc-manage-materials-act-view"
                                onclick="openViewModal(this)"
                                data-title='<%# HttpUtility.HtmlAttributeEncode(Eval("materialTitle").ToString()) %>'
                                data-desc='<%# HttpUtility.HtmlAttributeEncode(Eval("materialContent")?.ToString() ?? "") %>'
                                data-type='<%# HttpUtility.HtmlAttributeEncode(Eval("materialType").ToString()) %>'
                                data-lang='<%# HttpUtility.HtmlAttributeEncode(Eval("language")?.ToString() ?? "") %>'
                                data-subtopic='<%# HttpUtility.HtmlAttributeEncode(Eval("subtopicName")?.ToString() ?? "") %>'
                                data-file='<%# HttpUtility.HtmlAttributeEncode(GetFilePath(Eval("fileUrl"))) %>'>
                                <i class="bi bi-eye"></i> View
                            </button>
                            <asp:LinkButton ID="lnkDownload" runat="server"
                                CommandName="DownloadMaterial"
                                CommandArgument='<%# Eval("fileUrl") %>'
                                CssClass="tc-manage-materials-action-btn tc-manage-materials-act-download"
                                CausesValidation="false">
                                <i class="bi bi-download"></i> Download
                            </asp:LinkButton>
                            <%# Eval("status").ToString() == "Rejected" ?
                                "<button type='button' class='tc-manage-materials-action-btn tc-manage-materials-act-resubmit' onclick=\"openEditModal('" + Eval("materialId") + "')\"><i class='bi bi-arrow-counterclockwise'></i> Resubmit</button>" :
                                "<button type='button' class='tc-manage-materials-action-btn tc-manage-materials-act-edit' onclick=\"openEditModal('" + Eval("materialId") + "')\"><i class='bi bi-pencil'></i> Edit</button>" %>
                            <button type="button"
                                class="tc-manage-materials-action-btn tc-manage-materials-act-delete"
                                onclick="openDeleteModal('<%# Eval("materialId") %>','<%# HttpUtility.JavaScriptStringEncode(Eval("materialTitle").ToString()) %>')">
                                <i class="bi bi-trash"></i> Delete
                            </button>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </asp:Panel>

        <%-- Empty State (My Materials) --%>
        <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
            <div class="tc-manage-materials-empty">
                <div style="font-size:3rem;opacity:.5;margin-bottom:.75rem;">??</div>
                <div style="font-size:1rem;font-weight:700;color:var(--tc-text);margin-bottom:.25rem;">
                    <asp:Literal ID="litEmptyTitle" runat="server" />
                </div>
                <div style="font-size:.85rem;margin-bottom:1rem;">
                    <asp:Literal ID="litEmptyDesc" runat="server" />
                </div>
                <asp:Panel ID="pnlEmptyUploadBtn" runat="server">
                    <a href="<%: ResolveUrl("~/Teacher/uploadMaterial.aspx") %>"
                        class="tc-manage-materials-btn-upload">
                        <i class="bi bi-plus-lg"></i> <%: T("Upload Material","Muat Naik Bahan") %>
                    </a>
                </asp:Panel>
            </div>
        </asp:Panel>

        <%-- Discover Materials --%>
        <asp:Panel ID="pnlDiscover" runat="server" Visible="false">
            <asp:Repeater ID="rptDiscover" runat="server" OnItemCommand="rptDiscover_ItemCommand">
                <ItemTemplate>
                    <div class="tc-manage-materials-card">
                        <div class="tc-manage-materials-card-top">
                            <div class='tc-manage-materials-card-ico <%# GetIconCss(Eval("materialType").ToString()) %>'>
                                <i class='bi <%# GetFileIcon(Eval("materialType").ToString()) %>'></i>
                            </div>
                            <div class="tc-manage-materials-card-info">
                                <div class="tc-manage-materials-card-title">
                                    <%# HttpUtility.HtmlEncode(Eval("materialTitle")) %>
                                </div>
                                <div class="tc-manage-materials-card-teacher">
                                    <i class="bi bi-person"></i> <%# HttpUtility.HtmlEncode(Eval("teacherName")) %>
                                </div>
                                <div class="tc-manage-materials-card-desc">
                                    <%# (Eval("materialContent")?.ToString() ?? "").Length > 250 ? "<span class='tc-manage-materials-desc-short'>" + HttpUtility.HtmlEncode((Eval("materialContent")?.ToString() ?? "").Substring(0,250)) + "...</span><span class='tc-manage-materials-desc-full'>" + HttpUtility.HtmlEncode(Eval("materialContent")?.ToString() ?? "") + "</span>" : HttpUtility.HtmlEncode(Eval("materialContent")?.ToString() ?? "") %>
                                </div>
                                <%# (Eval("materialContent")?.ToString() ?? "").Length > 250 ? "<span class='tc-manage-materials-view-more' onclick='toggleDesc(this)'>View More</span>" : "" %>
                                <div class="tc-manage-materials-card-meta">
                                    <span><i class="bi bi-folder2-open"></i> <%# HttpUtility.HtmlEncode(Eval("subtopicName")) %></span>
                                    <span><i class="bi bi-file-earmark"></i> <%# HttpUtility.HtmlEncode(Eval("materialType")) %></span>
                                    <span><i class="bi bi-calendar-event"></i> <%# Eval("createdDate", "{0:d MMM yyyy}") %></span>
                                    <span><i class="bi bi-translate"></i> <%# HttpUtility.HtmlEncode(Eval("language")) %></span>
                                </div>
                            </div>
                        </div>
                        <div class="tc-manage-materials-card-actions">
                            <button type="button"
                                class="tc-manage-materials-action-btn tc-manage-materials-act-view"
                                onclick="openViewModal(this)"
                                data-title='<%# HttpUtility.HtmlAttributeEncode(Eval("materialTitle").ToString()) %>'
                                data-desc='<%# HttpUtility.HtmlAttributeEncode(Eval("materialContent")?.ToString() ?? "") %>'
                                data-type='<%# HttpUtility.HtmlAttributeEncode(Eval("materialType").ToString()) %>'
                                data-lang='<%# HttpUtility.HtmlAttributeEncode(Eval("language")?.ToString() ?? "") %>'
                                data-subtopic='<%# HttpUtility.HtmlAttributeEncode(Eval("subtopicName")?.ToString() ?? "") %>'
                                data-teacher='<%# HttpUtility.HtmlAttributeEncode(Eval("teacherName")?.ToString() ?? "") %>'
                                data-file='<%# HttpUtility.HtmlAttributeEncode(GetFilePath(Eval("fileUrl"))) %>'>
                                <i class="bi bi-eye"></i> <%: T("View","Lihat") %>
                            </button>
                            <asp:LinkButton ID="lnkDownloadD" runat="server"
                                CommandName="DownloadMaterial"
                                CommandArgument='<%# Eval("fileUrl") %>'
                                CssClass="tc-manage-materials-action-btn tc-manage-materials-act-download"
                                CausesValidation="false">
                                <i class="bi bi-download"></i> <%: T("Download","Muat Turun") %>
                            </asp:LinkButton>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </asp:Panel>

        <%-- Empty State (Discover) --%>
        <asp:Panel ID="pnlDiscoverEmpty" runat="server" Visible="false">
            <div class="tc-manage-materials-empty">
                <div style="font-size:3rem;opacity:.5;margin-bottom:.75rem;">??</div>
                <div style="font-size:1rem;font-weight:700;color:var(--tc-text);margin-bottom:.25rem;">
                    <%: T("No shared materials are available at the moment.","Tiada bahan kongsi tersedia buat masa ini.") %>
                </div>
                <div style="font-size:.85rem;">
                    <%: T("Check back later for materials shared by other teachers.","Semak kemudian untuk bahan yang dikongsi oleh guru lain.") %>
                </div>
            </div>
        </asp:Panel>

        <%-- Edit Modal --%>
        <div id="editModal" class="tc-manage-materials-modal-overlay" style="display:none;">
            <div class="tc-manage-materials-modal">
                <div class="tc-manage-materials-modal-header">
                    <div>
                        <h3 class="tc-manage-materials-modal-title">
                            <asp:Literal ID="litFormTitle" runat="server" Text="Edit Material" />
                        </h3>
                        <p class="tc-manage-materials-modal-sub">Update your learning material information.</p>
                    </div>
                    <button type="button" class="tc-manage-materials-modal-close" onclick="closeEditModal()">&#215;</button>
                </div>
                <div class="tc-manage-materials-modal-body">
                    <asp:HiddenField ID="hidMaterialId" runat="server" Value="" />
                    <asp:HiddenField ID="hidMaterialStatus" runat="server" Value="" />
                    <%-- Hidden fields to store original values for change detection --%>
                    <asp:HiddenField ID="hidOrigTitle" runat="server" Value="" />
                    <asp:HiddenField ID="hidOrigDesc" runat="server" Value="" />
                    <asp:HiddenField ID="hidOrigLang" runat="server" Value="" />
                    <asp:HiddenField ID="hidOrigLevel" runat="server" Value="" />
                    <asp:HiddenField ID="hidOrigUnit" runat="server" Value="" />
                    <asp:HiddenField ID="hidOrigSubtopic" runat="server" Value="" />
                    <div class="tc-manage-materials-form-grid2">
                        <div>
                            <label class="tc-manage-materials-label">Title *</label>
                            <asp:TextBox ID="txtTitle" runat="server"
                                MaxLength="150"
                                CssClass="tc-manage-materials-input" />
                            <div class="tc-manage-materials-val-msg" id="valTitle">Title is required.</div>
                        </div>
                        <div>
                            <label class="tc-manage-materials-label">Language *</label>
                            <asp:DropDownList ID="ddlLanguage" runat="server" CssClass="tc-manage-materials-input">
                                <asp:ListItem Value="EN" Text="English" />
                                <asp:ListItem Value="BM" Text="Bahasa Melayu" />
                            </asp:DropDownList>
                            <div class="tc-manage-materials-val-msg" id="valLang">Language is required.</div>
                        </div>
                    </div>
                    <div style="margin-bottom:1rem;">
                        <label class="tc-manage-materials-label">Description</label>
                        <asp:TextBox ID="txtDescription" runat="server"
                            TextMode="MultiLine"
                            Rows="3"
                            CssClass="tc-manage-materials-input"
                            style="resize:vertical;" />
                    </div>
                    <div class="tc-manage-materials-form-grid3">
                        <div>
                            <label class="tc-manage-materials-label">Level *</label>
                            <asp:DropDownList ID="ddlLevel" runat="server"
                                AutoPostBack="true"
                                OnSelectedIndexChanged="ddlLevel_Changed"
                                CssClass="tc-manage-materials-input" />
                            <div class="tc-manage-materials-val-msg" id="valLevel">Level is required.</div>
                        </div>
                        <div>
                            <label class="tc-manage-materials-label">Unit *</label>
                            <asp:DropDownList ID="ddlUnit" runat="server"
                                AutoPostBack="true"
                                OnSelectedIndexChanged="ddlUnit_Changed"
                                CssClass="tc-manage-materials-input" />
                            <div class="tc-manage-materials-val-msg" id="valUnit">Unit is required.</div>
                        </div>
                        <div>
                            <label class="tc-manage-materials-label">Subtopic *</label>
                            <asp:DropDownList ID="ddlSubtopic" runat="server"
                                CssClass="tc-manage-materials-input" />
                            <div class="tc-manage-materials-val-msg" id="valSubtopic">Subtopic is required.</div>
                        </div>
                    </div>
                    <div style="margin-bottom:.5rem;">
                        <label class="tc-manage-materials-label">Replace File (optional)</label>
                        <asp:FileUpload ID="fuFile" runat="server"
                            CssClass="tc-manage-materials-input"
                            style="padding:.4rem .6rem;background:#FAFAFA;" />
                        <div style="font-size:.72rem;color:var(--tc-muted);margin-top:3px;">
                            PDF, DOC, DOCX, PPT, PPTX, JPG, JPEG, PNG (max 10 MB)
                        </div>
                        <asp:Panel ID="pnlCurrentFile" runat="server" Visible="false">
                            <div style="font-size:.78rem;color:var(--tc-info);margin-top:4px;">
                                <i class="bi bi-paperclip"></i> Current: <asp:Literal ID="litCurrentFile" runat="server" />
                            </div>
                        </asp:Panel>
                    </div>
                </div>
                <div class="tc-manage-materials-modal-footer">
                    <button type="button" class="tc-manage-materials-btn-cancel" onclick="closeEditModal()">
                        <%: T("Cancel","Batal") %>
                    </button>
                    <button type="button"
                        class="tc-manage-materials-btn-primary"
                        id="btnEditConfirmChanges"
                        onclick="validateEditForm()">
                        <asp:Literal ID="litSaveBtnText" runat="server" Text="Confirm Changes" />
                    </button>
                </div>
            </div>
        </div>

        <%-- Save Confirmation Modal --%>
        <div id="saveConfirmModal" class="tc-manage-materials-modal-overlay" style="display:none;">
            <div style="background:#fff;border-radius:20px;width:100%;max-width:380px;box-shadow:0 20px 60px rgba(17,24,39,.16);border:1px solid #F0F0F0;position:relative;animation:mmFadeIn .2s ease;">
                <button type="button" onclick="closeSaveConfirm()"
                    style="position:absolute;top:14px;right:16px;background:none;border:none;font-size:1.3rem;color:#9CA3AF;cursor:pointer;line-height:1;padding:2px;">
                    &#215;
                </button>
                <div style="padding:2rem 1.75rem 1.5rem;text-align:center;">
                    <div style="width:56px;height:56px;border-radius:50%;background:#EEF2FF;border:2px solid #C7D2FE;display:inline-flex;align-items:center;justify-content:center;margin-bottom:1rem;">
                        <i class="bi bi-info-circle-fill" style="font-size:1.5rem;color:#6C63FF;"></i>
                    </div>
                    <h3 id="scmTitle"
                        style="font-size:1.1rem;font-weight:800;color:#1E293B;margin:0 0 .5rem;">
                        Confirm Material Changes
                    </h3>
                    <p id="scmMessage"
                        style="font-size:.88rem;color:#6B7280;line-height:1.65;margin:0;">
                        Editing this material will return its status to Pending for review. Are you sure you want to continue?
                    </p>
                </div>
                <div style="display:flex;gap:.75rem;padding:1rem 1.75rem 1.5rem;justify-content:center;">
                    <button type="button" onclick="closeSaveConfirm()"
                        style="flex:1;max-width:145px;height:42px;border-radius:10px;border:1.5px solid #E5E7EB;background:#fff;font-size:.88rem;font-weight:700;color:#374151;cursor:pointer;transition:border-color .15s,background .15s;">
                        <%: T("Cancel","Batal") %>
                    </button>
                    <asp:Button ID="btnSave" runat="server"
                        Text="Confirm"
                        OnClick="btnSave_Click"
                        CausesValidation="false"
                        style="flex:1;max-width:145px;height:42px;border-radius:10px;border:none;background:#6C63FF;font-size:.88rem;font-weight:700;color:#fff;cursor:pointer;transition:background .15s;box-shadow:0 2px 8px rgba(108,99,255,.25);" />
                </div>
            </div>
        </div>

        <%-- Delete Confirmation Modal --%>
        <div id="deleteConfirmModal" class="tc-manage-materials-modal-overlay" style="display:none;">
            <div class="tc-manage-materials-modal tc-manage-materials-modal-sm"
                style="border-radius:16px;overflow:hidden;box-shadow:0 20px 60px rgba(0,0,0,.18);">
                <div style="background:#FEF2F2;padding:1.1rem 1.5rem;display:flex;align-items:center;justify-content:space-between;border-bottom:1px solid #FECACA;">
                    <h3 style="margin:0;font-size:1rem;font-weight:800;color:#991B1B;display:flex;align-items:center;gap:7px;">
                        <i class="bi bi-trash3" style="font-size:1rem;"></i>
                        <%: T("Confirm Deletion","Sahkan Pemadaman") %>
                    </h3>
                    <button type="button" class="tc-manage-materials-modal-close" onclick="closeDeleteModal()">&#215;</button>
                </div>
                <div style="padding:1.4rem 1.5rem;text-align:left;">
                    <p style="font-size:.92rem;color:var(--tc-text);margin:0;line-height:1.6;">
                        <%: T("Are you sure you want to delete","Adakah anda pasti mahu memadam") %>
                        <br/><strong id="delMaterialTitle" style="color:var(--tc-text);"></strong>?
                    </p>
                </div>
                <div style="display:flex;justify-content:flex-end;gap:.6rem;padding:1rem 1.5rem;border-top:1px solid var(--tc-border);">
                    <button type="button"
                        class="tc-manage-materials-btn-cancel"
                        onclick="closeDeleteModal()"
                        style="border-radius:10px;">
                        <%: T("Cancel","Batal") %>
                    </button>
                    <asp:Button ID="btnConfirmDelete" runat="server"
                        Text="Delete"
                        OnClick="btnConfirmDelete_Click"
                        CausesValidation="false"
                        CssClass="tc-manage-materials-btn-primary"
                        style="background:#DC2626;border-radius:10px;" />
                </div>
            </div>
        </div>

        <asp:HiddenField ID="hidDeleteId" runat="server" Value="" />
        <asp:HiddenField ID="hidShowEditModal" runat="server" Value="" />
        <asp:HiddenField ID="hidToast" runat="server" Value="" />
        <asp:HiddenField ID="hidActiveTab" runat="server" Value="mine" />

        <%-- View Material Modal --%>
        <div id="viewMaterialModal"
            class="tc-manage-materials-modal-overlay"
            style="display:none;"
            onclick="if(event.target===this)closeViewModal()">
            <div class="tc-manage-materials-modal"
                style="max-width:780px;max-height:90vh;display:flex;flex-direction:column;border-radius:18px;overflow:hidden;box-shadow:0 24px 64px rgba(0,0,0,.22);">
                <div style="display:flex;align-items:center;justify-content:space-between;padding:1.1rem 1.5rem;border-bottom:1px solid var(--tc-border);flex-shrink:0;">
                    <h3 id="vmTitle" style="font-size:1rem;font-weight:800;color:var(--tc-text);margin:0;"></h3>
                    <button type="button"
                        style="background:none;border:none;font-size:1.3rem;color:var(--tc-muted);cursor:pointer;"
                        onclick="closeViewModal()">
                        &#215;
                    </button>
                </div>
                <div style="flex:1;overflow-y:auto;padding:1.25rem 1.5rem;">
                    <div id="vmPreview" style="border-radius:12px;overflow:hidden;"></div>
                </div>
            </div>
        </div>

        <%-- Toast Container --%>
        <div id="mmToastContainer" class="tc-manage-materials-toast-container"></div>

    </asp:Panel><%-- /pnlMain --%>

</asp:Content>

<%-- Scripts --%>
<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
    function toggleDesc(el) {
        var desc = el.previousElementSibling;
        if (!desc.classList.contains('expanded')) {
            desc.classList.add('expanded');
            el.textContent = 'View Less';
        } else {
            desc.classList.remove('expanded');
            el.textContent = 'View More';
        }
    }

    function openViewModal(btn) {
        var title = btn.dataset.title || '';
        var file = btn.dataset.file || '';

        var resolvedUrl = '<%: ResolveUrl("~/") %>' + file;
        var ext = file.split('.').pop().toLowerCase();

        // Unsupported preview types - open in new tab instead
        if (['ppt','pptx','doc','docx','xls','xlsx'].indexOf(ext) >= 0) {
            showToast('Preview is not available for this file type. Opening in a new tab...');
            window.open(resolvedUrl, '_blank');
            return;
        }

        document.getElementById('vmTitle').textContent = title;

        // Preview only - no meta, no description
        var preview = document.getElementById('vmPreview');

        if (ext === 'pdf') {
            preview.innerHTML = '<iframe src="' + resolvedUrl + '" style="width:100%;height:550px;border:1px solid #E5E7EB;border-radius:10px;" frameborder="0"></iframe>';
        } else if (['jpg','jpeg','png','gif','webp'].indexOf(ext) >= 0) {
            preview.innerHTML = '<img src="' + resolvedUrl + '" style="max-width:100%;border-radius:10px;box-shadow:0 2px 10px rgba(0,0,0,.08);" alt="Preview" />';
        } else if (['mp4','webm','ogg'].indexOf(ext) >= 0) {
            preview.innerHTML = '<video controls style="width:100%;border-radius:10px;"><source src="' + resolvedUrl + '" type="video/' + ext + '">Your browser does not support video.</video>';
        } else {
            // Any other unknown type - also open in new tab
            showToast('Preview is not available for this file type. Opening in a new tab...');
            window.open(resolvedUrl, '_blank');
            return;
        }

        document.getElementById('viewMaterialModal').style.display = 'flex';
        document.body.style.overflow = 'hidden';
    }

    function closeViewModal() {
        document.getElementById('viewMaterialModal').style.display = 'none';
        document.getElementById('vmPreview').innerHTML = '';
        document.body.style.overflow = '';
    }

    function escVM(s) { var d = document.createElement('div'); d.textContent = s; return d.innerHTML; }

    function openEditModal(id) {
        document.getElementById('<%=hidMaterialId.ClientID%>').value = id;
        __doPostBack('LoadEdit', id);
    }

    function closeEditModal() {
        document.getElementById('editModal').style.display = 'none';
        clearValidation();
    }

    function showEditModal() { document.getElementById('editModal').style.display = 'flex'; }

    /* --- VALIDATION --- */
    function clearValidation() {
        var msgs = document.querySelectorAll('.tc-manage-materials-val-msg');
        for (var i = 0; i < msgs.length; i++) msgs[i].classList.remove('show');
        var inputs = document.querySelectorAll('#editModal .tc-manage-materials-invalid');
        for (var i = 0; i < inputs.length; i++) inputs[i].classList.remove('tc-manage-materials-invalid');
    }

    function isEmptyHtml(val) {
        if (!val) return true;
        // Strip HTML tags and check if only whitespace/empty remains
        var stripped = val.replace(/<[^>]*>/g, '').replace(/&nbsp;/g, ' ').trim();
        return stripped.length === 0;
    }

    function showVal(id, el) {
        document.getElementById(id).classList.add('show');
        if (el) el.classList.add('tc-manage-materials-invalid');
    }

    function hideVal(id, el) {
        document.getElementById(id).classList.remove('show');
        if (el) el.classList.remove('tc-manage-materials-invalid');
    }

    function validateEditForm() {
        clearValidation();
        var valid = true;

        // Title
        var titleEl = document.querySelector('[id$="txtTitle"]');
        var titleVal = titleEl.value.trim();
        if (!titleVal) { showVal('valTitle', titleEl); valid = false; } else { hideVal('valTitle', titleEl); }

        // Description (optional - no validation needed)
        var descEl = document.querySelector('[id$="txtDescription"]');
        var descVal = descEl.value.trim();

        // Language
        var langEl = document.querySelector('[id$="ddlLanguage"]');
        var langVal = langEl.value;
        if (!langVal) { showVal('valLang', langEl); valid = false; } else { hideVal('valLang', langEl); }

        // Level
        var levelEl = document.querySelector('[id$="ddlLevel"]');
        var levelVal = levelEl.value;
        if (!levelVal) { showVal('valLevel', levelEl); valid = false; } else { hideVal('valLevel', levelEl); }

        // Unit
        var unitEl = document.querySelector('[id$="ddlUnit"]');
        var unitVal = unitEl.value;
        if (!unitVal) { showVal('valUnit', unitEl); valid = false; } else { hideVal('valUnit', unitEl); }

        // Subtopic
        var subEl = document.querySelector('[id$="ddlSubtopic"]');
        var subVal = subEl.value;
        if (!subVal) { showVal('valSubtopic', subEl); valid = false; } else { hideVal('valSubtopic', subEl); }

        if (!valid) return; // Do not close edit popup

        // Check if any field has actually changed
        var origTitle = document.getElementById('<%=hidOrigTitle.ClientID%>').value;
        var origDesc = document.getElementById('<%=hidOrigDesc.ClientID%>').value;
        var origLang = document.getElementById('<%=hidOrigLang.ClientID%>').value;
        var origLevel = document.getElementById('<%=hidOrigLevel.ClientID%>').value;
        var origUnit = document.getElementById('<%=hidOrigUnit.ClientID%>').value;
        var origSubtopic = document.getElementById('<%=hidOrigSubtopic.ClientID%>').value;

        // Check file upload
        var fuEl = document.querySelector('[id$="fuFile"]');
        var hasNewFile = fuEl && fuEl.files && fuEl.files.length > 0;

        var changed = hasNewFile ||
            titleVal !== origTitle.trim() ||
            descVal !== origDesc.trim() ||
            langVal !== origLang ||
            levelVal !== origLevel ||
            unitVal !== origUnit ||
            subVal !== origSubtopic;

        if (!changed) {
            showToast('No changes were made.');
            return;
        }

        // All valid and has changes - show confirmation modal
        openSaveConfirm();
    }

    function openSaveConfirm() {
        // Dynamically set modal content based on material status
        var status = document.getElementById('<%=hidMaterialStatus.ClientID%>').value || '';
        var titleEl = document.getElementById('scmTitle');
        var msgEl = document.getElementById('scmMessage');

        if (status.toLowerCase() === 'approved') {
            titleEl.textContent = '<%: T("Confirm Material Changes","Sahkan Perubahan Bahan") %>';
            msgEl.textContent = '<%: T("This material is currently approved. Editing it will return its status to Pending for review. Are you sure you want to continue?","Bahan ini kini telah diluluskan. Mengemas kininya akan menukar statusnya kepada Menunggu untuk semakan. Adakah anda pasti mahu meneruskan?") %>';
        } else {
            titleEl.textContent = '<%: T("Confirm Changes","Sahkan Perubahan") %>';
            msgEl.textContent = '<%: T("Are you sure you want to save these changes?","Adakah anda pasti mahu menyimpan perubahan ini?") %>';
        }

        document.getElementById('saveConfirmModal').style.display = 'flex';
    }

    function closeSaveConfirm() {
        document.getElementById('saveConfirmModal').style.display = 'none';
        // Re-enable the confirm button in case it was in loading state
        var btn = document.querySelector('[id$="btnSave"]');
        if (btn) { btn.disabled = false; btn.value = 'Confirm'; btn.style.opacity = ''; btn.style.cursor = ''; btn.removeAttribute('data-saving'); }
    }

    /* Attach loading state to Confirm Changes button - uses setTimeout to not block postback */
    (function(){
        var btn = document.querySelector('[id$="btnSave"]');
        if (!btn) return;
        btn.addEventListener('click', function(e) {
            if (btn.getAttribute('data-saving') === 'true') { e.preventDefault(); return false; }
            btn.setAttribute('data-saving', 'true');
            setTimeout(function(){
                btn.disabled = true;
                btn.value = 'Saving...';
                btn.style.opacity = '0.7';
                btn.style.cursor = 'not-allowed';
            }, 0);
        });
    })();

    function openDeleteModal(id, title) {
        document.getElementById('<%=hidDeleteId.ClientID%>').value = id;
        document.getElementById('delMaterialTitle').textContent = '"' + (title || 'this material') + '"';
        document.getElementById('deleteConfirmModal').style.display = 'flex';
    }

    function closeDeleteModal() { document.getElementById('deleteConfirmModal').style.display = 'none'; }

    function showToast(msg) {
        var c = document.getElementById('mmToastContainer');
        var t = document.createElement('div');
        t.className = 'tc-manage-materials-toast';
        t.innerHTML = '<i class="bi bi-check-circle-fill"></i> ' + msg;
        c.appendChild(t);
        setTimeout(function() { t.classList.add('tc-manage-materials-toast-out'); }, 3500);
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
