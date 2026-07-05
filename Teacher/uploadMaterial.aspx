<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="uploadMaterial.aspx.cs"
    Inherits="ScienceBuddy.Teacher.uploadMaterial" MasterPageFile="~/Site.Master"
    Title="Upload Material" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--tc-primary:#6C63FF;--tc-hover:#5A52E0;--tc-light-bg:#F5F3FF;--tc-card-bg:#FFF;--tc-border:#E5E7EB;--tc-text:#374151;--tc-muted:#6B7280;--tc-info:#3B82F6;--tc-success:#10B981;--tc-error:#EF4444;}
.um-breadcrumb{display:flex;align-items:center;gap:6px;font-size:.8rem;color:var(--tc-muted);margin-bottom:1rem;}
.um-breadcrumb a{color:var(--tc-primary);text-decoration:none;font-weight:600;}.um-breadcrumb a:hover{text-decoration:underline;}
.um-breadcrumb i{font-size:.6rem;opacity:.5;}.um-breadcrumb span{color:var(--tc-text);font-weight:600;}
.um-header{margin-bottom:1.75rem;}.um-header h1{font-size:1.5rem;font-weight:800;color:var(--tc-text);margin:0;}.um-header p{font-size:.85rem;color:var(--tc-muted);margin:.25rem 0 0;}
.um-grid{display:grid;grid-template-columns:1fr 380px;gap:1.5rem;align-items:start;}
.um-form-card{background:var(--tc-card-bg);border:1.5px solid var(--tc-border);border-radius:16px;padding:1.75rem;box-shadow:0 2px 8px rgba(0,0,0,.03);}
.um-section{margin-bottom:1.5rem;}.um-section:last-child{margin-bottom:0;}
.um-section-title{font-size:.9rem;font-weight:700;color:var(--tc-text);margin:0 0 1rem;display:flex;align-items:center;gap:8px;}.um-section-title i{color:var(--tc-primary);font-size:1rem;}
.um-field{margin-bottom:1rem;position:relative;}.um-field:last-child{margin-bottom:0;}
.um-field-row{display:grid;grid-template-columns:1fr 1fr 1fr;gap:1rem;}
.um-label{font-size:.79rem;font-weight:600;color:var(--tc-text);display:block;margin-bottom:5px;}
.um-input{width:100%;border-radius:10px;border:1.5px solid var(--tc-border);padding:.6rem .8rem;font-size:.84rem;transition:border-color .2s,box-shadow .2s;background:var(--tc-card-bg);}
.um-input:focus{border-color:var(--tc-primary);box-shadow:0 0 0 3px rgba(108,99,255,.08);outline:none;}
.um-input.um-invalid{border-color:var(--tc-error)!important;box-shadow:0 0 0 3px rgba(239,68,68,.08)!important;}
.um-textarea{resize:vertical;min-height:110px;line-height:1.5;}
.um-val-msg{font-size:.73rem;color:var(--tc-error);margin-top:4px;display:none;font-weight:600;}
.um-val-msg.show{display:block;}
/* Language */
.um-lang-group{display:flex;gap:0;border:1.5px solid var(--tc-border);border-radius:10px;overflow:hidden;width:fit-content;}
.um-lang-group.um-invalid{border-color:var(--tc-error)!important;}
.um-lang-btn{padding:.55rem 1.25rem;font-size:.82rem;font-weight:600;border:none;background:var(--tc-card-bg);color:var(--tc-muted);cursor:pointer;transition:background .15s,color .15s;}
.um-lang-btn.active{background:var(--tc-primary);color:#fff;}.um-lang-btn:hover:not(.active){background:var(--tc-light-bg);}
/* Dropzone */
.um-dropzone{border:2px dashed var(--tc-border);border-radius:14px;padding:2rem;cursor:pointer;transition:border-color .2s,background .2s;text-align:center;}
.um-dropzone:hover,.um-dropzone.um-dragover{border-color:var(--tc-primary);background:var(--tc-light-bg);}
.um-dropzone.um-invalid{border-color:var(--tc-error)!important;}
.um-dropzone-content{display:flex;flex-direction:column;align-items:center;gap:4px;color:var(--tc-muted);}
.um-dropzone-content i{font-size:2.5rem;color:var(--tc-primary);margin-bottom:.5rem;}
.um-dropzone-content p{margin:0;font-size:.85rem;}.um-dropzone-sub{font-size:.8rem!important;}.um-link{color:var(--tc-primary);font-weight:600;}
.um-dropzone-hint{font-size:.74rem!important;color:var(--tc-muted);margin-top:8px!important;line-height:1.5;}
.um-file-info{display:flex;align-items:center;gap:12px;padding:.75rem 1rem;background:var(--tc-light-bg);border-radius:10px;margin-top:.75rem;}
.um-file-ico{width:40px;height:40px;border-radius:10px;background:#EDE9FE;color:var(--tc-primary);display:flex;align-items:center;justify-content:center;font-size:1.2rem;}
.um-file-details{flex:1;display:flex;flex-direction:column;gap:2px;}.um-file-name{font-size:.84rem;font-weight:600;color:var(--tc-text);}.um-file-meta{font-size:.74rem;color:var(--tc-muted);}
.um-file-remove{background:none;border:none;color:var(--tc-error);cursor:pointer;font-size:1rem;padding:4px;border-radius:6px;transition:background .15s;}.um-file-remove:hover{background:#FEE2E2;}
/* Error panel */
.um-error{background:#FEF2F2;border:1px solid #FEE2E2;color:#B91C1C;padding:.7rem 1rem;border-radius:10px;font-size:.83rem;font-weight:600;display:flex;align-items:center;gap:8px;margin-bottom:1rem;}
/* Actions */
.um-actions{display:flex;gap:.75rem;justify-content:flex-end;padding-top:1.25rem;border-top:1px solid var(--tc-border);margin-top:1.5rem;}
.um-btn-primary{background:var(--tc-primary);border:none;border-radius:10px;padding:.6rem 1.5rem;font-weight:700;font-size:.85rem;color:#fff;cursor:pointer;transition:background .2s;text-decoration:none;}
.um-btn-primary:hover{background:var(--tc-hover);}
.um-btn-cancel{background:var(--tc-card-bg);border:1.5px solid var(--tc-border);border-radius:10px;padding:.6rem 1.25rem;font-weight:600;font-size:.85rem;color:var(--tc-text);cursor:pointer;text-decoration:none;transition:border-color .15s;}
.um-btn-cancel:hover{border-color:var(--tc-muted);color:var(--tc-text);}
/* Preview */
.um-preview-card{background:var(--tc-card-bg);border:1.5px solid var(--tc-border);border-radius:16px;padding:1.5rem;box-shadow:0 2px 8px rgba(0,0,0,.03);position:sticky;top:1rem;}
.um-preview-title{font-size:.9rem;font-weight:700;color:var(--tc-text);margin:0 0 1rem;display:flex;align-items:center;gap:8px;}.um-preview-title i{color:var(--tc-primary);}
.um-preview-body{min-height:200px;}
.um-preview-placeholder{display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;color:var(--tc-muted);padding:2rem 1rem;gap:.5rem;}
.um-preview-placeholder i{font-size:2.5rem;opacity:.4;}.um-preview-placeholder p{font-size:.85rem;margin:0;}
.um-pv-ico{width:50px;height:50px;border-radius:12px;background:#EDE9FE;color:var(--tc-primary);display:flex;align-items:center;justify-content:center;font-size:1.4rem;margin-bottom:.75rem;}
.um-pv-title{font-size:1rem;font-weight:700;color:var(--tc-text);margin-bottom:.35rem;}
.um-pv-desc{font-size:.82rem;color:var(--tc-muted);line-height:1.5;margin-bottom:.75rem;}
.um-pv-meta{display:flex;flex-wrap:wrap;gap:.6rem;font-size:.75rem;color:var(--tc-muted);margin-bottom:.5rem;}.um-pv-meta span{display:inline-flex;align-items:center;gap:3px;}
/* Modal */
.um-modal-overlay{position:fixed;inset:0;background:rgba(17,24,39,.5);z-index:9000;display:flex;align-items:center;justify-content:center;padding:1rem;}
.um-modal{background:#fff;border-radius:16px;width:100%;max-width:420px;box-shadow:0 20px 60px rgba(0,0,0,.2);animation:umFade .2s ease;}
@keyframes umFade{from{opacity:0;transform:translateY(10px);}to{opacity:1;transform:translateY(0);}}
.um-modal-header{display:flex;align-items:center;justify-content:space-between;padding:1.25rem 1.5rem;border-bottom:1px solid var(--tc-border);}
.um-modal-header h3{font-size:1.05rem;font-weight:800;color:var(--tc-text);margin:0;}
.um-modal-close{background:none;border:none;font-size:1.4rem;color:var(--tc-muted);cursor:pointer;}.um-modal-close:hover{color:var(--tc-text);}
.um-modal-body{padding:1.5rem;text-align:center;}.um-modal-body p{font-size:.9rem;color:var(--tc-text);margin:0;}
.um-modal-footer{display:flex;gap:.75rem;justify-content:center;padding:1rem 1.5rem;border-top:1px solid var(--tc-border);}
/* Toast */
.um-toast-container{position:fixed;top:1.25rem;right:1.25rem;z-index:9999;display:flex;flex-direction:column;gap:.5rem;}
.um-toast{background:var(--tc-primary);color:#fff;padding:.75rem 1.25rem;border-radius:10px;font-size:.84rem;font-weight:600;display:flex;align-items:center;gap:8px;box-shadow:0 8px 24px rgba(108,99,255,.3);animation:umSlideIn .3s ease;}
.um-toast-out{animation:umSlideOut .4s ease forwards;}
@keyframes umSlideIn{from{opacity:0;transform:translateX(30px);}to{opacity:1;transform:translateX(0);}}
@keyframes umSlideOut{from{opacity:1;}to{opacity:0;transform:translateX(30px);}}
@media(max-width:1024px){.um-grid{grid-template-columns:1fr;}.um-preview-card{position:static;}}
@media(max-width:640px){.um-field-row{grid-template-columns:1fr;}.um-actions{flex-direction:column;}.um-btn-primary,.um-btn-cancel{width:100%;text-align:center;}}
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
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Upload Material","Muat Naik Bahan") %></asp:Content>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="um-breadcrumb"><a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>"><%: T("Dashboard","Papan Pemuka") %></a><i class="bi bi-chevron-right"></i><a href="<%: ResolveUrl("~/Teacher/manageMaterials.aspx") %>"><%: T("Manage Materials","Urus Bahan") %></a><i class="bi bi-chevron-right"></i><span><%: T("Upload Material","Muat Naik Bahan") %></span></div>
<div class="um-header"><h1><%: T("Upload Material","Muat Naik Bahan") %></h1><p><%: T("Upload a new learning material for your students.","Muat naik bahan pembelajaran baharu untuk pelajar.") %></p></div>
<div class="um-grid">
<div class="um-form-card">
    <div class="um-section">
        <h3 class="um-section-title"><i class="bi bi-info-circle"></i> <%: T("Material Information","Maklumat Bahan") %></h3>
        <div class="um-field">
            <label class="um-label"><%: T("Material Title","Tajuk Bahan") %> *</label>
            <asp:TextBox ID="txtTitle" runat="server" MaxLength="150" CssClass="um-input" />
            <div class="um-val-msg" id="valTitle"><%: T("Material Title is required.","Tajuk Bahan diperlukan.") %></div>
        </div>
        <div class="um-field">
            <label class="um-label"><%: T("Description","Penerangan") %> *</label>
            <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="5" CssClass="um-input um-textarea" />
            <div class="um-val-msg" id="valDesc"><%: T("Description is required.","Penerangan diperlukan.") %></div>
        </div>
    </div>
    <div class="um-section">
        <h3 class="um-section-title"><i class="bi bi-bookmark"></i> <%: T("Learning Category","Kategori Pembelajaran") %></h3>
        <div class="um-field-row">
            <div class="um-field"><label class="um-label"><%: T("Level","Tahap") %> *</label>
                <asp:DropDownList ID="ddlLevel" runat="server" CssClass="um-input" AutoPostBack="true" OnSelectedIndexChanged="ddlLevel_Changed" />
                <div class="um-val-msg" id="valLevel"><%: T("Please select a Level.","Sila pilih Tahap.") %></div></div>
            <div class="um-field"><label class="um-label"><%: T("Unit","Unit") %> *</label>
                <asp:DropDownList ID="ddlUnit" runat="server" CssClass="um-input" AutoPostBack="true" OnSelectedIndexChanged="ddlUnit_Changed" />
                <div class="um-val-msg" id="valUnit"><%: T("Please select a Unit.","Sila pilih Unit.") %></div></div>
            <div class="um-field"><label class="um-label"><%: T("Subtopic","Subtopik") %> *</label>
                <asp:DropDownList ID="ddlSubtopic" runat="server" CssClass="um-input" />
                <div class="um-val-msg" id="valSubtopic"><%: T("Please select a Subtopic.","Sila pilih Subtopik.") %></div></div>
        </div>
    </div>
    <div class="um-section">
        <h3 class="um-section-title"><i class="bi bi-translate"></i> <%: T("Language","Bahasa") %> *</h3>
        <asp:HiddenField ID="hidLanguage" runat="server" Value="EN" />
        <div class="um-lang-group" id="langGroup">
            <button type="button" class="um-lang-btn active" id="btnLangEN" onclick="setLang('EN')">English</button>
            <button type="button" class="um-lang-btn" id="btnLangBM" onclick="setLang('BM')">Bahasa Melayu</button>
        </div>
        <div class="um-val-msg" id="valLang"><%: T("Please select a Language.","Sila pilih Bahasa.") %></div>
    </div>

    <div class="um-section">
        <h3 class="um-section-title"><i class="bi bi-cloud-arrow-up"></i> <%: T("Upload File","Muat Naik Fail") %> *</h3>
        <div class="um-dropzone" id="dropZone" onclick="document.getElementById('<%=fuFile.ClientID%>').click();">
            <div class="um-dropzone-content" id="dzContent">
                <i class="bi bi-cloud-arrow-up-fill"></i>
                <p><strong>Drag & drop your file here</strong></p>
                <p class="um-dropzone-sub">or <span class="um-link">Browse Files</span></p>
            </div>
        </div>
        <div class="um-dropzone-hint">Supported formats: PDF, DOC, DOCX, PPT, PPTX, JPG, JPEG, PNG, MP4 — Maximum size: 100 MB</div>
        <div class="um-file-info" id="fileInfo" style="display:none;">
            <div class="um-file-ico" id="fileIcoEl"><i class="bi bi-file-earmark-fill"></i></div>
            <div class="um-file-details">
                <span class="um-file-name" id="fileName"></span>
                <span class="um-file-meta" id="fileMeta"></span>
            </div>
            <button type="button" class="um-file-remove" onclick="removeFile(event)" title="Remove file"><i class="bi bi-x-lg"></i></button>
        </div>
        <div class="um-val-msg" id="valFile"><%: T("Please upload a file.","Sila muat naik fail.") %></div>
        <asp:FileUpload ID="fuFile" runat="server" style="display:none;" onchange="handleFileSelect(this)" />
    </div>

    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="um-error"><i class="bi bi-exclamation-circle"></i> <asp:Literal ID="litError" runat="server" /></div>
    </asp:Panel>

    <div class="um-actions">
        <a href="<%: ResolveUrl("~/Teacher/manageMaterials.aspx") %>" class="um-btn-cancel"><%: T("Cancel","Batal") %></a>
        <button type="button" class="um-btn-primary" onclick="validateAndConfirm()"><%: T("Upload Material","Muat Naik Bahan") %></button>
    </div>
</div>

<%-- Live Preview --%>
<div class="um-preview-card">
    <h3 class="um-preview-title"><i class="bi bi-eye"></i> Live Preview</h3>
    <div class="um-preview-body">
        <div class="um-preview-placeholder" id="previewPlaceholder">
            <i class="bi bi-file-earmark-richtext"></i><p>Your material preview will appear here.</p>
        </div>
        <div id="previewContent" style="display:none;">
            <div class="um-pv-ico" id="pvIcon"><i class="bi bi-file-earmark-fill"></i></div>
            <div class="um-pv-title" id="pvTitle">Material Title</div>
            <div class="um-pv-desc" id="pvDesc">Description preview</div>
            <div class="um-pv-meta"><span id="pvLevel"><i class="bi bi-layers"></i> —</span><span id="pvUnit"><i class="bi bi-collection"></i> —</span><span id="pvSubtopic"><i class="bi bi-bookmark"></i> —</span></div>
            <div class="um-pv-meta"><span id="pvLang"><i class="bi bi-translate"></i> English</span><span id="pvFile"><i class="bi bi-paperclip"></i> No file</span></div>
        </div>
    </div>
</div>
</div>

<%-- Confirmation Modal --%>
<div id="confirmModal" class="um-modal-overlay" style="display:none;">
    <div class="um-modal">
        <div class="um-modal-header"><h3><%: T("Upload Material","Muat Naik Bahan") %></h3><button type="button" class="um-modal-close" onclick="closeConfirmModal()">×</button></div>
        <div class="um-modal-body"><p><%: T("Are you sure you want to upload this material?","Adakah anda pasti mahu memuat naik bahan ini?") %></p></div>
        <div class="um-modal-footer">
            <button type="button" class="um-btn-cancel" onclick="closeConfirmModal()"><%: T("Cancel","Batal") %></button>
            <asp:Button ID="btnUpload" runat="server" Text="Upload" OnClick="btnUpload_Click" CausesValidation="false" CssClass="um-btn-primary" />
        </div>
    </div>
</div>
<div id="umToast" class="um-toast-container"></div>
<asp:HiddenField ID="hidToast" runat="server" Value="" />
</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
var ALLOWED=['pdf','doc','docx','ppt','pptx','jpg','jpeg','png','mp4'];
var MAX_SIZE=100*1024*1024;
var fileSelected=false;

function setLang(lang){
    document.getElementById('<%=hidLanguage.ClientID%>').value=lang;
    document.getElementById('btnLangEN').className='um-lang-btn'+(lang==='EN'?' active':'');
    document.getElementById('btnLangBM').className='um-lang-btn'+(lang==='BM'?' active':'');
    document.getElementById('pvLang').innerHTML='<i class="bi bi-translate"></i> '+(lang==='EN'?'English':'Bahasa Melayu');
    clearVal('valLang');document.getElementById('langGroup').classList.remove('um-invalid');
    updatePreview();
}

function handleFileSelect(input){
    clearVal('valFile');document.getElementById('dropZone').classList.remove('um-invalid');
    if(!input.files||!input.files[0])return;
    var f=input.files[0],ext=f.name.split('.').pop().toLowerCase();
    if(ALLOWED.indexOf(ext)===-1){showVal('valFile','Unsupported file type. Supported formats: PDF, DOC, DOCX, PPT, PPTX, JPG, JPEG, PNG, MP4');document.getElementById('dropZone').classList.add('um-invalid');input.value='';return;}
    if(f.size>MAX_SIZE){showVal('valFile','File size exceeds the maximum limit of 100 MB.');document.getElementById('dropZone').classList.add('um-invalid');input.value='';return;}
    fileSelected=true;
    document.getElementById('dzContent').style.display='none';
    document.getElementById('fileInfo').style.display='flex';
    document.getElementById('fileName').textContent=f.name;
    document.getElementById('fileMeta').textContent=formatSize(f.size)+' \u2022 '+ext.toUpperCase();
    document.getElementById('fileIcoEl').innerHTML='<i class="bi '+getFileIcon(ext)+'"></i>';
    document.getElementById('pvFile').innerHTML='<i class="bi bi-paperclip"></i> '+f.name;
    updatePreview();
}

function removeFile(e){
    e.stopPropagation();fileSelected=false;
    document.getElementById('<%=fuFile.ClientID%>').value='';
    document.getElementById('dzContent').style.display='flex';
    document.getElementById('fileInfo').style.display='none';
    document.getElementById('pvFile').innerHTML='<i class="bi bi-paperclip"></i> No file';
    updatePreview();
}

function getFileIcon(ext){
    if(ext==='pdf')return'bi-file-earmark-pdf-fill';
    if(ext==='doc'||ext==='docx')return'bi-file-earmark-word-fill';
    if(ext==='ppt'||ext==='pptx')return'bi-file-earmark-slides-fill';
    if(ext==='mp4')return'bi-file-earmark-play-fill';
    if(ext==='jpg'||ext==='jpeg'||ext==='png')return'bi-file-earmark-image-fill';
    return'bi-file-earmark-fill';
}
function formatSize(b){if(b<1024)return b+' B';if(b<1048576)return(b/1024).toFixed(1)+' KB';return(b/1048576).toFixed(1)+' MB';}

// Drag & drop
var dz=document.getElementById('dropZone');
if(dz){['dragenter','dragover'].forEach(function(ev){dz.addEventListener(ev,function(e){e.preventDefault();dz.classList.add('um-dragover');});});
['dragleave','drop'].forEach(function(ev){dz.addEventListener(ev,function(e){e.preventDefault();dz.classList.remove('um-dragover');});});
dz.addEventListener('drop',function(e){var dt=e.dataTransfer;if(dt.files&&dt.files[0]){var inp=document.getElementById('<%=fuFile.ClientID%>');inp.files=dt.files;handleFileSelect(inp);}});}

// Validation
function showVal(id,msg){var el=document.getElementById(id);el.textContent=msg;el.classList.add('show');}
function clearVal(id){var el=document.getElementById(id);el.classList.remove('show');}

function validateAndConfirm(){
    var valid=true,firstInvalid=null;
    var title=document.querySelector('[id$="txtTitle"]');
    var desc=document.querySelector('[id$="txtDescription"]');
    var level=document.querySelector('[id$="ddlLevel"]');
    var unit=document.querySelector('[id$="ddlUnit"]');
    var sub=document.querySelector('[id$="ddlSubtopic"]');
    var lang=document.getElementById('<%=hidLanguage.ClientID%>').value;

    // Title
    if(!title.value.trim()){showVal('valTitle','Material Title is required.');title.classList.add('um-invalid');valid=false;if(!firstInvalid)firstInvalid=title;}
    else{clearVal('valTitle');title.classList.remove('um-invalid');}
    // Desc
    if(!desc.value.trim()){showVal('valDesc','Description is required.');desc.classList.add('um-invalid');valid=false;if(!firstInvalid)firstInvalid=desc;}
    else{clearVal('valDesc');desc.classList.remove('um-invalid');}
    // Level
    if(!level.value){showVal('valLevel','Please select a Level.');level.classList.add('um-invalid');valid=false;if(!firstInvalid)firstInvalid=level;}
    else{clearVal('valLevel');level.classList.remove('um-invalid');}
    // Unit
    if(!unit.value){showVal('valUnit','Please select a Unit.');unit.classList.add('um-invalid');valid=false;if(!firstInvalid)firstInvalid=unit;}
    else{clearVal('valUnit');unit.classList.remove('um-invalid');}
    // Subtopic
    if(!sub.value){showVal('valSubtopic','Please select a Subtopic.');sub.classList.add('um-invalid');valid=false;if(!firstInvalid)firstInvalid=sub;}
    else{clearVal('valSubtopic');sub.classList.remove('um-invalid');}
    // Language
    if(!lang){showVal('valLang','Please select a Language.');document.getElementById('langGroup').classList.add('um-invalid');valid=false;}
    else{clearVal('valLang');document.getElementById('langGroup').classList.remove('um-invalid');}
    // File
    if(!fileSelected){showVal('valFile','Please upload a file.');document.getElementById('dropZone').classList.add('um-invalid');valid=false;}
    else{clearVal('valFile');document.getElementById('dropZone').classList.remove('um-invalid');}

    if(!valid){if(firstInvalid)firstInvalid.focus();return;}
    document.getElementById('confirmModal').style.display='flex';
}

function closeConfirmModal(){document.getElementById('confirmModal').style.display='none';}

// Live preview
function updatePreview(){
    var t=document.querySelector('[id$="txtTitle"]').value;
    var d=document.querySelector('[id$="txtDescription"]').value;
    var show=t||d||fileSelected;
    document.getElementById('previewPlaceholder').style.display=show?'none':'flex';
    document.getElementById('previewContent').style.display=show?'block':'none';
    if(t)document.getElementById('pvTitle').textContent=t;
    if(d)document.getElementById('pvDesc').textContent=d.length>150?d.substring(0,150)+'\u2026':d;
    var lS=document.querySelector('[id$="ddlLevel"]'),uS=document.querySelector('[id$="ddlUnit"]'),sS=document.querySelector('[id$="ddlSubtopic"]');
    if(lS&&lS.selectedIndex>0)document.getElementById('pvLevel').innerHTML='<i class="bi bi-layers"></i> '+lS.options[lS.selectedIndex].text;
    if(uS&&uS.selectedIndex>0)document.getElementById('pvUnit').innerHTML='<i class="bi bi-collection"></i> '+uS.options[uS.selectedIndex].text;
    if(sS&&sS.selectedIndex>0)document.getElementById('pvSubtopic').innerHTML='<i class="bi bi-bookmark"></i> '+sS.options[sS.selectedIndex].text;
}

// Clear validation on input
document.addEventListener('input',function(e){
    var id=e.target.id||'';
    if(id.indexOf('txtTitle')>-1){clearVal('valTitle');e.target.classList.remove('um-invalid');}
    if(id.indexOf('txtDescription')>-1){clearVal('valDesc');e.target.classList.remove('um-invalid');}
    updatePreview();
});
document.addEventListener('change',function(e){
    var id=e.target.id||'';
    if(id.indexOf('ddlLevel')>-1){clearVal('valLevel');e.target.classList.remove('um-invalid');}
    if(id.indexOf('ddlUnit')>-1){clearVal('valUnit');e.target.classList.remove('um-invalid');}
    if(id.indexOf('ddlSubtopic')>-1){clearVal('valSubtopic');e.target.classList.remove('um-invalid');}
    updatePreview();
});

// Toast + redirect
function showToast(msg){var c=document.getElementById('umToast'),t=document.createElement('div');t.className='um-toast';t.innerHTML='<i class="bi bi-check-circle-fill"></i> '+msg;c.appendChild(t);setTimeout(function(){t.classList.add('um-toast-out');},3e3);setTimeout(function(){t.remove();},3500);}
window.addEventListener('load',function(){
    var h=document.getElementById('<%=hidToast.ClientID%>');
    if(h&&h.value){showToast(h.value);h.value='';setTimeout(function(){window.location='<%=ResolveUrl("~/Teacher/manageMaterials.aspx")%>';},2e3);}
    updatePreview();
    var lang=document.getElementById('<%=hidLanguage.ClientID%>').value||'EN';setLang(lang);
    // Restore file state after postback
    var fi=document.getElementById('fileInfo');if(fi&&fi.style.display==='flex')fileSelected=true;
});
</script>
</asp:Content>
