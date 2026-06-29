using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace ScienceBuddy.Student
{
    public partial class VirtualLab : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        private string CurrentLanguage = "EN";
        private string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }

        // Lab routing map: labId -> aspx page filename
        private static readonly Dictionary<string, string> LabRoutes = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
        {
            { "LAB001", "MagneticForcesExplorer.aspx" },
            { "LAB002", "GreatSoakChallenge.aspx" },
            { "LAB003", "JourneyOfSandwich.aspx" },
            { "LAB004", "SinkOrFloatMaster.aspx" },
            { "LAB005", "LitmusTest.aspx" },
            { "LAB006", "BloodFlowSimulator.aspx" },
            { "LAB007", "CircuitLab.aspx" },
            { "LAB008", "MatterStateChanger.aspx" }
        };

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null || Session["role"].ToString() != "Student")
            { Response.Redirect("~/Login.aspx", false); return; }

            ((SiteMaster)Master).LayoutMode = "Sidebar";
            InitLang();

            string labId = Request.QueryString["labId"];
            if (string.IsNullOrEmpty(labId))
            { ShowError(T("No lab selected", "Tiada makmal dipilih"),
                T("Please select a virtual lab from the list.", "Sila pilih makmal maya dari senarai.")); return; }

            // Check if lab exists in routing map
            if (!LabRoutes.ContainsKey(labId))
            { ShowError(T("Lab not found", "Makmal tidak dijumpai"),
                T("This virtual lab does not exist or is not yet available.", "Makmal maya ini tidak wujud atau belum tersedia.")); return; }

            // Verify lab exists in database and student has access
            if (!Tbl("VirtualLab") || !Tbl("Student") || !Tbl("Unit"))
            { ShowError(T("Lab not available", "Makmal tidak tersedia"),
                T("Virtual labs are not configured yet.", "Makmal maya belum dikonfigurasi.")); return; }

            string userId = Session["userId"].ToString();
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Get student's current level
                string curLevel = "LV001";
                using (var cmd = new SqlCommand("SELECT currentlevelId FROM Student WHERE userId=@u", conn))
                { cmd.Parameters.AddWithValue("@u", userId); var r = cmd.ExecuteScalar(); if (r != null) curLevel = r.ToString(); }

                // Get lab's level via Unit
                string labLevel = null;
                using (var cmd = new SqlCommand(@"SELECT u.levelId FROM VirtualLab v
                    JOIN Unit u ON u.unitId=v.unitId WHERE v.labId=@l", conn))
                { cmd.Parameters.AddWithValue("@l", labId); var r = cmd.ExecuteScalar(); labLevel = r?.ToString(); }

                if (string.IsNullOrEmpty(labLevel))
                { ShowError(T("Lab not found", "Makmal tidak dijumpai"),
                    T("This lab does not exist in the database.", "Makmal ini tidak wujud dalam pangkalan data.")); return; }

                // Access check
                if (Ord(labLevel) > Ord(curLevel))
                { ShowError(T("Lab Locked", "Makmal Dikunci"),
                    T("Complete your current level to unlock this lab.", "Selesaikan tahap semasa untuk membuka makmal ini.")); return; }
            }

            // All checks passed — redirect to specific lab activity page
            string targetPage = LabRoutes[labId];
            string targetUrl = ResolveUrl("~/Student/Labs/" + targetPage + "?labId=" + labId);
            Response.Redirect(targetUrl, false);
        }

        private void ShowError(string title, string desc)
        {
            pnlError.Visible = true;
            litErrorTitle.Text = title;
            litErrorDesc.Text = desc;
            litErrorBtn.Text = T("Back to Virtual Labs", "Kembali ke Makmal Maya");
            litPageTitle.Text = T("Virtual Lab", "Makmal Maya");
        }

        private void InitLang()
        {
            string l = Session["preferredLanguage"] as string;
            if (!string.IsNullOrEmpty(l)) { CurrentLanguage = l; return; }
            string uid = Session["userId"] as string;
            if (!string.IsNullOrEmpty(uid))
            { try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT preferredLanguage FROM [User] WHERE userId=@u", c))
              { cmd.Parameters.AddWithValue("@u", uid); c.Open(); var r = cmd.ExecuteScalar();
                if (r != null && r != System.DBNull.Value) { l = r.ToString(); Session["preferredLanguage"] = l; CurrentLanguage = l; return; } } } catch {} }
            CurrentLanguage = "EN"; Session["preferredLanguage"] = "EN";
        }

        private static int Ord(string id) { switch (id) { case "LV001": return 1; case "LV002": return 2; case "LV003": return 3; default: return 0; } }
        private bool Tbl(string t) { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME=@t AND TABLE_TYPE='BASE TABLE'", c)) { cmd.Parameters.AddWithValue("@t", t); c.Open(); return (int)cmd.ExecuteScalar() > 0; } }
    }
}
