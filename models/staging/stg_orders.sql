with source as (
    select * from {{ ref('raw_orders') }}
)

select
    cast(order_id as int64)        as order_id,
    cast(customer_id as int64)     as customer_id,
    cast(store_id as int64)        as store_id,
    cast(order_ts as timestamp)    as order_ts,
    date(cast(order_ts as timestamp)) as order_date,
    status                         as order_status,
    channel                        as order_channel,
    status = 'completed'           as is_completed
from source
