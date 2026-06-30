<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Quiz.aspx.cs"
    Inherits="ScienceBuddy.Student.QuizPage" MasterPageFile="~/Site.Master"
    Title="Quiz" ValidateRequest="false" EnableEventValidation="false" %>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--qz-primary:#FF6B2C;--qz-primary-light:#FFF0E8;--qz-primary-dark:#E85B1D;
     --qz-blue:#2563EB;--qz-green:#22C55E;--qz-gold:#FFD84D;}

.qz-hero{background:linear-gradient(135deg,var(--qz-primary) 0%,#FF8C54 50%,var(--qz-gold) 100%);
    border-radius:var(--border-radius-xl);padding:var(--space-xl) var(--space-2xl);color:#fff;
    position:relative;overflow:hidden;margin-bottom:var(--space-xl);box-shadow:0 12px 40px rgba(255,107,44,.25);}
.qz-hero-blob{position:absolute;width:200px;height:200px;border-radius:50%;
    background:rgba(255,255,255,.08);top:-60px;right:-40px;pointer-events:none;}
.qz-hero-title{font-family:var(--font-primary);font-size:1.5rem;font-weight:800;margin-bottom:4px;position:relative;z-index:1;}
.qz-hero-sub{font-size:.9rem;opacity:.88;position:relative;z-index:1;line-height:1.5;}
.qz-hero-meta{display:flex;gap:var(--space-md);margin-top:var(--space-md);flex-wrap:wrap;position:relative;z-index:1;}
.qz-hero-chip{background:rgba(255,255,255,.2);border:1px solid rgba(255,255,255,.3);
    border-radius:var(--border-radius-full);padding:4px 12px;font-size:.75rem;font-weight:700;
    display:inline-flex;align-items:center;gap:4px;}

.qz-progress-bar{background:var(--color-white);border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);
    padding:var(--space-md) var(--space-xl);margin-bottom:var(--space-xl);
    display:flex;align-items:center;gap:var(--space-md);}
.qz-progress-label{font-size:.8125rem;font-weight:700;color:var(--color-text);white-space:nowrap;}
.qz-progress-track{flex:1;height:10px;background:#F0F0F0;border-radius:var(--border-radius-full);overflow:hidden;}
.qz-progress-fill{height:100%;background:linear-gradient(90deg,var(--qz-primary),var(--qz-gold));
    border-radius:var(--border-radius-full);transition:width .4s ease;}
.qz-progress-count{font-size:.8125rem;font-weight:700;color:var(--color-text-secondary);}

.qz-card{background:var(--color-white);border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-md);
    padding:var(--space-2xl);margin-bottom:var(--space-xl);}
.qz-q-num{font-size:.75rem;font-weight:700;color:var(--qz-primary);letter-spacing:1px;
    text-transform:uppercase;margin-bottom:var(--space-sm);display:flex;align-items:center;gap:6px;}
.qz-q-text{font-family:var(--font-primary);font-size:1.125rem;font-weight:700;
    color:var(--color-text);line-height:1.5;margin-bottom:var(--space-lg);}
.qz-q-img{max-width:100%;max-height:250px;border-radius:var(--border-radius-lg);
    border:1.5px solid var(--border-color);margin-bottom:var(--space-lg);}
.qz-q-diff{display:inline-flex;align-items:center;gap:4px;padding:3px 10px;
    border-radius:var(--border-radius-full);font-size:.6875rem;font-weight:700;margin-bottom:var(--space-md);}
.qz-q-diff.easy{background:#DCFCE7;color:#15803D;}
.qz-q-diff.medium{background:#FEF9C3;color:#854D0E;}
.qz-q-diff.hard{background:#FEF2F2;color:#DC2626;}

/* Radio/Checkbox option cards */
.qz-rbl,.qz-cbl{display:flex!important;flex-direction:column;gap:var(--space-sm);}
.qz-rbl label,.qz-cbl label{display:flex!important;align-items:center;gap:var(--space-md);padding:14px 18px;
    border:2px solid var(--border-color);border-radius:var(--border-radius-lg);
    cursor:pointer;transition:all .2s;background:#FAFBFC;font-size:.9375rem;color:var(--color-text);line-height:1.4;}
.qz-rbl label:hover,.qz-cbl label:hover{border-color:var(--qz-primary);background:var(--qz-primary-light);transform:translateX(4px);}
.qz-rbl input[type="radio"],.qz-cbl input[type="checkbox"]{width:20px;height:20px;accent-color:var(--qz-primary);flex-shrink:0;cursor:pointer;}
.qz-rbl input[type="radio"]:checked+span,.qz-cbl input[type="checkbox"]:checked+span{color:var(--qz-primary);font-weight:700;}
.qz-rbl label:has(input:checked),.qz-cbl label:has(input:checked){border-color:var(--qz-primary);background:var(--qz-primary-light);box-shadow:0 0 0 3px rgba(255,107,44,.12);}

/* TF cards */
.qz-tf-wrap{display:grid;grid-template-columns:1fr 1fr;gap:var(--space-md);}
.qz-tf-wrap label{display:flex;flex-direction:column;align-items:center;justify-content:center;
    padding:var(--space-xl);border:2px solid var(--border-color);border-radius:var(--border-radius-xl);
    cursor:pointer;transition:all .2s;background:#FAFBFC;text-align:center;gap:8px;}
.qz-tf-wrap label:hover{border-color:var(--qz-primary);background:var(--qz-primary-light);}
.qz-tf-wrap label:has(input:checked){border-color:var(--qz-primary);background:var(--qz-primary-light);box-shadow:0 0 0 3px rgba(255,107,44,.12);}
.qz-tf-wrap input[type="radio"]{display:none;}
.qz-tf-ico{font-size:2rem;}
.qz-tf-lbl{font-family:var(--font-primary);font-size:1rem;font-weight:700;color:var(--color-text);}

/* DragDrop / Fill chips */
.qz-dd-chips{display:flex;flex-wrap:wrap;gap:var(--space-sm);margin-bottom:var(--space-md);margin-top:var(--space-md);}
.qz-dd-chip{display:inline-flex;align-items:center;gap:6px;padding:12px 20px;
    border:2px solid var(--border-color);border-radius:var(--border-radius-full);
    cursor:grab;transition:all .2s;background:#FAFBFC;font-size:.9375rem;font-weight:600;color:var(--color-text);
    user-select:none;-webkit-user-select:none;}
.qz-dd-chip:hover{border-color:var(--qz-primary);background:var(--qz-primary-light);transform:scale(1.05);}
.qz-dd-chip:active{cursor:grabbing;transform:scale(.95);opacity:.7;}
.qz-dd-chip.used{border-color:var(--qz-green);background:#DCFCE7;color:#15803D;opacity:.5;pointer-events:none;cursor:default;}
.qz-dd-dropzone{background:#F8FAFC;border:2.5px dashed var(--border-color);border-radius:var(--border-radius-xl);
    padding:var(--space-lg) var(--space-xl);min-height:70px;display:flex;flex-wrap:wrap;gap:var(--space-sm);
    align-items:center;transition:all .25s;margin-bottom:var(--space-sm);}
.qz-dd-dropzone.dragover{border-color:var(--qz-primary);background:var(--qz-primary-light);box-shadow:0 0 0 4px rgba(255,107,44,.12);}
.qz-dd-dropzone .qz-dd-answer-chip{display:inline-flex;align-items:center;gap:6px;padding:8px 16px;
    background:var(--qz-primary-light);border:1.5px solid var(--qz-primary);border-radius:var(--border-radius-full);
    font-size:.875rem;font-weight:700;color:var(--qz-primary);cursor:pointer;transition:all .2s;animation:ddPop .3s ease;}
.qz-dd-dropzone .qz-dd-answer-chip:hover{background:#FECACA;border-color:#EF4444;color:#DC2626;}
@keyframes ddPop{from{transform:scale(0);opacity:0;}to{transform:scale(1);opacity:1;}}
.qz-dd-placeholder{color:var(--color-text-muted);font-size:.875rem;font-style:italic;}
.qz-dd-reset{display:inline-flex;align-items:center;gap:4px;padding:8px 16px;border-radius:var(--border-radius-full);
    font-size:.8125rem;font-weight:700;background:#F3F4F6;color:var(--color-text-secondary);border:1px solid var(--border-color);
    cursor:pointer;transition:all .2s;margin-top:var(--space-sm);}
.qz-dd-reset:hover{background:#E5E7EB;}

/* Multiselect hint */
.qz-hint{font-size:.8rem;color:var(--color-text-muted);margin-bottom:var(--space-sm);font-weight:600;display:flex;align-items:center;gap:4px;}

/* Navigation */
.qz-nav{display:flex;align-items:center;justify-content:space-between;gap:var(--space-md);flex-wrap:wrap;}
.qz-nav-btn{display:inline-flex;align-items:center;gap:6px;padding:12px 24px;
    border-radius:var(--border-radius-full);font-weight:700;font-size:.9375rem;
    border:none;cursor:pointer;transition:all .2s;}
.qz-nav-prev{background:#F3F4F6;color:var(--color-text);}
.qz-nav-prev:hover{background:#E5E7EB;}
.qz-nav-next{background:var(--qz-blue);color:#fff;box-shadow:0 4px 12px rgba(37,99,235,.3);}
.qz-nav-next:hover{background:#1D4ED8;transform:translateY(-2px);}
.qz-nav-submit{background:linear-gradient(135deg,var(--qz-green),#4ADE80);color:#fff;
    box-shadow:0 4px 12px rgba(34,197,94,.3);}
.qz-nav-submit:hover{transform:translateY(-2px);box-shadow:0 8px 20px rgba(34,197,94,.4);}

/* Validation message */
.qz-val-msg{background:#FEF2F2;border:1.5px solid #FECACA;border-radius:var(--border-radius);
    padding:10px 16px;margin-bottom:var(--space-md);font-size:.875rem;font-weight:600;color:#DC2626;
    display:flex;align-items:center;gap:8px;}

/* Error page */
.qz-error{background:var(--color-white);border-radius:var(--border-radius-xl);
    border:1.5px solid var(--border-color);box-shadow:var(--shadow-sm);
    padding:var(--space-2xl);text-align:center;}
.qz-error-icon{font-size:3rem;margin-bottom:var(--space-md);}
.qz-error-btn{display:inline-flex;align-items:center;gap:6px;padding:10px 22px;
    border-radius:var(--border-radius-full);font-weight:700;background:var(--qz-blue);
    color:#fff;text-decoration:none;margin-top:var(--space-lg);}
.qz-error-btn:hover{text-decoration:none;color:#fff;}

@media(max-width:767px){
    .qz-hero{padding:var(--space-lg);}
    .qz-hero-title{font-size:1.25rem;}
    .qz-card{padding:var(--space-xl);}
    .qz-tf-wrap{grid-template-columns:1fr;}
    .qz-nav{flex-direction:column;align-items:stretch;}
    .qz-nav-btn{justify-content:center;}
}
</style>
</asp:Content>

<asp:Content ID="cSidebarMenu" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label">Main</div>
        <a href="<%: ResolveUrl("~/Student/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label">Dashboard</span></a>
        <a href="<%: ResolveUrl("~/Student/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label">Notifications</span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Learn</div>
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label">My Learning</span></a>
        <a href="<%: ResolveUrl("~/Student/PracticeLibrary.aspx") %>" class="sb-sidebar-item"><i class="bi bi-patch-question item-icon"></i><span class="item-label">Practice Library</span></a>
        <a href="<%: ResolveUrl("~/Student/VirtualLabs.aspx") %>" class="sb-sidebar-item"><i class="bi bi-eyedropper item-icon"></i><span class="item-label">Virtual Labs</span></a>
        <a href="<%: ResolveUrl("~/Student/LiveSessions.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label">Live Sessions</span></a>
        <a href="<%: ResolveUrl("~/Student/AIStudyCompanion.aspx") %>" class="sb-sidebar-item"><i class="bi bi-robot item-icon"></i><span class="item-label">AI Study Companion</span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Progress</div>
        <a href="<%: ResolveUrl("~/Student/ProgressRewards.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bar-chart-line item-icon"></i><span class="item-label">Progress &amp; Rewards</span></a>
        <a href="<%: ResolveUrl("~/Student/Forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label">Forum</span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label">Account</div>
        <a href="<%: ResolveUrl("~/Student/Messages.aspx") %>" class="sb-sidebar-item"><i class="bi bi-envelope item-icon"></i><span class="item-label">Messages</span></a>
        <a href="<%: ResolveUrl("~/Student/MyProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label">My Profile</span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label">Sign Out</span></a></div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><asp:Literal ID="litPageTitle" runat="server" Text="Quiz" /></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- ERROR --%>
<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="qz-error">
        <div class="qz-error-icon"><i class="bi bi-exclamation-triangle-fill" style="color:var(--qz-primary);"></i></div>
        <div style="font-family:var(--font-primary);font-size:1.25rem;font-weight:700;margin-bottom:8px;"><asp:Literal ID="litErrorTitle" runat="server" /></div>
        <div style="color:var(--color-text-secondary);"><asp:Literal ID="litErrorDesc" runat="server" /></div>
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="qz-error-btn"><i class="bi bi-arrow-left"></i> <asp:Literal ID="litErrorBtn" runat="server" Text="Back" /></a>
    </div>
</asp:Panel>

<%-- QUIZ --%>
<asp:Panel ID="pnlQuiz" runat="server" Visible="false">
    <div class="qz-hero"><div class="qz-hero-blob"></div>
        <div class="qz-hero-title"><asp:Literal ID="litQuizTitle" runat="server" /></div>
        <div class="qz-hero-sub"><asp:Literal ID="litQuizSub" runat="server" /></div>
        <div class="qz-hero-meta">
            <span class="qz-hero-chip"><i class="bi bi-list-check"></i> <asp:Literal ID="litQCount" runat="server" /></span>
            <span class="qz-hero-chip"><i class="bi bi-bookmark-fill"></i> <asp:Literal ID="litQType" runat="server" /></span>
        </div>
    </div>

    <div class="qz-progress-bar">
        <span class="qz-progress-label"><i class="bi bi-bar-chart-steps"></i> <asp:Literal ID="litProgressLabel" runat="server" Text="Progress" /></span>
        <div class="qz-progress-track"><div class="qz-progress-fill" id="progressFill" runat="server" style="width:0%"></div></div>
        <span class="qz-progress-count"><asp:Literal ID="litProgressCount" runat="server" Text="0/0" /></span>
    </div>

    <%-- Validation Message --%>
    <asp:Panel ID="pnlValMsg" runat="server" Visible="false">
        <div class="qz-val-msg"><i class="bi bi-exclamation-circle-fill"></i> <asp:Literal ID="litValMsg" runat="server" /></div>
    </asp:Panel>

    <%-- Question Card --%>
    <div class="qz-card">
        <div class="qz-q-num"><i class="bi bi-patch-question-fill"></i> <asp:Literal ID="litQNum" runat="server" /></div>
        <asp:Panel ID="pnlQDiff" runat="server" Visible="false">
            <div class="qz-q-diff" id="divDiff" runat="server"><asp:Literal ID="litQDiff" runat="server" /></div>
        </asp:Panel>
        <div class="qz-q-text"><asp:Literal ID="litQText" runat="server" /></div>
        <asp:Image ID="imgQuestion" runat="server" CssClass="qz-q-img" Visible="false" />

        <%-- MCQ --%>
        <asp:Panel ID="pnlMCQ" runat="server" Visible="false">
            <asp:RadioButtonList ID="rblMCQ" runat="server" CssClass="qz-rbl" RepeatLayout="Flow" />
        </asp:Panel>

        <%-- True/False --%>
        <asp:Panel ID="pnlTF" runat="server" Visible="false">
            <div class="qz-tf-wrap">
                <asp:RadioButtonList ID="rblTF" runat="server" RepeatLayout="Flow" CssClass="qz-tf-wrap" />
            </div>
        </asp:Panel>

        <%-- Multiselect --%>
        <asp:Panel ID="pnlMulti" runat="server" Visible="false">
            <div class="qz-hint"><i class="bi bi-info-circle"></i> <asp:Literal ID="litMultiHint" runat="server" /></div>
            <asp:CheckBoxList ID="cblMulti" runat="server" CssClass="qz-cbl" RepeatLayout="Flow" />
        </asp:Panel>

        <%-- DragDrop / Fill-in (HTML5 Drag & Drop + Click) --%>
        <asp:Panel ID="pnlDrag" runat="server" Visible="false">
            <div class="qz-hint"><i class="bi bi-info-circle"></i> <asp:Literal ID="litDragHint" runat="server" /></div>

            <%-- Drop Zone --%>
            <div class="qz-dd-dropzone" id="ddDropZone"
                 ondragover="event.preventDefault();this.classList.add('dragover');"
                 ondragleave="this.classList.remove('dragover');"
                 ondrop="ddHandleDrop(event);">
                <span class="qz-dd-placeholder" id="ddPlaceholder"><asp:Literal ID="litDDPlaceholder" runat="server" Text="Drag answers here or click them" /></span>
            </div>

            <%-- Draggable Chips rendered by server as plain HTML divs --%>
            <div class="qz-dd-chips" id="ddChipContainer">
                <asp:Literal ID="litDDChips" runat="server" />
            </div>

            <%-- Reset Button (client-side) --%>
            <button type="button" class="qz-dd-reset" onclick="ddReset();"><i class="bi bi-arrow-counterclockwise"></i> <asp:Literal ID="litDDResetBtn" runat="server" Text="Reset" /></button>

            <%-- Hidden field stores the answer --%>
            <asp:HiddenField ID="hdnDDAnswer" runat="server" />
        </asp:Panel>
    </div>

    <%-- Navigation --%>
    <div class="qz-nav">
        <asp:Button ID="btnPrev" runat="server" CssClass="qz-nav-btn qz-nav-prev" OnClick="btnPrev_Click" Text="Previous" CausesValidation="false" />
        <asp:Button ID="btnNext" runat="server" CssClass="qz-nav-btn qz-nav-next" OnClick="btnNext_Click" Text="Next" CausesValidation="false" />
        <asp:Button ID="btnSubmit" runat="server" CssClass="qz-nav-btn qz-nav-submit" OnClick="btnSubmit_Click" Text="Submit Quiz" Visible="false" CausesValidation="false" />
    </div>
</asp:Panel>
</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
// ═══ HTML5 Drag & Drop + Click for DragDrop questions ═══
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
    // Update hidden field
    var hdn = document.getElementById(ddHiddenId);
    if (hdn) hdn.value = ddAnswers.join(',');

    // Update drop zone
    var zone = document.getElementById('ddDropZone');
    if (!zone) return;
    if (ddAnswers.length === 0) {
        var ph = document.getElementById('ddPlaceholder');
        zone.innerHTML = '<span class="qz-dd-placeholder" id="ddPlaceholder">' + (ph ? ph.textContent : 'Drop here') + '</span>';
    } else {
        var html = '';
        for (var i = 0; i < ddAnswers.length; i++) {
            html += '<span class="qz-dd-answer-chip" onclick="ddRemoveAnswer('+i+')" title="Click to remove">' +
                    ddAnswers[i] + ' <i class="bi bi-x-circle-fill" style="font-size:.75rem;opacity:.7;"></i></span>';
        }
        zone.innerHTML = html;
    }

    // Update chip states
    var chips = document.querySelectorAll('#ddChipContainer .qz-dd-chip');
    chips.forEach(function(chip) {
        var val = chip.getAttribute('data-value');
        // For single-blank, mark the selected one as used
        if (ddMaxBlanks === 1 && ddAnswers.indexOf(val) > -1) {
            chip.classList.add('used');
        } else if (ddMaxBlanks > 1) {
            // For multi-blank, count how many times this value appears
            var count = ddAnswers.filter(function(a){return a===val;}).length;
            // Don't mark used for multi-blank (allow reuse is possible, but typically each used once)
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
</script>
</asp:Content>
