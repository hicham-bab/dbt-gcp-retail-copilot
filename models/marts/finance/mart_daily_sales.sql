-- Daily sales performance by channel.
with orders as (
    select * from {{ ref('fct_orders') }}
)

select
    order_date,
    order_channel,
    count(distinct order_id)                                  as orders,
    countif(is_completed)                                     as completed_orders,
    sum(if(is_completed, units, 0))                           as units_sold,
    round(sum(if(is_completed, gross_amount, 0)), 2)          as gross_revenue,
    round(sum(if(is_completed, total_margin, 0)), 2)          as gross_margin,
    round(safe_divide(
        sum(if(is_completed, gross_amount, 0)),
        nullif(countif(is_completed), 0)
    ), 2)                                                     as avg_order_value
from orders
group by order_date, order_channel
