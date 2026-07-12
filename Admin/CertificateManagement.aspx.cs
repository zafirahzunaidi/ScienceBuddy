using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

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
                string fileName = "cert_" + studentId.ToLower() + "_" + levelId.ToLower() + ".html";
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
        /// Generates a self-contained HTML certificate file that can be printed to PDF.
        /// The file is saved to Images/Certificate/ and serves as the permanent certificate document.
        /// </summary>
        private void GenerateCertificateFile(string studentName, string levelName, string description, string code, DateTime issueDate, string fileName, string certTitle)
        {
            try
            {
                string dirPath = Server.MapPath("~/Images/Certificate/");
                if (!System.IO.Directory.Exists(dirPath))
                    System.IO.Directory.CreateDirectory(dirPath);

                string filePath = System.IO.Path.Combine(dirPath, fileName);
                string html = BuildCertificateHtml(studentName, levelName, description, code, issueDate, certTitle);
                System.IO.File.WriteAllText(filePath, html, System.Text.Encoding.UTF8);
            }
            catch { /* File generation failure should not block DB record creation */ }
        }

        private string BuildCertificateHtml(string studentName, string levelName, string description, string code, DateTime issueDate, string certTitle)
        {
            // Level-specific theming
            string borderColor, accentColor, sealBg, ribbonBg, ribbonText;
            if (levelName.ToLower().Contains("advanced"))
            { borderColor = "#B8860B"; accentColor = "#1E3A5F"; sealBg = "linear-gradient(135deg,#1E3A5F,#2C5282)"; ribbonBg = "linear-gradient(135deg,#B8860B,#D4A843)"; ribbonText = "#fff"; }
            else if (levelName.ToLower().Contains("intermediate"))
            { borderColor = "#94A3B8"; accentColor = "#475569"; sealBg = "linear-gradient(135deg,#475569,#64748B)"; ribbonBg = "linear-gradient(135deg,#94A3B8,#CBD5E1)"; ribbonText = "#1E293B"; }
            else
            { borderColor = "#2563EB"; accentColor = "#1D4ED8"; sealBg = "linear-gradient(135deg,#1D4ED8,#3B82F6)"; ribbonBg = "linear-gradient(135deg,#2563EB,#60A5FA)"; ribbonText = "#fff"; }

            string logoUrl = VirtualPathUtility.ToAbsolute("~/Images/Logo/sciencebuddy-logo.png");

            string html = @"<!DOCTYPE html><html><head><meta charset='utf-8'/>
<title>ScienceBuddy Certificate - " + HttpUtility.HtmlEncode(studentName) + @"</title>
<link href='https://fonts.googleapis.com/css2?family=Cinzel:wght@700;800;900&family=Cormorant+Garamond:ital,wght@0,400;0,600;1,400&family=Playfair+Display:wght@700;800;900&family=Poppins:wght@400;600;700&display=swap' rel='stylesheet'/>
<style>
@page{size:297mm 210mm;margin:0;}
@media print{body{-webkit-print-color-adjust:exact;print-color-adjust:exact;}}
*{margin:0;padding:0;box-sizing:border-box;}
html,body{width:100%;height:100%;overflow:hidden;background:#EDE8E0;}
body{display:flex;align-items:center;justify-content:center;padding:8px;}
.page{width:calc(100% - 16px);height:calc(100% - 16px);position:relative;background:linear-gradient(170deg,#FFFDF9 0%,#FBF8F2 40%,#F9F5ED 100%);box-shadow:0 8px 40px rgba(0,0,0,.12);}
@media print{html,body{width:297mm;height:210mm;}.page{width:285mm;height:198mm;}}
/* Borders */
.bdr-out{position:absolute;inset:5mm;border:2.5px solid " + borderColor + @";}
.bdr-in{position:absolute;inset:8mm;border:1px solid " + borderColor + @";opacity:.5;}
/* Corner ornaments */
.corner{position:absolute;width:28px;height:28px;z-index:2;}
.corner svg{width:100%;height:100%;}
.c-tl{top:5mm;left:5mm;}.c-tr{top:5mm;right:5mm;transform:scaleX(-1);}.c-bl{bottom:5mm;left:5mm;transform:scaleY(-1);}.c-br{bottom:5mm;right:5mm;transform:scale(-1);}
/* Watermark */
.wm{position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);font-family:'Cinzel',serif;font-size:72px;font-weight:900;color:rgba(0,0,0,.03);letter-spacing:12px;white-space:nowrap;pointer-events:none;}
/* Content */
.content{position:relative;z-index:1;width:100%;height:100%;display:flex;flex-direction:column;align-items:center;justify-content:center;padding:14mm 24mm 18mm;text-align:center;}
/* Header */
.logo{height:72px;margin-bottom:6px;}
.brand{font-family:'Poppins',sans-serif;font-size:20px;font-weight:700;letter-spacing:1.5px;color:#333;margin-bottom:14px;}
.brand-s{color:#2563EB;}.brand-b{color:#FF6B2C;}
/* Title */
.title{font-family:'Cinzel',serif;font-size:36px;font-weight:800;color:" + accentColor + @";letter-spacing:5px;text-transform:uppercase;margin-bottom:8px;}
.ornament{width:240px;height:12px;margin:0 auto 14px;background:url(""data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='240' height='12'%3E%3Cpath d='M0 6 Q60 0 120 6 Q180 12 240 6' stroke='%23C9A84C' stroke-width='1.5' fill='none'/%3E%3Ccircle cx='120' cy='6' r='3' fill='%23C9A84C'/%3E%3C/svg%3E"") no-repeat center;}
/* Body */
.presented{font-family:'Cormorant Garamond',serif;font-size:17px;color:#6B7280;font-style:italic;margin-bottom:16px;}
.student-name{font-family:'Playfair Display',serif;font-size:42px;font-weight:800;color:#111827;margin-bottom:6px;}
.gold-line{width:180px;height:2px;background:linear-gradient(90deg,transparent," + borderColor + @" 20%," + borderColor + @" 80%,transparent);margin:6px auto 14px;}
.for-text{font-family:'Cormorant Garamond',serif;font-size:16px;color:#6B7280;margin-bottom:8px;}
/* Ribbon */
.ribbon{display:inline-block;padding:9px 36px;border-radius:5px;font-family:'Poppins',sans-serif;font-size:14px;font-weight:700;letter-spacing:4px;text-transform:uppercase;background:" + ribbonBg + @";color:" + ribbonText + @";box-shadow:0 3px 10px rgba(0,0,0,.1);margin-bottom:16px;}
.desc{font-family:'Cormorant Garamond',serif;font-size:15px;color:#4B5563;max-width:480px;line-height:1.7;margin-bottom:0;}
/* Footer */
.footer{width:100%;display:grid;grid-template-columns:1fr 1fr 1fr 1fr;gap:14px;align-items:end;padding-top:16px;border-top:1.5px solid #E5DDD0;margin-top:auto;}
.fcol{text-align:center;}
.fval{font-family:'Poppins',sans-serif;font-size:11px;font-weight:600;color:#1F2937;margin-bottom:3px;}
.flbl{font-family:'Poppins',sans-serif;font-size:8px;color:#9CA3AF;text-transform:uppercase;letter-spacing:.8px;}
/* Seal */
.seal{width:58px;height:58px;border-radius:50%;background:" + sealBg + @";border:3px solid " + borderColor + @";display:flex;flex-direction:column;align-items:center;justify-content:center;color:#fff;margin:0 auto 4px;box-shadow:0 0 0 2.5px #FFFDF9,0 0 0 5px " + borderColor + @",0 4px 14px rgba(0,0,0,.12);}
.seal-top{font-size:4.5px;text-transform:uppercase;letter-spacing:1.2px;opacity:.8;}
.seal-mid{font-size:14px;font-weight:900;line-height:1;}
.seal-bot{font-size:4.5px;text-transform:uppercase;letter-spacing:1.2px;opacity:.8;}
/* Signature */
.sig{font-family:'Cormorant Garamond',serif;font-style:italic;font-size:13px;color:#1E293B;border-top:1px solid #94A3B8;padding-top:3px;display:inline-block;}
/* Page footer */
.page-foot{position:absolute;bottom:8px;left:0;right:0;text-align:center;font-family:'Poppins',sans-serif;font-size:6.5px;color:#CBD5E1;letter-spacing:.5px;}
</style></head><body>
<div class='page'>
<div class='bdr-out'></div><div class='bdr-in'></div>
<div class='corner c-tl'><svg viewBox='0 0 28 28'><path d='M0 0 L0 20 Q0 0 20 0 Z' fill='" + borderColor + @"' opacity='0.6'/></svg></div>
<div class='corner c-tr'><svg viewBox='0 0 28 28'><path d='M0 0 L0 20 Q0 0 20 0 Z' fill='" + borderColor + @"' opacity='0.6'/></svg></div>
<div class='corner c-bl'><svg viewBox='0 0 28 28'><path d='M0 0 L0 20 Q0 0 20 0 Z' fill='" + borderColor + @"' opacity='0.6'/></svg></div>
<div class='corner c-br'><svg viewBox='0 0 28 28'><path d='M0 0 L0 20 Q0 0 20 0 Z' fill='" + borderColor + @"' opacity='0.6'/></svg></div>
<div class='wm'>SCIENCEBUDDY</div>
<div class='content'>
<img src='" + logoUrl + @"' alt='ScienceBuddy' class='logo' onerror=""this.style.display='none'""/>
<div class='brand'><span class='brand-s'>Science</span><span class='brand-b'>Buddy</span></div>
<div class='title'>" + HttpUtility.HtmlEncode(certTitle) + @"</div>
<div class='ornament'></div>
<div class='presented'>This certificate is proudly presented to</div>
<div class='student-name'>" + HttpUtility.HtmlEncode(studentName) + @"</div>
<div class='gold-line'></div>
<div class='for-text'>For successfully completing</div>
<div class='ribbon'>" + HttpUtility.HtmlEncode(levelName.ToUpper()) + @"</div>
<div class='desc'>" + HttpUtility.HtmlEncode(description) + @"</div>
<div class='footer'>
<div class='fcol'><div class='fval'>" + HttpUtility.HtmlEncode(code) + @"</div><div class='flbl'>Certificate No.</div></div>
<div class='fcol'><div class='fval'>" + issueDate.ToString("d MMMM yyyy") + @"</div><div class='flbl'>Issue Date</div></div>
<div class='fcol'><div class='seal'><div class='seal-top'>Official</div><div class='seal-mid'>SB</div><div class='seal-bot'>Certificate</div></div><div class='flbl'>Verified</div></div>
<div class='fcol'><div class='sig'>ScienceBuddy</div><div class='flbl'>Administrator</div></div>
</div>
</div>
<div class='page-foot'>ScienceBuddy &copy; 2026 &bull; www.sciencebuddy.com &bull; Electronically Generated &amp; Verified Certificate</div>
</div></body></html>";
            return html;
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
                        
                        // Fix old .pdf URLs — we generate .html files
                        if (!string.IsNullOrEmpty(certUrl) && certUrl.EndsWith(".pdf"))
                            certUrl = certUrl.Replace(".pdf", ".html");

                        string physicalPath = string.IsNullOrEmpty(certUrl) ? "" : Server.MapPath("~/" + certUrl);
                        bool fileExists = !string.IsNullOrEmpty(physicalPath) && System.IO.File.Exists(physicalPath);

                        // Always regenerate with latest template for consistent look
                        string studentNameVal = NS(rd["studentName"]);
                        string levelNameVal = NS(rd["levelName"]);
                        string descVal = NS(rd["descr"]);
                        string codeVal = NS(rd["certificateCode"]);
                        DateTime issuedDt = rd["issuedDate"] == DBNull.Value ? DateTime.Today : Convert.ToDateTime(rd["issuedDate"]);
                        string certTitleVal = CurrentLanguage == "BM" ? NS(rd["certificateTitleBM"]) : NS(rd["certificateTitleEN"]);
                        if (string.IsNullOrWhiteSpace(certTitleVal)) certTitleVal = NS(rd["certificateTitleEN"]);
                        
                        // Ensure file exists with latest design
                        string fileName = !string.IsNullOrEmpty(certUrl) ? System.IO.Path.GetFileName(certUrl) : "cert_preview.html";
                        if (string.IsNullOrEmpty(certUrl)) certUrl = "Images/Certificate/" + fileName;
                        GenerateCertificateFile(studentNameVal, levelNameVal, descVal, codeVal, issuedDt, fileName, certTitleVal);

                        hfCertUrl.Value = certUrl;
                        string iframeSrc = ResolveUrl("~/" + certUrl);
                        litIframe.Text = string.Format(
                            "<iframe src=\"{0}?v={1}\" style=\"width:100%;height:100%;min-height:700px;border:none;display:block;\" title=\"Certificate Preview\"></iframe>",
                            iframeSrc, DateTime.Now.Ticks);
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
