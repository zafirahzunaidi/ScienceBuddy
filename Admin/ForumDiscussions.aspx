<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ForumDiscussions.aspx.cs"
    Inherits="ScienceBuddy.Admin.ForumDiscussions" MasterPageFile="~/Site.Master"
    Title="Forum Discussions" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" />
<style>
:root{--fd:#8B5CF6;--fd-light:#F5F3FF;--fd-border:#DDD6FE;}
.fd-hdr{display:flex;align-items:center;justify-content:space-between;padding:var(--space-xl) 0 var(--space-lg);border-bottom:1.5px solid var(--border-color);margin-bottom:var(--space-xl);flex-wrap:wrap;gap:var(--space-md);}
.fd-hdr-title{font-family:var(--font-primary);font-size:1.75rem;font-weight:800;color:var(--color-text);display:flex;align-items:center;gap:10px;}
.fd-hdr-sub{font-size:.875rem;color:var(--color-text-secondary);margin-top:4px;max-width:480px;}
.fd-stats{display:grid;grid-template-columns:repeat(4,1fr);gap:var(--space-md);margin-bottom:var(--space-xl);}
.fd-stat{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);padding:var(--space-lg);display:flex;align-items:center;gap:var(--space-md);transition:transform .2s,box-shadow .2s;position:relative;overflow:hidden;}
.fd-stat:hover{transform:translateY(-3px);box-shadow:var(--shadow-md);}
.fd-stat::before{content:'';position:absolute;top:0;left:0;right:0;height:3px;}
.fd-stat.s1::before{background:linear-gradient(90deg,#8B5CF6,#A78BFA);}.fd-stat.s2::before{background:linear-gradient(90deg,#2563EB,#60A5FA);}.fd-stat.s3::before{background:linear-gradient(90deg,#059669,#34D399);}.fd-stat.s4::before{background:linear-gradient(90deg,#D97706,#FBBF24);}
.fd-stat-ico{width:46px;height:46px;border-radius:var(--border-radius-lg);display:flex;align-items:center;justify-content:center;font-size:1.2rem;flex-shrink:0;}
.fd-stat-val{font-family:var(--font-primary);font-size:1.6rem;font-weight:800;color:var(--color-text);}
.fd-stat-lbl{font-size:.78rem;color:var(--color-text-secondary);font-weight:600;}
.fd-toolbar{display:flex;gap:var(--space-md);margin-bottom:var(--space-xl);flex-wrap:wrap;align-items:center;background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);padding:var(--space-md) var(--space-lg);}
.fd-search{flex:1;min-width:200px;position:relative;}.fd-search i{position:absolute;left:12px;top:50%;transform:translateY(-50%);color:var(--color-text-muted);}
.fd-search input{width:100%;padding:9px 12px 9px 38px;border:1.5px solid var(--border-color);border-radius:var(--border-radius);font-size:.875rem;transition:border-color .2s;}.fd-search input:focus{outline:none;border-color:var(--fd);}
.fd-filter{padding:8px 12px;border:1.5px solid var(--border-color);border-radius:var(--border-radius);font-size:.8rem;background:var(--color-white);}.fd-filter:focus{outline:none;border-color:var(--fd);}
.fd-grid{display:grid;grid-template-columns:repeat(2,1fr);gap:var(--space-lg);margin-bottom:var(--space-xl);}
.fd-card{background:var(--color-white);border-radius:var(--border-radius-xl);border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);padding:var(--space-lg);transition:transform .2s,box-shadow .2s;display:flex;flex-direction:column;}
.fd-card:hover{transform:translateY(-3px);box-shadow:var(--shadow-md);}
.fd-card-top{display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:8px;}
.fd-card-id{font-size:.68rem;font-family:monospace;color:var(--color-text-muted);background:var(--color-surface-alt);padding:2px 8px;border-radius:var(--border-radius-full);}
.fd-badge-public{background:#DBEAFE;color:#1D4ED8;padding:3px 10px;border-radius:var(--border-radius-full);font-size:.65rem;font-weight:700;text-transform:uppercase;}
.fd-badge-private{background:#D1FAE5;color:#065F46;padding:3px 10px;border-radius:var(--border-radius-full);font-size:.65rem;font-weight:700;text-transform:uppercase;}
.fd-card-title{font-family:var(--font-primary);font-size:1rem;font-weight:700;color:var(--color-text);line-height:1.4;margin-bottom:6px;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;}
.fd-card-msg{font-size:.8rem;color:var(--color-text-muted);line-height:1.5;margin-bottom:var(--space-md);display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;flex:1;}
.fd-card-meta{display:flex;flex-wrap:wrap;gap:8px;font-size:.75rem;color:var(--color-text-muted);margin-bottom:var(--space-md);}
.fd-card-meta span{display:flex;align-items:center;gap:3px;}
.fd-card-actions{display:flex;gap:6px;padding-top:var(--space-sm);border-top:1px solid #F1F5F9;}
.fd-abtn{padding:6px 14px;border-radius:var(--border-radius);font-size:.75rem;font-weight:700;cursor:pointer;border:1.5px solid var(--border-color);transition:all .2s;display:inline-flex;align-items:center;gap:4px;text-decoration:none;background:var(--color-white);color:var(--color-text-secondary);}
.fd-abtn:hover{transform:translateY(-1px);box-shadow:var(--shadow-sm);}
.fd-abtn-view{border-color:var(--fd);color:var(--fd);}.fd-abtn-view:hover{background:var(--fd-light);}
.fd-abtn-lock{border-color:#D97706;color:#D97706;}.fd-abtn-lock:hover{background:#FFFBEB;}
.fd-abtn-delete{border-color:#DC2626;color:#DC2626;}.fd-abtn-delete:hover{background:#FEF2F2;}
.fd-overlay{display:none;position:fixed;top:0;left:var(--sidebar-width,0px);right:0;bottom:0;background:rgba(0,0,0,.5);z-index:1000;align-items:center;justify-content:center;padding:var(--space-xl);}.fd-overlay.active{display:flex;}
.fd-modal{background:var(--color-white);border-radius:var(--border-radius-xl);width:100%;max-width:640px;max-height:90vh;overflow-y:auto;box-shadow:0 25px 60px rgba(0,0,0,.2);animation:fdIn .3s ease;}
@keyframes fdIn{from{opacity:0;transform:scale(.95)}to{opacity:1;transform:scale(1)}}
.fd-modal-hdr{padding:var(--space-lg) var(--space-xl);border-bottom:1px solid var(--border-color);display:flex;align-items:center;justify-content:space-between;}
.fd-modal-title{font-family:var(--font-primary);font-size:1.1rem;font-weight:700;display:flex;align-items:center;gap:8px;}
.fd-modal-close{width:36px;height:36px;border-radius:var(--border-radius);border:none;background:var(--color-surface-alt);cursor:pointer;display:flex;align-items:center;justify-content:center;font-size:1.1rem;}.fd-modal-close:hover{background:#E2E8F0;}
.fd-modal-body{padding:var(--space-xl);}
.fd-detail{margin-bottom:var(--space-md);}.fd-detail-label{font-size:.7rem;font-weight:600;color:var(--color-text-muted);text-transform:uppercase;letter-spacing:.5px;margin-bottom:3px;}.fd-detail-value{font-size:.9rem;font-weight:600;color:var(--color-text);line-height:1.5;}
.fd-empty{display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;padding:var(--space-2xl);color:var(--color-text-muted);}.fd-empty i{font-size:3rem;opacity:.4;margin-bottom:var(--space-md);}
@media(max-width:1279px){.fd-stats{grid-template-columns:repeat(2,1fr);}.fd-grid{grid-template-columns:repeat(2,1fr);}}
@media(max-width:767px){.fd-stats{grid-template-columns:1fr 1fr;}.fd-grid{grid-template-columns:1fr;}.fd-toolbar{flex-direction:column;align-items:stretch;}}
</style>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="<%: ResolveUrl("~/Scripts/admin-signout.js") %>"></script>
</asp:Content>
<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
<div class="sb-nav-section"><div class="sb-nav-section-label">Main</div><a href="<%: ResolveUrl("~/Admin/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label">Dashboard</span></a></div>
<div class="sb-nav-section"><div class="sb-nav-section-label">User Management</div><a href="<%: ResolveUrl("~/Admin/StudentManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-people item-icon"></i><span class="item-label">Students</span></a><a href="<%: ResolveUrl("~/Admin/ParentManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-heart item-icon"></i><span class="item-label">Parents</span></a><a href="<%: ResolveUrl("~/Admin/TeacherManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person-badge item-icon"></i><span class="item-label">Teachers</span></a></div>
<div class="sb-nav-section"><div class="sb-nav-section-label">Learning Content</div><a href="<%: ResolveUrl("~/Admin/LessonManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label">Lessons</span></a><a href="<%: ResolveUrl("~/Admin/QuizManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label">Quizzes</span></a><a href="<%: ResolveUrl("~/Admin/QuestionBank.aspx") %>" class="sb-sidebar-item"><i class="bi bi-question-circle item-icon"></i><span class="item-label">Question Bank</span></a><a href="<%: ResolveUrl("~/Admin/TeacherMaterials.aspx") %>" class="sb-sidebar-item"><i class="bi bi-file-earmark-text item-icon"></i><span class="item-label">Material Requests</span></a><a href="<%: ResolveUrl("~/Admin/LiveSessions.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label">Live Sessions</span></a><a href="<%: ResolveUrl("~/Admin/QuestionRequests.aspx") %>" class="sb-sidebar-item"><i class="bi bi-clipboard-check item-icon"></i><span class="item-label">Question Requests</span></a><a href="<%: ResolveUrl("~/Admin/CertificateManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-award item-icon"></i><span class="item-label">Certificates</span></a></div>
<div class="sb-nav-section"><div class="sb-nav-section-label">Community</div><a href="<%: ResolveUrl("~/Admin/ForumDiscussions.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-chat-dots item-icon"></i><span class="item-label">Forum Discussions</span></a></div>
<div class="sb-nav-section"><div class="sb-nav-section-label">Gamification</div><a href="<%: ResolveUrl("~/Admin/GamificationManagement.aspx") %>" class="sb-sidebar-item"><i class="bi bi-trophy item-icon"></i><span class="item-label">Student Performance</span></a></div>
<div class="sb-nav-section"><div class="sb-nav-section-label">Configuration</div><a href="<%: ResolveUrl("~/Admin/SystemSettings.aspx") %>" class="sb-sidebar-item"><i class="bi bi-gear item-icon"></i><span class="item-label">System Settings</span></a></div>
<div class="sb-nav-section"><div class="sb-nav-section-label">Logs</div><a href="<%: ResolveUrl("~/Admin/SystemActivityLogs.aspx") %>" class="sb-sidebar-item"><i class="bi bi-clock-history item-icon"></i><span class="item-label">Activity Logs</span></a><a href="<%: ResolveUrl("~/Admin/LoginLogs.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-in-right item-icon"></i><span class="item-label">Login Logs</span></a><a href="<%: ResolveUrl("~/Admin/SuspiciousLogins.aspx") %>" class="sb-sidebar-item"><i class="bi bi-exclamation-triangle item-icon"></i><span class="item-label">Suspicious Logins</span></a></div>
<div class="sb-nav-section"><div class="sb-nav-section-label">Account</div><a href="<%: ResolveUrl("~/Admin/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span></a><a href="<%: ResolveUrl("~/Admin/Profile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a><a href="javascript:;" class="sb-sidebar-item" onclick="showSignOutModal()"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a></div>
</asp:Content>
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%= T("Forum Discussions", "Perbincangan Forum") %></asp:Content>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">
<div class="fd-hdr"><div><div class="fd-hdr-title"><i class="bi bi-chat-dots-fill" style="color:var(--fd);"></i> <%= T("Forum Discussions", "Perbincangan Forum") %></div><div class="fd-hdr-sub"><%= T("Monitor and moderate all community discussions in ScienceBuddy.", "Pantau dan moderasi semua perbincangan komuniti dalam ScienceBuddy.") %></div></div></div>
<div class="fd-stats">
<div class="fd-stat s1"><div class="fd-stat-ico" style="background:#F5F3FF;color:#8B5CF6;"><i class="bi bi-chat-square-text-fill"></i></div><div><div class="fd-stat-val"><asp:Literal ID="litTotal" runat="server" Text="0" /></div><div class="fd-stat-lbl"><%= T("Total Discussions", "Jumlah Perbincangan") %></div></div></div>
<div class="fd-stat s2"><div class="fd-stat-ico" style="background:#DBEAFE;color:#2563EB;"><i class="bi bi-globe"></i></div><div><div class="fd-stat-val"><asp:Literal ID="litPublic" runat="server" Text="0" /></div><div class="fd-stat-lbl"><%= T("Public", "Awam") %></div></div></div>
<div class="fd-stat s3"><div class="fd-stat-ico" style="background:#D1FAE5;color:#059669;"><i class="bi bi-lock-fill"></i></div><div><div class="fd-stat-val"><asp:Literal ID="litPrivate" runat="server" Text="0" /></div><div class="fd-stat-lbl"><%= T("Private", "Persendirian") %></div></div></div>
<div class="fd-stat s4"><div class="fd-stat-ico" style="background:#FEF3C7;color:#D97706;"><i class="bi bi-calendar-check"></i></div><div><div class="fd-stat-val"><asp:Literal ID="litToday" runat="server" Text="0" /></div><div class="fd-stat-lbl"><%= T("Today", "Hari Ini") %></div></div></div>
</div>
<div class="fd-toolbar"><div class="fd-search"><i class="bi bi-search"></i><asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" /></div>
<asp:DropDownList ID="ddlType" runat="server" CssClass="fd-filter"><asp:ListItem Value="" Text="All Types" /><asp:ListItem Value="Public" Text="Public" /><asp:ListItem Value="Private" Text="Private" /></asp:DropDownList>
<asp:DropDownList ID="ddlSort" runat="server" CssClass="fd-filter"><asp:ListItem Value="newest" Text="Newest" /><asp:ListItem Value="oldest" Text="Oldest" /></asp:DropDownList>
<asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="sb-btn sb-btn-primary sb-btn-sm" OnClick="btnSearch_Click" />
<asp:Button ID="btnReset" runat="server" Text="Reset" CssClass="sb-btn sb-btn-ghost sb-btn-sm" OnClick="btnReset_Click" /></div>
<div class="fd-grid"><asp:Repeater ID="rptForums" runat="server"><ItemTemplate>
<div class="fd-card"><div class="fd-card-top"><span class="fd-card-id"><%# Eval("forumId") %></span><span class='<%# Eval("typeCls") %>'><%# Eval("discussionType") %></span></div>
<div class="fd-card-title"><%# HttpUtility.HtmlEncode(Eval("title")) %></div>
<div class="fd-card-msg"><%# HttpUtility.HtmlEncode(Eval("messagePreview")) %></div>
<div class="fd-card-meta"><span><i class="bi bi-person"></i> <%# Eval("username") %></span><span><i class="bi bi-tag"></i> <%# Eval("role") %></span><span><i class="bi bi-calendar3"></i> <%# Eval("createdAt") %></span></div>
<div class="fd-card-actions">
<a href="javascript:;" class="fd-abtn fd-abtn-view" data-json='<%# HttpUtility.HtmlAttributeEncode(Eval("jsonData").ToString()) %>' onclick="viewForum(JSON.parse(this.getAttribute('data-json')))"><i class="bi bi-eye"></i> <%= T("View","Lihat") %></a>
<a href="javascript:;" class="fd-abtn fd-abtn-delete" onclick="deleteForum('<%# Eval("forumId") %>','<%# Eval("createdByUserId") %>')"><i class="bi bi-trash"></i> <%= T("Delete","Padam") %></a>
</div></div>
</ItemTemplate></asp:Repeater></div>
<asp:Panel ID="pnlEmpty" runat="server" Visible="false"><div class="fd-empty"><i class="bi bi-chat-square-text"></i><div style="font-size:1rem;font-weight:600;color:var(--color-text-secondary);"><%= T("No discussions found.", "Tiada perbincangan dijumpai.") %></div></div></asp:Panel>
<div class="fd-overlay" id="fdModal"><div class="fd-modal"><div class="fd-modal-hdr"><span class="fd-modal-title"><i class="bi bi-chat-dots" style="color:var(--fd);"></i> <%= T("Discussion Details","Butiran Perbincangan") %></span><button class="fd-modal-close" onclick="document.getElementById('fdModal').classList.remove('active')"><i class="bi bi-x-lg"></i></button></div><div class="fd-modal-body" id="fdModalBody"></div></div></div>
<script>
function viewForum(d){var h='';h+='<div class="fd-detail"><div class="fd-detail-label">Forum ID</div><div class="fd-detail-value">'+d.id+'</div></div>';h+='<div class="fd-detail"><div class="fd-detail-label"><%= T("Title","Tajuk") %></div><div class="fd-detail-value">'+d.title+'</div></div>';h+='<div class="fd-detail"><div class="fd-detail-label"><%= T("Message","Mesej") %></div><div class="fd-detail-value" style="white-space:pre-wrap;">'+d.message+'</div></div>';h+='<div class="fd-detail"><div class="fd-detail-label"><%= T("Author","Penulis") %></div><div class="fd-detail-value">'+d.username+' ('+d.role+')</div></div>';h+='<div class="fd-detail"><div class="fd-detail-label"><%= T("Type","Jenis") %></div><div class="fd-detail-value">'+d.type+'</div></div>';h+='<div class="fd-detail"><div class="fd-detail-label"><%= T("Created","Dicipta") %></div><div class="fd-detail-value">'+d.date+'</div></div>';document.getElementById('fdModalBody').innerHTML=h;document.getElementById('fdModal').classList.add('active');
fetch(window.location.pathname+'?handler=ForumAction&action=view&forumId='+d.id,{method:'POST',headers:{'X-Requested-With':'XMLHttpRequest'}});}
function deleteForum(fId,uid){Swal.fire({title:'<%= T("Delete Discussion?","Padam Perbincangan?") %>',text:'<%= T("This discussion will be permanently removed.","Perbincangan ini akan dipadam secara kekal.") %>',icon:'warning',showCancelButton:true,confirmButtonText:'<%= T("Delete","Padam") %>',confirmButtonColor:'#DC2626',cancelButtonText:'<%= T("Cancel","Batal") %>'}).then(function(r){if(!r.isConfirmed)return;fetch(window.location.pathname+'?handler=ForumAction&action=delete&forumId='+fId+'&uid='+uid,{method:'POST',headers:{'X-Requested-With':'XMLHttpRequest'}}).then(function(r){return r.json();}).then(function(d){if(d.success){Swal.fire({icon:'success',title:'<%= T("Deleted!","Dipadam!") %>',timer:2000,timerProgressBar:true}).then(function(){location.reload();});}else Swal.fire({icon:'error',title:'Error',text:d.msg});});});}
</script>
</asp:Content>
