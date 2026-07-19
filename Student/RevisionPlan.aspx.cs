using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ScienceBuddy.Student
{
    public partial class RevisionPlan : Page
    {
        private string ConnectionString
        {
            get { return ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString; }
        }

        public string CurrentLanguage = "EN";

        public string T(string en, string bm)
        {
            if (CurrentLanguage == "BM")
            {
                return bm;
            }
            return en;
        }

        private string TaskFilter
        {
            get
            {
                string value = ViewState["TaskFilter"] as string;
                if (value == null)
                {
                    return "pending";
                }
                return value;
            }
            set { ViewState["TaskFilter"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["role"] == null || Session["role"].ToString() != "Student")
            {
                Response.Redirect("~/Login.aspx", false);
                return;
            }

            ((ScienceBuddy.SiteMaster)Master).LayoutMode = "Sidebar";
            InitLang();

            if (!IsPostBack)
            {
                SetLabels();
                LoadPlan();
            }
        }

        private void InitLang()
        {
            string lang = Session["preferredLanguage"] as string;
            if (!string.IsNullOrEmpty(lang))
            {
                CurrentLanguage = lang;
                return;
            }

            string userId = Session["userId"] as string;
            if (!string.IsNullOrEmpty(userId))
            {
                try
                {
                    using (SqlConnection connection = new SqlConnection(ConnectionString))
                    using (SqlCommand command = new SqlCommand("SELECT preferredLanguage FROM [User] WHERE userId=@u", connection))
                    {
                        command.Parameters.AddWithValue("@u", userId);
                        connection.Open();
                        object result = command.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            lang = result.ToString();
                            Session["preferredLanguage"] = lang;
                            CurrentLanguage = lang;
                            return;
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("Error: " + ex.Message);
                }
            }

            CurrentLanguage = "EN";
            Session["preferredLanguage"] = "EN";
        }

        private void SetLabels()
        {
            litPageTitle.Text = T("Revision Plan", "Pelan Ulang Kaji");
            litHeroTitle.Text = T("My Revision Mission", "Misi Ulang Kaji Saya");
            litHeroSub.Text = T("Complete your tasks, unlock rewards, and keep learning with Buddy!",
                                "Selesaikan tugasan, buka ganjaran, dan terus belajar bersama Buddy!");
            litEmptyTitle.Text = T("No revision plan yet.", "Tiada pelan ulang kaji lagi.");
            litEmptyDesc.Text = T("Ask your parent to create a study plan for you, or continue learning from My Learning.",
                                  "Minta ibu bapa anda cipta pelan belajar, atau teruskan pembelajaran di Pembelajaran Saya.");
            litEmptyBtn.Text = T("Go to My Learning", "Pergi ke Pembelajaran Saya");
            litTasksTitle.Text = T("Mission Tasks", "Tugasan Misi");
            litRewardsTitle.Text = T("Reward Milestones", "Pencapaian Ganjaran");
            litNavProgress.Text = T("View Progress & Rewards", "Lihat Kemajuan & Ganjaran");
            litNavLearning.Text = T("Continue Learning", "Teruskan Pembelajaran");
            btnFilterPending.Text = "<i class='bi bi-circle'></i> " + T("Pending", "Belum Selesai");
            btnFilterCompleted.Text = "<i class='bi bi-check-circle-fill'></i> " + T("Completed", "Selesai");
            btnFilterAll.Text = "<i class='bi bi-list-ul'></i> " + T("All", "Semua");
        }

        private void LoadPlan()
        {
            string userId = Session["userId"].ToString();

            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                connection.Open();

                // Get studentId
                string studentId = null;
                using (SqlCommand command = new SqlCommand("SELECT studentId FROM Student WHERE userId=@u", connection))
                {
                    command.Parameters.AddWithValue("@u", userId);
                    object result = command.ExecuteScalar();
                    if (result != null)
                    {
                        studentId = result.ToString();
                    }
                }
                if (string.IsNullOrEmpty(studentId))
                {
                    ShowEmpty();
                    return;
                }

                // Get active study plan via StudentParent — JOIN to get parent name
                const string planSql = @"
                    SELECT TOP 1 sp.studyPlanId, sp.planTitle, sp.startDate, sp.endDate, sp.status,
                           p.name AS parentName
                    FROM StudyPlan sp
                    INNER JOIN StudentParent stp ON stp.studentParentId = sp.studentParentId
                    LEFT JOIN Parent p ON p.parentId = stp.parentId
                    WHERE stp.studentId = @sid
                      AND sp.status IN ('Ongoing','Completed')
                    ORDER BY CASE WHEN sp.status='Ongoing' THEN 0 ELSE 1 END, sp.createdAt DESC";

                string planId = null;
                string planTitle = "";
                string planStatus = "";
                string parentName = "";
                DateTime startDate = DateTime.Today;
                DateTime endDate = DateTime.Today;

                using (SqlCommand command = new SqlCommand(planSql, connection))
                {
                    command.Parameters.AddWithValue("@sid", studentId);
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            planId = reader["studyPlanId"].ToString();

                            if (reader["planTitle"] != null)
                            {
                                planTitle = reader["planTitle"].ToString();
                            }

                            if (reader["status"] != null)
                            {
                                planStatus = reader["status"].ToString();
                            }
                            else
                            {
                                planStatus = "Ongoing";
                            }

                            if (reader["startDate"] != DBNull.Value)
                            {
                                startDate = Convert.ToDateTime(reader["startDate"]);
                            }

                            if (reader["endDate"] != DBNull.Value)
                            {
                                endDate = Convert.ToDateTime(reader["endDate"]);
                            }

                            if (reader["parentName"] != null)
                            {
                                parentName = reader["parentName"].ToString();
                            }
                        }
                    }
                }

                if (string.IsNullOrEmpty(planId))
                {
                    ShowEmpty();
                    return;
                }

                // Load tasks
                DataTable tasks = new DataTable();
                using (SqlCommand command = new SqlCommand("SELECT spTaskId, taskTitle, suggestedAction, orderNo, isCompleted, completedAt FROM SPTask WHERE studyPlanId=@pid ORDER BY orderNo", connection))
                {
                    command.Parameters.AddWithValue("@pid", planId);
                    SqlDataAdapter adapter = new SqlDataAdapter(command);
                    adapter.Fill(tasks);
                }

                // Load rewards (include rewardImage)
                DataTable rewards = new DataTable();
                using (SqlCommand command = new SqlCommand("SELECT rewardId, rewardName, requiredProgress, isUnlocked, unlockedAt, rewardImage FROM SPReward WHERE studyPlanId=@pid ORDER BY requiredProgress", connection))
                {
                    command.Parameters.AddWithValue("@pid", planId);
                    SqlDataAdapter adapter = new SqlDataAdapter(command);
                    adapter.Fill(rewards);
                }

                // Calculate progress
                int totalTasks = tasks.Rows.Count;
                int completedTasks = 0;
                foreach (DataRow row in tasks.Rows)
                {
                    if (row["isCompleted"] != DBNull.Value && Convert.ToBoolean(row["isCompleted"]))
                    {
                        completedTasks++;
                    }
                }

                int progressPct = 0;
                if (totalTasks > 0)
                {
                    progressPct = (int)Math.Round((double)completedTasks / totalTasks * 100);
                }

                // Remaining days
                int remainingDays = (endDate.Date - DateTime.Today).Days;
                bool isOverdue = remainingDays < 0 && planStatus != "Completed";
                bool isCompleted = planStatus == "Completed" || (totalTasks > 0 && completedTasks == totalTasks);

                // Show plan
                pnlPlan.Visible = true;
                pnlEmpty.Visible = false;

                // Summary
                litPlanTitle.Text = HttpUtility.HtmlEncode(planTitle);
                litDateRange.Text = startDate.ToString("dd MMM yyyy") + " - " + endDate.ToString("dd MMM yyyy");

                // Parent name with fallback
                if (!string.IsNullOrWhiteSpace(parentName))
                {
                    litParentLabel.Text = T("From: ", "Daripada: ") + HttpUtility.HtmlEncode(parentName);
                }
                else
                {
                    litParentLabel.Text = T("From: Parent / Guardian", "Daripada: Ibu Bapa / Penjaga");
                }

                litProgressLabel.Text = T("Mission Progress", "Kemajuan Misi");
                litProgressPct.Text = progressPct + "%";
                divProgressFill.Style["width"] = progressPct + "%";
                litTaskCounts.Text = completedTasks + " " + T("of", "daripada") + " " + totalTasks + " " + T("mission tasks completed", "tugasan misi selesai");

                // Progress badge style
                if (isCompleted)
                {
                    divProgressBadge.Attributes["class"] = "st-revision-progress-badge st-revision-badge-complete";
                }
                else if (isOverdue)
                {
                    divProgressBadge.Attributes["class"] = "st-revision-progress-badge st-revision-badge-overdue";
                }
                else
                {
                    divProgressBadge.Attributes["class"] = "st-revision-progress-badge";
                }

                // Motivational text
                if (isCompleted)
                {
                    litMotivate.Text = T("Amazing! You completed this learning mission.",
                                         "Hebat! Anda telah menyelesaikan misi pembelajaran ini.");
                }
                else if (progressPct < 50)
                {
                    litMotivate.Text = T("Keep going, your next reward is getting closer!",
                                         "Teruskan usaha, ganjaran seterusnya semakin hampir!");
                }
                else
                {
                    litMotivate.Text = T("You're doing great! Almost there!",
                                         "Anda sedang hebat! Hampir sampai!");
                }

                // Status badge
                if (isCompleted)
                {
                    spanStatus.Attributes["class"] = "st-revision-status-badge st-revision-status-completed";
                    litStatus.Text = T("Completed", "Selesai");
                }
                else if (isOverdue)
                {
                    spanStatus.Attributes["class"] = "st-revision-status-badge st-revision-status-overdue";
                    litStatus.Text = T("Overdue", "Terlepas");
                }
                else
                {
                    spanStatus.Attributes["class"] = "st-revision-status-badge st-revision-status-ongoing";
                    litStatus.Text = T("Ongoing", "Sedang Berjalan");
                }

                // Remaining text
                if (isCompleted)
                {
                    litRemaining.Text = T("Mission Complete!", "Misi Selesai!");
                }
                else if (isOverdue)
                {
                    litRemaining.Text = Math.Abs(remainingDays) + " " + T("days overdue", "hari terlepas");
                }
                else
                {
                    litRemaining.Text = remainingDays + " " + T("days left", "hari lagi");
                }

                // Alert
                if (isOverdue && !isCompleted)
                {
                    pnlAlert.Visible = true;
                    divAlert.Attributes["class"] = "st-revision-alert st-revision-alert-warning";
                    iAlertIcon.Attributes["class"] = "bi bi-exclamation-triangle-fill";
                    litAlert.Text = T("This mission is overdue, but you can still keep going!",
                                      "Misi ini telah melepasi tarikh, tetapi anda masih boleh teruskan!");
                }
                else if (isCompleted)
                {
                    pnlAlert.Visible = true;
                    divAlert.Attributes["class"] = "st-revision-alert st-revision-alert-success";
                    iAlertIcon.Attributes["class"] = "bi bi-trophy-fill";
                    litAlert.Text = T("Amazing! You completed this revision mission! You can still review your tasks and rewards anytime.",
                                      "Hebat! Anda telah menyelesaikan misi ini! Anda masih boleh melihat semula tugasan dan ganjaran pada bila-bila masa.");
                }

                // Build milestone markers HTML
                BuildMilestones(rewards, progressPct);

                // Reward summary cards
                string nextRewardName = "";
                string nextRewardImage = "";
                int nextReqPct = 0;
                string finalRewardName = "";
                string finalRewardImage = "";
                foreach (DataRow row in rewards.Rows)
                {
                    bool unlocked = row["isUnlocked"] != DBNull.Value && Convert.ToBoolean(row["isUnlocked"]);
                    string rName = "";
                    if (row["rewardName"] != null)
                    {
                        rName = row["rewardName"].ToString();
                    }
                    string rImage = "";
                    if (row["rewardImage"] != DBNull.Value)
                    {
                        rImage = row["rewardImage"].ToString();
                    }
                    int reqPct = 0;
                    if (row["requiredProgress"] != DBNull.Value)
                    {
                        reqPct = Convert.ToInt32(row["requiredProgress"]);
                    }
                    if (!unlocked && string.IsNullOrEmpty(nextRewardName))
                    {
                        nextRewardName = rName;
                        nextReqPct = reqPct;
                        nextRewardImage = rImage;
                    }
                    finalRewardName = rName;
                    finalRewardImage = rImage;
                }

                // Next reward card
                litNextRewardLabel.Text = T("Next Reward", "Ganjaran Seterusnya");
                if (string.IsNullOrEmpty(nextRewardName))
                {
                    litNextReward.Text = T("All rewards unlocked!", "Semua ganjaran telah dibuka!");
                }
                else
                {
                    litNextReward.Text = HttpUtility.HtmlEncode(nextRewardName) + " <span class='st-revision-reward-box-pct'>" + T("at ", "pada ") + nextReqPct + "%</span>";
                }
                litNextRewardImg.Text = BuildRewardImgHtml(nextRewardImage, "bi bi-gift-fill");

                // Final reward card
                litFinalRewardLabel.Text = T("Final Reward", "Ganjaran Akhir");
                if (string.IsNullOrEmpty(finalRewardName))
                {
                    litFinalReward.Text = "\u2014";
                }
                else
                {
                    litFinalReward.Text = HttpUtility.HtmlEncode(finalRewardName);
                }
                litFinalRewardImg.Text = BuildRewardImgHtml(finalRewardImage, "bi bi-trophy-fill");

                // Default filter: only set on first load, not on filter postback
                if (!IsPostBack)
                {
                    if (completedTasks >= totalTasks && totalTasks > 0)
                    {
                        TaskFilter = "completed";
                    }
                    else
                    {
                        TaskFilter = "pending";
                    }
                }

                // Bind tasks with filter
                BindTasks(tasks);

                // Bind rewards
                BindRewards(rewards);

                // Update filter tab active state
                UpdateFilterTabs();

                // Store for postback
                ViewState["PlanId"] = planId;
                ViewState["StudentId"] = studentId;
            }
        }

        private void BuildMilestones(DataTable rewards, int progressPct)
        {
            if (rewards.Rows.Count == 0)
            {
                litMilestones.Text = "";
                return;
            }

            string html = "";
            foreach (DataRow row in rewards.Rows)
            {
                int reqPct = 0;
                if (row["requiredProgress"] != DBNull.Value)
                {
                    reqPct = Convert.ToInt32(row["requiredProgress"]);
                }

                bool unlocked = row["isUnlocked"] != DBNull.Value && Convert.ToBoolean(row["isUnlocked"]);

                string rName = "";
                if (row["rewardName"] != null)
                {
                    rName = HttpUtility.HtmlAttributeEncode(row["rewardName"].ToString());
                }

                string rewardImage = "";
                if (row["rewardImage"] != DBNull.Value)
                {
                    rewardImage = row["rewardImage"].ToString();
                }

                string stateClass;
                if (unlocked)
                {
                    stateClass = "unlocked";
                }
                else
                {
                    stateClass = "locked";
                }

                string imgHtml;
                if (!string.IsNullOrWhiteSpace(rewardImage))
                {
                    string resolvedUrl = ResolveUrl("~/" + rewardImage.TrimStart('~', '/'));
                    imgHtml = "<img src=\"" + HttpUtility.HtmlAttributeEncode(resolvedUrl) + "\" alt=\"" + rName + "\" onerror=\"this.style.display='none';this.nextElementSibling.style.display='flex';\" /><span class='st-revision-ms-fallback' style='display:none;'><i class='bi bi-gift-fill'></i></span>";
                }
                else
                {
                    imgHtml = "<i class='bi bi-gift-fill'></i>";
                }

                html += string.Format(
                    "<div class='st-revision-milestone {0}' style='left:{1}%' title='{2} ({1}%)'>" +
                    "<div class='st-revision-ms-img'>{3}</div>" +
                    "<div class='st-revision-ms-label'>{1}%</div>" +
                    "</div>",
                    stateClass, reqPct, rName, imgHtml);
            }
            litMilestones.Text = html;
        }

        private void BindTasks(DataTable tasks)
        {
            string filter = TaskFilter;
            string completedLabel = T("Completed", "Selesai");
            string pendingLabel = T("Not Completed", "Belum Selesai");
            string btnText = T("Mark as Completed", "Tanda Selesai");

            List<object> taskList = new List<object>();
            foreach (DataRow row in tasks.Rows)
            {
                bool done = row["isCompleted"] != DBNull.Value && Convert.ToBoolean(row["isCompleted"]);

                // Apply filter
                if (filter == "pending" && done)
                {
                    continue;
                }
                if (filter == "completed" && !done)
                {
                    continue;
                }

                string completedDate = "";
                if (done && row["completedAt"] != DBNull.Value)
                {
                    completedDate = Convert.ToDateTime(row["completedAt"]).ToString("dd MMM yyyy");
                }

                taskList.Add(new
                {
                    SpTaskId = row["spTaskId"].ToString(),
                    OrderNo = row["orderNo"] != DBNull.Value ? Convert.ToInt32(row["orderNo"]) : 0,
                    TaskTitle = HttpUtility.HtmlEncode(row["taskTitle"]?.ToString() ?? ""),
                    SuggestedAction = HttpUtility.HtmlEncode(row["suggestedAction"]?.ToString() ?? ""),
                    IsCompleted = done,
                    CompletedDate = completedDate,
                    CompletedLabel = completedLabel,
                    PendingLabel = pendingLabel,
                    BtnText = btnText
                });
            }

            if (taskList.Count == 0)
            {
                pnlTaskEmpty.Visible = true;
                if (filter == "pending")
                {
                    litTaskEmpty.Text = T("All tasks are completed! View completed tasks to see your past work.",
                                          "Semua tugasan telah selesai! Lihat tugasan selesai untuk melihat kerja anda.");
                }
                else if (filter == "completed")
                {
                    litTaskEmpty.Text = T("No completed tasks yet. Start with your first mission task!",
                                          "Belum ada tugasan selesai. Mulakan dengan tugasan misi pertama anda!");
                }
                else
                {
                    litTaskEmpty.Text = T("No tasks available.", "Tiada tugasan tersedia.");
                }
            }
            else
            {
                pnlTaskEmpty.Visible = false;
            }

            rptTasks.DataSource = taskList;
            rptTasks.DataBind();
        }

        private void BindRewards(DataTable rewards)
        {
            List<object> rewardList = new List<object>();
            foreach (DataRow row in rewards.Rows)
            {
                bool unlocked = row["isUnlocked"] != DBNull.Value && Convert.ToBoolean(row["isUnlocked"]);
                int reqProgress = 0;
                if (row["requiredProgress"] != DBNull.Value)
                {
                    reqProgress = Convert.ToInt32(row["requiredProgress"]);
                }

                string unlockedDate = "";
                if (unlocked && row["unlockedAt"] != DBNull.Value)
                {
                    unlockedDate = Convert.ToDateTime(row["unlockedAt"]).ToString("dd MMM yyyy");
                }

                string rewardImage = "";
                if (row["rewardImage"] != DBNull.Value)
                {
                    rewardImage = ResolveUrl("~/" + rewardImage);
                }

                string imageUrl = "";
                if (!string.IsNullOrWhiteSpace(rewardImage))
                {
                    imageUrl = ResolveUrl("~/" + rewardImage);
                }

                rewardList.Add(new
                {
                    RewardName = HttpUtility.HtmlEncode(row["rewardName"]?.ToString() ?? ""),
                    IsUnlocked = unlocked,
                    ProgressLabel = T("Unlocks at ", "Buka pada ") + reqProgress + "%",
                    UnlockedDate = unlockedDate,
                    ImageUrl = imageUrl
                });
            }
            rptRewards.DataSource = rewardList;
            rptRewards.DataBind();
        }

        private void UpdateFilterTabs()
        {
            string f = TaskFilter;
            if (f == "pending")
            {
                btnFilterPending.CssClass = "st-revision-tab active";
            }
            else
            {
                btnFilterPending.CssClass = "st-revision-tab";
            }

            if (f == "completed")
            {
                btnFilterCompleted.CssClass = "st-revision-tab active";
            }
            else
            {
                btnFilterCompleted.CssClass = "st-revision-tab";
            }

            if (f == "all")
            {
                btnFilterAll.CssClass = "st-revision-tab active";
            }
            else
            {
                btnFilterAll.CssClass = "st-revision-tab";
            }
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            LinkButton button = (LinkButton)sender;
            TaskFilter = button.CommandArgument;
            InitLang();
            SetLabels();
            LoadPlan();
        }

        protected void rptTasks_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "MarkDone")
            {
                return;
            }

            InitLang();

            string taskId = e.CommandArgument.ToString();
            string planId = ViewState["PlanId"] as string;

            if (string.IsNullOrEmpty(taskId) || string.IsNullOrEmpty(planId))
            {
                return;
            }

            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                connection.Open();
                using (SqlTransaction trans = connection.BeginTransaction())
                {
                    try
                    {
                        // Mark task completed
                        using (SqlCommand command = new SqlCommand("UPDATE SPTask SET isCompleted=1, completedAt=@now WHERE spTaskId=@tid AND studyPlanId=@pid", connection, trans))
                        {
                            command.Parameters.AddWithValue("@now", DateTime.Now);
                            command.Parameters.AddWithValue("@tid", taskId);
                            command.Parameters.AddWithValue("@pid", planId);
                            command.ExecuteNonQuery();
                        }

                        // Recalculate progress
                        int total = 0;
                        int completed = 0;
                        using (SqlCommand command = new SqlCommand("SELECT COUNT(*) FROM SPTask WHERE studyPlanId=@pid", connection, trans))
                        {
                            command.Parameters.AddWithValue("@pid", planId);
                            total = (int)command.ExecuteScalar();
                        }
                        using (SqlCommand command = new SqlCommand("SELECT COUNT(*) FROM SPTask WHERE studyPlanId=@pid AND isCompleted=1", connection, trans))
                        {
                            command.Parameters.AddWithValue("@pid", planId);
                            completed = (int)command.ExecuteScalar();
                        }

                        int pct = 0;
                        if (total > 0)
                        {
                            pct = (int)Math.Round((double)completed / total * 100);
                        }

                        // Unlock rewards
                        using (SqlCommand command = new SqlCommand("UPDATE SPReward SET isUnlocked=1, unlockedAt=@now WHERE studyPlanId=@pid AND isUnlocked=0 AND requiredProgress<=@pct", connection, trans))
                        {
                            command.Parameters.AddWithValue("@now", DateTime.Now);
                            command.Parameters.AddWithValue("@pid", planId);
                            command.Parameters.AddWithValue("@pct", pct);
                            command.ExecuteNonQuery();
                        }

                        // If all completed, update plan status
                        if (completed >= total && total > 0)
                        {
                            using (SqlCommand command = new SqlCommand("UPDATE StudyPlan SET status='Completed' WHERE studyPlanId=@pid", connection, trans))
                            {
                                command.Parameters.AddWithValue("@pid", planId);
                                command.ExecuteNonQuery();
                            }
                        }

                        trans.Commit();

                        // Award XP for completing task (XP009)
                        string studentId = ViewState["StudentId"] as string;
                        if (!string.IsNullOrEmpty(studentId))
                        {
                            AwardTaskXp(connection, studentId);
                        }

                        // Notify parent(s) of task completion
                        try
                        {
                            string taskStudentUserId = Session["userId"].ToString();
                            using (SqlCommand pCmd = new SqlCommand("SELECT p.userId FROM Parent p JOIN StudentParent sp ON sp.parentId=p.parentId JOIN Student s ON s.studentId=sp.studentId WHERE s.userId=@uid", connection))
                            {
                                pCmd.Parameters.AddWithValue("@uid", taskStudentUserId);
                                using (SqlDataReader rdr = pCmd.ExecuteReader())
                                {
                                    List<string> parentIds = new System.Collections.Generic.List<string>();
                                    while (rdr.Read()) { parentIds.Add(rdr["userId"].ToString()); }
                                    rdr.Close();
                                    foreach (string pid in parentIds)
                                    {
                                        SendNotification(connection, pid, "Study Plan Progress", "Kemajuan Pelan Belajar", "Your child completed a revision task.", "Anak anda menyelesaikan tugasan ulang kaji.");
                                    }
                                }
                            }
                        }
                        catch (Exception notifEx)
                        {
                            System.Diagnostics.Debug.WriteLine("Task notification error: " + notifEx.Message);
                        }

                        pnlSuccess.Visible = true;
                        litSuccess.Text = T("Task completed! Keep going!", "Tugasan selesai! Teruskan!");
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        System.Diagnostics.Debug.WriteLine("Error: " + ex.Message);
                    }
                }
            }

            SetLabels();
            LoadPlan();
        }

        private void ShowEmpty()
        {
            pnlEmpty.Visible = true;
            pnlPlan.Visible = false;
        }

        private string BuildRewardImgHtml(string rewardImage, string fallbackIcon)
        {
            if (!string.IsNullOrWhiteSpace(rewardImage))
            {
                string url = ResolveUrl("~/" + rewardImage.TrimStart('~', '/'));
                return "<img src=\"" + HttpUtility.HtmlAttributeEncode(url) + "\" alt=\"Reward\" onerror=\"this.style.display='none';this.nextElementSibling.style.display='flex';\" /><span class='st-revision-rbox-fallback' style='display:none;'><i class='" + fallbackIcon + "'></i></span>";
            }
            return "<i class='" + fallbackIcon + "'></i>";
        }

        // Award XP for completing study plan task (XP009)
        private void AwardTaskXp(SqlConnection conn, string studentId)
        {
            try
            {
                int xpAmount = 0;
                using (SqlCommand command = new SqlCommand("SELECT xpValue FROM XPAction WHERE xpActionId='XP009'", conn))
                {
                    object result = command.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        xpAmount = Convert.ToInt32(result);
                    }
                }
                if (xpAmount <= 0)
                {
                    return;
                }

                string xtId = "XPT001";
                using (SqlCommand command = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING(xpTransactionId,4,LEN(xpTransactionId)-3) AS INT)),0) FROM XPTransaction WHERE xpTransactionId LIKE 'XPT[0-9]%'", conn))
                {
                    xtId = "XPT" + (Convert.ToInt32(command.ExecuteScalar()) + 1).ToString("D3");
                }

                using (SqlCommand command = new SqlCommand("INSERT INTO XPTransaction(xpTransactionId,studentId,xpActionId,xpAmount,dateEarned) VALUES(@id,@s,@a,@xp,@dt)", conn))
                {
                    command.Parameters.AddWithValue("@id", xtId);
                    command.Parameters.AddWithValue("@s", studentId);
                    command.Parameters.AddWithValue("@a", "XP009");
                    command.Parameters.AddWithValue("@xp", xpAmount);
                    command.Parameters.AddWithValue("@dt", DateTime.Today);
                    command.ExecuteNonQuery();
                }

                using (SqlCommand command = new SqlCommand("UPDATE Student SET XP=ISNULL(XP,0)+@xp WHERE studentId=@s", conn))
                {
                    command.Parameters.AddWithValue("@xp", xpAmount);
                    command.Parameters.AddWithValue("@s", studentId);
                    command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Task XP error: " + ex.Message);
            }
        }

        private void SendNotification(SqlConnection conn, string toUserId, string titleEN, string titleBM, string msgEN, string msgBM)
        {
            try
            {
                string nId = "N001";
                using (SqlCommand command = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING(notificationId,2,LEN(notificationId)-1) AS INT)),0) FROM Notification WHERE notificationId LIKE 'N[0-9]%'", conn))
                {
                    nId = "N" + (Convert.ToInt32(command.ExecuteScalar()) + 1).ToString("D3");
                }
                using (SqlCommand command = new SqlCommand("INSERT INTO Notification(notificationId,toUserId,titleEN,titleBM,messageEN,messageBM,isRead,createdAt) VALUES(@id,@to,@tEN,@tBM,@mEN,@mBM,0,@dt)", conn))
                {
                    command.Parameters.AddWithValue("@id", nId);
                    command.Parameters.AddWithValue("@to", toUserId);
                    command.Parameters.AddWithValue("@tEN", titleEN);
                    command.Parameters.AddWithValue("@tBM", titleBM);
                    command.Parameters.AddWithValue("@mEN", msgEN);
                    command.Parameters.AddWithValue("@mBM", msgBM);
                    command.Parameters.AddWithValue("@dt", DateTime.Now);
                    command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Notification error: " + ex.Message);
            }
        }
    }
}

