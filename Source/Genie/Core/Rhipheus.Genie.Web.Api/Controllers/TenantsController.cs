using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Rhipheus.Genie.Api.Models;

namespace Rhipheus.Genie.Web.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class TenantsController : ControllerBase
    {
        private readonly IConfiguration _configuration;
        private readonly GenieContext _context;

        public TenantsController(GenieContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        // GET: api/Tenants
        [HttpGet]
        [Authorize]

        public ActionResult<IQueryable<Tenant>> GetTenants()
        {
          if (_context.Tenants == null)
          {
              return NotFound();
          }
            return  _context.Tenants;
        }

        // GET: api/Tenants/5
        [HttpGet("/api/Tenant/{id}")]
        public async Task<ActionResult<Tenant>> GetTenant(Guid id)
        {
          if (_context.Tenants == null)
          {
              return NotFound();
          }
            var tenant = await _context.Tenants.FindAsync(id);

            if (tenant == null)
            {
                return NotFound();
            }

            return tenant;
        }

        // PUT: api/Tenants/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("/api/Tenant/{id}")]
        public async Task<IActionResult> PutTenant(Guid id, Tenant tenant)
        {
            if (id != tenant.Id)
            {
                return BadRequest();
            }

            _context.Entry(tenant).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!TenantExists(id))
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

        // POST: api/Tenants
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost("/api/Tenant/")]
        public async Task<ActionResult<Tenant>> PostTenant()
        {
          if (_context.Tenants == null)
          {
              return Problem("Entity set 'GenieContext.Tenants'  is null.");
          }

            Tenant tenant = new Tenant
            {
                Id = Guid.NewGuid(),
                // Set other properties of the tenant as needed.
            };

            _context.Tenants.Add(tenant);
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                if (TenantExists(tenant.Id))
                {
                    return Conflict();
                }
                else
                {
                    throw;
                }
            }

            return CreatedAtAction("GetTenant", new { id = tenant.Id }, tenant);
        }

        // DELETE: api/Tenants/5
        [HttpDelete("/api/Tenant/{id}")]
        public async Task<IActionResult> DeleteTenant(Guid id)
        {
            if (_context.Tenants == null)
            {
                return NotFound();
            }
            var tenant = await _context.Tenants.FindAsync(id);
            if (tenant == null)
            {
                return NotFound();
            }

            _context.Tenants.Remove(tenant);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool TenantExists(Guid id)
        {
            return (_context.Tenants?.Any(e => e.Id == id)).GetValueOrDefault();
        }
        private string GenerateToken(Tenant tenant)
        {
            var jwtSettings = _configuration.GetSection("Jwt");
            var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSettings.GetSection("Key").Value));
            var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);
            var token = new JwtSecurityToken(
                issuer: jwtSettings.GetSection("Issuer").Value,
                audience: jwtSettings.GetSection("Audience").Value,
                expires: DateTime.Now.AddHours(1),
                signingCredentials: credentials);
            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}
