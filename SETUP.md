# Setup — GreenField Retail on BigQuery + dbt Wizard (Gemini)

End-to-end setup for the webinar: build the dbt project in BigQuery, then drive it with the dbt Wizard CLI running on Google Gemini.

## Prerequisites
- A GCP project with BigQuery enabled and permission to create datasets.
- `gcloud` CLI installed.
- dbt with the BigQuery adapter (`dbt-bigquery`) — Fusion or `dbt-core >= 1.9`.
- A **Google Gemini API key** (for dbt Wizard BYOK). Enterprise/Enterprise+ dbt plan required for BYOK.

---

## 1. Authenticate to BigQuery

Fastest path for a live demo (OAuth):

```bash
gcloud auth application-default login
```

Or use a service account JSON key and set `method: service-account` + `keyfile` in your profile.

## 2. Configure the dbt profile

Copy the template and edit the project id:

```bash
cp profiles.example.yml ~/.dbt/profiles.yml   # or keep local and use --profiles-dir .
```

Set `project:` to your GCP project id and `location:` to your BigQuery region (`US` or `EU`). The profile splits output across datasets: `<dataset>_raw`, `_staging`, `_intermediate`, `_marts`.

## 3. Generate seeds (already committed, regenerate if needed)

```bash
python3 scripts/generate_seeds.py
```

## 4. Build the project

```bash
dbt deps
dbt seed          # loads the 10 raw_* tables into <dataset>_raw
dbt build         # staging -> intermediate -> marts, runs tests
```

`dbt build` should complete green. Seeds act as the raw layer, so staging models
`ref()` them directly and ordering is guaranteed.

> Run `dbt parse` (or `dbt build`) at least once so a `target/` directory exists —
> dbt Wizard needs it to understand the project.

---

## 5. Install and configure dbt Wizard (Gemini)

Install the CLI:

```bash
curl -fsSL https://public.cdn.getdbt.com/dbt-wizard/install/install-wizard.sh | sh
wizard --version
```

Authenticate to dbt platform:

```bash
wizard login
```

Set your Gemini key and configure the provider:

```bash
export GOOGLE_API_KEY="your-gemini-api-key"     # add to ~/.zshrc to persist
wizard providers configure gemini
wizard providers enable gemini
wizard providers list                            # confirm gemini is active
```

Pick a Gemini model (list first, then set a default):

```bash
wizard debug models
```

Set a default in `~/.dbt/wizard/config.toml`:

```toml
model = "GEMINI_MODEL_ID"     # e.g. a current gemini-* model id from `wizard debug models`
```

## 6. Launch and confirm

From the project root:

```bash
cd dbt-gcp-retail-copilot
wizard
```

In the TUI, confirm the active model with `/model`. During onboarding, point Wizard
at your `dbt` executable and confirm the detected profile/target. You're ready to run
the prompts in `WIZARD_PROMPTS.md`.

---

## Notes & honest caveats
- **Gemini is supported in the dbt Wizard CLI (BYOK), not in the dbt platform UI.** The platform-level AI integration and dbt Copilot's in-IDE buttons currently support OpenAI/Azure OpenAI only. For "dbt + Gemini on GCP," the CLI is the right surface — and it's a great live-terminal demo.
- BYOK token costs bill directly to your Google account, not dbt.
- Wizard's exact provider commands and config keys can evolve — verify against the docs below before the live run.

## Sources
- [Enable dbt AI / supported providers](https://docs.getdbt.com/docs/platform/enable-dbt-ai)
- [About dbt Wizard CLI](https://docs.getdbt.com/docs/dbt-ai/about-dbt-wizard-cli)
- [Configure BYOK for dbt Wizard](https://docs.getdbt.com/docs/dbt-ai/wizard-byok)
- [dbt Wizard CLI quickstart](https://docs.getdbt.com/docs/dbt-ai/wizard-quickstart)
- [dbt BigQuery setup](https://docs.getdbt.com/docs/core/connect-data-platform/bigquery-setup)
