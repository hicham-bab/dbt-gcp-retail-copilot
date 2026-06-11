# GreenField Retail — dbt + BigQuery + dbt Wizard (Gemini)

A demo dbt project for the **dbt + Google Cloud** webinar. It showcases the
**dbt Wizard CLI** — running on **Google Gemini (BYOK)** against **BigQuery** —
modernizing a retail warehouse: migrating a legacy stored procedure into a
governed dbt model, generating docs and tests, and fixing/refactoring on demand.

## What's in here
- **30 models** across `staging` → `intermediate` → `marts` (core / finance / marketing / inventory)
- **10 seed tables** of synthetic retail data (customers, orders, items, payments, products, inventory, web sessions, marketing spend) — the project `dbt build`s end-to-end in BigQuery
- **A legacy BigQuery stored procedure** (`legacy/sp_customer_ltv.sql`) — the migration source material
- **An intentionally messy model** (`models/marts/_refactor_me/mart_messy_revenue.sql`) with a real revenue bug — the fix/refactor target
- Fusion-conformant SQL (`cast()` only, `arguments:` test spec, `require-dbt-version: >=1.9`)

## Demo flow
1. **Migrate** — turn `sp_customer_ltv` into `mart_customer_ltv` (governed, `ref()`-based, Fusion-conformant)
2. **Document & test** — auto-generate the model's YAML docs and data tests
3. **Fix & refactor** — diagnose and repair the inflated revenue model, then optimize for BigQuery cost

## Get started
- `SETUP.md` — BigQuery connection, `dbt build`, and dbt Wizard + Gemini install/config
- `WIZARD_PROMPTS.md` — copy/paste prompts for each act
- `DEMO_SCRIPT.md` — the live runbook with timings, talk track, and fallbacks

```bash
dbt deps && dbt seed && dbt build      # build the warehouse
wizard                                  # drive it with Gemini
```

## Layout
```
seeds/                     10 raw_* synthetic tables
legacy/sp_customer_ltv.sql legacy BigQuery stored procedure (migration source)
models/
  staging/                 typed, cleaned 1:1 with raw
  intermediate/            ephemeral business-logic building blocks
  marts/
    core/                  dim_* and fct_* (orders, items, payments, customers, products, stores, dates)
    finance/               mart_daily_sales, mart_customer_ltv (migration target)
    marketing/             web sessions, spend, attribution
    inventory/             daily inventory + health
    _refactor_me/          mart_messy_revenue (fix/refactor target)
analyses/                  validate_ltv_migration.sql (parity check)
scripts/generate_seeds.py  deterministic data generator
```

## Notes
- **Gemini runs via the dbt Wizard CLI (BYOK).** The dbt platform UI and dbt Copilot's in-IDE buttons currently support OpenAI/Azure only — so the Gemini-on-GCP story lives in the CLI. See `SETUP.md`.
- **Optional extension:** add a dbt Semantic Layer (semantic models + metrics on `fct_orders`) if you want to demo `dbt sl query` / Ask dbt as a follow-on. Left out here to keep the build dependency-light.
