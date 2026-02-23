using Azure.Storage.Blobs;
using AzureWebApp.Data;
using AzureWebApp.Models;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add database context
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

var connectionString = app.Configuration["AzureStorage:ConnectionString"];
var containerName = app.Configuration["AzureStorage:ContainerName"] ?? "photos";

app.MapPost("/upload", async (IFormFile file, ApplicationDbContext dbContext) =>
{
    var blobClient = new BlobContainerClient(connectionString, containerName);
    await blobClient.CreateIfNotExistsAsync();
    
    var blob = blobClient.GetBlobClient(file.FileName);
    await blob.UploadAsync(file.OpenReadStream(), overwrite: true);

    // Save metadata to database
    var metadata = new BlobMetadata
    {
        DocumentName = file.FileName,
        BlobPath = blob.Uri.ToString(),
        UploadedAt = DateTime.UtcNow
    };

    dbContext.BlobMetadata.Add(metadata);
    await dbContext.SaveChangesAsync();

    return Results.Ok(new { file.FileName, BlobPath = blob.Uri, metadata.Id });
})
.DisableAntiforgery()
.WithName("UploadFile")
.WithTags("Blob Storage");

app.MapGet("/blobs", async (ApplicationDbContext dbContext) =>
{
    var blobs = await dbContext.BlobMetadata
        .OrderByDescending(b => b.UploadedAt)
        .ToListAsync();
    
    return Results.Ok(blobs);
})
.WithName("GetAllBlobs")
.WithTags("Blob Storage");

app.Run();