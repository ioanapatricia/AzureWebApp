using System.IO;
using Azure.Storage.Blobs;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddAntiforgery();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();
app.UseHttpsRedirection();
app.UseAuthorization();

app.MapPost("/upload", async (IFormFile file) =>
{
    if (file?.Length > 0)
    {
        var connectionString = builder.Configuration.GetConnectionString("AzureStorage");
        var containerName = "photos";
        var blobServiceClient = new BlobServiceClient(connectionString);
        var containerClient = blobServiceClient.GetBlobContainerClient(containerName);
        await containerClient.CreateIfNotExistsAsync();
        var blobClient = containerClient.GetBlobClient(file.FileName);

        using var stream = file.OpenReadStream();
        await blobClient.UploadAsync(stream, overwrite: true);

        return Results.Ok(new
        {
            message = "File uploaded",
            fileName = file.FileName,
            uri = blobClient.Uri
        });
    }
    return Results.BadRequest("No file provided");
}).DisableAntiforgery();

app.MapControllers();

app.Run();
