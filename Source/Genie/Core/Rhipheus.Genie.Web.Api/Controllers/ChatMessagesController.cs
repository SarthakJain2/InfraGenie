using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Azure.AI.OpenAI;
using Azure;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Rhipheus.Genie.Api.Models;
using Rhipheus.Genie.Web.Api.Services;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using System.Net;
using Microsoft.Identity.Client;

namespace Rhipheus.Genie.Web.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ChatMessagesController : ControllerBase
    {
        private readonly GenieContext _context;
        private readonly IConfiguration _configuration;
        private readonly IFileUploadService _fileUploadService;

       


        public ChatMessagesController(GenieContext context, IConfiguration configuration, IFileUploadService fileUploadService)
        {
            _context = context;
            _configuration = configuration;
            _fileUploadService = fileUploadService;
        }

        // GET: api/ChatMessages
        [HttpGet]
        public ActionResult<IOrderedQueryable<Rhipheus.Genie.Api.Models.ChatMessage>> GetChatMessages()
        {
            if (_context.ChatMessages == null)
            {
                return NotFound();
            }

            //return _context.ChatMessages.OrderBy(m => m.DateCreated);
            return Ok(_context.ChatMessages.OrderBy(m => m.DateCreated));
        }

        // GET: api/ChatMessages/5
        [HttpGet("/api/ChatMessage{id}")]
        public async Task<ActionResult<Rhipheus.Genie.Api.Models.ChatMessage>> GetChatMessage(Guid id)
        {
          if (_context.ChatMessages == null)
          {
              return NotFound();
          }
            var chatMessage = await _context.ChatMessages.FindAsync(id);

            if (chatMessage == null)
            {
                return NotFound();
            }

            return chatMessage;
        }

        // GET: api/ChatMessages/Thread/{ThreadId}
        [HttpGet("Thread/{threadId}")]
        public async Task<ActionResult<List<Rhipheus.Genie.Api.Models.ChatMessage>>> GetChatMessagesByThreadId(Guid threadId)
        {
            if (_context.ChatMessages == null)
            {
                return NotFound();
            }
            var chatMessages = await _context.ChatMessages
                                    .Where(m => m.ThreadId == threadId)
                                     .Include(m => m.Document)
                                    .OrderBy(m => m.DateCreated)
                                    .ToListAsync();

            if (chatMessages == null || !chatMessages.Any())
            {
                return NotFound();
            }

            return chatMessages;
        }

        // PUT: api/ChatMessages/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("/api/ChatMessage/{id}")]
        public async Task<IActionResult> PutChatMessage(Guid id, Rhipheus.Genie.Api.Models.ChatMessage chatMessage)
        {
            if (id != chatMessage.Id)
            {
                return BadRequest();
            }

            _context.Entry(chatMessage).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!ChatMessageExists(id))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return NoContent();
        }

        // POST: api/ChatMessages                                        
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost("/api/ChatMessage")]
        public async Task<ActionResult<Rhipheus.Genie.Api.Models.ChatMessage>> PostChatMessage([FromForm] ChatMessageBinding chatMessageBinding, IFormFile file=null)
        {
            var imageUrl = "";
            Guid? documentId = null;
            try
            {
                if (file != null)
                {
       
                    imageUrl = await _fileUploadService.UploadFile(file);
                    Console.WriteLine("imageUrl:-" + imageUrl);

                    Document document = new Document
                    {
                        Id = Guid.NewGuid(),
                        LinkedId = Guid.NewGuid(),
                        LinkType = "azure",
                        Location = imageUrl 
                    };
                    _context.Documents.Add(document);
                    try
                    {
                        await _context.SaveChangesAsync();
                        documentId = document.Id;
                    }
                    catch (DbUpdateException)
                    {
                        throw new Exception("Failed to save the document.");
                    }

                   
                }
               // return Ok(imageUrl);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"An error occurred: {ex.Message}");
            }

            var openAIKey = _configuration.GetValue<string>("OpenAI:Key");
            var model = _configuration.GetValue<string>("OpenAI:Model");
            var temperature = _configuration.GetValue<double>("OpenAI:Temperature");
            var endPoint = _configuration.GetValue<string>("OpenAI:EndPoint");

            OpenAIClient client = new OpenAIClient(
                           new Uri(endPoint),
                           new AzureKeyCredential(openAIKey));

            ChatCompletionsOptions options = new ChatCompletionsOptions()
            {
                Messages = { new Azure.AI.OpenAI.ChatMessage(ChatRole.System, @"You are an AI assistant that helps people find information.") },
                Temperature = (float)0.7,
                MaxTokens = 800,
                NucleusSamplingFactor = (float)0.95,
                FrequencyPenalty = 0,
                PresencePenalty = 0,
            };
            options.Messages.Add(new Azure.AI.OpenAI.ChatMessage(ChatRole.User, chatMessageBinding.Request));
            Response<ChatCompletions> response =await client.GetChatCompletionsAsync(deploymentOrModelName: model, options);

            ChatCompletions completions = response.Value;
            string fullresponse = completions.Choices[0].Message.Content;

            options.Messages.Add(completions.Choices[0].Message);

            Rhipheus.Genie.Api.Models.ChatMessage chatMessage = new Rhipheus.Genie.Api.Models.ChatMessage
               {
                   Id = Guid.NewGuid(),
                   ThreadId = chatMessageBinding.ThreadId,
                   GroupId = chatMessageBinding.GroupId,
                   Request = chatMessageBinding.Request,
                   DocumentId=documentId,
                   DateCreated= DateTime.Now,
                   Attempt=0,
                   Response= fullresponse
            }; 
            if (_context.ChatMessages == null)
          {
              return Problem("Entity set 'GenieContext.ChatMessages'  is null.");
          }
            

            _context.ChatMessages.Add(chatMessage);
            if (file != null)
            { 
                
            }
                // _context.Documents.Add(document);
                try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                if (ChatMessageExists(chatMessage.Id))
                {
                    return Conflict();
                }
                else
                {
                    throw;
                }
            }

            return CreatedAtAction("GetChatMessage", new { id = chatMessage.Id }, chatMessage);
        }

        // DELETE: api/ChatMessages/5
        [HttpDelete("/api/ChatMessage/{id}")]
        public async Task<IActionResult> DeleteChatMessage(Guid id)
        {
            if (_context.ChatMessages == null)
            {
                return NotFound();
            }
            var chatMessage = await _context.ChatMessages.FindAsync(id);
            if (chatMessage == null)
            {
                return NotFound();
            }

            _context.ChatMessages.Remove(chatMessage);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool ChatMessageExists(Guid id)
        {
            return (_context.ChatMessages?.Any(e => e.Id == id)).GetValueOrDefault();
        }
    }
}
