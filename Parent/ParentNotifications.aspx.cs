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
    public partial class ParentNotifications : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        protected string CurrentLanguage = "EN";
        protected string T(string en, string bm) => CurrentLanguage == "BM" ? bm : en;
        private string _parentId = "", _parentUserId = "", _selectedChildId = "", _selectedChildName = "";
        private List<string> _linkedChildIds = new List<string>();

        private string ActiveFilter { get { return ViewState["Filter"] as string ?? "All"; } set { ViewState["Filter"] = value; } }
        private string SortOrder { get { return ViewState["SortOrder"] as string ?? "Latest"; } set { ViewState["SortOrder"] = value; } }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!EnsureAuth()) return;
            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            LoadLang(); LoadUnreadBadge(); _parentUserId = Session["userId"].ToString(); LoadParent();
            if (!IsPostBack) { LoadChildren(); if (_linkedChildIds.Count > 0) { pnlContent.Visible = true; LoadPage(); } else ShowNoChild(); }
            else { _selectedChildId = ddlSidebarChild.SelectedValue; _selectedChildName = ddlSidebarChild.SelectedItem != null ? ddlSidebarChild.SelectedItem.Text : ""; LoadLinkedChildIds(); }
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

        private void LoadChildren()
        {
            ddlSidebarChild.Items.Clear();
            try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT s.studentId, ISNULL(s.nickname,s.name) AS n FROM dbo.StudentParent sp INNER JOIN dbo.Student s ON sp.studentId=s.studentId WHERE sp.parentId=@p ORDER BY s.name", c)) { cmd.Parameters.AddWithValue("@p", _parentId); c.Open(); using (var r = cmd.ExecuteReader()) { while (r.Read()) { ddlSidebarChild.Items.Add(new ListItem(r["n"].ToString(), r["studentId"].ToString())); _linkedChildIds.Add(r["studentId"].ToString()); } } } } catch { }
            if (ddlSidebarChild.Items.Count > 0) { string saved = Session["selectedChildId"] as string; if (!string.IsNullOrEmpty(saved) && ddlSidebarChild.Items.FindByValue(saved) != null) ddlSidebarChild.SelectedValue = saved; else Session["selectedChildId"] = ddlSidebarChild.Items[0].Value; _selectedChildId = ddlSidebarChild.SelectedValue; _selectedChildName = ddlSidebarChild.SelectedItem.Text; }
        }

        private void LoadLinkedChildIds()
        {
            _linkedChildIds.Clear();
            try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT studentId FROM dbo.StudentParent WHERE parentId=@p", c)) { cmd.Parameters.AddWithValue("@p", _parentId); c.Open(); using (var r = cmd.ExecuteReader()) { while (r.Read()) _linkedChildIds.Add(r["studentId"].ToString()); } } } catch { }
        }

        protected void SidebarChildChanged(object sender, EventArgs e) { Session["selectedChildId"] = ddlSidebarChild.SelectedValue; _selectedChildId = ddlSidebarChild.SelectedValue; _selectedChildName = ddlSidebarChild.SelectedItem.Text; LoadLinkedChildIds(); pnlContent.Visible = true; LoadPage(); }
        private void ShowNoChild() { pnlNoChild.Visible = true; pnlContent.Visible = false; litNoChildMsg.Text = T("No linked child found.", "Tiada anak dipautkan."); }

        // ══════════════════════════════════════════════════════════════
        //  MAIN LOAD
        // ══════════════════════════════════════════════════════════════
        private void LoadPage()
        {
            LoadSinceLastVisit();
            LoadNotificationFeed();
            HighlightActiveFilter();
        }

        // ══════════════════════════════════════════════════════════════
        //  SINCE YOUR LAST VISIT
        // ══════════════════════════════════════════════════════════════
        private void LoadSinceLastVisit()
        {
            pnlSinceVisit.Controls.Clear();
            int unreadCount = 0;

            try
            {
                using (var c = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.Notification WHERE toUserId=@uid AND isRead=0", c))
                {
                    cmd.Parameters.AddWithValue("@uid", _parentUserId);
                    c.Open();
                    unreadCount = (int)cmd.ExecuteScalar();
                }
            }
            catch { }

            if (unreadCount == 0) { pnlAllCaughtUp.Visible = true; return; }
            pnlAllCaughtUp.Visible = false;

            StringBuilder sb = new StringBuilder("<div class=\"pt-since-visit-grid\">");
            sb.AppendFormat("<div class=\"pt-since-visit-item\"><i class=\"bi bi-bell-fill\"></i> {0} {1}</div>", unreadCount, T("unread notification(s)", "notifikasi belum dibaca"));
            sb.Append("</div>");
            pnlSinceVisit.Controls.Add(new LiteralControl(sb.ToString()));
        }

        private string GetChildIdsSql()
        {
            if (_linkedChildIds.Count == 0) return "'NONE'";
            var parts = new List<string>();
            for (int i = 0; i < _linkedChildIds.Count; i++) parts.Add("@cid" + i);
            return string.Join(",", parts);
        }

        private void AddChildParams(SqlCommand cmd)
        {
            for (int i = 0; i < _linkedChildIds.Count; i++) cmd.Parameters.AddWithValue("@cid" + i, _linkedChildIds[i]);
        }

        // ══════════════════════════════════════════════════════════════
        //  NOTIFICATION FEED
        // ══════════════════════════════════════════════════════════════
        private void LoadNotificationFeed()
        {
            pnlFeed.Controls.Clear();
            var items = new List<NotifItem>();
            string filter = ActiveFilter;
            string search = txtSearch.Text.Trim().ToLower();

            try
            {
                using (var c = new SqlConnection(ConnStr))
                {
                    c.Open();

                    // Only use the Notification table
                    using (var cmd = new SqlCommand(@"SELECT notificationId, titleEN, titleBM, messageEN, messageBM, isRead, createdAt
                        FROM dbo.Notification WHERE toUserId=@uid ORDER BY createdAt DESC", c))
                    {
                        cmd.Parameters.AddWithValue("@uid", _parentUserId);
                        using (var r = cmd.ExecuteReader())
                        {
                            while (r.Read())
                            {
                                bool isRead = r["isRead"] != DBNull.Value && Convert.ToBoolean(r["isRead"]);
                                var n = new NotifItem
                                {
                                    Id = r["notificationId"].ToString(),
                                    Category = "System", Icon = "bi-bell-fill", IconColor = "#6366F1",
                                    Title = CurrentLanguage == "BM" && r["titleBM"] != DBNull.Value && !string.IsNullOrEmpty(r["titleBM"].ToString()) ? r["titleBM"].ToString() : r["titleEN"] != DBNull.Value ? r["titleEN"].ToString() : "",
                                    Message = CurrentLanguage == "BM" && r["messageBM"] != DBNull.Value && !string.IsNullOrEmpty(r["messageBM"].ToString()) ? r["messageBM"].ToString() : r["messageEN"] != DBNull.Value ? r["messageEN"].ToString() : "",
                                    CreatedAt = r["createdAt"] != DBNull.Value ? Convert.ToDateTime(r["createdAt"]) : DateTime.MinValue,
                                    IsRead = isRead, Priority = "normal", ActionUrl = "", ActionText = ""
                                };
                                items.Add(n);
                            }
                        }
                    }
                }
            }
            catch { }

            // Apply search filter
            if (!string.IsNullOrEmpty(search))
                items = items.Where(i => i.Title.ToLower().Contains(search) || i.Message.ToLower().Contains(search)).ToList();

            // Filter read/unread
            if (filter == "Unread")
                items = items.Where(i => !i.IsRead).ToList();
            else if (filter == "Read")
                items = items.Where(i => i.IsRead).ToList();

            // Sort
            if (SortOrder == "Oldest")
                items = items.OrderBy(i => i.CreatedAt).ToList();
            else
                items = items.OrderByDescending(i => i.CreatedAt).ToList();

            if (items.Count == 0) { pnlEmpty.Visible = true; litEmptyMsg.Text = T("You're all caught up! No notifications to show.", "Anda sudah kemas kini! Tiada notifikasi untuk dipaparkan."); return; }
            pnlEmpty.Visible = false;
            RenderFeed(items);
        }

        private void RenderFeed(List<NotifItem> items)
        {
            StringBuilder sb = new StringBuilder();
            string lastGroup = "";

            foreach (var n in items)
            {
                string group = GetDateGroup(n.CreatedAt);
                if (group != lastGroup) { if (lastGroup != "") sb.Append("</div>"); sb.AppendFormat("<div class=\"pt-notif-group\"><div class=\"pt-notif-group-title\">{0}</div>", group); lastGroup = group; }

                string unreadDot = !n.IsRead ? "<span class=\"pt-notif-unread-dot\"></span>" : "";
                string markBtn = !n.IsRead && !string.IsNullOrEmpty(n.Id)
                    ? string.Format("<button type=\"button\" class=\"pt-notif-check-btn pt-notif-check-unread\" onclick=\"document.getElementById('{0}').value='{1}';document.getElementById('{2}').click();return false;\" title=\"{3}\"><i class=\"bi bi-circle\"></i></button>", hidMarkReadId.ClientID, n.Id, btnMarkRead.ClientID, T("Mark as read", "Tandai dibaca"))
                    : !string.IsNullOrEmpty(n.Id)
                    ? string.Format("<button type=\"button\" class=\"pt-notif-check-btn pt-notif-check-read\" onclick=\"document.getElementById('{0}').value='{1}';document.getElementById('{2}').click();return false;\" title=\"{3}\"><i class=\"bi bi-check-circle-fill\"></i></button>", hidMarkReadId.ClientID, n.Id, btnMarkRead.ClientID, T("Mark as unread", "Tandai belum dibaca"))
                    : "";
                string timeAgo = GetTimeAgo(n.CreatedAt);
                string cardClass = !n.IsRead ? "pt-notif-card pt-notif-card-unread" : "pt-notif-card";

                sb.AppendFormat(@"<div class=""{0}"">
                    <div class=""pt-notif-card-icon"" style=""background:{1}18;color:{1};""><i class=""bi {2}""></i></div>
                    <div class=""pt-notif-card-content"">
                        <div class=""pt-notif-card-title"">{3} {4}</div>
                        <div class=""pt-notif-card-message"">{5}</div>
                        <div class=""pt-notif-card-time""><i class=""bi bi-clock""></i> {6}</div>
                    </div>
                    {7}
                </div>", cardClass, n.IconColor, n.Icon,
                    System.Web.HttpUtility.HtmlEncode(n.Title), unreadDot,
                    System.Web.HttpUtility.HtmlEncode(n.Message), timeAgo, markBtn);
            }
            if (lastGroup != "") sb.Append("</div>");
            pnlFeed.Controls.Add(new LiteralControl(sb.ToString()));
        }

        private string GetDateGroup(DateTime dt)
        {
            if (dt.Date == DateTime.Today) return T("Today", "Hari Ini");
            if (dt.Date == DateTime.Today.AddDays(-1)) return T("Yesterday", "Semalam");
            return T("Older", "Lebih Lama");
        }

        private string GetTimeAgo(DateTime dt)
        {
            var diff = DateTime.Now - dt;
            if (diff.TotalSeconds < 0) return dt.ToString("dd MMM yyyy");
            if (diff.TotalMinutes < 1) return T("Just now", "Baru sahaja");
            if (diff.TotalMinutes < 60) return string.Format("{0} {1}", (int)diff.TotalMinutes, T("min ago", "min lalu"));
            if (diff.TotalHours < 24) return string.Format("{0} {1}", (int)diff.TotalHours, T("hours ago", "jam lalu"));
            if (diff.TotalDays < 31) return string.Format("{0} {1}", (int)diff.TotalDays, T("days ago", "hari lalu"));
            int months = (int)(diff.TotalDays / 30);
            if (months < 12) return string.Format("{0} {1}", months, T("months ago", "bulan lalu"));
            return dt.ToString("dd MMM yyyy");
        }

        // ══════════════════════════════════════════════════════════════
        //  FILTERS & ACTIONS
        // ══════════════════════════════════════════════════════════════
        protected void Filter_Changed(object sender, EventArgs e)
        {
            if (sender is LinkButton lb) ActiveFilter = lb.CommandArgument;
            LoadPage();
        }

        private void HighlightActiveFilter()
        {
            var chips = new[] { lnkAll, lnkRead, lnkUnread };
            foreach (var chip in chips) chip.CssClass = chip.CommandArgument == ActiveFilter ? "pt-notif-chip active" : "pt-notif-chip";
            lnkSortLatest.CssClass = SortOrder == "Latest" ? "pt-sort-btn active" : "pt-sort-btn";
            lnkSortOldest.CssClass = SortOrder == "Oldest" ? "pt-sort-btn active" : "pt-sort-btn";
        }

        protected void LnkMarkAllRead_Click(object sender, EventArgs e)
        {
            try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("UPDATE dbo.Notification SET isRead=1 WHERE toUserId=@uid AND isRead=0", c)) { cmd.Parameters.AddWithValue("@uid", _parentUserId); c.Open(); cmd.ExecuteNonQuery(); } } catch { }
            LoadPage();
        }

        protected void LnkSortLatest_Click(object sender, EventArgs e) { SortOrder = "Latest"; LoadPage(); }
        protected void LnkSortOldest_Click(object sender, EventArgs e) { SortOrder = "Oldest"; LoadPage(); }

        protected void BtnMarkRead_Click(object sender, EventArgs e)
        {
            string id = hidMarkReadId.Value;
            if (!string.IsNullOrEmpty(id))
            {
                try
                {
                    using (var c = new SqlConnection(ConnStr))
                    {
                        c.Open();
                        // Toggle: if read -> unread, if unread -> read
                        using (var cmd = new SqlCommand("UPDATE dbo.Notification SET isRead = CASE WHEN isRead=1 THEN 0 ELSE 1 END WHERE notificationId=@id AND toUserId=@uid", c))
                        { cmd.Parameters.AddWithValue("@id", id); cmd.Parameters.AddWithValue("@uid", _parentUserId); cmd.ExecuteNonQuery(); }
                    }
                }
                catch { }
            }
            LoadPage();
        }

        private class NotifItem
        {
            public string Id = "";
            public string Category = "";
            public string Icon = "";
            public string IconColor = "";
            public string Title = "";
            public string Message = "";
            public DateTime CreatedAt = DateTime.MinValue;
            public bool IsRead = true;
            public string Priority = "normal";
            public string ActionUrl = "";
            public string ActionText = "";
        }
        private void LoadUnreadBadge()
        {
            try
            {
                using (var c = new System.Data.SqlClient.SqlConnection(ConnStr))
                using (var cmd = new System.Data.SqlClient.SqlCommand("SELECT COUNT(*) FROM dbo.Notification WHERE toUserId=@uid AND isRead=0", c))
                {
                    cmd.Parameters.AddWithValue("@uid", Session["userId"].ToString());
                    c.Open();
                    int count = (int)cmd.ExecuteScalar();
                    if (count > 0) litUnreadBadge.Text = "<span class='pt-sidebar-badge'>" + count + "</span>";
                    else litUnreadBadge.Text = "";
                }
            }
            catch { }
        }
    }
}