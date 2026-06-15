namespace Sedix.API.Models;

public class Goal
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid UserId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public decimal TargetAmount { get; set; }
    public DateTime? Deadline { get; set; }
    public string Emoji { get; set; } = "🏦";
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public User User { get; set; } = null!;
    public ICollection<Transaction> Transactions { get; set; } = [];

    public decimal SavedAmount => Transactions.Sum(t => t.Amount);
    public decimal Progress => TargetAmount == 0 ? 0 : SavedAmount / TargetAmount * 100;
    public bool IsCompleted => SavedAmount >= TargetAmount;
}
