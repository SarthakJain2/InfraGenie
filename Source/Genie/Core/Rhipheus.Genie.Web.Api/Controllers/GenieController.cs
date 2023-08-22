using Azure;
using Azure.Storage.Queues;
using Azure.Storage.Queues.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Rhipheus.Genie.Api.Models;
using Azure.Storage.Blobs;
using Newtonsoft.Json;
using System.Collections;

//updated for concurrent execution  
namespace Rhipheus.Genie.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class GenieController : Controller
    {
        private readonly IConfiguration _configuration;
        private readonly AzureQueueService _azureQueueService;
        private string jsonString;


        public GenieController(IConfiguration configuration, AzureQueueService azureQueueService)
        {
            _configuration = configuration;
            _azureQueueService = azureQueueService;
        }

        [HttpPost("/api/Execute")]
        public async Task<IActionResult> ExecuteAsync([FromBody] GenieRequest request)
        {
            if (string.IsNullOrEmpty(request.SessionId))
            {
                request.SessionId = Guid.NewGuid().ToString();
            }

            // Convert the request into the string format you want to store in the queue
            string responseMessage = GenerateResponseMessage(request.Request, request.Command, request.Parameters, request.SessionId, request.ThreadId);

            await _azureQueueService.EnqueueRequestAsync(responseMessage);

            return Ok(new { ResponseMessage = responseMessage, SessionId = request.SessionId });
        }

        private string GenerateResponseMessage(string request, string command, Parameter[] parameters, string sessionId, string threadId)
        {
            /*string response = request + " " + command;

            foreach (Parameter parameter in parameters)
            {
                response += " " + parameter.Name;
                response += " " + parameter.Value;
            }

            response += " " + sessionId;
            response += " " + threadId;  


            return response;*/
            GenieRequest response = new GenieRequest()
            {
                Request = request,
                Command = command,
                Parameters = parameters,
                SessionId = sessionId,
                ThreadId = threadId
            };

            return JsonConvert.SerializeObject(response);
        }

        [HttpGet("/api/Messages/{threadId}")]
        public async Task<IActionResult> GetMessagesByThreadIdAsync(string threadId)
        {
            try
            {
                var messageContents = await _azureQueueService.GetMessagesWithRetryAsync();

                if (!messageContents.Any())
                {
                    return NotFound("No messages in the queue.");
                }

                // Filter messages by ThreadId
                var filteredMessages = messageContents
                    .Select(message => JsonConvert.DeserializeObject<GenieRequest>(message))
                    .Where(request => request.ThreadId == threadId)
                    .ToList();

                if (filteredMessages.Count > 0)
                {
                    return Ok(filteredMessages);
                }
                else
                {
                    return NotFound($"No messages in the queue for ThreadId {threadId}.");
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, "Error retrieving messages from the queue: " + ex.Message);
            }
        }


        public class AzureQueueService
        {
            private readonly IConfiguration _configuration;
            private readonly QueueClient _queueClient;

            public AzureQueueService(IConfiguration configuration)
            {
                _configuration = configuration;
                var connectionString = configuration.GetValue<string>("AzureStorage:MyConnectionString");
                var queueName = configuration.GetValue<string>("AzureStorage:queueName");
                _queueClient = new QueueClient(connectionString, queueName);
            }

            public async Task EnqueueRequestAsync(string responseMessage)
            {
                await CreateQueueIfNotExistsAsync();
                try
                {
                    await _queueClient.SendMessageAsync(responseMessage);
                    Console.WriteLine("Command sent into the queue.");
                }
                catch (Exception ex)
                {
                    throw new Exception("Error enqueueing the message: " + ex.Message);
                }
            }

            private async Task CreateQueueIfNotExistsAsync()
            {
                if (!_queueClient.Exists())
                {
                    await _queueClient.CreateAsync();
                    Console.WriteLine("Queue does not exist, created a new queue.");
                }
            }

            public async Task<List<string>> GetMessagesWithRetryAsync()
            {
                await CreateQueueIfNotExistsAsync();
                var messageContents = new List<string>();
                try
                {
                    QueueProperties queueProperties = await _queueClient.GetPropertiesAsync();
                    if (queueProperties.ApproximateMessagesCount > 0)
                    {
                        QueueMessage[] peekedMessages = await ReceiveMessagesWithRetryAsync(_queueClient, maxMessages: 10);
                        foreach (QueueMessage peekedMessage in peekedMessages)
                        {
                            string messageContent = peekedMessage.MessageText;
                            Console.WriteLine("Getting Command from the queue:\n" + messageContent);
                            messageContents.Add(messageContent);
                        }
                    }
                }
                catch (Exception ex)
                {
                    throw new Exception("Error retrieving messages from the queue: " + ex.Message);
                }
                return messageContents;
            }

            private async Task<QueueMessage[]> ReceiveMessagesWithRetryAsync(QueueClient queueClient, int maxMessages)
            {
                while (true)
                {
                    try
                    {
                        var messageResponse = await queueClient.ReceiveMessagesAsync(maxMessages);
                        var messages = messageResponse.Value;
                        Console.WriteLine("Messages from queue: " + messages.Length);
                        return messages;
                    }
                    catch (RequestFailedException ex)
                    {
                        Console.WriteLine("Error Occured:" + ex);
                    }
                }
            }


        }

    }

}
