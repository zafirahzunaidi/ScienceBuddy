using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace ScienceBuddy.Student
{
    public partial class Lesson1 : Page
    {
        private string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString; }
        }

        public string CurrentLanguage = "EN";

        public string T(string en, string bm)
        {
            if (CurrentLanguage == "BM")
            {
                return bm;
            }
            return en;
        }

        private string _studentId, _unitId, _subtopicId;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null || Session["role"].ToString() != "Student")
            {
                Response.Redirect("~/Login.aspx", false);
                return;
            }

            ((SiteMaster)Master).LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                InitLang();
                LoadPage();
            }
            else
            {
                InitLang();
            }
        }

        private void InitLang()
        {
            string lang = Session["preferredLanguage"] as string;
            if (!string.IsNullOrEmpty(lang))
            {
                CurrentLanguage = lang;
                return;
            }

            string uid = Session["userId"] as string;
            if (!string.IsNullOrEmpty(uid))
            {
                try
                {
                    using (SqlConnection connection = new SqlConnection(ConnStr))
                    using (SqlCommand command = new SqlCommand("SELECT preferredLanguage FROM [User] WHERE userId=@u", connection))
                    {
                        command.Parameters.AddWithValue("@u", uid);
                        connection.Open();
                        object result = command.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            lang = result.ToString();
                            Session["preferredLanguage"] = lang;
                            CurrentLanguage = lang;
                            return;
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("Error: " + ex.Message);
                }
            }

            CurrentLanguage = "EN";
            Session["preferredLanguage"] = "EN";
        }

        private void LoadPage()
        {
            string lessonId = Request.QueryString["lessonId"];
            string userId = Session["userId"].ToString();
            if (string.IsNullOrEmpty(lessonId) || !Tbl("Lesson") || !Tbl("Student"))
            {
                ShowLocked(T("Invalid", "Tidak sah"), T("No lesson specified.", "Tiada pelajaran dinyatakan."));
                return;
            }

            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();
                string curLevel = "LV001";
                using (SqlCommand command = new SqlCommand("SELECT studentId,currentlevelId FROM Student WHERE userId=@u", connection))
                {
                    command.Parameters.AddWithValue("@u", userId);
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            _studentId = reader["studentId"].ToString();
                            string levelValue = "";
                            if (reader["currentlevelId"] != null && reader["currentlevelId"] != DBNull.Value)
                            {
                                levelValue = reader["currentlevelId"].ToString();
                            }
                            if (!string.IsNullOrEmpty(levelValue))
                            {
                                curLevel = levelValue;
                            }
                            else
                            {
                                curLevel = "LV001";
                            }
                        }
                    }
                }

                if (string.IsNullOrEmpty(_studentId))
                {
                    ShowLocked(T("Not found", "Tidak dijumpai"), T("Student profile missing.", "Profil pelajar tiada."));
                    return;
                }

                bool bm = CurrentLanguage == "BM";
                DataTable dataTable = new DataTable();
                const string sql = @"SELECT ls.lessonId, ls.lessonTitleEN, ls.lessonTitleBM, ls.lessonContentEN, ls.lessonContentBM,
                    ls.attachmentUrl, ls.subtopicId, st.subtopicTitleEN, st.subtopicTitleBM, st.unitId,
                    u.unitNameEN, u.unitNameBM, u.levelId, l.levelNameEN, l.levelNameBM
                    FROM Lesson ls JOIN Subtopic st ON st.subtopicId=ls.subtopicId
                    JOIN Unit u ON u.unitId=st.unitId JOIN Level l ON l.levelId=u.levelId
                    WHERE ls.lessonId=@lid";
                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    command.Parameters.AddWithValue("@lid", lessonId);
                    new SqlDataAdapter(command).Fill(dataTable);
                }

                if (dataTable.Rows.Count == 0)
                {
                    ShowLocked(T("Lesson not found", "Pelajaran tidak dijumpai"), T("This lesson does not exist.", "Pelajaran ini tidak wujud."));
                    return;
                }

                DataRow row = dataTable.Rows[0];
                string levelId = row["levelId"].ToString();
                if (Ord(levelId) > Ord(curLevel))
                {
                    ShowLocked(T("Lesson Locked", "Pelajaran Dikunci"), T("Complete your current level to access this lesson.", "Selesaikan tahap semasa untuk akses pelajaran ini."));
                    return;
                }

                _unitId = row["unitId"].ToString();
                _subtopicId = row["subtopicId"].ToString();

                string title;
                if (bm)
                {
                    title = row["lessonTitleBM"].ToString();
                }
                else
                {
                    title = row["lessonTitleEN"].ToString();
                }
                if (string.IsNullOrWhiteSpace(title))
                {
                    title = row["lessonTitleEN"].ToString();
                }

                string stTitle;
                if (bm)
                {
                    stTitle = row["subtopicTitleBM"].ToString();
                }
                else
                {
                    stTitle = row["subtopicTitleEN"].ToString();
                }
                if (string.IsNullOrWhiteSpace(stTitle))
                {
                    stTitle = row["subtopicTitleEN"].ToString();
                }

                string uName;
                if (bm)
                {
                    uName = row["unitNameBM"].ToString();
                }
                else
                {
                    uName = row["unitNameEN"].ToString();
                }
                if (string.IsNullOrWhiteSpace(uName))
                {
                    uName = row["unitNameEN"].ToString();
                }

                string lName;
                if (bm)
                {
                    lName = row["levelNameBM"].ToString();
                }
                else
                {
                    lName = row["levelNameEN"].ToString();
                }
                if (string.IsNullOrWhiteSpace(lName))
                {
                    lName = row["levelNameEN"].ToString();
                }

                litPageTitle.Text = HttpUtility.HtmlEncode(title);
                litTitle.Text = HttpUtility.HtmlEncode(title);
                litCrumb.Text = HttpUtility.HtmlEncode(lName + " \u203A " + uName + " \u203A " + stTitle);
                litBack.Text = T("Back to Unit", "Kembali ke Unit");
                lnkBack.NavigateUrl = ResolveUrl("~/Student/UnitDetails.aspx?unitId=" + _unitId);

                string content;
                if (bm)
                {
                    content = row["lessonContentBM"].ToString();
                }
                else
                {
                    content = row["lessonContentEN"].ToString();
                }
                if (string.IsNullOrWhiteSpace(content))
                {
                    content = row["lessonContentEN"].ToString();
                }
                litContent.Text = content;

                bool isDone = false;
                if (Tbl("LessonProgress"))
                {
                    using (SqlCommand command = new SqlCommand("SELECT COUNT(*) FROM LessonProgress WHERE studentId=@s AND lessonId=@l AND isCompleted=1", connection))
                    {
                        command.Parameters.AddWithValue("@s", _studentId);
                        command.Parameters.AddWithValue("@l", lessonId);
                        isDone = (int)command.ExecuteScalar() > 0;
                    }
                }
                SetCompletionUI(isDone);

                string attach = "";
                if (row["attachmentUrl"] != null && row["attachmentUrl"] != DBNull.Value)
                {
                    attach = row["attachmentUrl"].ToString();
                }

                litAttachHd.Text = T("Attachment", "Lampiran");
                if (!string.IsNullOrWhiteSpace(attach))
                {
                    pnlAttach.Visible = true;
                    pnlAttachEmpty.Visible = false;
                    litAttachName.Text = HttpUtility.HtmlEncode(System.IO.Path.GetFileName(attach));
                    lnkAttach.NavigateUrl = attach;
                    litAttachBtn.Text = T("Open", "Buka");
                }
                else
                {
                    pnlAttach.Visible = false;
                    pnlAttachEmpty.Visible = true;
                    litAttachEmpty.Text = T("No lesson attachment is available.", "Tiada lampiran pelajaran tersedia.");
                }

                LoadMaterials(connection);
                litTTSStart.Text = T("Read Aloud", "Baca Kuat");
            }
        }

        private void SetCompletionUI(bool done)
        {
            if (done)
            {
                litCompleteTitle.Text = T("Lesson Completed!", "Pelajaran Selesai!");
                litCompleteSub.Text = T("You have already completed this lesson.", "Anda telah menyelesaikan pelajaran ini.");
                btnComplete.Text = T("\u2713 Completed", "\u2713 Selesai");
                btnComplete.Enabled = false;
                btnComplete.CssClass = "sb-btn sb-btn-success sb-btn-sm";
                completeIcon.Style["background"] = "#DCFCE7";
                completeIcon.Style["color"] = "#15803D";
                heroBadgeDiv.Attributes["class"] = "st-lesson-hero-badge st-lesson-badge-done";
                heroBadgeIcon.Attributes["class"] = "bi bi-check-circle-fill";
                litBadgeText.Text = T("Completed", "Selesai");
            }
            else
            {
                litCompleteTitle.Text = T("Finish reading?", "Selesai membaca?");
                litCompleteSub.Text = T("Mark this lesson as complete to track your progress.", "Tandakan pelajaran ini selesai untuk mengesan kemajuan anda.");
                btnComplete.Text = T("Mark as Complete", "Tandakan Selesai");
                btnComplete.Enabled = true;
                btnComplete.CssClass = "sb-btn sb-btn-orange sb-btn-sm";
                completeIcon.Style["background"] = "#FFF0E8";
                completeIcon.Style["color"] = "#FF6B2C";
                heroBadgeDiv.Attributes["class"] = "st-lesson-hero-badge st-lesson-badge-pending";
                heroBadgeIcon.Attributes["class"] = "bi bi-clock";
                litBadgeText.Text = T("Not Completed", "Belum Selesai");
            }
        }

        private void LoadMaterials(SqlConnection conn)
        {
            litMatHd.Text = T("Teacher Materials", "Bahan Guru");
            litMatsEmpty.Text = T("No extra materials are available for this lesson yet.", "Tiada bahan tambahan tersedia untuk pelajaran ini buat masa ini.");

            if (!Tbl("Material") || string.IsNullOrEmpty(_subtopicId))
            {
                pnlMats.Visible = false;
                pnlMatsEmpty.Visible = true;
                return;
            }

            DataTable dataTable = new DataTable();
            using (SqlCommand command = new SqlCommand("SELECT materialTitle,materialType,language,fileUrl FROM Material WHERE subtopicId=@s AND status='Approved'", conn))
            {
                command.Parameters.AddWithValue("@s", _subtopicId);
                new SqlDataAdapter(command).Fill(dataTable);
            }

            if (dataTable.Rows.Count == 0)
            {
                pnlMats.Visible = false;
                pnlMatsEmpty.Visible = true;
                return;
            }

            List<object> list = new List<object>();
            foreach (DataRow r in dataTable.Rows)
            {
                string fileUrl = "";
                if (r["fileUrl"] != null && r["fileUrl"] != DBNull.Value)
                {
                    fileUrl = r["fileUrl"].ToString();
                }
                else
                {
                    fileUrl = "#";
                }

                list.Add(new
                {
                    Title = HttpUtility.HtmlEncode(r["materialTitle"].ToString()),
                    Type = r["materialType"].ToString(),
                    Lang = r["language"].ToString(),
                    Url = fileUrl,
                    Btn = T("Open", "Buka")
                });
            }

            pnlMats.Visible = true;
            pnlMatsEmpty.Visible = false;
            rptMats.DataSource = list;
            rptMats.DataBind();
        }

        protected void btnComplete_Click(object sender, EventArgs e)
        {
            InitLang();
            string lessonId = Request.QueryString["lessonId"];
            string userId = Session["userId"].ToString();
            if (string.IsNullOrEmpty(lessonId))
            {
                return;
            }

            using (SqlConnection connection = new SqlConnection(ConnStr))
            {
                connection.Open();
                string studentId = null;
                using (SqlCommand command = new SqlCommand("SELECT studentId FROM Student WHERE userId=@u", connection))
                {
                    command.Parameters.AddWithValue("@u", userId);
                    object result = command.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        studentId = result.ToString();
                    }
                }
                if (string.IsNullOrEmpty(studentId))
                {
                    return;
                }

                bool already = false;
                if (Tbl("LessonProgress"))
                {
                    using (SqlCommand command = new SqlCommand("SELECT COUNT(*) FROM LessonProgress WHERE studentId=@s AND lessonId=@l AND isCompleted=1", connection))
                    {
                        command.Parameters.AddWithValue("@s", studentId);
                        command.Parameters.AddWithValue("@l", lessonId);
                        already = (int)command.ExecuteScalar() > 0;
                    }
                }

                if (!already && Tbl("LessonProgress"))
                {
                    string progId = "LP001";
                    using (SqlCommand seqCmd = new SqlCommand(@"SELECT ISNULL(MAX(CAST(SUBSTRING(progressId,3,LEN(progressId)-2) AS INT)),0) FROM LessonProgress WHERE progressId LIKE 'LP[0-9]%'", connection))
                    {
                        int last = Convert.ToInt32(seqCmd.ExecuteScalar());
                        progId = "LP" + (last + 1).ToString("D3");
                    }

                    using (SqlCommand command = new SqlCommand(@"INSERT INTO LessonProgress(progressId,studentId,lessonId,isCompleted,completedDate) VALUES(@pid,@s,@l,1,@d)", connection))
                    {
                        command.Parameters.AddWithValue("@pid", progId);
                        command.Parameters.AddWithValue("@s", studentId);
                        command.Parameters.AddWithValue("@l", lessonId);
                        command.Parameters.AddWithValue("@d", DateTime.Now);
                        command.ExecuteNonQuery();
                    }

                    AwardXP(connection, studentId, lessonId);
                }

                SetCompletionUI(true);
                pnlSuccess.Visible = true;
                litSuccess.Text = T("Lesson marked as complete! Keep going!", "Pelajaran ditandakan selesai! Teruskan!");
            }
        }

        private void AwardXP(SqlConnection conn, string studentId, string lessonId)
        {
            try
            {
                if (!Tbl("XPAction") || !Tbl("XPTransaction"))
                {
                    return;
                }

                string xpActionId = null;
                using (SqlCommand command = new SqlCommand("SELECT TOP 1 xpActionId FROM XPAction WHERE actionNameEN LIKE '%Lesson%'", conn))
                {
                    object result = command.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        xpActionId = result.ToString();
                    }
                }
                if (string.IsNullOrEmpty(xpActionId))
                {
                    return;
                }

                int xpAmount = 10;
                string xtId = "XT001";
                using (SqlCommand command = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING(xpTransactionId,3,LEN(xpTransactionId)-2) AS INT)),0) FROM XPTransaction WHERE xpTransactionId LIKE 'XT[0-9]%'", conn))
                {
                    int last = Convert.ToInt32(command.ExecuteScalar());
                    xtId = "XT" + (last + 1).ToString("D3");
                }

                using (SqlCommand command = new SqlCommand("INSERT INTO XPTransaction(xpTransactionId,studentId,xpActionId,xpAmount,dateEarned) VALUES(@id,@s,@a,@xp,@dt)", conn))
                {
                    command.Parameters.AddWithValue("@id", xtId);
                    command.Parameters.AddWithValue("@s", studentId);
                    command.Parameters.AddWithValue("@a", xpActionId);
                    command.Parameters.AddWithValue("@xp", xpAmount);
                    command.Parameters.AddWithValue("@dt", DateTime.Today);
                    command.ExecuteNonQuery();
                }

                using (SqlCommand command = new SqlCommand("UPDATE Student SET XP = ISNULL(XP,0) + @xp WHERE studentId=@s", conn))
                {
                    command.Parameters.AddWithValue("@xp", xpAmount);
                    command.Parameters.AddWithValue("@s", studentId);
                    command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error: " + ex.Message);
            }
        }

        private void ShowLocked(string t, string d)
        {
            pnlLocked.Visible = true;
            pnlMain.Visible = false;
            litLockedTitle.Text = t;
            litLockedDesc.Text = d;
            litLockedBtn.Text = T("Back", "Kembali");
        }

        private static int Ord(string id)
        {
            switch (id)
            {
                case "LV001": return 1;
                case "LV002": return 2;
                case "LV003": return 3;
                default: return 0;
            }
        }

        private bool Tbl(string t)
        {
            using (SqlConnection connection = new SqlConnection(ConnStr))
            using (SqlCommand command = new SqlCommand("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME=@t AND TABLE_TYPE='BASE TABLE'", connection))
            {
                command.Parameters.AddWithValue("@t", t);
                connection.Open();
                return (int)command.ExecuteScalar() > 0;
            }
        }
    }
}
