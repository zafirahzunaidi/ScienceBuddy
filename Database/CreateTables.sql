-- ScienceBuddy Database Tables

CREATE TABLE [User] (
    userId VARCHAR(10) PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    [password] VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    [role] VARCHAR(20) NOT NULL,
    preferredLanguage VARCHAR(5) NOT NULL,
    [status] VARCHAR(20) NOT NULL,
    CONSTRAINT CK_User_Role CHECK ([role] IN ('Admin', 'Student', 'Parent', 'Teacher')),
    CONSTRAINT CK_User_Language CHECK (preferredLanguage IN ('EN', 'BM')),
    CONSTRAINT CK_User_Status CHECK ([status] IN ('Active', 'Blocked', 'Deleted'))
);

CREATE TABLE [Level] (
    levelId VARCHAR(10) PRIMARY KEY,
    levelNameEN VARCHAR(50) NOT NULL,
    levelNameBM NVARCHAR(50) NOT NULL,
    levelDescriptionEN NVARCHAR(500),
    levelDescriptionBM NVARCHAR(500)
);

CREATE TABLE Personality (
    personalityId VARCHAR(10) PRIMARY KEY,
    personalityNameEN VARCHAR(50) NOT NULL,
    personalityNameBM NVARCHAR(50) NOT NULL,
    descriptionENG NVARCHAR(500),
    descriptionBM NVARCHAR(500),
    avatar VARCHAR(100),
    colour VARCHAR(20),
    learningStyleEN VARCHAR(100),
    learningStyleBM NVARCHAR(100)
);

CREATE TABLE Badge (
    badgeId VARCHAR(10) PRIMARY KEY,
    badgeNameEN VARCHAR(100) NOT NULL,
    badgeNameBM NVARCHAR(100) NOT NULL,
    badgeType VARCHAR(50) NOT NULL,
    xpReward INT NOT NULL DEFAULT 0,
    badgeIcon VARCHAR(100),
    requirementDescriptionEN NVARCHAR(500),
    requirementDescriptionBM NVARCHAR(500),
    badgeDescriptionEN NVARCHAR(500),
    badgeDescriptionBM NVARCHAR(500)
);

CREATE TABLE Student (
    studentId VARCHAR(10) PRIMARY KEY,
    userId VARCHAR(10) NOT NULL,
    [name] NVARCHAR(100) NOT NULL,
    phoneNumber VARCHAR(20),
    nickname NVARCHAR(50),
    currentlevelId VARCHAR(10),
    XP INT NOT NULL DEFAULT 0,
    personalityId VARCHAR(10),
    parentCode VARCHAR(10) UNIQUE,
    FOREIGN KEY (userId) REFERENCES [User](userId),
    FOREIGN KEY (currentlevelId) REFERENCES [Level](levelId),
    FOREIGN KEY (personalityId) REFERENCES Personality(personalityId)
);

CREATE TABLE Parent (
    parentId VARCHAR(10) PRIMARY KEY,
    userId VARCHAR(10) NOT NULL,
    [name] NVARCHAR(100) NOT NULL,
    phoneNumber VARCHAR(20),
    FOREIGN KEY (userId) REFERENCES [User](userId)
);

CREATE TABLE Teacher (
    teacherId VARCHAR(10) PRIMARY KEY,
    userId VARCHAR(10) NOT NULL,
    [name] NVARCHAR(100) NOT NULL,
    phoneNumber VARCHAR(20),
    academicQualification NVARCHAR(100),
    bio NVARCHAR(500),
    licenseCert VARCHAR(100),
    [status] VARCHAR(30) NOT NULL,
    approvedDate DATE,
    FOREIGN KEY (userId) REFERENCES [User](userId),
    CONSTRAINT CK_Teacher_Status CHECK ([status] IN ('Pending', 'Certified', 'Not Certified'))
);

CREATE TABLE StudentParent (
    studentParentId VARCHAR(10) PRIMARY KEY,
    studentId VARCHAR(10) NOT NULL,
    parentId VARCHAR(10) NOT NULL,
    relationship VARCHAR(50) NOT NULL,
    FOREIGN KEY (studentId) REFERENCES Student(studentId),
    FOREIGN KEY (parentId) REFERENCES Parent(parentId)
);
