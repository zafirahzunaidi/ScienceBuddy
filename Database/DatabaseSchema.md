# ScienceBuddy Database Schema

1.0 Database Schema

1.1 Table List

| No. | Table Name | Purpose |
|---|---|---|
| 1 | User | Keeps login account data, role, language and status. |
| 2 | Level | Contains learning level records. |
| 3 | Personality | Contains student personality types. |
| 4 | Badge | Contains badge records for student achievements. |
| 5 | Unit | Keeps science units under each level. |
| 6 | Subtopic | Keeps subtopics under each unit. |
| 7 | Lesson | Keeps lesson titles, content and attachment path. |
| 8 | XPAction | Contains fixed XP action values. |
| 9 | ConfigurationSetting | Contains system configuration values. |
| 10 | VirtualLab | Keeps virtual lab activities. |
| 11 | Student | Keeps student profile details. |
| 12 | Parent | Keeps parent profile details. |
| 13 | Teacher | Keeps teacher profile and certificate details. |
| 14 | StudentParent | Links a student account with a parent account. |
| 15 | Enrollment | Keeps student level enrollment records. |
| 16 | StudentBadge | Keeps badges earned by students. |
| 17 | Quiz | Keeps quiz details. |
| 18 | Material | Keeps teacher material uploads. |
| 19 | Forum | Keeps forum discussion posts. |
| 20 | ForumChat | Keeps replies inside forum discussions. |
| 21 | Tag | Keeps forum tags. |
| 22 | ForumTag | Links forums with tags. |
| 23 | ForumLike | Keeps forum likes. |
| 24 | Question | Keeps quiz questions and answer options. |
| 25 | QuizResult | Keeps student quiz result records. |
| 26 | QuizAnswer | Keeps answers selected in quiz attempts. |
| 27 | XPTransaction | Keeps XP earned by students. |
| 28 | LessonProgress | Keeps student lesson completion records. |
| 29 | Certificate | Keeps student certificate records. |
| 30 | Log | Keeps system log records. |
| 31 | Notification | Keeps notification records for users. |
| 32 | LabProgress | Keeps student virtual lab progress. |
| 33 | LiveConsultationSession | Keeps teacher live session details. |
| 34 | LiveSessionParticipant | Keeps students who joined live sessions. |
| 35 | UserStatusAction | Keeps user status actions done by admin. |
| 36 | AILearningAnalysis | Keeps learning analysis for students. |
| 37 | StudyPlan | Keeps study plans for students. |
| 38 | SPTask | Keeps tasks inside study plans. |
| 39 | SPReward | Keeps rewards inside study plans. |
| 40 | userChat | Keeps private chat rooms between users. |
| 41 | privateMessage | Keeps private messages inside private chats. |

1.2 Table Details

1. User table

Description:
Keeps login account data, role, language and status.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| userId | nvarchar(10) | PK | Related user ID. |
| username | nvarchar(50) | Unique | Username for login. |
| password | nvarchar(50) | - | Password for login. |
| email | nvarchar(100) | Unique | Email address. |
| role | nvarchar(20) | - | User role. |
| preferredLanguage | nvarchar(10) | - | Selected language. |
| status | nvarchar(20) | - | Record status. |

Primary Key:
- userId

Foreign Key:
- None

Sample Data:
Only selected sample records are shown.

| userId | username | password | email | role | preferredLanguage | status |
|---|---|---|---|---|---|---|
| U001 | najihah01 | 12345 | admin@sciencebuddy.edu | Admin | EN | Active |
| U002 | Aiman | 12345 | aiman@gmail.com | Student | BM | Active |
| U003 | siti | 12345 | siti@gmail.com | Student | EN | Active |

2. Level table

Description:
Contains learning level records.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| levelId | nvarchar(10) | PK | Level ID. |
| levelNameEN | nvarchar(50) | - | English text. |
| levelNameBM | nvarchar(50) | - | Bahasa Melayu text. |
| levelDescriptionEN | nvarchar(500) | - | English text. |
| levelDescriptionBM | nvarchar(500) | - | Bahasa Melayu text. |

Primary Key:
- levelId

Foreign Key:
- None

Sample Data:
| levelId | levelNameEN | levelNameBM | levelDescriptionEN | levelDescriptionBM |
|---|---|---|---|---|
| LV001 | Beginner | Pemula | Suitable for students who are starting to learn basic Science concepts. | Sesuai untuk murid yang baru mula mempelajari konsep asas Sains. |
| LV002 | Intermediate | Pertengahan | Suitable for students who have basic Science understanding and are ready for more detailed topics. | Sesuai untuk murid yang mempunyai kefahaman asas Sains dan bersedia untuk topik yang lebih terperinci. |
| LV003 | Advanced | Lanjutan | Suitable for students who are ready to explore more challenging Science concepts and assessments. | Sesuai untuk murid yang bersedia meneroka konsep dan penilaian Sains yang lebih mencabar. |

3. Personality table

Description:
Contains student personality types.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| personalityId | nvarchar(10) | PK | Personality ID. |
| personalityNameEN | nvarchar(50) | - | English text. |
| personalityNameBM | nvarchar(50) | - | Bahasa Melayu text. |
| descriptionEN | nvarchar(500) | - | English text. |
| descriptionBM | nvarchar(500) | - | Bahasa Melayu text. |
| avatar | nvarchar(200) | - | Table field. |
| colour | nvarchar(20) | - | Table field. |
| learningStyleEN | nvarchar(100) | - | English text. |
| learningStyleBM | nvarchar(100) | - | Bahasa Melayu text. |

Primary Key:
- personalityId

Foreign Key:
- None

Sample Data:
Only selected sample records are shown.

| personalityId | personalityNameEN | personalityNameBM | descriptionEN | descriptionBM | avatar | colour | learningStyleEN | learningStyleBM |
|---|---|---|---|---|---|---|---|---|
| P001 | Achiever | Pencapai | A goal-oriented learner who enjoys progress, rewards, badges, and completing learning targets. | Murid yang berorientasikan matlamat dan suka melihat kemajuan, ganjaran, lencana serta menyelesaikan sasaran pembelajaran. | Images/Personality/achiever.png | #F5B041 | Goal-based learning | Pembelajaran berasaskan matlamat |
| P002 | Creative | Kreatif | A visual and imaginative learner who enjoys colourful notes, flashcards, videos, and virtual lab activities. | Murid yang visual dan imaginatif serta suka nota berwarna, kad imbas, video dan aktiviti makmal maya. | Images/Personality/creative.png | #9B59B6 | Visual and interactive learning | Pembelajaran visual dan interaktif |
| P003 | Thinker | Pemikir | A curious learner who enjoys understanding reasons, reviewing explanations, and analysing weak topics. | Murid yang ingin tahu dan suka memahami sebab, menyemak penerangan serta menganalisis topik lemah. | Images/Personality/thinker.png | #3498DB | Explanation-based learning | Pembelajaran berasaskan penerangan |

4. Badge table

Description:
Contains badge records for student achievements.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| badgeId | nvarchar(10) | PK | Table field. |
| badgeNameEN | nvarchar(100) | - | English text. |
| badgeNameBM | nvarchar(100) | - | Bahasa Melayu text. |
| badgeType | nvarchar(50) | - | Type. |
| xpReward | int | - | Table field. |
| badgeIcon | nvarchar(200) | - | Table field. |
| requirementDescriptionEN | nvarchar(500) | - | English text. |
| requirementDescriptionBM | nvarchar(500) | - | Bahasa Melayu text. |
| badgeDescriptionEN | nvarchar(500) | - | English text. |
| badgeDescriptionBM | nvarchar(500) | - | Bahasa Melayu text. |

Primary Key:
- badgeId

Foreign Key:
- None

Sample Data:
Only selected sample records are shown.

| badgeId | badgeNameEN | badgeNameBM | badgeType | xpReward | badgeIcon | requirementDescriptionEN | requirementDescriptionBM | badgeDescriptionEN | badgeDescriptionBM |
|---|---|---|---|---|---|---|---|---|---|
| B001 | First Step Learner | Pelajar Langkah Pertama | Lesson | 20 | Images/Badge/first-step.png | Complete the first lesson. | Selesaikan pelajaran pertama. | Awarded to students who begin their learning journey by completing their first lesson. | Diberikan kepada murid yang memulakan perjalanan pembelajaran dengan menyelesaikan pelajaran pertama. |
| B002 | Lab Explorer | Penjelajah Makmal | Lab | 30 | Images/Badge/lab-explorer.png | Complete the first virtual lab. | Selesaikan makmal maya pertama. | Awarded to students who complete their first interactive virtual lab activity. | Diberikan kepada murid yang menyelesaikan aktiviti makmal maya interaktif pertama. |
| B003 | Quiz Starter | Pemula Kuiz | Quiz | 20 | Images/Badge/quiz-starter.png | Attempt the first quiz. | Jawab kuiz pertama. | Awarded to students who attempt their first quiz or self-assessment. | Diberikan kepada murid yang menjawab kuiz atau penilaian kendiri pertama. |

5. Unit table

Description:
Keeps science units under each level.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| unitId | nvarchar(10) | PK | Unit ID. |
| levelId | nvarchar(10) | FK -> Level.levelId | Level ID. |
| unitNameEN | nvarchar(100) | - | English text. |
| unitNameBM | nvarchar(100) | - | Bahasa Melayu text. |
| unitDescriptionEN | nvarchar(500) | - | English text. |
| unitDescriptionBM | nvarchar(500) | - | Bahasa Melayu text. |
| orderNo | int | - | Order number. |

Primary Key:
- unitId

Foreign Key:
- levelId -> Level.levelId

Sample Data:
Only selected sample records are shown.

| unitId | levelId | unitNameEN | unitNameBM | unitDescriptionEN | unitDescriptionBM | orderNo |
|---|---|---|---|---|---|---|
| UN101 | LV001 | Humans | Manusia | Learn about human senses and how they help us understand the world. | Mempelajari deria manusia dan kegunaannya dalam kehidupan harian. | 1 |
| UN102 | LV001 | Magnets | Magnet | Learn the uses, shapes, attraction and repulsion of magnets. | Mempelajari kegunaan, bentuk, tarikan dan tolakan magnet. | 2 |
| UN103 | LV001 | Absorption | Penyerapan | Learn about water absorbent and non-water absorbent materials. | Mempelajari bahan yang menyerap dan tidak menyerap air. | 3 |

6. Subtopic table

Description:
Keeps subtopics under each unit.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| subtopicId | nvarchar(10) | PK | Subtopic ID. |
| unitId | nvarchar(10) | FK -> Unit.unitId | Unit ID. |
| subtopicTitleEN | nvarchar(100) | - | English text. |
| subtopicTitleBM | nvarchar(100) | - | Bahasa Melayu text. |
| subtopicDescriptionEN | nvarchar(500) | - | English text. |
| subtopicDescriptionBM | nvarchar(500) | - | Bahasa Melayu text. |
| orderNo | int | - | Order number. |

Primary Key:
- subtopicId

Foreign Key:
- unitId -> Unit.unitId

Sample Data:
Only selected sample records are shown.

| subtopicId | unitId | subtopicTitleEN | subtopicTitleBM | subtopicDescriptionEN | subtopicDescriptionBM | orderNo |
|---|---|---|---|---|---|---|
| ST111 | UN101 | Human Sense | Deria Manusia | Learn about the five human senses. | Mempelajari lima deria manusia. | 1 |
| ST112 | UN101 | Classify Taste | Mengelaskan Rasa | Learn to classify different tastes. | Mempelajari cara mengelaskan rasa. | 2 |
| ST113 | UN101 | The Use of Human Sense | Kegunaan Deria Manusia | Learn how senses help us in daily life. | Mempelajari kegunaan deria dalam kehidupan harian. | 3 |

7. Lesson table

Description:
Keeps lesson titles, content and attachment path.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| lessonId | nvarchar(10) | PK | Lesson ID. |
| subtopicId | nvarchar(10) | FK -> Subtopic.subtopicId | Subtopic ID. |
| lessonTitleEN | nvarchar(100) | - | English text. |
| lessonTitleBM | nvarchar(100) | - | Bahasa Melayu text. |
| lessonContentEN | NVARCHAR(MAX) | - | English text. |
| lessonContentBM | NVARCHAR(MAX) | - | Bahasa Melayu text. |
| attachmentUrl | nvarchar(200) | - | Attachment path. |
| orderNo | int | - | Order number. |

Primary Key:
- lessonId

Foreign Key:
- subtopicId -> Subtopic.subtopicId

Sample Data:
Only selected sample records are shown.

| lessonId | subtopicId | lessonTitleEN | lessonTitleBM | lessonContentEN | lessonContentBM | attachmentUrl | orderNo |
|---|---|---|---|---|---|---|---|
| LS001 | ST111 | Human Sense | Deria Manusia | <p>We explore the world using <strong>five amazing senses</strong>!</p><br><br><p>Each sense has a special body part that helps us understand what is around us:</p><br><br><ul><br>  <li><strong>Eyes</strong> help us see colours, sizes, and shapes.</li><br>  <li><strong>Ears</strong> help us hear sounds, such as loud music or soft whispers.</li><br>  <li><strong>Nose</strong> helps us smell things, such as fragrant flowers or stinky trash.</li><br>  <li><strong>Tongue</strong> helps us taste food and drinks.</li><br>  <li><strong>Skin</strong> helps us feel things that are rough, smooth, hard, or soft.</li><br></ul><br><br><div class="lesson-tip"><br>  Our five senses help us explore, learn, and stay aware of the world around us.<br></div> | <p>Kita meneroka dunia menggunakan <strong>lima deria yang hebat</strong>!</p><br><br><p>Setiap deria mempunyai bahagian tubuh yang khas untuk membantu kita memahami keadaan di sekeliling:</p><br><br><ul><br>  <li><strong>Mata</strong> membantu kita melihat warna, saiz, dan bentuk.</li><br>  <li><strong>Telinga</strong> membantu kita mendengar bunyi, seperti muzik kuat atau bisikan perlahan.</li><br>  <li><strong>Hidung</strong> membantu kita menghidu bau, seperti bunga wangi atau sampah busuk.</li><br>  <li><strong>Lidah</strong> membantu kita merasa makanan dan minuman.</li><br>  <li><strong>Kulit</strong> membantu kita merasa benda yang kasar, licin, keras, atau lembut.</li><br></ul><br><br><div class="lesson-tip"><br>  Lima deria membantu kita meneroka, belajar, dan peka terhadap dunia di sekeliling kita.<br></div> | Images/Lesson/humansense.png | 1 |
| LS002 | ST112 | Classify Taste | Mengelaskan Rasa | <p>Our tongue is like a <strong>taste detective</strong>!</p><br><br><p>We can identify and group foods by four main flavours:</p><br><br><ul><br>  <li><strong>Sweet</strong> — like a lollipop or honey.</li><br>  <li><strong>Sour</strong> — like a lemon or lime.</li><br>  <li><strong>Salty</strong> — like salt or salted fish.</li><br>  <li><strong>Bitter</strong> — like coffee or bitter gourd.</li><br></ul><br><br><p>Some things may also be <strong>tasteless</strong>, such as plain water.</p><br><br><div class="lesson-tip"><br>  Taste helps us describe and compare different types of food.<br></div> | <p>Lidah kita seperti <strong>detektif rasa</strong>!</p><br><br><p>Kita boleh mengenal pasti dan mengelaskan makanan mengikut empat rasa utama:</p><br><br><ul><br>  <li><strong>Manis</strong> — seperti lolipop atau madu.</li><br>  <li><strong>Masam</strong> — seperti lemon atau limau nipis.</li><br>  <li><strong>Masin</strong> — seperti garam atau ikan masin.</li><br>  <li><strong>Pahit</strong> — seperti kopi atau peria.</li><br></ul><br><br><p>Ada juga benda yang mungkin <strong>tawar</strong>, seperti air kosong.</p><br><br><div class="lesson-tip"><br>  Deria rasa membantu kita menerangkan dan membandingkan pelbagai jenis makanan.<br></div> | Images/Lesson/taste.mp4 | 1 |
| LS003 | ST113 | The Use of Human Sense | Kegunaan Deria Manusia | <p>Our senses help us <strong>stay safe</strong> and <strong>learn about our surroundings</strong>.</p><br><br><p>When one sense does not work well, we can use special aids to help us:</p><br><br><ul><br>  <li><strong>Glasses</strong> help people see more clearly.</li><br>  <li><strong>Hearing aids</strong> help people hear sounds better.</li><br></ul><br><br><p>Even when it is dark and we cannot see, we can still use our <strong>sense of touch</strong> to find our way or identify objects.</p><br><br><div class="lesson-tip"><br>  Each sense is important because it helps us understand and respond to the world around us.<br></div> | <p>Deria kita membantu kita <strong>menjaga keselamatan</strong> dan <strong>belajar tentang persekitaran</strong>.</p><br><br><p>Jika satu deria tidak berfungsi dengan baik, kita boleh menggunakan alat bantuan khas:</p><br><br><ul><br>  <li><strong>Cermin mata</strong> membantu seseorang melihat dengan lebih jelas.</li><br>  <li><strong>Alat bantu pendengaran</strong> membantu seseorang mendengar bunyi dengan lebih baik.</li><br></ul><br><br><p>Walaupun dalam keadaan gelap dan kita tidak dapat melihat, kita masih boleh menggunakan <strong>deria sentuhan</strong> untuk mencari jalan atau mengenal pasti objek.</p><br><br><div class="lesson-tip"><br>  Setiap deria penting kerana membantu kita memahami dan bertindak balas terhadap dunia di sekeliling kita.<br></div> | Images/Lesson/useofhumansense.mp4 | 1 |

Notes:
- lessonContentEN and lessonContentBM use NVARCHAR(MAX).
- attachmentUrl is NULL when the lesson has no file path.

8. XPAction table

Description:
Contains fixed XP action values.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| xpActionId | nvarchar(10) | PK | XP action ID. |
| actionNameEN | nvarchar(100) | - | English text. |
| actionNameBM | nvarchar(100) | - | Bahasa Melayu text. |
| xpValue | int | - | Table field. |

Primary Key:
- xpActionId

Foreign Key:
- None

Sample Data:
Only selected sample records are shown.

| xpActionId | actionNameEN | actionNameBM | xpValue |
|---|---|---|---|
| XP001 | Complete Lesson | Selesaikan Pelajaran | 10 |
| XP002 | Complete Virtual Lab | Selesaikan Makmal Maya | 15 |
| XP003 | Attempt Practice Quiz | Jawab Kuiz Latihan | 10 |

9. ConfigurationSetting table

Description:
Contains system configuration values.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| configId | nvarchar(20) | PK | Table field. |
| configKey | nvarchar(100) | - | Table field. |
| configValue | int | - | Table field. |
| lastUpdated | datetime | - | Last updated date and time. |

Primary Key:
- configId

Foreign Key:
- None

Sample Data:
Only selected sample records are shown.

| configId | configKey | configValue | lastUpdated |
|---|---|---|---|
| CONFIG001 | Easy Question Timer (Seconds) | 10 | 2026-02-15 10:05:40 |
| CONFIG002 | Medium Question Timer (Seconds) | 20 | 2026-02-15 10:06:25 |
| CONFIG003 | Hard Question Timer (Seconds) | 30 | 2026-02-15 10:07:39 |

10. VirtualLab table

Description:
Keeps virtual lab activities.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| labId | nvarchar(10) | PK | Virtual lab ID. |
| unitId | nvarchar(10) | FK -> Unit.unitId | Unit ID. |
| labTitleEN | nvarchar(100) | - | English text. |
| labTitleBM | nvarchar(100) | - | Bahasa Melayu text. |
| labDescriptionEN | nvarchar(500) | - | English text. |
| labDescriptionBM | nvarchar(500) | - | Bahasa Melayu text. |
| instructionEN | nvarchar(max) | - | English text. |
| instructionBM | nvarchar(max) | - | Bahasa Melayu text. |
| labType | nvarchar(50) | - | Type. |
| difficulty | nvarchar(20) | - | Table field. |
| createdAt | datetime | - | Created date and time. |

Primary Key:
- labId

Foreign Key:
- unitId -> Unit.unitId

Sample Data:
Only selected sample records are shown.

| labId | unitId | labTitleEN | labTitleBM | labDescriptionEN | labDescriptionBM | instructionEN | instructionBM | labType | difficulty | createdAt |
|---|---|---|---|---|---|---|---|---|---|---|
| LAB001 | UN102 | Magnetic Forces Explorer | Penjelajah Daya Magnet | Test different magnet poles and identify which objects are attracted to magnets. | Uji kutub magnet yang berbeza dan kenal pasti objek yang ditarik oleh magnet. | 1. Select two magnets and drag them together to test the same poles (N-N or S-S) and different poles (N-S)<br>2. Observe if the magnets push away (repel) or pull together (attract)<br>3. Drag a magnet toward objects like a nail, pencil, and paperclip<br>4. Sort the objects into "Magnetic" and "Non-magnetic" categories | 1. Pilih dua magnet dan seretnya bersama-sama untuk menguji kutub yang sama (U-U atau S-S) dan kutub yang berbeza (U-S)<br>2. Perhatikan jika magnet menolak atau menarik satu sama lain<br>3. Seret magnet ke arah objek seperti paku, pensel, dan klip kertas<br>4. Kelaskan objek ke dalam kategori "Bermagnet" dan "Tidak Bermagnet" | Drag-and-drop Simulation | Easy | 2026-01-01 00:00:00 |
| LAB002 | UN103 | The Great Soak Challenge | Cabaran Serapan Hebat | Test the water absorption capacity of different materials | Uji keupayaan penyerapan air bagi bahan yang berbeza | 1. Select a material such as a sponge, tissue paper, or a plastic coin<br>2. Use the virtual dropper to place three drops of colored water on the material<br>3. Observe if the water is absorbed or if it remains on the surface<br>4. Compare two absorbent materials to see which one soaks up more water | 1. Pilih bahan seperti span, kertas tisu, atau duit syiling plastik<br>2. Gunakan penitis maya untuk menitiskan tiga titik air berwarna pada bahan tersebut<br>3. Perhatikan sama ada air diserap atau kekal di atas permukaan<br>4. Bandingkan dua bahan yang menyerap air untuk melihat mana yang menyerap lebih banyak air | Observation Lab | Easy | 2026-01-01 00:00:00 |
| LAB003 | UN201 | Journey of a Sandwich | Perjalanan Sekeping Sandwic | Follow food as it is broken down and travels through the digestive system | Ikuti perjalanan makanan semasa ia dihancurkan dan melalui sistem pencernaan | 1. Click the sandwich to begin mechanical digestion in the mouth using teeth and saliva<br>2. Drag the food bolus down the esophagus into the stomach<br>3. Watch the food turn into a liquid state in the stomach and move to the intestines<br>4. Identify where nutrients are absorbed and follow the waste until it reaches the anus | 1. Klik pada sandwic untuk memulakan pencernaan mekanikal di dalam mulut menggunakan gigi dan air liur<br>2. Seret bolus makanan menuruni esofagus ke dalam perut<br>3. Perhatikan makanan berubah menjadi cecair di dalam perut dan bergerak ke usus<br>4. Kenal pasti di mana nutrien diserap dan ikuti sisa makanan sehingga sampai ke dubur | Process Animation | Medium | 2026-01-01 00:00:00 |

11. Student table

Description:
Keeps student profile details.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| studentId | nvarchar(10) | PK | Student ID. |
| userId | nvarchar(10) | FK -> User.userId | Related user ID. |
| name | nvarchar(100) | - | Full name. |
| phoneNumber | nvarchar(20) | - | Phone number. |
| nickname | nvarchar(50) | - | Table field. |
| currentLevelId | nvarchar(10) | FK -> Level.levelId | Current level ID. |
| XP | int | - | Total XP. |
| personalityId | nvarchar(10) | FK -> Personality.personalityId | Personality ID. |
| parentCode | nvarchar(20) | Unique | Code used for parent linking. |

Primary Key:
- studentId

Foreign Key:
- userId -> User.userId
- currentLevelId -> Level.levelId
- personalityId -> Personality.personalityId

Sample Data:
Only selected sample records are shown.

| studentId | userId | name | phoneNumber | nickname | currentLevelId | XP | personalityId | parentCode |
|---|---|---|---|---|---|---|---|---|
| S001 | U002 | Aiman Harris Bin Zulkarnain | 0122068743 | Aiman | LV001 | 0 | P001 | ABX123 |
| S002 | U003 | Siti Rahimah Binti Hassan | 0126559145 | Siti | LV001 | 120 | P004 | SRT456 |
| S003 | U004 | Zara Binti Zaidi | 0172008562 | Zara | LV003 | 0 | P006 | HZQ789 |

12. Parent table

Description:
Keeps parent profile details.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| parentId | nvarchar(10) | PK | Parent ID. |
| userId | nvarchar(10) | FK -> User.userId | Related user ID. |
| name | nvarchar(100) | - | Full name. |
| phoneNumber | nvarchar(20) | - | Phone number. |

Primary Key:
- parentId

Foreign Key:
- userId -> User.userId

Sample Data:
Only selected sample records are shown.

| parentId | userId | name | phoneNumber |
|---|---|---|---|
| P001 | U005 | Aminah Binti Yusof | 0134444676 |
| P002 | U006 | Hassan Bin Zainal | 0198888900 |
| P003 | U007 | Laila Binti Mahfuz | 0186455333 |

13. Teacher table

Description:
Keeps teacher profile and certificate details.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| teacherId | nvarchar(10) | PK | Teacher ID. |
| userId | nvarchar(10) | FK -> User.userId | Related user ID. |
| name | nvarchar(100) | - | Full name. |
| phoneNumber | nvarchar(20) | - | Phone number. |
| academicQualification | nvarchar(200) | - | Table field. |
| bio | nvarchar(500) | - | Table field. |
| licenseCert | nvarchar(200) | - | Teacher certificate file. |
| status | nvarchar(30) | - | Record status. |
| approvedDate | datetime | - | Teacher approved date. |

Primary Key:
- teacherId

Foreign Key:
- userId -> User.userId

Sample Data:
Only selected sample records are shown.

| teacherId | userId | name | phoneNumber | academicQualification | bio | licenseCert | status | approvedDate |
|---|---|---|---|---|---|---|---|---|
| T001 | U008 | Zara Natasya Binti Karim | 0112222333 | B.Sc Biology (UTM) | Experienced science teacher with 10 years in secondary education. | Images/Teacher/cert_zara.pdf | Pending | NULL |
| T002 | U009 | Reza Hakim Bin Malik | 0145555666 | M.Ed Science Education (UM) | Passionate about inquiry-based learning and student engagement. | Images/Teacher/cert_reza.pdf | Certified | 2026-01-01 00:00:00 |
| T003 | U010 | Nurl Izzah Binti Azmi | 0178888999 | B.Ed (Hons) Chemistry (UPM) | Focused on helping student grasp foundational concepts. | Images/Teacher/cert_izzah.pdf | Not Certified | 2026-01-02 00:00:00 |

14. StudentParent table

Description:
Links a student account with a parent account.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| studentParentId | nvarchar(10) | PK | Student-parent link ID. |
| studentId | nvarchar(10) | FK -> Student.studentId | Student ID. |
| parentId | nvarchar(10) | FK -> Parent.parentId | Parent ID. |
| relationship | nvarchar(50) | - | Relationship name. |

Primary Key:
- studentParentId

Foreign Key:
- studentId -> Student.studentId
- parentId -> Parent.parentId

Sample Data:
Only selected sample records are shown.

| studentParentId | studentId | parentId | relationship |
|---|---|---|---|
| SP001 | S001 | P001 | Mother |
| SP002 | S002 | P002 | Father |
| SP003 | S003 | P003 | Mother |

15. Enrollment table

Description:
Keeps student level enrollment records.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| enrollmentId | nvarchar(10) | PK | Table field. |
| studentId | nvarchar(10) | FK -> Student.studentId | Student ID. |
| levelId | nvarchar(10) | FK -> Level.levelId | Level ID. |
| enrolledDate | datetime | - | Enrollment date. |
| status | nvarchar(20) | - | Record status. |

Primary Key:
- enrollmentId

Foreign Key:
- studentId -> Student.studentId
- levelId -> Level.levelId

Sample Data:
Only selected sample records are shown.

| enrollmentId | studentId | levelId | enrolledDate | status |
|---|---|---|---|---|
| EN001 | S001 | LV001 | 2026-01-06 00:00:00 | Active |
| EN002 | S002 | LV001 | 2026-05-01 00:00:00 | Active |
| EN003 | S003 | LV003 | 2026-10-03 00:00:00 | Deleted |

16. StudentBadge table

Description:
Keeps badges earned by students.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| studentBadgeId | nvarchar(10) | PK | Table field. |
| studentId | nvarchar(10) | FK -> Student.studentId | Student ID. |
| badgeId | nvarchar(10) | FK -> Badge.badgeId | Table field. |
| earnedAt | datetime | - | Date and time earned. |

Primary Key:
- studentBadgeId

Foreign Key:
- studentId -> Student.studentId
- badgeId -> Badge.badgeId

Sample Data:
Only selected sample records are shown.

| studentBadgeId | studentId | badgeId | earnedAt |
|---|---|---|---|
| SB001 | S002 | B001 | 2026-05-16 10:00:00 |
| SB002 | S002 | B003 | 2026-05-17 11:30:00 |
| SB003 | S004 | B001 | 2026-02-04 09:20:00 |

17. Quiz table

Description:
Keeps quiz details.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| quizId | nvarchar(10) | PK | Quiz ID. |
| levelId | nvarchar(10) | FK -> Level.levelId | Level ID. |
| unitId | nvarchar(10) | FK -> Unit.unitId | Unit ID. |
| quizTitleEN | nvarchar(100) | - | English text. |
| quizTitleBM | nvarchar(100) | - | Bahasa Melayu text. |
| quizType | nvarchar(20) | - | Type. |
| status | nvarchar(20) | - | Record status. |
| createdByUserId | nvarchar(10) | FK -> User.userId | User who created the record. |
| createdAt | datetime | - | Created date and time. |
| language | nvarchar(10) | - | Table field. |

Primary Key:
- quizId

Foreign Key:
- levelId -> Level.levelId
- unitId -> Unit.unitId
- createdByUserId -> User.userId

Sample Data:
Only selected sample records are shown.

| quizId | levelId | unitId | quizTitleEN | quizTitleBM | quizType | status | createdByUserId | createdAt | language |
|---|---|---|---|---|---|---|---|---|---|
| Q001 | NULL | UN101 | My Super Senses Challenge | Cabaran Deria Hebat Saya | Unit | NULL | U001 | 2026-01-01 10:00:00 | BOTH |
| Q002 | NULL | UN102 | Magnet Magic Adventure | Kembara Magnet Ajaib | Unit | NULL | U001 | 2026-01-02 12:59:21 | BOTH |
| Q003 | NULL | UN103 | The Great Soak-Off | Hero Penyerapan Hebat | Unit | NULL | U001 | 2026-01-02 17:34:22 | BOTH |

Notes:
- levelId and unitId allow NULL in SQL, but sample quiz rows use Level and Unit values.
- Quiz table does not have subtopicId in the real SQL.

18. Material table

Description:
Keeps teacher material uploads.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| materialId | nvarchar(10) | PK | Table field. |
| subtopicId | nvarchar(10) | FK -> Subtopic.subtopicId | Subtopic ID. |
| createdByUserId | nvarchar(10) | FK -> User.userId | User who created the record. |
| materialTitle | nvarchar(100) | - | Title. |
| materialType | nvarchar(30) | - | Type. |
| fileUrl | nvarchar(200) | - | File path. |
| materialContent | nvarchar(max) | - | Content. |
| createdDate | datetime | - | Created date and time. |
| status | nvarchar(20) | - | Record status. |
| reviewedDate | datetime | - | Reviewed date. |
| language | nvarchar(10) | - | Table field. |

Primary Key:
- materialId

Foreign Key:
- subtopicId -> Subtopic.subtopicId
- createdByUserId -> User.userId

Sample Data:
Only selected sample records are shown.

| materialId | subtopicId | createdByUserId | materialTitle | materialType | fileUrl | materialContent | createdDate | status | reviewedDate | language |
|---|---|---|---|---|---|---|---|---|---|---|
| M001 | ST111 | U022 | Human Sense Notes | PDF | Images/Material/humansense.pdf | This material introduces the five human senses and their functions. Students will learn how sight, hearing, smell, taste and touch help humans understand their surroundings. | 2026-01-28 00:00:00 | Pending | NULL | EN |
| M002 | ST122 | U023 | Bentuk-Bentuk Magnet | Image | magnetbentuk.png | Bahan pembelajaran ini memperkenalkan pelbagai bentuk magnet seperti magnet ladam, magnet bar dan magnet silinder serta kegunaannya dalam kehidupan harian. | 2025-01-04 00:00:00 | Approved | 2025-03-04 00:00:00 | BM |
| M003 | ST313 | U022 | Blood Circulatory System Video Lesson | Video | circulatory_system.mp4 | This video explains the functions of the heart, blood vessels and blood circulation throughout the human body using simple animations and examples. | 2025-09-18 00:00:00 | Pending | NULL | EN |

Notes:
- fileUrl is NULL when no material file is provided.

19. Forum table

Description:
Keeps forum discussion posts.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| forumId | nvarchar(10) | PK | Table field. |
| createdBy | nvarchar(10) | FK -> User.userId | User who created the forum. |
| title | nvarchar(200) | - | Title. |
| message | nvarchar(max) | - | Table field. |
| discussionType | nvarchar(20) | - | Type. |
| createdAt | datetime | - | Created date and time. |

Primary Key:
- forumId

Foreign Key:
- createdBy -> User.userId

Sample Data:
Only selected sample records are shown.

| forumId | createdBy | title | message | discussionType | createdAt |
|---|---|---|---|---|---|
| F001 | U002 | Can someone explain how gears work in a super simple way? | I am trying to answer the second quiz in Unit 3 but would like to see some examples. | Public | 2026-01-21 16:45:00 |
| F002 | U003 | Litmus paper not working | I tried testing acidity using litmus paper, but it does not change colour. Why? | Public | 2026-01-28 14:20:00 |
| F003 | U004 | Why does ice float on water? | NULL | Private | 2026-02-03 19:00:00 |

20. ForumChat table

Description:
Keeps replies inside forum discussions.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| forumChatId | nvarchar(10) | PK | Table field. |
| forumId | nvarchar(10) | FK -> Forum.forumId | Table field. |
| senderUserId | nvarchar(10) | FK -> User.userId | User who sent the record. |
| message | nvarchar(max) | - | Table field. |
| createdAt | datetime | - | Created date and time. |

Primary Key:
- forumChatId

Foreign Key:
- forumId -> Forum.forumId
- senderUserId -> User.userId

Sample Data:
Only selected sample records are shown.

| forumChatId | forumId | senderUserId | message | createdAt |
|---|---|---|---|---|
| FC001 | F013 | U016 | I use flashcards too. You should write short notes after each lesson to create them immediately. | 2026-01-06 11:33:44 |
| FC002 | F013 | U012 | Mind maps make it fun because you can draw anything on it. | 2026-06-06 10:22:00 |
| FC003 | F006 | U017 | Hey mom. | 2026-06-13 16:30:00 |

21. Tag table

Description:
Keeps forum tags.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| tagId | nvarchar(10) | PK | Table field. |
| tagName | nvarchar(100) | - | Table field. |
| createdAt | datetime | - | Created date and time. |

Primary Key:
- tagId

Foreign Key:
- None

Sample Data:
Only selected sample records are shown.

| tagId | tagName | createdAt |
|---|---|---|
| TAG001 | Human Sense | 2026-01-01 14:39:00 |
| TAG002 | Classify Taste | 2026-01-01 14:40:00 |
| TAG003 | Use of Human Sense | 2026-01-01 14:42:00 |

22. ForumTag table

Description:
Links forums with tags.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| forumTagId | nvarchar(10) | PK | Table field. |
| forumId | nvarchar(10) | FK -> Forum.forumId | Table field. |
| tagId | nvarchar(10) | FK -> Tag.tagId | Table field. |

Primary Key:
- forumTagId

Foreign Key:
- forumId -> Forum.forumId
- tagId -> Tag.tagId

Sample Data:
Only selected sample records are shown.

| forumTagId | forumId | tagId |
|---|---|---|
| FTAG001 | F001 | TAG043 |
| FTAG002 | F002 | TAG016 |
| FTAG003 | F003 | TAG013 |

23. ForumLike table

Description:
Keeps forum likes.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| likeId | nvarchar(10) | PK | Table field. |
| forumId | nvarchar(10) | FK -> Forum.forumId | Table field. |
| senderUserId | nvarchar(10) | FK -> User.userId | User who sent the record. |
| createdAt | datetime | - | Created date and time. |

Primary Key:
- likeId

Foreign Key:
- forumId -> Forum.forumId
- senderUserId -> User.userId

Sample Data:
Only selected sample records are shown.

| likeId | forumId | senderUserId | createdAt |
|---|---|---|---|
| LIKE001 | F001 | U003 | 2026-01-21 18:05:00 |
| LIKE002 | F001 | U008 | 2026-01-21 18:20:00 |
| LIKE003 | F002 | U012 | 2026-01-29 09:30:00 |

24. Question table

Description:
Keeps quiz questions and answer options.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| questionId | nvarchar(10) | PK | Question ID. |
| quizId | nvarchar(10) | FK -> Quiz.quizId | Quiz ID. |
| subtopicId | nvarchar(10) | FK -> Subtopic.subtopicId | Subtopic ID. |
| createdByUserId | nvarchar(10) | FK -> User.userId | User who created the record. |
| questionTextEN | nvarchar(max) | - | English text. |
| questionTextBM | nvarchar(max) | - | Bahasa Melayu text. |
| questionType | nvarchar(50) | - | Type. |
| questionImageUrl | nvarchar(200) | - | Question image path. |
| optionA_EN | nvarchar(500) | - | English text. |
| optionA_BM | nvarchar(500) | - | Bahasa Melayu text. |
| optionB_EN | nvarchar(500) | - | English text. |
| optionB_BM | nvarchar(500) | - | Bahasa Melayu text. |
| optionC_EN | nvarchar(500) | - | English text. |
| optionC_BM | nvarchar(500) | - | Bahasa Melayu text. |
| optionD_EN | nvarchar(500) | - | English text. |
| optionD_BM | nvarchar(500) | - | Bahasa Melayu text. |
| correctAnswer | nvarchar(200) | - | Table field. |
| correctExplanationEN | nvarchar(max) | - | English text. |
| correctExplanationBM | nvarchar(max) | - | Bahasa Melayu text. |
| wrongExplanationEN | nvarchar(max) | - | English text. |
| wrongExplanationBM | nvarchar(max) | - | Bahasa Melayu text. |
| difficulty | nvarchar(20) | - | Table field. |
| status | nvarchar(20) | - | Record status. |
| createdAt | datetime | - | Created date and time. |
| reviewedDate | datetime | - | Reviewed date. |

Primary Key:
- questionId

Foreign Key:
- quizId -> Quiz.quizId
- subtopicId -> Subtopic.subtopicId
- createdByUserId -> User.userId

Sample Data:
Only selected sample records are shown.

| questionId | quizId | subtopicId | createdByUserId | questionTextEN | questionTextBM | questionType | questionImageUrl | optionA_EN | optionA_BM | optionB_EN | optionB_BM | optionC_EN | optionC_BM | optionD_EN | optionD_BM | correctAnswer | correctExplanationEN | correctExplanationBM | wrongExplanationEN | wrongExplanationBM | difficulty | status | createdAt | reviewedDate |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| QST001 | Q001 | ST111 | U022 | Which sense helps us hear sounds? | Deria manakah yang membantu kita mendengar bunyi? | MCQ | Images/Question/human_senses.jpg | Sight | Penglihatan | Hearing | Pendengaran | Taste | Rasa | Smell | Bau | B | Correct! The sense of hearing allows us to hear sounds such as music, voices and alarms through our ears. | Betul! Deria pendengaran membolehkan kita mendengar bunyi seperti muzik, suara dan loceng menggunakan telinga. | Incorrect. Sight is used for seeing, taste is used for identifying flavours and smell is used for detecting scents. | Incorrect. Sight is used for seeing, taste is used for identifying flavours and smell is used for detecting scents. | Easy | Approved | 2026-01-02 10:00:00 | 2026-01-07 10:00:00 |
| QST002 | Q001 | ST111 | U022 | Select ALL organs that are part of the five human senses. | Pilih SEMUA organ yang merupakan sebahagian daripada lima deria manusia. | Multiselect | NULL | Reading a book | Membaca buku | Watching television | Menonton televisyen | Smelling a flower | Menghidu bunga | Identifying traffic lights | Mengenal lampu isyarat | A,B,D | Reading, watching television and identifying traffic lights all require our eyes. | Membaca, menonton televisyen dan mengenal lampu isyarat memerlukan penggunaan mata. | hink about which activities require you to see objects or colours. | Fikirkan aktiviti yang memerlukan kita melihat objek atau warna. | Medium | Approved | 2026-01-02 10:00:00 | 2026-01-07 10:00:00 |
| QST003 | Q001 | ST111 | U022 | Complete the sentence by dragging the correct answer.<br><br>We use our _____ to taste food. | Lengkapkan ayat dengan menyeret jawapan yang betul.<br><br>Kita menggunakan _____ untuk merasa makanan. | Drag & Drop | NULL | Tongue | Lidah | Ear | Telinga | NULL | NULL | NULL | NULL | Tongue,Lidah | The tongue contains taste buds that help us detect different tastes such as sweet, sour, salty and bitter. | Lidah mempunyai tunas rasa yang membantu kita mengesan pelbagai rasa seperti manis, masam, masin dan pahit | Food is tasted using the tongue, not the ears. | Makanan dirasa menggunakan lidah, bukan telinga. | Easy | Approved | 2026-01-02 10:00:00 | 2026-01-07 10:00:00 |

Notes:
- questionImageUrl is NULL when no image is used.

25. QuizResult table

Description:
Keeps student quiz result records.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| resultId | nvarchar(10) | PK | Quiz result ID. |
| studentId | nvarchar(10) | FK -> Student.studentId | Student ID. |
| quizId | nvarchar(10) | FK -> Quiz.quizId | Quiz ID. |
| score | int | - | Score value. |
| totalMarks | int | - | Marks value. |
| percentage | decimal(5,2) | - | Table field. |
| resultStatus | nvarchar(20) | - | Table field. |
| attemptNo | int | - | Order number. |
| attemptedDate | datetime | - | Quiz attempt date. |

Primary Key:
- resultId

Foreign Key:
- studentId -> Student.studentId
- quizId -> Quiz.quizId

Sample Data:
Only selected sample records are shown.

| resultId | studentId | quizId | score | totalMarks | percentage | resultStatus | attemptNo | attemptedDate |
|---|---|---|---|---|---|---|---|---|
| QR001 | S005 | Q001 | 10 | 10 | 100 | Passed | 1 | 2026-01-15 10:50:00 |
| QR002 | S005 | Q002 | 18 | 23 | 78.26 | Passed | 1 | 2026-01-15 11:00:00 |
| QR003 | S005 | Q003 | 14 | 19 | 73.68 | Passed | 1 | 2026-01-15 11:06:00 |

26. QuizAnswer table

Description:
Keeps answers selected in quiz attempts.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| answerId | nvarchar(10) | PK | Quiz answer ID. |
| resultId | nvarchar(10) | FK -> QuizResult.resultId | Quiz result ID. |
| questionId | nvarchar(10) | FK -> Question.questionId | Question ID. |
| selectedAnswer | nvarchar(500) | - | Table field. |
| isCorrect | bit | - | Correct answer value. |
| marksAwarded | int | - | Marks value. |

Primary Key:
- answerId

Foreign Key:
- resultId -> QuizResult.resultId
- questionId -> Question.questionId

Sample Data:
Only selected sample records are shown.

| answerId | resultId | questionId | selectedAnswer | isCorrect | marksAwarded |
|---|---|---|---|---|---|
| QA001 | QR001 | QST001 | B | 1 | 1 |
| QA002 | QR001 | QST002 | A,B,D | 1 | 3 |
| QA003 | QR001 | QST003 | Tongue | 1 | 1 |

27. XPTransaction table

Description:
Keeps XP earned by students.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| xpTransactionId | nvarchar(10) | PK | XP transaction ID. |
| studentId | nvarchar(10) | FK -> Student.studentId | Student ID. |
| xpActionId | nvarchar(10) | FK -> XPAction.xpActionId | XP action ID. |
| xpAmount | int | - | Table field. |
| dateEarned | datetime | - | Date XP was earned. |

Primary Key:
- xpTransactionId

Foreign Key:
- studentId -> Student.studentId
- xpActionId -> XPAction.xpActionId

Sample Data:
Only selected sample records are shown.

| xpTransactionId | studentId | xpActionId | xpAmount | dateEarned |
|---|---|---|---|---|
| XPT001 | S002 | XP001 | 10 | 2026-05-16 00:00:00 |
| XPT002 | S002 | XP003 | 10 | 2026-05-17 00:00:00 |
| XPT003 | S002 | XP002 | 15 | 2026-05-18 00:00:00 |

28. LessonProgress table

Description:
Keeps student lesson completion records.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| progressId | nvarchar(10) | PK | Lesson progress ID. |
| studentId | nvarchar(10) | FK -> Student.studentId | Student ID. |
| lessonId | nvarchar(10) | FK -> Lesson.lessonId | Lesson ID. |
| isCompleted | bit | - | Completion value. |
| completedDate | datetime | - | Completed date. |

Primary Key:
- progressId

Foreign Key:
- studentId -> Student.studentId
- lessonId -> Lesson.lessonId

Sample Data:
Only selected sample records are shown.

| progressId | studentId | lessonId | isCompleted | completedDate |
|---|---|---|---|---|
| PR001 | S002 | LS001 | 1 | 2026-05-16 00:00:00 |
| PR002 | S002 | LS002 | 1 | 2026-05-17 00:00:00 |
| PR003 | S002 | LS003 | 0 | NULL |

29. Certificate table

Description:
Keeps student certificate records.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| certificateId | nvarchar(20) | PK | Certificate ID. |
| studentId | nvarchar(10) | FK -> Student.studentId | Student ID. |
| levelId | nvarchar(10) | FK -> Level.levelId | Level ID. |
| certificateTitleEN | nvarchar(100) | - | English text. |
| certificateTitleBM | nvarchar(100) | - | Bahasa Melayu text. |
| certificateDescriptionEN | nvarchar(500) | - | English text. |
| certificateDescriptionBM | nvarchar(500) | - | Bahasa Melayu text. |
| issuedDate | datetime | - | Issued date. |
| certificateUrl | nvarchar(200) | - | Certificate file path. |
| certificateCode | nvarchar(50) | - | Table field. |
| status | nvarchar(20) | - | Record status. |

Primary Key:
- certificateId

Foreign Key:
- studentId -> Student.studentId
- levelId -> Level.levelId

Sample Data:
Only selected sample records are shown.

| certificateId | studentId | levelId | certificateTitleEN | certificateTitleBM | certificateDescriptionEN | certificateDescriptionBM | issuedDate | certificateUrl | certificateCode | status |
|---|---|---|---|---|---|---|---|---|---|---|
| CERT001 | S005 | LV001 | Beginner Science Completion Certificate | Sijil Tamat Sains Pemula | Awarded for successfully completing all Beginner Science learning units and meeting the minimum passing requirements. | Dianugerahkan kerana berjaya menamatkan semua unit pembelajaran Sains Pemula dan memenuhi syarat kelulusan minimum. | 2026-01-28 00:00:00 | Images/Certificate/cert_s005_lv001.pdf | SCI-BEG-S005 | Active |
| CERT002 | S006 | LV001 | Beginner Science Completion Certificate | Sijil Tamat Sains Pemula | Awarded for successfully completing all Beginner Science learning units and meeting the minimum passing requirements. | Dianugerahkan kerana berjaya menamatkan semua unit pembelajaran Sains Pemula dan memenuhi syarat kelulusan minimum. | 2026-02-28 00:00:00 | cert_s006_lv001.pdf | SCI-BEG-S006 | Active |
| CERT003 | S006 | LV002 | Intermediate Science Completion Certificate | Sijil Tamat Sains Pertengahan | Awarded for successfully completing all Intermediate Science learning units and achieving the required passing score. | Dianugerahkan kerana berjaya menamatkan semua unit pembelajaran Sains Pemula dan memenuhi syarat kelulusan minimum. | 2026-04-30 00:00:00 | cert_s006_lv002.pdf | SCI-INT-S006 | Active |

30. Log table

Description:
Keeps system log records.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| logId | nvarchar(10) | PK | Table field. |
| userId | nvarchar(10) | FK -> User.userId | Related user ID. |
| action | nvarchar(50) | - | Table field. |
| description | nvarchar(500) | - | Description. |
| logDateTime | datetime | - | Log date and time. |
| status | nvarchar(20) | - | Record status. |

Primary Key:
- logId

Foreign Key:
- userId -> User.userId

Sample Data:
Only selected sample records are shown.

| logId | userId | action | description | logDateTime | status |
|---|---|---|---|---|---|
| LOG001 | U002 | Login | User logged into the system successfully. | 2026-05-16 08:05:00 | Success |
| LOG002 | U018 | Failed Login | Incorrect password entered. Attempt 1 of 3. | 2026-06-14 07:55:43 | Failed |
| LOG003 | U018 | Failed Login | Incorrect password entered. Attempt 2 of 3. | 2026-06-14 07:57:43 | Failed |

31. Notification table

Description:
Keeps notification records for users.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| notificationId | nvarchar(10) | PK | Notification ID. |
| toUserId | nvarchar(10) | FK -> User.userId | User receiving the notification. |
| titleEN | nvarchar(100) | - | English text. |
| titleBM | nvarchar(100) | - | Bahasa Melayu text. |
| messageEN | nvarchar(500) | - | English text. |
| messageBM | nvarchar(500) | - | Bahasa Melayu text. |
| isRead | bit | - | Read value. |
| createdAt | datetime | - | Created date and time. |

Primary Key:
- notificationId

Foreign Key:
- toUserId -> User.userId

Sample Data:
Only selected sample records are shown.

| notificationId | toUserId | titleEN | titleBM | messageEN | messageBM | isRead | createdAt |
|---|---|---|---|---|---|---|---|
| N001 | U002 | Welcome to ScienceBuddy | Selamat Datang ke ScienceBuddy | Start your first lesson today. | Mulakan pelajaran pertama anda hari ini. | 0 | 2026-06-05 04:46:20 |
| N002 | U003 | Quiz Completed | Kuiz Selesai | You passed your quiz. | Anda telah lulus kuiz anda. | 1 | 2026-06-02 12:14:57 |
| N003 | U011 | New Badge Earned | Lencana Baharu Diperoleh | You earned High Scorer. | Anda memperoleh Skor Cemerlang. | 0 | 2026-06-13 14:31:55 |

32. LabProgress table

Description:
Keeps student virtual lab progress.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| labProgressId | nvarchar(10) | PK | Lab progress ID. |
| studentId | nvarchar(10) | FK -> Student.studentId | Student ID. |
| labId | nvarchar(10) | FK -> VirtualLab.labId | Virtual lab ID. |
| isCompleted | bit | - | Completion value. |
| completedDate | datetime | - | Completed date. |

Primary Key:
- labProgressId

Foreign Key:
- studentId -> Student.studentId
- labId -> VirtualLab.labId

Sample Data:
Only selected sample records are shown.

| labProgressId | studentId | labId | isCompleted | completedDate |
|---|---|---|---|---|
| LABP001 | S002 | LAB001 | 1 | 2026-05-18 00:00:00 |
| LABP002 | S004 | LAB001 | 1 | 2026-06-04 00:00:00 |
| LABP003 | S004 | LAB002 | 1 | 2026-10-04 00:00:00 |

33. LiveConsultationSession table

Description:
Keeps teacher live session details.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| sessionId | nvarchar(10) | PK | Live session ID. |
| teacherId | nvarchar(10) | FK -> Teacher.teacherId | Teacher ID. |
| unitId | nvarchar(10) | FK -> Unit.unitId | Unit ID. |
| subtopicId | nvarchar(10) | FK -> Subtopic.subtopicId | Subtopic ID. |
| sessionTitle | nvarchar(100) | - | Title. |
| sessionDescription | nvarchar(500) | - | Description. |
| meetingLink | nvarchar(200) | - | Meeting link. |
| startDateTime | datetime | - | Session start date and time. |
| endDateTime | datetime | - | Session end date and time. |
| status | nvarchar(20) | - | Record status. |

Primary Key:
- sessionId

Foreign Key:
- teacherId -> Teacher.teacherId
- unitId -> Unit.unitId
- subtopicId -> Subtopic.subtopicId

Sample Data:
Only selected sample records are shown.

| sessionId | teacherId | unitId | subtopicId | sessionTitle | sessionDescription | meetingLink | startDateTime | endDateTime | status |
|---|---|---|---|---|---|---|---|---|---|
| LIVE001 | T004 | UN201 | ST211 | Healthy Teeth Workshop | Learn how to maintain healthy teeth through proper habits. | https://meet.google.com/tth-sci-teeth | 2026-01-20 10:00:00 | 2026-01-20 12:00:00 | Completed |
| LIVE002 | T004 | UN202 | ST221 | Float and Sink Experiment | Live demonstration of floating and sinking objects. | https://meet.google.com/tth-float-sink | 2026-02-13 14:00:00 | 2026-02-13 15:00:00 | Completed |
| LIVE003 | T005 | UN104 | ST141 | Meneroka Bentuk Muka Bumi | Kenali gunung, lembah, pantai dan pelbagai bentuk muka bumi melalui contoh visual. | https://meet.google.com/tth-landforms | 2026-05-20 14:30:00 | 2026-05-20 16:30:00 | Completed |

34. LiveSessionParticipant table

Description:
Keeps students who joined live sessions.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| participantId | nvarchar(20) | PK | Participant ID. |
| sessionId | nvarchar(10) | FK -> LiveConsultationSession.sessionId | Live session ID. |
| studentId | nvarchar(10) | FK -> Student.studentId | Student ID. |
| joinedAt | datetime | - | Joined date and time. |

Primary Key:
- participantId

Foreign Key:
- sessionId -> LiveConsultationSession.sessionId
- studentId -> Student.studentId

Sample Data:
Only selected sample records are shown.

| participantId | sessionId | studentId | joinedAt |
|---|---|---|---|
| LIVEP001 | LIVE001 | S010 | 2026-01-20 10:05:00 |
| LIVEP002 | LIVE001 | S009 | 2026-01-20 10:05:00 |
| LIVEP003 | LIVE001 | S005 | 2026-01-20 10:20:00 |

35. UserStatusAction table

Description:
Keeps user status actions done by admin.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| actionId | nvarchar(10) | PK | Action ID. |
| userId | nvarchar(10) | FK -> User.userId | Related user ID. |
| actionType | nvarchar(20) | - | Type. |
| reason | nvarchar(500) | - | Table field. |
| actionDate | datetime | - | Action date and time. |
| performedBy | nvarchar(10) | FK -> User.userId | Table field. |

Primary Key:
- actionId

Foreign Key:
- userId -> User.userId
- performedBy -> User.userId

Sample Data:
Only selected sample records are shown.

| actionId | userId | actionType | reason | actionDate | performedBy |
|---|---|---|---|---|---|
| US001 | U018 | Blocked | Suspicious login attempts exceeded limit. | 2026-06-14 00:00:00 | U001 |
| US002 | U018 | Unblocked | Account lock duration completed and account restored. | 2026-06-14 00:00:00 | U001 |
| US003 | U004 | Deleted | User requested account deletion. | 2026-05-30 00:00:00 | U001 |

36. AILearningAnalysis table

Description:
Keeps learning analysis for students.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| analysisId | nvarchar(10) | PK | Analysis ID. |
| studentId | nvarchar(10) | FK -> Student.studentId | Student ID. |
| analysisJson | nvarchar(max) | - | Table field. |
| overallSummary | nvarchar(500) | - | Table field. |
| strongTopics | nvarchar(500) | - | Table field. |
| weakTopics | nvarchar(500) | - | Table field. |
| avgQuizScore | decimal(5,2) | - | Score value. |
| totalQuizAttempts | int | - | Date and time value. |
| isLatest | bit | - | Latest analysis value. |

Primary Key:
- analysisId

Foreign Key:
- studentId -> Student.studentId

Sample Data:
Only selected sample records are shown.

| analysisId | studentId | analysisJson | overallSummary | strongTopics | weakTopics | avgQuizScore | totalQuizAttempts | isLatest |
|---|---|---|---|---|---|---|---|---|
| A001 | S002 | NULL | Student is progressing steadily in Beginner level. | Basic science concepts | Scientific method | 65 | 2 | 1 |
| A002 | S004 | NULL | Student performs excellently and is ready for level completion. | Scientific method, Matter, Energy | NULL | 90 | 3 | 1 |
| A003 | S005 | NULL | Student completed Beginner level and is adapting to Intermediate topics. | Beginner concepts | Forces and electricity | 65 | 2 | 1 |

37. StudyPlan table

Description:
Keeps study plans for students.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| studyPlanId | nvarchar(10) | PK | Study plan ID. |
| studentParentId | nvarchar(10) | FK -> StudentParent.studentParentId | Student-parent link ID. |
| createdByUserId | nvarchar(10) | FK -> User.userId | User who created the record. |
| planTitle | nvarchar(100) | - | Title. |
| startDate | datetime | - | Plan start date. |
| endDate | datetime | - | Plan end date. |
| status | nvarchar(20) | - | Record status. |
| createdAt | datetime | - | Created date and time. |

Primary Key:
- studyPlanId

Foreign Key:
- studentParentId -> StudentParent.studentParentId
- createdByUserId -> User.userId

Sample Data:
Only selected sample records are shown.

| studyPlanId | studentParentId | createdByUserId | planTitle | startDate | endDate | status | createdAt |
|---|---|---|---|---|---|---|---|
| STP001 | SP002 | U006 | Siti Human Revision Plan | 2026-06-10 00:00:00 | 2026-06-16 00:00:00 | Ongoing | 2026-06-10 19:00:00 |
| STP002 | SP003 | U002 | This Week | 2026-06-01 00:00:00 | 2026-06-08 00:00:00 | Ongoing | 2026-06-01 15:21:00 |
| STP003 | SP006 | U005 | Hana Weak Topic Support Plan | 2026-06-02 00:00:00 | 2026-06-09 00:00:00 | Completed | 2026-06-02 20:15:00 |

38. SPTask table

Description:
Keeps tasks inside study plans.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| spTaskId | nvarchar(10) | PK | Study plan task ID. |
| studyPlanId | nvarchar(10) | FK -> StudyPlan.studyPlanId | Study plan ID. |
| taskTitle | nvarchar(100) | - | Title. |
| suggestedAction | nvarchar(500) | - | Table field. |
| orderNo | int | - | Order number. |
| isCompleted | bit | - | Completion value. |
| completedAt | datetime | - | Date and time value. |

Primary Key:
- spTaskId

Foreign Key:
- studyPlanId -> StudyPlan.studyPlanId

Sample Data:
Only selected sample records are shown.

| spTaskId | studyPlanId | taskTitle | suggestedAction | orderNo | isCompleted | completedAt |
|---|---|---|---|---|---|---|
| SPT001 | STP001 | Review Human Sense Lesson | Read notes about the five human senses. | 1 | 1 | 2026-06-10 20:00:00 |
| SPT002 | STP001 | Classify taste examples | Extra revision | 2 | 0 | NULL |
| SPT003 | STP001 | Attempt Human Sense Quiz | Complete quiz after revision | 3 | 0 | NULL |

39. SPReward table

Description:
Keeps rewards inside study plans.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| rewardId | nvarchar(10) | PK | Reward ID. |
| studyPlanId | nvarchar(10) | FK -> StudyPlan.studyPlanId | Study plan ID. |
| rewardName | nvarchar(100) | - | Table field. |
| requiredProgress | int | - | Table field. |
| isUnlocked | bit | - | Reward unlocked value. |
| unlockedAt | datetime | - | Date and time value. |

Primary Key:
- rewardId

Foreign Key:
- studyPlanId -> StudyPlan.studyPlanId

Sample Data:
Only selected sample records are shown.

| rewardId | studyPlanId | rewardName | requiredProgress | isUnlocked | unlockedAt | rewardImage
|---|---|---|---|---|---|
| SPR001 | STP001 | Extra Screentime (2 hours) | 25 | 1 | 2026-06-12 18:22:13 | Images/Rewards/Screentime.png
| SPR002 | STP001 | Watch "Spiderman" at the movies | 50 | 1 | 2026-06-15 22:10:10 |Images/Rewards/spiderman.png
| SPR003 | STP002 | McDonalds | 25 | 1 | 2026-06-03 16:10:10 | Images/Rewards/mcdonald.png

40. userChat table

Description:
Keeps private chat rooms between users.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| chatId | nvarchar(10) | PK | Private chat ID. |
| userId | nvarchar(10) | FK -> User.userId | Related user ID. |
| user2Id | nvarchar(10) | FK -> User.userId | Second user in chat. |
| createdAt | datetime | - | Created date and time. |

Primary Key:
- chatId

Foreign Key:
- userId -> User.userId
- user2Id -> User.userId

Sample Data:
Only selected sample records are shown.

| chatId | userId | user2Id | createdAt |
|---|---|---|---|
| C001 | U002 | U008 | 2026-05-06 10:00:00 |
| C002 | U003 | U008 | 2026-06-03 14:00:00 |
| C003 | U003 | U009 | 2026-06-15 20:00:00 |

Notes:
- The first chat user column is userId in the real SQL.

41. privateMessage table

Description:
Keeps private messages inside private chats.

Columns:
| Column Name | Data Type | Key | Description |
|---|---|---|---|
| privateMsgId | nvarchar(10) | PK | Private message ID. |
| chatId | nvarchar(10) | FK -> userChat.chatId | Private chat ID. |
| senderUserId | nvarchar(10) | FK -> User.userId | User who sent the record. |
| msgText | nvarchar(max) | - | Table field. |
| attachmentFile | nvarchar(200) | - | Message attachment file. |
| sentAt | datetime | - | Message sent date and time. |
| isRead | bit | - | Read value. |
| readAt | datetime | - | Message read date and time. |

Primary Key:
- privateMsgId

Foreign Key:
- chatId -> userChat.chatId
- senderUserId -> User.userId

Sample Data:
Only selected sample records are shown.

| privateMsgId | chatId | senderUserId | msgText | attachmentFile | sentAt | isRead | readAt |
|---|---|---|---|---|---|---|---|
| PM001 | C001 | U002 | Can you checkout my answers I wrote on paper? | Images/PrivateMessage/answer.pdf | 2026-07-03 10:00:00 | 1 | 2026-07-04 14:00:00 |
| PM002 | C001 | U008 | Sure! Question 2 and 3 is wrong. | NULL | 2026-07-03 10:10:55 | 0 | NULL |
| PM003 | C002 | U003 | Miss, I think the answer for question 4 is wrong. | NULL | 2026-07-07 09:00:00 | 1 | 2026-07-07 09:04:00 |

Notes:
- attachmentFile is NULL when the message has no attachment.

2.0 Static / Constant Tables

The following tables are inserted in InsertConstants_real.sql:

- Level
- Personality
- Badge
- Unit
- Subtopic
- Lesson
- XPAction
- ConfigurationSetting
- VirtualLab

3.0 Main Relationship Summary

| No. | Child Table | Foreign Key | Parent Table | Parent Key |
|---|---|---|---|---|
| 1 | Unit | levelId | Level | levelId |
| 2 | Subtopic | unitId | Unit | unitId |
| 3 | Lesson | subtopicId | Subtopic | subtopicId |
| 4 | VirtualLab | unitId | Unit | unitId |
| 5 | Student | userId | User | userId |
| 6 | Student | currentLevelId | Level | levelId |
| 7 | Student | personalityId | Personality | personalityId |
| 8 | Parent | userId | User | userId |
| 9 | Teacher | userId | User | userId |
| 10 | StudentParent | studentId | Student | studentId |
| 11 | StudentParent | parentId | Parent | parentId |
| 12 | Enrollment | studentId | Student | studentId |
| 13 | Enrollment | levelId | Level | levelId |
| 14 | StudentBadge | studentId | Student | studentId |
| 15 | StudentBadge | badgeId | Badge | badgeId |
| 16 | Quiz | levelId | Level | levelId |
| 17 | Quiz | unitId | Unit | unitId |
| 18 | Quiz | createdByUserId | User | userId |
| 19 | Material | subtopicId | Subtopic | subtopicId |
| 20 | Material | createdByUserId | User | userId |
| 21 | Forum | createdBy | User | userId |
| 22 | ForumChat | forumId | Forum | forumId |
| 23 | ForumChat | senderUserId | User | userId |
| 24 | ForumTag | forumId | Forum | forumId |
| 25 | ForumTag | tagId | Tag | tagId |
| 26 | ForumLike | forumId | Forum | forumId |
| 27 | ForumLike | senderUserId | User | userId |
| 28 | Question | quizId | Quiz | quizId |
| 29 | Question | subtopicId | Subtopic | subtopicId |
| 30 | Question | createdByUserId | User | userId |
| 31 | QuizResult | studentId | Student | studentId |
| 32 | QuizResult | quizId | Quiz | quizId |
| 33 | QuizAnswer | resultId | QuizResult | resultId |
| 34 | QuizAnswer | questionId | Question | questionId |
| 35 | XPTransaction | studentId | Student | studentId |
| 36 | XPTransaction | xpActionId | XPAction | xpActionId |
| 37 | LessonProgress | studentId | Student | studentId |
| 38 | LessonProgress | lessonId | Lesson | lessonId |
| 39 | Certificate | studentId | Student | studentId |
| 40 | Certificate | levelId | Level | levelId |
| 41 | Log | userId | User | userId |
| 42 | Notification | toUserId | User | userId |
| 43 | LabProgress | studentId | Student | studentId |
| 44 | LabProgress | labId | VirtualLab | labId |
| 45 | LiveConsultationSession | teacherId | Teacher | teacherId |
| 46 | LiveConsultationSession | unitId | Unit | unitId |
| 47 | LiveConsultationSession | subtopicId | Subtopic | subtopicId |
| 48 | LiveSessionParticipant | sessionId | LiveConsultationSession | sessionId |
| 49 | LiveSessionParticipant | studentId | Student | studentId |
| 50 | UserStatusAction | userId | User | userId |
| 51 | UserStatusAction | performedBy | User | userId |
| 52 | AILearningAnalysis | studentId | Student | studentId |
| 53 | StudyPlan | studentParentId | StudentParent | studentParentId |
| 54 | StudyPlan | createdByUserId | User | userId |
| 55 | SPTask | studyPlanId | StudyPlan | studyPlanId |
| 56 | SPReward | studyPlanId | StudyPlan | studyPlanId |
| 57 | userChat | userId | User | userId |
| 58 | userChat | user2Id | User | userId |
| 59 | privateMessage | chatId | userChat | chatId |
| 60 | privateMessage | senderUserId | User | userId |

4.0 Important Database Rules

- Login uses User table.
- Only Active users can login.
- Student, Parent, and Teacher profile tables are linked to User.
- Lessons belong to Subtopic.
- Quiz is linked to Level and Unit. In the real SQL, levelId and unitId allow NULL.
- Quiz table does not have subtopicId in the real SQL.
- Question links the quiz questions to Quiz and Subtopic.
- QuizAnswer must link to existing QuizResult and Question.
- StudyPlan is linked to StudentParent. studentParentId allows NULL in the real SQL.
- SPTask and SPReward are linked to StudyPlan.
- userChat stores private chat room.
- privateMessage stores messages under userChat.

5.0 Naming Convention

Use the exact database names below:

- userId
- studentId
- parentId
- teacherId
- studentParentId
- levelId
- unitId
- subtopicId
- lessonId
- quizId
- questionId
- resultId
- answerId
- studyPlanId
- spTaskId
- rewardId
- chatId
- privateMsgId

6.0 Data Review Notes

No major issue found after checking with the fixed real SQL files.
