using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace ScienceBuddy
{
    public partial class Logout : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Log logout
            string logoutUserId = Session["userId"] as string;
            if (!string.IsNullOrEmpty(logoutUserId))
            {
                AddLog(logoutUserId, "Logout", "User signed out of the system.", "Success");
            }

            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Login.aspx?msg=logout", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private void AddLog(string userId, string action, string description, string status)
        {
            try
            {
                string connStr = ConfigurationManager.ConnectionStrings["ScienceBuddy_DB"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    string logId = "LOG001";
                    using (SqlCommand cmd = new SqlCommand("SELECT ISNULL(MAX(CAST(SUBSTRING(logId,4,LEN(logId)-3) AS INT)),0) FROM Log WHERE logId LIKE 'LOG[0-9]%'", conn))
                    {
                        logId = "LOG" + (Convert.ToInt32(cmd.ExecuteScalar()) + 1).ToString("D3");
                    }
                    using (SqlCommand cmd = new SqlCommand("INSERT INTO Log(logId,userId,action,description,logDateTime,status) VALUES(@lid,@uid,@act,@desc,@dt,@st)", conn))
                    {
                        cmd.Parameters.AddWithValue("@lid", logId);
                        cmd.Parameters.AddWithValue("@uid", userId);
                        cmd.Parameters.AddWithValue("@act", action);
                        cmd.Parameters.AddWithValue("@desc", description);
                        cmd.Parameters.AddWithValue("@dt", DateTime.Now);
                        cmd.Parameters.AddWithValue("@st", status);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Log error: " + ex.Message);
            }
        }
    }
}