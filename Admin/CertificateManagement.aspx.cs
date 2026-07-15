using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using iTextSharp.text;
using iTextSharp.text.pdf;

namespace ScienceBuddy.Admin
{
    public partial class CertificateManagement : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        protected string CurrentLanguage => ((ScienceBuddy.SiteMaster)Master).CurrentLanguage;
        protected string T(string en, string bm) { return CurrentLanguage == "BM" ? bm : en; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null) { Response.Redirect("~/Login.aspx", false); return; }
            if (Session["role"] == null || Session["role"].ToString() != "Admin") { Response.Redirect("~/Login.aspx", false); return; }
            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            if (!IsPostBack) { SetMasterUser(); LoadAll(); }
            btnCloseModal.Text = T("Close", "Tutup");
            btnModalSend.OnClientClick = "return swalConfirmSend(this, '" + T("Send this certificate?", "Hantar sijil ini?") + "', '" + T("Send", "Hantar") + "');";
        }

        private void SetMasterUser()
        {
            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                using (var cmd = new SqlCommand("SELECT [username] FROM dbo.[User] WHERE [userId]=@uid", conn))
                { cmd.Parameters.AddWithValue("@uid", Session["userId"].ToString());
                  var v = cmd.ExecuteScalar(); string n = v != null && v != DBNull.Value ? v.ToString() : "Admin";
                  ((ScienceBuddy.SiteMaster)Master).SetUserInfo(n, "Administrator", n.Length >= 2 ? n.Substring(0, 2).ToUpper() : n.ToUpper()); } }
        }

        private void LoadAll()
        {
            using (var conn = new SqlConnection(ConnStr)) { conn.Open(); FixExistingTitles(conn); LoadStats(conn); LoadCerts(conn); LoadEligible(conn); }
        }

        /// <summary>Fix existing certificate records that have generic titles</summary>
        private void FixExistingTitles(SqlConnection conn)
        {
            try
            {
                using (var cmd = new SqlCommand(@"
                    UPDATE dbo.[Certificate] SET
                        [certificateTitleEN] = CASE [levelId]
                            WHEN 'LV001' THEN 'Beginner Science Completion Certificate'
                            WHEN 'LV002' THEN 'Intermediate Science Completion Certificate'
                            WHEN 'LV003' THEN 'Advanced Science Completion Certificate'
                            ELSE [certificateTitleEN] END,
                        [certificateTitleBM] = CASE [levelId]
                            WHEN 'LV001' THEN 'Sijil Tamat Sains Pemula'
                            WHEN 'LV002' THEN 'Sijil Tamat Sains Pertengahan'
                            WHEN 'LV003' THEN 'Sijil Tamat Sains Lanjutan'
                            ELSE [certificateTitleBM] END
                    WHERE [certificateTitleEN] LIKE '%Certificate of Completion%'
                       OR [certificateTitleEN] LIKE '%Sijil Penyempurnaan%'
                       OR [certificateTitleEN] IS NULL", conn))
                { cmd.ExecuteNonQuery(); }
            }
            catch { }
        }

        private void LoadStats(SqlConnection conn)
        {
            litTotal.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[Certificate]");
            litGenerated.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[Certificate] WHERE [status] IS NOT NULL");
            litSent.Text = SS(conn, "SELECT COUNT(*) FROM dbo.[Certificate] WHERE [status]='Active'");
            // "Ready" = enrolled students at a level who don't have a cert for that level yet
            litReady.Text = SS(conn, @"SELECT COUNT(*) FROM dbo.[Enrollment] en
                WHERE en.[status]='Active' AND NOT EXISTS(SELECT 1 FROM dbo.[Certificate] c WHERE c.[studentId]=en.[studentId] AND c.[levelId]=en.[levelId])");
        }

        private void LoadCerts(SqlConnection conn)
        {
            string lCol = CurrentLanguage == "BM" ? "lv.[levelNameBM]" : "lv.[levelNameEN]";
            string tCol = CurrentLanguage == "BM" ? "c.[certificateTitleBM]" : "c.[certificateTitleEN]";
            string sql = string.Format(@"SELECT c.[certificateId],c.[certificateCode],c.[issuedDate],c.[status],
                s.[name] AS studentName, s.[userId] AS studentUserId,
                ISNULL({0},'-') AS levelName, ISNULL({1},c.[certificateTitleEN]) AS title
                FROM dbo.[Certificate] c
                LEFT JOIN dbo.[Student] s ON s.[studentId]=c.[studentId]
                LEFT JOIN dbo.[Level] lv ON lv.[levelId]=c.[levelId]
                ORDER BY c.[issuedDate] DESC", lCol, tCol);
            using (var cmd = new SqlCommand(sql, conn)) {
                var da = new SqlDataAdapter(cmd); var dt = new DataTable(); da.Fill(dt);
                if (dt.Rows.Count == 0) { pnlCerts.Visible = false; pnlEmpty.Visible = true; return; }
                var list = new List<object>();
                foreach (DataRow r in dt.Rows) {
                    string st = NS(r["status"]);
                    list.Add(new { certId = r["certificateId"].ToString(), studentName = NS(r["studentName"]),
                        studentUserId = NS(r["studentUserId"]), levelName = NS(r["levelName"]), title = NS(r["title"]),
                        issuedStr = r["issuedDate"] == DBNull.Value ? "-" : Convert.ToDateTime(r["issuedDate"]).ToString("d MMM yyyy"),
                        code = NS(r["certificateCode"]),
                        statusLabel = st == "Active" ? T("Sent", "Dihantar") : T("Generated", "Dijana"),
                        statusCls = st == "Active" ? "sb-badge-success" : "sb-badge-warning",
                        canSend = st != "Active" });
                }
                pnlCerts.Visible = true; pnlEmpty.Visible = false; rptCerts.DataSource = list; rptCerts.DataBind();
            }
        }

        private void LoadEligible(SqlConnection conn)
        {
            string lCol = CurrentLanguage == "BM" ? "lv.[levelNameBM]" : "lv.[levelNameEN]";
            string sql = string.Format(@"SELECT en.[studentId], en.[levelId], s.[name] AS studentName, s.[userId] AS studentUserId,
                ISNULL({0},'-') AS levelName
                FROM dbo.[Enrollment] en
                JOIN dbo.[Student] s ON s.[studentId]=en.[studentId]
                LEFT JOIN dbo.[Level] lv ON lv.[levelId]=en.[levelId]
                WHERE en.[status]='Active'
                AND NOT EXISTS(SELECT 1 FROM dbo.[Certificate] c WHERE c.[studentId]=en.[studentId] AND c.[levelId]=en.[levelId])
                ORDER BY s.[name]", lCol);
            using (var cmd = new SqlCommand(sql, conn)) {
                var da = new SqlDataAdapter(cmd); var dt = new DataTable(); da.Fill(dt);
                if (dt.Rows.Count == 0) { pnlEligible.Visible = false; pnlNoEligible.Visible = true; return; }
                var list = new List<object>();
                foreach (DataRow r in dt.Rows) {
                    list.Add(new { studentId = r["studentId"].ToString(), levelId = r["levelId"].ToString(),
                        studentName = NS(r["studentName"]), studentUserId = NS(r["studentUserId"]), levelName = NS(r["levelName"]) });
                }
                pnlEligible.Visible = true; pnlNoEligible.Visible = false; rptEligible.DataSource = list; rptEligible.DataBind();
            }
        }

        // ── Generate Certificate ─────────────────────────────────────
        protected void rptEligible_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "Generate") return;
            string[] p = e.CommandArgument.ToString().Split('|');
            if (p.Length < 5) return;
            string studentId = p[0], levelId = p[1], studentName = p[2], levelName = p[3], studentUserId = p[4];

            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                string certId = GenId(conn, "Certificate", "CERT");
                string code = "SB-" + DateTime.Now.ToString("yyyyMMdd") + "-" + certId;
                
                // Level-specific titles
                string titleEN, titleBM;
                switch (levelId)
                {
                    case "LV002": titleEN = "Intermediate Science Completion Certificate"; titleBM = "Sijil Tamat Sains Pertengahan"; break;
                    case "LV003": titleEN = "Advanced Science Completion Certificate"; titleBM = "Sijil Tamat Sains Lanjutan"; break;
                    default:      titleEN = "Beginner Science Completion Certificate"; titleBM = "Sijil Tamat Sains Pemula"; break;
                }
                
                string descEN = "Awarded to " + studentName + " for successfully completing the " + levelName + " level in ScienceBuddy.";
                string descBM = "Dianugerahkan kepada " + studentName + " kerana berjaya menamatkan tahap " + levelName + " dalam ScienceBuddy.";
                string fileName = "cert_" + studentId.ToLower() + "_" + levelId.ToLower() + ".pdf";
                string url = "Images/Certificate/" + fileName;

                // Generate physical certificate file
                GenerateCertificateFile(studentName, levelName, descEN, code, DateTime.Today, fileName, titleEN);

                using (var cmd = new SqlCommand(@"INSERT INTO dbo.[Certificate]
                    ([certificateId],[studentId],[levelId],[certificateTitleEN],[certificateTitleBM],[certificateDescriptionEN],[certificateDescriptionBM],[issuedDate],[certificateUrl],[certificateCode],[status])
                    VALUES(@id,@sid,@lid,@tEN,@tBM,@dEN,@dBM,@dt,@url,@code,'Generated')", conn))
                { cmd.Parameters.AddWithValue("@id", certId); cmd.Parameters.AddWithValue("@sid", studentId);
                  cmd.Parameters.AddWithValue("@lid", levelId); cmd.Parameters.AddWithValue("@tEN", titleEN);
                  cmd.Parameters.AddWithValue("@tBM", titleBM); cmd.Parameters.AddWithValue("@dEN", descEN);
                  cmd.Parameters.AddWithValue("@dBM", descBM); cmd.Parameters.AddWithValue("@dt", DateTime.Today);
                  cmd.Parameters.AddWithValue("@url", url); cmd.Parameters.AddWithValue("@code", code);
                  cmd.ExecuteNonQuery(); }

                InsertLog(conn, "Certificate Generated", "Generated " + levelName + " certificate for " + studentName + ".", "Success");
            }
            ShowToast(T("Certificate generated successfully.", "Sijil berjaya dijana."), true);
            using (var conn = new SqlConnection(ConnStr)) { conn.Open(); LoadStats(conn); LoadCerts(conn); LoadEligible(conn); }
        }

        /// <summary>
        /// Generates a self-contained HTML certificate file.
        /// </summary>
        private void GenerateCertificateFile(string studentName, string levelName, string description, string code, DateTime issueDate, string fileName, string certTitle)
        {
            try
            {
                string dirPath = Server.MapPath("~/Images/Certificate/");
                if (!System.IO.Directory.Exists(dirPath))
                    System.IO.Directory.CreateDirectory(dirPath);

                string filePath = System.IO.Path.Combine(dirPath, fileName);
                string adminName = GetAdminSignatureName();
                BuildCertificatePdf(filePath, studentName, levelName, description, code, issueDate, certTitle, adminName);
            }
            catch { }
        }

        private string GetAdminSignatureName()
        {
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("SELECT [username] FROM dbo.[User] WHERE [userId]=@uid", conn))
                    {
                        cmd.Parameters.AddWithValue("@uid", Session["userId"].ToString());
                        var v = cmd.ExecuteScalar();
                        string username = (v != null && v != DBNull.Value) ? v.ToString() : "Admin";
                        string clean = System.Text.RegularExpressions.Regex.Replace(username, @"\d+$", "");
                        if (string.IsNullOrWhiteSpace(clean)) clean = username;
                        return char.ToUpper(clean[0]) + clean.Substring(1).ToLower();
                    }
                }
            }
            catch { return "Administrator"; }
        }

        private void BuildCertificatePdf(string filePath, string studentName, string levelName, string description, string code, DateTime issueDate, string certTitle, string adminName)
        {
            var pageSize = new Rectangle(PageSize.A4.Height, PageSize.A4.Width);
            using (var fs = new System.IO.FileStream(filePath, System.IO.FileMode.Create))
            {
                var doc = new Document(pageSize, 0, 0, 0, 0);
                var writer = PdfWriter.GetInstance(doc, fs);
                doc.Open();

                BaseColor borderColor, accentColor, ribbonColor;
                string lvl = levelName.ToLower();
                if (lvl.Contains("advanced") || lvl.Contains("lanjutan"))
                { borderColor = new BaseColor(184, 134, 11); accentColor = new BaseColor(30, 58, 95); ribbonColor = new BaseColor(184, 134, 11); }
                else if (lvl.Contains("intermediate") || lvl.Contains("pertengahan"))
                { borderColor = new BaseColor(100, 116, 139); accentColor = new BaseColor(51, 65, 85); ribbonColor = new BaseColor(71, 85, 105); }
                else
                { borderColor = new BaseColor(37, 99, 235); accentColor = new BaseColor(29, 78, 216); ribbonColor = new BaseColor(37, 99, 235); }

                float w = pageSize.Width, h = pageSize.Height;
                var cb = writer.DirectContent;

                // ── Clean white background ──
                cb.SetColorFill(BaseColor.WHITE);
                cb.Rectangle(0, 0, w, h); cb.Fill();

                // ── Elegant double border ──
                cb.SetColorStroke(borderColor); cb.SetLineWidth(2.5f);
                cb.Rectangle(22, 22, w - 44, h - 44); cb.Stroke();
                cb.SetLineWidth(0.7f);
                cb.Rectangle(28, 28, w - 56, h - 56); cb.Stroke();

                // ── Subtle watermark ──
                cb.SaveState();
                cb.SetGState(new PdfGState { FillOpacity = 0.02f });
                cb.SetColorFill(BaseColor.BLACK);
                cb.BeginText();
                cb.SetFontAndSize(BaseFont.CreateFont(BaseFont.HELVETICA_BOLD, BaseFont.CP1252, false), 55);
                cb.ShowTextAligned(PdfContentByte.ALIGN_CENTER, "SCIENCEBUDDY", w / 2, h / 2 - 20, 0);
                cb.EndText();
                cb.RestoreState();

                // ── Logo ──
                try
                {
                    string logoPath = Server.MapPath("~/Images/Logo/sciencebuddy-logo.png");
                    if (System.IO.File.Exists(logoPath))
                    {
                        var logo = iTextSharp.text.Image.GetInstance(logoPath);
                        logo.ScaleToFit(55, 55);
                        logo.SetAbsolutePosition(w / 2 - 27, h - 110);
                        cb.AddImage(logo);
                    }
                }
                catch { }

                // ── Brand ──
                var bfBold = BaseFont.CreateFont(BaseFont.HELVETICA_BOLD, BaseFont.CP1252, false);
                var bfItalic = BaseFont.CreateFont(BaseFont.TIMES_ITALIC, BaseFont.CP1252, false);
                var bfTimesBold = BaseFont.CreateFont(BaseFont.TIMES_BOLD, BaseFont.CP1252, false);
                var bfHelv = BaseFont.CreateFont(BaseFont.HELVETICA, BaseFont.CP1252, false);

                cb.BeginText();
                cb.SetFontAndSize(bfBold, 15);
                cb.SetColorFill(new BaseColor(37, 99, 235));
                cb.ShowTextAligned(PdfContentByte.ALIGN_RIGHT, "Science", w / 2 + 1, h - 125, 0);
                cb.SetColorFill(new BaseColor(255, 107, 44));
                cb.ShowTextAligned(PdfContentByte.ALIGN_LEFT, "Buddy", w / 2 + 3, h - 125, 0);
                cb.EndText();

                // ── Certificate Title (elegant, not all caps) ──
                cb.BeginText();
                cb.SetFontAndSize(bfTimesBold, 24);
                cb.SetColorFill(accentColor);
                cb.ShowTextAligned(PdfContentByte.ALIGN_CENTER, certTitle, w / 2, h - 160, 0);
                cb.EndText();

                // ── Ornamental line with dot ──
                float ornY = h - 175;
                cb.SetColorStroke(new BaseColor(201, 168, 76)); cb.SetLineWidth(0.8f);
                cb.MoveTo(w / 2 - 80, ornY); cb.LineTo(w / 2 - 4, ornY); cb.Stroke();
                cb.MoveTo(w / 2 + 4, ornY); cb.LineTo(w / 2 + 80, ornY); cb.Stroke();
                cb.SetColorFill(new BaseColor(201, 168, 76));
                cb.Circle(w / 2, ornY, 2); cb.Fill();

                // ── "This certificate is proudly presented to" ──
                cb.BeginText();
                cb.SetFontAndSize(bfItalic, 12);
                cb.SetColorFill(new BaseColor(107, 114, 128));
                cb.ShowTextAligned(PdfContentByte.ALIGN_CENTER, "This certificate is proudly presented to", w / 2, h - 210, 0);
                cb.EndText();

                // ── Student Name ──
                float nameSize = studentName.Length > 22 ? 28 : 34;
                cb.BeginText();
                cb.SetFontAndSize(bfTimesBold, nameSize);
                cb.SetColorFill(new BaseColor(17, 24, 39));
                cb.ShowTextAligned(PdfContentByte.ALIGN_CENTER, studentName, w / 2, h - 250, 0);
                cb.EndText();

                // ── Line under name ──
                cb.SetColorStroke(borderColor); cb.SetLineWidth(1.2f);
                cb.MoveTo(w / 2 - 70, h - 262); cb.LineTo(w / 2 + 70, h - 262); cb.Stroke();

                // ── "For successfully completing" ──
                cb.BeginText();
                cb.SetFontAndSize(bfItalic, 11);
                cb.SetColorFill(new BaseColor(107, 114, 128));
                cb.ShowTextAligned(PdfContentByte.ALIGN_CENTER, "For successfully completing", w / 2, h - 290, 0);
                cb.EndText();

                // ── Level Ribbon ──
                float rW = 140, rH = 24, rX = w / 2 - rW / 2, rY = h - 325;
                cb.SetColorFill(ribbonColor);
                cb.RoundRectangle(rX, rY, rW, rH, 4); cb.Fill();
                cb.BeginText();
                cb.SetFontAndSize(bfBold, 11);
                cb.SetColorFill(BaseColor.WHITE);
                cb.ShowTextAligned(PdfContentByte.ALIGN_CENTER, levelName.ToUpper(), w / 2, rY + 7, 0);
                cb.EndText();

                // ── Description ──
                string desc = description;
                cb.BeginText();
                cb.SetFontAndSize(bfItalic, 9);
                cb.SetColorFill(new BaseColor(75, 85, 99));
                cb.ShowTextAligned(PdfContentByte.ALIGN_CENTER, desc, w / 2, h - 358, 0);
                cb.EndText();

                // ══ FOOTER SECTION ══
                float footY = 140;
                // Separator line
                cb.SetColorStroke(new BaseColor(229, 221, 208)); cb.SetLineWidth(0.8f);
                cb.MoveTo(60, footY + 30); cb.LineTo(w - 60, footY + 30); cb.Stroke();

                // Col 1: Certificate No
                cb.BeginText(); cb.SetFontAndSize(bfBold, 7.5f); cb.SetColorFill(new BaseColor(31, 41, 55));
                cb.ShowTextAligned(PdfContentByte.ALIGN_CENTER, code, 155, footY, 0); cb.EndText();
                cb.BeginText(); cb.SetFontAndSize(bfHelv, 5.5f); cb.SetColorFill(new BaseColor(156, 163, 175));
                cb.ShowTextAligned(PdfContentByte.ALIGN_CENTER, "CERTIFICATE NO.", 155, footY - 10, 0); cb.EndText();

                // Col 2: Issue Date
                cb.BeginText(); cb.SetFontAndSize(bfBold, 7.5f); cb.SetColorFill(new BaseColor(31, 41, 55));
                cb.ShowTextAligned(PdfContentByte.ALIGN_CENTER, issueDate.ToString("d MMMM yyyy"), 330, footY, 0); cb.EndText();
                cb.BeginText(); cb.SetFontAndSize(bfHelv, 5.5f); cb.SetColorFill(new BaseColor(156, 163, 175));
                cb.ShowTextAligned(PdfContentByte.ALIGN_CENTER, "ISSUE DATE", 330, footY - 10, 0); cb.EndText();

                // Col 3: Seal
                float sX = 520, sY = footY + 2, sR = 18;
                cb.SetColorFill(accentColor); cb.Circle(sX, sY, sR); cb.Fill();
                cb.SetColorStroke(borderColor); cb.SetLineWidth(2f); cb.Circle(sX, sY, sR); cb.Stroke();
                cb.SetColorStroke(BaseColor.WHITE); cb.SetLineWidth(1f); cb.Circle(sX, sY, sR - 3.5f); cb.Stroke();
                cb.BeginText(); cb.SetFontAndSize(bfBold, 12); cb.SetColorFill(BaseColor.WHITE);
                cb.ShowTextAligned(PdfContentByte.ALIGN_CENTER, "SB", sX, sY - 4, 0); cb.EndText();
                cb.BeginText(); cb.SetFontAndSize(bfHelv, 5.5f); cb.SetColorFill(new BaseColor(156, 163, 175));
                cb.ShowTextAligned(PdfContentByte.ALIGN_CENTER, "VERIFIED", sX, footY - 22, 0); cb.EndText();

                // Col 4: Signature (clean script name)
                float sigCX = 690;
                // Just use elegant italic text - looks much cleaner than drawn curves
                var bfTimesBI = BaseFont.CreateFont(BaseFont.TIMES_BOLDITALIC, BaseFont.CP1252, false);
                cb.BeginText();
                cb.SetFontAndSize(bfTimesBI, 14);
                cb.SetColorFill(new BaseColor(20, 20, 60));
                cb.ShowTextAligned(PdfContentByte.ALIGN_CENTER, adminName, sigCX, footY + 5, 0);
                cb.EndText();
                // Label
                cb.BeginText(); cb.SetFontAndSize(bfHelv, 5.5f); cb.SetColorFill(new BaseColor(156, 163, 175));
                cb.ShowTextAligned(PdfContentByte.ALIGN_CENTER, "ADMINISTRATOR", sigCX, footY - 12, 0); cb.EndText();

                // ── Page footer text (well inside border) ──
                cb.BeginText(); cb.SetFontAndSize(bfHelv, 5f); cb.SetColorFill(new BaseColor(210, 215, 220));
                cb.ShowTextAligned(PdfContentByte.ALIGN_CENTER, "ScienceBuddy \u00a9 2026  \u2022  www.sciencebuddy.com  \u2022  Electronically Generated & Verified Certificate", w / 2, 38, 0);
                cb.EndText();

                doc.Close();
            }
        }

        // ── Send Certificate ─────────────────────────────────────────
        protected void rptCerts_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "ViewCert") { ShowViewModal(e.CommandArgument.ToString()); return; }
            if (e.CommandName != "SendCert") return;
            string[] p = e.CommandArgument.ToString().Split('|');
            if (p.Length < 4) return;
            string certId = p[0], studentUserId = p[1], studentName = p[2], levelName = p[3];

            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                // Update status
                using (var cmd = new SqlCommand("UPDATE dbo.[Certificate] SET [status]='Active' WHERE [certificateId]=@id", conn))
                { cmd.Parameters.AddWithValue("@id", certId); cmd.ExecuteNonQuery(); }

                // Notification
                string notifId = GenId(conn, "Notification", "N");
                using (var cmd = new SqlCommand(@"INSERT INTO dbo.[Notification]([notificationId],[toUserId],[titleEN],[titleBM],[messageEN],[messageBM],[isRead],[createdAt])
                    VALUES(@id,@uid,@tEN,@tBM,@mEN,@mBM,0,GETDATE())", conn))
                { cmd.Parameters.AddWithValue("@id", notifId); cmd.Parameters.AddWithValue("@uid", studentUserId);
                  cmd.Parameters.AddWithValue("@tEN", "Congratulations! Your Certificate is Ready");
                  cmd.Parameters.AddWithValue("@tBM", "Tahniah! Sijil Anda Telah Sedia");
                  cmd.Parameters.AddWithValue("@mEN", "Congratulations on completing the " + levelName + " level. Your certificate has been issued and is now available for download.");
                  cmd.Parameters.AddWithValue("@mBM", "Tahniah kerana menamatkan tahap " + levelName + ". Sijil anda telah dikeluarkan dan kini boleh dimuat turun.");
                  cmd.ExecuteNonQuery(); }

                // Log
                InsertLog(conn, "Certificate Sent", "Sent " + levelName + " certificate to " + studentName + ".", "Success");
            }
            ShowToast(T("Certificate sent successfully.", "Sijil berjaya dihantar."), true);
            using (var conn = new SqlConnection(ConnStr)) { conn.Open(); LoadStats(conn); LoadCerts(conn); LoadEligible(conn); }
        }

        private void ShowViewModal(string certId)
        {
            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                string dCol = CurrentLanguage == "BM" ? "c.[certificateDescriptionBM]" : "c.[certificateDescriptionEN]";
                string lCol = CurrentLanguage == "BM" ? "lv.[levelNameBM]" : "lv.[levelNameEN]";
                string sql = string.Format(@"SELECT c.*,s.[name] AS studentName,s.[userId] AS studentUserId,
                    ISNULL({0},'-') AS levelName,ISNULL({1},c.[certificateDescriptionEN]) AS descr
                    FROM dbo.[Certificate] c LEFT JOIN dbo.[Student] s ON s.[studentId]=c.[studentId]
                    LEFT JOIN dbo.[Level] lv ON lv.[levelId]=c.[levelId] WHERE c.[certificateId]=@id", lCol, dCol);
                using (var cmd = new SqlCommand(sql, conn)) { cmd.Parameters.AddWithValue("@id", certId);
                    using (var rd = cmd.ExecuteReader()) { if (!rd.Read()) return;
                        string certUrl = NS(rd["certificateUrl"]);

                        // Ensure URL points to PDF
                        if (!string.IsNullOrEmpty(certUrl) && certUrl.EndsWith(".html"))
                            certUrl = certUrl.Replace(".html", ".pdf");

                        // Get certificate data for regeneration
                        string studentNameVal = NS(rd["studentName"]);
                        string levelNameVal = NS(rd["levelName"]);
                        string descVal = NS(rd["descr"]);
                        string codeVal = NS(rd["certificateCode"]);
                        DateTime issuedDt = rd["issuedDate"] == DBNull.Value ? DateTime.Today : Convert.ToDateTime(rd["issuedDate"]);
                        string certTitleVal = CurrentLanguage == "BM" ? NS(rd["certificateTitleBM"]) : NS(rd["certificateTitleEN"]);
                        if (string.IsNullOrWhiteSpace(certTitleVal)) certTitleVal = NS(rd["certificateTitleEN"]);

                        // Ensure PDF file exists
                        string fileName = !string.IsNullOrEmpty(certUrl) ? System.IO.Path.GetFileName(certUrl) : "cert_preview.pdf";
                        if (!fileName.EndsWith(".pdf")) fileName = System.IO.Path.GetFileNameWithoutExtension(fileName) + ".pdf";
                        certUrl = "Images/Certificate/" + fileName;

                        GenerateCertificateFile(studentNameVal, levelNameVal, descVal, codeVal, issuedDt, fileName, certTitleVal);

                        hfCertUrl.Value = certUrl;
                        string pdfSrc = ResolveUrl("~/" + certUrl) + "?v=" + DateTime.Now.Ticks;
                        litIframe.Text = string.Format(
                            "<iframe src=\"{0}\" style=\"width:100%;height:100%;min-height:700px;border:none;display:block;\" title=\"Certificate Preview\"></iframe>",
                            pdfSrc);
                        pnlIframe.Visible = true;
                        pnlInlineCert.Visible = false;
                        lnkDownload.NavigateUrl = ResolveUrl("~/" + certUrl);
                        lnkDownload.Visible = true;

                        string st = NS(rd["status"]);
                        btnModalSend.Visible = (st != "Active");
                        hfModalCertId.Value = certId;
                        hfModalStudentUserId.Value = NS(rd["studentUserId"]);
                        hfModalStudentName.Value = NS(rd["studentName"]);
                        hfModalLevelName.Value = NS(rd["levelName"]);
                    }
                }
            }
            pnlModal.Visible = true;
        }

        protected void btnModalSend_Click(object sender, EventArgs e)
        {
            string certId = hfModalCertId.Value;
            string studentUserId = hfModalStudentUserId.Value;
            string studentName = hfModalStudentName.Value;
            string levelName = hfModalLevelName.Value;
            if (string.IsNullOrEmpty(certId)) return;

            using (var conn = new SqlConnection(ConnStr)) { conn.Open();
                using (var cmd = new SqlCommand("UPDATE dbo.[Certificate] SET [status]='Active' WHERE [certificateId]=@id", conn))
                { cmd.Parameters.AddWithValue("@id", certId); cmd.ExecuteNonQuery(); }
                string notifId = GenId(conn, "Notification", "N");
                using (var cmd = new SqlCommand(@"INSERT INTO dbo.[Notification]([notificationId],[toUserId],[titleEN],[titleBM],[messageEN],[messageBM],[isRead],[createdAt])
                    VALUES(@id,@uid,@tEN,@tBM,@mEN,@mBM,0,GETDATE())", conn))
                { cmd.Parameters.AddWithValue("@id", notifId); cmd.Parameters.AddWithValue("@uid", studentUserId);
                  cmd.Parameters.AddWithValue("@tEN", "Congratulations! Your Certificate is Ready");
                  cmd.Parameters.AddWithValue("@tBM", "Tahniah! Sijil Anda Telah Sedia");
                  cmd.Parameters.AddWithValue("@mEN", "Congratulations on completing the " + levelName + " level. Your certificate is now available for download.");
                  cmd.Parameters.AddWithValue("@mBM", "Tahniah kerana menamatkan tahap " + levelName + ". Sijil anda kini boleh dimuat turun.");
                  cmd.ExecuteNonQuery(); }
                InsertLog(conn, "Certificate Sent", "Sent " + levelName + " certificate to " + studentName + ".", "Success");
            }
            pnlModal.Visible = false;
            ShowToast(T("Certificate sent successfully.", "Sijil berjaya dihantar."), true);
            using (var conn = new SqlConnection(ConnStr)) { conn.Open(); LoadStats(conn); LoadCerts(conn); LoadEligible(conn); }
        }

        protected void btnCloseModal_Click(object sender, EventArgs e) { pnlModal.Visible = false; }

        // ── Helpers ──────────────────────────────────────────────────
        private string GenId(SqlConnection conn, string table, string prefix)
        {
            string sql = string.Format("SELECT MAX(CAST(SUBSTRING([{0}Id],{1},LEN([{0}Id])-{2}) AS INT)) FROM dbo.[{3}]",
                table.ToLower().Replace("certificate", "certificate").Replace("notification", "notification"),
                prefix.Length + 1, prefix.Length, table);
            // Simplified: just get max numeric part
            string colName = table == "Certificate" ? "certificateId" : "notificationId";
            sql = string.Format("SELECT MAX(CAST(SUBSTRING([{0}],{1},LEN([{0}])-{2}) AS INT)) FROM dbo.[{3}]",
                colName, prefix.Length + 1, prefix.Length, table);
            try { using (var cmd = new SqlCommand(sql, conn)) { var v = cmd.ExecuteScalar();
                int next = (v != null && v != DBNull.Value) ? Convert.ToInt32(v) + 1 : 1;
                return prefix + next.ToString("D3"); } }
            catch { return prefix + DateTime.Now.Ticks.ToString().Substring(10); }
        }

        private void InsertLog(SqlConnection conn, string action, string desc, string status)
        {
            try {
                string logId = GenId(conn, "Log", "LOG");
                using (var cmd = new SqlCommand(@"INSERT INTO dbo.[Log]([logId],[userId],[action],[description],[logDateTime],[status])
                    VALUES(@id,@uid,@act,@desc,GETDATE(),@st)", conn))
                { cmd.Parameters.AddWithValue("@id", logId); cmd.Parameters.AddWithValue("@uid", Session["userId"].ToString());
                  cmd.Parameters.AddWithValue("@act", action); cmd.Parameters.AddWithValue("@desc", desc);
                  cmd.Parameters.AddWithValue("@st", status); cmd.ExecuteNonQuery(); }
            } catch { }
        }

        private void ShowToast(string msg, bool success)
        {
            pnlToast.Visible = true;
            litToast.Text = string.Format("<div class=\"sb-alert {0}\" style=\"position:fixed;bottom:24px;right:24px;z-index:3000;max-width:380px;\"><span class=\"alert-icon\"><i class=\"bi {1}\"></i></span><div class=\"alert-content\">{2}</div></div>",
                success ? "sb-alert-success" : "sb-alert-error", success ? "bi-check-circle-fill" : "bi-x-circle-fill", HttpUtility.HtmlEncode(msg));
        }

        private string SS(SqlConnection c, string sql) { try { using (var cmd = new SqlCommand(sql, c)) { var v = cmd.ExecuteScalar(); return v != null && v != DBNull.Value ? Convert.ToInt32(v).ToString() : "0"; } } catch { return "0"; } }
        private static string NS(object v) { return (v == null || v == DBNull.Value) ? "" : v.ToString(); }
    }
}
