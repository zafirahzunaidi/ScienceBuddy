<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="uploadMaterial.aspx.cs"
    Inherits="ScienceBuddy.Teacher.uploadMaterial" MasterPageFile="~/Site.Master" Title="Upload Material" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Teacher.css") %>" rel="stylesheet" />
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label"><%: T("Notifications","Notifikasi") %></span></a></div>
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

<a href="<%: ResolveUrl("~/Teacher/manageMaterials.aspx") %>" class="tc-upload-material-back"><i class="bi bi-arrow-left"></i> <%: T("Back to Materials","Kembali ke Bahan") %></a>
<div class="tc-upload-material-header"><h1><i class="bi bi-cloud-arrow-up" style="color:var(--p);margin-right:.3rem;"></i><%: T("Upload Material","Muat Naik Bahan") %></h1><p><%: T("Upload a new learning material for your students.","Muat naik bahan pembelajaran baharu untuk pelajar.") %></p></div>

<div class="tc-upload-material-card">
    <asp:Panel ID="pnlError" runat="server" Visible="false"><div class="tc-upload-material-error"><i class="bi bi-exclamation-circle"></i> <asp:Literal ID="litError" runat="server" /></div></asp:Panel>

    <%-- Row 1: Title full width --%>
    <div class="tc-upload-material-row-full">
        <div class="tc-upload-material-field">
            <label class="tc-upload-material-label"><%: T("Material Title","Tajuk Bahan") %> *</label>
            <asp:TextBox ID="txtTitle" runat="server" MaxLength="150" CssClass="tc-upload-material-input" placeholder="Enter material title..." />
            <div class="tc-upload-material-val" id="vTitle"><%: T("Material Title is required.","Tajuk Bahan diperlukan.") %></div>
        </div>
    </div>

    <%-- Row 2: Description full width — rich-text editor --%>
    <div class="tc-upload-material-row-full">
        <div class="tc-upload-material-field">
            <label class="tc-upload-material-label"><%: T("Description","Penerangan") %></label>
            <%-- Hidden textarea — stays connected to backend unchanged --%>
            <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="4"
                CssClass="tc-upload-material-input tc-upload-material-textarea" placeholder="Describe what this material covers..."
                ValidateRequestMode="Disabled" style="display:none;" />
            <%-- Rich-text editor shell --%>
            <div class="tc-upload-material-rte-wrap" id="rteWrap">
                <div class="tc-upload-material-rte-toolbar" id="rteToolbar">
                    <button type="button" class="tc-upload-material-rte-btn" id="rteBold"    title="Bold (Ctrl+B)"      onclick="rteCmd('bold')"><i class="bi bi-type-bold"></i></button>
                    <button type="button" class="tc-upload-material-rte-btn" id="rteItalic"  title="Italic (Ctrl+I)"    onclick="rteCmd('italic')"><i class="bi bi-type-italic"></i></button>
                    <button type="button" class="tc-upload-material-rte-btn" id="rteUnder"   title="Underline (Ctrl+U)" onclick="rteCmd('underline')"><i class="bi bi-type-underline"></i></button>
                    <div class="tc-upload-material-rte-sep"></div>
                    <button type="button" class="tc-upload-material-rte-btn" id="rteBullet"  title="Bulleted List"      onclick="rteCmd('insertUnorderedList')"><i class="bi bi-list-ul"></i></button>
                    <button type="button" class="tc-upload-material-rte-btn" id="rteNumber"  title="Numbered List"      onclick="rteCmd('insertOrderedList')"><i class="bi bi-list-ol"></i></button>
                </div>
                <div class="tc-upload-material-rte-editor" id="rteEditor" contenteditable="true"
                     data-placeholder="Describe what this material covers..."></div>
            </div>
        </div>
    </div>

    <%-- Row 3: Language 15% + Level 20% + Unit 30% + Subtopic 35%
         UpdatePanel keeps dropdown cascading partial — no full reload --%>
    <asp:UpdatePanel ID="upDropdowns" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
    <div class="tc-upload-material-row-3col">
        <div class="tc-upload-material-field">
            <label class="tc-upload-material-label"><%: T("Language","Bahasa") %> *</label>
            <asp:HiddenField ID="hidLanguage" runat="server" Value="EN" />
            <div class="tc-upload-material-lang-group" id="langGrp">
                <button type="button" class="tc-upload-material-lang-btn active" id="bEN" onclick="setLang('EN')">EN</button>
                <button type="button" class="tc-upload-material-lang-btn" id="bBM" onclick="setLang('BM')">BM</button>
            </div>
        </div>
        <div class="tc-upload-material-field">
            <label class="tc-upload-material-label"><%: T("Level","Tahap") %> *</label>
            <asp:DropDownList ID="ddlLevel" runat="server" CssClass="tc-upload-material-input" AutoPostBack="true" OnSelectedIndexChanged="ddlLevel_Changed" />
            <div class="tc-upload-material-val" id="vLevel"><%: T("Select Level.","Pilih Tahap.") %></div>
        </div>
        <div class="tc-upload-material-field">
            <label class="tc-upload-material-label"><%: T("Unit","Unit") %> *</label>
            <asp:DropDownList ID="ddlUnit" runat="server" CssClass="tc-upload-material-input" AutoPostBack="true" OnSelectedIndexChanged="ddlUnit_Changed" />
            <div class="tc-upload-material-val" id="vUnit"><%: T("Select Unit.","Pilih Unit.") %></div>
        </div>
        <div class="tc-upload-material-field">
            <label class="tc-upload-material-label"><%: T("Subtopic","Subtopik") %> *</label>
            <asp:DropDownList ID="ddlSubtopic" runat="server" CssClass="tc-upload-material-input" />
            <div class="tc-upload-material-val" id="vSub"><%: T("Select Subtopic.","Pilih Subtopik.") %></div>
        </div>
    </div>
    </ContentTemplate>
    </asp:UpdatePanel>

    <%-- Row 4: Upload File full width --%>
    <div class="tc-upload-material-row-full">
        <div class="tc-upload-material-field">
            <label class="tc-upload-material-label"><%: T("Upload File","Muat Naik Fail") %> *</label>
            <div class="tc-upload-material-drop" id="dropZone" onclick="document.getElementById('<%=fuFile.ClientID%>').click();">
                <div class="tc-upload-material-drop-content" id="dzContent">
                    <i class="bi bi-cloud-arrow-up-fill"></i>
                    <p><%: T("Drag & drop or click to browse","Seret & lepas atau klik untuk semak imbas") %></p>
                    <p class="tc-upload-material-drop-sub">PDF, DOC, DOCX, PPT, PPTX, JPG, PNG, MP4 (max 100 MB)</p>
                </div>
            </div>
            <div class="tc-upload-material-file-card" id="fileCard" style="display:none;">
                <div class="tc-upload-material-file-ico" id="fIco"><i class="bi bi-file-earmark-fill"></i></div>
                <div class="tc-upload-material-file-info"><span class="tc-upload-material-file-name" id="fName"></span><span class="tc-upload-material-file-meta" id="fMeta"></span></div>
                <button type="button" class="tc-upload-material-file-rm" onclick="removeFile(event)"><i class="bi bi-x-lg"></i></button>
            </div>
            <div class="tc-upload-material-val" id="vFile"><%: T("Please upload a file.","Sila muat naik fail.") %></div>
            <asp:FileUpload ID="fuFile" runat="server" style="display:none;" onchange="handleFile(this)" />
        </div>
    </div>

    <%-- Actions --%>
    <div class="tc-upload-material-actions">
        <a href="<%: ResolveUrl("~/Teacher/manageMaterials.aspx") %>" class="tc-upload-material-btn tc-upload-material-btn-cancel"><%: T("Cancel","Batal") %></a>
        <button type="button" class="tc-upload-material-btn tc-upload-material-btn-primary" onclick="validateForm()"><i class="bi bi-cloud-arrow-up"></i> <%: T("Upload Material","Muat Naik Bahan") %></button>
    </div>
</div>

<%-- Confirm Modal --%>
<div id="confirmModal" class="tc-upload-material-modal-overlay" style="display:none;">
    <div class="tc-upload-material-modal">
        <div class="tc-upload-material-modal-hd"><h3><%: T("Confirm Upload","Sahkan Muat Naik") %></h3><button type="button" class="tc-upload-material-modal-close" onclick="closeModal()">&#215;</button></div>
        <div class="tc-upload-material-modal-body"><p><%: T("Upload this material?","Muat naik bahan ini?") %></p></div>
        <div class="tc-upload-material-modal-ft">
            <button type="button" class="tc-upload-material-btn tc-upload-material-btn-cancel" onclick="closeModal()"><%: T("Cancel","Batal") %></button>
            <asp:Button ID="btnUpload" runat="server" Text="Upload" OnClick="btnUpload_Click" CausesValidation="false" CssClass="tc-upload-material-btn tc-upload-material-btn-primary" />
        </div>
    </div>
</div>

<%-- Unsaved Changes Modal --%>
<div class="tc-upload-material-unsaved-overlay" id="umUnsavedOverlay">
    <div class="tc-upload-material-unsaved-modal">
        <div class="tc-upload-material-unsaved-icon"><i class="bi bi-exclamation-triangle-fill"></i></div>
        <h3><%: T("Unsaved Changes","Perubahan Belum Disimpan") %></h3>
        <p><%: T("Your unsaved material will be discarded. Are you sure you want to leave this page?","Bahan anda yang belum disimpan akan dibuang. Adakah anda pasti mahu meninggalkan halaman ini?") %></p>
        <div class="tc-upload-material-unsaved-actions">
            <button type="button" class="tc-upload-material-unsaved-cancel" onclick="document.getElementById('umUnsavedOverlay').classList.remove('open')"><%: T("Cancel","Batal") %></button>
            <button type="button" class="tc-upload-material-unsaved-confirm" id="umUnsavedConfirm"><%: T("Confirm","Sahkan") %></button>
        </div>
    </div>
</div>

<asp:HiddenField ID="hidToast" runat="server" Value="" />
<div class="tc-upload-material-toast-wrap" id="toastWrap"></div>
</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
var ALLOWED=['pdf','doc','docx','ppt','pptx','jpg','jpeg','png','mp4'];
var fileOk=false;
function setLang(v){document.getElementById('<%=hidLanguage.ClientID%>').value=v;
    document.getElementById('bEN').className='tc-upload-material-lang-btn'+(v==='EN'?' active':'');
    document.getElementById('bBM').className='tc-upload-material-lang-btn'+(v==='BM'?' active':'');}
function handleFile(inp){
    hide('vFile');var dz=document.getElementById('dropZone');dz.classList.remove('invalid');
    if(!inp.files||!inp.files[0])return;var f=inp.files[0],ext=f.name.split('.').pop().toLowerCase();
    if(ALLOWED.indexOf(ext)===-1){show('vFile');dz.classList.add('invalid');inp.value='';return;}
    if(f.size>100*1024*1024){document.getElementById('vFile').textContent='The selected file exceeds the 100 MB upload limit. Please choose a smaller file.';show('vFile');dz.classList.add('invalid');inp.value='';fileOk=false;return;}
    fileOk=true;dz.style.display='none';
    var card=document.getElementById('fileCard');card.style.display='flex';
    document.getElementById('fName').textContent=f.name;
    document.getElementById('fMeta').textContent=fmtSize(f.size)+' \u2022 '+ext.toUpperCase();
    var ico=document.getElementById('fIco');ico.className='tc-upload-material-file-ico '+getIcoCss(ext);
    ico.innerHTML='<i class="bi '+getIcoClass(ext)+'"></i>';}
function removeFile(e){e.stopPropagation();fileOk=false;document.getElementById('<%=fuFile.ClientID%>').value='';
    document.getElementById('dropZone').style.display='block';document.getElementById('fileCard').style.display='none';}
function getIcoCss(x){if(x==='pdf')return'tc-upload-material-ico-pdf';if(x==='doc'||x==='docx')return'tc-upload-material-ico-doc';if(x==='ppt'||x==='pptx')return'tc-upload-material-ico-ppt';if(x==='jpg'||x==='jpeg'||x==='png')return'tc-upload-material-ico-img';if(x==='mp4')return'tc-upload-material-ico-vid';return'tc-upload-material-ico-oth';}
function getIcoClass(x){if(x==='pdf')return'bi-file-earmark-pdf-fill';if(x==='doc'||x==='docx')return'bi-file-earmark-word-fill';if(x==='ppt'||x==='pptx')return'bi-file-earmark-slides-fill';if(x==='jpg'||x==='jpeg'||x==='png')return'bi-file-earmark-image-fill';if(x==='mp4')return'bi-file-earmark-play-fill';return'bi-file-earmark-fill';}
function fmtSize(b){if(b<1024)return b+' B';if(b<1048576)return(b/1024).toFixed(1)+' KB';return(b/1048576).toFixed(1)+' MB';}
function show(id){document.getElementById(id).classList.add('show');}
function hide(id){document.getElementById(id).classList.remove('show');}
function validateForm(){
    // sync RTE → hidden textarea before validation
    syncRteToTextarea();
    var ok=true;
    var t=document.querySelector('[id$="txtTitle"]');if(!t.value.trim()){show('vTitle');t.classList.add('invalid');ok=false;}else{hide('vTitle');t.classList.remove('invalid');}
    var u=document.querySelector('[id$="ddlUnit"]');if(!u.value){show('vUnit');u.classList.add('invalid');ok=false;}else{hide('vUnit');u.classList.remove('invalid');}
    var lv=document.querySelector('[id$="ddlLevel"]');if(!lv.value){show('vLevel');lv.classList.add('invalid');ok=false;}else{hide('vLevel');lv.classList.remove('invalid');}
    var s=document.querySelector('[id$="ddlSubtopic"]');if(!s.value){show('vSub');s.classList.add('invalid');ok=false;}else{hide('vSub');s.classList.remove('invalid');}
    if(!fileOk){document.getElementById('vFile').textContent='<%: T("Please upload a file.","Sila muat naik fail.") %>';show('vFile');document.getElementById('dropZone').classList.add('invalid');ok=false;}else{hide('vFile');}
    if(ok)document.getElementById('confirmModal').style.display='flex';}
function closeModal(){document.getElementById('confirmModal').style.display='none';}

/* ── Rich-text editor logic ─────────────────────────────── */
(function(){
    var editor  = document.getElementById('rteEditor');
    var wrap    = document.getElementById('rteWrap');
    var txDesc  = document.querySelector('[id$="txtDescription"]');

    if(!editor||!txDesc) return;

    /* Populate editor from textarea value on page load (postback round-trip) */
    if(txDesc.value.trim()){
        editor.innerHTML = txDesc.value;
    }

    /* Sync editor HTML → hidden textarea */
    window.syncRteToTextarea = function(){
        if(!txDesc||!editor) return;
        /* Strip completely empty editor state */
        var html = editor.innerHTML.trim();
        if(html === '<br>' || html === '') html = '';
        txDesc.value = html;
    };

    /* execCommand wrapper — re-focus editor then execute */
    window.rteCmd = function(cmd){
        editor.focus();
        document.execCommand(cmd, false, null);
        updateToolbarState();
    };

    /* Keep toolbar button active states in sync with cursor position */
    function updateToolbarState(){
        var cmds = {bold:'rteBold', italic:'rteItalic', underline:'rteUnder',
                    insertUnorderedList:'rteBullet', insertOrderedList:'rteNumber'};
        Object.keys(cmds).forEach(function(c){
            var btn = document.getElementById(cmds[c]);
            if(!btn) return;
            try{
                btn.classList.toggle('active', document.queryCommandState(c));
            }catch(e){}
        });
    }

    editor.addEventListener('keyup',   updateToolbarState);
    editor.addEventListener('mouseup', updateToolbarState);
    editor.addEventListener('focus',   updateToolbarState);

    /* Strip pasted rich formatting — keep plain text only, then re-apply via execCommand */
    editor.addEventListener('paste', function(e){
        e.preventDefault();
        var txt = (e.clipboardData || window.clipboardData).getData('text/plain');
        document.execCommand('insertText', false, txt);
    });

    /* Sync on every input so the hidden field is always up to date */
    /* editor.addEventListener('input', function(){ syncRteToTextarea(); }); */
    /* Sync happens only on submit — see validateForm() and btnUpload click below */

    /* Also sync before the modal upload button triggers the postback + loading state */
    var btnUpload = document.querySelector('[id$="btnUpload"]');
    if(btnUpload){
        btnUpload.addEventListener('click', function(e){
            syncRteToTextarea();
            if(btnUpload.getAttribute('data-uploading')==='true'){e.preventDefault();return false;}
            btnUpload.setAttribute('data-uploading','true');
            // Delay disabling so the form submission is not cancelled by the browser
            setTimeout(function(){
                btnUpload.disabled=true;
                btnUpload.value='Uploading material...';
                btnUpload.style.opacity='0.7';btnUpload.style.cursor='not-allowed';
            },0);
        });
    }
})();
// Drag & drop
var dz=document.getElementById('dropZone');
if(dz){['dragenter','dragover'].forEach(function(ev){dz.addEventListener(ev,function(e){e.preventDefault();dz.classList.add('dragover');});});
['dragleave','drop'].forEach(function(ev){dz.addEventListener(ev,function(e){e.preventDefault();dz.classList.remove('dragover');});});
dz.addEventListener('drop',function(e){var dt=e.dataTransfer;if(dt.files&&dt.files[0]){var inp=document.getElementById('<%=fuFile.ClientID%>');inp.files=dt.files;handleFile(inp);}});}
// Toast
window.addEventListener('load',function(){var h=document.getElementById('<%=hidToast.ClientID%>');if(h&&h.value){var w=document.getElementById('toastWrap'),t=document.createElement('div');t.className='tc-upload-material-toast';t.innerHTML='<i class="bi bi-check-circle-fill"></i> '+h.value;w.appendChild(t);h.value='';setTimeout(function(){t.style.opacity='0';t.style.transition='opacity .3s';},3e3);setTimeout(function(){t.remove();},3500);/* Reset language buttons and file UI after successful upload */setLang('EN');fileOk=false;document.getElementById('dropZone').style.display='block';document.getElementById('fileCard').style.display='none';/* Reset RTE editor */var rte=document.getElementById('rteEditor');if(rte)rte.innerHTML='';}});

/* ═══ UNSAVED CHANGES DETECTION ═══════════════════════════ */
(function(){
    var dirty=false;
    var pendingUrl='';
    var submitting=false;

    // Mark dirty on input/change in the form card
    var card=document.querySelector('.tc-upload-material-card');
    if(card){
        card.addEventListener('input',function(){dirty=true;},true);
        card.addEventListener('change',function(){dirty=true;},true);
    }
    // RTE editor
    var rte=document.querySelector('.tc-upload-material-rte-editor');
    if(rte)rte.addEventListener('input',function(){dirty=true;});
    // File upload
    var fu=document.getElementById('<%=fuFile.ClientID%>');
    if(fu)fu.addEventListener('change',function(){dirty=true;});

    // Clear dirty on submit
    var form=document.querySelector('form');
    if(form)form.addEventListener('submit',function(){submitting=true;});

    // Clear dirty if toast shows (successful upload)
    window.addEventListener('load',function(){
        var h=document.getElementById('<%=hidToast.ClientID%>');
        if(h&&h.value)dirty=false;
    });

    // Browser native beforeunload
    window.addEventListener('beforeunload',function(e){
        if(dirty&&!submitting){e.preventDefault();e.returnValue='';}
    });

    // Intercept sidebar links + Back to Materials link
    document.querySelectorAll('.sb-sidebar-item, .tc-upload-material-back').forEach(function(link){
        link.addEventListener('click',function(e){
            if(!dirty||submitting)return;
            e.preventDefault();e.stopPropagation();
            pendingUrl=link.getAttribute('href')||link.href;
            document.getElementById('umUnsavedOverlay').classList.add('open');
        });
    });

    // Confirm button — navigate away
    var confirmBtn=document.getElementById('umUnsavedConfirm');
    if(confirmBtn)confirmBtn.addEventListener('click',function(){
        dirty=false;
        document.getElementById('umUnsavedOverlay').classList.remove('open');
        if(pendingUrl)window.location.href=pendingUrl;
    });

    // Close on Escape
    document.addEventListener('keydown',function(e){
        if(e.key==='Escape'&&document.getElementById('umUnsavedOverlay').classList.contains('open'))
            document.getElementById('umUnsavedOverlay').classList.remove('open');
    });
})();
</script>
</asp:Content>
