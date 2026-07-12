<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="QuizResults.aspx.cs"
    Inherits="ScienceBuddy.Parent.QuizResults" MasterPageFile="~/Site.Master"
    Title="Quiz Results" MaintainScrollPositionOnPostback="true" %>

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
        <a href="<%: ResolveUrl("~/Parent/EnrolledModules.aspx") %>" class="sb-sidebar-item"><i class="bi bi-journal-bookmark item-icon"></i><span class="item-label"><%: T("Learning Journey","Perjalanan Pembelajaran") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Child Performance","Prestasi Anak") %></div>
        <a href="<%: ResolveUrl("~/Parent/ChildProgress.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bar-chart-line item-icon"></i><span class="item-label"><%: T("Current Progress","Kemajuan Semasa") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/QuizResults.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-patch-check item-icon"></i><span class="item-label"><%: T("Quiz Results","Keputusan Kuiz") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Study Plan","Pelan Pembelajaran") %></div>
        <a href="<%: ResolveUrl("~/Parent/StudyPlan.aspx") %>" class="sb-sidebar-item"><i class="bi bi-journal-check item-icon"></i><span class="item-label"><%: T("Study Plan","Pelan Pembelajaran") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/EditStudyPlan.aspx") %>" class="sb-sidebar-item"><i class="bi bi-pencil-square item-icon"></i><span class="item-label"><%: T("Edit Study Plan","Edit Pelan Pembelajaran") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Discussions","Perbincangan") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentTeacherCommunication.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Chat with Teachers","Sembang dengan Guru") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/Forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-people item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Profile","Profil") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("Edit Profile","Edit Profil") %></span></a>        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Logout","Log Keluar") %></span></a></div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Quiz Results","Keputusan Kuiz") %></asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="pd-page">

    <%-- Success Popup --%>
    <asp:Panel ID="pnlMessage" runat="server" Visible="false">
        <div class="pt-success-popup-overlay">
            <div class="pt-success-popup">
                <div class="pt-success-popup-icon"><i class="bi" id="iMsgIcon" runat="server"></i></div>
                <div class="pt-success-popup-text" id="divMessage" runat="server"></div>
                <asp:Button ID="btnCloseMsg" runat="server" Text="X" CssClass="pt-success-popup-close" OnClick="BtnCloseMsg_Click" CausesValidation="false" />
            </div>
        </div>
    </asp:Panel>

    <%-- No Child State --%>
    <asp:Panel ID="pnlNoChild" runat="server" Visible="false">
        <div class="pd-empty"><i class="bi bi-person-x-fill"></i><p><asp:Literal ID="litNoChildMsg" runat="server" /></p></div>
    </asp:Panel>

    <%-- Main Content --%>
    <asp:Panel ID="pnlContent" runat="server" Visible="false">

        <%-- ══ 1. HEADER ══ --%>
        <div class="pt-progress-hero">
            <i class="bi bi-star-fill pt-twinkle-star" style="top:12%;left:8%;"></i>
            <i class="bi bi-stars pt-twinkle-star" style="top:55%;right:6%;"></i>
            <div class="pt-progress-hero-body">
                <h2 class="pt-progress-hero-title"><asp:Literal ID="litHeroTitle" runat="server" /></h2>
                <p class="pt-progress-hero-sub"><asp:Literal ID="litHeroSub" runat="server" /></p>
            </div>
        </div>

        <%-- Unit Filter --%>
        <div class="pt-quiz-filter-row">
            <span class="pt-quiz-filter-label"><i class="bi bi-funnel"></i> <%: T("Filter by Unit","Tapis mengikut Unit") %>:</span>
            <asp:DropDownList ID="ddlUnit" runat="server" CssClass="pt-heatmap-month-select"
                AutoPostBack="true" OnSelectedIndexChanged="DdlUnit_Changed" />
        </div>

        <%-- ══ 2. PERFORMANCE SUMMARY ══ --%>
        <div class="pt-summary-grid pt-summary-grid-4 pt-stagger-in">
            <div class="pt-summary-card progress-card">
                <div class="pt-summary-icon"><i class="bi bi-percent"></i></div>
                <span class="pt-summary-value"><asp:Literal ID="litAvgScore" runat="server" /></span>
                <span class="pt-summary-label"><%: T("Average Score","Skor Purata") %></span>
            </div>
            <div class="pt-summary-card quiz-card">
                <div class="pt-summary-icon"><i class="bi bi-trophy-fill"></i></div>
                <span class="pt-summary-value"><asp:Literal ID="litHighScore" runat="server" /></span>
                <span class="pt-summary-label"><%: T("Highest Score","Skor Tertinggi") %></span>
            </div>
            <div class="pt-summary-card badge-card">
                <div class="pt-summary-icon"><i class="bi bi-check-circle-fill"></i></div>
                <span class="pt-summary-value"><asp:Literal ID="litPassRate" runat="server" /></span>
                <span class="pt-summary-label"><%: T("Pass Rate","Kadar Lulus") %></span>
            </div>
            <div class="pt-summary-card" style="background:#E0F2FE;">
                <div class="pt-summary-icon" style="background:#BAE6FD;color:#0369A1;"><i class="bi bi-pencil-square"></i></div>
                <span class="pt-summary-value"><asp:Literal ID="litTotalAttempts" runat="server" /></span>
                <span class="pt-summary-label"><%: T("Total Attempts","Jumlah Percubaan") %></span>
            </div>
        </div>

        <%-- ══ 3. PERFORMANCE INSIGHTS ══ --%>
        <div class="pt-quiz-section-title"><i class="bi bi-graph-up-arrow"></i> <%: T("Performance Insights","Wawasan Prestasi") %></div>
        <div class="pt-two-col">
            <%-- Score Trend --%>
            <div class="pt-dashboard-card">
                <div class="pt-dashboard-card-header">
                    <span class="pt-dashboard-card-title"><i class="bi bi-activity"></i> <%: T("Score Trend","Trend Skor") %></span>
                </div>
                <div class="pt-dashboard-card-body">
                    <asp:Panel ID="pnlScoreTrend" runat="server"></asp:Panel>
                    <asp:Panel ID="pnlNoTrend" runat="server" Visible="false">
                        <div class="pt-no-data"><%: T("No quiz attempts yet.","Belum ada percubaan kuiz.") %></div>
                    </asp:Panel>
                </div>
            </div>
            <%-- Performance by Unit --%>
            <div class="pt-dashboard-card">
                <div class="pt-dashboard-card-header">
                    <span class="pt-dashboard-card-title"><i class="bi bi-bar-chart-line"></i> <%: T("Performance by Unit","Prestasi mengikut Unit") %></span>
                </div>
                <div class="pt-dashboard-card-body">
                    <asp:Panel ID="pnlUnitPerformance" runat="server"></asp:Panel>
                    <asp:Panel ID="pnlNoUnitPerf" runat="server" Visible="false">
                        <div class="pt-no-data"><%: T("No data yet.","Belum ada data.") %></div>
                    </asp:Panel>
                </div>
            </div>
        </div>

        <%-- ══ 4. RECENT QUIZ ATTEMPTS ══ --%>
        <div class="pt-dashboard-card" style="margin-bottom:24px;">
            <div class="pt-dashboard-card-header">
                <span class="pt-dashboard-card-title"><i class="bi bi-clock-history"></i> <%: T("Recent Quiz Attempts","Percubaan Kuiz Terkini") %></span>
                <asp:Button ID="btnViewSelected" runat="server" CssClass="pt-btn primary"
                    Text="View Selected Details" OnClick="BtnViewSelected_Click" CausesValidation="false" />
            </div>
            <div class="pt-dashboard-card-body" style="padding:0;">
                <asp:Panel ID="pnlAttempts" runat="server"></asp:Panel>
                <asp:Panel ID="pnlNoAttempts" runat="server" Visible="false">
                    <div class="pt-no-data" style="padding:24px;"><%: T("No quiz attempts found for this child.","Tiada percubaan kuiz ditemui untuk anak ini.") %></div>
                </asp:Panel>
            </div>
        </div>
        <asp:HiddenField ID="hidSelectedResults" runat="server" />

        <%-- ══ 5. QUIZ DETAILS MODAL ══ --%>
        <asp:Panel ID="pnlDetailsModal" runat="server" Visible="false">
            <div class="pt-daily-modal-overlay">
                <div class="pt-daily-modal" style="max-width:640px;max-height:85vh;">
                    <div class="pt-daily-modal-header">
                        <span class="pt-daily-modal-title"><i class="bi bi-file-earmark-text"></i> <%: T("Selected Quiz Details","Butiran Kuiz Dipilih") %></span>
                        <asp:Button ID="btnCloseDetails" runat="server" Text="X" CssClass="pt-modal-close-btn" OnClick="BtnCloseDetails_Click" CausesValidation="false" />
                    </div>
                    <div class="pt-daily-modal-body">
                        <asp:Panel ID="pnlDetailsContent" runat="server"></asp:Panel>
                    </div>
                </div>
            </div>
        </asp:Panel>

        <%-- Hidden field for toggling incorrect questions --%>
        <asp:HiddenField ID="hidToggleResult" runat="server" />
        <asp:Button ID="btnToggleIncorrect" runat="server" CssClass="d-none" OnClick="BtnToggleIncorrect_Click" CausesValidation="false" />

        <%-- ══ 6. WEAK & STRONG AREAS ══ --%>
        <div class="pt-quiz-section-title"><i class="bi bi-lightbulb-fill"></i> <%: T("Learning Insights","Wawasan Pembelajaran") %></div>
        <div class="pt-two-col">
            <%-- Weak Areas --%>
            <div class="pt-dashboard-card">
                <div class="pt-dashboard-card-header">
                    <span class="pt-dashboard-card-title" style="color:#DC2626;"><i class="bi bi-exclamation-triangle-fill"></i> <%: T("Areas That Need Improvement","Bidang yang Perlu Diperbaiki") %></span>
                </div>
                <div class="pt-dashboard-card-body">
                    <asp:Panel ID="pnlWeakAreas" runat="server"></asp:Panel>
                    <asp:Panel ID="pnlNoWeak" runat="server" Visible="false">
                        <div class="pt-no-data"><%: T("No weak areas identified. Great work!","Tiada bidang lemah dikenal pasti. Syabas!") %></div>
                    </asp:Panel>
                    <asp:Button ID="btnAddWeakToStudyPlan" runat="server" CssClass="pt-btn primary" style="margin-top:14px;"
                        OnClick="BtnAddWeakToStudyPlan_Click" CausesValidation="false" />
                </div>
            </div>
            <%-- Strong Areas --%>
            <div class="pt-dashboard-card">
                <div class="pt-dashboard-card-header">
                    <span class="pt-dashboard-card-title" style="color:#16A34A;"><i class="bi bi-trophy-fill"></i> <%: T("Strong Areas","Bidang Kekuatan") %></span>
                </div>
                <div class="pt-dashboard-card-body">
                    <div class="pt-quiz-most-improved">
                        <span class="pt-quiz-most-improved-label"><i class="bi bi-arrow-up-circle-fill"></i> <%: T("Most Improved Unit","Unit Paling Berkembang") %></span>
                        <span class="pt-quiz-most-improved-value"><asp:Literal ID="litMostImproved" runat="server" /></span>
                    </div>
                    <asp:Panel ID="pnlStrongAreas" runat="server"></asp:Panel>
                    <asp:Panel ID="pnlNoStrong" runat="server" Visible="false">
                        <div class="pt-no-data"><%: T("Not enough quiz history yet.","Belum cukup sejarah kuiz.") %></div>
                    </asp:Panel>
                </div>
            </div>
        </div>

        <%-- ══ ADD TO STUDY PLAN MODAL ══ --%>
        <asp:Panel ID="pnlTaskModal" runat="server" CssClass="pt-task-modal-overlay pt-task-modal-hidden">
            <div class="pt-task-modal" id="taskModalCard">
                <div class="pt-task-modal-header">
                    <span class="pt-task-modal-title"><i class="bi bi-journal-plus"></i> <%: T("Add to Study Plan","Tambah ke Pelan Belajar") %></span>
                    <div class="pt-task-modal-controls">
                        <button type="button" class="pt-modal-ctrl-btn" onclick="document.getElementById('taskModalCard').classList.toggle('pt-task-modal-minimised'); return false;" title="Minimise"><i class="bi bi-dash"></i></button>
                        <button type="button" class="pt-modal-ctrl-btn" onclick="document.getElementById('taskModalCard').classList.toggle('pt-task-modal-expanded'); return false;" title="Expand"><i class="bi bi-arrows-fullscreen"></i></button>
                        <button type="button" class="pt-modal-ctrl-btn pt-modal-close-x" onclick="document.getElementById('<%=pnlTaskModal.ClientID%>').classList.add('pt-task-modal-hidden'); return false;" title="Close"><i class="bi bi-x-lg"></i></button>
                    </div>
                </div>
                <div class="pt-task-modal-body">
                    <p class="pt-task-modal-sub"><asp:Literal ID="litTaskModalSub" runat="server" /></p>
                    <div class="pt-field">
                        <label class="pt-label"><%: T("Task Name","Nama Tugasan") %></label>
                        <asp:TextBox ID="txtTaskName" runat="server" CssClass="pt-input" MaxLength="200" />
                    </div>
                    <div class="pt-field">
                        <label class="pt-label"><%: T("Suggested Action","Cadangan Tindakan") %></label>
                        <asp:TextBox ID="txtSuggestedAction" runat="server" CssClass="pt-input" TextMode="MultiLine" Rows="3" />
                    </div>
                    <div class="pt-task-modal-footer">
                        <button type="button" class="pt-btn soft" onclick="document.getElementById('<%=pnlTaskModal.ClientID%>').classList.add('pt-task-modal-hidden'); return false;"><%: T("Cancel","Batal") %></button>
                        <asp:Button ID="btnConfirmAddTask" runat="server" CssClass="pt-btn primary" OnClick="BtnConfirmAddTask_Click" CausesValidation="false" />
                    </div>
                </div>
            </div>
        </asp:Panel>

    </asp:Panel><%-- /pnlContent --%>
</div>
</asp:Content>
