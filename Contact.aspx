<%@ Page Title="Contact" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Contact.aspx.cs" Inherits="ScienceBuddy.Contact" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%: ResolveUrl("~/Content/About.css") %>?v=2" rel="stylesheet" />
    <link href="<%: ResolveUrl("~/Content/Contact.css") %>" rel="stylesheet" />
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="contact-page">

    <%-- ══ 1. HERO ══ --%>
    <section class="contact-hero">
        <div class="contact-hero__inner">
            <div class="contact-hero__visual">
                <img src="<%: ResolveUrl("~/Images/Contact/contact-logo.png") %>" alt="ScienceBuddy Contact" class="contact-hero__img" />
            </div>
            <div class="contact-hero__text">
                <div class="contact-hero__label">CONTACT SCIENCEBUDDY</div>
                <h1 class="contact-hero__title">Questions? We're Here to Help.</h1>
                <p class="contact-hero__subtitle">Have a question about registration, lessons, quizzes or using ScienceBuddy? Send us a message and our team will be happy to assist you.</p>
            </div>
        </div>
    </section>

    <%-- ══ 2. FORM + INFO ══ --%>
    <section class="contact-section">
        <div class="contact-info">
            <h2 class="contact-info__heading">Let's Talk</h2>
            <p class="contact-info__text">Whether you are a student, parent, teacher or visitor, we would love to hear from you. Complete the form and your message will be sent directly to the ScienceBuddy administrator.</p>
            <div class="contact-info__card">
                <div class="contact-info__card-icon"><i class="bi bi-envelope-fill"></i></div>
                <div><div class="contact-info__card-label">Email</div><div class="contact-info__card-value">najihahazmi26@gmail.com</div></div>
            </div>
            <div class="contact-info__card">
                <div class="contact-info__card-icon"><i class="bi bi-geo-alt-fill"></i></div>
                <div><div class="contact-info__card-label">Location</div><div class="contact-info__card-value">14, Jalan AmanPutra 3/2,<br/>Taman AmanPutra, 47130 Puchong,<br/>Selangor, Malaysia</div></div>
            </div>
            <div class="contact-info__card">
                <div class="contact-info__card-icon"><i class="bi bi-clock-fill"></i></div>
                <div><div class="contact-info__card-label">Response Time</div><div class="contact-info__card-value">We usually respond within 1–2 working days.</div></div>
            </div>
        </div>

        <div class="contact-form-card">
            <asp:Panel ID="pnlStatus" runat="server" Visible="false">
                <div id="divStatus" runat="server" class="contact-status" role="alert" aria-live="polite"></div>
            </asp:Panel>

            <asp:ValidationSummary ID="vsSummary" runat="server" ValidationGroup="ContactForm" CssClass="validation-summary-errors" HeaderText="Please fix the following:" />

            <div class="contact-field">
                <label for="<%: txtName.ClientID %>">Full Name</label>
                <asp:TextBox ID="txtName" runat="server" MaxLength="80" CssClass="contact-input" />
                <asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtName" ValidationGroup="ContactForm" ErrorMessage="Full Name is required." Display="Dynamic" CssClass="field-validation-error">Full Name is required.</asp:RequiredFieldValidator>
            </div>
            <div class="contact-field">
                <label for="<%: txtEmail.ClientID %>">Email Address</label>
                <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" MaxLength="100" CssClass="contact-input" />
                <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" ValidationGroup="ContactForm" ErrorMessage="Email Address is required." Display="Dynamic" CssClass="field-validation-error">Email is required.</asp:RequiredFieldValidator>
                <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail" ValidationGroup="ContactForm" ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" ErrorMessage="Invalid email format." Display="Dynamic" CssClass="field-validation-error">Invalid email format.</asp:RegularExpressionValidator>
            </div>
            <div class="contact-field">
                <label for="<%: ddlType.ClientID %>">Enquiry Type</label>
                <asp:DropDownList ID="ddlType" runat="server" CssClass="contact-input">
                    <asp:ListItem Value="" Text="-- Select --" />
                    <asp:ListItem Value="General Enquiry" />
                    <asp:ListItem Value="Registration Help" />
                    <asp:ListItem Value="Login Problem" />
                    <asp:ListItem Value="Learning Content" />
                    <asp:ListItem Value="Quiz and Assessment" />
                    <asp:ListItem Value="Public Forum" />
                    <asp:ListItem Value="Technical Problem" />
                    <asp:ListItem Value="Teacher Registration" />
                    <asp:ListItem Value="Other" />
                </asp:DropDownList>
                <asp:RequiredFieldValidator ID="rfvType" runat="server" ControlToValidate="ddlType" InitialValue="" ValidationGroup="ContactForm" ErrorMessage="Please select an enquiry type." Display="Dynamic" CssClass="field-validation-error">Please select an enquiry type.</asp:RequiredFieldValidator>
            </div>
            <div class="contact-field">
                <label for="<%: txtSubject.ClientID %>">Subject</label>
                <asp:TextBox ID="txtSubject" runat="server" MaxLength="120" CssClass="contact-input" />
                <asp:RequiredFieldValidator ID="rfvSubject" runat="server" ControlToValidate="txtSubject" ValidationGroup="ContactForm" ErrorMessage="Subject is required." Display="Dynamic" CssClass="field-validation-error">Subject is required.</asp:RequiredFieldValidator>
            </div>
            <div class="contact-field">
                <label for="<%: txtMessage.ClientID %>">Message</label>
                <asp:TextBox ID="txtMessage" runat="server" TextMode="MultiLine" Rows="5" MaxLength="1500" CssClass="contact-input" />
                <asp:RequiredFieldValidator ID="rfvMessage" runat="server" ControlToValidate="txtMessage" ValidationGroup="ContactForm" ErrorMessage="Message is required." Display="Dynamic" CssClass="field-validation-error">Message is required.</asp:RequiredFieldValidator>
            </div>
            <%-- Honeypot --%>
            <div class="contact-honeypot"><label>Leave blank</label><asp:TextBox ID="txtHoney" runat="server" TabIndex="-1" autocomplete="off" /></div>
            <asp:Button ID="btnSend" runat="server" Text="Send Message" CssClass="contact-btn" OnClick="BtnSend_Click" ValidationGroup="ContactForm" />
        </div>
    </section>

    <%-- ══ 3. MAP ══ --%>
    <section class="contact-map">
        <iframe class="contact-map__frame" title="ScienceBuddy location" loading="lazy" referrerpolicy="no-referrer-when-downgrade"
            src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3984.5!2d101.62!3d3.03!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x0%3A0x0!2sTaman+AmanPutra%2C+47130+Puchong%2C+Selangor!5e0!3m2!1sen!2smy!4v1700000000000"
            allowfullscreen></iframe>
        <a href="https://www.google.com/maps/search/14+Jalan+AmanPutra+3%2F2+Taman+AmanPutra+47130+Puchong+Selangor" target="_blank" rel="noopener noreferrer" class="contact-map__link"><i class="bi bi-box-arrow-up-right"></i> Get Directions</a>
    </section>

    <%-- ══ 4. FAQ ══ --%>
    <section class="contact-faq">
        <h2 class="contact-faq__title">Frequently Asked Questions</h2>
        <div class="contact-faq__item"><button type="button" class="contact-faq__btn" aria-expanded="false" aria-controls="faq1">Can I explore ScienceBuddy without registering? <i class="bi bi-chevron-down"></i></button><div id="faq1" class="contact-faq__answer"><div class="contact-faq__answer-inner">Yes. Guests can browse public learning modules, preview selected lesson content, try sample quiz questions and read public forum discussions.</div></div></div>
        <div class="contact-faq__item"><button type="button" class="contact-faq__btn" aria-expanded="false" aria-controls="faq2">Why can't I access the complete lesson? <i class="bi bi-chevron-down"></i></button><div id="faq2" class="contact-faq__answer"><div class="contact-faq__answer-inner">Full lessons, complete quizzes, saved progress and personalised learning features require a registered ScienceBuddy account.</div></div></div>
        <div class="contact-faq__item"><button type="button" class="contact-faq__btn" aria-expanded="false" aria-controls="faq3">Are Guest quiz results saved? <i class="bi bi-chevron-down"></i></button><div id="faq3" class="contact-faq__answer"><div class="contact-faq__answer-inner">No. Guest quiz scores, attempts and progress are not stored.</div></div></div>
        <div class="contact-faq__item"><button type="button" class="contact-faq__btn" aria-expanded="false" aria-controls="faq4">Can Guests participate in the forum? <i class="bi bi-chevron-down"></i></button><div id="faq4" class="contact-faq__answer"><div class="contact-faq__answer-inner">Guests can read public discussions, but registration and login are required to post, reply or like content.</div></div></div>
        <div class="contact-faq__item"><button type="button" class="contact-faq__btn" aria-expanded="false" aria-controls="faq5">Does ScienceBuddy support Bahasa Melayu? <i class="bi bi-chevron-down"></i></button><div id="faq5" class="contact-faq__answer"><div class="contact-faq__answer-inner">Yes. ScienceBuddy supports both English and Bahasa Melayu across its learning experience.</div></div></div>
        <div class="contact-faq__item"><button type="button" class="contact-faq__btn" aria-expanded="false" aria-controls="faq6">How long will it take to receive a reply? <i class="bi bi-chevron-down"></i></button><div id="faq6" class="contact-faq__answer"><div class="contact-faq__answer-inner">The ScienceBuddy team usually responds within 1–2 working days.</div></div></div>
    </section>

    <%-- ══ 5. CTA ══ --%>
    <section class="contact-cta">
        <h2>Ready to Begin Your Science Journey?</h2>
        <p>Choose your role and discover everything ScienceBuddy has to offer.</p>
        <button type="button" class="contact-cta__btn" id="contactGetStartedBtn"><i class="bi bi-rocket-takeoff-fill"></i> Get Started</button>
    </section>

    <%-- ══ ROLE-SELECTION MODAL (reused from About page) ══ --%>
    <div class="about-modal-overlay" id="contactRoleModal" role="dialog" aria-modal="true" aria-labelledby="contactModalTitle">
        <div class="about-modal">
            <button type="button" class="about-modal__close" aria-label="Close">&times;</button>
            <h3 id="contactModalTitle">How would you like to continue?</h3>
            <div class="about-modal__roles">
                <a href="<%: ResolveUrl("~/StudentRegistration.aspx") %>" class="about-modal__role" data-role="student">
                    <div class="about-modal__role-icon about-modal__role-icon--student"><i class="bi bi-mortarboard-fill"></i></div>
                    <div class="about-modal__role-info"><h4>Student</h4><p>Learn and explore</p></div>
                </a>
                <a href="<%: ResolveUrl("~/ParentRegistration.aspx") %>" class="about-modal__role" data-role="parent">
                    <div class="about-modal__role-icon about-modal__role-icon--parent"><i class="bi bi-heart-fill"></i></div>
                    <div class="about-modal__role-info"><h4>Parent</h4><p>Support and encourage</p></div>
                </a>
                <a href="<%: ResolveUrl("~/TeacherRegistration.aspx") %>" class="about-modal__role" data-role="teacher">
                    <div class="about-modal__role-icon about-modal__role-icon--teacher"><i class="bi bi-journal-bookmark-fill"></i></div>
                    <div class="about-modal__role-info"><h4>Teacher</h4><p>Guide and inspire</p></div>
                </a>
            </div>
        </div>
    </div>

</div>
<script src="<%: ResolveUrl("~/Scripts/Contact.js") %>"></script>
</asp:Content>
