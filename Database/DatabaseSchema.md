# ScienceBuddy Database Schema Guide


> **Important rule:** Use the exact table names and column names shown here. Do not rename columns in website code unless the SQL database schema is officially changed.

---

## 1. Database Name

```sql
ScienceBuddy_DB
```

Always run scripts using:

```sql
USE ScienceBuddy_DB;
GO
```

---

## 2. SQL Script Run Order

Run the files in this exact order.

| Order | File | Purpose |
|---:|---|---|
| 1 | `CreateTables_ImagesPath_Set.sql` | Creates ScienceBuddy_DB, drops/recreates all 41 tables, PKs, FKs, unique constraints, and check constraints. |
| 2 | `InsertConstants_ImagesPath.sql` | Inserts seeded/constant data such as levels, personalities, badges, units, subtopics, lessons, XP actions, tags, labs, and configuration settings. |
| 3 | `InsertSampleData_ImagesPath.sql` | Inserts sample users and activity data such as students, parents, teachers, quizzes, materials, forums, results, study plans, chats, and messages. |

Do not run insert scripts before table creation. If SQL Server says `Invalid object name`, it normally means the table creation script was not executed successfully or the query is running in the wrong database.

---

## 3. Global Naming and Coding Rules

- SQL Server schema is `dbo`.
- Always reference tables using `dbo.TableName`.
- Use `dbo.[User]` with square brackets because `User` can conflict with SQL Server reserved/context keywords.
- ID columns use string IDs such as `U001`, `S001`, `QST001`, `CERT001`.
- `BIT` values are stored as `1` or `0` in SQL Server.
- Use ISO date format in SQL inserts and updates: `YYYY-MM-DD` or `YYYY-MM-DD HH:MM:SS`.
- Bilingual content uses `EN` and `BM` suffixes where applicable.
- Current check constraints allow these language values:
  - `User.preferredLanguage`: `EN`, `BM`
  - `Quiz.language`: `EN`, `BM`, `BOTH`
  - `Material.language`: `EN`, `BM`, `BOTH`

---

## 4. File and Image Path Rules

All stored file/image paths must start with `Images/TableName/filename.ext`. Do not store only the filename for these columns.

| Table | Column | Required Path Prefix | Example |
|---|---|---|---|
| `Teacher` | `licenseCert` | `Images/Teacher/` | `Images/Teacher/cert_zara.pdf` |
| `Personality` | `avatar` | `Images/Personality/` | `Images/Personality/achiever.png` |
| `Badge` | `badgeIcon` | `Images/Badge/` | `Images/Badge/first-step.png` |
| `Lesson` | `attachmentUrl` | `Images/Lesson/` | `Images/Lesson/humansense.png` |
| `Material` | `fileUrl` | `Images/Material/` | `Images/Material/humansense.pdf` |
| `Question` | `questionImageUrl` | `Images/Question/` | `Images/Question/human_senses.jpg` |
| `Certificate` | `certificateUrl` | `Images/Certificate/` | `Images/Certificate/cert_s005_lv001.pdf` |
| `privateMessage` | `attachmentFile` | `Images/privateMessage/` | `Images/privateMessage/answer.pdf` |

### Path Handling Rules for Website Code

- Store relative paths only, not local machine paths like `C:\Users\...`.
- Do not include physical Windows paths in the database.
- For web display, combine the database value with the project root/static file handling.
- For `Question.questionImageUrl`, treat `NULL`, empty value, or `optional` as no image.
- For other attachment columns, prefer `NULL` when there is no attachment.

---

## 5. Table Summary

| No. | Table | Purpose | Seed/Sample Rows |
|---:|---|---|---:|
| 1 | `User` | Stores login credentials, user role, preferred language, and account status. | 24 |
| 2 | `Student` | Stores student profile, current level, XP, personality, and parent-linking code. | 11 |
| 3 | `Parent` | Stores parent profile information. | 6 |
| 4 | `Teacher` | Stores teacher profile, biography, certification file path, and approval status. | 6 |
| 5 | `StudentParent` | Junction table linking students to parents and relationship type. | 10 |
| 6 | `Level` | Seeded lookup table for learning levels. | 3 |
| 7 | `Personality` | Seeded lookup table for learner personalities and avatar/theme information. | 6 |
| 8 | `Badge` | Seeded lookup table for achievement badges and badge icons. | 10 |
| 9 | `StudentBadge` | Stores badges earned by students. | 22 |
| 10 | `Unit` | Stores learning units under each level. | 15 |
| 11 | `Subtopic` | Stores subtopics under each unit. | 44 |
| 12 | `Enrollment` | Stores student enrollment records by level. | 14 |
| 13 | `Lesson` | Stores core lesson content and lesson attachment file path. | 81 |
| 14 | `Quiz` | Stores quiz metadata for Unit, Level, and Practice quizzes. | 53 |
| 15 | `Material` | Stores teacher-uploaded learning support materials and review status. | 12 |
| 16 | `Forum` | Stores public/private forum discussion posts. | 17 |
| 17 | `ForumChat` | Stores replies/messages inside forum discussions. | 5 |
| 18 | `Tag` | Stores forum tag names. | 51 |
| 19 | `ForumTag` | Junction table linking forum posts to tags. | 14 |
| 20 | `ForumLike` | Stores likes on forum posts. | 10 |
| 21 | `Question` | Stores quiz questions, options, correct answers, explanations, image path, difficulty, and review status. | 99 |
| 22 | `QuizResult` | Stores quiz attempt result summaries. | 22 |
| 23 | `QuizAnswer` | Stores selected answers and marks for each quiz attempt. | 87 |
| 24 | `XPAction` | Seeded lookup table for XP action types and default XP values. | 9 |
| 25 | `XPTransaction` | Stores XP earned by students. | 19 |
| 26 | `LessonProgress` | Tracks lesson completion by student. | 26 |
| 27 | `Certificate` | Stores issued student certificates and certificate file paths. | 4 |
| 28 | `Log` | Stores system/user activity logs. | 20 |
| 29 | `Notification` | Stores bilingual notifications sent to users. | 15 |
| 30 | `VirtualLab` | Seeded interactive virtual lab activities. | 8 |
| 31 | `LabProgress` | Tracks virtual lab completion by student. | 12 |
| 32 | `LiveConsultationSession` | Stores teacher-hosted live consultation sessions. | 6 |
| 33 | `LiveSessionParticipant` | Stores attendance/participation records for live sessions. | 12 |
| 34 | `UserStatusAction` | Stores admin/status actions performed on user accounts. | 5 |
| 35 | `ConfigurationSetting` | Stores configurable application settings. | 14 |
| 36 | `AILearningAnalysis` | Stores AI-generated learning analysis summaries for students. | 8 |
| 37 | `StudyPlan` | Stores study plans created by parents/students/users. | 7 |
| 38 | `SPTask` | Stores tasks inside study plans. | 19 |
| 39 | `SPReward` | Stores rewards linked to study plans. | 12 |
| 40 | `userChat` | Stores private one-to-one chat rooms between two users. | 11 |
| 41 | `privateMessage` | Stores private messages inside user chats, including optional attachment file path. | 16 |

---

## 6. Seeded / Mostly Static Tables

These tables are inserted through `InsertConstants_ImagesPath.sql` and should normally be treated as seeded data.

| Table | Notes |
|---|---|
| `Level` | 3 levels: Beginner, Intermediate, Advanced. |
| `Personality` | 6 learner personalities: Achiever, Creative, Thinker, Go-Getter, Chill Learner, Socializer. |
| `Badge` | 10 achievement badges covering lesson, lab, quiz, unit, level, forum, and progress actions. |
| `Unit` | 15 units: 5 per level. |
| `Subtopic` | 44 subtopics mapped to units. |
| `Lesson` | 81 core/admin lessons mapped to subtopics. |
| `XPAction` | 9 XP actions. |
| `Tag` | 51 forum tags. |
| `VirtualLab` | 8 interactive lab activities. |
| `ConfigurationSetting` | 14 configurable system settings. |

---

## 7. Account, Access, and Status Rules

### User Login Rules

- Login uses `dbo.[User]`.
- Username/password must match.
- Only `status = 'Active'` can log in.
- `Blocked` users cannot log in.
- `Deleted` users cannot log in.

### User Roles

Allowed by check constraint:

- `Admin`
- `Student`
- `Parent`
- `Teacher`

### Teacher Certification Status

Use these values in application logic:

| Status | Meaning |
|---|---|
| `Pending` | Teacher has restricted access while waiting for approval. |
| `Certified` | Teacher can use full teacher features. |
| `Not Certified` | Teacher is restricted/rejected and may need to resubmit certification. |

### Content Review Status

Used in teacher-created content such as `Material`, `Question`, and teacher practice quizzes:

- `Pending`
- `Approved`
- `Rejected`
- `NULL` may exist for admin-created/unit/level content depending on sample data.

---

## 8. Main Learning Structure

The main content hierarchy is:

```text
Level
  -> Unit
      -> Subtopic
          -> Lesson
          -> Quiz / Question
          -> Material
          -> LiveConsultationSession
```

Student progress links into this structure through:

```text
Student
  -> Enrollment
  -> LessonProgress
  -> LabProgress
  -> QuizResult
      -> QuizAnswer
  -> StudentBadge
  -> XPTransaction
  -> Certificate
  -> AILearningAnalysis
```

Parent support features link through:

```text
Parent
  -> StudentParent
      -> StudyPlan
          -> SPTask
          -> SPReward
```

Communication features use:

```text
Forum
  -> ForumChat
  -> ForumTag
  -> ForumLike

userChat
  -> privateMessage
```

---

## 9. Main Foreign Key Relationships

| Child Table | FK Column | Parent Table | Parent Column | Constraint Name |
|---|---|---|---|---|
| `Student` | `userId` | `User` | `userId` | `FK_Student_userId_User` |
| `Student` | `currentLevelId` | `Level` | `levelId` | `FK_Student_currentLevelId_Level` |
| `Student` | `personalityId` | `Personality` | `personalityId` | `FK_Student_personalityId_Personality` |
| `Parent` | `userId` | `User` | `userId` | `FK_Parent_userId_User` |
| `Teacher` | `userId` | `User` | `userId` | `FK_Teacher_userId_User` |
| `StudentParent` | `studentId` | `Student` | `studentId` | `FK_StudentParent_studentId_Student` |
| `StudentParent` | `parentId` | `Parent` | `parentId` | `FK_StudentParent_parentId_Parent` |
| `StudentBadge` | `studentId` | `Student` | `studentId` | `FK_StudentBadge_studentId_Student` |
| `StudentBadge` | `badgeId` | `Badge` | `badgeId` | `FK_StudentBadge_badgeId_Badge` |
| `Unit` | `levelId` | `Level` | `levelId` | `FK_Unit_levelId_Level` |
| `Subtopic` | `unitId` | `Unit` | `unitId` | `FK_Subtopic_unitId_Unit` |
| `Enrollment` | `studentId` | `Student` | `studentId` | `FK_Enrollment_studentId_Student` |
| `Enrollment` | `levelId` | `Level` | `levelId` | `FK_Enrollment_levelId_Level` |
| `Lesson` | `subtopicId` | `Subtopic` | `subtopicId` | `FK_Lesson_subtopicId_Subtopic` |
| `Quiz` | `levelId` | `Level` | `levelId` | `FK_Quiz_levelId_Level` |
| `Quiz` | `unitId` | `Unit` | `unitId` | `FK_Quiz_unitId_Unit` |
| `Quiz` | `subtopicId` | `Subtopic` | `subtopicId` | `FK_Quiz_subtopicId_Subtopic` |
| `Quiz` | `createdByUserId` | `User` | `userId` | `FK_Quiz_createdByUserId_User` |
| `Material` | `subtopicId` | `Subtopic` | `subtopicId` | `FK_Material_subtopicId_Subtopic` |
| `Material` | `createdByUserId` | `User` | `userId` | `FK_Material_createdByUserId_User` |
| `Forum` | `createdBy` | `User` | `userId` | `FK_Forum_createdBy_User` |
| `ForumChat` | `forumId` | `Forum` | `forumId` | `FK_ForumChat_forumId_Forum` |
| `ForumChat` | `senderUserId` | `User` | `userId` | `FK_ForumChat_senderUserId_User` |
| `ForumTag` | `forumId` | `Forum` | `forumId` | `FK_ForumTag_forumId_Forum` |
| `ForumTag` | `tagId` | `Tag` | `tagId` | `FK_ForumTag_tagId_Tag` |
| `ForumLike` | `forumId` | `Forum` | `forumId` | `FK_ForumLike_forumId_Forum` |
| `ForumLike` | `senderUserId` | `User` | `userId` | `FK_ForumLike_senderUserId_User` |
| `Question` | `quizId` | `Quiz` | `quizId` | `FK_Question_quizId_Quiz` |
| `Question` | `subtopicId` | `Subtopic` | `subtopicId` | `FK_Question_subtopicId_Subtopic` |
| `Question` | `createdByUserId` | `User` | `userId` | `FK_Question_createdByUserId_User` |
| `QuizResult` | `studentId` | `Student` | `studentId` | `FK_QuizResult_studentId_Student` |
| `QuizResult` | `quizId` | `Quiz` | `quizId` | `FK_QuizResult_quizId_Quiz` |
| `QuizAnswer` | `resultId` | `QuizResult` | `resultId` | `FK_QuizAnswer_resultId_QuizResult` |
| `QuizAnswer` | `questionId` | `Question` | `questionId` | `FK_QuizAnswer_questionId_Question` |
| `XPTransaction` | `studentId` | `Student` | `studentId` | `FK_XPTransaction_studentId_Student` |
| `XPTransaction` | `xpActionId` | `XPAction` | `xpActionId` | `FK_XPTransaction_xpActionId_XPAction` |
| `LessonProgress` | `studentId` | `Student` | `studentId` | `FK_LessonProgress_studentId_Student` |
| `LessonProgress` | `lessonId` | `Lesson` | `lessonId` | `FK_LessonProgress_lessonId_Lesson` |
| `Certificate` | `studentId` | `Student` | `studentId` | `FK_Certificate_studentId_Student` |
| `Certificate` | `levelId` | `Level` | `levelId` | `FK_Certificate_levelId_Level` |
| `Log` | `userId` | `User` | `userId` | `FK_Log_userId_User` |
| `Notification` | `toUserId` | `User` | `userId` | `FK_Notification_toUserId_User` |
| `VirtualLab` | `unitId` | `Unit` | `unitId` | `FK_VirtualLab_unitId_Unit` |
| `LabProgress` | `studentId` | `Student` | `studentId` | `FK_LabProgress_studentId_Student` |
| `LabProgress` | `labId` | `VirtualLab` | `labId` | `FK_LabProgress_labId_VirtualLab` |
| `LiveConsultationSession` | `teacherId` | `Teacher` | `teacherId` | `FK_LiveConsultationSession_teacherId_Teacher` |
| `LiveConsultationSession` | `unitId` | `Unit` | `unitId` | `FK_LiveConsultationSession_unitId_Unit` |
| `LiveConsultationSession` | `subtopicId` | `Subtopic` | `subtopicId` | `FK_LiveConsultationSession_subtopicId_Subtopic` |
| `LiveSessionParticipant` | `sessionId` | `LiveConsultationSession` | `sessionId` | `FK_LiveSessionParticipant_sessionId_LiveConsultationSession` |
| `LiveSessionParticipant` | `studentId` | `Student` | `studentId` | `FK_LiveSessionParticipant_studentId_Student` |
| `UserStatusAction` | `userId` | `User` | `userId` | `FK_UserStatusAction_userId_User` |
| `UserStatusAction` | `performedBy` | `User` | `userId` | `FK_UserStatusAction_performedBy_User` |
| `AILearningAnalysis` | `studentId` | `Student` | `studentId` | `FK_AILearningAnalysis_studentId_Student` |
| `StudyPlan` | `studentParentId` | `StudentParent` | `studentParentId` | `FK_StudyPlan_studentParentId_StudentParent` |
| `StudyPlan` | `createdByUserId` | `User` | `userId` | `FK_StudyPlan_createdByUserId_User` |
| `SPTask` | `studyPlanId` | `StudyPlan` | `studyPlanId` | `FK_SPTask_studyPlanId_StudyPlan` |
| `SPReward` | `studyPlanId` | `StudyPlan` | `studyPlanId` | `FK_SPReward_studyPlanId_StudyPlan` |
| `userChat` | `userId` | `User` | `userId` | `FK_userChat_userId_User` |
| `userChat` | `user2Id` | `User` | `userId` | `FK_userChat_user2Id_User` |
| `privateMessage` | `chatId` | `userChat` | `chatId` | `FK_privateMessage_chatId_userChat` |
| `privateMessage` | `senderUserId` | `User` | `userId` | `FK_privateMessage_senderUserId_User` |

---

## 10. Check Constraints

| Table | Constraint | Rule |
|---|---|---|
| `Student` | `FK_Student_userId_User] FOREIGN KEY ([userId]) REFERENCES dbo.[User]([userId]);
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
ALTER TABLE dbo.[User] WITH CHECK ADD CONSTRAINT [CK_User_Role` | `[role] IN (N'Admin',N'Student',N'Parent',N'Teacher')` |
| `User` | `CK_User_Language` | `[preferredLanguage] IN (N'EN',N'BM')` |
| `User` | `CK_User_Status` | `[status] IN (N'Active',N'Blocked',N'Deleted')` |
| `Quiz` | `CK_Quiz_Language` | `[language] IS NULL OR [language] IN (N'EN',N'BM',N'BOTH')` |
| `Material` | `CK_Material_Language` | `[language] IS NULL OR [language] IN (N'EN',N'BM',N'BOTH')` |

---

# Table Details

## 1. `User`

Stores login credentials, user role, preferred language, and account status.

Seed/sample script currently inserts **24 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `userId` | `NVARCHAR(10)` | No | PK | Unique user account ID, e.g. U001. |
| `username` | `NVARCHAR(50)` | No | - | Login username. |
| `password` | `NVARCHAR(255)` | No | - | Login password. For real deployment, store hashed passwords, not plain text. |
| `email` | `NVARCHAR(100)` | No | UNIQUE | User email address. |
| `role` | `NVARCHAR(20)` | No | - | User role: Admin, Student, Parent, or Teacher. |
| `preferredLanguage` | `NVARCHAR(5)` | No | - | User interface language preference: EN or BM. |
| `status` | `NVARCHAR(20)` | No | - | Account status: Active, Blocked, or Deleted. |

### Important Notes

- Use `dbo.[User]` with square brackets in SQL because `USER` is a SQL Server keyword/context function.
- Only users with `status = 'Active'` should be allowed to log in.
- The current schema makes `email` unique. `username` is not marked unique in the latest SQL script, so enforce unique username in the application if needed or add a DB constraint later.

## 2. `Student`

Stores student profile, current level, XP, personality, and parent-linking code.

Seed/sample script currently inserts **11 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `studentId` | `NVARCHAR(10)` | No | PK | Unique student ID, e.g. S001. |
| `userId` | `NVARCHAR(10)` | Yes | FK -> `User.userId` | Unique user account ID, e.g. U001. |
| `name` | `NVARCHAR(150)` | Yes | - | Full name. |
| `phoneNumber` | `NVARCHAR(20)` | Yes | - | Phone number. |
| `nickname` | `NVARCHAR(50)` | Yes | - | Display nickname. |
| `currentLevelId` | `NVARCHAR(10)` | Yes | FK -> `Level.levelId` | Current learning level ID. |
| `XP` | `INT` | Yes | - | Total student XP. |
| `personalityId` | `NVARCHAR(10)` | Yes | FK -> `Personality.personalityId` | Selected/assigned learning personality. |
| `parentCode` | `NVARCHAR(20)` | Yes | UNIQUE | Unique code used to link parent with student. |

### Foreign Keys

- `userId` references `User.userId` (`FK_Student_userId_User`).
- `currentLevelId` references `Level.levelId` (`FK_Student_currentLevelId_Level`).
- `personalityId` references `Personality.personalityId` (`FK_Student_personalityId_Personality`).

### Important Notes

- A student profile links back to one `User` account.
- `parentCode` is unique and used by parents to link to a child.

## 3. `Parent`

Stores parent profile information.

Seed/sample script currently inserts **6 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `parentId` | `NVARCHAR(10)` | No | PK | Unique parent ID, e.g. P001. |
| `userId` | `NVARCHAR(10)` | Yes | FK -> `User.userId` | Unique user account ID, e.g. U001. |
| `name` | `NVARCHAR(150)` | Yes | - | Full name. |
| `phoneNumber` | `NVARCHAR(20)` | Yes | - | Phone number. |

### Foreign Keys

- `userId` references `User.userId` (`FK_Parent_userId_User`).

## 4. `Teacher`

Stores teacher profile, biography, certification file path, and approval status.

Seed/sample script currently inserts **6 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `teacherId` | `NVARCHAR(10)` | No | PK | Unique teacher ID, e.g. T001. |
| `userId` | `NVARCHAR(10)` | Yes | FK -> `User.userId` | Unique user account ID, e.g. U001. |
| `name` | `NVARCHAR(150)` | Yes | - | Full name. |
| `phoneNumber` | `NVARCHAR(20)` | Yes | - | Phone number. |
| `academicQualification` | `NVARCHAR(200)` | Yes | - | Teacher academic qualification. |
| `bio` | `NVARCHAR(MAX)` | Yes | - | Teacher biography. |
| `licenseCert` | `NVARCHAR(255)` | Yes | - | Teacher certificate/license file path. |
| `status` | `NVARCHAR(30)` | Yes | - | Account status: Active, Blocked, or Deleted. |
| `approvedDate` | `DATE` | Yes | - | Teacher approval/review date. |

### Foreign Keys

- `userId` references `User.userId` (`FK_Teacher_userId_User`).

### Important Notes

- `status` uses the teacher certification workflow: `Pending`, `Certified`, `Not Certified`.
- `licenseCert` must use the path prefix `Images/Teacher/`.

## 5. `StudentParent`

Junction table linking students to parents and relationship type.

Seed/sample script currently inserts **10 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `studentParentId` | `NVARCHAR(10)` | No | PK | Unique student-parent relationship ID. |
| `studentId` | `NVARCHAR(10)` | Yes | FK -> `Student.studentId` | Unique student ID, e.g. S001. |
| `parentId` | `NVARCHAR(10)` | Yes | FK -> `Parent.parentId` | Unique parent ID, e.g. P001. |
| `relationship` | `NVARCHAR(30)` | Yes | - | Relationship to student, e.g. Mother, Father, Guardian. |

### Foreign Keys

- `studentId` references `Student.studentId` (`FK_StudentParent_studentId_Student`).
- `parentId` references `Parent.parentId` (`FK_StudentParent_parentId_Parent`).

## 6. `Level`

Seeded lookup table for learning levels.

Seed/sample script currently inserts **3 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `levelId` | `NVARCHAR(10)` | No | PK | Unique learning level ID. |
| `levelNameEN` | `NVARCHAR(50)` | No | - | English level name. |
| `levelNameBM` | `NVARCHAR(50)` | No | - | Malay level name. |
| `levelDescriptionEN` | `NVARCHAR(MAX)` | Yes | - | English level description. |
| `levelDescriptionBM` | `NVARCHAR(MAX)` | Yes | - | Malay level description. |

## 7. `Personality`

Seeded lookup table for learner personalities and avatar/theme information.

Seed/sample script currently inserts **6 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `personalityId` | `NVARCHAR(10)` | No | PK | Selected/assigned learning personality. |
| `personalityNameEN` | `NVARCHAR(50)` | No | - | English personality name. |
| `personalityNameBM` | `NVARCHAR(50)` | Yes | - | Malay personality name. |
| `descriptionEN` | `NVARCHAR(MAX)` | Yes | - | English description. |
| `descriptionBM` | `NVARCHAR(MAX)` | Yes | - | Malay description. |
| `avatar` | `NVARCHAR(255)` | Yes | - | Personality avatar image path. |
| `colour` | `NVARCHAR(20)` | Yes | - | Hex colour used for personality theme. |
| `learningStyleEN` | `NVARCHAR(100)` | Yes | - | English learning style label. |
| `learningStyleBM` | `NVARCHAR(100)` | Yes | - | Malay learning style label. |

### Important Notes

- `avatar` must use the path prefix `Images/Personality/`.

## 8. `Badge`

Seeded lookup table for achievement badges and badge icons.

Seed/sample script currently inserts **10 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `badgeId` | `NVARCHAR(10)` | No | PK | Unique badge ID. |
| `badgeNameEN` | `NVARCHAR(100)` | No | - | English badge name. |
| `badgeNameBM` | `NVARCHAR(100)` | Yes | - | Malay badge name. |
| `badgeType` | `NVARCHAR(30)` | No | - | Badge category/type. |
| `xpReward` | `INT` | Yes | - | XP rewarded for earning badge. |
| `badgeIcon` | `NVARCHAR(255)` | Yes | - | Badge icon image path. |
| `requirementDescriptionEN` | `NVARCHAR(MAX)` | Yes | - | English requirement description. |
| `requirementDescriptionBM` | `NVARCHAR(MAX)` | Yes | - | Malay requirement description. |
| `badgeDescriptionEN` | `NVARCHAR(MAX)` | Yes | - | English badge description. |
| `badgeDescriptionBM` | `NVARCHAR(MAX)` | Yes | - | Malay badge description. |

### Important Notes

- `badgeIcon` must use the path prefix `Images/Badge/`.

## 9. `StudentBadge`

Stores badges earned by students.

Seed/sample script currently inserts **22 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `studentBadgeId` | `NVARCHAR(10)` | No | PK | Unique earned-badge record ID. |
| `studentId` | `NVARCHAR(10)` | Yes | FK -> `Student.studentId` | Unique student ID, e.g. S001. |
| `badgeId` | `NVARCHAR(10)` | Yes | FK -> `Badge.badgeId` | Unique badge ID. |
| `earnedAt` | `DATETIME2(0)` | Yes | - | Date/time badge was earned. |

### Foreign Keys

- `studentId` references `Student.studentId` (`FK_StudentBadge_studentId_Student`).
- `badgeId` references `Badge.badgeId` (`FK_StudentBadge_badgeId_Badge`).

## 10. `Unit`

Stores learning units under each level.

Seed/sample script currently inserts **15 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `unitId` | `NVARCHAR(10)` | No | PK | Unique unit ID. |
| `levelId` | `NVARCHAR(10)` | No | FK -> `Level.levelId` | Unique learning level ID. |
| `unitNameEN` | `NVARCHAR(100)` | No | - | English unit name. |
| `unitNameBM` | `NVARCHAR(100)` | Yes | - | Malay unit name. |
| `unitDescriptionEN` | `NVARCHAR(MAX)` | Yes | - | English unit description. |
| `unitDescriptionBM` | `NVARCHAR(MAX)` | Yes | - | Malay unit description. |
| `orderNo` | `INT` | No | - | Display/order number. |

### Foreign Keys

- `levelId` references `Level.levelId` (`FK_Unit_levelId_Level`).

## 11. `Subtopic`

Stores subtopics under each unit.

Seed/sample script currently inserts **44 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `subtopicId` | `NVARCHAR(10)` | No | PK | Unique subtopic ID. |
| `unitId` | `NVARCHAR(10)` | No | FK -> `Unit.unitId` | Unique unit ID. |
| `subtopicTitleEN` | `NVARCHAR(150)` | Yes | - | English subtopic title. |
| `subtopicTitleBM` | `NVARCHAR(150)` | Yes | - | Malay subtopic title. |
| `subtopicDescriptionEN` | `NVARCHAR(MAX)` | Yes | - | English subtopic description. |
| `subtopicDescriptionBM` | `NVARCHAR(MAX)` | Yes | - | Malay subtopic description. |
| `orderNo` | `INT` | Yes | - | Display/order number. |

### Foreign Keys

- `unitId` references `Unit.unitId` (`FK_Subtopic_unitId_Unit`).

## 12. `Enrollment`

Stores student enrollment records by level.

Seed/sample script currently inserts **14 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `enrollmentId` | `NVARCHAR(10)` | No | PK | Unique enrollment record ID. |
| `studentId` | `NVARCHAR(10)` | Yes | FK -> `Student.studentId` | Unique student ID, e.g. S001. |
| `levelId` | `NVARCHAR(10)` | Yes | FK -> `Level.levelId` | Unique learning level ID. |
| `enrolledDate` | `DATE` | Yes | - | Date student enrolled in level. |
| `status` | `NVARCHAR(20)` | Yes | - | Account status: Active, Blocked, or Deleted. |

### Foreign Keys

- `studentId` references `Student.studentId` (`FK_Enrollment_studentId_Student`).
- `levelId` references `Level.levelId` (`FK_Enrollment_levelId_Level`).

## 13. `Lesson`

Stores core lesson content and lesson attachment file path.

Seed/sample script currently inserts **81 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `lessonId` | `NVARCHAR(10)` | No | PK | Unique lesson ID. |
| `subtopicId` | `NVARCHAR(10)` | No | FK -> `Subtopic.subtopicId` | Unique subtopic ID. |
| `lessonTitleEN` | `NVARCHAR(150)` | Yes | - | English lesson title. |
| `lessonTitleBM` | `NVARCHAR(150)` | Yes | - | Malay lesson title. |
| `lessonContentEN` | `NVARCHAR(MAX)` | Yes | - | English lesson content. |
| `lessonContentBM` | `NVARCHAR(MAX)` | Yes | - | Malay lesson content. |
| `attachmentUrl` | `NVARCHAR(255)` | Yes | - | Lesson attachment file path. |
| `orderNo` | `INT` | Yes | - | Display/order number. |

### Foreign Keys

- `subtopicId` references `Subtopic.subtopicId` (`FK_Lesson_subtopicId_Subtopic`).

### Important Notes

- `attachmentUrl` must use the path prefix `Images/Lesson/` when an attachment exists.

## 14. `Quiz`

Stores quiz metadata for Unit, Level, and Practice quizzes.

Seed/sample script currently inserts **53 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `quizId` | `NVARCHAR(10)` | No | PK | Unique quiz ID. |
| `levelId` | `NVARCHAR(10)` | Yes | FK -> `Level.levelId` | Unique learning level ID. |
| `unitId` | `NVARCHAR(10)` | Yes | FK -> `Unit.unitId` | Unique unit ID. |
| `subtopicId` | `NVARCHAR(10)` | Yes | FK -> `Subtopic.subtopicId` | Unique subtopic ID. |
| `quizTitleEN` | `NVARCHAR(150)` | Yes | - | English quiz title. |
| `quizTitleBM` | `NVARCHAR(150)` | Yes | - | Malay quiz title. |
| `quizType` | `NVARCHAR(30)` | Yes | - | Quiz type: Unit, Level, or Practice. |
| `status` | `NVARCHAR(30)` | Yes | - | Account status: Active, Blocked, or Deleted. |
| `createdByUserId` | `NVARCHAR(10)` | Yes | FK -> `User.userId` | User who created the record. |
| `createdAt` | `DATETIME2(0)` | Yes | - | Creation date/time. |
| `language` | `NVARCHAR(10)` | Yes | - | Content language: EN, BM, or BOTH. |

### Foreign Keys

- `levelId` references `Level.levelId` (`FK_Quiz_levelId_Level`).
- `unitId` references `Unit.unitId` (`FK_Quiz_unitId_Unit`).
- `subtopicId` references `Subtopic.subtopicId` (`FK_Quiz_subtopicId_Subtopic`).
- `createdByUserId` references `User.userId` (`FK_Quiz_createdByUserId_User`).

### Important Notes

- `quizType` supports `Unit`, `Level`, and `Practice`.
- Level quizzes may have `unitId` and `subtopicId` as `NULL`; the schema allows this.
- `language` must be `EN`, `BM`, or `BOTH` because of the check constraint.

## 15. `Material`

Stores teacher-uploaded learning support materials and review status.

Seed/sample script currently inserts **12 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `materialId` | `NVARCHAR(10)` | No | PK | Unique material ID. |
| `subtopicId` | `NVARCHAR(10)` | Yes | FK -> `Subtopic.subtopicId` | Unique subtopic ID. |
| `createdByUserId` | `NVARCHAR(10)` | Yes | FK -> `User.userId` | User who created the record. |
| `materialTitle` | `NVARCHAR(150)` | Yes | - | Material title. |
| `materialType` | `NVARCHAR(30)` | Yes | - | Material type, e.g. PDF, Image, Video, PPTX. |
| `fileUrl` | `NVARCHAR(255)` | Yes | - | Material file path. |
| `materialContent` | `NVARCHAR(MAX)` | Yes | - | Description or text content. |
| `createdDate` | `DATE` | Yes | - | Created/uploaded date. |
| `status` | `NVARCHAR(30)` | Yes | - | Account status: Active, Blocked, or Deleted. |
| `reviewedDate` | `DATE` | Yes | - | Reviewed date/time. |
| `language` | `NVARCHAR(10)` | Yes | - | Content language: EN, BM, or BOTH. |

### Foreign Keys

- `subtopicId` references `Subtopic.subtopicId` (`FK_Material_subtopicId_Subtopic`).
- `createdByUserId` references `User.userId` (`FK_Material_createdByUserId_User`).

### Important Notes

- `fileUrl` must use the path prefix `Images/Material/` when a file exists.
- `language` must be `EN`, `BM`, or `BOTH` because of the check constraint.
- Teacher-uploaded material should normally be reviewed before students see it.

## 16. `Forum`

Stores public/private forum discussion posts.

Seed/sample script currently inserts **17 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `forumId` | `NVARCHAR(10)` | No | PK | Unique forum post ID. |
| `createdBy` | `NVARCHAR(10)` | Yes | FK -> `User.userId` | User who created the forum post. |
| `title` | `NVARCHAR(200)` | Yes | - | Forum title. |
| `message` | `NVARCHAR(MAX)` | Yes | - | Forum/message body. |
| `discussionType` | `NVARCHAR(20)` | Yes | - | Public or Private. |
| `createdAt` | `DATETIME2(0)` | Yes | - | Creation date/time. |

### Foreign Keys

- `createdBy` references `User.userId` (`FK_Forum_createdBy_User`).

## 17. `ForumChat`

Stores replies/messages inside forum discussions.

Seed/sample script currently inserts **5 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `forumChatId` | `NVARCHAR(10)` | No | PK | Unique forum reply/chat ID. |
| `forumId` | `NVARCHAR(10)` | Yes | FK -> `Forum.forumId` | Unique forum post ID. |
| `senderUserId` | `NVARCHAR(10)` | Yes | FK -> `User.userId` | User who sent message/like/answer. |
| `message` | `NVARCHAR(MAX)` | Yes | - | Forum/message body. |
| `createdAt` | `DATETIME2(0)` | Yes | - | Creation date/time. |

### Foreign Keys

- `forumId` references `Forum.forumId` (`FK_ForumChat_forumId_Forum`).
- `senderUserId` references `User.userId` (`FK_ForumChat_senderUserId_User`).

## 18. `Tag`

Stores forum tag names.

Seed/sample script currently inserts **51 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `tagId` | `NVARCHAR(10)` | No | PK | Unique tag ID. |
| `tagName` | `NVARCHAR(100)` | Yes | - | Tag display name. |
| `createdAt` | `DATETIME2(0)` | Yes | - | Creation date/time. |

## 19. `ForumTag`

Junction table linking forum posts to tags.

Seed/sample script currently inserts **14 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `forumTagId` | `NVARCHAR(10)` | No | PK | Unique forum-tag ID. |
| `forumId` | `NVARCHAR(10)` | Yes | FK -> `Forum.forumId` | Unique forum post ID. |
| `tagId` | `NVARCHAR(10)` | Yes | FK -> `Tag.tagId` | Unique tag ID. |

### Foreign Keys

- `forumId` references `Forum.forumId` (`FK_ForumTag_forumId_Forum`).
- `tagId` references `Tag.tagId` (`FK_ForumTag_tagId_Tag`).

## 20. `ForumLike`

Stores likes on forum posts.

Seed/sample script currently inserts **10 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `likeId` | `NVARCHAR(10)` | No | PK | Unique forum-like ID. |
| `forumId` | `NVARCHAR(10)` | Yes | FK -> `Forum.forumId` | Unique forum post ID. |
| `senderUserId` | `NVARCHAR(10)` | Yes | FK -> `User.userId` | User who sent message/like/answer. |
| `createdAt` | `DATETIME2(0)` | Yes | - | Creation date/time. |

### Foreign Keys

- `forumId` references `Forum.forumId` (`FK_ForumLike_forumId_Forum`).
- `senderUserId` references `User.userId` (`FK_ForumLike_senderUserId_User`).

## 21. `Question`

Stores quiz questions, options, correct answers, explanations, image path, difficulty, and review status.

Seed/sample script currently inserts **99 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `questionId` | `NVARCHAR(10)` | No | PK | Unique question ID. |
| `quizId` | `NVARCHAR(10)` | Yes | FK -> `Quiz.quizId` | Unique quiz ID. |
| `subtopicId` | `NVARCHAR(10)` | Yes | FK -> `Subtopic.subtopicId` | Unique subtopic ID. |
| `createdByUserId` | `NVARCHAR(10)` | Yes | FK -> `User.userId` | User who created the record. |
| `questionTextEN` | `NVARCHAR(MAX)` | Yes | - | English question text. |
| `questionTextBM` | `NVARCHAR(MAX)` | Yes | - | Malay question text. |
| `questionType` | `NVARCHAR(30)` | Yes | - | Question type such as MCQ, True/False, Drag & Drop, or Multiselect. |
| `questionImageUrl` | `NVARCHAR(255)` | Yes | - | Optional question image path or no-image marker. |
| `optionA_EN` | `NVARCHAR(MAX)` | Yes | - | Option A in English. |
| `optionA_BM` | `NVARCHAR(MAX)` | Yes | - | Option A in Malay. |
| `optionB_EN` | `NVARCHAR(MAX)` | Yes | - | Option B in English. |
| `optionB_BM` | `NVARCHAR(MAX)` | Yes | - | Option B in Malay. |
| `optionC_EN` | `NVARCHAR(MAX)` | Yes | - | Option C in English. |
| `optionC_BM` | `NVARCHAR(MAX)` | Yes | - | Option C in Malay. |
| `optionD_EN` | `NVARCHAR(MAX)` | Yes | - | Option D in English. |
| `optionD_BM` | `NVARCHAR(MAX)` | Yes | - | Option D in Malay. |
| `correctAnswer` | `NVARCHAR(255)` | Yes | - | Correct answer value; may be A/B/C/D, comma-separated selections, or drag/drop text. |
| `correctExplanationEN` | `NVARCHAR(MAX)` | Yes | - | English explanation for correct answer. |
| `correctExplanationBM` | `NVARCHAR(MAX)` | Yes | - | Malay explanation for correct answer. |
| `wrongExplanationEN` | `NVARCHAR(MAX)` | Yes | - | English explanation for wrong answer. |
| `wrongExplanationBM` | `NVARCHAR(MAX)` | Yes | - | Malay explanation for wrong answer. |
| `difficulty` | `NVARCHAR(20)` | Yes | - | Question difficulty: Easy, Medium, or Hard. |
| `status` | `NVARCHAR(30)` | Yes | - | Account status: Active, Blocked, or Deleted. |
| `createdAt` | `DATETIME2(0)` | Yes | - | Creation date/time. |
| `reviewedDate` | `DATETIME2(0)` | Yes | - | Reviewed date/time. |

### Foreign Keys

- `quizId` references `Quiz.quizId` (`FK_Question_quizId_Quiz`).
- `subtopicId` references `Subtopic.subtopicId` (`FK_Question_subtopicId_Subtopic`).
- `createdByUserId` references `User.userId` (`FK_Question_createdByUserId_User`).

### Important Notes

- `questionImageUrl` must use the path prefix `Images/Question/` for real image files.
- Some sample rows use `optional` to mean no image. In application code, treat `NULL`, empty string, or `optional` as no image.
- For multiselect answers, comma-separated values such as `A,B,D` are used.
- For drag/drop answers, text values may be used in `correctAnswer`.

## 22. `QuizResult`

Stores quiz attempt result summaries.

Seed/sample script currently inserts **22 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `resultId` | `NVARCHAR(10)` | No | PK | Unique quiz result/attempt ID. |
| `studentId` | `NVARCHAR(10)` | Yes | FK -> `Student.studentId` | Unique student ID, e.g. S001. |
| `quizId` | `NVARCHAR(10)` | Yes | FK -> `Quiz.quizId` | Unique quiz ID. |
| `score` | `DECIMAL(6,2)` | Yes | - | Score achieved. |
| `totalMarks` | `DECIMAL(6,2)` | Yes | - | Total possible marks. |
| `percentage` | `DECIMAL(5,2)` | Yes | - | Percentage score. |
| `resultStatus` | `NVARCHAR(20)` | Yes | - | Result status, e.g. Passed or Failed. |
| `attemptNo` | `INT` | Yes | - | Attempt number. |
| `attemptedDate` | `DATETIME2(0)` | Yes | - | Attempt date/time. |

### Foreign Keys

- `studentId` references `Student.studentId` (`FK_QuizResult_studentId_Student`).
- `quizId` references `Quiz.quizId` (`FK_QuizResult_quizId_Quiz`).

## 23. `QuizAnswer`

Stores selected answers and marks for each quiz attempt.

Seed/sample script currently inserts **87 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `answerId` | `NVARCHAR(10)` | No | PK | Unique quiz answer ID. |
| `resultId` | `NVARCHAR(10)` | Yes | FK -> `QuizResult.resultId` | Unique quiz result/attempt ID. |
| `questionId` | `NVARCHAR(10)` | Yes | FK -> `Question.questionId` | Unique question ID. |
| `selectedAnswer` | `NVARCHAR(255)` | Yes | - | Answer selected by student. |
| `isCorrect` | `BIT` | Yes | - | BIT value: 1 = true, 0 = false. |
| `marksAwarded` | `DECIMAL(6,2)` | Yes | - | Marks awarded for this answer. |

### Foreign Keys

- `resultId` references `QuizResult.resultId` (`FK_QuizAnswer_resultId_QuizResult`).
- `questionId` references `Question.questionId` (`FK_QuizAnswer_questionId_Question`).

## 24. `XPAction`

Seeded lookup table for XP action types and default XP values.

Seed/sample script currently inserts **9 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `xpActionId` | `NVARCHAR(10)` | No | PK | Unique XP action ID. |
| `actionNameEN` | `NVARCHAR(100)` | No | - | English XP action name. |
| `actionNameBM` | `NVARCHAR(100)` | Yes | - | Malay XP action name. |
| `xpValue` | `INT` | No | - | Default XP value. |

## 25. `XPTransaction`

Stores XP earned by students.

Seed/sample script currently inserts **19 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `xpTransactionId` | `NVARCHAR(10)` | No | PK | Unique XP transaction ID. |
| `studentId` | `NVARCHAR(10)` | Yes | FK -> `Student.studentId` | Unique student ID, e.g. S001. |
| `xpActionId` | `NVARCHAR(10)` | Yes | FK -> `XPAction.xpActionId` | Unique XP action ID. |
| `xpAmount` | `INT` | Yes | - | XP amount awarded. |
| `dateEarned` | `DATE` | Yes | - | Date XP was earned. |

### Foreign Keys

- `studentId` references `Student.studentId` (`FK_XPTransaction_studentId_Student`).
- `xpActionId` references `XPAction.xpActionId` (`FK_XPTransaction_xpActionId_XPAction`).

## 26. `LessonProgress`

Tracks lesson completion by student.

Seed/sample script currently inserts **26 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `progressId` | `NVARCHAR(10)` | No | PK | Unique lesson progress ID. |
| `studentId` | `NVARCHAR(10)` | Yes | FK -> `Student.studentId` | Unique student ID, e.g. S001. |
| `lessonId` | `NVARCHAR(10)` | Yes | FK -> `Lesson.lessonId` | Unique lesson ID. |
| `isCompleted` | `BIT` | Yes | - | BIT value: 1 = completed, 0 = not completed. |
| `completedDate` | `DATE` | Yes | - | Completion date. |

### Foreign Keys

- `studentId` references `Student.studentId` (`FK_LessonProgress_studentId_Student`).
- `lessonId` references `Lesson.lessonId` (`FK_LessonProgress_lessonId_Lesson`).

## 27. `Certificate`

Stores issued student certificates and certificate file paths.

Seed/sample script currently inserts **4 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `certificateId` | `NVARCHAR(10)` | No | PK | Unique certificate ID. |
| `studentId` | `NVARCHAR(10)` | Yes | FK -> `Student.studentId` | Unique student ID, e.g. S001. |
| `levelId` | `NVARCHAR(10)` | Yes | FK -> `Level.levelId` | Unique learning level ID. |
| `certificateTitleEN` | `NVARCHAR(150)` | Yes | - | English certificate title. |
| `certificateTitleBM` | `NVARCHAR(150)` | Yes | - | Malay certificate title. |
| `certificateDescriptionEN` | `NVARCHAR(MAX)` | Yes | - | English certificate description. |
| `certificateDescriptionBM` | `NVARCHAR(MAX)` | Yes | - | Malay certificate description. |
| `issuedDate` | `DATE` | Yes | - | Certificate issued date. |
| `certificateUrl` | `NVARCHAR(255)` | Yes | - | Certificate file path. |
| `certificateCode` | `NVARCHAR(50)` | Yes | UNIQUE | Unique certificate verification code. |
| `status` | `NVARCHAR(20)` | Yes | - | Account status: Active, Blocked, or Deleted. |

### Foreign Keys

- `studentId` references `Student.studentId` (`FK_Certificate_studentId_Student`).
- `levelId` references `Level.levelId` (`FK_Certificate_levelId_Level`).

### Important Notes

- `certificateUrl` must use the path prefix `Images/Certificate/`.

## 28. `Log`

Stores system/user activity logs.

Seed/sample script currently inserts **20 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `logId` | `NVARCHAR(10)` | No | PK | Unique log ID. |
| `userId` | `NVARCHAR(10)` | Yes | FK -> `User.userId` | Unique user account ID, e.g. U001. |
| `action` | `NVARCHAR(100)` | Yes | - | Action name. |
| `description` | `NVARCHAR(MAX)` | Yes | - |  |
| `logDateTime` | `DATETIME2(0)` | Yes | - | Action/log date and time. |
| `status` | `NVARCHAR(20)` | Yes | - | Account status: Active, Blocked, or Deleted. |

### Foreign Keys

- `userId` references `User.userId` (`FK_Log_userId_User`).

## 29. `Notification`

Stores bilingual notifications sent to users.

Seed/sample script currently inserts **15 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `notificationId` | `NVARCHAR(10)` | No | PK | Unique notification ID. |
| `toUserId` | `NVARCHAR(10)` | Yes | FK -> `User.userId` | Recipient user ID. |
| `titleEN` | `NVARCHAR(150)` | Yes | - | English title. |
| `titleBM` | `NVARCHAR(150)` | Yes | - | Malay title. |
| `messageEN` | `NVARCHAR(MAX)` | Yes | - | English message. |
| `messageBM` | `NVARCHAR(MAX)` | Yes | - | Malay message. |
| `isRead` | `BIT` | Yes | - | BIT value: 1 = read, 0 = unread. |
| `createdAt` | `DATETIME2(0)` | Yes | - | Creation date/time. |

### Foreign Keys

- `toUserId` references `User.userId` (`FK_Notification_toUserId_User`).

## 30. `VirtualLab`

Seeded interactive virtual lab activities.

Seed/sample script currently inserts **8 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `labId` | `NVARCHAR(10)` | No | PK | Unique virtual lab ID. |
| `unitId` | `NVARCHAR(10)` | Yes | FK -> `Unit.unitId` | Unique unit ID. |
| `labTitleEN` | `NVARCHAR(150)` | Yes | - | English lab title. |
| `labTitleBM` | `NVARCHAR(150)` | Yes | - | Malay lab title. |
| `labDescriptionEN` | `NVARCHAR(MAX)` | Yes | - | English lab description. |
| `labDescriptionBM` | `NVARCHAR(MAX)` | Yes | - | Malay lab description. |
| `instructionEN` | `NVARCHAR(MAX)` | Yes | - | English lab instructions. |
| `instructionBM` | `NVARCHAR(MAX)` | Yes | - | Malay lab instructions. |
| `labType` | `NVARCHAR(50)` | Yes | - | Lab interaction type. |
| `difficulty` | `NVARCHAR(20)` | Yes | - | Question difficulty: Easy, Medium, or Hard. |
| `createdAt` | `DATE` | Yes | - | Creation date/time. |

### Foreign Keys

- `unitId` references `Unit.unitId` (`FK_VirtualLab_unitId_Unit`).

## 31. `LabProgress`

Tracks virtual lab completion by student.

Seed/sample script currently inserts **12 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `labProgressId` | `NVARCHAR(10)` | No | PK | Unique lab progress ID. |
| `studentId` | `NVARCHAR(10)` | Yes | FK -> `Student.studentId` | Unique student ID, e.g. S001. |
| `labId` | `NVARCHAR(10)` | Yes | FK -> `VirtualLab.labId` | Unique virtual lab ID. |
| `isCompleted` | `BIT` | Yes | - | BIT value: 1 = completed, 0 = not completed. |
| `completedDate` | `DATE` | Yes | - | Completion date. |

### Foreign Keys

- `studentId` references `Student.studentId` (`FK_LabProgress_studentId_Student`).
- `labId` references `VirtualLab.labId` (`FK_LabProgress_labId_VirtualLab`).

## 32. `LiveConsultationSession`

Stores teacher-hosted live consultation sessions.

Seed/sample script currently inserts **6 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `sessionId` | `NVARCHAR(10)` | No | PK | Unique live session ID. |
| `teacherId` | `NVARCHAR(10)` | Yes | FK -> `Teacher.teacherId` | Unique teacher ID, e.g. T001. |
| `unitId` | `NVARCHAR(10)` | Yes | FK -> `Unit.unitId` | Unique unit ID. |
| `subtopicId` | `NVARCHAR(10)` | Yes | FK -> `Subtopic.subtopicId` | Unique subtopic ID. |
| `sessionTitle` | `NVARCHAR(200)` | Yes | - | Live session title. |
| `sessionDescription` | `NVARCHAR(MAX)` | Yes | - | Live session description. |
| `meetingLink` | `NVARCHAR(255)` | Yes | - | Online meeting link. |
| `startDateTime` | `DATETIME2(0)` | Yes | - | Session start date/time. |
| `endDateTime` | `DATETIME2(0)` | Yes | - | Session end date/time. |
| `status` | `NVARCHAR(30)` | Yes | - | Account status: Active, Blocked, or Deleted. |

### Foreign Keys

- `teacherId` references `Teacher.teacherId` (`FK_LiveConsultationSession_teacherId_Teacher`).
- `unitId` references `Unit.unitId` (`FK_LiveConsultationSession_unitId_Unit`).
- `subtopicId` references `Subtopic.subtopicId` (`FK_LiveConsultationSession_subtopicId_Subtopic`).

## 33. `LiveSessionParticipant`

Stores attendance/participation records for live sessions.

Seed/sample script currently inserts **12 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `participantId` | `NVARCHAR(10)` | No | PK | Unique live session participant ID. |
| `sessionId` | `NVARCHAR(10)` | Yes | FK -> `LiveConsultationSession.sessionId` | Unique live session ID. |
| `studentId` | `NVARCHAR(10)` | Yes | FK -> `Student.studentId` | Unique student ID, e.g. S001. |
| `joinedAt` | `DATETIME2(0)` | Yes | - | Date/time student joined session. |

### Foreign Keys

- `sessionId` references `LiveConsultationSession.sessionId` (`FK_LiveSessionParticipant_sessionId_LiveConsultationSession`).
- `studentId` references `Student.studentId` (`FK_LiveSessionParticipant_studentId_Student`).

### Important Notes

- The latest SQL table has no `attendanceStatus` column; do not reference it in website code unless the schema is officially changed.

## 34. `UserStatusAction`

Stores admin/status actions performed on user accounts.

Seed/sample script currently inserts **5 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `actionId` | `NVARCHAR(10)` | No | PK | Unique user status action ID. |
| `userId` | `NVARCHAR(10)` | Yes | FK -> `User.userId` | Unique user account ID, e.g. U001. |
| `actionType` | `NVARCHAR(30)` | Yes | - | Status action type, e.g. Blocked, Unblocked, Deleted. |
| `reason` | `NVARCHAR(MAX)` | Yes | - | Reason for action. |
| `actionDate` | `DATE` | Yes | - | Date action was performed. |
| `performedBy` | `NVARCHAR(10)` | Yes | FK -> `User.userId` | User/admin who performed the action. |

### Foreign Keys

- `userId` references `User.userId` (`FK_UserStatusAction_userId_User`).
- `performedBy` references `User.userId` (`FK_UserStatusAction_performedBy_User`).

## 35. `ConfigurationSetting`

Stores configurable application settings.

Seed/sample script currently inserts **14 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `configId` | `NVARCHAR(10)` | No | PK | Unique configuration ID. |
| `configKey` | `NVARCHAR(100)` | Yes | UNIQUE | Configuration setting name/key. |
| `configValue` | `NVARCHAR(100)` | Yes | - | Configuration value stored as text. |
| `lastUpdated` | `DATETIME2(0)` | Yes | - | Date/time setting was last updated. |

## 36. `AILearningAnalysis`

Stores AI-generated learning analysis summaries for students.

Seed/sample script currently inserts **8 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `analysisId` | `NVARCHAR(10)` | No | PK | Unique AI analysis ID. |
| `studentId` | `NVARCHAR(10)` | Yes | FK -> `Student.studentId` | Unique student ID, e.g. S001. |
| `analysisJson` | `NVARCHAR(MAX)` | Yes | - | Raw AI response or JSON payload. |
| `overallSummary` | `NVARCHAR(MAX)` | Yes | - | Human-readable learning summary. |
| `strongTopics` | `NVARCHAR(MAX)` | Yes | - | Topics where the student is strong. |
| `weakTopics` | `NVARCHAR(MAX)` | Yes | - | Topics needing improvement. |
| `avgQuizScore` | `DECIMAL(5,2)` | Yes | - | Average quiz score. |
| `totalQuizAttempts` | `INT` | Yes | - | Total quiz attempts considered. |
| `isLatest` | `BIT` | Yes | - | BIT value: 1 = latest analysis for student. |

### Foreign Keys

- `studentId` references `Student.studentId` (`FK_AILearningAnalysis_studentId_Student`).

### Important Notes

- When inserting a new latest analysis for a student, application logic should set previous analyses for that student to `isLatest = 0` and the new row to `isLatest = 1`.

## 37. `StudyPlan`

Stores study plans created by parents/students/users.

Seed/sample script currently inserts **7 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `studyPlanId` | `NVARCHAR(10)` | No | PK | Unique study plan ID. |
| `studentParentId` | `NVARCHAR(10)` | Yes | FK -> `StudentParent.studentParentId` | Unique student-parent relationship ID. |
| `createdByUserId` | `NVARCHAR(10)` | Yes | FK -> `User.userId` | User who created the record. |
| `planTitle` | `NVARCHAR(200)` | Yes | - | Study plan title. |
| `startDate` | `DATE` | Yes | - | Study plan start date. |
| `endDate` | `DATE` | Yes | - | Study plan end date. |
| `status` | `NVARCHAR(30)` | Yes | - | Account status: Active, Blocked, or Deleted. |
| `createdAt` | `DATETIME2(0)` | Yes | - | Creation date/time. |

### Foreign Keys

- `studentParentId` references `StudentParent.studentParentId` (`FK_StudyPlan_studentParentId_StudentParent`).
- `createdByUserId` references `User.userId` (`FK_StudyPlan_createdByUserId_User`).

### Important Notes

- `studentParentId` is nullable so a study plan can exist for a student without a linked parent relationship.

## 38. `SPTask`

Stores tasks inside study plans.

Seed/sample script currently inserts **19 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `spTaskId` | `NVARCHAR(10)` | No | PK | Unique study plan task ID. |
| `studyPlanId` | `NVARCHAR(10)` | Yes | FK -> `StudyPlan.studyPlanId` | Unique study plan ID. |
| `taskTitle` | `NVARCHAR(200)` | Yes | - | Task title. |
| `suggestedAction` | `NVARCHAR(MAX)` | Yes | - | Suggested action/instruction for task. |
| `orderNo` | `INT` | Yes | - | Display/order number. |
| `isCompleted` | `BIT` | Yes | - | BIT value: 1 = completed, 0 = not completed. |
| `completedAt` | `DATETIME2(0)` | Yes | - | Task completion date/time. |

### Foreign Keys

- `studyPlanId` references `StudyPlan.studyPlanId` (`FK_SPTask_studyPlanId_StudyPlan`).

## 39. `SPReward`

Stores rewards linked to study plans.

Seed/sample script currently inserts **12 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `rewardId` | `NVARCHAR(10)` | No | PK | Unique study plan reward ID. |
| `studyPlanId` | `NVARCHAR(10)` | Yes | FK -> `StudyPlan.studyPlanId` | Unique study plan ID. |
| `rewardName` | `NVARCHAR(200)` | Yes | - | Reward name. |
| `requiredProgress` | `INT` | Yes | - | Required progress percentage/value to unlock. |
| `isUnlocked` | `BIT` | Yes | - | BIT value: 1 = unlocked, 0 = locked. |
| `unlockedAt` | `DATETIME2(0)` | Yes | - | Reward unlock date/time. |

### Foreign Keys

- `studyPlanId` references `StudyPlan.studyPlanId` (`FK_SPReward_studyPlanId_StudyPlan`).

## 40. `userChat`

Stores private one-to-one chat rooms between two users.

Seed/sample script currently inserts **11 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `chatId` | `NVARCHAR(10)` | No | PK | Unique chat room ID. |
| `userId` | `NVARCHAR(10)` | Yes | FK -> `User.userId` | Unique user account ID, e.g. U001. |
| `user2Id` | `NVARCHAR(10)` | Yes | FK -> `User.userId` | Second chat user ID. |
| `createdAt` | `DATETIME2(0)` | Yes | - | Creation date/time. |

### Foreign Keys

- `userId` references `User.userId` (`FK_userChat_userId_User`).
- `user2Id` references `User.userId` (`FK_userChat_user2Id_User`).

### Important Notes

- The current column names are `userId` and `user2Id`, not `user1Id` and `user2Id`.

## 41. `privateMessage`

Stores private messages inside user chats, including optional attachment file path.

Seed/sample script currently inserts **16 row(s)** for this table.

### Columns

| Column | Data Type | Null? | Key / Constraint | Description |
|---|---|---|---|---|
| `privateMsgId` | `NVARCHAR(10)` | No | PK | Unique private message ID. |
| `chatId` | `NVARCHAR(10)` | Yes | FK -> `userChat.chatId` | Unique chat room ID. |
| `senderUserId` | `NVARCHAR(10)` | Yes | FK -> `User.userId` | User who sent message/like/answer. |
| `msgText` | `NVARCHAR(MAX)` | Yes | - | Private message text. |
| `attachmentFile` | `NVARCHAR(255)` | Yes | - | Optional private message attachment file path. |
| `sentAt` | `DATETIME2(0)` | Yes | - | Message sent date/time. |
| `isRead` | `BIT` | Yes | - | BIT value: 1 = read, 0 = unread. |
| `readAt` | `DATETIME2(0)` | Yes | - | Message read date/time. |

### Foreign Keys

- `chatId` references `userChat.chatId` (`FK_privateMessage_chatId_userChat`).
- `senderUserId` references `User.userId` (`FK_privateMessage_senderUserId_User`).

### Important Notes

- `attachmentFile` must use the path prefix `Images/privateMessage/` when an attachment exists.
- In application code, treat `NULL` as no attachment.


---

# Website Development Guide for Kiro / Groupmates

Use these rules when generating ASP.NET Web Forms pages, C# code-behind, SQL queries, or UI modules.

## A. Do Not Rename Database Fields

Use the exact latest names:

- `Student.currentLevelId`, not `currentlevelId`
- `StudentBadge.earnedAt`, not `dateTimeEarned`
- `StudyPlan.createdByUserId`, not `CreatedByUserId`
- `SPTask.spTaskId`, not `SPTaskId`
- `privateMessage.readAt`, not `ReadAt`
- `userChat.userId` and `userChat.user2Id`, not `user1Id`

## B. Use Parameterized Queries

Do not concatenate user input into SQL strings. Use parameters for login, search, insert, update, and delete operations.

Example pattern:

```csharp
SqlCommand cmd = new SqlCommand(
    "SELECT * FROM dbo.[User] WHERE username = @username AND password = @password AND status = 'Active'",
    conn
);
cmd.Parameters.AddWithValue("@username", username);
cmd.Parameters.AddWithValue("@password", password);
```

## C. Use Correct Boolean Handling

SQL Server `BIT` uses:

- `1` = true/completed/read/correct/latest/unlocked
- `0` = false/not completed/unread/incorrect/not latest/locked

Apply this to:

- `QuizAnswer.isCorrect`
- `LessonProgress.isCompleted`
- `Notification.isRead`
- `LabProgress.isCompleted`
- `AILearningAnalysis.isLatest`
- `SPTask.isCompleted`
- `SPReward.isUnlocked`
- `privateMessage.isRead`

## D. Use Correct File Path Handling

When uploading or displaying files, use the path prefixes from Section 4.

Example insert/update values:

```sql
Images/Teacher/cert_zara.pdf
Images/Personality/achiever.png
Images/Badge/first-step.png
Images/Lesson/humansense.png
Images/Material/humansense.pdf
Images/Question/human_senses.jpg
Images/Certificate/cert_s005_lv001.pdf
Images/privateMessage/answer.pdf
```

Do not store only `cert_zara.pdf` or `humansense.png` in these columns.

## E. Recommended Module-to-Table Mapping

| Website Module | Main Tables |
|---|---|
| Login / Authentication | `User`, `Log`, `UserStatusAction` |
| Student Dashboard | `Student`, `Level`, `Personality`, `Badge`, `StudentBadge`, `XPTransaction`, `Notification`, `AILearningAnalysis` |
| My Learning | `Level`, `Unit`, `Subtopic`, `Lesson`, `LessonProgress`, `Quiz`, `Question`, `QuizResult`, `QuizAnswer` |
| Virtual Labs | `VirtualLab`, `LabProgress`, `Unit` |
| Practice Library | `Quiz`, `Question`, `QuizResult`, `QuizAnswer` |
| Teacher Material Upload | `Teacher`, `Material`, `Subtopic`, `User` |
| Teacher Quiz/Question Review | `Quiz`, `Question`, `User` |
| Forum | `Forum`, `ForumChat`, `ForumTag`, `ForumLike`, `Tag`, `User` |
| Parent Dashboard | `Parent`, `StudentParent`, `Student`, `StudyPlan`, `SPTask`, `SPReward`, `AILearningAnalysis` |
| Live Sessions | `LiveConsultationSession`, `LiveSessionParticipant`, `Teacher`, `Student`, `Unit`, `Subtopic` |
| Private Messaging | `userChat`, `privateMessage`, `User` |
| Certificates | `Certificate`, `Student`, `Level` |
| Admin Settings | `ConfigurationSetting`, `Log`, `UserStatusAction` |

## F. Safe Filtering Rules

- Hide or block login for users with `User.status IN ('Blocked', 'Deleted')`.
- Teacher full features should be available only when `Teacher.status = 'Certified'`.
- Show only approved teacher-created learning material/questions to students unless the page is for teacher/admin review.
- Deleted sample records may remain in the database for history/testing; filter them out in normal UI views.

## G. Useful Verification Queries

Check all tables exist:

```sql
USE ScienceBuddy_DB;
GO

SELECT name
FROM sys.tables
ORDER BY name;
```

Check row counts quickly:

```sql
SELECT 'User' AS TableName, COUNT(*) AS TotalRows FROM dbo.[User]
UNION ALL SELECT 'Student', COUNT(*) FROM dbo.Student
UNION ALL SELECT 'Teacher', COUNT(*) FROM dbo.Teacher
UNION ALL SELECT 'Quiz', COUNT(*) FROM dbo.Quiz
UNION ALL SELECT 'Question', COUNT(*) FROM dbo.Question
UNION ALL SELECT 'Lesson', COUNT(*) FROM dbo.Lesson
UNION ALL SELECT 'Material', COUNT(*) FROM dbo.Material;
```

Check path columns:

```sql
SELECT teacherId, licenseCert FROM dbo.Teacher;
SELECT personalityId, avatar FROM dbo.Personality;
SELECT badgeId, badgeIcon FROM dbo.Badge;
SELECT lessonId, attachmentUrl FROM dbo.Lesson;
SELECT materialId, fileUrl FROM dbo.Material;
SELECT questionId, questionImageUrl FROM dbo.Question WHERE questionImageUrl IS NOT NULL;
SELECT certificateId, certificateUrl FROM dbo.Certificate;
SELECT privateMsgId, attachmentFile FROM dbo.privateMessage WHERE attachmentFile IS NOT NULL;
```

---

# Final Reminder

This guide describes the database structure, relationships, and development rules. It intentionally does **not** list every sample row. For exact seed/sample records, refer to:

- `InsertConstants_ImagesPath.sql`
- `InsertSampleData_ImagesPath.sql`
