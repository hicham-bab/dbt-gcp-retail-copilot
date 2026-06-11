with source as (
    select * from {{ ref('raw_web_sessions') }}
)

select
    session_id,
    -- customer_id is null for anonymous sessions (blank in the CSV -> NULL int64)
    cast(customer_id as int64)          as customer_id,
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
    customer_id is not null             as is_identified
from source
