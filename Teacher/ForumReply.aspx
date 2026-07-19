<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ForumReply.aspx.cs"
    Inherits="ScienceBuddy.Teacher.ForumReply" MasterPageFile="~/Site.Master" Title="Forum Discussion" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Teacher.css") %>" rel="stylesheet" />
</asp:Content>

<%-- ---- SIDEBAR MENU ---- --%>
<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label"><%: T("Notifications","Notifikasi") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Teaching","Pengajaran") %></div>
        <a href="<%: ResolveUrl("~/Teacher/manageMaterials.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label"><%: T("Manage Materials","Bahan Pembelajaran") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label"><%: T("Manage Quiz","Kuiz") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/studentProgress.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bar-chart item-icon"></i><span class="item-label"><%: T("Student Progress","Prestasi Pelajar") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/liveSession.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label"><%: T("Schedule Live Class","Kelas Langsung") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Community","Komuniti") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Forum.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/privateMessages.aspx") %>" class="sb-sidebar-item"><i class="bi bi-envelope item-icon"></i><span class="item-label"><%: T("Private Message","Mesej Peribadi") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Account","Akaun") %></div>
        <a href="<%: ResolveUrl("~/Teacher/MyProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("My Profile","Profil Saya") %></span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Sign Out","Log Keluar") %></span></a></div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Forum Discussion","Perbincangan Forum") %></asp:Content>

<%-- ---- MAIN CONTENT ---- --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

    <%-- Back link --%>
    <a href="<%: ResolveUrl("~/Teacher/Forum.aspx") %>" class="tc-forum-reply-back">
        <i class="bi bi-arrow-left"></i> <%: T("Back to Forum","Kembali ke Forum") %>
    </a>

    <%-- -- Error panel -- --%>
    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="tc-forum-reply-err-card">
            <i class="bi bi-exclamation-triangle-fill"></i>
            <div class="tc-forum-reply-err-title"><%: T("Discussion Not Found","Perbincangan Tidak Dijumpai") %></div>
            <div class="tc-forum-reply-err-sub"><asp:Literal ID="litErrMsg" runat="server" /></div>
            <a href="<%: ResolveUrl("~/Teacher/Forum.aspx") %>" class="tc-forum-reply-err-link">
                <i class="bi bi-arrow-left"></i> <%: T("Back to Forum","Kembali ke Forum") %>
            </a>
        </div>
    </asp:Panel>

    <%-- -- Main content (2-column) -- --%>
    <asp:Panel ID="pnlMain" runat="server" Visible="false">
    <div class="tc-forum-reply-layout">

        <%-- -- LEFT COLUMN -- --%>
        <div class="tc-forum-reply-left-col">

            <%-- Discussion card --%>
            <div class="tc-forum-reply-main-card">
                <div class="tc-forum-reply-card-top">
                    <div class="tc-forum-reply-avatar-lg"><asp:Literal ID="litInitials" runat="server" /></div>
                    <div class="tc-forum-reply-creator-info">
                        <div class="tc-forum-reply-creator-name">
                            <asp:Literal ID="litCreatorName" runat="server" />
                            <asp:Literal ID="litRoleBadge" runat="server" />
                        </div>
                        <div class="tc-forum-reply-date"><i class="bi bi-clock"></i> <asp:Literal ID="litPostDate" runat="server" /></div>
                    </div>
                </div>
                <div class="tc-forum-reply-post-title"><asp:Literal ID="litTitle" runat="server" /></div>
                <div class="tc-forum-reply-post-msg"><asp:Literal ID="litMessage" runat="server" /></div>
                <div class="tc-forum-reply-main-footer">
                    <span class="tc-forum-reply-stat"><i class="bi bi-chat-text"></i> <asp:Literal ID="litReplyCount" runat="server" /> <%: T("replies","balasan") %></span>
                    <asp:LinkButton ID="btnLike" runat="server" OnClick="btnLike_Click" CausesValidation="false" />
                </div>
            </div>

            <%-- Pending License Notice (above reply textbox) --%>
            <asp:HiddenField ID="hidLicenseStatus" runat="server" Value="" />
            <div id="frdPendingNotice" class="tc-forum-reply-pending-notice" style="display:none;">
                <div class="tc-forum-reply-pending-notice-icon"><i class="bi bi-shield-exclamation"></i></div>
                <div class="tc-forum-reply-pending-notice-content">
                    <div class="tc-forum-reply-pending-notice-title"><%: T("Verification Pending","Pengesahan Menunggu") %></div>
                    <div class="tc-forum-reply-pending-notice-msg"><%: T("Your Teaching License is still under review. Replying to forum discussions is temporarily unavailable until your verification has been approved.","Lesen Mengajar anda masih dalam semakan. Membalas perbincangan forum tidak tersedia buat sementara waktu sehingga pengesahan anda diluluskan.") %></div>
                </div>
            </div>

            <%-- Reply composer --%>
            <div class="tc-forum-reply-composer-wrap">
                <div class="tc-forum-reply-composer-row">
                    <asp:TextBox ID="txtReply" runat="server" CssClass="tc-forum-reply-composer-ta" TextMode="MultiLine" Rows="1" placeholder="Write a reply..." />
                    <asp:LinkButton ID="btnPostReply" runat="server" CssClass="tc-forum-reply-send-btn"
                        OnClick="btnPostReply_Click" CausesValidation="false">
                        <i class="bi bi-send-fill"></i>
                    </asp:LinkButton>
                </div>
                <asp:Panel ID="pnlReplyVal" runat="server" Visible="false" CssClass="tc-forum-reply-composer-val">
                    <span class="tc-forum-reply-val-msg"><i class="bi bi-exclamation-circle-fill"></i> <asp:Literal ID="litReplyVal" runat="server" /></span>
                </asp:Panel>
            </div>

            <%-- Comments heading --%>
            <div class="tc-forum-reply-comments-hd">
                <h2><%: T("Comments","Komen") %></h2>
                <span class="tc-forum-reply-count-badge"><asp:Literal ID="litRepliesBadge" runat="server" /></span>
            </div>

            <%-- Reply list --%>
            <asp:Panel ID="pnlReplies" runat="server" Visible="false">
                <div class="tc-forum-reply-reply-list">
                    <asp:Repeater ID="rptReplies" runat="server">
                        <ItemTemplate>
                            <div class='tc-forum-reply-reply accent-<%# Eval("roleCss") %>'>
                                <div class="tc-forum-reply-reply-top">
                                    <div class="tc-forum-reply-avatar-sm"><%# Eval("initials") %></div>
                                    <div class="tc-forum-reply-reply-meta">
                                        <div class="tc-forum-reply-reply-name">
                                            <%# HttpUtility.HtmlEncode(Eval("senderName").ToString()) %>
                                            <span class='tc-forum-reply-role-badge <%# Eval("roleCss") %>'><%# Eval("roleLabel") %></span>
                                        </div>
                                        <div class="tc-forum-reply-reply-date"><i class="bi bi-clock"></i> <%# Eval("timeAgo") %></div>
                                    </div>
                                </div>
                                <div class="tc-forum-reply-reply-msg"><%# HttpUtility.HtmlEncode(Eval("message").ToString()) %></div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </asp:Panel>

            <%-- Empty replies --%>
            <asp:Panel ID="pnlRepliesEmpty" runat="server" Visible="false">
                <div style="text-align:center;padding:1.5rem;color:var(--tm);font-size:.88rem;font-weight:600;">
                    <%: T("No replies yet.","Belum ada balasan.") %>
                </div>
            </asp:Panel>

        </div><%-- /.tc-forum-reply-left-col --%>

        <%-- -- RIGHT SIDEBAR -- --%>
        <div class="tc-forum-reply-sidebar">

            <%-- More Discussions --%>
            <div class="tc-forum-reply-sidebar-card">
                <div class="tc-forum-reply-sidebar-title"><i class="bi bi-collection" style="color:var(--tp);"></i> <%: T("More Discussions","Perbincangan Lain") %></div>
                <asp:Panel ID="pnlMoreDiscussions" runat="server">
                    <div class="tc-forum-reply-more-list">
                        <asp:Repeater ID="rptMore" runat="server">
                            <ItemTemplate>
                                <div class='tc-forum-reply-more-item accent-<%# Eval("roleCss") %>'>
                                    <div class="tc-forum-reply-more-avatar"><%# Eval("initials") %></div>
                                    <div class="tc-forum-reply-more-info">
                                        <div class="tc-forum-reply-more-name"><%# HttpUtility.HtmlEncode(Eval("creatorName").ToString()) %></div>
                                        <div class="tc-forum-reply-more-date"><%# Eval("timeAgo") %></div>
                                        <div class="tc-forum-reply-more-title"><%# HttpUtility.HtmlEncode(Eval("title").ToString()) %></div>
                                        <a href='<%# ResolveUrl("~/Teacher/ForumReply.aspx") + "?forumId=" + Eval("forumId") %>' class="tc-forum-reply-more-link"><%: T("View Discussion ?","Lihat Perbincangan ?") %></a>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </asp:Panel>
            </div>

        </div><%-- /.tc-forum-reply-sidebar --%>

    </div><%-- /.tc-forum-reply-layout --%>
    </asp:Panel>

    <asp:HiddenField ID="hidToast"   runat="server" Value="" />
    <asp:HiddenField ID="hidForumId" runat="server" Value="" />
    <div class="tc-forum-reply-toast-wrap" id="frdToastWrap"></div>

</asp:Content>

<%-- ---- SCRIPTS ---- --%>
<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
(function () {
    // Toast
    var h = document.getElementById('<%=hidToast.ClientID%>');
    if (h && h.value) {
        var wrap = document.getElementById('frdToastWrap');
        var t = document.createElement('div');
        t.className = 'tc-forum-reply-toast';
        t.innerHTML = '<i class="bi bi-check-circle-fill"></i> ' + h.value;
        wrap.appendChild(t);
        h.value = '';
        setTimeout(function () { t.style.opacity = '0'; t.style.transition = 'opacity .3s'; }, 2500);
        setTimeout(function () { if (t.parentNode) t.parentNode.removeChild(t); }, 3000);
    }
    // Textarea focus ring
    var ta = document.getElementById('<%=txtReply.ClientID%>');
    if (ta) {
        ta.addEventListener('focus', function () { this.style.borderColor = '#6C63FF'; this.style.boxShadow = '0 0 0 3px rgba(108,99,255,.08)'; });
        ta.addEventListener('blur',  function () { this.style.borderColor = '#E5E7EB'; this.style.boxShadow = 'none'; });
    }
    // Pending License: show notice
    var lic = document.getElementById('<%=hidLicenseStatus.ClientID%>');
    if (lic && lic.value === 'Pending') {
        var notice = document.getElementById('frdPendingNotice');
        if (notice) notice.style.display = 'flex';
    }
}());
</script>
</asp:Content>
