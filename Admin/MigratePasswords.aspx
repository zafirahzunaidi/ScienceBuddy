<%@ Page Title="Migrate Passwords" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MigratePasswords.aspx.cs" Inherits="ScienceBuddy.Admin.MigratePasswords" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div style="max-width:600px;margin:60px auto;padding:24px;background:#fff;border-radius:16px;border:1.5px solid #E2E8F0;">
    <h2>BCrypt Password Migration</h2>
    <p>This will convert all existing plaintext passwords to BCrypt hashes. Run once only.</p>
    <asp:Panel ID="pnlResult" runat="server" Visible="false">
        <div style="background:#F0FDF4;border:1px solid #A7F3D0;border-radius:10px;padding:14px;margin-bottom:16px;">
            <asp:Literal ID="litResult" runat="server" />
        </div>
    </asp:Panel>
    <asp:Button ID="btnMigrate" runat="server" Text="Run Migration" OnClick="BtnMigrate_Click" CssClass="reg-btn" style="max-width:200px;" />
</div>
</asp:Content>
