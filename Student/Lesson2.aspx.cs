using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace ScienceBuddy.Student
{
    public partial class Lesson : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        public string CurrentLanguage = "EN";
        public string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }

        private string _studentId, _unitId, _subtopicId;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null || Session["role"].ToString() != "Student")
            { Response.Redirect("~/Login.aspx", false); return; }
            ((SiteMaster)Master).LayoutMode = "Sidebar";
            if (!IsPostBack) { InitLang(); LoadPage(); }
            else { InitLang(); } // keep lang available for postback TTS script
        }

        private void InitLang()
        {
            string l = Session["preferredLanguage"] as string;
            if (!string.IsNullOrEmpty(l)) { CurrentLanguage = l; return; }
            string uid = Session["userId"] as string;
            if (!string.IsNullOrEmpty(uid))
            { try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT preferredLanguage FROM [User] WHERE userId=@u", c))
              { cmd.Parameters.AddWithValue("@u", uid); c.Open(); var r = cmd.ExecuteScalar();
                if (r != null && r != DBNull.Value) { l = r.ToString(); Session["preferredLanguage"] = l; CurrentLanguage = l; return; } } } catch {} }
            CurrentLanguage = "EN"; Session["preferredLanguage"] = "EN";
        }

        private void LoadPage()
        {
            string lessonId = Request.QueryString["lessonId"];
            string userId = Session["userId"].ToString();
            if (string.IsNullOrEmpty(lessonId) || !Tbl("Lesson") || !Tbl("Student"))
            { ShowLocked(T("Invalid","Tidak sah"), T("No lesson specified.","Tiada pelajaran dinyatakan.")); return; }

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                // Student info
                string curLevel = "LV001";
                using (var cmd = new SqlCommand("SELECT studentId,currentlevelId FROM Student WHERE userId=@u", conn))
                { cmd.Parameters.AddWithValue("@u", userId);
                  using (var r = cmd.ExecuteReader()) { if (r.Read()) { _studentId = r["studentId"].ToString(); curLevel = r["currentlevelId"]?.ToString() ?? "LV001"; } } }
                if (string.IsNullOrEmpty(_studentId)) { ShowLocked(T("Not found","Tidak dijumpai"), T("Student profile missing.","Profil pelajar tiada.")); return; }

                // Load lesson + joins
                bool bm = CurrentLanguage == "BM";
                DataTable dt = new DataTable();
                const string sql = @"SELECT ls.lessonId, ls.lessonTitleEN, ls.lessonTitleBM, ls.lessonContentEN, ls.lessonContentBM,
                    ls.attachmentUrl, ls.subtopicId, st.subtopicTitleEN, st.subtopicTitleBM, st.unitId,
                    u.unitNameEN, u.unitNameBM, u.levelId, l.levelNameEN, l.levelNameBM
                    FROM Lesson ls JOIN Subtopic st ON st.subtopicId=ls.subtopicId
                    JOIN Unit u ON u.unitId=st.unitId JOIN Level l ON l.levelId=u.levelId
                    WHERE ls.lessonId=@lid";
                using (var cmd = new SqlCommand(sql, conn))
                { cmd.Parameters.AddWithValue("@lid", lessonId); new SqlDataAdapter(cmd).Fill(dt); }

                if (dt.Rows.Count == 0) { ShowLocked(T("Lesson not found","Pelajaran tidak dijumpai"), T("This lesson does not exist.","Pelajaran ini tidak wujud.")); return; }

                var row = dt.Rows[0];
                string levelId = row["levelId"].ToString();
                if (Ord(levelId) > Ord(curLevel)) { ShowLocked(T("Lesson Locked","Pelajaran Dikunci"), T("Complete your current level to access this lesson.","Selesaikan tahap semasa untuk akses pelajaran ini.")); return; }

                _unitId = row["unitId"].ToString();
                _subtopicId = row["subtopicId"].ToString();

                // Hero
                string title = bm ? row["lessonTitleBM"].ToString() : row["lessonTitleEN"].ToString();
                if (string.IsNullOrWhiteSpace(title)) title = row["lessonTitleEN"].ToString();
                string stTitle = bm ? row["subtopicTitleBM"].ToString() : row["subtopicTitleEN"].ToString();
                if (string.IsNullOrWhiteSpace(stTitle)) stTitle = row["subtopicTitleEN"].ToString();
                string uName = bm ? row["unitNameBM"].ToString() : row["unitNameEN"].ToString();
                if (string.IsNullOrWhiteSpace(uName)) uName = row["unitNameEN"].ToString();
                string lName = bm ? row["levelNameBM"].ToString() : row["levelNameEN"].ToString();
                if (string.IsNullOrWhiteSpace(lName)) lName = row["levelNameEN"].ToString();

                litPageTitle.Text = HttpUtility.HtmlEncode(title);
                litTitle.Text = HttpUtility.HtmlEncode(title);
                litCrumb.Text = HttpUtility.HtmlEncode(lName + " › " + uName + " › " + stTitle);
                litBack.Text = T("Back to Unit","Kembali ke Unit");
                lnkBack.NavigateUrl = ResolveUrl("~/Student/UnitDetails.aspx?unitId=" + _unitId);

                // Content
                string content = bm ? row["lessonContentBM"].ToString() : row["lessonContentEN"].ToString();
                if (string.IsNullOrWhiteSpace(content)) content = row["lessonContentEN"].ToString();
                litContent.Text = content; // allow HTML

                // Completion status
                bool isDone = false;
                if (Tbl("LessonProgress"))
                {
                    using (var cmd = new SqlCommand("SELECT COUNT(*) FROM LessonProgress WHERE studentId=@s AND lessonId=@l AND isCompleted=1", conn))
                    { cmd.Parameters.AddWithValue("@s", _studentId); cmd.Parameters.AddWithValue("@l", lessonId); isDone = (int)cmd.ExecuteScalar() > 0; }
                }
                SetCompletionUI(isDone);

                // Attachment
                string attach = row["attachmentUrl"]?.ToString();
                litAttachHd.Text = T("Attachment","Lampiran");
                if (!string.IsNullOrWhiteSpace(attach))
                { pnlAttach.Visible = true; pnlAttachEmpty.Visible = false;
                  litAttachName.Text = HttpUtility.HtmlEncode(System.IO.Path.GetFileName(attach));
                  lnkAttach.NavigateUrl = attach; litAttachBtn.Text = T("Open","Buka"); }
                else { pnlAttach.Visible = false; pnlAttachEmpty.Visible = true;
                  litAttachEmpty.Text = T("No lesson attachment is available.","Tiada lampiran pelajaran tersedia."); }

                // Materials
                LoadMaterials(conn);

                // TTS label
                litTTSStart.Text = T("Read Aloud","Baca Kuat");
            }
        }

        private void SetCompletionUI(bool done)
        {
            if (done)
            {
                litCompleteTitle.Text = T("Lesson Completed! 🎉","Pelajaran Selesai! 🎉");
                litCompleteSub.Text = T("You have already completed this lesson.","Anda telah menyelesaikan pelajaran ini.");
                btnComplete.Text = T("✓ Completed","✓ Selesai");
                btnComplete.Enabled = false;
                btnComplete.CssClass = "sb-btn sb-btn-success sb-btn-sm";
                completeIcon.Style["background"] = "#DCFCE7"; completeIcon.Style["color"] = "#15803D";
                heroBadgeDiv.Attributes["class"]  = "ls-hero-badge ls-badge-done";
                heroBadgeIcon.Attributes["class"] = "bi bi-check-circle-fill";
                litBadgeText.Text = T("Completed","Selesai");
            }
            else
            {
                litCompleteTitle.Text = T("Finish reading?","Selesai membaca?");
                litCompleteSub.Text = T("Mark this lesson as complete to track your progress.","Tandakan pelajaran ini selesai untuk mengesan kemajuan anda.");
                btnComplete.Text = T("Mark as Complete","Tandakan Selesai");
                btnComplete.Enabled = true;
                btnComplete.CssClass = "sb-btn sb-btn-orange sb-btn-sm";
                completeIcon.Style["background"] = "#FFF0E8"; completeIcon.Style["color"] = "#FF6B2C";
                heroBadgeDiv.Attributes["class"]  = "ls-hero-badge ls-badge-pending";
                heroBadgeIcon.Attributes["class"] = "bi bi-clock";
                litBadgeText.Text = T("Not Completed","Belum Selesai");
            }
        }

        private void LoadMaterials(SqlConnection conn)
        {
            litMatHd.Text = T("Teacher Materials","Bahan Guru");
            litMatsEmpty.Text = T("No extra materials are available for this lesson yet.","Tiada bahan tambahan tersedia untuk pelajaran ini buat masa ini.");

            if (!Tbl("Material") || string.IsNullOrEmpty(_subtopicId)) { pnlMats.Visible = false; pnlMatsEmpty.Visible = true; return; }

            var dt = new DataTable();
            using (var cmd = new SqlCommand("SELECT materialTitle,materialType,language,fileUrl FROM Material WHERE subtopicId=@s AND status='Approved'", conn))
            { cmd.Parameters.AddWithValue("@s", _subtopicId); new SqlDataAdapter(cmd).Fill(dt); }

            if (dt.Rows.Count == 0) { pnlMats.Visible = false; pnlMatsEmpty.Visible = true; return; }

            var list = new List<object>();
            foreach (DataRow r in dt.Rows)
                list.Add(new { Title = HttpUtility.HtmlEncode(r["materialTitle"].ToString()),
                    Type = r["materialType"].ToString(), Lang = r["language"].ToString(),
                    Url = r["fileUrl"]?.ToString() ?? "#", Btn = T("Open","Buka") });

            pnlMats.Visible = true; pnlMatsEmpty.Visible = false;
            rptMats.DataSource = list; rptMats.DataBind();
        }

        protected void btnComplete_Click(object sender, EventArgs e)
        {
            InitLang();
            string lessonId = Request.QueryString["lessonId"];
            string userId = Session["userId"].ToString();
            if (string.IsNullOrEmpty(lessonId)) return;

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                // Get studentId
                string studentId = null;
                using (var cmd = new SqlCommand("SELECT studentId FROM Student WHERE userId=@u", conn))
                { cmd.Parameters.AddWithValue("@u", userId); var r = cmd.ExecuteScalar(); studentId = r?.ToString(); }
                if (string.IsNullOrEmpty(studentId)) return;

                // Check if already done
                bool already = false;
                if (Tbl("LessonProgress"))
                {
                    using (var cmd = new SqlCommand("SELECT COUNT(*) FROM LessonProgress WHERE studentId=@s AND lessonId=@l AND isCompleted=1", conn))
                    { cmd.Parameters.AddWithValue("@s", studentId); cmd.Parameters.AddWithValue("@l", lessonId); already = (int)cmd.ExecuteScalar() > 0; }
                }

                if (!already && Tbl("LessonProgress"))
                {
                    // Generate sequential progressId: LP + 3-digit (LP001, LP002...)
                    string progId = "LP001";
                    using (var seqCmd = new SqlCommand(@"SELECT ISNULL(MAX(CAST(SUBSTRING(progressId,3,LEN(progressId)-2) AS INT)),0) FROM LessonProgress WHERE progressId LIKE 'LP[0-9]%'", conn))
                    {
                        int last = Convert.ToInt32(seqCmd.ExecuteScalar());
                        progId = "LP" + (last + 1).ToString("D3");
                    }

                    using (var cmd = new SqlCommand(@"INSERT INTO LessonProgress(progressId,studentId,lessonId,isCompleted,completedDate)
                        VALUES(@pid,@s,@l,1,@d)", conn))
                    {
                        cmd.Parameters.AddWithValue("@pid", progId);
                        cmd.Parameters.AddWithValue("@s", studentId);
                        cmd.Parameters.AddWithValue("@l", lessonId);
                        cmd.Parameters.AddWithValue("@d", DateTime.Now);
                        cmd.ExecuteNonQuery();
                    }

                    // XP reward
                    AwardXP(conn, studentId, lessonId);
                }

                SetCompletionUI(true);
                pnlSuccess.Visible = true;
                litSuccess.Text = T("🎉 Lesson marked as complete! Keep going!","🎉 Pelajaran ditandakan selesai! Teruskan!");
            }
        }

        private void AwardXP(SqlConnection conn, string studentId, string lessonId)
        {
            try
            {
                if (!Tbl("XPAction") || !Tbl("XPTransaction")) return;

                // Find XP action for lesson completion
                string xpActionId = null;
                using (var cmd = new SqlCommand("SELECT TOP 1 xpActionId FROM XPAction WHERE actionNameEN LIKE '%Lesson%'", conn))
                {
                    object r = cmd.ExecuteScalar();
                    if (r != null && r != DBNull.Value) xpActionId = r.ToString();
                }
                if (string.IsNullOrEmpty(xpActionId)) return;

                int xpAmount = 10; // default XP for lesson completion

                // Check duplicate: same student + same action on same day
                using (var cmd = new SqlCommand("SELECT COUNT(*) FROM XPTransaction WHERE studentId=@s AND xpActionId=@a AND dateEarned=@d", conn))
                {
                    cmd.Parameters.AddWithValue("@s", studentId);
                    cmd.Parameters.AddWithValue("@a", xpActionId);
                    cmd.Parameters.AddWithValue("@d", DateTime.Today);
                    // Allow multiple lesson completions per day, skip duplicate check
                }

                // Generate sequential xpTransactionId: XT + 3-digit (XT001, XT002...)
                string xtId = "XT001";
                using (var cmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING(xpTransactionId,3,LEN(xpTransactionId)-2) AS INT)),0) FROM XPTransaction WHERE xpTransactionId LIKE 'XT[0-9]%'", conn))
                {
                    int last = Convert.ToInt32(cmd.ExecuteScalar());
                    xtId = "XT" + (last + 1).ToString("D3");
                }

                // Insert XPTransaction (columns: xpTransactionId, studentId, xpActionId, xpAmount, dateEarned)
                using (var cmd = new SqlCommand("INSERT INTO XPTransaction(xpTransactionId,studentId,xpActionId,xpAmount,dateEarned) VALUES(@id,@s,@a,@xp,@dt)", conn))
                {
                    cmd.Parameters.AddWithValue("@id", xtId);
                    cmd.Parameters.AddWithValue("@s", studentId);
                    cmd.Parameters.AddWithValue("@a", xpActionId);
                    cmd.Parameters.AddWithValue("@xp", xpAmount);
                    cmd.Parameters.AddWithValue("@dt", DateTime.Today);
                    cmd.ExecuteNonQuery();
                }

                // Update Student.XP
                using (var cmd = new SqlCommand("UPDATE Student SET XP = ISNULL(XP,0) + @xp WHERE studentId=@s", conn))
                { cmd.Parameters.AddWithValue("@xp", xpAmount); cmd.Parameters.AddWithValue("@s", studentId); cmd.ExecuteNonQuery(); }
            }
            catch { /* Do not crash lesson completion if XP award fails */ }
        }

        private void ShowLocked(string t, string d)
        { pnlLocked.Visible = true; pnlMain.Visible = false; litLockedTitle.Text = t; litLockedDesc.Text = d; litLockedBtn.Text = T("Back","Kembali"); }

        private static int Ord(string id) { switch (id) { case "LV001": return 1; case "LV002": return 2; case "LV003": return 3; default: return 0; } }
        private bool Tbl(string t) { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME=@t AND TABLE_TYPE='BASE TABLE'", c)) { cmd.Parameters.AddWithValue("@t", t); c.Open(); return (int)cmd.ExecuteScalar() > 0; } }
    }
}
