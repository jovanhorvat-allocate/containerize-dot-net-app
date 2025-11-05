using Microsoft.AspNetCore.Mvc;
using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.Model;
using Amazon.DynamoDBv2.DocumentModel;
using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);

// Add CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

builder.Services.AddControllers();

// Configure DynamoDB
var dynamoDbEndpoint = Environment.GetEnvironmentVariable("DYNAMODB_ENDPOINT") ?? "http://localhost:8000";
var dynamoConfig = new AmazonDynamoDBConfig
{
    ServiceURL = dynamoDbEndpoint
};
builder.Services.AddSingleton<IAmazonDynamoDB>(new AmazonDynamoDBClient("dummy", "dummy", dynamoConfig));

var app = builder.Build();

app.UseCors("AllowAll");
app.UseAuthorization();

// Initialize database
await InitializeDatabase(app.Services.GetRequiredService<IAmazonDynamoDB>());

// Health check
app.MapGet("/health", () => Results.Ok(new { status = "healthy", message = ".NET Todo API is running" }));

// Get all todos
app.MapGet("/todos", async (IAmazonDynamoDB dynamoDb) =>
{
    try
    {
        var table = Table.LoadTable(dynamoDb, "todos");
        var search = table.Scan(new ScanFilter());
        var documents = await search.GetRemainingAsync();
        
        var todos = documents.Select(doc => new
        {
            id = doc["id"].AsString(),
            title = doc.ContainsKey("title") ? doc["title"].AsString() : "",
            completed = doc.ContainsKey("completed") ? doc["completed"].AsBoolean() : false,
            createdAt = doc.ContainsKey("createdAt") ? doc["createdAt"].AsString() : DateTime.UtcNow.ToString("o")
        }).OrderBy(t => t.createdAt).ToList();
        
        return Results.Ok(new { success = true, todos, count = todos.Count });
    }
    catch (Exception ex)
    {
        return Results.Json(new { success = false, error = ex.Message }, statusCode: 500);
    }
});

// Get single todo
app.MapGet("/todos/{id}", async (string id, IAmazonDynamoDB dynamoDb) =>
{
    try
    {
        var table = Table.LoadTable(dynamoDb, "todos");
        var document = await table.GetItemAsync(id);
        
        if (document == null)
        {
            return Results.Json(new { success = false, error = "Todo not found" }, statusCode: 404);
        }
        
        var todo = new
        {
            id = document["id"].AsString(),
            title = document.ContainsKey("title") ? document["title"].AsString() : "",
            completed = document.ContainsKey("completed") ? document["completed"].AsBoolean() : false,
            createdAt = document.ContainsKey("createdAt") ? document["createdAt"].AsString() : DateTime.UtcNow.ToString("o")
        };
        
        return Results.Ok(new { success = true, todo });
    }
    catch (Exception ex)
    {
        return Results.Json(new { success = false, error = ex.Message }, statusCode: 500);
    }
});

// Create todo
app.MapPost("/todos", async (HttpContext context, IAmazonDynamoDB dynamoDb) =>
{
    try
    {
        var body = await JsonSerializer.DeserializeAsync<Dictionary<string, JsonElement>>(context.Request.Body);
        
        if (body == null || !body.ContainsKey("title") || string.IsNullOrWhiteSpace(body["title"].GetString()))
        {
            return Results.Json(new { success = false, error = "Title is required" }, statusCode: 400);
        }
        
        var id = Guid.NewGuid().ToString();
        var title = body["title"].GetString()!;
        var completed = body.ContainsKey("completed") && body["completed"].GetBoolean();
        var createdAt = DateTime.UtcNow.ToString("o");
        
        var table = Table.LoadTable(dynamoDb, "todos");
        var document = new Document
        {
            ["id"] = id,
            ["title"] = title,
            ["completed"] = completed,
            ["createdAt"] = createdAt
        };
        
        await table.PutItemAsync(document);
        
        return Results.Json(new
        {
            success = true,
            message = "Todo created successfully",
            todo = new { id, title, completed, createdAt }
        }, statusCode: 201);
    }
    catch (Exception ex)
    {
        return Results.Json(new { success = false, error = ex.Message }, statusCode: 500);
    }
});

// Update todo
app.MapPut("/todos/{id}", async (string id, HttpContext context, IAmazonDynamoDB dynamoDb) =>
{
    try
    {
        var body = await JsonSerializer.DeserializeAsync<Dictionary<string, JsonElement>>(context.Request.Body);
        
        if (body == null)
        {
            return Results.Json(new { success = false, error = "Request body is required" }, statusCode: 400);
        }
        
        var table = Table.LoadTable(dynamoDb, "todos");
        
        // Get existing item
        var existing = await table.GetItemAsync(id);
        if (existing == null)
        {
            return Results.Json(new { success = false, error = "Todo not found" }, statusCode: 404);
        }
        
        // Update fields
        if (body.ContainsKey("title"))
            existing["title"] = body["title"].GetString() ?? existing["title"].AsString();
        
        if (body.ContainsKey("completed"))
            existing["completed"] = body["completed"].GetBoolean();
        
        existing["updatedAt"] = DateTime.UtcNow.ToString("o");
        
        await table.PutItemAsync(existing);
        
        var updatedTodo = new
        {
            id = existing["id"].AsString(),
            title = existing["title"].AsString(),
            completed = existing["completed"].AsBoolean(),
            createdAt = existing.ContainsKey("createdAt") ? existing["createdAt"].AsString() : "",
            updatedAt = existing["updatedAt"].AsString()
        };
        
        return Results.Ok(new { success = true, message = "Todo updated successfully", todo = updatedTodo });
    }
    catch (Exception ex)
    {
        return Results.Json(new { success = false, error = ex.Message }, statusCode: 500);
    }
});

// Delete todo
app.MapDelete("/todos/{id}", async (string id, IAmazonDynamoDB dynamoDb) =>
{
    try
    {
        var table = Table.LoadTable(dynamoDb, "todos");
        
        // Check if exists
        var existing = await table.GetItemAsync(id);
        if (existing == null)
        {
            return Results.Json(new { success = false, error = "Todo not found" }, statusCode: 404);
        }
        
        await table.DeleteItemAsync(id);
        
        return Results.Ok(new { success = true, message = "Todo deleted successfully" });
    }
    catch (Exception ex)
    {
        return Results.Json(new { success = false, error = ex.Message }, statusCode: 500);
    }
});

app.Run();

async Task InitializeDatabase(IAmazonDynamoDB dynamoDb)
{
    var tableName = "todos";
    
    try
    {
        await dynamoDb.DescribeTableAsync(tableName);
        Console.WriteLine($"Table {tableName} already exists");
    }
    catch (ResourceNotFoundException)
    {
        Console.WriteLine($"Creating table {tableName}");
        
        var request = new CreateTableRequest
        {
            TableName = tableName,
            KeySchema = new List<KeySchemaElement>
            {
                new KeySchemaElement { AttributeName = "id", KeyType = KeyType.HASH }
            },
            AttributeDefinitions = new List<AttributeDefinition>
            {
                new AttributeDefinition { AttributeName = "id", AttributeType = ScalarAttributeType.S }
            },
            BillingMode = BillingMode.PAY_PER_REQUEST
        };
        
        await dynamoDb.CreateTableAsync(request);
        
        // Wait for table to be active
        var tableActive = false;
        while (!tableActive)
        {
            await Task.Delay(1000);
            var describeResponse = await dynamoDb.DescribeTableAsync(tableName);
            tableActive = describeResponse.Table.TableStatus == TableStatus.ACTIVE;
        }
        
        Console.WriteLine($"Table {tableName} created successfully");
    }
}
