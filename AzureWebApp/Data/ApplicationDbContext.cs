using Microsoft.EntityFrameworkCore;
using AzureWebApp.Models;

namespace AzureWebApp.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    public DbSet<BlobMetadata> BlobMetadata { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<BlobMetadata>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.DocumentName).IsRequired().HasMaxLength(500);
            entity.Property(e => e.BlobPath).IsRequired().HasMaxLength(1000);
            entity.Property(e => e.UploadedAt).IsRequired();
        });
    }
}
