with source as (
    select * from {{ ref('raw_inventory_snapshots') }}
)

select
    cast(snapshot_date as date)     as snapshot_date,
    cast(store_id as int64)         as store_id,
    cast(product_id as int64)       as product_id,
    cast(units_on_hand as int64)    as units_on_hand,
    cast(units_reserved as int64)   as units_reserved,
    cast(units_on_hand as int64) - cast(units_reserved as int64) as units_available
from source
