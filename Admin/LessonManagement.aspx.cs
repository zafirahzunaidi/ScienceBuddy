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
    public partial class LessonManagement : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        protected string CurrentLanguage => ((ScienceBuddy.SiteMaster)Master).CurrentLanguage;
        protected string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null) { Response.Redirect("~/Login.aspx", false); return; }
            if (Session["role"] == null || Session["role"].ToString() != "Admin") { Response.Redirect("~/Login.aspx", false); return; }
            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            if (!IsPostBack) { SetMasterUser(); LoadDropdowns(); LoadStats(); LoadLessons("", "", ""); }
            txtSearch.Attributes["placeholder"] = T("Search lesson title, subtopic...", "Cari tajuk pelajaran, subtopik...");
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
                string lCol = CurrentLanguage == "BM" ? "levelNameBM" : "levelNameEN";
                ddlLevel.Items.Clear(); ddlLevel.Items.Add(new ListItem(T("All Levels", "Semua Tahap"), ""));
                using (var cmd = new SqlCommand("SELECT [levelId],[levelNameEN],[levelNameBM] FROM dbo.[Level] ORDER BY [levelId]", conn))
                using (var rd = cmd.ExecuteReader()) { while (rd.Read()) ddlLevel.Items.Add(new ListItem(rd[lCol].ToString(), rd["levelId"].ToString())); }

                string uCol = CurrentLanguage == "BM" ? "unitNameBM" : "unitNameEN";
                ddlUnit.Items.Clear(); ddlUnit.Items.Add(new ListItem(T("All Units", "Semua Unit"), ""));
                using (var cmd = new SqlCommand("SELECT [unitId],[unitNameEN],[unitNameBM] FROM dbo.[Unit] ORDER BY [orderNo]", conn))
                using (var rd = cmd.ExecuteReader()) { while (rd.Read()) ddlUnit.Items.Add(new ListItem(rd[uCol].ToString(), rd["unitId"].ToString())); }
            }
        }

        private void LoadStats()
        {
            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                litTotal.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[Lesson]");
                litVideo.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[Lesson] WHERE [attachmentUrl] LIKE '%.mp4'");
                litImage.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[Lesson] WHERE [attachmentUrl] LIKE '%.png' OR [attachmentUrl] LIKE '%.jpg' OR [attachmentUrl] LIKE '%.jpeg'");
                litUnits.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[Unit]");
            }
        }

        private void LoadLessons(string search, string levelF, string unitF)
        {
            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                string tCol = CurrentLanguage == "BM" ? "l.[lessonTitleBM]" : "l.[lessonTitleEN]";
                string stCol = CurrentLanguage == "BM" ? "st.[subtopicTitleBM]" : "st.[subtopicTitleEN]";
                string uCol = CurrentLanguage == "BM" ? "un.[unitNameBM]" : "un.[unitNameEN]";
                string lvCol = CurrentLanguage == "BM" ? "lv.[levelNameBM]" : "lv.[levelNameEN]";

                string sql = string.Format(@"SELECT l.[lessonId], ISNULL({0},l.[lessonTitleEN]) AS title,
                    ISNULL({1},'-') AS subtopic, ISNULL({2},'-') AS unit, ISNULL({3},'-') AS level,
                    l.[attachmentUrl], l.[orderNo], un.[unitId], lv.[levelId]
                    FROM dbo.[Lesson] l
                    LEFT JOIN dbo.[Subtopic] st ON st.[subtopicId]=l.[subtopicId]
                    LEFT JOIN dbo.[Unit] un ON un.[unitId]=st.[unitId]
                    LEFT JOIN dbo.[Level] lv ON lv.[levelId]=un.[levelId]
                    WHERE 1=1", tCol, stCol, uCol, lvCol);

                if (!string.IsNullOrWhiteSpace(search))
                    sql += " AND (l.[lessonTitleEN] LIKE @s OR l.[lessonTitleBM] LIKE @s OR " + stCol + " LIKE @s)";
                if (!string.IsNullOrWhiteSpace(levelF))
                    sql += " AND lv.[levelId]=@lv";
                if (!string.IsNullOrWhiteSpace(unitF))
                    sql += " AND un.[unitId]=@un";
                sql += " ORDER BY un.[orderNo], st.[orderNo], l.[orderNo]";

                using (var cmd = new SqlCommand(sql, conn)) {
                    if (!string.IsNullOrWhiteSpace(search)) cmd.Parameters.AddWithValue("@s", "%" + search + "%");
                    if (!string.IsNullOrWhiteSpace(levelF)) cmd.Parameters.AddWithValue("@lv", levelF);
                    if (!string.IsNullOrWhiteSpace(unitF)) cmd.Parameters.AddWithValue("@un", unitF);
                    var da = new SqlDataAdapter(cmd); var dt = new DataTable(); da.Fill(dt);
                    if (dt.Rows.Count == 0) { pnlLessons.Visible = false; pnlEmpty.Visible = true; return; }

                    var list = new List<object>();
                    foreach (DataRow r in dt.Rows) {
                        string att = NS(r["attachmentUrl"]);
                        string aType = att.EndsWith(".mp4") ? T("Video","Video") : (att.EndsWith(".png") || att.EndsWith(".jpg") || att.EndsWith(".jpeg")) ? T("Image","Imej") : T("None","Tiada");
                        string tCls = att.EndsWith(".mp4") ? "sb-badge-secondary" : att.Contains(".") ? "sb-badge-success" : "sb-badge-gray";
                        list.Add(new { lessonId = r["lessonId"].ToString(), title = NS(r["title"]), subtopic = NS(r["subtopic"]),
                            unit = NS(r["unit"]), level = NS(r["level"]), orderNo = r["orderNo"],
                            attachType = aType, typeCls = tCls });
                    }
                    pnlLessons.Visible = true; pnlEmpty.Visible = false; rptLessons.DataSource = list; rptLessons.DataBind();
                }
            }
        }

        protected void rptLessons_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "ViewLesson") return;
            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                string stCol = CurrentLanguage == "BM" ? "st.[subtopicTitleBM]" : "st.[subtopicTitleEN]";
                string uCol = CurrentLanguage == "BM" ? "un.[unitNameBM]" : "un.[unitNameEN]";
                string lvCol = CurrentLanguage == "BM" ? "lv.[levelNameBM]" : "lv.[levelNameEN]";
                string sql = string.Format(@"SELECT l.*,ISNULL({0},st.[subtopicTitleEN]) AS subtopic,
                    ISNULL({1},un.[unitNameEN]) AS unit,ISNULL({2},lv.[levelNameEN]) AS level
                    FROM dbo.[Lesson] l LEFT JOIN dbo.[Subtopic] st ON st.[subtopicId]=l.[subtopicId]
                    LEFT JOIN dbo.[Unit] un ON un.[unitId]=st.[unitId] LEFT JOIN dbo.[Level] lv ON lv.[levelId]=un.[levelId]
                    WHERE l.[lessonId]=@id", stCol, uCol, lvCol);
                using (var cmd = new SqlCommand(sql, conn)) { cmd.Parameters.AddWithValue("@id", e.CommandArgument.ToString());
                    using (var rd = cmd.ExecuteReader()) { if (!rd.Read()) return;
                        litMTitleEN.Text = HttpUtility.HtmlEncode(NS(rd["lessonTitleEN"]));
                        litMTitleBM.Text = HttpUtility.HtmlEncode(NS(rd["lessonTitleBM"]));
                        litMContentEN.Text = NS(rd["lessonContentEN"]).Replace("\n", "<br/>");
                        litMContentBM.Text = NS(rd["lessonContentBM"]).Replace("\n", "<br/>");
                        litMSubtopic.Text = HttpUtility.HtmlEncode(NS(rd["subtopic"]));
                        litMUnit.Text = HttpUtility.HtmlEncode(NS(rd["unit"]));
                        litMLevel.Text = HttpUtility.HtmlEncode(NS(rd["level"]));
                        litMOrder.Text = rd["orderNo"] == DBNull.Value ? "-" : rd["orderNo"].ToString();
                        
                        // Attachment preview
                        string att = NS(rd["attachmentUrl"]);
                        if (!string.IsNullOrEmpty(att))
                        {
                            string resolvedUrl = GetLessonAttachmentPath(att);
                            if (att.EndsWith(".mp4"))
                                litMMedia.Text = string.Format("<video controls style=\"width:100%;max-height:360px;border-radius:12px;background:#000;\"><source src=\"{0}\" type=\"video/mp4\"/>Your browser does not support video.</video>", resolvedUrl);
                            else if (att.EndsWith(".png") || att.EndsWith(".jpg") || att.EndsWith(".jpeg"))
                                litMMedia.Text = string.Format("<img src=\"{0}\" alt=\"Lesson\" style=\"width:100%;max-height:360px;object-fit:contain;border-radius:12px;background:#F1F5F9;\"/>", resolvedUrl);
                            else
                                litMMedia.Text = "<p style='color:var(--color-text-muted);font-size:.875rem;text-align:center;padding:var(--space-lg);'>" + HttpUtility.HtmlEncode(att) + "</p>";
                            litMAttachType.Text = att.EndsWith(".mp4") ? T("Video", "Video") : T("Image", "Imej");
                        }
                        else
                        {
                            litMMedia.Text = "<p style='color:var(--color-text-muted);font-size:.875rem;text-align:center;padding:var(--space-xl);'>" + T("No attachment", "Tiada lampiran") + "</p>";
                            litMAttachType.Text = T("None", "Tiada");
                        }
                    }
                }
            }
            pnlModal.Visible = true;
        }

        protected void btnCloseModal_Click(object sender, EventArgs e) { pnlModal.Visible = false; }
        protected void btnSearch_Click(object sender, EventArgs e) { LoadLessons(txtSearch.Text.Trim(), ddlLevel.SelectedValue, ddlUnit.SelectedValue); }
        protected void btnReset_Click(object sender, EventArgs e) { txtSearch.Text = ""; ddlLevel.SelectedIndex = 0; ddlUnit.SelectedIndex = 0; LoadLessons("", "", ""); }

        private string SS(SqlConnection c, string sql) { try { using (var cmd = new SqlCommand(sql, c)) { var v = cmd.ExecuteScalar(); return v != null && v != DBNull.Value ? Convert.ToInt32(v).ToString() : "0"; } } catch { return "0"; } }
        private static string NS(object v) { return (v == null || v == DBNull.Value) ? "" : v.ToString(); }

        /// <summary>Resolves lesson attachment path. Files are stored in ~/Images/Lesson/</summary>
        private string GetLessonAttachmentPath(string fileName)
        {
            if (string.IsNullOrWhiteSpace(fileName)) return "";
            if (fileName.StartsWith("Images/") || fileName.StartsWith("~/"))
                return ResolveUrl("~/" + fileName.TrimStart('~', '/'));
            return ResolveUrl("~/Images/Lesson/" + fileName);
        }
    }
}
