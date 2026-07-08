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
            if (!IsPostBack)
            {
                txtSearch.Attributes["placeholder"] = T("Search student name...", "Cari nama pelajar...");
                btnSearch.Text = T("Search", "Cari");
                btnReset.Text = T("Reset", "Set Semula");
                LoadRanking("");
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadRanking(txtSearch.Text.Trim());
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            LoadRanking("");
        }

        private void LoadRanking(string searchName)
        {
            var list = new List<object>();
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

                    if (!string.IsNullOrEmpty(searchName))
                        sql += " AND s.[name] LIKE @search";

                    using (var cmd = new SqlCommand(sql, c))
                    {
                        if (!string.IsNullOrEmpty(searchName))
                            cmd.Parameters.AddWithValue("@search", "%" + searchName + "%");

                        using (var r = cmd.ExecuteReader())
                        {
                            while (r.Read())
                            {
                                int doneL  = r["doneL"] != DBNull.Value ? Convert.ToInt32(r["doneL"]) : 0;
                                decimal uA = r["unitAvg"] != DBNull.Value ? Convert.ToDecimal(r["unitAvg"]) : -1;
                                decimal lA = r["levelAvg"] != DBNull.Value ? Convert.ToDecimal(r["levelAvg"]) : -1;

                                string uStr = uA >= 0 ? uA.ToString("0.0") + "%" : T("No Attempt", "Tiada Cubaan");
                                string lStr = lA >= 0 ? lA.ToString("0.0") + "%" : T("No Attempt", "Tiada Cubaan");

                                string uBadge = uA >= 80 ? "good" : uA >= 50 ? "fair" : uA >= 0 ? "need" : "na";
                                string lBadge = lA >= 80 ? "good" : lA >= 50 ? "fair" : lA >= 0 ? "need" : "na";

                                list.Add(new
                                {
                                    studentId = r["studentId"].ToString(),
                                    name = r["name"]?.ToString() ?? "Student",
                                    lessonsStr = doneL + " / " + totalLessons,
                                    unitQuizStr = uStr, levelQuizStr = lStr,
                                    unitBadge = uBadge, levelBadge = lBadge,
                                    sortU = uA < 0 ? 999m : uA,
                                    sortL = lA < 0 ? 999m : lA,
                                    doneL
                                });
                            }
                        }
                    }
                }
            }
            catch { }

            // Sort by quiz performance
            list.Sort((a, b) =>
            {
                decimal aU = ((dynamic)a).sortU, aL = ((dynamic)a).sortL;
                decimal bU = ((dynamic)b).sortU, bL = ((dynamic)b).sortL;
                bool aHas = aU < 999 || aL < 999;
                bool bHas = bU < 999 || bL < 999;
                if (aHas && !bHas) return -1;
                if (!aHas && bHas) return 1;
                if (!aHas && !bHas)
                {
                    int c1 = ((int)((dynamic)b).doneL).CompareTo((int)((dynamic)a).doneL);
                    return c1 != 0 ? c1 : string.Compare((string)((dynamic)a).name, (string)((dynamic)b).name, StringComparison.OrdinalIgnoreCase);
                }
                decimal aAvg = (aU < 999 && aL < 999) ? (aU + aL) / 2 : (aU < 999) ? aU : aL;
                decimal bAvg = (bU < 999 && bL < 999) ? (bU + bL) / 2 : (bU < 999) ? bU : bL;
                bool aBoth = aU < 999 && aL < 999, bBoth = bU < 999 && bL < 999;
                if (aBoth && !bBoth) return -1;
                if (!aBoth && bBoth) return 1;
                int r1 = bAvg.CompareTo(aAvg); if (r1 != 0) return r1;
                int r2 = (bU < 999 ? bU : 0m).CompareTo(aU < 999 ? aU : 0m); if (r2 != 0) return r2;
                int r3 = (bL < 999 ? bL : 0m).CompareTo(aL < 999 ? aL : 0m); if (r3 != 0) return r3;
                int r4 = ((int)((dynamic)b).doneL).CompareTo((int)((dynamic)a).doneL); if (r4 != 0) return r4;
                return string.Compare((string)((dynamic)a).name, (string)((dynamic)b).name, StringComparison.OrdinalIgnoreCase);
            });

            var ranked = new List<object>();
            for (int i = 0; i < list.Count; i++)
            {
                dynamic it = list[i];
                string rankCss = i == 0 ? "gold" : i == 1 ? "silver" : i == 2 ? "bronze" : "purple";
                string rowCss  = i == 0 ? "sp-row-gold" : i == 1 ? "sp-row-silver" : i == 2 ? "sp-row-bronze" : "";
                string medalIcon = i == 0 ? "🥇" : i == 1 ? "🥈" : i == 2 ? "🥉" : (i + 1).ToString();
                ranked.Add(new
                {
                    rank = i + 1, rankCss, rowCss, medalIcon,
                    name = (string)it.name,
                    studentId = (string)it.studentId,
                    lessonsStr = (string)it.lessonsStr,
                    unitQuizStr = (string)it.unitQuizStr,
                    levelQuizStr = (string)it.levelQuizStr,
                    unitBadge = (string)it.unitBadge,
                    levelBadge = (string)it.levelBadge
                });
            }

            if (ranked.Count > 0)
            { rptRanking.DataSource = ranked; rptRanking.DataBind(); pnlRankingEmpty.Visible = false; }
            else
            { rptRanking.DataSource = null; rptRanking.DataBind(); pnlRankingEmpty.Visible = true; }
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
    }
}
