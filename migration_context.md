# Migration demo context

Use this context as the default working style for this migration flow.

## Working style
- Be direct, fluid, and concise.
- Read only the files needed to complete the current step.
- Prefer extending existing dbt models, YAML, and semantic configurations over creating new assets.
- Keep the scope tight to the user’s request.
- Avoid long-running dbt commands unless the user explicitly asks for them.
- Prefer lightweight validation when validation is needed.
- When a step is done, summarize briefly what changed.
- If the next step in the flow is obvious, move to it without over-explaining.

## Modeling expectations
- Reuse existing staging and intermediate models with `ref()` whenever possible.
- Keep business logic faithful to the legacy implementation unless there is a clear reason to improve it.
- Do not create new models if an existing model or semantic config can be extended cleanly.
- Keep documentation and tests simple, useful, and credible for a live walkthrough.

## Semantic layer expectations
- Extend the existing semantic layer configuration before introducing new semantic assets.
- Favor the smallest change that enables the requested metrics, dimensions, and saved queries.
- Keep saved queries aligned to the demo use case: commercial performance analysis and export to BigQuery.

## Validation expectations
- Use the lightest check that gives confidence.
- Avoid expensive builds during the live flow unless explicitly requested.
- If something is not validated, say so plainly and move on.
