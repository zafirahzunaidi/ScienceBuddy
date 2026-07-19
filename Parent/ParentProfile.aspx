<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ParentProfile.aspx.cs"
    Inherits="ScienceBuddy.Parent.ParentProfile" MasterPageFile="~/Site.Master"
    Title="Parent Profile" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Parent.css") %>?v=6" rel="stylesheet" />
<script type="text/javascript">
function toggleChildPopover(e){e.stopPropagation();var pop=document.getElementById('divChildPopover');if(!pop)return;if(pop.classList.contains('pt-popover-open')){pop.classList.remove('pt-popover-open');return;}var ddl=document.querySelector('.sb-sidebar-child-ddl');if(!ddl)return;var html='<div class="pt-child-popover-title">Select Child</div>';for(var i=0;i<ddl.options.length;i++){var o=ddl.options[i];var init=o.text.charAt(0).toUpperCase();var ac=o.selected?' pt-popover-active':'';html+='<div class="pt-child-popover-item'+ac+'" onclick="selectChildFromPopover(\''+o.value+'\')"><span class="pt-popover-avatar">'+init+'</span>'+o.text+'</div>';}pop.innerHTML=html;pop.classList.add('pt-popover-open');}
function selectChildFromPopover(v){var ddl=document.querySelector('.sb-sidebar-child-ddl');if(ddl&&ddl.value!==v){ddl.value=v;__doPostBack(ddl.id.replace(/_/g,'$'),'');}var pop=document.getElementById('divChildPopover');if(pop)pop.classList.remove('pt-popover-open');}
document.addEventListener('DOMContentLoaded',function(){var ddl=document.querySelector('.sb-sidebar-child-ddl');var btn=document.querySelector('.pt-child-compact-btn');if(ddl&&btn&&ddl.options.length>0){btn.textContent=ddl.options[ddl.selectedIndex].text.charAt(0).toUpperCase();}});
document.addEventListener('click',function(e){var pop=document.getElementById('divChildPopover');if(pop&&!e.target.closest('.pt-child-selector-compact')){pop.classList.remove('pt-popover-open');}});
</script>
</asp:Content>

<%-- ════ SIDEBAR ════ --%>
<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="pt-child-selector">
        <div class="pt-child-selector-label"><%: T("Viewing Child","Anak Dilihat") %></div>
        <div class="pt-child-selector-full"><asp:DropDownList ID="ddlSidebarChild" runat="server" AutoPostBack="true" OnSelectedIndexChanged="SidebarChildChanged" CssClass="sb-sidebar-child-ddl" /></div>
        <div class="pt-child-selector-compact"><button type="button" class="pt-child-compact-btn" onclick="toggleChildPopover(event);"></button><div class="pt-child-popover" id="divChildPopover"></div></div>
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
        <a href="<%: ResolveUrl("~/Parent/ParentAICoach.aspx") %>" class="sb-sidebar-item"><i class="bi bi-robot item-icon"></i><span class="item-label"><%: T("AI Parent Coach","Jurulatih AI") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Study Plan","Pelan Pembelajaran") %></div>
        <a href="<%: ResolveUrl("~/Parent/StudyPlan.aspx") %>" class="sb-sidebar-item"><i class="bi bi-journal-check item-icon"></i><span class="item-label"><%: T("Study Plan","Pelan Pembelajaran") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/EditStudyPlan.aspx") %>" class="sb-sidebar-item"><i class="bi bi-pencil-square item-icon"></i><span class="item-label"><%: T("Edit Study Plan","Edit Pelan Pembelajaran") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Discussions","Perbincangan") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentTeacherCommunication.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Chat with Teachers","Sembang dengan Guru") %></span></a>
        <a href="<%: ResolveUrl("~/Parent/Forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-people item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Profile","Profil") %></div>
        <a href="<%: ResolveUrl("~/Parent/ParentProfile.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("My Profile","Profil Saya") %></span></a>        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Logout","Log Keluar") %></span></a></div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("My Profile","Profil Saya") %></asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="pd-page">

    <%-- Success/Error Popup --%>
    <asp:Panel ID="pnlMessage" runat="server" Visible="false">
        <div class="pt-success-popup-overlay"><div class="pt-success-popup">
            <div class="pt-success-popup-icon"><i class="bi" id="iMsgIcon" runat="server"></i></div>
            <div class="pt-success-popup-text" id="divMsg" runat="server"></div>
            <asp:Button ID="btnCloseMsg" runat="server" Text="X" CssClass="pt-success-popup-close" OnClick="BtnCloseMsg_Click" CausesValidation="false" />
        </div></div>
    </asp:Panel>

    <%-- ══ HERO CARD ══ --%>
    <div class="pt-hero">
        <i class="bi bi-star-fill pt-sparkle" style="top:14%;left:10%;"></i>
        <i class="bi bi-stars pt-sparkle" style="top:50%;right:7%;animation-delay:0.9s;"></i>
        <div style="display:flex;align-items:center;gap:18px;position:relative;z-index:1;flex-wrap:wrap;">
            <div class="pt-profile-hero-avatar"><asp:Literal ID="litInitials" runat="server" /></div>
            <div>
                <h2 class="pt-hero-title" style="margin-bottom:2px;"><asp:Literal ID="litHeroName" runat="server" /></h2>
                <p class="pt-hero-sub" style="margin-bottom:8px;"><i class="bi bi-person-heart"></i> <%: T("Parent","Ibu Bapa") %></p>
                <div class="pt-hero-pills">
                    <span class="pt-hero-pill"><i class="bi bi-people-fill"></i> <asp:Literal ID="litChildrenCount" runat="server" /></span>
                    <span class="pt-hero-pill"><i class="bi bi-envelope-fill"></i> <asp:Literal ID="litHeroEmail" runat="server" /></span>
                </div>
            </div>
        </div>
    </div>

    <%-- ══ PERSONAL INFORMATION ══ --%>
    <div class="pt-profile-section">
        <div class="pt-profile-section-title"><i class="bi bi-person-lines-fill"></i> <%: T("Personal Information","Maklumat Peribadi") %></div>
        <div class="pt-profile-form-grid">
            <div class="pt-field">
                <label class="pt-label"><%: T("Username","Nama Pengguna") %></label>
                <asp:TextBox ID="txtUsername" runat="server" CssClass="pt-input pt-input-readonly" ReadOnly="true" />
            </div>
            <div class="pt-field">
                <label class="pt-label"><%: T("Full Name","Nama Penuh") %></label>
                <asp:TextBox ID="txtName" runat="server" CssClass="pt-input" MaxLength="100" />
            </div>
            <div class="pt-field">
                <label class="pt-label"><%: T("Email","E-mel") %></label>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="pt-input" MaxLength="100" TextMode="Email" />
            </div>
            <div class="pt-field">
                <label class="pt-label"><%: T("Phone Number","Nombor Telefon") %></label>
                <asp:TextBox ID="txtPhone" runat="server" CssClass="pt-input" MaxLength="20" />
            </div>
        </div>
    </div>

    <%-- ══ LANGUAGE PREFERENCE ══ --%>
    <div class="pt-profile-section pt-profile-section-compact">
        <div class="pt-profile-section-title"><i class="bi bi-translate"></i> <%: T("Language Preference","Pilihan Bahasa") %></div>
        <p class="pt-profile-section-hint"><%: T("Choose your preferred display language.","Pilih bahasa paparan pilihan anda.") %></p>
        <div class="pt-field" style="max-width:280px;">
            <asp:DropDownList ID="ddlLang" runat="server" CssClass="pt-select">
                <asp:ListItem Value="EN" Text="English" />
                <asp:ListItem Value="BM" Text="Bahasa Melayu" />
            </asp:DropDownList>
        </div>
    </div>

    <%-- ══ CHANGE PASSWORD ══ --%>
    <div class="pt-profile-section">
        <div class="pt-profile-section-title"><i class="bi bi-shield-lock-fill"></i> <%: T("Change Password","Tukar Kata Laluan") %></div>
        <p class="pt-profile-section-hint"><%: T("Leave blank if you don't want to change your password.","Biarkan kosong jika anda tidak mahu menukar kata laluan.") %></p>
        <div class="pt-profile-form-grid">
            <div class="pt-field">
                <label class="pt-label"><%: T("Current Password","Kata Laluan Semasa") %></label>
                <asp:TextBox ID="txtCurrentPwd" runat="server" CssClass="pt-input" TextMode="Password" MaxLength="50" />
            </div>
            <div class="pt-field">
                <label class="pt-label"><%: T("New Password","Kata Laluan Baharu") %></label>
                <asp:TextBox ID="txtNewPwd" runat="server" CssClass="pt-input" TextMode="Password" MaxLength="50" />
            </div>
            <div class="pt-field">
                <label class="pt-label"><%: T("Confirm New Password","Sahkan Kata Laluan Baharu") %></label>
                <asp:TextBox ID="txtConfirmPwd" runat="server" CssClass="pt-input" TextMode="Password" MaxLength="50" />
            </div>
        </div>
        <asp:Button ID="btnChangePwd" runat="server" CssClass="pt-btn soft" style="margin-top:10px;"
            OnClick="BtnChangePwd_Click" CausesValidation="false" />
    </div>

    <%-- ══ ACCOUNT STATUS ══ --%>
    <div class="pt-profile-section pt-profile-section-compact">
        <div class="pt-profile-section-title"><i class="bi bi-shield-check"></i> <%: T("Account Status","Status Akaun") %></div>
        <p class="pt-profile-section-hint"><%: T("This information is read-only.","Maklumat ini hanya untuk bacaan.") %></p>
        <div class="pt-profile-status-inline">
            <span class="pt-profile-status-chip"><i class="bi bi-person-badge"></i> <asp:Literal ID="litStatusRole" runat="server" /></span>
            <span class="pt-profile-status-chip"><i class="bi bi-check-circle-fill"></i> <asp:Literal ID="litStatusStatus" runat="server" /></span>
            <span class="pt-profile-status-chip"><i class="bi bi-globe"></i> <asp:Literal ID="litStatusLang" runat="server" /></span>
        </div>
    </div>

    <%-- ══ SAVE BUTTON ══ --%>
    <div class="pt-profile-save-area">
        <asp:Button ID="btnSave" runat="server" CssClass="pt-btn primary" OnClick="BtnSave_Click" CausesValidation="false" />
        <p class="pt-profile-save-hint"><%: T("This saves all changes made on this page.","Ini menyimpan semua perubahan yang dibuat di halaman ini.") %></p>
    </div>

    <%-- ══ ACCORDION — HELP & SUPPORT + ACCOUNT ACCESS ══ --%>
    <div class="pt-profile-accordion">

        <%-- ── 1. Help & Support ── --%>
        <div class="pt-profile-accordion-item" id="accSupport">
            <button type="button" class="pt-profile-accordion-header" onclick="toggleAccordion('accSupport')">
                <span class="pt-profile-accordion-icon pt-acc-icon-support"><i class="bi bi-life-preserver"></i></span>
                <span class="pt-profile-accordion-text">
                    <span class="pt-profile-accordion-title"><%: T("Help & Support","Bantuan & Sokongan") %></span>
                    <span class="pt-profile-accordion-subtitle"><%: T("Need help? Send a message to the admin.","Perlukan bantuan? Hantar mesej kepada pentadbir.") %></span>
                </span>
                <i class="bi bi-chevron-down pt-profile-accordion-chevron"></i>
            </button>
            <div class="pt-profile-accordion-content">
                <div class="pt-support-inner">
                    <h4 class="pt-support-inner-title"><i class="bi bi-chat-left-text"></i> <%: T("Report a Problem","Laporkan Masalah") %></h4>
                    <p class="pt-support-inner-desc"><%: T("Need help with something? Tell us what happened, and we'll let the admin know.","Perlukan bantuan? Beritahu kami apa yang berlaku, dan kami akan maklumkan kepada pentadbir.") %></p>

                    <asp:Panel ID="pnlReportSuccess" runat="server" Visible="false" CssClass="pt-support-status pt-support-status-ok">
                        <i class="bi bi-check-circle-fill"></i> <asp:Literal ID="litReportStatus" runat="server" />
                    </asp:Panel>
                    <asp:Panel ID="pnlReportError" runat="server" Visible="false" CssClass="pt-support-status pt-support-status-err">
                        <i class="bi bi-exclamation-circle-fill"></i> <asp:Literal ID="litReportError" runat="server" />
                    </asp:Panel>

                    <div class="pt-support-form">
                        <div class="pt-support-field">
                            <label class="pt-label"><%: T("Issue Category","Kategori Isu") %> <span class="pt-required">*</span></label>
                            <asp:DropDownList ID="ddlReportCategory" runat="server" CssClass="pt-select" />
                        </div>
                        <div class="pt-support-field">
                            <label class="pt-label"><%: T("Subject","Subjek") %> <span class="pt-required">*</span></label>
                            <asp:TextBox ID="txtReportSubject" runat="server" CssClass="pt-input" MaxLength="100" />
                        </div>
                        <div class="pt-support-field">
                            <label class="pt-label"><%: T("Message","Mesej") %> <span class="pt-required">*</span></label>
                            <asp:TextBox ID="txtReportMessage" runat="server" CssClass="pt-input" TextMode="MultiLine" Rows="5" MaxLength="1000" />
                        </div>
                        <asp:Button ID="btnReportSubmit" runat="server" CssClass="pt-support-submit"
                            OnClick="BtnReportSubmit_Click" CausesValidation="false" />
                    </div>
                </div>
            </div>
        </div>

        <%-- ── 2. Account Access ── --%>
        <div class="pt-profile-accordion-item" id="accAccount">
            <button type="button" class="pt-profile-accordion-header" onclick="toggleAccordion('accAccount')">
                <span class="pt-profile-accordion-icon pt-acc-icon-account"><i class="bi bi-person-lock"></i></span>
                <span class="pt-profile-accordion-text">
                    <span class="pt-profile-accordion-title"><%: T("Account Access","Akses Akaun") %></span>
                    <span class="pt-profile-accordion-subtitle"><%: T("Manage account closure and recovery options.","Urus pilihan penutupan dan pemulihan akaun.") %></span>
                </span>
                <i class="bi bi-chevron-down pt-profile-accordion-chevron"></i>
            </button>
            <div class="pt-profile-accordion-content">
                <div class="pt-account-close-card">
                    <h4 class="pt-account-close-title"><i class="bi bi-box-arrow-right"></i> <%: T("Close My Account","Tutup Akaun Saya") %></h4>
                    <p class="pt-account-close-desc"><%: T("If you no longer want to use ScienceBuddy, you can mark your account as deleted. You will not be able to log in after this. To recover your account, contact the admin at","Jika anda tidak lagi mahu menggunakan ScienceBuddy, anda boleh menandakan akaun anda sebagai dipadam. Anda tidak akan dapat log masuk selepas ini. Untuk memulihkan akaun, hubungi pentadbir di") %> <strong>najihahazmi26@gmail.com</strong></p>

                    <asp:Panel ID="pnlDeleteError" runat="server" Visible="false" CssClass="pt-support-status pt-support-status-err" style="margin-bottom:12px;">
                        <i class="bi bi-exclamation-circle-fill"></i> <asp:Literal ID="litDeleteError" runat="server" />
                    </asp:Panel>

                    <div class="pt-account-close-form">
                        <div class="pt-support-field">
                            <label class="pt-label"><%: T("Reason (optional)","Sebab (pilihan)") %></label>
                            <asp:TextBox ID="txtDeleteReason" runat="server" CssClass="pt-input" TextMode="MultiLine" Rows="2" MaxLength="300" />
                        </div>
                        <div class="pt-delete-confirm">
                            <asp:CheckBox ID="chkDeleteConfirm" runat="server" />
                            <label for="<%= chkDeleteConfirm.ClientID %>">
                                <%: T("I understand that my account will be marked as deleted and I will need to contact admin to recover it.",
                                       "Saya faham bahawa akaun saya akan ditandakan sebagai dipadam dan saya perlu menghubungi pentadbir untuk memulihkannya.") %>
                            </label>
                        </div>
                        <asp:Button ID="btnDeleteAccount" runat="server" CssClass="pt-delete-button"
                            OnClick="BtnDeleteAccount_Click" CausesValidation="false"
                            OnClientClick="return confirmCloseAccount();" />
                    </div>
                </div>
            </div>
        </div>

    </div>

    <script type="text/javascript">
    function toggleAccordion(id){var el=document.getElementById(id);if(!el)return;el.classList.toggle('pt-profile-accordion-open');}
    function confirmCloseAccount(){var cb=document.getElementById('<%= chkDeleteConfirm.ClientID %>');if(!cb||!cb.checked){return true;}return confirm('<%= T("Are you sure you want to close your account? Your account will be marked as deleted and you will no longer be able to log in. To recover your account, contact the admin.","Adakah anda pasti mahu menutup akaun anda? Akaun anda akan ditandakan sebagai dipadam dan anda tidak akan dapat log masuk. Untuk memulihkan akaun, hubungi pentadbir.") %>');}
    </script>

</div>
</asp:Content>
