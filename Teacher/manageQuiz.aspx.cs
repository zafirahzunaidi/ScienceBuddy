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
    public partial class manageQuiz : Page
    {
        #region Properties

        protected global::System.Web.UI.WebControls.LinkButton btnTabUnitLevel;
        protected global::System.Web.UI.WebControls.Panel pnlCreateULBtn;
        protected global::System.Web.UI.WebControls.Panel pnlUnitLevel;
        protected global::System.Web.UI.WebControls.Panel pnlUnitLevelEmpty;
        protected global::System.Web.UI.WebControls.Repeater rptUnitLevelQs;
        protected global::System.Web.UI.WebControls.Panel pnlUnitCards;
        protected global::System.Web.UI.WebControls.Repeater rptUnitQs;
        protected global::System.Web.UI.WebControls.Panel pnlUnitEmpty;
        protected global::System.Web.UI.WebControls.Panel pnlLevelCards;
        protected global::System.Web.UI.WebControls.Repeater rptLevelQs;
        protected global::System.Web.UI.WebControls.Panel pnlLevelEmpty;
        protected global::System.Web.UI.WebControls.Literal litUnitGrouped;
        protected global::System.Web.UI.WebControls.Literal litEmptyMsg;

        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected string CurrentLanguage
        {
            get
            {
                string lang = Session["preferredLanguage"] as string;
                return string.IsNullOrEmpty(lang) ? "EN" : lang;
            }
        }

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

            // Route AJAX requests to their handlers
            string handler = Request.QueryString["handler"];
            if (!string.IsNullOrEmpty(handler))
            {
                switch (handler)
                {
                    case "ulquestions": HandleULQuestionRequest(); return;
                    case "subtopics": HandleSubtopicRequest(); return;
                    case "discoverquiz": HandleDiscoverQuizRequest(); return;
                    case "pqlevels": HandlePQLevelsRequest(); return;
                    case "pqunits": HandlePQUnitsRequest(); return;
                    case "pqsubtopics": HandlePQSubtopicsRequest(); return;
                    case "resubmit": HandleResubmitRequest(); return;
                }
            }

            var master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                if (!Authorize()) return;
                SetupControls();

                // Check for Practice Quiz submission success (redirected from createPracticeQuiz)
                string practiceQuizSuccess = Session["PracticeQuizSuccess"] as string;
                if (!string.IsNullOrEmpty(practiceQuizSuccess) || Request.QueryString["tab"] == "practice")
                {
                    hidActiveTab.Value = "mine";
                    if (!string.IsNullOrEmpty(practiceQuizSuccess))
                    {
                        hidToast.Value = practiceQuizSuccess;
                        Session.Remove("PracticeQuizSuccess");
                    }
                }
                else
                {
                    hidActiveTab.Value = "unitlevel";
                }

                SetTabUI();
                LoadForActiveTab();
            }
        }

        #endregion

        #region Event Handlers

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadForActiveTab();
        }

        protected void ddlFilter_Changed(object sender, EventArgs e)
        {
            LoadForActiveTab();
        }

        protected void btnTabUnitLevel_Click(object sender, EventArgs e)
        {
            hidActiveTab.Value = "unitlevel";
            SetTabUI();
            LoadForActiveTab();
        }

        protected void btnTabMine_Click(object sender, EventArgs e)
        {
            hidActiveTab.Value = "mine";
            SetTabUI();
            LoadForActiveTab();
        }

        protected void btnTabDiscover_Click(object sender, EventArgs e)
        {
            hidActiveTab.Value = "discover";
            SetTabUI();
            LoadForActiveTab();
        }

        protected void btnChip_Click(object sender, EventArgs e)
        {
            var btn = sender as LinkButton;
            string status = btn?.CommandArgument ?? "";

            btnChipAll.CssClass = "tc-manage-quiz-chip" + (status == "" ? " active" : "");
            btnChipApproved.CssClass = "tc-manage-quiz-chip" + (status == "Approved" ? " active" : "");
            btnChipPending.CssClass = "tc-manage-quiz-chip" + (status == "Pending" ? " active" : "");
            btnChipRejected.CssClass = "tc-manage-quiz-chip" + (status == "Rejected" ? " active" : "");

            try { ddlStatus.SelectedValue = status; } catch { }
            LoadForActiveTab();
        }

        protected void btnConfirmDelete_Click(object sender, EventArgs e)
        {
            string quizId = hidDeleteId.Value;
            string teacherId = Session["userId"].ToString();

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // Delete questions first (FK constraint)
                    using (var cmd = new SqlCommand("DELETE FROM dbo.[Question] WHERE [quizId]=@qid AND [createdByUserId]=@uid", conn))
                    {
                        cmd.Parameters.AddWithValue("@qid", quizId);
                        cmd.Parameters.AddWithValue("@uid", teacherId);
                        cmd.ExecuteNonQuery();
                    }

                    // Delete quiz
                    using (var cmd = new SqlCommand("DELETE FROM dbo.[Quiz] WHERE [quizId]=@qid AND [createdByUserId]=@uid", conn))
                    {
                        cmd.Parameters.AddWithValue("@qid", quizId);
                        cmd.Parameters.AddWithValue("@uid", teacherId);
                        cmd.ExecuteNonQuery();
                    }
                }
                hidToast.Value = T("Quiz deleted successfully.", "Kuiz berjaya dipadam.");
            }
            catch
            {
                hidToast.Value = T("Could not delete quiz.", "Tidak dapat memadam kuiz.");
            }

            LoadQuizzes();
        }

        protected void ddlCreateType_Changed(object sender, EventArgs e)
        {
            string quizType = ddlCreateType.SelectedValue;

            pnlCreateLevel.Visible = (quizType == "Level");
            pnlCreateUnit.Visible = (quizType == "Unit");
            pnlCreateSubtopic.Visible = (quizType == "Practice" || quizType == "Unit" || quizType == "Level");
            pnlCreateLang.Visible = (quizType == "Practice");

            ddlCreateSubtopic.Items.Clear();
            ddlCreateSubtopic.Items.Add(new ListItem(T("— Select Subtopic —", "— Pilih Subtopik —"), ""));
            ddlCreateUnit.Items.Clear();
            ddlCreateUnit.Items.Add(new ListItem(T("— Select Unit —", "— Pilih Unit —"), ""));

            if (quizType == "Unit") LoadCreateUnits();

            hidShowCreateModal.Value = "1";
        }

        protected void ddlCreateLevel_Changed(object sender, EventArgs e)
        {
            // For Level quiz: load subtopics for the entire level
            ddlCreateSubtopic.Items.Clear();
            ddlCreateSubtopic.Items.Add(new ListItem(T("— Select Subtopic —", "— Pilih Subtopik —"), ""));

            string selectedLevelId = ddlCreateLevel.SelectedValue;
            if (!string.IsNullOrEmpty(selectedLevelId))
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    const string sql = @"SELECT st.[subtopicId], st.[subtopicTitleEN] 
                        FROM dbo.[Subtopic] st
                        INNER JOIN dbo.[Unit] u ON u.[unitId] = st.[unitId] 
                        WHERE u.[levelId] = @lid 
                        ORDER BY u.[orderNo], st.[orderNo]";

                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@lid", selectedLevelId);
                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                                ddlCreateSubtopic.Items.Add(new ListItem(reader["subtopicTitleEN"].ToString(), reader["subtopicId"].ToString()));
                        }
                    }
                }
            }

            hidShowCreateModal.Value = "1";
        }

        protected void ddlCreateUnit_Changed(object sender, EventArgs e)
        {
            ddlCreateSubtopic.Items.Clear();
            ddlCreateSubtopic.Items.Add(new ListItem(T("— Select Subtopic —", "— Pilih Subtopik —"), ""));

            string selectedUnitId = ddlCreateUnit.SelectedValue;
            if (!string.IsNullOrEmpty(selectedUnitId))
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("SELECT [subtopicId],[subtopicTitleEN] FROM dbo.[Subtopic] WHERE [unitId]=@u ORDER BY [orderNo]", conn))
                    {
                        cmd.Parameters.AddWithValue("@u", selectedUnitId);
                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                                ddlCreateSubtopic.Items.Add(new ListItem(reader["subtopicTitleEN"].ToString(), reader["subtopicId"].ToString()));
                        }
                    }
                }
            }

            hidShowCreateModal.Value = "1";
        }

        protected void btnContinue_Click(object sender, EventArgs e)
        {
            string quizType = ddlCreateType.SelectedValue;
            string subtopicId = ddlCreateSubtopic.SelectedValue;

            if (string.IsNullOrEmpty(quizType) || string.IsNullOrEmpty(subtopicId))
            {
                hidShowCreateModal.Value = "1";
                return;
            }

            if (quizType == "Practice")
            {
                string language = ddlCreateLang.SelectedValue;
                if (string.IsNullOrEmpty(language)) { hidShowCreateModal.Value = "1"; return; }
                Response.Redirect("~/Teacher/createPracticeQuiz.aspx?language=" + language + "&subtopicId=" + subtopicId, false);
            }
            else if (quizType == "Unit")
            {
                string unitId = ddlCreateUnit.SelectedValue;
                if (string.IsNullOrEmpty(unitId)) { hidShowCreateModal.Value = "1"; return; }
                Response.Redirect("~/Teacher/createUnitLevelQuiz.aspx?mode=unit&unitId=" + unitId + "&subtopicId=" + subtopicId, false);
            }
            else if (quizType == "Level")
            {
                string levelId = ddlCreateLevel.SelectedValue;
                if (string.IsNullOrEmpty(levelId)) { hidShowCreateModal.Value = "1"; return; }
                Response.Redirect("~/Teacher/createUnitLevelQuiz.aspx?mode=level&level=" + levelId + "&subtopicId=" + subtopicId, false);
            }

            Context.ApplicationInstance.CompleteRequest();
        }

        #endregion

        #region AJAX Handlers

        private void HandleULQuestionRequest()
        {
            Response.Clear();
            Response.ContentType = "text/html";

            string quizId = (Request.QueryString["quizId"] ?? "").Trim();
            string teacherId = Session["userId"]?.ToString() ?? "";

            if (string.IsNullOrEmpty(quizId))
            {
                Response.Write("<div class='tc-manage-quiz-empty'>Invalid request.</div>");
                Response.End();
                return;
            }

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    var html = new System.Text.StringBuilder();

                    RenderQuizHeader(conn, quizId, html);
                    RenderTeacherQuestions(conn, quizId, teacherId, html);

                    Response.Write(html.ToString());
                }
            }
            catch
            {
                Response.Write("<div class='tc-manage-quiz-empty'>Error loading questions.</div>");
            }

            Response.End();
        }

        private void HandleSubtopicRequest()
        {
            Response.Clear();
            Response.ContentType = "application/json";

            string quizId = (Request.QueryString["quizId"] ?? "").Trim();
            if (string.IsNullOrEmpty(quizId))
            {
                Response.Write("{\"error\":\"Invalid\"}");
                Response.End();
                return;
            }

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    string quizType = "", unitId = "", levelId = "", scopeName = "";
                    using (var cmd = new SqlCommand(@"SELECT q.[quizType], q.[unitId], q.[levelId],
                        CASE WHEN q.[quizType]='Unit' THEN COALESCE(u.[unitNameEN],'-') ELSE COALESCE(lv.[levelNameEN],'-') END AS scopeName
                        FROM dbo.[Quiz] q LEFT JOIN dbo.[Unit] u ON u.[unitId]=q.[unitId] LEFT JOIN dbo.[Level] lv ON lv.[levelId]=q.[levelId]
                        WHERE q.[quizId]=@qid", conn))
                    {
                        cmd.Parameters.AddWithValue("@qid", quizId);
                        using (var reader = cmd.ExecuteReader())
                        {
                            if (!reader.Read())
                            {
                                Response.Write("{\"error\":\"Quiz not found\"}");
                                Response.End();
                                return;
                            }
                            quizType = reader["quizType"]?.ToString() ?? "";
                            unitId = reader["unitId"]?.ToString() ?? "";
                            levelId = reader["levelId"]?.ToString() ?? "";
                            scopeName = reader["scopeName"]?.ToString() ?? "-";
                        }
                    }

                    // Determine subtopic query based on quiz scope
                    string subtopicSql;
                    string filterValue;
                    if (quizType == "Unit")
                    {
                        subtopicSql = "SELECT [subtopicId],[subtopicTitleEN] FROM dbo.[Subtopic] WHERE [unitId]=@v ORDER BY [orderNo]";
                        filterValue = unitId;
                    }
                    else
                    {
                        subtopicSql = "SELECT st.[subtopicId], st.[subtopicTitleEN] FROM dbo.[Subtopic] st INNER JOIN dbo.[Unit] u ON u.[unitId]=st.[unitId] WHERE u.[levelId]=@v ORDER BY u.[orderNo], st.[orderNo]";
                        filterValue = levelId;
                    }

                    var json = new System.Text.StringBuilder();
                    json.AppendFormat("{{\"quizType\":\"{0}\",\"scopeName\":\"{1}\",\"subtopics\":[",
                        HttpUtility.JavaScriptStringEncode(quizType),
                        HttpUtility.JavaScriptStringEncode(scopeName));

                    bool first = true;
                    using (var cmd = new SqlCommand(subtopicSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@v", filterValue);
                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                if (!first) json.Append(",");
                                first = false;
                                json.AppendFormat("{{\"id\":\"{0}\",\"name\":\"{1}\"}}",
                                    HttpUtility.JavaScriptStringEncode(reader["subtopicId"].ToString()),
                                    HttpUtility.JavaScriptStringEncode(reader["subtopicTitleEN"].ToString()));
                            }
                        }
                    }

                    json.Append("]}");
                    Response.Write(json.ToString());
                }
            }
            catch
            {
                Response.Write("{\"error\":\"Server error\"}");
            }

            Response.End();
        }

        private void HandleDiscoverQuizRequest()
        {
            Response.Clear();
            Response.ContentType = "text/html";

            string quizId = (Request.QueryString["quizId"] ?? "").Trim();
            if (string.IsNullOrEmpty(quizId))
            {
                Response.Write("<div class='tc-manage-quiz-empty'><div class='tc-manage-quiz-empty-title'>Invalid request.</div></div>");
                Response.End();
                return;
            }

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    var html = new System.Text.StringBuilder();
                    string teacherId = Session["userId"]?.ToString() ?? "";

                    // Check if this is the current teacher's own Practice Quiz
                    bool isOwnPractice = false;
                    using (var chk = new SqlCommand("SELECT COUNT(*) FROM dbo.[Quiz] WHERE [quizId]=@qid AND [quizType]='Practice' AND [createdByUserId]=@uid", conn))
                    {
                        chk.Parameters.AddWithValue("@qid", quizId);
                        chk.Parameters.AddWithValue("@uid", teacherId);
                        isOwnPractice = (int)chk.ExecuteScalar() > 0;
                    }

                    // Own Practice Quiz shows ALL questions; otherwise only Approved
                    string sql = @"
                        SELECT qn.[questionTextEN], qn.[questionTextBM], qn.[questionType], qn.[difficulty],
                               qn.[optionA_EN], qn.[optionA_BM], qn.[optionB_EN], qn.[optionB_BM],
                               qn.[optionC_EN], qn.[optionC_BM], qn.[optionD_EN], qn.[optionD_BM],
                               qn.[correctAnswer],
                               qn.[correctExplanationEN], qn.[correctExplanationBM],
                               qn.[wrongExplanationEN], qn.[wrongExplanationBM],
                               qn.[questionImageUrl]
                        FROM dbo.[Question] qn
                        WHERE qn.[quizId]=@qid" + (isOwnPractice ? "" : " AND qn.[status]='Approved'") + @"
                        ORDER BY qn.[questionId]";

                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@qid", quizId);
                        using (var reader = cmd.ExecuteReader())
                        {
                            int questionNumber = 0;
                            while (reader.Read())
                            {
                                questionNumber++;
                                RenderDiscoverQuestionCard(reader, questionNumber, html);
                            }

                            if (questionNumber == 0)
                                html.Append("<div class='tc-manage-quiz-empty'><div style='font-size:2.5rem;opacity:.4;margin-bottom:.75rem;'>📝</div><div class='tc-manage-quiz-empty-title'>No questions in this quiz yet.</div></div>");
                        }
                    }

                    Response.Write(html.ToString());
                }
            }
            catch
            {
                Response.Write("<div class='tc-manage-quiz-empty'><div class='tc-manage-quiz-empty-title'>Error loading questions.</div></div>");
            }

            Response.End();
        }

        private void HandleResubmitRequest()
        {
            Response.Clear();
            Response.ContentType = "text/plain";

            string quizId = (Request.QueryString["quizId"] ?? "").Trim();
            string teacherId = Session["userId"]?.ToString() ?? "";

            if (string.IsNullOrEmpty(quizId) || string.IsNullOrEmpty(teacherId))
            {
                Response.StatusCode = 400;
                Response.Write("Invalid request.");
                Response.End();
                return;
            }

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var txn = conn.BeginTransaction())
                    {
                        try
                        {
                            // Reset Quiz status to Pending (only if owned by this teacher)
                            int quizRows;
                            using (var cmd = new SqlCommand("UPDATE dbo.[Quiz] SET [status]='Pending' WHERE [quizId]=@qid AND [createdByUserId]=@uid AND [quizType]='Practice'", conn, txn))
                            {
                                cmd.Parameters.AddWithValue("@qid", quizId);
                                cmd.Parameters.AddWithValue("@uid", teacherId);
                                quizRows = cmd.ExecuteNonQuery();
                            }

                            if (quizRows == 0)
                            {
                                txn.Rollback();
                                Response.StatusCode = 400;
                                Response.Write("Quiz not found or not eligible for resubmission.");
                                Response.End();
                                return;
                            }

                            // Reset ALL questions in this quiz to Pending
                            using (var cmd = new SqlCommand("UPDATE dbo.[Question] SET [status]='Pending' WHERE [quizId]=@qid", conn, txn))
                            {
                                cmd.Parameters.AddWithValue("@qid", quizId);
                                cmd.ExecuteNonQuery();
                            }

                            txn.Commit();
                            Response.Write("OK");
                        }
                        catch
                        {
                            txn.Rollback();
                            throw;
                        }
                    }
                }
            }
            catch
            {
                Response.StatusCode = 500;
                Response.Write("Error.");
            }

            Response.End();
        }

        private void HandlePQLevelsRequest()
        {
            Response.Clear();
            Response.ContentType = "application/json";

            try
            {
                var json = new System.Text.StringBuilder();
                json.Append("[");
                bool first = true;

                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("SELECT [levelId],[levelNameEN] FROM dbo.[Level] ORDER BY [levelId]", conn))
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            if (!first) json.Append(",");
                            first = false;
                            json.AppendFormat("{{\"id\":\"{0}\",\"name\":\"{1}\"}}",
                                HttpUtility.JavaScriptStringEncode(reader["levelId"].ToString()),
                                HttpUtility.JavaScriptStringEncode(reader["levelNameEN"].ToString()));
                        }
                    }
                }

                json.Append("]");
                Response.Write(json.ToString());
            }
            catch
            {
                Response.Write("[]");
            }

            Response.End();
        }

        private void HandlePQUnitsRequest()
        {
            Response.Clear();
            Response.ContentType = "application/json";

            string selectedLevelId = (Request.QueryString["levelId"] ?? "").Trim();
            if (string.IsNullOrEmpty(selectedLevelId))
            {
                Response.Write("[]");
                Response.End();
                return;
            }

            try
            {
                var json = new System.Text.StringBuilder();
                json.Append("[");
                bool first = true;

                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("SELECT [unitId],[unitNameEN] FROM dbo.[Unit] WHERE [levelId]=@lid ORDER BY [orderNo]", conn))
                    {
                        cmd.Parameters.AddWithValue("@lid", selectedLevelId);
                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                if (!first) json.Append(",");
                                first = false;
                                json.AppendFormat("{{\"id\":\"{0}\",\"name\":\"{1}\"}}",
                                    HttpUtility.JavaScriptStringEncode(reader["unitId"].ToString()),
                                    HttpUtility.JavaScriptStringEncode(reader["unitNameEN"].ToString()));
                            }
                        }
                    }
                }

                json.Append("]");
                Response.Write(json.ToString());
            }
            catch
            {
                Response.Write("[]");
            }

            Response.End();
        }

        private void HandlePQSubtopicsRequest()
        {
            Response.Clear();
            Response.ContentType = "application/json";

            string selectedUnitId = (Request.QueryString["unitId"] ?? "").Trim();
            if (string.IsNullOrEmpty(selectedUnitId))
            {
                Response.Write("[]");
                Response.End();
                return;
            }

            try
            {
                var json = new System.Text.StringBuilder();
                json.Append("[");
                bool first = true;

                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("SELECT [subtopicId],[subtopicTitleEN] FROM dbo.[Subtopic] WHERE [unitId]=@uid ORDER BY [orderNo]", conn))
                    {
                        cmd.Parameters.AddWithValue("@uid", selectedUnitId);
                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                if (!first) json.Append(",");
                                first = false;
                                json.AppendFormat("{{\"id\":\"{0}\",\"name\":\"{1}\"}}",
                                    HttpUtility.JavaScriptStringEncode(reader["subtopicId"].ToString()),
                                    HttpUtility.JavaScriptStringEncode(reader["subtopicTitleEN"].ToString()));
                            }
                        }
                    }
                }

                json.Append("]");
                Response.Write(json.ToString());
            }
            catch
            {
                Response.Write("[]");
            }

            Response.End();
        }

        #endregion

        #region Data Loading

        private void LoadForActiveTab()
        {
            SetTabUI();

            // Hide all content panels first
            pnlQuizzes.Visible = false;
            pnlEmpty.Visible = false;
            pnlDiscover.Visible = false;
            pnlDiscoverEmpty.Visible = false;
            pnlUnitLevel.Visible = false;
            pnlUnitLevelEmpty.Visible = false;

            if (hidActiveTab.Value == "discover")
                LoadDiscoverQuizzes();
            else if (hidActiveTab.Value == "unitlevel")
                LoadUnitLevelQuestions();
            else
                LoadQuizzes();
        }

        private void LoadQuizzes()
        {
            string teacherId = Session["userId"].ToString();
            string search = txtSearch.Text.Trim();
            string difficultyFilter = ddlDifficulty.SelectedValue;
            string statusFilter = ddlStatus.SelectedValue;
            string languageFilter = ddlLanguage.SelectedValue;

            string sql = @"
                SELECT q.[quizId],
                       ISNULL(q.[quizTitleEN], q.[quizTitleBM]) AS quizTitle,
                       q.[status], q.[language],
                       (SELECT COUNT(*) FROM dbo.[Question] WHERE [quizId] = q.[quizId]) AS questionCount,
                       ISNULL((SELECT TOP 1 [difficulty] FROM dbo.[Question] WHERE [quizId] = q.[quizId]
                               GROUP BY [difficulty] ORDER BY COUNT(*) DESC), 'Medium') AS difficulty
                FROM dbo.[Quiz] q
                WHERE q.[createdByUserId] = @userId
                  AND q.[quizType] = 'Practice'";

            if (!string.IsNullOrEmpty(search))
                sql += " AND (q.[quizTitleEN] LIKE @s OR q.[quizTitleBM] LIKE @s)";
            if (!string.IsNullOrEmpty(statusFilter))
                sql += " AND q.[status] = @status";
            if (!string.IsNullOrEmpty(languageFilter))
                sql += " AND q.[language] = @lang";

            sql += " ORDER BY q.[createdAt] DESC";

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", teacherId);
                    if (!string.IsNullOrEmpty(search)) cmd.Parameters.AddWithValue("@s", "%" + search + "%");
                    if (!string.IsNullOrEmpty(statusFilter)) cmd.Parameters.AddWithValue("@status", statusFilter);
                    if (!string.IsNullOrEmpty(languageFilter)) cmd.Parameters.AddWithValue("@lang", languageFilter);

                    var dt = new DataTable();
                    new SqlDataAdapter(cmd).Fill(dt);

                    // Filter by difficulty in memory (since it's an aggregated column)
                    if (!string.IsNullOrEmpty(difficultyFilter))
                    {
                        var rows = dt.Select("difficulty = '" + difficultyFilter.Replace("'", "''") + "'");
                        var filtered = dt.Clone();
                        foreach (var row in rows) filtered.ImportRow(row);
                        dt = filtered;
                    }

                    if (dt.Rows.Count > 0)
                    {
                        pnlQuizzes.Visible = true;
                        pnlEmpty.Visible = false;
                        pnlDiscover.Visible = false;
                        pnlDiscoverEmpty.Visible = false;
                        rptQuizzes.DataSource = dt;
                        rptQuizzes.DataBind();
                    }
                    else
                    {
                        pnlQuizzes.Visible = false;
                        pnlEmpty.Visible = true;
                        pnlDiscover.Visible = false;
                        pnlDiscoverEmpty.Visible = false;

                        litEmptyMsg.Text = GetEmptyMessage(statusFilter);
                    }
                }
            }
        }

        private void LoadDiscoverQuizzes()
        {
            string teacherId = Session["userId"].ToString();
            string search = txtSearch.Text.Trim();
            string languageFilter = ddlLanguage.SelectedValue;

            string sql = @"
                SELECT q.[quizId],
                       ISNULL(q.[quizTitleEN], q.[quizTitleBM]) AS quizTitle,
                       q.[quizType], q.[language],
                       COALESCE(t.[name], u.[username], 'Teacher') AS teacherName,
                       (SELECT COUNT(*) FROM dbo.[Question] WHERE [quizId]=q.[quizId]) AS questionCount
                FROM dbo.[Quiz] q
                INNER JOIN dbo.[User] u ON u.[userId]=q.[createdByUserId]
                LEFT JOIN dbo.[Teacher] t ON t.[userId]=q.[createdByUserId]
                WHERE q.[createdByUserId]<>@userId AND q.[status]='Approved'";

            if (!string.IsNullOrEmpty(search))
                sql += " AND (q.[quizTitleEN] LIKE @s OR q.[quizTitleBM] LIKE @s)";
            if (!string.IsNullOrEmpty(languageFilter))
                sql += " AND q.[language]=@lang";

            sql += " ORDER BY q.[createdAt] DESC";

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", teacherId);
                    if (!string.IsNullOrEmpty(search)) cmd.Parameters.AddWithValue("@s", "%" + search + "%");
                    if (!string.IsNullOrEmpty(languageFilter)) cmd.Parameters.AddWithValue("@lang", languageFilter);

                    var dt = new DataTable();
                    new SqlDataAdapter(cmd).Fill(dt);

                    pnlDiscover.Visible = dt.Rows.Count > 0;
                    pnlDiscoverEmpty.Visible = dt.Rows.Count == 0;
                    pnlQuizzes.Visible = false;
                    pnlEmpty.Visible = false;

                    if (dt.Rows.Count > 0)
                    {
                        rptDiscover.DataSource = dt;
                        rptDiscover.DataBind();
                    }
                }
            }
        }

        private void LoadUnitLevelQuestions()
        {
            string teacherId = Session["userId"].ToString();
            string search = txtSearch.Text.Trim();
            bool isBM = CurrentLanguage == "BM";

            string unitSql = @"
                SELECT q.[quizId],
                       COALESCE(u.[unitNameEN],'-') AS unitNameEN,
                       COALESCE(u.[unitNameBM], u.[unitNameEN],'-') AS unitNameBM,
                       u.[unitId], u.[orderNo],
                       COUNT(qn.[questionId]) AS yourCount,
                       SUM(CASE WHEN qn.[status]='Approved' THEN 1 ELSE 0 END) AS approvedCount,
                       SUM(CASE WHEN qn.[status]='Pending' OR (qn.[status] IS NULL AND qn.[questionId] IS NOT NULL) THEN 1 ELSE 0 END) AS pendingCount,
                       SUM(CASE WHEN qn.[status]='Rejected' THEN 1 ELSE 0 END) AS rejectedCount,
                       MAX(qn.[createdAt]) AS lastDate,
                       (SELECT COUNT(*) FROM dbo.[Question] qa WHERE qa.[quizId]=q.[quizId] AND qa.[status]='Approved') AS overallApproved
                FROM dbo.[Quiz] q
                LEFT JOIN dbo.[Unit] u ON u.[unitId]=q.[unitId]
                LEFT JOIN dbo.[Question] qn ON qn.[quizId]=q.[quizId] AND qn.[createdByUserId]=@userId
                WHERE q.[quizType]='Unit'";

            if (!string.IsNullOrEmpty(search))
                unitSql += " AND (u.[unitNameEN] LIKE @s OR u.[unitNameBM] LIKE @s OR q.[quizTitleEN] LIKE @s)";

            unitSql += " GROUP BY q.[quizId], u.[unitNameEN], u.[unitNameBM], u.[unitId], u.[orderNo] ORDER BY u.[unitId], u.[orderNo]";

            string levelSql = @"
                SELECT q.[quizId],
                       ISNULL(q.[quizTitleEN], q.[quizTitleBM]) AS quizName,
                       COALESCE(lv.[levelNameEN],'-') AS levelName,
                       COUNT(qn.[questionId]) AS yourCount,
                       SUM(CASE WHEN qn.[status]='Approved' THEN 1 ELSE 0 END) AS approvedCount,
                       SUM(CASE WHEN qn.[status]='Pending' OR (qn.[status] IS NULL AND qn.[questionId] IS NOT NULL) THEN 1 ELSE 0 END) AS pendingCount,
                       SUM(CASE WHEN qn.[status]='Rejected' THEN 1 ELSE 0 END) AS rejectedCount,
                       MAX(qn.[createdAt]) AS lastDate,
                       (SELECT COUNT(*) FROM dbo.[Question] qa WHERE qa.[quizId]=q.[quizId] AND qa.[status]='Approved') AS overallApproved
                FROM dbo.[Quiz] q
                LEFT JOIN dbo.[Level] lv ON lv.[levelId]=q.[levelId]
                LEFT JOIN dbo.[Question] qn ON qn.[quizId]=q.[quizId] AND qn.[createdByUserId]=@userId
                WHERE q.[quizType]='Level'";

            if (!string.IsNullOrEmpty(search))
                levelSql += " AND (lv.[levelNameEN] LIKE @s OR q.[quizTitleEN] LIKE @s OR q.[quizTitleBM] LIKE @s)";

            levelSql += " GROUP BY q.[quizId], q.[quizTitleEN], q.[quizTitleBM], lv.[levelNameEN] ORDER BY lv.[levelNameEN]";

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Render Unit quiz rows grouped by unit number
                var html = new System.Text.StringBuilder();
                using (var cmd = new SqlCommand(unitSql, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", teacherId);
                    if (!string.IsNullOrEmpty(search)) cmd.Parameters.AddWithValue("@s", "%" + search + "%");

                    using (var reader = cmd.ExecuteReader())
                    {
                        int currentGroup = -1;
                        while (reader.Read())
                        {
                            string unitId = reader["unitId"]?.ToString() ?? "";

                            // Derive group number from unitId: UN101 → 1, UN201 → 2, UN301 → 3
                            int groupNum = 0;
                            if (unitId.Length >= 4) int.TryParse(unitId.Substring(2, 1), out groupNum);

                            if (groupNum != currentGroup)
                            {
                                if (currentGroup > 0) html.Append("</div>");
                                currentGroup = groupNum;
                                html.AppendFormat("<div class=\"tc-manage-quiz-unit-group\"><div class=\"tc-manage-quiz-unit-group-hd\"><span class=\"tc-manage-quiz-unit-group-num\">{0}</span><span class=\"tc-manage-quiz-unit-group-label\">{1} {0}</span></div>",
                                    groupNum, T("Unit", "Unit"));
                            }

                            RenderUnitQuizCard(reader, isBM, html);
                        }

                        if (currentGroup > 0) html.Append("</div>");
                    }
                }

                litUnitGrouped.Text = html.ToString();

                // Load Level rows
                var levelRows = new List<object>();
                using (var cmd = new SqlCommand(levelSql, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", teacherId);
                    if (!string.IsNullOrEmpty(search)) cmd.Parameters.AddWithValue("@s", "%" + search + "%");

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            levelRows.Add(new
                            {
                                quizId = reader["quizId"].ToString(),
                                quizName = reader["quizName"].ToString(),
                                levelName = reader["levelName"].ToString(),
                                yourCount = Convert.ToInt32(reader["yourCount"]),
                                overallApproved = Convert.ToInt32(reader["overallApproved"]),
                                approvedCount = Convert.ToInt32(reader["approvedCount"]),
                                pendingCount = Convert.ToInt32(reader["pendingCount"]),
                                rejectedCount = Convert.ToInt32(reader["rejectedCount"])
                            });
                        }
                    }
                }

                rptLevelQs.DataSource = levelRows;
                rptLevelQs.DataBind();

                pnlUnitLevel.Visible = true;
                pnlUnitLevelEmpty.Visible = false;
            }
        }

        #endregion

        #region Database Operations

        private bool Authorize()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [status] FROM dbo.[Teacher] WHERE [userId]=@u", conn))
                {
                    cmd.Parameters.AddWithValue("@u", Session["userId"].ToString());
                    var val = cmd.ExecuteScalar();

                    if (val == null || val == DBNull.Value)
                    {
                        pnlDenied.Visible = true;
                        return false;
                    }

                    string teacherStatus = val.ToString();

                    if (teacherStatus.Equals("Certified", StringComparison.OrdinalIgnoreCase) ||
                        teacherStatus.Equals("Pending", StringComparison.OrdinalIgnoreCase))
                    {
                        pnlMain.Visible = true;
                        hidTeacherLicenseStatus.Value = teacherStatus.Equals("Certified", StringComparison.OrdinalIgnoreCase)
                            ? "Certified"
                            : "Pending";
                        return true;
                    }

                    pnlDenied.Visible = true;
                    return false;
                }
            }
        }

        private void LoadCreateUnits()
        {
            ddlCreateUnit.Items.Clear();
            ddlCreateUnit.Items.Add(new ListItem(T("— Select Unit —", "— Pilih Unit —"), ""));

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [unitId],[unitNameEN] FROM dbo.[Unit] ORDER BY [levelId],[orderNo]", conn))
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                        ddlCreateUnit.Items.Add(new ListItem(reader["unitNameEN"].ToString(), reader["unitId"].ToString()));
                }
            }
        }

        #endregion

        #region Helper Methods

        /// <summary>
        /// Bilingual text helper: returns BM text when language is BM, otherwise EN.
        /// </summary>
        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        private void SetupControls()
        {
            txtSearch.Attributes["placeholder"] = T("Search quizzes...", "Cari kuiz...");
            btnSearch.Text = T("Search", "Cari");
            btnConfirmDelete.Text = T("Delete", "Padam");
            btnContinue.Text = T("Continue", "Teruskan");

            ddlDifficulty.Items.Clear();
            ddlDifficulty.Items.Add(new ListItem(T("All Difficulty", "Semua Kesukaran"), ""));
            ddlDifficulty.Items.Add(new ListItem(T("Easy", "Mudah"), "Easy"));
            ddlDifficulty.Items.Add(new ListItem(T("Medium", "Sederhana"), "Medium"));
            ddlDifficulty.Items.Add(new ListItem(T("Hard", "Sukar"), "Hard"));

            ddlStatus.Items.Clear();
            ddlStatus.Items.Add(new ListItem(T("All Status", "Semua Status"), ""));
            ddlStatus.Items.Add(new ListItem(T("Pending", "Menunggu"), "Pending"));
            ddlStatus.Items.Add(new ListItem(T("Approved", "Diluluskan"), "Approved"));
            ddlStatus.Items.Add(new ListItem(T("Rejected", "Ditolak"), "Rejected"));

            ddlLanguage.Items.Clear();
            ddlLanguage.Items.Add(new ListItem(T("All Language", "Semua Bahasa"), ""));
            ddlLanguage.Items.Add(new ListItem("English", "EN"));
            ddlLanguage.Items.Add(new ListItem("Bahasa Melayu", "BM"));

            // Create modal - Quiz Type
            ddlCreateType.Items.Clear();
            ddlCreateType.Items.Add(new ListItem(T("— Select Quiz Type —", "— Pilih Jenis Kuiz —"), ""));
            ddlCreateType.Items.Add(new ListItem(T("Practice Quiz", "Kuiz Latihan"), "Practice"));
            ddlCreateType.Items.Add(new ListItem(T("Unit Quiz", "Kuiz Unit"), "Unit"));
            ddlCreateType.Items.Add(new ListItem(T("Level Quiz", "Kuiz Tahap"), "Level"));

            // Create modal - Level
            ddlCreateLevel.Items.Clear();
            ddlCreateLevel.Items.Add(new ListItem(T("— Select Level —", "— Pilih Tahap —"), ""));
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [levelId],[levelNameEN] FROM dbo.[Level] ORDER BY [levelId]", conn))
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                        ddlCreateLevel.Items.Add(new ListItem(reader["levelNameEN"].ToString(), reader["levelId"].ToString()));
                }
            }
        }

        private void SetTabUI()
        {
            string tab = hidActiveTab.Value;

            btnTabUnitLevel.CssClass = "tc-manage-quiz-tab" + (tab == "unitlevel" ? " active" : "");
            btnTabMine.CssClass = "tc-manage-quiz-tab" + (tab == "mine" ? " active" : "");
            btnTabDiscover.CssClass = "tc-manage-quiz-tab" + (tab == "discover" ? " active" : "");

            pnlCreateBtn.Visible = (tab == "mine");
            pnlCreateULBtn.Visible = (tab == "unitlevel");
            pnlStatusChips.Visible = (tab == "mine");
            ddlLanguage.Visible = (tab != "unitlevel");
        }

        private string GetEmptyMessage(string statusFilter)
        {
            switch (statusFilter)
            {
                case "Approved": return T("No approved Practice Quizzes found.", "Tiada Kuiz Latihan yang diluluskan ditemui.");
                case "Pending": return T("No pending Practice Quizzes found.", "Tiada Kuiz Latihan yang menunggu ditemui.");
                case "Rejected": return T("No rejected Practice Quizzes found.", "Tiada Kuiz Latihan yang ditolak ditemui.");
                default: return T("No Practice Quizzes found.", "Tiada Kuiz Latihan ditemui.");
            }
        }

        protected string GetStatusCss(string status)
        {
            if (string.IsNullOrEmpty(status)) return "tc-manage-quiz-badge-pending";
            string lower = status.ToLower();
            if (lower == "approved" || lower == "active") return "tc-manage-quiz-badge-approved";
            if (lower == "rejected") return "tc-manage-quiz-badge-rejected";
            return "tc-manage-quiz-badge-pending";
        }

        protected string GetStatusLabel(string status)
        {
            if (string.IsNullOrEmpty(status)) return T("Pending", "Menunggu");
            string lower = status.ToLower();
            if (lower == "approved" || lower == "active") return T("Approved", "Diluluskan");
            if (lower == "rejected") return T("Rejected", "Ditolak");
            return T("Pending", "Menunggu");
        }

        protected string GetDiffCss(string difficulty)
        {
            if (string.IsNullOrEmpty(difficulty)) return "tc-manage-quiz-diff-medium";
            string lower = difficulty.ToLower();
            if (lower == "easy") return "tc-manage-quiz-diff-easy";
            if (lower == "hard") return "tc-manage-quiz-diff-hard";
            return "tc-manage-quiz-diff-medium";
        }

        protected string GetTeacherInitial(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "T";
            return name.Trim()[0].ToString().ToUpper();
        }

        /// <summary>
        /// Renders the bilingual quiz header (title EN/BM + quiz type metadata).
        /// </summary>
        private void RenderQuizHeader(SqlConnection conn, string quizId, System.Text.StringBuilder html)
        {
            using (var cmd = new SqlCommand(@"SELECT q.[quizTitleEN], q.[quizTitleBM], q.[quizType],
                CASE WHEN q.[quizType]='Unit' THEN COALESCE(u.[unitNameEN],'-') ELSE COALESCE(lv.[levelNameEN],'-') END AS relatedName
                FROM dbo.[Quiz] q LEFT JOIN dbo.[Unit] u ON u.[unitId]=q.[unitId] LEFT JOIN dbo.[Level] lv ON lv.[levelId]=q.[levelId]
                WHERE q.[quizId]=@qid", conn))
            {
                cmd.Parameters.AddWithValue("@qid", quizId);
                using (var reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        string titleEN = reader["quizTitleEN"]?.ToString() ?? "";
                        string titleBM = reader["quizTitleBM"]?.ToString() ?? "";
                        string relatedName = reader["relatedName"]?.ToString() ?? "-";
                        string quizType = reader["quizType"]?.ToString() ?? "";

                        html.Append("<div class='tc-view-quiz-header'>");
                        html.Append("<div class='tc-view-quiz-header-titles'>");
                        html.AppendFormat("<div class='tc-view-quiz-header-col'><div class='tc-view-quiz-header-lang'>English</div><div class='tc-view-quiz-header-title'>{0}</div></div>", HttpUtility.HtmlEncode(titleEN));
                        html.AppendFormat("<div class='tc-view-quiz-header-col'><div class='tc-view-quiz-header-lang'>Bahasa Melayu</div><div class='tc-view-quiz-header-title'>{0}</div></div>", HttpUtility.HtmlEncode(titleBM));
                        html.Append("</div>");
                        html.AppendFormat("<div class='tc-view-quiz-header-meta'><i class='bi bi-diagram-3'></i> {0} · {1}</div>", HttpUtility.HtmlEncode(relatedName), HttpUtility.HtmlEncode(quizType));
                        html.Append("</div>");
                    }
                }
            }
        }

        /// <summary>
        /// Renders all questions submitted by the current teacher for a Unit/Level quiz.
        /// </summary>
        private void RenderTeacherQuestions(SqlConnection conn, string quizId, string teacherId, System.Text.StringBuilder html)
        {
            const string sql = @"SELECT qn.[questionTextEN], qn.[questionTextBM], qn.[questionType], qn.[difficulty], qn.[status],
                qn.[optionA_EN], qn.[optionA_BM], qn.[optionB_EN], qn.[optionB_BM],
                qn.[optionC_EN], qn.[optionC_BM], qn.[optionD_EN], qn.[optionD_BM],
                qn.[correctAnswer], qn.[correctExplanationEN], qn.[correctExplanationBM],
                qn.[wrongExplanationEN], qn.[wrongExplanationBM], qn.[questionImageUrl]
                FROM dbo.[Question] qn
                WHERE qn.[quizId]=@qid AND qn.[createdByUserId]=@uid
                ORDER BY qn.[questionId]";

            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@qid", quizId);
                cmd.Parameters.AddWithValue("@uid", teacherId);

                using (var reader = cmd.ExecuteReader())
                {
                    int questionNumber = 0;
                    while (reader.Read())
                    {
                        questionNumber++;

                        string questionTextEN = reader["questionTextEN"]?.ToString() ?? "";
                        string questionTextBM = reader["questionTextBM"]?.ToString() ?? "";
                        string questionType = reader["questionType"]?.ToString() ?? "MCQ";
                        string difficulty = reader["difficulty"]?.ToString() ?? "Medium";
                        string status = reader["status"]?.ToString() ?? "Pending";
                        string correctAnswer = reader["correctAnswer"]?.ToString() ?? "";
                        string imageUrl = reader["questionImageUrl"]?.ToString() ?? "";

                        string optionA_EN = reader["optionA_EN"]?.ToString() ?? "", optionA_BM = reader["optionA_BM"]?.ToString() ?? "";
                        string optionB_EN = reader["optionB_EN"]?.ToString() ?? "", optionB_BM = reader["optionB_BM"]?.ToString() ?? "";
                        string optionC_EN = reader["optionC_EN"]?.ToString() ?? "", optionC_BM = reader["optionC_BM"]?.ToString() ?? "";
                        string optionD_EN = reader["optionD_EN"]?.ToString() ?? "", optionD_BM = reader["optionD_BM"]?.ToString() ?? "";
                        string correctExplEN = reader["correctExplanationEN"]?.ToString() ?? "", correctExplBM = reader["correctExplanationBM"]?.ToString() ?? "";
                        string wrongExplEN = reader["wrongExplanationEN"]?.ToString() ?? "", wrongExplBM = reader["wrongExplanationBM"]?.ToString() ?? "";

                        string statusCss = status == "Approved" ? "tc-view-quiz-badge-green" : status == "Rejected" ? "tc-view-quiz-badge-red" : "tc-view-quiz-badge-amber";
                        string diffCss = difficulty.Equals("Easy", StringComparison.OrdinalIgnoreCase) ? "tc-view-quiz-badge-green" : difficulty.Equals("Hard", StringComparison.OrdinalIgnoreCase) ? "tc-view-quiz-badge-red" : "tc-view-quiz-badge-amber";
                        bool expanded = (questionNumber == 1);

                        // Card header
                        html.AppendFormat("<div class='tc-view-quiz-card{0}'>", expanded ? " tc-view-quiz-expanded" : "");
                        html.Append("<div class='tc-view-quiz-card-hd' onclick='toggleVQ(this)'>");
                        html.AppendFormat("<span class='tc-view-quiz-card-num'>Q{0}</span>", questionNumber);
                        html.AppendFormat("<span class='tc-view-quiz-badge {0}'>{1}</span>", diffCss, HttpUtility.HtmlEncode(difficulty));
                        html.AppendFormat("<span class='tc-view-quiz-badge {0} tc-view-quiz-status-badge'>{1}</span>", statusCss, HttpUtility.HtmlEncode(status));
                        html.Append("<i class='bi bi-chevron-down tc-view-quiz-chevron'></i>");
                        html.Append("</div>");

                        // Card body
                        html.Append("<div class='tc-view-quiz-card-body'>");
                        html.AppendFormat("<div class='tc-view-quiz-format-row'><span class='tc-view-quiz-format-label'>Question Format:</span> <span class='tc-view-quiz-format-val'>{0}</span></div>", HttpUtility.HtmlEncode(questionType));

                        // Bilingual columns
                        html.Append("<div class='tc-view-quiz-cols'>");

                        // English column
                        html.Append("<div class='tc-view-quiz-col'><div class='tc-view-quiz-col-hd'>English</div>");
                        html.AppendFormat("<div class='tc-view-quiz-question'>{0}</div>", HttpUtility.HtmlEncode(questionTextEN));
                        RenderOptions(html, optionA_EN, optionB_EN, optionC_EN, optionD_EN, correctAnswer, questionType, false);
                        if (!string.IsNullOrEmpty(correctExplEN)) html.AppendFormat("<div class='tc-view-quiz-expl tc-view-quiz-expl-correct'><div class='tc-view-quiz-expl-title'><i class='bi bi-check-circle-fill'></i> Correct Explanation</div><div>{0}</div></div>", HttpUtility.HtmlEncode(correctExplEN));
                        if (!string.IsNullOrEmpty(wrongExplEN)) html.AppendFormat("<div class='tc-view-quiz-expl tc-view-quiz-expl-wrong'><div class='tc-view-quiz-expl-title'><i class='bi bi-x-circle-fill'></i> Wrong Explanation</div><div>{0}</div></div>", HttpUtility.HtmlEncode(wrongExplEN));
                        html.Append("</div>");

                        // Bahasa Melayu column
                        html.Append("<div class='tc-view-quiz-col'><div class='tc-view-quiz-col-hd'>Bahasa Melayu</div>");
                        html.AppendFormat("<div class='tc-view-quiz-question'>{0}</div>", HttpUtility.HtmlEncode(questionTextBM));
                        RenderOptions(html, optionA_BM, optionB_BM, optionC_BM, optionD_BM, correctAnswer, questionType, true);
                        if (!string.IsNullOrEmpty(correctExplBM)) html.AppendFormat("<div class='tc-view-quiz-expl tc-view-quiz-expl-correct'><div class='tc-view-quiz-expl-title'><i class='bi bi-check-circle-fill'></i> Penjelasan Betul</div><div>{0}</div></div>", HttpUtility.HtmlEncode(correctExplBM));
                        if (!string.IsNullOrEmpty(wrongExplBM)) html.AppendFormat("<div class='tc-view-quiz-expl tc-view-quiz-expl-wrong'><div class='tc-view-quiz-expl-title'><i class='bi bi-x-circle-fill'></i> Penjelasan Salah</div><div>{0}</div></div>", HttpUtility.HtmlEncode(wrongExplBM));
                        html.Append("</div>");

                        html.Append("</div>"); // close tc-view-quiz-cols

                        // Question image link
                        if (!string.IsNullOrWhiteSpace(imageUrl))
                        {
                            string fileName = System.IO.Path.GetFileName(imageUrl);
                            string resolvedPath = ResolveUrl("~/Images/Question/" + fileName);
                            html.AppendFormat("<div class='tc-view-quiz-img-row'><i class='bi bi-image'></i> <a href='#' class='tc-view-quiz-img-link' onclick='openImgPreview(\"{0}\");return false;'>{1}</a></div>", HttpUtility.HtmlEncode(resolvedPath), HttpUtility.HtmlEncode(fileName));
                        }

                        html.Append("</div>"); // close tc-view-quiz-card-body
                        html.Append("</div>"); // close tc-view-quiz-card
                    }

                    if (questionNumber == 0)
                        html.Append("<div class='tc-manage-quiz-empty'>" + T("No questions have been submitted by you for this quiz yet.", "Anda belum menghantar sebarang soalan untuk kuiz ini.") + "</div>");
                }
            }
        }

        /// <summary>
        /// Renders a single question card for the Discover Quiz view (no status badge shown).
        /// </summary>
        private void RenderDiscoverQuestionCard(SqlDataReader reader, int questionNumber, System.Text.StringBuilder html)
        {
            string questionTextEN = reader["questionTextEN"]?.ToString() ?? "";
            string questionTextBM = reader["questionTextBM"]?.ToString() ?? "";
            string questionType = reader["questionType"]?.ToString() ?? "MCQ";
            string difficulty = reader["difficulty"]?.ToString() ?? "Medium";
            string correctAnswer = reader["correctAnswer"]?.ToString() ?? "";
            string imageUrl = reader["questionImageUrl"]?.ToString() ?? "";

            string optionA_EN = reader["optionA_EN"]?.ToString() ?? "", optionA_BM = reader["optionA_BM"]?.ToString() ?? "";
            string optionB_EN = reader["optionB_EN"]?.ToString() ?? "", optionB_BM = reader["optionB_BM"]?.ToString() ?? "";
            string optionC_EN = reader["optionC_EN"]?.ToString() ?? "", optionC_BM = reader["optionC_BM"]?.ToString() ?? "";
            string optionD_EN = reader["optionD_EN"]?.ToString() ?? "", optionD_BM = reader["optionD_BM"]?.ToString() ?? "";
            string correctExplEN = reader["correctExplanationEN"]?.ToString() ?? "", correctExplBM = reader["correctExplanationBM"]?.ToString() ?? "";
            string wrongExplEN = reader["wrongExplanationEN"]?.ToString() ?? "", wrongExplBM = reader["wrongExplanationBM"]?.ToString() ?? "";

            string diffCss = difficulty.Equals("Easy", StringComparison.OrdinalIgnoreCase) ? "tc-view-quiz-badge-green" : difficulty.Equals("Hard", StringComparison.OrdinalIgnoreCase) ? "tc-view-quiz-badge-red" : "tc-view-quiz-badge-amber";
            bool expanded = (questionNumber == 1);

            // Card header (no status badge in discover view)
            html.AppendFormat("<div class='tc-view-quiz-card{0}'>", expanded ? " tc-view-quiz-expanded" : "");
            html.Append("<div class='tc-view-quiz-card-hd' onclick='toggleVQ(this)'>");
            html.AppendFormat("<span class='tc-view-quiz-card-num'>Q{0}</span>", questionNumber);
            html.AppendFormat("<span class='tc-view-quiz-badge {0}'>{1}</span>", diffCss, HttpUtility.HtmlEncode(difficulty));
            html.Append("<i class='bi bi-chevron-down tc-view-quiz-chevron'></i>");
            html.Append("</div>");

            // Card body
            html.Append("<div class='tc-view-quiz-card-body'>");
            html.AppendFormat("<div class='tc-view-quiz-format-row'><span class='tc-view-quiz-format-label'>Question Format:</span> <span class='tc-view-quiz-format-val'>{0}</span></div>", HttpUtility.HtmlEncode(questionType));
            html.Append("<div class='tc-view-quiz-cols'>");

            // English column
            html.Append("<div class='tc-view-quiz-col'><div class='tc-view-quiz-col-hd'>English</div>");
            html.AppendFormat("<div class='tc-view-quiz-question'>{0}</div>", HttpUtility.HtmlEncode(questionTextEN));
            RenderOptions(html, optionA_EN, optionB_EN, optionC_EN, optionD_EN, correctAnswer, questionType, false);
            if (!string.IsNullOrEmpty(correctExplEN)) html.AppendFormat("<div class='tc-view-quiz-expl tc-view-quiz-expl-correct'><div class='tc-view-quiz-expl-title'><i class='bi bi-check-circle-fill'></i> Correct Explanation</div><div>{0}</div></div>", HttpUtility.HtmlEncode(correctExplEN));
            if (!string.IsNullOrEmpty(wrongExplEN)) html.AppendFormat("<div class='tc-view-quiz-expl tc-view-quiz-expl-wrong'><div class='tc-view-quiz-expl-title'><i class='bi bi-x-circle-fill'></i> Wrong Explanation</div><div>{0}</div></div>", HttpUtility.HtmlEncode(wrongExplEN));
            html.Append("</div>");

            // Bahasa Melayu column
            html.Append("<div class='tc-view-quiz-col'><div class='tc-view-quiz-col-hd'>Bahasa Melayu</div>");
            html.AppendFormat("<div class='tc-view-quiz-question'>{0}</div>", HttpUtility.HtmlEncode(questionTextBM));
            RenderOptions(html, optionA_BM, optionB_BM, optionC_BM, optionD_BM, correctAnswer, questionType, true);
            if (!string.IsNullOrEmpty(correctExplBM)) html.AppendFormat("<div class='tc-view-quiz-expl tc-view-quiz-expl-correct'><div class='tc-view-quiz-expl-title'><i class='bi bi-check-circle-fill'></i> Penjelasan Betul</div><div>{0}</div></div>", HttpUtility.HtmlEncode(correctExplBM));
            if (!string.IsNullOrEmpty(wrongExplBM)) html.AppendFormat("<div class='tc-view-quiz-expl tc-view-quiz-expl-wrong'><div class='tc-view-quiz-expl-title'><i class='bi bi-x-circle-fill'></i> Penjelasan Salah</div><div>{0}</div></div>", HttpUtility.HtmlEncode(wrongExplBM));
            html.Append("</div>");

            html.Append("</div>"); // close tc-view-quiz-cols

            // Question image link
            if (!string.IsNullOrWhiteSpace(imageUrl))
            {
                string fileName = System.IO.Path.GetFileName(imageUrl);
                string resolvedPath = ResolveUrl("~/Images/Question/" + fileName);
                html.AppendFormat("<div class='tc-view-quiz-img-row'><i class='bi bi-image'></i> <a href='#' class='tc-view-quiz-img-link' onclick='openImgPreview(\"{0}\");return false;'>{1}</a></div>", HttpUtility.HtmlEncode(resolvedPath), HttpUtility.HtmlEncode(fileName));
            }

            html.Append("</div>"); // close tc-view-quiz-card-body
            html.Append("</div>"); // close tc-view-quiz-card
        }

        /// <summary>
        /// Renders MCQ options or Drag &amp; Drop ordering depending on question type.
        /// </summary>
        private void RenderOptions(System.Text.StringBuilder html, string optA, string optB, string optC, string optD, string correctAnswer, string questionType, bool isBM)
        {
            string[] options = { optA, optB, optC, optD };

            if (IsDragDropType(questionType))
            {
                RenderDragDropOptions(html, options, correctAnswer, isBM);
            }
            else
            {
                RenderMCQOptions(html, options, correctAnswer);
            }
        }

        private bool IsDragDropType(string questionType)
        {
            return questionType.Equals("Drag & Drop", StringComparison.OrdinalIgnoreCase)
                || questionType.Equals("DragDrop", StringComparison.OrdinalIgnoreCase)
                || questionType.Equals("Drag and Drop", StringComparison.OrdinalIgnoreCase);
        }

        private void RenderMCQOptions(System.Text.StringBuilder html, string[] options, string correctAnswer)
        {
            html.Append("<div class='tc-view-quiz-options'>");
            string[] labels = { "A", "B", "C", "D" };

            for (int i = 0; i < 4; i++)
            {
                if (string.IsNullOrEmpty(options[i])) continue;

                bool isCorrect = !string.IsNullOrEmpty(correctAnswer) && correctAnswer.IndexOf(labels[i], StringComparison.OrdinalIgnoreCase) >= 0;
                html.AppendFormat("<div class='tc-view-quiz-opt{0}'><span class='tc-view-quiz-opt-label'>{1}</span><span class='tc-view-quiz-opt-text'>{2}</span>{3}</div>",
                    isCorrect ? " tc-view-quiz-opt-correct" : "",
                    labels[i],
                    HttpUtility.HtmlEncode(options[i]),
                    isCorrect ? "<i class='bi bi-check-circle-fill'></i>" : "");
            }

            html.Append("</div>");
        }

        private void RenderDragDropOptions(System.Text.StringBuilder html, string[] options, string correctAnswer, bool isBM)
        {
            // Available Options as neutral boxes
            html.AppendFormat("<div class='tc-view-quiz-dd-section'><div class='tc-view-quiz-dd-label'>{0}</div><div class='tc-view-quiz-dd-items'>", isBM ? "Pilihan Tersedia" : "Available Options");
            for (int i = 0; i < 4; i++)
            {
                if (!string.IsNullOrEmpty(options[i]))
                    html.AppendFormat("<div class='tc-view-quiz-dd-item'>{0}</div>", HttpUtility.HtmlEncode(options[i]));
            }
            html.Append("</div></div>");

            // Correct Order - split EN/BM halves from comma-separated correctAnswer
            if (!string.IsNullOrEmpty(correctAnswer))
            {
                string[] allParts = correctAnswer.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                for (int i = 0; i < allParts.Length; i++) allParts[i] = allParts[i].Trim();

                var cleaned = new List<string>();
                foreach (string part in allParts)
                {
                    if (!string.IsNullOrEmpty(part)) cleaned.Add(part);
                }

                string[] orderItems;
                int half = cleaned.Count / 2;

                if (cleaned.Count >= 2 && cleaned.Count % 2 == 0)
                {
                    // Even count: first half = EN order, second half = BM order
                    orderItems = isBM
                        ? cleaned.GetRange(half, half).ToArray()
                        : cleaned.GetRange(0, half).ToArray();
                }
                else if (cleaned.Count == 1)
                {
                    // Single value: show for both languages
                    orderItems = cleaned.ToArray();
                }
                else
                {
                    // Odd count fallback: EN gets first ceil(n/2), BM gets the rest
                    int enCount = (cleaned.Count + 1) / 2;
                    orderItems = isBM
                        ? cleaned.GetRange(enCount, cleaned.Count - enCount).ToArray()
                        : cleaned.GetRange(0, enCount).ToArray();
                }

                if (orderItems.Length > 0)
                {
                    html.AppendFormat("<div class='tc-view-quiz-dd-order'><div class='tc-view-quiz-dd-label'>{0}</div><ol class='tc-view-quiz-dd-order-list'>", isBM ? "Susunan Betul" : "Correct Order");
                    foreach (string item in orderItems)
                        html.AppendFormat("<li>{0}</li>", HttpUtility.HtmlEncode(item));
                    html.Append("</ol></div>");
                }
            }
        }

        /// <summary>
        /// Renders a single Unit quiz card row in the Unit/Level tab.
        /// </summary>
        private void RenderUnitQuizCard(SqlDataReader reader, bool isBM, System.Text.StringBuilder html)
        {
            string unitName = isBM ? reader["unitNameBM"].ToString() : reader["unitNameEN"].ToString();
            string quizId = reader["quizId"].ToString();
            int yourCount = Convert.ToInt32(reader["yourCount"]);
            int overallApproved = Convert.ToInt32(reader["overallApproved"]);
            int approvedCount = Convert.ToInt32(reader["approvedCount"]);
            int pendingCount = Convert.ToInt32(reader["pendingCount"]);
            int rejectedCount = Convert.ToInt32(reader["rejectedCount"]);

            string overallTip = T("Total approved questions available for this quiz from all teachers.", "Jumlah soalan yang diluluskan tersedia untuk kuiz ini daripada semua guru.");
            string yourTip = T("Total questions you have submitted for this quiz, including approved, pending and rejected questions.", "Jumlah soalan yang telah anda hantar untuk kuiz ini, termasuk yang diluluskan, menunggu dan ditolak.");

            html.Append("<div class=\"tc-manage-quiz-ulq-card\">");

            // Left side: icon + unit name
            html.AppendFormat("<div class=\"tc-manage-quiz-ulq-left\"><div class=\"tc-manage-quiz-ulq-icon tc-manage-quiz-ulq-icon-unit\"><i class=\"bi bi-layers-fill\"></i></div><div class=\"tc-manage-quiz-ulq-info\"><div class=\"tc-manage-quiz-ulq-title\">{0}</div></div></div>", HttpUtility.HtmlEncode(unitName));

            // Stats columns
            html.Append("<div class=\"tc-manage-quiz-ulq-stats\">");
            html.AppendFormat("<div class=\"tc-manage-quiz-ulq-col tc-manage-quiz-ulq-col--overall\"><div class=\"tc-manage-quiz-ulq-col-label\">{0} <span class=\"tc-manage-quiz-info-icon\" tabindex=\"0\" data-tip=\"{2}\"><i class=\"bi bi-info-circle\"></i></span></div><div class=\"tc-manage-quiz-ulq-col-val tc-manage-quiz-val-overall\">{1}</div></div>", T("Overall Approved", "Diluluskan Semua"), overallApproved, HttpUtility.HtmlEncode(overallTip));
            html.AppendFormat("<div class=\"tc-manage-quiz-ulq-col tc-manage-quiz-ulq-col--submitted\"><div class=\"tc-manage-quiz-ulq-col-label\">{0} <span class=\"tc-manage-quiz-info-icon\" tabindex=\"0\" data-tip=\"{2}\"><i class=\"bi bi-info-circle\"></i></span></div><div class=\"tc-manage-quiz-ulq-col-val\">{1}</div></div>", T("Your Submitted", "Hantar Anda"), yourCount, HttpUtility.HtmlEncode(yourTip));
            html.AppendFormat("<div class=\"tc-manage-quiz-ulq-col tc-manage-quiz-ulq-col--approved\"><div class=\"tc-manage-quiz-ulq-col-label\">{0}</div><div class=\"tc-manage-quiz-ulq-col-val tc-manage-quiz-val-approved\">{1}</div></div>", T("Approved", "Diluluskan"), approvedCount);
            html.AppendFormat("<div class=\"tc-manage-quiz-ulq-col tc-manage-quiz-ulq-col--pending\"><div class=\"tc-manage-quiz-ulq-col-label\">{0}</div><div class=\"tc-manage-quiz-ulq-col-val tc-manage-quiz-val-pending\">{1}</div></div>", T("Pending", "Menunggu"), pendingCount);
            html.AppendFormat("<div class=\"tc-manage-quiz-ulq-col tc-manage-quiz-ulq-col--rejected\"><div class=\"tc-manage-quiz-ulq-col-label\">{0}</div><div class=\"tc-manage-quiz-ulq-col-val tc-manage-quiz-val-rejected\">{1}</div></div>", T("Rejected", "Ditolak"), rejectedCount);
            html.Append("</div>");

            // Action buttons
            html.AppendFormat("<div class=\"tc-manage-quiz-ulq-btn-col\"><a href=\"#\" class=\"tc-manage-quiz-ulq-btn tc-manage-quiz-ulq-btn-add\" onclick='openSubtopicModal(\"{0}\");return false;'><i class=\"bi bi-plus-lg\"></i> {1}</a><button type=\"button\" class=\"tc-manage-quiz-ulq-btn\" onclick='openULModal(\"{0}\")'><i class=\"bi bi-eye\"></i> {2}</button></div>", HttpUtility.HtmlEncode(quizId), T("Add Questions", "Tambah Soalan"), T("View Questions", "Lihat Soalan"));
            html.Append("</div>");
        }

        #endregion
    }
}
