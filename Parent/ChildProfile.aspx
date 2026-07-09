<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ChildProfile.aspx.cs"
    Inherits="ScienceBuddy.Parent.ChildProfile" MasterPageFile="~/Site.Master"
    Title="Child Profile" MaintainScrollPositionOnPostback="true" %>

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
    <%-- Child Switcher --%>
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
        <a href="<%: ResolveUrl("~/Parent/ChildProfile.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-person-badge item-icon"></i><span class="item-label"><%: T("Child Profile","Profil Anak") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/EnrolledModules.aspx") %>" class="sb-sidebar-item"><i class="bi bi-journal-bookmark item-icon"></i><span class="item-label"><%: T("Learning Journey","Perjalanan Pembelajaran") %></span></a></div>
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
        <a href="<%: ResolveUrl("~/Parent/ParentProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("Edit Profile","Edit Profil") %></span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Logout","Log Keluar") %></span></a></div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Child Profile","Profil Anak") %></asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="cp-page">

    <%-- No child --%>
    <asp:Panel ID="pnlNoChild" runat="server" Visible="false">
        <div class="cp-card"><div class="cp-empty">
            <i class="bi bi-person-x-fill"></i>
            <p><asp:Literal ID="litNoChildMsg" runat="server" /></p><br />
            <a href="<%: ResolveUrl("~/Parent/LinkChildAccount.aspx") %>"><asp:Literal ID="litNoChildLink" runat="server" /></a>
        </div></div>
    </asp:Panel>

    <asp:Panel ID="pnlProfile" runat="server" Visible="false">

        <%-- Identity Card --%>
        <div class="cp-card">
            <div class="cp-identity">
                <div class="cp-avatar"><asp:Literal ID="litInitials" runat="server" /></div>
                <div class="cp-id-info">
                    <h2 class="cp-id-name"><asp:Literal ID="litName" runat="server" /></h2>
                    <div class="cp-id-meta"><asp:Literal ID="litNickname" runat="server" /></div>
                    <div class="cp-id-pills">
                        <span class="cp-id-pill level"><i class="bi bi-mortarboard-fill"></i> <asp:Literal ID="litLevel" runat="server" /></span>
                        <span class="cp-id-pill rel"><i class="bi bi-heart-fill"></i> <asp:Literal ID="litRelationship" runat="server" /></span>
                    </div>
                </div>
            </div>
        </div>

        <%-- Learning Path --%>
        <div class="cp-card">
            <div class="cp-sec-title"><i class="bi bi-map-fill"></i> <asp:Literal ID="litPathTitle" runat="server" /></div>
            <asp:Panel ID="pnlUnits" runat="server"></asp:Panel>
            <asp:Panel ID="pnlNoUnits" runat="server" Visible="false">
                <div class="cp-no-data"><asp:Literal ID="litNoUnits" runat="server" /></div>
            </asp:Panel>
        </div>

        <%-- Recent Learning Summary --%>
        <div class="cp-card">
            <div class="cp-sec-title"><i class="bi bi-clock-history"></i> <asp:Literal ID="litRecentTitle" runat="server" /></div>
            <asp:Panel ID="pnlRecent" runat="server"></asp:Panel>
            <asp:Panel ID="pnlNoRecent" runat="server" Visible="false">
                <div class="cp-no-data"><asp:Literal ID="litNoRecent" runat="server" /></div>
            </asp:Panel>
        </div>

        <%-- Achievement Snapshot --%>
        <div class="cp-card">
            <div class="cp-sec-title"><i class="bi bi-trophy-fill"></i> <asp:Literal ID="litAchieveTitle" runat="server" /></div>
            <div class="cp-achieve-row">
                <div class="cp-achieve-item">
                    <span class="cp-achieve-value"><asp:Literal ID="litXP" runat="server" /></span>
                    <span class="cp-achieve-label"><asp:Literal ID="litXPLabel" runat="server" /></span>
                </div>
                <div class="cp-achieve-item">
                    <span class="cp-achieve-value"><asp:Literal ID="litBadgeCount" runat="server" /></span>
                    <span class="cp-achieve-label"><asp:Literal ID="litBadgeCountLabel" runat="server" /></span>
                </div>
            </div>
            <asp:Panel ID="pnlLatestBadge" runat="server" Visible="false">
                <div class="cp-achieve-badge"><i class="bi bi-award-fill"></i> <asp:Literal ID="litLatestBadge" runat="server" /></div>
            </asp:Panel>
        </div>

        <%-- Badge Collection --%>
        <div class="cp-card">
            <div class="cp-sec-title"><i class="bi bi-award"></i> <%: T("Badge Collection","Koleksi Lencana") %></div>
            <asp:Panel ID="pnlBadgeGrid" runat="server"></asp:Panel>
            <asp:Panel ID="pnlNoBadges" runat="server" Visible="false">
                <div class="cp-no-data"><%: T("No badges available yet.","Belum ada lencana tersedia.") %></div>
            </asp:Panel>
        </div>

    </asp:Panel>

</div>
</asp:Content>
