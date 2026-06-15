# Sedix — Save with purpose

Sedix is a personal savings web app that helps users define goals, track contributions, and visualize progress toward financial milestones.

## Tech Stack

| Layer     | Technology                              |
|-----------|-----------------------------------------|
| Frontend  | Flutter Web (Dart)                      |
| Backend   | C# .NET 8 · ASP.NET Core Web API        |
| Database  | PostgreSQL 16                           |
| Auth      | JWT Bearer Tokens                       |
| CI/CD     | GitHub Actions                          |

## Repository Structure

```
sedix/
├── .github/
│   └── workflows/         # CI pipelines
├── backend/
│   └── Sedix.API/         # ASP.NET Core project
│       ├── Controllers/   # HTTP endpoints
│       ├── Models/        # Domain entities
│       ├── DTOs/          # Request / response shapes
│       ├── Services/      # Business logic
│       ├── Repositories/  # Data access layer
│       ├── Data/          # EF Core DbContext + migrations
│       ├── Middleware/    # Error handling, auth
│       └── Extensions/    # DI service registration
├── frontend/              # Flutter Web project
│   ├── lib/
│   │   ├── app/           # Root widget, MaterialApp
│   │   ├── core/          # Theme, router, network, utils
│   │   ├── features/      # auth | goals | savings
│   │   └── shared/        # Reusable widgets, constants
│   ├── assets/
│   └── web/               # index.html, manifest
├── docs/
│   ├── architecture.md
│   ├── api-reference.md
│   ├── database-schema.md
│   └── setup.md
└── scripts/               # Dev helpers (setup, migrate)
```

## Quick Start

> Full instructions: [`docs/setup.md`](docs/setup.md)

### Prerequisites

- Flutter SDK ≥ 3.19
- .NET SDK 8.0
- PostgreSQL 16
- Docker (optional, for local DB)

### 1 — Database (Docker)

```bash
docker run --name sedix-db \
  -e POSTGRES_USER=sedix \
  -e POSTGRES_PASSWORD=sedix \
  -e POSTGRES_DB=sedix \
  -p 5432:5432 -d postgres:16
```

### 2 — Backend

```bash
cd backend/Sedix.API
cp appsettings.json appsettings.Development.json   # edit connection string
dotnet restore
dotnet ef database update
dotnet run
# → https://localhost:5001/swagger
```

### 3 — Frontend

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

## Documentation

| Document | Description |
|----------|-------------|
| [`docs/architecture.md`](docs/architecture.md) | System design and layer responsibilities |
| [`docs/api-reference.md`](docs/api-reference.md) | All REST endpoints with request/response examples |
| [`docs/database-schema.md`](docs/database-schema.md) | Tables, columns, relationships |
| [`docs/setup.md`](docs/setup.md) | Step-by-step local dev environment setup |

## License

MIT
