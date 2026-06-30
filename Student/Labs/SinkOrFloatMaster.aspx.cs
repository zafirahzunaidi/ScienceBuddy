using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace ScienceBuddy.Student.Labs
{
    public partial class SinkOrFloatMaster : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
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
            string labId = Request.QueryString["labId"] ?? "LAB004";
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
                            litDiff.Text = r["difficulty"]?.ToString() ?? "Easy";
                        }
                    }
                }

                if (Tbl("LabProgress"))
                {
                    using (var cmd = new SqlCommand("SELECT isCompleted FROM LabProgress WHERE studentId=@s AND labId=@l", conn))
                    {
                        cmd.Parameters.AddWithValue("@s", _studentId); cmd.Parameters.AddWithValue("@l", labId);
                        var r = cmd.ExecuteScalar();
                        if (r != null && Convert.ToBoolean(r))
                        {
                            btnComplete.Enabled = false; btnComplete.Text = T("✓ Completed", "✓ Selesai");
                            btnComplete.CssClass = "sb-btn sb-btn-success";
                        }
                    }
                }
            }

            SetLabels();
        }

        private void SetLabels()
        {
            litBack.Text = T("Virtual Labs", "Makmal Maya");
            litStep1Title.Text = T("Step 1: Predict & Test", "Langkah 1: Ramal & Uji");
            litStep1Inst.Text = T("Select an object, predict if it will sink or float, then watch what happens!",
                "Pilih objek, ramalkan sama ada ia akan tenggelam atau terapung, kemudian lihat apa yang berlaku!");
            litStep2Title.Text = T("Step 2: Change the Density", "Langkah 2: Ubah Ketumpatan");
            litStep2Inst.Text = T("Add salt or sugar to make water denser. Can you make a marble float?",
                "Tambah garam atau gula untuk menjadikan air lebih pekat. Bolehkah anda membuat guli terapung?");
            litObjMarble.Text = T("Marble", "Guli");
            litObjCork.Text = T("Cork", "Gabus");
            litObjBall.Text = T("Plastic Ball", "Bola Plastik");
            litObjSpoon.Text = T("Metal Spoon", "Sudu Logam");
            litObjWood.Text = T("Wood Block", "Blok Kayu");
            litSink.Text = T("Sink", "Tenggelam");
            litFloat.Text = T("Float", "Terapung");
            litDensityLabel.Text = T("Add Salt/Sugar to Water", "Tambah Garam/Gula ke Air");
            btnComplete.Text = T("Complete Lab 🎉", "Selesaikan Makmal 🎉");
            litErrorBtn.Text = T("Back to Virtual Labs", "Kembali ke Makmal Maya");
        }

        protected void btnComplete_Click(object sender, EventArgs e)
        {
            InitLang();
            string labId = Request.QueryString["labId"] ?? "LAB004";
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
                    string pid = "LPR001";
                    using (var seqCmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING(labProgressId,4,LEN(labProgressId)-3) AS INT)),0) FROM LabProgress WHERE labProgressId LIKE 'LPR[0-9]%'", conn))
                    { int last = Convert.ToInt32(seqCmd.ExecuteScalar()); pid = "LPR" + (last + 1).ToString("D3"); }
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
                    {
                        cmd.Parameters.AddWithValue("@sc", score); cmd.Parameters.AddWithValue("@dt", DateTime.Now);
                        cmd.Parameters.AddWithValue("@s", studentId); cmd.Parameters.AddWithValue("@l", labId); cmd.ExecuteNonQuery();
                    }
                }
            }

            btnComplete.Enabled = false; btnComplete.Text = T("✓ Completed", "✓ Selesai"); btnComplete.CssClass = "sb-btn sb-btn-success";
            pnlSuccess.Visible = true; litSuccess.Text = T("🎉 Lab completed! You earned XP!", "🎉 Makmal selesai! Anda memperoleh XP!");
        }

        private void AwardXP(SqlConnection conn, string studentId, string labId)
        {
            if (!Tbl("XPAction") || !Tbl("XPTransaction")) return;
            int xp = 0; string aid = null;
            using (var cmd = new SqlCommand("SELECT xpActionId,xpValue FROM XPAction WHERE actionNameEN='Complete Virtual Lab'", conn))
            using (var r = cmd.ExecuteReader()) { if (r.Read()) { aid = r["xpActionId"].ToString(); xp = Convert.ToInt32(r["xpValue"]); } }
            if (xp == 0) return;
            using (var cmd = new SqlCommand("SELECT COUNT(*) FROM XPTransaction WHERE studentId=@s AND xpActionId=@a AND referenceId=@r", conn))
            {
                cmd.Parameters.AddWithValue("@s", studentId); cmd.Parameters.AddWithValue("@a", aid); cmd.Parameters.AddWithValue("@r", labId);
                if ((int)cmd.ExecuteScalar() > 0) return;
            }
            string tid = "XPT" + DateTime.Now.ToString("yyyyMMddHHmmss");
            using (var cmd = new SqlCommand("INSERT INTO XPTransaction(xpTransactionId,studentId,xpActionId,xpEarned,referenceId,earnedAt) VALUES(@id,@s,@a,@xp,@r,@dt)", conn))
            {
                cmd.Parameters.AddWithValue("@id", tid); cmd.Parameters.AddWithValue("@s", studentId); cmd.Parameters.AddWithValue("@a", aid);
                cmd.Parameters.AddWithValue("@xp", xp); cmd.Parameters.AddWithValue("@r", labId); cmd.Parameters.AddWithValue("@dt", DateTime.Now); cmd.ExecuteNonQuery();
            }
            using (var cmd = new SqlCommand("UPDATE Student SET XP=XP+@xp WHERE studentId=@s", conn))
            { cmd.Parameters.AddWithValue("@xp", xp); cmd.Parameters.AddWithValue("@s", studentId); cmd.ExecuteNonQuery(); }
        }

        private void ShowError()
        {
            pnlError.Visible = true; pnlMain.Visible = false;
            litErrorTitle.Text = T("Lab not available", "Makmal tidak tersedia");
            litErrorDesc.Text = T("This lab cannot be loaded.", "Makmal ini tidak dapat dimuatkan.");
            litErrorBtn.Text = T("Back", "Kembali");
        }

        private bool Tbl(string t)
        {
            using (var c = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME=@t AND TABLE_TYPE='BASE TABLE'", c))
            { cmd.Parameters.AddWithValue("@t", t); c.Open(); return (int)cmd.ExecuteScalar() > 0; }
        }
    }
}
