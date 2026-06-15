using Microsoft.EntityFrameworkCore;
using Sedix.API.Models;

namespace Sedix.API.Data;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<User> Users => Set<User>();
    public DbSet<Goal> Goals => Set<Goal>();
    public DbSet<Transaction> Transactions => Set<Transaction>();

    protected override void OnModelCreating(ModelBuilder model)
    {
        base.OnModelCreating(model);

        model.Entity<User>(e =>
        {
            e.HasKey(u => u.Id);
            e.HasIndex(u => u.Email).IsUnique();
            e.Property(u => u.Email).HasMaxLength(256);
            e.Property(u => u.Name).HasMaxLength(128);
        });

        model.Entity<Goal>(e =>
        {
            e.HasKey(g => g.Id);
            e.Property(g => g.TargetAmount).HasPrecision(18, 2);
            e.Property(g => g.Name).HasMaxLength(128);
            e.Ignore(g => g.SavedAmount);
            e.Ignore(g => g.Progress);
            e.Ignore(g => g.IsCompleted);
            e.HasOne(g => g.User)
             .WithMany(u => u.Goals)
             .HasForeignKey(g => g.UserId)
             .OnDelete(DeleteBehavior.Cascade);
        });

        model.Entity<Transaction>(e =>
        {
            e.HasKey(t => t.Id);
            e.Property(t => t.Amount).HasPrecision(18, 2);
            e.Property(t => t.Type).HasConversion<string>();
            e.HasOne(t => t.Goal)
             .WithMany(g => g.Transactions)
             .HasForeignKey(t => t.GoalId)
             .OnDelete(DeleteBehavior.Cascade);
        });
    }
}
