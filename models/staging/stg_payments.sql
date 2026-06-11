with source as (
    select * from {{ ref('raw_payments') }}
)

select
    cast(payment_id as int64)    as payment_id,
    cast(order_id as int64)      as order_id,
    payment_method,
    cast(amount_cents as int64)  as amount_cents,
    {{ cents_to_dollars('amount_cents') }} as amount,
    cast(payment_ts as timestamp) as payment_ts,
    status                       as payment_status,
    status = 'refunded'          as is_refunded
from source
