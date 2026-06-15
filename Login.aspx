<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs"
    Inherits="ScienceBuddy.Login" MasterPageFile="~/Site.Master"
    Title="Sign In" %>

<%-- ── Head extras ─────────────────────────────────────────────────────── --%>
<asp:Content ID="LoginHead" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        /* ── Login page layout ── */
        .login-page {
            min-height: calc(100vh - var(--topnav-height) - 80px);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: var(--space-xl) var(--space-md);
        }

        .login-wrapper {
            display: grid;
            grid-template-columns: 1fr 1fr;
            max-width: 960px;
            width: 100%;
            background: var(--color-white);
            border-radius: var(--border-radius-xl);
            box-shadow: var(--shadow-xl);
            overflow: hidden;
            border: 1.5px solid var(--border-color);
        }

        /* ── Left panel – illustration / branding ── */
        .login-panel-left {
            background: linear-gradient(145deg, var(--color-primary) 0%, #1A4CC8 50%, var(--color-secondary) 100%);
            padding: var(--space-3xl) var(--space-2xl);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        /* Decorative circles */
        .login-panel-left::before {
            content: '';
            position: absolute;
            width: 320px; height: 320px;
            background: rgba(255,255,255,.06);
            border-radius: 50%;
            top: -80px; right: -80px;
        }
        .login-panel-left::after {
            content: '';
            position: absolute;
            width: 240px; height: 240px;
            background: rgba(255,255,255,.05);
            border-radius: 50%;
            bottom: -60px; left: -60px;
        }

        .login-brand-logo {
            width: 88px; height: 88px;
            background: rgba(255,255,255,.18);
            border-radius: var(--border-radius-xl);
            display: flex; align-items: center; justify-content: center;
            margin-bottom: var(--space-lg);
            font-size: 2.5rem;
            position: relative; z-index: 1;
            box-shadow: 0 8px 32px rgba(0,0,0,.2);
            border: 2px solid rgba(255,255,255,.25);
            overflow: hidden;
        }

        .login-brand-logo img {
            width: 100%; height: 100%; object-fit: contain; padding: 10px;
        }

        .login-brand-name {
            font-family: var(--font-primary);
            font-size: 2rem; font-weight: 800;
            color: #fff; line-height: 1.1;
            margin-bottom: var(--space-sm);
            position: relative; z-index: 1;
        }

        .login-brand-name span { color: var(--color-yellow); }

        .login-brand-tagline {
            font-size: 1rem; color: rgba(255,255,255,.85);
            line-height: 1.6; max-width: 260px;
            position: relative; z-index: 1;
            margin-bottom: var(--space-xl);
        }

        /* Science emoji bubbles */
        .login-science-icons {
            display: flex; gap: var(--space-md);
            flex-wrap: wrap; justify-content: center;
            position: relative; z-index: 1;
        }

        .login-science-icon {
            width: 52px; height: 52px;
            background: rgba(255,255,255,.15);
            border-radius: var(--border-radius);
            display: flex; align-items: center; justify-content: center;
            font-size: 1.5rem;
            border: 1.5px solid rgba(255,255,255,.2);
            backdrop-filter: blur(4px);
        }

        /* ── Right panel – form ── */
        .login-panel-right {
            padding: var(--space-3xl) var(--space-2xl);
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .login-form-header { margin-bottom: var(--space-xl); }

        .login-form-title {
            font-family: var(--font-primary);
            font-size: 1.625rem; font-weight: 800;
            color: var(--color-text); line-height: 1.2;
            margin-bottom: var(--space-xs);
        }

        .login-form-subtitle {
            font-size: 0.9375rem;
            color: var(--color-text-secondary);
        }

        /* ── Form ── */
        .login-form { display: flex; flex-direction: column; gap: var(--space-md); }

        /* Remember me row */
        .login-remember-row {
            display: flex; align-items: center;
            justify-content: space-between; gap: var(--space-sm);
        }

        .login-forgot {
            font-size: 0.875rem; font-weight: 600;
            color: var(--color-primary);
            transition: color var(--transition-fast);
        }
        .login-forgot:hover { color: var(--color-primary-dark); text-decoration: underline; }

        /* Divider */
        .login-divider {
            display: flex; align-items: center; gap: var(--space-md);
            color: var(--color-text-muted); font-size: 0.875rem;
            margin: var(--space-xs) 0;
        }
        .login-divider::before,
        .login-divider::after {
            content: ''; flex: 1;
            height: 1px; background: var(--border-color);
        }

        /* Register link row */
        .login-register-row {
            text-align: center;
            font-size: 0.9375rem;
            color: var(--color-text-secondary);
        }
        .login-register-row a {
            font-weight: 700; color: var(--color-primary);
        }
        .login-register-row a:hover { text-decoration: underline; }

        /* Error summary panel */
        .login-error-panel {
            background: var(--color-error-light);
            border: 1.5px solid #FCA5A5;
            border-radius: var(--border-radius);
            padding: var(--space-md);
            font-size: 0.9375rem;
            color: #7F1D1D;
            display: flex; align-items: flex-start; gap: var(--space-sm);
        }

        /* ── Responsive ── */
        @media (max-width: 767px) {
            .login-page { padding: var(--space-md); align-items: flex-start; }
            .login-wrapper { grid-template-columns: 1fr; }
            .login-panel-left { display: none; }
            .login-panel-right { padding: var(--space-xl) var(--space-lg); }
        }

        @media (max-width: 479px) {
            .login-panel-right { padding: var(--space-lg) var(--space-md); }
            .login-form-title { font-size: 1.375rem; }
        }
    </style>
</asp:Content>

<%-- ── Override top-nav action buttons: hide Sign In on login page ── --%>
<asp:Content ID="LoginNavActions" ContentPlaceHolderID="TopNavActions" runat="server">
    <a runat="server" href="~/Register" class="sb-btn sb-btn-primary sb-btn-sm">
        <i class="bi bi-person-plus"></i> Register
    </a>
</asp:Content>

<%-- ── Main content ─────────────────────────────────────────────────────── --%>
<asp:Content ID="LoginMain" ContentPlaceHolderID="MainContent" runat="server">

    <div class="login-page">
        <div class="login-wrapper">

            <%-- ════ LEFT PANEL ════ --%>
            <div class="login-panel-left" aria-hidden="true">

                <div class="login-brand-logo">
                    <img src="<%: ResolveUrl("~/Images/Logo/sciencebuddy-logo.png") %>"
                         alt="ScienceBuddy"
                         onerror="this.parentElement.innerHTML='🔬'" />
                </div>

                <div class="login-brand-name">Science<span>Buddy</span></div>

                <p class="login-brand-tagline">
                    Your fun and interactive science learning companion for curious young minds! 🚀
                </p>

                <div class="login-science-icons">
                    <div class="login-science-icon" title="Chemistry">⚗️</div>
                    <div class="login-science-icon" title="Biology">🌱</div>
                    <div class="login-science-icon" title="Physics">⚡</div>
                    <div class="login-science-icon" title="Astronomy">🌍</div>
                    <div class="login-science-icon" title="Microscope">🔬</div>
                </div>

            </div>

            <%-- ════ RIGHT PANEL – FORM ════ --%>
            <div class="login-panel-right">

                <div class="login-form-header">
                    <h1 class="login-form-title">Welcome back! 👋</h1>
                    <p class="login-form-subtitle">Sign in to continue your science adventure.</p>
                </div>

                <%-- Error summary (server-side messages) --%>
                <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="login-error-panel" role="alert">
                    <i class="bi bi-exclamation-circle-fill" style="flex-shrink:0;margin-top:2px"></i>
                    <div>
                        <asp:Literal ID="litError" runat="server" />
                    </div>
                </asp:Panel>

                <%-- Success panel (e.g. after password reset redirect) --%>
                <asp:Panel ID="pnlSuccess" runat="server" Visible="false" CssClass="sb-alert sb-alert-success mb-md" role="status">
                    <i class="bi bi-check-circle-fill alert-icon"></i>
                    <div class="alert-content">
                        <asp:Literal ID="litSuccess" runat="server" />
                    </div>
                </asp:Panel>

                <div class="login-form">

                    <%-- ── Username ── --%>
                    <div class="sb-form-group" style="margin-bottom:0">
                        <label class="sb-label" for="txtUsername">
                            Username or Email <span class="required" aria-hidden="true">*</span>
                        </label>
                        <div class="sb-input-wrapper">
                            <span class="input-icon" aria-hidden="true">
                                <i class="bi bi-person"></i>
                            </span>
                            <asp:TextBox ID="txtUsername"
                                         runat="server"
                                         CssClass="sb-input"
                                         placeholder="Enter your username or email"
                                         MaxLength="150"
                                         AutoComplete="username"
                                         data-validate-required="true"
                                         aria-required="true" />
                        </div>
                        <asp:RequiredFieldValidator
                            ID="rfvUsername" runat="server"
                            ControlToValidate="txtUsername"
                            ErrorMessage="Username or email is required."
                            CssClass="sb-field-error"
                            Display="Dynamic"
                            SetFocusOnError="true"
                            ValidationGroup="LoginGroup" />
                    </div>

                    <%-- ── Password ── --%>
                    <div class="sb-form-group" style="margin-bottom:0">
                        <label class="sb-label" for="txtPassword">
                            Password <span class="required" aria-hidden="true">*</span>
                        </label>
                        <div class="sb-input-wrapper has-right-icon">
                            <span class="input-icon" aria-hidden="true">
                                <i class="bi bi-lock"></i>
                            </span>
                            <asp:TextBox ID="txtPassword"
                                         runat="server"
                                         CssClass="sb-input"
                                         TextMode="Password"
                                         placeholder="Enter your password"
                                         MaxLength="128"
                                         AutoComplete="current-password"
                                         data-validate-required="true"
                                         aria-required="true" />
                            <%-- Show/hide password toggle --%>
                            <button type="button"
                                    class="input-icon-right"
                                    id="btnTogglePassword"
                                    aria-label="Show or hide password"
                                    data-tooltip="Show / hide password">
                                <i class="bi bi-eye" id="iconTogglePassword"></i>
                            </button>
                        </div>
                        <asp:RequiredFieldValidator
                            ID="rfvPassword" runat="server"
                            ControlToValidate="txtPassword"
                            ErrorMessage="Password is required."
                            CssClass="sb-field-error"
                            Display="Dynamic"
                            SetFocusOnError="true"
                            ValidationGroup="LoginGroup" />
                    </div>

                    <%-- ── Remember me + Forgot password ── --%>
                    <div class="login-remember-row">
                        <label class="sb-check-label">
                            <asp:CheckBox ID="chkRemember" runat="server" />
                            <span>Remember me</span>
                        </label>
                        <a runat="server" href="~/ForgotPassword" class="login-forgot">
                            Forgot password?
                        </a>
                    </div>

                    <%-- ── Login button ── --%>
                    <asp:Button ID="btnLogin"
                                runat="server"
                                Text="Sign In"
                                CssClass="sb-btn sb-btn-primary sb-btn-full sb-btn-lg"
                                OnClick="btnLogin_Click"
                                ValidationGroup="LoginGroup"
                                UseSubmitBehavior="true"
                                aria-label="Sign in to ScienceBuddy" />

                    <%-- ── Divider ── --%>
                    <div class="login-divider" aria-hidden="true">or</div>

                    <%-- ── Register link ── --%>
                    <div class="login-register-row">
                        Don't have an account?
                        <a runat="server" href="~/Register">Create one free &rarr;</a>
                    </div>

                </div>
                <%-- /.login-form --%>

            </div>
            <%-- /.login-panel-right --%>

        </div>
        <%-- /.login-wrapper --%>
    </div>
    <%-- /.login-page --%>

</asp:Content>

<%-- ── Page scripts ─────────────────────────────────────────────────────── --%>
<asp:Content ID="LoginScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script>
        (function () {
            /* ── Show / hide password ── */
            var toggleBtn  = document.getElementById('btnTogglePassword');
            var toggleIcon = document.getElementById('iconTogglePassword');
            var pwdInput   = document.getElementById('<%= txtPassword.ClientID %>');

            if (toggleBtn && pwdInput) {
                toggleBtn.addEventListener('click', function () {
                    var isHidden = pwdInput.type === 'password';
                    pwdInput.type = isHidden ? 'text' : 'password';
                    toggleIcon.className = isHidden ? 'bi bi-eye-slash' : 'bi bi-eye';
                    toggleBtn.setAttribute('aria-label', isHidden ? 'Hide password' : 'Show password');
                });
            }

            /* ── Set master layout to TopNav ── */
            /* (already set in code-behind, this is just a safety hook) */

            /* ── Focus first empty field on load ── */
            window.addEventListener('DOMContentLoaded', function () {
                var u = document.getElementById('<%= txtUsername.ClientID %>');
                var p = document.getElementById('<%= txtPassword.ClientID %>');
                if (u && !u.value) { u.focus(); }
                else if (p && !p.value) { p.focus(); }
            });
        })();
    </script>
</asp:Content>
