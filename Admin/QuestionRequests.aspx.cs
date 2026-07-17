using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

// Admin QuestionRequests - Code Behind
namespace ScienceBuddy.Admin
{
    public partial class QuestionRequests : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        protected string CurrentLanguage => ((ScienceBuddy.SiteMaster)Master).CurrentLanguage;
        protected string T(string en, string bm) => CurrentLanguage == "BM" ? bm : en;
        private bool _isAjax = false;

        protected override void Render(HtmlTextWriter writer)
        {
            if (!_isAjax) base.Render(writer);
        }

        // --- Page Lifecycle ---

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.QueryString["handler"] == "ReviewQuiz" && Request.HttpMethod == "POST")
            { _isAjax = true; HandleReview(); return; }

            if (Request.QueryString["handler"] == "ViewQuiz" && Request.HttpMethod == "POST")
            { _isAjax = true; HandleView(); return; }

            if (Session["userId"] == null || Session["role"]?.ToString() != "Admin")
            { Response.Redirect("~/Login.aspx", false); return; }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                SetUserInfo();
                LoadStats();
                LoadData("", "", "", "");
            }

            txtSearch.Attributes["placeholder"] = T("Search quiz title, teacher or ID…", "Cari tajuk kuiz, guru atau ID…");
            btnSearch.Text = T("Search", "Cari");
            btnReset.Text = T("Reset", "Tetapkan Semula");
        }

        // --- Data Loading ---

        private void SetUserInfo()
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

        private void LoadStats()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                litPending.Text = SC(conn, "SELECT COUNT(*) FROM dbo.[Quiz] WHERE [status]='Pending'");
                litApproved.Text = SC(conn, "SELECT COUNT(*) FROM dbo.[Quiz] WHERE [status]='Approved'");
                litRejected.Text = SC(conn, "SELECT COUNT(*) FROM dbo.[Quiz] WHERE [status]='Rejected'");
                litToday.Text = SC(conn, "SELECT COUNT(*) FROM dbo.[Quiz] WHERE [status] IN ('Approved','Rejected') AND CAST([createdAt] AS DATE)=CAST(GETDATE() AS DATE)");

                string pCount = SC(conn, "SELECT COUNT(*) FROM dbo.[Quiz] WHERE [status]='Pending'");
                litBadge.Text = pCount != "0"
                    ? "<span class=\"sb-badge sb-badge-warning\" style=\"margin-left:6px;\">" + pCount + "</span>"
                    : "";
            }
        }

        private void LoadData(string search, string statusF, string typeF, string langF)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                string tCol = CurrentLanguage == "BM"
                    ? "ISNULL(q.[quizTitleBM],q.[quizTitleEN])"
                    : "ISNULL(q.[quizTitleEN],q.[quizTitleBM])";

                string baseSql = string.Format(@"SELECT q.[quizId], {0} AS quizTitle, q.[quizType], q.[language],
                    q.[status], q.[createdAt], ISNULL(t.[name],u.[username]) AS teacherName,
                    (SELECT COUNT(*) FROM dbo.[Question] qn WHERE qn.[quizId]=q.[quizId]) AS questionCount
                    FROM dbo.[Quiz] q LEFT JOIN dbo.[User] u ON u.[userId]=q.[createdByUserId]
                    LEFT JOIN dbo.[Teacher] t ON t.[userId]=q.[createdByUserId]
                    WHERE q.[status] IS NOT NULL", tCol);

                if (!string.IsNullOrWhiteSpace(search))
                    baseSql += " AND (" + tCol + " LIKE @s OR q.[quizId] LIKE @s OR ISNULL(t.[name],u.[username]) LIKE @s)";
                if (!string.IsNullOrWhiteSpace(statusF))
                    baseSql += " AND q.[status]=@st";
                if (!string.IsNullOrWhiteSpace(typeF))
                    baseSql += " AND q.[quizType]=@tp";
                if (!string.IsNullOrWhiteSpace(langF))
                    baseSql += " AND q.[language]=@lg";

                // Pending quizzes
                string pendingSql = baseSql + " AND q.[status]='Pending' ORDER BY q.[createdAt] DESC";
                using (var cmd = new SqlCommand(pendingSql, conn))
                {
                    if (!string.IsNullOrWhiteSpace(search)) cmd.Parameters.AddWithValue("@s", "%" + search + "%");
                    if (!string.IsNullOrWhiteSpace(statusF)) cmd.Parameters.AddWithValue("@st", statusF);
                    if (!string.IsNullOrWhiteSpace(typeF)) cmd.Parameters.AddWithValue("@tp", typeF);
                    if (!string.IsNullOrWhiteSpace(langF)) cmd.Parameters.AddWithValue("@lg", langF);

                    var da = new SqlDataAdapter(cmd);
                    var dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        pnlPending.Visible = true;
                        pnlPendingEmpty.Visible = false;
                        var list = new List<object>();
                        foreach (DataRow r in dt.Rows)
                        {
                            list.Add(new
                            {
                                quizId = r["quizId"].ToString(),
                                quizTitle = NS(r["quizTitle"]),
                                quizType = NS(r["quizType"]),
                                language = NS(r["language"]),
                                teacherName = NS(r["teacherName"]),
                                questionCount = r["questionCount"].ToString(),
                                createdAt = r["createdAt"] != DBNull.Value
                                    ? Convert.ToDateTime(r["createdAt"]).ToString("dd MMM yyyy") : "-"
                            });
                        }
                        rptPending.DataSource = list;
                        rptPending.DataBind();
                    }
                    else
                    {
                        pnlPending.Visible = false;
                        pnlPendingEmpty.Visible = true;
                    }
                }

                // History (Approved + Rejected)
                string histSql = baseSql + " AND q.[status] IN ('Approved','Rejected') ORDER BY q.[createdAt] DESC";
                using (var cmd = new SqlCommand(histSql, conn))
                {
                    if (!string.IsNullOrWhiteSpace(search)) cmd.Parameters.AddWithValue("@s", "%" + search + "%");
                    if (!string.IsNullOrWhiteSpace(statusF)) cmd.Parameters.AddWithValue("@st", statusF);
                    if (!string.IsNullOrWhiteSpace(typeF)) cmd.Parameters.AddWithValue("@tp", typeF);
                    if (!string.IsNullOrWhiteSpace(langF)) cmd.Parameters.AddWithValue("@lg", langF);

                    var da = new SqlDataAdapter(cmd);
                    var dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        pnlHistory.Visible = true;
                        pnlHistoryEmpty.Visible = false;
                        var list = new List<object>();
                        foreach (DataRow r in dt.Rows)
                        {
                            list.Add(new
                            {
                                quizId = r["quizId"].ToString(),
                                quizTitle = NS(r["quizTitle"]),
                                quizType = NS(r["quizType"]),
                                teacherName = NS(r["teacherName"]),
                                questionCount = r["questionCount"].ToString(),
                                reviewedDate = r["createdAt"] != DBNull.Value
                                    ? Convert.ToDateTime(r["createdAt"]).ToString("dd MMM yyyy") : "-",
                                status = NS(r["status"])
                            });
                        }
                        rptHistory.DataSource = list;
                        rptHistory.DataBind();
                    }
                    else
                    {
                        pnlHistory.Visible = false;
                        pnlHistoryEmpty.Visible = true;
                    }
                }
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadStats();
            LoadData(txtSearch.Text.Trim(), fStatus.SelectedValue, fType.SelectedValue, fLang.SelectedValue);
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            fStatus.SelectedIndex = 0;
            fType.SelectedIndex = 0;
            fLang.SelectedIndex = 0;
            LoadStats();
            LoadData("", "", "", "");
        }

        // --- AJAX Handlers ---

        private void HandleReview()
        {
            Response.Clear();
            Response.ContentType = "application/json";
            try
            {
                if (Session["userId"] == null || Session["role"]?.ToString() != "Admin")
                { Response.Write("{\"success\":false,\"msg\":\"Unauthorized\"}"); Flush(); return; }

                string quizId = Request.QueryString["quizId"] ?? "";
                string action = Request.QueryString["action"] ?? "";
                string adminId = Session["userId"].ToString();
                string newStatus = action == "Approve" ? "Approved" : "Rejected";

                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // Verify quiz is still Pending
                    string curStatus = "";
                    using (var cmd = new SqlCommand("SELECT [status] FROM dbo.[Quiz] WHERE [quizId]=@id", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", quizId);
                        var result = cmd.ExecuteScalar();
                        curStatus = result?.ToString() ?? "";
                    }
                    if (curStatus != "Pending")
                    { Response.Write("{\"success\":false,\"msg\":\"Quiz already reviewed.\"}"); Flush(); return; }

                    using (var txn = conn.BeginTransaction())
                    {
                        try
                        {
                            // Update Quiz status
                            using (var cmd = new SqlCommand("UPDATE dbo.[Quiz] SET [status]=@st WHERE [quizId]=@id", conn, txn))
                            {
                                cmd.Parameters.AddWithValue("@st", newStatus);
                                cmd.Parameters.AddWithValue("@id", quizId);
                                cmd.ExecuteNonQuery();
                            }

                            // Update all questions in the quiz
                            using (var cmd = new SqlCommand("UPDATE dbo.[Question] SET [status]=@st, [reviewedDate]=GETDATE() WHERE [quizId]=@id", conn, txn))
                            {
                                cmd.Parameters.AddWithValue("@st", newStatus);
                                cmd.Parameters.AddWithValue("@id", quizId);
                                cmd.ExecuteNonQuery();
                            }

                            // Log the action
                            string logId = GenId(conn, txn, "Log", "logId", "LOG");
                            using (var cmd = new SqlCommand("INSERT INTO dbo.[Log]([logId],[userId],[action],[description],[logDateTime],[status]) VALUES(@a,@b,@c,@d,GETDATE(),'Success')", conn, txn))
                            {
                                cmd.Parameters.AddWithValue("@a", logId);
                                cmd.Parameters.AddWithValue("@b", adminId);
                                cmd.Parameters.AddWithValue("@c", action == "Approve" ? "Approved Quiz" : "Rejected Quiz");
                                cmd.Parameters.AddWithValue("@d", "Admin " + action.ToLower() + "d quiz " + quizId + ".");
                                cmd.ExecuteNonQuery();
                            }

                            // Notify the teacher
                            string teacherUserId = "";
                            using (var cmd = new SqlCommand("SELECT [createdByUserId] FROM dbo.[Quiz] WHERE [quizId]=@id", conn, txn))
                            {
                                cmd.Parameters.AddWithValue("@id", quizId);
                                var result = cmd.ExecuteScalar();
                                teacherUserId = result?.ToString() ?? "";
                            }

                            if (!string.IsNullOrEmpty(teacherUserId))
                            {
                                string tEN, tBM, mEN, mBM;
                                string qTitle = "";
                                using (var cmd = new SqlCommand("SELECT ISNULL([quizTitleEN],[quizTitleBM]) FROM dbo.[Quiz] WHERE [quizId]=@id", conn, txn))
                                {
                                    cmd.Parameters.AddWithValue("@id", quizId);
                                    var result = cmd.ExecuteScalar();
                                    qTitle = result?.ToString() ?? quizId;
                                }

                                if (action == "Approve")
                                {
                                    tEN = "Quiz Approved"; tBM = "Kuiz Diluluskan";
                                    mEN = "Congratulations! Your quiz \"" + qTitle + "\" has been approved. Students can now attempt it.";
                                    mBM = "Tahniah! Kuiz anda \"" + qTitle + "\" telah diluluskan. Pelajar kini boleh menjawabnya.";
                                }
                                else
                                {
                                    tEN = "Quiz Rejected"; tBM = "Kuiz Ditolak";
                                    mEN = "Your quiz \"" + qTitle + "\" was not approved. Please review and resubmit.";
                                    mBM = "Kuiz anda \"" + qTitle + "\" tidak diluluskan. Sila semak dan hantar semula.";
                                }

                                string nId = GenId(conn, txn, "Notification", "notificationId", "N");
                                using (var cmd = new SqlCommand("INSERT INTO dbo.[Notification]([notificationId],[toUserId],[titleEN],[titleBM],[messageEN],[messageBM],[isRead],[createdAt]) VALUES(@a,@b,@c,@d,@e,@f,0,GETDATE())", conn, txn))
                                {
                                    cmd.Parameters.AddWithValue("@a", nId);
                                    cmd.Parameters.AddWithValue("@b", teacherUserId);
                                    cmd.Parameters.AddWithValue("@c", tEN);
                                    cmd.Parameters.AddWithValue("@d", tBM);
                                    cmd.Parameters.AddWithValue("@e", mEN);
                                    cmd.Parameters.AddWithValue("@f", mBM);
                                    cmd.ExecuteNonQuery();
                                }
                            }
                            txn.Commit();
                        }
                        catch
                        {
                            txn.Rollback();
                            Response.Write("{\"success\":false,\"msg\":\"Transaction failed.\"}");
                            Flush();
                            return;
                        }
                    }

                    // Return updated counts
                    string pending = SC(conn, "SELECT COUNT(*) FROM dbo.[Quiz] WHERE [status]='Pending'");
                    string approved = SC(conn, "SELECT COUNT(*) FROM dbo.[Quiz] WHERE [status]='Approved'");
                    string rejected = SC(conn, "SELECT COUNT(*) FROM dbo.[Quiz] WHERE [status]='Rejected'");
                    string today = SC(conn, "SELECT COUNT(*) FROM dbo.[Quiz] WHERE [status] IN ('Approved','Rejected') AND CAST([createdAt] AS DATE)=CAST(GETDATE() AS DATE)");
                    Response.Write("{\"success\":true,\"pending\":" + pending + ",\"approved\":" + approved + ",\"rejected\":" + rejected + ",\"today\":" + today + ",\"reviewedAt\":\"" + DateTime.Now.ToString("dd MMM yyyy") + "\"}");
                }
            }
            catch (Exception ex)
            {
                Response.Write("{\"success\":false,\"msg\":\"" + EJ(ex.Message) + "\"}");
            }
            Flush();
        }

        private void HandleView()
        {
            Response.Clear();
            Response.ContentType = "application/json";
            try
            {
                string quizId = Request.QueryString["quizId"] ?? "";
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    string tCol = CurrentLanguage == "BM"
                        ? "ISNULL(q.[quizTitleBM],q.[quizTitleEN])"
                        : "ISNULL(q.[quizTitleEN],q.[quizTitleBM])";

                    string sql = string.Format(@"SELECT q.[quizId], {0} AS title, q.[quizType], q.[language], q.[createdAt],
                        ISNULL(t.[name],u.[username]) AS teacher,
                        (SELECT COUNT(*) FROM dbo.[Question] qn WHERE qn.[quizId]=q.[quizId]) AS questionCount
                        FROM dbo.[Quiz] q LEFT JOIN dbo.[User] u ON u.[userId]=q.[createdByUserId]
                        LEFT JOIN dbo.[Teacher] t ON t.[userId]=q.[createdByUserId] WHERE q.[quizId]=@id", tCol);

                    var sb = new StringBuilder();
                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@id", quizId);
                        using (var rd = cmd.ExecuteReader())
                        {
                            if (!rd.Read()) { Response.Write("{\"success\":false,\"msg\":\"Not found\"}"); Flush(); return; }
                            sb.Append("{\"success\":true,\"quiz\":{");
                            sb.AppendFormat("\"quizId\":\"{0}\",", EJ(rd["quizId"]));
                            sb.AppendFormat("\"title\":\"{0}\",", EJ(rd["title"]));
                            sb.AppendFormat("\"quizType\":\"{0}\",", EJ(rd["quizType"]));
                            sb.AppendFormat("\"language\":\"{0}\",", EJ(rd["language"]));
                            sb.AppendFormat("\"teacher\":\"{0}\",", EJ(rd["teacher"]));
                            sb.AppendFormat("\"createdAt\":\"{0}\",", rd["createdAt"] != DBNull.Value ? Convert.ToDateTime(rd["createdAt"]).ToString("dd MMM yyyy HH:mm") : "-");
                            sb.AppendFormat("\"questionCount\":\"{0}\"", rd["questionCount"]);
                            sb.Append("},\"questions\":[");
                        }
                    }

                    // Get questions for this quiz
                    string qCol = CurrentLanguage == "BM" ? "ISNULL(qn.[questionTextBM],qn.[questionTextEN])" : "ISNULL(qn.[questionTextEN],qn.[questionTextBM])";
                    string oA = CurrentLanguage == "BM" ? "ISNULL(qn.[optionA_BM],qn.[optionA_EN])" : "ISNULL(qn.[optionA_EN],qn.[optionA_BM])";
                    string oB = CurrentLanguage == "BM" ? "ISNULL(qn.[optionB_BM],qn.[optionB_EN])" : "ISNULL(qn.[optionB_EN],qn.[optionB_BM])";
                    string oC = CurrentLanguage == "BM" ? "ISNULL(qn.[optionC_BM],qn.[optionC_EN])" : "ISNULL(qn.[optionC_EN],qn.[optionC_BM])";
                    string oD = CurrentLanguage == "BM" ? "ISNULL(qn.[optionD_BM],qn.[optionD_EN])" : "ISNULL(qn.[optionD_EN],qn.[optionD_BM])";
                    string expCol = CurrentLanguage == "BM" ? "ISNULL(qn.[correctExplanationBM],qn.[correctExplanationEN])" : "ISNULL(qn.[correctExplanationEN],qn.[correctExplanationBM])";

                    string qSql = string.Format(@"SELECT qn.[questionId], {0} AS text, qn.[questionType], qn.[difficulty],
                        {1} AS optA, {2} AS optB, {3} AS optC, {4} AS optD, qn.[correctAnswer], {5} AS explanation
                        FROM dbo.[Question] qn WHERE qn.[quizId]=@id ORDER BY qn.[questionId]", qCol, oA, oB, oC, oD, expCol);

                    using (var cmd = new SqlCommand(qSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@id", quizId);
                        using (var rd = cmd.ExecuteReader())
                        {
                            bool first = true;
                            while (rd.Read())
                            {
                                if (!first) sb.Append(",");
                                first = false;
                                sb.Append("{");
                                sb.AppendFormat("\"text\":\"{0}\",", EJ(rd["text"]));
                                sb.AppendFormat("\"type\":\"{0}\",", EJ(rd["questionType"]));
                                sb.AppendFormat("\"difficulty\":\"{0}\",", EJ(rd["difficulty"]));
                                sb.AppendFormat("\"optA\":\"{0}\",", EJ(rd["optA"]));
                                sb.AppendFormat("\"optB\":\"{0}\",", EJ(rd["optB"]));
                                sb.AppendFormat("\"optC\":\"{0}\",", EJ(rd["optC"]));
                                sb.AppendFormat("\"optD\":\"{0}\",", EJ(rd["optD"]));
                                sb.AppendFormat("\"correct\":\"{0}\",", EJ(rd["correctAnswer"]));
                                sb.AppendFormat("\"explanation\":\"{0}\"", EJ(rd["explanation"]));
                                sb.Append("}");
                            }
                        }
                    }
                    sb.Append("]}");
                    Response.Write(sb.ToString());
                }
            }
            catch (Exception ex)
            {
                Response.Write("{\"success\":false,\"msg\":\"" + EJ(ex.Message) + "\"}");
            }
            Flush();
        }

        // --- Helper Methods ---

        protected string GetTypeClass(object quizType)
        {
            string t = (quizType ?? "").ToString();
            switch (t)
            {
                case "Unit": return "sb-badge sb-badge-primary";
                case "Practice": return "sb-badge sb-badge-warning";
                case "Level": return "sb-badge sb-badge-success";
                default: return "sb-badge sb-badge-gray";
            }
        }

        protected string BuildBadge(string status)
        {
            switch (status)
            {
                case "Approved":
                    return "<span class=\"sb-badge sb-badge-success\"><i class=\"bi bi-check-circle-fill\"></i> Approved</span>";
                case "Rejected":
                    return "<span class=\"sb-badge sb-badge-error\"><i class=\"bi bi-x-circle-fill\"></i> Rejected</span>";
                default:
                    return "<span class=\"sb-badge sb-badge-warning\">" + status + "</span>";
            }
        }

        private string SC(SqlConnection c, string sql)
        {
            try
            {
                using (var cmd = new SqlCommand(sql, c))
                {
                    var val = cmd.ExecuteScalar();
                    return val != null && val != DBNull.Value ? Convert.ToInt32(val).ToString() : "0";
                }
            }
            catch { return "0"; }
        }

        private static string NS(object v)
        {
            return (v == null || v == DBNull.Value) ? "" : v.ToString();
        }

        private static string EJ(object v)
        {
            string s = NS(v);
            return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "");
        }

        private string GenId(SqlConnection conn, SqlTransaction txn, string table, string col, string prefix)
        {
            try
            {
                string sql = string.Format("SELECT MAX(CAST(SUBSTRING([{0}],{1},LEN([{0}])-{2}) AS INT)) FROM dbo.[{3}]",
                    col, prefix.Length + 1, prefix.Length, table);
                using (var cmd = new SqlCommand(sql, conn, txn))
                {
                    var val = cmd.ExecuteScalar();
                    int next = (val != null && val != DBNull.Value) ? Convert.ToInt32(val) + 1 : 1;
                    return prefix + next.ToString("D3");
                }
            }
            catch { return prefix + DateTime.Now.Ticks.ToString().Substring(10); }
        }

        private void Flush()
        {
            Response.Flush();
            HttpContext.Current.ApplicationInstance.CompleteRequest();
        }
    }
}
