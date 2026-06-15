-- ScienceBuddy Sample / Dummy Data

INSERT INTO [User] (userId, username, [password], email, [role], preferredLanguage, [status]) VALUES
('U001', 'najihah01', '12345', 'admin@sciencebuddy.edu', 'Admin', 'EN', 'Active'),
('U002', 'ali', '12345', 'ali@gmail.com', 'Student', 'BM', 'Active'),
('U003', 'siti', '12345', 'siti@gmail.com', 'Student', 'EN', 'Active'),
('U004', 'abu', '12345', 'abu@gmail.com', 'Student', 'BM', 'Deleted'),
('U005', 'aminah', 'aminah123', 'aminah@gmail.com', 'Parent', 'EN', 'Active'),
('U006', 'hassan', 'hassan456', 'hassan@gmail.com', 'Parent', 'BM', 'Active'),
('U007', 'laila', 'laila789', 'laila@gmail.com', 'Parent', 'EN', 'Deleted'),
('U008', 'zara', '12345', 'zara@gmail.com', 'Teacher', 'BM', 'Active'),
('U009', 'reza', '12345', 'reza@gmail.com', 'Teacher', 'EN', 'Active'),
('U010', 'nurul', '12345', 'nurul@gmail.com', 'Teacher', 'BM', 'Blocked');

INSERT INTO Student (studentId, userId, [name], phoneNumber, nickname, currentlevelId, XP, personalityId, parentCode) VALUES
('S001', 'U002', N'Ali Bin Abu', '0122068743', N'Ali', 'LV001', 0, 'P001', 'ABX123'),
('S002', 'U003', N'Siti Rahimah Binti Hassan', '0126559145', N'Siti', 'LV002', 0, 'P004', 'SRT456'),
('S003', 'U004', N'Zara Binti Zaidi', '0172008562', N'Zara', 'LV003', 0, 'P006', 'HZQ789');

INSERT INTO Parent (parentId, userId, [name], phoneNumber) VALUES
('P001', 'U005', N'Aminah Binti Yusof', '0134444676'),
('P002', 'U006', N'Hassan Bin Zainal', '0198888900'),
('P003', 'U007', N'Laila Binti Mahfuz', '0186455333');

INSERT INTO Teacher (teacherId, userId, [name], phoneNumber, academicQualification, bio, licenseCert, [status], approvedDate) VALUES
('T001', 'U008', N'Zara Natasya Binti Karim', '0112222333', N'B.Sc Biology (UTM)', N'Experienced science teacher with 10 years in secondary education.', 'cert_zara.pdf', 'Pending', '2026-01-15'),
('T002', 'U009', N'Reza Hakim Bin Malik', '0145555666', N'M.Ed Science Education (UM)', N'Passionate about inquiry-based learning and student engagement.', 'cert_reza.pdf', 'Certified', '2026-03-18'),
('T003', 'U010', N'Nurul Izzah Binti Azmi', '0178888999', N'B.Ed (Hons) Chemistry (UPM)', N'Focused on helping students grasp foundational concepts.', 'cert_izzah.pdf', 'Not Certified', '2026-04-07');

INSERT INTO StudentParent (studentParentId, studentId, parentId, relationship) VALUES
('SP001', 'S001', 'P001', 'Mother'),
('SP002', 'S002', 'P002', 'Father'),
('SP003', 'S003', 'P003', 'Mother');
