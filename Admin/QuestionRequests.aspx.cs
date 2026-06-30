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
                    q.[optionA_EN],q.[optionB_EN],q.[optionC_EN],q.[optionD_EN],
                    ISNULL(t.[name],u.[username]) AS teacherName,
                    ISNULL(st.[subtopicTitleEN],'') AS subEN, ISNULL(st.[subtopicTitleBM],'') AS subBM
                    FROM dbo.[Question] q
                    LEFT JOIN dbo.[User] u ON u.[userId]=q.[createdByUserId]
                    LEFT JOIN dbo.[Teacher] t ON t.[userId]=q.[createdByUserId]
                    LEFT JOIN dbo.[Subtopic] st ON st.[subtopicId]=q.[subtopicId]
                    WHERE 1=1";
                if (!string.IsNullOrWhiteSpace(status)) sql += " AND q.[status]=@st";
                if (!string.IsNullOrWhiteSpace(diff)) sql += " AND q.[difficulty]=@df";
                if (!string.IsNullOrWhiteSpace(search)) sql += " AND (q.[questionTextEN] LIKE @s OR q.[questionTextBM] LIKE @s OR ISNULL(t.[name],'') LIKE @s OR u.[username] LIKE @s OR ISNULL(st.[subtopicTitleEN],'') LIKE @s)";
                sql += " ORDER BY CASE WHEN q.[status]='Pending' THEN 0 ELSE 1 END, q.[createdAt] DESC";

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
                            string textEN = r["questionTextEN"]?.ToString() ?? "";
                            string textBM = r["questionTextBM"]?.ToString() ?? "";
                            string text = CurrentLanguage == "BM" && !string.IsNullOrEmpty(textBM) ? textBM : textEN;
                            if (string.IsNullOrEmpty(text)) text = textEN;
                            string subName = CurrentLanguage == "BM" && !string.IsNullOrEmpty(r["subBM"]?.ToString()) ? r["subBM"].ToString() : r["subEN"].ToString();

                            string json = "{id:'" + Esc(r["questionId"]) + "',text:'" + Esc(text) + "',type:'" + Esc(r["questionType"]) +
                                "',diff:'" + Esc(r["difficulty"]) + "',status:'" + Esc(r["status"]) + "',teacher:'" + Esc(r["teacherName"]) +
                                "',subtopic:'" + Esc(subName) + "',correct:'" + Esc(r["correctAnswer"]) +
                                "',optA:'" + Esc(r["optionA_EN"]) + "',optB:'" + Esc(r["optionB_EN"]) +
                                "',optC:'" + Esc(r["optionC_EN"]) + "',optD:'" + Esc(r["optionD_EN"]) + "'}";

                            list.Add(new
                            {
                                questionId = r["questionId"].ToString(),
                                questionText = text.Length > 120 ? text.Substring(0, 120) + "..." : text,
                                questionType = r["questionType"]?.ToString() ?? "",
                                difficulty = r["difficulty"]?.ToString() ?? "",
                                status = r["status"]?.ToString() ?? "",
                                teacherName = r["teacherName"]?.ToString() ?? "-",
                                teacherUserId = r["createdByUserId"]?.ToString() ?? "",
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
            LoadData(txtSearch.Text.Trim(), fStatus.Value, fDifficulty.Value);
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = ""; fStatus.Value = ""; fDifficulty.Value = "";
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
            LoadStats(); LoadData(txtSearch.Text.Trim(), fStatus.Value, fDifficulty.Value);
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

        private static string Esc(object v) { string s = v?.ToString() ?? ""; return s.Replace("\\", "\\\\").Replace("'", "\\'").Replace("\n", " ").Replace("\r", ""); }
    }
}
