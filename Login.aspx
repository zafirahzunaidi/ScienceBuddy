<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs"
    Inherits="ScienceBuddy.Login" MasterPageFile="~/Site.Master"
    Title="Sign In" %>

<asp:Content ID="LoginHead" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        /* Hide nav language toggle and remove master page padding */
        .sb-lang-toggle { display: none !important; }
        .sb-layout-topnav .sb-main-content { padding: 0; max-width: none; }

        /* ── Full viewport split ── */
        .login-page { display: flex; min-height: calc(100vh - 68px); }

        /* ── Left Panel ── */
        .login-left {
            flex: 0 0 48%; display: flex; flex-direction: column;
            align-items: center; justify-content: center; text-align: center;
            padding: 48px 36px; position: relative; overflow: hidden;
            background: linear-gradient(160deg, #1e1b4b 0%, #312e81 25%, #4338ca 50%, #6366f1 75%, #7c3aed 95%);
        }
        /* Large soft glow behind mascot */
        .login-left::before { content: ''; position: absolute; width: 280px; height: 280px; border-radius: 50%; background: radial-gradient(circle, rgba(99,102,241,0.25) 0%, transparent 70%); bottom: 10%; left: 50%; transform: translateX(-50%); pointer-events: none; }
        /* Faint orbit ring */
        .login-left::after { content: ''; position: absolute; width: 320px; height: 320px; border-radius: 50%; border: 1px solid rgba(255,255,255,0.06); bottom: 5%; left: 50%; transform: translateX(-50%); pointer-events: none; }

        /* Decorative elements */
        .login-left-glow { position: absolute; width: 160px; height: 160px; border-radius: 50%; background: rgba(129,140,248,0.15); filter: blur(50px); top: 35%; left: 50%; transform: translateX(-50%); pointer-events: none; }
        .login-left-orbit { position: absolute; width: 400px; height: 400px; border-radius: 50%; border: 1px dashed rgba(255,255,255,0.05); bottom: 0%; left: 50%; transform: translateX(-50%) translateY(30%); pointer-events: none; }
        .login-left-bubble1 { position: absolute; width: 50px; height: 50px; border-radius: 50%; background: rgba(255,255,255,0.04); top: 12%; left: 18%; pointer-events: none; }
        .login-left-bubble2 { position: absolute; width: 28px; height: 28px; border-radius: 50%; background: rgba(255,255,255,0.05); top: 25%; right: 14%; pointer-events: none; }
        .login-left-bubble3 { position: absolute; width: 18px; height: 18px; border-radius: 50%; background: rgba(255,255,255,0.06); bottom: 28%; left: 12%; pointer-events: none; }
        .login-left-star1 { position: absolute; width: 4px; height: 4px; border-radius: 50%; background: rgba(255,255,255,0.4); top: 18%; right: 28%; pointer-events: none; }
        .login-left-star2 { position: absolute; width: 3px; height: 3px; border-radius: 50%; background: rgba(255,255,255,0.35); top: 42%; left: 22%; pointer-events: none; }
        .login-left-star3 { position: absolute; width: 5px; height: 5px; border-radius: 50%; background: rgba(255,255,255,0.3); bottom: 35%; right: 20%; pointer-events: none; }
        .login-left-star4 { position: absolute; width: 3px; height: 3px; border-radius: 50%; background: rgba(255,255,255,0.25); top: 65%; left: 30%; pointer-events: none; }
        .login-left-atom { position: absolute; width: 60px; height: 60px; border-radius: 50%; border: 1px solid rgba(255,255,255,0.05); top: 55%; right: 10%; pointer-events: none; }
        .login-left-atom::before { content: ''; position: absolute; width: 100%; height: 100%; border-radius: 50%; border: 1px solid rgba(255,255,255,0.04); transform: rotate(60deg); }
        .login-left-atom::after { content: ''; position: absolute; width: 6px; height: 6px; border-radius: 50%; background: rgba(255,255,255,0.12); top: 50%; left: 50%; transform: translate(-50%,-50%); }

        @media (max-width: 767px) {
            .login-left-orbit, .login-left-atom, .login-left-bubble1, .login-left-bubble3 { display: none; }
        }

        .login-brand { font-family: 'Poppins', sans-serif; font-size: 1.8rem; font-weight: 800; color: #fff; margin-bottom: 8px; position: relative; z-index: 1; }
        .login-brand span { color: #FCD34D; }
        .login-slogan { font-size: 0.95rem; color: rgba(255,255,255,0.75); max-width: 260px; line-height: 1.5; position: relative; z-index: 1; margin-bottom: 32px; }
        .login-mascot { width: 280px; max-width: 85%; height: auto; object-fit: contain; position: relative; z-index: 1; }

        /* ── Right Panel ── */
        .login-right {
            flex: 1; display: flex; align-items: center; justify-content: center;
            padding: 40px 32px; position: relative; overflow: hidden;
            background: linear-gradient(180deg, #f8faff 0%, #eef2ff 50%, #f0f4ff 100%);
        }
        .login-right-blob1 { position: absolute; width: 200px; height: 200px; border-radius: 50%; background: rgba(99,102,241,0.04); top: -60px; right: -40px; filter: blur(30px); }
        .login-right-blob2 { position: absolute; width: 140px; height: 140px; border-radius: 50%; background: rgba(167,139,250,0.05); bottom: -40px; left: 20px; filter: blur(25px); }

        /* ── Floating Login Card ── */
        .login-card {
            background: #fff; border-radius: 24px; padding: 44px 36px;
            width: 100%; max-width: 420px; position: relative; z-index: 1;
            box-shadow: 0 12px 40px rgba(0,0,0,0.06); border: 1px solid rgba(226,232,240,0.7);
        }

        /* Card header */
        .login-card-header { margin-bottom: 32px; }
        .login-card-title { font-family: 'Poppins', sans-serif; font-size: 1.5rem; font-weight: 800; color: #1E293B; margin: 0 0 6px; }
        .login-card-sub { font-size: 0.9rem; color: #64748B; }

        /* Error/Success */
        .login-error-panel { background: #FEF2F2; border: 1.5px solid #FECACA; border-radius: 12px; padding: 12px 16px; font-size: 0.88rem; color: #991B1B; display: flex; align-items: flex-start; gap: 8px; margin-bottom: 18px; }

        /* Form */
        .login-form { display: flex; flex-direction: column; gap: 18px; }
        .login-field label { display: block; font-size: 0.8rem; font-weight: 700; color: #1E293B; margin-bottom: 6px; }
        .login-field label .required { color: #DC2626; }
        .login-input-wrap { position: relative; display: flex; align-items: center; }
        .login-input-wrap .icon-left { position: absolute; left: 14px; color: #94A3B8; font-size: 1rem; pointer-events: none; }
        .login-input-wrap input { width: 100%; padding: 13px 14px 13px 42px; border: 1.5px solid #E2E8F0; border-radius: 12px; font-size: 0.9rem; font-family: 'Poppins', sans-serif; color: #1E293B; background: #FAFBFE; transition: border-color 0.2s, box-shadow 0.2s; }
        .login-input-wrap input:focus { border-color: #6366F1; background: #fff; outline: none; box-shadow: 0 0 0 3px rgba(99,102,241,0.08); }
        .login-input-wrap .icon-right { position: absolute; right: 6px; background: none; border: none; padding: 8px; cursor: pointer; color: #64748B; border-radius: 8px; transition: background 0.15s; }
        .login-input-wrap .icon-right:hover { background: #F1F5F9; }
        .sb-field-error { display: block; font-size: 0.72rem; color: #DC2626; margin-top: 4px; }

        /* Remember + Forgot */
        .login-options { display: flex; align-items: center; justify-content: space-between; font-size: 0.82rem; }
        .login-options label { display: flex; align-items: center; gap: 6px; color: #475569; cursor: pointer; }
        .login-forgot { color: #6366F1; font-weight: 600; text-decoration: none; }
        .login-forgot:hover { text-decoration: underline; }

        /* Button */
        .login-btn { width: 100%; padding: 14px; border: none; border-radius: 12px; background: linear-gradient(135deg, #6366F1 0%, #4F46E5 100%); color: #fff; font-size: 0.95rem; font-weight: 700; font-family: 'Poppins', sans-serif; cursor: pointer; transition: transform 0.2s, box-shadow 0.2s; margin-top: 6px; }
        .login-btn:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(99,102,241,0.25); }
        .login-btn:disabled { opacity: 0.6; cursor: not-allowed; transform: none; box-shadow: none; }

        /* Register link */
        .login-register { text-align: center; font-size: 0.85rem; color: #64748B; margin-top: 6px; }
        .login-register a { color: #6366F1; font-weight: 700; text-decoration: none; }
        .login-register a:hover { text-decoration: underline; }

        /* ── Responsive ── */
        @media (max-width: 767px) {
            .login-page { flex-direction: column; }
            .login-left { flex: none; padding: 32px 24px; min-height: auto; }
            .login-mascot { width: 100px; margin-bottom: 0; }
            .login-slogan { margin-bottom: 16px; font-size: 0.85rem; }
            .login-right { padding: 28px 16px; }
            .login-card { padding: 32px 22px; max-width: none; }
        }
    </style>
</asp:Content>

<asp:Content ID="LoginNavActions" ContentPlaceHolderID="TopNavActions" runat="server">
    <a runat="server" href="~/Register" class="sb-btn sb-btn-primary sb-btn-sm"><i class="bi bi-person-plus"></i> Register</a>
</asp:Content>

<asp:Content ID="LoginMain" ContentPlaceHolderID="MainContent" runat="server">
<div class="login-page">

    <%-- ═══ LEFT PANEL ═══ --%>
    <div class="login-left" aria-hidden="true">
        <div class="login-left-glow"></div>
        <div class="login-left-orbit"></div>
        <div class="login-left-bubble1"></div>
        <div class="login-left-bubble2"></div>
        <div class="login-left-bubble3"></div>
        <div class="login-left-star1"></div>
        <div class="login-left-star2"></div>
        <div class="login-left-star3"></div>
        <div class="login-left-star4"></div>
        <div class="login-left-atom"></div>
        <div class="login-brand">Science<span>Buddy</span></div>
        <p class="login-slogan">Your next science adventure starts here.</p>
        <img src="<%: ResolveUrl("~/Images/Login/login-fox.png") %>" alt="" class="login-mascot" />
    </div>

    <%-- ═══ RIGHT PANEL ═══ --%>
    <div class="login-right">
        <div class="login-right-blob1"></div>
        <div class="login-right-blob2"></div>
        <div class="login-card">
            <div class="login-card-header">
                <h1 class="login-card-title">Welcome back! 👋</h1>
                <p class="login-card-sub">Sign in to continue your science adventure.</p>
            </div>

            <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="login-error-panel" role="alert" aria-live="assertive">
                <i class="bi bi-exclamation-circle-fill" style="flex-shrink:0;margin-top:2px"></i>
                <div><asp:Literal ID="litError" runat="server" /></div>
            </asp:Panel>
            <asp:Panel ID="pnlSuccess" runat="server" Visible="false" CssClass="sb-alert sb-alert-success mb-md" role="status">
                <i class="bi bi-check-circle-fill alert-icon"></i>
                <div class="alert-content"><asp:Literal ID="litSuccess" runat="server" /></div>
            </asp:Panel>

            <div class="login-form">
                <div class="login-field">
                    <label for="<%: txtUsername.ClientID %>">Username or Email <span class="required">*</span></label>
                    <div class="login-input-wrap">
                        <i class="bi bi-person icon-left"></i>
                        <asp:TextBox ID="txtUsername" runat="server" MaxLength="150" AutoComplete="username" placeholder="Enter your username or email" aria-required="true" />
                    </div>
                    <asp:RequiredFieldValidator ID="rfvUsername" runat="server" ControlToValidate="txtUsername" ErrorMessage="Username or email is required." CssClass="sb-field-error" Display="Dynamic" SetFocusOnError="true" ValidationGroup="LoginGroup" />
                </div>

                <div class="login-field">
                    <label for="<%: txtPassword.ClientID %>">Password <span class="required">*</span></label>
                    <div class="login-input-wrap">
                        <i class="bi bi-lock icon-left"></i>
                        <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" MaxLength="128" AutoComplete="current-password" placeholder="Enter your password" aria-required="true" />
                        <button type="button" class="icon-right" id="btnTogglePassword" aria-label="Show password"><i class="bi bi-eye" id="iconTogglePassword"></i></button>
                    </div>
                    <asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword" ErrorMessage="Password is required." CssClass="sb-field-error" Display="Dynamic" SetFocusOnError="true" ValidationGroup="LoginGroup" />
                </div>

                <div class="login-options">
                    <label><asp:CheckBox ID="chkRemember" runat="server" /> Remember me</label>
                    <a runat="server" href="~/ForgotPassword" class="login-forgot">Forgot password?</a>
                </div>

                <asp:Button ID="btnLogin" runat="server" Text="Sign In" CssClass="login-btn" OnClick="btnLogin_Click" ValidationGroup="LoginGroup" UseSubmitBehavior="true" />
                <div class="login-register">Don't have an account? <a runat="server" href="~/Register">Create one free &rarr;</a></div>
            </div>
        </div>
    </div>

</div>
</asp:Content>

<asp:Content ID="LoginScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
(function () {
    var toggleBtn = document.getElementById('btnTogglePassword');
    var toggleIcon = document.getElementById('iconTogglePassword');
    var pwdInput = document.getElementById('<%= txtPassword.ClientID %>');
    if (toggleBtn && pwdInput) {
        toggleBtn.addEventListener('click', function () {
            var isHidden = pwdInput.type === 'password';
            pwdInput.type = isHidden ? 'text' : 'password';
            toggleIcon.className = isHidden ? 'bi bi-eye-slash' : 'bi bi-eye';
            toggleBtn.setAttribute('aria-label', isHidden ? 'Hide password' : 'Show password');
        });
    }
    var loginBtn = document.getElementById('<%= btnLogin.ClientID %>');
    if (loginBtn) {
        loginBtn.addEventListener('click', function () {
            // Allow ASP.NET to handle validation; just show signing-in state after a short delay
            setTimeout(function () {
                if (typeof Page_IsValid !== 'undefined' && Page_IsValid) {
                    loginBtn.disabled = true;
                    loginBtn.value = 'Signing in\u2026';
                    setTimeout(function () { loginBtn.disabled = false; loginBtn.value = 'Sign In'; }, 8000);
                }
            }, 50);
        });
    }
    window.addEventListener('DOMContentLoaded', function () {
        var u = document.getElementById('<%= txtUsername.ClientID %>');
        var p = document.getElementById('<%= txtPassword.ClientID %>');
        var err = document.querySelector('.login-error-panel');
        if (err && err.offsetHeight > 0) { err.setAttribute('tabindex', '-1'); err.focus(); }
        else if (u && !u.value) { u.focus(); }
        else if (p && !p.value) { p.focus(); }
    });
})();
</script>
</asp:Content>
