using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rhipheus.Genie.Api.Models;

namespace Rhipheus.Genie.Web.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ChatThreadsController : ControllerBase
    {
        private readonly GenieContext _context;

        public ChatThreadsController(GenieContext context)
        {
            _context = context;
        }

        // GET: api/ChatThreads
        [HttpGet]
        public ActionResult<IOrderedQueryable<ChatThread>> GetChatThreads()
        {
            if (_context.ChatThreads == null)
            {
                return NotFound();
            }
           
            return Ok(_context.ChatThreads.OrderByDescending(m => m.DateCreated));
        }

        // GET: api/ChatThreads/5
        [HttpGet("/api/ChatThread/{id}")]
        public async Task<ActionResult<ChatThread>> GetChatThread(Guid id)
        {
          if (_context.ChatThreads == null)
          {
              return NotFound();
          }
            var chatThread = await _context.ChatThreads.FindAsync(id);

            if (chatThread == null)
            {
                return NotFound();
            }

            return chatThread;
        }

        // PUT: api/ChatThreads/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("/api/ChatThread/{id}")]
        public async Task<IActionResult> PutChatThread(Guid id, ChatThreadBinding input)
        {
            var chatThread = await _context.ChatThreads.FindAsync(id);
            if (chatThread == null)
            {
                return NotFound();
            }

            chatThread.Name = input.Name;
            _context.Entry(chatThread).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!ChatThreadExists(id))
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

       


        // POST: api/ChatThreads
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost("/api/ChatThread/")]
        public async Task<ActionResult<ChatThread>> PostChatThread(ChatThreadBinding chatThreadBinding)
        {
          if (_context.ChatThreads == null)
          {
              return Problem("Entity set 'GenieContext.ChatThreads'  is null.");
          }
            ChatThread chatThread = new ChatThread
            {
                Id = Guid.NewGuid(),
                Name = chatThreadBinding.Name,
                DateCreated = DateTime.Now
            };
           
            _context.ChatThreads.Add(chatThread);
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                if (ChatThreadExists(chatThread.Id))
                {

                    return Conflict();
                }
                else
                {
                    throw;
                }
            }

            return CreatedAtAction("GetChatThread", new { id = chatThread.Id }, chatThread);
        }

        // DELETE: api/ChatThreads/5
        [HttpDelete("/api/ChatThread/{id}")]
        public async Task<IActionResult> DeleteChatThread(Guid id)
        {
            if (_context.ChatThreads == null)
            {
                return NotFound();
            }
            var chatThread = await _context.ChatThreads.FindAsync(id);
            if (chatThread == null)
            {
                return NotFound();
            }

            _context.ChatThreads.Remove(chatThread);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool ChatThreadExists(Guid id)
        {
            return (_context.ChatThreads?.Any(e => e.Id == id)).GetValueOrDefault();
        }
    }
}
