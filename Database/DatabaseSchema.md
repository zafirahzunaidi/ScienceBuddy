# ScienceBuddy Database Schema

This document describes the full ScienceBuddy database schema, including all tables, columns, primary keys, foreign keys, constants, sample data rules, and important naming conventions.

> IMPORTANT: Use the exact database column and table names shown in this document. Do not rename columns unless the database schema is officially updated.

---

## Table Summary

| No. | Table Name | Purpose |
|---:|---|---|
| 1 | User | Stores login credentials, roles, language preference, and account status. |
| 2 | Student | Stores student profile information. |
| 3 | Parent | Stores parent profile information. |
| 4 | Teacher | Stores teacher profile and certification information. |
| 5 | StudentParent | Links students with parents. |
| 6 | Level | Static lookup table for learning levels. |
| 7 | Personality | Static lookup table for learner personalities. |
| 8 | Badge | Static lookup table for achievement badges. |
| 9 | StudentBadge | Stores badges earned by students. |
| 10 | Unit | Stores learning units under levels. |
| 11 | Subtopic | Stores subtopics under units. |
| 12 | Enrollment | Stores student enrollment by level. |
| 13 | Lesson | Stores core lesson content created by admin. |
| 14 | Quiz | Stores quiz information. |
| 15 | Material | Stores teacher-uploaded support materials. |
| 16 | Forum | Stores forum discussion posts. |
| 17 | ForumChat | Stores replies/messages inside forum discussions. |
| 18 | Tag | Stores forum tags. |
| 19 | ForumTag | Links forums with tags. |
| 20 | ForumLike | Stores forum likes. |
| 21 | Question | Stores quiz questions and answer options. |
| 22 | QuizResult | Stores quiz attempt results. |
| 23 | QuizAnswer | Stores selected answers for quiz attempts. |
| 24 | XPAction | Static lookup table for XP actions. |
| 25 | XPTransaction | Stores XP earned by students. |
| 26 | LessonProgress | Tracks student lesson completion. |
| 27 | Certificate | Stores student certificates. |
| 28 | Log | Stores system/user activity logs. |
| 29 | Notification | Stores user notifications. |
| 30 | VirtualLab | Static/constant interactive lab activities. |
| 31 | LabProgress | Tracks student virtual lab progress. |
| 32 | LiveConsultationSession | Stores live consultation sessions created by teachers. |
| 33 | LiveSessionParticipant | Stores live session attendance. |
| 34 | UserStatusAction | Stores actions taken on user account status. |
| 35 | ConfigurationSetting | Stores configurable system settings. |
| 36 | AILearningAnalysis | Stores AI-generated learning analysis for students. |
| 37 | StudyPlan | Stores study plans created for students. |
| 38 | SPTask | Stores tasks inside study plans. |
| 39 | SPReward | Stores rewards linked to study plans. |
| 40 | userChat | Stores private chat rooms between users. |
| 41 | privateMessage | Stores private messages inside user chats. |

---

# 1. User

Stores login credentials, system roles, language preference, and account status.

## Columns

| Column | Key | Description |
|---|---|---|
| userId | PK | Unique user ID. Example: U001. |
| username | Unique | Username used for login. |
| password |  | Password used for login. |
| email | Unique | User email address. |
| role |  | User role: Admin, Student, Parent, Teacher. |
| preferredLanguage |  | Preferred language: EN or BM. Every time user changes language, update database. |
| status |  | Account status: Active, Blocked, Deleted. |

## Status Rules

| Status | Meaning |
|---|---|
| Active | User can login. |
| Blocked | User cannot login because admin blocked the account. |
| Deleted | User cannot login because user deleted the account. |

## Sample Data

| userId | username | password | email | role | preferredLanguage | status |
|---|---|---|---|---|---|---|
| U001 | najihah01 | 12345 | admin@sciencebuddy.edu | Admin | EN | Active |
| U002 | ali | 12345 | ali@gmail.com | Student | BM | Active |
| U003 | siti | 12345 | siti@gmail.com | Student | EN | Active |
| U004 | abu | 12345 | abu@gmail.com | Student | BM | Deleted |
| U005 | aminah | aminah123 | aminah@gmail.com | Parent | EN | Active |
| U006 | hassan | hassan456 | hassan@gmail.com | Parent | BM | Active |
| U007 | laila | laila789 | laila@gmail.com | Parent | EN | Deleted |
| U008 | zara | 12345 | zara@gmail.com | Teacher | BM | Active |
| U009 | reza | 12345 | reza@gmail.com | Teacher | EN | Active |
| U010 | nurul | 12345 | nurul@gmail.com | Teacher | BM | Blocked |

---

# 2. Student

Stores student profile information.

## Columns

| Column | Key | Description |
|---|---|---|
| studentId | PK | Unique student ID. Example: S001. |
| userId | FK -> User.userId | Links student profile to login account. |
| name |  | Student full name. |
| phoneNumber |  | Student phone number. |
| nickname |  | Student nickname. |
| currentlevelId | FK -> Level.levelId | Current learning level. |
| XP |  | Student total XP. Default is 0. |
| personalityId | FK -> Personality.personalityId | Student learning personality. |
| parentCode |  | Random 6-character code used to link parent with student. |

## Notes

* One User can have one Student profile.
* parentCode is a random 6-character code.
* Deleted student account may still exist in Student table for historical/reference records.

## Sample Data

| studentId | userId | name | phoneNumber | nickname | currentlevelId | XP | personalityId | parentCode | Notes |
|---|---|---|---|---|---|---:|---|---|---|
| S001 | U002 | Ali Bin Abu | 0122068743 | Ali | LV001 | 0 | P001 | ABX123 |  |
| S002 | U003 | Siti Rahimah Binti Hassan | 0126559145 | Siti | LV002 | 0 | P004 | SRT456 |  |
| S003 | U004 | Zara Binti Zaidi | 0172008562 | Zara | LV003 | 0 | P006 | HZQ789 | deleted |

---

# 3. Parent

Stores parent profile information.

## Columns

| Column | Key | Description |
|---|---|---|
| parentId | PK | Unique parent ID. Example: P001. |
| userId | FK -> User.userId | Links parent profile to login account. |
| name |  | Parent full name. |
| phoneNumber |  | Parent phone number. |

## Sample Data

| parentId | userId | name | phoneNumber | Notes |
|---|---|---|---|---|
| P001 | U005 | Aminah Binti Yusof | 0134444676 |  |
| P002 | U006 | Hassan Bin Zainal | 0198888900 |  |
| P003 | U007 | Laila Binti Mahfuz | 0186455333 | deleted |

---

# 4. Teacher

Stores teacher profile information, certification document, and approval status.

## Columns

| Column | Key | Description |
|---|---|---|
| teacherId | PK | Unique teacher ID. Example: T001. |
| userId | FK -> User.userId | Links teacher profile to login account. |
| name |  | Teacher full name. |
| phoneNumber |  | Teacher phone number. |
| academicQualification |  | Teacher academic qualification. |
| bio |  | Teacher biography. |
| licenseCert |  | Uploaded certificate/license file. |
| status |  | Teacher certification status. |
| approvedDate |  | Date teacher status was approved/reviewed. |

## Teacher Status Rules

| Status | Meaning |
|---|---|
| Pending | Restricted access. Teacher is waiting for approval. |
| Certified | Teacher can access all teacher functions. |
| Not Certified | Teacher is blocked/restricted. May submit another document by email to admin. |

## Sample Data

| teacherId | userId | name | phoneNumber | academicQualification | bio | licenseCert | status | approvedDate | Notes |
|---|---|---|---|---|---|---|---|---|---|
| T001 | U008 | Zara Natasya Binti Karim | 0112222333 | B.Sc Biology (UTM) | Experienced scinece teacher with 10 years in secondary education. | cert_zara.pdf | Pending | 15-01-26 | restrict |
| T002 | U009 | Reza Hakim Bin Malik | 0145555666 | M.Ed Science Education (UM) | Passionate about inquiry-based learning and student engagement. | cert_reza.pdf | Certified | 18-03-26 |  |
| T003 | U010 | Nurl Izzah Binti Azmi | 0178888999 | B.Ed (Hons) Chemistry (UPM) | Focused on helping student grasp foundational concepts. | cert_izzah.pdf | Not Certified | 07-04-26 | blocked |

---

# 5. StudentParent

Links students with parents.

## Columns

| Column | Key | Description |
|---|---|---|
| studentParentId | PK | Unique student-parent relationship ID. Example: SP001. |
| studentId | FK -> Student.studentId | Linked student. |
| parentId | FK -> Parent.parentId | Linked parent. |
| relationship |  | Relationship between student and parent. Example: Mother, Father. |

## Notes

* If a student or parent is deleted, decide whether the StudentParent row should remain for historical records or be removed depending on project requirements.

## Sample Data

| studentParentId | studentId | parentId | relationship | Notes |
|---|---|---|---|---|
| SP001 | S001 | P001 | Mother |  |
| SP002 | S002 | P002 | Father |  |
| SP003 | S003 | P003 | Mother | Student/parent deleted case. Need decision whether this should remain. |

---

# 6. Level

Static lookup table for learning levels.

## Columns

| Column | Key | Description |
|---|---|---|
| levelId | PK | Unique level ID. |
| levelNameEN |  | English level name. |
| levelNameBM |  | Malay level name. |
| levelDescriptionEN |  | English level description. |
| levelDescriptionBM |  | Malay level description. |

## Constant Data

| levelId | levelNameEN | levelNameBM | levelDescriptionEN | levelDescriptionBM |
|---|---|---|---|---|
| LV001 | Beginner | Pemula | Suitable for students who are starting to learn basic Science concepts. | Sesuai untuk murid yang baru mula mempelajari konsep asas Sains. |
| LV002 | Intermediate | Pertengahan | Suitable for students who have basic Science understanding and are ready for more detailed topics. | Sesuai untuk murid yang mempunyai kefahaman asas Sains dan bersedia untuk topik yang lebih terperinci. |
| LV003 | Advanced | Lanjutan | Suitable for students who are ready to explore more challenging Science concepts and assessments. | Sesuai untuk murid yang bersedia meneroka konsep dan penilaian Sains yang lebih mencabar. |

---

# 7. Personality

Static lookup table for learner personalities.

## Columns

| Column | Key | Description |
|---|---|---|
| personalityId | PK | Unique personality ID. |
| personalityNameEN |  | English personality name. |
| personalityNameBM |  | Malay personality name. |
| descriptionENG |  | English description. |
| descriptionBM |  | Malay description. |
| avatar |  | Avatar image file. |
| colour |  | Personality display colour. |
| learningStyleEN |  | English learning style. |
| learningStyleBM |  | Malay learning style. |

## Constant Data

| personalityId | personalityNameEN | personalityNameBM | descriptionENG | descriptionBM | avatar | colour | learningStyleEN | learningStyleBM |
|---|---|---|---|---|---|---|---|---|
| P001 | Achiever | Pencapai | A goal-oriented learner who enjoys progress, rewards, badges, and completing learning targets. | Murid yang berorientasikan matlamat dan suka melihat kemajuan, ganjaran, lencana serta menyelesaikan sasaran pembelajaran. | achiever.png | #F5B041 | Goal-based learning | Pembelajaran berasaskan matlamat |
| P002 | Creative | Kreatif | A visual and imaginative learner who enjoys colourful notes, flashcards, videos, and virtual lab activities. | Murid yang visual dan imaginatif serta suka nota berwarna, kad imbas, video dan aktiviti makmal maya. | creative.png | #9B59B6 | Visual and interactive learning | Pembelajaran visual dan interaktif |
| P003 | Thinker | Pemikir | A curious learner who enjoys understanding reasons, reviewing explanations, and analysing weak topics. | Murid yang ingin tahu dan suka memahami sebab, menyemak penerangan serta menganalisis topik lemah. | thinker.png | #3498DB | Explanation-based learning | Pembelajaran berasaskan penerangan |
| P004 | Go-Getter | Bersemangat | An active learner who enjoys challenges, quizzes, leaderboard ranking, and fast progress. | Murid yang aktif dan suka cabaran, kuiz, kedudukan papan markah serta kemajuan yang cepat. | gogetter.png | #E74C3C | Challenge-based learning | Pembelajaran berasaskan cabaran |
| P005 | Chill Learner | Santai | A calm learner who prefers step-by-step learning, gentle reminders, and stress-free activities. | Murid yang tenang dan lebih suka pembelajaran langkah demi langkah, peringatan lembut dan aktiviti tanpa tekanan. | chill-learner.png | #58D68D | Step-by-step learning | Pembelajaran langkah demi langkah |
| P006 | Socializer | Sosial | A collaborative learner who enjoys discussions, teacher guidance, live sessions, and learning with others. | Murid yang suka bekerjasama melalui perbincangan, bimbingan guru, sesi langsung dan pembelajaran bersama orang lain. | socializer.png | #F39C12 | Collaborative learning | Pembelajaran kolaboratif |

---

# 8. Badge

Static lookup table for achievement badges.

## Columns

| Column | Key | Description |
|---|---|---|
| badgeId | PK | Unique badge ID. |
| badgeNameEN |  | English badge name. |
| badgeNameBM |  | Malay badge name. |
| badgeType |  | Badge category/type. |
| xpReward |  | XP reward given for badge. |
| badgeIcon |  | Badge icon file. |
| requirementDescriptionEN |  | English requirement description. |
| requirementDescriptionBM |  | Malay requirement description. |
| badgeDescriptionEN |  | English badge description. |
| badgeDescriptionBM |  | Malay badge description. |

## Constant Data

| badgeId | badgeNameEN | badgeNameBM | badgeType | xpReward | badgeIcon | requirementDescriptionEN | requirementDescriptionBM | badgeDescriptionEN | badgeDescriptionBM |
|---|---|---|---|---:|---|---|---|---|---|
| B001 | First Step Learner | Pelajar Langkah Pertama | Lesson | 20 | first-step.png | Complete the first lesson. | Selesaikan pelajaran pertama. | Awarded to students who begin their learning journey by completing their first lesson. | Diberikan kepada murid yang memulakan perjalanan pembelajaran dengan menyelesaikan pelajaran pertama. |
| B002 | Lab Explorer | Penjelajah Makmal | Lab | 30 | lab-explorer.png | Complete the first virtual lab. | Selesaikan makmal maya pertama. | Awarded to students who complete their first interactive virtual lab activity. | Diberikan kepada murid yang menyelesaikan aktiviti makmal maya interaktif pertama. |
| B003 | Quiz Starter | Pemula Kuiz | Quiz | 20 | quiz-starter.png | Attempt the first quiz. | Jawab kuiz pertama. | Awarded to students who attempt their first quiz or self-assessment. | Diberikan kepada murid yang menjawab kuiz atau penilaian kendiri pertama. |
| B004 | High Scorer | Skor Cemerlang | Quiz | 40 | high-scorer.png | Score 80% or above in any quiz. | Mendapat markah 80% ke atas dalam mana-mana kuiz. | Awarded to students who achieve excellent quiz performance. | Diberikan kepada murid yang mencapai prestasi kuiz yang cemerlang. |
| B005 | Unit Master | Pakar Unit | Unit | 50 | unit-master.png | Complete all lessons, labs, and unit quiz in one unit. | Selesaikan semua pelajaran, makmal dan kuiz unit dalam satu unit. | Awarded to students who successfully complete all required activities in one unit. | Diberikan kepada murid yang berjaya menyelesaikan semua aktiviti wajib dalam satu unit. |
| B006 | Beginner Champion | Juara Pemula | Level | 100 | beginner-champion.png | Complete Beginner level requirements. | Selesaikan keperluan tahap Pemula. | Awarded to students who complete all required Beginner level learning activities. | Diberikan kepada murid yang menyelesaikan semua aktiviti pembelajaran wajib tahap Pemula. |
| B007 | Intermediate Champion | Juara Pertengahan | Level | 120 | intermediate-champion.png | Complete Intermediate level requirements. | Selesaikan keperluan tahap Pertengahan. | Awarded to students who complete all required Intermediate level learning activities. | Diberikan kepada murid yang menyelesaikan semua aktiviti pembelajaran wajib tahap Pertengahan. |
| B008 | Advanced Champion | Juara Lanjutan | Level | 150 | advanced-champion.png | Complete Advanced level requirements. | Selesaikan keperluan tahap Lanjutan. | Awarded to students who complete all required Advanced level learning activities. | Diberikan kepada murid yang menyelesaikan semua aktiviti pembelajaran wajib tahap Lanjutan. |
| B009 | Forum Helper | Pembantu Forum | Forum | 25 | forum-helper.png | Post or reply in the public forum. | Hantar hantaran atau balasan dalam forum awam. | Awarded to students who actively participate in public learning discussions. | Diberikan kepada murid yang aktif menyertai perbincangan pembelajaran awam. |
| B010 | Consistent Learner | Pelajar Konsisten | Progress | 50 | consistent-learner.png | Complete learning activities on multiple days. | Selesaikan aktiviti pembelajaran pada beberapa hari berbeza. | Awarded to students who show consistent learning effort over time. | Diberikan kepada murid yang menunjukkan usaha pembelajaran yang konsisten dari semasa ke semasa. |

---

# 9. StudentBadge

Stores badges earned by students.

## Columns

| Column | Key | Description |
|---|---|---|
| studentbadgeId | PK | Unique student badge ID. Example: SB001. |
| studentId | FK -> Student.studentId | Student who earned the badge. |
| badgeId | FK -> Badge.badgeId | Badge earned by student. |
| dateTimeEarned |  | Date and time the badge was earned. |

## Sample Data Placeholder

| studentbadgeId | studentId | badgeId | dateTimeEarned |
|---|---|---|---|
| SB001 |  |  |  |

---

# 10. Unit

Stores learning units under levels.

## Columns

| Column | Key | Description |
|---|---|---|
| unitId | PK | Unique unit ID. Format: U101 to U305. |
| levelId | FK -> Level.levelId | Level that the unit belongs to. |
| unitNameEN |  | English unit name. |
| unitNameBM |  | Malay unit name. |
| unitDescriptionEN |  | English unit description. |
| unitDescriptionBM |  | Malay unit description. |
| orderNo |  | Unit order number within the level. |

## ID Format Notes

* `U101` means Level 1, Unit 1.
* `U305` means Level 3, Unit 5.

---

# 11. Subtopic

Stores subtopics under units.

## Columns

| Column | Key | Description |
|---|---|---|
| subtopicId | PK | Unique subtopic ID. Format: S111 to S355. |
| unitId | FK -> Unit.unitId | Unit that the subtopic belongs to. |
| subtopicTitleEN |  | English subtopic title. |
| subtopicTitleBM |  | Malay subtopic title. |
| subtopicDescriptionEN |  | English subtopic description. |
| subtopicDescriptionBM |  | Malay subtopic description. |
| orderNo |  | Subtopic order number within the unit. |

## ID Format Notes

* `S111` means Level 1, Unit 1, Subtopic 1.
* `S355` means Level 3, Unit 5, Subtopic 5.

---

# 12. Enrollment

Stores student enrollment records by level.

## Columns

| Column | Key | Description |
|---|---|---|
| enrollmentId | PK | Unique enrollment ID. Example: EN001. |
| studentId | FK -> Student.studentId | Enrolled student. |
| levelId | FK -> Level.levelId | Enrolled level. |
| enrolledDate |  | Date the student enrolled. |
| status |  | Enrollment status. |

## Sample Data Placeholder

| enrollmentId | studentId | levelId | enrolledDate | status |
|---|---|---|---|---|
| EN001 | S001 |  |  |  |
| EN002 | S002 |  |  |  |
| EN003 | S003 |  |  |  |

---

# 13. Lesson

Stores core lesson content created by admin.

## Columns

| Column | Key | Description |
|---|---|---|
| lessonId | PK | Unique lesson ID. Example: LS001. |
| subtopicId | FK -> Subtopic.subtopicId | Subtopic that lesson belongs to. |
| lessonTitleEN |  | English lesson title. |
| lessonTitleBM |  | Malay lesson title. |
| lessonContentEN |  | English lesson content. |
| lessonContentBM |  | Malay lesson content. |
| attachmentUrl |  | Lesson attachment URL/file path. |
| orderNo |  | Lesson order number within the subtopic. |

## Sample Data Placeholder

| lessonId |
|---|
| LS001 |
| LS002 |
| LS003 |
| LS004 |
| LS005 |
| LS006 |
| LS007 |
| LS008 |

---

# 14. Quiz

Stores quiz information.

## Columns

| Column | Key | Description |
|---|---|---|
| quizId | PK | Unique quiz ID. Example: Q001. |
| levelId | FK -> Level.levelId | Level linked to quiz. Level and Unit are always both included. |
| unitId | FK -> Unit.unitId | Unit linked to quiz. Level and Unit are always both included. |
| subtopicId | FK -> Subtopic.subtopicId | Optional/selected subtopic for quiz. |
| quizTitleEN |  | English quiz title. |
| quizTitleBM |  | Malay quiz title. |
| quizType |  | Quiz type: Level, Unit, Practice. |
| status |  | Quiz status. |
| createdByUserId | FK -> User.userId | User who created the quiz. |
| createdAt |  | Quiz creation date/time. |
| language |  | Quiz language: BM, ENG, BOTH. |

## Notes

* Level and Unit should always be both assigned.
* For Practice quiz, teacher can choose either one depending on requirements.
* Language values: BM, ENG, BOTH.

## Sample Data Placeholder

| quizId | quizType | language |
|---|---|---|
| Q001 | Level/Unit/Practice | BM/ENG/BOTH |

---

# 15. Material

Stores teacher-uploaded extra support materials.

## Columns

| Column | Key | Description |
|---|---|---|
| materialId | PK | Unique material ID. Example: M001. |
| subtopicId | FK -> Subtopic.subtopicId | Subtopic linked to material. |
| createdByUserId | FK -> User.userId | Teacher/user who uploaded material. |
| materialTitle |  | Material title. |
| materialType |  | Type of material. |
| fileUrl |  | Uploaded file URL/path. |
| materialContent |  | Text content for the material. |
| createdDate |  | Date material was created/uploaded. |
| status |  | Material review/status. |
| reviewedDate |  | Date material was reviewed. |
| language |  | Material language: BM or ENG. |

## Notes

* Teacher can only upload one language at a time: BM or ENG.

## Sample Data Placeholder

| materialId | language |
|---|---|
| M001 | BM/ENG |

---

# 16. Forum

Stores forum discussion posts.

## Columns

| Column | Key | Description |
|---|---|---|
| forumId | PK | Unique forum post ID. |
| createdBy | FK -> User.userId | User who created the forum post. |
| title |  | Forum title. |
| message |  | Forum message/body. |
| discussionType |  | Public or Private. |
| createdAt |  | Forum creation date/time. |

## Sample Data

| forumId | createdBy | title | message | discussionType | createdAt |
|---|---|---|---|---|---|
| F001 | U002 | Can someone explain the scientific method steps? | I am trying to answer the second quiz in Unit 3 but would like to see some examples. | Public | 21-01-2026 17:45:37 |
| F002 | U003 | Is a virus a living thing? |  | Public | 29-01-2026 00:10:13 |
| F003 | U004 | Why does ice float on water? |  | Private | 11-02-2026 10:42:09 |
| F004 | U005 | How to edit time on study plan? |  | Public | 18-02-2026 08:22:00 |
| F005 | U006 | Is Unit 1 taught a lot in school? |  | Public | 05-03-2026 15:11:22 |
| F006 | U005 | New reward: One bag of candy for one quiz. |  | Private | 10-03-2026 19:12:12 |
| F007 | U004 | Can you message my teacher to recheck my answers? |  | Private | 01-04-2026 12:56:43 |
| F008 | U004 | Difference between series and parallel circuits. |  | Public | 19-05-2026 00:01:32 |
| F009 | U007 | New item in study plan added for next week. |  | Private | 20-05-2026 09:22:31 |
| F010 | U002 | How to unlock all badges? |  | Public | 02-06-2026 02:17:19 |

---

# 17. ForumChat

Stores messages/replies inside forum discussions.

## Columns

| Column | Key | Description |
|---|---|---|
| forumChatId | PK | Unique forum chat ID. Example: FC001. |
| forumId | FK -> Forum.forumId | Related forum post. |
| senderUserId | FK -> User.userId | User who sent the reply/message. |
| message |  | Reply/message content. |
| createdAt |  | Date/time message was created. |

## Sample Data Placeholder

| forumChatId | forumId | senderUserId | message | createdAt |
|---|---|---|---|---|
| FC001 |  |  |  | 06-01-2026 11:33:44 |
| FC002 |  |  |  |  |
| FC003 |  |  |  |  |
| FC004 |  |  |  |  |
| FC005 |  |  |  |  |
| FC006 |  |  |  |  |
| FC007 |  |  |  |  |
| FC008 |  |  |  |  |
| FC009 |  |  |  |  |
| FC010 |  |  |  |  |

---

# 18. Tag

Stores tags used for forum categorisation.

## Columns

| Column | Key | Description |
|---|---|---|
| tagId | PK | Unique tag ID. Example: TAG001. |
| tagName |  | Tag name. |
| createdAt |  | Date/time tag was created. |

## Sample Data Placeholder

| tagId | tagName | createdAt |
|---|---|---|
| TAG001 |  | 01-01-2026 14:39:00 |
| TAG002 |  | 01-01-2026 14:40:00 |
| TAG003 |  | 01-01-2026 14:42:00 |
| TAG004 |  | 01-01-2026 14:43:00 |
| TAG005 |  | 01-01-2026 14:43:00 |
| TAG006 |  | 01-01-2026 14:45:00 |
| TAG007 |  | 01-01-2026 14:46:00 |
| TAG008 |  | 01-01-2026 14:47:00 |
| TAG009 |  | 01-01-2026 14:48:00 |
| TAG010 |  | 01-01-2026 14:45:00 |

---

# 19. ForumTag

Links forums with tags.

## Columns

| Column | Key | Description |
|---|---|---|
| forumTagId | PK | Unique forum-tag ID. |
| forumId | FK -> Forum.forumId | Related forum. |
| tagId | FK -> Tag.tagId | Related tag. |

## Sample Data

> Note: The provided data uses `FC001`, `FC002`, etc. under `forumId`, but based on the table name and relationship, `forumId` should normally reference `Forum.forumId` such as `F001`, `F002`. Keep this as a schema review item.

| forumTagId | forumId | tagId |
|---|---|---|
| FTAG001 | FC001 | TAG001 |
| FTAG002 | FC002 | TAG002 |
| FTAG003 | FC003 | TAG003 |
| FTAG004 | FC003 | TAG004 |
| FTAG005 | FC003 | TAG009 |
| FTAG006 | FC010 | TAG006 |
| FTAG007 | FC007 | TAG007 |
| FTAG008 | FC004 | TAG001 |
| FTAG009 | FC009 | TAG009 |
| FTAG010 | FC010 | TAG010 |

---

# 20. ForumLike

Stores likes on forum posts.

## Columns

| Column | Key | Description |
|---|---|---|
| likeId | PK | Unique like ID. Example: LIKE001. |
| forumId | FK -> Forum.forumId | Forum post that was liked. |
| senderUserId | FK -> User.userId | User who liked the forum post. |
| createdAt |  | Date/time the like was created. |

## Sample Data Placeholder

| likeId | forumId | senderUserId | createdAt |
|---|---|---|---|
| LIKE001 |  |  | 15-06-2026 00:00:00 |
| LIKE002 |  |  |  |
| LIKE003 |  |  |  |
| LIKE004 |  |  |  |
| LIKE005 |  |  |  |
| LIKE006 |  |  |  |
| LIKE007 |  |  |  |
| LIKE008 |  |  |  |
| LIKE009 |  |  |  |
| LIKE010 |  |  |  |

---

# 21. Question

Stores quiz questions, options, answers, explanations, difficulty, and review status.

## Columns

| Column | Key | Description |
|---|---|---|
| questionId | PK | Unique question ID. Example: QST001. |
| quizId | FK -> Quiz.quizId | Quiz that the question belongs to. |
| subtopicId | FK -> Subtopic.subtopicId | Related subtopic. |
| createdByUserId | FK -> User.userId | User/admin/teacher who created the question. |
| questionTextEN |  | English question text. |
| questionTextBM |  | Malay question text. |
| questionType |  | MCQ, T/F, DragDrop, Multiselect. |
| questionImageUrl |  | Optional image URL/file path for question. |
| optionA_EN |  | Option A in English. |
| optionA_BM |  | Option A in Malay. |
| optionB_EN |  | Option B in English. |
| optionB_BM |  | Option B in Malay. |
| optionC_EN |  | Option C in English. |
| optionC_BM |  | Option C in Malay. |
| optionD_EN |  | Option D in English. |
| optionD_BM |  | Option D in Malay. |
| correctAnswer |  | Correct option: A, B, C, or D. |
| correctExplanationEN |  | English explanation for correct answer. |
| correctExplanationBM |  | Malay explanation for correct answer. |
| wrongExplanationEN |  | English explanation for wrong answer. |
| wrongExplanationBM |  | Malay explanation for wrong answer. |
| difficulty |  | Question difficulty. |
| status |  | Question review/status. |
| createdAt |  | Question creation date/time. |
| reviewedDate |  | Date question was reviewed. |

## Sample Data Placeholder

| questionId | questionType | correctAnswer |
|---|---|---|
| QST001 | MCQ, T/F, DragDrop, Multiselect | A/B/C/D |

---

# 22. QuizResult

Stores quiz attempt result summary.

## Columns

| Column | Key | Description |
|---|---|---|
| resultId | PK | Unique quiz result ID. Example: QR001. |
| studentId | FK -> Student.studentId | Student who attempted the quiz. |
| quizId | FK -> Quiz.quizId | Quiz attempted by student. |
| score |  | Student score. |
| totalMarks |  | Total possible marks. |
| percentage |  | Percentage score. |
| resultStatus |  | Result status. Example: Pass/Fail. |
| attemptNo |  | Attempt number. |
| attemptedDate |  | Date/time quiz was attempted. |

## Sample Data Placeholder

| resultId | studentId | quizId | score | totalMarks | percentage | resultStatus | attemptNo | attemptedDate |
|---|---|---|---|---|---|---|---|---|
| QR001 |  |  |  |  |  |  |  |  |

---

# 23. QuizAnswer

Stores selected answers for each quiz attempt.

## Columns

| Column | Key | Description |
|---|---|---|
| answerId | PK | Unique quiz answer ID. Example: QA001. |
| resultId | FK -> QuizResult.resultId | Quiz result attempt. |
| questionId | FK -> Question.questionId | Question answered. |
| selectedAnswer |  | Student selected answer. |
| isCorrect |  | TRUE/FALSE whether selected answer is correct. |
| marksAwarded |  | Marks awarded for the answer. |

## Sample Data Placeholder

| answerId | resultId | questionId | selectedAnswer | isCorrect | marksAwarded |
|---|---|---|---|---|---|
| QA001 |  |  |  |  |  |

---

# 24. XPAction

Static lookup table for XP actions.

## Columns

| Column | Key | Description |
|---|---|---|
| xpActionId | PK | Unique XP action ID. |
| actionNameEN |  | English action name. |
| actionNameBM |  | Malay action name. |
| xpValue |  | XP value for action. |

## Constant Data

| xpActionId | actionNameEN | actionNameBM | xpValue |
|---|---|---|---:|
| XP001 | Complete Lesson | Selesaikan Pelajaran | 10 |
| XP002 | Complete Virtual Lab | Selesaikan Makmal Maya | 15 |
| XP003 | Attempt Practice Quiz | Jawab Kuiz Latihan | 10 |
| XP004 | Pass Unit Quiz | Lulus Kuiz Unit | 25 |
| XP005 | Score 80% or Above | Skor 80% ke Atas | 20 |
| XP006 | Complete Level Assessment | Selesaikan Penilaian Tahap | 40 |
| XP007 | Join Forum Discussion | Sertai Perbincangan Forum | 5 |
| XP008 | Attend Live Session | Hadiri Sesi Langsung | 15 |
| XP009 | Complete Study Plan Task | Selesaikan Tugasan Pelan Belajar | 10 |

---

# 25. XPTransaction

Stores XP earned by students.

## Columns

| Column | Key | Description |
|---|---|---|
| xpTransactionId | PK | Unique XP transaction ID. Example: XPT001. |
| studentId | FK -> Student.studentId | Student who earned XP. |
| xpActionId | FK -> XPAction.xpActionId | XP action performed. |
| xpAmount |  | Amount of XP earned. |
| dateEarned |  | Date/time XP was earned. |

## Sample Data Placeholder

| xpTransactionId | studentId | xpActionId | xpAmount | dateEarned |
|---|---|---|---|---|
| XPT001 |  |  |  |  |

---

# 26. LessonProgress

Tracks student lesson completion.

## Columns

| Column | Key | Description |
|---|---|---|
| progressId | PK | Unique progress ID. Example: PR001. |
| studentId | FK -> Student.studentId | Student linked to progress. |
| lessonId | FK -> Lesson.lessonId | Lesson linked to progress. |
| isCompleted |  | TRUE/FALSE completion status. |
| completedDate |  | Date/time lesson was completed. |

## Sample Data Placeholder

| progressId | studentId | lessonId | isCompleted | completedDate |
|---|---|---|---|---|
| PR001 |  |  |  |  |

---

# 27. Certificate

Stores certificates issued to students.

## Columns

| Column | Key | Description |
|---|---|---|
| certificateId | PK | Unique certificate ID. Example: CERT001. |
| studentId | FK -> Student.studentId | Student receiving certificate. |
| levelId | FK -> Level.levelId | Level completed for certificate. |
| certificateTitleEN |  | English certificate title. |
| certificateTitleBM |  | Malay certificate title. |
| certificateDescriptionEN |  | English certificate description. |
| certificateDescriptionBM |  | Malay certificate description. |
| issuedDate |  | Date certificate was issued. |
| certificateUrl |  | Certificate file URL/path. |
| certificateCode |  | Unique certificate verification code. |
| status |  | Certificate status. |

## Sample Data Placeholder

| certificateId | studentId | levelId | certificateTitleEN | certificateTitleBM | certificateDescriptionEN | certificateDescriptionBM | issuedDate | certificateUrl | certificateCode | status |
|---|---|---|---|---|---|---|---|---|---|---|
| CERT001 |  |  |  |  |  |  |  |  |  |  |

---

# 28. Log

Stores system/user activity logs.

## Columns

| Column | Key | Description |
|---|---|---|
| logId | PK | Unique log ID. Example: LOG001. |
| userId | FK -> User.userId | User related to the action. |
| action |  | Action performed. |
| description |  | Detailed action description. |
| logDateTime |  | Date/time log was created. |
| status |  | Log/action status. |

## Sample Data Placeholder

| logId | userId | action | description | logDateTime | status |
|---|---|---|---|---|---|
| LOG001 |  |  |  |  |  |

---

# 29. Notification

Stores notifications sent to users.

## Columns

| Column | Key | Description |
|---|---|---|
| notificationId | PK | Unique notification ID. Example: N0001. |
| toUserId | FK -> User.userId | User receiving notification. |
| titleEN |  | English notification title. |
| titleBM |  | Malay notification title. |
| messageEN |  | English notification message. |
| messageBM |  | Malay notification message. |
| isRead |  | TRUE/FALSE read status. |
| createdAt |  | Date/time notification was created. |

## Sample Data Placeholder

| notificationId | toUserId | titleEN | titleBM | messageEN | messageBM | isRead | createdAt |
|---|---|---|---|---|---|---|---|
| N0001 |  |  |  |  |  |  |  |

---

# 30. VirtualLab

Stores interactive virtual lab activities.

## Columns

| Column | Key | Description |
|---|---|---|
| labId | PK | Unique lab ID. Example: LAB001. |
| unitId | FK -> Unit.unitId | Unit linked to lab. |
| labTitleEN |  | English lab title. |
| labTitleBM |  | Malay lab title. |
| labDescriptionEN |  | English lab description. |
| labDescriptionBM |  | Malay lab description. |
| instructionEN |  | English lab instructions. |
| instructionBM |  | Malay lab instructions. |
| labType |  | Type/category of virtual lab. |
| difficulty |  | Lab difficulty. |
| createdAt |  | Date/time lab was created. |

## Sample Data Placeholder

| labId | unitId | labTitleEN | labTitleBM | labDescriptionEN | labDescriptionBM | instructionEN | instructionBM | labType | difficulty | createdAt |
|---|---|---|---|---|---|---|---|---|---|---|
| LAB001 |  |  |  |  |  |  |  |  |  |  |

---

# 31. LabProgress

Tracks student virtual lab progress.

## Columns

| Column | Key | Description |
|---|---|---|
| labProgressId | PK | Unique lab progress ID. Example: LABP001. |
| studentId | FK -> Student.studentId | Student linked to lab progress. |
| labId | FK -> VirtualLab.labId | Virtual lab activity. |
| isCompleted |  | TRUE/FALSE completion status. |
| completedDate |  | Date/time lab was completed. |

## Sample Data Placeholder

| labProgressId | studentId | labId | isCompleted | completedDate |
|---|---|---|---|---|---|
| LABP001 |  |  |  |  |  |

---

# 32. LiveConsultationSession

Stores live consultation sessions created by teachers.

## Columns

| Column | Key | Description |
|---|---|---|
| sessionId | PK | Unique live session ID. Example: LIVE001. |
| teacherId | FK -> Teacher.teacherId | Teacher hosting the session. |
| unitId | FK -> Unit.unitId | Related unit. |
| subtopicId | FK -> Subtopic.subtopicId | Related subtopic. |
| sessionTitle |  | Live session title. |
| sessionDescription |  | Live session description. |
| meetingLink |  | Online meeting link. |
| startDateTime |  | Session start date/time. |
| endDateTime |  | Session end date/time. |
| status |  | Session status. |

## Sample Data Placeholder

| sessionId | teacherId | unitId | subtopicId | sessionTitle | sessionDescription | meetingLink | startDateTime | endDateTime | status |
|---|---|---|---|---|---|---|---|---|---|
| LIVE001 |  |  |  |  |  |  |  |  |  |

---

# 33. LiveSessionParticipant

Stores student attendance/participation in live sessions.

## Columns

| Column | Key | Description |
|---|---|---|
| participantId | PK | Unique participant ID. Example: LIVEP001. |
| sessionId | FK -> LiveConsultationSession.sessionId | Live session. |
| studentId | FK -> Student.studentId | Student participant. |
| joinedAt |  | Date/time student joined session. |
| attendanceStatus |  | Attendance status. |

## Sample Data Placeholder

| participantId | sessionId | studentId | joinedAt | attendanceStatus |
|---|---|---|---|---|
| LIVEP001 |  |  |  |  |

---

# 34. UserStatusAction

Stores status actions performed on user accounts.

## Columns

| Column | Key | Description |
|---|---|---|
| actionId | PK | Unique action ID. Example: US001. |
| userId | FK -> User.userId | User whose status was affected. |
| actionType |  | Type of action. Example: Block, Unblock, Delete. |
| reason |  | Reason for status action. |
| actionDate |  | Date/time action was performed. |
| performedBy | FK -> User.userId | Admin/user who performed the action. |

## Sample Data Placeholder

| actionId | userId | actionType | reason | actionDate | performedBy |
|---|---|---|---|---|---|
| US001 |  |  |  |  |  |

---

# 35. ConfigurationSetting

Stores configurable system settings.

## Columns

| Column | Key | Description |
|---|---|---|
| configId | PK | Unique configuration ID. |
| configKey |  | Configuration key/name. |
| configValue |  | Configuration value. |
| lastUpdated |  | Date/time configuration was last updated. |

## Sample Data

| configId | configKey | configValue | lastUpdated |
|---|---|---|---|
| CONFIG001 | Easy Question Timer (Seconds) | 10 | 15-02-2026 10:05:40 |
| CONFIG002 | Medium Question Timer (Seconds) | 20 | 15-02-2026 10:06:25 |
| CONFIG003 | Hard Question Timer (Seconds) | 30 | 15-02-2026 10:07:39 |
| CONFIG004 | Passing Mark Percentage for Unit | 50 | 15-02-2026 10:08:51 |
| CONFIG005 | Passing Mark for Level | 70 | 15-02-2026 10:09:48 |
| CONFIG006 | Leaderboard Top Count | 10 | 15-02-2026 10:10:40 |
| CONFIG007 | Easy Question Mark | 1 | 15-02-2026 10:11:23 |
| CONFIG008 | Medium Question Mark | 3 | 15-02-2026 10:12:20 |
| CONFIG009 | Hard Question Mark | 5 | 15-02-2026 10:13:10 |
| CONFIG010 | Suspicious Login Attempt | 3 | 15-02-2026 10:14:27 |
| CONFIG011 | Account Lock Duration (Minutes) | 30 | 15-02-2026 10:15:32 |
| CONFIG012 | Password Minimum Length | 8 | 15-02-2026 10:16:09 |
| CONFIG013 | XP Reward Per Lesson Completion |  | 15-02-2026 10:17:19 |
| CONFIG014 | XP Reward Per Quiz Completion |  | 15-02-2026 10:18:42 |
| CONFIG015 | XP Reward Per Virtual Lab Completion |  | 15-02-2026 10:19:45 |
| CONFIG016 | Maximum Students Per Session | 50 | 15-02-2026 10:20:54 |
| CONFIG017 | Consultation Session Duration (Minutes) | 60 | 15-02-2026 10:21:59 |

---

# 36. AILearningAnalysis

Stores AI-generated learning analysis for students.

## Columns

| Column | Key | Description |
|---|---|---|
| analysisId | PK | Unique AI analysis ID. Example: A001. |
| studentId | FK -> Student.studentId | Student linked to analysis. |
| analysisJson |  | Raw unprocessed AI response. |
| overallSummary |  | Human-readable summary. |
| strongTopics |  | Topics the student is strong in. |
| weakTopics |  | Topics the student is weak in. |
| avgQuizScore |  | Average quiz score. |
| totalQuizAttempts |  | Total quiz attempts. |
| isLatest |  | Most recent student analysis. Bit value: 1 or 0. |

## Notes

* Update every time student completes a quiz.
* `analysisJson` stores raw unprocessed AI response.
* `overallSummary` stores readable summary.
* `isLatest` marks most recent student analysis.

## Sample Data Placeholder

| analysisId | studentId | analysisJson | overallSummary | strongTopics | weakTopics | avgQuizScore | totalQuizAttempts | isLatest |
|---|---|---|---|---|---|---|---|---|
| A001 | S001 |  |  |  |  |  |  |  |
| A002 | S002 |  |  |  |  |  |  |  |
| A003 | S003 |  |  |  |  |  |  |  |
| A004 | S002 |  |  |  |  |  |  |  |
| A005 | S002 |  |  |  |  |  |  |  |
| A006 | S001 |  |  |  |  |  |  |  |
| A007 | S002 |  |  |  |  |  |  |  |
| A008 | S001 |  |  |  |  |  |  |  |
| A009 | S003 |  |  |  |  |  |  |  |
| A010 | S003 |  |  |  |  |  |  |  |

---

# 37. StudyPlan

Stores study plans created for students by parent/student/user.

## Columns

| Column | Key | Description |
|---|---|---|
| studyPlanId | PK | Unique study plan ID. Example: STP001. |
| studentParentId | FK -> StudentParent.studentParentId | Student-parent relationship linked to study plan. |
| CreatedByUserId | FK -> User.userId | User who created the study plan. |
| planTitle |  | Study plan title. |
| startDate |  | Study plan start date. |
| endDate |  | Study plan end date. |
| status |  | Study plan status. |
| createdAt |  | Date/time study plan was created. |

## Status Values

* active
* completed
* draft
* Ongoing
* Completed

## Sample Data

| studyPlanId | studentParentId | CreatedByUserId | planTitle | startDate | endDate | status | createdAt |
|---|---|---|---|---|---|---|---|
| STP001 | SP001 | U005 | Weekly Study Plam | 04-05-26 | 11-05-26 | Completed | 04-05-2026 10:15:32 |
| STP002 | SP002 | U006 | Revision Plan | 13-05-26 | 22-05-26 | Ongoing | 15-05-2026 14:41:41 |
| STP003 | SP003 | U002 | This Week | 01-06-26 | 08-06-26 | Ongoing | 01-06-2026 15:21:00 |

---

# 38. SPTask

Stores tasks inside study plans.

## Columns

| Column | Key | Description |
|---|---|---|
| SPTaskId | PK | Unique study plan task ID. Example: SPT001. |
| studyPlanId | FK -> StudyPlan.studyPlanId | Study plan linked to task. |
| taskTitle |  | Task title. |
| suggestedAction |  | Suggested action for the task. |
| orderNo |  | Task order number. |
| isCompleted |  | TRUE/FALSE task completion status. |
| completedAt |  | Date/time task was completed. |

## Sample Data

| SPTaskId | studyPlanId | taskTitle | suggestedAction | orderNo | isCompleted | completedAt |
|---|---|---|---|---:|---|---|
| SPT001 | SP001 | akan diisi lepas tahu unit |  | 1 | TRUE | 05-05-2026 08:22:13 |
| SPT002 | SP001 |  |  | 2 | TRUE | 05-05-2026 18:55:10 |
| SPT003 | SP001 |  |  | 3 | TRUE | 06-05-2026 23:43:10 |
| SPT004 | SP001 |  |  | 4 | TRUE | 08-05-2026 22:10:10 |
| SPT005 | SP002 |  |  | 1 | TRUE | 17-05-2026 16:10:10 |
| SPT006 | SP002 |  |  | 2 | FALSE |  |
| SPT007 | SP002 |  |  | 3 | FALSE |  |
| SPT008 | SP003 |  |  | 1 | FALSE |  |
| SPT009 | SP003 |  |  | 2 | FALSE |  |
| SPT010 | SP003 |  |  | 2 | FALSE |  |

---

# 39. SPReward

Stores rewards linked to study plans.

## Columns

| Column | Key | Description |
|---|---|---|
| rewardId | PK | Unique reward ID. Example: SPR001. |
| studyPlanId | FK -> StudyPlan.studyPlanId | Study plan linked to reward. |
| rewardName |  | Reward name. |
| requiredProgress |  | Required progress percentage/value to unlock reward. |
| isUnlocked |  | TRUE/FALSE reward unlock status. |
| unlockedAt |  | Date/time reward was unlocked. |

## Sample Data

> Note: `SPR006` uses `STP003` as `studyPlanId`, while other rewards use `SP001`/`SP002`. Based on StudyPlan sample IDs, `STP003` appears correct and `SP001`/`SP002` may need review.

| rewardId | studyPlanId | rewardName | requiredProgress | isUnlocked | unlockedAt |
|---|---|---|---:|---|---|
| SPR001 | SP001 | Extra Screentime (2 hours) | 25 | TRUE | 05-05-2026 18:22:13 |
| SPR002 | SP001 | Watch "Spiderman" at the movies | 50 | TRUE | 08-05-2026 22:10:10 |
| SPR003 | SP002 | McDonalds | 25 | TRUE | 17-05-2026 16:10:10 |
| SPR004 | SP002 | Trip to ToysRUs | 50 | FALSE |  |
| SPR005 | SP002 | Secret Recipe Cake | 100 | FALSE |  |
| SPR006 | STP003 | New toy | 50 | FALSE |  |

---

# 40. userChat

Stores private chat rooms between users.

## Columns

| Column | Key | Description |
|---|---|---|
| chatId | PK | Unique chat ID. Example: C001. |
| user1Id | FK -> User.userId | First chat user. |
| user2Id | FK -> User.userId | Second chat user. |
| createdAt |  | Date/time chat was created. |

## Notes

* Used for parent-teacher and student-teacher chats.
* The provided sample has duplicate `C004`, which should be reviewed if `chatId` is primary key.

## Sample Data

| chatId | user1Id | user2Id | createdAt | Notes |
|---|---|---|---|---|
| C001 | U002 | U008 | 06-05-2026 10:00:00 | student-teacher |
| C002 | U003 | U008 | 03-06-2026 14:00:00 |  |
| C003 | U003 | U009 | 15-06-2026 20:00:00 |  |
| C004 | U004 | U010 | 16-06-2026 08:00:00 |  |
| C004 | U005 | U008 | 17-06-2026 09:00:00 | duplicate chatId, review needed |
| C005 | U005 | U010 | 19-06-2026 08:00:00 |  |
| C006 | U006 | U009 | 21-06-2026 15:00:00 |  |
| C007 | U007 | U008 | 26-06-2026 16:00:00 |  |
| C008 | U007 | U009 | 02-07-2026 15:00:00 |  |

---

# 41. privateMessage

Stores private messages inside user chats.

## Columns

| Column | Key | Description |
|---|---|---|
| privateMsgId | PK | Unique private message ID. Example: PM001. |
| chatId | FK -> userChat.chatId | Chat room linked to the message. |
| senderUserId | FK -> User.userId | User who sent the message. |
| msgText |  | Message text. |
| attachmentFile |  | Optional attachment file. |
| sentAt |  | Date/time message was sent. |
| isRead |  | TRUE/FALSE read status. |
| ReadAt |  | Date/time message was read. |

## Sample Data

| privateMsgId | chatId | senderUserId | msgText | attachmentFile | sentAt | isRead | ReadAt |
|---|---|---|---|---|---|---|---|
| PM001 | C001 | U002 | Can you checkout my answers I wrote on paper? | answer.pdf | 22-06-2026 07:08:19 | TRUE | 21-06-2026 22:00:00 |
| PM002 | C001 | U008 | Sure! Question 2 and 3 is wrong. | optional | 28-06-2026 02:39:00 | FALSE | 13-08-2026 09:21:33 |
| PM003 | C002 | U003 | Miss, I think the answer for question 4 is wrong. | optional | 20-06-2026 20:35:38 | TRUE | 23-11-2026 16:49:01 |
| PM004 | C002 | U008 | OH, you're right! | optional | 29-06-2026 00:38:02 | TRUE | 04-09-2026 17:46:31 |
| PM005 | C002 | U003 | No problem miss. | optional | 22-06-2026 14:17:45 | FALSE | 17-10-2026 05:20:15 |
| PM006 | C003 | U003 | When is the next live session? | optional | 19-06-2026 18:50:31 | TRUE | 06-10-2026 06:03:33 |
| PM007 | C003 | U009 | We have not scheduled it yet, sorry but around this week. | optional | 30-06-2026 19:27:29 | TRUE | 14-10-2026 04:45:56 |
| PM008 | C003 | U003 | I understand. | optional | 29-06-2026 07:21:07 | FALSE | 02-09-2026 11:24:24 |
| PM009 | C004 | U004 | Teacher, I am struggling with the notes. | optional | 20-06-2026 20:35:09 | TRUE | 07-07-2026 18:08:31 |
| PM010 | C004 | U010 | No problem, I will any questions you have. | optional | 17-06-2026 20:58:33 | FALSE | 17-09-2026 11:27:24 |

---

# Login Rules

Authentication uses the `User` table.

## Columns Used

* username
* password
* status

## Requirements

* Username and password must match.
* User status must be `Active`.
* `Blocked` users cannot login.
* `Deleted` users cannot login.

---

# Language Rules

The system supports English and Bahasa Melayu.

## Language Columns

* `preferredLanguage` in `User`
* English/BM fields in content tables such as Level, Personality, Badge, Lesson, Question, Notification, and VirtualLab
* `language` field in Quiz and Material

## Values

* EN
* BM
* ENG
* BOTH

## Notes

* `preferredLanguage` stores the user's selected system language.
* Every time user changes language, update the database.
* Teacher-uploaded `Material` supports BM or ENG one at a time.
* Quiz language can be BM, ENG, or BOTH.

---

# Static / Constant Tables

The following tables contain fixed or mostly fixed data.

* Level
* Personality
* Badge
* XPAction
* VirtualLab

---

# Main Foreign Key Relationships

| Child Table | FK Column | Parent Table | Parent Column |
|---|---|---|---|
| Student | userId | User | userId |
| Student | currentlevelId | Level | levelId |
| Student | personalityId | Personality | personalityId |
| Parent | userId | User | userId |
| Teacher | userId | User | userId |
| StudentParent | studentId | Student | studentId |
| StudentParent | parentId | Parent | parentId |
| StudentBadge | studentId | Student | studentId |
| StudentBadge | badgeId | Badge | badgeId |
| Unit | levelId | Level | levelId |
| Subtopic | unitId | Unit | unitId |
| Enrollment | studentId | Student | studentId |
| Enrollment | levelId | Level | levelId |
| Lesson | subtopicId | Subtopic | subtopicId |
| Quiz | levelId | Level | levelId |
| Quiz | unitId | Unit | unitId |
| Quiz | subtopicId | Subtopic | subtopicId |
| Quiz | createdByUserId | User | userId |
| Material | subtopicId | Subtopic | subtopicId |
| Material | createdByUserId | User | userId |
| Forum | createdBy | User | userId |
| ForumChat | forumId | Forum | forumId |
| ForumChat | senderUserId | User | userId |
| ForumTag | forumId | Forum | forumId |
| ForumTag | tagId | Tag | tagId |
| ForumLike | forumId | Forum | forumId |
| ForumLike | senderUserId | User | userId |
| Question | quizId | Quiz | quizId |
| Question | subtopicId | Subtopic | subtopicId |
| Question | createdByUserId | User | userId |
| QuizResult | studentId | Student | studentId |
| QuizResult | quizId | Quiz | quizId |
| QuizAnswer | resultId | QuizResult | resultId |
| QuizAnswer | questionId | Question | questionId |
| XPTransaction | studentId | Student | studentId |
| XPTransaction | xpActionId | XPAction | xpActionId |
| LessonProgress | studentId | Student | studentId |
| LessonProgress | lessonId | Lesson | lessonId |
| Certificate | studentId | Student | studentId |
| Certificate | levelId | Level | levelId |
| Log | userId | User | userId |
| Notification | toUserId | User | userId |
| VirtualLab | unitId | Unit | unitId |
| LabProgress | studentId | Student | studentId |
| LabProgress | labId | VirtualLab | labId |
| LiveConsultationSession | teacherId | Teacher | teacherId |
| LiveConsultationSession | unitId | Unit | unitId |
| LiveConsultationSession | subtopicId | Subtopic | subtopicId |
| LiveSessionParticipant | sessionId | LiveConsultationSession | sessionId |
| LiveSessionParticipant | studentId | Student | studentId |
| UserStatusAction | userId | User | userId |
| UserStatusAction | performedBy | User | userId |
| AILearningAnalysis | studentId | Student | studentId |
| StudyPlan | studentParentId | StudentParent | studentParentId |
| StudyPlan | CreatedByUserId | User | userId |
| SPTask | studyPlanId | StudyPlan | studyPlanId |
| SPReward | studyPlanId | StudyPlan | studyPlanId |
| userChat | user1Id | User | userId |
| userChat | user2Id | User | userId |
| privateMessage | chatId | userChat | chatId |
| privateMessage | senderUserId | User | userId |

---

# Naming Convention

IMPORTANT: Use exact database names.

## Correct Names

* userId
* username
* password
* email
* role
* preferredLanguage
* status
* studentId
* currentlevelId
* personalityId
* parentCode
* teacherId
* approvedDate
* studentParentId
* levelId
* personalityNameEN
* descriptionENG
* badgeId
* xpReward
* studentbadgeId
* unitId
* subtopicId
* enrollmentId
* lessonId
* quizId
* materialId
* forumId
* forumChatId
* tagId
* forumTagId
* likeId
* questionId
* resultId
* answerId
* xpActionId
* xpTransactionId
* progressId
* certificateId
* logId
* notificationId
* labId
* labProgressId
* sessionId
* participantId
* actionId
* configId
* analysisId
* studyPlanId
* SPTaskId
* rewardId
* chatId
* privateMsgId

## Do NOT Generate These Names Unless Schema Is Changed

* UserID
* PasswordHash
* UserRole
* IsActive
* CreatedDate
* CreatedBy
* UpdatedAt
* DeletedAt
* LevelID
* StudentID
* TeacherID
* ParentID

---

# Data Review Notes

These are not missing data. They are notes from the provided database draft that should be reviewed before final SQL insertion.

1. `ForumTag.forumId` sample data uses `FC001`, `FC002`, etc., but should likely reference `Forum.forumId` values such as `F001`, `F002`.
2. `userChat` sample data has duplicate `chatId = C004`. If `chatId` is the primary key, one of them should be changed.
3. `SPReward.studyPlanId` sample data uses `SP001` and `SP002`, but StudyPlan IDs are `STP001`, `STP002`, `STP003`. This should be reviewed.
4. `StudyPlan` status values appear in different casing: `Completed`, `Ongoing`, and notes mention `active/completed/draft`. Standardise if needed.
5. Some placeholder tables have IDs only or blank columns. These are documented as placeholders.
6. Some date formats are mixed, for example `15-01-26` and `21-01-2026 17:45:37`. Standardise date format in SQL Server if needed.

---

# Recommended SQL Server Date Format

For SQL Server scripts, use a clear ISO-style date format where possible:

```sql
YYYY-MM-DD
YYYY-MM-DD HH:MM:SS
```

Example:

```sql
2026-01-21 17:45:37
```

This avoids confusion between day-month-year and month-day-year.

---

# End of Schema Document
