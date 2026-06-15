# API Reference — Sedix

Base URL: `http://localhost:5000/api` (dev) · `https://api.sedix.app/api` (prod)

All endpoints except `/auth/*` require:
```
Authorization: Bearer <jwt_token>
```

---

## Auth

### POST `/auth/register`

Creates a new user account and returns a JWT.

**Body**
```json
{
  "name": "Francisco",
  "email": "francisco@example.com",
  "password": "mysecurepassword"
}
```

**201 Created**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "name": "Francisco",
  "email": "francisco@example.com"
}
```

**409 Conflict** — email already registered.

---

### POST `/auth/login`

**Body**
```json
{
  "email": "francisco@example.com",
  "password": "mysecurepassword"
}
```

**200 OK** — same shape as register.

**401 Unauthorized** — invalid credentials.

---

## Goals

### GET `/goals`

Returns all goals for the authenticated user.

**200 OK**
```json
[
  {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "name": "New Backpack",
    "description": null,
    "targetAmount": 130.00,
    "savedAmount": 45.00,
    "progress": 34.6,
    "isCompleted": false,
    "deadline": "2026-12-31T00:00:00Z",
    "emoji": "🎒",
    "createdAt": "2026-06-14T00:00:00Z"
  }
]
```

---

### POST `/goals`

**Body**
```json
{
  "name": "PlayStation 5 Pro",
  "description": "Save for the new PS5",
  "targetAmount": 699.99,
  "deadline": "2026-12-25T00:00:00Z",
  "emoji": "🎮"
}
```

**201 Created** — returns the created goal.

---

### GET `/goals/{id}`

**200 OK** — single goal object.
**404 Not Found**

---

### PATCH `/goals/{id}`

Partially updates a goal. All fields optional.

**Body**
```json
{
  "name": "PS5 Pro Bundle",
  "targetAmount": 799.99
}
```

**200 OK** — updated goal.

---

### DELETE `/goals/{id}`

**204 No Content**
**404 Not Found**

---

### POST `/goals/{id}/transactions`

Adds a deposit or withdrawal to a goal.

**Body**
```json
{
  "amount": 50.00,
  "type": "deposit",
  "note": "Weekly allowance"
}
```

`type` accepts `"deposit"` or `"withdrawal"`.

**200 OK** — updated goal with new totals.

---

### GET `/goals/{id}/transactions`

Returns transaction history for a goal.

**200 OK**
```json
[
  {
    "id": "...",
    "amount": 50.00,
    "type": "Deposit",
    "note": "Weekly allowance",
    "date": "2026-06-14T20:00:00Z"
  }
]
```

---

## Error Format

All errors return:

```json
{
  "error": "Human-readable error message"
}
```

| Status | Meaning |
|--------|---------|
| 400 | Validation error |
| 401 | Not authenticated / bad credentials |
| 404 | Resource not found |
| 409 | Conflict (e.g. duplicate email) |
| 500 | Unexpected server error |
