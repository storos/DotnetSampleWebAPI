using Microsoft.AspNetCore.Mvc;

namespace DotnetSampleWebAPI.Controllers;

[ApiController]
[Route("[controller]")]
public class HealthCheckController : ControllerBase
{
    [HttpGet]
    public IActionResult Get()
    {
        return Ok(new { message = "everything ok" });
    }
}
