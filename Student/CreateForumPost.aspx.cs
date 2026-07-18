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
    public partial class CreateForumPost1 : Page
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

        // ── Mode: "Public" or "Private" from URL param ────────────────
        private string PageMode
        {
            get
            {
                string mode = Request.QueryString["type"];
                if (!string.IsNullOrEmpty(mode) && mode.Equals("Private", StringComparison.OrdinalIgnoreCase))
                {
                    return "Private";
                }
                return "Public";
            }
        }

        // ── Edit mode: forumId from URL param ─────────────────────────
        private string EditForumId
        {
            get { return Request.QueryString["forumId"]; }
        }

        private bool IsEditMode
        {
            get { return !string.IsNullOrEmpty(EditForumId); }
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

            ScienceBuddy.SiteMaster master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            InitLang();

            if (!IsPostBack)
            {
                SetLabels();
                BuildForm();

                if (IsEditMode)
                {
                    LoadPostForEdit();
                }
            }
        }

        // ── Language initialization ───────────────────────────────────
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

        // ── Set bilingual labels ──────────────────────────────────────
        private void SetLabels()
        {
            bool isPrivate = (PageMode == "Private");

            if (isPrivate)
            {
                litPageTitle.Text = T("Create Student-Parent Discussion", "Cipta Perbincangan Murid-Ibu Bapa");
                litTitle.Text = T("Create Student-Parent Discussion", "Cipta Perbincangan Murid-Ibu Bapa");
                litSubtitle.Text = T("Start a private discussion with your linked parent.",
                                     "Mulakan perbincangan peribadi dengan ibu bapa anda yang dipautkan.");

                // Header style
                divHeader.Attributes["class"] = "st-createpost-header private-mode";
                divHeaderIcon.InnerHtml = "<i class=\"bi bi-people-fill\"></i>";

                // Show private info banner
                pnlPrivateInfo.Visible = true;
                litPrivateInfoTitle.Text = T("Private Discussion", "Perbincangan Peribadi");
                litPrivateInfoDesc.Text = T("This discussion can only be viewed by you and your linked parent.",
                                            "Perbincangan ini hanya boleh dilihat oleh anda dan ibu bapa yang dipautkan.");

                // Type is locked for Private
                pnlTypeDropdown.Visible = false;
                pnlTypeLocked.Visible = true;
                litTypeLockedLbl.Text = T("Discussion Type", "Jenis Perbincangan");
                litTypeLockedVal.Text = T("Private (Student-Parent)", "Peribadi (Murid-Ibu Bapa)");

                // Submit button style
                btnSubmit.CssClass = "st-createpost-btn-submit private-btn";
                litSubmitBtn.Text = T("Create Private Discussion", "Cipta Perbincangan Peribadi");

                // Check if student has linked parent
                CheckLinkedParent();
            }
            else
            {
                litPageTitle.Text = IsEditMode ? T("Edit Discussion", "Sunting Perbincangan") : T("Create Public Discussion", "Cipta Perbincangan Awam");
                litTitle.Text = IsEditMode ? T("Edit Discussion", "Sunting Perbincangan") : T("Create Public Discussion", "Cipta Perbincangan Awam");
                litSubtitle.Text = IsEditMode
                    ? T("Update your discussion title or message.", "Kemas kini tajuk atau mesej perbincangan anda.")
                    : T("Ask a question or start a Science discussion with the community.",
                         "Tanya soalan atau mulakan perbincangan Sains dengan komuniti.");

                divHeader.Attributes["class"] = "st-createpost-header public-mode";
                divHeaderIcon.InnerHtml = IsEditMode ? "<i class=\"bi bi-pencil-square\"></i>" : "<i class=\"bi bi-chat-dots-fill\"></i>";

                pnlTypeDropdown.Visible = true;
                pnlTypeLocked.Visible = false;
                litSubmitBtn.Text = IsEditMode ? T("Update Discussion", "Kemas Kini Perbincangan") : T("Create Discussion", "Cipta Perbincangan");
            }

            litTitleLbl.Text = T("Discussion Title", "Tajuk Perbincangan");
            litTypeLbl.Text = T("Discussion Type", "Jenis Perbincangan");
            litTypeHint.Text = T("Choose a category for your discussion.", "Pilih kategori untuk perbincangan anda.");
            litTagLbl.Text = T("Tag (Optional)", "Tag (Pilihan)");
            litMsgLbl.Text = T("Your Message", "Mesej Anda");
            litCancelBtn.Text = T("Cancel", "Batal");

            txtTitle.Attributes["placeholder"] = T("Enter your discussion title...", "Masukkan tajuk perbincangan anda...");
            txtMessage.Attributes["placeholder"] = T("Write your question or message...", "Tulis soalan atau mesej anda...");
        }

        // ── Check if student has a linked parent ──────────────────────
        private void CheckLinkedParent()
        {
            string userId = Session["userId"].ToString();

            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();

                if (!Tbl(connection, "Student") || !Tbl(connection, "StudentParent") || !Tbl(connection, "Parent"))
                {
                    ShowNoParentWarning();
                    return;
                }

                const string sql = @"
                    SELECT COUNT(*)
                    FROM   Student s
                    JOIN   StudentParent sp ON sp.studentId = s.studentId
                    JOIN   Parent p ON p.parentId = sp.parentId
                    WHERE  s.userId = @userId";

                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    command.Parameters.AddWithValue("@userId", userId);
                    int count = (int)command.ExecuteScalar();
                    if (count == 0)
                    {
                        ShowNoParentWarning();
                    }
                }
            }
        }

        private void ShowNoParentWarning()
        {
            pnlNoParent.Visible = true;
            litNoParent.Text = T(
                "No linked parent account was found. You can still create the discussion, but your parent may not see it until their account is linked.",
                "Tiada akaun ibu bapa yang dipautkan ditemui. Anda masih boleh mencipta perbincangan ini, tetapi ibu bapa anda mungkin tidak dapat melihatnya sehingga akaun mereka dipautkan.");
        }

        // ── Build form (load type dropdown and tags) ──────────────────
        private void BuildForm()
        {
            // Type dropdown (Public mode only)
            if (PageMode != "Private")
            {
                ddlType.Items.Clear();
                ddlType.Items.Add(new ListItem(T("Public", "Awam"), "Public"));
                ddlType.Items.Add(new ListItem(T("Family", "Keluarga"), "Private"));
            }

            // Tags checkboxes
            cblTags.Items.Clear();

            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();

                if (!Tbl(connection, "Tag"))
                {
                    return;
                }

                const string sql = "SELECT tagId, tagName FROM Tag ORDER BY tagName";
                using (SqlCommand command = new SqlCommand(sql, connection))
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string tagId = reader["tagId"].ToString();
                        string tagName = reader["tagName"].ToString();
                        cblTags.Items.Add(new ListItem(tagName, tagId));
                    }
                }
            }
        }

        // ── Load existing post for editing ───────────────────────────
        private void LoadPostForEdit()
        {
            string userId = Session["userId"].ToString();
            string forumId = EditForumId;

            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();

                const string sql = "SELECT title, message, discussionType, createdBy FROM Forum WHERE forumId = @fid";
                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    command.Parameters.AddWithValue("@fid", forumId);
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        if (!reader.Read())
                        {
                            // Post not found
                            Response.Redirect("~/Student/Forum.aspx", false);
                            return;
                        }

                        string createdBy = reader["createdBy"].ToString();
                        if (createdBy != userId)
                        {
                            // Not owner — redirect
                            Response.Redirect("~/Student/Forum.aspx", false);
                            return;
                        }

                        txtTitle.Text = reader["title"].ToString();
                        txtMessage.Text = reader["message"].ToString();

                        string discType = reader["discussionType"] != DBNull.Value ? reader["discussionType"].ToString() : "Public";
                        if (ddlType.Items.FindByValue(discType) != null)
                        {
                            ddlType.SelectedValue = discType;
                        }
                    }
                }

                // Load existing tags and pre-select them
                if (Tbl(connection, "ForumTag") && Tbl(connection, "Tag"))
                {
                    const string tagSql = "SELECT tagId FROM ForumTag WHERE forumId = @fid";
                    using (SqlCommand tagCmd = new SqlCommand(tagSql, connection))
                    {
                        tagCmd.Parameters.AddWithValue("@fid", forumId);
                        using (SqlDataReader tagReader = tagCmd.ExecuteReader())
                        {
                            while (tagReader.Read())
                            {
                                string existingTag = tagReader["tagId"].ToString();
                                ListItem item = cblTags.Items.FindByValue(existingTag);
                                if (item != null)
                                    item.Selected = true;
                            }
                        }
                    }
                }
            }
        }

        // ── Submit handler ────────────────────────────────────────────
        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            // Re-init language for postback
            InitLang();

            string title = txtTitle.Text.Trim();
            string message = txtMessage.Text.Trim();
            string userId = Session["userId"].ToString();

            // Determine discussion type
            string discussionType;
            if (PageMode == "Private")
            {
                discussionType = "Private";
            }
            else
            {
                discussionType = ddlType.SelectedValue;
                if (string.IsNullOrEmpty(discussionType))
                {
                    discussionType = "Public";
                }
            }

            List<string> selectedTagIds = new List<string>();
            foreach (ListItem item in cblTags.Items)
            {
                if (item.Selected)
                    selectedTagIds.Add(item.Value);
            }

            // Validation
            if (string.IsNullOrEmpty(title))
            {
                ShowError(T("Please enter a discussion title.", "Sila masukkan tajuk perbincangan."));
                return;
            }
            if (string.IsNullOrEmpty(message))
            {
                ShowError(T("Please write your question or message.", "Sila tulis soalan atau mesej anda."));
                return;
            }

            // ── EDIT MODE ──
            if (IsEditMode)
            {
                UpdatePost(title, message, discussionType, selectedTagIds);
                return;
            }

            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();

                // Use a transaction for data integrity
                using (SqlTransaction transaction = connection.BeginTransaction())
                {
                    try
                    {
                        // Generate sequential forumId
                        string forumId = "F001";
                        const string seqForumSql = @"
                            SELECT ISNULL(MAX(CAST(SUBSTRING(forumId, 2, LEN(forumId) - 1) AS INT)), 0)
                            FROM Forum WHERE forumId LIKE 'F[0-9]%'";
                        using (SqlCommand seqCmd = new SqlCommand(seqForumSql, connection, transaction))
                        {
                            object lastVal = seqCmd.ExecuteScalar();
                            if (lastVal != null && lastVal != DBNull.Value)
                            {
                                int lastNum = Convert.ToInt32(lastVal);
                                forumId = "F" + (lastNum + 1).ToString("D3");
                            }
                        }

                        DateTime now = DateTime.Now;

                        // Insert Forum post
                        const string sqlForum = @"
                            INSERT INTO Forum (forumId, createdBy, title, message, discussionType, createdAt)
                            VALUES (@fid, @uid, @title, @msg, @type, @now)";
                        using (SqlCommand command = new SqlCommand(sqlForum, connection, transaction))
                        {
                            command.Parameters.AddWithValue("@fid", forumId);
                            command.Parameters.AddWithValue("@uid", userId);
                            command.Parameters.AddWithValue("@title", title);
                            command.Parameters.AddWithValue("@msg", message);
                            command.Parameters.AddWithValue("@type", discussionType);
                            command.Parameters.AddWithValue("@now", now);
                            command.ExecuteNonQuery();
                        }

                        // Insert first ForumChat entry (same message as the post)
                        string forumChatId = "FC001";
                        const string seqChatSql = @"
                            SELECT ISNULL(MAX(CAST(SUBSTRING(forumChatId, 3, LEN(forumChatId) - 2) AS INT)), 0)
                            FROM ForumChat WHERE forumChatId LIKE 'FC[0-9]%'";
                        using (SqlCommand seqCmd = new SqlCommand(seqChatSql, connection, transaction))
                        {
                            object lastVal = seqCmd.ExecuteScalar();
                            if (lastVal != null && lastVal != DBNull.Value)
                            {
                                int lastNum = Convert.ToInt32(lastVal);
                                forumChatId = "FC" + (lastNum + 1).ToString("D3");
                            }
                        }

                        const string sqlChat = @"
                            INSERT INTO ForumChat (forumChatId, forumId, senderUserId, message, createdAt)
                            VALUES (@fcid, @fid, @uid, @msg, @now)";
                        using (SqlCommand command = new SqlCommand(sqlChat, connection, transaction))
                        {
                            command.Parameters.AddWithValue("@fcid", forumChatId);
                            command.Parameters.AddWithValue("@fid", forumId);
                            command.Parameters.AddWithValue("@uid", userId);
                            command.Parameters.AddWithValue("@msg", message);
                            command.Parameters.AddWithValue("@now", now);
                            command.ExecuteNonQuery();
                        }

                        // Insert ForumTag for each selected tag
                        foreach (string selectedTag in selectedTagIds)
                        {
                            string forumTagId = "FTAG001";
                            const string seqTagSql = @"
                                SELECT ISNULL(MAX(CAST(SUBSTRING(forumTagId, 5, LEN(forumTagId) - 4) AS INT)), 0)
                                FROM ForumTag WHERE forumTagId LIKE 'FTAG[0-9]%'";
                            using (SqlCommand seqCmd = new SqlCommand(seqTagSql, connection, transaction))
                            {
                                object lastVal = seqCmd.ExecuteScalar();
                                if (lastVal != null && lastVal != DBNull.Value)
                                {
                                    int lastNum = Convert.ToInt32(lastVal);
                                    forumTagId = "FTAG" + (lastNum + 1).ToString("D3");
                                }
                            }

                            const string sqlTag = @"
                                INSERT INTO ForumTag (forumTagId, forumId, tagId)
                                VALUES (@ftid, @fid, @tagId)";
                            using (SqlCommand command = new SqlCommand(sqlTag, connection, transaction))
                            {
                                command.Parameters.AddWithValue("@ftid", forumTagId);
                                command.Parameters.AddWithValue("@fid", forumId);
                                command.Parameters.AddWithValue("@tagId", selectedTag);
                                command.ExecuteNonQuery();
                            }
                        }

                        transaction.Commit();

                        // Award XP for forum post (XP007)
                        AwardForumXp(connection, userId);

                        // Check B009 Forum Helper badge
                        CheckForumBadge(connection, userId);

                        // Check B009 Forum Helper badge
                        CheckForumBadge(connection, userId);

                        // Redirect to thread page
                        Response.Redirect("~/Student/ForumThread.aspx?forumId=" + forumId, false);
                    }
                    catch (Exception ex)
                    {
                        transaction.Rollback();
                        System.Diagnostics.Debug.WriteLine("Error: " + ex.Message);
                        ShowError(T("An error occurred while creating the discussion. Please try again.",
                                    "Ralat berlaku semasa mencipta perbincangan. Sila cuba lagi."));
                    }
                }
            }
        }

        // ── Update existing post ──────────────────────────────────────
        private void UpdatePost(string title, string message, string discussionType, List<string> selectedTagIds)
        {
            string userId = Session["userId"].ToString();
            string forumId = EditForumId;

            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();

                // Verify ownership again before updating
                const string ownerSql = "SELECT createdBy FROM Forum WHERE forumId = @fid";
                using (SqlCommand ownerCmd = new SqlCommand(ownerSql, connection))
                {
                    ownerCmd.Parameters.AddWithValue("@fid", forumId);
                    object result = ownerCmd.ExecuteScalar();
                    if (result == null || result == DBNull.Value || result.ToString() != userId)
                    {
                        Response.Redirect("~/Student/Forum.aspx", false);
                        return;
                    }
                }

                // Update the forum post
                const string updateSql = @"
                    UPDATE Forum SET title = @title, message = @msg, discussionType = @type
                    WHERE forumId = @fid AND createdBy = @uid";
                using (SqlCommand command = new SqlCommand(updateSql, connection))
                {
                    command.Parameters.AddWithValue("@title", title);
                    command.Parameters.AddWithValue("@msg", message);
                    command.Parameters.AddWithValue("@type", discussionType);
                    command.Parameters.AddWithValue("@fid", forumId);
                    command.Parameters.AddWithValue("@uid", userId);
                    command.ExecuteNonQuery();
                }

                // Update tags: remove old, add new
                if (Tbl(connection, "ForumTag"))
                {
                    using (SqlCommand delCmd = new SqlCommand("DELETE FROM ForumTag WHERE forumId = @fid", connection))
                    {
                        delCmd.Parameters.AddWithValue("@fid", forumId);
                        delCmd.ExecuteNonQuery();
                    }

                    foreach (string tagId in selectedTagIds)
                    {
                        string forumTagId = "FTAG001";
                        const string seqTagSql = @"
                            SELECT ISNULL(MAX(CAST(SUBSTRING(forumTagId, 5, LEN(forumTagId) - 4) AS INT)), 0)
                            FROM ForumTag WHERE forumTagId LIKE 'FTAG[0-9]%'";
                        using (SqlCommand seqCmd = new SqlCommand(seqTagSql, connection))
                        {
                            object lastVal = seqCmd.ExecuteScalar();
                            if (lastVal != null && lastVal != DBNull.Value)
                            {
                                int lastNum = Convert.ToInt32(lastVal);
                                forumTagId = "FTAG" + (lastNum + 1).ToString("D3");
                            }
                        }

                        const string sqlTag = @"
                            INSERT INTO ForumTag (forumTagId, forumId, tagId)
                            VALUES (@ftid, @fid, @tagId)";
                        using (SqlCommand command = new SqlCommand(sqlTag, connection))
                        {
                            command.Parameters.AddWithValue("@ftid", forumTagId);
                            command.Parameters.AddWithValue("@fid", forumId);
                            command.Parameters.AddWithValue("@tagId", tagId);
                            command.ExecuteNonQuery();
                        }
                    }
                }

                Response.Redirect("~/Student/ForumThread.aspx?forumId=" + forumId, false);
            }
        }

        // Check B009 Forum Helper badge
        private void CheckForumBadge(SqlConnection conn, string userId)
        {
            try
            {
                if (!Tbl(conn, "StudentBadge") || !Tbl(conn, "Student")) return;

                string studentId = null;
                using (SqlCommand cmd = new SqlCommand("SELECT studentId FROM Student WHERE userId=@uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    object r = cmd.ExecuteScalar();
                    if (r != null && r != DBNull.Value) studentId = r.ToString();
                }
                if (string.IsNullOrEmpty(studentId)) return;

                // Award B009 on first forum post/reply
                int forumActions = 0;
                using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM ForumChat WHERE senderUserId=@uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    forumActions = (int)cmd.ExecuteScalar();
                }
                if (forumActions == 1)
                {
                    AwardBadgeIfNotEarned(conn, studentId, "B009");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Badge error: " + ex.Message);
            }
        }

        private void AwardBadgeIfNotEarned(SqlConnection conn, string studentId, string badgeId)
        {
            using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM StudentBadge WHERE studentId=@s AND badgeId=@b", conn))
            {
                cmd.Parameters.AddWithValue("@s", studentId);
                cmd.Parameters.AddWithValue("@b", badgeId);
                if ((int)cmd.ExecuteScalar() > 0) return;
            }
            string sbId = "SB001";
            using (SqlCommand cmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING(studentBadgeId,3,LEN(studentBadgeId)-2) AS INT)),0) FROM StudentBadge WHERE studentBadgeId LIKE 'SB[0-9]%'", conn))
            {
                sbId = "SB" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3");
            }
            using (SqlCommand cmd = new SqlCommand("INSERT INTO StudentBadge(studentBadgeId,studentId,badgeId,earnedAt) VALUES(@id,@s,@b,@dt)", conn))
            {
                cmd.Parameters.AddWithValue("@id", sbId);
                cmd.Parameters.AddWithValue("@s", studentId);
                cmd.Parameters.AddWithValue("@b", badgeId);
                cmd.Parameters.AddWithValue("@dt", DateTime.Now);
                cmd.ExecuteNonQuery();
            }

            // Send badge earned notification
            try
            {
                string uId = "";
                using (SqlCommand uidCmd = new SqlCommand("SELECT userId FROM Student WHERE studentId=@s", conn))
                { uidCmd.Parameters.AddWithValue("@s", studentId); var r = uidCmd.ExecuteScalar(); if (r != null) uId = r.ToString(); }
                if (!string.IsNullOrEmpty(uId))
                {
                    string bName = "";
                    using (SqlCommand bCmd = new SqlCommand("SELECT badgeNameEN FROM Badge WHERE badgeId=@b", conn))
                    { bCmd.Parameters.AddWithValue("@b", badgeId); var r = bCmd.ExecuteScalar(); if (r != null) bName = r.ToString(); }
                    SendNotification(conn, uId, "New Badge Earned", "Lencana Baru Diperolehi", "You earned the " + bName + " badge!", "Anda memperoleh lencana " + bName + "!");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Badge notification error: " + ex.Message);
            }
        }

        // Award XP for forum activity (XP007)
        private void AwardForumXp(SqlConnection conn, string userId)
        {
            try
            {
                if (!Tbl(conn, "XPAction") || !Tbl(conn, "XPTransaction") || !Tbl(conn, "Student"))
                {
                    return;
                }

                // Get studentId
                string studentId = null;
                using (SqlCommand command = new SqlCommand("SELECT studentId FROM Student WHERE userId=@uid", conn))
                {
                    command.Parameters.AddWithValue("@uid", userId);
                    object result = command.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        studentId = result.ToString();
                    }
                }
                if (string.IsNullOrEmpty(studentId)) return;

                // Get XP value for XP007
                int xpAmount = 0;
                using (SqlCommand command = new SqlCommand("SELECT xpValue FROM XPAction WHERE xpActionId='XP007'", conn))
                {
                    object result = command.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        xpAmount = Convert.ToInt32(result);
                    }
                }
                if (xpAmount <= 0) return;

                // Generate next ID
                string xtId = "XPT001";
                using (SqlCommand command = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING(xpTransactionId,4,LEN(xpTransactionId)-3) AS INT)),0) FROM XPTransaction WHERE xpTransactionId LIKE 'XPT[0-9]%'", conn))
                {
                    xtId = "XPT" + (Convert.ToInt32(command.ExecuteScalar()) + 1).ToString("D3");
                }

                // Insert XP transaction
                using (SqlCommand command = new SqlCommand("INSERT INTO XPTransaction(xpTransactionId,studentId,xpActionId,xpAmount,dateEarned) VALUES(@id,@s,@a,@xp,@dt)", conn))
                {
                    command.Parameters.AddWithValue("@id", xtId);
                    command.Parameters.AddWithValue("@s", studentId);
                    command.Parameters.AddWithValue("@a", "XP007");
                    command.Parameters.AddWithValue("@xp", xpAmount);
                    command.Parameters.AddWithValue("@dt", DateTime.Today);
                    command.ExecuteNonQuery();
                }

                // Update student total
                using (SqlCommand command = new SqlCommand("UPDATE Student SET XP=ISNULL(XP,0)+@xp WHERE studentId=@s", conn))
                {
                    command.Parameters.AddWithValue("@xp", xpAmount);
                    command.Parameters.AddWithValue("@s", studentId);
                    command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Forum XP error: " + ex.Message);
            }
        }

        // ── Show error message ────────────────────────────────────────
        private void ShowError(string message)
        {
            pnlError.Visible = true;
            litError.Text = HttpUtility.HtmlEncode(message);
        }

        // ── Table existence check ─────────────────────────────────────
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


