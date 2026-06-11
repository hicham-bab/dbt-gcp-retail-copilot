with source as (
    select * from {{ ref('raw_customers') }}
)

select
    cast(customer_id as int64)        as customer_id,
    cast(home_store_id as int64)      as home_store_id,
    first_name,
    last_name,
    concat(first_name, ' ', last_name) as full_name,
    lower(email)                      as email,
    cast(signup_date as date)         as signup_date,
    country,
    region,
    -- a basic validity flag the data-quality tests can lean on
    regexp_contains(email, r'^[^@\s]+@[^@\s]+\.[^@\s]+$') as has_valid_email
from source
