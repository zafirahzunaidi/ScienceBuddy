using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

// Admin QuestionBank - Code Behind
namespace ScienceBuddy.Admin
{
    public partial class QuestionBank : Page
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
            if (Request.QueryString["handler"] == "GetQuestion" && Request.HttpMethod == "POST")
            { _isAjax = true; HandleGetQuestion(); return; }

            if (Request.QueryString["handler"] == "SaveQuestion" && Request.HttpMethod == "POST")
            { _isAjax = true; HandleSaveQuestion(); return; }

            if (Request.QueryString["handler"] == "DisableQuestion" && Request.HttpMethod == "POST")
            { _isAjax = true; HandleDisable(); return; }

            if (Session["userId"] == null || Session["role"]?.ToString() != "Admin")
            { Response.Redirect("~/Login.aspx", false); return; }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                SetUserInfo();
                LoadStats();
                LoadQuestions("", "", "", "");
                txtSearch.Attributes["placeholder"] = T("Search question, teacher, subtopic...", "Cari soalan, guru, subtopik...");
            }
        }

        // --- Data Loading ---

        private void SetUserInfo()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [username] FROM dbo.[User] WHERE [userId]=@u", conn))
                {
                    cmd.Parameters.AddWithValue("@u", Session["userId"].ToString());
                    var result = cmd.ExecuteScalar();
                    string name = result?.ToString() ?? "Admin";
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
                litTotal.Text = SC(conn, "SELECT COUNT(*) FROM dbo.[Question]").ToString();
                litMCQ.Text = SC(conn, "SELECT COUNT(*) FROM dbo.[Question] WHERE [questionType]='MCQ'").ToString();
                litTF.Text = SC(conn, "SELECT COUNT(*) FROM dbo.[Question] WHERE [questionType]='True/False'").ToString();

                int total = int.Parse(litTotal.Text);
                int mcq = int.Parse(litMCQ.Text);
                int tf = int.Parse(litTF.Text);
                litOther.Text = (total - mcq - tf).ToString();
            }
        }

        private void LoadQuestions(string search, string type, string diff, string status)
        {
            var list = new List<object>();

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                string sql = @"SELECT q.[questionId],q.[questionTextEN],q.[questionTextBM],q.[questionType],
                    q.[difficulty],q.[status],q.[createdAt],q.[correctAnswer],
                    q.[optionA_EN],q.[optionA_BM],q.[optionB_EN],q.[optionB_BM],
                    q.[optionC_EN],q.[optionC_BM],q.[optionD_EN],q.[optionD_BM],
                    q.[correctExplanationEN],q.[correctExplanationBM],
                    ISNULL(t.[name],u.[username]) AS teacherName,
                    ISNULL(st.[subtopicTitleEN],'') AS subEN,ISNULL(st.[subtopicTitleBM],'') AS subBM
                    FROM dbo.[Question] q
                    LEFT JOIN dbo.[User] u ON u.[userId]=q.[createdByUserId]
                    LEFT JOIN dbo.[Teacher] t ON t.[userId]=q.[createdByUserId]
                    LEFT JOIN dbo.[Subtopic] st ON st.[subtopicId]=q.[subtopicId]
                    WHERE 1=1";

                if (!string.IsNullOrWhiteSpace(type)) sql += " AND q.[questionType]=@tp";
                if (!string.IsNullOrWhiteSpace(diff)) sql += " AND q.[difficulty]=@df";
                if (!string.IsNullOrWhiteSpace(status)) sql += " AND q.[status]=@st";
                if (!string.IsNullOrWhiteSpace(search))
                    sql += " AND (q.[questionTextEN] LIKE @s OR q.[questionTextBM] LIKE @s OR ISNULL(t.[name],'') LIKE @s OR u.[username] LIKE @s OR q.[questionId] LIKE @s OR ISNULL(st.[subtopicTitleEN],'') LIKE @s\r\nOR ISNULL(st.[subtopicTitleBM],'') LIKE @s)";
                sql += " ORDER BY q.[createdAt] DESC";

                using (var cmd = new SqlCommand(sql, conn))
                {
                    if (!string.IsNullOrWhiteSpace(type)) cmd.Parameters.AddWithValue("@tp", type);
                    if (!string.IsNullOrWhiteSpace(diff)) cmd.Parameters.AddWithValue("@df", diff);
                    if (!string.IsNullOrWhiteSpace(status)) cmd.Parameters.AddWithValue("@st", status);
                    if (!string.IsNullOrWhiteSpace(search)) cmd.Parameters.AddWithValue("@s", "%" + search + "%");

                    using (var da = new SqlDataAdapter(cmd))
                    {
                        var dt = new DataTable();
                        da.Fill(dt);

                        foreach (DataRow r in dt.Rows)
                        {
                            string textEN = NS(r, "questionTextEN");
                            string textBM = NS(r, "questionTextBM");
                            string text = CurrentLanguage == "BM" && !string.IsNullOrEmpty(textBM) ? textBM : textEN;
                            if (string.IsNullOrEmpty(text)) text = !string.IsNullOrEmpty(textEN) ? textEN : "(No text)";

                            string sub = CurrentLanguage == "BM" && !string.IsNullOrEmpty(NS(r, "subBM")) ? NS(r, "subBM") : NS(r, "subEN");
                            string optA = CurrentLanguage == "BM" && !string.IsNullOrEmpty(NS(r, "optionA_BM")) ? NS(r, "optionA_BM") : NS(r, "optionA_EN");
                            string optB = CurrentLanguage == "BM" && !string.IsNullOrEmpty(NS(r, "optionB_BM")) ? NS(r, "optionB_BM") : NS(r, "optionB_EN");
                            string optC = CurrentLanguage == "BM" && !string.IsNullOrEmpty(NS(r, "optionC_BM")) ? NS(r, "optionC_BM") : NS(r, "optionC_EN");
                            string optD = CurrentLanguage == "BM" && !string.IsNullOrEmpty(NS(r, "optionD_BM")) ? NS(r, "optionD_BM") : NS(r, "optionD_EN");
                            string expl = CurrentLanguage == "BM" && !string.IsNullOrEmpty(NS(r, "correctExplanationBM")) ? NS(r, "correctExplanationBM") : NS(r, "correctExplanationEN");

                            string json = "{" + JStr("id", NS(r, "questionId")) + "," + JStr("text", text) + "," + JStr("type", NS(r, "questionType")) + "," +
                                JStr("diff", NS(r, "difficulty")) + "," + JStr("status", NS(r, "status")) + "," + JStr("teacher", NS(r, "teacherName")) + "," +
                                JStr("subtopic", sub) + "," + JStr("lang", "") + "," + JStr("correct", NS(r, "correctAnswer")) + "," +
                                JStr("optA", optA) + "," + JStr("optB", optB) + "," + JStr("optC", optC) + "," + JStr("optD", optD) + "," +
                                JStr("explanation", expl) + "," + JStr("date", r["createdAt"] != DBNull.Value ? Convert.ToDateTime(r["createdAt"]).ToString("d MMM yyyy") : "-") + "}";

                            list.Add(new
                            {
                                questionId = NS(r, "questionId"),
                                questionText = text.Length > 150 ? text.Substring(0, 150) + "..." : text,
                                questionType = NS(r, "questionType"),
                                difficulty = NS(r, "difficulty"),
                                status = NS(r, "status"),
                                teacherName = NS(r, "teacherName"),
                                subtopicName = sub,
                                createdAt = r["createdAt"] != DBNull.Value ? Convert.ToDateTime(r["createdAt"]).ToString("d MMM yyyy") : "-",
                                typeCls = GetTypeCls(NS(r, "questionType")),
                                diffCls = GetDiffCls(NS(r, "difficulty")),
                                jsonData = json
                            });
                        }
                    }
                }
            }

            if (list.Count > 0)
            {
                rptQuestions.DataSource = list;
                rptQuestions.DataBind();
                pnlEmpty.Visible = false;
            }
            else
            {
                pnlEmpty.Visible = true;
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadStats();
            LoadQuestions(txtSearch.Text.Trim(), ddlType.SelectedValue, ddlDiff.SelectedValue, ddlStatus.SelectedValue);
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlType.SelectedIndex = 0;
            ddlDiff.SelectedIndex = 0;
            ddlStatus.SelectedIndex = 0;
            LoadStats();
            LoadQuestions("", "", "", "");
        }

        // --- AJAX Handlers ---

        private void HandleGetQuestion()
        {
            Response.ContentType = "application/json";
            try
            {
                if (Session["userId"] == null)
                { Response.Write("{\"success\":false,\"msg\":\"Unauthorized\"}"); return; }

                string qId = Request.QueryString["qId"] ?? "";
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("SELECT [questionId],[questionTextEN],[questionTextBM],[optionA_EN],[optionB_EN],[optionC_EN],[optionD_EN],[correctAnswer],[difficulty],[status] FROM dbo.[Question] WHERE [questionId]=@id", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", qId);
                        using (var rd = cmd.ExecuteReader())
                        {
                            if (!rd.Read())
                            { Response.Write("{\"success\":false,\"msg\":\"Not found\"}"); return; }

                            string json = "{\"success\":true,\"data\":{" +
                                "\"id\":\"" + EJ(rd["questionId"]) + "\"," +
                                "\"textEN\":\"" + EJ(rd["questionTextEN"]) + "\"," +
                                "\"textBM\":\"" + EJ(rd["questionTextBM"]) + "\"," +
                                "\"optA\":\"" + EJ(rd["optionA_EN"]) + "\"," +
                                "\"optB\":\"" + EJ(rd["optionB_EN"]) + "\"," +
                                "\"optC\":\"" + EJ(rd["optionC_EN"]) + "\"," +
                                "\"optD\":\"" + EJ(rd["optionD_EN"]) + "\"," +
                                "\"correct\":\"" + EJ(rd["correctAnswer"]) + "\"," +
                                "\"diff\":\"" + EJ(rd["difficulty"]) + "\"," +
                                "\"status\":\"" + EJ(rd["status"]) + "\"}}";
                            Response.Write(json);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Response.Write("{\"success\":false,\"msg\":\"" + EJ(ex.Message) + "\"}");
            }
        }

        private void HandleSaveQuestion()
        {
            Response.Clear();
            Response.ContentType = "application/json";
            try
            {
                if (Session["userId"] == null)
                { Response.Write("{\"success\":false,\"msg\":\"Unauthorized\"}"); return; }

                string qId = Request.QueryString["qId"] ?? "";
                string textEN = Request.QueryString["textEN"] ?? "";
                string textBM = Request.QueryString["textBM"] ?? "";
                string optA = Request.QueryString["optA"] ?? "";
                string optB = Request.QueryString["optB"] ?? "";
                string optC = Request.QueryString["optC"] ?? "";
                string optD = Request.QueryString["optD"] ?? "";
                string correct = Request.QueryString["correct"] ?? "";
                string diff = Request.QueryString["diff"] ?? "";

                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand(@"UPDATE dbo.[Question] SET [questionTextEN]=@tEN,[questionTextBM]=@tBM,
                        [optionA_EN]=@oA,[optionB_EN]=@oB,[optionC_EN]=@oC,[optionD_EN]=@oD,
                        [correctAnswer]=@cor,[difficulty]=@dif WHERE [questionId]=@id", conn))
                    {
                        cmd.Parameters.AddWithValue("@tEN", textEN);
                        cmd.Parameters.AddWithValue("@tBM", textBM);
                        cmd.Parameters.AddWithValue("@oA", optA);
                        cmd.Parameters.AddWithValue("@oB", optB);
                        cmd.Parameters.AddWithValue("@oC", optC);
                        cmd.Parameters.AddWithValue("@oD", optD);
                        cmd.Parameters.AddWithValue("@cor", correct);
                        cmd.Parameters.AddWithValue("@dif", diff);
                        cmd.Parameters.AddWithValue("@id", qId);
                        cmd.ExecuteNonQuery();
                    }
                    InsertLog(conn, Session["userId"].ToString(), "Question Updated", "Updated question " + qId + ".", "Success");
                }
                Response.Write("{\"success\":true}");
            }
            catch (Exception ex)
            {
                Response.Write("{\"success\":false,\"msg\":\"" + EJ(ex.Message) + "\"}");
            }
        }

        private void HandleDisable()
        {
            Response.ContentType = "application/json";
            try
            {
                if (Session["userId"] == null)
                { Response.Write("{\"success\":false,\"msg\":\"Unauthorized\"}"); return; }

                string qId = Request.QueryString["qId"] ?? "";
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("UPDATE dbo.[Question] SET [status]='Disabled' WHERE [questionId]=@id", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", qId);
                        cmd.ExecuteNonQuery();
                    }
                    InsertLog(conn, Session["userId"].ToString(), "Question Disabled", "Disabled question " + qId + ".", "Success");
                }
                Response.Write("{\"success\":true}");
            }
            catch (Exception ex)
            {
                Response.Write("{\"success\":false,\"msg\":\"" + EJ(ex.Message) + "\"}");
            }
        }

        // --- Helper Methods ---

        private void InsertLog(SqlConnection c, string uid, string action, string desc, string status)
        {
            string id = GenId(c, "Log", "logId", "LOG");
            using (var cmd = new SqlCommand("INSERT INTO dbo.[Log]([logId],[userId],[action],[description],[logDateTime],[status]) VALUES(@a,@b,@c,@d,@e,@f)", c))
            {
                cmd.Parameters.AddWithValue("@a", id);
                cmd.Parameters.AddWithValue("@b", uid);
                cmd.Parameters.AddWithValue("@c", action);
                cmd.Parameters.AddWithValue("@d", desc);
                cmd.Parameters.AddWithValue("@e", DateTime.Now);
                cmd.Parameters.AddWithValue("@f", status);
                cmd.ExecuteNonQuery();
            }
        }

        private string GenId(SqlConnection c, string tbl, string col, string pfx)
        {
            using (var cmd = new SqlCommand(string.Format("SELECT TOP 1 [{0}] FROM dbo.[{1}] ORDER BY [{0}] DESC", col, tbl), c))
            {
                var val = cmd.ExecuteScalar();
                if (val == null || val == DBNull.Value) return pfx + "001";
                string last = val.ToString();
                int num;
                int.TryParse(last.Substring(pfx.Length), out num);
                num++;
                return pfx + num.ToString().PadLeft(last.Length - pfx.Length, '0');
            }
        }

        private string GetTypeCls(string t)
        {
            switch ((t ?? "").ToLower())
            {
                case "mcq": return "qb-bdg-mcq";
                case "true/false": return "qb-bdg-tf";
                case "multi select": return "qb-bdg-multi";
                case "drag & drop": return "qb-bdg-drag";
                case "fill in the blank": return "qb-bdg-fill";
                default: return "qb-bdg-other";
            }
        }

        private string GetDiffCls(string d)
        {
            switch ((d ?? "").ToLower())
            {
                case "easy": return "qb-bdg-easy";
                case "medium": return "qb-bdg-medium";
                case "hard": return "qb-bdg-hard";
                default: return "qb-bdg-other";
            }
        }

        private int SC(SqlConnection c, string sql)
        {
            try
            {
                using (var cmd = new SqlCommand(sql, c))
                {
                    var val = cmd.ExecuteScalar();
                    return val != null && val != DBNull.Value ? Convert.ToInt32(val) : 0;
                }
            }
            catch { return 0; }
        }

        private static string NS(DataRow r, string col)
        {
            if (!r.Table.Columns.Contains(col)) return "";
            return r[col] == null || r[col] == DBNull.Value ? "" : r[col].ToString();
        }

        private static string JStr(string key, string val)
        {
            return "\"" + key + "\":\"" + EJ(val) + "\"";
        }

        private static string EJ(object v)
        {
            string s = (v == null || v == DBNull.Value) ? "" : v.ToString();
            return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "");
        }
    }
}
