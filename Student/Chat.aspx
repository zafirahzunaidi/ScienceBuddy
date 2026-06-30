<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Chat.aspx.cs"
    Inherits="ScienceBuddy.Student.ChatPage" MasterPageFile="~/Site.Master"
    Title="Chat" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* -- Student Chat Page -- */
:root{--ct-blue:#2563EB;--ct-blue-light:#EFF6FF;--ct-blue-dark:#1D4ED8;--ct-grey:#F3F4F6;}

.ct-back{display:inline-flex;align-items:center;gap:6px;font-size:.875rem;font-weight:600;
    color:var(--ct-blue);text-decoration:none;margin-bottom:var(--space-md);
    transition:color .2s;}
.ct-back:hover{color:var(--ct-blue-dark);text-decoration:none;}

/* Chat header */
.ct-header{background:var(--color-white);border-radius:var(--border-radius-lg);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);
    padding:var(--space-lg);display:flex;align-items:center;gap:var(--space-md);
    margin-bottom:var(--space-md);}
.ct-header-avatar{width:48px;height:48px;border-radius:50%;
    background:var(--ct-blue-light);color:var(--ct-blue);
    display:flex;align-items:center;justify-content:center;
    font-size:1.125rem;font-weight:800;flex-shrink:0;}
.ct-header-info{flex:1;}
.ct-header-name{font-family:var(--font-primary);font-weight:700;font-size:1.125rem;
    color:var(--color-text);margin-bottom:2px;}
.ct-header-qual{font-size:.8125rem;color:var(--color-text-secondary);}
.ct-header-status{font-size:.75rem;font-weight:700;padding:3px 10px;
    border-radius:var(--border-radius-full);background:#DCFCE7;color:#15803D;}

/* Messages area */
.ct-messages{background:var(--color-white);border-radius:var(--border-radius-lg);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);
    padding:var(--space-lg);min-height:400px;max-height:500px;overflow-y:auto;
    margin-bottom:var(--space-md);display:flex;flex-direction:column;gap:var(--space-md);}
.ct-msg{display:flex;flex-direction:column;max-width:70%;}
.ct-msg.ct-msg-mine{align-self:flex-end;align-items:flex-end;}
.ct-msg.ct-msg-other{align-self:flex-start;align-items:flex-start;}
.ct-msg-bubble{padding:var(--space-sm) var(--space-md);border-radius:var(--border-radius-lg);
    font-size:.9rem;line-height:1.5;word-wrap:break-word;}
.ct-msg-mine .ct-msg-bubble{background:var(--ct-blue);color:#fff;
    border-bottom-right-radius:4px;}
.ct-msg-other .ct-msg-bubble{background:var(--ct-grey);color:var(--color-text);
    border-bottom-left-radius:4px;}
.ct-msg-meta{font-size:.7rem;color:var(--color-text-muted);margin-top:3px;
    display:flex;align-items:center;gap:4px;}
.ct-msg-sender{font-size:.75rem;font-weight:600;color:var(--color-text-secondary);margin-bottom:2px;}

/* Empty messages */
.ct-empty{text-align:center;padding:var(--space-2xl) var(--space-xl);color:var(--color-text-muted);}
.ct-empty-icon{font-size:2.5rem;margin-bottom:var(--space-sm);}
.ct-empty-text{font-size:.9rem;}

/* Input area */
.ct-input{background:var(--color-white);border-radius:var(--border-radius-lg);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);
    padding:var(--space-md);display:flex;align-items:center;gap:var(--space-sm);}
.ct-input-text{flex:1;border:1.5px solid var(--border-color);border-radius:var(--border-radius-full);
    padding:10px 16px;font-size:.9rem;outline:none;transition:border-color .2s;
    font-family:inherit;}
.ct-input-text:focus{border-color:var(--ct-blue);}
.ct-input-btn{display:inline-flex;align-items:center;gap:6px;padding:10px 20px;
    background:var(--ct-blue);color:#fff;border:none;border-radius:var(--border-radius-full);
    font-size:.875rem;font-weight:700;cursor:pointer;transition:background .2s;}
.ct-input-btn:hover{background:var(--ct-blue-dark);}

/* Error panel */
.ct-error{background:#FEF2F2;border:1.5px solid #FECACA;border-radius:var(--border-radius-lg);
    padding:var(--space-xl);text-align:center;color:#991B1B;}
.ct-error-icon{font-size:2rem;margin-bottom:var(--space-sm);}
.ct-error-text{font-size:.9rem;font-weight:600;}

@media(max-width:767px){
    .ct-msg{max-width:85%;}
    .ct-messages{max-height:350px;min-height:300px;}
}
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
        <div class="sb-nav-section-label">Progress</div>
        <a href="<%: ResolveUrl("~/Student/ProgressRewards.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-bar-chart-line item-icon"></i><span class="item-label">Progress &amp; Rewards</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/Forum.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-chat-dots item-icon"></i><span class="item-label">Forum</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/Messages.aspx") %>" class="sb-sidebar-item active">
            <i class="bi bi-envelope item-icon"></i><span class="item-label">Messages</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Student/MyProfile.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span>
        </a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span>
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
                    <div class='<%# Convert.ToBoolean(Eval("IsMine")) ? "ct-msg ct-msg-mine" : "ct-msg ct-msg-other" %>'>
                        <div class="ct-msg-sender" style='<%# Convert.ToBoolean(Eval("IsMine")) ? "display:none" : "" %>'><%# Eval("SenderName") %></div>
                        <div class="ct-msg-bubble"><%# Eval("MsgText") %></div>
                        <div class="ct-msg-meta">
                            <i class="bi bi-clock"></i> <%# Eval("SentAt") %>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </asp:Panel>
        <asp:Panel ID="pnlMessagesEmpty" runat="server" Visible="false">
            <div class="ct-empty">
                <div class="ct-empty-icon">💬</div>
                <div class="ct-empty-text"><asp:Literal ID="litEmptyMsg" runat="server" Text="No messages yet. Start the conversation!" /></div>
            </div>
        </asp:Panel>
    </div>

    <!-- Input area -->
    <div class="ct-input">
        <asp:TextBox ID="txtMessage" runat="server" CssClass="ct-input-text"
            placeholder="Type your message..." MaxLength="4000" />
        <asp:Button ID="btnSend" runat="server" CssClass="ct-input-btn"
            Text="Send" OnClick="btnSend_Click" />
    </div>

</asp:Panel>

<script type="text/javascript">
    // Auto-scroll to bottom of messages
    var msgDiv = document.getElementById('divMessages');
    if (msgDiv) { msgDiv.scrollTop = msgDiv.scrollHeight; }
</script>

</asp:Content>
