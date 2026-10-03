using Microsoft.Data.SqlClient;

var builder = WebApplication.CreateBuilder(args);

// Adiciona uma página simples que testa a conexão ao SQL
builder.Services.AddRazorPages();

var app = builder.Build();

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseRouting();
app.MapRazorPages();

app.MapGet("/", async (HttpContext http) =>
{
    var connString = Environment.GetEnvironmentVariable("AZURE_SQL_CONNECTIONSTRING");
    var apiKey = Environment.GetEnvironmentVariable("API_DEMO_KEY");

    if (string.IsNullOrWhiteSpace(connString))
    {
        await http.Response.WriteAsJsonAsync(new
        {
            error = "Connection string AZURE_SQL_CONNECTIONSTRING não encontrada."
        });
        return;
    }

    try
    {
        await using var conn = new SqlConnection(connString);
        await conn.OpenAsync();

        await http.Response.WriteAsJsonAsync(new
        {
            status = "Conectado ao SQL com sucesso",
            database = conn.Database,
            dataSource = conn.DataSource
            apiKeyPresent = !string.IsNullOrWhiteSpace(apiKey)
        });
    }
    catch (Exception ex)
    {
        await http.Response.WriteAsJsonAsync(new
        {
            error = "Falha ao conectar ao SQL",
            message = ex.Message
        });
    }
});

app.Run();