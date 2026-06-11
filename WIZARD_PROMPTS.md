# dbt Wizard prompts — GreenField Retail on BigQuery

These are copy/paste prompts for the **dbt Wizard CLI**, running with **Google Gemini (BYOK)** against **BigQuery**. They follow the webinar arc: migrate a legacy stored procedure into a governed dbt model, auto-generate its docs and tests, then fix and refactor a messy model.

> Terminology: **dbt Wizard** is the agentic AI assistant (CLI + dbt platform). The CLI is the variant that supports **Google Gemini** via bring-your-own-key. (dbt Copilot — the in-IDE generate buttons — currently supports only OpenAI/Azure, so the Gemini story lives in the Wizard CLI.)

Start the assistant from the project root:

```bash
cd dbt-gcp-retail-copilot
wizard
```

Confirm Gemini is the active provider/model inside the TUI:

```
/model
```

---

## Act 1 — Migrate a BigQuery stored procedure to a dbt model

The legacy procedure lives at `legacy/sp_customer_ltv.sql`. It rebuilds `analytics.customer_ltv` every night with temp tables and procedural SQL.

**Prompt 1.1 — understand the legacy procedure**
```
Read legacy/sp_customer_ltv.sql. Explain in plain English what this BigQuery
stored procedure computes, what its output grain is, and list every source
table and business rule (segmentation thresholds, recency/tenure logic).
```

**Prompt 1.2 — propose the migration**
```
I want to migrate legacy/sp_customer_ltv.sql into a dbt model. This project
already has staging and intermediate models over the same raw tables. Inspect
models/staging and models/intermediate and tell me which existing models I
should build on instead of re-reading raw tables. Propose a target file path
and the CTE structure before writing any SQL.
```

**Prompt 1.3 — generate the model**
```
Create models/marts/finance/mart_customer_ltv.sql as a dbt model that
reproduces the logic of sp_customer_ltv exactly, but:
- use ref() to int_customer_order_summary and stg_customers instead of raw tables
- BigQuery dialect, dbt Fusion conformant (use cast(... as ...), no :: casts)
- keep the same output columns, segmentation thresholds, and lifecycle rules
- only include customers with at least one completed order
Then run `dbt build -s mart_customer_ltv` and fix anything that fails.
```

**Prompt 1.4 — prove parity (optional but a killer demo beat)**
```
Compile analyses/validate_ltv_migration.sql and explain how I'd use it to
prove the dbt model matches the legacy procedure's output row-for-row.
```

> Safety net: a reference solution already exists at `models/marts/finance/mart_customer_ltv.sql`. If you want a clean live build, rename or delete it first, then let Wizard regenerate it. See `DEMO_SCRIPT.md`.

---

## Act 2 — Auto-generate documentation and tests

`mart_customer_ltv` is intentionally shipped with **no** YAML docs or tests.

**Prompt 2.1 — generate docs**
```
Generate a dbt YAML properties file for mart_customer_ltv with a model
description and a description for every column. Infer meaning from the SQL.
Write it to models/marts/finance/_finance_models.yml without removing the
existing mart_daily_sales entry.
```

**Prompt 2.2 — generate tests**
```
Add appropriate dbt data tests to mart_customer_ltv: unique + not_null on the
grain, accepted_values on ltv_segment and lifecycle_stage, and a relationships
test from customer_id to dim_customers. Use the Fusion test spec with arguments:
nested under each test. Then run `dbt test -s mart_customer_ltv`.
```

**Prompt 2.3 — backfill the gap project-wide (shows scale)**
```
Scan all models under models/marts and list any model that is missing a
description or has columns without descriptions. Draft docs for the gaps.
```

---

## Act 3 — Fix and refactor

`models/marts/_refactor_me/mart_messy_revenue.sql` builds, but Finance says the weekly revenue is too high.

**Prompt 3.1 — diagnose the bug**
```
Finance says mart_messy_revenue overstates weekly revenue. Read the model and
identify the root cause. Pay attention to the join fan-out and the order status
filter. Explain the bug and quantify why the number is inflated.
```

**Prompt 3.2 — fix + refactor**
```
Refactor mart_messy_revenue.sql:
- fix the payments fan-out so revenue isn't multiplied by line-item count
- only count completed orders as revenue
- rewrite into readable CTEs, build on ref() models (fct_orders), drop the
  correlated subquery and SELECT *
- BigQuery + Fusion conformant
Keep the output grain (year, week, channel, region). Then run
`dbt build -s mart_messy_revenue` and show me the before/after row counts.
```

**Prompt 3.3 — optimize for BigQuery cost (Google-audience favorite)**
```
Review fct_orders and fct_order_items for BigQuery cost and performance. Suggest
partitioning and clustering keys for these tables and show me the dbt config()
block to add. Explain the expected impact on bytes scanned.
```

---

## Bonus prompts (keep in your back pocket)

**Explain lineage**
```
What downstream models depend on stg_orders? If I change order_status to an
enum, what breaks?
```

**Build a net-new model from a business question**
```
Create a new mart that returns monthly revenue retention by signup cohort.
Build on the existing marts, BigQuery + Fusion conformant, and add it to the
finance folder with docs and tests.
```

**Natural-language analytics**
```
Using the built models, what were the top 5 product departments by gross margin
in the last full quarter? Write the BigQuery SQL and run it with dbt show.
```

**Self-review before commit**
```
Review all the changes you just made for dbt best practices and Fusion
conformance, then summarize them as a PR description.
```

---

## Sources
- [Get started in dbt platform / enable dbt AI](https://docs.getdbt.com/docs/platform/enable-dbt-ai)
- [About dbt Wizard CLI](https://docs.getdbt.com/docs/dbt-ai/about-dbt-wizard-cli)
- [Configure BYOK for dbt Wizard](https://docs.getdbt.com/docs/dbt-ai/wizard-byok)
- [Get started with the dbt Wizard local CLI](https://docs.getdbt.com/docs/dbt-ai/wizard-quickstart)
