namespace Sedix.API.DTOs;

public record RegisterRequest(
    string Name,
    string Email,
    string Password,
    string? Phone = null,
    string? Country = null,
    string? DateOfBirth = null,   // ISO date string: "1999-05-20"
    string Currency = "USD",
    decimal? MonthlyGoal = null,
    string? RecaptchaToken = null
);

public record LoginRequest(string Email, string Password);

public record AuthResponse(string Token, string Name, string Email, string Role);
