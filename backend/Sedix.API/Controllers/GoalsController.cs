using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Sedix.API.DTOs;
using Sedix.API.Services;

namespace Sedix.API.Controllers;

[ApiController]
[Route("api/goals")]
[Authorize]
public class GoalsController(IGoalService goalService) : ControllerBase
{
    private Guid UserId =>
        Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

    [HttpGet]
    [ProducesResponseType(typeof(List<GoalResponse>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAll() =>
        Ok(await goalService.GetAllAsync(UserId));

    [HttpGet("{id:guid}")]
    [ProducesResponseType(typeof(GoalResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetById(Guid id) =>
        Ok(await goalService.GetByIdAsync(UserId, id));

    [HttpPost]
    [ProducesResponseType(typeof(GoalResponse), StatusCodes.Status201Created)]
    public async Task<IActionResult> Create([FromBody] CreateGoalRequest req)
    {
        var goal = await goalService.CreateAsync(UserId, req);
        return CreatedAtAction(nameof(GetById), new { id = goal.Id }, goal);
    }

    [HttpPatch("{id:guid}")]
    [ProducesResponseType(typeof(GoalResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateGoalRequest req) =>
        Ok(await goalService.UpdateAsync(UserId, id, req));

    [HttpDelete("{id:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Delete(Guid id)
    {
        await goalService.DeleteAsync(UserId, id);
        return NoContent();
    }

    [HttpPost("{id:guid}/transactions")]
    [ProducesResponseType(typeof(GoalResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> AddTransaction(
        Guid id, [FromBody] AddTransactionRequest req) =>
        Ok(await goalService.AddTransactionAsync(UserId, id, req));

    [HttpGet("{id:guid}/transactions")]
    [ProducesResponseType(typeof(List<TransactionResponse>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetTransactions(Guid id) =>
        Ok(await goalService.GetTransactionsAsync(UserId, id));
}
