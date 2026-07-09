<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Quiz.aspx.cs" Inherits="ScienceBuddy.Student.Quiz" ValidateRequest="false" EnableEventValidation="false" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%: ResolveUrl("~/Content/Student.css") %>" rel="stylesheet" />
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Main</div>
        <a href="<%: ResolveUrl("~/Student/Dashboard.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-speedometer2 item-icon"></i><span class="item-label">Dashboard</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/Notifications.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Learn</div>
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-book item-icon"></i><span class="item-label">My Learning</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/PracticeLibrary.aspx") %>" class="sb-sidebar-item active">
            <i class="bi bi-patch-question item-icon"></i><span class="item-label">Practice Library</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/QuizHistory.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-clock-history item-icon"></i><span class="item-label">Quiz History</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/VirtualLabs.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-eyedropper item-icon"></i><span class="item-label">Virtual Labs</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/LiveSessions.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-camera-video item-icon"></i><span class="item-label">Live Sessions</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/AIStudyCompanion.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-robot item-icon"></i><span class="item-label">AI Study Companion</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Communication</div>
        <a href="<%: ResolveUrl("~/Student/Messages.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-chat-dots item-icon"></i><span class="item-label">Messages</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/Forum.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-people item-icon"></i><span class="item-label">Forum</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Progress</div>
        <a href="<%: ResolveUrl("~/Student/ProgressRewards.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-bar-chart-line item-icon"></i><span class="item-label">Progress &amp; Rewards</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/MyRanking.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-trophy item-icon"></i><span class="item-label">My Ranking</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/RevisionPlan.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-calendar-check item-icon"></i><span class="item-label">Revision Plan</span>
        </a>
    </div>
    <div class="sb-nav-section">
        <div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Student/MyProfile.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span>
        </a>
    </div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><asp:Literal ID="litPageTitle" runat="server" Text="Quiz" /></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- ERROR --%>
<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="st-quiz-error">
        <div class="st-quiz-error-icon"><i class="bi bi-exclamation-triangle-fill" style="color:var(--student);"></i></div>
        <div style="font-family:var(--font-primary);font-size:1.25rem;font-weight:700;margin-bottom:8px;"><asp:Literal ID="litErrorTitle" runat="server" /></div>
        <div style="color:var(--color-text-secondary);"><asp:Literal ID="litErrorDesc" runat="server" /></div>
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="st-quiz-error-btn"><i class="bi bi-arrow-left"></i> <asp:Literal ID="litErrorBtn" runat="server" Text="Back" /></a>
    </div>
</asp:Panel>

<%-- QUIZ --%>
<asp:Panel ID="pnlQuiz" runat="server" Visible="false">
    <div class="st-quiz-hero"><div class="st-quiz-hero-blob"></div>
        <div class="st-quiz-hero-title"><asp:Literal ID="litQuizTitle" runat="server" /></div>
        <div class="st-quiz-hero-sub"><asp:Literal ID="litQuizSub" runat="server" /></div>
        <div class="st-quiz-hero-meta">
            <span class="st-quiz-hero-chip"><i class="bi bi-list-check"></i> <asp:Literal ID="litQCount" runat="server" /></span>
            <span class="st-quiz-hero-chip"><i class="bi bi-bookmark-fill"></i> <asp:Literal ID="litQType" runat="server" /></span>
        </div>
    </div>

    <div class="st-quiz-progress-bar">
        <span class="st-quiz-progress-label"><i class="bi bi-bar-chart-steps"></i> <asp:Literal ID="litProgressLabel" runat="server" Text="Progress" /></span>
        <div class="st-quiz-progress-track"><div class="st-quiz-progress-fill" id="progressFill" runat="server" style="width:0%"></div></div>
        <span class="st-quiz-progress-count"><asp:Literal ID="litProgressCount" runat="server" Text="0/0" /></span>
    </div>

    <%-- Validation Message --%>
    <asp:Panel ID="pnlValMsg" runat="server" Visible="false">
        <div class="st-quiz-val-msg"><i class="bi bi-exclamation-circle-fill"></i> <asp:Literal ID="litValMsg" runat="server" /></div>
    </asp:Panel>

    <%-- Question Card --%>
    <div class="st-quiz-card">
        <div class="st-quiz-q-num"><i class="bi bi-patch-question-fill"></i> <asp:Literal ID="litQNum" runat="server" /></div>
        <asp:Panel ID="pnlQDiff" runat="server" Visible="false">
            <div class="st-quiz-q-diff" id="divDiff" runat="server"><asp:Literal ID="litQDiff" runat="server" /></div>
        </asp:Panel>
        <div class="st-quiz-q-text"><asp:Literal ID="litQText" runat="server" /></div>
        <asp:Image ID="imgQuestion" runat="server" CssClass="st-quiz-q-img" Visible="false" />

        <%-- MCQ --%>
        <asp:Panel ID="pnlMCQ" runat="server" Visible="false">
            <asp:RadioButtonList ID="rblMCQ" runat="server" CssClass="st-quiz-rbl" RepeatLayout="Flow" />
        </asp:Panel>

        <%-- True/False --%>
        <asp:Panel ID="pnlTF" runat="server" Visible="false">
            <asp:RadioButtonList ID="rblTF" runat="server" RepeatLayout="Flow" CssClass="st-quiz-tf-wrap" />
        </asp:Panel>

        <%-- Multiselect --%>
        <asp:Panel ID="pnlMulti" runat="server" Visible="false">
            <div class="st-quiz-hint"><i class="bi bi-info-circle"></i> <asp:Literal ID="litMultiHint" runat="server" /></div>
            <asp:CheckBoxList ID="cblMulti" runat="server" CssClass="st-quiz-cbl" RepeatLayout="Flow" />
        </asp:Panel>

        <%-- DragDrop / Fill-in --%>
        <asp:Panel ID="pnlDrag" runat="server" Visible="false">
            <div class="st-quiz-hint"><i class="bi bi-info-circle"></i> <asp:Literal ID="litDragHint" runat="server" /></div>

            <div class="st-quiz-dd-dropzone" id="ddDropZone"
                 ondragover="event.preventDefault();this.classList.add('dragover');"
                 ondragleave="this.classList.remove('dragover');"
                 ondrop="ddHandleDrop(event);">
                <span class="st-quiz-dd-placeholder" id="ddPlaceholder"><asp:Literal ID="litDDPlaceholder" runat="server" Text="Drag answers here or click them" /></span>
            </div>

            <div class="st-quiz-dd-chips" id="ddChipContainer">
                <asp:Literal ID="litDDChips" runat="server" />
            </div>

            <button type="button" class="st-quiz-dd-reset" onclick="ddReset();"><i class="bi bi-arrow-counterclockwise"></i> <asp:Literal ID="litDDResetBtn" runat="server" Text="Reset" /></button>

            <asp:HiddenField ID="hdnDDAnswer" runat="server" />
        </asp:Panel>
    </div>

    <%-- Navigation --%>
    <div class="st-quiz-nav">
        <asp:Button ID="btnPrev" runat="server" CssClass="st-quiz-nav-btn st-quiz-nav-prev" OnClick="btnPrev_Click" Text="Previous" CausesValidation="false" />
        <asp:Button ID="btnNext" runat="server" CssClass="st-quiz-nav-btn st-quiz-nav-next" OnClick="btnNext_Click" Text="Next" CausesValidation="false" />
        <asp:Button ID="btnSubmit" runat="server" CssClass="st-quiz-nav-btn st-quiz-nav-submit" OnClick="btnSubmit_Click" Text="Submit Quiz" Visible="false" CausesValidation="false" />
    </div>
</asp:Panel>
</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
var ddMaxBlanks = 1;
var ddAnswers = [];
var ddHiddenId = '';

function ddInit(maxBlanks, hiddenFieldId, existingAnswer) {
    ddMaxBlanks = maxBlanks || 1;
    ddHiddenId = hiddenFieldId;
    ddAnswers = [];
    if (existingAnswer && existingAnswer.trim().length > 0) {
        ddAnswers = existingAnswer.split(',').map(function(s){return s.trim();}).filter(function(s){return s.length>0;});
    }
    ddRender();
}

function ddHandleDrop(e) {
    e.preventDefault();
    var zone = document.getElementById('ddDropZone');
    zone.classList.remove('dragover');
    var val = e.dataTransfer.getData('text/plain');
    if (val && ddAnswers.length < ddMaxBlanks) {
        ddAnswers.push(val);
        ddRender();
    }
}

function ddChipClick(val) {
    if (ddAnswers.length < ddMaxBlanks) {
        ddAnswers.push(val);
        ddRender();
    }
}

function ddRemoveAnswer(idx) {
    ddAnswers.splice(idx, 1);
    ddRender();
}

function ddReset() {
    ddAnswers = [];
    ddRender();
}

function ddRender() {
    var hdn = document.getElementById(ddHiddenId);
    if (hdn) hdn.value = ddAnswers.join(',');

    var zone = document.getElementById('ddDropZone');
    if (!zone) return;
    if (ddAnswers.length === 0) {
        var ph = document.getElementById('ddPlaceholder');
        zone.innerHTML = '<span class="st-quiz-dd-placeholder" id="ddPlaceholder">' + (ph ? ph.textContent : 'Drop here') + '</span>';
    } else {
        var html = '';
        for (var i = 0; i < ddAnswers.length; i++) {
            html += '<span class="st-quiz-dd-answer-chip" onclick="ddRemoveAnswer('+i+')" title="Click to remove">' +
                    ddAnswers[i] + ' <i class="bi bi-x-circle-fill" style="font-size:.75rem;opacity:.7;"></i></span>';
        }
        zone.innerHTML = html;
    }

    var chips = document.querySelectorAll('#ddChipContainer .st-quiz-dd-chip');
    chips.forEach(function(chip) {
        var val = chip.getAttribute('data-value');
        if (ddMaxBlanks === 1 && ddAnswers.indexOf(val) > -1) {
            chip.classList.add('used');
        } else if (ddMaxBlanks > 1) {
            var count = ddAnswers.filter(function(a){return a===val;}).length;
            if (count > 0) chip.classList.add('used'); else chip.classList.remove('used');
        } else {
            chip.classList.remove('used');
        }
    });
}

function ddStartDrag(e, val) {
    e.dataTransfer.setData('text/plain', val);
    e.dataTransfer.effectAllowed = 'move';
    e.target.style.opacity = '0.5';
}
function ddEndDrag(e) { e.target.style.opacity = '1'; }

// --- True/False selection highlight ---
document.addEventListener('click', function(e) {
    var label = e.target.closest('.st-quiz-tf-wrap label');
    if (!label) return;
    var wrap = label.closest('.st-quiz-tf-wrap');
    if (!wrap) return;
    wrap.querySelectorAll('label').forEach(function(l){ l.classList.remove('tf-selected'); });
    label.classList.add('tf-selected');
});
// On page load, highlight any already-checked TF option
(function(){
    var tfWraps = document.querySelectorAll('.st-quiz-tf-wrap');
    tfWraps.forEach(function(wrap){
        var checked = wrap.querySelector('input[type="radio"]:checked');
        if (checked) {
            var lbl = checked.closest('label') || checked.parentElement.querySelector('label');
            if (lbl) lbl.classList.add('tf-selected');
        }
    });
})();
</script>
</asp:Content>
