<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Practice.aspx.cs"
    Inherits="ScienceBuddy.Student.Practice" MasterPageFile="~/Site.Master"
    Title="Practice Page" %>

<%-- HEAD: load Student CSS --%>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%: ResolveUrl("~/Content/Student.css") %>" rel="stylesheet" />
    <style>
        .practice-card {
            background: #fff;
            border: 1.5px solid #E2E8F0;
            border-radius: 16px;
            padding: 28px 32px;
            max-width: 500px;
            margin: 40px auto;
            box-shadow: 0 4px 16px rgba(37,99,235,.10);
        }
        .practice-title {
            font-family: 'Poppins', sans-serif;
            font-size: 1.4rem;
            font-weight: 700;
            color: #2563EB;
            margin-bottom: 4px;
        }
        .practice-subtitle {
            font-size: 0.9rem;
            color: #64748B;
            margin-bottom: 24px;
        }
        .practice-field { margin-bottom: 18px; }
        .practice-field label {
            display: block;
            font-weight: 600;
            font-size: 0.875rem;
            color: #1E293B;
            margin-bottom: 6px;
        }
        .practice-field input {
            width: 100%;
            padding: 10px 14px;
            border: 1.5px solid #E2E8F0;
            border-radius: 10px;
            font-size: 0.9rem;
            font-family: 'Poppins', sans-serif;
            color: #1E293B;
            background: #FAFBFE;
            box-sizing: border-box;
        }
        .practice-field input:focus {
            border-color: #2563EB;
            outline: none;
            box-shadow: 0 0 0 3px rgba(37,99,235,.08);
        }
        .practice-btn {
            width: 100%;
            padding: 12px;
            background: #2563EB;
            color: #fff;
            border: none;
            border-radius: 10px;
            font-size: 0.95rem;
            font-weight: 700;
            font-family: 'Poppins', sans-serif;
            cursor: pointer;
            margin-top: 4px;
        }
        .practice-btn:hover { background: #1D4ED8; }
        .practice-result {
            margin-top: 20px;
            padding: 14px 18px;
            border-radius: 10px;
            font-size: 0.9rem;
            font-weight: 600;
        }
        .practice-result.success {
            background: #DCFCE7;
            color: #15803D;
            border: 1.5px solid #86EFAC;
        }
        .practice-result.error {
            background: #FEE2E2;
            color: #B91C1C;
            border: 1.5px solid #FCA5A5;
        }
        .practice-greeting {
            margin-top: 20px;
            padding: 16px 18px;
            background: #EFF6FF;
            border-radius: 10px;
            border: 1.5px solid #BFDBFE;
        }
        .practice-greeting .greeting-label {
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: #2563EB;
            margin-bottom: 4px;
        }
        .practice-greeting .greeting-text {
            font-size: 1rem;
            font-weight: 600;
            color: #1E293B;
        }
    </style>
</asp:Content>

<%-- SIDEBAR MENU --%>
<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Practice</div>
        <a href="<%: ResolveUrl("~/Student/Practice.aspx") %>" class="sb-sidebar-item active">
            <i class="bi bi-code-square item-icon"></i>
            <span class="item-label">My Practice Page</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/Dashboard.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-speedometer2 item-icon"></i>
            <span class="item-label">Back to Dashboard</span>
        </a>
    </div>
</asp:Content>

<%-- PAGE TITLE IN HEADER --%>
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    My Practice Page
</asp:Content>

<%-- MAIN CONTENT --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

    <div class="practice-card">

        <div class="practice-title">Hello, Practice!</div>
        <div class="practice-subtitle">
            This page is for you to practise writing your own code-behind logic.
        </div>

        <%-- INPUT: Name --%>
        <div class="practice-field">
            <label for="<%: txtName.ClientID %>">Your Name</label>
            <asp:TextBox ID="txtName" runat="server"
                placeholder="Enter your name here..." />
        </div>

        <%-- INPUT: Favourite subject --%>
        <div class="practice-field">
            <label for="<%: txtSubject.ClientID %>">Favourite Subject</label>
            <asp:TextBox ID="txtSubject" runat="server"
                placeholder="e.g. Science, Maths..." />
        </div>

        <%-- BUTTON: Submit --%>
        <asp:Button ID="btnSubmit" runat="server"
            Text="Say Hello!"
            CssClass="practice-btn"
            OnClick="btnSubmit_Click" />

        <%-- ERROR MESSAGE (hidden by default, shown by code-behind) --%>
        <asp:Panel ID="pnlError" runat="server" Visible="false">
            <div class="practice-result error">
                <asp:Literal ID="litError" runat="server" />
            </div>
        </asp:Panel>

        <%-- GREETING RESULT (hidden by default, shown by code-behind) --%>
        <asp:Panel ID="pnlGreeting" runat="server" Visible="false">
            <div class="practice-greeting">
                <div class="greeting-label">Greeting from the server</div>
                <div class="greeting-text">
                    <asp:Literal ID="litGreeting" runat="server" />
                </div>
            </div>
        </asp:Panel>

    </div>

</asp:Content>
