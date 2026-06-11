-- Latest inventory position per store and product with stock-risk flags.
with latest as (
    select *
    from {{ ref('fct_inventory_daily') }}
    qualify row_number() over (
        partition by store_id, product_id
        order by snapshot_date desc
    ) = 1
)

select
    store_id,
    store_name,
    region,
    product_id,
    product_name,
    category_name,
    department,
    snapshot_date as last_snapshot_date,
    units_on_hand,
    units_reserved,
    units_available,
    case
        when units_available <= 0 then 'stockout'
        when units_available < 20 then 'low'
        when units_available > 200 then 'overstock'
        else 'healthy'
    end as stock_status
from latest
