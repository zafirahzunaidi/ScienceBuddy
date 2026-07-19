<%@ Page Title="Student Details" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="studentDetails.aspx.cs" Inherits="ScienceBuddy.Teacher.studentDetails" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Teacher.css") %>" rel="stylesheet" />
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div><a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a><a href="<%: ResolveUrl("~/Teacher/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label"><%: T("Notifications","Notifikasi") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Teaching","Pengajaran") %></div><a href="<%: ResolveUrl("~/Teacher/manageMaterials.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label"><%: T("Manage Materials","Bahan Pembelajaran") %></span></a><a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label"><%: T("Manage Quiz","Kuiz") %></span></a><a href="<%: ResolveUrl("~/Teacher/studentProgress.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-bar-chart item-icon"></i><span class="item-label"><%: T("Student Progress","Prestasi Pelajar") %></span></a><a href="<%: ResolveUrl("~/Teacher/liveSession.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label"><%: T("Schedule Live Class","Kelas Langsung") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Community","Komuniti") %></div><a href="<%: ResolveUrl("~/Teacher/Forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a><a href="<%: ResolveUrl("~/Teacher/privateMessages.aspx") %>" class="sb-sidebar-item"><i class="bi bi-envelope item-icon"></i><span class="item-label"><%: T("Private Message","Mesej Peribadi") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Account","Akaun") %></div><a href="<%: ResolveUrl("~/Teacher/MyProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("My Profile","Profil Saya") %></span></a><a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Sign Out","Log Keluar") %></span></a></div>
</asp:Content>
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Student Details","Butiran Pelajar") %></asp:Content>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">
<a href="<%: ResolveUrl("~/Teacher/studentProgress.aspx") %>" class="tc-student-details-back"><i class="bi bi-arrow-left"></i> <%: T("Back to Student Progress","Kembali ke Prestasi Pelajar") %></a>
<asp:Panel ID="pnlError" runat="server" Visible="false"><div class="tc-student-details-err"><i class="bi bi-exclamation-triangle-fill"></i><div class="tc-student-details-err-t"><%: T("Error","Ralat") %></div><div class="tc-student-details-err-s"><asp:Literal ID="litErrMsg" runat="server" /></div><a href="<%: ResolveUrl("~/Teacher/studentProgress.aspx") %>" class="tc-student-details-err-link"><i class="bi bi-arrow-left"></i> <%: T("Back","Kembali") %></a></div></asp:Panel>
<asp:Panel ID="pnlMain" runat="server" Visible="false">

<div class="tc-student-details-profile"><div class="tc-student-details-avatar"><asp:Literal ID="litInitials" runat="server" /></div><div class="tc-student-details-pinfo"><h2><asp:Literal ID="litName" runat="server" /></h2><p>ID: <asp:Literal ID="litStudentId" runat="server" /> � <%: T("Detailed learning analytics","Analitik pembelajaran terperinci") %></p><div class="tc-student-details-pills"><span class="tc-student-details-pill"><i class="bi bi-mortarboard"></i> <asp:Literal ID="litLevel" runat="server" /></span></div></div></div>

<%-- 3 Donut Cards (percentage only inside) --%>
<div class="tc-student-details-donuts">
    <div class="tc-student-details-dc accent-blue"><div class="tc-student-details-donut" style="background:conic-gradient(#3B82F6 0% <%=LessonPct%>%, #E2E8F0 <%=LessonPct%>% 100%);"><div class="tc-student-details-donut-inner"><span class="tc-student-details-donut-val"><%=LessonPct%>%</span></div></div><div class="tc-student-details-dc-label"><%: T("Lesson Completion","Penyelesaian Pelajaran") %></div><div class="tc-student-details-dc-meta"><asp:Literal ID="litLessons" runat="server" /></div></div>
    <div class="tc-student-details-dc accent-green"><div class="tc-student-details-donut" style="background:conic-gradient(#10B981 0% <%=UnitPct%>%, #E2E8F0 <%=UnitPct%>% 100%);"><div class="tc-student-details-donut-inner"><span class="tc-student-details-donut-val"><%=UnitPct%>%</span></div></div><div class="tc-student-details-dc-label"><%: T("Unit Quiz Average","Purata Kuiz Unit") %></div><div class="tc-student-details-dc-meta"><asp:Literal ID="litUnitAvg" runat="server" /></div></div>
    <div class="tc-student-details-dc accent-orange"><div class="tc-student-details-donut" style="background:conic-gradient(#F59E0B 0% <%=LevelPct%>%, #E2E8F0 <%=LevelPct%>% 100%);"><div class="tc-student-details-donut-inner"><span class="tc-student-details-donut-val"><%=LevelPct%>%</span></div></div><div class="tc-student-details-dc-label"><%: T("Level Quiz Average","Purata Kuiz Tahap") %></div><div class="tc-student-details-dc-meta"><asp:Literal ID="litLevelAvg" runat="server" /></div></div>
</div>

<%-- Lesson Progress --%>
<div class="tc-student-details-section"><div class="tc-student-details-sec-hd"><h3><i class="bi bi-book-half" style="color:var(--blue);"></i> <%: T("Lesson Progress","Kemajuan Pelajaran") %></h3></div>
<asp:Panel ID="pnlLessonTable" runat="server" Visible="false">
<table class="tc-student-details-tbl"><thead><tr><th><%: T("Lesson","Pelajaran") %></th><th><%: T("Status","Status") %></th><th><%: T("Date","Tarikh") %></th></tr></thead><tbody>
<asp:Repeater ID="rptLessons" runat="server"><ItemTemplate><tr><td><%# HttpUtility.HtmlEncode(Eval("lesson").ToString()) %></td><td><span class='tc-student-details-badge <%# Eval("statusCss") %>'><%# Eval("status") %></span></td><td style="color:var(--m);"><%# Eval("date") %></td></tr></ItemTemplate></asp:Repeater></tbody></table>
</asp:Panel>
<asp:Panel ID="pnlLessonEmpty" runat="server" Visible="false">
<div class="tc-student-details-quiz-empty"><i class="bi bi-book"></i><div class="tc-student-details-quiz-empty-msg"><%: T("No lesson progress yet.","Belum ada kemajuan pelajaran.") %></div></div>
</asp:Panel>
</div>

<%-- Quiz Results --%>
<div class="tc-student-details-section"><div class="tc-student-details-sec-hd"><h3><i class="bi bi-trophy-fill" style="color:var(--green);"></i> <%: T("Unit Quiz Results","Keputusan Kuiz Unit") %></h3></div>
<asp:Panel ID="pnlUnitQuizTable" runat="server" Visible="false">
<table class="tc-student-details-tbl"><thead><tr><th><%: T("Quiz","Kuiz") %></th><th><%: T("Score","Markah") %></th><th><%: T("Correct","Betul") %></th><th><%: T("Wrong","Salah") %></th><th><%: T("Percentage","Peratus") %></th><th><%: T("Result","Keputusan") %></th><th><%: T("No. of Attempt","Bil. Cubaan") %></th><th><%: T("Date","Tarikh") %></th><th><%: T("Action","Tindakan") %></th></tr></thead><tbody>
<asp:Repeater ID="rptUnitQuiz" runat="server"><ItemTemplate><tr><td><%# HttpUtility.HtmlEncode(Eval("quizName").ToString()) %></td><td><%# Eval("score") %></td><td style="color:var(--green);font-weight:700;"><%# Eval("correctCount") %></td><td style="color:var(--red);font-weight:700;"><%# Eval("wrongCount") %></td><td><strong><%# Eval("pct") %></strong></td><td><span class='tc-student-details-badge <%# Eval("resCss") %>'><%# Eval("result") %></span></td><td><%# Eval("attempts") %></td><td style="color:var(--m);"><%# Eval("date") %></td><td><button type="button" class="tc-student-details-view-btn" onclick='openAnswerModal("<%# Eval("resultId") %>")'><%# T("View","Lihat") %></button></td></tr></ItemTemplate></asp:Repeater></tbody></table>
</asp:Panel>
<asp:Panel ID="pnlUnitQuizEmpty" runat="server" Visible="false">
<div class="tc-student-details-quiz-empty"><i class="bi bi-clipboard2-x"></i><div class="tc-student-details-quiz-empty-msg"><%: T("No quiz attempts yet.","Belum ada cubaan kuiz.") %></div></div>
</asp:Panel>
</div>

<div class="tc-student-details-section"><div class="tc-student-details-sec-hd"><h3><i class="bi bi-award-fill" style="color:var(--orange);"></i> <%: T("Level Quiz Results","Keputusan Kuiz Tahap") %></h3></div>
<asp:Panel ID="pnlLevelQuizTable" runat="server" Visible="false">
<table class="tc-student-details-tbl"><thead><tr><th><%: T("Quiz","Kuiz") %></th><th><%: T("Score","Markah") %></th><th><%: T("Correct","Betul") %></th><th><%: T("Wrong","Salah") %></th><th><%: T("Percentage","Peratus") %></th><th><%: T("Result","Keputusan") %></th><th><%: T("No. of Attempt","Bil. Cubaan") %></th><th><%: T("Date","Tarikh") %></th><th><%: T("Action","Tindakan") %></th></tr></thead><tbody>
<asp:Repeater ID="rptLevelQuiz" runat="server"><ItemTemplate><tr><td><%# HttpUtility.HtmlEncode(Eval("quizName").ToString()) %></td><td><%# Eval("score") %></td><td style="color:var(--green);font-weight:700;"><%# Eval("correctCount") %></td><td style="color:var(--red);font-weight:700;"><%# Eval("wrongCount") %></td><td><strong><%# Eval("pct") %></strong></td><td><span class='tc-student-details-badge <%# Eval("resCss") %>'><%# Eval("result") %></span></td><td><%# Eval("attempts") %></td><td style="color:var(--m);"><%# Eval("date") %></td><td><button type="button" class="tc-student-details-view-btn" onclick='openAnswerModal("<%# Eval("resultId") %>")'><%# T("View","Lihat") %></button></td></tr></ItemTemplate></asp:Repeater></tbody></table>
</asp:Panel>
<asp:Panel ID="pnlLevelQuizEmpty" runat="server" Visible="false">
<div class="tc-student-details-quiz-empty"><i class="bi bi-clipboard2-x"></i><div class="tc-student-details-quiz-empty-msg"><%: T("No quiz attempts yet.","Belum ada cubaan kuiz.") %></div></div>
</asp:Panel>
</div>

<%-- Answer Detail Modal --%>
<div id="answerModal" class="tc-student-details-modal-overlay" style="display:none;" onclick="if(event.target===this)closeAnswerModal();">
<div class="tc-student-details-modal">
<div class="tc-student-details-modal-hd"><h3><i class="bi bi-eye-fill"></i> <%: T("Quiz Answers","Jawapan Kuiz") %></h3><button type="button" class="tc-student-details-modal-close" onclick="closeAnswerModal();">&times;</button></div>
<div class="tc-student-details-modal-body" id="answerModalBody"><div class="tc-student-details-empty"><%: T("Loading...","Memuatkan...") %></div></div>
</div>
</div>

<%-- Weak Topics + Teacher Insight side by side --%>
<div class="tc-student-details-weak-insight-row">
<div class="tc-student-details-weak-col">
<div class="tc-student-details-section"><div class="tc-student-details-sec-hd"><h3><i class="bi bi-exclamation-triangle-fill" style="color:var(--red);"></i> <%: T("Weak Topics","Topik Lemah") %></h3></div>
<asp:Panel ID="pnlWeakNoAttempts" runat="server" Visible="false"><div class="tc-student-details-empty" style="padding:2rem;"><div style="font-size:2rem;margin-bottom:.5rem;">??</div><div style="font-size:1rem;font-weight:800;color:var(--t);margin-bottom:.3rem;"><%: T("No Quiz Attempts Yet","Belum Ada Cubaan Kuiz") %></div><div style="font-size:.86rem;color:var(--m);"><%: T("This student has not attempted any Unit or Level quizzes.","Pelajar ini belum mencuba sebarang Kuiz Unit atau Kuiz Level.") %></div></div></asp:Panel>
<asp:Panel ID="pnlWeakEmpty" runat="server" Visible="false"><div class="tc-student-details-empty" style="padding:2rem;"><div style="font-size:2rem;margin-bottom:.5rem;">??</div><div style="font-size:1rem;font-weight:800;color:var(--t);margin-bottom:.3rem;"><%: T("No Weak Topics","Tiada Topik Lemah") %></div><div style="font-size:.86rem;color:var(--m);"><%: T("The student has passed all attempted Unit and Level quizzes.","Pelajar telah lulus semua Kuiz Unit dan Kuiz Level yang telah dicuba.") %></div></div></asp:Panel>
<div class="tc-student-details-wk-grid">
<asp:Repeater ID="rptWeak" runat="server"><ItemTemplate>
<div class="tc-student-details-wk-card">
    <div class="tc-student-details-wk-row"><span class="tc-student-details-wk-lbl"><%: T("Quiz","Kuiz") %></span><span class="tc-student-details-wk-val tc-student-details-wk-val-title"><%# HttpUtility.HtmlEncode(Eval("quizName").ToString()) %></span></div>
    <div class="tc-student-details-wk-row"><span class="tc-student-details-wk-lbl"><%# Eval("quizType").ToString() == "Unit" ? T("Unit","Unit") : T("Level","Tahap") %></span><span class="tc-student-details-wk-val"><%# HttpUtility.HtmlEncode(Eval("scopeName").ToString()) %></span></div>
    <div class="tc-student-details-wk-scores">
        <div class="tc-student-details-wk-score-item"><span class="tc-student-details-wk-lbl"><%: T("Latest Score","Markah Terkini") %></span><span class="tc-student-details-wk-score-val tc-student-details-wk-val-red"><%# Eval("latestPct") %></span></div>
        <div class="tc-student-details-wk-score-item"><span class="tc-student-details-wk-lbl"><%: T("Passing Mark","Markah Lulus") %></span><span class="tc-student-details-wk-score-val"><%# Eval("passMarkStr") %></span></div>
    </div>
    <div class="tc-student-details-wk-row"><span class="tc-student-details-wk-lbl"><%: T("Status","Status") %></span><span class="tc-student-details-wk-status"><%# Eval("statusLabel") %></span></div>
</div>
</ItemTemplate></asp:Repeater>
</div></div>
</div>
<div class="tc-student-details-insight-col">
<div class="tc-student-details-insight">
    <h4><i class="bi bi-lightbulb-fill"></i> <%: T("Performance Summary","Ringkasan Prestasi") %></h4>
    <div class="tc-student-details-ins-items">
        <div class="tc-student-details-ins-item"><span class="tc-student-details-ins-lbl"><%: T("Completed Lessons","Pelajaran Selesai") %></span><span class="tc-student-details-ins-val"><asp:Literal ID="litInsLessons" runat="server" /></span></div>
        <div class="tc-student-details-ins-item"><span class="tc-student-details-ins-lbl"><%: T("Weak Unit Topics","Topik Unit Lemah") %></span><span class="tc-student-details-ins-val tc-student-details-ins-val-red"><asp:Literal ID="litInsWeakUnit" runat="server" Text="0" /></span></div>
        <div class="tc-student-details-ins-item"><span class="tc-student-details-ins-lbl"><%: T("Weak Level Topics","Topik Tahap Lemah") %></span><span class="tc-student-details-ins-val tc-student-details-ins-val-red"><asp:Literal ID="litInsWeakLevel" runat="server" Text="0" /></span></div>
        <div class="tc-student-details-ins-item"><span class="tc-student-details-ins-lbl"><%: T("Certificates Earned","Sijil Diperolehi") %></span><span class="tc-student-details-ins-val"><asp:Literal ID="litInsCerts" runat="server" Text="0" /></span></div>
    </div>
    <div class="tc-student-details-ins-rec">
        <span class="tc-student-details-ins-rec-lbl"><i class="bi bi-chat-quote"></i> <%: T("Recommendation","Cadangan") %></span>
        <p class="tc-student-details-ins-rec-text"><asp:Literal ID="litInsight" runat="server" /></p>
    </div>
</div>
</div>
</div>

<%-- Certificates --%>
<div class="tc-student-details-section"><div class="tc-student-details-sec-hd"><h3><i class="bi bi-patch-check-fill" style="color:var(--orange);"></i> <%: T("Certificates Earned","Sijil Diperolehi") %></h3></div>
<asp:Panel ID="pnlCertEmpty" runat="server" Visible="false"><div class="tc-student-details-empty"><%: T("This student has not earned any certificate yet.","Pelajar ini belum memperolehi sebarang sijil.") %></div></asp:Panel>
<div class="tc-student-details-cert-list">
<asp:Repeater ID="rptCerts" runat="server"><ItemTemplate>
<div class="tc-student-details-cert">
    <div class="tc-student-details-cert-icon"><i class="bi bi-award"></i></div>
    <div class="tc-student-details-cert-body">
        <div class="tc-student-details-cert-title"><%# HttpUtility.HtmlEncode(Eval("title").ToString()) %></div>
        <div class="tc-student-details-cert-desc"><%# HttpUtility.HtmlEncode(Eval("description").ToString()) %></div>
        <div class="tc-student-details-cert-meta">
            <span><i class="bi bi-mortarboard"></i> <%# HttpUtility.HtmlEncode(Eval("level").ToString()) %></span>
            <span><i class="bi bi-calendar3"></i> <%# Eval("date") %></span>
            <span class='tc-student-details-cbadge <%# Eval("statusCss") %>'><%# Eval("status") %></span>
        </div>
    </div>
</div>
</ItemTemplate></asp:Repeater>
</div></div>

</asp:Panel>
</asp:Content>
<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
function openAnswerModal(resultId){
    var modal=document.getElementById('answerModal');
    var body=document.getElementById('answerModalBody');
    body.innerHTML='<div class="tc-student-details-empty"><%: T("Loading...","Memuatkan...") %></div>';
    modal.style.display='flex';
    var xhr=new XMLHttpRequest();
    xhr.open('GET','studentDetails.aspx?handler=answers&resultId='+encodeURIComponent(resultId),true);
    xhr.onreadystatechange=function(){
        if(xhr.readyState===4){
            if(xhr.status===200){body.innerHTML=xhr.responseText;}
            else{body.innerHTML='<div class="tc-student-details-empty"><%: T("Error loading answers.","Ralat memuatkan jawapan.") %></div>';}
        }
    };
    xhr.send();
}
function closeAnswerModal(){document.getElementById('answerModal').style.display='none';}
document.addEventListener('keydown',function(e){if(e.key==='Escape')closeAnswerModal();});
</script>
</asp:Content>
