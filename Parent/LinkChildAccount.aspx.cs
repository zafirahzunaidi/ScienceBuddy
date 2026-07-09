using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace ScienceBuddy.Parent
{
    public partial class LinkChildAccount : Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected string CurrentLanguage = "EN";

        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        private string _userId = "";
        private string _parentId = "";

        // ══════════════════════════════════════════════════════════════
        //  PAGE LOAD
        // ══════════════════════════════════════════════════════════════

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null ||
                Session["role"].ToString() != "Parent")
            {
                Response.Redirect("~/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";

            _userId = Session["userId"].ToString();
            LoadCurrentLanguage(); LoadUnreadBadge();
            LoadParentId();
            SetLabels();

            // Always load linked children (dynamic controls must be recreated on every request)
            LoadLinkedChildren();
            PopulateSidebarChild();

            if (!IsPostBack)
            {
                // Initial load — nothing extra needed since LoadLinkedChildren already ran
            }
        }

        // ══════════════════════════════════════════════════════════════
        //  LANGUAGE
        // ══════════════════════════════════════════════════════════════

        private void LoadCurrentLanguage()
        {
            string lang = Session["preferredLanguage"] as string;
            if (!string.IsNullOrEmpty(lang))
            {
                CurrentLanguage = lang;
                return;
            }

            try
            {
                const string sql = "SELECT preferredLanguage FROM dbo.[User] WHERE userId = @userId";
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", _userId);
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        lang = result.ToString();
                        Session["preferredLanguage"] = lang;
                        CurrentLanguage = lang;
                        return;
                    }
                }
            }
            catch (SqlException) { }

            CurrentLanguage = "EN";
        }

        // ══════════════════════════════════════════════════════════════
        //  PARENT ID
        // ══════════════════════════════════════════════════════════════

        private void LoadParentId()
        {
            try
            {
                const string sql = "SELECT parentId FROM dbo.[Parent] WHERE userId = @userId";
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", _userId);
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                        _parentId = result.ToString();
                }
            }
            catch (SqlException) { }
        }

        // ══════════════════════════════════════════════════════════════
        //  LABELS
        // ══════════════════════════════════════════════════════════════

        private void SetLabels()
        {
            litTitle.Text           = T("Link Child Account", "Paut Akaun Anak");
            litSub.Text             = T("Ask your child for their unique link code from their Student profile. Enter it below to link their account to yours.",
                                        "Minta anak anda untuk kod paut unik dari profil Pelajar mereka. Masukkan di bawah untuk memautkan akaun mereka ke akaun anda.");
            litLblCode.Text         = T("Child Link Code", "Kod Paut Anak");
            litLblRelationship.Text = T("Your Relationship", "Hubungan Anda");
            btnLink.Text            = T("Link Child", "Paut Anak");
            litLinkedTitle.Text     = T("Linked Children", "Anak Dipautkan");
            litNoLinked.Text        = T("No linked children yet.", "Tiada anak dipautkan lagi.");
        }

        private void PopulateSidebarChild()
        {
            ddlSidebarChild.Items.Clear();
            if (string.IsNullOrEmpty(_parentId)) return;
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT sp.studentId, s.name, s.nickname FROM dbo.[StudentParent] sp INNER JOIN dbo.[Student] s ON s.studentId=sp.studentId WHERE sp.parentId=@p", conn))
                {
                    cmd.Parameters.AddWithValue("@p", _parentId); conn.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            string sid = r["studentId"]?.ToString() ?? "";
                            string nm = r["nickname"]?.ToString() ?? "";
                            string n = r["name"]?.ToString() ?? "";
                            ddlSidebarChild.Items.Add(new System.Web.UI.WebControls.ListItem(!string.IsNullOrWhiteSpace(nm) ? nm : n, sid));
                        }
                    }
                }
                string sel = Session["selectedChildId"] as string;
                if (!string.IsNullOrEmpty(sel) && ddlSidebarChild.Items.FindByValue(sel) != null)
                    ddlSidebarChild.SelectedValue = sel;
            }
            catch (SqlException) { }
        }

        protected void SidebarChildChanged(object sender, EventArgs e)
        {
            Session["selectedChildId"] = ddlSidebarChild.SelectedValue;
            Response.Redirect(Request.RawUrl, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        // ══════════════════════════════════════════════════════════════
        //  LINK CHILD
        // ══════════════════════════════════════════════════════════════

        protected void BtnLink_Click(object sender, EventArgs e)
        {
            string code         = txtCode.Text.Trim().ToUpper();
            string relationship = ddlRelationship.SelectedValue;

            // Validate
            if (string.IsNullOrEmpty(code))
            {
                ShowMessage(T("Please enter the child link code.", "Sila masukkan kod paut anak."), true);
                return;
            }

            if (string.IsNullOrEmpty(_parentId))
            {
                ShowMessage(T("Parent account not found.", "Akaun ibu bapa tidak ditemui."), true);
                return;
            }

            // Find student by parentCode
            string studentId   = "";
            string studentName = "";
            string nickname    = "";

            try
            {
                const string findSql = "SELECT studentId, name, nickname FROM dbo.[Student] WHERE parentCode = @code";
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(findSql, conn))
                {
                    cmd.Parameters.AddWithValue("@code", code);
                    conn.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            studentId   = reader["studentId"]?.ToString() ?? "";
                            studentName = reader["name"]?.ToString() ?? "";
                            nickname    = reader["nickname"]?.ToString() ?? "";
                        }
                    }
                }
            }
            catch (SqlException)
            {
                ShowMessage(T("An error occurred. Please try again.", "Ralat berlaku. Sila cuba lagi."), true);
                return;
            }

            if (string.IsNullOrEmpty(studentId))
            {
                ShowMessage(T("Invalid link code. No child found with this code.",
                              "Kod paut tidak sah. Tiada anak ditemui dengan kod ini."), true);
                return;
            }

            // Check duplicate
            try
            {
                const string dupSql = "SELECT COUNT(*) FROM dbo.[StudentParent] WHERE parentId = @parentId AND studentId = @studentId";
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(dupSql, conn))
                {
                    cmd.Parameters.AddWithValue("@parentId", _parentId);
                    cmd.Parameters.AddWithValue("@studentId", studentId);
                    conn.Open();
                    int count = Convert.ToInt32(cmd.ExecuteScalar());
                    if (count > 0)
                    {
                        ShowMessage(T("This child is already linked to your account.",
                                      "Anak ini sudah dipautkan ke akaun anda."), true);
                        return;
                    }
                }
            }
            catch (SqlException)
            {
                ShowMessage(T("An error occurred. Please try again.", "Ralat berlaku. Sila cuba lagi."), true);
                return;
            }

            // Insert with generated ID
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var tran = conn.BeginTransaction())
                    {
                        // Generate next SP ID
                        const string idSql = @"
                            SELECT ISNULL(MAX(CAST(SUBSTRING(studentParentId, 3, LEN(studentParentId)-2) AS INT)), 0) + 1
                            FROM dbo.[StudentParent]
                            WHERE studentParentId LIKE 'SP%'";

                        int nextNum;
                        using (var cmd = new SqlCommand(idSql, conn, tran))
                        {
                            nextNum = Convert.ToInt32(cmd.ExecuteScalar());
                        }

                        string newId = "SP" + nextNum.ToString("D3");

                        // Insert
                        const string insertSql = @"
                            INSERT INTO dbo.[StudentParent] (studentParentId, studentId, parentId, relationship)
                            VALUES (@id, @studentId, @parentId, @relationship)";

                        using (var cmd = new SqlCommand(insertSql, conn, tran))
                        {
                            cmd.Parameters.AddWithValue("@id", newId);
                            cmd.Parameters.AddWithValue("@studentId", studentId);
                            cmd.Parameters.AddWithValue("@parentId", _parentId);
                            cmd.Parameters.AddWithValue("@relationship", relationship);
                            cmd.ExecuteNonQuery();
                        }

                        tran.Commit();
                    }
                }

                string displayName = !string.IsNullOrWhiteSpace(nickname) ? nickname : studentName;
                ShowMessage(T("Successfully linked to ", "Berjaya dipautkan ke ") + displayName + "!", false);

                txtCode.Text = "";
                LoadLinkedChildren();
            }
            catch (SqlException)
            {
                ShowMessage(T("An error occurred while linking. Please try again.",
                              "Ralat berlaku semasa memautkan. Sila cuba lagi."), true);
            }
        }

        // ══════════════════════════════════════════════════════════════
        //  LINKED CHILDREN LIST
        // ══════════════════════════════════════════════════════════════

        private void LoadLinkedChildren()
        {
            pnlLinkedList.Controls.Clear();
            pnlNoLinked.Visible = false;

            if (string.IsNullOrEmpty(_parentId))
            {
                pnlNoLinked.Visible = true;
                return;
            }

            try
            {
                const string sql = @"
                    SELECT sp.studentParentId, sp.studentId, s.name, s.nickname, sp.relationship
                    FROM dbo.[StudentParent] sp
                    INNER JOIN dbo.[Student] s ON s.studentId = sp.studentId
                    WHERE sp.parentId = @parentId
                    ORDER BY s.name";

                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@parentId", _parentId);
                    conn.Open();
                    bool hasRows = false;

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            hasRows = true;
                            string spId     = reader["studentParentId"]?.ToString() ?? "";
                            string studId   = reader["studentId"]?.ToString() ?? "";
                            string name     = reader["name"]?.ToString() ?? "-";
                            string nick     = reader["nickname"]?.ToString() ?? "";
                            string rel      = reader["relationship"]?.ToString() ?? "";
                            string display  = !string.IsNullOrWhiteSpace(nick) ? name + " (" + nick + ")" : name;

                            string initials = name.Length > 0 ? name[0].ToString().ToUpper() : "?";
                            if (name.Contains(" "))
                            {
                                var parts = name.Trim().Split(' ');
                                initials = (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
                            }

                            // Build row with Unlink button
                            string html = "<div class='lc-child-row'>"
                                + "<div class='lc-child-avatar'>" + Server.HtmlEncode(initials) + "</div>"
                                + "<div class='lc-child-info'>"
                                + "<div class='lc-child-name'>" + Server.HtmlEncode(display) + "</div>"
                                + "<div class='lc-child-rel'>" + Server.HtmlEncode(rel) + "</div>"
                                + "</div>";

                            pnlLinkedList.Controls.Add(new LiteralControl(html));

                            // Add Unlink LinkButton (shows modal instead of browser confirm)
                            var btnUnlink = new System.Web.UI.WebControls.LinkButton();
                            btnUnlink.ID = "unlnk_" + spId;
                            btnUnlink.Text = "<i class='bi bi-x-circle'></i> " + T("Unlink", "Nyahpaut");
                            btnUnlink.CommandArgument = spId + "|" + studId;
                            btnUnlink.Command += ShowUnlinkModal_Click;
                            btnUnlink.CssClass = "lc-unlink-btn";
                            btnUnlink.CausesValidation = false;

                            pnlLinkedList.Controls.Add(btnUnlink);
                            pnlLinkedList.Controls.Add(new LiteralControl("</div>"));
                        }
                    }

                    if (!hasRows)
                        pnlNoLinked.Visible = true;
                }
            }
            catch (SqlException)
            {
                pnlNoLinked.Visible = true;
            }
        }

        // ══════════════════════════════════════════════════════════════
        //  UNLINK CHILD (modal flow)
        // ══════════════════════════════════════════════════════════════

        protected void ShowUnlinkModal_Click(object sender, System.Web.UI.WebControls.CommandEventArgs e)
        {
            string arg = e.CommandArgument?.ToString() ?? "";
            hidUnlinkArg.Value = arg;

            // Set modal text
            litModalTitle.Text     = T("Unlink Child?", "Nyahpaut Anak?");
            litModalMsg.Text       = T("This will remove the child from your linked children list. The child account will not be deleted.",
                                       "Tindakan ini akan mengeluarkan anak daripada senarai anak yang dipautkan. Akaun anak tidak akan dipadam.");
            btnCancelUnlink.Text   = T("Cancel", "Batal");
            btnConfirmUnlink.Text  = T("Unlink Child", "Nyahpaut Anak");

            pnlUnlinkModal.Visible = true;
        }

        protected void BtnCancelUnlink_Click(object sender, EventArgs e)
        {
            pnlUnlinkModal.Visible = false;
            hidUnlinkArg.Value = "";
        }

        protected void BtnConfirmUnlink_Click(object sender, EventArgs e)
        {
            pnlUnlinkModal.Visible = false;

            string arg = hidUnlinkArg.Value;
            hidUnlinkArg.Value = "";

            string[] parts = arg.Split('|');
            if (parts.Length < 2) return;

            string studentParentId = parts[0];
            string studentId       = parts[1];

            if (string.IsNullOrEmpty(_parentId) || string.IsNullOrEmpty(studentParentId))
            {
                ShowMessage(T("Unable to unlink. Please try again.", "Gagal nyahpaut. Sila cuba lagi."), true);
                return;
            }

            try
            {
                const string sql = @"
                    DELETE FROM dbo.[StudentParent]
                    WHERE studentParentId = @spId AND parentId = @parentId";

                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@spId", studentParentId);
                    cmd.Parameters.AddWithValue("@parentId", _parentId);
                    conn.Open();
                    int affected = cmd.ExecuteNonQuery();

                    if (affected > 0)
                    {
                        string selectedChild = Session["selectedChildId"] as string;
                        if (!string.IsNullOrEmpty(selectedChild) && selectedChild == studentId)
                        {
                            Session["selectedChildId"] = null;
                        }

                        ShowMessage(T("Child unlinked successfully.", "Anak berjaya dinyahpaut."), false);
                    }
                    else
                    {
                        ShowMessage(T("Unable to unlink. The link was not found.",
                                      "Gagal nyahpaut. Pautan tidak ditemui."), true);
                    }
                }
            }
            catch (SqlException)
            {
                ShowMessage(T("An error occurred. Please try again.", "Ralat berlaku. Sila cuba lagi."), true);
            }

            LoadLinkedChildren();
        }

        // ══════════════════════════════════════════════════════════════
        //  MESSAGES
        // ══════════════════════════════════════════════════════════════

        private void ShowMessage(string message, bool isError)
        {
            pnlMessage.Visible = true;
            divMsg.InnerHtml = Server.HtmlEncode(message);
            divMsg.Attributes["class"] = isError ? "lc-msg error" : "lc-msg success";
        }
        private void LoadUnreadBadge()
        {
            try
            {
                using (var c = new System.Data.SqlClient.SqlConnection(ConnStr))
                using (var cmd = new System.Data.SqlClient.SqlCommand("SELECT COUNT(*) FROM dbo.Notification WHERE toUserId=@uid AND isRead=0", c))
                {
                    cmd.Parameters.AddWithValue("@uid", Session["userId"].ToString());
                    c.Open();
                    int count = (int)cmd.ExecuteScalar();
                    if (count > 0) litUnreadBadge.Text = "<span class='pt-sidebar-badge'>" + count + "</span>";
                    else litUnreadBadge.Text = "";
                }
            }
            catch { }
        }
    }
}