-- Joins paid-media spend to session and same-day conversion outcomes
-- at the date / source / campaign grain.
with spend as (
    select
        spend_date,
        utm_source,
        utm_campaign,
        marketing_channel,
        sum(spend_amount) as spend_amount,
        sum(impressions)  as impressions,
        sum(clicks)       as clicks
    from {{ ref('fct_marketing_spend') }}
    group by spend_date, utm_source, utm_campaign, marketing_channel
),

sessions as (
    select
        session_date,
        utm_source,
        utm_campaign,
        count(*)                       as sessions,
        countif(converted_same_day)    as conversions
    from {{ ref('fct_web_sessions') }}
    group by session_date, utm_source, utm_campaign
)

select
    spend.spend_date,
    spend.marketing_channel,
    spend.utm_source,
    spend.utm_campaign,
    spend.spend_amount,
    spend.impressions,
    spend.clicks,
    coalesce(sessions.sessions, 0)     as sessions,
    coalesce(sessions.conversions, 0)  as conversions,
    round(safe_divide(spend.spend_amount, nullif(sessions.sessions, 0)), 2)    as cost_per_session,
    round(safe_divide(spend.spend_amount, nullif(sessions.conversions, 0)), 2) as cost_per_conversion
from spend
left join sessions
    on spend.spend_date = sessions.session_date
    and spend.utm_source = sessions.utm_source
    and spend.utm_campaign = sessions.utm_campaign
