<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LinkChildAccount.aspx.cs"
    Inherits="ScienceBuddy.Parent.LinkChildAccount" MasterPageFile="~/Site.Master"
    Title="Link Child Account" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Parent.css") %>?v=4" rel="stylesheet" />
<script type="text/javascript">
function toggleChildPopover(e){e.stopPropagation();var pop=document.getElementById('divChildPopover');if(!pop)return;if(pop.classList.contains('pt-popover-open')){pop.classList.remove('pt-popover-open');return;}var ddl=document.querySelector('.sb-sidebar-child-ddl');if(!ddl)return;var html='<div class="pt-child-popover-title">Select Child</div>';for(var i=0;i<ddl.options.length;i++){var o=ddl.options[i];var init=o.text.charAt(0).toUpperCase();var ac=o.selected?' pt-popover-active':'';html+='<div class="pt-child-popover-item'+ac+'" onclick="selectChildFromPopover(\''+o.value+'\')"><span class="pt-popover-avatar">'+init+'</span>'+o.text+'</div>';}pop.innerHTML=html;pop.classList.add('pt-popover-open');}
function selectChildFromPopover(v){var ddl=document.querySelector('.sb-sidebar-child-ddl');if(ddl&&ddl.value!==v){ddl.value=v;__doPostBack(ddl.id.replace(/_/g,'$'),'');}var pop=document.getElementById('divChildPopover');if(pop)pop.classList.remove('pt-popover-open');}
document.addEventListener('DOMContentLoaded',function(){var ddl=document.querySelector('.sb-sidebar-child-ddl');var btn=document.querySelector('.pt-child-compact-btn');if(ddl&&btn&&ddl.options.length>0){btn.textContent=ddl.options[ddl.selectedIndex].text.charAt(0).toUpperCase();}});
document.addEventListener('click',function(e){var pop=document.getElementById('divChildPopover');if(pop&&!e.target.closest('.pt-child-selector-compact')){pop.classList.remove('pt-popover-open');}});
</script>
</asp:Content>

<%-- ════ SIDEBAR (full Parent sidebar) ════ --%>
<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <%-- Child Switcher --%>
    <div class="pt-child-selector">
        <div class="pt-child-selector-label"><%: T("Viewing Child","Anak Dilihat") %></div>
        <div class="pt-child-selector-full"><asp:DropDownList ID="ddlSidebarChild" runat="server" AutoPostBack="true" OnSelectedIndexChanged="SidebarChildChanged" CssClass="sb-sidebar-child-ddl" /></div>
        <div class="pt-child-selector-compact"><button type="button" class="pt-child-compact-btn" onclick="toggleChildPopover(event);"></button><div class="pt-child-popover" id="divChildPopover"></div></div>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentDashboard.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-speedometer2 item-icon"></i>
            <span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/ParentNotifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label"><%: T("Notifications","Notifikasi") %></span><asp:Literal ID="litUnreadBadge" runat="server" /></a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("My Children","Anak Saya") %></div>
        <a href="<%: ResolveUrl("~/Parent/LinkChildAccount.aspx") %>" class="sb-sidebar-item active">
            <i class="bi bi-link-45deg item-icon"></i>
            <span class="item-label"><%: T("Link Child Account","Paut Akaun Anak") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/ChildProfile.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-person-badge item-icon"></i>
            <span class="item-label"><%: T("Child Profile","Profil Anak") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/EnrolledModules.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-journal-bookmark item-icon"></i>
            <span class="item-label"><%: T("Learning Journey","Perjalanan Pembelajaran") %></span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Child Performance","Prestasi Anak") %></div>
        <a href="<%: ResolveUrl("~/Parent/ChildProgress.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-bar-chart-line item-icon"></i>
            <span class="item-label"><%: T("Current Progress","Kemajuan Semasa") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/QuizResults.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-patch-check item-icon"></i>
            <span class="item-label"><%: T("Quiz Results","Keputusan Kuiz") %></span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Study Plan","Pelan Pembelajaran") %></div>
        <a href="<%: ResolveUrl("~/Parent/StudyPlan.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-journal-check item-icon"></i>
            <span class="item-label"><%: T("Study Plan","Pelan Pembelajaran") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/EditStudyPlan.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-pencil-square item-icon"></i>
            <span class="item-label"><%: T("Edit Study Plan","Edit Pelan Pembelajaran") %></span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Discussions","Perbincangan") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentTeacherCommunication.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-chat-dots item-icon"></i>
            <span class="item-label"><%: T("Chat with Teachers","Sembang dengan Guru") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Parent/Forum.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-people item-icon"></i>
            <span class="item-label"><%: T("Forum","Forum") %></span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Profile","Profil") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentProfile.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-person item-icon"></i>
            <span class="item-label"><%: T("Edit Profile","Edit Profil") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-box-arrow-right item-icon"></i>
            <span class="item-label"><%: T("Logout","Log Keluar") %></span>
        </a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Link Child Account","Paut Akaun Anak") %></asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="lc-page">

    <%-- Hero --%>
    <div class="pt-page-hero">
        <div class="pt-page-hero-content">
            <h1 class="pt-page-hero-title"><i class="bi bi-link-45deg"></i> <%: T("Link Child Account","Paut Akaun Anak") %></h1>
            <p class="pt-page-hero-subtitle"><%: T("Connect your child's account to monitor their ScienceBuddy progress.","Pautkan akaun anak anda untuk memantau kemajuan ScienceBuddy mereka.") %></p>
        </div>
    </div>

    <asp:Panel ID="pnlMessage" runat="server" Visible="false">
        <div class="lc-msg" id="divMsg" runat="server"></div>
    </asp:Panel>

    <%-- Link form --%>
    <div class="lc-card">
        <div class="lc-title"><i class="bi bi-link-45deg"></i> <asp:Literal ID="litTitle" runat="server" /></div>
        <div class="lc-sub"><asp:Literal ID="litSub" runat="server" /></div>

        <div class="lc-field">
            <label class="lc-label"><asp:Literal ID="litLblCode" runat="server" /></label>
            <asp:TextBox ID="txtCode" runat="server" CssClass="lc-input" MaxLength="20" placeholder="e.g. RAY468" />
        </div>

        <div class="lc-field">
            <label class="lc-label"><asp:Literal ID="litLblRelationship" runat="server" /></label>
            <asp:DropDownList ID="ddlRelationship" runat="server" CssClass="lc-select">
                <asp:ListItem Value="Mother" />
                <asp:ListItem Value="Father" />
                <asp:ListItem Value="Guardian" />
            </asp:DropDownList>
        </div>

        <asp:Button ID="btnLink" runat="server" CssClass="lc-btn"
            OnClick="BtnLink_Click" CausesValidation="false" />
    </div>

    <%-- Linked children list --%>
    <div class="lc-card">
        <div class="lc-list-title"><i class="bi bi-people-fill"></i> <asp:Literal ID="litLinkedTitle" runat="server" /></div>
        <asp:Panel ID="pnlLinkedList" runat="server"></asp:Panel>
        <asp:Panel ID="pnlNoLinked" runat="server" Visible="false">
            <div class="lc-empty">
                <i class="bi bi-person-x"></i>
                <asp:Literal ID="litNoLinked" runat="server" />
            </div>
        </asp:Panel>
    </div>

    <%-- Hidden field for unlink target --%>
    <asp:HiddenField ID="hidUnlinkArg" runat="server" />

    <%-- Unlink Confirmation Modal --%>
    <asp:Panel ID="pnlUnlinkModal" runat="server" Visible="false">
        <div class="lc-modal-overlay">
            <div class="lc-modal-card">
                <div class="lc-modal-icon">
                    <i class="bi bi-exclamation-triangle-fill"></i>
                </div>
                <div class="lc-modal-title"><asp:Literal ID="litModalTitle" runat="server" /></div>
                <div class="lc-modal-msg"><asp:Literal ID="litModalMsg" runat="server" /></div>
                <div class="lc-modal-actions">
                    <asp:Button ID="btnCancelUnlink" runat="server" CssClass="lc-modal-btn cancel"
                        OnClick="BtnCancelUnlink_Click" CausesValidation="false" />
                    <asp:Button ID="btnConfirmUnlink" runat="server" CssClass="lc-modal-btn danger"
                        OnClick="BtnConfirmUnlink_Click" CausesValidation="false" />
                </div>
            </div>
        </div>
    </asp:Panel>

</div>
</asp:Content>
