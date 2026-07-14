using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Web.Script.Serialization;

namespace ScienceBuddy.Services
{
    public class LearningAnalysisData
    {
        public string ResultId { get; set; }
        public string GeneratedAt { get; set; }
        public string Confidence { get; set; }

        public decimal AverageQuizScore { get; set; }
        public decimal RecentQuizAverage { get; set; }
        public int TotalQuizAttempts { get; set; }

        public string StrongTopics { get; set; }
        public string WeakTopics { get; set; }

        public string RecommendedLessonId { get; set; }
        public string RecommendedLessonTitle { get; set; }
        public string RecommendedQuizDifficulty { get; set; }
        public string RecommendedLabId { get; set; }
        public string RecommendedLabTitle { get; set; }

        public string OverallSummary { get; set; }
        public string StudentAdvice { get; set; }
        public string ParentGuidance { get; set; }
        public string LessonReason { get; set; }
        public string QuizReason { get; set; }
        public string LabReason { get; set; }
        public List<string> StudyTips { get; set; }

        public string PersonalityName { get; set; }
        public string PersonalityInsight { get; set; }

        public decimal CurrentQuizScore { get; set; }
        public decimal PreviousRecentAverage { get; set; }
        public decimal ScoreChange { get; set; }
        public string PerformanceTrend { get; set; }

        public string ProgressHeadline { get; set; }
        public string CelebrationMessage { get; set; }

        public string NextMissionTitle { get; set; }
        public List<string> NextMissionSteps { get; set; }


        public LearningAnalysisData()
        {
            StudyTips = new List<string>();
            NextMissionSteps = new List<string>();
        }
    }

    public class StudentLearningAnalysisService
    {
        private readonly string _connectionString;

        public StudentLearningAnalysisService(string connectionString)
        {
            _connectionString = connectionString;
        }

        public void GenerateAndSaveAnalysis(
            string studentId,
            string resultId,
            string language)
        {
            if (string.IsNullOrWhiteSpace(studentId) ||
                string.IsNullOrWhiteSpace(resultId))
            {
                return;
            }

            LearningSnapshot snapshot = BuildSnapshot(studentId, resultId, language);

            if (snapshot.TotalQuizAttempts == 0)
            {
                return;
            }

            AIText aiText;

            try
            {
                aiText = GenerateAIText(snapshot);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(
                    "AI report fallback used: " + ex.Message);

                aiText = CreateFallbackText(snapshot);
            }

            LearningAnalysisData finalAnalysis =
                BuildFinalAnalysis(snapshot, aiText);

            SaveAnalysis(studentId, finalAnalysis);
        }

        private LearningSnapshot BuildSnapshot(
            string studentId,
            string resultId,
            string language)
        {
            LearningSnapshot snapshot = new LearningSnapshot();

            snapshot.StudentId = studentId;
            snapshot.ResultId = resultId;
            snapshot.Language = language == "BM" ? "BM" : "EN";

            using (SqlConnection connection =
                new SqlConnection(_connectionString))
            {
                connection.Open();

                LoadStudentDetails(connection, snapshot);
                LoadQuizSummary(connection, snapshot);
                LoadPerformanceTrend(connection, snapshot);
                LoadTopicPerformance(connection, snapshot);
                LoadRecommendedLesson(connection, snapshot);
                LoadRecommendedLab(connection, snapshot);
            }

            snapshot.RecommendedQuizDifficulty =
                GetRecommendedDifficulty(
                    snapshot.RecentQuizAverage);

            if (snapshot.TotalQuizAttempts <= 1)
            {
                snapshot.Confidence = "Early";
            }
            else if (snapshot.TotalQuizAttempts <= 3)
            {
                snapshot.Confidence = "Developing";
            }
            else
            {
                snapshot.Confidence = "Established";
            }

            return snapshot;
        }

        private void LoadStudentDetails(SqlConnection connection, LearningSnapshot snapshot)
        {
            const string sql = @"
            SELECT
                s.currentLevelId,
                s.personalityId,

                p.personalityNameEN,
                p.personalityNameBM,

                p.descriptionEN,
                p.descriptionBM,

                p.learningStyleEN,
                p.learningStyleBM,

                l.levelNameEN,
                l.levelNameBM

            FROM Student s

            LEFT JOIN Personality p
                ON p.personalityId = s.personalityId

            LEFT JOIN Level l
                ON l.levelId = s.currentLevelId

            WHERE s.studentId = @studentId";

            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue(
                    "@studentId",
                    snapshot.StudentId);

                using (SqlDataReader reader =
                    command.ExecuteReader())
                {
                    if (!reader.Read())
                    {
                        throw new Exception(
                            "Student profile was not found.");
                    }

                    snapshot.CurrentLevelId = ReadString(reader, "currentLevelId");
                    snapshot.PersonalityId = ReadString(reader, "personalityId");

                    snapshot.PersonalityName =
                        ChooseLanguage(
                            ReadString(
                                reader,
                                "personalityNameEN"),
                            ReadString(
                                reader,
                                "personalityNameBM"),
                            snapshot.Language);

                    snapshot.LearningStyle =
                        ChooseLanguage(
                            ReadString(
                                reader,
                                "learningStyleEN"),
                            ReadString(
                                reader,
                                "learningStyleBM"),
                            snapshot.Language);

                    snapshot.LevelName =
                        ChooseLanguage(
                            ReadString(reader, "levelNameEN"),
                            ReadString(reader, "levelNameBM"),
                            snapshot.Language);

                    snapshot.PersonalityDescription =
                        ChooseLanguage(
                            ReadString(reader, "descriptionEN"),
                            ReadString(reader, "descriptionBM"),
                            snapshot.Language
    );

                    snapshot.PersonalityApproach =
                        GetPersonalityApproach(
                            snapshot.PersonalityId,
                            snapshot.Language
                        );
                }
            }
        }

        private void LoadQuizSummary(
            SqlConnection connection,
            LearningSnapshot snapshot)
        {
            const string summarySql = @"
                SELECT
                    ISNULL(
                        AVG(
                            CAST(
                                percentage AS decimal(10,2)
                            )
                        ),
                        0
                    ) AS averageScore,
                    COUNT(*) AS totalAttempts
                FROM QuizResult
                WHERE studentId = @studentId";

            using (SqlCommand command =
                new SqlCommand(summarySql, connection))
            {
                command.Parameters.AddWithValue(
                    "@studentId",
                    snapshot.StudentId);

                using (SqlDataReader reader =
                    command.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        snapshot.AverageQuizScore =
                            Convert.ToDecimal(
                                reader["averageScore"]);

                        snapshot.TotalQuizAttempts =
                            Convert.ToInt32(
                                reader["totalAttempts"]);
                    }
                }
            }

            const string recentSql = @"
                SELECT ISNULL(
                    AVG(
                        CAST(
                            recent.percentage
                            AS decimal(10,2)
                        )
                    ),
                    0
                )
                FROM
                (
                    SELECT TOP 3 percentage
                    FROM QuizResult
                    WHERE studentId = @studentId
                    ORDER BY attemptedDate DESC,
                             resultId DESC
                ) recent";

            using (SqlCommand command =
                new SqlCommand(recentSql, connection))
            {
                command.Parameters.AddWithValue(
                    "@studentId",
                    snapshot.StudentId);

                object result = command.ExecuteScalar();

                if (result != null && result != DBNull.Value)
                {
                    snapshot.RecentQuizAverage =
                        Convert.ToDecimal(result);
                }
            }
        }

        private string GetPersonalityApproach(string personalityId, string language)
        {
            bool isBM = language == "BM";

            switch (personalityId)
            {
                case "P001": // Achiever
                    return isBM
                        ? "Gunakan sasaran skor, kemajuan, XP, lencana dan matlamat yang jelas."
                        : "Use score targets, progress, XP, badges and clear achievement goals.";

                case "P002": // Creative
                    return isBM
                        ? "Gunakan gambar rajah, warna, contoh visual, imaginasi dan aktiviti makmal interaktif."
                        : "Use diagrams, colours, visual examples, imagination and interactive lab activities.";

                case "P003": // Thinker
                    return isBM
                        ? "Terangkan sebab jawapan salah, hubungan antara konsep dan langkah pemikiran."
                        : "Explain why answers were incorrect, how concepts connect and the reasoning steps.";

                case "P004": // Go-Getter
                    return isBM
                        ? "Gunakan cabaran, sasaran skor baharu, soalan lebih sukar dan kemajuan pantas."
                        : "Use challenges, new score targets, harder questions and visible improvement.";

                case "P005": // Chill Learner
                    return isBM
                        ? "Gunakan langkah kecil, sesi pendek, bahasa yang tenang dan beban belajar yang terkawal."
                        : "Use small steps, short sessions, calm wording and a manageable learning load.";

                case "P006": // Socializer
                    return isBM
                        ? "Gunakan perbincangan, pembelajaran bersama rakan, forum dan penerangan kepada orang lain."
                        : "Use discussion, peer learning, forums and explaining concepts to other people.";

                default:
                    return isBM
                        ? "Gunakan langkah pembelajaran yang jelas dan praktikal."
                        : "Use clear and practical learning steps.";
            }
        }

        private void LoadTopicPerformance(
            SqlConnection connection,
            LearningSnapshot snapshot)
        {
            const string sql = @"
                SELECT
                    st.subtopicId,
                    st.subtopicTitleEN,
                    st.subtopicTitleBM,
                    u.unitId,
                    COUNT(*) AS answeredQuestions,
                    SUM(
                        CASE
                            WHEN qa.isCorrect = 1 THEN 1
                            ELSE 0
                        END
                    ) AS correctAnswers,
                    CAST(
                        100.0 * SUM(
                            CASE
                                WHEN qa.isCorrect = 1 THEN 1
                                ELSE 0
                            END
                        ) / NULLIF(COUNT(*), 0)
                        AS decimal(5,2)
                    ) AS topicAccuracy
                FROM QuizAnswer qa
                INNER JOIN QuizResult qr
                    ON qr.resultId = qa.resultId
                INNER JOIN Question q
                    ON q.questionId = qa.questionId
                INNER JOIN Subtopic st
                    ON st.subtopicId = q.subtopicId
                INNER JOIN Unit u
                    ON u.unitId = st.unitId
                WHERE qr.studentId = @studentId
                GROUP BY
                    st.subtopicId,
                    st.subtopicTitleEN,
                    st.subtopicTitleBM,
                    u.unitId";

            List<TopicScore> topicScores =
                new List<TopicScore>();

            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue(
                    "@studentId",
                    snapshot.StudentId);

                using (SqlDataReader reader =
                    command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        TopicScore topic =
                            new TopicScore();

                        topic.SubtopicId =
                            ReadString(reader, "subtopicId");

                        topic.UnitId =
                            ReadString(reader, "unitId");

                        topic.TopicName =
                            ChooseLanguage(
                                ReadString(
                                    reader,
                                    "subtopicTitleEN"),
                                ReadString(
                                    reader,
                                    "subtopicTitleBM"),
                                snapshot.Language);

                        topic.AnsweredQuestions =
                            Convert.ToInt32(
                                reader["answeredQuestions"]);

                        topic.Accuracy =
                            Convert.ToDecimal(
                                reader["topicAccuracy"]);

                        topicScores.Add(topic);
                    }
                }
            }

            List<TopicScore> strongTopics =
                topicScores
                    .Where(topic => topic.AnsweredQuestions >= 2 && topic.Accuracy >= 80m)
                    .OrderByDescending(
                        topic => topic.Accuracy)
                    .Take(3)
                    .ToList();

            List<TopicScore> weakTopics =
                topicScores
                    .Where(topic => topic.AnsweredQuestions >= 2 && topic.Accuracy < 60m)
                    .OrderBy(topic => topic.Accuracy)
                    .Take(3)
                    .ToList();

            snapshot.StrongTopics = string.Join(
                ", ",
                strongTopics
                    .Select(topic => topic.TopicName)
                    .ToArray());

            snapshot.WeakTopics = string.Join(
                ", ",
                weakTopics
                    .Select(topic => topic.TopicName)
                    .ToArray());

            TopicScore priorityTopic =
                topicScores
                    .OrderBy(topic => topic.Accuracy)
                    .FirstOrDefault();

            TopicScore strongestTopic = topicScores
                .Where(topic => topic.AnsweredQuestions >= 2)
                .OrderByDescending(topic => topic.Accuracy)
                .FirstOrDefault();

            if (strongestTopic != null)
            {
                snapshot.StrongestTopic =
                    strongestTopic.TopicName;

                snapshot.StrongestTopicAccuracy =
                    strongestTopic.Accuracy;
            }

            TopicScore focusTopic =
                topicScores
                    .Where(topic => topic.AnsweredQuestions >= 2)
                    .OrderBy(topic => topic.Accuracy)
                    .FirstOrDefault();

            if (focusTopic != null)
            {
                snapshot.FocusTopic =
                    focusTopic.TopicName;

                snapshot.FocusTopicAccuracy =
                    focusTopic.Accuracy;
            }

            if (priorityTopic != null)
            {
                snapshot.PrioritySubtopicId =
                    priorityTopic.SubtopicId;

                snapshot.PriorityUnitId =
                    priorityTopic.UnitId;
            }
        }

        private void LoadRecommendedLesson(
            SqlConnection connection,
            LearningSnapshot snapshot)
        {
            if (string.IsNullOrWhiteSpace(
                snapshot.CurrentLevelId))
            {
                return;
            }

            const string sql = @"
                SELECT TOP 1
                    l.lessonId,
                    l.lessonTitleEN,
                    l.lessonTitleBM,
                    u.unitId
                FROM Lesson l
                INNER JOIN Subtopic st
                    ON st.subtopicId = l.subtopicId
                INNER JOIN Unit u
                    ON u.unitId = st.unitId
                LEFT JOIN LessonProgress lp
                    ON lp.lessonId = l.lessonId
                    AND lp.studentId = @studentId
                WHERE u.levelId = @levelId
                AND (
                    lp.progressId IS NULL
                    OR lp.isCompleted = 0
                )
                ORDER BY
                    CASE
                        WHEN st.subtopicId =
                             @prioritySubtopicId
                        THEN 0
                        ELSE 1
                    END,
                    u.orderNo,
                    st.orderNo,
                    l.orderNo,
                    l.lessonId";

            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue(
                    "@studentId",
                    snapshot.StudentId);

                command.Parameters.AddWithValue(
                    "@levelId",
                    snapshot.CurrentLevelId);

                command.Parameters.AddWithValue(
                    "@prioritySubtopicId",
                    string.IsNullOrWhiteSpace(
                        snapshot.PrioritySubtopicId)
                        ? (object)DBNull.Value
                        : snapshot.PrioritySubtopicId);

                using (SqlDataReader reader =
                    command.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        snapshot.RecommendedLessonId =
                            ReadString(reader, "lessonId");

                        snapshot.RecommendedLessonTitle =
                            ChooseLanguage(
                                ReadString(
                                    reader,
                                    "lessonTitleEN"),
                                ReadString(
                                    reader,
                                    "lessonTitleBM"),
                                snapshot.Language);

                        if (string.IsNullOrWhiteSpace(
                            snapshot.PriorityUnitId))
                        {
                            snapshot.PriorityUnitId =
                                ReadString(reader, "unitId");
                        }
                    }
                }
            }
        }

        private void LoadRecommendedLab(
            SqlConnection connection,
            LearningSnapshot snapshot)
        {
            if (string.IsNullOrWhiteSpace(
                snapshot.PriorityUnitId))
            {
                return;
            }

            const string sql = @"
                SELECT TOP 1
                    vl.labId,
                    vl.labTitleEN,
                    vl.labTitleBM
                FROM VirtualLab vl
                WHERE vl.unitId = @unitId
                AND NOT EXISTS
                (
                    SELECT 1
                    FROM LabProgress lp
                    WHERE lp.studentId = @studentId
                    AND lp.labId = vl.labId
                    AND lp.isCompleted = 1
                )
                ORDER BY vl.createdAt,
                         vl.labId";

            using (SqlCommand command =
                new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue(
                    "@unitId",
                    snapshot.PriorityUnitId);

                command.Parameters.AddWithValue(
                    "@studentId",
                    snapshot.StudentId);

                using (SqlDataReader reader =
                    command.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        snapshot.RecommendedLabId =
                            ReadString(reader, "labId");

                        snapshot.RecommendedLabTitle =
                            ChooseLanguage(
                                ReadString(
                                    reader,
                                    "labTitleEN"),
                                ReadString(
                                    reader,
                                    "labTitleBM"),
                                snapshot.Language);
                    }
                }
            }
        }

        private void LoadPerformanceTrend(
            SqlConnection connection,
            LearningSnapshot snapshot)
        {
            const string currentSql = @"
                SELECT percentage
                FROM QuizResult
                WHERE studentId = @studentId
                AND resultId = @resultId";

            using (SqlCommand command =
                new SqlCommand(currentSql, connection))
            {
                command.Parameters.AddWithValue(
                    "@studentId",
                    snapshot.StudentId);

                command.Parameters.AddWithValue(
                    "@resultId",
                    snapshot.ResultId);

                object result = command.ExecuteScalar();

                if (result != null && result != DBNull.Value)
                {
                    snapshot.CurrentQuizScore =
                        Convert.ToDecimal(result);
                }
            }

            const string previousSql = @"
                SELECT ISNULL(
                    AVG(
                        CAST(previous.percentage AS decimal(10,2))
                    ),
                    0
                )
                FROM
                (
                    SELECT TOP 3 percentage
                    FROM QuizResult
                    WHERE studentId = @studentId
                    AND resultId <> @resultId
                    ORDER BY attemptedDate DESC,
                             resultId DESC
                ) previous";

            using (SqlCommand command =
                new SqlCommand(previousSql, connection))
            {
                command.Parameters.AddWithValue(
                    "@studentId",
                    snapshot.StudentId);

                command.Parameters.AddWithValue(
                    "@resultId",
                    snapshot.ResultId);

                object result = command.ExecuteScalar();

                if (result != null && result != DBNull.Value)
                {
                    snapshot.PreviousRecentAverage =
                        Convert.ToDecimal(result);
                }
            }

            if (snapshot.TotalQuizAttempts <= 1)
            {
                snapshot.ScoreChange = 0;
                snapshot.PerformanceTrend = "First Attempt";
                return;
            }

            snapshot.ScoreChange =
                Math.Round(
                    snapshot.CurrentQuizScore -
                    snapshot.PreviousRecentAverage,
                    2
                );

            if (snapshot.ScoreChange >= 5)
            {
                snapshot.PerformanceTrend = "Improving";
            }
            else if (snapshot.ScoreChange <= -5)
            {
                snapshot.PerformanceTrend = "Needs Support";
            }
            else
            {
                snapshot.PerformanceTrend = "Stable";
            }
        }

        private string GetRecommendedDifficulty(
            decimal recentAverage)
        {
            if (recentAverage >= 85m)
            {
                return "Hard";
            }

            if (recentAverage >= 60m)
            {
                return "Medium";
            }

            return "Easy";
        }

        private AIText GenerateAIText(
            LearningSnapshot snapshot)
        {
            string apiKey =
                ConfigurationManager.AppSettings[
                    "NvidiaApiKey"];

            string model =
                ConfigurationManager.AppSettings[
                    "NvidiaModel"];

            string endpoint =
                ConfigurationManager.AppSettings[
                    "NvidiaApiEndpoint"];

            if (string.IsNullOrWhiteSpace(model))
            {
                model =
                    "meta/llama-3.1-8b-instruct";
            }

            if (string.IsNullOrWhiteSpace(endpoint))
            {
                endpoint =
                    "https://integrate.api.nvidia.com/" +
                    "v1/chat/completions";
            }

            if (string.IsNullOrWhiteSpace(apiKey) ||
                apiKey == "YOUR_NVIDIA_API_KEY_HERE")
            {
                throw new Exception(
                    "The NVIDIA API key is missing.");
            }

            JavaScriptSerializer serializer =
                new JavaScriptSerializer();

            object learningData = new
            {
                Language = snapshot.Language,

                Level = snapshot.LevelName,

                Personality = snapshot.PersonalityName,
                PersonalityDescription = snapshot.PersonalityDescription,
                LearningStyle = snapshot.LearningStyle,
                PersonalityApproach = snapshot.PersonalityApproach,

                CurrentQuizScore = snapshot.CurrentQuizScore,
                PreviousRecentAverage = snapshot.PreviousRecentAverage,
                ScoreChange = snapshot.ScoreChange,
                PerformanceTrend = snapshot.PerformanceTrend,

                AverageQuizScore = snapshot.AverageQuizScore,
                RecentQuizAverage = snapshot.RecentQuizAverage,
                TotalQuizAttempts = snapshot.TotalQuizAttempts,
                Confidence = snapshot.Confidence,

                StrongestTopic = snapshot.StrongestTopic,
                StrongestTopicAccuracy = snapshot.StrongestTopicAccuracy,

                FocusTopic = snapshot.FocusTopic,
                FocusTopicAccuracy = snapshot.FocusTopicAccuracy,

                StrongTopics = snapshot.StrongTopics,
                WeakTopics = snapshot.WeakTopics,

                RecommendedLesson = snapshot.RecommendedLessonTitle,

                RecommendedQuizDifficulty = snapshot.RecommendedQuizDifficulty,

                RecommendedVirtualLab = snapshot.RecommendedLabTitle
            };

            string systemPrompt = @"
                You are ScienceBuddy's adaptive AI learning coach
                for primary Science students.

                Use only the verified learning data supplied by the
                system. Never invent scores, topics, lessons,
                laboratories, quiz results or student behaviour.

                Your response must clearly demonstrate personalisation.

                PERSONALISATION RULES

                1. Compare the student's newest quiz score with the
                   previous recent average.

                2. Mention the performance trend:
                   Improving, Stable, Needs Support or First Attempt.

                3. Explain one strength using the strongest topic and
                   its accuracy when available.

                4. Explain one focus area using the focus topic and its
                   accuracy when available.

                5. Adapt the learning strategy to the student's exact
                   personality, learning style and supplied personality
                   approach.

                6. Do not only say that the student has a personality.
                   Explain WHY the recommended learning method fits
                   that personality.

                7. The three mission steps must be specific to the
                   student's actual topic, lesson, quiz difficulty or
                   virtual lab.

                8. Avoid generic advice such as:
                   'study harder',
                   'keep practising',
                   'do your best',
                   unless followed by a specific action.

                9. Do not diagnose emotions, behaviour, disabilities,
                   medical conditions or mental health.

                Return valid JSON only.
                Do not include Markdown or code fences.

                Use exactly these properties:

                ProgressHeadline
                CelebrationMessage
                PersonalityInsight
                OverallSummary
                StudentAdvice
                ParentGuidance
                LessonReason
                QuizReason
                LabReason
                NextMissionTitle
                NextMissionSteps
                StudyTips

                ProgressHeadline must contain no more than 10 words.

                CelebrationMessage must recognise a real improvement,
                strength or completed attempt.

                PersonalityInsight must explain why the learning plan
                fits this specific personality.

                NextMissionSteps must contain exactly three short,
                actionable steps.

                StudyTips must contain exactly three tips that differ
                from NextMissionSteps.

                IMPORTANT WORDING RULES:
                - Write for children aged 7-12. Use simple short words.
                - ProgressHeadline: Maximum 7 words. Exciting and fun. Example: ""Amazing! Your Score Jumped!""
                - CelebrationMessage: Maximum 16 words. One sentence only.
                - PersonalityInsight: Maximum 22 words. One or two short sentences.
                - OverallSummary: Maximum 2 short sentences, 35 words total. Do NOT include mission steps here.
                - StudentAdvice: Maximum 18 words. One clear action.
                - LessonReason, QuizReason, LabReason: Maximum 16 words each.
                - Each NextMissionStep: Maximum 12 words. Start with an action word.
                - StudyTips: Maximum 12 words each.
                - Do NOT repeat PersonalityInsight inside OverallSummary.
                - Do NOT repeat topic names multiple times across properties.
                - Sound cheerful and encouraging, not formal or academic.

                Use the language requested by the system.";

            List<Dictionary<string, string>> messages =
                new List<Dictionary<string, string>>();

            messages.Add(
                new Dictionary<string, string>
                {
                    { "role", "system" },
                    { "content", systemPrompt }
                });

            messages.Add(
                new Dictionary<string, string>
                {
                    { "role", "user" },
                    {
                        "content",
                        serializer.Serialize(learningData)
                    }
                });

            Dictionary<string, object> payload =
                new Dictionary<string, object>();

            payload["model"] = model;
            payload["messages"] = messages;
            payload["temperature"] = 0.2;
            payload["top_p"] = 0.9;
            payload["max_tokens"] = 700;
            payload["stream"] = false;

            string responseBody = SendAIRequest(
                endpoint,
                apiKey,
                serializer.Serialize(payload));

            string aiContent = ReadAIContent(
                responseBody,
                serializer);

            string cleanJson =
                RemoveCodeFences(aiContent);

            AIText aiText =
                serializer.Deserialize<AIText>(cleanJson);

            if (aiText == null ||
                string.IsNullOrWhiteSpace(
                    aiText.OverallSummary))
            {
                throw new Exception(
                    "The AI report JSON was incomplete.");
            }

            AIText fallbackText =
                CreateFallbackText(snapshot);

            if (string.IsNullOrWhiteSpace(
                aiText.StudentAdvice))
            {
                aiText.StudentAdvice =
                    fallbackText.StudentAdvice;
            }

            if (string.IsNullOrWhiteSpace(
                aiText.ParentGuidance))
            {
                aiText.ParentGuidance =
                    fallbackText.ParentGuidance;
            }

            if (string.IsNullOrWhiteSpace(
                aiText.LessonReason))
            {
                aiText.LessonReason =
                    fallbackText.LessonReason;
            }

            if (string.IsNullOrWhiteSpace(
                aiText.QuizReason))
            {
                aiText.QuizReason =
                    fallbackText.QuizReason;
            }

            if (string.IsNullOrWhiteSpace(
                aiText.LabReason))
            {
                aiText.LabReason =
                    fallbackText.LabReason;
            }

            if (aiText.StudyTips == null ||
                aiText.StudyTips.Count != 3)
            {
                aiText.StudyTips =
                    fallbackText.StudyTips;
            }

            if (string.IsNullOrWhiteSpace(
                aiText.ProgressHeadline))
            {
                aiText.ProgressHeadline =
                    fallbackText.ProgressHeadline;
            }

            if (string.IsNullOrWhiteSpace(
                aiText.CelebrationMessage))
            {
                aiText.CelebrationMessage =
                    fallbackText.CelebrationMessage;
            }

            if (string.IsNullOrWhiteSpace(
                aiText.PersonalityInsight))
            {
                aiText.PersonalityInsight =
                    fallbackText.PersonalityInsight;
            }

            if (string.IsNullOrWhiteSpace(
                aiText.NextMissionTitle))
            {
                aiText.NextMissionTitle =
                    fallbackText.NextMissionTitle;
            }

            if (aiText.NextMissionSteps == null ||
                aiText.NextMissionSteps.Count != 3)
            {
                aiText.NextMissionSteps =
                    fallbackText.NextMissionSteps;
            }



            return aiText;
        }

        

        private string SendAIRequest(
            string endpoint,
            string apiKey,
            string jsonPayload)
        {
            byte[] requestBytes =
                Encoding.UTF8.GetBytes(jsonPayload);

            HttpWebRequest request =
                (HttpWebRequest)WebRequest.Create(endpoint);

            request.Method = "POST";
            request.ContentType = "application/json";
            request.Accept = "application/json";
            request.Headers["Authorization"] =
                "Bearer " + apiKey;
            request.Timeout = 20000;
            request.ContentLength =
                requestBytes.Length;

            using (Stream requestStream =
                request.GetRequestStream())
            {
                requestStream.Write(
                    requestBytes,
                    0,
                    requestBytes.Length);
            }

            try
            {
                using (HttpWebResponse response =
                    (HttpWebResponse)
                    request.GetResponse())
                using (StreamReader reader =
                    new StreamReader(
                        response.GetResponseStream(),
                        Encoding.UTF8))
                {
                    return reader.ReadToEnd();
                }
            }
            catch (WebException ex)
            {
                if (ex.Response != null)
                {
                    using (Stream errorStream =
                        ex.Response.GetResponseStream())
                    using (StreamReader reader =
                        new StreamReader(
                            errorStream,
                            Encoding.UTF8))
                    {
                        throw new Exception(
                            "NVIDIA API error: " +
                            reader.ReadToEnd());
                    }
                }

                throw;
            }
        }

        private string ReadAIContent(
            string responseBody,
            JavaScriptSerializer serializer)
        {
            Dictionary<string, object> response =
                serializer.DeserializeObject(responseBody)
                as Dictionary<string, object>;

            if (response == null ||
                !response.ContainsKey("choices"))
            {
                throw new Exception(
                    "The AI response had no choices.");
            }

            object[] choices =
                response["choices"] as object[];

            if (choices == null ||
                choices.Length == 0)
            {
                throw new Exception(
                    "The AI returned no answer.");
            }

            Dictionary<string, object> firstChoice =
                choices[0]
                as Dictionary<string, object>;

            Dictionary<string, object> message =
                firstChoice["message"]
                as Dictionary<string, object>;

            string content =
                Convert.ToString(message["content"]);

            if (string.IsNullOrWhiteSpace(content))
            {
                throw new Exception(
                    "The AI returned an empty answer.");
            }

            return content.Trim();
        }

        private AIText CreateFallbackText(
            LearningSnapshot snapshot)
        {
            AIText text = new AIText();

            if (snapshot.Language == "BM")
            {
                text.OverallSummary =
                    "Analisis ini berdasarkan " +
                    snapshot.TotalQuizAttempts +
                    " percubaan kuiz dengan purata skor " +
                    snapshot.AverageQuizScore
                        .ToString("0.0") +
                    "%.";

                text.StudentAdvice =
                    "Ulang kaji topik yang masih lemah " +
                    "sebelum mencuba kuiz seterusnya.";

                text.ParentGuidance =
                    "Galakkan sesi ulang kaji yang pendek " +
                    "dan konsisten.";

                text.LessonReason =
                    "Pelajaran ini dipilih berdasarkan " +
                    "topik yang paling memerlukan ulang kaji.";

                text.QuizReason =
                    "Tahap kesukaran ini sepadan dengan " +
                    "prestasi kuiz terkini.";

                text.LabReason =
                    "Makmal ini membantu mengukuhkan konsep " +
                    "melalui aktiviti interaktif.";

                text.StudyTips = new List<string>
                {
                    "Semak jawapan kuiz yang salah.",
                    "Selesaikan pelajaran yang dicadangkan.",
                    "Cuba semula kuiz selepas ulang kaji."
                };
            }
            else
            {
                text.OverallSummary =
                    "This analysis is based on " +
                    snapshot.TotalQuizAttempts +
                    " quiz attempt(s), with an average " +
                    "score of " +
                    snapshot.AverageQuizScore
                        .ToString("0.0") +
                    "%.";

                text.StudentAdvice =
                    "Review weaker topics before attempting " +
                    "the next quiz.";

                text.ParentGuidance =
                    "Encourage short and consistent " +
                    "revision sessions.";

                text.LessonReason =
                    "This lesson was selected from the topic " +
                    "that currently needs the most revision.";

                text.QuizReason =
                    "This difficulty matches the student's " +
                    "recent quiz performance.";

                text.LabReason =
                    "This lab reinforces the concept through " +
                    "an interactive activity.";

                text.StudyTips = new List<string>
                {
                    "Review incorrectly answered questions.",
                    "Complete the recommended lesson.",
                    "Retry a quiz after revision."
                };
            }

            return text;
        }

        private LearningAnalysisData BuildFinalAnalysis(
            LearningSnapshot snapshot,
            AIText aiText)
        {
            LearningAnalysisData analysis =
                new LearningAnalysisData();

            analysis.ResultId = snapshot.ResultId;
            analysis.GeneratedAt =
                DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
            analysis.Confidence = snapshot.Confidence;

            analysis.AverageQuizScore =
                snapshot.AverageQuizScore;
            analysis.RecentQuizAverage =
                snapshot.RecentQuizAverage;
            analysis.TotalQuizAttempts =
                snapshot.TotalQuizAttempts;

            analysis.StrongTopics =
                snapshot.StrongTopics;
            analysis.WeakTopics =
                snapshot.WeakTopics;

            analysis.RecommendedLessonId =
                snapshot.RecommendedLessonId;
            analysis.RecommendedLessonTitle =
                snapshot.RecommendedLessonTitle;
            analysis.RecommendedQuizDifficulty =
                snapshot.RecommendedQuizDifficulty;
            analysis.RecommendedLabId =
                snapshot.RecommendedLabId;
            analysis.RecommendedLabTitle =
                snapshot.RecommendedLabTitle;

            analysis.PersonalityName =
                snapshot.PersonalityName;

            analysis.CurrentQuizScore =
                snapshot.CurrentQuizScore;

            analysis.PreviousRecentAverage =
                snapshot.PreviousRecentAverage;

            analysis.ScoreChange =
                snapshot.ScoreChange;

            analysis.PerformanceTrend =
                snapshot.PerformanceTrend;

            analysis.ProgressHeadline =
                aiText.ProgressHeadline;

            analysis.CelebrationMessage =
                aiText.CelebrationMessage;

            analysis.PersonalityInsight =
                aiText.PersonalityInsight;

            analysis.NextMissionTitle =
                aiText.NextMissionTitle;

            analysis.NextMissionSteps =
                aiText.NextMissionSteps;

            analysis.OverallSummary =
                aiText.OverallSummary;
            analysis.StudentAdvice =
                aiText.StudentAdvice;
            analysis.ParentGuidance =
                aiText.ParentGuidance;
            analysis.LessonReason =
                aiText.LessonReason;
            analysis.QuizReason =
                aiText.QuizReason;
            analysis.LabReason =
                aiText.LabReason;
            analysis.StudyTips =
                aiText.StudyTips;



            return analysis;
        }

        private void SaveAnalysis(
            string studentId,
            LearningAnalysisData analysis)
        {
            JavaScriptSerializer serializer =
                new JavaScriptSerializer();

            string analysisJson =
                serializer.Serialize(analysis);

            using (SqlConnection connection =
                new SqlConnection(_connectionString))
            {
                connection.Open();

                using (SqlTransaction transaction =
                    connection.BeginTransaction())
                {
                    try
                    {
                        const string updateSql = @"
                            UPDATE AILearningAnalysis
                            SET isLatest = 0
                            WHERE studentId = @studentId
                            AND isLatest = 1";

                        using (SqlCommand command =
                            new SqlCommand(
                                updateSql,
                                connection,
                                transaction))
                        {
                            command.Parameters.AddWithValue(
                                "@studentId",
                                studentId);

                            command.ExecuteNonQuery();
                        }

                        string analysisId =
                            GetNextAnalysisId(
                                connection,
                                transaction);

                        const string insertSql = @"
                            INSERT INTO AILearningAnalysis
                            (
                                analysisId,
                                studentId,
                                analysisJson,
                                overallSummary,
                                strongTopics,
                                weakTopics,
                                avgQuizScore,
                                totalQuizAttempts,
                                isLatest
                            )
                            VALUES
                            (
                                @analysisId,
                                @studentId,
                                @analysisJson,
                                @overallSummary,
                                @strongTopics,
                                @weakTopics,
                                @averageScore,
                                @totalAttempts,
                                1
                            )";

                        using (SqlCommand command =
                            new SqlCommand(
                                insertSql,
                                connection,
                                transaction))
                        {
                            command.Parameters.AddWithValue(
                                "@analysisId",
                                analysisId);

                            command.Parameters.AddWithValue(
                                "@studentId",
                                studentId);

                            command.Parameters.AddWithValue(
                                "@analysisJson",
                                analysisJson);

                            command.Parameters.AddWithValue(
                                "@overallSummary",
                                Truncate(
                                    analysis.OverallSummary,
                                    500));

                            command.Parameters.AddWithValue(
                                "@strongTopics",
                                DbValue(
                                    Truncate(
                                        analysis.StrongTopics,
                                        500)));

                            command.Parameters.AddWithValue(
                                "@weakTopics",
                                DbValue(
                                    Truncate(
                                        analysis.WeakTopics,
                                        500)));

                            command.Parameters.AddWithValue(
                                "@averageScore",
                                analysis.AverageQuizScore);

                            command.Parameters.AddWithValue(
                                "@totalAttempts",
                                analysis.TotalQuizAttempts);

                            command.ExecuteNonQuery();
                        }

                        transaction.Commit();
                    }
                    catch
                    {
                        transaction.Rollback();
                        throw;
                    }
                }
            }
        }

        private string GetNextAnalysisId(
            SqlConnection connection,
            SqlTransaction transaction)
        {
            const string sql = @"
                SELECT ISNULL(
                    MAX(
                        CAST(
                            SUBSTRING(
                                analysisId,
                                2,
                                LEN(analysisId) - 1
                            ) AS INT
                        )
                    ),
                    0
                )
                FROM AILearningAnalysis
                WHERE analysisId LIKE 'A[0-9]%'";

            using (SqlCommand command =
                new SqlCommand(
                    sql,
                    connection,
                    transaction))
            {
                int lastNumber =
                    Convert.ToInt32(
                        command.ExecuteScalar());

                return "A" +
                    (lastNumber + 1).ToString("D3");
            }
        }

        private static string ChooseLanguage(
            string english,
            string malay,
            string language)
        {
            string selected =
                language == "BM" ? malay : english;

            if (!string.IsNullOrWhiteSpace(selected))
            {
                return selected;
            }

            if (!string.IsNullOrWhiteSpace(english))
            {
                return english;
            }

            return malay;
        }

        private static string ReadString(
            IDataRecord reader,
            string columnName)
        {
            object value = reader[columnName];

            if (value == null ||
                value == DBNull.Value)
            {
                return "";
            }

            return value.ToString();
        }

        private static string RemoveCodeFences(
            string text)
        {
            string cleaned = text.Trim();

            if (cleaned.StartsWith("```"))
            {
                int firstNewLine =
                    cleaned.IndexOf('\n');

                if (firstNewLine >= 0)
                {
                    cleaned =
                        cleaned.Substring(
                            firstNewLine + 1);
                }

                int finalFence =
                    cleaned.LastIndexOf("```");

                if (finalFence >= 0)
                {
                    cleaned =
                        cleaned.Substring(
                            0,
                            finalFence);
                }
            }

            return cleaned.Trim();
        }

        private static object DbValue(string text)
        {
            if (string.IsNullOrWhiteSpace(text))
            {
                return DBNull.Value;
            }

            return text;
        }

        private static string Truncate(
            string text,
            int maximumLength)
        {
            if (string.IsNullOrEmpty(text) ||
                text.Length <= maximumLength)
            {
                return text;
            }

            return text.Substring(0, maximumLength);
        }

        private class LearningSnapshot
        {
            public string StudentId { get; set; }
            public string ResultId { get; set; }
            public string Language { get; set; }
            public string CurrentLevelId { get; set; }
            public string LevelName { get; set; }
            public string PersonalityName { get; set; }
            public string LearningStyle { get; set; }

            public decimal AverageQuizScore { get; set; }
            public decimal RecentQuizAverage { get; set; }
            public int TotalQuizAttempts { get; set; }
            public string Confidence { get; set; }

            public string StrongTopics { get; set; }
            public string WeakTopics { get; set; }

            public string PrioritySubtopicId { get; set; }
            public string PriorityUnitId { get; set; }

            public string RecommendedLessonId { get; set; }
            public string RecommendedLessonTitle { get; set; }
            public string RecommendedQuizDifficulty { get; set; }
            public string RecommendedLabId { get; set; }
            public string RecommendedLabTitle { get; set; }

            public string PersonalityId { get; set; }
            public string PersonalityDescription { get; set; }
            public string PersonalityApproach { get; set; }

            public decimal CurrentQuizScore { get; set; }
            public decimal PreviousRecentAverage { get; set; }
            public decimal ScoreChange { get; set; }
            public string PerformanceTrend { get; set; }

            public string StrongestTopic { get; set; }
            public decimal StrongestTopicAccuracy { get; set; }

            public string FocusTopic { get; set; }
            public decimal FocusTopicAccuracy { get; set; }
        }

        private class TopicScore
        {
            public string SubtopicId { get; set; }
            public string UnitId { get; set; }
            public string TopicName { get; set; }
            public int AnsweredQuestions { get; set; }
            public decimal Accuracy { get; set; }
        }

        public class AIText
        {
            public string OverallSummary { get; set; }
            public string StudentAdvice { get; set; }
            public string ParentGuidance { get; set; }
            public string LessonReason { get; set; }
            public string QuizReason { get; set; }
            public string LabReason { get; set; }
            public List<string> StudyTips { get; set; }

            public string ProgressHeadline { get; set; }
            public string CelebrationMessage { get; set; }
            public string PersonalityInsight { get; set; }
            public string NextMissionTitle { get; set; }
            public List<string> NextMissionSteps { get; set; }

            public AIText()
            {
                StudyTips = new List<string>();
                NextMissionSteps = new List<string>();
            }
        }
    }
}