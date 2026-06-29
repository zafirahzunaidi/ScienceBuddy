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
    public partial class StudentManagement : Page
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
            if (Session["userId"] == null)
            { Response.Redirect("~/Login.aspx", false); return; }
            if (Session["role"] == null || Session["role"].ToString() != "Admin")
            { Response.Redirect("~/Login.aspx", false); return; }

            var master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                SetMasterUserInfo();
                LoadLevelDropdown();
                LoadInsights();
                LoadStudents("", "", "", "", "name");
            }

            // Bilingual labels
            txtSearch.Attributes["placeholder"] = T("Search by name, username or email…", "Cari mengikut nama, nama pengguna atau e-mel…");
            btnSearch.Text     = T("Search", "Cari");
            btnReset.Text      = T("Reset", "Tetapkan Semula");
            btnCloseModal.Text = T("Close", "Tutup");
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

        private void LoadLevelDropdown()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                string col = CurrentLanguage == "BM" ? "levelNameBM" : "levelNameEN";
                using (var cmd = new SqlCommand(
                    "SELECT [levelId],[levelNameEN],[levelNameBM] FROM dbo.[Level] ORDER BY [levelId]", conn))
                {
                    var reader = cmd.ExecuteReader();
                    ddlLevel.Items.Clear();
                    ddlLevel.Items.Add(new ListItem(T("All Levels", "Semua Tahap"), ""));
                    while (reader.Read())
                    {
                        string name = CurrentLanguage == "BM"
                            ? reader["levelNameBM"].ToString()
                            : reader["levelNameEN"].ToString();
                        ddlLevel.Items.Add(new ListItem(name, reader["levelId"].ToString()));
                    }
                }
            }
        }

        private void LoadInsights()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Total students
                litTotal.Text = SafeScalar(conn, "SELECT COUNT(*) FROM dbo.[Student]");

                // Average XP
                litAvgXP.Text = SafeScalar(conn, "SELECT ISNULL(AVG([XP]),0) FROM dbo.[Student]");

                // Highest level
                string lvlCol = CurrentLanguage == "BM" ? "l.[levelNameBM]" : "l.[levelNameEN]";
                using (var cmd = new SqlCommand(string.Format(@"
                    SELECT TOP 1 {0}
                    FROM dbo.[Student] s
                    JOIN dbo.[Level] l ON l.[levelId] = s.[currentLevelId]
                    ORDER BY l.[levelId] DESC", lvlCol), conn))
                {
                    var val = cmd.ExecuteScalar();
                    litHighLevel.Text = (val != null && val != DBNull.Value) ? val.ToString() : "-";
                }

                // Active students (User.status = 'Active')
                litActive.Text = SafeScalar(conn,
                    "SELECT COUNT(*) FROM dbo.[Student] s JOIN dbo.[User] u ON u.[userId]=s.[userId] WHERE u.[status]='Active'");
            }
        }

        private void LoadStudents(string search, string levelFilter, string statusFilter, string langFilter, string sortBy)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                string lvlCol = CurrentLanguage == "BM" ? "lv.[levelNameBM]" : "lv.[levelNameEN]";
                string pCol   = CurrentLanguage == "BM" ? "p.[personalityNameBM]" : "p.[personalityNameEN]";

                string sql = string.Format(@"
                    SELECT
                        s.[studentId], s.[name], s.[nickname], s.[XP], s.[currentLevelId],
                        u.[username], u.[email], u.[status], u.[preferredLanguage],
                        ISNULL({0}, '-') AS levelName,
                        ISNULL({1}, '-') AS personalityName,
                        (SELECT COUNT(*) FROM dbo.[LessonProgress] lp WHERE lp.[studentId]=s.[studentId] AND lp.[isCompleted]=1) AS lessonsCompleted,
                        (SELECT COUNT(*) FROM dbo.[StudentBadge] sb WHERE sb.[studentId]=s.[studentId]) AS badgesEarned
                    FROM dbo.[Student] s
                    LEFT JOIN dbo.[User] u ON u.[userId] = s.[userId]
                    LEFT JOIN dbo.[Level] lv ON lv.[levelId] = s.[currentLevelId]
                    LEFT JOIN dbo.[Personality] p ON p.[personalityId] = s.[personalityId]
                    WHERE 1=1", lvlCol, pCol);

                if (!string.IsNullOrWhiteSpace(search))
                    sql += " AND (s.[name] LIKE @search OR s.[nickname] LIKE @search OR u.[username] LIKE @search OR u.[email] LIKE @search)";
                if (!string.IsNullOrWhiteSpace(levelFilter))
                    sql += " AND s.[currentLevelId] = @level";
                if (!string.IsNullOrWhiteSpace(statusFilter))
                    sql += " AND u.[status] = @status";
                if (!string.IsNullOrWhiteSpace(langFilter))
                    sql += " AND u.[preferredLanguage] = @lang";

                // Sort
                switch (sortBy)
                {
                    case "name_desc": sql += " ORDER BY s.[name] DESC"; break;
                    case "xp_desc":   sql += " ORDER BY s.[XP] DESC"; break;
                    case "xp_asc":    sql += " ORDER BY s.[XP] ASC"; break;
                    default:          sql += " ORDER BY s.[name] ASC"; break;
                }

                using (var cmd = new SqlCommand(sql, conn))
                {
                    if (!string.IsNullOrWhiteSpace(search))
                        cmd.Parameters.AddWithValue("@search", "%" + search + "%");
                    if (!string.IsNullOrWhiteSpace(levelFilter))
                        cmd.Parameters.AddWithValue("@level", levelFilter);
                    if (!string.IsNullOrWhiteSpace(statusFilter))
                        cmd.Parameters.AddWithValue("@status", statusFilter);
                    if (!string.IsNullOrWhiteSpace(langFilter))
                        cmd.Parameters.AddWithValue("@lang", langFilter);

                    var da = new SqlDataAdapter(cmd);
                    var dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count == 0)
                    {
                        pnlStudents.Visible = false;
                        pnlEmpty.Visible    = true;
                        return;
                    }

                    var list = new List<object>();
                    string[] gradients = {
                        "background:linear-gradient(135deg,#6366F1,#818CF8);",
                        "background:linear-gradient(135deg,#EC4899,#F472B6);",
                        "background:linear-gradient(135deg,#10B981,#34D399);",
                        "background:linear-gradient(135deg,#F59E0B,#FBBF24);",
                        "background:linear-gradient(135deg,#06B6D4,#22D3EE);",
                        "background:linear-gradient(135deg,#8B5CF6,#A78BFA);"
                    };

                    int idx = 0;
                    foreach (DataRow row in dt.Rows)
                    {
                        string name     = NullSafe(row["name"]);
                        string nickname = NullSafe(row["nickname"]);
                        string display  = !string.IsNullOrWhiteSpace(nickname) ? nickname : (!string.IsNullOrWhiteSpace(name) ? name : "Student");
                        string username = NullSafe(row["username"]);
                        string status   = NullSafe(row["status"]);
                        int xp          = row["XP"] == DBNull.Value ? 0 : Convert.ToInt32(row["XP"]);
                        int maxXp       = 500; // per-level scale
                        int pct         = Math.Min(xp * 100 / Math.Max(maxXp, 1), 100);
                        string initials = GetInitials(display);
                        string lang     = NullSafe(row["preferredLanguage"]);

                        list.Add(new
                        {
                            studentId       = row["studentId"].ToString(),
                            displayName     = display,
                            username        = username,
                            initials        = initials,
                            levelName       = NullSafe(row["levelName"]),
                            personalityName = NullSafe(row["personalityName"]),
                            language        = lang == "BM" ? "BM" : "EN",
                            xp              = xp,
                            xpPct           = pct,
                            lessonsCompleted = row["lessonsCompleted"],
                            badgesEarned    = row["badgesEarned"],
                            statusClass     = status == "Active" ? "active" : "inactive",
                            avatarGradient  = gradients[idx % gradients.Length]
                        });
                        idx++;
                    }

                    pnlStudents.Visible = true;
                    pnlEmpty.Visible    = false;
                    rptStudents.DataSource = list;
                    rptStudents.DataBind();
                }
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadStudents(txtSearch.Text.Trim(), ddlLevel.SelectedValue, ddlStatus.SelectedValue, ddlLang.SelectedValue, ddlSort.SelectedValue);
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlLevel.SelectedIndex  = 0;
            ddlStatus.SelectedIndex = 0;
            ddlLang.SelectedIndex   = 0;
            ddlSort.SelectedIndex   = 0;
            LoadStudents("", "", "", "", "name");
        }

        // ── View Details modal ───────────────────────────────────────
        protected void rptStudents_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "ViewStudent")
                ShowStudentModal(e.CommandArgument.ToString());
        }

        private void ShowStudentModal(string studentId)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                string lvlCol = CurrentLanguage == "BM" ? "lv.[levelNameBM]" : "lv.[levelNameEN]";
                string pCol   = CurrentLanguage == "BM" ? "p.[personalityNameBM]" : "p.[personalityNameEN]";

                string sql = string.Format(@"
                    SELECT s.[studentId], s.[name], s.[nickname], s.[XP], s.[phoneNumber],
                           u.[username], u.[email], u.[status], u.[preferredLanguage],
                           ISNULL({0}, '-') AS levelName,
                           ISNULL({1}, '-') AS personalityName,
                           (SELECT COUNT(*) FROM dbo.[LessonProgress] lp WHERE lp.[studentId]=s.[studentId] AND lp.[isCompleted]=1) AS lessonsCompleted,
                           (SELECT COUNT(*) FROM dbo.[StudentBadge] sb WHERE sb.[studentId]=s.[studentId]) AS badgesEarned,
                           (SELECT COUNT(*) FROM dbo.[QuizResult] qr WHERE qr.[studentId]=s.[studentId]) AS quizzesCompleted
                    FROM dbo.[Student] s
                    LEFT JOIN dbo.[User] u ON u.[userId]=s.[userId]
                    LEFT JOIN dbo.[Level] lv ON lv.[levelId]=s.[currentLevelId]
                    LEFT JOIN dbo.[Personality] p ON p.[personalityId]=s.[personalityId]
                    WHERE s.[studentId]=@sid", lvlCol, pCol);

                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@sid", studentId);
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read()) return;

                        string name     = NullSafe(reader["nickname"]);
                        if (string.IsNullOrWhiteSpace(name)) name = NullSafe(reader["name"]);
                        if (string.IsNullOrWhiteSpace(name)) name = "Student";
                        string username = NullSafe(reader["username"]);
                        int xp          = reader["XP"] == DBNull.Value ? 0 : Convert.ToInt32(reader["XP"]);
                        int pct         = Math.Min(xp * 100 / Math.Max(500, 1), 100);
                        string status   = NullSafe(reader["status"]);
                        string lang     = NullSafe(reader["preferredLanguage"]);

                        litMInitials.Text    = GetInitials(name);
                        litMName.Text        = HttpUtility.HtmlEncode(name);
                        litMUsername.Text     = HttpUtility.HtmlEncode(username);
                        litMEmail.Text       = HttpUtility.HtmlEncode(NullSafe(reader["email"]));
                        litMPhone.Text       = HttpUtility.HtmlEncode(NullSafe(reader["phoneNumber"]));
                        litMLevel.Text       = string.Format("<span class=\"sb-badge sb-badge-primary\">{0}</span>",
                                                HttpUtility.HtmlEncode(NullSafe(reader["levelName"])));
                        litMPersonality.Text = HttpUtility.HtmlEncode(NullSafe(reader["personalityName"]));
                        litMLangVal.Text     = lang == "BM" ? "Bahasa Melayu" : "English";
                        litMStatus.Text      = string.Format("<span class=\"sb-badge {0}\">{1}</span>",
                                                status == "Active" ? "sb-badge-success" : "sb-badge-error",
                                                HttpUtility.HtmlEncode(status == "Active" ? T("Active","Aktif") : T("Blocked","Disekat")));
                        litMXP.Text          = xp.ToString();
                        litMXPPct.Text       = pct.ToString();
                        litMLessons.Text     = reader["lessonsCompleted"].ToString();
                        litMBadges.Text      = reader["badgesEarned"].ToString();
                        litMQuizzes.Text     = reader["quizzesCompleted"].ToString();
                    }
                }
            }
            pnlModal.Visible = true;
        }

        protected void btnCloseModal_Click(object sender, EventArgs e)
        {
            pnlModal.Visible = false;
        }

        // ── Helpers ──────────────────────────────────────────────────
        private string SafeScalar(SqlConnection conn, string sql)
        {
            try
            {
                using (var cmd = new SqlCommand(sql, conn))
                {
                    var val = cmd.ExecuteScalar();
                    return (val != null && val != DBNull.Value) ? Convert.ToInt32(val).ToString() : "0";
                }
            }
            catch { return "0"; }
        }

        private static string NullSafe(object val)
        {
            return (val == null || val == DBNull.Value) ? "" : val.ToString();
        }

        private static string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "S";
            var parts = name.Trim().Split(' ');
            if (parts.Length >= 2)
                return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
            return name.Substring(0, Math.Min(2, name.Length)).ToUpper();
        }
    }
}
