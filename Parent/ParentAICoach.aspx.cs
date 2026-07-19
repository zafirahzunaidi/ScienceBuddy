using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Net;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Parent
{
    public partial class ParentAICoach : Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected string CurrentLanguage = "EN";
        protected string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }

        private string _userId = "";
        private string _parentId = "";
        private string _selectedChildId = "";
        private string _childName = "";
        private string _currentTopic = "";

        // Chat history stored in session
        private List<Dictionary<string, string>> ChatHistory
        {
            get { return Session["ParentAIChatHistory"] as List<Dictionary<string, string>>; }
            set { Session["ParentAIChatHistory"] = value; }
        }

        private string ChatChildId
        {
            get { return Session["ParentAIChatChildId"] as string ?? ""; }
            set { Session["ParentAIChatChildId"] = value; }
        }

        // --- Page Load ---

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!CheckAuth()) return;

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            LoadLang();
            LoadUnreadBadge();
            _userId = Session["userId"].ToString();
            LoadParentId();

            if (!IsPostBack)
            {
                LoadChildren();
                InitChild();
            }
            else
            {
                _selectedChildId = ddlSidebarChild.SelectedValue;
                LoadChildContext();
            }
        }

        private bool CheckAuth()
        {
            if (Session["userId"] == null || Session["role"] == null ||
                Session["role"].ToString() != "Parent")
            {
                Response.Redirect("~/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return false;
            }
            return true;
        }

        protected void SidebarChildChanged(object sender, EventArgs e)
        {
            Session["selectedChildId"] = ddlSidebarChild.SelectedValue;
            // Clear chat when child changes to prevent cross-child data leaks
            ChatHistory = null;
            ChatChildId = "";
            InitChild();
        }

        private void InitChild()
        {
            string savedChild = Session["selectedChildId"] as string;
            if (!string.IsNullOrEmpty(savedChild) &&
                ddlSidebarChild.Items.FindByValue(savedChild) != null)
            {
                ddlSidebarChild.SelectedValue = savedChild;
            }
            else if (ddlSidebarChild.Items.Count > 0)
            {
                Session["selectedChildId"] = ddlSidebarChild.Items[0].Value;
                ddlSidebarChild.SelectedValue = ddlSidebarChild.Items[0].Value;
            }

            _selectedChildId = ddlSidebarChild.SelectedValue;

            if (ChatChildId != _selectedChildId)
            {
                ChatHistory = null;
                ChatChildId = _selectedChildId;
            }

            LoadChildContext();
            BuildCoachingPlan();
            BuildChips();
            RenderChatMessages();
        }

        // --- Load Child Info ---

        private void LoadChildContext()
        {
            if (string.IsNullOrEmpty(_selectedChildId)) return;

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    using (var cmd = new SqlCommand(
                        "SELECT ISNULL(nickname, name) FROM dbo.Student WHERE studentId = @sid", conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                        object result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                            _childName = result.ToString();
                    }

                    // Get weakest or most recent topic
                    using (var cmd = new SqlCommand(
                        @"SELECT TOP 1 weakTopics FROM dbo.AILearningAnalysis
                          WHERE studentId = @sid AND isLatest = 1 AND weakTopics IS NOT NULL AND weakTopics <> ''", conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                        object result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            string topics = result.ToString();
                            _currentTopic = topics.Contains(",") ? topics.Split(',')[0].Trim() : topics.Trim();
                        }
                    }

                    // Fallback: use latest unit name
                    if (string.IsNullOrEmpty(_currentTopic))
                    {
                        using (var cmd = new SqlCommand(
                            @"SELECT TOP 1 u.unitNameEN FROM dbo.Unit u
                              INNER JOIN dbo.Student s ON s.currentLevelId = u.levelId
                              WHERE s.studentId = @sid ORDER BY u.orderNo DESC", conn))
                        {
                            cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                            object result = cmd.ExecuteScalar();
                            if (result != null && result != DBNull.Value)
                                _currentTopic = result.ToString();
                        }
                    }
                }
            }
            catch { }

            if (string.IsNullOrEmpty(_currentTopic))
                _currentTopic = T("Science", "Sains");
        }

        // --- Coaching Plan ---

        private void BuildCoachingPlan()
        {
            if (string.IsNullOrEmpty(_selectedChildId))
            {
                pnlCoachingPlan.Visible = false;
                return;
            }

            pnlCoachingPlan.Visible = true;

            string step1Text = string.Format(
                T("Ask {0} what they already know about {1} before their next lesson. This helps activate prior knowledge.",
                  "Tanya {0} apa yang mereka sudah tahu tentang {1} sebelum pelajaran seterusnya. Ini membantu mengaktifkan pengetahuan sedia ada."),
                _childName, _currentTopic);

            string step2Text = GetRecommendedGoal();

            string step3Text = string.Format(
                T("Try a fun activity with {0}: find three real-life examples of {1} around the house or neighbourhood together!",
                  "Cuba aktiviti menarik dengan {0}: cari tiga contoh {1} dalam kehidupan sebenar di sekitar rumah atau kejiranan bersama-sama!"),
                _childName, _currentTopic);

            litStep1.Text = Server.HtmlEncode(step1Text);
            litStep2.Text = Server.HtmlEncode(step2Text);
            litStep3.Text = Server.HtmlEncode(step3Text);
        }

        private string GetRecommendedGoal()
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // Check parent-child link first
                    string spId = "";
                    using (var cmd = new SqlCommand(
                        "SELECT studentParentId FROM dbo.StudentParent WHERE parentId=@pid AND studentId=@sid", conn))
                    {
                        cmd.Parameters.AddWithValue("@pid", _parentId);
                        cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                        object r = cmd.ExecuteScalar();
                        if (r != null && r != DBNull.Value) spId = r.ToString();
                    }

                    if (!string.IsNullOrEmpty(spId))
                    {
                        using (var cmd = new SqlCommand(
                            @"SELECT TOP 1 t.taskTitle FROM dbo.SPTask t
                              INNER JOIN dbo.StudyPlan sp ON t.studyPlanId = sp.studyPlanId
                              WHERE sp.studentParentId = @spid AND t.isCompleted = 0
                              ORDER BY t.orderNo", conn))
                        {
                            cmd.Parameters.AddWithValue("@spid", spId);
                            object r = cmd.ExecuteScalar();
                            if (r != null && r != DBNull.Value)
                            {
                                return string.Format(
                                    T("Complete the study plan task: \"{0}\"",
                                      "Selesaikan tugasan pelan belajar: \"{0}\""), r.ToString());
                            }
                        }
                    }
                }
            }
            catch { }

            return string.Format(
                T("Complete at least one lesson in {0} this week and try the unit quiz.",
                  "Selesaikan sekurang-kurangnya satu pelajaran {0} minggu ini dan cuba kuiz unit."),
                _currentTopic);
        }

        // --- Quick Chips ---

        private void BuildChips()
        {
            string chip1 = string.Format(T("How can I help {0} this week?", "Bagaimana saya boleh bantu {0} minggu ini?"), _childName);
            string chip2 = T("What should we focus on next?", "Apa yang perlu difokuskan seterusnya?");
            string chip3 = string.Format(T("Suggest a fun activity for {0}.", "Cadangkan aktiviti menarik untuk {0}."), _currentTopic);
            string chip4 = string.Format(T("What question can I ask {0} tonight?", "Soalan apa boleh saya tanya {0} malam ini?"), _childName);

            var sb = new StringBuilder();
            sb.AppendFormat("<button type='button' class='pt-ai-coach-chip' onclick=\"fillChip('{0}')\"><i class='bi bi-lightbulb-fill'></i> {1}</button>",
                HttpUtility.HtmlAttributeEncode(chip1), Server.HtmlEncode(chip1));
            sb.AppendFormat("<button type='button' class='pt-ai-coach-chip' onclick=\"fillChip('{0}')\"><i class='bi bi-bullseye'></i> {1}</button>",
                HttpUtility.HtmlAttributeEncode(chip2), Server.HtmlEncode(chip2));
            sb.AppendFormat("<button type='button' class='pt-ai-coach-chip' onclick=\"fillChip('{0}')\"><i class='bi bi-puzzle-fill'></i> {1}</button>",
                HttpUtility.HtmlAttributeEncode(chip3), Server.HtmlEncode(chip3));
            sb.AppendFormat("<button type='button' class='pt-ai-coach-chip' onclick=\"fillChip('{0}')\"><i class='bi bi-chat-heart-fill'></i> {1}</button>",
                HttpUtility.HtmlAttributeEncode(chip4), Server.HtmlEncode(chip4));

            litChips.Text = sb.ToString();
        }

        // --- Chat Send & Render ---

        protected void BtnSend_Click(object sender, EventArgs e)
        {
            string userMessage = txtMessage.Text.Trim();
            if (string.IsNullOrEmpty(userMessage)) return;

            if (ChatHistory == null)
                ChatHistory = new List<Dictionary<string, string>>();

            ChatHistory.Add(new Dictionary<string, string> { { "role", "user" }, { "content", userMessage } });

            string aiReply = GetAIResponse(userMessage);
            ChatHistory.Add(new Dictionary<string, string> { { "role", "assistant" }, { "content", aiReply } });

            txtMessage.Text = "";
            RenderChatMessages();

            ScriptManager.RegisterStartupScript(this, GetType(), "ScrollChat",
                "setTimeout(function(){ var a=document.getElementById('chatArea'); if(a) a.scrollTop=a.scrollHeight; },100);", true);
        }

        private void RenderChatMessages()
        {
            pnlChatMessages.Controls.Clear();
            var sb = new StringBuilder();

            string greeting = string.Format(
                T("Hi! I am ScienceBuddy Coach. I know {0}'s latest results — ask me how to help!",
                  "Hi! Saya Jurulatih ScienceBuddy. Saya tahu keputusan terkini {0} — tanya saya bagaimana untuk membantu!"),
                _childName);

            sb.Append("<div class='pt-ai-coach-bubble pt-ai-coach-bubble-ai'>");
            sb.Append(Server.HtmlEncode(greeting));
            sb.Append("</div>");

            var history = ChatHistory;
            if (history != null)
            {
                foreach (var msg in history)
                {
                    if (msg["role"] == "user")
                    {
                        sb.Append("<div class='pt-ai-coach-bubble pt-ai-coach-bubble-user'>");
                        sb.Append(Server.HtmlEncode(msg["content"]));
                        sb.Append("</div>");
                    }
                    else
                    {
                        sb.Append("<div class='pt-ai-coach-bubble pt-ai-coach-bubble-ai'>");
                        sb.Append(FormatAIResponse(msg["content"]));

                        string actionChips = BuildActionChips(msg["content"]);
                        if (!string.IsNullOrEmpty(actionChips))
                        {
                            sb.Append("<div class='pt-ai-coach-action-row'>");
                            sb.Append(actionChips);
                            sb.Append("</div>");
                        }
                        sb.Append("</div>");
                    }
                }
            }

            pnlChatMessages.Controls.Add(new LiteralControl(sb.ToString()));
        }

        // Formats AI response into readable HTML (encodes first for safety, then applies formatting)
        private string FormatAIResponse(string rawResponse)
        {
            if (string.IsNullOrEmpty(rawResponse)) return "";

            string safe = Server.HtmlEncode(rawResponse);

            // Strip markdown bold/italic
            safe = safe.Replace("**", "");
            safe = safe.Replace("__", "");
            safe = safe.Replace("*", "");
            safe = safe.Replace("_", " ");

            // Paragraph breaks
            safe = safe.Replace("\r\n\r\n", "<br/><br/>");
            safe = safe.Replace("\n\n", "<br/><br/>");
            safe = safe.Replace("\r\n", "<br/>");
            safe = safe.Replace("\n", "<br/>");

            // Format numbered steps
            for (int i = 1; i <= 6; i++)
            {
                string pattern = "<br/>" + i + ". ";
                string replacement = "<br/><span class='pt-ai-step'>" + i + ". </span>";
                safe = safe.Replace(pattern, replacement);
            }

            // Bullet points
            safe = safe.Replace("<br/>- ", "<br/><span class='pt-ai-bullet'>• </span>");

            safe = CleanHeadingFormatting(safe);
            return safe;
        }

        private string CleanHeadingFormatting(string html)
        {
            string[] patterns = {
                "💡", "🧪", "💬", "🔍", "🌱", "⭐", "🎯", "✅", "📈"
            };

            foreach (string emoji in patterns)
            {
                string encoded = Server.HtmlEncode(emoji);
                int startIdx = 0;

                while (true)
                {
                    int pos = html.IndexOf(encoded, startIdx);
                    if (pos < 0) break;

                    int endPos = html.IndexOf("<br/>", pos);
                    if (endPos < 0) endPos = html.Length;

                    string headingText = html.Substring(pos, endPos - pos);
                    string replacement = "<strong class='pt-ai-section-heading'>"
                        + headingText + "</strong>";

                    html = html.Substring(0, pos) + replacement + html.Substring(endPos);
                    startIdx = pos + replacement.Length;
                }
            }

            return html;
        }

        // Scans AI response for keywords and returns relevant action links (max 3)
        private string BuildActionChips(string aiResponse)
        {
            if (string.IsNullOrEmpty(aiResponse)) return "";

            string responseLower = aiResponse.ToLower();
            var actions = new List<string>();

            if (responseLower.Contains("study plan") || responseLower.Contains("task") || responseLower.Contains("plan"))
                actions.Add(MakeActionChip("bi-journal-plus", T("Add to Study Plan", "Tambah ke Pelan"), "~/Parent/EditStudyPlan.aspx"));

            if (responseLower.Contains("quiz") || responseLower.Contains("score") || responseLower.Contains("test"))
                actions.Add(MakeActionChip("bi-patch-check", T("View Quiz Results", "Lihat Keputusan Kuiz"), "~/Parent/QuizResults.aspx"));

            if (responseLower.Contains("reward") || responseLower.Contains("celebrate") || responseLower.Contains("motivat"))
                actions.Add(MakeActionChip("bi-gift-fill", T("Add Reward", "Tambah Ganjaran"), "~/Parent/EditStudyPlan.aspx"));

            if (responseLower.Contains("progress") || responseLower.Contains("improve") || responseLower.Contains("streak"))
                actions.Add(MakeActionChip("bi-bar-chart-line", T("View Progress", "Lihat Kemajuan"), "~/Parent/ChildProgress.aspx"));

            if (responseLower.Contains("lesson") || responseLower.Contains("topic") || responseLower.Contains("module") || responseLower.Contains("unit"))
                actions.Add(MakeActionChip("bi-journal-bookmark", T("View Learning Journey", "Lihat Perjalanan"), "~/Parent/EnrolledModules.aspx"));

            if (responseLower.Contains("contact teacher") || responseLower.Contains("speak to teacher") || responseLower.Contains("ask the teacher"))
                actions.Add(MakeActionChip("bi-chat-dots-fill", T("Chat with Teacher", "Sembang dengan Guru"), "~/Parent/ParentTeacherCommunication.aspx"));

            if (responseLower.Contains("badge") || responseLower.Contains("achievement") || responseLower.Contains("earn"))
                actions.Add(MakeActionChip("bi-award-fill", T("View Child Profile", "Lihat Profil Anak"), "~/Parent/ChildProfile.aspx"));

            if (responseLower.Contains("forum") || responseLower.Contains("community") || responseLower.Contains("parent"))
                actions.Add(MakeActionChip("bi-people-fill", T("Visit Forum", "Lawati Forum"), "~/Parent/Forum.aspx"));

            if (responseLower.Contains("report") || responseLower.Contains("download") || responseLower.Contains("pdf"))
                actions.Add(MakeActionChip("bi-file-earmark-pdf", T("Download Report", "Muat Turun Laporan"), "~/Parent/DownloadReport.aspx"));

            if (responseLower.Contains("notification") || responseLower.Contains("alert") || responseLower.Contains("message"))
                actions.Add(MakeActionChip("bi-bell-fill", T("Check Notifications", "Semak Notifikasi"), "~/Parent/ParentNotifications.aspx"));

            if (actions.Count == 0) return "";
            if (actions.Count > 3) actions = actions.GetRange(0, 3);
            return string.Join("", actions);
        }

        private string MakeActionChip(string icon, string label, string url)
        {
            string resolvedUrl = ResolveUrl(url);
            return string.Format(
                "<a href='{0}' class='pt-ai-coach-action-chip'><i class='bi {1}'></i> {2}</a>",
                resolvedUrl, icon, Server.HtmlEncode(label));
        }

        // --- AI API Call ---

        private string GetAIResponse(string userMessage)
        {
            try
            {
                string apiKey   = ConfigurationManager.AppSettings["NvidiaApiKey"];
                string model    = ConfigurationManager.AppSettings["NvidiaModel"] ?? "meta/llama-3.1-8b-instruct";
                string endpoint = ConfigurationManager.AppSettings["NvidiaApiEndpoint"]
                    ?? "https://integrate.api.nvidia.com/v1/chat/completions";

                if (string.IsNullOrEmpty(apiKey) || apiKey == "YOUR_NVIDIA_API_KEY_HERE")
                    return T("AI service is not available right now.", "Perkhidmatan AI tidak tersedia sekarang.");

                string learningContext = BuildLearningContext();

                var messages = new List<Dictionary<string, string>>();

                messages.Add(new Dictionary<string, string>
                {
                    { "role", "system" },
                    { "content", @"You are ScienceBuddy Parent Coach — a warm, friendly education coach who speaks directly to parents in a natural conversational tone.

VOICE:
- Write like an experienced primary school teacher giving advice over a cup of tea.
- Be warm, encouraging, natural and practical.
- Never sound like a template or report.
- Use the child's name naturally but not in every sentence.
- Do NOT use markdown bold (**) or italic (*). Write plain text only.

CURRICULUM RULES:
- The CURRICULUM CONTENT section is your primary source of truth.
- ALL advice must come from the actual ScienceBuddy lessons provided.
- Do NOT invent content not in the curriculum.
- Only move to another topic when the child has completed the current one.

BANNED PHRASES:
Never use: 'The real learning data shows', 'This recommendation is based on', 'will demonstrate an understanding', 'This activity helps develop', 'will be able to', 'It seems', 'I would recommend', 'She may need'.

==================================================
INTENT-BASED RESPONSES
==================================================

Do NOT use a fixed response template for every question.

Before writing any answer, silently determine:
1. What is the parent really asking?
2. What information from the child's data and curriculum is relevant?
3. Does this question require an explanation, activity, comparison, encouragement, troubleshooting, planning, or clarification?
4. What is the clearest way to answer THIS specific question?
5. If this is a follow-up question, continue the conversation naturally — do not restart with the same structure.

Do not expose this reasoning. Only produce the final parent-friendly response.

Every response should feel different because different questions require different answers. Adapt the structure, length and detail to the actual question.

GUIDELINES FOR DIFFERENT INTENTS:

When the parent asks WHAT TO FOCUS ON:
- State one clear priority, explain why, give one goal and one brief suggestion.

When the parent asks for AN ACTIVITY:
- Give a proper detailed activity: creative name, purpose, materials list, numbered steps (4-6), conversation prompts (2-3 questions), and what it teaches.

When the parent asks HOW TO HELP:
- Explain what the child is learning, why it matters, and give 3 practical ways to help.

When the parent asks for QUESTIONS TO ASK:
- Provide 5-8 conversation questions with brief explanations of why each is useful. Do NOT suggest activities.

When the parent asks to EXPLAIN A TOPIC:
- Start simple, use analogies, explain difficult words. Do NOT suggest activities unless asked.

When the parent asks about PERFORMANCE OR STRUGGLES:
- Give possible reasons, evidence from learning data, one suggestion, one next step.

When the parent asks about MOTIVATION, CONFIDENCE, REWARDS:
- Give warm practical encouragement strategies that connect to the child's actual achievements.

When the parent asks about STUDY HABITS or PLANNING:
- Give practical routine suggestions tied to the child's ScienceBuddy study plan.

When the parent asks FOLLOW-UP QUESTIONS:
- Continue naturally from the previous response. Do not restart from scratch.

For ANY OTHER QUESTION not listed above:
- Understand the intent, choose the clearest structure, and answer naturally.

==================================================
ACTIVITY FORMAT (only when an activity is needed):
==================================================
- Creative activity name
- Purpose (1 sentence connecting to the lesson)
- Materials (bullet list, household items only)
- Steps (numbered, 4-6 clear steps)
- Conversation prompts (2-3 questions)
- What this teaches (1 sentence)

==================================================
IMPORTANT:
- Do NOT force every response into the same template.
- Vary your response structure based on what was asked.
- End every response with one warm encouraging sentence.
- Maximum 200 words for simple questions, up to 350 for detailed activities.
- Use emoji section headings only where they genuinely help readability — not on every response." }
                });

                if (!string.IsNullOrEmpty(learningContext))
                {
                    messages.Add(new Dictionary<string, string>
                    {
                        { "role", "system" },
                        { "content", "Here is the child's real learning data. Use it to give specific advice:\n" + learningContext }
                    });
                }

                // Include last 6 messages for conversation continuity
                var history = ChatHistory;
                if (history != null)
                {
                    int startIdx = Math.Max(0, history.Count - 6);
                    for (int i = startIdx; i < history.Count - 1; i++)
                        messages.Add(history[i]);
                }

                messages.Add(new Dictionary<string, string>
                {
                    { "role", "user" },
                    { "content", userMessage }
                });

                var payload = new Dictionary<string, object>
                {
                    { "model", model },
                    { "messages", messages },
                    { "max_tokens", 500 },
                    { "stream", false }
                };

                var serializer = new JavaScriptSerializer();
                string jsonPayload = serializer.Serialize(payload);
                byte[] requestBytes = Encoding.UTF8.GetBytes(jsonPayload);

                var req = (HttpWebRequest)WebRequest.Create(endpoint);
                req.Method      = "POST";
                req.ContentType = "application/json";
                req.Accept      = "application/json";
                req.Headers["Authorization"] = "Bearer " + apiKey;
                req.Timeout       = 20000;
                req.ContentLength = requestBytes.Length;

                using (var stream = req.GetRequestStream())
                    stream.Write(requestBytes, 0, requestBytes.Length);

                using (var resp = (HttpWebResponse)req.GetResponse())
                using (var reader = new StreamReader(resp.GetResponseStream()))
                {
                    string responseBody = reader.ReadToEnd();
                    var parsed  = serializer.Deserialize<Dictionary<string, object>>(responseBody);
                    var choices = parsed["choices"] as System.Collections.ArrayList;
                    var first   = choices[0] as Dictionary<string, object>;
                    var msg     = first["message"] as Dictionary<string, object>;
                    return msg["content"].ToString().Trim();
                }
            }
            catch
            {
                return T("I couldn't process that right now. Please try again.",
                    "Saya tidak dapat memproses itu sekarang. Sila cuba lagi.");
            }
        }

        // --- Build Learning Context for AI ---

        private string BuildLearningContext()
        {
            var sb = new StringBuilder();
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    sb.AppendFormat("Child name: {0}\n", _childName);

                    using (var cmd = new SqlCommand(
                        @"SELECT s.XP, ISNULL(l.levelNameEN,'-') AS lvl
                          FROM dbo.Student s LEFT JOIN dbo.[Level] l ON l.levelId=s.currentLevelId
                          WHERE s.studentId=@sid", conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                        using (var r = cmd.ExecuteReader())
                        {
                            if (r.Read())
                            {
                                sb.AppendFormat("Level: {0}\n", r["lvl"]);
                                sb.AppendFormat("XP: {0}\n", r["XP"]);
                            }
                        }
                    }

                    using (var cmd = new SqlCommand(
                        "SELECT AVG(percentage) FROM dbo.QuizResult WHERE studentId=@sid", conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                        object r = cmd.ExecuteScalar();
                        if (r != null && r != DBNull.Value)
                            sb.AppendFormat("Quiz average: {0:F0}%\n", Convert.ToDecimal(r));
                    }

                    using (var cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM dbo.LessonProgress WHERE studentId=@sid AND isCompleted=1", conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                        sb.AppendFormat("Lessons completed: {0}\n", (int)cmd.ExecuteScalar());
                    }

                    using (var cmd = new SqlCommand(
                        @"SELECT TOP 1 weakTopics, strongTopics, overallSummary
                          FROM dbo.AILearningAnalysis WHERE studentId=@sid AND isLatest=1", conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                        using (var r = cmd.ExecuteReader())
                        {
                            if (r.Read())
                            {
                                string weak = r["weakTopics"] != DBNull.Value ? r["weakTopics"].ToString() : "";
                                string strong = r["strongTopics"] != DBNull.Value ? r["strongTopics"].ToString() : "";
                                string summary = r["overallSummary"] != DBNull.Value ? r["overallSummary"].ToString() : "";
                                if (!string.IsNullOrEmpty(strong)) sb.AppendFormat("Strong topics: {0}\n", strong);
                                if (!string.IsNullOrEmpty(weak)) sb.AppendFormat("Weak topics: {0}\n", weak);
                                if (!string.IsNullOrEmpty(summary)) sb.AppendFormat("Summary: {0}\n", summary);
                            }
                        }
                    }

                    using (var cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM dbo.StudentBadge WHERE studentId=@sid", conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                        sb.AppendFormat("Badges earned: {0}\n", (int)cmd.ExecuteScalar());
                    }

                    sb.Append("\n--- CURRICULUM CONTENT (use this as primary source of truth) ---\n");
                    AppendLessonContext(conn, sb);
                }
            }
            catch { }
            return sb.ToString();
        }

        // Gets current lesson + neighbours and appends to AI context
        private void AppendLessonContext(SqlConnection conn, StringBuilder sb)
        {
            string currentLessonId = "";
            string currentSubtopicId = "";

            // Find first incomplete lesson in curriculum order
            using (var cmd = new SqlCommand(@"
                SELECT TOP 1 l.lessonId, l.subtopicId
                FROM dbo.Lesson l
                INNER JOIN dbo.Subtopic st ON l.subtopicId = st.subtopicId
                INNER JOIN dbo.Unit u ON st.unitId = u.unitId
                INNER JOIN dbo.Student s ON s.currentLevelId = u.levelId
                WHERE s.studentId = @sid
                  AND l.lessonId NOT IN (
                      SELECT lessonId FROM dbo.LessonProgress 
                      WHERE studentId = @sid AND isCompleted = 1)
                ORDER BY u.orderNo, st.orderNo, l.orderNo", conn))
            {
                cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                using (var r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        currentLessonId = r["lessonId"].ToString();
                        currentSubtopicId = r["subtopicId"].ToString();
                    }
                }
            }

            // If all done, use last completed
            if (string.IsNullOrEmpty(currentLessonId))
            {
                using (var cmd = new SqlCommand(@"
                    SELECT TOP 1 lp.lessonId, l.subtopicId
                    FROM dbo.LessonProgress lp
                    INNER JOIN dbo.Lesson l ON lp.lessonId = l.lessonId
                    WHERE lp.studentId = @sid AND lp.isCompleted = 1
                    ORDER BY lp.completedDate DESC", conn))
                {
                    cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                    using (var r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            currentLessonId = r["lessonId"].ToString();
                            currentSubtopicId = r["subtopicId"].ToString();
                        }
                    }
                }
            }

            if (string.IsNullOrEmpty(currentLessonId))
            {
                sb.Append("No lesson data available yet.\n");
                return;
            }

            // Get current + prev + next lessons in order
            using (var cmd = new SqlCommand(@"
                SELECT l.lessonId, l.lessonTitleEN, l.lessonContentEN, l.orderNo,
                       st.subtopicTitleEN, u.unitNameEN
                FROM dbo.Lesson l
                INNER JOIN dbo.Subtopic st ON l.subtopicId = st.subtopicId
                INNER JOIN dbo.Unit u ON st.unitId = u.unitId
                INNER JOIN dbo.Student s ON s.currentLevelId = u.levelId
                WHERE s.studentId = @sid
                ORDER BY u.orderNo, st.orderNo, l.orderNo", conn))
            {
                cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                using (var r = cmd.ExecuteReader())
                {
                    string prevTitle = "", prevContent = "";
                    string currTitle = "", currContent = "", currUnit = "", currSubtopic = "";
                    string nextTitle = "", nextContent = "";
                    bool foundCurrent = false;
                    bool gotNext = false;

                    while (r.Read())
                    {
                        string thisId = r["lessonId"].ToString();
                        string title = r["lessonTitleEN"] != DBNull.Value ? r["lessonTitleEN"].ToString() : "";
                        string content = r["lessonContentEN"] != DBNull.Value ? r["lessonContentEN"].ToString() : "";
                        string unit = r["unitNameEN"] != DBNull.Value ? r["unitNameEN"].ToString() : "";
                        string subtopic = r["subtopicTitleEN"] != DBNull.Value ? r["subtopicTitleEN"].ToString() : "";

                        content = StripHtmlTags(content);
                        if (content.Length > 600) content = content.Substring(0, 600) + "...";

                        if (thisId == currentLessonId)
                        {
                            foundCurrent = true;
                            currTitle = title;
                            currContent = content;
                            currUnit = unit;
                            currSubtopic = subtopic;
                        }
                        else if (!foundCurrent)
                        {
                            prevTitle = title;
                            prevContent = content;
                        }
                        else if (foundCurrent && !gotNext)
                        {
                            nextTitle = title;
                            nextContent = content;
                            gotNext = true;
                        }
                    }

                    sb.AppendFormat("Current Unit: {0}\n", currUnit);
                    sb.AppendFormat("Current Subtopic: {0}\n", currSubtopic);
                    sb.AppendFormat("\n[CURRENT LESSON] {0}\n{1}\n", currTitle, currContent);

                    if (!string.IsNullOrEmpty(prevTitle))
                        sb.AppendFormat("\n[PREVIOUS LESSON] {0}\n{1}\n", prevTitle, prevContent);

                    if (!string.IsNullOrEmpty(nextTitle))
                        sb.AppendFormat("\n[NEXT LESSON] {0}\n{1}\n", nextTitle, nextContent);
                }
            }

            AppendQuizContext(conn, sb, currentSubtopicId);
            AppendMaterialContext(conn, sb, currentSubtopicId);
        }

        private void AppendQuizContext(SqlConnection conn, StringBuilder sb, string subtopicId)
        {
            if (string.IsNullOrEmpty(subtopicId)) return;

            using (var cmd = new SqlCommand(@"
                SELECT TOP 3 questionTextEN, correctAnswer, correctExplanationEN
                FROM dbo.Question
                WHERE subtopicId = @stid AND status = 'Approved'
                ORDER BY difficulty", conn))
            {
                cmd.Parameters.AddWithValue("@stid", subtopicId);
                using (var r = cmd.ExecuteReader())
                {
                    bool hasQuiz = false;
                    while (r.Read())
                    {
                        if (!hasQuiz)
                        {
                            sb.Append("\n[QUIZ QUESTIONS for this topic]\n");
                            hasQuiz = true;
                        }
                        string question = r["questionTextEN"] != DBNull.Value ? r["questionTextEN"].ToString() : "";
                        string answer = r["correctAnswer"] != DBNull.Value ? r["correctAnswer"].ToString() : "";
                        string explanation = r["correctExplanationEN"] != DBNull.Value ? r["correctExplanationEN"].ToString() : "";
                        sb.AppendFormat("Q: {0}\nA: {1}\nExplanation: {2}\n\n", question, answer, explanation);
                    }
                }
            }
        }

        private void AppendMaterialContext(SqlConnection conn, StringBuilder sb, string subtopicId)
        {
            if (string.IsNullOrEmpty(subtopicId)) return;

            using (var cmd = new SqlCommand(@"
                SELECT TOP 1 materialTitle, materialContent
                FROM dbo.Material
                WHERE subtopicId = @stid AND status = 'Approved' AND materialContent IS NOT NULL
                ORDER BY createdDate DESC", conn))
            {
                cmd.Parameters.AddWithValue("@stid", subtopicId);
                using (var r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        string title = r["materialTitle"] != DBNull.Value ? r["materialTitle"].ToString() : "";
                        string content = r["materialContent"] != DBNull.Value ? r["materialContent"].ToString() : "";
                        if (!string.IsNullOrEmpty(content))
                        {
                            if (content.Length > 400) content = content.Substring(0, 400) + "...";
                            sb.AppendFormat("\n[TEACHER MATERIAL] {0}\n{1}\n", title, content);
                        }
                    }
                }
            }
        }

        private string StripHtmlTags(string html)
        {
            if (string.IsNullOrEmpty(html)) return "";
            string result = System.Text.RegularExpressions.Regex.Replace(html, "<[^>]+>", " ");
            result = System.Text.RegularExpressions.Regex.Replace(result, @"\s+", " ");
            return result.Trim();
        }

        // --- Shared Helpers ---

        private void LoadLang()
        {
            string lang = Session["preferredLanguage"] as string;
            if (!string.IsNullOrEmpty(lang)) { CurrentLanguage = lang; return; }
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(
                    "SELECT preferredLanguage FROM dbo.[User] WHERE userId=@uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", Session["userId"].ToString());
                    conn.Open();
                    object r = cmd.ExecuteScalar();
                    if (r != null && r != DBNull.Value)
                    {
                        CurrentLanguage = r.ToString();
                        Session["preferredLanguage"] = CurrentLanguage;
                    }
                }
            }
            catch { }
        }

        private void LoadParentId()
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(
                    "SELECT parentId FROM dbo.[Parent] WHERE userId=@uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", _userId);
                    conn.Open();
                    object r = cmd.ExecuteScalar();
                    if (r != null && r != DBNull.Value)
                        _parentId = r.ToString();
                }
            }
            catch { }
        }

        private void LoadChildren()
        {
            ddlSidebarChild.Items.Clear();
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(
                    @"SELECT s.studentId, ISNULL(s.nickname,s.name) AS displayName
                      FROM dbo.StudentParent sp INNER JOIN dbo.Student s ON sp.studentId=s.studentId
                      WHERE sp.parentId=@pid ORDER BY s.name", conn))
                {
                    cmd.Parameters.AddWithValue("@pid", _parentId);
                    conn.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            ddlSidebarChild.Items.Add(new ListItem(
                                r["displayName"].ToString(), r["studentId"].ToString()));
                        }
                    }
                }
            }
            catch { }
        }

        private void LoadUnreadBadge()
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(
                    "SELECT COUNT(*) FROM dbo.Notification WHERE toUserId=@uid AND isRead=0", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", Session["userId"].ToString());
                    conn.Open();
                    int count = (int)cmd.ExecuteScalar();
                    litUnreadBadge.Text = count > 0
                        ? "<span class='pt-sidebar-badge'>" + count + "</span>" : "";
                }
            }
            catch { }
        }
    }
}
