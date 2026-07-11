<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EnrolledModules.aspx.cs"
    Inherits="ScienceBuddy.Parent.EnrolledModules" MasterPageFile="~/Site.Master"
    Title="Learning Journey" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Parent.css") %>?v=4" rel="stylesheet" />
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
        <a href="<%: ResolveUrl("~/Parent/EnrolledModules.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-journal-bookmark item-icon"></i><span class="item-label"><%: T("Learning Journey","Perjalanan Pembelajaran") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Child Performance","Prestasi Anak") %></div>
        <a href="<%: ResolveUrl("~/Parent/ChildProgress.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bar-chart-line item-icon"></i><span class="item-label"><%: T("Current Progress","Kemajuan Semasa") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/QuizResults.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-check item-icon"></i><span class="item-label"><%: T("Quiz Results","Keputusan Kuiz") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Study Plan","Pelan Pembelajaran") %></div>
        <a href="<%: ResolveUrl("~/Parent/StudyPlan.aspx") %>" class="sb-sidebar-item"><i class="bi bi-journal-check item-icon"></i><span class="item-label"><%: T("Study Plan","Pelan Pembelajaran") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/EditStudyPlan.aspx") %>" class="sb-sidebar-item"><i class="bi bi-pencil-square item-icon"></i><span class="item-label"><%: T("Edit Study Plan","Edit Pelan Pembelajaran") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Discussions","Perbincangan") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentTeacherCommunication.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Chat with Teachers","Sembang dengan Guru") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/Forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-people item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Profile","Profil") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("My Profile","Profil Saya") %></span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Logout","Log Keluar") %></span></a></div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Learning Journey","Perjalanan Pembelajaran") %></asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="pt-learning-page">

    <%-- No Child State --%>
    <asp:Panel ID="pnlNoChild" runat="server" Visible="false">
        <div class="pt-empty-notif"><i class="bi bi-person-x-fill"></i><p><%: T("No linked child found.","Tiada anak dipautkan.") %></p></div>
    </asp:Panel>

    <%-- ══ LEVELS VIEW ══ --%>
    <asp:Panel ID="pnlLevels" runat="server" Visible="false">
        <div class="pt-learning-hero">
            <div class="pt-learning-hero-icon"><i class="bi bi-rocket-takeoff-fill"></i></div>
            <h2><%: T("Learning Journey","Perjalanan Pembelajaran") %></h2>
            <p><%: T("Explore your child's science learning levels and track their progress.","Terokai tahap pembelajaran sains anak anda dan jejak kemajuan mereka.") %></p>
        </div>
        <div class="pt-levels-section">
            <h3 class="pt-levels-heading"><%: T("Levels","Tahap") %></h3>
            <asp:Panel ID="pnlLevelsGrid" runat="server" CssClass="pt-levels-grid"></asp:Panel>
        </div>
    </asp:Panel>

    <%-- ══ LEVEL DETAILS VIEW ══ --%>
    <asp:Panel ID="pnlLevelDetail" runat="server" Visible="false">
        <a href="<%: ResolveUrl("~/Parent/EnrolledModules.aspx") %>" class="pt-learning-back-button"><i class="bi bi-arrow-left"></i> <%: T("Back to Levels","Kembali ke Tahap") %></a>
        <asp:Panel ID="pnlLevelHero" runat="server" CssClass="pt-level-detail-hero"></asp:Panel>
        <div class="pt-level-info-grid">
            <div class="pt-level-info-card pt-level-info-card-blue">
                <div class="pt-level-info-icon"><i class="bi bi-journal-check"></i></div>
                <h4><%: T("How to complete this level","Cara melengkapkan tahap ini") %></h4>
                <p><%: T("Your child completes this level by learning each unit, finishing lessons and materials, and attempting the related quizzes.","Anak anda melengkapkan tahap ini dengan mempelajari setiap unit, menyelesaikan pelajaran dan bahan, serta mencuba kuiz berkaitan.") %></p>
            </div>
            <div class="pt-level-info-card pt-level-info-card-peach">
                <div class="pt-level-info-icon"><i class="bi bi-collection"></i></div>
                <h4><%: T("How many units are there?","Berapa banyak unit?") %></h4>
                <p><asp:Literal ID="litUnitCountInfo" runat="server" /></p>
            </div>
        </div>
        <div class="pt-units-section">
            <h3 class="pt-levels-heading"><%: T("Units","Unit") %></h3>
            <asp:Panel ID="pnlUnitsGrid" runat="server" CssClass="pt-units-grid"></asp:Panel>
            <asp:Panel ID="pnlNoUnits" runat="server" Visible="false"><div class="pt-no-data" style="text-align:center;padding:30px;"><%: T("No units available.","Tiada unit tersedia.") %></div></asp:Panel>
        </div>
    </asp:Panel>

    <%-- ══ UNIT DETAILS VIEW ══ --%>
    <asp:Panel ID="pnlUnitDetail" runat="server" Visible="false">
        <a href="" id="lnkBackToUnits" runat="server" class="pt-learning-back-button"><i class="bi bi-arrow-left"></i> <%: T("Back to Units","Kembali ke Unit") %></a>
        <asp:Panel ID="pnlUnitHero" runat="server" CssClass="pt-unit-title-hero"></asp:Panel>
        <div class="pt-unit-description-band">
            <div class="pt-unit-description-pill">
                <span class="pt-unit-desc-label"><i class="bi bi-info-circle-fill"></i> <%: T("What this unit is about","Tentang unit ini") %></span>
                <p><asp:Literal ID="litUnitDescription" runat="server" /></p>
            </div>
        </div>
        <div class="pt-subtopic-section">
            <h3 class="pt-levels-heading"><%: T("Subtopics","Subtopik") %></h3>
            <asp:Panel ID="pnlSubtopicsGrid" runat="server" CssClass="pt-subtopic-grid"></asp:Panel>
            <asp:Panel ID="pnlNoSubtopics" runat="server" Visible="false"><div class="pt-no-data" style="text-align:center;padding:30px;"><%: T("No subtopics available.","Tiada subtopik tersedia.") %></div></asp:Panel>
        </div>
    </asp:Panel>

</div>
</asp:Content>
