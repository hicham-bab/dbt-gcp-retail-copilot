with source as (
    select * from {{ ref('raw_stores') }}
)

select
    cast(store_id as int64)    as store_id,
    store_name,
    region,
    country,
    cast(opened_date as date)  as opened_date
from source
