-- Payments aggregated to the order grain.
with payments as (
    select * from {{ ref('stg_payments') }}
)

select
    order_id,
    count(*)                              as payment_count,
    round(sum(amount), 2)                 as amount_paid,
    logical_or(is_refunded)               as has_refund,
    array_agg(distinct payment_method order by payment_method) as payment_methods
from payments
group by order_id
