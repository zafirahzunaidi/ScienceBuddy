using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

// Admin LiveSessions - Code Behind

namespace ScienceBuddy.Admin
{
    public partial class LiveSessions : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected string CurrentLanguage => ((ScienceBuddy.SiteMaster)Master).CurrentLanguage;

        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        // --- Page Lifecycle ---

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null)
            { Response.Redirect("~/Login.aspx", false); return; }
            if (Session["role"] == null || Session["role"].ToString() != "Admin")
            { Response.Redirect("~/Login.aspx", false); return; }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                SetMasterUser();
                LoadDropdowns();
                LoadStats();
                LoadSessions("", "", "", "");
            }

            txtSearch.Attributes["placeholder"] = T("Search session, teacher, unit…", "Cari sesi, guru, unit…");
            btnSearch.Text = T("Search", "Cari");
            btnReset.Text = T("Reset", "Tetapkan Semula");
            btnCloseModal.Text = T("Close", "Tutup");
        }

        // --- Data Loading ---

        private void SetMasterUser()
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

        private void LoadDropdowns()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Teachers
                ddlTeacher.Items.Clear();
                ddlTeacher.Items.Add(new ListItem(T("All Teachers", "Semua Guru"), ""));
                using (var cmd = new SqlCommand("SELECT [teacherId],[name] FROM dbo.[Teacher] ORDER BY [name]", conn))
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                        ddlTeacher.Items.Add(new ListItem(NullSafe(reader["name"]), reader["teacherId"].ToString()));
                }

                // Units
                string unitCol = CurrentLanguage == "BM" ? "unitNameBM" : "unitNameEN";
                ddlUnit.Items.Clear();
                ddlUnit.Items.Add(new ListItem(T("All Units", "Semua Unit"), ""));
                using (var cmd = new SqlCommand("SELECT [unitId],[unitNameEN],[unitNameBM] FROM dbo.[Unit] ORDER BY [orderNo]", conn))
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                        ddlUnit.Items.Add(new ListItem(NullSafe(reader[unitCol]), reader["unitId"].ToString()));
                }
            }
        }

        private void LoadStats()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                litTotalSessions.Text = SafeScalar(conn, "SELECT COUNT(*) FROM dbo.[LiveConsultationSession]");
                litUpcoming.Text = SafeScalar(conn, "SELECT COUNT(*) FROM dbo.[LiveConsultationSession] WHERE [status]='Upcoming'");
                litCompleted.Text = SafeScalar(conn, "SELECT COUNT(*) FROM dbo.[LiveConsultationSession] WHERE [status]='Completed'");
                litTeachers.Text = SafeScalar(conn, "SELECT COUNT(DISTINCT [teacherId]) FROM dbo.[LiveConsultationSession]");
                litAttendance.Text = SafeScalar(conn, "SELECT COUNT(*) FROM dbo.[LiveSessionParticipant]");

                int total = SafeInt(conn, "SELECT COUNT(*) FROM dbo.[LiveConsultationSession]");
                int parts = SafeInt(conn, "SELECT COUNT(*) FROM dbo.[LiveSessionParticipant]");
                litAvgAttendance.Text = total > 0 ? Math.Round((decimal)parts / total, 1).ToString("0.#") : "0";
            }
        }

        private void LoadSessions(string search, string statusFilter, string teacherFilter, string unitFilter)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                string unitCol = CurrentLanguage == "BM" ? "un.[unitNameBM]" : "un.[unitNameEN]";

                string sql = string.Format(@"SELECT s.[sessionId],s.[sessionTitle],s.[startDateTime],s.[endDateTime],s.[status],
                    t.[name] AS teacherName, ISNULL({0},'-') AS unitName,
                    (SELECT COUNT(*) FROM dbo.[LiveSessionParticipant] p WHERE p.[sessionId]=s.[sessionId]) AS participantCount
                    FROM dbo.[LiveConsultationSession] s
                    LEFT JOIN dbo.[Teacher] t ON t.[teacherId]=s.[teacherId]
                    LEFT JOIN dbo.[Unit] un ON un.[unitId]=s.[unitId]
                    WHERE 1=1", unitCol);

                if (!string.IsNullOrWhiteSpace(search))
                    sql += " AND (s.[sessionTitle] LIKE @s OR t.[name] LIKE @s OR " + unitCol + " LIKE @s)";
                if (!string.IsNullOrWhiteSpace(statusFilter))
                    sql += " AND s.[status]=@st";
                if (!string.IsNullOrWhiteSpace(teacherFilter))
                    sql += " AND s.[teacherId]=@tid";
                if (!string.IsNullOrWhiteSpace(unitFilter))
                    sql += " AND s.[unitId]=@uid";
                sql += " ORDER BY s.[startDateTime] DESC";

                using (var cmd = new SqlCommand(sql, conn))
                {
                    if (!string.IsNullOrWhiteSpace(search))
                        cmd.Parameters.AddWithValue("@s", "%" + search + "%");
                    if (!string.IsNullOrWhiteSpace(statusFilter))
                        cmd.Parameters.AddWithValue("@st", statusFilter);
                    if (!string.IsNullOrWhiteSpace(teacherFilter))
                        cmd.Parameters.AddWithValue("@tid", teacherFilter);
                    if (!string.IsNullOrWhiteSpace(unitFilter))
                        cmd.Parameters.AddWithValue("@uid", unitFilter);

                    var da = new SqlDataAdapter(cmd);
                    var dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count == 0)
                    {
                        pnlSessions.Visible = false;
                        pnlEmpty.Visible = true;
                        return;
                    }

                    var list = new List<object>();
                    foreach (DataRow row in dt.Rows)
                    {
                        string status = NullSafe(row["status"]);
                        DateTime start = row["startDateTime"] == DBNull.Value ? DateTime.Now : Convert.ToDateTime(row["startDateTime"]);

                        list.Add(new
                        {
                            sessionId = row["sessionId"].ToString(),
                            title = NullSafe(row["sessionTitle"]),
                            teacherName = NullSafe(row["teacherName"]),
                            unitName = NullSafe(row["unitName"]),
                            startStr = start.ToString("d MMM yyyy, HH:mm"),
                            participantCount = row["participantCount"],
                            statusLabel = status == "Upcoming" ? T("Upcoming", "Akan Datang") : status == "Completed" ? T("Completed", "Selesai") : T("Cancelled", "Dibatalkan"),
                            statusCls = status == "Upcoming" ? "sb-badge-primary" : status == "Completed" ? "sb-badge-success" : "sb-badge-error"
                        });
                    }

                    pnlSessions.Visible = true;
                    pnlEmpty.Visible = false;
                    rptSessions.DataSource = list;
                    rptSessions.DataBind();
                }
            }
        }

        // --- Event Handlers ---

        protected void rptSessions_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "ViewSession") return;
            ShowModal(e.CommandArgument.ToString());
        }

        protected void btnCloseModal_Click(object sender, EventArgs e)
        {
            pnlModal.Visible = false;
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadSessions(txtSearch.Text.Trim(), ddlStatus.SelectedValue, ddlTeacher.SelectedValue, ddlUnit.SelectedValue);
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlStatus.SelectedIndex = 0;
            ddlTeacher.SelectedIndex = 0;
            ddlUnit.SelectedIndex = 0;
            LoadSessions("", "", "", "");
        }

        // --- Modal ---

        private void ShowModal(string sessionId)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                string unitCol = CurrentLanguage == "BM" ? "un.[unitNameBM]" : "un.[unitNameEN]";
                string subtopicCol = CurrentLanguage == "BM" ? "st.[subtopicTitleBM]" : "st.[subtopicTitleEN]";

                string sql = string.Format(@"SELECT s.*,t.[name] AS teacherName,ISNULL({0},'-') AS unitName,ISNULL({1},'-') AS subtopicName
                    FROM dbo.[LiveConsultationSession] s LEFT JOIN dbo.[Teacher] t ON t.[teacherId]=s.[teacherId]
                    LEFT JOIN dbo.[Unit] un ON un.[unitId]=s.[unitId] LEFT JOIN dbo.[Subtopic] st ON st.[subtopicId]=s.[subtopicId]
                    WHERE s.[sessionId]=@sid", unitCol, subtopicCol);

                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@sid", sessionId);
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read()) return;

                        litMTitle.Text = HttpUtility.HtmlEncode(NullSafe(reader["sessionTitle"]));
                        litMDesc.Text = HttpUtility.HtmlEncode(NullSafe(reader["sessionDescription"]));
                        litMTeacher.Text = HttpUtility.HtmlEncode(NullSafe(reader["teacherName"]));
                        litMUnit.Text = HttpUtility.HtmlEncode(NullSafe(reader["unitName"]) + " / " + NullSafe(reader["subtopicName"]));

                        DateTime start = reader["startDateTime"] == DBNull.Value ? DateTime.MinValue : Convert.ToDateTime(reader["startDateTime"]);
                        DateTime end = reader["endDateTime"] == DBNull.Value ? DateTime.MinValue : Convert.ToDateTime(reader["endDateTime"]);
                        litMSchedule.Text = start != DateTime.MinValue
                            ? start.ToString("d MMM yyyy, HH:mm") + " - " + (end != DateTime.MinValue ? end.ToString("HH:mm") : "—")
                            : "—";

                        string link = NullSafe(reader["meetingLink"]);
                        litMLink.Text = !string.IsNullOrWhiteSpace(link) ? HttpUtility.HtmlEncode(link) : "—";

                        string status = NullSafe(reader["status"]);
                        litMStatus.Text = string.Format("<span class=\"sb-badge {0}\">{1}</span>",
                            status == "Upcoming" ? "sb-badge-primary" : status == "Completed" ? "sb-badge-success" : "sb-badge-error",
                            HttpUtility.HtmlEncode(status == "Upcoming" ? T("Upcoming", "Akan Datang") : status == "Completed" ? T("Completed", "Selesai") : T("Cancelled", "Dibatalkan")));
                    }
                }

                // Participants
                using (var cmd = new SqlCommand(@"SELECT p.[joinedAt],s.[name],s.[nickname] FROM dbo.[LiveSessionParticipant] p
                    LEFT JOIN dbo.[Student] s ON s.[studentId]=p.[studentId] WHERE p.[sessionId]=@sid ORDER BY p.[joinedAt]", conn))
                {
                    cmd.Parameters.AddWithValue("@sid", sessionId);
                    var da = new SqlDataAdapter(cmd);
                    var dt = new DataTable();
                    da.Fill(dt);

                    litMCount.Text = dt.Rows.Count.ToString();

                    if (dt.Rows.Count == 0)
                    {
                        pnlParticipants.Visible = false;
                        pnlNoParticipants.Visible = true;
                    }
                    else
                    {
                        string[] grads = {
                            "background:linear-gradient(135deg,#4F46E5,#818CF8);",
                            "background:linear-gradient(135deg,#10B981,#34D399);",
                            "background:linear-gradient(135deg,#F59E0B,#FBBF24);",
                            "background:linear-gradient(135deg,#EC4899,#F472B6);"
                        };

                        var list = new List<object>();
                        int idx = 0;
                        foreach (DataRow row in dt.Rows)
                        {
                            string studentName = NullSafe(row["nickname"]);
                            if (string.IsNullOrWhiteSpace(studentName)) studentName = NullSafe(row["name"]);
                            if (string.IsNullOrWhiteSpace(studentName)) studentName = "Student";

                            DateTime joined = row["joinedAt"] == DBNull.Value ? DateTime.MinValue : Convert.ToDateTime(row["joinedAt"]);

                            list.Add(new
                            {
                                studentName = studentName,
                                initials = GetInitials(studentName),
                                joinedStr = joined != DateTime.MinValue ? joined.ToString("HH:mm") : "—",
                                gradient = grads[idx % grads.Length]
                            });
                            idx++;
                        }

                        pnlParticipants.Visible = true;
                        pnlNoParticipants.Visible = false;
                        rptParticipants.DataSource = list;
                        rptParticipants.DataBind();
                    }
                }
            }
            pnlModal.Visible = true;
        }

        // --- Helpers ---

        private string SafeScalar(SqlConnection conn, string sql)
        {
            try
            {
                using (var cmd = new SqlCommand(sql, conn))
                {
                    var result = cmd.ExecuteScalar();
                    return result != null && result != DBNull.Value ? Convert.ToInt32(result).ToString() : "0";
                }
            }
            catch { return "0"; }
        }

        private int SafeInt(SqlConnection conn, string sql)
        {
            try
            {
                using (var cmd = new SqlCommand(sql, conn))
                {
                    var result = cmd.ExecuteScalar();
                    return result != null && result != DBNull.Value ? Convert.ToInt32(result) : 0;
                }
            }
            catch { return 0; }
        }

        private static string NullSafe(object val)
        {
            return (val == null || val == DBNull.Value) ? "" : val.ToString();
        }

        private static string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "S";
            var parts = name.Trim().Split(' ');
            return parts.Length >= 2
                ? (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper()
                : name.Substring(0, Math.Min(2, name.Length)).ToUpper();
        }
    }
}
