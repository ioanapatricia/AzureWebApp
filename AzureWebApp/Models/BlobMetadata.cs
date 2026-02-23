namespace AzureWebApp.Models;

public class BlobMetadata
{
    public int Id { get; set; }
    public string DocumentName { get; set; } = string.Empty;
    public string BlobPath { get; set; } = string.Empty;
    public DateTime UploadedAt { get; set; } = DateTime.UtcNow;
}
