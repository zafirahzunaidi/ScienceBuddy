<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Forum.aspx.cs"
    Inherits="ScienceBuddy.Parent.Forum" MasterPageFile="~/Site.Master"
    Title="Forum" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Parent.css") %>" rel="stylesheet" />
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
        <a href="<%: ResolveUrl("~/Parent/QuizResults.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-check item-icon"></i><span class="item-label"><%: T("Quiz Results","Keputusan Kuiz") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Study Plan","Pelan Pembelajaran") %></div>
        <a href="<%: ResolveUrl("~/Parent/StudyPlan.aspx") %>" class="sb-sidebar-item"><i class="bi bi-journal-check item-icon"></i><span class="item-label"><%: T("Study Plan","Pelan Pembelajaran") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/EditStudyPlan.aspx") %>" class="sb-sidebar-item"><i class="bi bi-pencil-square item-icon"></i><span class="item-label"><%: T("Edit Study Plan","Edit Pelan Pembelajaran") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Discussions","Perbincangan") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentTeacherCommunication.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Chat with Teachers","Sembang dengan Guru") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/Forum.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-people item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Profile","Profil") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("My Profile","Profil Saya") %></span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Logout","Log Keluar") %></span></a></div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Forum","Forum") %></asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="pd-page">

    <%-- Hero --%>
    <div class="pt-forum-hero">
        <h2><i class="bi bi-chat-square-text-fill"></i> <%: T("Forum","Forum") %></h2>
        <p><%: T("See what people are talking about.","Lihat apa yang sedang dibincangkan di sini.") %></p>
    </div>

    <%-- Tabs + Create button in same row --%>
    <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:16px;flex-wrap:wrap;gap:10px;border:none;">
        <div class="pt-forum-tabs">
            <asp:LinkButton ID="lnkPublic" runat="server" CssClass="pt-forum-tab pt-forum-tab-active" OnClick="TabPublic_Click" CausesValidation="false"><%: T("Public","Awam") %></asp:LinkButton>
            <asp:LinkButton ID="lnkPrivate" runat="server" CssClass="pt-forum-tab" OnClick="TabPrivate_Click" CausesValidation="false"><%: T("Student-Parent","Murid-Ibu Bapa") %></asp:LinkButton>
        </div>
        <a href="<%: ResolveUrl("~/Parent/CreateDiscussion.aspx") + "?type=" + (ViewState["Tab"] != null && ViewState["Tab"].ToString() == "Private" ? "Private" : "Public") %>" class="pt-btn primary"><i class="bi bi-plus-circle"></i> <%: T("Create Discussion","Buat Perbincangan") %></a>
    </div>

    <%-- Filters --%>
    <div class="pt-forum-filter-row">
        <asp:DropDownList ID="ddlTag" runat="server" CssClass="pt-heatmap-month-select" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed" />
        <asp:DropDownList ID="ddlSort" runat="server" CssClass="pt-heatmap-month-select" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed" />
        <asp:Panel ID="pnlChildFilter" runat="server" Visible="false" style="display:inline-block;">
            <asp:DropDownList ID="ddlChildFilter" runat="server" CssClass="pt-heatmap-month-select" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed" />
        </asp:Panel>
        <asp:TextBox ID="txtSearch" runat="server" CssClass="pt-notif-search-input" placeholder="Search..." AutoPostBack="true" OnTextChanged="Filter_Changed" style="max-width:220px;" />
    </div>

    <%-- Thread list (Public tab) --%>
    <asp:Panel ID="pnlPublicList" runat="server"></asp:Panel>

    <%-- Child Activity (Student-Parent tab) --%>
    <asp:Panel ID="pnlPrivateList" runat="server" Visible="false">
        <div class="pt-quiz-section-title"><i class="bi bi-journal-text"></i> <%: T("Child Threads","Hantaran Anak") %></div>
        <asp:Panel ID="pnlChildThreads" runat="server"></asp:Panel>
    </asp:Panel>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="pt-empty-notif"><i class="bi bi-chat-square-dots"></i><p><asp:Literal ID="litEmpty" runat="server" /></p></div>
    </asp:Panel>

</div>
</asp:Content>
