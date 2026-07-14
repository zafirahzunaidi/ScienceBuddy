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
        protected string CurrentLanguage
        { get { string l = Session["preferredLanguage"] as string; return string.IsNullOrEmpty(l) ? "EN" : l; } }
        protected string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"]?.ToString() != "Teacher")
            { Response.Redirect("~/Login.aspx", false); Context.ApplicationInstance.CompleteRequest(); return; }
            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";

            // Check Teaching License status
            string licenseStatus = GetTeacherLicenseStatus();
            if (licenseStatus.Equals("Pending", StringComparison.OrdinalIgnoreCase))
            {
                pnlContent.Visible = false;
                pnlPending.Visible = true;
                return;
            }

            if (!IsPostBack)
            {
                txtSearch.Attributes["placeholder"] = T("Search student name...", "Cari nama pelajar...");
                btnSearch.Text = T("Search", "Cari");
                btnReset.Text = T("Reset", "Set Semula");
                ddlSort.Items.Clear();
                ddlSort.Items.Add(new ListItem(T("Default","Lalai"), ""));
                ddlSort.Items.Add(new ListItem("A-Z", "az"));
                ddlSort.Items.Add(new ListItem("Z-A", "za"));
                ddlSort.Items.Add(new ListItem(T("Highest Overall","Keseluruhan Tertinggi"), "high"));
                ddlSort.Items.Add(new ListItem(T("Lowest Overall","Keseluruhan Terendah"), "low"));
                ddlSort.Items.Add(new ListItem(T("Most Lessons","Paling Banyak Pelajaran"), "most"));
                ddlSort.Items.Add(new ListItem(T("Least Lessons","Paling Sedikit Pelajaran"), "least"));
                LoadPodium();
                LoadTable("");
            }
        }

        private string GetTeacherLicenseStatus()
        {
            try
            {
                using (var c = new SqlConnection(ConnStr))
                {
                    c.Open();
                    using (var cmd = new SqlCommand("SELECT [status] FROM dbo.[Teacher] WHERE [userId]=@u", c))
                    {
                        cmd.Parameters.AddWithValue("@u", Session["userId"].ToString());
                        var val = cmd.ExecuteScalar();
                        return val != null && val != DBNull.Value ? val.ToString() : "";
                    }
                }
            }
            catch { return ""; }
        }

        protected void btnSearch_Click(object sender, EventArgs e) { LoadPodium(); LoadTable(txtSearch.Text.Trim()); }
        protected void btnReset_Click(object sender, EventArgs e) { txtSearch.Text = ""; ddlSort.SelectedIndex = 0; LoadPodium(); LoadTable(""); }

        private List<RankItem> FetchStudents(string search)
        {
            var list = new List<RankItem>();
            try
            {
                int totalLessons = 0;
                using (var c = new SqlConnection(ConnStr))
                {
                    c.Open();
                    using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[Lesson]", c))
                        totalLessons = Convert.ToInt32(cmd.ExecuteScalar());

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
                    if (!string.IsNullOrEmpty(search)) sql += " AND s.[name] LIKE @s";

                    using (var cmd = new SqlCommand(sql, c))
                    {
                        if (!string.IsNullOrEmpty(search)) cmd.Parameters.AddWithValue("@s", "%" + search + "%");
                        using (var r = cmd.ExecuteReader())
                            while (r.Read())
                            {
                                var item = new RankItem();
                                item.StudentId = r["studentId"].ToString();
                                item.Name = r["name"]?.ToString() ?? "Student";
                                item.DoneL = r["doneL"] != DBNull.Value ? Convert.ToInt32(r["doneL"]) : 0;
                                item.UnitAvg = r["unitAvg"] != DBNull.Value ? Convert.ToDecimal(r["unitAvg"]) : -1;
                                item.LevelAvg = r["levelAvg"] != DBNull.Value ? Convert.ToDecimal(r["levelAvg"]) : -1;
                                item.TotalL = totalLessons;
                                list.Add(item);
                            }
                    }
                }
            } catch { }
            list.Sort((a, b) => { bool aH=a.HasAttempt,bH=b.HasAttempt; if(aH&&!bH)return-1;if(!aH&&bH)return 1;if(!aH&&!bH)return string.Compare(a.Name,b.Name,StringComparison.OrdinalIgnoreCase); bool aB=a.UnitAvg>=0&&a.LevelAvg>=0,bB=b.UnitAvg>=0&&b.LevelAvg>=0;if(aB&&!bB)return-1;if(!aB&&bB)return 1; int c1=b.CombinedAvg.CompareTo(a.CombinedAvg);if(c1!=0)return c1; int c2=b.UnitVal.CompareTo(a.UnitVal);if(c2!=0)return c2; int c3=b.LevelVal.CompareTo(a.LevelVal);if(c3!=0)return c3; int c4=b.DoneL.CompareTo(a.DoneL);if(c4!=0)return c4; return string.Compare(a.Name,b.Name,StringComparison.OrdinalIgnoreCase); });
            return list;
        }

        private void LoadPodium()
        {
            var list = FetchStudents(""); // always ALL students
            var podiumStudents = new List<RankItem>();
            for (int i = 0; i < list.Count && podiumStudents.Count < 3; i++)
                if (list[i].HasAttempt) podiumStudents.Add(list[i]);

            string[] podCssArr = { "first", "second", "third" };
            string[] medalArr = { "🥇", "🥈", "🥉" };
            var podiumData = new List<object>();
            for (int p = 0; p < 3; p++)
            {
                if (p < podiumStudents.Count)
                {
                    var item = podiumStudents[p];
                    decimal ov = item.CombinedAvg;
                    string perfCss = ov >= 80 ? "excellent" : ov >= 60 ? "good" : "fair";
                    string perfLabel = ov >= 80 ? T("Excellent","Cemerlang") : ov >= 60 ? T("Very Good","Sangat Baik") : T("Good","Baik");
                    podiumData.Add(new { podCss = podCssArr[p], medal = medalArr[p], initials = Initials(item.Name), name = item.Name,
                        overallStr = ov.ToString("0.0") + "%", perfCss, perfLabel,
                        lessonsStr = item.DoneL + " / " + item.TotalL + " Lessons", hasData = true });
                }
                else
                {
                    podiumData.Add(new { podCss = podCssArr[p], medal = medalArr[p], initials = "-", name = "-",
                        overallStr = "-", perfCss = "", perfLabel = "", lessonsStr = "", hasData = false });
                }
            }
            rptPodium.DataSource = podiumData; rptPodium.DataBind(); pnlPodium.Visible = true;
        }

        private void LoadTable(string search)
        {
            var list = FetchStudents(search);

            // Apply sort
            string sort = ddlSort.SelectedValue;
            switch (sort)
            {
                case "az": list.Sort((a, b) => string.Compare(a.Name, b.Name, StringComparison.OrdinalIgnoreCase)); break;
                case "za": list.Sort((a, b) => string.Compare(b.Name, a.Name, StringComparison.OrdinalIgnoreCase)); break;
                case "high": list.Sort((a, b) => b.CombinedAvg.CompareTo(a.CombinedAvg)); break;
                case "low": list.Sort((a, b) => a.CombinedAvg.CompareTo(b.CombinedAvg)); break;
                case "most": list.Sort((a, b) => b.DoneL.CompareTo(a.DoneL)); break;
                case "least": list.Sort((a, b) => a.DoneL.CompareTo(b.DoneL)); break;
            }

            int rowNum = 0;
            var output = new List<object>();
            foreach (var item in list)
            {
                rowNum++;
                string uStr = item.UnitAvg >= 0 ? item.UnitAvg.ToString("0.0") + "%" : T("No Attempt", "Tiada Cubaan");
                string lStr = item.LevelAvg >= 0 ? item.LevelAvg.ToString("0.0") + "%" : T("No Attempt", "Tiada Cubaan");
                string overallStr = item.HasAttempt ? item.CombinedAvg.ToString("0.0") + "%" : T("No Attempt", "Tiada Cubaan");
                string uBadge = item.UnitAvg >= 80 ? "good" : item.UnitAvg >= 50 ? "fair" : item.UnitAvg >= 0 ? "need" : "na";
                string lBadge = item.LevelAvg >= 80 ? "good" : item.LevelAvg >= 50 ? "fair" : item.LevelAvg >= 0 ? "need" : "na";

                output.Add(new { rowNum, name = item.Name, studentId = item.StudentId,
                    lessonsStr = item.DoneL + " / " + item.TotalL, unitQuizStr = uStr, levelQuizStr = lStr,
                    overallStr, unitBadge = uBadge, levelBadge = lBadge });
            }
            if (output.Count > 0) { rptRanking.DataSource = output; rptRanking.DataBind(); pnlTable.Visible = true; pnlRankingEmpty.Visible = false; }
            else { rptRanking.DataSource = null; rptRanking.DataBind(); pnlTable.Visible = false; pnlRankingEmpty.Visible = true; }
        }

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

        private static string Initials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "NA";
            var p = name.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            return p.Length >= 2 ? (p[0][0].ToString() + p[p.Length - 1][0].ToString()).ToUpper() : p[0][0].ToString().ToUpper();
        }

        private class RankItem
        {
            public string StudentId;
            public string Name;
            public int DoneL;
            public int TotalL;
            public decimal UnitAvg;
            public decimal LevelAvg;
            public bool HasAttempt => UnitAvg >= 0 || LevelAvg >= 0;
            public decimal UnitVal => UnitAvg >= 0 ? UnitAvg : 0;
            public decimal LevelVal => LevelAvg >= 0 ? LevelAvg : 0;
            public decimal CombinedAvg =>
                (UnitAvg >= 0 && LevelAvg >= 0) ? (UnitAvg + LevelAvg) / 2
                : (UnitAvg >= 0) ? UnitAvg : LevelAvg;
        }
    }
}
