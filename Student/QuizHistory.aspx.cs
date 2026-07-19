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
    public partial class QuizHistory1 : Page
    {
        private string ConnectionString
        {
            get { return ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString; }
        }

        public string CurrentLanguage = "EN";

        public string T(string en, string bm)
        {
            if (CurrentLanguage == "BM")
            {
                return bm;
            }
            return en;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null || Session["role"].ToString() != "Student")
            {
                Response.Redirect("~/Login.aspx", false);
                return;
            }
            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            InitLang();
            if (!IsPostBack)
            {
                BuildFilters();
                LoadData();
            }
        }

        private void InitLang()
        {
            string lang = Session["preferredLanguage"] as string;
            if (!string.IsNullOrEmpty(lang))
            {
                CurrentLanguage = lang;
                return;
            }
            string userId = Session["userId"] as string;
            if (!string.IsNullOrEmpty(userId))
            {
                try
                {
                    using (SqlConnection connection = new SqlConnection(ConnectionString))
                    using (SqlCommand command = new SqlCommand("SELECT preferredLanguage FROM [User] WHERE userId=@u", connection))
                    {
                        command.Parameters.AddWithValue("@u", userId);
                        connection.Open();
                        object result = command.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            lang = result.ToString();
                            Session["preferredLanguage"] = lang;
                            CurrentLanguage = lang;
                            return;
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("Error: " + ex.Message);
                }
            }
            CurrentLanguage = "EN";
            Session["preferredLanguage"] = "EN";
        }

        private void SetLabels()
        {
            litPageTitle.Text = T("Quiz History", "Sejarah Kuiz");
            litTitle.Text = T("Quiz History", "Sejarah Kuiz");
            litSubtitle.Text = T("View your past quiz attempts, scores, and reviews.", "Lihat percubaan kuiz, skor, dan semakan jawapan anda.");
            litFType.Text = T("Type", "Jenis");
            litFStatus.Text = T("Status", "Status");
            litFSort.Text = T("Sort", "Susun");
            litFSearch.Text = T("Search", "Cari");
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

        protected void ddlFilter_Changed(object sender, EventArgs e)
        {
            LoadData();
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            LoadData();
        }

        private void LoadData()
        {
            SetLabels();
            string userId = Session["userId"].ToString();

            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                connection.Open();

                // Get studentId
                string studentId = null;
                using (SqlCommand command = new SqlCommand("SELECT studentId FROM Student WHERE userId=@u", connection))
                {
                    command.Parameters.AddWithValue("@u", userId);
                    object result = command.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        studentId = result.ToString();
                    }
                }

                if (string.IsNullOrEmpty(studentId))
                {
                    pnlList.Visible = false;
                    pnlEmpty.Visible = true;
                    return;
                }

                // Build query with filters
                string sql = @"
                    SELECT qr.resultId, qr.quizId, qr.score, qr.totalMarks, qr.percentage,
                           qr.resultStatus, qr.attemptNo, qr.attemptedDate,
                           q.quizTitleEN, q.quizTitleBM, q.quizType
                    FROM QuizResult qr
                    INNER JOIN Quiz q ON q.quizId = qr.quizId
                    WHERE qr.studentId = @sid";

                // Apply type filter
                string filterType = ddlType.SelectedValue;
                if (!string.IsNullOrEmpty(filterType))
                {
                    sql += " AND q.quizType = @ftype";
                }

                // Apply status filter
                string filterStatus = ddlStatus.SelectedValue;
                if (!string.IsNullOrEmpty(filterStatus))
                {
                    sql += " AND qr.resultStatus = @fstatus";
                }

                // Apply search filter
                string searchText = txtSearch.Text.Trim();
                if (!string.IsNullOrEmpty(searchText))
                {
                    sql += " AND (q.quizTitleEN LIKE @search OR q.quizTitleBM LIKE @search)";
                }

                // Apply sort
                string sort = ddlSort.SelectedValue;
                if (sort == "highest")
                {
                    sql += " ORDER BY qr.percentage DESC";
                }
                else if (sort == "lowest")
                {
                    sql += " ORDER BY qr.percentage ASC";
                }
                else
                {
                    sql += " ORDER BY qr.attemptedDate DESC";
                }

                DataTable resultTable = new DataTable();
                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    command.Parameters.AddWithValue("@sid", studentId);
                    if (!string.IsNullOrEmpty(filterType))
                    {
                        command.Parameters.AddWithValue("@ftype", filterType);
                    }
                    if (!string.IsNullOrEmpty(filterStatus))
                    {
                        command.Parameters.AddWithValue("@fstatus", filterStatus);
                    }
                    if (!string.IsNullOrEmpty(searchText))
                    {
                        command.Parameters.AddWithValue("@search", "%" + searchText + "%");
                    }

                    SqlDataAdapter adapter = new SqlDataAdapter(command);
                    adapter.Fill(resultTable);
                }

                if (resultTable.Rows.Count == 0)
                {
                    pnlList.Visible = false;
                    pnlEmpty.Visible = true;
                    return;
                }

                pnlList.Visible = true;
                pnlEmpty.Visible = false;

                bool isBM = CurrentLanguage == "BM";
                string viewLabel = T("View", "Lihat");
                string reviewLabel = T("Review", "Semak");
                string retryLabel = T("Retry", "Cuba Lagi");
                string passedLabel = T("Passed", "Lulus");
                string failedLabel = T("Failed", "Gagal");

                List<object> historyList = new List<object>();
                foreach (DataRow row in resultTable.Rows)
                {
                    string quizTitle = isBM ? row["quizTitleBM"].ToString() : row["quizTitleEN"].ToString();
                    if (string.IsNullOrWhiteSpace(quizTitle))
                    {
                        quizTitle = row["quizTitleEN"].ToString();
                    }
                    if (string.IsNullOrWhiteSpace(quizTitle))
                    {
                        quizTitle = row["quizTitleBM"].ToString();
                    }

                    string quizType = row["quizType"] != DBNull.Value ? row["quizType"].ToString() : "Practice";
                    string status = row["resultStatus"] != DBNull.Value ? row["resultStatus"].ToString() : "";
                    int percentage = row["percentage"] != DBNull.Value ? (int)Convert.ToDecimal(row["percentage"]) : 0;
                    int score = row["score"] != DBNull.Value ? Convert.ToInt32(row["score"]) : 0;
                    int totalMarks = row["totalMarks"] != DBNull.Value ? Convert.ToInt32(row["totalMarks"]) : 0;
                    int attemptNo = row["attemptNo"] != DBNull.Value ? Convert.ToInt32(row["attemptNo"]) : 1;
                    string resultId = row["resultId"].ToString();
                    string quizId = row["quizId"].ToString();

                    string dateDisplay = "";
                    if (row["attemptedDate"] != DBNull.Value)
                    {
                        dateDisplay = Convert.ToDateTime(row["attemptedDate"]).ToString("dd MMM yyyy");
                    }

                    string statusClass = status == "Passed" ? "passed" : "failed";
                    string typeBadgeClass = "st-quizhistory-badge-" + quizType.ToLower();
                    string statusBadgeClass = status == "Passed" ? "st-quizhistory-badge-passed" : "st-quizhistory-badge-failed";
                    string statusLabel = status == "Passed" ? passedLabel : failedLabel;
                    string typeLabel = GetTypeLabel(quizType);

                    historyList.Add(new
                    {
                        QuizTitle = HttpUtility.HtmlEncode(quizTitle),
                        PctDisplay = percentage + "%",
                        StatusClass = statusClass,
                        TypeBadgeClass = typeBadgeClass,
                        TypeLabel = typeLabel,
                        StatusBadgeClass = statusBadgeClass,
                        StatusLabel = statusLabel,
                        AttemptNo = attemptNo,
                        DateDisplay = dateDisplay,
                        ScoreDisplay = score + "/" + totalMarks,
                        ResultUrl = ResolveUrl("~/Student/QuizResult.aspx?resultId=" + HttpUtility.UrlEncode(resultId)),
                        ReviewUrl = ResolveUrl("~/Student/QuizResult.aspx?resultId=" + HttpUtility.UrlEncode(resultId)),
                        RetryUrl = ResolveUrl("~/Student/Quiz.aspx?quizId=" + HttpUtility.UrlEncode(quizId)),
                        ViewLbl = viewLabel,
                        ReviewLbl = reviewLabel,
                        RetryLbl = retryLabel
                    });
                }

                rptHistory.DataSource = historyList;
                rptHistory.DataBind();
            }
        }

        private string GetTypeLabel(string quizType)
        {
            if (quizType == "Practice")
            {
                return T("Practice", "Latihan");
            }
            else if (quizType == "Unit")
            {
                return T("Unit", "Unit");
            }
            else if (quizType == "Level")
            {
                return T("Level", "Tahap");
            }
            return T("Quiz", "Kuiz");
        }

        private static bool TableExists(SqlConnection conn, string tableName)
        {
            using (SqlCommand command = new SqlCommand("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME=@t AND TABLE_TYPE='BASE TABLE'", conn))
            {
                command.Parameters.AddWithValue("@t", tableName);
                return (int)command.ExecuteScalar() > 0;
            }
        }
    }
}