with orders as (
    select * from {{ ref('int_orders_enriched') }}
),

payments as (
    select * from {{ ref('int_payments_by_order') }}
)

select
    orders.order_id,
    orders.customer_id,
    orders.store_id,
    orders.order_date,
    orders.order_ts,
    orders.order_status,
    orders.order_channel,
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
