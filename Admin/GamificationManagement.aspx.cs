using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

// Admin GamificationManagement - Code Behind

namespace ScienceBuddy.Admin
{
    public partial class GamificationManagement : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected string CurrentLanguage => ((ScienceBuddy.SiteMaster)Master).CurrentLanguage;

        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        // --- Page Lifecycle ---

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null)
            { Response.Redirect("~/Login.aspx", false); return; }
            if (Session["role"] == null || Session["role"].ToString() != "Admin")
            { Response.Redirect("~/Login.aspx", false); return; }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                SetMasterUser();
                ShowTab("overview");
            }
        }

        // --- Tab Handlers ---

        protected void tabOverview_Click(object sender, EventArgs e) { ShowTab("overview"); }
        protected void tabXP_Click(object sender, EventArgs e) { ShowTab("xp"); }
        protected void tabBadges_Click(object sender, EventArgs e) { ShowTab("badges"); }
        protected void tabStudents_Click(object sender, EventArgs e) { ShowTab("students"); }

        private void ShowTab(string tab)
        {
            // Toggle panel visibility
            pnlOverview.Visible = (tab == "overview");
            pnlXPTab.Visible = (tab == "xp");
            pnlBadgesTab.Visible = (tab == "badges");
            pnlStudentsTab.Visible = (tab == "students");

            // Highlight active tab
            tabOverview.CssClass = tab == "overview" ? "sb-btn sb-btn-primary sb-btn-sm" : "sb-btn sb-btn-ghost sb-btn-sm";
            tabXP.CssClass = tab == "xp" ? "sb-btn sb-btn-primary sb-btn-sm" : "sb-btn sb-btn-ghost sb-btn-sm";
            tabBadges.CssClass = tab == "badges" ? "sb-btn sb-btn-primary sb-btn-sm" : "sb-btn sb-btn-ghost sb-btn-sm";
            tabStudents.CssClass = tab == "students" ? "sb-btn sb-btn-primary sb-btn-sm" : "sb-btn sb-btn-ghost sb-btn-sm";

            // Load data for active tab
            if (tab == "overview")
            {
                LoadStats();
                LoadXPActions();
                LoadLeaderboard();
            }
            else if (tab == "xp")
            {
                LoadXPActions();
                rptXPTab.DataSource = rptXPActions.DataSource;
                rptXPTab.DataBind();
            }
            else if (tab == "badges")
            {
                LoadBadges();
            }
            else if (tab == "students")
            {
                LoadStudentRewards();
            }
        }

        // --- Data Loading ---

        private void SetMasterUser()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [username] FROM dbo.[User] WHERE [userId]=@uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", Session["userId"].ToString());
                    var result = cmd.ExecuteScalar();
                    string name = result != null && result != DBNull.Value ? result.ToString() : "Admin";
                    string initials = name.Length >= 2 ? name.Substring(0, 2).ToUpper() : name.ToUpper();
                    ((ScienceBuddy.SiteMaster)Master).SetUserInfo(name, "Administrator", initials);
                }
            }
        }

        private void LoadStats()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                litRules.Text = SafeScalar(conn, "SELECT COUNT(*) FROM dbo.[XPAction]");
                litTotalXP.Text = SafeScalar(conn, "SELECT ISNULL(SUM([xpAmount]),0) FROM dbo.[XPTransaction]");
                litCerts.Text = SafeScalar(conn, "SELECT COUNT(*) FROM dbo.[Certificate]");
                litActiveStudents.Text = SafeScalar(conn, "SELECT COUNT(DISTINCT [studentId]) FROM dbo.[XPTransaction]");
            }
        }

        private void LoadXPActions()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(@"SELECT xa.[xpActionId], xa.[actionNameEN], xa.[actionNameBM], xa.[xpValue],
                    (SELECT COUNT(*) FROM dbo.[XPTransaction] xt WHERE xt.[xpActionId]=xa.[xpActionId]) AS earnedCount
                    FROM dbo.[XPAction] xa ORDER BY xa.[xpValue] DESC", conn))
                {
                    var da = new SqlDataAdapter(cmd);
                    var dt = new DataTable();
                    da.Fill(dt);

                    string[] icons = { "bi bi-book-fill", "bi bi-patch-check-fill", "bi bi-trophy-fill", "bi bi-star-fill", "bi bi-lightning-fill", "bi bi-mortarboard-fill", "bi bi-chat-dots-fill", "bi bi-eyedropper", "bi bi-award-fill" };
                    string[] styles = { "background:#DBEAFE;color:#2563EB;", "background:#FEF3C7;color:#D97706;", "background:#ECFDF5;color:#059669;", "background:#F3E8FF;color:#7C3AED;", "background:#FEE2E2;color:#DC2626;", "background:#E0F2FE;color:#0891B2;", "background:#FFF7ED;color:#EA580C;", "background:#F0FDF4;color:#16A34A;", "background:#FDF2F8;color:#DB2777;" };

                    var list = new List<object>();
                    int idx = 0;
                    foreach (DataRow row in dt.Rows)
                    {
                        list.Add(new
                        {
                            nameEN = NullSafe(row["actionNameEN"]),
                            nameBM = NullSafe(row["actionNameBM"]),
                            xpValue = row["xpValue"],
                            earnedCount = row["earnedCount"],
                            icoClass = icons[idx % icons.Length],
                            icoStyle = styles[idx % styles.Length]
                        });
                        idx++;
                    }
                    rptXPActions.DataSource = list;
                    rptXPActions.DataBind();
                }
            }
        }

        private void LoadBadges()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(@"SELECT b.[badgeId],b.[badgeNameEN],b.[badgeNameBM],b.[badgeType],ISNULL(b.[xpReward],0) AS xpReward,
                    (SELECT COUNT(*) FROM dbo.[StudentBadge] sb WHERE sb.[badgeId]=b.[badgeId]) AS earnedCount
                    FROM dbo.[Badge] b ORDER BY b.[badgeId]", conn))
                {
                    var da = new System.Data.SqlClient.SqlDataAdapter(cmd);
                    var dt = new DataTable();
                    da.Fill(dt);

                    var list = new System.Collections.Generic.List<object>();
                    foreach (DataRow row in dt.Rows)
                    {
                        list.Add(new
                        {
                            nameEN = NullSafe(row["badgeNameEN"]),
                            nameBM = NullSafe(row["badgeNameBM"]),
                            badgeType = NullSafe(row["badgeType"]),
                            xpReward = row["xpReward"],
                            earnedCount = row["earnedCount"]
                        });
                    }
                    rptBadges.DataSource = list;
                    rptBadges.DataBind();
                }
            }
        }

        private void LoadStudentRewards()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(@"SELECT TOP 15 s.[name], ISNULL(s.[XP],0) AS totalXP,
                    (SELECT COUNT(*) FROM dbo.[StudentBadge] sb WHERE sb.[studentId]=s.[studentId]) AS badgeCount,
                    (SELECT COUNT(*) FROM dbo.[LessonProgress] lp WHERE lp.[studentId]=s.[studentId] AND lp.[isCompleted]=1) AS lessonsCompleted
                    FROM dbo.[Student] s ORDER BY s.[XP] DESC", conn))
                {
                    var da = new System.Data.SqlClient.SqlDataAdapter(cmd);
                    var dt = new DataTable();
                    da.Fill(dt);

                    var list = new System.Collections.Generic.List<object>();
                    int rank = 1;
                    foreach (DataRow row in dt.Rows)
                    {
                        string rankCls = rank == 1 ? "r1" : rank == 2 ? "r2" : rank == 3 ? "r3" : "rn";
                        list.Add(new
                        {
                            rank = rank,
                            rankCls = rankCls,
                            studentName = NullSafe(row["name"]),
                            totalXP = row["totalXP"],
                            badgeCount = row["badgeCount"],
                            lessonsCompleted = row["lessonsCompleted"]
                        });
                        rank++;
                    }
                    rptStudentRewards.DataSource = list;
                    rptStudentRewards.DataBind();
                }
            }
        }

        private void LoadLeaderboard()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(@"SELECT TOP 10 s.[name], SUM(xt.[xpAmount]) AS totalXP
                    FROM dbo.[XPTransaction] xt
                    JOIN dbo.[Student] s ON s.[studentId]=xt.[studentId]
                    GROUP BY s.[name] ORDER BY totalXP DESC, MIN(xt.[dateEarned]) ASC", conn))
                {
                    var da = new SqlDataAdapter(cmd);
                    var dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count == 0)
                    {
                        pnlLeaderboard.Visible = false;
                        pnlNoLeaderboard.Visible = true;
                        return;
                    }

                    pnlLeaderboard.Visible = true;
                    pnlNoLeaderboard.Visible = false;

                    // Build podium for top 3
                    string podiumHtml = "";
                    string[] medals = { "&#x1F947;", "&#x1F948;", "&#x1F949;" };
                    string[] labels = { T("1st Place", "Tempat Ke-1"), T("2nd Place", "Tempat Ke-2"), T("3rd Place", "Tempat Ke-3") };
                    string[] avatarColors = { "linear-gradient(135deg,#F59E0B,#D97706)", "linear-gradient(135deg,#94A3B8,#64748B)", "linear-gradient(135deg,#92400E,#B45309)" };
                    string[] blockCss = { "ad-student-performance-podium-1st", "ad-student-performance-podium-2nd", "ad-student-performance-podium-3rd" };

                    var podiumItems = new string[3];
                    for (int i = 0; i < Math.Min(3, dt.Rows.Count); i++)
                    {
                        string name = NullSafe(dt.Rows[i]["name"]);
                        string xp = dt.Rows[i]["totalXP"].ToString();
                        string initials = name.Length >= 2 ? name.Substring(0, 2).ToUpper() : name.ToUpper();

                        podiumItems[i] = string.Format(
                            "<div class=\"ad-student-performance-podium-item {0}\">" +
                            "<div class=\"ad-student-performance-podium-block\">" +
                            "<div class=\"ad-student-performance-podium-medal\">{1}</div>" +
                            "<div class=\"ad-student-performance-podium-avatar\" style=\"background:{2};\">{3}</div>" +
                            "<div class=\"ad-student-performance-podium-name\">{4}</div>" +
                            "<div class=\"ad-student-performance-podium-xp\">{5} XP</div>" +
                            "</div>" +
                            "<div class=\"ad-student-performance-podium-label\">{6}</div>" +
                            "</div>",
                            blockCss[i], medals[i], avatarColors[i], HttpUtility.HtmlEncode(initials),
                            HttpUtility.HtmlEncode(name), xp, labels[i]);
                    }

                    // Display order: 2nd | 1st | 3rd (center = winner)
                    if (dt.Rows.Count >= 3)
                        podiumHtml = podiumItems[1] + podiumItems[0] + podiumItems[2];
                    else if (dt.Rows.Count == 2)
                        podiumHtml = podiumItems[1] + podiumItems[0];
                    else if (dt.Rows.Count == 1)
                        podiumHtml = podiumItems[0];

                    litPodium.Text = podiumHtml;

                    // Rankings 4+
                    if (dt.Rows.Count > 3)
                    {
                        pnlRankings.Visible = true;
                        var list = new List<object>();
                        string[] bgColors = { "#6366F1", "#0EA5E9", "#8B5CF6", "#059669", "#D97706", "#DC2626", "#EC4899" };

                        for (int i = 3; i < dt.Rows.Count; i++)
                        {
                            string name = NullSafe(dt.Rows[i]["name"]);
                            string initials = name.Length >= 2 ? name.Substring(0, 2).ToUpper() : name.ToUpper();
                            list.Add(new
                            {
                                rank = i + 1,
                                studentName = name,
                                totalXP = dt.Rows[i]["totalXP"].ToString(),
                                initials = initials,
                                avatarBg = bgColors[(i - 3) % bgColors.Length]
                            });
                        }
                        rptLeaderboard.DataSource = list;
                        rptLeaderboard.DataBind();
                    }
                    else
                    {
                        pnlRankings.Visible = false;
                    }
                }
            }
        }

        // --- Helpers ---

        private string SafeScalar(SqlConnection conn, string sql)
        {
            try
            {
                using (var cmd = new SqlCommand(sql, conn))
                {
                    var result = cmd.ExecuteScalar();
                    return result != null && result != DBNull.Value ? Convert.ToInt32(result).ToString() : "0";
                }
            }
            catch { return "0"; }
        }

        private static string NullSafe(object val)
        {
            return (val == null || val == DBNull.Value) ? "" : val.ToString();
        }
    }
}
