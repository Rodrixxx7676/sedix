using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Sedix.API.DTOs;
using Sedix.API.Services;

namespace Sedix.API.Controllers;

[ApiController]
[Route("api/admin")]
[Authorize(Roles = "Admin")]
public class AdminController(IAdminService adminService) : ControllerBase
{
    [HttpGet("stats")]
    [ProducesResponseType(typeof(GlobalStatsResponse), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetStats() =>
        Ok(await adminService.GetGlobalStatsAsync());

    [HttpGet("users")]
    [ProducesResponseType(typeof(List<UserSummaryResponse>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetUsers() =>
        Ok(await adminService.GetAllUsersAsync());

    [HttpPatch("users/{id:guid}/role")]
    [ProducesResponseType(typeof(UserSummaryResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateRole(Guid id, [FromBody] UpdateRoleRequest req) =>
        Ok(await adminService.UpdateRoleAsync(id, req));

    [HttpDelete("users/{id:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> DeleteUser(Guid id)
    {
        await adminService.DeleteUserAsync(id);
        return NoContent();
    }
}
