with source as (
    select * from {{ ref('raw_marketing_spend') }}
)

select
    cast(spend_date as date)     as spend_date,
    channel                      as marketing_channel,
    campaign,
    utm_source,
    utm_campaign,
    cast(spend_cents as int64)   as spend_cents,
    {{ cents_to_dollars('spend_cents') }} as spend_amount,
    cast(impressions as int64)   as impressions,
    cast(clicks as int64)        as clicks
from source
