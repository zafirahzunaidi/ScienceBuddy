<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="uploadMaterial.aspx.cs"
    Inherits="ScienceBuddy.Teacher.uploadMaterial" MasterPageFile="~/Site.Master" Title="Upload Material" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--p:#6C63FF;--p-dk:#5A52E0;--p-lt:#F5F3FF;--w:#FFF;--b:#E5E7EB;--t:#374151;--m:#6B7280;--s:#10B981;--e:#EF4444;}
.um-back{display:inline-flex;align-items:center;gap:6px;font-size:.88rem;font-weight:700;color:var(--p);text-decoration:none;margin-bottom:1.2rem;}.um-back:hover{color:var(--p-dk);}
.um-header{margin-bottom:1.5rem;}.um-header h1{font-size:1.5rem;font-weight:800;color:var(--t);margin:0 0 .2rem;}.um-header p{font-size:.88rem;color:var(--m);margin:0;}
.um-card{background:var(--w);border:1.5px solid var(--b);border-radius:18px;padding:1.75rem 2rem;box-shadow:0 3px 12px rgba(0,0,0,.04);}
.um-row{display:grid;grid-template-columns:1fr 1fr;gap:1.2rem;margin-bottom:1.2rem;}
.um-row-3col{display:grid;grid-template-columns:15% 20% 30% 1fr;gap:.9rem;margin-bottom:1.2rem;}
.um-row-full{margin-bottom:1.2rem;}
.um-field{position:relative;}
.um-label{display:block;font-size:.92rem;font-weight:800;color:var(--t);margin-bottom:6px;}
.um-input{width:100%;border-radius:10px;border:1.5px solid var(--b);padding:.65rem .9rem;font-size:.9rem;transition:border-color .2s,box-shadow .2s;background:var(--w);box-sizing:border-box;font-family:inherit;}
.um-input:focus{border-color:var(--p);box-shadow:0 0 0 3px rgba(108,99,255,.08);outline:none;}
.um-textarea{resize:vertical;min-height:100px;line-height:1.55;}
.um-val{font-size:.78rem;color:var(--e);margin-top:4px;display:none;font-weight:600;}.um-val.show{display:block;}
.um-input.invalid{border-color:var(--e)!important;}
/* Language */
.um-lang-group{display:flex;border:1.5px solid var(--b);border-radius:10px;overflow:hidden;width:fit-content;}
.um-lang-btn{padding:.55rem 1.3rem;font-size:.86rem;font-weight:600;border:none;background:var(--w);color:var(--m);cursor:pointer;transition:background .15s,color .15s;}
.um-lang-btn.active{background:var(--p);color:#fff;}
/* Upload area */
.um-drop{border:2px dashed var(--b);border-radius:14px;padding:1.5rem;cursor:pointer;transition:border-color .2s,background .2s;text-align:center;}
.um-drop:hover,.um-drop.dragover{border-color:var(--p);background:var(--p-lt);}
.um-drop.invalid{border-color:var(--e)!important;}
.um-drop-content{display:flex;flex-direction:column;align-items:center;gap:4px;color:var(--m);}
.um-drop-content i{font-size:2rem;color:var(--p);margin-bottom:.4rem;}
.um-drop-content p{margin:0;font-size:.88rem;font-weight:600;}.um-drop-sub{font-size:.8rem!important;font-weight:400!important;}
.um-drop-hint{font-size:.76rem;color:var(--m);margin-top:6px;}
.um-file-card{display:flex;align-items:center;gap:12px;padding:.75rem 1rem;border-radius:12px;margin-top:.75rem;border:1.5px solid var(--b);background:#FAFAFA;}
.um-file-ico{width:42px;height:42px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:1.2rem;flex-shrink:0;}
.um-ico-pdf{background:#FEE2E2;color:#DC2626;}.um-ico-doc{background:#DBEAFE;color:#2563EB;}.um-ico-ppt{background:#FFEDD5;color:#EA580C;}.um-ico-img{background:#D1FAE5;color:#059669;}.um-ico-vid{background:#DBEAFE;color:#2563EB;}.um-ico-oth{background:#F3F4F6;color:#6B7280;}
.um-file-info{flex:1;}.um-file-name{font-size:.88rem;font-weight:700;color:var(--t);}.um-file-meta{font-size:.76rem;color:var(--m);}
.um-file-rm{background:none;border:none;color:var(--e);cursor:pointer;font-size:1.1rem;padding:4px;border-radius:6px;}.um-file-rm:hover{background:#FEE2E2;}
/* Error */
.um-error{background:#FEF2F2;border:1px solid #FEE2E2;color:#B91C1C;padding:.7rem 1rem;border-radius:10px;font-size:.86rem;font-weight:600;display:flex;align-items:center;gap:8px;margin-bottom:1rem;}
/* Actions */
.um-actions{display:flex;gap:.75rem;justify-content:flex-end;padding-top:1.25rem;border-top:1px solid var(--b);margin-top:1.5rem;}
.um-btn{border:none;border-radius:10px;padding:.65rem 1.5rem;font-weight:700;font-size:.9rem;cursor:pointer;transition:background .2s;text-decoration:none;display:inline-flex;align-items:center;gap:6px;}
.um-btn-primary{background:#0D9488;color:#fff;box-shadow:0 2px 8px rgba(13,148,136,.22);}.um-btn-primary:hover{background:#0F766E;}
.um-btn-cancel{background:var(--w);border:1.5px solid var(--b);color:var(--t);}.um-btn-cancel:hover{border-color:var(--m);}
/* Modal */
.um-modal-overlay{position:fixed;inset:0;background:rgba(17,24,39,.5);z-index:9000;display:flex;align-items:center;justify-content:center;padding:1rem;}
.um-modal{background:#fff;border-radius:18px;width:100%;max-width:400px;box-shadow:0 20px 60px rgba(0,0,0,.2);animation:umF .2s ease;}
@keyframes umF{from{opacity:0;transform:translateY(10px);}to{opacity:1;transform:translateY(0);}}
.um-modal-hd{padding:1.25rem 1.5rem;border-bottom:1px solid var(--b);display:flex;align-items:center;justify-content:space-between;}
.um-modal-hd h3{margin:0;font-size:1.05rem;font-weight:800;color:var(--t);}
.um-modal-close{background:none;border:none;font-size:1.4rem;color:var(--m);cursor:pointer;}.um-modal-close:hover{color:var(--t);}
.um-modal-body{padding:1.5rem;text-align:center;}.um-modal-body p{font-size:.92rem;color:var(--t);margin:0;}
.um-modal-ft{display:flex;gap:.75rem;justify-content:center;padding:1rem 1.5rem;border-top:1px solid var(--b);}
/* Toast */
.um-toast-wrap{position:fixed;top:1.25rem;right:1.25rem;z-index:9999;}
.um-toast{background:var(--s);color:#fff;padding:.75rem 1.25rem;border-radius:10px;font-size:.88rem;font-weight:600;display:flex;align-items:center;gap:8px;box-shadow:0 6px 18px rgba(16,185,129,.25);animation:umF .3s ease;}
@media(max-width:768px){.um-row,.um-row-3col{grid-template-columns:1fr;}.um-card{padding:1.3rem;}.um-actions{flex-direction:column;}.um-btn{width:100%;justify-content:center;}}
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
        <a href="<%: ResolveUrl("~/Teacher/Forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/privateMessages.aspx") %>" class="sb-sidebar-item"><i class="bi bi-envelope item-icon"></i><span class="item-label"><%: T("Private Message","Mesej Peribadi") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Account","Akaun") %></div>
        <a href="<%: ResolveUrl("~/Teacher/MyProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("My Profile","Profil Saya") %></span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Sign Out","Log Keluar") %></span></a></div>
</asp:Content>
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Upload Material","Muat Naik Bahan") %></asp:Content>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<a href="<%: ResolveUrl("~/Teacher/manageMaterials.aspx") %>" class="um-back"><i class="bi bi-arrow-left"></i> <%: T("Back to Materials","Kembali ke Bahan") %></a>
<div class="um-header"><h1><i class="bi bi-cloud-arrow-up" style="color:var(--p);margin-right:.3rem;"></i><%: T("Upload Material","Muat Naik Bahan") %></h1><p><%: T("Upload a new learning material for your students.","Muat naik bahan pembelajaran baharu untuk pelajar.") %></p></div>

<div class="um-card">
    <asp:Panel ID="pnlError" runat="server" Visible="false"><div class="um-error"><i class="bi bi-exclamation-circle"></i> <asp:Literal ID="litError" runat="server" /></div></asp:Panel>

    <%-- Row 1: Title full width --%>
    <div class="um-row-full">
        <div class="um-field">
            <label class="um-label"><%: T("Material Title","Tajuk Bahan") %> *</label>
            <asp:TextBox ID="txtTitle" runat="server" MaxLength="150" CssClass="um-input" placeholder="Enter material title..." />
            <div class="um-val" id="vTitle"><%: T("Material Title is required.","Tajuk Bahan diperlukan.") %></div>
        </div>
    </div>

    <%-- Row 2: Description full width --%>
    <div class="um-row-full">
        <div class="um-field">
            <label class="um-label"><%: T("Description","Penerangan") %></label>
            <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="4" CssClass="um-input um-textarea" placeholder="Describe what this material covers..." />
        </div>
    </div>

    <%-- Row 3: Language 15% + Level 20% + Unit 30% + Subtopic 35% --%>
    <div class="um-row-3col">
        <div class="um-field">
            <label class="um-label"><%: T("Language","Bahasa") %> *</label>
            <asp:HiddenField ID="hidLanguage" runat="server" Value="EN" />
            <div class="um-lang-group" id="langGrp">
                <button type="button" class="um-lang-btn active" id="bEN" onclick="setLang('EN')">EN</button>
                <button type="button" class="um-lang-btn" id="bBM" onclick="setLang('BM')">BM</button>
            </div>
        </div>
        <div class="um-field">
            <label class="um-label"><%: T("Level","Tahap") %> *</label>
            <asp:DropDownList ID="ddlLevel" runat="server" CssClass="um-input" AutoPostBack="true" OnSelectedIndexChanged="ddlLevel_Changed" />
            <div class="um-val" id="vLevel"><%: T("Select Level.","Pilih Tahap.") %></div>
        </div>
        <div class="um-field">
            <label class="um-label"><%: T("Unit","Unit") %> *</label>
            <asp:DropDownList ID="ddlUnit" runat="server" CssClass="um-input" AutoPostBack="true" OnSelectedIndexChanged="ddlUnit_Changed" />
            <div class="um-val" id="vUnit"><%: T("Select Unit.","Pilih Unit.") %></div>
        </div>
        <div class="um-field">
            <label class="um-label"><%: T("Subtopic","Subtopik") %> *</label>
            <asp:DropDownList ID="ddlSubtopic" runat="server" CssClass="um-input" />
            <div class="um-val" id="vSub"><%: T("Select Subtopic.","Pilih Subtopik.") %></div>
        </div>
    </div>

    <%-- Row 4: Upload File full width --%>
    <div class="um-row-full">
        <div class="um-field">
            <label class="um-label"><%: T("Upload File","Muat Naik Fail") %> *</label>
            <div class="um-drop" id="dropZone" onclick="document.getElementById('<%=fuFile.ClientID%>').click();">
                <div class="um-drop-content" id="dzContent">
                    <i class="bi bi-cloud-arrow-up-fill"></i>
                    <p><%: T("Drag & drop or click to browse","Seret & lepas atau klik untuk semak imbas") %></p>
                    <p class="um-drop-sub">PDF, DOC, DOCX, PPT, PPTX, JPG, PNG, MP4 (max 100 MB)</p>
                </div>
            </div>
            <div class="um-file-card" id="fileCard" style="display:none;">
                <div class="um-file-ico" id="fIco"><i class="bi bi-file-earmark-fill"></i></div>
                <div class="um-file-info"><span class="um-file-name" id="fName"></span><span class="um-file-meta" id="fMeta"></span></div>
                <button type="button" class="um-file-rm" onclick="removeFile(event)"><i class="bi bi-x-lg"></i></button>
            </div>
            <div class="um-val" id="vFile"><%: T("Please upload a file.","Sila muat naik fail.") %></div>
            <asp:FileUpload ID="fuFile" runat="server" style="display:none;" onchange="handleFile(this)" />
        </div>
    </div>

    <%-- Actions --%>
    <div class="um-actions">
        <a href="<%: ResolveUrl("~/Teacher/manageMaterials.aspx") %>" class="um-btn um-btn-cancel"><%: T("Cancel","Batal") %></a>
        <button type="button" class="um-btn um-btn-primary" onclick="validateForm()"><i class="bi bi-cloud-arrow-up"></i> <%: T("Upload Material","Muat Naik Bahan") %></button>
    </div>
</div>

<%-- Confirm Modal --%>
<div id="confirmModal" class="um-modal-overlay" style="display:none;">
    <div class="um-modal">
        <div class="um-modal-hd"><h3><%: T("Confirm Upload","Sahkan Muat Naik") %></h3><button type="button" class="um-modal-close" onclick="closeModal()">&#215;</button></div>
        <div class="um-modal-body"><p><%: T("Upload this material?","Muat naik bahan ini?") %></p></div>
        <div class="um-modal-ft">
            <button type="button" class="um-btn um-btn-cancel" onclick="closeModal()"><%: T("Cancel","Batal") %></button>
            <asp:Button ID="btnUpload" runat="server" Text="Upload" OnClick="btnUpload_Click" CausesValidation="false" CssClass="um-btn um-btn-primary" />
        </div>
    </div>
</div>

<asp:HiddenField ID="hidToast" runat="server" Value="" />
<div class="um-toast-wrap" id="toastWrap"></div>
</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
var ALLOWED=['pdf','doc','docx','ppt','pptx','jpg','jpeg','png','mp4'];
var fileOk=false;
function setLang(v){document.getElementById('<%=hidLanguage.ClientID%>').value=v;
    document.getElementById('bEN').className='um-lang-btn'+(v==='EN'?' active':'');
    document.getElementById('bBM').className='um-lang-btn'+(v==='BM'?' active':'');}
function handleFile(inp){
    hide('vFile');var dz=document.getElementById('dropZone');dz.classList.remove('invalid');
    if(!inp.files||!inp.files[0])return;var f=inp.files[0],ext=f.name.split('.').pop().toLowerCase();
    if(ALLOWED.indexOf(ext)===-1){show('vFile');dz.classList.add('invalid');inp.value='';return;}
    if(f.size>100*1024*1024){show('vFile');dz.classList.add('invalid');inp.value='';return;}
    fileOk=true;dz.style.display='none';
    var card=document.getElementById('fileCard');card.style.display='flex';
    document.getElementById('fName').textContent=f.name;
    document.getElementById('fMeta').textContent=fmtSize(f.size)+' \u2022 '+ext.toUpperCase();
    var ico=document.getElementById('fIco');ico.className='um-file-ico '+getIcoCss(ext);
    ico.innerHTML='<i class="bi '+getIcoClass(ext)+'"></i>';}
function removeFile(e){e.stopPropagation();fileOk=false;document.getElementById('<%=fuFile.ClientID%>').value='';
    document.getElementById('dropZone').style.display='block';document.getElementById('fileCard').style.display='none';}
function getIcoCss(x){if(x==='pdf')return'um-ico-pdf';if(x==='doc'||x==='docx')return'um-ico-doc';if(x==='ppt'||x==='pptx')return'um-ico-ppt';if(x==='jpg'||x==='jpeg'||x==='png')return'um-ico-img';if(x==='mp4')return'um-ico-vid';return'um-ico-oth';}
function getIcoClass(x){if(x==='pdf')return'bi-file-earmark-pdf-fill';if(x==='doc'||x==='docx')return'bi-file-earmark-word-fill';if(x==='ppt'||x==='pptx')return'bi-file-earmark-slides-fill';if(x==='jpg'||x==='jpeg'||x==='png')return'bi-file-earmark-image-fill';if(x==='mp4')return'bi-file-earmark-play-fill';return'bi-file-earmark-fill';}
function fmtSize(b){if(b<1024)return b+' B';if(b<1048576)return(b/1024).toFixed(1)+' KB';return(b/1048576).toFixed(1)+' MB';}
function show(id){document.getElementById(id).classList.add('show');}
function hide(id){document.getElementById(id).classList.remove('show');}
function validateForm(){
    var ok=true;
    var t=document.querySelector('[id$="txtTitle"]');if(!t.value.trim()){show('vTitle');t.classList.add('invalid');ok=false;}else{hide('vTitle');t.classList.remove('invalid');}
    var u=document.querySelector('[id$="ddlUnit"]');if(!u.value){show('vUnit');u.classList.add('invalid');ok=false;}else{hide('vUnit');u.classList.remove('invalid');}
    var lv=document.querySelector('[id$="ddlLevel"]');if(!lv.value){show('vLevel');lv.classList.add('invalid');ok=false;}else{hide('vLevel');lv.classList.remove('invalid');}
    var s=document.querySelector('[id$="ddlSubtopic"]');if(!s.value){show('vSub');s.classList.add('invalid');ok=false;}else{hide('vSub');s.classList.remove('invalid');}
    if(!fileOk){show('vFile');document.getElementById('dropZone').classList.add('invalid');ok=false;}else{hide('vFile');}
    if(ok)document.getElementById('confirmModal').style.display='flex';}
function closeModal(){document.getElementById('confirmModal').style.display='none';}
// Drag & drop
var dz=document.getElementById('dropZone');
if(dz){['dragenter','dragover'].forEach(function(ev){dz.addEventListener(ev,function(e){e.preventDefault();dz.classList.add('dragover');});});
['dragleave','drop'].forEach(function(ev){dz.addEventListener(ev,function(e){e.preventDefault();dz.classList.remove('dragover');});});
dz.addEventListener('drop',function(e){var dt=e.dataTransfer;if(dt.files&&dt.files[0]){var inp=document.getElementById('<%=fuFile.ClientID%>');inp.files=dt.files;handleFile(inp);}});}
// Toast
window.addEventListener('load',function(){var h=document.getElementById('<%=hidToast.ClientID%>');if(h&&h.value){var w=document.getElementById('toastWrap'),t=document.createElement('div');t.className='um-toast';t.innerHTML='<i class="bi bi-check-circle-fill"></i> '+h.value;w.appendChild(t);h.value='';setTimeout(function(){t.style.opacity='0';t.style.transition='opacity .3s';},3e3);setTimeout(function(){t.remove();},3500);}});
</script>
</asp:Content>
