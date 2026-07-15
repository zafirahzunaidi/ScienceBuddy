<%@ Page Title="Reset Password" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ResetPassword.aspx.cs" Inherits="ScienceBuddy.ResetPassword" %>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%: ResolveUrl("~/Content/Registration.css") %>" rel="stylesheet" />
</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="reg-page" style="justify-content:center;align-items:center;min-height:calc(100vh - 140px);">
    <div style="max-width:460px;width:100%;padding:36px;background:#fff;border-radius:20px;border:1.5px solid #E2E8F0;box-shadow:0 4px 20px rgba(0,0,0,0.04);">

        <asp:Panel ID="pnlInvalid" runat="server" Visible="false">
            <div class="reg-status reg-status--error" role="alert">This password reset link is invalid or has expired.</div>
            <div class="reg-signin-link" style="margin-top:16px;"><a href="<%: ResolveUrl("~/ForgotPassword") %>">Request a new reset link</a> | <a href="<%: ResolveUrl("~/Login") %>">Back to Sign In</a></div>
        </asp:Panel>

        <asp:Panel ID="pnlForm" runat="server" DefaultButton="btnReset">
            <h1 class="reg-form-panel__heading">Reset your password</h1>
            <p class="reg-form-panel__sub">Enter your new password below.</p>
            <asp:Panel ID="pnlError" runat="server" Visible="false"><div class="reg-status reg-status--error" role="alert"><asp:Literal ID="litError" runat="server" /></div></asp:Panel>
            <div class="reg-field"><label>New Password <span style="color:#DC2626;">*</span></label><asp:TextBox ID="txtPassword" runat="server" TextMode="Password" MaxLength="50" /><asp:RequiredFieldValidator ID="rfvPass" runat="server" ControlToValidate="txtPassword" ValidationGroup="RP" Display="Dynamic" CssClass="field-validation-error" ErrorMessage="Password is required.">Required</asp:RequiredFieldValidator></div>
            <div class="reg-field"><label>Confirm New Password <span style="color:#DC2626;">*</span></label><asp:TextBox ID="txtConfirm" runat="server" TextMode="Password" MaxLength="50" /><asp:CompareValidator ID="cvPass" runat="server" ControlToValidate="txtConfirm" ControlToCompare="txtPassword" ValidationGroup="RP" Display="Dynamic" CssClass="field-validation-error" ErrorMessage="Passwords do not match.">Passwords do not match</asp:CompareValidator></div>
            <asp:Button ID="btnReset" runat="server" Text="Reset Password" CssClass="reg-btn" OnClick="BtnReset_Click" ValidationGroup="RP" />
        </asp:Panel>

        <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
            <div class="reg-success">
                <div class="reg-success__icon"><i class="bi bi-check-circle-fill"></i></div>
                <h2 class="reg-success__title">Password Reset Successfully</h2>
                <p class="reg-success__msg">Your password has been reset. You can now sign in with your new password.</p>
                <a href="<%: ResolveUrl("~/Login") %>" class="reg-success__btn">Go to Sign In</a>
            </div>
        </asp:Panel>

    </div>
</div>
</asp:Content>
