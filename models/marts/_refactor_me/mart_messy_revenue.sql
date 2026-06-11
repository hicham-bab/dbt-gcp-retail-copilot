-- TODO(analytics): this "works" but Finance says the weekly revenue number
-- looks too high and nobody can read it. Hand it to dbt Copilot to fix + refactor.
--
-- Known smells:
--   * fans out payments across order line items (revenue is overstated)
--   * counts returned/cancelled orders in revenue (no status filter)
--   * no CTEs, nested subquery, correlated subquery, magic numbers
select * from (
  select
    extract(year from o.order_ts) as yr,
    extract(week from o.order_ts) as wk,
    o.order_channel as ch,
    c.region as rg,
    sum(p.amount_cents)/100 as revenue,
    count(distinct o.order_id) as orders,
    sum(oi.quantity) as units,
    (select count(*) from {{ ref('stg_customers') }} c2
       where c2.region = c.region) as customers_in_region,
    case when sum(p.amount_cents)/100 > 50000 then 'big'
         when sum(p.amount_cents)/100 > 10000 then 'med'
         else 'small' end as bucket
  from {{ ref('stg_orders') }} o
  join {{ ref('stg_order_items') }} oi on oi.order_id = o.order_id
  join {{ ref('stg_payments') }} p on p.order_id = o.order_id
  left join {{ ref('stg_customers') }} c on c.customer_id = o.customer_id
  group by 1, 2, 3, 4
) x
where x.revenue is not null
order by x.yr, x.wk, x.revenue desc
