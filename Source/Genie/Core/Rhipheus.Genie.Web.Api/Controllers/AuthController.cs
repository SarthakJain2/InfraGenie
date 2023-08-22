using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Text;
using Rhipheus.Genie.Api.Models;
using Microsoft.EntityFrameworkCore;


namespace Rhipheus.Genie.Web.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : Controller
    {
        private readonly IConfiguration _configuration;
        private readonly GenieContext _context;

        public AuthController(IConfiguration configuration, GenieContext context)
        {
            _configuration = configuration;
            _context = context;
        }

        [HttpPost]
        public IActionResult Authenticate(Tenant tenant)
        {
            if (IsValidUser(tenant))
            {
                var token = GenerateToken(tenant);
                return Ok(new { token });
            }

            return Unauthorized();
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

        private bool IsValidUser(Tenant tenant)
        {
            return _context.Tenants.Any(t => t.Id == tenant.Id);
        }
    }
}
