<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="liveSession.aspx.cs"
    Inherits="ScienceBuddy.Teacher.liveSession" MasterPageFile="~/Site.Master" Title="Live Sessions" EnableEventValidation="false" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Teacher.css") %>" rel="stylesheet" />
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label"><%: T("Notifications","Notifikasi") %></span></a></div>
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
<asp:HiddenField ID="hidLicenseStatus" runat="server" Value="" />

<%-- Header --%>
<div class="tc-live-session-page-header">
    <div><h1><%: T("Live Sessions","Kelas Langsung") %></h1><p><%: T("Manage all your online classes, schedules, and previous sessions.","Urus semua kelas dalam talian, jadual, dan sesi terdahulu anda.") %></p></div>
</div>

<%-- Pending License Notice --%>
<div id="lsPendingNotice" class="tc-live-session-pending-notice" style="display:none;">
    <div class="tc-live-session-pending-notice-icon"><i class="bi bi-shield-exclamation"></i></div>
    <div class="tc-live-session-pending-notice-content">
        <div class="tc-live-session-pending-notice-title"><%: T("Verification Pending","Pengesahan Menunggu") %></div>
        <div class="tc-live-session-pending-notice-msg"><%: T("Your Teaching License is still under review. Scheduling or starting live classes is temporarily unavailable until your verification has been approved.","Lesen Mengajar anda masih dalam semakan. Penjadualan atau permulaan kelas langsung tidak tersedia buat sementara waktu sehingga pengesahan anda diluluskan.") %></div>
    </div>
</div>

<%-- Action Cards --%>
<div class="tc-live-session-action-row">
    <div class="tc-live-session-action-card tc-live-session-action-schedule" onclick="document.getElementById('scheduleModal').style.display='flex'">
        <div class="tc-live-session-action-icon"><i class="bi bi-calendar-plus"></i></div>
        <div>
            <div class="tc-live-session-action-title"><%: T("Schedule Live Class","Jadualkan Kelas Langsung") %></div>
            <div class="tc-live-session-action-desc"><%: T("Plan a future online class","Rancang kelas dalam talian") %></div>
        </div>
        <div class="tc-live-session-action-cta"><%: T("Schedule","Jadual") %> <i class="bi bi-arrow-right"></i></div>
    </div>
    <div class="tc-live-session-action-card tc-live-session-action-instant" onclick="document.getElementById('instantModal').style.display='flex'">
        <div class="tc-live-session-action-icon"><i class="bi bi-broadcast-pin"></i><span class="tc-live-session-live-dot"></span></div>
        <div>
            <div class="tc-live-session-action-title"><%: T("Start Instant Class","Mulakan Kelas Segera") %></div>
            <div class="tc-live-session-action-desc"><%: T("Begin teaching immediately","Mula mengajar serta-merta") %></div>
        </div>
        <div class="tc-live-session-action-cta"><%: T("Start Now","Mula Sekarang") %> <i class="bi bi-arrow-right"></i></div>
    </div>
</div>

<%-- Stats --%>
<div class="tc-live-session-stats">
    <div class="tc-live-session-stat tc-live-session-stat-upcoming"><div class="tc-live-session-stat-icon" style="background:#DBEAFE;color:#2563EB;"><i class="bi bi-calendar-event"></i></div><div class="tc-live-session-stat-val"><asp:Literal ID="litUpcoming" runat="server" Text="0" /></div><div class="tc-live-session-stat-label"><%: T("Upcoming Sessions","Sesi Akan Datang") %></div></div>
    <div class="tc-live-session-stat tc-live-session-stat-completed"><div class="tc-live-session-stat-icon" style="background:#D1FAE5;color:#047857;"><i class="bi bi-check-circle"></i></div><div class="tc-live-session-stat-val"><asp:Literal ID="litCompleted" runat="server" Text="0" /></div><div class="tc-live-session-stat-label"><%: T("Completed Sessions","Sesi Selesai") %></div></div>
    <div class="tc-live-session-stat tc-live-session-stat-cancelled"><div class="tc-live-session-stat-icon" style="background:#FEE2E2;color:#B91C1C;"><i class="bi bi-x-circle"></i></div><div class="tc-live-session-stat-val"><asp:Literal ID="litCancelled" runat="server" Text="0" /></div><div class="tc-live-session-stat-label"><%: T("Cancelled Sessions","Sesi Dibatalkan") %></div></div>
    <div class="tc-live-session-stat tc-live-session-stat-students"><div class="tc-live-session-stat-icon" style="background:#E0E7FF;color:#4338CA;"><i class="bi bi-people"></i></div><div class="tc-live-session-stat-val"><asp:Literal ID="litStudentsJoined" runat="server" Text="0" /></div><div class="tc-live-session-stat-label"><%: T("Students Joined","Pelajar Menyertai") %></div></div>
</div>

<%-- Tabs (client-side switching, no postback) --%>
<div class="tc-live-session-tabs">
    <button type="button" class="tc-live-session-tab active" id="btnTabUpcoming" onclick="switchLsTab('upcoming')"><%: T("Upcoming","Akan Datang") %></button>
    <button type="button" class="tc-live-session-tab" id="btnTabHistory" onclick="switchLsTab('history')"><%: T("History","Sejarah") %></button>
</div>

<%-- Upcoming Session List --%>
<div id="lsTabUpcoming">
<asp:Panel ID="pnlListUpcoming" runat="server" Visible="false">
    <div class="tc-live-session-cards">
        <asp:Repeater ID="rptUpcoming" runat="server" OnItemCommand="rptSessions_ItemCommand">
            <ItemTemplate>
                <div class="tc-live-session-card">
                    <div class="tc-live-session-card-date"><span class="tc-live-session-card-day"><%# Eval("day") %></span><span class="tc-live-session-card-month"><%# Eval("month") %></span></div>
                    <div class="tc-live-session-card-body">
                        <div class="tc-live-session-card-title"><%# HttpUtility.HtmlEncode(Eval("title")) %></div>
                        <div class="tc-live-session-card-meta">
                            <span><i class="bi bi-clock"></i> <%# Eval("timeRange") %></span>
                            <span><i class="bi bi-bookmark"></i> <%# HttpUtility.HtmlEncode(Eval("topic")) %></span>
                        </div>
                        <span class='tc-live-session-badge <%# Eval("badgeCss") %>'><%# Eval("badgeLabel") %></span>
                    </div>
                    <div class="tc-live-session-card-actions">
                        <asp:LinkButton ID="btnStartSession" runat="server" CommandName="StartSession" CommandArgument='<%# Eval("sessionId") %>' CssClass='<%# (bool)Eval("canStart") ? "tc-live-session-act tc-live-session-act-start" : "tc-live-session-act tc-live-session-act-notyet" %>' CausesValidation="false" Enabled='<%# (bool)Eval("canStart") %>'>
                            <i class='<%# (bool)Eval("canStart") ? "bi bi-broadcast-pin" : "bi bi-clock" %>'></i> <%# (bool)Eval("canStart") ? T("Start Live","Mula Langsung") : T("Not Started Yet","Belum Bermula") %>
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnReschedule" runat="server" CommandName="Reschedule" CommandArgument='<%# Eval("sessionId") + "|" + Eval("rawStart") + "|" + Eval("rawEnd") + "|" + HttpUtility.HtmlEncode(Eval("title")) %>' CssClass="tc-live-session-act tc-live-session-act-edit" CausesValidation="false" Visible='<%# !(bool)Eval("canStart") %>'>
                            <i class="bi bi-calendar2-plus"></i> <%: T("Reschedule","Jadual Semula") %>
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnDel" runat="server" CommandName="Cancel" CommandArgument='<%# Eval("sessionId") + "|" + HttpUtility.HtmlEncode(Eval("title")) + "|" + Eval("timeRange") %>' CssClass="tc-live-session-act tc-live-session-act-cancel" CausesValidation="false">
                            <i class="bi bi-x-lg"></i> <%: T("Cancel","Batal") %>
                        </asp:LinkButton>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>
<asp:Panel ID="pnlUpcomingEmpty" runat="server" Visible="false">
    <div class="tc-live-session-empty">
        <i class="bi bi-calendar2-x"></i>
        <div class="tc-live-session-empty-title"><%: T("No Upcoming Sessions","Tiada Sesi Akan Datang") %></div>
        <div class="tc-live-session-empty-sub"><%: T("You do not have any upcoming live classes scheduled.","Anda tidak mempunyai kelas langsung yang dijadualkan.") %></div>
    </div>
</asp:Panel>
</div>

<%-- History Session List --%>
<div id="lsTabHistory" style="display:none;">
<asp:Panel ID="pnlListHistory" runat="server" Visible="false">
    <div class="tc-live-session-cards">
        <asp:Repeater ID="rptHistory" runat="server" OnItemCommand="rptSessions_ItemCommand">
            <ItemTemplate>
                <div class="tc-live-session-card">
                    <div class="tc-live-session-card-date"><span class="tc-live-session-card-day"><%# Eval("day") %></span><span class="tc-live-session-card-month"><%# Eval("month") %></span></div>
                    <div class="tc-live-session-card-body">
                        <div class="tc-live-session-card-title"><%# HttpUtility.HtmlEncode(Eval("title")) %></div>
                        <div class="tc-live-session-card-meta">
                            <span><i class="bi bi-clock"></i> <%# Eval("timeRange") %></span>
                            <span><i class="bi bi-bookmark"></i> <%# HttpUtility.HtmlEncode(Eval("topic")) %></span>
                            <%# Convert.ToInt32(Eval("students")) > 0 ? "<span><i class='bi bi-people'></i> " + Eval("students") + " students</span>" : "" %>
                            <%# Eval("duration").ToString()!="" ? "<span><i class='bi bi-hourglass-split'></i> " + Eval("duration") + "</span>" : "" %>
                        </div>
                        <span class='tc-live-session-badge <%# Eval("badgeCss") %>'><%# Eval("badgeLabel") %></span>
                    </div>
                    <div class="tc-live-session-card-actions" style='<%# (bool)Eval("isCompleted") ? "" : "display:none;" %>'>
                        <button type="button" class="tc-live-session-view-summary" onclick="viewSessionSummary('<%# Eval("sessionId") %>')">
                            <i class="bi bi-bar-chart-line"></i> <%: T("View Summary","Lihat Ringkasan") %> ?
                        </button>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>
<asp:Panel ID="pnlHistoryEmpty" runat="server" Visible="false">
    <div class="tc-live-session-empty">
        <i class="bi bi-clock-history"></i>
        <div class="tc-live-session-empty-title"><%: T("No Session History","Tiada Sejarah Sesi") %></div>
        <div class="tc-live-session-empty-sub"><%: T("Your completed and cancelled live classes will appear here.","Kelas langsung yang selesai dan dibatalkan akan terpapar di sini.") %></div>
    </div>
</asp:Panel>
</div>

<%-- Start Instant Class Modal --%>
<div id="instantModal" class="tc-live-session-modal-overlay" style="display:none;">
    <div class="tc-live-session-modal">
        <div class="tc-live-session-modal-header"><h3 style="font-size:1.1rem;"><%: T("Start Instant Class","Mulakan Kelas Segera") %></h3><button type="button" class="tc-live-session-modal-close" onclick="document.getElementById('instantModal').style.display='none'">×</button></div>
        <div class="tc-live-session-modal-body">
            <p style="font-size:.82rem;color:var(--tm);margin:0 0 1rem;"><%: T("Create a live class and begin teaching immediately.","Cipta kelas langsung dan mula mengajar serta-merta.") %></p>
            <div class="tc-live-session-field"><label class="tc-live-session-label"><%: T("Session Title","Tajuk Sesi") %> <span style="color:var(--te);">*</span></label><asp:TextBox ID="txtInstantTitle" runat="server" CssClass="tc-live-session-input" MaxLength="200" /><div class="tc-live-session-field-error" id="errInstTitle">Please enter a session title.</div></div>
            <div class="tc-live-session-field"><label class="tc-live-session-label"><%: T("Description","Penerangan") %></label><asp:TextBox ID="txtInstantDesc" runat="server" CssClass="tc-live-session-input" TextMode="MultiLine" Rows="2" /></div>
            <div class="tc-live-session-row2">
                <div class="tc-live-session-field"><label class="tc-live-session-label"><%: T("Unit","Unit") %> <span style="color:var(--te);">*</span></label><asp:DropDownList ID="ddlInstantUnit" runat="server" CssClass="tc-live-session-input" /><div class="tc-live-session-field-error" id="errInstUnit">Please select a unit.</div></div>
                <div class="tc-live-session-field"><label class="tc-live-session-label"><%: T("Subtopic","Subtopik") %> <span style="color:var(--te);">*</span></label><asp:DropDownList ID="ddlInstantSubtopic" runat="server" CssClass="tc-live-session-input" /><div class="tc-live-session-field-error" id="errInstSub">Please select a subtopic.</div></div>
            </div>
            <asp:Panel ID="pnlInstantError" runat="server" Visible="false"><div style="font-size:.78rem;color:var(--te);font-weight:600;margin-top:.25rem;"><asp:Literal ID="litInstantError" runat="server" /></div></asp:Panel>
        </div>
        <div class="tc-live-session-modal-footer">
            <button type="button" class="tc-live-session-btn-cancel-modal" onclick="document.getElementById('instantModal').style.display='none'"><%: T("Cancel","Batal") %></button>
            <asp:Button ID="btnStartLive" runat="server" CssClass="tc-live-session-btn-submit" style="background:#DC2626;" OnClick="btnStartLive_Click" CausesValidation="false" OnClientClick="return validateInstantForm();" />
        </div>
    </div>
</div>
<asp:HiddenField ID="hidShowInstantModal" runat="server" Value="" OnValueChanged="hidShowInstantModal_ValueChanged" />

<%-- Reschedule Modal --%>
<div id="rescheduleModal" class="tc-live-session-modal-overlay" style="display:none;">
    <div class="tc-live-session-modal">
        <div class="tc-live-session-modal-header"><h3><%: T("Reschedule Live Session","Jadual Semula Sesi Langsung") %></h3><button type="button" class="tc-live-session-modal-close" onclick="document.getElementById('rescheduleModal').style.display='none'">×</button></div>
        <div class="tc-live-session-modal-body">
            <div style="background:#F9FAFB;border-radius:10px;padding:.75rem 1rem;margin-bottom:1rem;font-size:.82rem;color:var(--tt);">
                <strong><asp:Literal ID="litRescTitle" runat="server" /></strong><br/>
                <span style="font-size:.76rem;color:var(--tm);"><asp:Literal ID="litRescCurrent" runat="server" /></span>
            </div>
            <asp:HiddenField ID="hidRescId" runat="server" Value="" />
            <div class="tc-live-session-field"><label class="tc-live-session-label"><%: T("New Date","Tarikh Baharu") %> *</label><asp:TextBox ID="txtRescDate" runat="server" CssClass="tc-live-session-input" TextMode="Date" /></div>
            <div class="tc-live-session-row2">
                <div class="tc-live-session-field"><label class="tc-live-session-label"><%: T("New Start Time","Masa Mula Baharu") %> *</label><asp:TextBox ID="txtRescStart" runat="server" CssClass="tc-live-session-input" TextMode="Time" /></div>
                <div class="tc-live-session-field"><label class="tc-live-session-label"><%: T("New End Time","Masa Tamat Baharu") %> *</label><asp:TextBox ID="txtRescEnd" runat="server" CssClass="tc-live-session-input" TextMode="Time" /></div>
            </div>
            <asp:Panel ID="pnlRescError" runat="server" Visible="false"><div style="font-size:.76rem;color:var(--te);font-weight:600;"><asp:Literal ID="litRescError" runat="server" /></div></asp:Panel>
        </div>
        <div class="tc-live-session-modal-footer">
            <button type="button" class="tc-live-session-btn-cancel-modal" onclick="document.getElementById('rescheduleModal').style.display='none'"><%: T("Close","Tutup") %></button>
            <asp:Button ID="btnSaveReschedule" runat="server" CssClass="tc-live-session-btn-submit" OnClick="btnSaveReschedule_Click" CausesValidation="false" />
        </div>
    </div>
</div>

<%-- Cancel Confirmation Modal --%>
<div id="cancelModal" class="tc-live-session-modal-overlay" style="display:none;">
    <div class="tc-live-session-modal">
        <div class="tc-live-session-modal-header"><h3><%: T("Cancel Live Session?","Batalkan Sesi Langsung?") %></h3><button type="button" class="tc-live-session-modal-close" onclick="document.getElementById('cancelModal').style.display='none'">×</button></div>
        <div class="tc-live-session-modal-body" style="text-align:center;padding:1.5rem;">
            <p style="font-size:.88rem;color:var(--tt);margin:0 0 .5rem;"><%: T("Are you sure you want to cancel this live session?","Adakah anda pasti mahu membatalkan sesi langsung ini?") %></p>
            <div style="background:#FEF2F2;border-radius:10px;padding:.75rem 1rem;font-size:.82rem;color:#B91C1C;margin-top:.75rem;">
                <strong><asp:Literal ID="litCancelTitle" runat="server" /></strong><br/>
                <span style="font-size:.76rem;"><asp:Literal ID="litCancelTime" runat="server" /></span>
            </div>
            <asp:HiddenField ID="hidCancelId" runat="server" Value="" />
        </div>
        <div class="tc-live-session-modal-footer" style="justify-content:center;">
            <button type="button" class="tc-live-session-btn-cancel-modal" onclick="document.getElementById('cancelModal').style.display='none'"><%: T("Keep Session","Kekalkan Sesi") %></button>
            <asp:Button ID="btnConfirmCancel" runat="server" CssClass="tc-live-session-btn-submit" style="background:var(--te);" OnClick="btnConfirmCancel_Click" CausesValidation="false" />
        </div>
    </div>
</div>

<asp:HiddenField ID="hidShowRescModal" runat="server" Value="" />
<asp:HiddenField ID="hidShowCancelModal" runat="server" Value="" />

<%-- Schedule Modal --%>
<div id="scheduleModal" class="tc-live-session-modal-overlay" style="display:none;">
    <div class="tc-live-session-modal">
        <div class="tc-live-session-modal-header"><h3><%: T("Schedule Live Class","Jadualkan Kelas Langsung") %></h3><button type="button" class="tc-live-session-modal-close" onclick="document.getElementById('scheduleModal').style.display='none'">×</button></div>
        <div class="tc-live-session-modal-body">
            <div class="tc-live-session-field"><label class="tc-live-session-label"><%: T("Class Title","Tajuk Kelas") %> <span style="color:var(--te);">*</span></label><asp:TextBox ID="txtTitle" runat="server" CssClass="tc-live-session-input" MaxLength="200" /><div class="tc-live-session-field-error" id="errSchTitle">Please enter a class title.</div></div>
            <div class="tc-live-session-field"><label class="tc-live-session-label"><%: T("Date","Tarikh") %> <span style="color:var(--te);">*</span></label><asp:TextBox ID="txtDate" runat="server" CssClass="tc-live-session-input" TextMode="Date" /><div class="tc-live-session-field-error" id="errSchDate">Please select a date.</div></div>
            <div class="tc-live-session-row2">
                <div class="tc-live-session-field"><label class="tc-live-session-label"><%: T("Start Time","Masa Mula") %> <span style="color:var(--te);">*</span></label><asp:TextBox ID="txtStart" runat="server" CssClass="tc-live-session-input" TextMode="Time" /><div class="tc-live-session-field-error" id="errSchStart">Please select a start time.</div></div>
                <div class="tc-live-session-field"><label class="tc-live-session-label"><%: T("End Time","Masa Tamat") %> <span style="color:var(--te);">*</span></label><asp:TextBox ID="txtEnd" runat="server" CssClass="tc-live-session-input" TextMode="Time" /><div class="tc-live-session-field-error" id="errSchEnd">Please select an end time.</div></div>
            </div>
            <div class="tc-live-session-field-error" id="errSchDuration" style="margin-top:-0.5rem;margin-bottom:.75rem;"></div>
            <div class="tc-live-session-field"><label class="tc-live-session-label"><%: T("Unit","Unit") %> <span style="color:var(--te);">*</span></label><asp:DropDownList ID="ddlUnit" runat="server" CssClass="tc-live-session-input" /><div class="tc-live-session-field-error" id="errSchUnit">Please select a unit.</div></div>
            <div class="tc-live-session-field"><label class="tc-live-session-label"><%: T("Subtopic","Subtopik") %> <span style="color:var(--te);">*</span></label><asp:DropDownList ID="ddlSubtopic" runat="server" CssClass="tc-live-session-input" /><div class="tc-live-session-field-error" id="errSchSub">Please select a subtopic.</div></div>
            <div class="tc-live-session-field"><label class="tc-live-session-label"><%: T("Description","Penerangan") %></label><asp:TextBox ID="txtDesc" runat="server" CssClass="tc-live-session-input" TextMode="MultiLine" Rows="2" /></div>
            <asp:Panel ID="pnlError" runat="server" Visible="false"><div style="font-size:.78rem;color:var(--te);font-weight:600;margin-top:.25rem;"><asp:Literal ID="litError" runat="server" /></div></asp:Panel>
        </div>
        <div class="tc-live-session-modal-footer">
            <button type="button" class="tc-live-session-btn-cancel-modal" onclick="document.getElementById('scheduleModal').style.display='none'"><%: T("Cancel","Batal") %></button>
            <asp:Button ID="btnSchedule" runat="server" CssClass="tc-live-session-btn-submit" OnClick="btnSchedule_Click" CausesValidation="false" OnClientClick="return validateScheduleForm();" />
        </div>
    </div>
</div>

<asp:HiddenField ID="hidToast" runat="server" Value="" />
<asp:HiddenField ID="hidShowModal" runat="server" Value="" />
<asp:HiddenField ID="hidShowSummary" runat="server" Value="" />
<div class="tc-live-session-toast-wrap" id="lsToast"></div>

<%-- Live Session Summary Panel (bottom-right, shown after End Live) --%>
<asp:Panel ID="pnlSummary" runat="server">
<div class="tc-live-session-summary-overlay" id="lsSummaryOverlay" style="display:none;"></div>
<div class="tc-live-session-summary-panel" id="lsSummaryPanel" style="display:none;">
    <div class="tc-live-session-summary-hdr">
        <div class="tc-live-session-summary-ico"><i class="bi bi-check-lg"></i></div>
        <div class="tc-live-session-summary-hdr-text">
            <h3><%: T("Live Session Completed","Sesi Langsung Selesai") %></h3>
            <div class="tc-live-session-summary-hdr-sub"><asp:Literal ID="litSumTitle" runat="server" /></div>
        </div>
    </div>
    <div class="tc-live-session-summary-body">
        <div class="tc-live-session-sum-times">
            <div class="tc-live-session-sum-time"><%: T("Start","Mula") %><span><asp:Literal ID="litSumStart" runat="server" /></span></div>
            <div class="tc-live-session-sum-time"><%: T("End","Tamat") %><span><asp:Literal ID="litSumEnd" runat="server" /></span></div>
        </div>
        <div class="tc-live-session-sum-stats">
            <div class="tc-live-session-sum-stat">
                <div class="tc-live-session-sum-stat-ico" style="background:#EDE9FE;color:#7C3AED;"><i class="bi bi-clock-fill"></i></div>
                <div><div class="tc-live-session-sum-stat-val"><asp:Literal ID="litSumDuration" runat="server" /></div><div class="tc-live-session-sum-stat-lbl"><%: T("Duration","Tempoh") %></div></div>
            </div>
            <div class="tc-live-session-sum-stat">
                <div class="tc-live-session-sum-stat-ico" style="background:#D1FAE5;color:#059669;"><i class="bi bi-people-fill"></i></div>
                <div><div class="tc-live-session-sum-stat-val"><asp:Literal ID="litSumStudents" runat="server" /></div><div class="tc-live-session-sum-stat-lbl"><%: T("Students Joined","Pelajar Menyertai") %></div></div>
            </div>
        </div>
        <div class="tc-live-session-sum-parts">
            <div class="tc-live-session-sum-parts-title"><i class="bi bi-person-lines-fill" style="color:var(--tp);"></i> <%: T("Participants","Peserta") %></div>
            <asp:Panel ID="pnlSumPartsList" runat="server">
                <div class="tc-live-session-sum-parts-list">
                    <asp:Repeater ID="rptSumParticipants" runat="server">
                        <ItemTemplate>
                            <div class="tc-live-session-sum-part-item">
                                <div class="tc-live-session-sum-part-av"><%# Eval("initials") %></div>
                                <div class="tc-live-session-sum-part-name"><%# HttpUtility.HtmlEncode((string)Eval("name")) %></div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </asp:Panel>
            <asp:Panel ID="pnlSumNoParticipants" runat="server" Visible="false">
                <div class="tc-live-session-sum-no-parts"><%: T("No students attended this live session.","Tiada pelajar menghadiri sesi langsung ini.") %></div>
            </asp:Panel>
            <div class="tc-live-session-sum-no-parts" id="lsSumNoPartsJs" style="display:none;"><%: T("No students attended this live session.","Tiada pelajar menghadiri sesi langsung ini.") %></div>
        </div>
    </div>
    <div class="tc-live-session-summary-ftr">
        <button type="button" class="tc-live-session-sum-btn-done" onclick="closeLsSummary()"><%: T("Close","Tutup") %></button>
    </div>
</div>
</asp:Panel>

</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
function switchLsTab(tab){
    var up=document.getElementById('lsTabUpcoming');
    var hi=document.getElementById('lsTabHistory');
    var btnU=document.getElementById('btnTabUpcoming');
    var btnH=document.getElementById('btnTabHistory');
    if(tab==='history'){
        if(up)up.style.display='none';
        if(hi)hi.style.display='';
        if(btnU)btnU.className='tc-live-session-tab';
        if(btnH)btnH.className='tc-live-session-tab active';
    }else{
        if(up)up.style.display='';
        if(hi)hi.style.display='none';
        if(btnU)btnU.className='tc-live-session-tab active';
        if(btnH)btnH.className='tc-live-session-tab';
    }
}
window.addEventListener('load',function(){
    var h=document.getElementById('<%=hidToast.ClientID%>');
    if(h&&h.value){var w=document.getElementById('lsToast'),t=document.createElement('div');t.className='tc-live-session-toast';t.innerHTML='<i class="bi bi-check-circle-fill"></i> '+h.value;w.appendChild(t);h.value='';setTimeout(function(){t.style.opacity='0';t.style.transition='opacity .3s';},2500);setTimeout(function(){t.remove();},3e3);}
    var sm=document.getElementById('<%=hidShowModal.ClientID%>');
    if(sm&&sm.value==='1'){document.getElementById('scheduleModal').style.display='flex';sm.value='';}
    var rm=document.getElementById('<%=hidShowRescModal.ClientID%>');
    if(rm&&rm.value==='1'){document.getElementById('rescheduleModal').style.display='flex';rm.value='';}
    var cm=document.getElementById('<%=hidShowCancelModal.ClientID%>');
    if(cm&&cm.value==='1'){document.getElementById('cancelModal').style.display='flex';cm.value='';}
    var im=document.getElementById('<%=hidShowInstantModal.ClientID%>');
    if (im && im.value === '1') { document.getElementById('instantModal').style.display = 'flex'; im.value = ''; }

    // Show summary panel if redirected from End Live
    var ss=document.getElementById('<%=hidShowSummary.ClientID%>');
    if(ss&&ss.value==='1'){var sp=document.getElementById('lsSummaryPanel');var so=document.getElementById('lsSummaryOverlay');if(so)so.style.display='block';if(sp)sp.style.display='flex';ss.value='';}

    // Pending License: show notice + disable action cards
    var lic=document.getElementById('<%=hidLicenseStatus.ClientID%>');
    if(lic&&lic.value==='Pending'){
        var notice=document.getElementById('lsPendingNotice');if(notice)notice.style.display='flex';
        var cards=document.querySelectorAll('.tc-live-session-action-card');
        for(var i=0;i<cards.length;i++){cards[i].classList.add('tc-live-session-disabled');cards[i].removeAttribute('onclick');}
    }

    // Unit ? Subtopic dependency for Schedule modal
    var ddlUnitEl=document.getElementById('<%=ddlUnit.ClientID%>');
    var ddlSubEl=document.getElementById('<%=ddlSubtopic.ClientID%>');
    if(ddlUnitEl&&ddlSubEl){
        // Initially disable if no unit selected
        if(!ddlUnitEl.value){ddlSubEl.disabled=true;}
        ddlUnitEl.addEventListener('change',function(){
            var unitId=this.value;
            ddlSubEl.innerHTML='';
            if(!unitId){
                ddlSubEl.disabled=true;
                var opt=document.createElement('option');opt.value='';opt.textContent='-- Select Unit First --';ddlSubEl.appendChild(opt);
                return;
            }
            ddlSubEl.disabled=false;
            var loading=document.createElement('option');loading.value='';loading.textContent='Loading...';ddlSubEl.appendChild(loading);
            fetch(window.location.pathname+'?handler=subtopicsByUnit&unitId='+encodeURIComponent(unitId))
            .then(function(r){return r.json();})
            .then(function(data){
                ddlSubEl.innerHTML='';
                var def=document.createElement('option');def.value='';def.textContent='-- Select Subtopic --';ddlSubEl.appendChild(def);
                for(var i=0;i<data.length;i++){
                    var o=document.createElement('option');o.value=data[i].id;o.textContent=data[i].name;ddlSubEl.appendChild(o);
                }
            })
            .catch(function(){
                ddlSubEl.innerHTML='';
                var err=document.createElement('option');err.value='';err.textContent='Error loading';ddlSubEl.appendChild(err);
            });
        });
    }

    // Unit ? Subtopic dependency for Instant modal
    var ddlInstUnitEl=document.getElementById('<%=ddlInstantUnit.ClientID%>');
    var ddlInstSubEl=document.getElementById('<%=ddlInstantSubtopic.ClientID%>');
    if(ddlInstUnitEl&&ddlInstSubEl){
        if(!ddlInstUnitEl.value){ddlInstSubEl.disabled=true;}
        ddlInstUnitEl.addEventListener('change',function(){
            var unitId=this.value;
            ddlInstSubEl.innerHTML='';
            if(!unitId){
                ddlInstSubEl.disabled=true;
                var opt=document.createElement('option');opt.value='';opt.textContent='-- Select Unit First --';ddlInstSubEl.appendChild(opt);
                return;
            }
            ddlInstSubEl.disabled=false;
            var loading=document.createElement('option');loading.value='';loading.textContent='Loading...';ddlInstSubEl.appendChild(loading);
            fetch(window.location.pathname+'?handler=subtopicsByUnit&unitId='+encodeURIComponent(unitId))
            .then(function(r){return r.json();})
            .then(function(data){
                ddlInstSubEl.innerHTML='';
                var def=document.createElement('option');def.value='';def.textContent='-- Select Subtopic --';ddlInstSubEl.appendChild(def);
                for(var i=0;i<data.length;i++){
                    var o=document.createElement('option');o.value=data[i].id;o.textContent=data[i].name;ddlInstSubEl.appendChild(o);
                }
            })
            .catch(function(){
                ddlInstSubEl.innerHTML='';
                var err=document.createElement('option');err.value='';err.textContent='Error loading';ddlInstSubEl.appendChild(err);
            });
        });
    }

    // Enable dropdowns before form submit so values are posted
    var form=document.getElementById('MainForm');
    if(form){form.addEventListener('submit',function(){
        if(ddlSubEl)ddlSubEl.disabled=false;
        if(ddlInstSubEl)ddlInstSubEl.disabled=false;
    });}

});

/* -- Summary panel close -- */
function closeLsSummary(){
    var p=document.getElementById('lsSummaryPanel');
    var o=document.getElementById('lsSummaryOverlay');
    if(p){p.style.transition='opacity .25s ease,transform .25s ease';p.style.opacity='0';p.style.transform='translate(-50%,-48%) scale(.96)';setTimeout(function(){p.style.display='none';},260);}
    if(o){o.style.transition='opacity .25s ease';o.style.opacity='0';setTimeout(function(){o.style.display='none';},260);}
    if(window.history&&window.history.replaceState){
        var url=window.location.pathname;
        window.history.replaceState({},'',url);
    }
}

/* -- View Summary from History (AJAX) -- */
function viewSessionSummary(sessionId){
    fetch(window.location.pathname+'?handler=sessionSummary&id='+encodeURIComponent(sessionId))
    .then(function(r){return r.json();})
    .then(function(data){
        if(data.error)return;
        var titleEl=document.querySelector('#lsSummaryPanel .tc-live-session-summary-hdr-sub');
        var startEl=document.querySelector('#lsSummaryPanel .tc-live-session-sum-times .tc-live-session-sum-time:first-child span');
        var endEl=document.querySelector('#lsSummaryPanel .tc-live-session-sum-times .tc-live-session-sum-time:last-child span');
        var durEl=document.querySelectorAll('#lsSummaryPanel .tc-live-session-sum-stat-val')[0];
        var studEl=document.querySelectorAll('#lsSummaryPanel .tc-live-session-sum-stat-val')[1];
        if(titleEl)titleEl.textContent=data.title;
        if(startEl)startEl.textContent=data.startTime;
        if(endEl)endEl.textContent=data.endTime;
        if(durEl)durEl.textContent=data.duration;
        if(studEl)studEl.textContent=data.studentCount.toString();
        // Participants
        var listEl=document.querySelector('#lsSummaryPanel .tc-live-session-sum-parts-list');
        var noPartsEl=document.getElementById('lsSumNoPartsJs');
        if(listEl){
            if(data.participants.length>0){
                var html='';
                for(var i=0;i<data.participants.length;i++){
                    html+='<div class="tc-live-session-sum-part-item"><div class="tc-live-session-sum-part-av">'+data.participants[i].initials+'</div><div class="tc-live-session-sum-part-name">'+escHtml(data.participants[i].name)+'</div></div>';
                }
                listEl.innerHTML=html;
                listEl.parentElement.style.display='';
                if(noPartsEl)noPartsEl.style.display='none';
            }else{
                listEl.parentElement.style.display='none';
                if(noPartsEl)noPartsEl.style.display='';
            }
        }
        // Show modal
        var panel=document.getElementById('lsSummaryPanel');
        var overlay=document.getElementById('lsSummaryOverlay');
        if(overlay){overlay.style.display='block';overlay.style.opacity='1';}
        if(panel){panel.style.display='flex';panel.style.opacity='1';panel.style.transform='translate(-50%,-50%) scale(1)';}
    })
    .catch(function(){});
}
function escHtml(s){var d=document.createElement('div');d.textContent=s;return d.innerHTML;}

/* -- Client-side validation -- */
var __LS_MIN_DURATION=<%= MinSessionDuration %>;
var __LS_LANG='<%= CurrentLanguage %>';
function _lsT(en,bm){return __LS_LANG==='BM'?bm:en;}

function validateScheduleForm(){
    // Enable disabled dropdowns before validation so their values can be read
    var subEl=document.getElementById('<%=ddlSubtopic.ClientID%>');
    var fields=[
        {el:document.getElementById('<%=txtTitle.ClientID%>'),err:'errSchTitle'},
        {el:document.getElementById('<%=txtDate.ClientID%>'),err:'errSchDate'},
        {el:document.getElementById('<%=txtStart.ClientID%>'),err:'errSchStart'},
        {el:document.getElementById('<%=txtEnd.ClientID%>'),err:'errSchEnd'},
        {el:document.getElementById('<%=ddlUnit.ClientID%>'),err:'errSchUnit'},
        {el:subEl,err:'errSchSub'}
    ];
    var valid=true;
    for(var i=0;i<fields.length;i++){
        var f=fields[i],val=f.el?f.el.value.trim():'';
        var errEl=document.getElementById(f.err);
        if(!val){valid=false;if(errEl)errEl.classList.add('show');if(f.el)f.el.classList.add('invalid');}
        else{if(errEl)errEl.classList.remove('show');if(f.el)f.el.classList.remove('invalid');}
    }
    /* Duration validation (CONFIG014) */
    var durErr=document.getElementById('errSchDuration');
    if(durErr)durErr.classList.remove('show');
    if(valid){
        var dateVal=document.getElementById('<%=txtDate.ClientID%>').value;
        var startVal=document.getElementById('<%=txtStart.ClientID%>').value;
        var endVal=document.getElementById('<%=txtEnd.ClientID%>').value;
        if(dateVal&&startVal&&endVal){
            var startDt=new Date(dateVal+'T'+startVal);
            var endDt=new Date(dateVal+'T'+endVal);
            var diffMin=(endDt-startDt)/(1000*60);
            if(diffMin<__LS_MIN_DURATION){
                valid=false;
                if(durErr){
                    durErr.textContent=_lsT(
                        'The live session duration must be at least '+__LS_MIN_DURATION+' minutes.',
                        'Tempoh sesi langsung mestilah sekurang-kurangnya '+__LS_MIN_DURATION+' minit.');
                    durErr.classList.add('show');
                }
            }
        }
    }
    var gen=document.getElementById('errSchGeneral');
    if(gen)gen.style.display='none';
    // Enable subtopic dropdown before submit so its value is POSTed
    if(valid&&subEl)subEl.disabled=false;
    return valid;
}
function validateInstantForm(){
    var instSubEl=document.getElementById('<%=ddlInstantSubtopic.ClientID%>');
    var fields=[
        {el:document.getElementById('<%=txtInstantTitle.ClientID%>'),err:'errInstTitle'},
        {el:document.getElementById('<%=ddlInstantUnit.ClientID%>'),err:'errInstUnit'},
        {el:instSubEl,err:'errInstSub'}
    ];
    var valid=true;
    for(var i=0;i<fields.length;i++){
        var f=fields[i],val=f.el?f.el.value.trim():'';
        var errEl=document.getElementById(f.err);
        if(!val){valid=false;if(errEl)errEl.classList.add('show');if(f.el)f.el.classList.add('invalid');}
        else{if(errEl)errEl.classList.remove('show');if(f.el)f.el.classList.remove('invalid');}
    }
    var gen=document.getElementById('errInstGeneral');
    if(gen)gen.style.display='none';
    // Enable subtopic dropdown before submit so its value is POSTed
    if(valid&&instSubEl)instSubEl.disabled=false;
    return valid;
}
/* Auto-clear errors on input */
document.addEventListener('input',function(e){
    var el=e.target;if(!el.classList.contains('invalid'))return;
    if(el.value.trim()){el.classList.remove('invalid');var p=el.parentElement;var err=p?p.querySelector('.tc-live-session-field-error'):null;if(err)err.classList.remove('show');}
});
document.addEventListener('change',function(e){
    var el=e.target;
    if(el.classList.contains('invalid')&&el.value.trim()){el.classList.remove('invalid');var p=el.parentElement;var err=p?p.querySelector('.tc-live-session-field-error'):null;if(err)err.classList.remove('show');}
    /* Auto-clear duration error when start/end time changes */
    var startEl=document.getElementById('<%=txtStart.ClientID%>');
    var endEl=document.getElementById('<%=txtEnd.ClientID%>');
    var dateEl=document.getElementById('<%=txtDate.ClientID%>');
    if(el===startEl||el===endEl||el===dateEl){
        var durErr=document.getElementById('errSchDuration');
        if(durErr&&startEl&&endEl&&dateEl&&startEl.value&&endEl.value&&dateEl.value){
            var s=new Date(dateEl.value+'T'+startEl.value);
            var en=new Date(dateEl.value+'T'+endEl.value);
            var diff=(en-s)/(1000*60);
            if(diff>=__LS_MIN_DURATION)durErr.classList.remove('show');
        }
    }
});

</script>
</asp:Content>
