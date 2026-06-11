with stores as (
    select * from {{ ref('stg_stores') }}
),

order_rollup as (
    select
        store_id,
        count(distinct order_id)              as total_orders,
        round(sum(if(is_completed, gross_amount, 0)), 2) as total_gross
    from {{ ref('int_orders_enriched') }}
    group by store_id
)

select
    stores.store_id,
    stores.store_name,
    stores.region,
    stores.country,
    stores.opened_date,
    coalesce(order_rollup.total_orders, 0) as total_orders,
    coalesce(order_rollup.total_gross, 0)  as total_gross
from stores
left join order_rollup on stores.store_id = order_rollup.store_id
