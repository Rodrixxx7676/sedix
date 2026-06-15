namespace Sedix.API.DTOs;

public record AiAdviceRequest(string Question, Guid? GoalId = null);

public record AiAdviceResponse(string Answer, string[] SuggestedQuestions);
