<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="createUnitLevelQuiz.aspx.cs"
    Inherits="ScienceBuddy.Teacher.createUnitLevelQuiz" MasterPageFile="~/Site.Master"
    Title="Create Quiz" EnableViewState="true" %>

<%-- Head --%>
<asp:Content ID="cHead" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%: ResolveUrl("~/Content/Teacher.css") %>" rel="stylesheet" />
</asp:Content>

<%-- Sidebar --%>
<asp:Content ID="cSidebar" ContentPlaceHolderID="SidebarMenu" runat="server">
    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Main","Utama") %></div>
        <a href="<%: ResolveUrl("~/Teacher/Dashboard.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-speedometer2 item-icon"></i>
            <span class="item-label"><%: T("Dashboard","Papan Pemuka") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Teacher/Notifications.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-bell item-icon"></i>
            <span class="item-label"><%: T("Notifications","Notifikasi") %></span>
        </a>
    </div>

    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Teaching","Pengajaran") %></div>
        <a href="<%: ResolveUrl("~/Teacher/manageMaterials.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-book item-icon"></i>
            <span class="item-label"><%: T("Manage Materials","Bahan Pembelajaran") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="sb-sidebar-item active">
            <i class="bi bi-patch-question item-icon"></i>
            <span class="item-label"><%: T("Manage Quiz","Kuiz") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Teacher/studentProgress.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-bar-chart item-icon"></i>
            <span class="item-label"><%: T("Student Progress","Prestasi Pelajar") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Teacher/liveSession.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-camera-video item-icon"></i>
            <span class="item-label"><%: T("Schedule Live Class","Kelas Langsung") %></span>
        </a>
    </div>

    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Community","Komuniti") %></div>
        <a href="<%: ResolveUrl("~/Teacher/forum.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-chat-dots item-icon"></i>
            <span class="item-label"><%: T("Forum","Forum") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Teacher/privateMessages.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-envelope item-icon"></i>
            <span class="item-label"><%: T("Private Message","Mesej Peribadi") %></span>
        </a>
    </div>

    <div class="sb-nav-section">
        <div class="sb-nav-section-label"><%: T("Account","Akaun") %></div>
        <a href="<%: ResolveUrl("~/Teacher/MyProfile.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-person item-icon"></i>
            <span class="item-label"><%: T("My Profile","Profil Saya") %></span>
        </a>
        <a href="<%: ResolveUrl("~/Logout.aspx") %>" class="sb-sidebar-item">
            <i class="bi bi-box-arrow-right item-icon"></i>
            <span class="item-label"><%: T("Sign Out","Log Keluar") %></span>
        </a>
    </div>
</asp:Content>

<%-- Page Title --%>
<asp:Content ID="cPageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <%: T("Create Quiz","Cipta Kuiz") %>
</asp:Content>

<%-- Main Content --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContentSidebar" runat="server">

    <%-- Error Panel --%>
    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="tc-question-builder-msg tc-question-builder-msg-error">
            <i class="bi bi-exclamation-circle"></i>
            <asp:Literal ID="litError" runat="server" />
        </div>
        <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>" class="tc-question-builder-btn tc-question-builder-btn-outline">
            <%: T("Back to Quizzes","Kembali ke Kuiz") %>
        </a>
    </asp:Panel>

    <asp:Panel ID="pnlBuilder" runat="server" Visible="false">

    <%-- Hero --%>
    <div class="tc-create-quiz-hero">
        <div class="tc-create-quiz-hero-bg">
            <svg viewBox="0 0 820 260" fill="none" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMaxYMid slice">
                <circle cx="550" cy="62" r="10" fill="#D97B6C"/>
                <ellipse cx="550" cy="62" rx="36" ry="15" stroke="#D97B6C" stroke-width="2.2" fill="none"/>
                <ellipse cx="550" cy="62" rx="36" ry="15" stroke="#D97B6C" stroke-width="2.2" fill="none" transform="rotate(60 550 62)"/>
                <ellipse cx="550" cy="62" rx="36" ry="15" stroke="#D97B6C" stroke-width="2.2" fill="none" transform="rotate(120 550 62)"/>
                <path d="M650 18 C660 36 672 36 682 18 C692 0 704 0 714 18" stroke="#486F4B" stroke-width="2.2" fill="none" stroke-linecap="round"/>
                <path d="M650 36 C660 54 672 54 682 36 C692 18 704 18 714 36" stroke="#486F4B" stroke-width="2.2" fill="none" stroke-linecap="round"/>
                <line x1="659" y1="27" x2="659" y2="43" stroke="#486F4B" stroke-width="1.6"/>
                <line x1="673" y1="36" x2="673" y2="52" stroke="#486F4B" stroke-width="1.6"/>
                <line x1="687" y1="27" x2="687" y2="43" stroke="#486F4B" stroke-width="1.6"/>
                <line x1="701" y1="18" x2="701" y2="34" stroke="#486F4B" stroke-width="1.6"/>
                <path d="M760 28 L760 66 L780 98 L740 98 Z" stroke="#5F8F63" stroke-width="2.2" fill="none" stroke-linejoin="round"/>
                <line x1="752" y1="28" x2="768" y2="28" stroke="#5F8F63" stroke-width="2.2"/>
                <ellipse cx="760" cy="90" rx="13" ry="5" fill="#5F8F63" opacity=".45"/>
                <circle cx="754" cy="78" r="4" fill="#D97B6C" opacity=".55"/>
                <circle cx="764" cy="84" r="3" fill="#D8A53A" opacity=".5"/>
                <rect x="790" y="110" width="24" height="38" rx="4" stroke="#D8A53A" stroke-width="2" fill="none"/>
                <line x1="802" y1="110" x2="802" y2="96" stroke="#D8A53A" stroke-width="2.2"/>
                <circle cx="802" cy="92" r="7" stroke="#D8A53A" stroke-width="2" fill="none"/>
                <line x1="786" y1="148" x2="818" y2="148" stroke="#D8A53A" stroke-width="2.2" stroke-linecap="round"/>
                <circle cx="700" cy="170" r="7" fill="#D97B6C"/>
                <circle cx="726" cy="150" r="5" fill="#5F8F63"/>
                <circle cx="748" cy="172" r="7" fill="#D97B6C"/>
                <circle cx="726" cy="192" r="4.5" fill="#D8A53A"/>
                <line x1="707" y1="170" x2="721" y2="153" stroke="#D97B6C" stroke-width="1.8"/>
                <line x1="731" y1="153" x2="743" y2="169" stroke="#D97B6C" stroke-width="1.8"/>
                <line x1="726" y1="155" x2="726" y2="187" stroke="#5F8F63" stroke-width="1.8"/>
                <path d="M610 110 Q632 88 644 110 Q632 134 610 110 Z" stroke="#486F4B" stroke-width="1.8" fill="none"/>
                <line x1="610" y1="110" x2="642" y2="110" stroke="#486F4B" stroke-width="1.2"/>
                <path d="M618 130 Q628 118 636 130 Q628 142 618 130 Z" stroke="#486F4B" stroke-width="1.5" fill="none" opacity=".6"/>
                <line x1="460" y1="200" x2="520" y2="160" stroke="#D97B6C" stroke-width="2.5" stroke-linecap="round"/>
                <ellipse cx="461" cy="201" rx="10" ry="6" stroke="#D97B6C" stroke-width="2" fill="none" transform="rotate(-35 461 201)"/>
                <line x1="520" y1="160" x2="536" y2="158" stroke="#D97B6C" stroke-width="2.5" stroke-linecap="round"/>
                <line x1="490" y1="220" x2="490" y2="200" stroke="#D97B6C" stroke-width="2" stroke-linecap="round"/>
                <line x1="476" y1="220" x2="504" y2="220" stroke="#D97B6C" stroke-width="2.5" stroke-linecap="round"/>
                <path d="M575 155 C580 138 596 135 598 148 C593 140 581 143 575 155 Z" fill="#D8A53A"/>
                <path d="M420 45 L422.5 52 L430 54.5 L422.5 57 L420 64 L417.5 57 L410 54.5 L417.5 52 Z" fill="#D8A53A" opacity=".75"/>
                <path d="M668 70 L669.8 75.5 L675.5 77.3 L669.8 79.1 L668 84.6 L666.2 79.1 L660.5 77.3 L666.2 75.5 Z" fill="#D8A53A" opacity=".65"/>
                <path d="M495 130 L496.4 134 L500.5 135.4 L496.4 136.8 L495 140.8 L493.6 136.8 L489.5 135.4 L493.6 134 Z" fill="#D97B6C" opacity=".6"/>
                <circle cx="438" cy="105" r="3.2" fill="#D8A53A" opacity=".6"/>
                <circle cx="462" cy="72" r="2.4" fill="#D97B6C" opacity=".55"/>
                <circle cx="582" cy="200" r="2.8" fill="#5F8F63" opacity=".5"/>
                <circle cx="640" cy="230" r="2" fill="#D8A53A" opacity=".5"/>
                <circle cx="772" cy="60" r="3" fill="#D97B6C" opacity=".45"/>
                <path d="M380 260 Q470 228 565 242 Q650 256 750 236 Q790 228 820 234 L820 260 Z" fill="#D8A53A" opacity=".18"/>
                <path d="M0 220 Q80 200 160 215 Q240 230 300 210 L300 260 L0 260 Z" fill="#5F8F63" opacity=".15"/>
            </svg>
        </div>
        <div class="tc-create-quiz-hero-left">
            <div class="tc-create-quiz-hero-top">
                <div class="tc-create-quiz-hero-icon"><i class="bi bi-journal-bookmark-fill"></i></div>
                <div>
                    <h1 class="tc-create-quiz-hero-title">
                        <asp:Literal ID="litMode" runat="server" />
                    </h1>
                    <p class="tc-create-quiz-hero-desc">
                        <%: T("Create and manage questions for this quiz.","Cipta dan urus soalan untuk kuiz ini.") %>
                    </p>
                </div>
            </div>
            <div class="tc-create-quiz-hero-meta">
                <div class="tc-create-quiz-meta-item">
                    <div class="tc-create-quiz-meta-pill tc-create-quiz-meta-pill-unit">
                        <i class="bi bi-layers-fill"></i>
                    </div>
                    <div>
                        <span class="tc-create-quiz-meta-label">
                            <asp:Literal ID="litScopeLabel" runat="server" />
                        </span>
                        <span class="tc-create-quiz-meta-val">
                            <asp:Literal ID="litScope" runat="server" />
                        </span>
                    </div>
                </div>
                <div class="tc-create-quiz-meta-item">
                    <div class="tc-create-quiz-meta-pill tc-create-quiz-meta-pill-subtopic">
                        <i class="bi bi-bookmark-fill"></i>
                    </div>
                    <div>
                        <span class="tc-create-quiz-meta-label"><%: T("Subtopic","Subtopik") %></span>
                        <span class="tc-create-quiz-meta-val">
                            <asp:Literal ID="litSubtopic" runat="server" />
                        </span>
                    </div>
                </div>
            </div>
        </div>
    </div><%-- /.tc-create-quiz-hero --%>

    <%-- Quiz Titles Panel --%>
    <asp:Panel ID="pnlQuizTitles" runat="server" Visible="false">
        <div class="tc-create-quiz-titles-panel">
            <div class="tc-create-quiz-title-col">
                <span class="tc-create-quiz-title-badge tc-create-quiz-title-badge-en">
                    <i class="bi bi-translate"></i>&nbsp;English
                </span>
                <div class="tc-create-quiz-title-val">
                    <asp:Literal ID="litQuizTitleEN" runat="server" />
                </div>
            </div>
            <div class="tc-create-quiz-title-col">
                <span class="tc-create-quiz-title-badge tc-create-quiz-title-badge-bm">
                    <i class="bi bi-translate"></i>&nbsp;Bahasa Melayu
                </span>
                <div class="tc-create-quiz-title-val">
                    <asp:Literal ID="litQuizTitleBM" runat="server" />
                </div>
            </div>
        </div>
    </asp:Panel>

    <%-- Subtopic Selection (legacy flow fallback) --%>
    <asp:Panel ID="pnlSubtopicSelect" runat="server" Visible="false">
        <div style="margin-bottom:1.5rem;padding:1.1rem 1.3rem;background:#FAFAF8;border-radius:14px;border:1.5px solid var(--tc-border);">
            <div style="font-size:.8rem;font-weight:700;color:var(--tc-text);margin-bottom:7px;">
                <%: T("Select Subtopic","Pilih Subtopik") %> *
            </div>
            <asp:DropDownList ID="ddlSubtopic" runat="server"
                CssClass="tc-question-builder-input"
                style="padding:.55rem .75rem;" />
        </div>
    </asp:Panel>

    <%-- Information Notice --%>
    <div class="tc-create-quiz-info-notice">
        <div class="tc-create-quiz-info-icon"><i class="bi bi-info-circle-fill"></i></div>
        <div class="tc-create-quiz-info-body">
            <div class="tc-create-quiz-info-title"><%: T("Unit Quiz Information","Maklumat Kuiz Unit") %></div>
            <div class="tc-create-quiz-info-text">
                <%: T("Each question must include both English and Bahasa Melayu versions before it can be submitted successfully. Complete both language tabs before saving each question.","Setiap soalan mesti mengandungi kedua-dua versi Bahasa Inggeris dan Bahasa Melayu sebelum boleh dihantar. Lengkapkan kedua-dua tab bahasa sebelum menyimpan setiap soalan.") %>
            </div>
        </div>
    </div>

    <%-- Progress Bar (hidden) --%>
    <div class="tc-question-builder-progress" style="display:none;">
        <div class="tc-question-builder-progress-icon"><i class="bi bi-check2-all"></i></div>
        <div class="tc-question-builder-progress-bar">
            <div class="tc-question-builder-progress-fill" id="progressFill" style="width:0%"></div>
        </div>
        <div class="tc-question-builder-progress-text" id="progressText">
            0 / 0 <%: T("Questions Saved","Soalan Disimpan") %>
        </div>
    </div>

    <%-- Question Builder --%>
    <div class="tc-question-builder-layout">

        <%-- Left Nav --%>
        <div class="tc-question-builder-nav">
            <div class="tc-question-builder-nav-header">
                <div class="tc-question-builder-nav-title">
                    <%: T("Questions","Soalan") %>
                    <span class="tc-question-builder-nav-count" id="navCount">0</span>
                </div>
            </div>
            <div class="tc-question-builder-nav-list">
                <asp:Repeater ID="rptNav" runat="server">
                    <ItemTemplate>
                        <div class="tc-question-builder-nav-row">
                            <asp:LinkButton ID="btnNavQ" runat="server"
                                CssClass='<%# "tc-question-builder-nav-item" + (Convert.ToInt32(Eval("Index")) == CurrentIndex ? " active" : "") + (Convert.ToBoolean(Eval("Done")) ? " done" : "") %>'
                                CommandName="GoTo"
                                CommandArgument='<%# Eval("Index") %>'
                                OnCommand="btnNav_Command"
                                CausesValidation="false"
                                data-qidx='<%# Eval("Index") %>'>
                                <span class="tc-question-builder-nav-badge"><%# Convert.ToInt32(Eval("Index")) + 1 %></span>
                                <span>Q<%# Convert.ToInt32(Eval("Index")) + 1 %></span>
                                <i class="bi bi-check-circle-fill tc-question-builder-nav-check"></i>
                            </asp:LinkButton>
                            <button type="button" class="tc-question-builder-nav-del"
                                data-idx="<%# Convert.ToInt32(Eval("Index")) %>"
                                onclick="confirmDeleteQuestion(+this.dataset.idx)"
                                title="Delete question">
                                <i class="bi bi-trash3"></i>
                            </button>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
            <div class="tc-question-builder-nav-footer">
                <asp:Button ID="btnAddQuestion" runat="server"
                    CssClass="tc-question-builder-nav-add"
                    OnClientClick="clientAddQuestion();return false;"
                    OnClick="btnAddQuestion_Click"
                    CausesValidation="false" />
            </div>
        </div>

        <%-- Delete confirmation modal --%>
        <div class="tc-question-builder-del-overlay" id="qbDelOverlay" onclick="closeDeleteModal(event)">
            <div class="tc-question-builder-del-modal">
                <div class="tc-question-builder-del-modal-icon"><i class="bi bi-trash3-fill"></i></div>
                <h3><%: T("Delete Question?","Padam Soalan?") %></h3>
                <p id="qbDelMsg">
                    <%: T("This question will be permanently removed. This action cannot be undone.","Soalan ini akan dipadam secara kekal. Tindakan ini tidak boleh dibatalkan.") %>
                </p>
                <div class="tc-question-builder-del-modal-actions">
                    <button type="button" class="tc-question-builder-del-btn-cancel" onclick="closeDeleteModal()">
                        <%: T("Cancel","Batal") %>
                    </button>
                    <button type="button" class="tc-question-builder-del-btn-confirm" id="qbDelConfirm">
                        <%: T("Delete","Padam") %>
                    </button>
                </div>
            </div>
        </div>

        <%-- Center Editor --%>
        <div class="tc-question-builder-center">

            <%-- Toolbar: Navigation + Submit --%>
            <div class="tc-question-builder-toolbar">
                <div class="tc-question-builder-toolbar-nav">
                    <button type="button" id="qbNavPrev" class="tc-question-builder-toolbar-arrow"
                        onclick="navGoTo(window.__CI-1);return false;">
                        <i class="bi bi-chevron-left"></i>
                    </button>
                    <span id="qbNavLabel" class="tc-question-builder-toolbar-label"></span>
                    <button type="button" id="qbNavNext" class="tc-question-builder-toolbar-arrow"
                        onclick="navGoTo(window.__CI+1);return false;">
                        <i class="bi bi-chevron-right"></i>
                    </button>
                </div>
                <asp:Button ID="btnSubmitQuiz" runat="server"
                    CssClass="tc-question-builder-btn tc-question-builder-btn-success"
                    style="margin:0;padding:.55rem 1.2rem;font-size:.82rem;"
                    OnClientClick="return validateFibBlanksAndFlush();"
                    OnClick="btnSubmitQuiz_Click"
                    CausesValidation="false" />
            </div>

            <%-- Language toggle --%>
            <div class="tc-question-builder-toolbar-lang">
                <div class="tc-question-builder-tabs">
                    <asp:Button ID="btnTabEN" runat="server" Text="English"
                        CssClass="tc-question-builder-tab active"
                        OnClientClick="switchTab('EN');return false;"
                        CausesValidation="false" />
                    <asp:Button ID="btnTabBM" runat="server" Text="Bahasa Melayu"
                        CssClass="tc-question-builder-tab"
                        OnClientClick="switchTab('BM');return false;"
                        CausesValidation="false" />
                </div>
            </div>

            <%-- Hidden literals for code-behind compatibility --%>
            <asp:Literal ID="litQNum" runat="server" Visible="false" />
            <asp:Literal ID="litQTextLabel" runat="server" Visible="false" />

            <div class="tc-question-builder-editor-body">

                <%-- Question Text: Rich Editor --%>
                <div class="tc-question-builder-field" style="margin-bottom:1.2rem;">
                    <div class="tc-question-builder-label">
                        <span>
                            <%: T("Question","Soalan") %> *
                            <span id="qbLangBadge"
                                style="font-size:.65rem;font-weight:700;padding:2px 8px;border-radius:5px;background:#D1FAE5;color:#047857;margin-left:6px;text-transform:none;letter-spacing:0;">
                                EN
                            </span>
                        </span>
                        <span class="tc-question-builder-char-count" id="qCharCount">0 / 500</span>
                    </div>
                    <div class="tc-question-builder-tc-rte-wrap">
                        <div class="tc-question-builder-tc-rte-toolbar">
                            <button type="button" class="tc-question-builder-tc-rte-btn" onmousedown="event.preventDefault();rteExec('bold')" title="Bold (Ctrl+B)"><i class="bi bi-type-bold"></i></button>
                            <button type="button" class="tc-question-builder-tc-rte-btn" onmousedown="event.preventDefault();rteExec('italic')" title="Italic (Ctrl+I)"><i class="bi bi-type-italic"></i></button>
                            <button type="button" class="tc-question-builder-tc-rte-btn" onmousedown="event.preventDefault();rteExec('underline')" title="Underline (Ctrl+U)"><i class="bi bi-type-underline"></i></button>
                            <span class="tc-question-builder-tc-rte-sep"></span>
                            <button type="button" class="tc-question-builder-tc-rte-btn" onmousedown="event.preventDefault();rteExec('insertUnorderedList')" title="Bullet List"><i class="bi bi-list-ul"></i></button>
                            <button type="button" class="tc-question-builder-tc-rte-btn" onmousedown="event.preventDefault();rteExec('insertOrderedList')" title="Numbered List"><i class="bi bi-list-ol"></i></button>
                            <span class="tc-question-builder-tc-rte-sep tc-question-builder-tc-fill-blank-only" id="fibToolbarSep" style="display:none;"></span>
                            <span class="tc-fill-blank-counter tc-question-builder-tc-fill-blank-only" id="blankCounter" style="display:none;margin-left:auto;font-size:.75rem;">
                                <%: T("Blanks","Kosong") %>: <strong id="blankNum">0</strong> / 4
                            </span>
                            <button type="button" class="tc-fill-blank-add-btn tc-question-builder-tc-fill-blank-only" id="btnAddBlank" onclick="addBlank()" style="display:none;margin-left:6px;padding:.4rem .8rem;font-size:.76rem;">
                                <i class="bi bi-plus-square-dotted"></i> <%: T("Add Blank","Tambah Kosong") %>
                            </button>
                        </div>
                        <div id="qbRteEditor" class="tc-question-builder-tc-rte-editor"
                            contenteditable="true"
                            data-placeholder-en="Type your question here..."
                            data-placeholder-bm="Taip soalan anda di sini..."
                            data-placeholder="<%: T("Type your question here...","Taip soalan anda di sini...") %>">
                        </div>
                    </div>
                    <%-- Hidden textarea for server sync --%>
                    <asp:TextBox ID="txtQuestionText" runat="server"
                        TextMode="MultiLine" Rows="4"
                        CssClass="tc-question-builder-input tc-question-builder-textarea"
                        MaxLength="500" style="display:none;" />
                </div>

                <%-- Question Image --%>
                <div class="tc-question-builder-img-zone" id="qbImgZone">
                    <div class="tc-question-builder-img-upload" id="qbImgUploadLabel"
                        onclick="document.getElementById('qbImgInput').click()">
                        <div class="tc-question-builder-img-upload-icon"><i class="bi bi-image"></i></div>
                        <span class="tc-question-builder-img-upload-text"><%: T("Upload Image","Muat Naik Imej") %></span>
                        <span class="tc-question-builder-img-upload-sub"><%: T("Optional ? PNG, JPG, GIF up to 5 MB","Pilihan ? PNG, JPG, GIF sehingga 5 MB") %></span>
                    </div>
                    <asp:FileUpload ID="fuQuestionImage" runat="server" Style="display:none;" />
                    <input type="file" id="qbImgInput" accept="image/*" onchange="handleQImgUpload(this)" style="display:none;" />
                    <div class="tc-question-builder-img-preview" id="qbImgPreview">
                        <img id="qbImgPreviewSrc" src="" alt="" />
                        <button type="button" class="tc-question-builder-img-remove" onclick="removeQImg()">
                            <i class="bi bi-x"></i>
                        </button>
                    </div>
                </div>
                <asp:HiddenField ID="hidImgFileName" runat="server" Value="" />

                <%-- Answer Section: MCQ (default) --%>
                <div id="sectionMCQ" class="tc-question-builder-answer-section">
                    <div class="tc-question-builder-section-header">
                        <div class="tc-question-builder-section-header-icon"><i class="bi bi-ui-radios"></i></div>
                        <span class="tc-question-builder-section-header-text">
                            <asp:Literal ID="litOptionsLabel" runat="server" />
                        </span>
                        <span class="tc-question-builder-section-header-sub">
                            <%: T("Select one correct answer","Pilih satu jawapan betul") %>
                        </span>
                        <div class="tc-question-builder-section-divider"></div>
                    </div>
                    <div class="tc-question-builder-opts">
                        <div class="tc-question-builder-opt" id="optAWrap" runat="server">
                            <div class="tc-question-builder-opt-band">A</div>
                            <div class="tc-question-builder-opt-body">
                                <asp:RadioButton ID="radA" runat="server" GroupName="correct" />
                                <asp:TextBox ID="txtOptA" runat="server" CssClass="tc-question-builder-opt-input" />
                            </div>
                            <div class="tc-question-builder-opt-selector" onclick="selectCorrectOpt(this)"></div>
                        </div>
                        <div class="tc-question-builder-opt" id="optBWrap" runat="server">
                            <div class="tc-question-builder-opt-band">B</div>
                            <div class="tc-question-builder-opt-body">
                                <asp:RadioButton ID="radB" runat="server" GroupName="correct" />
                                <asp:TextBox ID="txtOptB" runat="server" CssClass="tc-question-builder-opt-input" />
                            </div>
                            <div class="tc-question-builder-opt-selector" onclick="selectCorrectOpt(this)"></div>
                        </div>
                        <div class="tc-question-builder-opt" id="optCWrap" runat="server">
                            <div class="tc-question-builder-opt-band">C</div>
                            <div class="tc-question-builder-opt-body">
                                <asp:RadioButton ID="radC" runat="server" GroupName="correct" />
                                <asp:TextBox ID="txtOptC" runat="server" CssClass="tc-question-builder-opt-input" />
                            </div>
                            <div class="tc-question-builder-opt-selector" onclick="selectCorrectOpt(this)"></div>
                        </div>
                        <div class="tc-question-builder-opt" id="optDWrap" runat="server">
                            <div class="tc-question-builder-opt-band">D</div>
                            <div class="tc-question-builder-opt-body">
                                <asp:RadioButton ID="radD" runat="server" GroupName="correct" />
                                <asp:TextBox ID="txtOptD" runat="server" CssClass="tc-question-builder-opt-input" />
                            </div>
                            <div class="tc-question-builder-opt-selector" onclick="selectCorrectOpt(this)"></div>
                        </div>
                    </div>
                </div>

                <%-- Answer Section: True/False --%>
                <div id="sectionTF" class="tc-question-builder-answer-section" style="display:none;">
                    <div class="tc-question-builder-section-header">
                        <div class="tc-question-builder-section-header-icon"><i class="bi bi-toggles"></i></div>
                        <span class="tc-question-builder-section-header-text">
                            <%: T("Select the correct answer","Pilih jawapan yang betul") %>
                        </span>
                        <div class="tc-question-builder-section-divider"></div>
                    </div>
                    <div class="tc-question-builder-tf-grid">
                        <label class="tc-question-builder-tf-card" id="tfTrueCard">
                            <input type="radio" name="tfAnswer" value="A" onchange="updateTFCards()"/>
                            <i class="bi bi-check-circle-fill"></i>
                            <span id="tfTrueLabel">TRUE</span>
                        </label>
                        <label class="tc-question-builder-tf-card" id="tfFalseCard">
                            <input type="radio" name="tfAnswer" value="B" onchange="updateTFCards()"/>
                            <i class="bi bi-x-circle-fill"></i>
                            <span id="tfFalseLabel">FALSE</span>
                        </label>
                    </div>
                </div>

                <%-- Answer Section: Multiselect --%>
                <div id="sectionMS" class="tc-question-builder-answer-section" style="display:none;">
                    <div class="tc-question-builder-section-header">
                        <div class="tc-question-builder-section-header-icon"><i class="bi bi-check2-square"></i></div>
                        <span class="tc-question-builder-section-header-text">
                            <%: T("Select all correct answers","Pilih semua jawapan betul") %>
                        </span>
                        <span class="tc-question-builder-ms-count" id="msCount" style="margin-left:0;">
                            0 <%: T("selected","dipilih") %>
                        </span>
                        <div class="tc-question-builder-section-divider"></div>
                    </div>
                    <div class="tc-question-builder-opts">
                        <div class="tc-question-builder-opt tc-question-builder-ms-opt">
                            <div class="tc-question-builder-opt-band">A</div>
                            <div class="tc-question-builder-opt-body">
                                <input type="checkbox" class="ms-check" onchange="updateMSCards()"/>
                                <input type="text" class="tc-question-builder-opt-input ms-text" placeholder="<%: T("Type option A...","Taip pilihan A...") %>" />
                            </div>
                        </div>
                        <div class="tc-question-builder-opt tc-question-builder-ms-opt">
                            <div class="tc-question-builder-opt-band">B</div>
                            <div class="tc-question-builder-opt-body">
                                <input type="checkbox" class="ms-check" onchange="updateMSCards()"/>
                                <input type="text" class="tc-question-builder-opt-input ms-text" placeholder="<%: T("Type option B...","Taip pilihan B...") %>" />
                            </div>
                        </div>
                        <div class="tc-question-builder-opt tc-question-builder-ms-opt">
                            <div class="tc-question-builder-opt-band">C</div>
                            <div class="tc-question-builder-opt-body">
                                <input type="checkbox" class="ms-check" onchange="updateMSCards()"/>
                                <input type="text" class="tc-question-builder-opt-input ms-text" placeholder="<%: T("Type option C...","Taip pilihan C...") %>" />
                            </div>
                        </div>
                        <div class="tc-question-builder-opt tc-question-builder-ms-opt">
                            <div class="tc-question-builder-opt-band">D</div>
                            <div class="tc-question-builder-opt-body">
                                <input type="checkbox" class="ms-check" onchange="updateMSCards()"/>
                                <input type="text" class="tc-question-builder-opt-input ms-text" placeholder="<%: T("Type option D...","Taip pilihan D...") %>" />
                            </div>
                        </div>
                    </div>
                </div>

                <%-- Answer Section: Drag & Drop --%>
                <div id="sectionFIB" class="tc-question-builder-answer-section" style="display:none;">
                    <div class="tc-fill-blank-section-label" style="font-size:.92rem;font-weight:800;">
                        <%: T("Answer Options","Pilihan Jawapan") %> *
                        <span class="tc-fill-blank-sub-label">(<%: T("Max 4 words","Maks 4 perkataan") %>)</span>
                    </div>
                    <div class="tc-question-builder-tc-fill-blank-words" id="fibWordsContainer">
                        <div class="tc-question-builder-tc-fill-blank-word">
                            <span class="tc-question-builder-tc-fill-blank-num">1</span>
                            <input type="text" class="tc-question-builder-opt-input tc-fill-blank-word-input" placeholder="<%: T("Word 1","Perkataan 1") %>" oninput="onFibWordChange()" />
                        </div>
                        <div class="tc-question-builder-tc-fill-blank-word">
                            <span class="tc-question-builder-tc-fill-blank-num">2</span>
                            <input type="text" class="tc-question-builder-opt-input tc-fill-blank-word-input" placeholder="<%: T("Word 2","Perkataan 2") %>" oninput="onFibWordChange()" />
                        </div>
                        <div class="tc-question-builder-tc-fill-blank-word">
                            <span class="tc-question-builder-tc-fill-blank-num">3</span>
                            <input type="text" class="tc-question-builder-opt-input tc-fill-blank-word-input" placeholder="<%: T("Word 3","Perkataan 3") %>" oninput="onFibWordChange()" />
                        </div>
                        <div class="tc-question-builder-tc-fill-blank-word">
                            <span class="tc-question-builder-tc-fill-blank-num">4</span>
                            <input type="text" class="tc-question-builder-opt-input tc-fill-blank-word-input" placeholder="<%: T("Word 4","Perkataan 4") %>" oninput="onFibWordChange()" />
                        </div>
                    </div>

                    <div id="fibMappingSection" class="tc-fill-blank-mapping-wrap" style="display:none;">
                        <div class="tc-fill-blank-section-label" style="font-size:.92rem;font-weight:800;">
                            <i class="bi bi-arrow-left-right"></i>
                            <%: T("Correct Answer Mapping","Pemetaan Jawapan Betul") %> *
                        </div>
                        <div class="tc-question-builder-tc-fill-blank-mappings" id="fibMappings"></div>
                        <div class="tc-fill-blank-warning" id="fibMappingError" style="display:none;margin-top:6px;">
                            <i class="bi bi-exclamation-circle-fill"></i>
                            <%: T("Each blank must map to a unique word.","Setiap kosong mesti dipetakan kepada perkataan unik.") %>
                        </div>
                    </div>

                    <div id="fibPreviewSection" class="tc-fill-blank-preview-wrap" style="display:none;">
                        <div class="tc-question-builder-tc-fill-blank-preview-card">
                            <div class="tc-question-builder-tc-fill-blank-preview-title">
                                <i class="bi bi-eye"></i> <%: T("Student Preview","Pratonton Pelajar") %>
                            </div>
                            <div class="tc-question-builder-tc-fill-blank-preview-sub">
                                <%: T("Students will drag the correct words into the blanks below.","Pelajar akan menyeret perkataan betul ke dalam kosong di bawah.") %>
                            </div>
                            <div class="tc-question-builder-tc-fill-blank-preview-text" id="fibPreviewText"></div>
                            <div style="margin-top:.75rem;">
                                <div style="font-size:.72rem;font-weight:600;color:var(--tc-muted);margin-bottom:6px;text-transform:uppercase;letter-spacing:.5px;">
                                    <%: T("Available Words","Perkataan Tersedia") %>
                                </div>
                                <div class="tc-question-builder-tc-fill-blank-preview-words" id="fibPreviewWords"></div>
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

                <%-- Correct Explanation --%>
                <div class="tc-question-builder-exp-block tc-question-builder-exp-correct">
                    <div class="tc-question-builder-exp-block-header">
                        <div class="tc-question-builder-exp-block-icon"><i class="bi bi-check-circle-fill"></i></div>
                        <span class="tc-question-builder-exp-block-label">
                            <asp:Literal ID="litCorrectExpLabel" runat="server" /> *
                        </span>
                        <span class="tc-question-builder-exp-block-count" id="ceCharCount">0 / 500</span>
                    </div>
                    <asp:TextBox ID="txtCorrectExp" runat="server"
                        TextMode="MultiLine" Rows="2"
                        CssClass="tc-question-builder-input tc-question-builder-textarea"
                        MaxLength="500" />
                </div>

                <%-- Wrong Explanation --%>
                <div class="tc-question-builder-exp-block tc-question-builder-exp-wrong">
                    <div class="tc-question-builder-exp-block-header">
                        <div class="tc-question-builder-exp-block-icon"><i class="bi bi-x-circle-fill"></i></div>
                        <span class="tc-question-builder-exp-block-label">
                            <asp:Literal ID="litWrongExpLabel" runat="server" /> *
                        </span>
                        <span class="tc-question-builder-exp-block-count" id="weCharCount">0 / 500</span>
                    </div>
                    <asp:TextBox ID="txtWrongExp" runat="server"
                        TextMode="MultiLine" Rows="2"
                        CssClass="tc-question-builder-input tc-question-builder-textarea"
                        MaxLength="500" />
                </div>

                <%-- Save Status (hidden) --%>
                <div class="tc-question-builder-save-status" id="saveStatus" style="display:none;">
                    <i class="bi bi-circle"></i>
                    <span id="saveStatusText"><%: T("Question Incomplete","Soalan Tidak Lengkap") %></span>
                </div>

            </div><%-- /.tc-question-builder-editor-body --%>

            <%-- Hidden server buttons for postback compatibility --%>
            <div style="display:none;">
                <asp:Button ID="btnPrev" runat="server" Text="? Previous"
                    CssClass="tc-question-builder-btn tc-question-builder-btn-outline"
                    OnClientClick="return navGoTo(window.__CI-1);"
                    CausesValidation="false" />
                <asp:Button ID="btnNext" runat="server" Text="Next ?"
                    CssClass="tc-question-builder-btn tc-question-builder-btn-outline"
                    OnClientClick="return navGoTo(window.__CI+1);"
                    CausesValidation="false" />
                <asp:Button ID="btnSaveQ" runat="server" Text="Save Question"
                    CssClass="tc-question-builder-btn tc-question-builder-btn-primary"
                    OnClientClick="flushToServer();"
                    OnClick="btnSaveQ_Click"
                    CausesValidation="false" />
            </div>

        </div><%-- /.tc-question-builder-center --%>

        <%-- Right Props --%>
        <div class="tc-question-builder-props">
            <div class="tc-question-builder-props-header">
                <div class="tc-question-builder-props-header-icon"><i class="bi bi-sliders"></i></div>
                <div class="tc-question-builder-props-title"><%: T("Properties","Sifat") %></div>
            </div>
            <div class="tc-question-builder-props-body">
                <div class="tc-question-builder-prop-field">
                    <div class="tc-question-builder-prop-label">
                        <span class="tc-question-builder-prop-label-icon type"><i class="bi bi-ui-checks"></i></span>
                        <%: T("Question Type","Jenis Soalan") %>
                    </div>
                    <asp:DropDownList ID="ddlQType" runat="server" CssClass="tc-question-builder-input">
                        <asp:ListItem Value="MCQ" Text="MCQ" />
                        <asp:ListItem Value="True/False" Text="True / False" />
                        <asp:ListItem Value="Multiselect" Text="Multiselect" />
                        <asp:ListItem Value="Drag & Drop" Text="Drag & Drop" />
                    </asp:DropDownList>
                </div>
                <div class="tc-question-builder-prop-field">
                    <div class="tc-question-builder-prop-label">
                        <span class="tc-question-builder-prop-label-icon diff"><i class="bi bi-bar-chart-fill"></i></span>
                        <%: T("Difficulty","Kesukaran") %>
                    </div>
                    <asp:DropDownList ID="ddlQDiff" runat="server" CssClass="tc-question-builder-input">
                        <asp:ListItem Value="Easy" Text="Easy" />
                        <asp:ListItem Value="Medium" Text="Medium" />
                        <asp:ListItem Value="Hard" Text="Hard" />
                    </asp:DropDownList>
                </div>
            </div>
        </div>
        <asp:Literal ID="litPropSubtopic" runat="server" Visible="false" />

    </div><%-- /.tc-question-builder-layout --%>

    <%-- Hidden Fields --%>
    <asp:HiddenField ID="hidCurrentTab" runat="server" Value="EN" />
    <asp:HiddenField ID="hidCurrentIndex" runat="server" Value="0" />
    <asp:HiddenField ID="hidQuestionsJson" runat="server" Value="" />
    <asp:HiddenField ID="hidToast" runat="server" Value="" />
    <asp:HiddenField ID="hidDeleteIndex" runat="server" Value="-1" />
    <asp:HiddenField ID="hidSubmitSuccess" runat="server" Value="" />
    <asp:Button ID="btnDeleteQuestion" runat="server" Style="display:none;" OnClick="btnDeleteQuestion_Click" CausesValidation="false" />
    <asp:Button ID="btnNavGo" runat="server" Style="display:none;" OnClick="btnNavGo_Click" CausesValidation="false" />
    <asp:Literal ID="litQuestionsJson" runat="server" />

    </asp:Panel>

    <%-- Submit Success Modal --%>
    <div class="tc-question-builder-success-overlay" id="qbSuccessOverlay">
        <div class="tc-question-builder-success-modal">
            <div class="tc-question-builder-success-icon"><i class="bi bi-patch-check-fill"></i></div>
            <h3><%: T("Quiz Submitted Successfully","Kuiz Berjaya Dihantar") %></h3>
            <p><%: T("Your questions have been submitted and are now pending review.","Soalan anda telah dihantar dan sedang menunggu semakan.") %></p>
            <a href="<%: ResolveUrl("~/Teacher/manageQuiz.aspx") %>"
                class="tc-question-builder-btn tc-question-builder-btn-primary"
                style="margin-top:.5rem;text-decoration:none;">
                <%: T("Back to Manage Quizzes","Kembali ke Urus Kuiz") %>
            </a>
        </div>
    </div>

    <%-- Unsaved Changes Modal --%>
    <div class="tc-question-builder-unsaved-overlay" id="qbUnsavedOverlay">
        <div class="tc-question-builder-unsaved-modal">
            <div class="tc-question-builder-unsaved-icon"><i class="bi bi-exclamation-triangle-fill"></i></div>
            <h3><%: T("Unsaved Changes","Perubahan Belum Disimpan") %></h3>
            <p><%: T("Your unsaved question will be discarded. Are you sure you want to leave this page?","Soalan anda yang belum disimpan akan dibuang. Adakah anda pasti mahu meninggalkan halaman ini?") %></p>
            <div class="tc-question-builder-unsaved-actions">
                <button type="button" class="tc-question-builder-unsaved-cancel" onclick="closeUnsavedModal()">
                    <%: T("Cancel","Batal") %>
                </button>
                <button type="button" class="tc-question-builder-unsaved-confirm" id="qbUnsavedConfirm">
                    <%: T("Confirm","Sahkan") %>
                </button>
            </div>
        </div>
    </div>

    <div id="qbToast" class="tc-question-builder-toast-container"></div>

</asp:Content>

<%-- Scripts --%>
<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
/* -----------------------------------------------------------
   CLIENT-SIDE QUIZ ENGINE ? no postback for tab/nav switch
   ----------------------------------------------------------- */
function $id(s){return document.getElementById(s);}
function $qs(s){return document.querySelector(s);}

var SRV={
    txtQ:'<%=txtQuestionText.ClientID%>',txtA:'<%=txtOptA.ClientID%>',
    txtB:'<%=txtOptB.ClientID%>',txtC:'<%=txtOptC.ClientID%>',txtD:'<%=txtOptD.ClientID%>',
    txtCE:'<%=txtCorrectExp.ClientID%>',txtWE:'<%=txtWrongExp.ClientID%>',
    radA:'<%=radA.ClientID%>',radB:'<%=radB.ClientID%>',
    radC:'<%=radC.ClientID%>',radD:'<%=radD.ClientID%>',
    ddlType:'<%=ddlQType.ClientID%>',ddlDiff:'<%=ddlQDiff.ClientID%>',
    hidTab:'<%=hidCurrentTab.ClientID%>',hidIdx:'<%=hidCurrentIndex.ClientID%>',
    hidJson:'<%=hidQuestionsJson.ClientID%>',hidDel:'<%=hidDeleteIndex.ClientID%>',
    btnDel:'<%=btnDeleteQuestion.ClientID%>',toast:'<%=hidToast.ClientID%>',
    fuImg:'<%=fuQuestionImage.ClientID%>',hidImgFile:'<%=hidImgFileName.ClientID%>'
};

window.__QD=window.__QD||[];
window.__CI=window.__CI||0;
window.__CT=window.__CT||'EN';
window.__SITE_LANG='<%= CurrentLanguage %>';
function _T(en,bm){return window.__SITE_LANG==='BM'?bm:en;}

/* After server postback, fibIdxEN/fibIdxBM arrive as JSON strings ? parse them back to objects */
(function normFibIdx(){
    window.__QD.forEach(function(q){
        if(typeof q.fibIdxEN==='string'){try{q.fibIdxEN=JSON.parse(q.fibIdxEN);}catch(e){q.fibIdxEN={};}}
        else if(!q.fibIdxEN)q.fibIdxEN={};
        if(typeof q.fibIdxBM==='string'){try{q.fibIdxBM=JSON.parse(q.fibIdxBM);}catch(e){q.fibIdxBM={};}}
        else if(!q.fibIdxBM)q.fibIdxBM={};
        if(!q.fibMapEN)q.fibMapEN=[];
        if(!q.fibMapBM)q.fibMapBM=[];
    });
})();

function emptyQ(){return{
    qEN:'',qBM:'',
    aEN:'',aBM:'',bEN:'',bBM:'',cEN:'',cBM:'',dEN:'',dBM:'',
    ceEN:'',ceBM:'',weEN:'',weBM:'',
    correct:'',type:'MCQ',diff:'Medium',saved:false,img:'',
    /* Multiselect ? per-language option text, SHARED checked state */
    msAEN:'',msABM:'',msBEN:'',msBBM:'',msCEN:'',msCBM:'',msDEN:'',msDBM:'',
    msChk:'',  /* shared comma-separated checked letters e.g. "A,C" ? same for both languages */
    /* Drag & Drop (FIB) ? per-language word bank (4 slots) */
    fibEN:['','','',''],fibBM:['','','',''],
    /* FIB mapping indices per blank per language: {blank_label: slot_index_string} */
    fibIdxEN:{},fibIdxBM:{},
    /* FIB mapping resolved word text per blank in order (for correctAnswer) */
    fibMapEN:[],fibMapBM:[]
};}

/* -- Rich Text Editor ----------------------------------- */
function rteExec(cmd){
    document.execCommand(cmd,false,null);
    rteSync();rteUpdateToolbar();
}
function rteSync(){
    var ed=document.getElementById('qbRteEditor');
    var ta=document.getElementById(SRV.txtQ);
    if(ed&&ta){
        // Build plain text: replace blank chips with their [Blank X] tag
        var clone=ed.cloneNode(true);
        clone.querySelectorAll('.tc-rte-blank-chip').forEach(function(chip){
            chip.replaceWith(chip.getAttribute('data-blank'));
        });
        ta.value=clone.innerText||'';
    }
    updateCharCounts();
}
function rteSetContent(text){
    var ed=document.getElementById('qbRteEditor');
    if(!ed)return;
    // Convert [Blank X] markers to visual chips
    if(text&&/\[Blank \d\]/.test(text)){
        var html=text.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
        html=html.replace(/\[Blank (\d)\]/g,'<span class="tc-rte-blank-chip" contenteditable="false" data-blank="[Blank $1]">_______</span>');
        ed.innerHTML=html;
    } else {
        ed.innerText=text||'';
    }
}
function rteGetText(){
    var ed=document.getElementById('qbRteEditor');
    if(!ed)return'';
    var clone=ed.cloneNode(true);
    clone.querySelectorAll('.tc-rte-blank-chip').forEach(function(chip){
        chip.replaceWith(chip.getAttribute('data-blank'));
    });
    return clone.innerText||'';
}
function rteUpdateToolbar(){
    document.querySelectorAll('.tc-question-builder-tc-rte-btn').forEach(function(btn){btn.classList.remove('active');});
    if(document.queryCommandState('bold'))document.querySelector('.tc-question-builder-tc-rte-btn[title*="Bold"]').classList.add('active');
    if(document.queryCommandState('italic'))document.querySelector('.tc-question-builder-tc-rte-btn[title*="Italic"]').classList.add('active');
    if(document.queryCommandState('underline'))document.querySelector('.tc-question-builder-tc-rte-btn[title*="Underline"]').classList.add('active');
    if(document.queryCommandState('insertUnorderedList')){var b=document.querySelector('.tc-question-builder-tc-rte-btn[title*="Bullet"]');if(b)b.classList.add('active');}
    if(document.queryCommandState('insertOrderedList')){var n=document.querySelector('.tc-question-builder-tc-rte-btn[title*="Numbered"]');if(n)n.classList.add('active');}
}
function rteUpdatePlaceholder(){
    var ed=document.getElementById('qbRteEditor');
    if(ed){ed.setAttribute('data-placeholder',_T(ed.dataset.placeholderEn,ed.dataset.placeholderBm));}
}

function captureCurrentFields(){
    if(!window.__QD.length)return;
    rteSync(); // sync contenteditable ? hidden textarea
    var q=window.__QD[window.__CI],tab=window.__CT;
    var g=function(id){var e=$id(id);return e?e.value:'';};

    /* -- MCQ / shared text fields --------------------------- */
    if(tab==='EN'){q.qEN=g(SRV.txtQ);q.aEN=g(SRV.txtA);q.bEN=g(SRV.txtB);q.cEN=g(SRV.txtC);q.dEN=g(SRV.txtD);q.ceEN=g(SRV.txtCE);q.weEN=g(SRV.txtWE);}
    else{q.qBM=g(SRV.txtQ);q.aBM=g(SRV.txtA);q.bBM=g(SRV.txtB);q.cBM=g(SRV.txtC);q.dBM=g(SRV.txtD);q.ceBM=g(SRV.txtCE);q.weBM=g(SRV.txtWE);}

    /* -- MCQ correct answer --------------------------------- */
    ['A','B','C','D'].forEach(function(l){var r=$id(SRV['rad'+l]);if(r&&r.checked)q.correct=l;});

    /* -- True/False correct answer (separate radio group) --- */
    if(q.type==='True/False'||($id(SRV.ddlType)&&$id(SRV.ddlType).value==='True/False')){
        var tfRadios=document.querySelectorAll('.tc-question-builder-tf-card input[type="radio"]');
        tfRadios.forEach(function(r){if(r.checked)q.correct=r.value;});
    }

    /* -- Multiselect option texts (per language) ----------- */
    var msInputs=document.querySelectorAll('#sectionMS .ms-text');
    var msKeys=(tab==='EN')?['msAEN','msBEN','msCEN','msDEN']:['msABM','msBBM','msCBM','msDBM'];
    msInputs.forEach(function(inp,i){if(msKeys[i]!==undefined)q[msKeys[i]]=inp.value||'';});
    /* Multiselect checked letters ? SHARED across languages */
    var msChecked=[];
    document.querySelectorAll('#sectionMS .ms-check').forEach(function(cb,i){
        if(cb.checked)msChecked.push(['A','B','C','D'][i]);
    });
    /* store as single shared field ? same selection applies to both EN and BM */
    q.msChk=msChecked.join(',');

    /* -- FIB word bank (per language) ---------------------- */
    var fibInputs=document.querySelectorAll('#sectionFIB .tc-fill-blank-word-input');
    var fibArr=[];
    fibInputs.forEach(function(inp){fibArr.push(inp.value||'');});
    if(tab==='EN')q.fibEN=fibArr;
    else q.fibBM=fibArr;

    /* -- FIB mapping ? capture selected slot indices + resolved word text per language --- */
    var fibWordInputsAll=document.querySelectorAll('#sectionFIB .tc-fill-blank-word-input');
    var allWords=[];
    fibWordInputsAll.forEach(function(inp){allWords.push(inp.value||'');});
    /* Save the numeric slot index (1-based string) for each blank, keyed by blank label */
    var fibIdxMap={};
    var fibMappings=[];
    document.querySelectorAll('#fibMappings .tc-fill-blank-map-dd').forEach(function(sel){
        fibIdxMap[sel.dataset.blank]=sel.value||''; /* e.g. {"[Blank 1]":"2"} */
        var idx=sel.value?parseInt(sel.value,10)-1:-1;
        fibMappings.push(idx>=0&&allWords[idx]?allWords[idx]:'');
    });
    if(tab==='EN'){q.fibIdxEN=fibIdxMap;q.fibMapEN=fibMappings;}
    else{q.fibIdxBM=fibIdxMap;q.fibMapBM=fibMappings;}

    var dt=$id(SRV.ddlType);if(dt)q.type=dt.value;
    var dd=$id(SRV.ddlDiff);if(dd)q.diff=dd.value;

    /* -- Image --------------------------------------------- */
    var imgSrc=$id('qbImgPreviewSrc');
    var imgPreview=$id('qbImgPreview');
    if(imgSrc&&imgPreview&&imgPreview.style.display!=='none'&&imgSrc.src&&imgSrc.src!==window.location.href){
        q.img=imgSrc.src;
    }
}

function populateFields(q,tab){
    var isEN=(tab==='EN');
    var s=function(id,v){var e=$id(id);if(e)e.value=v||'';};

    /* -- MCQ / shared text fields --------------------------- */
    s(SRV.txtQ,isEN?q.qEN:q.qBM);
    rteSetContent(isEN?q.qEN:q.qBM); // sync RTE editor with stored text
    s(SRV.txtA,isEN?q.aEN:q.aBM);s(SRV.txtB,isEN?q.bEN:q.bBM);
    s(SRV.txtC,isEN?q.cEN:q.cBM);s(SRV.txtD,isEN?q.dEN:q.dBM);
    s(SRV.txtCE,isEN?q.ceEN:q.ceBM);s(SRV.txtWE,isEN?q.weEN:q.weBM);

    /* -- MCQ correct answer radio -------------------------- */
    ['A','B','C','D'].forEach(function(l){var r=$id(SRV['rad'+l]);if(r)r.checked=(q.correct===l);});

    /* -- True/False correct answer (separate radio group) --- */
    document.querySelectorAll('.tc-question-builder-tf-card input[type="radio"]').forEach(function(r){
        r.checked=(q.correct===r.value);
    });
    updateTFCards();

    /* -- Multiselect option texts (per language) ----------- */
    var msInputs=document.querySelectorAll('#sectionMS .ms-text');
    var msVals=isEN?[q.msAEN,q.msBEN,q.msCEN,q.msDEN]:[q.msABM,q.msBBM,q.msCBM,q.msDBM];
    msInputs.forEach(function(inp,i){inp.value=msVals[i]||'';});
    /* Restore multiselect checked state ? SHARED, same for both languages */
    var chkStr=q.msChk||'';
    var chkLetters=chkStr?chkStr.split(','):[];
    var letters=['A','B','C','D'];
    document.querySelectorAll('#sectionMS .ms-check').forEach(function(cb,i){
        cb.checked=chkLetters.indexOf(letters[i])>-1;
    });
    updateMSCards();

    /* -- FIB word bank (per language) ---------------------- */
    var fibArr=isEN?(q.fibEN||['','','','']):(q.fibBM||['','','','']);
    document.querySelectorAll('#sectionFIB .tc-fill-blank-word-input').forEach(function(inp,i){
        inp.value=fibArr[i]||'';
    });
    /* Rebuild the mapping dropdowns using this language's stored indices */
    /* (updateFibUI calls updateFibMappings which reads fibIdxEN/fibIdxBM from the store) */

    /* -- Type / Difficulty --------------------------------- */
    var dt=$id(SRV.ddlType);if(dt&&q.type)dt.value=q.type;
    var dd=$id(SRV.ddlDiff);if(dd&&q.diff)dd.value=q.diff;

    /* -- Image --------------------------------------------- */
    var imgPreview=$id('qbImgPreview');
    var imgSrc=$id('qbImgPreviewSrc');
    var imgLabel=$id('qbImgUploadLabel');
    if(q.img){
        if(imgSrc)imgSrc.src=q.img;
        if(imgPreview)imgPreview.style.display='block';
        if(imgLabel)imgLabel.style.display='none';
    } else {
        if(imgSrc)imgSrc.src='';
        if(imgPreview)imgPreview.style.display='none';
        if(imgLabel)imgLabel.style.display='flex';
    }

    switchQuestionType();updateAnswerCards();updateCharCounts();updateFibUI();
}

function updateLabels(tab){
    var isEN=(tab==='EN');
    // Update language badge (shows which content tab is active)
    var badge=document.getElementById('qbLangBadge');
    if(badge){badge.textContent=isEN?'EN':'BM';badge.style.background=isEN?'#D1FAE5':'#FEF3C7';badge.style.color=isEN?'#047857':'#92400E';}
    // Section headers indicate which language content is being edited
    var ol=$qs('#sectionMCQ .tc-question-builder-section-header-text');
    if(ol)ol.textContent=isEN?_T('Options (English)','Pilihan (Bahasa Inggeris)'):_T('Options (Bahasa Melayu)','Pilihan (Bahasa Melayu)');
    var ce=$qs('.tc-question-builder-exp-correct .tc-question-builder-exp-block-label');
    if(ce)ce.textContent=(isEN?_T('Correct Explanation (EN)','Penjelasan Betul (EN)'):_T('Correct Explanation (BM)','Penjelasan Betul (BM)'))+' *';
    var we=$qs('.tc-question-builder-exp-wrong .tc-question-builder-exp-block-label');
    if(we)we.textContent=(isEN?_T('Wrong Explanation (EN)','Penjelasan Salah (EN)'):_T('Wrong Explanation (BM)','Penjelasan Salah (BM)'))+' *';
    // Placeholders follow website language, NOT the active tab
    var ph=function(id,en,bm){var el=$id(id);if(el)el.placeholder=_T(en,bm);};
    ph(SRV.txtQ,'Type your question here...','Taip soalan anda di sini...');
    rteUpdatePlaceholder();
    ph(SRV.txtA,'Enter option A...','Masukkan pilihan A...');
    ph(SRV.txtB,'Enter option B...','Masukkan pilihan B...');
    ph(SRV.txtC,'Enter option C...','Masukkan pilihan C...');
    ph(SRV.txtD,'Enter option D...','Masukkan pilihan D...');
    ph(SRV.txtCE,'Explain why this answer is correct...','Terangkan mengapa jawapan ini betul...');
    ph(SRV.txtWE,'Explain why the other answers are incorrect...','Terangkan mengapa jawapan lain salah...');
    // True/False card labels follow the active content tab language
    var tfTL=document.getElementById('tfTrueLabel');
    var tfFL=document.getElementById('tfFalseLabel');
    if(tfTL)tfTL.textContent=isEN?'TRUE':'BETUL';
    if(tfFL)tfFL.textContent=isEN?'FALSE':'SALAH';
    // Update navigation label
    updateNavLabel();
}
function updateNavLabel(){
    var lbl=document.getElementById('qbNavLabel');
    var prev=document.getElementById('qbNavPrev');
    var next=document.getElementById('qbNavNext');
    var total=window.__QD?window.__QD.length:1;
    var current=(window.__CI||0)+1;
    if(lbl)lbl.textContent=_T('Question '+current+' of '+total,'Soalan '+current+' daripada '+total);
    if(prev){prev.disabled=(current<=1);prev.style.opacity=(current<=1)?'.35':'1';}
    if(next){next.disabled=(current>=total);next.style.opacity=(current>=total)?'.35':'1';}
}

function switchTab(tab){
    captureCurrentFields();window.__CT=tab;
    var q=window.__QD[window.__CI]||emptyQ();
    populateFields(q,tab);updateLabels(tab);
    var en=$qs('[id$="btnTabEN"]'),bm=$qs('[id$="btnTabBM"]');
    if(en)en.className=(tab==='EN')?'tc-question-builder-tab active':'tc-question-builder-tab';
    if(bm)bm.className=(tab==='BM')?'tc-question-builder-tab active':'tc-question-builder-tab';
    var ht=$id(SRV.hidTab);if(ht)ht.value=tab;
}

function navGoTo(idx){
    if(idx<0||idx>=window.__QD.length)return false;
    captureCurrentFields();window.__CI=idx;
    var q=window.__QD[idx];populateFields(q,window.__CT);updateLabels(window.__CT);
    document.querySelectorAll('.tc-question-builder-nav-item').forEach(function(el,i){
        el.className='tc-question-builder-nav-item'+(i===idx?' active':'')+(window.__QD[i]&&window.__QD[i].saved?' done':'');
    });
    updateNavLabel();
    updateProgress();return false;
}

/* -- Inline field validation helpers ----------------------- */
var ERR_MSG=_T('Please fill in the required field.','Sila isi ruangan yang diperlukan.');

/* Returns the element after which the message should be inserted.
   We always want the message OUTSIDE the coloured container card. */
function qbMsgAnchor(el){
    var expBlock=el.closest ? el.closest('.tc-question-builder-exp-block') : null;
    if(expBlock)return expBlock;
    var heroBlock=el.closest ? el.closest('.tc-question-builder-question-hero') : null;
    if(heroBlock)return heroBlock;
    return el;
}

function qbSetErr(el,customMsg){
    if(!el)return;
    el.classList.add('tc-question-builder-err');
    var anchor=qbMsgAnchor(el);
    var next=anchor.nextElementSibling;
    if(next&&next.classList.contains('tc-question-builder-err-msg'))next.remove();
    var msg=document.createElement('div');
    msg.className='tc-question-builder-err-msg';
    msg.innerHTML='<i class="bi bi-exclamation-circle-fill" style="font-size:13px;flex-shrink:0;"></i> '+(customMsg||ERR_MSG);
    anchor.parentNode.insertBefore(msg,anchor.nextSibling);
}

/* Mark individual empty inputs with red border; place ONE message after the grid */
function qbSetGridErr(gridEl,inputs,customMsg){
    if(!gridEl)return;
    inputs.forEach(function(inp){if(inp)inp.classList.add('tc-question-builder-err');});
    var next=gridEl.nextElementSibling;
    if(next&&next.classList.contains('tc-question-builder-err-msg'))next.remove();
    var msg=document.createElement('div');
    msg.className='tc-question-builder-err-msg';
    msg.innerHTML='<i class="bi bi-exclamation-circle-fill" style="font-size:13px;flex-shrink:0;"></i> '+(customMsg||ERR_MSG);
    gridEl.parentNode.insertBefore(msg,gridEl.nextSibling);
}

function qbClearErr(el){
    if(!el)return;
    el.classList.remove('tc-question-builder-err');
    var anchor=qbMsgAnchor(el);
    var next=anchor.nextElementSibling;
    if(next&&next.classList.contains('tc-question-builder-err-msg'))next.remove();
    if(anchor!==el){next=el.nextElementSibling;if(next&&next.classList.contains('tc-question-builder-err-msg'))next.remove();}
}
function qbClearAllErrors(){
    document.querySelectorAll('.tc-question-builder-err').forEach(function(el){el.classList.remove('tc-question-builder-err');});
    document.querySelectorAll('.tc-question-builder-err-msg').forEach(function(el){el.remove();});
}
function qbWireAutoClears(){
    document.querySelectorAll('textarea,input[type="text"],select').forEach(function(el){
        el.addEventListener('input',function(){
            qbClearErr(el);
            var grid=el.closest('.tc-question-builder-opts,.tc-question-builder-tf-grid,.tc-question-builder-tc-fill-blank-words');
            if(grid){var next=grid.nextElementSibling;if(next&&next.classList.contains('tc-question-builder-err-msg'))next.remove();}
        });
        el.addEventListener('change',function(){qbClearErr(el);});
    });
    document.querySelectorAll('.ms-check,input[type="radio"]').forEach(function(el){
        el.addEventListener('change',function(){
            var grid=el.closest('.tc-question-builder-opts,.tc-question-builder-tf-grid');
            if(grid){var next=grid.nextElementSibling;if(next&&next.classList.contains('tc-question-builder-err-msg'))next.remove();}
        });
    });
}

/* -- Full client-side submit validation --------------------- */
function validateAllQuestions(){
    for(var i=0;i<window.__QD.length;i++){
        var q=window.__QD[i];
        var qType=q.type||'MCQ';
        navGoTo(i);

        /* -- EN question text --- */
        switchTab('EN');
        var txQ=$id(SRV.txtQ);
        if(!txQ||!txQ.value.trim()){qbSetErr(txQ);return{ok:false,qIdx:i,tab:'EN',firstEl:txQ};}

        /* -- BM question text --- */
        switchTab('BM');
        txQ=$id(SRV.txtQ);
        if(!txQ||!txQ.value.trim()){qbSetErr(txQ);return{ok:false,qIdx:i,tab:'BM',firstEl:txQ};}

        /* -- EN explanations --- */
        switchTab('EN');
        var txCE=$id(SRV.txtCE);
        if(!txCE||!txCE.value.trim()){qbSetErr(txCE);return{ok:false,qIdx:i,tab:'EN',firstEl:txCE};}
        var txWE=$id(SRV.txtWE);
        if(!txWE||!txWE.value.trim()){qbSetErr(txWE);return{ok:false,qIdx:i,tab:'EN',firstEl:txWE};}

        /* -- BM explanations --- */
        switchTab('BM');
        txCE=$id(SRV.txtCE);
        if(!txCE||!txCE.value.trim()){qbSetErr(txCE);return{ok:false,qIdx:i,tab:'BM',firstEl:txCE};}
        txWE=$id(SRV.txtWE);
        if(!txWE||!txWE.value.trim()){qbSetErr(txWE);return{ok:false,qIdx:i,tab:'BM',firstEl:txWE};}

        /* -- MCQ --- */
        if(qType==='MCQ'){
            switchTab('EN');
            var mcqGrid=$qs('#sectionMCQ .tc-question-builder-opts');
            var tA=$id(SRV.txtA),tB=$id(SRV.txtB);
            var emptyEN=[];
            if(!tA||!tA.value.trim())emptyEN.push(tA);
            if(!tB||!tB.value.trim())emptyEN.push(tB);
            if(emptyEN.length){qbSetGridErr(mcqGrid,emptyEN);return{ok:false,qIdx:i,tab:'EN',firstEl:emptyEN[0]};}
            switchTab('BM');
            var tAbm=$id(SRV.txtA),tBbm=$id(SRV.txtB);
            var emptyBM=[];
            if(!tAbm||!tAbm.value.trim())emptyBM.push(tAbm);
            if(!tBbm||!tBbm.value.trim())emptyBM.push(tBbm);
            if(emptyBM.length){qbSetGridErr($qs('#sectionMCQ .tc-question-builder-opts'),emptyBM);return{ok:false,qIdx:i,tab:'BM',firstEl:emptyBM[0]};}
            /* No correct answer selected */
            switchTab('EN');
            if(!q.correct){
                qbSetGridErr($qs('#sectionMCQ .tc-question-builder-opts'),[],_T('Please select the correct answer.','Sila pilih jawapan yang betul.'));
                return{ok:false,qIdx:i,tab:'EN',firstEl:$qs('#sectionMCQ .tc-question-builder-opts')};
            }
            /* Correct answer points to an empty option */
            var correctInput=$id({'A':SRV.txtA,'B':SRV.txtB,'C':SRV.txtC,'D':SRV.txtD}[q.correct]);
            if(!correctInput||!correctInput.value.trim()){
                qbSetGridErr($qs('#sectionMCQ .tc-question-builder-opts'),[correctInput],_T('Please fill in the required field.','Sila isi ruangan yang diperlukan.'));
                return{ok:false,qIdx:i,tab:'EN',firstEl:correctInput||$qs('#sectionMCQ .tc-question-builder-opts')};
            }
            /* Correct answer must have text in both EN and BM */
            var correctENVal={'A':q.aEN,'B':q.bEN,'C':q.cEN,'D':q.dEN}[q.correct]||'';
            var correctBMVal={'A':q.aBM,'B':q.bBM,'C':q.cBM,'D':q.dBM}[q.correct]||'';
            if(!correctENVal.trim()){
                switchTab('EN');
                qbSetGridErr($qs('#sectionMCQ .tc-question-builder-opts'),[],_T('The selected correct answer must contain answer text in both English and Bahasa Melayu.','Jawapan betul yang dipilih mesti mempunyai teks jawapan dalam Bahasa Inggeris dan Bahasa Melayu.'));
                return{ok:false,qIdx:i,tab:'EN',firstEl:$qs('#sectionMCQ .tc-question-builder-opts')};
            }
            if(!correctBMVal.trim()){
                switchTab('BM');
                qbSetGridErr($qs('#sectionMCQ .tc-question-builder-opts'),[],_T('The selected correct answer must contain answer text in both English and Bahasa Melayu.','Jawapan betul yang dipilih mesti mempunyai teks jawapan dalam Bahasa Inggeris dan Bahasa Melayu.'));
                return{ok:false,qIdx:i,tab:'BM',firstEl:$qs('#sectionMCQ .tc-question-builder-opts')};
            }
            /* EN/BM must use the same option letters */
            var mcqLettersEN=((q.aEN||'').trim()?'A':'')+((q.bEN||'').trim()?'B':'')+((q.cEN||'').trim()?'C':'')+((q.dEN||'').trim()?'D':'');
            var mcqLettersBM=((q.aBM||'').trim()?'A':'')+((q.bBM||'').trim()?'B':'')+((q.cBM||'').trim()?'C':'')+((q.dBM||'').trim()?'D':'');
            if(mcqLettersEN!==mcqLettersBM){
                if(mcqLettersEN.length>=mcqLettersBM.length){
                    switchTab('BM');
                    qbSetGridErr($qs('#sectionMCQ .tc-question-builder-opts'),[],_T('The English and Bahasa Melayu sections must use the same answer options.','Bahagian Bahasa Inggeris dan Bahasa Melayu mesti menggunakan pilihan jawapan yang sama.'));
                    return{ok:false,qIdx:i,tab:'BM',firstEl:$qs('#sectionMCQ .tc-question-builder-opts')};
                }else{
                    switchTab('EN');
                    qbSetGridErr($qs('#sectionMCQ .tc-question-builder-opts'),[],_T('The English and Bahasa Melayu sections must use the same answer options.','Bahagian Bahasa Inggeris dan Bahasa Melayu mesti menggunakan pilihan jawapan yang sama.'));
                    return{ok:false,qIdx:i,tab:'EN',firstEl:$qs('#sectionMCQ .tc-question-builder-opts')};
                }
            }
        }

        /* -- True / False --- */
        if(qType==='True/False'){
            switchTab('EN');
            if(!q.correct){
                var tfGrid=$qs('#sectionTF .tc-question-builder-tf-grid');
                qbSetGridErr(tfGrid,[],_T('Please select the correct answer.','Sila pilih jawapan yang betul.'));
                return{ok:false,qIdx:i,tab:'EN',firstEl:tfGrid};
            }
        }

        /* -- Multiselect --- */
        if(qType==='Multiselect'){
            /* At least 3 answer options required (EN) */
            switchTab('EN');
            var msGrid=$qs('#sectionMS .tc-question-builder-opts');
            var msTxEN=document.querySelectorAll('#sectionMS .ms-text');
            var filledMsEN=Array.prototype.slice.call(msTxEN).filter(function(inp){return inp.value.trim();}).length;
            if(filledMsEN<3){
                var emptyMsEN=Array.prototype.slice.call(msTxEN).filter(function(inp){return!inp.value.trim();});
                qbSetGridErr(msGrid,emptyMsEN.slice(0,3-filledMsEN),_T('Multi-select questions must contain at least three answer options.','Soalan Aneka Pilihan Berbilang mesti mempunyai sekurang-kurangnya tiga pilihan jawapan.'));
                return{ok:false,qIdx:i,tab:'EN',firstEl:emptyMsEN[0]||msGrid};
            }
            /* At least 3 answer options required (BM) */
            switchTab('BM');
            var msTxBM=document.querySelectorAll('#sectionMS .ms-text');
            var filledMsBM=Array.prototype.slice.call(msTxBM).filter(function(inp){return inp.value.trim();}).length;
            if(filledMsBM<3){
                var emptyMsBM=Array.prototype.slice.call(msTxBM).filter(function(inp){return!inp.value.trim();});
                qbSetGridErr($qs('#sectionMS .tc-question-builder-opts'),emptyMsBM.slice(0,3-filledMsBM),_T('Multi-select questions must contain at least three answer options.','Soalan Aneka Pilihan Berbilang mesti mempunyai sekurang-kurangnya tiga pilihan jawapan.'));
                return{ok:false,qIdx:i,tab:'BM',firstEl:emptyMsBM[0]||$qs('#sectionMS .tc-question-builder-opts')};
            }
            /* Correct answer count */
            switchTab('EN');
            var chkLetters=(q.msChk||'').split(',').filter(function(l){return l.trim();});
            if(chkLetters.length<2){
                qbSetGridErr($qs('#sectionMS .tc-question-builder-opts'),[],_T('Please select at least two correct answers for a Multi-select question.','Sila pilih sekurang-kurangnya dua jawapan yang betul.'));
                return{ok:false,qIdx:i,tab:'EN',firstEl:$qs('#sectionMS .tc-question-builder-opts')};
            }
            /* Ensure each selected correct answer has text in both EN and BM */
            var msMap={'A':0,'B':1,'C':2,'D':3};
            var msENVals=[q.msAEN,q.msBEN,q.msCEN,q.msDEN];
            var msBMVals=[q.msABM,q.msBBM,q.msCBM,q.msDBM];
            var badChkEN=[];var badChkBM=[];
            chkLetters.forEach(function(l){
                var j=msMap[l];
                if(j!==undefined){
                    if(!(msENVals[j]||'').trim())badChkEN.push(l);
                    if(!(msBMVals[j]||'').trim())badChkBM.push(l);
                }
            });
            if(badChkEN.length){
                switchTab('EN');
                var msTxCheckEN=document.querySelectorAll('#sectionMS .ms-text');
                var highlightEN=badChkEN.map(function(l){return msTxCheckEN[msMap[l]];}).filter(Boolean);
                qbSetGridErr($qs('#sectionMS .tc-question-builder-opts'),highlightEN,_T('All selected correct answers must contain answer text in both English and Bahasa Melayu.','Semua jawapan betul yang dipilih mesti mempunyai teks jawapan dalam Bahasa Inggeris dan Bahasa Melayu.'));
                return{ok:false,qIdx:i,tab:'EN',firstEl:highlightEN[0]||$qs('#sectionMS .tc-question-builder-opts')};
            }
            if(badChkBM.length){
                switchTab('BM');
                var msTxCheckBM=document.querySelectorAll('#sectionMS .ms-text');
                var highlightBM=badChkBM.map(function(l){return msTxCheckBM[msMap[l]];}).filter(Boolean);
                qbSetGridErr($qs('#sectionMS .tc-question-builder-opts'),highlightBM,_T('All selected correct answers must contain answer text in both English and Bahasa Melayu.','Semua jawapan betul yang dipilih mesti mempunyai teks jawapan dalam Bahasa Inggeris dan Bahasa Melayu.'));
                return{ok:false,qIdx:i,tab:'BM',firstEl:highlightBM[0]||$qs('#sectionMS .tc-question-builder-opts')};
            }
            /* EN/BM must use the same option letters */
            var msLettersEN=((q.msAEN||'').trim()?'A':'')+((q.msBEN||'').trim()?'B':'')+((q.msCEN||'').trim()?'C':'')+((q.msDEN||'').trim()?'D':'');
            var msLettersBM=((q.msABM||'').trim()?'A':'')+((q.msBBM||'').trim()?'B':'')+((q.msCBM||'').trim()?'C':'')+((q.msDBM||'').trim()?'D':'');
            if(msLettersEN!==msLettersBM){
                if(msLettersEN.length>=msLettersBM.length){
                    switchTab('BM');
                    qbSetGridErr($qs('#sectionMS .tc-question-builder-opts'),[],_T('The English and Bahasa Melayu sections must use the same answer options.','Bahagian Bahasa Inggeris dan Bahasa Melayu mesti menggunakan pilihan jawapan yang sama.'));
                    return{ok:false,qIdx:i,tab:'BM',firstEl:$qs('#sectionMS .tc-question-builder-opts')};
                }else{
                    switchTab('EN');
                    qbSetGridErr($qs('#sectionMS .tc-question-builder-opts'),[],_T('The English and Bahasa Melayu sections must use the same answer options.','Bahagian Bahasa Inggeris dan Bahasa Melayu mesti menggunakan pilihan jawapan yang sama.'));
                    return{ok:false,qIdx:i,tab:'EN',firstEl:$qs('#sectionMS .tc-question-builder-opts')};
                }
            }
        }

        /* -- Drag & Drop --- */
        if(qType==='Drag & Drop'){
            var blankRe=/\[Blank \d\]/g;
            var enC=((q.qEN||'').match(blankRe)||[]).length;
            var bmC=((q.qBM||'').match(blankRe)||[]).length;

            /* EN/BM blank count mismatch */
            if(enC!==bmC){
                switchTab('EN');
                var tqMismatch=$id(SRV.txtQ);
                qbSetErr(tqMismatch,_T('The number of blanks in English and Bahasa Melayu must match.','Bilangan kosong dalam Bahasa Inggeris dan Bahasa Melayu mesti sama.'));
                return{ok:false,qIdx:i,tab:'EN',firstEl:tqMismatch};
            }

            /* At least 1 blank required */
            if(enC<1){
                switchTab('EN');
                var tqBlank=$id(SRV.txtQ);
                qbSetErr(tqBlank,_T('At least one blank is required.','Sekurang-kurangnya satu kosong diperlukan.'));
                return{ok:false,qIdx:i,tab:'EN',firstEl:tqBlank};
            }

            /* EN word bank: min 2 */
            switchTab('EN');
            var fibGridEN=$qs('#sectionFIB .tc-question-builder-tc-fill-blank-words');
            var enW=(q.fibEN||[]).filter(function(s){return s&&s.trim();});
            if(enW.length<2){
                var fibInEN=document.querySelectorAll('#sectionFIB .tc-fill-blank-word-input');
                var emptyFibEN=Array.prototype.slice.call(fibInEN).filter(function(el){return!el.value.trim();});
                qbSetGridErr(fibGridEN,emptyFibEN.slice(0,Math.max(1,2-enW.length)),
                    _T('At least two answer options are required.','Sekurang-kurangnya dua pilihan jawapan diperlukan.'));
                return{ok:false,qIdx:i,tab:'EN',firstEl:emptyFibEN[0]||fibGridEN};
            }

            /* BM word bank: min 2 */
            switchTab('BM');
            var fibGridBM=$qs('#sectionFIB .tc-question-builder-tc-fill-blank-words');
            var bmW=(q.fibBM||[]).filter(function(s){return s&&s.trim();});
            if(bmW.length<2){
                var fibInBM=document.querySelectorAll('#sectionFIB .tc-fill-blank-word-input');
                var emptyFibBM=Array.prototype.slice.call(fibInBM).filter(function(el){return!el.value.trim();});
                qbSetGridErr(fibGridBM,emptyFibBM.slice(0,Math.max(1,2-bmW.length)),
                    _T('At least two answer options are required.','Sekurang-kurangnya dua pilihan jawapan diperlukan.'));
                return{ok:false,qIdx:i,tab:'BM',firstEl:emptyFibBM[0]||fibGridBM};
            }

            /* EN mapping: count must equal blank count */
            switchTab('EN');
            var enMapped=(q.fibMapEN||[]).filter(function(s){return s&&s.trim();});
            if(enMapped.length===0){
                var mapSectionEN=$id('fibMappingSection');
                qbSetGridErr(mapSectionEN||$qs('#sectionFIB .tc-question-builder-tc-fill-blank-words'),[],
                    _T('Please select the correct mapping order.','Sila pilih susunan pemetaan yang betul.'));
                return{ok:false,qIdx:i,tab:'EN',firstEl:mapSectionEN};
            }
            if(enMapped.length!==enC){
                var mapSectionEN2=$id('fibMappingSection');
                qbSetGridErr(mapSectionEN2||$qs('#sectionFIB .tc-question-builder-tc-fill-blank-words'),[],
                    _T('The number of mappings must match the number of blanks.','Bilangan pemetaan mesti sama dengan bilangan kosong.'));
                return{ok:false,qIdx:i,tab:'EN',firstEl:mapSectionEN2};
            }

            /* BM mapping: count must equal blank count */
            switchTab('BM');
            var bmMapped=(q.fibMapBM||[]).filter(function(s){return s&&s.trim();});
            if(bmMapped.length===0){
                var mapSectionBM=$id('fibMappingSection');
                qbSetGridErr(mapSectionBM||$qs('#sectionFIB .tc-question-builder-tc-fill-blank-words'),[],
                    _T('Please select the correct mapping order.','Sila pilih susunan pemetaan yang betul.'));
                return{ok:false,qIdx:i,tab:'BM',firstEl:mapSectionBM};
            }
            if(bmMapped.length!==bmC){
                var mapSectionBM2=$id('fibMappingSection');
                qbSetGridErr(mapSectionBM2||$qs('#sectionFIB .tc-question-builder-tc-fill-blank-words'),[],
                    _T('The number of mappings must match the number of blanks.','Bilangan pemetaan mesti sama dengan bilangan kosong.'));
                return{ok:false,qIdx:i,tab:'BM',firstEl:mapSectionBM2};
            }
        }
    }
    return{ok:true};
}

/* -- Validate then flush ------------------------------------ */
function validateFibBlanksAndFlush(){
    captureCurrentFields();
    qbClearAllErrors();
    var result=validateAllQuestions();
    if(!result.ok){
        navGoTo(result.qIdx);
        switchTab(result.tab);
        if(result.firstEl){
            try{result.firstEl.scrollIntoView({behavior:'smooth',block:'center'});}catch(e){}
            try{result.firstEl.focus();}catch(e){}
        }
        return false;
    }
    flushToServer();
    return true;
}

function flushToServer(){
    captureCurrentFields();
    /* Sync Multiselect / FIB text into the server txtOpt* controls for the active tab */
    var dt=$id(SRV.ddlType);
    if(dt){
        var isEN=(window.__CT==='EN');
        var q=window.__QD[window.__CI];
        if(q&&dt.value==='Multiselect'){
            var s=function(id,v){var e=$id(id);if(e)e.value=v||'';};
            s(SRV.txtA,isEN?q.msAEN:q.msABM);s(SRV.txtB,isEN?q.msBEN:q.msBBM);
            s(SRV.txtC,isEN?q.msCEN:q.msCBM);s(SRV.txtD,isEN?q.msDEN:q.msDBM);
        }
        if(q&&dt.value==='Drag & Drop'){
            var fibArr=isEN?(q.fibEN||[]):(q.fibBM||[]);
            var fibIds=[SRV.txtA,SRV.txtB,SRV.txtC,SRV.txtD];
            fibIds.forEach(function(id,i){var e=$id(id);if(e)e.value=fibArr[i]||'';});
        }
    }
    var hj=$id(SRV.hidJson);if(hj)hj.value=JSON.stringify(window.__QD);
    var hi=$id(SRV.hidIdx);if(hi)hi.value=window.__CI;
    var ht=$id(SRV.hidTab);if(ht)ht.value=window.__CT;
}

function showToast(m){var c=$id('qbToast'),t=document.createElement('div');t.className='tc-question-builder-toast';t.innerHTML='<i class="bi bi-check-circle-fill"></i> '+m;c.appendChild(t);setTimeout(function(){t.style.opacity='0';},3e3);setTimeout(function(){t.remove();},3500);}

function switchQuestionType(){
    var sel=$id(SRV.ddlType);if(!sel)return;var v=sel.value;
    $id('sectionMCQ').style.display=(v==='MCQ')?'block':'none';
    $id('sectionTF').style.display=(v==='True/False')?'block':'none';
    $id('sectionMS').style.display=(v==='Multiselect')?'block':'none';
    $id('sectionFIB').style.display=(v==='Drag & Drop')?'block':'none';
    // Show/hide Add Blank in toolbar
    var isFIB=(v==='Drag & Drop');
    document.querySelectorAll('.tc-question-builder-tc-fill-blank-only').forEach(function(el){el.style.display=isFIB?'':'none';});
}
function updateAnswerCards(){
    document.querySelectorAll('#sectionMCQ .tc-question-builder-opt').forEach(function(o){
        o.classList.remove('correct');
        // Toggle has-text based on whether the option input has text
        var inp=o.querySelector('.tc-question-builder-opt-input');
        if(inp&&inp.value.trim())o.classList.add('has-text');
        else o.classList.remove('has-text');
    });
    document.querySelectorAll('#sectionMCQ .tc-question-builder-opt input[type="radio"]').forEach(function(r){
        if(r.checked){
            var card=r.closest('.tc-question-builder-opt');
            // Only mark correct if the option has text
            var inp=card.querySelector('.tc-question-builder-opt-input');
            if(inp&&inp.value.trim())card.classList.add('correct');
        }
    });
}
function selectCorrectOpt(el){
    var card=el.closest('.tc-question-builder-opt');
    var radio=card.querySelector('input[type="radio"]');
    if(radio){radio.checked=true;updateAnswerCards();}
    if(window.__QD&&window.__QD[window.__CI]&&radio)window.__QD[window.__CI].correct=radio.value;
}
function updateTFCards(){
    document.querySelectorAll('.tc-question-builder-tf-card').forEach(function(c){c.classList.remove('selected');});
    document.querySelectorAll('.tc-question-builder-tf-card input[type="radio"]').forEach(function(r){if(r.checked)r.closest('.tc-question-builder-tf-card').classList.add('selected');});
}
function updateMSCards(){
    var count=0;
    document.querySelectorAll('.tc-question-builder-ms-opt').forEach(function(o){var cb=o.querySelector('.ms-check');if(cb&&cb.checked){o.classList.add('selected');count++;}else o.classList.remove('selected');});
    var el=$id('msCount');if(el)el.textContent=count+' <%: T("selected","dipilih") %>';
}
function addBlank(){
    var btn=$id('btnAddBlank');if(btn.classList.contains('disabled'))return;
    var ed=document.getElementById('qbRteEditor');if(!ed)return;
    var text=ed.innerText||'';
    var count=(text.match(/\[Blank \d\]/g)||[]).length;
    if(count>=4)return;
    var blankTag='[Blank '+(count+1)+']';
    // Insert a styled blank element into contenteditable
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
        // Move cursor after the blank
        range.setStartAfter(span);range.setEndAfter(span);
        sel.removeAllRanges();sel.addRange(range);
    } else {
        ed.appendChild(span);
    }
    rteSync();updateFibUI();
}
function onFibWordChange(){updateFibMappings();updateFibPreview();}
function updateFibUI(){
    var text=rteGetText();
    var blanks=(text.match(/\[Blank \d\]/g)||[]),count=blanks.length;
    var numEl=$id('blankNum');if(numEl)numEl.textContent=count;
    var ctr=$qs('.tc-fill-blank-counter');if(ctr)ctr.classList.toggle('full',count>=4);
    var btn=$id('btnAddBlank');
    var warn=$id('blankWarning');
    if(btn){if(count>=4){btn.classList.add('disabled');if(warn)warn.style.display='flex';}else{btn.classList.remove('disabled');if(warn)warn.style.display='none';}}
    var ms=$id('fibMappingSection'),ps=$id('fibPreviewSection');
    if(count>0){if(ms)ms.style.display='block';if(ps)ps.style.display='block';updateFibMappings();updateFibPreview();}
    else{if(ms)ms.style.display='none';if(ps)ps.style.display='none';}
}
function updateFibMappings(){
    var text=rteGetText();
    var blanks=(text.match(/\[Blank \d\]/g)||[]),words=[];
    document.querySelectorAll('.tc-fill-blank-word-input').forEach(function(i){if(i.value.trim())words.push(i.value.trim());});
    var container=$id('fibMappings');
    /* Use the stored index map for the current language ? not the live DOM ? so EN and BM are independent */
    var q=window.__QD[window.__CI];
    var storedIdx=(window.__CT==='EN')?((q&&q.fibIdxEN)||{}):((q&&q.fibIdxBM)||{});
    var html='';
    blanks.forEach(function(b){
        var selectedVal=storedIdx[b]||'';
        var opts='<option value="">-- <%: T("Select word","Pilih perkataan") %> --</option>';
        words.forEach(function(w,wi){opts+='<option value="'+(wi+1)+'"'+(selectedVal===''+(wi+1)?' selected':'')+'>'+w+'</option>';});
        html+='<div class="tc-question-builder-tc-fill-blank-map-row'+(selectedVal?' valid':'')+'"><span class="tc-question-builder-tc-fill-blank-map-label">'+b+'</span><span class="tc-question-builder-tc-fill-blank-map-arrow"><i class="bi bi-arrow-right"></i></span><select class="tc-question-builder-tc-fill-blank-map-select tc-fill-blank-map-dd" data-blank="'+b+'" onchange="validateFibMapping()">'+opts+'</select><span class="tc-question-builder-tc-fill-blank-map-check"><i class="bi bi-check-circle-fill"></i></span></div>';
    });
    container.innerHTML=html;updateFibPreview();
}
function validateFibMapping(){
    var selects=document.querySelectorAll('.tc-fill-blank-map-dd'),vals=[],dup=false;
    selects.forEach(function(s){var row=s.closest('.tc-question-builder-tc-fill-blank-map-row');row.classList.remove('invalid');s.classList.remove('invalid');if(s.value){if(vals.indexOf(s.value)>-1){dup=true;row.classList.add('invalid');s.classList.add('invalid');}else row.classList.add('valid');vals.push(s.value);}else row.classList.remove('valid');});
    $id('fibMappingError').style.display=dup?'flex':'none';
}
function updateFibPreview(){
    var text=rteGetText();
    var html=text.replace(/\[Blank \d\]/g,'<span class="tc-fill-blank-blank">_____</span>');
    $id('fibPreviewText').innerHTML=html||'<em style="color:var(--tc-muted);"><%: T("Type your question with blanks...","Taip soalan anda dengan tempat kosong...") %></em>';
    var words=[];document.querySelectorAll('.tc-fill-blank-word-input').forEach(function(i){if(i.value.trim())words.push(i.value.trim());});
    $id('fibPreviewWords').innerHTML=words.length?words.map(function(w){return'<span class="tc-question-builder-tc-fill-blank-chip">'+w+'</span>';}).join(''):'<em style="font-size:.78rem;color:var(--tc-muted);"><%: T("Add words to Word Bank above","Tambah perkataan ke Bank Perkataan di atas") %></em>';
}
function updateCharCounts(){
    var ed=document.getElementById('qbRteEditor');
    var qLen=ed?(ed.innerText||'').length:0;
    $id('qCharCount').textContent=qLen+' / 500';
    var ce=$id(SRV.txtCE),we=$id(SRV.txtWE);
    if(ce)$id('ceCharCount').textContent=ce.value.length+' / 500';
    if(we)$id('weCharCount').textContent=we.value.length+' / 500';
}
function updateProgress(){
    var done=window.__QD.filter(function(q){return q.saved;}).length,total=window.__QD.length;
    var pct=total>0?Math.round(done/total*100):0;
    var fill=$id('progressFill'),txt=$id('progressText');
    if(fill)fill.style.width=pct+'%';
    if(txt)txt.textContent=done+' / '+total+' <%: T("Questions Saved","Soalan Disimpan") %>';
    var nc=$id('navCount');if(nc)nc.textContent=total;
    document.querySelectorAll('.tc-question-builder-nav-del').forEach(function(b){total<=1?b.classList.add('disabled'):b.classList.remove('disabled');});
}

/* -- Delete modal ------------------------------------------ */
var _pendingDeleteIndex=-1;

function confirmDeleteQuestion(idx){
    if(window.__QD.length<=1)return; /* never delete the last question */
    _pendingDeleteIndex=idx;
    var msg=$id('qbDelMsg');
    if(msg)msg.textContent=_T('Question '+(idx+1)+' will be permanently removed. This action cannot be undone.','Soalan '+(idx+1)+' akan dipadamkan secara kekal. Tindakan ini tidak boleh dibatalkan.');
    $id('qbDelOverlay').classList.add('open');
}
function closeDeleteModal(e){
    if(e&&e.target!==$id('qbDelOverlay'))return;
    $id('qbDelOverlay').classList.remove('open');_pendingDeleteIndex=-1;
}
function executeDelete(){
    if(_pendingDeleteIndex<0)return;
    var delIdx=_pendingDeleteIndex;
    $id('qbDelOverlay').classList.remove('open');
    _pendingDeleteIndex=-1;

    if(window.__QD.length<=1)return; /* safety guard */

    /* 1. Capture the currently displayed question BEFORE touching anything */
    captureCurrentFields();

    /* 2. Remove the target question from the store by exact index */
    window.__QD.splice(delIdx,1);

    /* 3. Work out which question to show next:
          - if delIdx < length ? show delIdx (now the question that was after it)
          - otherwise show the new last question                                  */
    var nextIdx=delIdx<window.__QD.length ? delIdx : window.__QD.length-1;
    window.__CI=nextIdx;

    /* 4. Populate the editor with the question we're switching to */
    var q=window.__QD[nextIdx];
    populateFields(q,window.__CT);
    updateLabels(window.__CT);

    /* 5. Update question number header */
    var qn=$qs('[id$="litQNum"]');if(qn)qn.textContent=nextIdx+1;

    /* 6. Rebuild the nav list (re-numbers sequentially from the new __QD) */
    rebuildNavList();

    /* 7. Update prev/next button states */
    var bp=$qs('[id$="btnPrev"]'),bn=$qs('[id$="btnNext"]');
    if(bp)bp.disabled=(nextIdx===0);
    if(bn)bn.disabled=(nextIdx>=window.__QD.length-1);

    /* 8. Sync progress bar */
    updateProgress();

    /* 9. Keep hidden fields up to date so the next Save/Submit postback is aware */
    var hIdx=$id(SRV.hidIdx);if(hIdx)hIdx.value=nextIdx;
    var hTab=$id(SRV.hidTab);if(hTab)hTab.value=window.__CT;
    /* Write the updated store into the JSON hidden field so the server
       rebuilds Questions from the correct post-delete state on next postback */
    var hJson=$id(SRV.hidJson);if(hJson)hJson.value=JSON.stringify(window.__QD);
}

/* -- Image upload ? per-question, stored in __QD[idx].img --- */
function handleQImgUpload(input){
    if(!input.files||!input.files[0])return;
    var file=input.files[0];
    if(file.size>5*1024*1024){alert('<%: T("Image must be under 5 MB.","Imej mesti di bawah 5 MB.") %>');input.value='';return;}
    /* Store just the filename in the question store ? the server FileUpload saves the file */
    var fileName=file.name;
    if(window.__QD[window.__CI])window.__QD[window.__CI].img=fileName;
    /* Copy the selected file to the server-side FileUpload control so it uploads on submit */
    try{
        var dt=new DataTransfer();dt.items.add(file);
        var fu=$id(SRV.fuImg);if(fu)fu.files=dt.files;
    }catch(e){/* DataTransfer not supported in all browsers ? file still previews */}
    /* Also write filename into the hidden server field for fallback */
    var hf=$id(SRV.hidImgFile);if(hf)hf.value=fileName;
    /* Show preview using data-URL (display only) */
    var reader=new FileReader();
    reader.onload=function(ev){
        $id('qbImgPreviewSrc').src=ev.target.result;
        $id('qbImgUploadLabel').style.display='none';
        $id('qbImgPreview').style.display='block';
    };
    reader.readAsDataURL(file);
}
function removeQImg(){
    /* clear only this question's image */
    if(window.__QD[window.__CI])window.__QD[window.__CI].img='';
    var hf=$id(SRV.hidImgFile);if(hf)hf.value='';
    $id('qbImgInput').value='';$id('qbImgPreviewSrc').src='';
    $id('qbImgPreview').style.display='none';$id('qbImgUploadLabel').style.display='flex';
}

/* -- Add question client-side (no postback) ---------------- */
function clientAddQuestion(){
    captureCurrentFields();
    window.__QD.push(emptyQ());
    var newIdx=window.__QD.length-1;
    window.__CI=newIdx;
    populateFields(window.__QD[newIdx],window.__CT);
    updateLabels(window.__CT);
    rebuildNavList();
    updateNavLabel();
    updateProgress();
}

/* Rebuild the left nav list entirely from __QD (no server call) */
function rebuildNavList(){
    var list=$qs('.tc-question-builder-nav-list');if(!list)return;
    list.innerHTML='';
    window.__QD.forEach(function(q,i){
        var row=document.createElement('div');
        row.className='tc-question-builder-nav-row';
        /* nav item */
        var btn=document.createElement('button');
        btn.type='button';
        btn.className='tc-question-builder-nav-item'+(i===window.__CI?' active':'')+(q.saved?' done':'');
        btn.dataset.qidx=i;
        btn.innerHTML='<span class="tc-question-builder-nav-badge">'+(i+1)+'</span><span>Q'+(i+1)+'</span><i class="bi bi-check-circle-fill tc-question-builder-nav-check"></i>';
        btn.addEventListener('click',function(e){
            e.preventDefault();e.stopPropagation();
            navGoTo(parseInt(btn.dataset.qidx,10));
        });
        /* delete button */
        var del=document.createElement('button');
        del.type='button';
        del.className='tc-question-builder-nav-del'+(window.__QD.length<=1?' disabled':'');
        del.dataset.idx=i;
        del.innerHTML='<i class="bi bi-trash3"></i>';
        del.title=_T('Delete question','Padam soalan');
        del.addEventListener('click',function(){confirmDeleteQuestion(parseInt(del.dataset.idx,10));});
        row.appendChild(btn);row.appendChild(del);
        list.appendChild(row);
    });
    var nc=$id('navCount');if(nc)nc.textContent=window.__QD.length;
}

/* -- Bootstrap ---------------------------------------------- */
function wireNavItems(){
    /* Wire server-rendered nav items (initial load / after postback) */
    document.querySelectorAll('.tc-question-builder-nav-item').forEach(function(el){
        /* Remove any old listener by replacing with a clone */
        var clone=el.cloneNode(true);
        el.parentNode.replaceChild(clone,el);
        clone.addEventListener('click',function(e){
            e.preventDefault();e.stopPropagation();
            var idx=parseInt(clone.dataset.qidx,10);
            if(!isNaN(idx))navGoTo(idx);
        });
    });
}

window.addEventListener('load',function(){
    var h=$id(SRV.toast);if(h&&h.value){showToast(h.value);h.value='';}

    /* Show submit-success modal if the server flagged it */
    var hSuccess=$id('<%=hidSubmitSuccess.ClientID%>');
    if(hSuccess&&hSuccess.value==='1'){
        hSuccess.value='';
        var overlay=$id('qbSuccessOverlay');
        if(overlay)overlay.classList.add('open');
    }

    var ddl=$id(SRV.ddlType);
    if(ddl){ddl.addEventListener('change',switchQuestionType);switchQuestionType();}

    document.querySelectorAll('#sectionMCQ .tc-question-builder-opt').forEach(function(card){
        card.addEventListener('click',function(e){
            if(e.target.tagName==='INPUT'&&e.target.type==='text')return;
            if(e.target.tagName==='TEXTAREA')return;
            var radio=card.querySelector('input[type="radio"]');
            if(radio){radio.checked=true;updateAnswerCards();}
            if(window.__QD[window.__CI]&&radio)window.__QD[window.__CI].correct=radio.value;
        });
        card.style.cursor='pointer';
    });
    document.querySelectorAll('#sectionMS .tc-question-builder-ms-opt').forEach(function(card){
        card.addEventListener('click',function(e){
            if(e.target.tagName==='INPUT'&&e.target.type==='text')return;
            var cb=card.querySelector('.ms-check');
            if(cb){cb.checked=!cb.checked;updateMSCards();}
        });
        card.style.cursor='pointer';
    });
    document.querySelectorAll('#sectionMCQ .tc-question-builder-opt input[type="radio"]').forEach(function(r){r.addEventListener('change',updateAnswerCards);});
    document.querySelectorAll('#sectionMCQ .tc-question-builder-opt-input').forEach(function(inp){inp.addEventListener('input',updateAnswerCards);});
    document.querySelectorAll('textarea').forEach(function(ta){ta.addEventListener('input',function(){updateCharCounts();updateFibUI();});});

    /* Wire RTE editor events */
    var rteEd=document.getElementById('qbRteEditor');
    if(rteEd){
        rteEd.addEventListener('input',function(){rteSync();updateFibUI();});
        rteEd.addEventListener('keyup',rteUpdateToolbar);
        rteEd.addEventListener('mouseup',rteUpdateToolbar);
        rteEd.addEventListener('keydown',function(e){
            if(e.ctrlKey||e.metaKey){
                if(e.key==='b'){e.preventDefault();rteExec('bold');}
                if(e.key==='i'){e.preventDefault();rteExec('italic');}
                if(e.key==='u'){e.preventDefault();rteExec('underline');}
            }
        });
    }

    var form=document.querySelector('form');
    if(form)form.addEventListener('submit',flushToServer);

    var delBtn=$id('qbDelConfirm');
    if(delBtn)delBtn.addEventListener('click',executeDelete);

    document.addEventListener('keydown',function(e){
        if(e.key==='Escape'&&$id('qbDelOverlay').classList.contains('open'))closeDeleteModal();
    });

    /* Wire nav items (server-rendered on load/postback) */
    wireNavItems();

    updateAnswerCards();updateProgress();updateCharCounts();updateFibUI();updateLabels(window.__CT);

    qbWireAutoClears();

    var bp=$qs('[id$="btnPrev"]'),bn=$qs('[id$="btnNext"]');
    if(bp)bp.disabled=(window.__CI===0);
    if(bn)bn.disabled=(window.__CI>=window.__QD.length-1);
});

/* --- UNSAVED CHANGES DETECTION --------------------------- */
(function(){
    var dirty=false;
    var pendingUrl='';
    var submitting=false;

    // Mark dirty on any input/change in the editor area
    var editorBody=document.querySelector('.tc-question-builder-editor-body');
    if(editorBody){
        editorBody.addEventListener('input',function(){dirty=true;},true);
        editorBody.addEventListener('change',function(){dirty=true;},true);
    }
    // Also mark dirty on RTE input
    var rte=document.getElementById('qbRteEditor');
    if(rte)rte.addEventListener('input',function(){dirty=true;});
    // Mark dirty on image upload/remove
    var imgInput=document.getElementById('qbImgInput');
    if(imgInput)imgInput.addEventListener('change',function(){dirty=true;});
    // Mark dirty on question type/difficulty change
    var propsBody=document.querySelector('.tc-question-builder-props-body');
    if(propsBody)propsBody.addEventListener('change',function(){dirty=true;},true);
    // Mark dirty on add question / delete question
    var origAdd=window.clientAddQuestion;
    window.clientAddQuestion=function(){dirty=true;if(origAdd)origAdd();};

    // Clear dirty on successful submit
    var submitBtn=document.querySelector('[id$="btnSubmitQuiz"]');
    if(submitBtn)submitBtn.addEventListener('click',function(){submitting=true;});

    // Clear dirty when success overlay shows
    var obs=new MutationObserver(function(){
        if(document.getElementById('qbSuccessOverlay')&&document.getElementById('qbSuccessOverlay').classList.contains('open')){
            dirty=false;submitting=true;
        }
    });
    var successEl=document.getElementById('qbSuccessOverlay');
    if(successEl)obs.observe(successEl,{attributes:true,attributeFilter:['class']});

    // Browser native beforeunload
    window.addEventListener('beforeunload',function(e){
        if(dirty&&!submitting){e.preventDefault();e.returnValue='';}
    });

    // Intercept sidebar links
    document.querySelectorAll('.sb-sidebar-item').forEach(function(link){
        link.addEventListener('click',function(e){
            if(!dirty||submitting)return; // allow navigation
            e.preventDefault();
            e.stopPropagation();
            pendingUrl=link.getAttribute('href')||link.href;
            document.getElementById('qbUnsavedOverlay').classList.add('open');
        });
    });

    // Modal confirm ? navigate away
    var confirmBtn=document.getElementById('qbUnsavedConfirm');
    if(confirmBtn)confirmBtn.addEventListener('click',function(){
        dirty=false;
        document.getElementById('qbUnsavedOverlay').classList.remove('open');
        if(pendingUrl)window.location.href=pendingUrl;
    });

    // Expose close function
    window.closeUnsavedModal=function(){
        document.getElementById('qbUnsavedOverlay').classList.remove('open');
        pendingUrl='';
    };

    // Close on Escape
    document.addEventListener('keydown',function(e){
        if(e.key==='Escape'&&document.getElementById('qbUnsavedOverlay').classList.contains('open'))closeUnsavedModal();
    });
})();

/* --- WEBSITE LANGUAGE SWITCH ? NO RELOAD ----------------- */
(function(){
    /* Intercept the master page language toggle buttons to prevent full postback */
    function interceptLangBtns(){
        var btns=document.querySelectorAll('[id$="btnLangEN_Top"],[id$="btnLangBM_Top"],[id$="btnLangEN_Header"],[id$="btnLangBM_Header"]');
        btns.forEach(function(btn){
            btn.addEventListener('click',function(e){
                e.preventDefault();e.stopPropagation();e.stopImmediatePropagation();
                var newLang=btn.id.indexOf('LangEN')>-1?'EN':'BM';
                if(newLang===window.__SITE_LANG)return;
                switchSiteLang(newLang);
                return false;
            },true); /* capture phase to beat __doPostBack */
            /* Also remove the href="javascript:__doPostBack..." so the link doesn't fire */
            btn.removeAttribute('href');
            btn.style.cursor='pointer';
        });
    }

    function switchSiteLang(lang){
        /* 1. Update session via AJAX (fire-and-forget) */
        var xhr=new XMLHttpRequest();
        xhr.open('POST','<%= ResolveUrl("~/Teacher/createUnitLevelQuiz.aspx/SetLanguage") %>',true);
        xhr.setRequestHeader('Content-Type','application/json; charset=utf-8');
        xhr.send(JSON.stringify({lang:lang}));

        /* 2. Update client-side language variable */
        window.__SITE_LANG=lang;

        /* 3. Update toggle button active states */
        document.querySelectorAll('.sb-lang-btn').forEach(function(b){
            var isEN=b.id.indexOf('LangEN')>-1;
            b.className=(isEN&&lang==='EN')||(!isEN&&lang==='BM')?'sb-lang-btn active':'sb-lang-btn';
        });

        /* 4. Refresh all UI text */
        refreshPageLanguage();
    }

    function refreshPageLanguage(){
        var L=window.__SITE_LANG;
        var t=function(en,bm){return L==='BM'?bm:en;};

        /* -- ERR_MSG (used by validation) -- */
        ERR_MSG=t('Please fill in the required field.','Sila isi ruangan yang diperlukan.');

        /* -- Navigation label -- */
        updateNavLabel();

        /* -- Placeholders (always website language) -- */
        var ph=function(id,en,bm){var el=$id(id);if(el)el.placeholder=t(en,bm);};
        ph(SRV.txtQ,'Type your question here...','Taip soalan anda di sini...');
        ph(SRV.txtA,'Enter option A...','Masukkan pilihan A...');
        ph(SRV.txtB,'Enter option B...','Masukkan pilihan B...');
        ph(SRV.txtC,'Enter option C...','Masukkan pilihan C...');
        ph(SRV.txtD,'Enter option D...','Masukkan pilihan D...');
        ph(SRV.txtCE,'Explain why this answer is correct...','Terangkan mengapa jawapan ini betul...');
        ph(SRV.txtWE,'Explain why the other answers are incorrect...','Terangkan mengapa jawapan lain salah...');

        /* -- RTE placeholder -- */
        var ed=document.getElementById('qbRteEditor');
        if(ed)ed.setAttribute('data-placeholder',t(ed.dataset.placeholderEn,ed.dataset.placeholderBm));

        /* -- Section headers (keep tab-awareness) -- */
        var isEN=(window.__CT==='EN');
        var ol=$qs('#sectionMCQ .tc-question-builder-section-header-text');
        if(ol)ol.textContent=isEN?t('Options (English)','Pilihan (Bahasa Inggeris)'):t('Options (Bahasa Melayu)','Pilihan (Bahasa Melayu)');
        var ce=$qs('.tc-question-builder-exp-correct .tc-question-builder-exp-block-label');
        if(ce)ce.textContent=(isEN?t('Correct Explanation (EN)','Penjelasan Betul (EN)'):t('Correct Explanation (BM)','Penjelasan Betul (BM)'))+' *';
        var we=$qs('.tc-question-builder-exp-wrong .tc-question-builder-exp-block-label');
        if(we)we.textContent=(isEN?t('Wrong Explanation (EN)','Penjelasan Salah (EN)'):t('Wrong Explanation (BM)','Penjelasan Salah (BM)'))+' *';

        /* -- MCQ sub-header -- */
        var mcqSub=$qs('#sectionMCQ .tc-question-builder-section-header-sub');
        if(mcqSub)mcqSub.textContent=t('Select one correct answer','Pilih satu jawapan betul');

        /* -- True/False section -- */
        var tfHead=$qs('#sectionTF .tc-question-builder-section-header-text');
        if(tfHead)tfHead.textContent=t('Select the correct answer','Pilih jawapan yang betul');

        /* -- Multiselect section -- */
        var msHead=$qs('#sectionMS .tc-question-builder-section-header-text');
        if(msHead)msHead.textContent=t('Select all correct answers','Pilih semua jawapan betul');

        /* -- Explanations section header -- */
        var expHeaders=document.querySelectorAll('.tc-question-builder-section-header .tc-question-builder-section-header-text');
        expHeaders.forEach(function(h){
            if(h.textContent.indexOf('Explanation')>-1||h.textContent.indexOf('Penjelasan')>-1)
                h.textContent=t('Explanations','Penjelasan');
        });

        /* -- Buttons -- */
        var submitBtn=document.querySelector('[id$="btnSubmitQuiz"]');
        if(submitBtn)submitBtn.value=t('Submit Quiz','Hantar Kuiz');
        var addBtn=document.querySelector('[id$="btnAddQuestion"]');
        if(addBtn)addBtn.value=t('+ Add Question','+ Tambah Soalan');

        /* -- Dropdown display text -- */
        var ddlType=$id(SRV.ddlType);
        if(ddlType){
            var typeMap={'MCQ':t('MCQ','Aneka Pilihan'),'True/False':t('True / False','Betul / Salah'),'Multiselect':t('Multiselect','Pelbagai Pilihan'),'Drag & Drop':t('Drag & Drop','Seret & Letak')};
            Array.prototype.slice.call(ddlType.options).forEach(function(opt){if(typeMap[opt.value])opt.text=typeMap[opt.value];});
        }
        var ddlDiff=$id(SRV.ddlDiff);
        if(ddlDiff){
            var diffMap={'Easy':t('Easy','Mudah'),'Medium':t('Medium','Sederhana'),'Hard':t('Hard','Sukar')};
            Array.prototype.slice.call(ddlDiff.options).forEach(function(opt){if(diffMap[opt.value])opt.text=diffMap[opt.value];});
        }

        /* -- Properties panel labels -- */
        var propLabels=document.querySelectorAll('.tc-question-builder-prop-label');
        propLabels.forEach(function(lbl){
            var txt=lbl.textContent.trim();
            if(txt.indexOf('Question Type')>-1||txt.indexOf('Jenis Soalan')>-1)
                lbl.innerHTML=lbl.querySelector('.tc-question-builder-prop-label-icon').outerHTML+' '+t('Question Type','Jenis Soalan');
            else if(txt.indexOf('Difficulty')>-1||txt.indexOf('Kesukaran')>-1)
                lbl.innerHTML=lbl.querySelector('.tc-question-builder-prop-label-icon').outerHTML+' '+t('Difficulty','Kesukaran');
        });

        /* -- Properties panel title -- */
        var propsTitle=$qs('.tc-question-builder-props-title');
        if(propsTitle)propsTitle.textContent=t('Properties','Sifat');

        /* -- Image upload text -- */
        var imgText=$qs('.tc-question-builder-img-upload-text');
        if(imgText)imgText.textContent=t('Upload Image','Muat Naik Imej');
        var imgSub=$qs('.tc-question-builder-img-upload-sub');
        if(imgSub)imgSub.textContent=t('Optional ? PNG, JPG, GIF up to 5 MB','Pilihan ? PNG, JPG, GIF sehingga 5 MB');

        /* -- Delete modal -- */
        var delTitle=$qs('.tc-question-builder-del-modal h3');
        if(delTitle)delTitle.textContent=t('Delete Question?','Padam Soalan?');
        var delCancel=$qs('.tc-question-builder-del-btn-cancel');
        if(delCancel)delCancel.textContent=t('Cancel','Batal');
        var delConfirm=$qs('.tc-question-builder-del-btn-confirm');
        if(delConfirm)delConfirm.textContent=t('Delete','Padam');

        /* -- Unsaved modal -- */
        var unsavedTitle=$qs('.tc-question-builder-unsaved-modal h3');
        if(unsavedTitle)unsavedTitle.textContent=t('Unsaved Changes','Perubahan Belum Disimpan');
        var unsavedDesc=$qs('.tc-question-builder-unsaved-modal p');
        if(unsavedDesc)unsavedDesc.textContent=t('Your unsaved question will be discarded. Are you sure you want to leave this page?','Soalan anda yang belum disimpan akan dibuang. Adakah anda pasti mahu meninggalkan halaman ini?');
        var unsavedCancel=$qs('.tc-question-builder-unsaved-cancel');
        if(unsavedCancel)unsavedCancel.textContent=t('Cancel','Batal');
        var unsavedConfirm=$qs('.tc-question-builder-unsaved-confirm');
        if(unsavedConfirm)unsavedConfirm.textContent=t('Confirm','Sahkan');

        /* -- Success modal -- */
        var successTitle=$qs('.tc-question-builder-success-modal h3');
        if(successTitle)successTitle.textContent=t('Quiz Submitted Successfully','Kuiz Berjaya Dihantar');
        var successDesc=$qs('.tc-question-builder-success-modal p');
        if(successDesc)successDesc.textContent=t('Your questions have been submitted and are now pending review.','Soalan anda telah dihantar dan sedang menunggu semakan.');
        var successBtn=$qs('.tc-question-builder-success-modal .tc-question-builder-btn');
        if(successBtn)successBtn.textContent=t('Back to Manage Quizzes','Kembali ke Urus Kuiz');

        /* -- Page title -- */
        var pageTitle=$qs('.sb-page-title');
        if(pageTitle)pageTitle.textContent=t('Create Quiz','Cipta Kuiz');

        /* -- Question label -- */
        var qLabel=$qs('.tc-question-builder-label span');
        if(qLabel){
            var badge=document.getElementById('qbLangBadge');
            var badgeHTML=badge?badge.outerHTML:'';
            qLabel.innerHTML=t('Question','Soalan')+' * '+badgeHTML;
        }

        /* -- Multiselect count -- */
        updateMSCards();

        /* -- Progress bar -- */
        updateProgress();
    }

    interceptLangBtns();
})();
</script>
</asp:Content>
