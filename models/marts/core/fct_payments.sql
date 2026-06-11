with payments as (
    select * from {{ ref('stg_payments') }}
),

orders as (
    select order_id, customer_id from {{ ref('stg_orders') }}
)

select
    payments.payment_id,
    payments.order_id,
    orders.customer_id,
    date(payments.payment_ts) as payment_date,
    payments.payment_ts,
    payments.payment_method,
    payments.amount,
    payments.payment_status,
    payments.is_refunded
from payments
left join orders on payments.order_id = orders.order_id
