namespace ScienceBuddy
{
    public partial class StudentRegistration
    {
        protected global::System.Web.UI.WebControls.Panel pnlForm;
        protected global::System.Web.UI.WebControls.Panel pnlError;
        protected global::System.Web.UI.WebControls.Literal litError;
        protected global::System.Web.UI.WebControls.ValidationSummary vs;
        protected global::System.Web.UI.WebControls.TextBox txtName;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvName;
        protected global::System.Web.UI.WebControls.TextBox txtNickname;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvNick;
        protected global::System.Web.UI.WebControls.TextBox txtUsername;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvUser;
        protected global::System.Web.UI.WebControls.TextBox txtEmail;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvEmail;
        protected global::System.Web.UI.WebControls.RegularExpressionValidator revEmail;
        protected global::System.Web.UI.WebControls.TextBox txtPhone;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvPhone;
        protected global::System.Web.UI.WebControls.TextBox txtPassword;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvPass;
        protected global::System.Web.UI.WebControls.TextBox txtConfirm;
        protected global::System.Web.UI.WebControls.CompareValidator cvPass;
        protected global::System.Web.UI.WebControls.DropDownList ddlLanguage;
        protected global::System.Web.UI.WebControls.Button btnRegister;
        protected global::System.Web.UI.WebControls.Panel pnlSuccess;
    }
}
