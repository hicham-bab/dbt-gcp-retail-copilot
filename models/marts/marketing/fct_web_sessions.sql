select
    session_id,
    customer_id,
    session_start_ts,
    session_date,
    session_duration_seconds,
    session_channel,
    landing_page,
    device,
    utm_source,
    utm_campaign,
    is_identified,
    converted_same_day
from {{ ref('int_web_sessions_enriched') }}
