using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Parent
{
    public partial class EditStudyPlan : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        protected string CurrentLanguage = "EN";
        protected string T(string en, string bm) => CurrentLanguage == "BM" ? bm : en;
        private string _parentId = "", _parentUserId = "", _selectedChildId = "", _selectedChildName = "", _studentParentId = "";
        private string _planId { get { return ViewState["PlanId"] as string ?? ""; } set { ViewState["PlanId"] = value; } }

        private static readonly string[] RewardImages = {
            "allowance.png","shopping.png","toy.png","mystery.png","trip.png",
            "favorite-food.png","movie.png","playground.png","favorite-drink.png",
            "phone.png","game.png","television.png","bedtime.png"
        };

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!EnsureAuth()) return;
            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            LoadLang(); LoadUnreadBadge(); _parentUserId = Session["userId"].ToString(); LoadParent();
            if (!IsPostBack) { SetLabels(); LoadChildren(); if (!string.IsNullOrEmpty(_selectedChildId)) LoadPage(); else ShowNoChild(); }
            else { SetLabels(); _selectedChildId = ddlSidebarChild.SelectedValue; _selectedChildName = ddlSidebarChild.SelectedItem != null ? ddlSidebarChild.SelectedItem.Text : ""; LoadSPId(); }
        }

        private bool EnsureAuth() { if (Session["userId"] == null || Session["role"] == null || Session["role"].ToString() != "Parent") { Response.Redirect("~/Login.aspx", false); Context.ApplicationInstance.CompleteRequest(); return false; } return true; }
        private void LoadLang() { string l = Session["preferredLanguage"] as string; if (!string.IsNullOrEmpty(l)) { CurrentLanguage = l; return; } try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT preferredLanguage FROM dbo.[User] WHERE userId=@u", c)) { cmd.Parameters.AddWithValue("@u", Session["userId"].ToString()); c.Open(); var r = cmd.ExecuteScalar(); if (r != null && r != DBNull.Value) { CurrentLanguage = r.ToString(); Session["preferredLanguage"] = CurrentLanguage; } } } catch { } }
        private void LoadParent() { try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT parentId FROM dbo.[Parent] WHERE userId=@u", c)) { cmd.Parameters.AddWithValue("@u", _parentUserId); c.Open(); var r = cmd.ExecuteScalar(); if (r != null) _parentId = r.ToString(); } } catch { } }
        private void LoadChildren() { ddlSidebarChild.Items.Clear(); try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT s.studentId, ISNULL(s.nickname,s.name) AS n FROM dbo.StudentParent sp INNER JOIN dbo.Student s ON sp.studentId=s.studentId WHERE sp.parentId=@p ORDER BY s.name", c)) { cmd.Parameters.AddWithValue("@p", _parentId); c.Open(); using (var r = cmd.ExecuteReader()) { while (r.Read()) ddlSidebarChild.Items.Add(new ListItem(r["n"].ToString(), r["studentId"].ToString())); } } } catch { } if (ddlSidebarChild.Items.Count > 0) { string saved = Session["selectedChildId"] as string; if (!string.IsNullOrEmpty(saved) && ddlSidebarChild.Items.FindByValue(saved) != null) ddlSidebarChild.SelectedValue = saved; else Session["selectedChildId"] = ddlSidebarChild.Items[0].Value; _selectedChildId = ddlSidebarChild.SelectedValue; _selectedChildName = ddlSidebarChild.SelectedItem.Text; LoadSPId(); } }
        private void LoadSPId() { try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT studentParentId FROM dbo.StudentParent WHERE parentId=@p AND studentId=@s", c)) { cmd.Parameters.AddWithValue("@p", _parentId); cmd.Parameters.AddWithValue("@s", _selectedChildId); c.Open(); var r = cmd.ExecuteScalar(); if (r != null) _studentParentId = r.ToString(); } } catch { } }
        protected void SidebarChildChanged(object sender, EventArgs e) { Session["selectedChildId"] = ddlSidebarChild.SelectedValue; _selectedChildId = ddlSidebarChild.SelectedValue; _selectedChildName = ddlSidebarChild.SelectedItem.Text; LoadSPId(); LoadPage(); }
        private void ShowNoChild() { pnlNoChild.Visible = true; pnlContent.Visible = false; litNoChildMsg.Text = T("No linked child found.", "Tiada anak dipautkan."); }

        private void SetLabels()
        {
            btnSaveTitle.Text = T("Save Title", "Simpan Tajuk");
            btnShowAddTask.Text = T("+ Add Task", "+ Tambah Tugasan");
            btnShowAddReward.Text = T("+ Add Reward", "+ Tambah Ganjaran");
            btnSaveTask.Text = T("Save Task", "Simpan Tugasan");
            btnCancelTask.Text = T("Cancel", "Batal");
            btnSaveReward.Text = T("Save Reward", "Simpan Ganjaran");
            btnCancelReward.Text = T("Cancel", "Batal");
            btnCreatePlan.Text = T("Create Study Plan", "Buat Pelan Belajar");
        }

        private void LoadPage()
        {
            pnlNoChild.Visible = false;
            string planId = GetActivePlanId();
            if (string.IsNullOrEmpty(planId)) { pnlContent.Visible = true; pnlCreatePlan.Visible = true; litCreatePlanMsg.Text = string.Format(T("{0} does not have a study plan yet.", "{0} belum mempunyai pelan belajar."), _selectedChildName); litEditSub.Text = _selectedChildName; return; }
            _planId = planId; pnlContent.Visible = true; pnlCreatePlan.Visible = false;
            litEditSub.Text = string.Format(T("Editing plan for {0}", "Mengedit pelan untuk {0}"), _selectedChildName);

            // Load plan title and due date
            try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT planTitle, endDate FROM dbo.StudyPlan WHERE studyPlanId=@id", c)) { cmd.Parameters.AddWithValue("@id", planId); c.Open(); using (var r = cmd.ExecuteReader()) { if (r.Read()) { txtPlanTitle.Text = r["planTitle"] != DBNull.Value ? r["planTitle"].ToString() : ""; if (r["endDate"] != DBNull.Value) txtDueDate.Text = Convert.ToDateTime(r["endDate"]).ToString("yyyy-MM-dd"); } } } } catch { }

            LoadTaskList();
            LoadRewardList();
            BuildImageGrid();
            BuildPreviewMarkers();
        }

        private string GetActivePlanId()
        {
            try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT TOP 1 studyPlanId FROM dbo.StudyPlan WHERE studentParentId=@sp AND status='Ongoing' ORDER BY createdAt DESC", c)) { cmd.Parameters.AddWithValue("@sp", _studentParentId); c.Open(); var r = cmd.ExecuteScalar(); if (r != null && r != DBNull.Value) return r.ToString(); } } catch { }
            try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT TOP 1 studyPlanId FROM dbo.StudyPlan WHERE studentParentId=@sp ORDER BY createdAt DESC", c)) { cmd.Parameters.AddWithValue("@sp", _studentParentId); c.Open(); var r = cmd.ExecuteScalar(); if (r != null && r != DBNull.Value) return r.ToString(); } } catch { }
            return null;
        }

        // ═══ CREATE PLAN ═══
        protected void BtnCreatePlan_Click(object sender, EventArgs e)
        {
            try
            {
                using (var c = new SqlConnection(ConnStr)) { c.Open(); using (var txn = c.BeginTransaction()) { try {
                    string id = GenId(c, txn, "StudyPlan", "studyPlanId", "STP");
                    using (var cmd = new SqlCommand(@"INSERT INTO dbo.StudyPlan(studyPlanId,studentParentId,createdByUserId,planTitle,startDate,endDate,status,createdAt) VALUES(@id,@sp,@uid,@t,@s,@e,'Ongoing',@now)", c, txn))
                    { cmd.Parameters.AddWithValue("@id", id); cmd.Parameters.AddWithValue("@sp", _studentParentId); cmd.Parameters.AddWithValue("@uid", _parentUserId); cmd.Parameters.AddWithValue("@t", T("My Learning Mission", "Misi Pembelajaran Saya")); cmd.Parameters.AddWithValue("@s", DateTime.Today); cmd.Parameters.AddWithValue("@e", DateTime.Today.AddDays(30)); cmd.Parameters.AddWithValue("@now", DateTime.Now); cmd.ExecuteNonQuery(); }
                    txn.Commit(); _planId = id;
                } catch { txn.Rollback(); throw; } } }
                ShowMsg(T("Study plan created!", "Pelan belajar telah dibuat!"), true);
            }
            catch { ShowMsg(T("Error creating plan.", "Ralat membuat pelan."), false); }
            LoadPage();
        }

        // ═══ SAVE PLAN DETAILS ═══
        protected void BtnSaveTitle_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtPlanTitle.Text)) { ShowMsg(T("Title cannot be empty.", "Tajuk tidak boleh kosong."), false); return; }

            // Validate due date
            DateTime dueDate;
            if (string.IsNullOrWhiteSpace(txtDueDate.Text))
            { ShowMsg(T("Due date cannot be empty.", "Tarikh akhir tidak boleh kosong."), false); return; }
            if (!DateTime.TryParse(txtDueDate.Text, out dueDate))
            { ShowMsg(T("Invalid date format.", "Format tarikh tidak sah."), false); return; }
            if (dueDate.Date < DateTime.Today)
            { ShowMsg(T("Due date cannot be earlier than today.", "Tarikh akhir tidak boleh lebih awal daripada hari ini."), false); return; }

            try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("UPDATE dbo.StudyPlan SET planTitle=@t, endDate=@d WHERE studyPlanId=@id", c)) { cmd.Parameters.AddWithValue("@t", txtPlanTitle.Text.Trim()); cmd.Parameters.AddWithValue("@d", dueDate.Date); cmd.Parameters.AddWithValue("@id", _planId); c.Open(); cmd.ExecuteNonQuery(); } ShowMsg(T("Plan details saved!", "Butiran pelan disimpan!"), true); } catch { ShowMsg(T("Error saving plan details.", "Ralat menyimpan butiran pelan."), false); }
        }

        // ═══ TASKS ═══
        private void LoadTaskList()
        {
            pnlTaskList.Controls.Clear();
            var tasks = new List<TaskRow>();
            try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT spTaskId, taskTitle, suggestedAction, orderNo, isCompleted FROM dbo.SPTask WHERE studyPlanId=@id ORDER BY orderNo", c)) { cmd.Parameters.AddWithValue("@id", _planId); c.Open(); using (var r = cmd.ExecuteReader()) { while (r.Read()) tasks.Add(new TaskRow { Id = r["spTaskId"].ToString(), Title = r["taskTitle"].ToString(), Action = r["suggestedAction"] != DBNull.Value ? r["suggestedAction"].ToString() : "", Order = Convert.ToInt32(r["orderNo"]), Done = r["isCompleted"] != DBNull.Value && Convert.ToBoolean(r["isCompleted"]) }); } } } catch { }
            if (tasks.Count == 0) { pnlNoTasks.Visible = true; return; }
            pnlNoTasks.Visible = false;
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < tasks.Count; i++)
            {
                var t = tasks[i];
                string doneClass = t.Done ? "pt-task-card-completed" : "";
                sb.AppendFormat(@"<div class=""pt-task-card pt-task-card-editable pt-draggable {0}"" data-id=""{1}"">
                    <div class=""pt-task-card-drag""><i class=""bi bi-grip-vertical""></i></div>
                    <div class=""pt-task-card-num"">{2}</div>
                    <div class=""pt-task-card-body""><div class=""pt-task-card-title"">{3}</div><div class=""pt-task-card-action"">{4}</div></div>
                    <div class=""pt-task-card-actions"">
                        <button type=""button"" class=""pt-btn-icon"" title=""Move Up"" onclick=""document.getElementById('{5}').value='{6}';document.getElementById('{7}').value='up';document.getElementById('{8}').click();return false;"" {9}><i class=""bi bi-arrow-up""></i></button>
                        <button type=""button"" class=""pt-btn-icon"" title=""Move Down"" onclick=""document.getElementById('{5}').value='{6}';document.getElementById('{7}').value='down';document.getElementById('{8}').click();return false;"" {10}><i class=""bi bi-arrow-down""></i></button>
                        <button type=""button"" class=""pt-btn-icon"" title=""Edit"" onclick=""document.getElementById('{11}').value='{6}';document.getElementById('{12}').click();return false;""><i class=""bi bi-pencil""></i></button>
                        <button type=""button"" class=""pt-btn-icon pt-btn-icon-danger"" title=""Delete"" onclick=""showDeleteModal('task','{6}','{13}','{14}');return false;""><i class=""bi bi-trash""></i></button>
                    </div>
                </div>", doneClass, t.Id, t.Order, Server.HtmlEncode(t.Title), Server.HtmlEncode(t.Action),
                    hidMoveTaskId.ClientID, t.Id, hidMoveDir.ClientID, btnMoveTask.ClientID,
                    i == 0 ? "disabled" : "", i == tasks.Count - 1 ? "disabled" : "",
                    hidEditTaskIdTrigger.ClientID, btnEditTaskTrigger.ClientID,
                    T("Delete Task?", "Padam Tugasan?"),
                    Server.HtmlEncode(string.Format(T("Are you sure you want to delete \"{0}\"?", "Adakah anda pasti mahu memadam \"{0}\"?"), t.Title)).Replace("'", "\\'"));
            }
            pnlTaskList.Controls.Add(new LiteralControl(sb.ToString()));
        }

        protected void BtnShowAddTask_Click(object sender, EventArgs e) { litTaskFormTitle.Text = T("Add Task", "Tambah Tugasan"); hidEditTaskId.Value = ""; txtTaskTitle.Text = ""; ddlSuggestedAction.SelectedIndex = 0; pnlTaskForm.Visible = true; LoadTaskList(); LoadRewardList(); BuildPreviewMarkers(); }
        protected void BtnCancelTask_Click(object sender, EventArgs e) { pnlTaskForm.Visible = false; LoadTaskList(); LoadRewardList(); BuildPreviewMarkers(); }

        protected void BtnEditTaskTrigger_Click(object sender, EventArgs e)
        {
            string taskId = hidEditTaskIdTrigger.Value;
            try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT taskTitle, suggestedAction FROM dbo.SPTask WHERE spTaskId=@id AND studyPlanId=@pid", c)) { cmd.Parameters.AddWithValue("@id", taskId); cmd.Parameters.AddWithValue("@pid", _planId); c.Open(); using (var r = cmd.ExecuteReader()) { if (r.Read()) { txtTaskTitle.Text = r["taskTitle"].ToString(); var li = ddlSuggestedAction.Items.FindByValue(r["suggestedAction"] != DBNull.Value ? r["suggestedAction"].ToString() : ""); if (li != null) li.Selected = true; } } } } catch { }
            hidEditTaskId.Value = taskId; litTaskFormTitle.Text = T("Edit Task", "Edit Tugasan"); pnlTaskForm.Visible = true; LoadTaskList(); LoadRewardList(); BuildPreviewMarkers();
        }

        protected void BtnSaveTask_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtTaskTitle.Text)) { ShowMsg(T("Task title cannot be empty.", "Tajuk tugasan tidak boleh kosong."), false); return; }
            string editId = hidEditTaskId.Value;
            try
            {
                using (var c = new SqlConnection(ConnStr)) { c.Open(); using (var txn = c.BeginTransaction()) { try {
                    if (string.IsNullOrEmpty(editId))
                    {
                        int maxOrder = 0; using (var cmd = new SqlCommand("SELECT ISNULL(MAX(orderNo),0) FROM dbo.SPTask WHERE studyPlanId=@id", c, txn)) { cmd.Parameters.AddWithValue("@id", _planId); maxOrder = (int)cmd.ExecuteScalar(); }
                        string newId = GenId(c, txn, "SPTask", "spTaskId", "SPT");
                        using (var cmd = new SqlCommand("INSERT INTO dbo.SPTask(spTaskId,studyPlanId,taskTitle,suggestedAction,orderNo,isCompleted,completedAt) VALUES(@id,@pid,@t,@a,@o,0,NULL)", c, txn))
                        { cmd.Parameters.AddWithValue("@id", newId); cmd.Parameters.AddWithValue("@pid", _planId); cmd.Parameters.AddWithValue("@t", txtTaskTitle.Text.Trim()); cmd.Parameters.AddWithValue("@a", ddlSuggestedAction.SelectedValue); cmd.Parameters.AddWithValue("@o", maxOrder + 1); cmd.ExecuteNonQuery(); }
                    }
                    else
                    {
                        using (var cmd = new SqlCommand("UPDATE dbo.SPTask SET taskTitle=@t, suggestedAction=@a WHERE spTaskId=@id AND studyPlanId=@pid", c, txn))
                        { cmd.Parameters.AddWithValue("@t", txtTaskTitle.Text.Trim()); cmd.Parameters.AddWithValue("@a", ddlSuggestedAction.SelectedValue); cmd.Parameters.AddWithValue("@id", editId); cmd.Parameters.AddWithValue("@pid", _planId); cmd.ExecuteNonQuery(); }
                    }
                    txn.Commit();
                } catch { txn.Rollback(); throw; } } }
                pnlTaskForm.Visible = false; ShowMsg(T("Task saved!", "Tugasan disimpan!"), true);
            }
            catch { ShowMsg(T("Error saving task.", "Ralat menyimpan tugasan."), false); }
            LoadTaskList(); LoadRewardList(); BuildPreviewMarkers();
        }

        protected void BtnDeleteTask_Click(object sender, EventArgs e)
        {
            string taskId = hidDeleteTaskId.Value;
            try { using (var c = new SqlConnection(ConnStr)) { c.Open(); using (var txn = c.BeginTransaction()) { try {
                using (var cmd = new SqlCommand("DELETE FROM dbo.SPTask WHERE spTaskId=@id AND studyPlanId=@pid", c, txn)) { cmd.Parameters.AddWithValue("@id", taskId); cmd.Parameters.AddWithValue("@pid", _planId); cmd.ExecuteNonQuery(); }
                // Reorder
                int order = 1; using (var cmd = new SqlCommand("SELECT spTaskId FROM dbo.SPTask WHERE studyPlanId=@pid ORDER BY orderNo", c, txn)) { cmd.Parameters.AddWithValue("@pid", _planId); using (var r = cmd.ExecuteReader()) { var ids = new List<string>(); while (r.Read()) ids.Add(r["spTaskId"].ToString()); r.Close(); foreach (var id in ids) { using (var u = new SqlCommand("UPDATE dbo.SPTask SET orderNo=@o WHERE spTaskId=@id", c, txn)) { u.Parameters.AddWithValue("@o", order++); u.Parameters.AddWithValue("@id", id); u.ExecuteNonQuery(); } } } }
                txn.Commit();
            } catch { txn.Rollback(); throw; } } } ShowMsg(T("Task deleted.", "Tugasan dipadam."), true); } catch { ShowMsg(T("Error deleting task.", "Ralat memadam tugasan."), false); }
            LoadTaskList(); LoadRewardList(); BuildPreviewMarkers();
        }

        protected void BtnMoveTask_Click(object sender, EventArgs e)
        {
            string taskId = hidMoveTaskId.Value; string dir = hidMoveDir.Value;
            try { using (var c = new SqlConnection(ConnStr)) { c.Open();
                int curOrder = 0; using (var cmd = new SqlCommand("SELECT orderNo FROM dbo.SPTask WHERE spTaskId=@id", c)) { cmd.Parameters.AddWithValue("@id", taskId); curOrder = (int)cmd.ExecuteScalar(); }
                int swapOrder = dir == "up" ? curOrder - 1 : curOrder + 1;
                using (var cmd = new SqlCommand("UPDATE dbo.SPTask SET orderNo=@new WHERE spTaskId=@id", c)) { cmd.Parameters.AddWithValue("@new", swapOrder); cmd.Parameters.AddWithValue("@id", taskId); cmd.ExecuteNonQuery(); }
                using (var cmd = new SqlCommand("UPDATE dbo.SPTask SET orderNo=@new WHERE studyPlanId=@pid AND orderNo=@swap AND spTaskId<>@id", c)) { cmd.Parameters.AddWithValue("@new", curOrder); cmd.Parameters.AddWithValue("@pid", _planId); cmd.Parameters.AddWithValue("@swap", swapOrder); cmd.Parameters.AddWithValue("@id", taskId); cmd.ExecuteNonQuery(); }
            } } catch { }
            LoadTaskList(); LoadRewardList(); BuildPreviewMarkers();
        }

        protected void BtnSaveOrder_Click(object sender, EventArgs e)
        {
            string orderStr = hidNewOrder.Value;
            if (string.IsNullOrEmpty(orderStr)) return;
            var ids = orderStr.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
            try { using (var c = new SqlConnection(ConnStr)) { c.Open(); using (var txn = c.BeginTransaction()) { try {
                for (int i = 0; i < ids.Length; i++)
                {
                    using (var cmd = new SqlCommand("UPDATE dbo.SPTask SET orderNo=@o WHERE spTaskId=@id AND studyPlanId=@pid", c, txn))
                    { cmd.Parameters.AddWithValue("@o", i + 1); cmd.Parameters.AddWithValue("@id", ids[i]); cmd.Parameters.AddWithValue("@pid", _planId); cmd.ExecuteNonQuery(); }
                }
                txn.Commit();
            } catch { txn.Rollback(); } } } } catch { }
            LoadTaskList(); LoadRewardList(); BuildPreviewMarkers();
        }

        private class TaskRow { public string Id; public string Title; public string Action; public int Order; public bool Done; }

        // ═══ REWARDS ═══
        private void LoadRewardList()
        {
            pnlRewardList.Controls.Clear();
            int count = 0;
            try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT rewardId, rewardName, requiredProgress FROM dbo.SPReward WHERE studyPlanId=@id ORDER BY requiredProgress", c)) { cmd.Parameters.AddWithValue("@id", _planId); c.Open(); using (var r = cmd.ExecuteReader()) { StringBuilder sb = new StringBuilder();
                while (r.Read()) { count++; string raw = r["rewardName"] != DBNull.Value ? r["rewardName"].ToString() : ""; string name, img; ParseRN(raw, out name, out img); int pct = r["requiredProgress"] != DBNull.Value ? Convert.ToInt32(r["requiredProgress"]) : 0; string imgUrl = !string.IsNullOrEmpty(img) ? ResolveUrl("~/Images/Rewards/" + img) : "";
                    sb.AppendFormat(@"<div class=""pt-reward-list-item""><div class=""pt-reward-list-img"">{0}</div><div class=""pt-reward-list-info""><div class=""pt-reward-list-name"">{1}</div><div class=""pt-reward-list-pct"">{2}%</div></div>
                        <button type=""button"" class=""pt-btn-icon"" onclick=""document.getElementById('{3}').value='{4}';document.getElementById('{5}').click();return false;""><i class=""bi bi-pencil""></i></button>
                        <button type=""button"" class=""pt-btn-icon pt-btn-icon-danger"" onclick=""showDeleteModal('reward','{4}','{6}','{7}');return false;""><i class=""bi bi-trash""></i></button>
                    </div>", !string.IsNullOrEmpty(imgUrl) ? "<img src='" + imgUrl + "' alt='" + Server.HtmlEncode(name) + "'/>" : "<i class='bi bi-gift-fill'></i>", Server.HtmlEncode(name), pct,
                        hidEditRewardIdTrigger.ClientID, r["rewardId"].ToString(), btnEditRewardTrigger.ClientID,
                        T("Delete Reward?","Padam Ganjaran?"),
                        Server.HtmlEncode(string.Format(T("Are you sure you want to delete \"{0}\"?", "Adakah anda pasti mahu memadam \"{0}\"?"), name)).Replace("'", "\\'"));
                } pnlRewardList.Controls.Add(new LiteralControl(sb.ToString())); } } } catch { }
            litRewardCount.Text = count.ToString();
            if (count == 0) pnlNoRewards.Visible = true; else pnlNoRewards.Visible = false;
            btnShowAddReward.Visible = count < 5;
        }

        private void BuildImageGrid()
        {
            pnlImageGrid.Controls.Clear();
            StringBuilder sb = new StringBuilder();
            string selected = hidSelectedImage.Value;
            foreach (string img in RewardImages)
            {
                string url = ResolveUrl("~/Images/Rewards/" + img);
                string selClass = img == selected ? " pt-reward-option-selected" : "";
                sb.AppendFormat(@"<div class=""pt-reward-option{0}"" onclick=""document.getElementById('{1}').value='{2}';document.getElementById('{3}').click();return false;""><img src=""{4}"" alt=""{5}"" /></div>",
                    selClass, hidImageSelect.ClientID, img, btnImageSelect.ClientID, url, img.Replace(".png",""));
            }
            pnlImageGrid.Controls.Add(new LiteralControl(sb.ToString()));
        }

        protected void BtnImageSelect_Click(object sender, EventArgs e) { hidSelectedImage.Value = hidImageSelect.Value; LoadTaskList(); LoadRewardList(); BuildImageGrid(); BuildPreviewMarkers(); }

        private void BuildPreviewMarkers()
        {
            pnlPreviewMarkers.Controls.Clear();
            try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT rewardName, requiredProgress FROM dbo.SPReward WHERE studyPlanId=@id ORDER BY requiredProgress", c)) { cmd.Parameters.AddWithValue("@id", _planId); c.Open(); StringBuilder sb = new StringBuilder(); using (var r = cmd.ExecuteReader()) { while (r.Read()) { string raw = r["rewardName"] != DBNull.Value ? r["rewardName"].ToString() : ""; string name, img; ParseRN(raw, out name, out img); int pct = r["requiredProgress"] != DBNull.Value ? Convert.ToInt32(r["requiredProgress"]) : 0; string imgUrl = !string.IsNullOrEmpty(img) ? ResolveUrl("~/Images/Rewards/" + img) : ""; int left = Math.Max(2, Math.Min(98, pct));
                sb.AppendFormat(@"<div class=""pt-reward-marker pt-reward-marker-unlocked"" style=""left:{0}%;"" title=""{1} ({2}%)"">{3}</div>", left, Server.HtmlEncode(name), pct, !string.IsNullOrEmpty(imgUrl) ? "<img src='" + imgUrl + "'/>" : "<i class='bi bi-gift-fill'></i>"); } }
                pnlPreviewMarkers.Controls.Add(new LiteralControl(sb.ToString())); } } catch { }
        }

        protected void BtnShowAddReward_Click(object sender, EventArgs e) { litRewardFormTitle.Text = T("Add Reward", "Tambah Ganjaran"); hidEditRewardId.Value = ""; txtRewardName.Text = ""; txtUnlockPct.Text = ""; hidSelectedImage.Value = ""; pnlRewardForm.Visible = true; LoadTaskList(); LoadRewardList(); BuildImageGrid(); BuildPreviewMarkers(); }
        protected void BtnCancelReward_Click(object sender, EventArgs e) { pnlRewardForm.Visible = false; LoadTaskList(); LoadRewardList(); BuildImageGrid(); BuildPreviewMarkers(); }

        protected void BtnEditRewardTrigger_Click(object sender, EventArgs e)
        {
            string rid = hidEditRewardIdTrigger.Value;
            try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT rewardName, requiredProgress FROM dbo.SPReward WHERE rewardId=@id AND studyPlanId=@pid", c)) { cmd.Parameters.AddWithValue("@id", rid); cmd.Parameters.AddWithValue("@pid", _planId); c.Open(); using (var r = cmd.ExecuteReader()) { if (r.Read()) { string raw = r["rewardName"] != DBNull.Value ? r["rewardName"].ToString() : ""; string name, img; ParseRN(raw, out name, out img); txtRewardName.Text = name; hidSelectedImage.Value = img; txtUnlockPct.Text = r["requiredProgress"] != DBNull.Value ? r["requiredProgress"].ToString() : ""; } } } } catch { }
            hidEditRewardId.Value = rid; litRewardFormTitle.Text = T("Edit Reward", "Edit Ganjaran"); pnlRewardForm.Visible = true; LoadTaskList(); LoadRewardList(); BuildImageGrid(); BuildPreviewMarkers();
        }

        protected void BtnSaveReward_Click(object sender, EventArgs e)
        {
            string img = hidSelectedImage.Value; string name = txtRewardName.Text.Trim(); int pct = 0;
            if (string.IsNullOrEmpty(img)) { ShowMsg(T("Please select a reward image.", "Sila pilih imej ganjaran."), false); return; }
            if (string.IsNullOrEmpty(name)) { ShowMsg(T("Reward name cannot be empty.", "Nama ganjaran tidak boleh kosong."), false); return; }
            if (!int.TryParse(txtUnlockPct.Text, out pct) || pct < 1 || pct > 100) { ShowMsg(T("Unlock percentage must be between 1 and 100.", "Peratus buka mesti antara 1 dan 100."), false); return; }

            string editId = hidEditRewardId.Value;
            string encodedName = name + "|||" + img;

            try { using (var c = new SqlConnection(ConnStr)) { c.Open();
                // Check duplicate pct
                using (var chk = new SqlCommand("SELECT COUNT(*) FROM dbo.SPReward WHERE studyPlanId=@pid AND requiredProgress=@p AND rewardId<>@rid", c))
                { chk.Parameters.AddWithValue("@pid", _planId); chk.Parameters.AddWithValue("@p", pct); chk.Parameters.AddWithValue("@rid", string.IsNullOrEmpty(editId) ? "NONE" : editId); if ((int)chk.ExecuteScalar() > 0) { ShowMsg(T("A reward already exists at this unlock percentage.", "Ganjaran sudah wujud pada peratus buka ini."), false); return; } }

                using (var txn = c.BeginTransaction()) { try {
                    if (string.IsNullOrEmpty(editId))
                    {
                        // Check max 5
                        int cnt = 0; using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.SPReward WHERE studyPlanId=@pid", c, txn)) { cmd.Parameters.AddWithValue("@pid", _planId); cnt = (int)cmd.ExecuteScalar(); }
                        if (cnt >= 5) { txn.Rollback(); ShowMsg(T("Maximum 5 rewards allowed.", "Maksimum 5 ganjaran dibenarkan."), false); return; }
                        string newId = GenId(c, txn, "SPReward", "rewardId", "SPR");
                        using (var cmd = new SqlCommand("INSERT INTO dbo.SPReward(rewardId,studyPlanId,rewardName,requiredProgress,isUnlocked,unlockedAt) VALUES(@id,@pid,@n,@p,0,NULL)", c, txn))
                        { cmd.Parameters.AddWithValue("@id", newId); cmd.Parameters.AddWithValue("@pid", _planId); cmd.Parameters.AddWithValue("@n", encodedName); cmd.Parameters.AddWithValue("@p", pct); cmd.ExecuteNonQuery(); }
                    }
                    else
                    {
                        using (var cmd = new SqlCommand("UPDATE dbo.SPReward SET rewardName=@n, requiredProgress=@p WHERE rewardId=@id AND studyPlanId=@pid", c, txn))
                        { cmd.Parameters.AddWithValue("@n", encodedName); cmd.Parameters.AddWithValue("@p", pct); cmd.Parameters.AddWithValue("@id", editId); cmd.Parameters.AddWithValue("@pid", _planId); cmd.ExecuteNonQuery(); }
                    }
                    txn.Commit();
                } catch { txn.Rollback(); throw; } } }
                pnlRewardForm.Visible = false; ShowMsg(T("Reward saved!", "Ganjaran disimpan!"), true);
            }
            catch { ShowMsg(T("Error saving reward.", "Ralat menyimpan ganjaran."), false); }
            LoadTaskList(); LoadRewardList(); BuildImageGrid(); BuildPreviewMarkers();
        }

        protected void BtnDeleteReward_Click(object sender, EventArgs e)
        {
            string rid = hidDeleteRewardId.Value;
            try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("DELETE FROM dbo.SPReward WHERE rewardId=@id AND studyPlanId=@pid", c)) { cmd.Parameters.AddWithValue("@id", rid); cmd.Parameters.AddWithValue("@pid", _planId); c.Open(); cmd.ExecuteNonQuery(); } ShowMsg(T("Reward deleted.", "Ganjaran dipadam."), true); } catch { ShowMsg(T("Error.", "Ralat."), false); }
            LoadTaskList(); LoadRewardList(); BuildImageGrid(); BuildPreviewMarkers();
        }

        // ═══ HELPERS ═══
        private void ParseRN(string raw, out string name, out string img) { if (raw.Contains("|||")) { var p = raw.Split(new[] { "|||" }, StringSplitOptions.None); name = p[0]; img = p.Length > 1 ? p[1] : ""; } else { name = raw; img = ""; } }
        private string GenId(SqlConnection c, SqlTransaction t, string table, string col, string prefix) { int n = 1; using (var cmd = new SqlCommand(string.Format("SELECT MAX({0}) FROM dbo.[{1}]", col, table), c, t)) { var r = cmd.ExecuteScalar(); if (r != null && r != DBNull.Value) { string last = r.ToString(); if (last.Length > prefix.Length) { int num; if (int.TryParse(last.Substring(prefix.Length), out num)) n = num + 1; } } } return prefix + n.ToString("D3"); }
        private void ShowMsg(string msg, bool ok) { pnlMessage.Visible = true; divMessage.InnerHtml = msg; iMsgIcon.Attributes["class"] = ok ? "bi bi-check-circle-fill" : "bi bi-exclamation-circle-fill"; }
        protected void BtnCloseMsg_Click(object sender, EventArgs e) { pnlMessage.Visible = false; LoadPage(); }
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