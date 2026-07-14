<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ParentTeacherCommunication.aspx.cs"
    Inherits="ScienceBuddy.Parent.ParentTeacherCommunication" MasterPageFile="~/Site.Master"
    Title="Messages" MaintainScrollPositionOnPostback="true" %>

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
    <div class="pt-child-selector">
        <div class="pt-child-selector-label"><%: T("Viewing Child","Anak Dilihat") %></div>
        <div class="pt-child-selector-full"><asp:DropDownList ID="ddlSidebarChild" runat="server" CssClass="sb-sidebar-child-ddl" /></div>
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
        <a href="<%: ResolveUrl("~/Parent/ParentTeacherCommunication.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Chat with Teachers","Sembang dengan Guru") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/Forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-people item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Profile","Profil") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("My Profile","Profil Saya") %></span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Logout","Log Keluar") %></span></a></div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Messages","Mesej") %></asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="pd-page">

    <%-- Message Popup --%>
    <asp:Panel ID="pnlMsg" runat="server" Visible="false"><div class="pt-success-popup-overlay"><div class="pt-success-popup"><div class="pt-success-popup-icon"><i class="bi" id="iMsgIcon" runat="server"></i></div><div class="pt-success-popup-text" id="divMsg" runat="server"></div><asp:Button ID="btnCloseMsg" runat="server" Text="X" CssClass="pt-success-popup-close" OnClick="BtnCloseMsg_Click" CausesValidation="false" /></div></div></asp:Panel>

    <%-- Header --%>
    <div class="pt-messages-header">
        <h2><i class="bi bi-chat-dots-fill"></i> <%: T("Messages","Mesej") %></h2>
        <p><%: T("Chat privately with teachers for learning support.","Berbual secara peribadi dengan guru untuk sokongan pembelajaran.") %></p>
    </div>

    <%-- Tabs --%>
    <div class="pt-message-tabs">
        <asp:LinkButton ID="lnkMyChats" runat="server" CssClass="pt-message-tab pt-message-tab-active" OnClick="TabMyChats_Click" CausesValidation="false"><%: T("My Chats","Sembang Saya") %></asp:LinkButton>
        <asp:LinkButton ID="lnkTeachers" runat="server" CssClass="pt-message-tab" OnClick="TabTeachers_Click" CausesValidation="false"><%: T("Teachers","Guru") %></asp:LinkButton>
    </div>

    <%-- ══ MY CHATS TAB ══ --%>
    <asp:Panel ID="pnlMyChats" runat="server">
        <div class="pt-chat-workspace">
            <%-- Left: Chat list --%>
            <div class="pt-chat-sidebar">
                <asp:TextBox ID="txtChatSearch" runat="server" CssClass="pt-chat-search" placeholder="Search conversations..." AutoPostBack="true" OnTextChanged="ChatSearch_Changed" />
                <asp:Panel ID="pnlChatList" runat="server" CssClass="pt-chat-list"></asp:Panel>
                <asp:Panel ID="pnlNoChatList" runat="server" Visible="false"><div class="pt-empty-state"><i class="bi bi-chat-square-dots"></i><p><%: T("No conversations yet.","Tiada perbualan lagi.") %></p></div></asp:Panel>
            </div>
            <%-- Right: Chat main --%>
            <div class="pt-chat-main">
                <asp:Panel ID="pnlChatHeader" runat="server" Visible="false" CssClass="pt-chat-header">
                    <div class="pt-chat-avatar"><asp:Literal ID="litChatInitial" runat="server" /></div>
                    <div><strong><asp:Literal ID="litChatTeacherName" runat="server" /></strong><br/><small><asp:Literal ID="litChatQualification" runat="server" /></small></div>
                </asp:Panel>
                <asp:Panel ID="pnlChatBody" runat="server" CssClass="pt-chat-body"></asp:Panel>
                <asp:Panel ID="pnlNoChat" runat="server" Visible="false"><div class="pt-empty-state" style="padding:60px 20px;"><i class="bi bi-chat-left-text"></i><p><%: T("Select a conversation to start chatting.","Pilih perbualan untuk mula berbual.") %></p><div class="pt-empty-helper"><%: T("Choose a teacher from your chat list or start a new conversation.","Pilih guru dari senarai sembang atau mulakan perbualan baharu.") %></div></div></asp:Panel>
                <%-- Composer --%>
                <asp:Panel ID="pnlComposer" runat="server" Visible="false">
                    <%-- Selected attachment preview --%>
                    <div class="pt-selected-attachment" id="divAttachPreview">
                        <div class="pt-selected-attachment-thumb" id="divAttachThumb"></div>
                        <div class="pt-selected-attachment-info">
                            <div class="pt-selected-attachment-name" id="spanAttachName"></div>
                            <div class="pt-selected-attachment-meta" id="spanAttachMeta"></div>
                        </div>
                        <button type="button" class="pt-selected-attachment-remove" id="btnRemoveAttach" onclick="clearAttachment();">&times;</button>
                    </div>
                    <div class="pt-chat-composer">
                        <div class="pt-file-upload-wrap">
                            <div class="pt-file-upload-btn"><i class="bi bi-paperclip"></i></div>
                            <asp:FileUpload ID="fuAttachment" runat="server" onchange="previewAttachment(this);" />
                        </div>
                        <asp:TextBox ID="txtMessage" runat="server" CssClass="pt-chat-input" placeholder="Type your message..." />
                        <asp:Button ID="btnSend" runat="server" CssClass="pt-chat-send-btn" OnClick="BtnSend_Click" CausesValidation="false" />
                    </div>
                </asp:Panel>
                <script type="text/javascript">
                    var imageExts = ['.png','.jpg','.jpeg','.gif','.webp'];
                    var docExts = ['.pdf','.doc','.docx','.ppt','.pptx','.xls','.xlsx','.txt'];
                    var maxSize = 5*1024*1024;
                    function previewAttachment(input) {
                        var preview = document.getElementById('divAttachPreview');
                        var thumb = document.getElementById('divAttachThumb');
                        var nameEl = document.getElementById('spanAttachName');
                        var metaEl = document.getElementById('spanAttachMeta');
                        if (!input.files || !input.files[0]) { preview.classList.remove('pt-selected-attachment-visible'); return; }
                        var file = input.files[0];
                        var ext = '.' + file.name.split('.').pop().toLowerCase();
                        var isImage = imageExts.indexOf(ext) !== -1;
                        var isDoc = docExts.indexOf(ext) !== -1;
                        if (!isImage && !isDoc) { alert('<%: T("This file type is not allowed.","Jenis fail ini tidak dibenarkan.") %>'); input.value=''; preview.classList.remove('pt-selected-attachment-visible'); return; }
                        if (file.size > maxSize) { alert('<%: T("File size must not exceed 5 MB.","Saiz fail tidak boleh melebihi 5 MB.") %>'); input.value=''; preview.classList.remove('pt-selected-attachment-visible'); return; }
                        nameEl.textContent = file.name.length > 30 ? file.name.substring(0,27) + '...' : file.name;
                        var sizeStr = file.size < 1024 ? file.size + ' B' : file.size < 1048576 ? (file.size/1024).toFixed(1) + ' KB' : (file.size/1048576).toFixed(1) + ' MB';
                        metaEl.textContent = ext.replace('.','').toUpperCase() + ' \u2022 ' + sizeStr;
                        thumb.innerHTML = '';
                        if (isImage) { var url = URL.createObjectURL(file); thumb.innerHTML = '<img src="'+url+'" alt="preview"/>'; }
                        else { thumb.innerHTML = '<i class="bi bi-file-earmark-text"></i>'; }
                        preview.classList.add('pt-selected-attachment-visible');
                    }
                    function clearAttachment() {
                        var preview = document.getElementById('divAttachPreview');
                        preview.classList.remove('pt-selected-attachment-visible');
                        var fu = document.querySelector('.pt-file-upload-wrap input[type="file"]');
                        if (fu) { fu.value = ''; }
                    }
                </script>
            </div>
        </div>
        <asp:HiddenField ID="hidSelectedChat" runat="server" />
        <asp:Button ID="btnSelectChat" runat="server" CssClass="d-none" OnClick="BtnSelectChat_Click" CausesValidation="false" />
    </asp:Panel>

    <%-- ══ TEACHERS TAB ══ --%>
    <asp:Panel ID="pnlTeachers" runat="server" Visible="false">
        <asp:Panel ID="pnlTeacherGrid" runat="server" CssClass="pt-teacher-grid"></asp:Panel>
        <asp:Panel ID="pnlNoTeachers" runat="server" Visible="false"><div class="pt-empty-state"><i class="bi bi-person-x"></i><p><%: T("No certified teachers available.","Tiada guru yang disahkan tersedia.") %></p></div></asp:Panel>
        <asp:HiddenField ID="hidStartChatTeacher" runat="server" />
        <asp:Button ID="btnStartChat" runat="server" CssClass="d-none" OnClick="BtnStartChat_Click" CausesValidation="false" />
    </asp:Panel>

</div>
</asp:Content>
