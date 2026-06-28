/* ScienceBuddy_DB - InsertSampleData.sql
   Generated from the provided ScienceBuddy data sheet. */


IF DB_ID(N'ScienceBuddy_DB') IS NULL
BEGIN
    THROW 51000, 'ScienceBuddy_DB does not exist. Run CreateTables.sql first.', 1;
END;
GO

USE [ScienceBuddy_DB];
GO

IF OBJECT_ID(N'dbo.[User]', N'U') IS NULL
BEGIN
    THROW 51001, 'ScienceBuddy tables do not exist. Run CreateTables.sql fully first, then InsertConstants.sql, then InsertSampleData.sql.', 1;
END;
GO

SET NOCOUNT ON;
GO

PRINT N'Inserting User (24 rows)...';
INSERT INTO dbo.[User] ([userId], [username], [password], [email], [role], [preferredLanguage], [status])
VALUES
    (N'U001', N'najihah01', N'12345', N'admin@sciencebuddy.edu', N'Admin', N'EN', N'Active'),
    (N'U002', N'Aiman', N'12345', N'aiman@gmail.com', N'Student', N'BM', N'Active'),
    (N'U003', N'siti', N'12345', N'siti@gmail.com', N'Student', N'EN', N'Active'),
    (N'U004', N'abu', N'12345', N'abu@gmail.com', N'Student', N'BM', N'Deleted'),
    (N'U005', N'aminah', N'aminah123', N'aminah@gmail.com', N'Parent', N'EN', N'Active'),
    (N'U006', N'hassan', N'hassan456', N'hassan@gmail.com', N'Parent', N'BM', N'Active'),
    (N'U007', N'laila', N'laila789', N'laila@gmail.com', N'Parent', N'EN', N'Deleted'),
    (N'U008', N'zara', N'12345', N'zara@gmail.com', N'Teacher', N'BM', N'Active'),
    (N'U009', N'reza', N'12345', N'reza@gmail.com', N'Teacher', N'EN', N'Active'),
    (N'U010', N'nurul', N'12345', N'nurul@gmail.com', N'Teacher', N'BM', N'Blocked'),
    (N'U011', N'danial', N'12345', N'danial@gmail.com', N'Student', N'EN', N'Active'),
    (N'U012', N'maya', N'12345', N'maya@gmail.com', N'Student', N'BM', N'Active'),
    (N'U013', N'faris', N'12345', N'faris@gmail.com', N'Student', N'EN', N'Active'),
    (N'U014', N'hana', N'12345', N'hana@gmail.com', N'Student', N'BM', N'Active'),
    (N'U015', N'iqbal', N'12345', N'iqbal@gmail.com', N'Student', N'EN', N'Active'),
    (N'U016', N'qistina', N'12345', N'qistina@gmail.com', N'Student', N'BM', N'Active'),
    (N'U017', N'rayyan', N'12345', N'rayyan@gmail.com', N'Student', N'EN', N'Active'),
    (N'U018', N'sofia', N'12345', N'sofia@gmail.com', N'Student', N'BM', N'Blocked'),
    (N'U019', N'hakim', N'12345', N'hakim@gmail.com', N'Parent', N'BM', N'Active'),
    (N'U020', N'ana', N'12345', N'ananawai@gmail.com', N'Parent', N'BM', N'Active'),
    (N'U021', N'hisyam', N'12345', N'hisyamhamdan@gmail.com', N'Parent', N'BM', N'Active'),
    (N'U022', N'nurun', N'9999', N'nurun99@gmail.com', N'Teacher', N'EN', N'Active'),
    (N'U023', N'amin', N'9988', N'amin@gmail.com', N'Teacher', N'EN', N'Active'),
    (N'U024', N'balqis', N'9900', N'balbal@gmail.com', N'Teacher', N'BM', N'Deleted');
GO

PRINT N'Inserting Parent (6 rows)...';
INSERT INTO dbo.[Parent] ([parentId], [userId], [name], [phoneNumber])
VALUES
    (N'P001', N'U005', N'Aminah Binti Yusof', N'0134444676'),
    (N'P002', N'U006', N'Hassan Bin Zainal', N'0198888900'),
    (N'P003', N'U007', N'Laila Binti Mahfuz', N'0186455333'),
    (N'P004', N'U019', N'Hakim Bin Osman', N'0134567890'),
    (N'P005', N'U020', N'Norhazana Binti Nawai', N'0134567765'),
    (N'P006', N'U021', N'Hisyam Bin Hamdan', N'0198273654');
GO

PRINT N'Inserting Teacher (6 rows)...';
INSERT INTO dbo.[Teacher] ([teacherId], [userId], [name], [phoneNumber], [academicQualification], [bio], [licenseCert], [status], [approvedDate])
VALUES
    (N'T001', N'U008', N'Zara Natasya Binti Karim', N'0112222333', N'B.Sc Biology (UTM)', N'Experienced science teacher with 10 years in secondary education.', N'Images/Teacher/cert_zara.pdf', N'Pending', NULL),
    (N'T002', N'U009', N'Reza Hakim Bin Malik', N'0145555666', N'M.Ed Science Education (UM)', N'Passionate about inquiry-based learning and student engagement.', N'Images/Teacher/cert_reza.pdf', N'Certified', N'2026-01-01'),
    (N'T003', N'U010', N'Nurl Izzah Binti Azmi', N'0178888999', N'B.Ed (Hons) Chemistry (UPM)', N'Focused on helping student grasp foundational concepts.', N'Images/Teacher/cert_izzah.pdf', N'Not Certified', N'2026-01-02'),
    (N'T004', N'U022', N'Nurun binti Azmi', N'0178889000', N'B.Ed (Hons) Science Education (UPSI)', N'Dedicated to nurturing students'' interest in science through inquiry-based learning and exploration.', N'Images/Teacher/cert_nurun.pdf', N'Certified', N'2026-01-03'),
    (N'T005', N'U023', N'Muhammad Amin bin Hakim', N'0125656788', N'B.Ed (Hons) Teaching English as a Second Language (TESL)', N'Specialises in bilingual science instruction to help students understand concepts in both English and Bahasa Melayu.', N'Images/Teacher/cert_amin.pdf', N'Certified', N'2026-01-04'),
    (N'T006', N'U024', N'Balqis binti Suhaimi', N'0156767322', N'B.Ed (Hons) Primary Education (UM)', N'Committed to creating a supportive and inclusive learning environment that encourages curiosity and critical thinking.', N'Images/Teacher/cert_balqis.pdf', N'Certified', N'2026-01-05');
GO

PRINT N'Inserting Student (11 rows)...';
INSERT INTO dbo.[Student] ([studentId], [userId], [name], [phoneNumber], [nickname], [currentLevelId], [XP], [personalityId], [parentCode])
VALUES
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
GO

PRINT N'Inserting StudentParent (10 rows)...';
INSERT INTO dbo.[StudentParent] ([studentParentId], [studentId], [parentId], [relationship])
VALUES
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
GO

PRINT N'Inserting Quiz (53 rows)...';
INSERT INTO dbo.[Quiz] ([quizId], [levelId], [unitId], [subtopicId], [quizTitleEN], [quizTitleBM], [quizType], [status], [createdByUserId], [createdAt], [language])
VALUES
    (N'Q001', N'LV001', N'UN101', N'ST111', N'Understanding Human Senses', N'Memahami Deria Manusia', N'Unit', NULL, N'U001', N'2026-01-01 10:00:00', N'BOTH'),
    (N'Q002', N'LV001', N'UN101', N'ST112', N'Identifying Different Tastes', N'Mengenal Pasti Jenis Rasa', N'Unit', NULL, N'U001', N'2026-01-01 10:02:00', N'BOTH'),
    (N'Q003', N'LV001', N'UN101', N'ST113', N'Using Our Human Senses', N'Menggunakan Deria Manusia', N'Unit', NULL, N'U001', N'2026-01-01 10:05:31', N'BOTH'),
    (N'Q004', N'LV001', N'UN101', N'ST121', N'Exploring the Uses of Magnets', N'Meneroka Kegunaan Magnet', N'Unit', NULL, N'U001', N'2026-01-01 10:09:10', N'BOTH'),
    (N'Q005', N'LV001', N'UN102', N'ST121', NULL, N'Kegunaan Magnet', N'Practice', N'Approved', N'U022', N'2026-01-02 12:01:21', N'BM'),
    (N'Q006', N'LV001', N'UN102', N'ST122', N'Recognising Different Magnet Shapes', N'Mengenal Bentuk-bentuk Magnet', N'Unit', NULL, N'U001', N'2026-01-02 12:59:21', N'BOTH'),
    (N'Q007', N'LV001', N'UN102', N'ST123', N'Understanding Magnetic Attraction and Repulsion', N'Memahami Tarikan dan Tolakan Magnet', N'Unit', NULL, N'U001', N'2026-01-02 15:31:21', N'BOTH'),
    (N'Q008', N'LV001', N'UN103', N'ST131', N'Water Absorbent and Non-Water Absorbent Materials', N'Bahan Menyerap dan Tidak Menyerap Air', N'Unit', NULL, N'U001', N'2026-01-02 17:34:22', N'BOTH'),
    (N'Q009', N'LV001', N'UN103', N'ST132', N'Importance of Water Absorbent Materials', N'Kepentingan Bahan Menyerap dan Tidak Menyerap Air', N'Unit', NULL, N'U001', N'2026-01-03 01:02:22', N'BOTH'),
    (N'Q010', N'LV001', N'UN104', N'ST141', N'Exploring Landforms', N'Meneroka Bentuk Muka Bumi', N'Unit', NULL, N'U001', N'2026-01-03 01:05:26', N'BOTH'),
    (N'Q011', N'LV001', N'UN104', N'ST142', N'Learning About Soil', N'Mempelajari Tanah', N'Unit', NULL, N'U001', N'2026-01-03 01:10:59', N'BOTH'),
    (N'Q012', N'LV001', N'UN105', N'ST151', N'Recognising Basic Shapes', N'Mengenal Bentuk Asas', N'Unit', NULL, N'U001', N'2026-01-03 01:15:22', N'BOTH'),
    (N'Q013', N'LV001', N'UN105', N'ST152', N'Exploring Basic 3D Shapes', N'Meneroka Bentuk Blok Asas', N'Unit', NULL, N'U001', N'2026-01-03 01:17:22', N'BOTH'),
    (N'Q014', N'LV001', N'UN105', N'ST153', N'Importance of 3D Shapes', N'Kepentingan Bentuk Blok', N'Unit', NULL, N'U001', N'2026-01-03 01:20:22', N'BOTH'),
    (N'Q015', N'LV002', N'UN201', N'ST211', N'Understanding Human Teeth', N'Memahami Gigi Manusia', N'Unit', NULL, N'U001', N'2026-01-03 01:26:22', N'BOTH'),
    (N'Q016', N'LV002', N'UN201', N'ST212', N'Healthy Eating and Balanced Diet', N'Pemakanan Sihat dan Diet Seimbang', N'Unit', NULL, N'U001', N'2026-01-03 09:20:22', N'BOTH'),
    (N'Q017', N'LV002', N'UN201', N'ST213', N'Understanding the Digestion Process', N'Memahami Proses Pencernaan', N'Unit', NULL, N'U001', N'2026-01-03 09:23:22', N'BOTH'),
    (N'Q018', N'LV002', N'UN202', N'ST221', N'Float or Sink?', N'Terapung atau Tenggelam?', N'Unit', NULL, N'U001', N'2026-01-03 09:30:00', N'BOTH'),
    (N'Q019', N'LV002', N'UN202', N'ST222', N'Density', NULL, N'Practice', N'Approved', N'U023', N'2026-01-03 13:00:04', N'EN'),
    (N'Q020', N'LV002', N'UN202', N'ST222', N'Understanding Density', N'Memahami Ketumpatan', N'Unit', NULL, N'U001', N'2026-01-04 14:10:04', N'BOTH'),
    (N'Q021', N'LV002', N'UN202', N'ST223', N'Density in Everyday Life', N'Ketumpatan dalam Kehidupan Harian', N'Unit', NULL, N'U001', N'2026-01-04 14:13:00', N'BOTH'),
    (N'Q022', N'LV002', N'UN203', N'ST231', N'Understanding Acids, Alkalis and Neutral Substances', N'Memahami Asid, Alkali dan Neutral', N'Unit', NULL, N'U001', N'2026-01-04 14:20:04', N'BOTH'),
    (N'Q023', N'LV002', N'UN203', N'ST232', N'Acids, Alkalis and Neutral Substances Around Us', N'Bahan Asid, Alkali dan Neutral di Sekeliling Kita', N'Unit', NULL, N'U001', N'2026-01-04 14:23:02', N'BOTH'),
    (N'Q024', N'LV002', N'UN204', N'ST241', N'Exploring the Solar System', N'Meneroka Sistem Suria', N'Unit', NULL, N'U001', N'2026-01-04 14:30:21', N'BOTH'),
    (N'Q025', N'LV002', N'UN204', N'ST242', N'Comparing Planet Temperatures', N'Membandingkan Suhu Planet', N'Unit', NULL, N'U001', N'2026-01-04 14:33:09', N'BOTH'),
    (N'Q026', N'LV002', N'UN204', N'ST243', N'Understanding Planet Orbits', N'Memahami Orbit Planet', N'Unit', NULL, N'U001', N'2026-01-04 14:45:10', N'BOTH'),
    (N'Q027', N'LV002', N'UN204', N'ST244', N'Planet Revolution Time', N'Tempoh Revolusi Planet', N'Unit', NULL, N'U001', N'2026-01-05 08:10:10', N'BOTH'),
    (N'Q028', N'LV002', N'UN205', N'ST251', N'Types of Pulleys', N'Jenis-jenis Takal', N'Unit', NULL, N'U001', N'2026-01-05 08:13:10', N'BOTH'),
    (N'Q029', N'LV002', N'UN205', N'ST252', N'Understanding Fixed Pulleys', N'Memahami Fungsi Takal Tetap', N'Unit', NULL, N'U001', N'2026-01-05 08:47:12', N'BOTH'),
    (N'Q030', N'LV002', N'UN205', N'ST253', N'Exploring the Uses of Pulleys', N'Meneroka Kegunaan Takal', N'Unit', NULL, N'U001', N'2026-01-05 09:00:10', N'BOTH'),
    (N'Q031', N'LV003', N'UN301', N'ST311', N'Understanding the Human Skeletal System', N'Memahami Sistem Rangka Manusia', N'Unit', N'Approved', N'U024', N'2026-01-05 09:04:10', N'BOTH'),
    (N'Q032', N'LV003', N'UN301', N'ST311', NULL, N'Kuiz Unit Sistem Rangka Manusia', N'Practice', N'Rejected', N'U022', N'2026-01-05 09:14:10', N'BM'),
    (N'Q033', N'LV003', N'UN301', N'ST312', N'Understanding Human Joints', N'Memahami Sendi Manusia', N'Unit', NULL, N'U001', N'2026-01-05 09:20:30', N'BOTH'),
    (N'Q034', N'LV003', N'UN301', N'ST313', N'Human Blood Circulatory System', N'Sistem Peredaran Darah Manusia', N'Unit', NULL, N'U001', N'2026-01-05 09:25:22', N'BOTH'),
    (N'Q035', N'LV003', N'UN301', N'ST314', N'Blood Circulation Pathway', N'Laluan Peredaran Darah Manusia', N'Unit', NULL, N'U001', N'2026-01-06 10:00:22', N'BOTH'),
    (N'Q036', N'LV003', N'UN302', N'ST321', N'Sources of Electrical Energy', N'Sumber Tenaga Elektrik', N'Unit', NULL, N'U001', N'2026-01-06 10:00:22', N'BOTH'),
    (N'Q037', N'LV003', N'UN302', N'ST322', N'Series and Parallel Circuits', N'Litar Bersiri dan Litar Selari', N'Unit', NULL, N'U001', N'2026-01-06 10:00:22', N'BOTH'),
    (N'Q038', N'LV003', N'UN302', N'ST323', N'Electrical Circuit Symbols', N'Simbol Litar Elektrik', N'Unit', NULL, N'U001', N'2026-01-06 10:00:22', N'BOTH'),
    (N'Q039', N'LV003', N'UN303', N'ST331', N'Changes in the State of Matter', N'Perubahan Keadaan Jirim', N'Unit', NULL, N'U001', N'2026-01-06 10:00:22', N'BOTH'),
    (N'Q040', N'LV003', N'UN303', N'ST332', N'Properties of Matter', N'Sifat-sifat Jirim', N'Unit', NULL, N'U001', N'2026-01-06 10:00:22', N'BOTH'),
    (N'Q041', N'LV003', N'UN303', N'ST333', N'Understanding the Water Cycle', N'Memahami Kitaran Air', N'Unit', NULL, N'U001', N'2026-01-06 10:00:22', N'BOTH'),
    (N'Q042', N'LV003', N'UN304', N'ST341', N'Phases of the Moon', N'Fasa-fasa Bulan', N'Unit', NULL, N'U001', N'2026-01-06 10:00:22', N'BOTH'),
    (N'Q043', N'LV003', N'UN304', N'ST342', N'Exploring Constellations', N'Meneroka Buruj', N'Unit', NULL, N'U001', N'2026-01-06 10:00:22', N'BOTH'),
    (N'Q044', N'LV003', N'UN305', N'ST351', N'Introduction to Pulleys', N'Pengenalan kepada Takal', N'Unit', NULL, N'U001', N'2026-01-07 13:00:22', N'BOTH'),
    (N'Q045', N'LV003', N'UN305', N'ST352', N'Understanding Gears', N'Memahami Gear', N'Unit', NULL, N'U001', N'2026-01-07 13:00:22', N'BOTH'),
    (N'Q046', N'LV003', N'UN305', N'ST353', N'Simple Machines Around Us', N'Mesin Ringkas di Sekeliling Kita', N'Unit', NULL, N'U001', N'2026-01-07 13:00:22', N'BOTH'),
    (N'Q047', N'LV003', N'UN305', N'ST354', N'Understanding Compound Machines', N'Memahami Mesin Kompleks', N'Unit', NULL, N'U001', N'2026-01-07 13:00:22', N'BOTH'),
    (N'Q048', N'LV001', NULL, NULL, N'Beginner Science Challenge', N'Cabaran Sains Pemula', N'Level', NULL, N'U001', N'2026-01-07 13:00:22', N'BOTH'),
    (N'Q049', N'LV002', NULL, NULL, N'Intermediate Science Challenge', N'Cabaran Sains Pertengahan', N'Level', NULL, N'U001', N'2026-01-07 13:00:22', N'BOTH'),
    (N'Q050', N'LV003', NULL, NULL, N'Advanced Science Challenge', N'Cabaran Sains Lanjutan', N'Level', NULL, N'U001', N'2026-01-07 13:00:22', N'BOTH'),
    (N'Q051', N'LV002', N'UN202', N'ST223', NULL, N'Aplikasi Ketumpatan Dalam Kehidupan', N'Practice', N'Pending', N'U022', N'2026-01-15 15:00:00', N'BM'),
    (N'Q052', N'LV002', N'UN204', N'ST241', N'Members of the Solar System Unit Quiz', NULL, N'Practice', N'Approved', N'U022', N'2026-04-01 15:12:00', N'EN'),
    (N'Q053', N'LV003', N'UN305', N'ST354', N'Understand Compound Machines', NULL, N'Practice', N'Approved', N'U022', N'2026-04-01 20:11:12', N'EN');
GO

PRINT N'Inserting Material (12 rows)...';
INSERT INTO dbo.[Material] ([materialId], [subtopicId], [createdByUserId], [materialTitle], [materialType], [fileUrl], [materialContent], [createdDate], [status], [reviewedDate], [language])
VALUES
    (N'M001', N'ST111', N'U022', N'Human Sense Notes', N'PDF', N'Images/Material/humansense.pdf', N'This material introduces the five human senses and their functions. Students will learn how sight, hearing, smell, taste and touch help humans understand their surroundings.', N'2026-01-28', N'Pending', NULL, N'EN'),
    (N'M002', N'ST122', N'U023', N'Bentuk-Bentuk Magnet', N'Image', N'Images/Material/magnetbentuk.png', N'Bahan pembelajaran ini memperkenalkan pelbagai bentuk magnet seperti magnet ladam, magnet bar dan magnet silinder serta kegunaannya dalam kehidupan harian.', N'2025-01-04', N'Approved', N'2025-03-04', N'BM'),
    (N'M003', N'ST313', N'U022', N'Blood Circulatory System Video Lesson', N'Video', N'Images/Material/circulatory_system.mp4', N'This video explains the functions of the heart, blood vessels and blood circulation throughout the human body using simple animations and examples.', N'2025-09-18', N'Pending', NULL, N'EN'),
    (N'M004', N'ST333', N'U022', N'Video Animasi Kitaran Air', N'Video', N'Images/Material/water_cycle.mp4', N'Video ini menerangkan proses kitaran air termasuk penyejatan, pemeluwapan, hujan dan pengumpulan air dalam alam sekitar.', N'2025-01-10', N'Approved', N'2025-10-20', N'BM'),
    (N'M005', N'ST341', N'U022', N'Moon Phases Interactive Slides', N'PPTX', N'Images/Material/moon_phases.pptx', N'This interactive presentation helps students understand the different phases of the moon and how the moon''s appearance changes throughout the month.', N'2026-01-03', N'Approved', N'2026-03-20', N'EN'),
    (N'M006', N'ST311', N'U022', N'Rajah Sistem Rangka Manusia', N'Image', N'Images/Material/skeletal_system.png', N'Rajah berlabel ini menunjukkan struktur utama sistem rangka manusia dan fungsi setiap tulang dalam menyokong pergerakan badan.', N'2026-01-01', N'Rejected', N'2026-01-01', N'BM'),
    (N'M007', N'ST351', N'U023', N'How Pulleys Work', N'Video', N'Images/Material/pulley_demo.mp4', N'This demonstration video explains how pulleys reduce the amount of force needed to lift heavy objects through practical examples.', N'2026-06-16', N'Pending', NULL, N'EN'),
    (N'M008', N'ST153', N'U024', N'Why Block Shapes Matter', N'PPTX', N'Images/Material/block_shapes_notes.pptx', N'This material explains how different block shapes influence the stability, strength and balance of structures. Students will learn how shape selection affects the design and construction of buildings and other everyday structures.', N'2026-01-20', N'Approved', N'2026-02-02', N'EN'),
    (N'M009', N'ST132', N'U024', N'Aplikasi Bahan Penyerap Air Dalam Kehidupan Harian', N'PPTX', N'Images/Material/absorbent_materials.pptx', N'Pembentangan ini menunjukkan penggunaan bahan penyerap air dalam produk harian seperti tisu, span dan lampin pakai buang.', N'2026-01-18', N'Approved', N'2026-01-19', N'EN'),
    (N'M010', N'ST123', N'U023', N'Magnet Experiment Demonstration', N'Video', N'Images/Material/magnet_demo.mp4', N'Students will observe attraction and repulsion forces between magnets through simple experiments and guided observations.', N'2025-06-12', N'Rejected', N'2025-12-12', N'EN'),
    (N'M011', N'ST113', N'U022', N'Using Human Senses in Daily Life', N'Video', N'Images/Material/human_senses_video.mp4', N'This video demonstrates how human senses are used in everyday activities such as crossing roads, identifying food and recognizing sounds.', N'2026-12-20', N'Approved', N'2026-01-01', N'EN'),
    (N'M012', N'ST312', N'U024', N'Jenis-Jenis Sendi Manusia', N'Image', N'Images/Material/joints.png', N'Bahan pembelajaran ini menerangkan pelbagai jenis sendi manusia seperti sendi engsel, sendi bebola dan soket serta fungsinya dalam pergerakan badan.', N'2025-09-07', N'Rejected', N'2025-12-09', N'BM');
GO

PRINT N'Inserting Forum (17 rows)...';
INSERT INTO dbo.[Forum] ([forumId], [createdBy], [title], [message], [discussionType], [createdAt])
VALUES
    (N'F001', N'U002', N'Can someone explain how gears work in a super simple way?', N'I am trying to answer the second quiz in Unit 3 but would like to see some examples.', N'Public', N'2026-01-21 16:45:00'),
    (N'F002', N'U003', N'Litmus paper not working', N'I tried testing acidity using litmus paper, but it does not change colour. Why?', N'Public', N'2026-01-28 14:20:00'),
    (N'F003', N'U004', N'Why does ice float on water?', NULL, N'Private', N'2026-02-03 19:00:00'),
    (N'F004', N'U005', N'How to edit time on study plan?', NULL, N'Public', N'2026-02-16 20:30:00'),
    (N'F005', N'U006', N'Is Unit 1 taught a lot in school?', NULL, N'Public', N'2026-03-05 13:05:00'),
    (N'F006', N'U005', N'Check-In', N'Testing first forum post.', N'Private', N'2026-06-13 15:40:00'),
    (N'F007', N'U004', N'Request to extend study plan deadline', N'Mom, I can''t finish this quiz by tonight I have football. Can you extend the deadline on the study plan.', N'Private', N'2026-06-14 17:45:00'),
    (N'F008', N'U004', N'Difference between series and parallel circuits.', NULL, N'Public', N'2026-06-01 11:10:00'),
    (N'F009', N'U007', N'New item in study plan added for next week.', NULL, N'Private', N'2026-06-02 19:00:00'),
    (N'F010', N'U002', N'How to unlock all badges?', NULL, N'Public', N'2026-06-02 08:30:00'),
    (N'F011', N'U011', N'How to score high in Beginner quiz?', N'I want to complete all Beginner badges.', N'Public', N'2026-06-05 17:20:00'),
    (N'F012', N'U014', N'I do not understand matter topic', N'Can someone explain solid, liquid and gas?', N'Public', N'2026-05-25 13:45:00'),
    (N'F013', N'U016', N'Tips for remembering science facts', N'I use flashcards. What about others?', N'Public', N'2026-01-06 08:55:00'),
    (N'F014', N'U017', N'Live session helped me', N'The teacher explained forces clearly.', N'Public', N'2026-06-10 10:30:00'),
    (N'F015', N'U015', N'I am back after a long break', N'Which lesson should I continue first?', N'Public', N'2026-06-14 07:40:00'),
    (N'F016', N'U005', N'How do I use the learning recommendation', N'I want to know how to support my child after looking at their weak topics.', N'Public', N'2026-06-13 08:50:00'),
    (N'F017', N'U006', N'How can I help my child start on this app?', N'My child and I are using this platform for the first time. How should we start?', N'Public', N'2026-06-15 10:15:00');
GO

PRINT N'Inserting ForumChat (5 rows)...';
INSERT INTO dbo.[ForumChat] ([forumChatId], [forumId], [senderUserId], [message], [createdAt])
VALUES
    (N'FC001', N'F013', N'U016', N'I use flashcards too. You should write short notes after each lesson to create them immediately.', N'2026-01-06 11:33:44'),
    (N'FC002', N'F013', N'U012', N'Mind maps make it fun because you can draw anything on it.', N'2026-06-06 10:22:00'),
    (N'FC003', N'F006', N'U017', N'Hey mom.', N'2026-06-13 16:30:00'),
    (N'FC004', N'F015', N'U008', N'List all lessons you are unfamiliar with right now and go from the earliest to latest lesson. Hope this helps!', N'2026-06-14 09:15:00'),
    (N'FC005', N'F007', N'U005', N'Sure but you only get one ice cream not two.', N'2026-06-14 19:34:00');
GO

PRINT N'Inserting ForumTag (14 rows)...';
INSERT INTO dbo.[ForumTag] ([forumTagId], [forumId], [tagId])
VALUES
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
GO

PRINT N'Inserting ForumLike (10 rows)...';
INSERT INTO dbo.[ForumLike] ([likeId], [forumId], [senderUserId], [createdAt])
VALUES
    (N'LIKE001', N'F001', N'U003', N'2026-01-21 18:05:00'),
    (N'LIKE002', N'F001', N'U008', N'2026-01-21 18:20:00'),
    (N'LIKE003', N'F002', N'U012', N'2026-01-29 09:30:00'),
    (N'LIKE004', N'F004', N'U006', N'2026-02-18 09:00:00'),
    (N'LIKE005', N'F005', N'U005', N'2026-03-05 16:00:00'),
    (N'LIKE006', N'F010', N'U011', N'2026-06-02 09:15:00'),
    (N'LIKE007', N'F012', N'U008', N'2026-05-25 15:30:00'),
    (N'LIKE008', N'F013', N'U012', N'2026-06-06 10:25:00'),
    (N'LIKE009', N'F013', N'U017', N'2026-06-06 10:40:00'),
    (N'LIKE010', N'F014', N'U016', N'2026-06-13 16:35:00');
GO
select * from question;
PRINT N'Inserting Question (99 rows)...';
INSERT INTO dbo.[Question] ([questionId], [quizId], [subtopicId], [createdByUserId], [questionTextEN], [questionTextBM], [questionType], [questionImageUrl], [optionA_EN], [optionA_BM], [optionB_EN], [optionB_BM], [optionC_EN], [optionC_BM], [optionD_EN], [optionD_BM], [correctAnswer], [correctExplanationEN], [correctExplanationBM], [wrongExplanationEN], [wrongExplanationBM], [difficulty], [status], [createdAt], [reviewedDate])
VALUES
    (N'QST001', N'Q001', N'ST111', N'U022', N'Which sense helps us hear sounds?', N'Deria manakah yang membantu kita mendengar bunyi?', N'MCQ', N'Images/Question/human_senses.jpg', N'Sight', N'Penglihatan', N'Hearing', N'Pendengaran', N'Taste', N'Rasa', N'Smell', N'Bau', N'B', N'Correct! The sense of hearing allows us to hear sounds such as music, voices and alarms through our ears.', N'Betul! Deria pendengaran membolehkan kita mendengar bunyi seperti muzik, suara dan loceng menggunakan telinga.', N'Incorrect. Sight is used for seeing, taste is used for identifying flavours and smell is used for detecting scents.', N'Incorrect. Sight is used for seeing, taste is used for identifying flavours and smell is used for detecting scents.', N'Easy', N'Approved', N'2026-01-02 10:00:00', N'2026-01-07 10:00:00'),
    (N'QST002', N'Q001', N'ST111', N'U022', N'Select ALL organs that are part of the five human senses.', N'Pilih SEMUA organ yang merupakan sebahagian daripada lima deria manusia.', N'Multiselect', NULL, N'Reading a book', N'Membaca buku', N'Watching television', N'Menonton televisyen', N'Smelling a flower', N'Menghidu bunga', N'Identifying traffic lights', N'Mengenal lampu isyarat', N'A,B,D', N'Reading, watching television and identifying traffic lights all require our eyes.', N'Membaca, menonton televisyen dan mengenal lampu isyarat memerlukan penggunaan mata.', N'hink about which activities require you to see objects or colours.', N'Fikirkan aktiviti yang memerlukan kita melihat objek atau warna.', N'Medium', N'Approved', N'2026-01-02 10:00:00', N'2026-01-07 10:00:00'),
    (N'QST003', N'Q001', N'ST111', N'U022', N'Complete the sentence by dragging the correct answer.

We use our _____ to taste food.', N'Lengkapkan ayat dengan menyeret jawapan yang betul.

Kita menggunakan _____ untuk merasa makanan.', N'DragDrop', NULL, N'Tongue', N'Lidah', N'Ear', N'Telinga', NULL, NULL, NULL, NULL, N'Tongue,Lidah', N'The tongue contains taste buds that help us detect different tastes such as sweet, sour, salty and bitter.', N'Lidah mempunyai tunas rasa yang membantu kita mengesan pelbagai rasa seperti manis, masam, masin dan pahit', N'Food is tasted using the tongue, not the ears.', N'Makanan dirasa menggunakan lidah, bukan telinga.', N'Easy', N'Approved', N'2026-01-02 10:00:00', N'2026-01-07 10:00:00'),
    (N'QST004', N'Q003', N'ST113', N'U022', N'Which sense do we use to know that soup is hot before drinking it?', N'Deria manakah yang kita gunakan untuk mengetahui sup itu panas sebelum meminumnya?', N'MCQ', NULL, N'Touch', N'Sentuhan', N'Hearing', N'Pendengaran', N'Smell', N'Bau', N'Taste', N'Rasa', N'A', N'We use the sense of touch through our skin to feel whether an object is hot or cold', N'Kita menggunakan deria sentuhan melalui kulit untuk merasai sama ada sesuatu objek panas atau sejuk.', N'Only the sense of touch helps us feel temperature.', N'Hanya deria sentuhan membantu kita merasai suhu sesuatu objek.', N'Easy', N'Approved', N'2026-01-02 13:20:00', N'2026-01-07 10:00:00'),
    (N'QST005', N'Q003', N'ST113', N'U022', N'We use our ears to hear a school bell ringing.', N'Kita menggunakan telinga untuk mendengar loceng sekolah berbunyi.', N'TrueFalse', NULL, N'TRUE', N'BETUL', N'FALSE', N'SALAH', NULL, NULL, NULL, NULL, N'A', N'The ears help us hear different sounds, including bells, music and voices.', N'Telinga membantu kita mendengar pelbagai bunyi termasuk loceng, muzik dan suara.', N'Hearing sounds is the function of our ears.', N'Mendengar bunyi ialah fungsi telinga.', N'Easy', N'Approved', N'2026-01-02 13:20:00', N'2026-01-07 10:00:00'),
    (N'QST006', N'Q003', N'ST113', N'U022', N'Select ALL situations that use the sense of smell.', N'Pilih SEMUA situasi yang menggunakan deria bau.', N'Multiselect', NULL, N'Smelling fresh flowers', N'Menghidu bunga segar', N'Detecting spoiled food', N'Mengenal pasti makanan yang telah rosak', N'Reading a storybook', N'Membaca buku cerita', N'Smelling perfume', N'Menghidu minyak wangi', N'A,B,D', N'Our nose helps us detect pleasant and unpleasant smells around us.', N'Hidung membantu kita mengesan bau yang wangi atau busuk di sekeliling kita.', N'Choose only the activities that require smelling.', N'Pilih hanya aktiviti yang memerlukan deria bau.', N'Medium', N'Approved', N'2026-01-02 13:20:00', N'2026-01-07 10:00:00'),
    (N'QST007', N'Q005', N'ST121', N'U022', NULL, N'Apakah fungsi utama magnet?', N'MCQ', NULL, NULL, N'Menyerap air', NULL, N'Menarik objek tertentu', NULL, N'Menghasilkan cahaya', NULL, N'Menyimpan tenaga', N'B', NULL, N'Magnet digunakan untuk menarik bahan tertentu seperti besi dan keluli. Oleh sebab itu, magnet banyak digunakan dalam kehidupan harian seperti pada peti sejuk dan kompas.', NULL, N'Salah. Magnet tidak digunakan untuk menyerap air, menghasilkan cahaya atau menyimpan tenaga. Fungsi utamanya adalah menarik bahan magnetik seperti besi.', N'Easy', N'Approved', N'2026-01-03 20:01:21', N'2026-01-05 12:01:21'),
    (N'QST008', N'Q005', N'ST121', N'U022', NULL, N'Antara berikut, yang manakah boleh ditarik oleh magnet?', N'MCQ', NULL, NULL, N'Sudu plastik', NULL, N'Paku besi', NULL, N'Pemadam', NULL, N'Kertas', N'B', NULL, N'Paku besi diperbuat daripada besi yang merupakan bahan magnetik dan boleh ditarik oleh magnet.', NULL, N'Plastik, pemadam dan kertas bukan bahan magnetik dan tidak akan ditarik oleh magnet.', N'Easy', N'Approved', N'2026-01-03 20:01:21', N'2026-01-05 12:01:21'),
    (N'QST009', N'Q005', N'ST121', N'U022', NULL, N'Kompas menggunakan magnet untuk membantu kita...', N'MCQ', N'Images/Question/compass.jpg', NULL, N'Mengukur suhu', NULL, N'Mengetahui masa', NULL, N'Menentukan arah', NULL, N'Mengira nombor', N'C', NULL, N'Jarum kompas mengandungi magnet yang sentiasa menunjuk ke arah utara dan membantu manusia menentukan arah.', NULL, N'Kompas tidak digunakan untuk mengukur suhu, mengetahui masa atau membuat pengiraan.', N'Easy', N'Approved', N'2026-01-03 20:01:21', N'2026-01-05 12:01:21'),
    (N'QST010', N'Q005', N'ST121', N'U022', NULL, N'Magnet boleh menarik semua jenis logam.', N'TrueFalse', NULL, NULL, N'Betul', NULL, N'Salah', NULL, NULL, NULL, NULL, N'B', NULL, N'Tidak semua logam boleh ditarik oleh magnet. Contohnya, besi boleh ditarik magnet tetapi aluminium dan tembaga tidak.', NULL, N'Ramai menganggap semua logam boleh ditarik magnet, tetapi hanya logam tertentu seperti besi dan keluli yang mempunyai sifat magnetik.', N'Medium', N'Approved', N'2026-01-03 20:01:21', N'2026-01-05 12:01:21'),
    (N'QST011', N'Q005', N'ST121', N'U022', NULL, N'Ali terjatuhkan beberapa paku besi ke dalam pasir. Apakah alat yang paling sesuai digunakan untuk mengutip paku tersebut?', N'MCQ', NULL, NULL, N'Pembaris', NULL, N'Magnet', NULL, N'Sudu', NULL, N'Penyapu', N'B', NULL, N'Magnet boleh menarik paku besi dengan mudah walaupun bercampur dengan pasir.', NULL, N'Pembaris, sudu dan penyapu mungkin dapat mengalihkan pasir tetapi tidak dapat menarik paku besi dengan berkesan.', N'Hard', N'Approved', N'2026-01-03 20:01:21', N'2026-01-05 12:01:21'),
    (N'QST012', N'Q007', N'ST123', N'U024', N'What happens when two different magnetic poles are placed close together?', N'Apakah yang berlaku apabila dua kutub magnet yang berlainan didekatkan?', N'MCQ', NULL, N'They attract each other', N'Mereka saling menarik', N'They repel each other', N'Mereka saling menolak', N'They disappear', N'Mereka hilang', N'They become weaker', N'Mereka menjadi lebih lemah', N'A', N'Different magnetic poles (North and South) attract each other.', N'Kutub magnet yang berlainan (Utara dan Selatan) akan saling menarik.', N'Remember that unlike poles attract while like poles repel.', N'Ingat bahawa kutub berlainan menarik manakala kutub yang sama menolak.', N'Easy', N'Approved', N'2026-01-03 21:31:21', N'2026-01-09 13:21:21'),
    (N'QST013', N'Q007', N'ST123', N'U024', N'Two North poles repel each other.', N'Dua kutub Utara akan saling menolak.', N'TrueFalse', NULL, N'TRUE', N'BETUL', N'FALSE', N'SALAH', NULL, NULL, NULL, NULL, N'A', N'Magnets with the same poles repel each other.', N'Magnet yang mempunyai kutub yang sama akan saling menolak.', N'Magnets only attract when their poles are different.', N'Magnet hanya akan menarik apabila kutubnya berlainan.', N'Easy', N'Approved', N'2026-01-03 21:31:21', N'2026-01-09 13:21:21'),
    (N'QST014', N'Q007', N'ST123', N'U024', N'Select ALL pairs that will attract each other.', N'Pilih SEMUA pasangan kutub magnet yang akan saling menarik.', N'Multiselect', NULL, N'North – South', N'Utara – Selatan', N'South – North', N'Selatan – Utara', N'North – North', N'Utara – Utara', N'South – South', N'Selatan – Selatan', N'A,B', N'Only opposite magnetic poles attract each other.', N'Hanya kutub magnet yang berlainan akan saling menarik.', N'Remember that the same poles repel each other.', N'Ingat bahawa kutub yang sama akan saling menolak', N'Medium', N'Approved', N'2026-01-03 21:31:21', N'2026-01-09 13:21:21'),
    (N'QST015', N'Q007', N'ST123', N'U024', N'Complete the sentence by dragging the correct answer.

Magnets with the same poles will ______ each other.', N'Lengkapkan ayat dengan menyeret jawapan yang betul.

Magnet yang mempunyai kutub yang sama akan saling ______.', N'DragDrop', NULL, N'Repel', N'Menolak', N'Attract', N'Menarik', NULL, NULL, NULL, NULL, N'Repel,Menolak', N'Magnets with the same poles cannot stick together because they repel each other.', N'Magnet yang mempunyai kutub yang sama tidak boleh melekat kerana mereka saling menolak.', N'The same poles always repel.', N'Kutub yang sama sentiasa menolak.', N'Medium', N'Approved', N'2026-01-03 21:31:21', N'2026-01-09 13:21:21'),
    (N'QST016', N'Q007', N'ST123', N'U024', N'Ali places the North pole of a magnet near another hidden magnet. The two magnets repel each other. Which statement is correct?', N'Ali meletakkan kutub Utara sebuah magnet berhampiran satu lagi magnet yang tersembunyi. Kedua-dua magnet saling menolak. Pernyataan manakah yang betul?', N'MCQ', NULL, N'The hidden magnet''s nearby pole is North', N'Kutub magnet yang berhampiran ialah Utara', N'The hidden magnet''s nearby pole is South', N'Kutub magnet yang berhampiran ialah Selatan', N'The hidden magnet has no poles', N'Magnet itu tidak mempunyai kutub', N'The hidden object is not a magnet', N'Objek itu bukan magnet', N'A', N'Since the magnets repel each other and Ali used a North pole, the nearby pole of the hidden magnet must also be North. Magnets with the same poles repel each other.', N'Oleh sebab kedua-dua magnet saling menolak dan Ali menggunakan kutub Utara, maka kutub magnet yang berhampiran mestilah juga kutub Utara. Magnet yang mempunyai kutub yang sama akan saling menolak.', N'Think about the relationship between magnetic poles. Repulsion only happens when the poles are the same.', N'Fikirkan hubungan antara kutub magnet. Penolakan hanya berlaku apabila kedua-dua kutub adalah sama.', N'Hard', N'Approved', N'2026-01-03 21:31:21', N'2026-01-09 13:21:21'),
    (N'QST017', N'Q006', N'ST122', N'U009', N'Which of the following is a type of magnet?', N'Antara berikut, yang manakah ialah jenis magnet?', N'MCQ', N'Images/Question/magnet.png', N'Bar magnet', N'Magnet batang', N'Wooden stick', N'Batang kayu', N'Plastic ruler', N'Pembaris plastik', N'Paper clip', N'Klip kertas', N'A', N'A bar magnet is one of the common shapes of magnets used in science.', N'Magnet batang ialah salah satu bentuk magnet yang biasa digunakan dalam sains.', N'Only objects designed as magnets are considered magnet shapes.', N'Hanya objek yang direka sebagai magnet dianggap sebagai bentuk magnet.', N'Easy', N'Approved', N'2026-01-03 22:41:21', N'2026-01-10 14:21:21'),
    (N'QST018', N'Q006', N'ST122', N'U009', N'A horseshoe magnet has two ends that are close together.', N'Magnet ladam mempunyai dua hujung yang berdekatan antara satu sama lain.', N'TrueFalse', NULL, N'TRUE', N'Betul', N'FALSE', N'Salah', NULL, NULL, NULL, NULL, N'A', N'A horseshoe magnet is bent into a U-shape, bringing its two poles close together.', N'Magnet ladam dibengkokkan menjadi bentuk U, menyebabkan kedua-dua kutubnya berada berdekatan.', N'Observe the shape of a horseshoe magnet carefully.', N'Perhatikan bentuk magnet ladam dengan teliti.', N'Easy', N'Approved', N'2026-01-03 22:41:21', N'2026-01-10 14:21:21'),
    (N'QST019', N'Q006', N'ST122', N'U009', N'Select ALL objects that are shapes of magnets.', N'Pilih SEMUA yang merupakan bentuk magnet.', N'Multiselect', NULL, N'Ring magnet', N'Magnet cincin', N'Bar magnet', N'Magnet batang', N'Horseshoe magnet', N'Magnet ladam', N'Spoon', N'Sudu', N'A,B,C', N'Ring magnets, bar magnets and horseshoe magnets are common types of magnets.', N'Magnet cincin, magnet batang dan magnet ladam ialah bentuk magnet yang biasa digunakan.', N'Choose only objects that are actual magnet shapes.', N'Pilih hanya objek yang merupakan bentuk magnet.', N'Medium', N'Approved', N'2026-01-03 22:41:21', N'2026-01-10 14:21:21'),
    (N'QST020', N'Q006', N'ST122', N'U009', N'A student wants to pick up many paper clips quickly. Which magnet shape is MOST suitable?', N'Seorang murid ingin mengangkat banyak klip kertas dengan cepat. Bentuk magnet manakah PALING sesuai digunakan?', N'MCQ', NULL, N'Horseshoe magnet', N'Magnet ladam', N'Plastic stick', N'Batang plastik', N'Wooden ruler', N'Pembaris kayu', N'Rubber eraser', N'Pemadam getah', N'A', N'A horseshoe magnet has its two poles close together, producing a stronger magnetic effect at the ends, making it suitable for picking up many metal objects.', N'Magnet ladam mempunyai kedua-dua kutub yang berdekatan, menghasilkan daya tarikan magnet yang lebih kuat pada hujungnya dan sesuai untuk mengangkat banyak objek logam.', N'Consider which object is actually a magnet and how its shape affects its magnetic strength.', N'Fikirkan objek yang benar-benar merupakan magnet dan bagaimana bentuknya mempengaruhi kekuatan daya tarikannya.', N'Hard', N'Approved', N'2026-01-03 22:41:21', N'2026-01-10 14:21:21'),
    (N'QST021', N'Q009', N'ST132', N'U023', N'Why is a towel made from water absorbent material?', N'Mengapakah tuala diperbuat daripada bahan yang menyerap air?', N'MCQ', NULL, N'To absorb water', N'Untuk menyerap air', N'To float on water', N'Untuk terapung di atas air', N'To produce heat', N'Untuk menghasilkan haba', N'To become waterproof', N'Untuk menjadi kalis air', N'A', N'A towel is made from water absorbent material so it can soak up water and dry our body.', N'Tuala diperbuat daripada bahan yang menyerap air supaya dapat menyerap air dan mengeringkan badan kita.', N'Think about the main purpose of using a towel after bathing.', N'Fikirkan tujuan utama menggunakan tuala selepas mandi.', N'Easy', N'Approved', N'2026-01-04 11:00:21', N'2026-01-13 14:41:21'),
    (N'QST022', N'Q009', N'ST132', N'U023', N'Farah accidentally spilled water on the dining table. Which TWO items would BEST help her clean it up?', N'Farah tertumpahkan air di atas meja makan. Pilih DUA barangan yang PALING sesuai untuk membersihkannya.', N'Multiselect', NULL, N'Tissue', N'Tisu', N'Sponge', N'Span', N'Plastic sheet', N'Kepingan plastik', N'Glass plate', N'Pinggan kaca', N'A,B', N'Tissues and sponges absorb water quickly, making them suitable for cleaning spills', N'Tisu dan span menyerap air dengan cepat, menjadikannya sesuai untuk membersihkan tumpahan air.', N'Choose the items that can absorb water effectively.', N'Pilih barangan yang boleh menyerap air dengan berkesan.', N'Medium', N'Approved', N'2026-01-04 11:00:21', N'2026-01-13 14:41:21'),
    (N'QST023', N'Q009', N'ST132', N'U023', N'Complete the sentence by dragging the correct answer.

A raincoat should be made from a _____ material.', N'Lengkapkan ayat dengan menyeret jawapan yang betul.

Baju hujan perlu diperbuat daripada bahan yang _____.', N'DragDrop', NULL, N'Waterproof', N'Kalis air', N'Water absorbent', N'Menyerap air', NULL, NULL, NULL, NULL, N'Waterproof,Kalis air', N'Waterproof materials prevent water from soaking through, keeping the wearer dry.', N'Bahan kalis air menghalang air daripada meresap, sekali gus memastikan pemakainya kekal kering.', N'Think about the main function of a raincoat.', N'Fikirkan fungsi utama baju hujan.', N'Medium', N'Approved', N'2026-01-04 11:00:21', N'2026-01-13 14:41:21'),
    (N'QST024', N'Q009', N'ST132', N'U023', N'A camping group wants to make a picnic mat that can be used on wet grass. Which material would be the MOST suitable?', N'Sekumpulan murid ingin menghasilkan tikar berkelah yang boleh digunakan di atas rumput yang basah. Bahan manakah yang PALING sesuai digunakan?', N'MCQ', NULL, N'Cottin fabric', N'Kain kapas', N'Tissue paper', N'Kertas tisu', N'Waterproof plastic', N'Plastik kalis air', N'Sponge', N'Span', N'C', N'Waterproof plastic prevents water from soaking through, keeping the picnic mat dry and comfortable to use.', N'Plastik kalis air menghalang air daripada meresap, menjadikan tikar kekal kering dan selesa digunakan.', N'Choose a material that prevents water from entering instead of absorbing it.', N'Pilih bahan yang menghalang air daripada meresap, bukan bahan yang menyerap air.', N'Hard', N'Approved', N'2026-01-04 11:00:21', N'2026-01-13 14:41:21'),
    (N'QST025', N'Q010', N'ST141', N'U009', N'Which landform is usually covered with sand and found beside the sea?', N'Bentuk muka bumi manakah biasanya dipenuhi pasir dan terletak di tepi laut?', N'MCQ', NULL, N'Beach', N'Pantai', N'Hill', N'Bukit', N'Cave', N'Gua', N'Waterfall', N'Air Terjun', N'A', N'A beach is a landform found along the seashore and is usually covered with sand.', N'Pantai ialah bentuk muka bumi yang terletak di persisiran laut dan biasanya dipenuhi pasir.', N'Think about the landform that is located next to the sea.', N'Fikirkan bentuk muka bumi yang berada di tepi laut.', N'Easy', N'Approved', N'2026-01-04 13:00:21', N'2026-01-20 17:41:21'),
    (N'QST026', N'Q010', N'ST141', N'U009', N'A waterfall is formed when water flows down from a high place.', N'Air terjun terbentuk apabila air mengalir dari tempat yang tinggi.', N'TrueFalse', NULL, N'TRUE', N'BETUL', N'FALSE', N'SALAH', NULL, NULL, NULL, NULL, N'A', N'A waterfall is formed when water flows from a higher level to a lower level.', N'Air terjun terbentuk apabila air mengalir dari kawasan yang lebih tinggi ke kawasan yang lebih rendah.', N'Remember that waterfalls always involve water flowing from a higher place.', N'Ingat bahawa air terjun melibatkan air yang mengalir dari tempat yang tinggi.', N'Easy', N'Approved', N'2026-01-04 13:00:21', N'2026-01-20 17:41:21'),
    (N'QST027', N'Q010', N'ST141', N'U009', N'A village wants to build a recreation area where visitors can enjoy cool weather and beautiful scenery. Which landform is the BEST choice?', N'Sebuah kampung ingin membina kawasan rekreasi supaya pengunjung dapat menikmati udara yang sejuk dan pemandangan yang indah. Bentuk muka bumi manakah PALING sesuai?', N'MCQ', NULL, N'Hill', N'Bukit', N'Beach', N'Pantai', N'Swamp', N'Paya', N'Cave', N'Gua', N'A', N'Hills usually have cooler temperatures and beautiful views, making them suitable for recreational activities.', N'Bukit biasanya mempunyai suhu yang lebih sejuk dan pemandangan yang indah, menjadikannya sesuai untuk aktiviti rekreasi.', N'Think about which landform provides cool weather and attractive scenery for visitors.', N'Fikirkan bentuk muka bumi yang menawarkan udara sejuk dan pemandangan menarik kepada pengunjung.', N'Hard', N'Approved', N'2026-01-04 13:00:21', N'2026-01-20 17:41:21'),
    (N'QST028', N'Q014', N'ST153', N'U023', N'Which block shape is MOST suitable for stacking boxes in a warehouse?', N'Bentuk blok manakah PALING sesuai untuk menyusun kotak di dalam gudang?', N'MCQ', NULL, N'Cube', N'Kubus', N'Sphere', N'Sfera', N'Cone', N'Kon', N'Cylinder', N'Silinder', N'A', N'A cube has flat surfaces, making it stable and easy to stack.', N'Kubus mempunyai permukaan yang rata, menjadikannya stabil dan mudah disusun.', N'Think about which shape can be stacked without rolling.', N'Fikirkan bentuk yang boleh disusun tanpa bergolek.', N'Easy', N'Approved', N'2026-01-04 17:00:00', N'2026-01-19 17:41:21'),
    (N'QST029', N'Q014', N'ST153', N'U023', N'A shop owner wants to display canned drinks neatly on a shelf. Why are the cans stored upright?', N'Seorang pemilik kedai ingin menyusun tin minuman dengan kemas di atas rak. Mengapakah tin minuman disusun secara tegak?', N'MCQ', NULL, N'The flat base keeps them stable', N'Tapak yang rata menjadikannya stabil', N'They become lighter', N'Ia menjadi lebih ringan', N'They become waterproof', N'Ia menjadi kalis air', N'They change into cubes', N'Ia bertukar menjadi kubus', N'A', N'Although a cylinder can roll, placing it upright allows its flat base to keep it stable.', N'Walaupun silinder boleh bergolek, meletakkannya secara tegak menggunakan tapaknya yang rata untuk memastikan ia stabil.', N'Think about how the shape helps the object stay balanced.', N'Fikirkan bagaimana bentuk membantu objek kekal seimbang.', N'Medium', N'Approved', N'2026-01-04 17:00:00', N'2026-01-19 17:41:21'),
    (N'QST030', N'Q014', N'ST153', N'U023', N'A company is designing a new package for fragile glass bottles. Which block shape would be the BEST choice to protect the bottles during transportation?', N'Sebuah syarikat ingin mereka bentuk kotak pembungkusan untuk botol kaca yang mudah pecah. Bentuk blok manakah PALING sesuai digunakan?', N'MCQ', NULL, N'Sphere', N'Sfera', N'Cone', N'Kon', N'Cube', N'Kubus', N'Hemispere', N'Hemisfera', N'C', N'A cube-shaped box has flat sides that make it easy to stack, store and protect fragile items during transportation.', N'Kotak berbentuk kubus mempunyai sisi yang rata, menjadikannya mudah disusun, disimpan dan melindungi barangan yang mudah pecah semasa penghantaran.', N'Consider which shape provides stability and protects fragile objects during transport.', N'Fikirkan bentuk yang memberikan kestabilan dan melindungi barangan yang mudah pecah semasa pengangkutan.', N'Hard', N'Approved', N'2026-01-04 17:00:00', N'2026-01-19 17:41:21'),
    (N'QST031', N'Q015', N'ST211', N'U024', N'Which type of teeth is mainly used for cutting food?', N'Gigi jenis manakah digunakan terutamanya untuk memotong makanan?', N'MCQ', N'teeth.png', N'Incisors', N'Gigi kacip', N'Canines', N'Gigi taring', N'Premolars', N'Gigi geraham kecil', N'Molars', N'Gigi geraham', N'A', N'Incisors are the front teeth. They have sharp edges that help us bite and cut food into smaller pieces before chewing.', N'Gigi kacip ialah gigi di bahagian hadapan mulut. Gigi ini mempunyai hujung yang tajam untuk menggigit dan memotong makanan kepada bahagian yang lebih kecil sebelum dikunyah.', N'Incisors are responsible for cutting food. Canines tear food, while premolars and molars crush and grind food.', N'Gigi kacip berfungsi untuk memotong makanan. Gigi taring mengoyakkan makanan, manakala gigi geraham kecil dan geraham menghancurkan serta mengunyah makanan.', N'Easy', N'Pending', N'2026-01-04 23:30:22', NULL),
    (N'QST032', N'Q015', N'ST211', N'U024', N'Brushing your teeth twice a day helps prevent tooth decay.', N'Memberus gigi dua kali sehari membantu mencegah kerosakan gigi.', N'TrueFalse', NULL, N'TRUE', N'BETUL', N'FALSE', N'SALAH', NULL, NULL, NULL, NULL, N'A', N'Brushing your teeth twice a day removes food particles and plaque, reducing the risk of tooth decay and keeping your teeth healthy.', N'Memberus gigi dua kali sehari membantu membuang sisa makanan dan plak, sekali gus mengurangkan risiko kerosakan gigi dan mengekalkan kesihatan gigi.', N'Brushing twice a day is recommended because it removes plaque before it damages the teeth and gums.', N'Memberus gigi dua kali sehari disarankan kerana ia membantu membuang plak sebelum merosakkan gigi dan gusi.', N'Easy', N'Pending', N'2026-01-04 23:30:22', NULL),
    (N'QST033', N'Q015', N'ST211', N'U024', N'Sarah often drinks sweet drinks before going to bed without brushing her teeth. After a few months, she starts having toothache. What is the MOST likely reason?', N'Sarah sering minum minuman manis sebelum tidur tanpa memberus gigi. Selepas beberapa bulan, dia mula mengalami sakit gigi. Apakah sebab yang PALING mungkin?', N'MCQ', NULL, N'Her teeth became longer', N'Giginya menjadi lebih panjang', N'Her teeth became longer', N'Giginya menjadi lebih panjang', N'Her teeth changed colour naturally', N'Warna giginya berubah secara semula jadi', N'Sugar remained on her teeth, allowing bacteria to damage them', N'Gula tertinggal pada gigi dan membolehkan bakteria merosakkan gigi', N'D', N'When sugary food or drinks remain on the teeth, bacteria feed on the sugar and produce acids. These acids slowly damage the tooth enamel, leading to tooth decay and toothache.', N'Apabila gula daripada makanan atau minuman tertinggal pada gigi, bakteria akan menggunakan gula tersebut dan menghasilkan asid. Asid ini akan menghakis enamel gigi secara perlahan-lahan, menyebabkan kerosakan gigi dan akhirnya sakit gigi.', N'Tooth decay is mainly caused by bacteria that produce acid from sugar left on the teeth. This is why brushing your teeth before sleeping is very important.', N'Kerosakan gigi berlaku apabila bakteria menghasilkan asid daripada gula yang tertinggal pada gigi. Oleh itu, memberus gigi sebelum tidur sangat penting untuk menjaga kesihatan gigi.', N'Hard', N'Pending', N'2026-01-04 23:30:22', NULL),
    (N'QST034', N'Q019', N'ST222', N'U022', N'Which object is most likely to float on water?', NULL, N'MCQ', NULL, N'Stone', NULL, N'Iron Nail', NULL, N'Wooden Block', NULL, N'Coin', NULL, N'C', N'A wooden block is usually less dense than water, allowing it to float on the surface.', NULL, N'Stones, iron nails and coins are generally denser than water and tend to sink.', NULL, N'Easy', N'Approved', N'2026-01-05 13:50:44', N'2026-01-06 13:40:04'),
    (N'QST035', N'Q019', N'ST222', N'U022', N'Sarah places a cork and a stone into water. What is most likely to happen?', NULL, N'MCQ', NULL, N'Both float', NULL, N'Both sink', NULL, N'Cork floats and stone sinks', NULL, N'Stone floats and cork sinks', NULL, N'C', N'Cork has a lower density than water, while stone has a higher density than water.', NULL, N'Different materials have different densities, so they may behave differently in water.', NULL, N'Medium', N'Approved', N'2026-01-05 13:50:44', N'2026-01-06 13:40:04'),
    (N'QST036', N'Q019', N'ST222', N'U022', N'Objects with a lower density than water usually float.', NULL, N'TrueFalse', NULL, N'TRUE', NULL, N'FALSE', NULL, NULL, NULL, NULL, NULL, N'A', N'If an object is less dense than water, it can stay on the surface and float.', NULL, N'Lower density is one of the main reasons why objects float in water.', NULL, N'Easy', N'Approved', N'2026-01-05 13:50:44', N'2026-01-06 13:40:04'),
    (N'QST037', N'Q019', N'ST222', N'U022', N'All heavy objects will sink in water.', NULL, N'TrueFalse', NULL, N'TRUE', NULL, N'FALSE', NULL, NULL, NULL, NULL, NULL, N'B', N'Some heavy objects, such as large ships, can float because their overall density is lower than water.', NULL, N'Weight alone does not determine whether an object floats or sinks. Density is also important.', NULL, N'Medium', N'Approved', N'2026-01-05 13:50:44', N'2026-01-06 13:40:04'),
    (N'QST038', N'Q019', N'ST222', N'U022', N'Which factors can affect an object''s density?', NULL, N'Multiselect', NULL, N'Mass', NULL, N'Volume', NULL, N'Material Type', NULL, N'Favourite Colour', NULL, N'A, B, C', N'Density depends on an object''s mass, volume and the material it is made from.', NULL, N'An object''s favourite colour or appearance does not affect its density.', NULL, N'Medium', N'Approved', N'2026-01-05 13:50:44', N'2026-01-06 13:40:04'),
    (N'QST039', N'Q019', N'ST222', N'U022', N'Objects with lower ______ than water usually float.

A wooden block will usually ______ on water.

A stone will usually ______ in water.', NULL, N'DragDrop', NULL, N'density', NULL, N'float', NULL, N'sink', NULL, N'colour', NULL, N'density,float,sink', N'Density affects whether objects float or sink. Wooden blocks usually float, while stones usually sink.', NULL, N'Colour does not determine whether an object floats or sinks.', NULL, N'Medium', N'Approved', N'2026-01-05 13:50:44', N'2026-01-06 13:40:04'),
    (N'QST040', N'Q019', N'ST222', N'U022', N'A large wooden boat floats on water while a small metal ball sinks. Why?', NULL, N'MCQ', N'Images/Question/boat_and_ball.jpg', N'The boat is lighter than the ball', NULL, N'The boat has a lower overall density than water', NULL, N'Metal objects always sink because they are metal', NULL, N'Boats contain magic air', NULL, N'B', N'The shape of the boat and the air inside it reduce its overall density, allowing it to float.', NULL, N'Floating depends on density, not simply size, weight or the type of material alone.', NULL, N'Hard', N'Approved', N'2026-01-05 13:50:44', N'2026-01-06 13:40:04'),
    (N'QST041', N'Q019', N'ST222', N'U022', N'Ali wants to design a toy boat that can float. Which material would be the best choice?', NULL, N'MCQ', NULL, N'Stone', NULL, N'Iron Block', NULL, N'Wood', NULL, N'Solid Steel', NULL, N'C', N'Wood generally has a lower density than water, making it a suitable material for floating objects.', NULL, N'Stone, iron and solid steel are usually denser than water and are more likely to sink.', NULL, N'Hard', N'Approved', N'2026-01-05 13:50:44', N'2026-01-06 13:40:04'),
    (N'QST042', N'Q024', N'ST241', N'U022', N'Which object is located at the centre of the Solar System?', N'Objek manakah yang berada di pusat Sistem Suria?', N'MCQ', NULL, N'Moon', N'Bulan', N'Sun', N'Matahari', N'Earth', N'Bumi', N'Mars', N'Marikh', N'B', N'The Sun is the centre of the Solar System. All eight planets revolve around the Sun because of its strong gravitational pull.', N'Matahari ialah pusat Sistem Suria. Kesemua lapan planet beredar mengelilingi Matahari kerana tarikan gravitinya yang kuat.', N'The planets and other objects in the Solar System orbit the Sun, making it the centre of the Solar System.', N'Planet dan objek lain dalam Sistem Suria mengelilingi Matahari, menjadikan Matahari sebagai pusat Sistem Suria.', N'Easy', N'Approved', N'2026-01-05 08:14:10', N'2026-01-07 21:14:15'),
    (N'QST043', N'Q024', N'ST241', N'U022', N'The Earth is one of the planets in the Solar System.', N'Bumi ialah salah satu planet dalam Sistem Suria.', N'TrueFalse', NULL, N'TRUE', N'BETUL', N'FALSE', N'SALAH', NULL, NULL, NULL, NULL, N'A', N'Earth is the third planet from the Sun and is the only known planet that supports life.', N'Bumi ialah planet ketiga dari Matahari dan merupakan satu-satunya planet yang diketahui dapat menyokong kehidupan.', N'Earth is one of the eight planets that orbit the Sun.', N'Bumi ialah salah satu daripada lapan planet yang mengelilingi Matahari.', N'Easy', N'Approved', N'2026-01-05 08:14:10', N'2026-01-07 21:14:15'),
    (N'QST044', N'Q024', N'ST241', N'U022', N'A group of students is building a model of the Solar System. Amir places the Earth at the centre and all the other planets around it. What should he do to make his model correct?', N'Sekumpulan murid sedang membina model Sistem Suria. Amir meletakkan Bumi di bahagian tengah dan semua planet lain mengelilinginya. Apakah yang perlu dilakukan untuk membetulkan model tersebut?', N'MCQ', NULL, N'Put the Moon at the centre', N'Letakkan Bulan di bahagian tengah', N'Move Mars to the centre', N'Letakkan Marikh di bahagian tengah', N'Leave the model as it is', N'Biarkan model seperti itu', N'Replace the Earth with the Sun at the centre', N'Gantikan Bumi dengan Matahari di bahagian tengah', N'D', N'The Sun is the centre of the Solar System. All the planets, including Earth, revolve around the Sun. Therefore, the Sun must be placed at the centre of the model.', N'Matahari ialah pusat Sistem Suria. Semua planet termasuk Bumi beredar mengelilingi Matahari. Oleh itu, Matahari mesti diletakkan di bahagian tengah model.', N'Only the Sun is located at the centre of the Solar System. The Earth and the other planets orbit the Sun, not the other way around.', N'Hanya Matahari berada di pusat Sistem Suria. Bumi dan planet-planet lain mengelilingi Matahari, bukan sebaliknya.', N'Hard', N'Approved', N'2026-01-05 08:14:10', N'2026-01-07 21:14:15'),
    (N'QST045', N'Q032', N'ST311', N'U022', NULL, N'Apakah fungsi utama sistem rangka manusia?', N'MCQ', N'Images/Question/human_skeleton.png', NULL, N'Menghasilkan makanan', NULL, N'Menyokong badan', NULL, N'Menghasilkan oksigen', NULL, N'Mencerna makanan', N'B', NULL, N'Sistem rangka memberikan bentuk kepada badan dan menyokong keseluruhan struktur tubuh manusia.', NULL, N'Sistem rangka tidak menghasilkan makanan, oksigen atau mencerna makanan. Fungsi utamanya adalah menyokong badan.', N'Easy', N'Rejected', N'2026-01-05 09:14:10', N'2026-01-09 10:14:10'),
    (N'QST046', N'Q032', N'ST311', N'U022', NULL, N'Tulang manakah yang melindungi otak?', N'MCQ', NULL, NULL, N'Femur', NULL, N'Rusuk', NULL, N'Tengkorak', NULL, N'Tulang belakang', N'C', NULL, N'Tengkorak melindungi otak daripada kecederaan dan hentakan.', NULL, N'Femur ialah tulang kaki, rusuk melindungi paru-paru dan jantung, manakala tulang belakang menyokong badan.', N'Easy', N'Rejected', N'2026-01-05 09:14:10', N'2026-01-09 10:14:10'),
    (N'QST047', N'Q032', N'ST311', N'U022', NULL, N'Pilih semua bahagian sistem rangka manusia.', N'Multiselect', NULL, NULL, N'Tengkorak', NULL, N'Tulang rusuk', NULL, N'Femur', NULL, N'Jantung', N'A, B, C', NULL, N'Tengkorak, tulang rusuk dan femur merupakan sebahagian daripada sistem rangka manusia.', NULL, N'Jantung ialah organ dalam sistem peredaran darah dan bukan sebahagian daripada sistem rangka.', N'Medium', N'Rejected', N'2026-01-05 09:14:10', N'2026-01-09 10:14:10'),
    (N'QST048', N'Q032', N'ST311', N'U022', NULL, N'______ melindungi otak.

Tulang ______ ialah tulang paling panjang dalam badan manusia.

Sistem rangka membantu ______ badan.', N'DragDrop', NULL, NULL, N'Femur', NULL, N'menyokong', NULL, N'Tengkorak', NULL, N'paru-paru', N'Tengkorak,Femur,menyokong', NULL, N'Tengkorak melindungi otak, femur ialah tulang paling panjang dan sistem rangka membantu menyokong badan.', NULL, N'Paru-paru bukan jawapan yang sesuai untuk melengkapkan ayat tersebut.', N'Medium', N'Rejected', N'2026-01-05 09:14:10', N'2026-01-09 10:14:10'),
    (N'QST049', N'Q032', N'ST311', N'U022', NULL, N'Mengapakah manusia sukar berdiri atau berjalan jika tidak mempunyai sistem rangka?', N'MCQ', NULL, NULL, N'Badan tidak mempunyai sokongan dan bentuk', NULL, N'Otak berhenti berfungsi', NULL, N'Darah tidak mengalir', NULL, N'Mata tidak dapat melihat', N'A', NULL, N'Sistem rangka memberikan bentuk dan sokongan kepada badan. Tanpanya, manusia tidak dapat berdiri atau bergerak dengan baik.', NULL, N'Sistem rangka tidak mengawal penglihatan, aliran darah atau fungsi otak secara langsung. Fungsi utamanya ialah menyokong badan dan membantu pergerakan.', N'Hard', N'Approved', N'2026-01-07 02:30:22', N'2026-01-19 09:30:22'),
    (N'QST050', N'Q043', N'ST342', N'U024', N'What is a constellation?', N'Apakah yang dimaksudkan dengan buruj?', N'MCQ', NULL, N'A planet that revolves around the Sun', N'Sebuah planet yang mengelilingi Matahari', N'A bright cloud in the sky', N'Awan terang di langit', N'A group of stars that forms a pattern', N'Sekumpulan bintang yang membentuk corak', N'A shooting star', N'Bintang jatuh', N'C', N'A constellation is a group of stars that appear to form a recognisable pattern when viewed from Earth.', N'Buruj ialah sekumpulan bintang yang kelihatan membentuk corak tertentu apabila dilihat dari Bumi.', N'Constellations are not planets or clouds. They are patterns formed by groups of stars.', N'Buruj bukan planet atau awan. Buruj ialah corak yang terbentuk daripada sekumpulan bintang.', N'Easy', N'Approved', N'2026-01-07 02:30:22', N'2026-01-19 09:30:22'),
    (N'QST051', N'Q043', N'ST342', N'U024', N'A camping group wants to find the north direction at night. Which constellation would MOST likely help them?', N'Sekumpulan murid sedang berkhemah dan ingin mencari arah utara pada waktu malam. Buruj manakah yang PALING sesuai membantu mereka?', N'MCQ', NULL, N'Ursa Major', N'Buruj Biduk', N'Orion', N'Buruj Belantik', N'Scorpius', N'Buruj Kala Jengking', N'Southern Cross', N'Buruj Pari', N'A', N'Ursa Major can be used to locate the North Star (Polaris), which helps determine the north direction.', N'Buruj Biduk boleh digunakan untuk mencari Bintang Utara (Polaris), yang membantu menentukan arah utara.', N'Different constellations have different uses. Ursa Major is commonly used to locate the north direction.', N'Setiap buruj mempunyai kegunaan yang berbeza. Buruj Biduk sering digunakan untuk menentukan arah utara.', N'Medium', N'Approved', N'2026-01-07 02:30:22', N'2026-01-19 09:30:22'),
    (N'QST052', N'Q043', N'ST342', N'U024', N'During a night exploration activity, Amin notices a group of stars forming a familiar pattern. His teacher explains that people have used this pattern for hundreds of years. Why are constellations still important today?', N'Semasa aktiviti penerokaan waktu malam, Amin melihat sekumpulan bintang yang membentuk corak tertentu. Gurunya menerangkan bahawa corak ini telah digunakan sejak ratusan tahun dahulu. Mengapakah buruj masih penting pada masa kini?', N'MCQ', NULL, N'They produce light for the Earth', N'Menghasilkan cahaya untuk Bumi', N'They control the weather', N'Mengawal cuaca', N'They change the seasons', N'Menukar musim', N'They help people study space and identify directions', N'Membantu manusia mengkaji angkasa dan menentukan arah', N'D', N'Constellations are useful for studying the night sky and have long been used for navigation. Today, they continue to help astronomers identify different regions of the sky.', N'Buruj digunakan untuk mengkaji langit malam dan telah lama membantu manusia menentukan arah. Pada masa kini, buruj juga membantu ahli astronomi mengenal pasti kawasan tertentu di langit.', N'Constellations do not produce light for Earth or control weather. Their importance lies in astronomy and navigation.', N'Buruj tidak menghasilkan cahaya untuk Bumi atau mengawal cuaca. Kepentingannya adalah dalam bidang astronomi dan penentuan arah.', N'Hard', N'Approved', N'2026-01-07 02:30:22', N'2026-01-19 09:30:22'),
    (N'QST053', N'Q046', N'ST353', N'U009', N'Which of the following is an example of a simple machine?', N'Antara berikut, yang manakah merupakan contoh mesin ringkas?', N'MCQ', NULL, N'Wheelbarrow', N'Kereta sorong', N'Scissors', N'Gunting', N'Pulley', N'Takal', N'Bicycle', N'Basikal', N'C', N'A pulley is one of the six types of simple machines. Scissors, bicycles and wheelbarrows are compound machines because they combine two or more simple machines.', N'Takal ialah salah satu daripada enam jenis mesin ringkas. Gunting, basikal dan kereta sorong ialah mesin kompleks kerana menggabungkan dua atau lebih mesin ringkas.', N'A simple machine performs work using a single basic mechanism. Objects made from several simple machines are compound machines.', N'Mesin ringkas melakukan kerja menggunakan satu mekanisme asas sahaja. Objek yang menggabungkan beberapa mesin ringkas ialah mesin kompleks.', N'Easy', N'Pending', N'2026-01-08 01:30:22', NULL),
    (N'QST054', N'Q046', N'ST353', N'U009', N'Complete the sentence by dragging the correct answer.

A _____ helps lift heavy objects using a rope.', N'Lengkapkan ayat dengan menyeret jawapan yang betul.

_____ membantu mengangkat objek berat menggunakan tali.', N'DragDrop', NULL, N'Pulley', N'Takal', N'Wheel', N'Roda', NULL, NULL, NULL, NULL, N'Takal', N'A pulley uses a rope and wheel to make lifting heavy objects easier.', N'Takal menggunakan tali dan roda untuk memudahkan kerja mengangkat objek yang berat.', N'A pulley is specially designed to lift loads using a rope, while a wheel has a different purpose.', N'Takal direka khas untuk mengangkat beban menggunakan tali, manakala roda mempunyai fungsi yang berbeza.', N'Medium', N'Pending', N'2026-01-08 01:32:22', NULL),
    (N'QST055', N'Q046', N'ST353', N'U009', N'A school is building a wheelchair ramp at the entrance. Why is a ramp a better choice than stairs for wheelchair users?', N'Sebuah sekolah membina laluan condong untuk pengguna kerusi roda di pintu masuk. Mengapakah laluan condong lebih sesuai berbanding tangga?', N'MCQ', NULL, N'It makes the wheelchair lighter', N'Ia menjadikan kerusi roda lebih ringan', N'It reduces the effort needed to move up to a higher place', N'Ia mengurangkan daya yang diperlukan untuk bergerak ke tempat yang lebih tinggi', N'It increases the speed of the wheelchair automatically', N'Ia meningkatkan kelajuan kerusi roda secara automatik', N'It changes the size of the wheelchair', N'Ia mengubah saiz kerusi roda', N'B', N'A ramp is an inclined plane, which is a simple machine. It reduces the force needed to move heavy objects or wheelchairs to a higher level, making movement safer and easier.', N'Laluan condong ialah sejenis satah condong, iaitu mesin ringkas yang mengurangkan daya yang diperlukan untuk menggerakkan objek berat atau kerusi roda ke tempat yang lebih tinggi. Oleh itu, ia lebih selamat dan mudah digunakan.', N'A ramp does not change the wheelchair itself. Its purpose is to reduce the effort required to move to a higher level by providing a sloping surface.', N'Laluan condong tidak mengubah kerusi roda. Fungsinya ialah mengurangkan daya yang diperlukan untuk bergerak ke tempat yang lebih tinggi melalui permukaan yang condong.', N'Hard', N'Pending', N'2026-01-08 01:30:22', NULL),
    (N'QST056', N'Q048', N'ST122', N'U023', N'A toy company wants to make magnetic building blocks that can be connected from the centre. Which magnet shape would be the MOST suitable?', N'Sebuah syarikat permainan ingin menghasilkan blok binaan magnet yang boleh disambungkan dari bahagian tengah. Bentuk magnet manakah yang PALING sesuai digunakan?', N'MCQ', NULL, N'Horseshoe magnet', N'Magnet ladam', N'Bar magnet', N'Magnet batang', N'Ring magnet', N'Magnet cincin', N'U-shaped plastic', N'Plastik berbentuk U', N'C', N'Ring magnets have a hole in the centre, making them suitable for certain designs such as toys, holders and rotating objects.', N'Magnet cincin mempunyai lubang di bahagian tengah, menjadikannya sesuai untuk reka bentuk tertentu seperti permainan, pemegang dan objek yang berputar.', N'Different magnet shapes are chosen based on their design and purpose. A ring magnet is suitable when a centre hole is needed.', N'Setiap bentuk magnet dipilih mengikut reka bentuk dan kegunaannya. Magnet cincin sesuai apabila diperlukan lubang di bahagian tengah.', N'Medium', N'Approved', N'2026-01-08 09:20:22', N'2026-01-22 13:20:22'),
    (N'QST057', N'Q048', N'ST122', N'U023', N'Complete the sentence by dragging the correct answer.

A magnet shaped like the letter _____ is called a horseshoe magnet.', N'Lengkapkan ayat dengan menyeret jawapan yang betul.

Magnet yang berbentuk huruf _____ dikenali sebagai magnet ladam.', N'DragDrop', NULL, N'U', N'U', N'T', N'T', NULL, NULL, NULL, NULL, N'U', N'A horseshoe magnet is bent into a U-shape, bringing its two magnetic poles closer together to produce a stronger magnetic effect.', N'Magnet ladam dibengkokkan menjadi bentuk huruf U, menyebabkan kedua-dua kutubnya berada lebih dekat dan menghasilkan daya magnet yang lebih kuat.', N'The name "horseshoe magnet" comes from its U-shaped design, which looks like a horseshoe.', N'Nama "magnet ladam" diambil daripada reka bentuknya yang berbentuk huruf U seperti ladam kuda.', N'Medium', N'Approved', N'2026-01-08 09:22:22', N'2026-01-22 13:20:22'),
    (N'QST058', N'Q048', N'ST141', N'U023', N'Which landform is usually found between two hills or mountains?', N'Bentuk muka bumi manakah yang biasanya terletak di antara dua bukit atau gunung?', N'MCQ', N'Images/Question/landforms.jpg', N'Valley', N'Lembah', N'Mountain', N'Gunung', N'Plateau', N'Tanah Tinggi', N'Beach', N'Pantai', N'A', N'Correct! A valley is a low area of land that is often located between hills or mountains. Rivers are commonly found flowing through valleys.', N'Correct! A valley is a low area of land that is often located between hills or mountains. Rivers are commonly found flowing through valleys.', N'Incorrect. Mountains and plateaus are higher landforms, while beaches are located along the coast.', N'Salah. Gunung dan tanah tinggi merupakan kawasan yang lebih tinggi, manakala pantai terletak di kawasan pesisir laut.', N'Easy', N'Approved', N'2026-01-08 09:25:22', N'2026-01-22 13:20:22'),
    (N'QST059', N'Q048', N'ST141', N'U023', N'A recycling centre needs a magnet to collect many iron nails quickly from a pile of mixed materials. Which magnet shape would be the BEST choice and why?', N'Sebuah pusat kitar semula memerlukan magnet untuk mengutip banyak paku besi dengan cepat daripada timbunan pelbagai bahan. Bentuk magnet manakah yang PALING sesuai dan mengapa?', N'MCQ', NULL, N'Ring magnet because it has a hole in the middle', N'Magnet cincin kerana mempunyai lubang di bahagian tengah', N'Disc magnet because it is flat', N'Magnet cakera kerana bentuknya leper', N'Plastic U-shape because it looks like a horseshoe', N'Plastik berbentuk U kerana rupanya seperti ladam', N'Horseshoe magnet because its poles are close together, producing a stronger magnetic pull', N'Magnet ladam kerana kutubnya berdekatan dan menghasilkan daya tarikan magnet yang lebih kuat', N'D', N'A horseshoe magnet is commonly used for collecting metal objects because its poles are positioned close together, concentrating the magnetic force and making it easier to attract iron objects.', N'Magnet ladam sering digunakan untuk mengutip objek logam kerana kedua-dua kutubnya berada berdekatan. Keadaan ini menumpukan daya magnet pada hujung magnet dan memudahkan paku besi serta objek logam lain ditarik.', N'The best magnet is not chosen based on its appearance, but on how its shape affects its magnetic strength and intended use.', N'Pemilihan magnet bukan berdasarkan rupanya semata-mata, tetapi berdasarkan bagaimana bentuk magnet mempengaruhi kekuatan daya magnet dan kegunaannya.', N'Hard', N'Approved', N'2026-01-08 09:26:22', N'2026-01-22 13:20:22'),
    (N'QST060', N'Q048', N'ST152', N'U023', N'A cylinder has four flat circular faces and one curved surface.', N'Silinder mempunyai empat permukaan bulat yang rata dan satu permukaan melengkung.', N'TrueFalse', NULL, N'TRUE', N'BETUL', N'FALSE', N'SALAH', NULL, NULL, NULL, NULL, N'B', N'A cylinder has two flat circular faces—one at the top and one at the bottom—and one curved surface. Therefore, the statement is false.', N'Silinder mempunyai dua permukaan bulat yang rata, iaitu satu di bahagian atas dan satu di bahagian bawah, serta satu permukaan melengkung. Oleh itu, pernyataan ini adalah salah.', N'A cylinder does not have only one flat circular face. It has two flat circular faces connected by one curved surface.', N'Silinder bukan mempunyai satu permukaan bulat yang rata sahaja. Silinder mempunyai dua permukaan bulat yang rata yang dihubungkan oleh satu permukaan melengkung.', N'Easy', N'Approved', N'2026-01-08 09:30:22', N'2026-01-22 13:20:22'),
    (N'QST061', N'Q048', N'ST152', N'U023', N'A toy company wants to design a toy that can roll smoothly in any direction without getting stuck. Which 3D shape is the BEST choice?', N'Sebuah syarikat permainan ingin mereka bentuk mainan yang boleh bergolek dengan lancar ke semua arah tanpa tersekat. Bentuk 3D manakah yang PALING sesuai?', N'MCQ', NULL, N'Cube', N'Kubus', N'Cuboid', N'Kuboid', N'Sphere', N'Sfera', N'Pyramid', N'Piramid', N'C', N'A sphere has one continuous curved surface and no edges, allowing it to roll smoothly in every direction. Shapes with flat faces or edges cannot roll as smoothly.', N'Sfera mempunyai satu permukaan melengkung yang berterusan tanpa sisi atau bucu, membolehkannya bergolek dengan lancar ke semua arah. Bentuk yang mempunyai permukaan rata atau sisi tidak dapat bergolek dengan begitu lancar.', N'To roll smoothly in all directions, an object needs a fully curved surface without flat faces or edges.', N'Untuk bergolek dengan lancar ke semua arah, sesuatu objek perlu mempunyai permukaan yang melengkung sepenuhnya tanpa permukaan rata atau sisi.', N'Hard', N'Approved', N'2026-01-08 09:31:22', N'2026-01-22 13:20:22'),
    (N'QST062', N'Q049', N'ST212', N'U009', N'Which meal shows a balanced diet?', N'Hidangan manakah menunjukkan diet seimbang?', N'MCQ', N'Images/Question/meal.png', N'Fried chicken and soft drink only', N'Ayam goreng dan minuman bergas sahaja', N'Chocolate and sweets', N'Coklat dan gula-gula', N'Potato chips only', N'Kerepek kentang sahaja', N'Rice, grilled fish, vegetables and an orange', N'Nasi, ikan bakar, sayur-sayuran dan sebiji oren', N'D', N'A balanced diet includes different food groups such as carbohydrates, protein, vitamins and minerals. Rice provides energy, fish supplies protein, vegetables provide fibre and vitamins, while oranges are rich in vitamin C.', N'Diet seimbang mengandungi pelbagai kumpulan makanan seperti karbohidrat, protein, vitamin dan mineral. Nasi membekalkan tenaga, ikan membekalkan protein, sayur-sayuran membekalkan serat dan vitamin, manakala oren kaya dengan vitamin C.', N'A balanced diet should include a variety of nutrients. Meals containing only one type of food cannot provide all the nutrients our body needs.', N'Diet seimbang perlu mengandungi pelbagai jenis nutrien. Hidangan yang hanya mempunyai satu jenis makanan tidak dapat membekalkan semua nutrien yang diperlukan oleh badan.', N'Easy', N'Pending', N'2026-01-09 13:11:22', NULL),
    (N'QST063', N'Q049', N'ST212', N'U009', N'Hakim wants to have enough energy for a football match after school. Which TWO foods should he choose?', N'Hakim ingin mempunyai tenaga yang mencukupi untuk bermain bola sepak selepas sekolah. Pilih DUA makanan yang paling sesuai.', N'Multiselect', NULL, N'Rice', N'Nasi', N'Bread', N'Roti', N'Soft Drink', N'Minuman bergas', N'Candy', N'Gula-gula', N'A,B', N'Rice and bread are rich in carbohydrates, which provide the body with energy for physical activities such as playing football.', N'Nasi dan roti kaya dengan karbohidrat yang membekalkan tenaga kepada badan untuk melakukan aktiviti fizikal seperti bermain bola sepak.', N'Sugary foods and soft drinks may provide energy for a short time, but carbohydrates are a healthier and more reliable source of energy.', N'Makanan bergula dan minuman bergas mungkin memberikan tenaga untuk tempoh yang singkat, tetapi karbohidrat merupakan sumber tenaga yang lebih sihat dan berpanjangan.', N'Medium', N'Pending', N'2026-01-09 13:11:22', NULL),
    (N'QST064', N'Q049', N'ST221', N'U009', N'Two toy boats are placed on water. Boat A is made of metal but is hollow. Boat B is a small solid metal block. Which boat is MORE LIKELY to float?', N'Dua buah bot mainan diletakkan di atas air. Bot A diperbuat daripada logam tetapi berongga. Bot B ialah bongkah logam pepejal yang kecil. Bot manakah yang LEBIH BERKEMUNGKINAN terapung?', N'MCQ', NULL, N'Boat A', N'Bot A', N'Boat B', N'Bot B', N'Both boats', N'Kedua - dua bot', N'Neither boat', N'Tiada satu pun', N'A', N'Although Boat A is made of metal, its hollow design traps air and lowers its overall density, allowing it to float. A solid metal block is denser than water and usually sinks', N'Walaupun Bot A diperbuat daripada logam, reka bentuknya yang berongga memerangkap udara dan mengurangkan ketumpatan keseluruhannya, membolehkannya terapung. Bongkah logam pepejal lebih tumpat daripada air dan biasanya tenggelam.', N'Whether an object floats does not depend only on the material it is made from. Its shape and overall density are also important.', N'Sama ada sesuatu objek terapung bukan hanya bergantung pada bahan pembuatannya. Bentuk dan ketumpatan keseluruhannya juga memainkan peranan penting.', N'Hard', N'Approved', N'2026-01-11 13:13:22', N'2026-01-24 13:13:22'),
    (N'QST065', N'Q049', N'ST223', N'U022', N'A fisherman wants his fishing net to sink into the water. Which TWO materials are suitable to attach to the net?', N'Seorang nelayan ingin memastikan jaringnya tenggelam ke dalam air. Pilih DUA bahan yang sesuai dipasang pada jaring tersebut.', N'Multiselect', NULL, N'Cork', N'Gabus', N'Foam', N'Buih', N'Metal weights', N'Pemberat logam', N'Stones', N'Batu', N'C,D', N'Metal weights and stones are denser than water, so they help pull the fishing net underwater. Cork and foam are less dense than water and tend to float.', N'Pemberat logam dan batu lebih tumpat daripada air, jadi kedua-duanya membantu jaring tenggelam. Gabus dan buih pula kurang tumpat daripada air dan cenderung untuk terapung.', N'Objects that are denser than water sink and are suitable as weights. Objects that are less dense than water float and cannot pull the net underwater.', N'Objek yang lebih tumpat daripada air akan tenggelam dan sesuai dijadikan pemberat. Objek yang kurang tumpat daripada air akan terapung dan tidak dapat membantu jaring tenggelam.', N'Medium', N'Approved', N'2026-01-11 13:14:22', N'2026-01-24 13:13:22'),
    (N'QST066', N'Q049', N'ST232', N'U022', N'Siti accidentally spills vinegar on the kitchen table. Which household item can help reduce its acidity?', N'Siti tertumpahkan cuka di atas meja dapur. Barangan rumah manakah yang boleh membantu mengurangkan sifat berasid cuka?', N'MCQ', NULL, N'Lemon juice', N'Jus lemon', N'Orange juice', N'Jus oren', N'Baking soda', N'Soda penaik', N'Vinegar', N'Cuka', N'C', N'Baking soda is an alkaline substance. It can help neutralise acidic substances such as vinegar.', N'Soda penaik ialah bahan beralkali. Ia boleh membantu meneutralkan bahan berasid seperti cuka.', N'To reduce acidity, an alkaline substance is needed. Lemon juice, orange juice and vinegar are acidic.', N'Untuk mengurangkan sifat berasid, bahan beralkali diperlukan. Jus lemon, jus oren dan cuka ialah bahan berasid.', N'Medium', N'Approved', N'2026-01-11 13:14:22', N'2026-01-24 13:13:22'),
    (N'QST067', N'Q049', N'ST242', N'U022', N'Which planet is the hottest planet in the Solar System?', N'Planet manakah merupakan planet yang paling panas dalam Sistem Suria?', N'MCQ', NULL, N'Venus', N'Zuhrah', N'Mercury', N'Utarid', N'Earth', N'Bumi', N'Mars', N'Marikh', N'A', N'Venus is the hottest planet because its thick atmosphere traps heat through the greenhouse effect, making its surface even hotter than Mercury.', N'Zuhrah ialah planet yang paling panas kerana atmosfera tebalnya memerangkap haba melalui kesan rumah hijau, menyebabkan permukaannya lebih panas daripada Utarid.', N'Although Mercury is the closest planet to the Sun, Venus is hotter because its thick atmosphere traps heat.', N'Walaupun Utarid ialah planet yang paling hampir dengan Matahari, Zuhrah lebih panas kerana atmosfera tebalnya memerangkap haba.', N'Easy', N'Approved', N'2026-01-11 13:15:22', N'2026-01-24 13:13:22'),
    (N'QST068', N'Q049', N'ST252', N'U022', N'A worker needs to lift a heavy bucket from a deep well every day. Why is a fixed pulley installed above the well?', N'Seorang pekerja perlu mengangkat baldi yang berat dari sebuah perigi setiap hari. Mengapakah takal tetap dipasang di bahagian atas perigi?', N'MCQ', NULL, N'To reduce the weight of the bucket to zero', N'Untuk mengurangkan berat baldi menjadi sifar', N'To make the bucket float', N'Untuk membuat baldi terapung', N'To shorten the rope', N'Untuk memendekkan tali', N'To allow the bucket to be lifted by pulling the rope downward', N'Untuk membolehkan baldi diangkat dengan menarik tali ke bawah', N'D', N'A fixed pulley changes the direction of the pulling force. Instead of lifting the bucket upward directly, the worker pulls the rope downward, making the task more convenient and safer.', N'Takal tetap menukar arah daya tarikan. Daripada mengangkat baldi terus ke atas, pekerja hanya perlu menarik tali ke bawah, menjadikan kerja lebih mudah dan selamat dilakukan.', N'A fixed pulley does not reduce the bucket''s weight or shorten the rope. Its purpose is to change the direction of the force so lifting becomes easier to perform.', N'Takal tetap tidak mengurangkan berat baldi atau memendekkan tali. Fungsinya ialah menukar arah daya supaya kerja mengangkat menjadi lebih mudah dilakukan.', N'Hard', N'Approved', N'2026-01-11 13:16:22', N'2026-01-24 13:13:22'),
    (N'QST069', N'Q050', N'ST313', N'U023', N'A person has been exercising for 20 minutes. Which TWO changes are MOST LIKELY to happen?', N'Seseorang telah bersenam selama 20 minit. Pilih DUA perubahan yang PALING MUNGKIN berlaku.', N'Multiselect', NULL, N'The heart beats faster', N'Jantung berdegup lebih laju', N'Blood stops flowing', N'Darah berhenti mengalir', N'The heart stops pumping', N'Jantung berhenti mengepam', N'Blood carries more oxygen to the muscles', N'Darah membawa lebih banyak oksigen ke otot', N'A,D', N'During exercise, the heart beats faster to pump more blood. This supplies more oxygen and nutrients to the muscles so they can work efficiently.', N'Semasa bersenam, jantung berdegup lebih laju untuk mengepam lebih banyak darah. Ini membekalkan lebih banyak oksigen dan nutrien kepada otot supaya dapat bekerja dengan lebih berkesan.', N'Exercise increases blood circulation. The heart continues pumping blood and never stops during normal physical activity.', N'Semasa bersenam, peredaran darah meningkat. Jantung terus mengepam darah dan tidak berhenti semasa melakukan aktiviti fizikal yang normal.', N'Medium', N'Approved', N'2026-01-10 13:11:22', N'2026-01-17 13:11:22'),
    (N'QST070', N'Q050', N'ST323', N'U023', N'Complete the sentence by dragging the correct answer.

A _____ controls the flow of electricity by opening or closing the circuit.', N'Lengkapkan ayat dengan menyeret jawapan yang betul.

_____ mengawal aliran elektrik dengan membuka atau menutup litar.', N'DragDrop', NULL, N'Switch', N'Suis', N'Bulb', N'Mentol', NULL, NULL, NULL, NULL, N'Switch,Suis', N'A switch controls the flow of electricity by opening or closing the circuit. When the switch is closed, electricity can flow through the circuit and the bulb can light up.', N'Suis mengawal aliran elektrik dengan membuka atau menutup litar. Apabila suis ditutup, arus elektrik dapat mengalir melalui litar dan mentol boleh menyala.', N'A bulb produces light when electricity flows through it, but it does not control the flow of electricity. The switch is the component that opens and closes the circuit.', N'Mentol menghasilkan cahaya apabila arus elektrik mengalir melaluinya, tetapi mentol tidak mengawal aliran elektrik. Suis ialah komponen yang membuka dan menutup litar.', N'Medium', N'Approved', N'2026-01-10 13:11:22', N'2026-01-17 13:11:22'),
    (N'QST071', N'Q050', N'ST323', N'U023', N'A circuit contains

battery
bulb
wires

The bulb does not light up.

Which component is MOST LIKELY missing?', N'Satu litar mempunyai

bateri
mentol
wayar

Mentol masih tidak menyala.

Komponen manakah PALING MUNGKIN tiada?', N'MCQ', NULL, N'Battery', N'Bateri', N'Bulb', N'Mentol', N'Switch', N'Suis', N'Wire', N'Wayar', N'C', N'A switch is used to open or close an electrical circuit. Without a switch, the circuit may be incomplete, preventing electricity from flowing to the bulb. Adding the switch completes the circuit so the bulb can light up.', N'Suis digunakan untuk membuka dan menutup litar elektrik. Tanpa suis, litar mungkin tidak lengkap dan elektrik tidak dapat mengalir ke mentol. Apabila suis dipasang dan ditutup, litar menjadi lengkap lalu mentol boleh menyala.', N'The battery supplies electrical energy, the bulb produces light, and the wires connect the components. In this situation, those components are already present. The missing component is the switch, which completes the circuit and allows electricity to flow.', N'ateri membekalkan tenaga elektrik, mentol menghasilkan cahaya, dan wayar menyambungkan semua komponen. Dalam situasi ini, semua komponen tersebut telah ada. Komponen yang tiada ialah suis, yang melengkapkan litar dan membolehkan arus elektrik mengalir.', N'Medium', N'Approved', N'2026-01-10 13:11:22', N'2026-01-17 13:11:22'),
    (N'QST072', N'Q050', N'ST341', N'U022', N'Why does the Moon appear to change its shape over time?', N'Mengapakah Bulan kelihatan berubah bentuk dari semasa ke semasa?', N'MCQ', NULL, N'The Moon changes its size', N'Bulan berubah saiz', N'Clouds cover parts of the Moon', N'Awan menutupi sebahagian Bulan', N'Different portions of the Moon are illuminated by the Sun as the Moon revolves around Earth', N'Bahagian Bulan yang disinari Matahari berubah apabila Bulan beredar mengelilingi Bumi', N'The Earth changes the shape of the Moon', N'Bumi mengubah bentuk Bulan', N'C', N'The Moon does not change its actual shape. As it revolves around the Earth, different portions of the Moon that are illuminated by the Sun become visible from Earth, creating the different phases of the Moon.', N'Bulan tidak berubah bentuk sebenar. Apabila Bulan beredar mengelilingi Bumi, bahagian Bulan yang disinari Matahari dan dapat dilihat dari Bumi berubah, lalu menghasilkan fasa-fasa Bulan.', N'The Moon always keeps the same shape. Its different phases happen because we see different illuminated portions of the Moon from Earth.', N'Bulan sentiasa mempunyai bentuk yang sama. Perubahan fasa berlaku kerana kita melihat bahagian Bulan yang disinari Matahari dari sudut yang berbeza.', N'Medium', N'Pending', N'2026-01-10 13:00:22', NULL),
    (N'QST073', N'Q050', N'ST341', N'U022', N'The Moon produces its own light.', N'Bulan menghasilkan cahayanya sendiri.', N'TrueFalse', NULL, N'TRUE', N'BETUL', N'FALSE', N'SALAH', NULL, NULL, NULL, NULL, N'B', N'The Moon does not produce its own light. It appears bright because it reflects sunlight.', N'Bulan tidak menghasilkan cahayanya sendiri. Bulan kelihatan terang kerana memantulkan cahaya Matahari.', N'Only the Sun produces its own light. The Moon reflects sunlight, allowing us to see it at night.', N'Hanya Matahari menghasilkan cahayanya sendiri. Bulan memantulkan cahaya Matahari, membolehkan kita melihatnya pada waktu malam.', N'Easy', N'Pending', N'2026-01-10 13:00:22', NULL),
    (N'QST074', N'Q050', N'ST341', N'U022', N'Hakim says that the Moon becomes smaller each night because part of it disappears. Is his statement correct?', N'Hakim mengatakan Bulan menjadi semakin kecil setiap malam kerana sebahagian daripadanya hilang. Adakah kenyataannya betul?', N'MCQ', NULL, N'Yes, because the Moon loses pieces every night', N'Ya, kerana Bulan kehilangan sebahagian daripadanya setiap malam', N'No, because clouds cover part of the Moon', N'Tidak, kerana awan menutupi sebahagian Bulan', N'No, because the Moon''s size does not change; only the illuminated part that we can see changes', N'Tidak, kerana saiz Bulan tidak berubah; hanya bahagian yang disinari dan dapat dilihat berubah', N'Yes, because the Earth pulls part of the Moon away', N'Ya, kerana Bumi menarik sebahagian Bulan keluar', N'C', N'The Moon always remains the same size. Its phases occur because we see different illuminated portions of the Moon as it revolves around Earth.', N'Saiz Bulan sentiasa kekal sama. Fasa Bulan berlaku kerana kita melihat bahagian Bulan yang berbeza yang disinari Matahari semasa Bulan beredar mengelilingi Bumi.', N'The Moon does not lose parts of itself or become smaller. The changing appearance is caused by sunlight illuminating different portions of the Moon.', N'Bulan tidak kehilangan bahagiannya atau menjadi semakin kecil. Perubahan yang dilihat berlaku kerana cahaya Matahari menyinari bahagian Bulan yang berbeza.', N'Hard', N'Pending', N'2026-01-10 13:00:22', NULL),
    (N'QST075', N'Q051', N'ST223', N'U022', NULL, N'Mengapakah kapal yang besar boleh terapung di atas air?', N'MCQ', NULL, NULL, N'Kapal diperbuat daripada plastik', NULL, N'Kapal mempunyai ketumpatan keseluruhan yang lebih rendah daripada air', NULL, N'Kapal sentiasa bergerak', NULL, N'Kapal sangat ringan', N'B', NULL, N'Walaupun kapal berat, reka bentuknya mengandungi ruang udara yang menjadikan ketumpatan keseluruhannya lebih rendah daripada air.', NULL, N'Kapal bukan terapung kerana ia ringan atau sentiasa bergerak, tetapi kerana ketumpatannya sesuai untuk terapung.', N'Easy', N'Pending', N'2026-01-15 15:00:00', NULL),
    (N'QST076', N'Q051', N'ST223', N'U022', NULL, N'Apakah kegunaan jaket keselamatan?', N'MCQ', NULL, NULL, N'Menjadikan badan lebih panas', NULL, N'Membantu seseorang terapung di atas air', NULL, N'Menambah berat badan', NULL, N'Mengeringkan pakaian', N'B', NULL, N'Jaket keselamatan mengandungi bahan yang kurang tumpat daripada air dan membantu seseorang terapung.', NULL, N'Fungsi utama jaket keselamatan ialah membantu seseorang terapung dengan selamat di dalam air.', N'Easy', N'Pending', N'2026-01-15 15:00:00', NULL),
    (N'QST077', N'Q051', N'ST223', N'U022', NULL, N'Mengapakah minyak masak terapung di atas air?', N'MCQ', NULL, NULL, N'Minyak lebih berat daripada air', NULL, N'Minyak lebih tumpat daripada air', NULL, N'Minyak kurang tumpat daripada air', NULL, N'Minyak mengandungi udara', N'C', NULL, N'Minyak mempunyai ketumpatan yang lebih rendah daripada air, sebab itu ia terapung di permukaan air.', NULL, N'Minyak tidak lebih tumpat atau lebih berat daripada air dalam keadaan biasa.', N'Medium', N'Pending', N'2026-01-15 15:00:00', NULL),
    (N'QST078', N'Q051', N'ST223', N'U022', NULL, N'Ali menuang minyak ke dalam segelas air. Dia mendapati minyak berada di bahagian atas. Apakah kesimpulan yang boleh dibuat?', N'MCQ', NULL, NULL, N'Minyak lebih berat daripada air', NULL, N'Air lebih ringan daripada minyak', NULL, N'Minyak mempunyai ketumpatan yang lebih rendah daripada air', NULL, N'Minyak bercampur sepenuhnya dengan air', N'C', NULL, N'Minyak terapung kerana ketumpatannya lebih rendah daripada air dan kedua-duanya tidak bercampur sepenuhnya.', NULL, N'Jika minyak lebih berat atau lebih tumpat daripada air, ia akan berada di bahagian bawah bekas.', N'Hard', N'Pending', N'2026-01-15 15:00:00', NULL),
    (N'QST079', N'Q051', N'ST223', N'U022', NULL, N'Jaket keselamatan membantu seseorang terapung kerana ia meningkatkan daya apungan badan di dalam air.', N'TrueFalse', NULL, NULL, N'Betul', NULL, N'Salah', NULL, NULL, NULL, NULL, N'A', NULL, N'Jaket keselamatan diperbuat daripada bahan yang kurang tumpat daripada air. Bahan ini membantu meningkatkan daya apungan dan membolehkan seseorang terapung dengan lebih mudah di permukaan air.', NULL, N'Jaket keselamatan bukan sekadar pakaian biasa. Ia direka khas untuk membantu seseorang kekal terapung dan mengurangkan risiko lemas.', N'Easy', N'Pending', N'2026-01-15 15:00:00', NULL),
    (N'QST080', N'Q051', N'ST223', N'U022', NULL, N'Aina meletakkan sebiji epal dan seketul batu ke dalam baldi air. Epal terapung tetapi batu tenggelam. Mengapa?', N'MCQ', NULL, NULL, N'Batu lebih gelap warnanya', NULL, N'Epal lebih cantik daripada batu', NULL, N'Epal mempunyai ketumpatan yang lebih rendah daripada air', NULL, N'Batu tidak menyukai air', N'C', NULL, N'Epal terapung kerana ketumpatannya lebih rendah daripada air. Batu pula tenggelam kerana ketumpatannya lebih tinggi daripada air. Ketumpatan memainkan peranan penting dalam menentukan sama ada sesuatu objek akan terapung atau tenggelam.', NULL, N'Warna, rupa bentuk atau ciri-ciri lain tidak menentukan sama ada sesuatu objek terapung atau tenggelam. Faktor utama ialah ketumpatan objek berbanding ketumpatan air.', N'Medium', N'Pending', N'2026-01-15 15:00:00', NULL),
    (N'QST081', N'Q051', N'ST223', N'U022', NULL, N'Sebuah kapal kargo membawa beribu-ribu kontena tetapi masih boleh terapung. Apakah sebab yang paling tepat?', N'MCQ', NULL, NULL, N'Kapal diperbuat daripada logam yang ringan', NULL, N'Kapal sentiasa bergerak', NULL, N'Reka bentuk kapal menyebabkan ketumpatan keseluruhannya lebih rendah daripada air', NULL, N'Air laut menolak kapal ke atas secara ajaib', N'C', NULL, N'Walaupun kapal sangat berat, reka bentuknya yang mempunyai ruang udara yang besar menyebabkan ketumpatan keseluruhannya menjadi lebih rendah daripada air. Oleh itu, kapal dapat terapung di permukaan air.', NULL, N'Kapal tidak terapung kerana sentiasa bergerak atau disebabkan faktor ajaib. Keupayaan kapal untuk terapung bergantung kepada ketumpatan keseluruhan kapal dan reka bentuknya yang membolehkan daya apungan bertindak dengan berkesan.', N'Hard', N'Pending', N'2026-01-15 15:00:00', NULL),
    (N'QST082', N'Q052', N'ST241', N'U022', N'Which planet is known as the Red Planet?', NULL, N'MCQ', N'Images/Question/solar_system.jpg', N'Venus', NULL, N'Jupiter', NULL, N'Mars', NULL, N'Saturn', NULL, N'C', N'Mars is often called the Red Planet because its surface contains iron oxide, giving it a reddish appearance.', NULL, N'Venus, Jupiter and Saturn have different characteristics and are not known as the Red Planet.', NULL, N'Easy', N'Approved', N'2026-04-01 15:12:00', N'2026-04-03 15:12:00'),
    (N'QST083', N'Q052', N'ST241', N'U022', N'Which objects are members of the Solar System?', NULL, N'Multiselect', NULL, N'Sun', NULL, N'Planets', NULL, N'Moons', NULL, N'School Bus', NULL, N'A, B, C', N'The Solar System contains the Sun, planets, moons, asteroids and other celestial objects.', NULL, N'A school bus is an object found on Earth and is not part of the Solar System.', NULL, N'Medium', N'Approved', N'2026-04-01 15:12:00', N'2026-04-03 15:12:00'),
    (N'QST084', N'Q052', N'ST241', N'U022', N'Which of the following are planets in the Solar System?', NULL, N'Multiselect', NULL, N'Earth', NULL, N'Mars', NULL, N'Jupiter', NULL, N'Sun', NULL, N'A, B, C', N'Earth, Mars and Jupiter are planets. The Sun is a star, not a planet.', NULL, N'Many students confuse the Sun with a planet, but it is actually a star.', NULL, N'Medium', N'Approved', N'2026-04-01 15:12:00', N'2026-04-03 15:12:00'),
    (N'QST085', N'Q052', N'ST241', N'U022', N'The Moon is a planet in the Solar System.', NULL, N'TrueFalse', NULL, N'TRUE', NULL, N'FALSE', NULL, NULL, NULL, NULL, NULL, N'B', N'The Moon is Earth''s natural satellite, not a planet.', NULL, N'Although the Moon is found in the Solar System, it is classified as a natural satellite.', NULL, N'Medium', N'Approved', N'2026-04-01 15:12:00', N'2026-04-03 15:12:00'),
    (N'QST086', N'Q052', N'ST241', N'U022', N'The ______ is at the center of the Solar System.

Humans live on ______.

Mars is known as the ______ Planet.', NULL, N'DragDrop', NULL, N'Earth', NULL, N'Sun', NULL, N'Red', NULL, N'Moon', NULL, N'Sun,Earth,Red', N'The Sun is at the center of the Solar System, humans live on Earth and Mars is commonly known as the Red Planet.', NULL, N'The Moon is not at the center of the Solar System and is not the correct answer for these statements.', NULL, N'Medium', N'Approved', N'2026-04-01 15:12:00', N'2026-04-03 15:12:00'),
    (N'QST087', N'Q052', N'ST241', N'U022', N'The Sun is a star.', NULL, N'TrueFalse', NULL, N'TRUE', NULL, N'FALSE', NULL, NULL, NULL, NULL, NULL, N'A', N'The Sun is a star that produces its own light and heat. It provides the energy needed for life on Earth.', NULL, N'The Sun is not a planet. It is a star located at the center of the Solar System.', NULL, N'Easy', N'Approved', N'2026-04-01 15:12:00', N'2026-04-03 15:12:00'),
    (N'QST088', N'Q052', N'ST241', N'U022', N'Why do all planets in the Solar System revolve around the Sun?', NULL, N'MCQ', NULL, N'Because the Sun is the largest source of gravity in the Solar System', NULL, N'Because the planets are lighter than the Sun', NULL, N'Because the Moon tells them where to go', NULL, N'Because the planets move randomly', NULL, N'A', N'The Sun has a very strong gravitational pull that keeps the planets moving around it in their orbits.', NULL, N'Planets do not move randomly, and the Moon does not control their movement. Gravity from the Sun is the main reason planets orbit around it.', NULL, N'Hard', N'Approved', N'2026-04-01 15:12:00', N'2026-04-03 15:12:00'),
    (N'QST089', N'Q053', N'ST354', N'U022', N'What is a compound machine?', NULL, N'MCQ', NULL, N'A machine made from only one simple machine', NULL, N'A machine made from two or more simple machines', NULL, N'A machine that uses water only', NULL, N'A machine that does not move', NULL, N'B', N'A compound machine is formed when two or more simple machines work together to make tasks easier and more efficient.', NULL, N'A compound machine is not made from just one simple machine. It combines multiple simple machines to perform a task.', NULL, N'Easy', N'Approved', N'2026-04-01 20:11:12', N'2026-04-08 20:11:12'),
    (N'QST090', N'Q053', N'ST354', N'U022', N'Which of the following is a compound machine?', NULL, N'MCQ', NULL, N'Ramp', NULL, N'Pulley', NULL, N'Bicycle', NULL, N'Lever', NULL, N'C', N'A bicycle contains several simple machines such as wheels and axles, gears and levers, making it a compound machine.', NULL, N'A ramp, pulley and lever are examples of simple machines, not compound machines.', NULL, N'Easy', N'Approved', N'2026-04-01 20:11:12', N'2026-04-08 20:11:12'),
    (N'QST091', N'Q053', N'ST354', N'U022', N'Why do people use compound machines?', NULL, N'MCQ', NULL, N'To make work easier', NULL, N'To make work harder', NULL, N'To increase homework', NULL, N'To create noise', NULL, N'A', N'Compound machines help people perform tasks more easily by reducing effort and improving efficiency.', NULL, N'Compound machines are designed to help people, not to make work harder or create unnecessary noise.', NULL, N'Easy', N'Approved', N'2026-04-01 20:11:12', N'2026-04-08 20:11:12'),
    (N'QST092', N'Q053', N'ST354', N'U022', N'A pair of scissors is a compound machine.', NULL, N'TrueFalse', NULL, N'TRUE', NULL, N'FALSE', NULL, NULL, NULL, NULL, NULL, N'A', N'Scissors combine levers and wedges, making them a compound machine.', NULL, N'Scissors contain more than one simple machine working together.', NULL, N'Easy', N'Approved', N'2026-04-01 20:11:12', N'2026-04-08 20:11:12'),
    (N'QST093', N'Q053', N'ST354', N'U022', N'A wheel and axle is a compound machine.', NULL, N'TrueFalse', NULL, N'TRUE', NULL, N'FALSE', NULL, NULL, NULL, NULL, NULL, N'B', N'A wheel and axle is classified as a simple machine, not a compound machine.', NULL, N'Compound machines must contain two or more simple machines working together.', NULL, N'Medium', N'Approved', N'2026-04-01 20:11:12', N'2026-04-08 20:11:12'),
    (N'QST094', N'Q053', N'ST354', N'U022', N'Which simple machines can be found in a bicycle?', NULL, N'Multiselect', NULL, N'Wheel and Axle', NULL, N'Gear', NULL, N'Lever', NULL, N'Spoon', NULL, N'A, B, C', N'A bicycle uses wheels and axles, gears and levers to help riders move efficiently.', NULL, N'A spoon is not a simple machine found in a bicycle.', NULL, N'Medium', N'Approved', N'2026-04-01 20:11:12', N'2026-04-08 20:11:12'),
    (N'QST095', N'Q053', N'ST354', N'U022', N'Which of the following are compound machines?', NULL, N'Multiselect', NULL, N'Bicycle', NULL, N'Wheelbarrow', NULL, N'Can Opener', NULL, N'Pulley', NULL, N'A, B, C', N'A bicycle, wheelbarrow and can opener combine multiple simple machines to perform tasks more effectively.', NULL, N'A pulley is considered a simple machine and does not qualify as a compound machine on its own.', NULL, N'Medium', N'Approved', N'2026-04-01 20:11:12', N'2026-04-08 20:11:12'),
    (N'QST096', N'Q053', N'ST354', N'U022', N'A bicycle is a ______ machine.

Scissors combine a lever and a ______.

Compound machines help make work ______.', NULL, N'DragDrop', NULL, N'compound', NULL, N'easier', NULL, N'wedge', NULL, N'planet', NULL, N'compound,wedge,easier', N'A bicycle is a compound machine, scissors use wedges, and compound machines are designed to make work easier.', NULL, N'A planet is not related to compound machines and cannot complete any of the sentences correctly.', NULL, N'Medium', N'Approved', N'2026-04-01 20:11:12', N'2026-04-08 20:11:12'),
    (N'QST097', N'Q053', N'ST354', N'U022', N'A student wants to cut cardboard for a school project. Which compound machine would be the most suitable?', NULL, N'MCQ', NULL, N'Bicycle', NULL, N'Scissors', NULL, N'Wheelbarrow', NULL, N'Pulley', NULL, N'B', N'Scissors are designed for cutting materials and combine simple machines to make cutting easier and more effective.', NULL, N'Bicycles, wheelbarrows and pulleys are useful machines, but they are not suitable for cutting cardboard.', NULL, N'Hard', N'Approved', N'2026-04-01 20:11:12', N'2026-04-08 20:11:12'),
    (N'QST098', N'Q053', N'ST354', N'U022', N'A wheelbarrow is used to carry heavy loads. Why is it considered a compound machine?', NULL, N'MCQ', NULL, N'It contains only one simple machine', NULL, N'It combines a wheel and axle with a lever', NULL, N'It uses electricity', NULL, N'It can only be used outdoors', NULL, N'B', N'A wheelbarrow combines a wheel and axle with a lever, making it a compound machine that helps reduce effort when carrying loads.', NULL, N'A wheelbarrow does not rely on electricity and is not made from only one simple machine. Its classification comes from combining multiple simple machines.', NULL, N'Hard', N'Approved', N'2026-04-01 20:11:12', N'2026-04-08 20:11:12'),
    (N'QST099', N'Q035', N'ST314', N'U009', N'What is the correct pathway of blood circulation?', N'Apakah laluan peredaran darah yang betul?', N'MCQ', NULL, N'Heart → Blood Vessels → Body Cells → Heart', N'Jantung → Salur Darah → Sel Badan → Jantung', N'Heart → Bones → Body Cells → Heart', N'Jantung → Tulang → Sel Badan → Jantung', N'Heart → Stomach → Body Cells → Heart', N'Jantung → Perut → Sel Badan → Jantung', N'Heart → Muscles → Teeth → Heart', N'Jantung → Otot → Gigi → Jantung', N'A', N'Correct! Blood is pumped from the heart through blood vessels to body cells and then returns to the heart.', N'Betul! Darah dipam dari jantung melalui salur darah ke seluruh badan sebelum kembali semula ke jantung.', N'Incorrect. Bones, teeth and stomach are not part of the main blood circulation pathway.', N'Salah. Tulang, gigi dan perut bukan laluan utama dalam sistem peredaran darah.', N'Easy', N'Pending', N'2026-07-01 20:11:12', NULL);
GO

PRINT N'Inserting Enrollment (14 rows)...';
INSERT INTO dbo.[Enrollment] ([enrollmentId], [studentId], [levelId], [enrolledDate], [status])
VALUES
    (N'EN001', N'S001', N'LV001', N'2026-01-06', N'Active'),
    (N'EN002', N'S002', N'LV001', N'2026-05-01', N'Active'),
    (N'EN003', N'S003', N'LV003', N'2026-10-03', N'Deleted'),
    (N'EN004', N'S004', N'LV001', N'2026-01-04', N'Active'),
    (N'EN005', N'S005', N'LV001', N'2026-01-02', N'Completed'),
    (N'EN006', N'S005', N'LV002', N'2026-01-05', N'Active'),
    (N'EN007', N'S006', N'LV001', N'2026-01-01', N'Completed'),
    (N'EN008', N'S006', N'LV002', N'2026-01-03', N'Completed'),
    (N'EN009', N'S006', N'LV003', N'2026-01-06', N'Active'),
    (N'EN010', N'S007', N'LV001', N'2026-05-20', N'Active'),
    (N'EN011', N'S008', N'LV001', N'2026-01-04', N'Inactive'),
    (N'EN012', N'S009', N'LV002', N'2026-01-05', N'Active'),
    (N'EN013', N'S010', N'LV002', N'2026-10-05', N'Active'),
    (N'EN014', N'S011', N'LV001', N'2026-01-06', N'Blocked');
GO

PRINT N'Inserting StudentBadge (22 rows)...';
INSERT INTO dbo.[StudentBadge] ([studentBadgeId], [studentId], [badgeId], [earnedAt])
VALUES
    (N'SB001', N'S002', N'B001', N'2026-05-16 10:00:00'),
    (N'SB002', N'S002', N'B003', N'2026-05-17 11:30:00'),
    (N'SB003', N'S004', N'B001', N'2026-02-04 09:20:00'),
    (N'SB004', N'S004', N'B002', N'2026-04-04 14:10:00'),
    (N'SB005', N'S004', N'B003', N'2026-05-04 15:00:00'),
    (N'SB006', N'S004', N'B004', N'2026-08-04 12:00:00'),
    (N'SB007', N'S004', N'B005', N'2026-04-15 16:30:00'),
    (N'SB008', N'S005', N'B001', N'2026-05-02 10:00:00'),
    (N'SB009', N'S005', N'B002', N'2026-08-02 11:00:00'),
    (N'SB010', N'S005', N'B003', N'2026-10-02 13:00:00'),
    (N'SB011', N'S005', N'B004', N'2026-02-15 14:00:00'),
    (N'SB012', N'S005', N'B005', N'2026-02-20 15:00:00'),
    (N'SB013', N'S005', N'B006', N'2026-02-28 02:30:00'),
    (N'SB014', N'S006', N'B001', N'2026-02-01 09:00:00'),
    (N'SB015', N'S006', N'B002', N'2026-04-01 09:30:00'),
    (N'SB016', N'S006', N'B003', N'2026-06-01 10:00:00'),
    (N'SB017', N'S006', N'B004', N'2026-08-01 10:30:00'),
    (N'SB018', N'S006', N'B005', N'2026-06-15 02:00:00'),
    (N'SB019', N'S006', N'B006', N'2026-01-28 09:00:00'),
    (N'SB020', N'S006', N'B007', N'2026-01-29 10:00:00'),
    (N'SB021', N'S009', N'B009', N'2026-10-06 16:15:00'),
    (N'SB022', N'S010', N'B010', N'2026-12-06 09:00:00');
GO

PRINT N'Inserting QuizResult (22 rows)...';
INSERT INTO dbo.[QuizResult] ([resultId], [studentId], [quizId], [score], [totalMarks], [percentage], [resultStatus], [attemptNo], [attemptedDate])
VALUES
    (N'QR001', N'S005', N'Q001', 5, 5, 100, N'Passed', 1, N'2026-01-15 10:50:00'),
    (N'QR002', N'S005', N'Q003', 5, 5, 100, N'Passed', 1, N'2026-01-15 10:55:00'),
    (N'QR003', N'S005', N'Q006', 9, 10, 90, N'Passed', 1, N'2026-01-15 11:00:00'),
    (N'QR004', N'S005', N'Q007', 9, 13, 69.2, N'Passed', 1, N'2026-01-15 11:03:00'),
    (N'QR005', N'S005', N'Q009', 7, 12, 58.3, N'Passed', 1, N'2026-01-15 11:06:00'),
    (N'QR006', N'S005', N'Q010', 7, 7, 100, N'Passed', 1, N'2026-01-15 11:10:00'),
    (N'QR007', N'S005', N'Q014', 9, 9, 100, N'Passed', 1, N'2026-01-15 11:12:00'),
    (N'QR008', N'S005', N'Q048', 14, 18, 77.7, N'Passed', 1, N'2026-01-15 11:18:00'),
    (N'QR009', N'S006', N'Q001', 5, 5, 100, N'Passed', 1, N'2026-02-10 10:50:00'),
    (N'QR010', N'S006', N'Q003', 5, 5, 100, N'Passed', 1, N'2026-02-10 10:55:00'),
    (N'QR011', N'S006', N'Q006', 9, 10, 90, N'Passed', 1, N'2026-02-10 11:50:00'),
    (N'QR012', N'S006', N'Q007', 0, 13, 0, N'Failed', 1, N'2026-02-15 10:50:00'),
    (N'QR013', N'S006', N'Q007', 9, 13, 69.2, N'Passed', 2, N'2026-02-15 10:55:00'),
    (N'QR014', N'S006', N'Q009', 7, 12, 58.3, N'Passed', 1, N'2026-02-15 11:50:00'),
    (N'QR015', N'S006', N'Q010', 6, 7, 85.7, N'Passed', 1, N'2026-02-15 11:55:00'),
    (N'QR016', N'S006', N'Q014', 9, 9, 100, N'Passed', 1, N'2026-02-15 00:50:00'),
    (N'QR017', N'S006', N'Q048', 14, 18, 77.7, N'Passed', 1, N'2026-02-28 10:50:00'),
    (N'QR018', N'S006', N'Q024', 7, 7, 100, N'Passed', 1, N'2026-04-29 10:50:00'),
    (N'QR019', N'S006', N'Q049', 14, 19, 73.7, N'Passed', 1, N'2026-04-30 10:50:00'),
    (N'QR020', N'S006', N'Q043', 9, 9, 100, N'Passed', 1, N'2026-06-28 10:50:00'),
    (N'QR021', N'S006', N'Q050', 6, 9, 66.6, N'Failed', 1, N'2026-06-28 11:50:00'),
    (N'QR022', N'S006', N'Q050', 9, 9, 100, N'Passed', 2, N'2026-06-30 11:50:00');
GO

PRINT N'Inserting QuizAnswer (87 rows)...';
INSERT INTO dbo.[QuizAnswer] ([answerId], [resultId], [questionId], [selectedAnswer], [isCorrect], [marksAwarded])
VALUES
    (N'QA001', N'QR001', N'QST001', N'B', 1, 1),
    (N'QA002', N'QR001', N'QST002', N'A,B,D', 1, 3),
    (N'QA003', N'QR001', N'QST003', N'Tongue', 1, 1),
    (N'QA004', N'QR002', N'QST004', N'A', 1, 1),
    (N'QA005', N'QR002', N'QST005', N'A', 1, 1),
    (N'QA006', N'QR002', N'QST006', N'A,B,D', 1, 3),
    (N'QA007', N'QR003', N'QST017', N'C', 0, 0),
    (N'QA008', N'QR003', N'QST018', N'A', 1, 1),
    (N'QA009', N'QR003', N'QST019', N'A,B,C', 1, 3),
    (N'QA010', N'QR003', N'QST020', N'A', 1, 5),
    (N'QA011', N'QR004', N'QST012', N'C', 0, 0),
    (N'QA012', N'QR004', N'QST013', N'A', 1, 1),
    (N'QA013', N'QR004', N'QST014', N'A,C', 0, 0),
    (N'QA014', N'QR004', N'QST015', N'Repel', 1, 3),
    (N'QA015', N'QR004', N'QST016', N'A', 1, 5),
    (N'QA016', N'QR005', N'QST021', N'A', 1, 1),
    (N'QA017', N'QR005', N'QST022', N'A,B', 1, 3),
    (N'QA018', N'QR005', N'QST023', N'Waterproof', 1, 3),
    (N'QA019', N'QR005', N'QST024', N'B', 0, 0),
    (N'QA020', N'QR006', N'QST025', N'A', 1, 1),
    (N'QA021', N'QR006', N'QST026', N'A', 1, 1),
    (N'QA022', N'QR006', N'QST027', N'A', 1, 5),
    (N'QA023', N'QR007', N'QST028', N'A', 1, 1),
    (N'QA024', N'QR007', N'QST029', N'A', 1, 3),
    (N'QA025', N'QR007', N'QST030', N'C', 1, 5),
    (N'QA026', N'QR008', N'QST056', N'C', 1, 3),
    (N'QA027', N'QR008', N'QST057', N'T', 0, 0),
    (N'QA028', N'QR008', N'QST058', N'A', 1, 1),
    (N'QA029', N'QR008', N'QST059', N'D', 1, 5),
    (N'QA030', N'QR008', N'QST060', N'A', 0, 0),
    (N'QA031', N'QR008', N'QST061', N'C', 1, 5),
    (N'QA032', N'QR009', N'QST001', N'B', 1, 1),
    (N'QA033', N'QR009', N'QST002', N'A,B,D', 1, 3),
    (N'QA034', N'QR009', N'QST003', N'Tongue', 1, 1),
    (N'QA035', N'QR010', N'QST004', N'A', 1, 1),
    (N'QA036', N'QR010', N'QST005', N'A', 1, 1),
    (N'QA037', N'QR010', N'QST006', N'A,B,D', 1, 3),
    (N'QA038', N'QR011', N'QST017', N'C', 0, 0),
    (N'QA039', N'QR011', N'QST018', N'A', 1, 1),
    (N'QA040', N'QR011', N'QST019', N'A,B,C', 1, 3),
    (N'QA041', N'QR011', N'QST020', N'A', 1, 5),
    (N'QA042', N'QR012', N'QST012', N'B', 0, 0),
    (N'QA043', N'QR012', N'QST013', N'B', 1, 1),
    (N'QA044', N'QR012', N'QST014', N'A,D', 0, 0),
    (N'QA045', N'QR012', N'QST015', N'Repel', 1, 3),
    (N'QA046', N'QR012', N'QST016', N'D', 1, 5),
    (N'QA047', N'QR013', N'QST012', N'C', 0, 0),
    (N'QA048', N'QR013', N'QST013', N'A', 0, 0),
    (N'QA049', N'QR013', N'QST014', N'A,C', 0, 0),
    (N'QA050', N'QR013', N'QST015', N'Attract', 0, 0),
    (N'QA051', N'QR013', N'QST016', N'A', 0, 0),
    (N'QA052', N'QR014', N'QST021', N'A', 1, 1),
    (N'QA053', N'QR014', N'QST022', N'A,B', 1, 3),
    (N'QA054', N'QR014', N'QST023', N'Waterproof', 1, 3),
    (N'QA055', N'QR014', N'QST024', N'B', 0, 0),
    (N'QA056', N'QR015', N'QST025', N'A', 1, 1),
    (N'QA057', N'QR015', N'QST026', N'A', 0, 0),
    (N'QA058', N'QR015', N'QST027', N'A', 1, 5),
    (N'QA059', N'QR016', N'QST028', N'B', 0, 0),
    (N'QA060', N'QR016', N'QST029', N'B', 0, 0),
    (N'QA061', N'QR016', N'QST030', N'B', 0, 0),
    (N'QA062', N'QR016', N'QST028', N'A', 1, 1),
    (N'QA063', N'QR016', N'QST029', N'A', 1, 3),
    (N'QA064', N'QR016', N'QST030', N'C', 1, 5),
    (N'QA065', N'QR017', N'QST056', N'C', 1, 3),
    (N'QA066', N'QR017', N'QST057', N'T', 0, 0),
    (N'QA067', N'QR017', N'QST058', N'A', 1, 1),
    (N'QA068', N'QR017', N'QST059', N'D', 1, 5),
    (N'QA069', N'QR017', N'QST060', N'A', 0, 0),
    (N'QA070', N'QR017', N'QST061', N'C', 1, 5),
    (N'QA071', N'QR018', N'QST042', N'B', 1, 1),
    (N'QA072', N'QR018', N'QST043', N'A', 1, 1),
    (N'QA073', N'QR018', N'QST044', N'D', 1, 5),
    (N'QA074', N'QR019', N'QST064', N'A', 1, 3),
    (N'QA075', N'QR019', N'QST065', N'C,D', 1, 5),
    (N'QA076', N'QR019', N'QST066', N'B', 0, 0),
    (N'QA077', N'QR019', N'QST067', N'A', 1, 1),
    (N'QA078', N'QR019', N'QST068', N'D', 1, 5),
    (N'QA079', N'QR020', N'QST050', N'C', 1, 1),
    (N'QA080', N'QR020', N'QST051', N'A', 1, 3),
    (N'QA081', N'QR020', N'QST052', N'D', 1, 5),
    (N'QA082', N'QR021', N'QST069', N'A,D', 1, 3),
    (N'QA083', N'QR021', N'QST070', N'Switch', 1, 3),
    (N'QA084', N'QR021', N'QST071', N'B', 0, 0),
    (N'QA085', N'QR022', N'QST069', N'A,D', 1, 3),
    (N'QA086', N'QR022', N'QST070', N'Switch', 1, 3),
    (N'QA087', N'QR022', N'QST071', N'C', 1, 3);
GO

PRINT N'Inserting XPTransaction (19 rows)...';
INSERT INTO dbo.[XPTransaction] ([xpTransactionId], [studentId], [xpActionId], [xpAmount], [dateEarned])
VALUES
    (N'XPT001', N'S002', N'XP001', 10, N'2026-05-16'),
    (N'XPT002', N'S002', N'XP003', 10, N'2026-05-17'),
    (N'XPT003', N'S002', N'XP002', 15, N'2026-05-18'),
    (N'XPT004', N'S004', N'XP001', 10, N'2026-02-04'),
    (N'XPT005', N'S004', N'XP001', 10, N'2026-03-04'),
    (N'XPT006', N'S004', N'XP002', 15, N'2026-06-04'),
    (N'XPT007', N'S004', N'XP005', 20, N'2026-08-04'),
    (N'XPT008', N'S004', N'XP004', 25, N'2026-12-04'),
    (N'XPT009', N'S005', N'XP006', 40, N'2026-02-28'),
    (N'XPT010', N'S005', N'XP001', 10, N'2026-10-05'),
    (N'XPT011', N'S006', N'XP006', 40, N'2026-01-28'),
    (N'XPT012', N'S006', N'XP006', 40, N'2026-04-30'),
    (N'XPT013', N'S006', N'XP005', 20, N'2026-05-06'),
    (N'XPT014', N'S007', N'XP001', 10, N'2026-05-21'),
    (N'XPT015', N'S007', N'XP003', 10, N'2026-05-23'),
    (N'XPT016', N'S008', N'XP001', 10, N'2026-05-04'),
    (N'XPT017', N'S009', N'XP007', 5, N'2026-02-06'),
    (N'XPT018', N'S009', N'XP007', 5, N'2026-04-06'),
    (N'XPT019', N'S010', N'XP008', 15, N'2026-12-06');
GO

PRINT N'Inserting LessonProgress (26 rows)...';
INSERT INTO dbo.[LessonProgress] ([progressId], [studentId], [lessonId], [isCompleted], [completedDate])
VALUES
    (N'PR001', N'S002', N'LS001', 1, N'2026-05-16'),
    (N'PR002', N'S002', N'LS002', 1, N'2026-05-17'),
    (N'PR003', N'S002', N'LS003', 0, NULL),
    (N'PR004', N'S004', N'LS001', 1, N'2026-02-04'),
    (N'PR005', N'S004', N'LS002', 1, N'2026-03-04'),
    (N'PR006', N'S004', N'LS003', 1, N'2026-04-04'),
    (N'PR007', N'S004', N'LS004', 1, N'2026-05-04'),
    (N'PR008', N'S004', N'LS005', 1, N'2026-06-04'),
    (N'PR009', N'S004', N'LS006', 1, N'2026-07-04'),
    (N'PR010', N'S005', N'LS001', 1, N'2026-02-02'),
    (N'PR011', N'S005', N'LS002', 1, N'2026-03-02'),
    (N'PR012', N'S005', N'LS003', 1, N'2026-04-02'),
    (N'PR013', N'S005', N'LS007', 1, N'2026-10-05'),
    (N'PR014', N'S005', N'LS008', 0, NULL),
    (N'PR015', N'S006', N'LS001', 1, N'2026-02-01'),
    (N'PR016', N'S006', N'LS002', 1, N'2026-03-01'),
    (N'PR017', N'S006', N'LS003', 1, N'2026-04-01'),
    (N'PR018', N'S006', N'LS007', 1, N'2026-03-03'),
    (N'PR019', N'S006', N'LS008', 1, N'2026-04-03'),
    (N'PR020', N'S007', N'LS001', 1, N'2026-05-21'),
    (N'PR021', N'S007', N'LS002', 0, NULL),
    (N'PR022', N'S008', N'LS001', 1, N'2026-05-04'),
    (N'PR023', N'S009', N'LS007', 1, N'2026-02-06'),
    (N'PR024', N'S009', N'LS008', 1, N'2026-03-06'),
    (N'PR025', N'S010', N'LS007', 1, N'2026-05-06'),
    (N'PR026', N'S010', N'LS008', 0, NULL);
GO

PRINT N'Inserting Certificate (4 rows)...';
INSERT INTO dbo.[Certificate] ([certificateId], [studentId], [levelId], [certificateTitleEN], [certificateTitleBM], [certificateDescriptionEN], [certificateDescriptionBM], [issuedDate], [certificateUrl], [certificateCode], [status])
VALUES
    (N'CERT001', N'S005', N'LV001', N'Beginner Science Completion Certificate', N'Sijil Tamat Sains Pemula', N'Awarded for successfully completing all Beginner Science learning units and meeting the minimum passing requirements.', N'Dianugerahkan kerana berjaya menamatkan semua unit pembelajaran Sains Pemula dan memenuhi syarat kelulusan minimum.', N'2026-01-28', N'Images/Certificate/cert_s005_lv001.pdf', N'SCI-BEG-S005', N'Active'),
    (N'CERT002', N'S006', N'LV001', N'Beginner Science Completion Certificate', N'Sijil Tamat Sains Pemula', N'Awarded for successfully completing all Beginner Science learning units and meeting the minimum passing requirements.', N'Dianugerahkan kerana berjaya menamatkan semua unit pembelajaran Sains Pemula dan memenuhi syarat kelulusan minimum.', N'2026-02-28', N'Images/Certificate/cert_s006_lv001.pdf', N'SCI-BEG-S006', N'Active'),
    (N'CERT003', N'S006', N'LV002', N'Intermediate Science Completion Certificate', N'Sijil Tamat Sains Pertengahan', N'Awarded for successfully completing all Intermediate Science learning units and achieving the required passing score.', N'Dianugerahkan kerana berjaya menamatkan semua unit pembelajaran Sains Pemula dan memenuhi syarat kelulusan minimum.', N'2026-04-30', N'Images/Certificate/cert_s006_lv002.pdf', N'SCI-INT-S006', N'Active'),
    (N'CERT004', N'S006', N'LV003', N'Advanced Science Completion Certificate', N'Sijil Tamat Sains Lanjutan', N'Awarded for successfully completing all Advanced Science learning units and demonstrating mastery of advanced science concepts.', N'Dianugerahkan kerana berjaya menamatkan semua unit pembelajaran Sains Lanjutan dan menunjukkan penguasaan konsep sains lanjutan.', N'2026-06-30', N'Images/Certificate/cert_s006_lv003.pdf', N'SCI-ADV-S006', N'Active');
GO

PRINT N'Inserting Log (20 rows)...';
INSERT INTO dbo.[Log] ([logId], [userId], [action], [description], [logDateTime], [status])
VALUES
    (N'LOG001', N'U002', N'Login', N'User logged into the system successfully.', N'2026-05-16 08:05:00', N'Success'),
    (N'LOG002', N'U018', N'Failed Login', N'Incorrect password entered. Attempt 1 of 3.', N'2026-06-14 07:55:43', N'Failed'),
    (N'LOG003', N'U018', N'Failed Login', N'Incorrect password entered. Attempt 2 of 3.', N'2026-06-14 07:57:43', N'Failed'),
    (N'LOG004', N'U018', N'Suspicious Login Attempt', N'Maximum failed login attempts reached.', N'2026-06-14 08:00:20', N'Warning'),
    (N'LOG005', N'U018', N'Account Locked', N'Account temporarily locked for 30 minutes.', N'2026-06-14 08:00:21', N'Success'),
    (N'LOG006', N'U002', N'Quiz Completed', N'Completed quiz Q001.', N'2026-05-16 08:30:20', N'Success'),
    (N'LOG007', N'U003', N'Badge Earned', N'Earned badge B001.', N'2026-05-20 10:00:37', N'Success'),
    (N'LOG008', N'U016', N'Forum Created', N'Created forum discussion F013.', N'2026-06-06 10:00:10', N'Success'),
    (N'LOG009', N'U016', N'Forum Message Sent', N'Posted a message in forum discussion.', N'2026-06-06 10:05:20', N'Success'),
    (N'LOG010', N'U017', N'Live Session Joined', N'Joined consultation session S001.', N'2026-06-13 10:00:44', N'Success'),
    (N'LOG011', N'U022', N'Material Uploaded', N'Uploaded material M001 for review.', N'2026-01-28 09:33:54', N'Success'),
    (N'LOG012', N'U001', N'Teacher Approved', N'Approved teacher registration T002.', N'2026-03-18 09:45:20', N'Success'),
    (N'LOG013', N'U001', N'Content Request Approved', N'Approved content request CR001.', N'2026-01-28 11:30:20', N'Success'),
    (N'LOG014', N'U001', N'Content Request Rejected', N'Rejected content request CR002.', N'2026-02-15 15:28:10', N'Success'),
    (N'LOG015', N'U001', N'Lesson Updated', N'Updated lesson LS021.', N'2026-06-20 10:00:02', N'Success'),
    (N'LOG016', N'U001', N'Quiz Updated', N'Updated quiz Q004 settings.', N'2026-06-20 10:30:54', N'Success'),
    (N'LOG017', N'U001', N'Configuration Updated', N'Updated Passing Mark Percentage to 50.', N'2026-06-25 10:15:50', N'Success'),
    (N'LOG018', N'U001', N'Security Setting', N'Updated Account Lock Duration to 30 minutes.', N'2026-06-25 10:30:20', N'Success'),
    (N'LOG019', N'U001', N'Notification Sent', N'Sent notification to all students.', N'2026-06-25 14:45:17', N'Success'),
    (N'LOG020', N'U002', N'Logout', N'User logged out from the system.', N'2026-05-16 09:30:43', N'Success');
GO

PRINT N'Inserting Notification (15 rows)...';
INSERT INTO dbo.[Notification] ([notificationId], [toUserId], [titleEN], [titleBM], [messageEN], [messageBM], [isRead], [createdAt])
VALUES
    (N'N001', N'U002', N'Welcome to ScienceBuddy', N'Selamat Datang ke ScienceBuddy', N'Start your first lesson today.', N'Mulakan pelajaran pertama anda hari ini.', 0, N'2026-06-15 21:15:51'),
    (N'N002', N'U003', N'Quiz Completed', N'Kuiz Selesai', N'You passed your quiz.', N'Anda telah lulus kuiz anda.', 1, N'2026-06-11 12:17:18'),
    (N'N003', N'U011', N'New Badge Earned', N'Lencana Baharu Diperoleh', N'You earned High Scorer.', N'Anda memperoleh Skor Cemerlang.', 0, N'2026-06-13 03:31:36'),
    (N'N004', N'U012', N'New Level Unlocked', N'Tahap Baharu Dibuka', N'Intermediate level is now available.', N'Tahap Pertengahan kini tersedia.', 1, N'2026-06-15 15:58:21'),
    (N'N005', N'U013', N'Certificate Ready', N'Sijil Sedia', N'Your certificate is ready to download.', N'Sijil anda sedia untuk dimuat turun.', 0, N'2026-06-14 06:26:41'),
    (N'N006', N'U014', N'Study Reminder', N'Peringatan Belajar', N'Please revise your weak topics.', N'Sila ulang kaji topik lemah anda.', 0, N'2026-06-08 08:24:26'),
    (N'N007', N'U015', N'Come Back Soon', N'Kembali Semula', N'Continue your ScienceBuddy journey.', N'Teruskan perjalanan ScienceBuddy anda.', 0, N'2026-06-09 02:54:13'),
    (N'N008', N'U016', N'Forum Reply', N'Balasan Forum', N'Someone replied to your discussion.', N'Seseorang membalas perbincangan anda.', 0, N'2026-06-13 23:50:51'),
    (N'N009', N'U017', N'Live Session Reminder', N'Peringatan Sesi Langsung', N'Your live session starts soon.', N'Sesi langsung anda akan bermula.', 1, N'2026-06-04 07:53:25'),
    (N'N010', N'U018', N'Account Blocked', N'Akaun Disekat', N'Your account is currently blocked.', N'Akaun anda sedang disekat.', 0, N'2026-06-07 00:13:12'),
    (N'N011', N'U005', N'Your child replied to a discussion.', N'Anak Anda Membalas Perbincangan', N'Your account is currently blocked.', N'Akaun anda sedang disekat.', 0, N'2026-06-05 14:00:49'),
    (N'N012', N'U014', N'Your parent replied to a discussion.', N'Ibu Bapa Anda Membalas Perbincangan', N'Your account is currently blocked.', N'Akaun anda sedang disekat.', 0, N'2026-06-03 02:35:44'),
    (N'N013', N'U016', N'Forum Reply', N'Balasan Forum', N'Someone replied to your discussion.', N'Seseorang membalas perbincangan anda.', 0, N'2026-06-09 06:15:53'),
    (N'N014', N'U015', N'Forum Reply', N'Balasan Forum', N'Someone replied to your discussion.', N'Seseorang membalas perbincangan anda.', 0, N'2026-06-06 22:09:47'),
    (N'N015', N'U004', N'New Parent Discussion', N'Perbincangan Baharu Ibu Bapa Dimulakan', N'Your parent started a discussion with a forum post.', N'Ibu/bapa anda telah memulakan perbincangan dengan memuatnaik forum baharu.', 0, N'2026-06-02 18:16:08');
GO

PRINT N'Inserting LabProgress (12 rows)...';
INSERT INTO dbo.[LabProgress] ([labProgressId], [studentId], [labId], [isCompleted], [completedDate])
VALUES
    (N'LABP001', N'S002', N'LAB001', 1, N'2026-05-18'),
    (N'LABP002', N'S004', N'LAB001', 1, N'2026-06-04'),
    (N'LABP003', N'S004', N'LAB002', 1, N'2026-10-04'),
    (N'LABP004', N'S005', N'LAB001', 1, N'2026-10-02'),
    (N'LABP005', N'S005', N'LAB003', 0, NULL),
    (N'LABP006', N'S006', N'LAB001', 1, N'2026-05-01'),
    (N'LABP007', N'S006', N'LAB002', 1, N'2026-06-07'),
    (N'LABP008', N'S006', N'LAB003', 1, N'2026-10-06'),
    (N'LABP009', N'S007', N'LAB001', 1, N'2026-06-02'),
    (N'LABP010', N'S008', N'LAB001', 0, NULL),
    (N'LABP011', N'S009', N'LAB003', 1, N'2026-07-06'),
    (N'LABP012', N'S010', N'LAB003', 1, N'2026-09-06');
GO

PRINT N'Inserting LiveConsultationSession (6 rows)...';
INSERT INTO dbo.[LiveConsultationSession] ([sessionId], [teacherId], [unitId], [subtopicId], [sessionTitle], [sessionDescription], [meetingLink], [startDateTime], [endDateTime], [status])
VALUES
    (N'LIVE001', N'T004', N'UN201', N'ST211', N'Healthy Teeth Workshop', N'Learn how to maintain healthy teeth through proper habits.', N'https://meet.google.com/tth-sci-teeth', N'2026-01-20 10:00:00', N'2026-01-20 12:00:00', N'Completed'),
    (N'LIVE002', N'T004', N'UN202', N'ST221', N'Float and Sink Experiment', N'Live demonstration of floating and sinking objects.', N'https://meet.google.com/tth-float-sink', N'2026-02-13 14:00:00', N'2026-02-13 15:00:00', N'Completed'),
    (N'LIVE003', N'T005', N'UN104', N'ST141', N'Meneroka Bentuk Muka Bumi', N'Kenali gunung, lembah, pantai dan pelbagai bentuk muka bumi melalui contoh visual.', N'https://meet.google.com/tth-landforms', N'2026-05-20 14:30:00', N'2026-05-20 16:30:00', N'Completed'),
    (N'LIVE004', N'T006', N'UN303', N'ST314', N'Journey of Blood Through the Body', N'Follow the pathway of blood as it travels through the circulatory system.', N'https://meet.google.com/tth-blood-pathway', N'2026-08-20 09:30:00', N'2026-08-20 11:00:00', N'Upcoming'),
    (N'LIVE005', N'T002', N'UN202', N'ST212', N'Building a Healthy Plate', N'Learn how different food groups contribute to a balanced diet.', N'https://meet.google.com/tth-balanced-diet', N'2026-08-30 10:10:00', N'2026-08-30 11:10:00', N'Upcoming'),
    (N'LIVE006', N'T004', N'UN301', N'ST311', N'Memahami Sistem Rangka Manusia', N'Pelajari fungsi tulang dan bagaimana sistem rangka menyokong badan.', N'https://meet.google.com/tth-skeleton-support', N'2026-09-15 09:00:00', N'2026-09-15 10:15:00', N'Upcoming');
GO

PRINT N'Inserting LiveSessionParticipant (12 rows)...';
INSERT INTO dbo.[LiveSessionParticipant] ([participantId], [sessionId], [studentId], [joinedAt])
VALUES
    (N'LIVEP001', N'LIVE001', N'S010', N'2026-01-20 10:05:00'),
    (N'LIVEP002', N'LIVE001', N'S009', N'2026-01-20 10:05:00'),
    (N'LIVEP003', N'LIVE001', N'S005', N'2026-01-20 10:20:00'),
    (N'LIVEP004', N'LIVE001', N'S007', N'2026-01-20 10:35:12'),
    (N'LIVEP005', N'LIVE002', N'S010', N'2026-02-13 14:15:20'),
    (N'LIVEP006', N'LIVE002', N'S002', N'2026-02-13 14:20:30'),
    (N'LIVEP007', N'LIVE002', N'S004', N'2026-02-13 14:30:45'),
    (N'LIVEP008', N'LIVE002', N'S006', N'2026-02-13 14:40:50'),
    (N'LIVEP009', N'LIVE003', N'S010', N'2026-05-20 14:38:41'),
    (N'LIVEP010', N'LIVE003', N'S005', N'2026-05-20 15:01:41'),
    (N'LIVEP011', N'LIVE003', N'S002', N'2026-05-20 15:20:41'),
    (N'LIVEP012', N'LIVE003', N'S010', N'2026-05-20 16:05:01');
GO

PRINT N'Inserting UserStatusAction (5 rows)...';
INSERT INTO dbo.[UserStatusAction] ([actionId], [userId], [actionType], [reason], [actionDate], [performedBy])
VALUES
    (N'US001', N'U018', N'Blocked', N'Suspicious login attempts exceeded limit.', N'2026-06-14', N'U001'),
    (N'US002', N'U018', N'Unblocked', N'Account lock duration completed and account restored.', N'2026-06-14', N'U001'),
    (N'US003', N'U004', N'Deleted', N'User requested account deletion.', N'2026-05-30', N'U001'),
    (N'US004', N'U024', N'Blocked', N'Teacher certification rejected.', N'2026-04-07', N'U001'),
    (N'US005', N'U024', N'Unblocked', N'Teacher submitted updated certification documents.', N'2026-04-20', N'U001');
GO

PRINT N'Inserting AILearningAnalysis (8 rows)...';
INSERT INTO dbo.[AILearningAnalysis] ([analysisId], [studentId], [analysisJson], [overallSummary], [strongTopics], [weakTopics], [avgQuizScore], [totalQuizAttempts], [isLatest])
VALUES
    (N'A001', N'S002', NULL, N'Student is progressing steadily in Beginner level.', N'Basic science concepts', N'Scientific method', 65, 2, 1),
    (N'A002', N'S004', NULL, N'Student performs excellently and is ready for level completion.', N'Scientific method, Matter, Energy', N'None', 90, 3, 1),
    (N'A003', N'S005', NULL, N'Student completed Beginner level and is adapting to Intermediate topics.', N'Beginner concepts', N'Forces and electricity', 65, 2, 1),
    (N'A004', N'S006', NULL, N'Student shows strong performance across all levels.', N'Matter, Energy, Electricity', N'None', 95, 2, 1),
    (N'A005', N'S007', NULL, N'Student is struggling and needs revision support.', N'Basic observation', N'Matter, Scientific method, Quiz confidence', 30, 3, 1),
    (N'A006', N'S008', NULL, N'Student has limited recent activity.', N'Basic introduction', N'Consistency', 50, 1, 1),
    (N'A007', N'S009', NULL, N'Student learns well through discussion and collaboration.', N'Forum discussion, explanation', N'Calculation questions', 80, 1, 1),
    (N'A008', N'S010', NULL, N'Student benefits from live session participation.', N'Guided learning', N'Independent quiz practice', 70, 1, 1);
GO

PRINT N'Inserting StudyPlan (7 rows)...';
INSERT INTO dbo.[StudyPlan] ([studyPlanId], [studentParentId], [createdByUserId], [planTitle], [startDate], [endDate], [status], [createdAt])
VALUES
    (N'STP001', N'SP002', N'U006', N'Siti Human Revision Plan', N'2026-06-10', N'2026-06-16', N'Ongoing', N'2026-06-10 19:00:00'),
    (N'STP002', N'SP003', N'U002', N'This Week', N'2026-06-01', N'2026-06-08', N'Ongoing', N'2026-06-01 15:21:00'),
    (N'STP003', N'SP006', N'U005', N'Hana Weak Topic Support Plan', N'2026-06-02', N'2026-06-09', N'Completed', N'2026-06-02 20:15:00'),
    (N'STP004', N'SP005', N'U012', N'Maya Intermediate Practice', N'2026-06-11', N'2026-06-16', N'Ongoing', N'2026-06-11 16:30:00'),
    (N'STP005', NULL, N'U013', N'Advanced Electricity Revision plan', N'2026-06-12', N'2026-06-16', N'Ongoing', N'2026-06-12 18:00:00'),
    (N'STP006', N'SP007', N'U016', N'Qistina Forum and Quiz Plan', N'2026-12-06', N'2026-12-13', N'Ongoing', N'2026-12-05 15:10:00'),
    (N'STP007', N'SP008', N'U005', N'Rayyan Live Session Plan', N'2026-05-07', N'2026-05-14', N'Completed', N'2026-06-02 15:10:00');
GO

PRINT N'Inserting SPTask (19 rows)...';
INSERT INTO dbo.[SPTask] ([spTaskId], [studyPlanId], [taskTitle], [suggestedAction], [orderNo], [isCompleted], [completedAt])
VALUES
    (N'SPT001', N'STP001', N'Review Human Sense Lesson', N'Read notes about the five human senses.', 1, 1, N'2026-06-10 20:00:00'),
    (N'SPT002', N'STP001', N'Classify taste examples', N'Extra revision', 2, 0, NULL),
    (N'SPT003', N'STP001', N'Attempt Human Sense Quiz', N'Complete quiz after revision', 3, 0, NULL),
    (N'SPT004', N'STP002', N'Archived deleted user task', N'Keep for deleted user filtering test', 1, 0, NULL),
    (N'SPT005', N'STP002', N'Archived parent reminder', N'Keep old deleted parent-child record', 2, 0, NULL),
    (N'SPT006', N'STP003', N'Rewatch weak topic video', N'Review difficult topic before quiz retry', 1, 1, N'2026-06-03 18:00:00'),
    (N'SPT007', N'STP003', N'Retry failed quiz', N'Attempt quiz again after revision', 2, 1, N'2026-06-05 19:00:00'),
    (N'SPT008', N'STP003', N'Teacher checking', N'Get teacher to review answers', 3, 1, N'2026-06-08 20:00:00'),
    (N'SPT009', N'STP004', N'Revise Density topic', N'Read Float and Sink notes', 1, 1, N'2026-06-12 17:00:00'),
    (N'SPT010', N'STP004', N'Complete Density practice', N'Answer practice questions', 2, 0, NULL),
    (N'SPT011', N'STP004', N'Do lab task', N'Do lab task over practice quizzes for better understanding', 3, 0, NULL),
    (N'SPT013', N'STP005', N'Review Series Circuits', N'Study advanced electricity notes', 1, 1, N'2026-06-12 19:00:00'),
    (N'SPT014', N'STP005', N'Complete Circuit Symbols', N'Match symbols with circuit parts', 2, 1, N'2026-06-13 17:30:00'),
    (N'SPT015', N'STP005', N'Attempt Electricity Quiz', N'Score at least 80%', 3, 0, NULL),
    (N'SPT016', N'STP006', N'Write revision notes', N'Summarise facts using written notes', 1, 1, N'2026-06-13 23:00:00'),
    (N'SPT017', N'STP006', N'Reply in Forum', N'Help another student', 2, 1, N'2026-06-13 12:15:00'),
    (N'SPT018', N'STP007', N'Attend Live Session', N'Join teacher consultation session', 1, 1, N'2026-12-06 15:00:00'),
    (N'SPT019', N'STP007', N'Review session notes', N'Read notes after live session', 2, 1, N'2026-12-07 10:00:00'),
    (N'SPT020', N'STP007', N'Write reflection', N'List three things learned', 3, 1, N'2026-12-10 11:00:00');
GO

PRINT N'Inserting SPReward (12 rows)...';
INSERT INTO dbo.[SPReward] ([rewardId], [studyPlanId], [rewardName], [requiredProgress], [isUnlocked], [unlockedAt])
VALUES
    (N'SPR001', N'STP001', N'Extra Screentime (2 hours)', 25, 1, N'2026-05-05 18:22:13'),
    (N'SPR002', N'STP001', N'Watch "Spiderman" at the movies', 50, 1, N'2026-05-08 22:10:10'),
    (N'SPR003', N'STP002', N'McDonalds', 25, 1, N'2026-05-17 16:10:10'),
    (N'SPR004', N'STP002', N'Trip to ToysRUs', 50, 0, NULL),
    (N'SPR005', N'STP002', N'Secret Recipe Cake', 100, 0, NULL),
    (N'SPR006', N'STP003', N'New toy', 50, 0, NULL),
    (N'SPR007', N'STP004', N'New Science Sticker Set', 50, 1, N'2026-10-04 00:00:00'),
    (N'SPR008', N'STP004', N'Ice Cream Treat', 100, 1, N'2026-06-18 00:00:00'),
    (N'SPR009', N'STP005', N'1 Hour Game Time', 50, 0, NULL),
    (N'SPR010', N'STP006', N'Favourite Snack', 50, 0, NULL),
    (N'SPR011', N'STP007', N'Buy New Notebook', 50, 1, N'2026-12-07 12:50:00'),
    (N'SPR012', N'STP007', N'Weekend Movie Night', 100, 1, N'2026-12-13 09:10:00');
GO

PRINT N'Inserting userChat (11 rows)...';
INSERT INTO dbo.[userChat] ([chatId], [userId], [user2Id], [createdAt])
VALUES
    (N'C001', N'U002', N'U008', N'2026-05-06 10:00:00'),
    (N'C002', N'U003', N'U008', N'2026-06-03 14:00:00'),
    (N'C003', N'U003', N'U009', N'2026-06-15 20:00:00'),
    (N'C004', N'U004', N'U010', N'2026-06-16 08:00:00'),
    (N'C005', N'U005', N'U008', N'2026-06-17 09:00:00'),
    (N'C006', N'U005', N'U010', N'2026-06-19 08:00:00'),
    (N'C007', N'U006', N'U009', N'2026-06-21 15:00:00'),
    (N'C008', N'U007', N'U008', N'2026-06-26 16:00:00'),
    (N'C009', N'U007', N'U009', N'2026-07-02 15:00:00'),
    (N'C010', N'U013', N'U022', N'2026-07-15 10:20:15'),
    (N'C011', N'U022', N'U005', N'2026-07-30 11:12:12');
GO

PRINT N'Inserting privateMessage (16 rows)...';
INSERT INTO dbo.[privateMessage] ([privateMsgId], [chatId], [senderUserId], [msgText], [attachmentFile], [sentAt], [isRead], [readAt])
VALUES
    (N'PM001', N'C001', N'U002', N'Can you checkout my answers I wrote on paper?', N'Images/PrivateMessage/answer.pdf', N'2026-07-04 10:00:00', 1, N'2026-07-04 14:00:00'),
    (N'PM002', N'C001', N'U008', N'Sure! Question 2 and 3 is wrong.', NULL, N'2026-07-03 00:00:55', 0, NULL),
    (N'PM003', N'C002', N'U003', N'Miss, I think the answer for question 4 is wrong.', NULL, N'2026-07-07 09:00:00', 1, N'2026-07-07 11:00:00'),
    (N'PM004', N'C002', N'U008', N'OH, you''re right!', NULL, N'2026-07-10 03:00:00', 1, N'2026-07-10 08:00:00'),
    (N'PM005', N'C002', N'U003', N'No problem miss.', NULL, N'2026-07-10 00:00:50', 0, NULL),
    (N'PM006', N'C003', N'U003', N'When is the next live session?', NULL, N'2026-06-11 11:00:00', 1, N'2026-06-11 11:30:00'),
    (N'PM007', N'C003', N'U009', N'We have not scheduled it yet, sorry but around this week.', NULL, N'2026-06-12 10:00:00', 1, N'2026-06-12 10:30:00'),
    (N'PM008', N'C003', N'U003', N'I understand.', NULL, N'2026-06-13 00:30:00', 0, NULL),
    (N'PM009', N'C004', N'U004', N'Teacher, I am struggling with the notes.', NULL, N'2026-06-14 08:00:00', 1, N'2026-06-14 09:00:00'),
    (N'PM010', N'C004', N'U010', N'No problem, I will any questions you have.', NULL, N'2026-06-15 00:55:00', 0, NULL),
    (N'PM011', N'C010', N'U013', N'Teacher, I don''t understand why a magnet can attract some metals but not others.', NULL, N'2026-06-16 09:00:00', 1, N'2026-06-16 10:00:00'),
    (N'PM012', N'C010', N'U022', N'Magnets only attract certain metals such as iron, nickel and cobalt. Not all metals have magnetic properties.', NULL, N'2026-06-17 11:00:00', 1, N'2026-06-17 11:10:00'),
    (N'PM013', N'C010', N'U013', N'Oh, I understand now. Thank you, teacher!', NULL, N'2026-06-18 10:00:00', 1, N'2026-06-18 11:00:00'),
    (N'PM014', N'C011', N'U005', N'Assalamualaikum cikgu. Anak saya terlepas sesi konsultasi minggu lepas. Adakah akan ada sesi lagi?', NULL, N'2026-07-30 11:12:12', 1, N'2026-07-30 11:30:12'),
    (N'PM015', N'C011', N'U022', N'Waalaikumsalam. Ya, akan ada sesi tambahan minggu hadapan untuk topik yang sama.', NULL, N'2026-07-30 13:30:12', 1, N'2026-07-30 15:10:10'),
    (N'PM016', N'C011', N'U005', N'Alhamdulillah, terima kasih cikgu.', NULL, N'2026-07-30 13:45:50', 1, N'2026-07-30 14:21:12');
GO

