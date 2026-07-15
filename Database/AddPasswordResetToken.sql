/* ============================================================
   ScienceBuddy — Add PasswordResetToken table
   Run this on existing databases without losing data.
   ============================================================ */
USE [ScienceBuddy_DB];
GO

IF OBJECT_ID(N'dbo.[PasswordResetToken]', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.[PasswordResetToken] (
        [tokenId]    NVARCHAR(10)  NOT NULL,
        [userId]     NVARCHAR(10)  NOT NULL,
        [tokenHash]  NVARCHAR(64)  NOT NULL,
        [createdAt]  DATETIME2     NOT NULL,
        [expiresAt]  DATETIME2     NOT NULL,
        [usedAt]     DATETIME2     NULL,
        CONSTRAINT PK_PasswordResetToken PRIMARY KEY ([tokenId]),
        CONSTRAINT FK_PasswordResetToken_User FOREIGN KEY ([userId]) REFERENCES dbo.[User]([userId])
    );
    PRINT N'PasswordResetToken table created.';
END
ELSE
BEGIN
    PRINT N'PasswordResetToken table already exists. Skipped.';
END
GO

/* Also ensure User.password column supports BCrypt hashes */
ALTER TABLE dbo.[User] ALTER COLUMN [password] NVARCHAR(100);
GO
PRINT N'AddPasswordResetToken.sql completed.';
GO
