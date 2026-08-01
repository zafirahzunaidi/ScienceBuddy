# ScienceBuddy

A fun and personalised science learning platform for Malaysian primary school students aged 7 to 12. Built with ASP.NET Web Forms (.NET Framework 4.8.1) and SQL Server.

## About

ScienceBuddy helps young learners explore Science through interactive lessons, quizzes, virtual labs, and AI-powered study tools. The platform supports four user roles: Student, Parent, Teacher, and Administrator. Each role has its own set of features and a personalised interface.

Key features include:
- Personality-based dashboard personalisation
- Level-gated learning progression with XP and badges
- Four quiz types (MCQ, True/False, Multi-Select, Drag and Drop)
- AI-powered learning analysis, chatbot, and flashcard generator
- Live video sessions via embedded Jitsi Meet
- Bilingual support (English and Bahasa Melayu)
- Parent-child account linking with study plans

## Getting Started

### Prerequisites

- Visual Studio 2022 (or later) with ASP.NET and web development workload
- SQL Server 2019 (or later) or SQL Server Express
- SQL Server Management Studio (SSMS)
- .NET Framework 4.8.1

### Step 1: Set Up the Database

1. Open SQL Server Management Studio (SSMS)
2. Connect to your local SQL Server instance
3. Open the file `Database/CreateTables.sql`
4. Execute the script. This will create the `ScienceBuddy_DB` database and all required tables
5. Next, open and execute `Database/SeedData.sql` to populate the tables with initial data (levels, personalities, badges, sample users, etc.)
6. If needed, also run `Database/AddPasswordResetToken.sql` for the password reset feature

### Step 2: Configure the Connection String

1. Open the file `connectionStrings.config` in the project root
2. Update the connection string to match your SQL Server instance:

```xml
<connectionStrings>
    <add name="ScienceBuddy_DB"
         connectionString="Data Source=YOUR_SERVER_NAME;Initial Catalog=ScienceBuddy_DB;Integrated Security=True"
         providerName="System.Data.SqlClient" />
</connectionStrings>
```

Replace `YOUR_SERVER_NAME` with your actual server (e.g. `localhost\SQLEXPRESS` or `.`).

### Step 3: Configure the AI API Key (Optional)

The AI features require an NVIDIA API key. If you want to test AI features:

1. Open or create `AppSettingsSecrets.config` in the project root
2. Add your NVIDIA API key:

```xml
<appSettings>
    <add key="NvidiaApiKey" value="YOUR_NVIDIA_API_KEY_HERE" />
</appSettings>
```

If you do not have an API key, the system will still work. AI features will show fallback content instead of generated responses.

### Step 4: Run the Project

1. Open `ScienceBuddy.slnx` in Visual Studio
2. Restore NuGet packages (right-click solution > Restore NuGet Packages)
3. Press F5 or click the green Start button
4. The application will launch in your browser at `https://localhost:44374`

### Step 5: Log In

Use any of the seeded accounts to test. Default test accounts (if seed data was loaded):

| Role | Username | Password |
|------|----------|----------|
| Admin | admin | (check seed data) |
| Student | (check seed data) | (check seed data) |
| Teacher | (check seed data) | (check seed data) |
| Parent | (check seed data) | (check seed data) |

## Project Structure

```
ScienceBuddy/
├── Admin/          → Administrator pages
├── Student/        → Student pages
├── Teacher/        → Teacher pages
├── Parent/         → Parent pages
├── Content/        → CSS stylesheets
├── Scripts/        → JavaScript files
├── Images/         → Static media assets
├── Services/       → AI service classes
├── App_Code/       → Shared utility classes
├── Database/       → SQL scripts for setup
├── Site.Master     → Shared master page
└── Web.config      → Application configuration
```

## Technology Stack

| Component | Technology |
|-----------|-----------|
| Framework | ASP.NET Web Forms (.NET 4.8.1) |
| Language | C# |
| Database | SQL Server |
| CSS | Bootstrap 5.2.3 + custom design system |
| JavaScript | jQuery 3.7.0 + vanilla JS |
| AI Model | NVIDIA meta/llama-3.1-8b-instruct |
| Video Calls | Jitsi Meet External API |
| Password Security | BCrypt.Net-Next |
| PDF Generation | iTextSharp |

## Notes

- The `AppSettingsSecrets.config` file is excluded from Git via `.gitignore` to protect the API key
- Session timeout is the ASP.NET default of 20 minutes
- File uploads are stored in `Images/` subfolders (Lesson, Material, PrivateMessage, Certificate)
- The system uses TLS 1.2 for all external API calls
