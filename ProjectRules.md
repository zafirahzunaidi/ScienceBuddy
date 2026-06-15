# ScienceBuddy Project Rules

## Project Overview

Project Name: ScienceBuddy

ScienceBuddy is a web-based science learning platform for Malaysian primary school students aged 7–12.

Technology Stack:

* ASP.NET Web Forms
* C#
* SQL Server
* HTML
* CSS
* JavaScript

---

## Development Rules

IMPORTANT:

* Use the existing ASP.NET Web Forms project only.
* Do not create a new solution.
* Do not create a new project.
* Modify the existing project structure only.
* Reuse existing files whenever possible.

---

## Master Page Rules

Use:

* Site.Master
* Site.Master.cs

All pages must inherit from Site.Master unless explicitly instructed otherwise.

Do not create additional master pages.

---

## Folder Structure

Use the existing folder structure.

Student pages:

Student/

* Dashboard.aspx
* Learning.aspx
* Quiz.aspx
* Progress.aspx
* Forum.aspx
* Messages.aspx
* Profile.aspx

Teacher pages:

Teacher/

* Dashboard.aspx
* Materials.aspx
* QuizManagement.aspx
* StudentProgress.aspx
* LiveSessions.aspx
* Forum.aspx
* Messages.aspx
* Profile.aspx

Parent pages:

Parent/

* Dashboard.aspx
* ChildProgress.aspx
* StudyPlan.aspx
* Rewards.aspx
* Messages.aspx
* Profile.aspx

Admin pages:

Admin/

* Dashboard.aspx
* UserManagement.aspx
* ApprovalManagement.aspx
* Reports.aspx
* Settings.aspx

Guest pages:

Guest/

* Home.aspx
* About.aspx
* Lessons.aspx
* Quizzes.aspx
* Forum.aspx

---

## Database Rules

Refer to:

Database/DatabaseSchema.md

IMPORTANT:

* Use existing database tables only.
* Use existing database columns only.
* Do not create alternative schemas.
* Do not rename columns.
* Do not create new tables unless explicitly requested.

Always follow DatabaseSchema.md.

---

## Naming Conventions

Use existing database naming conventions.

Examples:

Correct:

* userId
* studentId
* parentId
* teacherId
* levelId
* personalityId

Incorrect:

* UserID
* StudentID
* ParentID
* TeacherID

---

## Authentication Rules

Login uses:

Table:

* User

Columns:

* username
* password
* role
* status

Requirements:

* Username and password must match.
* Status must be Active.
* Blocked users cannot login.
* Deleted users cannot login.

Store:

* userId
* role

inside Session.

---

## UI Design Rules

Use the ScienceBuddy design system.

Primary Colours:

* #2563EB
* #4DA8FF
* #FF6B2C
* #FFD84D

Use:

* Rounded corners
* Soft shadows
* Friendly educational appearance
* Child-friendly design

Avoid:

* Cyberpunk styling
* Dark hacker themes
* Terminal designs
* Neon effects

---

## Images

Store images inside:

Images/

* Logo/
* Avatars/
* Badges/
* Personality/
* Units/

Do not store image binary data in SQL Server.

Store image paths only.

Example:

~/Images/Badges/unit-master.png

---

## Development Principles

When generating code:

* Prefer reusable code.
* Prefer reusable CSS classes.
* Prefer reusable user controls.
* Avoid duplicate logic.
* Follow existing folder structure.
* Follow existing database schema.
* Follow existing naming conventions.

If uncertain:

DO NOT invent a new architecture.

Use the existing ScienceBuddy architecture.
