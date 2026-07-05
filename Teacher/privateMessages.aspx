<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="privateMessages.aspx.cs"
    Inherits="ScienceBuddy.Teacher.privateMessages" MasterPageFile="~/Site.Master"
    Title="Private Messages" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--tp:#6C63FF;--tp2:#8B5CF6;--th:#5A52E0;--tl:#F5F3FF;--tc:#FFF;--tb:#E5E7EB;--tt:#374151;--tm:#6B7280;--ts:#10B981;--te:#EF4444;}
.pm-wrap{display:grid;grid-template-columns:320px 1fr;gap:0;height:calc(100vh - 160px);min-height:500px;background:var(--tc);border:1.5px solid var(--tb);border-radius:16px;overflow:hidden;box-shadow:0 2px 12px rgba(0,0,0,.04);}
.pm-left{border-right:1.5px solid var(--tb);display:flex;flex-direction:column;overflow:hidden;}
.pm-left-header{padding:1rem 1.25rem;border-bottom:1px solid var(--tb);}
.pm-search-wrap{position:relative;}.pm-search-wrap i{position:absolute;left:12px;top:50%;transform:translateY(-50%);color:var(--tm);font-size:.9rem;pointer-events:none;}
.pm-search{width:100%;height:44px;border-radius:12px;border:1.5px solid var(--tb);padding:0 .75rem 0 2.2rem;font-size:.82rem;background:var(--tc);transition:border-color .2s,box-shadow .2s;}
.pm-search:focus{border-color:var(--tp);outline:none;box-shadow:0 0 0 3px rgba(108,99,255,.08);}
.pm-compose-btn{display:flex;align-items:center;justify-content:center;width:44px;height:44px;border-radius:12px;background:linear-gradient(135deg,var(--tp),var(--tp2));color:#fff;font-size:1.1rem;text-decoration:none;cursor:pointer;transition:transform .15s,box-shadow .15s;box-shadow:0 2px 8px rgba(108,99,255,.2);flex-shrink:0;}
.pm-compose-btn:hover{transform:translateY(-2px);box-shadow:0 6px 18px rgba(108,99,255,.3);color:#fff;text-decoration:none;}
.pm-compose-btn:active{transform:translateY(0);background:linear-gradient(135deg,var(--th),var(--tp));}
.pm-tabs{display:flex;gap:0;margin-top:.75rem;border:1.5px solid var(--tb);border-radius:8px;overflow:hidden;}
.pm-tab{flex:1;padding:.4rem;font-size:.72rem;font-weight:600;text-align:center;border:none;background:var(--tc);color:var(--tm);cursor:pointer;transition:all .15s;}
.pm-tab.active{background:var(--tp);color:#fff;}
.pm-list{flex:1;overflow-y:auto;padding:.5rem;}
.pm-conv{display:flex;align-items:center;gap:10px;padding:.7rem .75rem;border-radius:12px;cursor:pointer;transition:all .15s;border:1.5px solid transparent;}
.pm-conv:hover{background:var(--tl);border-color:#EDE9FE;}
.pm-conv.active{background:#EDE9FE;border-color:var(--tp);}
.pm-conv-avatar{width:38px;height:38px;border-radius:50%;background:#EDE9FE;color:var(--tp);display:flex;align-items:center;justify-content:center;font-size:.8rem;font-weight:700;flex-shrink:0;}
.pm-conv-info{flex:1;min-width:0;}
.pm-conv-name{font-size:.82rem;font-weight:700;color:var(--tt);display:flex;align-items:center;gap:6px;}
.pm-conv-role{font-size:.6rem;font-weight:700;padding:1px 6px;border-radius:4px;background:#DBEAFE;color:#1D4ED8;}
.pm-conv-role.parent{background:#FEF3C7;color:#92400E;}
.pm-conv-preview{font-size:.74rem;color:var(--tm);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;margin-top:2px;}
.pm-conv-time{font-size:.66rem;color:var(--tm);white-space:nowrap;}
.pm-unread{width:8px;height:8px;border-radius:50%;background:var(--tp);flex-shrink:0;}
/* Right panel */
.pm-right{display:flex;flex-direction:column;overflow:hidden;}
.pm-chat-header{padding:.85rem 1.25rem;border-bottom:1px solid var(--tb);display:flex;align-items:center;gap:12px;}
.pm-chat-avatar{width:36px;height:36px;border-radius:50%;background:#EDE9FE;color:var(--tp);display:flex;align-items:center;justify-content:center;font-size:.8rem;font-weight:700;}
.pm-chat-name{font-size:.9rem;font-weight:700;color:var(--tt);}
.pm-chat-role{font-size:.7rem;color:var(--tm);}
.pm-messages{flex:1;overflow-y:auto;padding:1.25rem;display:flex;flex-direction:column;gap:.75rem;}
.pm-msg{max-width:75%;display:flex;flex-direction:column;}
.pm-msg.sent{align-self:flex-end;align-items:flex-end;}
.pm-msg.received{align-self:flex-start;align-items:flex-start;}
.pm-bubble{padding:.6rem 1rem;border-radius:14px;font-size:.84rem;line-height:1.5;word-break:break-word;}
.pm-msg.sent .pm-bubble{background:linear-gradient(135deg,var(--tp),var(--tp2));color:#fff;border-bottom-right-radius:4px;}
.pm-msg.received .pm-bubble{background:#F3F4F6;color:var(--tt);border-bottom-left-radius:4px;}
.pm-msg-time{font-size:.66rem;color:var(--tm);margin-top:3px;}
.pm-msg-attach{font-size:.76rem;color:var(--tp);text-decoration:none;display:flex;align-items:center;gap:4px;margin-top:4px;}
.pm-input-area{padding:.85rem 1.25rem;border-top:1px solid var(--tb);display:flex;gap:.6rem;align-items:center;}
.pm-input{flex:1;border-radius:10px;border:1.5px solid var(--tb);padding:.55rem .8rem;font-size:.84rem;resize:none;min-height:38px;max-height:80px;transition:border-color .2s;}
.pm-input:focus{border-color:var(--tp);outline:none;}
.pm-send-btn{width:38px;height:38px;border-radius:50%;background:linear-gradient(135deg,var(--tp),var(--tp2));border:none;color:#fff;display:flex;align-items:center;justify-content:center;cursor:pointer;transition:transform .15s,box-shadow .15s;box-shadow:0 2px 8px rgba(108,99,255,.2);}
.pm-send-btn:hover{transform:scale(1.08);box-shadow:0 4px 14px rgba(108,99,255,.3);}
.pm-empty{display:flex;flex-direction:column;align-items:center;justify-content:center;height:100%;color:var(--tm);text-align:center;padding:2rem;}
.pm-empty i{font-size:2.5rem;opacity:.4;margin-bottom:.75rem;}
.pm-empty p{font-size:.88rem;font-weight:600;}
.pm-val{font-size:.72rem;color:var(--te);padding:0 1.25rem;display:none;}
.pm-val.show{display:block;}
/* New button */
.pm-new-btn{display:inline-flex;align-items:center;gap:4px;padding:.4rem .7rem;border-radius:8px;border:1.5px solid var(--tp);background:var(--tl);color:var(--tp);font-size:.72rem;font-weight:700;cursor:pointer;transition:all .15s;white-space:nowrap;}
.pm-new-btn:hover{background:var(--tp);color:#fff;}
.pm-compose-select{border-radius:8px;border:1.5px solid var(--tb);padding:.35rem .6rem;font-size:.82rem;background:var(--tc);transition:border-color .2s;min-width:100px;}
.pm-compose-select:focus{border-color:var(--tp);outline:none;}
/* Modal */
.pm-modal-overlay{position:fixed;inset:0;background:rgba(17,24,39,.5);z-index:9000;display:flex;align-items:center;justify-content:center;padding:1rem;}
.pm-modal{background:#fff;border-radius:16px;width:100%;max-width:440px;box-shadow:0 20px 60px rgba(0,0,0,.2);animation:pmFade .2s ease;}
@keyframes pmFade{from{opacity:0;transform:translateY(10px);}to{opacity:1;transform:translateY(0);}}
.pm-modal-header{display:flex;align-items:center;justify-content:space-between;padding:1.25rem 1.5rem;border-bottom:1px solid var(--tb);}
.pm-modal-header h3{font-size:1rem;font-weight:800;color:var(--tt);margin:0;}
.pm-modal-close{background:none;border:none;font-size:1.4rem;color:var(--tm);cursor:pointer;}.pm-modal-close:hover{color:var(--tt);}
.pm-modal-body{padding:1.25rem 1.5rem;}
.pm-modal-footer{display:flex;gap:.75rem;justify-content:flex-end;padding:1rem 1.5rem;border-top:1px solid var(--tb);}
.pm-mfield{margin-bottom:1rem;}.pm-mlabel{font-size:.78rem;font-weight:600;color:var(--tt);display:block;margin-bottom:4px;}
.pm-minput{width:100%;border-radius:10px;border:1.5px solid var(--tb);padding:.55rem .75rem;font-size:.84rem;transition:border-color .2s;}.pm-minput:focus{border-color:var(--tp);outline:none;}
.pm-mbtn-cancel{background:#fff;border:1.5px solid var(--tb);border-radius:10px;padding:.5rem 1rem;font-weight:600;font-size:.82rem;color:var(--tt);cursor:pointer;}
.pm-mbtn-primary{background:linear-gradient(135deg,var(--tp),var(--tp2));border:none;border-radius:10px;padding:.5rem 1.25rem;font-weight:700;font-size:.82rem;color:#fff;cursor:pointer;transition:box-shadow .2s;}
.pm-mbtn-primary:hover{box-shadow:0 4px 14px rgba(108,99,255,.3);}
@media(max-width:768px){.pm-wrap{grid-template-columns:1fr;height:auto;}.pm-left{max-height:300px;}}
</style>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Teaching","Pengajaran") %></div>
        <a href="<%: ResolveUrl("~/Teacher/manageMaterials.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label"><%: T("Manage Materials","Bahan Pembelajaran") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label"><%: T("Manage Quiz","Kuiz") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/studentProgress.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bar-chart item-icon"></i><span class="item-label"><%: T("Student Progress","Prestasi Pelajar") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/liveSession.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label"><%: T("Schedule Live Class","Kelas Langsung") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Community","Komuniti") %></div>
        <a href="<%: ResolveUrl("~/Teacher/forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/privateMessages.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-envelope item-icon"></i><span class="item-label"><%: T("Private Message","Mesej Peribadi") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Account","Akaun") %></div>
        <a href="<%: ResolveUrl("~/Teacher/MyProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("My Profile","Profil Saya") %></span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Sign Out","Log Keluar") %></span></a></div>
</asp:Content>
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Private Messages","Mesej Peribadi") %></asp:Content>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="pm-wrap">

<%-- Left: Conversation List --%>
<div class="pm-left">
    <div class="pm-left-header">
        <div style="display:flex;align-items:center;gap:10px;margin-bottom:.6rem;">
            <div class="pm-search-wrap" style="flex:1;"><i class="bi bi-search"></i>
                <asp:TextBox ID="txtSearchConv" runat="server" CssClass="pm-search" placeholder="Search conversations..." AutoPostBack="true" OnTextChanged="btnFilter_Click" /></div>
            <asp:LinkButton ID="btnCompose" runat="server" CssClass="pm-compose-btn" OnClick="btnCompose_Click" CausesValidation="false" ToolTip="New Message">
                <i class="bi bi-pencil-square"></i>
            </asp:LinkButton>
        </div>
        <div class="pm-tabs">
            <asp:Button ID="btnAll" runat="server" Text="All" CssClass="pm-tab active" OnClick="btnFilter_Click" CommandArgument="All" CausesValidation="false" />
            <asp:Button ID="btnStudents" runat="server" Text="Students" CssClass="pm-tab" OnClick="btnFilter_Click" CommandArgument="Student" CausesValidation="false" />
            <asp:Button ID="btnParents" runat="server" Text="Parents" CssClass="pm-tab" OnClick="btnFilter_Click" CommandArgument="Parent" CausesValidation="false" />
        </div>
    </div>
    <div class="pm-list">
        <asp:Panel ID="pnlNoConvs" runat="server" Visible="false">
            <div class="pm-empty"><i class="bi bi-chat-square-text"></i><p><%: T("No private messages yet.","Tiada mesej peribadi lagi.") %></p></div>
        </asp:Panel>
        <asp:Repeater ID="rptConvs" runat="server" OnItemCommand="rptConvs_ItemCommand">
            <ItemTemplate>
                <div class='pm-conv <%# Eval("chatId").ToString() == SelectedChatId ? "active" : "" %>'>
                    <asp:LinkButton ID="lnkConv" runat="server" CommandName="Select" CommandArgument='<%# Eval("chatId") %>' CausesValidation="false" style="display:contents;">
                        <div class="pm-conv-avatar"><%# Eval("initials") %></div>
                        <div class="pm-conv-info">
                            <div class="pm-conv-name"><%# HttpUtility.HtmlEncode(Eval("name")) %> <span class='pm-conv-role <%# Eval("role").ToString()=="Parent"?"parent":"" %>'><%# Eval("role") %></span></div>
                            <div class="pm-conv-preview"><%# HttpUtility.HtmlEncode(Eval("lastMsg")) %></div>
                        </div>
                        <div style="display:flex;flex-direction:column;align-items:flex-end;gap:4px;">
                            <span class="pm-conv-time"><%# Eval("timeAgo") %></span>
                            <%# Convert.ToInt32(Eval("unreadCount")) > 0 ? "<span class='pm-unread'></span>" : "" %>
                        </div>
                    </asp:LinkButton>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</div>

<%-- Right: Chat --%>
<div class="pm-right">
    <asp:Panel ID="pnlNoChat" runat="server" Visible="true">
        <div class="pm-empty"><i class="bi bi-chat-left-text"></i><p><%: T("Select a conversation to start messaging.","Pilih perbualan untuk mula menghantar mesej.") %></p></div>
    </asp:Panel>

    <%-- Compose Mode --%>
    <asp:Panel ID="pnlCompose" runat="server" Visible="false">
        <div class="pm-chat-header" style="border-bottom:1px solid var(--tb);">
            <div style="display:flex;align-items:center;gap:8px;flex:1;">
                <span style="font-size:.82rem;font-weight:700;color:var(--tm);"><%: T("To:","Kepada:") %></span>
                <asp:DropDownList ID="ddlRecipientType" runat="server" CssClass="pm-compose-select" AutoPostBack="true" OnSelectedIndexChanged="ddlRecipientType_Changed">
                    <asp:ListItem Value="" Text="— Type —" />
                    <asp:ListItem Value="Student" Text="Student" />
                    <asp:ListItem Value="Parent" Text="Parent" />
                </asp:DropDownList>
                <asp:DropDownList ID="ddlRecipient" runat="server" CssClass="pm-compose-select" style="flex:1;" />
            </div>
        </div>
        <div class="pm-messages">
            <div class="pm-empty" style="padding:3rem;">
                <i class="bi bi-pencil-square" style="font-size:2.5rem;opacity:.3;color:var(--tp);"></i>
                <p style="margin-top:.75rem;"><%: T("You're starting a new conversation","Anda memulakan perbualan baharu") %></p>
                <span style="font-size:.78rem;color:var(--tm);"><%: T("Type your first message below.","Taip mesej pertama anda di bawah.") %></span>
            </div>
        </div>
        <asp:Panel ID="pnlComposeVal" runat="server" Visible="false">
            <div style="font-size:.74rem;color:var(--te);padding:0 1.25rem .5rem;font-weight:600;"><asp:Literal ID="litComposeError" runat="server" /></div>
        </asp:Panel>
        <div class="pm-input-area">
            <asp:TextBox ID="txtComposeMsg" runat="server" CssClass="pm-input" TextMode="MultiLine" Rows="1" placeholder="Type a message..." />
            <asp:Button ID="btnComposeSend" runat="server" CssClass="pm-send-btn" Text="›" OnClick="btnComposeSend_Click" CausesValidation="false" />
        </div>
    </asp:Panel>

    <%-- Normal Chat --%>
    <asp:Panel ID="pnlChat" runat="server" Visible="false">
        <div class="pm-chat-header">
            <div class="pm-chat-avatar"><asp:Literal ID="litChatInitials" runat="server" /></div>
            <div><div class="pm-chat-name"><asp:Literal ID="litChatName" runat="server" /></div>
                <div class="pm-chat-role"><asp:Literal ID="litChatRole" runat="server" /></div></div>
        </div>
        <div class="pm-messages" id="msgArea">
            <asp:Repeater ID="rptMessages" runat="server">
                <ItemTemplate>
                    <div class='pm-msg <%# Eval("isSent").ToString()=="True"?"sent":"received" %>'>
                        <div class="pm-bubble"><%# HttpUtility.HtmlEncode(Eval("msgText")) %></div>
                        <%# Eval("attachmentFile")!=null && Eval("attachmentFile").ToString()!="" ? "<a href='"+ResolveUrl("~/"+Eval("attachmentFile"))+"' target='_blank' class='pm-msg-attach'><i class='bi bi-paperclip'></i> Attachment</a>" : "" %>
                        <div class="pm-msg-time"><%# Eval("timeStr") %></div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
            <asp:Panel ID="pnlNoMessages" runat="server" Visible="false">
                <div class="pm-empty" style="padding:2rem;"><i class="bi bi-chat"></i><p><%: T("No messages yet. Send the first message.","Tiada mesej lagi. Hantar mesej pertama.") %></p></div>
            </asp:Panel>
        </div>
        <div class="pm-val" id="valMsg"></div>
        <div class="pm-input-area">
            <asp:TextBox ID="txtMessage" runat="server" CssClass="pm-input" TextMode="MultiLine" Rows="1" placeholder="Type your message..." />
            <asp:Button ID="btnSend" runat="server" CssClass="pm-send-btn" Text="›" OnClick="btnSend_Click" CausesValidation="false" />
        </div>
    </asp:Panel>
</div>

</div>

<%-- New Conversation Modal removed - using inline compose mode --%>

<asp:HiddenField ID="hidSelectedChat" runat="server" Value="" />
</asp:Content>
<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
window.addEventListener('load',function(){var m=document.getElementById('msgArea');if(m)m.scrollTop=m.scrollHeight;});
</script>
</asp:Content>
