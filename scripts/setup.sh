#!/usr/bin/env bash
# Bootstraps the local dev environment for Sedix.
set -euo pipefail

echo "==> Starting PostgreSQL via Docker..."
docker run --name sedix-db \
  -e POSTGRES_USER=sedix \
  -e POSTGRES_PASSWORD=sedix \
  -e POSTGRES_DB=sedix \
  -p 5432:5432 \
  -d postgres:16 2>/dev/null || echo "Container already running."

echo "==> Waiting for PostgreSQL to be ready..."
until docker exec sedix-db pg_isready -U sedix -q; do sleep 1; done

echo "==> Restoring .NET dependencies..."
dotnet restore backend/Sedix.sln

echo "==> Applying database migrations..."
(cd backend/Sedix.API && dotnet ef database update)

echo "==> Installing Flutter dependencies..."
(cd frontend && flutter pub get)

echo ""
echo "Setup complete."
echo "  Backend:  cd backend/Sedix.API && dotnet run"
echo "  Frontend: cd frontend && flutter run -d chrome"
