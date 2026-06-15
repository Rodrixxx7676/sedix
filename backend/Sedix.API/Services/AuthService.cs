using Microsoft.EntityFrameworkCore;
using Sedix.API.Data;
using Sedix.API.DTOs;
using Sedix.API.Models;

namespace Sedix.API.Services;

public interface IAuthService
{
    Task<AuthResponse> RegisterAsync(RegisterRequest req);
    Task<AuthResponse> LoginAsync(LoginRequest req);
}

public class AuthService(AppDbContext db, ITokenService tokenService) : IAuthService
{
    public async Task<AuthResponse> RegisterAsync(RegisterRequest req)
    {
        if (await db.Users.AnyAsync(u => u.Email == req.Email))
            throw new InvalidOperationException("Email already registered.");

        var isFirst = !await db.Users.AnyAsync();

        DateOnly? dob = null;
        if (!string.IsNullOrWhiteSpace(req.DateOfBirth) &&
            DateOnly.TryParse(req.DateOfBirth, out var parsed))
            dob = parsed;

        var user = new User
        {
            Name = req.Name,
            Email = req.Email.ToLowerInvariant(),
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(req.Password),
            Role = isFirst ? UserRole.Admin : UserRole.User,
            Phone = req.Phone,
            Country = req.Country,
            DateOfBirth = dob,
            Currency = req.Currency,
            MonthlyGoal = req.MonthlyGoal,
        };

        db.Users.Add(user);
        await db.SaveChangesAsync();

        return new AuthResponse(
            tokenService.Generate(user), user.Name, user.Email, user.Role.ToString());
    }

    public async Task<AuthResponse> LoginAsync(LoginRequest req)
    {
        var user = await db.Users.FirstOrDefaultAsync(
            u => u.Email == req.Email.ToLowerInvariant())
            ?? throw new UnauthorizedAccessException("Invalid credentials.");

        if (!BCrypt.Net.BCrypt.Verify(req.Password, user.PasswordHash))
            throw new UnauthorizedAccessException("Invalid credentials.");

        return new AuthResponse(
            tokenService.Generate(user), user.Name, user.Email, user.Role.ToString());
    }
}
