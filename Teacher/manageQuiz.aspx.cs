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
        protected string CurrentLanguage
        {
            get { string l = Session["preferredLanguage"] as string; return string.IsNullOrEmpty(l) ? "EN" : l; }
        }
        protected string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }

        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"]?.ToString() != "Teacher")
            { Response.Redirect("~/Login.aspx", false); Context.ApplicationInstance.CompleteRequest(); return; }

            var master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                if (!Authorize()) return;
                SetupControls();
                LoadQuizzes();
            }
        }

        private bool Authorize()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [status] FROM dbo.[Teacher] WHERE [userId]=@u", conn))
                {
                    cmd.Parameters.AddWithValue("@u", Session["userId"].ToString());
                    var val = cmd.ExecuteScalar();
                    if (val == null || val == DBNull.Value || !val.ToString().Equals("Certified", StringComparison.OrdinalIgnoreCase))
                    { pnlDenied.Visible = true; return false; }
                }
            }
            pnlMain.Visible = true;
            return true;
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
            ddlLanguage.Items.Add(new ListItem(T("Both", "Kedua-dua"), "BOTH"));

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
                using (var r = cmd.ExecuteReader()) while (r.Read()) ddlCreateLevel.Items.Add(new ListItem(r["levelNameEN"].ToString(), r["levelId"].ToString()));
            }
        }

        private void LoadQuizzes()
        {
            string userId = Session["userId"].ToString();
            string search = txtSearch.Text.Trim();
            string diff = ddlDifficulty.SelectedValue;
            string status = ddlStatus.SelectedValue;
            string lang = ddlLanguage.SelectedValue;

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
            if (!string.IsNullOrEmpty(status))
                sql += " AND q.[status] = @status";
            if (!string.IsNullOrEmpty(lang))
                sql += " AND q.[language] = @lang";

            sql += " ORDER BY q.[createdAt] DESC";

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    if (!string.IsNullOrEmpty(search)) cmd.Parameters.AddWithValue("@s", "%" + search + "%");
                    if (!string.IsNullOrEmpty(status)) cmd.Parameters.AddWithValue("@status", status);
                    if (!string.IsNullOrEmpty(lang)) cmd.Parameters.AddWithValue("@lang", lang);

                    var dt = new DataTable();
                    new SqlDataAdapter(cmd).Fill(dt);

                    // Filter by difficulty in memory (since it's aggregated)
                    if (!string.IsNullOrEmpty(diff))
                    {
                        var rows = dt.Select("difficulty = '" + diff.Replace("'", "''") + "'");
                        var filtered = dt.Clone();
                        foreach (var r in rows) filtered.ImportRow(r);
                        dt = filtered;
                    }

                    if (dt.Rows.Count > 0)
                    {
                        pnlQuizzes.Visible = true; pnlEmpty.Visible = false;
                        rptQuizzes.DataSource = dt; rptQuizzes.DataBind();
                    }
                    else
                    {
                        pnlQuizzes.Visible = false; pnlEmpty.Visible = true;
                    }
                }
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e) { LoadQuizzes(); }
        protected void ddlFilter_Changed(object sender, EventArgs e) { LoadQuizzes(); }

        protected void btnConfirmDelete_Click(object sender, EventArgs e)
        {
            string quizId = hidDeleteId.Value;
            string userId = Session["userId"].ToString();
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    // Delete questions first (FK constraint)
                    using (var cmd = new SqlCommand("DELETE FROM dbo.[Question] WHERE [quizId]=@qid AND [createdByUserId]=@uid", conn))
                    { cmd.Parameters.AddWithValue("@qid", quizId); cmd.Parameters.AddWithValue("@uid", userId); cmd.ExecuteNonQuery(); }
                    // Delete quiz
                    using (var cmd = new SqlCommand("DELETE FROM dbo.[Quiz] WHERE [quizId]=@qid AND [createdByUserId]=@uid", conn))
                    { cmd.Parameters.AddWithValue("@qid", quizId); cmd.Parameters.AddWithValue("@uid", userId); cmd.ExecuteNonQuery(); }
                }
                hidToast.Value = T("Quiz deleted successfully.", "Kuiz berjaya dipadam.");
            }
            catch { hidToast.Value = T("Could not delete quiz.", "Tidak dapat memadam kuiz."); }
            LoadQuizzes();
        }

        // ── Create Modal Events ─────────────────────────────────────
        protected void ddlCreateType_Changed(object sender, EventArgs e)
        {
            string t = ddlCreateType.SelectedValue;
            pnlCreateLevel.Visible = (t == "Level");
            pnlCreateUnit.Visible = (t == "Unit");
            pnlCreateSubtopic.Visible = (t == "Practice" || t == "Unit" || t == "Level");
            pnlCreateLang.Visible = (t == "Practice");

            // Load units for Unit quiz type
            if (t == "Unit") LoadCreateUnits();
            // Load subtopics based on type
            ddlCreateSubtopic.Items.Clear();
            ddlCreateSubtopic.Items.Add(new ListItem(T("— Select Subtopic —", "— Pilih Subtopik —"), ""));
            ddlCreateUnit.Items.Clear();
            ddlCreateUnit.Items.Add(new ListItem(T("— Select Unit —", "— Pilih Unit —"), ""));
            if (t == "Unit") LoadCreateUnits();

            hidShowCreateModal.Value = "1";
        }

        protected void ddlCreateLevel_Changed(object sender, EventArgs e)
        {
            // For Level quiz - load subtopics for the entire level
            ddlCreateSubtopic.Items.Clear();
            ddlCreateSubtopic.Items.Add(new ListItem(T("— Select Subtopic —", "— Pilih Subtopik —"), ""));
            string levelId = ddlCreateLevel.SelectedValue;
            if (!string.IsNullOrEmpty(levelId))
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    const string sql = @"SELECT st.[subtopicId], st.[subtopicTitleEN] FROM dbo.[Subtopic] st
                        INNER JOIN dbo.[Unit] u ON u.[unitId] = st.[unitId] WHERE u.[levelId] = @lid ORDER BY u.[orderNo], st.[orderNo]";
                    using (var cmd = new SqlCommand(sql, conn))
                    { cmd.Parameters.AddWithValue("@lid", levelId); using (var r = cmd.ExecuteReader()) while (r.Read()) ddlCreateSubtopic.Items.Add(new ListItem(r["subtopicTitleEN"].ToString(), r["subtopicId"].ToString())); }
                }
            }
            hidShowCreateModal.Value = "1";
        }

        protected void ddlCreateUnit_Changed(object sender, EventArgs e)
        {
            ddlCreateSubtopic.Items.Clear();
            ddlCreateSubtopic.Items.Add(new ListItem(T("— Select Subtopic —", "— Pilih Subtopik —"), ""));
            string unitId = ddlCreateUnit.SelectedValue;
            if (!string.IsNullOrEmpty(unitId))
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("SELECT [subtopicId],[subtopicTitleEN] FROM dbo.[Subtopic] WHERE [unitId]=@u ORDER BY [orderNo]", conn))
                    { cmd.Parameters.AddWithValue("@u", unitId); using (var r = cmd.ExecuteReader()) while (r.Read()) ddlCreateSubtopic.Items.Add(new ListItem(r["subtopicTitleEN"].ToString(), r["subtopicId"].ToString())); }
                }
            }
            hidShowCreateModal.Value = "1";
        }

        private void LoadCreateUnits()
        {
            ddlCreateUnit.Items.Clear();
            ddlCreateUnit.Items.Add(new ListItem(T("— Select Unit —", "— Pilih Unit —"), ""));
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [unitId],[unitNameEN] FROM dbo.[Unit] ORDER BY [levelId],[orderNo]", conn))
                using (var r = cmd.ExecuteReader()) while (r.Read()) ddlCreateUnit.Items.Add(new ListItem(r["unitNameEN"].ToString(), r["unitId"].ToString()));
            }
        }

        protected void btnContinue_Click(object sender, EventArgs e)
        {
            string quizType = ddlCreateType.SelectedValue;
            string subtopicId = ddlCreateSubtopic.SelectedValue;

            if (string.IsNullOrEmpty(quizType) || string.IsNullOrEmpty(subtopicId))
            { hidShowCreateModal.Value = "1"; return; }

            if (quizType == "Practice")
            {
                string lang = ddlCreateLang.SelectedValue;
                if (string.IsNullOrEmpty(lang)) { hidShowCreateModal.Value = "1"; return; }
                Response.Redirect("~/Teacher/createPracticeQuiz.aspx?language=" + lang + "&subtopicId=" + subtopicId, false);
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

        // ── Helpers ──────────────────────────────────────────────────
        protected string GetStatusCss(string s)
        {
            if (string.IsNullOrEmpty(s)) return "mq-badge-pending";
            string l = s.ToLower();
            if (l == "approved" || l == "active") return "mq-badge-approved";
            if (l == "rejected") return "mq-badge-rejected";
            return "mq-badge-pending";
        }

        protected string GetStatusLabel(string s)
        {
            if (string.IsNullOrEmpty(s)) return T("Pending", "Menunggu");
            string l = s.ToLower();
            if (l == "approved" || l == "active") return T("Approved", "Diluluskan");
            if (l == "rejected") return T("Rejected", "Ditolak");
            return T("Pending", "Menunggu");
        }

        protected string GetDiffCss(string d)
        {
            if (string.IsNullOrEmpty(d)) return "mq-diff-medium";
            string l = d.ToLower();
            if (l == "easy") return "mq-diff-easy";
            if (l == "hard") return "mq-diff-hard";
            return "mq-diff-medium";
        }
    }
}
