<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MyProfile.aspx.cs"
    Inherits="ScienceBuddy.Teacher.MyProfile" MasterPageFile="~/Site.Master"
    Title="My Profile" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--tp:#6C63FF;--tp2:#8B5CF6;--tp-h:#5A52E0;--tl:#F5F3FF;--tc:#FFF;--tb:#E5E7EB;--tt:#1F2937;--tm:#6B7280;--ts:#10B981;--te:#EF4444;--tw:#F59E0B;--cyan:#06B6D4;}
/* Hero Banner - Premium */
.mp-hero{background:linear-gradient(135deg,#0F172A 0%,#1E293B 20%,#1E3A5F 45%,#1D4ED8 75%,#3B82F6 100%);border-radius:24px;padding:3rem 2.8rem;color:#fff;display:flex;align-items:center;gap:2.4rem;position:relative;overflow:hidden;margin-bottom:2rem;box-shadow:0 20px 60px rgba(30,64,175,.3);}
.mp-hero::before{content:'';position:absolute;width:400px;height:400px;border-radius:50%;background:radial-gradient(circle,rgba(59,130,246,.15),transparent 70%);top:-120px;right:-80px;}
.mp-hero::after{content:'';position:absolute;width:200px;height:200px;border-radius:50%;background:radial-gradient(circle,rgba(99,102,241,.1),transparent 70%);bottom:-80px;left:40px;}
.mp-avatar{width:96px;height:96px;border-radius:50%;background:linear-gradient(135deg,rgba(255,255,255,.2),rgba(255,255,255,.05));border:3px solid rgba(255,255,255,.3);display:flex;align-items:center;justify-content:center;font-size:2.1rem;font-weight:800;flex-shrink:0;position:relative;z-index:1;backdrop-filter:blur(8px);box-shadow:0 8px 32px rgba(0,0,0,.2);}
.mp-hero-info{position:relative;z-index:1;flex:1;}
.mp-hero-name{font-size:1.85rem;font-weight:800;margin-bottom:6px;letter-spacing:-.4px;background:linear-gradient(90deg,#fff 0%,#E0E7FF 50%,#fff 100%);background-size:200% auto;-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;animation:mpShimmer 4s ease-in-out infinite;}
@keyframes mpShimmer{0%,100%{background-position:0% center;}50%{background-position:200% center;}}
.mp-hero-role{font-size:.88rem;opacity:.75;margin-bottom:12px;font-weight:600;letter-spacing:.3px;}
.mp-hero-meta{display:flex;gap:.6rem;flex-wrap:wrap;align-items:center;}
.mp-badge{padding:6px 14px;border-radius:50px;font-size:.76rem;font-weight:700;display:inline-flex;align-items:center;gap:5px;backdrop-filter:blur(4px);}
.mp-badge-green{background:rgba(16,185,129,.2);color:#6EE7B7;border:1px solid rgba(16,185,129,.35);}
.mp-badge-orange{background:rgba(245,158,11,.2);color:#FCD34D;border:1px solid rgba(245,158,11,.35);}
.mp-badge-red{background:rgba(239,68,68,.2);color:#FCA5A5;border:1px solid rgba(239,68,68,.35);}
.mp-badge-grey{background:rgba(255,255,255,.1);color:rgba(255,255,255,.85);border:1px solid rgba(255,255,255,.2);}
.mp-hero-bio{font-size:.9rem;opacity:.82;margin-top:14px;line-height:1.7;max-width:540px;}
/* Grid & Cards */
.mp-grid{display:grid;grid-template-columns:1fr 1fr;gap:1.5rem;margin-bottom:1.8rem;}
.mp-card{background:var(--tc);border:1.5px solid var(--tb);border-radius:18px;padding:1.8rem;box-shadow:0 4px 16px rgba(0,0,0,.05);transition:transform .2s,box-shadow .2s;}
.mp-card:hover{transform:translateY(-2px);box-shadow:0 8px 28px rgba(108,99,255,.1);}
.mp-card-title{font-size:1rem;font-weight:800;color:var(--tt);margin-bottom:1.2rem;display:flex;align-items:center;gap:9px;}
.mp-card-title i{color:var(--tp);font-size:1.15rem;}
.mp-field{margin-bottom:1.1rem;}.mp-field:last-child{margin-bottom:0;}
.mp-field-label{font-size:.78rem;font-weight:700;color:var(--tm);text-transform:uppercase;letter-spacing:.5px;margin-bottom:5px;}
.mp-field-value{font-size:.94rem;font-weight:600;color:var(--tt);}
.mp-input{width:100%;border-radius:10px;border:1.5px solid var(--tb);padding:.65rem .9rem;font-size:.9rem;transition:all .2s;}
.mp-input:focus{border-color:var(--tp);outline:none;box-shadow:0 0 0 3px rgba(108,99,255,.08);}
.mp-input.invalid{border-color:var(--te);box-shadow:0 0 0 3px rgba(239,68,68,.08);}
.mp-textarea{min-height:110px;resize:vertical;line-height:1.6;}
.mp-char{font-size:.74rem;color:var(--tm);text-align:right;margin-top:4px;}
.mp-val-msg{font-size:.76rem;color:var(--te);margin-top:4px;display:none;}.mp-val-msg.show{display:block;}
/* Progress - Cyan/Teal */
.mp-progress-card{background:var(--tc);border:1.5px solid var(--tb);border-radius:18px;padding:1.4rem 1.6rem;margin-bottom:1.5rem;display:flex;align-items:center;gap:1.4rem;box-shadow:0 4px 16px rgba(0,0,0,.05);}
.mp-pct{font-size:1.6rem;font-weight:800;color:#0891B2;}
.mp-progress-bar{flex:1;height:10px;background:#ECFEFF;border-radius:10px;overflow:hidden;}
.mp-progress-fill{height:100%;background:linear-gradient(90deg,#06B6D4,#22D3EE);border-radius:10px;transition:width .6s ease;}
.mp-progress-msg{font-size:.82rem;color:var(--tm);font-weight:600;}
/* Certificate */
.mp-cert-file{display:flex;align-items:center;gap:14px;padding:1.1rem 1.3rem;background:#FAFAFA;border-radius:14px;border:1.5px solid #F0F0F0;}
.mp-cert-icon{width:50px;height:50px;border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:1.5rem;flex-shrink:0;}
.mp-cert-icon.pdf{background:#FEF2F2;color:#DC2626;}
.mp-cert-icon.img{background:#ECFDF5;color:#059669;}
.mp-cert-icon.doc{background:#EFF6FF;color:#2563EB;}
.mp-cert-icon.ppt{background:#FFF7ED;color:#EA580C;}
.mp-cert-icon.other{background:#F3F4F6;color:#6B7280;}
.mp-cert-name{font-size:.95rem;font-weight:700;color:var(--tt);}
.mp-cert-btn{font-size:.82rem;font-weight:700;color:var(--tp);text-decoration:none;padding:8px 16px;border-radius:10px;border:1.5px solid var(--tb);background:var(--tc);transition:all .2s;cursor:pointer;}
.mp-cert-btn:hover{border-color:var(--tp);background:var(--tl);color:var(--tp-h);}
.mp-cert-date{font-size:.78rem;font-weight:700;color:var(--ts);margin-top:4px;display:flex;align-items:center;gap:4px;}
/* Certificate Modal */
.mp-cert-modal-overlay{position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,.6);z-index:9999;display:none;align-items:center;justify-content:center;padding:1.5rem;}
.mp-cert-modal-overlay.active{display:flex;}
.mp-cert-modal{background:#fff;border-radius:18px;width:100%;max-width:820px;max-height:88vh;display:flex;flex-direction:column;box-shadow:0 24px 64px rgba(0,0,0,.25);}
.mp-cert-modal-hd{display:flex;align-items:center;justify-content:space-between;padding:1.2rem 1.6rem;border-bottom:1px solid var(--tb);}
.mp-cert-modal-hd h4{margin:0;font-size:1rem;font-weight:800;color:var(--tt);}
.mp-cert-modal-close{background:none;border:none;font-size:1.5rem;color:var(--tm);cursor:pointer;line-height:1;padding:4px;border-radius:6px;transition:background .15s;}
.mp-cert-modal-close:hover{background:#F3F4F6;color:var(--tt);}
.mp-cert-modal-body{flex:1;overflow:auto;padding:0;}
.mp-cert-modal-body iframe,.mp-cert-modal-body img{width:100%;height:100%;min-height:500px;border:none;display:block;}
/* Permissions - Minimal */
.mp-perm-list{list-style:none;padding:0;margin:0;}
.mp-perm-list li{display:flex;align-items:center;padding:.7rem 0;font-size:.88rem;border-bottom:1px solid #F3F4F6;transition:background .12s,padding .12s;}
.mp-perm-list li:last-child{border-bottom:none;}
.mp-perm-list li:hover{background:#FAFAFA;padding-left:.5rem;padding-right:.5rem;border-radius:8px;}
.mp-perm-ico{width:22px;height:22px;display:flex;align-items:center;justify-content:center;font-size:.82rem;flex-shrink:0;margin-right:10px;}
.mp-perm-name{flex:1;font-weight:600;color:var(--tt);}
.mp-perm-status{font-size:.78rem;font-weight:700;padding:3px 10px;border-radius:6px;}
.mp-perm-status.allowed{color:#047857;background:#ECFDF5;}
.mp-perm-status.restricted{color:#6B7280;background:#F3F4F6;}
.mp-perm-list li.enabled .mp-perm-ico{color:#059669;}
.mp-perm-list li.restricted .mp-perm-ico{color:#9CA3AF;}
/* Actions */
.mp-actions{display:flex;gap:.85rem;justify-content:flex-end;margin-top:1.8rem;}
.mp-btn{padding:.7rem 1.6rem;border-radius:12px;font-size:.9rem;font-weight:700;cursor:pointer;border:none;transition:all .2s;}
.mp-btn:hover{transform:translateY(-1px);}
.mp-btn-primary{background:linear-gradient(135deg,var(--tp),var(--tp2));color:#fff;box-shadow:0 4px 14px rgba(108,99,255,.25);}
.mp-btn-primary:hover{box-shadow:0 6px 22px rgba(108,99,255,.35);}
.mp-btn-cancel{background:var(--tc);color:var(--tt);border:1.5px solid var(--tb);}
/* Toast */
.mp-toast-container{position:fixed;top:1.25rem;right:1.25rem;z-index:9999;display:flex;flex-direction:column;gap:.5rem;}
.mp-toast{background:#10B981;color:#fff;padding:.8rem 1.3rem;border-radius:12px;font-size:.88rem;font-weight:600;display:flex;align-items:center;gap:8px;box-shadow:0 8px 24px rgba(16,185,129,.3);animation:mpSlide .3s ease;}
.mp-toast-out{opacity:0;transform:translateX(30px);transition:all .4s;}
@keyframes mpSlide{from{opacity:0;transform:translateX(30px);}to{opacity:1;transform:translateX(0);}}
@media(max-width:768px){.mp-hero{flex-direction:column;text-align:center;padding:2rem 1.5rem;}.mp-grid{grid-template-columns:1fr;}.mp-actions{flex-direction:column;}.mp-cert-modal{max-width:100%;border-radius:12px;}}
</style>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Teaching","Pengajaran") %></div>
        <a href="<%: ResolveUrl("~/Teacher/manageMaterials.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label"><%: T("Manage Materials","Bahan Pembelajaran") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label"><%: T("Manage Quiz","Kuiz") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/studentProgress.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bar-chart item-icon"></i><span class="item-label"><%: T("Student Progress","Prestasi Pelajar") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/liveSession.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label"><%: T("Schedule Live Class","Kelas Langsung") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Community","Komuniti") %></div>
        <a href="<%: ResolveUrl("~/Teacher/forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/privateMessages.aspx") %>" class="sb-sidebar-item"><i class="bi bi-envelope item-icon"></i><span class="item-label"><%: T("Private Message","Mesej Peribadi") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Account","Akaun") %></div>
        <a href="<%: ResolveUrl("~/Teacher/MyProfile.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("My Profile","Profil Saya") %></span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Sign Out","Log Keluar") %></span></a></div>
</asp:Content>
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("My Profile","Profil Saya") %></asp:Content>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- Hero --%>
<div class="mp-hero">
    <div class="mp-avatar"><asp:Literal ID="litInitials" runat="server" Text="T" /></div>
    <div class="mp-hero-info">
        <div class="mp-hero-name"><asp:Literal ID="litName" runat="server" /></div>
        <div class="mp-hero-role">ScienceBuddy Teacher</div>
        <div class="mp-hero-meta">
            <asp:Literal ID="litStatusBadge" runat="server" />
            <span class="mp-badge mp-badge-grey"><i class="bi bi-hash"></i> <asp:Literal ID="litTeacherId" runat="server" /></span>
        </div>
        <div class="mp-hero-bio"><asp:Literal ID="litBioPreview" runat="server" /></div>
    </div>
</div>

<%-- Profile Completion --%>
<div class="mp-progress-card">
    <div class="mp-pct"><asp:Literal ID="litPct" runat="server" Text="0" />%</div>
    <div style="flex:1;">
        <div class="mp-progress-bar"><div class="mp-progress-fill" style="width:<%= litPct.Text %>%"></div></div>
        <div class="mp-progress-msg" style="margin-top:6px;"><asp:Literal ID="litProgressMsg" runat="server" /></div>
    </div>
</div>

<%-- Cards Grid --%>
<div class="mp-grid">

<%-- Personal Info --%>
<div class="mp-card">
    <div class="mp-card-title"><i class="bi bi-person-circle"></i> <%: T("Personal Information","Maklumat Peribadi") %></div>
    <div class="mp-field"><div class="mp-field-label"><%: T("Full Name","Nama Penuh") %> *</div>
        <asp:TextBox ID="txtName" runat="server" CssClass="mp-input" MaxLength="100" />
        <div class="mp-val-msg" id="valName"></div>
    </div>
    <div class="mp-field"><div class="mp-field-label"><%: T("Teacher ID","ID Guru") %></div><div class="mp-field-value"><asp:Literal ID="litTID" runat="server" /></div></div>
    <div class="mp-field"><div class="mp-field-label"><%: T("Academic Qualification","Kelayakan Akademik") %></div><div class="mp-field-value"><asp:Literal ID="litQual" runat="server" /></div></div>
    <div class="mp-field">
        <div class="mp-field-label"><%: T("Phone Number","Nombor Telefon") %> *</div>
        <asp:TextBox ID="txtPhone" runat="server" CssClass="mp-input" MaxLength="15" />
        <div class="mp-val-msg" id="valPhone"></div>
    </div>
    <div class="mp-field">
        <div class="mp-field-label"><%: T("Biography","Biografi") %></div>
        <asp:TextBox ID="txtBio" runat="server" TextMode="MultiLine" Rows="4" CssClass="mp-input mp-textarea" MaxLength="500" />
        <div class="mp-char" id="bioCounter">0 / 500</div>
    </div>
</div>

<%-- Certificate + Verification + Access --%>
<div style="display:flex;flex-direction:column;gap:1.5rem;">

<div class="mp-card">
    <div class="mp-card-title"><i class="bi bi-file-earmark-check-fill"></i> <%: T("Teaching Certificate","Sijil Pengajaran") %></div>
    <asp:Panel ID="pnlCertExists" runat="server" Visible="false">
        <div class="mp-cert-file">
            <div class="mp-cert-icon" id="certIconDiv" runat="server"><i id="certIconI" runat="server" class="bi bi-file-earmark-fill"></i></div>
            <div style="flex:1;">
                <div class="mp-cert-name"><asp:Literal ID="litCertName" runat="server" /></div>
                <asp:Panel ID="pnlApprovedDate" runat="server" Visible="false">
                    <div class="mp-cert-date"><i class="bi bi-calendar-check"></i> <%: T("Approved","Diluluskan") %>: <asp:Literal ID="litApprovedDate" runat="server" /></div>
                </asp:Panel>
            </div>
            <a id="lnkCert" runat="server" class="mp-cert-btn" onclick="openCertModal(event);return false;"><i class="bi bi-eye"></i> <%: T("View","Lihat") %></a>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlCertEmpty" runat="server" Visible="false">
        <div style="text-align:center;padding:2rem;color:var(--tm);">
            <i class="bi bi-file-earmark-x" style="font-size:2.5rem;opacity:.4;"></i>
            <p style="font-size:.88rem;margin-top:.6rem;font-weight:600;"><%: T("No teaching certificate uploaded.","Tiada sijil pengajaran dimuat naik.") %></p>
        </div>
    </asp:Panel>
</div>

<div class="mp-card">
    <div class="mp-card-title"><i class="bi bi-shield-check"></i> <%: T("Teacher Access Status","Status Akses Guru") %></div>
    <asp:Panel ID="pnlVerCertified" runat="server" Visible="false">
        <div style="display:inline-flex;align-items:center;gap:6px;padding:5px 12px;background:#ECFDF5;border-radius:8px;font-size:.82rem;font-weight:700;color:#047857;margin-bottom:1rem;">
            <i class="bi bi-patch-check-fill"></i> <%: T("Verified Educator","Pendidik Disahkan") %>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlVerPending" runat="server" Visible="false">
        <div style="display:inline-flex;align-items:center;gap:6px;padding:5px 12px;background:#FEF3C7;border-radius:8px;font-size:.82rem;font-weight:700;color:#92400E;margin-bottom:1rem;">
            <i class="bi bi-hourglass-split"></i> <%: T("Pending Verification","Pengesahan Belum Selesai") %>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlVerRejected" runat="server" Visible="false">
        <div style="display:inline-flex;align-items:center;gap:6px;padding:5px 12px;background:#FEF2F2;border-radius:8px;font-size:.82rem;font-weight:700;color:#B91C1C;margin-bottom:1rem;">
            <i class="bi bi-x-circle-fill"></i> <%: T("Verification Rejected","Pengesahan Ditolak") %>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlVerUnknown" runat="server" Visible="false">
        <div style="display:inline-flex;align-items:center;gap:6px;padding:5px 12px;background:#F3F4F6;border-radius:8px;font-size:.82rem;font-weight:700;color:var(--tm);margin-bottom:1rem;">
            <i class="bi bi-question-circle"></i> <%: T("Status unavailable","Status tidak tersedia") %>
        </div>
    </asp:Panel>

    <asp:Literal ID="litPermissions" runat="server" />
</div>

</div>
</div>

<%-- Actions --%>
<div class="mp-actions">
    <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="mp-btn mp-btn-cancel" OnClick="btnCancel_Click" CausesValidation="false" />
    <asp:Button ID="btnSave" runat="server" Text="Save Changes" CssClass="mp-btn mp-btn-primary" OnClick="btnSave_Click" CausesValidation="false" />
</div>

<asp:HiddenField ID="hidToast" runat="server" Value="" />
<div id="mpToast" class="mp-toast-container"></div>

<%-- Certificate View Modal --%>
<div id="certModal" class="mp-cert-modal-overlay" onclick="if(event.target===this)closeCertModal()">
    <div class="mp-cert-modal">
        <div class="mp-cert-modal-hd">
            <h4><i class="bi bi-file-earmark-text"></i> <%: T("Teaching Certificate","Sijil Pengajaran") %></h4>
            <button type="button" class="mp-cert-modal-close" onclick="closeCertModal()">&times;</button>
        </div>
        <div class="mp-cert-modal-body" id="certModalBody"></div>
    </div>
</div>
</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
var bio=document.querySelector('[id$="txtBio"]');
if(bio){bio.addEventListener('input',function(){document.getElementById('bioCounter').textContent=this.value.length+' / 500';});}
// Certificate modal
function openCertModal(e){
    e.preventDefault();
    var link=e.currentTarget;
    var url=link.getAttribute('href');
    var body=document.getElementById('certModalBody');
    var ext=(url.split('.').pop()||'').toLowerCase().split('?')[0];
    if(ext==='pdf'){body.innerHTML='<iframe src="'+url+'" style="width:100%;height:560px;border:none;"></iframe>';}
    else if(['png','jpg','jpeg','gif','webp'].indexOf(ext)>-1){body.innerHTML='<img src="'+url+'" style="width:100%;height:auto;min-height:auto;padding:1.5rem;" alt="Certificate"/>';}
    else{body.innerHTML='<div style="text-align:center;padding:3rem;"><p style="font-size:.94rem;color:#6B7280;margin-bottom:1rem;"><%: T("Cannot preview this file type.","Tidak dapat pratonton jenis fail ini.") %></p><a href="'+url+'" target="_blank" style="color:#6C63FF;font-weight:700;text-decoration:none;"><%: T("Download File","Muat Turun Fail") %> <i class="bi bi-download"></i></a></div>';}
    document.getElementById('certModal').classList.add('active');
}
function closeCertModal(){document.getElementById('certModal').classList.remove('active');}
document.addEventListener('keydown',function(e){if(e.key==='Escape')closeCertModal();});
// Client-side validation highlighting
function validateProfile(){
    var valid=true;
    var nameEl=document.querySelector('[id$="txtName"]');
    var phoneEl=document.querySelector('[id$="txtPhone"]');
    var valName=document.getElementById('valName');
    var valPhone=document.getElementById('valPhone');
    nameEl.classList.remove('invalid');phoneEl.classList.remove('invalid');
    valName.classList.remove('show');valName.textContent='';
    valPhone.classList.remove('show');valPhone.textContent='';
    if(!nameEl.value.trim()){nameEl.classList.add('invalid');valName.textContent='<%: T("Full Name is required.","Nama Penuh diperlukan.") %>';valName.classList.add('show');valid=false;}
    if(!phoneEl.value.trim()){phoneEl.classList.add('invalid');valPhone.textContent='<%: T("Phone Number is required.","Nombor Telefon diperlukan.") %>';valPhone.classList.add('show');valid=false;}
    else if(!/^\d+$/.test(phoneEl.value.trim())){phoneEl.classList.add('invalid');valPhone.textContent='<%: T("Phone Number must contain digits only.","Nombor Telefon mesti mengandungi digit sahaja.") %>';valPhone.classList.add('show');valid=false;}
    if(!valid){var first=document.querySelector('.mp-input.invalid');if(first)first.focus();}
    return valid;
}
document.addEventListener('input',function(e){
    if(e.target.id&&e.target.id.indexOf('txtName')>-1){e.target.classList.remove('invalid');document.getElementById('valName').classList.remove('show');}
    if(e.target.id&&e.target.id.indexOf('txtPhone')>-1){e.target.classList.remove('invalid');document.getElementById('valPhone').classList.remove('show');}
});
window.addEventListener('load',function(){
    var h=document.getElementById('<%=hidToast.ClientID%>');
    if(h&&h.value){var c=document.getElementById('mpToast'),t=document.createElement('div');t.className='mp-toast';t.innerHTML='<i class="bi bi-check-circle-fill"></i> '+h.value;c.appendChild(t);setTimeout(function(){t.classList.add('mp-toast-out');},3e3);setTimeout(function(){t.remove();},3500);h.value='';}
    if(bio)document.getElementById('bioCounter').textContent=bio.value.length+' / 500';
    var saveBtn=document.querySelector('[id$="btnSave"]');
    if(saveBtn){saveBtn.addEventListener('click',function(e){if(!validateProfile())e.preventDefault();});}
});
</script>
</asp:Content>
