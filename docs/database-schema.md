# Database Schema — Sedix

Database: PostgreSQL 16

---

## Tables

### `users`

| Column         | Type           | Constraints              |
|----------------|----------------|--------------------------|
| `id`           | `uuid`         | PK, default `gen_random_uuid()` |
| `name`         | `varchar(128)` | NOT NULL                 |
| `email`        | `varchar(256)` | NOT NULL, UNIQUE         |
| `password_hash`| `text`         | NOT NULL (bcrypt)        |
| `created_at`   | `timestamptz`  | NOT NULL, default now()  |

---

### `goals`

| Column          | Type           | Constraints              |
|-----------------|----------------|--------------------------|
| `id`            | `uuid`         | PK                       |
| `user_id`       | `uuid`         | FK → `users.id` CASCADE  |
| `name`          | `varchar(128)` | NOT NULL                 |
| `description`   | `text`         | NULL                     |
| `target_amount` | `numeric(18,2)`| NOT NULL                 |
| `deadline`      | `timestamptz`  | NULL                     |
| `emoji`         | `varchar(8)`   | NOT NULL, default '🏦'   |
| `created_at`    | `timestamptz`  | NOT NULL, default now()  |

---

### `transactions`

| Column     | Type           | Constraints              |
|------------|----------------|--------------------------|
| `id`       | `uuid`         | PK                       |
| `goal_id`  | `uuid`         | FK → `goals.id` CASCADE  |
| `amount`   | `numeric(18,2)`| NOT NULL                 |
| `type`     | `varchar(16)`  | NOT NULL (`Deposit` / `Withdrawal`) |
| `note`     | `text`         | NULL                     |
| `date`     | `timestamptz`  | NOT NULL, default now()  |

---

## Relationships

```
users ──< goals ──< transactions
 1        *     1       *
```

- One user can have many goals.
- One goal can have many transactions.
- Deleting a user cascades to goals and then to transactions.

---

## Notes

- `savedAmount` and `progress` are **not stored** — they are computed at query time from `SUM(transactions.amount)`.
- Withdrawals are stored as **negative amounts** in the `transactions` table.
- All `id` columns use UUID v4 generated at the application level (`Guid.NewGuid()`).
