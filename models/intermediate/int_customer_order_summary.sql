-- Per-customer order history summary, reused by dim_customers and the LTV mart.
with orders as (
    select * from {{ ref('int_orders_enriched') }}
)

select
    customer_id,
    min(order_date)                                       as first_order_date,
    max(order_date)                                       as last_order_date,
    count(distinct order_id)                              as lifetime_orders,
    countif(is_completed)                                 as completed_orders,
    countif(order_status = 'returned')                    as returned_orders,
    round(sum(if(is_completed, gross_amount, 0)), 2)      as lifetime_gross,
    round(sum(if(is_completed, total_margin, 0)), 2)      as lifetime_margin,
    round(safe_divide(sum(if(is_completed, gross_amount, 0)),
                      nullif(countif(is_completed), 0)), 2) as avg_order_value
from orders
group by customer_id
