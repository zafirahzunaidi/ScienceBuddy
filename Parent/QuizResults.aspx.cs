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
        private string DatabaseConnectionString =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected string CurrentLanguage = "EN";

        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        private string _parentRecordId = "";
        private string _authenticatedUserId = "";
        private string _selectedChildId = "";
        private string _selectedChildName = "";
        private string _studentParentLinkId = "";

        /// <summary>
        /// Tracks which quiz result cards have their incorrect-question section expanded.
        /// Persisted via ViewState to survive postbacks.
        /// </summary>
        private List<string> _expandedResultIds
        {
            get { return ViewState["ExpandedResults"] as List<string> ?? new List<string>(); }
            set { ViewState["ExpandedResults"] = value; }
        }

        // ══════════════════════════════════════════════════════════════
        //  PAGE LIFECYCLE
        // ══════════════════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!ValidateParentSession())
            {
                return;
            }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            LoadLanguagePreference();
            LoadUnreadNotificationBadge();
            _authenticatedUserId = Session["userId"].ToString();
            LoadParentRecordId();

            if (!IsPostBack)
            {
                ApplyPageLabels();
                LoadLinkedChildrenDropdown();

                if (!string.IsNullOrEmpty(_selectedChildId))
                {
                    pnlContent.Visible = true;
                    pnlNoChild.Visible = false;
                    PopulateUnitFilter();
                    RefreshAllQuizData();
                }
                else
                {
                    ShowNoLinkedChildState();
                }
            }
            else
            {
                ApplyPageLabels();
                _selectedChildId = ddlSidebarChild.SelectedValue;
                _selectedChildName = ddlSidebarChild.SelectedItem != null
                    ? ddlSidebarChild.SelectedItem.Text : "";
                LoadStudentParentLinkId();
            }
        }

        // ══════════════════════════════════════════════════════════════
        //  AUTHORIZATION, LANGUAGE, PARENT RESOLUTION
        // ══════════════════════════════════════════════════════════════
        private bool ValidateParentSession()
        {
            if (Session["userId"] == null || Session["role"] == null ||
                Session["role"].ToString() != "Parent")
            {
                Response.Redirect("~/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return false;
            }
            return true;
        }

        private void LoadLanguagePreference()
        {
            string cachedLanguage = Session["preferredLanguage"] as string;
            if (!string.IsNullOrEmpty(cachedLanguage))
            {
                CurrentLanguage = cachedLanguage;
                return;
            }

            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(
                    "SELECT preferredLanguage FROM dbo.[User] WHERE userId=@uid", connection))
                {
                    command.Parameters.AddWithValue("@uid", Session["userId"].ToString());
                    connection.Open();
                    object result = command.ExecuteScalar();

                    if (result != null && result != DBNull.Value)
                    {
                        CurrentLanguage = result.ToString();
                        Session["preferredLanguage"] = CurrentLanguage;
                    }
                }
            }
            catch { }
        }

        private void LoadParentRecordId()
        {
            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(
                    "SELECT parentId FROM dbo.[Parent] WHERE userId=@uid", connection))
                {
                    command.Parameters.AddWithValue("@uid", _authenticatedUserId);
                    connection.Open();
                    object result = command.ExecuteScalar();

                    if (result != null)
                    {
                        _parentRecordId = result.ToString();
                    }
                }
            }
            catch { }
        }

        private void LoadLinkedChildrenDropdown()
        {
            ddlSidebarChild.Items.Clear();

            try
            {
                const string childListQuery = @"SELECT s.studentId, ISNULL(s.nickname, s.name) AS displayName
                    FROM dbo.StudentParent sp INNER JOIN dbo.Student s ON sp.studentId=s.studentId
                    WHERE sp.parentId=@pid ORDER BY s.name";

                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(childListQuery, connection))
                {
                    command.Parameters.AddWithValue("@pid", _parentRecordId);
                    connection.Open();

                    using (var reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            ddlSidebarChild.Items.Add(new ListItem(
                                reader["displayName"].ToString(),
                                reader["studentId"].ToString()));
                        }
                    }
                }
            }
            catch { }

            if (ddlSidebarChild.Items.Count > 0)
            {
                string savedChildId = Session["selectedChildId"] as string;
                if (!string.IsNullOrEmpty(savedChildId) &&
                    ddlSidebarChild.Items.FindByValue(savedChildId) != null)
                {
                    ddlSidebarChild.SelectedValue = savedChildId;
                }
                else
                {
                    Session["selectedChildId"] = ddlSidebarChild.Items[0].Value;
                }

                _selectedChildId = ddlSidebarChild.SelectedValue;
                _selectedChildName = ddlSidebarChild.SelectedItem.Text;
                LoadStudentParentLinkId();
            }
        }

        private void LoadStudentParentLinkId()
        {
            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(
                    "SELECT studentParentId FROM dbo.StudentParent WHERE parentId=@pid AND studentId=@sid",
                    connection))
                {
                    command.Parameters.AddWithValue("@pid", _parentRecordId);
                    command.Parameters.AddWithValue("@sid", _selectedChildId);
                    connection.Open();
                    object result = command.ExecuteScalar();

                    if (result != null)
                    {
                        _studentParentLinkId = result.ToString();
                    }
                }
            }
            catch { }
        }

        protected void SidebarChildChanged(object sender, EventArgs e)
        {
            Session["selectedChildId"] = ddlSidebarChild.SelectedValue;
            _selectedChildId = ddlSidebarChild.SelectedValue;
            _selectedChildName = ddlSidebarChild.SelectedItem.Text;
            LoadStudentParentLinkId();
            pnlContent.Visible = true;
            pnlNoChild.Visible = false;
            pnlDetailsModal.Visible = false;
            _expandedResultIds = new List<string>();
            PopulateUnitFilter();
            RefreshAllQuizData();
        }

        protected void DdlUnit_Changed(object sender, EventArgs e)
        {
            RefreshAllQuizData();
        }

        private void ShowNoLinkedChildState()
        {
            pnlContent.Visible = false;
            pnlNoChild.Visible = true;
            litNoChildMsg.Text = T(
                "No linked child found. Please link a child account first.",
                "Tiada anak dipautkan. Sila pautkan akaun anak terlebih dahulu.");
        }

        private void ApplyPageLabels()
        {
            btnViewSelected.Text = T("View Selected Details", "Lihat Butiran Dipilih");
            btnAddWeakToStudyPlan.Text = T("Add Weak Topics to Study Plan",
                "Tambah Topik Lemah ke Pelan Belajar");
        }

        private string FetchChildNickname()
        {
            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(
                    "SELECT ISNULL(nickname, name) FROM dbo.Student WHERE studentId=@sid", connection))
                {
                    command.Parameters.AddWithValue("@sid", _selectedChildId);
                    connection.Open();
                    object result = command.ExecuteScalar();

                    if (result != null && result != DBNull.Value)
                    {
                        return result.ToString();
                    }
                }
            }
            catch { }
            return _selectedChildName;
        }

        private string GetSelectedUnitFilter()
        {
            return ddlUnit.SelectedValue ?? "";
        }

        // ══════════════════════════════════════════════════════════════
        //  UNIT FILTER DROPDOWN
        // ══════════════════════════════════════════════════════════════
        private void PopulateUnitFilter()
        {
            ddlUnit.Items.Clear();
            ddlUnit.Items.Add(new ListItem(T("All Units", "Semua Unit"), ""));

            try
            {
                const string unitListQuery = @"SELECT DISTINCT u.unitId, u.unitNameEN, u.unitNameBM
                    FROM dbo.Unit u
                    INNER JOIN dbo.Level l ON u.levelId=l.levelId
                    INNER JOIN dbo.Student s ON s.currentLevelId=l.levelId
                    WHERE s.studentId=@sid
                    UNION
                    SELECT DISTINCT u.unitId, u.unitNameEN, u.unitNameBM
                    FROM dbo.QuizResult qr INNER JOIN dbo.Quiz q ON qr.quizId=q.quizId
                    INNER JOIN dbo.Unit u ON q.unitId=u.unitId
                    WHERE qr.studentId=@sid
                    ORDER BY unitNameEN";

                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(unitListQuery, connection))
                {
                    command.Parameters.AddWithValue("@sid", _selectedChildId);
                    connection.Open();

                    using (var reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string unitDisplayName = CurrentLanguage == "BM" && reader["unitNameBM"] != DBNull.Value
                                ? reader["unitNameBM"].ToString()
                                : reader["unitNameEN"].ToString();
                            ddlUnit.Items.Add(new ListItem(unitDisplayName, reader["unitId"].ToString()));
                        }
                    }
                }
            }
            catch { }
        }

        // ══════════════════════════════════════════════════════════════
        //  PAGE DATA ORCHESTRATOR
        // ══════════════════════════════════════════════════════════════
        private void RefreshAllQuizData()
        {
            string childDisplayName = FetchChildNickname();
            _selectedChildName = childDisplayName;

            litHeroTitle.Text = string.Format(
                T("{0}'s Quiz Results", "Keputusan Kuiz {0}"), childDisplayName);
            litHeroSub.Text = T(
                "Track your child's quiz performance and identify areas for improvement.",
                "Jejak prestasi kuiz anak anda dan kenal pasti bidang untuk diperbaiki.");

            string unitFilter = GetSelectedUnitFilter();
            RenderSummaryStatistics(unitFilter);
            RenderScoreTrendChart(unitFilter);
            RenderUnitPerformanceBars(unitFilter);
            RenderRecentAttemptsTable(unitFilter);
            RenderWeakAndStrongAreas();
            RenderPerformanceInsightSummary(childDisplayName);
        }

        /// <summary>
        /// Builds the natural-language performance summary that tells the parent
        /// whether the child is excelling, progressing, or needs attention.
        /// </summary>
        private void RenderPerformanceInsightSummary(string childName)
        {
            try
            {
                string strongestUnit = null;
                string weakestUnit = null;
                decimal overallAverage = 0;
                int totalAttemptCount = 0;

                using (var connection = new SqlConnection(DatabaseConnectionString))
                {
                    connection.Open();

                    // Overall quiz average across all units
                    using (var command = new SqlCommand(
                        "SELECT AVG(percentage) AS avg, COUNT(*) AS cnt FROM dbo.QuizResult WHERE studentId=@sid",
                        connection))
                    {
                        command.Parameters.AddWithValue("@sid", _selectedChildId);

                        using (var reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                overallAverage = reader["avg"] != DBNull.Value
                                    ? Convert.ToDecimal(reader["avg"]) : 0;
                                totalAttemptCount = reader["cnt"] != DBNull.Value
                                    ? Convert.ToInt32(reader["cnt"]) : 0;
                            }
                        }
                    }

                    if (totalAttemptCount == 0)
                    {
                        pnlPerfSummary.Visible = false;
                        return;
                    }

                    strongestUnit = FindTopPerformingUnit(connection);
                    weakestUnit = FindLowestPerformingUnit(connection);
                }

                string performanceVerb = DescribePerformanceLevel(overallAverage);
                string summaryHtml = string.Format("<strong>{0}</strong> {1}.", childName, performanceVerb);

                if (!string.IsNullOrEmpty(strongestUnit))
                {
                    summaryHtml += " " + string.Format(
                        T("Strongest unit: <strong>{0}</strong>.", "Unit terkuat: <strong>{0}</strong>."),
                        strongestUnit);
                }
                if (!string.IsNullOrEmpty(weakestUnit) && weakestUnit != strongestUnit)
                {
                    summaryHtml += " " + string.Format(
                        T("Recommended revision: <strong>{0}</strong>.",
                          "Cadangan ulangkaji: <strong>{0}</strong>."), weakestUnit);
                }

                litPerfSummary.Text = summaryHtml;
                pnlPerfSummary.Visible = true;

                // Insight text
                string insightNarrative = BuildInsightNarrative(childName, overallAverage);
                litInsightsSummary.Text = insightNarrative;
                pnlInsightsSummary.Visible = true;
            }
            catch
            {
                pnlPerfSummary.Visible = false;
            }
        }

        private string FindTopPerformingUnit(SqlConnection connection)
        {
            const string topUnitQuery = @"SELECT TOP 1 
                CASE WHEN @lang='BM' THEN ISNULL(u.unitNameBM, u.unitNameEN) ELSE u.unitNameEN END AS uName, 
                AVG(qr.percentage) AS avg
                FROM dbo.QuizResult qr INNER JOIN dbo.Quiz q ON qr.quizId=q.quizId 
                INNER JOIN dbo.Unit u ON q.unitId=u.unitId
                WHERE qr.studentId=@sid GROUP BY u.unitId, u.unitNameEN, u.unitNameBM 
                ORDER BY AVG(qr.percentage) DESC";

            using (var command = new SqlCommand(topUnitQuery, connection))
            {
                command.Parameters.AddWithValue("@sid", _selectedChildId);
                command.Parameters.AddWithValue("@lang", CurrentLanguage);

                using (var reader = command.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        return reader["uName"]?.ToString();
                    }
                }
            }
            return null;
        }

        private string FindLowestPerformingUnit(SqlConnection connection)
        {
            const string weakUnitQuery = @"SELECT TOP 1 
                CASE WHEN @lang='BM' THEN ISNULL(u.unitNameBM, u.unitNameEN) ELSE u.unitNameEN END AS uName, 
                AVG(qr.percentage) AS avg
                FROM dbo.QuizResult qr INNER JOIN dbo.Quiz q ON qr.quizId=q.quizId 
                INNER JOIN dbo.Unit u ON q.unitId=u.unitId
                WHERE qr.studentId=@sid GROUP BY u.unitId, u.unitNameEN, u.unitNameBM 
                HAVING COUNT(*) > 0 ORDER BY AVG(qr.percentage) ASC";

            using (var command = new SqlCommand(weakUnitQuery, connection))
            {
                command.Parameters.AddWithValue("@sid", _selectedChildId);
                command.Parameters.AddWithValue("@lang", CurrentLanguage);

                using (var reader = command.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        return reader["uName"]?.ToString();
                    }
                }
            }
            return null;
        }

        private string DescribePerformanceLevel(decimal averageScore)
        {
            if (averageScore >= 80)
                return T("is doing excellently", "berprestasi cemerlang");
            else if (averageScore >= 60)
                return T("is doing well", "berprestasi baik");
            else if (averageScore >= 40)
                return T("needs some attention", "memerlukan sedikit perhatian");
            else
                return T("needs extra support", "memerlukan sokongan tambahan");
        }

        private string BuildInsightNarrative(string childName, decimal averageScore)
        {
            if (averageScore >= 80)
            {
                return string.Format(
                    T("{0} is consistently performing well. Average quiz score has remained above 80%.",
                      "{0} berprestasi cemerlang secara konsisten. Purata skor kuiz kekal melebihi 80%."),
                    childName);
            }
            else if (averageScore >= 60)
            {
                return string.Format(
                    T("{0} is making good progress. Keep encouraging regular practice.",
                      "{0} menunjukkan kemajuan yang baik. Teruskan menggalakkan latihan biasa."),
                    childName);
            }
            else
            {
                return string.Format(
                    T("{0} may benefit from extra revision in weaker units.",
                      "{0} mungkin mendapat manfaat daripada ulangkaji tambahan dalam unit yang lebih lemah."),
                    childName);
            }
        }

        // ══════════════════════════════════════════════════════════════
        //  SUMMARY STATISTICS CARD
        // ══════════════════════════════════════════════════════════════
        private void RenderSummaryStatistics(string unitFilter)
        {
            try
            {
                string unitClause = string.IsNullOrEmpty(unitFilter) ? "" : " AND q.unitId=@uid";
                string summaryQuery = string.Format(
                    @"SELECT COUNT(*) AS total, AVG(qr.percentage) AS avg, MAX(qr.percentage) AS highest,
                    SUM(CASE WHEN qr.resultStatus IN ('Pass','Passed') THEN 1 ELSE 0 END) AS passed
                    FROM dbo.QuizResult qr INNER JOIN dbo.Quiz q ON qr.quizId=q.quizId
                    WHERE qr.studentId=@sid{0}", unitClause);

                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(summaryQuery, connection))
                {
                    command.Parameters.AddWithValue("@sid", _selectedChildId);
                    if (!string.IsNullOrEmpty(unitFilter))
                    {
                        command.Parameters.AddWithValue("@uid", unitFilter);
                    }
                    connection.Open();

                    using (var reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            int totalAttempts = reader["total"] != DBNull.Value ? Convert.ToInt32(reader["total"]) : 0;
                            decimal averageScore = reader["avg"] != DBNull.Value ? Convert.ToDecimal(reader["avg"]) : 0;
                            decimal highestScore = reader["highest"] != DBNull.Value ? Convert.ToDecimal(reader["highest"]) : 0;
                            int passedCount = reader["passed"] != DBNull.Value ? Convert.ToInt32(reader["passed"]) : 0;
                            decimal passPercentage = totalAttempts > 0
                                ? Math.Round((decimal)passedCount / totalAttempts * 100, 0) : 0;

                            litAvgScore.Text = totalAttempts > 0
                                ? averageScore.ToString("F0") + "%" : T("No data", "Tiada data");
                            litHighScore.Text = totalAttempts > 0
                                ? highestScore.ToString("F0") + "%" : "-";
                            litPassRate.Text = totalAttempts > 0
                                ? passPercentage.ToString("F0") + "%" : "-";
                            litTotalAttempts.Text = totalAttempts.ToString();
                        }
                    }
                }
            }
            catch
            {
                litAvgScore.Text = "-";
                litHighScore.Text = "-";
                litPassRate.Text = "-";
                litTotalAttempts.Text = "0";
            }
        }

        // ══════════════════════════════════════════════════════════════
        //  SCORE TREND CHART (SVG polyline)
        // ══════════════════════════════════════════════════════════════
        private void RenderScoreTrendChart(string unitFilter)
        {
            pnlScoreTrend.Controls.Clear();
            var recentAttempts = new List<Tuple<DateTime, decimal, string>>();

            try
            {
                string unitClause = string.IsNullOrEmpty(unitFilter) ? "" : " AND q.unitId=@uid";
                string trendQuery = string.Format(
                    @"SELECT TOP 10 qr.percentage, qr.attemptedDate, q.quizTitleEN, q.quizTitleBM
                    FROM dbo.QuizResult qr INNER JOIN dbo.Quiz q ON qr.quizId=q.quizId
                    WHERE qr.studentId=@sid{0} ORDER BY qr.attemptedDate DESC", unitClause);

                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(trendQuery, connection))
                {
                    command.Parameters.AddWithValue("@sid", _selectedChildId);
                    if (!string.IsNullOrEmpty(unitFilter))
                    {
                        command.Parameters.AddWithValue("@uid", unitFilter);
                    }
                    connection.Open();

                    using (var reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string quizTitle = CurrentLanguage == "BM" && reader["quizTitleBM"] != DBNull.Value
                                ? reader["quizTitleBM"].ToString()
                                : reader["quizTitleEN"].ToString();
                            recentAttempts.Add(Tuple.Create(
                                Convert.ToDateTime(reader["attemptedDate"]),
                                Convert.ToDecimal(reader["percentage"]),
                                quizTitle));
                        }
                    }
                }
            }
            catch { }

            if (recentAttempts.Count == 0)
            {
                pnlNoTrend.Visible = true;
                return;
            }
            pnlNoTrend.Visible = false;
            recentAttempts.Reverse(); // chronological order

            StringBuilder chartHtml = BuildSvgTrendChart(recentAttempts);
            pnlScoreTrend.Controls.Add(new LiteralControl(chartHtml.ToString()));
        }

        private StringBuilder BuildSvgTrendChart(List<Tuple<DateTime, decimal, string>> dataPoints)
        {
            int pointCount = dataPoints.Count;
            var polylinePoints = new StringBuilder();
            var dotElements = new StringBuilder();

            for (int idx = 0; idx < pointCount; idx++)
            {
                double xPosition = pointCount == 1
                    ? 100.0
                    : (double)idx / (pointCount - 1) * 176 + 12;
                double yPosition = (double)(100 - dataPoints[idx].Item2) / 100.0 * 80 + 10;

                polylinePoints.AppendFormat("{0},{1} ",
                    xPosition.ToString("F1", CultureInfo.InvariantCulture),
                    yPosition.ToString("F1", CultureInfo.InvariantCulture));

                string dotColor = dataPoints[idx].Item2 >= 80 ? "#16A34A"
                    : dataPoints[idx].Item2 >= 50 ? "#6366F1" : "#DC2626";

                dotElements.AppendFormat(
                    "<circle cx=\"{0}\" cy=\"{1}\" r=\"3\" fill=\"{2}\" stroke=\"#fff\" stroke-width=\"1.5\"/>",
                    xPosition.ToString("F1", CultureInfo.InvariantCulture),
                    yPosition.ToString("F1", CultureInfo.InvariantCulture),
                    dotColor);
            }

            var chartHtml = new StringBuilder();
            chartHtml.Append("<div class=\"pt-line-chart-wrap\">");
            chartHtml.Append("<div class=\"pt-line-chart-y\"><span>100%</span><span>50%</span><span>0%</span></div>");
            chartHtml.Append("<svg class=\"pt-line-chart-svg\" viewBox=\"0 0 200 100\" preserveAspectRatio=\"none\">");
            chartHtml.Append("<line x1=\"12\" y1=\"10\" x2=\"188\" y2=\"10\" stroke=\"#E2E8F0\" stroke-width=\"0.3\"/>");
            chartHtml.Append("<line x1=\"12\" y1=\"50\" x2=\"188\" y2=\"50\" stroke=\"#E2E8F0\" stroke-width=\"0.3\" stroke-dasharray=\"2,2\"/>");
            chartHtml.Append("<line x1=\"12\" y1=\"90\" x2=\"188\" y2=\"90\" stroke=\"#E2E8F0\" stroke-width=\"0.3\"/>");
            chartHtml.AppendFormat(
                "<polyline points=\"{0}\" fill=\"none\" stroke=\"#6366F1\" stroke-width=\"1.2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>",
                polylinePoints.ToString().Trim());
            chartHtml.Append(dotElements.ToString());
            chartHtml.Append("</svg>");
            chartHtml.Append("<div class=\"pt-line-chart-x\">");
            foreach (var point in dataPoints)
            {
                chartHtml.AppendFormat("<span>{0}</span>", point.Item1.ToString("dd MMM"));
            }
            chartHtml.Append("</div></div>");

            return chartHtml;
        }

        // ══════════════════════════════════════════════════════════════
        //  UNIT PERFORMANCE BARS
        // ══════════════════════════════════════════════════════════════
        private void RenderUnitPerformanceBars(string unitFilter)
        {
            pnlUnitPerformance.Controls.Clear();
            var unitScores = new List<Tuple<string, decimal>>();

            try
            {
                string unitClause = string.IsNullOrEmpty(unitFilter) ? "" : " AND q.unitId=@uid";
                string perfQuery = string.Format(
                    @"SELECT u.unitNameEN, u.unitNameBM, AVG(qr.percentage) AS avg
                    FROM dbo.QuizResult qr INNER JOIN dbo.Quiz q ON qr.quizId=q.quizId
                    INNER JOIN dbo.Unit u ON q.unitId=u.unitId
                    WHERE qr.studentId=@sid{0} GROUP BY u.unitNameEN, u.unitNameBM ORDER BY avg DESC",
                    unitClause);

                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(perfQuery, connection))
                {
                    command.Parameters.AddWithValue("@sid", _selectedChildId);
                    if (!string.IsNullOrEmpty(unitFilter))
                    {
                        command.Parameters.AddWithValue("@uid", unitFilter);
                    }
                    connection.Open();

                    using (var reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string unitName = CurrentLanguage == "BM" && reader["unitNameBM"] != DBNull.Value
                                ? reader["unitNameBM"].ToString()
                                : reader["unitNameEN"].ToString();
                            unitScores.Add(Tuple.Create(unitName, Convert.ToDecimal(reader["avg"])));
                        }
                    }
                }
            }
            catch { }

            if (unitScores.Count == 0)
            {
                pnlNoUnitPerf.Visible = true;
                return;
            }
            pnlNoUnitPerf.Visible = false;

            StringBuilder barsHtml = new StringBuilder();
            foreach (var unitScore in unitScores)
            {
                string barColor;
                string gradeLabel;

                if (unitScore.Item2 >= 80)
                {
                    barColor = "#16A34A";
                    gradeLabel = T("Excellent", "Cemerlang");
                }
                else if (unitScore.Item2 >= 60)
                {
                    barColor = "#F59E0B";
                    gradeLabel = T("Good", "Baik");
                }
                else if (unitScore.Item2 >= 40)
                {
                    barColor = "#F97316";
                    gradeLabel = T("Needs Practice", "Perlu Latihan");
                }
                else
                {
                    barColor = "#DC2626";
                    gradeLabel = T("Weak", "Lemah");
                }

                barsHtml.AppendFormat(@"<div class=""pt-unit-perf-row"">
                    <div class=""pt-unit-perf-label"">{0}</div>
                    <div class=""pt-unit-perf-bar-wrap""><div class=""pt-unit-perf-bar"" style=""width:{1}%;background:{2};""></div></div>
                    <span class=""pt-unit-perf-pct"">{1:F0}%</span>
                    <span class=""pt-unit-perf-badge"" style=""color:{2};"">{3}</span>
                </div>", unitScore.Item1, unitScore.Item2, barColor, gradeLabel);
            }
            pnlUnitPerformance.Controls.Add(new LiteralControl(barsHtml.ToString()));
        }

        // ══════════════════════════════════════════════════════════════
        //  RECENT ATTEMPTS TABLE
        // ══════════════════════════════════════════════════════════════
        private void RenderRecentAttemptsTable(string unitFilter)
        {
            pnlAttempts.Controls.Clear();

            try
            {
                string unitClause = string.IsNullOrEmpty(unitFilter) ? "" : " AND q.unitId=@uid";
                string attemptsQuery = string.Format(
                    @"SELECT qr.resultId, q.quizTitleEN, q.quizTitleBM, u.unitNameEN, u.unitNameBM,
                    qr.percentage, qr.attemptedDate, qr.resultStatus
                    FROM dbo.QuizResult qr INNER JOIN dbo.Quiz q ON qr.quizId=q.quizId
                    LEFT JOIN dbo.Unit u ON q.unitId=u.unitId
                    WHERE qr.studentId=@sid{0} ORDER BY qr.attemptedDate DESC", unitClause);

                var attemptRows = new List<QuizAttemptRow>();

                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(attemptsQuery, connection))
                {
                    command.Parameters.AddWithValue("@sid", _selectedChildId);
                    if (!string.IsNullOrEmpty(unitFilter))
                    {
                        command.Parameters.AddWithValue("@uid", unitFilter);
                    }
                    connection.Open();

                    using (var reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            attemptRows.Add(new QuizAttemptRow
                            {
                                ResultId = reader["resultId"].ToString(),
                                QuizTitle = CurrentLanguage == "BM" && reader["quizTitleBM"] != DBNull.Value
                                    ? reader["quizTitleBM"].ToString() : reader["quizTitleEN"].ToString(),
                                UnitName = reader["unitNameEN"] != DBNull.Value
                                    ? (CurrentLanguage == "BM" && reader["unitNameBM"] != DBNull.Value
                                        ? reader["unitNameBM"].ToString() : reader["unitNameEN"].ToString())
                                    : "-",
                                ScorePercentage = reader["percentage"] != DBNull.Value
                                    ? Convert.ToDecimal(reader["percentage"]) : 0,
                                AttemptDate = reader["attemptedDate"] != DBNull.Value
                                    ? Convert.ToDateTime(reader["attemptedDate"]) : DateTime.MinValue,
                                ResultStatus = reader["resultStatus"] != DBNull.Value
                                    ? reader["resultStatus"].ToString() : ""
                            });
                        }
                    }
                }

                if (attemptRows.Count == 0)
                {
                    pnlNoAttempts.Visible = true;
                    return;
                }
                pnlNoAttempts.Visible = false;

                StringBuilder tableHtml = BuildAttemptsTableHtml(attemptRows);
                pnlAttempts.Controls.Add(new LiteralControl(tableHtml.ToString()));
            }
            catch
            {
                pnlNoAttempts.Visible = true;
            }
        }

        private StringBuilder BuildAttemptsTableHtml(List<QuizAttemptRow> rows)
        {
            StringBuilder tableHtml = new StringBuilder();
            tableHtml.Append("<table class=\"pt-attempts-table\"><thead><tr>");
            tableHtml.AppendFormat("<th></th><th>{0}</th><th>{1}</th><th>{2}</th><th>{3}</th><th>{4}</th><th></th>",
                T("Quiz", "Kuiz"), T("Unit", "Unit"), T("Score", "Skor"),
                T("Date", "Tarikh"), T("Status", "Status"));
            tableHtml.Append("</tr></thead><tbody>");

            foreach (var row in rows)
            {
                string statusCss = (row.ResultStatus == "Pass" || row.ResultStatus == "Passed")
                    ? "pt-status-pass" : "pt-status-fail";
                string statusLabel = (row.ResultStatus == "Pass" || row.ResultStatus == "Passed")
                    ? T("Pass", "Lulus") : T("Fail", "Gagal");

                tableHtml.AppendFormat(
                    @"<tr class=""pt-attempts-row"" onclick=""selectSingleQuiz('{0}');"" style=""cursor:pointer;"">
                    <td><input type=""checkbox"" class=""pt-quiz-check"" value=""{0}"" onclick=""event.stopPropagation();updateSelectedQuizzes()"" /></td>
                    <td class=""pt-attempts-quiz"">{1}</td>
                    <td>{2}</td>
                    <td><strong>{3:F0}%</strong></td>
                    <td>{4}</td>
                    <td><span class=""pt-status-badge {5}"">{6}</span></td>
                    <td><button type=""button"" class=""pt-btn-view-detail"" onclick=""event.stopPropagation();selectSingleQuiz('{0}');"">&#128065; {7}</button></td>
                </tr>", row.ResultId, row.QuizTitle, row.UnitName, row.ScorePercentage,
                    row.AttemptDate != DateTime.MinValue ? row.AttemptDate.ToString("dd MMM yyyy") : "-",
                    statusCss, statusLabel, T("View", "Lihat"));
            }

            tableHtml.Append("</tbody></table>");

            // Client-side checkbox management script
            tableHtml.Append(@"<script>
function updateSelectedQuizzes(){var cbs=document.querySelectorAll('.pt-quiz-check');var ids=[];cbs.forEach(function(c){if(c.checked)ids.push(c.value);});document.getElementById('" + hidSelectedResults.ClientID + @"').value=ids.join(',');}
function selectSingleQuiz(id){document.getElementById('" + hidSelectedResults.ClientID + @"').value=id;document.getElementById('" + btnViewSelected.ClientID + @"').click();}
</script>");

            return tableHtml;
        }

        private class QuizAttemptRow
        {
            public string ResultId;
            public string QuizTitle;
            public string UnitName;
            public decimal ScorePercentage;
            public DateTime AttemptDate;
            public string ResultStatus;
        }

        // ══════════════════════════════════════════════════════════════
        //  QUIZ DETAILS MODAL
        // ══════════════════════════════════════════════════════════════
        protected void BtnViewSelected_Click(object sender, EventArgs e)
        {
            string selectedIds = hidSelectedResults.Value;
            if (string.IsNullOrWhiteSpace(selectedIds))
            {
                ShowFeedbackMessage(
                    T("Please select at least one quiz.", "Sila pilih sekurang-kurangnya satu kuiz."),
                    false);
                RefreshAllQuizData();
                return;
            }

            var resultIdList = selectedIds.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries).ToList();
            BuildQuizDetailsModal(resultIdList);
            pnlDetailsModal.Visible = true;
            RefreshAllQuizData();
        }

        protected void BtnCloseDetails_Click(object sender, EventArgs e)
        {
            pnlDetailsModal.Visible = false;
            RefreshAllQuizData();
        }

        private void BuildQuizDetailsModal(List<string> resultIds)
        {
            pnlDetailsContent.Controls.Clear();
            StringBuilder detailsHtml = new StringBuilder();
            var expandedIds = _expandedResultIds;

            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                {
                    connection.Open();

                    foreach (string resultId in resultIds)
                    {
                        string quizTitle = "";
                        string quizStatus = "";
                        decimal scorePercent = 0;
                        int correctAnswerCount = 0;
                        int incorrectAnswerCount = 0;

                        // Fetch quiz result metadata
                        using (var command = new SqlCommand(
                            @"SELECT q.quizTitleEN, q.quizTitleBM, qr.percentage, qr.resultStatus,
                            (SELECT COUNT(*) FROM dbo.QuizAnswer WHERE resultId=qr.resultId AND isCorrect=1) AS correctCount,
                            (SELECT COUNT(*) FROM dbo.QuizAnswer WHERE resultId=qr.resultId AND isCorrect=0) AS incorrectCount
                            FROM dbo.QuizResult qr INNER JOIN dbo.Quiz q ON qr.quizId=q.quizId
                            WHERE qr.resultId=@rid AND qr.studentId=@sid", connection))
                        {
                            command.Parameters.AddWithValue("@rid", resultId);
                            command.Parameters.AddWithValue("@sid", _selectedChildId);

                            using (var reader = command.ExecuteReader())
                            {
                                if (!reader.Read()) continue;
                                quizTitle = CurrentLanguage == "BM" && reader["quizTitleBM"] != DBNull.Value
                                    ? reader["quizTitleBM"].ToString() : reader["quizTitleEN"].ToString();
                                scorePercent = Convert.ToDecimal(reader["percentage"]);
                                quizStatus = reader["resultStatus"].ToString();
                                correctAnswerCount = Convert.ToInt32(reader["correctCount"]);
                                incorrectAnswerCount = Convert.ToInt32(reader["incorrectCount"]);
                            }
                        }

                        string statusBadgeHtml = (quizStatus == "Pass" || quizStatus == "Passed")
                            ? "<span class='pt-status-badge pt-status-pass'>" + T("Pass", "Lulus") + "</span>"
                            : "<span class='pt-status-badge pt-status-fail'>" + T("Fail", "Gagal") + "</span>";

                        detailsHtml.AppendFormat(@"<div class=""pt-quiz-detail-card"">
                            <div class=""pt-quiz-detail-header"">
                                <h4>{0}</h4>{1}
                            </div>
                            <div class=""pt-quiz-detail-stats"">
                                <span><i class=""bi bi-percent""></i> {2:F0}%</span>
                                <span class=""text-success""><i class=""bi bi-check-circle""></i> {3} {4}</span>
                                <span class=""text-error""><i class=""bi bi-x-circle""></i> {5} {6}</span>
                            </div>", quizTitle, statusBadgeHtml, scorePercent,
                            correctAnswerCount, T("correct", "betul"),
                            incorrectAnswerCount, T("incorrect", "salah"));

                        // Toggle for incorrect questions section
                        bool isExpanded = expandedIds.Contains(resultId);
                        string toggleLabel = string.Format(
                            T("Incorrect Questions ({0})", "Soalan Salah ({0})"), incorrectAnswerCount);

                        detailsHtml.AppendFormat(@"<div class=""pt-incorrect-toggle-wrap"">
                            <button type=""button"" class=""pt-incorrect-toggle"" onclick=""document.getElementById('{0}').value='{1}';document.getElementById('{2}').click();"">
                                <i class=""bi {3}""></i> {4}
                            </button>
                        </div>", hidToggleResult.ClientID, resultId, btnToggleIncorrect.ClientID,
                            isExpanded ? "bi-chevron-up" : "bi-chevron-down", toggleLabel);

                        if (isExpanded && incorrectAnswerCount > 0)
                        {
                            RenderIncorrectQuestions(connection, resultId, detailsHtml);
                        }

                        detailsHtml.Append("</div>");
                    }
                }
            }
            catch { }

            pnlDetailsContent.Controls.Add(new LiteralControl(detailsHtml.ToString()));
        }

        private void RenderIncorrectQuestions(SqlConnection connection,
            string resultId, StringBuilder outputHtml)
        {
            outputHtml.Append("<div class=\"pt-incorrect-list\">");

            using (var command = new SqlCommand(
                @"SELECT qa.selectedAnswer, q.questionTextEN, q.questionTextBM,
                q.correctAnswer, q.optionA_EN, q.optionA_BM, q.optionB_EN, q.optionB_BM,
                q.optionC_EN, q.optionC_BM, q.optionD_EN, q.optionD_BM
                FROM dbo.QuizAnswer qa INNER JOIN dbo.Question q ON qa.questionId=q.questionId
                WHERE qa.resultId=@rid AND qa.isCorrect=0", connection))
            {
                command.Parameters.AddWithValue("@rid", resultId);

                using (var reader = command.ExecuteReader())
                {
                    int questionNumber = 1;
                    while (reader.Read())
                    {
                        string questionText = CurrentLanguage == "BM" && reader["questionTextBM"] != DBNull.Value
                            ? reader["questionTextBM"].ToString()
                            : reader["questionTextEN"].ToString();
                        string childAnswer = reader["selectedAnswer"] != DBNull.Value
                            ? reader["selectedAnswer"].ToString() : "-";
                        string correctAnswerText = ResolveCorrectAnswerText(reader);

                        outputHtml.AppendFormat(@"<div class=""pt-question-review-card"">
                            <div class=""pt-qr-question""><strong>Q{0}.</strong> {1}</div>
                            <div class=""pt-qr-answers"">
                                <span class=""pt-qr-child-ans""><i class=""bi bi-x-circle-fill""></i> {2}: {3}</span>
                                <span class=""pt-qr-correct-ans""><i class=""bi bi-check-circle-fill""></i> {4}: {5}</span>
                            </div>
                        </div>", questionNumber++, questionText,
                            T("Your child's answer", "Jawapan anak"), childAnswer,
                            T("Correct answer", "Jawapan betul"), correctAnswerText);
                    }
                }
            }

            outputHtml.Append("</div>");
        }

        protected void BtnToggleIncorrect_Click(object sender, EventArgs e)
        {
            string toggledResultId = hidToggleResult.Value;
            if (string.IsNullOrEmpty(toggledResultId))
            {
                return;
            }

            var expandedIds = _expandedResultIds;
            if (expandedIds.Contains(toggledResultId))
            {
                expandedIds.Remove(toggledResultId);
            }
            else
            {
                expandedIds.Add(toggledResultId);
            }
            _expandedResultIds = expandedIds;

            // Rebuild modal with current selection preserved
            string selectedIds = hidSelectedResults.Value;
            if (!string.IsNullOrEmpty(selectedIds))
            {
                var resultIdList = selectedIds.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries).ToList();
                BuildQuizDetailsModal(resultIdList);
                pnlDetailsModal.Visible = true;
            }
            RefreshAllQuizData();
        }

        /// <summary>
        /// Resolves the correct answer display text by mapping single-letter answers (A/B/C/D)
        /// to their full option text in the appropriate language.
        /// </summary>
        private string ResolveCorrectAnswerText(SqlDataReader reader)
        {
            string correctKey = reader["correctAnswer"] != DBNull.Value
                ? reader["correctAnswer"].ToString().Trim() : "";

            if (correctKey.Length == 1)
            {
                string columnName = "";
                if (correctKey == "A")
                    columnName = CurrentLanguage == "BM" ? "optionA_BM" : "optionA_EN";
                else if (correctKey == "B")
                    columnName = CurrentLanguage == "BM" ? "optionB_BM" : "optionB_EN";
                else if (correctKey == "C")
                    columnName = CurrentLanguage == "BM" ? "optionC_BM" : "optionC_EN";
                else if (correctKey == "D")
                    columnName = CurrentLanguage == "BM" ? "optionD_BM" : "optionD_EN";

                if (!string.IsNullOrEmpty(columnName) && reader[columnName] != DBNull.Value)
                {
                    return reader[columnName].ToString();
                }
            }
            return correctKey;
        }

        // ══════════════════════════════════════════════════════════════
        //  WEAK & STRONG AREAS
        // ══════════════════════════════════════════════════════════════
        private void RenderWeakAndStrongAreas()
        {
            pnlWeakAreas.Controls.Clear();
            pnlStrongAreas.Controls.Clear();

            var unitPerformanceStats = FetchUnitPerformanceStats();

            RenderWeakAreasPanel(unitPerformanceStats);
            RenderStrongAreasPanel(unitPerformanceStats);
            litMostImproved.Text = CalculateMostImprovedUnit();
        }

        private List<UnitPerformanceStat> FetchUnitPerformanceStats()
        {
            var stats = new List<UnitPerformanceStat>();

            try
            {
                const string statsQuery = @"SELECT u.unitId, u.unitNameEN, u.unitNameBM, AVG(qr.percentage) AS avg,
                    (SELECT COUNT(*) FROM dbo.QuizAnswer qa INNER JOIN dbo.QuizResult qr2 ON qa.resultId=qr2.resultId
                        INNER JOIN dbo.Quiz q2 ON qr2.quizId=q2.quizId WHERE qr2.studentId=@sid AND q2.unitId=u.unitId AND qa.isCorrect=0) AS incorrectCount
                    FROM dbo.QuizResult qr INNER JOIN dbo.Quiz q ON qr.quizId=q.quizId
                    INNER JOIN dbo.Unit u ON q.unitId=u.unitId
                    WHERE qr.studentId=@sid GROUP BY u.unitId, u.unitNameEN, u.unitNameBM";

                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(statsQuery, connection))
                {
                    command.Parameters.AddWithValue("@sid", _selectedChildId);
                    connection.Open();

                    using (var reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            stats.Add(new UnitPerformanceStat
                            {
                                UnitId = reader["unitId"].ToString(),
                                UnitName = CurrentLanguage == "BM" && reader["unitNameBM"] != DBNull.Value
                                    ? reader["unitNameBM"].ToString() : reader["unitNameEN"].ToString(),
                                AverageScore = Convert.ToDecimal(reader["avg"]),
                                IncorrectQuestionCount = Convert.ToInt32(reader["incorrectCount"])
                            });
                        }
                    }
                }
            }
            catch { }

            return stats;
        }

        private void RenderWeakAreasPanel(List<UnitPerformanceStat> allStats)
        {
            // Weak: average below 60%, or the single lowest if none below 60
            var weakUnits = allStats.Where(u => u.AverageScore < 60)
                .OrderBy(u => u.AverageScore).ToList();

            if (weakUnits.Count == 0 && allStats.Count > 0)
            {
                weakUnits = allStats.OrderBy(u => u.AverageScore)
                    .Take(1).Where(u => u.AverageScore < 80).ToList();
            }

            if (weakUnits.Count > 0)
            {
                pnlNoWeak.Visible = false;
                StringBuilder weakHtml = new StringBuilder();

                foreach (var unit in weakUnits)
                {
                    weakHtml.AppendFormat(@"<div class=""pt-weak-item"">
                        <div class=""pt-weak-item-name""><i class=""bi bi-book""></i> {0}</div>
                        <div class=""pt-weak-item-detail""><i class=""bi bi-x-circle""></i> {1}: {2}</div>
                        <div class=""pt-weak-item-detail""><i class=""bi bi-percent""></i> {3}: {4:F0}%</div>
                        <div class=""pt-weak-item-action"">{5}</div>
                    </div>", unit.UnitName,
                        T("Incorrect questions", "Soalan salah"), unit.IncorrectQuestionCount,
                        T("Average", "Purata"), unit.AverageScore,
                        T("Revise this unit to improve scores.",
                          "Ulangkaji unit ini untuk meningkatkan markah."));
                }

                pnlWeakAreas.Controls.Add(new LiteralControl(weakHtml.ToString()));
                pnlWeakAction.Visible = true;
                btnAddWeakToStudyPlan.Visible = true;

                // Actionable next-step recommendation
                string topWeakUnit = weakUnits[0].UnitName;
                litNextStepSummary.Text = string.Format(
                    T("Focus on revising <strong>{0}</strong> this week.",
                      "Fokus pada mengulangkaji <strong>{0}</strong> minggu ini."), topWeakUnit);
                pnlNextStepSummary.Visible = true;
            }
            else
            {
                pnlNoWeak.Visible = true;
                pnlWeakAction.Visible = false;
                btnAddWeakToStudyPlan.Visible = false;
                pnlNextStepSummary.Visible = false;
            }
        }

        private void RenderStrongAreasPanel(List<UnitPerformanceStat> allStats)
        {
            var strongUnits = allStats.Where(u => u.AverageScore >= 70)
                .OrderByDescending(u => u.AverageScore).ToList();

            if (strongUnits.Count > 0)
            {
                pnlNoStrong.Visible = false;
                StringBuilder strongHtml = new StringBuilder();

                foreach (var unit in strongUnits)
                {
                    string achievementBadge = unit.AverageScore >= 90
                        ? T("Excellent", "Cemerlang")
                        : T("Good", "Baik");
                    string badgeColor = unit.AverageScore >= 90 ? "#16A34A" : "#F59E0B";

                    strongHtml.AppendFormat(@"<div class=""pt-strong-item"">
                        <div class=""pt-strong-item-name""><i class=""bi bi-check-circle-fill"" style=""color:{3};""></i> {0} <span class=""pt-strong-badge"" style=""color:{3};"">{4}</span></div>
                        <div class=""pt-strong-item-bar""><div style=""width:{2:F0}%;background:{3};height:4px;border-radius:99px;""></div></div>
                    </div>", unit.UnitName, T("Average", "Purata"), unit.AverageScore,
                        badgeColor, achievementBadge);
                }

                pnlStrongAreas.Controls.Add(new LiteralControl(strongHtml.ToString()));
            }
            else
            {
                pnlNoStrong.Visible = true;
            }
        }

        /// <summary>
        /// Identifies the unit with the greatest improvement by comparing the average
        /// of the first half of attempts vs the second half (chronological order).
        /// </summary>
        private string CalculateMostImprovedUnit()
        {
            try
            {
                const string historyQuery = @"SELECT q.unitId, u.unitNameEN, u.unitNameBM, 
                    qr.percentage, qr.attemptedDate
                    FROM dbo.QuizResult qr INNER JOIN dbo.Quiz q ON qr.quizId=q.quizId
                    INNER JOIN dbo.Unit u ON q.unitId=u.unitId
                    WHERE qr.studentId=@sid ORDER BY q.unitId, qr.attemptedDate";

                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(historyQuery, connection))
                {
                    command.Parameters.AddWithValue("@sid", _selectedChildId);
                    connection.Open();

                    var scoresByUnit = new Dictionary<string, List<decimal>>();
                    var unitNameLookup = new Dictionary<string, string>();

                    using (var reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string unitId = reader["unitId"].ToString();
                            if (!scoresByUnit.ContainsKey(unitId))
                            {
                                scoresByUnit[unitId] = new List<decimal>();
                                unitNameLookup[unitId] = CurrentLanguage == "BM" && reader["unitNameBM"] != DBNull.Value
                                    ? reader["unitNameBM"].ToString()
                                    : reader["unitNameEN"].ToString();
                            }
                            scoresByUnit[unitId].Add(Convert.ToDecimal(reader["percentage"]));
                        }
                    }

                    string mostImprovedUnitId = "";
                    decimal largestImprovement = 0;

                    foreach (var entry in scoresByUnit)
                    {
                        if (entry.Value.Count < 2) continue;

                        int halfwayIndex = entry.Value.Count / 2;
                        decimal earlierAverage = entry.Value.Take(halfwayIndex).Average();
                        decimal laterAverage = entry.Value.Skip(halfwayIndex).Average();
                        decimal improvement = laterAverage - earlierAverage;

                        if (improvement > largestImprovement)
                        {
                            largestImprovement = improvement;
                            mostImprovedUnitId = entry.Key;
                        }
                    }

                    if (!string.IsNullOrEmpty(mostImprovedUnitId))
                    {
                        return string.Format("{0} (+{1:F0}%)",
                            unitNameLookup[mostImprovedUnitId], largestImprovement);
                    }
                }
            }
            catch { }

            return T("Not enough quiz history yet.", "Belum cukup sejarah kuiz.");
        }

        private class UnitPerformanceStat
        {
            public string UnitId;
            public string UnitName;
            public decimal AverageScore;
            public int IncorrectQuestionCount;
        }

        // ══════════════════════════════════════════════════════════════
        //  ADD WEAK TOPICS TO STUDY PLAN
        // ══════════════════════════════════════════════════════════════
        protected void BtnAddWeakToStudyPlan_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(_studentParentLinkId))
            {
                ShowFeedbackMessage(
                    T("Unable to find child link.", "Tidak dapat mencari pautan anak."), false);
                RefreshAllQuizData();
                return;
            }

            try
            {
                var weakUnitsList = new List<Tuple<string, string>>();

                using (var connection = new SqlConnection(DatabaseConnectionString))
                {
                    connection.Open();

                    using (var command = new SqlCommand(
                        @"SELECT u.unitId, u.unitNameEN, u.unitNameBM, AVG(qr.percentage) AS avg
                        FROM dbo.QuizResult qr INNER JOIN dbo.Quiz q ON qr.quizId=q.quizId
                        INNER JOIN dbo.Unit u ON q.unitId=u.unitId
                        WHERE qr.studentId=@sid GROUP BY u.unitId, u.unitNameEN, u.unitNameBM 
                        HAVING AVG(qr.percentage) < 80 ORDER BY avg", connection))
                    {
                        command.Parameters.AddWithValue("@sid", _selectedChildId);

                        using (var reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                string unitName = CurrentLanguage == "BM" && reader["unitNameBM"] != DBNull.Value
                                    ? reader["unitNameBM"].ToString()
                                    : reader["unitNameEN"].ToString();
                                weakUnitsList.Add(Tuple.Create(reader["unitId"].ToString(), unitName));
                            }
                        }
                    }
                }

                if (weakUnitsList.Count == 0)
                {
                    ShowFeedbackMessage(
                        T("No weak topics to add.", "Tiada topik lemah untuk ditambah."), false);
                    RefreshAllQuizData();
                    return;
                }

                // Pre-fill task modal with revision task details
                string topicNamesCombined = string.Join(", ", weakUnitsList.Select(w => w.Item2));
                txtTaskName.Text = string.Format(T("Revise {0}", "Ulangkaji {0}"), topicNamesCombined);
                txtSuggestedAction.Text = string.Format(
                    T("Spend 20 minutes reviewing {0} to improve quiz scores.",
                      "Luangkan 20 minit mengulangkaji {0} untuk memperbaiki skor kuiz."),
                    topicNamesCombined);

                litTaskModalSub.Text = string.Format(
                    T("Review and add a revision task for {0}.",
                      "Semak dan tambah tugasan ulangkaji untuk {0}."), _selectedChildName);
                btnConfirmAddTask.Text = T("Add Task", "Tambah Tugasan");

                pnlTaskModal.CssClass = "pt-task-modal-overlay";
            }
            catch
            {
                ShowFeedbackMessage(T("An error occurred.", "Ralat berlaku."), false);
            }
            RefreshAllQuizData();
        }

        protected void BtnConfirmAddTask_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtTaskName.Text))
            {
                ShowFeedbackMessage(
                    T("Please enter a task name.", "Sila masukkan nama tugasan."), false);
                RefreshAllQuizData();
                return;
            }

            if (string.IsNullOrEmpty(_studentParentLinkId))
            {
                ShowFeedbackMessage(
                    T("Unable to find child link.", "Tidak dapat mencari pautan anak."), false);
                RefreshAllQuizData();
                return;
            }

            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                {
                    connection.Open();

                    // Find or create active study plan
                    string activePlanId = null;
                    using (var command = new SqlCommand(
                        "SELECT TOP 1 studyPlanId FROM dbo.StudyPlan WHERE studentParentId=@spid AND status='Ongoing' ORDER BY createdAt DESC",
                        connection))
                    {
                        command.Parameters.AddWithValue("@spid", _studentParentLinkId);
                        activePlanId = command.ExecuteScalar() as string;
                    }

                    using (var transaction = connection.BeginTransaction())
                    {
                        try
                        {
                            if (string.IsNullOrEmpty(activePlanId))
                            {
                                activePlanId = GenerateSequentialId(connection, transaction, "StudyPlan", "studyPlanId", "STP");

                                using (var command = new SqlCommand(
                                    @"INSERT INTO dbo.StudyPlan (studyPlanId,studentParentId,createdByUserId,planTitle,startDate,endDate,status,createdAt)
                                    VALUES(@id,@spid,@uid,@title,@start,@end,'Ongoing',@now)",
                                    connection, transaction))
                                {
                                    command.Parameters.AddWithValue("@id", activePlanId);
                                    command.Parameters.AddWithValue("@spid", _studentParentLinkId);
                                    command.Parameters.AddWithValue("@uid", _authenticatedUserId);
                                    command.Parameters.AddWithValue("@title",
                                        T("Quiz Revision Plan", "Pelan Ulangkaji Kuiz"));
                                    command.Parameters.AddWithValue("@start", DateTime.Today);
                                    command.Parameters.AddWithValue("@end", DateTime.Today.AddDays(14));
                                    command.Parameters.AddWithValue("@now", DateTime.Now);
                                    command.ExecuteNonQuery();
                                }
                            }

                            // Check for duplicate task
                            bool duplicateExists = false;
                            using (var checkCommand = new SqlCommand(
                                "SELECT COUNT(*) FROM dbo.SPTask WHERE studyPlanId=@spid AND taskTitle=@title AND isCompleted=0",
                                connection, transaction))
                            {
                                checkCommand.Parameters.AddWithValue("@spid", activePlanId);
                                checkCommand.Parameters.AddWithValue("@title", txtTaskName.Text.Trim());
                                duplicateExists = (int)checkCommand.ExecuteScalar() > 0;
                            }

                            if (duplicateExists)
                            {
                                transaction.Rollback();
                                pnlTaskModal.CssClass = "pt-task-modal-overlay pt-task-modal-hidden";
                                ShowFeedbackMessage(
                                    T("This task has already been added to the study plan.",
                                      "Tugasan ini telah ditambah ke pelan belajar."), true);
                                RefreshAllQuizData();
                                return;
                            }

                            int maxOrder = 0;
                            using (var command = new SqlCommand(
                                "SELECT ISNULL(MAX(orderNo),0) FROM dbo.SPTask WHERE studyPlanId=@spid",
                                connection, transaction))
                            {
                                command.Parameters.AddWithValue("@spid", activePlanId);
                                maxOrder = (int)command.ExecuteScalar();
                            }

                            string taskId = GenerateSequentialId(connection, transaction, "SPTask", "spTaskId", "SPT");

                            using (var command = new SqlCommand(
                                @"INSERT INTO dbo.SPTask (spTaskId,studyPlanId,taskTitle,suggestedAction,orderNo,isCompleted,completedAt)
                                VALUES(@id,@spid,@title,@action,@order,0,NULL)",
                                connection, transaction))
                            {
                                command.Parameters.AddWithValue("@id", taskId);
                                command.Parameters.AddWithValue("@spid", activePlanId);
                                command.Parameters.AddWithValue("@title", txtTaskName.Text.Trim());
                                command.Parameters.AddWithValue("@action",
                                    string.IsNullOrEmpty(txtSuggestedAction.Text)
                                        ? (object)DBNull.Value : txtSuggestedAction.Text.Trim());
                                command.Parameters.AddWithValue("@order", maxOrder + 1);
                                command.ExecuteNonQuery();
                            }

                            // Notify child
                            string childUserId = LookupChildUserId(connection, transaction);
                            if (!string.IsNullOrEmpty(childUserId))
                            {
                                CreateNotificationRecord(connection, transaction, childUserId,
                                    "New study task added", "Tugasan belajar baharu ditambah",
                                    "Your parent added a new study task: " + txtTaskName.Text.Trim() + ".",
                                    "Ibu bapa anda menambah tugasan belajar baharu: " + txtTaskName.Text.Trim() + ".");
                            }

                            transaction.Commit();
                            txtTaskName.Text = "";
                            txtSuggestedAction.Text = "";
                            pnlTaskModal.CssClass = "pt-task-modal-overlay pt-task-modal-hidden";
                            ShowFeedbackMessage(
                                T("The task has been added to the study plan.",
                                  "Tugasan telah ditambah ke pelan belajar."), true);
                        }
                        catch
                        {
                            transaction.Rollback();
                            throw;
                        }
                    }
                }
            }
            catch
            {
                ShowFeedbackMessage(
                    T("An error occurred while adding the task.",
                      "Ralat berlaku semasa menambah tugasan."), false);
            }
            RefreshAllQuizData();
        }

        // ══════════════════════════════════════════════════════════════
        //  SHARED UTILITIES
        // ══════════════════════════════════════════════════════════════
        private string GenerateSequentialId(SqlConnection connection, SqlTransaction transaction,
            string tableName, string columnName, string prefix)
        {
            int nextSequence = 1;

            using (var command = new SqlCommand(
                string.Format("SELECT MAX({0}) FROM dbo.[{1}]", columnName, tableName),
                connection, transaction))
            {
                object result = command.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                {
                    string lastId = result.ToString();
                    if (lastId.Length > prefix.Length)
                    {
                        int numericPart;
                        if (int.TryParse(lastId.Substring(prefix.Length), out numericPart))
                        {
                            nextSequence = numericPart + 1;
                        }
                    }
                }
            }

            return prefix + nextSequence.ToString("D3");
        }

        private void CreateNotificationRecord(SqlConnection connection, SqlTransaction transaction,
            string recipientUserId, string titleEN, string titleBM, string messageEN, string messageBM)
        {
            try
            {
                string notificationId = GenerateSequentialId(
                    connection, transaction, "Notification", "notificationId", "N");

                using (var command = new SqlCommand(
                    @"INSERT INTO dbo.Notification(notificationId,toUserId,titleEN,titleBM,messageEN,messageBM,isRead,createdAt)
                    VALUES(@id,@to,@te,@tb,@me,@mb,0,@now)", connection, transaction))
                {
                    command.Parameters.AddWithValue("@id", notificationId);
                    command.Parameters.AddWithValue("@to", recipientUserId);
                    command.Parameters.AddWithValue("@te", titleEN);
                    command.Parameters.AddWithValue("@tb", titleBM);
                    command.Parameters.AddWithValue("@me", messageEN);
                    command.Parameters.AddWithValue("@mb", messageBM);
                    command.Parameters.AddWithValue("@now", DateTime.Now);
                    command.ExecuteNonQuery();
                }
            }
            catch { }
        }

        private string LookupChildUserId(SqlConnection connection, SqlTransaction transaction)
        {
            try
            {
                using (var command = new SqlCommand(
                    @"SELECT u.userId FROM dbo.Student s 
                    INNER JOIN dbo.[User] u ON s.userId=u.userId 
                    WHERE s.studentId=@sid", connection, transaction))
                {
                    command.Parameters.AddWithValue("@sid", _selectedChildId);
                    var result = command.ExecuteScalar();

                    if (result != null && result != DBNull.Value)
                    {
                        return result.ToString();
                    }
                }
            }
            catch { }
            return null;
        }

        private void ShowFeedbackMessage(string messageText, bool isSuccess)
        {
            pnlMessage.Visible = true;
            divMessage.InnerHtml = messageText;
            iMsgIcon.Attributes["class"] = isSuccess
                ? "bi bi-check-circle-fill"
                : "bi bi-exclamation-circle-fill";
        }

        protected void BtnCloseMsg_Click(object sender, EventArgs e)
        {
            pnlMessage.Visible = false;
            RefreshAllQuizData();
        }

        private void LoadUnreadNotificationBadge()
        {
            try
            {
                using (var connection = new SqlConnection(DatabaseConnectionString))
                using (var command = new SqlCommand(
                    "SELECT COUNT(*) FROM dbo.Notification WHERE toUserId=@uid AND isRead=0",
                    connection))
                {
                    command.Parameters.AddWithValue("@uid", Session["userId"].ToString());
                    connection.Open();
                    int unreadCount = (int)command.ExecuteScalar();

                    litUnreadBadge.Text = unreadCount > 0
                        ? "<span class='pt-sidebar-badge'>" + unreadCount + "</span>"
                        : "";
                }
            }
            catch { }
        }
    }
}
