/* ScienceBuddy_DB - CreateTables.sql
   Creates database, drops existing ScienceBuddy tables safely, and recreates PK/FK structure. */
USE [master];
GO

IF DB_ID(N'ScienceBuddy_DB') IS NULL
BEGIN
    CREATE DATABASE [ScienceBuddy_DB];
END;
GO

USE [ScienceBuddy_DB];
GO
-- Drop tables in child-to-parent order so the script can be rerun during development.
IF OBJECT_ID(N'dbo.privateMessage', N'U') IS NOT NULL DROP TABLE dbo.[privateMessage];
GO
IF OBJECT_ID(N'dbo.userChat', N'U') IS NOT NULL DROP TABLE dbo.[userChat];
GO
IF OBJECT_ID(N'dbo.SPReward', N'U') IS NOT NULL DROP TABLE dbo.[SPReward];
GO
IF OBJECT_ID(N'dbo.SPTask', N'U') IS NOT NULL DROP TABLE dbo.[SPTask];
GO
IF OBJECT_ID(N'dbo.StudyPlan', N'U') IS NOT NULL DROP TABLE dbo.[StudyPlan];
GO
IF OBJECT_ID(N'dbo.AILearningAnalysis', N'U') IS NOT NULL DROP TABLE dbo.[AILearningAnalysis];
GO
IF OBJECT_ID(N'dbo.ConfigurationSetting', N'U') IS NOT NULL DROP TABLE dbo.[ConfigurationSetting];
GO
IF OBJECT_ID(N'dbo.UserStatusAction', N'U') IS NOT NULL DROP TABLE dbo.[UserStatusAction];
GO
IF OBJECT_ID(N'dbo.LiveSessionParticipant', N'U') IS NOT NULL DROP TABLE dbo.[LiveSessionParticipant];
GO
IF OBJECT_ID(N'dbo.LiveConsultationSession', N'U') IS NOT NULL DROP TABLE dbo.[LiveConsultationSession];
GO
IF OBJECT_ID(N'dbo.LabProgress', N'U') IS NOT NULL DROP TABLE dbo.[LabProgress];
GO
IF OBJECT_ID(N'dbo.VirtualLab', N'U') IS NOT NULL DROP TABLE dbo.[VirtualLab];
GO
IF OBJECT_ID(N'dbo.Notification', N'U') IS NOT NULL DROP TABLE dbo.[Notification];
GO
IF OBJECT_ID(N'dbo.Log', N'U') IS NOT NULL DROP TABLE dbo.[Log];
GO
IF OBJECT_ID(N'dbo.Certificate', N'U') IS NOT NULL DROP TABLE dbo.[Certificate];
GO
IF OBJECT_ID(N'dbo.LessonProgress', N'U') IS NOT NULL DROP TABLE dbo.[LessonProgress];
GO
IF OBJECT_ID(N'dbo.XPTransaction', N'U') IS NOT NULL DROP TABLE dbo.[XPTransaction];
GO
IF OBJECT_ID(N'dbo.XPAction', N'U') IS NOT NULL DROP TABLE dbo.[XPAction];
GO
IF OBJECT_ID(N'dbo.QuizAnswer', N'U') IS NOT NULL DROP TABLE dbo.[QuizAnswer];
GO
IF OBJECT_ID(N'dbo.QuizResult', N'U') IS NOT NULL DROP TABLE dbo.[QuizResult];
GO
IF OBJECT_ID(N'dbo.Question', N'U') IS NOT NULL DROP TABLE dbo.[Question];
GO
IF OBJECT_ID(N'dbo.ForumLike', N'U') IS NOT NULL DROP TABLE dbo.[ForumLike];
GO
IF OBJECT_ID(N'dbo.ForumTag', N'U') IS NOT NULL DROP TABLE dbo.[ForumTag];
GO
IF OBJECT_ID(N'dbo.Tag', N'U') IS NOT NULL DROP TABLE dbo.[Tag];
GO
IF OBJECT_ID(N'dbo.ForumChat', N'U') IS NOT NULL DROP TABLE dbo.[ForumChat];
GO
IF OBJECT_ID(N'dbo.Forum', N'U') IS NOT NULL DROP TABLE dbo.[Forum];
GO
IF OBJECT_ID(N'dbo.Material', N'U') IS NOT NULL DROP TABLE dbo.[Material];
GO
IF OBJECT_ID(N'dbo.Quiz', N'U') IS NOT NULL DROP TABLE dbo.[Quiz];
GO
IF OBJECT_ID(N'dbo.Lesson', N'U') IS NOT NULL DROP TABLE dbo.[Lesson];
GO
IF OBJECT_ID(N'dbo.Enrollment', N'U') IS NOT NULL DROP TABLE dbo.[Enrollment];
GO
IF OBJECT_ID(N'dbo.Subtopic', N'U') IS NOT NULL DROP TABLE dbo.[Subtopic];
GO
IF OBJECT_ID(N'dbo.Unit', N'U') IS NOT NULL DROP TABLE dbo.[Unit];
GO
IF OBJECT_ID(N'dbo.StudentBadge', N'U') IS NOT NULL DROP TABLE dbo.[StudentBadge];
GO
IF OBJECT_ID(N'dbo.Badge', N'U') IS NOT NULL DROP TABLE dbo.[Badge];
GO
IF OBJECT_ID(N'dbo.Personality', N'U') IS NOT NULL DROP TABLE dbo.[Personality];
GO
IF OBJECT_ID(N'dbo.Level', N'U') IS NOT NULL DROP TABLE dbo.[Level];
GO
IF OBJECT_ID(N'dbo.StudentParent', N'U') IS NOT NULL DROP TABLE dbo.[StudentParent];
GO
IF OBJECT_ID(N'dbo.Teacher', N'U') IS NOT NULL DROP TABLE dbo.[Teacher];
GO
IF OBJECT_ID(N'dbo.Parent', N'U') IS NOT NULL DROP TABLE dbo.[Parent];
GO
IF OBJECT_ID(N'dbo.Student', N'U') IS NOT NULL DROP TABLE dbo.[Student];
GO
IF OBJECT_ID(N'dbo.User', N'U') IS NOT NULL DROP TABLE dbo.[User];
GO

CREATE TABLE dbo.[User] (
    [userId] NVARCHAR(10) NOT NULL,
    [username] NVARCHAR(50) NOT NULL,
    [password] NVARCHAR(255) NOT NULL,
    [email] NVARCHAR(100) NOT NULL,
    [role] NVARCHAR(20) NOT NULL,
    [preferredLanguage] NVARCHAR(5) NOT NULL,
    [status] NVARCHAR(20) NOT NULL,
    CONSTRAINT [PK_User] PRIMARY KEY ([userId]),
    CONSTRAINT [UQ_User_Email] UNIQUE ([email])
);
GO

CREATE TABLE dbo.[Student] (
    [studentId] NVARCHAR(10) NOT NULL,
    [userId] NVARCHAR(10) NULL,
    [name] NVARCHAR(150) NULL,
    [phoneNumber] NVARCHAR(20) NULL,
    [nickname] NVARCHAR(50) NULL,
    [currentLevelId] NVARCHAR(10) NULL,
    [XP] INT NULL,
    [personalityId] NVARCHAR(10) NULL,
    [parentCode] NVARCHAR(20) NULL,
    CONSTRAINT [PK_Student] PRIMARY KEY ([studentId]),
    CONSTRAINT [UQ_Student_ParentCode] UNIQUE ([parentCode])
);
GO

CREATE TABLE dbo.[Parent] (
    [parentId] NVARCHAR(10) NOT NULL,
    [userId] NVARCHAR(10) NULL,
    [name] NVARCHAR(150) NULL,
    [phoneNumber] NVARCHAR(20) NULL,
    CONSTRAINT [PK_Parent] PRIMARY KEY ([parentId])
);
GO

CREATE TABLE dbo.[Teacher] (
    [teacherId] NVARCHAR(10) NOT NULL,
    [userId] NVARCHAR(10) NULL,
    [name] NVARCHAR(150) NULL,
    [phoneNumber] NVARCHAR(20) NULL,
    [academicQualification] NVARCHAR(200) NULL,
    [bio] NVARCHAR(MAX) NULL,
    [licenseCert] NVARCHAR(255) NULL,
    [status] NVARCHAR(30) NULL,
    [approvedDate] DATE NULL,
    CONSTRAINT [PK_Teacher] PRIMARY KEY ([teacherId])
);
GO

CREATE TABLE dbo.[StudentParent] (
    [studentParentId] NVARCHAR(10) NOT NULL,
    [studentId] NVARCHAR(10) NULL,
    [parentId] NVARCHAR(10) NULL,
    [relationship] NVARCHAR(30) NULL,
    CONSTRAINT [PK_StudentParent] PRIMARY KEY ([studentParentId])
);
GO

CREATE TABLE dbo.[Level] (
    [levelId] NVARCHAR(10) NOT NULL,
    [levelNameEN] NVARCHAR(50) NOT NULL,
    [levelNameBM] NVARCHAR(50) NOT NULL,
    [levelDescriptionEN] NVARCHAR(MAX) NULL,
    [levelDescriptionBM] NVARCHAR(MAX) NULL,
    CONSTRAINT [PK_Level] PRIMARY KEY ([levelId])
);
GO

CREATE TABLE dbo.[Personality] (
    [personalityId] NVARCHAR(10) NOT NULL,
    [personalityNameEN] NVARCHAR(50) NOT NULL,
    [personalityNameBM] NVARCHAR(50) NULL,
    [descriptionEN] NVARCHAR(MAX) NULL,
    [descriptionBM] NVARCHAR(MAX) NULL,
    [avatar] NVARCHAR(255) NULL,
    [colour] NVARCHAR(20) NULL,
    [learningStyleEN] NVARCHAR(100) NULL,
    [learningStyleBM] NVARCHAR(100) NULL,
    CONSTRAINT [PK_Personality] PRIMARY KEY ([personalityId])
);
GO

CREATE TABLE dbo.[Badge] (
    [badgeId] NVARCHAR(10) NOT NULL,
    [badgeNameEN] NVARCHAR(100) NOT NULL,
    [badgeNameBM] NVARCHAR(100) NULL,
    [badgeType] NVARCHAR(30) NOT NULL,
    [xpReward] INT NULL,
    [badgeIcon] NVARCHAR(255) NULL,
    [requirementDescriptionEN] NVARCHAR(MAX) NULL,
    [requirementDescriptionBM] NVARCHAR(MAX) NULL,
    [badgeDescriptionEN] NVARCHAR(MAX) NULL,
    [badgeDescriptionBM] NVARCHAR(MAX) NULL,
    CONSTRAINT [PK_Badge] PRIMARY KEY ([badgeId])
);
GO

CREATE TABLE dbo.[StudentBadge] (
    [studentBadgeId] NVARCHAR(10) NOT NULL,
    [studentId] NVARCHAR(10) NULL,
    [badgeId] NVARCHAR(10) NULL,
    [earnedAt] DATETIME2(0) NULL,
    CONSTRAINT [PK_StudentBadge] PRIMARY KEY ([studentBadgeId])
);
GO

CREATE TABLE dbo.[Unit] (
    [unitId] NVARCHAR(10) NOT NULL,
    [levelId] NVARCHAR(10) NOT NULL,
    [unitNameEN] NVARCHAR(100) NOT NULL,
    [unitNameBM] NVARCHAR(100) NULL,
    [unitDescriptionEN] NVARCHAR(MAX) NULL,
    [unitDescriptionBM] NVARCHAR(MAX) NULL,
    [orderNo] INT NOT NULL,
    CONSTRAINT [PK_Unit] PRIMARY KEY ([unitId])
);
GO

CREATE TABLE dbo.[Subtopic] (
    [subtopicId] NVARCHAR(10) NOT NULL,
    [unitId] NVARCHAR(10) NOT NULL,
    [subtopicTitleEN] NVARCHAR(150) NULL,
    [subtopicTitleBM] NVARCHAR(150) NULL,
    [subtopicDescriptionEN] NVARCHAR(MAX) NULL,
    [subtopicDescriptionBM] NVARCHAR(MAX) NULL,
    [orderNo] INT NULL,
    CONSTRAINT [PK_Subtopic] PRIMARY KEY ([subtopicId])
);
GO

CREATE TABLE dbo.[Enrollment] (
    [enrollmentId] NVARCHAR(10) NOT NULL,
    [studentId] NVARCHAR(10) NULL,
    [levelId] NVARCHAR(10) NULL,
    [enrolledDate] DATE NULL,
    [status] NVARCHAR(20) NULL,
    CONSTRAINT [PK_Enrollment] PRIMARY KEY ([enrollmentId])
);
GO

CREATE TABLE dbo.[Lesson] (
    [lessonId] NVARCHAR(10) NOT NULL,
    [subtopicId] NVARCHAR(10) NOT NULL,
    [lessonTitleEN] NVARCHAR(150) NULL,
    [lessonTitleBM] NVARCHAR(150) NULL,
    [lessonContentEN] NVARCHAR(MAX) NULL,
    [lessonContentBM] NVARCHAR(MAX) NULL,
    [attachmentUrl] NVARCHAR(255) NULL,
    [orderNo] INT NULL,
    CONSTRAINT [PK_Lesson] PRIMARY KEY ([lessonId])
);
GO

CREATE TABLE dbo.[Quiz] (
    [quizId] NVARCHAR(10) NOT NULL,
    [levelId] NVARCHAR(10) NULL,
    [unitId] NVARCHAR(10) NULL,
    [subtopicId] NVARCHAR(10) NULL,
    [quizTitleEN] NVARCHAR(150) NULL,
    [quizTitleBM] NVARCHAR(150) NULL,
    [quizType] NVARCHAR(30) NULL,
    [status] NVARCHAR(30) NULL,
    [createdByUserId] NVARCHAR(10) NULL,
    [createdAt] DATETIME2(0) NULL,
    [language] NVARCHAR(10) NULL,
    CONSTRAINT [PK_Quiz] PRIMARY KEY ([quizId])
);
GO

CREATE TABLE dbo.[Material] (
    [materialId] NVARCHAR(10) NOT NULL,
    [subtopicId] NVARCHAR(10) NULL,
    [createdByUserId] NVARCHAR(10) NULL,
    [materialTitle] NVARCHAR(150) NULL,
    [materialType] NVARCHAR(30) NULL,
    [fileUrl] NVARCHAR(255) NULL,
    [materialContent] NVARCHAR(MAX) NULL,
    [createdDate] DATE NULL,
    [status] NVARCHAR(30) NULL,
    [reviewedDate] DATE NULL,
    [language] NVARCHAR(10) NULL,
    CONSTRAINT [PK_Material] PRIMARY KEY ([materialId])
);
GO

CREATE TABLE dbo.[Forum] (
    [forumId] NVARCHAR(10) NOT NULL,
    [createdBy] NVARCHAR(10) NULL,
    [title] NVARCHAR(200) NULL,
    [message] NVARCHAR(MAX) NULL,
    [discussionType] NVARCHAR(20) NULL,
    [createdAt] DATETIME2(0) NULL,
    CONSTRAINT [PK_Forum] PRIMARY KEY ([forumId])
);
GO

CREATE TABLE dbo.[ForumChat] (
    [forumChatId] NVARCHAR(10) NOT NULL,
    [forumId] NVARCHAR(10) NULL,
    [senderUserId] NVARCHAR(10) NULL,
    [message] NVARCHAR(MAX) NULL,
    [createdAt] DATETIME2(0) NULL,
    CONSTRAINT [PK_ForumChat] PRIMARY KEY ([forumChatId])
);
GO

CREATE TABLE dbo.[Tag] (
    [tagId] NVARCHAR(10) NOT NULL,
    [tagName] NVARCHAR(100) NULL,
    [createdAt] DATETIME2(0) NULL,
    CONSTRAINT [PK_Tag] PRIMARY KEY ([tagId])
);
GO

CREATE TABLE dbo.[ForumTag] (
    [forumTagId] NVARCHAR(10) NOT NULL,
    [forumId] NVARCHAR(10) NULL,
    [tagId] NVARCHAR(10) NULL,
    CONSTRAINT [PK_ForumTag] PRIMARY KEY ([forumTagId])
);
GO

CREATE TABLE dbo.[ForumLike] (
    [likeId] NVARCHAR(10) NOT NULL,
    [forumId] NVARCHAR(10) NULL,
    [senderUserId] NVARCHAR(10) NULL,
    [createdAt] DATETIME2(0) NULL,
    CONSTRAINT [PK_ForumLike] PRIMARY KEY ([likeId])
);
GO

CREATE TABLE dbo.[Question] (
    [questionId] NVARCHAR(10) NOT NULL,
    [quizId] NVARCHAR(10) NULL,
    [subtopicId] NVARCHAR(10) NULL,
    [createdByUserId] NVARCHAR(10) NULL,
    [questionTextEN] NVARCHAR(MAX) NULL,
    [questionTextBM] NVARCHAR(MAX) NULL,
    [questionType] NVARCHAR(30) NULL,
    [questionImageUrl] NVARCHAR(255) NULL,
    [optionA_EN] NVARCHAR(MAX) NULL,
    [optionA_BM] NVARCHAR(MAX) NULL,
    [optionB_EN] NVARCHAR(MAX) NULL,
    [optionB_BM] NVARCHAR(MAX) NULL,
    [optionC_EN] NVARCHAR(MAX) NULL,
    [optionC_BM] NVARCHAR(MAX) NULL,
    [optionD_EN] NVARCHAR(MAX) NULL,
    [optionD_BM] NVARCHAR(MAX) NULL,
    [correctAnswer] NVARCHAR(255) NULL,
    [correctExplanationEN] NVARCHAR(MAX) NULL,
    [correctExplanationBM] NVARCHAR(MAX) NULL,
    [wrongExplanationEN] NVARCHAR(MAX) NULL,
    [wrongExplanationBM] NVARCHAR(MAX) NULL,
    [difficulty] NVARCHAR(20) NULL,
    [status] NVARCHAR(30) NULL,
    [createdAt] DATETIME2(0) NULL,
    [reviewedDate] DATETIME2(0) NULL,
    CONSTRAINT [PK_Question] PRIMARY KEY ([questionId])
);
GO

CREATE TABLE dbo.[QuizResult] (
    [resultId] NVARCHAR(10) NOT NULL,
    [studentId] NVARCHAR(10) NULL,
    [quizId] NVARCHAR(10) NULL,
    [score] DECIMAL(6,2) NULL,
    [totalMarks] DECIMAL(6,2) NULL,
    [percentage] DECIMAL(5,2) NULL,
    [resultStatus] NVARCHAR(20) NULL,
    [attemptNo] INT NULL,
    [attemptedDate] DATETIME2(0) NULL,
    CONSTRAINT [PK_QuizResult] PRIMARY KEY ([resultId])
);
GO

CREATE TABLE dbo.[QuizAnswer] (
    [answerId] NVARCHAR(10) NOT NULL,
    [resultId] NVARCHAR(10) NULL,
    [questionId] NVARCHAR(10) NULL,
    [selectedAnswer] NVARCHAR(255) NULL,
    [isCorrect] BIT NULL,
    [marksAwarded] DECIMAL(6,2) NULL,
    CONSTRAINT [PK_QuizAnswer] PRIMARY KEY ([answerId])
);
GO

CREATE TABLE dbo.[XPAction] (
    [xpActionId] NVARCHAR(10) NOT NULL,
    [actionNameEN] NVARCHAR(100) NOT NULL,
    [actionNameBM] NVARCHAR(100) NULL,
    [xpValue] INT NOT NULL,
    CONSTRAINT [PK_XPAction] PRIMARY KEY ([xpActionId])
);
GO

CREATE TABLE dbo.[XPTransaction] (
    [xpTransactionId] NVARCHAR(10) NOT NULL,
    [studentId] NVARCHAR(10) NULL,
    [xpActionId] NVARCHAR(10) NULL,
    [xpAmount] INT NULL,
    [dateEarned] DATE NULL,
    CONSTRAINT [PK_XPTransaction] PRIMARY KEY ([xpTransactionId])
);
GO

CREATE TABLE dbo.[LessonProgress] (
    [progressId] NVARCHAR(10) NOT NULL,
    [studentId] NVARCHAR(10) NULL,
    [lessonId] NVARCHAR(10) NULL,
    [isCompleted] BIT NULL,
    [completedDate] DATE NULL,
    CONSTRAINT [PK_LessonProgress] PRIMARY KEY ([progressId])
);
GO

CREATE TABLE dbo.[Certificate] (
    [certificateId] NVARCHAR(10) NOT NULL,
    [studentId] NVARCHAR(10) NULL,
    [levelId] NVARCHAR(10) NULL,
    [certificateTitleEN] NVARCHAR(150) NULL,
    [certificateTitleBM] NVARCHAR(150) NULL,
    [certificateDescriptionEN] NVARCHAR(MAX) NULL,
    [certificateDescriptionBM] NVARCHAR(MAX) NULL,
    [issuedDate] DATE NULL,
    [certificateUrl] NVARCHAR(255) NULL,
    [certificateCode] NVARCHAR(50) NULL,
    [status] NVARCHAR(20) NULL,
    CONSTRAINT [PK_Certificate] PRIMARY KEY ([certificateId]),
    CONSTRAINT [UQ_Certificate_Code] UNIQUE ([certificateCode])
);
GO

CREATE TABLE dbo.[Log] (
    [logId] NVARCHAR(10) NOT NULL,
    [userId] NVARCHAR(10) NULL,
    [action] NVARCHAR(100) NULL,
    [description] NVARCHAR(MAX) NULL,
    [logDateTime] DATETIME2(0) NULL,
    [status] NVARCHAR(20) NULL,
    CONSTRAINT [PK_Log] PRIMARY KEY ([logId])
);
GO

CREATE TABLE dbo.[Notification] (
    [notificationId] NVARCHAR(10) NOT NULL,
    [toUserId] NVARCHAR(10) NULL,
    [titleEN] NVARCHAR(150) NULL,
    [titleBM] NVARCHAR(150) NULL,
    [messageEN] NVARCHAR(MAX) NULL,
    [messageBM] NVARCHAR(MAX) NULL,
    [isRead] BIT NULL,
    [createdAt] DATETIME2(0) NULL,
    CONSTRAINT [PK_Notification] PRIMARY KEY ([notificationId])
);
GO

CREATE TABLE dbo.[VirtualLab] (
    [labId] NVARCHAR(10) NOT NULL,
    [unitId] NVARCHAR(10) NULL,
    [labTitleEN] NVARCHAR(150) NULL,
    [labTitleBM] NVARCHAR(150) NULL,
    [labDescriptionEN] NVARCHAR(MAX) NULL,
    [labDescriptionBM] NVARCHAR(MAX) NULL,
    [instructionEN] NVARCHAR(MAX) NULL,
    [instructionBM] NVARCHAR(MAX) NULL,
    [labType] NVARCHAR(50) NULL,
    [difficulty] NVARCHAR(20) NULL,
    [createdAt] DATE NULL,
    CONSTRAINT [PK_VirtualLab] PRIMARY KEY ([labId])
);
GO

CREATE TABLE dbo.[LabProgress] (
    [labProgressId] NVARCHAR(10) NOT NULL,
    [studentId] NVARCHAR(10) NULL,
    [labId] NVARCHAR(10) NULL,
    [isCompleted] BIT NULL,
    [completedDate] DATE NULL,
    CONSTRAINT [PK_LabProgress] PRIMARY KEY ([labProgressId])
);
GO

CREATE TABLE dbo.[LiveConsultationSession] (
    [sessionId] NVARCHAR(10) NOT NULL,
    [teacherId] NVARCHAR(10) NULL,
    [unitId] NVARCHAR(10) NULL,
    [subtopicId] NVARCHAR(10) NULL,
    [sessionTitle] NVARCHAR(200) NULL,
    [sessionDescription] NVARCHAR(MAX) NULL,
    [meetingLink] NVARCHAR(255) NULL,
    [startDateTime] DATETIME2(0) NULL,
    [endDateTime] DATETIME2(0) NULL,
    [status] NVARCHAR(30) NULL,
    CONSTRAINT [PK_LiveConsultationSession] PRIMARY KEY ([sessionId])
);
GO

CREATE TABLE dbo.[LiveSessionParticipant] (
    [participantId] NVARCHAR(10) NOT NULL,
    [sessionId] NVARCHAR(10) NULL,
    [studentId] NVARCHAR(10) NULL,
    [joinedAt] DATETIME2(0) NULL,
    CONSTRAINT [PK_LiveSessionParticipant] PRIMARY KEY ([participantId])
);
GO

CREATE TABLE dbo.[UserStatusAction] (
    [actionId] NVARCHAR(10) NOT NULL,
    [userId] NVARCHAR(10) NULL,
    [actionType] NVARCHAR(30) NULL,
    [reason] NVARCHAR(MAX) NULL,
    [actionDate] DATE NULL,
    [performedBy] NVARCHAR(10) NULL,
    CONSTRAINT [PK_UserStatusAction] PRIMARY KEY ([actionId])
);
GO

CREATE TABLE dbo.[ConfigurationSetting] (
    [configId] NVARCHAR(10) NOT NULL,
    [configKey] NVARCHAR(100) NULL,
    [configValue] NVARCHAR(100) NULL,
    [lastUpdated] DATETIME2(0) NULL,
    CONSTRAINT [PK_ConfigurationSetting] PRIMARY KEY ([configId]),
    CONSTRAINT [UQ_ConfigurationSetting_Key] UNIQUE ([configKey])
);
GO

CREATE TABLE dbo.[AILearningAnalysis] (
    [analysisId] NVARCHAR(10) NOT NULL,
    [studentId] NVARCHAR(10) NULL,
    [analysisJson] NVARCHAR(MAX) NULL,
    [overallSummary] NVARCHAR(MAX) NULL,
    [strongTopics] NVARCHAR(MAX) NULL,
    [weakTopics] NVARCHAR(MAX) NULL,
    [avgQuizScore] DECIMAL(5,2) NULL,
    [totalQuizAttempts] INT NULL,
    [isLatest] BIT NULL,
    CONSTRAINT [PK_AILearningAnalysis] PRIMARY KEY ([analysisId])
);
GO

CREATE TABLE dbo.[StudyPlan] (
    [studyPlanId] NVARCHAR(10) NOT NULL,
    [studentParentId] NVARCHAR(10) NULL,
    [createdByUserId] NVARCHAR(10) NULL,
    [planTitle] NVARCHAR(200) NULL,
    [startDate] DATE NULL,
    [endDate] DATE NULL,
    [status] NVARCHAR(30) NULL,
    [createdAt] DATETIME2(0) NULL,
    CONSTRAINT [PK_StudyPlan] PRIMARY KEY ([studyPlanId])
);
GO

CREATE TABLE dbo.[SPTask] (
    [spTaskId] NVARCHAR(10) NOT NULL,
    [studyPlanId] NVARCHAR(10) NULL,
    [taskTitle] NVARCHAR(200) NULL,
    [suggestedAction] NVARCHAR(MAX) NULL,
    [orderNo] INT NULL,
    [isCompleted] BIT NULL,
    [completedAt] DATETIME2(0) NULL,
    CONSTRAINT [PK_SPTask] PRIMARY KEY ([spTaskId])
);
GO

CREATE TABLE dbo.[SPReward] (
    [rewardId] NVARCHAR(10) NOT NULL,
    [studyPlanId] NVARCHAR(10) NULL,
    [rewardName] NVARCHAR(200) NULL,
    [requiredProgress] INT NULL,
    [isUnlocked] BIT NULL,
    [unlockedAt] DATETIME2(0) NULL,
    CONSTRAINT [PK_SPReward] PRIMARY KEY ([rewardId])
);
GO

CREATE TABLE dbo.[userChat] (
    [chatId] NVARCHAR(10) NOT NULL,
    [userId] NVARCHAR(10) NULL,
    [user2Id] NVARCHAR(10) NULL,
    [createdAt] DATETIME2(0) NULL,
    CONSTRAINT [PK_userChat] PRIMARY KEY ([chatId])
);
GO

CREATE TABLE dbo.[privateMessage] (
    [privateMsgId] NVARCHAR(10) NOT NULL,
    [chatId] NVARCHAR(10) NULL,
    [senderUserId] NVARCHAR(10) NULL,
    [msgText] NVARCHAR(MAX) NULL,
    [attachmentFile] NVARCHAR(255) NULL,
    [sentAt] DATETIME2(0) NULL,
    [isRead] BIT NULL,
    [readAt] DATETIME2(0) NULL,
    CONSTRAINT [PK_privateMessage] PRIMARY KEY ([privateMsgId])
);
GO

-- Foreign keys
ALTER TABLE dbo.[Student] WITH CHECK ADD CONSTRAINT [FK_Student_userId_User] FOREIGN KEY ([userId]) REFERENCES dbo.[User]([userId]);
GO
ALTER TABLE dbo.[Student] WITH CHECK ADD CONSTRAINT [FK_Student_currentLevelId_Level] FOREIGN KEY ([currentLevelId]) REFERENCES dbo.[Level]([levelId]);
GO
ALTER TABLE dbo.[Student] WITH CHECK ADD CONSTRAINT [FK_Student_personalityId_Personality] FOREIGN KEY ([personalityId]) REFERENCES dbo.[Personality]([personalityId]);
GO
ALTER TABLE dbo.[Parent] WITH CHECK ADD CONSTRAINT [FK_Parent_userId_User] FOREIGN KEY ([userId]) REFERENCES dbo.[User]([userId]);
GO
ALTER TABLE dbo.[Teacher] WITH CHECK ADD CONSTRAINT [FK_Teacher_userId_User] FOREIGN KEY ([userId]) REFERENCES dbo.[User]([userId]);
GO
ALTER TABLE dbo.[StudentParent] WITH CHECK ADD CONSTRAINT [FK_StudentParent_studentId_Student] FOREIGN KEY ([studentId]) REFERENCES dbo.[Student]([studentId]);
GO
ALTER TABLE dbo.[StudentParent] WITH CHECK ADD CONSTRAINT [FK_StudentParent_parentId_Parent] FOREIGN KEY ([parentId]) REFERENCES dbo.[Parent]([parentId]);
GO
ALTER TABLE dbo.[StudentBadge] WITH CHECK ADD CONSTRAINT [FK_StudentBadge_studentId_Student] FOREIGN KEY ([studentId]) REFERENCES dbo.[Student]([studentId]);
GO
ALTER TABLE dbo.[StudentBadge] WITH CHECK ADD CONSTRAINT [FK_StudentBadge_badgeId_Badge] FOREIGN KEY ([badgeId]) REFERENCES dbo.[Badge]([badgeId]);
GO
ALTER TABLE dbo.[Unit] WITH CHECK ADD CONSTRAINT [FK_Unit_levelId_Level] FOREIGN KEY ([levelId]) REFERENCES dbo.[Level]([levelId]);
GO
ALTER TABLE dbo.[Subtopic] WITH CHECK ADD CONSTRAINT [FK_Subtopic_unitId_Unit] FOREIGN KEY ([unitId]) REFERENCES dbo.[Unit]([unitId]);
GO
ALTER TABLE dbo.[Enrollment] WITH CHECK ADD CONSTRAINT [FK_Enrollment_studentId_Student] FOREIGN KEY ([studentId]) REFERENCES dbo.[Student]([studentId]);
GO
ALTER TABLE dbo.[Enrollment] WITH CHECK ADD CONSTRAINT [FK_Enrollment_levelId_Level] FOREIGN KEY ([levelId]) REFERENCES dbo.[Level]([levelId]);
GO
ALTER TABLE dbo.[Lesson] WITH CHECK ADD CONSTRAINT [FK_Lesson_subtopicId_Subtopic] FOREIGN KEY ([subtopicId]) REFERENCES dbo.[Subtopic]([subtopicId]);
GO
ALTER TABLE dbo.[Quiz] WITH CHECK ADD CONSTRAINT [FK_Quiz_levelId_Level] FOREIGN KEY ([levelId]) REFERENCES dbo.[Level]([levelId]);
GO
ALTER TABLE dbo.[Quiz] WITH CHECK ADD CONSTRAINT [FK_Quiz_unitId_Unit] FOREIGN KEY ([unitId]) REFERENCES dbo.[Unit]([unitId]);
GO
ALTER TABLE dbo.[Quiz] WITH CHECK ADD CONSTRAINT [FK_Quiz_subtopicId_Subtopic] FOREIGN KEY ([subtopicId]) REFERENCES dbo.[Subtopic]([subtopicId]);
GO
ALTER TABLE dbo.[Quiz] WITH CHECK ADD CONSTRAINT [FK_Quiz_createdByUserId_User] FOREIGN KEY ([createdByUserId]) REFERENCES dbo.[User]([userId]);
GO
ALTER TABLE dbo.[Material] WITH CHECK ADD CONSTRAINT [FK_Material_subtopicId_Subtopic] FOREIGN KEY ([subtopicId]) REFERENCES dbo.[Subtopic]([subtopicId]);
GO
ALTER TABLE dbo.[Material] WITH CHECK ADD CONSTRAINT [FK_Material_createdByUserId_User] FOREIGN KEY ([createdByUserId]) REFERENCES dbo.[User]([userId]);
GO
ALTER TABLE dbo.[Forum] WITH CHECK ADD CONSTRAINT [FK_Forum_createdBy_User] FOREIGN KEY ([createdBy]) REFERENCES dbo.[User]([userId]);
GO
ALTER TABLE dbo.[ForumChat] WITH CHECK ADD CONSTRAINT [FK_ForumChat_forumId_Forum] FOREIGN KEY ([forumId]) REFERENCES dbo.[Forum]([forumId]);
GO
ALTER TABLE dbo.[ForumChat] WITH CHECK ADD CONSTRAINT [FK_ForumChat_senderUserId_User] FOREIGN KEY ([senderUserId]) REFERENCES dbo.[User]([userId]);
GO
ALTER TABLE dbo.[ForumTag] WITH CHECK ADD CONSTRAINT [FK_ForumTag_forumId_Forum] FOREIGN KEY ([forumId]) REFERENCES dbo.[Forum]([forumId]);
GO
ALTER TABLE dbo.[ForumTag] WITH CHECK ADD CONSTRAINT [FK_ForumTag_tagId_Tag] FOREIGN KEY ([tagId]) REFERENCES dbo.[Tag]([tagId]);
GO
ALTER TABLE dbo.[ForumLike] WITH CHECK ADD CONSTRAINT [FK_ForumLike_forumId_Forum] FOREIGN KEY ([forumId]) REFERENCES dbo.[Forum]([forumId]);
GO
ALTER TABLE dbo.[ForumLike] WITH CHECK ADD CONSTRAINT [FK_ForumLike_senderUserId_User] FOREIGN KEY ([senderUserId]) REFERENCES dbo.[User]([userId]);
GO
ALTER TABLE dbo.[Question] WITH CHECK ADD CONSTRAINT [FK_Question_quizId_Quiz] FOREIGN KEY ([quizId]) REFERENCES dbo.[Quiz]([quizId]);
GO
ALTER TABLE dbo.[Question] WITH CHECK ADD CONSTRAINT [FK_Question_subtopicId_Subtopic] FOREIGN KEY ([subtopicId]) REFERENCES dbo.[Subtopic]([subtopicId]);
GO
ALTER TABLE dbo.[Question] WITH CHECK ADD CONSTRAINT [FK_Question_createdByUserId_User] FOREIGN KEY ([createdByUserId]) REFERENCES dbo.[User]([userId]);
GO
ALTER TABLE dbo.[QuizResult] WITH CHECK ADD CONSTRAINT [FK_QuizResult_studentId_Student] FOREIGN KEY ([studentId]) REFERENCES dbo.[Student]([studentId]);
GO
ALTER TABLE dbo.[QuizResult] WITH CHECK ADD CONSTRAINT [FK_QuizResult_quizId_Quiz] FOREIGN KEY ([quizId]) REFERENCES dbo.[Quiz]([quizId]);
GO
ALTER TABLE dbo.[QuizAnswer] WITH CHECK ADD CONSTRAINT [FK_QuizAnswer_resultId_QuizResult] FOREIGN KEY ([resultId]) REFERENCES dbo.[QuizResult]([resultId]);
GO
ALTER TABLE dbo.[QuizAnswer] WITH CHECK ADD CONSTRAINT [FK_QuizAnswer_questionId_Question] FOREIGN KEY ([questionId]) REFERENCES dbo.[Question]([questionId]);
GO
ALTER TABLE dbo.[XPTransaction] WITH CHECK ADD CONSTRAINT [FK_XPTransaction_studentId_Student] FOREIGN KEY ([studentId]) REFERENCES dbo.[Student]([studentId]);
GO
ALTER TABLE dbo.[XPTransaction] WITH CHECK ADD CONSTRAINT [FK_XPTransaction_xpActionId_XPAction] FOREIGN KEY ([xpActionId]) REFERENCES dbo.[XPAction]([xpActionId]);
GO
ALTER TABLE dbo.[LessonProgress] WITH CHECK ADD CONSTRAINT [FK_LessonProgress_studentId_Student] FOREIGN KEY ([studentId]) REFERENCES dbo.[Student]([studentId]);
GO
ALTER TABLE dbo.[LessonProgress] WITH CHECK ADD CONSTRAINT [FK_LessonProgress_lessonId_Lesson] FOREIGN KEY ([lessonId]) REFERENCES dbo.[Lesson]([lessonId]);
GO
ALTER TABLE dbo.[Certificate] WITH CHECK ADD CONSTRAINT [FK_Certificate_studentId_Student] FOREIGN KEY ([studentId]) REFERENCES dbo.[Student]([studentId]);
GO
ALTER TABLE dbo.[Certificate] WITH CHECK ADD CONSTRAINT [FK_Certificate_levelId_Level] FOREIGN KEY ([levelId]) REFERENCES dbo.[Level]([levelId]);
GO
ALTER TABLE dbo.[Log] WITH CHECK ADD CONSTRAINT [FK_Log_userId_User] FOREIGN KEY ([userId]) REFERENCES dbo.[User]([userId]);
GO
ALTER TABLE dbo.[Notification] WITH CHECK ADD CONSTRAINT [FK_Notification_toUserId_User] FOREIGN KEY ([toUserId]) REFERENCES dbo.[User]([userId]);
GO
ALTER TABLE dbo.[VirtualLab] WITH CHECK ADD CONSTRAINT [FK_VirtualLab_unitId_Unit] FOREIGN KEY ([unitId]) REFERENCES dbo.[Unit]([unitId]);
GO
ALTER TABLE dbo.[LabProgress] WITH CHECK ADD CONSTRAINT [FK_LabProgress_studentId_Student] FOREIGN KEY ([studentId]) REFERENCES dbo.[Student]([studentId]);
GO
ALTER TABLE dbo.[LabProgress] WITH CHECK ADD CONSTRAINT [FK_LabProgress_labId_VirtualLab] FOREIGN KEY ([labId]) REFERENCES dbo.[VirtualLab]([labId]);
GO
ALTER TABLE dbo.[LiveConsultationSession] WITH CHECK ADD CONSTRAINT [FK_LiveConsultationSession_teacherId_Teacher] FOREIGN KEY ([teacherId]) REFERENCES dbo.[Teacher]([teacherId]);
GO
ALTER TABLE dbo.[LiveConsultationSession] WITH CHECK ADD CONSTRAINT [FK_LiveConsultationSession_unitId_Unit] FOREIGN KEY ([unitId]) REFERENCES dbo.[Unit]([unitId]);
GO
ALTER TABLE dbo.[LiveConsultationSession] WITH CHECK ADD CONSTRAINT [FK_LiveConsultationSession_subtopicId_Subtopic] FOREIGN KEY ([subtopicId]) REFERENCES dbo.[Subtopic]([subtopicId]);
GO
ALTER TABLE dbo.[LiveSessionParticipant] WITH CHECK ADD CONSTRAINT [FK_LiveSessionParticipant_sessionId_LiveConsultationSession] FOREIGN KEY ([sessionId]) REFERENCES dbo.[LiveConsultationSession]([sessionId]);
GO
ALTER TABLE dbo.[LiveSessionParticipant] WITH CHECK ADD CONSTRAINT [FK_LiveSessionParticipant_studentId_Student] FOREIGN KEY ([studentId]) REFERENCES dbo.[Student]([studentId]);
GO
ALTER TABLE dbo.[UserStatusAction] WITH CHECK ADD CONSTRAINT [FK_UserStatusAction_userId_User] FOREIGN KEY ([userId]) REFERENCES dbo.[User]([userId]);
GO
ALTER TABLE dbo.[UserStatusAction] WITH CHECK ADD CONSTRAINT [FK_UserStatusAction_performedBy_User] FOREIGN KEY ([performedBy]) REFERENCES dbo.[User]([userId]);
GO
ALTER TABLE dbo.[AILearningAnalysis] WITH CHECK ADD CONSTRAINT [FK_AILearningAnalysis_studentId_Student] FOREIGN KEY ([studentId]) REFERENCES dbo.[Student]([studentId]);
GO
ALTER TABLE dbo.[StudyPlan] WITH CHECK ADD CONSTRAINT [FK_StudyPlan_studentParentId_StudentParent] FOREIGN KEY ([studentParentId]) REFERENCES dbo.[StudentParent]([studentParentId]);
GO
ALTER TABLE dbo.[StudyPlan] WITH CHECK ADD CONSTRAINT [FK_StudyPlan_createdByUserId_User] FOREIGN KEY ([createdByUserId]) REFERENCES dbo.[User]([userId]);
GO
ALTER TABLE dbo.[SPTask] WITH CHECK ADD CONSTRAINT [FK_SPTask_studyPlanId_StudyPlan] FOREIGN KEY ([studyPlanId]) REFERENCES dbo.[StudyPlan]([studyPlanId]);
GO
ALTER TABLE dbo.[SPReward] WITH CHECK ADD CONSTRAINT [FK_SPReward_studyPlanId_StudyPlan] FOREIGN KEY ([studyPlanId]) REFERENCES dbo.[StudyPlan]([studyPlanId]);
GO
ALTER TABLE dbo.[userChat] WITH CHECK ADD CONSTRAINT [FK_userChat_userId_User] FOREIGN KEY ([userId]) REFERENCES dbo.[User]([userId]);
GO
ALTER TABLE dbo.[userChat] WITH CHECK ADD CONSTRAINT [FK_userChat_user2Id_User] FOREIGN KEY ([user2Id]) REFERENCES dbo.[User]([userId]);
GO
ALTER TABLE dbo.[privateMessage] WITH CHECK ADD CONSTRAINT [FK_privateMessage_chatId_userChat] FOREIGN KEY ([chatId]) REFERENCES dbo.[userChat]([chatId]);
GO
ALTER TABLE dbo.[privateMessage] WITH CHECK ADD CONSTRAINT [FK_privateMessage_senderUserId_User] FOREIGN KEY ([senderUserId]) REFERENCES dbo.[User]([userId]);
GO

-- Basic data-quality checks
ALTER TABLE dbo.[User] WITH CHECK ADD CONSTRAINT [CK_User_Role] CHECK ([role] IN (N'Admin',N'Student',N'Parent',N'Teacher'));
GO
ALTER TABLE dbo.[User] WITH CHECK ADD CONSTRAINT [CK_User_Language] CHECK ([preferredLanguage] IN (N'EN',N'BM'));
GO
ALTER TABLE dbo.[User] WITH CHECK ADD CONSTRAINT [CK_User_Status] CHECK ([status] IN (N'Active',N'Blocked',N'Deleted'));
GO
ALTER TABLE dbo.[Quiz] WITH CHECK ADD CONSTRAINT [CK_Quiz_Language] CHECK ([language] IS NULL OR [language] IN (N'EN',N'BM',N'BOTH'));
GO
ALTER TABLE dbo.[Material] WITH CHECK ADD CONSTRAINT [CK_Material_Language] CHECK ([language] IS NULL OR [language] IN (N'EN',N'BM',N'BOTH'));
GO


-- VERIFY_TABLES_CREATED
PRINT N'Verifying ScienceBuddy tables...';
SELECT COUNT(*) AS TablesCreated
FROM sys.tables
WHERE schema_id = SCHEMA_ID(N'dbo');
GO
PRINT N'CreateTables.sql completed successfully.';
GO
