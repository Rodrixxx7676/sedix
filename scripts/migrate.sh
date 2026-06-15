#!/usr/bin/env bash
# Creates and applies a new EF Core migration.
# Usage: ./scripts/migrate.sh <MigrationName>
set -euo pipefail

NAME="${1:?Usage: ./scripts/migrate.sh <MigrationName>}"

echo "==> Creating migration: $NAME"
(cd backend/Sedix.API && dotnet ef migrations add "$NAME")

echo "==> Applying migration..."
(cd backend/Sedix.API && dotnet ef database update)

echo "Migration '$NAME' applied successfully."
