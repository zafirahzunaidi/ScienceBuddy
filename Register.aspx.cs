using System;
using System.Web.UI;

namespace ScienceBuddy
{
    public partial class Register : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] != null && Session["role"] != null)
            { Response.Redirect("~/", false); Context.ApplicationInstance.CompleteRequest(); return; }
            ((SiteMaster)Master).LayoutMode = "TopNav";
        }
    }
}
