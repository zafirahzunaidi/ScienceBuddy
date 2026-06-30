using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Admin
{
    public partial class QuestionRequests : Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected string CurrentLanguage =>
            ((ScienceBuddy.SiteMaster)Master).CurrentLanguage;

        protected string T(string en, string bm) => CurrentLanguage == "BM" ? bm : en;

        protected void Page_Load(object sender, EventArgs e)
        {
            // AJAX handler for approve/reject
            if (Request.QueryString["handler"] == "ReviewQuestion" && Request.HttpMethod == "POST")
            {
                HandleReview();
                return;
            }

            if (Session["userId"] == null || Session["role"]?.ToString() != "Admin")
            { Response.Redirect("~/Login.aspx", false); return; }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                SetUserInfo();
                LoadStats();
                LoadData("", "", "");
                txtSearch.Attributes["placeholder"] = T("Search question, teacher, subtopic...", "Cari soalan, guru, subtopik...");
            }
        }

        private void HandleReview()
        {
            Response.ContentType = "application/json";
            try
            {
                if (Session["userId"] == null || Session["role"]?.ToString() != "Admin")
                { Response.Write("{\"success\":false,\"msg\":\"Unauthorized\"}"); Response.End(); return; }

                string qId = Request.QueryString["qId"] ?? "";
                string action = Request.QueryString["action"] ?? "";
                string teacherUid = Request.QueryString["tUid"] ?? "";
                string userId = Session["userId"].ToString();

                if (string.IsNullOrEmpty(qId) || (action != "Approve" && action != "Reject"))
                { Response.Write("{\"success\":false,\"msg\":\"Invalid\"}"); Response.End(); return; }

                string newStatus = action == "Approve" ? "Approved" : "Rejected";
                string reviewedAt = "";

                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    DateTime now = DateTime.Now;
                    using (var cmd = new SqlCommand("UPDATE dbo.[Question] SET [status]=@s,[reviewedDate]=@d WHERE [questionId]=@id", conn))
                    {
                        cmd.Parameters.AddWithValue("@s", newStatus);
                        cmd.Parameters.AddWithValue("@d", now);
                        cmd.Parameters.AddWithValue("@id", qId);
                        cmd.ExecuteNonQuery();
                    }
                    reviewedAt = now.ToString("d MMM yyyy");

                    string logAction = action == "Approve" ? "Approved Question " + qId : "Rejected Question " + qId;
                    InsertLog(conn, userId, logAction, logAction + ".", "Success");

                    if (!string.IsNullOrEmpty(teacherUid))
                    {
                        if (action == "Approve")
                            InsertNotification(conn, teacherUid, "Question Approved", "Soalan Diluluskan",
                                "Your submitted question has been approved and is now available for quiz creation.",
                                "Soalan yang anda hantar telah diluluskan dan kini boleh digunakan untuk pembinaan kuiz.");
                        else
                            InsertNotification(conn, teacherUid, "Question Rejected", "Soalan Ditolak",
                                "Your submitted question requires revision before approval.",
                                "Soalan anda memerlukan pembetulan sebelum boleh diluluskan.");
                    }

                    // Get updated counts
                    int pending = SC(conn, "SELECT COUNT(*) FROM dbo.[Question] WHERE [status]='Pending'");
                    int approved = SC(conn, "SELECT COUNT(*) FROM dbo.[Question] WHERE [status]='Approved'");
                    int rejected = SC(conn, "SELECT COUNT(*) FROM dbo.[Question] WHERE [status]='Rejected'");
                    int today = SC(conn, "SELECT COUNT(*) FROM dbo.[Question] WHERE [reviewedDate] IS NOT NULL AND CAST([reviewedDate] AS DATE)=CAST(GETDATE() AS DATE)");

                    string json = "{\"success\":true,\"status\":\"" + newStatus + "\",\"reviewedAt\":\"" + reviewedAt + "\"," +
                        "\"pending\":" + pending + ",\"approved\":" + approved + ",\"rejected\":" + rejected + ",\"today\":" + today + "}";
                    Response.Write(json);
                }
            }
            catch (Exception ex)
            {
                Response.Write("{\"success\":false,\"msg\":\"" + ex.Message.Replace("\"", "'") + "\"}");
            }
            Response.End();
        }

        private void SetUserInfo()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [username] FROM dbo.[User] WHERE [userId]=@u", conn))
                {
                    cmd.Parameters.AddWithValue("@u", Session["userId"].ToString());
                    var v = cmd.ExecuteScalar();
                    string name = v?.ToString() ?? "Admin";
                    ((ScienceBuddy.SiteMaster)Master).SetUserInfo(name, "Administrator",
                        name.Length >= 2 ? name.Substring(0, 2).ToUpper() : name.ToUpper());
                }
            }
        }

        private void LoadStats()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                litPending.Text = SC(conn, "SELECT COUNT(*) FROM dbo.[Question] WHERE [status]='Pending'").ToString();
                litApproved.Text = SC(conn, "SELECT COUNT(*) FROM dbo.[Question] WHERE [status]='Approved'").ToString();
                litRejected.Text = SC(conn, "SELECT COUNT(*) FROM dbo.[Question] WHERE [status]='Rejected'").ToString();
                litToday.Text = SC(conn, "SELECT COUNT(*) FROM dbo.[Question] WHERE [reviewedDate] IS NOT NULL AND CAST([reviewedDate] AS DATE)=CAST(GETDATE() AS DATE)").ToString();
                int p = int.Parse(litPending.Text);
                litBadge.Text = p > 0 ? "<span class=\"sb-badge sb-badge-warning\" style=\"margin-left:6px;\">" + p + "</span>" : "";
            }
        }

        private void LoadData(string search, string status, string diff)
        {
            var all = Fetch(search, status, diff);
            var pending = new List<object>();
            var history = new List<object>();
            foreach (var r in all) { if (((dynamic)r).status == "Pending") pending.Add(r); else history.Add(r); }

            pnlPending.Visible = pending.Count > 0; pnlPendingEmpty.Visible = pending.Count == 0;
            if (pending.Count > 0) { rptPending.DataSource = pending; rptPending.DataBind(); }

            pnlHistory.Visible = history.Count > 0; pnlHistoryEmpty.Visible = history.Count == 0;
            if (history.Count > 0) { rptHistory.DataSource = history; rptHistory.DataBind(); }
        }

        private List<object> Fetch(string search, string status, string diff)
        {
            var list = new List<object>();
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                string sql = @"SELECT q.[questionId],q.[questionTextEN],q.[questionTextBM],q.[questionType],
                    q.[difficulty],q.[status],q.[createdAt],q.[reviewedDate],q.[createdByUserId],q.[correctAnswer],
                    q.[optionA_EN],q.[optionA_BM],q.[optionB_EN],q.[optionB_BM],
                    q.[optionC_EN],q.[optionC_BM],q.[optionD_EN],q.[optionD_BM],
                    q.[correctExplanationEN],q.[correctExplanationBM],
                    ISNULL(t.[name],u.[username]) AS teacherName,
                    ISNULL(st.[subtopicTitleEN],'') AS subEN, ISNULL(st.[subtopicTitleBM],'') AS subBM,
                    ISNULL(un.[unitNameEN],'') AS unitEN, ISNULL(un.[unitNameBM],'') AS unitBM,
                    ISNULL(lv.[levelNameEN],'') AS levelEN, ISNULL(lv.[levelNameBM],'') AS levelBM
                    FROM dbo.[Question] q
                    LEFT JOIN dbo.[User] u ON u.[userId]=q.[createdByUserId]
                    LEFT JOIN dbo.[Teacher] t ON t.[userId]=q.[createdByUserId]
                    LEFT JOIN dbo.[Subtopic] st ON st.[subtopicId]=q.[subtopicId]
                    LEFT JOIN dbo.[Unit] un ON un.[unitId]=st.[unitId]
                    LEFT JOIN dbo.[Level] lv ON lv.[levelId]=un.[levelId]
                    WHERE 1=1";
                if (!string.IsNullOrWhiteSpace(status)) sql += " AND q.[status]=@st";
                if (!string.IsNullOrWhiteSpace(diff)) sql += " AND q.[difficulty]=@df";
                if (!string.IsNullOrWhiteSpace(search)) sql += " AND (q.[questionTextEN] LIKE @s OR q.[questionTextBM] LIKE @s OR ISNULL(t.[name],'') LIKE @s OR u.[username] LIKE @s OR ISNULL(st.[subtopicTitleEN],'') LIKE @s)";
                sql += " ORDER BY CASE WHEN q.[status]='Pending' THEN 0 ELSE 1 END, CASE WHEN q.[status]='Pending' THEN q.[createdAt] ELSE q.[reviewedDate] END DESC";

                using (var cmd = new SqlCommand(sql, conn))
                {
                    if (!string.IsNullOrWhiteSpace(status)) cmd.Parameters.AddWithValue("@st", status);
                    if (!string.IsNullOrWhiteSpace(diff)) cmd.Parameters.AddWithValue("@df", diff);
                    if (!string.IsNullOrWhiteSpace(search)) cmd.Parameters.AddWithValue("@s", "%" + search + "%");
                    using (var da = new SqlDataAdapter(cmd))
                    {
                        var dt = new DataTable(); da.Fill(dt);
                        foreach (DataRow r in dt.Rows)
                        {
                            string textEN = NullSafe(r, "questionTextEN");
                            string textBM = NullSafe(r, "questionTextBM");
                            string text = CurrentLanguage == "BM" && !string.IsNullOrEmpty(textBM) ? textBM : textEN;
                            if (string.IsNullOrEmpty(text)) text = !string.IsNullOrEmpty(textEN) ? textEN : textBM;
                            if (string.IsNullOrEmpty(text)) text = "(No question text)";

                            string subName = CurrentLanguage == "BM" && !string.IsNullOrEmpty(NullSafe(r, "subBM")) ? NullSafe(r, "subBM") : NullSafe(r, "subEN");
                            string unitName = CurrentLanguage == "BM" && !string.IsNullOrEmpty(NullSafe(r, "unitBM")) ? NullSafe(r, "unitBM") : NullSafe(r, "unitEN");
                            string levelName = CurrentLanguage == "BM" && !string.IsNullOrEmpty(NullSafe(r, "levelBM")) ? NullSafe(r, "levelBM") : NullSafe(r, "levelEN");

                            string optA = CurrentLanguage == "BM" && !string.IsNullOrEmpty(NullSafe(r, "optionA_BM")) ? NullSafe(r, "optionA_BM") : NullSafe(r, "optionA_EN");
                            string optB = CurrentLanguage == "BM" && !string.IsNullOrEmpty(NullSafe(r, "optionB_BM")) ? NullSafe(r, "optionB_BM") : NullSafe(r, "optionB_EN");
                            string optC = CurrentLanguage == "BM" && !string.IsNullOrEmpty(NullSafe(r, "optionC_BM")) ? NullSafe(r, "optionC_BM") : NullSafe(r, "optionC_EN");
                            string optD = CurrentLanguage == "BM" && !string.IsNullOrEmpty(NullSafe(r, "optionD_BM")) ? NullSafe(r, "optionD_BM") : NullSafe(r, "optionD_EN");
                            string explanation = CurrentLanguage == "BM" && !string.IsNullOrEmpty(NullSafe(r, "correctExplanationBM")) ? NullSafe(r, "correctExplanationBM") : NullSafe(r, "correctExplanationEN");

                            // Build safe JSON using escaped values
                            string json = "{" +
                                "id:" + JsStr(NullSafe(r, "questionId")) + "," +
                                "text:" + JsStr(text) + "," +
                                "type:" + JsStr(NullSafe(r, "questionType")) + "," +
                                "diff:" + JsStr(NullSafe(r, "difficulty")) + "," +
                                "status:" + JsStr(NullSafe(r, "status")) + "," +
                                "teacher:" + JsStr(NullSafe(r, "teacherName")) + "," +
                                "subtopic:" + JsStr(subName) + "," +
                                "unit:" + JsStr(unitName) + "," +
                                "level:" + JsStr(levelName) + "," +
                                "correct:" + JsStr(NullSafe(r, "correctAnswer")) + "," +
                                "optA:" + JsStr(optA) + "," +
                                "optB:" + JsStr(optB) + "," +
                                "optC:" + JsStr(optC) + "," +
                                "optD:" + JsStr(optD) + "," +
                                "explanation:" + JsStr(explanation) + "," +
                                "date:" + JsStr(r["createdAt"] != DBNull.Value ? Convert.ToDateTime(r["createdAt"]).ToString("d MMM yyyy") : "-") +
                                "}";

                            list.Add(new
                            {
                                questionId = NullSafe(r, "questionId"),
                                questionText = text.Length > 120 ? text.Substring(0, 120) + "..." : text,
                                questionType = NullSafe(r, "questionType"),
                                difficulty = NullSafe(r, "difficulty"),
                                status = NullSafe(r, "status"),
                                teacherName = NullSafe(r, "teacherName"),
                                teacherUserId = NullSafe(r, "createdByUserId"),
                                subtopicName = subName,
                                createdAt = r["createdAt"] != DBNull.Value ? Convert.ToDateTime(r["createdAt"]).ToString("d MMM yyyy") : "-",
                                reviewedDate = r["reviewedDate"] != DBNull.Value ? Convert.ToDateTime(r["reviewedDate"]).ToString("d MMM yyyy") : "-",
                                jsonData = json
                            });
                        }
                    }
                }
            }
            return list;
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadStats();
            LoadData(txtSearch.Text.Trim(), fStatus.SelectedValue, fDifficulty.SelectedValue);
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = ""; fStatus.SelectedIndex = 0; fDifficulty.SelectedIndex = 0;
            LoadStats(); LoadData("", "", "");
        }

        protected void rptPending_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "Approve" && e.CommandName != "Reject") return;
            string[] p = e.CommandArgument.ToString().Split('|');
            string qId = p[0], teacherUid = p.Length > 1 ? p[1] : "";
            string newStatus = e.CommandName == "Approve" ? "Approved" : "Rejected";

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("UPDATE dbo.[Question] SET [status]=@s,[reviewedDate]=@d WHERE [questionId]=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@s", newStatus);
                    cmd.Parameters.AddWithValue("@d", DateTime.Now);
                    cmd.Parameters.AddWithValue("@id", qId);
                    cmd.ExecuteNonQuery();
                }

                string logAction = e.CommandName == "Approve" ? "Approved Question " + qId : "Rejected Question " + qId;
                InsertLog(conn, Session["userId"].ToString(), logAction, logAction + ".", "Success");

                if (!string.IsNullOrEmpty(teacherUid))
                {
                    if (e.CommandName == "Approve")
                        InsertNotification(conn, teacherUid, "Question Approved", "Soalan Diluluskan",
                            "Your submitted question has been approved and is now available for quiz creation.",
                            "Soalan yang anda hantar telah diluluskan dan kini boleh digunakan untuk pembinaan kuiz.");
                    else
                        InsertNotification(conn, teacherUid, "Question Rejected", "Soalan Ditolak",
                            "Your submitted question requires revision before approval.",
                            "Soalan anda memerlukan pembetulan sebelum boleh diluluskan.");
                }
            }
            LoadStats(); LoadData(txtSearch.Text.Trim(), fStatus.SelectedValue, fDifficulty.SelectedValue);
        }

        protected string GetDiffClass(object d)
        {
            switch ((d?.ToString() ?? "").ToLower())
            {
                case "easy": return "qr-diff-easy";
                case "medium": return "qr-diff-medium";
                case "hard": return "qr-diff-hard";
                default: return "sb-badge sb-badge-gray";
            }
        }

        protected string BuildBadge(string s)
        {
            switch (s)
            {
                case "Approved": return "<span class=\"sb-badge sb-badge-success\"><i class=\"bi bi-check-circle-fill\"></i> " + T("Approved", "Diluluskan") + "</span>";
                case "Rejected": return "<span class=\"sb-badge sb-badge-error\"><i class=\"bi bi-x-circle-fill\"></i> " + T("Rejected", "Ditolak") + "</span>";
                default: return "<span class=\"sb-badge sb-badge-warning\"><i class=\"bi bi-hourglass-split\"></i> " + T("Pending", "Tertunggak") + "</span>";
            }
        }

        private int SC(SqlConnection c, string sql) { try { using (var cmd = new SqlCommand(sql, c)) { var v = cmd.ExecuteScalar(); return v != null && v != DBNull.Value ? Convert.ToInt32(v) : 0; } } catch { return 0; } }

        private void InsertLog(SqlConnection c, string uid, string action, string desc, string status)
        {
            string id = GenId(c, "Log", "logId", "LOG");
            using (var cmd = new SqlCommand("INSERT INTO dbo.[Log]([logId],[userId],[action],[description],[logDateTime],[status]) VALUES(@a,@b,@c,@d,@e,@f)", c))
            { cmd.Parameters.AddWithValue("@a", id); cmd.Parameters.AddWithValue("@b", uid); cmd.Parameters.AddWithValue("@c", action); cmd.Parameters.AddWithValue("@d", desc.Length > 900 ? desc.Substring(0, 900) : desc); cmd.Parameters.AddWithValue("@e", DateTime.Now); cmd.Parameters.AddWithValue("@f", status); cmd.ExecuteNonQuery(); }
        }

        private void InsertNotification(SqlConnection c, string toUid, string tEN, string tBM, string mEN, string mBM)
        {
            string id = GenId(c, "Notification", "notificationId", "N");
            using (var cmd = new SqlCommand("INSERT INTO dbo.[Notification]([notificationId],[toUserId],[titleEN],[titleBM],[messageEN],[messageBM],[isRead],[createdAt]) VALUES(@a,@b,@c,@d,@e,@f,0,@g)", c))
            { cmd.Parameters.AddWithValue("@a", id); cmd.Parameters.AddWithValue("@b", toUid); cmd.Parameters.AddWithValue("@c", tEN); cmd.Parameters.AddWithValue("@d", tBM); cmd.Parameters.AddWithValue("@e", mEN); cmd.Parameters.AddWithValue("@f", mBM); cmd.Parameters.AddWithValue("@g", DateTime.Now); cmd.ExecuteNonQuery(); }
        }

        private string GenId(SqlConnection c, string tbl, string col, string pfx)
        {
            using (var cmd = new SqlCommand(string.Format("SELECT TOP 1 [{0}] FROM dbo.[{1}] ORDER BY [{0}] DESC", col, tbl), c))
            { var v = cmd.ExecuteScalar(); if (v == null || v == DBNull.Value) return pfx + "001"; string l = v.ToString(); int n; int.TryParse(l.Substring(pfx.Length), out n); n++; return pfx + n.ToString().PadLeft(l.Length - pfx.Length, '0'); }
        }

        private static string NullSafe(DataRow r, string col)
        {
            if (!r.Table.Columns.Contains(col)) return "";
            return r[col] == null || r[col] == DBNull.Value ? "" : r[col].ToString();
        }

        private static string JsStr(string s)
        {
            if (string.IsNullOrEmpty(s)) return "\"\"";
            s = s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "").Replace("'", "\\'");
            return "\"" + s + "\"";
        }

        private static string Esc(object v) { string s = v?.ToString() ?? ""; if (v == DBNull.Value) s = ""; return s.Replace("\\", "\\\\").Replace("'", "\\'").Replace("\n", " ").Replace("\r", ""); }
    }
}
