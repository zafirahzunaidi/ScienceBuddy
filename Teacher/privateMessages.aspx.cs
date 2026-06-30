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
                LoadConversations();
            }
        }

        private void LoadConversations()
        {
            string userId = Session["userId"].ToString();
            string search = txtSearchConv.Text.Trim();
            string filter = FilterRole;
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
            if (filter == "Student") sql += " AND u.[role]='Student'";
            else if (filter == "Parent") sql += " AND u.[role]='Parent'";
            if (!string.IsNullOrEmpty(search)) sql += " AND (COALESCE(s.[name],p.[name],u.[username]) LIKE @s)";
            sql += " ORDER BY lastTime DESC";

            var list = new List<object>();
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    if (!string.IsNullOrEmpty(search)) cmd.Parameters.AddWithValue("@s", "%" + search + "%");
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
            else { pnlNoConvs.Visible = true; }
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
                using (var cmd = new SqlCommand("SELECT [senderUserId],[msgText],[attachmentFile],[sentAt] FROM dbo.[privateMessage] WHERE [chatId]=@cid ORDER BY [sentAt] ASC", conn))
                {
                    cmd.Parameters.AddWithValue("@cid", chatId);
                    using (var r = cmd.ExecuteReader()) while (r.Read())
                    {
                        DateTime sent = r["sentAt"] != DBNull.Value ? Convert.ToDateTime(r["sentAt"]) : DateTime.Now;
                        msgs.Add(new { msgText = r["msgText"]?.ToString() ?? "", attachmentFile = r["attachmentFile"]?.ToString(), isSent = r["senderUserId"].ToString() == userId, timeStr = sent.ToString("h:mm tt, d MMM") });
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
            var btn = sender as Button;
            if (btn != null && !string.IsNullOrEmpty(btn.CommandArgument)) FilterRole = btn.CommandArgument;
            btnAll.CssClass = "pm-tab" + (FilterRole == "All" ? " active" : "");
            btnStudents.CssClass = "pm-tab" + (FilterRole == "Student" ? " active" : "");
            btnParents.CssClass = "pm-tab" + (FilterRole == "Parent" ? " active" : "");
            if (!string.IsNullOrEmpty(SelectedChatId) && FilterRole != "All")
            { string r = GetOtherUserRole(SelectedChatId); if (!string.IsNullOrEmpty(r) && r != FilterRole) { SelectedChatId = ""; pnlChat.Visible = false; pnlNoChat.Visible = true; } }
            LoadConversations();
        }

        private string GetOtherUserRole(string chatId)
        {
            string uid = Session["userId"].ToString();
            try { using (var conn = new SqlConnection(ConnStr)) { conn.Open(); using (var cmd = new SqlCommand("SELECT u.[role] FROM dbo.[userChat] uc INNER JOIN dbo.[User] u ON u.[userId]=CASE WHEN uc.[userId]=@uid THEN uc.[user2Id] ELSE uc.[userId] END WHERE uc.[chatId]=@cid AND (uc.[userId]=@uid OR uc.[user2Id]=@uid)", conn)) { cmd.Parameters.AddWithValue("@uid", uid); cmd.Parameters.AddWithValue("@cid", chatId); return cmd.ExecuteScalar()?.ToString(); } } }
            catch { return null; }
        }

        protected void btnSend_Click(object sender, EventArgs e)
        {
            string msg = txtMessage.Text.Trim(); string chatId = SelectedChatId;
            if (string.IsNullOrEmpty(msg) || string.IsNullOrEmpty(chatId)) return;
            string userId = Session["userId"].ToString();
            try { using (var conn = new SqlConnection(ConnStr)) { conn.Open(); VerifyAndSend(conn, chatId, userId, msg); } txtMessage.Text = ""; }
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
            if (string.IsNullOrEmpty(recipientId) || string.IsNullOrEmpty(msg))
            { pnlComposeVal.Visible = true; litComposeError.Text = string.IsNullOrEmpty(recipientId) ? T("Select a recipient first.","Pilih penerima terlebih dahulu.") : T("Message cannot be empty.","Mesej tidak boleh kosong."); pnlCompose.Visible = true; pnlNoChat.Visible = false; return; }

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
                    VerifyAndSend(conn, chatId, userId, msg);
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
            using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[userChat] WHERE [chatId]=@c AND ([userId]=@u OR [user2Id]=@u)", conn))
            { cmd.Parameters.AddWithValue("@c", chatId); cmd.Parameters.AddWithValue("@u", userId); if (Convert.ToInt32(cmd.ExecuteScalar()) == 0) return; }
            string msgId;
            using (var cmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING([privateMsgId],3,LEN([privateMsgId])-2) AS INT)),0) FROM dbo.[privateMessage]", conn))
            { msgId = "PM" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3"); }
            using (var cmd = new SqlCommand("INSERT INTO dbo.[privateMessage]([privateMsgId],[chatId],[senderUserId],[msgText],[sentAt],[isRead]) VALUES(@id,@c,@u,@m,GETDATE(),0)", conn))
            { cmd.Parameters.AddWithValue("@id", msgId); cmd.Parameters.AddWithValue("@c", chatId); cmd.Parameters.AddWithValue("@u", userId); cmd.Parameters.AddWithValue("@m", msg); cmd.ExecuteNonQuery(); }
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
    }
}
