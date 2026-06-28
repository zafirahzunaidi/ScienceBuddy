/* ScienceBuddy_DB - InsertConstants.sql
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

PRINT N'Inserting Level (3 rows)...';
INSERT INTO dbo.[Level] ([levelId], [levelNameEN], [levelNameBM], [levelDescriptionEN], [levelDescriptionBM])
VALUES
    (N'LV001', N'Beginner', N'Pemula', N'Suitable for students who are starting to learn basic Science concepts.', N'Sesuai untuk murid yang baru mula mempelajari konsep asas Sains.'),
    (N'LV002', N'Intermediate', N'Pertengahan', N'Suitable for students who have basic Science understanding and are ready for more detailed topics.', N'Sesuai untuk murid yang mempunyai kefahaman asas Sains dan bersedia untuk topik yang lebih terperinci.'),
    (N'LV003', N'Advanced', N'Lanjutan', N'Suitable for students who are ready to explore more challenging Science concepts and assessments.', N'Sesuai untuk murid yang bersedia meneroka konsep dan penilaian Sains yang lebih mencabar.');
GO

PRINT N'Inserting Personality (6 rows)...';
INSERT INTO dbo.[Personality] ([personalityId], [personalityNameEN], [personalityNameBM], [descriptionEN], [descriptionBM], [avatar], [colour], [learningStyleEN], [learningStyleBM])
VALUES
    (N'P001', N'Achiever', N'Pencapai', N'A goal-oriented learner who enjoys progress, rewards, badges, and completing learning targets.', N'Murid yang berorientasikan matlamat dan suka melihat kemajuan, ganjaran, lencana serta menyelesaikan sasaran pembelajaran.', N'Images/Personality/achiever.png', N'#F5B041', N'Goal-based learning', N'Pembelajaran berasaskan matlamat'),
    (N'P002', N'Creative', N'Kreatif', N'A visual and imaginative learner who enjoys colourful notes, flashcards, videos, and virtual lab activities.', N'Murid yang visual dan imaginatif serta suka nota berwarna, kad imbas, video dan aktiviti makmal maya.', N'Images/Personality/creative.png', N'#9B59B6', N'Visual and interactive learning', N'Pembelajaran visual dan interaktif'),
    (N'P003', N'Thinker', N'Pemikir', N'A curious learner who enjoys understanding reasons, reviewing explanations, and analysing weak topics.', N'Murid yang ingin tahu dan suka memahami sebab, menyemak penerangan serta menganalisis topik lemah.', N'Images/Personality/thinker.png', N'#3498DB', N'Explanation-based learning', N'Pembelajaran berasaskan penerangan'),
    (N'P004', N'Go-Getter', N'Bersemangat', N'An active learner who enjoys challenges, quizzes, leaderboard ranking, and fast progress.', N'Murid yang aktif dan suka cabaran, kuiz, kedudukan papan markah serta kemajuan yang cepat.', N'Images/Personality/gogetter.png', N'#E74C3C', N'Challenge-based learning', N'Pembelajaran berasaskan cabaran'),
    (N'P005', N'Chill Learner', N'Santai', N'A calm learner who prefers step-by-step learning, gentle reminders, and stress-free activities.', N'Murid yang tenang dan lebih suka pembelajaran langkah demi langkah, peringatan lembut dan aktiviti tanpa tekanan.', N'Images/Personality/chill-learner.png', N'#58D68D', N'Step-by-step learning', N'Pembelajaran langkah demi langkah'),
    (N'P006', N'Socializer', N'Sosial', N'A collaborative learner who enjoys discussions, teacher guidance, live sessions, and learning with others.', N'Murid yang suka bekerjasama melalui perbincangan, bimbingan guru, sesi langsung dan pembelajaran bersama orang lain.', N'Images/Personality/socializer.png', N'#F39C12', N'Collaborative learning', N'Pembelajaran kolaboratif');
GO

PRINT N'Inserting Badge (10 rows)...';
INSERT INTO dbo.[Badge] ([badgeId], [badgeNameEN], [badgeNameBM], [badgeType], [xpReward], [badgeIcon], [requirementDescriptionEN], [requirementDescriptionBM], [badgeDescriptionEN], [badgeDescriptionBM])
VALUES
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
GO

PRINT N'Inserting Unit (15 rows)...';
INSERT INTO dbo.[Unit] ([unitId], [levelId], [unitNameEN], [unitNameBM], [unitDescriptionEN], [unitDescriptionBM], [orderNo])
VALUES
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
GO

PRINT N'Inserting Subtopic (44 rows)...';
INSERT INTO dbo.[Subtopic] ([subtopicId], [unitId], [subtopicTitleEN], [subtopicTitleBM], [subtopicDescriptionEN], [subtopicDescriptionBM], [orderNo])
VALUES
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
GO

PRINT N'Inserting Lesson (81 rows)...';
INSERT INTO dbo.[Lesson] ([lessonId], [subtopicId], [lessonTitleEN], [lessonTitleBM], [lessonContentEN], [lessonContentBM], [attachmentUrl], [orderNo])
VALUES
    (N'LS001', N'ST111', N'Human Sense', N'Deria Manusia', N'Humans use five senses to understand the world around them. The senses are sight, hearing, smell, taste and touch.', N'Manusia menggunakan lima deria untuk memahami dunia sekeliling. Deria tersebut ialah penglihatan, pendengaran, bau, rasa dan sentuhan.', N'Images/Lesson/humansense.png', 1),
    (N'LS002', N'ST112', N'Classify Taste', N'Mengelaskan Rasa', N'Taste helps us identify different flavours such as sweet, sour, bitter and salty.', N'Deria rasa membantu kita mengenal pasti rasa seperti manis, masam, pahit dan masin.', N'Images/Lesson/taste.mp4', 1),
    (N'LS003', N'ST113', N'The Use of Human Sense', N'Kegunaan Deria Manusia', N'Human senses help us perform daily activities safely and effectively.', N'Deria manusia membantu kita menjalankan aktiviti harian dengan selamat dan berkesan.', N'Images/Lesson/useofhumansense.mp4', 1),
    (N'LS004', N'ST121', N'Uses of Magnets', N'Kegunaan Magnet', N'Magnets are used in daily life such as in refrigerators, compasses and speakers.', N'Magnet digunakan dalam kehidupan harian seperti peti sejuk, kompas dan pembesar suara.', N'Images/Lesson/magnets.mp4', 1),
    (N'LS005', N'ST122', N'Shapes of Magnets', N'Bentuk Magnet', N'Magnets come in various shapes including bar magnets, horseshoe magnets and ring magnets.', N'Magnet mempunyai pelbagai bentuk seperti magnet bar, magnet ladam dan magnet cincin.', N'Images/Lesson/magnetshape.png', 1),
    (N'LS006', N'ST123', N'Attraction and Repulsion of Magnets', N'Tarikan dan Tolakan Magnet', N'Like poles repel each other while unlike poles attract each other.', N'Kutub yang sama menolak antara satu sama lain manakala kutub berlainan saling menarik.', N'Images/Lesson/attractmagnet.png', 1),
    (N'LS007', N'ST131', N'Water Absorbent vs Non-Water Absorbent', N'Objek Menyerap Air, Objek Tidak Menyerap Air', N'Some materials absorb water while others do not absorb water.', N'Sesetengah bahan menyerap air manakala yang lain tidak menyerap air.', N'Images/Lesson/waterabsorption.mp4', 1),
    (N'LS008', N'ST132', N'Importance of Water Absorbent and Non-Water Absorbent', N'Kepentingan Objek Menyerap dan Objek Tidak Menyerap Air', N'Different materials are chosen based on their ability to absorb water.', N'Bahan yang berbeza dipilih berdasarkan keupayaannya menyerap air.', N'Images/Lesson/absorbvsnon.jpeg', 1),
    (N'LS009', N'ST141', N'Landforms', N'Bentuk Muka Bumi', N'The Earth has various landforms such as mountains, hills and plains.', N'Bumi mempunyai pelbagai bentuk muka bumi seperti gunung, bukit dan dataran.', N'Images/Lesson/land.mp4', 1),
    (N'LS010', N'ST142', N'Soil', N'Tanah', N'Soil contains minerals, water, air and organic matter that support plant growth.', N'Tanah mengandungi mineral, air, udara dan bahan organik yang membantu pertumbuhan tumbuhan.', N'Images/Lesson/soil.png', 1),
    (N'LS011', N'ST151', N'Basic Shapes', N'Bentuk Asas', N'Common basic shapes include circles, squares, triangles and rectangles.', N'Bentuk asas yang biasa ialah bulatan, segi empat sama, segi tiga dan segi empat tepat.', N'Images/Lesson/shapes.mp4', 1),
    (N'LS012', N'ST152', N'Basic Shape Blocks', N'Bongkah Bentuk Asas', N'Basic shapes can be formed into blocks such as cubes, cuboids and cylinders.', N'Bentuk asas boleh membentuk bongkah seperti kubus, kuboid dan silinder.', N'Images/Lesson/basicshapes.png', 1),
    (N'LS013', N'ST153', N'Importance of Block Shapes', N'Kepentingan Bentuk Bongkah', N'Different block shapes provide strength and stability to structures.', N'Bentuk bongkah yang berbeza memberikan kekuatan dan kestabilan kepada struktur.', N'Images/Lesson/shapes.png', 1),
    (N'LS014', N'ST211', N'Types of Human Teeth', N'Jenis Gigi Manusia', N'Humans have incisors, canines and molars. Each type of tooth has a different function.', N'Manusia mempunyai gigi kacip, gigi taring dan gigi geraham. Setiap jenis gigi mempunyai fungsi yang berbeza.', N'Images/Lesson/teeth.mp4', 1),
    (N'LS015', N'ST211', N'Functions of Teeth', N'Fungsi Gigi', N'Teeth help us bite, tear and grind food before digestion.', N'Gigi membantu kita menggigit, mengoyak dan mengisar makanan sebelum pencernaan berlaku.', N'Images/Lesson/teeth.jpeg', 2),
    (N'LS016', N'ST211', N'Caring for Teeth', N'Penjagaan Gigi', N'Healthy teeth can be maintained by brushing regularly and eating healthy food.', N'Gigi yang sihat boleh dijaga dengan memberus gigi secara berkala dan mengambil makanan sihat.', N'Images/Lesson/careteeth.png', 3),
    (N'LS017', N'ST212', N'Food Classes', N'Kelas Makanan', N'Food can be classified into carbohydrates, proteins, fats, vitamins and minerals.', N'Makanan boleh dikelaskan kepada karbohidrat, protein, lemak, vitamin dan mineral.', N'Images/Lesson/foodclass.mp4', 1),
    (N'LS018', N'ST212', N'Importance of a Balanced Diet', N'Kepentingan Pemakanan Seimbang', N'A balanced diet provides the nutrients needed for growth and health.', N'Pemakanan seimbang membekalkan nutrien yang diperlukan untuk pertumbuhan dan kesihatan.', N'Images/Lesson/diet.png', 2),
    (N'LS019', N'ST212', N'Healthy Eating Habits', N'Amalan Pemakanan Sihat', N'Healthy eating habits help maintain a healthy body.', N'Amalan pemakanan sihat membantu mengekalkan tubuh yang sihat.', N'Images/Lesson/healthyeating.png', 3),
    (N'LS020', N'ST213', N'Digestive Organs', N'Organ Pencernaan', N'The digestive system consists of several organs that process food.', N'Sistem pencernaan terdiri daripada beberapa organ yang memproses makanan.', N'Images/Lesson/organ.mp4', 1),
    (N'LS021', N'ST213', N'The Human Digestive System', N'Sistem Pencernaan Manusia', N'The digestive system breaks down food into nutrients for the body.', N'Sistem pencernaan memecahkan makanan kepada nutrien untuk badan.', N'Images/Lesson/digestivesystem.png', 2),
    (N'LS022', N'ST213', N'The Digestion Process', N'Proses Pencernaan', N'Digestion begins in the mouth and continues through the digestive tract.', N'Pencernaan bermula di mulut dan berterusan melalui saluran pencernaan.', N'Images/Lesson/digestiveprocess.png', 3),
    (N'LS023', N'ST221', N'Objects that Float and Sink', N'Objek Timbul dan Tenggelam', N'Some objects float while others sink depending on their properties.', N'Sesetengah objek timbul manakala yang lain tenggelam bergantung kepada sifatnya.', N'Images/Lesson/float.mp4', 1),
    (N'LS024', N'ST222', N'Understanding Density', N'Memahami Ketumpatan', N'Density refers to how closely packed the particles in a substance are.', N'Ketumpatan merujuk kepada sejauh mana zarah dalam sesuatu bahan tersusun rapat.', N'Images/Lesson/density.png', 1),
    (N'LS025', N'ST222', N'Increasing Water Density', N'Meningkatkan Ketumpatan Air', N'Adding certain substances such as salt can increase water density.', N'Menambah bahan tertentu seperti garam boleh meningkatkan ketumpatan air.', N'Images/Lesson/waterdensity.png', 2),
    (N'LS026', N'ST223', N'Uses of Density in Everyday Life', N'Aplikasi Ketumpatan dalam Kehidupan Harian', N'Density helps explain why ships float and hot air balloons rise.', N'Ketumpatan menerangkan mengapa kapal terapung dan belon udara panas boleh naik.', N'Images/Lesson/densitylife.png', 1),
    (N'LS027', N'ST231', N'Acid, Alkali and Neutral Substances', N'Bahan Asid, Alkali dan Neutral', N'Substances can be grouped as acidic, alkaline or neutral.', N'Bahan boleh dikelaskan sebagai berasid, beralkali atau neutral.', N'Images/Lesson/acidalkalineutral.mp4', 1),
    (N'LS028', N'ST232', N'Identifying Acidic, Alkaline and Neutral Substances', N'Mengenal Pasti Bahan Asid, Alkali dan Neutral', N'Indicators help identify whether a substance is acidic, alkaline or neutral.', N'Penunjuk membantu mengenal pasti sama ada sesuatu bahan berasid, beralkali atau neutral.', N'Images/Lesson/acidalkalineutral.png', 1),
    (N'LS029', N'ST232', N'Acidic, Alkaline and Neutral Substances Around Us', N'Bahan Asid, Alkali dan Neutral di Sekeliling Kita', N'Many household substances can be classified according to their properties.', N'Banyak bahan di sekeliling kita boleh dikelaskan mengikut sifatnya.', N'substances,png', 2),
    (N'LS030', N'ST232', N'Alternatives to Litmus Paper', N'Pengganti Kertas Litmus', N'Natural materials can be used as alternatives to litmus paper.', N'Bahan semula jadi boleh digunakan sebagai pengganti kertas litmus.', N'Images/Lesson/litmuspaper.png', 3),
    (N'LS031', N'ST241', N'The Members of the Solar System', N'Ahli Sistem Suria', N'The Solar System consists of the Sun, planets and other celestial objects.', N'Sistem Suria terdiri daripada Matahari, planet dan objek angkasa yang lain.', N'Images/Lesson/solarsytem.mp4', 1),
    (N'LS032', N'ST242', N'Planet Temperatures', N'Suhu Planet', N'Each planet has a different temperature depending on its distance from the Sun.', N'Setiap planet mempunyai suhu yang berbeza bergantung kepada jaraknya dari Matahari.', N'Images/Lesson/planettemp.png', 1),
    (N'LS033', N'ST243', N'Planetary Orbits', N'Orbit Planet', N'Planets move around the Sun in paths called orbits.', N'Planet bergerak mengelilingi Matahari dalam laluan yang dipanggil orbit.', N'Images/Lesson/orbits.png', 1),
    (N'LS034', N'ST244', N'Time Taken by Planets to Orbit the Sun', N'Masa Peredaran Planet Mengelilingi Matahari', N'Different planets take different amounts of time to orbit the Sun.', N'Planet yang berbeza mengambil masa yang berbeza untuk mengelilingi Matahari.', N'Images/Lesson/timeorbit.png', 1),
    (N'LS035', N'ST251', N'Introduction to Pulleys', N'Pengenalan Takal', N'A pulley is a simple machine used to lift heavy objects.', N'Takal ialah mesin ringkas yang digunakan untuk mengangkat objek berat.', N'Images/Lesson/pulley.mp4', 1),
    (N'LS036', N'ST251', N'Types of Pulleys', N'Jenis-jenis Takal', N'There are different types of pulleys used for different purposes.', N'Terdapat pelbagai jenis takal yang digunakan untuk tujuan yang berbeza.', N'Images/Lesson/pulley.png', 2),
    (N'LS037', N'ST252', N'How a Fixed Pulley Works', N'Cara Takal Tetap Berfungsi', N'A fixed pulley changes the direction of force.', N'Takal tetap mengubah arah daya.', N'Images/Lesson/fixedpulley.png', 1),
    (N'LS038', N'ST253', N'Applications of Pulleys', N'Kegunaan Takal', N'Pulleys are used in construction, elevators and cranes.', N'Takal digunakan dalam pembinaan, lif dan kren.', N'Images/Lesson/pulleyapp.png', 1),
    (N'LS039', N'ST253', N'Building a Functional Pulley Model', N'Membina Model Takal Berfungsi', N'A pulley model helps demonstrate how pulleys make work easier.', N'Model takal membantu menunjukkan bagaimana takal memudahkan kerja.', N'Images/Lesson/functionalpulley.png', 2),
    (N'LS040', N'ST311', N'Human Skeletal System', N'Sistem Rangka Manusia', N'The skeletal system supports the body and protects internal organs.', N'Sistem rangka menyokong badan dan melindungi organ dalaman.', N'Images/Lesson/skeletal.mp4', 1),
    (N'LS041', N'ST311', N'Functions of the Human Skeleton', N'Fungsi Sistem Rangka Manusia', N'Bones provide support, protection and movement.', N'Tulang memberikan sokongan, perlindungan dan pergerakan.', N'Images/Lesson/fskeletal.png', 2),
    (N'LS042', N'ST311', N'Importance of the Skeletal System', N'Kepentingan Sistem Rangka', N'A healthy skeletal system is important for movement and growth.', N'Sistem rangka yang sihat penting untuk pergerakan dan pertumbuhan.', N'Images/Lesson/iskeletal.png', 3),
    (N'LS043', N'ST312', N'Position of Joints in the Human Body', N'Kedudukan Sendi dalam Badan Manusia', N'Joints connect bones and allow movement.', N'Sendi menghubungkan tulang dan membolehkan pergerakan.', N'Images/Lesson/joints.mp4', 1),
    (N'LS044', N'ST312', N'Functions of Joints', N'Fungsi Sendi', N'Joints help the body move in different ways.', N'Sendi membantu badan bergerak dalam pelbagai cara.', N'Images/Lesson/fjoints.png', 2),
    (N'LS045', N'ST312', N'Types of Joint Movement', N'Jenis Pergerakan Sendi', N'Different joints allow different types of movement.', N'Sendi yang berbeza membolehkan jenis pergerakan yang berbeza.', N'Images/Lesson/jointsmove.png', 3),
    (N'LS046', N'ST313', N'Main Parts of the Circulatory System', N'Bahagian Utama Sistem Peredaran Darah', N'The circulatory system consists of the heart, blood vessels and blood.', N'Sistem peredaran darah terdiri daripada jantung, salur darah dan darah.', N'Images/Lesson/circulatorysystem.mp4', 1),
    (N'LS047', N'ST313', N'Functions of the Heart, Blood Vessels and Blood', N'Fungsi Jantung, Salur Darah dan Darah', N'These components transport oxygen and nutrients throughout the body.', N'Komponen ini mengangkut oksigen dan nutrien ke seluruh badan.', N'Images/Lesson/fcirculatory.png', 2),
    (N'LS048', N'ST313', N'Importance of the Circulatory System', N'Kepentingan Sistem Peredaran Darah', N'The circulatory system is essential for survival.', N'Sistem peredaran darah penting untuk kelangsungan hidup.', N'Images/Lesson/icirculatory.png', 3),
    (N'LS049', N'ST314', N'Blood Circulation Pathway', N'Laluan Peredaran Darah', N'Blood flows from the heart to the lungs and throughout the body before returning to the heart.', N'Darah mengalir dari jantung ke paru-paru dan seluruh badan sebelum kembali ke jantung.', N'Images/Lesson/pathcirc.png', 1),
    (N'LS050', N'ST314', N'Relationship Between Body Systems', N'Hubungan Antara Sistem Badan', N'Body systems work together to keep the body healthy and functioning properly.', N'Sistem badan bekerjasama untuk memastikan badan kekal sihat dan berfungsi dengan baik.', N'Images/Lesson/bodysystem.png', 2),
    (N'LS051', N'ST314', N'Caring for Body Systems', N'Penjagaan Sistem Badan', N'Healthy habits help maintain the efficiency of body systems.', N'Amalan hidup sihat membantu mengekalkan kecekapan sistem badan.', N'Images/Lesson/carebody.png', 3),
    (N'LS052', N'ST321', N'Sources of Electricity', N'Sumber Elektrik', N'Electricity can be generated from various sources such as batteries and power stations.', N'Elektrik boleh dijana daripada pelbagai sumber seperti bateri dan stesen janakuasa.', N'Images/Lesson/electricity.mp4', 1),
    (N'LS053', N'ST321', N'Dry Cells, Solar Cells and Generators', N'Sel Kering, Sel Suria dan Penjana', N'Dry cells, solar cells and generators are common sources of electrical energy.', N'Sel kering, sel suria dan penjana merupakan sumber tenaga elektrik yang biasa digunakan.', N'Images/Lesson/cells.png', 2),
    (N'LS054', N'ST322', N'Series Circuit', N'Litar Bersiri', N'Components in a series circuit are connected in a single path.', N'Komponen dalam litar bersiri disambungkan dalam satu laluan.', N'Images/Lesson/seriescir.png', 1),
    (N'LS055', N'ST322', N'Parallel Circuit', N'Litar Selari', N'Components in a parallel circuit are connected through multiple paths.', N'Komponen dalam litar selari disambungkan melalui beberapa laluan.', N'Images/Lesson/parallelcir.png', 2),
    (N'LS056', N'ST322', N'Differences Between Series and Parallel Circuits', N'Perbezaan Litar Bersiri dan Selari', N'Series and parallel circuits differ in connection methods and performance.', N'Litar bersiri dan selari berbeza dari segi sambungan dan prestasi.', N'Images/Lesson/diffseriesparallel.png', 3),
    (N'LS057', N'ST323', N'Circuit Components and Symbols', N'Komponen dan Simbol Litar', N'Electrical symbols represent components used in electrical circuits.', N'Simbol elektrik mewakili komponen yang digunakan dalam litar elektrik.', N'Images/Lesson/componentsymbol.png', 1),
    (N'LS058', N'ST323', N'Drawing Circuit Diagrams', N'Melukis Rajah Litar', N'Circuit diagrams use symbols to show electrical connections.', N'Rajah litar menggunakan simbol untuk menunjukkan sambungan elektrik.', N'Images/Lesson/circuitdiagram.png', 2),
    (N'LS059', N'ST331', N'States of Matter', N'Keadaan Jirim', N'Matter exists in three main states: solid, liquid and gas.', N'Jirim wujud dalam tiga keadaan utama iaitu pepejal, cecair dan gas.', N'Images/Lesson/matter.mp4', 1),
    (N'LS060', N'ST331', N'Melting and Freezing', N'Peleburan dan Pembekuan', N'Melting changes a solid into a liquid, while freezing changes a liquid into a solid.', N'Peleburan menukarkan pepejal kepada cecair manakala pembekuan menukarkan cecair kepada pepejal.', N'Images/Lesson/meltfreezing.png', 2),
    (N'LS061', N'ST331', N'Evaporation and Condensation', N'Penyejatan dan Kondensasi', N'Evaporation changes liquid into gas while condensation changes gas into liquid.', N'Penyejatan menukarkan cecair kepada gas manakala kondensasi menukarkan gas kepada cecair.', N'Images/Lesson/evaporateandcondense.png', 3),
    (N'LS062', N'ST332', N'Physical Properties of Matter', N'Sifat Fizikal Jirim', N'Matter has physical properties such as mass, volume and shape.', N'Jirim mempunyai sifat fizikal seperti jisim, isipadu dan bentuk.', N'Images/Lesson/matter.png', 1),
    (N'LS063', N'ST332', N'Changes in Matter', N'Perubahan Jirim', N'Matter can undergo physical changes due to heat or cooling.', N'Jirim boleh mengalami perubahan fizikal akibat pemanasan atau penyejukan.', N'Images/Lesson/changesmatter.png', 2),
    (N'LS064', N'ST333', N'Water Cycle Process', N'Proses Kitaran Air', N'The water cycle involves evaporation, condensation and precipitation.', N'Kitaran air melibatkan penyejatan, kondensasi dan pemendakan.', N'Images/Lesson/watercycle.mp4', 1),
    (N'LS065', N'ST333', N'Importance of the Water Cycle', N'Kepentingan Kitaran Air', N'The water cycle ensures a continuous supply of fresh water on Earth.', N'Kitaran air memastikan bekalan air bersih berterusan di Bumi.', N'Images/Lesson/iwatercycle.png', 2),
    (N'LS066', N'ST341', N'Moon Phases', N'Fasa Bulan', N'The Moon appears to change shape as it orbits the Earth.', N'Bulan kelihatan berubah bentuk semasa mengelilingi Bumi.', N'Images/Lesson/moon.mp4', 1),
    (N'LS067', N'ST341', N'Sequence of Moon Phases', N'Urutan Fasa Bulan', N'The phases of the Moon occur in a repeating sequence each month.', N'Fasa Bulan berlaku dalam urutan yang berulang setiap bulan.', N'Images/Lesson/moonphases.png', 2),
    (N'LS068', N'ST341', N'Observing Moon Phases', N'Pemerhatian Fasa Bulan', N'Moon phases can be observed from Earth over time.', N'Fasa Bulan boleh diperhatikan dari Bumi dari semasa ke semasa.', N'Images/Lesson/observemoon.png', 3),
    (N'LS069', N'ST342', N'What Are Constellations?', N'Apakah Itu Buruj?', N'Constellations are groups of stars that form recognizable patterns.', N'Buruj ialah kumpulan bintang yang membentuk corak tertentu.', N'Images/Lesson/constellations.mp4', 1),
    (N'LS070', N'ST342', N'Major Constellations', N'Buruj Utama', N'Several constellations are commonly observed in the night sky.', N'Terdapat beberapa buruj utama yang sering diperhatikan di langit malam.', N'Images/Lesson/constellations.png', 2),
    (N'LS071', N'ST342', N'Uses of Constellations', N'Kegunaan Buruj', N'Constellations have been used for navigation and observation.', N'Buruj digunakan untuk navigasi dan pemerhatian.', N'Images/Lesson/usesconstellations.png', 3),
    (N'LS072', N'ST351', N'What Is a Pulley?', N'Apakah Itu Takal?', N'A pulley is a simple machine that helps lift loads with less effort.', N'Takal ialah mesin ringkas yang membantu mengangkat beban dengan kurang daya.', N'Images/Lesson/pulleyadv.mp4', 1),
    (N'LS073', N'ST351', N'Types of Pulleys', N'Jenis-jenis Takal', N'Pulleys can be fixed, movable or combined.', N'Takal boleh terdiri daripada takal tetap, takal bergerak atau gabungan kedua-duanya.', N'Images/Lesson/typepulley.png', 2),
    (N'LS074', N'ST351', N'Uses of Pulleys', N'Kegunaan Takal', N'Pulleys are widely used to lift heavy objects efficiently.', N'Takal digunakan secara meluas untuk mengangkat objek berat dengan lebih cekap.', N'Images/Lesson/usespulley.png', 3),
    (N'LS075', N'ST352', N'Introduction to Gears', N'Pengenalan Gear', N'Gears are wheels with teeth that transfer motion and force.', N'Gear ialah roda bergigi yang memindahkan pergerakan dan daya.', N'Images/Lesson/gears.mp4', 1),
    (N'LS076', N'ST352', N'How Gears Work?', N'Cara Gear Berfungsi', N'Gears work by interlocking teeth to transfer movement.', N'Gear berfungsi melalui sentuhan gigi gear untuk memindahkan pergerakan.', N'Images/Lesson/gearswork.png', 2),
    (N'LS077', N'ST352', N'Applications of Gears', N'Aplikasi Gear', N'Gears are commonly found in bicycles, clocks and machinery.', N'Gear biasanya digunakan dalam basikal, jam dan mesin.', N'Images/Lesson/gearsappication.png', 3),
    (N'LS078', N'ST353', N'Types of Simple Machines', N'Jenis Mesin Ringkas', N'Simple machines make work easier by changing force or direction.', N'Mesin ringkas memudahkan kerja dengan mengubah daya atau arah.', N'Images/Lesson/simplemachine.png', 1),
    (N'LS079', N'ST353', N'Machines in Daily Life', N'Mesin dalam Kehidupan Harian', N'Simple machines are commonly used in everyday activities.', N'Mesin ringkas sering digunakan dalam aktiviti harian.', N'Images/Lesson/machinedailylife.png', 2),
    (N'LS080', N'ST354', N'Combining Simple Machines', N'Gabungan Mesin Ringkas', N'Compound machines are formed by combining multiple simple machines.', N'Mesin kompleks terbentuk daripada gabungan beberapa mesin ringkas.', N'Images/Lesson/combinesimplemachine.png', 1),
    (N'LS081', N'ST354', N'Examples of Compound Machines', N'Contoh Mesin Kompleks', N'Bicycles and wheelbarrows are examples of compound machines.', N'Basikal dan kereta sorong merupakan contoh mesin kompleks.', N'Images/Lesson/compoundmachine.png', 2);
GO

PRINT N'Inserting XPAction (9 rows)...';
INSERT INTO dbo.[XPAction] ([xpActionId], [actionNameEN], [actionNameBM], [xpValue])
VALUES
    (N'XP001', N'Complete Lesson', N'Selesaikan Pelajaran', 10),
    (N'XP002', N'Complete Virtual Lab', N'Selesaikan Makmal Maya', 15),
    (N'XP003', N'Attempt Practice Quiz', N'Jawab Kuiz Latihan', 10),
    (N'XP004', N'Pass Unit Quiz', N'Lulus Kuiz Unit', 25),
    (N'XP005', N'Score 80% or Above', N'Skor 80% ke Atas', 20),
    (N'XP006', N'Complete Level Assessment', N'Selesaikan Penilaian Tahap', 40),
    (N'XP007', N'Join Forum Discussion', N'Sertai Perbincangan Forum', 5),
    (N'XP008', N'Attend Live Session', N'Hadiri Sesi Langsung', 15),
    (N'XP009', N'Complete Study Plan Task', N'Selesaikan Tugasan Pelan Belajar', 10);
GO

PRINT N'Inserting Tag (51 rows)...';
INSERT INTO dbo.[Tag] ([tagId], [tagName], [createdAt])
VALUES
    (N'TAG001', N'Human Sense', N'2026-01-01 14:39:00'),
    (N'TAG002', N'Classify Taste', N'2026-01-01 14:40:00'),
    (N'TAG003', N'Use of Human Sense', N'2026-01-01 14:42:00'),
    (N'TAG004', N'Magnets', N'2026-01-01 14:43:00'),
    (N'TAG005', N'Absorption', N'2026-01-01 14:43:00'),
    (N'TAG006', N'The Earth', N'2026-01-01 14:45:00'),
    (N'TAG007', N'Landforms', N'2026-01-01 14:46:00'),
    (N'TAG008', N'Soil', N'2026-01-01 14:47:00'),
    (N'TAG009', N'Basics of Buildings', N'2026-01-01 14:48:00'),
    (N'TAG010', N'Teeth', N'2026-01-01 14:49:00'),
    (N'TAG011', N'Balanced Diet', N'2026-01-01 14:49:00'),
    (N'TAG012', N'Digestion Process', N'2026-01-01 14:49:00'),
    (N'TAG013', N'Float and Sink', N'2026-01-01 14:49:00'),
    (N'TAG014', N'Density', N'2026-01-01 14:50:00'),
    (N'TAG015', N'Applications of Density', N'2026-01-01 14:50:00'),
    (N'TAG016', N'Acid and Alkali', N'2026-01-01 14:50:00'),
    (N'TAG017', N'The Solar System', N'2026-01-01 14:50:00'),
    (N'TAG018', N'Members of the Solar System', N'2026-01-01 14:51:00'),
    (N'TAG019', N'Temperature of Planets', N'2026-01-01 14:51:00'),
    (N'TAG020', N'Orbit of Planets', N'2026-01-01 14:51:00'),
    (N'TAG021', N'Revolution Time of Planets', N'2026-01-01 14:51:00'),
    (N'TAG022', N'Machine', N'2026-01-01 14:52:00'),
    (N'TAG023', N'Pulleys and Types', N'2026-01-01 14:52:00'),
    (N'TAG024', N'Function of a Fixed Pulley', N'2026-01-01 14:52:00'),
    (N'TAG025', N'Uses of Pulleys', N'2026-01-01 14:52:00'),
    (N'TAG029', N'Humans', N'2026-01-01 14:53:00'),
    (N'TAG030', N'Human Skeletal System', N'2026-01-01 14:53:00'),
    (N'TAG031', N'Joints', N'2026-01-01 14:53:00'),
    (N'TAG032', N'Human Blood Circulatory System', N'2026-01-01 14:53:00'),
    (N'TAG033', N'Human Blood Circulatory Pathway', N'2026-01-01 14:54:00'),
    (N'TAG034', N'Electricity', N'2026-01-01 14:54:00'),
    (N'TAG035', N'Sources of Electrical Energy', N'2026-01-01 14:54:00'),
    (N'TAG036', N'Series and Parallel Circuits', N'2026-01-01 14:54:00'),
    (N'TAG037', N'Matter Changes State', N'2026-01-01 14:55:00'),
    (N'TAG038', N'Properties of Matter', N'2026-01-01 14:55:00'),
    (N'TAG039', N'Water Cycle', N'2026-01-01 14:55:00'),
    (N'TAG040', N'Phases of the Moon', N'2026-01-01 14:55:00'),
    (N'TAG041', N'Constellations', N'2026-01-01 14:56:00'),
    (N'TAG042', N'Pulley', N'2026-01-01 14:56:00'),
    (N'TAG043', N'Gear', N'2026-01-01 14:56:00'),
    (N'TAG044', N'Simple Machines', N'2026-01-01 14:56:00'),
    (N'TAG045', N'Compound Machines', N'2026-01-01 14:57:00'),
    (N'TAG046', N'Beginner', N'2026-01-01 14:57:00'),
    (N'TAG047', N'Intermediate', N'2026-01-01 14:57:00'),
    (N'TAG048', N'Advanced', N'2026-01-01 14:57:00'),
    (N'TAG049', N'Live Session', N'2026-01-01 14:58:00'),
    (N'TAG050', N'Badge', N'2026-01-01 14:58:00'),
    (N'TAG051', N'Quiz', N'2026-01-01 14:58:00'),
    (N'TAG052', N'Teacher Help', N'2026-01-01 14:59:00'),
    (N'TAG053', N'Study Plan', N'2026-01-01 14:59:00'),
    (N'TAG054', N'Revision Tips', N'2026-01-01 15:00:00');
GO

PRINT N'Inserting VirtualLab (8 rows)...';
INSERT INTO dbo.[VirtualLab] ([labId], [unitId], [labTitleEN], [labTitleBM], [labDescriptionEN], [labDescriptionBM], [instructionEN], [instructionBM], [labType], [difficulty], [createdAt])
VALUES
    (N'LAB001', N'UN102', N'Magnetic Forces Explorer', N'Penjelajah Daya Magnet', N'Test different magnet poles and identify which objects are attracted to magnets.', N'Uji kutub magnet yang berbeza dan kenal pasti objek yang ditarik oleh magnet.', N'1. Select two magnets and drag them together to test the same poles (N-N or S-S) and different poles (N-S)
2. Observe if the magnets push away (repel) or pull together (attract)
3. Drag a magnet toward objects like a nail, pencil, and paperclip
4. Sort the objects into "Magnetic" and "Non-magnetic" categories', N'1. Pilih dua magnet dan seretnya bersama-sama untuk menguji kutub yang sama (U-U atau S-S) dan kutub yang berbeza (U-S)
2. Perhatikan jika magnet menolak atau menarik satu sama lain
3. Seret magnet ke arah objek seperti paku, pensel, dan klip kertas
4. Kelaskan objek ke dalam kategori "Bermagnet" dan "Tidak Bermagnet"', N'Drag-and-drop Simulation', N'Easy', N'2026-01-01'),
    (N'LAB002', N'UN103', N'The Great Soak Challenge', N'Cabaran Serapan Hebat', N'Test the water absorption capacity of different materials', N'Uji keupayaan penyerapan air bagi bahan yang berbeza', N'1. Select a material such as a sponge, tissue paper, or a plastic coin
2. Use the virtual dropper to place three drops of colored water on the material
3. Observe if the water is absorbed or if it remains on the surface
4. Compare two absorbent materials to see which one soaks up more water', N'1. Pilih bahan seperti span, kertas tisu, atau duit syiling plastik
2. Gunakan penitis maya untuk menitiskan tiga titik air berwarna pada bahan tersebut
3. Perhatikan sama ada air diserap atau kekal di atas permukaan
4. Bandingkan dua bahan yang menyerap air untuk melihat mana yang menyerap lebih banyak air', N'Observation Lab', N'Easy', N'2026-01-01'),
    (N'LAB003', N'UN201', N'Journey of a Sandwich', N'Perjalanan Sekeping Sandwic', N'Follow food as it is broken down and travels through the digestive system', N'Ikuti perjalanan makanan semasa ia dihancurkan dan melalui sistem pencernaan', N'1. Click the sandwich to begin mechanical digestion in the mouth using teeth and saliva
2. Drag the food bolus down the esophagus into the stomach
3. Watch the food turn into a liquid state in the stomach and move to the intestines
4. Identify where nutrients are absorbed and follow the waste until it reaches the anus', N'1. Klik pada sandwic untuk memulakan pencernaan mekanikal di dalam mulut menggunakan gigi dan air liur
2. Seret bolus makanan menuruni esofagus ke dalam perut
3. Perhatikan makanan berubah menjadi cecair di dalam perut dan bergerak ke usus
4. Kenal pasti di mana nutrien diserap dan ikuti sisa makanan sehingga sampai ke dubur', N'Process Animation', N'Medium', N'2026-01-01'),
    (N'LAB004', N'UN202', N'Sink or Float Master', N'Pakar Timbul atau Tenggelam', N'Discover how objects react to water and how to make sinking objects float', N'Temui bagaimana objek bertindak balas terhadap air dan cara membuat objek yang tenggelam menjadi timbul', N'1. Pick an object like a marble or a cork and drop it into the water tank
2. Observe if the object sinks to the bottom or stays at the top
3. Add salt or sugar to the water to increase its density
4. Watch if the sinking objects begin to float as the water becomes denser', N'1. Pilih objek seperti guli atau gabus dan jatuhkan ke dalam tangki air
2. Perhatikan sama ada objek itu tenggelam ke dasar atau kekal di atas permukaan
3. Tambah garam atau gula ke dalam air untuk meningkatkan ketumpatannya
4. Perhatikan jika objek yang tenggelam mula timbul apabila air menjadi lebih tumpat', N'Variable Experiment', N'Medium', N'2026-01-01'),
    (N'LAB005', N'UN203', N'The Litmus Test', N'Ujian Kertas Litmus', N'Use litmus paper to identify acidic, alkaline, and neutral substances', N'Gunakan kertas litmus untuk mengenal pasti bahan berasid, beralkali, dan neutral', N'1. Select a substance to test, such as lemon juice, soap, or salt water
2. Drag a strip of blue litmus paper into the substance and check for a color change
3. Drag a strip of red litmus paper into the same substance and check for a color change
4. Classify the substance as acidic (blue turns red), alkaline (red turns blue), or neutral (no change)', N'1. Pilih bahan untuk diuji, seperti jus limau, sabun, atau air garam
2. Seret sehelai kertas litmus biru ke dalam bahan dan perhatikan perubahan warna
3. Seret sehelai kertas litmus merah ke dalam bahan yang sama dan perhatikan perubahan warna
4. Kelaskan bahan tersebut sebagai berasid (biru jadi merah), beralkali (merah jadi biru), atau neutral (tiada perubahan)', N'Sandbox Simulator', N'Medium', N'2026-01-01'),
    (N'LAB006', N'UN301', N'Blood Flow Simulator', N'Simulator Aliran Darah', N'Visualize the path of oxygen-rich and carbon dioxide-rich blood in the human body', N'Visualkan laluan darah yang kaya dengan oksigen dan kaya dengan karbon dioksida dalam badan manusia', N'1. Click the lungs to pick up oxygen and turn the blood red
2. Drag the oxygen-rich blood to the heart to be pumped to the rest of the body
3. Watch the blood deliver oxygen to the body parts and turn blue as it picks up carbon dioxide
4. Move the carbon dioxide-rich blood back to the heart and then to the lungs to be exhaled', N'1. Klik pada peparu untuk mengambil oksigen dan menukarkan warna darah menjadi merah
2. Seret darah yang kaya dengan oksigen ke jantung untuk dipam ke seluruh bahagian badan
3. Perhatikan darah menghantar oksigen ke bahagian badan dan bertukar menjadi biru setelah mengambil karbon dioksida
4. Gerakkan darah yang kaya dengan karbon dioksida kembali ke jantung dan kemudian ke peparu untuk dihembus keluar', N'Process Animation', N'Hard', N'2026-01-01'),
    (N'LAB007', N'UN302', N'Power Up: Circuit Lab', N'Jana Kuasa: Makmal Litar', N'Build and compare series and parallel electrical circuits', N'Bina dan bandingkan litar elektrik bersiri dan selari', N'1. Place a dry cell, a switch, and two bulbs on the board
2. Use wires to connect the components in a single path to create a series circuit
3. Change the wiring to create multiple paths for a parallel circuit
4. Flip the switches and compare the brightness of the bulbs in both circuits', N'1. Letakkan sel kering, suis, dan dua mentol di atas papan
2. Gunakan wayar untuk menyambungkan komponen dalam satu laluan untuk membina litar bersiri
3. Tukar pendawaian untuk membina beberapa laluan bagi litar selari
4. Petik suis dan bandingkan kecerahan mentol dalam kedua-dua litar tersebut', N'Sandbox Simulator', N'Hard', N'2026-01-01'),
    (N'LAB008', N'UN303', N'Matter State Changer', N'Penukar Keadaan Jirim', N'Explore how water changes between solid, liquid, and gas states', N'Terokai bagaimana air berubah antara keadaan pepejal, cecair, dan gas', N'1. Place ice cubes (solid) into a virtual beaker
2. Turn on the Bunsen burner to heat the ice and observe it melting into liquid water
3. Increase the heat until the water boils and turns into gas (evaporation)
4. Use a cool surface to watch the gas turn back into liquid droplets (condensation)', N'1. Letakkan ketulan ais (pepejal) ke dalam bikar maya
2. Hidupkan penunu Bunsen untuk memanaskan ais dan perhatikan ia melebur menjadi cecair air
3. Tingkatkan haba sehingga air mendidih dan berubah menjadi gas (penyejatan)
4. Gunakan permukaan sejuk untuk melihat gas berubah kembali menjadi titisan cecair (kondensasi)', N'Thermal Simulation', N'Medium', N'2026-01-01');
GO

PRINT N'Inserting ConfigurationSetting (14 rows)...';
INSERT INTO dbo.[ConfigurationSetting] ([configId], [configKey], [configValue], [lastUpdated])
VALUES
    (N'CONFIG001', N'Easy Question Timer (Seconds)', N'10', N'2026-02-15 10:05:40'),
    (N'CONFIG002', N'Medium Question Timer (Seconds)', N'20', N'2026-02-15 10:06:25'),
    (N'CONFIG003', N'Hard Question Timer (Seconds)', N'30', N'2026-02-15 10:07:39'),
    (N'CONFIG004', N'Passing Mark Percentage for Unit', N'50', N'2026-02-15 10:08:51'),
    (N'CONFIG005', N'Passing Mark for Level', N'70', N'2026-02-15 10:09:48'),
    (N'CONFIG006', N'Leaderboard Top Count', N'10', N'2026-02-15 10:10:40'),
    (N'CONFIG007', N'Easy Question Mark', N'1', N'2026-02-15 10:11:23'),
    (N'CONFIG008', N'Medium Question Mark', N'3', N'2026-02-15 10:12:20'),
    (N'CONFIG009', N'Hard Question Mark', N'5', N'2026-02-15 10:13:10'),
    (N'CONFIG010', N'Suspicious Login Attempt', N'3', N'2026-02-15 10:14:27'),
    (N'CONFIG011', N'Account Lock Duration (Minutes)', N'30', N'2026-02-15 10:15:32'),
    (N'CONFIG012', N'Password Minimum Length', N'8', N'2026-02-15 10:16:09'),
    (N'CONFIG013', N'Maximum Students Per Session', N'50', N'2026-02-15 10:20:54'),
    (N'CONFIG014', N'Consultation Session Duration (Minutes)', N'60', N'2026-02-15 10:21:59');
GO

