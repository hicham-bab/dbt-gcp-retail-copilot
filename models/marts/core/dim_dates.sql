-- Date spine covering the demo window.
with spine as (
    select day as date_day
    from unnest(generate_date_array('2024-01-01', '2026-12-31')) as day
)

select
    date_day,
    extract(year from date_day)        as year,
    extract(quarter from date_day)     as quarter,
    extract(month from date_day)       as month,
    format_date('%B', date_day)        as month_name,
    extract(week from date_day)        as week_of_year,
    extract(dayofweek from date_day)   as day_of_week,
    format_date('%A', date_day)        as day_name,
    extract(dayofweek from date_day) in (1, 7) as is_weekend
from spine
