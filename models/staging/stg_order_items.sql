with source as (
    select * from {{ ref('raw_order_items') }}
)

select
    cast(order_item_id as int64)    as order_item_id,
    cast(order_id as int64)         as order_id,
    cast(product_id as int64)       as product_id,
    cast(quantity as int64)         as quantity,
    cast(unit_price_cents as int64) as unit_price_cents,
    cast(discount_cents as int64)   as discount_cents,
    {{ cents_to_dollars('unit_price_cents') }} as unit_price,
    {{ cents_to_dollars('discount_cents') }}   as discount_amount,
    {{ cents_to_dollars('unit_price_cents * quantity - discount_cents') }} as gross_line_amount
from source
