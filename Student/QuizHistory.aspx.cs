using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Student
{
    public partial class QuizHistory : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        public string CurrentLanguage = "EN";
        public string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null || Session["role"].ToString() != "Student")
            { Response.Redirect("~/Login.aspx", false); return; }
            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            InitLang();
            if (!IsPostBack) { BuildFilters(); LoadData(); }
        }

        private void InitLang()
        {
            string lang = Session["preferredLanguage"] as string;
            if (!string.IsNullOrEmpty(lang)) { CurrentLanguage = lang; return; }
            string uid = Session["userId"] as string;
            if (!string.IsNullOrEmpty(uid))
            {
                try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT preferredLanguage FROM [User] WHERE userId=@u", c))
                { cmd.Parameters.AddWithValue("@u", uid); c.Open(); object r = cmd.ExecuteScalar();
                  if (r != null && r != DBNull.Value) { lang = r.ToString(); Session["preferredLanguage"] = lang; CurrentLanguage = lang; return; } } } catch { }
            }
            CurrentLanguage = "EN"; Session["preferredLanguage"] = "EN";
        }

        private void SetLabels()
        {
            litPageTitle.Text = T("Quiz History", "Sejarah Kuiz");
            litTitle.Text = T("Quiz History", "Sejarah Kuiz");
            litSubtitle.Text = T("View your past quiz attempts, scores, and reviews.", "Lihat percubaan kuiz, skor, dan semakan jawapan anda.");
            litStatTotalLbl.Text = T("Total Attempts", "Jumlah Percubaan");
            litStatPassedLbl.Text = T("Passed", "Lulus");
            litStatBestLbl.Text = T("Best Score", "Skor Terbaik");
            litStatLatestLbl.Text = T("Latest", "Terkini");
            litFType.Text = T("Type", "Jenis"); litFStatus.Text = T("Status", "Status");
            litFSort.Text = T("Sort", "Susun"); litFSearch.Text = T("Search", "Cari");
            btnFilter.Text = T("Filter", "Tapis");
            litEmptyTitle.Text = T("No Quiz Attempts Yet", "Belum Ada Percubaan Kuiz");
            litEmptyDesc.Text = T("You have not attempted any quizzes yet. Try a practice quiz to begin!", "Anda belum menjawab sebarang kuiz. Cuba kuiz latihan untuk bermula!");
            litEmptyBtn.Text = T("Go to Practice Library", "Pergi ke Perpustakaan Latihan");
            litBackToPractice.Text = T("Back to Practice Library", "Kembali ke Perpustakaan Latihan");
            txtSearch.Attributes["placeholder"] = T("Search quiz title...", "Cari tajuk kuiz...");
        }

        private void BuildFilters()
        {
            ddlType.Items.Clear();
            ddlType.Items.Add(new ListItem(T("All Types", "Semua Jenis"), ""));
            ddlType.Items.Add(new ListItem(T("Practice", "Latihan"), "Practice"));
            ddlType.Items.Add(new ListItem(T("Unit", "Unit"), "Unit"));
            ddlType.Items.Add(new ListItem(T("Level", "Tahap"), "Level"));

            ddlStatus.Items.Clear();
            ddlStatus.Items.Add(new ListItem(T("All Status", "Semua Status"), ""));
            ddlStatus.Items.Add(new ListItem(T("Passed", "Lulus"), "Passed"));
            ddlStatus.Items.Add(new ListItem(T("Failed", "Gagal"), "Failed"));

            ddlSort.Items.Clear();
            ddlSort.Items.Add(new ListItem(T("Latest First", "Terkini Dahulu"), "latest"));
            ddlSort.Items.Add(new ListItem(T("Highest Score", "Skor Tertinggi"), "highest"));
            ddlSort.Items.Add(new ListItem(T("Lowest Score", "Skor Terendah"), "lowest"));
        }

        protected void ddlFilter_Changed(object sender, EventArgs e) { LoadData(); }
        protected void btnFilter_Click(object sender, EventArgs e) { LoadData(); }

        private void LoadData()
        {
            SetLabels();
            string userId = Session["userId"].ToString();
            bool isBM = CurrentLanguage == "BM";

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                // Get studentId
                string studentId = null;
                using (var cmd = new SqlCommand("SELECT studentId FROM Student WHERE userId=@u", conn))
                { cmd.Parameters.AddWithValue("@u", userId); object r = cmd.ExecuteScalar();
                  if (r != null && r != DBNull.Value) studentId = r.ToString(); }
                if (string.IsNullOrEmpty(studentId)) { ShowEmpty(); return; }

                // Build query
                string sql = @"SELECT qr.resultId, qr.quizId, qr.score, qr.totalMarks, qr.percentage,
                    qr.resultStatus, qr.attemptNo, qr.attemptedDate,
                    q.quizTitleEN, q.quizTitleBM, q.quizType,
                    lv.levelNameEN, lv.levelNameBM, u.unitNameEN, u.unitNameBM
                    FROM QuizResult qr
                    JOIN Quiz q ON q.quizId = qr.quizId
                    LEFT JOIN Level lv ON lv.levelId = q.levelId
                    LEFT JOIN Unit u ON u.unitId = q.unitId
                    WHERE qr.studentId = @sid";

                string filterType = ddlType.SelectedValue;
                string filterStatus = ddlStatus.SelectedValue;
                string search = txtSearch.Text.Trim();

                if (!string.IsNullOrEmpty(filterType)) sql += " AND q.quizType = @qtype";
                if (!string.IsNullOrEmpty(filterStatus)) sql += " AND qr.resultStatus = @rstatus";
                if (!string.IsNullOrEmpty(search)) sql += " AND (q.quizTitleEN LIKE @search OR q.quizTitleBM LIKE @search)";

                string sort = ddlSort.SelectedValue;
                switch (sort)
                {
                    case "highest": sql += " ORDER BY qr.percentage DESC"; break;
                    case "lowest": sql += " ORDER BY qr.percentage ASC"; break;
                    default: sql += " ORDER BY qr.attemptedDate DESC"; break;
                }

                var dt = new DataTable();
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@sid", studentId);
                    if (!string.IsNullOrEmpty(filterType)) cmd.Parameters.AddWithValue("@qtype", filterType);
                    if (!string.IsNullOrEmpty(filterStatus)) cmd.Parameters.AddWithValue("@rstatus", filterStatus);
                    if (!string.IsNullOrEmpty(search)) cmd.Parameters.AddWithValue("@search", "%" + search + "%");
                    new SqlDataAdapter(cmd).Fill(dt);
                }

                if (dt.Rows.Count == 0) { ShowEmpty(); return; }

                // Stats
                int totalAttempts = dt.Rows.Count;
                int passedCount = 0; decimal bestPct = 0; DateTime latestDate = DateTime.MinValue;
                foreach (DataRow row in dt.Rows)
                {
                    if (row["resultStatus"] != DBNull.Value && row["resultStatus"].ToString() == "Passed") passedCount++;
                    decimal pct = row["percentage"] != DBNull.Value ? Convert.ToDecimal(row["percentage"]) : 0;
                    if (pct > bestPct) bestPct = pct;
                    DateTime d = row["attemptedDate"] != DBNull.Value ? Convert.ToDateTime(row["attemptedDate"]) : DateTime.MinValue;
                    if (d > latestDate) latestDate = d;
                }
                litStatTotal.Text = totalAttempts.ToString();
                litStatPassed.Text = passedCount.ToString();
                litStatBest.Text = Math.Round(bestPct, 0) + "%";
                litStatLatest.Text = latestDate > DateTime.MinValue ? latestDate.ToString("d MMM") : "-";

                // Build list
                var items = new List<object>();
                foreach (DataRow row in dt.Rows)
                {
                    string resultId = row["resultId"].ToString();
                    string quizId = row["quizId"].ToString();
                    string title = isBM ? Sv(row, "quizTitleBM") : Sv(row, "quizTitleEN");
                    if (string.IsNullOrWhiteSpace(title)) title = Sv(row, "quizTitleEN");
                    string quizType = Sv(row, "quizType");
                    string status = Sv(row, "resultStatus");
                    decimal pct = row["percentage"] != DBNull.Value ? Convert.ToDecimal(row["percentage"]) : 0;
                    decimal score = row["score"] != DBNull.Value ? Convert.ToDecimal(row["score"]) : 0;
                    decimal total = row["totalMarks"] != DBNull.Value ? Convert.ToDecimal(row["totalMarks"]) : 0;
                    int att = row["attemptNo"] != DBNull.Value ? Convert.ToInt32(row["attemptNo"]) : 1;
                    DateTime date = row["attemptedDate"] != DBNull.Value ? Convert.ToDateTime(row["attemptedDate"]) : DateTime.Now;

                    bool passed = status == "Passed";
                    string typeBadge = quizType == "Practice" ? "qh-badge-practice" : quizType == "Unit" ? "qh-badge-unit" : "qh-badge-level";
                    string typeLabel = quizType == "Practice" ? T("Practice", "Latihan") : quizType == "Unit" ? T("Unit", "Unit") : T("Level", "Tahap");

                    items.Add(new {
                        QuizTitle = HttpUtility.HtmlEncode(title),
                        PctDisplay = Math.Round(pct, 0) + "%",
                        ScoreDisplay = score + "/" + total,
                        StatusClass = passed ? "passed" : "failed",
                        TypeBadgeClass = typeBadge,
                        TypeLabel = typeLabel,
                        StatusBadgeClass = passed ? "qh-badge-passed" : "qh-badge-failed",
                        StatusLabel = passed ? T("Passed", "Lulus") : T("Failed", "Gagal"),
                        AttemptNo = att,
                        DateDisplay = date.ToString("d MMM yyyy"),
                        ResultUrl = ResolveUrl("~/Student/QuizResult.aspx?resultId=" + resultId),
                        ReviewUrl = ResolveUrl("~/Student/QuizReview.aspx?resultId=" + resultId),
                        RetryUrl = ResolveUrl("~/Student/Quiz.aspx?quizId=" + quizId),
                        ViewLbl = T("Result", "Keputusan"),
                        ReviewLbl = T("Review", "Semakan"),
                        RetryLbl = T("Retry", "Cuba Lagi")
                    });
                }

                pnlList.Visible = true; pnlEmpty.Visible = false;
                rptHistory.DataSource = items; rptHistory.DataBind();
            }
        }

        private void ShowEmpty() { pnlList.Visible = false; pnlEmpty.Visible = true; }
        private static string Sv(DataRow r, string c) { return r[c] != null && r[c] != DBNull.Value ? r[c].ToString() : ""; }
    }
}
