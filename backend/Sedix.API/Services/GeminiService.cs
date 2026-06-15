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

public class GeminiService(IConfiguration config, HttpClient http, AppDbContext db) : IGeminiService
{
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

        GoalDtos.GoalResponse? targetGoal = null;
        if (req.GoalId.HasValue)
        {
            var g = goals.FirstOrDefault(g => g.Id == req.GoalId.Value);
            if (g is not null)
                targetGoal = new GoalDtos.GoalResponse(
                    g.Id, g.Name, g.Description, g.TargetAmount,
                    g.SavedAmount, g.Progress, g.IsCompleted, g.Deadline, g.Emoji, g.CreatedAt);
        }

        var systemPrompt =
            "You are Seди, a friendly and practical personal savings advisor inside the Sedix app. " +
            "Keep answers concise (2-4 sentences), motivating, and actionable. " +
            "When relevant, mention specific amounts or timeframes from the user's goals. " +
            "Always reply in the same language the user writes in.";

        var userMessage =
            $"User's saving goals:\n{goalContext}\n\n" +
            (targetGoal is not null ? $"Focused goal: {targetGoal.Emoji} {targetGoal.Name}\n\n" : "") +
            $"User question: {req.Question}";

        var answer = await CallGeminiAsync(systemPrompt, userMessage);

        var suggestions = targetGoal is not null
            ? new[]
            {
                $"How much do I need to save per week for {targetGoal.Name}?",
                $"When will I complete {targetGoal.Name} at my current pace?",
                "What if I increase my savings by 20%?",
                "Give me 3 tips to reach this goal faster.",
            }
            : DefaultSuggestions;

        return new AiAdviceResponse(answer, suggestions);
    }

    private async Task<string> CallGeminiAsync(string system, string user)
    {
        var apiKey = config["Gemini:ApiKey"];
        if (string.IsNullOrWhiteSpace(apiKey) || apiKey == "YOUR_GEMINI_API_KEY")
            return "AI advisor is not configured yet. Ask your admin to set up the Gemini API key.";

        var url = $"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={apiKey}";

        var body = new
        {
            system_instruction = new { parts = new[] { new { text = system } } },
            contents = new[]
            {
                new { role = "user", parts = new[] { new { text = user } } }
            },
            generationConfig = new
            {
                temperature = 0.7,
                maxOutputTokens = 256,
            },
        };

        var json = JsonSerializer.Serialize(body);
        var content = new StringContent(json, Encoding.UTF8, "application/json");
        var response = await http.PostAsync(url, content);

        if (!response.IsSuccessStatusCode)
            return "I couldn't connect to the AI service right now. Please try again later.";

        var raw = await response.Content.ReadAsStringAsync();
        using var doc = JsonDocument.Parse(raw);

        return doc.RootElement
            .GetProperty("candidates")[0]
            .GetProperty("content")
            .GetProperty("parts")[0]
            .GetProperty("text")
            .GetString() ?? "No response.";
    }
}

// Nested DTO for internal use
file static class GoalDtos
{
    public record GoalResponse(
        Guid Id, string Name, string? Description,
        decimal TargetAmount, decimal SavedAmount, decimal Progress,
        bool IsCompleted, DateTime? Deadline, string Emoji, DateTime CreatedAt);
}
