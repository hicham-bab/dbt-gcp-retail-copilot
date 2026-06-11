with customers as (
    select * from {{ ref('stg_customers') }}
),

summary as (
    select * from {{ ref('int_customer_order_summary') }}
),

stores as (
    select store_id, store_name from {{ ref('stg_stores') }}
)

select
    customers.customer_id,
    customers.full_name,
    customers.email,
    customers.has_valid_email,
    customers.signup_date,
    customers.country,
    customers.region,
    customers.home_store_id,
    stores.store_name                              as home_store_name,
    coalesce(summary.lifetime_orders, 0)           as lifetime_orders,
    coalesce(summary.completed_orders, 0)          as completed_orders,
    coalesce(summary.returned_orders, 0)           as returned_orders,
    coalesce(summary.lifetime_gross, 0)            as lifetime_gross,
    coalesce(summary.lifetime_margin, 0)           as lifetime_margin,
    summary.avg_order_value,
    summary.first_order_date,
    summary.last_order_date,
    case
        when summary.last_order_date is null then 'never_ordered'
        when summary.last_order_date >= date_sub(current_date(), interval 90 day) then 'active'
        when summary.last_order_date >= date_sub(current_date(), interval 365 day) then 'lapsing'
        else 'churned'
    end                                            as customer_status
from customers
left join summary on customers.customer_id = summary.customer_id
left join stores on customers.home_store_id = stores.store_id
