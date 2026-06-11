with spend as (
    select * from {{ ref('stg_marketing_spend') }}
)

select
    spend_date,
    marketing_channel,
    campaign,
    utm_source,
    utm_campaign,
    spend_amount,
    impressions,
    clicks,
    round(safe_divide(clicks, nullif(impressions, 0)), 4)        as click_through_rate,
    round(safe_divide(spend_amount, nullif(clicks, 0)), 2)       as cost_per_click
from spend
