using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Web.Script.Serialization;
using System.Web.UI;
using iTextSharp.text;
using iTextSharp.text.pdf;
using iTextSharp.text.pdf.draw;

namespace ScienceBuddy.Parent
{
    /// <summary>
    /// Generates a colourful, child-friendly A4 progress report styled like
    /// a kindergarten report card. Streams directly as a PDF download.
    /// </summary>
    public partial class DownloadReport : Page
    {
        private string DatabaseConnectionString =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        private string _parentUserId   = "";
        private string _parentRecordId = "";
        private string _selectedChildId = "";

        // ── Class-level colour palette ────────────────────────────────
        private static readonly BaseColor ColourGreen       = new BaseColor(220, 252, 231);
        private static readonly BaseColor ColourGreenDark   = new BaseColor( 22, 163,  74);
        private static readonly BaseColor ColourBlue        = new BaseColor(219, 234, 254);
        private static readonly BaseColor ColourBlueDark    = new BaseColor( 37,  99, 235);
        private static readonly BaseColor ColourPurple      = new BaseColor(237, 233, 254);
        private static readonly BaseColor ColourPurpleDark  = new BaseColor(109,  40, 217);
        private static readonly BaseColor ColourOrange      = new BaseColor(255, 237, 213);
        private static readonly BaseColor ColourOrangeDark  = new BaseColor(194,  65,  12);
        private static readonly BaseColor ColourHero        = new BaseColor( 99, 102, 241);
        private static readonly BaseColor ColourText        = new BaseColor( 30,  41,  59);
        private static readonly BaseColor ColourMuted       = new BaseColor(100, 116, 139);
        private static readonly BaseColor ColourWhite       = BaseColor.WHITE;

        // ══════════════════════════════════════════════════════════════
        //  PAGE LIFECYCLE
        // ══════════════════════════════════════════════════════════════

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null ||
                Session["role"].ToString() != "Parent")
            {
                Response.Redirect("~/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            _parentUserId    = Session["userId"].ToString();
            _selectedChildId = Session["selectedChildId"] as string ?? "";

            if (string.IsNullOrEmpty(_selectedChildId))
            {
                Response.Redirect("~/Parent/ChildProgress.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            LoadParentRecordId();

            if (!IsChildLinkedToParent())
            {
                Response.Redirect("~/Parent/ChildProgress.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            BuildAndStreamReport();
        }

        private void LoadParentRecordId()
        {
            try
            {
                using (var conn = new SqlConnection(DatabaseConnectionString))
                using (var cmd = new SqlCommand(
                    "SELECT parentId FROM dbo.[Parent] WHERE userId = @uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", _parentUserId);
                    conn.Open();
                    object r = cmd.ExecuteScalar();
                    if (r != null && r != DBNull.Value)
                        _parentRecordId = r.ToString();
                }
            }
            catch { }
        }

        private bool IsChildLinkedToParent()
        {
            if (string.IsNullOrEmpty(_parentRecordId) || string.IsNullOrEmpty(_selectedChildId))
                return false;
            try
            {
                using (var conn = new SqlConnection(DatabaseConnectionString))
                using (var cmd = new SqlCommand(
                    "SELECT COUNT(*) FROM dbo.StudentParent WHERE parentId=@pid AND studentId=@sid",
                    conn))
                {
                    cmd.Parameters.AddWithValue("@pid", _parentRecordId);
                    cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                    conn.Open();
                    return (int)cmd.ExecuteScalar() > 0;
                }
            }
            catch { return false; }
        }

        // ══════════════════════════════════════════════════════════════
        //  DATA MODELS
        // ══════════════════════════════════════════════════════════════

        private class ChildInfo
        {
            public string Name;
            public string LevelName;
            public int XP;
            public int BadgeCount;
            public int LessonsCompleted;
            public int QuizAttempts;
            public DateTime? EnrolledDate;
            public string WeakTopics;
            public string StrongTopics;
            public string OverallSummary;
            public string AnalysisJson;
        }

        private class SkillRow
        {
            public string Title;
            public string Status; // Confident, Developing, NotIntroduced
        }

        private class SkillCategory
        {
            public string Title;
            public string Icon;
            public BaseColor BgColour;
            public BaseColor TitleColour;
            public List<SkillRow> Skills = new List<SkillRow>();
        }

        // ══════════════════════════════════════════════════════════════
        //  DATA COLLECTION
        // ══════════════════════════════════════════════════════════════

        private ChildInfo GatherChildData()
        {
            var info = new ChildInfo();
            try
            {
                using (var conn = new SqlConnection(DatabaseConnectionString))
                {
                    conn.Open();

                    using (var cmd = new SqlCommand(
                        @"SELECT s.name, s.XP, ISNULL(l.levelNameEN,'-') AS levelName
                          FROM dbo.Student s
                          LEFT JOIN dbo.[Level] l ON l.levelId = s.currentLevelId
                          WHERE s.studentId = @sid", conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                        using (var r = cmd.ExecuteReader())
                        {
                            if (r.Read())
                            {
                                info.Name      = r["name"]      != DBNull.Value ? r["name"].ToString()      : "Student";
                                info.XP        = r["XP"]        != DBNull.Value ? Convert.ToInt32(r["XP"])  : 0;
                                info.LevelName = r["levelName"] != DBNull.Value ? r["levelName"].ToString()  : "-";
                            }
                        }
                    }

                    using (var cmd = new SqlCommand(
                        "SELECT TOP 1 enrolledDate FROM dbo.Enrollment WHERE studentId=@sid ORDER BY enrolledDate ASC", conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                        object r = cmd.ExecuteScalar();
                        if (r != null && r != DBNull.Value)
                            info.EnrolledDate = Convert.ToDateTime(r);
                    }

                    using (var cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM dbo.LessonProgress WHERE studentId=@sid AND isCompleted=1", conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                        info.LessonsCompleted = (int)cmd.ExecuteScalar();
                    }

                    using (var cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM dbo.StudentBadge WHERE studentId=@sid", conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                        info.BadgeCount = (int)cmd.ExecuteScalar();
                    }

                    using (var cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM dbo.QuizResult WHERE studentId=@sid", conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                        info.QuizAttempts = (int)cmd.ExecuteScalar();
                    }

                    using (var cmd = new SqlCommand(
                        @"SELECT TOP 1 analysisJson, overallSummary, weakTopics, strongTopics
                          FROM dbo.AILearningAnalysis WHERE studentId=@sid AND isLatest=1", conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                        using (var r = cmd.ExecuteReader())
                        {
                            if (r.Read())
                            {
                                info.AnalysisJson   = r["analysisJson"]   != DBNull.Value ? r["analysisJson"].ToString()   : "";
                                info.OverallSummary = r["overallSummary"] != DBNull.Value ? r["overallSummary"].ToString()  : "";
                                info.WeakTopics     = r["weakTopics"]     != DBNull.Value ? r["weakTopics"].ToString()      : "";
                                info.StrongTopics   = r["strongTopics"]   != DBNull.Value ? r["strongTopics"].ToString()    : "";
                            }
                        }
                    }
                }
            }
            catch { }
            return info;
        }

        private List<SkillCategory> BuildSkillCategories()
        {
            var categories = new List<SkillCategory>
            {
                new SkillCategory { Title = "Living Things",      Icon = "🌱", BgColour = ColourGreen,  TitleColour = ColourGreenDark  },
                new SkillCategory { Title = "Physical Science",   Icon = "🧲", BgColour = ColourBlue,   TitleColour = ColourBlueDark   },
                new SkillCategory { Title = "Earth & Space",      Icon = "🌍", BgColour = ColourPurple, TitleColour = ColourPurpleDark },
                new SkillCategory { Title = "Scientific Methods", Icon = "🧪", BgColour = ColourOrange, TitleColour = ColourOrangeDark }
            };

            var livingWords  = new[] { "human", "animal", "plant", "life", "living", "body", "organ", "sense", "food" };
            var physicsWords = new[] { "magnet", "force", "push", "pull", "material", "absorb", "electricity", "light", "sound", "energy", "gear", "pulley" };
            var earthWords   = new[] { "earth", "space", "planet", "weather", "sky", "water", "soil", "rock", "land", "cycle", "solar" };

            try
            {
                using (var conn = new SqlConnection(DatabaseConnectionString))
                {
                    conn.Open();

                    var completedSubtopics = new HashSet<string>();
                    var partialSubtopics   = new HashSet<string>();

                    using (var cmd = new SqlCommand(@"
                        SELECT st.subtopicId,
                               COUNT(l.lessonId) AS total,
                               SUM(CASE WHEN lp.isCompleted=1 THEN 1 ELSE 0 END) AS done
                        FROM dbo.Subtopic st
                        INNER JOIN dbo.Lesson l ON l.subtopicId = st.subtopicId
                        INNER JOIN dbo.Unit u ON u.unitId = st.unitId
                        INNER JOIN dbo.Student s ON s.currentLevelId = u.levelId
                        LEFT JOIN dbo.LessonProgress lp ON lp.lessonId = l.lessonId AND lp.studentId = @sid
                        WHERE s.studentId = @sid
                        GROUP BY st.subtopicId", conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                        using (var r = cmd.ExecuteReader())
                        {
                            while (r.Read())
                            {
                                string stId  = r["subtopicId"].ToString();
                                int total    = Convert.ToInt32(r["total"]);
                                int done     = r["done"] != DBNull.Value ? Convert.ToInt32(r["done"]) : 0;
                                if (done == total && total > 0) completedSubtopics.Add(stId);
                                else if (done > 0)              partialSubtopics.Add(stId);
                            }
                        }
                    }

                    const string unitQuery = @"
                        SELECT u.unitNameEN, st.subtopicId, st.subtopicTitleEN
                        FROM dbo.Unit u
                        INNER JOIN dbo.Student s ON s.currentLevelId = u.levelId
                        INNER JOIN dbo.Subtopic st ON st.unitId = u.unitId
                        WHERE s.studentId = @sid
                        ORDER BY u.orderNo, st.orderNo";

                    using (var cmd = new SqlCommand(unitQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                        using (var r = cmd.ExecuteReader())
                        {
                            while (r.Read())
                            {
                                string unitName    = r["unitNameEN"].ToString().ToLower();
                                string subtopicId  = r["subtopicId"].ToString();
                                string subtopicTitle = r["subtopicTitleEN"].ToString();

                                int catIdx = 3;
                                if      (livingWords.Any(k => unitName.Contains(k)))  catIdx = 0;
                                else if (physicsWords.Any(k => unitName.Contains(k))) catIdx = 1;
                                else if (earthWords.Any(k => unitName.Contains(k)))   catIdx = 2;

                                if (categories[catIdx].Skills.Count >= 5) continue;

                                string status = "NotIntroduced";
                                if      (completedSubtopics.Contains(subtopicId)) status = "Confident";
                                else if (partialSubtopics.Contains(subtopicId))   status = "Developing";

                                categories[catIdx].Skills.Add(new SkillRow { Title = subtopicTitle, Status = status });
                            }
                        }
                    }
                }
            }
            catch { }

            return categories.Where(c => c.Skills.Count > 0).ToList();
        }

        // ══════════════════════════════════════════════════════════════
        //  AI TEACHER COMMENT
        // ══════════════════════════════════════════════════════════════

        private string GetTeacherComment(ChildInfo info)
        {
            // Prefer pre-generated ParentGuidance from analysisJson
            if (!string.IsNullOrEmpty(info.AnalysisJson))
            {
                try
                {
                    var parsed   = Newtonsoft.Json.Linq.JObject.Parse(info.AnalysisJson);
                    string saved = parsed["ParentGuidance"]?.ToString() ?? "";
                    if (!string.IsNullOrEmpty(saved)) return saved;
                }
                catch { }
            }

            // Fall back to a live Nvidia API call
            string aiReply = CallNvidiaForComment(BuildTeacherPrompt(info));
            if (!string.IsNullOrEmpty(aiReply)) return aiReply;

            // Last resort: template comment using stored data columns
            return BuildTemplateComment(info);
        }

        private string BuildTeacherPrompt(ChildInfo info)
        {
            var sb = new StringBuilder();
            sb.Append("You are a primary school science teacher writing a short progress comment for a parent report card. ");
            sb.Append("Write 3 sentences maximum. Be warm, encouraging, and specific. ");
            sb.Append("Do not use bullet points. Do not invent facts. Only use the data provided.\n\n");
            sb.AppendFormat("Student: {0}\n", info.Name);
            sb.AppendFormat("Level: {0}\n", info.LevelName);
            sb.AppendFormat("Lessons completed: {0}\n", info.LessonsCompleted);
            sb.AppendFormat("Quiz attempts: {0}\n", info.QuizAttempts);
            sb.AppendFormat("Badges earned: {0}\n", info.BadgeCount);
            if (!string.IsNullOrEmpty(info.StrongTopics)) sb.AppendFormat("Strong topics: {0}\n", info.StrongTopics);
            if (!string.IsNullOrEmpty(info.WeakTopics))   sb.AppendFormat("Topics to develop: {0}\n", info.WeakTopics);
            return sb.ToString();
        }

        private string CallNvidiaForComment(string prompt)
        {
            try
            {
                string apiKey   = ConfigurationManager.AppSettings["NvidiaApiKey"];
                string model    = ConfigurationManager.AppSettings["NvidiaModel"]       ?? "meta/llama-3.1-8b-instruct";
                string endpoint = ConfigurationManager.AppSettings["NvidiaApiEndpoint"] ?? "https://integrate.api.nvidia.com/v1/chat/completions";

                if (string.IsNullOrEmpty(apiKey) || apiKey == "YOUR_NVIDIA_API_KEY_HERE") return "";

                var messages = new List<Dictionary<string, string>>
                {
                    new Dictionary<string, string> { { "role", "system" }, { "content", "Write short warm teacher-style comments for primary school reports. Max 3 sentences." } },
                    new Dictionary<string, string> { { "role", "user"   }, { "content", prompt } }
                };

                var payload = new Dictionary<string, object>
                {
                    { "model", model }, { "messages", messages },
                    { "temperature", 0.6 }, { "max_tokens", 120 }, { "stream", false }
                };

                string jsonPayload = new JavaScriptSerializer().Serialize(payload);
                byte[] bodyBytes   = Encoding.UTF8.GetBytes(jsonPayload);

                var req = (HttpWebRequest)WebRequest.Create(endpoint);
                req.Method      = "POST";
                req.ContentType = "application/json";
                req.Accept      = "application/json";
                req.Headers["Authorization"] = "Bearer " + apiKey;
                req.Timeout     = 12000;
                req.ContentLength = bodyBytes.Length;

                using (var stream = req.GetRequestStream())
                    stream.Write(bodyBytes, 0, bodyBytes.Length);

                using (var resp   = (HttpWebResponse)req.GetResponse())
                using (var reader = new StreamReader(resp.GetResponseStream()))
                {
                    string responseBody = reader.ReadToEnd();
                    var    parsed  = new JavaScriptSerializer().Deserialize<Dictionary<string, object>>(responseBody);
                    var    choices = parsed["choices"] as System.Collections.ArrayList;
                    var    first   = choices[0] as Dictionary<string, object>;
                    var    message = first["message"] as Dictionary<string, object>;
                    return message["content"].ToString().Trim();
                }
            }
            catch { return ""; }
        }

        private string BuildTemplateComment(ChildInfo info)
        {
            if (!string.IsNullOrEmpty(info.OverallSummary)) return info.OverallSummary;

            string firstName = info.Name.Contains(" ") ? info.Name.Split(' ')[0] : info.Name;
            return string.Format(
                "{0} has been making great progress in science, completing {1} lesson{2} and earning {3} badge{4}. " +
                "Keep exploring new topics and trying quizzes to build confidence. " +
                "Short daily learning sessions at home will make a big difference!",
                firstName,
                info.LessonsCompleted, info.LessonsCompleted == 1 ? "" : "s",
                info.BadgeCount,       info.BadgeCount       == 1 ? "" : "s");
        }

        // ══════════════════════════════════════════════════════════════
        //  PDF STORYBOOK LAYOUT
        // ══════════════════════════════════════════════════════════════

        private void BuildAndStreamReport()
        {
            ChildInfo info           = GatherChildData();
            List<SkillCategory> cats = BuildSkillCategories();
            string teacherComment    = GetTeacherComment(info);

            // Extra local accent colours
            BaseColor cYellow     = new BaseColor(254, 252, 232);
            BaseColor cYellowMid  = new BaseColor(253, 224,  71);
            BaseColor cYellowDark = new BaseColor(133,  77,  14);
            BaseColor cPink       = new BaseColor(253, 242, 248);
            BaseColor cPinkMid    = new BaseColor(249, 168, 212);
            BaseColor cPinkDark   = new BaseColor(157,  23,  77);
            BaseColor cAqua       = new BaseColor(236, 254, 255);
            BaseColor cAquaMid    = new BaseColor(103, 232, 249);
            BaseColor cAquaDark   = new BaseColor( 14, 116, 144);
            BaseColor cCream      = new BaseColor(255, 253, 245);

            using (var ms = new MemoryStream())
            {
                Document doc = new Document(PageSize.A4, 40, 40, 44, 44);
                PdfWriter.GetInstance(doc, ms);
                doc.Open();

                BaseFont bf  = BaseFont.CreateFont(
                    Server.MapPath("~/Fonts/Nunito-Regular.ttf"), BaseFont.IDENTITY_H, BaseFont.EMBEDDED);
                BaseFont bfB = BaseFont.CreateFont(
                    Server.MapPath("~/Fonts/Poppins-Bold.ttf"), BaseFont.IDENTITY_H, BaseFont.EMBEDDED);

                // ── SECTION 1: COVER STICKER ─────────────────────────
                // Bold indigo banner — styled like a sticker label on top.
                // Brand name, large title, and date — all centred, white text.
                PdfPTable cover = new PdfPTable(1);
                cover.WidthPercentage = 100;
                cover.SpacingAfter    = 0;

                PdfPCell cc = new PdfPCell();
                cc.BackgroundColor = ColourHero;
                cc.Border          = Rectangle.NO_BORDER;
                cc.PaddingTop      = 20;
                cc.PaddingBottom   = 16;
                cc.PaddingLeft     = 20;
                cc.PaddingRight    = 20;

                Paragraph pBrand = new Paragraph("🦊  ScienceBuddy",
                    new Font(bfB, 11, Font.NORMAL, new BaseColor(199, 210, 254)));
                pBrand.Alignment = Element.ALIGN_CENTER;
                cc.AddElement(pBrand);

                Paragraph pTitle = new Paragraph("Progress Report",
                    new Font(bfB, 26, Font.NORMAL, ColourWhite));
                pTitle.Alignment = Element.ALIGN_CENTER;
                cc.AddElement(pTitle);

                Paragraph pDate = new Paragraph(DateTime.Now.ToString("dd MMMM yyyy"),
                    new Font(bf, 9, Font.ITALIC, new BaseColor(165, 180, 252)));
                pDate.Alignment = Element.ALIGN_CENTER;
                cc.AddElement(pDate);

                cover.AddCell(cc);
                doc.Add(cover);

                // Dot-stripe divider — alternating coloured dots create a playful
                // illustrated-book divider instead of a plain horizontal line.
                DotDivider(doc, bf,
                    new BaseColor(165, 180, 252),
                    ColourHero,
                    new BaseColor(196, 181, 253));

                // ── SECTION 2: NAME-TAG PROFILE ───────────────────────
                // Looks like a name-badge lanyard card — thick indigo left stripe
                // plus a cream body. Completely different shape from the cover.
                Spacer(doc);

                PdfPTable nameTag = new PdfPTable(new float[] { 0.04f, 1 });
                nameTag.WidthPercentage = 100;
                nameTag.SpacingAfter    = 8;

                PdfPCell tagStripe = new PdfPCell(new Phrase(""));
                tagStripe.BackgroundColor = ColourHero;
                tagStripe.Border          = Rectangle.NO_BORDER;
                nameTag.AddCell(tagStripe);

                PdfPCell tagBody = new PdfPCell();
                tagBody.BackgroundColor = cCream;
                tagBody.Border          = Rectangle.BOX;
                tagBody.BorderColor     = new BaseColor(199, 210, 254);
                tagBody.BorderWidth     = 1f;
                tagBody.Padding         = 14;

                string initials = MakeInitials(info.Name);
                Paragraph pInitials = new Paragraph(initials,
                    new Font(bfB, 36, Font.NORMAL, ColourHero));
                pInitials.Alignment = Element.ALIGN_LEFT;
                tagBody.AddElement(pInitials);

                tagBody.AddElement(new Paragraph(info.Name,
                    new Font(bfB, 16, Font.NORMAL, ColourText)) { SpacingAfter = 3 });

                tagBody.AddElement(new Paragraph(
                    "🎓  " + info.LevelName + "     ⭐  " + info.XP.ToString("N0") + " XP",
                    new Font(bfB, 10, Font.NORMAL, ColourHero)) { SpacingAfter = 4 });

                if (info.EnrolledDate.HasValue)
                {
                    tagBody.AddElement(new Paragraph(
                        "Member since  " + info.EnrolledDate.Value.ToString("MMMM yyyy"),
                        new Font(bf, 9, Font.ITALIC, ColourMuted)));
                }

                nameTag.AddCell(tagBody);
                doc.Add(nameTag);

                // ── SECTION 3: SCIENCE SKILLS (sticker cards) ─────────
                // Section title uses an icon badge + large heading — no rectangular
                // ribbon. Each category card has its own thick colour top border
                // so they look like individual stickers, not one big table.
                Spacer(doc);
                StorybookTitle(doc, bfB, bf,
                    "⭐", "Science Skills",
                    "Here is what your child has been exploring this term.",
                    ColourGreenDark);

                // Legend row — uses coloured squares instead of emoji for consistent rendering
                PdfPTable legRow = new PdfPTable(1);
                legRow.WidthPercentage = 100;
                legRow.SpacingAfter    = 8;

                PdfPCell legCell = new PdfPCell();
                legCell.Border  = Rectangle.NO_BORDER;
                legCell.Padding = 4;

                // Build a mini-table with 3 coloured squares + labels inline
                PdfPTable legInner = new PdfPTable(new float[] { 0.03f, 0.2f, 0.03f, 0.2f, 0.03f, 0.31f });
                legInner.WidthPercentage = 100;

                // Green = Confident
                PdfPCell gDot = new PdfPCell(new Phrase(""));
                gDot.BackgroundColor = new BaseColor(34, 197, 94);
                gDot.Border = Rectangle.NO_BORDER;
                gDot.Padding = 4;
                legInner.AddCell(gDot);
                PdfPCell gLabel = new PdfPCell(new Phrase("Confident", new Font(bf, 8, Font.ITALIC, ColourMuted)));
                gLabel.Border = Rectangle.NO_BORDER;
                gLabel.PaddingLeft = 4;
                gLabel.VerticalAlignment = Element.ALIGN_MIDDLE;
                legInner.AddCell(gLabel);

                // Yellow = Developing
                PdfPCell yDot = new PdfPCell(new Phrase(""));
                yDot.BackgroundColor = new BaseColor(250, 204, 21);
                yDot.Border = Rectangle.NO_BORDER;
                yDot.Padding = 4;
                legInner.AddCell(yDot);
                PdfPCell yLabel = new PdfPCell(new Phrase("Developing", new Font(bf, 8, Font.ITALIC, ColourMuted)));
                yLabel.Border = Rectangle.NO_BORDER;
                yLabel.PaddingLeft = 4;
                yLabel.VerticalAlignment = Element.ALIGN_MIDDLE;
                legInner.AddCell(yLabel);

                // Grey = Not Introduced Yet
                PdfPCell wDot = new PdfPCell(new Phrase(""));
                wDot.BackgroundColor = new BaseColor(203, 213, 225);
                wDot.Border = Rectangle.NO_BORDER;
                wDot.Padding = 4;
                legInner.AddCell(wDot);
                PdfPCell wLabel = new PdfPCell(new Phrase("Not Introduced Yet", new Font(bf, 8, Font.ITALIC, ColourMuted)));
                wLabel.Border = Rectangle.NO_BORDER;
                wLabel.PaddingLeft = 4;
                wLabel.VerticalAlignment = Element.ALIGN_MIDDLE;
                legInner.AddCell(wLabel);

                legCell.AddElement(legInner);
                legRow.AddCell(legCell);
                doc.Add(legRow);

                if (cats.Count > 0)
                {
                    for (int i = 0; i < cats.Count; i += 2)
                    {
                        PdfPTable catPair = new PdfPTable(new float[] { 1, 1 });
                        catPair.WidthPercentage = 100;
                        catPair.SpacingAfter    = 8;

                        StickerSkillCard(catPair, cats[i], bfB, bf);

                        if (i + 1 < cats.Count)
                            StickerSkillCard(catPair, cats[i + 1], bfB, bf);
                        else
                        {
                            // Blank filler keeps two-column balance
                            PdfPCell blank = new PdfPCell(new Phrase(""));
                            blank.Border = Rectangle.NO_BORDER;
                            catPair.AddCell(blank);
                        }

                        doc.Add(catPair);
                    }
                }
                else
                {
                    doc.Add(new Paragraph(
                        "Start exploring lessons to unlock science skills!",
                        new Font(bf, 9, Font.ITALIC, ColourMuted)));
                }

                // ── SECTION 4: ACHIEVEMENT STICKERS ──────────────────
                // Four oversized emoji stickers in a single row — looks nothing
                // like the rectangular sections above.
                Spacer(doc);
                DotDivider(doc, bf,
                    cYellowMid,
                    new BaseColor(245, 158, 11),
                    ColourOrange);

                StorybookTitle(doc, bfB, bf,
                    "🏅", "This Month's Highlights",
                    "Celebrating your child's achievements.",
                    cYellowDark);

                PdfPTable stickerRow = new PdfPTable(new float[] { 1, 1, 1, 1 });
                stickerRow.WidthPercentage = 100;
                stickerRow.SpacingAfter    = 10;

                stickerRow.AddCell(AchievementSticker("🏅", info.BadgeCount.ToString(),       "Badges",   ColourOrange, ColourOrangeDark, bfB, bf));
                stickerRow.AddCell(AchievementSticker("📚", info.LessonsCompleted.ToString(), "Lessons",  ColourBlue,   ColourBlueDark,   bfB, bf));
                stickerRow.AddCell(AchievementSticker("⭐", info.XP.ToString("N0"),            "XP",       ColourPurple, ColourPurpleDark, bfB, bf));
                stickerRow.AddCell(AchievementSticker("🎯", info.QuizAttempts.ToString(),     "Quizzes",  ColourGreen,  ColourGreenDark,  bfB, bf));

                doc.Add(stickerRow);

                // ── SECTION 5: GOALS CLOUD ────────────────────────────
                // A cloud-shaped pink card — different feel from every section
                // above. Uses thick rounded border and generous padding.
                Spacer(doc);
                StorybookTitle(doc, bfB, bf,
                    "🎯", "Next Learning Goals",
                    "Small steps to keep growing.",
                    cPinkDark);

                PdfPTable goalCloud = new PdfPTable(1);
                goalCloud.WidthPercentage = 100;
                goalCloud.SpacingAfter    = 10;

                PdfPCell goalCell = new PdfPCell();
                goalCell.BackgroundColor = cPink;
                goalCell.Border          = Rectangle.BOX;
                goalCell.BorderColor     = cPinkMid;
                goalCell.BorderWidth     = 1.5f;
                goalCell.Padding         = 14;

                string[] goals = {
                    "Try one new quiz this week",
                    "Unlock the next badge",
                    "Complete at least 3 lessons",
                    "Explore a brand-new science topic"
                };

                // Each goal gets a visible checkbox square that parents can tick when printed
                foreach (string goal in goals)
                {
                    PdfPTable goalRow = new PdfPTable(new float[] { 0.05f, 1 });
                    goalRow.WidthPercentage = 100;
                    goalRow.SpacingAfter    = 4;

                    // Checkbox square — empty bordered cell that can be ticked with a pen
                    PdfPCell checkBox = new PdfPCell(new Phrase(""));
                    checkBox.Border      = Rectangle.BOX;
                    checkBox.BorderColor = new BaseColor(157, 23, 77);
                    checkBox.BorderWidth = 1.5f;
                    checkBox.Padding     = 5;
                    goalRow.AddCell(checkBox);

                    // Goal text
                    PdfPCell goalText = new PdfPCell(
                        new Phrase(goal, new Font(bfB, 10, Font.NORMAL, ColourText)));
                    goalText.Border      = Rectangle.NO_BORDER;
                    goalText.PaddingLeft = 8;
                    goalText.VerticalAlignment = Element.ALIGN_MIDDLE;
                    goalRow.AddCell(goalText);

                    goalCell.AddElement(goalRow);
                }

                goalCloud.AddCell(goalCell);
                doc.Add(goalCloud);

                // ── SECTION 6: AI COACH SPEECH BUBBLE ────────────────
                // Speech-bubble style — aqua left stripe + light aqua body,
                // with a large opening quote and italic teacher comment inside.
                // The fox emoji acts as the speaker.
                Spacer(doc);
                DotDivider(doc, bf, cAquaMid, cAquaDark, new BaseColor(165, 243, 252));
                StorybookTitle(doc, bfB, bf,
                    "🦊", "ScienceBuddy AI Coach",
                    "A personalised message from your child's real learning progress.",
                    cAquaDark);

                PdfPTable bubble = new PdfPTable(new float[] { 0.06f, 1 });
                bubble.WidthPercentage = 100;
                bubble.SpacingAfter    = 10;

                PdfPCell bubbleStripe = new PdfPCell(new Phrase(""));
                bubbleStripe.BackgroundColor = cAquaDark;
                bubbleStripe.Border          = Rectangle.NO_BORDER;
                bubble.AddCell(bubbleStripe);

                PdfPCell bubbleBody = new PdfPCell();
                bubbleBody.BackgroundColor = cAqua;
                bubbleBody.Border          = Rectangle.BOX;
                bubbleBody.BorderColor     = cAquaMid;
                bubbleBody.BorderWidth     = 1f;
                bubbleBody.Padding         = 16;
                bubbleBody.PaddingLeft     = 18;

                bubbleBody.AddElement(new Paragraph("\u201C",
                    new Font(bfB, 24, Font.NORMAL, cAquaDark)) { SpacingAfter = 2 });

                bubbleBody.AddElement(new Paragraph(teacherComment,
                    new Font(bf, 10, Font.ITALIC, ColourText))
                    { Leading = 16, SpacingAfter = 8 });

                bubbleBody.AddElement(new Paragraph(
                    "✦  Generated using NVIDIA AI from your child's real learning data.",
                    new Font(bf, 8, Font.ITALIC, ColourMuted)));

                bubble.AddCell(bubbleBody);
                doc.Add(bubble);

                // ── FOOTER ────────────────────────────────────────────
                Spacer(doc);
                PdfPTable footer = new PdfPTable(1);
                footer.WidthPercentage = 100;

                PdfPCell footerCell = new PdfPCell();
                footerCell.BackgroundColor = ColourHero;
                footerCell.Border          = Rectangle.NO_BORDER;
                footerCell.Padding         = 14;

                Paragraph footerLine = new Paragraph(
                    "🌟   Every small discovery brings your child one step closer to becoming a confident young scientist.   🌟",
                    new Font(bf, 9, Font.ITALIC, new BaseColor(199, 210, 254)));
                footerLine.Alignment = Element.ALIGN_CENTER;
                footerCell.AddElement(footerLine);

                footer.AddCell(footerCell);
                doc.Add(footer);

                doc.Close();

                // Stream the finished PDF as a file download
                byte[] pdfBytes    = ms.ToArray();
                string safeChildName = info.Name.Replace(" ", "_").Replace("/", "");
                string fileName    = "ScienceBuddy_Report_" + safeChildName + "_"
                    + DateTime.Now.ToString("yyyyMMdd") + ".pdf";

                Response.Clear();
                Response.ContentType = "application/pdf";
                Response.AddHeader("Content-Disposition",
                    "attachment; filename=\"" + fileName + "\"");
                Response.BinaryWrite(pdfBytes);
                Response.End();
            }
        }

        // ══════════════════════════════════════════════════════════════
        //  LAYOUT HELPER METHODS
        // ══════════════════════════════════════════════════════════════

        /// <summary>
        /// Storybook section title: icon badge on the left, large heading + subtitle
        /// stacked on the right. No full-width coloured rectangle.
        /// </summary>
        private void StorybookTitle(Document doc, BaseFont bfB, BaseFont bf,
            string icon, string heading, string subtitle, BaseColor accentColour)
        {
            PdfPTable tbl = new PdfPTable(new float[] { 0.12f, 1 });
            tbl.WidthPercentage = 100;
            tbl.SpacingBefore   = 6;
            tbl.SpacingAfter    = 6;

            // Circular-feel icon badge
            PdfPCell iconCell = new PdfPCell(
                new Phrase(icon, new Font(bfB, 18, Font.NORMAL, ColourWhite)));
            iconCell.BackgroundColor      = accentColour;
            iconCell.Border               = Rectangle.NO_BORDER;
            iconCell.Padding              = 10;
            iconCell.HorizontalAlignment  = Element.ALIGN_CENTER;
            iconCell.VerticalAlignment    = Element.ALIGN_MIDDLE;
            tbl.AddCell(iconCell);

            PdfPCell textCell = new PdfPCell();
            textCell.Border         = Rectangle.NO_BORDER;
            textCell.PaddingLeft    = 10;
            textCell.VerticalAlignment = Element.ALIGN_MIDDLE;

            textCell.AddElement(new Paragraph(heading,
                new Font(bfB, 15, Font.NORMAL, accentColour)));
            if (!string.IsNullOrEmpty(subtitle))
            {
                textCell.AddElement(new Paragraph(subtitle,
                    new Font(bf, 8, Font.ITALIC, ColourMuted)));
            }

            tbl.AddCell(textCell);
            doc.Add(tbl);
        }

        /// <summary>
        /// Playful dot-stripe divider — alternating coloured dots that break up
        /// sections like an illustrated children's book page separator.
        /// </summary>
        private void DotDivider(Document doc, BaseFont bf,
            BaseColor c1, BaseColor c2, BaseColor c3)
        {
            BaseColor[] palette = { c1, c2, c3, c2, c1, c3, c2, c1, c3, c2, c1, c2, c3 };

            PdfPTable divider = new PdfPTable(palette.Length);
            divider.WidthPercentage = 100;
            divider.SpacingBefore   = 4;
            divider.SpacingAfter    = 4;

            foreach (BaseColor colour in palette)
            {
                PdfPCell dot = new PdfPCell(new Phrase("  ", new Font(bf, 5)));
                dot.BackgroundColor = colour;
                dot.Border          = Rectangle.NO_BORDER;
                dot.Padding         = 3;
                divider.AddCell(dot);
            }

            doc.Add(divider);
        }

        /// <summary>
        /// A tiny vertical gap between major sections so nothing feels cramped.
        /// </summary>
        private void Spacer(Document doc)
        {
            doc.Add(new Paragraph(" ") { SpacingAfter = 1 });
        }

        /// <summary>
        /// One skill-category sticker card inside a two-column pair.
        /// Each card has a thick top border in its category colour to differentiate
        /// it from the others — looks like a real physical sticker card.
        /// Skills get a coloured square indicator (green/yellow/grey) that actually
        /// renders visibly in iTextSharp instead of relying on emoji.
        /// </summary>
        private void StickerSkillCard(PdfPTable row, SkillCategory cat,
            BaseFont bfB, BaseFont bf)
        {
            PdfPCell cell = new PdfPCell();
            cell.BackgroundColor    = cat.BgColour;
            cell.BorderWidthTop     = 3.5f;
            cell.BorderColorTop     = cat.TitleColour;
            cell.BorderWidthLeft    = 0.5f;
            cell.BorderWidthRight   = 0.5f;
            cell.BorderWidthBottom  = 0.5f;
            cell.BorderColorLeft    = new BaseColor(226, 232, 240);
            cell.BorderColorRight   = new BaseColor(226, 232, 240);
            cell.BorderColorBottom  = new BaseColor(226, 232, 240);
            cell.Padding            = 10;

            cell.AddElement(new Paragraph(
                cat.Icon + "  " + cat.Title,
                new Font(bfB, 11, Font.NORMAL, cat.TitleColour)) { SpacingAfter = 6 });

            // Each skill row uses a coloured indicator table: [colour block] [skill text]
            foreach (SkillRow skill in cat.Skills)
            {
                BaseColor indicatorColour;
                if (skill.Status == "Confident")
                    indicatorColour = new BaseColor(34, 197, 94);   // green
                else if (skill.Status == "Developing")
                    indicatorColour = new BaseColor(250, 204, 21);  // yellow
                else
                    indicatorColour = new BaseColor(203, 213, 225); // grey

                PdfPTable skillRow = new PdfPTable(new float[] { 0.06f, 1 });
                skillRow.WidthPercentage = 100;
                skillRow.SpacingAfter    = 2;

                // Coloured indicator square
                PdfPCell dotCell = new PdfPCell(new Phrase(""));
                dotCell.BackgroundColor = indicatorColour;
                dotCell.Border          = Rectangle.NO_BORDER;
                dotCell.Padding         = 4;
                skillRow.AddCell(dotCell);

                // Skill text
                PdfPCell textCell = new PdfPCell(
                    new Phrase(skill.Title, new Font(bf, 9, Font.NORMAL, ColourText)));
                textCell.Border     = Rectangle.NO_BORDER;
                textCell.PaddingLeft = 5;
                textCell.Padding    = 3;
                skillRow.AddCell(textCell);

                cell.AddElement(skillRow);
            }

            row.AddCell(cell);
        }

        /// <summary>
        /// One circular-feel achievement sticker: large emoji, bold big number, small label.
        /// Equal padding on all sides gives it a badge/sticker appearance.
        /// </summary>
        private PdfPCell AchievementSticker(string emoji, string count, string label,
            BaseColor bg, BaseColor textColour, BaseFont bfB, BaseFont bf)
        {
            PdfPCell cell = new PdfPCell();
            cell.BackgroundColor = bg;
            cell.Border          = Rectangle.BOX;
            cell.BorderColor     = new BaseColor(226, 232, 240);
            cell.BorderWidth     = 0.5f;
            cell.Padding         = 14;
            cell.HorizontalAlignment = Element.ALIGN_CENTER;

            Paragraph pEmoji = new Paragraph(emoji,
                new Font(bfB, 20, Font.NORMAL, textColour));
            pEmoji.Alignment = Element.ALIGN_CENTER;
            cell.AddElement(pEmoji);

            Paragraph pCount = new Paragraph(count,
                new Font(bfB, 20, Font.NORMAL, textColour));
            pCount.Alignment = Element.ALIGN_CENTER;
            cell.AddElement(pCount);

            Paragraph pLabel = new Paragraph(label,
                new Font(bf, 8, Font.NORMAL, ColourMuted));
            pLabel.Alignment = Element.ALIGN_CENTER;
            cell.AddElement(pLabel);

            return cell;
        }

        /// <summary>
        /// Builds two-letter or one-letter initials from the child's full name.
        /// Displayed as the avatar inside the name-tag profile section.
        /// </summary>
        private string MakeInitials(string fullName)
        {
            if (string.IsNullOrEmpty(fullName)) return "?";
            string[] parts = fullName.Trim().Split(' ');
            if (parts.Length >= 2)
                return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
            return fullName[0].ToString().ToUpper();
        }
    }
}
