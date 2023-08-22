
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.OpenApi.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using Rhipheus.Genie.Api.Models;
using Rhipheus.Genie.Web.Api.Services;
using System.Text.Json.Serialization;
using System.Text.Json;
using Rhipheus.Genie.Core;
using Microsoft.AspNetCore.OData;
using Rhipheus.Genie.Api.Controllers;
using static Rhipheus.Genie.Api.Controllers.GenieController;
using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllersWithViews();

builder.Services.AddControllers().AddOData(options => options.SetMaxTop(50));

builder.Services.AddControllers()
        .AddJsonOptions(options =>
        {
            options.JsonSerializerOptions.DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingDefault;
            options.JsonSerializerOptions.ReferenceHandler=null; //ReferenceHandler.Preserve
            options.JsonSerializerOptions.WriteIndented = true;
            options.JsonSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
            options.JsonSerializerOptions.DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull;
            options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter());
            options.JsonSerializerOptions.Converters.Add(new ExpandoObjectConverter());
        });

//DefaultConnection
var configuration = new ConfigurationBuilder()
    .SetBasePath(builder.Environment.ContentRootPath)
    .AddJsonFile("appsettings.json")
    .Build();

var jwtSettings = configuration.GetSection("Jwt");
var key = Encoding.ASCII.GetBytes(jwtSettings.GetValue<string>("Key"));
builder.Services.AddAuthentication(x =>
{
    x.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    x.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(x =>
{
    x.RequireHttpsMetadata = false;
    x.SaveToken = true;
    x.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(key),
        ValidateIssuer = true,
        ValidIssuer = jwtSettings.GetValue<string>("Issuer"),
        ValidateAudience = true,
        ValidAudience = jwtSettings.GetValue<string>("Audience"),
        ValidateLifetime = true,
        ClockSkew = TimeSpan.Zero
    };
});

// Register your DbContext
builder.Services.AddDbContext<GenieContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("GenieConnection")));

// Add services to the container.
builder.Services.AddScoped<IFileUploadService, FileUploadService>();

builder.Services.AddSingleton<IFirstRunService, FirstRunService>();
builder.Services.AddSingleton<AzureQueueService>();

builder.Services.AddControllers();

var provider=builder.Services.BuildServiceProvider();


builder.Services.AddCors(options =>
{
    var frontendurl = builder.Configuration.GetValue<string>("frontend_url");
    //var frontendurls = configuration.GetSection("frontend_urls").Get<string[]>();
    options.AddDefaultPolicy(builder =>
    {
        builder.WithOrigins(frontendurl).AllowAnyMethod().AllowAnyHeader();
    });
});

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "Rhipheus Genie Web Api", Version = "v1" });
});


var app = builder.Build();

var firstRunService = app.Services.GetRequiredService<IFirstRunService>();
firstRunService.CheckFirstRun(builder.Environment);

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Rhipheus Genie Web Api V1");
    });

}

app.UseHttpsRedirection();
app.UseCors();
app.UseRouting();
app.UseAuthentication(); 
app.UseAuthorization();

app.MapControllers();


app.Run();
