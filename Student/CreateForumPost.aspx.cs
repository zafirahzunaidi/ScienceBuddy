using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

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

            if (!IsPostBack)
            {
                InitLang();
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
            litPageTitle.Text  = T("Create Discussion", "Cipta Perbincangan");
            litTitle.Text      = T("Create Discussion", "Cipta Perbincangan");
            litSubtitle.Text   = T("Ask a question or start a Science discussion.", "Tanya soalan atau mulakan perbincangan Sains.");

            litTitleLbl.Text   = T("Discussion Title", "Tajuk Perbincangan");
            litTypeLbl.Text    = T("Discussion Type", "Jenis Perbincangan");
            litTagLbl.Text     = T("Tag (Optional)", "Tag (Pilihan)");
            litMsgLbl.Text     = T("Your Message", "Mesej Anda");

            txtTitle.Attributes["placeholder"]   = T("Enter your discussion title...", "Masukkan tajuk perbincangan anda...");
            txtMessage.Attributes["placeholder"] = T("Write your question or message...", "Tulis soalan atau mesej anda...");

            litSubmitBtn.Text  = T("Create Discussion", "Cipta Perbincangan");
            litCancelBtn.Text  = T("Cancel", "Batal");

            // Update dropdown text
            ddlType.Items.Clear();
            ddlType.Items.Add(new System.Web.UI.WebControls.ListItem(T("Public", "Awam"), "Public"));
        }

        // ── Build form (load tags) ───────────────────────────────────
        private void BuildForm()
        {
            ddlTag.Items.Clear();
            ddlTag.Items.Add(new System.Web.UI.WebControls.ListItem(T("No tag", "Tiada tag"), ""));

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
                        string tagId   = reader["tagId"].ToString();
                        string tagName = reader["tagName"].ToString();
                        ddlTag.Items.Add(new System.Web.UI.WebControls.ListItem(tagName, tagId));
                    }
                }
            }
        }

        // ── Submit handler ────────────────────────────────────────────
        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            // Re-init language for postback
            InitLang();

            string title   = txtTitle.Text.Trim();
            string message = txtMessage.Text.Trim();
            string type    = ddlType.SelectedValue;
            string tagId   = ddlTag.SelectedValue;
            string userId  = Session["userId"].ToString();

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

            // Generate IDs
            string timestamp = DateTime.Now.ToString("yyyyMMddHHmmss");
            string forumId     = ("F" + timestamp).Length > 10 ? ("F" + timestamp).Substring(0, 10) : "F" + timestamp;
            string forumChatId = ("FC" + timestamp).Length > 10 ? ("FC" + timestamp).Substring(0, 10) : "FC" + timestamp;
            DateTime now = DateTime.Now;

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Insert Forum post
                const string sqlForum = @"
                    INSERT INTO Forum (forumId, createdBy, title, message, discussionType, createdAt)
                    VALUES (@fid, @uid, @title, @msg, @type, @now)";
                using (var cmd = new SqlCommand(sqlForum, conn))
                {
                    cmd.Parameters.AddWithValue("@fid", forumId);
                    cmd.Parameters.AddWithValue("@uid", userId);
                    cmd.Parameters.AddWithValue("@title", title);
                    cmd.Parameters.AddWithValue("@msg", message);
                    cmd.Parameters.AddWithValue("@type", type);
                    cmd.Parameters.AddWithValue("@now", now);
                    cmd.ExecuteNonQuery();
                }

                // Insert first ForumChat entry (same message as the post)
                const string sqlChat = @"
                    INSERT INTO ForumChat (forumChatId, forumId, senderUserId, message, createdAt)
                    VALUES (@fcid, @fid, @uid, @msg, @now)";
                using (var cmd = new SqlCommand(sqlChat, conn))
                {
                    cmd.Parameters.AddWithValue("@fcid", forumChatId);
                    cmd.Parameters.AddWithValue("@fid", forumId);
                    cmd.Parameters.AddWithValue("@uid", userId);
                    cmd.Parameters.AddWithValue("@msg", message);
                    cmd.Parameters.AddWithValue("@now", now);
                    cmd.ExecuteNonQuery();
                }

                // Insert ForumTag if a tag was selected and ForumTag table exists
                if (!string.IsNullOrEmpty(tagId) && Tbl(conn, "ForumTag"))
                {
                    string forumTagId = ("FT" + timestamp).Length > 10 ? ("FT" + timestamp).Substring(0, 10) : "FT" + timestamp;
                    const string sqlTag = @"
                        INSERT INTO ForumTag (forumTagId, forumId, tagId)
                        VALUES (@ftid, @fid, @tagId)";
                    using (var cmd = new SqlCommand(sqlTag, conn))
                    {
                        cmd.Parameters.AddWithValue("@ftid", forumTagId);
                        cmd.Parameters.AddWithValue("@fid", forumId);
                        cmd.Parameters.AddWithValue("@tagId", tagId);
                        cmd.ExecuteNonQuery();
                    }
                }
            }

            // Redirect to thread page
            Response.Redirect("~/Student/ForumThread.aspx?forumId=" + forumId, false);
        }

        // ── Show error message ────────────────────────────────────────
        private void ShowError(string message)
        {
            pnlError.Visible = true;
            litError.Text = message;
        }

        // ── Table existence check ─────────────────────────────────────
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
