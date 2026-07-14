<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ChildProfile.aspx.cs"
    Inherits="ScienceBuddy.Parent.ChildProfile" MasterPageFile="~/Site.Master"
    Title="Child Profile" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Parent.css") %>?v=5" rel="stylesheet" />
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

    <%-- Hero --%>
    <div class="pt-page-hero">
        <div class="pt-page-hero-content">
            <h1 class="pt-page-hero-title"><i class="bi bi-person-badge-fill"></i> <%: T("Child Profile","Profil Anak") %></h1>
            <p class="pt-page-hero-subtitle"><%: T("View your child's account details and learning information.","Lihat maklumat akaun dan pembelajaran anak anda.") %></p>
        </div>
    </div>

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

        <%-- Personality + Level Cards --%>
        <div class="pt-child-profile-grid">
            <%-- LEFT: Personality Card --%>
            <div class="pt-personality-card">
                <asp:Panel ID="pnlPersonality" runat="server">
                    <div class="pt-personality-avatar-wrap">
                        <asp:Image ID="imgPersonality" runat="server" CssClass="pt-personality-avatar" />
                    </div>
                    <div class="pt-personality-content">
                        <h3 class="pt-personality-title"><asp:Literal ID="litPersonalityTitle" runat="server" /></h3>
                        <p class="pt-personality-description"><asp:Literal ID="litPersonalityDesc" runat="server" /></p>
                        <div class="pt-child-info-list">
                            <div class="pt-child-info-row"><span class="pt-child-info-label"><%: T("Full Name","Nama Penuh") %></span><span class="pt-child-info-value"><asp:Literal ID="litInfoFullName" runat="server" /></span></div>
                            <div class="pt-child-info-row"><span class="pt-child-info-label"><%: T("Nickname","Nama Panggilan") %></span><span class="pt-child-info-value"><asp:Literal ID="litInfoNickname" runat="server" /></span></div>
                            <div class="pt-child-info-row"><span class="pt-child-info-label"><%: T("Relationship","Hubungan") %></span><span class="pt-child-info-value"><asp:Literal ID="litInfoRelationship" runat="server" /></span></div>
                            <div class="pt-child-info-row"><span class="pt-child-info-label"><%: T("Learning Style","Gaya Pembelajaran") %></span><span class="pt-child-info-value"><asp:Literal ID="litInfoLearningStyle" runat="server" /></span></div>
                        </div>
                    </div>
                </asp:Panel>
                <asp:Panel ID="pnlNoPersonality" runat="server" Visible="false">
                    <div class="cp-no-data"><%: T("No personality information available.","Tiada maklumat personaliti tersedia.") %></div>
                </asp:Panel>
            </div>
            <%-- RIGHT: Level Card --%>
            <div class="pt-level-card-profile">
                <asp:Panel ID="pnlLevelInfo" runat="server">
                    <h3 class="pt-level-card-title"><%: T("Their Level","Tahap Mereka") %></h3>
                    <div class="pt-level-card-name"><asp:Literal ID="litLevelName" runat="server" /></div>
                    <p class="pt-level-card-desc"><asp:Literal ID="litLevelDesc" runat="server" /></p>
                    <div class="pt-level-card-enrolled"><i class="bi bi-calendar-check"></i> <asp:Literal ID="litEnrolledSince" runat="server" /></div>
                </asp:Panel>
                <asp:Panel ID="pnlNoLevel" runat="server" Visible="false">
                    <div class="cp-no-data"><%: T("No level information available.","Tiada maklumat tahap tersedia.") %></div>
                </asp:Panel>
            </div>
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
