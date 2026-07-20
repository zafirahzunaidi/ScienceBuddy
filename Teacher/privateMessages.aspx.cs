using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Teacher
{
    public partial class privateMessages : Page
    {
        #region Properties

        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected string CurrentLanguage
        {
            get
            {
                string lang = Session["preferredLanguage"] as string;
                return string.IsNullOrEmpty(lang) ? "EN" : lang;
            }
        }

        protected string SelectedChatId
        {
            get { return hidSelectedChat.Value ?? ""; }
            set { hidSelectedChat.Value = value; }
        }

        private string FilterRole
        {
            get { return ViewState["FR"] as string ?? "All"; }
            set { ViewState["FR"] = value; }
        }

        private static readonly HashSet<string> AllowedAttachExts = new HashSet<string>(
            StringComparer.OrdinalIgnoreCase)
        {
            ".pdf", ".doc", ".docx", ".ppt", ".pptx", ".jpg", ".jpeg", ".png"
        };

        private const int MaxAttachSize = 10 * 1024 * 1024;

        #endregion

        #region Helper Methods

        /// <summary>
        /// Returns the localised string based on the current language preference.
        /// </summary>
        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        /// <summary>
        /// Formats a DateTime into a human-friendly relative time string.
        /// </summary>
        private static string FormatTime(DateTime dateTime)
        {
            var elapsed = DateTime.Now - dateTime;

            if (elapsed.TotalMinutes < 1) return "Now";
            if (elapsed.TotalHours < 1) return (int)elapsed.TotalMinutes + "m";
            if (elapsed.TotalDays < 1) return (int)elapsed.TotalHours + "h";
            if (elapsed.TotalDays < 7) return (int)elapsed.TotalDays + "d";

            return dateTime.ToString("d MMM");
        }

        /// <summary>
        /// Builds the initials from a display name (first + last character).
        /// </summary>
        private static string GetInitials(string name)
        {
            var parts = name.Split(' ');
            return parts.Length >= 2
                ? (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper()
                : name[0].ToString().ToUpper();
        }

        /// <summary>
        /// Generates the next sequential ID by reading the current max from the given table/column.
        /// </summary>
        private string GenerateNextId(SqlConnection conn, string sql, string prefix, int padLength)
        {
            using (var cmd = new SqlCommand(sql, conn))
            {
                int currentMax = Convert.ToInt32(cmd.ExecuteScalar());
                return prefix + (currentMax + 1).ToString("D" + padLength);
            }
        }

        /// <summary>
        /// Renders an attachment as an HTML link or inline image preview.
        /// </summary>
        protected string RenderAttachment(string attachFile)
        {
            if (string.IsNullOrEmpty(attachFile)) return "";

            string filePath = attachFile.StartsWith("Images/", StringComparison.OrdinalIgnoreCase)
                ? attachFile
                : "Images/PrivateMessage/" + attachFile;

            string url = ResolveUrl("~/" + filePath);
            string ext = System.IO.Path.GetExtension(attachFile).ToLower();
            string fileName = System.IO.Path.GetFileName(attachFile);

            if (ext == ".jpg" || ext == ".jpeg" || ext == ".png")
            {
                return "<a href='" + HttpUtility.HtmlAttributeEncode(url) + "' target='_blank' style='display:block;margin-top:6px;'>"
                     + "<img src='" + HttpUtility.HtmlAttributeEncode(url) + "' style='max-width:200px;max-height:150px;border-radius:8px;border:1px solid #E5E7EB;' alt='attachment' /></a>";
            }

            return "<a href='" + HttpUtility.HtmlAttributeEncode(url) + "' target='_blank' class='tc-private-messages-msg-attach'>"
                 + "<i class='bi bi-file-earmark'></i> " + HttpUtility.HtmlEncode(fileName) + "</a>";
        }

        /// <summary>
        /// Saves an uploaded file to the PrivateMessage folder and returns the filename.
        /// Returns null if validation fails.
        /// </summary>
        private string SaveAttachment(FileUpload fileUpload, out string errorMessage)
        {
            errorMessage = null;

            if (!fileUpload.HasFile) return null;

            string ext = System.IO.Path.GetExtension(fileUpload.FileName).ToLower();

            if (!AllowedAttachExts.Contains(ext))
            {
                errorMessage = T("File type not allowed.", "Jenis fail tidak dibenarkan.");
                return null;
            }

            if (fileUpload.PostedFile.ContentLength > MaxAttachSize)
            {
                errorMessage = T("File exceeds 10 MB limit.", "Fail melebihi had 10 MB.");
                return null;
            }

            string directory = Server.MapPath("~/Images/PrivateMessage/");
            if (!System.IO.Directory.Exists(directory))
                System.IO.Directory.CreateDirectory(directory);

            string fileName = fileUpload.FileName;
            fileUpload.SaveAs(System.IO.Path.Combine(directory, fileName));
            return fileName;
        }

        /// <summary>
        /// Gets the role of the other user in a chat conversation.
        /// </summary>
        private string GetOtherUserRole(string chatId)
        {
            string teacherId = Session["userId"].ToString();

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand(
                        @"SELECT u.[role] FROM dbo.[userChat] uc 
                          INNER JOIN dbo.[User] u ON u.[userId]=CASE WHEN uc.[userId]=@uid THEN uc.[user2Id] ELSE uc.[userId] END 
                          WHERE uc.[chatId]=@cid AND (uc.[userId]=@uid OR uc.[user2Id]=@uid)", conn))
                    {
                        cmd.Parameters.AddWithValue("@uid", teacherId);
                        cmd.Parameters.AddWithValue("@cid", chatId);
                        return cmd.ExecuteScalar()?.ToString();
                    }
                }
            }
            catch { return null; }
        }

        #endregion

        #region Page Lifecycle

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"]?.ToString() != "Teacher")
            {
                Response.Redirect("~/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            var master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                ddlRecipient.Items.Clear();
                ddlRecipient.Items.Add(new ListItem(T("— Select Recipient —", "— Pilih Penerima —"), ""));

                LoadRecipientsJson();
                CheckUnreadAndNotify();
                LoadConversations();
            }
        }

        #endregion

        #region Event Handlers

        protected void rptConvs_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Select")
            {
                SelectedChatId = e.CommandArgument.ToString();
                LoadConversations();
            }
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            // Filtering is now handled client-side; kept for backward compatibility
            LoadConversations();
        }

        protected void btnSend_Click(object sender, EventArgs e)
        {
            string messageText = txtMessage.Text.Trim();
            string chatId = SelectedChatId;

            // Validate and save attachment
            string attachFile = null;
            if (fuAttachment.HasFile)
            {
                string error;
                attachFile = SaveAttachment(fuAttachment, out error);

                if (attachFile == null && error != null)
                {
                    txtMessage.Text = messageText;
                    LoadConversations();
                    return;
                }
            }

            if (string.IsNullOrEmpty(messageText) && string.IsNullOrEmpty(attachFile)) return;
            if (string.IsNullOrEmpty(chatId)) return;

            string teacherId = Session["userId"].ToString();

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    VerifyAndSendWithAttach(conn, chatId, teacherId, messageText, attachFile);
                }
                txtMessage.Text = "";
            }
            catch { }

            LoadConversations();
        }

        protected void btnCompose_Click(object sender, EventArgs e)
        {
            SelectedChatId = "";
            pnlNoChat.Visible = false;
            pnlChat.Visible = false;
            pnlCompose.Visible = true;
            LoadConversations();
        }

        protected void ddlRecipientType_Changed(object sender, EventArgs e)
        {
            ddlRecipient.Items.Clear();
            ddlRecipient.Items.Add(new ListItem(T("— Select Recipient —", "— Pilih Penerima —"), ""));

            string recipientType = ddlRecipientType.SelectedValue;

            if (!string.IsNullOrEmpty(recipientType))
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    string sql = recipientType == "Student"
                        ? "SELECT u.[userId],COALESCE(s.[name],u.[username]) AS n FROM dbo.[User] u LEFT JOIN dbo.[Student] s ON s.[userId]=u.[userId] WHERE u.[role]='Student' AND u.[status]='Active' ORDER BY n"
                        : "SELECT u.[userId],COALESCE(p.[name],u.[username]) AS n FROM dbo.[User] u LEFT JOIN dbo.[Parent] p ON p.[userId]=u.[userId] WHERE u.[role]='Parent' AND u.[status]='Active' ORDER BY n";

                    using (var cmd = new SqlCommand(sql, conn))
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                            ddlRecipient.Items.Add(new ListItem(reader["n"].ToString(), reader["userId"].ToString()));
                    }
                }
            }

            pnlCompose.Visible = true;
            pnlNoChat.Visible = false;
            pnlChat.Visible = false;
        }

        protected void btnComposeSend_Click(object sender, EventArgs e)
        {
            string recipientId = ddlRecipient.SelectedValue;
            string messageText = txtComposeMsg.Text.Trim();
            string teacherId = Session["userId"].ToString();

            // Validate and save attachment
            string attachFile = null;
            if (fuComposeAttachment.HasFile)
            {
                string error;
                attachFile = SaveAttachment(fuComposeAttachment, out error);

                if (attachFile == null && error != null)
                {
                    pnlComposeVal.Visible = true;
                    litComposeError.Text = error;
                    pnlCompose.Visible = true;
                    pnlNoChat.Visible = false;
                    return;
                }
            }

            if (string.IsNullOrEmpty(recipientId))
            {
                pnlComposeVal.Visible = true;
                litComposeError.Text = T("Select a recipient first.", "Pilih penerima terlebih dahulu.");
                pnlCompose.Visible = true;
                pnlNoChat.Visible = false;
                return;
            }

            if (string.IsNullOrEmpty(messageText) && string.IsNullOrEmpty(attachFile))
            {
                pnlComposeVal.Visible = true;
                litComposeError.Text = T("Message or attachment is required.", "Mesej atau lampiran diperlukan.");
                pnlCompose.Visible = true;
                pnlNoChat.Visible = false;
                return;
            }

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // Find existing chat or create a new one
                    string chatId = FindExistingChat(conn, teacherId, recipientId);

                    if (string.IsNullOrEmpty(chatId))
                        chatId = CreateNewChat(conn, teacherId, recipientId);

                    VerifyAndSendWithAttach(conn, chatId, teacherId, messageText, attachFile);

                    SelectedChatId = chatId;
                    txtComposeMsg.Text = "";
                    pnlComposeVal.Visible = false;
                }
            }
            catch
            {
                pnlComposeVal.Visible = true;
                litComposeError.Text = T("An error occurred.", "Ralat berlaku.");
                pnlCompose.Visible = true;
                return;
            }

            LoadConversations();
        }

        #endregion

        #region Data Loading

        /// <summary>
        /// Loads all active Students and Parents into a JSON hidden field for client-side filtering.
        /// </summary>
        private void LoadRecipientsJson()
        {
            var recipients = new List<object>();

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    using (var cmd = new SqlCommand(
                        @"SELECT u.[userId], u.[role], COALESCE(s.[name], p.[name], u.[username]) AS n
                          FROM dbo.[User] u 
                          LEFT JOIN dbo.[Student] s ON s.[userId]=u.[userId] 
                          LEFT JOIN dbo.[Parent] p ON p.[userId]=u.[userId]
                          WHERE u.[role] IN ('Student','Parent') AND u.[status]='Active' 
                          ORDER BY n", conn))
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            recipients.Add(new
                            {
                                id = reader["userId"].ToString(),
                                name = reader["n"].ToString(),
                                role = reader["role"].ToString()
                            });
                        }
                    }
                }
            }
            catch { }

            hidRecipientsJson.Value = new System.Web.Script.Serialization.JavaScriptSerializer().Serialize(recipients);
        }

        /// <summary>
        /// Loads the conversation list for the current teacher, ordered by most recent message.
        /// </summary>
        private void LoadConversations()
        {
            string teacherId = Session["userId"].ToString();
            string search = ""; // Search is now handled client-side

            string sql = @"
                SELECT uc.[chatId],
                    CASE WHEN uc.[userId]=@uid THEN uc.[user2Id] ELSE uc.[userId] END AS otherUserId,
                    u.[role] AS otherRole,
                    COALESCE(s.[name], p.[name], u.[username]) AS otherName,
                    (SELECT TOP 1 [msgText] FROM dbo.[privateMessage] WHERE [chatId]=uc.[chatId] ORDER BY [sentAt] DESC) AS lastMsg,
                    (SELECT TOP 1 [sentAt] FROM dbo.[privateMessage] WHERE [chatId]=uc.[chatId] ORDER BY [sentAt] DESC) AS lastTime,
                    (SELECT COUNT(*) FROM dbo.[privateMessage] WHERE [chatId]=uc.[chatId] AND [senderUserId]<>@uid AND ([isRead]=0 OR [isRead] IS NULL)) AS unreadCount
                FROM dbo.[userChat] uc
                INNER JOIN dbo.[User] u ON u.[userId]=CASE WHEN uc.[userId]=@uid THEN uc.[user2Id] ELSE uc.[userId] END
                LEFT JOIN dbo.[Student] s ON s.[userId]=u.[userId]
                LEFT JOIN dbo.[Parent] p ON p.[userId]=u.[userId]
                WHERE (uc.[userId]=@uid OR uc.[user2Id]=@uid) AND u.[role] IN ('Student','Parent')
                ORDER BY lastTime DESC";

            var conversationList = new List<object>();

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@uid", teacherId);

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string name = reader["otherName"]?.ToString() ?? "User";
                            string role = reader["otherRole"]?.ToString() ?? "";
                            string initials = GetInitials(name);
                            string lastMsg = reader["lastMsg"]?.ToString() ?? "";
                            DateTime? lastTime = reader["lastTime"] != DBNull.Value
                                ? (DateTime?)Convert.ToDateTime(reader["lastTime"])
                                : null;

                            conversationList.Add(new
                            {
                                chatId = reader["chatId"].ToString(),
                                name,
                                role,
                                initials,
                                lastMsg = lastMsg.Length > 40 ? lastMsg.Substring(0, 40) + "…" : lastMsg,
                                timeAgo = lastTime.HasValue ? FormatTime(lastTime.Value) : "",
                                unreadCount = Convert.ToInt32(reader["unreadCount"])
                            });
                        }
                    }
                }
            }

            if (conversationList.Count > 0)
            {
                rptConvs.DataSource = conversationList;
                rptConvs.DataBind();
                pnlNoConvs.Visible = false;
            }
            else
            {
                pnlNoConvs.Visible = true;
                litNoConvMsg.Text = string.IsNullOrEmpty(search)
                    ? T("No private messages yet.", "Tiada mesej peribadi lagi.")
                    : T("No matching conversations found.", "Tiada perbualan sepadan ditemui.");
            }

            if (!string.IsNullOrEmpty(SelectedChatId))
                LoadMessages();
        }

        /// <summary>
        /// Loads messages for the currently selected chat and marks incoming messages as read.
        /// </summary>
        private void LoadMessages()
        {
            string chatId = SelectedChatId;
            string teacherId = Session["userId"].ToString();

            pnlNoChat.Visible = false;
            pnlCompose.Visible = false;
            pnlChat.Visible = true;

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Load chat header info (other user's name and role)
                using (var cmd = new SqlCommand(
                    @"SELECT u.[role], COALESCE(s.[name], p.[name], u.[username]) AS n 
                      FROM dbo.[userChat] uc
                      INNER JOIN dbo.[User] u ON u.[userId]=CASE WHEN uc.[userId]=@uid THEN uc.[user2Id] ELSE uc.[userId] END
                      LEFT JOIN dbo.[Student] s ON s.[userId]=u.[userId] 
                      LEFT JOIN dbo.[Parent] p ON p.[userId]=u.[userId]
                      WHERE uc.[chatId]=@cid AND (uc.[userId]=@uid OR uc.[user2Id]=@uid)", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", teacherId);
                    cmd.Parameters.AddWithValue("@cid", chatId);

                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string name = reader["n"]?.ToString() ?? "User";
                            litChatInitials.Text = HttpUtility.HtmlEncode(GetInitials(name));
                            litChatName.Text = HttpUtility.HtmlEncode(name);
                            litChatRole.Text = HttpUtility.HtmlEncode(reader["role"]?.ToString() ?? "");
                        }
                    }
                }

                // Mark all incoming messages as read
                using (var cmd = new SqlCommand(
                    @"UPDATE dbo.[privateMessage] SET [isRead]=1, [readAt]=GETDATE() 
                      WHERE [chatId]=@cid AND [senderUserId]<>@uid AND ([isRead]=0 OR [isRead] IS NULL)", conn))
                {
                    cmd.Parameters.AddWithValue("@cid", chatId);
                    cmd.Parameters.AddWithValue("@uid", teacherId);
                    cmd.ExecuteNonQuery();
                }

                // Load all messages in chronological order
                var messages = new List<object>();

                using (var cmd = new SqlCommand(
                    @"SELECT [senderUserId], [msgText], [attachmentFile], [sentAt], [isRead] 
                      FROM dbo.[privateMessage] WHERE [chatId]=@cid ORDER BY [sentAt] ASC", conn))
                {
                    cmd.Parameters.AddWithValue("@cid", chatId);

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            DateTime sentAt = reader["sentAt"] != DBNull.Value
                                ? Convert.ToDateTime(reader["sentAt"])
                                : DateTime.Now;

                            bool isSentByTeacher = reader["senderUserId"].ToString() == teacherId;
                            bool isRead = reader["isRead"] != DBNull.Value && Convert.ToBoolean(reader["isRead"]);

                            messages.Add(new
                            {
                                msgText = reader["msgText"]?.ToString() ?? "",
                                attachmentFile = reader["attachmentFile"]?.ToString(),
                                isSent = isSentByTeacher,
                                timeStr = sentAt.ToString("h:mm tt, d MMM"),
                                isRead
                            });
                        }
                    }
                }

                if (messages.Count > 0)
                {
                    rptMessages.DataSource = messages;
                    rptMessages.DataBind();
                    pnlNoMessages.Visible = false;
                }
                else
                {
                    pnlNoMessages.Visible = true;
                    rptMessages.DataSource = null;
                    rptMessages.DataBind();
                }
            }
        }

        #endregion

        #region Database Operations

        /// <summary>
        /// Finds an existing chat between two users. Returns chatId or null.
        /// </summary>
        private string FindExistingChat(SqlConnection conn, string userId, string recipientId)
        {
            using (var cmd = new SqlCommand(
                "SELECT [chatId] FROM dbo.[userChat] WHERE ([userId]=@a AND [user2Id]=@b) OR ([userId]=@b AND [user2Id]=@a)", conn))
            {
                cmd.Parameters.AddWithValue("@a", userId);
                cmd.Parameters.AddWithValue("@b", recipientId);
                return cmd.ExecuteScalar()?.ToString();
            }
        }

        /// <summary>
        /// Creates a new chat record and returns the generated chatId.
        /// </summary>
        private string CreateNewChat(SqlConnection conn, string teacherId, string recipientId)
        {
            string chatId = GenerateNextId(conn,
                "SELECT ISNULL(MAX(CAST(SUBSTRING([chatId],2,LEN([chatId])-1) AS INT)),0) FROM dbo.[userChat]",
                "C", 3);

            using (var cmd = new SqlCommand(
                "INSERT INTO dbo.[userChat]([chatId],[userId],[user2Id],[createdAt]) VALUES(@c,@u,@r,GETDATE())", conn))
            {
                cmd.Parameters.AddWithValue("@c", chatId);
                cmd.Parameters.AddWithValue("@u", teacherId);
                cmd.Parameters.AddWithValue("@r", recipientId);
                cmd.ExecuteNonQuery();
            }

            return chatId;
        }

        /// <summary>
        /// Verifies the sender belongs to the chat, inserts the message, and sends a notification.
        /// </summary>
        private void VerifyAndSend(SqlConnection conn, string chatId, string userId, string msg)
        {
            VerifyAndSendWithAttach(conn, chatId, userId, msg, null);
        }

        /// <summary>
        /// Verifies the sender belongs to the chat, inserts the message with optional attachment, 
        /// and sends a notification to the recipient.
        /// </summary>
        private void VerifyAndSendWithAttach(SqlConnection conn, string chatId, string senderId, string messageText, string attachFile)
        {
            // Verify sender is part of this chat
            using (var cmd = new SqlCommand(
                "SELECT COUNT(*) FROM dbo.[userChat] WHERE [chatId]=@c AND ([userId]=@u OR [user2Id]=@u)", conn))
            {
                cmd.Parameters.AddWithValue("@c", chatId);
                cmd.Parameters.AddWithValue("@u", senderId);
                if (Convert.ToInt32(cmd.ExecuteScalar()) == 0) return;
            }

            // Generate next message ID
            string messageId = GenerateNextId(conn,
                "SELECT ISNULL(MAX(CAST(SUBSTRING([privateMsgId],3,LEN([privateMsgId])-2) AS INT)),0) FROM dbo.[privateMessage]",
                "PM", 3);

            // Insert the message
            string sql = string.IsNullOrEmpty(attachFile)
                ? "INSERT INTO dbo.[privateMessage]([privateMsgId],[chatId],[senderUserId],[msgText],[sentAt],[isRead]) VALUES(@id,@c,@u,@m,GETDATE(),0)"
                : "INSERT INTO dbo.[privateMessage]([privateMsgId],[chatId],[senderUserId],[msgText],[attachmentFile],[sentAt],[isRead]) VALUES(@id,@c,@u,@m,@af,GETDATE(),0)";

            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@id", messageId);
                cmd.Parameters.AddWithValue("@c", chatId);
                cmd.Parameters.AddWithValue("@u", senderId);
                cmd.Parameters.AddWithValue("@m", string.IsNullOrEmpty(messageText) ? (object)DBNull.Value : messageText);

                if (!string.IsNullOrEmpty(attachFile))
                    cmd.Parameters.AddWithValue("@af", attachFile);

                cmd.ExecuteNonQuery();
            }

            // Send notification to the recipient
            SendMessageNotification(conn, chatId, senderId);
        }

        /// <summary>
        /// Creates a notification for the chat recipient when a new message is sent.
        /// Notification text varies based on whether the recipient is a Parent or Student.
        /// </summary>
        private void SendMessageNotification(SqlConnection conn, string chatId, string senderId)
        {
            try
            {
                // Determine the recipient (the other user in the chat)
                string recipientId = null;
                using (var cmd = new SqlCommand(
                    "SELECT CASE WHEN [userId]=@u THEN [user2Id] ELSE [userId] END FROM dbo.[userChat] WHERE [chatId]=@c", conn))
                {
                    cmd.Parameters.AddWithValue("@u", senderId);
                    cmd.Parameters.AddWithValue("@c", chatId);
                    recipientId = cmd.ExecuteScalar()?.ToString();
                }

                if (string.IsNullOrEmpty(recipientId)) return;

                // Get recipient role to determine notification wording
                string recipientRole = "";
                using (var cmd = new SqlCommand("SELECT [role] FROM dbo.[User] WHERE [userId]=@uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", recipientId);
                    recipientRole = cmd.ExecuteScalar()?.ToString() ?? "";
                }

                string msgEN, msgBM;
                if (recipientRole.Equals("Parent", StringComparison.OrdinalIgnoreCase))
                {
                    msgEN = "You have received a new message regarding your child's learning progress.";
                    msgBM = "Anda telah menerima mesej baharu berkaitan perkembangan pembelajaran anak anda.";
                }
                else
                {
                    msgEN = "You have received a new message from your teacher.";
                    msgBM = "Anda telah menerima mesej baharu daripada guru anda.";
                }

                string notificationId = GenerateNextId(conn,
                    "SELECT ISNULL(MAX(CAST(SUBSTRING([notificationId],2,LEN([notificationId])-1) AS INT)),0) FROM dbo.[Notification]",
                    "N", 3);

                using (var cmd = new SqlCommand(
                    @"INSERT INTO dbo.[Notification]([notificationId],[toUserId],[titleEN],[titleBM],[messageEN],[messageBM],[isRead],[createdAt]) 
                      VALUES(@id,@uid,@tEN,@tBM,@mEN,@mBM,0,GETDATE())", conn))
                {
                    cmd.Parameters.AddWithValue("@id", notificationId);
                    cmd.Parameters.AddWithValue("@uid", recipientId);
                    cmd.Parameters.AddWithValue("@tEN", "New Message from Teacher");
                    cmd.Parameters.AddWithValue("@tBM", "Mesej Baharu daripada Guru");
                    cmd.Parameters.AddWithValue("@mEN", msgEN);
                    cmd.Parameters.AddWithValue("@mBM", msgBM);
                    cmd.ExecuteNonQuery();
                }
            }
            catch { /* Notification failure is non-critical */ }
        }

        /// <summary>
        /// Checks for unread messages sent to this teacher and creates notifications
        /// for any that don't already have one. Duplicate check uses toUserId + titleEN + createdAt.
        /// </summary>
        private void CheckUnreadAndNotify()
        {
            try
            {
                string teacherId = Session["userId"].ToString();

                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // Find unread messages where this teacher is the recipient (not the sender)
                    const string sqlUnread = @"
                        SELECT pm.[sentAt]
                        FROM dbo.[privateMessage] pm
                        INNER JOIN dbo.[userChat] uc ON uc.[chatId]=pm.[chatId]
                        WHERE pm.[senderUserId]<>@uid
                          AND (uc.[userId]=@uid OR uc.[user2Id]=@uid)
                          AND (pm.[isRead]=0 OR pm.[isRead] IS NULL)
                          AND NOT EXISTS (
                              SELECT 1 FROM dbo.[Notification] n
                              WHERE n.[toUserId]=@uid
                                AND n.[titleEN]='New Private Message'
                                AND n.[createdAt]=pm.[sentAt]
                          )";

                    var unreadDates = new List<DateTime>();

                    using (var cmd = new SqlCommand(sqlUnread, conn))
                    {
                        cmd.Parameters.AddWithValue("@uid", teacherId);

                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                if (reader["sentAt"] != DBNull.Value)
                                    unreadDates.Add(Convert.ToDateTime(reader["sentAt"]));
                            }
                        }
                    }

                    // Insert a notification for each unread message without a duplicate
                    foreach (var sentAt in unreadDates)
                    {
                        string notificationId = GenerateNextId(conn,
                            "SELECT ISNULL(MAX(CAST(SUBSTRING([notificationId],2,LEN([notificationId])-1) AS INT)),0) FROM dbo.[Notification]",
                            "N", 3);

                        using (var cmd = new SqlCommand(
                            @"INSERT INTO dbo.[Notification]([notificationId],[toUserId],[titleEN],[messageEN],[titleBM],[messageBM],[isRead],[createdAt])
                              VALUES(@id,@uid,@tEN,@mEN,@tBM,@mBM,0,@dt)", conn))
                        {
                            cmd.Parameters.AddWithValue("@id", notificationId);
                            cmd.Parameters.AddWithValue("@uid", teacherId);
                            cmd.Parameters.AddWithValue("@tEN", "New Private Message");
                            cmd.Parameters.AddWithValue("@mEN", "You received a new private message.");
                            cmd.Parameters.AddWithValue("@tBM", "Mesej Peribadi Baharu");
                            cmd.Parameters.AddWithValue("@mBM", "Anda menerima mesej peribadi baharu.");
                            cmd.Parameters.AddWithValue("@dt", sentAt);
                            cmd.ExecuteNonQuery();
                        }
                    }
                }
            }
            catch { /* Notification creation failure should not block page load */ }
        }

        #endregion
    }
}
