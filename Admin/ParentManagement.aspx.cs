using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Admin
{
    public partial class ParentManagement : Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected string CurrentLanguage =>
            ((ScienceBuddy.SiteMaster)Master).CurrentLanguage;

        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // AJAX handler for Add Parent
            if (Request.QueryString["handler"] == "ParentCRUD" && Request.HttpMethod == "POST")
            { HandleParentAjax(); return; }

            if (Session["userId"] == null)
            { Response.Redirect("~/Login.aspx", false); return; }
            if (Session["role"] == null || Session["role"].ToString() != "Admin")
            { Response.Redirect("~/Login.aspx", false); return; }

            var master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                SetMasterUserInfo();
                LoadInsights();
                LoadParents("", "", "", "name");
            }

            txtSearch.Attributes["placeholder"] = T("Search parent name…", "Cari nama ibu bapa…");
            btnSearch.Text       = T("Search", "Cari");
            btnReset.Text        = T("Reset", "Tetapkan Semula");
            btnCloseProfile.Text = T("Close", "Tutup");
        }

        private void SetMasterUserInfo()
        {
            string uid = Session["userId"].ToString();
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [username] FROM dbo.[User] WHERE [userId]=@uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", uid);
                    var val = cmd.ExecuteScalar();
                    string name = (val != null && val != DBNull.Value) ? val.ToString() : "Admin";
                    string ini = name.Length >= 2 ? name.Substring(0, 2).ToUpper() : name.ToUpper();
                    ((ScienceBuddy.SiteMaster)Master).SetUserInfo(name, "Administrator", ini);
                }
            }
        }

        private void LoadInsights()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                litTotal.Text   = SafeScalar(conn, "SELECT COUNT(*) FROM dbo.[Parent]");
                litLinked.Text  = SafeScalar(conn, "SELECT COUNT(*) FROM dbo.[StudentParent]");
                litDiscuss.Text = SafeScalar(conn,
                    "SELECT COUNT(*) FROM dbo.[Forum] f JOIN dbo.[User] u ON u.[userId]=f.[createdBy] WHERE u.[role]='Parent'");
                litActive.Text  = SafeScalar(conn,
                    "SELECT COUNT(*) FROM dbo.[Parent] p JOIN dbo.[User] u ON u.[userId]=p.[userId] WHERE u.[status]='Active'");
            }
        }

        private void LoadParents(string search, string statusFilter, string langFilter, string sortBy)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                string sql = @"
                    SELECT p.[parentId], p.[name], p.[phoneNumber],
                           u.[username], u.[email], u.[status], u.[preferredLanguage],
                           (SELECT COUNT(*) FROM dbo.[StudentParent] sp WHERE sp.[parentId]=p.[parentId]) AS childCount
                    FROM dbo.[Parent] p
                    LEFT JOIN dbo.[User] u ON u.[userId] = p.[userId]
                    WHERE 1=1";

                if (!string.IsNullOrWhiteSpace(search))
                    sql += " AND (p.[name] LIKE @search OR u.[username] LIKE @search)";
                if (!string.IsNullOrWhiteSpace(statusFilter))
                    sql += " AND u.[status] = @status";
                if (!string.IsNullOrWhiteSpace(langFilter))
                    sql += " AND u.[preferredLanguage] = @lang";

                switch (sortBy)
                {
                    case "name_desc":     sql += " ORDER BY p.[name] DESC"; break;
                    case "children_desc": sql += " ORDER BY childCount DESC"; break;
                    default:              sql += " ORDER BY p.[name] ASC"; break;
                }

                using (var cmd = new SqlCommand(sql, conn))
                {
                    if (!string.IsNullOrWhiteSpace(search))
                        cmd.Parameters.AddWithValue("@search", "%" + search + "%");
                    if (!string.IsNullOrWhiteSpace(statusFilter))
                        cmd.Parameters.AddWithValue("@status", statusFilter);
                    if (!string.IsNullOrWhiteSpace(langFilter))
                        cmd.Parameters.AddWithValue("@lang", langFilter);

                    var da = new SqlDataAdapter(cmd);
                    var dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count == 0)
                    { pnlParents.Visible = false; pnlEmpty.Visible = true; return; }

                    string[] gradients = {
                        "background:linear-gradient(135deg,#0891B2,#22D3EE);",
                        "background:linear-gradient(135deg,#14B8A6,#5EEAD4);",
                        "background:linear-gradient(135deg,#F97316,#FB923C);",
                        "background:linear-gradient(135deg,#3B82F6,#60A5FA);",
                        "background:linear-gradient(135deg,#8B5CF6,#A78BFA);",
                        "background:linear-gradient(135deg,#EC4899,#F472B6);"
                    };

                    var list = new List<object>();
                    int idx = 0;
                    foreach (DataRow row in dt.Rows)
                    {
                        string name     = NullSafe(row["name"]);
                        string username = NullSafe(row["username"]);
                        string display  = !string.IsNullOrWhiteSpace(name) ? name : username;
                        string status   = NullSafe(row["status"]);
                        string lang     = NullSafe(row["preferredLanguage"]);
                        string phone    = NullSafe(row["phoneNumber"]);
                        int children    = row["childCount"] == DBNull.Value ? 0 : Convert.ToInt32(row["childCount"]);

                        list.Add(new
                        {
                            parentId        = row["parentId"].ToString(),
                            displayName     = display,
                            username        = username,
                            initials        = GetInitials(display),
                            phone           = string.IsNullOrWhiteSpace(phone) ? "-" : phone,
                            language        = lang == "BM" ? "BM" : "EN",
                            childCount      = children,
                            statusLabel     = status == "Active" ? T("Active", "Aktif") : T("Blocked", "Disekat"),
                            statusPillClass = status == "Active" ? "" : "blocked",
                            dotClass        = status == "Active" ? "active" : "inactive",
                            gradient        = gradients[idx % gradients.Length]
                        });
                        idx++;
                    }

                    pnlParents.Visible = true;
                    pnlEmpty.Visible   = false;
                    rptParents.DataSource = list;
                    rptParents.DataBind();
                }
            }
        }

        // ── Card button commands ─────────────────────────────────────
        protected void rptParents_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string parentId = e.CommandArgument.ToString();

            if (e.CommandName == "ViewProfile")
                ShowProfileModal(parentId);
            else if (e.CommandName == "ViewChildren")
                ShowChildrenModal(parentId);
        }

        private void ShowProfileModal(string parentId)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(@"
                    SELECT p.[parentId], p.[name], p.[phoneNumber],
                           u.[username], u.[email], u.[status], u.[preferredLanguage],
                           (SELECT COUNT(*) FROM dbo.[StudentParent] sp WHERE sp.[parentId]=p.[parentId]) AS childCount,
                           (SELECT COUNT(*) FROM dbo.[Forum] f WHERE f.[createdBy]=p.[userId]) AS forumCount
                    FROM dbo.[Parent] p
                    LEFT JOIN dbo.[User] u ON u.[userId]=p.[userId]
                    WHERE p.[parentId]=@pid", conn))
                {
                    cmd.Parameters.AddWithValue("@pid", parentId);
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string name = NullSafe(reader["name"]);
                            string username = NullSafe(reader["username"]);
                            litModalInitials.Text = GetInitials(!string.IsNullOrWhiteSpace(name) ? name : username);
                            litModalName.Text     = HttpUtility.HtmlEncode(!string.IsNullOrWhiteSpace(name) ? name : username);
                            litModalUsername.Text  = HttpUtility.HtmlEncode(username);
                            litModalEmail.Text    = HttpUtility.HtmlEncode(NullSafe(reader["email"]));
                            litModalPhone.Text    = HttpUtility.HtmlEncode(NullSafe(reader["phoneNumber"]));
                            litModalChildren.Text = reader["childCount"].ToString();
                            litModalForums.Text   = reader["forumCount"].ToString();
                            string lang = NullSafe(reader["preferredLanguage"]);
                            litModalLang.Text     = lang == "BM" ? "BM" : "EN";
                            string status = NullSafe(reader["status"]);
                            litModalStatus.Text   = string.Format(
                                "<span class=\"sb-badge {0}\">{1}</span>",
                                status == "Active" ? "sb-badge-success" : "sb-badge-error",
                                HttpUtility.HtmlEncode(status == "Active" ? T("Active", "Aktif") : T("Blocked", "Disekat")));
                        }
                    }
                }
            }
            pnlProfileModal.Visible  = true;
            pnlChildrenModal.Visible = false;
        }

        private void ShowChildrenModal(string parentId)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                string lvlCol = CurrentLanguage == "BM" ? "lv.[levelNameBM]" : "lv.[levelNameEN]";
                string sql = string.Format(@"
                    SELECT s.[studentId], s.[name], s.[nickname], s.[XP],
                           ISNULL({0}, '-') AS levelName
                    FROM dbo.[StudentParent] sp
                    JOIN dbo.[Student] s ON s.[studentId] = sp.[studentId]
                    LEFT JOIN dbo.[Level] lv ON lv.[levelId] = s.[currentLevelId]
                    WHERE sp.[parentId] = @pid", lvlCol);

                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@pid", parentId);
                    var da = new SqlDataAdapter(cmd);
                    var dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count == 0)
                    { pnlChildrenList.Visible = false; pnlNoChildren.Visible = true; }
                    else
                    {
                        string[] grads = {
                            "background:linear-gradient(135deg,#6366F1,#818CF8);",
                            "background:linear-gradient(135deg,#10B981,#34D399);",
                            "background:linear-gradient(135deg,#F59E0B,#FBBF24);",
                            "background:linear-gradient(135deg,#EC4899,#F472B6);"
                        };

                        var list = new List<object>();
                        int i = 0;
                        foreach (DataRow row in dt.Rows)
                        {
                            string cName = NullSafe(row["nickname"]);
                            if (string.IsNullOrWhiteSpace(cName)) cName = NullSafe(row["name"]);
                            if (string.IsNullOrWhiteSpace(cName)) cName = "Student";
                            int xp = row["XP"] == DBNull.Value ? 0 : Convert.ToInt32(row["XP"]);
                            list.Add(new
                            {
                                name     = cName,
                                initials = GetInitials(cName),
                                level    = NullSafe(row["levelName"]),
                                xp       = xp,
                                xpPct    = Math.Min(xp * 100 / 500, 100),
                                gradient = grads[i % grads.Length]
                            });
                            i++;
                        }
                        pnlChildrenList.Visible = true;
                        pnlNoChildren.Visible   = false;
                        rptChildren.DataSource  = list;
                        rptChildren.DataBind();
                    }
                }
            }
            pnlChildrenModal.Visible = true;
            pnlProfileModal.Visible  = false;
        }

        protected void btnCloseModal_Click(object sender, EventArgs e)
        {
            pnlProfileModal.Visible  = false;
            pnlChildrenModal.Visible = false;
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadParents(txtSearch.Text.Trim(), ddlStatus.SelectedValue, ddlLang.SelectedValue, ddlSort.SelectedValue);
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlStatus.SelectedIndex = 0;
            ddlLang.SelectedIndex   = 0;
            ddlSort.SelectedIndex   = 0;
            LoadParents("", "", "", "name");
        }

        private string SafeScalar(SqlConnection conn, string sql)
        {
            try { using (var cmd = new SqlCommand(sql, conn)) { var v = cmd.ExecuteScalar(); return (v != null && v != DBNull.Value) ? Convert.ToInt32(v).ToString() : "0"; } }
            catch { return "0"; }
        }

        private static string NullSafe(object val)
        { return (val == null || val == DBNull.Value) ? "" : val.ToString(); }

        private static string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "P";
            var parts = name.Trim().Split(' ');
            if (parts.Length >= 2) return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
            return name.Substring(0, Math.Min(2, name.Length)).ToUpper();
        }

        // ── Add Parent AJAX ──────────────────────────────────────────
        private void HandleParentAjax()
        {
            Response.ContentType = "application/json";
            try
            {
                if (Session["userId"] == null || Session["role"]?.ToString() != "Admin")
                { Response.Write("{\"success\":false,\"msg\":\"Unauthorized\"}"); Response.End(); return; }

                string action = Request.QueryString["action"] ?? "";
                if (action != "addParent") { Response.Write("{\"success\":false,\"msg\":\"Unknown\"}"); Response.End(); return; }

                string name     = Request.Form["name"]     ?? "";
                string username = Request.Form["username"] ?? "";
                string email    = Request.Form["email"]    ?? "";
                string password = Request.Form["password"] ?? "";
                string phone    = Request.Form["phone"]    ?? "";
                string lang     = Request.Form["lang"]     ?? "EN";
                string adminId  = Session["userId"].ToString();

                if (string.IsNullOrWhiteSpace(name) || string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(email))
                { Response.Write("{\"success\":false,\"msg\":\"Name, username and email are required.\"}"); Response.End(); return; }
                if (string.IsNullOrWhiteSpace(password) || password.Length < 8)
                { Response.Write("{\"success\":false,\"msg\":\"Password must be at least 8 characters.\"}"); Response.End(); return; }

                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    // Check uniqueness before starting transaction
                    using (var chk = new SqlCommand("SELECT COUNT(*) FROM dbo.[User] WHERE [email]=@e OR [username]=@u", conn))
                    { chk.Parameters.AddWithValue("@e", email); chk.Parameters.AddWithValue("@u", username);
                      if (Convert.ToInt32(chk.ExecuteScalar()) > 0) { Response.Write("{\"success\":false,\"msg\":\"Username or email already exists.\"}"); Response.End(); return; } }

                    // BEGIN TRANSACTION — all inserts succeed or none persist
                    using (var txn = conn.BeginTransaction())
                    {
                        try
                        {
                            // 1. Generate UserID
                            string userId = GenId(conn, "User", "userId", "U", txn);

                            // 2. Insert User
                            using (var cmd = new SqlCommand("INSERT INTO dbo.[User]([userId],[username],[password],[email],[role],[preferredLanguage],[status]) VALUES(@uid,@un,@pw,@em,'Parent',@lg,'Active')", conn, txn))
                            { cmd.Parameters.AddWithValue("@uid", userId); cmd.Parameters.AddWithValue("@un", username); cmd.Parameters.AddWithValue("@pw", password); cmd.Parameters.AddWithValue("@em", email); cmd.Parameters.AddWithValue("@lg", lang); cmd.ExecuteNonQuery(); }

                            // 3. Generate ParentID
                            string parentId = GenId(conn, "Parent", "parentId", "P", txn);

                            // 4. Insert Parent (foreign key to User)
                            using (var cmd = new SqlCommand("INSERT INTO dbo.[Parent]([parentId],[userId],[name],[phoneNumber]) VALUES(@pid,@uid,@name,@ph)", conn, txn))
                            { cmd.Parameters.AddWithValue("@pid", parentId); cmd.Parameters.AddWithValue("@uid", userId); cmd.Parameters.AddWithValue("@name", name);
                              cmd.Parameters.AddWithValue("@ph", string.IsNullOrEmpty(phone) ? (object)DBNull.Value : phone); cmd.ExecuteNonQuery(); }

                            // 5. Insert Notification
                            string notifId = GenId(conn, "Notification", "notificationId", "N", txn);
                            using (var cmd = new SqlCommand("INSERT INTO dbo.[Notification]([notificationId],[toUserId],[titleEN],[titleBM],[messageEN],[messageBM],[isRead],[createdAt]) VALUES(@a,@b,'Welcome to ScienceBuddy!','Selamat Datang ke ScienceBuddy!','Your parent account has been created.','Akaun ibu bapa anda telah dicipta.',0,@c)", conn, txn))
                            { cmd.Parameters.AddWithValue("@a", notifId); cmd.Parameters.AddWithValue("@b", userId); cmd.Parameters.AddWithValue("@c", DateTime.Now); cmd.ExecuteNonQuery(); }

                            // 6. Insert Log
                            string logId = GenId(conn, "Log", "logId", "LOG", txn);
                            using (var cmd = new SqlCommand("INSERT INTO dbo.[Log]([logId],[userId],[action],[description],[logDateTime],[status]) VALUES(@a,@b,'Parent Created',@c,@d,'Success')", conn, txn))
                            { cmd.Parameters.AddWithValue("@a", logId); cmd.Parameters.AddWithValue("@b", adminId); cmd.Parameters.AddWithValue("@c", "Created parent: " + name + " (" + parentId + ")."); cmd.Parameters.AddWithValue("@d", DateTime.Now); cmd.ExecuteNonQuery(); }

                            // COMMIT — all steps succeeded
                            txn.Commit();
                        }
                        catch (Exception txEx)
                        {
                            // ROLLBACK — no partial records
                            txn.Rollback();
                            Response.Write("{\"success\":false,\"msg\":\"Transaction failed: " + EscJ(txEx.Message) + "\"}");
                            Response.End();
                            return;
                        }
                    }
                }
                Response.Write("{\"success\":true}");
            }
            catch (Exception ex) { Response.Write("{\"success\":false,\"msg\":\"" + EscJ(ex.Message) + "\"}"); }
            Response.End();
        }

        private string GenId(SqlConnection c, string tbl, string col, string pfx)
        { return GenId(c, tbl, col, pfx, null); }

        private string GenId(SqlConnection c, string tbl, string col, string pfx, SqlTransaction txn)
        { using (var cmd = new SqlCommand(string.Format("SELECT TOP 1 [{0}] FROM dbo.[{1}] ORDER BY [{0}] DESC", col, tbl), c)) { cmd.Transaction = txn; var v = cmd.ExecuteScalar(); if (v == null || v == DBNull.Value) return pfx + "001"; string l = v.ToString(); int n; int.TryParse(l.Substring(pfx.Length), out n); n++; return pfx + n.ToString().PadLeft(l.Length - pfx.Length, '0'); } }

        private static string EscJ(string s) { return (s ?? "").Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", ""); }
    }
}
