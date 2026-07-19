<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ParentAICoach.aspx.cs"
    Inherits="ScienceBuddy.Parent.ParentAICoach" MasterPageFile="~/Site.Master"
    Title="Parent AI Coach" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Parent.css") %>?v=8" rel="stylesheet" />
</asp:Content>

<%-- ════ SIDEBAR ════ --%>
<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="pt-child-selector">
        <div class="pt-child-selector-label"><%: T("Viewing Child","Anak Dilihat") %></div>
        <div class="pt-child-selector-full">
            <asp:DropDownList ID="ddlSidebarChild" runat="server" AutoPostBack="true"
                OnSelectedIndexChanged="SidebarChildChanged" CssClass="sb-sidebar-child-ddl" />
        </div>
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
        <a href="<%: ResolveUrl("~/Parent/QuizResults.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-check item-icon"></i><span class="item-label"><%: T("Quiz Results","Keputusan Kuiz") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/ParentAICoach.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-robot item-icon"></i><span class="item-label"><%: T("AI Parent Coach","Jurulatih AI") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Study Plan","Pelan Pembelajaran") %></div>
        <a href="<%: ResolveUrl("~/Parent/StudyPlan.aspx") %>" class="sb-sidebar-item"><i class="bi bi-journal-check item-icon"></i><span class="item-label"><%: T("Study Plan","Pelan Pembelajaran") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/EditStudyPlan.aspx") %>" class="sb-sidebar-item"><i class="bi bi-pencil-square item-icon"></i><span class="item-label"><%: T("Edit Study Plan","Edit Pelan Pembelajaran") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Discussions","Perbincangan") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentTeacherCommunication.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Chat with Teachers","Sembang dengan Guru") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/Forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-people item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Profile","Profil") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("My Profile","Profil Saya") %></span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Logout","Log Keluar") %></span></a></div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("AI Parent Coach","Jurulatih AI Ibu Bapa") %></asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="pt-ai-coach-page">

    <%-- ══ 1. HERO ══ --%>
    <div class="pt-hero">
        <i class="bi bi-star-fill pt-sparkle" style="top:14%;left:10%;"></i>
        <i class="bi bi-stars pt-sparkle" style="top:50%;right:7%;animation-delay:0.9s;"></i>
        <div class="pt-ai-coach-header">
            <span class="pt-ai-coach-header-icon"><i class="bi bi-robot"></i></span>
            <div class="pt-ai-coach-header-text">
                <h2 class="pt-hero-title"><%: T("ScienceBuddy Parent Coach","Jurulatih Ibu Bapa ScienceBuddy") %></h2>
                <p class="pt-hero-sub"><%: T("Personalised learning support based on your selected child's recent ScienceBuddy progress.","Sokongan pembelajaran peribadi berdasarkan kemajuan terkini anak anda di ScienceBuddy.") %></p>
            </div>
        </div>
    </div>

    <%-- ══ 2. COACHING PLAN (3 steps — main feature) ══ --%>
    <asp:Panel ID="pnlCoachingPlan" runat="server" Visible="false">
        <div class="pt-ai-coach-guide">
            <div class="pt-ai-coach-guide-title">
                <i class="bi bi-clipboard2-check-fill"></i>
                <%: T("Your Coaching Plan","Pelan Bimbingan Anda") %>
            </div>
            <p class="pt-ai-coach-guide-subtitle"><%: T("A simple plan to help your child reach their next science milestone.","Pelan mudah untuk membantu anak anda mencapai pencapaian sains seterusnya.") %></p>

            <div class="pt-ai-coach-steps-row">
                <%-- Step 1 --%>
                <div class="pt-ai-coach-step-card">
                    <span class="pt-ai-coach-step-number">1</span>
                    <span class="pt-ai-coach-step-icon"><i class="bi bi-lightbulb-fill" style="color:#F59E0B;"></i></span>
                    <span class="pt-ai-coach-step-label step-blue"><%: T("HOW YOU CAN HELP","BAGAIMANA MEMBANTU") %></span>
                    <div class="pt-ai-coach-step-text"><asp:Literal ID="litStep1" runat="server" /></div>
                </div>

                <span class="pt-ai-coach-step-arrow"><i class="bi bi-arrow-right-circle-fill"></i></span>

                <%-- Step 2 --%>
                <div class="pt-ai-coach-step-card">
                    <span class="pt-ai-coach-step-number">2</span>
                    <span class="pt-ai-coach-step-icon"><i class="bi bi-bullseye" style="color:#8B5CF6;"></i></span>
                    <span class="pt-ai-coach-step-label step-purple"><%: T("RECOMMENDED GOAL","MATLAMAT DISYORKAN") %></span>
                    <div class="pt-ai-coach-step-text"><asp:Literal ID="litStep2" runat="server" /></div>
                </div>

                <span class="pt-ai-coach-step-arrow"><i class="bi bi-arrow-right-circle-fill"></i></span>

                <%-- Step 3 --%>
                <div class="pt-ai-coach-step-card">
                    <span class="pt-ai-coach-step-number">3</span>
                    <span class="pt-ai-coach-step-icon"><i class="bi bi-balloon-heart-fill" style="color:#EC4899;"></i></span>
                    <span class="pt-ai-coach-step-label step-pink"><%: T("FUN FAMILY ACTIVITY","AKTIVITI KELUARGA") %></span>
                    <div class="pt-ai-coach-step-text"><asp:Literal ID="litStep3" runat="server" /></div>
                </div>
            </div>
        </div>
    </asp:Panel>

    <%-- ══ 3. QUICK QUESTION CHIPS ══ --%>
    <div class="pt-ai-coach-chips">
        <asp:Literal ID="litChips" runat="server" />
    </div>

    <%-- ══ 4. CHAT AREA ══ --%>
    <div class="pt-ai-coach-chat-area" id="chatArea">
        <asp:Panel ID="pnlChatMessages" runat="server" CssClass="pt-ai-coach-messages"></asp:Panel>
    </div>

    <%-- ══ 5. INPUT ROW ══ --%>
    <div class="pt-ai-coach-input-row">
        <asp:TextBox ID="txtMessage" runat="server" CssClass="pt-ai-coach-input"
            placeholder="Ask about your child's learning..." MaxLength="500" />
        <asp:Button ID="btnSend" runat="server" CssClass="pt-ai-coach-send-btn"
            Text="Send" OnClick="BtnSend_Click" CausesValidation="false" />
    </div>

    <%-- ══ 6. DISCLAIMER ══ --%>
    <div class="pt-ai-coach-disclaimer">
        <i class="bi bi-info-circle"></i>
        <%: T("AI suggestions are based on real learning data. Always discuss with your child's teacher.","Cadangan AI berdasarkan data sebenar. Sentiasa berbincang dengan guru anak anda.") %>
    </div>

</div>

<script type="text/javascript">
// Populate input when a chip is clicked (no auto-submit)
function fillChip(text){
    var input = document.getElementById('<%= txtMessage.ClientID %>');
    if(input){ input.value = text; input.focus(); }
}
// Scroll chat to bottom after load
document.addEventListener('DOMContentLoaded', function(){
    var area = document.getElementById('chatArea');
    if(area) area.scrollTop = area.scrollHeight;
});
</script>
</asp:Content>
