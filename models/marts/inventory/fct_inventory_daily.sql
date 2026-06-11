with snapshots as (
    select * from {{ ref('stg_inventory_snapshots') }}
),

products as (
    select product_id, product_name, category_id from {{ ref('stg_products') }}
),

categories as (
    select category_id, category_name, department from {{ ref('stg_product_categories') }}
),

stores as (
    select store_id, store_name, region from {{ ref('stg_stores') }}
)

select
    snapshots.snapshot_date,
    snapshots.store_id,
    stores.store_name,
    stores.region,
    snapshots.product_id,
    products.product_name,
    categories.category_name,
    categories.department,
    snapshots.units_on_hand,
    snapshots.units_reserved,
    snapshots.units_available
from snapshots
left join products on snapshots.product_id = products.product_id
left join categories on products.category_id = categories.category_id
left join stores on snapshots.store_id = stores.store_id
