<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="manageQuiz.aspx.cs"
    Inherits="ScienceBuddy.Teacher.manageQuiz" MasterPageFile="~/Site.Master"
    Title="Manage Quizzes" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--tc-primary:#6C63FF;--tc-hover:#5A52E0;--tc-light-bg:#F5F3FF;--tc-card-bg:#FFF;--tc-border:#E5E7EB;--tc-text:#374151;--tc-muted:#6B7280;--tc-info:#3B82F6;--tc-success:#10B981;--tc-error:#EF4444;--tc-warning:#F59E0B;}
.mq-page-title{font-size:1.5rem;font-weight:800;color:var(--tc-text);margin:0;}
.mq-page-sub{font-size:.85rem;color:var(--tc-muted);margin:.3rem 0 0;}
.mq-btn-create{display:inline-flex;align-items:center;gap:6px;background:var(--tc-primary);border:none;border-radius:10px;padding:.6rem 1.25rem;font-weight:700;font-size:.85rem;color:#fff;cursor:pointer;text-decoration:none;transition:background .2s,box-shadow .2s;box-shadow:0 2px 8px rgba(108,99,255,.15);}
.mq-btn-create:hover{background:var(--tc-hover);box-shadow:0 4px 16px rgba(108,99,255,.25);color:#fff;text-decoration:none;}
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
/* Carousel */
.mq-carousel-wrap{position:relative;display:flex;align-items:center;gap:8px;}
.mq-carousel{display:flex;gap:1rem;overflow-x:auto;scroll-behavior:smooth;padding:1rem .25rem;-ms-overflow-style:none;scrollbar-width:none;}
.mq-carousel::-webkit-scrollbar{display:none;}
.mq-arrow{width:36px;height:36px;border-radius:50%;border:1.5px solid var(--tc-border);background:var(--tc-card-bg);display:flex;align-items:center;justify-content:center;cursor:pointer;font-size:1rem;color:var(--tc-text);transition:border-color .2s,box-shadow .2s;flex-shrink:0;box-shadow:0 2px 6px rgba(0,0,0,.05);}
.mq-arrow:hover{border-color:var(--tc-primary);color:var(--tc-primary);box-shadow:0 4px 12px rgba(108,99,255,.12);}
/* Card */
.mq-card{min-width:280px;max-width:280px;background:var(--tc-card-bg);border:1.5px solid var(--tc-border);border-radius:16px;display:flex;flex-direction:column;box-shadow:0 2px 8px rgba(0,0,0,.03);transition:transform .2s,box-shadow .2s;}
.mq-card:hover{transform:translateY(-3px);box-shadow:0 8px 24px rgba(108,99,255,.1);}
.mq-card-header{padding:1rem 1.25rem .5rem;display:flex;justify-content:flex-end;}
.mq-card-body{padding:0 1.25rem 1rem;flex:1;display:flex;flex-direction:column;gap:6px;}
.mq-card-icon{width:44px;height:44px;border-radius:12px;background:#EDE9FE;color:var(--tc-primary);display:flex;align-items:center;justify-content:center;font-size:1.3rem;margin-bottom:4px;}
.mq-card-title{font-size:.92rem;font-weight:700;color:var(--tc-text);line-height:1.3;}
.mq-card-category{font-size:.75rem;color:var(--tc-muted);font-weight:600;}
.mq-card-meta{display:flex;flex-wrap:wrap;gap:8px;font-size:.73rem;color:var(--tc-muted);margin-top:6px;}
.mq-card-meta span{display:inline-flex;align-items:center;gap:3px;}
.mq-card-actions{display:flex;gap:6px;padding:.75rem 1.25rem;border-top:1px solid #F0EDFF;}
.mq-act{font-size:.76rem;font-weight:600;text-decoration:none;padding:5px 10px;border-radius:8px;border:1.5px solid;cursor:pointer;background:transparent;display:inline-flex;align-items:center;gap:4px;transition:background .15s;}
.mq-act-view{color:var(--tc-info);border-color:#DBEAFE;background:#F0F7FF;}.mq-act-view:hover{background:#DBEAFE;}
.mq-act-edit{color:var(--tc-primary);border-color:#EDE9FE;background:#F5F3FF;}.mq-act-edit:hover{background:#EDE9FE;}
.mq-act-delete{color:var(--tc-error);border-color:#FEE2E2;background:#FEF2F2;}.mq-act-delete:hover{background:#FEE2E2;}
/* Badges */
.mq-badge{padding:3px 10px;border-radius:50px;font-size:.7rem;font-weight:700;}
.mq-badge-pending{background:#FEF3C7;color:#B45309;}.mq-badge-approved{background:#D1FAE5;color:#047857;}.mq-badge-rejected{background:#FEE2E2;color:#B91C1C;}.mq-badge-active{background:#D1FAE5;color:#047857;}
.mq-diff{padding:2px 8px;border-radius:6px;font-size:.7rem;font-weight:700;}
.mq-diff-easy{background:#D1FAE5;color:#047857;}.mq-diff-medium{background:#FEF3C7;color:#B45309;}.mq-diff-hard{background:#FEE2E2;color:#B91C1C;}
/* Empty */
.mq-empty{display:flex;flex-direction:column;align-items:center;padding:3.5rem;text-align:center;}
.mq-empty-title{font-size:1rem;font-weight:700;color:var(--tc-text);}
/* Modal */
.mq-modal-overlay{position:fixed;inset:0;background:rgba(17,24,39,.5);z-index:9000;display:flex;align-items:center;justify-content:center;padding:1rem;}
.mq-modal{background:#fff;border-radius:16px;width:100%;max-width:420px;box-shadow:0 20px 60px rgba(0,0,0,.2);animation:mqFade .2s ease;}
@keyframes mqFade{from{opacity:0;transform:translateY(10px);}to{opacity:1;transform:translateY(0);}}
.mq-modal-header{display:flex;align-items:center;justify-content:space-between;padding:1.25rem 1.5rem;border-bottom:1px solid var(--tc-border);}
.mq-modal-header h3{font-size:1.05rem;font-weight:800;color:var(--tc-text);margin:0;}
.mq-modal-close{background:none;border:none;font-size:1.4rem;color:var(--tc-muted);cursor:pointer;}.mq-modal-close:hover{color:var(--tc-text);}
.mq-modal-body{padding:1.5rem;text-align:center;}.mq-modal-body p{font-size:.9rem;color:var(--tc-text);margin:0;}
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
@media(max-width:900px){.mq-filter-bar{flex-wrap:wrap;}.mq-search-wrap{width:100%;}.mq-select{flex:1;min-width:120px;width:auto;}.mq-btn-search{flex:0;}}
@media(max-width:640px){.mq-filter-bar{flex-direction:column;align-items:stretch;}.mq-select{width:100%;}.mq-btn-search{width:100%;}.mq-card{min-width:260px;max-width:260px;}}
</style>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Teaching","Pengajaran") %></div>
        <a href="<%: ResolveUrl("~/Teacher/manageMaterials.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label"><%: T("Manage Materials","Urus Bahan Pembelajaran") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-patch-question item-icon"></i><span class="item-label"><%: T("Manage Quiz","Urus Kuiz") %></span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-bar-chart item-icon"></i><span class="item-label"><%: T("Student Progress","Kemajuan Pelajar") %></span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label"><%: T("Schedule Live Class","Jadual Kelas Langsung") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Community","Komuniti") %></div>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/privateMessages.aspx") %>" class="sb-sidebar-item"><i class="bi bi-envelope item-icon"></i><span class="item-label"><%: T("Private Message","Mesej Peribadi") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Account","Akaun") %></div>
        <a href="<%: ResolveUrl("~/Teacher/MyProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("My Profile","Profil Saya") %></span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Sign Out","Log Keluar") %></span></a></div>
</asp:Content>
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Manage Quizzes","Urus Kuiz") %></asp:Content>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<asp:Panel ID="pnlDenied" runat="server" Visible="false">
    <div style="display:flex;flex-direction:column;align-items:center;padding:3rem;text-align:center;">
        <div style="font-size:3rem;margin-bottom:1rem;">🚫</div>
        <h2 style="color:var(--tc-text);font-weight:800;"><%: T("Access Denied","Akses Ditolak") %></h2>
        <p style="color:var(--tc-muted);max-width:450px;"><%: T("Your account cannot access this page.","Akaun anda tidak boleh mengakses halaman ini.") %></p>
    </div>
</asp:Panel>

<asp:Panel ID="pnlMain" runat="server" Visible="false">

<%-- Header --%>
<div style="margin-bottom:1.25rem;">
    <h1 class="mq-page-title"><%: T("My Quizzes","Kuiz Saya") %></h1>
    <p class="mq-page-sub"><%: T("Create and manage your practice quizzes.","Cipta dan urus kuiz latihan anda.") %></p>
</div>
<div style="margin-bottom:1.5rem;">
    <button type="button" class="mq-btn-create" onclick="document.getElementById('createModal').style.display='flex'"><i class="bi bi-plus-lg"></i> <%: T("Create Quiz","Cipta Kuiz") %></button>
</div>

<%-- Search & Filter --%>
<div class="mq-filter-bar">
    <div class="mq-search-wrap"><i class="bi bi-search"></i>
        <asp:TextBox ID="txtSearch" runat="server" CssClass="mq-search-input" /></div>
    <asp:DropDownList ID="ddlDifficulty" runat="server" CssClass="mq-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed" />
    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="mq-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed" />
    <asp:DropDownList ID="ddlLanguage" runat="server" CssClass="mq-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed" />
    <asp:Button ID="btnSearch" runat="server" CssClass="mq-btn-search" OnClick="btnSearch_Click" CausesValidation="false" />
</div>

<%-- Quiz Carousel --%>
<asp:Panel ID="pnlQuizzes" runat="server" Visible="false">
    <div class="mq-carousel-wrap">
        <button type="button" class="mq-arrow mq-arrow-left" onclick="scrollCarousel(-1)" aria-label="Scroll left"><i class="bi bi-chevron-left"></i></button>
        <div class="mq-carousel" id="quizCarousel">
            <asp:Repeater ID="rptQuizzes" runat="server">
                <ItemTemplate>
                    <div class="mq-card">
                        <div class="mq-card-header">
                            <span class='mq-badge <%# GetStatusCss(Eval("status").ToString()) %>'><%# GetStatusLabel(Eval("status").ToString()) %></span>
                        </div>
                        <div class="mq-card-body">
                            <div class="mq-card-icon"><i class="bi bi-patch-question-fill"></i></div>
                            <div class="mq-card-title"><%# HttpUtility.HtmlEncode(Eval("quizTitle")) %></div>
                            <div class="mq-card-category"><%: T("Practice Quiz","Kuiz Latihan") %></div>
                            <div class="mq-card-meta">
                                <span class='mq-diff <%# GetDiffCss(Eval("difficulty").ToString()) %>'><%# HttpUtility.HtmlEncode(Eval("difficulty")) %></span>
                                <span><i class="bi bi-translate"></i> <%# HttpUtility.HtmlEncode(Eval("language")) %></span>
                                <span><i class="bi bi-list-check"></i> <%# Eval("questionCount") %> <%: T("Questions","Soalan") %></span>
                            </div>
                        </div>
                        <div class="mq-card-actions">
                            <a href="#" class="mq-act mq-act-view"><i class="bi bi-eye"></i> <%: T("View","Lihat") %></a>
                            <a href="#" class="mq-act mq-act-edit"><i class="bi bi-pencil"></i> <%: T("Edit","Edit") %></a>
                            <button type="button" class="mq-act mq-act-delete" onclick="openDeleteModal('<%# Eval("quizId") %>')"><i class="bi bi-trash"></i> <%: T("Delete","Padam") %></button>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
        <button type="button" class="mq-arrow mq-arrow-right" onclick="scrollCarousel(1)" aria-label="Scroll right"><i class="bi bi-chevron-right"></i></button>
    </div>
</asp:Panel>

<%-- Empty state --%>
<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="mq-empty">
        <div style="font-size:3.5rem;opacity:.5;margin-bottom:1rem;">📝</div>
        <div class="mq-empty-title"><%: T("No quizzes created yet.","Tiada kuiz dicipta lagi.") %></div>
        <button type="button" class="mq-btn-create" style="margin-top:1rem;" onclick="document.getElementById('createModal').style.display='flex'">
            <i class="bi bi-plus-lg"></i> <%: T("Create Your First Quiz","Cipta Kuiz Pertama Anda") %></button>
    </div>
</asp:Panel>

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
<asp:HiddenField ID="hidDeleteId" runat="server" Value="" />
<asp:HiddenField ID="hidToast" runat="server" Value="" />
<div id="mqToast" class="mq-toast-container"></div>

</asp:Panel>
</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
function scrollCarousel(dir){var c=document.getElementById('quizCarousel');if(c)c.scrollBy({left:dir*320,behavior:'smooth'});}
function openDeleteModal(id){document.getElementById('<%=hidDeleteId.ClientID%>').value=id;document.getElementById('deleteModal').style.display='flex';}
function closeDeleteModal(){document.getElementById('deleteModal').style.display='none';}
function showToast(msg){var c=document.getElementById('mqToast'),t=document.createElement('div');t.className='mq-toast';t.innerHTML='<i class="bi bi-check-circle-fill"></i> '+msg;c.appendChild(t);setTimeout(function(){t.classList.add('mq-toast-out');},3e3);setTimeout(function(){t.remove();},3500);}
window.addEventListener('load',function(){var h=document.getElementById('<%=hidToast.ClientID%>');if(h&&h.value){showToast(h.value);h.value='';}
var cm=document.getElementById('<%=hidShowCreateModal.ClientID%>');if(cm&&cm.value==='1'){document.getElementById('createModal').style.display='flex';cm.value='';}});
</script>
</asp:Content>
