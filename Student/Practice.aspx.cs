using System;
using System.Web.UI;

namespace ScienceBuddy.Student
{
    public partial class Practice : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // TASK 1:
            // Check if the user is logged in and is a Student.
            // If not, redirect to Login.aspx
            // Hint: look at how Dashboard.aspx.cs does it using Session["userId"] and Session["role"]

            // TASK 2:
            // Tell the master page to use the Sidebar layout.
            // Hint: look at how other student pages do it using (SiteMaster)Master).LayoutMode
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            // TASK 3:
            // Read the value from txtName and txtSubject using .Text.Trim()
            // Store them in local string variables

            // TASK 4:
            // Validate that neither field is empty.
            // If either is empty:
            //   - Set litError.Text to an error message
            //   - Set pnlError.Visible = true
            //   - Set pnlGreeting.Visible = false
            //   - return (stop the method here)

            // TASK 5:
            // If both fields have values:
            //   - Build a greeting string like:
            //     "Hi [name]! It's great that you love [subject]!"
            //   - Set litGreeting.Text to that string
            //   - Set pnlGreeting.Visible = true
            //   - Set pnlError.Visible = false
        }
    }
}
