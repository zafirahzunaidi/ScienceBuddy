using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Parent
{
    public partial class QuizResults : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        protected string CurrentLanguage = "EN";
        protected string T(string en, string bm) => CurrentLanguage == "BM" ? bm : en;

        private string _parentId = "";
        private string _parentUserId = "";
        private string _selectedChildId = "";
        private string _selectedChildName = "";
        private string _studentParentId = "";

        // Track expanded incorrect sections
        private List<string> _expandedResults
        {
            get { return ViewState["ExpandedResults"] as List<string> ?? new List<string>(); }
            set { ViewState["ExpandedResults"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!EnsureParentAuthorized()) return;
            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            LoadCurrentLanguage();
            _parentUserId = Session["userId"].ToString();
            LoadParentProfile();

            if (!IsPostBack)
            {
                SetLabels();
                LoadLinkedChildren();
                if (!string.IsNullOrEmpty(_selectedChildId))
                {
                    pnlContent.Visible = true;
                    pnlNoChild.Visible = false;
                    PopulateUnitFilter();
                    LoadPageData();
                }
                else { ShowNoChildState(); }
            }
            else
            {
                SetLabels();
                _selectedChildId = ddlSidebarChild.SelectedValue;
                _selectedChildName = ddlSidebarChild.SelectedItem != null ? ddlSidebarChild.SelectedItem.Text : "";
                LoadStudentParentId();
            }
        }

        // ══════════════════════════════════════════════════════════════
        //  AUTH, LANGUAGE, PARENT PROFILE
        // ══════════════════════════════════════════════════════════════
        private bool EnsureParentAuthorized()
        {
            if (Session["userId"] == null || Session["role"] == null || Session["role"].ToString() != "Parent")
            { Response.Redirect("~/Login.aspx", false); Context.ApplicationInstance.CompleteRequest(); return false; }
            return true;
        }

        private void LoadCurrentLanguage()
        {
            string lang = Session["preferredLanguage"] as string;
            if (!string.IsNullOrEmpty(lang)) { CurrentLanguage = lang; return; }
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT preferredLanguage FROM dbo.[User] WHERE userId=@uid", conn))
                { cmd.Parameters.AddWithValue("@uid", Session["userId"].ToString()); conn.Open(); object r = cmd.ExecuteScalar(); if (r != null && r != DBNull.Value) { CurrentLanguage = r.ToString(); Session["preferredLanguage"] = CurrentLanguage; } }
            }
            catch { }
        }

        private void LoadParentProfile()
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT parentId FROM dbo.[Parent] WHERE userId=@uid", conn))
                { cmd.Parameters.AddWithValue("@uid", _parentUserId); conn.Open(); object r = cmd.ExecuteScalar(); if (r != null) _parentId = r.ToString(); }
            }
            catch { }
        }

        private void LoadLinkedChildren()
        {
            ddlSidebarChild.Items.Clear();
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(@"SELECT s.studentId, ISNULL(s.nickname, s.name) AS displayName
                    FROM dbo.StudentParent sp INNER JOIN dbo.Student s ON sp.studentId=s.studentId
                    WHERE sp.parentId=@pid ORDER BY s.name", conn))
                { cmd.Parameters.AddWithValue("@pid", _parentId); conn.Open(); using (var rdr = cmd.ExecuteReader()) { while (rdr.Read()) ddlSidebarChild.Items.Add(new ListItem(rdr["displayName"].ToString(), rdr["studentId"].ToString())); } }
            }
            catch { }
            if (ddlSidebarChild.Items.Count > 0)
            {
                string saved = Session["selectedChildId"] as string;
                if (!string.IsNullOrEmpty(saved) && ddlSidebarChild.Items.FindByValue(saved) != null) ddlSidebarChild.SelectedValue = saved;
                else Session["selectedChildId"] = ddlSidebarChild.Items[0].Value;
                _selectedChildId = ddlSidebarChild.SelectedValue;
                _selectedChildName = ddlSidebarChild.SelectedItem.Text;
                LoadStudentParentId();
            }
        }

        private void LoadStudentParentId()
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT studentParentId FROM dbo.StudentParent WHERE parentId=@pid AND studentId=@sid", conn))
                { cmd.Parameters.AddWithValue("@pid", _parentId); cmd.Parameters.AddWithValue("@sid", _selectedChildId); conn.Open(); object r = cmd.ExecuteScalar(); if (r != null) _studentParentId = r.ToString(); }
            }
            catch { }
        }

        protected void SidebarChildChanged(object sender, EventArgs e)
        {
            Session["selectedChildId"] = ddlSidebarChild.SelectedValue;
            _selectedChildId = ddlSidebarChild.SelectedValue;
            _selectedChildName = ddlSidebarChild.SelectedItem.Text;
            LoadStudentParentId();
            pnlContent.Visible = true; pnlNoChild.Visible = false;
            pnlDetailsModal.Visible = false;
            _expandedResults = new List<string>();
            PopulateUnitFilter();
            LoadPageData();
        }

        protected void DdlUnit_Changed(object sender, EventArgs e) { LoadPageData(); }

        private void ShowNoChildState()
        {
            pnlContent.Visible = false; pnlNoChild.Visible = true;
            litNoChildMsg.Text = T("No linked child found. Please link a child account first.", "Tiada anak dipautkan. Sila pautkan akaun anak terlebih dahulu.");
        }

        private void SetLabels()
        {
            btnViewSelected.Text = T("View Selected Details", "Lihat Butiran Dipilih");
            btnAddWeakToStudyPlan.Text = T("Add Weak Topics to Study Plan", "Tambah Topik Lemah ke Pelan Belajar");
        }

        private string GetChildNickname()
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT ISNULL(nickname, name) FROM dbo.Student WHERE studentId=@sid", conn))
                { cmd.Parameters.AddWithValue("@sid", _selectedChildId); conn.Open(); object r = cmd.ExecuteScalar(); if (r != null && r != DBNull.Value) return r.ToString(); }
            }
            catch { }
            return _selectedChildName;
        }

        private string GetSelectedUnit() { return ddlUnit.SelectedValue ?? ""; }

        // ══════════════════════════════════════════════════════════════
        //  UNIT FILTER & PAGE DATA
        // ══════════════════════════════════════════════════════════════
        private void PopulateUnitFilter()
        {
            ddlUnit.Items.Clear();
            ddlUnit.Items.Add(new ListItem(T("All Units", "Semua Unit"), ""));
            try
            {
                // Show all units from child's enrolled level, not just units with quiz attempts
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(@"SELECT DISTINCT u.unitId, u.unitNameEN, u.unitNameBM
                    FROM dbo.Unit u
                    INNER JOIN dbo.Level l ON u.levelId=l.levelId
                    INNER JOIN dbo.Student s ON s.currentLevelId=l.levelId
                    WHERE s.studentId=@sid
                    UNION
                    SELECT DISTINCT u.unitId, u.unitNameEN, u.unitNameBM
                    FROM dbo.QuizResult qr INNER JOIN dbo.Quiz q ON qr.quizId=q.quizId
                    INNER JOIN dbo.Unit u ON q.unitId=u.unitId
                    WHERE qr.studentId=@sid
                    ORDER BY unitNameEN", conn))
                {
                    cmd.Parameters.AddWithValue("@sid", _selectedChildId); conn.Open();
                    using (var rdr = cmd.ExecuteReader())
                    { while (rdr.Read()) { string name = CurrentLanguage == "BM" && rdr["unitNameBM"] != DBNull.Value ? rdr["unitNameBM"].ToString() : rdr["unitNameEN"].ToString(); ddlUnit.Items.Add(new ListItem(name, rdr["unitId"].ToString())); } }
                }
            }
            catch { }
        }

        private void LoadPageData()
        {
            string childName = GetChildNickname();
            _selectedChildName = childName;
            litHeroTitle.Text = string.Format(T("{0}'s Quiz Results", "Keputusan Kuiz {0}"), childName);
            litHeroSub.Text = T("Track your child's quiz performance and identify areas for improvement.", "Jejak prestasi kuiz anak anda dan kenal pasti bidang untuk diperbaiki.");

            string unitFilter = GetSelectedUnit();
            LoadSummary(unitFilter);
            LoadScoreTrend(unitFilter);
            LoadUnitPerformance(unitFilter);
            LoadRecentAttempts(unitFilter);
            LoadWeakAndStrongAreas();
        }

        // ══════════════════════════════════════════════════════════════
        //  PERFORMANCE SUMMARY
        // ══════════════════════════════════════════════════════════════
        private void LoadSummary(string unitFilter)
        {
            try
            {
                string whereUnit = string.IsNullOrEmpty(unitFilter) ? "" : " AND q.unitId=@uid";
                string sql = string.Format(@"SELECT COUNT(*) AS total, AVG(qr.percentage) AS avg, MAX(qr.percentage) AS highest,
                    SUM(CASE WHEN qr.resultStatus IN ('Pass','Passed') THEN 1 ELSE 0 END) AS passed
                    FROM dbo.QuizResult qr INNER JOIN dbo.Quiz q ON qr.quizId=q.quizId
                    WHERE qr.studentId=@sid{0}", whereUnit);
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                    if (!string.IsNullOrEmpty(unitFilter)) cmd.Parameters.AddWithValue("@uid", unitFilter);
                    conn.Open();
                    using (var rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            int total = rdr["total"] != DBNull.Value ? Convert.ToInt32(rdr["total"]) : 0;
                            decimal avg = rdr["avg"] != DBNull.Value ? Convert.ToDecimal(rdr["avg"]) : 0;
                            decimal highest = rdr["highest"] != DBNull.Value ? Convert.ToDecimal(rdr["highest"]) : 0;
                            int passed = rdr["passed"] != DBNull.Value ? Convert.ToInt32(rdr["passed"]) : 0;
                            decimal passRate = total > 0 ? Math.Round((decimal)passed / total * 100, 0) : 0;

                            litAvgScore.Text = total > 0 ? avg.ToString("F0") + "%" : T("No data", "Tiada data");
                            litHighScore.Text = total > 0 ? highest.ToString("F0") + "%" : "-";
                            litPassRate.Text = total > 0 ? passRate.ToString("F0") + "%" : "-";
                            litTotalAttempts.Text = total.ToString();
                        }
                    }
                }
            }
            catch { litAvgScore.Text = "-"; litHighScore.Text = "-"; litPassRate.Text = "-"; litTotalAttempts.Text = "0"; }
        }

        // ══════════════════════════════════════════════════════════════
        //  SCORE TREND
        // ══════════════════════════════════════════════════════════════
        private void LoadScoreTrend(string unitFilter)
        {
            pnlScoreTrend.Controls.Clear();
            var attempts = new List<Tuple<DateTime, decimal, string>>();
            try
            {
                string whereUnit = string.IsNullOrEmpty(unitFilter) ? "" : " AND q.unitId=@uid";
                string sql = string.Format(@"SELECT TOP 10 qr.percentage, qr.attemptedDate, q.quizTitleEN, q.quizTitleBM
                    FROM dbo.QuizResult qr INNER JOIN dbo.Quiz q ON qr.quizId=q.quizId
                    WHERE qr.studentId=@sid{0} ORDER BY qr.attemptedDate DESC", whereUnit);
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                    if (!string.IsNullOrEmpty(unitFilter)) cmd.Parameters.AddWithValue("@uid", unitFilter);
                    conn.Open();
                    using (var rdr = cmd.ExecuteReader())
                    { while (rdr.Read()) { string title = CurrentLanguage == "BM" && rdr["quizTitleBM"] != DBNull.Value ? rdr["quizTitleBM"].ToString() : rdr["quizTitleEN"].ToString(); attempts.Add(Tuple.Create(Convert.ToDateTime(rdr["attemptedDate"]), Convert.ToDecimal(rdr["percentage"]), title)); } }
                }
            }
            catch { }

            if (attempts.Count == 0) { pnlNoTrend.Visible = true; return; }
            pnlNoTrend.Visible = false;
            attempts.Reverse(); // chronological order

            // CSS-only line chart using SVG polyline
            StringBuilder sb = new StringBuilder();
            int count = attempts.Count;

            // Build SVG points
            var points = new StringBuilder();
            var dots = new StringBuilder();
            for (int i = 0; i < count; i++)
            {
                double x = count == 1 ? 100.0 : (double)i / (count - 1) * 176 + 12; // 12 to 188
                double y = (double)(100 - attempts[i].Item2) / 100.0 * 80 + 10; // 10 to 90
                points.AppendFormat("{0},{1} ", x.ToString("F1", CultureInfo.InvariantCulture), y.ToString("F1", CultureInfo.InvariantCulture));
                string dotColor = attempts[i].Item2 >= 80 ? "#16A34A" : attempts[i].Item2 >= 50 ? "#6366F1" : "#DC2626";
                dots.AppendFormat("<circle cx=\"{0}\" cy=\"{1}\" r=\"3\" fill=\"{2}\" stroke=\"#fff\" stroke-width=\"1.5\"/>",
                    x.ToString("F1", CultureInfo.InvariantCulture), y.ToString("F1", CultureInfo.InvariantCulture), dotColor);
            }

            sb.Append("<div class=\"pt-line-chart-wrap\">");
            sb.Append("<div class=\"pt-line-chart-y\"><span>100%</span><span>50%</span><span>0%</span></div>");
            sb.Append("<svg class=\"pt-line-chart-svg\" viewBox=\"0 0 200 100\" preserveAspectRatio=\"none\">");
            sb.Append("<line x1=\"12\" y1=\"10\" x2=\"188\" y2=\"10\" stroke=\"#E2E8F0\" stroke-width=\"0.3\"/>");
            sb.Append("<line x1=\"12\" y1=\"50\" x2=\"188\" y2=\"50\" stroke=\"#E2E8F0\" stroke-width=\"0.3\" stroke-dasharray=\"2,2\"/>");
            sb.Append("<line x1=\"12\" y1=\"90\" x2=\"188\" y2=\"90\" stroke=\"#E2E8F0\" stroke-width=\"0.3\"/>");
            sb.AppendFormat("<polyline points=\"{0}\" fill=\"none\" stroke=\"#6366F1\" stroke-width=\"1.2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>", points.ToString().Trim());
            sb.Append(dots.ToString());
            sb.Append("</svg>");
            sb.Append("<div class=\"pt-line-chart-x\">");
            foreach (var a in attempts) sb.AppendFormat("<span>{0}</span>", a.Item1.ToString("dd MMM"));
            sb.Append("</div></div>");

            pnlScoreTrend.Controls.Add(new LiteralControl(sb.ToString()));
        }

        // ══════════════════════════════════════════════════════════════
        //  UNIT PERFORMANCE
        // ══════════════════════════════════════════════════════════════
        private void LoadUnitPerformance(string unitFilter)
        {
            pnlUnitPerformance.Controls.Clear();
            var units = new List<Tuple<string, decimal>>();
            try
            {
                string whereUnit = string.IsNullOrEmpty(unitFilter) ? "" : " AND q.unitId=@uid";
                string sql = string.Format(@"SELECT u.unitNameEN, u.unitNameBM, AVG(qr.percentage) AS avg
                    FROM dbo.QuizResult qr INNER JOIN dbo.Quiz q ON qr.quizId=q.quizId
                    INNER JOIN dbo.Unit u ON q.unitId=u.unitId
                    WHERE qr.studentId=@sid{0} GROUP BY u.unitNameEN, u.unitNameBM ORDER BY avg DESC", whereUnit);
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                    if (!string.IsNullOrEmpty(unitFilter)) cmd.Parameters.AddWithValue("@uid", unitFilter);
                    conn.Open();
                    using (var rdr = cmd.ExecuteReader())
                    { while (rdr.Read()) { string name = CurrentLanguage == "BM" && rdr["unitNameBM"] != DBNull.Value ? rdr["unitNameBM"].ToString() : rdr["unitNameEN"].ToString(); units.Add(Tuple.Create(name, Convert.ToDecimal(rdr["avg"]))); } }
                }
            }
            catch { }

            if (units.Count == 0) { pnlNoUnitPerf.Visible = true; return; }
            pnlNoUnitPerf.Visible = false;

            StringBuilder sb = new StringBuilder();
            foreach (var u in units)
            {
                string color = u.Item2 >= 80 ? "#16A34A" : u.Item2 >= 50 ? "#6366F1" : "#DC2626";
                sb.AppendFormat(@"<div class=""pt-unit-perf-row"">
                    <div class=""pt-unit-perf-label"">{0}</div>
                    <div class=""pt-unit-perf-bar-wrap""><div class=""pt-unit-perf-bar"" style=""width:{1}%;background:{2};""></div></div>
                    <span class=""pt-unit-perf-pct"">{1:F0}%</span>
                </div>", u.Item1, u.Item2, color);
            }
            pnlUnitPerformance.Controls.Add(new LiteralControl(sb.ToString()));
        }

        // ══════════════════════════════════════════════════════════════
        //  RECENT ATTEMPTS TABLE
        // ══════════════════════════════════════════════════════════════
        private void LoadRecentAttempts(string unitFilter)
        {
            pnlAttempts.Controls.Clear();
            try
            {
                string whereUnit = string.IsNullOrEmpty(unitFilter) ? "" : " AND q.unitId=@uid";
                string sql = string.Format(@"SELECT qr.resultId, q.quizTitleEN, q.quizTitleBM, u.unitNameEN, u.unitNameBM,
                    qr.percentage, qr.attemptedDate, qr.resultStatus
                    FROM dbo.QuizResult qr INNER JOIN dbo.Quiz q ON qr.quizId=q.quizId
                    LEFT JOIN dbo.Unit u ON q.unitId=u.unitId
                    WHERE qr.studentId=@sid{0} ORDER BY qr.attemptedDate DESC", whereUnit);

                var rows = new List<AttemptRow>();
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                    if (!string.IsNullOrEmpty(unitFilter)) cmd.Parameters.AddWithValue("@uid", unitFilter);
                    conn.Open();
                    using (var rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            rows.Add(new AttemptRow
                            {
                                ResultId = rdr["resultId"].ToString(),
                                QuizTitle = CurrentLanguage == "BM" && rdr["quizTitleBM"] != DBNull.Value ? rdr["quizTitleBM"].ToString() : rdr["quizTitleEN"].ToString(),
                                UnitName = rdr["unitNameEN"] != DBNull.Value ? (CurrentLanguage == "BM" && rdr["unitNameBM"] != DBNull.Value ? rdr["unitNameBM"].ToString() : rdr["unitNameEN"].ToString()) : "-",
                                Percentage = rdr["percentage"] != DBNull.Value ? Convert.ToDecimal(rdr["percentage"]) : 0,
                                Date = rdr["attemptedDate"] != DBNull.Value ? Convert.ToDateTime(rdr["attemptedDate"]) : DateTime.MinValue,
                                Status = rdr["resultStatus"] != DBNull.Value ? rdr["resultStatus"].ToString() : ""
                            });
                        }
                    }
                }

                if (rows.Count == 0) { pnlNoAttempts.Visible = true; return; }
                pnlNoAttempts.Visible = false;

                StringBuilder sb = new StringBuilder();
                sb.Append("<table class=\"pt-attempts-table\"><thead><tr>");
                sb.AppendFormat("<th></th><th>{0}</th><th>{1}</th><th>{2}</th><th>{3}</th><th>{4}</th><th></th>",
                    T("Quiz","Kuiz"), T("Unit","Unit"), T("Score","Skor"), T("Date","Tarikh"), T("Status","Status"));
                sb.Append("</tr></thead><tbody>");

                foreach (var r in rows)
                {
                    string statusClass = (r.Status == "Pass" || r.Status == "Passed") ? "pt-status-pass" : "pt-status-fail";
                    string statusText = (r.Status == "Pass" || r.Status == "Passed") ? T("Pass","Lulus") : T("Fail","Gagal");
                    sb.AppendFormat(@"<tr>
                        <td><input type=""checkbox"" class=""pt-quiz-check"" value=""{0}"" onclick=""updateSelectedQuizzes()"" /></td>
                        <td class=""pt-attempts-quiz"">{1}</td>
                        <td>{2}</td>
                        <td><strong>{3:F0}%</strong></td>
                        <td>{4}</td>
                        <td><span class=""pt-status-badge {5}"">{6}</span></td>
                        <td><button type=""button"" class=""pt-btn-view-detail"" onclick=""selectSingleQuiz('{0}');""><i class=""bi bi-chevron-right""></i></button></td>
                    </tr>", r.ResultId, r.QuizTitle, r.UnitName, r.Percentage,
                        r.Date != DateTime.MinValue ? r.Date.ToString("dd MMM yyyy") : "-", statusClass, statusText);
                }
                sb.Append("</tbody></table>");

                // Inline script for checkbox management
                sb.Append(@"<script>
function updateSelectedQuizzes(){var cbs=document.querySelectorAll('.pt-quiz-check');var ids=[];cbs.forEach(function(c){if(c.checked)ids.push(c.value);});document.getElementById('" + hidSelectedResults.ClientID + @"').value=ids.join(',');}
function selectSingleQuiz(id){document.getElementById('" + hidSelectedResults.ClientID + @"').value=id;document.getElementById('" + btnViewSelected.ClientID + @"').click();}
</script>");

                pnlAttempts.Controls.Add(new LiteralControl(sb.ToString()));
            }
            catch { pnlNoAttempts.Visible = true; }
        }

        private class AttemptRow
        {
            public string ResultId; public string QuizTitle; public string UnitName;
            public decimal Percentage; public DateTime Date; public string Status;
        }

        // ══════════════════════════════════════════════════════════════
        //  VIEW QUIZ DETAILS MODAL
        // ══════════════════════════════════════════════════════════════
        protected void BtnViewSelected_Click(object sender, EventArgs e)
        {
            string ids = hidSelectedResults.Value;
            if (string.IsNullOrWhiteSpace(ids)) { ShowMessage(T("Please select at least one quiz.", "Sila pilih sekurang-kurangnya satu kuiz."), false); LoadPageData(); return; }

            var resultIds = ids.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries).ToList();
            BuildDetailsModal(resultIds);
            pnlDetailsModal.Visible = true;
            LoadPageData();
        }

        protected void BtnCloseDetails_Click(object sender, EventArgs e)
        {
            pnlDetailsModal.Visible = false;
            LoadPageData();
        }

        private void BuildDetailsModal(List<string> resultIds)
        {
            pnlDetailsContent.Controls.Clear();
            StringBuilder sb = new StringBuilder();
            var expanded = _expandedResults;

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    foreach (string rid in resultIds)
                    {
                        // Get quiz result info
                        string quizTitle = "", status = "";
                        decimal pct = 0; int correct = 0, incorrect = 0;
                        using (var cmd = new SqlCommand(@"SELECT q.quizTitleEN, q.quizTitleBM, qr.percentage, qr.resultStatus,
                            (SELECT COUNT(*) FROM dbo.QuizAnswer WHERE resultId=qr.resultId AND isCorrect=1) AS correctCount,
                            (SELECT COUNT(*) FROM dbo.QuizAnswer WHERE resultId=qr.resultId AND isCorrect=0) AS incorrectCount
                            FROM dbo.QuizResult qr INNER JOIN dbo.Quiz q ON qr.quizId=q.quizId
                            WHERE qr.resultId=@rid AND qr.studentId=@sid", conn))
                        {
                            cmd.Parameters.AddWithValue("@rid", rid);
                            cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                            using (var rdr = cmd.ExecuteReader())
                            {
                                if (!rdr.Read()) continue;
                                quizTitle = CurrentLanguage == "BM" && rdr["quizTitleBM"] != DBNull.Value ? rdr["quizTitleBM"].ToString() : rdr["quizTitleEN"].ToString();
                                pct = Convert.ToDecimal(rdr["percentage"]);
                                status = rdr["resultStatus"].ToString();
                                correct = Convert.ToInt32(rdr["correctCount"]);
                                incorrect = Convert.ToInt32(rdr["incorrectCount"]);
                            }
                        }

                        string statusBadge = (status == "Pass" || status == "Passed")
                            ? "<span class='pt-status-badge pt-status-pass'>" + T("Pass","Lulus") + "</span>"
                            : "<span class='pt-status-badge pt-status-fail'>" + T("Fail","Gagal") + "</span>";

                        sb.AppendFormat(@"<div class=""pt-quiz-detail-card"">
                            <div class=""pt-quiz-detail-header"">
                                <h4>{0}</h4>{1}
                            </div>
                            <div class=""pt-quiz-detail-stats"">
                                <span><i class=""bi bi-percent""></i> {2:F0}%</span>
                                <span class=""text-success""><i class=""bi bi-check-circle""></i> {3} {4}</span>
                                <span class=""text-error""><i class=""bi bi-x-circle""></i> {5} {6}</span>
                            </div>", quizTitle, statusBadge, pct, correct, T("correct","betul"), incorrect, T("incorrect","salah"));

                        // Incorrect toggle
                        bool isExpanded = expanded.Contains(rid);
                        string toggleText = string.Format(T("Incorrect Questions ({0})", "Soalan Salah ({0})"), incorrect);
                        sb.AppendFormat(@"<div class=""pt-incorrect-toggle-wrap"">
                            <button type=""button"" class=""pt-incorrect-toggle"" onclick=""document.getElementById('{0}').value='{1}';document.getElementById('{2}').click();"">
                                <i class=""bi {3}""></i> {4}
                            </button>
                        </div>", hidToggleResult.ClientID, rid, btnToggleIncorrect.ClientID,
                            isExpanded ? "bi-chevron-up" : "bi-chevron-down", toggleText);

                        if (isExpanded && incorrect > 0)
                        {
                            sb.Append("<div class=\"pt-incorrect-list\">");
                            using (var cmd2 = new SqlCommand(@"SELECT qa.selectedAnswer, q.questionTextEN, q.questionTextBM,
                                q.correctAnswer, q.optionA_EN, q.optionA_BM, q.optionB_EN, q.optionB_BM,
                                q.optionC_EN, q.optionC_BM, q.optionD_EN, q.optionD_BM
                                FROM dbo.QuizAnswer qa INNER JOIN dbo.Question q ON qa.questionId=q.questionId
                                WHERE qa.resultId=@rid AND qa.isCorrect=0", conn))
                            {
                                cmd2.Parameters.AddWithValue("@rid", rid);
                                using (var rdr2 = cmd2.ExecuteReader())
                                {
                                    int qNum = 1;
                                    while (rdr2.Read())
                                    {
                                        string qText = CurrentLanguage == "BM" && rdr2["questionTextBM"] != DBNull.Value ? rdr2["questionTextBM"].ToString() : rdr2["questionTextEN"].ToString();
                                        string childAns = rdr2["selectedAnswer"] != DBNull.Value ? rdr2["selectedAnswer"].ToString() : "-";
                                        string correctAns = ResolveCorrectAnswer(rdr2);

                                        sb.AppendFormat(@"<div class=""pt-question-review-card"">
                                            <div class=""pt-qr-question""><strong>Q{0}.</strong> {1}</div>
                                            <div class=""pt-qr-answers"">
                                                <span class=""pt-qr-child-ans""><i class=""bi bi-x-circle-fill""></i> {2}: {3}</span>
                                                <span class=""pt-qr-correct-ans""><i class=""bi bi-check-circle-fill""></i> {4}: {5}</span>
                                            </div>
                                        </div>", qNum++, qText, T("Your child's answer","Jawapan anak"), childAns, T("Correct answer","Jawapan betul"), correctAns);
                                    }
                                }
                            }
                            sb.Append("</div>");
                        }
                        sb.Append("</div>"); // close pt-quiz-detail-card
                    }
                }
            }
            catch { }
            pnlDetailsContent.Controls.Add(new LiteralControl(sb.ToString()));
        }

        protected void BtnToggleIncorrect_Click(object sender, EventArgs e)
        {
            string rid = hidToggleResult.Value;
            if (string.IsNullOrEmpty(rid)) return;
            var expanded = _expandedResults;
            if (expanded.Contains(rid)) expanded.Remove(rid); else expanded.Add(rid);
            _expandedResults = expanded;

            // Rebuild modal with current selection
            string ids = hidSelectedResults.Value;
            if (!string.IsNullOrEmpty(ids))
            {
                var resultIds = ids.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries).ToList();
                BuildDetailsModal(resultIds);
                pnlDetailsModal.Visible = true;
            }
            LoadPageData();
        }

        private string ResolveCorrectAnswer(SqlDataReader rdr)
        {
            string ca = rdr["correctAnswer"] != DBNull.Value ? rdr["correctAnswer"].ToString().Trim() : "";
            if (ca.Length == 1)
            {
                string col = "";
                if (ca == "A") col = CurrentLanguage == "BM" ? "optionA_BM" : "optionA_EN";
                else if (ca == "B") col = CurrentLanguage == "BM" ? "optionB_BM" : "optionB_EN";
                else if (ca == "C") col = CurrentLanguage == "BM" ? "optionC_BM" : "optionC_EN";
                else if (ca == "D") col = CurrentLanguage == "BM" ? "optionD_BM" : "optionD_EN";
                if (!string.IsNullOrEmpty(col) && rdr[col] != DBNull.Value) return rdr[col].ToString();
            }
            return ca;
        }

        // ══════════════════════════════════════════════════════════════
        //  WEAK & STRONG AREAS
        // ══════════════════════════════════════════════════════════════
        private void LoadWeakAndStrongAreas()
        {
            pnlWeakAreas.Controls.Clear();
            pnlStrongAreas.Controls.Clear();
            var unitStats = new List<UnitStat>();

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(@"SELECT u.unitId, u.unitNameEN, u.unitNameBM, AVG(qr.percentage) AS avg,
                    (SELECT COUNT(*) FROM dbo.QuizAnswer qa INNER JOIN dbo.QuizResult qr2 ON qa.resultId=qr2.resultId
                        INNER JOIN dbo.Quiz q2 ON qr2.quizId=q2.quizId WHERE qr2.studentId=@sid AND q2.unitId=u.unitId AND qa.isCorrect=0) AS incorrectCount
                    FROM dbo.QuizResult qr INNER JOIN dbo.Quiz q ON qr.quizId=q.quizId
                    INNER JOIN dbo.Unit u ON q.unitId=u.unitId
                    WHERE qr.studentId=@sid GROUP BY u.unitId, u.unitNameEN, u.unitNameBM", conn))
                {
                    cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                    conn.Open();
                    using (var rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            unitStats.Add(new UnitStat
                            {
                                UnitId = rdr["unitId"].ToString(),
                                UnitName = CurrentLanguage == "BM" && rdr["unitNameBM"] != DBNull.Value ? rdr["unitNameBM"].ToString() : rdr["unitNameEN"].ToString(),
                                Avg = Convert.ToDecimal(rdr["avg"]),
                                IncorrectCount = Convert.ToInt32(rdr["incorrectCount"])
                            });
                        }
                    }
                }
            }
            catch { }

            // Weak: avg < 60 or top 3 lowest
            var weak = unitStats.Where(u => u.Avg < 60).OrderBy(u => u.Avg).ToList();
            if (weak.Count == 0 && unitStats.Count > 0) weak = unitStats.OrderBy(u => u.Avg).Take(1).Where(u => u.Avg < 80).ToList();

            if (weak.Count > 0)
            {
                pnlNoWeak.Visible = false;
                StringBuilder sb = new StringBuilder();
                foreach (var w in weak)
                {
                    sb.AppendFormat(@"<div class=""pt-weak-item"">
                        <div class=""pt-weak-item-name"">{0}</div>
                        <div class=""pt-weak-item-detail""><i class=""bi bi-x-circle""></i> {1}: {2}</div>
                        <div class=""pt-weak-item-detail""><i class=""bi bi-percent""></i> {3}: {4:F0}%</div>
                    </div>", w.UnitName, T("Incorrect questions","Soalan salah"), w.IncorrectCount, T("Average","Purata"), w.Avg);
                }
                pnlWeakAreas.Controls.Add(new LiteralControl(sb.ToString()));
                btnAddWeakToStudyPlan.Visible = true;
            }
            else { pnlNoWeak.Visible = true; btnAddWeakToStudyPlan.Visible = false; }

            // Strong: avg >= 70, ranked highest first
            var strong = unitStats.Where(u => u.Avg >= 70).OrderByDescending(u => u.Avg).ToList();
            if (strong.Count > 0)
            {
                pnlNoStrong.Visible = false;
                StringBuilder sb = new StringBuilder();
                foreach (var s in strong)
                {
                    sb.AppendFormat(@"<div class=""pt-strong-item"">
                        <div class=""pt-strong-item-name"">{0}</div>
                        <div class=""pt-strong-item-detail""><i class=""bi bi-percent""></i> {1}: {2:F0}%</div>
                    </div>", s.UnitName, T("Average","Purata"), s.Avg);
                }
                pnlStrongAreas.Controls.Add(new LiteralControl(sb.ToString()));
            }
            else { pnlNoStrong.Visible = true; }

            // Most Improved
            litMostImproved.Text = CalculateMostImproved();
        }

        private string CalculateMostImproved()
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(@"SELECT q.unitId, u.unitNameEN, u.unitNameBM, qr.percentage, qr.attemptedDate
                    FROM dbo.QuizResult qr INNER JOIN dbo.Quiz q ON qr.quizId=q.quizId
                    INNER JOIN dbo.Unit u ON q.unitId=u.unitId
                    WHERE qr.studentId=@sid ORDER BY q.unitId, qr.attemptedDate", conn))
                {
                    cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                    conn.Open();
                    var byUnit = new Dictionary<string, List<decimal>>();
                    var unitNames = new Dictionary<string, string>();
                    using (var rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            string uid = rdr["unitId"].ToString();
                            if (!byUnit.ContainsKey(uid)) { byUnit[uid] = new List<decimal>(); unitNames[uid] = CurrentLanguage == "BM" && rdr["unitNameBM"] != DBNull.Value ? rdr["unitNameBM"].ToString() : rdr["unitNameEN"].ToString(); }
                            byUnit[uid].Add(Convert.ToDecimal(rdr["percentage"]));
                        }
                    }

                    string bestUnit = ""; decimal bestDelta = 0;
                    foreach (var kv in byUnit)
                    {
                        if (kv.Value.Count < 2) continue;
                        int half = kv.Value.Count / 2;
                        decimal firstHalf = kv.Value.Take(half).Average();
                        decimal secondHalf = kv.Value.Skip(half).Average();
                        decimal delta = secondHalf - firstHalf;
                        if (delta > bestDelta) { bestDelta = delta; bestUnit = kv.Key; }
                    }

                    if (!string.IsNullOrEmpty(bestUnit))
                        return string.Format("{0} (+{1:F0}%)", unitNames[bestUnit], bestDelta);
                }
            }
            catch { }
            return T("Not enough quiz history yet.", "Belum cukup sejarah kuiz.");
        }

        private class UnitStat { public string UnitId; public string UnitName; public decimal Avg; public int IncorrectCount; }

        // ══════════════════════════════════════════════════════════════
        //  ADD WEAK TOPICS TO STUDY PLAN
        // ══════════════════════════════════════════════════════════════
        protected void BtnAddWeakToStudyPlan_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(_studentParentId)) { ShowMessage(T("Unable to find child link.", "Tidak dapat mencari pautan anak."), false); LoadPageData(); return; }

            // Get weak units and pre-fill the modal
            try
            {
                var weakUnits = new List<Tuple<string, string>>(); // unitId, unitName
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand(@"SELECT u.unitId, u.unitNameEN, u.unitNameBM, AVG(qr.percentage) AS avg
                        FROM dbo.QuizResult qr INNER JOIN dbo.Quiz q ON qr.quizId=q.quizId
                        INNER JOIN dbo.Unit u ON q.unitId=u.unitId
                        WHERE qr.studentId=@sid GROUP BY u.unitId, u.unitNameEN, u.unitNameBM HAVING AVG(qr.percentage) < 80
                        ORDER BY avg", conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", _selectedChildId);
                        using (var rdr = cmd.ExecuteReader())
                        {
                            while (rdr.Read())
                            {
                                string name = CurrentLanguage == "BM" && rdr["unitNameBM"] != DBNull.Value ? rdr["unitNameBM"].ToString() : rdr["unitNameEN"].ToString();
                                weakUnits.Add(Tuple.Create(rdr["unitId"].ToString(), name));
                            }
                        }
                    }
                }

                if (weakUnits.Count == 0) { ShowMessage(T("No weak topics to add.", "Tiada topik lemah untuk ditambah."), false); LoadPageData(); return; }

                // Pre-fill task name and suggested action
                string topicNames = string.Join(", ", weakUnits.Select(w => w.Item2));
                txtTaskName.Text = string.Format(T("Revise {0}", "Ulangkaji {0}"), topicNames);
                txtSuggestedAction.Text = string.Format(
                    T("Spend 20 minutes reviewing {0} to improve quiz scores.", "Luangkan 20 minit mengulangkaji {0} untuk memperbaiki skor kuiz."), topicNames);

                litTaskModalSub.Text = string.Format(T("Review and add a revision task for {0}.", "Semak dan tambah tugasan ulangkaji untuk {0}."), _selectedChildName);
                btnConfirmAddTask.Text = T("Add Task", "Tambah Tugasan");

                // Show the modal
                pnlTaskModal.CssClass = "pt-task-modal-overlay";
            }
            catch { ShowMessage(T("An error occurred.", "Ralat berlaku."), false); }
            LoadPageData();
        }

        protected void BtnConfirmAddTask_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtTaskName.Text))
            {
                ShowMessage(T("Please enter a task name.", "Sila masukkan nama tugasan."), false);
                LoadPageData();
                return;
            }

            if (string.IsNullOrEmpty(_studentParentId)) { ShowMessage(T("Unable to find child link.", "Tidak dapat mencari pautan anak."), false); LoadPageData(); return; }

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // Find active study plan
                    string studyPlanId = null;
                    using (var cmd = new SqlCommand("SELECT TOP 1 studyPlanId FROM dbo.StudyPlan WHERE studentParentId=@spid AND status='Ongoing' ORDER BY createdAt DESC", conn))
                    { cmd.Parameters.AddWithValue("@spid", _studentParentId); studyPlanId = cmd.ExecuteScalar() as string; }

                    using (var txn = conn.BeginTransaction())
                    {
                        try
                        {
                            // Create plan if needed
                            if (string.IsNullOrEmpty(studyPlanId))
                            {
                                studyPlanId = GenerateId(conn, txn, "StudyPlan", "studyPlanId", "STP");
                                using (var cmd = new SqlCommand(@"INSERT INTO dbo.StudyPlan (studyPlanId,studentParentId,createdByUserId,planTitle,startDate,endDate,status,createdAt)
                                    VALUES(@id,@spid,@uid,@title,@start,@end,'Ongoing',@now)", conn, txn))
                                {
                                    cmd.Parameters.AddWithValue("@id", studyPlanId);
                                    cmd.Parameters.AddWithValue("@spid", _studentParentId);
                                    cmd.Parameters.AddWithValue("@uid", _parentUserId);
                                    cmd.Parameters.AddWithValue("@title", T("Quiz Revision Plan", "Pelan Ulangkaji Kuiz"));
                                    cmd.Parameters.AddWithValue("@start", DateTime.Today);
                                    cmd.Parameters.AddWithValue("@end", DateTime.Today.AddDays(14));
                                    cmd.Parameters.AddWithValue("@now", DateTime.Now);
                                    cmd.ExecuteNonQuery();
                                }
                            }

                            // Check duplicate
                            bool exists = false;
                            using (var chk = new SqlCommand("SELECT COUNT(*) FROM dbo.SPTask WHERE studyPlanId=@spid AND taskTitle=@title AND isCompleted=0", conn, txn))
                            {
                                chk.Parameters.AddWithValue("@spid", studyPlanId);
                                chk.Parameters.AddWithValue("@title", txtTaskName.Text.Trim());
                                exists = (int)chk.ExecuteScalar() > 0;
                            }

                            if (exists)
                            {
                                txn.Rollback();
                                pnlTaskModal.CssClass = "pt-task-modal-overlay pt-task-modal-hidden";
                                ShowMessage(T("This task has already been added to the study plan.", "Tugasan ini telah ditambah ke pelan belajar."), true);
                                LoadPageData();
                                return;
                            }

                            int maxOrder = 0;
                            using (var cmd = new SqlCommand("SELECT ISNULL(MAX(orderNo),0) FROM dbo.SPTask WHERE studyPlanId=@spid", conn, txn))
                            { cmd.Parameters.AddWithValue("@spid", studyPlanId); maxOrder = (int)cmd.ExecuteScalar(); }

                            string taskId = GenerateId(conn, txn, "SPTask", "spTaskId", "SPT");
                            using (var cmd = new SqlCommand(@"INSERT INTO dbo.SPTask (spTaskId,studyPlanId,taskTitle,suggestedAction,orderNo,isCompleted,completedAt)
                                VALUES(@id,@spid,@title,@action,@order,0,NULL)", conn, txn))
                            {
                                cmd.Parameters.AddWithValue("@id", taskId);
                                cmd.Parameters.AddWithValue("@spid", studyPlanId);
                                cmd.Parameters.AddWithValue("@title", txtTaskName.Text.Trim());
                                cmd.Parameters.AddWithValue("@action", string.IsNullOrEmpty(txtSuggestedAction.Text) ? (object)DBNull.Value : txtSuggestedAction.Text.Trim());
                                cmd.Parameters.AddWithValue("@order", maxOrder + 1);
                                cmd.ExecuteNonQuery();
                            }

                            txn.Commit();
                            txtTaskName.Text = "";
                            txtSuggestedAction.Text = "";
                            pnlTaskModal.CssClass = "pt-task-modal-overlay pt-task-modal-hidden";
                            ShowMessage(T("The task has been added to the study plan.", "Tugasan telah ditambah ke pelan belajar."), true);
                        }
                        catch { txn.Rollback(); throw; }
                    }
                }
            }
            catch { ShowMessage(T("An error occurred while adding the task.", "Ralat berlaku semasa menambah tugasan."), false); }
            LoadPageData();
        }

        private string GenerateId(SqlConnection conn, SqlTransaction txn, string table, string column, string prefix)
        {
            int nextNum = 1;
            using (var cmd = new SqlCommand(string.Format("SELECT MAX({0}) FROM dbo.[{1}]", column, table), conn, txn))
            {
                object r = cmd.ExecuteScalar();
                if (r != null && r != DBNull.Value)
                {
                    string lastId = r.ToString();
                    if (lastId.Length > prefix.Length) { int num; if (int.TryParse(lastId.Substring(prefix.Length), out num)) nextNum = num + 1; }
                }
            }
            return prefix + nextNum.ToString("D3");
        }

        private void ShowMessage(string msg, bool success)
        {
            pnlMessage.Visible = true;
            divMessage.InnerHtml = msg;
            iMsgIcon.Attributes["class"] = success ? "bi bi-check-circle-fill" : "bi bi-exclamation-circle-fill";
        }

        protected void BtnCloseMsg_Click(object sender, EventArgs e) { pnlMessage.Visible = false; LoadPageData(); }
    }
}
