# Local Setup — Sedix

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Flutter SDK | ≥ 3.19 | https://flutter.dev/docs/get-started/install |
| .NET SDK | 8.0 | https://dotnet.microsoft.com/download/dotnet/8.0 |
| PostgreSQL | 16 | https://www.postgresql.org/download/ or Docker |
| Docker | any | https://www.docker.com/products/docker-desktop/ |

---

## 1. Clone the repository

```bash
git clone https://github.com/<your-user>/sedix.git
cd sedix
```

---

## 2. Start the database

Using Docker (recommended for local dev):

```bash
docker run --name sedix-db \
  -e POSTGRES_USER=sedix \
  -e POSTGRES_PASSWORD=sedix \
  -e POSTGRES_DB=sedix \
  -p 5432:5432 \
  -d postgres:16
```

---

## 3. Configure the backend

Copy and edit the local settings file:

```bash
cp backend/Sedix.API/appsettings.json \
   backend/Sedix.API/appsettings.Development.json
```

Edit `appsettings.Development.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=sedix;Username=sedix;Password=sedix"
  },
  "Jwt": {
    "Key": "your-super-secret-key-minimum-32-chars!!"
  }
}
```

> `appsettings.Development.json` is in `.gitignore` — never commit secrets.

---

## 4. Run database migrations

```bash
cd backend/Sedix.API
dotnet tool install --global dotnet-ef   # only once
dotnet ef database update
```

---

## 5. Start the backend

```bash
cd backend/Sedix.API
dotnet run
```

- API: http://localhost:5000
- Swagger UI: http://localhost:5000/swagger

---

## 6. Start the frontend

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

The app opens at http://localhost:3000 by default.

---

## Useful commands

| Command | Description |
|---------|-------------|
| `dotnet ef migrations add <Name>` | Create a new migration |
| `dotnet ef database update` | Apply pending migrations |
| `flutter pub run build_runner build` | Generate Riverpod code |
| `flutter analyze` | Lint Dart code |
| `flutter test` | Run unit tests |
| `dotnet test` | Run backend tests |

---

## Environment variables (production)

| Variable | Description |
|----------|-------------|
| `ConnectionStrings__DefaultConnection` | PostgreSQL connection string |
| `Jwt__Key` | JWT signing secret (min 32 chars) |
| `Jwt__Issuer` | Token issuer (default: `sedix-api`) |
| `Jwt__Audience` | Token audience (default: `sedix-client`) |
| `Cors__AllowedOrigins__0` | Frontend URL |
