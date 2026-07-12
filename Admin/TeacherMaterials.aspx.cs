using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace ScienceBuddy.Admin
{
    public partial class TeacherMaterials : Page
    {
        private bool _isAjax = false;

        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected string CurrentLanguage =>
            ((ScienceBuddy.SiteMaster)Master).CurrentLanguage;

        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        protected override void Render(HtmlTextWriter writer)
        {
            if (!_isAjax)
                base.Render(writer);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // AJAX handler
            if (Request.QueryString["handler"] == "MaterialAction" && Request.HttpMethod == "POST")
            {
                _isAjax = true;
                HandleAction();
                return;
            }

            if (Session["userId"] == null || Session["role"] == null || Session["role"].ToString() != "Admin")
            {
                Response.Redirect("~/Login.aspx", false); return;
            }

            var master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                LoadStats();
                LoadMaterials();
                SetUserInfo();
            }
        }

        private void SetUserInfo()
        {
            string userId = Session["userId"].ToString();
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [username] FROM dbo.[User] WHERE [userId]=@uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    var val = cmd.ExecuteScalar();
                    string name = val != null && val != DBNull.Value ? val.ToString() : "Admin";
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
                litPending.Text = SafeCount(conn, "SELECT COUNT(*) FROM dbo.[Material] WHERE [status]='Pending'").ToString();
                litApproved.Text = SafeCount(conn, "SELECT COUNT(*) FROM dbo.[Material] WHERE [status]='Approved'").ToString();
                litRejected.Text = SafeCount(conn, "SELECT COUNT(*) FROM dbo.[Material] WHERE [status]='Rejected'").ToString();
                litTotal.Text = SafeCount(conn, "SELECT COUNT(*) FROM dbo.[Material]").ToString();
            }
        }

        private void LoadMaterials()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                const string sql = @"
                    SELECT m.[materialId], m.[materialTitle], m.[materialType], m.[fileUrl],
                           m.[materialContent], m.[createdDate], m.[status], m.[reviewedDate],
                           m.[language], m.[subtopicId],
                           ISNULL(t.[name], u.[username]) AS teacherName,
                           ISNULL(st.[subtopicTitleEN], '') AS subtopicEN,
                           ISNULL(st.[subtopicTitleBM], '') AS subtopicBM
                    FROM dbo.[Material] m
                    LEFT JOIN dbo.[User] u ON u.[userId] = m.[createdByUserId]
                    LEFT JOIN dbo.[Teacher] t ON t.[userId] = m.[createdByUserId]
                    LEFT JOIN dbo.[Subtopic] st ON st.[subtopicId] = m.[subtopicId]
                    ORDER BY 
                        CASE WHEN m.[status]='Pending' THEN 0 WHEN m.[status]='Approved' THEN 1 ELSE 2 END,
                        m.[createdDate] DESC";

                using (var cmd = new SqlCommand(sql, conn))
                {
                    var da = new SqlDataAdapter(cmd);
                    var dt = new DataTable();
                    da.Fill(dt);

                    var list = new List<object>();
                    foreach (DataRow row in dt.Rows)
                    {
                        string matId = row["materialId"].ToString();
                        string title = row["materialTitle"] != DBNull.Value ? row["materialTitle"].ToString() : "";
                        string type = row["materialType"] != DBNull.Value ? row["materialType"].ToString() : "";
                        string fileUrl = row["fileUrl"] != DBNull.Value ? row["fileUrl"].ToString() : "";
                        string status = row["status"] != DBNull.Value ? row["status"].ToString() : "";
                        string lang = row["language"] != DBNull.Value ? row["language"].ToString() : "";
                        string teacher = row["teacherName"] != DBNull.Value ? row["teacherName"].ToString() : "-";
                        string subtopicEN = row["subtopicEN"] != DBNull.Value ? row["subtopicEN"].ToString() : "";
                        string subtopicBM = row["subtopicBM"] != DBNull.Value ? row["subtopicBM"].ToString() : "";
                        string subtopic = CurrentLanguage == "BM" && !string.IsNullOrEmpty(subtopicBM) ? subtopicBM : subtopicEN;
                        DateTime createdDate = row["createdDate"] != DBNull.Value ? Convert.ToDateTime(row["createdDate"]) : DateTime.MinValue;
                        string reviewedDate = row["reviewedDate"] != DBNull.Value ? Convert.ToDateTime(row["reviewedDate"]).ToString("dd MMM yyyy") : "";

                        // Build JSON for JS (using double-quoted strings)
                        string json = "{" +
                            "\"id\":\"" + EscapeJson(matId) + "\"," +
                            "\"title\":\"" + EscapeJson(title) + "\"," +
                            "\"type\":\"" + EscapeJson(type) + "\"," +
                            "\"fileUrl\":\"" + EscapeJson(ResolveUrl("~/" + fileUrl)) + "\"," +
                            "\"status\":\"" + EscapeJson(status) + "\"," +
                            "\"lang\":\"" + EscapeJson(lang) + "\"," +
                            "\"teacher\":\"" + EscapeJson(teacher) + "\"," +
                            "\"subtopic\":\"" + EscapeJson(subtopic) + "\"," +
                            "\"date\":\"" + (createdDate != DateTime.MinValue ? createdDate.ToString("dd MMM yyyy") : "-") + "\"," +
                            "\"reviewed\":\"" + EscapeJson(reviewedDate) + "\"" +
                            "}";

                        list.Add(new
                        {
                            materialId = matId,
                            materialTitle = title,
                            materialType = type,
                            fileUrl = fileUrl,
                            status = status,
                            language = lang,
                            teacherName = teacher,
                            subtopicName = subtopic,
                            createdDateStr = createdDate != DateTime.MinValue ? createdDate.ToString("dd MMM yyyy") : "-",
                            sortDate = createdDate.ToString("yyyy-MM-dd"),
                            jsonData = json
                        });
                    }

                    rptMaterials.DataSource = list;
                    rptMaterials.DataBind();
                }
            }
        }

        // ── AJAX Action Handler ──
        private void HandleAction()
        {
            Response.Clear();
            Response.ContentType = "application/json";
            try
            {
                if (Session["userId"] == null || Session["role"]?.ToString() != "Admin")
                {
                    Response.Write("{\"success\":false,\"error\":\"Unauthorized\"}");
                }
                else
                {
                    string action = Request.QueryString["action"] ?? "";
                    string matId  = Request.QueryString["matId"]  ?? "";
                    string reason = Request.QueryString["reason"] ?? "";
                    string userId = Session["userId"].ToString();

                    using (var conn = new SqlConnection(ConnStr))
                    {
                        conn.Open();

                        // Get material info for logging/notification
                        string matTitle       = "";
                        string teacherUserId  = "";
                        using (var cmd = new SqlCommand("SELECT [materialTitle],[createdByUserId] FROM dbo.[Material] WHERE [materialId]=@id", conn))
                        {
                            cmd.Parameters.AddWithValue("@id", matId);
                            using (var r = cmd.ExecuteReader())
                            {
                                if (r.Read())
                                {
                                    matTitle      = r["materialTitle"]?.ToString()      ?? "";
                                    teacherUserId = r["createdByUserId"]?.ToString()    ?? "";
                                }
                            }
                        }

                        switch (action)
                        {
                            case "approve":
                                using (var cmd = new SqlCommand("UPDATE dbo.[Material] SET [status]='Approved',[reviewedDate]=@dt WHERE [materialId]=@id", conn))
                                {
                                    cmd.Parameters.AddWithValue("@dt", DateTime.Now);
                                    cmd.Parameters.AddWithValue("@id", matId);
                                    cmd.ExecuteNonQuery();
                                }
                                InsertLog(conn, userId, "Teacher Material Approved", "Approved material " + matId + " (" + matTitle + ") uploaded by " + teacherUserId + ".", "Success");
                                InsertNotification(conn, teacherUserId, "Material Approved", "Bahan Diluluskan",
                                    "Your material \"" + matTitle + "\" has been approved by the administrator.",
                                    "Bahan anda \"" + matTitle + "\" telah diluluskan oleh pentadbir.");
                                break;

                            case "reject":
                                using (var cmd = new SqlCommand("UPDATE dbo.[Material] SET [status]='Rejected',[reviewedDate]=@dt WHERE [materialId]=@id", conn))
                                {
                                    cmd.Parameters.AddWithValue("@dt", DateTime.Now);
                                    cmd.Parameters.AddWithValue("@id", matId);
                                    cmd.ExecuteNonQuery();
                                }
                                InsertLog(conn, userId, "Teacher Material Rejected", "Rejected material " + matId + " (" + matTitle + "). Reason: " + reason, "Success");
                                InsertNotification(conn, teacherUserId, "Material Rejected", "Bahan Ditolak",
                                    "Your material \"" + matTitle + "\" has been rejected. Reason: " + reason,
                                    "Bahan anda \"" + matTitle + "\" telah ditolak. Alasan: " + reason);
                                break;

                            case "reconsider":
                                using (var cmd = new SqlCommand("UPDATE dbo.[Material] SET [status]='Pending',[reviewedDate]=NULL WHERE [materialId]=@id", conn))
                                {
                                    cmd.Parameters.AddWithValue("@id", matId);
                                    cmd.ExecuteNonQuery();
                                }
                                InsertLog(conn, userId, "Teacher Material Reconsidered", "Reconsidered material " + matId + " (" + matTitle + ") - set back to Pending.", "Success");
                                break;

                            case "view":
                                InsertLog(conn, userId, "Viewed Material", "Viewed material " + matId + ".", "Success");
                                break;
                        }
                    }

                    Response.Write("{\"success\":true}");
                }
            }
            catch (Exception ex)
            {
                Response.Clear();
                Response.Write("{\"success\":false,\"error\":\"" + EscapeJson(ex.Message) + "\"}");
            }
            Response.Flush();
            HttpContext.Current.ApplicationInstance.CompleteRequest();
        }

        // ── Helpers called from ASPX ──
        protected string GetPreviewClass(object materialType)
        {
            string t = (materialType?.ToString() ?? "").ToLower();
            if (t.Contains("pdf")) return "pdf";
            if (t.Contains("video")) return "video";
            if (t.Contains("image")) return "image";
            if (t.Contains("pptx") || t.Contains("powerpoint")) return "pptx";
            return "pdf";
        }

        protected string GetPreviewIcon(object materialType)
        {
            string t = (materialType?.ToString() ?? "").ToLower();
            if (t.Contains("pdf")) return "bi bi-file-earmark-pdf-fill";
            if (t.Contains("video")) return "bi bi-play-circle-fill";
            if (t.Contains("image")) return "bi bi-image-fill";
            if (t.Contains("pptx") || t.Contains("powerpoint")) return "bi bi-file-earmark-ppt-fill";
            return "bi bi-file-earmark-fill";
        }

        protected string GetBadgeClass(object status)
        {
            string s = (status?.ToString() ?? "").ToLower();
            if (s == "pending")  return "ad-material-request-badge-pending";
            if (s == "approved") return "ad-material-request-badge-approved";
            if (s == "rejected") return "ad-material-request-badge-rejected";
            return "ad-material-request-badge-pending";
        }

        protected string GetActionButtons(object status, object materialId)
        {
            string s  = (status?.ToString() ?? "");
            string id = materialId?.ToString() ?? "";
            string html = "";

            if (s == "Pending")
            {
                html += "<a class='ad-material-request-abtn ad-material-request-abtn-approve' href='javascript:;' onclick='approveMaterial(\"" + id + "\")'><i class='bi bi-check-lg'></i> " + T("Approve", "Luluskan") + "</a>";
                html += "<a class='ad-material-request-abtn ad-material-request-abtn-reject' href='javascript:;' onclick='openRejectModal(\"" + id + "\")'><i class='bi bi-x-lg'></i> " + T("Reject", "Tolak") + "</a>";
            }
            else if (s == "Rejected")
            {
                html += "<a class='ad-material-request-abtn ad-material-request-abtn-reconsider' href='javascript:;' onclick='reconsiderMaterial(\"" + id + "\")'><i class='bi bi-arrow-repeat'></i> " + T("Reconsider", "Pertimbang Semula") + "</a>";
            }

            return html;
        }

        private int SafeCount(SqlConnection conn, string sql)
        {
            try { using (var cmd = new SqlCommand(sql, conn)) { var v = cmd.ExecuteScalar(); return v != null && v != DBNull.Value ? Convert.ToInt32(v) : 0; } }
            catch { return 0; }
        }

        private void InsertLog(SqlConnection conn, string userId, string action, string description, string status)
        {
            string logId = GenerateId(conn, "Log", "logId", "LOG");
            using (var cmd = new SqlCommand("INSERT INTO dbo.[Log]([logId],[userId],[action],[description],[logDateTime],[status]) VALUES(@a,@b,@c,@d,@e,@f)", conn))
            {
                cmd.Parameters.AddWithValue("@a", logId);
                cmd.Parameters.AddWithValue("@b", userId);
                cmd.Parameters.AddWithValue("@c", action);
                cmd.Parameters.AddWithValue("@d", description.Length > 900 ? description.Substring(0, 900) : description);
                cmd.Parameters.AddWithValue("@e", DateTime.Now);
                cmd.Parameters.AddWithValue("@f", status);
                cmd.ExecuteNonQuery();
            }
        }

        private void InsertNotification(SqlConnection conn, string toUserId, string titleEN, string titleBM, string msgEN, string msgBM)
        {
            if (string.IsNullOrEmpty(toUserId)) return;
            string nId = GenerateId(conn, "Notification", "notificationId", "N");
            using (var cmd = new SqlCommand("INSERT INTO dbo.[Notification]([notificationId],[toUserId],[titleEN],[titleBM],[messageEN],[messageBM],[isRead],[createdAt]) VALUES(@a,@b,@c,@d,@e,@f,0,@g)", conn))
            {
                cmd.Parameters.AddWithValue("@a", nId);
                cmd.Parameters.AddWithValue("@b", toUserId);
                cmd.Parameters.AddWithValue("@c", titleEN);
                cmd.Parameters.AddWithValue("@d", titleBM);
                cmd.Parameters.AddWithValue("@e", msgEN.Length > 900 ? msgEN.Substring(0, 900) : msgEN);
                cmd.Parameters.AddWithValue("@f", msgBM.Length > 900 ? msgBM.Substring(0, 900) : msgBM);
                cmd.Parameters.AddWithValue("@g", DateTime.Now);
                cmd.ExecuteNonQuery();
            }
        }

        private string GenerateId(SqlConnection conn, string table, string idCol, string prefix)
        {
            string sql = string.Format("SELECT TOP 1 [{0}] FROM dbo.[{1}] ORDER BY [{0}] DESC", idCol, table);
            using (var cmd = new SqlCommand(sql, conn))
            {
                var val = cmd.ExecuteScalar();
                if (val == null || val == DBNull.Value) return prefix + "001";
                string last = val.ToString();
                string numPart = last.Substring(prefix.Length);
                int num; int.TryParse(numPart, out num); num++;
                return prefix + num.ToString().PadLeft(last.Length - prefix.Length, '0');
            }
        }

        private static string EscapeJs(string s)
        {
            if (string.IsNullOrEmpty(s)) return "";
            return s.Replace("\\", "\\\\").Replace("'", "\\'").Replace("\n", "\\n").Replace("\r", "");
        }

        private static string EscapeJson(string s)
        {
            if (string.IsNullOrEmpty(s)) return "";
            return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "");
        }
    }
}
