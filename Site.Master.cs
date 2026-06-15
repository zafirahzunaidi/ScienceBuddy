using System;
using System.Web;
using System.Web.UI;

namespace ScienceBuddy
{
    /// <summary>
    /// ScienceBuddy Master Page
    ///
    /// Supports two layout modes controlled by the LayoutMode property:
    ///   "TopNav"  – Guest pages and dashboard (top navigation only).
    ///   "Sidebar" – Logged-in non-dashboard pages (left sidebar + top header).
    ///
    /// Child pages set the layout in their Page_Load:
    ///   ((SiteMaster)Master).LayoutMode = "TopNav";   // or "Sidebar"
    ///
    /// Optional helpers:
    ///   SetUserInfo(name, role, initials) – populate header user widget.
    ///   ShowBreadcrumb()                 – reveal breadcrumb panel.
    ///   ShowNotificationDot()            – show red dot on bell icon.
    ///   BodyCssClass                     – extra CSS classes added to <body>.
    /// </summary>
    public partial class SiteMaster : MasterPage
    {
        // ── Layout mode ─────────────────────────────────────────────
        /// <summary>
        /// "TopNav" (default) or "Sidebar".
        /// Set this in the child page's Page_Init or Page_Load
        /// before the master page renders.
        /// </summary>
        public string LayoutMode
        {
            get { return ViewState["LayoutMode"] as string ?? "TopNav"; }
            set { ViewState["LayoutMode"] = value; }
        }

        // ── CSS classes on <body> ────────────────────────────────────
        /// <summary>
        /// Additional CSS classes applied to the &lt;body&gt; element.
        /// </summary>
        public string BodyCssClass
        {
            get { return ViewState["BodyCssClass"] as string ?? string.Empty; }
            set { ViewState["BodyCssClass"] = value; }
        }

        // ── Page lifecycle ───────────────────────────────────────────
        protected void Page_Init(object sender, EventArgs e)
        {
            // Nothing needed here; layout is resolved in PreRender.
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // Nothing needed here; layout is resolved in PreRender.
        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            ApplyLayout();
        }

        // ── Layout switching ─────────────────────────────────────────
        private void ApplyLayout()
        {
            bool useSidebar = string.Equals(LayoutMode, "Sidebar", StringComparison.OrdinalIgnoreCase);

            pnlTopNavLayout.Visible = !useSidebar;
            pnlSidebarLayout.Visible = useSidebar;
        }

        // ── Public helpers for child pages ───────────────────────────

        /// <summary>
        /// Populate the logged-in user widget in the top header (sidebar layout).
        /// </summary>
        /// <param name="fullName">Display name shown next to the avatar.</param>
        /// <param name="role">Role label shown below the name (e.g. "Student").</param>
        /// <param name="initials">1–2 character initials rendered inside the avatar circle.</param>
        public void SetUserInfo(string fullName, string role, string initials)
        {
            if (litUserName     != null) litUserName.Text     = HtmlEncode(fullName  ?? "User");
            if (litUserRole     != null) litUserRole.Text     = HtmlEncode(role      ?? string.Empty);
            if (litUserInitials != null) litUserInitials.Text = HtmlEncode((initials ?? "U").ToUpper());
        }

        /// <summary>
        /// Sets the user avatar image.  If the image fails to load the
        /// initials circle acts as the fallback automatically.
        /// </summary>
        /// <param name="imageUrl">Relative or absolute URL to the avatar image.</param>
        public void SetUserAvatar(string imageUrl)
        {
            if (imgUserAvatar == null || string.IsNullOrWhiteSpace(imageUrl)) return;
            imgUserAvatar.ImageUrl = imageUrl;
            imgUserAvatar.Visible = true;
            if (litUserInitials != null) litUserInitials.Visible = false;
        }

        /// <summary>
        /// Show the red notification dot on the bell icon.
        /// </summary>
        public void ShowNotificationDot()
        {
            if (pnlNotifDot != null) pnlNotifDot.Visible = true;
        }

        /// <summary>
        /// Make the breadcrumb bar visible.
        /// Child pages fill the BreadcrumbContent placeholder with their crumbs.
        /// </summary>
        public void ShowBreadcrumb()
        {
            if (pnlBreadcrumb != null) pnlBreadcrumb.Visible = true;
        }

        // ── Utility ─────────────────────────────────────────────────
        private static string HtmlEncode(string value)
        {
            return HttpUtility.HtmlEncode(value ?? string.Empty);
        }
    }
}
