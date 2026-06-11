-- Web sessions flagged with same-day conversion for attribution analysis.
with sessions as (
    select * from {{ ref('stg_web_sessions') }}
),

daily_orders as (
    select
        customer_id,
        order_date,
        count(*) as orders_placed
    from {{ ref('stg_orders') }}
    where is_completed
    group by customer_id, order_date
)

select
    sessions.session_id,
    sessions.customer_id,
    sessions.session_start_ts,
    date(sessions.session_start_ts)        as session_date,
    sessions.session_duration_seconds,
    sessions.session_channel,
    sessions.landing_page,
    sessions.device,
    sessions.utm_source,
    sessions.utm_campaign,
    sessions.is_identified,
    coalesce(daily_orders.orders_placed, 0) > 0 as converted_same_day
from sessions
left join daily_orders
    on sessions.customer_id = daily_orders.customer_id
    and date(sessions.session_start_ts) = daily_orders.order_date
