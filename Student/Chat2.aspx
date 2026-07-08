<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Chat2.aspx.cs"
    Inherits="ScienceBuddy.Student.ChatPage" MasterPageFile="~/Site.Master"
    Title="Chat" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* -- Student Chat Page -- */
:root{--ct-blue:#2563EB;--ct-indigo:#4F46E5;--ct-purple:#7C3AED;--ct-light:#EFF6FF;--ct-grey:#F8FAFC;}

.ct-back{display:inline-flex;align-items:center;gap:6px;font-size:.8rem;font-weight:600;
    color:var(--ct-blue);text-decoration:none;margin-bottom:var(--space-md);transition:color .2s;}
.ct-back:hover{color:var(--ct-indigo);text-decoration:none;}

/* Header */
.ct-header{background:var(--color-white);border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);
    padding:var(--space-md) var(--space-lg);display:flex;align-items:center;gap:var(--space-md);
    margin-bottom:2px;position:sticky;top:0;z-index:10;}
.ct-header-avatar{width:44px;height:44px;border-radius:50%;
    background:linear-gradient(135deg,var(--ct-blue),var(--ct-purple));color:#fff;
    display:flex;align-items:center;justify-content:center;
    font-size:1rem;font-weight:800;flex-shrink:0;box-shadow:0 2px 8px rgba(37,99,235,.2);}
.ct-header-info{flex:1;}
.ct-header-name{font-family:var(--font-primary);font-weight:700;font-size:1rem;color:var(--color-text);}
.ct-header-qual{font-size:.75rem;color:var(--color-text-secondary);}
.ct-header-status{font-size:.7rem;font-weight:700;padding:3px 10px;
    border-radius:var(--border-radius-full);background:#DCFCE7;color:#15803D;
    display:inline-flex;align-items:center;gap:4px;}
.ct-header-status::before{content:'';width:6px;height:6px;border-radius:50%;background:#22C55E;
    animation:ct-pulse 2s ease-in-out infinite;}
@keyframes ct-pulse{0%,100%{opacity:1;}50%{opacity:.4;}}

/* Messages area */
.ct-messages{background:var(--ct-light);border-radius:0 0 var(--border-radius-xl) var(--border-radius-xl);
    border:1.5px solid var(--border-color);border-top:none;
    padding:var(--space-lg);min-height:380px;max-height:480px;overflow-y:auto;
    margin-bottom:var(--space-sm);display:flex;flex-direction:column;gap:var(--space-sm);
    position:relative;}
.ct-messages::before{content:'';position:absolute;inset:0;
    background-image:radial-gradient(circle,rgba(37,99,235,.03) 1px,transparent 1px);
    background-size:20px 20px;pointer-events:none;border-radius:inherit;}

/* Message row */
.ct-msg-row{display:flex;align-items:flex-end;gap:8px;animation:ct-fadein .3s ease;}
@keyframes ct-fadein{from{opacity:0;transform:translateY(6px);}to{opacity:1;transform:translateY(0);}}
.ct-msg-row.mine{flex-direction:row-reverse;}
.ct-msg-row.other{flex-direction:row;}

/* Avatar */
.ct-msg-avatar{width:32px;height:32px;border-radius:50%;display:flex;align-items:center;
    justify-content:center;font-size:.7rem;font-weight:800;flex-shrink:0;color:#fff;}
.ct-msg-row.mine .ct-msg-avatar{background:linear-gradient(135deg,var(--ct-blue),var(--ct-indigo));}
.ct-msg-row.other .ct-msg-avatar{background:linear-gradient(135deg,#F97316,#FBBF24);}

/* Bubble */
.ct-msg-content{max-width:65%;display:flex;flex-direction:column;}
.ct-msg-row.mine .ct-msg-content{align-items:flex-end;}
.ct-msg-row.other .ct-msg-content{align-items:flex-start;}
.ct-msg-bubble{padding:10px 16px;font-size:.875rem;line-height:1.5;word-wrap:break-word;
    box-shadow:0 1px 4px rgba(0,0,0,.06);}
.ct-msg-row.mine .ct-msg-bubble{background:linear-gradient(135deg,var(--ct-blue),var(--ct-indigo));
    color:#fff;border-radius:18px 18px 4px 18px;}
.ct-msg-row.other .ct-msg-bubble{background:#fff;color:var(--color-text);
    border:1px solid var(--border-color);border-radius:18px 18px 18px 4px;}
.ct-msg-meta{font-size:.65rem;color:var(--color-text-muted);margin-top:3px;
    display:flex;align-items:center;gap:3px;}
.ct-msg-sender{font-size:.7rem;font-weight:600;color:var(--color-text-secondary);margin-bottom:2px;}

/* Empty */
.ct-empty{text-align:center;padding:var(--space-2xl) var(--space-xl);color:var(--color-text-muted);}
.ct-empty-icon{font-size:3rem;margin-bottom:var(--space-md);color:var(--ct-blue);opacity:.4;
    animation:ct-float 3s ease-in-out infinite;}
@keyframes ct-float{0%,100%{transform:translateY(0);}50%{transform:translateY(-6px);}}
.ct-empty-title{font-family:var(--font-primary);font-size:1rem;font-weight:700;color:var(--color-text);margin-bottom:4px;}
.ct-empty-text{font-size:.85rem;line-height:1.4;}

/* Input */
.ct-input{background:var(--color-white);border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);
    padding:var(--space-sm) var(--space-md);display:flex;align-items:center;gap:var(--space-sm);}
.ct-input-text{flex:1;border:1.5px solid var(--border-color);border-radius:var(--border-radius-full);
    padding:10px 18px;font-size:.875rem;outline:none;transition:border-color .2s,box-shadow .2s;
    font-family:inherit;background:#FAFBFC;}
.ct-input-text:focus{border-color:var(--ct-blue);box-shadow:0 0 0 3px rgba(37,99,235,.08);background:#fff;}
.ct-input-btn{width:42px;height:42px;border-radius:50%;display:flex;align-items:center;justify-content:center;
    background:linear-gradient(135deg,var(--ct-blue),var(--ct-indigo));color:#fff;border:none;
    font-size:1.1rem;cursor:pointer;transition:all .2s;box-shadow:0 3px 10px rgba(37,99,235,.25);}
.ct-input-btn:hover{transform:translateY(-2px) scale(1.05);box-shadow:0 6px 16px rgba(37,99,235,.35);}

/* Error */
.ct-error{background:#FEF2F2;border:1.5px solid #FECACA;border-radius:var(--border-radius-xl);
    padding:var(--space-xl);text-align:center;color:#991B1B;}
.ct-error-icon{font-size:2rem;margin-bottom:var(--space-sm);}
.ct-error-text{font-size:.9rem;font-weight:600;}

@media(max-width:767px){.ct-msg-content{max-width:80%;}.ct-messages{max-height:380px;min-height:280px;}.ct-msg-avatar{width:28px;height:28px;font-size:.6rem;}}
@media(max-width:479px){.ct-msg-content{max-width:85%;}}
</style>
</asp:Content>

<asp:Content ID="cSidebarMenu" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Main</div>
        <a href="<%: ResolveUrl("~/Student/Dashboard.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-speedometer2 item-icon"></i><span class="item-label">Dashboard</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/Notifications.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Learn</div>
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-book item-icon"></i><span class="item-label">My Learning</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/PracticeLibrary.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-patch-question item-icon"></i><span class="item-label">Practice Library</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/QuizHistory.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-clock-history item-icon"></i><span class="item-label">Quiz History</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/VirtualLabs.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-eyedropper item-icon"></i><span class="item-label">Virtual Labs</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/LiveSessions.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-camera-video item-icon"></i><span class="item-label">Live Sessions</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/AIStudyCompanion.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-robot item-icon"></i><span class="item-label">AI Study Companion</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Communication</div>
        <a href="<%: ResolveUrl("~/Student/Messages.aspx") %>" class="sb-sidebar-item active">
            <i class="bi bi-chat-dots item-icon"></i><span class="item-label">Messages</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/Forum.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-people item-icon"></i><span class="item-label">Forum</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Progress</div>
        <a href="<%: ResolveUrl("~/Student/ProgressRewards.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-bar-chart-line item-icon"></i><span class="item-label">Progress &amp; Rewards</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/MyRanking.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-trophy item-icon"></i><span class="item-label">My Ranking</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Student/MyProfile.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span>
        </a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">Chat</asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<!-- Back link -->
<a href="<%: ResolveUrl("~/Student/Messages.aspx") %>" class="ct-back">
    <i class="bi bi-arrow-left"></i> <asp:Literal ID="litBack" runat="server" Text="Back to Messages" />
</a>

<!-- Error panel -->
<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="ct-error">
        <div class="ct-error-icon"><i class="bi bi-exclamation-triangle-fill"></i></div>
        <div class="ct-error-text"><asp:Literal ID="litError" runat="server" Text="Chat not found or access denied." /></div>
    </div>
</asp:Panel>

<!-- Chat content -->
<asp:Panel ID="pnlChat" runat="server">

    <!-- Chat header -->
    <div class="ct-header">
        <div class="ct-header-avatar"><asp:Literal ID="litHeaderInitials" runat="server" /></div>
        <div class="ct-header-info">
            <div class="ct-header-name"><asp:Literal ID="litHeaderName" runat="server" /></div>
            <div class="ct-header-qual"><asp:Literal ID="litHeaderQual" runat="server" /></div>
        </div>
        <span class="ct-header-status"><asp:Literal ID="litHeaderStatus" runat="server" Text="Certified" /></span>
    </div>

    <!-- Messages -->
    <div class="ct-messages" id="divMessages">
        <asp:Panel ID="pnlMessages" runat="server">
            <asp:Repeater ID="rptMessages" runat="server">
                <ItemTemplate>
                    <div class='ct-msg-row <%# Convert.ToBoolean(Eval("IsMine")) ? "mine" : "other" %>'>
                        <div class="ct-msg-avatar"><%# Eval("SenderInitial") %></div>
                        <div class="ct-msg-content">
                            <div class="ct-msg-bubble"><%# Eval("MsgText") %></div>
                            <div class="ct-msg-meta"><i class="bi bi-clock"></i> <%# Eval("SentAt") %></div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </asp:Panel>
        <asp:Panel ID="pnlMessagesEmpty" runat="server" Visible="false">
            <div class="ct-empty">
                <div class="ct-empty-icon"><i class="bi bi-chat-heart-fill"></i></div>
                <div class="ct-empty-title"><asp:Literal ID="litEmptyTitle" runat="server" Text="No messages yet" /></div>
                <div class="ct-empty-text"><asp:Literal ID="litEmptyMsg" runat="server" Text="Start the conversation!" /></div>
            </div>
        </asp:Panel>
    </div>

    <!-- Input area -->
    <div class="ct-input">
        <asp:TextBox ID="txtMessage" runat="server" CssClass="ct-input-text"
            placeholder="Type your message..." MaxLength="4000" />
        <asp:LinkButton ID="btnSend" runat="server" CssClass="ct-input-btn"
            OnClick="btnSend_Click"><i class="bi bi-send-fill"></i></asp:LinkButton>
    </div>

</asp:Panel>

<script type="text/javascript">
    // Auto-scroll to bottom of messages
    var msgDiv = document.getElementById('divMessages');
    if (msgDiv) { msgDiv.scrollTop = msgDiv.scrollHeight; }
</script>

</asp:Content>
