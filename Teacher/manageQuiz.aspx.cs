using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Teacher
{
    public partial class manageQuiz : Page
    {
        protected global::System.Web.UI.WebControls.LinkButton btnTabUnitLevel;
        protected global::System.Web.UI.WebControls.Panel pnlCreateULBtn;
        protected global::System.Web.UI.WebControls.Panel pnlUnitLevel;
        protected global::System.Web.UI.WebControls.Panel pnlUnitLevelEmpty;
        protected global::System.Web.UI.WebControls.Repeater rptUnitLevelQs;
        protected global::System.Web.UI.WebControls.Panel pnlUnitCards;
        protected global::System.Web.UI.WebControls.Repeater rptUnitQs;
        protected global::System.Web.UI.WebControls.Panel pnlUnitEmpty;
        protected global::System.Web.UI.WebControls.Panel pnlLevelCards;
        protected global::System.Web.UI.WebControls.Repeater rptLevelQs;
        protected global::System.Web.UI.WebControls.Panel pnlLevelEmpty;
        protected global::System.Web.UI.WebControls.Literal litUnitGrouped;
        protected global::System.Web.UI.WebControls.Literal litEmptyMsg;

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

            // Handle AJAX request for question details
            if (Request.QueryString["handler"] == "ulquestions")
            { HandleULQuestionRequest(); return; }
            // Handle AJAX request for subtopics
            if (Request.QueryString["handler"] == "subtopics")
            { HandleSubtopicRequest(); return; }
            // Handle AJAX request for Discover Quiz questions
            if (Request.QueryString["handler"] == "discoverquiz")
            { HandleDiscoverQuizRequest(); return; }
            // Handle AJAX requests for Practice Quiz selection popup
            if (Request.QueryString["handler"] == "pqlevels")
            { HandlePQLevelsRequest(); return; }
            if (Request.QueryString["handler"] == "pqunits")
            { HandlePQUnitsRequest(); return; }
            if (Request.QueryString["handler"] == "pqsubtopics")
            { HandlePQSubtopicsRequest(); return; }
            // Handle resubmit request
            if (Request.QueryString["handler"] == "resubmit")
            { HandleResubmitRequest(); return; }

            var master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                if (!Authorize()) return;
                SetupControls();
                hidActiveTab.Value = "unitlevel";
                SetTabUI();
                LoadForActiveTab();
            }
        }

        private void HandleULQuestionRequest()
        {
            Response.Clear();
            Response.ContentType = "text/html";
            string quizId = (Request.QueryString["quizId"] ?? "").Trim();
            string userId = Session["userId"]?.ToString() ?? "";
            if (string.IsNullOrEmpty(quizId)) { Response.Write("<div class='mq-empty'>Invalid request.</div>"); Response.End(); return; }
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    var sb = new System.Text.StringBuilder();

                    // Quiz header info — bilingual two-column layout
                    using (var cmd = new SqlCommand(@"SELECT q.[quizTitleEN], q.[quizTitleBM], q.[quizType],
                        CASE WHEN q.[quizType]='Unit' THEN COALESCE(u.[unitNameEN],'-') ELSE COALESCE(lv.[levelNameEN],'-') END AS relatedName
                        FROM dbo.[Quiz] q LEFT JOIN dbo.[Unit] u ON u.[unitId]=q.[unitId] LEFT JOIN dbo.[Level] lv ON lv.[levelId]=q.[levelId]
                        WHERE q.[quizId]=@qid", conn))
                    {
                        cmd.Parameters.AddWithValue("@qid", quizId);
                        using (var r = cmd.ExecuteReader())
                        {
                            if (r.Read())
                            {
                                string titleEN = r["quizTitleEN"]?.ToString() ?? "";
                                string titleBM = r["quizTitleBM"]?.ToString() ?? "";
                                string related = r["relatedName"]?.ToString() ?? "-";
                                string qType = r["quizType"]?.ToString() ?? "";
                                sb.Append("<div class='vq-header'>");
                                sb.Append("<div class='vq-header-titles'>");
                                sb.AppendFormat("<div class='vq-header-col'><div class='vq-header-lang'>English</div><div class='vq-header-title'>{0}</div></div>", HttpUtility.HtmlEncode(titleEN));
                                sb.AppendFormat("<div class='vq-header-col'><div class='vq-header-lang'>Bahasa Melayu</div><div class='vq-header-title'>{0}</div></div>", HttpUtility.HtmlEncode(titleBM));
                                sb.Append("</div>");
                                sb.AppendFormat("<div class='vq-header-meta'><i class='bi bi-diagram-3'></i> {0} · {1}</div>", HttpUtility.HtmlEncode(related), HttpUtility.HtmlEncode(qType));
                                sb.Append("</div>");
                            }
                        }
                    }

                    // Questions - full data
                    const string sql = @"SELECT qn.[questionTextEN], qn.[questionTextBM], qn.[questionType], qn.[difficulty], qn.[status],
                        qn.[optionA_EN], qn.[optionA_BM], qn.[optionB_EN], qn.[optionB_BM],
                        qn.[optionC_EN], qn.[optionC_BM], qn.[optionD_EN], qn.[optionD_BM],
                        qn.[correctAnswer], qn.[correctExplanationEN], qn.[correctExplanationBM],
                        qn.[wrongExplanationEN], qn.[wrongExplanationBM], qn.[questionImageUrl]
                        FROM dbo.[Question] qn
                        WHERE qn.[quizId]=@qid AND qn.[createdByUserId]=@uid
                        ORDER BY qn.[questionId]";
                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@qid", quizId);
                        cmd.Parameters.AddWithValue("@uid", userId);
                        using (var r = cmd.ExecuteReader())
                        {
                            int num = 0;
                            while (r.Read())
                            {
                                num++;
                                string qEN = r["questionTextEN"]?.ToString() ?? "";
                                string qBM = r["questionTextBM"]?.ToString() ?? "";
                                string qtype = r["questionType"]?.ToString() ?? "MCQ";
                                string diff = r["difficulty"]?.ToString() ?? "Medium";
                                string status = r["status"]?.ToString() ?? "Pending";
                                string correctAns = r["correctAnswer"]?.ToString() ?? "";
                                string imgUrl = r["questionImageUrl"]?.ToString() ?? "";
                                string aEN = r["optionA_EN"]?.ToString() ?? "", aBM = r["optionA_BM"]?.ToString() ?? "";
                                string bEN = r["optionB_EN"]?.ToString() ?? "", bBM = r["optionB_BM"]?.ToString() ?? "";
                                string cEN = r["optionC_EN"]?.ToString() ?? "", cBM = r["optionC_BM"]?.ToString() ?? "";
                                string dEN = r["optionD_EN"]?.ToString() ?? "", dBM = r["optionD_BM"]?.ToString() ?? "";
                                string ceEN = r["correctExplanationEN"]?.ToString() ?? "", ceBM = r["correctExplanationBM"]?.ToString() ?? "";
                                string weEN = r["wrongExplanationEN"]?.ToString() ?? "", weBM = r["wrongExplanationBM"]?.ToString() ?? "";

                                string statusCss = status == "Approved" ? "vq-badge-green" : status == "Rejected" ? "vq-badge-red" : "vq-badge-amber";
                                string diffCss = diff.Equals("Easy", StringComparison.OrdinalIgnoreCase) ? "vq-badge-green" : diff.Equals("Hard", StringComparison.OrdinalIgnoreCase) ? "vq-badge-red" : "vq-badge-amber";
                                bool expanded = (num == 1);

                                // Card
                                sb.AppendFormat("<div class='vq-card{0}'>", expanded ? " vq-expanded" : "");
                                // Header: Q# + Difficulty (left) ... Status + chevron (right)
                                sb.Append("<div class='vq-card-hd' onclick='toggleVQ(this)'>");
                                sb.AppendFormat("<span class='vq-card-num'>Q{0}</span>", num);
                                sb.AppendFormat("<span class='vq-badge {0}'>{1}</span>", diffCss, HttpUtility.HtmlEncode(diff));
                                sb.AppendFormat("<span class='vq-badge {0} vq-status-badge'>{1}</span>", statusCss, HttpUtility.HtmlEncode(status));
                                sb.Append("<i class='bi bi-chevron-down vq-chevron'></i>");
                                sb.Append("</div>");

                                // Body
                                sb.Append("<div class='vq-card-body'>");
                                // Question Format (plain bold text)
                                sb.AppendFormat("<div class='vq-format-row'><span class='vq-format-label'>Question Format:</span> <span class='vq-format-val'>{0}</span></div>", HttpUtility.HtmlEncode(qtype));

                                // Bilingual columns
                                sb.Append("<div class='vq-cols'>");
                                // EN
                                sb.Append("<div class='vq-col'><div class='vq-col-hd'>English</div>");
                                sb.AppendFormat("<div class='vq-question'>{0}</div>", HttpUtility.HtmlEncode(qEN));
                                RenderOptions(sb, aEN, bEN, cEN, dEN, correctAns, qtype, false);
                                if (!string.IsNullOrEmpty(ceEN)) sb.AppendFormat("<div class='vq-expl vq-expl-correct'><div class='vq-expl-title'><i class='bi bi-check-circle-fill'></i> Correct Explanation</div><div>{0}</div></div>", HttpUtility.HtmlEncode(ceEN));
                                if (!string.IsNullOrEmpty(weEN)) sb.AppendFormat("<div class='vq-expl vq-expl-wrong'><div class='vq-expl-title'><i class='bi bi-x-circle-fill'></i> Wrong Explanation</div><div>{0}</div></div>", HttpUtility.HtmlEncode(weEN));
                                sb.Append("</div>");
                                // BM
                                sb.Append("<div class='vq-col'><div class='vq-col-hd'>Bahasa Melayu</div>");
                                sb.AppendFormat("<div class='vq-question'>{0}</div>", HttpUtility.HtmlEncode(qBM));
                                RenderOptions(sb, aBM, bBM, cBM, dBM, correctAns, qtype, true);
                                if (!string.IsNullOrEmpty(ceBM)) sb.AppendFormat("<div class='vq-expl vq-expl-correct'><div class='vq-expl-title'><i class='bi bi-check-circle-fill'></i> Penjelasan Betul</div><div>{0}</div></div>", HttpUtility.HtmlEncode(ceBM));
                                if (!string.IsNullOrEmpty(weBM)) sb.AppendFormat("<div class='vq-expl vq-expl-wrong'><div class='vq-expl-title'><i class='bi bi-x-circle-fill'></i> Penjelasan Salah</div><div>{0}</div></div>", HttpUtility.HtmlEncode(weBM));
                                sb.Append("</div>");
                                sb.Append("</div>"); // close vq-cols

                                // Image
                                if (!string.IsNullOrWhiteSpace(imgUrl))
                                {
                                    string fileName = System.IO.Path.GetFileName(imgUrl);
                                    string resolvedPath = ResolveUrl("~/Images/Question/" + fileName);
                                    sb.AppendFormat("<div class='vq-img-row'><i class='bi bi-image'></i> <a href='#' class='vq-img-link' onclick='openImgPreview(\"{0}\");return false;'>{1}</a></div>", HttpUtility.HtmlEncode(resolvedPath), HttpUtility.HtmlEncode(fileName));
                                }

                                sb.Append("</div>"); // close vq-card-body
                                sb.Append("</div>"); // close vq-card
                            }
                            if (num == 0) sb.Append("<div class='mq-empty'>" + T("No questions have been submitted by you for this quiz yet.", "Anda belum menghantar sebarang soalan untuk kuiz ini.") + "</div>");
                        }
                    }
                    Response.Write(sb.ToString());
                }
            }
            catch { Response.Write("<div class='mq-empty'>Error loading questions.</div>"); }
            Response.End();
        }

        private void HandleSubtopicRequest()
        {
            Response.Clear();
            Response.ContentType = "application/json";
            string quizId = (Request.QueryString["quizId"] ?? "").Trim();
            if (string.IsNullOrEmpty(quizId)) { Response.Write("{\"error\":\"Invalid\"}"); Response.End(); return; }
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    string quizType = "", unitId = "", levelId = "", scopeName = "";
                    using (var cmd = new SqlCommand(@"SELECT q.[quizType], q.[unitId], q.[levelId],
                        CASE WHEN q.[quizType]='Unit' THEN COALESCE(u.[unitNameEN],'-') ELSE COALESCE(lv.[levelNameEN],'-') END AS scopeName
                        FROM dbo.[Quiz] q LEFT JOIN dbo.[Unit] u ON u.[unitId]=q.[unitId] LEFT JOIN dbo.[Level] lv ON lv.[levelId]=q.[levelId]
                        WHERE q.[quizId]=@qid", conn))
                    {
                        cmd.Parameters.AddWithValue("@qid", quizId);
                        using (var r = cmd.ExecuteReader())
                        {
                            if (!r.Read()) { Response.Write("{\"error\":\"Quiz not found\"}"); Response.End(); return; }
                            quizType = r["quizType"]?.ToString() ?? "";
                            unitId = r["unitId"]?.ToString() ?? "";
                            levelId = r["levelId"]?.ToString() ?? "";
                            scopeName = r["scopeName"]?.ToString() ?? "-";
                        }
                    }

                    string subtopicSql;
                    string filterValue;
                    if (quizType == "Unit")
                    {
                        subtopicSql = "SELECT [subtopicId],[subtopicTitleEN] FROM dbo.[Subtopic] WHERE [unitId]=@v ORDER BY [orderNo]";
                        filterValue = unitId;
                    }
                    else
                    {
                        subtopicSql = "SELECT st.[subtopicId], st.[subtopicTitleEN] FROM dbo.[Subtopic] st INNER JOIN dbo.[Unit] u ON u.[unitId]=st.[unitId] WHERE u.[levelId]=@v ORDER BY u.[orderNo], st.[orderNo]";
                        filterValue = levelId;
                    }

                    var sbJson = new System.Text.StringBuilder();
                    sbJson.AppendFormat("{{\"quizType\":\"{0}\",\"scopeName\":\"{1}\",\"subtopics\":[", HttpUtility.JavaScriptStringEncode(quizType), HttpUtility.JavaScriptStringEncode(scopeName));
                    bool first = true;
                    using (var cmd = new SqlCommand(subtopicSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@v", filterValue);
                        using (var r = cmd.ExecuteReader())
                        {
                            while (r.Read())
                            {
                                if (!first) sbJson.Append(",");
                                first = false;
                                sbJson.AppendFormat("{{\"id\":\"{0}\",\"name\":\"{1}\"}}", HttpUtility.JavaScriptStringEncode(r["subtopicId"].ToString()), HttpUtility.JavaScriptStringEncode(r["subtopicTitleEN"].ToString()));
                            }
                        }
                    }
                    sbJson.Append("]}");
                    Response.Write(sbJson.ToString());
                }
            }
            catch { Response.Write("{\"error\":\"Server error\"}"); }
            Response.End();
        }

        private void RenderOptions(System.Text.StringBuilder sb, string a, string b, string c, string d, string correct, string qtype, bool isBM)
        {
            string[] vals = { a, b, c, d };

            if (qtype.Equals("Drag & Drop", StringComparison.OrdinalIgnoreCase) || qtype.Equals("DragDrop", StringComparison.OrdinalIgnoreCase) || qtype.Equals("Drag and Drop", StringComparison.OrdinalIgnoreCase))
            {
                // Available Options as neutral boxes
                sb.AppendFormat("<div class='vq-dd-section'><div class='vq-dd-label'>{0}</div><div class='vq-dd-items'>", isBM ? "Pilihan Tersedia" : "Available Options");
                for (int i = 0; i < 4; i++)
                {
                    if (!string.IsNullOrEmpty(vals[i]))
                        sb.AppendFormat("<div class='vq-dd-item'>{0}</div>", HttpUtility.HtmlEncode(vals[i]));
                }
                sb.Append("</div></div>");

                // Correct Order - split EN/BM halves from comma-separated correctAnswer
                if (!string.IsNullOrEmpty(correct))
                {
                    string[] allParts = correct.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                    for (int i = 0; i < allParts.Length; i++) allParts[i] = allParts[i].Trim();

                    // Remove empty entries
                    var cleaned = new System.Collections.Generic.List<string>();
                    foreach (string p in allParts) { if (!string.IsNullOrEmpty(p)) cleaned.Add(p); }

                    string[] orderItems;
                    int half = cleaned.Count / 2;

                    if (cleaned.Count >= 2 && cleaned.Count % 2 == 0)
                    {
                        // Even count: first half = EN, second half = BM
                        if (isBM)
                            orderItems = cleaned.GetRange(half, half).ToArray();
                        else
                            orderItems = cleaned.GetRange(0, half).ToArray();
                    }
                    else if (cleaned.Count == 1)
                    {
                        // Single value — show for both
                        orderItems = cleaned.ToArray();
                    }
                    else
                    {
                        // Odd count fallback: EN gets first ceil(n/2), BM gets the rest
                        int enCount = (cleaned.Count + 1) / 2;
                        if (isBM)
                            orderItems = cleaned.GetRange(enCount, cleaned.Count - enCount).ToArray();
                        else
                            orderItems = cleaned.GetRange(0, enCount).ToArray();
                    }

                    if (orderItems.Length > 0)
                    {
                        sb.AppendFormat("<div class='vq-dd-order'><div class='vq-dd-label'>{0}</div><ol class='vq-dd-order-list'>", isBM ? "Susunan Betul" : "Correct Order");
                        foreach (string item in orderItems)
                            sb.AppendFormat("<li>{0}</li>", HttpUtility.HtmlEncode(item));
                        sb.Append("</ol></div>");
                    }
                }
            }
            else
            {
                // MCQ / Multiselect / True-False: show A,B,C,D with correct highlighted
                sb.Append("<div class='vq-options'>");
                string[] labels = { "A", "B", "C", "D" };
                for (int i = 0; i < 4; i++)
                {
                    if (string.IsNullOrEmpty(vals[i])) continue;
                    bool isCorrect = !string.IsNullOrEmpty(correct) && correct.IndexOf(labels[i], StringComparison.OrdinalIgnoreCase) >= 0;
                    sb.AppendFormat("<div class='vq-opt{0}'><span class='vq-opt-label'>{1}</span><span class='vq-opt-text'>{2}</span>{3}</div>",
                        isCorrect ? " vq-opt-correct" : "",
                        labels[i],
                        HttpUtility.HtmlEncode(vals[i]),
                        isCorrect ? "<i class='bi bi-check-circle-fill'></i>" : "");
                }
                sb.Append("</div>");
            }
        }

        private void HandleDiscoverQuizRequest()
        {
            Response.Clear();
            Response.ContentType = "text/html";
            string quizId = (Request.QueryString["quizId"] ?? "").Trim();
            if (string.IsNullOrEmpty(quizId)) { Response.Write("<div class='mq-empty'><div class='mq-empty-title'>Invalid request.</div></div>"); Response.End(); return; }
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    var sb = new System.Text.StringBuilder();

                    // Determine if this quiz is the current teacher's Practice Quiz
                    string userId = Session["userId"]?.ToString() ?? "";
                    bool isOwnPractice = false;
                    using (var chk = new SqlCommand("SELECT COUNT(*) FROM dbo.[Quiz] WHERE [quizId]=@qid AND [quizType]='Practice' AND [createdByUserId]=@uid", conn))
                    {
                        chk.Parameters.AddWithValue("@qid", quizId);
                        chk.Parameters.AddWithValue("@uid", userId);
                        isOwnPractice = (int)chk.ExecuteScalar() > 0;
                    }

                    // If own Practice Quiz, show ALL questions; otherwise only Approved
                    string sql = @"
                        SELECT qn.[questionTextEN], qn.[questionTextBM], qn.[questionType], qn.[difficulty],
                               qn.[optionA_EN], qn.[optionA_BM], qn.[optionB_EN], qn.[optionB_BM],
                               qn.[optionC_EN], qn.[optionC_BM], qn.[optionD_EN], qn.[optionD_BM],
                               qn.[correctAnswer],
                               qn.[correctExplanationEN], qn.[correctExplanationBM],
                               qn.[wrongExplanationEN], qn.[wrongExplanationBM],
                               qn.[questionImageUrl]
                        FROM dbo.[Question] qn
                        WHERE qn.[quizId]=@qid" + (isOwnPractice ? "" : " AND qn.[status]='Approved'") + @"
                        ORDER BY qn.[questionId]";

                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@qid", quizId);
                        using (var r = cmd.ExecuteReader())
                        {
                            int num = 0;
                            while (r.Read())
                            {
                                num++;
                                string qEN  = r["questionTextEN"]?.ToString() ?? "";
                                string qBM  = r["questionTextBM"]?.ToString() ?? "";
                                string qtype = r["questionType"]?.ToString() ?? "MCQ";
                                string diff  = r["difficulty"]?.ToString() ?? "Medium";
                                string correctAns = r["correctAnswer"]?.ToString() ?? "";
                                string imgUrl = r["questionImageUrl"]?.ToString() ?? "";
                                string aEN=r["optionA_EN"]?.ToString()??"", aBM=r["optionA_BM"]?.ToString()??"";
                                string bEN=r["optionB_EN"]?.ToString()??"", bBM=r["optionB_BM"]?.ToString()??"";
                                string cEN=r["optionC_EN"]?.ToString()??"", cBM=r["optionC_BM"]?.ToString()??"";
                                string dEN=r["optionD_EN"]?.ToString()??"", dBM=r["optionD_BM"]?.ToString()??"";
                                string ceEN=r["correctExplanationEN"]?.ToString()??"", ceBM=r["correctExplanationBM"]?.ToString()??"";
                                string weEN=r["wrongExplanationEN"]?.ToString()??"",  weBM=r["wrongExplanationBM"]?.ToString()??"";

                                string diffCss = diff.Equals("Easy",StringComparison.OrdinalIgnoreCase)?"vq-badge-green":diff.Equals("Hard",StringComparison.OrdinalIgnoreCase)?"vq-badge-red":"vq-badge-amber";
                                bool expanded = (num == 1);

                                sb.AppendFormat("<div class='vq-card{0}'>", expanded?" vq-expanded":"");
                                sb.Append("<div class='vq-card-hd' onclick='toggleVQ(this)'>");
                                sb.AppendFormat("<span class='vq-card-num'>Q{0}</span>", num);
                                sb.AppendFormat("<span class='vq-badge {0}'>{1}</span>", diffCss, HttpUtility.HtmlEncode(diff));
                                sb.Append("<i class='bi bi-chevron-down vq-chevron'></i>");
                                sb.Append("</div>");

                                sb.Append("<div class='vq-card-body'>");
                                sb.AppendFormat("<div class='vq-format-row'><span class='vq-format-label'>Question Format:</span> <span class='vq-format-val'>{0}</span></div>", HttpUtility.HtmlEncode(qtype));
                                sb.Append("<div class='vq-cols'>");

                                // EN column
                                sb.Append("<div class='vq-col'><div class='vq-col-hd'>English</div>");
                                sb.AppendFormat("<div class='vq-question'>{0}</div>", HttpUtility.HtmlEncode(qEN));
                                RenderOptions(sb, aEN, bEN, cEN, dEN, correctAns, qtype, false);
                                if (!string.IsNullOrEmpty(ceEN)) sb.AppendFormat("<div class='vq-expl vq-expl-correct'><div class='vq-expl-title'><i class='bi bi-check-circle-fill'></i> Correct Explanation</div><div>{0}</div></div>", HttpUtility.HtmlEncode(ceEN));
                                if (!string.IsNullOrEmpty(weEN)) sb.AppendFormat("<div class='vq-expl vq-expl-wrong'><div class='vq-expl-title'><i class='bi bi-x-circle-fill'></i> Wrong Explanation</div><div>{0}</div></div>", HttpUtility.HtmlEncode(weEN));
                                sb.Append("</div>");

                                // BM column
                                sb.Append("<div class='vq-col'><div class='vq-col-hd'>Bahasa Melayu</div>");
                                sb.AppendFormat("<div class='vq-question'>{0}</div>", HttpUtility.HtmlEncode(qBM));
                                RenderOptions(sb, aBM, bBM, cBM, dBM, correctAns, qtype, true);
                                if (!string.IsNullOrEmpty(ceBM)) sb.AppendFormat("<div class='vq-expl vq-expl-correct'><div class='vq-expl-title'><i class='bi bi-check-circle-fill'></i> Penjelasan Betul</div><div>{0}</div></div>", HttpUtility.HtmlEncode(ceBM));
                                if (!string.IsNullOrEmpty(weBM)) sb.AppendFormat("<div class='vq-expl vq-expl-wrong'><div class='vq-expl-title'><i class='bi bi-x-circle-fill'></i> Penjelasan Salah</div><div>{0}</div></div>", HttpUtility.HtmlEncode(weBM));
                                sb.Append("</div>");

                                sb.Append("</div>"); // vq-cols

                                if (!string.IsNullOrWhiteSpace(imgUrl))
                                {
                                    string fileName = System.IO.Path.GetFileName(imgUrl);
                                    string resolvedPath = ResolveUrl("~/Images/Question/" + fileName);
                                    sb.AppendFormat("<div class='vq-img-row'><i class='bi bi-image'></i> <a href='#' class='vq-img-link' onclick='openImgPreview(\"{0}\");return false;'>{1}</a></div>", HttpUtility.HtmlEncode(resolvedPath), HttpUtility.HtmlEncode(fileName));
                                }

                                sb.Append("</div>"); // vq-card-body
                                sb.Append("</div>"); // vq-card
                            }
                            if (num == 0)
                                sb.Append("<div class='mq-empty'><div style='font-size:2.5rem;opacity:.4;margin-bottom:.75rem;'>📭</div><div class='mq-empty-title'>No questions in this quiz yet.</div></div>");
                        }
                    }
                    Response.Write(sb.ToString());
                }
            }
            catch { Response.Write("<div class='mq-empty'><div class='mq-empty-title'>Error loading questions.</div></div>"); }
            Response.End();
        }

        private void HandleResubmitRequest()
        {
            Response.Clear();
            Response.ContentType = "text/plain";
            string quizId = (Request.QueryString["quizId"] ?? "").Trim();
            string userId = Session["userId"]?.ToString() ?? "";
            if (string.IsNullOrEmpty(quizId) || string.IsNullOrEmpty(userId))
            { Response.StatusCode = 400; Response.Write("Invalid request."); Response.End(); return; }
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var txn = conn.BeginTransaction())
                    {
                        try
                        {
                            // 1. Update the Quiz status to Pending (only if owned by this teacher)
                            int quizRows;
                            using (var cmd = new SqlCommand("UPDATE dbo.[Quiz] SET [status]='Pending' WHERE [quizId]=@qid AND [createdByUserId]=@uid AND [quizType]='Practice'", conn, txn))
                            {
                                cmd.Parameters.AddWithValue("@qid", quizId);
                                cmd.Parameters.AddWithValue("@uid", userId);
                                quizRows = cmd.ExecuteNonQuery();
                            }
                            if (quizRows == 0)
                            {
                                txn.Rollback();
                                Response.StatusCode = 400;
                                Response.Write("Quiz not found or not eligible for resubmission.");
                                Response.End();
                                return;
                            }
                            // 2. Update ALL questions in this quiz to Pending
                            using (var cmd2 = new SqlCommand("UPDATE dbo.[Question] SET [status]='Pending' WHERE [quizId]=@qid", conn, txn))
                            {
                                cmd2.Parameters.AddWithValue("@qid", quizId);
                                cmd2.ExecuteNonQuery();
                            }
                            txn.Commit();
                            Response.Write("OK");
                        }
                        catch
                        {
                            txn.Rollback();
                            throw;
                        }
                    }
                }
            }
            catch { Response.StatusCode = 500; Response.Write("Error."); }
            Response.End();
        }

        private void HandlePQLevelsRequest()        {
            Response.Clear();
            Response.ContentType = "application/json";
            try
            {
                var sb = new System.Text.StringBuilder();
                sb.Append("[");
                bool first = true;
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("SELECT [levelId],[levelNameEN] FROM dbo.[Level] ORDER BY [levelId]", conn))
                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            if (!first) sb.Append(",");
                            first = false;
                            sb.AppendFormat("{{\"id\":\"{0}\",\"name\":\"{1}\"}}",
                                HttpUtility.JavaScriptStringEncode(r["levelId"].ToString()),
                                HttpUtility.JavaScriptStringEncode(r["levelNameEN"].ToString()));
                        }
                    }
                }
                sb.Append("]");
                Response.Write(sb.ToString());
            }
            catch { Response.Write("[]"); }
            Response.End();
        }

        private void HandlePQUnitsRequest()
        {
            Response.Clear();
            Response.ContentType = "application/json";
            string levelId = (Request.QueryString["levelId"] ?? "").Trim();
            if (string.IsNullOrEmpty(levelId)) { Response.Write("[]"); Response.End(); return; }
            try
            {
                var sb = new System.Text.StringBuilder();
                sb.Append("[");
                bool first = true;
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("SELECT [unitId],[unitNameEN] FROM dbo.[Unit] WHERE [levelId]=@lid ORDER BY [orderNo]", conn))
                    {
                        cmd.Parameters.AddWithValue("@lid", levelId);
                        using (var r = cmd.ExecuteReader())
                        {
                            while (r.Read())
                            {
                                if (!first) sb.Append(",");
                                first = false;
                                sb.AppendFormat("{{\"id\":\"{0}\",\"name\":\"{1}\"}}",
                                    HttpUtility.JavaScriptStringEncode(r["unitId"].ToString()),
                                    HttpUtility.JavaScriptStringEncode(r["unitNameEN"].ToString()));
                            }
                        }
                    }
                }
                sb.Append("]");
                Response.Write(sb.ToString());
            }
            catch { Response.Write("[]"); }
            Response.End();
        }

        private void HandlePQSubtopicsRequest()
        {
            Response.Clear();
            Response.ContentType = "application/json";
            string unitId = (Request.QueryString["unitId"] ?? "").Trim();
            if (string.IsNullOrEmpty(unitId)) { Response.Write("[]"); Response.End(); return; }
            try
            {
                var sb = new System.Text.StringBuilder();
                sb.Append("[");
                bool first = true;
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("SELECT [subtopicId],[subtopicTitleEN] FROM dbo.[Subtopic] WHERE [unitId]=@uid ORDER BY [orderNo]", conn))
                    {
                        cmd.Parameters.AddWithValue("@uid", unitId);
                        using (var r = cmd.ExecuteReader())
                        {
                            while (r.Read())
                            {
                                if (!first) sb.Append(",");
                                first = false;
                                sb.AppendFormat("{{\"id\":\"{0}\",\"name\":\"{1}\"}}",
                                    HttpUtility.JavaScriptStringEncode(r["subtopicId"].ToString()),
                                    HttpUtility.JavaScriptStringEncode(r["subtopicTitleEN"].ToString()));
                            }
                        }
                    }
                }
                sb.Append("]");
                Response.Write(sb.ToString());
            }
            catch { Response.Write("[]"); }
            Response.End();
        }

        private bool Authorize()
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [status] FROM dbo.[Teacher] WHERE [userId]=@u", conn))
                {
                    cmd.Parameters.AddWithValue("@u", Session["userId"].ToString());
                    var val = cmd.ExecuteScalar();
                    if (val == null || val == DBNull.Value)
                    { pnlDenied.Visible = true; return false; }
                    string teacherStatus = val.ToString();
                    if (teacherStatus.Equals("Certified", StringComparison.OrdinalIgnoreCase))
                    {
                        pnlMain.Visible = true;
                        hidTeacherLicenseStatus.Value = "Certified";
                        return true;
                    }
                    if (teacherStatus.Equals("Pending", StringComparison.OrdinalIgnoreCase))
                    {
                        pnlMain.Visible = true;
                        hidTeacherLicenseStatus.Value = "Pending";
                        return true;
                    }
                    pnlDenied.Visible = true;
                    return false;
                }
            }
        }

        private void SetupControls()
        {
            txtSearch.Attributes["placeholder"] = T("Search quizzes...", "Cari kuiz...");
            btnSearch.Text = T("Search", "Cari");
            btnConfirmDelete.Text = T("Delete", "Padam");
            btnContinue.Text = T("Continue", "Teruskan");

            ddlDifficulty.Items.Clear();
            ddlDifficulty.Items.Add(new ListItem(T("All Difficulty", "Semua Kesukaran"), ""));
            ddlDifficulty.Items.Add(new ListItem(T("Easy", "Mudah"), "Easy"));
            ddlDifficulty.Items.Add(new ListItem(T("Medium", "Sederhana"), "Medium"));
            ddlDifficulty.Items.Add(new ListItem(T("Hard", "Sukar"), "Hard"));

            ddlStatus.Items.Clear();
            ddlStatus.Items.Add(new ListItem(T("All Status", "Semua Status"), ""));
            ddlStatus.Items.Add(new ListItem(T("Pending", "Menunggu"), "Pending"));
            ddlStatus.Items.Add(new ListItem(T("Approved", "Diluluskan"), "Approved"));
            ddlStatus.Items.Add(new ListItem(T("Rejected", "Ditolak"), "Rejected"));

            ddlLanguage.Items.Clear();
            ddlLanguage.Items.Add(new ListItem(T("All Language", "Semua Bahasa"), ""));
            ddlLanguage.Items.Add(new ListItem("English", "EN"));
            ddlLanguage.Items.Add(new ListItem("Bahasa Melayu", "BM"));

            // Create modal - Quiz Type
            ddlCreateType.Items.Clear();
            ddlCreateType.Items.Add(new ListItem(T("— Select Quiz Type —", "— Pilih Jenis Kuiz —"), ""));
            ddlCreateType.Items.Add(new ListItem(T("Practice Quiz", "Kuiz Latihan"), "Practice"));
            ddlCreateType.Items.Add(new ListItem(T("Unit Quiz", "Kuiz Unit"), "Unit"));
            ddlCreateType.Items.Add(new ListItem(T("Level Quiz", "Kuiz Tahap"), "Level"));

            // Create modal - Level
            ddlCreateLevel.Items.Clear();
            ddlCreateLevel.Items.Add(new ListItem(T("— Select Level —", "— Pilih Tahap —"), ""));
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [levelId],[levelNameEN] FROM dbo.[Level] ORDER BY [levelId]", conn))
                using (var r = cmd.ExecuteReader()) while (r.Read()) ddlCreateLevel.Items.Add(new ListItem(r["levelNameEN"].ToString(), r["levelId"].ToString()));
            }
        }

        private void LoadQuizzes()
        {
            string userId = Session["userId"].ToString();
            string search = txtSearch.Text.Trim();
            string diff = ddlDifficulty.SelectedValue;
            string status = ddlStatus.SelectedValue;
            string lang = ddlLanguage.SelectedValue;

            string sql = @"
                SELECT q.[quizId],
                       ISNULL(q.[quizTitleEN], q.[quizTitleBM]) AS quizTitle,
                       q.[status], q.[language],
                       (SELECT COUNT(*) FROM dbo.[Question] WHERE [quizId] = q.[quizId]) AS questionCount,
                       ISNULL((SELECT TOP 1 [difficulty] FROM dbo.[Question] WHERE [quizId] = q.[quizId]
                               GROUP BY [difficulty] ORDER BY COUNT(*) DESC), 'Medium') AS difficulty
                FROM dbo.[Quiz] q
                WHERE q.[createdByUserId] = @userId
                  AND q.[quizType] = 'Practice'";

            if (!string.IsNullOrEmpty(search))
                sql += " AND (q.[quizTitleEN] LIKE @s OR q.[quizTitleBM] LIKE @s)";
            if (!string.IsNullOrEmpty(status))
                sql += " AND q.[status] = @status";
            if (!string.IsNullOrEmpty(lang))
                sql += " AND q.[language] = @lang";

            sql += " ORDER BY q.[createdAt] DESC";

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    if (!string.IsNullOrEmpty(search)) cmd.Parameters.AddWithValue("@s", "%" + search + "%");
                    if (!string.IsNullOrEmpty(status)) cmd.Parameters.AddWithValue("@status", status);
                    if (!string.IsNullOrEmpty(lang)) cmd.Parameters.AddWithValue("@lang", lang);

                    var dt = new DataTable();
                    new SqlDataAdapter(cmd).Fill(dt);

                    // Filter by difficulty in memory (since it's aggregated)
                    if (!string.IsNullOrEmpty(diff))
                    {
                        var rows = dt.Select("difficulty = '" + diff.Replace("'", "''") + "'");
                        var filtered = dt.Clone();
                        foreach (var r in rows) filtered.ImportRow(r);
                        dt = filtered;
                    }

                    if (dt.Rows.Count > 0)
                    {
                        pnlQuizzes.Visible = true; pnlEmpty.Visible = false;
                        pnlDiscover.Visible = false; pnlDiscoverEmpty.Visible = false;
                        rptQuizzes.DataSource = dt; rptQuizzes.DataBind();
                    }
                    else
                    {
                        pnlQuizzes.Visible = false; pnlEmpty.Visible = true;
                        pnlDiscover.Visible = false; pnlDiscoverEmpty.Visible = false;
                        // Set filter-specific empty message
                        if (status == "Approved")
                            litEmptyMsg.Text = T("No approved Practice Quizzes found.", "Tiada Kuiz Latihan yang diluluskan ditemui.");
                        else if (status == "Pending")
                            litEmptyMsg.Text = T("No pending Practice Quizzes found.", "Tiada Kuiz Latihan yang menunggu ditemui.");
                        else if (status == "Rejected")
                            litEmptyMsg.Text = T("No rejected Practice Quizzes found.", "Tiada Kuiz Latihan yang ditolak ditemui.");
                        else
                            litEmptyMsg.Text = T("No Practice Quizzes found.", "Tiada Kuiz Latihan ditemui.");
                    }
                }
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e) { LoadForActiveTab(); }
        protected void ddlFilter_Changed(object sender, EventArgs e) { LoadForActiveTab(); }

        protected void btnTabUnitLevel_Click(object sender, EventArgs e) { hidActiveTab.Value = "unitlevel"; SetTabUI(); LoadForActiveTab(); }
        protected void btnTabMine_Click(object sender, EventArgs e) { hidActiveTab.Value = "mine"; SetTabUI(); LoadForActiveTab(); }
        protected void btnTabDiscover_Click(object sender, EventArgs e) { hidActiveTab.Value = "discover"; SetTabUI(); LoadForActiveTab(); }

        private void SetTabUI()
        {
            string tab = hidActiveTab.Value;
            btnTabUnitLevel.CssClass = "mq-tab" + (tab == "unitlevel" ? " active" : "");
            btnTabMine.CssClass = "mq-tab" + (tab == "mine" ? " active" : "");
            btnTabDiscover.CssClass = "mq-tab" + (tab == "discover" ? " active" : "");
            pnlCreateBtn.Visible = (tab == "mine");
            pnlCreateULBtn.Visible = (tab == "unitlevel");
            pnlStatusChips.Visible = (tab == "mine");
            ddlLanguage.Visible = (tab != "unitlevel");
        }

        protected void btnChip_Click(object sender, EventArgs e)
        {
            var btn = sender as LinkButton;
            string status = btn?.CommandArgument ?? "";
            btnChipAll.CssClass = "mq-chip" + (status == "" ? " active" : "");
            btnChipApproved.CssClass = "mq-chip" + (status == "Approved" ? " active" : "");
            btnChipPending.CssClass = "mq-chip" + (status == "Pending" ? " active" : "");
            btnChipRejected.CssClass = "mq-chip" + (status == "Rejected" ? " active" : "");
            try { ddlStatus.SelectedValue = status; } catch { }
            LoadForActiveTab();
        }

        private void LoadForActiveTab()
        {
            SetTabUI();
            // Hide all content panels first
            pnlQuizzes.Visible = false; pnlEmpty.Visible = false;
            pnlDiscover.Visible = false; pnlDiscoverEmpty.Visible = false;
            pnlUnitLevel.Visible = false; pnlUnitLevelEmpty.Visible = false;

            if (hidActiveTab.Value == "discover") LoadDiscoverQuizzes();
            else if (hidActiveTab.Value == "unitlevel") LoadUnitLevelQuestions();
            else LoadQuizzes();
        }

        private void LoadDiscoverQuizzes()
        {
            string userId = Session["userId"].ToString();
            string search = txtSearch.Text.Trim();
            string lang = ddlLanguage.SelectedValue;

            string sql = @"
                SELECT q.[quizId],
                       ISNULL(q.[quizTitleEN], q.[quizTitleBM]) AS quizTitle,
                       q.[quizType], q.[language],
                       COALESCE(t.[name], u.[username], 'Teacher') AS teacherName,
                       (SELECT COUNT(*) FROM dbo.[Question] WHERE [quizId]=q.[quizId]) AS questionCount
                FROM dbo.[Quiz] q
                INNER JOIN dbo.[User] u ON u.[userId]=q.[createdByUserId]
                LEFT JOIN dbo.[Teacher] t ON t.[userId]=q.[createdByUserId]
                WHERE q.[createdByUserId]<>@userId AND q.[status]='Approved'";
            if (!string.IsNullOrEmpty(search))
                sql += " AND (q.[quizTitleEN] LIKE @s OR q.[quizTitleBM] LIKE @s)";
            if (!string.IsNullOrEmpty(lang))
                sql += " AND q.[language]=@lang";
            sql += " ORDER BY q.[createdAt] DESC";

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    if (!string.IsNullOrEmpty(search)) cmd.Parameters.AddWithValue("@s", "%" + search + "%");
                    if (!string.IsNullOrEmpty(lang)) cmd.Parameters.AddWithValue("@lang", lang);
                    var dt = new DataTable(); new SqlDataAdapter(cmd).Fill(dt);
                    pnlDiscover.Visible = dt.Rows.Count > 0;
                    pnlDiscoverEmpty.Visible = dt.Rows.Count == 0;
                    pnlQuizzes.Visible = false; pnlEmpty.Visible = false;
                    if (dt.Rows.Count > 0) { rptDiscover.DataSource = dt; rptDiscover.DataBind(); }
                }
            }
        }

        private void LoadUnitLevelQuestions()
        {
            string userId = Session["userId"].ToString();
            string search = txtSearch.Text.Trim();
            bool isBM = CurrentLanguage == "BM";

            // Unit Quiz: ALL Unit quizzes, LEFT JOIN questions for current teacher only
            string unitSql = @"
                SELECT q.[quizId],
                       COALESCE(u.[unitNameEN],'-') AS unitNameEN,
                       COALESCE(u.[unitNameBM], u.[unitNameEN],'-') AS unitNameBM,
                       u.[unitId], u.[orderNo],
                       COUNT(qn.[questionId]) AS yourCount,
                       SUM(CASE WHEN qn.[status]='Approved' THEN 1 ELSE 0 END) AS approvedCount,
                       SUM(CASE WHEN qn.[status]='Pending' OR (qn.[status] IS NULL AND qn.[questionId] IS NOT NULL) THEN 1 ELSE 0 END) AS pendingCount,
                       SUM(CASE WHEN qn.[status]='Rejected' THEN 1 ELSE 0 END) AS rejectedCount,
                       MAX(qn.[createdAt]) AS lastDate,
                       (SELECT COUNT(*) FROM dbo.[Question] qa WHERE qa.[quizId]=q.[quizId] AND qa.[status]='Approved') AS overallApproved
                FROM dbo.[Quiz] q
                LEFT JOIN dbo.[Unit] u ON u.[unitId]=q.[unitId]
                LEFT JOIN dbo.[Question] qn ON qn.[quizId]=q.[quizId] AND qn.[createdByUserId]=@userId
                WHERE q.[quizType]='Unit'";
            if (!string.IsNullOrEmpty(search))
                unitSql += " AND (u.[unitNameEN] LIKE @s OR u.[unitNameBM] LIKE @s OR q.[quizTitleEN] LIKE @s)";
            unitSql += " GROUP BY q.[quizId], u.[unitNameEN], u.[unitNameBM], u.[unitId], u.[orderNo] ORDER BY u.[unitId], u.[orderNo]";

            // Level Quiz: ALL Level quizzes, LEFT JOIN questions for current teacher only
            string levelSql = @"
                SELECT q.[quizId],
                       ISNULL(q.[quizTitleEN], q.[quizTitleBM]) AS quizName,
                       COALESCE(lv.[levelNameEN],'-') AS levelName,
                       COUNT(qn.[questionId]) AS yourCount,
                       SUM(CASE WHEN qn.[status]='Approved' THEN 1 ELSE 0 END) AS approvedCount,
                       SUM(CASE WHEN qn.[status]='Pending' OR (qn.[status] IS NULL AND qn.[questionId] IS NOT NULL) THEN 1 ELSE 0 END) AS pendingCount,
                       SUM(CASE WHEN qn.[status]='Rejected' THEN 1 ELSE 0 END) AS rejectedCount,
                       MAX(qn.[createdAt]) AS lastDate,
                       (SELECT COUNT(*) FROM dbo.[Question] qa WHERE qa.[quizId]=q.[quizId] AND qa.[status]='Approved') AS overallApproved
                FROM dbo.[Quiz] q
                LEFT JOIN dbo.[Level] lv ON lv.[levelId]=q.[levelId]
                LEFT JOIN dbo.[Question] qn ON qn.[quizId]=q.[quizId] AND qn.[createdByUserId]=@userId
                WHERE q.[quizType]='Level'";
            if (!string.IsNullOrEmpty(search))
                levelSql += " AND (lv.[levelNameEN] LIKE @s OR q.[quizTitleEN] LIKE @s OR q.[quizTitleBM] LIKE @s)";
            levelSql += " GROUP BY q.[quizId], q.[quizTitleEN], q.[quizTitleBM], lv.[levelNameEN] ORDER BY lv.[levelNameEN]";

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Load & render Unit rows grouped by unit number
                var sb = new System.Text.StringBuilder();
                using (var cmd = new SqlCommand(unitSql, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    if (!string.IsNullOrEmpty(search)) cmd.Parameters.AddWithValue("@s", "%" + search + "%");
                    using (var r = cmd.ExecuteReader())
                    {
                        int currentGroup = -1;
                        while (r.Read())
                        {
                            string unitId = r["unitId"]?.ToString() ?? "";
                            // Derive group number: UN101 → 1, UN201 → 2, UN301 → 3
                            int groupNum = 0;
                            if (unitId.Length >= 4) int.TryParse(unitId.Substring(2, 1), out groupNum);

                            if (groupNum != currentGroup)
                            {
                                if (currentGroup > 0) sb.Append("</div>"); // close previous group
                                currentGroup = groupNum;
                                sb.AppendFormat("<div class=\"mq-unit-group\"><div class=\"mq-unit-group-hd\"><span class=\"mq-unit-group-num\">{0}</span><span class=\"mq-unit-group-label\">{1} {0}</span></div>",
                                    groupNum, T("Unit", "Unit"));
                            }

                            string unitName = isBM ? r["unitNameBM"].ToString() : r["unitNameEN"].ToString();
                            string quizId = r["quizId"].ToString();
                            int yourCount = Convert.ToInt32(r["yourCount"]);
                            int overallApproved = Convert.ToInt32(r["overallApproved"]);
                            int approved = Convert.ToInt32(r["approvedCount"]);
                            int pending = Convert.ToInt32(r["pendingCount"]);
                            int rejected = Convert.ToInt32(r["rejectedCount"]);

                            string overallTip = T("Total approved questions available for this quiz from all teachers.", "Jumlah soalan yang diluluskan tersedia untuk kuiz ini daripada semua guru.");
                            string yourTip = T("Total questions you have submitted for this quiz, including approved, pending and rejected questions.", "Jumlah soalan yang telah anda hantar untuk kuiz ini, termasuk yang diluluskan, menunggu dan ditolak.");

                            sb.Append("<div class=\"mq-ulq-card\">");
                            sb.AppendFormat("<div class=\"mq-ulq-left\"><div class=\"mq-ulq-icon mq-ulq-icon-unit\"><i class=\"bi bi-layers-fill\"></i></div><div class=\"mq-ulq-info\"><div class=\"mq-ulq-title\">{0}</div></div></div>", HttpUtility.HtmlEncode(unitName));
                            sb.Append("<div class=\"mq-ulq-stats\">");
                            sb.AppendFormat("<div class=\"mq-ulq-col mq-ulq-col--overall\"><div class=\"mq-ulq-col-label\">{0} <span class=\"mq-info-icon\" tabindex=\"0\" data-tip=\"{2}\"><i class=\"bi bi-info-circle\"></i></span></div><div class=\"mq-ulq-col-val mq-val-overall\">{1}</div></div>", T("Overall Approved", "Diluluskan Semua"), overallApproved, HttpUtility.HtmlEncode(overallTip));
                            sb.AppendFormat("<div class=\"mq-ulq-col mq-ulq-col--submitted\"><div class=\"mq-ulq-col-label\">{0} <span class=\"mq-info-icon\" tabindex=\"0\" data-tip=\"{2}\"><i class=\"bi bi-info-circle\"></i></span></div><div class=\"mq-ulq-col-val\">{1}</div></div>", T("Your Submitted", "Hantar Anda"), yourCount, HttpUtility.HtmlEncode(yourTip));
                            sb.AppendFormat("<div class=\"mq-ulq-col mq-ulq-col--approved\"><div class=\"mq-ulq-col-label\">{0}</div><div class=\"mq-ulq-col-val mq-val-approved\">{1}</div></div>", T("Approved", "Diluluskan"), approved);
                            sb.AppendFormat("<div class=\"mq-ulq-col mq-ulq-col--pending\"><div class=\"mq-ulq-col-label\">{0}</div><div class=\"mq-ulq-col-val mq-val-pending\">{1}</div></div>", T("Pending", "Menunggu"), pending);
                            sb.AppendFormat("<div class=\"mq-ulq-col mq-ulq-col--rejected\"><div class=\"mq-ulq-col-label\">{0}</div><div class=\"mq-ulq-col-val mq-val-rejected\">{1}</div></div>", T("Rejected", "Ditolak"), rejected);
                            sb.Append("</div>");
                            sb.AppendFormat("<div class=\"mq-ulq-btn-col\"><a href=\"#\" class=\"mq-ulq-btn mq-ulq-btn-add\" onclick='openSubtopicModal(\"{0}\");return false;'><i class=\"bi bi-plus-lg\"></i> {1}</a><button type=\"button\" class=\"mq-ulq-btn\" onclick='openULModal(\"{0}\")'><i class=\"bi bi-eye\"></i> {2}</button></div>", HttpUtility.HtmlEncode(quizId), T("Add Questions", "Tambah Soalan"), T("View Questions", "Lihat Soalan"));
                            sb.Append("</div>");
                        }
                        if (currentGroup > 0) sb.Append("</div>"); // close last group
                    }
                }
                litUnitGrouped.Text = sb.ToString();

                // Load Level rows
                var levelRows = new List<object>();
                using (var cmd = new SqlCommand(levelSql, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    if (!string.IsNullOrEmpty(search)) cmd.Parameters.AddWithValue("@s", "%" + search + "%");
                    using (var r = cmd.ExecuteReader())
                        while (r.Read())
                            levelRows.Add(new {
                                quizId = r["quizId"].ToString(),
                                quizName = r["quizName"].ToString(),
                                levelName = r["levelName"].ToString(),
                                yourCount = Convert.ToInt32(r["yourCount"]),
                                overallApproved = Convert.ToInt32(r["overallApproved"]),
                                approvedCount = Convert.ToInt32(r["approvedCount"]),
                                pendingCount = Convert.ToInt32(r["pendingCount"]),
                                rejectedCount = Convert.ToInt32(r["rejectedCount"])
                            });
                }

                rptLevelQs.DataSource = levelRows; rptLevelQs.DataBind();

                pnlUnitLevel.Visible = true;
                pnlUnitLevelEmpty.Visible = false;
            }
        }

        protected void btnConfirmDelete_Click(object sender, EventArgs e)
        {
            string quizId = hidDeleteId.Value;
            string userId = Session["userId"].ToString();
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    // Delete questions first (FK constraint)
                    using (var cmd = new SqlCommand("DELETE FROM dbo.[Question] WHERE [quizId]=@qid AND [createdByUserId]=@uid", conn))
                    { cmd.Parameters.AddWithValue("@qid", quizId); cmd.Parameters.AddWithValue("@uid", userId); cmd.ExecuteNonQuery(); }
                    // Delete quiz
                    using (var cmd = new SqlCommand("DELETE FROM dbo.[Quiz] WHERE [quizId]=@qid AND [createdByUserId]=@uid", conn))
                    { cmd.Parameters.AddWithValue("@qid", quizId); cmd.Parameters.AddWithValue("@uid", userId); cmd.ExecuteNonQuery(); }
                }
                hidToast.Value = T("Quiz deleted successfully.", "Kuiz berjaya dipadam.");
            }
            catch { hidToast.Value = T("Could not delete quiz.", "Tidak dapat memadam kuiz."); }
            LoadQuizzes();
        }

        // ── Create Modal Events ─────────────────────────────────────
        protected void ddlCreateType_Changed(object sender, EventArgs e)
        {
            string t = ddlCreateType.SelectedValue;
            pnlCreateLevel.Visible = (t == "Level");
            pnlCreateUnit.Visible = (t == "Unit");
            pnlCreateSubtopic.Visible = (t == "Practice" || t == "Unit" || t == "Level");
            pnlCreateLang.Visible = (t == "Practice");

            // Load units for Unit quiz type
            if (t == "Unit") LoadCreateUnits();
            // Load subtopics based on type
            ddlCreateSubtopic.Items.Clear();
            ddlCreateSubtopic.Items.Add(new ListItem(T("— Select Subtopic —", "— Pilih Subtopik —"), ""));
            ddlCreateUnit.Items.Clear();
            ddlCreateUnit.Items.Add(new ListItem(T("— Select Unit —", "— Pilih Unit —"), ""));
            if (t == "Unit") LoadCreateUnits();

            hidShowCreateModal.Value = "1";
        }

        protected void ddlCreateLevel_Changed(object sender, EventArgs e)
        {
            // For Level quiz - load subtopics for the entire level
            ddlCreateSubtopic.Items.Clear();
            ddlCreateSubtopic.Items.Add(new ListItem(T("— Select Subtopic —", "— Pilih Subtopik —"), ""));
            string levelId = ddlCreateLevel.SelectedValue;
            if (!string.IsNullOrEmpty(levelId))
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    const string sql = @"SELECT st.[subtopicId], st.[subtopicTitleEN] FROM dbo.[Subtopic] st
                        INNER JOIN dbo.[Unit] u ON u.[unitId] = st.[unitId] WHERE u.[levelId] = @lid ORDER BY u.[orderNo], st.[orderNo]";
                    using (var cmd = new SqlCommand(sql, conn))
                    { cmd.Parameters.AddWithValue("@lid", levelId); using (var r = cmd.ExecuteReader()) while (r.Read()) ddlCreateSubtopic.Items.Add(new ListItem(r["subtopicTitleEN"].ToString(), r["subtopicId"].ToString())); }
                }
            }
            hidShowCreateModal.Value = "1";
        }

        protected void ddlCreateUnit_Changed(object sender, EventArgs e)
        {
            ddlCreateSubtopic.Items.Clear();
            ddlCreateSubtopic.Items.Add(new ListItem(T("— Select Subtopic —", "— Pilih Subtopik —"), ""));
            string unitId = ddlCreateUnit.SelectedValue;
            if (!string.IsNullOrEmpty(unitId))
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new SqlCommand("SELECT [subtopicId],[subtopicTitleEN] FROM dbo.[Subtopic] WHERE [unitId]=@u ORDER BY [orderNo]", conn))
                    { cmd.Parameters.AddWithValue("@u", unitId); using (var r = cmd.ExecuteReader()) while (r.Read()) ddlCreateSubtopic.Items.Add(new ListItem(r["subtopicTitleEN"].ToString(), r["subtopicId"].ToString())); }
                }
            }
            hidShowCreateModal.Value = "1";
        }

        private void LoadCreateUnits()
        {
            ddlCreateUnit.Items.Clear();
            ddlCreateUnit.Items.Add(new ListItem(T("— Select Unit —", "— Pilih Unit —"), ""));
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [unitId],[unitNameEN] FROM dbo.[Unit] ORDER BY [levelId],[orderNo]", conn))
                using (var r = cmd.ExecuteReader()) while (r.Read()) ddlCreateUnit.Items.Add(new ListItem(r["unitNameEN"].ToString(), r["unitId"].ToString()));
            }
        }

        protected void btnContinue_Click(object sender, EventArgs e)
        {
            string quizType = ddlCreateType.SelectedValue;
            string subtopicId = ddlCreateSubtopic.SelectedValue;

            if (string.IsNullOrEmpty(quizType) || string.IsNullOrEmpty(subtopicId))
            { hidShowCreateModal.Value = "1"; return; }

            if (quizType == "Practice")
            {
                string lang = ddlCreateLang.SelectedValue;
                if (string.IsNullOrEmpty(lang)) { hidShowCreateModal.Value = "1"; return; }
                Response.Redirect("~/Teacher/createPracticeQuiz.aspx?language=" + lang + "&subtopicId=" + subtopicId, false);
            }
            else if (quizType == "Unit")
            {
                string unitId = ddlCreateUnit.SelectedValue;
                if (string.IsNullOrEmpty(unitId)) { hidShowCreateModal.Value = "1"; return; }
                Response.Redirect("~/Teacher/createUnitLevelQuiz.aspx?mode=unit&unitId=" + unitId + "&subtopicId=" + subtopicId, false);
            }
            else if (quizType == "Level")
            {
                string levelId = ddlCreateLevel.SelectedValue;
                if (string.IsNullOrEmpty(levelId)) { hidShowCreateModal.Value = "1"; return; }
                Response.Redirect("~/Teacher/createUnitLevelQuiz.aspx?mode=level&level=" + levelId + "&subtopicId=" + subtopicId, false);
            }
            Context.ApplicationInstance.CompleteRequest();
        }

        // ── Helpers ──────────────────────────────────────────────────
        protected string GetStatusCss(string s)
        {
            if (string.IsNullOrEmpty(s)) return "mq-badge-pending";
            string l = s.ToLower();
            if (l == "approved" || l == "active") return "mq-badge-approved";
            if (l == "rejected") return "mq-badge-rejected";
            return "mq-badge-pending";
        }

        protected string GetStatusLabel(string s)
        {
            if (string.IsNullOrEmpty(s)) return T("Pending", "Menunggu");
            string l = s.ToLower();
            if (l == "approved" || l == "active") return T("Approved", "Diluluskan");
            if (l == "rejected") return T("Rejected", "Ditolak");
            return T("Pending", "Menunggu");
        }

        protected string GetDiffCss(string d)
        {
            if (string.IsNullOrEmpty(d)) return "mq-diff-medium";
            string l = d.ToLower();
            if (l == "easy") return "mq-diff-easy";
            if (l == "hard") return "mq-diff-hard";
            return "mq-diff-medium";
        }

        protected string GetTeacherInitial(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "T";
            return name.Trim()[0].ToString().ToUpper();
        }
    }
}
