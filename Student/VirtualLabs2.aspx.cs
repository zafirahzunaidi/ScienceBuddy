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
    public partial class VirtualLabs : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        private string CurrentLanguage = "EN";
        private string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null || Session["role"].ToString() != "Student")
            { Response.Redirect("~/Login.aspx", false); return; }
            ((SiteMaster)Master).LayoutMode = "Sidebar";
            InitLang();
            if (!IsPostBack) { SetLabels(); BuildFilters(); LoadLabs(); }
        }

        protected void Filter_Changed(object sender, EventArgs e) { LoadLabs(); }

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
            if (Tbl("Level"))
            { using (var c = new SqlConnection(ConnStr)) { c.Open();
              using (var cmd = new SqlCommand("SELECT levelId,levelNameEN,levelNameBM FROM Level ORDER BY levelId", c))
              using (var r = cmd.ExecuteReader()) while (r.Read())
              { string n = bm ? r["levelNameBM"].ToString() : r["levelNameEN"].ToString();
                if (string.IsNullOrWhiteSpace(n)) n = r["levelNameEN"].ToString();
                ddlLevel.Items.Add(new ListItem(n, r["levelId"].ToString())); } } }

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
            if (!Tbl("VirtualLab") || !Tbl("Student")) { ShowEmpty(); return; }

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                string studentId = null; string curLevel = "LV001";
                using (var cmd = new SqlCommand("SELECT studentId,currentlevelId FROM Student WHERE userId=@u", conn))
                { cmd.Parameters.AddWithValue("@u", userId);
                  using (var r = cmd.ExecuteReader()) if (r.Read()) { studentId = r["studentId"].ToString(); curLevel = r["currentlevelId"]?.ToString() ?? "LV001"; } }
                if (string.IsNullOrEmpty(studentId)) { ShowEmpty(); return; }

                int curOrd = Ord(curLevel); bool bm = CurrentLanguage == "BM";
                const string sql = @"SELECT v.labId, v.labTitleEN, v.labTitleBM, v.labDescriptionEN, v.labDescriptionBM,
                    v.difficulty, v.labType, v.unitId, u.unitNameEN, u.unitNameBM, u.levelId, l.levelNameEN, l.levelNameBM
                    FROM VirtualLab v JOIN Unit u ON u.unitId=v.unitId JOIN Level l ON l.levelId=u.levelId ORDER BY u.levelId, u.orderNo";
                var dt = new DataTable();
                using (var cmd = new SqlCommand(sql, conn)) { new SqlDataAdapter(cmd).Fill(dt); }

                // Progress
                var doneSet = new HashSet<string>();
                if (Tbl("LabProgress"))
                { using (var cmd = new SqlCommand("SELECT labId FROM LabProgress WHERE studentId=@s AND isCompleted=1", conn))
                  { cmd.Parameters.AddWithValue("@s", studentId); using (var r = cmd.ExecuteReader()) while (r.Read()) doneSet.Add(r["labId"].ToString()); } }

                string fLevel = ddlLevel.SelectedValue;
                string fDiff = ddlDifficulty.SelectedValue;
                string fStatus = ddlStatus.SelectedValue;

                var list = new List<object>(); int cntAvail = 0, cntDone = 0, cntNew = 0;
                foreach (DataRow row in dt.Rows)
                {
                    string lvl = row["levelId"].ToString();
                    if (Ord(lvl) > curOrd) continue;
                    cntAvail++;
                    string labId = row["labId"].ToString();
                    bool isDone = doneSet.Contains(labId);
                    if (isDone) cntDone++; else cntNew++;

                    if (!string.IsNullOrEmpty(fLevel) && lvl != fLevel) continue;
                    string diff = row["difficulty"]?.ToString() ?? "";
                    if (!string.IsNullOrEmpty(fDiff) && !diff.Equals(fDiff, StringComparison.OrdinalIgnoreCase)) continue;
                    if (fStatus == "done" && !isDone) continue;
                    if (fStatus == "new" && isDone) continue;

                    string title = bm ? row["labTitleBM"].ToString() : row["labTitleEN"].ToString();
                    if (string.IsNullOrWhiteSpace(title)) title = row["labTitleEN"].ToString();
                    string desc = bm ? row["labDescriptionBM"].ToString() : row["labDescriptionEN"].ToString();
                    if (string.IsNullOrWhiteSpace(desc)) desc = row["labDescriptionEN"].ToString();
                    string uName = bm ? row["unitNameBM"].ToString() : row["unitNameEN"].ToString();
                    if (string.IsNullOrWhiteSpace(uName)) uName = row["unitNameEN"].ToString();
                    string lName = bm ? row["levelNameBM"].ToString() : row["levelNameEN"].ToString();
                    if (string.IsNullOrWhiteSpace(lName)) lName = row["levelNameEN"].ToString();

                    string statusText = isDone ? T("Completed", "Selesai") : T("Not Started", "Belum Mula");
                    string badgeClass = isDone ? "vl-badge-done" : "vl-badge-new";
                    string btnText = isDone ? T("Redo Lab", "Ulang Makmal") : T("Start Lab", "Mula Makmal");
                    string btnClass = isDone ? "sb-btn-light" : "sb-btn-primary";
                    string diffClass = diff.Equals("Easy", StringComparison.OrdinalIgnoreCase) ? "easy"
                        : diff.Equals("Hard", StringComparison.OrdinalIgnoreCase) ? "hard" : "medium";

                    list.Add(new { Title = HttpUtility.HtmlEncode(title), Desc = HttpUtility.HtmlEncode(desc),
                        Level = HttpUtility.HtmlEncode(lName), Unit = HttpUtility.HtmlEncode(uName),
                        Difficulty = diff, DiffClass = diffClass, StatusText = statusText,
                        BadgeClass = badgeClass, BtnText = btnText, BtnClass = btnClass,
                        Icon = GetIcon(title), Url = ResolveUrl("~/Student/VirtualLab.aspx?labId=" + labId) });
                }

                litAvailable.Text = cntAvail.ToString();
                litCompleted.Text = cntDone.ToString();
                litInProgress.Text = cntNew.ToString();
                if (list.Count == 0) { ShowEmpty(); return; }
                pnlGrid.Visible = true; pnlEmpty.Visible = false;
                rptLabs.DataSource = list; rptLabs.DataBind();
            }
        }

        private void ShowEmpty() { pnlGrid.Visible = false; pnlEmpty.Visible = true; }

        private static string GetIcon(string t)
        {
            if (string.IsNullOrEmpty(t)) return "🧪";
            string s = t.ToLower();
            if (s.Contains("magnet")) return "🧲";
            if (s.Contains("soak") || s.Contains("water") || s.Contains("air")) return "💧";
            if (s.Contains("sandwich") || s.Contains("digest")) return "🥪";
            if (s.Contains("sink") || s.Contains("float")) return "🚢";
            if (s.Contains("litmus") || s.Contains("acid")) return "🧫";
            if (s.Contains("blood") || s.Contains("darah")) return "❤️";
            if (s.Contains("circuit") || s.Contains("litar")) return "⚡";
            if (s.Contains("matter") || s.Contains("jirim")) return "🧊";
            return "🔬";
        }

        private static int Ord(string id) { switch (id) { case "LV001": return 1; case "LV002": return 2; case "LV003": return 3; default: return 0; } }
        private bool Tbl(string t) { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME=@t AND TABLE_TYPE='BASE TABLE'", c)) { cmd.Parameters.AddWithValue("@t", t); c.Open(); return (int)cmd.ExecuteScalar() > 0; } }
    }
}
