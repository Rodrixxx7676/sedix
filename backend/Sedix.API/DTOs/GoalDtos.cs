namespace Sedix.API.DTOs;

public record CreateGoalRequest(
    string Name,
    string? Description,
    decimal TargetAmount,
    DateTime? Deadline,
    string Emoji = "🏦"
);

public record UpdateGoalRequest(
    string? Name,
    string? Description,
    decimal? TargetAmount,
    DateTime? Deadline,
    string? Emoji
);

public record GoalResponse(
    Guid Id,
    string Name,
    string? Description,
    decimal TargetAmount,
    decimal SavedAmount,
    decimal Progress,
    bool IsCompleted,
    DateTime? Deadline,
    string Emoji,
    DateTime CreatedAt
);

public record AddTransactionRequest(
    decimal Amount,
    string Type,   // "deposit" | "withdrawal"
    string? Note
);

public record TransactionResponse(
    Guid Id,
    decimal Amount,
    string Type,
    string? Note,
    DateTime Date
);
