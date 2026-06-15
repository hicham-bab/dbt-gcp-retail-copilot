# Demo state switching

This repo now supports two useful states for the live demo.

## 1. Demo start state

Use this state when you want the prompts to visibly do work live:
- `Q1.md` explains the legacy procedure
- `Q2.md` creates `models/marts/finance/mart_customer_ltv.sql`
- `Q3.md` fixes `models/marts/_refactor_me/mart_messy_revenue.sql`
- `Q4.md` extends the semantic layer and creates richer saved queries / exports

In demo start state:
- `models/marts/finance/mart_customer_ltv.sql` does **not** exist
- `models/marts/core/_core_models.yml` contains only the simpler baseline semantic config
- `analyses/validate_ltv_migration.sql` does **not** exist yet, because it depends on `mart_customer_ltv`

## 2. Reference / after state

Use this state when you want a safety net or want to restore the fully built answer key after the live demo.

Reference files are stored in `legacy/`:
- `legacy/mart_customer_ltv.reference.sql`
- `legacy/core_models.conversational_analytics.reference.yml`
- `legacy/validate_ltv_migration.reference.sql`

## Recommended live flow

1. Start from demo start state
2. Run `@Q1.md`
3. Run `@Q2.md`
4. Run `@Q3.md`
5. Run `@Q4.md`

## Optional parity step after Q2

If you want to show row-for-row parity after generating `mart_customer_ltv`, restore:

- `legacy/validate_ltv_migration.reference.sql` -> `analyses/validate_ltv_migration.sql`

Then validate with:

```text
dbt compile --select path:analyses/validate_ltv_migration.sql
```

## Switching from demo start state to reference / after state

Copy the contents of these reference files back into the live project files:

- `legacy/mart_customer_ltv.reference.sql` -> `models/marts/finance/mart_customer_ltv.sql`
- `legacy/core_models.conversational_analytics.reference.yml` -> `models/marts/core/_core_models.yml`
- `legacy/validate_ltv_migration.reference.sql` -> `analyses/validate_ltv_migration.sql`

Then validate with:

```text
dbt parse
dbt build --resource-type saved_query
```

## Switching from reference / after state back to demo start state

1. Remove `models/marts/finance/mart_customer_ltv.sql`
2. Remove `analyses/validate_ltv_migration.sql`
3. Restore the simpler baseline version of `models/marts/core/_core_models.yml`
4. Run `dbt parse`

## Notes

- Keep `models/marts/_refactor_me/mart_messy_revenue.sql` unchanged in the initial demo state.
- Keep `Q1.md` to `Q4.md` at the repo root for fast `@Q1.md`-style references during the live demo.
- The `legacy/` directory now acts as the answer-key store for the live demo.
