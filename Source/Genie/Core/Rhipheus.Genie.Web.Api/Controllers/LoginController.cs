using Microsoft.AspNetCore.Mvc;
using Rhipheus.Genie.Api.Controllers;
using Rhipheus.Genie.Api.Models;
using Rhipheus.Genie.Web.Api.Services;

namespace Rhipheus.Genie.Web.Api.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class LoginController : ControllerBase
    {
        private readonly IFirstRunService _firstRunService;
        private readonly IWebHostEnvironment _env;

        public LoginController(IFirstRunService firstRunService, IWebHostEnvironment env)
        {
            _firstRunService = firstRunService;
            _env = env;
        }

        [HttpGet("/api/Login")]
        public ActionResult<bool> GetFirstRunStatus()
        {
            bool isFirstRun = _firstRunService.CheckFirstRun(_env);
            if (isFirstRun)
            {
                _firstRunService.DeleteFirstRunFile(_env);
            }
            return Ok(isFirstRun);
        }


    }
}
