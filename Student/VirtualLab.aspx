<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="VirtualLab.aspx.cs" Inherits="ScienceBuddy.Student.VirtualLab1" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%: ResolveUrl("~/Content/Student.css") %>" rel="stylesheet" />
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%= T("Main", "Utama") %></div>
        <a href="<%: ResolveUrl("~/Student/Dashboard.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%= T("Dashboard", "Papan Pemuka") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Student/Notifications.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-bell item-icon"></i><span class="item-label"><%= T("Notifications", "Notifikasi") %></span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%= T("Learn", "Belajar") %></div>
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-book item-icon"></i><span class="item-label"><%= T("My Learning", "Pembelajaran Saya") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Student/PracticeLibrary.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-patch-question item-icon"></i><span class="item-label"><%= T("Practice Library", "Perpustakaan Latihan") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Student/QuizHistory.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-clock-history item-icon"></i><span class="item-label"><%= T("Quiz History", "Sejarah Kuiz") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Student/VirtualLabs.aspx") %>" class="sb-sidebar-item active">
            <i class="bi bi-eyedropper item-icon"></i><span class="item-label"><%= T("Virtual Labs", "Makmal Maya") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Student/LiveSessions.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-camera-video item-icon"></i><span class="item-label"><%= T("Live Sessions", "Sesi Langsung") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Student/AIStudyCompanion.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-robot item-icon"></i><span class="item-label"><%= T("AI Study Companion", "Teman Belajar AI") %></span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%= T("Communication", "Komunikasi") %></div>
        <a href="<%: ResolveUrl("~/Student/Messages.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%= T("Messages", "Mesej") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Student/Forum.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-people item-icon"></i><span class="item-label"><%= T("Forum", "Forum") %></span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%= T("Progress", "Kemajuan") %></div>
        <a href="<%: ResolveUrl("~/Student/ProgressRewards.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-bar-chart-line item-icon"></i><span class="item-label"><%= T("Progress &amp; Rewards", "Kemajuan &amp; Ganjaran") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Student/MyRanking.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-trophy item-icon"></i><span class="item-label"><%= T("My Ranking", "Kedudukan Saya") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Student/RevisionPlan.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-calendar-check item-icon"></i><span class="item-label"><%= T("Revision Plan", "Pelan Ulangkaji") %></span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%= T("Account", "Akaun") %></div>
        <a href="<%: ResolveUrl("~/Student/MyProfile.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-person item-icon"></i><span class="item-label"><%= T("My Profile", "Profil Saya") %></span>
        </a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><asp:Literal ID="litPageTitle" runat="server" Text="Virtual Lab" /></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">
<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="st-virtuallab-error">
        <div class="st-virtuallab-error-icon"><i class="bi bi-exclamation-triangle-fill"></i></div>
        <div class="st-virtuallab-error-title"><asp:Literal ID="litErrorTitle" runat="server" /></div>
        <div class="st-virtuallab-error-desc"><asp:Literal ID="litErrorDesc" runat="server" /></div>
        <a href="<%: ResolveUrl("~/Student/VirtualLabs.aspx") %>" class="sb-btn sb-btn-primary sb-btn-sm">
            <i class="bi bi-arrow-left"></i> <asp:Literal ID="litErrorBtn" runat="server" />
        </a>
    </div>
</asp:Panel>
</asp:Content>
