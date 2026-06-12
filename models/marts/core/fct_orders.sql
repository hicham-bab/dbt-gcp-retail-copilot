with orders as (
    select * from {{ ref('int_orders_enriched') }}
),

payments as (
    select * from {{ ref('int_payments_by_order') }}
),

stores as (
    select store_id, region from {{ ref('dim_stores') }}
)

select
    orders.order_id,
    orders.customer_id,
    orders.store_id,
    orders.order_date,
    orders.order_ts,
    orders.order_status,
    orders.order_channel,
    stores.region,
    orders.is_completed,
    orders.item_count,
    orders.units,
    orders.gross_amount,
    orders.total_cost,
    orders.total_margin,
    coalesce(payments.amount_paid, 0)     as amount_paid,
    coalesce(payments.payment_count, 0)   as payment_count,
    coalesce(payments.has_refund, false)  as has_refund
from orders
left join payments on orders.order_id = payments.order_id
left join stores on orders.store_id = stores.store_id
