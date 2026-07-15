using System;
using System.Configuration;
using System.Net;
using System.Net.Mail;
using System.Web.UI;

namespace ScienceBuddy
{
    public partial class Contact : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void BtnSend_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            // Honeypot check
            if (!string.IsNullOrEmpty(txtHoney.Text)) return;

            // Server-side validation
            string name = txtName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string type = ddlType.SelectedValue;
            string subject = txtSubject.Text.Trim();
            string message = txtMessage.Text.Trim();

            if (name.Length < 2 || name.Length > 80) { ShowStatus("Full Name must be 2–80 characters.", false); return; }
            if (subject.Length < 3 || subject.Length > 120) { ShowStatus("Subject must be 3–120 characters.", false); return; }
            if (message.Length < 10 || message.Length > 1500) { ShowStatus("Message must be 10–1500 characters.", false); return; }
            if (string.IsNullOrEmpty(type)) { ShowStatus("Please select an enquiry type.", false); return; }

            // Sanitize for header injection
            subject = subject.Replace("\r", "").Replace("\n", "");
            email = email.Replace("\r", "").Replace("\n", "");

            try
            {
                string smtpHost = ConfigurationManager.AppSettings["SmtpHost"] ?? "smtp.gmail.com";
                int smtpPort = int.Parse(ConfigurationManager.AppSettings["SmtpPort"] ?? "587");
                string smtpUser = ConfigurationManager.AppSettings["SmtpUsername"] ?? "";
                string smtpPass = ConfigurationManager.AppSettings["SmtpPassword"] ?? "";
                bool smtpSsl = bool.Parse(ConfigurationManager.AppSettings["SmtpEnableSsl"] ?? "true");
                string recipient = ConfigurationManager.AppSettings["ContactRecipientEmail"] ?? "tp07734@mail.apu.edu.my";

                if (string.IsNullOrEmpty(smtpUser) || string.IsNullOrEmpty(smtpPass))
                {
                    ShowStatus("Email service is not configured. Please try again later.", false);
                    return;
                }

                string fullSubject = "[ScienceBuddy Contact] " + type + " — " + subject;
                string body = string.Format(
                    "Full Name: {0}\nEmail: {1}\nEnquiry Type: {2}\nSubject: {3}\n\nMessage:\n{4}\n\nSubmitted: {5}",
                    name, email, type, subject, message, DateTime.Now.ToString("dd MMM yyyy HH:mm:ss"));

                using (var mail = new MailMessage())
                {
                    mail.From = new MailAddress(smtpUser, "ScienceBuddy Contact");
                    mail.To.Add(recipient);
                    mail.ReplyToList.Add(new MailAddress(email, name));
                    mail.Subject = fullSubject;
                    mail.Body = body;
                    mail.IsBodyHtml = false;

                    using (var smtp = new SmtpClient(smtpHost, smtpPort))
                    {
                        smtp.Credentials = new NetworkCredential(smtpUser, smtpPass);
                        smtp.EnableSsl = smtpSsl;
                        smtp.Send(mail);
                    }
                }

                // Success
                ShowStatus("Thank you! Your message has been sent to the ScienceBuddy team.", true);
                txtName.Text = ""; txtEmail.Text = ""; ddlType.SelectedIndex = 0; txtSubject.Text = ""; txtMessage.Text = "";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("SMTP ERROR: " + ex.ToString());
                ShowStatus("We could not send your message right now. Please try again later.", false);
            }
        }

        private void ShowStatus(string msg, bool success)
        {
            pnlStatus.Visible = true;
            divStatus.InnerText = msg;
            divStatus.Attributes["class"] = success ? "contact-status contact-status--success" : "contact-status contact-status--error";
        }
    }
}
