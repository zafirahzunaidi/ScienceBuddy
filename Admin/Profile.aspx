<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Profile.aspx.cs"
    Inherits="ScienceBuddy.Admin.Profile" MasterPageFile="~/Site.Master"
    Title="My Profile" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%: ResolveUrl("~/Content/Admin.css") %>" rel="stylesheet" />
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
        <a href="<%: ResolveUrl("~/Admin/TeacherCertificateApproval.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-check item-icon"></i><span class="item-label">Teacher Certificate Approval</span></a>
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
<div class="ad-profile-hero">
    <button type="button" class="ad-profile-edit-btn" onclick="openEditModal()"><i class="bi bi-pencil-square"></i> <%= T("Edit Profile", "Sunting Profil") %></button>
    <div class="ad-profile-hero-body">
        <div class="ad-profile-avatar" id="heroAvatar"><asp:Literal ID="litInitials" runat="server" Text="A" /></div>
        <div class="ad-profile-hero-info">
            <div class="ad-profile-hero-name" id="heroName"><asp:Literal ID="litUsername" runat="server" Text="-" /></div>
            <div class="ad-profile-hero-role"><i class="bi bi-shield-check"></i> <asp:Literal ID="litRole" runat="server" Text="Administrator" /></div>
            <div class="ad-profile-hero-meta">
                <span><i class="bi bi-envelope"></i> <span id="heroEmail"><asp:Literal ID="litEmail" runat="server" Text="-" /></span></span>
                <span><i class="bi bi-translate"></i> <span id="heroLang"><asp:Literal ID="litLanguage" runat="server" Text="-" /></span></span>
            </div>
        </div>
    </div>
</div>

<!-- INFO CARDS -->
<div class="ad-profile-grid">
    <!-- Account Information -->
    <div class="ad-profile-card">
        <div class="ad-profile-card-title"><i class="bi bi-person-circle" style="color:var(--ad-profile-accent);"></i> <%= T("Account Information", "Maklumat Akaun") %></div>
        <div class="ad-profile-field">
            <div class="ad-profile-field-ico"><i class="bi bi-person"></i></div>
            <div class="ad-profile-field-body"><div class="ad-profile-label"><%= T("Username", "Nama Pengguna") %></div><div class="ad-profile-value" id="cardUsername"><asp:Literal ID="litUsernameVal" runat="server" Text="-" /></div></div>
        </div>
        <div class="ad-profile-field">
            <div class="ad-profile-field-ico"><i class="bi bi-envelope"></i></div>
            <div class="ad-profile-field-body"><div class="ad-profile-label"><%= T("Email Address", "Alamat E-mel") %></div><div class="ad-profile-value" id="cardEmail"><asp:Literal ID="litEmailVal" runat="server" Text="-" /></div></div>
        </div>
        <div class="ad-profile-field">
            <div class="ad-profile-field-ico"><i class="bi bi-shield-lock"></i></div>
            <div class="ad-profile-field-body"><div class="ad-profile-label"><%= T("Role", "Peranan") %></div><div class="ad-profile-value"><asp:Literal ID="litRoleVal" runat="server" Text="Administrator" /></div></div>
        </div>
    </div>

    <!-- Preferences -->
    <div class="ad-profile-card">
        <div class="ad-profile-card-title"><i class="bi bi-gear" style="color:var(--ad-profile-accent);"></i> <%= T("Preferences", "Keutamaan") %></div>
        <div class="ad-profile-field">
            <div class="ad-profile-field-ico"><i class="bi bi-translate"></i></div>
            <div class="ad-profile-field-body"><div class="ad-profile-label"><%= T("Preferred Language", "Bahasa Pilihan") %></div><div class="ad-profile-value" id="cardLang"><asp:Literal ID="litLangVal" runat="server" Text="-" /></div></div>
        </div>
        <div class="ad-profile-field">
            <div class="ad-profile-field-ico"><i class="bi bi-activity"></i></div>
            <div class="ad-profile-field-body"><div class="ad-profile-label"><%= T("Account Status", "Status Akaun") %></div><div class="ad-profile-value"><asp:Literal ID="litStatus" runat="server" Text="-" /></div></div>
        </div>
        <div class="ad-profile-field">
            <div class="ad-profile-field-ico"><i class="bi bi-calendar3"></i></div>
            <div class="ad-profile-field-body"><div class="ad-profile-label"><%= T("System", "Sistem") %></div><div class="ad-profile-value">ScienceBuddy Admin v1.0</div></div>
        </div>
    </div>
</div>

<!-- EDIT PROFILE MODAL -->
<div class="ad-profile-modal-overlay" id="editModal">
    <div class="ad-profile-modal">
        <div class="ad-profile-modal-header">
            <div class="ad-profile-modal-title"><%= T("Edit Profile", "Sunting Profil") %></div>
            <div class="ad-profile-modal-subtitle"><%= T("Update your account information.", "Kemas kini maklumat akaun anda.") %></div>
        </div>

        <!-- Editable Fields -->
        <div class="ad-profile-form-group">
            <label class="ad-profile-form-label" for="editDisplayName"><%= T("Display Name", "Nama Paparan") %></label>
            <input type="text" class="ad-profile-form-input" id="editDisplayName" maxlength="50" />
            <div class="ad-profile-form-error" id="errDisplayName"></div>
        </div>
        <div class="ad-profile-form-group">
            <label class="ad-profile-form-label" for="editEmail"><%= T("Email Address", "Alamat E-mel") %></label>
            <input type="email" class="ad-profile-form-input" id="editEmail" />
            <div class="ad-profile-form-error" id="errEmail"></div>
        </div>
        <div class="ad-profile-form-group">
            <label class="ad-profile-form-label" for="editLanguage"><%= T("Preferred Language", "Bahasa Pilihan") %></label>
            <select class="ad-profile-form-select" id="editLanguage">
                <option value="EN">English</option>
                <option value="BM">Bahasa Melayu</option>
            </select>
        </div>

        <hr class="ad-profile-form-divider" />
        <div class="ad-profile-form-section-label"><%= T("Read-Only Information", "Maklumat Baca Sahaja") %></div>

        <!-- Read-Only Fields -->
        <div class="ad-profile-form-group">
            <label class="ad-profile-form-label"><%= T("Username", "Nama Pengguna") %></label>
            <input type="text" class="ad-profile-form-input" id="readonlyUsername" disabled />
        </div>
        <div class="ad-profile-form-group">
            <label class="ad-profile-form-label"><%= T("Role", "Peranan") %></label>
            <input type="text" class="ad-profile-form-input" disabled value="Administrator" />
        </div>
        <div class="ad-profile-form-group">
            <label class="ad-profile-form-label"><%= T("Account Status", "Status Akaun") %></label>
            <input type="text" class="ad-profile-form-input" id="readonlyStatus" disabled />
        </div>

        <!-- Modal Actions -->
        <div class="ad-profile-modal-actions">
            <button type="button" class="ad-profile-btn ad-profile-btn-secondary" onclick="closeEditModal()"><%= T("Cancel", "Batal") %></button>
            <button type="button" class="ad-profile-btn ad-profile-btn-primary" id="btnSaveProfile" onclick="confirmSave()"><i class="bi bi-check-lg"></i> <%= T("Save Changes", "Simpan Perubahan") %></button>
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
        document.querySelectorAll('.ad-profile-form-error').forEach(function (el) { el.classList.remove('visible'); el.textContent = ''; });
        document.querySelectorAll('.ad-profile-form-input.error').forEach(function (el) { el.classList.remove('error'); });
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
