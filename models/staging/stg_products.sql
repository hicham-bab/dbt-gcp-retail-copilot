with source as (
    select * from {{ ref('raw_products') }}
)

select
    cast(product_id as int64)        as product_id,
    cast(category_id as int64)       as category_id,
    product_name,
    cast(unit_cost_cents as int64)   as unit_cost_cents,
    cast(unit_price_cents as int64)  as unit_price_cents,
    {{ cents_to_dollars('unit_cost_cents') }}  as unit_cost,
    {{ cents_to_dollars('unit_price_cents') }} as unit_price,
    cast(is_active as boolean)       as is_active
from source
