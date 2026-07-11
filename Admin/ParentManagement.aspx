<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ParentManagement.aspx.cs"
    Inherits="ScienceBuddy.Admin.ParentManagement" MasterPageFile="~/Site.Master"
    Title="Parent Management" ValidateRequest="false" EnableEventValidation="false" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Admin.css") %>" rel="stylesheet" />
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" />
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="<%: ResolveUrl("~/Scripts/admin-signout.js") %>"></script>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label">Main</div>
        <a href="<%: ResolveUrl("~/Admin/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label">Dashboard</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">User Management</div>
        <a href="<%: ResolveUrl("~/Admin/StudentManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-people item-icon"></i><span class="item-label">Students</span></a>
        <a href="<%: ResolveUrl("~/Admin/ParentManagement.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-person-heart item-icon"></i><span class="item-label">Parents</span></a>
        <a href="<%: ResolveUrl("~/Admin/TeacherManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-badge item-icon"></i><span class="item-label">Teachers</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Learning Content</div>
        <a href="<%: ResolveUrl("~/Admin/LessonManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label">Lessons</span></a>
        <a href="<%: ResolveUrl("~/Admin/QuizManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label">Quizzes</span></a>
        <a href="<%: ResolveUrl("~/Admin/QuestionBank.aspx") %>" class="sb-sidebar-item"><i class="bi bi-question-circle item-icon"></i><span class="item-label">Question Bank</span></a>
        <a href="<%: ResolveUrl("~/Admin/TeacherMaterials.aspx") %>" class="sb-sidebar-item"><i class="bi bi-file-earmark-text item-icon"></i><span class="item-label">Material Requests</span></a>
        <a href="<%: ResolveUrl("~/Admin/LiveSessions.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label">Live Sessions</span></a>
        <a href="<%: ResolveUrl("~/Admin/QuestionRequests.aspx") %>" class="sb-sidebar-item"><i class="bi bi-clipboard-check item-icon"></i><span class="item-label">Question Requests</span></a>
        <a href="<%: ResolveUrl("~/Admin/CertificateManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-award item-icon"></i><span class="item-label">Certificates</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Community</div>
        <a href="<%: ResolveUrl("~/Admin/ForumDiscussions.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label">Forum Discussions</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Gamification</div>
        <a href="<%: ResolveUrl("~/Admin/GamificationManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-trophy item-icon"></i><span class="item-label">Student Performance</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Configuration</div>
        <a href="<%: ResolveUrl("~/Admin/SystemSettings.aspx") %>" class="sb-sidebar-item"><i class="bi bi-gear item-icon"></i><span class="item-label">System Settings</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Logs</div>
        <a href="<%: ResolveUrl("~/Admin/SystemActivityLogs.aspx") %>" class="sb-sidebar-item"><i class="bi bi-clock-history item-icon"></i><span class="item-label">Activity Logs</span></a>
        <a href="<%: ResolveUrl("~/Admin/LoginLogs.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-in-right item-icon"></i><span class="item-label">Login Logs</span></a>
        <a href="<%: ResolveUrl("~/Admin/SuspiciousLogins.aspx") %>" class="sb-sidebar-item"><i class="bi bi-exclamation-triangle item-icon"></i><span class="item-label">Suspicious Logins</span></a>
    </div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Admin/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span></a>
        <a href="<%: ResolveUrl("~/Admin/Profile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a>
        <a href="javascript:;" class="sb-sidebar-item" onclick="showSignOutModal()"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%= T("Parent Management", "Pengurusan Ibu Bapa") %></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<div class="ad-parent-management-header">
    <div>
        <h1 class="ad-parent-management-header-title"><i class="bi bi-person-heart" style="color:var(--ad-parent-management-accent);"></i> <%= T("Parent Management", "Pengurusan Ibu Bapa") %></h1>
        <p class="ad-parent-management-header-sub"><%= T("Manage parent accounts, monitor engagement and parent-child communication.", "Urus akaun ibu bapa, pantau penglibatan dan komunikasi ibu bapa-anak.") %></p>
        <span class="ad-parent-management-header-badge"><i class="bi bi-house-heart-fill"></i> <%= T("Family Directory", "Direktori Keluarga") %></span>
    </div>
    <div style="display:flex;align-items:center;gap:var(--space-md);">
        <div class="ad-parent-management-header-icon"><i class="bi bi-people-fill"></i></div>
        <a href="javascript:;" onclick="openAddParent()" style="display:inline-flex;align-items:center;gap:8px;padding:12px 24px;background:linear-gradient(135deg,#0E7490,#0891B2,#22D3EE);color:#fff;border-radius:12px;font-weight:700;font-size:.9rem;text-decoration:none;box-shadow:0 6px 20px rgba(8,145,178,.35);transition:all .25s;">
            <i class="bi bi-person-plus-fill"></i> <%= T("+ Add Parent", "+ Tambah Ibu Bapa") %>
        </a>
    </div>
</div>

<div class="ad-parent-management-insights">
    <div class="ad-parent-management-insight ad-parent-management-gi-total"><div class="ad-parent-management-insight-ico"><i class="bi bi-person-heart"></i></div><div class="ad-parent-management-insight-val"><asp:Literal ID="litTotal" runat="server" Text="0" /></div><div class="ad-parent-management-insight-lbl"><%= T("Total Parents", "Jumlah Ibu Bapa") %></div></div>
    <div class="ad-parent-management-insight ad-parent-management-gi-linked"><div class="ad-parent-management-insight-ico"><i class="bi bi-link-45deg"></i></div><div class="ad-parent-management-insight-val"><asp:Literal ID="litLinked" runat="server" Text="0" /></div><div class="ad-parent-management-insight-lbl"><%= T("Linked Children", "Anak yang Dihubungkan") %></div></div>
    <div class="ad-parent-management-insight ad-parent-management-gi-discuss"><div class="ad-parent-management-insight-ico"><i class="bi bi-chat-dots-fill"></i></div><div class="ad-parent-management-insight-val"><asp:Literal ID="litDiscuss" runat="server" Text="0" /></div><div class="ad-parent-management-insight-lbl"><%= T("Forum Discussions", "Perbincangan Forum") %></div></div>
    <div class="ad-parent-management-insight ad-parent-management-gi-active"><div class="ad-parent-management-insight-ico"><i class="bi bi-lightning-fill"></i></div><div class="ad-parent-management-insight-val"><asp:Literal ID="litActive" runat="server" Text="0" /></div><div class="ad-parent-management-insight-lbl"><%= T("Active Parents", "Ibu Bapa Aktif") %></div></div>
</div>

<div class="ad-parent-management-search">
    <i class="bi bi-search text-muted"></i>
    <asp:TextBox ID="txtSearch" runat="server" CssClass="sb-input sb-input-sm" AutoPostBack="false" />
    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="sb-select sb-input-sm" AutoPostBack="false">
        <asp:ListItem Value="">All Status</asp:ListItem>
        <asp:ListItem Value="Active">Active</asp:ListItem>
        <asp:ListItem Value="Blocked">Blocked</asp:ListItem>
    </asp:DropDownList>
    <asp:DropDownList ID="ddlLang" runat="server" CssClass="sb-select sb-input-sm" AutoPostBack="false">
        <asp:ListItem Value="">All Languages</asp:ListItem>
        <asp:ListItem Value="EN">English</asp:ListItem>
        <asp:ListItem Value="BM">Bahasa Melayu</asp:ListItem>
    </asp:DropDownList>
    <asp:DropDownList ID="ddlSort" runat="server" CssClass="sb-select sb-input-sm" AutoPostBack="false">
        <asp:ListItem Value="name">A-Z</asp:ListItem>
        <asp:ListItem Value="name_desc">Z-A</asp:ListItem>
        <asp:ListItem Value="children_desc">Most Children</asp:ListItem>
    </asp:DropDownList>
    <asp:Button ID="btnSearch" runat="server" CssClass="sb-btn sb-btn-primary sb-btn-sm" OnClick="btnSearch_Click" />
    <asp:Button ID="btnReset" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnReset_Click" />
</div>

<asp:Panel ID="pnlParents" runat="server" Visible="false">
    <div class="ad-parent-management-grid">
        <asp:Repeater ID="rptParents" runat="server" OnItemCommand="rptParents_ItemCommand">
            <ItemTemplate>
                <div class="ad-parent-management-card">
                    <div class="ad-parent-management-avatar" style='<%# Eval("gradient") %>'><%# HttpUtility.HtmlEncode(Eval("initials")) %><span class='ad-parent-management-avatar-dot <%# Eval("dotClass") %>'></span></div>
                    <div class="ad-parent-management-name"><%# HttpUtility.HtmlEncode(Eval("displayName")) %></div>
                    <div class="ad-parent-management-username">@<%# HttpUtility.HtmlEncode(Eval("username")) %></div>
                    <div class="ad-parent-management-pills">
                        <span class='ad-parent-management-pill ad-parent-management-pill-status <%# Eval("statusPillClass") %>'><%# HttpUtility.HtmlEncode(Eval("statusLabel")) %></span>
                        <span class="ad-parent-management-pill ad-parent-management-pill-lang"><%# HttpUtility.HtmlEncode(Eval("language")) %></span>
                        <span class="ad-parent-management-pill ad-parent-management-pill-children"><i class="bi bi-people-fill"></i> <%# Eval("childCount") %></span>
                    </div>
                    <div class="ad-parent-management-meta">
                        <span><i class="bi bi-telephone"></i> <%# HttpUtility.HtmlEncode(Eval("phone")) %></span>
                    </div>
                    <div class="ad-parent-management-card-actions">
                        <asp:LinkButton ID="lnkProfile" runat="server" CssClass="sb-btn sb-btn-light sb-btn-xs"
                            CommandName="ViewProfile" CommandArgument='<%# Eval("parentId") %>'
                            data-tooltip="View parent profile">
                            <i class="bi bi-eye"></i> <%= T("View Profile", "Lihat Profil") %>
                        </asp:LinkButton>
                        <asp:LinkButton ID="lnkChildren" runat="server" CssClass="sb-btn sb-btn-light sb-btn-xs"
                            CommandName="ViewChildren" CommandArgument='<%# Eval("parentId") %>'
                            data-tooltip="View linked children">
                            <i class="bi bi-link-45deg"></i> <%= T("Children", "Anak") %>
                        </asp:LinkButton>
                        <a href='<%# ResolveUrl("~/Admin/ParentDetails.aspx?id=" + Eval("parentId")) %>' class="sb-btn sb-btn-primary sb-btn-xs">
                            <i class="bi bi-gear"></i> <%= T("Manage", "Urus") %>
                        </a>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>

<asp:Panel ID="pnlEmpty" runat="server">
    <div class="ad-parent-management-empty">
        <div class="ad-parent-management-empty-ico"><i class="bi bi-person-heart"></i></div>
        <div class="ad-parent-management-empty-msg"><%= T("No parents found.", "Tiada ibu bapa ditemui.") %></div>
        <div class="ad-parent-management-empty-sub"><%= T("Try adjusting your search or filters.", "Cuba laraskan carian atau penapis anda.") %></div>
    </div>
</asp:Panel>

<%-- ══ PROFILE MODAL ══ --%>
<asp:Panel ID="pnlProfileModal" runat="server" Visible="false">
    <div class="sb-modal-overlay active" style="display:flex;">
        <div class="sb-modal" style="max-width:520px;">
            <div class="ad-parent-management-modal-hdr">
                <div class="ad-parent-management-modal-avatar"><asp:Literal ID="litModalInitials" runat="server" /></div>
                <div class="ad-parent-management-modal-name"><asp:Literal ID="litModalName" runat="server" /></div>
                <div class="ad-parent-management-modal-user">@<asp:Literal ID="litModalUsername" runat="server" /></div>
            </div>
            <div class="ad-parent-management-modal-stats">
                <div class="ad-parent-management-modal-stat"><div class="ad-parent-management-modal-stat-val"><asp:Literal ID="litModalChildren" runat="server" Text="0" /></div><div class="ad-parent-management-modal-stat-lbl"><%= T("Children", "Anak") %></div></div>
                <div class="ad-parent-management-modal-stat"><div class="ad-parent-management-modal-stat-val"><asp:Literal ID="litModalForums" runat="server" Text="0" /></div><div class="ad-parent-management-modal-stat-lbl"><%= T("Discussions", "Perbincangan") %></div></div>
                <div class="ad-parent-management-modal-stat"><div class="ad-parent-management-modal-stat-val"><asp:Literal ID="litModalLang" runat="server" Text="-" /></div><div class="ad-parent-management-modal-stat-lbl"><%= T("Language", "Bahasa") %></div></div>
            </div>
            <div class="ad-parent-management-modal-body">
                <div class="ad-parent-management-modal-field"><div class="ad-parent-management-modal-label"><%= T("Email", "E-mel") %></div><div class="ad-parent-management-modal-value"><asp:Literal ID="litModalEmail" runat="server" Text="-" /></div></div>
                <div class="ad-parent-management-modal-field"><div class="ad-parent-management-modal-label"><%= T("Phone", "Telefon") %></div><div class="ad-parent-management-modal-value"><asp:Literal ID="litModalPhone" runat="server" Text="-" /></div></div>
                <div class="ad-parent-management-modal-field"><div class="ad-parent-management-modal-label"><%= T("Status", "Status") %></div><div class="ad-parent-management-modal-value"><asp:Literal ID="litModalStatus" runat="server" Text="-" /></div></div>
            </div>
            <div class="sb-modal-footer">
                <asp:Button ID="btnCloseProfile" runat="server" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnCloseModal_Click" />
            </div>
        </div>
    </div>
</asp:Panel>

<%-- ══ CHILDREN MODAL ══ --%>
<asp:Panel ID="pnlChildrenModal" runat="server" Visible="false">
    <div class="sb-modal-overlay active" style="display:flex;">
        <div class="sb-modal" style="max-width:560px;">
            <div class="sb-modal-header">
                <span class="sb-modal-title"><i class="bi bi-link-45deg"></i> <%= T("Linked Children", "Anak yang Dihubungkan") %></span>
                <asp:LinkButton ID="lnkCloseChildren" runat="server" CssClass="sb-modal-close" OnClick="btnCloseModal_Click"><i class="bi bi-x-lg"></i></asp:LinkButton>
            </div>
            <div class="sb-modal-body">
                <asp:Panel ID="pnlChildrenList" runat="server" Visible="false">
                    <asp:Repeater ID="rptChildren" runat="server">
                        <ItemTemplate>
                            <div class="ad-parent-management-child-card">
                                <div class="ad-parent-management-child-avatar" style='<%# Eval("gradient") %>'><%# HttpUtility.HtmlEncode(Eval("initials")) %></div>
                                <div class="ad-parent-management-child-info">
                                    <div class="ad-parent-management-child-name"><%# HttpUtility.HtmlEncode(Eval("name")) %></div>
                                    <div class="ad-parent-management-child-meta">
                                        <span><i class="bi bi-bar-chart"></i> <%# HttpUtility.HtmlEncode(Eval("level")) %></span>
                                        <span><i class="bi bi-lightning"></i> <%# Eval("xp") %> XP</span>
                                    </div>
                                    <div class="ad-parent-management-child-xp-bar"><div class="ad-parent-management-child-xp-fill" style='width:<%# Eval("xpPct") %>%'></div></div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </asp:Panel>
                <asp:Panel ID="pnlNoChildren" runat="server">
                    <div class="ad-parent-management-empty" style="padding:var(--space-xl);">
                        <div class="ad-parent-management-empty-ico" style="font-size:2rem;"><i class="bi bi-person-x"></i></div>
                        <div class="ad-parent-management-empty-msg"><%= T("No linked children.", "Tiada anak dipautkan.") %></div>
                    </div>
                </asp:Panel>
            </div>
        </div>
    </div>
</asp:Panel>

<%-- ADD PARENT MODAL --%>
<div id="addParentOverlay" style="display:none;position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,.5);z-index:2000;align-items:center;justify-content:center;padding:20px;">
<div style="background:#fff;border-radius:20px;width:100%;max-width:560px;max-height:90vh;overflow-y:auto;box-shadow:0 25px 60px rgba(0,0,0,.2);animation:ad-parent-management-modalIn .3s ease;">
<div style="padding:24px 28px;border-bottom:1px solid #F1F5F9;display:flex;align-items:center;justify-content:space-between;">
    <div><div style="font-family:var(--font-primary);font-size:1.1rem;font-weight:800;display:flex;align-items:center;gap:8px;"><i class="bi bi-person-plus-fill" style="color:#0891B2;"></i> <%= T("Add New Parent","Tambah Ibu Bapa Baharu") %></div><div style="font-size:.8rem;color:#64748B;margin-top:2px;"><%= T("Create a new parent account.","Cipta akaun ibu bapa baharu.") %></div></div>
    <button onclick="closeAddParent()" style="width:36px;height:36px;border:none;background:#F1F5F9;border-radius:10px;cursor:pointer;display:flex;align-items:center;justify-content:center;"><i class="bi bi-x-lg"></i></button>
</div>
<div style="padding:24px 28px;">
<div class="ad-parent-management-add-grid">
<div class="ad-parent-management-add-field"><label class="ad-parent-management-add-label"><%= T("Full Name *","Nama Penuh *") %></label><input id="p_name" class="ad-parent-management-add-input" type="text" /><div class="ad-parent-management-add-err" id="pe_name"><%= T("Required","Diperlukan") %></div></div>
<div class="ad-parent-management-add-field"><label class="ad-parent-management-add-label"><%= T("Username *","Nama Pengguna *") %></label><input id="p_username" class="ad-parent-management-add-input" type="text" /><div class="ad-parent-management-add-err" id="pe_username"><%= T("Required","Diperlukan") %></div></div>
<div class="ad-parent-management-add-field"><label class="ad-parent-management-add-label"><%= T("Email *","E-mel *") %></label><input id="p_email" class="ad-parent-management-add-input" type="email" /><div class="ad-parent-management-add-err" id="pe_email"><%= T("Required","Diperlukan") %></div></div>
<div class="ad-parent-management-add-field"><label class="ad-parent-management-add-label"><%= T("Phone Number","Nombor Telefon") %></label><input id="p_phone" class="ad-parent-management-add-input" type="text" /></div>
<div class="ad-parent-management-add-field"><label class="ad-parent-management-add-label"><%= T("Password *","Kata Laluan *") %></label><input id="p_pw" class="ad-parent-management-add-input" type="password" /><div class="ad-parent-management-add-err" id="pe_pw"><%= T("Min 8 characters","Min 8 aksara") %></div></div>
<div class="ad-parent-management-add-field"><label class="ad-parent-management-add-label"><%= T("Confirm Password *","Sahkan Kata Laluan *") %></label><input id="p_pw2" class="ad-parent-management-add-input" type="password" /><div class="ad-parent-management-add-err" id="pe_pw2"><%= T("Passwords do not match","Kata laluan tidak sama") %></div></div>
<div class="ad-parent-management-add-field"><label class="ad-parent-management-add-label"><%= T("Preferred Language","Bahasa Pilihan") %></label><select id="p_lang" class="ad-parent-management-add-input"><option value="EN">English</option><option value="BM">Bahasa Melayu</option></select></div>
</div>
<div style="display:flex;gap:10px;justify-content:flex-end;margin-top:20px;padding-top:16px;border-top:1px solid #F1F5F9;">
<button onclick="closeAddParent()" style="padding:10px 22px;border-radius:10px;border:1.5px solid #E2E8F0;background:#fff;font-weight:600;cursor:pointer;"><%= T("Cancel","Batal") %></button>
<button onclick="submitAddParent()" style="padding:10px 26px;border-radius:10px;border:none;background:linear-gradient(135deg,#0E7490,#0891B2);color:#fff;font-weight:700;cursor:pointer;box-shadow:0 4px 14px rgba(8,145,178,.3);"><i class="bi bi-person-plus-fill"></i> <%= T("Create Parent","Cipta Ibu Bapa") %></button>
</div>
</div></div></div>

<script>
function openAddParent(){document.getElementById('addParentOverlay').style.display='flex';}
function closeAddParent(){document.getElementById('addParentOverlay').style.display='none';}
function submitAddParent(){
    var n=document.getElementById('p_name').value.trim(),u=document.getElementById('p_username').value.trim(),e=document.getElementById('p_email').value.trim(),pw=document.getElementById('p_pw').value,pw2=document.getElementById('p_pw2').value;
    var ok=true;['pe_name','pe_username','pe_email','pe_pw','pe_pw2'].forEach(function(id){document.getElementById(id).style.display='none';});
    if(!n){document.getElementById('pe_name').style.display='block';ok=false;}
    if(!u){document.getElementById('pe_username').style.display='block';ok=false;}
    if(!e||e.indexOf('@')<0){document.getElementById('pe_email').style.display='block';ok=false;}
    if(pw.length<8){document.getElementById('pe_pw').style.display='block';ok=false;}
    if(pw!==pw2){document.getElementById('pe_pw2').style.display='block';ok=false;}
    if(!ok)return;
    var ph=document.getElementById('p_phone').value.trim(),lang=document.getElementById('p_lang').value;
    closeAddParent();
    Swal.fire({
        title:'<%= T("Create New Account?","Cipta Akaun Baharu?") %>',
        text:'<%= T("Are you sure you want to create this account?","Adakah anda pasti ingin mencipta akaun ini?") %>',
        icon:'question',showCancelButton:true,
        confirmButtonText:'<i class="bi bi-person-plus-fill"></i> <%= T("Create","Cipta") %>',
        cancelButtonText:'<%= T("Cancel","Batal") %>',
        confirmButtonColor:'#0891B2',reverseButtons:true
    }).then(function(r){
        if(!r.isConfirmed){openAddParent();return;}
        var fd=new FormData();fd.append('name',n);fd.append('username',u);fd.append('email',e);fd.append('password',pw);fd.append('phone',ph);fd.append('lang',lang);
        fetch(window.location.pathname + (window.location.pathname.indexOf('.aspx') === -1 ? '.aspx' : '') + '?handler=ParentCRUD&action=addParent',{method:'POST',body:fd})
        .then(function(r){return r.json();}).then(function(d){
            if(d.success){Swal.fire({icon:'success',title:'<%= T("Parent Created!","Ibu Bapa Dicipta!") %>',text:'<%= T("The parent account has been created successfully.","Akaun ibu bapa telah berjaya dicipta.") %>',confirmButtonColor:'#0891B2',timer:3000,timerProgressBar:true}).then(function(){__doPostBack('<%= btnSearch.UniqueID %>','');});}
            else{openAddParent();Swal.fire({icon:'error',title:'<%= T("Error","Ralat") %>',text:d.msg});}
        }).catch(function(){openAddParent();Swal.fire({icon:'error',title:'Network Error',text:'Please try again.'});});
    });
}
</script>
</asp:Content>
