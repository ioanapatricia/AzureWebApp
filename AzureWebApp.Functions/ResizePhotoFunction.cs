using System.IO;
using System.Threading.Tasks;
using Azure.Storage.Blobs;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

namespace AzureWebApp.Functions
{
    public class ResizePhotoFunction
    {
        private readonly IConfiguration _configuration;

        public ResizePhotoFunction(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        [Function("ResizePhoto")]
        public async Task Run(
            [BlobTrigger("photos/{name}", Connection = "AzureStorageConnection")] Stream blobStream,
            string name,
            FunctionContext context)
        {
            var logger = context.GetLogger("ResizePhotoFunction");
            
            try
            {
                logger.LogInformation($"Processing image: {name}");

                // Get configuration
                var connectionString = _configuration["AzureStorage:ConnectionString"];
                var resizedContainer = _configuration["AzureStorage:ResizedContainer"] ?? "photos-resized";
                var width = int.Parse(_configuration["ImageResize:Width"] ?? "500");
                var height = int.Parse(_configuration["ImageResize:Height"] ?? "500");
                var quality = int.Parse(_configuration["ImageResize:Quality"] ?? "90");

                // Load and resize image
                using (var image = await Image.LoadAsync(blobStream))
                {
                    image.Mutate(x => x
                        .Resize(new ResizeOptions
                        {
                            Size = new Size(width, height),
                            Mode = ResizeMode.Crop
                        }));

                    // Save to blob storage
                    var resizedBlobClient = new BlobContainerClient(connectionString, resizedContainer);
                    await resizedBlobClient.CreateIfNotExistsAsync();

                    using (var resizedStream = new MemoryStream())
                    {
                        await image.SaveAsJpegAsync(resizedStream, new SixLabors.ImageSharp.Formats.Jpeg.JpegEncoder { Quality = quality });
                        resizedStream.Position = 0;

                        var blobClient = resizedBlobClient.GetBlobClient(name);
                        await blobClient.UploadAsync(resizedStream, overwrite: true);

                        logger.LogInformation($"Successfully resized and saved: {name} to {resizedContainer}");
                    }
                }
            }
            catch (Exception ex)
            {
                logger.LogError($"Error processing image {name}: {ex.Message}");
                throw;
            }
        }
    }
}
