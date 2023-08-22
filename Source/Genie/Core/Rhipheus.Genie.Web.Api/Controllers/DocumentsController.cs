using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Azure.Storage.Blobs;
using Azure;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rhipheus.Genie.Api.Models;
using Rhipheus.Genie.Web.Api.Services;

namespace Rhipheus.Genie.Web.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DocumentsController : ControllerBase
    {
        private readonly GenieContext _context;
        private readonly IConfiguration _configuration;
        private readonly IFileUploadService _fileUploadService;

        public DocumentsController(GenieContext context, IConfiguration configuration, IFileUploadService fileUploadService)
        {
            _context = context;
            _configuration = configuration;
            _fileUploadService = fileUploadService;
        }

        // GET: api/Documents
        [HttpGet]
        public ActionResult<IQueryable<Document>> GetDocuments()
        {
          if (_context.Documents == null)
          {
              return NotFound();
          }
            return _context.Documents;
        }

        // GET: api/Documents/5
        [HttpGet("/api/Document/{id}")]
        public async Task<ActionResult<Document>> GetDocument(Guid id)
        {
          if (_context.Documents == null)
          {
              return NotFound();
          }
            var document = await _context.Documents.FindAsync(id);

            if (document == null)
            {
                return NotFound();
            }

            return document;
        }

        // PUT: api/Documents/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("/api/Document/{id}")]
        public async Task<IActionResult> PutDocument(Guid id, Document document)
        {
            if (id != document.Id)
            {
                return BadRequest();
            }

            _context.Entry(document).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!DocumentExists(id))
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

        // POST: api/Documents
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost("/api/Document/")]
        public async Task<ActionResult<Document>> PostDocument(IFormFile file,Guid LinkedId,string LinkType)
        {
            var imageUrl = "";
            try
            {
                imageUrl = await _fileUploadService.UploadFile(file);
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

            Document document = new Document
            {
                Id = Guid.NewGuid(),
                LinkedId= LinkedId,
                LinkType= LinkType,
                Location = imageUrl,
            };


            if (_context.Documents == null)
          {
              return Problem("Entity set 'GenieContext.Documents'  is null.");
          }
            _context.Documents.Add(document);
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                if (DocumentExists(document.Id))
                {
                    return Conflict();
                }
                else
                {
                    throw;
                }
            }

            return CreatedAtAction("GetDocument", new { id = document.Id }, document);
        }

        // DELETE: api/Documents/5
        [HttpDelete("/api/Document/{id}")]
        public async Task<IActionResult> DeleteDocument(Guid id)
        {
            if (_context.Documents == null)
            {
                return NotFound();
            }
            var document = await _context.Documents.FindAsync(id);
            if (document == null)
            {
                return NotFound();
            }

            _context.Documents.Remove(document);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool DocumentExists(Guid id)
        {
            return (_context.Documents?.Any(e => e.Id == id)).GetValueOrDefault();
        }

    }
}
