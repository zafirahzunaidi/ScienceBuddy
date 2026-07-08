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

        protected void btnSearch_Click(object sender, EventArgs e) { LoadRanking(txtSearch.Text.Trim()); }
        protected void btnReset_Click(object sender, EventArgs e) { txtSearch.Text = ""; LoadRanking(""); }

        private void LoadRanking(string search)
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
                    if (!string.IsNullOrEmpty(search))
                        sql += " AND s.[name] LIKE @s";

                    using (var cmd = new SqlCommand(sql, c))
                    {
                        if (!string.IsNullOrEmpty(search))
                            cmd.Parameters.AddWithValue("@s", "%" + search + "%");
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
            }
            catch { }

            // Sort
            list.Sort((a, b) =>
            {
                bool aHas = a.HasAttempt, bHas = b.HasAttempt;
                if (aHas && !bHas) return -1;
                if (!aHas && bHas) return 1;
                if (!aHas && !bHas) return string.Compare(a.Name, b.Name, StringComparison.OrdinalIgnoreCase);

                // Both have attempts
                bool aBoth = a.UnitAvg >= 0 && a.LevelAvg >= 0;
                bool bBoth = b.UnitAvg >= 0 && b.LevelAvg >= 0;
                if (aBoth && !bBoth) return -1;
                if (!aBoth && bBoth) return 1;

                int c1 = b.CombinedAvg.CompareTo(a.CombinedAvg); if (c1 != 0) return c1;
                int c2 = b.UnitVal.CompareTo(a.UnitVal); if (c2 != 0) return c2;
                int c3 = b.LevelVal.CompareTo(a.LevelVal); if (c3 != 0) return c3;
                int c4 = b.DoneL.CompareTo(a.DoneL); if (c4 != 0) return c4;
                return string.Compare(a.Name, b.Name, StringComparison.OrdinalIgnoreCase);
            });

            // Build output — only students with attempts get a rank number
            int rankCounter = 0;
            var output = new List<object>();
            foreach (var item in list)
            {
                bool hasRank = item.HasAttempt;
                if (hasRank) rankCounter++;
                int rankNum = rankCounter;

                string rowCss = "";
                string rankHtml = "";
                bool isTop3 = false;

                if (hasRank)
                {
                    if (rankNum == 1) { rankHtml = "<span class='sp-medal'>🥇</span>"; rowCss = "sp-row-gold"; isTop3 = true; }
                    else if (rankNum == 2) { rankHtml = "<span class='sp-medal'>🥈</span>"; rowCss = "sp-row-silver"; isTop3 = true; }
                    else if (rankNum == 3) { rankHtml = "<span class='sp-medal'>🥉</span>"; rowCss = "sp-row-bronze"; isTop3 = true; }
                    else { rankHtml = "<span class='sp-rank-plain'>" + rankNum + "</span>"; }
                }

                string uStr = item.UnitAvg >= 0 ? item.UnitAvg.ToString("0.0") + "%" : T("No Attempt", "Tiada Cubaan");
                string lStr = item.LevelAvg >= 0 ? item.LevelAvg.ToString("0.0") + "%" : T("No Attempt", "Tiada Cubaan");
                string uBadge = item.UnitAvg >= 80 ? "good" : item.UnitAvg >= 50 ? "fair" : item.UnitAvg >= 0 ? "need" : "na";
                string lBadge = item.LevelAvg >= 80 ? "good" : item.LevelAvg >= 50 ? "fair" : item.LevelAvg >= 0 ? "need" : "na";

                output.Add(new
                {
                    hasRank, isTop3, rowCss, rankHtml,
                    name = item.Name,
                    studentId = item.StudentId,
                    lessonsStr = item.DoneL + " / " + item.TotalL,
                    unitQuizStr = uStr, levelQuizStr = lStr,
                    unitBadge = uBadge, levelBadge = lBadge
                });
            }

            if (output.Count > 0)
            { rptRanking.DataSource = output; rptRanking.DataBind(); pnlTable.Visible = true; pnlRankingEmpty.Visible = false; }
            else
            { rptRanking.DataSource = null; rptRanking.DataBind(); pnlTable.Visible = false; pnlRankingEmpty.Visible = true; }
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
