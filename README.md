# GreenField Retail — dbt + BigQuery + dbt Wizard (Gemini)

A demo dbt project for the **dbt + Google Cloud** webinar. It showcases the
**dbt Wizard CLI** — running with **Google Gemini (BYOK)** against **BigQuery** —
on a realistic retail project with staging, intermediate, and mart layers.

## What's in here
- **30 models** across `staging` → `intermediate` → `marts` (core / finance / marketing / inventory)
- **10 seed tables** of synthetic retail data (customers, orders, items, payments, products, inventory, web sessions, marketing spend)
- **A legacy BigQuery stored procedure** (`legacy/sp_customer_ltv.sql`) you can migrate into dbt
- **An intentionally messy model** (`models/marts/_refactor_me/mart_messy_revenue.sql`) you can diagnose and refactor
- Fusion-conformant SQL (`cast()` only, `arguments:` test spec, `require-dbt-version: >=1.9`)

## Get started
- `SETUP.md` — BigQuery connection, `dbt build`, and dbt Wizard + Gemini install/config
- `PROMPTS_FR.md` — French prompts for the live workflow

```bash
dbt deps && dbt seed && dbt build
wizard
```

## Layout
```
seeds/                     10 raw_* synthetic tables
legacy/sp_customer_ltv.sql legacy BigQuery stored procedure
models/
  staging/                 typed, cleaned 1:1 with raw
  intermediate/            business-logic building blocks
  marts/
    core/                  dim_* and fct_* models
    finance/               marts for finance use cases
    marketing/             web sessions, spend, attribution
    inventory/             daily inventory + health
    _refactor_me/          mart_messy_revenue (refactor target)
scripts/generate_seeds.py  deterministic data generator
```

## Notes
- **Gemini runs via the dbt Wizard CLI (BYOK).** The dbt platform UI and in-IDE generate buttons currently support OpenAI/Azure only.
- The project is set up so you can demonstrate migration, lineage, docs/tests, and semantic layer authoring on top of existing dbt assets.
