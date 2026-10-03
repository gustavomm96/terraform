using Microsoft.Data.SqlClient;

var builder = WebApplication.CreateBuilder(args);

// Não usamos Razor Pages neste lab, só o endpoint de API
// builder.Services.AddRazorPages();

var app = builder.Build();

// Endpoint que testa SQL e mostra se o segredo do Key Vault está disponível
app.MapGet("/api/status", async (HttpContext http) =>
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
            dataSource = conn.DataSource,
            apiKeyPresent = !string.IsNullOrWhiteSpace(apiKey),
            apiKeyValue = apiKey
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

// Opcional: se quiser que a raiz "/" redirecione para /api/status
app.MapGet("/", () => Results.Redirect("/api/status"));

app.Run();