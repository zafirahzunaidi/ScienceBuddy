<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MyProfile.aspx.cs"
    Inherits="ScienceBuddy.Teacher.MyProfile" MasterPageFile="~/Site.Master"
    Title="My Profile" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--tp:#6C63FF;--tp2:#8B5CF6;--tp-h:#5A52E0;--tl:#F5F3FF;--tc:#FFF;--tb:#E5E7EB;--tt:#374151;--tm:#6B7280;--ts:#10B981;--te:#EF4444;--tw:#F59E0B;}
.mp-hero{background:linear-gradient(135deg,#4F46E5 0%,#6C63FF 40%,#8B5CF6 80%,#A78BFA 100%);border-radius:20px;padding:2.5rem;color:#fff;display:flex;align-items:center;gap:2rem;position:relative;overflow:hidden;margin-bottom:1.5rem;box-shadow:0 12px 40px rgba(108,99,255,.2);}
.mp-hero::before{content:'';position:absolute;width:300px;height:300px;border-radius:50%;background:rgba(255,255,255,.04);top:-80px;right:-40px;}
.mp-hero::after{content:'';position:absolute;width:150px;height:150px;border-radius:50%;background:rgba(255,255,255,.03);bottom:-40px;left:20px;}
.mp-avatar{width:80px;height:80px;border-radius:50%;background:rgba(255,255,255,.2);border:3px solid rgba(255,255,255,.4);display:flex;align-items:center;justify-content:center;font-size:1.75rem;font-weight:800;flex-shrink:0;position:relative;z-index:1;}
.mp-hero-info{position:relative;z-index:1;flex:1;}
.mp-hero-name{font-size:1.5rem;font-weight:800;margin-bottom:4px;}
.mp-hero-role{font-size:.82rem;opacity:.8;margin-bottom:8px;}
.mp-hero-meta{display:flex;gap:.75rem;flex-wrap:wrap;align-items:center;}
.mp-badge{padding:4px 12px;border-radius:50px;font-size:.7rem;font-weight:700;display:inline-flex;align-items:center;gap:4px;}
.mp-badge-green{background:rgba(16,185,129,.2);color:#6EE7B7;border:1px solid rgba(16,185,129,.3);}
.mp-badge-orange{background:rgba(245,158,11,.2);color:#FCD34D;border:1px solid rgba(245,158,11,.3);}
.mp-badge-red{background:rgba(239,68,68,.2);color:#FCA5A5;border:1px solid rgba(239,68,68,.3);}
.mp-badge-grey{background:rgba(255,255,255,.15);color:rgba(255,255,255,.7);border:1px solid rgba(255,255,255,.2);}
.mp-hero-bio{font-size:.82rem;opacity:.85;margin-top:8px;line-height:1.5;max-width:500px;}
.mp-grid{display:grid;grid-template-columns:1fr 1fr;gap:1.25rem;margin-bottom:1.5rem;}
.mp-card{background:var(--tc);border:1.5px solid var(--tb);border-radius:16px;padding:1.5rem;box-shadow:0 2px 8px rgba(0,0,0,.03);transition:transform .2s,box-shadow .2s;}
.mp-card:hover{transform:translateY(-2px);box-shadow:0 6px 20px rgba(108,99,255,.08);}
.mp-card-title{font-size:.85rem;font-weight:700;color:var(--tt);margin-bottom:1rem;display:flex;align-items:center;gap:8px;}
.mp-card-title i{color:var(--tp);font-size:1rem;}
.mp-field{margin-bottom:1rem;}
.mp-field:last-child{margin-bottom:0;}
.mp-field-label{font-size:.72rem;font-weight:600;color:var(--tm);text-transform:uppercase;letter-spacing:.5px;margin-bottom:4px;}
.mp-field-value{font-size:.88rem;font-weight:600;color:var(--tt);}
.mp-input{width:100%;border-radius:10px;border:1.5px solid var(--tb);padding:.6rem .8rem;font-size:.84rem;transition:all .2s;}
.mp-input:focus{border-color:var(--tp);outline:none;box-shadow:0 0 0 3px rgba(108,99,255,.08);}
.mp-input.invalid{border-color:var(--te);box-shadow:0 0 0 3px rgba(239,68,68,.08);}
.mp-textarea{min-height:100px;resize:vertical;line-height:1.6;}
.mp-char{font-size:.7rem;color:var(--tm);text-align:right;margin-top:3px;}
.mp-val-msg{font-size:.72rem;color:var(--te);margin-top:3px;display:none;}
.mp-val-msg.show{display:block;}
/* Progress */
.mp-progress-card{background:var(--tc);border:1.5px solid var(--tb);border-radius:16px;padding:1.25rem 1.5rem;margin-bottom:1.25rem;display:flex;align-items:center;gap:1.25rem;box-shadow:0 2px 8px rgba(0,0,0,.03);}
.mp-pct{font-size:1.5rem;font-weight:800;color:var(--tp);}
.mp-progress-bar{flex:1;height:8px;background:#EDE9FE;border-radius:8px;overflow:hidden;}
.mp-progress-fill{height:100%;background:linear-gradient(90deg,var(--tp),#A78BFA);border-radius:8px;transition:width .6s ease;}
.mp-progress-msg{font-size:.78rem;color:var(--tm);font-weight:600;}
/* Cert */
.mp-cert-file{display:flex;align-items:center;gap:12px;padding:.75rem 1rem;background:var(--tl);border-radius:12px;border:1.5px solid #EDE9FE;}
.mp-cert-icon{width:40px;height:40px;border-radius:10px;background:#EDE9FE;color:var(--tp);display:flex;align-items:center;justify-content:center;font-size:1.2rem;}
.mp-cert-name{font-size:.84rem;font-weight:600;color:var(--tt);flex:1;}
.mp-cert-btn{font-size:.78rem;font-weight:700;color:var(--tp);text-decoration:none;padding:5px 12px;border-radius:8px;border:1.5px solid #EDE9FE;background:var(--tc);transition:all .2s;}
.mp-cert-btn:hover{background:var(--tl);border-color:var(--tp);}
/* Checklist */
.mp-check-list{list-style:none;padding:0;margin:0;}
.mp-check-list li{display:flex;align-items:center;gap:10px;padding:.5rem 0;font-size:.82rem;font-weight:600;color:var(--tm);}
.mp-check-list li.active{color:var(--ts);}
.mp-check-ico{width:20px;height:20px;border-radius:50%;border:2px solid var(--tb);display:flex;align-items:center;justify-content:center;font-size:.6rem;flex-shrink:0;}
.mp-check-list li.active .mp-check-ico{border-color:var(--ts);background:var(--ts);color:#fff;}
/* Actions */
.mp-actions{display:flex;gap:.75rem;justify-content:flex-end;margin-top:1.5rem;}
.mp-btn{padding:.6rem 1.5rem;border-radius:12px;font-size:.84rem;font-weight:700;cursor:pointer;border:none;transition:all .2s;}
.mp-btn:hover{transform:translateY(-1px);}
.mp-btn-primary{background:linear-gradient(135deg,var(--tp),var(--tp2));color:#fff;box-shadow:0 4px 12px rgba(108,99,255,.25);}
.mp-btn-primary:hover{box-shadow:0 6px 20px rgba(108,99,255,.35);}
.mp-btn-cancel{background:var(--tc);color:var(--tt);border:1.5px solid var(--tb);}
/* Toast */
.mp-toast-container{position:fixed;top:1.25rem;right:1.25rem;z-index:9999;display:flex;flex-direction:column;gap:.5rem;}
.mp-toast{background:#10B981;color:#fff;padding:.75rem 1.25rem;border-radius:10px;font-size:.84rem;font-weight:600;display:flex;align-items:center;gap:8px;box-shadow:0 8px 24px rgba(16,185,129,.3);animation:mpSlide .3s ease;}
.mp-toast-out{opacity:0;transform:translateX(30px);transition:all .4s;}
@keyframes mpSlide{from{opacity:0;transform:translateX(30px);}to{opacity:1;transform:translateX(0);}}
@media(max-width:768px){.mp-hero{flex-direction:column;text-align:center;padding:1.75rem;}.mp-grid{grid-template-columns:1fr;}.mp-actions{flex-direction:column;}}
</style>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Teaching","Pengajaran") %></div>
        <a href="<%: ResolveUrl("~/Teacher/manageMaterials.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label"><%: T("Manage Materials","Urus Bahan Pembelajaran") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label"><%: T("Manage Quiz","Urus Kuiz") %></span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-bar-chart item-icon"></i><span class="item-label"><%: T("Student Progress","Kemajuan Pelajar") %></span></a>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label"><%: T("Schedule Live Class","Jadual Kelas Langsung") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Community","Komuniti") %></div>
        <a href="#" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a>
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

<%-- Certificate + Verification --%>
<div style="display:flex;flex-direction:column;gap:1.25rem;">

<div class="mp-card">
    <div class="mp-card-title"><i class="bi bi-file-earmark-check"></i> <%: T("Teaching Certificate","Sijil Pengajaran") %></div>
    <asp:Panel ID="pnlCertExists" runat="server" Visible="false">
        <div class="mp-cert-file">
            <div class="mp-cert-icon"><i class="bi bi-file-earmark-pdf-fill"></i></div>
            <div style="flex:1;">
                <div class="mp-cert-name"><asp:Literal ID="litCertName" runat="server" /></div>
                <asp:Panel ID="pnlApprovedDate" runat="server" Visible="false">
                    <div style="font-size:.72rem;font-weight:700;color:var(--ts);margin-top:3px;"><i class="bi bi-calendar-check"></i> <%: T("Approved","Diluluskan") %>: <asp:Literal ID="litApprovedDate" runat="server" /></div>
                </asp:Panel>
            </div>
            <a id="lnkCert" runat="server" target="_blank" class="mp-cert-btn"><i class="bi bi-eye"></i> <%: T("View","Lihat") %></a>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlCertEmpty" runat="server" Visible="false">
        <div style="text-align:center;padding:1.5rem;color:var(--tm);">
            <i class="bi bi-file-earmark-x" style="font-size:2rem;opacity:.4;"></i>
            <p style="font-size:.82rem;margin-top:.5rem;"><%: T("No teaching certificate uploaded.","Tiada sijil pengajaran dimuat naik.") %></p>
        </div>
    </asp:Panel>
</div>

<div class="mp-card">
    <div class="mp-card-title"><i class="bi bi-patch-check-fill"></i> <%: T("Verification Status","Status Pengesahan") %></div>
    <asp:Panel ID="pnlVerCertified" runat="server" Visible="false">
        <ul class="mp-check-list">
            <li class="active"><span class="mp-check-ico"><i class="bi bi-check"></i></span><%: T("Certificate reviewed","Sijil disemak") %></li>
            <li class="active"><span class="mp-check-ico"><i class="bi bi-check"></i></span><%: T("Eligible to upload materials","Layak memuat naik bahan") %></li>
            <li class="active"><span class="mp-check-ico"><i class="bi bi-check"></i></span><%: T("Eligible to create quizzes","Layak mencipta kuiz") %></li>
            <li class="active"><span class="mp-check-ico"><i class="bi bi-check"></i></span><%: T("Eligible to support student learning","Layak menyokong pembelajaran pelajar") %></li>
        </ul>
    </asp:Panel>
    <asp:Panel ID="pnlVerPending" runat="server" Visible="false">
        <div style="display:flex;align-items:flex-start;gap:10px;padding:.75rem 1rem;background:#FEF3C7;border:1px solid #FDE68A;border-radius:10px;">
            <i class="bi bi-hourglass-split" style="color:var(--tw);font-size:1.1rem;margin-top:2px;"></i>
            <div>
                <div style="font-size:.82rem;font-weight:700;color:#92400E;"><%: T("Pending Verification","Pengesahan Belum Selesai") %></div>
                <div style="font-size:.76rem;color:#92400E;margin-top:3px;line-height:1.4;"><%: T("Awaiting certificate approval. Access may be limited until verification is complete.","Menunggu kelulusan sijil. Akses mungkin terhad sehingga pengesahan selesai.") %></div>
            </div>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlVerRejected" runat="server" Visible="false">
        <div style="display:flex;align-items:flex-start;gap:10px;padding:.75rem 1rem;background:#FEF2F2;border:1px solid #FEE2E2;border-radius:10px;">
            <i class="bi bi-x-circle-fill" style="color:var(--te);font-size:1.1rem;margin-top:2px;"></i>
            <div>
                <div style="font-size:.82rem;font-weight:700;color:#B91C1C;"><%: T("Verification Rejected","Pengesahan Ditolak") %></div>
                <div style="font-size:.76rem;color:#B91C1C;margin-top:3px;line-height:1.4;"><%: T("Certificate was not approved. Please contact admin.","Sijil tidak diluluskan. Sila hubungi admin.") %></div>
            </div>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlVerUnknown" runat="server" Visible="false">
        <div style="text-align:center;padding:1rem;color:var(--tm);font-size:.82rem;"><%: T("Status unavailable.","Status tidak tersedia.") %></div>
    </asp:Panel>
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
</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
var bio=document.querySelector('[id$="txtBio"]');
if(bio){bio.addEventListener('input',function(){document.getElementById('bioCounter').textContent=this.value.length+' / 500';});}
// Client-side validation highlighting
function validateProfile(){
    var valid=true;
    var nameEl=document.querySelector('[id$="txtName"]');
    var phoneEl=document.querySelector('[id$="txtPhone"]');
    var valName=document.getElementById('valName');
    var valPhone=document.getElementById('valPhone');
    // Reset
    nameEl.classList.remove('invalid');phoneEl.classList.remove('invalid');
    valName.classList.remove('show');valName.textContent='';
    valPhone.classList.remove('show');valPhone.textContent='';
    // Name
    if(!nameEl.value.trim()){nameEl.classList.add('invalid');valName.textContent='<%: T("Full Name is required.","Nama Penuh diperlukan.") %>';valName.classList.add('show');valid=false;}
    // Phone
    if(!phoneEl.value.trim()){phoneEl.classList.add('invalid');valPhone.textContent='<%: T("Phone Number is required.","Nombor Telefon diperlukan.") %>';valPhone.classList.add('show');valid=false;}
    else if(!/^\d+$/.test(phoneEl.value.trim())){phoneEl.classList.add('invalid');valPhone.textContent='<%: T("Phone Number must contain digits only.","Nombor Telefon mesti mengandungi digit sahaja.") %>';valPhone.classList.add('show');valid=false;}
    if(!valid){var first=document.querySelector('.mp-input.invalid');if(first)first.focus();}
    return valid;
}
// Clear validation on input
document.addEventListener('input',function(e){
    if(e.target.id&&e.target.id.indexOf('txtName')>-1){e.target.classList.remove('invalid');document.getElementById('valName').classList.remove('show');}
    if(e.target.id&&e.target.id.indexOf('txtPhone')>-1){e.target.classList.remove('invalid');document.getElementById('valPhone').classList.remove('show');}
});
// Toast
window.addEventListener('load',function(){
    var h=document.getElementById('<%=hidToast.ClientID%>');
    if(h&&h.value){var c=document.getElementById('mpToast'),t=document.createElement('div');t.className='mp-toast';t.innerHTML='<i class="bi bi-check-circle-fill"></i> '+h.value;c.appendChild(t);setTimeout(function(){t.classList.add('mp-toast-out');},3e3);setTimeout(function(){t.remove();},3500);h.value='';}
    if(bio)document.getElementById('bioCounter').textContent=bio.value.length+' / 500';
    // Hook save button to validate client-side first
    var saveBtn=document.querySelector('[id$="btnSave"]');
    if(saveBtn){saveBtn.addEventListener('click',function(e){if(!validateProfile())e.preventDefault();});}
});
</script>
</asp:Content>
