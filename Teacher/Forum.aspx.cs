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
        // -- Language --------------------------------------------------
        protected string CurrentLanguage
        {
            get { string l = Session["preferredLanguage"] as string; return string.IsNullOrEmpty(l) ? "EN" : l; }
        }
        protected string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }

        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        // -- State: track whether the current load is a search ---------
        private bool IsSearch
        {
            get { return ViewState["IsSearch"] as bool? ?? false; }
            set { ViewState["IsSearch"] = value; }
        }

        // ------------------------------------------------------------
        //  PAGE LOAD
        // ------------------------------------------------------------
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"]?.ToString() != "Teacher")
            { Response.Redirect("~/Login.aspx", false); Context.ApplicationInstance.CompleteRequest(); return; }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                // Localise dynamic controls
                txtSearch.Attributes["placeholder"] = T("Search forum...", "Cari forum...");
                btnSearch.Text = T("Search", "Cari");
                btnPost.Text   = T("Post Discussion", "Hantar Perbincangan");
                btnReset.Text  = T("? Reset search", "? Set semula carian");
                IsSearch       = false;

                // Check Teaching License status
                hidLicenseStatus.Value = GetTeacherLicenseStatus();

                LoadPosts(searchTerm: "");
            }
        }

        private string GetTeacherLicenseStatus()
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("SELECT [status] FROM dbo.[Teacher] WHERE [userId]=@u", conn))
                    {
                        cmd.Parameters.AddWithValue("@u", Session["userId"].ToString());
                        var val = cmd.ExecuteScalar();
                        return val != null && val != DBNull.Value ? val.ToString() : "";
                    }
                }
            }
            catch { return ""; }
        }

        // ------------------------------------------------------------
        //  LOAD POSTS
        // ------------------------------------------------------------
        private void LoadPosts(string searchTerm)
        {
            string userId = Session["userId"].ToString();
            string s = (searchTerm ?? "").Trim();

            // Search includes creator name as per spec
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

            if (!string.IsNullOrEmpty(s))
                sql += @" AND (f.[title]   LIKE @s
                           OR  f.[message] LIKE @s
                           OR  COALESCE(t.[name], s2.[name], p.[name], u.[username]) LIKE @s)";

            sql += " ORDER BY f.[createdAt] DESC";

            var list = new List<object>();
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    if (!string.IsNullOrEmpty(s))
                        cmd.Parameters.AddWithValue("@s", "%" + s + "%");

                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            string name  = r["creatorName"]?.ToString() ?? "User";
                            string role  = r["role"]?.ToString()        ?? "";
                            string msg   = r["message"]?.ToString()     ?? "";
                            DateTime dt  = r["createdAt"] != DBNull.Value
                                ? Convert.ToDateTime(r["createdAt"]) : DateTime.Now;

                            list.Add(new
                            {
                                forumId    = r["forumId"].ToString(),
                                title      = r["title"]?.ToString() ?? "",
                                msgPreview = msg.Length > 180 ? msg.Substring(0, 180) + "…" : msg,
                                creatorName = name,
                                initials   = BuildInitials(name),
                                roleCss    = RoleCss(role),
                                roleLabel  = RoleLabel(role),
                                timeAgo    = FormatTime(dt),
                                replyCount = Convert.ToInt32(r["replyCount"]),
                                likeCount  = Convert.ToInt32(r["likeCount"])
                            });
                        }
                    }
                }
            }

            // Decide which panel to show
            bool searching = !string.IsNullOrEmpty(s);

            if (list.Count > 0)
            {
                pnlList.Visible        = true;
                pnlDbEmpty.Visible     = false;
                pnlSearchEmpty.Visible = false;
                rptPosts.DataSource    = list;
                rptPosts.DataBind();
            }
            else if (searching)
            {
                pnlList.Visible        = false;
                pnlDbEmpty.Visible     = false;
                pnlSearchEmpty.Visible = true;
            }
            else
            {
                pnlList.Visible        = false;
                pnlDbEmpty.Visible     = true;
                pnlSearchEmpty.Visible = false;
            }
        }

        // ------------------------------------------------------------
        //  SEARCH
        // ------------------------------------------------------------
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            IsSearch = true;
            LoadPosts(txtSearch.Text.Trim());
        }

        // ------------------------------------------------------------
        //  RESET SEARCH
        // ------------------------------------------------------------
        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            IsSearch       = false;
            LoadPosts(searchTerm: "");
        }

        // ------------------------------------------------------------
        //  CREATE POST
        // ------------------------------------------------------------
        protected void btnPost_Click(object sender, EventArgs e)
        {
            string title = txtTitle.Text.Trim();
            string msg   = txtMessage.Text.Trim();

            if (string.IsNullOrEmpty(title) || string.IsNullOrEmpty(msg))
            {
                pnlModalVal.Visible = true;
                litModalVal.Text    = T("Title and Message are required.", "Tajuk dan Mesej diperlukan.");
                hidShowModal.Value  = "1";
                // Re-render list so page doesn't go blank
                LoadPosts(IsSearch ? txtSearch.Text.Trim() : "");
                return;
            }

            string userId = Session["userId"].ToString();
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var txn = conn.BeginTransaction())
                {
                    string newId;
                    using (var cmd = new SqlCommand(
                        "SELECT ISNULL(MAX(CAST(SUBSTRING([forumId],2,LEN([forumId])-1) AS INT)),0) FROM dbo.[Forum]",
                        conn, txn))
                    { newId = "F" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3"); }

                    using (var cmd = new SqlCommand(
                        "INSERT INTO dbo.[Forum]([forumId],[createdBy],[title],[message],[discussionType],[createdAt]) " +
                        "VALUES(@id,@uid,@t,@m,'Public',GETDATE())", conn, txn))
                    {
                        cmd.Parameters.AddWithValue("@id",  newId);
                        cmd.Parameters.AddWithValue("@uid", userId);
                        cmd.Parameters.AddWithValue("@t",   title);
                        cmd.Parameters.AddWithValue("@m",   msg);
                        cmd.ExecuteNonQuery();
                    }
                    txn.Commit();
                }
            }

            hidToast.Value      = T("Forum post created successfully.", "Catatan forum berjaya dicipta.");
            txtTitle.Text       = "";
            txtMessage.Text     = "";
            pnlModalVal.Visible = false;
            txtSearch.Text      = "";
            IsSearch            = false;
            LoadPosts(searchTerm: "");
        }

        // ------------------------------------------------------------
        //  HELPERS
        // ------------------------------------------------------------
        private static string BuildInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "U";
            string[] parts = name.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length >= 2)
                return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
            return name.Trim()[0].ToString().ToUpper();
        }

        private static string RoleCss(string role)
        {
            switch ((role ?? "").Trim().ToLower())
            {
                case "teacher": return "teacher";
                case "student": return "student";
                case "parent":  return "parent";
                default:        return "";
            }
        }

        private string RoleLabel(string role)
        {
            switch ((role ?? "").Trim().ToLower())
            {
                case "teacher": return T("Teacher", "Guru");
                case "student": return T("Student", "Pelajar");
                case "parent":  return T("Parent",  "Ibu Bapa");
                default:        return role ?? "";
            }
        }

        private static string FormatTime(DateTime dt)
        {
            TimeSpan span = DateTime.Now - dt;
            if (span.TotalMinutes < 1)  return "Just now";
            if (span.TotalHours   < 1)  return (int)span.TotalMinutes + " min ago";
            if (span.TotalDays    < 1)  return (int)span.TotalHours   + " hr ago";
            if (span.TotalDays    < 7)
                return (int)span.TotalDays + " day" + ((int)span.TotalDays == 1 ? "" : "s") + " ago";
            return dt.ToString("d MMM yyyy, h:mm tt");
        }
    }
}
