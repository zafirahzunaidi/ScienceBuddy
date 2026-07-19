<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="UnitDetails.aspx.cs" Inherits="ScienceBuddy.Student.UnitDetails" %>

<asp:Content ID="HeadStyle" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%: ResolveUrl("~/Content/Student.css") %>" rel="stylesheet" />
</asp:Content>

<asp:Content ID="TopNavigationLinks" ContentPlaceHolderID="TopNavLinks" runat="server">
</asp:Content>

<asp:Content ID="TopNavActions" ContentPlaceHolderID="TopNavActions" runat="server">
</asp:Content>

<asp:Content ID="TopNavigationMainContent" ContentPlaceHolderID="MainContent" runat="server">
</asp:Content>

<%-- Student Sidebar --%>
<asp:Content ID="StudentSidebarMenu" ContentPlaceHolderID="SidebarMenu" runat="server">
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
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="sb-sidebar-item active">
            <i class="bi bi-book item-icon"></i><span class="item-label">My Learning</span>
        </a>
        <a href="<%: ResolveUrl("~/Student/PracticeLibrary.aspx") %>" class="sb-sidebar-item">
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

<asp:Content ID="StudentSidebarFooter" ContentPlaceHolderID="SidebarFooter" runat="server">
</asp:Content>

<asp:Content ID="UnitDetailsPageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <asp:Literal ID="litPageTitle" runat="server" Text="Unit Details" />
</asp:Content>

<asp:Content ID="StudentUserDropdownMenu" ContentPlaceHolderID="UserDropdownMenu" runat="server">
</asp:Content>

<asp:Content ID="UnitDetailsBreadcrumb" ContentPlaceHolderID="BreadcrumbContent" runat="server">
</asp:Content>

<%-- UnitDetails Main Content --%>
<asp:Content ID="UnitDetailsMainContent" ContentPlaceHolderID="MainContentSidebar" runat="server">

    <asp:Panel ID="pnlLocked" runat="server" Visible="false">
        <div class="st-unitdetails-locked"><div class="st-unitdetails-locked-icon"><i class="bi bi-lock-fill"></i></div>
            <div class="st-unitdetails-locked-title"><asp:Literal ID="litLockedTitle" runat="server" /></div>
            <div class="st-unitdetails-locked-desc"><asp:Literal ID="litLockedDesc" runat="server" /></div>
            <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="sb-btn sb-btn-primary sb-btn-sm"><i class="bi bi-arrow-left"></i> <asp:Literal ID="litLockedBtn" runat="server" /></a>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlMain" runat="server">

    <div class="st-unitdetails-hero">
        <a href="<%: ResolveUrl("~/Student/MyLearning.aspx") %>" class="st-unitdetails-hero-back"><i class="bi bi-arrow-left"></i> <asp:Literal ID="litBack" runat="server" /></a>
        <div class="st-unitdetails-hero-name"><asp:Literal ID="litUnitName" runat="server" /></div>
        <div class="st-unitdetails-hero-desc"><asp:Literal ID="litUnitDesc" runat="server" /></div>
        <div class="st-unitdetails-hero-level"><i class="bi bi-bar-chart-fill"></i> <asp:Literal ID="litHeroLevel" runat="server" /></div>
        <div class="st-unitdetails-hero-bar">
            <div class="st-unitdetails-bar"><div class="st-unitdetails-bar-fill" id="heroBar" runat="server" style="width:0%"></div></div>
            <div class="st-unitdetails-bar-lbl"><span><asp:Literal ID="litBarLbl" runat="server" /></span><span><asp:Literal ID="litBarPct" runat="server" Text="0%" /></span></div>
        </div>
        <div class="st-unit-flashcard-hero-action">
            <asp:Button ID="btnGenerateFlashcards" runat="server" Text="Create AI Flashcards" CssClass="st-unit-flashcard-generate" OnClick="btnGenerateFlashcards_Click" OnClientClick="this.value=this.getAttribute('data-creating');this.disabled=true;" UseSubmitBehavior="false" />
        </div>
    </div>


    <%-- Subtopics & Lessons --%>
    <asp:Panel ID="pnlLessons" runat="server">
        <div class="st-unitdetails-sec-hd"><i class="bi bi-journal-text" style="color:var(--student);font-size:1.1rem;"></i><div class="st-unitdetails-sec-title"><asp:Literal ID="litLessonHd" runat="server" /></div></div>
        <asp:Repeater ID="rptSubtopics" runat="server">
            <ItemTemplate>
                <div class="st-unitdetails-subtopic">
                    <div class="st-unitdetails-subtopic-title"><i class="bi bi-bookmark-fill" style="color:var(--student);"></i> <%# Eval("Title") %></div>
                    <div class="st-unitdetails-subtopic-desc"><%# Eval("Desc") %></div>
                    <div class="st-unitdetails-lessons st-unitdetails-road">
                        <asp:Repeater ID="rptLessons" runat="server" DataSource='<%# Eval("Lessons") %>'>
                            <ItemTemplate>
                                <a href="<%# Eval("Url") %>" class="st-unitdetails-lesson-link">
                                    <div class="st-unitdetails-lesson-node <%# (bool)Eval("Done") ? "done" : "pending" %>">
                                        <i class="bi <%# (bool)Eval("Done") ? "bi-check-lg" : "bi-play-fill" %>"></i>
                                    </div>
                                    <div class="st-unitdetails-lesson-content">
                                        <div class="st-unitdetails-lesson-name"><%# Eval("Title") %></div>
                                        <span class="st-unitdetails-lesson-badge" style="background:<%# (bool)Eval("Done") ? "#DCFCE7" : "#F0F7FF" %>;color:<%# (bool)Eval("Done") ? "#15803D" : "#2563EB" %>;">
                                            <%# Eval("Badge") %>
                                        </span>
                                    </div>
                                </a>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </asp:Panel>

    <%-- Materials --%>
    <asp:Panel ID="pnlMats" runat="server">
        <div class="st-unitdetails-sec-hd"><i class="bi bi-folder-fill" style="color:#B45309;font-size:1.1rem;"></i><div class="st-unitdetails-sec-title"><asp:Literal ID="litMatHd" runat="server" /></div></div>
        <div class="st-unitdetails-mat-grid">
            <asp:Repeater ID="rptMats" runat="server">
                <ItemTemplate>
                    <div class="st-unitdetails-mat-card">
                        <div class="st-unitdetails-mat-title"><%# Eval("Title") %></div>
                        <div class="st-unitdetails-mat-meta"><span><i class="bi bi-file-earmark"></i> <%# Eval("Type") %></span><span><i class="bi bi-translate"></i> <%# Eval("Lang") %></span></div>
                        <div class="st-unitdetails-mat-actions">
                            <button type="button" class="sb-btn sb-btn-xs sb-btn-primary st-unitdetails-mat-view-btn" onclick="openMaterialPreview('<%# Eval("ResolvedUrl") %>', '<%# Eval("Title").ToString().Replace("'","\\'") %>')"><i class="bi bi-eye"></i> <%# Eval("ViewBtn") %></button>
                            <a href="<%# Eval("ResolvedUrl") %>" class="sb-btn sb-btn-xs sb-btn-outline-primary" download><i class="bi bi-download"></i> <%# Eval("DownloadBtn") %></a>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlMatsEmpty" runat="server" Visible="false">
        <div class="sb-alert sb-alert-info mb-lg"><i class="bi bi-info-circle-fill alert-icon"></i><div class="alert-content"><asp:Literal ID="litMatsEmpty" runat="server" /></div></div>
    </asp:Panel>

    <%-- Material Preview Modal --%>
    <div id="materialPreviewModal" class="st-unitdetails-mat-modal" style="display:none;" onclick="if(event.target===this)closeMaterialPreview();">
        <div class="st-unitdetails-mat-modal-content">
            <div class="st-unitdetails-mat-modal-header">
                <span id="materialPreviewTitle"></span>
                <button type="button" onclick="closeMaterialPreview();" class="st-unitdetails-mat-modal-close"><i class="bi bi-x-lg"></i></button>
            </div>
            <iframe id="materialPreviewFrame" class="st-unitdetails-mat-modal-frame" src="about:blank"></iframe>
        </div>
    </div>

    <%-- Virtual Lab --%>
    <asp:Panel ID="pnlLab" runat="server" Visible="false">
        <div class="st-unitdetails-sec-hd"><i class="bi bi-eyedropper" style="color:#15803D;font-size:1.1rem;"></i><div class="st-unitdetails-sec-title"><asp:Literal ID="litLabHd" runat="server" /></div></div>
        <div class="st-unitdetails-lab">
            <div class="st-unitdetails-lab-icon"><i class="bi bi-eyedropper"></i></div>
            <div class="st-unitdetails-lab-body"><div class="st-unitdetails-lab-title"><asp:Literal ID="litLabTitle" runat="server" /></div><div class="st-unitdetails-lab-sub"><asp:Literal ID="litLabSub" runat="server" /></div></div>
            <a href="#" class="sb-btn sb-btn-white sb-btn-sm"><i class="bi bi-play-fill"></i> <asp:Literal ID="litLabBtn" runat="server" /></a>
        </div>
    </asp:Panel>

    <%-- Unit Quiz --%>
    <asp:Panel ID="pnlQuiz" runat="server" Visible="false">
        <div class="st-unitdetails-sec-hd"><i class="bi bi-patch-question-fill" style="color:#1D4ED8;font-size:1.1rem;"></i><div class="st-unitdetails-sec-title"><asp:Literal ID="litQuizHd" runat="server" /></div></div>
        <div class="st-unitdetails-quiz">
            <div class="st-unitdetails-quiz-icon"><i class="bi bi-patch-question-fill"></i></div>
            <div class="st-unitdetails-quiz-body"><div class="st-unitdetails-quiz-title"><asp:Literal ID="litQuizTitle" runat="server" /></div><div class="st-unitdetails-quiz-sub"><asp:Literal ID="litQuizSub" runat="server" /></div></div>
            <a id="lnkQuizStart" runat="server" class="sb-btn sb-btn-white sb-btn-sm"><i class="bi bi-play-fill"></i> <asp:Literal ID="litQuizBtn" runat="server" /></a>
        </div>
        <asp:Panel ID="pnlQuizResult" runat="server" Visible="false" style="margin-top:var(--space-sm);display:flex;gap:8px;flex-wrap:wrap;">
            <a id="lnkQuizResult" runat="server" class="sb-btn sb-btn-outline-primary sb-btn-sm" style="font-size:.75rem;"><i class="bi bi-eye"></i> <asp:Literal ID="litQuizResultBtn" runat="server" /></a>
            <a id="lnkQuizReview" runat="server" class="sb-btn sb-btn-outline-primary sb-btn-sm" style="font-size:.75rem;"><i class="bi bi-search"></i> <asp:Literal ID="litQuizReviewBtn" runat="server" /></a>
        </asp:Panel>
    </asp:Panel>

    </asp:Panel>

    <%-- AI Flashcards Modal --%>
    <asp:Panel ID="pnlAIFlashcards" runat="server" Visible="false">
        <div id="flashcardModalOverlay" class="st-unit-flashcard-modal" style="display:none;position:fixed;top:0;left:0;right:0;bottom:0;z-index:2000;">
            <div class="st-unit-flashcard-backdrop" onclick="closeFlashcardModal(event);">
                <div class="st-unit-flashcard-dialog" role="dialog" aria-modal="true" aria-labelledby="flashcardModalTitle" onclick="event.stopPropagation();">
                    <button type="button" class="st-unit-flashcard-close" aria-label="Close flashcards" onclick="closeFlashcardModal();">
                        <i class="bi bi-x-lg"></i>
                    </button>
                    <div class="st-unit-flashcard-dialog-header">
                        <div class="st-unit-flashcard-dialog-header-left">
                            <div class="st-unit-flashcard-dialog-icon"><i class="bi bi-stars"></i></div>
                            <div>
                                <h2 id="flashcardModalTitle" class="st-unit-flashcard-dialog-title"><asp:Literal ID="litFlashcardTitle" runat="server" /></h2>
                                <asp:Literal ID="litFlashcardDesc" runat="server" />
                            </div>
                        </div>
                    </div>

                    <%-- Loading --%>
                    <asp:Panel ID="pnlFlashcardLoading" runat="server" Visible="false">
                        <div class="st-unit-flashcard-loading">
                            <div class="st-unit-flashcard-loading-spinner"></div>
                            <div class="st-unit-flashcard-loading-text">
                                <span><asp:Literal ID="litFlashcardLoading" runat="server" /></span>
                                <span class="st-unit-flashcard-loading-sub"><asp:Literal ID="litFlashcardLoadingSub" runat="server" /></span>
                            </div>
                        </div>
                    </asp:Panel>

                    <%-- Error --%>
                    <asp:Panel ID="pnlFlashcardError" runat="server" Visible="false">
                        <div class="st-unit-flashcard-error">
                            <i class="bi bi-exclamation-triangle-fill"></i>
                            <div>
                                <span><asp:Literal ID="litFlashcardError" runat="server" /></span>
                            </div>
                        </div>
                    </asp:Panel>

                    <%-- Flashcard Deck --%>
                    <asp:Button ID="btnRegenerateFlashcards" runat="server" Text="Create New Cards" CssClass="st-unit-flashcard-regenerate" OnClick="btnGenerateFlashcards_Click" style="display:none;" />
                    <div class="st-unit-flashcard-deck">
                        <div class="st-unit-flashcard-stage">
                            <asp:Repeater ID="rptAIFlashcards" runat="server">
                                <ItemTemplate>
                                    <div class="st-unit-flashcard-slide" data-card-index="<%# Container.ItemIndex %>">
                                        <div class="st-unit-flashcard-card" tabindex="0" role="button" aria-label="Flip flashcard" onclick="flipFlashcard(this);" onkeydown="handleFlashcardKey(event, this);">
                                            <div class="st-unit-flashcard-inner">
                                                <div class="st-unit-flashcard-face st-unit-flashcard-front">
                                                    <div class="st-unit-flashcard-top">
                                                        <span class="st-unit-flashcard-number"><%#: Eval("CardNumber") %></span>
                                                        <span class="st-unit-flashcard-label"><%#: FlashcardQuestionLabel %></span>
                                                    </div>
                                                    <div class="st-unit-flashcard-question"><%#: Eval("Question") %></div>
                                                    <div class="st-unit-flashcard-hint"><i class="bi bi-hand-index"></i> <%#: FlashcardTapToReveal %></div>
                                                </div>
                                                <div class="st-unit-flashcard-face st-unit-flashcard-back">
                                                    <div class="st-unit-flashcard-top">
                                                        <span class="st-unit-flashcard-number"><%#: Eval("CardNumber") %></span>
                                                        <span class="st-unit-flashcard-label st-unit-flashcard-label-answer"><%#: FlashcardAnswerLabel %></span>
                                                    </div>
                                                    <div class="st-unit-flashcard-answer"><%#: Eval("Answer") %></div>
                                                    <div class="st-unit-flashcard-hint st-unit-flashcard-hint-back"><i class="bi bi-arrow-repeat"></i> <%#: FlashcardTapToQuestion %></div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                        <div id="flashcardDots" class="st-unit-flashcard-dots"></div>
                        <div class="st-unit-flashcard-navigation">
                            <button type="button" id="btnPreviousFlashcard" class="st-unit-flashcard-nav-btn" onclick="showPreviousFlashcard();">
                                <i class="bi bi-arrow-left"></i> <span><%: FlashcardPrevText %></span>
                            </button>
                            <button type="button" id="btnNextFlashcard" class="st-unit-flashcard-nav-btn st-unit-flashcard-nav-primary" onclick="showNextFlashcard();">
                                <span id="flashcardNextLabel"><%: FlashcardNextText %></span> <i class="bi bi-arrow-right"></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </asp:Panel>

    <script type="text/javascript">
    function openMaterialPreview(url, title) {
        document.getElementById('materialPreviewTitle').innerText = title;
        document.getElementById('materialPreviewFrame').src = url;
        document.getElementById('materialPreviewModal').style.display = 'flex';
    }
    function closeMaterialPreview() {
        document.getElementById('materialPreviewModal').style.display = 'none';
        document.getElementById('materialPreviewFrame').src = 'about:blank';
    }

    /* --- Flashcard Modal --- */
    var currentFlashcardIndex = 0;
    var flashcardNextText = '<%: FlashcardNextText %>';
    var flashcardFinishedText = '<%: FlashcardFinishedText %>';

    function openFlashcardModal() {
        var modal = document.getElementById('flashcardModalOverlay');
        if (modal) {
            modal.style.display = 'block';
            document.body.style.overflow = 'hidden';
            initialiseFlashcardDeck();
        }
    }

    function closeFlashcardModal(event) {
        if (event) { event.preventDefault(); }
        var modal = document.getElementById('flashcardModalOverlay');
        if (modal) {
            modal.style.display = 'none';
            document.body.style.overflow = '';
        }
    }

    function getFlashcardSlides() {
        return document.querySelectorAll('.st-unit-flashcard-slide');
    }

    function initialiseFlashcardDeck() {
        currentFlashcardIndex = 0;
        createFlashcardDots();
        showFlashcard(0);
    }

    function showFlashcard(index) {
        var slides = getFlashcardSlides();
        if (!slides || slides.length === 0) { return; }
        if (index < 0) { index = 0; }
        if (index >= slides.length) { index = slides.length - 1; }

        for (var i = 0; i < slides.length; i++) {
            slides[i].classList.remove('is-active');
            var card = slides[i].querySelector('.st-unit-flashcard-card');
            if (card) { card.classList.remove('is-flipped'); }
        }

        currentFlashcardIndex = index;
        slides[index].classList.add('is-active');
        updateFlashcardDots();
        updateFlashcardButtons(slides.length);

        var activeCard = slides[index].querySelector('.st-unit-flashcard-card');
        if (activeCard) { activeCard.focus(); }
    }

    function showNextFlashcard() {
        var slides = getFlashcardSlides();
        if (currentFlashcardIndex < slides.length - 1) {
            showFlashcard(currentFlashcardIndex + 1);
        }
    }

    function showPreviousFlashcard() {
        if (currentFlashcardIndex > 0) {
            showFlashcard(currentFlashcardIndex - 1);
        }
    }

    function updateFlashcardButtons(total) {
        var prevBtn = document.getElementById('btnPreviousFlashcard');
        var nextBtn = document.getElementById('btnNextFlashcard');
        var nextLabel = document.getElementById('flashcardNextLabel');
        if (prevBtn) { prevBtn.disabled = (currentFlashcardIndex === 0); }
        if (nextBtn) { nextBtn.disabled = (currentFlashcardIndex === total - 1); }
        if (nextLabel) {
            nextLabel.textContent = (currentFlashcardIndex === total - 1) ? flashcardFinishedText : flashcardNextText;
        }
    }

    function createFlashcardDots() {
        var dotsContainer = document.getElementById('flashcardDots');
        if (!dotsContainer) { return; }
        var slides = getFlashcardSlides();
        dotsContainer.innerHTML = '';
        for (var i = 0; i < slides.length; i++) {
            var dot = document.createElement('button');
            dot.type = 'button';
            dot.className = 'st-unit-flashcard-dot';
            dot.setAttribute('aria-label', 'Go to card ' + (i + 1));
            dot.setAttribute('data-dot-index', i);
            dot.onclick = (function (idx) { return function () { showFlashcard(idx); }; })(i);
            dotsContainer.appendChild(dot);
        }
    }

    function updateFlashcardDots() {
        var dots = document.querySelectorAll('.st-unit-flashcard-dot');
        for (var i = 0; i < dots.length; i++) {
            if (i === currentFlashcardIndex) {
                dots[i].classList.add('is-active');
            } else {
                dots[i].classList.remove('is-active');
            }
        }
    }

    function flipFlashcard(card) {
        if (card) { card.classList.toggle('is-flipped'); }
    }

    function handleFlashcardKey(event, card) {
        if (event.key === 'Enter' || event.key === ' ') {
            event.preventDefault();
            flipFlashcard(card);
        }
    }

    /* Keyboard navigation */
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') { closeFlashcardModal(); return; }
        var modal = document.getElementById('flashcardModalOverlay');
        if (!modal || modal.style.display === 'none') { return; }
        var tag = document.activeElement ? document.activeElement.tagName : '';
        if (tag === 'INPUT' || tag === 'TEXTAREA' || tag === 'SELECT') { return; }
        if (e.key === 'ArrowRight') { e.preventDefault(); showNextFlashcard(); }
        if (e.key === 'ArrowLeft') { e.preventDefault(); showPreviousFlashcard(); }
    });
    </script>

</asp:Content>

<asp:Content ID="UnitDetailsScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
</asp:Content>

