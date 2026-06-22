using System.Text.Json.Serialization;

namespace Sedix.API.Services;

public interface IRecaptchaService
{
    Task<bool> VerifyAsync(string? token);
}

public class RecaptchaService(IConfiguration config) : IRecaptchaService
{
    private static readonly HttpClient _http = new();
    private readonly string _secret = config["Recaptcha:SecretKey"]!;

    public async Task<bool> VerifyAsync(string? token)
    {
        if (string.IsNullOrEmpty(token)) return false;

        var response = await _http.PostAsync(
            "https://www.google.com/recaptcha/api/siteverify",
            new FormUrlEncodedContent(new Dictionary<string, string>
            {
                ["secret"] = _secret,
                ["response"] = token,
            })
        );

        var result = await response.Content
            .ReadFromJsonAsync<RecaptchaResponse>();

        return result?.Success == true && result.Score >= 0.5f;
    }
}

file record RecaptchaResponse(
    [property: JsonPropertyName("success")] bool Success,
    [property: JsonPropertyName("score")] float Score
);
