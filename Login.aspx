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
        .login-left::before { content: ''; position: absolute; width: 300px; height: 300px; border-radius: 50%; background: radial-gradient(circle, rgba(99,102,241,0.18) 0%, transparent 70%); top: -80px; right: -60px; pointer-events: none; }
        .login-left::after { content: ''; position: absolute; width: 200px; height: 200px; border-radius: 50%; background: radial-gradient(circle, rgba(124,58,237,0.12) 0%, transparent 70%); bottom: -40px; left: -30px; pointer-events: none; }

        /* Decorative elements */
        .login-left-bubble1 { position: absolute; width: 50px; height: 50px; border-radius: 50%; background: rgba(255,255,255,0.04); top: 12%; left: 18%; pointer-events: none; }
        .login-left-bubble2 { position: absolute; width: 28px; height: 28px; border-radius: 50%; background: rgba(255,255,255,0.05); top: 25%; right: 14%; pointer-events: none; }
        .login-left-bubble3 { position: absolute; width: 18px; height: 18px; border-radius: 50%; background: rgba(255,255,255,0.06); bottom: 28%; left: 12%; pointer-events: none; }
        .login-left-star1 { position: absolute; width: 4px; height: 4px; border-radius: 50%; background: rgba(255,255,255,0.4); top: 18%; right: 28%; pointer-events: none; }
        .login-left-star2 { position: absolute; width: 3px; height: 3px; border-radius: 50%; background: rgba(255,255,255,0.35); top: 42%; left: 22%; pointer-events: none; }
        .login-left-star3 { position: absolute; width: 5px; height: 5px; border-radius: 50%; background: rgba(255,255,255,0.3); bottom: 35%; right: 20%; pointer-events: none; }
        .login-left-star4 { position: absolute; width: 3px; height: 3px; border-radius: 50%; background: rgba(255,255,255,0.25); top: 65%; left: 30%; pointer-events: none; }

        /* ── Visual Stage ── */
        .login-visual-stage { position: relative; display: flex; align-items: center; justify-content: center; flex-direction: column; width: 100%; }

        /* Brand content (wordmark + slogan above, mascot below) */
        .login-brand-content { position: relative; z-index: 5; display: flex; flex-direction: column; align-items: center; text-align: center; }

        /* Wordmark */
        .login-wordmark { font-family: 'Poppins', sans-serif; font-size: clamp(2.8rem, 4.5vw, 5.2rem); font-weight: 800; color: #fff; margin: 0 0 8px; line-height: 1.1; letter-spacing: -0.5px; }
        .login-wordmark span { color: #FCD34D; }

        /* Slogan */
        .login-slogan { font-size: clamp(0.85rem, 1.2vw, 1.05rem); color: rgba(255,255,255,0.75); max-width: 300px; line-height: 1.5; margin-bottom: 20px; }

        /* Mascot wrapper with glow — orbit surrounds this */
        .login-mascot-wrap { position: relative; display: flex; align-items: center; justify-content: center; width: 380px; height: 380px; }
        .login-mascot-wrap::before { content: ''; position: absolute; inset: 15% 12%; background: radial-gradient(circle, rgba(255,238,148,0.70) 0%, rgba(255,200,95,0.30) 28%, rgba(168,105,255,0.16) 52%, transparent 72%); filter: blur(26px); transform: scale(1.15); z-index: 0; border-radius: 50%; pointer-events: none; }
        .login-mascot-wrap::after { content: ''; position: absolute; inset: -8%; background: radial-gradient(circle, rgba(99,102,241,0.10) 0%, transparent 60%); filter: blur(35px); z-index: 0; pointer-events: none; }
        .login-mascot { width: 240px; max-width: 65%; height: auto; object-fit: contain; position: relative; z-index: 4; margin-top: 20px; }

        /* ── Fox-centred Orbit (bigger, fits fox inside) ── */
        .login-orbit { position: absolute; width: 360px; height: 360px; border: 2px solid rgba(255,255,255,0.38); border-radius: 50%; box-shadow: 0 0 8px rgba(255,255,255,0.35), 0 0 18px rgba(170,140,255,0.30), 0 0 32px rgba(117,90,255,0.18), inset 0 0 10px rgba(255,255,255,0.08); pointer-events: none; z-index: 1; top: 50%; left: 50%; transform: translate(-50%, -50%); }

        /* ── Rocket on fox orbit ── */
        .login-rocket-wrap { position: absolute; width: 360px; height: 360px; top: 50%; left: 50%; transform: translate(-50%, -50%); pointer-events: none; z-index: 3; }
        .login-rocket { position: absolute; top: 0; left: 0; width: 100%; height: 100%; pointer-events: none; }
        .login-rocket span { position: absolute; font-size: clamp(1.8rem, 2.5vw, 2.8rem); offset-path: ellipse(50% 50% at 50% 50%); offset-distance: 0%; offset-rotate: auto 90deg; animation: loginRocketPath 16s linear infinite; filter: drop-shadow(0 0 6px rgba(255,230,130,0.90)) drop-shadow(0 0 14px rgba(255,140,70,0.50)); }
        .login-rocket span::after { content: ''; position: absolute; top: 50%; right: 100%; width: 16px; height: 5px; background: linear-gradient(90deg, transparent, rgba(255,180,60,0.6), rgba(255,120,40,0.75)); border-radius: 0 4px 4px 0; transform: translateY(-50%); filter: blur(2px); }
        @keyframes loginRocketPath { from { offset-distance: 0%; } to { offset-distance: 100%; } }

        /* ── Planets OUTSIDE the orbit ── */
        .login-planet { position: absolute; border-radius: 50%; pointer-events: none; z-index: 2; }
        .login-planet-1 { width: 26px; height: 26px; background: radial-gradient(circle at 30% 30%, #93C5FD, #2563EB); top: 50%; left: -18%; box-shadow: 0 0 12px rgba(37,99,235,0.5), 0 0 24px rgba(37,99,235,0.2); animation: loginBreathe1 4s ease-in-out infinite alternate; }
        .login-planet-2 { width: 22px; height: 22px; background: radial-gradient(circle at 30% 30%, #F9A8D4, #EC4899); top: 8%; right: -12%; box-shadow: 0 0 12px rgba(236,72,153,0.5), 0 0 24px rgba(236,72,153,0.2); animation: loginBreathe2 5s ease-in-out infinite alternate; animation-delay: 0.8s; }
        .login-planet-3 { width: 20px; height: 20px; background: radial-gradient(circle at 30% 30%, #FDE68A, #A855F7); bottom: 5%; right: -10%; box-shadow: 0 0 12px rgba(168,85,247,0.5), 0 0 24px rgba(168,85,247,0.2); animation: loginBreathe3 3.5s ease-in-out infinite alternate; animation-delay: 1.5s; }
        @keyframes loginBreathe1 { from { transform: scale(1); } to { transform: scale(1.10); } }
        @keyframes loginBreathe2 { from { transform: scale(0.95); } to { transform: scale(1.08); } }
        @keyframes loginBreathe3 { from { transform: scale(1); } to { transform: scale(1.12); } }

        /* ── Glowing Yellow Stars ── */
        .login-star { position: absolute; border-radius: 50%; background: #FCD34D; pointer-events: none; z-index: 0; box-shadow: 0 0 4px rgba(252,211,77,0.6), 0 0 8px rgba(252,211,77,0.3); animation: loginTwinkle 3s ease-in-out infinite alternate; }
        .login-star-1 { width: 4px; height: 4px; top: 15%; left: 12%; animation-duration: 2.5s; }
        .login-star-2 { width: 5px; height: 5px; top: 30%; right: 10%; animation-duration: 3.2s; animation-delay: 0.4s; }
        .login-star-3 { width: 3px; height: 3px; top: 55%; left: 8%; animation-duration: 4s; animation-delay: 1s; }
        .login-star-4 { width: 4px; height: 4px; bottom: 18%; right: 15%; animation-duration: 2.8s; animation-delay: 0.7s; }
        .login-star-5 { width: 3px; height: 3px; top: 22%; left: 32%; animation-duration: 3.5s; animation-delay: 1.2s; }
        .login-star-6 { width: 5px; height: 5px; bottom: 35%; left: 6%; animation-duration: 3s; animation-delay: 0.3s; }
        .login-star-7 { width: 3px; height: 3px; top: 42%; right: 6%; animation-duration: 4.2s; animation-delay: 2s; }
        .login-star-8 { width: 4px; height: 4px; bottom: 12%; left: 25%; animation-duration: 3.8s; animation-delay: 0.9s; }
        .login-star-9 { width: 3px; height: 3px; top: 70%; right: 25%; animation-duration: 2.6s; animation-delay: 1.6s; }
        .login-star-10 { width: 5px; height: 5px; top: 8%; right: 30%; animation-duration: 3.4s; animation-delay: 0.5s; }
        @keyframes loginTwinkle { from { opacity: 0.4; transform: scale(0.8); } to { opacity: 1; transform: scale(1.3); } }

        /* Reduced motion */
        @media (prefers-reduced-motion: reduce) {
            .login-rocket span { animation: none; offset-distance: 12%; }
            .login-planet { animation: none !important; }
            .login-star { animation: none !important; opacity: 0.6 !important; }
        }

        @media (max-width: 900px) {
            .login-mascot-wrap { width: 300px; height: 300px; }
            .login-orbit, .login-rocket-wrap { width: 290px; height: 290px; }
            .login-mascot { width: 200px; }
            .login-planet-1 { width: 20px; height: 20px; }
            .login-planet-2 { width: 16px; height: 16px; }
            .login-planet-3 { width: 14px; height: 14px; }
        }

        @media (max-width: 767px) {
            .login-left-bubble1, .login-left-bubble3 { display: none; }
            .login-orbit { width: 200px; height: 200px; }
            .login-rocket-wrap { display: none; }
            .login-mascot-wrap { width: 200px; height: 200px; }
            .login-mascot { width: 140px; margin-top: 10px; }
            .login-wordmark { font-size: clamp(1.8rem, 6vw, 2.4rem); }
            .login-slogan { margin-bottom: 12px; }
            .login-planet-2, .login-planet-3 { display: none; }
            .login-planet-1 { width: 16px; height: 16px; }
            .login-star-3, .login-star-5, .login-star-7, .login-star-9 { display: none; }
        }

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
        <div class="login-left-bubble1"></div>
        <div class="login-left-bubble2"></div>
        <div class="login-left-bubble3"></div>
        <div class="login-left-star1"></div>
        <div class="login-left-star2"></div>
        <div class="login-left-star3"></div>
        <div class="login-left-star4"></div>

        <%-- Visual Stage --%>
        <div class="login-visual-stage">
            <%-- Glowing stars --%>
            <div class="login-star login-star-1" aria-hidden="true"></div>
            <div class="login-star login-star-2" aria-hidden="true"></div>
            <div class="login-star login-star-3" aria-hidden="true"></div>
            <div class="login-star login-star-4" aria-hidden="true"></div>
            <div class="login-star login-star-5" aria-hidden="true"></div>
            <div class="login-star login-star-6" aria-hidden="true"></div>
            <div class="login-star login-star-7" aria-hidden="true"></div>
            <div class="login-star login-star-8" aria-hidden="true"></div>
            <div class="login-star login-star-9" aria-hidden="true"></div>
            <div class="login-star login-star-10" aria-hidden="true"></div>
            <%-- Brand content --%>
            <div class="login-brand-content">
                <h1 class="login-wordmark">Science<span>Buddy</span></h1>
                <p class="login-slogan">Your next science adventure starts here.</p>
                <div class="login-mascot-wrap">
                    <%-- Orbit around fox --%>
                    <div class="login-orbit" aria-hidden="true"></div>
                    <%-- Rocket on fox orbit --%>
                    <div class="login-rocket-wrap" aria-hidden="true">
                        <div class="login-rocket"><span>&#x1F680;</span></div>
                    </div>
                    <%-- Planets --%>
                    <div class="login-planet login-planet-1" aria-hidden="true"></div>
                    <div class="login-planet login-planet-2" aria-hidden="true"></div>
                    <div class="login-planet login-planet-3" aria-hidden="true"></div>
                    <%-- Fox --%>
                    <img src="<%: ResolveUrl("~/Images/Login/login-fox.png") %>" alt="" class="login-mascot" />
                </div>
            </div>
        </div>
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
                    <label for="<%: txtUsername.ClientID %>">Username <span class="required">*</span></label>
                    <div class="login-input-wrap">
                        <i class="bi bi-person icon-left"></i>
                        <asp:TextBox ID="txtUsername" runat="server" MaxLength="150" AutoComplete="username" placeholder="Enter your username" aria-required="true" />
                    </div>
                    <asp:RequiredFieldValidator ID="rfvUsername" runat="server" ControlToValidate="txtUsername" ErrorMessage="Username is required." CssClass="sb-field-error" Display="Dynamic" SetFocusOnError="true" ValidationGroup="LoginGroup" />
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
