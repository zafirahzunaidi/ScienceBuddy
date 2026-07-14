<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ParentDashboard.aspx.cs"
    Inherits="ScienceBuddy.Parent.ParentDashboard" MasterPageFile="~/Site.Master"
    Title="Parent Dashboard" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Parent.css") %>?v=5" rel="stylesheet" />
</asp:Content>

<%-- ════ SIDEBAR MENU ════ --%>
<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">

    <%-- Child Switcher Dropdown --%>
    <div class="pt-child-selector">
        <div class="pt-child-selector-label"><%: T("Viewing Child","Anak Dilihat") %></div>
        <div class="pt-child-selector-full">
            <asp:DropDownList ID="ddlSidebarChild" runat="server"
                AutoPostBack="true" OnSelectedIndexChanged="SidebarChildChanged"
                CssClass="sb-sidebar-child-ddl" />
        </div>
        <div class="pt-child-selector-compact">
            <button type="button" class="pt-child-compact-btn" onclick="toggleChildPopover(event);"></button>
            <div class="pt-child-popover" id="divChildPopover"></div>
        </div>
    </div>

    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentDashboard.aspx") %>" class="sb-sidebar-item active">
            <i class="bi bi-speedometer2 item-icon"></i>
            <span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/ParentNotifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label"><%: T("Notifications","Notifikasi") %></span><asp:Literal ID="litUnreadBadge" runat="server" /></a>
    </div>

    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("My Children","Anak Saya") %></div>
        <a href="<%: ResolveUrl("~/Parent/LinkChildAccount.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-link-45deg item-icon"></i>
            <span class="item-label"><%: T("Link Child Account","Paut Akaun Anak") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/ChildProfile.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-person-badge item-icon"></i>
            <span class="item-label"><%: T("Child Profile","Profil Anak") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/EnrolledModules.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-journal-bookmark item-icon"></i>
            <span class="item-label"><%: T("Learning Journey","Perjalanan Pembelajaran") %></span>
        </a>
    </div>

    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Child Performance","Prestasi Anak") %></div>
        <a href="<%: ResolveUrl("~/Parent/ChildProgress.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-bar-chart-line item-icon"></i>
            <span class="item-label"><%: T("Current Progress","Kemajuan Semasa") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/QuizResults.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-patch-check item-icon"></i>
            <span class="item-label"><%: T("Quiz Results","Keputusan Kuiz") %></span>
        </a>
    </div>

    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Study Plan","Pelan Pembelajaran") %></div>
        <a href="<%: ResolveUrl("~/Parent/StudyPlan.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-journal-check item-icon"></i>
            <span class="item-label"><%: T("Study Plan","Pelan Pembelajaran") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/EditStudyPlan.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-pencil-square item-icon"></i>
            <span class="item-label"><%: T("Edit Study Plan","Edit Pelan Pembelajaran") %></span>
        </a>
    </div>

    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Discussions","Perbincangan") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentTeacherCommunication.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-chat-dots item-icon"></i>
            <span class="item-label"><%: T("Chat with Teachers","Sembang dengan Guru") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/Forum.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-people item-icon"></i>
            <span class="item-label"><%: T("Forum","Forum") %></span>
        </a>
    </div>

    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Profile","Profil") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentProfile.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-person item-icon"></i>
            <span class="item-label"><%: T("Edit Profile","Edit Profil") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-box-arrow-right item-icon"></i>
            <span class="item-label"><%: T("Logout","Log Keluar") %></span>
        </a>
    </div>

    <script type="text/javascript">
    function toggleChildPopover(e){e.stopPropagation();var pop=document.getElementById('divChildPopover');if(!pop)return;if(pop.classList.contains('pt-popover-open')){pop.classList.remove('pt-popover-open');return;}var ddl=document.querySelector('.sb-sidebar-child-ddl');if(!ddl)return;var html='<div class="pt-child-popover-title"><%: T("Select Child","Pilih Anak") %></div>';for(var i=0;i<ddl.options.length;i++){var o=ddl.options[i];var init=o.text.charAt(0).toUpperCase();var ac=o.selected?' pt-popover-active':'';html+='<div class="pt-child-popover-item'+ac+'" onclick="selectChildFromPopover(\''+o.value+'\')"><span class="pt-popover-avatar">'+init+'</span>'+o.text+'</div>';}pop.innerHTML=html;pop.classList.add('pt-popover-open');}
    function selectChildFromPopover(v){var ddl=document.querySelector('.sb-sidebar-child-ddl');if(ddl&&ddl.value!==v){ddl.value=v;__doPostBack(ddl.id.replace(/_/g,'$'),'');}var pop=document.getElementById('divChildPopover');if(pop)pop.classList.remove('pt-popover-open');}
    document.addEventListener('DOMContentLoaded',function(){var ddl=document.querySelector('.sb-sidebar-child-ddl');var btn=document.querySelector('.pt-child-compact-btn');if(ddl&&btn&&ddl.options.length>0){btn.textContent=ddl.options[ddl.selectedIndex].text.charAt(0).toUpperCase();}});
    document.addEventListener('click',function(e){var pop=document.getElementById('divChildPopover');if(pop&&!e.target.closest('.pt-child-selector-compact')){pop.classList.remove('pt-popover-open');}});
    </script>

</asp:Content>

<%-- ════ PAGE TITLE ════ --%>
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Parent Dashboard","Papan Pemuka Ibu Bapa") %></asp:Content>

<%-- ════ MAIN CONTENT ════ --%>
<asp:Content ID="cBody" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="pd-page">

    <asp:Panel ID="pnlMessage" runat="server" Visible="false">
        <div class="pd-msg pt-confetti-wrap" id="divMessage" runat="server">
            <span class="pt-confetti-bit" style="left:5%;color:#6366F1;">●</span>
            <span class="pt-confetti-bit" style="left:18%;color:#EC4899;">★</span>
            <span class="pt-confetti-bit" style="left:32%;color:#F59E0B;">●</span>
            <span class="pt-confetti-bit" style="left:48%;color:#14B8A6;">✦</span>
            <span class="pt-confetti-bit" style="left:62%;color:#8B5CF6;">●</span>
            <span class="pt-confetti-bit" style="left:78%;color:#6366F1;">★</span>
            <span class="pt-confetti-bit" style="left:90%;color:#EC4899;">●</span>
        </div>
    </asp:Panel>

    <%-- ── Redesigned Hero Card ── --%>
    <div class="pd-hero">
        <%-- decorative sparkles (CSS only) --%>
        <div class="pd-hero-spark1"></div>
        <div class="pd-hero-spark2"></div>
        <div class="pd-hero-spark3"></div>
        <div class="pd-hero-spark4"></div>
        <%-- twinkling stars --%>
        <i class="bi bi-star-fill pt-twinkle-star" style="top:15%;left:12%;"></i>
        <i class="bi bi-stars pt-twinkle-star" style="top:60%;right:10%;"></i>
        <i class="bi bi-star-fill pt-twinkle-star" style="bottom:18%;left:35%;"></i>
        <i class="bi bi-star pt-twinkle-star" style="top:25%;right:25%;"></i>
        <i class="bi bi-stars pt-twinkle-star" style="bottom:30%;right:40%;"></i>

        <%-- eyebrow --%>
        <div class="pd-hero-eyebrow">
            <i class="bi bi-stars"></i>
            <asp:Literal ID="litHeroEyebrow" runat="server" />
        </div>

        <%-- main greeting --%>
        <div class="pd-hero-greeting">
            <asp:Literal ID="litHeroGreeting" runat="server" />
        </div>

        <%-- currently viewing subtitle (hidden when no child) --%>
        <asp:Panel ID="pnlHeroViewing" runat="server" Visible="false">
            <div class="pd-hero-viewing">
                <i class="bi bi-eye-fill"></i>
                <asp:Literal ID="litHeroViewing" runat="server" />
            </div>
            <%-- learning pills + link button in one row --%>
            <div class="pd-hero-action-row">
                <span class="pd-hero-pill">
                    <i class="bi bi-mortarboard-fill"></i>
                    <asp:Literal ID="litHeroLevel" runat="server" />
                </span>
                <span class="pd-hero-pill xp">
                    <i class="bi bi-lightning-charge-fill"></i>
                    <asp:Literal ID="litHeroXP" runat="server" />
                </span>
                <asp:Panel ID="pnlHeroBadges" runat="server" Visible="false">
                    <span class="pd-hero-pill badge">
                        <i class="bi bi-award-fill"></i>
                        <asp:Literal ID="litHeroBadges" runat="server" />
                    </span>
                </asp:Panel>
                <a href="<%: ResolveUrl("~/Parent/LinkChildAccount.aspx") %>" class="pd-hero-link-btn" style="margin-left:auto;">
                    <i class="bi bi-plus-circle-fill"></i>
                    <asp:Literal ID="litHeroLinkChild" runat="server" />
                </a>
            </div>
        </asp:Panel>

        <%-- no child state inside hero --%>
        <asp:Panel ID="pnlHeroNoChild" runat="server" Visible="false">
            <div class="pd-hero-nochild">
                <i class="bi bi-person-x-fill"></i>
                <asp:Literal ID="litHeroNoChild" runat="server" />
            </div>
            <%-- link button shown when no child linked --%>
            <a href="<%: ResolveUrl("~/Parent/LinkChildAccount.aspx") %>" class="pd-hero-link-btn" style="margin-top:10px;display:inline-flex;">
                <i class="bi bi-plus-circle-fill"></i>
                <asp:Literal ID="litHeroLinkChildNoChild" runat="server" />
            </a>
        </asp:Panel>
    </div>

    <asp:Panel ID="pnlNoChild" runat="server" Visible="false">
        <div class="pd-section-card">
            <div class="pd-empty">
                <i class="bi bi-people"></i>
                <p><asp:Literal ID="litNoChildMsg" runat="server" /></p>
                <br />
                <a href="LinkChildAccount.aspx"><asp:Literal ID="litLinkChildBtn" runat="server" /></a>
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlDashboard" runat="server" Visible="false">

        <%-- ── Selected Child Card ── --%>
        <div class="pt-child-mini-card">
            <div class="pt-child-mini-avatar"><asp:Literal ID="litSnapInitials" runat="server" /></div>
            <div class="pt-child-mini-content">
                <div class="pt-child-mini-name"><asp:Literal ID="litSnapName" runat="server" /></div>
                <div class="pt-child-mini-relationship"><asp:Literal ID="litSnapRel" runat="server" /></div>
            </div>
            <div class="pt-child-mini-actions">
                <a href="<%: ResolveUrl("~/Parent/ChildProfile.aspx") %>" class="pt-child-mini-button"><i class="bi bi-person-badge"></i> <asp:Literal ID="litSnapBtnProfile" runat="server" /></a>
                <a href="<%: ResolveUrl("~/Parent/ChildProgress.aspx") %>" class="pt-child-mini-button"><i class="bi bi-bar-chart-line"></i> <asp:Literal ID="litSnapBtnProgress" runat="server" /></a>
            </div>
        </div>

        <%-- ── Summary Cards (3 pastel cards) ── --%>
        <div class="pd-summary-grid pt-stagger-in">
            <div class="pd-summary-card progress-card">
                <div class="pd-summary-icon"><i class="bi bi-bar-chart-fill"></i></div>
                <span class="pd-summary-value"><asp:Literal ID="litProgressValue" runat="server" /></span>
                <span class="pd-summary-label"><asp:Literal ID="litProgressLabel" runat="server" /></span>
            </div>
            <div class="pd-summary-card quiz-card">
                <div class="pd-summary-icon"><i class="bi bi-pencil-square"></i></div>
                <span class="pd-summary-value"><asp:Literal ID="litQuizScoreValue" runat="server" /></span>
                <span class="pd-summary-label"><asp:Literal ID="litQuizScoreLabel" runat="server" /></span>
            </div>
            <div class="pd-summary-card badge-card">
                <div class="pd-summary-icon"><i class="bi bi-award-fill"></i></div>
                <span class="pd-summary-value"><asp:Literal ID="litBadgeValue" runat="server" /></span>
                <span class="pd-summary-label"><asp:Literal ID="litBadgeLabel" runat="server" /></span>
            </div>
        </div>

        <%-- ── Two-column: Study Plan + Recent Activities ── --%>
        <div class="pd-two-col">

            <%-- LEFT: Study Plan --%>
            <div class="pd-lower-card">
                <div class="pd-lower-card-header">
                    <div class="pd-lower-card-title">
                        <i class="bi bi-journal-check"></i>
                        <asp:Literal ID="litStudyPlanTitle" runat="server" />
                    </div>
                    <a href="<%: ResolveUrl("~/Parent/EditStudyPlan.aspx") %>" class="pt-btn-icon" title="<%: T("Edit Plan","Edit Pelan") %>" style="width:30px;height:30px;border-radius:8px;background:#EEF2FF;color:#6366F1;border:none;display:flex;align-items:center;justify-content:center;"><i class="bi bi-pencil-square"></i></a>
                </div>
                <div class="pd-lower-card-body">
                    <asp:Panel ID="pnlStudyPlanCard" runat="server" Visible="false">
                        <asp:Panel ID="pnlSPTaskList" runat="server"></asp:Panel>
                    </asp:Panel>
                    <asp:Panel ID="pnlNoStudyPlan" runat="server" Visible="false">
                        <div class="pd-empty">
                            <i class="bi bi-journal-x"></i>
                            <p><asp:Literal ID="litNoStudyPlanMsg" runat="server" /></p>
                        </div>
                    </asp:Panel>
                </div>
            </div>

            <%-- RIGHT: Recent Activities --%>
            <div class="pd-lower-card">
                <div class="pd-lower-card-header">
                    <div class="pd-lower-card-title">
                        <i class="bi bi-clock-history"></i>
                        <asp:Literal ID="litRecentActivitiesTitle" runat="server" />
                    </div>
                </div>
                <div class="pd-lower-card-body">
                    <asp:Panel ID="pnlRecentActivities" runat="server"></asp:Panel>
                    <asp:Panel ID="pnlNoActivities" runat="server" Visible="false">
                        <div class="pd-empty">
                            <i class="bi bi-hourglass-split"></i>
                            <p><asp:Literal ID="litNoActivitiesMsg" runat="server" /></p>
                        </div>
                    </asp:Panel>
                </div>
            </div>

        </div>

        <%-- ── Forum Preview Section ── --%>
        <div class="pd-forum-section">
            <div class="pd-forum-header">
                <div class="pd-section-title-row">
                    <i class="bi bi-chat-square-text-fill"></i>
                    <span><asp:Literal ID="litForumTitle" runat="server" /></span>
                </div>
                <div class="pd-forum-sub"><asp:Literal ID="litForumSub" runat="server" /></div>
            </div>

            <%-- Tabs --%>
            <div class="pd-forum-tabs">
                <asp:LinkButton ID="lnkTabPublic" runat="server" CssClass="pd-forum-tab active"
                    OnClick="ForumTabPublic_Click" CausesValidation="false">
                    <i class="bi bi-globe2"></i> <asp:Literal ID="litTabPublic" runat="server" />
                </asp:LinkButton>
                <asp:LinkButton ID="lnkTabPrivate" runat="server" CssClass="pd-forum-tab"
                    OnClick="ForumTabPrivate_Click" CausesValidation="false">
                    <i class="bi bi-people-fill"></i> <asp:Literal ID="litTabPrivate" runat="server" />
                </asp:LinkButton>
            </div>

            <%-- Filters row --%>
            <div class="pd-forum-filters">
                <asp:DropDownList ID="ddlForumTag" runat="server" CssClass="pd-forum-filter-ddl"
                    AutoPostBack="true" OnSelectedIndexChanged="ForumFilter_Changed" />
                <asp:DropDownList ID="ddlForumSort" runat="server" CssClass="pd-forum-filter-ddl"
                    AutoPostBack="true" OnSelectedIndexChanged="ForumFilter_Changed" />
                <asp:TextBox ID="txtForumSearch" runat="server" CssClass="pd-forum-filter-search"
                    placeholder="Search" AutoPostBack="true" OnTextChanged="ForumFilter_Changed" />
            </div>

            <%-- Scrollable post list --%>
            <div class="pd-forum-list">
                <asp:Panel ID="pnlForumPosts" runat="server"></asp:Panel>
                <asp:Panel ID="pnlNoForumPosts" runat="server" Visible="false">
                    <div class="pd-empty">
                        <i class="bi bi-chat-square-dots"></i>
                        <p><asp:Literal ID="litNoForumMsg" runat="server" /></p>
                    </div>
                </asp:Panel>
            </div>

            <%-- Go to Forum button --%>
            <div class="pd-forum-footer">
                <a href="<%: ResolveUrl("~/Parent/Forum.aspx") %>" class="pd-forum-goto-btn">
                    <i class="bi bi-arrow-right-circle"></i>
                    <asp:Literal ID="litGoToForum" runat="server" />
                </a>
            </div>
        </div>

    </asp:Panel>

</div>
</asp:Content>
