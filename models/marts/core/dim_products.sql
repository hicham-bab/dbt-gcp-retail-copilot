with products as (
    select * from {{ ref('stg_products') }}
),

categories as (
    select * from {{ ref('stg_product_categories') }}
),

sales as (
    select
        product_id,
        sum(quantity)                  as lifetime_units_sold,
        round(sum(gross_line_amount), 2) as lifetime_revenue,
        round(sum(line_margin), 2)       as lifetime_margin
    from {{ ref('int_order_items_enriched') }}
    group by product_id
)

select
    products.product_id,
    products.product_name,
    products.category_id,
    categories.category_name,
    categories.department,
    products.unit_cost,
    products.unit_price,
    round(products.unit_price - products.unit_cost, 2) as unit_margin,
    products.is_active,
    coalesce(sales.lifetime_units_sold, 0)             as lifetime_units_sold,
    coalesce(sales.lifetime_revenue, 0)                as lifetime_revenue,
    coalesce(sales.lifetime_margin, 0)                 as lifetime_margin
from products
left join categories on products.category_id = categories.category_id
left join sales on products.product_id = sales.product_id
