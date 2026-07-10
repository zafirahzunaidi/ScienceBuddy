<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EditStudyPlan.aspx.cs"
    Inherits="ScienceBuddy.Parent.EditStudyPlan" MasterPageFile="~/Site.Master"
    Title="Edit Study Plan" MaintainScrollPositionOnPostback="true" %>

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
        <a href="<%: ResolveUrl("~/Parent/EditStudyPlan.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-pencil-square item-icon"></i><span class="item-label"><%: T("Edit Study Plan","Edit Pelan Pembelajaran") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Discussions","Perbincangan") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentTeacherCommunication.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Chat with Teachers","Sembang dengan Guru") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/Forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-people item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Profile","Profil") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("Edit Profile","Edit Profil") %></span></a>        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Logout","Log Keluar") %></span></a></div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Edit Study Plan","Edit Pelan Pembelajaran") %></asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="pd-page">

    <%-- Success Popup --%>
    <asp:Panel ID="pnlMessage" runat="server" Visible="false">
        <div class="pt-success-popup-overlay"><div class="pt-success-popup">
            <div class="pt-success-popup-icon"><i class="bi" id="iMsgIcon" runat="server"></i></div>
            <div class="pt-success-popup-text" id="divMessage" runat="server"></div>
            <asp:Button ID="btnCloseMsg" runat="server" Text="X" CssClass="pt-success-popup-close" OnClick="BtnCloseMsg_Click" CausesValidation="false" />
        </div></div>
    </asp:Panel>

    <%-- No Child / No Plan --%>
    <asp:Panel ID="pnlNoChild" runat="server" Visible="false">
        <div class="pd-empty"><i class="bi bi-person-x-fill"></i><p><asp:Literal ID="litNoChildMsg" runat="server" /></p></div>
    </asp:Panel>

    <asp:Panel ID="pnlContent" runat="server" Visible="false">

        <%-- Header --%>
        <div class="pt-study-plan-header">
            <div class="pt-study-plan-header-left">
                <h2 class="pt-study-plan-title"><i class="bi bi-pencil-square"></i> <%: T("Edit Study Plan","Edit Pelan Pembelajaran") %></h2>
                <p class="pt-study-plan-sub"><asp:Literal ID="litEditSub" runat="server" /></p>
            </div>
            <a href="<%: ResolveUrl("~/Parent/StudyPlan.aspx") %>" class="pt-btn soft"><i class="bi bi-arrow-left"></i> <%: T("Back to Plan","Kembali ke Pelan") %></a>
        </div>

        <%-- ══ PLAN DETAILS EDITOR ══ --%>
        <div class="pt-dashboard-card" style="margin-bottom:20px;">
            <div class="pt-dashboard-card-header"><span class="pt-dashboard-card-title"><i class="bi bi-gear-fill"></i> <%: T("Plan Details","Butiran Pelan") %></span></div>
            <div class="pt-dashboard-card-body">
                <div class="pt-field"><label class="pt-label"><%: T("Plan Title","Tajuk Pelan") %></label><asp:TextBox ID="txtPlanTitle" runat="server" CssClass="pt-input" MaxLength="200" /></div>
                <div class="pt-field"><label class="pt-label"><%: T("Due Date","Tarikh Akhir") %></label><asp:TextBox ID="txtDueDate" runat="server" CssClass="pt-input" TextMode="Date" /></div>
                <asp:Button ID="btnSaveTitle" runat="server" CssClass="pt-btn primary" OnClick="BtnSaveTitle_Click" CausesValidation="false" />
            </div>
        </div>

        <%-- ══ TASKS ══ --%>
        <div class="pt-dashboard-card" style="margin-bottom:20px;">
            <div class="pt-dashboard-card-header">
                <div>
                    <span class="pt-dashboard-card-title"><i class="bi bi-list-check"></i> <%: T("Tasks","Tugasan") %></span>
                    <div style="font-size:0.75rem;color:#94A3B8;font-weight:500;margin-top:2px;"><%: T("Drag to reorder","Seret untuk menyusun semula") %></div>
                </div>
                <asp:Button ID="btnShowAddTask" runat="server" CssClass="pt-btn primary" OnClick="BtnShowAddTask_Click" CausesValidation="false" />
            </div>
            <div class="pt-dashboard-card-body">
                <asp:Panel ID="pnlTaskList" runat="server"></asp:Panel>
                <asp:Panel ID="pnlNoTasks" runat="server" Visible="false">
                    <div class="pt-no-data"><%: T("No tasks yet. Add your first task!","Belum ada tugasan. Tambah tugasan pertama!") %></div>
                </asp:Panel>
            </div>
        </div>

        <%-- Add/Edit Task Form (hidden by default) --%>
        <asp:Panel ID="pnlTaskForm" runat="server" Visible="false">
            <div class="pt-dashboard-card" style="margin-bottom:20px;border:2px solid #C7D2FE;">
                <div class="pt-dashboard-card-header"><span class="pt-dashboard-card-title"><i class="bi bi-plus-circle"></i> <asp:Literal ID="litTaskFormTitle" runat="server" /></span></div>
                <div class="pt-dashboard-card-body">
                    <div class="pt-field"><label class="pt-label"><%: T("Task Title","Tajuk Tugasan") %></label><asp:TextBox ID="txtTaskTitle" runat="server" CssClass="pt-input" MaxLength="200" /></div>
                    <div class="pt-field"><label class="pt-label"><%: T("Suggested Action","Cadangan Tindakan") %></label>
                        <asp:DropDownList ID="ddlSuggestedAction" runat="server" CssClass="pt-select">
                            <asp:ListItem Value="View Lesson" />
                            <asp:ListItem Value="Attempt Quiz" />
                            <asp:ListItem Value="Revise Notes" />
                            <asp:ListItem Value="Watch Video" />
                            <asp:ListItem Value="Practise Weak Topic" />
                            <asp:ListItem Value="Complete Activity" />
                            <asp:ListItem Value="Parent Reminder" />
                        </asp:DropDownList>
                    </div>
                    <div style="display:flex;gap:10px;">
                        <asp:Button ID="btnSaveTask" runat="server" CssClass="pt-btn primary" OnClick="BtnSaveTask_Click" CausesValidation="false" />
                        <asp:Button ID="btnCancelTask" runat="server" CssClass="pt-btn soft" OnClick="BtnCancelTask_Click" CausesValidation="false" />
                    </div>
                    <asp:HiddenField ID="hidEditTaskId" runat="server" />
                </div>
            </div>
        </asp:Panel>

        <%-- Hidden fields for task operations --%>
        <asp:HiddenField ID="hidDeleteTaskId" runat="server" />
        <asp:Button ID="btnDeleteTask" runat="server" CssClass="d-none" OnClick="BtnDeleteTask_Click" CausesValidation="false" />
        <asp:HiddenField ID="hidMoveTaskId" runat="server" />
        <asp:HiddenField ID="hidMoveDir" runat="server" />
        <asp:Button ID="btnMoveTask" runat="server" CssClass="d-none" OnClick="BtnMoveTask_Click" CausesValidation="false" />
        <asp:HiddenField ID="hidEditTaskIdTrigger" runat="server" />
        <asp:Button ID="btnEditTaskTrigger" runat="server" CssClass="d-none" OnClick="BtnEditTaskTrigger_Click" CausesValidation="false" />
        <%-- Drag-drop order save --%>
        <asp:HiddenField ID="hidNewOrder" runat="server" />
        <asp:Button ID="btnSaveOrder" runat="server" CssClass="d-none" OnClick="BtnSaveOrder_Click" CausesValidation="false" />

        <%-- Delete Confirmation Modal --%>
        <div class="pt-delete-modal-overlay" id="deleteModal" style="display:none;">
            <div class="pt-delete-modal">
                <div class="pt-delete-modal-icon"><i class="bi bi-exclamation-triangle-fill"></i></div>
                <div class="pt-delete-modal-title" id="deleteModalTitle"></div>
                <div class="pt-delete-modal-msg" id="deleteModalMsg"></div>
                <div class="pt-delete-modal-actions">
                    <button type="button" class="pt-btn soft" onclick="closeDeleteModal(); return false;"><%: T("Cancel","Batal") %></button>
                    <button type="button" class="pt-btn danger" id="deleteModalConfirm" onclick="confirmDelete(); return false;"><%: T("Confirm","Sahkan") %></button>
                </div>
            </div>
        </div>

        <script>
        var _deleteType='', _deleteId='';
        function showDeleteModal(type, id, title, msg){
            _deleteType=type; _deleteId=id;
            document.getElementById('deleteModalTitle').innerText=title;
            document.getElementById('deleteModalMsg').innerText=msg;
            document.getElementById('deleteModal').style.display='flex';
        }
        function closeDeleteModal(){ document.getElementById('deleteModal').style.display='none'; }
        function confirmDelete(){
            closeDeleteModal();
            if(_deleteType==='task'){ document.getElementById('<%=hidDeleteTaskId.ClientID%>').value=_deleteId; document.getElementById('<%=btnDeleteTask.ClientID%>').click(); }
            else if(_deleteType==='reward'){ document.getElementById('<%=hidDeleteRewardId.ClientID%>').value=_deleteId; document.getElementById('<%=btnDeleteReward.ClientID%>').click(); }
        }
        // Drag and drop
        var dragSrc=null;
        function initDrag(){
            var items=document.querySelectorAll('.pt-draggable');
            items.forEach(function(el){
                el.setAttribute('draggable','true');
                el.addEventListener('dragstart',function(e){ dragSrc=this; this.classList.add('pt-dragging'); e.dataTransfer.effectAllowed='move'; });
                el.addEventListener('dragend',function(){ this.classList.remove('pt-dragging'); });
                el.addEventListener('dragover',function(e){ e.preventDefault(); e.dataTransfer.dropEffect='move'; this.classList.add('pt-drag-over'); });
                el.addEventListener('dragleave',function(){ this.classList.remove('pt-drag-over'); });
                el.addEventListener('drop',function(e){ e.preventDefault(); this.classList.remove('pt-drag-over'); if(dragSrc!==this){ var list=this.parentNode; var allItems=Array.from(list.querySelectorAll('.pt-draggable')); var srcIdx=allItems.indexOf(dragSrc); var dstIdx=allItems.indexOf(this); if(srcIdx<dstIdx) this.after(dragSrc); else this.before(dragSrc); saveOrder(); } });
            });
        }
        function saveOrder(){
            var items=document.querySelectorAll('.pt-draggable');
            var ids=[]; items.forEach(function(el){ ids.push(el.getAttribute('data-id')); });
            document.getElementById('<%=hidNewOrder.ClientID%>').value=ids.join(',');
            document.getElementById('<%=btnSaveOrder.ClientID%>').click();
        }
        if(document.readyState==='loading') document.addEventListener('DOMContentLoaded',initDrag); else initDrag();
        </script>

        <%-- ══ REWARDS ══ --%>
        <div class="pt-dashboard-card" style="margin-bottom:20px;">
            <div class="pt-dashboard-card-header">
                <div>
                    <span class="pt-dashboard-card-title"><i class="bi bi-gift-fill"></i> <%: T("Rewards","Ganjaran") %> <span class="pt-reward-count">(<asp:Literal ID="litRewardCount" runat="server" /> / 5)</span></span>
                    <div style="font-size:0.75rem;color:#94A3B8;font-weight:500;margin-top:2px;"><%: T("Add fun rewards for your child.","Tambah ganjaran menarik untuk anak anda.") %></div>
                </div>
                <asp:Button ID="btnShowAddReward" runat="server" CssClass="pt-btn primary" OnClick="BtnShowAddReward_Click" CausesValidation="false" />
            </div>
            <div class="pt-dashboard-card-body">
                <asp:Panel ID="pnlRewardList" runat="server"></asp:Panel>
                <asp:Panel ID="pnlNoRewards" runat="server" Visible="false">
                    <div class="pt-no-data"><%: T("No rewards yet. Add fun rewards to motivate your child!","Belum ada ganjaran. Tambah ganjaran untuk memotivasikan anak!") %></div>
                </asp:Panel>

                <%-- Reward Milestone Preview --%>
                <div class="pt-quiz-section-title" style="margin-top:16px;"><i class="bi bi-flag-fill"></i> <%: T("Reward Milestone Preview","Pratonton Pencapaian Ganjaran") %></div>
                <div class="pt-progress-track-wrap pt-reward-preview-wrap">
                    <asp:Panel ID="pnlPreviewMarkers" runat="server" CssClass="pt-reward-markers"></asp:Panel>
                    <div class="pt-progress-track"><div class="pt-progress-fill" style="width:0%;"></div></div>
                    <div class="pt-reward-preview-labels"><span>0%</span><span>25%</span><span>50%</span><span>75%</span><span>100%</span></div>
                </div>
            </div>
        </div>

        <%-- Add/Edit Reward Form --%>
        <asp:Panel ID="pnlRewardForm" runat="server" Visible="false">
            <div class="pt-dashboard-card" style="margin-bottom:20px;border:2px solid #FCD34D;">
                <div class="pt-dashboard-card-header"><span class="pt-dashboard-card-title"><i class="bi bi-gift"></i> <asp:Literal ID="litRewardFormTitle" runat="server" /></span></div>
                <div class="pt-dashboard-card-body">
                    <%-- Image Picker --%>
                    <div class="pt-field"><label class="pt-label"><%: T("Choose Image","Pilih Imej") %></label>
                        <div class="pt-reward-picker-grid">
                            <asp:Panel ID="pnlImageGrid" runat="server"></asp:Panel>
                        </div>
                        <asp:HiddenField ID="hidSelectedImage" runat="server" />
                    </div>
                    <%-- Reward Name --%>
                    <div class="pt-field"><label class="pt-label"><%: T("Reward Name","Nama Ganjaran") %></label><asp:TextBox ID="txtRewardName" runat="server" CssClass="pt-input" MaxLength="150" placeholder="e.g. Watch Frozen Together" /></div>
                    <%-- Unlock At --%>
                    <div class="pt-field"><label class="pt-label"><%: T("Unlock At (%)","Buka pada (%)") %></label>
                        <div style="display:flex;gap:8px;flex-wrap:wrap;margin-bottom:8px;">
                            <button type="button" class="pt-btn soft" onclick="document.getElementById('<%=txtUnlockPct.ClientID%>').value='25'; return false;">25%</button>
                            <button type="button" class="pt-btn soft" onclick="document.getElementById('<%=txtUnlockPct.ClientID%>').value='50'; return false;">50%</button>
                            <button type="button" class="pt-btn soft" onclick="document.getElementById('<%=txtUnlockPct.ClientID%>').value='75'; return false;">75%</button>
                            <button type="button" class="pt-btn soft" onclick="document.getElementById('<%=txtUnlockPct.ClientID%>').value='100'; return false;">100%</button>
                        </div>
                        <asp:TextBox ID="txtUnlockPct" runat="server" CssClass="pt-input" TextMode="Number" style="max-width:120px;" />
                    </div>
                    <div style="display:flex;gap:10px;">
                        <asp:Button ID="btnSaveReward" runat="server" CssClass="pt-btn primary" OnClick="BtnSaveReward_Click" CausesValidation="false" />
                        <asp:Button ID="btnCancelReward" runat="server" CssClass="pt-btn soft" OnClick="BtnCancelReward_Click" CausesValidation="false" />
                    </div>
                    <asp:HiddenField ID="hidEditRewardId" runat="server" />
                </div>
            </div>
        </asp:Panel>

        <%-- Hidden fields for reward operations --%>
        <asp:HiddenField ID="hidDeleteRewardId" runat="server" />
        <asp:Button ID="btnDeleteReward" runat="server" CssClass="d-none" OnClick="BtnDeleteReward_Click" CausesValidation="false" />
        <asp:HiddenField ID="hidEditRewardIdTrigger" runat="server" />
        <asp:Button ID="btnEditRewardTrigger" runat="server" CssClass="d-none" OnClick="BtnEditRewardTrigger_Click" CausesValidation="false" />
        <asp:HiddenField ID="hidImageSelect" runat="server" />
        <asp:Button ID="btnImageSelect" runat="server" CssClass="d-none" OnClick="BtnImageSelect_Click" CausesValidation="false" />

        <%-- Create Plan (if none exists) --%>
        <asp:Panel ID="pnlCreatePlan" runat="server" Visible="false">
            <div class="pd-empty"><i class="bi bi-journal-x"></i>
                <p><asp:Literal ID="litCreatePlanMsg" runat="server" /></p>
                <asp:Button ID="btnCreatePlan" runat="server" CssClass="pt-btn primary" style="margin-top:14px;" OnClick="BtnCreatePlan_Click" CausesValidation="false" />
            </div>
        </asp:Panel>

    </asp:Panel>
</div>
</asp:Content>
