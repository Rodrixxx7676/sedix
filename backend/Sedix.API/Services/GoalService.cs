using Microsoft.EntityFrameworkCore;
using Sedix.API.Data;
using Sedix.API.DTOs;
using Sedix.API.Models;

namespace Sedix.API.Services;

public interface IGoalService
{
    Task<List<GoalResponse>> GetAllAsync(Guid userId);
    Task<GoalResponse> GetByIdAsync(Guid userId, Guid goalId);
    Task<GoalResponse> CreateAsync(Guid userId, CreateGoalRequest req);
    Task<GoalResponse> UpdateAsync(Guid userId, Guid goalId, UpdateGoalRequest req);
    Task DeleteAsync(Guid userId, Guid goalId);
    Task<GoalResponse> AddTransactionAsync(Guid userId, Guid goalId, AddTransactionRequest req);
    Task<List<TransactionResponse>> GetTransactionsAsync(Guid userId, Guid goalId);
}

public class GoalService(AppDbContext db) : IGoalService
{
    public async Task<List<GoalResponse>> GetAllAsync(Guid userId) =>
        await db.Goals
            .Where(g => g.UserId == userId)
            .Include(g => g.Transactions)
            .OrderByDescending(g => g.CreatedAt)
            .Select(g => ToResponse(g))
            .ToListAsync();

    public async Task<GoalResponse> GetByIdAsync(Guid userId, Guid goalId)
    {
        var goal = await FindGoalAsync(userId, goalId);
        return ToResponse(goal);
    }

    public async Task<GoalResponse> CreateAsync(Guid userId, CreateGoalRequest req)
    {
        var goal = new Goal
        {
            UserId = userId,
            Name = req.Name,
            Description = req.Description,
            TargetAmount = req.TargetAmount,
            Deadline = req.Deadline,
            Emoji = req.Emoji,
        };

        db.Goals.Add(goal);
        await db.SaveChangesAsync();
        await db.Entry(goal).Collection(g => g.Transactions).LoadAsync();

        return ToResponse(goal);
    }

    public async Task<GoalResponse> UpdateAsync(Guid userId, Guid goalId, UpdateGoalRequest req)
    {
        var goal = await FindGoalAsync(userId, goalId);

        if (req.Name is not null) goal.Name = req.Name;
        if (req.Description is not null) goal.Description = req.Description;
        if (req.TargetAmount.HasValue) goal.TargetAmount = req.TargetAmount.Value;
        if (req.Deadline.HasValue) goal.Deadline = req.Deadline;
        if (req.Emoji is not null) goal.Emoji = req.Emoji;

        await db.SaveChangesAsync();
        return ToResponse(goal);
    }

    public async Task DeleteAsync(Guid userId, Guid goalId)
    {
        var goal = await FindGoalAsync(userId, goalId);
        db.Goals.Remove(goal);
        await db.SaveChangesAsync();
    }

    public async Task<GoalResponse> AddTransactionAsync(
        Guid userId, Guid goalId, AddTransactionRequest req)
    {
        var goal = await FindGoalAsync(userId, goalId);

        var txType = req.Type.ToLower() == "withdrawal"
            ? TransactionType.Withdrawal
            : TransactionType.Deposit;

        var amount = txType == TransactionType.Withdrawal ? -Math.Abs(req.Amount) : Math.Abs(req.Amount);

        goal.Transactions.Add(new Transaction
        {
            GoalId = goalId,
            Amount = amount,
            Type = txType,
            Note = req.Note,
        });

        await db.SaveChangesAsync();
        return ToResponse(goal);
    }

    public async Task<List<TransactionResponse>> GetTransactionsAsync(Guid userId, Guid goalId)
    {
        var goal = await FindGoalAsync(userId, goalId);
        return goal.Transactions
            .OrderByDescending(t => t.Date)
            .Select(t => new TransactionResponse(t.Id, t.Amount, t.Type.ToString(), t.Note, t.Date))
            .ToList();
    }

    private async Task<Goal> FindGoalAsync(Guid userId, Guid goalId) =>
        await db.Goals
            .Include(g => g.Transactions)
            .FirstOrDefaultAsync(g => g.Id == goalId && g.UserId == userId)
            ?? throw new KeyNotFoundException($"Goal {goalId} not found.");

    private static GoalResponse ToResponse(Goal g) => new(
        g.Id, g.Name, g.Description,
        g.TargetAmount, g.SavedAmount, g.Progress, g.IsCompleted,
        g.Deadline, g.Emoji, g.CreatedAt);
}
