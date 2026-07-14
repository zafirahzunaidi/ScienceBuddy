<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ForumReply.aspx.cs"
    Inherits="ScienceBuddy.Teacher.ForumReply" MasterPageFile="~/Site.Master" Title="Forum Discussion" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--tp:#6C63FF;--th:#5A52E0;--tl:#F5F3FF;--tc:#FFF;--tb:#E5E7EB;--tt:#374151;--tm:#6B7280;--ts:#10B981;--te:#EF4444;}
/* ── 2-column layout ── */
.frd-layout{display:grid;grid-template-columns:1fr 340px;gap:1.5rem;align-items:start;}
/* ── Back ── */
.frd-back{display:inline-flex;align-items:center;gap:6px;font-size:.82rem;font-weight:700;color:var(--tp);text-decoration:none;margin-bottom:1.25rem;transition:color .15s;}
.frd-back:hover{color:var(--th);text-decoration:none;}
/* ── Error ── */
.frd-err-card{background:#FEF2F2;border:1.5px solid #FECACA;border-radius:18px;padding:3rem 2rem;text-align:center;}
.frd-err-card i{font-size:2.8rem;color:var(--te);opacity:.55;margin-bottom:.75rem;display:block;}
.frd-err-title{font-size:1rem;font-weight:800;color:#991B1B;margin-bottom:.4rem;}
.frd-err-sub{font-size:.85rem;color:#B91C1C;margin-bottom:1.1rem;}
.frd-err-link{display:inline-flex;align-items:center;gap:6px;background:var(--tp);border:none;border-radius:10px;padding:.55rem 1.1rem;font-weight:700;font-size:.83rem;color:#fff;text-decoration:none;transition:background .2s;}
.frd-err-link:hover{background:var(--th);color:#fff;text-decoration:none;}
/* ── Main discussion card ── */
.frd-main-card{background:var(--tc);border:1.5px solid #D8D4FF;border-radius:18px;padding:1.75rem 2rem;box-shadow:0 6px 24px rgba(108,99,255,.09);margin-bottom:1.5rem;}
.frd-card-top{display:flex;align-items:flex-start;gap:14px;margin-bottom:1.1rem;}
.frd-avatar-lg{width:48px;height:48px;border-radius:50%;background:#EDE9FE;color:var(--tp);display:flex;align-items:center;justify-content:center;font-size:.95rem;font-weight:800;flex-shrink:0;border:2px solid #C4BFFF;}
.frd-creator-info{flex:1;min-width:0;}
.frd-creator-name{font-size:.9rem;font-weight:700;color:var(--tt);display:flex;align-items:center;gap:7px;flex-wrap:wrap;}
.frd-role-badge{font-size:.63rem;font-weight:700;padding:2px 8px;border-radius:5px;background:#DBEAFE;color:#1D4ED8;}
.frd-role-badge.teacher{background:#EDE9FE;color:var(--tp);}
.frd-role-badge.student{background:#D1FAE5;color:#047857;}
.frd-role-badge.parent{background:#FEF3C7;color:#92400E;}
.frd-pub-badge{font-size:.63rem;font-weight:700;padding:2px 8px;border-radius:5px;background:#F0FDF4;color:#15803D;border:1px solid #D1FAE5;}
.frd-date{font-size:.74rem;color:var(--tm);margin-top:3px;display:flex;align-items:center;gap:5px;}
.frd-post-title{font-size:1.25rem;font-weight:800;color:var(--tt);margin-bottom:.9rem;line-height:1.4;}
.frd-post-msg{font-size:.9rem;color:#4B5563;line-height:1.8;white-space:pre-wrap;word-break:break-word;margin-bottom:1.25rem;padding:1rem 1.1rem;background:#FAFAFA;border-radius:10px;border:1px solid #F0EDFF;}
.frd-main-footer{display:flex;align-items:center;gap:1rem;padding-top:1rem;border-top:1.5px solid #F0EDFF;flex-wrap:wrap;}
.frd-stat{font-size:.8rem;color:var(--tm);display:inline-flex;align-items:center;gap:5px;font-weight:600;}
.frd-like-btn{font-size:.8rem;font-weight:700;padding:5px 13px;border-radius:9px;border:1.5px solid;cursor:pointer;background:transparent;display:inline-flex;align-items:center;gap:5px;transition:all .15s;}
.frd-like-btn.liked{color:var(--te);border-color:#FEE2E2;background:#FEF2F2;}
.frd-like-btn.liked:hover{background:#FEE2E2;}
.frd-like-btn.notliked{color:var(--tm);border-color:var(--tb);}
.frd-like-btn.notliked:hover{color:var(--te);border-color:#FEE2E2;background:#FEF2F2;}
/* ── Reply composer ── */
.frd-composer-wrap{background:var(--tc);border:1.5px solid var(--tb);border-radius:16px;padding:1.1rem 1.25rem;box-shadow:0 2px 8px rgba(0,0,0,.03);margin-bottom:1.5rem;}
.frd-composer-inner{display:flex;align-items:flex-start;gap:10px;}
.frd-composer-avatar{width:36px;height:36px;border-radius:50%;background:#EDE9FE;color:var(--tp);display:flex;align-items:center;justify-content:center;font-size:.75rem;font-weight:800;flex-shrink:0;}
.frd-composer-right{flex:1;min-width:0;}
.frd-composer-ta{width:100%;border-radius:12px;border:1.5px solid var(--tb);padding:.65rem .85rem;font-size:.85rem;line-height:1.6;resize:none;min-height:80px;font-family:inherit;transition:border-color .2s,box-shadow .2s;box-sizing:border-box;}
.frd-composer-ta:focus{border-color:var(--tp);outline:none;box-shadow:0 0 0 3px rgba(108,99,255,.08);}
.frd-composer-actions{display:flex;align-items:center;justify-content:space-between;margin-top:.6rem;flex-wrap:wrap;gap:.4rem;}
.frd-val-msg{font-size:.75rem;color:var(--te);font-weight:600;display:flex;align-items:center;gap:4px;}
.frd-send-btn{width:36px;height:36px;border-radius:50%;background:var(--tp);border:none;color:#fff;cursor:pointer;display:flex;align-items:center;justify-content:center;font-size:.9rem;flex-shrink:0;transition:background .2s,transform .15s,box-shadow .2s;box-shadow:0 2px 8px rgba(108,99,255,.22);}
.frd-send-btn:hover{background:var(--th);transform:scale(1.08);box-shadow:0 4px 14px rgba(108,99,255,.32);}
/* ── Comments ── */
.frd-comments-hd{display:flex;align-items:center;gap:.75rem;margin-bottom:1rem;}
.frd-comments-hd h2{font-size:1rem;font-weight:800;color:var(--tt);margin:0;}
.frd-count-badge{font-size:.72rem;font-weight:700;background:var(--tl);color:var(--tp);padding:2px 10px;border-radius:20px;}
.frd-reply-list{display:flex;flex-direction:column;gap:.75rem;margin-bottom:1.5rem;}
.frd-reply{background:var(--tc);border:1.5px solid var(--tb);border-radius:14px;padding:.9rem 1.1rem;transition:box-shadow .15s;position:relative;overflow:hidden;}
.frd-reply:hover{box-shadow:0 4px 16px rgba(108,99,255,.07);}
.frd-reply::after{content:'';position:absolute;bottom:0;left:0;right:0;height:3px;}
.frd-reply.accent-student::after{background:#818CF8;}
.frd-reply.accent-parent::after{background:#FBBF24;}
.frd-reply.accent-teacher::after{background:#A78BFA;}
.frd-reply-top{display:flex;align-items:flex-start;gap:10px;margin-bottom:.5rem;}
.frd-avatar-sm{width:34px;height:34px;border-radius:50%;background:#EDE9FE;color:var(--tp);display:flex;align-items:center;justify-content:center;font-size:.72rem;font-weight:800;flex-shrink:0;}
.frd-reply-meta{flex:1;}
.frd-reply-name{font-size:.83rem;font-weight:700;color:var(--tt);display:flex;align-items:center;gap:6px;flex-wrap:wrap;}
.frd-reply-date{font-size:.7rem;color:var(--tm);margin-top:2px;display:flex;align-items:center;gap:4px;}
.frd-reply-msg{font-size:.84rem;color:#4B5563;line-height:1.65;white-space:pre-wrap;word-break:break-word;padding-left:44px;}
.frd-empty{display:flex;flex-direction:column;align-items:center;text-align:center;padding:2.25rem 1.5rem;background:#FAFAFA;border:1.5px dashed var(--tb);border-radius:14px;margin-bottom:1.5rem;}
.frd-empty i{font-size:2.2rem;color:var(--tm);opacity:.3;margin-bottom:.6rem;}
.frd-empty-title{font-size:.9rem;font-weight:700;color:var(--tt);margin-bottom:.2rem;}
.frd-empty-sub{font-size:.78rem;color:var(--tm);}
/* ── Right sidebar ── */
.frd-sidebar{display:flex;flex-direction:column;gap:1.25rem;}
.frd-sidebar-card{background:var(--tc);border:1.5px solid var(--tb);border-radius:16px;padding:1.1rem 1.25rem;box-shadow:0 2px 8px rgba(0,0,0,.03);}
.frd-sidebar-title{font-size:.82rem;font-weight:800;color:var(--tt);margin-bottom:.9rem;display:flex;align-items:center;gap:6px;border-bottom:1px solid var(--tb);padding-bottom:.6rem;}
.frd-more-list{display:flex;flex-direction:column;gap:.75rem;}
.frd-more-item{display:flex;align-items:flex-start;gap:9px;padding:.7rem .8rem;background:#FAFAFA;border:1px solid var(--tb);border-radius:10px;position:relative;overflow:hidden;}
.frd-more-item::after{content:'';position:absolute;bottom:0;left:0;right:0;height:3px;}
.frd-more-item.accent-student::after{background:#818CF8;}
.frd-more-item.accent-parent::after{background:#FBBF24;}
.frd-more-item.accent-teacher::after{background:#A78BFA;}
.frd-more-avatar{width:30px;height:30px;border-radius:50%;background:#EDE9FE;color:var(--tp);display:flex;align-items:center;justify-content:center;font-size:.65rem;font-weight:800;flex-shrink:0;}
.frd-more-info{flex:1;min-width:0;}
.frd-more-name{font-size:.82rem;font-weight:800;color:var(--tt);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.frd-more-date{font-size:.67rem;color:var(--tm);margin-bottom:2px;}
.frd-more-title{font-size:.82rem;color:var(--tt);font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;margin-bottom:4px;}
.frd-more-link{font-size:.78rem;font-weight:700;color:#4338CA;text-decoration:none;margin-top:2px;display:inline-block;}
.frd-more-link:hover{color:#3730A3;text-decoration:underline;}
.frd-part-list{display:flex;flex-direction:column;gap:.6rem;}
.frd-part-item{display:flex;align-items:center;gap:9px;}
.frd-part-avatar{width:30px;height:30px;border-radius:50%;background:#EDE9FE;color:var(--tp);display:flex;align-items:center;justify-content:center;font-size:.65rem;font-weight:800;flex-shrink:0;}
.frd-part-name{font-size:.78rem;font-weight:600;color:var(--tt);}
/* ── Toast ── */
.frd-toast-wrap{position:fixed;top:1.25rem;right:1.25rem;z-index:9999;}
.frd-toast{background:var(--ts);color:#fff;padding:.7rem 1.1rem;border-radius:10px;font-size:.82rem;font-weight:600;display:flex;align-items:center;gap:6px;box-shadow:0 6px 18px rgba(16,185,129,.25);animation:frdIn .3s ease;}
@keyframes frdIn{from{opacity:0;transform:translateY(-8px);}to{opacity:1;transform:translateY(0);}}
@media(max-width:900px){.frd-layout{grid-template-columns:1fr;}}
@media(max-width:600px){.frd-main-card{padding:1.1rem;}.frd-reply-msg{padding-left:0;margin-top:.5rem;}}
/* Pending License Notice */
.frd-pending-notice{display:flex;align-items:flex-start;gap:.75rem;padding:.85rem 1.1rem;margin-bottom:1rem;background:#FEF2F2;border:1.5px solid #FECACA;border-left:4px solid #DC2626;border-radius:10px;}
.frd-pending-notice-icon{flex-shrink:0;width:32px;height:32px;border-radius:8px;background:#FEE2E2;color:#DC2626;display:flex;align-items:center;justify-content:center;font-size:1rem;}
.frd-pending-notice-content{flex:1;min-width:0;}
.frd-pending-notice-title{font-size:.84rem;font-weight:700;color:#991B1B;margin-bottom:2px;}
.frd-pending-notice-msg{font-size:.78rem;color:#B91C1C;line-height:1.45;}
.frd-composer-ta[disabled]{opacity:.6;cursor:not-allowed;background:#F9FAFB;}
.frd-send-btn[disabled]{opacity:.5;cursor:not-allowed;background:#9CA3AF !important;box-shadow:none !important;}
</style>
</asp:Content>

<%-- ════ SIDEBAR MENU ════ --%>
<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a></div>
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

<%-- ════ MAIN CONTENT ════ --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

    <%-- Back link --%>
    <a href="<%: ResolveUrl("~/Teacher/Forum.aspx") %>" class="frd-back">
        <i class="bi bi-arrow-left"></i> <%: T("Back to Forum","Kembali ke Forum") %>
    </a>

    <%-- ── Error panel ── --%>
    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="frd-err-card">
            <i class="bi bi-exclamation-triangle-fill"></i>
            <div class="frd-err-title"><%: T("Discussion Not Found","Perbincangan Tidak Dijumpai") %></div>
            <div class="frd-err-sub"><asp:Literal ID="litErrMsg" runat="server" /></div>
            <a href="<%: ResolveUrl("~/Teacher/Forum.aspx") %>" class="frd-err-link">
                <i class="bi bi-arrow-left"></i> <%: T("Back to Forum","Kembali ke Forum") %>
            </a>
        </div>
    </asp:Panel>

    <%-- ── Main content (2-column) ── --%>
    <asp:Panel ID="pnlMain" runat="server" Visible="false">
    <div class="frd-layout">

        <%-- ══ LEFT COLUMN ══ --%>
        <div class="frd-left-col">

            <%-- Discussion card --%>
            <div class="frd-main-card">
                <div class="frd-card-top">
                    <div class="frd-avatar-lg"><asp:Literal ID="litInitials" runat="server" /></div>
                    <div class="frd-creator-info">
                        <div class="frd-creator-name">
                            <asp:Literal ID="litCreatorName" runat="server" />
                            <asp:Literal ID="litRoleBadge" runat="server" />
                        </div>
                        <div class="frd-date"><i class="bi bi-clock"></i> <asp:Literal ID="litPostDate" runat="server" /></div>
                    </div>
                </div>
                <div class="frd-post-title"><asp:Literal ID="litTitle" runat="server" /></div>
                <div class="frd-post-msg"><asp:Literal ID="litMessage" runat="server" /></div>
                <div class="frd-main-footer">
                    <span class="frd-stat"><i class="bi bi-chat-text"></i> <asp:Literal ID="litReplyCount" runat="server" /> <%: T("replies","balasan") %></span>
                    <asp:LinkButton ID="btnLike" runat="server" OnClick="btnLike_Click" CausesValidation="false" />
                </div>
            </div>

            <%-- Pending License Notice (above reply textbox) --%>
            <asp:HiddenField ID="hidLicenseStatus" runat="server" Value="" />
            <div id="frdPendingNotice" class="frd-pending-notice" style="display:none;">
                <div class="frd-pending-notice-icon"><i class="bi bi-shield-exclamation"></i></div>
                <div class="frd-pending-notice-content">
                    <div class="frd-pending-notice-title"><%: T("Verification Pending","Pengesahan Menunggu") %></div>
                    <div class="frd-pending-notice-msg"><%: T("Your Teaching License is still under review. Replying to forum discussions is temporarily unavailable until your verification has been approved.","Lesen Mengajar anda masih dalam semakan. Membalas perbincangan forum tidak tersedia buat sementara waktu sehingga pengesahan anda diluluskan.") %></div>
                </div>
            </div>

            <%-- Reply composer --%>
            <div class="frd-composer-wrap">
                <div class="frd-composer-right" style="width:100%;">
                    <asp:TextBox ID="txtReply" runat="server" CssClass="frd-composer-ta" TextMode="MultiLine" Rows="3" />
                    <div class="frd-composer-actions">
                        <asp:Panel ID="pnlReplyVal" runat="server" Visible="false">
                            <span class="frd-val-msg"><i class="bi bi-exclamation-circle-fill"></i> <asp:Literal ID="litReplyVal" runat="server" /></span>
                        </asp:Panel>
                        <span></span>
                        <asp:Button ID="btnPostReply" runat="server" CssClass="frd-send-btn"
                            OnClick="btnPostReply_Click" CausesValidation="false"
                            Text="&#9992;" />
                    </div>
                </div>
            </div>

            <%-- Comments heading --%>
            <div class="frd-comments-hd">
                <h2><%: T("Comments","Komen") %></h2>
                <span class="frd-count-badge"><asp:Literal ID="litRepliesBadge" runat="server" /></span>
            </div>

            <%-- Reply list --%>
            <asp:Panel ID="pnlReplies" runat="server" Visible="false">
                <div class="frd-reply-list">
                    <asp:Repeater ID="rptReplies" runat="server">
                        <ItemTemplate>
                            <div class='frd-reply accent-<%# Eval("roleCss") %>'>
                                <div class="frd-reply-top">
                                    <div class="frd-avatar-sm"><%# Eval("initials") %></div>
                                    <div class="frd-reply-meta">
                                        <div class="frd-reply-name">
                                            <%# HttpUtility.HtmlEncode(Eval("senderName").ToString()) %>
                                            <span class='frd-role-badge <%# Eval("roleCss") %>'><%# Eval("roleLabel") %></span>
                                        </div>
                                        <div class="frd-reply-date"><i class="bi bi-clock"></i> <%# Eval("timeAgo") %></div>
                                    </div>
                                </div>
                                <div class="frd-reply-msg"><%# HttpUtility.HtmlEncode(Eval("message").ToString()) %></div>
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

        </div><%-- /.frd-left-col --%>

        <%-- ══ RIGHT SIDEBAR ══ --%>
        <div class="frd-sidebar">

            <%-- More Discussions --%>
            <div class="frd-sidebar-card">
                <div class="frd-sidebar-title"><i class="bi bi-collection" style="color:var(--tp);"></i> <%: T("More Discussions","Perbincangan Lain") %></div>
                <asp:Panel ID="pnlMoreDiscussions" runat="server">
                    <div class="frd-more-list">
                        <asp:Repeater ID="rptMore" runat="server">
                            <ItemTemplate>
                                <div class='frd-more-item accent-<%# Eval("roleCss") %>'>
                                    <div class="frd-more-avatar"><%# Eval("initials") %></div>
                                    <div class="frd-more-info">
                                        <div class="frd-more-name"><%# HttpUtility.HtmlEncode(Eval("creatorName").ToString()) %></div>
                                        <div class="frd-more-date"><%# Eval("timeAgo") %></div>
                                        <div class="frd-more-title"><%# HttpUtility.HtmlEncode(Eval("title").ToString()) %></div>
                                        <a href='<%# ResolveUrl("~/Teacher/ForumReply.aspx") + "?forumId=" + Eval("forumId") %>' class="frd-more-link"><%: T("View Discussion →","Lihat Perbincangan →") %></a>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </asp:Panel>
            </div>

        </div><%-- /.frd-sidebar --%>

    </div><%-- /.frd-layout --%>
    </asp:Panel>

    <asp:HiddenField ID="hidToast"   runat="server" Value="" />
    <asp:HiddenField ID="hidForumId" runat="server" Value="" />
    <div class="frd-toast-wrap" id="frdToastWrap"></div>

</asp:Content>

<%-- ════ SCRIPTS ════ --%>
<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
(function () {
    // Toast
    var h = document.getElementById('<%=hidToast.ClientID%>');
    if (h && h.value) {
        var wrap = document.getElementById('frdToastWrap');
        var t = document.createElement('div');
        t.className = 'frd-toast';
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
