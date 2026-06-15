using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Sedix.API.DTOs;
using Sedix.API.Services;

namespace Sedix.API.Controllers;

[ApiController]
[Route("api/ai")]
[Authorize]
public class AiController(IGeminiService geminiService) : ControllerBase
{
    private Guid UserId =>
        Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

    [HttpPost("advice")]
    [ProducesResponseType(typeof(AiAdviceResponse), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAdvice([FromBody] AiAdviceRequest req) =>
        Ok(await geminiService.GetAdviceAsync(UserId, req));
}
