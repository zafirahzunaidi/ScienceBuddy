<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MyProfile.aspx.cs"
    Inherits="ScienceBuddy.Teacher.MyProfile" MasterPageFile="~/Site.Master"
    Title="My Profile" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Teacher.css") %>" rel="stylesheet" />
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label"><%: T("Notifications","Notifikasi") %></span></a></div>
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
<div class="tc-my-profile-hero">
    <div class="tc-my-profile-hero-decor"></div>
    <div class="tc-my-profile-avatar">
        <asp:Literal ID="litInitials" runat="server" Text="T" />
        <asp:Panel ID="pnlAvatarVerified" runat="server" CssClass="tc-my-profile-avatar-verified" Visible="false"><i class="bi bi-check-lg"></i></asp:Panel>
    </div>
    <div class="tc-my-profile-hero-info">
        <div class="tc-my-profile-hero-name"><asp:Literal ID="litName" runat="server" /></div>
        <div class="tc-my-profile-hero-subtitle">ScienceBuddy Teacher</div>
        <div class="tc-my-profile-hero-meta">
            <asp:Literal ID="litStatusBadge" runat="server" />
            <span class="tc-my-profile-badge tc-my-profile-badge-grey"><i class="bi bi-hash"></i> <asp:Literal ID="litTeacherId" runat="server" /></span>
        </div>
        <div class="tc-my-profile-hero-tagline"><%: T("Inspiring young minds to explore, question and discover the world of science.","Menginspirasi minda muda untuk meneroka, menyoal dan menemui dunia sains.") %></div>
        <div class="tc-my-profile-hero-info-row">
            <span><i class="bi bi-briefcase"></i> <%: T("Educator","Pendidik") %></span>
            <span><i class="bi bi-shield-check"></i> <asp:Literal ID="litProfileStatus" runat="server" Text="Active" /></span>
            <span><i class="bi bi-person-badge"></i> <asp:Literal ID="litMemberId" runat="server" /></span>
        </div>
    </div>
</div>

<%-- Tabs --%>
<div class="tc-my-profile-tabs">
    <button type="button" class="tc-my-profile-tab tc-my-profile-tab-active" onclick="switchTab('personal',this)"><i class="bi bi-person-circle"></i> <%: T("Personal Information","Maklumat Peribadi") %></button>
    <button type="button" class="tc-my-profile-tab" onclick="switchTab('certificate',this)"><i class="bi bi-file-earmark-check"></i> <%: T("Teaching Certificate","Sijil Pengajaran") %></button>
    <button type="button" class="tc-my-profile-tab" onclick="switchTab('permissions',this)"><i class="bi bi-shield-check"></i> <%: T("Teaching Permissions","Kebenaran Pengajaran") %></button>
    <button type="button" class="tc-my-profile-tab" onclick="switchTab('settings',this)"><i class="bi bi-gear"></i> <%: T("Account Settings","Tetapan Akaun") %></button>
</div>

<%-- Tab: Personal Information --%>
<div class="tc-my-profile-tab-content tc-my-profile-tab-visible" id="tab-personal">
<div class="tc-my-profile-card">
    <div class="tc-my-profile-field"><div class="tc-my-profile-field-label"><%: T("Full Name","Nama Penuh") %> *</div>
        <asp:TextBox ID="txtName" runat="server" CssClass="tc-my-profile-input" MaxLength="100" />
        <div class="tc-my-profile-val-msg" id="valName"></div>
    </div>
    <div class="tc-my-profile-field"><div class="tc-my-profile-field-label"><%: T("Teacher ID","ID Guru") %></div><div class="tc-my-profile-field-value"><asp:Literal ID="litTID" runat="server" /></div></div>
    <div class="tc-my-profile-field"><div class="tc-my-profile-field-label"><%: T("Academic Qualification","Kelayakan Akademik") %></div><div class="tc-my-profile-field-value"><asp:Literal ID="litQual" runat="server" /></div></div>
    <div class="tc-my-profile-field">
        <div class="tc-my-profile-field-label"><%: T("Phone Number","Nombor Telefon") %> *</div>
        <asp:TextBox ID="txtPhone" runat="server" CssClass="tc-my-profile-input" MaxLength="15" />
        <div class="tc-my-profile-val-msg" id="valPhone"></div>
    </div>
    <div class="tc-my-profile-field">
        <div class="tc-my-profile-field-label"><%: T("Biography","Biografi") %></div>
        <asp:TextBox ID="txtBio" runat="server" TextMode="MultiLine" Rows="4" CssClass="tc-my-profile-input tc-my-profile-textarea" MaxLength="500" />
        <div class="tc-my-profile-char" id="bioCounter">0 / 500</div>
    </div>
</div>
<div class="tc-my-profile-actions">
    <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="tc-my-profile-btn tc-my-profile-btn-cancel" OnClick="btnCancel_Click" CausesValidation="false" />
    <asp:Button ID="btnSave" runat="server" Text="Save Changes" CssClass="tc-my-profile-btn tc-my-profile-btn-primary" OnClick="btnSave_Click" CausesValidation="false" />
</div>
</div>

<%-- Tab: Teaching Certificate --%>
<div class="tc-my-profile-tab-content" id="tab-certificate">
<div class="tc-my-profile-card">
    <asp:Panel ID="pnlCertExists" runat="server" Visible="false">
        <div class="tc-my-profile-cert-file">
            <div class="tc-my-profile-cert-icon" id="certIconDiv" runat="server"><i id="certIconI" runat="server" class="bi bi-file-earmark-fill"></i></div>
            <div style="flex:1;">
                <div class="tc-my-profile-cert-name"><asp:Literal ID="litCertName" runat="server" /></div>
                <asp:Panel ID="pnlApprovedDate" runat="server" Visible="false">
                    <div class="tc-my-profile-cert-date"><i class="bi bi-calendar-check"></i> <%: T("Approved","Diluluskan") %>: <asp:Literal ID="litApprovedDate" runat="server" /></div>
                </asp:Panel>
            </div>
            <a id="lnkCert" runat="server" class="tc-my-profile-cert-btn" onclick="openCertModal(event);return false;"><i class="bi bi-eye"></i> <%: T("View","Lihat") %></a>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlCertEmpty" runat="server" Visible="false">
        <div style="text-align:center;padding:2rem;color:var(--tm);">
            <i class="bi bi-file-earmark-x" style="font-size:2.5rem;opacity:.4;"></i>
            <p style="font-size:.88rem;margin-top:.6rem;font-weight:600;"><%: T("No teaching certificate uploaded.","Tiada sijil pengajaran dimuat naik.") %></p>
        </div>
    </asp:Panel>
</div>
</div>

<%-- Tab: Teaching Permissions --%>
<div class="tc-my-profile-tab-content" id="tab-permissions">
<div class="tc-my-profile-card">
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

<%-- Tab: Account Settings --%>
<div class="tc-my-profile-tab-content" id="tab-settings">

<%-- Preferred Language --%>
<div class="tc-my-profile-card" style="margin-bottom:1.5rem;">
    <div class="tc-my-profile-card-title"><i class="bi bi-translate"></i> <%: T("Preferred Language","Bahasa Pilihan") %></div>
    <p style="font-size:.84rem;color:var(--tm);margin:0 0 1rem;line-height:1.5;"><%: T("Choose your preferred display language for ScienceBuddy.","Pilih bahasa paparan pilihan anda untuk ScienceBuddy.") %></p>
    <div class="tc-my-profile-field">
        <select id="selLanguage" class="tc-my-profile-input" style="height:42px;">
            <option value="EN" <%= CurrentLanguage == "EN" ? "selected" : "" %>>English</option>
            <option value="BM" <%= CurrentLanguage == "BM" ? "selected" : "" %>>Bahasa Melayu</option>
        </select>
    </div>
    <div style="margin-top:1rem;">
        <button type="button" class="tc-my-profile-btn tc-my-profile-btn-primary" style="padding:.6rem 1.4rem;font-size:.84rem;" onclick="saveLanguage()"><i class="bi bi-check-lg"></i> <%: T("Save Language","Simpan Bahasa") %></button>
    </div>
</div>

<%-- Change Password --%>
<div class="tc-my-profile-card" style="margin-bottom:1.5rem;">
    <div class="tc-my-profile-card-title"><i class="bi bi-key"></i> <%: T("Change Password","Tukar Kata Laluan") %></div>
    <div class="tc-my-profile-field">
        <div class="tc-my-profile-field-label"><%: T("Current Password","Kata Laluan Semasa") %> *</div>
        <div class="tc-my-profile-pw-wrap">
            <input type="password" id="pwCurrent" class="tc-my-profile-input tc-my-profile-pw-input" autocomplete="current-password" />
            <button type="button" class="tc-my-profile-pw-toggle" onclick="togglePw('pwCurrent',this)"><i class="bi bi-eye"></i></button>
        </div>
    </div>
    <div class="tc-my-profile-field">
        <div class="tc-my-profile-field-label"><%: T("New Password","Kata Laluan Baharu") %> *</div>
        <div class="tc-my-profile-pw-wrap">
            <input type="password" id="pwNew" class="tc-my-profile-input tc-my-profile-pw-input" autocomplete="new-password" />
            <button type="button" class="tc-my-profile-pw-toggle" onclick="togglePw('pwNew',this)"><i class="bi bi-eye"></i></button>
        </div>
    </div>
    <div class="tc-my-profile-field">
        <div class="tc-my-profile-field-label"><%: T("Confirm New Password","Sahkan Kata Laluan Baharu") %> *</div>
        <div class="tc-my-profile-pw-wrap">
            <input type="password" id="pwConfirm" class="tc-my-profile-input tc-my-profile-pw-input" autocomplete="new-password" />
            <button type="button" class="tc-my-profile-pw-toggle" onclick="togglePw('pwConfirm',this)"><i class="bi bi-eye"></i></button>
        </div>
    </div>
    <div id="pwMsg" style="font-size:.8rem;margin-top:.5rem;font-weight:600;display:none;"></div>
    <div style="margin-top:1.2rem;">
        <button type="button" class="tc-my-profile-btn tc-my-profile-btn-primary" style="padding:.6rem 1.4rem;font-size:.84rem;" onclick="changePassword()"><i class="bi bi-shield-lock"></i> <%: T("Save Password","Simpan Kata Laluan") %></button>
    </div>
</div>

<%-- Delete Account --%>
<div class="tc-my-profile-card tc-my-profile-card-danger">
    <div class="tc-my-profile-card-title" style="color:#B91C1C;"><i class="bi bi-exclamation-triangle-fill" style="color:#EF4444;"></i> <%: T("Delete Account","Padam Akaun") %></div>
    <p style="font-size:.88rem;color:#6B7280;margin:0 0 1.2rem;line-height:1.6;"><%: T("Deleting your account is permanent and cannot be undone.","Pemadaman akaun anda adalah kekal dan tidak boleh dibatalkan.") %></p>
    <button type="button" class="tc-my-profile-btn-delete-account" onclick="openDeleteAccountModal()"><i class="bi bi-trash3"></i> <%: T("Delete Account","Padam Akaun") %></button>
</div>

</div>

<%-- Delete Account Confirmation Modal --%>
<div id="deleteAccountModal" class="tc-manage-quiz-modal-overlay" style="display:none;" onclick="if(event.target===this)closeDeleteAccountModal()">
    <div class="tc-manage-quiz-modal" style="max-width:500px;">
        <div class="tc-manage-quiz-modal-header" style="background:#FEF2F2;border-bottom:1px solid #FECACA;">
            <h3 style="color:#B91C1C;display:flex;align-items:center;gap:8px;font-size:1.1rem;"><i class="bi bi-exclamation-triangle-fill" style="color:#EF4444;"></i> <%: T("Delete Account","Padam Akaun") %></h3>
            <button type="button" class="tc-manage-quiz-modal-close" onclick="closeDeleteAccountModal()">?</button>
        </div>
        <div class="tc-delete-account-modal-body">
            <p class="tc-delete-account-msg"><%: T("We're sorry to see you go. Please tell us why you're leaving before deleting your account.","Kami sedih melihat anda pergi. Sila beritahu kami mengapa anda meninggalkan sebelum memadam akaun anda.") %></p>
            <div class="tc-delete-account-warning">
                <i class="bi bi-shield-exclamation"></i>
                <span><%: T("Deleting your account is permanent and cannot be undone.","Pemadaman akaun anda adalah kekal dan tidak boleh dibatalkan.") %></span>
            </div>

            <div class="tc-delete-account-reasons">
                <label class="tc-delete-account-reason"><input type="radio" name="daReason" value="no_longer_use" /><span><%: T("I no longer use ScienceBuddy","Saya tidak lagi menggunakan ScienceBuddy") %></span></label>
                <label class="tc-delete-account-reason"><input type="radio" name="daReason" value="another_account" /><span><%: T("I created another account","Saya mencipta akaun lain") %></span></label>
                <label class="tc-delete-account-reason"><input type="radio" name="daReason" value="privacy" /><span><%: T("I have privacy concerns","Saya mempunyai kebimbangan privasi") %></span></label>
                <label class="tc-delete-account-reason"><input type="radio" name="daReason" value="technical" /><span><%: T("I am experiencing technical issues","Saya mengalami masalah teknikal") %></span></label>
                <label class="tc-delete-account-reason"><input type="radio" name="daReason" value="not_meet_needs" /><span><%: T("The platform does not meet my needs","Platform ini tidak memenuhi keperluan saya") %></span></label>
                <label class="tc-delete-account-reason"><input type="radio" name="daReason" value="other" /><span><%: T("Other","Lain-lain") %></span></label>
            </div>

            <div id="daOtherWrap" class="tc-delete-account-other-wrap" style="display:none;">
                <textarea id="daOtherText" class="tc-my-profile-input tc-my-profile-textarea" rows="3" placeholder="<%: T("Please share your reason.","Sila kongsi alasan anda.") %>" style="min-height:80px;"></textarea>
            </div>

            <div id="daValMsg" class="tc-delete-account-val-msg" style="display:none;"></div>
        </div>
        <div class="tc-manage-quiz-modal-footer">
            <button type="button" class="tc-manage-quiz-btn-cancel" onclick="closeDeleteAccountModal()"><%: T("Cancel","Batal") %></button>
            <button type="button" class="tc-my-profile-btn-delete-confirm" onclick="confirmDeleteAccount()"><i class="bi bi-trash3"></i> <%: T("Delete Account","Padam Akaun") %></button>
        </div>
    </div>
</div>

<asp:HiddenField ID="hidToast" runat="server" Value="" />
<div id="mpToast" class="tc-my-profile-toast-container"></div>

<%-- Certificate View Modal --%>
<div id="certModal" class="tc-my-profile-cert-modal-overlay" onclick="if(event.target===this)closeCertModal()">
    <div class="tc-my-profile-cert-modal">
        <div class="tc-my-profile-cert-modal-hd">
            <h4><i class="bi bi-file-earmark-text"></i> <%: T("Teaching Certificate","Sijil Pengajaran") %></h4>
            <button type="button" class="tc-my-profile-cert-modal-close" onclick="closeCertModal()">&times;</button>
        </div>
        <div class="tc-my-profile-cert-modal-body" id="certModalBody"></div>
    </div>
</div>
</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
// Tab switching
function switchTab(tabId, btn){
    var contents=document.querySelectorAll('.tc-my-profile-tab-content');
    for(var i=0;i<contents.length;i++){contents[i].classList.remove('tc-my-profile-tab-visible');}
    var target=document.getElementById('tab-'+tabId);
    if(target){target.classList.add('tc-my-profile-tab-visible');}
    var tabs=document.querySelectorAll('.tc-my-profile-tab');
    for(var j=0;j<tabs.length;j++){tabs[j].classList.remove('tc-my-profile-tab-active');}
    btn.classList.add('tc-my-profile-tab-active');
}
// Password toggle
function togglePw(id,btn){
    var inp=document.getElementById(id);
    if(inp.type==='password'){inp.type='text';btn.innerHTML='<i class="bi bi-eye-slash"></i>';}
    else{inp.type='password';btn.innerHTML='<i class="bi bi-eye"></i>';}
}
// Save Language
function saveLanguage(){
    var lang=document.getElementById('selLanguage').value;
    var xhr=new XMLHttpRequest();
    xhr.open('POST','MyProfile.aspx?handler=savelang&lang='+encodeURIComponent(lang),true);
    xhr.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
    xhr.onreadystatechange=function(){
        if(xhr.readyState===4){
            if(xhr.status===200){showMpToast('<%: T("Language saved successfully.","Bahasa berjaya disimpan.") %>');setTimeout(function(){location.reload();},1200);}
            else{alert('Error saving language.');}
        }
    };
    xhr.send('');
}
// Change Password
function changePassword(){
    var cur=document.getElementById('pwCurrent').value;
    var nw=document.getElementById('pwNew').value;
    var cf=document.getElementById('pwConfirm').value;
    var msg=document.getElementById('pwMsg');
    msg.style.display='none';
    if(!cur||!nw||!cf){msg.textContent='<%: T("All fields are required.","Semua medan diperlukan.") %>';msg.style.color='#B91C1C';msg.style.display='block';return;}
    if(nw.length<6){msg.textContent='<%: T("New password must be at least 6 characters.","Kata laluan baharu mestilah sekurang-kurangnya 6 aksara.") %>';msg.style.color='#B91C1C';msg.style.display='block';return;}
    if(nw!==cf){msg.textContent='<%: T("Passwords do not match.","Kata laluan tidak sepadan.") %>';msg.style.color='#B91C1C';msg.style.display='block';return;}
    var xhr=new XMLHttpRequest();
    xhr.open('POST','MyProfile.aspx?handler=changepw',true);
    xhr.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
    xhr.onreadystatechange=function(){
        if(xhr.readyState===4){
            if(xhr.status===200){
                msg.textContent='<%: T("Password changed successfully.","Kata laluan berjaya ditukar.") %>';msg.style.color='#047857';msg.style.display='block';
                document.getElementById('pwCurrent').value='';document.getElementById('pwNew').value='';document.getElementById('pwConfirm').value='';
                showMpToast('<%: T("Password changed.","Kata laluan ditukar.") %>');
            }else{
                msg.textContent=xhr.responseText||'<%: T("Error changing password.","Ralat menukar kata laluan.") %>';msg.style.color='#B91C1C';msg.style.display='block';
            }
        }
    };
    xhr.send('current='+encodeURIComponent(cur)+'&newpw='+encodeURIComponent(nw));
}
// Delete Account Modal
function openDeleteAccountModal(){
    document.getElementById('deleteAccountModal').style.display='flex';
    // Reset state
    var radios=document.querySelectorAll('input[name="daReason"]');
    for(var i=0;i<radios.length;i++){radios[i].checked=false;}
    document.getElementById('daOtherWrap').style.display='none';
    document.getElementById('daOtherText').value='';
    var msg=document.getElementById('daValMsg');msg.style.display='none';msg.textContent='';
}
function closeDeleteAccountModal(){document.getElementById('deleteAccountModal').style.display='none';}
// Show/hide Other textbox based on radio selection
document.addEventListener('change',function(e){
    if(e.target.name==='daReason'){
        var otherWrap=document.getElementById('daOtherWrap');
        if(e.target.value==='other'){otherWrap.style.display='block';}
        else{otherWrap.style.display='none';document.getElementById('daOtherText').value='';}
        document.getElementById('daValMsg').style.display='none';
    }
});
function confirmDeleteAccount(){
    var msg=document.getElementById('daValMsg');
    msg.style.display='none';msg.textContent='';
    // Get selected reason
    var selected=document.querySelector('input[name="daReason"]:checked');
    if(!selected){
        msg.textContent='<%: T("Please select a reason.","Sila pilih alasan.") %>';
        msg.style.display='block';return;
    }
    if(selected.value==='other'){
        var otherText=document.getElementById('daOtherText').value.trim();
        if(!otherText){
            msg.textContent='<%: T("Please enter your reason.","Sila masukkan alasan anda.") %>';
            msg.style.display='block';return;
        }
    }
    // Validation passed ? call server to set status to Deleted
    msg.style.display='none';
    var xhr=new XMLHttpRequest();
    xhr.open('POST','MyProfile.aspx?handler=deleteaccount',true);
    xhr.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
    xhr.onreadystatechange=function(){
        if(xhr.readyState===4){
            if(xhr.status===200){
                closeDeleteAccountModal();
                window.location.href='<%: ResolveUrl("~/Login.aspx") %>';
            }else{
                msg.textContent=xhr.responseText||'<%: T("Error deleting account.","Ralat memadam akaun.") %>';
                msg.style.display='block';
            }
        }
    };
    xhr.send('reason='+encodeURIComponent(selected.value)+(selected.value==='other'?'&detail='+encodeURIComponent(document.getElementById('daOtherText').value.trim()):''));
}
function showMpToast(msg){var c=document.getElementById('mpToast'),t=document.createElement('div');t.className='tc-my-profile-toast';t.innerHTML='<i class="bi bi-check-circle-fill"></i> '+msg;c.appendChild(t);setTimeout(function(){t.classList.add('tc-my-profile-toast-out');},3e3);setTimeout(function(){t.remove();},3500);}
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
    if(!valid){var first=document.querySelector('.tc-my-profile-input.invalid');if(first)first.focus();}
    return valid;
}
document.addEventListener('input',function(e){
    if(e.target.id&&e.target.id.indexOf('txtName')>-1){e.target.classList.remove('invalid');document.getElementById('valName').classList.remove('show');}
    if(e.target.id&&e.target.id.indexOf('txtPhone')>-1){e.target.classList.remove('invalid');document.getElementById('valPhone').classList.remove('show');}
});
window.addEventListener('load',function(){
    var h=document.getElementById('<%=hidToast.ClientID%>');
    if(h&&h.value){var c=document.getElementById('mpToast'),t=document.createElement('div');t.className='tc-my-profile-toast';t.innerHTML='<i class="bi bi-check-circle-fill"></i> '+h.value;c.appendChild(t);setTimeout(function(){t.classList.add('tc-my-profile-toast-out');},3e3);setTimeout(function(){t.remove();},3500);h.value='';}
    if(bio)document.getElementById('bioCounter').textContent=bio.value.length+' / 500';
    var saveBtn=document.querySelector('[id$="btnSave"]');
    if(saveBtn){saveBtn.addEventListener('click',function(e){if(!validateProfile())e.preventDefault();});}
});
</script>
</asp:Content>
