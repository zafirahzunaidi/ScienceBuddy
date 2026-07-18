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
    public partial class Chat : Page
    {
        // â”€â”€ Connection string â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        private string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString; }
        }

        // â”€â”€ Language helper â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        public string CurrentLanguage = "EN";

        public string T(string en, string bm)
        {
            if (CurrentLanguage == "BM")
            {
                return bm;
            }
            return en;
        }

        // â”€â”€ State â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        private string ChatId
        {
            get { return ViewState["ChatId"] as string; }
            set { ViewState["ChatId"] = value; }
        }

        // â”€â”€ Page Load â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

        // â”€â”€ Initialize chat from URL params â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        private void InitializeChat()
        {
            string uid = Session["userId"].ToString();
            string chatIdParam = Request.QueryString["chatId"];
            string teacherUserIdParam = Request.QueryString["teacherUserId"];

            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();

                if (!Tbl(connection, "userChat") || !Tbl(connection, "privateMessage"))
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

                    using (SqlCommand command = new SqlCommand(verifySql, connection))
                    {
                        command.Parameters.AddWithValue("@chatId", chatIdParam);
                        command.Parameters.AddWithValue("@uid", uid);
                        object result = command.ExecuteScalar();
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
                    using (SqlCommand command = new SqlCommand(findSql, connection))
                    {
                        command.Parameters.AddWithValue("@uid", uid);
                        command.Parameters.AddWithValue("@teacherUid", teacherUserIdParam);
                        object result = command.ExecuteScalar();
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
                            command.Parameters.AddWithValue("@teacherUid", teacherUserIdParam);
                            command.Parameters.AddWithValue("@createdAt", DateTime.Now);
                            command.ExecuteNonQuery();
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
                MarkAsRead(connection, uid);

                // Load chat header and messages
                LoadChatHeader(connection, uid);
                LoadMessages(connection, uid);
            }
        }

        // â”€â”€ Mark teacher messages as read â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        private void MarkAsRead(SqlConnection connection, string uid)
        {
            const string sql = @"
                UPDATE privateMessage
                SET    isRead = 1, readAt = @now
                WHERE  chatId = @chatId
                AND    senderUserId != @uid
                AND    isRead = 0";

            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@chatId", ChatId);
                command.Parameters.AddWithValue("@uid", uid);
                command.Parameters.AddWithValue("@now", DateTime.Now);
                command.ExecuteNonQuery();
            }
        }

        // â”€â”€ Load chat header (teacher info) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        private void LoadChatHeader(SqlConnection connection, string uid)
        {
            // Get the other user's ID from the chat
            const string chatSql = @"
                SELECT CASE WHEN userId = @uid THEN user2Id ELSE userId END AS otherUserId
                FROM   userChat
                WHERE  chatId = @chatId";

            string otherUserId = null;
            using (SqlCommand command = new SqlCommand(chatSql, connection))
            {
                command.Parameters.AddWithValue("@chatId", ChatId);
                command.Parameters.AddWithValue("@uid", uid);
                object result = command.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                {
                    otherUserId = result.ToString();
                }
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

            if (Tbl(connection, "Teacher"))
            {
                const string teacherSql = @"
                    SELECT t.name, t.academicQualification, t.status
                    FROM   Teacher t
                    WHERE  t.userId = @otherUserId";

                using (SqlCommand command = new SqlCommand(teacherSql, connection))
                {
                    command.Parameters.AddWithValue("@otherUserId", otherUserId);
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            if (reader["name"] != DBNull.Value)
                            {
                                teacherName = reader["name"].ToString();
                            }
                            else
                            {
                                teacherName = "";
                            }

                            if (reader["academicQualification"] != DBNull.Value)
                            {
                                qualification = reader["academicQualification"].ToString();
                            }
                            else
                            {
                                qualification = "";
                            }

                            if (reader["status"] != DBNull.Value)
                            {
                                status = reader["status"].ToString();
                            }
                            else
                            {
                                status = "";
                            }
                        }
                    }
                }
            }

            // Fallback to User table if teacher info not found
            if (string.IsNullOrEmpty(teacherName))
            {
                const string userSql = "SELECT username FROM [User] WHERE userId = @uid2";
                using (SqlCommand command = new SqlCommand(userSql, connection))
                {
                    command.Parameters.AddWithValue("@uid2", otherUserId);
                    object result = command.ExecuteScalar();
                    if (result != null)
                    {
                        teacherName = result.ToString();
                    }
                    else
                    {
                        teacherName = "User";
                    }
                }
            }

            litHeaderName.Text = HttpUtility.HtmlEncode(teacherName);
            litHeaderQual.Text = HttpUtility.HtmlEncode(qualification);
            litHeaderInitials.Text = GetInitials(teacherName);

            if (string.IsNullOrEmpty(status))
            {
                litHeaderStatus.Text = "";
            }
            else if (status == "Certified")
            {
                litHeaderStatus.Text = T("Certified", "Bertauliah");
            }
            else
            {
                litHeaderStatus.Text = HttpUtility.HtmlEncode(status);
            }
        }

        // â”€â”€ Load messages â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        private void LoadMessages(SqlConnection connection, string uid)
        {
            const string sql = @"
                SELECT pm.privateMsgId, pm.senderUserId, pm.msgText, pm.sentAt
                FROM   privateMessage pm
                WHERE  pm.chatId = @chatId
                ORDER BY pm.sentAt ASC";

            List<object> messages = new List<object>();

            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@chatId", ChatId);
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string senderUserId = reader["senderUserId"].ToString();
                        bool isMine = senderUserId == uid;

                        string msgText = "";
                        if (reader["msgText"] != DBNull.Value)
                        {
                            msgText = reader["msgText"].ToString();
                        }

                        DateTime sentAt;
                        if (reader["sentAt"] != DBNull.Value)
                        {
                            sentAt = Convert.ToDateTime(reader["sentAt"]);
                        }
                        else
                        {
                            sentAt = DateTime.Now;
                        }

                        string senderName;
                        if (isMine)
                        {
                            senderName = T("You", "Anda");
                        }
                        else
                        {
                            senderName = litHeaderName.Text;
                        }

                        string senderInitial;
                        if (isMine)
                        {
                            senderInitial = "Y";
                        }
                        else
                        {
                            senderInitial = (litHeaderInitials.Text.Length > 0) ? litHeaderInitials.Text : "T";
                        }

                        messages.Add(new
                        {
                            MsgText = HttpUtility.HtmlEncode(msgText),
                            SentAt = sentAt.ToString("dd MMM yyyy, h:mm tt"),
                            IsMine = isMine,
                            SenderName = senderName,
                            SenderInitial = senderInitial
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

        // â”€â”€ Send message â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        protected void btnSend_Click(object sender, EventArgs e)
        {
            string msgText = txtMessage.Text.Trim();
            if (string.IsNullOrEmpty(msgText))
            {
                return;
            }
            if (string.IsNullOrEmpty(ChatId))
            {
                return;
            }

            string uid = Session["userId"].ToString();

            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();

                // Generate unique privateMsgId: "PM" + next sequential 3-digit number (PM001 to PM999)
                string msgId = "PM001";
                const string seqSql = @"
                    SELECT ISNULL(MAX(CAST(SUBSTRING(privateMsgId, 3, LEN(privateMsgId) - 2) AS INT)), 0)
                    FROM privateMessage
                    WHERE privateMsgId LIKE 'PM[0-9]%'";
                using (SqlCommand seqCmd = new SqlCommand(seqSql, connection))
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

                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    command.Parameters.AddWithValue("@msgId", msgId);
                    command.Parameters.AddWithValue("@chatId", ChatId);
                    command.Parameters.AddWithValue("@uid", uid);
                    command.Parameters.AddWithValue("@msgText", msgText);
                    command.Parameters.AddWithValue("@sentAt", DateTime.Now);
                    command.ExecuteNonQuery();
                }

                // Notify recipient of new message
                try
                {
                    string recipientUserId = "";
                    using (SqlCommand recipCmd = new SqlCommand("SELECT CASE WHEN userId=@uid THEN user2Id ELSE userId END FROM userChat WHERE chatId=@chatId", connection))
                    {
                        recipCmd.Parameters.AddWithValue("@uid", uid);
                        recipCmd.Parameters.AddWithValue("@chatId", ChatId);
                        var r = recipCmd.ExecuteScalar();
                        if (r != null && r != DBNull.Value) recipientUserId = r.ToString();
                    }
                    if (!string.IsNullOrEmpty(recipientUserId))
                    {
                        SendNotification(connection, recipientUserId, "New Message", "Mesej Baru", "You received a new message.", "Anda menerima mesej baru.");
                    }
                }
                catch (Exception notifEx)
                {
                    System.Diagnostics.Debug.WriteLine("Chat notification error: " + notifEx.Message);
                }

                // Clear textbox and reload messages
                txtMessage.Text = "";
                LoadChatHeader(connection, uid);
                LoadMessages(connection, uid);
            }
        }

        // â”€â”€ Show error â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        private void ShowError()
        {
            pnlError.Visible = true;
            pnlChat.Visible = false;
        }

        // â”€â”€ Language initialisation â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

        // â”€â”€ Bilingual labels â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        private void SetLabels()
        {
            litBack.Text = T("Back to Messages", "Kembali ke Mesej");
            litError.Text = T("Chat not found or access denied.", "Chat tidak ditemui atau akses ditolak.");
            litEmptyTitle.Text = T("No messages yet", "Tiada mesej lagi");
            litEmptyMsg.Text = T("Start the conversation!", "Mulakan perbualan!");
            litHeaderStatus.Text = T("Certified", "Bertauliah");
            txtMessage.Attributes["placeholder"] = T("Type your message...", "Taip mesej anda...");
        }

        // â”€â”€ Utility helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
            else
            {
                return name[0].ToString().ToUpper();
            }
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

        private void SendNotification(SqlConnection conn, string toUserId, string titleEN, string titleBM, string msgEN, string msgBM)
        {
            try
            {
                string nId = "N001";
                using (SqlCommand cmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING(notificationId,2,LEN(notificationId)-1) AS INT)),0) FROM Notification WHERE notificationId LIKE 'N[0-9]%'", conn))
                {
                    nId = "N" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3");
                }
                using (SqlCommand cmd = new SqlCommand("INSERT INTO Notification(notificationId,toUserId,titleEN,titleBM,messageEN,messageBM,isRead,createdAt) VALUES(@id,@to,@tEN,@tBM,@mEN,@mBM,0,@dt)", conn))
                {
                    cmd.Parameters.AddWithValue("@id", nId);
                    cmd.Parameters.AddWithValue("@to", toUserId);
                    cmd.Parameters.AddWithValue("@tEN", titleEN);
                    cmd.Parameters.AddWithValue("@tBM", titleBM);
                    cmd.Parameters.AddWithValue("@mEN", msgEN);
                    cmd.Parameters.AddWithValue("@mBM", msgBM);
                    cmd.Parameters.AddWithValue("@dt", DateTime.Now);
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Notification error: " + ex.Message);
            }
        }
    }
}

