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
        private string ConnectionString
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
                    using (SqlConnection connection = new SqlConnection(ConnectionString))
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
            if (string.IsNullOrEmpty(lessonId) || !TableExists("Lesson") || !TableExists("Student"))
            {
                ShowLocked(T("Invalid", "Tidak sah"), T("No lesson specified.", "Tiada pelajaran dinyatakan."));
                return;
            }

            using (SqlConnection connection = new SqlConnection(ConnectionString))
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
                if (TableExists("LessonProgress"))
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
                    string resolvedAttach = ResolveUrl("~/Images/Lesson/" + attach);
                    string ext = System.IO.Path.GetExtension(attach).ToLower();

                    if (ext == ".mp4" || ext == ".webm" || ext == ".ogg")
                    {
                        litAttachInline.Text = "<video controls style=\"width:100%;max-height:400px;border-radius:8px;\">" +
                            "<source src=\"" + HttpUtility.HtmlAttributeEncode(resolvedAttach) + "\" type=\"video/" + ext.TrimStart('.') + "\" />" +
                            "</video>";
                    }
                    else
                    {
                        litAttachInline.Text = "<img src=\"" + HttpUtility.HtmlAttributeEncode(resolvedAttach) +
                            "\" alt=\"\" style=\"width:100%;max-height:400px;object-fit:contain;border-radius:8px;\" />";
                    }
                }
                else
                {
                    pnlAttach.Visible = false;
                }

                SetupNavigation(connection, lessonId, _unitId);
                litTTSStart.Text = T("Read Aloud", "Baca Kuat");
            }
        }

        private void SetCompletionUI(bool done)
        {
            if (done)
            {
                heroBadgeDiv.Attributes["class"] = "st-lesson-hero-badge st-lesson-badge-done";
                heroBadgeIcon.Attributes["class"] = "bi bi-check-circle-fill";
                litBadgeText.Text = T("Completed", "Selesai");
            }
            else
            {
                heroBadgeDiv.Attributes["class"] = "st-lesson-hero-badge st-lesson-badge-pending";
                heroBadgeIcon.Attributes["class"] = "bi bi-clock";
                litBadgeText.Text = T("Not Completed", "Belum Selesai");
            }
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

            using (SqlConnection connection = new SqlConnection(ConnectionString))
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
                if (TableExists("LessonProgress"))
                {
                    using (SqlCommand command = new SqlCommand("SELECT COUNT(*) FROM LessonProgress WHERE studentId=@s AND lessonId=@l AND isCompleted=1", connection))
                    {
                        command.Parameters.AddWithValue("@s", studentId);
                        command.Parameters.AddWithValue("@l", lessonId);
                        already = (int)command.ExecuteScalar() > 0;
                    }
                }

                if (!already && TableExists("LessonProgress"))
                {
                    string progId = "PR001";
                    using (SqlCommand seqCmd = new SqlCommand(@"SELECT ISNULL(MAX(CAST(SUBSTRING(progressId,3,LEN(progressId)-2) AS INT)),0) FROM LessonProgress WHERE progressId LIKE 'PR[0-9]%'", connection))
                    {
                        int last = Convert.ToInt32(seqCmd.ExecuteScalar());
                        progId = "PR" + (last + 1).ToString("D3");
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
                if (!TableExists("XPAction") || !TableExists("XPTransaction"))
                {
                    return;
                }

                // Read XP value from XPAction table for XP001 (Complete Lesson)
                int xpAmount = 0;
                using (SqlCommand command = new SqlCommand("SELECT xpValue FROM XPAction WHERE xpActionId='XP001'", conn))
                {
                    object result = command.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        xpAmount = Convert.ToInt32(result);
                    }
                }

                if (xpAmount <= 0)
                {
                    return;
                }

                // Generate next XPTransaction ID
                string xtId = "XPT001";
                using (SqlCommand command = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING(xpTransactionId,4,LEN(xpTransactionId)-3) AS INT)),0) FROM XPTransaction WHERE xpTransactionId LIKE 'XPT[0-9]%'", conn))
                {
                    int last = Convert.ToInt32(command.ExecuteScalar());
                    xtId = "XPT" + (last + 1).ToString("D3");
                }

                // Insert XP transaction
                using (SqlCommand command = new SqlCommand("INSERT INTO XPTransaction(xpTransactionId,studentId,xpActionId,xpAmount,dateEarned) VALUES(@id,@s,@a,@xp,@dt)", conn))
                {
                    command.Parameters.AddWithValue("@id", xtId);
                    command.Parameters.AddWithValue("@s", studentId);
                    command.Parameters.AddWithValue("@a", "XP001");
                    command.Parameters.AddWithValue("@xp", xpAmount);
                    command.Parameters.AddWithValue("@dt", DateTime.Today);
                    command.ExecuteNonQuery();
                }

                // Update student total XP
                using (SqlCommand command = new SqlCommand("UPDATE Student SET XP = ISNULL(XP,0) + @xp WHERE studentId=@s", conn))
                {
                    command.Parameters.AddWithValue("@xp", xpAmount);
                    command.Parameters.AddWithValue("@s", studentId);
                    command.ExecuteNonQuery();
                }

                // Check badges after lesson XP
                CheckLessonBadges(conn, studentId);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Lesson XP error: " + ex.Message);
            }
        }

        // Badge checks after lesson completion
        private void CheckLessonBadges(SqlConnection conn, string studentId)
        {
            try
            {
                if (!TableExists("StudentBadge") || !TableExists("LessonProgress")) return;

                // B001 First Step Learner — first lesson completed
                int lessonCount = 0;
                using (SqlCommand command = new SqlCommand("SELECT COUNT(*) FROM LessonProgress WHERE studentId=@s AND isCompleted=1", conn))
                {
                    command.Parameters.AddWithValue("@s", studentId);
                    lessonCount = (int)command.ExecuteScalar();
                }
                if (lessonCount == 1)
                {
                    AwardBadgeIfNotEarned(conn, studentId, "B001");
                }

                // B010 Consistent Learner — activity on 3+ different days
                if (TableExists("XPTransaction"))
                {
                    int distinctDays = 0;
                    using (SqlCommand command = new SqlCommand("SELECT COUNT(DISTINCT CAST(dateEarned AS DATE)) FROM XPTransaction WHERE studentId=@s", conn))
                    {
                        command.Parameters.AddWithValue("@s", studentId);
                        distinctDays = (int)command.ExecuteScalar();
                    }
                    if (distinctDays >= 3)
                    {
                        AwardBadgeIfNotEarned(conn, studentId, "B010");
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Badge error: " + ex.Message);
            }
        }

        private void AwardBadgeIfNotEarned(SqlConnection conn, string studentId, string badgeId)
        {
            using (SqlCommand command = new SqlCommand("SELECT COUNT(*) FROM StudentBadge WHERE studentId=@s AND badgeId=@b", conn))
            {
                command.Parameters.AddWithValue("@s", studentId);
                command.Parameters.AddWithValue("@b", badgeId);
                if ((int)command.ExecuteScalar() > 0) return;
            }

            string sbId = "SB001";
            using (SqlCommand command = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING(studentBadgeId,3,LEN(studentBadgeId)-2) AS INT)),0) FROM StudentBadge WHERE studentBadgeId LIKE 'SB[0-9]%'", conn))
            {
                sbId = "SB" + (Convert.ToInt32(command.ExecuteScalar()) + 1).ToString("D3");
            }

            using (SqlCommand command = new SqlCommand("INSERT INTO StudentBadge(studentBadgeId,studentId,badgeId,earnedAt) VALUES(@id,@s,@b,@dt)", conn))
            {
                command.Parameters.AddWithValue("@id", sbId);
                command.Parameters.AddWithValue("@s", studentId);
                command.Parameters.AddWithValue("@b", badgeId);
                command.Parameters.AddWithValue("@dt", DateTime.Now);
                command.ExecuteNonQuery();
            }

            // Send badge earned notification
            try
            {
                string uId = "";
                using (SqlCommand uidCmd = new SqlCommand("SELECT userId FROM Student WHERE studentId=@s", conn))
                { uidCmd.Parameters.AddWithValue("@s", studentId); var r = uidCmd.ExecuteScalar(); if (r != null) uId = r.ToString(); }
                if (!string.IsNullOrEmpty(uId))
                {
                    string bName = "";
                    using (SqlCommand bCmd = new SqlCommand("SELECT badgeNameEN FROM Badge WHERE badgeId=@b", conn))
                    { bCmd.Parameters.AddWithValue("@b", badgeId); var r = bCmd.ExecuteScalar(); if (r != null) bName = r.ToString(); }
                    SendNotification(conn, uId, "New Badge Earned", "Lencana Baru Diperolehi", "You earned the " + bName + " badge!", "Anda memperoleh lencana " + bName + "!");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Badge notification error: " + ex.Message);
            }
        }

        private void SetupNavigation(SqlConnection connection, string currentLessonId, string unitId)
        {
            // Get all lessons in this unit, ordered
            const string sql = @"SELECT ls.lessonId FROM Lesson ls
                JOIN Subtopic st ON st.subtopicId = ls.subtopicId
                WHERE st.unitId = @uid ORDER BY st.orderNo, ls.orderNo";
            List<string> allLessons = new List<string>();
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@uid", unitId);
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                        allLessons.Add(reader["lessonId"].ToString());
                }
            }

            int idx = allLessons.IndexOf(currentLessonId);
            if (idx < 0) return;

            litPrevBtn.Text = T("Previous", "Sebelum");
            litNextBtn.Text = T("Next", "Seterusnya");

            // Previous button
            if (idx > 0)
            {
                lnkPrev.Visible = true;
                lnkPrev.NavigateUrl = ResolveUrl("~/Student/Lesson.aspx?lessonId=" + allLessons[idx - 1]);
            }

            // Next button
            if (idx < allLessons.Count - 1)
            {
                btnNext.Visible = true;
                btnNext.CommandArgument = allLessons[idx + 1];
            }
        }

        protected void btnNext_Click(object sender, EventArgs e)
        {
            InitLang();
            string currentLessonId = Request.QueryString["lessonId"];
            string nextLessonId = btnNext.CommandArgument;
            string userId = Session["userId"].ToString();

            if (string.IsNullOrEmpty(currentLessonId) || string.IsNullOrEmpty(nextLessonId)) return;

            // Mark current lesson as complete
            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                connection.Open();
                string studentId = null;
                using (SqlCommand command = new SqlCommand("SELECT studentId FROM Student WHERE userId=@u", connection))
                {
                    command.Parameters.AddWithValue("@u", userId);
                    object result = command.ExecuteScalar();
                    if (result != null && result != DBNull.Value) studentId = result.ToString();
                }

                if (!string.IsNullOrEmpty(studentId) && TableExists("LessonProgress"))
                {
                    bool already = false;
                    using (SqlCommand command = new SqlCommand("SELECT COUNT(*) FROM LessonProgress WHERE studentId=@s AND lessonId=@l AND isCompleted=1", connection))
                    {
                        command.Parameters.AddWithValue("@s", studentId);
                        command.Parameters.AddWithValue("@l", currentLessonId);
                        already = (int)command.ExecuteScalar() > 0;
                    }

                    if (!already)
                    {
                        string progId = "PR001";
                        using (SqlCommand seqCmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING(progressId,3,LEN(progressId)-2) AS INT)),0) FROM LessonProgress WHERE progressId LIKE 'PR[0-9]%'", connection))
                        {
                            int last = Convert.ToInt32(seqCmd.ExecuteScalar());
                            progId = "PR" + (last + 1).ToString("D3");
                        }

                        using (SqlCommand command = new SqlCommand("INSERT INTO LessonProgress(progressId,studentId,lessonId,isCompleted,completedDate) VALUES(@pid,@s,@l,1,@d)", connection))
                        {
                            command.Parameters.AddWithValue("@pid", progId);
                            command.Parameters.AddWithValue("@s", studentId);
                            command.Parameters.AddWithValue("@l", currentLessonId);
                            command.Parameters.AddWithValue("@d", DateTime.Now);
                            command.ExecuteNonQuery();
                        }

                        AwardXP(connection, studentId, currentLessonId);
                    }
                }
            }

            // Navigate to next lesson
            Response.Redirect("~/Student/Lesson.aspx?lessonId=" + nextLessonId, false);
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

        private bool TableExists(string t)
        {
            using (SqlConnection connection = new SqlConnection(ConnectionString))
            using (SqlCommand command = new SqlCommand("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME=@t AND TABLE_TYPE='BASE TABLE'", connection))
            {
                command.Parameters.AddWithValue("@t", t);
                connection.Open();
                return (int)command.ExecuteScalar() > 0;
            }
        }

        private void SendNotification(SqlConnection conn, string toUserId, string titleEN, string titleBM, string msgEN, string msgBM)
        {
            try
            {
                string nId = "N001";
                using (SqlCommand command = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING(notificationId,2,LEN(notificationId)-1) AS INT)),0) FROM Notification WHERE notificationId LIKE 'N[0-9]%'", conn))
                {
                    nId = "N" + (Convert.ToInt32(command.ExecuteScalar()) + 1).ToString("D3");
                }
                using (SqlCommand command = new SqlCommand("INSERT INTO Notification(notificationId,toUserId,titleEN,titleBM,messageEN,messageBM,isRead,createdAt) VALUES(@id,@to,@tEN,@tBM,@mEN,@mBM,0,@dt)", conn))
                {
                    command.Parameters.AddWithValue("@id", nId);
                    command.Parameters.AddWithValue("@to", toUserId);
                    command.Parameters.AddWithValue("@tEN", titleEN);
                    command.Parameters.AddWithValue("@tBM", titleBM);
                    command.Parameters.AddWithValue("@mEN", msgEN);
                    command.Parameters.AddWithValue("@mBM", msgBM);
                    command.Parameters.AddWithValue("@dt", DateTime.Now);
                    command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Notification error: " + ex.Message);
            }
        }
    }
}

