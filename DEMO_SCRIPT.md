# Webinar runbook — dbt Wizard + Gemini on BigQuery

**Audience:** Google Cloud webinar. **Story:** a retail data team uses dbt Wizard (powered by Gemini, BYOK) to modernize a BigQuery warehouse — migrate legacy stored procedures into governed, tested, documented dbt models, then fix and refactor in seconds.

**Dataset:** GreenField Retail — 800 customers, ~1,900 orders, ~5,700 line items, 120 products, inventory snapshots, web sessions, and marketing spend. 30 models across staging → intermediate → marts (core / finance / marketing / inventory).

---

## Pre-flight (do before you go live)
1. `dbt build` is green. (`SETUP.md` steps 1–4.)
2. `wizard` launches, `/model` shows a Gemini model. (`SETUP.md` step 5.)
3. Decide on the Act 1 mode:
   - **Live build (bolder):** rename the reference solution so Wizard regenerates it from scratch:
     ```bash
     mv models/marts/finance/mart_customer_ltv.sql /tmp/mart_customer_ltv.reference.sql
     ```
   - **Walk-through (safer):** keep the file; have Wizard explain and "rebuild" it, diffing against what's there.
4. Have `legacy/sp_customer_ltv.sql` open in your editor on screen.

---

## Act 0 — Set the scene (2 min)
"Every BigQuery warehouse has these — nightly stored procedures nobody wants to touch. Here's `sp_rebuild_customer_ltv`: temp tables, magic numbers, no tests, no lineage, and the author left. Let's hand it to dbt Wizard, running on Gemini." Show the legacy file.

## Act 1 — Migrate the stored procedure (8 min)
Run `WIZARD_PROMPTS.md` prompts **1.1 → 1.3**.
- 1.1: Wizard explains the proc in plain English — establishes trust.
- 1.2: Wizard inspects existing staging/intermediate models and proposes building on `int_customer_order_summary` instead of re-reading raw tables. **This is the punchline: Gemini reasons over your actual project, not a blank page.**
- 1.3: Wizard writes `mart_customer_ltv.sql` with `ref()`, Fusion-conformant SQL, and runs `dbt build -s mart_customer_ltv` to prove it compiles in BigQuery.
- Optional 1.4: compile the validation analysis to show row-for-row parity vs the legacy output.

## Act 2 — Docs & tests for free (5 min)
The new model ships with no YAML. Run prompts **2.1 → 2.2**.
- Wizard generates column-level descriptions and a full test suite (unique/not_null, accepted_values, relationships) and runs `dbt test`.
- Prompt 2.3 for the "and it scales" moment: Wizard finds doc gaps across all marts.

## Act 3 — Fix & refactor (6 min)
Open `models/marts/_refactor_me/mart_messy_revenue.sql`. "Finance says revenue is too high."
- Prompt 3.1: Wizard finds the payments fan-out + missing status filter and explains the inflation.
- Prompt 3.2: Wizard refactors into clean CTEs on `fct_orders`, fixes the bug, rebuilds, and reports before/after.
- Prompt 3.3 (Google crowd-pleaser): Wizard recommends BigQuery partitioning/clustering and shows the `config()` block.

## Close (2 min)
Recap: legacy proc → governed, tested, documented dbt model; a real bug fixed; cost optimized — all driven by dbt Wizard on **Gemini tokens, your GCP billing**, against **BigQuery**. Point to the repo.

---

## Recovery / fallbacks
- **Wizard write goes sideways in Act 1:** restore the reference solution: `mv /tmp/mart_customer_ltv.reference.sql models/marts/finance/mart_customer_ltv.sql` and keep narrating.
- **A `dbt build` fails live:** that's a feature — ask Wizard to read the error and fix it. Great unscripted moment.
- **Gemini latency/quotas:** pre-warm with one throwaway prompt before going live; have screenshots of expected outputs as a backstop.
- **No BigQuery access on the day:** the same flow runs against any adapter; the SQL is standard enough to demo on DuckDB locally if needed (drop BigQuery-specific functions).
