using Azure.Storage.Blobs;
using Azure;

namespace Rhipheus.Genie.Web.Api.Services
{
    public interface IFileUploadService
    {
        Task<string> UploadFile(IFormFile file);
    }
    public class FileUploadService : IFileUploadService
    {
        private readonly IConfiguration _configuration;

        public FileUploadService(IConfiguration configuration)
        {
            _configuration = configuration;
        }
        public async Task<string> UploadFile(IFormFile file)
        {
            var imageUrl = "";
            if (file == null || file.Length == 0)
                throw new ArgumentException("No file selected.");

            // Check file format
          //  if (!IsImageFile(file))
            //    throw new ArgumentException("Invalid file format. Only image files are allowed.");


            // Check file size
            if (!IsFileSizeValid(file))
                throw new ArgumentException("File size exceeded. Maximum allowed size is 10MB.");

            try
            {
                // Save the file to Azure Blob Storage
                var connectionStringblob = _configuration.GetValue<string>("AzureStorage:MyConnectionString");
                var containerName = _configuration.GetValue<string>("AzureStorage:AzureContainerName");
                var blobServiceClient = new BlobServiceClient(connectionStringblob);
                var blobContainerClient = blobServiceClient.GetBlobContainerClient(containerName);

                // Create the container if it does not exist.
                await blobContainerClient.CreateIfNotExistsAsync();

                // Get a reference to a blob
                var blobClient = blobContainerClient.GetBlobClient(file.FileName);

                // Open the stream and upload its data
                using (var stream = file.OpenReadStream())
                {
                    await blobClient.UploadAsync(stream, true);
                }
                imageUrl = blobClient.Uri.ToString();
                Console.WriteLine("Image URL Service"+imageUrl);
            }
            catch (RequestFailedException e)
            {
                // Handle Azure-specific exceptions
                throw new Exception($"Error uploading to Blob Storage: {e.Message}");
            }
            catch (Exception e)
            {
                // Handle all other exceptions
                throw new Exception($"An error occurred: {e.Message}");
            }
            return imageUrl;
        }
        private bool IsImageFile(IFormFile file)
        {
            // Check the file's content type to ensure it's an image
            return file.ContentType.StartsWith("image/");
        }

        private bool IsFileSizeValid(IFormFile file)
        {
            const int maxFileSize = 10 * 1024 * 1024; // 10MB
            return file.Length <= maxFileSize;
        }
    }
}
