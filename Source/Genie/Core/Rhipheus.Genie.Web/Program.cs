using Microsoft.AspNetCore.Builder;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorPages();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
   
}

app.UseHttpsRedirection();

app.Use(async (context, next) =>
{
    await next();

    // If there's no available file and the request doesn't contain an extension, assume it's a route and return the React index.html file
    if (context.Response.StatusCode == 404 && !Path.HasExtension(context.Request.Path.Value))
    {
        context.Request.Path = "/index.html";
        await next();
    }
});

// Serve React files from the wwwroot folder
app.UseDefaultFiles(); // This will serve index.html as the default file
app.UseStaticFiles(); // This will serve other static files, such as CSS and JavaScript files

app.UseRouting();

app.UseAuthorization();

app.MapRazorPages();

app.Run();
