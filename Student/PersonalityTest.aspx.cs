using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace ScienceBuddy.Student
{
    public partial class PersonalityTest1 : Page
    {
        private string ConnStr
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
            CurrentLanguage = "EN";
            Session["preferredLanguage"] = "EN";
        }

        private void SetLabels()
        {
            litPageTitle.Text = T("Personality Test", "Ujian Personaliti");
            litHeroTitle.Text = T("Set Your Learning Style", "Tetapkan Gaya Pembelajaran Anda");
            litHeroSub.Text = T("Move the sliders and Buddy will personalise your ScienceBuddy dashboard!",
                "Gerakkan peluncur supaya Buddy dapat memperibadikan papan pemuka ScienceBuddy anda!");
            litBubble.Text = T("Hi! I'm Buddy. Let's find the best way for you to learn Science!",
                "Hai! Saya Buddy. Jom cari cara terbaik untuk anda belajar Sains!");
            litPreview.Text = T("Your dashboard will change based on your learning style.",
                "Papan pemuka anda akan berubah berdasarkan gaya pembelajaran anda.");
            litS1.Text = T("Learning Speed", "Kelajuan Pembelajaran");
            litS1L.Text = T("Slow & Steady", "Perlahan & Mantap");
            litS1R.Text = T("Fast & Bold", "Pantas & Berani");
            litS2.Text = T("Learning Focus", "Fokus Pembelajaran");
            litS2L.Text = T("Goals & Rewards", "Matlamat & Ganjaran");
            litS2R.Text = T("Explore & Create", "Terokai & Cipta");
            litS3.Text = T("Thinking Style", "Gaya Berfikir");
            litS3L.Text = T("Quick Answer", "Jawapan Pantas");
            litS3R.Text = T("Deep Explanation", "Penerangan Mendalam");
            litS4.Text = T("Learning Mood", "Suasana Belajar");
            litS4L.Text = T("Calm", "Tenang");
            litS4R.Text = T("Energetic", "Bertenaga");
            litS5.Text = T("Study Preference", "Pilihan Belajar");
            litS5L.Text = T("Learn Alone", "Belajar Sendiri");
            litS5R.Text = T("Learn Together", "Belajar Bersama");
            litS6.Text = T("Activity Style", "Gaya Aktiviti");
            litS6L.Text = T("Read Notes", "Baca Nota");
            litS6R.Text = T("Do Activities", "Buat Aktiviti");
            btnDiscover.Text = T("\u2728 Discover My Personality!", "\u2728 Temui Personaliti Saya!");
            litResultBtn.Text = T("Go to My Dashboard", "Pergi ke Papan Pemuka");
            litRetakeBtn.Text = T("Retake Setup", "Ulang Semula");
            litBtnHint.Text = T("Buddy will personalise your dashboard after this!", "Buddy akan memperibadikan papan pemuka anda selepas ini!");
            litH1.Text = T("How fast do you like to move through lessons?", "Berapa pantas anda suka melalui pelajaran?");
            litH2.Text = T("What makes learning exciting for you?", "Apa yang membuatkan pembelajaran menarik untuk anda?");
            litH3.Text = T("How do you like to understand answers?", "Bagaimana anda suka memahami jawapan?");
            litH4.Text = T("What learning energy feels right?", "Tenaga belajar yang mana sesuai?");
            litH5.Text = T("Do you like learning solo or with others?", "Suka belajar sendiri atau bersama?");
            litH6.Text = T("Do you prefer reading or hands-on?", "Suka membaca atau buat aktiviti?");
            litUnlock.Text = T("Your Learning Style is Unlocked!", "Gaya Pembelajaran Anda Telah Dibuka!");
        }

        protected void btnDiscover_Click(object sender, EventArgs e)
        {
            InitLang();
            int s1 = GetSlider("slider1");
            int s2 = GetSlider("slider2");
            int s3 = GetSlider("slider3");
            int s4 = GetSlider("slider4");
            int s5 = GetSlider("slider5");
            int s6 = GetSlider("slider6");

            int achiever = 0, creative = 0, thinker = 0, gogetter = 0, chill = 0, socializer = 0;

            if (s1 <= 2)
            {
                chill += 2;
            }
            else if (s1 == 3)
            {
                achiever += 1;
            }
            else
            {
                gogetter += 2;
            }

            if (s2 <= 2)
            {
                achiever += 2;
            }
            else if (s2 == 3)
            {
                thinker += 1;
            }
            else
            {
                creative += 2;
            }

            if (s3 <= 2)
            {
                gogetter += 2;
            }
            else if (s3 == 3)
            {
                achiever += 1;
            }
            else
            {
                thinker += 2;
            }

            if (s4 <= 2)
            {
                chill += 2;
            }
            else if (s4 == 3)
            {
                creative += 1;
            }
            else
            {
                gogetter += 2;
            }

            if (s5 <= 2)
            {
                thinker += 2;
            }
            else if (s5 == 3)
            {
                chill += 1;
            }
            else
            {
                socializer += 2;
            }

            if (s6 <= 2)
            {
                thinker += 2;
            }
            else if (s6 == 3)
            {
                achiever += 1;
            }
            else
            {
                creative += 2;
            }

            int max = achiever;
            string pid = "P001";
            string pName = "Achiever";

            if (creative > max)
            {
                max = creative;
                pid = "P002";
                pName = "Creative";
            }
            if (thinker > max)
            {
                max = thinker;
                pid = "P003";
                pName = "Thinker";
            }
            if (gogetter > max)
            {
                max = gogetter;
                pid = "P004";
                pName = "Go-Getter";
            }
            if (chill > max)
            {
                max = chill;
                pid = "P005";
                pName = "Chill Learner";
            }
            if (socializer > max)
            {
                max = socializer;
                pid = "P006";
                pName = "Socializer";
            }

            string userId = Session["userId"].ToString();
            using (SqlConnection connection = new SqlConnection(ConnStr))
            using (SqlCommand command = new SqlCommand("UPDATE Student SET personalityId=@p WHERE userId=@u", connection))
            {
                command.Parameters.AddWithValue("@p", pid);
                command.Parameters.AddWithValue("@u", userId);
                connection.Open();
                command.ExecuteNonQuery();
            }

            pnlQuiz.Visible = false;
            pnlResult.Visible = true;
            ShowResult(pid, pName);
        }

        private void ShowResult(string pid, string pName)
        {
            string avatar = "~/Images/Personality/";
            string desc = "", card1 = "", card2 = "", card3 = "";
            string c1Title = T("Buddy shows first", "Buddy tunjuk dahulu");
            string c2Title = T("Best activity", "Aktiviti terbaik");
            string c3Title = T("Learn better", "Belajar lebih baik");

            switch (pid)
            {
                case "P001":
                    avatar += "achiever.png";
                    pName = "Achiever";
                    desc = T("You love goals, progress, rewards, and completing learning missions!",
                        "Anda suka matlamat, kemajuan, ganjaran, dan menyelesaikan misi pembelajaran!");
                    card1 = T("XP, badges, progress", "XP, lencana, kemajuan");
                    card2 = T("Unit goals & certificates", "Matlamat unit & sijil");
                    card3 = T("Complete missions one by one", "Selesaikan misi satu demi satu");
                    break;
                case "P002":
                    avatar += "creative.png";
                    pName = "Creative";
                    desc = T("You enjoy colourful, visual, and interactive learning!",
                        "Anda menikmati pembelajaran berwarna, visual, dan interaktif!");
                    card1 = T("Videos, virtual labs, flashcards", "Video, makmal maya, kad imbas");
                    card2 = T("Visual & interactive activities", "Aktiviti visual & interaktif");
                    card3 = T("Use colours, diagrams & experiments", "Guna warna, rajah & eksperimen");
                    break;
                case "P003":
                    avatar += "thinker.png";
                    pName = "Thinker";
                    desc = T("You like understanding the reason behind every answer!",
                        "Anda suka memahami sebab di sebalik setiap jawapan!");
                    card1 = T("Explanations, quiz feedback", "Penerangan, maklum balas kuiz");
                    card2 = T("Review answers & notes", "Semak jawapan & nota");
                    card3 = T("Understand the reason behind each answer", "Fahami sebab setiap jawapan");
                    break;
                case "P004":
                    avatar += "gogetter.png";
                    pName = "Go-Getter";
                    desc = T("You enjoy challenges and fast progress!",
                        "Anda menikmati cabaran dan kemajuan pantas!");
                    card1 = T("Quizzes, challenges, leaderboard", "Kuiz, cabaran, papan kedudukan");
                    card2 = T("Timed quiz & level missions", "Kuiz masa & misi tahap");
                    card3 = T("Challenge yourself and retry", "Cabar diri anda dan cuba lagi");
                    break;
                case "P005":
                    avatar += "chill-learner.png";
                    pName = "Chill Learner";
                    desc = T("You prefer calm, step-by-step learning at your own pace!",
                        "Anda suka pembelajaran tenang langkah demi langkah mengikut rentak sendiri!");
                    card1 = T("Continue learning, gentle reminders", "Teruskan belajar, peringatan lembut");
                    card2 = T("Step-by-step lessons", "Pelajaran langkah demi langkah");
                    card3 = T("Learn calmly at your own pace", "Belajar dengan tenang mengikut rentak anda");
                    break;
                case "P006":
                    avatar += "socializer.png";
                    pName = "Socializer";
                    desc = T("You enjoy learning with others and sharing knowledge!",
                        "Anda menikmati belajar bersama orang lain dan berkongsi ilmu!");
                    card1 = T("Forum, messages, live sessions", "Forum, mesej, sesi langsung");
                    card2 = T("Discussion & teacher support", "Perbincangan & sokongan guru");
                    card3 = T("Ask questions & learn together", "Tanya soalan & belajar bersama");
                    break;
            }
            imgResult.ImageUrl = ResolveUrl(avatar);
            litResultName.Text = HttpUtility.HtmlEncode(pName);
            litResultDesc.Text = desc;
            litCard1Title.Text = c1Title;
            litCard1Val.Text = card1;
            litCard2Title.Text = c2Title;
            litCard2Val.Text = card2;
            litCard3Title.Text = c3Title;
            litCard3Val.Text = card3;
        }

        private int GetSlider(string name)
        {
            string val = Request.Form[name];
            int v;
            if (int.TryParse(val, out v))
            {
                return Math.Max(1, Math.Min(5, v));
            }
            return 3;
        }
    }
}
