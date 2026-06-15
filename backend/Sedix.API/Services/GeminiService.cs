using System.Text;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Sedix.API.Data;
using Sedix.API.DTOs;

namespace Sedix.API.Services;

public interface IGeminiService
{
    Task<AiAdviceResponse> GetAdviceAsync(Guid userId, AiAdviceRequest req);
}

public class GeminiService(IConfiguration config, AppDbContext db) : IGeminiService
{
    // Static HttpClient — avoids per-request socket exhaustion and DI scope issues
    private static readonly HttpClient Http = new();

    private static readonly string[] DefaultSuggestions =
    [
        "How can I reach my goal faster?",
        "What's a good weekly savings amount?",
        "How do I stay motivated to save?",
        "What should I prioritize if I have multiple goals?",
    ];

    public async Task<AiAdviceResponse> GetAdviceAsync(Guid userId, AiAdviceRequest req)
    {
        var goals = await db.Goals
            .Where(g => g.UserId == userId)
            .Include(g => g.Transactions)
            .ToListAsync();

        var goalContext = goals.Count == 0
            ? "The user has no saving goals yet."
            : string.Join("\n", goals.Select(g =>
                $"- {g.Emoji} {g.Name}: saved ${g.SavedAmount:F2} of ${g.TargetAmount:F2} " +
                $"({g.Progress:F1}% complete)" +
                (g.Deadline.HasValue ? $", deadline {g.Deadline:yyyy-MM-dd}" : "")));

        var focusGoalLine = "";
        if (req.GoalId.HasValue)
        {
            var g = goals.FirstOrDefault(x => x.Id == req.GoalId.Value);
            if (g is not null)
                focusGoalLine = $"\nFocused goal: {g.Emoji} {g.Name} — ${g.SavedAmount:F2} / ${g.TargetAmount:F2}\n";
        }

        var prompt =
            "You are Sedix, a friendly personal savings advisor. " +
            "Reply in 2-4 sentences, be motivating and specific. " +
            "Reply in the same language the user writes in.\n\n" +
            $"User's goals:\n{goalContext}{focusGoalLine}\n\n" +
            $"User: {req.Question}";

        var answer = await CallGeminiAsync(prompt);

        var suggestions = req.GoalId.HasValue
            ? new[]
            {
                "How much should I save per week?",
                "When will I reach this goal?",
                "Give me 3 tips to save faster.",
                "What if I increase savings by 20%?",
            }
            : DefaultSuggestions;

        return new AiAdviceResponse(answer, suggestions);
    }

    private async Task<string> CallGeminiAsync(string prompt)
    {
        var apiKey = config["Gemini:ApiKey"];

        if (string.IsNullOrWhiteSpace(apiKey) || apiKey == "YOUR_GEMINI_API_KEY")
            return "AI advisor is not configured. Ask your admin to add the Gemini API key.";

        var url = $"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key={apiKey}";

        var body = JsonSerializer.Serialize(new
        {
            contents = new[]
            {
                new
                {
                    role = "user",
                    parts = new[] { new { text = prompt } }
                }
            },
            generationConfig = new
            {
                temperature = 0.7,
                maxOutputTokens = 300,
            },
        });

        var request = new HttpRequestMessage(HttpMethod.Post, url)
        {
            Content = new StringContent(body, Encoding.UTF8, "application/json")
        };

        var response = await Http.SendAsync(request);
        var raw = await response.Content.ReadAsStringAsync();

        if (!response.IsSuccessStatusCode)
        {
            // Extract Gemini error message for easier debugging
            try
            {
                using var err = JsonDocument.Parse(raw);
                var msg = err.RootElement
                    .GetProperty("error")
                    .GetProperty("message")
                    .GetString();
                return $"Gemini error: {msg}";
            }
            catch
            {
                return $"Gemini error ({(int)response.StatusCode}): {raw[..Math.Min(raw.Length, 200)]}";
            }
        }

        using var doc = JsonDocument.Parse(raw);
        return doc.RootElement
            .GetProperty("candidates")[0]
            .GetProperty("content")
            .GetProperty("parts")[0]
            .GetProperty("text")
            .GetString() ?? "No response.";
    }
}
