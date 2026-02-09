using Azure.Storage.Blobs;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

var connectionString = app.Configuration["AzureStorage:ConnectionString"];
var containerName = app.Configuration["AzureStorage:ContainerName"] ?? "photos";

app.MapPost("/upload", async (IFormFile file) =>
{
    var blobClient = new BlobContainerClient(connectionString, containerName);
    await blobClient.CreateIfNotExistsAsync();
    
    var blob = blobClient.GetBlobClient(file.FileName);
    await blob.UploadAsync(file.OpenReadStream(), overwrite: true);

    return Results.Ok(new { file.FileName, blob.Uri });
}).DisableAntiforgery();

app.Run();