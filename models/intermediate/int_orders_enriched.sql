-- Order headers rolled up with line-item economics.
with orders as (
    select * from {{ ref('stg_orders') }}
),

items as (
    select * from {{ ref('int_order_items_enriched') }}
),

item_rollup as (
    select
        order_id,
        count(*)                  as item_count,
        sum(quantity)             as units,
        round(sum(gross_line_amount), 2) as gross_amount,
        round(sum(line_cost), 2)         as total_cost,
        round(sum(line_margin), 2)       as total_margin
    from items
    group by order_id
)

select
    orders.order_id,
    orders.customer_id,
    orders.store_id,
    orders.order_ts,
    orders.order_date,
    orders.order_status,
    orders.order_channel,
    orders.is_completed,
    coalesce(item_rollup.item_count, 0)   as item_count,
    coalesce(item_rollup.units, 0)        as units,
    coalesce(item_rollup.gross_amount, 0) as gross_amount,
    coalesce(item_rollup.total_cost, 0)   as total_cost,
    coalesce(item_rollup.total_margin, 0) as total_margin
from orders
left join item_rollup on orders.order_id = item_rollup.order_id
