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
    public partial class ChatPage : Page
    {
        // ── Connection string ─────────────────────────────────────────
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        // ── Language helper ────────────────────────────────────────────
        public string CurrentLanguage = "EN";

        public string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        // ── State ─────────────────────────────────────────────────────
        private string ChatId
        {
            get { return ViewState["ChatId"] as string; }
            set { ViewState["ChatId"] = value; }
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
                InitializeChat();
            }
        }

        // ── Initialize chat from URL params ───────────────────────────
        private void InitializeChat()
        {
            string uid = Session["userId"].ToString();
            string chatIdParam = Request.QueryString["chatId"];
            string teacherUserIdParam = Request.QueryString["teacherUserId"];

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                if (!Tbl(conn, "userChat") || !Tbl(conn, "privateMessage"))
                {
                    ShowError();
                    return;
                }

                if (!string.IsNullOrEmpty(chatIdParam))
                {
                    // Verify access: user must be userId or user2Id
                    const string verifySql = @"
                        SELECT chatId FROM userChat
                        WHERE  chatId = @chatId
                        AND    (userId = @uid OR user2Id = @uid)";

                    using (var cmd = new SqlCommand(verifySql, conn))
                    {
                        cmd.Parameters.AddWithValue("@chatId", chatIdParam);
                        cmd.Parameters.AddWithValue("@uid", uid);
                        object result = cmd.ExecuteScalar();
                        if (result == null || result == DBNull.Value)
                        {
                            ShowError();
                            return;
                        }
                    }

                    ChatId = chatIdParam;
                }
                else if (!string.IsNullOrEmpty(teacherUserIdParam))
                {
                    // Find or create chat
                    const string findSql = @"
                        SELECT chatId FROM userChat
                        WHERE  (userId = @uid AND user2Id = @teacherUid)
                        OR     (userId = @teacherUid AND user2Id = @uid)";

                    string existingChatId = null;
                    using (var cmd = new SqlCommand(findSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@uid", uid);
                        cmd.Parameters.AddWithValue("@teacherUid", teacherUserIdParam);
                        object result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            existingChatId = result.ToString();
                        }
                    }

                    if (!string.IsNullOrEmpty(existingChatId))
                    {
                        ChatId = existingChatId;
                    }
                    else
                    {
                        // Create new chat
                        string newChatId = "C" + DateTime.Now.ToString("yyMMddHHmm").Substring(0, 9);
                        if (newChatId.Length > 10) newChatId = newChatId.Substring(0, 10);

                        const string insertSql = @"
                            INSERT INTO userChat (chatId, userId, user2Id, createdAt)
                            VALUES (@chatId, @uid, @teacherUid, @createdAt)";

                        using (var cmd = new SqlCommand(insertSql, conn))
                        {
                            cmd.Parameters.AddWithValue("@chatId", newChatId);
                            cmd.Parameters.AddWithValue("@uid", uid);
                            cmd.Parameters.AddWithValue("@teacherUid", teacherUserIdParam);
                            cmd.Parameters.AddWithValue("@createdAt", DateTime.Now);
                            cmd.ExecuteNonQuery();
                        }

                        ChatId = newChatId;
                    }
                }
                else
                {
                    ShowError();
                    return;
                }

                // Mark unread messages from teacher as read
                MarkAsRead(conn, uid);

                // Load chat header and messages
                LoadChatHeader(conn, uid);
                LoadMessages(conn, uid);
            }
        }

        // ── Mark teacher messages as read ─────────────────────────────
        private void MarkAsRead(SqlConnection conn, string uid)
        {
            const string sql = @"
                UPDATE privateMessage
                SET    isRead = 1, readAt = @now
                WHERE  chatId = @chatId
                AND    senderUserId != @uid
                AND    isRead = 0";

            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@chatId", ChatId);
                cmd.Parameters.AddWithValue("@uid", uid);
                cmd.Parameters.AddWithValue("@now", DateTime.Now);
                cmd.ExecuteNonQuery();
            }
        }

        // ── Load chat header (teacher info) ───────────────────────────
        private void LoadChatHeader(SqlConnection conn, string uid)
        {
            // Get the other user's ID from the chat
            const string chatSql = @"
                SELECT CASE WHEN userId = @uid THEN user2Id ELSE userId END AS otherUserId
                FROM   userChat
                WHERE  chatId = @chatId";

            string otherUserId = null;
            using (var cmd = new SqlCommand(chatSql, conn))
            {
                cmd.Parameters.AddWithValue("@chatId", ChatId);
                cmd.Parameters.AddWithValue("@uid", uid);
                object result = cmd.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                    otherUserId = result.ToString();
            }

            if (string.IsNullOrEmpty(otherUserId))
            {
                ShowError();
                return;
            }

            // Get teacher info
            string teacherName = "";
            string qualification = "";
            string status = "";

            if (Tbl(conn, "Teacher"))
            {
                const string teacherSql = @"
                    SELECT t.name, t.academicQualification, t.status
                    FROM   Teacher t
                    WHERE  t.userId = @otherUserId";

                using (var cmd = new SqlCommand(teacherSql, conn))
                {
                    cmd.Parameters.AddWithValue("@otherUserId", otherUserId);
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            teacherName = reader["name"] != DBNull.Value ? reader["name"].ToString() : "";
                            qualification = reader["academicQualification"] != DBNull.Value ? reader["academicQualification"].ToString() : "";
                            status = reader["status"] != DBNull.Value ? reader["status"].ToString() : "";
                        }
                    }
                }
            }

            // Fallback to User table if teacher info not found
            if (string.IsNullOrEmpty(teacherName))
            {
                const string userSql = "SELECT username FROM [User] WHERE userId = @uid2";
                using (var cmd = new SqlCommand(userSql, conn))
                {
                    cmd.Parameters.AddWithValue("@uid2", otherUserId);
                    object result = cmd.ExecuteScalar();
                    teacherName = result != null ? result.ToString() : "User";
                }
            }

            litHeaderName.Text = HttpUtility.HtmlEncode(teacherName);
            litHeaderQual.Text = HttpUtility.HtmlEncode(qualification);
            litHeaderInitials.Text = GetInitials(teacherName);
            litHeaderStatus.Text = string.IsNullOrEmpty(status) ? "" :
                (status == "Certified" ? T("Certified", "Bertauliah") : HttpUtility.HtmlEncode(status));
        }

        // ── Load messages ─────────────────────────────────────────────
        private void LoadMessages(SqlConnection conn, string uid)
        {
            const string sql = @"
                SELECT pm.privateMsgId, pm.senderUserId, pm.msgText, pm.sentAt
                FROM   privateMessage pm
                WHERE  pm.chatId = @chatId
                ORDER BY pm.sentAt ASC";

            var messages = new List<object>();

            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@chatId", ChatId);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string senderUserId = reader["senderUserId"].ToString();
                        bool isMine = senderUserId == uid;
                        string msgText = reader["msgText"] != DBNull.Value ? reader["msgText"].ToString() : "";
                        DateTime sentAt = reader["sentAt"] != DBNull.Value ? Convert.ToDateTime(reader["sentAt"]) : DateTime.Now;

                        messages.Add(new
                        {
                            MsgText = HttpUtility.HtmlEncode(msgText),
                            SentAt = sentAt.ToString("dd MMM yyyy, h:mm tt"),
                            IsMine = isMine,
                            SenderName = isMine ? T("You", "Anda") : litHeaderName.Text
                        });
                    }
                }
            }

            if (messages.Count == 0)
            {
                pnlMessages.Visible = false;
                pnlMessagesEmpty.Visible = true;
            }
            else
            {
                pnlMessages.Visible = true;
                pnlMessagesEmpty.Visible = false;
                rptMessages.DataSource = messages;
                rptMessages.DataBind();
            }
        }

        // ── Send message ──────────────────────────────────────────────
        protected void btnSend_Click(object sender, EventArgs e)
        {
            string msgText = txtMessage.Text.Trim();
            if (string.IsNullOrEmpty(msgText)) return;
            if (string.IsNullOrEmpty(ChatId)) return;

            string uid = Session["userId"].ToString();

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Generate unique privateMsgId: "PM" + next sequential 3-digit number (PM001 to PM999)
                string msgId = "PM001";
                const string seqSql = @"
                    SELECT ISNULL(MAX(CAST(SUBSTRING(privateMsgId, 3, LEN(privateMsgId) - 2) AS INT)), 0)
                    FROM privateMessage
                    WHERE privateMsgId LIKE 'PM[0-9]%'";
                using (var seqCmd = new SqlCommand(seqSql, conn))
                {
                    object lastVal = seqCmd.ExecuteScalar();
                    if (lastVal != null && lastVal != DBNull.Value)
                    {
                        int lastNum = Convert.ToInt32(lastVal);
                        msgId = "PM" + (lastNum + 1).ToString("D3");
                    }
                }

                const string sql = @"
                    INSERT INTO privateMessage (privateMsgId, chatId, senderUserId, msgText, attachmentFile, sentAt, isRead, readAt)
                    VALUES (@msgId, @chatId, @uid, @msgText, NULL, @sentAt, 0, NULL)";

                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@msgId", msgId);
                    cmd.Parameters.AddWithValue("@chatId", ChatId);
                    cmd.Parameters.AddWithValue("@uid", uid);
                    cmd.Parameters.AddWithValue("@msgText", msgText);
                    cmd.Parameters.AddWithValue("@sentAt", DateTime.Now);
                    cmd.ExecuteNonQuery();
                }

                // Clear textbox and reload messages
                txtMessage.Text = "";
                LoadChatHeader(conn, uid);
                LoadMessages(conn, uid);
            }
        }

        // ── Show error ────────────────────────────────────────────────
        private void ShowError()
        {
            pnlError.Visible = true;
            pnlChat.Visible = false;
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
                    using (var conn = new SqlConnection(ConnStr))
                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@userId", userId);
                        conn.Open();
                        object result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            lang = result.ToString();
                            Session["preferredLanguage"] = lang;
                            CurrentLanguage = lang;
                            return;
                        }
                    }
                }
                catch (SqlException) { }
            }

            CurrentLanguage = "EN";
            Session["preferredLanguage"] = "EN";
        }

        // ── Bilingual labels ──────────────────────────────────────────
        private void SetLabels()
        {
            litBack.Text = T("Back to Messages", "Kembali ke Mesej");
            litError.Text = T("Chat not found or access denied.", "Chat tidak ditemui atau akses ditolak.");
            litEmptyMsg.Text = T("No messages yet. Start the conversation!", "Tiada mesej lagi. Mulakan perbualan!");
            litHeaderStatus.Text = T("Certified", "Bertauliah");
            btnSend.Text = T("Send", "Hantar");
            txtMessage.Attributes["placeholder"] = T("Type your message...", "Taip mesej anda...");
        }

        // ── Utility helpers ───────────────────────────────────────────
        private static string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "T";
            var parts = name.Trim().Split(' ');
            return parts.Length >= 2
                ? (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper()
                : name[0].ToString().ToUpper();
        }

        /// <summary>
        /// Returns true if the given table exists in the current database.
        /// Uses INFORMATION_SCHEMA so it never throws on a missing table.
        /// </summary>
        private static bool Tbl(SqlConnection conn, string tableName)
        {
            const string sql = @"
                SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
                WHERE  TABLE_NAME = @tableName
                AND    TABLE_TYPE = 'BASE TABLE'";
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@tableName", tableName);
                return (int)cmd.ExecuteScalar() > 0;
            }
        }
    }
}
