using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Teacher
{
    public partial class studentProgress : Page
    {
        #region Properties

        protected string CurrentLanguage
        {
            get
            {
                string language = Session["preferredLanguage"] as string;
                return string.IsNullOrEmpty(language) ? "EN" : language;
            }
        }

        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        #endregion

        #region Page Lifecycle

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"]?.ToString() != "Teacher")
            {
                Response.Redirect("~/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";

            string licenseStatus = GetTeacherLicenseStatus();
            if (licenseStatus.Equals("Pending", StringComparison.OrdinalIgnoreCase))
            {
                pnlContent.Visible = false;
                pnlPending.Visible = true;
                return;
            }

            if (!IsPostBack)
            {
                PopulateSortDropdown();
                LoadPodium();
                LoadTable("");
            }
        }

        #endregion

        #region Data Loading

        private void LoadPodium()
        {
            var allStudents = FetchStudents("");
            var topStudents = GetTopStudentsWithAttempts(allStudents, count: 3);

            string[] positionCssClasses = { "first", "second", "third" };
            string[] medalEmojis = { "🥇", "🥈", "🥉" };

            var podiumData = new List<object>();

            for (int position = 0; position < 3; position++)
            {
                if (position < topStudents.Count)
                {
                    var student = topStudents[position];
                    decimal overallPercent = student.CombinedAvg;
                    string performanceCss = GetPerformanceCssClass(overallPercent);
                    string performanceLabel = GetPerformanceLabel(overallPercent);

                    podiumData.Add(new
                    {
                        podCss = positionCssClasses[position],
                        medal = medalEmojis[position],
                        initials = Initials(student.Name),
                        name = student.Name,
                        overallStr = overallPercent.ToString("0.0") + "%",
                        perfCss = performanceCss,
                        perfLabel = performanceLabel,
                        lessonsStr = student.CompletedLessons + " / " + student.TotalLessons + " Lessons",
                        hasData = true
                    });
                }
                else
                {
                    podiumData.Add(new
                    {
                        podCss = positionCssClasses[position],
                        medal = medalEmojis[position],
                        initials = "-",
                        name = "-",
                        overallStr = "-",
                        perfCss = "",
                        perfLabel = "",
                        lessonsStr = "",
                        hasData = false
                    });
                }
            }

            rptPodium.DataSource = podiumData;
            rptPodium.DataBind();
            pnlPodium.Visible = true;
        }

        private void LoadTable(string searchTerm)
        {
            var students = FetchStudents(searchTerm);

            ApplySortOrder(students, ddlSort.SelectedValue);

            var tableRows = BuildTableRows(students);

            if (tableRows.Count > 0)
            {
                rptRanking.DataSource = tableRows;
                rptRanking.DataBind();
                pnlTable.Visible = true;
                pnlRankingEmpty.Visible = false;
            }
            else
            {
                rptRanking.DataSource = null;
                rptRanking.DataBind();
                pnlTable.Visible = false;
                pnlRankingEmpty.Visible = true;
            }
        }

        #endregion

        #region Database Operations

        private string GetTeacherLicenseStatus()
        {
            try
            {
                using (var connection = new SqlConnection(ConnStr))
                {
                    connection.Open();

                    using (var cmd = new SqlCommand("SELECT [status] FROM dbo.[Teacher] WHERE [userId]=@u", connection))
                    {
                        cmd.Parameters.AddWithValue("@u", Session["userId"].ToString());
                        var result = cmd.ExecuteScalar();
                        return result != null && result != DBNull.Value ? result.ToString() : "";
                    }
                }
            }
            catch { return ""; }
        }

        private List<StudentRankItem> FetchStudents(string searchTerm)
        {
            var students = new List<StudentRankItem>();

            try
            {
                int totalLessons = 0;

                using (var connection = new SqlConnection(ConnStr))
                {
                    connection.Open();

                    using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[Lesson]", connection))
                    {
                        totalLessons = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    string sql = @"
                        SELECT s.[studentId], s.[name],
                            (SELECT COUNT(*) FROM dbo.[LessonProgress] WHERE [studentId]=s.[studentId] AND [isCompleted]=1) AS doneL,
                            (SELECT AVG(CAST(qr.[percentage] AS DECIMAL(5,2)))
                                FROM dbo.[QuizResult] qr INNER JOIN dbo.[Quiz] q ON q.[quizId]=qr.[quizId]
                                WHERE qr.[studentId]=s.[studentId] AND q.[quizType]='Unit') AS unitAvg,
                            (SELECT AVG(CAST(qr.[percentage] AS DECIMAL(5,2)))
                                FROM dbo.[QuizResult] qr INNER JOIN dbo.[Quiz] q ON q.[quizId]=qr.[quizId]
                                WHERE qr.[studentId]=s.[studentId] AND q.[quizType]='Level') AS levelAvg
                        FROM dbo.[Student] s
                        INNER JOIN dbo.[User] u ON u.[userId]=s.[userId]
                        WHERE u.[status]='Active'";

                    if (!string.IsNullOrEmpty(searchTerm))
                    {
                        sql += " AND s.[name] LIKE @s";
                    }

                    using (var cmd = new SqlCommand(sql, connection))
                    {
                        if (!string.IsNullOrEmpty(searchTerm))
                        {
                            cmd.Parameters.AddWithValue("@s", "%" + searchTerm + "%");
                        }

                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                var student = new StudentRankItem
                                {
                                    StudentId = reader["studentId"].ToString(),
                                    Name = reader["name"]?.ToString() ?? "Student",
                                    CompletedLessons = reader["doneL"] != DBNull.Value ? Convert.ToInt32(reader["doneL"]) : 0,
                                    UnitQuizAverage = reader["unitAvg"] != DBNull.Value ? Convert.ToDecimal(reader["unitAvg"]) : -1,
                                    LevelQuizAverage = reader["levelAvg"] != DBNull.Value ? Convert.ToDecimal(reader["levelAvg"]) : -1,
                                    TotalLessons = totalLessons
                                };

                                students.Add(student);
                            }
                        }
                    }
                }
            }
            catch { }

            // Default ranking: students with attempts first, sorted by combined average descending
            students.Sort((a, b) =>
            {
                bool aHasAttempt = a.HasAttempt;
                bool bHasAttempt = b.HasAttempt;

                // Students with attempts rank above those without
                if (aHasAttempt && !bHasAttempt) return -1;
                if (!aHasAttempt && bHasAttempt) return 1;
                if (!aHasAttempt && !bHasAttempt) return string.Compare(a.Name, b.Name, StringComparison.OrdinalIgnoreCase);

                // Students with both quiz types rank above those with only one
                bool aHasBoth = a.UnitQuizAverage >= 0 && a.LevelQuizAverage >= 0;
                bool bHasBoth = b.UnitQuizAverage >= 0 && b.LevelQuizAverage >= 0;
                if (aHasBoth && !bHasBoth) return -1;
                if (!aHasBoth && bHasBoth) return 1;

                // Tiebreakers: combined avg > unit avg > level avg > lessons > name
                int cmp = b.CombinedAvg.CompareTo(a.CombinedAvg);
                if (cmp != 0) return cmp;

                cmp = b.UnitVal.CompareTo(a.UnitVal);
                if (cmp != 0) return cmp;

                cmp = b.LevelVal.CompareTo(a.LevelVal);
                if (cmp != 0) return cmp;

                cmp = b.CompletedLessons.CompareTo(a.CompletedLessons);
                if (cmp != 0) return cmp;

                return string.Compare(a.Name, b.Name, StringComparison.OrdinalIgnoreCase);
            });

            return students;
        }

        #endregion

        #region Helper Methods

        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        /// <summary>
        /// Returns a badge label for display in the ASPX repeater.
        /// </summary>
        protected string BadgeLabel(string badge)
        {
            switch (badge)
            {
                case "good": return T("Good", "Baik");
                case "fair": return T("Fair", "Sederhana");
                case "need": return T("Needs Support", "Perlu Sokongan");
                default: return "";
            }
        }

        private void PopulateSortDropdown()
        {
            ddlSort.Items.Clear();
            ddlSort.Items.Add(new ListItem(T("Default", "Lalai"), ""));
            ddlSort.Items.Add(new ListItem("A-Z", "az"));
            ddlSort.Items.Add(new ListItem("Z-A", "za"));
            ddlSort.Items.Add(new ListItem(T("Highest Overall", "Keseluruhan Tertinggi"), "high"));
            ddlSort.Items.Add(new ListItem(T("Lowest Overall", "Keseluruhan Terendah"), "low"));
            ddlSort.Items.Add(new ListItem(T("Most Lessons", "Paling Banyak Pelajaran"), "most"));
            ddlSort.Items.Add(new ListItem(T("Least Lessons", "Paling Sedikit Pelajaran"), "least"));
        }

        private void ApplySortOrder(List<StudentRankItem> students, string sortValue)
        {
            switch (sortValue)
            {
                case "az":
                    students.Sort((a, b) => string.Compare(a.Name, b.Name, StringComparison.OrdinalIgnoreCase));
                    break;
                case "za":
                    students.Sort((a, b) => string.Compare(b.Name, a.Name, StringComparison.OrdinalIgnoreCase));
                    break;
                case "high":
                    students.Sort((a, b) => b.CombinedAvg.CompareTo(a.CombinedAvg));
                    break;
                case "low":
                    students.Sort((a, b) => a.CombinedAvg.CompareTo(b.CombinedAvg));
                    break;
                case "most":
                    students.Sort((a, b) => b.CompletedLessons.CompareTo(a.CompletedLessons));
                    break;
                case "least":
                    students.Sort((a, b) => a.CompletedLessons.CompareTo(b.CompletedLessons));
                    break;
            }
        }

        private List<StudentRankItem> GetTopStudentsWithAttempts(List<StudentRankItem> allStudents, int count)
        {
            var topStudents = new List<StudentRankItem>();

            for (int i = 0; i < allStudents.Count && topStudents.Count < count; i++)
            {
                if (allStudents[i].HasAttempt)
                {
                    topStudents.Add(allStudents[i]);
                }
            }

            return topStudents;
        }

        private List<object> BuildTableRows(List<StudentRankItem> students)
        {
            var rows = new List<object>();
            int rowNum = 0;

            foreach (var student in students)
            {
                rowNum++;

                string unitQuizDisplay = student.UnitQuizAverage >= 0
                    ? student.UnitQuizAverage.ToString("0.0") + "%"
                    : T("No Attempt", "Tiada Cubaan");

                string levelQuizDisplay = student.LevelQuizAverage >= 0
                    ? student.LevelQuizAverage.ToString("0.0") + "%"
                    : T("No Attempt", "Tiada Cubaan");

                string overallDisplay = student.HasAttempt
                    ? student.CombinedAvg.ToString("0.0") + "%"
                    : T("No Attempt", "Tiada Cubaan");

                // Badge thresholds: >=80 good, >=50 fair, >=0 needs support, <0 (no attempt) n/a
                string unitBadge = GetQuizBadge(student.UnitQuizAverage);
                string levelBadge = GetQuizBadge(student.LevelQuizAverage);

                rows.Add(new
                {
                    rowNum,
                    name = student.Name,
                    studentId = student.StudentId,
                    lessonsStr = student.CompletedLessons + " / " + student.TotalLessons,
                    unitQuizStr = unitQuizDisplay,
                    levelQuizStr = levelQuizDisplay,
                    overallStr = overallDisplay,
                    unitBadge,
                    levelBadge
                });
            }

            return rows;
        }

        private string GetQuizBadge(decimal quizAverage)
        {
            if (quizAverage >= 80) return "good";
            if (quizAverage >= 50) return "fair";
            if (quizAverage >= 0) return "need";
            return "na";
        }

        private string GetPerformanceCssClass(decimal overallPercent)
        {
            if (overallPercent >= 80) return "excellent";
            if (overallPercent >= 60) return "good";
            return "fair";
        }

        private string GetPerformanceLabel(decimal overallPercent)
        {
            if (overallPercent >= 80) return T("Excellent", "Cemerlang");
            if (overallPercent >= 60) return T("Very Good", "Sangat Baik");
            return T("Good", "Baik");
        }

        private static string Initials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "NA";

            var parts = name.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);

            return parts.Length >= 2
                ? (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper()
                : parts[0][0].ToString().ToUpper();
        }

        #endregion

        #region Inner Classes

        private class StudentRankItem
        {
            public string StudentId;
            public string Name;
            public int CompletedLessons;
            public int TotalLessons;
            public decimal UnitQuizAverage;
            public decimal LevelQuizAverage;

            public bool HasAttempt => UnitQuizAverage >= 0 || LevelQuizAverage >= 0;

            public decimal UnitVal => UnitQuizAverage >= 0 ? UnitQuizAverage : 0;
            public decimal LevelVal => LevelQuizAverage >= 0 ? LevelQuizAverage : 0;

            /// <summary>
            /// Combined average: uses both quiz types if available, otherwise whichever one exists.
            /// Returns -1 equivalent logic is handled by HasAttempt check before use.
            /// </summary>
            public decimal CombinedAvg =>
                (UnitQuizAverage >= 0 && LevelQuizAverage >= 0) ? (UnitQuizAverage + LevelQuizAverage) / 2
                : (UnitQuizAverage >= 0) ? UnitQuizAverage
                : LevelQuizAverage;
        }

        #endregion
    }
}
