using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace ScienceBuddy.Teacher
{
    public partial class createPracticeQuiz : Page
    {
        protected string CurrentLanguage
        {
            get { string l = Session["preferredLanguage"] as string; return string.IsNullOrEmpty(l) ? "EN" : l; }
        }
        protected string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }

        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"]?.ToString() != "Teacher")
            { Response.Redirect("~/Login.aspx", false); Context.ApplicationInstance.CompleteRequest(); return; }

            var master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            // AJAX handlers — return JSON without full page lifecycle
            string handler = Request.QueryString["handler"] ?? "";
            if (handler == "levels")    { HandleLevels();    return; }
            if (handler == "units")     { HandleUnits();     return; }
            if (handler == "subtopics") { HandleSubtopics(); return; }

            if (!IsPostBack)
            {
                if (!AuthorizeTeacher()) return;
                ValidateAndLoad();
            }
        }

        // ── AJAX: all levels ─────────────────────────────────────────
        private void HandleLevels()
        {
            Response.Clear(); Response.ContentType = "application/json";
            try
            {
                var sb = new System.Text.StringBuilder("[");
                bool first = true;
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("SELECT [levelId],[levelNameEN] FROM dbo.[Level] ORDER BY [levelId]", conn))
                    using (var r = cmd.ExecuteReader())
                        while (r.Read())
                        {
                            if (!first) sb.Append(","); first = false;
                            sb.AppendFormat("{{\"id\":\"{0}\",\"name\":\"{1}\"}}",
                                HttpUtility.JavaScriptStringEncode(r["levelId"].ToString()),
                                HttpUtility.JavaScriptStringEncode(r["levelNameEN"].ToString()));
                        }
                }
                sb.Append("]");
                Response.Write(sb.ToString());
            }
            catch { Response.Write("[]"); }
            Response.End();
        }

        // ── AJAX: units by level ─────────────────────────────────────
        private void HandleUnits()
        {
            Response.Clear(); Response.ContentType = "application/json";
            string levelId = (Request.QueryString["levelId"] ?? "").Trim();
            if (string.IsNullOrEmpty(levelId)) { Response.Write("[]"); Response.End(); return; }
            try
            {
                var sb = new System.Text.StringBuilder("[");
                bool first = true;
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("SELECT [unitId],[unitNameEN] FROM dbo.[Unit] WHERE [levelId]=@l ORDER BY [orderNo]", conn))
                    {
                        cmd.Parameters.AddWithValue("@l", levelId);
                        using (var r = cmd.ExecuteReader())
                            while (r.Read())
                            {
                                if (!first) sb.Append(","); first = false;
                                sb.AppendFormat("{{\"id\":\"{0}\",\"name\":\"{1}\"}}",
                                    HttpUtility.JavaScriptStringEncode(r["unitId"].ToString()),
                                    HttpUtility.JavaScriptStringEncode(r["unitNameEN"].ToString()));
                            }
                    }
                }
                sb.Append("]");
                Response.Write(sb.ToString());
            }
            catch { Response.Write("[]"); }
            Response.End();
        }

        // ── AJAX: subtopics by unit ──────────────────────────────────
        private void HandleSubtopics()
        {
            Response.Clear(); Response.ContentType = "application/json";
            string unitId = (Request.QueryString["unitId"] ?? "").Trim();
            if (string.IsNullOrEmpty(unitId)) { Response.Write("[]"); Response.End(); return; }
            try
            {
                var sb = new System.Text.StringBuilder("[");
                bool first = true;
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("SELECT [subtopicId],[subtopicTitleEN] FROM dbo.[Subtopic] WHERE [unitId]=@u ORDER BY [orderNo]", conn))
                    {
                        cmd.Parameters.AddWithValue("@u", unitId);
                        using (var r = cmd.ExecuteReader())
                            while (r.Read())
                            {
                                if (!first) sb.Append(","); first = false;
                                sb.AppendFormat("{{\"id\":\"{0}\",\"name\":\"{1}\"}}",
                                    HttpUtility.JavaScriptStringEncode(r["subtopicId"].ToString()),
                                    HttpUtility.JavaScriptStringEncode(r["subtopicTitleEN"].ToString()));
                            }
                    }
                }
                sb.Append("]");
                Response.Write(sb.ToString());
            }
            catch { Response.Write("[]"); }
            Response.End();
        }

        // ── Authorization ─────────────────────────────────────────────
        private bool AuthorizeTeacher()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [status] FROM dbo.[Teacher] WHERE [userId]=@u", conn))
                {
                    cmd.Parameters.AddWithValue("@u", Session["userId"].ToString());
                    var val = cmd.ExecuteScalar();
                    if (val == null || val == DBNull.Value ||
                        !val.ToString().Equals("Certified", StringComparison.OrdinalIgnoreCase))
                    { pnlDenied.Visible = true; return false; }
                }
            }
            return true;
        }

        // ── Validate query-string params and populate hero ────────────
        private void ValidateAndLoad()
        {
            string levelId    = (Request.QueryString["levelId"]    ?? "").Trim();
            string unitId     = (Request.QueryString["unitId"]     ?? "").Trim();
            string subtopicId = (Request.QueryString["subtopicId"] ?? "").Trim();
            string language   = (Request.QueryString["language"]   ?? "").Trim().ToUpperInvariant();

            if (string.IsNullOrEmpty(levelId) || string.IsNullOrEmpty(unitId) ||
                string.IsNullOrEmpty(subtopicId) || string.IsNullOrEmpty(language))
            {
                ShowInvalid(T("Missing required parameters. Please go back and select a Level, Unit, Subtopic, and Language.",
                              "Parameter diperlukan tidak lengkap. Sila kembali dan pilih Tahap, Unit, Subtopik, dan Bahasa."));
                return;
            }

            if (language != "EN" && language != "BM")
            {
                ShowInvalid(T("Invalid language selection.", "Pilihan bahasa tidak sah.")); return;
            }

            string levelName = null, unitName = null, subtopicName = null;

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                using (var cmd = new SqlCommand("SELECT [levelNameEN] FROM dbo.[Level] WHERE [levelId]=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", levelId);
                    var v = cmd.ExecuteScalar();
                    if (v == null || v == DBNull.Value) { ShowInvalid(T("The selected Level does not exist.", "Tahap yang dipilih tidak wujud.")); return; }
                    levelName = v.ToString();
                }

                using (var cmd = new SqlCommand("SELECT [unitNameEN] FROM dbo.[Unit] WHERE [unitId]=@uid AND [levelId]=@lid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", unitId);
                    cmd.Parameters.AddWithValue("@lid", levelId);
                    var v = cmd.ExecuteScalar();
                    if (v == null || v == DBNull.Value) { ShowInvalid(T("The selected Unit does not belong to the chosen Level.", "Unit yang dipilih tidak tergolong dalam Tahap yang dipilih.")); return; }
                    unitName = v.ToString();
                }

                using (var cmd = new SqlCommand("SELECT [subtopicTitleEN] FROM dbo.[Subtopic] WHERE [subtopicId]=@sid AND [unitId]=@uid", conn))
                {
                    cmd.Parameters.AddWithValue("@sid", subtopicId);
                    cmd.Parameters.AddWithValue("@uid", unitId);
                    var v = cmd.ExecuteScalar();
                    if (v == null || v == DBNull.Value) { ShowInvalid(T("The selected Subtopic does not belong to the chosen Unit.", "Subtopik yang dipilih tidak tergolong dalam Unit yang dipilih.")); return; }
                    subtopicName = v.ToString();
                }
            }

            string langLabel = language == "BM" ? "Bahasa Melayu" : "English";

            litLevel.Text    = HttpUtility.HtmlEncode(levelName);
            litUnit.Text     = HttpUtility.HtmlEncode(unitName);
            litSubtopic.Text = HttpUtility.HtmlEncode(subtopicName);
            litLanguage.Text = HttpUtility.HtmlEncode(langLabel);

            // Populate hidden fields for JS to read
            hidLevelId.Value    = levelId;
            hidUnitId.Value     = unitId;
            hidSubtopicId.Value = subtopicId;
            hidLanguage.Value   = language;

            pnlMain.Visible = true;
        }

        private void ShowInvalid(string message)
        {
            litInvalidMsg.Text = HttpUtility.HtmlEncode(message);
            pnlInvalid.Visible = true;
        }
    }
}
