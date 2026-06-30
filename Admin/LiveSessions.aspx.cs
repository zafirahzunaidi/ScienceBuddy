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
    public partial class LiveSessions : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        protected string CurrentLanguage => ((ScienceBuddy.SiteMaster)Master).CurrentLanguage;
        protected string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null) { Response.Redirect("~/Login.aspx", false); return; }
            if (Session["role"] == null || Session["role"].ToString() != "Admin") { Response.Redirect("~/Login.aspx", false); return; }
            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            if (!IsPostBack) { SetMasterUser(); LoadDropdowns(); LoadStats(); LoadSessions("", "", "", ""); }
            txtSearch.Attributes["placeholder"] = T("Search session, teacher, unit…", "Cari sesi, guru, unit…");
            btnSearch.Text = T("Search", "Cari"); btnReset.Text = T("Reset", "Tetapkan Semula");
            btnCloseModal.Text = T("Close", "Tutup");
        }

        private void SetMasterUser()
        {
            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                using (var cmd = new SqlCommand("SELECT [username] FROM dbo.[User] WHERE [userId]=@uid", conn))
                { cmd.Parameters.AddWithValue("@uid", Session["userId"].ToString());
                  var v = cmd.ExecuteScalar(); string n = v != null && v != DBNull.Value ? v.ToString() : "Admin";
                  ((ScienceBuddy.SiteMaster)Master).SetUserInfo(n, "Administrator", n.Length >= 2 ? n.Substring(0, 2).ToUpper() : n.ToUpper()); } }
        }

        private void LoadDropdowns()
        {
            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                // Teachers
                ddlTeacher.Items.Clear(); ddlTeacher.Items.Add(new ListItem(T("All Teachers", "Semua Guru"), ""));
                using (var cmd = new SqlCommand("SELECT [teacherId],[name] FROM dbo.[Teacher] ORDER BY [name]", conn))
                using (var rd = cmd.ExecuteReader()) { while (rd.Read()) ddlTeacher.Items.Add(new ListItem(NS(rd["name"]), rd["teacherId"].ToString())); }
                // Units
                string uCol = CurrentLanguage == "BM" ? "unitNameBM" : "unitNameEN";
                ddlUnit.Items.Clear(); ddlUnit.Items.Add(new ListItem(T("All Units", "Semua Unit"), ""));
                using (var cmd = new SqlCommand("SELECT [unitId],[unitNameEN],[unitNameBM] FROM dbo.[Unit] ORDER BY [orderNo]", conn))
                using (var rd = cmd.ExecuteReader()) { while (rd.Read()) ddlUnit.Items.Add(new ListItem(NS(rd[uCol]), rd["unitId"].ToString())); }
            }
        }

        private void LoadStats()
        {
            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                litTotalSessions.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[LiveConsultationSession]");
                litUpcoming.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[LiveConsultationSession] WHERE [status]='Upcoming'");
                litCompleted.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[LiveConsultationSession] WHERE [status]='Completed'");
                litTeachers.Text = SS(conn, "SELECT COUNT(DISTINCT [teacherId]) FROM dbo.[LiveConsultationSession]");
                litAttendance.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[LiveSessionParticipant]");
                int total = SafeInt(conn, "SELECT COUNT(*) FROM dbo.[LiveConsultationSession]");
                int parts = SafeInt(conn, "SELECT COUNT(*) FROM dbo.[LiveSessionParticipant]");
                litAvgAttendance.Text = total > 0 ? Math.Round((decimal)parts / total, 1).ToString("0.#") : "0";
            }
        }

        private void LoadSessions(string search, string statusF, string teacherF, string unitF)
        {
            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                string uCol = CurrentLanguage == "BM" ? "un.[unitNameBM]" : "un.[unitNameEN]";
                string sql = string.Format(@"SELECT s.[sessionId],s.[sessionTitle],s.[startDateTime],s.[endDateTime],s.[status],
                    t.[name] AS teacherName, ISNULL({0},'-') AS unitName,
                    (SELECT COUNT(*) FROM dbo.[LiveSessionParticipant] p WHERE p.[sessionId]=s.[sessionId]) AS participantCount
                    FROM dbo.[LiveConsultationSession] s
                    LEFT JOIN dbo.[Teacher] t ON t.[teacherId]=s.[teacherId]
                    LEFT JOIN dbo.[Unit] un ON un.[unitId]=s.[unitId]
                    WHERE 1=1", uCol);
                if (!string.IsNullOrWhiteSpace(search)) sql += " AND (s.[sessionTitle] LIKE @s OR t.[name] LIKE @s OR " + uCol + " LIKE @s)";
                if (!string.IsNullOrWhiteSpace(statusF)) sql += " AND s.[status]=@st";
                if (!string.IsNullOrWhiteSpace(teacherF)) sql += " AND s.[teacherId]=@tid";
                if (!string.IsNullOrWhiteSpace(unitF)) sql += " AND s.[unitId]=@uid";
                sql += " ORDER BY s.[startDateTime] DESC";

                using (var cmd = new SqlCommand(sql, conn)) {
                    if (!string.IsNullOrWhiteSpace(search)) cmd.Parameters.AddWithValue("@s", "%" + search + "%");
                    if (!string.IsNullOrWhiteSpace(statusF)) cmd.Parameters.AddWithValue("@st", statusF);
                    if (!string.IsNullOrWhiteSpace(teacherF)) cmd.Parameters.AddWithValue("@tid", teacherF);
                    if (!string.IsNullOrWhiteSpace(unitF)) cmd.Parameters.AddWithValue("@uid", unitF);
                    var da = new SqlDataAdapter(cmd); var dt = new DataTable(); da.Fill(dt);
                    if (dt.Rows.Count == 0) { pnlSessions.Visible = false; pnlEmpty.Visible = true; return; }
                    var list = new List<object>();
                    foreach (DataRow r in dt.Rows) {
                        string st = NS(r["status"]);
                        DateTime start = r["startDateTime"] == DBNull.Value ? DateTime.Now : Convert.ToDateTime(r["startDateTime"]);
                        list.Add(new { sessionId = r["sessionId"].ToString(), title = NS(r["sessionTitle"]),
                            teacherName = NS(r["teacherName"]), unitName = NS(r["unitName"]),
                            startStr = start.ToString("d MMM yyyy, HH:mm"), participantCount = r["participantCount"],
                            statusLabel = st == "Upcoming" ? T("Upcoming", "Akan Datang") : st == "Completed" ? T("Completed", "Selesai") : T("Cancelled", "Dibatalkan"),
                            statusCls = st == "Upcoming" ? "sb-badge-primary" : st == "Completed" ? "sb-badge-success" : "sb-badge-error" });
                    }
                    pnlSessions.Visible = true; pnlEmpty.Visible = false; rptSessions.DataSource = list; rptSessions.DataBind();
                }
            }
        }

        protected void rptSessions_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "ViewSession") return;
            ShowModal(e.CommandArgument.ToString());
        }

        private void ShowModal(string sessionId)
        {
            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                string uCol = CurrentLanguage == "BM" ? "un.[unitNameBM]" : "un.[unitNameEN]";
                string stCol = CurrentLanguage == "BM" ? "st.[subtopicTitleBM]" : "st.[subtopicTitleEN]";
                string sql = string.Format(@"SELECT s.*,t.[name] AS teacherName,ISNULL({0},'-') AS unitName,ISNULL({1},'-') AS subtopicName
                    FROM dbo.[LiveConsultationSession] s LEFT JOIN dbo.[Teacher] t ON t.[teacherId]=s.[teacherId]
                    LEFT JOIN dbo.[Unit] un ON un.[unitId]=s.[unitId] LEFT JOIN dbo.[Subtopic] st ON st.[subtopicId]=s.[subtopicId]
                    WHERE s.[sessionId]=@sid", uCol, stCol);
                using (var cmd = new SqlCommand(sql, conn)) { cmd.Parameters.AddWithValue("@sid", sessionId);
                    using (var rd = cmd.ExecuteReader()) { if (!rd.Read()) return;
                        litMTitle.Text = HttpUtility.HtmlEncode(NS(rd["sessionTitle"]));
                        litMDesc.Text = HttpUtility.HtmlEncode(NS(rd["sessionDescription"]));
                        litMTeacher.Text = HttpUtility.HtmlEncode(NS(rd["teacherName"]));
                        litMUnit.Text = HttpUtility.HtmlEncode(NS(rd["unitName"]) + " / " + NS(rd["subtopicName"]));
                        DateTime start = rd["startDateTime"] == DBNull.Value ? DateTime.MinValue : Convert.ToDateTime(rd["startDateTime"]);
                        DateTime end = rd["endDateTime"] == DBNull.Value ? DateTime.MinValue : Convert.ToDateTime(rd["endDateTime"]);
                        litMSchedule.Text = start != DateTime.MinValue ? start.ToString("d MMM yyyy, HH:mm") + " - " + (end != DateTime.MinValue ? end.ToString("HH:mm") : "—") : "—";
                        string link = NS(rd["meetingLink"]);
                        litMLink.Text = !string.IsNullOrWhiteSpace(link) ? HttpUtility.HtmlEncode(link) : "—";
                        string st = NS(rd["status"]);
                        litMStatus.Text = string.Format("<span class=\"sb-badge {0}\">{1}</span>",
                            st == "Upcoming" ? "sb-badge-primary" : st == "Completed" ? "sb-badge-success" : "sb-badge-error",
                            HttpUtility.HtmlEncode(st == "Upcoming" ? T("Upcoming", "Akan Datang") : st == "Completed" ? T("Completed", "Selesai") : T("Cancelled", "Dibatalkan")));
                    }
                }
                // Participants
                using (var cmd = new SqlCommand(@"SELECT p.[joinedAt],s.[name],s.[nickname] FROM dbo.[LiveSessionParticipant] p
                    LEFT JOIN dbo.[Student] s ON s.[studentId]=p.[studentId] WHERE p.[sessionId]=@sid ORDER BY p.[joinedAt]", conn))
                { cmd.Parameters.AddWithValue("@sid", sessionId);
                    var da = new SqlDataAdapter(cmd); var dt = new DataTable(); da.Fill(dt);
                    litMCount.Text = dt.Rows.Count.ToString();
                    if (dt.Rows.Count == 0) { pnlParticipants.Visible = false; pnlNoParticipants.Visible = true; }
                    else {
                        string[] grads = {"background:linear-gradient(135deg,#4F46E5,#818CF8);","background:linear-gradient(135deg,#10B981,#34D399);","background:linear-gradient(135deg,#F59E0B,#FBBF24);","background:linear-gradient(135deg,#EC4899,#F472B6);"};
                        var list = new List<object>(); int i = 0;
                        foreach (DataRow r in dt.Rows) {
                            string nm = NS(r["nickname"]); if (string.IsNullOrWhiteSpace(nm)) nm = NS(r["name"]); if (string.IsNullOrWhiteSpace(nm)) nm = "Student";
                            DateTime j = r["joinedAt"] == DBNull.Value ? DateTime.MinValue : Convert.ToDateTime(r["joinedAt"]);
                            list.Add(new { studentName = nm, initials = GI(nm), joinedStr = j != DateTime.MinValue ? j.ToString("HH:mm") : "—", gradient = grads[i % grads.Length] }); i++;
                        }
                        pnlParticipants.Visible = true; pnlNoParticipants.Visible = false; rptParticipants.DataSource = list; rptParticipants.DataBind();
                    }
                }
            }
            pnlModal.Visible = true;
        }

        protected void btnCloseModal_Click(object sender, EventArgs e) { pnlModal.Visible = false; }
        protected void btnSearch_Click(object sender, EventArgs e) { LoadSessions(txtSearch.Text.Trim(), ddlStatus.SelectedValue, ddlTeacher.SelectedValue, ddlUnit.SelectedValue); }
        protected void btnReset_Click(object sender, EventArgs e) { txtSearch.Text = ""; ddlStatus.SelectedIndex = 0; ddlTeacher.SelectedIndex = 0; ddlUnit.SelectedIndex = 0; LoadSessions("", "", "", ""); }

        private string SS(SqlConnection c, string sql) { try { using (var cmd = new SqlCommand(sql, c)) { var v = cmd.ExecuteScalar(); return v != null && v != DBNull.Value ? Convert.ToInt32(v).ToString() : "0"; } } catch { return "0"; } }
        private int SafeInt(SqlConnection c, string sql) { try { using (var cmd = new SqlCommand(sql, c)) { var v = cmd.ExecuteScalar(); return v != null && v != DBNull.Value ? Convert.ToInt32(v) : 0; } } catch { return 0; } }
        private static string NS(object v) { return (v == null || v == DBNull.Value) ? "" : v.ToString(); }
        private static string GI(string n) { if (string.IsNullOrWhiteSpace(n)) return "S"; var p = n.Trim().Split(' '); return p.Length >= 2 ? (p[0][0].ToString() + p[p.Length - 1][0].ToString()).ToUpper() : n.Substring(0, Math.Min(2, n.Length)).ToUpper(); }
    }
}
