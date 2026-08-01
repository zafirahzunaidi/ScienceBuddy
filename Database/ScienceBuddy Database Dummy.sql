/* =========================================================
   ScienceBuddy Database
   ========================================================= */

/* Drop tables in reverse order because of Foreign Key dependencies */
IF OBJECT_ID(N'dbo.privateMessage', N'U') IS NOT NULL
    DROP TABLE dbo.[privateMessage];
GO

IF OBJECT_ID(N'dbo.userChat', N'U') IS NOT NULL
    DROP TABLE dbo.[userChat];
GO

IF OBJECT_ID(N'dbo.SPReward', N'U') IS NOT NULL
    DROP TABLE dbo.[SPReward];
GO

IF OBJECT_ID(N'dbo.SPTask', N'U') IS NOT NULL
    DROP TABLE dbo.[SPTask];
GO

IF OBJECT_ID(N'dbo.StudyPlan', N'U') IS NOT NULL
    DROP TABLE dbo.[StudyPlan];
GO

IF OBJECT_ID(N'dbo.AILearningAnalysis', N'U') IS NOT NULL
    DROP TABLE dbo.[AILearningAnalysis];
GO

IF OBJECT_ID(N'dbo.UserStatusAction', N'U') IS NOT NULL
    DROP TABLE dbo.[UserStatusAction];
GO

IF OBJECT_ID(N'dbo.LiveSessionParticipant', N'U') IS NOT NULL
    DROP TABLE dbo.[LiveSessionParticipant];
GO

IF OBJECT_ID(N'dbo.LiveConsultationSession', N'U') IS NOT NULL
    DROP TABLE dbo.[LiveConsultationSession];
GO

IF OBJECT_ID(N'dbo.LabProgress', N'U') IS NOT NULL
    DROP TABLE dbo.[LabProgress];
GO

IF OBJECT_ID(N'dbo.Notification', N'U') IS NOT NULL
    DROP TABLE dbo.[Notification];
GO

IF OBJECT_ID(N'dbo.Log', N'U') IS NOT NULL
    DROP TABLE dbo.[Log];
GO

IF OBJECT_ID(N'dbo.Certificate', N'U') IS NOT NULL
    DROP TABLE dbo.[Certificate];
GO

IF OBJECT_ID(N'dbo.LessonProgress', N'U') IS NOT NULL
    DROP TABLE dbo.[LessonProgress];
GO

IF OBJECT_ID(N'dbo.XPTransaction', N'U') IS NOT NULL
    DROP TABLE dbo.[XPTransaction];
GO

IF OBJECT_ID(N'dbo.QuizAnswer', N'U') IS NOT NULL
    DROP TABLE dbo.[QuizAnswer];
GO

IF OBJECT_ID(N'dbo.QuizResult', N'U') IS NOT NULL
    DROP TABLE dbo.[QuizResult];
GO

IF OBJECT_ID(N'dbo.Question', N'U') IS NOT NULL
    DROP TABLE dbo.[Question];
GO

IF OBJECT_ID(N'dbo.ForumLike', N'U') IS NOT NULL
    DROP TABLE dbo.[ForumLike];
GO

IF OBJECT_ID(N'dbo.ForumTag', N'U') IS NOT NULL
    DROP TABLE dbo.[ForumTag];
GO

IF OBJECT_ID(N'dbo.Tag', N'U') IS NOT NULL
    DROP TABLE dbo.[Tag];
GO

IF OBJECT_ID(N'dbo.ForumChat', N'U') IS NOT NULL
    DROP TABLE dbo.[ForumChat];
GO

IF OBJECT_ID(N'dbo.Forum', N'U') IS NOT NULL
    DROP TABLE dbo.[Forum];
GO

IF OBJECT_ID(N'dbo.Material', N'U') IS NOT NULL
    DROP TABLE dbo.[Material];
GO

IF OBJECT_ID(N'dbo.Quiz', N'U') IS NOT NULL
    DROP TABLE dbo.[Quiz];
GO

IF OBJECT_ID(N'dbo.StudentBadge', N'U') IS NOT NULL
    DROP TABLE dbo.[StudentBadge];
GO

IF OBJECT_ID(N'dbo.Enrollment', N'U') IS NOT NULL
    DROP TABLE dbo.[Enrollment];
GO

IF OBJECT_ID(N'dbo.StudentParent', N'U') IS NOT NULL
    DROP TABLE dbo.[StudentParent];
GO

IF OBJECT_ID(N'dbo.Teacher', N'U') IS NOT NULL
    DROP TABLE dbo.[Teacher];
GO

IF OBJECT_ID(N'dbo.Parent', N'U') IS NOT NULL
    DROP TABLE dbo.[Parent];
GO

IF OBJECT_ID(N'dbo.Student', N'U') IS NOT NULL
    DROP TABLE dbo.[Student];
GO

IF OBJECT_ID(N'dbo.VirtualLab', N'U') IS NOT NULL
    DROP TABLE dbo.[VirtualLab];
GO

IF OBJECT_ID(N'dbo.ConfigurationSetting', N'U') IS NOT NULL
    DROP TABLE dbo.[ConfigurationSetting];
GO

IF OBJECT_ID(N'dbo.XPAction', N'U') IS NOT NULL
    DROP TABLE dbo.[XPAction];
GO

IF OBJECT_ID(N'dbo.Lesson', N'U') IS NOT NULL
    DROP TABLE dbo.[Lesson];
GO

IF OBJECT_ID(N'dbo.Subtopic', N'U') IS NOT NULL
    DROP TABLE dbo.[Subtopic];
GO

IF OBJECT_ID(N'dbo.Unit', N'U') IS NOT NULL
    DROP TABLE dbo.[Unit];
GO

IF OBJECT_ID(N'dbo.Badge', N'U') IS NOT NULL
    DROP TABLE dbo.[Badge];
GO

IF OBJECT_ID(N'dbo.Personality', N'U') IS NOT NULL
    DROP TABLE dbo.[Personality];
GO

IF OBJECT_ID(N'dbo.Level', N'U') IS NOT NULL
    DROP TABLE dbo.[Level];
GO

-- Password reset tokens must be removed before the User table.
IF OBJECT_ID(N'dbo.PasswordResetToken', N'U') IS NOT NULL
    DROP TABLE dbo.[PasswordResetToken];
GO

IF OBJECT_ID(N'dbo.User', N'U') IS NOT NULL
    DROP TABLE dbo.[User];
GO



/* =========================================================
   Create tables
   ========================================================= */

Create table [User]
(
    userId nvarchar(10) Primary Key,
    username nvarchar(50) NOT NULL unique,
    [password] nvarchar(100) NOT NULL,
    email nvarchar(100) NOT NULL unique,
    [role] nvarchar(20) NOT NULL,
    preferredLanguage nvarchar(10) NOT NULL,
    [status] nvarchar(20) NOT NULL
);

-- Stores one-time tokens used by the forgot password feature.
Create table PasswordResetToken
(
    tokenId nvarchar(10) Primary Key,
    userId nvarchar(10) NOT NULL Foreign Key References [User](userId),
    tokenHash nvarchar(64) NOT NULL,
    createdAt datetime2 NOT NULL,
    expiresAt datetime2 NOT NULL,
    usedAt datetime2 NULL
);

Create table [Level]
(
    levelId nvarchar(10) Primary Key,
    levelNameEN nvarchar(50) NOT NULL,
    levelNameBM nvarchar(50) NOT NULL,
    levelDescriptionEN nvarchar(500) NULL,
    levelDescriptionBM nvarchar(500) NULL
);

Create table Personality
(
    personalityId nvarchar(10) Primary Key,
    personalityNameEN nvarchar(50) NOT NULL,
    personalityNameBM nvarchar(50) NOT NULL,
    descriptionEN nvarchar(500) NULL,
    descriptionBM nvarchar(500) NULL,
    avatar nvarchar(200) NULL,
    colour nvarchar(20) NULL,
    learningStyleEN nvarchar(100) NULL,
    learningStyleBM nvarchar(100) NULL
);

Create table Badge
(
    badgeId nvarchar(10) Primary Key,
    badgeNameEN nvarchar(100) NOT NULL,
    badgeNameBM nvarchar(100) NOT NULL,
    badgeType nvarchar(50) NOT NULL,
    xpReward int NOT NULL,
    badgeIcon nvarchar(200) NULL,
    requirementDescriptionEN nvarchar(500) NULL,
    requirementDescriptionBM nvarchar(500) NULL,
    badgeDescriptionEN nvarchar(500) NULL,
    badgeDescriptionBM nvarchar(500) NULL
);

Create table Unit
(
    unitId nvarchar(10) Primary Key,
    levelId nvarchar(10) NOT NULL Foreign Key References [Level](levelId),
    unitNameEN nvarchar(100) NOT NULL,
    unitNameBM nvarchar(100) NOT NULL,
    unitDescriptionEN nvarchar(500) NULL,
    unitDescriptionBM nvarchar(500) NULL,
    orderNo int NOT NULL
);

Create table Subtopic
(
    subtopicId nvarchar(10) Primary Key,
    unitId nvarchar(10) NOT NULL Foreign Key References Unit(unitId),
    subtopicTitleEN nvarchar(100) NOT NULL,
    subtopicTitleBM nvarchar(100) NOT NULL,
    subtopicDescriptionEN nvarchar(500) NULL,
    subtopicDescriptionBM nvarchar(500) NULL,
    orderNo int NOT NULL
);

Create table Lesson
(
    lessonId nvarchar(10) Primary Key,
    subtopicId nvarchar(10) NOT NULL Foreign Key References Subtopic(subtopicId),
    lessonTitleEN nvarchar(100) NOT NULL,
    lessonTitleBM nvarchar(100) NOT NULL,
    lessonContentEN NVARCHAR(MAX) NULL,
    lessonContentBM NVARCHAR(MAX) NULL,
    attachmentUrl nvarchar(200) NULL,
    orderNo int NOT NULL
);

Create table XPAction
(
    xpActionId nvarchar(10) Primary Key,
    actionNameEN nvarchar(100) NOT NULL,
    actionNameBM nvarchar(100) NOT NULL,
    xpValue int NOT NULL
);

Create table ConfigurationSetting
(
    configId nvarchar(20) Primary Key,
    configKey nvarchar(100) NOT NULL,
    configValue int NOT NULL,
    lastUpdated datetime NOT NULL
);

Create table VirtualLab
(
    labId nvarchar(10) Primary Key,
    unitId nvarchar(10) NOT NULL Foreign Key References Unit(unitId),
    labTitleEN nvarchar(100) NOT NULL,
    labTitleBM nvarchar(100) NOT NULL,
    labDescriptionEN nvarchar(500) NULL,
    labDescriptionBM nvarchar(500) NULL,
    instructionEN nvarchar(max) NULL,
    instructionBM nvarchar(max) NULL,
    labType nvarchar(50) NOT NULL,
    difficulty nvarchar(20) NOT NULL,
    createdAt datetime NOT NULL
);

Create table Student
(
    studentId nvarchar(10) Primary Key,
    userId nvarchar(10) NOT NULL Foreign Key References [User](userId),
    [name] nvarchar(100) NOT NULL,
    phoneNumber nvarchar(20) NULL,
    nickname nvarchar(50) NULL,
    currentLevelId nvarchar(10) NULL Foreign Key References [Level](levelId),
    XP int NOT NULL,
    personalityId nvarchar(10) NULL Foreign Key References Personality(personalityId),
    parentCode nvarchar(20) NULL unique
);

Create table Parent
(
    parentId nvarchar(10) Primary Key,
    userId nvarchar(10) NOT NULL Foreign Key References [User](userId),
    [name] nvarchar(100) NOT NULL,
    phoneNumber nvarchar(20) NULL
);

Create table Teacher
(
    teacherId nvarchar(10) Primary Key,
    userId nvarchar(10) NOT NULL Foreign Key References [User](userId),
    [name] nvarchar(100) NOT NULL,
    phoneNumber nvarchar(20) NULL,
    academicQualification nvarchar(200) NULL,
    bio nvarchar(500) NULL,
    licenseCert nvarchar(200) NULL,
    [status] nvarchar(30) NOT NULL,
    approvedDate datetime NULL
);

Create table StudentParent
(
    studentParentId nvarchar(10) Primary Key,
    studentId nvarchar(10) NOT NULL Foreign Key References Student(studentId),
    parentId nvarchar(10) NOT NULL Foreign Key References Parent(parentId),
    relationship nvarchar(50) NOT NULL
);

Create table Enrollment
(
    enrollmentId nvarchar(10) Primary Key,
    studentId nvarchar(10) NOT NULL Foreign Key References Student(studentId),
    levelId nvarchar(10) NOT NULL Foreign Key References [Level](levelId),
    enrolledDate datetime NOT NULL,
    [status] nvarchar(20) NOT NULL
);

Create table StudentBadge
(
    studentBadgeId nvarchar(10) Primary Key,
    studentId nvarchar(10) NOT NULL Foreign Key References Student(studentId),
    badgeId nvarchar(10) NOT NULL Foreign Key References Badge(badgeId),
    earnedAt datetime NOT NULL
);

Create table Quiz
(
    quizId nvarchar(10) Primary Key,
    levelId nvarchar(10) NULL Foreign Key References [Level](levelId),
    unitId nvarchar(10) NULL Foreign Key References Unit(unitId),
    quizTitleEN nvarchar(100) NULL,
    quizTitleBM nvarchar(100) NULL,
    quizType nvarchar(20) NOT NULL,
    [status] nvarchar(20) NULL,
    createdByUserId nvarchar(10) NOT NULL Foreign Key References [User](userId),
    createdAt datetime NOT NULL,
    language nvarchar(10) NOT NULL
);

Create table Material
(
    materialId nvarchar(10) Primary Key,
    subtopicId nvarchar(10) NOT NULL Foreign Key References Subtopic(subtopicId),
    createdByUserId nvarchar(10) NOT NULL Foreign Key References [User](userId),
    materialTitle nvarchar(100) NOT NULL,
    materialType nvarchar(30) NOT NULL,
    fileUrl nvarchar(200) NULL,
    materialContent nvarchar(max) NULL,
    createdDate datetime NOT NULL,
    [status] nvarchar(20) NOT NULL,
    reviewedDate datetime NULL,
    language nvarchar(10) NOT NULL
);

Create table Forum
(
    forumId nvarchar(10) Primary Key,
    createdBy nvarchar(10) NOT NULL Foreign Key References [User](userId),
    title nvarchar(200) NOT NULL,
    message nvarchar(max) NULL,
    discussionType nvarchar(20) NOT NULL,
    createdAt datetime NOT NULL
);

Create table ForumChat
(
    forumChatId nvarchar(10) Primary Key,
    forumId nvarchar(10) NOT NULL Foreign Key References Forum(forumId),
    senderUserId nvarchar(10) NOT NULL Foreign Key References [User](userId),
    message nvarchar(max) NULL,
    createdAt datetime NOT NULL
);

Create table Tag
(
    tagId nvarchar(10) Primary Key,
    tagName nvarchar(100) NOT NULL,
    createdAt datetime NOT NULL
);

Create table ForumTag
(
    forumTagId nvarchar(10) Primary Key,
    forumId nvarchar(10) NOT NULL Foreign Key References Forum(forumId),
    tagId nvarchar(10) NOT NULL Foreign Key References Tag(tagId)
);

Create table ForumLike
(
    likeId nvarchar(10) Primary Key,
    forumId nvarchar(10) NOT NULL Foreign Key References Forum(forumId),
    senderUserId nvarchar(10) NOT NULL Foreign Key References [User](userId),
    createdAt datetime NOT NULL
);

Create table Question
(
    questionId nvarchar(10) Primary Key,
    quizId nvarchar(10) NOT NULL Foreign Key References Quiz(quizId),
    subtopicId nvarchar(10) NOT NULL Foreign Key References Subtopic(subtopicId),
    createdByUserId nvarchar(10) NOT NULL Foreign Key References [User](userId),
    questionTextEN nvarchar(max) NULL,
    questionTextBM nvarchar(max) NULL,
    questionType nvarchar(50) NOT NULL,
    questionImageUrl nvarchar(200) NULL,
    optionA_EN nvarchar(500) NULL,
    optionA_BM nvarchar(500) NULL,
    optionB_EN nvarchar(500) NULL,
    optionB_BM nvarchar(500) NULL,
    optionC_EN nvarchar(500) NULL,
    optionC_BM nvarchar(500) NULL,
    optionD_EN nvarchar(500) NULL,
    optionD_BM nvarchar(500) NULL,
    correctAnswer nvarchar(200) NOT NULL,
    correctExplanationEN nvarchar(max) NULL,
    correctExplanationBM nvarchar(max) NULL,
    wrongExplanationEN nvarchar(max) NULL,
    wrongExplanationBM nvarchar(max) NULL,
    difficulty nvarchar(20) NOT NULL,
    [status] nvarchar(20) NOT NULL,
    createdAt datetime NOT NULL,
    reviewedDate datetime NULL
);

Create table QuizResult
(
    resultId nvarchar(10) Primary Key,
    studentId nvarchar(10) NOT NULL Foreign Key References Student(studentId),
    quizId nvarchar(10) NOT NULL Foreign Key References Quiz(quizId),
    score int NOT NULL,
    totalMarks int NOT NULL,
    percentage decimal(5,2) NOT NULL,
    resultStatus nvarchar(20) NOT NULL,
    attemptNo int NOT NULL,
    attemptedDate datetime NOT NULL
);

Create table QuizAnswer
(
    answerId nvarchar(10) Primary Key,
    resultId nvarchar(10) NOT NULL Foreign Key References QuizResult(resultId),
    questionId nvarchar(10) NOT NULL Foreign Key References Question(questionId),
    selectedAnswer nvarchar(500) NULL,
    isCorrect bit NOT NULL,
    marksAwarded int NOT NULL
);

Create table XPTransaction
(
    xpTransactionId nvarchar(10) Primary Key,
    studentId nvarchar(10) NOT NULL Foreign Key References Student(studentId),
    xpActionId nvarchar(10) NOT NULL Foreign Key References XPAction(xpActionId),
    xpAmount int NOT NULL,
    dateEarned datetime NOT NULL
);

Create table LessonProgress
(
    progressId nvarchar(10) Primary Key,
    studentId nvarchar(10) NOT NULL Foreign Key References Student(studentId),
    lessonId nvarchar(10) NOT NULL Foreign Key References Lesson(lessonId),
    isCompleted bit NOT NULL,
    completedDate datetime NULL
);

Create table Certificate
(
    certificateId nvarchar(20) Primary Key,
    studentId nvarchar(10) NOT NULL Foreign Key References Student(studentId),
    levelId nvarchar(10) NOT NULL Foreign Key References [Level](levelId),
    certificateTitleEN nvarchar(100) NOT NULL,
    certificateTitleBM nvarchar(100) NOT NULL,
    certificateDescriptionEN nvarchar(500) NULL,
    certificateDescriptionBM nvarchar(500) NULL,
    issuedDate datetime NULL,
    certificateUrl nvarchar(200) NULL,
    certificateCode nvarchar(50) NULL,
    [status] nvarchar(20) NOT NULL
);

Create table [Log]
(
    logId nvarchar(10) Primary Key,
    userId nvarchar(10) NOT NULL Foreign Key References [User](userId),
    [action] nvarchar(50) NOT NULL,
    description nvarchar(500) NULL,
    logDateTime datetime NOT NULL,
    [status] nvarchar(20) NOT NULL
);

Create table Notification
(
    notificationId nvarchar(10) Primary Key,
    toUserId nvarchar(10) NOT NULL Foreign Key References [User](userId),
    titleEN nvarchar(100) NOT NULL,
    titleBM nvarchar(100) NOT NULL,
    messageEN nvarchar(500) NULL,
    messageBM nvarchar(500) NULL,
    isRead bit NOT NULL,
    createdAt datetime NOT NULL
);

Create table LabProgress
(
    labProgressId nvarchar(10) Primary Key,
    studentId nvarchar(10) NOT NULL Foreign Key References Student(studentId),
    labId nvarchar(10) NOT NULL Foreign Key References VirtualLab(labId),
    isCompleted bit NOT NULL,
    completedDate datetime NULL
);

Create table LiveConsultationSession
(
    sessionId nvarchar(10) Primary Key,
    teacherId nvarchar(10) NOT NULL Foreign Key References Teacher(teacherId),
    unitId nvarchar(10) NOT NULL Foreign Key References Unit(unitId),
    subtopicId nvarchar(10) NOT NULL Foreign Key References Subtopic(subtopicId),
    sessionTitle nvarchar(100) NOT NULL,
    sessionDescription nvarchar(500) NULL,
    meetingLink nvarchar(200) NULL,
    startDateTime datetime NOT NULL,
    endDateTime datetime NOT NULL,
    [status] nvarchar(20) NOT NULL
);

Create table LiveSessionParticipant
(
    participantId nvarchar(20) Primary Key,
    sessionId nvarchar(10) NOT NULL Foreign Key References LiveConsultationSession(sessionId),
    studentId nvarchar(10) NOT NULL Foreign Key References Student(studentId),
    joinedAt datetime NOT NULL
);

Create table UserStatusAction
(
    actionId nvarchar(10) Primary Key,
    userId nvarchar(10) NOT NULL Foreign Key References [User](userId),
    actionType nvarchar(20) NOT NULL,
    reason nvarchar(500) NULL,
    actionDate datetime NOT NULL,
    performedBy nvarchar(10) NOT NULL Foreign Key References [User](userId)
);

Create table AILearningAnalysis
(
    analysisId nvarchar(10) Primary Key,
    studentId nvarchar(10) NOT NULL Foreign Key References Student(studentId),
    analysisJson nvarchar(max) NULL,
    overallSummary nvarchar(500) NULL,
    strongTopics nvarchar(500) NULL,
    weakTopics nvarchar(500) NULL,
    avgQuizScore decimal(5,2) NULL,
    totalQuizAttempts int NOT NULL,
    isLatest bit NOT NULL
);

Create table StudyPlan
(
    studyPlanId nvarchar(10) Primary Key,
    studentParentId nvarchar(10) NULL Foreign Key References StudentParent(studentParentId),
    createdByUserId nvarchar(10) NOT NULL Foreign Key References [User](userId),
    planTitle nvarchar(100) NOT NULL,
    startDate datetime NOT NULL,
    endDate datetime NOT NULL,
    [status] nvarchar(20) NOT NULL,
    createdAt datetime NOT NULL
);

Create table SPTask
(
    spTaskId nvarchar(10) Primary Key,
    studyPlanId nvarchar(10) NOT NULL Foreign Key References StudyPlan(studyPlanId),
    taskTitle nvarchar(100) NOT NULL,
    suggestedAction nvarchar(500) NULL,
    orderNo int NOT NULL,
    isCompleted bit NOT NULL,
    completedAt datetime NULL
);

Create table SPReward
(
    rewardId nvarchar(10) Primary Key,
    studyPlanId nvarchar(10) NOT NULL Foreign Key References StudyPlan(studyPlanId),
    rewardName nvarchar(100) NOT NULL,
    requiredProgress int NOT NULL,
    isUnlocked bit NOT NULL,
    unlockedAt datetime NULL,
    rewardImage nvarchar(200) NULL
);

Create table userChat
(
    chatId nvarchar(10) Primary Key,
    userId nvarchar(10) NOT NULL Foreign Key References [User](userId),
    user2Id nvarchar(10) NOT NULL Foreign Key References [User](userId),
    createdAt datetime NOT NULL
);

Create table privateMessage
(
    privateMsgId nvarchar(10) Primary Key,
    chatId nvarchar(10) NOT NULL Foreign Key References userChat(chatId),
    senderUserId nvarchar(10) NOT NULL Foreign Key References [User](userId),
    msgText nvarchar(max) NOT NULL,
    attachmentFile nvarchar(200) NULL,
    sentAt datetime NOT NULL,
    isRead bit NOT NULL,
    readAt datetime NULL
);
GO

/* =========================================================
   Insert constant/master data first
   ========================================================= */

-- ScienceBuddy Constant Data

insert into [Level] values
(N'LV001', N'Beginner', N'Pemula', N'Suitable for students who are starting to learn basic Science concepts.', N'Sesuai untuk murid yang baru mula mempelajari konsep asas Sains.'),
(N'LV002', N'Intermediate', N'Pertengahan', N'Suitable for students who have basic Science understanding and are ready for more detailed topics.', N'Sesuai untuk murid yang mempunyai kefahaman asas Sains dan bersedia untuk topik yang lebih terperinci.'),
(N'LV003', N'Advanced', N'Lanjutan', N'Suitable for students who are ready to explore more challenging Science concepts and assessments.', N'Sesuai untuk murid yang bersedia meneroka konsep dan penilaian Sains yang lebih mencabar.');

insert into Personality values
(N'P001', N'Achiever', N'Pencapai', N'A goal-oriented learner who enjoys progress, rewards, badges, and completing learning targets.', N'Murid yang berorientasikan matlamat dan suka melihat kemajuan, ganjaran, lencana serta menyelesaikan sasaran pembelajaran.', N'Images/Personality/achiever.png', N'#F5B041', N'Goal-based learning', N'Pembelajaran berasaskan matlamat'),
(N'P002', N'Creative', N'Kreatif', N'A visual and imaginative learner who enjoys colourful notes, flashcards, videos, and virtual lab activities.', N'Murid yang visual dan imaginatif serta suka nota berwarna, kad imbas, video dan aktiviti makmal maya.', N'Images/Personality/creative.png', N'#9B59B6', N'Visual and interactive learning', N'Pembelajaran visual dan interaktif'),
(N'P003', N'Thinker', N'Pemikir', N'A curious learner who enjoys understanding reasons, reviewing explanations, and analysing weak topics.', N'Murid yang ingin tahu dan suka memahami sebab, menyemak penerangan serta menganalisis topik lemah.', N'Images/Personality/thinker.png', N'#3498DB', N'Explanation-based learning', N'Pembelajaran berasaskan penerangan'),
(N'P004', N'Go-Getter', N'Bersemangat', N'An active learner who enjoys challenges, quizzes, leaderboard ranking, and fast progress.', N'Murid yang aktif dan suka cabaran, kuiz, kedudukan papan markah serta kemajuan yang cepat.', N'Images/Personality/gogetter.png', N'#E74C3C', N'Challenge-based learning', N'Pembelajaran berasaskan cabaran'),
(N'P005', N'Chill Learner', N'Santai', N'A calm learner who prefers step-by-step learning, gentle reminders, and stress-free activities.', N'Murid yang tenang dan lebih suka pembelajaran langkah demi langkah, peringatan lembut dan aktiviti tanpa tekanan.', N'Images/Personality/chill-learner.png', N'#58D68D', N'Step-by-step learning', N'Pembelajaran langkah demi langkah'),
(N'P006', N'Socializer', N'Sosial', N'A collaborative learner who enjoys discussions, teacher guidance, live sessions, and learning with others.', N'Murid yang suka bekerjasama melalui perbincangan, bimbingan guru, sesi langsung dan pembelajaran bersama orang lain.', N'Images/Personality/socializer.png', N'#F39C12', N'Collaborative learning', N'Pembelajaran kolaboratif');

insert into Badge values
(N'B001', N'First Step Learner', N'Pelajar Langkah Pertama', N'Lesson', 20, N'Images/Badge/first-step.png', N'Complete the first lesson.', N'Selesaikan pelajaran pertama.', N'Awarded to students who begin their learning journey by completing their first lesson.', N'Diberikan kepada murid yang memulakan perjalanan pembelajaran dengan menyelesaikan pelajaran pertama.'),
(N'B002', N'Lab Explorer', N'Penjelajah Makmal', N'Lab', 30, N'Images/Badge/lab-explorer.png', N'Complete the first virtual lab.', N'Selesaikan makmal maya pertama.', N'Awarded to students who complete their first interactive virtual lab activity.', N'Diberikan kepada murid yang menyelesaikan aktiviti makmal maya interaktif pertama.'),
(N'B003', N'Quiz Starter', N'Pemula Kuiz', N'Quiz', 20, N'Images/Badge/quiz-starter.png', N'Attempt the first quiz.', N'Jawab kuiz pertama.', N'Awarded to students who attempt their first quiz or self-assessment.', N'Diberikan kepada murid yang menjawab kuiz atau penilaian kendiri pertama.'),
(N'B004', N'High Scorer', N'Skor Cemerlang', N'Quiz', 40, N'Images/Badge/high-scorer.png', N'Score 80% or above in any quiz.', N'Mendapat markah 80% ke atas dalam mana-mana kuiz.', N'Awarded to students who achieve excellent quiz performance.', N'Diberikan kepada murid yang mencapai prestasi kuiz yang cemerlang.'),
(N'B005', N'Unit Master', N'Pakar Unit', N'Unit', 50, N'Images/Badge/unit-master.png', N'Complete all lessons, labs, and unit quiz in one unit.', N'Selesaikan semua pelajaran, makmal dan kuiz unit dalam satu unit.', N'Awarded to students who successfully complete all required activities in one unit.', N'Diberikan kepada murid yang berjaya menyelesaikan semua aktiviti wajib dalam satu unit.'),
(N'B006', N'Beginner Champion', N'Juara Pemula', N'Level', 100, N'Images/Badge/beginner-champion.png', N'Complete Beginner level requirements.', N'Selesaikan keperluan tahap Pemula.', N'Awarded to students who complete all required Beginner level learning activities.', N'Diberikan kepada murid yang menyelesaikan semua aktiviti pembelajaran wajib tahap Pemula.'),
(N'B007', N'Intermediate Champion', N'Juara Pertengahan', N'Level', 120, N'Images/Badge/intermediate-champion.png', N'Complete Intermediate level requirements.', N'Selesaikan keperluan tahap Pertengahan.', N'Awarded to students who complete all required Intermediate level learning activities.', N'Diberikan kepada murid yang menyelesaikan semua aktiviti pembelajaran wajib tahap Pertengahan.'),
(N'B008', N'Advanced Champion', N'Juara Lanjutan', N'Level', 150, N'Images/Badge/advanced-champion.png', N'Complete Advanced level requirements.', N'Selesaikan keperluan tahap Lanjutan.', N'Awarded to students who complete all required Advanced level learning activities.', N'Diberikan kepada murid yang menyelesaikan semua aktiviti pembelajaran wajib tahap Lanjutan.'),
(N'B009', N'Forum Helper', N'Pembantu Forum', N'Forum', 25, N'Images/Badge/forum-helper.png', N'Post or reply in the public forum.', N'Hantar hantaran atau balasan dalam forum awam.', N'Awarded to students who actively participate in public learning discussions.', N'Diberikan kepada murid yang aktif menyertai perbincangan pembelajaran awam.'),
(N'B010', N'Consistent Learner', N'Pelajar Konsisten', N'Progress', 50, N'Images/Badge/consistent-learner.png', N'Complete learning activities on multiple days.', N'Selesaikan aktiviti pembelajaran pada beberapa hari berbeza.', N'Awarded to students who show consistent learning effort over time.', N'Diberikan kepada murid yang menunjukkan usaha pembelajaran yang konsisten dari semasa ke semasa.');

insert into Unit values
(N'UN101', N'LV001', N'Humans', N'Manusia', N'Learn about human senses and how they help us understand the world.', N'Mempelajari deria manusia dan kegunaannya dalam kehidupan harian.', 1),
(N'UN102', N'LV001', N'Magnets', N'Magnet', N'Learn the uses, shapes, attraction and repulsion of magnets.', N'Mempelajari kegunaan, bentuk, tarikan dan tolakan magnet.', 2),
(N'UN103', N'LV001', N'Absorption', N'Penyerapan', N'Learn about water absorbent and non-water absorbent materials.', N'Mempelajari bahan yang menyerap dan tidak menyerap air.', 3),
(N'UN104', N'LV001', N'The Earth', N'Bumi', N'Learn about landforms and soil found on Earth.', N'Mempelajari bentuk muka bumi dan tanah.', 4),
(N'UN105', N'LV001', N'Basics of Buildings', N'Asas Binaan', N'Learn basic shapes and their importance in construction.', N'Mempelajari bentuk asas dan kepentingannya dalam binaan.', 5),
(N'UN201', N'LV002', N'Humans', N'Manusia', N'Learn about teeth, balanced diets and the digestive system.', N'Mempelajari gigi, pemakanan seimbang dan sistem pencernaan.', 1),
(N'UN202', N'LV002', N'Density', N'Ketumpatan', N'Learn about floating, sinking and density in daily life.', N'Mempelajari konsep timbul, tenggelam dan ketumpatan dalam kehidupan.', 2),
(N'UN203', N'LV002', N'Acid and Alkali', N'Asid dan Alkali', N'Learn about acidic, alkaline and neutral substances around us.', N'Mempelajari bahan berasid, beralkali dan neutral di sekeliling kita.', 3),
(N'UN204', N'LV002', N'The Solar System', N'Sistem Suria', N'Learn about planets, orbits and the solar system.', N'Mempelajari planet, orbit dan sistem suria.', 4),
(N'UN205', N'LV002', N'Machine', N'Mesin', N'Learn about pulleys and how they make work easier.', N'Mempelajari takal dan kegunaannya dalam memudahkan kerja.', 5),
(N'UN301', N'LV003', N'Humans', N'Manusia', N'Learn about the human skeletal system, joints and blood circulation system.', N'Mempelajari sistem rangka, sendi dan sistem peredaran darah manusia.', 1),
(N'UN302', N'LV003', N'Electricity', N'Elektrik', N'Learn about electrical circuits, conductors and electrical safety.', N'Mempelajari litar elektrik, pengalir elektrik dan keselamatan elektrik.', 2),
(N'UN303', N'LV003', N'Matter', N'Jirim', N'Learn about the properties and changes of matter.', N'Mempelajari sifat dan perubahan jirim.', 3),
(N'UN304', N'LV003', N'Phases of the Moon and Constellations', N'Fasa Bulan dan Buruj', N'Learn about moon phases and constellations in the night sky.', N'Mempelajari fasa bulan dan buruj di langit malam.', 4),
(N'UN305', N'LV003', N'Machines', N'Mesin', N'Learn about simple machines and their functions.', N'Mempelajari mesin ringkas dan fungsinya.', 5);

insert into Subtopic values
(N'ST111', N'UN101', N'Human Sense', N'Deria Manusia', N'Learn about the five human senses.', N'Mempelajari lima deria manusia.', 1),
(N'ST112', N'UN101', N'Classify Taste', N'Mengelaskan Rasa', N'Learn to classify different tastes.', N'Mempelajari cara mengelaskan rasa.', 2),
(N'ST113', N'UN101', N'The Use of Human Sense', N'Kegunaan Deria Manusia', N'Learn how senses help us in daily life.', N'Mempelajari kegunaan deria dalam kehidupan harian.', 3),
(N'ST121', N'UN102', N'Uses of Magnets', N'Kegunaan Magnet', N'Learn the uses of magnets.', N'Mempelajari kegunaan magnet.', 1),
(N'ST122', N'UN102', N'Shapes of Magnets', N'Bentuk Magnet', N'Learn the different shapes of magnets.', N'Mempelajari pelbagai bentuk magnet.', 2),
(N'ST123', N'UN102', N'Attraction and Repulsion of Magnets', N'Tarikan dan Tolakan Magnet', N'Learn how magnets attract and repel.', N'Mempelajari tarikan dan tolakan magnet.', 3),
(N'ST131', N'UN103', N'Water Absorbent vs Non-Water Absorbent', N'Objek Menyerap Air, Objek Tidak Menyerap Air', N'Learn the difference between absorbent and non-absorbent materials.', N'Mempelajari perbezaan bahan menyerap dan tidak menyerap air.', 1),
(N'ST132', N'UN103', N'Importance of Water Absorbent and Non-Water Absorbent', N'Kepentingan Objek Menyerap dan Objek Tidak Menyerap Air', N'Learn their uses in daily life.', N'Mempelajari kegunaannya dalam kehidupan harian.', 2),
(N'ST141', N'UN104', N'Landforms', N'Bentuk Muka Bumi', N'Learn different landforms on Earth.', N'Mempelajari pelbagai bentuk muka bumi.', 1),
(N'ST142', N'UN104', N'Soil', N'Tanah', N'Learn about soil and its characteristics.', N'Mempelajari tanah dan ciri-cirinya.', 2),
(N'ST151', N'UN105', N'Basic Shapes', N'Bentuk Asas', N'Learn common basic shapes.', N'Mempelajari bentuk asas.', 1),
(N'ST152', N'UN105', N'Basic Shape Blocks', N'Bongkah Bentuk Asas', N'Learn about blocks formed from basic shapes.', N'Mempelajari bongkah bentuk asas.', 2),
(N'ST153', N'UN105', N'Importance of Block Shapes', N'Kepentingan Bentuk Bongkah', N'Learn why block shapes are important in buildings.', N'Mempelajari kepentingan bentuk bongkah dalam binaan.', 3),
(N'ST211', N'UN201', N'Teeth', N'Gigi', N'Learn about the types, functions and care of teeth.', N'Mempelajari jenis, fungsi dan penjagaan gigi.', 1),
(N'ST212', N'UN201', N'Balanced Diet', N'Pemakanan Seimbang', N'Learn about food groups and balanced nutrition.', N'Mempelajari kumpulan makanan dan pemakanan seimbang.', 2),
(N'ST213', N'UN201', N'Digestion Process', N'Proses Pencernaan', N'Learn how food is digested in the human body.', N'Mempelajari proses pencernaan makanan dalam badan manusia.', 3),
(N'ST221', N'UN202', N'Float and Sink', N'Timbul dan Tenggelam', N'Learn why objects float or sink in water.', N'Mempelajari sebab objek timbul atau tenggelam di dalam air.', 1),
(N'ST222', N'UN202', N'Density', N'Ketumpatan', N'Learn the concept of density and its effects.', N'Mempelajari konsep ketumpatan dan kesannya.', 2),
(N'ST223', N'UN202', N'Applications of Density in Life', N'Aplikasi Ketumpatan dalam Kehidupan', N'Learn how density is applied in daily life.', N'Mempelajari aplikasi ketumpatan dalam kehidupan harian.', 3),
(N'ST231', N'UN203', N'Acidic, Alkaline and Neutral', N'Asid, Alkali dan Neutral', N'Learn the properties of acidic, alkaline and neutral substances.', N'Mempelajari sifat bahan berasid, beralkali dan neutral.', 1),
(N'ST232', N'UN203', N'Acidic, Alkaline and Neutral Substances Around Us', N'Bahan Asid, Alkali dan Neutral di Sekeliling Kita', N'Learn to identify substances around us.', N'Mempelajari cara mengenal pasti bahan di sekeliling kita.', 2),
(N'ST241', N'UN204', N'Members of the Solar System', N'Ahli Sistem Suria', N'Learn about the planets and objects in the Solar System.', N'Mempelajari planet dan objek dalam Sistem Suria.', 1),
(N'ST242', N'UN204', N'Temperature of Planets', N'Suhu Planet', N'Learn about temperature differences between planets.', N'Mempelajari perbezaan suhu antara planet.', 2),
(N'ST243', N'UN204', N'Orbit of Planets', N'Orbit Planet', N'Learn how planets orbit the Sun.', N'Mempelajari bagaimana planet mengorbit Matahari.', 3),
(N'ST244', N'UN204', N'Revolution Time of Planets', N'Masa Peredaran Planet', N'Learn the revolution period of planets.', N'Mempelajari tempoh peredaran planet.', 4),
(N'ST251', N'UN205', N'Pulleys and Its Types', N'Takal dan Jenis Takal', N'Learn about pulleys and their different types.', N'Mempelajari takal dan pelbagai jenis takal.', 1),
(N'ST252', N'UN205', N'Functions of a Fixed Pulley', N'Fungsi Takal Tetap', N'Learn how fixed pulleys make work easier.', N'Mempelajari fungsi takal tetap dalam memudahkan kerja.', 2),
(N'ST253', N'UN205', N'Uses of Pulleys', N'Kegunaan Takal', N'Learn the uses of pulleys in daily life.', N'Mempelajari kegunaan takal dalam kehidupan harian.', 3),
(N'ST311', N'UN301', N'Human Skeletal System', N'Sistem Rangka Manusia', N'Learn about the structure and functions of the skeletal system.', N'Mempelajari struktur dan fungsi sistem rangka manusia.', 1),
(N'ST312', N'UN301', N'Joints', N'Sendi', N'Learn about joints and body movement.', N'Mempelajari sendi dan pergerakan badan.', 2),
(N'ST313', N'UN301', N'Human Blood Circulatory System', N'Sistem Peredaran Darah Manusia', N'Learn about the circulatory system and its components.', N'Mempelajari sistem peredaran darah dan komponennya.', 3),
(N'ST314', N'UN301', N'Human Blood Circulatory Pathway', N'Laluan Peredaran Darah Manusia', N'Learn how blood circulates through the body.', N'Mempelajari laluan peredaran darah dalam badan.', 4),
(N'ST321', N'UN302', N'Sources of Electrical Energy', N'Sumber Tenaga Elektrik', N'Learn about different sources of electrical energy.', N'Mempelajari pelbagai sumber tenaga elektrik.', 1),
(N'ST322', N'UN302', N'Series Circuit and Parallel Circuit', N'Litar Bersiri dan Litar Selari', N'Learn the differences between series and parallel circuits.', N'Mempelajari perbezaan antara litar bersiri dan litar selari.', 2),
(N'ST323', N'UN302', N'Electrical Circuit Symbols', N'Simbol Litar Elektrik', N'Learn electrical symbols and diagrams.', N'Mempelajari simbol dan rajah litar elektrik.', 3),
(N'ST331', N'UN303', N'Matter Changes State', N'Perubahan Keadaan Jirim', N'Learn how matter changes from one state to another.', N'Mempelajari perubahan keadaan jirim.', 1),
(N'ST332', N'UN303', N'Properties of Matter', N'Sifat Jirim', N'Learn the physical properties of matter.', N'Mempelajari sifat fizikal jirim.', 2),
(N'ST333', N'UN303', N'Water Cycle', N'Kitaran Air', N'Learn the processes involved in the water cycle.', N'Mempelajari proses-proses dalam kitaran air.', 3),
(N'ST341', N'UN304', N'Phases of the Moon', N'Fasa Bulan', N'Learn the phases of the Moon and how they occur.', N'Mempelajari fasa-fasa Bulan dan bagaimana ia berlaku.', 1),
(N'ST342', N'UN304', N'Constellations', N'Buruj', N'Learn about constellations and their uses.', N'Mempelajari buruj dan kegunaannya.', 2),
(N'ST351', N'UN305', N'Pulley', N'Takal', N'Learn how pulleys work as simple machines.', N'Mempelajari cara takal berfungsi sebagai mesin ringkas.', 1),
(N'ST352', N'UN305', N'Gear', N'Gear', N'Learn how gears transfer motion and force.', N'Mempelajari cara gear memindahkan pergerakan dan daya.', 2),
(N'ST353', N'UN305', N'Simple Machines', N'Mesin Ringkas', N'Learn about different types of simple machines.', N'Mempelajari pelbagai jenis mesin ringkas.', 3),
(N'ST354', N'UN305', N'Compound Machines', N'Mesin Kompleks', N'Learn how simple machines combine to form compound machines.', N'Mempelajari gabungan mesin ringkas membentuk mesin kompleks.', 4);

insert into Lesson values
(N'LS001', N'ST111', N'Human Sense', N'Deria Manusia', N'<p>We explore the world using <strong>five amazing senses</strong>!</p>

<p>Each sense has a special body part that helps us understand what is around us:</p>

<ul>
  <li><strong>Eyes</strong> help us see colours, sizes, and shapes.</li>
  <li><strong>Ears</strong> help us hear sounds, such as loud music or soft whispers.</li>
  <li><strong>Nose</strong> helps us smell things, such as fragrant flowers or stinky trash.</li>
  <li><strong>Tongue</strong> helps us taste food and drinks.</li>
  <li><strong>Skin</strong> helps us feel things that are rough, smooth, hard, or soft.</li>
</ul>

<div class="lesson-tip">
  Our five senses help us explore, learn, and stay aware of the world around us.
</div>', N'<p>Kita meneroka dunia menggunakan <strong>lima deria yang hebat</strong>!</p>

<p>Setiap deria mempunyai bahagian tubuh yang khas untuk membantu kita memahami keadaan di sekeliling:</p>

<ul>
  <li><strong>Mata</strong> membantu kita melihat warna, saiz, dan bentuk.</li>
  <li><strong>Telinga</strong> membantu kita mendengar bunyi, seperti muzik kuat atau bisikan perlahan.</li>
  <li><strong>Hidung</strong> membantu kita menghidu bau, seperti bunga wangi atau sampah busuk.</li>
  <li><strong>Lidah</strong> membantu kita merasa makanan dan minuman.</li>
  <li><strong>Kulit</strong> membantu kita merasa benda yang kasar, licin, keras, atau lembut.</li>
</ul>

<div class="lesson-tip">
  Lima deria membantu kita meneroka, belajar, dan peka terhadap dunia di sekeliling kita.
</div>', N'humansense.png', 1),
(N'LS002', N'ST112', N'Classify Taste', N'Mengelaskan Rasa', N'<p>Our tongue is like a <strong>taste detective</strong>!</p>

<p>We can identify and group foods by four main flavours:</p>

<ul>
  <li><strong>Sweet</strong> — like a lollipop or honey.</li>
  <li><strong>Sour</strong> — like a lemon or lime.</li>
  <li><strong>Salty</strong> — like salt or salted fish.</li>
  <li><strong>Bitter</strong> — like coffee or bitter gourd.</li>
</ul>

<p>Some things may also be <strong>tasteless</strong>, such as plain water.</p>

<div class="lesson-tip">
  Taste helps us describe and compare different types of food.
</div>', N'<p>Lidah kita seperti <strong>detektif rasa</strong>!</p>

<p>Kita boleh mengenal pasti dan mengelaskan makanan mengikut empat rasa utama:</p>

<ul>
  <li><strong>Manis</strong> — seperti lolipop atau madu.</li>
  <li><strong>Masam</strong> — seperti lemon atau limau nipis.</li>
  <li><strong>Masin</strong> — seperti garam atau ikan masin.</li>
  <li><strong>Pahit</strong> — seperti kopi atau peria.</li>
</ul>

<p>Ada juga benda yang mungkin <strong>tawar</strong>, seperti air kosong.</p>

<div class="lesson-tip">
  Deria rasa membantu kita menerangkan dan membandingkan pelbagai jenis makanan.
</div>', N'taste.mp4', 1),
(N'LS003', N'ST113', N'The Use of Human Sense', N'Kegunaan Deria Manusia', N'<p>Our senses help us <strong>stay safe</strong> and <strong>learn about our surroundings</strong>.</p>

<p>When one sense does not work well, we can use special aids to help us:</p>

<ul>
  <li><strong>Glasses</strong> help people see more clearly.</li>
  <li><strong>Hearing aids</strong> help people hear sounds better.</li>
</ul>

<p>Even when it is dark and we cannot see, we can still use our <strong>sense of touch</strong> to find our way or identify objects.</p>

<div class="lesson-tip">
  Each sense is important because it helps us understand and respond to the world around us.
</div>', N'<p>Deria kita membantu kita <strong>menjaga keselamatan</strong> dan <strong>belajar tentang persekitaran</strong>.</p>

<p>Jika satu deria tidak berfungsi dengan baik, kita boleh menggunakan alat bantuan khas:</p>

<ul>
  <li><strong>Cermin mata</strong> membantu seseorang melihat dengan lebih jelas.</li>
  <li><strong>Alat bantu pendengaran</strong> membantu seseorang mendengar bunyi dengan lebih baik.</li>
</ul>

<p>Walaupun dalam keadaan gelap dan kita tidak dapat melihat, kita masih boleh menggunakan <strong>deria sentuhan</strong> untuk mencari jalan atau mengenal pasti objek.</p>

<div class="lesson-tip">
  Setiap deria penting kerana membantu kita memahami dan bertindak balas terhadap dunia di sekeliling kita.
</div>', N'useofhumansense.mp4', 1),
(N'LS004', N'ST121', N'Uses of Magnets', N'Kegunaan Magnet', N'<p>Magnets are like <strong>magic helpers</strong> in our daily lives!</p>

<p>We use magnets in many objects around us:</p>

<ul>
  <li>They help <strong>refrigerator doors</strong> stay shut tightly.</li>
  <li>They keep <strong>pencil cases</strong> closed.</li>
  <li>They allow teachers to wear <strong>name tags</strong> without using pins.</li>
  <li>Builders use <strong>magnetic screwdrivers</strong> to hold tiny screws so they do not fall.</li>
</ul>

<div class="lesson-tip">
  Magnets make many daily tasks easier, safer, and more convenient.
</div>', N'<p>Magnet adalah seperti <strong>pembantu ajaib</strong> dalam kehidupan harian kita!</p>

<p>Kita menggunakan magnet pada banyak objek di sekeliling kita:</p>

<ul>
  <li>Magnet membantu <strong>pintu peti sejuk</strong> ditutup dengan rapat.</li>
  <li>Magnet memastikan <strong>kotak pensel</strong> tertutup.</li>
  <li>Magnet membolehkan guru memakai <strong>tanda nama</strong> tanpa menggunakan pin.</li>
  <li>Pembina menggunakan <strong>pemutar skru bermagnet</strong> untuk memegang skru kecil supaya tidak jatuh.</li>
</ul>

<div class="lesson-tip">
  Magnet menjadikan banyak kerja harian lebih mudah, selamat, dan praktikal.
</div>', N'magnets.mp4', 1),
(N'LS005', N'ST122', N'Shapes of Magnets', N'Bentuk Magnet', N'<p>Magnets come in many interesting shapes depending on their use.</p>

<p>Some common shapes of magnets are:</p>

<ul>
  <li><strong>Bar magnet</strong></li>
  <li><strong>Cylinder magnet</strong></li>
  <li><strong>Horseshoe magnet</strong></li>
  <li><strong>U-shaped magnet</strong></li>
  <li><strong>Button magnet</strong></li>
  <li><strong>Ring magnet</strong></li>
</ul>

<p>Each shape is designed to be useful in different objects at home, in school, or in daily life.</p>

<div class="lesson-tip">
  Different magnet shapes are used for different purposes.
</div>', N'<p>Magnet mempunyai pelbagai bentuk yang menarik bergantung kepada kegunaannya.</p>

<p>Antara bentuk magnet yang biasa ialah:</p>

<ul>
  <li><strong>Magnet bar</strong></li>
  <li><strong>Magnet silinder</strong></li>
  <li><strong>Magnet ladam</strong></li>
  <li><strong>Magnet bentuk U</strong></li>
  <li><strong>Magnet butang</strong></li>
  <li><strong>Magnet cincin</strong></li>
</ul>

<p>Setiap bentuk direka supaya berguna pada objek yang berbeza di rumah, di sekolah, atau dalam kehidupan harian.</p>

<div class="lesson-tip">
  Bentuk magnet yang berbeza digunakan untuk tujuan yang berbeza.
</div>', N'magnetshape.png', 1),
(N'LS006', N'ST123', N'Attraction and Repulsion of Magnets', N'Tarikan dan Tolakan Magnet', N'<p>Every magnet has two poles:</p>

<ul>
  <li><strong>North Pole</strong></li>
  <li><strong>South Pole</strong></li>
</ul>

<p>When different poles are placed together, they <strong>attract</strong> and pull close to each other.</p>

<ul>
  <li><strong>North + South</strong> = attract</li>
</ul>

<p>When the same poles are placed together, they <strong>repel</strong> and push each other away.</p>

<ul>
  <li><strong>North + North</strong> = repel</li>
  <li><strong>South + South</strong> = repel</li>
</ul>

<p>Magnets only attract certain materials, especially objects made of metal, such as nails or pins.</p>

<div class="lesson-tip">
  Opposite poles attract, while the same poles repel.
</div>', N'<p>Setiap magnet mempunyai dua kutub:</p>

<ul>
  <li><strong>Kutub Utara</strong></li>
  <li><strong>Kutub Selatan</strong></li>
</ul>

<p>Apabila kutub yang berbeza dirapatkan, magnet akan <strong>menarik</strong> antara satu sama lain.</p>

<ul>
  <li><strong>Utara + Selatan</strong> = menarik</li>
</ul>

<p>Apabila kutub yang sama dirapatkan, magnet akan <strong>menolak</strong> antara satu sama lain.</p>

<ul>
  <li><strong>Utara + Utara</strong> = menolak</li>
  <li><strong>Selatan + Selatan</strong> = menolak</li>
</ul>

<p>Magnet hanya menarik bahan tertentu, terutamanya objek yang diperbuat daripada logam, seperti paku atau pin.</p>

<div class="lesson-tip">
  Kutub yang berbeza akan menarik, manakala kutub yang sama akan menolak.
</div>', N'attractmagnet.png', 1),
(N'LS007', N'ST131', N'Water Absorbent vs Non-Water Absorbent', N'Objek Menyerap Air, Objek Tidak Menyerap Air', N'<p>Some materials can <strong>absorb water</strong>, while others cannot.</p>

<p>Materials that absorb water are called <strong>water-absorbent materials</strong>. Examples include:</p>

<ul>
  <li>Sponge</li>
  <li>Tissue</li>
  <li>Mop</li>
</ul>

<p>Materials that do not absorb water are called <strong>non-water-absorbent materials</strong>. Water usually slides off these materials.</p>

<p>Examples include:</p>

<ul>
  <li>Plastic toys</li>
  <li>Glass</li>
  <li>Rubber boots</li>
  <li>Metal paperclips</li>
</ul>

<div class="lesson-tip">
  Absorbent materials soak up water, while non-absorbent materials do not.
</div>', N'<p>Sesetengah bahan boleh <strong>menyerap air</strong>, manakala bahan lain tidak boleh menyerap air.</p>

<p>Bahan yang menyerap air dipanggil <strong>bahan menyerap air</strong>. Contohnya termasuk:</p>

<ul>
  <li>Span</li>
  <li>Tisu</li>
  <li>Mop</li>
</ul>

<p>Bahan yang tidak menyerap air dipanggil <strong>bahan tidak menyerap air</strong>. Air biasanya akan mengalir atau meluncur di atas bahan ini.</p>

<p>Contohnya termasuk:</p>

<ul>
  <li>Mainan plastik</li>
  <li>Kaca</li>
  <li>Kasut getah</li>
  <li>Klip kertas logam</li>
</ul>

<div class="lesson-tip">
  Bahan menyerap air boleh menyerap air, manakala bahan tidak menyerap air tidak boleh menyerap air.
</div>', N'waterabsorption.mp4', 1),
(N'LS008', N'ST132', N'Importance of Water Absorbent and Non-Water Absorbent', N'Kepentingan Objek Menyerap dan Objek Tidak Menyerap Air', N'<p>Both absorbent and non-absorbent materials are important in our daily lives.</p>

<p>We use <strong>absorbent materials</strong> when we need to soak up water or liquid. For example:</p>

<ul>
  <li>We use <strong>towels</strong> to dry our bodies after a bath.</li>
  <li>We use <strong>tissues</strong> to wipe up spilled juice.</li>
</ul>

<p>We use <strong>non-absorbent materials</strong> when we want to keep water away. For example:</p>

<ul>
  <li>We use <strong>umbrellas</strong> and <strong>raincoats</strong> to keep ourselves dry when it rains.</li>
  <li>We use <strong>glass windows</strong> to stop rain from entering our cars.</li>
</ul>

<div class="lesson-tip">
  Different materials are useful because they have different properties.
</div>', N'<p>Kedua-dua bahan menyerap air dan bahan tidak menyerap air penting dalam kehidupan harian kita.</p>

<p>Kita menggunakan <strong>bahan menyerap air</strong> apabila kita perlu menyerap air atau cecair. Contohnya:</p>

<ul>
  <li>Kita menggunakan <strong>tuala</strong> untuk mengeringkan badan selepas mandi.</li>
  <li>Kita menggunakan <strong>tisu</strong> untuk mengelap jus yang tumpah.</li>
</ul>

<p>Kita menggunakan <strong>bahan tidak menyerap air</strong> apabila kita mahu menghalang air. Contohnya:</p>

<ul>
  <li>Kita menggunakan <strong>payung</strong> dan <strong>baju hujan</strong> untuk kekal kering semasa hujan.</li>
  <li>Kita menggunakan <strong>tingkap kaca</strong> untuk menghalang hujan daripada masuk ke dalam kereta.</li>
</ul>

<div class="lesson-tip">
  Bahan yang berbeza berguna kerana mempunyai sifat yang berbeza.
</div>', N'absorption.jpeg', 1),
(N'LS009', N'ST141', N'Landforms', N'Bentuk Muka Bumi', N'<p>Our Earth is full of beautiful natural features.</p>

<p>Some natural features on Earth include:</p>

<ul>
  <li><strong>Mountains</strong> and hills</li>
  <li><strong>Flat plains</strong></li>
  <li><strong>Winding rivers</strong></li>
  <li><strong>Ponds</strong> and lakes</li>
  <li><strong>Beaches</strong> where the land meets the sea</li>
  <li><strong>Forests</strong> full of trees</li>
</ul>

<p>These features make the surface of the Earth unique and beautiful.</p>

<div class="lesson-tip">
  The Earth has many different landforms and natural features.
</div>', N'<p>Bumi kita penuh dengan ciri semula jadi yang indah.</p>

<p>Antara ciri semula jadi di Bumi ialah:</p>

<ul>
  <li><strong>Gunung</strong> dan bukit</li>
  <li><strong>Dataran</strong> yang rata</li>
  <li><strong>Sungai</strong> yang berliku</li>
  <li><strong>Kolam</strong> dan tasik</li>
  <li><strong>Pantai</strong> di mana daratan bertemu laut</li>
  <li><strong>Hutan</strong> yang penuh dengan pokok-pokok</li>
</ul>

<p>Ciri-ciri ini menjadikan permukaan Bumi unik dan indah.</p>

<div class="lesson-tip">
  Bumi mempunyai pelbagai bentuk muka bumi dan ciri semula jadi.
</div>', N'land.mp4', 1),
(N'LS010', N'ST142', N'Soil', N'Tanah', N'<p>Did you know that there are different types of soil?</p>

<p>Some common types of soil are:</p>

<ul>
  <li><strong>Garden soil</strong> — dark in colour and full of nutrients for plants.</li>
  <li><strong>Sand</strong> — commonly found at the beach and has large grains.</li>
  <li><strong>Clay</strong> — sticky and can be used to make pots.</li>
</ul>

<p>Soil is very important because it contains:</p>

<ul>
  <li>Minerals</li>
  <li>Water</li>
  <li>Air</li>
  <li>Decayed plants and organic matter</li>
</ul>

<p>These help plants grow and provide food for humans and animals.</p>

<div class="lesson-tip">
  Soil is important because it supports plant growth.
</div>', N'<p>Tahukah anda bahawa terdapat pelbagai jenis tanah?</p>

<p>Antara jenis tanah yang biasa ialah:</p>

<ul>
  <li><strong>Tanah kebun</strong> — berwarna gelap dan penuh dengan nutrien untuk tumbuhan.</li>
  <li><strong>Pasir</strong> — biasanya terdapat di pantai dan mempunyai butiran yang besar.</li>
  <li><strong>Tanah liat</strong> — bersifat melekit dan boleh digunakan untuk membuat pasu.</li>
</ul>

<p>Tanah sangat penting kerana mengandungi:</p>

<ul>
  <li>Mineral</li>
  <li>Air</li>
  <li>Udara</li>
  <li>Tumbuhan reput dan bahan organik</li>
</ul>

<p>Bahan-bahan ini membantu tumbuhan membesar dan membekalkan makanan kepada manusia serta haiwan.</p>

<div class="lesson-tip">
  Tanah penting kerana membantu pertumbuhan tumbuhan.
</div>', N'soil.png', 1),
(N'LS011', N'ST151', N'Basic Shapes', N'Bentuk Asas', N'<p>Everything we build starts with <strong>simple basic shapes</strong>!</p>

<p>Can you spot these shapes around you?</p>

<ul>
  <li><strong>Circle</strong></li>
  <li><strong>Square</strong></li>
  <li><strong>Triangle</strong></li>
  <li><strong>Rectangle</strong></li>
</ul>

<p>For example, your clock might be a <strong>circle</strong>, and your book might be a <strong>rectangle</strong>.</p>

<p>Learning basic shapes is the first step to becoming a great builder.</p>

<div class="lesson-tip">
  Basic shapes can be found in many objects around us.
</div>', N'<p>Semua yang kita bina bermula dengan <strong>bentuk asas yang ringkas</strong>!</p>

<p>Bolehkah anda mengenal pasti bentuk-bentuk ini di sekeliling anda?</p>

<ul>
  <li><strong>Bulatan</strong></li>
  <li><strong>Segi empat sama</strong></li>
  <li><strong>Segi tiga</strong></li>
  <li><strong>Segi empat tepat</strong></li>
</ul>

<p>Contohnya, jam anda mungkin berbentuk <strong>bulatan</strong>, dan buku anda mungkin berbentuk <strong>segi empat tepat</strong>.</p>

<p>Mempelajari bentuk asas ialah langkah pertama untuk menjadi pembina yang hebat.</p>

<div class="lesson-tip">
  Bentuk asas boleh ditemui pada banyak objek di sekeliling kita.
</div>', N'shapes.mp4', 1),
(N'LS012', N'ST152', N'Basic Shape Blocks', N'Bongkah Bentuk Asas', N'<p>When basic shapes become 3D objects, we call them <strong>blocks</strong>.</p>

<p>Common blocks include:</p>

<ul>
  <li><strong>Cube</strong></li>
  <li><strong>Cuboid</strong></li>
  <li><strong>Pyramid</strong></li>
  <li><strong>Prism</strong></li>
  <li><strong>Cone</strong></li>
  <li><strong>Cylinder</strong></li>
  <li><strong>Sphere</strong></li>
</ul>

<p>Think of objects around you:</p>

<ul>
  <li>A ball is shaped like a <strong>sphere</strong>.</li>
  <li>A soda can is shaped like a <strong>cylinder</strong>.</li>
  <li>An ice cube is shaped like a <strong>cube</strong>.</li>
</ul>

<div class="lesson-tip">
  Blocks are 3D shapes that can be seen and touched.
</div>', N'<p>Apabila bentuk asas menjadi objek 3D, kita memanggilnya <strong>bongkah</strong>.</p>

<p>Antara bongkah yang biasa ialah:</p>

<ul>
  <li><strong>Kubus</strong></li>
  <li><strong>Kuboid</strong></li>
  <li><strong>Piramid</strong></li>
  <li><strong>Prisma</strong></li>
  <li><strong>Kon</strong></li>
  <li><strong>Silinder</strong></li>
  <li><strong>Sfera</strong></li>
</ul>

<p>Fikirkan objek di sekeliling anda:</p>

<ul>
  <li>Bola berbentuk seperti <strong>sfera</strong>.</li>
  <li>Tin minuman berbentuk seperti <strong>silinder</strong>.</li>
  <li>Ketulan ais berbentuk seperti <strong>kubus</strong>.</li>
</ul>

<div class="lesson-tip">
  Bongkah ialah bentuk 3D yang boleh dilihat dan disentuh.
</div>', N'basicshapes.png', 1),
(N'LS013', N'ST153', N'Importance of Block Shapes', N'Kepentingan Bentuk Bongkah', N'<p>Why do we use blocks in buildings and structures?</p>

<p>We use blocks because they help make structures <strong>strong</strong> and <strong>stable</strong>.</p>

<p>Different blocks are useful for different purposes:</p>

<ul>
  <li>A flat <strong>cuboid</strong> block is useful for making walls.</li>
  <li>A <strong>cylinder</strong> block is useful for making pillars.</li>
</ul>

<p>Using the right blocks helps ensure that buildings and structures do not fall over easily.</p>

<div class="lesson-tip">
  The right shape can make a structure stronger and more stable.
</div>', N'<p>Mengapakah kita menggunakan bongkah dalam bangunan dan binaan?</p>

<p>Kita menggunakan bongkah kerana bongkah membantu menjadikan binaan <strong>kuat</strong> dan <strong>stabil</strong>.</p>

<p>Bongkah yang berbeza berguna untuk tujuan yang berbeza:</p>

<ul>
  <li>Bongkah <strong>kuboid</strong> yang rata sesuai digunakan untuk membina dinding.</li>
  <li>Bongkah <strong>silinder</strong> sesuai digunakan untuk membina tiang.</li>
</ul>

<p>Menggunakan bongkah yang sesuai membantu memastikan bangunan dan binaan tidak mudah tumbang.</p>

<div class="lesson-tip">
  Bentuk yang sesuai boleh menjadikan sesuatu binaan lebih kuat dan stabil.
</div>', N'shapes.png', 1),
(N'LS014', N'ST211', N'Types of Human Teeth', N'Jenis Gigi Manusia', N'<p>Did you know that humans have <strong>two sets of teeth</strong>?</p>

<p>We start with <strong>milk teeth</strong> and later grow <strong>permanent teeth</strong>.</p>

<ul>
  <li><strong>Milk teeth</strong> — 20 teeth.</li>
  <li><strong>Permanent teeth</strong> — 32 teeth.</li>
</ul>

<p>There are three main types of teeth:</p>

<ul>
  <li><strong>Incisors</strong> — the front teeth used for cutting food.</li>
  <li><strong>Canines</strong> — the sharp side teeth used for tearing food.</li>
  <li><strong>Molars</strong> — the big back teeth used for grinding food.</li>
</ul>

<div class="lesson-tip">
  Permanent teeth can last a lifetime, so we must take good care of them.
</div>', N'<p>Tahukah anda bahawa manusia mempunyai <strong>dua set gigi</strong>?</p>

<p>Kita bermula dengan <strong>gigi susu</strong> dan kemudian tumbuh <strong>gigi kekal</strong>.</p>

<ul>
  <li><strong>Gigi susu</strong> — 20 batang gigi.</li>
  <li><strong>Gigi kekal</strong> — 32 batang gigi.</li>
</ul>

<p>Terdapat tiga jenis gigi utama:</p>

<ul>
  <li><strong>Gigi kacip</strong> — gigi hadapan yang digunakan untuk memotong makanan.</li>
  <li><strong>Gigi taring</strong> — gigi tajam di bahagian sisi yang digunakan untuk mengoyakkan makanan.</li>
  <li><strong>Gigi geraham</strong> — gigi besar di bahagian belakang yang digunakan untuk mengisar makanan.</li>
</ul>

<div class="lesson-tip">
  Gigi kekal boleh bertahan seumur hidup, jadi kita mesti menjaganya dengan baik.
</div>', N'teeth.mp4', 1),
(N'LS015', N'ST211', N'Functions of Teeth', N'Fungsi Gigi', N'<p>Every tooth has a special job in the <strong>Food Crushing Factory</strong>!</p>

<p>Different types of teeth help us eat food in different ways:</p>

<ul>
  <li><strong>Incisors</strong> cut food like scissors.</li>
  <li><strong>Canines</strong> tear food, such as meat.</li>
  <li><strong>Molars</strong> grind food into a soft paste.</li>
</ul>

<p>When all teeth work together, food becomes smaller and easier to swallow.</p>

<div class="lesson-activity">
  Sing the <strong>"Jom Kenali Gigi"</strong> song to remember the jobs of each type of tooth!
</div>', N'<p>Setiap gigi mempunyai tugas khas dalam <strong>Kilang Penghancur Makanan</strong>!</p>

<p>Jenis gigi yang berbeza membantu kita makan makanan dengan cara yang berbeza:</p>

<ul>
  <li><strong>Gigi kacip</strong> memotong makanan seperti gunting.</li>
  <li><strong>Gigi taring</strong> mengoyakkan makanan, seperti daging.</li>
  <li><strong>Gigi geraham</strong> mengisar makanan menjadi lebih halus dan lembut.</li>
</ul>

<p>Apabila semua gigi bekerjasama, makanan menjadi lebih kecil dan lebih mudah ditelan.</p>

<div class="lesson-activity">
  Nyanyikan lagu <strong>"Jom Kenali Gigi"</strong> untuk mengingati tugas setiap jenis gigi!
</div>', N'teeth.jpeg', 2),
(N'LS016', N'ST211', N'Caring for Teeth', N'Penjagaan Gigi', N'<p>Kina’s tooth is hurting! Why?</p>

<p>It may be because she did not clean her teeth properly.</p>

<p>We can keep our smile bright and healthy by practising good dental care:</p>

<ul>
  <li>Brush your teeth <strong>twice a day</strong> using toothpaste.</li>
  <li>Use <strong>dental floss</strong> to remove food stuck between teeth.</li>
  <li>Rinse your mouth after meals.</li>
  <li>Visit the dentist every <strong>six months</strong>.</li>
</ul>

<div class="lesson-tip">
  Sugar and bacteria can create acid that damages the hard enamel layer of your teeth.
</div>', N'<p>Gigi Kina sedang sakit! Mengapa?</p>

<p>Ini mungkin kerana dia tidak membersihkan giginya dengan betul.</p>

<p>Kita boleh mengekalkan senyuman yang cerah dan sihat dengan mengamalkan penjagaan gigi yang baik:</p>

<ul>
  <li>Gosok gigi <strong>dua kali sehari</strong> menggunakan ubat gigi.</li>
  <li>Gunakan <strong>flos gigi</strong> untuk membuang makanan yang terselit di celah gigi.</li>
  <li>Berkumur selepas makan.</li>
  <li>Berjumpa doktor gigi setiap <strong>enam bulan</strong>.</li>
</ul>

<div class="lesson-tip">
  Gula dan bakteria boleh menghasilkan asid yang merosakkan lapisan enamel gigi yang keras.
</div>', N'careteeth.png', 3),
(N'LS017', N'ST212', N'Food Classes', N'Kelas Makanan', N'<p>Food is the <strong>fuel</strong> for our bodies!</p>

<p>There are seven important classes of food:</p>

<ul>
  <li><strong>Carbohydrates</strong> give us energy. Examples include rice and bread.</li>
  <li><strong>Proteins</strong> help our bodies grow. Examples include fish and chicken.</li>
  <li><strong>Fats</strong> help keep our bodies warm.</li>
  <li><strong>Vitamins</strong> help keep our bodies healthy.</li>
  <li><strong>Minerals</strong> help our bodies function properly.</li>
  <li><strong>Fibre</strong> helps prevent constipation.</li>
  <li><strong>Water</strong> helps regulate body temperature.</li>
</ul>

<div class="lesson-tip">
  Eating different types of food helps our body get the nutrients it needs.
</div>', N'<p>Makanan ialah <strong>bahan api</strong> untuk badan kita!</p>

<p>Terdapat tujuh kelas makanan yang penting:</p>

<ul>
  <li><strong>Karbohidrat</strong> membekalkan tenaga. Contohnya nasi dan roti.</li>
  <li><strong>Protein</strong> membantu tumbesaran badan. Contohnya ikan dan ayam.</li>
  <li><strong>Lemak</strong> membantu memanaskan badan.</li>
  <li><strong>Vitamin</strong> membantu mengekalkan kesihatan badan.</li>
  <li><strong>Mineral</strong> membantu badan berfungsi dengan baik.</li>
  <li><strong>Pelawas</strong> membantu mencegah sembelit.</li>
  <li><strong>Air</strong> membantu mengawal suhu badan.</li>
</ul>

<div class="lesson-tip">
  Mengambil pelbagai jenis makanan membantu badan mendapatkan nutrien yang diperlukan.
</div>', N'foodclass.mp4', 1),
(N'LS018', N'ST212', N'Importance of a Balanced Diet', N'Kepentingan Pemakanan Seimbang', N'<p>Makanan ialah <strong>bahan api</strong> untuk badan kita!</p>

<p>Terdapat tujuh kelas makanan yang penting:</p>

<ul>
  <li><strong>Karbohidrat</strong> membekalkan tenaga. Contohnya nasi dan roti.</li>
  <li><strong>Protein</strong> membantu tumbesaran badan. Contohnya ikan dan ayam.</li>
  <li><strong>Lemak</strong> membantu memanaskan badan.</li>
  <li><strong>Vitamin</strong> membantu mengekalkan kesihatan badan.</li>
  <li><strong>Mineral</strong> membantu badan berfungsi dengan baik.</li>
  <li><strong>Pelawas</strong> membantu mencegah sembelit.</li>
  <li><strong>Air</strong> membantu mengawal suhu badan.</li>
</ul>

<div class="lesson-tip">
  Mengambil pelbagai jenis makanan membantu badan mendapatkan nutrien yang diperlukan.
</div>', N'<p>Bagaimanakah kita kekal sihat?</p>

<p>Kita kekal sihat dengan makan <strong>jenis makanan yang betul</strong> dalam <strong>kuantiti yang sesuai</strong>.</p>

<p>Piramid Makanan Malaysia membantu kita memilih makanan dengan bijak:</p>

<ul>
  <li><strong>Aras 1</strong> — makan karbohidrat secukupnya, seperti nasi, mi, dan roti.</li>
  <li><strong>Aras 2</strong> — makan lebih banyak buah-buahan dan sayur-sayuran.</li>
  <li><strong>Aras 3</strong> — makan daging, ikan, telur, susu, dan produk tenusu secara sederhana.</li>
  <li><strong>Aras 4</strong> — makan minyak, gula, dan garam dalam kuantiti yang sangat sedikit.</li>
</ul>

<div class="lesson-tip">
  Pemakanan seimbang membekalkan tenaga dan nutrien yang mencukupi untuk badan kekal sihat.
</div>', N'diet.png', 2),
(N'LS019', N'ST212', N'Healthy Eating Habits', N'Amalan Pemakanan Sihat', N'<p>Your eating habits today can affect your health tomorrow!</p>

<p>Good eating habits help us grow well, stay active, and avoid health problems.</p>

<p>Unhealthy eating habits can cause problems such as:</p>

<ul>
  <li>Eating too much oil, sugar, and salt can cause <strong>obesity</strong>.</li>
  <li>Not eating enough fibre can make it difficult to pass motion.</li>
  <li>Eating too little healthy food can make the body weak.</li>
</ul>

<p>We should choose healthy food and eat in suitable amounts every day.</p>

<div class="lesson-activity">
  Create a <strong>health brochure</strong> for a patient to help them practise better eating habits.
</div>', N'<p>Amalan pemakanan anda hari ini boleh mempengaruhi kesihatan anda pada masa hadapan!</p>

<p>Amalan pemakanan yang baik membantu kita membesar dengan sihat, kekal aktif, dan mengelakkan masalah kesihatan.</p>

<p>Amalan pemakanan yang tidak sihat boleh menyebabkan masalah seperti:</p>

<ul>
  <li>Makan terlalu banyak minyak, gula, dan garam boleh menyebabkan <strong>obesiti</strong>.</li>
  <li>Tidak makan pelawas yang mencukupi boleh menyebabkan kesukaran membuang air besar.</li>
  <li>Makan terlalu sedikit makanan berkhasiat boleh menyebabkan badan menjadi lemah.</li>
</ul>

<p>Kita perlu memilih makanan yang sihat dan makan dalam kuantiti yang sesuai setiap hari.</p>

<div class="lesson-activity">
  Hasilkan <strong>brosur kesihatan</strong> untuk membantu pesakit mengamalkan pemakanan yang lebih baik.
</div>', N'healthyeating.png', 3),
(N'LS020', N'ST213', N'Digestive Organs', N'Organ Pencernaan', N'<p>Let’s follow a grape on its journey through your body!</p>

<p>Food travels through several organs in the digestive system.</p>

<p>The main digestive organs are:</p>

<ol>
  <li><strong>Mouth</strong></li>
  <li><strong>Esophagus</strong></li>
  <li><strong>Stomach</strong></li>
  <li><strong>Intestines</strong></li>
  <li><strong>Anus</strong></li>
</ol>

<p>Each organ has an important role in helping the body digest food.</p>

<div class="lesson-tip">
  The digestive system helps turn food into nutrients that the body can use.
</div>', N'<p>Mari kita ikuti perjalanan sebiji anggur di dalam badan anda!</p>

<p>Makanan bergerak melalui beberapa organ dalam sistem pencernaan.</p>

<p>Organ pencernaan utama ialah:</p>

<ol>
  <li><strong>Mulut</strong></li>
  <li><strong>Esofagus</strong></li>
  <li><strong>Perut</strong></li>
  <li><strong>Usus</strong></li>
  <li><strong>Dubur</strong></li>
</ol>

<p>Setiap organ mempunyai peranan penting dalam membantu badan mencerna makanan.</p>

<div class="lesson-tip">
  Sistem pencernaan membantu menukarkan makanan kepada nutrien yang boleh digunakan oleh badan.
</div>', N'organ.mp4', 1),
(N'LS021', N'ST213', N'The Human Digestive System', N'Sistem Pencernaan Manusia', N'<p><strong>Digestion</strong> is the process of breaking food into tiny pieces.</p>

<p>The digestion process starts in the mouth.</p>

<ul>
  <li><strong>Teeth</strong> crush and break food into smaller pieces.</li>
  <li><strong>Tongue</strong> helps move food around in the mouth.</li>
  <li><strong>Saliva</strong> helps soften the food.</li>
</ul>

<p>After that, the food slides down the <strong>esophagus</strong> and moves into the <strong>stomach</strong>.</p>

<p>In the stomach, food is mixed and turned into a liquid mixture.</p>

<div class="lesson-tip">
  Digestion makes food small enough for the body to absorb and use.
</div>', N'<p><strong>Pencernaan</strong> ialah proses menghancurkan makanan kepada bahagian yang kecil.</p>

<p>Proses pencernaan bermula di dalam mulut.</p>

<ul>
  <li><strong>Gigi</strong> menghancurkan dan memecahkan makanan kepada cebisan kecil.</li>
  <li><strong>Lidah</strong> membantu menggerakkan makanan di dalam mulut.</li>
  <li><strong>Air liur</strong> membantu melembutkan makanan.</li>
</ul>

<p>Selepas itu, makanan bergerak menuruni <strong>esofagus</strong> dan masuk ke dalam <strong>perut</strong>.</p>

<p>Di dalam perut, makanan digaul dan berubah menjadi campuran cecair.</p>

<div class="lesson-tip">
  Pencernaan menjadikan makanan cukup kecil untuk diserap dan digunakan oleh badan.
</div>', N'digestivesystem.png', 2),
(N'LS022', N'ST213', N'The Digestion Process', N'Proses Pencernaan', N'<p>What happens to the food that our body does not need?</p>

<p>During digestion, useful nutrients from food are absorbed in the <strong>intestines</strong>.</p>

<p>The leftover waste that the body does not need becomes <strong>feces</strong>.</p>

<p>The feces then leaves the body through the <strong>anus</strong>.</p>

<div class="lesson-warning">
  Do not talk, run, or play while eating. These actions can cause choking or vomiting.
</div>', N'<p>Apakah yang berlaku kepada makanan yang tidak diperlukan oleh badan kita?</p>

<p>Semasa pencernaan, nutrien yang berguna daripada makanan diserap di dalam <strong>usus</strong>.</p>

<p>Sisa makanan yang tidak diperlukan oleh badan akan menjadi <strong>tinja</strong>.</p>

<p>Tinja kemudian keluar daripada badan melalui <strong>dubur</strong>.</p>

<div class="lesson-warning">
  Jangan bercakap, berlari, atau bermain semasa makan. Perbuatan ini boleh menyebabkan tercekik atau muntah.
</div>', N'digestiveprocess.png', 3),
(N'LS023', N'ST221', N'Objects that Float and Sink', N'Objek Timbul dan Tenggelam', N'<p>Why does a heavy log float, but a tiny pin sinks?</p>

<p>Objects can either <strong>float</strong> or <strong>sink</strong> in water.</p>

<ul>
  <li>An object <strong>floats</strong> when it stays on the surface of water.</li>
  <li>An object <strong>sinks</strong> when it goes down to the bottom of water.</li>
</ul>

<p>Whether an object floats or sinks depends on its density compared to water.</p>

<div class="lesson-tip">
  An object floats if it is less dense than water and sinks if it is more dense than water.
</div>', N'<p>Mengapakah kayu balak yang berat boleh terapung, tetapi pin yang kecil boleh tenggelam?</p>

<p>Objek boleh sama ada <strong>timbul</strong> atau <strong>tenggelam</strong> di dalam air.</p>

<ul>
  <li>Objek <strong>timbul</strong> apabila berada di permukaan air.</li>
  <li>Objek <strong>tenggelam</strong> apabila turun ke dasar air.</li>
</ul>

<p>Sama ada sesuatu objek timbul atau tenggelam bergantung kepada ketumpatannya berbanding air.</p>

<div class="lesson-tip">
  Objek akan timbul jika kurang tumpat daripada air dan tenggelam jika lebih tumpat daripada air.
</div>', N'float.mp4', 1),
(N'LS024', N'ST222', N'Understanding Density', N'Memahami Ketumpatan', N'<p><strong>Density</strong> tells us how tightly packed the material in an object is.</p>

<p>Objects with different densities behave differently in water.</p>

<ul>
  <li>If an object is <strong>less dense than water</strong>, it will float.</li>
  <li>If an object is <strong>more dense than water</strong>, it will sink.</li>
</ul>

<p>For example, some big objects can float because they are less dense than water, while some small objects can sink because they are more dense than water.</p>

<div class="lesson-tip">
  Density helps explain why some objects float and others sink.
</div>', N'<p><strong>Ketumpatan</strong> menunjukkan betapa rapatnya bahan dalam sesuatu objek.</p>

<p>Objek yang mempunyai ketumpatan berbeza akan bertindak secara berbeza di dalam air.</p>

<ul>
  <li>Jika objek <strong>kurang tumpat daripada air</strong>, objek itu akan timbul.</li>
  <li>Jika objek <strong>lebih tumpat daripada air</strong>, objek itu akan tenggelam.</li>
</ul>

<p>Contohnya, sesetengah objek besar boleh timbul kerana kurang tumpat daripada air, manakala sesetengah objek kecil boleh tenggelam kerana lebih tumpat daripada air.</p>

<div class="lesson-tip">
  Ketumpatan membantu menerangkan sebab sesetengah objek timbul dan sesetengah objek tenggelam.
</div>', N'density.png', 1),
(N'LS025', N'ST222', N'Increasing Water Density', N'Meningkatkan Ketumpatan Air', N'<p>Can we make a sinking egg float?</p>

<p>Yes, we can!</p>

<p>When we add salt or sugar to water, the water becomes <strong>denser</strong>.</p>

<p>As the water becomes denser, it can push some sinking objects upward until they float.</p>

<ol>
  <li>Place an egg in plain water. It may sink.</li>
  <li>Add salt or sugar into the water.</li>
  <li>Stir until it dissolves.</li>
  <li>Observe what happens to the egg.</li>
</ol>

<div class="lesson-tip">
  Adding salt or sugar increases the density of water.
</div>', N'<p>Bolehkah kita membuat telur yang tenggelam menjadi timbul?</p>

<p>Ya, boleh!</p>

<p>Apabila kita menambah garam atau gula ke dalam air, air menjadi <strong>lebih tumpat</strong>.</p>

<p>Apabila air menjadi lebih tumpat, air boleh menolak sesetengah objek yang tenggelam ke atas sehingga objek itu timbul.</p>

<ol>
  <li>Masukkan telur ke dalam air biasa. Telur mungkin tenggelam.</li>
  <li>Tambah garam atau gula ke dalam air.</li>
  <li>Kacau sehingga larut.</li>
  <li>Perhatikan apa yang berlaku kepada telur.</li>
</ol>

<div class="lesson-tip">
  Menambah garam atau gula dapat meningkatkan ketumpatan air.
</div>', N'waterdensity.png', 2),
(N'LS026', N'ST223', N'Uses of Density in Everyday Life', N'Aplikasi Ketumpatan dalam Kehidupan Harian', N'<p>Science helps keep us safe in the ocean!</p>

<p>Density is used in many objects around us:</p>

<ul>
  <li><strong>Life jackets</strong> are filled with air, making them less dense than water so they can float.</li>
  <li><strong>Anchors</strong> are made of heavy iron, making them dense enough to sink to the bottom.</li>
  <li><strong>Fish cages</strong> use floats to stay on the surface of water.</li>
</ul>

<p>By understanding density, we can design objects that float or sink when needed.</p>

<div class="lesson-tip">
  Density is useful in transportation, safety equipment, and daily life.
</div>', N'<p>Sains membantu menjaga keselamatan kita di laut!</p>

<p>Ketumpatan digunakan pada banyak objek di sekeliling kita:</p>

<ul>
  <li><strong>Jaket keselamatan</strong> diisi dengan udara, menjadikannya kurang tumpat daripada air supaya boleh terapung.</li>
  <li><strong>Sauh</strong> diperbuat daripada besi yang berat, menjadikannya cukup tumpat untuk tenggelam ke dasar air.</li>
  <li><strong>Sangkar ikan</strong> menggunakan pelampung supaya kekal di permukaan air.</li>
</ul>

<p>Dengan memahami ketumpatan, kita boleh mereka bentuk objek yang boleh timbul atau tenggelam mengikut keperluan.</p>

<div class="lesson-tip">
  Ketumpatan berguna dalam pengangkutan, peralatan keselamatan, dan kehidupan harian.
</div>', N'densitylife.png', 1),
(N'LS027', N'ST231', N'Acid, Alkali and Neutral Substances', N'Bahan Asid, Alkali dan Neutral', N'<p>Why do some things taste sour, while others feel slippery?</p>

<p>Substances can be grouped based on their properties.</p>

<ul>
  <li><strong>Acidic substances</strong> usually taste sour. An example is lemon.</li>
  <li><strong>Alkaline substances</strong> usually taste bitter and feel slippery. An example is soap.</li>
  <li><strong>Neutral substances</strong> may taste sweet, salty, or tasteless.</li>
</ul>

<div class="lesson-warning">
  Do not taste unknown substances. Some substances can be dangerous.
</div>', N'<p>Mengapakah sesetengah bahan terasa masam, manakala bahan lain terasa licin?</p>

<p>Bahan boleh dikelaskan berdasarkan sifatnya.</p>

<ul>
  <li><strong>Bahan berasid</strong> biasanya terasa masam. Contohnya lemon.</li>
  <li><strong>Bahan beralkali</strong> biasanya terasa pahit dan licin. Contohnya sabun.</li>
  <li><strong>Bahan neutral</strong> mungkin terasa manis, masin, atau tawar.</li>
</ul>

<div class="lesson-warning">
  Jangan merasa bahan yang tidak dikenali. Sesetengah bahan boleh berbahaya.
</div>', N'acidalkalineutral.mp4', 1),
(N'LS028', N'ST232', N'Identifying Acidic, Alkaline and Neutral Substances', N'Mengenal Pasti Bahan Asid, Alkali dan Neutral', N'<p>Do not taste everything to identify whether it is acidic, alkaline, or neutral.</p>

<p>Instead, we can use <strong>litmus paper</strong> to test substances safely.</p>

<ul>
  <li><strong>Blue litmus paper turns red</strong> — the substance is acidic.</li>
  <li><strong>Red litmus paper turns blue</strong> — the substance is alkaline.</li>
  <li><strong>No colour change</strong> — the substance is neutral.</li>
</ul>

<div class="lesson-tip">
  Litmus paper helps us identify acidic, alkaline, and neutral substances safely.
</div>', N'<p>Jangan merasa semua bahan untuk mengenal pasti sama ada bahan itu berasid, beralkali, atau neutral.</p>

<p>Sebaliknya, kita boleh menggunakan <strong>kertas litmus</strong> untuk menguji bahan dengan selamat.</p>

<ul>
  <li><strong>Kertas litmus biru bertukar merah</strong> — bahan itu berasid.</li>
  <li><strong>Kertas litmus merah bertukar biru</strong> — bahan itu beralkali.</li>
  <li><strong>Tiada perubahan warna</strong> — bahan itu neutral.</li>
</ul>

<div class="lesson-tip">
  Kertas litmus membantu kita mengenal pasti bahan berasid, beralkali, dan neutral dengan selamat.
</div>', N'acidalkalineutral.png', 1),
(N'LS029', N'ST232', N'Acidic, Alkaline and Neutral Substances Around Us', N'Bahan Asid, Alkali dan Neutral di Sekeliling Kita', N'<p>Chemistry is everywhere around us!</p>

<p>Acids and alkalis are useful in daily life:</p>

<ul>
  <li><strong>Medicine</strong> — vinegar can help treat wasp stings because wasp stings are alkaline.</li>
  <li><strong>Farming</strong> — lime can be added to soil to reduce soil acidity.</li>
  <li><strong>Hygiene</strong> — toothpaste is alkaline and helps neutralise acid in the mouth.</li>
</ul>

<p>By understanding acids and alkalis, we can use substances safely and correctly.</p>

<div class="lesson-tip">
  Many everyday products are acidic, alkaline, or neutral.
</div>', N'<p>Kimia ada di mana-mana di sekeliling kita!</p>

<p>Asid dan alkali berguna dalam kehidupan harian:</p>

<ul>
  <li><strong>Perubatan</strong> — cuka boleh membantu merawat sengatan tebuan kerana sengatan tebuan bersifat alkali.</li>
  <li><strong>Pertanian</strong> — kapur boleh ditambah ke dalam tanah untuk mengurangkan keasidan tanah.</li>
  <li><strong>Kebersihan</strong> — ubat gigi bersifat alkali dan membantu meneutralkan asid di dalam mulut.</li>
</ul>

<p>Dengan memahami asid dan alkali, kita boleh menggunakan bahan dengan selamat dan betul.</p>

<div class="lesson-tip">
  Banyak produk harian bersifat asid, alkali, atau neutral.
</div>', N'substances,png', 2),
(N'LS030', N'ST232', N'Alternatives to Litmus Paper', N'Pengganti Kertas Litmus', N'<p>No litmus paper?</p>

<p>You can use natural indicators from your kitchen or garden!</p>

<p>Some natural materials can be used to test whether a substance is acidic or alkaline:</p>

<ul>
  <li><strong>Turmeric extract</strong></li>
  <li><strong>Purple cabbage extract</strong></li>
  <li><strong>Hibiscus extract</strong></li>
</ul>

<p>These natural indicators can change colour when mixed with acidic or alkaline substances.</p>

<div class="lesson-tip">
  Natural indicators are useful alternatives when litmus paper is not available.
</div>', N'<p>Tiada kertas litmus?</p>

<p>Anda boleh menggunakan penunjuk semula jadi daripada dapur atau taman anda!</p>

<p>Sesetengah bahan semula jadi boleh digunakan untuk menguji sama ada sesuatu bahan bersifat asid atau alkali:</p>

<ul>
  <li><strong>Ekstrak kunyit</strong></li>
  <li><strong>Ekstrak kubis ungu</strong></li>
  <li><strong>Ekstrak bunga raya</strong></li>
</ul>

<p>Penunjuk semula jadi ini boleh berubah warna apabila dicampurkan dengan bahan berasid atau beralkali.</p>

<div class="lesson-tip">
  Penunjuk semula jadi berguna sebagai pengganti apabila kertas litmus tidak tersedia.
</div>', N'litmuspaper.png', 3),
(N'LS031', N'ST241', N'The Members of the Solar System', N'Ahli Sistem Suria', N'<p>We are part of a giant family in space called the <strong>Solar System</strong>!</p>

<p>The Solar System is made up of the Sun and many objects that move around it.</p>

<p>Members of the Solar System include:</p>

<ul>
  <li><strong>The Sun</strong> — the centre of the Solar System.</li>
  <li><strong>Eight planets</strong> — Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus, and Neptune.</li>
  <li><strong>Natural satellites</strong> — objects that move around planets, such as the Moon.</li>
  <li><strong>Asteroids</strong> — rocky objects that move around the Sun.</li>
  <li><strong>Meteoroids</strong> — small pieces of rock or metal in space.</li>
  <li><strong>Comets</strong> — icy objects that can form bright tails when near the Sun.</li>
</ul>

<div class="lesson-tip">
  The Solar System is like a space family, with the Sun as its centre.
</div>', N'<p>Kita merupakan sebahagian daripada keluarga besar di angkasa yang dipanggil <strong>Sistem Suria</strong>!</p>

<p>Sistem Suria terdiri daripada Matahari dan banyak objek yang bergerak mengelilinginya.</p>

<p>Ahli Sistem Suria termasuk:</p>

<ul>
  <li><strong>Matahari</strong> — pusat Sistem Suria.</li>
  <li><strong>Lapan planet</strong> — Utarid, Zuhrah, Bumi, Marikh, Musytari, Zuhal, Uranus, dan Neptun.</li>
  <li><strong>Satelit semula jadi</strong> — objek yang bergerak mengelilingi planet, seperti Bulan.</li>
  <li><strong>Asteroid</strong> — objek berbatu yang bergerak mengelilingi Matahari.</li>
  <li><strong>Meteoroid</strong> — ketulan kecil batu atau logam di angkasa.</li>
  <li><strong>Komet</strong> — objek berais yang boleh membentuk ekor terang apabila berada berhampiran Matahari.</li>
</ul>

<div class="lesson-tip">
  Sistem Suria seperti sebuah keluarga angkasa, dengan Matahari sebagai pusatnya.
</div>', N'solarsytem.mp4', 1),
(N'LS032', N'ST242', N'Planet Temperatures', N'Suhu Planet', N'<p>Why is it cold on Neptune but hot on Mercury?</p>

<p>Generally, the closer a planet is to the <strong>Sun</strong>, the hotter it is.</p>

<p>Planets that are nearer to the Sun receive more heat. Planets that are farther from the Sun receive less heat.</p>

<ul>
  <li><strong>Mercury</strong> is very close to the Sun, so it is very hot.</li>
  <li><strong>Neptune</strong> is very far from the Sun, so it is very cold.</li>
</ul>

<div class="lesson-tip">
  Venus is the hottest planet because its thick atmosphere traps heat.
</div>', N'<p>Mengapakah Neptun sangat sejuk tetapi Utarid sangat panas?</p>

<p>Secara umumnya, semakin dekat sesuatu planet dengan <strong>Matahari</strong>, semakin panas planet itu.</p>

<p>Planet yang lebih dekat dengan Matahari menerima lebih banyak haba. Planet yang lebih jauh daripada Matahari menerima kurang haba.</p>

<ul>
  <li><strong>Utarid</strong> sangat dekat dengan Matahari, jadi suhunya sangat panas.</li>
  <li><strong>Neptun</strong> sangat jauh daripada Matahari, jadi suhunya sangat sejuk.</li>
</ul>

<div class="lesson-tip">
  Zuhrah ialah planet paling panas kerana atmosferanya yang tebal memerangkap haba.
</div>', N'planettemp.png', 1),
(N'LS033', N'ST243', N'Planetary Orbits', N'Orbit Planet', N'<p>Planets do not just float randomly in space.</p>

<p>They travel around the Sun on invisible paths called <strong>orbits</strong>.</p>

<p>Every planet has its own orbit around the Sun.</p>

<ul>
  <li><strong>Mercury</strong> has the smallest orbit because it is closest to the Sun.</li>
  <li><strong>Neptune</strong> has the largest orbit because it is farthest from the Sun.</li>
</ul>

<p>The orbit keeps each planet moving around the Sun in an organised path.</p>

<div class="lesson-tip">
  An orbit is the path followed by a planet as it moves around the Sun.
</div>', N'<p>Planet tidak terapung secara rawak di angkasa.</p>

<p>Planet bergerak mengelilingi Matahari melalui laluan tidak kelihatan yang dipanggil <strong>orbit</strong>.</p>

<p>Setiap planet mempunyai orbitnya sendiri mengelilingi Matahari.</p>

<ul>
  <li><strong>Utarid</strong> mempunyai orbit paling kecil kerana paling dekat dengan Matahari.</li>
  <li><strong>Neptun</strong> mempunyai orbit paling besar kerana paling jauh daripada Matahari.</li>
</ul>

<p>Orbit memastikan setiap planet bergerak mengelilingi Matahari dalam laluan yang teratur.</p>

<div class="lesson-tip">
  Orbit ialah laluan yang diikuti oleh planet semasa bergerak mengelilingi Matahari.
</div>', N'orbits.png', 1),
(N'LS034', N'ST244', N'Time Taken by Planets to Orbit the Sun', N'Masa Peredaran Planet Mengelilingi Matahari', N'<p>A <strong>year</strong> is different on every planet!</p>

<p>A year is the time taken by a planet to complete one full revolution around the Sun.</p>

<p>Planets that are farther from the Sun have longer orbits. Because their paths are longer, they take more time to complete one revolution.</p>

<ul>
  <li><strong>Mercury</strong> has a short orbit, so it completes one revolution quickly.</li>
  <li><strong>Neptune</strong> has a very long orbit, so it takes much longer to complete one revolution.</li>
</ul>

<div class="lesson-tip">
  The farther a planet is from the Sun, the longer it takes to complete one revolution.
</div>', N'<p><strong>Setahun</strong> adalah berbeza bagi setiap planet!</p>

<p>Setahun ialah masa yang diambil oleh planet untuk melengkapkan satu peredaran penuh mengelilingi Matahari.</p>

<p>Planet yang lebih jauh daripada Matahari mempunyai orbit yang lebih panjang. Oleh itu, planet tersebut mengambil masa yang lebih lama untuk melengkapkan satu peredaran.</p>

<ul>
  <li><strong>Utarid</strong> mempunyai orbit yang pendek, jadi ia melengkapkan satu peredaran dengan cepat.</li>
  <li><strong>Neptun</strong> mempunyai orbit yang sangat panjang, jadi ia mengambil masa yang lebih lama untuk melengkapkan satu peredaran.</li>
</ul>

<div class="lesson-tip">
  Semakin jauh sesuatu planet daripada Matahari, semakin lama masa yang diambil untuk melengkapkan satu peredaran.
</div>', N'timeorbit.png', 1),
(N'LS035', N'ST251', N'Introduction to Pulleys', N'Pengenalan Takal', N'<p>How do we lift heavy flags or buckets of water more easily?</p>

<p>We can use a simple machine called a <strong>pulley</strong>.</p>

<p>A pulley is a simple machine made up of:</p>

<ul>
  <li>a <strong>grooved wheel</strong>, and</li>
  <li>a <strong>rope</strong>.</li>
</ul>

<p>The rope moves along the groove of the wheel to help lift a load.</p>

<p>Pulleys make it easier for us to lift heavy objects.</p>

<div class="lesson-tip">
  A pulley helps reduce the effort needed to lift a load.
</div>', N'<p>Bagaimanakah kita mengangkat bendera atau baldi air yang berat dengan lebih mudah?</p>

<p>Kita boleh menggunakan mesin ringkas yang dipanggil <strong>takal</strong>.</p>

<p>Takal ialah mesin ringkas yang terdiri daripada:</p>

<ul>
  <li><strong>roda beralur</strong>, dan</li>
  <li><strong>tali</strong>.</li>
</ul>

<p>Tali bergerak pada alur roda untuk membantu mengangkat beban.</p>

<p>Takal memudahkan kita mengangkat objek yang berat.</p>

<div class="lesson-tip">
  Takal membantu mengurangkan daya yang diperlukan untuk mengangkat beban.
</div>', N'pulley.mp4', 1),
(N'LS036', N'ST251', N'Types of Pulleys', N'Jenis-jenis Takal', N'<p>Not all pulleys are the same!</p>

<p>There are different types of pulleys used for different jobs.</p>

<ul>
  <li><strong>Fixed pulley</strong> — the pulley stays in one place while the rope moves.</li>
  <li><strong>Movable pulley</strong> — the pulley moves together with the load.</li>
  <li><strong>Compound pulley</strong> — a combination of fixed and movable pulleys for extra lifting power.</li>
</ul>

<p>Each type of pulley helps make lifting easier in its own way.</p>

<div class="lesson-tip">
  Compound pulleys can make heavy loads easier to lift.
</div>', N'<p>Bukan semua takal adalah sama!</p>

<p>Terdapat pelbagai jenis takal yang digunakan untuk tugas yang berbeza.</p>

<ul>
  <li><strong>Takal tetap</strong> — takal berada pada satu tempat semasa tali bergerak.</li>
  <li><strong>Takal bergerak</strong> — takal bergerak bersama-sama dengan beban.</li>
  <li><strong>Takal bergabung</strong> — gabungan takal tetap dan takal bergerak untuk kuasa mengangkat yang lebih kuat.</li>
</ul>

<p>Setiap jenis takal membantu memudahkan kerja mengangkat dengan caranya yang tersendiri.</p>

<div class="lesson-tip">
  Takal bergabung boleh menjadikan beban berat lebih mudah diangkat.
</div>', N'pulley.png', 2),
(N'LS037', N'ST252', N'How a Fixed Pulley Works', N'Cara Takal Tetap Berfungsi', N'<p>Let’s look at the parts of a fixed pulley.</p>

<p>A fixed pulley has several important parts:</p>

<ul>
  <li><strong>Groove</strong> — the channel where the rope sits.</li>
  <li><strong>Rope</strong> — used to pull and lift the load.</li>
  <li><strong>Wheel</strong> — turns when the rope is pulled.</li>
  <li><strong>Axle</strong> — holds the wheel in place and allows it to rotate.</li>
</ul>

<p>When you pull the rope down, the load moves up.</p>

<div class="lesson-tip">
  A pulley changes the direction of force, making lifting easier.
</div>', N'<p>Mari kita lihat bahagian-bahagian takal tetap.</p>

<p>Takal tetap mempunyai beberapa bahagian penting:</p>

<ul>
  <li><strong>Alur</strong> — laluan tempat tali berada.</li>
  <li><strong>Tali</strong> — digunakan untuk menarik dan mengangkat beban.</li>
  <li><strong>Roda</strong> — berputar apabila tali ditarik.</li>
  <li><strong>Gandar</strong> — memegang roda pada tempatnya dan membolehkan roda berputar.</li>
</ul>

<p>Apabila anda menarik tali ke bawah, beban akan bergerak ke atas.</p>

<div class="lesson-tip">
  Takal mengubah arah daya dan menjadikan kerja mengangkat lebih mudah.
</div>', N'fixedpulley.png', 1),
(N'LS038', N'ST253', N'Applications of Pulleys', N'Kegunaan Takal', N'<p>Pulleys are the <strong>strong helpers</strong> in our world.</p>

<p>We use pulleys in many daily activities and machines.</p>

<p>Examples of pulley applications include:</p>

<ol>
  <li><strong>Raising the national flag</strong> on a flagpole.</li>
  <li><strong>Lifting construction materials</strong> using a crane.</li>
  <li><strong>Drawing water from a well</strong> using a bucket and rope.</li>
</ol>

<p>These examples show how pulleys help us lift or move objects more easily.</p>

<div class="lesson-tip">
  Pulleys are useful because they make lifting work easier and safer.
</div>', N'<p>Takal ialah <strong>pembantu yang kuat</strong> dalam kehidupan kita.</p>

<p>Kita menggunakan takal dalam banyak aktiviti harian dan mesin.</p>

<p>Contoh kegunaan takal termasuk:</p>

<ol>
  <li><strong>Menaikkan bendera negara</strong> pada tiang bendera.</li>
  <li><strong>Mengangkat bahan binaan</strong> menggunakan kren.</li>
  <li><strong>Menimba air dari telaga</strong> menggunakan baldi dan tali.</li>
</ol>

<p>Contoh-contoh ini menunjukkan bagaimana takal membantu kita mengangkat atau menggerakkan objek dengan lebih mudah.</p>

<div class="lesson-tip">
  Takal berguna kerana menjadikan kerja mengangkat lebih mudah dan selamat.
</div>', N'pulleyapp.png', 1),
(N'LS039', N'ST253', N'Building a Functional Pulley Model', N'Membina Model Takal Berfungsi', N'<p>Time to be an engineer!</p>

<p>You can build your own simple pulley model using materials found around you.</p>

<p>Materials you can use include:</p>

<ul>
  <li><strong>Thread</strong></li>
  <li><strong>Wire</strong></li>
  <li><strong>A thread spool</strong></li>
  <li><strong>A small load</strong></li>
</ul>

<p>Use the thread spool as the wheel and the thread as the rope. Then, try pulling the thread to lift a small load.</p>

<div class="lesson-activity">
  Build a simple pulley model and observe how it helps lift a load more easily.
</div>', N'<p>Masa untuk menjadi jurutera!</p>

<p>Anda boleh membina model takal ringkas menggunakan bahan yang terdapat di sekeliling anda.</p>

<p>Bahan yang boleh digunakan termasuk:</p>

<ul>
  <li><strong>Benang</strong></li>
  <li><strong>Dawai</strong></li>
  <li><strong>Gelendong benang</strong></li>
  <li><strong>Beban kecil</strong></li>
</ul>

<p>Gunakan gelendong benang sebagai roda dan benang sebagai tali. Kemudian, cuba tarik benang untuk mengangkat beban kecil.</p>

<div class="lesson-activity">
  Bina model takal ringkas dan perhatikan bagaimana takal membantu mengangkat beban dengan lebih mudah.
</div>', N'functionalpulley.png', 2),
(N'LS040', N'ST311', N'Human Skeletal System', N'Sistem Rangka Manusia', N'<p>Why can humans stand upright while worms cannot?</p>

<p>It is because humans have a strong internal frame called a <strong>skeleton</strong>.</p>

<p>The human skeleton is made up of many bones that form a complete skeletal system.</p>

<p>Major parts of the human skeleton include:</p>

<ul>
  <li><strong>Skull</strong></li>
  <li><strong>Backbone</strong></li>
  <li><strong>Ribs</strong></li>
  <li><strong>Hand bones</strong></li>
  <li><strong>Leg bones</strong></li>
</ul>

<div class="lesson-tip">
  The skeleton gives our body shape and helps us stand upright.
</div>', N'<p>Mengapakah manusia boleh berdiri tegak tetapi cacing tidak boleh?</p>

<p>Ini kerana manusia mempunyai rangka dalaman yang kuat yang dipanggil <strong>rangka</strong>.</p>

<p>Rangka manusia terdiri daripada banyak tulang yang membentuk satu sistem rangka yang lengkap.</p>

<p>Bahagian utama rangka manusia termasuk:</p>

<ul>
  <li><strong>Tengkorak</strong></li>
  <li><strong>Tulang belakang</strong></li>
  <li><strong>Tulang rusuk</strong></li>
  <li><strong>Tulang tangan</strong></li>
  <li><strong>Tulang kaki</strong></li>
</ul>

<div class="lesson-tip">
  Rangka memberikan bentuk kepada badan dan membantu kita berdiri tegak.
</div>', N'skeletal.mp4', 1),
(N'LS041', N'ST311', N'Functions of the Human Skeleton', N'Fungsi Sistem Rangka Manusia', N'<p>Mengapakah manusia boleh berdiri tegak tetapi cacing tidak boleh?</p>

<p>Ini kerana manusia mempunyai rangka dalaman yang kuat yang dipanggil <strong>rangka</strong>.</p>

<p>Rangka manusia terdiri daripada banyak tulang yang membentuk satu sistem rangka yang lengkap.</p>

<p>Bahagian utama rangka manusia termasuk:</p>

<ul>
  <li><strong>Tengkorak</strong></li>
  <li><strong>Tulang belakang</strong></li>
  <li><strong>Tulang rusuk</strong></li>
  <li><strong>Tulang tangan</strong></li>
  <li><strong>Tulang kaki</strong></li>
</ul>

<div class="lesson-tip">
  Rangka memberikan bentuk kepada badan dan membantu kita berdiri tegak.
</div>', N'<p>Setiap tulang mempunyai tugas yang penting!</p>

<p>Rangka bukan sahaja memberikan bentuk kepada badan. Rangka juga melindungi organ penting dan membantu kita bergerak.</p>

<p>Antara bahagian penting rangka dan fungsinya ialah:</p>

<ol>
  <li><strong>Tengkorak</strong> — melindungi otak daripada kecederaan.</li>
  <li><strong>Tulang belakang</strong> — memberikan sokongan kepada badan.</li>
  <li><strong>Tulang rusuk</strong> — melindungi organ dalaman seperti jantung dan paru-paru.</li>
  <li><strong>Tulang tangan dan kaki</strong> — membantu pergerakan dan memberi sokongan.</li>
</ol>

<div class="lesson-tip">
  Rangka melindungi, menyokong, dan membantu badan bergerak.
</div>', N'fskeletal.png', 2),
(N'LS042', N'ST311', N'Importance of the Skeletal System', N'Kepentingan Sistem Rangka', N'<p>What would happen if we had no bones?</p>

<p>Without a skeleton, our body would be soft and have no proper shape.</p>

<p>The skeletal system is important because it:</p>

<ul>
  <li>gives shape to the body,</li>
  <li>supports the body,</li>
  <li>protects delicate internal organs, and</li>
  <li>helps us stay active and move around.</li>
</ul>

<p>Because of our skeleton, we can stand, walk, run, jump, and play.</p>

<div class="lesson-tip">
  The skeletal system is important for body shape, protection, support, and movement.
</div>', N'<p>Apakah yang akan berlaku jika kita tidak mempunyai tulang?</p>

<p>Tanpa rangka, badan kita akan menjadi lembut dan tidak mempunyai bentuk yang tetap.</p>

<p>Sistem rangka penting kerana ia:</p>

<ul>
  <li>memberikan bentuk kepada badan,</li>
  <li>menyokong badan,</li>
  <li>melindungi organ dalaman yang lembut, dan</li>
  <li>membantu kita kekal aktif dan bergerak.</li>
</ul>

<p>Disebabkan rangka, kita boleh berdiri, berjalan, berlari, melompat, dan bermain.</p>

<div class="lesson-tip">
  Sistem rangka penting untuk bentuk badan, perlindungan, sokongan, dan pergerakan.
</div>', N'iskeletal.png', 3),
(N'LS043', N'ST312', N'Position of Joints in the Human Body', N'Kedudukan Sendi dalam Badan Manusia', N'<p>How can we bend our arms or turn our heads?</p>

<p>We can do this because our body has <strong>joints</strong>.</p>

<p>Joints are places where two or more bones meet.</p>

<p>Joints can be found in many parts of the body, such as:</p>

<ul>
  <li><strong>Neck</strong></li>
  <li><strong>Shoulders</strong></li>
  <li><strong>Elbows</strong></li>
  <li><strong>Wrists</strong></li>
  <li><strong>Hips</strong></li>
  <li><strong>Knees</strong></li>
  <li><strong>Ankles</strong></li>
</ul>

<div class="lesson-tip">
  Joints are important because they allow different parts of the body to move.
</div>', N'<p>Bagaimanakah kita boleh membengkokkan tangan atau memusingkan kepala?</p>

<p>Kita boleh melakukannya kerana badan kita mempunyai <strong>sendi</strong>.</p>

<p>Sendi ialah tempat di mana dua atau lebih tulang bertemu.</p>

<p>Sendi boleh ditemui pada banyak bahagian badan, seperti:</p>

<ul>
  <li><strong>Leher</strong></li>
  <li><strong>Bahu</strong></li>
  <li><strong>Siku</strong></li>
  <li><strong>Pergelangan tangan</strong></li>
  <li><strong>Pinggul</strong></li>
  <li><strong>Lutut</strong></li>
  <li><strong>Pergelangan kaki</strong></li>
</ul>

<div class="lesson-tip">
  Sendi penting kerana membolehkan bahagian badan bergerak.
</div>', N'joints.mp4', 1),
(N'LS044', N'ST312', N'Functions of Joints', N'Fungsi Sendi', N'<p>Joints are like the hinges on a door!</p>

<p>A door hinge allows a door to open and close. In the same way, joints allow our body parts to move.</p>

<p>Joints make our skeleton flexible. Because of joints, we can:</p>

<ul>
  <li>walk,</li>
  <li>run,</li>
  <li>dance,</li>
  <li>jump,</li>
  <li>play sports, and</li>
  <li>carry out daily activities.</li>
</ul>

<p>Without joints, our body would be stiff and difficult to move.</p>

<div class="lesson-tip">
  Joints help the skeleton move smoothly and flexibly.
</div>', N'<p>Sendi adalah seperti engsel pada pintu!</p>

<p>Engsel membolehkan pintu dibuka dan ditutup. Begitu juga, sendi membolehkan bahagian badan kita bergerak.</p>

<p>Sendi menjadikan rangka kita fleksibel. Disebabkan sendi, kita boleh:</p>

<ul>
  <li>berjalan,</li>
  <li>berlari,</li>
  <li>menari,</li>
  <li>melompat,</li>
  <li>bersukan, dan</li>
  <li>melakukan aktiviti harian.</li>
</ul>

<p>Tanpa sendi, badan kita akan menjadi kaku dan sukar bergerak.</p>

<div class="lesson-tip">
  Sendi membantu rangka bergerak dengan lancar dan fleksibel.
</div>', N'fjoints.png', 2),
(N'LS045', N'ST312', N'Types of Joint Movement', N'Jenis Pergerakan Sendi', N'<p>Not all joints move in the same way.</p>

<p>Different joints allow different types of movement.</p>

<ol>
  <li><strong>Neck joint</strong> — allows us to rotate or turn our head.</li>
  <li><strong>Shoulder and hip joints</strong> — allow circular movements.</li>
  <li><strong>Elbow and knee joints</strong> — act like hinges for folding and extending our arms or legs.</li>
</ol>

<p>These movements help us carry out many activities in daily life.</p>

<div class="lesson-tip">
  Different joints have different movements depending on their position and structure.
</div>', N'<p>Bukan semua sendi bergerak dengan cara yang sama.</p>

<p>Sendi yang berbeza membolehkan jenis pergerakan yang berbeza.</p>

<ol>
  <li><strong>Sendi leher</strong> — membolehkan kita memusingkan kepala.</li>
  <li><strong>Sendi bahu dan pinggul</strong> — membolehkan pergerakan membulat.</li>
  <li><strong>Sendi siku dan lutut</strong> — bertindak seperti engsel untuk membengkokkan dan meluruskan tangan atau kaki.</li>
</ol>

<p>Pergerakan ini membantu kita melakukan pelbagai aktiviti dalam kehidupan harian.</p>

<div class="lesson-tip">
  Sendi yang berbeza mempunyai pergerakan yang berbeza mengikut kedudukan dan strukturnya.
</div>', N'jointsmove.png', 3),
(N'LS046', N'ST313', N'Main Parts of the Circulatory System', N'Bahagian Utama Sistem Peredaran Darah', N'<p>Our body has a transport system that moves blood around the body!</p>

<p>This system is called the <strong>circulatory system</strong>.</p>

<p>The main parts of the circulatory system are:</p>

<ul>
  <li><strong>Heart</strong></li>
  <li><strong>Blood vessels</strong></li>
  <li><strong>Blood</strong></li>
  <li><strong>Lungs</strong></li>
</ul>

<p>These parts work together to transport oxygen, nutrients, water, and waste products.</p>

<div class="lesson-tip">
  The circulatory system helps carry important substances throughout the body.
</div>', N'<p>Badan kita mempunyai sistem pengangkutan yang menggerakkan darah ke seluruh badan!</p>

<p>Sistem ini dipanggil <strong>sistem peredaran darah</strong>.</p>

<p>Bahagian utama sistem peredaran darah ialah:</p>

<ul>
  <li><strong>Jantung</strong></li>
  <li><strong>Salur darah</strong></li>
  <li><strong>Darah</strong></li>
  <li><strong>Paru-paru</strong></li>
</ul>

<p>Bahagian-bahagian ini bekerjasama untuk mengangkut oksigen, nutrien, air, dan bahan buangan.</p>

<div class="lesson-tip">
  Sistem peredaran darah membantu membawa bahan penting ke seluruh badan.
</div>', N'circulatorysystem.mp4', 1),
(N'LS047', N'ST313', N'Functions of the Heart, Blood Vessels and Blood', N'Fungsi Jantung, Salur Darah dan Darah', N'<p>Think of the heart as a pump and blood vessels as pipes!</p>

<p>Each part of the circulatory system has an important function:</p>

<ul>
  <li><strong>Heart</strong> — pumps blood to the lungs and the rest of the body.</li>
  <li><strong>Blood vessels</strong> — tubes that transport blood around the body.</li>
  <li><strong>Blood</strong> — carries oxygen, nutrients, and water.</li>
  <li><strong>Lungs</strong> — the place where oxygen and carbon dioxide are exchanged.</li>
</ul>

<p>All these parts work together to keep the body alive and active.</p>

<div class="lesson-tip">
  The heart, blood vessels, blood, and lungs work as a team.
</div>', N'<p>Bayangkan jantung sebagai pam dan salur darah sebagai paip!</p>

<p>Setiap bahagian sistem peredaran darah mempunyai fungsi yang penting:</p>

<ul>
  <li><strong>Jantung</strong> — mengepam darah ke paru-paru dan seluruh badan.</li>
  <li><strong>Salur darah</strong> — tiub yang mengangkut darah ke seluruh badan.</li>
  <li><strong>Darah</strong> — membawa oksigen, nutrien, dan air.</li>
  <li><strong>Paru-paru</strong> — tempat pertukaran oksigen dan karbon dioksida berlaku.</li>
</ul>

<p>Semua bahagian ini bekerjasama untuk memastikan badan terus hidup dan aktif.</p>

<div class="lesson-tip">
  Jantung, salur darah, darah, dan paru-paru bekerjasama sebagai satu pasukan.
</div>', N'fcirculatory.png', 2),
(N'LS048', N'ST313', N'Importance of the Circulatory System', N'Kepentingan Sistem Peredaran Darah', N'<p>Why do we need blood to move around the body?</p>

<p>The circulatory system is important because it carries useful substances to every part of the body.</p>

<p>It helps to:</p>

<ul>
  <li>deliver <strong>oxygen</strong> to body cells,</li>
  <li>deliver <strong>nutrients</strong> from food to body cells,</li>
  <li>carry <strong>water</strong> around the body, and</li>
  <li>remove waste products such as <strong>carbon dioxide</strong>.</li>
</ul>

<p>This keeps every cell in the body healthy and working properly.</p>

<div class="lesson-tip">
  The circulatory system keeps body cells supplied with oxygen and nutrients.
</div>', N'<p>Mengapakah darah perlu bergerak ke seluruh badan?</p>

<p>Sistem peredaran darah penting kerana membawa bahan berguna ke setiap bahagian badan.</p>

<p>Sistem ini membantu untuk:</p>

<ul>
  <li>menghantar <strong>oksigen</strong> kepada sel-sel badan,</li>
  <li>menghantar <strong>nutrien</strong> daripada makanan kepada sel-sel badan,</li>
  <li>membawa <strong>air</strong> ke seluruh badan, dan</li>
  <li>menyingkirkan bahan buangan seperti <strong>karbon dioksida</strong>.</li>
</ul>

<p>Ini memastikan setiap sel dalam badan kekal sihat dan berfungsi dengan baik.</p>

<div class="lesson-tip">
  Sistem peredaran darah membekalkan oksigen dan nutrien kepada sel-sel badan.
</div>', N'icirculatory.png', 3),
(N'LS049', N'ST314', N'Blood Circulation Pathway', N'Laluan Peredaran Darah', N'<p>Follow the red and blue paths of blood circulation!</p>

<p>Blood travels through the body in two main pathways:</p>

<ol>
  <li><strong>Oxygen-rich blood</strong> travels from the lungs to the heart, then from the heart to the rest of the body.</li>
  <li><strong>Carbon dioxide-rich blood</strong> travels from the body to the heart, then from the heart back to the lungs to release carbon dioxide.</li>
</ol>

<p>In the lungs, carbon dioxide is removed from the body when we breathe out.</p>

<div class="lesson-tip">
  Blood carries oxygen to the body and carries carbon dioxide back to the lungs.
</div>', N'<p>Ikuti laluan merah dan biru dalam peredaran darah!</p>

<p>Darah bergerak melalui badan dalam dua laluan utama:</p>

<ol>
  <li><strong>Darah kaya oksigen</strong> bergerak dari paru-paru ke jantung, kemudian dari jantung ke seluruh badan.</li>
  <li><strong>Darah kaya karbon dioksida</strong> bergerak dari badan ke jantung, kemudian dari jantung kembali ke paru-paru untuk menyingkirkan karbon dioksida.</li>
</ol>

<p>Di paru-paru, karbon dioksida dikeluarkan daripada badan apabila kita menghembus nafas.</p>

<div class="lesson-tip">
  Darah membawa oksigen ke seluruh badan dan membawa karbon dioksida kembali ke paru-paru.
</div>', N'pathcirc.png', 1),
(N'LS050', N'ST314', N'Relationship Between Body Systems', N'Hubungan Antara Sistem Badan', N'<p>Our body systems work together like a team!</p>

<p>Each system has its own job, but they depend on one another to keep the body healthy.</p>

<ul>
  <li>The <strong>respiratory system</strong> provides oxygen.</li>
  <li>The <strong>circulatory system</strong> carries oxygen to all parts of the body.</li>
  <li>The <strong>skeletal system</strong> protects important organs such as the heart and lungs.</li>
  <li>The <strong>digestive system</strong> provides nutrients for growth and energy.</li>
</ul>

<p>When these systems work together, the body can function well.</p>

<div class="lesson-tip">
  Body systems are connected and must work together to keep us alive and healthy.
</div>', N'<p>Sistem badan kita bekerjasama seperti satu pasukan!</p>

<p>Setiap sistem mempunyai tugas tersendiri, tetapi semuanya saling bergantung untuk memastikan badan sihat.</p>

<ul>
  <li><strong>Sistem respirasi</strong> membekalkan oksigen.</li>
  <li><strong>Sistem peredaran darah</strong> membawa oksigen ke seluruh badan.</li>
  <li><strong>Sistem rangka</strong> melindungi organ penting seperti jantung dan paru-paru.</li>
  <li><strong>Sistem pencernaan</strong> membekalkan nutrien untuk tumbesaran dan tenaga.</li>
</ul>

<p>Apabila sistem-sistem ini bekerjasama, badan dapat berfungsi dengan baik.</p>

<div class="lesson-tip">
  Sistem badan saling berhubung dan perlu bekerjasama untuk memastikan kita hidup dan sihat.
</div>', N'bodysystem.png', 2),
(N'LS051', N'ST314', N'Caring for Body Systems', N'Penjagaan Sistem Badan', N'<p>Keep your body systems healthy like a strong team!</p>

<p>We can take care of our body systems by practising healthy habits.</p>

<ul>
  <li>Eat <strong>calcium-rich foods</strong>, such as milk and cheese, to strengthen bones.</li>
  <li>Exercise regularly to keep the heart strong.</li>
  <li>Avoid smoking to protect the lungs.</li>
  <li>Eat balanced meals to provide nutrients for the body.</li>
  <li>Drink enough water every day.</li>
  <li>Get enough rest so the body can recover.</li>
</ul>

<div class="lesson-tip">
  Healthy habits help our body systems work properly.
</div>', N'<p>Pastikan sistem badan anda sihat seperti satu pasukan yang kuat!</p>

<p>Kita boleh menjaga sistem badan dengan mengamalkan tabiat yang sihat.</p>

<ul>
  <li>Makan makanan yang kaya dengan <strong>kalsium</strong>, seperti susu dan keju, untuk menguatkan tulang.</li>
  <li>Bersenam secara berkala untuk menguatkan jantung.</li>
  <li>Elakkan merokok untuk melindungi paru-paru.</li>
  <li>Makan makanan seimbang untuk membekalkan nutrien kepada badan.</li>
  <li>Minum air yang mencukupi setiap hari.</li>
  <li>Dapatkan rehat yang cukup supaya badan boleh pulih.</li>
</ul>

<div class="lesson-tip">
  Tabiat sihat membantu sistem badan kita berfungsi dengan baik.
</div>', N'carebody.png', 3),
(N'LS052', N'ST321', N'Sources of Electricity', N'Sumber Elektrik', N'<p>Where does the power for your television come from?</p>

<p>Electricity can come from many different sources.</p>

<p>Some common sources of electricity are:</p>

<ul>
  <li><strong>Power stations</strong></li>
  <li><strong>Solar cells</strong></li>
  <li><strong>Dry cells</strong></li>
  <li><strong>Accumulators</strong></li>
  <li><strong>Dynamos</strong></li>
  <li><strong>Generators</strong></li>
</ul>

<p>These sources help provide electricity for homes, schools, vehicles, and machines.</p>

<div class="lesson-tip">
  Different sources of electricity are used for different purposes.
</div>', N'<p>Dari manakah kuasa elektrik untuk televisyen anda datang?</p>

<p>Elektrik boleh datang daripada pelbagai sumber yang berbeza.</p>

<p>Antara sumber elektrik yang biasa ialah:</p>

<ul>
  <li><strong>Stesen jana kuasa</strong></li>
  <li><strong>Sel suria</strong></li>
  <li><strong>Sel kering</strong></li>
  <li><strong>Akumulator</strong></li>
  <li><strong>Dinamo</strong></li>
  <li><strong>Penjana</strong></li>
</ul>

<p>Sumber-sumber ini membantu membekalkan elektrik untuk rumah, sekolah, kenderaan, dan mesin.</p>

<div class="lesson-tip">
  Sumber elektrik yang berbeza digunakan untuk tujuan yang berbeza.
</div>', N'electricity.mp4', 1),
(N'LS053', N'ST321', N'Dry Cells, Solar Cells and Generators', N'Sel Kering, Sel Suria dan Penjana', N'<p>Different jobs need different sources of electricity!</p>

<p>Some devices need small cells, while bigger machines may need stronger sources of electricity.</p>

<ul>
  <li><strong>Solar cells</strong> use sunlight to produce electricity. They are used in objects such as satellites and calculators.</li>
  <li><strong>Accumulators</strong> store electrical energy and are commonly used to power vehicles.</li>
  <li><strong>Dynamos</strong> change movement energy into electrical energy, such as in bicycle lights.</li>
  <li><strong>Generators</strong> convert energy from fuel into electricity.</li>
  <li><strong>Dry cells</strong> provide electricity for small devices such as torches, clocks, and remote controls.</li>
</ul>

<div class="lesson-tip">
  The right electricity source depends on the device and the amount of energy needed.
</div>', N'<p>Different jobs need different sources of electricity!</p>

<p>Some devices need small cells, while bigger machines may need stronger sources of electricity.</p>

<ul>
  <li><strong>Solar cells</strong> use sunlight to produce electricity. They are used in objects such as satellites and calculators.</li>
  <li><strong>Accumulators</strong> store electrical energy and are commonly used to power vehicles.</li>
  <li><strong>Dynamos</strong> change movement energy into electrical energy, such as in bicycle lights.</li>
  <li><strong>Generators</strong> convert energy from fuel into electricity.</li>
  <li><strong>Dry cells</strong> provide electricity for small devices such as torches, clocks, and remote controls.</li>
</ul>

<div class="lesson-tip">
  The right electricity source depends on the device and the amount of energy needed.
</div>', N'cells.png', 2),
(N'LS054', N'ST322', N'Series Circuit', N'Litar Bersiri', N'<p>A series circuit has a single path for electricity to flow.</p>

<p>In a <strong>series circuit</strong>, bulbs are arranged in one single loop.</p>

<p>Electricity must pass through each component one after another.</p>

<ul>
  <li>If all bulbs are connected properly, the circuit works.</li>
  <li>If one bulb breaks, the whole circuit stops working.</li>
  <li>The bulbs share the electrical energy, so they may appear dimmer.</li>
</ul>

<div class="lesson-tip">
  In a series circuit, all components are connected in one path.
</div>', N'<p>Litar bersiri mempunyai satu laluan sahaja untuk elektrik mengalir.</p>

<p>Dalam <strong>litar bersiri</strong>, mentol disusun dalam satu gelung tunggal.</p>

<p>Elektrik perlu melalui setiap komponen satu demi satu.</p>

<ul>
  <li>Jika semua mentol disambung dengan betul, litar akan berfungsi.</li>
  <li>Jika satu mentol rosak, seluruh litar akan berhenti berfungsi.</li>
  <li>Mentol berkongsi tenaga elektrik, jadi nyalaannya mungkin menjadi lebih malap.</li>
</ul>

<div class="lesson-tip">
  Dalam litar bersiri, semua komponen disambungkan dalam satu laluan.
</div>', N'seriescir.png', 1),
(N'LS055', N'ST322', N'Parallel Circuit', N'Litar Selari', N'<p>Litar bersiri mempunyai satu laluan sahaja untuk elektrik mengalir.</p>

<p>Dalam <strong>litar bersiri</strong>, mentol disusun dalam satu gelung tunggal.</p>

<p>Elektrik perlu melalui setiap komponen satu demi satu.</p>

<ul>
  <li>Jika semua mentol disambung dengan betul, litar akan berfungsi.</li>
  <li>Jika satu mentol rosak, seluruh litar akan berhenti berfungsi.</li>
  <li>Mentol berkongsi tenaga elektrik, jadi nyalaannya mungkin menjadi lebih malap.</li>
</ul>

<div class="lesson-tip">
  Dalam litar bersiri, semua komponen disambungkan dalam satu laluan.
</div>', N'<p>Litar selari memberikan lebih daripada satu laluan untuk elektrik mengalir.</p>

<p>Dalam <strong>litar selari</strong>, komponen disambungkan pada cabang yang berasingan.</p>

<ul>
  <li>Elektrik boleh mengalir melalui lebih daripada satu laluan.</li>
  <li>Jika satu laluan terputus, laluan yang lain masih boleh berfungsi.</li>
  <li>Mentol pada cabang lain masih boleh menyala.</li>
</ul>

<p>Ini menjadikan litar selari berguna untuk rumah dan bangunan.</p>

<div class="lesson-tip">
  Dalam litar selari, komponen boleh berfungsi secara berasingan pada laluan yang berbeza.
</div>', N'parallelcir.png', 2),
(N'LS056', N'ST322', N'Differences Between Series and Parallel Circuits', N'Perbezaan Litar Bersiri dan Selari', N'<p>Litar selari memberikan lebih daripada satu laluan untuk elektrik mengalir.</p>

<p>Dalam <strong>litar selari</strong>, komponen disambungkan pada cabang yang berasingan.</p>

<ul>
  <li>Elektrik boleh mengalir melalui lebih daripada satu laluan.</li>
  <li>Jika satu laluan terputus, laluan yang lain masih boleh berfungsi.</li>
  <li>Mentol pada cabang lain masih boleh menyala.</li>
</ul>

<p>Ini menjadikan litar selari berguna untuk rumah dan bangunan.</p>

<div class="lesson-tip">
  Dalam litar selari, komponen boleh berfungsi secara berasingan pada laluan yang berbeza.
</div>', N'<p>Litar manakah yang lebih baik: litar bersiri atau litar selari?</p>

<p>Kedua-dua litar berguna, tetapi berfungsi dengan cara yang berbeza.</p>

<p><strong>Litar bersiri:</strong></p>

<ul>
  <li>Pendawaiannya lebih ringkas.</li>
  <li>Mempunyai satu laluan sahaja untuk elektrik.</li>
  <li>Mentol berkongsi tenaga elektrik, jadi nyalaannya mungkin lebih malap.</li>
  <li>Jika satu mentol rosak, seluruh litar berhenti berfungsi.</li>
</ul>

<p><strong>Litar selari:</strong></p>

<ul>
  <li>Pendawaiannya lebih kompleks.</li>
  <li>Mempunyai lebih daripada satu laluan untuk elektrik.</li>
  <li>Mentol boleh menyala dengan kecerahan yang sama.</li>
  <li>Jika satu mentol rosak, mentol lain masih boleh berfungsi.</li>
</ul>

<div class="lesson-tip">
  Litar bersiri lebih ringkas, manakala litar selari membolehkan komponen berfungsi secara berasingan.
</div>', N'diffseriesparallel.png', 3),
(N'LS057', N'ST323', N'Circuit Components and Symbols', N'Komponen dan Simbol Litar', N'<p>Scientists and engineers use special symbols to draw circuits clearly.</p>

<p>These symbols act like a secret code for circuits.</p>

<p>Common circuit symbols include:</p>

<ul>
  <li><strong>Dry cell</strong> — shown as long and short parallel lines.</li>
  <li><strong>Switch</strong> — shown as a line with an open or closed bridge.</li>
  <li><strong>Bulb</strong> — shown as a circle with an <strong>X</strong> inside.</li>
  <li><strong>Wire</strong> — shown as a straight line connecting components.</li>
</ul>

<p>Using symbols makes circuit diagrams easier to read and understand.</p>

<div class="lesson-tip">
  Circuit symbols help us draw electrical circuits neatly and accurately.
</div>', N'<p>Saintis dan jurutera menggunakan simbol khas untuk melukis litar dengan jelas.</p>

<p>Simbol-simbol ini seperti kod rahsia untuk litar.</p>

<p>Antara simbol litar yang biasa ialah:</p>

<ul>
  <li><strong>Sel kering</strong> — ditunjukkan sebagai garisan selari panjang dan pendek.</li>
  <li><strong>Suis</strong> — ditunjukkan sebagai garisan dengan jambatan terbuka atau tertutup.</li>
  <li><strong>Mentol</strong> — ditunjukkan sebagai bulatan dengan tanda <strong>X</strong> di dalamnya.</li>
  <li><strong>Wayar</strong> — ditunjukkan sebagai garisan lurus yang menyambungkan komponen.</li>
</ul>

<p>Penggunaan simbol menjadikan rajah litar lebih mudah dibaca dan difahami.</p>

<div class="lesson-tip">
  Simbol litar membantu kita melukis litar elektrik dengan kemas dan tepat.
</div>', N'componentsymbol.png', 1),
(N'LS058', N'ST323', N'Drawing Circuit Diagrams', N'Melukis Rajah Litar', N'<p>Draw like an engineer!</p>

<p>When drawing circuit diagrams, we do not need to draw realistic pictures of batteries, bulbs, or switches.</p>

<p>Instead, we use:</p>

<ul>
  <li><strong>circuit symbols</strong> to represent components, and</li>
  <li><strong>straight lines</strong> to represent wires.</li>
</ul>

<p>This makes the circuit diagram clear, simple, and easy to understand.</p>

<p>A good circuit diagram should be neat, labelled correctly, and connected properly.</p>

<div class="lesson-tip">
  Circuit diagrams are blueprints that show how electrical components are connected.
</div>', N'<p>Lukis seperti seorang jurutera!</p>

<p>Apabila melukis rajah litar, kita tidak perlu melukis gambar sebenar bateri, mentol, atau suis.</p>

<p>Sebaliknya, kita menggunakan:</p>

<ul>
  <li><strong>simbol litar</strong> untuk mewakili komponen, dan</li>
  <li><strong>garisan lurus</strong> untuk mewakili wayar.</li>
</ul>

<p>Ini menjadikan rajah litar jelas, ringkas, dan mudah difahami.</p>

<p>Rajah litar yang baik mestilah kemas, dilabel dengan betul, dan disambungkan dengan tepat.</p>

<div class="lesson-tip">
  Rajah litar ialah pelan yang menunjukkan cara komponen elektrik disambungkan.
</div>', N'circuitdiagram.png', 2),
(N'LS059', N'ST331', N'States of Matter', N'Keadaan Jirim', N'<p>Everything around us is made of <strong>matter</strong>!</p>

<p>Matter is anything that has mass and takes up space.</p>

<p>Matter exists in three main states:</p>

<ul>
  <li><strong>Solid</strong> — has a fixed shape. Examples include sand and ice.</li>
  <li><strong>Liquid</strong> — flows and takes the shape of its container. Examples include seawater and juice.</li>
  <li><strong>Gas</strong> — spreads out to fill the space around it. Examples include wind and steam.</li>
</ul>

<div class="lesson-tip">
  Matter can exist as solid, liquid, or gas.
</div>', N'<p>Semua benda di sekeliling kita terdiri daripada <strong>jirim</strong>!</p>

<p>Jirim ialah sesuatu yang mempunyai jisim dan memenuhi ruang.</p>

<p>Jirim wujud dalam tiga keadaan utama:</p>

<ul>
  <li><strong>Pepejal</strong> — mempunyai bentuk yang tetap. Contohnya pasir dan ais.</li>
  <li><strong>Cecair</strong> — mengalir dan mengikut bentuk bekas. Contohnya air laut dan jus.</li>
  <li><strong>Gas</strong> — merebak untuk memenuhi ruang di sekelilingnya. Contohnya angin dan wap.</li>
</ul>

<div class="lesson-tip">
  Jirim boleh wujud sebagai pepejal, cecair, atau gas.
</div>', N'matter.mp4', 1),
(N'LS060', N'ST331', N'Melting and Freezing', N'Peleburan dan Pembekuan', N'<p>What happens when we add heat or take heat away?</p>

<p>Matter can change from one state to another when it receives or loses heat.</p>

<ul>
  <li><strong>Melting</strong> happens when a solid receives heat and changes into a liquid.</li>
  <li><strong>Freezing</strong> happens when a liquid loses heat and changes into a solid.</li>
</ul>

<p>For example, ice melts into water when it receives heat. Water freezes into ice when it loses heat.</p>

<div class="lesson-tip">
  Melting needs heat, while freezing happens when heat is removed.
</div>', N'<p>Apakah yang berlaku apabila kita menambah haba atau mengurangkan haba?</p>

<p>Jirim boleh berubah daripada satu keadaan kepada keadaan lain apabila menerima atau kehilangan haba.</p>

<ul>
  <li><strong>Peleburan</strong> berlaku apabila pepejal menerima haba dan berubah menjadi cecair.</li>
  <li><strong>Pembekuan</strong> berlaku apabila cecair kehilangan haba dan berubah menjadi pepejal.</li>
</ul>

<p>Contohnya, ais melebur menjadi air apabila menerima haba. Air membeku menjadi ais apabila kehilangan haba.</p>

<div class="lesson-tip">
  Peleburan memerlukan haba, manakala pembekuan berlaku apabila haba disingkirkan.
</div>', N'meltfreezing.png', 2),
(N'LS061', N'ST331', N'Evaporation and Condensation', N'Penyejatan dan Kondensasi', N'<p>Matter can change into gas and back into liquid!</p>

<p>These changes happen when heat is received or lost.</p>

<ul>
  <li><strong>Evaporation</strong> happens when a liquid changes into gas.</li>
  <li><strong>Boiling</strong> is a fast change from liquid to gas when enough heat is given.</li>
  <li><strong>Condensation</strong> happens when gas loses heat and changes back into liquid.</li>
</ul>

<p>For example, steam can turn into water droplets on a mirror during condensation.</p>

<div class="lesson-tip">
  Evaporation changes liquid to gas, while condensation changes gas to liquid.
</div>', N'<p>Jirim boleh berubah menjadi gas dan kembali menjadi cecair!</p>

<p>Perubahan ini berlaku apabila haba diterima atau hilang.</p>

<ul>
  <li><strong>Penyejatan</strong> berlaku apabila cecair berubah menjadi gas.</li>
  <li><strong>Pendidihan</strong> ialah perubahan cepat daripada cecair kepada gas apabila haba yang cukup diberikan.</li>
  <li><strong>Kondensasi</strong> berlaku apabila gas kehilangan haba dan berubah kembali menjadi cecair.</li>
</ul>

<p>Contohnya, wap boleh berubah menjadi titisan air pada cermin semasa kondensasi.</p>

<div class="lesson-tip">
  Penyejatan menukarkan cecair kepada gas, manakala kondensasi menukarkan gas kepada cecair.
</div>', N'evaporateandcondense.png', 3),
(N'LS062', N'ST332', N'Physical Properties of Matter', N'Sifat Fizikal Jirim', N'<p>How does matter behave in different states?</p>

<p>Solids, liquids, and gases have different physical properties.</p>

<ul>
  <li><strong>Solids</strong> have a fixed shape, fixed mass, and fixed volume.</li>
  <li><strong>Liquids</strong> have mass and fixed volume, but they take the shape of their container.</li>
  <li><strong>Gases</strong> have no fixed shape and no fixed volume. They fill the entire space available.</li>
</ul>

<p>These properties help us identify whether something is a solid, liquid, or gas.</p>

<div class="lesson-tip">
  The state of matter affects its shape and volume.
</div>', N'<p>Bagaimanakah jirim berkelakuan dalam keadaan yang berbeza?</p>

<p>Pepejal, cecair, dan gas mempunyai sifat fizikal yang berbeza.</p>

<ul>
  <li><strong>Pepejal</strong> mempunyai bentuk tetap, jisim tetap, dan isi padu tetap.</li>
  <li><strong>Cecair</strong> mempunyai jisim dan isi padu tetap, tetapi mengikut bentuk bekas.</li>
  <li><strong>Gas</strong> tidak mempunyai bentuk tetap dan tidak mempunyai isi padu tetap. Gas memenuhi seluruh ruang yang ada.</li>
</ul>

<p>Sifat-sifat ini membantu kita mengenal pasti sama ada sesuatu bahan ialah pepejal, cecair, atau gas.</p>

<div class="lesson-tip">
  Keadaan jirim mempengaruhi bentuk dan isi padunya.
</div>', N'matter.png', 1),
(N'LS063', N'ST332', N'Changes in Matter', N'Perubahan Jirim', N'<p>Water is a shape-shifter!</p>

<p>Water is special because it can exist in three different states depending on temperature.</p>

<ul>
  <li><strong>Solid</strong> — water becomes ice when it freezes.</li>
  <li><strong>Liquid</strong> — water flows in rivers, lakes, and oceans.</li>
  <li><strong>Gas</strong> — water becomes water vapour when it evaporates.</li>
</ul>

<p>When temperature changes, water can change from one state to another.</p>

<div class="lesson-tip">
  Water can exist as ice, liquid water, or water vapour.
</div>', N'<p>Air boleh berubah bentuk!</p>

<p>Air adalah istimewa kerana boleh wujud dalam tiga keadaan yang berbeza bergantung kepada suhu.</p>

<ul>
  <li><strong>Pepejal</strong> — air menjadi ais apabila membeku.</li>
  <li><strong>Cecair</strong> — air mengalir di sungai, tasik, dan lautan.</li>
  <li><strong>Gas</strong> — air menjadi wap air apabila tersejat.</li>
</ul>

<p>Apabila suhu berubah, air boleh berubah daripada satu keadaan kepada keadaan lain.</p>

<div class="lesson-tip">
  Air boleh wujud sebagai ais, air cecair, atau wap air.
</div>', N'changesmatter.png', 2),
(N'LS064', N'ST333', N'Water Cycle Process', N'Proses Kitaran Air', N'<p>The water cycle is Earth’s endless water loop!</p>

<p>Water moves continuously between the Earth’s surface and the atmosphere.</p>

<ol>
  <li><strong>Evaporation</strong> — water from oceans, rivers, and lakes changes into water vapour and rises into the air.</li>
  <li><strong>Condensation</strong> — water vapour cools and forms clouds.</li>
  <li><strong>Precipitation</strong> — water falls back to Earth as rain.</li>
</ol>

<p>After rain falls, the water returns to rivers, lakes, and oceans. Then, the cycle begins again.</p>

<div class="lesson-tip">
  The water cycle repeats continuously in nature.
</div>', N'<p>Kitaran air ialah pusingan air yang berterusan di Bumi!</p>

<p>Air bergerak secara berterusan antara permukaan Bumi dan atmosfera.</p>

<ol>
  <li><strong>Penyejatan</strong> — air dari lautan, sungai, dan tasik berubah menjadi wap air dan naik ke udara.</li>
  <li><strong>Kondensasi</strong> — wap air menyejuk dan membentuk awan.</li>
  <li><strong>Presipitasi</strong> — air jatuh semula ke Bumi sebagai hujan.</li>
</ol>

<p>Selepas hujan turun, air kembali ke sungai, tasik, dan lautan. Kemudian, kitaran ini bermula semula.</p>

<div class="lesson-tip">
  Kitaran air berlaku secara berulang-ulang dalam alam semula jadi.
</div>', N'watercycle.mp4', 1),
(N'LS065', N'ST333', N'Importance of the Water Cycle', N'Kepentingan Kitaran Air', N'<p>Why does rain matter?</p>

<p>The water cycle is important because it gives living things a continuous supply of fresh water.</p>

<p>The water cycle helps to:</p>

<ul>
  <li>provide water for humans, animals, and plants,</li>
  <li>support farming and food production,</li>
  <li>fill rivers, lakes, and other water sources, and</li>
  <li>regulate Earth’s temperature.</li>
</ul>

<p>Without the water cycle, life on Earth would not be able to survive.</p>

<div class="lesson-tip">
  The water cycle keeps water moving and supports life on Earth.
</div>', N'<p>Mengapakah hujan penting?</p>

<p>Kitaran air penting kerana membekalkan air tawar secara berterusan kepada hidupan.</p>

<p>Kitaran air membantu untuk:</p>

<ul>
  <li>membekalkan air kepada manusia, haiwan, dan tumbuhan,</li>
  <li>menyokong pertanian dan penghasilan makanan,</li>
  <li>mengisi sungai, tasik, dan sumber air lain, dan</li>
  <li>mengawal suhu Bumi.</li>
</ul>

<p>Tanpa kitaran air, kehidupan di Bumi tidak dapat terus hidup.</p>

<div class="lesson-tip">
  Kitaran air memastikan air terus bergerak dan menyokong kehidupan di Bumi.
</div>', N'iwatercycle.png', 2),
(N'LS066', N'ST341', N'Moon Phases', N'Fasa Bulan', N'<p>The Moon looks different every night!</p>

<p>The Moon does not produce its own light. It reflects light from the <strong>Sun</strong>.</p>

<p>As the Moon moves around the Earth, we see different parts of its bright side.</p>

<p>These different shapes of the Moon are called <strong>Moon phases</strong>.</p>

<div class="lesson-tip">
  Moon phases happen because the Moon orbits Earth and reflects sunlight.
</div>', N'<p>Bulan kelihatan berbeza pada setiap malam!</p>

<p>Bulan tidak menghasilkan cahayanya sendiri. Bulan memantulkan cahaya daripada <strong>Matahari</strong>.</p>

<p>Apabila Bulan bergerak mengelilingi Bumi, kita melihat bahagian terang Bulan yang berbeza.</p>

<p>Bentuk Bulan yang berbeza ini dipanggil <strong>fasa Bulan</strong>.</p>

<div class="lesson-tip">
  Fasa Bulan berlaku kerana Bulan mengelilingi Bumi dan memantulkan cahaya Matahari.
</div>', N'moon.mp4', 1),
(N'LS067', N'ST341', N'Sequence of Moon Phases', N'Urutan Fasa Bulan', N'<p>The Moon follows a cycle that takes about 28 days.</p>

<p>During this cycle, the Moon appears to grow bigger and then become smaller again.</p>

<p>The sequence of Moon phases includes:</p>

<ol>
  <li><strong>New Moon</strong></li>
  <li><strong>Crescent Moon</strong></li>
  <li><strong>Half Moon</strong></li>
  <li><strong>Gibbous Moon</strong></li>
  <li><strong>Full Moon</strong></li>
</ol>

<p>After the Full Moon, the Moon appears to shrink back down in reverse order until it becomes a New Moon again.</p>

<div class="lesson-tip">
  The Moon phase cycle repeats about every 28 days.
</div>', N'<p>Bulan mengikuti satu kitaran yang mengambil masa kira-kira 28 hari.</p>

<p>Dalam kitaran ini, Bulan kelihatan semakin besar dan kemudian menjadi semakin kecil semula.</p>

<p>Urutan fasa Bulan termasuk:</p>

<ol>
  <li><strong>Anak bulan</strong></li>
  <li><strong>Bulan sabit</strong></li>
  <li><strong>Bulan separa</strong></li>
  <li><strong>Bulan hampir purnama</strong></li>
  <li><strong>Bulan purnama</strong></li>
</ol>

<p>Selepas Bulan purnama, Bulan kelihatan mengecil semula dalam urutan terbalik sehingga menjadi anak bulan semula.</p>

<div class="lesson-tip">
  Kitaran fasa Bulan berulang kira-kira setiap 28 hari.
</div>', N'moonphases.png', 2),
(N'LS068', N'ST341', N'Observing Moon Phases', N'Pemerhatian Fasa Bulan', N'<p>Does the Moon actually change shape?</p>

<p>No, it does not! The Moon is just showing us different parts of its bright side.</p>

<p>As the Moon orbits Earth, we see different lit portions of the Moon. This creates the different <strong>Moon phases</strong>.</p>

<p>The Moon phase cycle includes:</p>

<ol>
  <li><strong>New Moon</strong> — the Moon looks dark.</li>
  <li><strong>Crescent Moon</strong> — a small curved part of the Moon is visible.</li>
  <li><strong>Half Moon</strong> — half of the Moon appears bright.</li>
  <li><strong>Gibbous Moon</strong> — more than half of the Moon appears bright.</li>
  <li><strong>Full Moon</strong> — the whole bright side of the Moon is visible.</li>
</ol>

<p>The Moon takes about <strong>27 1/3 days</strong> to orbit Earth.</p>

<div class="lesson-tip">
  The Moon’s appearance depends on its position relative to the Sun and Earth.
</div>', N'<p>Adakah Bulan sebenarnya berubah bentuk?</p>

<p>Tidak! Bulan hanya menunjukkan bahagian terangnya yang berbeza kepada kita.</p>

<p>Apabila Bulan mengorbit Bumi, kita melihat bahagian Bulan yang disinari cahaya dalam bentuk yang berbeza. Inilah yang menghasilkan <strong>fasa Bulan</strong>.</p>

<p>Kitaran fasa Bulan termasuk:</p>

<ol>
  <li><strong>Anak Bulan</strong> — Bulan kelihatan gelap.</li>
  <li><strong>Bulan Sabit</strong> — sebahagian kecil Bulan yang melengkung kelihatan.</li>
  <li><strong>Bulan Separa</strong> — separuh Bulan kelihatan terang.</li>
  <li><strong>Bulan Hampir Purnama</strong> — lebih daripada separuh Bulan kelihatan terang.</li>
  <li><strong>Bulan Purnama</strong> — seluruh bahagian terang Bulan kelihatan.</li>
</ol>

<p>Bulan mengambil masa kira-kira <strong>27 1/3 hari</strong> untuk mengorbit Bumi.</p>

<div class="lesson-tip">
  Rupa Bulan bergantung kepada kedudukannya berbanding Matahari dan Bumi.
</div>', N'observemoon.png', 3),
(N'LS069', N'ST342', N'What Are Constellations?', N'Apakah Itu Buruj?', N'<p>The stars are like a giant <strong>connect-the-dots puzzle</strong> in the sky!</p>

<p>A <strong>constellation</strong> is a group of stars that appears to form a specific pattern in the night sky.</p>

<p>Some major constellations include:</p>

<ol>
  <li><strong>Big Dipper</strong> — looks like a ladle.</li>
  <li><strong>Orion</strong> — looks like a hunter with a belt.</li>
  <li><strong>Southern Cross</strong> — the smallest of these constellations and looks like a kite.</li>
  <li><strong>Scorpion</strong> — looks like a scorpion with a tail.</li>
</ol>

<p>People use constellations to recognise star patterns, directions, and seasons.</p>

<div class="lesson-activity">
  Can you spot <strong>Orion the hunter</strong> in the night sky?
</div>', N'<p>Bintang-bintang di langit seperti permainan <strong>sambung titik-titik</strong> yang sangat besar!</p>

<p><strong>Buruj</strong> ialah sekumpulan bintang yang kelihatan membentuk corak tertentu di langit malam.</p>

<p>Antara buruj utama termasuk:</p>

<ol>
  <li><strong>Biduk</strong> — kelihatan seperti senduk.</li>
  <li><strong>Belantik</strong> — kelihatan seperti seorang pemburu yang mempunyai tali pinggang.</li>
  <li><strong>Pari</strong> — buruj yang paling kecil antara buruj ini dan kelihatan seperti layang-layang.</li>
  <li><strong>Skorpio</strong> — kelihatan seperti kala jengking yang mempunyai ekor.</li>
</ol>

<p>Manusia menggunakan buruj untuk mengenal pasti corak bintang, arah, dan musim.</p>

<div class="lesson-activity">
  Bolehkah anda melihat <strong>Buruj Belantik</strong> di langit malam ini?
</div>', N'constellations.mp4', 1),
(N'LS070', N'ST342', N'Major Constellations', N'Buruj Utama', N'<p>The stars are like a giant <strong>connect-the-dots puzzle</strong> in the sky!</p>

<p>A <strong>constellation</strong> is a group of stars that appears to form a specific pattern in the night sky.</p>

<p>Some major constellations include:</p>

<ol>
  <li><strong>Big Dipper</strong> — looks like a ladle.</li>
  <li><strong>Orion</strong> — looks like a hunter with a belt.</li>
  <li><strong>Southern Cross</strong> — the smallest of these constellations and looks like a kite.</li>
  <li><strong>Scorpion</strong> — looks like a scorpion with a tail.</li>
</ol>

<p>People use constellations to recognise star patterns, directions, and seasons.</p>

<div class="lesson-activity">
  Can you spot <strong>Orion the hunter</strong> in the night sky?
</div>', N'<p>Bintang-bintang di langit seperti permainan <strong>sambung titik-titik</strong> yang sangat besar!</p>

<p><strong>Buruj</strong> ialah sekumpulan bintang yang kelihatan membentuk corak tertentu di langit malam.</p>

<p>Antara buruj utama termasuk:</p>

<ol>
  <li><strong>Biduk</strong> — kelihatan seperti senduk.</li>
  <li><strong>Belantik</strong> — kelihatan seperti seorang pemburu yang mempunyai tali pinggang.</li>
  <li><strong>Pari</strong> — buruj yang paling kecil antara buruj ini dan kelihatan seperti layang-layang.</li>
  <li><strong>Skorpio</strong> — kelihatan seperti kala jengking yang mempunyai ekor.</li>
</ol>

<p>Manusia menggunakan buruj untuk mengenal pasti corak bintang, arah, dan musim.</p>

<div class="lesson-activity">
  Bolehkah anda melihat <strong>Buruj Belantik</strong> di langit malam ini?
</div>', N'constellations.png', 2),
(N'LS071', N'ST342', N'Uses of Constellations', N'Kegunaan Buruj', N'<p>Constellations were like an ancient GPS and calendar!</p>

<p>Long ago, people observed constellations to help them in daily life.</p>

<p>Constellations were used to:</p>

<ul>
  <li>navigate at sea,</li>
  <li>find directions at night,</li>
  <li>identify seasons, and</li>
  <li>know the best times for planting and harvesting crops.</li>
</ul>

<p>Even before modern technology, the stars helped humans travel and plan their activities.</p>

<div class="lesson-tip">
  Constellations helped people with navigation, farming, and understanding seasons.
</div>', N'<p>Buruj seperti GPS dan kalendar zaman dahulu!</p>

<p>Pada zaman dahulu, manusia memerhatikan buruj untuk membantu kehidupan harian mereka.</p>

<p>Buruj digunakan untuk:</p>

<ul>
  <li>menentukan arah ketika belayar di laut,</li>
  <li>mencari arah pada waktu malam,</li>
  <li>mengenal pasti musim, dan</li>
  <li>mengetahui masa yang sesuai untuk menanam dan menuai tanaman.</li>
</ul>

<p>Sebelum teknologi moden wujud, bintang membantu manusia mengembara dan merancang aktiviti mereka.</p>

<div class="lesson-tip">
  Buruj membantu manusia dalam pelayaran, pertanian, dan mengenal pasti musim.
</div>', N'usesconstellations.png', 3),
(N'LS072', N'ST351', N'What Is a Pulley?', N'Apakah Itu Takal?', N'<p>How do we get a heavy flag to the top of a tall pole?</p>

<p>We use a simple machine called a <strong>pulley</strong>!</p>

<p>A pulley makes lifting loads easier by changing the direction of force.</p>

<p>A pulley consists of:</p>

<ul>
  <li>a <strong>grooved wheel</strong>,</li>
  <li>an <strong>axle</strong> that allows the wheel to rotate, and</li>
  <li>a <strong>rope</strong> that runs through the groove.</li>
</ul>

<p>When you pull the rope down, the load goes up.</p>

<div class="lesson-tip">
  A pulley helps us lift heavy loads more easily.
</div>', N'<p>Bagaimanakah kita menaikkan bendera yang berat ke puncak tiang yang tinggi?</p>

<p>Kita menggunakan mesin ringkas yang dipanggil <strong>takal</strong>!</p>

<p>Takal memudahkan kerja mengangkat beban dengan mengubah arah daya.</p>

<p>Takal terdiri daripada:</p>

<ul>
  <li><strong>roda beralur</strong>,</li>
  <li><strong>gandar</strong> yang membolehkan roda berputar, dan</li>
  <li><strong>tali</strong> yang melalui alur roda.</li>
</ul>

<p>Apabila anda menarik tali ke bawah, beban akan naik ke atas.</p>

<div class="lesson-tip">
  Takal membantu kita mengangkat beban berat dengan lebih mudah.
</div>', N'pulleyadv.mp4', 1),
(N'LS073', N'ST351', N'Types of Pulleys', N'Jenis-jenis Takal', N'<p>One pulley is strong, but many pulleys together can be even stronger!</p>

<p>There are three main types of pulleys:</p>

<ol>
  <li><strong>Fixed pulley</strong> — stays in one place, such as on a flagpole.</li>
  <li><strong>Movable pulley</strong> — moves together with the load.</li>
  <li><strong>Combined pulley</strong> — uses both fixed and movable pulleys to lift very heavy loads.</li>
</ol>

<p>Different pulley systems are used depending on how heavy the load is and how much force is needed.</p>

<div class="lesson-tip">
  Combined pulleys make it easier to lift very heavy objects.
</div>', N'<p>Satu takal sudah kuat, tetapi banyak takal yang digunakan bersama boleh menjadi lebih kuat!</p>

<p>Terdapat tiga jenis takal utama:</p>

<ol>
  <li><strong>Takal tetap</strong> — berada pada satu tempat, seperti pada tiang bendera.</li>
  <li><strong>Takal bergerak</strong> — bergerak bersama-sama dengan beban.</li>
  <li><strong>Takal bergabung</strong> — menggunakan takal tetap dan takal bergerak untuk mengangkat beban yang sangat berat.</li>
</ol>

<p>Sistem takal yang berbeza digunakan bergantung kepada berat beban dan jumlah daya yang diperlukan.</p>

<div class="lesson-tip">
  Takal bergabung memudahkan kerja mengangkat objek yang sangat berat.
</div>', N'typepulley.png', 2),
(N'LS074', N'ST351', N'Uses of Pulleys', N'Kegunaan Takal', N'<p>Pulleys are the <strong>strong helpers</strong> of the modern world!</p>

<p>We use pulleys in many places to lift or move heavy objects more easily.</p>

<p>Examples of pulley uses include:</p>

<ul>
  <li><strong>Cranes</strong> — used to lift heavy containers at ports.</li>
  <li><strong>Construction sites</strong> — used to move building materials to high floors.</li>
  <li><strong>Wells</strong> — used to draw water using a bucket and rope.</li>
  <li><strong>Fishing activities</strong> — used to pull in heavy fishing nets.</li>
</ul>

<p>Pulleys save time and reduce the effort needed to do heavy work.</p>

<div class="lesson-activity">
  Imagine building a skyscraper without pulleys. It would take a very long time!
</div>', N'<p>Pulleys are the <strong>strong helpers</strong> of the modern world!</p>

<p>We use pulleys in many places to lift or move heavy objects more easily.</p>

<p>Examples of pulley uses include:</p>

<ul>
  <li><strong>Cranes</strong> — used to lift heavy containers at ports.</li>
  <li><strong>Construction sites</strong> — used to move building materials to high floors.</li>
  <li><strong>Wells</strong> — used to draw water using a bucket and rope.</li>
  <li><strong>Fishing activities</strong> — used to pull in heavy fishing nets.</li>
</ul>

<p>Pulleys save time and reduce the effort needed to do heavy work.</p>

<div class="lesson-activity">
  Imagine building a skyscraper without pulleys. It would take a very long time!
</div>', N'usespulley.png', 3),
(N'LS075', N'ST352', N'Introduction to Gears', N'Pengenalan Gear', N'<p>What makes a bicycle go fast?</p>

<p>One important part that helps a bicycle move efficiently is the <strong>gear</strong>.</p>

<p>Gears are wheels with teeth around their edges. These teeth lock into each other and work together.</p>

<p>Gears are used to:</p>

<ul>
  <li>transfer motion from one part to another,</li>
  <li>change speed, and</li>
  <li>change the direction of movement.</li>
</ul>

<div class="lesson-tip">
  Gears help machines move smoothly and efficiently.
</div>', N'<p>Apakah yang membuatkan basikal bergerak dengan laju?</p>

<p>Salah satu bahagian penting yang membantu basikal bergerak dengan cekap ialah <strong>gear</strong>.</p>

<p>Gear ialah roda yang mempunyai gigi di sekeliling tepinya. Gigi gear ini saling bercantum dan bergerak bersama-sama.</p>

<p>Gear digunakan untuk:</p>

<ul>
  <li>memindahkan pergerakan dari satu bahagian ke bahagian lain,</li>
  <li>mengubah kelajuan, dan</li>
  <li>mengubah arah pergerakan.</li>
</ul>

<div class="lesson-tip">
  Gear membantu mesin bergerak dengan lancar dan cekap.
</div>', N'gears.mp4', 1),
(N'LS076', N'ST352', N'How Gears Work?', N'Cara Gear Berfungsi', N'<p>Some tools make work easier!</p>

<p>These tools are called <strong>simple machines</strong>.</p>

<p>There are seven types of simple machines:</p>

<ol>
  <li><strong>Lever</strong></li>
  <li><strong>Gear</strong></li>
  <li><strong>Pulley</strong></li>
  <li><strong>Screw</strong></li>
  <li><strong>Wheel and axle</strong></li>
  <li><strong>Inclined plane</strong></li>
  <li><strong>Wedge</strong></li>
</ol>

<p>Simple machines help us push, pull, lift, cut, or move objects more easily.</p>

<div class="lesson-tip">
  Simple machines reduce the effort needed to do work.
</div>', N'<p>Sesetengah alat menjadikan kerja lebih mudah!</p>

<p>Alat-alat ini dipanggil <strong>mesin ringkas</strong>.</p>

<p>Terdapat tujuh jenis mesin ringkas:</p>

<ol>
  <li><strong>Tuas</strong></li>
  <li><strong>Gear</strong></li>
  <li><strong>Takal</strong></li>
  <li><strong>Skru</strong></li>
  <li><strong>Roda dan gandar</strong></li>
  <li><strong>Satah condong</strong></li>
  <li><strong>Baji</strong></li>
</ol>

<p>Mesin ringkas membantu kita menolak, menarik, mengangkat, memotong, atau menggerakkan objek dengan lebih mudah.</p>

<div class="lesson-tip">
  Mesin ringkas mengurangkan daya yang diperlukan untuk melakukan kerja.
</div>', N'gearswork.png', 2),
(N'LS077', N'ST352', N'Applications of Gears', N'Aplikasi Gear', N'<p>Teamwork makes the dream work!</p>

<p>Simple machines can be combined to make a more useful machine.</p>

<p>A machine that uses two or more simple machines together is called a <strong>compound machine</strong>.</p>

<p>Compound machines are useful because they can perform more complex tasks than a single simple machine.</p>

<ul>
  <li>They make work easier.</li>
  <li>They save time and energy.</li>
  <li>They help us complete difficult tasks.</li>
</ul>

<div class="lesson-tip">
  A compound machine is made by combining two or more simple machines.
</div>', N'<p>Kerjasama menjadikan kerja lebih mudah!</p>

<p>Mesin ringkas boleh digabungkan untuk menghasilkan mesin yang lebih berguna.</p>

<p>Mesin yang menggunakan dua atau lebih mesin ringkas bersama-sama dipanggil <strong>mesin kompleks</strong>.</p>

<p>Mesin kompleks berguna kerana boleh melakukan tugas yang lebih rumit berbanding satu mesin ringkas sahaja.</p>

<ul>
  <li>Mesin kompleks menjadikan kerja lebih mudah.</li>
  <li>Mesin kompleks menjimatkan masa dan tenaga.</li>
  <li>Mesin kompleks membantu kita menyelesaikan tugas yang sukar.</li>
</ul>

<div class="lesson-tip">
  Mesin kompleks terhasil daripada gabungan dua atau lebih mesin ringkas.
</div>', N'gearsappication.png', 3),
(N'LS078', N'ST353', N'Types of Simple Machines', N'Jenis Mesin Ringkas', N'<p>Some tools make work easier!</p>

<p>These tools are called <strong>simple machines</strong>.</p>

<p>There are seven types of simple machines:</p>

<ol>
  <li><strong>Lever</strong></li>
  <li><strong>Gear</strong></li>
  <li><strong>Pulley</strong></li>
  <li><strong>Screw</strong></li>
  <li><strong>Wheel and axle</strong></li>
  <li><strong>Inclined plane</strong></li>
  <li><strong>Wedge</strong></li>
</ol>

<p>Simple machines help us push, pull, lift, cut, or move objects more easily.</p>

<div class="lesson-tip">
  Simple machines reduce the effort needed to do work.
</div>', N'<p>Sesetengah alat menjadikan kerja lebih mudah!</p>

<p>Alat-alat ini dipanggil <strong>mesin ringkas</strong>.</p>

<p>Terdapat tujuh jenis mesin ringkas:</p>

<ol>
  <li><strong>Tuas</strong></li>
  <li><strong>Gear</strong></li>
  <li><strong>Takal</strong></li>
  <li><strong>Skru</strong></li>
  <li><strong>Roda dan gandar</strong></li>
  <li><strong>Satah condong</strong></li>
  <li><strong>Baji</strong></li>
</ol>

<p>Mesin ringkas membantu kita menolak, menarik, mengangkat, memotong, atau menggerakkan objek dengan lebih mudah.</p>

<div class="lesson-tip">
  Mesin ringkas mengurangkan daya yang diperlukan untuk melakukan kerja.
</div>', N'simplemachine.png', 1),
(N'LS079', N'ST353', N'Machines in Daily Life', N'Mesin dalam Kehidupan Harian', N'<p>Simple machines are commonly used in everyday activitie!</p>

<p>These tools are called <strong>simple machines</strong>.</p>

<p>There are seven types of simple machines:</p>

<ol>
  <li><strong>Lever</strong></li>
  <li><strong>Gear</strong></li>
  <li><strong>Pulley</strong></li>
  <li><strong>Screw</strong></li>
  <li><strong>Wheel and axle</strong></li>
  <li><strong>Inclined plane</strong></li>
  <li><strong>Wedge</strong></li>
</ol>

<p>Simple machines help us push, pull, lift, cut, or move objects more easily.</p>

<div class="lesson-tip">
  Simple machines reduce the effort needed to do work.
</div>', N'<p>Sesetengah alat menjadikan kerja lebih mudah!</p>

<p>Alat-alat ini dipanggil <strong>mesin ringkas</strong>.</p>

<p>Terdapat tujuh jenis mesin ringkas:</p>

<ol>
  <li><strong>Tuas</strong></li>
  <li><strong>Gear</strong></li>
  <li><strong>Takal</strong></li>
  <li><strong>Skru</strong></li>
  <li><strong>Roda dan gandar</strong></li>
  <li><strong>Satah condong</strong></li>
  <li><strong>Baji</strong></li>
</ol>

<p>Mesin ringkas membantu kita menolak, menarik, mengangkat, memotong, atau menggerakkan objek dengan lebih mudah.</p>

<div class="lesson-tip">
  Mesin ringkas mengurangkan daya yang diperlukan untuk melakukan kerja.
</div>', N'machinedailylife.png', 2),
(N'LS080', N'ST354', N'Combining Simple Machines', N'Gabungan Mesin Ringkas', N'<p>Teamwork makes the dream work!</p>

<p>Simple machines can be combined to make a more useful machine.</p>

<p>A machine that uses two or more simple machines together is called a <strong>compound machine</strong>.</p>

<p>Compound machines are useful because they can perform more complex tasks than a single simple machine.</p>

<ul>
  <li>They make work easier.</li>
  <li>They save time and energy.</li>
  <li>They help us complete difficult tasks.</li>
</ul>

<div class="lesson-tip">
  A compound machine is made by combining two or more simple machines.
</div>', N'<p>Kerjasama menjadikan kerja lebih mudah!</p>

<p>Mesin ringkas boleh digabungkan untuk menghasilkan mesin yang lebih berguna.</p>

<p>Mesin yang menggunakan dua atau lebih mesin ringkas bersama-sama dipanggil <strong>mesin kompleks</strong>.</p>

<p>Mesin kompleks berguna kerana boleh melakukan tugas yang lebih rumit berbanding satu mesin ringkas sahaja.</p>

<ul>
  <li>Mesin kompleks menjadikan kerja lebih mudah.</li>
  <li>Mesin kompleks menjimatkan masa dan tenaga.</li>
  <li>Mesin kompleks membantu kita menyelesaikan tugas yang sukar.</li>
</ul>

<div class="lesson-tip">
  Mesin kompleks terhasil daripada gabungan dua atau lebih mesin ringkas.
</div>', N'combinesimplemachine.png', 1),
(N'LS081', N'ST354', N'Examples of Compound Machines', N'Contoh Mesin Kompleks', N'<p>Compound machines are everywhere around us!</p>

<p>Many objects we use every day are made from a combination of simple machines.</p>

<p>Examples of compound machines include:</p>

<ol>
  <li><strong>Bicycle</strong> — uses gears, wheels, and levers.</li>
  <li><strong>Pencil sharpener</strong> — uses gears, handles as levers, and wedges as blades.</li>
  <li><strong>Watch</strong> — uses many tiny gears and screws.</li>
</ol>

<p>These machines combine different simple machines to perform useful tasks.</p>

<div class="lesson-tip">
  Compound machines make daily activities easier by combining several simple machines.
</div>', N'<p>Mesin kompleks ada di mana-mana di sekeliling kita!</p>

<p>Banyak objek yang kita gunakan setiap hari terhasil daripada gabungan mesin ringkas.</p>

<p>Contoh mesin kompleks termasuk:</p>

<ol>
  <li><strong>Basikal</strong> — menggunakan gear, roda, dan tuas.</li>
  <li><strong>Pengasah pensel</strong> — menggunakan gear, pemegang sebagai tuas, dan baji sebagai bilah.</li>
  <li><strong>Jam tangan</strong> — menggunakan banyak gear kecil dan skru.</li>
</ol>

<p>Mesin-mesin ini menggabungkan mesin ringkas yang berbeza untuk menjalankan tugas yang berguna.</p>

<div class="lesson-tip">
  Mesin kompleks menjadikan aktiviti harian lebih mudah dengan menggabungkan beberapa mesin ringkas.
</div>', N'compoundmachine.png', 2);

insert into XPAction values
(N'XP001', N'Complete Lesson', N'Selesaikan Pelajaran', 10),
(N'XP002', N'Complete Virtual Lab', N'Selesaikan Makmal Maya', 15),
(N'XP003', N'Attempt Practice Quiz', N'Jawab Kuiz Latihan', 10),
(N'XP004', N'Pass Unit Quiz', N'Lulus Kuiz Unit', 25),
(N'XP005', N'Score 80% or Above', N'Skor 80% ke Atas', 20),
(N'XP006', N'Complete Level Assessment', N'Selesaikan Penilaian Tahap', 40),
(N'XP007', N'Join Forum Discussion', N'Sertai Perbincangan Forum', 5),
(N'XP008', N'Attend Live Session', N'Hadiri Sesi Langsung', 15),
(N'XP009', N'Complete Study Plan Task', N'Selesaikan Tugasan Pelan Belajar', 10);

insert into ConfigurationSetting values
(N'CONFIG001', N'Passing Mark Percentage for Unit', 50, '2026-02-15 10:08:51'),
(N'CONFIG002', N'Passing Mark for Level', 70, '2026-02-15 10:09:48'),
(N'CONFIG003', N'Leaderboard Top Count', 10, '2026-02-15 10:10:40'),
(N'CONFIG004', N'Easy Question Mark', 1, '2026-02-15 10:11:23'),
(N'CONFIG005', N'Medium Question Mark', 3, '2026-02-15 10:12:20'),
(N'CONFIG006', N'Hard Question Mark', 5, '2026-02-15 10:13:10'),
(N'CONFIG007', N'Suspicious Login Attempt', 3, '2026-02-15 10:14:27'),
(N'CONFIG008', N'Account Lock Duration (Minutes)', 30, '2026-02-15 10:15:32'),
(N'CONFIG009', N'Password Minimum Length', 8, '2026-02-15 10:16:09'),
(N'CONFIG010', N'Maximum Students Per Session', 50, '2026-02-15 10:20:54'),
(N'CONFIG011', N'Consultation Session Duration (Minutes)', 60, '2026-02-15 10:21:59');

insert into VirtualLab values
(N'LAB001', N'UN102', N'Magnetic Forces Explorer', N'Penjelajah Daya Magnet', N'Test different magnet poles and identify which objects are attracted to magnets.', N'Uji kutub magnet yang berbeza dan kenal pasti objek yang ditarik oleh magnet.', N'1. Select two magnets and drag them together to test the same poles (N-N or S-S) and different poles (N-S)
2. Observe if the magnets push away (repel) or pull together (attract)
3. Drag a magnet toward objects like a nail, pencil, and paperclip
4. Sort the objects into "Magnetic" and "Non-magnetic" categories', N'1. Pilih dua magnet dan seretnya bersama-sama untuk menguji kutub yang sama (U-U atau S-S) dan kutub yang berbeza (U-S)
2. Perhatikan jika magnet menolak atau menarik satu sama lain
3. Seret magnet ke arah objek seperti paku, pensel, dan klip kertas
4. Kelaskan objek ke dalam kategori "Bermagnet" dan "Tidak Bermagnet"', N'Drag-and-drop Simulation', N'Easy', '2026-01-01 00:00:00'),
(N'LAB002', N'UN103', N'The Great Soak Challenge', N'Cabaran Serapan Hebat', N'Test the water absorption capacity of different materials', N'Uji keupayaan penyerapan air bagi bahan yang berbeza', N'1. Select a material such as a sponge, tissue paper, or a plastic coin
2. Use the virtual dropper to place three drops of colored water on the material
3. Observe if the water is absorbed or if it remains on the surface
4. Compare two absorbent materials to see which one soaks up more water', N'1. Pilih bahan seperti span, kertas tisu, atau duit syiling plastik
2. Gunakan penitis maya untuk menitiskan tiga titik air berwarna pada bahan tersebut
3. Perhatikan sama ada air diserap atau kekal di atas permukaan
4. Bandingkan dua bahan yang menyerap air untuk melihat mana yang menyerap lebih banyak air', N'Observation Lab', N'Easy', '2026-01-01 00:00:00'),
(N'LAB003', N'UN201', N'Journey of a Sandwich', N'Perjalanan Sekeping Sandwic', N'Follow food as it is broken down and travels through the digestive system', N'Ikuti perjalanan makanan semasa ia dihancurkan dan melalui sistem pencernaan', N'1. Click the sandwich to begin mechanical digestion in the mouth using teeth and saliva
2. Drag the food bolus down the esophagus into the stomach
3. Watch the food turn into a liquid state in the stomach and move to the intestines
4. Identify where nutrients are absorbed and follow the waste until it reaches the anus', N'1. Klik pada sandwic untuk memulakan pencernaan mekanikal di dalam mulut menggunakan gigi dan air liur
2. Seret bolus makanan menuruni esofagus ke dalam perut
3. Perhatikan makanan berubah menjadi cecair di dalam perut dan bergerak ke usus
4. Kenal pasti di mana nutrien diserap dan ikuti sisa makanan sehingga sampai ke dubur', N'Process Animation', N'Medium', '2026-01-01 00:00:00'),
(N'LAB004', N'UN202', N'Sink or Float Master', N'Pakar Timbul atau Tenggelam', N'Discover how objects react to water and how to make sinking objects float', N'Temui bagaimana objek bertindak balas terhadap air dan cara membuat objek yang tenggelam menjadi timbul', N'1. Pick an object like a marble or a cork and drop it into the water tank
2. Observe if the object sinks to the bottom or stays at the top
3. Add salt or sugar to the water to increase its density
4. Watch if the sinking objects begin to float as the water becomes denser', N'1. Pilih objek seperti guli atau gabus dan jatuhkan ke dalam tangki air
2. Perhatikan sama ada objek itu tenggelam ke dasar atau kekal di atas permukaan
3. Tambah garam atau gula ke dalam air untuk meningkatkan ketumpatannya
4. Perhatikan jika objek yang tenggelam mula timbul apabila air menjadi lebih tumpat', N'Variable Experiment', N'Medium', '2026-01-01 00:00:00'),
(N'LAB005', N'UN203', N'The Litmus Test', N'Ujian Kertas Litmus', N'Use litmus paper to identify acidic, alkaline, and neutral substances', N'Gunakan kertas litmus untuk mengenal pasti bahan berasid, beralkali, dan neutral', N'1. Select a substance to test, such as lemon juice, soap, or salt water
2. Drag a strip of blue litmus paper into the substance and check for a color change
3. Drag a strip of red litmus paper into the same substance and check for a color change
4. Classify the substance as acidic (blue turns red), alkaline (red turns blue), or neutral (no change)', N'1. Pilih bahan untuk diuji, seperti jus limau, sabun, atau air garam
2. Seret sehelai kertas litmus biru ke dalam bahan dan perhatikan perubahan warna
3. Seret sehelai kertas litmus merah ke dalam bahan yang sama dan perhatikan perubahan warna
4. Kelaskan bahan tersebut sebagai berasid (biru jadi merah), beralkali (merah jadi biru), atau neutral (tiada perubahan)', N'Sandbox Simulator', N'Medium', '2026-01-01 00:00:00'),
(N'LAB006', N'UN301', N'Blood Flow Simulator', N'Simulator Aliran Darah', N'Visualize the path of oxygen-rich and carbon dioxide-rich blood in the human body', N'Visualkan laluan darah yang kaya dengan oksigen dan kaya dengan karbon dioksida dalam badan manusia', N'1. Click the lungs to pick up oxygen and turn the blood red
2. Drag the oxygen-rich blood to the heart to be pumped to the rest of the body
3. Watch the blood deliver oxygen to the body parts and turn blue as it picks up carbon dioxide
4. Move the carbon dioxide-rich blood back to the heart and then to the lungs to be exhaled', N'1. Klik pada peparu untuk mengambil oksigen dan menukarkan warna darah menjadi merah
2. Seret darah yang kaya dengan oksigen ke jantung untuk dipam ke seluruh bahagian badan
3. Perhatikan darah menghantar oksigen ke bahagian badan dan bertukar menjadi biru setelah mengambil karbon dioksida
4. Gerakkan darah yang kaya dengan karbon dioksida kembali ke jantung dan kemudian ke peparu untuk dihembus keluar', N'Process Animation', N'Hard', '2026-01-01 00:00:00'),
(N'LAB007', N'UN302', N'Power Up: Circuit Lab', N'Jana Kuasa: Makmal Litar', N'Build and compare series and parallel electrical circuits', N'Bina dan bandingkan litar elektrik bersiri dan selari', N'1. Place a dry cell, a switch, and two bulbs on the board
2. Use wires to connect the components in a single path to create a series circuit
3. Change the wiring to create multiple paths for a parallel circuit
4. Flip the switches and compare the brightness of the bulbs in both circuits', N'1. Letakkan sel kering, suis, dan dua mentol di atas papan
2. Gunakan wayar untuk menyambungkan komponen dalam satu laluan untuk membina litar bersiri
3. Tukar pendawaian untuk membina beberapa laluan bagi litar selari
4. Petik suis dan bandingkan kecerahan mentol dalam kedua-dua litar tersebut', N'Sandbox Simulator', N'Hard', '2026-01-01 00:00:00'),
(N'LAB008', N'UN303', N'Matter State Changer', N'Penukar Keadaan Jirim', N'Explore how water changes between solid, liquid, and gas states', N'Terokai bagaimana air berubah antara keadaan pepejal, cecair, dan gas', N'1. Place ice cubes (solid) into a virtual beaker
2. Turn on the Bunsen burner to heat the ice and observe it melting into liquid water
3. Increase the heat until the water boils and turns into gas (evaporation)
4. Use a cool surface to watch the gas turn back into liquid droplets (condensation)', N'1. Letakkan ketulan ais (pepejal) ke dalam bikar maya
2. Hidupkan penunu Bunsen untuk memanaskan ais dan perhatikan ia melebur menjadi cecair air
3. Tingkatkan haba sehingga air mendidih dan berubah menjadi gas (penyejatan)
4. Gunakan permukaan sejuk untuk melihat gas berubah kembali menjadi titisan cecair (kondensasi)', N'Thermal Simulation', N'Medium', '2026-01-01 00:00:00');
GO

/* =========================================================
   Insert sample/test data after constants
   ========================================================= */

-- ScienceBuddy Sample Data

insert into [User] values
(N'U001', N'najihah01', N'Admin123', N'admin@sciencebuddy.edu', N'Admin', N'EN', N'Active'),
(N'U002', N'Aiman', N'Aiman123', N'aiman@gmail.com', N'Student', N'BM', N'Active'),
(N'U003', N'siti', N'Siti1234', N'siti@gmail.com', N'Student', N'EN', N'Active'),
(N'U004', N'abu', N'Abu12345', N'abu@gmail.com', N'Student', N'BM', N'Deleted'),
(N'U005', N'aminah', N'Aminah12', N'aminah@gmail.com', N'Parent', N'EN', N'Active'),
(N'U006', N'hassan', N'Hassan45', N'hassan@gmail.com', N'Parent', N'BM', N'Active'),
(N'U007', N'laila', N'Laila789', N'laila@gmail.com', N'Parent', N'EN', N'Deleted'),
(N'U008', N'zara', N'Zara1234', N'zara@gmail.com', N'Teacher', N'BM', N'Active'),
(N'U009', N'reza', N'Reza1234', N'reza@gmail.com', N'Teacher', N'EN', N'Active'),
(N'U010', N'nurul', N'Nurul123', N'nurul@gmail.com', N'Teacher', N'BM', N'Blocked'),
(N'U011', N'danial', N'Danial1', N'danial@gmail.com', N'Student', N'EN', N'Active'),
(N'U012', N'maya', N'Maya2026', N'maya@gmail.com', N'Student', N'BM', N'Active'),
(N'U013', N'faris', N'Faris123', N'faris@gmail.com', N'Student', N'EN', N'Active'),
(N'U014', N'hana', N'Hana2026', N'hana@gmail.com', N'Student', N'BM', N'Active'),
(N'U015', N'iqbal', N'Iqbal123', N'iqbal@gmail.com', N'Student', N'EN', N'Active'),
(N'U016', N'qistina', N'Qisti123', N'qistina@gmail.com', N'Student', N'BM', N'Active'),
(N'U017', N'rayyan', N'Rayyan1', N'rayyan@gmail.com', N'Student', N'EN', N'Active'),
(N'U018', N'sofia', N'Sofia123', N'sofia@gmail.com', N'Student', N'BM', N'Blocked'),
(N'U019', N'hakim', N'Hakim123', N'hakim@gmail.com', N'Parent', N'BM', N'Active'),
(N'U020', N'ana', N'Ana20266', N'ananawai@gmail.com', N'Parent', N'BM', N'Active'),
(N'U021', N'hisyam', N'Hisyam12', N'hisyamhamdan@gmail.com', N'Parent', N'BM', N'Active'),
(N'U022', N'nurun', N'Nurun999', N'nurun99@gmail.com', N'Teacher', N'EN', N'Active'),
(N'U023', N'amin', N'Amin9988', N'amin@gmail.com', N'Teacher', N'EN', N'Active'),
(N'U024', N'balqis', N'Balqis999', N'balbal@gmail.com', N'Teacher', N'BM', N'Deleted');

insert into Student values
(N'S001', N'U002', N'Aiman Harris Bin Zulkarnain', N'0122068743', N'Aiman', N'LV001', 0, N'P001', N'ABX123'),
(N'S002', N'U003', N'Siti Rahimah Binti Hassan', N'0126559145', N'Siti', N'LV001', 120, N'P004', N'SRT456'),
(N'S003', N'U004', N'Zara Binti Zaidi', N'0172008562', N'Zara', N'LV003', 0, N'P006', N'HZQ789'),
(N'S004', N'U011', N'Danial Hakimi Bin Azlan', N'0111111222', N'Danial', N'LV001', 650, N'P001', N'DAN321'),
(N'S005', N'U012', N'Maya Sofea Binti Azhar', N'0112222333', N'Maya', N'LV002', 980, N'P003', N'MAY654'),
(N'S006', N'U013', N'Faris Iman Bin Fauzi', N'0113333444', N'Faris', N'LV003', 2450, N'P004', N'FAR987'),
(N'S007', N'U014', N'Hana Aleesya Binti Harun', N'0114444555', N'Hana', N'LV001', 80, N'P005', N'HAN135'),
(N'S008', N'U015', N'Muhammad Iqbal Bin Irfan', N'0115555666', N'Iqbal', N'LV001', 45, N'P002', N'IQB246'),
(N'S009', N'U016', N'Qistina Batrisyia Binti Kamal', N'0116666777', N'Qis', N'LV002', 760, N'P006', N'QIS357'),
(N'S010', N'U017', N'Rayyan Danish Bin Ridzuan', N'0117777888', N'Rayyan', N'LV002', 890, N'P003', N'RAY468'),
(N'S011', N'U018', N'Sofia Damia Binti Salleh', N'0118888999', N'Sofia', N'LV001', 0, N'P005', N'SOF579');

insert into Parent values
(N'P001', N'U005', N'Aminah Binti Yusof', N'0134444676'),
(N'P002', N'U006', N'Hassan Bin Zainal', N'0198888900'),
(N'P003', N'U007', N'Laila Binti Mahfuz', N'0186455333'),
(N'P004', N'U019', N'Hakim Bin Osman', N'0134567890'),
(N'P005', N'U020', N'Norhazana Binti Nawai', N'0134567765'),
(N'P006', N'U021', N'Hisyam Bin Hamdan', N'0198273654');

insert into Teacher values
(N'T001', N'U008', N'Zara Natasya Binti Karim', N'0112222333', N'B.Sc Biology (UTM)', N'Experienced science teacher with 10 years in secondary education.', N'Images/Teacher/cert_zara.pdf', N'Pending', NULL),
(N'T002', N'U009', N'Reza Hakim Bin Malik', N'0145555666', N'M.Ed Science Education (UM)', N'Passionate about inquiry-based learning and student engagement.', N'Images/Teacher/cert_reza.pdf', N'Certified', '2026-01-01 00:00:00'),
(N'T003', N'U010', N'Nurul Izzah Binti Azmi', N'0178888999', N'B.Ed (Hons) Chemistry (UPM)', N'Focused on helping student grasp foundational concepts.', N'Images/Teacher/cert_izzah.pdf', N'Not Certified', '2026-01-02 00:00:00'),
(N'T004', N'U022', N'Nurun binti Azmi', N'0178889000', N'B.Ed (Hons) Science Education (UPSI)', N'Dedicated to nurturing students'' interest in science through inquiry-based learning and exploration.', N'Images/Teacher/cert_nurun.pdf', N'Certified', '2026-01-03 00:00:00'),
(N'T005', N'U023', N'Muhammad Amin bin Hakim', N'0125656788', N'B.Ed (Hons) Teaching English as a Second Language (TESL)', N'Specialises in bilingual science instruction to help students understand concepts in both English and Bahasa Melayu.', N'Images/Teacher/cert_amin.pdf', N'Certified', '2026-01-04 00:00:00'),
(N'T006', N'U024', N'Balqis binti Suhaimi', N'0156767322', N'B.Ed (Hons) Primary Education (UM)', N'Committed to creating a supportive and inclusive learning environment that encourages curiosity and critical thinking.', N'Images/Teacher/cert_balqis.pdf', N'Certified', '2026-01-05 00:00:00');

insert into StudentParent values
(N'SP001', N'S001', N'P001', N'Mother'),
(N'SP002', N'S002', N'P002', N'Father'),
(N'SP003', N'S003', N'P003', N'Mother'),
(N'SP004', N'S004', N'P001', N'Mother'),
(N'SP005', N'S005', N'P002', N'Father'),
(N'SP006', N'S007', N'P001', N'Guardian'),
(N'SP007', N'S009', N'P002', N'Father'),
(N'SP008', N'S010', N'P001', N'Mother'),
(N'SP009', N'S011', N'P005', N'Mother'),
(N'SP010', N'S011', N'P006', N'Father');

insert into Enrollment values
(N'EN001', N'S001', N'LV001', '2026-01-06 00:00:00', N'Active'),
(N'EN002', N'S002', N'LV001', '2026-05-01 00:00:00', N'Active'),
(N'EN003', N'S003', N'LV003', '2026-10-03 00:00:00', N'Deleted'),
(N'EN004', N'S004', N'LV001', '2026-01-04 00:00:00', N'Active'),
(N'EN005', N'S005', N'LV001', '2026-01-02 00:00:00', N'Completed'),
(N'EN006', N'S005', N'LV002', '2026-01-05 00:00:00', N'Active'),
(N'EN007', N'S006', N'LV001', '2026-01-01 00:00:00', N'Completed'),
(N'EN008', N'S006', N'LV002', '2026-01-03 00:00:00', N'Completed'),
(N'EN009', N'S006', N'LV003', '2026-01-06 00:00:00', N'Active'),
(N'EN010', N'S007', N'LV001', '2026-05-20 00:00:00', N'Active'),
(N'EN011', N'S008', N'LV001', '2026-01-04 00:00:00', N'Inactive'),
(N'EN012', N'S009', N'LV002', '2026-01-05 00:00:00', N'Active'),
(N'EN013', N'S010', N'LV002', '2026-10-05 00:00:00', N'Active'),
(N'EN014', N'S011', N'LV001', '2026-01-06 00:00:00', N'Blocked');

insert into StudentBadge values
(N'SB001', N'S002', N'B001', '2026-05-16 10:00:00'),
(N'SB002', N'S002', N'B003', '2026-05-17 11:30:00'),
(N'SB003', N'S004', N'B001', '2026-02-04 09:20:00'),
(N'SB004', N'S004', N'B002', '2026-04-04 14:10:00'),
(N'SB005', N'S004', N'B003', '2026-05-04 15:00:00'),
(N'SB006', N'S004', N'B004', '2026-08-04 12:00:00'),
(N'SB007', N'S004', N'B005', '2026-04-15 16:30:00'),
(N'SB008', N'S005', N'B001', '2026-05-02 10:00:00'),
(N'SB009', N'S005', N'B002', '2026-08-02 11:00:00'),
(N'SB010', N'S005', N'B003', '2026-10-02 13:00:00'),
(N'SB011', N'S005', N'B004', '2026-02-15 14:00:00'),
(N'SB012', N'S005', N'B005', '2026-02-20 15:00:00'),
(N'SB013', N'S005', N'B006', '2026-02-28 02:30:00'),
(N'SB014', N'S006', N'B001', '2026-02-01 09:00:00'),
(N'SB015', N'S006', N'B002', '2026-04-01 09:30:00'),
(N'SB016', N'S006', N'B003', '2026-06-01 10:00:00'),
(N'SB017', N'S006', N'B004', '2026-08-01 10:30:00'),
(N'SB018', N'S006', N'B005', '2026-06-15 02:00:00'),
(N'SB019', N'S006', N'B006', '2026-01-28 09:00:00'),
(N'SB020', N'S006', N'B007', '2026-01-29 10:00:00'),
(N'SB021', N'S009', N'B009', '2026-10-06 16:15:00'),
(N'SB022', N'S010', N'B010', '2026-12-06 09:00:00');

insert into Quiz values
(N'Q001', NULL, N'UN101', N'My Super Senses Challenge', N'Cabaran Deria Hebat Saya', N'Unit', NULL, N'U001', '2026-01-01 10:00:00', N'BOTH'),
(N'Q002', NULL, N'UN102', N'Magnet Magic Adventure', N'Kembara Magnet Ajaib', N'Unit', NULL, N'U001', '2026-01-02 12:59:21', N'BOTH'),
(N'Q003', NULL, N'UN103', N'The Great Soak-Off', N'Hero Penyerapan Hebat', N'Unit', NULL, N'U001', '2026-01-02 17:34:22', N'BOTH'),
(N'Q004', NULL, N'UN104', N'Earth Explorers: Land & Soil', N'Penjelajah Bumi: Tanah & Muka Bumi', N'Unit', NULL, N'U001', '2026-01-03 01:05:26', N'BOTH'),
(N'Q005', NULL, N'UN105', N'Shape Builder Academy', N'Akademi Pakar Bentuk', N'Unit', NULL, N'U001', '2026-01-03 01:15:22', N'BOTH'),
(N'Q006', NULL, N'UN201', N'Humans Detective', N'Pakar Manusia', N'Unit', NULL, N'U001', '2026-01-03 01:26:22', N'BOTH'),
(N'Q007', NULL, N'UN202', N'Sink or Float Mystery', N'Misteri Timbul atau Tenggelam', N'Unit', NULL, N'U001', '2026-01-03 09:30:00', N'BOTH'),
(N'Q008', NULL, N'UN203', N'Acid and Alkali', N'Asid dan Alkali', N'Unit', NULL, N'U001', '2026-01-04 14:20:04', N'BOTH'),
(N'Q009', NULL, N'UN204', N'Galactic Space Tour', N'Jelajah Galaksi Sistem Suria', N'Unit', NULL, N'U001', '2026-01-04 14:30:21', N'BOTH'),
(N'Q010', NULL, N'UN205', N'Pulley Power Mission', N'Misi Kuasa Takal', N'Unit', NULL, N'U001', '2026-01-04 14:33:09', N'BOTH'),
(N'Q011', NULL, N'UN301', N'Body Systems: Bones & Blood', N'Sistem Badan: Tulang & Darah', N'Unit', NULL, N'U001', '2026-01-05 09:20:30', N'BOTH'),
(N'Q012', NULL, N'UN302', N'Circuit Master: Power Up!', N'Pakar Litar: Jana Kuasa!', N'Unit', NULL, N'U001', '2026-01-06 10:00:22', N'BOTH'),
(N'Q013', NULL, N'UN303', N'The State-Shifter Lab', N'Makmal Perubahan Jirim', N'Unit', NULL, N'U001', '2026-01-06 10:00:22', N'BOTH'),
(N'Q014', NULL, N'UN304', N'Night Sky Stargazer', N'Penjejak Bintang & Fasa Bulan', N'Unit', NULL, N'U001', '2026-01-06 10:00:22', N'BOTH'),
(N'Q015', NULL, N'UN305', N'Simple & Compound Machine Master', N'Pakar Mesin Ringkas & Kompleks', N'Unit', NULL, N'U001', '2026-01-07 13:00:22', N'BOTH'),
(N'Q016', N'LV001', NULL, N'Beginner Science Challenge', N'Cabaran Sains Pemula', N'Level', NULL, N'U001', '2026-01-07 13:00:22', N'BOTH'),
(N'Q017', N'LV002', NULL, N'Intermediate Science Challenge', N'Cabaran Sains Pertengahan', N'Level', NULL, N'U001', '2026-01-07 13:00:22', N'BOTH'),
(N'Q018', N'LV003', NULL, N'Advanced Science Challenge', N'Cabaran Sains Lanjutan', N'Level', NULL, N'U001', '2026-01-07 13:00:22', N'BOTH'),
(N'Q019', N'LV001', N'UN102', NULL, N'Kegunaan Magnet', N'Practice', N'Approved', N'U022', '2026-01-02 12:01:21', N'BM'),
(N'Q020', N'LV003', N'UN301', NULL, N'Kuiz Unit Sistem Rangka Manusia', N'Practice', N'Rejected', N'U022', '2026-01-05 09:14:10', N'BM'),
(N'Q021', N'LV002', N'UN202', NULL, N'Aplikasi Ketumpatan Dalam Kehidupan', N'Practice', N'Pending', N'U022', '2026-01-15 15:00:00', N'BM'),
(N'Q022', N'LV002', N'UN204', N'Members of the Solar System Unit Quiz', NULL, N'Practice', N'Approved', N'U022', '2026-04-01 15:12:00', N'EN'),
(N'Q023', N'LV003', N'UN305', N'Understand Compound Machines', NULL, N'Practice', N'Approved', N'U022', '2026-04-01 20:11:12', N'EN'),
(N'Q024', N'LV002', N'UN202', N'Density', NULL, N'Practice', N'Approved', N'U023', '2026-01-03 13:00:04', N'EN');

insert into Material values
(N'M001', N'ST111', N'U022', N'Human Sense Notes', N'PDF', N'humansense.pdf', N'This material introduces the five human senses and their functions. Students will learn how sight, hearing, smell, taste and touch help humans understand their surroundings.', '2026-01-28 00:00:00', N'Pending', NULL, N'EN'),
(N'M002', N'ST122', N'U023', N'Bentuk-Bentuk Magnet', N'Image', N'magnetbentuk.png', N'Bahan pembelajaran ini memperkenalkan pelbagai bentuk magnet seperti magnet ladam, magnet bar dan magnet silinder serta kegunaannya dalam kehidupan harian.', '2025-01-04 00:00:00', N'Approved', '2025-03-04 00:00:00', N'BM'),
(N'M003', N'ST313', N'U022', N'Blood Circulatory System Video Lesson', N'Video', N'circulatory_system.mp4', N'This video explains the functions of the heart, blood vessels and blood circulation throughout the human body using simple animations and examples.', '2025-09-18 00:00:00', N'Pending', NULL, N'EN'),
(N'M004', N'ST333', N'U022', N'Video Animasi Kitaran Air', N'Video', N'water_cycle.mp4', N'Video ini menerangkan proses kitaran air termasuk penyejatan, pemeluwapan, hujan dan pengumpulan air dalam alam sekitar.', '2025-01-10 00:00:00', N'Approved', '2025-10-20 00:00:00', N'BM'),
(N'M005', N'ST341', N'U022', N'Moon Phases Interactive Slides', N'PPTX', N'moon_phases.pptx', N'This interactive presentation helps students understand the different phases of the moon and how the moon''s appearance changes throughout the month.', '2026-01-03 00:00:00', N'Approved', '2026-03-20 00:00:00', N'EN'),
(N'M006', N'ST311', N'U022', N'Rajah Sistem Rangka Manusia', N'Image', N'skeletal_system.png', N'Rajah berlabel ini menunjukkan struktur utama sistem rangka manusia dan fungsi setiap tulang dalam menyokong pergerakan badan.', '2026-01-01 00:00:00', N'Rejected', '2026-01-01 00:00:00', N'BM'),
(N'M007', N'ST351', N'U023', N'How Pulleys Work', N'Video', N'pulley_demo.mp4', N'This demonstration video explains how pulleys reduce the amount of force needed to lift heavy objects through practical examples.', '2026-06-16 00:00:00', N'Pending', NULL, N'EN'),
(N'M008', N'ST153', N'U024', N'Why Block Shapes Matter', N'PPTX', N'block_shapes_notes.pptx', N'This material explains how different block shapes influence the stability, strength and balance of structures. Students will learn how shape selection affects the design and construction of buildings and other everyday structures.', '2026-01-20 00:00:00', N'Approved', '2026-02-02 00:00:00', N'ENG'),
(N'M009', N'ST132', N'U024', N'Aplikasi Bahan Penyerap Air Dalam Kehidupan Harian', N'PPTX', N'absorbent_materials.pptx', N'Pembentangan ini menunjukkan penggunaan bahan penyerap air dalam produk harian seperti tisu, span dan lampin pakai buang.', '2026-01-18 00:00:00', N'Approved', '2026-01-19 00:00:00', N'EN'),
(N'M010', N'ST123', N'U023', N'Magnet Experiment Demonstration', N'Video', N'magnet_demo.mp4', N'Students will observe attraction and repulsion forces between magnets through simple experiments and guided observations.', '2025-06-12 00:00:00', N'Rejected', '2025-12-12 00:00:00', N'EN'),
(N'M011', N'ST113', N'U022', N'Using Human Senses in Daily Life', N'Video', N'human_senses_video.mp4', N'This video demonstrates how human senses are used in everyday activities such as crossing roads, identifying food and recognizing sounds.', '2026-12-20 00:00:00', N'Approved', '2026-01-01 00:00:00', N'EN'),
(N'M012', N'ST312', N'U024', N'Jenis-Jenis Sendi Manusia', N'Image', N'joints.png', N'Bahan pembelajaran ini menerangkan pelbagai jenis sendi manusia seperti sendi engsel, sendi bebola dan soket serta fungsinya dalam pergerakan badan.', '2025-09-07 00:00:00', N'Rejected', '2025-12-09 00:00:00', N'BM');

insert into Forum values
(N'F001', N'U002', N'Can someone explain how gears work in a super simple way?', N'I am trying to answer the second quiz in Unit 3 but would like to see some examples.', N'Public', '2026-01-21 16:45:00'),
(N'F002', N'U003', N'Litmus paper not working', N'I tried testing acidity using litmus paper, but it does not change colour. Why?', N'Public', '2026-01-28 14:20:00'),
(N'F003', N'U004', N'Why does ice float on water?', NULL, N'Private', '2026-02-03 19:00:00'),
(N'F004', N'U005', N'How to edit time on study plan?', NULL, N'Public', '2026-02-16 20:30:00'),
(N'F005', N'U006', N'Is Unit 1 taught a lot in school?', NULL, N'Public', '2026-03-05 13:05:00'),
(N'F006', N'U005', N'Check-In', N'Testing first forum post.', N'Private', '2026-06-13 15:40:00'),
(N'F007', N'U004', N'Request to extend study plan deadline', N'Mom, I can''t finish this quiz by tonight I have football. Can you extend the deadline on the study plan.', N'Private', '2026-06-14 17:45:00'),
(N'F008', N'U004', N'Difference between series and parallel circuits.', NULL, N'Public', '2026-06-01 11:10:00'),
(N'F009', N'U007', N'New item in study plan added for next week.', NULL, N'Private', '2026-06-02 19:00:00'),
(N'F010', N'U002', N'How to unlock all badges?', NULL, N'Public', '2026-06-02 08:30:00'),
(N'F011', N'U011', N'How to score high in Beginner quiz?', N'I want to complete all Beginner badges.', N'Public', '2026-06-05 17:20:00'),
(N'F012', N'U014', N'I do not understand matter topic', N'Can someone explain solid, liquid and gas?', N'Public', '2026-05-25 13:45:00'),
(N'F013', N'U016', N'Tips for remembering science facts', N'I use flashcards. What about others?', N'Public', '2026-01-06 08:55:00'),
(N'F014', N'U017', N'Live session helped me', N'The teacher explained forces clearly.', N'Public', '2026-06-10 10:30:00'),
(N'F015', N'U015', N'I am back after a long break', N'Which lesson should I continue first?', N'Public', '2026-06-14 07:40:00'),
(N'F016', N'U005', N'How do I use the learning recommendation', N'I want to know how to support my child after looking at their weak topics.', N'Public', '2026-06-13 08:50:00'),
(N'F017', N'U006', N'How can I help my child start on this app?', N'My child and I are using this platform for the first time. How should we start?', N'Public', '2026-06-15 10:15:00');

insert into ForumChat values
(N'FC001', N'F013', N'U016', N'I use flashcards too. You should write short notes after each lesson to create them immediately.', '2026-01-06 11:33:44'),
(N'FC002', N'F013', N'U012', N'Mind maps make it fun because you can draw anything on it.', '2026-06-06 10:22:00'),
(N'FC003', N'F006', N'U017', N'Hey mom.', '2026-06-13 16:30:00'),
(N'FC004', N'F015', N'U008', N'List all lessons you are unfamiliar with right now and go from the earliest to latest lesson. Hope this helps!', '2026-06-14 09:15:00'),
(N'FC005', N'F007', N'U005', N'Sure but you only get one ice cream not two.', '2026-06-14 19:34:00');

insert into Tag values
(N'TAG001', N'Human Sense', '2026-01-01 14:39:00'),
(N'TAG002', N'Classify Taste', '2026-01-01 14:40:00'),
(N'TAG003', N'Use of Human Sense', '2026-01-01 14:42:00'),
(N'TAG004', N'Magnets', '2026-01-01 14:43:00'),
(N'TAG005', N'Absorption', '2026-01-01 14:43:00'),
(N'TAG006', N'The Earth', '2026-01-01 14:45:00'),
(N'TAG007', N'Landforms', '2026-01-01 14:46:00'),
(N'TAG008', N'Soil', '2026-01-01 14:47:00'),
(N'TAG009', N'Basics of Buildings', '2026-01-01 14:48:00'),
(N'TAG010', N'Teeth', '2026-01-01 14:49:00'),
(N'TAG011', N'Balanced Diet', '2026-01-01 14:49:00'),
(N'TAG012', N'Digestion Process', '2026-01-01 14:49:00'),
(N'TAG013', N'Float and Sink', '2026-01-01 14:49:00'),
(N'TAG014', N'Density', '2026-01-01 14:50:00'),
(N'TAG015', N'Applications of Density', '2026-01-01 14:50:00'),
(N'TAG016', N'Acid and Alkali', '2026-01-01 14:50:00'),
(N'TAG017', N'The Solar System', '2026-01-01 14:50:00'),
(N'TAG018', N'Members of the Solar System', '2026-01-01 14:51:00'),
(N'TAG019', N'Temperature of Planets', '2026-01-01 14:51:00'),
(N'TAG020', N'Orbit of Planets', '2026-01-01 14:51:00'),
(N'TAG021', N'Revolution Time of Planets', '2026-01-01 14:51:00'),
(N'TAG022', N'Machine', '2026-01-01 14:52:00'),
(N'TAG023', N'Pulleys and Types', '2026-01-01 14:52:00'),
(N'TAG024', N'Function of a Fixed Pulley', '2026-01-01 14:52:00'),
(N'TAG025', N'Uses of Pulleys', '2026-01-01 14:52:00'),
(N'TAG029', N'Humans', '2026-01-01 14:53:00'),
(N'TAG030', N'Human Skeletal System', '2026-01-01 14:53:00'),
(N'TAG031', N'Joints', '2026-01-01 14:53:00'),
(N'TAG032', N'Human Blood Circulatory System', '2026-01-01 14:53:00'),
(N'TAG033', N'Human Blood Circulatory Pathway', '2026-01-01 14:54:00'),
(N'TAG034', N'Electricity', '2026-01-01 14:54:00'),
(N'TAG035', N'Sources of Electrical Energy', '2026-01-01 14:54:00'),
(N'TAG036', N'Series and Parallel Circuits', '2026-01-01 14:54:00'),
(N'TAG037', N'Matter Changes State', '2026-01-01 14:55:00'),
(N'TAG038', N'Properties of Matter', '2026-01-01 14:55:00'),
(N'TAG039', N'Water Cycle', '2026-01-01 14:55:00'),
(N'TAG040', N'Phases of the Moon', '2026-01-01 14:55:00'),
(N'TAG041', N'Constellations', '2026-01-01 14:56:00'),
(N'TAG042', N'Pulley', '2026-01-01 14:56:00'),
(N'TAG043', N'Gear', '2026-01-01 14:56:00'),
(N'TAG044', N'Simple Machines', '2026-01-01 14:56:00'),
(N'TAG045', N'Compound Machines', '2026-01-01 14:57:00'),
(N'TAG046', N'Beginner', '2026-01-01 14:57:00'),
(N'TAG047', N'Intermediate', '2026-01-01 14:57:00'),
(N'TAG048', N'Advanced', '2026-01-01 14:57:00'),
(N'TAG049', N'Live Session', '2026-01-01 14:58:00'),
(N'TAG050', N'Badge', '2026-01-01 14:58:00'),
(N'TAG051', N'Quiz', '2026-01-01 14:58:00'),
(N'TAG052', N'Teacher Help', '2026-01-01 14:59:00'),
(N'TAG053', N'Study Plan', '2026-01-01 14:59:00'),
(N'TAG054', N'Revision Tips', '2026-01-01 15:00:00');

insert into ForumTag values
(N'FTAG001', N'F001', N'TAG043'),
(N'FTAG002', N'F002', N'TAG016'),
(N'FTAG003', N'F003', N'TAG013'),
(N'FTAG004', N'F003', N'TAG014'),
(N'FTAG005', N'F004', N'TAG045'),
(N'FTAG006', N'F005', N'TAG053'),
(N'FTAG007', N'F007', N'TAG053'),
(N'FTAG008', N'F008', N'TAG036'),
(N'FTAG009', N'F009', N'TAG053'),
(N'FTAG010', N'F010', N'TAG050'),
(N'FTAG011', N'F011', N'TAG046'),
(N'FTAG012', N'F011', N'TAG050'),
(N'FTAG013', N'F015', N'TAG052'),
(N'FTAG014', N'F013', N'TAG054');

insert into ForumLike values
(N'LIKE001', N'F001', N'U003', '2026-01-21 18:05:00'),
(N'LIKE002', N'F001', N'U008', '2026-01-21 18:20:00'),
(N'LIKE003', N'F002', N'U012', '2026-01-29 09:30:00'),
(N'LIKE004', N'F004', N'U006', '2026-02-18 09:00:00'),
(N'LIKE005', N'F005', N'U005', '2026-03-05 16:00:00'),
(N'LIKE006', N'F010', N'U011', '2026-06-02 09:15:00'),
(N'LIKE007', N'F012', N'U008', '2026-05-25 15:30:00'),
(N'LIKE008', N'F013', N'U012', '2026-06-06 10:25:00'),
(N'LIKE009', N'F013', N'U017', '2026-06-06 10:40:00'),
(N'LIKE010', N'F014', N'U016', '2026-06-13 16:35:00');

insert into Question values
(N'QST001', N'Q001', N'ST111', N'U022', N'Which sense helps us hear sounds?', N'Deria manakah yang membantu kita mendengar bunyi?', N'MCQ', N'human_senses.jpg', N'Sight', N'Penglihatan', N'Hearing', N'Pendengaran', N'Taste', N'Rasa', N'Smell', N'Bau', N'B', N'Correct! The sense of hearing allows us to hear sounds such as music, voices and alarms through our ears.', N'Betul! Deria pendengaran membolehkan kita mendengar bunyi seperti muzik, suara dan loceng menggunakan telinga.', N'Incorrect. Sight is used for seeing, taste is used for identifying flavours and smell is used for detecting scents.', N'Incorrect. Sight is used for seeing, taste is used for identifying flavours and smell is used for detecting scents.', N'Easy', N'Approved', '2026-01-02 10:00:00', '2026-01-07 10:00:00'),
(N'QST002', N'Q001', N'ST111', N'U022', N'Select ALL organs that are part of the five human senses.', N'Pilih SEMUA organ yang merupakan sebahagian daripada lima deria manusia.', N'Multiselect', NULL, N'Reading a book', N'Membaca buku', N'Watching television', N'Menonton televisyen', N'Smelling a flower', N'Menghidu bunga', N'Identifying traffic lights', N'Mengenal lampu isyarat', N'A,B,D', N'Reading, watching television and identifying traffic lights all require our eyes.', N'Membaca, menonton televisyen dan mengenal lampu isyarat memerlukan penggunaan mata.', N'hink about which activities require you to see objects or colours.', N'Fikirkan aktiviti yang memerlukan kita melihat objek atau warna.', N'Medium', N'Approved', '2026-01-02 10:00:00', '2026-01-07 10:00:00'),
(N'QST003', N'Q001', N'ST111', N'U022', N'Complete the sentence by dragging the correct answer.

We use our _____ to taste food.', N'Lengkapkan ayat dengan menyeret jawapan yang betul.

Kita menggunakan _____ untuk merasa makanan.', N'Drag & Drop', NULL, N'Tongue', N'Lidah', N'Ear', N'Telinga', NULL, NULL, NULL, NULL, N'Tongue,Lidah', N'The tongue contains taste buds that help us detect different tastes such as sweet, sour, salty and bitter.', N'Lidah mempunyai tunas rasa yang membantu kita mengesan pelbagai rasa seperti manis, masam, masin dan pahit', N'Food is tasted using the tongue, not the ears.', N'Makanan dirasa menggunakan lidah, bukan telinga.', N'Easy', N'Approved', '2026-01-02 10:00:00', '2026-01-07 10:00:00'),
(N'QST004', N'Q001', N'ST113', N'U022', N'Which sense do we use to know that soup is hot before drinking it?', N'Deria manakah yang kita gunakan untuk mengetahui sup itu panas sebelum meminumnya?', N'MCQ', NULL, N'Touch', N'Sentuhan', N'Hearing', N'Pendengaran', N'Smell', N'Bau', N'Taste', N'Rasa', N'A', N'We use the sense of touch through our skin to feel whether an object is hot or cold', N'Kita menggunakan deria sentuhan melalui kulit untuk merasai sama ada sesuatu objek panas atau sejuk.', N'Only the sense of touch helps us feel temperature.', N'Hanya deria sentuhan membantu kita merasai suhu sesuatu objek.', N'Easy', N'Approved', '2026-01-02 13:20:00', '2026-01-07 10:00:00'),
(N'QST005', N'Q001', N'ST113', N'U022', N'We use our ears to hear a school bell ringing.', N'Kita menggunakan telinga untuk mendengar loceng sekolah berbunyi.', N'True / False', NULL, N'True', N'BETUL', N'False', N'SALAH', NULL, NULL, NULL, NULL, N'A', N'The ears help us hear different sounds, including bells, music and voices.', N'Telinga membantu kita mendengar pelbagai bunyi termasuk loceng, muzik dan suara.', N'Hearing sounds is the function of our ears.', N'Mendengar bunyi ialah fungsi telinga.', N'Easy', N'Approved', '2026-01-02 13:20:00', '2026-01-07 10:00:00'),
(N'QST006', N'Q001', N'ST113', N'U022', N'Select ALL situations that use the sense of smell.', N'Pilih SEMUA situasi yang menggunakan deria bau.', N'Multiselect', NULL, N'Smelling fresh flowers', N'Menghidu bunga segar', N'Detecting spoiled food', N'Mengenal pasti makanan yang telah rosak', N'Reading a storybook', N'Membaca buku cerita', N'Smelling perfume', N'Menghidu minyak wangi', N'A,B,D', N'Our nose helps us detect pleasant and unpleasant smells around us.', N'Hidung membantu kita mengesan bau yang wangi atau busuk di sekeliling kita.', N'Choose only the activities that require smelling.', N'Pilih hanya aktiviti yang memerlukan deria bau.', N'Medium', N'Approved', '2026-01-02 13:20:00', '2026-01-07 10:00:00'),
(N'QST007', N'Q019', N'ST121', N'U022', NULL, N'Apakah fungsi utama magnet?', N'MCQ', NULL, NULL, N'Menyerap air', NULL, N'Menarik objek tertentu', NULL, N'Menghasilkan cahaya', NULL, N'Menyimpan tenaga', N'B', NULL, N'Magnet digunakan untuk menarik bahan tertentu seperti besi dan keluli. Oleh sebab itu, magnet banyak digunakan dalam kehidupan harian seperti pada peti sejuk dan kompas.', NULL, N'Salah. Magnet tidak digunakan untuk menyerap air, menghasilkan cahaya atau menyimpan tenaga. Fungsi utamanya adalah menarik bahan magnetik seperti besi.', N'Easy', N'Approved', '2026-01-03 20:01:21', '2026-01-05 12:01:21'),
(N'QST008', N'Q019', N'ST121', N'U022', NULL, N'Antara berikut, yang manakah boleh ditarik oleh magnet?', N'MCQ', NULL, NULL, N'Sudu plastik', NULL, N'Paku besi', NULL, N'Pemadam', NULL, N'Kertas', N'B', NULL, N'Paku besi diperbuat daripada besi yang merupakan bahan magnetik dan boleh ditarik oleh magnet.', NULL, N'Plastik, pemadam dan kertas bukan bahan magnetik dan tidak akan ditarik oleh magnet.', N'Easy', N'Approved', '2026-01-03 20:01:21', '2026-01-05 12:01:21'),
(N'QST009', N'Q019', N'ST121', N'U022', NULL, N'Kompas menggunakan magnet untuk membantu kita...', N'MCQ', N'compass.jpg', NULL, N'Mengukur suhu', NULL, N'Mengetahui masa', NULL, N'Menentukan arah', NULL, N'Mengira nombor', N'C', NULL, N'Jarum kompas mengandungi magnet yang sentiasa menunjuk ke arah utara dan membantu manusia menentukan arah.', NULL, N'Kompas tidak digunakan untuk mengukur suhu, mengetahui masa atau membuat pengiraan.', N'Easy', N'Approved', '2026-01-03 20:01:21', '2026-01-05 12:01:21'),
(N'QST010', N'Q019', N'ST121', N'U022', NULL, N'Magnet boleh menarik semua jenis logam.', N'True/False', NULL, NULL, N'Betul', NULL, N'Salah', NULL, NULL, NULL, NULL, N'B', NULL, N'Tidak semua logam boleh ditarik oleh magnet. Contohnya, besi boleh ditarik magnet tetapi aluminium dan tembaga tidak.', NULL, N'Ramai menganggap semua logam boleh ditarik magnet, tetapi hanya logam tertentu seperti besi dan keluli yang mempunyai sifat magnetik.', N'Medium', N'Approved', '2026-01-03 20:01:21', '2026-01-05 12:01:21'),
(N'QST011', N'Q019', N'ST121', N'U022', NULL, N'Ali terjatuhkan beberapa paku besi ke dalam pasir. Apakah alat yang paling sesuai digunakan untuk mengutip paku tersebut?', N'MCQ', NULL, NULL, N'Pembaris', NULL, N'Magnet', NULL, N'Sudu', NULL, N'Penyapu', N'B', NULL, N'Magnet boleh menarik paku besi dengan mudah walaupun bercampur dengan pasir.', NULL, N'Pembaris, sudu dan penyapu mungkin dapat mengalihkan pasir tetapi tidak dapat menarik paku besi dengan berkesan.', N'Hard', N'Approved', '2026-01-03 20:01:21', '2026-01-05 12:01:21'),
(N'QST012', N'Q002', N'ST123', N'U024', N'What happens when two different magnetic poles are placed close together?', N'Apakah yang berlaku apabila dua kutub magnet yang berlainan didekatkan?', N'MCQ', NULL, N'They attract each other', N'Mereka saling menarik', N'They repel each other', N'Mereka saling menolak', N'They disappear', N'Mereka hilang', N'They become weaker', N'Mereka menjadi lebih lemah', N'A', N'Different magnetic poles (North and South) attract each other.', N'Kutub magnet yang berlainan (Utara dan Selatan) akan saling menarik.', N'Remember that unlike poles attract while like poles repel.', N'Ingat bahawa kutub berlainan menarik manakala kutub yang sama menolak.', N'Easy', N'Approved', '2026-01-03 21:31:21', '2026-01-09 13:21:21'),
(N'QST013', N'Q002', N'ST123', N'U024', N'Two North poles repel each other.', N'Dua kutub Utara akan saling menolak.', N'True / False', NULL, N'True', N'BETUL', N'False', N'SALAH', NULL, NULL, NULL, NULL, N'A', N'Magnets with the same poles repel each other.', N'Magnet yang mempunyai kutub yang sama akan saling menolak.', N'Magnets only attract when their poles are different.', N'Magnet hanya akan menarik apabila kutubnya berlainan.', N'Easy', N'Approved', '2026-01-03 21:31:21', '2026-01-09 13:21:21'),
(N'QST014', N'Q002', N'ST123', N'U024', N'Select ALL pairs that will attract each other.', N'Pilih SEMUA pasangan kutub magnet yang akan saling menarik.', N'Multiselect', NULL, N'North – South', N'Utara – Selatan', N'South – North', N'Selatan – Utara', N'North – North', N'Utara – Utara', N'South – South', N'Selatan – Selatan', N'A,B', N'Only opposite magnetic poles attract each other.', N'Hanya kutub magnet yang berlainan akan saling menarik.', N'Remember that the same poles repel each other.', N'Ingat bahawa kutub yang sama akan saling menolak', N'Medium', N'Approved', '2026-01-03 21:31:21', '2026-01-09 13:21:21'),
(N'QST015', N'Q002', N'ST123', N'U024', N'Complete the sentence by dragging the correct answer.

Magnets with the same poles will ______ each other.', N'Lengkapkan ayat dengan menyeret jawapan yang betul.

Magnet yang mempunyai kutub yang sama akan saling ______.', N'Drag & Drop', NULL, N'Repel', N'Menolak', N'Attract', N'Menarik', NULL, NULL, NULL, NULL, N'Repel,Menolak', N'Magnets with the same poles cannot stick together because they repel each other.', N'Magnet yang mempunyai kutub yang sama tidak boleh melekat kerana mereka saling menolak.', N'The same poles always repel.', N'Kutub yang sama sentiasa menolak.', N'Medium', N'Approved', '2026-01-03 21:31:21', '2026-01-09 13:21:21'),
(N'QST016', N'Q002', N'ST123', N'U024', N'Ali places the North pole of a magnet near another hidden magnet. The two magnets repel each other. Which statement is correct?', N'Ali meletakkan kutub Utara sebuah magnet berhampiran satu lagi magnet yang tersembunyi. Kedua-dua magnet saling menolak. Pernyataan manakah yang betul?', N'MCQ', NULL, N'The hidden magnet''s nearby pole is North', N'Kutub magnet yang berhampiran ialah Utara', N'The hidden magnet''s nearby pole is South', N'Kutub magnet yang berhampiran ialah Selatan', N'The hidden magnet has no poles', N'Magnet itu tidak mempunyai kutub', N'The hidden object is not a magnet', N'Objek itu bukan magnet', N'A', N'Since the magnets repel each other and Ali used a North pole, the nearby pole of the hidden magnet must also be North. Magnets with the same poles repel each other.', N'Oleh sebab kedua-dua magnet saling menolak dan Ali menggunakan kutub Utara, maka kutub magnet yang berhampiran mestilah juga kutub Utara. Magnet yang mempunyai kutub yang sama akan saling menolak.', N'Think about the relationship between magnetic poles. Repulsion only happens when the poles are the same.', N'Fikirkan hubungan antara kutub magnet. Penolakan hanya berlaku apabila kedua-dua kutub adalah sama.', N'Hard', N'Approved', '2026-01-03 21:31:21', '2026-01-09 13:21:21'),
(N'QST017', N'Q002', N'ST122', N'U009', N'Which of the following is a type of magnet?', N'Antara berikut, yang manakah ialah jenis magnet?', N'MCQ', N'magnet.png', N'Bar magnet', N'Magnet batang', N'Wooden stick', N'Batang kayu', N'Plastic ruler', N'Pembaris plastik', N'Paper clip', N'Klip kertas', N'A', N'A bar magnet is one of the common shapes of magnets used in science.', N'Magnet batang ialah salah satu bentuk magnet yang biasa digunakan dalam sains.', N'Only objects designed as magnets are considered magnet shapes.', N'Hanya objek yang direka sebagai magnet dianggap sebagai bentuk magnet.', N'Easy', N'Approved', '2026-01-03 22:41:21', '2026-01-10 14:21:21'),
(N'QST018', N'Q002', N'ST122', N'U009', N'A horseshoe magnet has two ends that are close together.', N'Magnet ladam mempunyai dua hujung yang berdekatan antara satu sama lain.', N'True / False', NULL, N'True', N'Betul', N'False', N'Salah', NULL, NULL, NULL, NULL, N'A', N'A horseshoe magnet is bent into a U-shape, bringing its two poles close together.', N'Magnet ladam dibengkokkan menjadi bentuk U, menyebabkan kedua-dua kutubnya berada berdekatan.', N'Observe the shape of a horseshoe magnet carefully.', N'Perhatikan bentuk magnet ladam dengan teliti.', N'Easy', N'Approved', '2026-01-03 22:41:21', '2026-01-10 14:21:21'),
(N'QST019', N'Q002', N'ST122', N'U009', N'Select ALL objects that are shapes of magnets.', N'Pilih SEMUA yang merupakan bentuk magnet.', N'Multiselect', NULL, N'Ring magnet', N'Magnet cincin', N'Bar magnet', N'Magnet batang', N'Horseshoe magnet', N'Magnet ladam', N'Spoon', N'Sudu', N'A,B,C', N'Ring magnets, bar magnets and horseshoe magnets are common types of magnets.', N'Magnet cincin, magnet batang dan magnet ladam ialah bentuk magnet yang biasa digunakan.', N'Choose only objects that are actual magnet shapes.', N'Pilih hanya objek yang merupakan bentuk magnet.', N'Medium', N'Approved', '2026-01-03 22:41:21', '2026-01-10 14:21:21'),
(N'QST020', N'Q002', N'ST122', N'U009', N'A student wants to pick up many paper clips quickly. Which magnet shape is MOST suitable?', N'Seorang murid ingin mengangkat banyak klip kertas dengan cepat. Bentuk magnet manakah PALING sesuai digunakan?', N'MCQ', NULL, N'Horseshoe magnet', N'Magnet ladam', N'Plastic stick', N'Batang plastik', N'Wooden ruler', N'Pembaris kayu', N'Rubber eraser', N'Pemadam getah', N'A', N'A horseshoe magnet has its two poles close together, producing a stronger magnetic effect at the ends, making it suitable for picking up many metal objects.', N'Magnet ladam mempunyai kedua-dua kutub yang berdekatan, menghasilkan daya tarikan magnet yang lebih kuat pada hujungnya dan sesuai untuk mengangkat banyak objek logam.', N'Consider which object is actually a magnet and how its shape affects its magnetic strength.', N'Fikirkan objek yang benar-benar merupakan magnet dan bagaimana bentuknya mempengaruhi kekuatan daya tarikannya.', N'Hard', N'Approved', '2026-01-03 22:41:21', '2026-01-10 14:21:21'),
(N'QST021', N'Q003', N'ST132', N'U023', N'Why is a towel made from water absorbent material?', N'Mengapakah tuala diperbuat daripada bahan yang menyerap air?', N'MCQ', NULL, N'To absorb water', N'Untuk menyerap air', N'To float on water', N'Untuk terapung di atas air', N'To produce heat', N'Untuk menghasilkan haba', N'To become waterproof', N'Untuk menjadi kalis air', N'A', N'A towel is made from water absorbent material so it can soak up water and dry our body.', N'Tuala diperbuat daripada bahan yang menyerap air supaya dapat menyerap air dan mengeringkan badan kita.', N'Think about the main purpose of using a towel after bathing.', N'Fikirkan tujuan utama menggunakan tuala selepas mandi.', N'Easy', N'Approved', '2026-01-04 11:00:21', '2026-01-13 14:41:21'),
(N'QST022', N'Q003', N'ST132', N'U023', N'Farah accidentally spilled water on the dining table. Which TWO items would BEST help her clean it up?', N'Farah tertumpahkan air di atas meja makan. Pilih DUA barangan yang PALING sesuai untuk membersihkannya.', N'Multiselect', NULL, N'Tissue', N'Tisu', N'Sponge', N'Span', N'Plastic sheet', N'Kepingan plastik', N'Glass plate', N'Pinggan kaca', N'A,B', N'Tissues and sponges absorb water quickly, making them suitable for cleaning spills', N'Tisu dan span menyerap air dengan cepat, menjadikannya sesuai untuk membersihkan tumpahan air.', N'Choose the items that can absorb water effectively.', N'Pilih barangan yang boleh menyerap air dengan berkesan.', N'Medium', N'Approved', '2026-01-04 11:00:21', '2026-01-13 14:41:21'),
(N'QST023', N'Q003', N'ST132', N'U023', N'Complete the sentence by dragging the correct answer.

A raincoat should be made from a _____ material.', N'Lengkapkan ayat dengan menyeret jawapan yang betul.

Baju hujan perlu diperbuat daripada bahan yang _____.', N'Drag & Drop', NULL, N'Waterproof', N'Kalis air', N'Water absorbent', N'Menyerap air', NULL, NULL, NULL, NULL, N'Waterproof,Kalis air', N'Waterproof materials prevent water from soaking through, keeping the wearer dry.', N'Bahan kalis air menghalang air daripada meresap, sekali gus memastikan pemakainya kekal kering.', N'Think about the main function of a raincoat.', N'Fikirkan fungsi utama baju hujan.', N'Medium', N'Approved', '2026-01-04 11:00:21', '2026-01-13 14:41:21'),
(N'QST024', N'Q003', N'ST132', N'U023', N'A camping group wants to make a picnic mat that can be used on wet grass. Which material would be the MOST suitable?', N'Sekumpulan murid ingin menghasilkan tikar berkelah yang boleh digunakan di atas rumput yang basah. Bahan manakah yang PALING sesuai digunakan?', N'MCQ', NULL, N'Cottin fabric', N'Kain kapas', N'Tissue paper', N'Kertas tisu', N'Waterproof plastic', N'Plastik kalis air', N'Sponge', N'Span', N'C', N'Waterproof plastic prevents water from soaking through, keeping the picnic mat dry and comfortable to use.', N'Plastik kalis air menghalang air daripada meresap, menjadikan tikar kekal kering dan selesa digunakan.', N'Choose a material that prevents water from entering instead of absorbing it.', N'Pilih bahan yang menghalang air daripada meresap, bukan bahan yang menyerap air.', N'Hard', N'Approved', '2026-01-04 11:00:21', '2026-01-13 14:41:21'),
(N'QST025', N'Q004', N'ST141', N'U009', N'Which landform is usually covered with sand and found beside the sea?', N'Bentuk muka bumi manakah biasanya dipenuhi pasir dan terletak di tepi laut?', N'MCQ', NULL, N'Beach', N'Pantai', N'Hill', N'Bukit', N'Cave', N'Gua', N'Waterfall', N'Air Terjun', N'A', N'A beach is a landform found along the seashore and is usually covered with sand.', N'Pantai ialah bentuk muka bumi yang terletak di persisiran laut dan biasanya dipenuhi pasir.', N'Think about the landform that is located next to the sea.', N'Fikirkan bentuk muka bumi yang berada di tepi laut.', N'Easy', N'Approved', '2026-01-04 13:00:21', '2026-01-20 17:41:21'),
(N'QST026', N'Q004', N'ST141', N'U009', N'A waterfall is formed when water flows down from a high place.', N'Air terjun terbentuk apabila air mengalir dari tempat yang tinggi.', N'True / False', NULL, N'True', N'BETUL', N'False', N'SALAH', NULL, NULL, NULL, NULL, N'A', N'A waterfall is formed when water flows from a higher level to a lower level.', N'Air terjun terbentuk apabila air mengalir dari kawasan yang lebih tinggi ke kawasan yang lebih rendah.', N'Remember that waterfalls always involve water flowing from a higher place.', N'Ingat bahawa air terjun melibatkan air yang mengalir dari tempat yang tinggi.', N'Easy', N'Approved', '2026-01-04 13:00:21', '2026-01-20 17:41:21'),
(N'QST027', N'Q004', N'ST141', N'U009', N'A village wants to build a recreation area where visitors can enjoy cool weather and beautiful scenery. Which landform is the BEST choice?', N'Sebuah kampung ingin membina kawasan rekreasi supaya pengunjung dapat menikmati udara yang sejuk dan pemandangan yang indah. Bentuk muka bumi manakah PALING sesuai?', N'MCQ', NULL, N'Hill', N'Bukit', N'Beach', N'Pantai', N'Swamp', N'Paya', N'Cave', N'Gua', N'A', N'Hills usually have cooler temperatures and beautiful views, making them suitable for recreational activities.', N'Bukit biasanya mempunyai suhu yang lebih sejuk dan pemandangan yang indah, menjadikannya sesuai untuk aktiviti rekreasi.', N'Think about which landform provides cool weather and attractive scenery for visitors.', N'Fikirkan bentuk muka bumi yang menawarkan udara sejuk dan pemandangan menarik kepada pengunjung.', N'Hard', N'Approved', '2026-01-04 13:00:21', '2026-01-20 17:41:21'),
(N'QST028', N'Q005', N'ST153', N'U023', N'Which block shape is MOST suitable for stacking boxes in a warehouse?', N'Bentuk blok manakah PALING sesuai untuk menyusun kotak di dalam gudang?', N'MCQ', NULL, N'Cube', N'Kubus', N'Sphere', N'Sfera', N'Cone', N'Kon', N'Cylinder', N'Silinder', N'A', N'A cube has flat surfaces, making it stable and easy to stack.', N'Kubus mempunyai permukaan yang rata, menjadikannya stabil dan mudah disusun.', N'Think about which shape can be stacked without rolling.', N'Fikirkan bentuk yang boleh disusun tanpa bergolek.', N'Easy', N'Approved', '2026-01-04 17:00:00', '2026-01-19 17:41:21'),
(N'QST029', N'Q005', N'ST153', N'U023', N'A shop owner wants to display canned drinks neatly on a shelf. Why are the cans stored upright?', N'Seorang pemilik kedai ingin menyusun tin minuman dengan kemas di atas rak. Mengapakah tin minuman disusun secara tegak?', N'MCQ', NULL, N'The flat base keeps them stable', N'Tapak yang rata menjadikannya stabil', N'They become lighter', N'Ia menjadi lebih ringan', N'They become waterproof', N'Ia menjadi kalis air', N'They change into cubes', N'Ia bertukar menjadi kubus', N'A', N'Although a cylinder can roll, placing it upright allows its flat base to keep it stable.', N'Walaupun silinder boleh bergolek, meletakkannya secara tegak menggunakan tapaknya yang rata untuk memastikan ia stabil.', N'Think about how the shape helps the object stay balanced.', N'Fikirkan bagaimana bentuk membantu objek kekal seimbang.', N'Medium', N'Approved', '2026-01-04 17:00:00', '2026-01-19 17:41:21'),
(N'QST030', N'Q005', N'ST153', N'U023', N'A company is designing a new package for fragile glass bottles. Which block shape would be the BEST choice to protect the bottles during transportation?', N'Sebuah syarikat ingin mereka bentuk kotak pembungkusan untuk botol kaca yang mudah pecah. Bentuk blok manakah PALING sesuai digunakan?', N'MCQ', NULL, N'Sphere', N'Sfera', N'Cone', N'Kon', N'Cube', N'Kubus', N'Hemispere', N'Hemisfera', N'C', N'A cube-shaped box has flat sides that make it easy to stack, store and protect fragile items during transportation.', N'Kotak berbentuk kubus mempunyai sisi yang rata, menjadikannya mudah disusun, disimpan dan melindungi barangan yang mudah pecah semasa penghantaran.', N'Consider which shape provides stability and protects fragile objects during transport.', N'Fikirkan bentuk yang memberikan kestabilan dan melindungi barangan yang mudah pecah semasa pengangkutan.', N'Hard', N'Approved', '2026-01-04 17:00:00', '2026-01-19 17:41:21'),
(N'QST031', N'Q006', N'ST211', N'U024', N'Which type of teeth is mainly used for cutting food?', N'Gigi jenis manakah digunakan terutamanya untuk memotong makanan?', N'MCQ', N'teeth.png', N'Incisors', N'Gigi kacip', N'Canines', N'Gigi taring', N'Premolars', N'Gigi geraham kecil', N'Molars', N'Gigi geraham', N'A', N'Incisors are the front teeth. They have sharp edges that help us bite and cut food into smaller pieces before chewing.', N'Gigi kacip ialah gigi di bahagian hadapan mulut. Gigi ini mempunyai hujung yang tajam untuk menggigit dan memotong makanan kepada bahagian yang lebih kecil sebelum dikunyah.', N'Incisors are responsible for cutting food. Canines tear food, while premolars and molars crush and grind food.', N'Gigi kacip berfungsi untuk memotong makanan. Gigi taring mengoyakkan makanan, manakala gigi geraham kecil dan geraham menghancurkan serta mengunyah makanan.', N'Easy', N'Pending', '2026-01-04 23:30:22', NULL),
(N'QST032', N'Q006', N'ST211', N'U024', N'Brushing your teeth twice a day helps prevent tooth decay.', N'Memberus gigi dua kali sehari membantu mencegah kerosakan gigi.', N'True / False', NULL, N'True', N'BETUL', N'False', N'SALAH', NULL, NULL, NULL, NULL, N'A', N'Brushing your teeth twice a day removes food particles and plaque, reducing the risk of tooth decay and keeping your teeth healthy.', N'Memberus gigi dua kali sehari membantu membuang sisa makanan dan plak, sekali gus mengurangkan risiko kerosakan gigi dan mengekalkan kesihatan gigi.', N'Brushing twice a day is recommended because it removes plaque before it damages the teeth and gums.', N'Memberus gigi dua kali sehari disarankan kerana ia membantu membuang plak sebelum merosakkan gigi dan gusi.', N'Easy', N'Pending', '2026-01-04 23:30:22', NULL),
(N'QST033', N'Q006', N'ST211', N'U024', N'Sarah often drinks sweet drinks before going to bed without brushing her teeth. After a few months, she starts having toothache. What is the MOST likely reason?', N'Sarah sering minum minuman manis sebelum tidur tanpa memberus gigi. Selepas beberapa bulan, dia mula mengalami sakit gigi. Apakah sebab yang PALING mungkin?', N'MCQ', NULL, N'Her teeth became longer', N'Giginya menjadi lebih panjang', N'Her teeth became longer', N'Giginya menjadi lebih panjang', N'Her teeth changed colour naturally', N'Warna giginya berubah secara semula jadi', N'Sugar remained on her teeth, allowing bacteria to damage them', N'Gula tertinggal pada gigi dan membolehkan bakteria merosakkan gigi', N'D', N'When sugary food or drinks remain on the teeth, bacteria feed on the sugar and produce acids. These acids slowly damage the tooth enamel, leading to tooth decay and toothache.', N'Apabila gula daripada makanan atau minuman tertinggal pada gigi, bakteria akan menggunakan gula tersebut dan menghasilkan asid. Asid ini akan menghakis enamel gigi secara perlahan-lahan, menyebabkan kerosakan gigi dan akhirnya sakit gigi.', N'Tooth decay is mainly caused by bacteria that produce acid from sugar left on the teeth. This is why brushing your teeth before sleeping is very important.', N'Kerosakan gigi berlaku apabila bakteria menghasilkan asid daripada gula yang tertinggal pada gigi. Oleh itu, memberus gigi sebelum tidur sangat penting untuk menjaga kesihatan gigi.', N'Hard', N'Pending', '2026-01-04 23:30:22', NULL),
(N'QST034', N'Q024', N'ST222', N'U022', N'Which object is most likely to float on water?', NULL, N'MCQ', NULL, N'Stone', NULL, N'Iron Nail', NULL, N'Wooden Block', NULL, N'Coin', NULL, N'C', N'A wooden block is usually less dense than water, allowing it to float on the surface.', NULL, N'Stones, iron nails and coins are generally denser than water and tend to sink.', NULL, N'Easy', N'Approved', '2026-01-05 13:50:44', '2026-01-06 13:40:04'),
(N'QST035', N'Q024', N'ST222', N'U022', N'Sarah places a cork and a stone into water. What is most likely to happen?', NULL, N'MCQ', NULL, N'Both float', NULL, N'Both sink', NULL, N'Cork floats and stone sinks', NULL, N'Stone floats and cork sinks', NULL, N'C', N'Cork has a lower density than water, while stone has a higher density than water.', NULL, N'Different materials have different densities, so they may behave differently in water.', NULL, N'Medium', N'Approved', '2026-01-05 13:50:44', '2026-01-06 13:40:04'),
(N'QST036', N'Q024', N'ST222', N'U022', N'Objects with a lower density than water usually float.', NULL, N'True/False', NULL, N'True', NULL, N'False', NULL, NULL, NULL, NULL, NULL, N'A', N'If an object is less dense than water, it can stay on the surface and float.', NULL, N'Lower density is one of the main reasons why objects float in water.', NULL, N'Easy', N'Approved', '2026-01-05 13:50:44', '2026-01-06 13:40:04'),
(N'QST037', N'Q024', N'ST222', N'U022', N'All heavy objects will sink in water.', NULL, N'True/False', NULL, N'True', NULL, N'False', NULL, NULL, NULL, NULL, NULL, N'B', N'Some heavy objects, such as large ships, can float because their overall density is lower than water.', NULL, N'Weight alone does not determine whether an object floats or sinks. Density is also important.', NULL, N'Medium', N'Approved', '2026-01-05 13:50:44', '2026-01-06 13:40:04'),
(N'QST038', N'Q024', N'ST222', N'U022', N'Which factors can affect an object''s density?', NULL, N'Multiselect', NULL, N'Mass', NULL, N'Volume', NULL, N'Material Type', NULL, N'Favourite Colour', NULL, N'A, B, C', N'Density depends on an object''s mass, volume and the material it is made from.', NULL, N'An object''s favourite colour or appearance does not affect its density.', NULL, N'Medium', N'Approved', '2026-01-05 13:50:44', '2026-01-06 13:40:04'),
(N'QST039', N'Q024', N'ST222', N'U022', N'Objects with lower ______ than water usually float.

A wooden block will usually ______ on water.

A stone will usually ______ in water.', NULL, N'Drag-and-drop', NULL, N'density', NULL, N'float', NULL, N'sink', NULL, N'colour', NULL, N'density,float,sink', N'Density affects whether objects float or sink. Wooden blocks usually float, while stones usually sink.', NULL, N'Colour does not determine whether an object floats or sinks.', NULL, N'Medium', N'Approved', '2026-01-05 13:50:44', '2026-01-06 13:40:04'),
(N'QST040', N'Q024', N'ST222', N'U022', N'A large wooden boat floats on water while a small metal ball sinks. Why?', NULL, N'MCQ', N'boat_and_ball.jpg', N'The boat is lighter than the ball', NULL, N'The boat has a lower overall density than water', NULL, N'Metal objects always sink because they are metal', NULL, N'Boats contain magic air', NULL, N'B', N'The shape of the boat and the air inside it reduce its overall density, allowing it to float.', NULL, N'Floating depends on density, not simply size, weight or the type of material alone.', NULL, N'Hard', N'Approved', '2026-01-05 13:50:44', '2026-01-06 13:40:04'),
(N'QST041', N'Q024', N'ST222', N'U022', N'Ali wants to design a toy boat that can float. Which material would be the best choice?', NULL, N'MCQ', NULL, N'Stone', NULL, N'Iron Block', NULL, N'Wood', NULL, N'Solid Steel', NULL, N'C', N'Wood generally has a lower density than water, making it a suitable material for floating objects.', NULL, N'Stone, iron and solid steel are usually denser than water and are more likely to sink.', NULL, N'Hard', N'Approved', '2026-01-05 13:50:44', '2026-01-06 13:40:04'),
(N'QST042', N'Q009', N'ST241', N'U022', N'Which object is located at the centre of the Solar System?', N'Objek manakah yang berada di pusat Sistem Suria?', N'MCQ', NULL, N'Moon', N'Bulan', N'Sun', N'Matahari', N'Earth', N'Bumi', N'Mars', N'Marikh', N'B', N'The Sun is the centre of the Solar System. All eight planets revolve around the Sun because of its strong gravitational pull.', N'Matahari ialah pusat Sistem Suria. Kesemua lapan planet beredar mengelilingi Matahari kerana tarikan gravitinya yang kuat.', N'The planets and other objects in the Solar System orbit the Sun, making it the centre of the Solar System.', N'Planet dan objek lain dalam Sistem Suria mengelilingi Matahari, menjadikan Matahari sebagai pusat Sistem Suria.', N'Easy', N'Approved', '2026-01-05 08:14:10', '2026-01-07 21:14:15'),
(N'QST043', N'Q009', N'ST241', N'U022', N'The Earth is one of the planets in the Solar System.', N'Bumi ialah salah satu planet dalam Sistem Suria.', N'True / False', NULL, N'True', N'BETUL', N'False', N'SALAH', NULL, NULL, NULL, NULL, N'A', N'Earth is the third planet from the Sun and is the only known planet that supports life.', N'Bumi ialah planet ketiga dari Matahari dan merupakan satu-satunya planet yang diketahui dapat menyokong kehidupan.', N'Earth is one of the eight planets that orbit the Sun.', N'Bumi ialah salah satu daripada lapan planet yang mengelilingi Matahari.', N'Easy', N'Approved', '2026-01-05 08:14:10', '2026-01-07 21:14:15'),
(N'QST044', N'Q009', N'ST241', N'U022', N'A group of students is building a model of the Solar System. Amir places the Earth at the centre and all the other planets around it. What should he do to make his model correct?', N'Sekumpulan murid sedang membina model Sistem Suria. Amir meletakkan Bumi di bahagian tengah dan semua planet lain mengelilinginya. Apakah yang perlu dilakukan untuk membetulkan model tersebut?', N'MCQ', NULL, N'Put the Moon at the centre', N'Letakkan Bulan di bahagian tengah', N'Move Mars to the centre', N'Letakkan Marikh di bahagian tengah', N'Leave the model as it is', N'Biarkan model seperti itu', N'Replace the Earth with the Sun at the centre', N'Gantikan Bumi dengan Matahari di bahagian tengah', N'D', N'The Sun is the centre of the Solar System. All the planets, including Earth, revolve around the Sun. Therefore, the Sun must be placed at the centre of the model.', N'Matahari ialah pusat Sistem Suria. Semua planet termasuk Bumi beredar mengelilingi Matahari. Oleh itu, Matahari mesti diletakkan di bahagian tengah model.', N'Only the Sun is located at the centre of the Solar System. The Earth and the other planets orbit the Sun, not the other way around.', N'Hanya Matahari berada di pusat Sistem Suria. Bumi dan planet-planet lain mengelilingi Matahari, bukan sebaliknya.', N'Hard', N'Approved', '2026-01-05 08:14:10', '2026-01-07 21:14:15'),
(N'QST045', N'Q020', N'ST311', N'U022', NULL, N'Apakah fungsi utama sistem rangka manusia?', N'MCQ', N'human_skeleton.png', NULL, N'Menghasilkan makanan', NULL, N'Menyokong badan', NULL, N'Menghasilkan oksigen', NULL, N'Mencerna makanan', N'B', NULL, N'Sistem rangka memberikan bentuk kepada badan dan menyokong keseluruhan struktur tubuh manusia.', NULL, N'Sistem rangka tidak menghasilkan makanan, oksigen atau mencerna makanan. Fungsi utamanya adalah menyokong badan.', N'Easy', N'Rejected', '2026-01-05 09:14:10', '2026-01-09 10:14:10'),
(N'QST046', N'Q020', N'ST311', N'U022', NULL, N'Tulang manakah yang melindungi otak?', N'MCQ', NULL, NULL, N'Femur', NULL, N'Rusuk', NULL, N'Tengkorak', NULL, N'Tulang belakang', N'C', NULL, N'Tengkorak melindungi otak daripada kecederaan dan hentakan.', NULL, N'Femur ialah tulang kaki, rusuk melindungi paru-paru dan jantung, manakala tulang belakang menyokong badan.', N'Easy', N'Rejected', '2026-01-05 09:14:10', '2026-01-09 10:14:10'),
(N'QST047', N'Q020', N'ST311', N'U022', NULL, N'Pilih semua bahagian sistem rangka manusia.', N'Multiselect', NULL, NULL, N'Tengkorak', NULL, N'Tulang rusuk', NULL, N'Femur', NULL, N'Jantung', N'A, B, C', NULL, N'Tengkorak, tulang rusuk dan femur merupakan sebahagian daripada sistem rangka manusia.', NULL, N'Jantung ialah organ dalam sistem peredaran darah dan bukan sebahagian daripada sistem rangka.', N'Medium', N'Rejected', '2026-01-05 09:14:10', '2026-01-09 10:14:10'),
(N'QST048', N'Q020', N'ST311', N'U022', NULL, N'______ melindungi otak.

Tulang ______ ialah tulang paling panjang dalam badan manusia.

Sistem rangka membantu ______ badan.', N'Drag-and-drop', NULL, NULL, N'Femur', NULL, N'menyokong', NULL, N'Tengkorak', NULL, N'paru-paru', N'Tengkorak,Femur,menyokong', NULL, N'Tengkorak melindungi otak, femur ialah tulang paling panjang dan sistem rangka membantu menyokong badan.', NULL, N'Paru-paru bukan jawapan yang sesuai untuk melengkapkan ayat tersebut.', N'Medium', N'Rejected', '2026-01-05 09:14:10', '2026-01-09 10:14:10'),
(N'QST049', N'Q020', N'ST311', N'U022', NULL, N'Mengapakah manusia sukar berdiri atau berjalan jika tidak mempunyai sistem rangka?', N'MCQ', NULL, NULL, N'Badan tidak mempunyai sokongan dan bentuk', NULL, N'Otak berhenti berfungsi', NULL, N'Darah tidak mengalir', NULL, N'Mata tidak dapat melihat', N'A', NULL, N'Sistem rangka memberikan bentuk dan sokongan kepada badan. Tanpanya, manusia tidak dapat berdiri atau bergerak dengan baik.', NULL, N'Sistem rangka tidak mengawal penglihatan, aliran darah atau fungsi otak secara langsung. Fungsi utamanya ialah menyokong badan dan membantu pergerakan.', N'Hard', N'Approved', '2026-01-07 02:30:22', '2026-01-19 09:30:22'),
(N'QST050', N'Q014', N'ST342', N'U024', N'What is a constellation?', N'Apakah yang dimaksudkan dengan buruj?', N'MCQ', NULL, N'A planet that revolves around the Sun', N'Sebuah planet yang mengelilingi Matahari', N'A bright cloud in the sky', N'Awan terang di langit', N'A group of stars that forms a pattern', N'Sekumpulan bintang yang membentuk corak', N'A shooting star', N'Bintang jatuh', N'C', N'A constellation is a group of stars that appear to form a recognisable pattern when viewed from Earth.', N'Buruj ialah sekumpulan bintang yang kelihatan membentuk corak tertentu apabila dilihat dari Bumi.', N'Constellations are not planets or clouds. They are patterns formed by groups of stars.', N'Buruj bukan planet atau awan. Buruj ialah corak yang terbentuk daripada sekumpulan bintang.', N'Easy', N'Approved', '2026-01-07 02:30:22', '2026-01-19 09:30:22'),
(N'QST051', N'Q014', N'ST342', N'U024', N'A camping group wants to find the north direction at night. Which constellation would MOST likely help them?', N'Sekumpulan murid sedang berkhemah dan ingin mencari arah utara pada waktu malam. Buruj manakah yang PALING sesuai membantu mereka?', N'MCQ', NULL, N'Ursa Major', N'Buruj Biduk', N'Orion', N'Buruj Belantik', N'Scorpius', N'Buruj Kala Jengking', N'Southern Cross', N'Buruj Pari', N'A', N'Ursa Major can be used to locate the North Star (Polaris), which helps determine the north direction.', N'Buruj Biduk boleh digunakan untuk mencari Bintang Utara (Polaris), yang membantu menentukan arah utara.', N'Different constellations have different uses. Ursa Major is commonly used to locate the north direction.', N'Setiap buruj mempunyai kegunaan yang berbeza. Buruj Biduk sering digunakan untuk menentukan arah utara.', N'Medium', N'Approved', '2026-01-07 02:30:22', '2026-01-19 09:30:22'),
(N'QST052', N'Q014', N'ST342', N'U024', N'During a night exploration activity, Amin notices a group of stars forming a familiar pattern. His teacher explains that people have used this pattern for hundreds of years. Why are constellations still important today?', N'Semasa aktiviti penerokaan waktu malam, Amin melihat sekumpulan bintang yang membentuk corak tertentu. Gurunya menerangkan bahawa corak ini telah digunakan sejak ratusan tahun dahulu. Mengapakah buruj masih penting pada masa kini?', N'MCQ', NULL, N'They produce light for the Earth', N'Menghasilkan cahaya untuk Bumi', N'They control the weather', N'Mengawal cuaca', N'They change the seasons', N'Menukar musim', N'They help people study space and identify directions', N'Membantu manusia mengkaji angkasa dan menentukan arah', N'D', N'Constellations are useful for studying the night sky and have long been used for navigation. Today, they continue to help astronomers identify different regions of the sky.', N'Buruj digunakan untuk mengkaji langit malam dan telah lama membantu manusia menentukan arah. Pada masa kini, buruj juga membantu ahli astronomi mengenal pasti kawasan tertentu di langit.', N'Constellations do not produce light for Earth or control weather. Their importance lies in astronomy and navigation.', N'Buruj tidak menghasilkan cahaya untuk Bumi atau mengawal cuaca. Kepentingannya adalah dalam bidang astronomi dan penentuan arah.', N'Hard', N'Approved', '2026-01-07 02:30:22', '2026-01-19 09:30:22'),
(N'QST053', N'Q015', N'ST353', N'U009', N'Which of the following is an example of a simple machine?', N'Antara berikut, yang manakah merupakan contoh mesin ringkas?', N'MCQ', NULL, N'Wheelbarrow', N'Kereta sorong', N'Scissors', N'Gunting', N'Pulley', N'Takal', N'Bicycle', N'Basikal', N'C', N'A pulley is one of the six types of simple machines. Scissors, bicycles and wheelbarrows are compound machines because they combine two or more simple machines.', N'Takal ialah salah satu daripada enam jenis mesin ringkas. Gunting, basikal dan kereta sorong ialah mesin kompleks kerana menggabungkan dua atau lebih mesin ringkas.', N'A simple machine performs work using a single basic mechanism. Objects made from several simple machines are compound machines.', N'Mesin ringkas melakukan kerja menggunakan satu mekanisme asas sahaja. Objek yang menggabungkan beberapa mesin ringkas ialah mesin kompleks.', N'Easy', N'Pending', '2026-01-08 01:30:22', NULL),
(N'QST054', N'Q015', N'ST353', N'U009', N'Complete the sentence by dragging the correct answer.

A _____ helps lift heavy objects using a rope.', N'Lengkapkan ayat dengan menyeret jawapan yang betul.

_____ membantu mengangkat objek berat menggunakan tali.', N'Drag & Drop', NULL, N'Pulley', N'Takal', N'Wheel', N'Roda', NULL, NULL, NULL, NULL, N'Takal', N'A pulley uses a rope and wheel to make lifting heavy objects easier.', N'Takal menggunakan tali dan roda untuk memudahkan kerja mengangkat objek yang berat.', N'A pulley is specially designed to lift loads using a rope, while a wheel has a different purpose.', N'Takal direka khas untuk mengangkat beban menggunakan tali, manakala roda mempunyai fungsi yang berbeza.', N'Medium', N'Pending', '2026-01-08 01:32:22', NULL),
(N'QST055', N'Q015', N'ST353', N'U009', N'A school is building a wheelchair ramp at the entrance. Why is a ramp a better choice than stairs for wheelchair users?', N'Sebuah sekolah membina laluan condong untuk pengguna kerusi roda di pintu masuk. Mengapakah laluan condong lebih sesuai berbanding tangga?', N'MCQ', NULL, N'It makes the wheelchair lighter', N'Ia menjadikan kerusi roda lebih ringan', N'It reduces the effort needed to move up to a higher place', N'Ia mengurangkan daya yang diperlukan untuk bergerak ke tempat yang lebih tinggi', N'It increases the speed of the wheelchair automatically', N'Ia meningkatkan kelajuan kerusi roda secara automatik', N'It changes the size of the wheelchair', N'Ia mengubah saiz kerusi roda', N'B', N'A ramp is an inclined plane, which is a simple machine. It reduces the force needed to move heavy objects or wheelchairs to a higher level, making movement safer and easier.', N'Laluan condong ialah sejenis satah condong, iaitu mesin ringkas yang mengurangkan daya yang diperlukan untuk menggerakkan objek berat atau kerusi roda ke tempat yang lebih tinggi. Oleh itu, ia lebih selamat dan mudah digunakan.', N'A ramp does not change the wheelchair itself. Its purpose is to reduce the effort required to move to a higher level by providing a sloping surface.', N'Laluan condong tidak mengubah kerusi roda. Fungsinya ialah mengurangkan daya yang diperlukan untuk bergerak ke tempat yang lebih tinggi melalui permukaan yang condong.', N'Hard', N'Pending', '2026-01-08 01:30:22', NULL),
(N'QST056', N'Q016', N'ST122', N'U023', N'A toy company wants to make magnetic building blocks that can be connected from the centre. Which magnet shape would be the MOST suitable?', N'Sebuah syarikat permainan ingin menghasilkan blok binaan magnet yang boleh disambungkan dari bahagian tengah. Bentuk magnet manakah yang PALING sesuai digunakan?', N'MCQ', NULL, N'Horseshoe magnet', N'Magnet ladam', N'Bar magnet', N'Magnet batang', N'Ring magnet', N'Magnet cincin', N'U-shaped plastic', N'Plastik berbentuk U', N'C', N'Ring magnets have a hole in the centre, making them suitable for certain designs such as toys, holders and rotating objects.', N'Magnet cincin mempunyai lubang di bahagian tengah, menjadikannya sesuai untuk reka bentuk tertentu seperti permainan, pemegang dan objek yang berputar.', N'Different magnet shapes are chosen based on their design and purpose. A ring magnet is suitable when a centre hole is needed.', N'Setiap bentuk magnet dipilih mengikut reka bentuk dan kegunaannya. Magnet cincin sesuai apabila diperlukan lubang di bahagian tengah.', N'Medium', N'Approved', '2026-01-08 09:20:22', '2026-01-22 13:20:22'),
(N'QST057', N'Q016', N'ST122', N'U023', N'Complete the sentence by dragging the correct answer.

A magnet shaped like the letter _____ is called a horseshoe magnet.', N'Lengkapkan ayat dengan menyeret jawapan yang betul.

Magnet yang berbentuk huruf _____ dikenali sebagai magnet ladam.', N'Drag & Drop', NULL, N'U', N'U', N'T', N'T', NULL, NULL, NULL, NULL, N'U', N'A horseshoe magnet is bent into a U-shape, bringing its two magnetic poles closer together to produce a stronger magnetic effect.', N'Magnet ladam dibengkokkan menjadi bentuk huruf U, menyebabkan kedua-dua kutubnya berada lebih dekat dan menghasilkan daya magnet yang lebih kuat.', N'The name "horseshoe magnet" comes from its U-shaped design, which looks like a horseshoe.', N'Nama "magnet ladam" diambil daripada reka bentuknya yang berbentuk huruf U seperti ladam kuda.', N'Medium', N'Approved', '2026-01-08 09:22:22', '2026-01-22 13:20:22'),
(N'QST058', N'Q016', N'ST141', N'U023', N'Which landform is usually found between two hills or mountains?', N'Bentuk muka bumi manakah yang biasanya terletak di antara dua bukit atau gunung?', N'MCQ', N'landforms.jpg', N'Valley', N'Lembah', N'Mountain', N'Gunung', N'Plateau', N'Tanah Tinggi', N'Beach', N'Pantai', N'A', N'Correct! A valley is a low area of land that is often located between hills or mountains. Rivers are commonly found flowing through valleys.', N'Correct! A valley is a low area of land that is often located between hills or mountains. Rivers are commonly found flowing through valleys.', N'Incorrect. Mountains and plateaus are higher landforms, while beaches are located along the coast.', N'Salah. Gunung dan tanah tinggi merupakan kawasan yang lebih tinggi, manakala pantai terletak di kawasan pesisir laut.', N'Easy', N'Approved', '2026-01-08 09:25:22', '2026-01-22 13:20:22'),
(N'QST059', N'Q016', N'ST141', N'U023', N'A recycling centre needs a magnet to collect many iron nails quickly from a pile of mixed materials. Which magnet shape would be the BEST choice and why?', N'Sebuah pusat kitar semula memerlukan magnet untuk mengutip banyak paku besi dengan cepat daripada timbunan pelbagai bahan. Bentuk magnet manakah yang PALING sesuai dan mengapa?', N'MCQ', NULL, N'Ring magnet because it has a hole in the middle', N'Magnet cincin kerana mempunyai lubang di bahagian tengah', N'Disc magnet because it is flat', N'Magnet cakera kerana bentuknya leper', N'Plastic U-shape because it looks like a horseshoe', N'Plastik berbentuk U kerana rupanya seperti ladam', N'Horseshoe magnet because its poles are close together, producing a stronger magnetic pull', N'Magnet ladam kerana kutubnya berdekatan dan menghasilkan daya tarikan magnet yang lebih kuat', N'D', N'A horseshoe magnet is commonly used for collecting metal objects because its poles are positioned close together, concentrating the magnetic force and making it easier to attract iron objects.', N'Magnet ladam sering digunakan untuk mengutip objek logam kerana kedua-dua kutubnya berada berdekatan. Keadaan ini menumpukan daya magnet pada hujung magnet dan memudahkan paku besi serta objek logam lain ditarik.', N'The best magnet is not chosen based on its appearance, but on how its shape affects its magnetic strength and intended use.', N'Pemilihan magnet bukan berdasarkan rupanya semata-mata, tetapi berdasarkan bagaimana bentuk magnet mempengaruhi kekuatan daya magnet dan kegunaannya.', N'Hard', N'Approved', '2026-01-08 09:26:22', '2026-01-22 13:20:22'),
(N'QST060', N'Q016', N'ST152', N'U023', N'A cylinder has four flat circular faces and one curved surface.', N'Silinder mempunyai empat permukaan bulat yang rata dan satu permukaan melengkung.', N'True / False', NULL, N'True', N'BETUL', N'False', N'SALAH', NULL, NULL, NULL, NULL, N'B', N'A cylinder has two flat circular faces—one at the top and one at the bottom—and one curved surface. Therefore, the statement is false.', N'Silinder mempunyai dua permukaan bulat yang rata, iaitu satu di bahagian atas dan satu di bahagian bawah, serta satu permukaan melengkung. Oleh itu, pernyataan ini adalah salah.', N'A cylinder does not have only one flat circular face. It has two flat circular faces connected by one curved surface.', N'Silinder bukan mempunyai satu permukaan bulat yang rata sahaja. Silinder mempunyai dua permukaan bulat yang rata yang dihubungkan oleh satu permukaan melengkung.', N'Easy', N'Approved', '2026-01-08 09:30:22', '2026-01-22 13:20:22'),
(N'QST061', N'Q016', N'ST152', N'U023', N'A toy company wants to design a toy that can roll smoothly in any direction without getting stuck. Which 3D shape is the BEST choice?', N'Sebuah syarikat permainan ingin mereka bentuk mainan yang boleh bergolek dengan lancar ke semua arah tanpa tersekat. Bentuk 3D manakah yang PALING sesuai?', N'MCQ', NULL, N'Cube', N'Kubus', N'Cuboid', N'Kuboid', N'Sphere', N'Sfera', N'Pyramid', N'Piramid', N'C', N'A sphere has one continuous curved surface and no edges, allowing it to roll smoothly in every direction. Shapes with flat faces or edges cannot roll as smoothly.', N'Sfera mempunyai satu permukaan melengkung yang berterusan tanpa sisi atau bucu, membolehkannya bergolek dengan lancar ke semua arah. Bentuk yang mempunyai permukaan rata atau sisi tidak dapat bergolek dengan begitu lancar.', N'To roll smoothly in all directions, an object needs a fully curved surface without flat faces or edges.', N'Untuk bergolek dengan lancar ke semua arah, sesuatu objek perlu mempunyai permukaan yang melengkung sepenuhnya tanpa permukaan rata atau sisi.', N'Hard', N'Approved', '2026-01-08 09:31:22', '2026-01-22 13:20:22'),
(N'QST062', N'Q017', N'ST212', N'U009', N'Which meal shows a balanced diet?', N'Hidangan manakah menunjukkan diet seimbang?', N'MCQ', N'meal.png', N'Fried chicken and soft drink only', N'Ayam goreng dan minuman bergas sahaja', N'Chocolate and sweets', N'Coklat dan gula-gula', N'Potato chips only', N'Kerepek kentang sahaja', N'Rice, grilled fish, vegetables and an orange', N'Nasi, ikan bakar, sayur-sayuran dan sebiji oren', N'D', N'A balanced diet includes different food groups such as carbohydrates, protein, vitamins and minerals. Rice provides energy, fish supplies protein, vegetables provide fibre and vitamins, while oranges are rich in vitamin C.', N'Diet seimbang mengandungi pelbagai kumpulan makanan seperti karbohidrat, protein, vitamin dan mineral. Nasi membekalkan tenaga, ikan membekalkan protein, sayur-sayuran membekalkan serat dan vitamin, manakala oren kaya dengan vitamin C.', N'A balanced diet should include a variety of nutrients. Meals containing only one type of food cannot provide all the nutrients our body needs.', N'Diet seimbang perlu mengandungi pelbagai jenis nutrien. Hidangan yang hanya mempunyai satu jenis makanan tidak dapat membekalkan semua nutrien yang diperlukan oleh badan.', N'Easy', N'Pending', '2026-01-09 13:11:22', NULL),
(N'QST063', N'Q017', N'ST212', N'U009', N'Hakim wants to have enough energy for a football match after school. Which TWO foods should he choose?', N'Hakim ingin mempunyai tenaga yang mencukupi untuk bermain bola sepak selepas sekolah. Pilih DUA makanan yang paling sesuai.', N'Multiselect', NULL, N'Rice', N'Nasi', N'Bread', N'Roti', N'Soft Drink', N'Minuman bergas', N'Candy', N'Gula-gula', N'A,B', N'Rice and bread are rich in carbohydrates, which provide the body with energy for physical activities such as playing football.', N'Nasi dan roti kaya dengan karbohidrat yang membekalkan tenaga kepada badan untuk melakukan aktiviti fizikal seperti bermain bola sepak.', N'Sugary foods and soft drinks may provide energy for a short time, but carbohydrates are a healthier and more reliable source of energy.', N'Makanan bergula dan minuman bergas mungkin memberikan tenaga untuk tempoh yang singkat, tetapi karbohidrat merupakan sumber tenaga yang lebih sihat dan berpanjangan.', N'Medium', N'Pending', '2026-01-09 13:11:22', NULL),
(N'QST064', N'Q017', N'ST221', N'U009', N'Two toy boats are placed on water. Boat A is made of metal but is hollow. Boat B is a small solid metal block. Which boat is MORE LIKELY to float?', N'Dua buah bot mainan diletakkan di atas air. Bot A diperbuat daripada logam tetapi berongga. Bot B ialah bongkah logam pepejal yang kecil. Bot manakah yang LEBIH BERKEMUNGKINAN terapung?', N'MCQ', NULL, N'Boat A', N'Bot A', N'Boat B', N'Bot B', N'Both boats', N'Kedua - dua bot', N'Neither boat', N'Tiada satu pun', N'A', N'Although Boat A is made of metal, its hollow design traps air and lowers its overall density, allowing it to float. A solid metal block is denser than water and usually sinks', N'Walaupun Bot A diperbuat daripada logam, reka bentuknya yang berongga memerangkap udara dan mengurangkan ketumpatan keseluruhannya, membolehkannya terapung. Bongkah logam pepejal lebih tumpat daripada air dan biasanya tenggelam.', N'Whether an object floats does not depend only on the material it is made from. Its shape and overall density are also important.', N'Sama ada sesuatu objek terapung bukan hanya bergantung pada bahan pembuatannya. Bentuk dan ketumpatan keseluruhannya juga memainkan peranan penting.', N'Hard', N'Approved', '2026-01-11 13:13:22', '2026-01-24 13:13:22'),
(N'QST065', N'Q017', N'ST223', N'U022', N'A fisherman wants his fishing net to sink into the water. Which TWO materials are suitable to attach to the net?', N'Seorang nelayan ingin memastikan jaringnya tenggelam ke dalam air. Pilih DUA bahan yang sesuai dipasang pada jaring tersebut.', N'Multiselect', NULL, N'Cork', N'Gabus', N'Foam', N'Buih', N'Metal weights', N'Pemberat logam', N'Stones', N'Batu', N'C,D', N'Metal weights and stones are denser than water, so they help pull the fishing net underwater. Cork and foam are less dense than water and tend to float.', N'Pemberat logam dan batu lebih tumpat daripada air, jadi kedua-duanya membantu jaring tenggelam. Gabus dan buih pula kurang tumpat daripada air dan cenderung untuk terapung.', N'Objects that are denser than water sink and are suitable as weights. Objects that are less dense than water float and cannot pull the net underwater.', N'Objek yang lebih tumpat daripada air akan tenggelam dan sesuai dijadikan pemberat. Objek yang kurang tumpat daripada air akan terapung dan tidak dapat membantu jaring tenggelam.', N'Medium', N'Approved', '2026-01-11 13:14:22', '2026-01-24 13:13:22'),
(N'QST066', N'Q017', N'ST232', N'U022', N'Siti accidentally spills vinegar on the kitchen table. Which household item can help reduce its acidity?', N'Siti tertumpahkan cuka di atas meja dapur. Barangan rumah manakah yang boleh membantu mengurangkan sifat berasid cuka?', N'MCQ', NULL, N'Lemon juice', N'Jus lemon', N'Orange juice', N'Jus oren', N'Baking soda', N'Soda penaik', N'Vinegar', N'Cuka', N'C', N'Baking soda is an alkaline substance. It can help neutralise acidic substances such as vinegar.', N'Soda penaik ialah bahan beralkali. Ia boleh membantu meneutralkan bahan berasid seperti cuka.', N'To reduce acidity, an alkaline substance is needed. Lemon juice, orange juice and vinegar are acidic.', N'Untuk mengurangkan sifat berasid, bahan beralkali diperlukan. Jus lemon, jus oren dan cuka ialah bahan berasid.', N'Medium', N'Approved', '2026-01-11 13:14:22', '2026-01-24 13:13:22'),
(N'QST067', N'Q017', N'ST242', N'U022', N'Which planet is the hottest planet in the Solar System?', N'Planet manakah merupakan planet yang paling panas dalam Sistem Suria?', N'MCQ', NULL, N'Venus', N'Zuhrah', N'Mercury', N'Utarid', N'Earth', N'Bumi', N'Mars', N'Marikh', N'A', N'Venus is the hottest planet because its thick atmosphere traps heat through the greenhouse effect, making its surface even hotter than Mercury.', N'Zuhrah ialah planet yang paling panas kerana atmosfera tebalnya memerangkap haba melalui kesan rumah hijau, menyebabkan permukaannya lebih panas daripada Utarid.', N'Although Mercury is the closest planet to the Sun, Venus is hotter because its thick atmosphere traps heat.', N'Walaupun Utarid ialah planet yang paling hampir dengan Matahari, Zuhrah lebih panas kerana atmosfera tebalnya memerangkap haba.', N'Easy', N'Approved', '2026-01-11 13:15:22', '2026-01-24 13:13:22'),
(N'QST068', N'Q017', N'ST252', N'U022', N'A worker needs to lift a heavy bucket from a deep well every day. Why is a fixed pulley installed above the well?', N'Seorang pekerja perlu mengangkat baldi yang berat dari sebuah perigi setiap hari. Mengapakah takal tetap dipasang di bahagian atas perigi?', N'MCQ', NULL, N'To reduce the weight of the bucket to zero', N'Untuk mengurangkan berat baldi menjadi sifar', N'To make the bucket float', N'Untuk membuat baldi terapung', N'To shorten the rope', N'Untuk memendekkan tali', N'To allow the bucket to be lifted by pulling the rope downward', N'Untuk membolehkan baldi diangkat dengan menarik tali ke bawah', N'D', N'A fixed pulley changes the direction of the pulling force. Instead of lifting the bucket upward directly, the worker pulls the rope downward, making the task more convenient and safer.', N'Takal tetap menukar arah daya tarikan. Daripada mengangkat baldi terus ke atas, pekerja hanya perlu menarik tali ke bawah, menjadikan kerja lebih mudah dan selamat dilakukan.', N'A fixed pulley does not reduce the bucket''s weight or shorten the rope. Its purpose is to change the direction of the force so lifting becomes easier to perform.', N'Takal tetap tidak mengurangkan berat baldi atau memendekkan tali. Fungsinya ialah menukar arah daya supaya kerja mengangkat menjadi lebih mudah dilakukan.', N'Hard', N'Approved', '2026-01-11 13:16:22', '2026-01-24 13:13:22'),
(N'QST069', N'Q018', N'ST313', N'U023', N'A person has been exercising for 20 minutes. Which TWO changes are MOST LIKELY to happen?', N'Seseorang telah bersenam selama 20 minit. Pilih DUA perubahan yang PALING MUNGKIN berlaku.', N'Multiselect', NULL, N'The heart beats faster', N'Jantung berdegup lebih laju', N'Blood stops flowing', N'Darah berhenti mengalir', N'The heart stops pumping', N'Jantung berhenti mengepam', N'Blood carries more oxygen to the muscles', N'Darah membawa lebih banyak oksigen ke otot', N'A,D', N'During exercise, the heart beats faster to pump more blood. This supplies more oxygen and nutrients to the muscles so they can work efficiently.', N'Semasa bersenam, jantung berdegup lebih laju untuk mengepam lebih banyak darah. Ini membekalkan lebih banyak oksigen dan nutrien kepada otot supaya dapat bekerja dengan lebih berkesan.', N'Exercise increases blood circulation. The heart continues pumping blood and never stops during normal physical activity.', N'Semasa bersenam, peredaran darah meningkat. Jantung terus mengepam darah dan tidak berhenti semasa melakukan aktiviti fizikal yang normal.', N'Medium', N'Approved', '2026-01-10 13:11:22', '2026-01-17 13:11:22'),
(N'QST070', N'Q018', N'ST323', N'U023', N'Complete the sentence by dragging the correct answer.

A _____ controls the flow of electricity by opening or closing the circuit.', N'Lengkapkan ayat dengan menyeret jawapan yang betul.

_____ mengawal aliran elektrik dengan membuka atau menutup litar.', N'Drag and Drop', NULL, N'Switch', N'Suis', N'Bulb', N'Mentol', NULL, NULL, NULL, NULL, N'Switch,Suis', N'A switch controls the flow of electricity by opening or closing the circuit. When the switch is closed, electricity can flow through the circuit and the bulb can light up.', N'Suis mengawal aliran elektrik dengan membuka atau menutup litar. Apabila suis ditutup, arus elektrik dapat mengalir melalui litar dan mentol boleh menyala.', N'A bulb produces light when electricity flows through it, but it does not control the flow of electricity. The switch is the component that opens and closes the circuit.', N'Mentol menghasilkan cahaya apabila arus elektrik mengalir melaluinya, tetapi mentol tidak mengawal aliran elektrik. Suis ialah komponen yang membuka dan menutup litar.', N'Medium', N'Approved', '2026-01-10 13:11:22', '2026-01-17 13:11:22'),
(N'QST071', N'Q018', N'ST323', N'U023', N'A circuit contains

battery
bulb
wires

The bulb does not light up.

Which component is MOST LIKELY missing?', N'Satu litar mempunyai

bateri
mentol
wayar

Mentol masih tidak menyala.

Komponen manakah PALING MUNGKIN tiada?', N'MCQ', NULL, N'Battery', N'Bateri', N'Bulb', N'Mentol', N'Switch', N'Suis', N'Wire', N'Wayar', N'C', N'A switch is used to open or close an electrical circuit. Without a switch, the circuit may be incomplete, preventing electricity from flowing to the bulb. Adding the switch completes the circuit so the bulb can light up.', N'Suis digunakan untuk membuka dan menutup litar elektrik. Tanpa suis, litar mungkin tidak lengkap dan elektrik tidak dapat mengalir ke mentol. Apabila suis dipasang dan ditutup, litar menjadi lengkap lalu mentol boleh menyala.', N'The battery supplies electrical energy, the bulb produces light, and the wires connect the components. In this situation, those components are already present. The missing component is the switch, which completes the circuit and allows electricity to flow.', N'ateri membekalkan tenaga elektrik, mentol menghasilkan cahaya, dan wayar menyambungkan semua komponen. Dalam situasi ini, semua komponen tersebut telah ada. Komponen yang tiada ialah suis, yang melengkapkan litar dan membolehkan arus elektrik mengalir.', N'Medium', N'Approved', '2026-01-10 13:11:22', '2026-01-17 13:11:22'),
(N'QST072', N'Q018', N'ST341', N'U022', N'Why does the Moon appear to change its shape over time?', N'Mengapakah Bulan kelihatan berubah bentuk dari semasa ke semasa?', N'MCQ', NULL, N'The Moon changes its size', N'Bulan berubah saiz', N'Clouds cover parts of the Moon', N'Awan menutupi sebahagian Bulan', N'Different portions of the Moon are illuminated by the Sun as the Moon revolves around Earth', N'Bahagian Bulan yang disinari Matahari berubah apabila Bulan beredar mengelilingi Bumi', N'The Earth changes the shape of the Moon', N'Bumi mengubah bentuk Bulan', N'C', N'The Moon does not change its actual shape. As it revolves around the Earth, different portions of the Moon that are illuminated by the Sun become visible from Earth, creating the different phases of the Moon.', N'Bulan tidak berubah bentuk sebenar. Apabila Bulan beredar mengelilingi Bumi, bahagian Bulan yang disinari Matahari dan dapat dilihat dari Bumi berubah, lalu menghasilkan fasa-fasa Bulan.', N'The Moon always keeps the same shape. Its different phases happen because we see different illuminated portions of the Moon from Earth.', N'Bulan sentiasa mempunyai bentuk yang sama. Perubahan fasa berlaku kerana kita melihat bahagian Bulan yang disinari Matahari dari sudut yang berbeza.', N'Medium', N'Pending', '2026-01-10 13:00:22', NULL),
(N'QST073', N'Q018', N'ST341', N'U022', N'The Moon produces its own light.', N'Bulan menghasilkan cahayanya sendiri.', N'True / False', NULL, N'True', N'BETUL', N'False', N'SALAH', NULL, NULL, NULL, NULL, N'B', N'The Moon does not produce its own light. It appears bright because it reflects sunlight.', N'Bulan tidak menghasilkan cahayanya sendiri. Bulan kelihatan terang kerana memantulkan cahaya Matahari.', N'Only the Sun produces its own light. The Moon reflects sunlight, allowing us to see it at night.', N'Hanya Matahari menghasilkan cahayanya sendiri. Bulan memantulkan cahaya Matahari, membolehkan kita melihatnya pada waktu malam.', N'Easy', N'Pending', '2026-01-10 13:00:22', NULL),
(N'QST074', N'Q018', N'ST341', N'U022', N'Hakim says that the Moon becomes smaller each night because part of it disappears. Is his statement correct?', N'Hakim mengatakan Bulan menjadi semakin kecil setiap malam kerana sebahagian daripadanya hilang. Adakah kenyataannya betul?', N'MCQ', NULL, N'Yes, because the Moon loses pieces every night', N'Ya, kerana Bulan kehilangan sebahagian daripadanya setiap malam', N'No, because clouds cover part of the Moon', N'Tidak, kerana awan menutupi sebahagian Bulan', N'No, because the Moon''s size does not change; only the illuminated part that we can see changes', N'Tidak, kerana saiz Bulan tidak berubah; hanya bahagian yang disinari dan dapat dilihat berubah', N'Yes, because the Earth pulls part of the Moon away', N'Ya, kerana Bumi menarik sebahagian Bulan keluar', N'C', N'The Moon always remains the same size. Its phases occur because we see different illuminated portions of the Moon as it revolves around Earth.', N'Saiz Bulan sentiasa kekal sama. Fasa Bulan berlaku kerana kita melihat bahagian Bulan yang berbeza yang disinari Matahari semasa Bulan beredar mengelilingi Bumi.', N'The Moon does not lose parts of itself or become smaller. The changing appearance is caused by sunlight illuminating different portions of the Moon.', N'Bulan tidak kehilangan bahagiannya atau menjadi semakin kecil. Perubahan yang dilihat berlaku kerana cahaya Matahari menyinari bahagian Bulan yang berbeza.', N'Hard', N'Pending', '2026-01-10 13:00:22', NULL),
(N'QST075', N'Q021', N'ST223', N'U022', NULL, N'Mengapakah kapal yang besar boleh terapung di atas air?', N'MCQ', NULL, NULL, N'Kapal diperbuat daripada plastik', NULL, N'Kapal mempunyai ketumpatan keseluruhan yang lebih rendah daripada air', NULL, N'Kapal sentiasa bergerak', NULL, N'Kapal sangat ringan', N'B', NULL, N'Walaupun kapal berat, reka bentuknya mengandungi ruang udara yang menjadikan ketumpatan keseluruhannya lebih rendah daripada air.', NULL, N'Kapal bukan terapung kerana ia ringan atau sentiasa bergerak, tetapi kerana ketumpatannya sesuai untuk terapung.', N'Easy', N'Pending', '2026-01-15 15:00:00', NULL),
(N'QST076', N'Q021', N'ST223', N'U022', NULL, N'Apakah kegunaan jaket keselamatan?', N'MCQ', NULL, NULL, N'Menjadikan badan lebih panas', NULL, N'Membantu seseorang terapung di atas air', NULL, N'Menambah berat badan', NULL, N'Mengeringkan pakaian', N'B', NULL, N'Jaket keselamatan mengandungi bahan yang kurang tumpat daripada air dan membantu seseorang terapung.', NULL, N'Fungsi utama jaket keselamatan ialah membantu seseorang terapung dengan selamat di dalam air.', N'Easy', N'Pending', '2026-01-15 15:00:00', NULL),
(N'QST077', N'Q021', N'ST223', N'U022', NULL, N'Mengapakah minyak masak terapung di atas air?', N'MCQ', NULL, NULL, N'Minyak lebih berat daripada air', NULL, N'Minyak lebih tumpat daripada air', NULL, N'Minyak kurang tumpat daripada air', NULL, N'Minyak mengandungi udara', N'C', NULL, N'Minyak mempunyai ketumpatan yang lebih rendah daripada air, sebab itu ia terapung di permukaan air.', NULL, N'Minyak tidak lebih tumpat atau lebih berat daripada air dalam keadaan biasa.', N'Medium', N'Pending', '2026-01-15 15:00:00', NULL),
(N'QST078', N'Q021', N'ST223', N'U022', NULL, N'Ali menuang minyak ke dalam segelas air. Dia mendapati minyak berada di bahagian atas. Apakah kesimpulan yang boleh dibuat?', N'MCQ', NULL, NULL, N'Minyak lebih berat daripada air', NULL, N'Air lebih ringan daripada minyak', NULL, N'Minyak mempunyai ketumpatan yang lebih rendah daripada air', NULL, N'Minyak bercampur sepenuhnya dengan air', N'C', NULL, N'Minyak terapung kerana ketumpatannya lebih rendah daripada air dan kedua-duanya tidak bercampur sepenuhnya.', NULL, N'Jika minyak lebih berat atau lebih tumpat daripada air, ia akan berada di bahagian bawah bekas.', N'Hard', N'Pending', '2026-01-15 15:00:00', NULL),
(N'QST079', N'Q021', N'ST223', N'U022', NULL, N'Jaket keselamatan membantu seseorang terapung kerana ia meningkatkan daya apungan badan di dalam air.', N'True/False', NULL, NULL, N'Betul', NULL, N'Salah', NULL, NULL, NULL, NULL, N'A', NULL, N'Jaket keselamatan diperbuat daripada bahan yang kurang tumpat daripada air. Bahan ini membantu meningkatkan daya apungan dan membolehkan seseorang terapung dengan lebih mudah di permukaan air.', NULL, N'Jaket keselamatan bukan sekadar pakaian biasa. Ia direka khas untuk membantu seseorang kekal terapung dan mengurangkan risiko lemas.', N'Easy', N'Pending', '2026-01-15 15:00:00', NULL),
(N'QST080', N'Q021', N'ST223', N'U022', NULL, N'Aina meletakkan sebiji epal dan seketul batu ke dalam baldi air. Epal terapung tetapi batu tenggelam. Mengapa?', N'MCQ', NULL, NULL, N'Batu lebih gelap warnanya', NULL, N'Epal lebih cantik daripada batu', NULL, N'Epal mempunyai ketumpatan yang lebih rendah daripada air', NULL, N'Batu tidak menyukai air', N'C', NULL, N'Epal terapung kerana ketumpatannya lebih rendah daripada air. Batu pula tenggelam kerana ketumpatannya lebih tinggi daripada air. Ketumpatan memainkan peranan penting dalam menentukan sama ada sesuatu objek akan terapung atau tenggelam.', NULL, N'Warna, rupa bentuk atau ciri-ciri lain tidak menentukan sama ada sesuatu objek terapung atau tenggelam. Faktor utama ialah ketumpatan objek berbanding ketumpatan air.', N'Medium', N'Pending', '2026-01-15 15:00:00', NULL),
(N'QST081', N'Q021', N'ST223', N'U022', NULL, N'Sebuah kapal kargo membawa beribu-ribu kontena tetapi masih boleh terapung. Apakah sebab yang paling tepat?', N'MCQ', NULL, NULL, N'Kapal diperbuat daripada logam yang ringan', NULL, N'Kapal sentiasa bergerak', NULL, N'Reka bentuk kapal menyebabkan ketumpatan keseluruhannya lebih rendah daripada air', NULL, N'Air laut menolak kapal ke atas secara ajaib', N'C', NULL, N'Walaupun kapal sangat berat, reka bentuknya yang mempunyai ruang udara yang besar menyebabkan ketumpatan keseluruhannya menjadi lebih rendah daripada air. Oleh itu, kapal dapat terapung di permukaan air.', NULL, N'Kapal tidak terapung kerana sentiasa bergerak atau disebabkan faktor ajaib. Keupayaan kapal untuk terapung bergantung kepada ketumpatan keseluruhan kapal dan reka bentuknya yang membolehkan daya apungan bertindak dengan berkesan.', N'Hard', N'Pending', '2026-01-15 15:00:00', NULL),
(N'QST082', N'Q022', N'ST241', N'U022', N'Which planet is known as the Red Planet?', NULL, N'MCQ', N'solar_system.jpg', N'Venus', NULL, N'Jupiter', NULL, N'Mars', NULL, N'Saturn', NULL, N'C', N'Mars is often called the Red Planet because its surface contains iron oxide, giving it a reddish appearance.', NULL, N'Venus, Jupiter and Saturn have different characteristics and are not known as the Red Planet.', NULL, N'Easy', N'Approved', '2026-04-01 15:12:00', '2026-04-03 15:12:00'),
(N'QST083', N'Q022', N'ST241', N'U022', N'Which objects are members of the Solar System?', NULL, N'Multiselect', NULL, N'Sun', NULL, N'Planets', NULL, N'Moons', NULL, N'School Bus', NULL, N'A, B, C', N'The Solar System contains the Sun, planets, moons, asteroids and other celestial objects.', NULL, N'A school bus is an object found on Earth and is not part of the Solar System.', NULL, N'Medium', N'Approved', '2026-04-01 15:12:00', '2026-04-03 15:12:00'),
(N'QST084', N'Q022', N'ST241', N'U022', N'Which of the following are planets in the Solar System?', NULL, N'Multiselect', NULL, N'Earth', NULL, N'Mars', NULL, N'Jupiter', NULL, N'Sun', NULL, N'A, B, C', N'Earth, Mars and Jupiter are planets. The Sun is a star, not a planet.', NULL, N'Many students confuse the Sun with a planet, but it is actually a star.', NULL, N'Medium', N'Approved', '2026-04-01 15:12:00', '2026-04-03 15:12:00'),
(N'QST085', N'Q022', N'ST241', N'U022', N'The Moon is a planet in the Solar System.', NULL, N'True/False', NULL, N'True', NULL, N'False', NULL, NULL, NULL, NULL, NULL, N'B', N'The Moon is Earth''s natural satellite, not a planet.', NULL, N'Although the Moon is found in the Solar System, it is classified as a natural satellite.', NULL, N'Medium', N'Approved', '2026-04-01 15:12:00', '2026-04-03 15:12:00'),
(N'QST086', N'Q022', N'ST241', N'U022', N'The ______ is at the center of the Solar System.

Humans live on ______.

Mars is known as the ______ Planet.', NULL, N'Drag-and-drop', NULL, N'Earth', NULL, N'Sun', NULL, N'Red', NULL, N'Moon', NULL, N'Sun,Earth,Red', N'The Sun is at the center of the Solar System, humans live on Earth and Mars is commonly known as the Red Planet.', NULL, N'The Moon is not at the center of the Solar System and is not the correct answer for these statements.', NULL, N'Medium', N'Approved', '2026-04-01 15:12:00', '2026-04-03 15:12:00'),
(N'QST087', N'Q022', N'ST241', N'U022', N'The Sun is a star.', NULL, N'True/False', NULL, N'True', NULL, N'False', NULL, NULL, NULL, NULL, NULL, N'A', N'The Sun is a star that produces its own light and heat. It provides the energy needed for life on Earth.', NULL, N'The Sun is not a planet. It is a star located at the center of the Solar System.', NULL, N'Easy', N'Approved', '2026-04-01 15:12:00', '2026-04-03 15:12:00'),
(N'QST088', N'Q022', N'ST241', N'U022', N'Why do all planets in the Solar System revolve around the Sun?', NULL, N'MCQ', NULL, N'Because the Sun is the largest source of gravity in the Solar System', NULL, N'Because the planets are lighter than the Sun', NULL, N'Because the Moon tells them where to go', NULL, N'Because the planets move randomly', NULL, N'A', N'The Sun has a very strong gravitational pull that keeps the planets moving around it in their orbits.', NULL, N'Planets do not move randomly, and the Moon does not control their movement. Gravity from the Sun is the main reason planets orbit around it.', NULL, N'Hard', N'Approved', '2026-04-01 15:12:00', '2026-04-03 15:12:00'),
(N'QST089', N'Q023', N'ST354', N'U022', N'What is a compound machine?', NULL, N'MCQ', NULL, N'A machine made from only one simple machine', NULL, N'A machine made from two or more simple machines', NULL, N'A machine that uses water only', NULL, N'A machine that does not move', NULL, N'B', N'A compound machine is formed when two or more simple machines work together to make tasks easier and more efficient.', NULL, N'A compound machine is not made from just one simple machine. It combines multiple simple machines to perform a task.', NULL, N'Easy', N'Approved', '2026-04-01 20:11:12', '2026-04-08 20:11:12'),
(N'QST090', N'Q023', N'ST354', N'U022', N'Which of the following is a compound machine?', NULL, N'MCQ', NULL, N'Ramp', NULL, N'Pulley', NULL, N'Bicycle', NULL, N'Lever', NULL, N'C', N'A bicycle contains several simple machines such as wheels and axles, gears and levers, making it a compound machine.', NULL, N'A ramp, pulley and lever are examples of simple machines, not compound machines.', NULL, N'Easy', N'Approved', '2026-04-01 20:11:12', '2026-04-08 20:11:12'),
(N'QST091', N'Q023', N'ST354', N'U022', N'Why do people use compound machines?', NULL, N'MCQ', NULL, N'To make work easier', NULL, N'To make work harder', NULL, N'To increase homework', NULL, N'To create noise', NULL, N'A', N'Compound machines help people perform tasks more easily by reducing effort and improving efficiency.', NULL, N'Compound machines are designed to help people, not to make work harder or create unnecessary noise.', NULL, N'Easy', N'Approved', '2026-04-01 20:11:12', '2026-04-08 20:11:12'),
(N'QST092', N'Q023', N'ST354', N'U022', N'A pair of scissors is a compound machine.', NULL, N'True/False', NULL, N'True', NULL, N'False', NULL, NULL, NULL, NULL, NULL, N'A', N'Scissors combine levers and wedges, making them a compound machine.', NULL, N'Scissors contain more than one simple machine working together.', NULL, N'Easy', N'Approved', '2026-04-01 20:11:12', '2026-04-08 20:11:12'),
(N'QST093', N'Q023', N'ST354', N'U022', N'A wheel and axle is a compound machine.', NULL, N'True/False', NULL, N'True', NULL, N'False', NULL, NULL, NULL, NULL, NULL, N'B', N'A wheel and axle is classified as a simple machine, not a compound machine.', NULL, N'Compound machines must contain two or more simple machines working together.', NULL, N'Medium', N'Approved', '2026-04-01 20:11:12', '2026-04-08 20:11:12'),
(N'QST094', N'Q023', N'ST354', N'U022', N'Which simple machines can be found in a bicycle?', NULL, N'Multiselect', NULL, N'Wheel and Axle', NULL, N'Gear', NULL, N'Lever', NULL, N'Spoon', NULL, N'A, B, C', N'A bicycle uses wheels and axles, gears and levers to help riders move efficiently.', NULL, N'A spoon is not a simple machine found in a bicycle.', NULL, N'Medium', N'Approved', '2026-04-01 20:11:12', '2026-04-08 20:11:12'),
(N'QST095', N'Q023', N'ST354', N'U022', N'Which of the following are compound machines?', NULL, N'Multiselect', NULL, N'Bicycle', NULL, N'Wheelbarrow', NULL, N'Can Opener', NULL, N'Pulley', NULL, N'A, B, C', N'A bicycle, wheelbarrow and can opener combine multiple simple machines to perform tasks more effectively.', NULL, N'A pulley is considered a simple machine and does not qualify as a compound machine on its own.', NULL, N'Medium', N'Approved', '2026-04-01 20:11:12', '2026-04-08 20:11:12'),
(N'QST096', N'Q023', N'ST354', N'U022', N'A bicycle is a ______ machine.

Scissors combine a lever and a ______.

Compound machines help make work ______.', NULL, N'Drag-and-drop', NULL, N'compound', NULL, N'easier', NULL, N'wedge', NULL, N'planet', NULL, N'compound,wedge,easier', N'A bicycle is a compound machine, scissors use wedges, and compound machines are designed to make work easier.', NULL, N'A planet is not related to compound machines and cannot complete any of the sentences correctly.', NULL, N'Medium', N'Approved', '2026-04-01 20:11:12', '2026-04-08 20:11:12'),
(N'QST097', N'Q023', N'ST354', N'U022', N'A student wants to cut cardboard for a school project. Which compound machine would be the most suitable?', NULL, N'MCQ', NULL, N'Bicycle', NULL, N'Scissors', NULL, N'Wheelbarrow', NULL, N'Pulley', NULL, N'B', N'Scissors are designed for cutting materials and combine simple machines to make cutting easier and more effective.', NULL, N'Bicycles, wheelbarrows and pulleys are useful machines, but they are not suitable for cutting cardboard.', NULL, N'Hard', N'Approved', '2026-04-01 20:11:12', '2026-04-08 20:11:12'),
(N'QST098', N'Q023', N'ST354', N'U022', N'A wheelbarrow is used to carry heavy loads. Why is it considered a compound machine?', NULL, N'MCQ', NULL, N'It contains only one simple machine', NULL, N'It combines a wheel and axle with a lever', NULL, N'It uses electricity', NULL, N'It can only be used outdoors', NULL, N'B', N'A wheelbarrow combines a wheel and axle with a lever, making it a compound machine that helps reduce effort when carrying loads.', NULL, N'A wheelbarrow does not rely on electricity and is not made from only one simple machine. Its classification comes from combining multiple simple machines.', NULL, N'Hard', N'Approved', '2026-04-01 20:11:12', '2026-04-08 20:11:12'),
(N'QST099', N'Q011', N'ST314', N'U009', N'What is the correct pathway of blood circulation?', N'Apakah laluan peredaran darah yang betul?', N'MCQ', NULL, N'Heart → Blood Vessels → Body Cells → Heart', N'Jantung → Salur Darah → Sel Badan → Jantung', N'Heart → Bones → Body Cells → Heart', N'Jantung → Tulang → Sel Badan → Jantung', N'Heart → Stomach → Body Cells → Heart', N'Jantung → Perut → Sel Badan → Jantung', N'Heart → Muscles → Teeth → Heart', N'Jantung → Otot → Gigi → Jantung', N'A', N'Correct! Blood is pumped from the heart through blood vessels to body cells and then returns to the heart.', N'Betul! Darah dipam dari jantung melalui salur darah ke seluruh badan sebelum kembali semula ke jantung.', N'Incorrect. Bones, teeth and stomach are not part of the main blood circulation pathway.', N'Salah. Tulang, gigi dan perut bukan laluan utama dalam sistem peredaran darah.', N'Easy', N'Pending', '2026-07-01 20:11:12', NULL);

insert into QuizResult values
(N'QR001', N'S005', N'Q001', 10, 10, 100.00, N'Passed', 1, '2026-01-15 10:50:00'),
(N'QR002', N'S005', N'Q002', 18, 23, 78.26, N'Passed', 1, '2026-01-15 11:00:00'),
(N'QR003', N'S005', N'Q003', 14, 19, 73.68, N'Passed', 1, '2026-01-15 11:06:00'),
(N'QR004', N'S005', N'Q005', 9, 9, 100.00, N'Passed', 1, '2026-01-15 11:12:00'),
(N'QR005', N'S005', N'Q016', 14, 18, 77.78, N'Passed', 1, '2026-01-15 11:18:00'),
(N'QR006', N'S006', N'Q001', 10, 10, 100.00, N'Passed', 1, '2026-02-10 10:50:00'),
(N'QR007', N'S006', N'Q002', 18, 36, 50.00, N'Passed', 1, '2026-02-10 11:50:00'),
(N'QR008', N'S006', N'Q003', 7, 12, 58.33, N'Passed', 1, '2026-02-15 11:50:00'),
(N'QR009', N'S006', N'Q004', 6, 7, 85.71, N'Passed', 1, '2026-02-15 11:55:00'),
(N'QR010', N'S006', N'Q005', 9, 9, 100.00, N'Passed', 1, '2026-02-15 00:50:00'),
(N'QR011', N'S006', N'Q016', 14, 18, 77.78, N'Passed', 1, '2026-02-28 10:50:00'),
(N'QR012', N'S006', N'Q009', 7, 7, 100.00, N'Passed', 1, '2026-04-29 10:50:00'),
(N'QR013', N'S006', N'Q017', 14, 19, 73.68, N'Passed', 1, '2026-04-30 10:50:00'),
(N'QR014', N'S006', N'Q014', 9, 9, 100.00, N'Passed', 1, '2026-06-28 10:50:00'),
(N'QR015', N'S006', N'Q018', 15, 18, 83.33, N'Passed', 1, '2026-06-28 11:50:00');

insert into QuizAnswer values
(N'QA001', N'QR001', N'QST001', N'B', 1, 1),
(N'QA002', N'QR001', N'QST002', N'A,B,D', 1, 3),
(N'QA003', N'QR001', N'QST003', N'Tongue', 1, 1),
(N'QA004', N'QR001', N'QST004', N'A', 1, 1),
(N'QA005', N'QR001', N'QST005', N'A', 1, 1),
(N'QA006', N'QR001', N'QST006', N'A,B,D', 1, 3),
(N'QA007', N'QR002', N'QST017', N'C', 0, 0),
(N'QA008', N'QR002', N'QST018', N'A', 1, 1),
(N'QA009', N'QR002', N'QST019', N'A,B,C', 1, 3),
(N'QA010', N'QR002', N'QST020', N'A', 1, 5),
(N'QA011', N'QR002', N'QST012', N'C', 0, 0),
(N'QA012', N'QR002', N'QST013', N'A', 1, 1),
(N'QA013', N'QR002', N'QST014', N'A,C', 0, 0),
(N'QA014', N'QR002', N'QST015', N'Repel', 1, 3),
(N'QA015', N'QR002', N'QST016', N'A', 1, 5),
(N'QA016', N'QR003', N'QST021', N'A', 1, 1),
(N'QA017', N'QR003', N'QST022', N'A,B', 1, 3),
(N'QA018', N'QR003', N'QST023', N'Waterproof', 1, 3),
(N'QA019', N'QR003', N'QST024', N'B', 0, 0),
(N'QA020', N'QR003', N'QST025', N'A', 1, 1),
(N'QA021', N'QR003', N'QST026', N'A', 1, 1),
(N'QA022', N'QR003', N'QST027', N'A', 1, 5),
(N'QA023', N'QR004', N'QST028', N'A', 1, 1),
(N'QA024', N'QR004', N'QST029', N'A', 1, 3),
(N'QA025', N'QR004', N'QST030', N'C', 1, 5),
(N'QA026', N'QR005', N'QST056', N'C', 1, 3),
(N'QA027', N'QR005', N'QST057', N'T', 0, 0),
(N'QA028', N'QR005', N'QST058', N'A', 1, 1),
(N'QA029', N'QR005', N'QST059', N'D', 1, 5),
(N'QA030', N'QR005', N'QST060', N'A', 0, 0),
(N'QA031', N'QR005', N'QST061', N'C', 1, 5),
(N'QA032', N'QR006', N'QST001', N'B', 1, 1),
(N'QA033', N'QR006', N'QST002', N'A,B,D', 1, 3),
(N'QA034', N'QR006', N'QST003', N'Tongue', 1, 1),
(N'QA035', N'QR006', N'QST004', N'A', 1, 1),
(N'QA036', N'QR006', N'QST005', N'A', 1, 1),
(N'QA037', N'QR006', N'QST006', N'A,B,D', 1, 3),
(N'QA038', N'QR007', N'QST017', N'C', 0, 0),
(N'QA039', N'QR007', N'QST018', N'A', 1, 1),
(N'QA040', N'QR007', N'QST019', N'A,B,C', 1, 3),
(N'QA041', N'QR007', N'QST020', N'A', 1, 5),
(N'QA042', N'QR007', N'QST012', N'B', 0, 0),
(N'QA043', N'QR007', N'QST013', N'B', 1, 1),
(N'QA044', N'QR007', N'QST014', N'A,D', 0, 0),
(N'QA045', N'QR007', N'QST015', N'Repel', 1, 3),
(N'QA046', N'QR007', N'QST016', N'D', 1, 5),
(N'QA047', N'QR007', N'QST012', N'C', 0, 0),
(N'QA048', N'QR007', N'QST013', N'A', 0, 0),
(N'QA049', N'QR007', N'QST014', N'A,C', 0, 0),
(N'QA050', N'QR007', N'QST015', N'Attract', 0, 0),
(N'QA051', N'QR007', N'QST016', N'A', 0, 0),
(N'QA052', N'QR008', N'QST021', N'A', 1, 1),
(N'QA053', N'QR008', N'QST022', N'A,B', 1, 3),
(N'QA054', N'QR008', N'QST023', N'Waterproof', 1, 3),
(N'QA055', N'QR008', N'QST024', N'B', 0, 0),
(N'QA056', N'QR009', N'QST025', N'A', 1, 1),
(N'QA057', N'QR009', N'QST026', N'A', 0, 0),
(N'QA058', N'QR009', N'QST027', N'A', 1, 5),
(N'QA059', N'QR010', N'QST028', N'B', 0, 0),
(N'QA060', N'QR010', N'QST029', N'B', 0, 0),
(N'QA061', N'QR010', N'QST030', N'B', 0, 0),
(N'QA062', N'QR010', N'QST028', N'A', 1, 1),
(N'QA063', N'QR010', N'QST029', N'A', 1, 3),
(N'QA064', N'QR010', N'QST030', N'C', 1, 5),
(N'QA065', N'QR011', N'QST056', N'C', 1, 3),
(N'QA066', N'QR011', N'QST057', N'T', 0, 0),
(N'QA067', N'QR011', N'QST058', N'A', 1, 1),
(N'QA068', N'QR011', N'QST059', N'D', 1, 5),
(N'QA069', N'QR011', N'QST060', N'A', 0, 0),
(N'QA070', N'QR011', N'QST061', N'C', 1, 5),
(N'QA071', N'QR012', N'QST042', N'B', 1, 1),
(N'QA072', N'QR012', N'QST043', N'A', 1, 1),
(N'QA073', N'QR012', N'QST044', N'D', 1, 5),
(N'QA074', N'QR013', N'QST064', N'A', 1, 3),
(N'QA075', N'QR013', N'QST065', N'C,D', 1, 5),
(N'QA076', N'QR013', N'QST066', N'B', 0, 0),
(N'QA077', N'QR013', N'QST067', N'A', 1, 1),
(N'QA078', N'QR013', N'QST068', N'D', 1, 5),
(N'QA079', N'QR014', N'QST050', N'C', 1, 1),
(N'QA080', N'QR014', N'QST051', N'A', 1, 3),
(N'QA081', N'QR014', N'QST052', N'D', 1, 5),
(N'QA082', N'QR015', N'QST069', N'A,D', 1, 3),
(N'QA083', N'QR015', N'QST070', N'Switch', 1, 3),
(N'QA084', N'QR015', N'QST071', N'B', 0, 0),
(N'QA085', N'QR015', N'QST069', N'A,D', 1, 3),
(N'QA086', N'QR015', N'QST070', N'Switch', 1, 3),
(N'QA087', N'QR015', N'QST071', N'C', 1, 3);

insert into XPTransaction values
(N'XPT001', N'S002', N'XP001', 10, '2026-05-16 00:00:00'),
(N'XPT002', N'S002', N'XP003', 10, '2026-05-17 00:00:00'),
(N'XPT003', N'S002', N'XP002', 15, '2026-05-18 00:00:00'),
(N'XPT004', N'S004', N'XP001', 10, '2026-02-04 00:00:00'),
(N'XPT005', N'S004', N'XP001', 10, '2026-03-04 00:00:00'),
(N'XPT006', N'S004', N'XP002', 15, '2026-06-04 00:00:00'),
(N'XPT007', N'S004', N'XP005', 20, '2026-08-04 00:00:00'),
(N'XPT008', N'S004', N'XP004', 25, '2026-12-04 00:00:00'),
(N'XPT009', N'S005', N'XP006', 40, '2026-02-28 00:00:00'),
(N'XPT010', N'S005', N'XP001', 10, '2026-10-05 00:00:00'),
(N'XPT011', N'S006', N'XP006', 40, '2026-01-28 00:00:00'),
(N'XPT012', N'S006', N'XP006', 40, '2026-04-30 00:00:00'),
(N'XPT013', N'S006', N'XP005', 20, '2026-05-06 00:00:00'),
(N'XPT014', N'S007', N'XP001', 10, '2026-05-21 00:00:00'),
(N'XPT015', N'S007', N'XP003', 10, '2026-05-23 00:00:00'),
(N'XPT016', N'S008', N'XP001', 10, '2026-05-04 00:00:00'),
(N'XPT017', N'S009', N'XP007', 5, '2026-02-06 00:00:00'),
(N'XPT018', N'S009', N'XP007', 5, '2026-04-06 00:00:00'),
(N'XPT019', N'S010', N'XP008', 15, '2026-12-06 00:00:00');

insert into LessonProgress values
(N'PR001', N'S002', N'LS001', 1, '2026-05-16 00:00:00'),
(N'PR002', N'S002', N'LS002', 1, '2026-05-17 00:00:00'),
(N'PR003', N'S002', N'LS003', 0, NULL),
(N'PR004', N'S004', N'LS001', 1, '2026-02-04 00:00:00'),
(N'PR005', N'S004', N'LS002', 1, '2026-03-04 00:00:00'),
(N'PR006', N'S004', N'LS003', 1, '2026-04-04 00:00:00'),
(N'PR007', N'S004', N'LS004', 1, '2026-05-04 00:00:00'),
(N'PR008', N'S004', N'LS005', 1, '2026-06-04 00:00:00'),
(N'PR009', N'S004', N'LS006', 1, '2026-07-04 00:00:00'),
(N'PR010', N'S005', N'LS001', 1, '2026-02-02 00:00:00'),
(N'PR011', N'S005', N'LS002', 1, '2026-03-02 00:00:00'),
(N'PR012', N'S005', N'LS003', 1, '2026-04-02 00:00:00'),
(N'PR013', N'S005', N'LS007', 1, '2026-10-05 00:00:00'),
(N'PR014', N'S005', N'LS008', 0, NULL),
(N'PR015', N'S006', N'LS001', 1, '2026-02-01 00:00:00'),
(N'PR016', N'S006', N'LS002', 1, '2026-03-01 00:00:00'),
(N'PR017', N'S006', N'LS003', 1, '2026-04-01 00:00:00'),
(N'PR018', N'S006', N'LS007', 1, '2026-03-03 00:00:00'),
(N'PR019', N'S006', N'LS008', 1, '2026-04-03 00:00:00'),
(N'PR020', N'S007', N'LS001', 1, '2026-05-21 00:00:00'),
(N'PR021', N'S007', N'LS002', 0, NULL),
(N'PR022', N'S008', N'LS001', 1, '2026-05-04 00:00:00'),
(N'PR023', N'S009', N'LS007', 1, '2026-02-06 00:00:00'),
(N'PR024', N'S009', N'LS008', 1, '2026-03-06 00:00:00'),
(N'PR025', N'S010', N'LS007', 1, '2026-05-06 00:00:00'),
(N'PR026', N'S010', N'LS008', 0, NULL);

insert into Certificate values
(N'CERT001', N'S005', N'LV001', N'Beginner Science Completion Certificate', N'Sijil Tamat Sains Pemula', N'Awarded for successfully completing all Beginner Science learning units and meeting the minimum passing requirements.', N'Dianugerahkan kerana berjaya menamatkan semua unit pembelajaran Sains Pemula dan memenuhi syarat kelulusan minimum.', '2026-01-28 00:00:00', N'Images/Certificate/cert_s005_lv001.pdf', N'SCI-BEG-S005', N'Active'),
(N'CERT002', N'S006', N'LV001', N'Beginner Science Completion Certificate', N'Sijil Tamat Sains Pemula', N'Awarded for successfully completing all Beginner Science learning units and meeting the minimum passing requirements.', N'Dianugerahkan kerana berjaya menamatkan semua unit pembelajaran Sains Pemula dan memenuhi syarat kelulusan minimum.', '2026-02-28 00:00:00', N'Images/Certificate/cert_s006_lv001.pdf', N'SCI-BEG-S006', N'Active'),
(N'CERT003', N'S006', N'LV002', N'Intermediate Science Completion Certificate', N'Sijil Tamat Sains Pertengahan', N'Awarded for successfully completing all Intermediate Science learning units and achieving the required passing score.', N'Dianugerahkan kerana berjaya menamatkan semua unit pembelajaran Sains Pemula dan memenuhi syarat kelulusan minimum.', '2026-04-30 00:00:00', N'Images/Certificate/cert_s006_lv002.pdf', N'SCI-INT-S006', N'Active'),
(N'CERT004', N'S006', N'LV003', N'Advanced Science Completion Certificate', N'Sijil Tamat Sains Lanjutan', NULL, NULL, NULL, NULL, NULL, N'Pending');

insert into [Log] values
(N'LOG001', N'U002', N'Login', N'User logged into the system successfully.', '2026-05-16 08:05:00', N'Success'),
(N'LOG002', N'U018', N'Failed Login', N'Incorrect password entered. Attempt 1 of 3.', '2026-06-14 07:55:43', N'Failed'),
(N'LOG003', N'U018', N'Failed Login', N'Incorrect password entered. Attempt 2 of 3.', '2026-06-14 07:57:43', N'Failed'),
(N'LOG004', N'U018', N'Suspicious Login Attempt', N'Maximum failed login attempts reached.', '2026-06-14 08:00:20', N'Warning'),
(N'LOG005', N'U018', N'Account Locked', N'Account temporarily locked for 30 minutes.', '2026-06-14 08:00:21', N'Success'),
(N'LOG006', N'U022', N'Material Uploaded', N'Uploaded material M001 for review.', '2026-01-28 09:33:54', N'Success'),
(N'LOG007', N'U001', N'Teacher Approved', N'Approved teacher registration T002.', '2026-03-18 09:45:20', N'Success'),
(N'LOG008', N'U001', N'Content Request Approved', N'Approved content request CR001.', '2026-01-28 11:30:20', N'Success'),
(N'LOG009', N'U001', N'Content Request Rejected', N'Rejected content request CR002.', '2026-02-15 15:28:10', N'Success'),
(N'LOG010', N'U001', N'Lesson Updated', N'Updated lesson LS021.', '2026-06-20 10:00:02', N'Success'),
(N'LOG011', N'U001', N'Quiz Updated', N'Updated quiz Q004 settings.', '2026-06-20 10:30:54', N'Success'),
(N'LOG012', N'U001', N'Configuration Updated', N'Updated Passing Mark Percentage to 50.', '2026-06-25 10:15:50', N'Success'),
(N'LOG013', N'U001', N'Security Setting', N'Updated Account Lock Duration to 30 minutes.', '2026-06-25 10:30:20', N'Success'),
(N'LOG014', N'U001', N'Notification Sent', N'Sent notification to all students.', '2026-06-25 14:45:17', N'Success'),
(N'LOG015', N'U002', N'Logout', N'User logged out from the system.', '2026-05-16 09:30:43', N'Success');

insert into Notification values
(N'N001', N'U002', N'Welcome to ScienceBuddy', N'Selamat Datang ke ScienceBuddy', N'Start your first lesson today.', N'Mulakan pelajaran pertama anda hari ini.', 0, '2026-06-05 04:46:20'),
(N'N002', N'U003', N'Quiz Completed', N'Kuiz Selesai', N'You passed your quiz.', N'Anda telah lulus kuiz anda.', 1, '2026-06-02 12:14:57'),
(N'N003', N'U011', N'New Badge Earned', N'Lencana Baharu Diperoleh', N'You earned High Scorer.', N'Anda memperoleh Skor Cemerlang.', 0, '2026-06-13 14:31:55'),
(N'N004', N'U012', N'New Level Unlocked', N'Tahap Baharu Dibuka', N'Intermediate level is now available.', N'Tahap Pertengahan kini tersedia.', 1, '2026-06-13 09:26:11'),
(N'N005', N'U013', N'Certificate Ready', N'Sijil Sedia', N'Your certificate is ready to download.', N'Sijil anda sedia untuk dimuat turun.', 0, '2026-06-11 21:03:49'),
(N'N006', N'U014', N'Study Reminder', N'Peringatan Belajar', N'Please revise your weak topics.', N'Sila ulang kaji topik lemah anda.', 0, '2026-06-02 19:39:38'),
(N'N007', N'U015', N'Come Back Soon', N'Kembali Semula', N'Continue your ScienceBuddy journey.', N'Teruskan perjalanan ScienceBuddy anda.', 0, '2026-06-08 20:09:37'),
(N'N008', N'U016', N'Forum Reply', N'Balasan Forum', N'Someone replied to your discussion.', N'Seseorang membalas perbincangan anda.', 0, '2026-06-10 10:27:05'),
(N'N009', N'U017', N'Live Session Reminder', N'Peringatan Sesi Langsung', N'Your live session starts soon.', N'Sesi langsung anda akan bermula.', 1, '2026-06-12 11:06:54'),
(N'N010', N'U018', N'Account Blocked', N'Akaun Disekat', N'Your account is currently blocked.', N'Akaun anda sedang disekat.', 0, '2026-06-13 17:23:37'),
(N'N011', N'U005', N'Your child replied to a discussion.', N'Anak Anda Membalas Perbincangan', N'Your account is currently blocked.', N'Akaun anda sedang disekat.', 0, '2026-06-08 01:50:04'),
(N'N012', N'U014', N'Your parent replied to a discussion.', N'Ibu Bapa Anda Membalas Perbincangan', N'Your account is currently blocked.', N'Akaun anda sedang disekat.', 0, '2026-06-04 16:47:17'),
(N'N013', N'U016', N'Forum Reply', N'Balasan Forum', N'Someone replied to your discussion.', N'Seseorang membalas perbincangan anda.', 0, '2026-06-02 00:53:57'),
(N'N014', N'U015', N'Forum Reply', N'Balasan Forum', N'Someone replied to your discussion.', N'Seseorang membalas perbincangan anda.', 0, '2026-06-15 16:18:19'),
(N'N015', N'U004', N'New Parent Discussion', N'Perbincangan Baharu Ibu Bapa Dimulakan', N'Your parent started a discussion with a forum post.', N'Ibu/bapa anda telah memulakan perbincangan dengan memuatnaik forum baharu.', 0, '2026-06-12 11:01:30');

insert into LabProgress values
(N'LABP001', N'S002', N'LAB001', 1, '2026-05-18 00:00:00'),
(N'LABP002', N'S004', N'LAB001', 1, '2026-06-04 00:00:00'),
(N'LABP003', N'S004', N'LAB002', 1, '2026-10-04 00:00:00'),
(N'LABP004', N'S005', N'LAB001', 1, '2026-10-02 00:00:00'),
(N'LABP005', N'S005', N'LAB003', 0, NULL),
(N'LABP006', N'S006', N'LAB001', 1, '2026-05-01 00:00:00'),
(N'LABP007', N'S006', N'LAB002', 1, '2026-06-10 00:00:00'),
(N'LABP008', N'S006', N'LAB003', 1, '2026-10-06 00:00:00'),
(N'LABP009', N'S007', N'LAB001', 1, '2026-06-08 00:00:00'),
(N'LABP010', N'S008', N'LAB001', 0, NULL),
(N'LABP011', N'S009', N'LAB003', 1, '2026-07-06 00:00:00'),
(N'LABP012', N'S010', N'LAB003', 1, '2026-09-06 00:00:00');

insert into LiveConsultationSession values
(N'LIVE001', N'T004', N'UN201', N'ST211', N'Healthy Teeth Workshop', N'Learn how to maintain healthy teeth through proper habits.', N'https://meet.jit.si/ScienceBuddy-LIVE001', '2026-01-20 10:00:00', '2026-01-20 12:00:00', N'Completed'),
(N'LIVE002', N'T004', N'UN202', N'ST221', N'Float and Sink Experiment', N'Live demonstration of floating and sinking objects.', N'https://meet.jit.si/ScienceBuddy-LIVE002', '2026-02-13 14:00:00', '2026-02-13 15:00:00', N'Completed'),
(N'LIVE003', N'T005', N'UN104', N'ST141', N'Meneroka Bentuk Muka Bumi', N'Kenali gunung, lembah, pantai dan pelbagai bentuk muka bumi melalui contoh visual.', N'https://meet.jit.si/ScienceBuddy-LIVE003', '2026-05-20 14:30:00', '2026-05-20 16:30:00', N'Completed'),
(N'LIVE004', N'T006', N'UN303', N'ST314', N'Journey of Blood Through the Body', N'Follow the pathway of blood as it travels through the circulatory system.', N'https://meet.jit.si/ScienceBuddy-LIVE004', '2026-08-20 09:30:00', '2027-08-20 11:00:00', N'Ongoing'),
(N'LIVE005', N'T002', N'UN202', N'ST212', N'Building a Healthy Plate', N'Learn how different food groups contribute to a balanced diet.', N'https://meet.jit.si/ScienceBuddy-LIVE005', '2026-08-30 10:10:00', '2026-08-30 11:10:00', N'Upcoming'),
(N'LIVE006', N'T004', N'UN301', N'ST311', N'Memahami Sistem Rangka Manusia', N'Pelajari fungsi tulang dan bagaimana sistem rangka menyokong badan.', N'https://meet.jit.si/ScienceBuddy-LIVE006', '2026-09-15 09:00:00', '2026-09-15 10:15:00', N'Upcoming');

insert into LiveSessionParticipant values
(N'LIVEP001', N'LIVE001', N'S010', '2026-01-20 10:05:00'),
(N'LIVEP002', N'LIVE001', N'S009', '2026-01-20 10:05:00'),
(N'LIVEP003', N'LIVE001', N'S005', '2026-01-20 10:20:00'),
(N'LIVEP004', N'LIVE001', N'S007', '2026-01-20 10:35:12'),
(N'LIVEP005', N'LIVE002', N'S010', '2026-02-13 14:15:20'),
(N'LIVEP006', N'LIVE002', N'S002', '2026-02-13 14:20:30'),
(N'LIVEP007', N'LIVE002', N'S004', '2026-02-13 14:30:45'),
(N'LIVEP008', N'LIVE002', N'S006', '2026-02-13 14:40:50'),
(N'LIVEP009', N'LIVE003', N'S010', '2026-05-20 14:38:41'),
(N'LIVEP010', N'LIVE003', N'S005', '2026-05-20 15:01:41'),
(N'LIVEP011', N'LIVE003', N'S002', '2026-05-20 15:20:41'),
(N'LIVEP012', N'LIVE003', N'S010', '2026-05-20 16:05:01');

insert into UserStatusAction values
(N'US001', N'U018', N'Blocked', N'Suspicious login attempts exceeded limit.', '2026-06-14 00:00:00', N'U001'),
(N'US002', N'U018', N'Unblocked', N'Account lock duration completed and account restored.', '2026-06-14 00:00:00', N'U001'),
(N'US003', N'U004', N'Deleted', N'User requested account deletion.', '2026-05-30 00:00:00', N'U001'),
(N'US004', N'U024', N'Blocked', N'Teacher certification rejected.', '2026-04-07 00:00:00', N'U001'),
(N'US005', N'U024', N'Unblocked', N'Teacher submitted updated certification documents.', '2026-04-20 00:00:00', N'U001');

insert into AILearningAnalysis values
(N'A001', N'S002', NULL, N'Student is progressing steadily in Beginner level.', N'Basic science concepts', N'Scientific method', 65.00, 2, 1),
(N'A002', N'S004', NULL, N'Student performs excellently and is ready for level completion.', N'Scientific method, Matter, Energy', NULL, 90.00, 3, 1),
(N'A003', N'S005', NULL, N'Student completed Beginner level and is adapting to Intermediate topics.', N'Beginner concepts', N'Forces and electricity', 65.00, 2, 1),
(N'A004', N'S006', NULL, N'Student shows strong performance across all levels.', N'Matter, Energy, Electricity', NULL, 95.00, 2, 1),
(N'A005', N'S007', NULL, N'Student is struggling and needs revision support.', N'Basic observation', N'Matter, Scientific method, Quiz confidence', 30.00, 3, 1),
(N'A006', N'S008', NULL, N'Student has limited recent activity.', N'Basic introduction', N'Consistency', 50.00, 1, 1),
(N'A007', N'S009', NULL, N'Student learns well through discussion and collaboration.', N'Forum discussion, explanation', N'Calculation questions', 80.00, 1, 1),
(N'A008', N'S010', NULL, N'Student benefits from live session participation.', N'Guided learning', N'Independent quiz practice', 70.00, 1, 1);

insert into StudyPlan values
(N'STP001', N'SP002', N'U006', N'Siti Human Revision Plan', '2026-06-10 00:00:00', '2026-06-16 00:00:00', N'Ongoing', '2026-06-10 19:00:00'),
(N'STP002', N'SP003', N'U002', N'This Week', '2026-06-01 00:00:00', '2026-06-08 00:00:00', N'Ongoing', '2026-06-01 15:21:00'),
(N'STP003', N'SP006', N'U005', N'Hana Weak Topic Support Plan', '2026-06-02 00:00:00', '2026-06-09 00:00:00', N'Completed', '2026-06-02 20:15:00'),
(N'STP004', N'SP005', N'U012', N'Maya Intermediate Practice', '2026-06-11 00:00:00', '2026-06-16 00:00:00', N'Ongoing', '2026-06-11 16:30:00'),
(N'STP005', NULL, N'U013', N'Advanced Electricity Revision plan', '2026-06-12 00:00:00', '2026-06-16 00:00:00', N'Ongoing', '2026-06-12 18:00:00'),
(N'STP006', N'SP007', N'U016', N'Qistina Forum and Quiz Plan', '2026-12-06 00:00:00', '2026-12-13 00:00:00', N'Ongoing', '2026-12-05 15:10:00'),
(N'STP007', N'SP008', N'U005', N'Rayyan Live Session Plan', '2026-05-07 00:00:00', '2026-05-14 00:00:00', N'Completed', '2026-05-05 15:10:00');

insert into SPTask values
(N'SPT001', N'STP001', N'Review Human Sense Lesson', N'Read notes about the five human senses.', 1, 1, '2026-06-10 20:00:00'),
(N'SPT002', N'STP001', N'Classify taste examples', N'Extra revision', 2, 0, NULL),
(N'SPT003', N'STP001', N'Attempt Human Sense Quiz', N'Complete quiz after revision', 3, 0, NULL),
(N'SPT004', N'STP002', N'Archived deleted user task', N'Keep for deleted user filtering test', 1, 0, NULL),
(N'SPT005', N'STP002', N'Archived parent reminder', N'Keep old deleted parent-child record', 2, 0, NULL),
(N'SPT006', N'STP003', N'Rewatch weak topic video', N'Review difficult topic before quiz retry', 1, 1, '2026-06-03 18:00:00'),
(N'SPT007', N'STP003', N'Retry failed quiz', N'Attempt quiz again after revision', 2, 1, '2026-06-05 19:00:00'),
(N'SPT008', N'STP003', N'Teacher checking', N'Get teacher to review answers', 3, 1, '2026-06-08 20:00:00'),
(N'SPT009', N'STP004', N'Revise Density topic', N'Read Float and Sink notes', 1, 1, '2026-06-12 17:00:00'),
(N'SPT010', N'STP004', N'Complete Density practice', N'Answer practice questions', 2, 0, NULL),
(N'SPT011', N'STP004', N'Do lab task', N'Do lab task over practice quizzes for better understanding', 3, 0, NULL),
(N'SPT012', N'STP005', N'Review Series Circuits', N'Study advanced electricity notes', 1, 1, '2026-06-12 19:00:00'),
(N'SPT013', N'STP005', N'Complete Circuit Symbols', N'Match symbols with circuit parts', 2, 1, '2026-06-13 17:30:00'),
(N'SPT014', N'STP005', N'Attempt Electricity Quiz', N'Score at least 80%', 3, 0, NULL),
(N'SPT015', N'STP006', N'Write revision notes', N'Summarise facts using written notes', 1, 1, '2026-12-06 20:30:00'),
(N'SPT016', N'STP006', N'Reply in Forum', N'Help another student', 2, 1, '2026-12-07 10:15:00'),
(N'SPT017', N'STP007', N'Attend Live Session', N'Join teacher consultation session', 1, 1, '2026-05-06 15:00:00'),
(N'SPT018', N'STP007', N'Review session notes', N'Read notes after live session', 2, 1, '2026-05-07 10:00:00'),
(N'SPT019', N'STP007', N'Write reflection', N'List three things learned', 3, 1, '2026-05-10 11:00:00');

insert into SPReward
(rewardId, studyPlanId, rewardName, requiredProgress, isUnlocked, unlockedAt, rewardImage)
values
(N'SPR001', N'STP001', N'Extra Screentime (2 hours)', 25, 1, '2026-06-12 18:22:13', N'Images/Parent/Rewards/screentime.png'),
(N'SPR002', N'STP001', N'Watch "Spiderman" at the movies', 50, 1, '2026-06-15 22:10:10', N'Images/Parent/Rewards/movie.png'),
(N'SPR003', N'STP002', N'McDonalds', 25, 1, '2026-06-03 16:10:10', N'Images/Parent/Rewards/fast-food.png'),
(N'SPR004', N'STP002', N'Trip to ToysRUs', 50, 0, NULL, N'Images/Parent/Rewards/toy-store.png'),
(N'SPR005', N'STP002', N'Secret Recipe Cake', 100, 0, NULL, N'Images/Parent/Rewards/cake.png'),
(N'SPR006', N'STP003', N'New toy', 50, 0, NULL, N'Images/Parent/Rewards/toy.png'),
(N'SPR007', N'STP004', N'New Science Sticker Set', 50, 1, '2026-06-13 21:00:00', N'Images/Parent/Rewards/sticker-star.png'),
(N'SPR008', N'STP004', N'Ice Cream Treat', 100, 1, '2026-06-16 21:10:00', N'Images/Parent/Rewards/ice-cream.png'),
(N'SPR009', N'STP005', N'1 Hour Game Time', 50, 0, NULL, N'Images/Parent/Rewards/game.png'),
(N'SPR010', N'STP006', N'Favourite Snack', 50, 0, NULL, N'Images/Parent/Rewards/snack.png'),
(N'SPR011', N'STP007', N'Buy New Notebook', 50, 1, '2026-05-08 12:50:00', NULL),
(N'SPR012', N'STP007', N'Weekend Movie Night', 100, 1, '2026-05-13 09:10:00', N'Images/Parent/Rewards/movie.png');

insert into userChat values
(N'C001', N'U002', N'U008', '2026-05-06 10:00:00'),
(N'C002', N'U003', N'U008', '2026-06-03 14:00:00'),
(N'C003', N'U003', N'U009', '2026-06-15 20:00:00'),
(N'C004', N'U004', N'U010', '2026-06-16 08:00:00'),
(N'C005', N'U005', N'U008', '2026-06-17 09:00:00'),
(N'C006', N'U005', N'U010', '2026-06-19 08:00:00'),
(N'C007', N'U006', N'U009', '2026-06-21 15:00:00'),
(N'C008', N'U007', N'U008', '2026-06-26 16:00:00'),
(N'C009', N'U007', N'U009', '2026-07-02 15:00:00'),
(N'C010', N'U013', N'U022', '2026-07-15 10:20:15'),
(N'C011', N'U022', N'U005', '2026-07-30 11:12:12');

insert into privateMessage values
(N'PM001', N'C001', N'U002', N'Can you checkout my answers I wrote on paper?', N'answer.pdf', '2026-07-03 10:00:00', 1, '2026-07-04 14:00:00'),
(N'PM002', N'C001', N'U008', N'Sure! Question 2 and 3 is wrong.', NULL, '2026-07-03 10:10:55', 0, NULL),
(N'PM003', N'C002', N'U003', N'Miss, I think the answer for question 4 is wrong.', NULL, '2026-07-07 09:00:00', 1, '2026-07-07 09:04:00'),
(N'PM004', N'C002', N'U008', N'OH, you''re right!', NULL, '2026-07-07 09:05:00', 1, '2026-07-07 09:10:00'),
(N'PM005', N'C002', N'U003', N'No problem miss.', NULL, '2026-07-07 09:10:50', 0, NULL),
(N'PM006', N'C003', N'U003', N'When is the next live session?', NULL, '2026-06-11 11:00:00', 1, '2026-06-11 11:30:00'),
(N'PM007', N'C003', N'U009', N'We have not scheduled it yet, sorry but around this week.', NULL, '2026-06-12 10:00:00', 1, '2026-06-12 10:30:00'),
(N'PM008', N'C003', N'U003', N'I understand.', NULL, '2026-06-13 00:30:00', 0, NULL),
(N'PM009', N'C004', N'U004', N'Teacher, I am struggling with the notes.', NULL, '2026-06-14 08:00:00', 1, '2026-06-14 09:00:00'),
(N'PM010', N'C004', N'U010', N'No problem. Feel free to ask me any questions you have.', NULL, '2026-06-15 00:55:00', 0, NULL),
(N'PM011', N'C010', N'U013', N'Teacher, I don''t understand why a magnet can attract some metals but not others.', NULL, '2026-06-16 09:00:00', 1, '2026-06-16 10:00:00'),
(N'PM012', N'C010', N'U022', N'Magnets only attract certain metals such as iron, nickel and cobalt. Not all metals have magnetic properties.', NULL, '2026-06-17 11:00:00', 1, '2026-06-17 11:10:00'),
(N'PM013', N'C010', N'U013', N'Oh, I understand now. Thank you, teacher!', NULL, '2026-06-18 10:00:00', 1, '2026-06-18 11:00:00'),
(N'PM014', N'C011', N'U005', N'Assalamualaikum cikgu. Anak saya terlepas sesi konsultasi minggu lepas. Adakah akan ada sesi lagi?', NULL, '2026-07-30 11:12:12', 1, '2026-07-30 11:30:12'),
(N'PM015', N'C011', N'U022', N'Waalaikumsalam. Ya, akan ada sesi tambahan minggu hadapan untuk topik yang sama.', NULL, '2026-07-30 13:30:12', 1, '2026-07-30 15:10:10'),
(N'PM016', N'C011', N'U005', N'Alhamdulillah, terima kasih cikgu.', NULL, '2026-07-30 13:45:50', 1, '2026-07-30 14:21:12');