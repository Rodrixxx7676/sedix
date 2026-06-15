namespace Sedix.API.Models;

public enum TransactionType { Deposit, Withdrawal }

public class Transaction
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid GoalId { get; set; }
    public decimal Amount { get; set; }
    public TransactionType Type { get; set; } = TransactionType.Deposit;
    public string? Note { get; set; }
    public DateTime Date { get; set; } = DateTime.UtcNow;

    public Goal Goal { get; set; } = null!;
}
