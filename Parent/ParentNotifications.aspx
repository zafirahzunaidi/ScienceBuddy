<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ParentNotifications.aspx.cs"
    Inherits="ScienceBuddy.Parent.ParentNotifications" MasterPageFile="~/Site.Master"
    Title="Notifications" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Parent.css") %>?v=6" rel="stylesheet" />
<script type="text/javascript">
function toggleChildPopover(e){e.stopPropagation();var pop=document.getElementById('divChildPopover');if(!pop)return;if(pop.classList.contains('pt-popover-open')){pop.classList.remove('pt-popover-open');return;}var ddl=document.querySelector('.sb-sidebar-child-ddl');if(!ddl)return;var html='<div class="pt-child-popover-title">Select Child</div>';for(var i=0;i<ddl.options.length;i++){var o=ddl.options[i];var init=o.text.charAt(0).toUpperCase();var ac=o.selected?' pt-popover-active':'';html+='<div class="pt-child-popover-item'+ac+'" onclick="selectChildFromPopover(\''+o.value+'\')"><span class="pt-popover-avatar">'+init+'</span>'+o.text+'</div>';}pop.innerHTML=html;pop.classList.add('pt-popover-open');}
function selectChildFromPopover(v){var ddl=document.querySelector('.sb-sidebar-child-ddl');if(ddl&&ddl.value!==v){ddl.value=v;__doPostBack(ddl.id.replace(/_/g,'$'),'');}var pop=document.getElementById('divChildPopover');if(pop)pop.classList.remove('pt-popover-open');}
document.addEventListener('DOMContentLoaded',function(){var ddl=document.querySelector('.sb-sidebar-child-ddl');var btn=document.querySelector('.pt-child-compact-btn');if(ddl&&btn&&ddl.options.length>0){btn.textContent=ddl.options[ddl.selectedIndex].text.charAt(0).toUpperCase();}});
document.addEventListener('click',function(e){var pop=document.getElementById('divChildPopover');if(pop&&!e.target.closest('.pt-child-selector-compact')){pop.classList.remove('pt-popover-open');}});
</script>
</asp:Content>

<%-- ════ SIDEBAR ════ --%>
<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="pt-child-selector">
        <div class="pt-child-selector-label"><%: T("Viewing Child","Anak Dilihat") %></div>
        <div class="pt-child-selector-full"><asp:DropDownList ID="ddlSidebarChild" runat="server" AutoPostBack="true" OnSelectedIndexChanged="SidebarChildChanged" CssClass="sb-sidebar-child-ddl" /></div>
        <div class="pt-child-selector-compact"><button type="button" class="pt-child-compact-btn" onclick="toggleChildPopover(event);"></button><div class="pt-child-popover" id="divChildPopover"></div></div>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentDashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/ParentNotifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label"><%: T("Notifications","Notifikasi") %></span><asp:Literal ID="litUnreadBadge" runat="server" /></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("My Children","Anak Saya") %></div>
        <a href="<%: ResolveUrl("~/Parent/LinkChildAccount.aspx") %>" class="sb-sidebar-item"><i class="bi bi-link-45deg item-icon"></i><span class="item-label"><%: T("Link Child Account","Paut Akaun Anak") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/ChildProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-badge item-icon"></i><span class="item-label"><%: T("Child Profile","Profil Anak") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/EnrolledModules.aspx") %>" class="sb-sidebar-item"><i class="bi bi-journal-bookmark item-icon"></i><span class="item-label"><%: T("Learning Journey","Perjalanan Pembelajaran") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Child Performance","Prestasi Anak") %></div>
        <a href="<%: ResolveUrl("~/Parent/ChildProgress.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bar-chart-line item-icon"></i><span class="item-label"><%: T("Current Progress","Kemajuan Semasa") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/QuizResults.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-check item-icon"></i><span class="item-label"><%: T("Quiz Results","Keputusan Kuiz") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/ParentAICoach.aspx") %>" class="sb-sidebar-item"><i class="bi bi-robot item-icon"></i><span class="item-label"><%: T("AI Parent Coach","Jurulatih AI") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Study Plan","Pelan Pembelajaran") %></div>
        <a href="<%: ResolveUrl("~/Parent/StudyPlan.aspx") %>" class="sb-sidebar-item"><i class="bi bi-journal-check item-icon"></i><span class="item-label"><%: T("Study Plan","Pelan Pembelajaran") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/EditStudyPlan.aspx") %>" class="sb-sidebar-item"><i class="bi bi-pencil-square item-icon"></i><span class="item-label"><%: T("Edit Study Plan","Edit Pelan Pembelajaran") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Discussions","Perbincangan") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentTeacherCommunication.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Chat with Teachers","Sembang dengan Guru") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/Forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-people item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Profile","Profil") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("Edit Profile","Edit Profil") %></span></a>        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Logout","Log Keluar") %></span></a></div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Notifications","Notifikasi") %></asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="pd-page">

    <%-- No Child --%>
    <asp:Panel ID="pnlNoChild" runat="server" Visible="false">
        <div class="pd-empty"><i class="bi bi-person-x-fill"></i><p><asp:Literal ID="litNoChildMsg" runat="server" /></p></div>
    </asp:Panel>

    <asp:Panel ID="pnlContent" runat="server" Visible="false">

        <%-- ══ PAGE HEADING ══ --%>
        <div class="pt-hero">
            <i class="bi bi-star-fill pt-sparkle" style="top:15%;left:10%;"></i>
            <i class="bi bi-stars pt-sparkle" style="top:55%;right:8%;animation-delay:1s;"></i>
            <h2 class="pt-hero-title"><i class="bi bi-bell-fill"></i> <%: T("Notifications","Notifikasi") %></h2>
            <p class="pt-hero-sub"><%: T("Stay updated on your child's learning journey.","Kekal dikemas kini tentang perjalanan pembelajaran anak anda.") %></p>
        </div>

        <%-- ══ SINCE YOUR LAST VISIT ══ --%>
        <div class="pt-since-visit-card">
            <div class="pt-since-visit-title"><i class="bi bi-stars"></i> <%: T("Since Your Last Visit","Sejak Lawatan Terakhir Anda") %></div>
            <asp:Panel ID="pnlSinceVisit" runat="server"></asp:Panel>
            <asp:Panel ID="pnlAllCaughtUp" runat="server" Visible="false">
                <div class="pt-caught-up"><i class="bi bi-check-circle-fill"></i> <%: T("You're all caught up!","Anda sudah kemas kini!") %></div>
            </asp:Panel>
        </div>

        <%-- ══ FILTERS ══ --%>
        <div class="pt-notif-toolbar">
            <div class="pt-notif-search-wrap">
                <i class="bi bi-search"></i>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="pt-notif-search-input" placeholder="Search notifications..." AutoPostBack="true" OnTextChanged="Filter_Changed" />
            </div>
            <div class="pt-notif-filter-group">
                <asp:LinkButton ID="lnkAll" runat="server" CssClass="pt-notif-chip active" OnClick="Filter_Changed" CommandArgument="All" CausesValidation="false"><%: T("All","Semua") %></asp:LinkButton>
                <asp:LinkButton ID="lnkUnread" runat="server" CssClass="pt-notif-chip" OnClick="Filter_Changed" CommandArgument="Unread" CausesValidation="false"><%: T("Unread","Belum Dibaca") %></asp:LinkButton>
                <asp:LinkButton ID="lnkRead" runat="server" CssClass="pt-notif-chip" OnClick="Filter_Changed" CommandArgument="Read" CausesValidation="false"><%: T("Read","Dibaca") %></asp:LinkButton>
            </div>
            <asp:LinkButton ID="lnkMarkAllRead" runat="server" CssClass="pt-notif-mark-all-btn" OnClick="LnkMarkAllRead_Click" CausesValidation="false">
                <i class="bi bi-check2-all"></i> <%: T("Mark All Read","Tandai Semua Dibaca") %>
            </asp:LinkButton>
        </div>

        <%-- Sort --%>
        <div class="pt-notif-sort-row">
            <asp:LinkButton ID="lnkSortLatest" runat="server" CssClass="pt-sort-btn active" OnClick="LnkSortLatest_Click" CausesValidation="false">
                <i class="bi bi-sort-down"></i> <%: T("Latest","Terkini") %>
            </asp:LinkButton>
            <asp:LinkButton ID="lnkSortOldest" runat="server" CssClass="pt-sort-btn" OnClick="LnkSortOldest_Click" CausesValidation="false">
                <i class="bi bi-sort-up"></i> <%: T("Oldest","Terlama") %>
            </asp:LinkButton>
        </div>

        <%-- ══ NOTIFICATION FEED ══ --%>
        <asp:Panel ID="pnlFeed" runat="server"></asp:Panel>
        <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
            <div class="pt-empty-notif"><i class="bi bi-bell-slash"></i><p><asp:Literal ID="litEmptyMsg" runat="server" /></p></div>
        </asp:Panel>

        <%-- Hidden for mark-read single --%>
        <asp:HiddenField ID="hidMarkReadId" runat="server" />
        <asp:Button ID="btnMarkRead" runat="server" CssClass="d-none" OnClick="BtnMarkRead_Click" CausesValidation="false" />

    </asp:Panel>
</div>
</asp:Content>
