using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace ScienceBuddy.Student.Labs
{
    public partial class CircuitLab : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddyDB"].ConnectionString;
        public string CurrentLanguage = "EN";
        public string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }
        private string _studentId;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null || Session["role"].ToString() != "Student")
            { Response.Redirect("~/Login.aspx", false); return; }
            ((SiteMaster)Master).LayoutMode = "Sidebar";
            InitLang();
            if (!IsPostBack) LoadLab();
        }

        private void InitLang()
        {
            string l = Session["preferredLanguage"] as string;
            if (!string.IsNullOrEmpty(l)) { CurrentLanguage = l; return; }
            CurrentLanguage = "EN"; Session["preferredLanguage"] = "EN";
        }

        private void LoadLab()
        {
            string labId = Request.QueryString["labId"] ?? "LAB007";
            string userId = Session["userId"].ToString();
            if (!Tbl("VirtualLab") || !Tbl("Student")) { ShowError(); return; }

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT studentId FROM Student WHERE userId=@u", conn))
                { cmd.Parameters.AddWithValue("@u", userId); var r = cmd.ExecuteScalar(); _studentId = r?.ToString(); }
                if (string.IsNullOrEmpty(_studentId)) { ShowError(); return; }

                bool bm = CurrentLanguage == "BM";
                using (var cmd = new SqlCommand("SELECT labTitleEN,labTitleBM,labDescriptionEN,labDescriptionBM,difficulty FROM VirtualLab WHERE labId=@l", conn))
                {
                    cmd.Parameters.AddWithValue("@l", labId);
                    using (var r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            string t = bm ? r["labTitleBM"].ToString() : r["labTitleEN"].ToString();
                            if (string.IsNullOrWhiteSpace(t)) t = r["labTitleEN"].ToString();
                            string d = bm ? r["labDescriptionBM"].ToString() : r["labDescriptionEN"].ToString();
                            if (string.IsNullOrWhiteSpace(d)) d = r["labDescriptionEN"].ToString();
                            litPageTitle.Text = HttpUtility.HtmlEncode(t);
                            litLabTitle.Text = HttpUtility.HtmlEncode(t);
                            litLabDesc.Text = HttpUtility.HtmlEncode(d);
                            litDiff.Text = r["difficulty"]?.ToString() ?? "Medium";
                        }
                    }
                }

                if (Tbl("LabProgress"))
                {
                    using (var cmd = new SqlCommand("SELECT isCompleted FROM LabProgress WHERE studentId=@s AND labId=@l", conn))
                    { cmd.Parameters.AddWithValue("@s", _studentId); cmd.Parameters.AddWithValue("@l", labId);
                      var r = cmd.ExecuteScalar();
                      if (r != null && Convert.ToBoolean(r)) { btnComplete.Enabled = false; btnComplete.Text = T("? Completed","? Selesai");
                        btnComplete.CssClass = "sb-btn sb-btn-success"; } }
                }
            }

            SetLabels();
        }

        private void SetLabels()
        {
            litBack.Text = T("Virtual Labs", "Makmal Maya");
            litModeTitle.Text = T("Choose Circuit Type", "Pilih Jenis Litar");
            litModeInst.Text = T("Build both circuit types to compare them. Start with Series, then try Parallel.",
                "Bina kedua-dua jenis litar untuk membandingkannya. Mulakan dengan Sesiri, kemudian cuba Selari.");
            litSeries.Text = T("Series Circuit", "Litar Sesiri");
            litParallel.Text = T("Parallel Circuit", "Litar Selari");
            litBuildTitle.Text = T("Build Your Circuit", "Bina Litar Anda");
            litBuildInst.Text = T("Click components in the correct order: Battery ? Wire ? Switch ? Bulb 1 ? Bulb 2. Then toggle the switch!",
                "Klik komponen mengikut urutan: Bateri ? Wayar ? Suis ? Mentol 1 ? Mentol 2. Kemudian togol suis!");
            litBattery.Text = T("Battery", "Bateri");
            litWire1.Text = T("Wire", "Wayar");
            litSwitch.Text = T("Switch", "Suis");
            litBulb1.Text = T("Bulb 1", "Mentol 1");
            litBulb2.Text = T("Bulb 2", "Mentol 2");
            litCompareTitle.Text = T("Comparison Question", "Soalan Perbandingan");
            btnComplete.Text = T("Complete Lab ??", "Selesaikan Makmal ??");
            litErrorBtn.Text = T("Back to Virtual Labs", "Kembali ke Makmal Maya");
        }

        protected void btnComplete_Click(object sender, EventArgs e)
        {
            InitLang();
            string labId = Request.QueryString["labId"] ?? "LAB007";
            string userId = Session["userId"].ToString();
            int score = 0;
            int.TryParse(hfScore.Value, out score);
            if (score == 0) score = 70;

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                string studentId = null;
                using (var cmd = new SqlCommand("SELECT studentId FROM Student WHERE userId=@u", conn))
                { cmd.Parameters.AddWithValue("@u", userId); studentId = cmd.ExecuteScalar()?.ToString(); }
                if (string.IsNullOrEmpty(studentId)) return;

                bool exists = false;
                if (Tbl("LabProgress"))
                {
                    using (var cmd = new SqlCommand("SELECT COUNT(*) FROM LabProgress WHERE studentId=@s AND labId=@l", conn))
                    { cmd.Parameters.AddWithValue("@s", studentId); cmd.Parameters.AddWithValue("@l", labId); exists = (int)cmd.ExecuteScalar() > 0; }
                }

                if (!exists && Tbl("LabProgress"))
                {
                    string pid = "LP" + DateTime.Now.ToString("yyyyMMddHHmmss");
                    using (var cmd = new SqlCommand(@"INSERT INTO LabProgress(labProgressId,studentId,labId,isCompleted,score,completedDate)
                        VALUES(@pid,@s,@l,1,@sc,@dt)", conn))
                    {
                        cmd.Parameters.AddWithValue("@pid", pid); cmd.Parameters.AddWithValue("@s", studentId);
                        cmd.Parameters.AddWithValue("@l", labId); cmd.Parameters.AddWithValue("@sc", score);
                        cmd.Parameters.AddWithValue("@dt", DateTime.Now); cmd.ExecuteNonQuery();
                    }
                    AwardXP(conn, studentId, labId);
                }
                else if (Tbl("LabProgress"))
                {
                    using (var cmd = new SqlCommand("UPDATE LabProgress SET isCompleted=1,score=@sc,completedDate=@dt WHERE studentId=@s AND labId=@l", conn))
                    { cmd.Parameters.AddWithValue("@sc", score); cmd.Parameters.AddWithValue("@dt", DateTime.Now);
                      cmd.Parameters.AddWithValue("@s", studentId); cmd.Parameters.AddWithValue("@l", labId); cmd.ExecuteNonQuery(); }
                }
            }

            btnComplete.Enabled = false; btnComplete.Text = T("? Completed","? Selesai"); btnComplete.CssClass = "sb-btn sb-btn-success";
            pnlSuccess.Visible = true; litSuccess.Text = T("?? Lab completed! You earned XP!","?? Makmal selesai! Anda memperoleh XP!");
        }

        private void AwardXP(SqlConnection conn, string studentId, string labId)
        {
            if (!Tbl("XPAction") || !Tbl("XPTransaction")) return;
            int xp = 0; string aid = null;
            using (var cmd = new SqlCommand("SELECT xpActionId,xpValue FROM XPAction WHERE actionNameEN='Complete Virtual Lab'", conn))
            using (var r = cmd.ExecuteReader()) { if (r.Read()) { aid = r["xpActionId"].ToString(); xp = Convert.ToInt32(r["xpValue"]); } }
            if (xp == 0) return;
            using (var cmd = new SqlCommand("SELECT COUNT(*) FROM XPTransaction WHERE studentId=@s AND xpActionId=@a AND referenceId=@r", conn))
            { cmd.Parameters.AddWithValue("@s", studentId); cmd.Parameters.AddWithValue("@a", aid); cmd.Parameters.AddWithValue("@r", labId);
              if ((int)cmd.ExecuteScalar() > 0) return; }
            string tid = "XPT" + DateTime.Now.ToString("yyyyMMddHHmmss");
            using (var cmd = new SqlCommand("INSERT INTO XPTransaction(xpTransactionId,studentId,xpActionId,xpEarned,referenceId,earnedAt) VALUES(@id,@s,@a,@xp,@r,@dt)", conn))
            { cmd.Parameters.AddWithValue("@id", tid); cmd.Parameters.AddWithValue("@s", studentId); cmd.Parameters.AddWithValue("@a", aid);
              cmd.Parameters.AddWithValue("@xp", xp); cmd.Parameters.AddWithValue("@r", labId); cmd.Parameters.AddWithValue("@dt", DateTime.Now); cmd.ExecuteNonQuery(); }
            using (var cmd = new SqlCommand("UPDATE Student SET XP=XP+@xp WHERE studentId=@s", conn))
            { cmd.Parameters.AddWithValue("@xp", xp); cmd.Parameters.AddWithValue("@s", studentId); cmd.ExecuteNonQuery(); }
        }

        private void ShowError() { pnlError.Visible = true; pnlMain.Visible = false;
            litErrorTitle.Text = T("Lab not available","Makmal tidak tersedia");
            litErrorDesc.Text = T("This lab cannot be loaded.","Makmal ini tidak dapat dimuatkan.");
            litErrorBtn.Text = T("Back","Kembali"); }

        private bool Tbl(string t) { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME=@t AND TABLE_TYPE='BASE TABLE'", c)) { cmd.Parameters.AddWithValue("@t", t); c.Open(); return (int)cmd.ExecuteScalar() > 0; } }
    }
}
