using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Student
{
    public partial class CreateForumPost : Page
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

        // ── Mode: "Public" or "Private" from URL param ────────────────
        private string PageMode
        {
            get
            {
                string mode = Request.QueryString["type"];
                if (!string.IsNullOrEmpty(mode) && mode.Equals("Private", StringComparison.OrdinalIgnoreCase))
                    return "Private";
                return "Public";
            }
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

            var master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            InitLang();

            if (!IsPostBack)
            {
                SetLabels();
                BuildForm();
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
                divHeader.Attributes["class"] = "cfp-header private-mode";
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
                btnSubmit.CssClass = "cfp-btn-submit private-btn";
                litSubmitBtn.Text = T("Create Private Discussion", "Cipta Perbincangan Peribadi");

                // Check if student has linked parent
                CheckLinkedParent();
            }
            else
            {
                litPageTitle.Text = T("Create Public Discussion", "Cipta Perbincangan Awam");
                litTitle.Text = T("Create Public Discussion", "Cipta Perbincangan Awam");
                litSubtitle.Text = T("Ask a question or start a Science discussion with the community.",
                                     "Tanya soalan atau mulakan perbincangan Sains dengan komuniti.");

                divHeader.Attributes["class"] = "cfp-header public-mode";
                divHeaderIcon.InnerHtml = "<i class=\"bi bi-chat-dots-fill\"></i>";

                pnlTypeDropdown.Visible = true;
                pnlTypeLocked.Visible = false;
                litSubmitBtn.Text = T("Create Discussion", "Cipta Perbincangan");
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

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                if (!Tbl(conn, "Student") || !Tbl(conn, "StudentParent") || !Tbl(conn, "Parent"))
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

                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    int count = (int)cmd.ExecuteScalar();
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
                ddlType.Items.Add(new ListItem(T("Question", "Soalan"), "Question"));
                ddlType.Items.Add(new ListItem(T("Sharing", "Perkongsian"), "Sharing"));
                ddlType.Items.Add(new ListItem(T("Help", "Bantuan"), "Help"));
            }

            // Tags dropdown
            ddlTag.Items.Clear();
            ddlTag.Items.Add(new ListItem(T("No tag", "Tiada tag"), ""));

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                if (!Tbl(conn, "Tag")) return;

                const string sql = "SELECT tagId, tagName FROM Tag ORDER BY tagName";
                using (var cmd = new SqlCommand(sql, conn))
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string tagId = reader["tagId"].ToString();
                        string tagName = reader["tagName"].ToString();
                        ddlTag.Items.Add(new ListItem(tagName, tagId));
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
                    discussionType = "Public";
            }

            string tagId = ddlTag.SelectedValue;

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

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Use a transaction for data integrity
                using (var transaction = conn.BeginTransaction())
                {
                    try
                    {
                        // Generate sequential forumId
                        string forumId = "F001";
                        const string seqForumSql = @"
                            SELECT ISNULL(MAX(CAST(SUBSTRING(forumId, 2, LEN(forumId) - 1) AS INT)), 0)
                            FROM Forum WHERE forumId LIKE 'F[0-9]%'";
                        using (var seqCmd = new SqlCommand(seqForumSql, conn, transaction))
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
                        using (var cmd = new SqlCommand(sqlForum, conn, transaction))
                        {
                            cmd.Parameters.AddWithValue("@fid", forumId);
                            cmd.Parameters.AddWithValue("@uid", userId);
                            cmd.Parameters.AddWithValue("@title", title);
                            cmd.Parameters.AddWithValue("@msg", message);
                            cmd.Parameters.AddWithValue("@type", discussionType);
                            cmd.Parameters.AddWithValue("@now", now);
                            cmd.ExecuteNonQuery();
                        }

                        // Insert first ForumChat entry (same message as the post)
                        string forumChatId = "FC001";
                        const string seqChatSql = @"
                            SELECT ISNULL(MAX(CAST(SUBSTRING(forumChatId, 3, LEN(forumChatId) - 2) AS INT)), 0)
                            FROM ForumChat WHERE forumChatId LIKE 'FC[0-9]%'";
                        using (var seqCmd = new SqlCommand(seqChatSql, conn, transaction))
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
                        using (var cmd = new SqlCommand(sqlChat, conn, transaction))
                        {
                            cmd.Parameters.AddWithValue("@fcid", forumChatId);
                            cmd.Parameters.AddWithValue("@fid", forumId);
                            cmd.Parameters.AddWithValue("@uid", userId);
                            cmd.Parameters.AddWithValue("@msg", message);
                            cmd.Parameters.AddWithValue("@now", now);
                            cmd.ExecuteNonQuery();
                        }

                        // Insert ForumTag if a tag was selected
                        if (!string.IsNullOrEmpty(tagId))
                        {
                            string forumTagId = "FT001";
                            const string seqTagSql = @"
                                SELECT ISNULL(MAX(CAST(SUBSTRING(forumTagId, 3, LEN(forumTagId) - 2) AS INT)), 0)
                                FROM ForumTag WHERE forumTagId LIKE 'FT[0-9]%'";
                            using (var seqCmd = new SqlCommand(seqTagSql, conn, transaction))
                            {
                                object lastVal = seqCmd.ExecuteScalar();
                                if (lastVal != null && lastVal != DBNull.Value)
                                {
                                    int lastNum = Convert.ToInt32(lastVal);
                                    forumTagId = "FT" + (lastNum + 1).ToString("D3");
                                }
                            }

                            const string sqlTag = @"
                                INSERT INTO ForumTag (forumTagId, forumId, tagId)
                                VALUES (@ftid, @fid, @tagId)";
                            using (var cmd = new SqlCommand(sqlTag, conn, transaction))
                            {
                                cmd.Parameters.AddWithValue("@ftid", forumTagId);
                                cmd.Parameters.AddWithValue("@fid", forumId);
                                cmd.Parameters.AddWithValue("@tagId", tagId);
                                cmd.ExecuteNonQuery();
                            }
                        }

                        transaction.Commit();

                        // Redirect to thread page
                        Response.Redirect("~/Student/ForumThread.aspx?forumId=" + forumId, false);
                    }
                    catch (Exception ex)
                    {
                        transaction.Rollback();
                        ShowError(T("An error occurred while creating the discussion. Please try again.",
                                    "Ralat berlaku semasa mencipta perbincangan. Sila cuba lagi."));
                    }
                }
            }
        }

        // ── Show error message ────────────────────────────────────────
        private void ShowError(string message)
        {
            pnlError.Visible = true;
            litError.Text = HttpUtility.HtmlEncode(message);
        }

        // ── Table existence check ─────────────────────────────────────
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
