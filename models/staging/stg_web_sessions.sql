with source as (
    select * from {{ ref('raw_web_sessions') }}
)

select
    session_id,
    -- customer_id is blank for anonymous sessions; null it out cleanly
    case when customer_id = '' then null else cast(customer_id as int64) end as customer_id,
    cast(session_start_ts as timestamp) as session_start_ts,
    cast(session_end_ts as timestamp)   as session_end_ts,
    timestamp_diff(
        cast(session_end_ts as timestamp),
        cast(session_start_ts as timestamp),
        second
    )                                   as session_duration_seconds,
    channel                             as session_channel,
    landing_page,
    device,
    utm_source,
    utm_campaign,
    customer_id != ''                   as is_identified
from source
