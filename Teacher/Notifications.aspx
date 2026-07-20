<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Notifications.aspx.cs"
    Inherits="ScienceBuddy.Teacher.Notifications" MasterPageFile="~/Site.Master" Title="Notifications" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%: ResolveUrl("~/Content/Teacher.css") %>" rel="stylesheet" />
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-speedometer2 item-icon"></i>
            <span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Teacher/Notifications.aspx") %>" class="sb-sidebar-item active">
            <i class="bi bi-bell item-icon"></i>
            <span class="item-label"><%: T("Notifications","Notifikasi") %></span>
        </a>
    </div>

    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Teaching","Pengajaran") %></div>
        <a href="<%: ResolveUrl("~/Teacher/manageMaterials.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-book item-icon"></i>
            <span class="item-label"><%: T("Manage Materials","Bahan Pembelajaran") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-patch-question item-icon"></i>
            <span class="item-label"><%: T("Manage Quiz","Kuiz") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Teacher/studentProgress.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-bar-chart item-icon"></i>
            <span class="item-label"><%: T("Student Progress","Prestasi Pelajar") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Teacher/liveSession.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-camera-video item-icon"></i>
            <span class="item-label"><%: T("Schedule Live Class","Kelas Langsung") %></span>
        </a>
    </div>

    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Community","Komuniti") %></div>
        <a href="<%: ResolveUrl("~/Teacher/forum.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-chat-dots item-icon"></i>
            <span class="item-label"><%: T("Forum","Forum") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Teacher/privateMessages.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-envelope item-icon"></i>
            <span class="item-label"><%: T("Private Message","Mesej Peribadi") %></span>
        </a>
    </div>

    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Account","Akaun") %></div>
        <a href="<%: ResolveUrl("~/Teacher/MyProfile.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-person item-icon"></i>
            <span class="item-label"><%: T("My Profile","Profil Saya") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-box-arrow-right item-icon"></i>
            <span class="item-label"><%: T("Sign Out","Log Keluar") %></span>
        </a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <%: T("Notifications","Notifikasi") %>
</asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

    <%-- Page Header --%>
    <div class="tc-notifications-header">
        <h1><%: T("Notifications","Notifikasi") %></h1>
        <p><%: T("Stay updated with your latest ScienceBuddy activities.","Kekal dikemas kini dengan aktiviti ScienceBuddy terkini anda.") %></p>
    </div>

    <%-- Tabs --%>
    <div class="tc-notifications-tabs">
        <asp:LinkButton ID="btnTabAll" runat="server"
            CssClass="tc-notifications-tab active"
            OnClick="btnTab_Click"
            CommandArgument="All"
            CausesValidation="false">
            <%: T("All","Semua") %>
            <span class="tc-notifications-tab-count">
                <asp:Literal ID="litCountAll" runat="server" Text="0" />
            </span>
        </asp:LinkButton>

        <asp:LinkButton ID="btnTabUnread" runat="server"
            CssClass="tc-notifications-tab"
            OnClick="btnTab_Click"
            CommandArgument="Unread"
            CausesValidation="false">
            <%: T("Unread","Belum Dibaca") %>
            <span class="tc-notifications-tab-count">
                <asp:Literal ID="litCountUnread" runat="server" Text="0" />
            </span>
        </asp:LinkButton>

        <asp:LinkButton ID="btnTabRead" runat="server"
            CssClass="tc-notifications-tab"
            OnClick="btnTab_Click"
            CommandArgument="Read"
            CausesValidation="false">
            <%: T("Read","Dibaca") %>
            <span class="tc-notifications-tab-count">
                <asp:Literal ID="litCountRead" runat="server" Text="0" />
            </span>
        </asp:LinkButton>
    </div>

    <%-- Notification List --%>
    <asp:Panel ID="pnlList" runat="server" Visible="false">
        <div class="tc-notifications-list">
            <asp:Repeater ID="rptNotifs" runat="server" OnItemCommand="rptNotifs_ItemCommand">
                <ItemTemplate>
                    <div class='tc-notifications-card <%# Convert.ToBoolean(Eval("isRead")) ? "" : "unread" %>'>
                        <div class="tc-notifications-card-icon">
                            <i class="bi bi-bell-fill"></i>
                        </div>

                        <div class="tc-notifications-card-body">
                            <div class="tc-notifications-card-title">
                                <%# !Convert.ToBoolean(Eval("isRead")) ? "<span class='tc-notifications-dot'></span>" : "" %>
                                <%# HttpUtility.HtmlEncode(Eval("title")) %>
                            </div>
                            <div class="tc-notifications-card-msg">
                                <%# HttpUtility.HtmlEncode(Eval("message")) %>
                            </div>
                            <div class="tc-notifications-card-time">
                                <i class="bi bi-clock"></i> <%# Eval("timeDisplay") %>
                            </div>
                        </div>

                        <asp:LinkButton ID="btnMark" runat="server"
                            CommandName="MarkRead"
                            CommandArgument='<%# Eval("notificationId") %>'
                            CssClass="tc-notifications-mark-btn"
                            CausesValidation="false"
                            Visible='<%# !Convert.ToBoolean(Eval("isRead")) %>'>
                            <i class="bi bi-check2"></i> <%# CurrentLanguage=="BM"?"Tandai Dibaca":"Mark as Read" %>
                        </asp:LinkButton>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>

    <%-- Empty State --%>
    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="tc-notifications-empty">
            <div class="tc-notifications-empty-icon">
                <i class="bi bi-check-lg"></i>
            </div>
            <div class="tc-notifications-empty-title">
                <%: T("You're all caught up!","Anda sudah dikemas kini!") %>
            </div>
            <div class="tc-notifications-empty-sub">
                <%: T("There are no notifications yet.","Tiada pemberitahuan lagi.") %>
            </div>
            <div class="tc-notifications-empty-caption">
                <%: T("We'll notify you whenever there's something new.","Kami akan memberitahu anda apabila ada sesuatu yang baharu.") %>
            </div>
        </div>
    </asp:Panel>

    <%-- Toast --%>
    <asp:HiddenField ID="hidToast" runat="server" Value="" />
    <div class="tc-notifications-toast-wrap" id="tcNotificationsToastWrap"></div>

</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script>
        window.addEventListener('load', function () {
            var h = document.getElementById('<%=hidToast.ClientID%>');
            if (h && h.value) {
                var w = document.getElementById('tcNotificationsToastWrap'),
                    t = document.createElement('div');
                t.className = 'tc-notifications-toast';
                t.innerHTML = '<i class="bi bi-check-circle-fill"></i> ' + h.value;
                w.appendChild(t);
                h.value = '';
                setTimeout(function () { t.style.opacity = '0'; t.style.transition = 'opacity .3s'; }, 2000);
                setTimeout(function () { t.remove(); }, 2500);
            }
        });
    </script>
</asp:Content>
