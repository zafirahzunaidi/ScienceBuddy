<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="createPracticeQuiz.aspx.cs" Inherits="ScienceBuddy.Teacher.createPracticeQuiz" %>

<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
<link href="<%: ResolveUrl("~/Content/Teacher.css") %>" rel="stylesheet" />
</asp:Content>

<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item"><i class="bi bi-speedometer2 item-icon"></i><span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/Notifications.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bell item-icon"></i><span class="item-label"><%: T("Notifications","Notifikasi") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Teaching","Pengajaran") %></div>
        <a href="<%: ResolveUrl("~/Teacher/manageMaterials.aspx") %>" class="sb-sidebar-item"><i class="bi bi-book item-icon"></i><span class="item-label"><%: T("Manage Materials","Bahan Pembelajaran") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="sb-sidebar-item active"><i class="bi bi-patch-question item-icon"></i><span class="item-label"><%: T("Manage Quiz","Kuiz") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/studentProgress.aspx") %>" class="sb-sidebar-item"><i class="bi bi-bar-chart item-icon"></i><span class="item-label"><%: T("Student Progress","Prestasi Pelajar") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/liveSession.aspx") %>" class="sb-sidebar-item"><i class="bi bi-camera-video item-icon"></i><span class="item-label"><%: T("Schedule Live Class","Kelas Langsung") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Community","Komuniti") %></div>
        <a href="<%: ResolveUrl("~/Teacher/forum.aspx") %>" class="sb-sidebar-item"><i class="bi bi-chat-dots item-icon"></i><span class="item-label"><%: T("Forum","Forum") %></span></a>
        <a href="<%: ResolveUrl("~/Teacher/privateMessages.aspx") %>" class="sb-sidebar-item"><i class="bi bi-envelope item-icon"></i><span class="item-label"><%: T("Private Message","Mesej Peribadi") %></span></a></div>
    <div class="sb-nav-section"><div class="sb-nav-section-label"><%: T("Account","Akaun") %></div>
        <a href="<%: ResolveUrl("~/Teacher/MyProfile.aspx") %>" class="sb-sidebar-item"><i class="bi bi-person item-icon"></i><span class="item-label"><%: T("My Profile","Profil Saya") %></span></a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item"><i class="bi bi-box-arrow-right item-icon"></i><span class="item-label"><%: T("Sign Out","Log Keluar") %></span></a></div>
</asp:Content>

<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server"><%: T("Create Practice Quiz","Cipta Kuiz Latihan") %></asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

<%-- Access Denied --%>
<asp:Panel ID="pnlDenied" runat="server" Visible="false">
    <div class="tc-practice-quiz-denied">
        <div style="font-size:3rem;margin-bottom:1rem;">??</div>
        <h2 style="color:var(--tc-practice-quiz-text);font-weight:800;"><%: T("Access Denied","Akses Ditolak") %></h2>
        <p style="color:var(--tc-practice-quiz-muted);max-width:450px;"><%: T("Your account cannot access this page.","Akaun anda tidak boleh mengakses halaman ini.") %></p>
        <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="tc-practice-quiz-back" style="margin-top:1rem;"><i class="bi bi-arrow-left"></i> <%: T("Back","Kembali") %></a>
    </div>
</asp:Panel>

<%-- Invalid Parameters --%>
<asp:Panel ID="pnlInvalid" runat="server" Visible="false">
    <div class="tc-practice-quiz-denied">
        <div style="font-size:3rem;margin-bottom:1rem;">??</div>
        <h2 style="color:var(--tc-practice-quiz-text);font-weight:800;"><%: T("Invalid Selection","Pilihan Tidak Sah") %></h2>
        <p style="color:var(--tc-practice-quiz-muted);max-width:450px;"><asp:Literal ID="litInvalidMsg" runat="server" /></p>
        <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="tc-practice-quiz-back" style="margin-top:1rem;"><i class="bi bi-arrow-left"></i> <%: T("Back to Manage Quizzes","Kembali ke Urus Kuiz") %></a>
    </div>
</asp:Panel>

<%-- Main content --%>
<asp:Panel ID="pnlMain" runat="server" Visible="false">

<%-- ------------------------------------------------------
     HERO HEADER
     ------------------------------------------------------ --%>
<div class="tc-practice-quiz-hero">
    <div class="tc-practice-quiz-hero-bg">
        <%-- Science doodle icons ? decorative only, not clickable --%>
        <span class="tc-practice-quiz-doodle" style="top:12%;right:38%;font-size:2.8rem;transform:rotate(-18deg);color:#A78BFA;"><i class="bi bi-rocket-takeoff" style="pointer-events:none;"></i></span>
        <span class="tc-practice-quiz-doodle" style="top:8%;right:28%;font-size:2.2rem;transform:rotate(12deg);color:#6D5EF7;"><i class="bi bi-lightbulb" style="pointer-events:none;"></i></span>
        <span class="tc-practice-quiz-doodle tc-practice-quiz-doodle-sm" style="top:55%;right:22%;font-size:3rem;transform:rotate(-8deg);color:#4F8CFF;"><i class="bi bi-book" style="pointer-events:none;"></i></span>
        <span class="tc-practice-quiz-doodle tc-practice-quiz-doodle-sm" style="top:20%;right:18%;font-size:2.4rem;transform:rotate(22deg);color:#C4B5FD;"><i class="bi bi-eyedropper" style="pointer-events:none;"></i></span>
        <span class="tc-practice-quiz-doodle tc-practice-quiz-doodle-sm" style="top:65%;right:42%;font-size:2rem;transform:rotate(-30deg);color:#818CF8;"><i class="bi bi-search" style="pointer-events:none;"></i></span>
        <span class="tc-practice-quiz-doodle tc-practice-quiz-doodle-hide" style="top:30%;right:8%;font-size:3.5rem;transform:rotate(6deg);color:#A78BFA;"><i class="bi bi-globe2" style="pointer-events:none;"></i></span>
        <span class="tc-practice-quiz-doodle tc-practice-quiz-doodle-hide" style="top:5%;right:12%;font-size:2rem;transform:rotate(-14deg);color:#60A5FA;"><i class="bi bi-diagram-3" style="pointer-events:none;"></i></span>
        <span class="tc-practice-quiz-doodle tc-practice-quiz-doodle-hide" style="top:72%;right:14%;font-size:2.6rem;transform:rotate(18deg);color:#C4B5FD;"><i class="bi bi-clipboard2-pulse" style="pointer-events:none;"></i></span>
        <span class="tc-practice-quiz-doodle tc-practice-quiz-doodle-hide" style="top:45%;right:32%;font-size:2.2rem;transform:rotate(-22deg);color:#93C5FD;"><i class="bi bi-thermometer-half" style="pointer-events:none;"></i></span>
        <span class="tc-practice-quiz-doodle tc-practice-quiz-doodle-hide" style="top:80%;right:38%;font-size:1.8rem;transform:rotate(10deg);color:#A78BFA;"><i class="bi bi-stars" style="pointer-events:none;"></i></span>
        <svg viewBox="0 0 820 260" fill="none" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMaxYMid slice">
            <circle cx="550" cy="62" r="10" fill="#6D5EF7"/>
            <ellipse cx="550" cy="62" rx="36" ry="15" stroke="#6D5EF7" stroke-width="2.2" fill="none"/>
            <ellipse cx="550" cy="62" rx="36" ry="15" stroke="#6D5EF7" stroke-width="2.2" fill="none" transform="rotate(60 550 62)"/>
            <ellipse cx="550" cy="62" rx="36" ry="15" stroke="#6D5EF7" stroke-width="2.2" fill="none" transform="rotate(120 550 62)"/>
            <path d="M650 18 C660 36 672 36 682 18 C692 0 704 0 714 18" stroke="#4F8CFF" stroke-width="2.2" fill="none" stroke-linecap="round"/>
            <path d="M650 36 C660 54 672 54 682 36 C692 18 704 18 714 36" stroke="#4F8CFF" stroke-width="2.2" fill="none" stroke-linecap="round"/>
            <line x1="659" y1="27" x2="659" y2="43" stroke="#4F8CFF" stroke-width="1.6"/>
            <line x1="673" y1="36" x2="673" y2="52" stroke="#4F8CFF" stroke-width="1.6"/>
            <line x1="687" y1="27" x2="687" y2="43" stroke="#4F8CFF" stroke-width="1.6"/>
            <line x1="701" y1="18" x2="701" y2="34" stroke="#4F8CFF" stroke-width="1.6"/>
            <path d="M760 28 L760 66 L780 98 L740 98 Z" stroke="#6D5EF7" stroke-width="2.2" fill="none" stroke-linejoin="round"/>
            <line x1="752" y1="28" x2="768" y2="28" stroke="#6D5EF7" stroke-width="2.2"/>
            <ellipse cx="760" cy="90" rx="13" ry="5" fill="#6D5EF7" opacity=".45"/>
            <circle cx="754" cy="78" r="4" fill="#4F8CFF" opacity=".55"/>
            <circle cx="764" cy="84" r="3" fill="#A78BFA" opacity=".5"/>
            <rect x="790" y="110" width="24" height="38" rx="4" stroke="#4F8CFF" stroke-width="2" fill="none"/>
            <line x1="802" y1="110" x2="802" y2="96" stroke="#4F8CFF" stroke-width="2.2"/>
            <circle cx="802" cy="92" r="7" stroke="#4F8CFF" stroke-width="2" fill="none"/>
            <line x1="786" y1="148" x2="818" y2="148" stroke="#4F8CFF" stroke-width="2.2" stroke-linecap="round"/>
            <circle cx="700" cy="170" r="7" fill="#6D5EF7"/><circle cx="726" cy="150" r="5" fill="#4F8CFF"/>
            <circle cx="748" cy="172" r="7" fill="#6D5EF7"/><circle cx="726" cy="192" r="4.5" fill="#A78BFA"/>
            <line x1="707" y1="170" x2="721" y2="153" stroke="#6D5EF7" stroke-width="1.8"/>
            <line x1="731" y1="153" x2="743" y2="169" stroke="#6D5EF7" stroke-width="1.8"/>
            <line x1="726" y1="155" x2="726" y2="187" stroke="#4F8CFF" stroke-width="1.8"/>
            <path d="M610 110 Q632 88 644 110 Q632 134 610 110 Z" stroke="#6D5EF7" stroke-width="1.8" fill="none"/>
            <line x1="610" y1="110" x2="642" y2="110" stroke="#6D5EF7" stroke-width="1.2"/>
            <path d="M618 130 Q628 118 636 130 Q628 142 618 130 Z" stroke="#6D5EF7" stroke-width="1.5" fill="none" opacity=".6"/>
            <path d="M420 45 L422.5 52 L430 54.5 L422.5 57 L420 64 L417.5 57 L410 54.5 L417.5 52 Z" fill="#A78BFA" opacity=".75"/>
            <path d="M668 70 L669.8 75.5 L675.5 77.3 L669.8 79.1 L668 84.6 L666.2 79.1 L660.5 77.3 L666.2 75.5 Z" fill="#4F8CFF" opacity=".65"/>
            <path d="M495 130 L496.4 134 L500.5 135.4 L496.4 136.8 L495 140.8 L493.6 136.8 L489.5 135.4 L493.6 134 Z" fill="#6D5EF7" opacity=".6"/>
            <circle cx="438" cy="105" r="3.2" fill="#4F8CFF" opacity=".6"/>
            <circle cx="462" cy="72" r="2.4" fill="#6D5EF7" opacity=".55"/>
            <circle cx="582" cy="200" r="2.8" fill="#A78BFA" opacity=".5"/>
            <circle cx="640" cy="230" r="2" fill="#4F8CFF" opacity=".5"/>
            <path d="M380 260 Q470 228 565 242 Q650 256 750 236 Q790 228 820 234 L820 260 Z" fill="#6D5EF7" opacity=".15"/>
            <path d="M0 220 Q80 200 160 215 Q240 230 300 210 L300 260 L0 260 Z" fill="#4F8CFF" opacity=".12"/>
        </svg>
    </div>
    <div class="tc-practice-quiz-hero-left">
        <div class="tc-practice-quiz-hero-top">
            <div class="tc-practice-quiz-hero-top-left">
                <div class="tc-practice-quiz-hero-icon"><i class="bi bi-pencil-square"></i></div>
                <div>
                    <h1 class="tc-practice-quiz-hero-title"><%: T("Practice Quiz","Kuiz Latihan") %></h1>
                    <p class="tc-practice-quiz-hero-desc"><%: T("Create questions for the selected learning area.","Cipta soalan untuk kawasan pembelajaran yang dipilih.") %></p>
                </div>
            </div>
            <button type="button" class="tc-practice-quiz-btn-settings" onclick="openSettingsModal()">
                <i class="bi bi-gear-fill"></i> <%: T("Settings","Tetapan") %>
            </button>
        </div>
        <div class="tc-practice-quiz-hero-meta">
            <div class="tc-practice-quiz-meta-item">
                <div class="tc-practice-quiz-meta-pill tc-practice-quiz-meta-pill-level"><i class="bi bi-bar-chart-steps"></i></div>
                <div>
                    <span class="tc-practice-quiz-meta-label"><%: T("Level","Tahap") %></span>
                    <span class="tc-practice-quiz-meta-val" id="heroLevel"><asp:Literal ID="litLevel" runat="server" /></span>
                </div>
            </div>
            <div class="tc-practice-quiz-meta-item">
                <div class="tc-practice-quiz-meta-pill tc-practice-quiz-meta-pill-unit"><i class="bi bi-layers-fill"></i></div>
                <div>
                    <span class="tc-practice-quiz-meta-label"><%: T("Unit","Unit") %></span>
                    <span class="tc-practice-quiz-meta-val" id="heroUnit"><asp:Literal ID="litUnit" runat="server" /></span>
                </div>
            </div>
            <div class="tc-practice-quiz-meta-item">
                <div class="tc-practice-quiz-meta-pill tc-practice-quiz-meta-pill-subtopic"><i class="bi bi-bookmark-fill"></i></div>
                <div>
                    <span class="tc-practice-quiz-meta-label"><%: T("Subtopic","Subtopik") %></span>
                    <span class="tc-practice-quiz-meta-val" id="heroSubtopic"><asp:Literal ID="litSubtopic" runat="server" /></span>
                </div>
            </div>
            <div class="tc-practice-quiz-meta-item">
                <div class="tc-practice-quiz-meta-pill tc-practice-quiz-meta-pill-lang"><i class="bi bi-translate"></i></div>
                <div>
                    <span class="tc-practice-quiz-meta-label"><%: T("Language","Bahasa") %></span>
                    <span class="tc-practice-quiz-meta-val" id="heroLanguage"><asp:Literal ID="litLanguage" runat="server" /></span>
                </div>
            </div>
        </div>
    </div>
</div><%-- /.tc-practice-quiz-hero --%>

<%-- Quiz Title --%>
<div class="tc-practice-quiz-title-field">
    <label class="tc-practice-quiz-title-label" id="pqTitleLabel"><%: T("Quiz Title","Tajuk Kuiz") %> *</label>
    <input type="text" id="pqTitleInput" class="tc-practice-quiz-title-input" placeholder="<%: T("Enter quiz title...","Masukkan tajuk kuiz...") %>" maxlength="200" />
    <div id="pqTitleErr" class="tc-practice-quiz-title-err" style="display:none;">
        <i class="bi bi-exclamation-circle-fill" style="font-size:13px;flex-shrink:0;"></i>
        <span id="pqTitleErrMsg"></span>
    </div>
</div>

<%-- Quiz builder --%>
<div class="tc-question-builder-layout">

<%-- Left Nav ? Question Navigator --%>
<div class="tc-question-builder-nav">
    <div class="tc-question-builder-nav-header">
        <div class="tc-question-builder-nav-title"><%: T("Questions","Soalan") %> <span class="tc-question-builder-nav-count" id="navCount">1</span></div>
    </div>
    <div class="tc-question-builder-nav-list" id="qbNavList"></div>
    <div class="tc-question-builder-nav-footer">
        <button type="button" class="tc-question-builder-nav-add" id="pqBtnAdd" onclick="pqAddQuestion()"><%: T("+ Add Question","+ Tambah Soalan") %></button>
    </div>
</div>

<%-- Center Editor --%>
<div class="tc-question-builder-center">
    <%-- Toolbar --%>
    <div class="tc-question-builder-toolbar">
        <div class="tc-question-builder-toolbar-nav">
            <button type="button" id="qbNavPrev" class="tc-question-builder-toolbar-arrow" onclick="pqNavGoTo(window.__PQ_CI-1)"><i class="bi bi-chevron-left"></i></button>
            <span id="qbNavLabel" class="tc-question-builder-toolbar-label"></span>
            <button type="button" id="qbNavNext" class="tc-question-builder-toolbar-arrow" onclick="pqNavGoTo(window.__PQ_CI+1)"><i class="bi bi-chevron-right"></i></button>
        </div>
        <button type="button" class="tc-question-builder-btn tc-question-builder-btn-success" style="margin:0;padding:.55rem 1.2rem;font-size:.82rem;" onclick="return pqSubmitQuiz()"><%: T("Submit Quiz","Hantar Kuiz") %></button>
    </div>

    <div class="tc-question-builder-editor-body">

    <%-- Question Text --%>
    <div class="tc-question-builder-field" style="margin-bottom:1.2rem;">
        <div class="tc-question-builder-label">
            <span><%: T("Question","Soalan") %> *</span>
            <span class="tc-question-builder-char-count" id="pqQCharCount">0 / 500</span>
        </div>
        <div class="tc-question-builder-tc-rte-wrap">
            <div class="tc-question-builder-tc-rte-toolbar">
                <button type="button" class="tc-question-builder-tc-rte-btn" onmousedown="event.preventDefault();pqRteExec('bold')" title="Bold"><i class="bi bi-type-bold"></i></button>
                <button type="button" class="tc-question-builder-tc-rte-btn" onmousedown="event.preventDefault();pqRteExec('italic')" title="Italic"><i class="bi bi-type-italic"></i></button>
                <button type="button" class="tc-question-builder-tc-rte-btn" onmousedown="event.preventDefault();pqRteExec('underline')" title="Underline"><i class="bi bi-type-underline"></i></button>
                <span class="tc-question-builder-tc-rte-sep"></span>
                <button type="button" class="tc-question-builder-tc-rte-btn" onmousedown="event.preventDefault();pqRteExec('insertUnorderedList')" title="Bullet List"><i class="bi bi-list-ul"></i></button>
                <button type="button" class="tc-question-builder-tc-rte-btn" onmousedown="event.preventDefault();pqRteExec('insertOrderedList')" title="Numbered List"><i class="bi bi-list-ol"></i></button>
                <span class="tc-question-builder-tc-rte-sep" id="pqFibSep" style="display:none;"></span>
                <span id="pqBlankCounter" style="display:none;margin-left:auto;font-size:.75rem;font-weight:600;color:#7B7499;"><%: T("Blanks","Kosong") %>: <strong id="pqBlankNum">0</strong> / 4</span>
                <button type="button" id="pqBtnAddBlank" style="display:none;margin-left:6px;padding:.4rem .8rem;font-size:.76rem;" class="tc-fill-blank-add-btn" onclick="pqAddBlank()"><i class="bi bi-plus-square-dotted"></i> <%: T("Add Blank","Tambah Kosong") %></button>
            </div>
            <div id="pqRteEditor" class="tc-question-builder-tc-rte-editor" contenteditable="true" data-placeholder="<%: T("Type your question here...","Taip soalan anda di sini...") %>"></div>
        </div>
        <textarea id="pqTxtQuestion" style="display:none;" maxlength="500"></textarea>
        <div id="pqQTextErr" class="tc-question-builder-err-msg" style="display:none;margin-top:6px;"><i class="bi bi-exclamation-circle-fill" style="font-size:13px;flex-shrink:0;"></i> <span id="pqQTextErrMsg"></span></div>
    </div>

    <%-- Question Image --%>
    <div class="tc-question-builder-img-zone" id="pqImgZone">
        <div class="tc-question-builder-img-upload" onclick="document.getElementById('pqImgInput').click()">
            <div class="tc-question-builder-img-upload-icon"><i class="bi bi-image"></i></div>
            <span class="tc-question-builder-img-upload-text"><%: T("Upload Image","Muat Naik Imej") %></span>
            <span class="tc-question-builder-img-upload-sub"><%: T("Optional ? PNG, JPG, GIF up to 5 MB","Pilihan ? PNG, JPG, GIF sehingga 5 MB") %></span>
        </div>
        <input type="file" id="pqImgInput" accept="image/*" onchange="pqHandleImg(this)" style="display:none;" />
        <div class="tc-question-builder-img-preview" id="pqImgPreview">
            <img id="pqImgPreviewSrc" src="" alt="" />
            <button type="button" class="tc-question-builder-img-remove" onclick="pqRemoveImg()"><i class="bi bi-x"></i></button>
        </div>
    </div>

    <%-- MCQ Options --%>
    <div id="pqSectionMCQ" class="tc-question-builder-answer-section">
        <div class="tc-question-builder-section-header">
            <div class="tc-question-builder-section-header-icon"><i class="bi bi-ui-radios"></i></div>
            <span class="tc-question-builder-section-header-text" id="pqOptsLabel"><%: T("Options","Pilihan") %></span>
            <span class="tc-question-builder-section-header-sub"><%: T("Select one correct answer","Pilih satu jawapan betul") %></span>
            <div class="tc-question-builder-section-divider"></div>
        </div>
        <div class="tc-question-builder-opts" id="pqMcqOpts">
            <div class="tc-question-builder-opt"><div class="tc-question-builder-opt-band">A</div><div class="tc-question-builder-opt-body"><input type="text" class="tc-question-builder-opt-input tc-practice-quiz-opt-text" placeholder="<%: T("Enter option A...","Masukkan pilihan A...") %>" /></div><div class="tc-question-builder-opt-selector" onclick="pqSelectCorrect(this)"></div></div>
            <div class="tc-question-builder-opt"><div class="tc-question-builder-opt-band">B</div><div class="tc-question-builder-opt-body"><input type="text" class="tc-question-builder-opt-input tc-practice-quiz-opt-text" placeholder="<%: T("Enter option B...","Masukkan pilihan B...") %>" /></div><div class="tc-question-builder-opt-selector" onclick="pqSelectCorrect(this)"></div></div>
            <div class="tc-question-builder-opt"><div class="tc-question-builder-opt-band">C</div><div class="tc-question-builder-opt-body"><input type="text" class="tc-question-builder-opt-input tc-practice-quiz-opt-text" placeholder="<%: T("Enter option C...","Masukkan pilihan C...") %>" /></div><div class="tc-question-builder-opt-selector" onclick="pqSelectCorrect(this)"></div></div>
            <div class="tc-question-builder-opt"><div class="tc-question-builder-opt-band">D</div><div class="tc-question-builder-opt-body"><input type="text" class="tc-question-builder-opt-input tc-practice-quiz-opt-text" placeholder="<%: T("Enter option D...","Masukkan pilihan D...") %>" /></div><div class="tc-question-builder-opt-selector" onclick="pqSelectCorrect(this)"></div></div>
        </div>
        <div id="pqMcqErr" class="tc-question-builder-err-msg" style="display:none;"><i class="bi bi-exclamation-circle-fill" style="font-size:13px;flex-shrink:0;"></i> <span id="pqMcqErrMsg"></span></div>
    </div>

    <%-- True/False --%>
    <div id="pqSectionTF" class="tc-question-builder-answer-section" style="display:none;">
        <div class="tc-question-builder-section-header">
            <div class="tc-question-builder-section-header-icon"><i class="bi bi-toggles"></i></div>
            <span class="tc-question-builder-section-header-text"><%: T("Select the correct answer","Pilih jawapan yang betul") %></span>
            <div class="tc-question-builder-section-divider"></div>
        </div>
        <div class="tc-question-builder-tf-grid">
            <label class="tc-question-builder-tf-card" id="pqTfTrue"><input type="radio" name="pqTfAnswer" value="A" onchange="pqUpdateTF()"/><i class="bi bi-check-circle-fill"></i><span id="pqTfTrueLabel">TRUE</span></label>
            <label class="tc-question-builder-tf-card" id="pqTfFalse"><input type="radio" name="pqTfAnswer" value="B" onchange="pqUpdateTF()"/><i class="bi bi-x-circle-fill"></i><span id="pqTfFalseLabel">FALSE</span></label>
        </div>
        <div id="pqTfErr" class="tc-question-builder-err-msg" style="display:none;"><i class="bi bi-exclamation-circle-fill" style="font-size:13px;flex-shrink:0;"></i> <span id="pqTfErrMsg"></span></div>
    </div>

    <%-- Multiselect --%>
    <div id="pqSectionMS" class="tc-question-builder-answer-section" style="display:none;">
        <div class="tc-question-builder-section-header">
            <div class="tc-question-builder-section-header-icon"><i class="bi bi-check2-square"></i></div>
            <span class="tc-question-builder-section-header-text"><%: T("Select all correct answers","Pilih semua jawapan betul") %></span>
            <span class="tc-question-builder-ms-count" id="pqMsCount" style="margin-left:0;">0 <%: T("selected","dipilih") %></span>
            <div class="tc-question-builder-section-divider"></div>
        </div>
        <div class="tc-question-builder-opts" id="pqMsOpts">
            <div class="tc-question-builder-opt tc-question-builder-ms-opt"><div class="tc-question-builder-opt-band">A</div><div class="tc-question-builder-opt-body"><input type="checkbox" class="tc-practice-quiz-ms-check" onchange="pqUpdateMS()"/><input type="text" class="tc-question-builder-opt-input tc-practice-quiz-ms-text" placeholder="<%: T("Type option A...","Taip pilihan A...") %>" /></div></div>
            <div class="tc-question-builder-opt tc-question-builder-ms-opt"><div class="tc-question-builder-opt-band">B</div><div class="tc-question-builder-opt-body"><input type="checkbox" class="tc-practice-quiz-ms-check" onchange="pqUpdateMS()"/><input type="text" class="tc-question-builder-opt-input tc-practice-quiz-ms-text" placeholder="<%: T("Type option B...","Taip pilihan B...") %>" /></div></div>
            <div class="tc-question-builder-opt tc-question-builder-ms-opt"><div class="tc-question-builder-opt-band">C</div><div class="tc-question-builder-opt-body"><input type="checkbox" class="tc-practice-quiz-ms-check" onchange="pqUpdateMS()"/><input type="text" class="tc-question-builder-opt-input tc-practice-quiz-ms-text" placeholder="<%: T("Type option C...","Taip pilihan C...") %>" /></div></div>
            <div class="tc-question-builder-opt tc-question-builder-ms-opt"><div class="tc-question-builder-opt-band">D</div><div class="tc-question-builder-opt-body"><input type="checkbox" class="tc-practice-quiz-ms-check" onchange="pqUpdateMS()"/><input type="text" class="tc-question-builder-opt-input tc-practice-quiz-ms-text" placeholder="<%: T("Type option D...","Taip pilihan D...") %>" /></div></div>
        </div>
        <div id="pqMsErr" class="tc-question-builder-err-msg" style="display:none;"><i class="bi bi-exclamation-circle-fill" style="font-size:13px;flex-shrink:0;"></i> <span id="pqMsErrMsg"></span></div>
    </div>

    <%-- Drag & Drop --%>
    <div id="pqSectionFIB" class="tc-question-builder-answer-section" style="display:none;">

        <%-- Answer Options --%>
        <div class="tc-fill-blank-section-label" style="font-size:.92rem;font-weight:800;"><%: T("Answer Options","Pilihan Jawapan") %> * <span class="tc-fill-blank-sub-label">(<%: T("Max 4 words","Maks 4 perkataan") %>)</span></div>
        <div class="tc-question-builder-tc-fill-blank-words" id="pqFibWords">
            <div class="tc-question-builder-tc-fill-blank-word"><span class="tc-question-builder-tc-fill-blank-num">1</span><input type="text" class="tc-question-builder-opt-input tc-practice-quiz-tc-fill-blank-word" placeholder="<%: T("Word 1","Perkataan 1") %>" oninput="pqOnFibWordChange()" /></div>
            <div class="tc-question-builder-tc-fill-blank-word"><span class="tc-question-builder-tc-fill-blank-num">2</span><input type="text" class="tc-question-builder-opt-input tc-practice-quiz-tc-fill-blank-word" placeholder="<%: T("Word 2","Perkataan 2") %>" oninput="pqOnFibWordChange()" /></div>
            <div class="tc-question-builder-tc-fill-blank-word"><span class="tc-question-builder-tc-fill-blank-num">3</span><input type="text" class="tc-question-builder-opt-input tc-practice-quiz-tc-fill-blank-word" placeholder="<%: T("Word 3","Perkataan 3") %>" oninput="pqOnFibWordChange()" /></div>
            <div class="tc-question-builder-tc-fill-blank-word"><span class="tc-question-builder-tc-fill-blank-num">4</span><input type="text" class="tc-question-builder-opt-input tc-practice-quiz-tc-fill-blank-word" placeholder="<%: T("Word 4","Perkataan 4") %>" oninput="pqOnFibWordChange()" /></div>
        </div>
        <div id="pqDndBlankErr" class="tc-question-builder-err-msg" style="display:none;"><i class="bi bi-exclamation-circle-fill" style="font-size:13px;flex-shrink:0;"></i> <span id="pqDndBlankErrMsg"></span></div>
        <div id="pqDndWordsErr" class="tc-question-builder-err-msg" style="display:none;"><i class="bi bi-exclamation-circle-fill" style="font-size:13px;flex-shrink:0;"></i> <span id="pqDndWordsErrMsg"></span></div>
        <div id="pqFibMappingSection" class="tc-fill-blank-mapping-wrap" style="display:none;">
            <div class="tc-fill-blank-section-label" style="font-size:.92rem;font-weight:800;"><i class="bi bi-arrow-left-right"></i> <%: T("Correct Answer Mapping","Pemetaan Jawapan Betul") %> *</div>
            <div class="tc-question-builder-tc-fill-blank-mappings" id="pqFibMappings"></div>
            <div class="tc-fill-blank-warning" id="pqFibMapError" style="display:none;margin-top:6px;">
                <i class="bi bi-exclamation-circle-fill"></i> <%: T("Each blank must map to a unique word.","Setiap kosong mesti dipetakan kepada perkataan unik.") %>
            </div>
            <div id="pqDndMapErr" class="tc-question-builder-err-msg" style="display:none;margin-top:6px;"><i class="bi bi-exclamation-circle-fill" style="font-size:13px;flex-shrink:0;"></i> <span id="pqDndMapErrMsg"></span></div>
        </div>
        <div id="pqFibPreviewSection" class="tc-fill-blank-preview-wrap" style="display:none;">
            <div class="tc-question-builder-tc-fill-blank-preview-card">
                <div class="tc-question-builder-tc-fill-blank-preview-title"><i class="bi bi-eye"></i> <%: T("Student Preview","Pratonton Pelajar") %></div>
                <div class="tc-question-builder-tc-fill-blank-preview-sub"><%: T("Students will drag the correct words into the blanks below.","Pelajar akan menyeret perkataan betul ke dalam kosong di bawah.") %></div>
                <div class="tc-question-builder-tc-fill-blank-preview-text" id="pqFibPreviewText"></div>
                <div style="margin-top:.75rem;">
                    <div style="font-size:.72rem;font-weight:600;color:#7B7499;margin-bottom:6px;text-transform:uppercase;letter-spacing:.5px;"><%: T("Available Words","Perkataan Tersedia") %></div>
                    <div class="tc-question-builder-tc-fill-blank-preview-words" id="pqFibPreviewWords"></div>
                </div>
            </div>
        </div>
    </div>

    <%-- Explanations --%>
    <div class="tc-question-builder-section-header" style="margin-top:.5rem;">
        <div class="tc-question-builder-section-header-icon"><i class="bi bi-chat-quote-fill"></i></div>
        <span class="tc-question-builder-section-header-text"><%: T("Explanations","Penjelasan") %></span>
        <div class="tc-question-builder-section-divider"></div>
    </div>
    <div class="tc-question-builder-exp-block tc-question-builder-exp-correct">
        <div class="tc-question-builder-exp-block-header">
            <div class="tc-question-builder-exp-block-icon"><i class="bi bi-check-circle-fill"></i></div>
            <span class="tc-question-builder-exp-block-label" id="pqCeLabel"><%: T("Correct Explanation","Penjelasan Betul") %> *</span>
            <span class="tc-question-builder-exp-block-count" id="pqCeCount">0 / 500</span>
        </div>
        <textarea id="pqTxtCE" class="tc-question-builder-input tc-question-builder-textarea" maxlength="500" placeholder="<%: T("Explain why this answer is correct...","Terangkan mengapa jawapan ini betul...") %>"></textarea>
        <div id="pqCeErr" class="tc-question-builder-err-msg" style="display:none;margin:6px 1.1rem 0;"><i class="bi bi-exclamation-circle-fill" style="font-size:13px;flex-shrink:0;"></i> <span id="pqCeErrMsg"></span></div>
    </div>
    <div class="tc-question-builder-exp-block tc-question-builder-exp-wrong">
        <div class="tc-question-builder-exp-block-header">
            <div class="tc-question-builder-exp-block-icon"><i class="bi bi-x-circle-fill"></i></div>
            <span class="tc-question-builder-exp-block-label" id="pqWeLabel"><%: T("Wrong Explanation","Penjelasan Salah") %> *</span>
            <span class="tc-question-builder-exp-block-count" id="pqWeCount">0 / 500</span>
        </div>
        <textarea id="pqTxtWE" class="tc-question-builder-input tc-question-builder-textarea" maxlength="500" placeholder="<%: T("Explain why the other answers are incorrect...","Terangkan mengapa jawapan lain salah...") %>"></textarea>
        <div id="pqWeErr" class="tc-question-builder-err-msg" style="display:none;margin:6px 1.1rem 0;"><i class="bi bi-exclamation-circle-fill" style="font-size:13px;flex-shrink:0;"></i> <span id="pqWeErrMsg"></span></div>
    </div>

    </div><%-- /.tc-question-builder-editor-body --%>
</div><%-- /.tc-question-builder-center --%>

<%-- Right Props --%>
<div class="tc-question-builder-props">
    <div class="tc-question-builder-props-header">
        <div class="tc-question-builder-props-header-icon"><i class="bi bi-sliders"></i></div>
        <div class="tc-question-builder-props-title"><%: T("Properties","Sifat") %></div>
    </div>
    <div class="tc-question-builder-props-body">
        <div class="tc-question-builder-prop-field">
            <div class="tc-question-builder-prop-label"><span class="tc-question-builder-prop-label-icon type"><i class="bi bi-ui-checks"></i></span> <%: T("Question Type","Jenis Soalan") %></div>
            <select id="pqDdlType" class="tc-question-builder-input" onchange="pqSwitchType()">
                <option value="MCQ"><%: T("MCQ","Aneka Pilihan") %></option>
                <option value="True/False"><%: T("True / False","Betul / Salah") %></option>
                <option value="Multiselect"><%: T("Multiselect","Pelbagai Pilihan") %></option>
                <option value="Drag & Drop"><%: T("Drag & Drop","Seret & Letak") %></option>
            </select>
        </div>
        <div class="tc-question-builder-prop-field">
            <div class="tc-question-builder-prop-label"><span class="tc-question-builder-prop-label-icon diff"><i class="bi bi-bar-chart-fill"></i></span> <%: T("Difficulty","Kesukaran") %></div>
            <select id="pqDdlDiff" class="tc-question-builder-input">
                <option value="Easy"><%: T("Easy","Mudah") %></option>
                <option value="Medium" selected><%: T("Medium","Sederhana") %></option>
                <option value="Hard"><%: T("Hard","Sukar") %></option>
            </select>
        </div>
    </div>
</div>

</div><%-- /.tc-question-builder-layout --%>


<div id="pqToast" class="tc-practice-quiz-toast-container"></div>

<%-- ------------------------------------------------------
     SETTINGS MODAL
     ------------------------------------------------------ --%>
<div id="pqSettingsModal" class="tc-practice-quiz-modal-overlay" style="display:none;" onclick="if(event.target===this)closeSettingsModal()">
    <div class="tc-practice-quiz-modal">
        <div class="tc-practice-quiz-modal-header">
            <div>
                <h3><%: T("Quiz Settings","Tetapan Kuiz") %></h3>
                <p><%: T("Change the learning area for this practice quiz.","Tukar kawasan pembelajaran untuk kuiz latihan ini.") %></p>
            </div>
            <button type="button" class="tc-practice-quiz-modal-close" onclick="closeSettingsModal()">?</button>
        </div>
        <div class="tc-practice-quiz-modal-body">
            <div class="tc-practice-quiz-form-row">
                <label class="tc-practice-quiz-form-label"><%: T("Level","Tahap") %> *</label>
                <select id="stgLevel" class="tc-practice-quiz-form-select" onchange="stgOnLevelChange(this.value)">
                    <option value=""><%: T("? Select Level ?","? Pilih Tahap ?") %></option>
                </select>
            </div>
            <div class="tc-practice-quiz-form-row">
                <label class="tc-practice-quiz-form-label"><%: T("Unit","Unit") %> *</label>
                <select id="stgUnit" class="tc-practice-quiz-form-select" onchange="stgOnUnitChange(this.value)" disabled>
                    <option value=""><%: T("? Select Unit ?","? Pilih Unit ?") %></option>
                </select>
            </div>
            <div class="tc-practice-quiz-form-row">
                <label class="tc-practice-quiz-form-label"><%: T("Subtopic","Subtopik") %> *</label>
                <select id="stgSubtopic" class="tc-practice-quiz-form-select" onchange="_stgCheckApply()" disabled>
                    <option value=""><%: T("? Select Subtopic ?","? Pilih Subtopik ?") %></option>
                </select>
            </div>
            <div class="tc-practice-quiz-form-row" style="margin-bottom:0;">
                <label class="tc-practice-quiz-form-label"><%: T("Language","Bahasa") %> *</label>
                <select id="stgLanguage" class="tc-practice-quiz-form-select" onchange="_stgCheckApply()">
                    <option value=""><%: T("? Select Language ?","? Pilih Bahasa ?") %></option>
                    <option value="EN">English</option>
                    <option value="BM">Bahasa Melayu</option>
                </select>
            </div>
        </div>
        <div class="tc-practice-quiz-modal-footer">
            <button type="button" class="tc-practice-quiz-btn-cancel" onclick="closeSettingsModal()"><%: T("Cancel","Batal") %></button>
            <button type="button" id="stgApplyBtn" class="tc-practice-quiz-btn-apply" disabled style="opacity:.5;" onclick="stgApply()"><%: T("Apply Changes","Guna Perubahan") %></button>
        </div>
    </div>
</div>

<%-- ------------------------------------------------------
     CONFIRM RESET MODAL
     ------------------------------------------------------ --%>
<div id="pqConfirmModal" class="tc-practice-quiz-confirm-overlay" style="display:none;" onclick="if(event.target===this)closeConfirmModal()">
    <div class="tc-practice-quiz-confirm-modal">
        <div class="tc-practice-quiz-modal-header">
            <div>
                <h3><%: T("Confirm Settings Change","Sahkan Perubahan Tetapan") %></h3>
            </div>
            <button type="button" class="tc-practice-quiz-modal-close" onclick="closeConfirmModal()">?</button>
        </div>
        <div class="tc-practice-quiz-modal-body">
            <p style="font-size:.88rem;color:#374151;line-height:1.65;margin:0;"><%: T("Changing these settings may reset your current unsaved quiz data. Continue?","Menukar tetapan ini mungkin menetapkan semula data kuiz anda yang belum disimpan. Teruskan?") %></p>
        </div>
        <div class="tc-practice-quiz-modal-footer">
            <button type="button" class="tc-practice-quiz-btn-cancel" onclick="closeConfirmModal()"><%: T("Cancel","Batal") %></button>
            <button type="button" class="tc-practice-quiz-btn-apply" onclick="stgApplyConfirmed()"><%: T("Continue","Teruskan") %></button>
        </div>
    </div>
</div>

<%-- Hidden fields to track current values server-side --%>
<asp:HiddenField ID="hidLevelId"    runat="server" />
<asp:HiddenField ID="hidUnitId"     runat="server" />
<asp:HiddenField ID="hidSubtopicId" runat="server" />
<asp:HiddenField ID="hidLanguage"   runat="server" />
<asp:HiddenField ID="hidQuizTitle"  runat="server" />
<asp:HiddenField ID="hidQuestionsJson" runat="server" />
<asp:HiddenField ID="hidSubmitSuccess" runat="server" />
<asp:Button ID="btnSubmitPQ" runat="server" Style="display:none;" OnClick="btnSubmitPQ_Click" CausesValidation="false" />

</asp:Panel><%-- /pnlMain --%>

</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
var __PQ_SITE_LANG='<%= CurrentLanguage %>';
function _pqT(en,bm){return __PQ_SITE_LANG==='BM'?bm:en;}

// -- Tracked current selections ---------------------------------
var _pqCur = { levelId:'', levelName:'', unitId:'', unitName:'', subtopicId:'', subtopicName:'', language:'', languageName:'' };

window.addEventListener('load', function() {
    var hLv = document.getElementById('<%=hidLevelId.ClientID%>');
    var hUn = document.getElementById('<%=hidUnitId.ClientID%>');
    var hSt = document.getElementById('<%=hidSubtopicId.ClientID%>');
    var hLg = document.getElementById('<%=hidLanguage.ClientID%>');
    if (!hLv) return; // not on main panel
    _pqCur.levelId      = hLv.value;
    _pqCur.unitId       = hUn.value;
    _pqCur.subtopicId   = hSt.value;
    _pqCur.language     = hLg.value;
    _pqCur.levelName    = (document.getElementById('heroLevel')    || {}).textContent || '';
    _pqCur.unitName     = (document.getElementById('heroUnit')     || {}).textContent || '';
    _pqCur.subtopicName = (document.getElementById('heroSubtopic') || {}).textContent || '';
    _pqCur.languageName = (document.getElementById('heroLanguage') || {}).textContent || '';
    // Trim whitespace from Literal renders
    _pqCur.levelName    = _pqCur.levelName.trim();
    _pqCur.unitName     = _pqCur.unitName.trim();
    _pqCur.subtopicName = _pqCur.subtopicName.trim();
    _pqCur.languageName = _pqCur.languageName.trim();
});

// -- Settings modal open / close --------------------------------
function openSettingsModal() {
    var lvDd = document.getElementById('stgLevel');
    if (lvDd.options.length <= 1) {
        lvDd.innerHTML = '<option value="">Loading\u2026</option>';
        var xhr = new XMLHttpRequest();
        xhr.open('GET', 'createPracticeQuiz.aspx?handler=levels', true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== 4 || xhr.status !== 200) return;
            try {
                var data = JSON.parse(xhr.responseText);
                lvDd.innerHTML = '<option value="">? Select Level ?</option>';
                for (var i = 0; i < data.length; i++) {
                    var o = document.createElement('option');
                    o.value = data[i].id; o.textContent = data[i].name;
                    if (data[i].id === _pqCur.levelId) o.selected = true;
                    lvDd.appendChild(o);
                }
                if (_pqCur.levelId) _stgLoadUnits(_pqCur.levelId, _pqCur.unitId);
            } catch(e) { lvDd.innerHTML = '<option value="">Error</option>'; }
        };
        xhr.send();
    } else {
        lvDd.value = _pqCur.levelId;
        _stgLoadUnits(_pqCur.levelId, _pqCur.unitId);
    }
    document.getElementById('stgLanguage').value = _pqCur.language;
    _stgCheckApply();
    document.getElementById('pqSettingsModal').style.display = 'flex';
}

function closeSettingsModal() {
    document.getElementById('pqSettingsModal').style.display = 'none';
}

// -- Cascading loads --------------------------------------------
function stgOnLevelChange(levelId) {
    var stDd = document.getElementById('stgSubtopic');
    stDd.innerHTML = '<option value="">? Select Subtopic ?</option>';
    stDd.disabled = true;
    _stgCheckApply();
    _stgLoadUnits(levelId, '');
}

function _stgLoadUnits(levelId, preselect) {
    var unDd = document.getElementById('stgUnit');
    var stDd = document.getElementById('stgSubtopic');
    stDd.innerHTML = '<option value="">? Select Subtopic ?</option>';
    stDd.disabled = true;
    unDd.innerHTML = '<option value="">? Select Unit ?</option>';
    _stgCheckApply();
    if (!levelId) { unDd.disabled = true; return; }
    unDd.innerHTML = '<option value="">Loading\u2026</option>';
    unDd.disabled = true;
    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'createPracticeQuiz.aspx?handler=units&levelId=' + encodeURIComponent(levelId), true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState !== 4 || xhr.status !== 200) return;
        try {
            var data = JSON.parse(xhr.responseText);
            unDd.innerHTML = '<option value="">? Select Unit ?</option>';
            for (var i = 0; i < data.length; i++) {
                var o = document.createElement('option');
                o.value = data[i].id; o.textContent = data[i].name;
                if (data[i].id === preselect) o.selected = true;
                unDd.appendChild(o);
            }
            unDd.disabled = false;
            if (preselect) _stgLoadSubtopics(preselect, _pqCur.subtopicId);
            else _stgCheckApply();
        } catch(e) { unDd.innerHTML = '<option value="">Error</option>'; unDd.disabled = false; }
    };
    xhr.send();
}

function stgOnUnitChange(unitId) {
    _stgLoadSubtopics(unitId, '');
}

function _stgLoadSubtopics(unitId, preselect) {
    var stDd = document.getElementById('stgSubtopic');
    stDd.innerHTML = '<option value="">? Select Subtopic ?</option>';
    stDd.disabled = true;
    _stgCheckApply();
    if (!unitId) return;
    stDd.innerHTML = '<option value="">Loading\u2026</option>';
    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'createPracticeQuiz.aspx?handler=subtopics&unitId=' + encodeURIComponent(unitId), true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState !== 4 || xhr.status !== 200) return;
        try {
            var data = JSON.parse(xhr.responseText);
            stDd.innerHTML = '<option value="">? Select Subtopic ?</option>';
            for (var i = 0; i < data.length; i++) {
                var o = document.createElement('option');
                o.value = data[i].id; o.textContent = data[i].name;
                if (data[i].id === preselect) o.selected = true;
                stDd.appendChild(o);
            }
            stDd.disabled = false;
            _stgCheckApply();
        } catch(e) { stDd.innerHTML = '<option value="">Error</option>'; stDd.disabled = false; }
    };
    xhr.send();
}

function _stgCheckApply() {
    var ok = !!(document.getElementById('stgLevel').value &&
                document.getElementById('stgUnit').value &&
                document.getElementById('stgSubtopic').value &&
                document.getElementById('stgLanguage').value);
    var btn = document.getElementById('stgApplyBtn');
    btn.disabled = !ok;
    btn.style.opacity = ok ? '1' : '.5';
    btn.style.pointerEvents = ok ? 'auto' : 'none';
}
// expose for inline onchange
function stgCheckApply() { _stgCheckApply(); }

// -- Apply ------------------------------------------------------
var _stgPending = null;

function stgApply() {
    var lv = document.getElementById('stgLevel');
    var un = document.getElementById('stgUnit');
    var st = document.getElementById('stgSubtopic');
    var lg = document.getElementById('stgLanguage');
    if (!lv.value || !un.value || !st.value || !lg.value) return;

    _stgPending = {
        levelId:      lv.value,
        levelName:    lv.options[lv.selectedIndex].text,
        unitId:       un.value,
        unitName:     un.options[un.selectedIndex].text,
        subtopicId:   st.value,
        subtopicName: st.options[st.selectedIndex].text,
        language:     lg.value,
        languageName: lg.options[lg.selectedIndex].text
    };

    var changed = (_stgPending.levelId    !== _pqCur.levelId    ||
                   _stgPending.unitId     !== _pqCur.unitId     ||
                   _stgPending.subtopicId !== _pqCur.subtopicId ||
                   _stgPending.language   !== _pqCur.language);

    if (changed) {
        // Warn before discarding unsaved data
        closeSettingsModal();
        document.getElementById('pqConfirmModal').style.display = 'flex';
    } else {
        // Nothing changed ? just close
        closeSettingsModal();
        _stgPending = null;
    }
}

function closeConfirmModal() {
    document.getElementById('pqConfirmModal').style.display = 'none';
    _stgPending = null;
}

function stgApplyConfirmed() {
    document.getElementById('pqConfirmModal').style.display = 'none';
    if (!_stgPending) return;

    // -- Update hero spans --
    document.getElementById('heroLevel').textContent    = _stgPending.levelName;
    document.getElementById('heroUnit').textContent     = _stgPending.unitName;
    document.getElementById('heroSubtopic').textContent = _stgPending.subtopicName;
    document.getElementById('heroLanguage').textContent = _stgPending.languageName;

    // -- Update hidden fields --
    document.getElementById('<%=hidLevelId.ClientID%>').value    = _stgPending.levelId;
    document.getElementById('<%=hidUnitId.ClientID%>').value     = _stgPending.unitId;
    document.getElementById('<%=hidSubtopicId.ClientID%>').value = _stgPending.subtopicId;
    document.getElementById('<%=hidLanguage.ClientID%>').value   = _stgPending.language;

    // -- Sync in-memory state --
    _pqCur.levelId      = _stgPending.levelId;
    _pqCur.levelName    = _stgPending.levelName;
    _pqCur.unitId       = _stgPending.unitId;
    _pqCur.unitName     = _stgPending.unitName;
    _pqCur.subtopicId   = _stgPending.subtopicId;
    _pqCur.subtopicName = _stgPending.subtopicName;
    _pqCur.language     = _stgPending.language;
    _pqCur.languageName = _stgPending.languageName;

    // -- Update URL without reload --
    if (window.history && window.history.replaceState) {
        window.history.replaceState(null, '',
            'createPracticeQuiz.aspx?levelId='    + encodeURIComponent(_stgPending.levelId)
            + '&unitId='     + encodeURIComponent(_stgPending.unitId)
            + '&subtopicId=' + encodeURIComponent(_stgPending.subtopicId)
            + '&language='   + encodeURIComponent(_stgPending.language));
    }
    _stgPending = null;
}

/* --- PRACTICE QUIZ ? QUESTION BUILDER ENGINE ------------- */
window.__PQ_QD=[{qEN:'',qBM:'',aEN:'',aBM:'',bEN:'',bBM:'',cEN:'',cBM:'',dEN:'',dBM:'',ceEN:'',ceBM:'',weEN:'',weBM:'',correct:'',type:'MCQ',diff:'Medium',img:'',imgDataUrl:'',msAEN:'',msABM:'',msBEN:'',msBBM:'',msCEN:'',msCBM:'',msDEN:'',msDBM:'',msChk:'',fibEN:['','','',''],fibBM:['','','',''],fibIdx:{},fibMapEN:[],fibMapBM:[]}];
window.__PQ_CI=0;
/* Content language ? determined by the hero Language field, NOT by a tab */
window.__PQ_CT=(document.getElementById('<%=hidLanguage.ClientID%>')||{}).value||'EN';

function pqEmptyQ(){return{qEN:'',qBM:'',aEN:'',aBM:'',bEN:'',bBM:'',cEN:'',cBM:'',dEN:'',dBM:'',ceEN:'',ceBM:'',weEN:'',weBM:'',correct:'',type:'MCQ',diff:'Medium',img:'',imgDataUrl:'',msAEN:'',msABM:'',msBEN:'',msBBM:'',msCEN:'',msCBM:'',msDEN:'',msDBM:'',msChk:'',fibEN:['','','',''],fibBM:['','','',''],fibIdx:{},fibMapEN:[],fibMapBM:[]};}

/* -- RTE helpers -- */
function pqRteExec(cmd){document.execCommand(cmd,false,null);pqRteSync();}
function pqRteSync(){
    var ed=document.getElementById('pqRteEditor'),ta=document.getElementById('pqTxtQuestion');
    if(ed&&ta){
        var clone=ed.cloneNode(true);
        clone.querySelectorAll('.tc-rte-blank-chip').forEach(function(chip){
            chip.replaceWith(chip.getAttribute('data-blank'));
        });
        ta.value=clone.innerText||'';
    }
    var cc=document.getElementById('pqQCharCount');
    if(cc&&ed)cc.textContent=(ed.textContent||'').length+' / 500';
    pqUpdateBlankCount();
}
function pqRteGetText(){
    var ed=document.getElementById('pqRteEditor');
    if(!ed)return'';
    var clone=ed.cloneNode(true);
    clone.querySelectorAll('.tc-rte-blank-chip').forEach(function(chip){
        chip.replaceWith(chip.getAttribute('data-blank'));
    });
    return clone.innerText||'';
}
function pqRteSetContent(text){
    var ed=document.getElementById('pqRteEditor');
    if(!ed)return;
    if(text&&/\[Blank \d\]/.test(text)){
        var html=text.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
        html=html.replace(/\[Blank (\d)\]/g,'<span class="tc-rte-blank-chip" contenteditable="false" data-blank="[Blank $1]">_______</span>');
        ed.innerHTML=html;
    }else{
        ed.innerText=text||'';
    }
    pqRteSync();
}

/* -- Capture & Populate -- */
function pqCapture(){
    var q=window.__PQ_QD[window.__PQ_CI],tab=window.__PQ_CT;
    pqRteSync();
    var text=pqRteGetText();
    if(tab==='EN'){q.qEN=text;} else{q.qBM=text;}
    var opts=document.querySelectorAll('#pqMcqOpts .tc-practice-quiz-opt-text');
    var letters=['a','b','c','d'];
    opts.forEach(function(inp,i){q[letters[i]+(tab==='EN'?'EN':'BM')]=inp.value;});
    var ce=document.getElementById('pqTxtCE'),we=document.getElementById('pqTxtWE');
    if(tab==='EN'){q.ceEN=ce?ce.value:'';q.weEN=we?we.value:'';} else{q.ceBM=ce?ce.value:'';q.weBM=we?we.value:'';}
    q.type=document.getElementById('pqDdlType').value;
    q.diff=document.getElementById('pqDdlDiff').value;
    /* Multiselect */
    var msInputs=document.querySelectorAll('#pqMsOpts .tc-practice-quiz-ms-text');
    var msKeys=(tab==='EN')?['msAEN','msBEN','msCEN','msDEN']:['msABM','msBBM','msCBM','msDBM'];
    msInputs.forEach(function(inp,i){if(msKeys[i])q[msKeys[i]]=inp.value;});
    var msChecked=[];
    document.querySelectorAll('#pqMsOpts .tc-practice-quiz-ms-check').forEach(function(cb,i){if(cb.checked)msChecked.push(['A','B','C','D'][i]);});
    q.msChk=msChecked.join(',');
    /* True/False */
    var tfR=document.querySelector('input[name="pqTfAnswer"]:checked');
    if(q.type==='True/False'&&tfR)q.correct=tfR.value;
    /* Drag & Drop word bank */
    var fibInputs=document.querySelectorAll('#pqFibWords .tc-practice-quiz-tc-fill-blank-word');
    var fibArr=[];fibInputs.forEach(function(inp){fibArr.push(inp.value||'');});
    if(tab==='EN')q.fibEN=fibArr; else q.fibBM=fibArr;
    /* Drag & Drop mappings — capture index map and resolved word text */
    var fibWordInputsAll=document.querySelectorAll('#pqFibWords .tc-practice-quiz-tc-fill-blank-word');
    var allWords=[];fibWordInputsAll.forEach(function(inp){allWords.push(inp.value||'');});
    var fibIdxMap={};
    var fibMappings=[];
    document.querySelectorAll('#pqFibMappings .tc-practice-quiz-tc-fill-blank-map-dd').forEach(function(sel){
        fibIdxMap[sel.dataset.blank]=sel.value||'';
        var idx=sel.value?parseInt(sel.value,10)-1:-1;
        fibMappings.push(idx>=0&&allWords[idx]?allWords[idx]:'');
    });
    q.fibIdx=fibIdxMap;
    if(tab==='EN')q.fibMapEN=fibMappings; else q.fibMapBM=fibMappings;
}

function pqPopulate(q,tab){
    var isEN=(tab==='EN');
    pqRteSetContent(isEN?q.qEN:q.qBM);
    var opts=document.querySelectorAll('#pqMcqOpts .tc-practice-quiz-opt-text');
    var vals=isEN?[q.aEN,q.bEN,q.cEN,q.dEN]:[q.aBM,q.bBM,q.cBM,q.dBM];
    opts.forEach(function(inp,i){inp.value=vals[i]||'';});
    document.getElementById('pqTxtCE').value=isEN?q.ceEN||'':q.ceBM||'';
    document.getElementById('pqTxtWE').value=isEN?q.weEN||'':q.weBM||'';
    document.getElementById('pqDdlType').value=q.type||'MCQ';
    document.getElementById('pqDdlDiff').value=q.diff||'Medium';
    pqSwitchType();pqUpdateCorrectUI(q);pqUpdateCharCounts();
    /* Multiselect */
    var msInputs=document.querySelectorAll('#pqMsOpts .tc-practice-quiz-ms-text');
    var msVals=isEN?[q.msAEN,q.msBEN,q.msCEN,q.msDEN]:[q.msABM,q.msBBM,q.msCBM,q.msDBM];
    msInputs.forEach(function(inp,i){inp.value=msVals[i]||'';});
    var chkStr=q.msChk||'';var chkLetters=chkStr?chkStr.split(','):[];
    document.querySelectorAll('#pqMsOpts .tc-practice-quiz-ms-check').forEach(function(cb,i){cb.checked=chkLetters.indexOf(['A','B','C','D'][i])>-1;});
    pqUpdateMS();
    /* True/False */
    document.querySelectorAll('input[name="pqTfAnswer"]').forEach(function(r){r.checked=(q.type==='True/False'&&r.value===q.correct);});
    pqUpdateTF();
    /* Drag & Drop word bank */
    var fibInputs=document.querySelectorAll('#pqFibWords .tc-practice-quiz-tc-fill-blank-word');
    var fibVals=isEN?(q.fibEN||['','','','']):(q.fibBM||['','','','']);
    fibInputs.forEach(function(inp,i){inp.value=fibVals[i]||'';});
    /* Rebuild D&D mappings + preview */
    if(q.type==='Drag & Drop')pqUpdateFibUI();
    /* Image */
    var imgPreview=document.getElementById('pqImgPreview');
    var imgSrc=document.getElementById('pqImgPreviewSrc');
    var imgUpload=document.querySelector('#pqImgZone .tc-question-builder-img-upload');
    if(q.imgDataUrl){
        imgSrc.src=q.imgDataUrl;
        imgPreview.style.display='block';
        imgUpload.style.display='none';
    }else{
        imgPreview.style.display='none';
        imgSrc.src='';
        imgUpload.style.display='flex';
    }
    document.getElementById('pqImgInput').value='';
    /* Labels */
    pqUpdateLabels();
}

/* -- Navigation -- */
function pqNavGoTo(idx){
    if(idx<0||idx>=window.__PQ_QD.length)return;
    pqCapture();
    pqClearInlineErr();
    window.__PQ_CI=idx;
    pqPopulate(window.__PQ_QD[idx],window.__PQ_CT);
    pqRebuildNav();pqUpdateNavLabel();
}

function pqAddQuestion(){
    pqCapture();
    window.__PQ_QD.push(pqEmptyQ());
    window.__PQ_CI=window.__PQ_QD.length-1;
    pqPopulate(window.__PQ_QD[window.__PQ_CI],window.__PQ_CT);
    pqRebuildNav();pqUpdateNavLabel();
}

function pqUpdateLabels(){
    var ol=document.getElementById('pqOptsLabel');
    if(ol)ol.textContent=_pqT('Options','Pilihan');
    var ce=document.getElementById('pqCeLabel');
    if(ce)ce.textContent=_pqT('Correct Explanation','Penjelasan Betul')+' *';
    var we=document.getElementById('pqWeLabel');
    if(we)we.textContent=_pqT('Wrong Explanation','Penjelasan Salah')+' *';
}

function pqUpdateNavLabel(){
    var lbl=document.getElementById('qbNavLabel');
    var total=window.__PQ_QD.length,current=window.__PQ_CI+1;
    if(lbl)lbl.textContent=_pqT('Question '+current+' of '+total,'Soalan '+current+' daripada '+total);
    var prev=document.getElementById('qbNavPrev'),next=document.getElementById('qbNavNext');
    if(prev){prev.disabled=(current<=1);prev.style.opacity=(current<=1)?'.35':'1';}
    if(next){next.disabled=(current>=total);next.style.opacity=(current>=total)?'.35':'1';}
    var nc=document.getElementById('navCount');if(nc)nc.textContent=total;
}

function pqRebuildNav(){
    var list=document.getElementById('qbNavList');if(!list)return;
    var html='';
    window.__PQ_QD.forEach(function(q,i){
        var active=i===window.__PQ_CI?' active':'';
        html+='<div class="tc-question-builder-nav-row"><button type="button" class="tc-question-builder-nav-item'+active+'" onclick="pqNavGoTo('+i+')"><span class="tc-question-builder-nav-badge">'+(i+1)+'</span> Q'+(i+1)+'</button>';
        html+='<button type="button" class="tc-question-builder-nav-del'+(window.__PQ_QD.length<=1?' disabled':'')+'" title="'+_pqT('Delete','Padam')+'" onclick="pqDeleteQ('+i+')"><i class="bi bi-trash3"></i></button></div>';
    });
    list.innerHTML=html;
}

function pqDeleteQ(idx){
    if(window.__PQ_QD.length<=1)return;
    window.__PQ_QD.splice(idx,1);
    if(window.__PQ_CI>=window.__PQ_QD.length)window.__PQ_CI=window.__PQ_QD.length-1;
    pqPopulate(window.__PQ_QD[window.__PQ_CI],window.__PQ_CT);
    pqRebuildNav();pqUpdateNavLabel();
}

/* -- Question Type -- */
function pqSwitchType(){
    var v=document.getElementById('pqDdlType').value;
    document.getElementById('pqSectionMCQ').style.display=(v==='MCQ')?'block':'none';
    document.getElementById('pqSectionTF').style.display=(v==='True/False')?'block':'none';
    document.getElementById('pqSectionMS').style.display=(v==='Multiselect')?'block':'none';
    document.getElementById('pqSectionFIB').style.display=(v==='Drag & Drop')?'block':'none';
    /* Show/hide Add Blank toolbar items */
    var isFib=(v==='Drag & Drop');
    document.getElementById('pqFibSep').style.display=isFib?'':'none';
    document.getElementById('pqBlankCounter').style.display=isFib?'':'none';
    document.getElementById('pqBtnAddBlank').style.display=isFib?'':'none';
    if(isFib)pqUpdateBlankCount();
}

/* -- Add Blank -- */
function pqAddBlank(){
    var btn=document.getElementById('pqBtnAddBlank');
    if(btn.classList.contains('disabled'))return;
    var ed=document.getElementById('pqRteEditor');if(!ed)return;
    var text=pqRteGetText();
    var count=(text.match(/\[Blank \d\]/g)||[]).length;
    if(count>=4)return;
    var blankTag='[Blank '+(count+1)+']';
    ed.focus();
    var sel=window.getSelection();
    var span=document.createElement('span');
    span.className='tc-rte-blank-chip';
    span.contentEditable='false';
    span.setAttribute('data-blank',blankTag);
    span.textContent='_______';
    if(sel.rangeCount){
        var range=sel.getRangeAt(0);
        range.deleteContents();
        range.insertNode(span);
        range.setStartAfter(span);range.setEndAfter(span);
        sel.removeAllRanges();sel.addRange(range);
    }else{
        ed.appendChild(span);
    }
    pqRteSync();pqUpdateFibUI();
}

function pqUpdateBlankCount(){
    var text=pqRteGetText();
    var blanks=(text.match(/\[Blank \d\]/g)||[]),count=blanks.length;
    var numEl=document.getElementById('pqBlankNum');if(numEl)numEl.textContent=count;
    var ctr=document.getElementById('pqBlankCounter');if(ctr)ctr.style.color=count>=4?'#E53E5E':'#7B7499';
    var btn=document.getElementById('pqBtnAddBlank');
    if(btn){if(count>=4)btn.classList.add('disabled');else btn.classList.remove('disabled');}
    /* Show/hide mapping & preview based on blanks (only when in D&D mode) */
    if(document.getElementById('pqDdlType').value!=='Drag & Drop')return;
    var ms=document.getElementById('pqFibMappingSection'),ps=document.getElementById('pqFibPreviewSection');
    if(count>0){if(ms)ms.style.display='block';if(ps)ps.style.display='block';pqBuildMappings();pqUpdateFibPreview();}
    else{if(ms)ms.style.display='none';if(ps)ps.style.display='none';}
}

function pqUpdateFibUI(){
    pqUpdateBlankCount();
}

/* -- Correct answer (MCQ) -- */
function pqSelectCorrect(el){
    var opt=el.closest('.tc-question-builder-opt');
    document.querySelectorAll('#pqMcqOpts .tc-question-builder-opt').forEach(function(o){o.classList.remove('correct');});
    opt.classList.add('correct');
    var idx=Array.prototype.indexOf.call(opt.parentNode.children,opt);
    window.__PQ_QD[window.__PQ_CI].correct=['A','B','C','D'][idx];
    pqClearFieldErr('pqMcqErr',document.getElementById('pqMcqOpts'));
}
function pqUpdateCorrectUI(q){
    var letters=['A','B','C','D'];
    document.querySelectorAll('#pqMcqOpts .tc-question-builder-opt').forEach(function(o,i){
        o.classList.toggle('correct',q.correct===letters[i]);
        var inp=o.querySelector('.tc-practice-quiz-opt-text');
        o.classList.toggle('has-text',inp&&inp.value.trim().length>0);
    });
}

/* -- True/False -- */
function pqUpdateTF(){
    document.querySelectorAll('.tc-question-builder-tf-card').forEach(function(c){c.classList.remove('selected');});
    document.querySelectorAll('.tc-question-builder-tf-card input[type="radio"]').forEach(function(r){if(r.checked)r.closest('.tc-question-builder-tf-card').classList.add('selected');});
    pqClearFieldErr('pqTfErr',document.querySelector('.tc-question-builder-tf-grid'));
}

/* -- Multiselect -- */
function pqUpdateMS(){
    var count=0;
    document.querySelectorAll('#pqMsOpts .tc-question-builder-ms-opt').forEach(function(o){var cb=o.querySelector('.tc-practice-quiz-ms-check');if(cb&&cb.checked){o.classList.add('selected');count++;}else o.classList.remove('selected');});
    var el=document.getElementById('pqMsCount');if(el)el.textContent=count+' '+_pqT('selected','dipilih');
}

/* -- Drag & Drop -- */
function pqOnFibWordChange(){pqBuildMappings();pqUpdateFibPreview();pqClearErr();}

function pqBuildMappings(){
    var text=pqRteGetText();
    var blanks=(text.match(/\[Blank \d\]/g)||[]),words=[];
    document.querySelectorAll('#pqFibWords .tc-practice-quiz-tc-fill-blank-word').forEach(function(i){if(i.value.trim())words.push(i.value.trim());});
    var container=document.getElementById('pqFibMappings');
    var q=window.__PQ_QD[window.__PQ_CI];
    var storedIdx=(q&&q.fibIdx)||{};
    var html='';
    blanks.forEach(function(b){
        var selectedVal=storedIdx[b]||'';
        var opts='<option value="">-- '+_pqT('Select word','Pilih perkataan')+' --</option>';
        words.forEach(function(w,wi){opts+='<option value="'+(wi+1)+'"'+(selectedVal===''+(wi+1)?' selected':'')+'>'+w+'</option>';});
        html+='<div class="tc-question-builder-tc-fill-blank-map-row'+(selectedVal?' valid':'')+'"><span class="tc-question-builder-tc-fill-blank-map-label">'+b+'</span><span class="tc-question-builder-tc-fill-blank-map-arrow"><i class="bi bi-arrow-right"></i></span><select class="tc-question-builder-tc-fill-blank-map-select tc-practice-quiz-tc-fill-blank-map-dd" data-blank="'+b+'" onchange="pqValidateFibMapping()">'+opts+'</select><span class="tc-question-builder-tc-fill-blank-map-check"><i class="bi bi-check-circle-fill"></i></span></div>';
    });
    container.innerHTML=html;
    pqUpdateFibPreview();
}

function pqValidateFibMapping(){
    /* Clear inline D&D mapping error */
    pqClearFieldErr('pqDndMapErr',document.getElementById('pqFibMappings'));
    var selects=document.querySelectorAll('#pqFibMappings .tc-practice-quiz-tc-fill-blank-map-dd'),vals=[],dup=false;
    selects.forEach(function(s){
        var row=s.closest('.tc-question-builder-tc-fill-blank-map-row');row.classList.remove('invalid');s.classList.remove('invalid');
        if(s.value){if(vals.indexOf(s.value)>-1){dup=true;row.classList.add('invalid');s.classList.add('invalid');}else row.classList.add('valid');vals.push(s.value);}else row.classList.remove('valid');
    });
    document.getElementById('pqFibMapError').style.display=dup?'flex':'none';
    /* Save mapping to question data */
    var q=window.__PQ_QD[window.__PQ_CI];
    var CL=window.__PQ_CT;
    var fibWordInputsAll=document.querySelectorAll('#pqFibWords .tc-practice-quiz-tc-fill-blank-word');
    var allWords=[];fibWordInputsAll.forEach(function(inp){allWords.push(inp.value||'');});
    var fibIdxMap={};
    var fibMappings=[];
    selects.forEach(function(sel){
        fibIdxMap[sel.dataset.blank]=sel.value||'';
        var idx=sel.value?parseInt(sel.value,10)-1:-1;
        fibMappings.push(idx>=0&&allWords[idx]?allWords[idx]:'');
    });
    q.fibIdx=fibIdxMap;
    if(CL==='EN')q.fibMapEN=fibMappings; else q.fibMapBM=fibMappings;
    pqUpdateFibPreview();
}

function pqUpdateFibPreview(){
    var text=pqRteGetText();
    var previewText=document.getElementById('pqFibPreviewText');
    var previewWords=document.getElementById('pqFibPreviewWords');
    if(!previewText||!previewWords)return;
    var html=text.replace(/\[Blank \d\]/g,'<span class="tc-fill-blank-blank">_____</span>');
    previewText.innerHTML=html||'<em style="color:#7B7499;">'+_pqT('Type your question with blanks...','Taip soalan anda dengan tempat kosong...')+'</em>';
    var words=[];document.querySelectorAll('#pqFibWords .tc-practice-quiz-tc-fill-blank-word').forEach(function(i){if(i.value.trim())words.push(i.value.trim());});
    previewWords.innerHTML=words.length?words.map(function(w){return'<span class="tc-question-builder-tc-fill-blank-chip">'+w+'</span>';}).join(''):'<em style="font-size:.78rem;color:#7B7499;">'+_pqT('Add words to Word Bank above','Tambah perkataan ke Bank Perkataan di atas')+'</em>';
}

/* -- Char counts -- */
function pqUpdateCharCounts(){
    var ce=document.getElementById('pqTxtCE'),we=document.getElementById('pqTxtWE');
    var cec=document.getElementById('pqCeCount'),wec=document.getElementById('pqWeCount');
    if(ce&&cec)cec.textContent=ce.value.length+' / 500';
    if(we&&wec)wec.textContent=we.value.length+' / 500';
}

/* -- Image -- */
function pqHandleImg(input){
    if(!input.files||!input.files[0])return;
    var file=input.files[0];
    if(file.size>5*1024*1024){input.value='';return;}
    var reader=new FileReader();
    reader.onload=function(e){
        var dataUrl=e.target.result;
        document.getElementById('pqImgPreviewSrc').src=dataUrl;
        document.getElementById('pqImgPreview').style.display='block';
        document.querySelector('#pqImgZone .tc-question-builder-img-upload').style.display='none';
        window.__PQ_QD[window.__PQ_CI].img=file.name;
        window.__PQ_QD[window.__PQ_CI].imgDataUrl=dataUrl;
    };
    reader.readAsDataURL(file);
}
function pqRemoveImg(){
    document.getElementById('pqImgPreview').style.display='none';
    document.querySelector('#pqImgZone .tc-question-builder-img-upload').style.display='flex';
    document.getElementById('pqImgInput').value='';
    window.__PQ_QD[window.__PQ_CI].img='';
    window.__PQ_QD[window.__PQ_CI].imgDataUrl='';
}

/* -- Inline validation message (no alert) -- */
function pqShowErr(msg){
    /* Deprecated — general error removed; use pqInlineErr instead */
}
function pqClearErr(){
    pqClearInlineErr();
}
function pqInlineErr(containerId,msg,highlightEl){
    var el=document.getElementById(containerId);
    var span=document.getElementById(containerId+'Msg');
    if(el&&span){span.textContent=msg;el.style.display='inline-flex';
        if(highlightEl){highlightEl.classList.add('tc-practice-quiz-field-invalid');}
        setTimeout(function(){el.scrollIntoView({behavior:'smooth',block:'center'});},50);
    }
}
function pqClearInlineErr(){
    ['pqMcqErr','pqTfErr','pqDndBlankErr','pqDndWordsErr','pqDndMapErr','pqQTextErr','pqMsErr','pqCeErr','pqWeErr'].forEach(function(id){
        var el=document.getElementById(id);if(el)el.style.display='none';
    });
    /* Remove field highlights */
    document.querySelectorAll('.tc-practice-quiz-field-invalid').forEach(function(el){el.classList.remove('tc-practice-quiz-field-invalid');});
}
function pqClearFieldErr(errId,highlightEl){
    var el=document.getElementById(errId);if(el)el.style.display='none';
    if(highlightEl)highlightEl.classList.remove('tc-practice-quiz-field-invalid');
}

/* -- Submit -- */
function pqSubmitQuiz(){
    pqCapture();
    pqClearErr();
    /* Validate title */
    if(!pqValidateTitle())return false;
    /* Validate all questions */
    for(var i=0;i<window.__PQ_QD.length;i++){
        var q=window.__PQ_QD[i];
        var qType=q.type||'MCQ';
        var lbl=_pqT('Question '+(i+1),'Soalan '+(i+1));
        var CL=window.__PQ_CT; /* content language: 'EN' or 'BM' */
        var qSuf=(CL==='EN')?'EN':'BM';

        /* -- Required question text -- */
        var qText=q['q'+qSuf]||'';
        if(!qText.trim()){pqNavGoTo(i);pqInlineErr('pqQTextErr',_pqT('Please fill in the question text.','Sila isi teks soalan.'),document.querySelector('.tc-question-builder-tc-rte-wrap'));return false;}

        /* -- Required explanations -- */
        if(!(q['ce'+qSuf]||'').trim()){pqNavGoTo(i);pqInlineErr('pqCeErr',_pqT('Please fill in the correct explanation.','Sila isi penjelasan betul.'),document.getElementById('pqTxtCE'));return false;}
        if(!(q['we'+qSuf]||'').trim()){pqNavGoTo(i);pqInlineErr('pqWeErr',_pqT('Please fill in the wrong explanation.','Sila isi penjelasan salah.'),document.getElementById('pqTxtWE'));return false;}

        /* -- MCQ -- */
        if(qType==='MCQ'){
            /* Min 2 options */
            var mcqOpts=[q['a'+qSuf],q['b'+qSuf]].filter(function(v){return v&&v.trim();}).length;
            if(mcqOpts<2){pqNavGoTo(i);pqInlineErr('pqMcqErr',_pqT('Options A and B are required.','Pilihan A dan B diperlukan.'),document.getElementById('pqMcqOpts'));return false;}
            /* Correct answer selected */
            if(!q.correct){pqNavGoTo(i);pqInlineErr('pqMcqErr',_pqT('Please select the correct answer.','Sila pilih jawapan yang betul.'),document.getElementById('pqMcqOpts'));return false;}
            /* Correct answer option has text */
            var cVal={'A':q['a'+qSuf],'B':q['b'+qSuf],'C':q['c'+qSuf],'D':q['d'+qSuf]}[q.correct]||'';
            if(!cVal.trim()){pqNavGoTo(i);pqInlineErr('pqMcqErr',_pqT('The selected correct answer must contain answer text.','Jawapan betul yang dipilih mesti mempunyai teks jawapan.'),document.getElementById('pqMcqOpts'));return false;}
        }

        /* -- True/False -- */
        if(qType==='True/False'){
            if(!q.correct){pqNavGoTo(i);pqInlineErr('pqTfErr',_pqT('Please select the correct answer.','Sila pilih jawapan yang betul.'),document.querySelector('.tc-question-builder-tf-grid'));return false;}
        }

        /* -- Multiselect -- */
        if(qType==='Multiselect'){
            /* Min 3 options */
            var msKeys=CL==='EN'?[q.msAEN,q.msBEN,q.msCEN,q.msDEN]:[q.msABM,q.msBBM,q.msCBM,q.msDBM];
            var msFilled=msKeys.filter(function(v){return v&&v.trim();}).length;
            if(msFilled<3){pqNavGoTo(i);pqInlineErr('pqMsErr',_pqT('Multi-select questions must contain at least three answer options.','Soalan Aneka Pilihan Berbilang mesti mempunyai sekurang-kurangnya tiga pilihan jawapan.'),document.getElementById('pqMsOpts'));return false;}
            /* Min 2 correct answers */
            var chkLetters=(q.msChk||'').split(',').filter(function(l){return l.trim();});
            if(chkLetters.length<2){pqNavGoTo(i);pqInlineErr('pqMsErr',_pqT('Please select at least two correct answers for a Multi-select question.','Sila pilih sekurang-kurangnya dua jawapan yang betul.'),document.getElementById('pqMsOpts'));return false;}
            /* Each selected correct answer has text */
            var msMap={'A':0,'B':1,'C':2,'D':3};
            var msBad=false;
            chkLetters.forEach(function(l){var j=msMap[l];if(j!==undefined&&!(msKeys[j]||'').trim())msBad=true;});
            if(msBad){pqNavGoTo(i);pqInlineErr('pqMsErr',_pqT('All selected correct answers must contain answer text.','Semua jawapan betul yang dipilih mesti mempunyai teks jawapan.'),document.getElementById('pqMsOpts'));return false;}
        }

        /* -- Drag & Drop -- */
        if(qType==='Drag & Drop'){
            var blankRe=/\[Blank \d\]/g;
            var blankCount=((q['q'+qSuf]||'').match(blankRe)||[]).length;
            /* At least 1 blank required */
            if(blankCount<1){pqNavGoTo(i);pqInlineErr('pqDndBlankErr',_pqT('At least one blank is required.','Sekurang-kurangnya satu kosong diperlukan.'),document.querySelector('.tc-question-builder-tc-rte-wrap'));return false;}
            /* Min 2 answer options */
            var fibKey=CL==='EN'?'fibEN':'fibBM';
            var fibArr=q[fibKey]||[];
            var wordCount=fibArr.filter(function(s){return s&&s.trim();}).length;
            if(wordCount<2){pqNavGoTo(i);pqInlineErr('pqDndWordsErr',_pqT('At least two answer options are required.','Sekurang-kurangnya dua pilihan jawapan diperlukan.'),document.getElementById('pqFibWords'));return false;}
            /* Any answer option is empty (gap between filled slots) */
            var hasEmpty=false;
            var usedSlots=fibArr.slice(0,4);
            var filledPositions=[];
            for(var fi=0;fi<usedSlots.length;fi++){
                if(usedSlots[fi]&&usedSlots[fi].trim())filledPositions.push(fi);
            }
            if(filledPositions.length>0){
                var maxFilledIdx=filledPositions[filledPositions.length-1];
                for(var fi=0;fi<=maxFilledIdx;fi++){
                    if(!usedSlots[fi]||!usedSlots[fi].trim()){hasEmpty=true;break;}
                }
            }
            if(hasEmpty){pqNavGoTo(i);pqInlineErr('pqDndWordsErr',_pqT('Answer options cannot be empty.','Pilihan jawapan tidak boleh kosong.'),document.getElementById('pqFibWords'));return false;}
            /* Mapping: check fibIdx for completeness */
            var fibIdxMap=q.fibIdx||{};
            var mappedVals=[];
            var allMapped=true;var hasDup=false;
            for(var bi=1;bi<=blankCount;bi++){
                var blankLabel='[Blank '+bi+']';
                var val=fibIdxMap[blankLabel]||'';
                if(!val){allMapped=false;break;}
                if(mappedVals.indexOf(val)>-1)hasDup=true;
                mappedVals.push(val);
            }
            if(!allMapped){pqNavGoTo(i);pqInlineErr('pqDndMapErr',_pqT('Each blank must have a correct answer mapping.','Setiap kosong mesti mempunyai pemetaan jawapan yang betul.'),document.getElementById('pqFibMappings'));return false;}
            if(hasDup){pqNavGoTo(i);pqInlineErr('pqDndMapErr',_pqT('Each blank must map to a unique word.','Setiap kosong mesti dipetakan kepada perkataan unik.'),document.getElementById('pqFibMappings'));return false;}

            /* Build correctAnswer from fibMap — same format as Unit/Level Quiz (comma-separated words) */
            var fibMapKey=(CL==='EN')?'fibMapEN':'fibMapBM';
            var fibMapArr=(q[fibMapKey]||[]).filter(function(s){return s&&s.trim();});
            if(fibMapArr.length!==blankCount){pqNavGoTo(i);pqInlineErr('pqDndMapErr',_pqT('Please complete the correct answer mapping for every blank.','Sila lengkapkan pemetaan jawapan betul bagi setiap ruang kosong.'),document.getElementById('pqFibMappings'));return false;}
            q.correct=fibMapArr.join(',');
        }
    }
    /* All validation passed — flush to server */
    pqClearErr();
    document.getElementById('<%=hidQuizTitle.ClientID%>').value=document.getElementById('pqTitleInput').value.trim();
    document.getElementById('<%=hidQuestionsJson.ClientID%>').value=JSON.stringify(window.__PQ_QD);
    document.getElementById('<%=btnSubmitPQ.ClientID%>').click();
    return false;
}

/* -- Init -- */
(function(){
    /* Wire has-text class on MCQ inputs + auto-clear errors */
    document.querySelectorAll('#pqMcqOpts .tc-practice-quiz-opt-text').forEach(function(inp){
        inp.addEventListener('input',function(){
            inp.closest('.tc-question-builder-opt').classList.toggle('has-text',inp.value.trim().length>0);
            pqClearFieldErr('pqMcqErr',document.getElementById('pqMcqOpts'));
        });
    });
    /* Wire char count updates + auto-clear */
    document.getElementById('pqTxtCE').addEventListener('input',function(){pqUpdateCharCounts();pqClearFieldErr('pqCeErr',this);});
    document.getElementById('pqTxtWE').addEventListener('input',function(){pqUpdateCharCounts();pqClearFieldErr('pqWeErr',this);});
    /* Wire RTE input + auto-clear */
    var ed=document.getElementById('pqRteEditor');
    if(ed)ed.addEventListener('input',function(){pqRteSync();pqClearFieldErr('pqQTextErr',document.querySelector('.tc-question-builder-tc-rte-wrap'));pqClearFieldErr('pqDndBlankErr');});
    /* Wire multiselect inputs + checkboxes */
    document.querySelectorAll('#pqMsOpts .tc-practice-quiz-ms-text').forEach(function(inp){
        inp.addEventListener('input',function(){pqClearFieldErr('pqMsErr',document.getElementById('pqMsOpts'));});
    });
    document.querySelectorAll('#pqMsOpts .tc-practice-quiz-ms-check').forEach(function(cb){
        cb.addEventListener('change',function(){pqClearFieldErr('pqMsErr',document.getElementById('pqMsOpts'));});
    });
    /* Wire multiselect card click — toggle selection by clicking entire card (same as Unit/Level Quiz) */
    document.querySelectorAll('#pqMsOpts .tc-question-builder-ms-opt').forEach(function(card){
        card.addEventListener('click',function(e){
            if(e.target.tagName==='INPUT'&&e.target.type==='text')return;
            var cb=card.querySelector('.tc-practice-quiz-ms-check');
            if(cb){cb.checked=!cb.checked;pqUpdateMS();pqClearFieldErr('pqMsErr',document.getElementById('pqMsOpts'));}
        });
    });
    /* Wire FIB word inputs */
    document.querySelectorAll('#pqFibWords .tc-practice-quiz-tc-fill-blank-word').forEach(function(inp){
        inp.addEventListener('input',function(){pqClearFieldErr('pqDndWordsErr',document.getElementById('pqFibWords'));pqClearFieldErr('pqDndMapErr');});
    });
    /* Initial state */
    pqRebuildNav();pqUpdateNavLabel();pqUpdateLabels();
    /* Set True/False card labels based on quiz content language */
    var _tfCL=window.__PQ_CT;
    var _tfTL=document.getElementById('pqTfTrueLabel');
    var _tfFL=document.getElementById('pqTfFalseLabel');
    if(_tfTL)_tfTL.textContent=(_tfCL==='BM')?'BETUL':'TRUE';
    if(_tfFL)_tfFL.textContent=(_tfCL==='BM')?'SALAH':'FALSE';

    /* Check for successful submission — now handled via redirect to manageQuiz.aspx */
})();

/* --- QUIZ TITLE ? VALIDATION & LANGUAGE SWITCH ----------- */

function pqValidateTitle(){
    var input=document.getElementById('pqTitleInput');
    var errDiv=document.getElementById('pqTitleErr');
    var errMsg=document.getElementById('pqTitleErrMsg');
    if(!input||!input.value.trim()){
        if(errMsg)errMsg.textContent=_pqT('Please enter the quiz title.','Sila masukkan tajuk kuiz.');
        if(errDiv)errDiv.style.display='inline-flex';
        if(input)input.focus();
        return false;
    }
    if(errDiv)errDiv.style.display='none';
    return true;
}

/* Clear error on input */
(function(){
    var input=document.getElementById('pqTitleInput');
    if(input)input.addEventListener('input',function(){
        var errDiv=document.getElementById('pqTitleErr');
        if(errDiv)errDiv.style.display='none';
    });
})();

/* Intercept language toggle for this page ? no reload */
(function(){
    function interceptLangBtns(){
        var btns=document.querySelectorAll('[id$="btnLangEN_Top"],[id$="btnLangBM_Top"],[id$="btnLangEN_Header"],[id$="btnLangBM_Header"]');
        btns.forEach(function(btn){
            btn.addEventListener('click',function(e){
                e.preventDefault();e.stopPropagation();e.stopImmediatePropagation();
                var newLang=btn.id.indexOf('LangEN')>-1?'EN':'BM';
                if(newLang===__PQ_SITE_LANG)return;
                pqSwitchSiteLang(newLang);
                return false;
            },true);
            btn.removeAttribute('href');
            btn.style.cursor='pointer';
        });
    }

    function pqSwitchSiteLang(lang){
        var xhr=new XMLHttpRequest();
        xhr.open('POST','<%= ResolveUrl("~/Teacher/createPracticeQuiz.aspx/SetLanguage") %>',true);
        xhr.setRequestHeader('Content-Type','application/json; charset=utf-8');
        xhr.send(JSON.stringify({lang:lang}));

        __PQ_SITE_LANG=lang;

        document.querySelectorAll('.sb-lang-btn').forEach(function(b){
            var isEN=b.id.indexOf('LangEN')>-1;
            b.className=(isEN&&lang==='EN')||(!isEN&&lang==='BM')?'sb-lang-btn active':'sb-lang-btn';
        });

        /* Update title field */
        var lbl=document.getElementById('pqTitleLabel');
        if(lbl)lbl.textContent=_pqT('Quiz Title','Tajuk Kuiz')+' *';
        var inp=document.getElementById('pqTitleInput');
        if(inp)inp.placeholder=_pqT('Enter quiz title...','Masukkan tajuk kuiz...');
        var errDiv=document.getElementById('pqTitleErr');
        if(errDiv)errDiv.style.display='none';

        /* Update question builder labels */
        pqUpdateLabels();
        pqUpdateNavLabel();
    }

    interceptLangBtns();
})();

function pqValidateTitle(){
    var input=document.getElementById('pqTitleInput');
    var errDiv=document.getElementById('pqTitleErr');
    var errMsg=document.getElementById('pqTitleErrMsg');
    if(!input||!input.value.trim()){
        if(errMsg)errMsg.textContent=_pqT('Please enter the quiz title.','Sila masukkan tajuk kuiz.');
        if(errDiv)errDiv.style.display='inline-flex';
        if(input)input.focus();
        return false;
    }
    if(errDiv)errDiv.style.display='none';
    return true;
}

/* Clear error on input */
(function(){
    var input=document.getElementById('pqTitleInput');
    if(input)input.addEventListener('input',function(){
        var errDiv=document.getElementById('pqTitleErr');
        if(errDiv)errDiv.style.display='none';
    });
})();
</script>
</asp:Content>