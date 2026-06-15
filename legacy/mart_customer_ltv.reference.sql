-- =====================================================================
-- Customer lifetime value.
--
-- Migrated from the legacy BigQuery stored procedure
-- legacy/sp_customer_ltv.sql -> analytics.sp_rebuild_customer_ltv().
--
-- This is the reference "after" state. During the webinar, dbt Copilot
-- generates this from the legacy procedure live; keep it as a safety net
-- and answer key. See DEMO_SCRIPT.md.
-- =====================================================================
with customers as (
    select * from {{ ref('stg_customers') }}
),

summary as (
    select * from {{ ref('int_customer_order_summary') }}
    where completed_orders > 0
)

select
    customers.customer_id,
    customers.full_name,
    customers.region,
    summary.completed_orders                       as total_orders,
    summary.lifetime_gross                         as lifetime_revenue,
    summary.lifetime_margin                        as lifetime_margin,
    summary.avg_order_value,
    summary.first_order_date,
    summary.last_order_date,
    date_diff(current_date(), summary.first_order_date, day) as tenure_days,
    date_diff(current_date(), summary.last_order_date, day)  as recency_days,
    round(
        summary.lifetime_gross
        / nullif(date_diff(current_date(), summary.first_order_date, day), 0)
        * 365
    , 2)                                           as predicted_annual_value,
    case
        when summary.lifetime_gross >= 2000 then 'platinum'
        when summary.lifetime_gross >= 750  then 'gold'
        when summary.lifetime_gross >= 200  then 'silver'
        else 'bronze'
    end                                            as ltv_segment,
    case
        when date_diff(current_date(), summary.last_order_date, day) <= 90  then 'active'
        when date_diff(current_date(), summary.last_order_date, day) <= 365 then 'lapsing'
        else 'churned'
    end                                            as lifecycle_stage
from summary
inner join customers on summary.customer_id = customers.customer_id
