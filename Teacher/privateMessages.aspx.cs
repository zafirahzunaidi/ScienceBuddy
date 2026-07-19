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
        protected string CurrentLanguage { get { string l = Session["preferredLanguage"] as string; return string.IsNullOrEmpty(l) ? "EN" : l; } }
        protected string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        protected string SelectedChatId { get { return hidSelectedChat.Value ?? ""; } set { hidSelectedChat.Value = value; } }
        private string FilterRole { get { return ViewState["FR"] as string ?? "All"; } set { ViewState["FR"] = value; } }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"]?.ToString() != "Teacher")
            { Response.Redirect("~/Login.aspx", false); Context.ApplicationInstance.CompleteRequest(); return; }
            var master = (ScienceBuddy.SiteMaster)Master; master.LayoutMode = "Sidebar";
            if (!IsPostBack)
            {
                ddlRecipient.Items.Clear();
                ddlRecipient.Items.Add(new ListItem(T("— Select Recipient —","— Pilih Penerima —"), ""));
                LoadRecipientsJson();
                CheckUnreadAndNotify();
                LoadConversations();
            }
        }

        private void LoadRecipientsJson()
        {
            var recipients = new List<object>();
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand(@"SELECT u.[userId],u.[role],COALESCE(s.[name],p.[name],u.[username]) AS n
                        FROM dbo.[User] u LEFT JOIN dbo.[Student] s ON s.[userId]=u.[userId] LEFT JOIN dbo.[Parent] p ON p.[userId]=u.[userId]
                        WHERE u.[role] IN ('Student','Parent') AND u.[status]='Active' ORDER BY n", conn))
                    using (var r = cmd.ExecuteReader())
                        while (r.Read())
                            recipients.Add(new { id = r["userId"].ToString(), name = r["n"].ToString(), role = r["role"].ToString() });
                }
            }
            catch { }
            hidRecipientsJson.Value = new System.Web.Script.Serialization.JavaScriptSerializer().Serialize(recipients);
        }

        private void LoadConversations()
        {
            string userId = Session["userId"].ToString();
            string search = ""; // Search is now handled client-side
            string sql = @"SELECT uc.[chatId],
                CASE WHEN uc.[userId]=@uid THEN uc.[user2Id] ELSE uc.[userId] END AS otherUserId,
                u.[role] AS otherRole,
                COALESCE(s.[name],p.[name],u.[username]) AS otherName,
                (SELECT TOP 1 [msgText] FROM dbo.[privateMessage] WHERE [chatId]=uc.[chatId] ORDER BY [sentAt] DESC) AS lastMsg,
                (SELECT TOP 1 [sentAt] FROM dbo.[privateMessage] WHERE [chatId]=uc.[chatId] ORDER BY [sentAt] DESC) AS lastTime,
                (SELECT COUNT(*) FROM dbo.[privateMessage] WHERE [chatId]=uc.[chatId] AND [senderUserId]<>@uid AND ([isRead]=0 OR [isRead] IS NULL)) AS unreadCount
                FROM dbo.[userChat] uc
                INNER JOIN dbo.[User] u ON u.[userId]=CASE WHEN uc.[userId]=@uid THEN uc.[user2Id] ELSE uc.[userId] END
                LEFT JOIN dbo.[Student] s ON s.[userId]=u.[userId]
                LEFT JOIN dbo.[Parent] p ON p.[userId]=u.[userId]
                WHERE (uc.[userId]=@uid OR uc.[user2Id]=@uid) AND u.[role] IN ('Student','Parent')";
            sql += " ORDER BY lastTime DESC";

            var list = new List<object>();
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    using (var r = cmd.ExecuteReader())
                        while (r.Read())
                        {
                            string name = r["otherName"]?.ToString() ?? "User";
                            string role = r["otherRole"]?.ToString() ?? "";
                            var parts = name.Split(' ');
                            string initials = parts.Length >= 2 ? (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper() : name[0].ToString().ToUpper();
                            string lastMsg = r["lastMsg"]?.ToString() ?? "";
                            DateTime? lastTime = r["lastTime"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(r["lastTime"]) : null;
                            list.Add(new { chatId = r["chatId"].ToString(), name, role, initials, lastMsg = lastMsg.Length > 40 ? lastMsg.Substring(0, 40) + "…" : lastMsg, timeAgo = lastTime.HasValue ? FormatTime(lastTime.Value) : "", unreadCount = Convert.ToInt32(r["unreadCount"]) });
                        }
                }
            }
            if (list.Count > 0) { rptConvs.DataSource = list; rptConvs.DataBind(); pnlNoConvs.Visible = false; }
            else { pnlNoConvs.Visible = true; litNoConvMsg.Text = string.IsNullOrEmpty(search)
                ? T("No private messages yet.", "Tiada mesej peribadi lagi.")
                : T("No matching conversations found.", "Tiada perbualan sepadan ditemui."); }
            if (!string.IsNullOrEmpty(SelectedChatId)) LoadMessages();
        }

        private void LoadMessages()
        {
            string chatId = SelectedChatId; string userId = Session["userId"].ToString();
            pnlNoChat.Visible = false; pnlCompose.Visible = false; pnlChat.Visible = true;
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(@"SELECT u.[role],COALESCE(s.[name],p.[name],u.[username]) AS n FROM dbo.[userChat] uc
                    INNER JOIN dbo.[User] u ON u.[userId]=CASE WHEN uc.[userId]=@uid THEN uc.[user2Id] ELSE uc.[userId] END
                    LEFT JOIN dbo.[Student] s ON s.[userId]=u.[userId] LEFT JOIN dbo.[Parent] p ON p.[userId]=u.[userId]
                    WHERE uc.[chatId]=@cid AND (uc.[userId]=@uid OR uc.[user2Id]=@uid)", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId); cmd.Parameters.AddWithValue("@cid", chatId);
                    using (var r = cmd.ExecuteReader()) if (r.Read())
                    {
                        string name = r["n"]?.ToString() ?? "User"; var parts = name.Split(' ');
                        litChatInitials.Text = HttpUtility.HtmlEncode(parts.Length >= 2 ? (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper() : name[0].ToString().ToUpper());
                        litChatName.Text = HttpUtility.HtmlEncode(name);
                        litChatRole.Text = HttpUtility.HtmlEncode(r["role"]?.ToString() ?? "");
                    }
                }
                using (var cmd = new SqlCommand("UPDATE dbo.[privateMessage] SET [isRead]=1,[readAt]=GETDATE() WHERE [chatId]=@cid AND [senderUserId]<>@uid AND ([isRead]=0 OR [isRead] IS NULL)", conn))
                { cmd.Parameters.AddWithValue("@cid", chatId); cmd.Parameters.AddWithValue("@uid", userId); cmd.ExecuteNonQuery(); }
                var msgs = new List<object>();
                using (var cmd = new SqlCommand("SELECT [senderUserId],[msgText],[attachmentFile],[sentAt],[isRead] FROM dbo.[privateMessage] WHERE [chatId]=@cid ORDER BY [sentAt] ASC", conn))
                {
                    cmd.Parameters.AddWithValue("@cid", chatId);
                    using (var r = cmd.ExecuteReader()) while (r.Read())
                    {
                        DateTime sent = r["sentAt"] != DBNull.Value ? Convert.ToDateTime(r["sentAt"]) : DateTime.Now;
                        bool isSentMsg = r["senderUserId"].ToString() == userId;
                        bool isReadMsg = r["isRead"] != DBNull.Value && Convert.ToBoolean(r["isRead"]);
                        msgs.Add(new { msgText = r["msgText"]?.ToString() ?? "", attachmentFile = r["attachmentFile"]?.ToString(), isSent = isSentMsg, timeStr = sent.ToString("h:mm tt, d MMM"), isRead = isReadMsg });
                    }
                }
                if (msgs.Count > 0) { rptMessages.DataSource = msgs; rptMessages.DataBind(); pnlNoMessages.Visible = false; }
                else { pnlNoMessages.Visible = true; rptMessages.DataSource = null; rptMessages.DataBind(); }
            }
        }

        protected void rptConvs_ItemCommand(object source, RepeaterCommandEventArgs e)
        { if (e.CommandName == "Select") { SelectedChatId = e.CommandArgument.ToString(); LoadConversations(); } }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            // Filtering is now handled client-side; this method is kept for backward compatibility
            LoadConversations();
        }

        private string GetOtherUserRole(string chatId)
        {
            string uid = Session["userId"].ToString();
            try { using (var conn = new SqlConnection(ConnStr)) { conn.Open(); using (var cmd = new SqlCommand("SELECT u.[role] FROM dbo.[userChat] uc INNER JOIN dbo.[User] u ON u.[userId]=CASE WHEN uc.[userId]=@uid THEN uc.[user2Id] ELSE uc.[userId] END WHERE uc.[chatId]=@cid AND (uc.[userId]=@uid OR uc.[user2Id]=@uid)", conn)) { cmd.Parameters.AddWithValue("@uid", uid); cmd.Parameters.AddWithValue("@cid", chatId); return cmd.ExecuteScalar()?.ToString(); } } }
            catch { return null; }
        }

        private static readonly HashSet<string> AllowedAttachExts = new HashSet<string>(
            StringComparer.OrdinalIgnoreCase) { ".pdf", ".doc", ".docx", ".ppt", ".pptx", ".jpg", ".jpeg", ".png" };
        private const int MaxAttachSize = 10 * 1024 * 1024;

        protected void btnSend_Click(object sender, EventArgs e)
        {
            string msg = txtMessage.Text.Trim(); string chatId = SelectedChatId;
            string attachFile = null;

            // Handle file attachment
            if (fuAttachment.HasFile)
            {
                string ext = System.IO.Path.GetExtension(fuAttachment.FileName).ToLower();
                if (!AllowedAttachExts.Contains(ext)) { txtMessage.Text = msg; LoadConversations(); return; }
                if (fuAttachment.PostedFile.ContentLength > MaxAttachSize) { txtMessage.Text = msg; LoadConversations(); return; }
                string dir = Server.MapPath("~/Images/PrivateMessage/");
                if (!System.IO.Directory.Exists(dir)) System.IO.Directory.CreateDirectory(dir);
                string fn = fuAttachment.FileName; // preserve original filename
                fuAttachment.SaveAs(System.IO.Path.Combine(dir, fn));
                attachFile = fn; // store only filename, no path
            }

            if (string.IsNullOrEmpty(msg) && string.IsNullOrEmpty(attachFile)) return;
            if (string.IsNullOrEmpty(chatId)) return;
            string userId = Session["userId"].ToString();
            try { using (var conn = new SqlConnection(ConnStr)) { conn.Open(); VerifyAndSendWithAttach(conn, chatId, userId, msg, attachFile); } txtMessage.Text = ""; }
            catch { }
            LoadConversations();
        }

        // ── Compose Mode ─────────────────────────────────────────────
        protected void btnCompose_Click(object sender, EventArgs e)
        {
            SelectedChatId = "";
            pnlNoChat.Visible = false; pnlChat.Visible = false; pnlCompose.Visible = true;
            LoadConversations();
        }

        protected void ddlRecipientType_Changed(object sender, EventArgs e)
        {
            ddlRecipient.Items.Clear();
            ddlRecipient.Items.Add(new ListItem(T("— Select Recipient —","— Pilih Penerima —"), ""));
            string type = ddlRecipientType.SelectedValue;
            if (!string.IsNullOrEmpty(type))
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    string sql = type == "Student"
                        ? "SELECT u.[userId],COALESCE(s.[name],u.[username]) AS n FROM dbo.[User] u LEFT JOIN dbo.[Student] s ON s.[userId]=u.[userId] WHERE u.[role]='Student' AND u.[status]='Active' ORDER BY n"
                        : "SELECT u.[userId],COALESCE(p.[name],u.[username]) AS n FROM dbo.[User] u LEFT JOIN dbo.[Parent] p ON p.[userId]=u.[userId] WHERE u.[role]='Parent' AND u.[status]='Active' ORDER BY n";
                    using (var cmd = new SqlCommand(sql, conn)) using (var r = cmd.ExecuteReader()) while (r.Read()) ddlRecipient.Items.Add(new ListItem(r["n"].ToString(), r["userId"].ToString()));
                }
            }
            pnlCompose.Visible = true; pnlNoChat.Visible = false; pnlChat.Visible = false;
        }

        protected void btnComposeSend_Click(object sender, EventArgs e)
        {
            string recipientId = ddlRecipient.SelectedValue;
            string msg = txtComposeMsg.Text.Trim();
            string userId = Session["userId"].ToString();

            // Handle compose attachment
            string attachFile = null;
            if (fuComposeAttachment.HasFile)
            {
                string ext = System.IO.Path.GetExtension(fuComposeAttachment.FileName).ToLower();
                if (!AllowedAttachExts.Contains(ext)) { pnlComposeVal.Visible = true; litComposeError.Text = T("File type not allowed.","Jenis fail tidak dibenarkan."); pnlCompose.Visible = true; pnlNoChat.Visible = false; return; }
                if (fuComposeAttachment.PostedFile.ContentLength > MaxAttachSize) { pnlComposeVal.Visible = true; litComposeError.Text = T("File exceeds 10 MB limit.","Fail melebihi had 10 MB."); pnlCompose.Visible = true; pnlNoChat.Visible = false; return; }
                string dir = Server.MapPath("~/Images/PrivateMessage/");
                if (!System.IO.Directory.Exists(dir)) System.IO.Directory.CreateDirectory(dir);
                string fn = fuComposeAttachment.FileName;
                fuComposeAttachment.SaveAs(System.IO.Path.Combine(dir, fn));
                attachFile = fn;
            }

            if (string.IsNullOrEmpty(recipientId))
            { pnlComposeVal.Visible = true; litComposeError.Text = T("Select a recipient first.","Pilih penerima terlebih dahulu."); pnlCompose.Visible = true; pnlNoChat.Visible = false; return; }
            if (string.IsNullOrEmpty(msg) && string.IsNullOrEmpty(attachFile))
            { pnlComposeVal.Visible = true; litComposeError.Text = T("Message or attachment is required.","Mesej atau lampiran diperlukan."); pnlCompose.Visible = true; pnlNoChat.Visible = false; return; }

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    string chatId = null;
                    using (var cmd = new SqlCommand("SELECT [chatId] FROM dbo.[userChat] WHERE ([userId]=@a AND [user2Id]=@b) OR ([userId]=@b AND [user2Id]=@a)", conn))
                    { cmd.Parameters.AddWithValue("@a", userId); cmd.Parameters.AddWithValue("@b", recipientId); chatId = cmd.ExecuteScalar()?.ToString(); }
                    if (string.IsNullOrEmpty(chatId))
                    {
                        using (var cmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING([chatId],2,LEN([chatId])-1) AS INT)),0) FROM dbo.[userChat]", conn))
                        { chatId = "C" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3"); }
                        using (var cmd = new SqlCommand("INSERT INTO dbo.[userChat]([chatId],[userId],[user2Id],[createdAt]) VALUES(@c,@u,@r,GETDATE())", conn))
                        { cmd.Parameters.AddWithValue("@c", chatId); cmd.Parameters.AddWithValue("@u", userId); cmd.Parameters.AddWithValue("@r", recipientId); cmd.ExecuteNonQuery(); }
                    }
                    VerifyAndSendWithAttach(conn, chatId, userId, msg, attachFile);
                    SelectedChatId = chatId;
                    txtComposeMsg.Text = "";
                    pnlComposeVal.Visible = false;
                }
            }
            catch { pnlComposeVal.Visible = true; litComposeError.Text = T("An error occurred.","Ralat berlaku."); pnlCompose.Visible = true; return; }
            LoadConversations();
        }

        private void VerifyAndSend(SqlConnection conn, string chatId, string userId, string msg)
        {
            VerifyAndSendWithAttach(conn, chatId, userId, msg, null);
        }

        private void VerifyAndSendWithAttach(SqlConnection conn, string chatId, string userId, string msg, string attachFile)
        {
            using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[userChat] WHERE [chatId]=@c AND ([userId]=@u OR [user2Id]=@u)", conn))
            { cmd.Parameters.AddWithValue("@c", chatId); cmd.Parameters.AddWithValue("@u", userId); if (Convert.ToInt32(cmd.ExecuteScalar()) == 0) return; }
            string msgId;
            using (var cmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING([privateMsgId],3,LEN([privateMsgId])-2) AS INT)),0) FROM dbo.[privateMessage]", conn))
            { msgId = "PM" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3"); }
            string sql = string.IsNullOrEmpty(attachFile)
                ? "INSERT INTO dbo.[privateMessage]([privateMsgId],[chatId],[senderUserId],[msgText],[sentAt],[isRead]) VALUES(@id,@c,@u,@m,GETDATE(),0)"
                : "INSERT INTO dbo.[privateMessage]([privateMsgId],[chatId],[senderUserId],[msgText],[attachmentFile],[sentAt],[isRead]) VALUES(@id,@c,@u,@m,@af,GETDATE(),0)";
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@id", msgId); cmd.Parameters.AddWithValue("@c", chatId);
                cmd.Parameters.AddWithValue("@u", userId); cmd.Parameters.AddWithValue("@m", string.IsNullOrEmpty(msg) ? (object)DBNull.Value : msg);
                if (!string.IsNullOrEmpty(attachFile)) cmd.Parameters.AddWithValue("@af", attachFile);
                cmd.ExecuteNonQuery();
            }

            // Send notification to the recipient (not the sender)
            try
            {
                // Get the other user in the chat
                string recipientId = null;
                using (var cmd = new SqlCommand("SELECT CASE WHEN [userId]=@u THEN [user2Id] ELSE [userId] END FROM dbo.[userChat] WHERE [chatId]=@c", conn))
                { cmd.Parameters.AddWithValue("@u", userId); cmd.Parameters.AddWithValue("@c", chatId); recipientId = cmd.ExecuteScalar()?.ToString(); }

                if (!string.IsNullOrEmpty(recipientId))
                {
                    // Determine recipient role
                    string recipientRole = "";
                    using (var cmd = new SqlCommand("SELECT [role] FROM dbo.[User] WHERE [userId]=@uid", conn))
                    { cmd.Parameters.AddWithValue("@uid", recipientId); recipientRole = cmd.ExecuteScalar()?.ToString() ?? ""; }

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

                    int maxN = 0;
                    using (var cmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING([notificationId],2,LEN([notificationId])-1) AS INT)),0) FROM dbo.[Notification]", conn))
                    { maxN = Convert.ToInt32(cmd.ExecuteScalar()); }
                    string nid = "N" + (maxN + 1).ToString("D3");

                    using (var cmd = new SqlCommand("INSERT INTO dbo.[Notification]([notificationId],[toUserId],[titleEN],[titleBM],[messageEN],[messageBM],[isRead],[createdAt]) VALUES(@id,@uid,@tEN,@tBM,@mEN,@mBM,0,GETDATE())", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", nid);
                        cmd.Parameters.AddWithValue("@uid", recipientId);
                        cmd.Parameters.AddWithValue("@tEN", "New Message from Teacher");
                        cmd.Parameters.AddWithValue("@tBM", "Mesej Baharu daripada Guru");
                        cmd.Parameters.AddWithValue("@mEN", msgEN);
                        cmd.Parameters.AddWithValue("@mBM", msgBM);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch { /* Notification failure is non-critical */ }
        }

        private static string FormatTime(DateTime dt)
        {
            var span = DateTime.Now - dt;
            if (span.TotalMinutes < 1) return "Now";
            if (span.TotalHours < 1) return (int)span.TotalMinutes + "m";
            if (span.TotalDays < 1) return (int)span.TotalHours + "h";
            if (span.TotalDays < 7) return (int)span.TotalDays + "d";
            return dt.ToString("d MMM");
        }

        protected string RenderAttachment(string attachFile)
        {
            if (string.IsNullOrEmpty(attachFile)) return "";
            // Reconstruct the full web path from the stored filename
            string filePath = attachFile.StartsWith("Images/", StringComparison.OrdinalIgnoreCase)
                ? attachFile
                : "Images/PrivateMessage/" + attachFile;
            string url = ResolveUrl("~/" + filePath);
            string ext = System.IO.Path.GetExtension(attachFile).ToLower();
            string fileName = System.IO.Path.GetFileName(attachFile);
            if (ext == ".jpg" || ext == ".jpeg" || ext == ".png")
            {
                return "<a href='" + HttpUtility.HtmlAttributeEncode(url) + "' target='_blank' style='display:block;margin-top:6px;'><img src='" + HttpUtility.HtmlAttributeEncode(url) + "' style='max-width:200px;max-height:150px;border-radius:8px;border:1px solid #E5E7EB;' alt='attachment' /></a>";
            }
            return "<a href='" + HttpUtility.HtmlAttributeEncode(url) + "' target='_blank' class='pm-msg-attach'><i class='bi bi-file-earmark'></i> " + HttpUtility.HtmlEncode(fileName) + "</a>";
        }

        /// <summary>
        /// Check for unread private messages sent TO this teacher and create
        /// a notification for each one that doesn't already have one.
        /// Duplicate check: toUserId + titleEN + createdAt = message sentAt.
        /// </summary>
        private void CheckUnreadAndNotify()
        {
            try
            {
                string userId = Session["userId"].ToString();
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // Find unread messages where this teacher is the recipient (not the sender)
                    // Join userChat to determine which messages are addressed to the teacher
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
                        cmd.Parameters.AddWithValue("@uid", userId);
                        using (var r = cmd.ExecuteReader())
                            while (r.Read())
                                if (r["sentAt"] != DBNull.Value)
                                    unreadDates.Add(Convert.ToDateTime(r["sentAt"]));
                    }

                    // Insert a notification for each unread message without a duplicate
                    foreach (var sentAt in unreadDates)
                    {
                        // Generate next notification ID
                        string notifId;
                        using (var cmd = new SqlCommand(
                            "SELECT ISNULL(MAX(CAST(SUBSTRING([notificationId],2,LEN([notificationId])-1) AS INT)),0) FROM dbo.[Notification]", conn))
                        { notifId = "N" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3"); }

                        using (var cmd = new SqlCommand(@"
                            INSERT INTO dbo.[Notification]([notificationId],[toUserId],[titleEN],[messageEN],[titleBM],[messageBM],[isRead],[createdAt])
                            VALUES(@id,@uid,@tEN,@mEN,@tBM,@mBM,0,@dt)", conn))
                        {
                            cmd.Parameters.AddWithValue("@id", notifId);
                            cmd.Parameters.AddWithValue("@uid", userId);
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
            catch { /* notification creation failure should not block page load */ }
        }
    }
}
