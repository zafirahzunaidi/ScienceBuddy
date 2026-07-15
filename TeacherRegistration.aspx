<%@ Page Title="Teacher Registration" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="TeacherRegistration.aspx.cs" Inherits="ScienceBuddy.TeacherRegistration" %>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%: ResolveUrl("~/Content/Registration.css") %>?v=2" rel="stylesheet" />
</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="reg-page">
    <div class="reg-visual reg-visual--teacher">
        <img src="<%: ResolveUrl("~/Images/Logo/sciencebuddy-logo.png") %>" alt="" class="reg-visual__mascot" />
        <h2 class="reg-visual__title">Inspire Curious Minds</h2>
        <p class="reg-visual__sub">Share your knowledge and help students discover the excitement of science.</p>
    </div>
    <div class="reg-form-panel">
        <asp:Panel ID="pnlForm" runat="server">
            <h1 class="reg-form-panel__heading">Create your account</h1>
            <p class="reg-form-panel__sub">Join as a Teacher and start guiding young scientists.</p>
            <asp:Panel ID="pnlError" runat="server" Visible="false"><div class="reg-status reg-status--error"><asp:Literal ID="litError" runat="server" /></div></asp:Panel>
            <asp:ValidationSummary ID="vs" runat="server" ValidationGroup="Reg" CssClass="reg-validation-summary" HeaderText="Please fix:" />

            <%-- Section: Personal Information --%>
            <div class="reg-section-title">Personal Information</div>
            <div class="reg-row">
                <div class="reg-field"><label>Full Name <span style="color:#DC2626;">*</span></label><asp:TextBox ID="txtName" runat="server" MaxLength="80" /><asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtName" ValidationGroup="Reg" Display="Dynamic" CssClass="field-validation-error" ErrorMessage="Full Name is required.">Required</asp:RequiredFieldValidator></div>
                <div class="reg-field"><label>Username <span style="color:#DC2626;">*</span></label><asp:TextBox ID="txtUsername" runat="server" MaxLength="50" /><asp:RequiredFieldValidator ID="rfvUser" runat="server" ControlToValidate="txtUsername" ValidationGroup="Reg" Display="Dynamic" CssClass="field-validation-error" ErrorMessage="Username is required.">Required</asp:RequiredFieldValidator></div>
            </div>
            <div class="reg-row">
                <div class="reg-field"><label>Email Address <span style="color:#DC2626;">*</span></label><asp:TextBox ID="txtEmail" runat="server" TextMode="Email" MaxLength="100" /><asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" ValidationGroup="Reg" Display="Dynamic" CssClass="field-validation-error" ErrorMessage="Email is required.">Required</asp:RequiredFieldValidator><asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail" ValidationGroup="Reg" ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" Display="Dynamic" CssClass="field-validation-error" ErrorMessage="Invalid email.">Invalid email</asp:RegularExpressionValidator></div>
                <div class="reg-field"><label>Phone Number <span style="color:#DC2626;">*</span></label><asp:TextBox ID="txtPhone" runat="server" MaxLength="20" /><asp:RequiredFieldValidator ID="rfvPhone" runat="server" ControlToValidate="txtPhone" ValidationGroup="Reg" Display="Dynamic" CssClass="field-validation-error" ErrorMessage="Phone is required.">Required</asp:RequiredFieldValidator></div>
            </div>

            <%-- Section: Professional Information --%>
            <div class="reg-section-title">Professional Information</div>
            <div class="reg-field"><label>Academic Qualification <span style="color:#DC2626;">*</span></label><asp:TextBox ID="txtQualification" runat="server" MaxLength="150" /><asp:RequiredFieldValidator ID="rfvQualification" runat="server" ControlToValidate="txtQualification" ValidationGroup="Reg" Display="Dynamic" CssClass="field-validation-error" ErrorMessage="Academic Qualification is required.">Required</asp:RequiredFieldValidator></div>
            <div class="reg-field"><label>Short Biography <span style="color:#DC2626;">*</span></label><asp:TextBox ID="txtBio" runat="server" TextMode="MultiLine" Rows="4" MaxLength="500" /><asp:RequiredFieldValidator ID="rfvBio" runat="server" ControlToValidate="txtBio" ValidationGroup="Reg" Display="Dynamic" CssClass="field-validation-error" ErrorMessage="Short Biography is required.">Required</asp:RequiredFieldValidator></div>
            <div class="reg-field"><label>Teaching Certificate <span style="color:#DC2626;">*</span></label><asp:FileUpload ID="fuCertificate" runat="server" CssClass="reg-file-upload" /><span class="reg-field__note">Upload your teaching certificate in PDF format for administrator verification. Your account will remain pending until it is approved. (Max 5MB)</span></div>

            <%-- Section: Account Security --%>
            <div class="reg-section-title">Account Security</div>
            <div class="reg-row">
                <div class="reg-field"><label>Password <span style="color:#DC2626;">*</span></label><asp:TextBox ID="txtPassword" runat="server" TextMode="Password" MaxLength="50" /><asp:RequiredFieldValidator ID="rfvPass" runat="server" ControlToValidate="txtPassword" ValidationGroup="Reg" Display="Dynamic" CssClass="field-validation-error" ErrorMessage="Password is required.">Required</asp:RequiredFieldValidator></div>
                <div class="reg-field"><label>Confirm Password <span style="color:#DC2626;">*</span></label><asp:TextBox ID="txtConfirm" runat="server" TextMode="Password" MaxLength="50" /><asp:CompareValidator ID="cvPass" runat="server" ControlToValidate="txtConfirm" ControlToCompare="txtPassword" ValidationGroup="Reg" Display="Dynamic" CssClass="field-validation-error" ErrorMessage="Passwords do not match.">Passwords do not match</asp:CompareValidator></div>
            </div>
            <div class="reg-field"><label>Preferred Language <span style="color:#DC2626;">*</span></label><asp:DropDownList ID="ddlLanguage" runat="server"><asp:ListItem Value="EN" Text="English" /><asp:ListItem Value="BM" Text="Bahasa Melayu" /></asp:DropDownList></div>

            <asp:Button ID="btnRegister" runat="server" Text="Create Teacher Account" CssClass="reg-btn" OnClick="BtnRegister_Click" ValidationGroup="Reg" />
            <div class="reg-signin-link">Already have an account? <a href="<%: ResolveUrl("~/Login") %>">Sign In</a></div>
        </asp:Panel>
    </div>
</div>
</asp:Content>
