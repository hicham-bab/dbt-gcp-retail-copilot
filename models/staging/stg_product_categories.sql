with source as (
    select * from {{ ref('raw_product_categories') }}
)

select
    cast(category_id as int64) as category_id,
    category_name,
    department
from source
