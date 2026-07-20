<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="manageQuiz.aspx.cs"
    Inherits="ScienceBuddy.Teacher.manageQuiz" MasterPageFile="~/Site.Master"
    Title="Manage Quizzes" %>

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
        <a href="<%: ResolveUrl("~/Teacher/manageMaterials.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-book item-icon"></i>
            <span class="item-label"><%: T("Manage Materials","Bahan Pembelajaran") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="sb-sidebar-item active">
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

<%-- Page Header --%>
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <%: T("Manage Quizzes","Urus Kuiz") %>
</asp:Content>

<%-- Main Content --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- Access Denied Panel --%>
<asp:Panel ID="pnlDenied" runat="server" Visible="false">
    <div style="display:flex;flex-direction:column;align-items:center;padding:3rem;text-align:center;">
        <div style="font-size:3rem;margin-bottom:1rem;">??</div>
        <h2 style="color:var(--tc-text);font-weight:800;">
            <%: T("Access Denied","Akses Ditolak") %>
        </h2>
        <p style="color:var(--tc-muted);max-width:450px;">
            <%: T("Your account cannot access this page.","Akaun anda tidak boleh mengakses halaman ini.") %>
        </p>
    </div>
</asp:Panel>

<asp:Panel ID="pnlMain" runat="server" Visible="false">

<%-- Page Header with Create button --%>
<div style="display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:1rem;flex-wrap:wrap;gap:.75rem;">
    <div>
        <h1 class="tc-manage-quiz-page-title"><%: T("Manage Quizzes","Urus Kuiz") %></h1>
        <p class="tc-manage-quiz-page-sub"><%: T("Create, manage, and discover quizzes.","Cipta, urus, dan terokai kuiz.") %></p>
    </div>
    <asp:Panel ID="pnlCreateBtn" runat="server">
        <button type="button" class="tc-manage-quiz-btn-create" onclick="openPracticeModal()">
            <i class="bi bi-plus-lg"></i> <%: T("Create Quiz","Cipta Kuiz") %>
        </button>
    </asp:Panel>
    <asp:Panel ID="pnlCreateULBtn" runat="server" Visible="false"></asp:Panel>
</div>

<%-- Tabs --%>
<div class="tc-manage-quiz-tabs">
    <asp:LinkButton ID="btnTabUnitLevel" runat="server"
        CssClass="tc-manage-quiz-tab active"
        OnClick="btnTabUnitLevel_Click"
        CausesValidation="false">
        <i class="bi bi-journal-text"></i> <%: T("Unit / Level Quizzes","Kuiz Unit / Tahap") %>
    </asp:LinkButton>
    <asp:LinkButton ID="btnTabMine" runat="server"
        CssClass="tc-manage-quiz-tab"
        OnClick="btnTabMine_Click"
        CausesValidation="false">
        <i class="bi bi-folder2-open"></i> <%: T("Practice Quizzes","Kuiz Latihan") %>
    </asp:LinkButton>
    <asp:LinkButton ID="btnTabDiscover" runat="server"
        CssClass="tc-manage-quiz-tab"
        OnClick="btnTabDiscover_Click"
        CausesValidation="false">
        <i class="bi bi-globe2"></i> <%: T("Discover Quizzes","Terokai Kuiz") %>
    </asp:LinkButton>
</div>

<%-- Segmented Filter (Unit/Level tab only, client-side) --%>
<div id="ulSegFilter" class="tc-manage-quiz-seg-wrap" style="display:none;">
    <div class="tc-manage-quiz-seg">
        <button type="button" class="tc-manage-quiz-seg-btn tc-manage-quiz-seg-active" onclick="filterUL('all',this)">
            <%: T("All Quizzes","Semua Kuiz") %>
        </button>
        <button type="button" class="tc-manage-quiz-seg-btn" onclick="filterUL('unit',this)">
            <%: T("Unit Quizzes","Kuiz Unit") %>
        </button>
        <button type="button" class="tc-manage-quiz-seg-btn" onclick="filterUL('level',this)">
            <%: T("Level Quizzes","Kuiz Tahap") %>
        </button>
    </div>
</div>

<%-- Search & Filter --%>
<div class="tc-manage-quiz-filter-bar" id="mqFilterBar">
    <div class="tc-manage-quiz-search-wrap">
        <i class="bi bi-search"></i>
        <asp:TextBox ID="txtSearch" runat="server" CssClass="tc-manage-quiz-search-input" />
    </div>
    <asp:DropDownList ID="ddlDifficulty" runat="server" CssClass="tc-manage-quiz-select" Visible="false" />
    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="tc-manage-quiz-select" Visible="false" />
    <asp:DropDownList ID="ddlLanguage" runat="server"
        CssClass="tc-manage-quiz-select"
        AutoPostBack="true"
        OnSelectedIndexChanged="ddlFilter_Changed" />
    <asp:Button ID="btnSearch" runat="server"
        CssClass="tc-manage-quiz-btn-search"
        OnClick="btnSearch_Click"
        CausesValidation="false" />
</div>

<%-- Status Chips (My Quizzes only) --%>
<asp:Panel ID="pnlStatusChips" runat="server">
    <div class="tc-manage-quiz-chips">
        <asp:LinkButton ID="btnChipAll" runat="server"
            CssClass="tc-manage-quiz-chip active"
            OnClick="btnChip_Click"
            CommandArgument=""
            CausesValidation="false"
            data-s="all">
            <%: T("All","Semua") %>
        </asp:LinkButton>
        <asp:LinkButton ID="btnChipApproved" runat="server"
            CssClass="tc-manage-quiz-chip"
            OnClick="btnChip_Click"
            CommandArgument="Approved"
            CausesValidation="false"
            data-s="approved">
            <%: T("Approved","Diluluskan") %>
        </asp:LinkButton>
        <asp:LinkButton ID="btnChipPending" runat="server"
            CssClass="tc-manage-quiz-chip"
            OnClick="btnChip_Click"
            CommandArgument="Pending"
            CausesValidation="false"
            data-s="pending">
            <%: T("Pending","Menunggu") %>
        </asp:LinkButton>
        <asp:LinkButton ID="btnChipRejected" runat="server"
            CssClass="tc-manage-quiz-chip"
            OnClick="btnChip_Click"
            CommandArgument="Rejected"
            CausesValidation="false"
            data-s="rejected">
            <%: T("Rejected","Ditolak") %>
        </asp:LinkButton>
    </div>
</asp:Panel>

<%-- Quiz Cards --%>
<asp:Panel ID="pnlQuizzes" runat="server" Visible="false">
    <div class="tc-manage-quiz-grid">
        <asp:Repeater ID="rptQuizzes" runat="server">
            <ItemTemplate>
                <div class="tc-manage-quiz-dcard">
                    <%-- Teal cover header --%>
                    <div class="tc-manage-quiz-dcard-img-wrap">
                        <div class="tc-manage-quiz-dcard-cover"></div>
                        <span class="tc-practice-quiz-status-pill tc-practice-quiz-status-<%# (Eval("status") ?? "Pending").ToString().ToLower() %>">
                            <%# HttpUtility.HtmlEncode(Eval("status") ?? "Pending") %>
                        </span>
                        <span class="tc-manage-quiz-dcard-badge tc-manage-quiz-dcard-badge-left">
                            <i class="bi bi-list-check"></i> <%# Eval("questionCount") %> Qs
                        </span>
                        <span class="tc-manage-quiz-dcard-badge tc-manage-quiz-dcard-badge-right">
                            <%# HttpUtility.HtmlEncode(Eval("language")?.ToString() ?? "") %>
                        </span>
                    </div>
                    <%-- Body: title only --%>
                    <div class="tc-manage-quiz-dcard-body">
                        <div class="tc-manage-quiz-dcard-title">
                            <%# HttpUtility.HtmlEncode(Eval("quizTitle")) %>
                        </div>
                    </div>
                    <%-- Action buttons --%>
                    <div class="tc-practice-quiz-card-actions-wrap">
                        <span class="tc-practice-quiz-hidden-data" style="display:none;"
                            data-qid='<%# Eval("quizId") %>'
                            data-title='<%# HttpUtility.HtmlAttributeEncode((Eval("quizTitle") ?? "").ToString()) %>'
                            data-lang='<%# HttpUtility.HtmlAttributeEncode((Eval("language") ?? "").ToString()) %>'
                            data-count='<%# Eval("questionCount") %>'
                            data-status='<%# HttpUtility.HtmlAttributeEncode((Eval("status") ?? "").ToString()) %>'>
                        </span>
                        <a href="#" class="tc-practice-quiz-action-view"
                            onclick="openPracticeViewModal(this.closest('.tc-practice-quiz-card-actions-wrap').querySelector('.tc-practice-quiz-hidden-data'));return false;">
                            <i class="bi bi-eye"></i> <%: T("View Quiz","Lihat Kuiz") %>
                        </a>
                        <button type="button" class="tc-practice-quiz-action-resubmit"
                            style='<%# (Eval("status") ?? "").ToString().Equals("Rejected", StringComparison.OrdinalIgnoreCase) ? "" : "display:none;" %>'
                            onclick="resubmitQuiz('<%# Eval("quizId") %>')">
                            <i class="bi bi-arrow-repeat"></i> <%: T("Resubmit","Hantar Semula") %>
                        </button>
                        <button type="button" class="tc-practice-quiz-action-delete"
                            onclick="openDeleteModal('<%# Eval("quizId") %>')">
                            <i class="bi bi-trash"></i> <%: T("Delete Quiz","Padam Kuiz") %>
                        </button>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>

<%-- Empty State --%>
<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="tc-manage-quiz-empty">
        <div style="font-size:3.5rem;opacity:.5;margin-bottom:1rem;">??</div>
        <div class="tc-manage-quiz-empty-title">
            <asp:Literal ID="litEmptyMsg" runat="server" />
        </div>
    </div>
</asp:Panel>

<%-- Practice Quiz Pending State --%>
<div id="pqPendingState" style="display:none;">
    <div style="display:flex;flex-direction:column;align-items:center;padding:3.5rem 2rem;text-align:center;">
        <div style="font-size:3.5rem;margin-bottom:1rem;opacity:.85;">?</div>
        <h2 style="font-size:1.15rem;font-weight:800;color:var(--tc-text);margin:0 0 .6rem;">
            <%: T("Verification Pending","Pengesahan Sedang Diproses") %>
        </h2>
        <p style="font-size:.88rem;color:var(--tc-muted);max-width:480px;line-height:1.65;margin:0;">
            <%: T("Your Teaching License is still under review. You will be able to create and manage Practice Quizzes once your verification has been approved.","Lesen Mengajar anda masih dalam semakan. Anda akan dapat mencipta dan mengurus Kuiz Latihan setelah pengesahan anda diluluskan.") %>
        </p>
    </div>
</div>

<%-- Unit / Level Questions --%>
<asp:Panel ID="pnlUnitLevel" runat="server" Visible="false">

    <%-- Pending License Notice (Unit/Level only) --%>
    <div id="pendingNoticeUL" class="tc-manage-quiz-pending-notice" style="display:none;">
        <div class="tc-manage-quiz-pending-notice-icon">
            <i class="bi bi-shield-exclamation"></i>
        </div>
        <div class="tc-manage-quiz-pending-notice-content">
            <div class="tc-manage-quiz-pending-notice-title">
                <%: T("Verification Pending","Pengesahan Menunggu") %>
            </div>
            <div class="tc-manage-quiz-pending-notice-msg">
                <%: T("Your Teaching License is still under review. Adding questions to Unit & Level Quizzes is temporarily unavailable until your verification has been approved.","Lesen Mengajar anda masih dalam semakan. Penambahan soalan ke Kuiz Unit & Tahap tidak tersedia buat sementara waktu sehingga pengesahan anda diluluskan.") %>
            </div>
        </div>
    </div>

    <%-- Unit Quiz Section --%>
    <div id="ulSectionUnit" style="margin-bottom:2.5rem;">
        <h3 style="font-size:1.05rem;font-weight:800;color:var(--tc-text);margin:0 0 1rem;display:flex;align-items:center;gap:8px;">
            <i class="bi bi-layers" style="color:#2563EB;"></i> <%: T("Unit Quiz Questions","Soalan Kuiz Unit") %>
        </h3>
        <asp:Literal ID="litUnitGrouped" runat="server" />
    </div>

    <%-- Level Quiz Section --%>
    <div id="ulSectionLevel">
        <h3 style="font-size:1.05rem;font-weight:800;color:var(--tc-text);margin:0 0 1rem;display:flex;align-items:center;gap:8px;">
            <i class="bi bi-trophy" style="color:#D97706;"></i> <%: T("Level Quiz Questions","Soalan Kuiz Tahap") %>
        </h3>
        <asp:Repeater ID="rptLevelQs" runat="server">
            <ItemTemplate>
                <div class="tc-manage-quiz-ulq-card">
                    <div class="tc-manage-quiz-ulq-left">
                        <div class="tc-manage-quiz-ulq-icon tc-manage-quiz-ulq-icon-level">
                            <i class="bi bi-trophy-fill"></i>
                        </div>
                        <div class="tc-manage-quiz-ulq-info">
                            <div class="tc-manage-quiz-ulq-title">
                                <%# HttpUtility.HtmlEncode(Eval("levelName")) %>
                            </div>
                        </div>
                    </div>
                    <div class="tc-manage-quiz-ulq-stats">
                        <div class="tc-manage-quiz-ulq-col tc-manage-quiz-ulq-col--overall">
                            <div class="tc-manage-quiz-ulq-col-label">
                                <%: T("Overall Approved","Diluluskan Semua") %>
                                <span class="tc-manage-quiz-info-icon" tabindex="0"
                                    data-tip="<%: T("Total approved questions available for this quiz from all teachers.","Jumlah soalan yang diluluskan tersedia untuk kuiz ini daripada semua guru.") %>">
                                    <i class="bi bi-info-circle"></i>
                                </span>
                            </div>
                            <div class="tc-manage-quiz-ulq-col-val tc-manage-quiz-val-overall">
                                <%# Eval("overallApproved") %>
                            </div>
                        </div>
                        <div class="tc-manage-quiz-ulq-col tc-manage-quiz-ulq-col--submitted">
                            <div class="tc-manage-quiz-ulq-col-label">
                                <%: T("Your Submitted","Hantar Anda") %>
                                <span class="tc-manage-quiz-info-icon" tabindex="0"
                                    data-tip="<%: T("Total questions you have submitted for this quiz, including approved, pending and rejected questions.","Jumlah soalan yang telah anda hantar untuk kuiz ini, termasuk yang diluluskan, menunggu dan ditolak.") %>">
                                    <i class="bi bi-info-circle"></i>
                                </span>
                            </div>
                            <div class="tc-manage-quiz-ulq-col-val">
                                <%# Eval("yourCount") %>
                            </div>
                        </div>
                        <div class="tc-manage-quiz-ulq-col tc-manage-quiz-ulq-col--approved">
                            <div class="tc-manage-quiz-ulq-col-label"><%: T("Approved","Diluluskan") %></div>
                            <div class="tc-manage-quiz-ulq-col-val tc-manage-quiz-val-approved">
                                <%# Eval("approvedCount") %>
                            </div>
                        </div>
                        <div class="tc-manage-quiz-ulq-col tc-manage-quiz-ulq-col--pending">
                            <div class="tc-manage-quiz-ulq-col-label"><%: T("Pending","Menunggu") %></div>
                            <div class="tc-manage-quiz-ulq-col-val tc-manage-quiz-val-pending">
                                <%# Eval("pendingCount") %>
                            </div>
                        </div>
                        <div class="tc-manage-quiz-ulq-col tc-manage-quiz-ulq-col--rejected">
                            <div class="tc-manage-quiz-ulq-col-label"><%: T("Rejected","Ditolak") %></div>
                            <div class="tc-manage-quiz-ulq-col-val tc-manage-quiz-val-rejected">
                                <%# Eval("rejectedCount") %>
                            </div>
                        </div>
                    </div>
                    <div class="tc-manage-quiz-ulq-btn-col">
                        <a href="#" class="tc-manage-quiz-ulq-btn tc-manage-quiz-ulq-btn-add"
                            onclick='openSubtopicModal("<%# Eval("quizId") %>");return false;'>
                            <i class="bi bi-plus-lg"></i> <%: T("Add Questions","Tambah Soalan") %>
                        </a>
                        <button type="button" class="tc-manage-quiz-ulq-btn"
                            onclick='openULModal("<%# Eval("quizId") %>")'>
                            <i class="bi bi-eye"></i> <%: T("View Questions","Lihat Soalan") %>
                        </button>
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

<%-- Modals --%>

<%-- Unit/Level Question Detail Modal --%>
<div id="ulModal" class="tc-manage-quiz-modal-overlay" style="display:none;"
    onclick="if(event.target===this)closeULModal()">
    <div class="tc-manage-quiz-modal" style="max-width:880px;max-height:88vh;display:flex;flex-direction:column;">
        <div class="tc-manage-quiz-modal-header"
            style="background:linear-gradient(135deg,#EFF6FF,#DBEAFE);border-bottom:1px solid #BFDBFE;">
            <h3 style="color:#1E40AF;">
                <i class="bi bi-journal-text" style="color:#2563EB;"></i>
                <%: T("Submitted Questions","Soalan Dihantar") %>
            </h3>
            <button type="button" class="tc-manage-quiz-modal-close" onclick="closeULModal()">&times;</button>
        </div>
        <div class="tc-manage-quiz-modal-body" id="ulModalBody"
            style="text-align:left;overflow-y:auto;padding:1.25rem 1.5rem;">
            <div class="tc-manage-quiz-empty"><%: T("Loading...","Memuatkan...") %></div>
        </div>
    </div>
</div>

<%-- Image Preview Modal --%>
<div id="vqImgModal" class="tc-view-quiz-img-modal" onclick="if(event.target===this)closeImgPreview()">
    <div class="tc-view-quiz-img-modal-box">
        <div class="tc-view-quiz-img-modal-hd">
            <span id="vqImgName"></span>
            <button type="button" class="tc-view-quiz-img-modal-close" onclick="closeImgPreview()">&times;</button>
        </div>
        <div class="tc-view-quiz-img-modal-body">
            <img id="vqImgPreview" src="" alt="Preview" />
        </div>
    </div>
</div>

<%-- Subtopic Selection Modal --%>
<div id="subtopicModal" class="tc-manage-quiz-modal-overlay" style="display:none;"
    onclick="if(event.target===this)closeSubtopicModal()">
    <div class="tc-manage-quiz-modal" style="max-width:460px;">
        <div class="tc-manage-quiz-modal-header">
            <div>
                <h3><%: T("Select Subtopic","Pilih Subtopik") %></h3>
                <p style="font-size:.78rem;color:var(--tc-muted);margin:3px 0 0;">
                    <%: T("Choose the subtopic for the questions you want to add.","Pilih subtopik untuk soalan yang ingin ditambah.") %>
                </p>
            </div>
            <button type="button" class="tc-manage-quiz-modal-close" onclick="closeSubtopicModal()">&times;</button>
        </div>
        <div class="tc-manage-quiz-modal-body" style="text-align:left;padding:1.25rem 1.5rem;">
            <div id="stScopeInfo"
                style="font-size:.84rem;font-weight:600;color:var(--tc-text);margin-bottom:1rem;padding:.6rem .85rem;background:#F9FAFB;border-radius:8px;border:1px solid #E5E7EB;">
            </div>
            <label style="font-size:.8rem;font-weight:700;color:var(--tc-text);display:block;margin-bottom:5px;">
                <%: T("Subtopic","Subtopik") %> *
            </label>
            <select id="stDropdown" class="tc-manage-quiz-select" style="width:100%;height:42px;">
                <option value=""><%: T("― Select Subtopic ―","― Pilih Subtopik ―") %></option>
            </select>
        </div>
        <div class="tc-manage-quiz-modal-footer">
            <button type="button" class="tc-manage-quiz-btn-cancel" onclick="closeSubtopicModal()">
                <%: T("Cancel","Batal") %>
            </button>
            <button type="button" id="stContinueBtn" class="tc-manage-quiz-btn-create"
                style="box-shadow:none;opacity:.5;pointer-events:none;" onclick="goToCreatePage()">
                <%: T("Continue","Teruskan") %>
            </button>
        </div>
    </div>
</div>

<%-- Discover Quizzes --%>
<asp:Panel ID="pnlDiscover" runat="server" Visible="false">
    <div class="tc-manage-quiz-carousel-wrap">
        <button type="button" class="tc-manage-quiz-arrow tc-manage-quiz-arrow-left" onclick="scrollDiscover(-1)">
            <i class="bi bi-chevron-left"></i>
        </button>
        <div class="tc-manage-quiz-carousel" id="discoverCarousel">
            <asp:Repeater ID="rptDiscover" runat="server">
                <ItemTemplate>
                    <div class="tc-manage-quiz-dcard">
                        <div class="tc-manage-quiz-dcard-img-wrap">
                            <div class="tc-manage-quiz-dcard-cover"></div>
                            <span class="tc-manage-quiz-dcard-badge tc-manage-quiz-dcard-badge-left">
                                <i class="bi bi-list-check"></i> <%# Eval("questionCount") %> Qs
                            </span>
                            <span class="tc-manage-quiz-dcard-badge tc-manage-quiz-dcard-badge-right">
                                <%# HttpUtility.HtmlEncode(Eval("language")?.ToString() ?? "") %>
                            </span>
                        </div>
                        <div class="tc-manage-quiz-dcard-body">
                            <div class="tc-manage-quiz-dcard-title">
                                <%# HttpUtility.HtmlEncode(Eval("quizTitle")) %>
                            </div>
                            <div class="tc-manage-quiz-dcard-teacher">
                                <div class="tc-manage-quiz-dcard-teacher-avatar">
                                    <i class="bi bi-person-fill"></i>
                                </div>
                                <span class="tc-manage-quiz-dcard-teacher-name">
                                    <%# HttpUtility.HtmlEncode(Eval("teacherName")) %>
                                </span>
                            </div>
                        </div>
                        <div style="padding:.6rem 1.2rem .8rem;">
                            <span class="tc-delete-quiz-hidden-data" style="display:none;"
                                data-qid='<%# Eval("quizId") %>'
                                data-title='<%# HttpUtility.HtmlAttributeEncode(Eval("quizTitle").ToString()) %>'
                                data-teacher='<%# HttpUtility.HtmlAttributeEncode(Eval("teacherName").ToString()) %>'
                                data-lang='<%# HttpUtility.HtmlAttributeEncode(Eval("language")?.ToString() ?? "") %>'
                                data-count='<%# Eval("questionCount") %>'>
                            </span>
                            <a href="#" class="tc-practice-quiz-btn-view"
                                onclick="openDiscoverModal(this.previousElementSibling);return false;">
                                <i class="bi bi-eye"></i> View Quiz
                            </a>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
        <button type="button" class="tc-manage-quiz-arrow tc-manage-quiz-arrow-right" onclick="scrollDiscover(1)">
            <i class="bi bi-chevron-right"></i>
        </button>
    </div>
</asp:Panel>

<asp:Panel ID="pnlDiscoverEmpty" runat="server" Visible="false">
    <div class="tc-manage-quiz-empty">
        <div style="font-size:3rem;opacity:.4;margin-bottom:.75rem;">??</div>
        <div class="tc-manage-quiz-empty-title">
            <%: T("No shared quizzes available.","Tiada kuiz kongsi tersedia.") %>
        </div>
    </div>
</asp:Panel>

<asp:HiddenField ID="hidActiveTab" runat="server" Value="mine" />
<asp:HiddenField ID="hidTeacherLicenseStatus" runat="server" Value="" />

<%-- Practice Quiz View Modal --%>
<div id="pqViewModal" class="tc-practice-quiz-overlay"
    onclick="if(event.target===this)closePracticeViewModal()">
    <div class="tc-practice-quiz-modal">
        <div class="tc-practice-quiz-modal-header">
            <div class="tc-practice-quiz-header-main">
                <div class="tc-practice-quiz-header-title" id="pqViewTitle"></div>
                <div class="tc-practice-quiz-header-meta" id="pqViewMeta"></div>
            </div>
            <button type="button" class="tc-practice-quiz-close-btn"
                onclick="closePracticeViewModal()" title="Close">
                <i class="bi bi-x-lg"></i>
            </button>
        </div>
        <div class="tc-practice-quiz-modal-body" id="pqViewBody">
            <div class="tc-manage-quiz-empty">
                <div style="font-size:2rem;opacity:.4;">?</div>
                <div class="tc-manage-quiz-empty-title" style="margin-top:.5rem;">
                    <%: T("Loading...","Memuatkan...") %>
                </div>
            </div>
        </div>
    </div>
</div>

<%-- Discover Quiz View Modal --%>
<div id="dqModal" class="tc-delete-quiz-overlay"
    onclick="if(event.target===this)closeDiscoverModal()">
    <div class="tc-delete-quiz-modal">
        <div class="tc-delete-quiz-modal-header" id="dqHeader">
            <div class="tc-delete-quiz-header-main">
                <div class="tc-delete-quiz-header-title" id="dqTitle"></div>
                <div class="tc-delete-quiz-header-meta" id="dqMeta"></div>
            </div>
            <button type="button" class="tc-delete-quiz-close-btn"
                onclick="closeDiscoverModal()" title="Close">
                <i class="bi bi-x-lg"></i>
            </button>
        </div>
        <div class="tc-delete-quiz-modal-body" id="dqBody">
            <div class="tc-manage-quiz-empty">
                <div style="font-size:2rem;opacity:.4;">?</div>
                <div class="tc-manage-quiz-empty-title" style="margin-top:.5rem;">
                    <%: T("Loading...","Memuatkan...") %>
                </div>
            </div>
        </div>
    </div>
</div>

<%-- Practice Quiz Selection Modal --%>
<div id="practiceModal" class="tc-manage-quiz-modal-overlay" style="display:none;"
    onclick="if(event.target===this)closePracticeModal()">
    <div class="tc-manage-quiz-modal" style="max-width:460px;">
        <div class="tc-manage-quiz-modal-header">
            <div>
                <h3><%: T("Create Practice Quiz","Cipta Kuiz Latihan") %></h3>
                <p style="font-size:.78rem;color:var(--tc-muted);margin:3px 0 0;">
                    <%: T("Select the learning area for this practice quiz.","Pilih kawasan pembelajaran untuk kuiz latihan ini.") %>
                </p>
            </div>
            <button type="button" class="tc-manage-quiz-modal-close" onclick="closePracticeModal()">&times;</button>
        </div>
        <div class="tc-manage-quiz-modal-body" style="text-align:left;padding:1.25rem 1.5rem;">
            <div style="margin-bottom:1rem;">
                <label style="font-size:.8rem;font-weight:700;color:var(--tc-text);display:block;margin-bottom:5px;">
                    <%: T("Level","Tahap") %> *
                </label>
                <select id="pqLevel" class="tc-manage-quiz-select" style="width:100%;height:42px;"
                    onchange="pqOnLevelChange(this.value)">
                    <option value=""><%: T("― Select Level ―","― Pilih Tahap ―") %></option>
                </select>
            </div>
            <div style="margin-bottom:1rem;">
                <label style="font-size:.8rem;font-weight:700;color:var(--tc-text);display:block;margin-bottom:5px;">
                    <%: T("Unit","Unit") %> *
                </label>
                <select id="pqUnit" class="tc-manage-quiz-select" style="width:100%;height:42px;"
                    onchange="pqOnUnitChange(this.value)" disabled>
                    <option value=""><%: T("― Select Unit ―","― Pilih Unit ―") %></option>
                </select>
            </div>
            <div style="margin-bottom:1rem;">
                <label style="font-size:.8rem;font-weight:700;color:var(--tc-text);display:block;margin-bottom:5px;">
                    <%: T("Subtopic","Subtopik") %> *
                </label>
                <select id="pqSubtopic" class="tc-manage-quiz-select" style="width:100%;height:42px;"
                    onchange="pqOnSubtopicChange(this.value)" disabled>
                    <option value=""><%: T("― Select Subtopic ―","― Pilih Subtopik ―") %></option>
                </select>
            </div>
            <div style="margin-bottom:.25rem;">
                <label style="font-size:.8rem;font-weight:700;color:var(--tc-text);display:block;margin-bottom:5px;">
                    <%: T("Language","Bahasa") %> *
                </label>
                <select id="pqLanguage" class="tc-manage-quiz-select" style="width:100%;height:42px;"
                    onchange="pqUpdateContinue()">
                    <option value=""><%: T("― Select Language ―","― Pilih Bahasa ―") %></option>
                    <option value="EN">English</option>
                    <option value="BM">Bahasa Melayu</option>
                </select>
            </div>
        </div>
        <div class="tc-manage-quiz-modal-footer">
            <button type="button" class="tc-manage-quiz-btn-cancel" onclick="closePracticeModal()">
                <%: T("Cancel","Batal") %>
            </button>
            <button type="button" id="pqContinueBtn" class="tc-manage-quiz-btn-create"
                style="box-shadow:none;opacity:.5;pointer-events:none;" onclick="pqContinue()">
                <%: T("Continue","Teruskan") %>
            </button>
        </div>
    </div>
</div>

<%-- Create Quiz Setup Modal --%>
<div id="createModal" class="tc-manage-quiz-modal-overlay" style="display:none;">
    <div class="tc-manage-quiz-modal" style="max-width:520px;">
        <div class="tc-manage-quiz-modal-header">
            <div>
                <h3><%: T("Create Quiz","Cipta Kuiz") %></h3>
                <p style="font-size:.8rem;color:var(--tc-muted);margin:2px 0 0;">
                    <%: T("Choose your quiz setup before building questions.","Pilih tetapan kuiz sebelum membina soalan.") %>
                </p>
            </div>
            <button type="button" class="tc-manage-quiz-modal-close"
                onclick="document.getElementById('createModal').style.display='none'">&times;</button>
        </div>
        <div class="tc-manage-quiz-modal-body" style="text-align:left;padding:1.25rem 1.5rem;">
            <div style="margin-bottom:1rem;">
                <label style="font-size:.8rem;font-weight:600;color:var(--tc-text);display:block;margin-bottom:5px;">
                    <%: T("Quiz Type","Jenis Kuiz") %> *
                </label>
                <asp:DropDownList ID="ddlCreateType" runat="server"
                    CssClass="tc-manage-quiz-select" style="width:100%;"
                    AutoPostBack="true"
                    OnSelectedIndexChanged="ddlCreateType_Changed" />
                <div class="tc-manage-quiz-val-msg" id="valType"></div>
            </div>
            <asp:Panel ID="pnlCreateLevel" runat="server" Visible="false">
                <div style="margin-bottom:1rem;">
                    <label style="font-size:.8rem;font-weight:600;color:var(--tc-text);display:block;margin-bottom:5px;">
                        <%: T("Level","Tahap") %> *
                    </label>
                    <asp:DropDownList ID="ddlCreateLevel" runat="server"
                        CssClass="tc-manage-quiz-select" style="width:100%;"
                        AutoPostBack="true"
                        OnSelectedIndexChanged="ddlCreateLevel_Changed" />
                    <div class="tc-manage-quiz-val-msg" id="valLevel"></div>
                </div>
            </asp:Panel>
            <asp:Panel ID="pnlCreateUnit" runat="server" Visible="false">
                <div style="margin-bottom:1rem;">
                    <label style="font-size:.8rem;font-weight:600;color:var(--tc-text);display:block;margin-bottom:5px;">
                        <%: T("Unit","Unit") %> *
                    </label>
                    <asp:DropDownList ID="ddlCreateUnit" runat="server"
                        CssClass="tc-manage-quiz-select" style="width:100%;"
                        AutoPostBack="true"
                        OnSelectedIndexChanged="ddlCreateUnit_Changed" />
                    <div class="tc-manage-quiz-val-msg" id="valUnit"></div>
                </div>
            </asp:Panel>
            <asp:Panel ID="pnlCreateSubtopic" runat="server" Visible="false">
                <div style="margin-bottom:1rem;">
                    <label style="font-size:.8rem;font-weight:600;color:var(--tc-text);display:block;margin-bottom:5px;">
                        <%: T("Subtopic","Subtopik") %> *
                    </label>
                    <asp:DropDownList ID="ddlCreateSubtopic" runat="server"
                        CssClass="tc-manage-quiz-select" style="width:100%;" />
                    <div class="tc-manage-quiz-val-msg" id="valSubtopic"></div>
                </div>
            </asp:Panel>
            <asp:Panel ID="pnlCreateLang" runat="server" Visible="false">
                <div style="margin-bottom:1rem;">
                    <label style="font-size:.8rem;font-weight:600;color:var(--tc-text);display:block;margin-bottom:5px;">
                        <%: T("Language","Bahasa") %> *
                    </label>
                    <asp:DropDownList ID="ddlCreateLang" runat="server"
                        CssClass="tc-manage-quiz-select" style="width:100%;">
                        <asp:ListItem Value="" Text="― Select ―" />
                        <asp:ListItem Value="EN" Text="English" />
                        <asp:ListItem Value="BM" Text="Bahasa Melayu" />
                    </asp:DropDownList>
                    <div class="tc-manage-quiz-val-msg" id="valLang"></div>
                </div>
            </asp:Panel>
        </div>
        <div class="tc-manage-quiz-modal-footer">
            <button type="button" class="tc-manage-quiz-btn-cancel"
                onclick="document.getElementById('createModal').style.display='none'">
                <%: T("Cancel","Batal") %>
            </button>
            <asp:Button ID="btnContinue" runat="server"
                CssClass="tc-manage-quiz-btn-create" style="box-shadow:none;"
                Text="Continue"
                OnClick="btnContinue_Click"
                CausesValidation="false" />
        </div>
    </div>
</div>
<asp:HiddenField ID="hidShowCreateModal" runat="server" Value="" />

<%-- Delete Modal --%>
<div id="deleteModal" class="tc-manage-quiz-modal-overlay" style="display:none;">
    <div class="tc-manage-quiz-modal">
        <div class="tc-manage-quiz-modal-header">
            <h3><%: T("Delete Quiz","Padam Kuiz") %></h3>
            <button type="button" class="tc-manage-quiz-modal-close" onclick="closeDeleteModal()">&times;</button>
        </div>
        <div class="tc-manage-quiz-modal-body">
            <p><%: T("Are you sure you want to delete this quiz? This action cannot be undone.","Adakah anda pasti mahu memadam kuiz ini? Tindakan ini tidak boleh dibatalkan.") %></p>
        </div>
        <div class="tc-manage-quiz-modal-footer">
            <button type="button" class="tc-manage-quiz-btn-cancel" onclick="closeDeleteModal()">
                <%: T("Cancel","Batal") %>
            </button>
            <asp:Button ID="btnConfirmDelete" runat="server"
                CssClass="tc-manage-quiz-btn-danger"
                OnClick="btnConfirmDelete_Click"
                CausesValidation="false" />
        </div>
    </div>
</div>

<%-- Resubmit Confirmation Modal --%>
<div id="resubmitModal" class="tc-manage-quiz-modal-overlay" style="display:none;"
    onclick="if(event.target===this)closeResubmitModal()">
    <div class="tc-manage-quiz-modal" style="max-width:440px;">
        <div class="tc-resubmit-modal-header">
            <div class="tc-resubmit-modal-icon-wrap">
                <i class="bi bi-arrow-repeat"></i>
            </div>
            <div class="tc-resubmit-modal-header-text">
                <h3 class="tc-resubmit-modal-title"><%: T("Resubmit Quiz","Hantar Semula Kuiz") %></h3>
            </div>
            <button type="button" class="tc-manage-quiz-modal-close" onclick="closeResubmitModal()">&times;</button>
        </div>
        <div class="tc-resubmit-modal-body">
            <p class="tc-resubmit-modal-msg">
                <%: T("Are you sure you want to resubmit this quiz for review?","Adakah anda pasti mahu menghantar semula kuiz ini untuk semakan?") %>
            </p>
            <p class="tc-resubmit-modal-sub">
                <%: T("The quiz and all questions inside it will be changed to Pending.","Kuiz dan semua soalan di dalamnya akan ditukar kepada Menunggu.") %>
            </p>
        </div>
        <div class="tc-resubmit-modal-footer">
            <button type="button" class="tc-resubmit-modal-btn-cancel" onclick="closeResubmitModal()">
                <%: T("Cancel","Batal") %>
            </button>
            <button type="button" class="tc-resubmit-modal-btn-confirm" onclick="confirmResubmit()">
                <i class="bi bi-arrow-repeat"></i> <%: T("Confirm Resubmit","Sahkan Hantar Semula") %>
            </button>
        </div>
    </div>
</div>

<asp:HiddenField ID="hidDeleteId" runat="server" Value="" />
<asp:HiddenField ID="hidToast" runat="server" Value="" />
<div id="mqToast" class="tc-manage-quiz-toast-container"></div>

</asp:Panel>
</asp:Content>

<%-- Scripts --%>
<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
    function scrollCarousel(dir) {
        var c = document.getElementById('quizCarousel');
        if (c) c.scrollBy({ left: dir * 320, behavior: 'smooth' });
    }
    function scrollDiscover(dir) {
        var c = document.getElementById('discoverCarousel');
        if (c) c.scrollBy({ left: dir * 320, behavior: 'smooth' });
    }
    function openDeleteModal(id) {
        document.getElementById('<%=hidDeleteId.ClientID%>').value = id;
        document.getElementById('deleteModal').style.display = 'flex';
    }
    function closeDeleteModal() {
        document.getElementById('deleteModal').style.display = 'none';
    }
    var _resubmitQuizId = '';
    function resubmitQuiz(quizId) {
        _resubmitQuizId = quizId;
        document.getElementById('resubmitModal').style.display = 'flex';
    }
    function closeResubmitModal() {
        document.getElementById('resubmitModal').style.display = 'none';
        _resubmitQuizId = '';
    }
    function confirmResubmit() {
        if (!_resubmitQuizId) return;
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'manageQuiz.aspx?handler=resubmit&quizId=' + encodeURIComponent(_resubmitQuizId), true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                closeResubmitModal();
                if (xhr.status === 200) {
                    showToast('<%: T("Quiz resubmitted for review.","Kuiz dihantar semula untuk semakan.") %>');
                    setTimeout(function () { location.reload(); }, 1200);
                } else {
                    alert('Error resubmitting quiz.');
                }
            }
        };
        xhr.send('');
    }

    /* -- Practice Quiz Selection Modal -- */
    function openPracticeModal() {
        var modal = document.getElementById('practiceModal');
        var lvDd = document.getElementById('pqLevel');
        // Load levels if not already loaded
        if (lvDd.options.length <= 1) {
            lvDd.innerHTML = '<option value="">Loading...</option>';
            var xhr = new XMLHttpRequest();
            xhr.open('GET', 'manageQuiz.aspx?handler=pqlevels', true);
            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    try {
                        var data = JSON.parse(xhr.responseText);
                        lvDd.innerHTML = '<option value="">― <%: T("Select Level","Pilih Tahap") %> ―</option>';
                        for (var i = 0; i < data.length; i++) {
                            var o = document.createElement('option'); o.value = data[i].id; o.textContent = data[i].name; lvDd.appendChild(o);
                        }
                    } catch (e) { lvDd.innerHTML = '<option value="">Error</option>'; }
                }
            };
            xhr.send();
        }
        // Reset Unit, Subtopic, and Language
        var unDd = document.getElementById('pqUnit');
        var stDd = document.getElementById('pqSubtopic');
        unDd.innerHTML = '<option value="">― <%: T("Select Unit","Pilih Unit") %> ―</option>';
        unDd.disabled = true;
        stDd.innerHTML = '<option value="">― <%: T("Select Subtopic","Pilih Subtopik") %> ―</option>';
        stDd.disabled = true;
        document.getElementById('pqLanguage').value = '';
        pqUpdateContinue();
        modal.style.display = 'flex';
    }
    function closePracticeModal() {
        document.getElementById('practiceModal').style.display = 'none';
        document.getElementById('pqLevel').value = '';
        document.getElementById('pqUnit').innerHTML = '<option value="">― <%: T("Select Unit","Pilih Unit") %> ―</option>';
        document.getElementById('pqUnit').disabled = true;
        document.getElementById('pqSubtopic').innerHTML = '<option value="">― <%: T("Select Subtopic","Pilih Subtopik") %> ―</option>';
        document.getElementById('pqSubtopic').disabled = true;
        document.getElementById('pqLanguage').value = '';
        pqUpdateContinue();
    }
    function pqOnLevelChange(levelId) {
        var unDd = document.getElementById('pqUnit');
        var stDd = document.getElementById('pqSubtopic');
        stDd.innerHTML = '<option value="">― <%: T("Select Subtopic","Pilih Subtopik") %> ―</option>';
        stDd.disabled = true;
        unDd.innerHTML = '<option value="">― <%: T("Select Unit","Pilih Unit") %> ―</option>';
        pqUpdateContinue();
        if (!levelId) { unDd.disabled = true; return; }
        unDd.innerHTML = '<option value="">Loading...</option>';
        unDd.disabled = true;
        var xhr = new XMLHttpRequest();
        xhr.open('GET', 'manageQuiz.aspx?handler=pqunits&levelId=' + encodeURIComponent(levelId), true);
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4 && xhr.status === 200) {
                try {
                    var data = JSON.parse(xhr.responseText);
                    unDd.innerHTML = '<option value="">― <%: T("Select Unit","Pilih Unit") %> ―</option>';
                    for (var i = 0; i < data.length; i++) {
                        var o = document.createElement('option'); o.value = data[i].id; o.textContent = data[i].name; unDd.appendChild(o);
                    }
                    unDd.disabled = false;
                } catch (e) { unDd.innerHTML = '<option value="">Error</option>'; unDd.disabled = false; }
            }
        };
        xhr.send();
    }
    function pqOnUnitChange(unitId) {
        var stDd = document.getElementById('pqSubtopic');
        stDd.innerHTML = '<option value="">― <%: T("Select Subtopic","Pilih Subtopik") %> ―</option>';
        stDd.disabled = true;
        pqUpdateContinue();
        if (!unitId) return;
        stDd.innerHTML = '<option value="">Loading...</option>';
        var xhr = new XMLHttpRequest();
        xhr.open('GET', 'manageQuiz.aspx?handler=pqsubtopics&unitId=' + encodeURIComponent(unitId), true);
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4 && xhr.status === 200) {
                try {
                    var data = JSON.parse(xhr.responseText);
                    stDd.innerHTML = '<option value="">― <%: T("Select Subtopic","Pilih Subtopik") %> ―</option>';
                    for (var i = 0; i < data.length; i++) {
                        var o = document.createElement('option'); o.value = data[i].id; o.textContent = data[i].name; stDd.appendChild(o);
                    }
                    stDd.disabled = false;
                } catch (e) { stDd.innerHTML = '<option value="">Error</option>'; stDd.disabled = false; }
            }
        };
        xhr.send();
    }
    function pqOnSubtopicChange(val) { pqUpdateContinue(); }
    function pqUpdateContinue() {
        var btn = document.getElementById('pqContinueBtn');
        var lv = document.getElementById('pqLevel').value;
        var un = document.getElementById('pqUnit').value;
        var st = document.getElementById('pqSubtopic').value;
        var lg = document.getElementById('pqLanguage').value;
        var ok = (lv && un && st && lg);
        btn.style.opacity = ok ? '1' : '.5';
        btn.style.pointerEvents = ok ? 'auto' : 'none';
    }
    function pqContinue() {
        var lv = document.getElementById('pqLevel').value;
        var un = document.getElementById('pqUnit').value;
        var st = document.getElementById('pqSubtopic').value;
        var lg = document.getElementById('pqLanguage').value;
        if (!lv || !un || !st || !lg) return;
        window.location.href = 'createPracticeQuiz.aspx?levelId=' + encodeURIComponent(lv) + '&unitId=' + encodeURIComponent(un) + '&subtopicId=' + encodeURIComponent(st) + '&language=' + encodeURIComponent(lg);
    }
    function openULModal(quizId) {
        var modal = document.getElementById('ulModal'); var body = document.getElementById('ulModalBody');
        body.innerHTML = '<div class="tc-manage-quiz-empty">Loading...</div>'; modal.style.display = 'flex';
        var xhr = new XMLHttpRequest();
        xhr.open('GET', 'manageQuiz.aspx?handler=ulquestions&quizId=' + encodeURIComponent(quizId), true);
        xhr.onreadystatechange = function () { if (xhr.readyState === 4) { body.innerHTML = xhr.status === 200 ? xhr.responseText : '<div class="tc-manage-quiz-empty">Error</div>'; } };
        xhr.send();
    }
    function closeULModal() { document.getElementById('ulModal').style.display = 'none'; }
    function toggleVQ(el) { var card = el.parentElement; card.classList.toggle('tc-view-quiz-expanded'); }
    function openImgPreview(url) { var m = document.getElementById('vqImgModal'); document.getElementById('vqImgPreview').src = url; document.getElementById('vqImgName').textContent = url.split('/').pop(); m.classList.add('active'); }
    function closeImgPreview() { document.getElementById('vqImgModal').classList.remove('active'); }
    var _stQuizId = '';
    function openSubtopicModal(quizId) {
        _stQuizId = quizId;
        var modal = document.getElementById('subtopicModal');
        var dd = document.getElementById('stDropdown');
        var info = document.getElementById('stScopeInfo');
        var btn = document.getElementById('stContinueBtn');
        dd.innerHTML = '<option value="">Loading...</option>';
        info.textContent = 'Loading...';
        btn.style.opacity = '.5'; btn.style.pointerEvents = 'none';
        modal.style.display = 'flex';
        var xhr = new XMLHttpRequest();
        xhr.open('GET', 'manageQuiz.aspx?handler=subtopics&quizId=' + encodeURIComponent(quizId), true);
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4 && xhr.status === 200) {
                try {
                    var data = JSON.parse(xhr.responseText);
                    info.textContent = data.quizType + ' \u2014 ' + data.scopeName;
                    dd.innerHTML = '<option value="">― <%: T("Select Subtopic","Pilih Subtopik") %> ―</option>';
                    for (var i = 0; i < data.subtopics.length; i++) {
                        var o = document.createElement('option'); o.value = data.subtopics[i].id; o.textContent = data.subtopics[i].name; dd.appendChild(o);
                    }
                } catch (e) { info.textContent = 'Error'; dd.innerHTML = '<option value="">Error</option>'; }
            }
        };
        xhr.send();
        dd.onchange = function () {
            if (this.value) { btn.style.opacity = '1'; btn.style.pointerEvents = 'auto'; }
            else { btn.style.opacity = '.5'; btn.style.pointerEvents = 'none'; }
        };
    }
    function closeSubtopicModal() { document.getElementById('subtopicModal').style.display = 'none'; _stQuizId = ''; }
    function goToCreatePage() {
        var st = document.getElementById('stDropdown').value;
        if (!st || !_stQuizId) return;
        window.location.href = 'createUnitLevelQuiz.aspx?quizId=' + encodeURIComponent(_stQuizId) + '&subtopicId=' + encodeURIComponent(st);
    }
    function filterUL(mode, btn) {
        var u = document.getElementById('ulSectionUnit'), l = document.getElementById('ulSectionLevel');
        if (u) u.style.display = (mode === 'level' ? 'none' : '');
        if (l) l.style.display = (mode === 'unit' ? 'none' : '');
        var btns = btn.parentElement.querySelectorAll('.tc-manage-quiz-seg-btn');
        for (var i = 0; i < btns.length; i++) btns[i].classList.remove('tc-manage-quiz-seg-active');
        btn.classList.add('tc-manage-quiz-seg-active');
    }
    function showToast(msg) { var c = document.getElementById('mqToast'), t = document.createElement('div'); t.className = 'tc-manage-quiz-toast'; t.innerHTML = '<i class="bi bi-check-circle-fill"></i> ' + msg; c.appendChild(t); setTimeout(function () { t.classList.add('tc-manage-quiz-toast-out'); }, 3e3); setTimeout(function () { t.remove(); }, 3500); }

    /* -- Discover Quiz View Modal -- */
    function openDiscoverModal(el) {
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
        body.innerHTML = '<div class="tc-manage-quiz-empty"><div style="font-size:2rem;opacity:.4;">?</div><div class="tc-manage-quiz-empty-title" style="margin-top:.5rem;">Loading questions...</div></div>';
        overlay.classList.add('open');
        document.body.style.overflow = 'hidden';

        // Fetch questions and apply single-language transform
        var xhr = new XMLHttpRequest();
        xhr.open('GET', 'manageQuiz.aspx?handler=discoverquiz&quizId=' + encodeURIComponent(quizId), true);
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                body.innerHTML = xhr.status === 200
                    ? transformToSingleLang(xhr.responseText, lang)
                    : '<div class="tc-manage-quiz-empty"><div class="tc-manage-quiz-empty-title">Could not load questions. Please try again.</div></div>';
            }
        };
        xhr.send();
    }
    function closeDiscoverModal() {
        var overlay = document.getElementById('dqModal');
        overlay.classList.remove('open');
        document.body.style.overflow = '';
    }
    function escHtml(str) {
        var d = document.createElement('div');
        d.textContent = str;
        return d.innerHTML;
    }

    /* -- Practice Quiz View Modal -- */
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

        body.innerHTML = '<div class="tc-manage-quiz-empty"><div style="font-size:2rem;opacity:.4;">?</div><div class="tc-manage-quiz-empty-title" style="margin-top:.5rem;">Loading questions...</div></div>';
        overlay.classList.add('open');
        document.body.style.overflow = 'hidden';

        var xhr = new XMLHttpRequest();
        xhr.open('GET', 'manageQuiz.aspx?handler=discoverquiz&quizId=' + encodeURIComponent(quizId), true);
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                body.innerHTML = xhr.status === 200
                    ? transformToSingleLang(xhr.responseText, lang)
                    : '<div class="tc-manage-quiz-empty"><div class="tc-manage-quiz-empty-title">Could not load questions. Please try again.</div></div>';
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
     *   tc-view-quiz-card-hd:  Q# | diffBadge | chevron
     *   tc-view-quiz-card-body:
     *     tc-view-quiz-format-row
     *     tc-view-quiz-cols > [tc-view-quiz-col(EN), tc-view-quiz-col(BM)]    ? col contains: question, options, explanations
     *     tc-view-quiz-img-row  (outside tc-view-quiz-cols, at end of body)
     *
     * Output per card:
     *   tc-practice-quiz-card-hd:  Q#  [flex-1]  diffBadge[ml-auto]  chevron
     *   tc-view-quiz-card-body:
     *     tc-view-quiz-format-row
     *     question text   (full width)
     *     tc-view-quiz-img-row      (image right after question, if present)
     *     options         (full width)
     *     correct expl    (full width)
     *     wrong expl      (full width)
     */
    function transformToSingleLang(html, quizLang) {
        var isBM = (quizLang === 'BM');

        // Use a temporary container to parse the HTML safely
        var tmp = document.createElement('div');
        tmp.innerHTML = html;

        var cards = tmp.querySelectorAll('.tc-view-quiz-card');
        if (!cards.length) return html; // nothing to transform

        cards.forEach(function (card) {
            /* -- 1. Rebuild card header -- */
            var oldHd = card.querySelector('.tc-view-quiz-card-hd');
            if (oldHd) {
                var numEl    = oldHd.querySelector('.tc-view-quiz-card-num');
                var badges   = oldHd.querySelectorAll('.tc-view-quiz-badge');
                var chevron  = oldHd.querySelector('.tc-view-quiz-chevron');
                var numText  = numEl ? numEl.textContent : '';
                var diffBadgeClass = '';
                var diffBadgeText  = '';
                if (badges.length > 0) {
                    diffBadgeClass = badges[0].className;
                    diffBadgeText  = badges[0].textContent.trim();
                }
                var chevronClass = chevron ? chevron.className : 'bi bi-chevron-down tc-view-quiz-chevron';

                var newHd = document.createElement('div');
                newHd.className = 'tc-practice-quiz-card-hd';
                newHd.setAttribute('onclick', 'toggleVQ(this)');
                newHd.innerHTML =
                    '<span class="tc-view-quiz-card-num">' + escHtml(numText) + '</span>' +
                    (diffBadgeText ? '<span class="' + escHtml(diffBadgeClass) + ' tc-practice-quiz-diff-badge">' + escHtml(diffBadgeText) + '</span>' : '') +
                    '<i class="' + escHtml(chevronClass) + '"></i>';

                oldHd.parentNode.replaceChild(newHd, oldHd);
            }

            /* -- 2. Extract content from the matching language column -- */
            var body = card.querySelector('.tc-view-quiz-card-body');
            if (!body) return;

            var formatRow = body.querySelector('.tc-view-quiz-format-row');
            var cols      = body.querySelector('.tc-view-quiz-cols');
            var imgRow    = body.querySelector('.tc-view-quiz-img-row');  // sits outside tc-view-quiz-cols

            if (!cols) return; // nothing to transform

            var colDivs = cols.querySelectorAll('.tc-view-quiz-col');
            var keepIndex = isBM ? 1 : 0;
            if (colDivs.length <= keepIndex) keepIndex = 0;
            var targetCol = colDivs[keepIndex];
            if (!targetCol) return;

            // Remove language heading inside the column
            var colHd = targetCol.querySelector('.tc-view-quiz-col-hd');
            if (colHd) colHd.remove();

            // Collect ordered content: question, options/dd, correct-expl, wrong-expl
            var questionEl  = targetCol.querySelector('.tc-view-quiz-question');
            var optionsEl   = targetCol.querySelector('.tc-view-quiz-options');         // MCQ/TF/MS
            var ddSection   = targetCol.querySelector('.tc-view-quiz-dd-section');      // Drag & Drop
            var ddOrder     = targetCol.querySelector('.tc-view-quiz-dd-order');
            var explCorrect = targetCol.querySelector('.tc-view-quiz-expl-correct');
            var explWrong   = targetCol.querySelector('.tc-view-quiz-expl-wrong');

            // Build new body content in order:
            // format-row → question → image → options → correct-expl → wrong-expl
            var newBody = document.createElement('div');
            newBody.className = 'tc-view-quiz-card-body';

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

    window.addEventListener('load', function () {
        var h = document.getElementById('<%=hidToast.ClientID%>');
        if (h && h.value) { showToast(h.value); h.value = ''; }
        var cm = document.getElementById('<%=hidShowCreateModal.ClientID%>');
        if (cm && cm.value === '1') { document.getElementById('createModal').style.display = 'flex'; cm.value = ''; }
        // Show/hide segmented filter and search bar based on active tab
        var activeTab = document.getElementById('<%=hidActiveTab.ClientID%>');
        var seg = document.getElementById('ulSegFilter'); var fb = document.getElementById('mqFilterBar');
        if (activeTab && activeTab.value === 'unitlevel') { if (seg) seg.style.display = ''; if (fb) fb.style.display = 'none'; }
        else { if (seg) seg.style.display = 'none'; if (fb) fb.style.display = ''; }
        // Pending License restrictions
        var licStatus = document.getElementById('<%=hidTeacherLicenseStatus.ClientID%>');
        if (licStatus && licStatus.value === 'Pending') {
            var tipText = '<%: T("Adding questions is unavailable while your Teaching License verification is pending.","Penambahan soalan tidak tersedia semasa pengesahan Lesen Mengajar anda masih menunggu.") %>';
            // 1. Unit/Level tab: show notice + disable Add buttons
            var noticeUL = document.getElementById('pendingNoticeUL'); if (noticeUL) noticeUL.style.display = 'flex';
            var addBtns = document.querySelectorAll('.tc-manage-quiz-ulq-btn-add');
            for (var i = 0; i < addBtns.length; i++) {
                addBtns[i].classList.add('tc-manage-quiz-btn-disabled');
                addBtns[i].removeAttribute('onclick');
                addBtns[i].setAttribute('title', tipText);
                addBtns[i].href = 'javascript:void(0)';
            }
            // 2. Practice Quizzes tab: hide cards, show pending state, disable Create button
            var pqGrid = document.querySelector('#<%=pnlQuizzes.ClientID%>'); if (pqGrid) pqGrid.style.display = 'none';
            var pqEmpty = document.querySelector('#<%=pnlEmpty.ClientID%>'); if (pqEmpty) pqEmpty.style.display = 'none';
            var pqPending = document.getElementById('pqPendingState');
            if (pqPending) {
                if (activeTab && activeTab.value === 'mine') pqPending.style.display = 'block';
                else pqPending.style.display = 'none';
            }
            // Hide filter bar and status chips on Practice tab for Pending teachers
            if (activeTab && activeTab.value === 'mine') {
                if (fb) fb.style.display = 'none';
                var chips = document.querySelector('#<%=pnlStatusChips.ClientID%>'); if (chips) chips.style.display = 'none';
            }
            // Disable Create Quiz button at top
            var createBtns = document.querySelectorAll('#<%=pnlCreateBtn.ClientID%> .tc-manage-quiz-btn-create');
            for (var j = 0; j < createBtns.length; j++) { createBtns[j].classList.add('tc-manage-quiz-btn-disabled'); createBtns[j].removeAttribute('onclick'); createBtns[j].setAttribute('title', tipText); }
            // 3. Discover tab: no restrictions — fully accessible
        }
    });
</script>
</asp:Content>
