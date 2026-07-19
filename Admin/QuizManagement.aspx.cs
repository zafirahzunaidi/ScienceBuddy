using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

// Admin QuizManagement - Code Behind

namespace ScienceBuddy.Admin
{
    public partial class QuizManagement : Page
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
                LoadDropdowns();
                LoadStats();
                LoadQuizzes("", "", "", "");
            }

            txtSearch.Attributes["placeholder"] = T("Search quiz title...", "Cari tajuk kuiz...");
            btnSearch.Text = T("Search", "Cari");
            btnReset.Text = T("Reset", "Tetapkan Semula");
            btnCloseModal.Text = T("Close", "Tutup");
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

        private void LoadDropdowns()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                string levelCol = CurrentLanguage == "BM" ? "levelNameBM" : "levelNameEN";
                ddlLevel.Items.Clear();
                ddlLevel.Items.Add(new ListItem(T("All Levels", "Semua Tahap"), ""));

                using (var cmd = new SqlCommand("SELECT [levelId],[levelNameEN],[levelNameBM] FROM dbo.[Level] ORDER BY [levelId]", conn))
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                        ddlLevel.Items.Add(new ListItem(reader[levelCol].ToString(), reader["levelId"].ToString()));
                }
            }
        }

        private void LoadStats()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                litTotal.Text = SafeScalar(conn, "SELECT COUNT(*) FROM dbo.[Quiz]");
                litUnit.Text = SafeScalar(conn, "SELECT COUNT(*) FROM dbo.[Quiz] WHERE [quizType]='Unit'");
                litPractice.Text = SafeScalar(conn, "SELECT COUNT(*) FROM dbo.[Quiz] WHERE [quizType]='Practice'");
                litAttempts.Text = SafeScalar(conn, "SELECT COUNT(*) FROM dbo.[QuizResult]");
                litQuestions.Text = SafeScalar(conn, "SELECT COUNT(*) FROM dbo.[Question]");
            }
        }

        private void LoadQuizzes(string search, string typeFilter, string levelFilter, string statusFilter)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                string titleCol = CurrentLanguage == "BM" ? "ISNULL(q.[quizTitleBM],q.[quizTitleEN])" : "ISNULL(q.[quizTitleEN],q.[quizTitleBM])";
                string lvlCol = CurrentLanguage == "BM" ? "lv.[levelNameBM]" : "lv.[levelNameEN]";

                string sql = string.Format(@"SELECT q.[quizId], {0} AS title, q.[quizType], q.[status],
                    ISNULL({1},'-') AS level,
                    (SELECT COUNT(*) FROM dbo.[Question] qn WHERE qn.[quizId]=q.[quizId]) AS questionCount,
                    (SELECT COUNT(*) FROM dbo.[QuizResult] qr WHERE qr.[quizId]=q.[quizId]) AS attemptCount
                    FROM dbo.[Quiz] q LEFT JOIN dbo.[Level] lv ON lv.[levelId]=q.[levelId]
                    WHERE 1=1", titleCol, lvlCol);

                if (!string.IsNullOrWhiteSpace(search))
                    sql += " AND (q.[quizTitleEN] LIKE @s OR q.[quizTitleBM] LIKE @s)";
                if (!string.IsNullOrWhiteSpace(typeFilter))
                    sql += " AND q.[quizType]=@tp";
                if (!string.IsNullOrWhiteSpace(levelFilter))
                    sql += " AND q.[levelId]=@lv";
                if (!string.IsNullOrWhiteSpace(statusFilter))
                    sql += " AND q.[status]=@st";
                sql += " ORDER BY q.[createdAt] DESC";

                using (var cmd = new SqlCommand(sql, conn))
                {
                    if (!string.IsNullOrWhiteSpace(search))
                        cmd.Parameters.AddWithValue("@s", "%" + search + "%");
                    if (!string.IsNullOrWhiteSpace(typeFilter))
                        cmd.Parameters.AddWithValue("@tp", typeFilter);
                    if (!string.IsNullOrWhiteSpace(levelFilter))
                        cmd.Parameters.AddWithValue("@lv", levelFilter);
                    if (!string.IsNullOrWhiteSpace(statusFilter))
                        cmd.Parameters.AddWithValue("@st", statusFilter);

                    var da = new SqlDataAdapter(cmd);
                    var dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count == 0)
                    {
                        pnlQuizzes.Visible = false;
                        pnlEmpty.Visible = true;
                        return;
                    }

                    var list = new List<object>();
                    foreach (DataRow row in dt.Rows)
                    {
                        string status = NullSafe(row["status"]);
                        string quizType = NullSafe(row["quizType"]);

                        list.Add(new
                        {
                            quizId = row["quizId"].ToString(),
                            title = NullSafe(row["title"]),
                            quizType = quizType,
                            level = NullSafe(row["level"]),
                            questionCount = row["questionCount"],
                            attemptCount = row["attemptCount"],
                            statusLabel = status == "Approved" ? T("Approved", "Diluluskan") : status == "Pending" ? T("Pending", "Menunggu") : status == "Rejected" ? T("Rejected", "Ditolak") : status,
                            statusCls = status == "Approved" ? "sb-badge-success" : status == "Pending" ? "sb-badge-warning" : status == "Rejected" ? "sb-badge-error" : "sb-badge-gray",
                            typeCls = quizType == "Unit" ? "sb-badge-primary" : quizType == "Level" ? "sb-badge-secondary" : "sb-badge-yellow"
                        });
                    }

                    pnlQuizzes.Visible = true;
                    pnlEmpty.Visible = false;
                    rptQuizzes.DataSource = list;
                    rptQuizzes.DataBind();
                }
            }
        }

        // --- Event Handlers ---

        protected void rptQuizzes_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "ViewQuiz") return;

            string quizId = e.CommandArgument.ToString();

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Quiz info
                string titleCol = CurrentLanguage == "BM" ? "ISNULL(q.[quizTitleBM],q.[quizTitleEN])" : "ISNULL(q.[quizTitleEN],q.[quizTitleBM])";
                string lvlCol = CurrentLanguage == "BM" ? "lv.[levelNameBM]" : "lv.[levelNameEN]";

                using (var cmd = new SqlCommand(string.Format(@"SELECT {0} AS title, q.[quizType], q.[status], q.[language],
                    ISNULL({1},'-') AS level, ISNULL(u.[username],'Admin') AS creator
                    FROM dbo.[Quiz] q LEFT JOIN dbo.[Level] lv ON lv.[levelId]=q.[levelId]
                    LEFT JOIN dbo.[User] u ON u.[userId]=q.[createdByUserId] WHERE q.[quizId]=@id", titleCol, lvlCol), conn))
                {
                    cmd.Parameters.AddWithValue("@id", quizId);
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            litMTitle.Text = HttpUtility.HtmlEncode(NullSafe(reader["title"]));
                            litMInfo.Text = HttpUtility.HtmlEncode(NullSafe(reader["quizType"]) + " | " + NullSafe(reader["level"]) + " | " + NullSafe(reader["language"]) + " | " + NullSafe(reader["creator"]));
                        }
                    }
                }

                // Questions
                string qCol = CurrentLanguage == "BM" ? "questionTextBM" : "questionTextEN";
                string qFallback = CurrentLanguage == "BM" ? "questionTextEN" : "questionTextBM";
                string oACol = CurrentLanguage == "BM" ? "optionA_BM" : "optionA_EN";
                string oAFb = CurrentLanguage == "BM" ? "optionA_EN" : "optionA_BM";
                string oBCol = CurrentLanguage == "BM" ? "optionB_BM" : "optionB_EN";
                string oBFb = CurrentLanguage == "BM" ? "optionB_EN" : "optionB_BM";
                string oCCol = CurrentLanguage == "BM" ? "optionC_BM" : "optionC_EN";
                string oCFb = CurrentLanguage == "BM" ? "optionC_EN" : "optionC_BM";
                string oDCol = CurrentLanguage == "BM" ? "optionD_BM" : "optionD_EN";
                string oDFb = CurrentLanguage == "BM" ? "optionD_EN" : "optionD_BM";

                string questionSql = string.Format(@"SELECT ISNULL([{0}],[{5}]) AS questionText,
                    ISNULL([{1}],[{6}]) AS optA, ISNULL([{2}],[{7}]) AS optB,
                    ISNULL([{3}],[{8}]) AS optC, ISNULL([{4}],[{9}]) AS optD,
                    [correctAnswer],[difficulty],[questionType]
                    FROM dbo.[Question] WHERE [quizId]=@id ORDER BY [questionId]", qCol, oACol, oBCol, oCCol, oDCol, qFallback, oAFb, oBFb, oCFb, oDFb);

                using (var cmd = new SqlCommand(questionSql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", quizId);
                    var da = new SqlDataAdapter(cmd);
                    var dt = new DataTable();
                    da.Fill(dt);

                    litMQCount.Text = dt.Rows.Count.ToString();

                    if (dt.Rows.Count == 0)
                    {
                        pnlQuestions.Visible = false;
                        pnlNoQuestions.Visible = true;
                    }
                    else
                    {
                        var list = new List<object>();
                        int num = 1;
                        foreach (DataRow row in dt.Rows)
                        {
                            list.Add(new
                            {
                                num = num++,
                                questionText = NullSafe(row["questionText"]),
                                optA = NullSafe(row["optA"]),
                                optB = NullSafe(row["optB"]),
                                optC = NullSafe(row["optC"]),
                                optD = NullSafe(row["optD"]),
                                correctAnswer = NullSafe(row["correctAnswer"]),
                                difficulty = NullSafe(row["difficulty"]),
                                questionType = NullSafe(row["questionType"]),
                                isDragDrop = NullSafe(row["questionType"]).IndexOf("Drag", StringComparison.OrdinalIgnoreCase) >= 0,
                                isFillBlank = NullSafe(row["questionType"]).IndexOf("Fill", StringComparison.OrdinalIgnoreCase) >= 0
                            });
                        }
                        pnlQuestions.Visible = true;
                        pnlNoQuestions.Visible = false;
                        rptQuestions.DataSource = list;
                        rptQuestions.DataBind();
                    }
                }
            }
            pnlModal.Visible = true;
        }

        protected void btnCloseModal_Click(object sender, EventArgs e)
        {
            pnlModal.Visible = false;
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadQuizzes(txtSearch.Text.Trim(), ddlType.SelectedValue, ddlLevel.SelectedValue, ddlStatus.SelectedValue);
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlType.SelectedIndex = 0;
            ddlLevel.SelectedIndex = 0;
            ddlStatus.SelectedIndex = 0;
            LoadQuizzes("", "", "", "");
        }

        // --- Helpers ---

        protected string HideIf(bool condition) { return condition ? "display:none;" : ""; }
        protected string ShowIf(bool condition, string style) { return condition ? style : "display:none;"; }

        protected string FormatDragDropAnswer(string answer)
        {
            if (string.IsNullOrWhiteSpace(answer)) return "<span style='color:#94A3B8;'>-</span>";
            string[] parts = answer.Split(',');
            string[] colors = { "#7C3AED", "#2563EB", "#059669", "#D97706", "#DC2626", "#0891B2" };
            var sb = new System.Text.StringBuilder();
            for (int i = 0; i < parts.Length; i++)
            {
                string color = colors[i % colors.Length];
                if (i > 0)
                    sb.Append("<div style=\"text-align:center;padding:2px 0;color:#94A3B8;font-size:.7rem;\"><i class=\"bi bi-arrow-down\"></i></div>");
                sb.AppendFormat(
                    "<div style=\"display:flex;align-items:center;gap:10px;padding:8px 14px;background:#F8FAFC;border:1px solid #E2E8F0;border-radius:10px;\">" +
                    "<span style=\"display:inline-flex;align-items:center;justify-content:center;width:26px;height:26px;border-radius:50%;background:{0};color:#fff;font-size:.75rem;font-weight:700;flex-shrink:0;\">{1}</span>" +
                    "<span style=\"font-size:.875rem;font-weight:600;color:#1E293B;\">{2}</span></div>",
                    color, i + 1, HttpUtility.HtmlEncode(parts[i].Trim()));
            }
            return sb.ToString();
        }

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

        protected string GetQuestionOptionsStyle(bool isDragDrop, bool isFillBlank)
        {
            return (isDragDrop || isFillBlank)
                ? "display:none;"
                : "";
        }

        protected string GetFillBlankStyle(bool isFillBlank)
        {
            return isFillBlank
                ? "padding:12px 16px;margin-top:8px;background:#D1FAE5;border:1px solid #6EE7B7;border-radius:10px;"
                : "display:none;";
        }

        protected string GetDragDropStyle(bool isDragDrop)
        {
            return isDragDrop
                ? "padding:14px 16px;margin-top:10px;background:#EFF6FF;border:1px solid #BFDBFE;border-radius:12px;"
                : "display:none;";
        }

        private static string NullSafe(object val)
        {
            return (val == null || val == DBNull.Value) ? "" : val.ToString();
        }
    }
}
