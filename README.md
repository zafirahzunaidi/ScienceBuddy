# 🧪 ScienceBuddy

> 🎓 A fun and personalised science learning platform for Malaysian primary school students (7–12 years old), built using **ASP.NET Web Forms (.NET Framework 4.8.1)** and **SQL Server**.

---

## ✨ Features

🎯 **Personalised Learning**
- Personality-based dashboard
- Level-gated learning progression
- XP, badges and certificates

📚 **Interactive Learning**
- Science lessons
- Virtual laboratories
- Practice quizzes
- Unit quizzes

🤖 **AI Learning Support**
- AI Study Companion chatbot
- Learning analysis
- AI flashcard generator

👨‍👩‍👧 **Communication**
- Student-parent account linking
- Discussion forum
- Private messaging
- Live learning sessions (Jitsi Meet)

🌏 **Accessibility**
- English & Bahasa Melayu
- Responsive interface
- Four user roles

---

# 🖥️ Technology Stack

| Component | Technology |
|-----------|------------|
| 💻 Framework | ASP.NET Web Forms (.NET Framework 4.8.1) |
| ⚙️ Language | C# |
| 🗄️ Database | SQL Server |
| 🎨 Styling | Bootstrap 5.2.3 + Custom CSS |
| 🧩 JavaScript | jQuery 3.7 + Vanilla JS |
| 🤖 AI | NVIDIA Llama 3.1 8B |
| 📹 Video | Jitsi Meet |
| 🔐 Security | BCrypt.Net |
| 📄 PDF | iTextSharp |

---

# 👥 User Roles

| Role | Description |
|------|-------------|
| 👦 Student | Learn through lessons, quizzes, labs and AI |
| 👨‍👩‍👧 Parent | Monitor child progress |
| 👩‍🏫 Teacher | Manage learning content |
| 🛡️ Administrator | Manage the whole system |

---

# 📂 Project Structure

```text
ScienceBuddy/
│
├── 👑 Admin/
├── 🎓 Student/
├── 👩‍🏫 Teacher/
├── 👨‍👩‍👧 Parent/
├── 🌐 Guest/
│
├── 🎨 Content/
├── ⚡ Scripts/
├── 🖼️ Images/
├── 🤖 Services/
├── 📦 App_Code/
├── 🚀 App_Start/
├── 🗄️ Database/
│
├── 📄 Site.Master
├── 🌍 Global.asax
└── ⚙️ Web.config
```

---

# 🚀 Getting Started

## 1️⃣ Clone the Repository

```bash
git clone https://github.com/your-repository.git
```

---

## 2️⃣ Set Up the Database

1. Open **SQL Server Management Studio**
2. Execute:

```
Database/ScienceBuddy Database Dummy.sql
```


---

## 3️⃣ Configure the Connection String

Edit

```
connectionStrings.config
```

```xml
<connectionStrings>
    <add
        name="ScienceBuddy_DB"
        connectionString="..."
        providerName="System.Data.SqlClient"/>
</connectionStrings>
```

---

## 4️⃣ Configure AI (Optional)

Create

```
AppSettingsSecrets.config
```

```xml
<appSettings>
    <add key="NvidiaApiKey"
         value="YOUR_API_KEY"/>
</appSettings>
```

> 💡 Without an API key, the website still works. AI features simply display fallback content.

---

## 5️⃣ Run the Project

Open

```
ScienceBuddy.slnx
```

Restore NuGet packages.

Press

```
F5
```

---

# 🔑 Sample Accounts

| Role | Username | Password |
|------|----------|----------|
| 👑 Admin | najihah01 | Admin123 |
| 👦 Student | maya | Maya2026 |
| 👩‍🏫 Teacher | nurun | Nurun999 |
| 👨‍👩‍👧 Parent | hassan | Hassan45 |


---

## ✅ Implemented Features

- ✅ Multi-role authentication
- ✅ Student learning dashboard
- ✅ Personality-based interface
- ✅ Learning content management
- ✅ Practice and unit quizzes
- ✅ XP and badge system
- ✅ Certificate generation workflow
- ✅ Discussion forum
- ✅ Private messaging
- ✅ Parent monitoring
- ✅ Teacher management
- ✅ Administrator management
- ✅ AI Study Companion
- ✅ AI Flashcards
- ✅ AI Learning Analysis
- ✅ Live learning sessions
- 
---

# 📝 Notes

> 🔐 `AppSettingsSecrets.config` is excluded via `.gitignore`.

> 🔒 TLS 1.2 is enforced for all external API communication.

> ⏰ Session timeout uses the ASP.NET default of **20 minutes**.

> 📁 Uploaded files are stored inside the `Images/` folder.

