<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Profile.aspx.cs"
    Inherits="ScienceBuddy.Admin.Profile" MasterPageFile="~/Site.Master"
    Title="My Profile" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--ap:#2563EB;--ap-light:#EFF6FF;}
.ap-hero{background:linear-gradient(135deg,#1E3A5F 0%,#2563EB 60%,#3B82F6 100%);border-radius:var(--border-radius-xl);padding:var(--space-2xl);color:#fff;position:relative;overflow:hidden;margin-bottom:var(--space-xl);box-shadow:0 12px 40px rgba(37,99,235,.2);}
.ap-hero::before{content:'';position:absolute;width:300px;height:300px;border-radius:50%;background:rgba(255,255,255,.04);top:-100px;right:-60px;}
.ap-hero::after{content:'';position:absolute;width:150px;height:150px;border-radius:50%;background:rgba(255,255,255,.03);bottom:-40px;left:30px;}
.ap-hero-body{position:relative;z-index:1;display:flex;align-items:center;gap:var(--space-xl);flex-wrap:wrap;}
.ap-avatar{width:100px;height:100px;border-radius:50%;background:rgba(255,255,255,.15);border:4px solid rgba(255,255,255,.4);display:flex;align-items:center;justify-content:center;font-size:2.5rem;font-weight:800;color:#fff;flex-shrink:0;box-shadow:0 8px 24px rgba(0,0,0,.15);overflow:hidden;}
.ap-avatar img{width:100%;height:100%;object-fit:cover;}
.ap-hero-info{flex:1;min-width:200px;}
.ap-hero-name{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;margin-bottom:4px;}
.ap-hero-role{display:inline-flex;align-items:center;gap:6px;background:rgba(255,255,255,.18);border:1px solid rgba(255,255,255,.3);border-radius:var(--border-radius-full);padding:4px 14px;font-size:.75rem;font-weight:700;margin-bottom:8px;}
.ap-hero-meta{display:flex;gap:var(--space-lg);flex-wrap:wrap;font-size:.8rem;opacity:.85;}
.ap-hero-meta span{display:flex;align-items:center;gap:5px;}

/* Edit Profile Button — Top Right */
.ap-edit-btn{position:absolute;top:24px;right:24px;z-index:2;display:inline-flex;align-items:center;gap:8px;padding:10px 22px;border-radius:50px;background:#fff;color:#1D4ED8;font-size:.8rem;font-weight:700;text-decoration:none;border:none;cursor:pointer;box-shadow:0 4px 16px rgba(0,0,0,.12);transition:all .3s cubic-bezier(.4,0,.2,1);overflow:hidden;}
.ap-edit-btn:hover{transform:translateY(-2px);box-shadow:0 8px 24px rgba(37,99,235,.25);background:#EFF6FF;}
.ap-edit-btn:active{transform:translateY(0);box-shadow:0 4px 12px rgba(37,99,235,.15);}

.ap-grid{display:grid;grid-template-columns:1fr 1fr;gap:var(--space-xl);margin-bottom:var(--space-xl);}
.ap-card{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);padding:var(--space-xl);transition:box-shadow .2s;}
.ap-card:hover{box-shadow:var(--shadow-md);}
.ap-card-title{font-family:var(--font-primary);font-size:1rem;font-weight:800;color:var(--color-text);margin-bottom:var(--space-lg);display:flex;align-items:center;gap:8px;padding-bottom:var(--space-sm);border-bottom:1px solid var(--border-color);}
.ap-field{display:flex;align-items:center;padding:14px 0;border-bottom:1px solid #F1F5F9;}
.ap-field:last-child{border-bottom:none;}
.ap-field-ico{width:36px;height:36px;border-radius:var(--border-radius);background:var(--ap-light);color:var(--ap);display:flex;align-items:center;justify-content:center;font-size:.9rem;flex-shrink:0;margin-right:var(--space-md);}
.ap-field-body{flex:1;}
.ap-label{font-size:.7rem;font-weight:600;text-transform:uppercase;letter-spacing:.5px;color:var(--color-text-muted);margin-bottom:2px;}
.ap-value{font-size:.9375rem;font-weight:600;color:var(--color-text);}
.ap-status{display:inline-flex;align-items:center;gap:5px;padding:4px 12px;border-radius:var(--border-radius-full);font-size:.75rem;font-weight:700;background:#D1FAE5;color:#065F46;}
.ap-status-dot{width:7px;height:7px;border-radius:50%;background:#16A34A;}

/* ═══════════════════════════════════════════════════════════
   EDIT PROFILE MODAL
   ═══════════════════════════════════════════════════════════ */
.ap-modal-overlay{display:none;position:fixed;inset:0;background:rgba(15,23,42,.5);backdrop-filter:blur(4px);z-index:9999;align-items:center;justify-content:center;padding:20px;animation:apFadeIn .25s ease;}
.ap-modal-overlay.active{display:flex;}
@keyframes apFadeIn{from{opacity:0}to{opacity:1}}
@keyframes apSlideUp{from{opacity:0;transform:translateY(20px)}to{opacity:1;transform:translateY(0)}}
.ap-modal{background:#fff;border-radius:24px;width:100%;max-width:540px;max-height:90vh;overflow-y:auto;box-shadow:0 25px 60px rgba(0,0,0,.2);animation:apSlideUp .3s ease;padding:32px;}
.ap-modal-header{margin-bottom:24px;}
.ap-modal-title{font-family:var(--font-primary);font-size:1.25rem;font-weight:800;color:var(--color-text,#1e293b);margin-bottom:4px;}
.ap-modal-subtitle{font-size:.82rem;color:var(--color-text-muted,#94a3b8);font-weight:500;}
.ap-form-group{margin-bottom:18px;}
.ap-form-label{display:block;font-size:.75rem;font-weight:700;color:var(--color-text-secondary,#64748b);margin-bottom:6px;text-transform:uppercase;letter-spacing:.3px;}
.ap-form-input{width:100%;padding:12px 16px;border-radius:12px;border:1.5px solid #E2E8F0;font-size:.88rem;font-weight:500;color:var(--color-text,#1e293b);background:#fff;transition:all .2s;outline:none;font-family:inherit;}
.ap-form-input:focus{border-color:var(--ap);box-shadow:0 0 0 3px rgba(37,99,235,.1);}
.ap-form-input:disabled{background:#F8FAFC;color:var(--color-text-muted,#94a3b8);cursor:not-allowed;}
.ap-form-input.error{border-color:#EF4444;box-shadow:0 0 0 3px rgba(239,68,68,.1);}
.ap-form-error{font-size:.72rem;color:#EF4444;font-weight:600;margin-top:4px;display:none;}
.ap-form-error.visible{display:block;}
.ap-form-select{width:100%;padding:12px 16px;border-radius:12px;border:1.5px solid #E2E8F0;font-size:.88rem;font-weight:500;color:var(--color-text,#1e293b);background:#fff;transition:all .2s;outline:none;font-family:inherit;cursor:pointer;appearance:none;background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%2364748b' d='M6 8L1 3h10z'/%3E%3C/svg%3E");background-repeat:no-repeat;background-position:right 16px center;}
.ap-form-select:focus{border-color:var(--ap);box-shadow:0 0 0 3px rgba(37,99,235,.1);}

/* Modal buttons */
.ap-modal-actions{display:flex;gap:12px;justify-content:flex-end;margin-top:28px;padding-top:20px;border-top:1px solid #F1F5F9;}
.ap-btn{padding:11px 24px;border-radius:12px;font-size:.82rem;font-weight:700;border:none;cursor:pointer;transition:all .3s cubic-bezier(.4,0,.2,1);display:inline-flex;align-items:center;gap:6px;font-family:inherit;}
.ap-btn-secondary{background:#F1F5F9;color:var(--color-text-secondary,#64748b);}
.ap-btn-secondary:hover{background:#E2E8F0;transform:translateY(-1px);}
.ap-btn-primary{background:var(--ap);color:#fff;box-shadow:0 4px 12px rgba(37,99,235,.25);}
.ap-btn-primary:hover{background:#1D4ED8;transform:translateY(-2px);box-shadow:0 8px 20px rgba(37,99,235,.3);}
.ap-btn-primary:disabled{opacity:.5;cursor:not-allowed;transform:none;box-shadow:none;}

/* Divider */
.ap-form-divider{border:none;border-top:1px solid #F1F5F9;margin:20px 0;}
.ap-form-section-label{font-size:.7rem;font-weight:700;color:var(--color-text-muted,#94a3b8);text-transform:uppercase;letter-spacing:.5px;margin-bottom:14px;}

@media(max-width:767px){.ap-grid{grid-template-columns:1fr;}.ap-hero-body{flex-direction:column;align-items:flex-start;}.ap-edit-btn{top:16px;right:16px;padding:8px 16px;font-size:.75rem;}.ap-modal{padding:24px;margin:10px;}}
</style>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" />
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="<%: ResolveUrl("~/Scripts/admin-signout.js") %>"></script>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label">Main</div>
        <a href="<%: ResolveUrl("~/Admin/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label">Dashboard</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">User Management</div>
        <a href="<%: ResolveUrl("~/Admin/StudentManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-people item-icon"></i><span class="item-label">Students</span></a>
        <a href="<%: ResolveUrl("~/Admin/ParentManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-heart item-icon"></i><span class="item-label">Parents</span></a>
        <a href="<%: ResolveUrl("~/Admin/TeacherManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-badge item-icon"></i><span class="item-label">Teachers</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Learning Content</div>
        <a href="<%: ResolveUrl("~/Admin/LessonManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label">Lessons</span></a>
        <a href="<%: ResolveUrl("~/Admin/QuizManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label">Quizzes</span></a>
        <a href="<%: ResolveUrl("~/Admin/QuestionBank.aspx") %>" class="sb-sidebar-item"><i class="bi bi-question-circle item-icon"></i><span class="item-label">Question Bank</span></a>
        <a href="<%: ResolveUrl("~/Admin/TeacherMaterials.aspx") %>" class="sb-sidebar-item"><i class="bi bi-file-earmark-text item-icon"></i><span class="item-label">Material Requests</span></a>
        <a href="<%: ResolveUrl("~/Admin/LiveSessions.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label">Live Sessions</span></a>
        <a href="<%: ResolveUrl("~/Admin/QuestionRequests.aspx") %>" class="sb-sidebar-item"><i class="bi bi-clipboard-check item-icon"></i><span class="item-label">Question Requests</span></a>
        <a href="<%: ResolveUrl("~/Admin/CertificateManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-award item-icon"></i><span class="item-label">Certificates</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Community</div>
        <a href="<%: ResolveUrl("~/Admin/ForumDiscussions.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label">Forum Discussions</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Gamification</div>
        <a href="<%: ResolveUrl("~/Admin/GamificationManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-trophy item-icon"></i><span class="item-label">Student Performance</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Configuration</div>
        <a href="<%: ResolveUrl("~/Admin/SystemSettings.aspx") %>" class="sb-sidebar-item"><i class="bi bi-gear item-icon"></i><span class="item-label">System Settings</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Logs</div>
        <a href="<%: ResolveUrl("~/Admin/SystemActivityLogs.aspx") %>" class="sb-sidebar-item"><i class="bi bi-clock-history item-icon"></i><span class="item-label">Activity Logs</span></a>
        <a href="<%: ResolveUrl("~/Admin/LoginLogs.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-in-right item-icon"></i><span class="item-label">Login Logs</span></a>
        <a href="<%: ResolveUrl("~/Admin/SuspiciousLogins.aspx") %>" class="sb-sidebar-item"><i class="bi bi-exclamation-triangle item-icon"></i><span class="item-label">Suspicious Logins</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Admin/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span></a>
        <a href="<%: ResolveUrl("~/Admin/Profile.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a>
        <a href="javascript:;" class="sb-sidebar-item" onclick="showSignOutModal()"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%= T("My Profile", "Profil Saya") %></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<!-- HERO PROFILE BANNER -->
<div class="ap-hero">
    <button type="button" class="ap-edit-btn" onclick="openEditModal()"><i class="bi bi-pencil-square"></i> <%= T("Edit Profile", "Sunting Profil") %></button>
    <div class="ap-hero-body">
        <div class="ap-avatar" id="heroAvatar"><asp:Literal ID="litInitials" runat="server" Text="A" /></div>
        <div class="ap-hero-info">
            <div class="ap-hero-name" id="heroName"><asp:Literal ID="litUsername" runat="server" Text="-" /></div>
            <div class="ap-hero-role"><i class="bi bi-shield-check"></i> <asp:Literal ID="litRole" runat="server" Text="Administrator" /></div>
            <div class="ap-hero-meta">
                <span><i class="bi bi-envelope"></i> <span id="heroEmail"><asp:Literal ID="litEmail" runat="server" Text="-" /></span></span>
                <span><i class="bi bi-translate"></i> <span id="heroLang"><asp:Literal ID="litLanguage" runat="server" Text="-" /></span></span>
            </div>
        </div>
    </div>
</div>

<!-- INFO CARDS -->
<div class="ap-grid">
    <!-- Account Information -->
    <div class="ap-card">
        <div class="ap-card-title"><i class="bi bi-person-circle" style="color:var(--ap);"></i> <%= T("Account Information", "Maklumat Akaun") %></div>
        <div class="ap-field">
            <div class="ap-field-ico"><i class="bi bi-person"></i></div>
            <div class="ap-field-body"><div class="ap-label"><%= T("Username", "Nama Pengguna") %></div><div class="ap-value" id="cardUsername"><asp:Literal ID="litUsernameVal" runat="server" Text="-" /></div></div>
        </div>
        <div class="ap-field">
            <div class="ap-field-ico"><i class="bi bi-envelope"></i></div>
            <div class="ap-field-body"><div class="ap-label"><%= T("Email Address", "Alamat E-mel") %></div><div class="ap-value" id="cardEmail"><asp:Literal ID="litEmailVal" runat="server" Text="-" /></div></div>
        </div>
        <div class="ap-field">
            <div class="ap-field-ico"><i class="bi bi-shield-lock"></i></div>
            <div class="ap-field-body"><div class="ap-label"><%= T("Role", "Peranan") %></div><div class="ap-value"><asp:Literal ID="litRoleVal" runat="server" Text="Administrator" /></div></div>
        </div>
    </div>

    <!-- Preferences -->
    <div class="ap-card">
        <div class="ap-card-title"><i class="bi bi-gear" style="color:var(--ap);"></i> <%= T("Preferences", "Keutamaan") %></div>
        <div class="ap-field">
            <div class="ap-field-ico"><i class="bi bi-translate"></i></div>
            <div class="ap-field-body"><div class="ap-label"><%= T("Preferred Language", "Bahasa Pilihan") %></div><div class="ap-value" id="cardLang"><asp:Literal ID="litLangVal" runat="server" Text="-" /></div></div>
        </div>
        <div class="ap-field">
            <div class="ap-field-ico"><i class="bi bi-activity"></i></div>
            <div class="ap-field-body"><div class="ap-label"><%= T("Account Status", "Status Akaun") %></div><div class="ap-value"><asp:Literal ID="litStatus" runat="server" Text="-" /></div></div>
        </div>
        <div class="ap-field">
            <div class="ap-field-ico"><i class="bi bi-calendar3"></i></div>
            <div class="ap-field-body"><div class="ap-label"><%= T("System", "Sistem") %></div><div class="ap-value">ScienceBuddy Admin v1.0</div></div>
        </div>
    </div>
</div>

<!-- EDIT PROFILE MODAL -->
<div class="ap-modal-overlay" id="editModal">
    <div class="ap-modal">
        <div class="ap-modal-header">
            <div class="ap-modal-title"><%= T("Edit Profile", "Sunting Profil") %></div>
            <div class="ap-modal-subtitle"><%= T("Update your account information.", "Kemas kini maklumat akaun anda.") %></div>
        </div>

        <!-- Editable Fields -->
        <div class="ap-form-group">
            <label class="ap-form-label" for="editDisplayName"><%= T("Display Name", "Nama Paparan") %></label>
            <input type="text" class="ap-form-input" id="editDisplayName" maxlength="50" />
            <div class="ap-form-error" id="errDisplayName"></div>
        </div>
        <div class="ap-form-group">
            <label class="ap-form-label" for="editEmail"><%= T("Email Address", "Alamat E-mel") %></label>
            <input type="email" class="ap-form-input" id="editEmail" />
            <div class="ap-form-error" id="errEmail"></div>
        </div>
        <div class="ap-form-group">
            <label class="ap-form-label" for="editLanguage"><%= T("Preferred Language", "Bahasa Pilihan") %></label>
            <select class="ap-form-select" id="editLanguage">
                <option value="EN">English</option>
                <option value="BM">Bahasa Melayu</option>
            </select>
        </div>

        <hr class="ap-form-divider" />
        <div class="ap-form-section-label"><%= T("Read-Only Information", "Maklumat Baca Sahaja") %></div>

        <!-- Read-Only Fields -->
        <div class="ap-form-group">
            <label class="ap-form-label"><%= T("Username", "Nama Pengguna") %></label>
            <input type="text" class="ap-form-input" id="readonlyUsername" disabled />
        </div>
        <div class="ap-form-group">
            <label class="ap-form-label"><%= T("Role", "Peranan") %></label>
            <input type="text" class="ap-form-input" disabled value="Administrator" />
        </div>
        <div class="ap-form-group">
            <label class="ap-form-label"><%= T("Account Status", "Status Akaun") %></label>
            <input type="text" class="ap-form-input" id="readonlyStatus" disabled />
        </div>

        <!-- Modal Actions -->
        <div class="ap-modal-actions">
            <button type="button" class="ap-btn ap-btn-secondary" onclick="closeEditModal()"><%= T("Cancel", "Batal") %></button>
            <button type="button" class="ap-btn ap-btn-primary" id="btnSaveProfile" onclick="confirmSave()"><i class="bi bi-check-lg"></i> <%= T("Save Changes", "Simpan Perubahan") %></button>
        </div>
    </div>
</div>

<!-- Hidden fields for current data -->
<asp:HiddenField ID="hfUserId" runat="server" />
<asp:HiddenField ID="hfCurrentName" runat="server" />
<asp:HiddenField ID="hfCurrentEmail" runat="server" />
<asp:HiddenField ID="hfCurrentLang" runat="server" />
<asp:HiddenField ID="hfCurrentStatus" runat="server" />

<script>
(function () {
    // ── Modal open/close ─────────────────────────────────────
    window.openEditModal = function () {
        var modal = document.getElementById('editModal');
        document.getElementById('editDisplayName').value = document.getElementById('<%= hfCurrentName.ClientID %>').value;
        document.getElementById('editEmail').value = document.getElementById('<%= hfCurrentEmail.ClientID %>').value;
        document.getElementById('editLanguage').value = document.getElementById('<%= hfCurrentLang.ClientID %>').value;
        document.getElementById('readonlyUsername').value = document.getElementById('<%= hfCurrentName.ClientID %>').value;
        document.getElementById('readonlyStatus').value = document.getElementById('<%= hfCurrentStatus.ClientID %>').value;
        clearErrors();
        modal.classList.add('active');
    };

    window.closeEditModal = function () {
        document.getElementById('editModal').classList.remove('active');
    };

    // Close on overlay click
    document.getElementById('editModal').addEventListener('click', function (e) {
        if (e.target === this) closeEditModal();
    });

    // ── Validation ───────────────────────────────────────────
    function clearErrors() {
        document.querySelectorAll('.ap-form-error').forEach(function (el) { el.classList.remove('visible'); el.textContent = ''; });
        document.querySelectorAll('.ap-form-input.error').forEach(function (el) { el.classList.remove('error'); });
    }

    function validate() {
        clearErrors();
        var valid = true;
        var name = document.getElementById('editDisplayName').value.trim();
        var email = document.getElementById('editEmail').value.trim();

        if (!name) {
            showError('editDisplayName', 'errDisplayName', '<%= T("Display name cannot be empty.", "Nama paparan tidak boleh kosong.") %>');
            valid = false;
        }

        if (!email) {
            showError('editEmail', 'errEmail', '<%= T("Email address is required.", "Alamat e-mel diperlukan.") %>');
            valid = false;
        } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
            showError('editEmail', 'errEmail', '<%= T("Please enter a valid email address.", "Sila masukkan alamat e-mel yang sah.") %>');
            valid = false;
        }

        return valid;
    }

    function showError(inputId, errorId, msg) {
        document.getElementById(inputId).classList.add('error');
        var err = document.getElementById(errorId);
        err.textContent = msg;
        err.classList.add('visible');
    }

    // ── Confirm save ─────────────────────────────────────────
    window.confirmSave = function () {
        if (!validate()) return;

        Swal.fire({
            title: '<%= T("Save Profile Changes?", "Simpan Perubahan Profil?") %>',
            text: '<%= T("Are you sure you want to save the changes to your profile?", "Adakah anda pasti ingin menyimpan perubahan pada profil anda?") %>',
            icon: 'question',
            showCancelButton: true,
            confirmButtonColor: '#2563EB',
            cancelButtonColor: '#64748B',
            confirmButtonText: '<%= T("Save", "Simpan") %>',
            cancelButtonText: '<%= T("Cancel", "Batal") %>',
            reverseButtons: true
        }).then(function (result) {
            if (result.isConfirmed) saveProfile();
        });
    };

    // ── AJAX Save ────────────────────────────────────────────
    function saveProfile() {
        var btn = document.getElementById('btnSaveProfile');
        btn.disabled = true;
        btn.innerHTML = '<i class="bi bi-arrow-repeat"></i> <%= T("Saving...", "Menyimpan...") %>';

        var payload = {
            displayName: document.getElementById('editDisplayName').value.trim(),
            email: document.getElementById('editEmail').value.trim(),
            language: document.getElementById('editLanguage').value
        };

        fetch('<%= ResolveUrl("~/Admin/Profile.aspx/SaveProfile") %>', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        })
        .then(function (r) { return r.json(); })
        .then(function (data) {
            btn.disabled = false;
            btn.innerHTML = '<i class="bi bi-check-lg"></i> <%= T("Save Changes", "Simpan Perubahan") %>';

            if (data.d && data.d.success) {
                closeEditModal();

                // Update page UI without reload
                var langLabel = payload.language === 'BM' ? 'Bahasa Melayu' : 'English';
                document.getElementById('heroName').textContent = payload.displayName;
                document.getElementById('heroEmail').textContent = payload.email;
                document.getElementById('heroLang').textContent = langLabel;
                document.getElementById('cardUsername').textContent = payload.displayName;
                document.getElementById('cardEmail').textContent = payload.email;
                document.getElementById('cardLang').textContent = langLabel;

                // Update hidden fields
                document.getElementById('<%= hfCurrentName.ClientID %>').value = payload.displayName;
                document.getElementById('<%= hfCurrentEmail.ClientID %>').value = payload.email;
                document.getElementById('<%= hfCurrentLang.ClientID %>').value = payload.language;

                // Update initials in hero avatar
                var initials = payload.displayName.substring(0, 2).toUpperCase();
                document.getElementById('heroAvatar').textContent = initials;

                // Update nav bar name if present
                var navName = document.querySelector('.sb-user-name, [id$="litUserName"]');
                if (navName) navName.textContent = payload.displayName;
                var navInitials = document.querySelector('.sb-user-avatar-text, [id$="litUserInitials"]');
                if (navInitials) navInitials.textContent = initials;

                Swal.fire({
                    title: '<%= T("Profile Updated!", "Profil Dikemas Kini!") %>',
                    text: '<%= T("Your profile has been updated successfully.", "Profil anda telah berjaya dikemas kini.") %>',
                    icon: 'success',
                    confirmButtonColor: '#2563EB',
                    confirmButtonText: '<%= T("OK", "OK") %>'
                });
            } else {
                Swal.fire({
                    title: '<%= T("Error", "Ralat") %>',
                    text: data.d ? data.d.message : '<%= T("An error occurred.", "Ralat berlaku.") %>',
                    icon: 'error',
                    confirmButtonColor: '#2563EB'
                });
            }
        })
        .catch(function () {
            btn.disabled = false;
            btn.innerHTML = '<i class="bi bi-check-lg"></i> <%= T("Save Changes", "Simpan Perubahan") %>';
            Swal.fire({ title: '<%= T("Error", "Ralat") %>', text: '<%= T("Network error. Please try again.", "Ralat rangkaian. Sila cuba lagi.") %>', icon: 'error', confirmButtonColor: '#2563EB' });
        });
    }
})();
</script>

</asp:Content>
