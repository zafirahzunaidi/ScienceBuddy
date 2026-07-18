using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

// Admin Notifications - Code Behind

namespace ScienceBuddy.Admin
{
    public partial class Notifications : Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

        protected string CurrentLanguage =>
            ((ScienceBuddy.SiteMaster)Master).CurrentLanguage;

        protected string T(string en, string bm)
        {
            return CurrentLanguage == "BM" ? bm : en;
        }

        // ── Page Load ────────────────────────────────────────────────
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null)
            { Response.Redirect("~/Login.aspx", false); return; }
            if (Session["role"] == null || Session["role"].ToString() != "Admin")
            { Response.Redirect("~/Login.aspx", false); return; }

            var master = (ScienceBuddy.SiteMaster)Master;
            master.LayoutMode = "Sidebar";

            if (!IsPostBack)
            {
                SetMasterUserInfo();
                LoadSentTable("", "");

                // Auto-fill from Content Requests workflow
                if (Request.QueryString["from"] == "contentrequest" && Session["notif_action"] != null)
                {
                    AutoFillFromContentRequest();
                }
            }

            // Bilingual button labels (every load)
            btnSend.Text   = T("Send Notification", "Hantar Notifikasi");
            btnSearch.Text = T("Search", "Cari");
            btnReset.Text  = T("Reset", "Tetapkan Semula");
            txtSearch.Attributes["placeholder"] = T("Search by recipient, title or type…", "Cari mengikut penerima, tajuk atau jenis…");
        }

        private void SetMasterUserInfo()
        {
            string uid = Session["userId"].ToString();
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT [username] FROM dbo.[User] WHERE [userId]=@uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", uid);
                    var val = cmd.ExecuteScalar();
                    string name = (val != null && val != DBNull.Value) ? val.ToString() : "Admin";
                    string ini = name.Length >= 2 ? name.Substring(0, 2).ToUpper() : name.ToUpper();
                    ((ScienceBuddy.SiteMaster)Master).SetUserInfo(name, "Administrator", ini);
                }
            }
        }

        // ── Auto-fill from Content Request rejection workflow ─────────
        private void AutoFillFromContentRequest()
        {
            string action       = Session["notif_action"]?.ToString() ?? "";
            string teacherUid   = Session["notif_teacherUserId"]?.ToString() ?? "";
            string teacherName  = Session["notif_teacherName"]?.ToString() ?? "";
            string contentTitle = Session["notif_contentTitle"]?.ToString() ?? "";

            if (string.IsNullOrEmpty(teacherUid) || action != "Rejected") return;

            // Set recipient to Specific Teacher
            ddlRecipient.SelectedValue = "SpecificTeacher";
            pnlIndividual.Visible = true;
            LoadSpecificDropdown("SpecificTeacher");

            // Select the teacher in the dropdown
            if (ddlUser.Items.FindByValue(teacherUid) != null)
                ddlUser.SelectedValue = teacherUid;

            // Auto-fill rejection message
            txtTitleEN.Text = "Content Request Rejected";
            txtTitleBM.Text = "Permohonan Kandungan Ditolak";
            txtMsgEN.Text   = string.Format(
                "Your learning content \"{0}\" has been rejected.\r\nReason: ",
                contentTitle);
            txtMsgBM.Text   = string.Format(
                "Permohonan kandungan \"{0}\" telah ditolak.\r\nSebab: ",
                contentTitle);
        }

        // ── Recipient dropdown changed ───────────────────────────────
        protected void ddlRecipient_Changed(object sender, EventArgs e)
        {
            string val = ddlRecipient.SelectedValue;
            bool isSpecific = val.StartsWith("Specific");
            pnlIndividual.Visible = isSpecific;

            if (isSpecific)
                LoadSpecificDropdown(val);
        }

        private void LoadSpecificDropdown(string choice)
        {
            ddlUser.Items.Clear();
            ddlUser.Items.Add(new ListItem(T("-- Select --", "-- Pilih --"), ""));

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                string sql;

                switch (choice)
                {
                    case "SpecificStudent":
                        sql = "SELECT s.[userId], s.[name] FROM dbo.[Student] s WHERE s.[userId] IS NOT NULL ORDER BY s.[name]";
                        break;
                    case "SpecificParent":
                        sql = "SELECT p.[userId], p.[name] FROM dbo.[Parent] p WHERE p.[userId] IS NOT NULL ORDER BY p.[name]";
                        break;
                    case "SpecificTeacher":
                        sql = "SELECT t.[userId], t.[name] FROM dbo.[Teacher] t WHERE t.[userId] IS NOT NULL ORDER BY t.[name]";
                        break;
                    default:
                        return;
                }

                using (var cmd = new SqlCommand(sql, conn))
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string userId = reader["userId"].ToString();
                        string name   = reader["name"] != DBNull.Value ? reader["name"].ToString() : userId;
                        ddlUser.Items.Add(new ListItem(name, userId));
                    }
                }
            }
        }

        // ── Send notification ────────────────────────────────────────
        protected void btnSend_Click(object sender, EventArgs e)
        {
            string titleEN = txtTitleEN.Text.Trim();
            string titleBM = txtTitleBM.Text.Trim();
            string msgEN   = txtMsgEN.Text.Trim();
            string msgBM   = txtMsgBM.Text.Trim();

            if (string.IsNullOrEmpty(titleEN) && string.IsNullOrEmpty(titleBM))
            {
                ShowSendError(T("Please enter at least one title.", "Sila masukkan sekurang-kurangnya satu tajuk."));
                return;
            }

            List<string> recipientIds = GetRecipientIds();
            if (recipientIds.Count == 0)
            {
                ShowSendError(T("No recipients found. Please select a valid recipient.", "Tiada penerima ditemui. Sila pilih penerima yang sah."));
                return;
            }

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    int nextNum = GetNextNotificationNum(conn);

                    foreach (string uid in recipientIds)
                    {
                        string notifId = "N" + nextNum.ToString("D3");
                        nextNum++;

                        using (var cmd = new SqlCommand(@"
                            INSERT INTO dbo.[Notification]
                                ([notificationId],[toUserId],[titleEN],[titleBM],[messageEN],[messageBM],[isRead],[createdAt])
                            VALUES (@id,@uid,@tEN,@tBM,@mEN,@mBM,0,@now)", conn))
                        {
                            cmd.Parameters.AddWithValue("@id", notifId);
                            cmd.Parameters.AddWithValue("@uid", uid);
                            cmd.Parameters.AddWithValue("@tEN", string.IsNullOrEmpty(titleEN) ? (object)DBNull.Value : titleEN);
                            cmd.Parameters.AddWithValue("@tBM", string.IsNullOrEmpty(titleBM) ? (object)DBNull.Value : titleBM);
                            cmd.Parameters.AddWithValue("@mEN", string.IsNullOrEmpty(msgEN) ? (object)DBNull.Value : msgEN);
                            cmd.Parameters.AddWithValue("@mBM", string.IsNullOrEmpty(msgBM) ? (object)DBNull.Value : msgBM);
                            cmd.Parameters.AddWithValue("@now", DateTime.Now);
                            cmd.ExecuteNonQuery();
                        }
                    }
                }

                // Clear form
                txtTitleEN.Text = ""; txtTitleBM.Text = "";
                txtMsgEN.Text = ""; txtMsgBM.Text = "";
                lblSendMsg.Visible = false;

                // If came from Content Request rejection, clear Session and redirect back
                if (Session["notif_action"] != null && Session["notif_action"].ToString() == "Rejected")
                {
                    Session.Remove("notif_action");
                    Session.Remove("notif_teacherUserId");
                    Session.Remove("notif_teacherName");
                    Session.Remove("notif_contentTitle");
                    Session.Remove("notif_contentType");
                    Session.Remove("notif_requestId");

                    // Store success message for ContentRequests page
                    Session["cr_toast"] = T(
                        "Content rejected. Notification sent to the teacher.",
                        "Kandungan ditolak. Notifikasi telah dihantar kepada guru.");

                    Response.Redirect("~/Admin/ContentRequests.aspx", false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }

                ShowToast(string.Format(
                    T("Notification sent successfully to {0} recipient(s).", "Notifikasi berjaya dihantar kepada {0} penerima."),
                    recipientIds.Count), true);
                LoadSentTable("", "");
            }
            catch (Exception ex)
            {
                ShowSendError(T("Error sending notification.", "Ralat menghantar notifikasi.") + " " + ex.Message);
            }
        }

        private List<string> GetRecipientIds()
        {
            var ids = new List<string>();
            string choice = ddlRecipient.SelectedValue;

            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                string sql = null;

                switch (choice)
                {
                    case "AllStudents":
                        sql = "SELECT [userId] FROM dbo.[Student] WHERE [userId] IS NOT NULL";
                        break;
                    case "AllParents":
                        sql = "SELECT [userId] FROM dbo.[Parent] WHERE [userId] IS NOT NULL";
                        break;
                    case "AllTeachers":
                        sql = "SELECT [userId] FROM dbo.[Teacher] WHERE [userId] IS NOT NULL";
                        break;
                    case "SpecificStudent":
                    case "SpecificParent":
                    case "SpecificTeacher":
                        string selectedUser = ddlUser.SelectedValue;
                        if (!string.IsNullOrEmpty(selectedUser))
                            ids.Add(selectedUser);
                        return ids;
                    default:
                        return ids;
                }

                if (sql != null)
                {
                    using (var cmd = new SqlCommand(sql, conn))
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                            ids.Add(reader["userId"].ToString());
                    }
                }
            }

            return ids;
        }

        private int GetNextNotificationNum(SqlConnection conn)
        {
            using (var cmd = new SqlCommand(
                "SELECT MAX(CAST(SUBSTRING([notificationId],2,LEN([notificationId])-1) AS INT)) FROM dbo.[Notification]", conn))
            {
                var val = cmd.ExecuteScalar();
                return (val != null && val != DBNull.Value) ? Convert.ToInt32(val) + 1 : 1;
            }
        }

        // ── Load sent notifications table ────────────────────────────
        private void LoadSentTable(string search, string statusFilter)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                string sql = @"
                    SELECT n.[notificationId], n.[toUserId], n.[titleEN], n.[titleBM],
                           n.[isRead], n.[createdAt],
                           u.[username], u.[role]
                    FROM dbo.[Notification] n
                    LEFT JOIN dbo.[User] u ON u.[userId] = n.[toUserId]
                    WHERE 1=1";

                if (statusFilter == "Unread") sql += " AND n.[isRead]=0";
                else if (statusFilter == "Read") sql += " AND n.[isRead]=1";

                if (!string.IsNullOrWhiteSpace(search))
                    sql += @" AND (u.[username] LIKE @search
                              OR u.[role] LIKE @search
                              OR n.[titleEN] LIKE @search
                              OR n.[titleBM] LIKE @search)";

                sql += " ORDER BY n.[createdAt] DESC";

                using (var cmd = new SqlCommand(sql, conn))
                {
                    if (!string.IsNullOrWhiteSpace(search))
                        cmd.Parameters.AddWithValue("@search", "%" + search + "%");

                    var da = new SqlDataAdapter(cmd);
                    var dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count == 0)
                    {
                        pnlSent.Visible  = false;
                        pnlEmpty.Visible = true;
                        return;
                    }

                    bool isBM = CurrentLanguage == "BM";
                    var list = new List<object>();

                    foreach (DataRow row in dt.Rows)
                    {
                        string title = isBM
                            ? (NullSafe(row["titleBM"]) != "" ? NullSafe(row["titleBM"]) : NullSafe(row["titleEN"]))
                            : NullSafe(row["titleEN"]);
                        string recipient = NullSafe(row["username"]);
                        if (string.IsNullOrEmpty(recipient)) recipient = NullSafe(row["toUserId"]);
                        string role = NullSafe(row["role"]);
                        string recipientType = TranslateRole(role);
                        bool isRead = row["isRead"] != DBNull.Value && Convert.ToBoolean(row["isRead"]);
                        DateTime createdAt = row["createdAt"] == DBNull.Value ? DateTime.Now : Convert.ToDateTime(row["createdAt"]);

                        list.Add(new
                        {
                            recipient     = recipient,
                            recipientType = recipientType,
                            title         = title,
                            dateStr       = createdAt.ToString("d MMM yyyy, HH:mm"),
                            isRead        = isRead
                        });
                    }

                    pnlSent.Visible  = true;
                    pnlEmpty.Visible = false;
                    rptSent.DataSource = list;
                    rptSent.DataBind();
                }
            }
        }

        private string TranslateRole(string role)
        {
            if (string.IsNullOrEmpty(role)) return "—";
            switch (role)
            {
                case "Student": return T("Student", "Pelajar");
                case "Parent":  return T("Parent", "Ibu Bapa");
                case "Teacher": return T("Teacher", "Guru");
                case "Admin":   return T("Admin", "Pentadbir");
                default:        return role;
            }
        }

        // ── Search / Reset ───────────────────────────────────────────
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadSentTable(txtSearch.Text.Trim(), ddlFilter.SelectedValue);
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlFilter.SelectedIndex = 0;
            LoadSentTable("", "");
        }

        // ── Helpers ──────────────────────────────────────────────────
        protected string BuildReadBadge(object isReadObj)
        {
            bool isRead = isReadObj != null && isReadObj != DBNull.Value && Convert.ToBoolean(isReadObj);
            if (isRead)
                return "<span class=\"sb-badge sb-badge-gray\">" + T("Read", "Dibaca") + "</span>";
            return "<span class=\"sb-badge sb-badge-warning\">" + T("Unread", "Belum Dibaca") + "</span>";
        }

        private void ShowSendError(string msg)
        {
            lblSendMsg.Text = msg;
            lblSendMsg.Visible = true;
        }

        private void ShowToast(string msg, bool success)
        {
            pnlToast.Visible = true;
            string cls = success ? "sb-alert-success" : "sb-alert-error";
            string icon = success ? "bi-check-circle-fill" : "bi-x-circle-fill";
            litToast.Text = string.Format(
                "<div class=\"sb-alert {0} ad-notification-toast\"><span class=\"alert-icon\"><i class=\"bi {1}\"></i></span><div class=\"alert-content\">{2}</div></div>",
                cls, icon, HttpUtility.HtmlEncode(msg));
        }

        private static string NullSafe(object val)
        {
            return (val == null || val == DBNull.Value) ? "" : val.ToString();
        }
    }
}
