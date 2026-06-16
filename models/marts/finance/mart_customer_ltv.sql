with customers as (
    select * from {{ ref('stg_customers') }}
),

completed_orders as (
    select * from {{ ref('int_orders_enriched') }} where is_completed
),

customer_ltv as (
    select
        customer_id,
        count(distinct order_id) as total_orders,
        round(sum(gross_amount), 2) as lifetime_revenue,
        round(sum(total_margin), 2) as lifetime_margin,
        round(safe_divide(sum(gross_amount), nullif(count(distinct order_id), 0)), 2) as avg_order_value,
        min(order_date) as first_order_date,
        max(order_date) as last_order_date
    from completed_orders
    group by customer_id
)

select
    customers.customer_id,
    customer_ltv.total_orders,
    customer_ltv.lifetime_revenue,
    customer_ltv.lifetime_margin,
    customer_ltv.avg_order_value,
    customer_ltv.first_order_date,
    customer_ltv.last_order_date,
    date_diff(current_date(), customer_ltv.first_order_date, day) as tenure_days,
    date_diff(current_date(), customer_ltv.last_order_date, day) as recency_days,
    round(
        safe_divide(customer_ltv.lifetime_revenue,
                    nullif(date_diff(current_date(), customer_ltv.first_order_date, day), 0)) * 365,
        2
    ) as predicted_annual_value,
    case
        when customer_ltv.lifetime_revenue >= 2000 then 'platinum'
        when customer_ltv.lifetime_revenue >= 750 then 'gold'
        when customer_ltv.lifetime_revenue >= 200 then 'silver'
        else 'bronze'
    end as ltv_segment,
    case
        when date_diff(current_date(), customer_ltv.last_order_date, day) <= 90 then 'active'
        when date_diff(current_date(), customer_ltv.last_order_date, day) <= 365 then 'lapsing'
        else 'churned'
    end as lifecycle_stage
from customers
inner join customer_ltv on customers.customer_id = customer_ltv.customer_id
