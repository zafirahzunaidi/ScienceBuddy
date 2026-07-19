using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Student
{
    public partial class VirtualLabs1 : Page
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

            ((SiteMaster)Master).LayoutMode = "Sidebar";
            InitLang();

            if (!IsPostBack)
            {
                SetLabels();
                BuildFilters();
                LoadLabs();
            }
        }

        protected void Filter_Changed(object sender, EventArgs e)
        {
            LoadLabs();
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

        private void SetLabels()
        {
            litPageTitle.Text = T("Virtual Labs", "Makmal Maya");
            litTitle.Text = T("Virtual Labs", "Makmal Maya");
            litSubtitle.Text = T("Explore science through colourful interactive activities.",
                                 "Terokai Sains melalui aktiviti interaktif yang berwarna-warni.");
            litAvailableLbl.Text = T("Available Labs", "Makmal Tersedia");
            litCompletedLbl.Text = T("Completed", "Selesai");
            litInProgressLbl.Text = T("Not Started", "Belum Dimulakan");
            litEmptyTitle.Text = T("No virtual labs available", "Tiada makmal maya tersedia");
            litEmptyDesc.Text = T("No virtual labs are available yet.", "Tiada makmal maya tersedia buat masa ini.");
            litEmptyBtn.Text = T("My Learning", "Pembelajaran Saya");
        }

        private void BuildFilters()
        {
            bool bm = CurrentLanguage == "BM";
            ddlLevel.Items.Clear();
            ddlLevel.Items.Add(new ListItem(T("All Levels", "Semua Tahap"), ""));

            if (TableExists("Level"))
            {
                using (SqlConnection connection = new SqlConnection(ConnectionString))
                {
                    connection.Open();
                    using (SqlCommand command = new SqlCommand("SELECT levelId,levelNameEN,levelNameBM FROM Level ORDER BY levelId", connection))
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string n;
                            if (bm)
                            {
                                n = reader["levelNameBM"].ToString();
                            }
                            else
                            {
                                n = reader["levelNameEN"].ToString();
                            }
                            if (string.IsNullOrWhiteSpace(n))
                            {
                                n = reader["levelNameEN"].ToString();
                            }
                            ddlLevel.Items.Add(new ListItem(n, reader["levelId"].ToString()));
                        }
                    }
                }
            }

            ddlDifficulty.Items.Clear();
            ddlDifficulty.Items.Add(new ListItem(T("All Difficulty", "Semua Kesukaran"), ""));
            ddlDifficulty.Items.Add(new ListItem(T("Easy", "Mudah"), "Easy"));
            ddlDifficulty.Items.Add(new ListItem(T("Medium", "Sederhana"), "Medium"));
            ddlDifficulty.Items.Add(new ListItem(T("Hard", "Sukar"), "Hard"));

            ddlStatus.Items.Clear();
            ddlStatus.Items.Add(new ListItem(T("All Status", "Semua Status"), ""));
            ddlStatus.Items.Add(new ListItem(T("Not Started", "Belum Mula"), "new"));
            ddlStatus.Items.Add(new ListItem(T("Completed", "Selesai"), "done"));
        }

        private void LoadLabs()
        {
            string userId = Session["userId"].ToString();
            if (!TableExists("VirtualLab") || !TableExists("Student"))
            {
                ShowEmpty();
                return;
            }

            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                connection.Open();
                string studentId = null;
                string curLevel = "LV001";
                using (SqlCommand command = new SqlCommand("SELECT studentId,currentlevelId FROM Student WHERE userId=@u", connection))
                {
                    command.Parameters.AddWithValue("@u", userId);
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            studentId = reader["studentId"].ToString();
                            if (reader["currentlevelId"] != null)
                            {
                                curLevel = reader["currentlevelId"].ToString();
                            }
                            else
                            {
                                curLevel = "LV001";
                            }
                        }
                    }
                }
                if (string.IsNullOrEmpty(studentId))
                {
                    ShowEmpty();
                    return;
                }

                int curOrd = Ord(curLevel);
                bool bm = CurrentLanguage == "BM";
                const string sql = @"SELECT v.labId, v.labTitleEN, v.labTitleBM, v.labDescriptionEN, v.labDescriptionBM,
                    v.difficulty, v.labType, v.unitId, u.unitNameEN, u.unitNameBM, u.levelId, l.levelNameEN, l.levelNameBM
                    FROM VirtualLab v JOIN Unit u ON u.unitId=v.unitId JOIN Level l ON l.levelId=u.levelId ORDER BY u.levelId, u.orderNo";
                DataTable dataTable = new DataTable();
                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    SqlDataAdapter adapter = new SqlDataAdapter(command);
                    adapter.Fill(dataTable);
                }

                // Progress
                var doneSet = new HashSet<string>();
                if (TableExists("LabProgress"))
                {
                    using (SqlCommand command = new SqlCommand("SELECT labId FROM LabProgress WHERE studentId=@s AND isCompleted=1", connection))
                    {
                        command.Parameters.AddWithValue("@s", studentId);
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                doneSet.Add(reader["labId"].ToString());
                            }
                        }
                    }
                }

                string fLevel = ddlLevel.SelectedValue;
                string fDiff = ddlDifficulty.SelectedValue;
                string fStatus = ddlStatus.SelectedValue;

                var list = new List<object>();
                int cntAvail = 0;
                int cntDone = 0;
                int cntNew = 0;

                foreach (DataRow row in dataTable.Rows)
                {
                    string lvl = row["levelId"].ToString();
                    if (Ord(lvl) > curOrd)
                    {
                        continue;
                    }
                    cntAvail++;
                    string labId = row["labId"].ToString();
                    bool isDone = doneSet.Contains(labId);
                    if (isDone)
                    {
                        cntDone++;
                    }
                    else
                    {
                        cntNew++;
                    }

                    if (!string.IsNullOrEmpty(fLevel) && lvl != fLevel)
                    {
                        continue;
                    }
                    string diff = "";
                    if (row["difficulty"] != null)
                    {
                        diff = row["difficulty"].ToString();
                    }
                    if (!string.IsNullOrEmpty(fDiff) && !diff.Equals(fDiff, StringComparison.OrdinalIgnoreCase))
                    {
                        continue;
                    }
                    if (fStatus == "done" && !isDone)
                    {
                        continue;
                    }
                    if (fStatus == "new" && isDone)
                    {
                        continue;
                    }

                    string title;
                    if (bm)
                    {
                        title = row["labTitleBM"].ToString();
                    }
                    else
                    {
                        title = row["labTitleEN"].ToString();
                    }
                    if (string.IsNullOrWhiteSpace(title))
                    {
                        title = row["labTitleEN"].ToString();
                    }

                    string desc;
                    if (bm)
                    {
                        desc = row["labDescriptionBM"].ToString();
                    }
                    else
                    {
                        desc = row["labDescriptionEN"].ToString();
                    }
                    if (string.IsNullOrWhiteSpace(desc))
                    {
                        desc = row["labDescriptionEN"].ToString();
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

                    string statusText;
                    if (isDone)
                    {
                        statusText = T("Completed", "Selesai");
                    }
                    else
                    {
                        statusText = T("Not Started", "Belum Mula");
                    }

                    string badgeClass;
                    if (isDone)
                    {
                        badgeClass = "st-virtuallabs-badge-done";
                    }
                    else
                    {
                        badgeClass = "st-virtuallabs-badge-new";
                    }

                    string btnText;
                    if (isDone)
                    {
                        btnText = T("Redo Lab", "Ulang Makmal");
                    }
                    else
                    {
                        btnText = T("Start Lab", "Mula Makmal");
                    }

                    string btnClass;
                    if (isDone)
                    {
                        btnClass = "sb-btn-light";
                    }
                    else
                    {
                        btnClass = "sb-btn-primary";
                    }

                    string diffClass;
                    if (diff.Equals("Easy", StringComparison.OrdinalIgnoreCase))
                    {
                        diffClass = "easy";
                    }
                    else if (diff.Equals("Hard", StringComparison.OrdinalIgnoreCase))
                    {
                        diffClass = "hard";
                    }
                    else
                    {
                        diffClass = "medium";
                    }

                    list.Add(new
                    {
                        Title = HttpUtility.HtmlEncode(title),
                        Desc = HttpUtility.HtmlEncode(desc),
                        Level = HttpUtility.HtmlEncode(lName),
                        Unit = HttpUtility.HtmlEncode(uName),
                        Difficulty = diff,
                        DiffClass = diffClass,
                        StatusText = statusText,
                        BadgeClass = badgeClass,
                        BtnText = btnText,
                        BtnClass = btnClass,
                        Icon = GetIcon(title),
                        Url = ResolveUrl("~/Student/VirtualLab.aspx?labId=" + labId)
                    });
                }

                litAvailable.Text = cntAvail.ToString();
                litCompleted.Text = cntDone.ToString();
                litInProgress.Text = cntNew.ToString();

                if (list.Count == 0)
                {
                    ShowEmpty();
                    return;
                }

                pnlGrid.Visible = true;
                pnlEmpty.Visible = false;
                rptLabs.DataSource = list;
                rptLabs.DataBind();
            }
        }

        private void ShowEmpty()
        {
            pnlGrid.Visible = false;
            pnlEmpty.Visible = true;
        }

        private static string GetIcon(string t)
        {
            if (string.IsNullOrEmpty(t))
            {
                return "<i class=\"bi bi-eyedropper\"></i>";
            }
            string s = t.ToLower();
            if (s.Contains("magnet"))
            {
                return "<i class=\"bi bi-magnet\"></i>";
            }
            if (s.Contains("soak") || s.Contains("water") || s.Contains("air"))
            {
                return "<i class=\"bi bi-droplet-half\"></i>";
            }
            if (s.Contains("sandwich") || s.Contains("digest"))
            {
                return "<i class=\"bi bi-heart-pulse\"></i>";
            }
            if (s.Contains("sink") || s.Contains("float"))
            {
                return "<i class=\"bi bi-water\"></i>";
            }
            if (s.Contains("litmus") || s.Contains("acid"))
            {
                return "<i class=\"bi bi-moisture\"></i>";
            }
            if (s.Contains("blood") || s.Contains("darah"))
            {
                return "<i class=\"bi bi-heart-fill\"></i>";
            }
            if (s.Contains("circuit") || s.Contains("litar"))
            {
                return "<i class=\"bi bi-lightning-charge\"></i>";
            }
            if (s.Contains("matter") || s.Contains("jirim"))
            {
                return "<i class=\"bi bi-snow3\"></i>";
            }
            return "<i class=\"bi bi-eyedropper\"></i>";
        }

        private static int Ord(string id)
        {
            switch (id)
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
    }
}
