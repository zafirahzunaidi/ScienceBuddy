using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace ScienceBuddy.Student
{
    public partial class MyLearning : Page
    {
        private string ConnectionString
        {
            get { return ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString; }
        }

        private string CurrentLanguage = "EN";

        private string T(string en, string bm)
        {
            if (CurrentLanguage == "BM")
            {
                return bm;
            }
            return en;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null || Session["role"].ToString() != "Student")
            {
                Response.Redirect("~/Login.aspx", false);
                return;
            }

            ScienceBuddy.SiteMaster master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            InitLanguage();
            SetLabels();

            if (!IsPostBack)
            {
                LoadPage();
            }
        }

        private void InitLanguage()
        {
            string lang = Session["preferredLanguage"] as string;
            if (!string.IsNullOrEmpty(lang))
            {
                CurrentLanguage = lang;
                return;
            }

            string userId = Session["userId"] as string;
            if (!string.IsNullOrEmpty(userId))
            {
                try
                {
                    const string sql = "SELECT preferredLanguage FROM [User] WHERE userId = @userId";
                    using (SqlConnection connection = new SqlConnection(ConnectionString))
                    using (SqlCommand command = new SqlCommand(sql, connection))
                    {
                        command.Parameters.AddWithValue("@userId", userId);
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
                catch (SqlException ex)
                {
                    System.Diagnostics.Debug.WriteLine("Database error: " + ex.Message);
                }
            }

            CurrentLanguage = "EN";
            Session["preferredLanguage"] = "EN";
        }

        private void SetLabels()
        {
            litPageTitle.Text = T("My Learning", "Pembelajaran Saya");
            litTitle.Text = T("My Learning", "Pembelajaran Saya");
            litSubtitle.Text = T("Choose your level and continue your science journey.","Pilih tahap anda dan teruskan pembelajaran Sains.");
            litEmptyTitle.Text = T("No learning content yet", "Tiada kandungan pembelajaran lagi");
            litEmptyDesc.Text = T("Learning levels will appear here once available.","Tahap pembelajaran akan muncul di sini apabila tersedia.");
            litQuizEmpty.Text = T("Level assessment is not available yet.","Penilaian tahap belum tersedia lagi.");
        }

        // Selected level tracking
        private string SelectedLevelId
        {
            get 
            { 
                return ViewState["SelectedLevel"] as string; 
            }
            set 
            { 
                ViewState["SelectedLevel"] = value; 
            }
        }

        protected void rptLevels_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "SelectLevel")
            {
                SelectedLevelId = e.CommandArgument.ToString();
                LoadPage();
            }
        }

        private void LoadPage()
        {
            string userId = Session["userId"].ToString();

            if (!TableExists("Level") || !TableExists("Student"))
            {
                pnlEmpty.Visible = true;
                pnlUnits.Visible = false;
                return;
            }

            string currentLevelId = null;
            string studentId = null;
            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                connection.Open();
                const string sStu = "SELECT studentId, currentlevelId FROM Student WHERE userId = @userId";
                using (SqlCommand command = new SqlCommand(sStu, connection))
                {
                    command.Parameters.AddWithValue("@userId", userId);
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            studentId = reader["studentId"].ToString();
                            currentLevelId = reader["currentlevelId"]?.ToString();
                        }
                    }
                }

                if (string.IsNullOrEmpty(currentLevelId))
                {
                    currentLevelId = "LV001";
                }

                // Use selected level if set, otherwise default to current level
                string displayLevelId = SelectedLevelId;
                if (string.IsNullOrEmpty(displayLevelId))
                {
                    displayLevelId = currentLevelId;
                    SelectedLevelId = currentLevelId;
                }

                // Ensure selected level is not locked (order <= current)
                if (GetLevelOrder(displayLevelId) > GetLevelOrder(currentLevelId))
                {
                    displayLevelId = currentLevelId;
                    SelectedLevelId = currentLevelId;
                }

                LoadLevels(connection, currentLevelId, displayLevelId);
                LoadUnits(connection, displayLevelId, studentId);
                LoadLevelQuiz(connection, displayLevelId);
            }
        }

        private void LoadLevels(SqlConnection connection, string currentLevelId, string selectedLevelId)
        {
            const string sql = "SELECT levelId, levelNameEN, levelNameBM, levelDescriptionEN, levelDescriptionBM FROM Level ORDER BY levelId";
            DataTable dataTable = new DataTable();
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                SqlDataAdapter adapter = new SqlDataAdapter(command);
                adapter.Fill(dataTable);
            }

            if (dataTable.Rows.Count == 0)
            {
                pnlEmpty.Visible = true;
                return;
            }

            int currentOrder = GetLevelOrder(currentLevelId);
            bool isBM = CurrentLanguage == "BM";
            List<object> list = new List<object>();
            string[] icons = { "<i class=\"bi bi-flower2\"></i>", "<i class=\"bi bi-eyedropper\"></i>", "<i class=\"bi bi-rocket-takeoff\"></i>" };
            string[] iconBgs = { "#DCFCE7", "#DBEAFE", "#F3E8FF" };
            string[] iconColors = { "#15803D", "#1D4ED8", "#7C3AED" };

            for (int i = 0; i < dataTable.Rows.Count; i++)
            {
                DataRow row = dataTable.Rows[i];
                string lid = row["levelId"].ToString();
                int order = GetLevelOrder(lid);
                bool isCurrent = lid == currentLevelId;
                bool isLocked = order > currentOrder;

                string name;
                if (isBM)
                {
                    name = row["levelNameBM"].ToString();
                }
                else
                {
                    name = row["levelNameEN"].ToString();
                }
                if (string.IsNullOrWhiteSpace(name))
                {
                    name = row["levelNameEN"].ToString();
                }

                string desc;
                if (isBM)
                {
                    desc = row["levelDescriptionBM"].ToString();
                }
                else
                {
                    desc = row["levelDescriptionEN"].ToString();
                }
                if (string.IsNullOrWhiteSpace(desc))
                {
                    desc = row["levelDescriptionEN"].ToString();
                }

                string cssClass;
                if (lid == selectedLevelId)
                {
                    cssClass = "current";
                }
                else if (isLocked)
                {
                    cssClass = "locked";
                }
                else
                {
                    cssClass = "";
                }

                string badgeClass;
                if (lid == selectedLevelId)
                {
                    badgeClass = "st-mylearning-badge-current";
                }
                else if (isLocked)
                {
                    badgeClass = "st-mylearning-badge-locked";
                }
                else
                {
                    badgeClass = "st-mylearning-badge-unlocked";
                }

                string badgeText;
                if (isCurrent)
                {
                    badgeText = T("Current", "Semasa");
                }
                else if (isLocked)
                {
                    badgeText = T("Locked", "Dikunci");
                }
                else
                {
                    badgeText = T("Unlocked", "Dibuka");
                }

                string icon;
                if (i < icons.Length)
                {
                    icon = icons[i];
                }
                else
                {
                    icon = "<i class=\"bi bi-book\"></i>";
                }

                string iconBg;
                if (i < iconBgs.Length)
                {
                    iconBg = iconBgs[i];
                }
                else
                {
                    iconBg = "#F0F7FF";
                }

                string iconColor;
                if (i < iconColors.Length)
                {
                    iconColor = iconColors[i];
                }
                else
                {
                    iconColor = "#2563EB";
                }

                list.Add(new
                {
                    LevelId = lid,
                    CssClass = cssClass,
                    Name = HttpUtility.HtmlEncode(name),
                    Description = HttpUtility.HtmlEncode(desc),
                    Icon = icon,
                    IconBg = iconBg,
                    IconColor = iconColor,
                    BadgeClass = badgeClass,
                    BadgeText = badgeText,
                    IsLocked = isLocked,
                    IsSelected = (lid == selectedLevelId)
                });
            }

            rptLevels.DataSource = list;
            rptLevels.DataBind();
        }

        private void LoadUnits(SqlConnection connection, string levelId, string studentId)
        {
            if (!TableExists("Unit"))
            {
                pnlUnits.Visible = false;
                return;
            }

            bool isBM = CurrentLanguage == "BM";
            litUnitsTitle.Text = T("Units", "Unit");

            const string sql = @"SELECT u.unitId, u.unitNameEN, u.unitNameBM,u.unitDescriptionEN, u.unitDescriptionBM, u.orderNo,
                       (SELECT COUNT(*) FROM Subtopic WHERE unitId = u.unitId) AS subtopicCount,
                       (SELECT COUNT(*) FROM Lesson ls JOIN Subtopic st ON st.subtopicId = ls.subtopicId WHERE st.unitId = u.unitId) AS lessonCount
                        FROM Unit u
                        WHERE u.levelId = @levelId
                        ORDER BY u.orderNo";

            DataTable dataTable = new DataTable();
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@levelId", levelId);
                SqlDataAdapter adapter = new SqlDataAdapter(command);
                adapter.Fill(dataTable);
            }

            if (dataTable.Rows.Count == 0)
            {
                pnlUnits.Visible = false;
                return;
            }

            Dictionary<string, int> completedMap = new Dictionary<string, int>();
            if (!string.IsNullOrEmpty(studentId) && TableExists("LessonProgress"))
            {
                const string pSql = @"SELECT st.unitId, COUNT(*) AS cnt
                    FROM LessonProgress lp
                    JOIN Lesson ls ON ls.lessonId = lp.lessonId
                    JOIN Subtopic st ON st.subtopicId = ls.subtopicId
                    WHERE lp.studentId = @studentId AND lp.isCompleted = 1
                    GROUP BY st.unitId";

                using (SqlCommand cmd2 = new SqlCommand(pSql, connection))
                {
                    cmd2.Parameters.AddWithValue("@studentId", studentId);
                    using (SqlDataReader reader = cmd2.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            completedMap[reader["unitId"].ToString()] = Convert.ToInt32(reader["cnt"]);
                        }
                    }
                }
            }

            List<object> list = new List<object>();
            foreach (DataRow row in dataTable.Rows)
            {
                string unitId = row["unitId"].ToString();

                string name;
                if (isBM)
                {
                    name = row["unitNameBM"].ToString();
                }
                else
                {
                    name = row["unitNameEN"].ToString();
                }
                if (string.IsNullOrWhiteSpace(name))
                {
                    name = row["unitNameEN"].ToString();
                }

                string desc;
                if (isBM)
                {
                    desc = row["unitDescriptionBM"].ToString();
                }
                else
                {
                    desc = row["unitDescriptionEN"].ToString();
                }
                if (string.IsNullOrWhiteSpace(desc))
                {
                    desc = row["unitDescriptionEN"].ToString();
                }

                int subtopics = Convert.ToInt32(row["subtopicCount"]);
                int lessons = Convert.ToInt32(row["lessonCount"]);
                int completed;
                if (completedMap.ContainsKey(unitId))
                {
                    completed = completedMap[unitId];
                }
                else
                {
                    completed = 0;
                }

                int pct;
                if (lessons > 0)
                {
                    pct = Math.Min(completed * 100 / lessons, 100);
                }
                else
                {
                    pct = 0;
                }

                list.Add(new
                {
                    Name = HttpUtility.HtmlEncode(name),
                    Description = HttpUtility.HtmlEncode(desc),
                    SubtopicCount = subtopics,
                    SubtopicLabel = T("subtopics", "subtopik"),
                    LessonCount = lessons,
                    LessonLabel = T("lessons", "pelajaran"),
                    ProgressPct = pct,
                    ProgressText = completed + "/" + lessons + " " + T("completed", "selesai"),
                    BtnText = T("View Unit", "Lihat Unit"),
                    LinkUrl = ResolveUrl("~/Student/UnitDetails.aspx?unitId=" + unitId)
                });
            }

            pnlUnits.Visible = true;
            rptUnits.DataSource = list;
            rptUnits.DataBind();
        }

        private void LoadLevelQuiz(SqlConnection connection, string levelId)
        {
            if (!TableExists("Quiz"))
            {
                pnlQuiz.Visible = false;
                pnlQuizEmpty.Visible = true;
                return;
            }

            bool isBM = CurrentLanguage == "BM";
            const string sql = @"SELECT quizId, quizTitleEN, quizTitleBM
                FROM Quiz
                WHERE levelId = @levelId AND quizType = 'Level'
                ORDER BY createdAt DESC";

            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@levelId", levelId);
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        string title;
                        if (isBM)
                        {
                            title = reader["quizTitleBM"].ToString();
                        }
                        else
                        {
                            title = reader["quizTitleEN"].ToString();
                        }
                        if (string.IsNullOrWhiteSpace(title))
                        {
                            title = reader["quizTitleEN"].ToString();
                        }

                        pnlQuiz.Visible = true;
                        pnlQuizEmpty.Visible = false;
                        litQuizTitle.Text = HttpUtility.HtmlEncode(title);
                        litQuizSub.Text = T("Test your knowledge for this level","Uji pengetahuan anda untuk tahap ini");
                        litQuizBtn.Text = T("Start Quiz", "Mula Kuiz");
                    }
                    else
                    {
                        pnlQuiz.Visible = false;
                        pnlQuizEmpty.Visible = true;
                    }
                }
            }
        }

        private static int GetLevelOrder(string levelId)
        {
            switch (levelId)
            {
                case "LV001": 
                    return 1;
                case "LV002": 
                    return 2;
                case "LV003": 
                    return 3;
                default: 
                    return 0;
            }
        }

        private bool TableExists(string tableName)
        {
            const string sql = @"SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @t AND TABLE_TYPE = 'BASE TABLE'";
            using (SqlConnection connection = new SqlConnection(ConnectionString))
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@t", tableName);
                connection.Open();
                return (int)command.ExecuteScalar() > 0;
            }
        }
    }
}
