namespace Sedix.API.Models;

public enum UserRole { User, Admin }

public class User
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public UserRole Role { get; set; } = UserRole.User;

    // Extended profile
    public string? Phone { get; set; }
    public string? Country { get; set; }
    public DateOnly? DateOfBirth { get; set; }
    public string Currency { get; set; } = "USD";
    public decimal? MonthlyGoal { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<Goal> Goals { get; set; } = [];
}
