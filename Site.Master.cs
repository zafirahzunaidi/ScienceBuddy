using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace ScienceBuddy
{
    public partial class SiteMaster : MasterPage
    {
        // ── Layout mode ─────────────────────────────────────────────
        public string LayoutMode
        {
            get { return ViewState["LayoutMode"] as string ?? "TopNav"; }
            set { ViewState["LayoutMode"] = value; }
        }

        // ── CSS classes on <body> ────────────────────────────────────
        public string BodyCssClass
        {
            get { return ViewState["BodyCssClass"] as string ?? string.Empty; }
            set { ViewState["BodyCssClass"] = value; }
        }

        // ── Page lifecycle ───────────────────────────────────────────
        protected void Page_Init(object sender, EventArgs e)
        {
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // If user is logged in but language not yet set in Session, load from DB.
                InitLanguageFromDB();
                ApplyLanguageToggleState();
            }
        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            ApplyLayout();
            ApplyLanguageToggleState();
            AutoPopulateUserProfile();
        }

        // ── Layout switching ─────────────────────────────────────────
        private void ApplyLayout()
        {
            bool useSidebar = string.Equals(LayoutMode, "Sidebar", StringComparison.OrdinalIgnoreCase);
            pnlTopNavLayout.Visible  = !useSidebar;
            pnlSidebarLayout.Visible = useSidebar;
        }

        // ══════════════════════════════════════════════════════════════
        //  LANGUAGE SWITCHER
        // ══════════════════════════════════════════════════════════════

        /// <summary>
        /// Returns the current preferred language from Session (EN or BM).
        /// </summary>
        public string CurrentLanguage
        {
            get
            {
                string lang = Session["preferredLanguage"] as string;
                return string.IsNullOrEmpty(lang) ? "EN" : lang;
            }
        }

        /// <summary>
        /// On first load, if logged in and Session["preferredLanguage"] is empty,
        /// fetch from User table so the toggle reflects their saved preference.
        /// </summary>
        private void InitLanguageFromDB()
        {
            if (Session["preferredLanguage"] != null) return; // already set
            string userId = Session["userId"] as string;
            if (string.IsNullOrEmpty(userId)) return; // not logged in

            try
            {
                string connStr = ConfigurationManager
                    .ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

                const string sql = "SELECT preferredLanguage FROM [User] WHERE userId = @userId";
                using (var conn = new SqlConnection(connStr))
                using (var cmd  = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != System.DBNull.Value)
                    {
                        Session["preferredLanguage"] = result.ToString();
                    }
                    else
                    {
                        Session["preferredLanguage"] = "EN";
                    }
                }
            }
            catch (SqlException)
            {
                Session["preferredLanguage"] = "EN";
            }
        }

        /// <summary>
        /// Applies active/inactive CSS class to all language toggle buttons.
        /// </summary>
        private void ApplyLanguageToggleState()
        {
            string lang = CurrentLanguage;
            string activeClass  = "sb-lang-btn active";
            string defaultClass = "sb-lang-btn";

            // Top-nav layout buttons
            if (btnLangEN_Top != null)
                btnLangEN_Top.CssClass = lang == "EN" ? activeClass : defaultClass;
            if (btnLangBM_Top != null)
                btnLangBM_Top.CssClass = lang == "BM" ? activeClass : defaultClass;

            // Sidebar-header layout buttons
            if (btnLangEN_Header != null)
                btnLangEN_Header.CssClass = lang == "EN" ? activeClass : defaultClass;
            if (btnLangBM_Header != null)
                btnLangBM_Header.CssClass = lang == "BM" ? activeClass : defaultClass;
        }

        /// <summary>Click handler — switch to English.</summary>
        protected void btnLangEN_Click(object sender, EventArgs e)
        {
            SetLanguage("EN");
        }

        /// <summary>Click handler — switch to Bahasa Melayu.</summary>
        protected void btnLangBM_Click(object sender, EventArgs e)
        {
            SetLanguage("BM");
        }

        /// <summary>
        /// Core language switch logic:
        /// 1) Update Session
        /// 2) If logged in, update User.preferredLanguage in DB
        /// 3) Redirect to same page (refresh)
        /// </summary>
        private void SetLanguage(string lang)
        {
            Session["preferredLanguage"] = lang;

            // If user is logged in, persist to database
            string userId = Session["userId"] as string;
            if (!string.IsNullOrEmpty(userId))
            {
                try
                {
                    string connStr = ConfigurationManager
                        .ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

                    const string sql = @"
                        UPDATE [User]
                        SET    preferredLanguage = @lang
                        WHERE  userId = @userId";

                    using (var conn = new SqlConnection(connStr))
                    using (var cmd  = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@lang",   lang);
                        cmd.Parameters.AddWithValue("@userId", userId);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
                catch (SqlException)
                {
                    // Silently fail — Session still holds the value.
                }
            }

            // Refresh current page
            Response.Redirect(Request.RawUrl, false);
        }

        // ══════════════════════════════════════════════════════════════
        //  AUTO-POPULATE USER PROFILE IN HEADER
        // ══════════════════════════════════════════════════════════════

        /// <summary>
        /// Automatically loads the logged-in user's display name and role
        /// into the top header widget. Uses Session cache to avoid repeated DB hits.
        /// Only runs when user is logged in and the header still shows defaults.
        /// Child pages that call SetUserInfo() manually will override this.
        /// </summary>
        private void AutoPopulateUserProfile()
        {
            // Only for sidebar layout (logged-in pages)
            if (!string.Equals(LayoutMode, "Sidebar", StringComparison.OrdinalIgnoreCase))
                return;

            string userId = Session["userId"] as string;
            if (string.IsNullOrEmpty(userId)) return;

            // If a child page already set it (text != default), skip
            if (litUserName != null && litUserName.Text != "Guest" && litUserName.Text != "User")
                return;

            // Try Session cache first
            string displayName = Session["_profileName"] as string;
            string role        = Session["role"] as string ?? "User";

            if (string.IsNullOrEmpty(displayName))
            {
                // Load from DB
                try
                {
                    string connStr = ConfigurationManager
                        .ConnectionStrings["ScienceBuddy_DB"].ConnectionString;

                    string sql = "";
                    switch (role)
                    {
                        case "Student":
                            sql = @"SELECT s.nickname, s.name
                                    FROM Student s WHERE s.userId = @userId";
                            break;
                        case "Teacher":
                            sql = @"SELECT name, name AS nickname
                                    FROM Teacher WHERE userId = @userId";
                            break;
                        case "Parent":
                            sql = @"SELECT name, name AS nickname
                                    FROM Parent WHERE userId = @userId";
                            break;
                        default:
                            sql = @"SELECT username AS name, username AS nickname
                                    FROM [User] WHERE userId = @userId";
                            break;
                    }

                    using (var conn = new SqlConnection(connStr))
                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@userId", userId);
                        conn.Open();
                        using (var reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string nickname = reader["nickname"]?.ToString();
                                string name     = reader["name"]?.ToString();
                                displayName = !string.IsNullOrWhiteSpace(nickname) ? nickname : name;
                            }
                        }
                    }

                    if (string.IsNullOrWhiteSpace(displayName))
                        displayName = Session["username"] as string ?? "User";

                    // Cache in session so next page load is instant
                    Session["_profileName"] = displayName;
                }
                catch (SqlException)
                {
                    displayName = Session["username"] as string ?? "User";
                }
            }

            // Build initials
            string initials = "U";
            if (!string.IsNullOrWhiteSpace(displayName))
            {
                var parts = displayName.Trim().Split(' ');
                initials = parts.Length >= 2
                    ? (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper()
                    : displayName[0].ToString().ToUpper();
            }

            SetUserInfo(displayName, role, initials);
        }

        // ══════════════════════════════════════════════════════════════
        //  PUBLIC HELPERS FOR CHILD PAGES
        // ══════════════════════════════════════════════════════════════

        public void SetUserInfo(string fullName, string role, string initials)
        {
            if (litUserName     != null) litUserName.Text     = HtmlEncode(fullName  ?? "User");
            if (litUserRole     != null) litUserRole.Text     = HtmlEncode(role      ?? string.Empty);
            if (litUserInitials != null) litUserInitials.Text = HtmlEncode((initials ?? "U").ToUpper());
        }

        public void SetUserAvatar(string imageUrl)
        {
            if (imgUserAvatar == null || string.IsNullOrWhiteSpace(imageUrl)) return;
            imgUserAvatar.ImageUrl = imageUrl;
            imgUserAvatar.Visible  = true;
            if (litUserInitials != null) litUserInitials.Visible = false;
        }

        public void ShowNotificationDot()
        {
            if (pnlNotifDot != null) pnlNotifDot.Visible = true;
        }

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
