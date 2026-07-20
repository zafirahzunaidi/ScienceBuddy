<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="privateMessages.aspx.cs"
    Inherits="ScienceBuddy.Teacher.privateMessages" MasterPageFile="~/Site.Master"
    Title="Private Messages" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%: ResolveUrl("~/Content/Teacher.css") %>" rel="stylesheet" />
</asp:Content>

<%-- Sidebar --%>
<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-speedometer2 item-icon"></i>
            <span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Teacher/Notifications.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-bell item-icon"></i>
            <span class="item-label"><%: T("Notifications","Notifikasi") %></span>
        </a>
    </div>

    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Teaching","Pengajaran") %></div>
        <a href="<%: ResolveUrl("~/Teacher/manageMaterials.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-book item-icon"></i>
            <span class="item-label"><%: T("Manage Materials","Bahan Pembelajaran") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-patch-question item-icon"></i>
            <span class="item-label"><%: T("Manage Quiz","Kuiz") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Teacher/studentProgress.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-bar-chart item-icon"></i>
            <span class="item-label"><%: T("Student Progress","Prestasi Pelajar") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Teacher/liveSession.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-camera-video item-icon"></i>
            <span class="item-label"><%: T("Schedule Live Class","Kelas Langsung") %></span>
        </a>
    </div>

    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Community","Komuniti") %></div>
        <a href="<%: ResolveUrl("~/Teacher/forum.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-chat-dots item-icon"></i>
            <span class="item-label"><%: T("Forum","Forum") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Teacher/privateMessages.aspx") %>" class="sb-sidebar-item active">
            <i class="bi bi-envelope item-icon"></i>
            <span class="item-label"><%: T("Private Message","Mesej Peribadi") %></span>
        </a>
    </div>

    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Account","Akaun") %></div>
        <a href="<%: ResolveUrl("~/Teacher/MyProfile.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-person item-icon"></i>
            <span class="item-label"><%: T("My Profile","Profil Saya") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-box-arrow-right item-icon"></i>
            <span class="item-label"><%: T("Sign Out","Log Keluar") %></span>
        </a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <%: T("Private Messages","Mesej Peribadi") %>
</asp:Content>

<%-- Main Content --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="tc-private-messages-wrap">

    <%-- Conversation List --%>
    <div class="tc-private-messages-left">
        <div class="tc-private-messages-left-header">
            <div style="display:flex;align-items:center;gap:10px;margin-bottom:.6rem;">
                <div class="tc-private-messages-search-wrap" style="flex:1;">
                    <i class="bi bi-search"></i>
                    <asp:TextBox ID="txtSearchConv" runat="server"
                        CssClass="tc-private-messages-search"
                        placeholder="Search conversations..." />
                </div>
                <asp:LinkButton ID="btnCompose" runat="server"
                    CssClass="tc-private-messages-compose-btn"
                    OnClick="btnCompose_Click"
                    CausesValidation="false"
                    ToolTip="New Message">
                    <i class="bi bi-pencil-square"></i>
                </asp:LinkButton>
            </div>
            <div class="tc-private-messages-tabs">
                <button type="button" id="tabAll" class="tc-private-messages-tab active" onclick="pmSetTab('All')">All</button>
                <button type="button" id="tabStudent" class="tc-private-messages-tab" onclick="pmSetTab('Student')">Students</button>
                <button type="button" id="tabParent" class="tc-private-messages-tab" onclick="pmSetTab('Parent')">Parents</button>
            </div>
        </div>

        <div class="tc-private-messages-list" id="pmConvList">
            <div id="pmNoConvsMsg" class="tc-private-messages-empty" style="display:none;">
                <i class="bi bi-chat-square-text"></i>
                <p style="font-weight:700;margin-bottom:.25rem;">No matching conversations found.</p>
                <span style="font-size:.78rem;color:var(--tm);">Try searching with a different name or selecting another category.</span>
            </div>

            <asp:Panel ID="pnlNoConvs" runat="server" Visible="false">
                <div class="tc-private-messages-empty">
                    <i class="bi bi-chat-square-text"></i>
                    <p><asp:Literal ID="litNoConvMsg" runat="server" /></p>
                </div>
            </asp:Panel>

            <asp:Repeater ID="rptConvs" runat="server" OnItemCommand="rptConvs_ItemCommand">
                <ItemTemplate>
                    <div class='tc-private-messages-conv <%# Eval("chatId").ToString() == SelectedChatId ? "active" : "" %>'
                        data-name='<%# HttpUtility.HtmlAttributeEncode(Eval("name").ToString().ToLower()) %>'
                        data-role='<%# Eval("role") %>'
                        data-chatid='<%# Eval("chatId") %>'>
                        <asp:LinkButton ID="lnkConv" runat="server"
                            CommandName="Select"
                            CommandArgument='<%# Eval("chatId") %>'
                            CausesValidation="false"
                            style="display:contents;">
                            <div class="tc-private-messages-conv-avatar"><%# Eval("initials") %></div>
                            <div class="tc-private-messages-conv-info">
                                <div class="tc-private-messages-conv-name">
                                    <%# HttpUtility.HtmlEncode(Eval("name")) %>
                                    <span class='tc-private-messages-conv-role <%# Eval("role").ToString()=="Parent"?"parent":"" %>'><%# Eval("role") %></span>
                                </div>
                                <div class="tc-private-messages-conv-preview"><%# HttpUtility.HtmlEncode(Eval("lastMsg")) %></div>
                            </div>
                            <div style="display:flex;flex-direction:column;align-items:flex-end;gap:4px;">
                                <span class="tc-private-messages-conv-time"><%# Eval("timeAgo") %></span>
                                <%# Convert.ToInt32(Eval("unreadCount")) > 0 ? "<span class='tc-private-messages-unread'></span>" : "" %>
                            </div>
                        </asp:LinkButton>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </div>

    <%-- Chat Panel --%>
    <div class="tc-private-messages-right">
        <asp:Panel ID="pnlNoChat" runat="server" Visible="true">
            <div class="tc-private-messages-empty">
                <i class="bi bi-chat-left-text"></i>
                <p style="font-weight:700;margin-bottom:.25rem;"><%: T("No conversation selected.","Tiada perbualan dipilih.") %></p>
                <span style="font-size:.78rem;color:var(--tm);"><%: T("Select a conversation from the list or start a new one.","Pilih perbualan dari senarai atau mulakan yang baharu.") %></span>
            </div>
        </asp:Panel>

        <%-- Compose Mode --%>
        <asp:Panel ID="pnlCompose" runat="server" Visible="false">
            <div class="tc-private-messages-chat-header" style="border-bottom:1px solid var(--tb);">
                <div style="display:flex;align-items:center;gap:8px;flex:1;">
                    <span style="font-size:.82rem;font-weight:700;color:var(--tm);"><%: T("To:","Kepada:") %></span>
                    <select id="ddlRecipientTypeClient" class="tc-private-messages-compose-select" onchange="pmRecipientTypeChanged()">
                        <option value="">— Type —</option>
                        <option value="Student">Student</option>
                        <option value="Parent">Parent</option>
                    </select>
                    <asp:DropDownList ID="ddlRecipientType" runat="server"
                        CssClass="tc-private-messages-compose-select"
                        style="display:none;" />
                    <asp:DropDownList ID="ddlRecipient" runat="server"
                        CssClass="tc-private-messages-compose-select"
                        style="flex:1;" />
                </div>
            </div>

            <div class="tc-private-messages-messages">
                <div class="tc-private-messages-empty" style="padding:3rem;">
                    <i class="bi bi-pencil-square" style="font-size:2.5rem;opacity:.3;color:var(--tp);"></i>
                    <p style="margin-top:.75rem;"><%: T("You're starting a new conversation","Anda memulakan perbualan baharu") %></p>
                    <span style="font-size:.78rem;color:var(--tm);"><%: T("Type your first message below.","Taip mesej pertama anda di bawah.") %></span>
                </div>
            </div>

            <asp:Panel ID="pnlComposeVal" runat="server" Visible="false">
                <div style="font-size:.74rem;color:var(--te);padding:0 1.25rem .5rem;font-weight:600;">
                    <asp:Literal ID="litComposeError" runat="server" />
                </div>
            </asp:Panel>

            <div class="tc-private-messages-composer-bottom">
                <%-- Compose file preview bar --%>
                <div class="tc-private-messages-file-preview" id="pmComposeFilePreview" style="display:none;">
                    <div class="tc-private-messages-file-preview-inner">
                        <i class="bi bi-paperclip" id="pmComposeFileIcon"></i>
                        <img id="pmComposeFileThumb" class="tc-private-messages-file-thumb" style="display:none;" alt="" />
                        <span id="pmComposeFileName">file.pdf</span>
                        <button type="button" class="tc-private-messages-file-rm" onclick="pmComposeRemoveFile()">
                            <i class="bi bi-x-lg"></i>
                        </button>
                    </div>
                </div>

                <div class="tc-private-messages-input-area">
                    <asp:FileUpload ID="fuComposeAttachment" runat="server" style="display:none;" />
                    <button type="button" class="tc-private-messages-icon-btn"
                        onclick="document.getElementById('<%=fuComposeAttachment.ClientID%>').click();"
                        title="Attach file">
                        <i class="bi bi-plus-lg"></i>
                    </button>
                    <button type="button" class="tc-private-messages-icon-btn" id="pmComposeEmojiBtn"
                        onclick="pmComposeToggleEmoji()" title="Emoji">
                        <i class="bi bi-emoji-smile"></i>
                    </button>
                    <asp:TextBox ID="txtComposeMsg" runat="server"
                        CssClass="tc-private-messages-input"
                        TextMode="MultiLine"
                        Rows="1"
                        placeholder="Type a message..." />
                    <asp:LinkButton ID="btnComposeSend" runat="server"
                        CssClass="tc-private-messages-send-btn"
                        OnClick="btnComposeSend_Click"
                        CausesValidation="false">
                        <i class="bi bi-send-fill"></i>
                    </asp:LinkButton>
                </div>

                <%-- Compose emoji picker --%>
                <div class="tc-private-messages-emoji-picker" id="pmComposeEmojiPicker" style="display:none;">
                    <span onclick="pmComposeInsertEmoji('😊')">😊</span><span onclick="pmComposeInsertEmoji('😂')">😂</span><span onclick="pmComposeInsertEmoji('👍')">👍</span><span onclick="pmComposeInsertEmoji('❤️')">❤️</span><span onclick="pmComposeInsertEmoji('🎉')">🎉</span><span onclick="pmComposeInsertEmoji('🙏')">🙏</span><span onclick="pmComposeInsertEmoji('😢')">😢</span><span onclick="pmComposeInsertEmoji('😮')">😮</span><span onclick="pmComposeInsertEmoji('🔥')">🔥</span><span onclick="pmComposeInsertEmoji('💯')">💯</span><span onclick="pmComposeInsertEmoji('✅')">✅</span><span onclick="pmComposeInsertEmoji('⭐')">⭐</span><span onclick="pmComposeInsertEmoji('✨')">✨</span><span onclick="pmComposeInsertEmoji('📚')">📚</span><span onclick="pmComposeInsertEmoji('💪')">💪</span><span onclick="pmComposeInsertEmoji('👋')">👋</span><span onclick="pmComposeInsertEmoji('🤔')">🤔</span><span onclick="pmComposeInsertEmoji('😄')">😄</span>
                </div>
            </div>
        </asp:Panel>

        <%-- Normal Chat --%>
        <asp:Panel ID="pnlChat" runat="server" Visible="false" CssClass="tc-private-messages-chat-panel">
            <div class="tc-private-messages-chat-header">
                <div class="tc-private-messages-chat-avatar">
                    <asp:Literal ID="litChatInitials" runat="server" />
                </div>
                <div>
                    <div class="tc-private-messages-chat-name">
                        <asp:Literal ID="litChatName" runat="server" />
                    </div>
                    <div class="tc-private-messages-chat-role">
                        <asp:Literal ID="litChatRole" runat="server" />
                    </div>
                </div>
            </div>

            <div class="tc-private-messages-messages" id="msgArea">
                <asp:Repeater ID="rptMessages" runat="server">
                    <ItemTemplate>
                        <div class='tc-private-messages-msg <%# Eval("isSent").ToString()=="True"?"sent":"received" %>'>
                            <div class="tc-private-messages-bubble"><%# HttpUtility.HtmlEncode(Eval("msgText")) %></div>
                            <%# RenderAttachment(Eval("attachmentFile")?.ToString()) %>
                            <div class="tc-private-messages-msg-time">
                                <%# Eval("timeStr") %><%# Convert.ToBoolean(Eval("isSent")) ? (Convert.ToBoolean(Eval("isRead")) ? "<span class='tc-private-messages-tick read'>✓</span>" : "<span class='tc-private-messages-tick sent'>✓</span>") : "" %>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>

                <asp:Panel ID="pnlNoMessages" runat="server" Visible="false">
                    <div class="tc-private-messages-empty" style="padding:2rem;">
                        <i class="bi bi-chat"></i>
                        <p><%: T("No messages yet. Send the first message.","Tiada mesej lagi. Hantar mesej pertama.") %></p>
                    </div>
                </asp:Panel>
            </div>

            <div class="tc-private-messages-composer-bottom">
                <div class="tc-private-messages-val" id="valMsg"></div>

                <%-- File preview bar --%>
                <div class="tc-private-messages-file-preview" id="pmFilePreview" style="display:none;">
                    <div class="tc-private-messages-file-preview-inner">
                        <i class="bi bi-paperclip" id="pmFileIcon"></i>
                        <img id="pmFileThumb" class="tc-private-messages-file-thumb" style="display:none;" alt="" />
                        <span id="pmFileName">file.pdf</span>
                        <button type="button" class="tc-private-messages-file-rm" onclick="pmRemoveFile()">
                            <i class="bi bi-x-lg"></i>
                        </button>
                    </div>
                </div>

                <div class="tc-private-messages-input-area">
                    <asp:FileUpload ID="fuAttachment" runat="server" style="display:none;" />
                    <button type="button" class="tc-private-messages-icon-btn"
                        onclick="document.getElementById('<%=fuAttachment.ClientID%>').click();"
                        title="Attach file">
                        <i class="bi bi-plus-lg"></i>
                    </button>
                    <button type="button" class="tc-private-messages-icon-btn" id="pmEmojiBtn"
                        onclick="pmToggleEmoji()" title="Emoji">
                        <i class="bi bi-emoji-smile"></i>
                    </button>
                    <asp:TextBox ID="txtMessage" runat="server"
                        CssClass="tc-private-messages-input"
                        TextMode="MultiLine"
                        Rows="1"
                        placeholder="Type your message..." />
                    <asp:LinkButton ID="btnSend" runat="server"
                        CssClass="tc-private-messages-send-btn"
                        OnClick="btnSend_Click"
                        CausesValidation="false">
                        <i class="bi bi-send-fill"></i>
                    </asp:LinkButton>
                </div>

                <%-- Emoji picker --%>
                <div class="tc-private-messages-emoji-picker" id="pmEmojiPicker" style="display:none;">
                    <span onclick="pmInsertEmoji('😊')">😊</span><span onclick="pmInsertEmoji('😂')">😂</span><span onclick="pmInsertEmoji('👍')">👍</span><span onclick="pmInsertEmoji('❤️')">❤️</span><span onclick="pmInsertEmoji('🎉')">🎉</span><span onclick="pmInsertEmoji('🙏')">🙏</span><span onclick="pmInsertEmoji('😢')">😢</span><span onclick="pmInsertEmoji('😮')">😮</span><span onclick="pmInsertEmoji('🔥')">🔥</span><span onclick="pmInsertEmoji('💯')">💯</span><span onclick="pmInsertEmoji('✅')">✅</span><span onclick="pmInsertEmoji('⭐')">⭐</span><span onclick="pmInsertEmoji('✨')">✨</span><span onclick="pmInsertEmoji('📚')">📚</span><span onclick="pmInsertEmoji('💪')">💪</span><span onclick="pmInsertEmoji('👋')">👋</span><span onclick="pmInsertEmoji('🤔')">🤔</span><span onclick="pmInsertEmoji('😄')">😄</span>
                </div>
            </div>
        </asp:Panel>
    </div>

</div>

<%-- New Conversation Modal removed - using inline compose mode --%>

<asp:HiddenField ID="hidSelectedChat" runat="server" Value="" />
<asp:HiddenField ID="hidRecipientsJson" runat="server" Value="" />
</asp:Content>

<%-- Scripts --%>
<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
    window.addEventListener('load', function () {
        var m = document.getElementById('msgArea');
        if (m) m.scrollTop = m.scrollHeight;
    });

    /* -- Client-side Search & Category Filter -- */
    var pmActiveTab = 'All';
    function pmSetTab(tab) {
        pmActiveTab = tab;
        document.getElementById('tabAll').className = 'tc-private-messages-tab' + (tab === 'All' ? ' active' : '');
        document.getElementById('tabStudent').className = 'tc-private-messages-tab' + (tab === 'Student' ? ' active' : '');
        document.getElementById('tabParent').className = 'tc-private-messages-tab' + (tab === 'Parent' ? ' active' : '');
        pmFilterConvs();
    }

    function pmFilterConvs() {
        var searchEl = document.querySelector('[id$="txtSearchConv"]');
        var query = (searchEl ? searchEl.value : '').trim().toLowerCase();
        var cards = document.querySelectorAll('.tc-private-messages-conv[data-name]');
        var noConvsEl = document.getElementById('pmNoConvsMsg');
        var visibleCount = 0;
        var selectedChatId = document.querySelector('[id$="hidSelectedChat"]')?.value || '';
        var selectedStillVisible = false;

        cards.forEach(function (card) {
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
            cards.forEach(function (c) { c.classList.remove('active'); });
        }
    }

    function pmClearRightPanel() {
        var pnlChat = document.querySelector('[id$="pnlChat"]');
        var pnlNoChat = document.querySelector('[id$="pnlNoChat"]');
        var pnlCompose = document.querySelector('[id$="pnlCompose"]');
        if (pnlChat) pnlChat.style.display = 'none';
        if (pnlCompose) pnlCompose.style.display = 'none';
        if (pnlNoChat) pnlNoChat.style.display = '';
    }

    // Attach search input event
    (function () {
        var searchEl = document.querySelector('[id$="txtSearchConv"]');
        if (searchEl) {
            searchEl.addEventListener('input', pmFilterConvs);
            searchEl.addEventListener('keydown', function (e) { if (e.key === 'Enter') e.preventDefault(); });
        }
    })();

    /* -- Client-side Recipient Type Switching -- */
    function pmRecipientTypeChanged() {
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
            allRecipients.forEach(function (r) {
                if (r.role === selectedType) {
                    var opt = document.createElement('option');
                    opt.value = r.id;
                    opt.textContent = r.name;
                    recipientDdl.appendChild(opt);
                }
            });
        } catch (e) { }
    }

    /* -- Emoji Picker -- */
    function pmToggleEmoji() {
        var p = document.getElementById('pmEmojiPicker');
        p.style.display = p.style.display === 'none' ? 'flex' : 'none';
        // Close compose picker if open
        var cp = document.getElementById('pmComposeEmojiPicker');
        if (cp) cp.style.display = 'none';
    }
    function pmInsertEmoji(em) {
        var ta = document.querySelector('[id$="txtMessage"]');
        if (!ta) return;
        var start = ta.selectionStart, end = ta.selectionEnd;
        ta.value = ta.value.substring(0, start) + em + ta.value.substring(end);
        ta.selectionStart = ta.selectionEnd = start + em.length;
        ta.focus();
    }

    /* -- Compose Emoji Picker -- */
    function pmComposeToggleEmoji() {
        var p = document.getElementById('pmComposeEmojiPicker');
        p.style.display = p.style.display === 'none' ? 'flex' : 'none';
        // Close chat picker if open
        var cp = document.getElementById('pmEmojiPicker');
        if (cp) cp.style.display = 'none';
    }
    function pmComposeInsertEmoji(em) {
        var ta = document.querySelector('[id$="txtComposeMsg"]');
        if (!ta) return;
        var start = ta.selectionStart, end = ta.selectionEnd;
        ta.value = ta.value.substring(0, start) + em + ta.value.substring(end);
        ta.selectionStart = ta.selectionEnd = start + em.length;
        ta.focus();
    }

    // Close emoji pickers when clicking outside
    document.addEventListener('click', function (e) {
        var picker = document.getElementById('pmEmojiPicker');
        var btn = document.getElementById('pmEmojiBtn');
        if (picker && picker.style.display === 'flex' && !picker.contains(e.target) && e.target !== btn && !btn.contains(e.target)) {
            picker.style.display = 'none';
        }
        var picker2 = document.getElementById('pmComposeEmojiPicker');
        var btn2 = document.getElementById('pmComposeEmojiBtn');
        if (picker2 && picker2.style.display === 'flex' && !picker2.contains(e.target) && e.target !== btn2 && !btn2.contains(e.target)) {
            picker2.style.display = 'none';
        }
    });

    /* -- File Attachment Preview -- */
    (function () {
        var fu = document.querySelector('[id$="fuAttachment"]');
        if (!fu) return;
        var allowed = ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'jpg', 'jpeg', 'png'];
        var maxSize = 10 * 1024 * 1024;
        fu.addEventListener('change', function () {
            var preview = document.getElementById('pmFilePreview');
            var nameEl = document.getElementById('pmFileName');
            var thumb = document.getElementById('pmFileThumb');
            var icon = document.getElementById('pmFileIcon');
            if (!fu.files || !fu.files[0]) { preview.style.display = 'none'; return; }
            var f = fu.files[0];
            var ext = f.name.split('.').pop().toLowerCase();
            if (allowed.indexOf(ext) === -1) { alert('File type not allowed. Allowed: PDF, DOC, DOCX, PPT, PPTX, JPG, JPEG, PNG.'); fu.value = ''; preview.style.display = 'none'; return; }
            if (f.size > maxSize) { alert('File exceeds 10 MB limit.'); fu.value = ''; preview.style.display = 'none'; return; }
            nameEl.textContent = f.name;
            if (['jpg', 'jpeg', 'png'].indexOf(ext) >= 0) {
                var reader = new FileReader();
                reader.onload = function (e) { thumb.src = e.target.result; thumb.style.display = 'block'; icon.style.display = 'none'; };
                reader.readAsDataURL(f);
            } else {
                thumb.style.display = 'none'; icon.style.display = '';
            }
            preview.style.display = 'block';
        });
    })();

    function pmRemoveFile() {
        var fu = document.querySelector('[id$="fuAttachment"]');
        if (fu) fu.value = '';
        document.getElementById('pmFilePreview').style.display = 'none';
        var thumb = document.getElementById('pmFileThumb'); if (thumb) { thumb.style.display = 'none'; thumb.src = ''; }
        var icon = document.getElementById('pmFileIcon'); if (icon) icon.style.display = '';
    }

    /* -- Compose File Attachment Preview -- */
    (function () {
        var fu = document.querySelector('[id$="fuComposeAttachment"]');
        if (!fu) return;
        var allowed = ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'jpg', 'jpeg', 'png'];
        var maxSize = 10 * 1024 * 1024;
        fu.addEventListener('change', function () {
            var preview = document.getElementById('pmComposeFilePreview');
            var nameEl = document.getElementById('pmComposeFileName');
            var thumb = document.getElementById('pmComposeFileThumb');
            var icon = document.getElementById('pmComposeFileIcon');
            if (!fu.files || !fu.files[0]) { preview.style.display = 'none'; return; }
            var f = fu.files[0];
            var ext = f.name.split('.').pop().toLowerCase();
            if (allowed.indexOf(ext) === -1) { alert('File type not allowed. Allowed: PDF, DOC, DOCX, PPT, PPTX, JPG, JPEG, PNG.'); fu.value = ''; preview.style.display = 'none'; return; }
            if (f.size > maxSize) { alert('File exceeds 10 MB limit.'); fu.value = ''; preview.style.display = 'none'; return; }
            nameEl.textContent = f.name;
            if (['jpg', 'jpeg', 'png'].indexOf(ext) >= 0) {
                var reader = new FileReader();
                reader.onload = function (e) { thumb.src = e.target.result; thumb.style.display = 'block'; icon.style.display = 'none'; };
                reader.readAsDataURL(f);
            } else {
                thumb.style.display = 'none'; icon.style.display = '';
            }
            preview.style.display = 'block';
        });
    })();

    function pmComposeRemoveFile() {
        var fu = document.querySelector('[id$="fuComposeAttachment"]');
        if (fu) fu.value = '';
        document.getElementById('pmComposeFilePreview').style.display = 'none';
        var thumb = document.getElementById('pmComposeFileThumb'); if (thumb) { thumb.style.display = 'none'; thumb.src = ''; }
        var icon = document.getElementById('pmComposeFileIcon'); if (icon) icon.style.display = '';
    }
</script>
</asp:Content>
