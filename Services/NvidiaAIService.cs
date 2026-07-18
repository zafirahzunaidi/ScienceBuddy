using System;
using System.Configuration;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace ScienceBuddy.Services
{
    // ═══════════════════════════════════════════════════════════════════
    // NVIDIA AI Service - Reusable Educational Content Analysis
    // ═══════════════════════════════════════════════════════════════════
    // This service connects to the NVIDIA API (LLM) for AI-assisted
    // content review. It can analyse materials, questions, quizzes,
    // and teacher certificates.
    //
    // Configuration (Web.config / AppSettingsSecrets.config):
    //   NvidiaApiKey      - API authentication key
    //   NvidiaModel       - Model identifier (e.g. meta/llama-3.1-8b-instruct)
    //   NvidiaApiEndpoint - API endpoint URL
    // ═══════════════════════════════════════════════════════════════════

    public class NvidiaAIService
    {
        private static readonly HttpClient _httpClient;

        static NvidiaAIService()
        {
            // NVIDIA API requires TLS 1.2+
            System.Net.ServicePointManager.SecurityProtocol = System.Net.SecurityProtocolType.Tls12 | System.Net.SecurityProtocolType.Tls13;
            _httpClient = new HttpClient();
            _httpClient.Timeout = TimeSpan.FromSeconds(60);
        }

        private readonly string _apiKey;
        private readonly string _model;
        private readonly string _endpoint;

        // --- Constructor ---
        public NvidiaAIService()
        {
            _apiKey = ConfigurationManager.AppSettings["NvidiaApiKey"] ?? "";
            _model = ConfigurationManager.AppSettings["NvidiaModel"] ?? "meta/llama-3.1-8b-instruct";
            _endpoint = ConfigurationManager.AppSettings["NvidiaApiEndpoint"]
                ?? "https://integrate.api.nvidia.com/v1/chat/completions";

            if (string.IsNullOrWhiteSpace(_apiKey))
                throw new InvalidOperationException("NvidiaApiKey is not configured in AppSettings.");
        }

        // --- Public Methods ---

        /// <summary>
        /// Analyses educational content using the NVIDIA LLM.
        /// Returns the AI's assessment as structured text.
        /// </summary>
        /// <param name="content">The plain text content to analyse.</param>
        /// <param name="systemPrompt">Instructions for the AI (e.g. "Review this quiz for accuracy").</param>
        /// <param name="maxTokens">Maximum response tokens (default 1024).</param>
        public async Task<AIAnalysisResult> AnalyzeEducationalContentAsync(
            string content,
            string systemPrompt = "You are an educational content reviewer. Analyse the following content for accuracy, clarity, and age-appropriateness for primary school students.",
            int maxTokens = 1024)
        {
            if (string.IsNullOrWhiteSpace(content))
                return AIAnalysisResult.Failed("Content is empty.");

            try
            {
                var request = new NvidiaRequest
                {
                    Model = _model,
                    MaxTokens = maxTokens,
                    Messages = new[]
                    {
                        new NvidiaMessage { Role = "system", Content = systemPrompt },
                        new NvidiaMessage { Role = "user", Content = content }
                    }
                };

                string jsonBody = JsonConvert.SerializeObject(request);
                var httpRequest = new HttpRequestMessage(HttpMethod.Post, _endpoint);
                httpRequest.Headers.Add("Authorization", "Bearer " + _apiKey);
                httpRequest.Content = new StringContent(jsonBody, Encoding.UTF8, "application/json");

                HttpResponseMessage response = await _httpClient.SendAsync(httpRequest);

                if (!response.IsSuccessStatusCode)
                {
                    string errorBody = await response.Content.ReadAsStringAsync();
                    return HandleHttpError(response.StatusCode, errorBody);
                }

                string responseJson = await response.Content.ReadAsStringAsync();
                var nvidiaResponse = JsonConvert.DeserializeObject<NvidiaResponse>(responseJson);

                if (nvidiaResponse?.Choices == null || nvidiaResponse.Choices.Length == 0)
                    return AIAnalysisResult.Failed("AI returned an empty response.");

                string aiText = nvidiaResponse.Choices[0].Message?.Content ?? "";
                return AIAnalysisResult.Success(aiText);
            }
            catch (TaskCanceledException)
            {
                return AIAnalysisResult.Failed("Request timed out. The AI service did not respond in time.");
            }
            catch (HttpRequestException ex)
            {
                return AIAnalysisResult.Failed("Network error: " + ex.Message);
            }
            catch (JsonException ex)
            {
                return AIAnalysisResult.Failed("Failed to parse AI response: " + ex.Message);
            }
            catch (Exception ex)
            {
                return AIAnalysisResult.Failed("Unexpected error: " + ex.Message);
            }
        }

        // --- Private Helpers ---

        private AIAnalysisResult HandleHttpError(System.Net.HttpStatusCode statusCode, string body)
        {
            string truncBody = (body ?? "").Length > 300 ? body.Substring(0, 300) : (body ?? "");
            string msg = "HTTP " + (int)statusCode + " from " + _endpoint + " (model: " + _model + "): " + truncBody;

            switch ((int)statusCode)
            {
                case 401: return AIAnalysisResult.Failed("HTTP 401 - Invalid API Key. Endpoint: " + _endpoint);
                case 404: return AIAnalysisResult.Failed("HTTP 404 - Model or endpoint not found. Model: " + _model + ", Endpoint: " + _endpoint);
                case 429: return AIAnalysisResult.Failed("HTTP 429 - Rate limit exceeded. Try again later.");
                case 500:
                case 502:
                case 503: return AIAnalysisResult.Failed("HTTP " + (int)statusCode + " - NVIDIA service unavailable. Body: " + truncBody);
                default: return AIAnalysisResult.Failed(msg);
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    // Request/Response Models
    // ═══════════════════════════════════════════════════════════════════

    public class NvidiaRequest
    {
        [JsonProperty("model")]
        public string Model { get; set; }

        [JsonProperty("max_tokens")]
        public int MaxTokens { get; set; }

        [JsonProperty("messages")]
        public NvidiaMessage[] Messages { get; set; }
    }

    public class NvidiaMessage
    {
        [JsonProperty("role")]
        public string Role { get; set; }

        [JsonProperty("content")]
        public string Content { get; set; }
    }

    public class NvidiaResponse
    {
        [JsonProperty("choices")]
        public NvidiaChoice[] Choices { get; set; }
    }

    public class NvidiaChoice
    {
        [JsonProperty("message")]
        public NvidiaMessage Message { get; set; }
    }

    // ═══════════════════════════════════════════════════════════════════
    // Analysis Result
    // ═══════════════════════════════════════════════════════════════════

    public class AIAnalysisResult
    {
        public bool IsSuccess { get; set; }
        public string Response { get; set; }
        public string ErrorMessage { get; set; }

        public static AIAnalysisResult Success(string response)
        {
            return new AIAnalysisResult { IsSuccess = true, Response = response, ErrorMessage = null };
        }

        public static AIAnalysisResult Failed(string error)
        {
            return new AIAnalysisResult { IsSuccess = false, Response = null, ErrorMessage = error };
        }
    }
}
