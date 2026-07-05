<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ChildProfile.aspx.cs"
    Inherits="ScienceBuddy.Parent.ChildProfile" MasterPageFile="~/Site.Master"
    Title="Child Profile" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.cp-page { padding: 24px 0; max-width: 800px; margin: 0 auto; }
.cp-card { background:#fff; border-radius:20px; box-shadow:0 2px 16px rgba(0,0,0,0.05); padding:24px 28px; margin-bottom:20px; }

/* Identity */
.cp-identity { display:flex; align-items:center; gap:16px; flex-wrap:wrap; }
.cp-avatar { width:58px; height:58px; border-radius:50%; background:linear-gradient(135deg,#2563EB,#60A5FA); color:#fff; font-size:1.3rem; font-weight:800; display:flex; align-items:center; justify-content:center; flex-shrink:0; box-shadow:0 4px 12px rgba(37,99,235,0.2); }
.cp-id-info { flex:1; }
.cp-id-name { font-size:1.15rem; font-weight:800; color:#1E293B; margin:0 0 2px; }
.cp-id-meta { font-size:0.82rem; color:#64748B; }
.cp-id-pills { display:flex; gap:8px; flex-wrap:wrap; margin-top:6px; }
.cp-id-pill { display:inline-flex; align-items:center; gap:4px; padding:3px 10px; border-radius:999px; font-size:0.72rem; font-weight:700; }
.cp-id-pill.level { background:#DBEAFE; color:#1D4ED8; }
.cp-id-pill.rel { background:#FEF3C7; color:#92400E; }

/* Section title */
.cp-sec-title { font-size:1rem; font-weight:800; color:#1E293B; margin:0 0 14px; display:flex; align-items:center; gap:8px; }
.cp-sec-title i { color:#2563EB; font-size:1.05rem; }

/* Learning Path */
.cp-unit { background:#F8FAFC; border-radius:14px; padding:16px 18px; margin-bottom:12px; border:1px solid #F1F5F9; }
.cp-unit-header { display:flex; align-items:center; justify-content:space-between; gap:10px; margin-bottom:8px; flex-wrap:wrap; }
.cp-unit-name { font-size:0.92rem; font-weight:700; color:#1E293B; }
.cp-unit-pct { font-size:0.78rem; font-weight:700; color:#2563EB; }
.cp-unit-bar { height:6px; background:#E2E8F0; border-radius:999px; overflow:hidden; margin-bottom:8px; }
.cp-unit-bar-fill { height:100%; border-radius:999px; background:linear-gradient(90deg,#2563EB,#60A5FA); transition:width 0.3s; }
.cp-unit-subtopics { display:flex; flex-wrap:wrap; gap:6px; }
.cp-subtopic-chip { font-size:0.7rem; background:#EFF6FF; color:#1D4ED8; border-radius:999px; padding:3px 9px; font-weight:600; }
.cp-unit-stats { font-size:0.75rem; color:#64748B; margin-top:6px; }

/* Recent Summary */
.cp-activity-row { display:flex; align-items:flex-start; gap:12px; padding:10px 14px; background:#F8FAFC; border-radius:12px; margin-bottom:8px; border-left:3px solid #DBEAFE; }
.cp-activity-row.quiz { border-left-color:#FDE68A; }
.cp-activity-row.badgerow { border-left-color:#DDD6FE; }
.cp-activity-icon { width:32px; height:32px; border-radius:10px; display:flex; align-items:center; justify-content:center; font-size:0.9rem; flex-shrink:0; }
.cp-activity-icon.lesson { background:#DBEAFE; color:#1D4ED8; }
.cp-activity-icon.quiz { background:#FEF3C7; color:#D97706; }
.cp-activity-icon.badge-icon { background:#EDE9FE; color:#7C3AED; }
.cp-activity-body { flex:1; }
.cp-activity-label { font-size:0.7rem; font-weight:700; color:#94A3B8; text-transform:uppercase; letter-spacing:0.5px; }
.cp-activity-text { font-size:0.88rem; font-weight:600; color:#1E293B; }
.cp-activity-meta { font-size:0.75rem; color:#64748B; margin-top:2px; }

/* Achievement */
.cp-achieve-row { display:flex; gap:14px; flex-wrap:wrap; }
.cp-achieve-item { flex:1; min-width:120px; background:#F8FAFC; border-radius:12px; padding:14px; text-align:center; border:1px solid #F1F5F9; }
.cp-achieve-value { font-size:1.2rem; font-weight:800; color:#1E293B; display:block; }
.cp-achieve-label { font-size:0.72rem; color:#64748B; margin-top:2px; }
.cp-achieve-badge { margin-top:10px; font-size:0.8rem; color:#7C3AED; font-weight:600; }

/* Empty */
.cp-empty { text-align:center; padding:24px 16px; color:#94A3B8; font-size:0.85rem; }
.cp-empty i { font-size:2rem; color:#CBD5E1; display:block; margin-bottom:8px; }
.cp-empty a { color:#2563EB; font-weight:600; text-decoration:none; }

/* No activity */
.cp-no-data { text-align:center; padding:14px; color:#94A3B8; font-size:0.82rem; }
</style>
</asp:Content>

<%-- ════ SIDEBAR ════ --%>
<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <%-- Child Switcher --%>
    <div style="padding:10px 16px 6px; font-size:0.72rem; color:#94A3B8; text-transform:uppercase; letter-spacing:1px; font-weight:700;">
        <%: T("Viewing Child","Anak Dilihat") %>
    </div>
    <div style="padding:0 16px 14px;">
        <asp:DropDownList ID="ddlSidebarChild" runat="server"
            AutoPostBack="true" OnSelectedIndexChanged="SidebarChildChanged"
            style="width:100%;border:1.5px solid #E2E8F0;border-radius:10px;padding:8px 12px;font-size:0.82rem;font-weight:600;color:#1D4ED8;background:#EFF6FF;" />
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentDashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("My Children","Anak Saya") %></div>
        <a href="<%: ResolveUrl("~/Parent/LinkChildAccount.aspx") %>" class="sb-sidebar-item"><i class="bi bi-link-45deg item-icon"></i><span class="item-label"><%: T("Link Child Account","Paut Akaun Anak") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/ChildProfile.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-person-badge item-icon"></i><span class="item-label"><%: T("Child Profile","Profil Anak") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/EnrolledModules.aspx") %>" class="sb-sidebar-item"><i class="bi bi-journal-bookmark item-icon"></i><span class="item-label"><%: T("Learning Journey","Perjalanan Pembelajaran") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Child Performance","Prestasi Anak") %></div>
        <a href="<%: ResolveUrl("~/Parent/ChildProgress.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bar-chart-line item-icon"></i><span class="item-label"><%: T("Current Progress","Kemajuan Semasa") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/QuizResults.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-check item-icon"></i><span class="item-label"><%: T("Quiz Results","Keputusan Kuiz") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/ReportCard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-file-earmark-bar-graph item-icon"></i><span class="item-label"><%: T("Report Card","Kad Laporan") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Study Plan","Pelan Pembelajaran") %></div>
        <a href="<%: ResolveUrl("~/Parent/StudyPlan.aspx") %>" class="sb-sidebar-item"><i class="bi bi-journal-check item-icon"></i><span class="item-label"><%: T("Study Plan","Pelan Pembelajaran") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/EditStudyPlan.aspx") %>" class="sb-sidebar-item"><i class="bi bi-journal-pen item-icon"></i><span class="item-label"><%: T("Edit Study Plan","Edit Pelan Pembelajaran") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Discussions","Perbincangan") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentTeacherCommunication.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Chat with Teachers","Sembang dengan Guru") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/Forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-people item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Notifications","Notifikasi") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentNotifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label"><%: T("Notifications","Notifikasi") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Profile","Profil") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("Edit Profile","Edit Profil") %></span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Logout","Log Keluar") %></span></a></div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Child Profile","Profil Anak") %></asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="cp-page">

    <%-- No child --%>
    <asp:Panel ID="pnlNoChild" runat="server" Visible="false">
        <div class="cp-card"><div class="cp-empty">
            <i class="bi bi-person-x-fill"></i>
            <p><asp:Literal ID="litNoChildMsg" runat="server" /></p><br />
            <a href="<%: ResolveUrl("~/Parent/LinkChildAccount.aspx") %>"><asp:Literal ID="litNoChildLink" runat="server" /></a>
        </div></div>
    </asp:Panel>

    <asp:Panel ID="pnlProfile" runat="server" Visible="false">

        <%-- Identity Card --%>
        <div class="cp-card">
            <div class="cp-identity">
                <div class="cp-avatar"><asp:Literal ID="litInitials" runat="server" /></div>
                <div class="cp-id-info">
                    <h2 class="cp-id-name"><asp:Literal ID="litName" runat="server" /></h2>
                    <div class="cp-id-meta"><asp:Literal ID="litNickname" runat="server" /></div>
                    <div class="cp-id-pills">
                        <span class="cp-id-pill level"><i class="bi bi-mortarboard-fill"></i> <asp:Literal ID="litLevel" runat="server" /></span>
                        <span class="cp-id-pill rel"><i class="bi bi-heart-fill"></i> <asp:Literal ID="litRelationship" runat="server" /></span>
                    </div>
                </div>
            </div>
        </div>

        <%-- Learning Path --%>
        <div class="cp-card">
            <div class="cp-sec-title"><i class="bi bi-map-fill"></i> <asp:Literal ID="litPathTitle" runat="server" /></div>
            <asp:Panel ID="pnlUnits" runat="server"></asp:Panel>
            <asp:Panel ID="pnlNoUnits" runat="server" Visible="false">
                <div class="cp-no-data"><asp:Literal ID="litNoUnits" runat="server" /></div>
            </asp:Panel>
        </div>

        <%-- Recent Learning Summary --%>
        <div class="cp-card">
            <div class="cp-sec-title"><i class="bi bi-clock-history"></i> <asp:Literal ID="litRecentTitle" runat="server" /></div>
            <asp:Panel ID="pnlRecent" runat="server"></asp:Panel>
            <asp:Panel ID="pnlNoRecent" runat="server" Visible="false">
                <div class="cp-no-data"><asp:Literal ID="litNoRecent" runat="server" /></div>
            </asp:Panel>
        </div>

        <%-- Achievement Snapshot --%>
        <div class="cp-card">
            <div class="cp-sec-title"><i class="bi bi-trophy-fill"></i> <asp:Literal ID="litAchieveTitle" runat="server" /></div>
            <div class="cp-achieve-row">
                <div class="cp-achieve-item">
                    <span class="cp-achieve-value"><asp:Literal ID="litXP" runat="server" /></span>
                    <span class="cp-achieve-label"><asp:Literal ID="litXPLabel" runat="server" /></span>
                </div>
                <div class="cp-achieve-item">
                    <span class="cp-achieve-value"><asp:Literal ID="litBadgeCount" runat="server" /></span>
                    <span class="cp-achieve-label"><asp:Literal ID="litBadgeCountLabel" runat="server" /></span>
                </div>
            </div>
            <asp:Panel ID="pnlLatestBadge" runat="server" Visible="false">
                <div class="cp-achieve-badge"><i class="bi bi-award-fill"></i> <asp:Literal ID="litLatestBadge" runat="server" /></div>
            </asp:Panel>
        </div>

    </asp:Panel>

</div>
</asp:Content>
