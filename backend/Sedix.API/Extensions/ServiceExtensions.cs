using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Sedix.API.Data;
using Sedix.API.Services;

namespace Sedix.API.Extensions;

public static class ServiceExtensions
{
    public static IServiceCollection AddDatabase(
        this IServiceCollection services, IConfiguration config) =>
        services.AddDbContext<AppDbContext>(opts =>
            opts.UseNpgsql(config.GetConnectionString("DefaultConnection")));

    public static IServiceCollection AddJwtAuth(
        this IServiceCollection services, IConfiguration config)
    {
        services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            .AddJwtBearer(opts =>
            {
                opts.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidateLifetime = true,
                    ValidateIssuerSigningKey = true,
                    ValidIssuer = config["Jwt:Issuer"],
                    ValidAudience = config["Jwt:Audience"],
                    IssuerSigningKey = new SymmetricSecurityKey(
                        Encoding.UTF8.GetBytes(config["Jwt:Key"]!)),
                    RoleClaimType = System.Security.Claims.ClaimTypes.Role,
                };
            });

        services.AddAuthorizationBuilder()
            .AddPolicy("AdminOnly", p => p.RequireRole("Admin"));

        return services;
    }

    public static IServiceCollection AddSwagger(this IServiceCollection services)
    {
        services.AddSwaggerGen(opts =>
        {
            opts.SwaggerDoc("v1", new OpenApiInfo
            {
                Title = "Sedix API",
                Version = "v1",
                Description = "Savings goal management API",
            });

            var jwtScheme = new OpenApiSecurityScheme
            {
                BearerFormat = "JWT",
                Name = "Authorization",
                In = ParameterLocation.Header,
                Type = SecuritySchemeType.Http,
                Scheme = JwtBearerDefaults.AuthenticationScheme,
                Reference = new OpenApiReference
                {
                    Id = JwtBearerDefaults.AuthenticationScheme,
                    Type = ReferenceType.SecurityScheme,
                },
            };

            opts.AddSecurityDefinition(jwtScheme.Reference.Id, jwtScheme);
            opts.AddSecurityRequirement(new OpenApiSecurityRequirement
            {
                { jwtScheme, Array.Empty<string>() }
            });
        });

        return services;
    }

    public static IServiceCollection AddAppServices(this IServiceCollection services)
    {
        services.AddScoped<ITokenService, TokenService>();
        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<IGoalService, GoalService>();
        services.AddScoped<IAdminService, AdminService>();
        services.AddScoped<IGeminiService, GeminiService>();
        return services;
    }
}
