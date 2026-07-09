using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Parent
{
    public partial class ParentTeacherCommunication : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        protected string CurrentLanguage = "EN";
        protected string T(string en, string bm) => CurrentLanguage == "BM" ? bm : en;
        private string _userId = "";
        private string ActiveTab { get { return ViewState["Tab"] as string ?? "Chats"; } set { ViewState["Tab"] = value; } }
        private string SelectedChatId { get { return hidSelectedChat.Value; } set { hidSelectedChat.Value = value; } }

        private static readonly HashSet<string> AllowedImageExt = new HashSet<string>(StringComparer.OrdinalIgnoreCase) { ".png", ".jpg", ".jpeg", ".gif", ".webp" };
        private static readonly HashSet<string> AllowedDocExt = new HashSet<string>(StringComparer.OrdinalIgnoreCase) { ".pdf", ".doc", ".docx", ".ppt", ".pptx", ".xls", ".xlsx", ".txt" };
        private const int MaxFileSize = 5 * 1024 * 1024; // 5MB

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null || Session["role"].ToString() != "Parent") { Response.Redirect("~/Login.aspx", false); Context.ApplicationInstance.CompleteRequest(); return; }
            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            string l = Session["preferredLanguage"] as string; if (!string.IsNullOrEmpty(l)) CurrentLanguage = l;
            _userId = Session["userId"].ToString();
            LoadUnreadBadge(); LoadSidebarChildren();
            if (!IsPostBack)
            {
                btnSend.Text = T("Send", "Hantar");
                txtChatSearch.Attributes["placeholder"] = T("Search conversations...", "Cari perbualan...");
                txtMessage.Attributes["placeholder"] = T("Type your message...", "Taip mesej anda...");
                // Check query string for chat selection
                string qsChatId = Request.QueryString["chatId"];
                if (!string.IsNullOrEmpty(qsChatId)) { SelectedChatId = qsChatId; }
                LoadPage();
            }
            else { LoadPage(); }
        }

        private void LoadSidebarChildren() { ddlSidebarChild.Items.Clear(); try { string pid = ""; using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT parentId FROM dbo.[Parent] WHERE userId=@u", c)) { cmd.Parameters.AddWithValue("@u", _userId); c.Open(); var r = cmd.ExecuteScalar(); if (r != null) pid = r.ToString(); } using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT s.studentId, ISNULL(s.nickname,s.name) AS n FROM dbo.StudentParent sp INNER JOIN dbo.Student s ON sp.studentId=s.studentId WHERE sp.parentId=@p ORDER BY s.name", c)) { cmd.Parameters.AddWithValue("@p", pid); c.Open(); using (var r = cmd.ExecuteReader()) { while (r.Read()) ddlSidebarChild.Items.Add(new ListItem(r["n"].ToString(), r["studentId"].ToString())); } } } catch { } if (ddlSidebarChild.Items.Count > 0) { string saved = Session["selectedChildId"] as string; if (!string.IsNullOrEmpty(saved) && ddlSidebarChild.Items.FindByValue(saved) != null) ddlSidebarChild.SelectedValue = saved; } }
        private void LoadUnreadBadge() { try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.Notification WHERE toUserId=@uid AND isRead=0", c)) { cmd.Parameters.AddWithValue("@uid", _userId); c.Open(); int count = (int)cmd.ExecuteScalar(); litUnreadBadge.Text = count > 0 ? "<span class='pt-sidebar-badge'>" + count + "</span>" : ""; } } catch { } }

        protected void TabMyChats_Click(object sender, EventArgs e) { ActiveTab = "Chats"; }
        protected void TabTeachers_Click(object sender, EventArgs e) { ActiveTab = "Teachers"; }
        protected void ChatSearch_Changed(object sender, EventArgs e) { }
        protected void BtnCloseMsg_Click(object sender, EventArgs e) { pnlMsg.Visible = false; }

        private void LoadPage()
        {
            lnkMyChats.CssClass = ActiveTab == "Chats" ? "pt-message-tab pt-message-tab-active" : "pt-message-tab";
            lnkTeachers.CssClass = ActiveTab == "Teachers" ? "pt-message-tab pt-message-tab-active" : "pt-message-tab";
            pnlMyChats.Visible = ActiveTab == "Chats";
            pnlTeachers.Visible = ActiveTab == "Teachers";
            if (ActiveTab == "Chats") { LoadChatList(); LoadSelectedChat(); }
            else { LoadTeacherGrid(); }
        }

        // ══════════════════════════════════════════════════════════════
        //  MY CHATS
        // ══════════════════════════════════════════════════════════════
        private void LoadChatList()
        {
            pnlChatList.Controls.Clear();
            string search = txtChatSearch.Text.Trim().ToLower();
            try
            {
                using (var c = new SqlConnection(ConnStr))
                {
                    c.Open();
                    // Get all chats where parent is involved
                    string sql = @"SELECT uc.chatId, 
                        CASE WHEN uc.userId=@uid THEN uc.user2Id ELSE uc.userId END AS otherUserId,
                        t.name AS teacherName, t.academicQualification,
                        (SELECT TOP 1 msgText FROM dbo.privateMessage WHERE chatId=uc.chatId ORDER BY sentAt DESC) AS lastMsg,
                        (SELECT TOP 1 sentAt FROM dbo.privateMessage WHERE chatId=uc.chatId ORDER BY sentAt DESC) AS lastMsgTime,
                        (SELECT COUNT(*) FROM dbo.privateMessage WHERE chatId=uc.chatId AND senderUserId<>@uid AND isRead=0) AS unreadCount
                        FROM dbo.userChat uc
                        INNER JOIN dbo.Teacher t ON t.userId = CASE WHEN uc.userId=@uid THEN uc.user2Id ELSE uc.userId END
                        WHERE uc.userId=@uid OR uc.user2Id=@uid
                        ORDER BY lastMsgTime DESC";
                    using (var cmd = new SqlCommand(sql, c))
                    {
                        cmd.Parameters.AddWithValue("@uid", _userId);
                        using (var r = cmd.ExecuteReader())
                        {
                            StringBuilder sb = new StringBuilder(); bool has = false;
                            while (r.Read())
                            {
                                string tName = r["teacherName"] != DBNull.Value ? r["teacherName"].ToString() : "";
                                if (!string.IsNullOrEmpty(search) && !tName.ToLower().Contains(search)) continue;
                                has = true;
                                string chatId = r["chatId"].ToString();
                                string initial = !string.IsNullOrEmpty(tName) ? tName[0].ToString().ToUpper() : "T";
                                string lastMsg = r["lastMsg"] != DBNull.Value ? r["lastMsg"].ToString() : "";
                                if (lastMsg.Length > 40) lastMsg = lastMsg.Substring(0, 40) + "...";
                                string timeStr = r["lastMsgTime"] != DBNull.Value ? GetTimeAgo(Convert.ToDateTime(r["lastMsgTime"])) : "";
                                int unread = r["unreadCount"] != DBNull.Value ? Convert.ToInt32(r["unreadCount"]) : 0;
                                string activeClass = chatId == SelectedChatId ? " pt-chat-item-active" : "";
                                string unreadBadge = unread > 0 ? "<span class='pt-chat-unread-badge'>" + unread + "</span>" : "";
                                string qual = r["academicQualification"] != DBNull.Value ? r["academicQualification"].ToString() : "";

                                sb.AppendFormat(@"<div class='pt-chat-item{0}' onclick=""document.getElementById('{1}').value='{2}';document.getElementById('{3}').click();"">
                                    <div class='pt-chat-avatar'>{4}</div>
                                    <div class='pt-chat-item-body'><div class='pt-chat-item-name'>{5} {6}</div><div style='font-size:0.72rem;color:#6366F1;font-weight:600;margin-bottom:2px;'>{7}</div><div class='pt-chat-item-preview'>{8}</div></div>
                                    <div class='pt-chat-item-time'>{9}</div>
                                </div>", activeClass, hidSelectedChat.ClientID, chatId, btnSelectChat.ClientID,
                                    initial, Server.HtmlEncode(tName), unreadBadge,
                                    Server.HtmlEncode(qual), Server.HtmlEncode(lastMsg), timeStr);
                            }
                            if (has) { pnlChatList.Controls.Add(new LiteralControl(sb.ToString())); pnlNoChatList.Visible = false; }
                            else { pnlNoChatList.Visible = true; }
                        }
                    }
                }
            }
            catch { pnlNoChatList.Visible = true; }
        }

        protected void BtnSelectChat_Click(object sender, EventArgs e) { LoadPage(); }

        private void LoadSelectedChat()
        {
            string chatId = SelectedChatId;
            if (string.IsNullOrEmpty(chatId)) { pnlNoChat.Visible = true; pnlChatHeader.Visible = false; pnlComposer.Visible = false; return; }

            // Validate chat belongs to parent
            bool valid = false;
            try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.userChat WHERE chatId=@id AND (userId=@uid OR user2Id=@uid)", c)) { cmd.Parameters.AddWithValue("@id", chatId); cmd.Parameters.AddWithValue("@uid", _userId); c.Open(); valid = (int)cmd.ExecuteScalar() > 0; } } catch { }
            if (!valid) { pnlNoChat.Visible = true; pnlChatHeader.Visible = false; pnlComposer.Visible = false; return; }

            pnlNoChat.Visible = false; pnlChatHeader.Visible = true; pnlComposer.Visible = true;

            // Mark messages as read
            try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("UPDATE dbo.privateMessage SET isRead=1, readAt=GETDATE() WHERE chatId=@id AND senderUserId<>@uid AND isRead=0", c)) { cmd.Parameters.AddWithValue("@id", chatId); cmd.Parameters.AddWithValue("@uid", _userId); c.Open(); cmd.ExecuteNonQuery(); } } catch { }

            // Load header
            try
            {
                using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand(@"SELECT t.name, t.academicQualification, t.status FROM dbo.userChat uc
                    INNER JOIN dbo.Teacher t ON t.userId = CASE WHEN uc.userId=@uid THEN uc.user2Id ELSE uc.userId END
                    WHERE uc.chatId=@id", c))
                { cmd.Parameters.AddWithValue("@id", chatId); cmd.Parameters.AddWithValue("@uid", _userId); c.Open(); using (var r = cmd.ExecuteReader()) { if (r.Read()) { string tName = r["name"].ToString(); litChatInitial.Text = tName[0].ToString().ToUpper(); litChatTeacherName.Text = Server.HtmlEncode(tName); string qual = r["academicQualification"] != DBNull.Value ? r["academicQualification"].ToString() : ""; string certBadge = r["status"] != DBNull.Value && r["status"].ToString() == "Certified" ? " <span class='pt-certified-badge'>" + T("Certified","Disahkan") + "</span>" : ""; litChatQualification.Text = Server.HtmlEncode(qual) + certBadge; } } }
            }
            catch { }

            // Load messages
            pnlChatBody.Controls.Clear();
            try
            {
                using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT privateMsgId, senderUserId, msgText, attachmentFile, sentAt FROM dbo.privateMessage WHERE chatId=@id ORDER BY sentAt ASC", c))
                {
                    cmd.Parameters.AddWithValue("@id", chatId); c.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        StringBuilder sb = new StringBuilder(); string lastDate = "";
                        while (r.Read())
                        {
                            DateTime sentAt = Convert.ToDateTime(r["sentAt"]);
                            string dateKey = sentAt.ToString("yyyy-MM-dd");
                            if (dateKey != lastDate) { lastDate = dateKey; string dateLabel = sentAt.Date == DateTime.Today ? T("Today","Hari Ini") : sentAt.Date == DateTime.Today.AddDays(-1) ? T("Yesterday","Semalam") : sentAt.ToString("dd MMM yyyy"); sb.AppendFormat("<div class='pt-chat-date-separator'><span>{0}</span></div>", dateLabel); }

                            bool isParent = r["senderUserId"].ToString() == _userId;
                            string bubbleClass = isParent ? "pt-message-bubble pt-message-bubble-parent" : "pt-message-bubble pt-message-bubble-teacher";
                            string rowClass = isParent ? "pt-message-row pt-message-row-parent" : "pt-message-row pt-message-row-teacher";
                            string msgText = r["msgText"] != DBNull.Value ? r["msgText"].ToString() : "";
                            string attachment = r["attachmentFile"] != DBNull.Value ? r["attachmentFile"].ToString() : "";
                            string timeStr = sentAt.ToString("h:mm tt");

                            sb.AppendFormat("<div class='{0}'><div class='{1}'>", rowClass, bubbleClass);
                            if (msgText != "[Attachment]" && !string.IsNullOrEmpty(msgText)) sb.Append("<div>" + Server.HtmlEncode(msgText) + "</div>");
                            if (!string.IsNullOrEmpty(attachment)) sb.Append(RenderAttachment(attachment));
                            sb.AppendFormat("<div class='pt-message-time'>{0}</div>", timeStr);
                            sb.Append("</div></div>");
                        }
                        if (sb.Length > 0) pnlChatBody.Controls.Add(new LiteralControl(sb.ToString()));
                        else pnlChatBody.Controls.Add(new LiteralControl("<div class='pt-empty-state' style='padding:50px;'><i class='bi bi-chat'></i><p>" + T("No messages yet.","Tiada mesej lagi.") + "</p><div class='pt-empty-helper'>" + T("Send the first message to start the conversation.","Hantar mesej pertama untuk memulakan perbualan.") + "</div></div>"));
                    }
                }
            }
            catch { }

            // Scroll chat body to bottom after messages load
            ScriptManager.RegisterStartupScript(this, GetType(), "ScrollChatBottom", "setTimeout(function(){ var cb=document.querySelector('.pt-chat-body'); if(cb){cb.scrollTop=cb.scrollHeight;} },120);", true);
        }

        private string RenderAttachment(string filename)
        {
            string url = ResolveUrl("~/Uploads/ChatAttachments/" + filename);
            string ext = Path.GetExtension(filename).ToLower();
            if (AllowedImageExt.Contains(ext))
                return string.Format("<div class='pt-attachment-card'><img src='{0}' alt='attachment' style='max-width:220px;border-radius:14px;' onclick=\"window.open('{0}','_blank')\" /></div>", url);
            else
                return string.Format("<div class='pt-attachment-card'><i class='bi bi-file-earmark-text'></i> <a href='{0}' target='_blank'>{1}</a><a href='{0}' download class='pt-attachment-dl'><i class='bi bi-download'></i> {2}</a></div>", url, Server.HtmlEncode(Path.GetFileName(filename)), T("Download","Muat Turun"));
        }

        // ══════════════════════════════════════════════════════════════
        //  SEND MESSAGE
        // ══════════════════════════════════════════════════════════════
        protected void BtnSend_Click(object sender, EventArgs e)
        {
            string chatId = SelectedChatId;
            if (string.IsNullOrEmpty(chatId)) return;
            string msgText = txtMessage.Text.Trim();
            bool hasFile = fuAttachment.HasFile;
            if (string.IsNullOrEmpty(msgText) && !hasFile) { ShowMsg(T("Please enter a message or attach a file.","Sila masukkan mesej atau lampirkan fail."), false); return; }

            // Validate file
            string savedFilename = null;
            if (hasFile)
            {
                string ext = Path.GetExtension(fuAttachment.FileName).ToLower();
                if (!AllowedImageExt.Contains(ext) && !AllowedDocExt.Contains(ext)) { ShowMsg(T("This file type is not allowed.","Jenis fail ini tidak dibenarkan."), false); return; }
                if (fuAttachment.PostedFile.ContentLength > MaxFileSize) { ShowMsg(T("File size must not exceed 5 MB.","Saiz fail tidak boleh melebihi 5 MB."), false); return; }
            }

            if (string.IsNullOrEmpty(msgText)) msgText = "[Attachment]";

            try
            {
                using (var c = new SqlConnection(ConnStr)) { c.Open(); using (var txn = c.BeginTransaction()) { try {
                    string pmId = GenId(c, txn, "privateMessage", "privateMsgId", "PM");

                    // Save file if attached
                    if (hasFile)
                    {
                        string sanitized = SanitizeFilename(fuAttachment.FileName);
                        savedFilename = pmId + "_" + sanitized;
                        string folder = Server.MapPath("~/Uploads/ChatAttachments/");
                        if (!Directory.Exists(folder)) Directory.CreateDirectory(folder);
                        fuAttachment.SaveAs(Path.Combine(folder, savedFilename));
                    }

                    using (var cmd = new SqlCommand("INSERT INTO dbo.privateMessage(privateMsgId,chatId,senderUserId,msgText,attachmentFile,sentAt,isRead,readAt) VALUES(@id,@cid,@uid,@msg,@att,@now,0,NULL)", c, txn))
                    {
                        cmd.Parameters.AddWithValue("@id", pmId);
                        cmd.Parameters.AddWithValue("@cid", chatId);
                        cmd.Parameters.AddWithValue("@uid", _userId);
                        cmd.Parameters.AddWithValue("@msg", msgText);
                        cmd.Parameters.AddWithValue("@att", savedFilename != null ? (object)savedFilename : DBNull.Value);
                        cmd.Parameters.AddWithValue("@now", DateTime.Now);
                        cmd.ExecuteNonQuery();
                    }
                    txn.Commit(); txtMessage.Text = "";
                } catch { txn.Rollback(); throw; } } }
            }
            catch { ShowMsg(T("Unable to send message. Please try again.","Tidak dapat menghantar mesej. Sila cuba lagi."), false); }
            LoadPage();
        }

        private string SanitizeFilename(string filename)
        {
            string name = Path.GetFileNameWithoutExtension(filename);
            string ext = Path.GetExtension(filename);
            name = System.Text.RegularExpressions.Regex.Replace(name, @"[^a-zA-Z0-9_\-]", "_");
            if (name.Length > 50) name = name.Substring(0, 50);
            return name + ext;
        }

        // ══════════════════════════════════════════════════════════════
        //  TEACHERS TAB
        // ══════════════════════════════════════════════════════════════
        private void LoadTeacherGrid()
        {
            pnlTeacherGrid.Controls.Clear();
            try
            {
                using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand(@"SELECT t.teacherId, t.userId, t.name, t.academicQualification, LEFT(t.bio,100) AS bioPreview, t.status
                    FROM dbo.Teacher t INNER JOIN dbo.[User] u ON t.userId=u.userId WHERE t.status='Certified' ORDER BY t.name", c))
                {
                    c.Open(); using (var r = cmd.ExecuteReader())
                    {
                        StringBuilder sb = new StringBuilder(); bool has = false;
                        while (r.Read())
                        {
                            has = true;
                            string tName = r["name"].ToString();
                            string initial = tName[0].ToString().ToUpper();
                            string qual = r["academicQualification"] != DBNull.Value ? r["academicQualification"].ToString() : "";
                            string bio = r["bioPreview"] != DBNull.Value ? r["bioPreview"].ToString() : "";
                            string tUserId = r["userId"].ToString();

                            sb.AppendFormat(@"<div class='pt-teacher-card'>
                                <div class='pt-chat-avatar' style='width:52px;height:52px;font-size:1.1rem;margin:0 auto 12px;'>{0}</div>
                                <div class='pt-teacher-card-name'>{1}</div>
                                <div class='pt-teacher-card-qual'>{2}</div>
                                <div class='pt-teacher-card-bio'>{3}</div>
                                <span class='pt-certified-badge'><i class='bi bi-patch-check-fill'></i> {4}</span><br/>
                                <button type='button' class='pt-teacher-start-btn' style='margin-top:12px;' onclick=""document.getElementById('{5}').value='{6}';document.getElementById('{7}').click();""><i class='bi bi-chat-dots'></i> {8}</button>
                            </div>", initial, Server.HtmlEncode(tName), Server.HtmlEncode(qual),
                                Server.HtmlEncode(bio.Length > 80 ? bio.Substring(0, 80) + "..." : bio),
                                T("Certified","Disahkan"), hidStartChatTeacher.ClientID, tUserId, btnStartChat.ClientID, T("Start Chat","Mula Sembang"));
                        }
                        if (has) { pnlTeacherGrid.Controls.Add(new LiteralControl(sb.ToString())); pnlNoTeachers.Visible = false; }
                        else { pnlNoTeachers.Visible = true; }
                    }
                }
            }
            catch { pnlNoTeachers.Visible = true; }
        }

        protected void BtnStartChat_Click(object sender, EventArgs e)
        {
            string teacherUserId = hidStartChatTeacher.Value;
            if (string.IsNullOrEmpty(teacherUserId)) return;

            try
            {
                using (var c = new SqlConnection(ConnStr))
                {
                    c.Open();
                    // Check if chat exists
                    string existingChatId = null;
                    using (var cmd = new SqlCommand("SELECT chatId FROM dbo.userChat WHERE (userId=@uid AND user2Id=@tid) OR (userId=@tid AND user2Id=@uid)", c))
                    { cmd.Parameters.AddWithValue("@uid", _userId); cmd.Parameters.AddWithValue("@tid", teacherUserId); var r = cmd.ExecuteScalar(); if (r != null && r != DBNull.Value) existingChatId = r.ToString(); }

                    if (!string.IsNullOrEmpty(existingChatId)) { SelectedChatId = existingChatId; ActiveTab = "Chats"; LoadPage(); return; }

                    // Create new chat
                    using (var txn = c.BeginTransaction()) { try {
                        string chatId = GenId(c, txn, "userChat", "chatId", "C");
                        using (var cmd = new SqlCommand("INSERT INTO dbo.userChat(chatId,userId,user2Id,createdAt) VALUES(@id,@uid,@tid,@now)", c, txn))
                        { cmd.Parameters.AddWithValue("@id", chatId); cmd.Parameters.AddWithValue("@uid", _userId); cmd.Parameters.AddWithValue("@tid", teacherUserId); cmd.Parameters.AddWithValue("@now", DateTime.Now); cmd.ExecuteNonQuery(); }
                        txn.Commit();
                        SelectedChatId = chatId; ActiveTab = "Chats";
                    } catch { txn.Rollback(); } }
                }
            }
            catch { }
            LoadPage();
        }

        // ══════════════════════════════════════════════════════════════
        //  HELPERS
        // ══════════════════════════════════════════════════════════════
        private string GenId(SqlConnection c, SqlTransaction t, string table, string col, string prefix) { int n = 1; using (var cmd = new SqlCommand(string.Format("SELECT MAX({0}) FROM dbo.[{1}]", col, table), c, t)) { var r = cmd.ExecuteScalar(); if (r != null && r != DBNull.Value) { string last = r.ToString(); if (last.Length > prefix.Length) { int num; if (int.TryParse(last.Substring(prefix.Length), out num)) n = num + 1; } } } return prefix + n.ToString("D3"); }
        private string GetTimeAgo(DateTime dt) { var d = DateTime.Now - dt; if (d.TotalSeconds < 0) return dt.ToString("dd MMM"); if (d.TotalMinutes < 60) return (int)d.TotalMinutes + " min"; if (d.TotalHours < 24) return (int)d.TotalHours + "h"; if (d.TotalDays < 2) return T("Yesterday","Semalam"); if (d.TotalDays < 7) return (int)d.TotalDays + "d"; return dt.ToString("dd MMM"); }
        private void ShowMsg(string msg, bool ok) { pnlMsg.Visible = true; divMsg.InnerHtml = msg; iMsgIcon.Attributes["class"] = ok ? "bi bi-check-circle-fill" : "bi bi-exclamation-circle-fill"; }
    }
}
