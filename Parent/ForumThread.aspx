<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ForumThread.aspx.cs"
    Inherits="ScienceBuddy.Parent.ForumThread" MasterPageFile="~/Site.Master"
    Title="Forum Thread" MaintainScrollPositionOnPostback="true" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Parent.css") %>?v=6" rel="stylesheet" />
<script type="text/javascript">
function toggleChildPopover(e){e.stopPropagation();var pop=document.getElementById('divChildPopover');if(!pop)return;if(pop.classList.contains('pt-popover-open')){pop.classList.remove('pt-popover-open');return;}var ddl=document.querySelector('.sb-sidebar-child-ddl');if(!ddl)return;var html='<div class="pt-child-popover-title">Select Child</div>';for(var i=0;i<ddl.options.length;i++){var o=ddl.options[i];var init=o.text.charAt(0).toUpperCase();var ac=o.selected?' pt-popover-active':'';html+='<div class="pt-child-popover-item'+ac+'" onclick="selectChildFromPopover(\''+o.value+'\')"><span class="pt-popover-avatar">'+init+'</span>'+o.text+'</div>';}pop.innerHTML=html;pop.classList.add('pt-popover-open');}
function selectChildFromPopover(v){var ddl=document.querySelector('.sb-sidebar-child-ddl');if(ddl&&ddl.value!==v){ddl.value=v;__doPostBack(ddl.id.replace(/_/g,'$'),'');}var pop=document.getElementById('divChildPopover');if(pop)pop.classList.remove('pt-popover-open');}
document.addEventListener('DOMContentLoaded',function(){var ddl=document.querySelector('.sb-sidebar-child-ddl');var btn=document.querySelector('.pt-child-compact-btn');if(ddl&&btn&&ddl.options.length>0){btn.textContent=ddl.options[ddl.selectedIndex].text.charAt(0).toUpperCase();}});
document.addEventListener('click',function(e){var pop=document.getElementById('divChildPopover');if(pop&&!e.target.closest('.pt-child-selector-compact')){pop.classList.remove('pt-popover-open');}});
</script>
</asp:Content>
<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="pt-child-selector">
        <div class="pt-child-selector-label"><%: T("Viewing Child","Anak Dilihat") %></div>
        <div class="pt-child-selector-full"><asp:DropDownList ID="ddlSidebarChild2" runat="server" CssClass="sb-sidebar-child-ddl" /></div>
        <div class="pt-child-selector-compact"><button type="button" class="pt-child-compact-btn" onclick="toggleChildPopover(event);"></button><div class="pt-child-popover" id="divChildPopover"></div></div>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentDashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/ParentNotifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label"><%: T("Notifications","Notifikasi") %></span></a></div>
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
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Forum Thread","Hantaran Forum") %></asp:Content>
<asp:Content ID="cBody" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="pd-page">
    <asp:Panel ID="pnlMessage" runat="server" Visible="false"><div class="pt-success-popup-overlay"><div class="pt-success-popup"><div class="pt-success-popup-icon"><i class="bi" id="iMsgIcon" runat="server"></i></div><div class="pt-success-popup-text" id="divMsg" runat="server"></div><asp:Button ID="btnCloseMsg" runat="server" Text="X" CssClass="pt-success-popup-close" OnClick="BtnCloseMsg_Click" CausesValidation="false" /></div></div></asp:Panel>

    <a href="<%: ResolveUrl("~/Parent/Forum.aspx") %>" class="pt-btn soft" style="margin-bottom:16px;display:inline-flex;"><i class="bi bi-arrow-left"></i> <%: T("Back to Forum","Kembali ke Forum") %></a>

    <asp:Panel ID="pnlThread" runat="server" Visible="false">
        <div class="pt-forum-detail-card">
            <div style="display:flex;align-items:center;gap:12px;margin-bottom:12px;">
                <span class="pt-forum-avatar" style="width:40px;height:40px;font-size:0.9rem;"><asp:Literal ID="litAuthorInitial" runat="server" /></span>
                <div>
                    <span class="pt-forum-username"><asp:Literal ID="litAuthorName" runat="server" /></span>
                    <span class="pt-forum-date">&bull; <asp:Literal ID="litDate" runat="server" /></span>
                    <asp:Literal ID="litTypeBadge" runat="server" />
                </div>
            </div>
            <h2 class="pt-forum-title" style="font-size:1.3rem;"><asp:Literal ID="litTitle" runat="server" /></h2>
            <div style="font-size:0.9rem;color:#334155;line-height:1.6;margin:12px 0;"><asp:Literal ID="litMessage" runat="server" /></div>
            <asp:Panel ID="pnlTags" runat="server" style="margin-bottom:12px;"></asp:Panel>
            <div class="pt-forum-stats" style="font-size:0.85rem;">
                <asp:LinkButton ID="btnLike" runat="server" OnClick="BtnLike_Click" CausesValidation="false" CssClass="pt-forum-like-btn"><i class="bi bi-heart"></i> <asp:Literal ID="litLikeCount" runat="server" /></asp:LinkButton>
                <span><i class="bi bi-chat"></i> <asp:Literal ID="litReplyCount" runat="server" /></span>
            </div>
            <%-- Owner actions --%>
            <asp:Panel ID="pnlOwnerActions" runat="server" Visible="false" style="margin-top:14px;display:flex;gap:10px;">
                <a href="" id="lnkEdit" runat="server" class="pt-btn soft" style="font-size:0.8rem;"><i class="bi bi-pencil"></i> <%: T("Edit","Edit") %></a>
                <button type="button" class="pt-btn soft" style="font-size:0.8rem;color:#DC2626;border-color:#FECACA;" onclick="document.getElementById('deleteThreadModal').style.display='flex';return false;"><i class="bi bi-trash"></i> <%: T("Delete","Padam") %></button>
            </asp:Panel>
        </div>

        <%-- Delete Modal --%>
        <div class="pt-delete-modal-overlay" id="deleteThreadModal" style="display:none;">
            <div class="pt-delete-modal"><div class="pt-delete-modal-icon"><i class="bi bi-exclamation-triangle-fill"></i></div>
                <div class="pt-delete-modal-title"><%: T("Delete Discussion?","Padam Perbincangan?") %></div>
                <div class="pt-delete-modal-msg"><%: T("This will permanently remove this discussion, all replies, likes, and tags.","Ini akan membuang perbincangan ini, semua balasan, suka, dan tag secara kekal.") %></div>
                <div class="pt-delete-modal-actions">
                    <button type="button" class="pt-btn soft" onclick="document.getElementById('deleteThreadModal').style.display='none';return false;"><%: T("Cancel","Batal") %></button>
                    <asp:Button ID="btnDeleteThread" runat="server" CssClass="pt-btn danger" OnClick="BtnDeleteThread_Click" CausesValidation="false" />
                </div>
            </div>
        </div>

        <%-- Replies --%>
        <div class="pt-quiz-section-title" style="margin-top:24px;"><i class="bi bi-chat-left-text"></i> <%: T("Replies","Balasan") %></div>
        <asp:Panel ID="pnlReplies" runat="server"></asp:Panel>
        <asp:Panel ID="pnlNoReplies" runat="server" Visible="false"><div class="pt-no-data"><%: T("No replies yet.","Belum ada balasan.") %></div></asp:Panel>

        <%-- Reply form --%>
        <div class="pt-profile-section" style="margin-top:16px;">
            <div class="pt-field"><label class="pt-label"><%: T("Write a reply","Tulis balasan") %></label><asp:TextBox ID="txtReply" runat="server" CssClass="pt-input" TextMode="MultiLine" Rows="3" /></div>
            <asp:Button ID="btnReply" runat="server" CssClass="pt-btn primary" OnClick="BtnReply_Click" CausesValidation="false" />
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlNotFound" runat="server" Visible="false"><div class="pd-empty"><i class="bi bi-emoji-frown"></i><p><%: T("Discussion not found.","Perbincangan tidak ditemui.") %></p></div></asp:Panel>
</div>
</asp:Content>
