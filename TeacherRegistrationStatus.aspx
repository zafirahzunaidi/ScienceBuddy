<%@ Page Title="Teacher Registration Status" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="TeacherRegistrationStatus.aspx.cs" Inherits="ScienceBuddy.TeacherRegistrationStatus" %>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%: ResolveUrl("~/Content/Registration.css") %>?v=2" rel="stylesheet" />
</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="reg-page">
    <div class="reg-teacher-status">

        <%-- PENDING --%>
        <asp:Panel ID="pnlPending" runat="server" Visible="false">
            <div class="reg-status-card reg-status-card--pending">
                <div class="reg-status-card__icon"><i class="bi bi-hourglass-split"></i></div>
                <h2 class="reg-status-card__title">Your Registration Is Under Review</h2>
                <p class="reg-status-card__text">Thank you for registering, <asp:Literal ID="litTeacherName" runat="server" />. Your teaching certificate is being reviewed by our admin team.</p>
                <div class="reg-status-card__detail"><strong>Qualification:</strong> <asp:Literal ID="litQualification" runat="server" /></div>
                <div class="reg-status-card__badge"><i class="bi bi-clock-history"></i> Pending Approval</div>
                <div class="reg-status-card__actions">
                    <a href="<%: ResolveUrl("~/") %>" class="reg-btn reg-btn--outline">Return to Home</a>
                    <a href="<%: ResolveUrl("~/Contact") %>" class="reg-btn reg-btn--outline">Contact Support</a>
                </div>
            </div>
        </asp:Panel>

        <%-- CERTIFIED --%>
        <asp:Panel ID="pnlCertified" runat="server" Visible="false">
            <div class="reg-status-card reg-status-card--certified">
                <div class="reg-status-card__icon"><i class="bi bi-patch-check-fill"></i></div>
                <h2 class="reg-status-card__title">Certificate Approved!</h2>
                <p class="reg-status-card__text">Congratulations! Your teaching certificate has been approved. You can now access your Teacher Dashboard.</p>
                <div class="reg-status-card__actions">
                    <a href="<%: ResolveUrl("~/Login") %>" class="reg-btn">Go to Sign In</a>
                </div>
            </div>
        </asp:Panel>

        <%-- REJECTED (Not Certified) --%>
        <asp:Panel ID="pnlRejected" runat="server" Visible="false">
            <div class="reg-status-card reg-status-card--rejected">
                <div class="reg-status-card__icon"><i class="bi bi-x-circle-fill"></i></div>
                <h2 class="reg-status-card__title">Certificate Not Approved</h2>
                <p class="reg-status-card__text">Unfortunately, your teaching certificate was not approved. You may upload a new certificate for review.</p>
                <div class="reg-status-card__detail"><strong>Previous file:</strong> <asp:Literal ID="litCertFile" runat="server" /></div>
                <div class="reg-field" style="margin-top:1.5rem;"><label>Upload New Certificate</label><asp:FileUpload ID="fuNewCertificate" runat="server" CssClass="reg-file-upload" /><span class="reg-field__note">Upload your teaching certificate (PDF only, max 5MB)</span></div>
                <asp:Panel ID="pnlResubmitError" runat="server" Visible="false"><div class="reg-status reg-status--error"><asp:Literal ID="litResubmitError" runat="server" /></div></asp:Panel>
                <div class="reg-status-card__actions">
                    <asp:Button ID="btnResubmit" runat="server" Text="Resubmit Certificate" CssClass="reg-btn" OnClick="BtnResubmit_Click" />
                    <a href="<%: ResolveUrl("~/Contact") %>" class="reg-btn reg-btn--outline">Contact Support</a>
                </div>
            </div>
        </asp:Panel>

        <%-- BLOCKED --%>
        <asp:Panel ID="pnlBlocked" runat="server" Visible="false">
            <div class="reg-status-card reg-status-card--blocked">
                <div class="reg-status-card__icon"><i class="bi bi-shield-exclamation"></i></div>
                <h2 class="reg-status-card__title">Account Blocked</h2>
                <p class="reg-status-card__text">Your account has been blocked. Please contact support for more information.</p>
                <div class="reg-status-card__actions">
                    <a href="<%: ResolveUrl("~/Contact") %>" class="reg-btn reg-btn--outline">Contact Support</a>
                    <a href="<%: ResolveUrl("~/") %>" class="reg-btn reg-btn--outline">Return to Home</a>
                </div>
            </div>
        </asp:Panel>

        <%-- DELETED --%>
        <asp:Panel ID="pnlDeleted" runat="server" Visible="false">
            <div class="reg-status-card reg-status-card--deleted">
                <div class="reg-status-card__icon"><i class="bi bi-trash3-fill"></i></div>
                <h2 class="reg-status-card__title">Account Removed</h2>
                <p class="reg-status-card__text">This account has been removed from the system. Please contact support if you believe this is an error.</p>
                <div class="reg-status-card__actions">
                    <a href="<%: ResolveUrl("~/Contact") %>" class="reg-btn reg-btn--outline">Contact Support</a>
                    <a href="<%: ResolveUrl("~/") %>" class="reg-btn reg-btn--outline">Return to Home</a>
                </div>
            </div>
        </asp:Panel>

    </div>
</div>
</asp:Content>
