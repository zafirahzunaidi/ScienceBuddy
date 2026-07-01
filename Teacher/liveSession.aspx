<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="liveSession.aspx.cs"
    Inherits="ScienceBuddy.Teacher.liveSession" MasterPageFile="~/Site.Master" Title="Live Sessions" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--tp:#6C63FF;--tp2:#8B5CF6;--th:#5A52E0;--tl:#F5F3FF;--tc:#FFF;--tb:#E5E7EB;--tt:#374151;--tm:#6B7280;--ts:#10B981;--te:#EF4444;--tw:#F59E0B;}
.ls-header{display:flex;align-items:center;justify-content:space-between;margin-bottom:1.5rem;flex-wrap:wrap;gap:1rem;}
.ls-header h1{font-size:1.5rem;font-weight:800;color:var(--tt);margin:0;}
.ls-header p{font-size:.85rem;color:var(--tm);margin:.2rem 0 0;}
.ls-btn-create{display:inline-flex;align-items:center;gap:6px;background:var(--tp);border:none;border-radius:10px;padding:.6rem 1.25rem;font-weight:700;font-size:.85rem;color:#fff;cursor:pointer;text-decoration:none;transition:all .2s;box-shadow:0 2px 8px rgba(108,99,255,.15);}
.ls-btn-create:hover{background:var(--th);box-shadow:0 4px 16px rgba(108,99,255,.25);color:#fff;text-decoration:none;}
.ls-grid{display:grid;grid-template-columns:1fr 340px;gap:1.5rem;align-items:start;}
/* Calendar */
.ls-cal-card{background:var(--tc);border:1.5px solid var(--tb);border-radius:16px;padding:1.5rem;box-shadow:0 2px 8px rgba(0,0,0,.03);}
.ls-cal-header{display:flex;align-items:center;justify-content:space-between;margin-bottom:1rem;}
.ls-cal-month{font-size:1rem;font-weight:800;color:var(--tt);}
.ls-cal-nav{display:flex;gap:4px;}
.ls-cal-nav button{width:30px;height:30px;border-radius:8px;border:1.5px solid var(--tb);background:var(--tc);cursor:pointer;display:flex;align-items:center;justify-content:center;font-size:.85rem;color:var(--tm);transition:all .15s;}
.ls-cal-nav button:hover{border-color:var(--tp);color:var(--tp);}
.ls-cal-grid{display:grid;grid-template-columns:repeat(7,1fr);gap:4px;text-align:center;}
.ls-cal-grid .cal-h{font-size:.7rem;font-weight:700;color:var(--tm);padding:6px 0;}
.ls-cal-grid .cal-d{padding:8px 4px;border-radius:8px;font-size:.8rem;color:var(--tt);cursor:default;transition:all .15s;}
.ls-cal-grid .cal-d.today{background:var(--tp);color:#fff;font-weight:700;}
.ls-cal-grid .cal-d.has-session{background:#EDE9FE;color:var(--tp);font-weight:700;cursor:pointer;}
.ls-cal-grid .cal-d.has-session:hover{background:var(--tp);color:#fff;}
.ls-cal-grid .cal-d.empty{color:transparent;cursor:default;}
/* Sessions panel */
.ls-panel{background:var(--tc);border:1.5px solid var(--tb);border-radius:16px;padding:1.25rem;box-shadow:0 2px 8px rgba(0,0,0,.03);}
.ls-panel-title{font-size:.85rem;font-weight:700;color:var(--tt);margin-bottom:1rem;display:flex;align-items:center;gap:6px;}
.ls-panel-title i{color:var(--tp);}
.ls-session{padding:.75rem;border-radius:12px;border:1.5px solid var(--tb);margin-bottom:.6rem;transition:all .2s;}
.ls-session:hover{border-color:#EDE9FE;box-shadow:0 3px 10px rgba(108,99,255,.06);}
.ls-session-title{font-size:.84rem;font-weight:700;color:var(--tt);margin-bottom:4px;}
.ls-session-meta{font-size:.74rem;color:var(--tm);display:flex;flex-wrap:wrap;gap:8px;}
.ls-session-meta span{display:inline-flex;align-items:center;gap:3px;}
.ls-badge{padding:2px 8px;border-radius:6px;font-size:.66rem;font-weight:700;}
.ls-badge-upcoming{background:#EDE9FE;color:var(--tp);}
.ls-badge-active{background:#D1FAE5;color:#047857;}
.ls-badge-completed{background:#F3F4F6;color:var(--tm);}
.ls-session-actions{display:flex;gap:6px;margin-top:6px;}
.ls-act{font-size:.7rem;font-weight:600;padding:3px 8px;border-radius:6px;border:1px solid;cursor:pointer;background:transparent;text-decoration:none;display:inline-flex;align-items:center;gap:3px;}
.ls-act-del{color:var(--te);border-color:#FEE2E2;}.ls-act-del:hover{background:#FEF2F2;}
.ls-empty{text-align:center;padding:2rem;color:var(--tm);font-size:.85rem;}
/* Modal */
.ls-modal-overlay{position:fixed;inset:0;background:rgba(17,24,39,.5);z-index:9000;display:flex;align-items:center;justify-content:center;padding:1rem;}
.ls-modal{background:#fff;border-radius:16px;width:100%;max-width:500px;box-shadow:0 20px 60px rgba(0,0,0,.2);animation:lsFade .2s ease;}
@keyframes lsFade{from{opacity:0;transform:translateY(10px);}to{opacity:1;transform:translateY(0);}}
.ls-modal-header{display:flex;align-items:center;justify-content:space-between;padding:1.25rem 1.5rem;border-bottom:1px solid var(--tb);}
.ls-modal-header h3{font-size:1rem;font-weight:800;color:var(--tt);margin:0;}
.ls-modal-close{background:none;border:none;font-size:1.4rem;color:var(--tm);cursor:pointer;}.ls-modal-close:hover{color:var(--tt);}
.ls-modal-body{padding:1.25rem 1.5rem;max-height:60vh;overflow-y:auto;}
.ls-modal-footer{display:flex;gap:.75rem;justify-content:flex-end;padding:1rem 1.5rem;border-top:1px solid var(--tb);}
.ls-field{margin-bottom:1rem;}.ls-label{font-size:.78rem;font-weight:600;color:var(--tt);display:block;margin-bottom:4px;}
.ls-input{width:100%;border-radius:10px;border:1.5px solid var(--tb);padding:.55rem .75rem;font-size:.84rem;transition:border-color .2s;}
.ls-input:focus{border-color:var(--tp);outline:none;}
.ls-row2{display:grid;grid-template-columns:1fr 1fr;gap:1rem;}
.ls-btn-primary{background:var(--tp);border:none;border-radius:10px;padding:.55rem 1.25rem;font-weight:700;font-size:.84rem;color:#fff;cursor:pointer;}.ls-btn-primary:hover{background:var(--th);}
.ls-btn-cancel{background:var(--tc);border:1.5px solid var(--tb);border-radius:10px;padding:.55rem 1rem;font-weight:600;font-size:.84rem;color:var(--tt);cursor:pointer;}
.ls-toast-wrap{position:fixed;top:1.25rem;right:1.25rem;z-index:9999;}
.ls-toast{background:var(--ts);color:#fff;padding:.65rem 1.1rem;border-radius:10px;font-size:.82rem;font-weight:600;display:flex;align-items:center;gap:6px;box-shadow:0 6px 18px rgba(16,185,129,.25);animation:lsFade .3s ease;}
@media(max-width:900px){.ls-grid{grid-template-columns:1fr;}}
</style>
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Teaching","Pengajaran") %></div>
        <a href="<%: ResolveUrl("~/Teacher/manageMaterials.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label"><%: T("Manage Materials","Bahan Pembelajaran") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label"><%: T("Manage Quiz","Kuiz") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/studentProgress.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bar-chart item-icon"></i><span class="item-label"><%: T("Student Progress","Prestasi Pelajar") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/liveSession.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-camera-video item-icon"></i><span class="item-label"><%: T("Schedule Live Class","Kelas Langsung") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Community","Komuniti") %></div>
        <a href="<%: ResolveUrl("~/Teacher/forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/privateMessages.aspx") %>" class="sb-sidebar-item"><i class="bi bi-envelope item-icon"></i><span class="item-label"><%: T("Private Message","Mesej Peribadi") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Account","Akaun") %></div>
        <a href="<%: ResolveUrl("~/Teacher/MyProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("My Profile","Profil Saya") %></span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Sign Out","Log Keluar") %></span></a></div>
</asp:Content>
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Live Sessions","Kelas Langsung") %></asp:Content>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<div class="ls-header">
    <div><h1><%: T("Live Sessions","Kelas Langsung") %></h1><p><%: T("Schedule and manage your online live classes.","Jadualkan dan urus kelas langsung dalam talian anda.") %></p></div>
    <button type="button" class="ls-btn-create" onclick="document.getElementById('scheduleModal').style.display='flex'"><i class="bi bi-plus-lg"></i> <%: T("Schedule Live Class","Jadual Kelas Langsung") %></button>
</div>

<div class="ls-grid">
<%-- Calendar --%>
<div class="ls-cal-card">
    <div class="ls-cal-header">
        <div class="ls-cal-month"><asp:Literal ID="litMonth" runat="server" /></div>
        <div class="ls-cal-nav">
            <asp:Button ID="btnPrevMonth" runat="server" Text="‹" OnClick="btnPrevMonth_Click" CausesValidation="false" style="width:30px;height:30px;border-radius:8px;border:1.5px solid #E5E7EB;background:#fff;cursor:pointer;" />
            <asp:Button ID="btnNextMonth" runat="server" Text="›" OnClick="btnNextMonth_Click" CausesValidation="false" style="width:30px;height:30px;border-radius:8px;border:1.5px solid #E5E7EB;background:#fff;cursor:pointer;" />
        </div>
    </div>
    <div class="ls-cal-grid"><asp:Literal ID="litCalendar" runat="server" /></div>
</div>

<%-- Upcoming Sessions --%>
<div class="ls-panel">
    <div class="ls-panel-title"><i class="bi bi-broadcast"></i> <%: T("Upcoming Sessions","Sesi Akan Datang") %></div>
    <asp:Panel ID="pnlSessions" runat="server" Visible="false">
        <asp:Repeater ID="rptSessions" runat="server" OnItemCommand="rptSessions_ItemCommand">
            <ItemTemplate>
                <div class="ls-session">
                    <div class="ls-session-title"><%# HttpUtility.HtmlEncode(Eval("title")) %></div>
                    <div class="ls-session-meta">
                        <span><i class="bi bi-calendar-event"></i> <%# Eval("dateStr") %></span>
                        <span><i class="bi bi-clock"></i> <%# Eval("timeStr") %></span>
                        <span><i class="bi bi-people"></i> <%# Eval("participants") %></span>
                        <span class='ls-badge <%# Eval("badgeCss") %>'><%# Eval("statusLabel") %></span>
                    </div>
                    <div class="ls-session-actions">
                        <asp:LinkButton ID="btnDel" runat="server" CommandName="Delete" CommandArgument='<%# Eval("sessionId") %>' CssClass="ls-act ls-act-del" CausesValidation="false" OnClientClick="return confirm('Delete this session?');">
                            <i class="bi bi-trash"></i> <%# CurrentLanguage=="BM"?"Padam":"Delete" %>
                        </asp:LinkButton>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </asp:Panel>
    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="ls-empty"><i class="bi bi-calendar-x" style="font-size:1.5rem;opacity:.4;display:block;margin-bottom:.5rem;"></i><%: T("No upcoming live sessions.","Tiada sesi langsung akan datang.") %></div>
    </asp:Panel>
</div>
</div>

<%-- Schedule Modal --%>
<div id="scheduleModal" class="ls-modal-overlay" style="display:none;">
    <div class="ls-modal">
        <div class="ls-modal-header"><h3><%: T("Schedule Live Class","Jadual Kelas Langsung") %></h3><button type="button" class="ls-modal-close" onclick="document.getElementById('scheduleModal').style.display='none'">×</button></div>
        <div class="ls-modal-body">
            <div class="ls-field"><label class="ls-label"><%: T("Class Title","Tajuk Kelas") %> *</label><asp:TextBox ID="txtTitle" runat="server" CssClass="ls-input" MaxLength="200" /></div>
            <div class="ls-row2">
                <div class="ls-field"><label class="ls-label"><%: T("Date","Tarikh") %> *</label><asp:TextBox ID="txtDate" runat="server" CssClass="ls-input" TextMode="Date" /></div>
                <div class="ls-field"><label class="ls-label"><%: T("Start Time","Masa Mula") %> *</label><asp:TextBox ID="txtStart" runat="server" CssClass="ls-input" TextMode="Time" /></div>
            </div>
            <div class="ls-row2">
                <div class="ls-field"><label class="ls-label"><%: T("End Time","Masa Tamat") %> *</label><asp:TextBox ID="txtEnd" runat="server" CssClass="ls-input" TextMode="Time" /></div>
                <div class="ls-field"><label class="ls-label"><%: T("Subtopic","Subtopik") %> *</label><asp:DropDownList ID="ddlSubtopic" runat="server" CssClass="ls-input" /></div>
            </div>
            <div class="ls-field"><label class="ls-label"><%: T("Meeting Link","Pautan Mesyuarat") %> *</label><asp:TextBox ID="txtLink" runat="server" CssClass="ls-input" MaxLength="255" /></div>
            <div class="ls-field"><label class="ls-label"><%: T("Description","Penerangan") %></label><asp:TextBox ID="txtDesc" runat="server" CssClass="ls-input" TextMode="MultiLine" Rows="2" /></div>
            <asp:Panel ID="pnlError" runat="server" Visible="false"><div style="font-size:.76rem;color:var(--te);font-weight:600;"><asp:Literal ID="litError" runat="server" /></div></asp:Panel>
        </div>
        <div class="ls-modal-footer">
            <button type="button" class="ls-btn-cancel" onclick="document.getElementById('scheduleModal').style.display='none'"><%: T("Cancel","Batal") %></button>
            <asp:Button ID="btnSchedule" runat="server" CssClass="ls-btn-primary" OnClick="btnSchedule_Click" CausesValidation="false" />
        </div>
    </div>
</div>

<asp:HiddenField ID="hidToast" runat="server" Value="" />
<asp:HiddenField ID="hidShowModal" runat="server" Value="" />
<asp:HiddenField ID="hidCalMonth" runat="server" Value="" />
<div class="ls-toast-wrap" id="lsToast"></div>
</asp:Content>
<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
window.addEventListener('load',function(){
    var h=document.getElementById('<%=hidToast.ClientID%>');
    if(h&&h.value){var w=document.getElementById('lsToast'),t=document.createElement('div');t.className='ls-toast';t.innerHTML='<i class="bi bi-check-circle-fill"></i> '+h.value;w.appendChild(t);h.value='';setTimeout(function(){t.style.opacity='0';t.style.transition='opacity .3s';},2500);setTimeout(function(){t.remove();},3e3);}
    var sm=document.getElementById('<%=hidShowModal.ClientID%>');
    if(sm&&sm.value==='1'){document.getElementById('scheduleModal').style.display='flex';sm.value='';}
});
</script>
</asp:Content>
