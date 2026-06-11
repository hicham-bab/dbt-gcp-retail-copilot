-- Order line items enriched with product, category, cost, and margin.
with items as (
    select * from {{ ref('stg_order_items') }}
),

products as (
    select * from {{ ref('stg_products') }}
),

categories as (
    select * from {{ ref('stg_product_categories') }}
)

select
    items.order_item_id,
    items.order_id,
    items.product_id,
    products.category_id,
    categories.category_name,
    categories.department,
    items.quantity,
    items.unit_price,
    items.discount_amount,
    items.gross_line_amount,
    products.unit_cost,
    round(products.unit_cost * items.quantity, 2)                        as line_cost,
    round(items.gross_line_amount - products.unit_cost * items.quantity, 2) as line_margin
from items
left join products on items.product_id = products.product_id
left join categories on products.category_id = categories.category_id
