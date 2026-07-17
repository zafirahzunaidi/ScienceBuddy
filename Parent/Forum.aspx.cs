using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Parent
{
    public partial class Forum : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        protected string CurrentLanguage = "EN";
        protected string T(string en, string bm) => CurrentLanguage == "BM" ? bm : en;
        private string _parentUserId = "", _parentId = "";
        private List<string> _linkedChildUserIds = new List<string>();
        private string ActiveTab { get { return ViewState["Tab"] as string ?? "Public"; } set { ViewState["Tab"] = value; } }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!EnsureAuth()) return;
            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            LoadLang(); LoadUnreadBadge(); _parentUserId = Session["userId"].ToString(); LoadParent(); LoadLinkedChildUserIds();
            if (!IsPostBack) { LoadSidebarChildren(); PopulateFilters(); LoadPage(); }
            else { LoadPage(); }
        }

        private bool EnsureAuth()
        {
            if (Session["userId"] == null || Session["role"] == null || Session["role"].ToString() != "Parent")
            {
                Response.Redirect("~/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return false;
            }
            return true;
        }
        private void LoadLang()
        {
            string savedLang = Session["preferredLanguage"] as string;
            if (!string.IsNullOrEmpty(savedLang))
            {
                CurrentLanguage = savedLang;
                return;
            }

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT preferredLanguage FROM dbo.[User] WHERE userId = @userId", conn))
                {
                    cmd.Parameters.AddWithValue("@userId", Session["userId"].ToString());
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        CurrentLanguage = result.ToString();
                        Session["preferredLanguage"] = CurrentLanguage;
                    }
                }
            }
            catch { }
        }

        private void LoadParent()
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT parentId FROM dbo.[Parent] WHERE userId = @userId", conn))
                {
                    cmd.Parameters.AddWithValue("@userId", _parentUserId);
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                        _parentId = result.ToString();
                }
            }
            catch { }
        }
        private void LoadLinkedChildUserIds()
        {
            try
            {
                string sql = @"SELECT u.userId
                    FROM dbo.StudentParent sp
                    INNER JOIN dbo.Student s ON sp.studentId = s.studentId
                    INNER JOIN dbo.[User] u ON s.userId = u.userId
                    WHERE sp.parentId = @parentId";

                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@parentId", _parentId);
                    conn.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                            _linkedChildUserIds.Add(reader["userId"].ToString());
                    }
                }
            }
            catch { }
        }
        private void LoadSidebarChildren() { ddlSidebarChild.Items.Clear(); try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT s.studentId, ISNULL(s.nickname,s.name) AS n FROM dbo.StudentParent sp INNER JOIN dbo.Student s ON sp.studentId=s.studentId WHERE sp.parentId=@p ORDER BY s.name", c)) { cmd.Parameters.AddWithValue("@p", _parentId); c.Open(); using (var r = cmd.ExecuteReader()) { while (r.Read()) ddlSidebarChild.Items.Add(new ListItem(r["n"].ToString(), r["studentId"].ToString())); } } } catch { } if (ddlSidebarChild.Items.Count > 0) { string saved = Session["selectedChildId"] as string; if (!string.IsNullOrEmpty(saved) && ddlSidebarChild.Items.FindByValue(saved) != null) ddlSidebarChild.SelectedValue = saved; else Session["selectedChildId"] = ddlSidebarChild.Items[0].Value; } }
        protected void SidebarChildChanged(object sender, EventArgs e) { Session["selectedChildId"] = ddlSidebarChild.SelectedValue; }

        private void PopulateFilters()
        {
            ddlTag.Items.Clear(); ddlTag.Items.Add(new ListItem(T("All Tags", "Semua Tag"), ""));
            try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT tagId, tagName FROM dbo.Tag ORDER BY tagName", c)) { c.Open(); using (var r = cmd.ExecuteReader()) { while (r.Read()) ddlTag.Items.Add(new ListItem(r["tagName"].ToString(), r["tagId"].ToString())); } } } catch { }
            ddlSort.Items.Clear(); ddlSort.Items.Add(new ListItem(T("Latest", "Terkini"), "latest")); ddlSort.Items.Add(new ListItem(T("Oldest", "Terlama"), "oldest")); ddlSort.Items.Add(new ListItem(T("Most Liked", "Paling Disukai"), "likes")); ddlSort.Items.Add(new ListItem(T("Most Replies", "Paling Banyak Balasan"), "replies")); ddlSort.Items.Add(new ListItem(T("My Discussions", "Perbincangan Saya"), "mine"));
            // Child filter
            ddlChildFilter.Items.Clear(); ddlChildFilter.Items.Add(new ListItem(T("All Linked Children", "Semua Anak Dipautkan"), ""));
            try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT s.studentId, ISNULL(s.nickname,s.name) AS n, u.userId FROM dbo.StudentParent sp INNER JOIN dbo.Student s ON sp.studentId=s.studentId INNER JOIN dbo.[User] u ON s.userId=u.userId WHERE sp.parentId=@p ORDER BY s.name", c)) { cmd.Parameters.AddWithValue("@p", _parentId); c.Open(); using (var r = cmd.ExecuteReader()) { while (r.Read()) ddlChildFilter.Items.Add(new ListItem(r["n"].ToString(), r["userId"].ToString())); } } } catch { }
        }

        protected void TabPublic_Click(object sender, EventArgs e) { ActiveTab = "Public"; LoadPage(); }
        protected void TabPrivate_Click(object sender, EventArgs e) { ActiveTab = "Private"; LoadPage(); }
        protected void Filter_Changed(object sender, EventArgs e) { LoadPage(); }

        private void LoadPage()
        {
            lnkPublic.CssClass = ActiveTab == "Public" ? "pt-forum-tab pt-forum-tab-active" : "pt-forum-tab";
            lnkPrivate.CssClass = ActiveTab == "Private" ? "pt-forum-tab pt-forum-tab-active" : "pt-forum-tab";
            pnlChildFilter.Visible = ActiveTab == "Private";
            pnlPublicList.Visible = ActiveTab == "Public";
            pnlPrivateList.Visible = ActiveTab == "Private";
            pnlEmpty.Visible = false;

            if (ActiveTab == "Public") LoadPublicThreads();
            else LoadChildActivity();
        }

        private void LoadPublicThreads()
        {
            pnlPublicList.Controls.Clear();
            string tag = ddlTag.SelectedValue; string sort = ddlSort.SelectedValue; string search = txtSearch.Text.Trim();
            string orderBy = sort == "oldest" ? "f.createdAt ASC" : sort == "likes" ? "likeCount DESC" : sort == "replies" ? "replyCount DESC" : "f.createdAt DESC";
            string tagJoin = !string.IsNullOrEmpty(tag) ? " INNER JOIN dbo.ForumTag ft ON f.forumId=ft.forumId AND ft.tagId=@tag" : "";
            string searchWhere = !string.IsNullOrEmpty(search) ? " AND (f.title LIKE @search OR f.message LIKE @search)" : "";
            string mineWhere = sort == "mine" ? " AND f.createdBy=@uid" : "";

            string sql = string.Format(@"SELECT f.forumId, f.createdBy, f.title, LEFT(f.message,120) AS preview, f.createdAt, u.username,
                (SELECT COUNT(*) FROM dbo.ForumLike WHERE forumId=f.forumId) AS likeCount,
                (SELECT COUNT(*) FROM dbo.ForumChat WHERE forumId=f.forumId) AS replyCount
                FROM dbo.Forum f INNER JOIN dbo.[User] u ON f.createdBy=u.userId{0}
                WHERE f.discussionType='Public'{1}{2} ORDER BY {3}", tagJoin, searchWhere, mineWhere, sort == "mine" ? "f.createdAt DESC" : orderBy);

            try
            {
                using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand(sql, c))
                {
                    if (!string.IsNullOrEmpty(tag)) cmd.Parameters.AddWithValue("@tag", tag);
                    if (!string.IsNullOrEmpty(search)) cmd.Parameters.AddWithValue("@search", "%" + search + "%");
                    if (sort == "mine") cmd.Parameters.AddWithValue("@uid", _parentUserId);
                    c.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        StringBuilder sb = new StringBuilder();
                        bool hasData = false;
                        while (r.Read())
                        {
                            hasData = true;
                            sb.Append(RenderThreadCard(r["forumId"].ToString(), r["username"].ToString(), Convert.ToDateTime(r["createdAt"]), r["title"].ToString(), r["preview"].ToString(), Convert.ToInt32(r["likeCount"]), Convert.ToInt32(r["replyCount"])));
                        }
                        if (hasData) pnlPublicList.Controls.Add(new LiteralControl(sb.ToString()));
                        else { pnlEmpty.Visible = true; litEmpty.Text = T("No discussions found.", "Tiada perbincangan ditemui."); }
                    }
                }
            }
            catch { pnlEmpty.Visible = true; litEmpty.Text = T("Error loading forum.", "Ralat memuatkan forum."); }
        }

        private void LoadChildActivity()
        {
            pnlChildThreads.Controls.Clear();
            string childFilter = ddlChildFilter.SelectedValue;
            var childIds = string.IsNullOrEmpty(childFilter) ? _linkedChildUserIds : new System.Collections.Generic.List<string> { childFilter };
            if (childIds.Count == 0) { pnlEmpty.Visible = true; litEmpty.Text = T("No linked children.", "Tiada anak dipautkan."); return; }

            string inClause = string.Join(",", childIds.Select((id, i) => "@c" + i));

            try
            {
                using (var c = new SqlConnection(ConnStr))
                {
                    c.Open();
                    using (var cmd = new SqlCommand(string.Format(@"SELECT f.forumId, f.title, LEFT(f.message,100) AS preview, f.createdAt, u.username,
                        (SELECT COUNT(*) FROM dbo.ForumLike WHERE forumId=f.forumId) AS likeCount,
                        (SELECT COUNT(*) FROM dbo.ForumChat WHERE forumId=f.forumId) AS replyCount
                        FROM dbo.Forum f INNER JOIN dbo.[User] u ON f.createdBy=u.userId
                        WHERE f.createdBy IN ({0}) ORDER BY f.createdAt DESC", inClause), c))
                    {
                        for (int i = 0; i < childIds.Count; i++) cmd.Parameters.AddWithValue("@c" + i, childIds[i]);
                        using (var r = cmd.ExecuteReader()) { StringBuilder sb = new StringBuilder(); bool has = false; while (r.Read()) { has = true; sb.Append(RenderThreadCard(r["forumId"].ToString(), r["username"].ToString(), Convert.ToDateTime(r["createdAt"]), r["title"].ToString(), r["preview"].ToString(), Convert.ToInt32(r["likeCount"]), Convert.ToInt32(r["replyCount"]))); } if (has) pnlChildThreads.Controls.Add(new LiteralControl(sb.ToString())); else { pnlEmpty.Visible = true; litEmpty.Text = T("No threads by your children.", "Tiada hantaran oleh anak anda."); } }
                    }
                }
            }
            catch { }
        }

        private string RenderThreadCard(string forumId, string username, DateTime date, string title, string preview, int likes, int replies)
        {
            string initial = !string.IsNullOrEmpty(username) ? username[0].ToString().ToUpper() : "?";
            return string.Format(@"<a href='ForumThread.aspx?forumId={0}' class='pt-forum-thread-card'>
                <div class='pt-forum-avatar'>{1}</div>
                <div class='pt-forum-thread-body'>
                    <div class='pt-forum-author-row'><span class='pt-forum-username'>{2}</span> <span class='pt-forum-date'>&bull; {3}</span></div>
                    <div class='pt-forum-title'>{4}</div>
                    <div class='pt-forum-preview'>{5}</div>
                    <div class='pt-forum-stats'><span><i class='bi bi-heart'></i> {6}</span><span><i class='bi bi-chat'></i> {7}</span></div>
                </div>
            </a>", forumId, initial, Server.HtmlEncode(username), GetTimeAgo(date), Server.HtmlEncode(title), Server.HtmlEncode(preview), likes, replies);
        }

        private string GetTimeAgo(DateTime dt) { var d = DateTime.Now - dt; if (d.TotalSeconds < 0) return dt.ToString("dd MMM yyyy"); if (d.TotalMinutes < 1) return T("Just now", "Baru sahaja"); if (d.TotalMinutes < 60) return (int)d.TotalMinutes + " " + T("min ago", "min lalu"); if (d.TotalHours < 24) return (int)d.TotalHours + " " + T("hours ago", "jam lalu"); if (d.TotalDays < 31) return (int)d.TotalDays + " " + T("days ago", "hari lalu"); return dt.ToString("dd MMM yyyy"); }

        private void LoadUnreadBadge() { try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.Notification WHERE toUserId=@uid AND isRead=0", c)) { cmd.Parameters.AddWithValue("@uid", Session["userId"].ToString()); c.Open(); int count = (int)cmd.ExecuteScalar(); if (count > 0) litUnreadBadge.Text = "<span class='pt-sidebar-badge'>" + count + "</span>"; else litUnreadBadge.Text = ""; } } catch { } }
    }
}
