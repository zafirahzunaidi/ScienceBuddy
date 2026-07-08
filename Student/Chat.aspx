<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Chat.aspx.cs"
    Inherits="ScienceBuddy.Student.Chat" MasterPageFile="~/Site.Master"
    Title="Chat" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Student.css") %>" rel="stylesheet" />
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
<a href="<%: ResolveUrl("~/Student/Messages.aspx") %>" class="st-chat-back">
    <i class="bi bi-arrow-left"></i> <asp:Literal ID="litBack" runat="server" Text="Back to Messages" />
</a>

<!-- Error panel -->
<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="st-chat-error">
        <div class="st-chat-error-icon"><i class="bi bi-exclamation-triangle-fill"></i></div>
        <div class="st-chat-error-text"><asp:Literal ID="litError" runat="server" Text="Chat not found or access denied." /></div>
    </div>
</asp:Panel>

<!-- Chat content -->
<asp:Panel ID="pnlChat" runat="server">

    <!-- Chat header -->
    <div class="st-chat-header">
        <div class="st-chat-header-avatar"><asp:Literal ID="litHeaderInitials" runat="server" /></div>
        <div class="st-chat-header-info">
            <div class="st-chat-header-name"><asp:Literal ID="litHeaderName" runat="server" /></div>
            <div class="st-chat-header-qual"><asp:Literal ID="litHeaderQual" runat="server" /></div>
        </div>
        <span class="st-chat-header-status"><asp:Literal ID="litHeaderStatus" runat="server" Text="Certified" /></span>
    </div>

    <!-- Messages -->
    <div class="st-chat-messages" id="divMessages">
        <asp:Panel ID="pnlMessages" runat="server">
            <asp:Repeater ID="rptMessages" runat="server">
                <ItemTemplate>
                    <div class='st-chat-msg-row <%# Convert.ToBoolean(Eval("IsMine")) ? "mine" : "other" %>'>
                        <div class="st-chat-msg-avatar"><%# Eval("SenderInitial") %></div>
                        <div class="st-chat-msg-content">
                            <div class="st-chat-msg-bubble"><%# Eval("MsgText") %></div>
                            <div class="st-chat-msg-meta"><i class="bi bi-clock"></i> <%# Eval("SentAt") %></div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </asp:Panel>
        <asp:Panel ID="pnlMessagesEmpty" runat="server" Visible="false">
            <div class="st-chat-empty">
                <div class="st-chat-empty-icon"><i class="bi bi-chat-heart-fill"></i></div>
                <div class="st-chat-empty-title"><asp:Literal ID="litEmptyTitle" runat="server" Text="No messages yet" /></div>
                <div class="st-chat-empty-text"><asp:Literal ID="litEmptyMsg" runat="server" Text="Start the conversation!" /></div>
            </div>
        </asp:Panel>
    </div>

    <!-- Input area -->
    <div class="st-chat-input">
        <asp:TextBox ID="txtMessage" runat="server" CssClass="st-chat-input-text"
            placeholder="Type your message..." MaxLength="4000" />
        <asp:LinkButton ID="btnSend" runat="server" CssClass="st-chat-input-btn"
            OnClick="btnSend_Click"><i class="bi bi-send-fill"></i></asp:LinkButton>
    </div>

</asp:Panel>

<script type="text/javascript">
    // Auto-scroll to bottom of messages
    var msgDiv = document.getElementById('divMessages');
    if (msgDiv) { msgDiv.scrollTop = msgDiv.scrollHeight; }
</script>

</asp:Content>
