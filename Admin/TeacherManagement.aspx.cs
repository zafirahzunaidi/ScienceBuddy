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
    public partial class TeacherManagement : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        protected string CurrentLanguage => ((ScienceBuddy.SiteMaster)Master).CurrentLanguage;
        protected string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null) { Response.Redirect("~/Login.aspx", false); return; }
            if (Session["role"] == null || Session["role"].ToString() != "Admin") { Response.Redirect("~/Login.aspx", false); return; }
            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            if (!IsPostBack) { SetMasterUser(); LoadInsights(); LoadTeachers("", "", "", "name"); }
            txtSearch.Attributes["placeholder"] = T("Search teacher name…", "Cari nama guru…");
            btnSearch.Text = T("Search", "Cari"); btnReset.Text = T("Reset", "Tetapkan Semula");
            btnCloseProfile.Text = T("Close", "Tutup");
        }

        private void SetMasterUser()
        {
            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                using (var cmd = new SqlCommand("SELECT [username] FROM dbo.[User] WHERE [userId]=@uid", conn))
                { cmd.Parameters.AddWithValue("@uid", Session["userId"].ToString());
                  var v = cmd.ExecuteScalar(); string n = v != null && v != DBNull.Value ? v.ToString() : "Admin";
                  ((ScienceBuddy.SiteMaster)Master).SetUserInfo(n, "Administrator", n.Length >= 2 ? n.Substring(0,2).ToUpper() : n.ToUpper()); } }
        }

        private void LoadInsights()
        {
            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                litTotal.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[Teacher]");
                litActive.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[Teacher] WHERE [status]='Certified'");
                litLessons.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[Material] m JOIN dbo.[User] u ON u.[userId]=m.[createdByUserId] WHERE u.[role]='Teacher'");
                litQuizzes.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[Quiz] q JOIN dbo.[User] u ON u.[userId]=q.[createdByUserId] WHERE u.[role]='Teacher'");
            }
        }

        private void LoadTeachers(string search, string statusF, string langF, string sort)
        {
            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                string sql = @"SELECT t.[teacherId],t.[name],t.[phoneNumber],t.[academicQualification],t.[status] AS tStatus,
                    u.[username],u.[email],u.[preferredLanguage],
                    (SELECT COUNT(*) FROM dbo.[Material] WHERE [createdByUserId]=t.[userId]) AS matCount,
                    (SELECT COUNT(*) FROM dbo.[Quiz] WHERE [createdByUserId]=t.[userId] AND [quizType]='Practice') AS qzCount
                    FROM dbo.[Teacher] t LEFT JOIN dbo.[User] u ON u.[userId]=t.[userId] WHERE 1=1";
                if (!string.IsNullOrWhiteSpace(search)) sql += " AND (t.[name] LIKE @s OR u.[username] LIKE @s)";
                if (!string.IsNullOrWhiteSpace(statusF)) sql += " AND t.[status]=@st";
                if (!string.IsNullOrWhiteSpace(langF)) sql += " AND u.[preferredLanguage]=@lg";
                sql += sort == "name_desc" ? " ORDER BY t.[name] DESC" : " ORDER BY t.[name] ASC";

                using (var cmd = new SqlCommand(sql, conn)) {
                    if (!string.IsNullOrWhiteSpace(search)) cmd.Parameters.AddWithValue("@s", "%" + search + "%");
                    if (!string.IsNullOrWhiteSpace(statusF)) cmd.Parameters.AddWithValue("@st", statusF);
                    if (!string.IsNullOrWhiteSpace(langF)) cmd.Parameters.AddWithValue("@lg", langF);
                    var da = new SqlDataAdapter(cmd); var dt = new DataTable(); da.Fill(dt);
                    if (dt.Rows.Count == 0) { pnlTeachers.Visible = false; pnlEmpty.Visible = true; return; }
                    string[] grads = {"background:linear-gradient(135deg,#059669,#34D399);","background:linear-gradient(135deg,#0891B2,#22D3EE);","background:linear-gradient(135deg,#7C3AED,#A78BFA);","background:linear-gradient(135deg,#D97706,#FBBF24);","background:linear-gradient(135deg,#EC4899,#F472B6);","background:linear-gradient(135deg,#6366F1,#818CF8);"};
                    var list = new List<object>(); int i = 0;
                    foreach (DataRow r in dt.Rows) {
                        string nm = NS(r["name"]); string un = NS(r["username"]); string d = !string.IsNullOrWhiteSpace(nm) ? nm : un;
                        string st = NS(r["tStatus"]); string lg = NS(r["preferredLanguage"]);
                        list.Add(new { teacherId=r["teacherId"].ToString(), displayName=d, username=un, initials=GI(d),
                            phone=string.IsNullOrWhiteSpace(NS(r["phoneNumber"]))?"-":NS(r["phoneNumber"]),
                            language=lg=="BM"?"BM":"EN", materialsCount=r["matCount"], quizzesCount=r["qzCount"],
                            statusLabel=st=="Certified"?T("Certified","Bertauliah"):st=="Pending"?T("Pending","Menunggu"):T("Not Certified","Tidak Bertauliah"),
                            statusPillClass=st=="Certified"?"tm-pill-certified":st=="Pending"?"tm-pill-pending":"tm-pill-rejected",
                            dotClass=st=="Certified"?"certified":st=="Pending"?"pending":"rejected",
                            gradient=grads[i%grads.Length] }); i++;
                    }
                    pnlTeachers.Visible = true; pnlEmpty.Visible = false; rptTeachers.DataSource = list; rptTeachers.DataBind();
                }
            }
        }

        protected void rptTeachers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string tid = e.CommandArgument.ToString();
            if (e.CommandName == "ViewProfile") ShowProfile(tid);
            else if (e.CommandName == "ViewContent") ShowContent(tid);
        }

        private void ShowProfile(string tid)
        {
            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                using (var cmd = new SqlCommand(@"SELECT t.[name],t.[phoneNumber],t.[academicQualification],t.[status],t.[approvedDate],t.[userId],
                    u.[username],u.[email],u.[preferredLanguage],
                    (SELECT COUNT(*) FROM dbo.[Material] WHERE [createdByUserId]=t.[userId]) AS matCnt,
                    (SELECT COUNT(*) FROM dbo.[Quiz] WHERE [createdByUserId]=t.[userId] AND [quizType]='Practice') AS qzCnt,
                    (SELECT COUNT(*) FROM dbo.[LiveConsultationSession] WHERE [teacherId]=t.[teacherId]) AS sessCnt,
                    (SELECT COUNT(*) FROM dbo.[Material] WHERE [createdByUserId]=t.[userId] AND [status]='Pending')+(SELECT COUNT(*) FROM dbo.[Quiz] WHERE [createdByUserId]=t.[userId] AND [status]='Pending' AND [quizType]='Practice') AS pendCnt
                    FROM dbo.[Teacher] t LEFT JOIN dbo.[User] u ON u.[userId]=t.[userId] WHERE t.[teacherId]=@tid", conn))
                { cmd.Parameters.AddWithValue("@tid", tid);
                    using (var rd = cmd.ExecuteReader()) { if (!rd.Read()) return;
                        string nm = NS(rd["name"]); string un = NS(rd["username"]);
                        litMInitials.Text = GI(!string.IsNullOrWhiteSpace(nm)?nm:un);
                        litMName.Text = HttpUtility.HtmlEncode(!string.IsNullOrWhiteSpace(nm)?nm:un);
                        litMUsername.Text = HttpUtility.HtmlEncode(un);
                        litMEmail.Text = HttpUtility.HtmlEncode(NS(rd["email"]));
                        litMPhone.Text = HttpUtility.HtmlEncode(NS(rd["phoneNumber"]));
                        litMQual.Text = HttpUtility.HtmlEncode(NS(rd["academicQualification"]));
                        string st = NS(rd["status"]);
                        litMStatus.Text = string.Format("<span class=\"sb-badge {0}\">{1}</span>",
                            st=="Certified"?"sb-badge-success":st=="Pending"?"sb-badge-warning":"sb-badge-error",
                            HttpUtility.HtmlEncode(st=="Certified"?T("Certified","Bertauliah"):st=="Pending"?T("Pending","Menunggu"):T("Not Certified","Tidak Bertauliah")));
                        litMLang.Text = NS(rd["preferredLanguage"])=="BM"?"Bahasa Melayu":"English";
                        litMDate.Text = rd["approvedDate"]==DBNull.Value?"-":Convert.ToDateTime(rd["approvedDate"]).ToString("d MMM yyyy");
                        litMMaterials.Text = rd["matCnt"].ToString(); litMQuizzes.Text = rd["qzCnt"].ToString();
                        litMSessions.Text = rd["sessCnt"].ToString(); litMPending.Text = rd["pendCnt"].ToString();
                    }
                }
            }
            pnlProfileModal.Visible = true; pnlContentModal.Visible = false;
        }

        private void ShowContent(string tid)
        {
            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                // Get userId from teacherId
                string userId = "";
                using (var cmd = new SqlCommand("SELECT [userId] FROM dbo.[Teacher] WHERE [teacherId]=@tid", conn))
                { cmd.Parameters.AddWithValue("@tid", tid); var v = cmd.ExecuteScalar(); userId = v != null ? v.ToString() : ""; }
                if (string.IsNullOrEmpty(userId)) { pnlContentList.Visible = false; pnlNoContent.Visible = true; pnlContentModal.Visible = true; pnlProfileModal.Visible = false; return; }

                string sql = @"SELECT 'Material' AS cType, [materialTitle] AS title, [createdDate] AS dt, [status] FROM dbo.[Material] WHERE [createdByUserId]=@uid
                    UNION ALL SELECT 'Practice Quiz', ISNULL([quizTitleEN],[quizTitleBM]), [createdAt], [status] FROM dbo.[Quiz] WHERE [createdByUserId]=@uid AND [quizType]='Practice'
                    ORDER BY dt DESC";
                using (var cmd = new SqlCommand(sql, conn)) { cmd.Parameters.AddWithValue("@uid", userId);
                    var da = new SqlDataAdapter(cmd); var dt2 = new DataTable(); da.Fill(dt2);
                    if (dt2.Rows.Count == 0) { pnlContentList.Visible = false; pnlNoContent.Visible = true; }
                    else {
                        var list = new List<object>();
                        foreach (DataRow r in dt2.Rows) {
                            string s = NS(r["status"]);
                            list.Add(new { contentType=r["cType"].ToString(), title=NS(r["title"]),
                                dateStr=r["dt"]==DBNull.Value?"-":Convert.ToDateTime(r["dt"]).ToString("d MMM yyyy"),
                                statusLabel=s=="Approved"?T("Approved","Diluluskan"):s=="Pending"?T("Pending","Menunggu"):T("Rejected","Ditolak"),
                                statusCls=s=="Approved"?"sb-badge-success":s=="Pending"?"sb-badge-warning":"sb-badge-error",
                                typeCls=r["cType"].ToString()=="Material"?"sb-badge-secondary":"sb-badge-yellow"
                            });
                        }
                        pnlContentList.Visible = true; pnlNoContent.Visible = false;
                        rptContent.DataSource = list; rptContent.DataBind();
                    }
                }
            }
            pnlContentModal.Visible = true; pnlProfileModal.Visible = false;
        }

        protected void btnCloseModal_Click(object sender, EventArgs e) { pnlProfileModal.Visible = false; pnlContentModal.Visible = false; }
        protected void btnSearch_Click(object sender, EventArgs e) { LoadTeachers(txtSearch.Text.Trim(), ddlStatus.SelectedValue, ddlLang.SelectedValue, ddlSort.SelectedValue); }
        protected void btnReset_Click(object sender, EventArgs e) { txtSearch.Text=""; ddlStatus.SelectedIndex=0; ddlLang.SelectedIndex=0; ddlSort.SelectedIndex=0; LoadTeachers("","","","name"); }

        private string SS(SqlConnection c, string sql) { try { using (var cmd = new SqlCommand(sql, c)) { var v = cmd.ExecuteScalar(); return v!=null&&v!=DBNull.Value?Convert.ToInt32(v).ToString():"0"; } } catch { return "0"; } }
        private static string NS(object v) { return (v==null||v==DBNull.Value)?"":v.ToString(); }
        private static string GI(string n) { if (string.IsNullOrWhiteSpace(n)) return "T"; var p=n.Trim().Split(' '); return p.Length>=2?(p[0][0].ToString()+p[p.Length-1][0].ToString()).ToUpper():n.Substring(0,Math.Min(2,n.Length)).ToUpper(); }
    }
}
