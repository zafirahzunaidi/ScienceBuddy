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

            if (Request.QueryString["handler"] == "ReviewQuestion" && Request.HttpMethod == "POST")
            { _isAjax = true; HandleReviewQuestion(); return; }

            if (Request.QueryString["handler"] == "ViewQuiz" && Request.HttpMethod == "POST")
            { _isAjax = true; HandleView(); return; }

            if (Request.QueryString["handler"] == "AIAnalyzeQuiz" && Request.HttpMethod == "POST")
            { _isAjax = true; HandleAIAnalyzeQuiz(); return; }

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
                // Pending count: Practice quizzes pending + individual Unit/Level questions pending
                int pracPending = int.Parse(SC(conn, "SELECT COUNT(*) FROM dbo.[Quiz] WHERE [status]='Pending' AND [quizType]='Practice'"));
                int qnPending = int.Parse(SC(conn, "SELECT COUNT(*) FROM dbo.[Question] qn JOIN dbo.[Quiz] q ON q.[quizId]=qn.[quizId] WHERE qn.[status]='Pending' AND q.[quizType] IN ('Unit','Level')"));
                litPending.Text = (pracPending + qnPending).ToString();

                litApproved.Text = SC(conn, "SELECT COUNT(*) FROM dbo.[Quiz] WHERE [status]='Approved'");
                litRejected.Text = SC(conn, "SELECT COUNT(*) FROM dbo.[Quiz] WHERE [status]='Rejected'");
                litToday.Text = SC(conn, "SELECT COUNT(*) FROM dbo.[Quiz] WHERE [status] IN ('Approved','Rejected') AND CAST([createdAt] AS DATE)=CAST(GETDATE() AS DATE)");

                string pCount = (pracPending + qnPending).ToString();
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

                // ═══════════════════════════════════════════════════════
                // PENDING SECTION
                // ═══════════════════════════════════════════════════════
                var pendingList = new List<object>();

                // 1. Practice quizzes: show as whole quiz rows
                if (string.IsNullOrWhiteSpace(typeF) || typeF == "Practice")
                {
                    string pracSql = string.Format(@"SELECT q.[quizId], {0} AS quizTitle, q.[quizType], q.[language],
                        q.[createdAt], ISNULL(t.[name],u.[username]) AS teacherName,
                        (SELECT COUNT(*) FROM dbo.[Question] qn WHERE qn.[quizId]=q.[quizId]) AS questionCount
                        FROM dbo.[Quiz] q LEFT JOIN dbo.[User] u ON u.[userId]=q.[createdByUserId]
                        LEFT JOIN dbo.[Teacher] t ON t.[userId]=q.[createdByUserId]
                        WHERE q.[status]='Pending' AND q.[quizType]='Practice'", tCol);

                    if (!string.IsNullOrWhiteSpace(search))
                        pracSql += " AND (" + tCol + " LIKE @s OR q.[quizId] LIKE @s OR ISNULL(t.[name],u.[username]) LIKE @s)";
                    if (!string.IsNullOrWhiteSpace(langF))
                        pracSql += " AND q.[language]=@lg";
                    pracSql += " ORDER BY q.[createdAt] DESC";

                    using (var cmd = new SqlCommand(pracSql, conn))
                    {
                        if (!string.IsNullOrWhiteSpace(search)) cmd.Parameters.AddWithValue("@s", "%" + search + "%");
                        if (!string.IsNullOrWhiteSpace(langF)) cmd.Parameters.AddWithValue("@lg", langF);

                        var da = new SqlDataAdapter(cmd);
                        var dt = new DataTable();
                        da.Fill(dt);

                        foreach (DataRow r in dt.Rows)
                        {
                            pendingList.Add(new
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
                    }
                }

                // 2. Unit & Level quizzes: show each pending question as its own row
                if (string.IsNullOrWhiteSpace(typeF) || typeF == "Unit" || typeF == "Level")
                {
                    string qnCol = CurrentLanguage == "BM"
                        ? "ISNULL(qn.[questionTextBM],qn.[questionTextEN])"
                        : "ISNULL(qn.[questionTextEN],qn.[questionTextBM])";

                    string typeFilter = "";
                    if (typeF == "Unit") typeFilter = " AND q.[quizType]='Unit'";
                    else if (typeF == "Level") typeFilter = " AND q.[quizType]='Level'";
                    else typeFilter = " AND q.[quizType] IN ('Unit','Level')";

                    string qnSql = string.Format(@"SELECT qn.[questionId], {0} AS questionText, qn.[questionType], qn.[difficulty],
                        q.[quizId], q.[quizType], q.[language], qn.[createdAt],
                        ISNULL(t.[name],u.[username]) AS teacherName
                        FROM dbo.[Question] qn
                        JOIN dbo.[Quiz] q ON q.[quizId]=qn.[quizId]
                        LEFT JOIN dbo.[User] u ON u.[userId]=qn.[createdByUserId]
                        LEFT JOIN dbo.[Teacher] t ON t.[userId]=qn.[createdByUserId]
                        WHERE qn.[status]='Pending'{1}", qnCol, typeFilter);

                    if (!string.IsNullOrWhiteSpace(search))
                        qnSql += " AND (" + qnCol + " LIKE @s OR qn.[questionId] LIKE @s OR ISNULL(t.[name],u.[username]) LIKE @s OR q.[quizId] LIKE @s)";
                    if (!string.IsNullOrWhiteSpace(langF))
                        qnSql += " AND q.[language]=@lg";
                    qnSql += " ORDER BY qn.[createdAt] DESC";

                    using (var cmd = new SqlCommand(qnSql, conn))
                    {
                        if (!string.IsNullOrWhiteSpace(search)) cmd.Parameters.AddWithValue("@s", "%" + search + "%");
                        if (!string.IsNullOrWhiteSpace(langF)) cmd.Parameters.AddWithValue("@lg", langF);

                        var da = new SqlDataAdapter(cmd);
                        var dt = new DataTable();
                        da.Fill(dt);

                        foreach (DataRow r in dt.Rows)
                        {
                            string qText = NS(r["questionText"]);
                            if (qText.Length > 80) qText = qText.Substring(0, 80) + "…";

                            pendingList.Add(new
                            {
                                quizId = r["questionId"].ToString(),
                                quizTitle = qText,
                                quizType = NS(r["quizType"]),
                                language = NS(r["language"]),
                                teacherName = NS(r["teacherName"]),
                                questionCount = "1",
                                createdAt = r["createdAt"] != DBNull.Value
                                    ? Convert.ToDateTime(r["createdAt"]).ToString("dd MMM yyyy") : "-"
                            });
                        }
                    }
                }

                // Apply status filter for pending
                if (!string.IsNullOrWhiteSpace(statusF) && statusF != "Pending")
                    pendingList.Clear();

                if (pendingList.Count > 0)
                {
                    pnlPending.Visible = true;
                    pnlPendingEmpty.Visible = false;
                    rptPending.DataSource = pendingList;
                    rptPending.DataBind();
                }
                else
                {
                    pnlPending.Visible = false;
                    pnlPendingEmpty.Visible = true;
                }

                // ═══════════════════════════════════════════════════════
                // HISTORY SECTION
                // ═══════════════════════════════════════════════════════
                var histList = new List<object>();

                // 1. Practice quizzes: show as whole quiz rows
                if (string.IsNullOrWhiteSpace(typeF) || typeF == "Practice")
                {
                    string pracHistSql = string.Format(@"SELECT q.[quizId], {0} AS quizTitle, q.[quizType],
                        q.[createdAt], ISNULL(t.[name],u.[username]) AS teacherName, q.[status],
                        (SELECT COUNT(*) FROM dbo.[Question] qn WHERE qn.[quizId]=q.[quizId]) AS questionCount
                        FROM dbo.[Quiz] q LEFT JOIN dbo.[User] u ON u.[userId]=q.[createdByUserId]
                        LEFT JOIN dbo.[Teacher] t ON t.[userId]=q.[createdByUserId]
                        WHERE q.[status] IN ('Approved','Rejected') AND q.[quizType]='Practice'", tCol);

                    if (!string.IsNullOrWhiteSpace(search))
                        pracHistSql += " AND (" + tCol + " LIKE @s OR q.[quizId] LIKE @s OR ISNULL(t.[name],u.[username]) LIKE @s)";
                    if (!string.IsNullOrWhiteSpace(statusF) && statusF != "Pending")
                        pracHistSql += " AND q.[status]=@st";
                    if (!string.IsNullOrWhiteSpace(langF))
                        pracHistSql += " AND q.[language]=@lg";
                    pracHistSql += " ORDER BY q.[createdAt] DESC";

                    using (var cmd = new SqlCommand(pracHistSql, conn))
                    {
                        if (!string.IsNullOrWhiteSpace(search)) cmd.Parameters.AddWithValue("@s", "%" + search + "%");
                        if (!string.IsNullOrWhiteSpace(statusF) && statusF != "Pending") cmd.Parameters.AddWithValue("@st", statusF);
                        if (!string.IsNullOrWhiteSpace(langF)) cmd.Parameters.AddWithValue("@lg", langF);

                        var da = new SqlDataAdapter(cmd);
                        var dt = new DataTable();
                        da.Fill(dt);

                        foreach (DataRow r in dt.Rows)
                        {
                            DateTime dt2 = r["createdAt"] != DBNull.Value ? Convert.ToDateTime(r["createdAt"]) : DateTime.MinValue;
                            histList.Add(new
                            {
                                quizId = r["quizId"].ToString(),
                                quizTitle = NS(r["quizTitle"]),
                                quizType = NS(r["quizType"]),
                                teacherName = NS(r["teacherName"]),
                                questionCount = r["questionCount"].ToString(),
                                reviewedDate = dt2 != DateTime.MinValue
                                    ? dt2.ToString("dd MMM yyyy") : "-",
                                status = NS(r["status"]),
                                sortKey = dt2.ToString("yyyy-MM-dd HH:mm:ss")
                            });
                        }
                    }
                }

                // 2. Unit & Level: show each reviewed question as its own row
                if (string.IsNullOrWhiteSpace(typeF) || typeF == "Unit" || typeF == "Level")
                {
                    string qnCol = CurrentLanguage == "BM"
                        ? "ISNULL(qn.[questionTextBM],qn.[questionTextEN])"
                        : "ISNULL(qn.[questionTextEN],qn.[questionTextBM])";

                    string typeFilter = "";
                    if (typeF == "Unit") typeFilter = " AND q.[quizType]='Unit'";
                    else if (typeF == "Level") typeFilter = " AND q.[quizType]='Level'";
                    else typeFilter = " AND q.[quizType] IN ('Unit','Level')";

                    string histQnSql = string.Format(@"SELECT qn.[questionId], {0} AS questionText, qn.[questionType],
                        q.[quizId], q.[quizType], qn.[reviewedDate], qn.[status],
                        ISNULL(t.[name],u.[username]) AS teacherName
                        FROM dbo.[Question] qn
                        JOIN dbo.[Quiz] q ON q.[quizId]=qn.[quizId]
                        LEFT JOIN dbo.[User] u ON u.[userId]=qn.[createdByUserId]
                        LEFT JOIN dbo.[Teacher] t ON t.[userId]=qn.[createdByUserId]
                        WHERE qn.[status] IN ('Approved','Rejected'){1}", qnCol, typeFilter);

                    if (!string.IsNullOrWhiteSpace(search))
                        histQnSql += " AND (" + qnCol + " LIKE @s OR qn.[questionId] LIKE @s OR ISNULL(t.[name],u.[username]) LIKE @s OR q.[quizId] LIKE @s)";
                    if (!string.IsNullOrWhiteSpace(statusF) && statusF != "Pending")
                        histQnSql += " AND qn.[status]=@st";
                    if (!string.IsNullOrWhiteSpace(langF))
                        histQnSql += " AND q.[language]=@lg";
                    histQnSql += " ORDER BY qn.[reviewedDate] DESC";

                    using (var cmd = new SqlCommand(histQnSql, conn))
                    {
                        if (!string.IsNullOrWhiteSpace(search)) cmd.Parameters.AddWithValue("@s", "%" + search + "%");
                        if (!string.IsNullOrWhiteSpace(statusF) && statusF != "Pending") cmd.Parameters.AddWithValue("@st", statusF);
                        if (!string.IsNullOrWhiteSpace(langF)) cmd.Parameters.AddWithValue("@lg", langF);

                        var da = new SqlDataAdapter(cmd);
                        var dt = new DataTable();
                        da.Fill(dt);

                        foreach (DataRow r in dt.Rows)
                        {
                            string qText = NS(r["questionText"]);
                            if (qText.Length > 80) qText = qText.Substring(0, 80) + "…";
                            DateTime dt2 = r["reviewedDate"] != DBNull.Value ? Convert.ToDateTime(r["reviewedDate"]) : DateTime.MinValue;

                            histList.Add(new
                            {
                                quizId = r["questionId"].ToString(),
                                quizTitle = qText,
                                quizType = NS(r["quizType"]),
                                teacherName = NS(r["teacherName"]),
                                questionCount = "1",
                                reviewedDate = dt2 != DateTime.MinValue
                                    ? dt2.ToString("dd MMM yyyy") : "-",
                                status = NS(r["status"]),
                                sortKey = dt2.ToString("yyyy-MM-dd HH:mm:ss")
                            });
                        }
                    }
                }

                // Apply status filter for history
                if (!string.IsNullOrWhiteSpace(statusF) && statusF == "Pending")
                    histList.Clear();

                // Sort combined history by date descending (most recent first)
                histList.Sort((a, b) => string.Compare(
                    ((dynamic)b).sortKey,
                    ((dynamic)a).sortKey,
                    StringComparison.Ordinal));

                if (histList.Count > 0)
                {
                    pnlHistory.Visible = true;
                    pnlHistoryEmpty.Visible = false;
                    rptHistory.DataSource = histList;
                    rptHistory.DataBind();
                }
                else
                {
                    pnlHistory.Visible = false;
                    pnlHistoryEmpty.Visible = true;
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

                    // Get quiz status and type
                    string curStatus = "";
                    string quizType = "";
                    using (var cmd = new SqlCommand("SELECT [status],[quizType] FROM dbo.[Quiz] WHERE [quizId]=@id", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", quizId);
                        using (var rd = cmd.ExecuteReader())
                        {
                            if (rd.Read())
                            {
                                curStatus = rd["status"]?.ToString() ?? "";
                                quizType = rd["quizType"]?.ToString() ?? "";
                            }
                        }
                    }

                    // Unit and Level quizzes must be reviewed question-by-question
                    if (quizType == "Unit" || quizType == "Level")
                    {
                        Response.Write("{\"success\":false,\"msg\":\"Unit and Level quizzes must be reviewed question-by-question. Please use the View button to review individual questions.\"}");
                        Flush();
                        return;
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

                            // Update all questions in the quiz (Practice only)
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

        private void HandleReviewQuestion()
        {
            Response.Clear();
            Response.ContentType = "application/json";
            try
            {
                if (Session["userId"] == null || Session["role"]?.ToString() != "Admin")
                { Response.Write("{\"success\":false,\"msg\":\"Unauthorized\"}"); Flush(); return; }

                string questionId = Request.QueryString["questionId"] ?? "";
                string action = Request.QueryString["action"] ?? "";
                string adminId = Session["userId"].ToString();
                string newStatus = action == "Approve" ? "Approved" : "Rejected";

                if (string.IsNullOrEmpty(questionId))
                { Response.Write("{\"success\":false,\"msg\":\"Missing questionId\"}"); Flush(); return; }

                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // Get the quizId for this question
                    string quizId = "";
                    using (var cmd = new SqlCommand("SELECT [quizId] FROM dbo.[Question] WHERE [questionId]=@id", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", questionId);
                        var val = cmd.ExecuteScalar();
                        quizId = val?.ToString() ?? "";
                    }

                    if (string.IsNullOrEmpty(quizId))
                    { Response.Write("{\"success\":false,\"msg\":\"Question not found.\"}"); Flush(); return; }

                    // Update only this question
                    using (var cmd = new SqlCommand("UPDATE dbo.[Question] SET [status]=@st, [reviewedDate]=GETDATE() WHERE [questionId]=@id", conn))
                    {
                        cmd.Parameters.AddWithValue("@st", newStatus);
                        cmd.Parameters.AddWithValue("@id", questionId);
                        cmd.ExecuteNonQuery();
                    }

                    // Recalculate quiz status
                    string quizStatus = RecalculateQuizStatus(conn, quizId);

                    // Update quiz status
                    using (var cmd = new SqlCommand("UPDATE dbo.[Quiz] SET [status]=@st WHERE [quizId]=@id", conn))
                    {
                        cmd.Parameters.AddWithValue("@st", quizStatus);
                        cmd.Parameters.AddWithValue("@id", quizId);
                        cmd.ExecuteNonQuery();
                    }

                    // Log
                    string logId = GenId(conn, null, "Log", "logId", "LOG");
                    using (var cmd = new SqlCommand("INSERT INTO dbo.[Log]([logId],[userId],[action],[description],[logDateTime],[status]) VALUES(@a,@b,@c,@d,GETDATE(),'Success')", conn))
                    {
                        cmd.Parameters.AddWithValue("@a", logId);
                        cmd.Parameters.AddWithValue("@b", adminId);
                        cmd.Parameters.AddWithValue("@c", action == "Approve" ? "Approved Question" : "Rejected Question");
                        cmd.Parameters.AddWithValue("@d", "Admin " + action.ToLower() + "d question " + questionId + " in quiz " + quizId + ".");
                        cmd.ExecuteNonQuery();
                    }

                    // Notify the teacher who created this question
                    try
                    {
                        string questionCreatorId = "";
                        using (var cmd = new SqlCommand("SELECT [createdByUserId] FROM dbo.[Question] WHERE [questionId]=@id", conn))
                        {
                            cmd.Parameters.AddWithValue("@id", questionId);
                            var result = cmd.ExecuteScalar();
                            questionCreatorId = result?.ToString() ?? "";
                        }

                        if (!string.IsNullOrEmpty(questionCreatorId))
                        {
                            string qTitle = "";
                            using (var cmd = new SqlCommand("SELECT ISNULL([quizTitleEN],[quizTitleBM]) FROM dbo.[Quiz] WHERE [quizId]=@id", conn))
                            {
                                cmd.Parameters.AddWithValue("@id", quizId);
                                var result = cmd.ExecuteScalar();
                                qTitle = result?.ToString() ?? quizId;
                            }

                            string tEN, tBM, mEN, mBM;
                            if (action == "Approve")
                            {
                                tEN = "Question Approved"; tBM = "Soalan Diluluskan";
                                mEN = "Your question (ID: " + questionId + ") in quiz \"" + qTitle + "\" has been approved.";
                                mBM = "Soalan anda (ID: " + questionId + ") dalam kuiz \"" + qTitle + "\" telah diluluskan.";
                            }
                            else
                            {
                                tEN = "Question Rejected"; tBM = "Soalan Ditolak";
                                mEN = "Your question (ID: " + questionId + ") in quiz \"" + qTitle + "\" was not approved. Please review and resubmit.";
                                mBM = "Soalan anda (ID: " + questionId + ") dalam kuiz \"" + qTitle + "\" tidak diluluskan. Sila semak dan hantar semula.";
                            }

                            string nId = GenId(conn, null, "Notification", "notificationId", "N");
                            using (var cmd = new SqlCommand("INSERT INTO dbo.[Notification]([notificationId],[toUserId],[titleEN],[titleBM],[messageEN],[messageBM],[isRead],[createdAt]) VALUES(@a,@b,@c,@d,@e,@f,0,GETDATE())", conn))
                            {
                                cmd.Parameters.AddWithValue("@a", nId);
                                cmd.Parameters.AddWithValue("@b", questionCreatorId);
                                cmd.Parameters.AddWithValue("@c", tEN);
                                cmd.Parameters.AddWithValue("@d", tBM);
                                cmd.Parameters.AddWithValue("@e", mEN);
                                cmd.Parameters.AddWithValue("@f", mBM);
                                cmd.ExecuteNonQuery();
                            }
                        }
                    }
                    catch { /* notification failure should not block success */ }

                    // Notify teacher if all questions reviewed (quiz fully resolved) - for Practice quizzes
                    if (quizStatus == "Approved" || quizStatus == "Rejected")
                    {
                        try
                        {
                            string teacherUserId = "";
                            using (var cmd = new SqlCommand("SELECT [createdByUserId] FROM dbo.[Quiz] WHERE [quizId]=@id", conn))
                            {
                                cmd.Parameters.AddWithValue("@id", quizId);
                                var result = cmd.ExecuteScalar();
                                teacherUserId = result?.ToString() ?? "";
                            }

                            if (!string.IsNullOrEmpty(teacherUserId) && teacherUserId != adminId)
                            {
                                string qTitle = "";
                                using (var cmd = new SqlCommand("SELECT ISNULL([quizTitleEN],[quizTitleBM]) FROM dbo.[Quiz] WHERE [quizId]=@id", conn))
                                {
                                    cmd.Parameters.AddWithValue("@id", quizId);
                                    var result = cmd.ExecuteScalar();
                                    qTitle = result?.ToString() ?? quizId;
                                }

                                string tEN, tBM, mEN, mBM;
                                if (quizStatus == "Approved")
                                {
                                    tEN = "Quiz Approved"; tBM = "Kuiz Diluluskan";
                                    mEN = "All questions in your quiz \"" + qTitle + "\" have been approved. Students can now attempt it.";
                                    mBM = "Semua soalan dalam kuiz anda \"" + qTitle + "\" telah diluluskan. Pelajar kini boleh menjawabnya.";
                                }
                                else
                                {
                                    tEN = "Quiz Review Complete"; tBM = "Semakan Kuiz Selesai";
                                    mEN = "The review for your quiz \"" + qTitle + "\" is complete. One or more questions were rejected. Please review and resubmit.";
                                    mBM = "Semakan kuiz anda \"" + qTitle + "\" telah selesai. Satu atau lebih soalan telah ditolak. Sila semak dan hantar semula.";
                                }

                                string nId = GenId(conn, null, "Notification", "notificationId", "N");
                                using (var cmd = new SqlCommand("INSERT INTO dbo.[Notification]([notificationId],[toUserId],[titleEN],[titleBM],[messageEN],[messageBM],[isRead],[createdAt]) VALUES(@a,@b,@c,@d,@e,@f,0,GETDATE())", conn))
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
                        }
                        catch { /* notification failure should not block success */ }
                    }

                    // Return updated stats
                    string pending = SC(conn, "SELECT COUNT(*) FROM dbo.[Quiz] WHERE [status]='Pending'");
                    string approved = SC(conn, "SELECT COUNT(*) FROM dbo.[Quiz] WHERE [status]='Approved'");
                    string rejected = SC(conn, "SELECT COUNT(*) FROM dbo.[Quiz] WHERE [status]='Rejected'");
                    string today = SC(conn, "SELECT COUNT(*) FROM dbo.[Quiz] WHERE [status] IN ('Approved','Rejected') AND CAST([createdAt] AS DATE)=CAST(GETDATE() AS DATE)");
                    Response.Write("{\"success\":true,\"questionId\":\"" + EJ(questionId) + "\",\"newStatus\":\"" + EJ(newStatus) + "\",\"quizStatus\":\"" + EJ(quizStatus) + "\",\"quizId\":\"" + EJ(quizId) + "\",\"pending\":" + pending + ",\"approved\":" + approved + ",\"rejected\":" + rejected + ",\"today\":" + today + "}");
                }
            }
            catch (Exception ex)
            {
                Response.Write("{\"success\":false,\"msg\":\"" + EJ(ex.Message) + "\"}");
            }
            Flush();
        }

        private string RecalculateQuizStatus(SqlConnection conn, string quizId)
        {
            int totalQ = 0, approvedQ = 0, rejectedQ = 0, pendingQ = 0;
            using (var cmd = new SqlCommand(@"SELECT 
                COUNT(*) AS total,
                SUM(CASE WHEN [status]='Approved' THEN 1 ELSE 0 END) AS approved,
                SUM(CASE WHEN [status]='Rejected' THEN 1 ELSE 0 END) AS rejected,
                SUM(CASE WHEN [status]='Pending' THEN 1 ELSE 0 END) AS pending
                FROM dbo.[Question] WHERE [quizId]=@id", conn))
            {
                cmd.Parameters.AddWithValue("@id", quizId);
                using (var rd = cmd.ExecuteReader())
                {
                    if (rd.Read())
                    {
                        totalQ = rd["total"] != DBNull.Value ? Convert.ToInt32(rd["total"]) : 0;
                        approvedQ = rd["approved"] != DBNull.Value ? Convert.ToInt32(rd["approved"]) : 0;
                        rejectedQ = rd["rejected"] != DBNull.Value ? Convert.ToInt32(rd["rejected"]) : 0;
                        pendingQ = rd["pending"] != DBNull.Value ? Convert.ToInt32(rd["pending"]) : 0;
                    }
                }
            }

            if (totalQ == 0) return "Pending";
            if (approvedQ == totalQ) return "Approved";
            if (rejectedQ > 0 && pendingQ == 0) return "Rejected";
            return "Pending";
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

                    // If the ID is a questionId, resolve to parent quizId
                    using (var chk = new SqlCommand("SELECT [quizId] FROM dbo.[Question] WHERE [questionId]=@id", conn))
                    {
                        chk.Parameters.AddWithValue("@id", quizId);
                        var parentId = chk.ExecuteScalar();
                        if (parentId != null && parentId != DBNull.Value)
                            quizId = parentId.ToString();
                    }

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

                    string qSql = string.Format(@"SELECT qn.[questionId], {0} AS text, qn.[questionType], qn.[difficulty], qn.[status],
                        {1} AS optA, {2} AS optB, {3} AS optC, {4} AS optD, qn.[correctAnswer], {5} AS explanation,
                        qn.[reviewedDate]
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
                                sb.AppendFormat("\"questionId\":\"{0}\",", EJ(rd["questionId"]));
                                sb.AppendFormat("\"text\":\"{0}\",", EJ(rd["text"]));
                                sb.AppendFormat("\"type\":\"{0}\",", EJ(rd["questionType"]));
                                sb.AppendFormat("\"difficulty\":\"{0}\",", EJ(rd["difficulty"]));
                                sb.AppendFormat("\"status\":\"{0}\",", EJ(rd["status"]));
                                sb.AppendFormat("\"reviewedDate\":\"{0}\",", rd["reviewedDate"] != DBNull.Value ? Convert.ToDateTime(rd["reviewedDate"]).ToString("dd MMM yyyy") : "");
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

        // --- AI Quiz Analysis ---

        private void HandleAIAnalyzeQuiz()
        {
            Response.Clear(); Response.ContentType = "application/json";
            try
            {
                string quizId = Request.Form["quizId"] ?? "";
                if (string.IsNullOrWhiteSpace(quizId))
                { Response.Write("{\"success\":false,\"error\":\"Missing quizId\"}"); return; }

                var aiContent = new StringBuilder();
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // If the ID is a questionId, resolve to parent quizId
                    using (var chk = new SqlCommand("SELECT [quizId] FROM dbo.[Question] WHERE [questionId]=@id", conn))
                    {
                        chk.Parameters.AddWithValue("@id", quizId);
                        var parentId = chk.ExecuteScalar();
                        if (parentId != null && parentId != DBNull.Value)
                            quizId = parentId.ToString();
                    }

                    using (var cmd = new SqlCommand("SELECT ISNULL([quizTitleEN],[quizTitleBM]) AS title, [quizType], [language] FROM dbo.[Quiz] WHERE [quizId]=@id", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", quizId);
                        using (var rd = cmd.ExecuteReader())
                        {
                            if (rd.Read())
                            {
                                aiContent.AppendLine("Quiz Title: " + (rd["title"]?.ToString() ?? ""));
                                aiContent.AppendLine("Quiz Type: " + (rd["quizType"]?.ToString() ?? ""));
                                aiContent.AppendLine("Language: " + (rd["language"]?.ToString() ?? ""));
                            }
                        }
                    }
                    using (var cmd = new SqlCommand(@"SELECT ISNULL([questionTextEN],[questionTextBM]) AS text, [difficulty],
                        ISNULL([optionA_EN],[optionA_BM]) AS optA, ISNULL([optionB_EN],[optionB_BM]) AS optB,
                        ISNULL([optionC_EN],[optionC_BM]) AS optC, ISNULL([optionD_EN],[optionD_BM]) AS optD,
                        [correctAnswer] FROM dbo.[Question] WHERE [quizId]=@id ORDER BY [questionId]", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", quizId);
                        using (var rd = cmd.ExecuteReader())
                        {
                            int qNum = 1;
                            while (rd.Read())
                            {
                                aiContent.AppendLine("\nQ" + qNum + ": " + (rd["text"]?.ToString() ?? ""));
                                if (rd["difficulty"] != DBNull.Value) aiContent.AppendLine("Difficulty: " + rd["difficulty"].ToString());
                                string oA = rd["optA"]?.ToString() ?? "", oB = rd["optB"]?.ToString() ?? "";
                                string oC = rd["optC"]?.ToString() ?? "", oD = rd["optD"]?.ToString() ?? "";
                                if (!string.IsNullOrEmpty(oA)) aiContent.AppendLine("A) " + oA);
                                if (!string.IsNullOrEmpty(oB)) aiContent.AppendLine("B) " + oB);
                                if (!string.IsNullOrEmpty(oC)) aiContent.AppendLine("C) " + oC);
                                if (!string.IsNullOrEmpty(oD)) aiContent.AppendLine("D) " + oD);
                                aiContent.AppendLine("Answer: " + (rd["correctAnswer"]?.ToString() ?? ""));
                                qNum++;
                            }
                        }
                    }
                }

                string systemPrompt = @"You are an AI Educational Quiz Reviewer for ScienceBuddy, a Malaysian Primary School Science learning platform.
Review this science quiz according to the Malaysian Primary School Science Curriculum (KSSR).
Evaluate: Scientific Accuracy, Correct Answer Accuracy, Duplicate/Similar Questions, Question Clarity.
If you detect incorrect scientific facts, wrong correct answers, duplicate questions, or unclear wording, mention them in the summary.

Recommendation MUST be one of: Approve, Review Manually, Reject
Confidence MUST be a percentage.
Summary MUST NOT exceed 40 words.

Return ONLY valid JSON. No explanations. No markdown.
{""recommendation"":"""",""confidence"":"""",""scientificAccuracy"":"""",""correctAnswers"":"""",""duplicateQuestions"":"""",""questionClarity"":"""",""summary"":""""}";

                var aiService = new ScienceBuddy.Services.NvidiaAIService();
                var task = System.Threading.Tasks.Task.Run(async () =>
                    await aiService.AnalyzeEducationalContentAsync(aiContent.ToString(), systemPrompt, 512));
                if (!task.Wait(65000))
                { Response.Write("{\"success\":false,\"error\":\"AI request timed out.\"}"); return; }
                var result = task.Result;

                if (result.IsSuccess)
                {
                    string raw = (result.Response ?? "").Trim();
                    int s = raw.IndexOf('{'), e = raw.LastIndexOf('}');
                    if (s < 0 || e <= s)
                    { Response.Write("{\"success\":false,\"error\":\"No JSON found\",\"rawResponse\":\"" + EJ(raw.Length > 300 ? raw.Substring(0, 300) : raw) + "\"}"); return; }
                    var parsed = Newtonsoft.Json.JsonConvert.DeserializeObject<System.Collections.Generic.Dictionary<string, string>>(raw.Substring(s, e - s + 1));
                    string[] keys = { "recommendation", "confidence", "scientificAccuracy", "correctAnswers", "duplicateQuestions", "questionClarity", "summary" };
                    var clean = new System.Collections.Generic.Dictionary<string, string>();
                    foreach (var k in keys) { string v = (parsed != null && parsed.ContainsKey(k)) ? (parsed[k] ?? "").Trim() : ""; clean[k] = string.IsNullOrWhiteSpace(v) ? "Not Available" : v; }
                    Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(new { success = true, data = clean }));
                }
                else { Response.Write("{\"success\":false,\"error\":\"" + EJ(result.ErrorMessage) + "\"}"); }
            }
            catch (Exception ex) { Response.Write("{\"success\":false,\"error\":\"" + EJ(ex.Message) + "\"}"); }
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
                using (var cmd = txn != null ? new SqlCommand(sql, conn, txn) : new SqlCommand(sql, conn))
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
