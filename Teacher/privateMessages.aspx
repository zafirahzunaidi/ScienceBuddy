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
.pm-search{width:100%;height:44px;border-radius:12px;border:1.5px solid var(--tb);padding:0 .75rem 0 2.2rem;font-size:.86rem;background:var(--tc);transition:border-color .2s,box-shadow .2s;}
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
.pm-conv-name{font-size:.88rem;font-weight:700;color:var(--tt);display:flex;align-items:center;gap:6px;}
.pm-conv-role{font-size:.6rem;font-weight:700;padding:1px 6px;border-radius:4px;background:#DBEAFE;color:#1D4ED8;}
.pm-conv-role.parent{background:#FEF3C7;color:#92400E;}
.pm-conv-preview{font-size:.8rem;color:var(--tm);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;margin-top:2px;}
.pm-conv-time{font-size:.66rem;color:var(--tm);white-space:nowrap;}
.pm-unread{width:8px;height:8px;border-radius:50%;background:var(--tp);flex-shrink:0;}
/* Right panel */
.pm-right{display:flex;flex-direction:column;overflow:hidden;height:100%;}
.pm-chat-header{padding:.85rem 1.25rem;border-bottom:1px solid var(--tb);display:flex;align-items:center;gap:12px;flex-shrink:0;}
.pm-chat-avatar{width:36px;height:36px;border-radius:50%;background:#EDE9FE;color:var(--tp);display:flex;align-items:center;justify-content:center;font-size:.8rem;font-weight:700;}
.pm-chat-name{font-size:.9rem;font-weight:700;color:var(--tt);}
.pm-chat-role{font-size:.7rem;color:var(--tm);}
.pm-messages{flex:1;overflow-y:auto;padding:1.25rem;display:flex;flex-direction:column;gap:.75rem;min-height:0;}
.pm-msg{max-width:75%;display:flex;flex-direction:column;}
.pm-msg.sent{align-self:flex-end;align-items:flex-end;}
.pm-msg.received{align-self:flex-start;align-items:flex-start;}
.pm-bubble{padding:.6rem 1rem;border-radius:14px;font-size:.9rem;line-height:1.55;word-break:break-word;}
.pm-msg.sent .pm-bubble{background:linear-gradient(135deg,var(--tp),var(--tp2));color:#fff;border-bottom-right-radius:4px;}
.pm-msg.received .pm-bubble{background:#F3F4F6;color:var(--tt);border-bottom-left-radius:4px;}
.pm-msg-time{font-size:.66rem;color:var(--tm);margin-top:3px;display:flex;align-items:center;gap:4px;}
.pm-tick{font-size:.75rem;}.pm-tick.read{color:var(--tp);font-weight:800;}.pm-tick.sent{color:#9CA3AF;font-weight:400;}
.pm-msg-attach{font-size:.76rem;color:var(--tp);text-decoration:none;display:flex;align-items:center;gap:4px;margin-top:4px;}
/* Composer bottom section */
.pm-composer-bottom{flex-shrink:0;background:var(--tc);position:relative;}
.pm-input-area{padding:.75rem 1.25rem;border-top:1px solid var(--tb);display:flex;gap:.5rem;align-items:center;background:var(--tc);}
.pm-input{flex:1;border-radius:10px;border:1.5px solid var(--tb);padding:.55rem .8rem;font-size:.88rem;resize:none;min-height:38px;max-height:80px;transition:border-color .2s;min-width:0;}
.pm-input:focus{border-color:var(--tp);outline:none;}
.pm-send-btn{width:38px;height:38px;border-radius:50%;background:linear-gradient(135deg,var(--tp),var(--tp2));border:none;color:#fff;display:flex;align-items:center;justify-content:center;cursor:pointer;transition:transform .15s,box-shadow .15s;box-shadow:0 2px 8px rgba(108,99,255,.2);flex-shrink:0;text-decoration:none;}
.pm-send-btn:hover{transform:scale(1.08);box-shadow:0 4px 14px rgba(108,99,255,.3);color:#fff;text-decoration:none;}
.pm-empty{display:flex;flex-direction:column;align-items:center;justify-content:center;height:100%;color:var(--tm);text-align:center;padding:2rem;}
.pm-empty i{font-size:2.5rem;opacity:.4;margin-bottom:.75rem;}
.pm-empty p{font-size:.88rem;font-weight:600;}
/* Chat panel flex layout */
.pm-chat-panel{display:flex;flex-direction:column;height:100%;overflow:hidden;}
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
/* Emoji picker — positioned relative to .pm-composer-bottom */
.pm-emoji-picker{position:absolute;bottom:100%;left:46px;margin-bottom:6px;background:#fff;border:1.5px solid var(--tb);border-radius:12px;padding:.6rem;box-shadow:0 8px 24px rgba(0,0,0,.12);display:flex;flex-wrap:wrap;gap:4px;max-width:260px;z-index:200;}
.pm-emoji-picker span{font-size:1.3rem;cursor:pointer;padding:4px 5px;border-radius:6px;transition:background .12s;line-height:1;}
.pm-emoji-picker span:hover{background:#F3F4F6;}
/* Icon buttons */
.pm-icon-btn{width:36px;height:36px;border-radius:50%;background:#F3F4F6;border:none;color:var(--tm);display:flex;align-items:center;justify-content:center;font-size:1rem;cursor:pointer;flex-shrink:0;transition:background .15s,color .15s;}
.pm-icon-btn:hover{background:#EDE9FE;color:var(--tp);}
/* File preview */
.pm-file-preview{padding:.5rem 1.25rem;border-top:1px solid var(--tb);background:var(--tc);}
.pm-file-preview-inner{display:inline-flex;align-items:center;gap:8px;padding:6px 12px;border-radius:10px;background:#F9FAFB;border:1px solid var(--tb);font-size:.8rem;color:var(--tt);font-weight:600;max-width:100%;}
.pm-file-preview-inner i{color:var(--tp);font-size:.9rem;}
.pm-file-preview-inner span{white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:200px;}
.pm-file-rm{background:none;border:none;color:var(--te);cursor:pointer;font-size:.85rem;padding:2px 4px;border-radius:4px;margin-left:4px;}
.pm-file-rm:hover{background:#FEE2E2;}
/* Image attachment preview in file bar */
.pm-file-thumb{width:40px;height:40px;border-radius:6px;object-fit:cover;border:1px solid var(--tb);}</style>
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
                <asp:TextBox ID="txtSearchConv" runat="server" CssClass="pm-search" placeholder="Search conversations..." /></div>
            <asp:LinkButton ID="btnCompose" runat="server" CssClass="pm-compose-btn" OnClick="btnCompose_Click" CausesValidation="false" ToolTip="New Message">
                <i class="bi bi-pencil-square"></i>
            </asp:LinkButton>
        </div>
        <div class="pm-tabs">
            <button type="button" id="tabAll" class="pm-tab active" onclick="pmSetTab('All')">All</button>
            <button type="button" id="tabStudent" class="pm-tab" onclick="pmSetTab('Student')">Students</button>
            <button type="button" id="tabParent" class="pm-tab" onclick="pmSetTab('Parent')">Parents</button>
        </div>
    </div>
    <div class="pm-list" id="pmConvList">
        <div id="pmNoConvsMsg" class="pm-empty" style="display:none;"><i class="bi bi-chat-square-text"></i><p style="font-weight:700;margin-bottom:.25rem;">No matching conversations found.</p><span style="font-size:.78rem;color:var(--tm);">Try searching with a different name or selecting another category.</span></div>
        <asp:Panel ID="pnlNoConvs" runat="server" Visible="false">
            <div class="pm-empty"><i class="bi bi-chat-square-text"></i><p><asp:Literal ID="litNoConvMsg" runat="server" /></p></div>
        </asp:Panel>
        <asp:Repeater ID="rptConvs" runat="server" OnItemCommand="rptConvs_ItemCommand">
            <ItemTemplate>
                <div class='pm-conv <%# Eval("chatId").ToString() == SelectedChatId ? "active" : "" %>' data-name='<%# HttpUtility.HtmlAttributeEncode(Eval("name").ToString().ToLower()) %>' data-role='<%# Eval("role") %>' data-chatid='<%# Eval("chatId") %>'>
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
        <div class="pm-empty"><i class="bi bi-chat-left-text"></i><p style="font-weight:700;margin-bottom:.25rem;"><%: T("No conversation selected.","Tiada perbualan dipilih.") %></p><span style="font-size:.78rem;color:var(--tm);"><%: T("Select a conversation from the list or start a new one.","Pilih perbualan dari senarai atau mulakan yang baharu.") %></span></div>
    </asp:Panel>

    <%-- Compose Mode --%>
    <asp:Panel ID="pnlCompose" runat="server" Visible="false">
        <div class="pm-chat-header" style="border-bottom:1px solid var(--tb);">
            <div style="display:flex;align-items:center;gap:8px;flex:1;">
                <span style="font-size:.82rem;font-weight:700;color:var(--tm);"><%: T("To:","Kepada:") %></span>
                <select id="ddlRecipientTypeClient" class="pm-compose-select" onchange="pmRecipientTypeChanged()">
                    <option value="">— Type —</option>
                    <option value="Student">Student</option>
                    <option value="Parent">Parent</option>
                </select>
                <asp:DropDownList ID="ddlRecipientType" runat="server" CssClass="pm-compose-select" style="display:none;" />
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
        <div class="pm-composer-bottom">
            <%-- Compose file preview bar --%>
            <div class="pm-file-preview" id="pmComposeFilePreview" style="display:none;">
                <div class="pm-file-preview-inner">
                    <i class="bi bi-paperclip" id="pmComposeFileIcon"></i>
                    <img id="pmComposeFileThumb" class="pm-file-thumb" style="display:none;" alt="" />
                    <span id="pmComposeFileName">file.pdf</span>
                    <button type="button" class="pm-file-rm" onclick="pmComposeRemoveFile()"><i class="bi bi-x-lg"></i></button>
                </div>
            </div>
            <div class="pm-input-area">
                <asp:FileUpload ID="fuComposeAttachment" runat="server" style="display:none;" />
                <button type="button" class="pm-icon-btn" onclick="document.getElementById('<%=fuComposeAttachment.ClientID%>').click();" title="Attach file"><i class="bi bi-plus-lg"></i></button>
                <button type="button" class="pm-icon-btn" id="pmComposeEmojiBtn" onclick="pmComposeToggleEmoji()" title="Emoji"><i class="bi bi-emoji-smile"></i></button>
                <asp:TextBox ID="txtComposeMsg" runat="server" CssClass="pm-input" TextMode="MultiLine" Rows="1" placeholder="Type a message..." />
                <asp:LinkButton ID="btnComposeSend" runat="server" CssClass="pm-send-btn" OnClick="btnComposeSend_Click" CausesValidation="false">
                    <i class="bi bi-send-fill"></i>
                </asp:LinkButton>
            </div>
            <%-- Compose emoji picker --%>
            <div class="pm-emoji-picker" id="pmComposeEmojiPicker" style="display:none;">
                <span onclick="pmComposeInsertEmoji('😀')">😀</span><span onclick="pmComposeInsertEmoji('😄')">😄</span><span onclick="pmComposeInsertEmoji('😂')">😂</span><span onclick="pmComposeInsertEmoji('😊')">😊</span><span onclick="pmComposeInsertEmoji('😍')">😍</span><span onclick="pmComposeInsertEmoji('😢')">😢</span><span onclick="pmComposeInsertEmoji('😭')">😭</span><span onclick="pmComposeInsertEmoji('👍')">👍</span><span onclick="pmComposeInsertEmoji('👏')">👏</span><span onclick="pmComposeInsertEmoji('🙏')">🙏</span><span onclick="pmComposeInsertEmoji('❤️')">❤️</span><span onclick="pmComposeInsertEmoji('🎉')">🎉</span><span onclick="pmComposeInsertEmoji('✅')">✅</span><span onclick="pmComposeInsertEmoji('🔥')">🔥</span><span onclick="pmComposeInsertEmoji('💯')">💯</span><span onclick="pmComposeInsertEmoji('😎')">😎</span><span onclick="pmComposeInsertEmoji('🤔')">🤔</span><span onclick="pmComposeInsertEmoji('👀')">👀</span>
            </div>
        </div>
    </asp:Panel>

    <%-- Normal Chat --%>
    <asp:Panel ID="pnlChat" runat="server" Visible="false" CssClass="pm-chat-panel">
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
                        <%# RenderAttachment(Eval("attachmentFile")?.ToString()) %>
                        <div class="pm-msg-time"><%# Eval("timeStr") %><%# Convert.ToBoolean(Eval("isSent")) ? (Convert.ToBoolean(Eval("isRead")) ? "<span class='pm-tick read'>✓</span>" : "<span class='pm-tick sent'>✓</span>") : "" %></div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
            <asp:Panel ID="pnlNoMessages" runat="server" Visible="false">
                <div class="pm-empty" style="padding:2rem;"><i class="bi bi-chat"></i><p><%: T("No messages yet. Send the first message.","Tiada mesej lagi. Hantar mesej pertama.") %></p></div>
            </asp:Panel>
        </div>
        <div class="pm-composer-bottom">
            <div class="pm-val" id="valMsg"></div>
            <%-- File preview bar --%>
            <div class="pm-file-preview" id="pmFilePreview" style="display:none;">
                <div class="pm-file-preview-inner">
                    <i class="bi bi-paperclip" id="pmFileIcon"></i>
                    <img id="pmFileThumb" class="pm-file-thumb" style="display:none;" alt="" />
                    <span id="pmFileName">file.pdf</span>
                    <button type="button" class="pm-file-rm" onclick="pmRemoveFile()"><i class="bi bi-x-lg"></i></button>
                </div>
            </div>
            <div class="pm-input-area">
                <asp:FileUpload ID="fuAttachment" runat="server" style="display:none;" />
                <button type="button" class="pm-icon-btn" onclick="document.getElementById('<%=fuAttachment.ClientID%>').click();" title="Attach file"><i class="bi bi-plus-lg"></i></button>
                <button type="button" class="pm-icon-btn" id="pmEmojiBtn" onclick="pmToggleEmoji()" title="Emoji"><i class="bi bi-emoji-smile"></i></button>
                <asp:TextBox ID="txtMessage" runat="server" CssClass="pm-input" TextMode="MultiLine" Rows="1" placeholder="Type your message..." />
                <asp:LinkButton ID="btnSend" runat="server" CssClass="pm-send-btn" OnClick="btnSend_Click" CausesValidation="false">
                    <i class="bi bi-send-fill"></i>
                </asp:LinkButton>
            </div>
            <%-- Emoji picker --%>
            <div class="pm-emoji-picker" id="pmEmojiPicker" style="display:none;">
                <span onclick="pmInsertEmoji('😀')">😀</span><span onclick="pmInsertEmoji('😄')">😄</span><span onclick="pmInsertEmoji('😂')">😂</span><span onclick="pmInsertEmoji('😊')">😊</span><span onclick="pmInsertEmoji('😍')">😍</span><span onclick="pmInsertEmoji('😢')">😢</span><span onclick="pmInsertEmoji('😭')">😭</span><span onclick="pmInsertEmoji('👍')">👍</span><span onclick="pmInsertEmoji('👏')">👏</span><span onclick="pmInsertEmoji('🙏')">🙏</span><span onclick="pmInsertEmoji('❤️')">❤️</span><span onclick="pmInsertEmoji('🎉')">🎉</span><span onclick="pmInsertEmoji('✅')">✅</span><span onclick="pmInsertEmoji('🔥')">🔥</span><span onclick="pmInsertEmoji('💯')">💯</span><span onclick="pmInsertEmoji('😎')">😎</span><span onclick="pmInsertEmoji('🤔')">🤔</span><span onclick="pmInsertEmoji('👀')">👀</span>
            </div>
        </div>
    </asp:Panel>
</div>

</div>

<%-- New Conversation Modal removed - using inline compose mode --%>

<asp:HiddenField ID="hidSelectedChat" runat="server" Value="" />
<asp:HiddenField ID="hidRecipientsJson" runat="server" Value="" />
</asp:Content>
<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
window.addEventListener('load',function(){var m=document.getElementById('msgArea');if(m)m.scrollTop=m.scrollHeight;});

/* ══ Client-side Search & Category Filter ══ */
var pmActiveTab = 'All';
function pmSetTab(tab){
    pmActiveTab = tab;
    document.getElementById('tabAll').className = 'pm-tab' + (tab==='All'?' active':'');
    document.getElementById('tabStudent').className = 'pm-tab' + (tab==='Student'?' active':'');
    document.getElementById('tabParent').className = 'pm-tab' + (tab==='Parent'?' active':'');
    pmFilterConvs();
}
function pmFilterConvs(){
    var searchEl = document.querySelector('[id$="txtSearchConv"]');
    var query = (searchEl ? searchEl.value : '').trim().toLowerCase();
    var cards = document.querySelectorAll('.pm-conv[data-name]');
    var noConvsEl = document.getElementById('pmNoConvsMsg');
    var visibleCount = 0;
    var selectedChatId = document.querySelector('[id$="hidSelectedChat"]')?.value || '';
    var selectedStillVisible = false;

    cards.forEach(function(card){
        var name = card.getAttribute('data-name') || '';
        var role = card.getAttribute('data-role') || '';
        var chatId = card.getAttribute('data-chatid') || '';
        var matchesSearch = !query || name.indexOf(query) >= 0;
        var matchesTab = pmActiveTab === 'All' || role === pmActiveTab;
        var show = matchesSearch && matchesTab;
        card.style.display = show ? '' : 'none';
        if (show) visibleCount++;
        if (show && chatId === selectedChatId) selectedStillVisible = true;
    });

    // Show/hide no-conversations message
    if (noConvsEl) {
        noConvsEl.style.display = (visibleCount === 0 && cards.length > 0) ? '' : 'none';
    }
    // Also hide server-rendered pnlNoConvs if cards exist
    var serverNoConvs = document.querySelector('[id$="pnlNoConvs"]');
    if (serverNoConvs && cards.length > 0) serverNoConvs.style.display = 'none';

    // If selected conversation is now hidden, clear the right panel
    if (selectedChatId && !selectedStillVisible) {
        pmClearRightPanel();
        cards.forEach(function(c){ c.classList.remove('active'); });
    }
}
function pmClearRightPanel(){
    var pnlChat = document.querySelector('[id$="pnlChat"]');
    var pnlNoChat = document.querySelector('[id$="pnlNoChat"]');
    var pnlCompose = document.querySelector('[id$="pnlCompose"]');
    if (pnlChat) pnlChat.style.display = 'none';
    if (pnlCompose) pnlCompose.style.display = 'none';
    if (pnlNoChat) pnlNoChat.style.display = '';
}

// Attach search input event
(function(){
    var searchEl = document.querySelector('[id$="txtSearchConv"]');
    if (searchEl) {
        searchEl.addEventListener('input', pmFilterConvs);
        searchEl.addEventListener('keydown', function(e){ if(e.key==='Enter') e.preventDefault(); });
    }
})();

/* ══ Client-side Recipient Type Switching ══ */
function pmRecipientTypeChanged(){
    var typeSelect = document.getElementById('ddlRecipientTypeClient');
    var recipientDdl = document.querySelector('[id$="ddlRecipient"]');
    var hiddenTypeDdl = document.querySelector('[id$="ddlRecipientType"]');
    var selectedType = typeSelect.value;

    // Sync to hidden server control for postback
    if (hiddenTypeDdl) hiddenTypeDdl.value = selectedType;

    // Clear and repopulate recipient dropdown
    recipientDdl.innerHTML = '<option value="">— Select Recipient —</option>';
    if (!selectedType) return;

    // Get recipients from hidden JSON field
    try {
        var jsonEl = document.querySelector('[id$="hidRecipientsJson"]');
        var allRecipients = JSON.parse(jsonEl.value || '[]');
        allRecipients.forEach(function(r){
            if (r.role === selectedType) {
                var opt = document.createElement('option');
                opt.value = r.id;
                opt.textContent = r.name;
                recipientDdl.appendChild(opt);
            }
        });
    } catch(e){}
}

/* ── Emoji Picker ── */
function pmToggleEmoji(){
    var p=document.getElementById('pmEmojiPicker');
    p.style.display=p.style.display==='none'?'flex':'none';
    // Close compose picker if open
    var cp=document.getElementById('pmComposeEmojiPicker');
    if(cp)cp.style.display='none';
}
function pmInsertEmoji(em){
    var ta=document.querySelector('[id$="txtMessage"]');
    if(!ta)return;
    var start=ta.selectionStart,end=ta.selectionEnd;
    ta.value=ta.value.substring(0,start)+em+ta.value.substring(end);
    ta.selectionStart=ta.selectionEnd=start+em.length;
    ta.focus();
}

/* ── Compose Emoji Picker ── */
function pmComposeToggleEmoji(){
    var p=document.getElementById('pmComposeEmojiPicker');
    p.style.display=p.style.display==='none'?'flex':'none';
    // Close chat picker if open
    var cp=document.getElementById('pmEmojiPicker');
    if(cp)cp.style.display='none';
}
function pmComposeInsertEmoji(em){
    var ta=document.querySelector('[id$="txtComposeMsg"]');
    if(!ta)return;
    var start=ta.selectionStart,end=ta.selectionEnd;
    ta.value=ta.value.substring(0,start)+em+ta.value.substring(end);
    ta.selectionStart=ta.selectionEnd=start+em.length;
    ta.focus();
}

// Close emoji pickers when clicking outside
document.addEventListener('click',function(e){
    var picker=document.getElementById('pmEmojiPicker');
    var btn=document.getElementById('pmEmojiBtn');
    if(picker&&picker.style.display==='flex'&&!picker.contains(e.target)&&e.target!==btn&&!btn.contains(e.target)){
        picker.style.display='none';
    }
    var picker2=document.getElementById('pmComposeEmojiPicker');
    var btn2=document.getElementById('pmComposeEmojiBtn');
    if(picker2&&picker2.style.display==='flex'&&!picker2.contains(e.target)&&e.target!==btn2&&!btn2.contains(e.target)){
        picker2.style.display='none';
    }
});

/* ── File Attachment Preview ── */
(function(){
    var fu=document.querySelector('[id$="fuAttachment"]');
    if(!fu)return;
    var allowed=['pdf','doc','docx','ppt','pptx','jpg','jpeg','png'];
    var maxSize=10*1024*1024;
    fu.addEventListener('change',function(){
        var preview=document.getElementById('pmFilePreview');
        var nameEl=document.getElementById('pmFileName');
        var thumb=document.getElementById('pmFileThumb');
        var icon=document.getElementById('pmFileIcon');
        if(!fu.files||!fu.files[0]){preview.style.display='none';return;}
        var f=fu.files[0];
        var ext=f.name.split('.').pop().toLowerCase();
        if(allowed.indexOf(ext)===-1){alert('File type not allowed. Allowed: PDF, DOC, DOCX, PPT, PPTX, JPG, JPEG, PNG.');fu.value='';preview.style.display='none';return;}
        if(f.size>maxSize){alert('File exceeds 10 MB limit.');fu.value='';preview.style.display='none';return;}
        nameEl.textContent=f.name;
        if(['jpg','jpeg','png'].indexOf(ext)>=0){
            var reader=new FileReader();
            reader.onload=function(e){thumb.src=e.target.result;thumb.style.display='block';icon.style.display='none';};
            reader.readAsDataURL(f);
        } else {
            thumb.style.display='none';icon.style.display='';
        }
        preview.style.display='block';
    });
})();
function pmRemoveFile(){
    var fu=document.querySelector('[id$="fuAttachment"]');
    if(fu)fu.value='';
    document.getElementById('pmFilePreview').style.display='none';
    var thumb=document.getElementById('pmFileThumb');if(thumb){thumb.style.display='none';thumb.src='';}
    var icon=document.getElementById('pmFileIcon');if(icon)icon.style.display='';
}

/* ── Compose File Attachment Preview ── */
(function(){
    var fu=document.querySelector('[id$="fuComposeAttachment"]');
    if(!fu)return;
    var allowed=['pdf','doc','docx','ppt','pptx','jpg','jpeg','png'];
    var maxSize=10*1024*1024;
    fu.addEventListener('change',function(){
        var preview=document.getElementById('pmComposeFilePreview');
        var nameEl=document.getElementById('pmComposeFileName');
        var thumb=document.getElementById('pmComposeFileThumb');
        var icon=document.getElementById('pmComposeFileIcon');
        if(!fu.files||!fu.files[0]){preview.style.display='none';return;}
        var f=fu.files[0];
        var ext=f.name.split('.').pop().toLowerCase();
        if(allowed.indexOf(ext)===-1){alert('File type not allowed. Allowed: PDF, DOC, DOCX, PPT, PPTX, JPG, JPEG, PNG.');fu.value='';preview.style.display='none';return;}
        if(f.size>maxSize){alert('File exceeds 10 MB limit.');fu.value='';preview.style.display='none';return;}
        nameEl.textContent=f.name;
        if(['jpg','jpeg','png'].indexOf(ext)>=0){
            var reader=new FileReader();
            reader.onload=function(e){thumb.src=e.target.result;thumb.style.display='block';icon.style.display='none';};
            reader.readAsDataURL(f);
        } else {
            thumb.style.display='none';icon.style.display='';
        }
        preview.style.display='block';
    });
})();
function pmComposeRemoveFile(){
    var fu=document.querySelector('[id$="fuComposeAttachment"]');
    if(fu)fu.value='';
    document.getElementById('pmComposeFilePreview').style.display='none';
    var thumb=document.getElementById('pmComposeFileThumb');if(thumb){thumb.style.display='none';thumb.src='';}
    var icon=document.getElementById('pmComposeFileIcon');if(icon)icon.style.display='';
}
</script>
</asp:Content>
