using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Parent
{
    public partial class StudyPlan : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
        protected string CurrentLanguage = "EN";
        protected string T(string en, string bm) => CurrentLanguage == "BM" ? bm : en;

        private string _parentId = "", _parentUserId = "", _selectedChildId = "", _selectedChildName = "", _studentParentId = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!EnsureAuth()) return;
            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            LoadLang(); _parentUserId = Session["userId"].ToString(); LoadParent();
            if (!IsPostBack) { LoadChildren(); if (!string.IsNullOrEmpty(_selectedChildId)) LoadPage(); else ShowNoChild(); }
            else { _selectedChildId = ddlSidebarChild.SelectedValue; _selectedChildName = ddlSidebarChild.SelectedItem != null ? ddlSidebarChild.SelectedItem.Text : ""; LoadSPId(); }
        }

        private bool EnsureAuth() { if (Session["userId"] == null || Session["role"] == null || Session["role"].ToString() != "Parent") { Response.Redirect("~/Login.aspx", false); Context.ApplicationInstance.CompleteRequest(); return false; } return true; }
        private void LoadLang() { string l = Session["preferredLanguage"] as string; if (!string.IsNullOrEmpty(l)) { CurrentLanguage = l; return; } try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT preferredLanguage FROM dbo.[User] WHERE userId=@u", c)) { cmd.Parameters.AddWithValue("@u", Session["userId"].ToString()); c.Open(); var r = cmd.ExecuteScalar(); if (r != null && r != DBNull.Value) { CurrentLanguage = r.ToString(); Session["preferredLanguage"] = CurrentLanguage; } } } catch { } }
        private void LoadParent() { try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT parentId FROM dbo.[Parent] WHERE userId=@u", c)) { cmd.Parameters.AddWithValue("@u", _parentUserId); c.Open(); var r = cmd.ExecuteScalar(); if (r != null) _parentId = r.ToString(); } } catch { } }
        private void LoadChildren() { ddlSidebarChild.Items.Clear(); try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT s.studentId, ISNULL(s.nickname,s.name) AS n FROM dbo.StudentParent sp INNER JOIN dbo.Student s ON sp.studentId=s.studentId WHERE sp.parentId=@p ORDER BY s.name", c)) { cmd.Parameters.AddWithValue("@p", _parentId); c.Open(); using (var r = cmd.ExecuteReader()) { while (r.Read()) ddlSidebarChild.Items.Add(new ListItem(r["n"].ToString(), r["studentId"].ToString())); } } } catch { } if (ddlSidebarChild.Items.Count > 0) { string saved = Session["selectedChildId"] as string; if (!string.IsNullOrEmpty(saved) && ddlSidebarChild.Items.FindByValue(saved) != null) ddlSidebarChild.SelectedValue = saved; else Session["selectedChildId"] = ddlSidebarChild.Items[0].Value; _selectedChildId = ddlSidebarChild.SelectedValue; _selectedChildName = ddlSidebarChild.SelectedItem.Text; LoadSPId(); } }
        private void LoadSPId() { try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT studentParentId FROM dbo.StudentParent WHERE parentId=@p AND studentId=@s", c)) { cmd.Parameters.AddWithValue("@p", _parentId); cmd.Parameters.AddWithValue("@s", _selectedChildId); c.Open(); var r = cmd.ExecuteScalar(); if (r != null) _studentParentId = r.ToString(); } } catch { } }
        protected void SidebarChildChanged(object sender, EventArgs e) { Session["selectedChildId"] = ddlSidebarChild.SelectedValue; _selectedChildId = ddlSidebarChild.SelectedValue; _selectedChildName = ddlSidebarChild.SelectedItem.Text; LoadSPId(); LoadPage(); }
        private void ShowNoChild() { pnlNoChild.Visible = true; pnlContent.Visible = false; pnlNoPlan.Visible = false; litNoChildMsg.Text = T("No linked child found. Please link a child account first.", "Tiada anak dipautkan. Sila pautkan akaun anak terlebih dahulu."); }

        private void LoadPage()
        {
            pnlNoChild.Visible = false;
            string planId = GetActivePlanId();
            if (string.IsNullOrEmpty(planId)) { pnlNoPlan.Visible = true; pnlContent.Visible = false; litNoPlanMsg.Text = string.Format(T("{0} does not have a study plan yet.", "{0} belum mempunyai pelan belajar."), _selectedChildName); return; }
            pnlNoPlan.Visible = false; pnlContent.Visible = true;

            // Load plan info
            string planTitle = ""; DateTime? endDate = null;
            try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT planTitle, endDate FROM dbo.StudyPlan WHERE studyPlanId=@id", c)) { cmd.Parameters.AddWithValue("@id", planId); c.Open(); using (var r = cmd.ExecuteReader()) { if (r.Read()) { planTitle = r["planTitle"] != DBNull.Value ? r["planTitle"].ToString() : ""; if (r["endDate"] != DBNull.Value) endDate = Convert.ToDateTime(r["endDate"]); } } } } catch { }
            litPlanTitle.Text = Server.HtmlEncode(planTitle);
            litPlanSub.Text = string.Format(T("{0}'s learning mission", "Misi pembelajaran {0}"), _selectedChildName);

            // Tasks
            int totalTasks = 0, completedTasks = 0;
            var tasks = new List<TaskInfo>();
            try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT spTaskId, taskTitle, suggestedAction, orderNo, isCompleted FROM dbo.SPTask WHERE studyPlanId=@id ORDER BY orderNo", c)) { cmd.Parameters.AddWithValue("@id", planId); c.Open(); using (var r = cmd.ExecuteReader()) { while (r.Read()) { var t = new TaskInfo { Title = r["taskTitle"].ToString(), Action = r["suggestedAction"] != DBNull.Value ? r["suggestedAction"].ToString() : "", IsCompleted = r["isCompleted"] != DBNull.Value && Convert.ToBoolean(r["isCompleted"]) }; tasks.Add(t); totalTasks++; if (t.IsCompleted) completedTasks++; } } } } catch { }

            int progressPct = totalTasks > 0 ? (int)Math.Round((double)completedTasks / totalTasks * 100) : 0;
            litProgressPct.Text = progressPct + "%";
            divProgressFill.Style["width"] = progressPct + "%";

            // Rewards
            var rewards = new List<RewardInfo>();
            try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT rewardId, rewardName, requiredProgress, isUnlocked FROM dbo.SPReward WHERE studyPlanId=@id ORDER BY requiredProgress", c)) { cmd.Parameters.AddWithValue("@id", planId); c.Open(); using (var r = cmd.ExecuteReader()) { while (r.Read()) { var rw = new RewardInfo { Id = r["rewardId"].ToString(), RequiredProgress = r["requiredProgress"] != DBNull.Value ? Convert.ToInt32(r["requiredProgress"]) : 100, IsUnlocked = r["isUnlocked"] != DBNull.Value && Convert.ToBoolean(r["isUnlocked"]) }; ParseRewardName(r["rewardName"] != DBNull.Value ? r["rewardName"].ToString() : "", rw); rewards.Add(rw); } } } } catch { }

            // Update unlock status based on progress
            foreach (var rw in rewards) { if (progressPct >= rw.RequiredProgress && !rw.IsUnlocked) { rw.IsUnlocked = true; UpdateRewardUnlock(rw.Id); } }

            BuildRewardMarkers(rewards, progressPct);
            BuildTaskList(tasks);
            BuildSummary(rewards, progressPct, completedTasks, totalTasks, endDate);
        }

        private string GetActivePlanId()
        {
            try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT TOP 1 studyPlanId FROM dbo.StudyPlan WHERE studentParentId=@sp AND status='Ongoing' ORDER BY createdAt DESC", c)) { cmd.Parameters.AddWithValue("@sp", _studentParentId); c.Open(); var r = cmd.ExecuteScalar(); if (r != null && r != DBNull.Value) return r.ToString(); } } catch { }
            // Fallback: latest plan regardless of status
            try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("SELECT TOP 1 studyPlanId FROM dbo.StudyPlan WHERE studentParentId=@sp ORDER BY createdAt DESC", c)) { cmd.Parameters.AddWithValue("@sp", _studentParentId); c.Open(); var r = cmd.ExecuteScalar(); if (r != null && r != DBNull.Value) return r.ToString(); } } catch { }
            return null;
        }

        private void ParseRewardName(string raw, RewardInfo rw)
        {
            if (raw.Contains("|||")) { var parts = raw.Split(new[] { "|||" }, StringSplitOptions.None); rw.Name = parts[0]; rw.ImageFile = parts.Length > 1 ? parts[1] : ""; }
            else { rw.Name = raw; rw.ImageFile = ""; }
        }

        private void UpdateRewardUnlock(string rewardId)
        {
            try { using (var c = new SqlConnection(ConnStr)) using (var cmd = new SqlCommand("UPDATE dbo.SPReward SET isUnlocked=1, unlockedAt=@now WHERE rewardId=@id", c)) { cmd.Parameters.AddWithValue("@now", DateTime.Now); cmd.Parameters.AddWithValue("@id", rewardId); c.Open(); cmd.ExecuteNonQuery(); } } catch { }
        }

        private void BuildRewardMarkers(List<RewardInfo> rewards, int progressPct)
        {
            pnlRewardMarkers.Controls.Clear();
            if (rewards.Count == 0) return;
            StringBuilder sb = new StringBuilder();
            // Find next reward
            string nextRewardId = "";
            foreach (var rw in rewards) { if (!rw.IsUnlocked && progressPct < rw.RequiredProgress) { nextRewardId = rw.Id; break; } }

            foreach (var rw in rewards)
            {
                string imgUrl = !string.IsNullOrEmpty(rw.ImageFile) ? ResolveUrl("~/Images/Rewards/" + rw.ImageFile) : "";
                string unlockedClass = rw.IsUnlocked ? "pt-reward-marker-unlocked" : "pt-reward-marker-locked";
                string nextClass = rw.Id == nextRewardId ? " pt-reward-marker-next" : "";
                string leftPct = Math.Max(2, Math.Min(98, rw.RequiredProgress)).ToString();

                sb.AppendFormat(@"<div class=""pt-reward-marker {0}{1}"" style=""left:{2}%;"" title=""{3}""
                    onclick=""document.getElementById('{4}').value='{5}';document.getElementById('{6}').click();"">",
                    unlockedClass, nextClass, leftPct, Server.HtmlEncode(rw.Name), hidRewardClick.ClientID, rw.Id, btnRewardClick.ClientID);

                if (!string.IsNullOrEmpty(imgUrl))
                    sb.AppendFormat("<img src=\"{0}\" alt=\"{1}\" />", imgUrl, Server.HtmlEncode(rw.Name));
                else
                    sb.Append("<i class=\"bi bi-gift-fill\"></i>");
                sb.Append("</div>");
            }
            pnlRewardMarkers.Controls.Add(new LiteralControl(sb.ToString()));
        }

        protected void BtnRewardClick_Click(object sender, EventArgs e)
        {
            string rewardId = hidRewardClick.Value;
            if (string.IsNullOrEmpty(rewardId)) return;
            try
            {
                using (var c = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT rewardName, requiredProgress, isUnlocked FROM dbo.SPReward WHERE rewardId=@id", c))
                {
                    cmd.Parameters.AddWithValue("@id", rewardId); c.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            string raw = r["rewardName"] != DBNull.Value ? r["rewardName"].ToString() : "";
                            string name = "", imageFile = "";
                            if (raw.Contains("|||")) { var p = raw.Split(new[] { "|||" }, StringSplitOptions.None); name = p[0]; imageFile = p.Length > 1 ? p[1] : ""; }
                            else { name = raw; }
                            int pct = r["requiredProgress"] != DBNull.Value ? Convert.ToInt32(r["requiredProgress"]) : 0;
                            bool unlocked = r["isUnlocked"] != DBNull.Value && Convert.ToBoolean(r["isUnlocked"]);

                            litPopoverName.Text = Server.HtmlEncode(name);
                            litPopoverPct.Text = string.Format(T("Unlock at {0}%", "Buka pada {0}%"), pct);
                            litPopoverStatus.Text = unlocked ? T("Unlocked!", "Terbuka!") : T("Locked", "Terkunci");
                            if (!string.IsNullOrEmpty(imageFile)) imgPopoverReward.ImageUrl = ResolveUrl("~/Images/Rewards/" + imageFile);
                            else imgPopoverReward.Visible = false;
                            pnlRewardPopover.Visible = true;
                        }
                    }
                }
            }
            catch { }
            LoadPage();
        }

        protected void BtnClosePopover_Click(object sender, EventArgs e) { pnlRewardPopover.Visible = false; LoadPage(); }

        private void BuildTaskList(List<TaskInfo> tasks)
        {
            pnlTasks.Controls.Clear();
            if (tasks.Count == 0) { pnlNoTasks.Visible = true; return; }
            pnlNoTasks.Visible = false;
            StringBuilder sb = new StringBuilder();
            int num = 1;
            foreach (var t in tasks)
            {
                string badgeClass = t.IsCompleted ? "pt-task-badge-done" : "pt-task-badge-pending";
                string badgeText = t.IsCompleted ? T("Completed", "Selesai") : T("Not Completed", "Belum Selesai");
                string icon = t.IsCompleted ? "bi-check-circle-fill" : "bi-circle";
                sb.AppendFormat(@"<div class=""pt-task-card {0}"">
                    <div class=""pt-task-card-num"">{1}</div>
                    <div class=""pt-task-card-body"">
                        <div class=""pt-task-card-title"">{2}</div>
                        <div class=""pt-task-card-action"">{3}</div>
                    </div>
                    <span class=""pt-task-status-badge {4}""><i class=""bi {5}""></i> {6}</span>
                </div>", t.IsCompleted ? "pt-task-card-completed" : "", num++,
                    Server.HtmlEncode(t.Title), Server.HtmlEncode(t.Action), badgeClass, icon, badgeText);
            }
            pnlTasks.Controls.Add(new LiteralControl(sb.ToString()));
        }

        private void BuildSummary(List<RewardInfo> rewards, int progressPct, int completed, int total, DateTime? endDate)
        {
            litCompletedCount.Text = string.Format("{0} / {1}", completed, total);

            // Next reward
            string nextReward = T("All rewards unlocked!", "Semua ganjaran terbuka!");
            foreach (var rw in rewards) { if (!rw.IsUnlocked && progressPct < rw.RequiredProgress) { nextReward = rw.Name + " (" + rw.RequiredProgress + "%)"; break; } }
            litNextReward.Text = Server.HtmlEncode(nextReward);

            // Final reward
            if (rewards.Count > 0) litFinalReward.Text = Server.HtmlEncode(rewards[rewards.Count - 1].Name);
            else litFinalReward.Text = "-";

            // Remaining days
            if (endDate.HasValue)
            {
                if (endDate.Value.Date == DateTime.Today)
                { litRemainingDays.Text = T("Due today", "Tamat hari ini"); pnlRemainingDays.Visible = true; pnlDaysLeftBanner.Visible = true; litDaysLeftBanner.Text = T("This mission is due today! Encourage your child to finish up.", "Misi ini tamat hari ini! Galakkan anak anda untuk menyiapkannya."); }
                else if (endDate.Value > DateTime.Today)
                { int days = (endDate.Value - DateTime.Today).Days; litRemainingDays.Text = days + " " + T("days", "hari"); pnlRemainingDays.Visible = true; pnlDaysLeftBanner.Visible = true; litDaysLeftBanner.Text = string.Format(T("Your child has {0} days left to complete this mission!", "Anak anda mempunyai {0} hari lagi untuk menyelesaikan misi ini!"), days); }
                else
                { int overdue = (DateTime.Today - endDate.Value).Days; litRemainingDays.Text = T("Overdue", "Tertunggak"); pnlRemainingDays.Visible = true; pnlDaysLeftBanner.Visible = true; litDaysLeftBanner.Text = string.Format(T("This mission was due {0} days ago. Keep going!", "Misi ini telah tamat {0} hari yang lalu. Teruskan!"), overdue); }
            }
            else { pnlRemainingDays.Visible = false; pnlDaysLeftBanner.Visible = false; }
        }

        private class TaskInfo { public string Title; public string Action; public bool IsCompleted; }
        private class RewardInfo { public string Id; public string Name; public string ImageFile; public int RequiredProgress; public bool IsUnlocked; }
    }
}
