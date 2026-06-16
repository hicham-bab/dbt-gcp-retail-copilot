-- Validation harness for the stored-procedure -> dbt migration.
--
-- Run AFTER you have (a) executed the legacy proc into analytics.customer_ltv
-- and (b) built mart_customer_ltv with dbt. Compile with:
--   dbt compile --select validate_ltv_migration
-- then run the compiled SQL in BigQuery. Zero rows = perfect parity.
with dbt_version as (
    select customer_id, total_orders, lifetime_revenue, ltv_segment
    from {{ ref('mart_customer_ltv') }}
),

legacy_version as (
    -- point this at wherever the legacy proc wrote its output
    select customer_id, total_orders, lifetime_revenue, ltv_segment
    from `analytics.customer_ltv`
)

select
    coalesce(d.customer_id, l.customer_id) as customer_id,
    d.lifetime_revenue as dbt_revenue,
    l.lifetime_revenue as legacy_revenue,
    d.ltv_segment      as dbt_segment,
    l.ltv_segment      as legacy_segment
from dbt_version d
full outer join legacy_version l on d.customer_id = l.customer_id
where d.customer_id is null
   or l.customer_id is null
   or d.lifetime_revenue != l.lifetime_revenue
   or d.ltv_segment != l.ltv_segment
