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
    public partial class QuizManagement : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        protected string CurrentLanguage => ((ScienceBuddy.SiteMaster)Master).CurrentLanguage;
        protected string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null) { Response.Redirect("~/Login.aspx", false); return; }
            if (Session["role"] == null || Session["role"].ToString() != "Admin") { Response.Redirect("~/Login.aspx", false); return; }
            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            if (!IsPostBack) { SetMasterUser(); LoadDropdowns(); LoadStats(); LoadQuizzes("", "", "", ""); }
            txtSearch.Attributes["placeholder"] = T("Search quiz title...", "Cari tajuk kuiz...");
            btnSearch.Text = T("Search", "Cari"); btnReset.Text = T("Reset", "Tetapkan Semula");
            btnCloseModal.Text = T("Close", "Tutup");
        }

        private void SetMasterUser()
        {
            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                using (var cmd = new SqlCommand("SELECT [username] FROM dbo.[User] WHERE [userId]=@uid", conn))
                { cmd.Parameters.AddWithValue("@uid", Session["userId"].ToString());
                  var v = cmd.ExecuteScalar(); string n = v != null && v != DBNull.Value ? v.ToString() : "Admin";
                  ((ScienceBuddy.SiteMaster)Master).SetUserInfo(n, "Administrator", n.Length >= 2 ? n.Substring(0, 2).ToUpper() : n.ToUpper()); } }
        }

        private void LoadDropdowns()
        {
            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                string lCol = CurrentLanguage == "BM" ? "levelNameBM" : "levelNameEN";
                ddlLevel.Items.Clear(); ddlLevel.Items.Add(new ListItem(T("All Levels", "Semua Tahap"), ""));
                using (var cmd = new SqlCommand("SELECT [levelId],[levelNameEN],[levelNameBM] FROM dbo.[Level] ORDER BY [levelId]", conn))
                using (var rd = cmd.ExecuteReader()) { while (rd.Read()) ddlLevel.Items.Add(new ListItem(rd[lCol].ToString(), rd["levelId"].ToString())); }
            }
        }

        private void LoadStats()
        {
            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                litTotal.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[Quiz]");
                litUnit.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[Quiz] WHERE [quizType]='Unit'");
                litPractice.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[Quiz] WHERE [quizType]='Practice'");
                litAttempts.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[QuizResult]");
                litQuestions.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[Question]");
            }
        }

        private void LoadQuizzes(string search, string typeF, string levelF, string statusF)
        {
            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                string tCol = CurrentLanguage == "BM" ? "q.[quizTitleBM]" : "q.[quizTitleEN]";
                string lvCol = CurrentLanguage == "BM" ? "lv.[levelNameBM]" : "lv.[levelNameEN]";
                string sql = string.Format(@"SELECT q.[quizId], ISNULL({0},q.[quizTitleEN]) AS title, q.[quizType], q.[status],
                    ISNULL({1},'-') AS level,
                    (SELECT COUNT(*) FROM dbo.[Question] qn WHERE qn.[quizId]=q.[quizId]) AS questionCount,
                    (SELECT COUNT(*) FROM dbo.[QuizResult] qr WHERE qr.[quizId]=q.[quizId]) AS attemptCount
                    FROM dbo.[Quiz] q LEFT JOIN dbo.[Level] lv ON lv.[levelId]=q.[levelId]
                    WHERE 1=1", tCol, lvCol);
                if (!string.IsNullOrWhiteSpace(search)) sql += " AND (q.[quizTitleEN] LIKE @s OR q.[quizTitleBM] LIKE @s)";
                if (!string.IsNullOrWhiteSpace(typeF)) sql += " AND q.[quizType]=@tp";
                if (!string.IsNullOrWhiteSpace(levelF)) sql += " AND q.[levelId]=@lv";
                if (!string.IsNullOrWhiteSpace(statusF)) sql += " AND q.[status]=@st";
                sql += " ORDER BY q.[createdAt] DESC";

                using (var cmd = new SqlCommand(sql, conn)) {
                    if (!string.IsNullOrWhiteSpace(search)) cmd.Parameters.AddWithValue("@s", "%" + search + "%");
                    if (!string.IsNullOrWhiteSpace(typeF)) cmd.Parameters.AddWithValue("@tp", typeF);
                    if (!string.IsNullOrWhiteSpace(levelF)) cmd.Parameters.AddWithValue("@lv", levelF);
                    if (!string.IsNullOrWhiteSpace(statusF)) cmd.Parameters.AddWithValue("@st", statusF);
                    var da = new SqlDataAdapter(cmd); var dt = new DataTable(); da.Fill(dt);
                    if (dt.Rows.Count == 0) { pnlQuizzes.Visible = false; pnlEmpty.Visible = true; return; }
                    var list = new List<object>();
                    foreach (DataRow r in dt.Rows) {
                        string st = NS(r["status"]); string tp = NS(r["quizType"]);
                        list.Add(new { quizId = r["quizId"].ToString(), title = NS(r["title"]), quizType = tp, level = NS(r["level"]),
                            questionCount = r["questionCount"], attemptCount = r["attemptCount"],
                            statusLabel = st == "Approved" ? T("Approved","Diluluskan") : st == "Pending" ? T("Pending","Menunggu") : st == "Rejected" ? T("Rejected","Ditolak") : st,
                            statusCls = st == "Approved" ? "sb-badge-success" : st == "Pending" ? "sb-badge-warning" : st == "Rejected" ? "sb-badge-error" : "sb-badge-gray",
                            typeCls = tp == "Unit" ? "sb-badge-primary" : tp == "Level" ? "sb-badge-secondary" : "sb-badge-yellow" });
                    }
                    pnlQuizzes.Visible = true; pnlEmpty.Visible = false; rptQuizzes.DataSource = list; rptQuizzes.DataBind();
                }
            }
        }

        protected void rptQuizzes_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "ViewQuiz") return;
            string quizId = e.CommandArgument.ToString();
            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                // Quiz info
                string tCol = CurrentLanguage == "BM" ? "q.[quizTitleBM]" : "q.[quizTitleEN]";
                string lvCol = CurrentLanguage == "BM" ? "lv.[levelNameBM]" : "lv.[levelNameEN]";
                using (var cmd = new SqlCommand(string.Format(@"SELECT ISNULL({0},q.[quizTitleEN]) AS title, q.[quizType], q.[status], q.[language],
                    ISNULL({1},'-') AS level, ISNULL(u.[username],'Admin') AS creator
                    FROM dbo.[Quiz] q LEFT JOIN dbo.[Level] lv ON lv.[levelId]=q.[levelId]
                    LEFT JOIN dbo.[User] u ON u.[userId]=q.[createdByUserId] WHERE q.[quizId]=@id", tCol, lvCol), conn))
                { cmd.Parameters.AddWithValue("@id", quizId);
                    using (var rd = cmd.ExecuteReader()) { if (rd.Read()) {
                        litMTitle.Text = HttpUtility.HtmlEncode(NS(rd["title"]));
                        litMInfo.Text = HttpUtility.HtmlEncode(NS(rd["quizType"]) + " | " + NS(rd["level"]) + " | " + NS(rd["language"]) + " | " + NS(rd["creator"]));
                    } } }
                // Questions
                string qCol = CurrentLanguage == "BM" ? "questionTextBM" : "questionTextEN";
                string oACol = CurrentLanguage == "BM" ? "optionA_BM" : "optionA_EN";
                string oBCol = CurrentLanguage == "BM" ? "optionB_BM" : "optionB_EN";
                string oCCol = CurrentLanguage == "BM" ? "optionC_BM" : "optionC_EN";
                string oDCol = CurrentLanguage == "BM" ? "optionD_BM" : "optionD_EN";
                string sql2 = string.Format(@"SELECT ISNULL([{0}],[questionTextEN]) AS questionText,
                    ISNULL([{1}],[optionA_EN]) AS optA, ISNULL([{2}],[optionB_EN]) AS optB,
                    ISNULL([{3}],[optionC_EN]) AS optC, ISNULL([{4}],[optionD_EN]) AS optD,
                    [correctAnswer],[difficulty]
                    FROM dbo.[Question] WHERE [quizId]=@id ORDER BY [questionId]", qCol, oACol, oBCol, oCCol, oDCol);
                using (var cmd = new SqlCommand(sql2, conn)) { cmd.Parameters.AddWithValue("@id", quizId);
                    var da = new SqlDataAdapter(cmd); var dt = new DataTable(); da.Fill(dt);
                    litMQCount.Text = dt.Rows.Count.ToString();
                    if (dt.Rows.Count == 0) { pnlQuestions.Visible = false; pnlNoQuestions.Visible = true; }
                    else {
                        var list = new List<object>(); int i = 1;
                        foreach (DataRow r in dt.Rows) {
                            list.Add(new { num = i++, questionText = NS(r["questionText"]), optA = NS(r["optA"]),
                                optB = NS(r["optB"]), optC = NS(r["optC"]), optD = NS(r["optD"]),
                                correctAnswer = NS(r["correctAnswer"]), difficulty = NS(r["difficulty"]) });
                        }
                        pnlQuestions.Visible = true; pnlNoQuestions.Visible = false; rptQuestions.DataSource = list; rptQuestions.DataBind();
                    }
                }
            }
            pnlModal.Visible = true;
        }

        protected void btnCloseModal_Click(object sender, EventArgs e) { pnlModal.Visible = false; }
        protected void btnSearch_Click(object sender, EventArgs e) { LoadQuizzes(txtSearch.Text.Trim(), ddlType.SelectedValue, ddlLevel.SelectedValue, ddlStatus.SelectedValue); }
        protected void btnReset_Click(object sender, EventArgs e) { txtSearch.Text = ""; ddlType.SelectedIndex = 0; ddlLevel.SelectedIndex = 0; ddlStatus.SelectedIndex = 0; LoadQuizzes("", "", "", ""); }

        private string SS(SqlConnection c, string sql) { try { using (var cmd = new SqlCommand(sql, c)) { var v = cmd.ExecuteScalar(); return v != null && v != DBNull.Value ? Convert.ToInt32(v).ToString() : "0"; } } catch { return "0"; } }
        private static string NS(object v) { return (v == null || v == DBNull.Value) ? "" : v.ToString(); }
    }
}
