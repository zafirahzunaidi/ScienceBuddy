using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Teacher
{
    public partial class Forum : Page
    {
        #region Properties

        protected string CurrentLanguage
        {
            get
            {
                string lang = Session["preferredLanguage"] as string;
                return string.IsNullOrEmpty(lang) ? "EN" : lang;
            }
        }

        private string ConnectionString =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        private bool IsSearchActive
        {
            get { return ViewState["IsSearch"] as bool? ?? false; }
            set { ViewState["IsSearch"] = value; }
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

            ((SiteMaster)Master).LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                InitializeControls();
                hidLicenseStatus.Value = GetTeacherLicenseStatus();
                LoadPosts(searchTerm: "");
            }
        }

        private void InitializeControls()
        {
            txtSearch.Attributes["placeholder"] = T("Search forum...", "Cari forum...");
            btnSearch.Text = T("Search", "Cari");
            btnPost.Text = T("Post Discussion", "Hantar Perbincangan");
            btnReset.Text = T("↻ Reset search", "↻ Set semula carian");
            IsSearchActive = false;
        }

        #endregion

        #region Event Handlers

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            IsSearchActive = true;
            LoadPosts(txtSearch.Text.Trim());
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            IsSearchActive = false;
            LoadPosts(searchTerm: "");
        }

        protected void btnPost_Click(object sender, EventArgs e)
        {
            string title = txtTitle.Text.Trim();
            string message = txtMessage.Text.Trim();

            if (string.IsNullOrEmpty(title) || string.IsNullOrEmpty(message))
            {
                pnlModalVal.Visible = true;
                litModalVal.Text = T("Title and Message are required.", "Tajuk dan Mesej diperlukan.");
                hidShowModal.Value = "1";
                LoadPosts(IsSearchActive ? txtSearch.Text.Trim() : "");
                return;
            }

            string teacherId = Session["userId"].ToString();
            CreateForumPost(teacherId, title, message);

            hidToast.Value = T("Forum post created successfully.", "Catatan forum berjaya dicipta.");
            txtTitle.Text = "";
            txtMessage.Text = "";
            pnlModalVal.Visible = false;
            txtSearch.Text = "";
            IsSearchActive = false;
            LoadPosts(searchTerm: "");
        }

        #endregion

        #region Data Loading

        private void LoadPosts(string searchTerm)
        {
            string search = (searchTerm ?? "").Trim();
            bool isSearching = !string.IsNullOrEmpty(search);

            var posts = FetchForumPosts(search);

            if (posts.Count > 0)
            {
                pnlList.Visible = true;
                pnlDbEmpty.Visible = false;
                pnlSearchEmpty.Visible = false;
                rptPosts.DataSource = posts;
                rptPosts.DataBind();
            }
            else if (isSearching)
            {
                pnlList.Visible = false;
                pnlDbEmpty.Visible = false;
                pnlSearchEmpty.Visible = true;
            }
            else
            {
                pnlList.Visible = false;
                pnlDbEmpty.Visible = true;
                pnlSearchEmpty.Visible = false;
            }
        }

        private List<object> FetchForumPosts(string searchTerm)
        {
            string sql = @"
                SELECT f.[forumId], f.[title], f.[message], f.[createdAt],
                    COALESCE(t.[name], s2.[name], p.[name], u.[username]) AS creatorName,
                    u.[role],
                    (SELECT COUNT(*) FROM dbo.[ForumChat] WHERE [forumId]=f.[forumId]) AS replyCount,
                    (SELECT COUNT(*) FROM dbo.[ForumLike] WHERE [forumId]=f.[forumId]) AS likeCount
                FROM dbo.[Forum] f
                INNER JOIN dbo.[User]    u  ON u.[userId]  = f.[createdBy]
                LEFT  JOIN dbo.[Teacher] t  ON t.[userId]  = u.[userId]
                LEFT  JOIN dbo.[Student] s2 ON s2.[userId] = u.[userId]
                LEFT  JOIN dbo.[Parent]  p  ON p.[userId]  = u.[userId]
                WHERE f.[discussionType] = 'Public'";

            bool hasSearch = !string.IsNullOrEmpty(searchTerm);
            if (hasSearch)
            {
                sql += @" AND (f.[title] LIKE @s
                           OR f.[message] LIKE @s
                           OR COALESCE(t.[name], s2.[name], p.[name], u.[username]) LIKE @s)";
            }

            sql += " ORDER BY f.[createdAt] DESC";

            var posts = new List<object>();

            using (var conn = new SqlConnection(ConnectionString))
            {
                conn.Open();
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@uid", Session["userId"].ToString());
                    if (hasSearch)
                        cmd.Parameters.AddWithValue("@s", "%" + searchTerm + "%");

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string creatorName = reader["creatorName"]?.ToString() ?? "User";
                            string role = reader["role"]?.ToString() ?? "";
                            string message = reader["message"]?.ToString() ?? "";
                            DateTime createdAt = reader["createdAt"] != DBNull.Value
                                ? Convert.ToDateTime(reader["createdAt"])
                                : DateTime.Now;

                            posts.Add(new
                            {
                                forumId = reader["forumId"].ToString(),
                                title = reader["title"]?.ToString() ?? "",
                                msgPreview = message.Length > 180 ? message.Substring(0, 180) + "…" : message,
                                creatorName,
                                initials = BuildInitials(creatorName),
                                roleCss = GetRoleCss(role),
                                roleLabel = GetRoleLabel(role),
                                timeAgo = FormatTimeAgo(createdAt),
                                replyCount = Convert.ToInt32(reader["replyCount"]),
                                likeCount = Convert.ToInt32(reader["likeCount"])
                            });
                        }
                    }
                }
            }

            return posts;
        }

        #endregion

        #region Database Operations

        private void CreateForumPost(string teacherId, string title, string message)
        {
            using (var conn = new SqlConnection(ConnectionString))
            {
                conn.Open();
                using (var txn = conn.BeginTransaction())
                {
                    // Generate next forum ID
                    string newForumId;
                    using (var cmd = new SqlCommand(
                        "SELECT ISNULL(MAX(CAST(SUBSTRING([forumId],2,LEN([forumId])-1) AS INT)),0) FROM dbo.[Forum]",
                        conn, txn))
                    {
                        int nextNumber = Convert.ToInt32(cmd.ExecuteScalar()) + 1;
                        newForumId = "F" + nextNumber.ToString("D3");
                    }

                    // Insert new post
                    const string insertSql = @"INSERT INTO dbo.[Forum]
                        ([forumId], [createdBy], [title], [message], [discussionType], [createdAt])
                        VALUES (@forumId, @teacherId, @title, @message, 'Public', GETDATE())";

                    using (var cmd = new SqlCommand(insertSql, conn, txn))
                    {
                        cmd.Parameters.AddWithValue("@forumId", newForumId);
                        cmd.Parameters.AddWithValue("@teacherId", teacherId);
                        cmd.Parameters.AddWithValue("@title", title);
                        cmd.Parameters.AddWithValue("@message", message);
                        cmd.ExecuteNonQuery();
                    }

                    txn.Commit();
                }
            }
        }

        private string GetTeacherLicenseStatus()
        {
            try
            {
                using (var conn = new SqlConnection(ConnectionString))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("SELECT [status] FROM dbo.[Teacher] WHERE [userId]=@u", conn))
                    {
                        cmd.Parameters.AddWithValue("@u", Session["userId"].ToString());
                        var result = cmd.ExecuteScalar();
                        return result != null && result != DBNull.Value ? result.ToString() : "";
                    }
                }
            }
            catch
            {
                return "";
            }
        }

        #endregion

        #region Helper Methods

        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        private static string BuildInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "U";

            string[] parts = name.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);

            if (parts.Length >= 2)
                return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();

            return name.Trim()[0].ToString().ToUpper();
        }

        private static string GetRoleCss(string role)
        {
            switch ((role ?? "").Trim().ToLower())
            {
                case "teacher": return "teacher";
                case "student": return "student";
                case "parent": return "parent";
                default: return "";
            }
        }

        private string GetRoleLabel(string role)
        {
            switch ((role ?? "").Trim().ToLower())
            {
                case "teacher": return T("Teacher", "Guru");
                case "student": return T("Student", "Pelajar");
                case "parent": return T("Parent", "Ibu Bapa");
                default: return role ?? "";
            }
        }

        private static string FormatTimeAgo(DateTime dateTime)
        {
            TimeSpan elapsed = DateTime.Now - dateTime;

            if (elapsed.TotalMinutes < 1) return "Just now";
            if (elapsed.TotalHours < 1) return (int)elapsed.TotalMinutes + " min ago";
            if (elapsed.TotalDays < 1) return (int)elapsed.TotalHours + " hr ago";
            if (elapsed.TotalDays < 7)
            {
                int days = (int)elapsed.TotalDays;
                return days + " day" + (days == 1 ? "" : "s") + " ago";
            }

            return dateTime.ToString("d MMM yyyy, h:mm tt");
        }

        #endregion
    }
}
