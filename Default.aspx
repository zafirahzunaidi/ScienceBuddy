<%@ Page Title="ScienceBuddy" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="ScienceBuddy._Default" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%: ResolveUrl("~/Content/About.css") %>?v=2" rel="stylesheet" />
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="about-page">

    <%-- ══ SECTION 1: HERO ══ --%>
        <section class="about-hero" aria-label="Hero">
            <div class="about-hero__top">
                <div class="about-hero__text">
                    <h1 class="about-hero__title">Every Great Discovery,<br/>Starts With Curiosity.</h1>
                    <p class="about-hero__subtitle">
                        Learning designed for curious minds.</p>
                </div>
                <div class="about-hero__visual">
                    <img src="<%: ResolveUrl("~/Images/About/heading-about.png") %>?v=2" alt="ScienceBuddy platform overview" />
                </div>
            </div>
            <div class="about-hero__bottom">
                <p class="about-hero__cta-label">
                    Get started as a...</p>
                <div class="about-hero__cards">
                    <a href="<%: ResolveUrl("~/StudentRegistration.aspx") %>" class="about-hero__card" data-role="student">
                    <div class="about-hero__card-icon about-hero__card-icon--student">
                        <i class="bi bi-mortarboard-fill"></i>
                    </div>
                    <div class="about-hero__card-title">
                        Student</div>
                    <div class="about-hero__card-desc">
                        Learn, practise, and grow.</div>
                    </a><a href="<%: ResolveUrl("~/ParentRegistration.aspx") %>" class="about-hero__card" data-role="parent">
                    <div class="about-hero__card-icon about-hero__card-icon--parent">
                        <i class="bi bi-heart-fill"></i>
                    </div>
                    <div class="about-hero__card-title">
                        Parent</div>
                    <div class="about-hero__card-desc">
                        Support every learning step.</div>
                    </a><a href="<%: ResolveUrl("~/TeacherRegistration.aspx") %>" class="about-hero__card" data-role="teacher">
                    <div class="about-hero__card-icon about-hero__card-icon--teacher">
                        <i class="bi bi-journal-bookmark-fill"></i>
                    </div>
                    <div class="about-hero__card-title">
                        Teacher</div>
                    <div class="about-hero__card-desc">
                        Guide curious minds.</div>
                    </a>
                </div>
            </div>
        </section>

    <%-- ══ SECTION 2: WHAT IS SCIENCEBUDDY ══ --%>
        <section class="about-what" aria-labelledby="aboutWhatTitle">
            <div class="about-what__inner">
                <div class="about-what__text about-reveal">
                    <h2 id="aboutWhatTitle">What Is ScienceBuddy?</h2>
                    <p>
                        ScienceBuddy is a web-based science learning platform created for secondary school students, parents, and teachers. It combines structured lessons, interactive assessments, personalised learning, progress support, and community communication in one accessible environment.</p>
                    <p>
                        Guests can explore public modules, preview selected lesson content, try sample quiz questions, and read public forum discussions before registering.</p>
                </div>
                <div class="about-what__visual about-reveal about-reveal--right">
                    <img src="<%: ResolveUrl("~/Images/Logo/sciencebuddy-logo.png") %>" alt="ScienceBuddy mascot" style="max-width:200px;" />
                </div>
            </div>
        </section>

    <%-- ══ SECTION 3: FEATURES ══ --%>
        <section class="about-feature about-reveal" aria-labelledby="feat1">
            <div class="about-feature__text">
                <h2 id="feat1">Big Ideas, One at a Time</h2>
                <p>
                    ScienceBuddy organises science content into clear levels, units, and lessons. Students can move through each topic step by step, building their knowledge without feeling overwhelmed.</p>
            </div>
            <div class="about-feature__visual">
                <img src="<%: ResolveUrl("~/Images/About/learning-content.png") %>" alt="Learning content overview" loading="lazy" /></div>
        </section>
        <section class="about-feature about-feature--reverse about-reveal" aria-labelledby="feat2">
            <div class="about-feature__text">
                <h2 id="feat2">Try, Learn, and Try Again</h2>
                <p>
                    Interactive quizzes help students check what they understand and discover where they need more practice. Helpful feedback turns every answer into another opportunity to improve.</p>
            </div>
            <div class="about-feature__visual">
                <img src="<%: ResolveUrl("~/Images/About/quiz-assessment.png") %>" alt="Quiz and assessment" loading="lazy" /></div>
        </section>
        <section class="about-feature about-reveal" aria-labelledby="feat3">
            <div class="about-feature__text">
                <h2 id="feat3">Learn Your Own Way</h2>
                <p>
                    Every student learns differently. ScienceBuddy uses a personality and learning-style assessment to help students understand their strengths and weaknesses and receive a more personalised learning experience.</p>
            </div>
            <div class="about-feature__visual">
                <img src="<%: ResolveUrl("~/Images/About/personality-and-learning-style.png") %>" alt="Personality and learning style" loading="lazy" /></div>
        </section>
        <section class="about-feature about-feature--reverse about-reveal" aria-labelledby="feat4">
            <div class="about-feature__text">
                <h2 id="feat4">Celebrate Every Achievement</h2>
                <p>
                    Points, badges, and progress milestones make learning feel exciting. ScienceBuddy recognises both major achievements and small improvements so students stay motivated throughout their journey.</p>
            </div>
            <div class="about-feature__visual">
                <img src="<%: ResolveUrl("~/Images/About/progress.png") %>" alt="Progress and motivation" loading="lazy" /></div>
        </section>
        <section class="about-feature about-reveal" aria-labelledby="feat5">
            <div class="about-feature__text">
                <h2 id="feat5">Discover More Together</h2>
                <p>
                    Science becomes more meaningful when learners can share questions, ideas, and explanations. ScienceBuddy creates a friendly community where students, teachers, and families can stay connected through learning.</p>
            </div>
            <div class="about-feature__visual">
                <img src="<%: ResolveUrl("~/Images/About/community-section.png") %>" alt="Community features" loading="lazy" /></div>
        </section>

    <%-- ══ SECTION 4: COMMUNITY COLLAGE ══ --%>
        <section class="about-community" aria-labelledby="aboutCommunityTitle">
            <div class="about-community__inner">
                <div class="about-community__card about-community__card--1">
                    <img src="<%: ResolveUrl("~/Images/About/community-1.png") %>" alt="Community member" loading="lazy" /></div>
                <div class="about-community__card about-community__card--2">
                    <img src="<%: ResolveUrl("~/Images/About/community-2.png") %>" alt="Community member" loading="lazy" /></div>
                <div class="about-community__card about-community__card--3">
                    <img src="<%: ResolveUrl("~/Images/About/community-3.png") %>" alt="Community member" loading="lazy" /></div>
                <div class="about-community__card about-community__card--4">
                    <img src="<%: ResolveUrl("~/Images/About/community-4.png") %>" alt="Community member" loading="lazy" /></div>
                <div class="about-community__center about-reveal">
                    <h2 id="aboutCommunityTitle">Science Feels Better When We Learn Together</h2>
                    <p>
                        From first questions to proud breakthroughs, ScienceBuddy brings learners, parents, and teachers into one supportive learning space.</p>
                </div>
                <div class="about-community__card about-community__card--5">
                    <img src="<%: ResolveUrl("~/Images/About/community-5.png") %>" alt="Community member" loading="lazy" /></div>
                <div class="about-community__card about-community__card--6">
                    <img src="<%: ResolveUrl("~/Images/About/community-6.png") %>" alt="Community member" loading="lazy" /></div>
                <div class="about-community__card about-community__card--7">
                    <img src="<%: ResolveUrl("~/Images/About/community-7.png") %>" alt="Community member" loading="lazy" /></div>
                <div class="about-community__card about-community__card--8">
                    <img src="<%: ResolveUrl("~/Images/About/community-8.png") %>" alt="Community member" loading="lazy" /></div>
            </div>
            <div class="about-community__mobile">
                <img src="<%: ResolveUrl("~/Images/About/community-1.png") %>" alt="" loading="lazy" />
                <img src="<%: ResolveUrl("~/Images/About/community-2.png") %>" alt="" loading="lazy" />
                <img src="<%: ResolveUrl("~/Images/About/community-3.png") %>" alt="" loading="lazy" />
                <img src="<%: ResolveUrl("~/Images/About/community-4.png") %>" alt="" loading="lazy" />
            </div>
        </section>

    <%-- ══ SECTION 5: MISSION STATEMENT ══ --%>
        <section class="about-mission" aria-labelledby="aboutMissionTitle">
            <div class="about-mission__inner">
                <img src="<%: ResolveUrl("~/Images/About/mission-statement.png") %>" alt="ScienceBuddy mission" class="about-mission__img about-reveal" loading="lazy" />
                <h2 id="aboutMissionTitle" class="about-mission__heading about-reveal">Every Curious Mind Deserves To Shine</h2>
            </div>
        </section>

    <%-- ══ SECTION 6: CORE VALUES ══ --%>
        <section class="about-values about-reveal" aria-labelledby="aboutValuesTitle">
            <div class="about-values__header">
                <h2 id="aboutValuesTitle">We Believe In...</h2>
            </div>
            <div class="about-values__grid">
                <div class="about-values__card">
                    <h3>Curiosity First</h3>
                    <p>
                        Learning begins when students feel confident enough to ask questions and explore ideas.</p>
                </div>
                <div class="about-values__card">
                    <h3>Learning for Everyone</h3>
                    <p>
                        Science content should be understandable, welcoming, and available in English and Bahasa Melayu.</p>
                </div>
                <div class="about-values__card">
                    <h3>Supportive Connections</h3>
                    <p>
                        Students learn better when teachers and families can guide and encourage their progress.</p>
                </div>
                <div class="about-values__card">
                    <h3>Safe and Responsible Access</h3>
                    <p>
                        Each user receives access based on their role, while guests are limited to appropriate public content.</p>
                </div>
            </div>
        </section>

    <%-- ══ SECTION 7: TEST-USER FEEDBACK ══ --%>
        <section class="about-reviews" aria-labelledby="aboutReviewsTitle">
            <div class="about-reviews__header">
                <h2 id="aboutReviewsTitle">What Our Test Users Say</h2>
                <p>
                    Real impressions from students, parents, and teachers who explored ScienceBuddy.</p>
            </div>
            <div class="about-reviews__track">
                <div class="about-reviews__card">
                    <div class="about-reviews__card-name">
                        Aina — Student Tester</div>
                    <div class="about-reviews__card-text">
                        "The lesson preview was colourful and made the Human topic feel easier to understand."</div>
                </div>
                <div class="about-reviews__card">
                    <div class="about-reviews__card-name">
                        Mr. Hafiz — Parent Tester</div>
                    <div class="about-reviews__card-text">
                        "I liked being able to see how the progress and study-plan features support a child's learning."</div>
                </div>
                <div class="about-reviews__card">
                    <div class="about-reviews__card-name">
                        Ms. Farah — Teacher Tester</div>
                    <div class="about-reviews__card-text">
                        "The platform feels friendly and the science content is organised clearly."</div>
                </div>
                <div class="about-reviews__card">
                    <div class="about-reviews__card-name">
                        Daniel — Student Tester</div>
                    <div class="about-reviews__card-text">
                        "The personality test makes the platform feel more personal than a normal learning website."</div>
                </div>
                <div class="about-reviews__card">
                    <div class="about-reviews__card-name">
                        Aina — Student Tester</div>
                    <div class="about-reviews__card-text">
                        "The lesson preview was colourful and made the Human topic feel easier to understand."</div>
                </div>
                <div class="about-reviews__card">
                    <div class="about-reviews__card-name">
                        Mr. Hafiz — Parent Tester</div>
                    <div class="about-reviews__card-text">
                        "I liked being able to see how the progress and study-plan features support a child's learning."</div>
                </div>
                <div class="about-reviews__card">
                    <div class="about-reviews__card-name">
                        Ms. Farah — Teacher Tester</div>
                    <div class="about-reviews__card-text">
                        "The platform feels friendly and the science content is organised clearly."</div>
                </div>
                <div class="about-reviews__card">
                    <div class="about-reviews__card-name">
                        Daniel — Student Tester</div>
                    <div class="about-reviews__card-text">
                        "The personality test makes the platform feel more personal than a normal learning website."</div>
                </div>
            </div>
            <div class="about-reviews__track about-reviews__track--reverse" style="margin-top:16px;">
                <div class="about-reviews__card">
                    <div class="about-reviews__card-name">
                        Daniel — Student Tester</div>
                    <div class="about-reviews__card-text">
                        "The personality test makes the platform feel more personal than a normal learning website."</div>
                </div>
                <div class="about-reviews__card">
                    <div class="about-reviews__card-name">
                        Ms. Farah — Teacher Tester</div>
                    <div class="about-reviews__card-text">
                        "The platform feels friendly and the science content is organised clearly."</div>
                </div>
                <div class="about-reviews__card">
                    <div class="about-reviews__card-name">
                        Mr. Hafiz — Parent Tester</div>
                    <div class="about-reviews__card-text">
                        "I liked being able to see how the progress and study-plan features support a child's learning."</div>
                </div>
                <div class="about-reviews__card">
                    <div class="about-reviews__card-name">
                        Aina — Student Tester</div>
                    <div class="about-reviews__card-text">
                        "The lesson preview was colourful and made the Human topic feel easier to understand."</div>
                </div>
                <div class="about-reviews__card">
                    <div class="about-reviews__card-name">
                        Daniel — Student Tester</div>
                    <div class="about-reviews__card-text">
                        "The personality test makes the platform feel more personal than a normal learning website."</div>
                </div>
                <div class="about-reviews__card">
                    <div class="about-reviews__card-name">
                        Ms. Farah — Teacher Tester</div>
                    <div class="about-reviews__card-text">
                        "The platform feels friendly and the science content is organised clearly."</div>
                </div>
                <div class="about-reviews__card">
                    <div class="about-reviews__card-name">
                        Mr. Hafiz — Parent Tester</div>
                    <div class="about-reviews__card-text">
                        "I liked being able to see how the progress and study-plan features support a child's learning."</div>
                </div>
                <div class="about-reviews__card">
                    <div class="about-reviews__card-name">
                        Aina — Student Tester</div>
                    <div class="about-reviews__card-text">
                        "The lesson preview was colourful and made the Human topic feel easier to understand."</div>
                </div>
            </div>
        </section>

    <%-- ══ SECTION 8: GET STARTED CTA ══ --%>
        <section class="about-cta about-reveal" aria-labelledby="aboutCtaTitle">
            <img src="<%: ResolveUrl("~/Images/Logo/sciencebuddy-logo.png") %>" alt="" class="about-cta__mascot" />
            <h2 id="aboutCtaTitle">Ready to Turn Curiosity into Confidence?</h2>
            <p>
                Choose your role and begin your ScienceBuddy journey.</p>
            <button type="button" class="about-cta__btn" id="aboutGetStartedBtn">
                <i class="bi bi-rocket-takeoff-fill"></i>Get Started
            </button>
        </section>

    <%-- ══ ROLE-SELECTION MODAL ══ --%>
        <div class="about-modal-overlay" id="aboutRoleModal" role="dialog" aria-modal="true" aria-labelledby="aboutModalTitle">
            <div class="about-modal">
                <button type="button" class="about-modal__close" aria-label="Close">
                    &times;
                </button>
                <h3 id="aboutModalTitle">How would you like to continue?</h3>
                <div class="about-modal__roles">
                    <a href="<%: ResolveUrl("~/StudentRegistration.aspx") %>" class="about-modal__role" data-role="student">
                    <div class="about-modal__role-icon about-modal__role-icon--student">
                        <i class="bi bi-mortarboard-fill"></i>
                    </div>
                    <div class="about-modal__role-info">
                        <h4>Student</h4>
                        <p>
                            Learn and explore</p>
                    </div>
                    </a><a href="<%: ResolveUrl("~/ParentRegistration.aspx") %>" class="about-modal__role" data-role="parent">
                    <div class="about-modal__role-icon about-modal__role-icon--parent">
                        <i class="bi bi-heart-fill"></i>
                    </div>
                    <div class="about-modal__role-info">
                        <h4>Parent</h4>
                        <p>
                            Support and encourage</p>
                    </div>
                    </a><a href="<%: ResolveUrl("~/TeacherRegistration.aspx") %>" class="about-modal__role" data-role="teacher">
                    <div class="about-modal__role-icon about-modal__role-icon--teacher">
                        <i class="bi bi-journal-bookmark-fill"></i>
                    </div>
                    <div class="about-modal__role-info">
                        <h4>Teacher</h4>
                        <p>
                            Guide and inspire</p>
                    </div>
                    </a>
                </div>
            </div>
        </div>
    </div>
<script src="<%: ResolveUrl("~/Scripts/About.js") %>"></script>
</asp:Content>
