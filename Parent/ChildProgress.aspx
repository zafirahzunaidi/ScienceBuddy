
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ChildProgress.aspx.cs"
    Inherits="ScienceBuddy.Parent.ChildProgress" MasterPageFile="~/Site.Master"
    Title="Current Progress" MaintainScrollPositionOnPostback="true" %>

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
        <a href="<%: ResolveUrl("~/Parent/ChildProgress.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-bar-chart-line item-icon"></i><span class="item-label"><%: T("Current Progress","Kemajuan Semasa") %></span></a>
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

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Current Progress","Kemajuan Semasa") %></asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="pd-page">

    <%-- Success/Error Popup --%>
    <asp:Panel ID="pnlMessage" runat="server" Visible="false">
        <div class="pt-success-popup-overlay">
            <div class="pt-success-popup">
                <div class="pt-success-popup-icon">
                    <i class="bi" id="iMsgIcon" runat="server"></i>
                </div>
                <div class="pt-success-popup-text" id="divMessage" runat="server"></div>
                <asp:Button ID="btnCloseMsg" runat="server" Text="X" CssClass="pt-success-popup-close"
                    OnClick="BtnCloseMsg_Click" CausesValidation="false" />
            </div>
        </div>
    </asp:Panel>

    <%-- No Child State --%>
    <asp:Panel ID="pnlNoChild" runat="server" Visible="false">
        <div class="pd-empty">
            <i class="bi bi-person-x-fill"></i>
            <p><asp:Literal ID="litNoChildMsg" runat="server" /></p>
        </div>
    </asp:Panel>

    <%-- Main Content --%>
    <asp:Panel ID="pnlContent" runat="server" Visible="false">

        <%-- ══ 1. HERO CARD ══ --%>
        <div class="pt-hero">
            <i class="bi bi-star-fill pt-sparkle" style="top:12%;left:8%;"></i>
            <i class="bi bi-stars pt-sparkle" style="top:55%;right:6%;animation-delay:1s;"></i>
            <i class="bi bi-star-fill pt-sparkle" style="bottom:20%;left:30%;animation-delay:0.5s;"></i>
            <h2 class="pt-hero-title"><i class="bi bi-bar-chart-line-fill"></i> <asp:Literal ID="litHeroTitle" runat="server" /></h2>
            <p class="pt-hero-sub"><asp:Literal ID="litHeroSub" runat="server" /></p>
            <a href="DownloadReport.aspx" class="pt-download-report-btn" target="_blank">
                <i class="bi bi-file-earmark-pdf-fill"></i> <%: T("Download Progress Report","Muat Turun Laporan Kemajuan") %>
            </a>
        </div>

        <%-- ══ 2. MONTHLY SUMMARY ══ --%>
        <div class="pt-monthly-summary">
            <asp:Literal ID="litMonthlySummary" runat="server" />
        </div>

        <%-- ══ 3. LEARNING CALENDAR HEATMAP ══ --%>
        <div class="pt-heatmap-card sb-card">
            <div class="pt-heatmap-toolbar">
                <div class="pt-heatmap-toolbar-title">
                    <i class="bi bi-calendar3"></i>
                    <span><asp:Literal ID="litHeatmapTitle" runat="server" /></span>
                </div>
                <asp:DropDownList ID="ddlMonth" runat="server" CssClass="pt-heatmap-month-select"
                    AutoPostBack="true" OnSelectedIndexChanged="DdlMonth_Changed" />
            </div>
            <div class="pt-heatmap-legend">
                <span class="pt-heatmap-legend-item"><span class="pt-heatmap-swatch pt-heatmap-swatch-empty"></span> <%: T("No Activity","Tiada Aktiviti") %></span>
                <span class="pt-heatmap-legend-item"><span class="pt-heatmap-swatch pt-heatmap-swatch-low"></span> <%: T("Low","Rendah") %></span>
                <span class="pt-heatmap-legend-item"><span class="pt-heatmap-swatch pt-heatmap-swatch-medium"></span> <%: T("Medium","Sederhana") %></span>
                <span class="pt-heatmap-legend-item"><span class="pt-heatmap-swatch pt-heatmap-swatch-high"></span> <%: T("High","Tinggi") %></span>
            </div>
            <div class="pt-heatmap-grid">
                <div class="pt-heatmap-header">
                    <span><%: T("Mon","Isn") %></span><span><%: T("Tue","Sel") %></span><span><%: T("Wed","Rab") %></span>
                    <span><%: T("Thu","Kha") %></span><span><%: T("Fri","Jum") %></span><span><%: T("Sat","Sab") %></span><span><%: T("Sun","Ahd") %></span>
                </div>
                <asp:Panel ID="pnlHeatmapDays" runat="server" CssClass="pt-heatmap-days"></asp:Panel>
            </div>
        </div>

        <%-- Hidden field for clicked day --%>
        <asp:HiddenField ID="hidSelectedDate" runat="server" />
        <asp:Button ID="btnDayClick" runat="server" CssClass="d-none" OnClick="BtnDayClick_Click" CausesValidation="false" />

        <%-- ══ 3. DAILY ACTIVITY POPUP ══ --%>
        <asp:Panel ID="pnlDailyModal" runat="server" Visible="false">
            <div class="pt-daily-modal-overlay">
                <div class="pt-daily-modal">
                    <div class="pt-daily-modal-header">
                        <span class="pt-daily-modal-title"><i class="bi bi-calendar-event"></i> <asp:Literal ID="litDailyTitle" runat="server" /></span>
                        <asp:Button ID="btnCloseDailyModal" runat="server" Text="X" CssClass="pt-modal-close-btn" OnClick="BtnCloseDailyModal_Click" CausesValidation="false" />
                    </div>
                    <div class="pt-daily-modal-body">
                        <asp:Panel ID="pnlDailyActivities" runat="server"></asp:Panel>
                        <asp:Panel ID="pnlDailyEmpty" runat="server" Visible="false">
                            <div class="pt-daily-empty">
                                <i class="bi bi-emoji-neutral"></i>
                                <p><asp:Literal ID="litDailyEmpty" runat="server" /></p>
                            </div>
                        </asp:Panel>
                    </div>
                </div>
            </div>
        </asp:Panel>

        <%-- ══ 4. BE A COACH SECTION ══ --%>
        <div class="pt-coach-card">
            <div class="pt-coach-header">
                <i class="bi bi-lightbulb-fill"></i>
                <span><asp:Literal ID="litCoachTitle" runat="server" /></span>
            </div>
            <div class="pt-coach-body">
                <div class="pt-coach-avatar-area">
                    <div class="pt-avatar-ring-wrap">
                        <div class="pt-avatar-spin-ring"></div>
                        <asp:Image ID="imgFox" runat="server" CssClass="pt-progress-fox" />
                    </div>
                </div>
                <div class="pt-coach-content">
                    <div class="pt-coach-message">
                        <asp:Literal ID="litCoachMessage" runat="server" />
                    </div>
                    <asp:Panel ID="pnlCoachTip" runat="server" Visible="false">
                        <div class="pt-coach-tip">
                            <i class="bi bi-lightbulb"></i>
                            <asp:Literal ID="litCoachTip" runat="server" />
                        </div>
                    </asp:Panel>
                    <asp:Panel ID="pnlAddStudyPlanBtn" runat="server" Visible="false">
                        <button type="button" class="pt-btn primary" onclick="document.getElementById('<%=pnlTaskModal.ClientID%>').classList.remove('pt-task-modal-hidden'); return false;">
                            <i class="bi bi-plus-circle"></i> <asp:Literal ID="litAddToPlanBtn" runat="server" />
                        </button>
                    </asp:Panel>
                </div>
            </div>
        </div>

        <%-- ══ 5. ADD TO STUDY PLAN MINI POPUP ══ --%>
        <asp:Panel ID="pnlTaskModal" runat="server" CssClass="pt-task-modal-overlay pt-task-modal-hidden">
            <div class="pt-task-modal" id="taskModalCard">
                <div class="pt-task-modal-header">
                    <span class="pt-task-modal-title"><i class="bi bi-journal-plus"></i> <asp:Literal ID="litTaskModalTitle" runat="server" /></span>
                    <div class="pt-task-modal-controls">
                        <button type="button" class="pt-modal-ctrl-btn" onclick="document.getElementById('taskModalCard').classList.toggle('pt-task-modal-minimised'); return false;" title="Minimise">
                            <i class="bi bi-dash"></i>
                        </button>
                        <button type="button" class="pt-modal-ctrl-btn" onclick="document.getElementById('taskModalCard').classList.toggle('pt-task-modal-expanded'); return false;" title="Expand">
                            <i class="bi bi-arrows-fullscreen"></i>
                        </button>
                        <button type="button" class="pt-modal-ctrl-btn pt-modal-close-x" onclick="document.getElementById('<%=pnlTaskModal.ClientID%>').classList.add('pt-task-modal-hidden'); return false;" title="Close">
                            <i class="bi bi-x-lg"></i>
                        </button>
                    </div>
                </div>
                <div class="pt-task-modal-body">
                    <p class="pt-task-modal-sub"><asp:Literal ID="litTaskModalSub" runat="server" /></p>

                    <div class="pt-field">
                        <label class="pt-label"><asp:Literal ID="litLblTaskName" runat="server" /></label>
                        <asp:TextBox ID="txtTaskName" runat="server" CssClass="pt-input" MaxLength="200" />
                        <asp:RequiredFieldValidator ID="rfvTaskName" runat="server" ControlToValidate="txtTaskName"
                            ValidationGroup="vgTask" Display="Dynamic" CssClass="pt-field-error"
                            ErrorMessage="Required" />
                    </div>

                    <div class="pt-field">
                        <label class="pt-label"><asp:Literal ID="litLblSuggestedAction" runat="server" /></label>
                        <asp:TextBox ID="txtSuggestedAction" runat="server" CssClass="pt-input" TextMode="MultiLine" Rows="3" />
                    </div>

                    <div class="pt-task-modal-footer">
                        <button type="button" class="pt-btn soft" onclick="document.getElementById('<%=pnlTaskModal.ClientID%>').classList.add('pt-task-modal-hidden'); return false;">
                            <asp:Literal ID="litBtnCancel" runat="server" />
                        </button>
                        <asp:Button ID="btnAddTask" runat="server" CssClass="pt-btn primary"
                            OnClick="BtnAddTask_Click" ValidationGroup="vgTask" />
                    </div>
                </div>
            </div>
        </asp:Panel>

        <%-- ══ 6. SCIENCE POWER MAP ══ --%>
        <asp:Panel ID="pnlPowerMap" runat="server" Visible="false">
            <div class="pt-power-map-card">
                <div class="pt-power-map-header">
                    <span class="pt-power-map-icon"><i class="bi bi-lightning-charge-fill"></i></span>
                    <h3 class="pt-power-map-title"><asp:Literal ID="litPowerMapTitle" runat="server" /></h3>
                </div>
                <p class="pt-power-map-helper"><%: T("Click any skill to understand what it means and how you can support your child.","Klik mana-mana kemahiran untuk memahami maksudnya dan bagaimana anda boleh menyokong anak anda.") %></p>

                <%-- SVG Radar Chart with floating popover --%>
                <div class="pt-power-map-chart">
                    <asp:Literal ID="litPowerMapSvg" runat="server" />

                    <%-- Floating popover (positioned absolutely inside chart container) --%>
                    <div class="pt-power-popover" id="powerPopover">
                        <button type="button" class="pt-power-popover-close" onclick="closeSkillPanel()" aria-label="Close">&times;</button>
                        <div class="pt-power-popup-title" id="popupTitle"></div>
                        <div class="pt-power-popup-status" id="popupStatus"></div>
                        <div class="pt-power-popup-section">
                            <span class="pt-power-popup-label"><%: T("What it means:","Apa maksudnya:") %></span>
                            <span class="pt-power-popup-text" id="popupMeaning"></span>
                        </div>
                        <div class="pt-power-popup-section">
                            <span class="pt-power-popup-label"><%: T("Current progress:","Kemajuan semasa:") %></span>
                            <span class="pt-power-popup-text" id="popupProgress"></span>
                        </div>
                    </div>
                </div>

                <%-- Explorer Identity --%>
                <div class="pt-power-map-identity">
                    <div class="pt-power-map-type">
                        <i class="bi bi-star-fill"></i>
                        <asp:Literal ID="litExplorerType" runat="server" />
                    </div>
                    <div class="pt-power-map-stats">
                        <span class="pt-power-stat superpower"><i class="bi bi-lightning-fill"></i> <asp:Literal ID="litSuperpower" runat="server" /></span>
                        <span class="pt-power-stat powerup"><i class="bi bi-arrow-up-circle-fill"></i> <asp:Literal ID="litPowerUp" runat="server" /></span>
                    </div>
                </div>

                <%-- AI advice --%>
                <asp:Panel ID="pnlPowerMapAdvice" runat="server" Visible="false">
                    <div class="pt-power-map-advice">
                        <i class="bi bi-chat-left-heart-fill"></i>
                        <asp:Literal ID="litPowerMapAdvice" runat="server" />
                    </div>
                </asp:Panel>

                <div class="pt-power-map-footer">
                    <i class="bi bi-info-circle"></i> <asp:Literal ID="litPowerMapFooter" runat="server" />
                </div>
            </div>

            <%-- Skill data for JavaScript --%>
            <asp:Literal ID="litSkillDataScript" runat="server" />

            <script type="text/javascript">
            var skillData = window._skillData || [];
            var panelColors = ['#F3E8FF','#CCFBF1','#FFF7ED','#FEE2E2','#EDE9FE','#DCFCE7'];
            var posClasses = ['pt-power-popover-pos-0','pt-power-popover-pos-1','pt-power-popover-pos-2',
                              'pt-power-popover-pos-3','pt-power-popover-pos-4','pt-power-popover-pos-5'];

            function openSkillPanel(idx) {
                if (idx < 0 || idx >= skillData.length) return;
                var s = skillData[idx];
                var popover = document.getElementById('powerPopover');

                document.getElementById('popupTitle').textContent = s.name;
                document.getElementById('popupStatus').textContent = s.status;
                document.getElementById('popupMeaning').textContent = s.meaning;
                document.getElementById('popupProgress').textContent = s.progress;

                // Remove all position classes and set the correct one
                posClasses.forEach(function(c){ popover.classList.remove(c); });
                popover.classList.add(posClasses[idx] || posClasses[0]);

                // Set pastel background colour
                popover.style.background = panelColors[idx] || '#F8FAFC';

                // Show with animation
                popover.classList.add('pt-power-popover-visible');

                // Highlight the active label via SVG class
                var labels = document.querySelectorAll('.pt-power-skill-btn');
                labels.forEach(function(l){ l.classList.remove('pt-power-skill-active'); });
                if (labels[idx]) labels[idx].classList.add('pt-power-skill-active');
            }

            function closeSkillPanel() {
                var popover = document.getElementById('powerPopover');
                popover.classList.remove('pt-power-popover-visible');
                var labels = document.querySelectorAll('.pt-power-skill-btn');
                labels.forEach(function(l){ l.classList.remove('pt-power-skill-active'); });
            }

            document.addEventListener('keydown', function(e) {
                if (e.key === 'Escape') closeSkillPanel();
            });

            document.addEventListener('click', function(e) {
                var popover = document.getElementById('powerPopover');
                if (popover && popover.classList.contains('pt-power-popover-visible')) {
                    if (!e.target.closest('.pt-power-popover') && !e.target.closest('.pt-power-skill-btn')) {
                        closeSkillPanel();
                    }
                }
            });
            </script>
        </asp:Panel>

    </asp:Panel><%-- /pnlContent --%>

</div><%-- /.pd-page --%>
</asp:Content>
