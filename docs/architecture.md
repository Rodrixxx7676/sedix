# Architecture — Sedix

## Overview

Sedix follows a **client-server** architecture with a clear separation between frontend, backend, and data layers.

```
┌─────────────────────────────────────────┐
│           Flutter Web (Browser)          │
│  ┌──────────┐  ┌──────────┐  ┌───────┐  │
│  │   Auth   │  │  Goals   │  │Dashboard│ │
│  └────┬─────┘  └────┬─────┘  └───┬───┘  │
│       │              │             │      │
│  ┌────▼─────────────▼─────────────▼──┐  │
│  │         Riverpod Providers         │  │
│  └────────────────┬───────────────────┘  │
│  ┌────────────────▼───────────────────┐  │
│  │     Dio HTTP Client (JWT Bearer)   │  │
│  └────────────────────────────────────┘  │
└─────────────────┬───────────────────────┘
                  │ HTTPS / REST
┌─────────────────▼───────────────────────┐
│          ASP.NET Core Web API            │
│  ┌───────────┐  ┌────────────────────┐  │
│  │Controllers│→ │  Services (BL)     │  │
│  └───────────┘  └────────┬───────────┘  │
│                  ┌────────▼───────────┐  │
│                  │ EF Core + Npgsql   │  │
│                  └────────────────────┘  │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│              PostgreSQL 16               │
│  users │ goals │ transactions            │
└─────────────────────────────────────────┘
```

## Layer Responsibilities

### Frontend (`frontend/`)

| Layer | Responsibility |
|-------|---------------|
| `features/*/screens` | UI pages, user interactions |
| `features/*/widgets` | Reusable UI components |
| `features/*/providers` | State management (Riverpod) |
| `features/*/models` | JSON deserialization, computed fields |
| `core/network` | HTTP client, auth token injection |
| `core/router` | Navigation, auth guards |
| `core/theme` | Colors, typography |

### Backend (`backend/Sedix.API/`)

| Layer | Responsibility |
|-------|---------------|
| `Controllers/` | HTTP routing, request validation, HTTP responses |
| `Services/` | Business logic, domain rules |
| `Models/` | EF Core entities |
| `DTOs/` | Request/response shapes (never expose models directly) |
| `Data/` | DbContext, migrations |
| `Middleware/` | Cross-cutting concerns (error handling) |
| `Extensions/` | DI service registration |

## Auth Flow

```
Client                          API
  │  POST /api/auth/login         │
  │──────────────────────────────►│
  │                               │  Verify password (bcrypt)
  │◄──────────────────────────────│
  │  { token: "eyJ..." }          │
  │                               │
  │  GET /api/goals               │
  │  Authorization: Bearer eyJ... │
  │──────────────────────────────►│
  │                               │  Validate JWT → extract userId
  │◄──────────────────────────────│
  │  [{ id, name, ... }]          │
```

## Key Design Decisions

- **No Repository pattern** — EF Core's `DbContext` is already a Unit of Work + Repository. Adding another abstraction layer would be premature for this app's scale.
- **Computed fields on models** — `SavedAmount`, `Progress`, `IsCompleted` are computed from `Transactions` in memory (not stored columns) to keep DB writes simple.
- **Riverpod over Bloc** — Riverpod's `AsyncNotifier` covers all async state needs without boilerplate.
- **JWT stored in SecureStorage** — Safer than `localStorage` for web; prevents XSS token theft.
