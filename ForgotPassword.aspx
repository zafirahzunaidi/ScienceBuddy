<%@ Page Title="Forgot Password" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ForgotPassword.aspx.cs" Inherits="ScienceBuddy.ForgotPassword" %>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%: ResolveUrl("~/Content/Registration.css") %>" rel="stylesheet" />
</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="reg-page" style="justify-content:center;align-items:center;min-height:calc(100vh - 140px);">
    <div style="max-width:460px;width:100%;padding:36px;background:#fff;border-radius:20px;border:1.5px solid #E2E8F0;box-shadow:0 4px 20px rgba(0,0,0,0.04);">
        <h1 class="reg-form-panel__heading">Forgot your password?</h1>
        <p class="reg-form-panel__sub">Enter the email address or username linked to your ScienceBuddy account.</p>

        <asp:Panel ID="pnlStatus" runat="server" Visible="false">
            <div id="divStatus" runat="server" class="reg-status" role="alert" aria-live="assertive" tabindex="-1"></div>
        </asp:Panel>

        <asp:Panel ID="pnlForm" runat="server" DefaultButton="btnSend">
            <div class="reg-field">
                <label>Username or Email <span style="color:#DC2626;">*</span></label>
                <asp:TextBox ID="txtIdentifier" runat="server" MaxLength="150" placeholder="Enter your username or email" />
                <asp:RequiredFieldValidator ID="rfvId" runat="server" ControlToValidate="txtIdentifier" ValidationGroup="FP" Display="Dynamic" CssClass="field-validation-error" ErrorMessage="This field is required.">Required</asp:RequiredFieldValidator>
            </div>
            <asp:Button ID="btnSend" runat="server" Text="Send Reset Link" CssClass="reg-btn" OnClick="BtnSend_Click" ValidationGroup="FP" />
        </asp:Panel>

        <div class="reg-signin-link" style="margin-top:18px;"><a href="<%: ResolveUrl("~/Login") %>"><i class="bi bi-arrow-left"></i> Back to Sign In</a></div>
    </div>
</div>
</asp:Content>
