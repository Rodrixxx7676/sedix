namespace Sedix.API.DTOs;

public record UserSummaryResponse(
    Guid Id,
    string Name,
    string Email,
    string Role,
    int GoalCount,
    decimal TotalSaved,
    int CompletedGoals,
    DateTime CreatedAt
);

public record UpdateRoleRequest(string Role);

public record GlobalStatsResponse(
    int TotalUsers,
    int TotalGoals,
    int CompletedGoals,
    decimal TotalSaved
);
