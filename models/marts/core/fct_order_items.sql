with items as (
    select * from {{ ref('int_order_items_enriched') }}
),

orders as (
    select order_id, customer_id, order_date, order_channel, store_id
    from {{ ref('stg_orders') }}
)

select
    items.order_item_id,
    items.order_id,
    orders.customer_id,
    orders.store_id,
    orders.order_date,
    orders.order_channel,
    items.product_id,
    items.category_id,
    items.category_name,
    items.department,
    items.quantity,
    items.unit_price,
    items.discount_amount,
    items.gross_line_amount,
    items.unit_cost,
    items.line_cost,
    items.line_margin
from items
inner join orders on items.order_id = orders.order_id
