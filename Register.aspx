<%@ Page Title="Register" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="ScienceBuddy.Register" %>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%: ResolveUrl("~/Content/Registration.css") %>?v=2" rel="stylesheet" />
</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="reg-role-page">
    <h1 class="reg-role-page__title">Get started as a...</h1>
    <div class="reg-role-page__cards">
        <a href="<%: ResolveUrl("~/StudentRegistration.aspx") %>" class="reg-role-card reg-role-card--student">
            <div class="reg-role-card__icon"><i class="bi bi-mortarboard-fill"></i></div>
            <div class="reg-role-card__name">Student</div>
            <div class="reg-role-card__arrow"><i class="bi bi-arrow-right"></i></div>
        </a>
        <a href="<%: ResolveUrl("~/ParentRegistration.aspx") %>" class="reg-role-card reg-role-card--parent">
            <div class="reg-role-card__icon"><i class="bi bi-heart-fill"></i></div>
            <div class="reg-role-card__name">Parent</div>
            <div class="reg-role-card__arrow"><i class="bi bi-arrow-right"></i></div>
        </a>
        <a href="<%: ResolveUrl("~/TeacherRegistration.aspx") %>" class="reg-role-card reg-role-card--teacher">
            <div class="reg-role-card__icon"><i class="bi bi-journal-bookmark-fill"></i></div>
            <div class="reg-role-card__name">Teacher</div>
            <div class="reg-role-card__arrow"><i class="bi bi-arrow-right"></i></div>
        </a>
    </div>
    <div class="reg-signin-link">Already have an account? <a href="<%: ResolveUrl("~/Login") %>">Sign In</a></div>
</div>
</asp:Content>
