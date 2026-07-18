<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StudyPlan.aspx.cs"
    Inherits="ScienceBuddy.Parent.StudyPlan" MasterPageFile="~/Site.Master"
    Title="Study Plan" MaintainScrollPositionOnPostback="true" %>

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
        <a href="<%: ResolveUrl("~/Parent/StudyPlan.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-journal-check item-icon"></i><span class="item-label"><%: T("Study Plan","Pelan Pembelajaran") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/EditStudyPlan.aspx") %>" class="sb-sidebar-item"><i class="bi bi-pencil-square item-icon"></i><span class="item-label"><%: T("Edit Study Plan","Edit Pelan Pembelajaran") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Discussions","Perbincangan") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentTeacherCommunication.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Chat with Teachers","Sembang dengan Guru") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/Forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-people item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Profile","Profil") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("Edit Profile","Edit Profil") %></span></a>        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Logout","Log Keluar") %></span></a></div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Study Plan","Pelan Pembelajaran") %></asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="pd-page">

    <%-- No Child --%>
    <asp:Panel ID="pnlNoChild" runat="server" Visible="false">
        <div class="pd-empty"><i class="bi bi-person-x-fill"></i><p><asp:Literal ID="litNoChildMsg" runat="server" /></p></div>
    </asp:Panel>

    <%-- No Plan --%>
    <asp:Panel ID="pnlNoPlan" runat="server" Visible="false">
        <div class="pd-empty"><i class="bi bi-journal-x"></i>
            <p><asp:Literal ID="litNoPlanMsg" runat="server" /></p>
            <asp:Button ID="btnCreatePlan" runat="server" CssClass="pt-btn primary" style="margin-top:14px;"
                OnClick="BtnCreatePlan_Click" CausesValidation="false" />
        </div>
    </asp:Panel>

    <%-- Main Content --%>
    <asp:Panel ID="pnlContent" runat="server" Visible="false">

        <%-- ══ HEADER ══ --%>
        <div class="pt-hero">
            <i class="bi bi-star-fill pt-sparkle" style="top:14%;left:9%;"></i>
            <i class="bi bi-stars pt-sparkle" style="top:52%;right:7%;animation-delay:0.8s;"></i>
            <h2 class="pt-hero-title"><i class="bi bi-rocket-takeoff-fill"></i> <asp:Literal ID="litPlanTitle" runat="server" /></h2>
            <p class="pt-hero-sub"><asp:Literal ID="litPlanSub" runat="server" /></p>
            <div class="pt-hero-actions">
                <a href="<%: ResolveUrl("~/Parent/EditStudyPlan.aspx") %>" class="pt-hero-btn">
                    <i class="bi bi-pencil-square"></i> <%: T("Edit Plan","Edit Pelan") %>
                </a>
            </div>
        </div>

        <%-- ══ INFO CHIPS (replaces summary table) ══ --%>
        <div class="pt-sp-info-chips">
            <div class="pt-sp-chip blue">
                <i class="bi bi-check2-all"></i>
                <asp:Literal ID="litCompletedCount" runat="server" />
            </div>
            <asp:Panel ID="pnlRemainingDays" runat="server" Visible="false">
                <div class="pt-sp-chip blue">
                    <i class="bi bi-calendar-event"></i>
                    <asp:Literal ID="litRemainingDays" runat="server" />
                </div>
            </asp:Panel>
            <div class="pt-sp-chip yellow">
                <i class="bi bi-gift-fill"></i>
                <asp:Literal ID="litNextReward" runat="server" />
            </div>
            <div class="pt-sp-chip yellow">
                <i class="bi bi-star-fill"></i>
                <asp:Literal ID="litFinalReward" runat="server" />
            </div>
        </div>

        <%-- Days Left Banner (only shows ≤3 days or overdue) --%>
        <asp:Panel ID="pnlDaysLeftBanner" runat="server" Visible="false">
            <div class="pt-days-left-banner">
                <i class="bi bi-hourglass-split"></i>
                <asp:Literal ID="litDaysLeftBanner" runat="server" />
            </div>
        </asp:Panel>

        <%-- ══ TASK LIST (moved above progress) ══ --%>
        <div class="pt-quiz-section-title"><i class="bi bi-list-check"></i> <%: T("Tasks","Tugasan") %></div>
        <asp:Panel ID="pnlTasks" runat="server"></asp:Panel>
        <asp:Panel ID="pnlNoTasks" runat="server" Visible="false">
            <div class="pt-no-data"><%: T("No tasks in this study plan yet.","Belum ada tugasan dalam pelan belajar ini.") %></div>
        </asp:Panel>

        <%-- ══ MISSION PROGRESS ══ --%>
        <div class="pt-quiz-section-title" style="margin-top:24px;"><i class="bi bi-trophy-fill"></i> <%: T("Mission Progress","Kemajuan Misi") %></div>
        <div class="pt-sp-progress-summary">
            <asp:Literal ID="litProgressSummary" runat="server" />
        </div>
        <div class="pt-mission-progress-card">
            <div class="pt-progress-track-wrap">
                <%-- Reward markers rendered here --%>
                <asp:Panel ID="pnlRewardMarkers" runat="server" CssClass="pt-reward-markers"></asp:Panel>
                <div class="pt-progress-track">
                    <div class="pt-progress-fill" id="divProgressFill" runat="server"><asp:Literal ID="litProgressPct" runat="server" /></div>
                </div>
            </div>
        </div>

        <%-- Reward details popover (hidden by default) --%>
        <asp:Panel ID="pnlRewardPopover" runat="server" Visible="false">
            <div class="pt-reward-popover">
                <asp:Image ID="imgPopoverReward" runat="server" CssClass="pt-reward-popover-img" />
                <div class="pt-reward-popover-name"><asp:Literal ID="litPopoverName" runat="server" /></div>
                <div class="pt-reward-popover-pct"><asp:Literal ID="litPopoverPct" runat="server" /></div>
                <div class="pt-reward-popover-status"><asp:Literal ID="litPopoverStatus" runat="server" /></div>
                <asp:Button ID="btnClosePopover" runat="server" Text="X" CssClass="pt-reward-popover-close" OnClick="BtnClosePopover_Click" CausesValidation="false" />
            </div>
        </asp:Panel>
        <asp:HiddenField ID="hidRewardClick" runat="server" />
        <asp:Button ID="btnRewardClick" runat="server" CssClass="d-none" OnClick="BtnRewardClick_Click" CausesValidation="false" />

        <%-- ══ DANGER ZONE ══ --%>
        <div class="pt-sp-danger-zone">
            <span class="pt-sp-danger-label"><%: T("Danger Zone","Zon Bahaya") %></span>
            <button type="button" class="pt-sp-danger-btn" onclick="document.getElementById('resetModal').style.display='flex'; return false;">
                <i class="bi bi-arrow-counterclockwise"></i> <%: T("Reset Study Plan","Tetapkan Semula Pelan Belajar") %>
            </button>
        </div>

        <%-- Reset Confirmation Modal --%>
        <div class="pt-delete-modal-overlay" id="resetModal" style="display:none;">
            <div class="pt-delete-modal">
                <div class="pt-delete-modal-icon"><i class="bi bi-exclamation-triangle-fill"></i></div>
                <div class="pt-delete-modal-title"><%: T("Reset Study Plan?","Tetapkan Semula Pelan Belajar?") %></div>
                <div class="pt-delete-modal-msg"><%: T("This will permanently remove the current study plan, all tasks, and all rewards for this child. This action cannot be undone.","Ini akan membuang pelan belajar semasa, semua tugasan, dan semua ganjaran untuk anak ini secara kekal. Tindakan ini tidak boleh dibatalkan.") %></div>
                <div class="pt-delete-modal-actions">
                    <button type="button" class="pt-btn soft" onclick="document.getElementById('resetModal').style.display='none'; return false;"><%: T("Cancel","Batal") %></button>
                    <asp:Button ID="btnResetPlan" runat="server" CssClass="pt-btn danger" Text="Confirm Reset" OnClick="BtnResetPlan_Click" CausesValidation="false" />
                </div>
            </div>
        </div>

    </asp:Panel>
</div>
</asp:Content>
