using Microsoft.EntityFrameworkCore;
using Sedix.API.Data;
using Sedix.API.DTOs;
using Sedix.API.Models;

namespace Sedix.API.Services;

public interface IAdminService
{
    Task<List<UserSummaryResponse>> GetAllUsersAsync();
    Task<GlobalStatsResponse> GetGlobalStatsAsync();
    Task<UserSummaryResponse> UpdateRoleAsync(Guid userId, UpdateRoleRequest req);
    Task DeleteUserAsync(Guid userId);
}

public class AdminService(AppDbContext db) : IAdminService
{
    public async Task<List<UserSummaryResponse>> GetAllUsersAsync() =>
        await db.Users
            .Include(u => u.Goals).ThenInclude(g => g.Transactions)
            .OrderBy(u => u.CreatedAt)
            .Select(u => ToSummary(u))
            .ToListAsync();

    public async Task<GlobalStatsResponse> GetGlobalStatsAsync()
    {
        var users = await db.Users
            .Include(u => u.Goals).ThenInclude(g => g.Transactions)
            .ToListAsync();

        var allGoals = users.SelectMany(u => u.Goals).ToList();
        var totalSaved = allGoals.SelectMany(g => g.Transactions).Sum(t => t.Amount);

        return new GlobalStatsResponse(
            TotalUsers: users.Count,
            TotalGoals: allGoals.Count,
            CompletedGoals: allGoals.Count(g => g.IsCompleted),
            TotalSaved: totalSaved
        );
    }

    public async Task<UserSummaryResponse> UpdateRoleAsync(Guid userId, UpdateRoleRequest req)
    {
        var user = await db.Users
            .Include(u => u.Goals).ThenInclude(g => g.Transactions)
            .FirstOrDefaultAsync(u => u.Id == userId)
            ?? throw new KeyNotFoundException($"User {userId} not found.");

        if (!Enum.TryParse<UserRole>(req.Role, ignoreCase: true, out var role))
            throw new InvalidOperationException($"Invalid role '{req.Role}'. Valid: User, Admin.");

        user.Role = role;
        await db.SaveChangesAsync();
        return ToSummary(user);
    }

    public async Task DeleteUserAsync(Guid userId)
    {
        var user = await db.Users.FindAsync(userId)
            ?? throw new KeyNotFoundException($"User {userId} not found.");
        db.Users.Remove(user);
        await db.SaveChangesAsync();
    }

    private static UserSummaryResponse ToSummary(User u)
    {
        var totalSaved = u.Goals.SelectMany(g => g.Transactions).Sum(t => t.Amount);
        return new UserSummaryResponse(
            u.Id, u.Name, u.Email, u.Role.ToString(),
            u.Goals.Count, totalSaved,
            u.Goals.Count(g => g.IsCompleted), u.CreatedAt);
    }
}
