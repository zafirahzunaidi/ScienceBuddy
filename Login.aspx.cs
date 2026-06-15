using System;
using System.Web.UI;

namespace ScienceBuddy
{
    public partial class Login : Page
    {
        // ── Page lifecycle ────────────────────────────────────────────
        protected void Page_Load(object sender, EventArgs e)
        {
            // Tell the master page to use the top-nav-only layout.
            ((SiteMaster)Master).LayoutMode = "TopNav";

            if (!IsPostBack)
            {
                // Show a success message if redirected here after password reset.
                string msg = Request.QueryString["msg"];
                if (!string.IsNullOrEmpty(msg))
                {
                    switch (msg)
                    {
                        case "reset":
                            ShowSuccess("Your password has been reset. Please sign in with your new password.");
                            break;
                        case "registered":
                            ShowSuccess("Registration successful! Please sign in to start your science adventure.");
                            break;
                        case "logout":
                            ShowSuccess("You have been signed out safely.");
                            break;
                    }
                }
            }
        }

        // ── Login button click ────────────────────────────────────────
        protected void btnLogin_Click(object sender, EventArgs e)
        {
            // Server-side validation guard – ASP.NET validators already ran,
            // but we double-check the page is valid before proceeding.
            if (!Page.IsValid) return;

            // ── UI-only stub ──────────────────────────────────────────
            // Authentication logic is NOT implemented here.
            // A future phase will add database lookup and session handling.
            // For now we just surface a neutral informational message so the
            // page behaves predictably during UI review.
            ShowError("Authentication is not yet configured. This is a UI preview only.");
        }

        // ── Helpers ───────────────────────────────────────────────────
        private void ShowError(string message)
        {
            pnlError.Visible   = true;
            pnlSuccess.Visible = false;
            litError.Text      = System.Web.HttpUtility.HtmlEncode(message);
        }

        private void ShowSuccess(string message)
        {
            pnlSuccess.Visible = true;
            pnlError.Visible   = false;
            litSuccess.Text    = System.Web.HttpUtility.HtmlEncode(message);
        }
    }
}
