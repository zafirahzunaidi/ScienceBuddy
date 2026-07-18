using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Student
{
    public partial class Messages1 : Page
    {
        // ── Connection string ─────────────────────────────────────────
        private string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString; }
        }

        // ── Language helper ────────────────────────────────────────────
        public string CurrentLanguage = "EN";

        public string T(string en, string bm)
        {
            if (CurrentLanguage == "BM")
            {
                return bm;
            }
            return en;
        }

        // ── Page Load ─────────────────────────────────────────────────
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null ||
                Session["role"].ToString() != "Student")
            {
                Response.Redirect("~/Login.aspx", false);
                return;
            }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";

            InitLang();
            SetLabels();

            if (!IsPostBack)
            {
                LoadChats();
            }
        }

        // ── Language initialisation ───────────────────────────────────
        private void InitLang()
        {
            string lang = Session["preferredLanguage"] as string;
            if (!string.IsNullOrEmpty(lang))
            {
                CurrentLanguage = lang;
                return;
            }

            string userId = Session["userId"] as string;
            if (!string.IsNullOrEmpty(userId))
            {
                try
                {
                    const string sql = "SELECT preferredLanguage FROM [User] WHERE userId = @userId";
                    using (SqlConnection connection = new SqlConnection(ConnStr))
                    using (SqlCommand command = new SqlCommand(sql, connection))
                    {
                        command.Parameters.AddWithValue("@userId", userId);
                        connection.Open();
                        object result = command.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            lang = result.ToString();
                            Session["preferredLanguage"] = lang;
                            CurrentLanguage = lang;
                            return;
                        }
                    }
                }
                catch (SqlException ex)
                {
                    System.Diagnostics.Debug.WriteLine("Database error: " + ex.Message);
                }
            }

            CurrentLanguage = "EN";
            Session["preferredLanguage"] = "EN";
        }

        // ── Bilingual labels ──────────────────────────────────────────
        private void SetLabels()
        {
            litPageTitle.Text = T("Messages", "Mesej");
            litPageSub.Text = T("Chat privately with teachers for learning support.", "Berbual secara peribadi dengan guru untuk sokongan pembelajaran.");
            btnTabChats.Text = "<i class=\"bi bi-chat-left-text\"></i> " + T("My Chats", "Chat Saya");
            btnTabTeachers.Text = "<i class=\"bi bi-people\"></i> " + T("Teachers", "Guru");
            litChatsEmptyTitle.Text = T("You have not started any teacher chats yet.", "Anda belum memulakan sebarang chat dengan guru.");
            litChatsEmptyDesc.Text = T("Chat privately with teachers for learning support.", "Berbual secara peribadi dengan guru untuk sokongan pembelajaran.");
            litTeachersEmptyTitle.Text = T("No teachers available.", "Tiada guru tersedia.");
            litTeachersEmptyDesc.Text = T("Teachers will appear here once they are certified.", "Guru akan muncul di sini setelah mereka bertauliah.");
        }

        // ── Load chats ────────────────────────────────────────────────
        private void LoadChats()
        {
            string uid = Session["userId"].ToString();

            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();

                if (!Tbl(connection, "userChat") || !Tbl(connection, "privateMessage"))
                {
                    pnlChatsContent.Visible = false;
                    pnlChatsEmpty.Visible = true;
                    return;
                }

                // Get all chats for this user
                const string sql = @"
                    SELECT c.chatId,
                           CASE WHEN c.userId = @uid THEN c.user2Id ELSE c.userId END AS otherUserId,
                           c.createdAt
                    FROM   userChat c
                    WHERE  c.userId = @uid OR c.user2Id = @uid
                    ORDER BY c.createdAt DESC";

                List<object> chats = new List<object>();

                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    command.Parameters.AddWithValue("@uid", uid);
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        List<Tuple<string, string>> chatRows = new List<Tuple<string, string>>();
                        while (reader.Read())
                        {
                            chatRows.Add(Tuple.Create(
                                reader["chatId"].ToString(),
                                reader["otherUserId"].ToString()));
                        }
                        reader.Close();

                        foreach (Tuple<string, string> chat in chatRows)
                        {
                            string chatId = chat.Item1;
                            string otherUserId = chat.Item2;

                            // Get teacher info
                            string teacherName = "";
                            string qualification = "";
                            using (SqlCommand cmd2 = new SqlCommand(@"
                                SELECT t.name, t.academicQualification
                                FROM   Teacher t
                                WHERE  t.userId = @otherUserId", connection))
                            {
                                cmd2.Parameters.AddWithValue("@otherUserId", otherUserId);
                                using (SqlDataReader r2 = cmd2.ExecuteReader())
                                {
                                    if (r2.Read())
                                    {
                                        if (r2["name"] != DBNull.Value)
                                        {
                                            teacherName = r2["name"].ToString();
                                        }
                                        else
                                        {
                                            teacherName = "";
                                        }

                                        if (r2["academicQualification"] != DBNull.Value)
                                        {
                                            qualification = r2["academicQualification"].ToString();
                                        }
                                        else
                                        {
                                            qualification = "";
                                        }
                                    }
                                    else
                                    {
                                        // Other user might not be a teacher - use User table
                                        r2.Close();
                                        using (SqlCommand cmd3 = new SqlCommand("SELECT username FROM [User] WHERE userId = @uid2", connection))
                                        {
                                            cmd3.Parameters.AddWithValue("@uid2", otherUserId);
                                            object res = cmd3.ExecuteScalar();
                                            if (res != null)
                                            {
                                                teacherName = res.ToString();
                                            }
                                            else
                                            {
                                                teacherName = "User";
                                            }
                                        }
                                        qualification = "";
                                        goto afterTeacherRead;
                                    }
                                }
                            }
                            afterTeacherRead:

                            // Get last message
                            string lastMsg = "";
                            string lastDate = "";
                            using (SqlCommand cmd4 = new SqlCommand(@"
                                SELECT TOP 1 msgText, sentAt
                                FROM   privateMessage
                                WHERE  chatId = @cid
                                ORDER BY sentAt DESC", connection))
                            {
                                cmd4.Parameters.AddWithValue("@cid", chatId);
                                using (SqlDataReader r4 = cmd4.ExecuteReader())
                                {
                                    if (r4.Read())
                                    {
                                        if (r4["msgText"] != DBNull.Value)
                                        {
                                            lastMsg = r4["msgText"].ToString();
                                        }
                                        else
                                        {
                                            lastMsg = "";
                                        }

                                        if (lastMsg.Length > 60)
                                        {
                                            lastMsg = lastMsg.Substring(0, 60) + "...";
                                        }

                                        DateTime sentAt;
                                        if (r4["sentAt"] != DBNull.Value)
                                        {
                                            sentAt = Convert.ToDateTime(r4["sentAt"]);
                                        }
                                        else
                                        {
                                            sentAt = DateTime.Now;
                                        }
                                        lastDate = FormatTimeAgo(sentAt);
                                    }
                                }
                            }

                            // Count unread
                            int unreadCount = 0;
                            using (SqlCommand cmd5 = new SqlCommand(@"
                                SELECT COUNT(*) FROM privateMessage
                                WHERE  chatId = @cid AND senderUserId != @uid AND isRead = 0", connection))
                            {
                                cmd5.Parameters.AddWithValue("@cid", chatId);
                                cmd5.Parameters.AddWithValue("@uid", uid);
                                unreadCount = (int)cmd5.ExecuteScalar();
                            }

                            chats.Add(new
                            {
                                ChatId = chatId,
                                TeacherName = HttpUtility.HtmlEncode(teacherName),
                                Qualification = HttpUtility.HtmlEncode(qualification),
                                Initials = GetInitials(teacherName),
                                LastMessage = HttpUtility.HtmlEncode(lastMsg),
                                LastDate = lastDate,
                                UnreadCount = unreadCount,
                                ChatUrl = ResolveUrl("~/Student/Chat.aspx?chatId=" + HttpUtility.UrlEncode(chatId))
                            });
                        }
                    }
                }

                if (chats.Count == 0)
                {
                    pnlChatsContent.Visible = false;
                    pnlChatsEmpty.Visible = true;
                }
                else
                {
                    pnlChatsContent.Visible = true;
                    pnlChatsEmpty.Visible = false;
                    rptChats.DataSource = chats;
                    rptChats.DataBind();
                }
            }
        }

        // ── Load teachers ─────────────────────────────────────────────
        private void LoadTeachers()
        {
            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();

                if (!Tbl(connection, "Teacher"))
                {
                    pnlTeachersContent.Visible = false;
                    pnlTeachersEmpty.Visible = true;
                    return;
                }

                const string sql = @"
                    SELECT t.teacherId, t.userId, t.name, t.academicQualification, t.bio, t.status
                    FROM   Teacher t
                    JOIN   [User] u ON u.userId = t.userId
                    WHERE  t.status = 'Certified'
                    AND    u.status = 'Active'
                    ORDER BY t.name";

                List<object> teachers = new List<object>();

                using (SqlCommand command = new SqlCommand(sql, connection))
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string name;
                        if (reader["name"] != DBNull.Value)
                        {
                            name = reader["name"].ToString();
                        }
                        else
                        {
                            name = "";
                        }

                        string qual;
                        if (reader["academicQualification"] != DBNull.Value)
                        {
                            qual = reader["academicQualification"].ToString();
                        }
                        else
                        {
                            qual = "";
                        }

                        string bio;
                        if (reader["bio"] != DBNull.Value)
                        {
                            bio = reader["bio"].ToString();
                        }
                        else
                        {
                            bio = "";
                        }

                        string teacherUserId = reader["userId"].ToString();

                        if (bio.Length > 100)
                        {
                            bio = bio.Substring(0, 100) + "...";
                        }

                        teachers.Add(new
                        {
                            TeacherUserId = teacherUserId,
                            TeacherName = HttpUtility.HtmlEncode(name),
                            Qualification = HttpUtility.HtmlEncode(qual),
                            Bio = HttpUtility.HtmlEncode(bio),
                            Initials = GetInitials(name)
                        });
                    }
                }

                if (teachers.Count == 0)
                {
                    pnlTeachersContent.Visible = false;
                    pnlTeachersEmpty.Visible = true;
                }
                else
                {
                    pnlTeachersContent.Visible = true;
                    pnlTeachersEmpty.Visible = false;
                    rptTeachers.DataSource = teachers;
                    rptTeachers.DataBind();
                }
            }
        }

        // ── Tab switching ─────────────────────────────────────────────
        protected void btnTabChats_Click(object sender, EventArgs e)
        {
            hfTab.Value = "chats";
            pnlChats.Visible = true;
            pnlTeachers.Visible = false;
            btnTabChats.CssClass = "st-messages-tab active";
            btnTabTeachers.CssClass = "st-messages-tab";
            try
            {
                LoadChats();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadChats error: " + ex.Message);
                pnlChatsContent.Visible = false;
                pnlChatsEmpty.Visible = true;
            }
        }

        protected void btnTabTeachers_Click(object sender, EventArgs e)
        {
            hfTab.Value = "teachers";
            pnlChats.Visible = false;
            pnlTeachers.Visible = true;
            btnTabChats.CssClass = "st-messages-tab";
            btnTabTeachers.CssClass = "st-messages-tab active";
            try
            {
                LoadTeachers();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadTeachers error: " + ex.Message);
                pnlTeachersContent.Visible = false;
                pnlTeachersEmpty.Visible = true;
            }
        }

        // ── Start Chat command ────────────────────────────────────────
        protected void rptTeachers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "StartChat")
            {
                return;
            }

            string teacherUserId = e.CommandArgument.ToString();
            string uid = Session["userId"].ToString();

            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();

                if (!Tbl(connection, "userChat"))
                {
                    // Table doesn't exist, can't proceed
                    return;
                }

                // Check if chat already exists (check both directions)
                const string checkSql = @"
                    SELECT chatId FROM userChat
                    WHERE  (userId = @uid AND user2Id = @teacherUid)
                    OR     (userId = @teacherUid AND user2Id = @uid)";

                string existingChatId = null;
                using (SqlCommand command = new SqlCommand(checkSql, connection))
                {
                    command.Parameters.AddWithValue("@uid", uid);
                    command.Parameters.AddWithValue("@teacherUid", teacherUserId);
                    object result = command.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        existingChatId = result.ToString();
                    }
                }

                if (!string.IsNullOrEmpty(existingChatId))
                {
                    Response.Redirect("~/Student/Chat.aspx?chatId=" + HttpUtility.UrlEncode(existingChatId), false);
                    return;
                }

                // Create new chat
                string newChatId = "C" + DateTime.Now.ToString("yyMMddHHmm").Substring(0, 9);
                // Ensure 10 chars max
                if (newChatId.Length > 10)
                {
                    newChatId = newChatId.Substring(0, 10);
                }

                const string insertSql = @"
                    INSERT INTO userChat (chatId, userId, user2Id, createdAt)
                    VALUES (@chatId, @uid, @teacherUid, @createdAt)";

                using (SqlCommand command = new SqlCommand(insertSql, connection))
                {
                    command.Parameters.AddWithValue("@chatId", newChatId);
                    command.Parameters.AddWithValue("@uid", uid);
                    command.Parameters.AddWithValue("@teacherUid", teacherUserId);
                    command.Parameters.AddWithValue("@createdAt", DateTime.Now);
                    command.ExecuteNonQuery();
                }

                Response.Redirect("~/Student/Chat.aspx?chatId=" + HttpUtility.UrlEncode(newChatId), false);
            }
        }

        // ── Repeater label helpers (called from ASPX) ─────────────────
        public string GetOpenChatLabel()
        {
            return T("Open Chat", "Buka Chat");
        }

        public string GetStartChatLabel()
        {
            return T("Start Chat", "Mula Chat");
        }

        public string GetUnreadLabel()
        {
            return T("unread", "belum dibaca");
        }

        public string GetCertifiedLabel()
        {
            return T("Certified", "Bertauliah");
        }

        // ── Utility helpers ───────────────────────────────────────────
        private static string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name))
            {
                return "T";
            }
            string[] parts = name.Trim().Split(' ');
            if (parts.Length >= 2)
            {
                return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
            }
            return name[0].ToString().ToUpper();
        }

        private static string FormatTimeAgo(DateTime dt)
        {
            TimeSpan span = DateTime.Now - dt;
            if (span.TotalMinutes < 1)
            {
                return "Just now";
            }
            if (span.TotalHours < 1)
            {
                return (int)span.TotalMinutes + " min ago";
            }
            if (span.TotalDays < 1)
            {
                return (int)span.TotalHours + " hr ago";
            }
            if (span.TotalDays < 7)
            {
                return (int)span.TotalDays + " day" + ((int)span.TotalDays == 1 ? "" : "s") + " ago";
            }
            return dt.ToString("d MMM yyyy");
        }

        /// <summary>
        /// Returns true if the given table exists in the current database.
        /// Uses INFORMATION_SCHEMA so it never throws on a missing table.
        /// </summary>
        private static bool Tbl(SqlConnection connection, string tableName)
        {
            const string sql = @"
                SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
                WHERE  TABLE_NAME = @tableName
                AND    TABLE_TYPE = 'BASE TABLE'";
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@tableName", tableName);
                return (int)command.ExecuteScalar() > 0;
            }
        }
    }
}
