-- =====================================================================
-- LEGACY BIGQUERY STORED PROCEDURE  (the "before" state for the demo)
--
-- Owner: data-eng (original author left the company)
-- Schedule: runs nightly via a Cloud Scheduler -> Cloud Function
-- Output:  analytics.customer_ltv  (full rebuild each night)
--
-- This is the kind of procedural, hard-to-test, hard-to-trace SQL that
-- accumulates in a warehouse. The webinar migrates it into a governed,
-- tested, documented dbt model (mart_customer_ltv) with dbt Copilot.
-- =====================================================================

CREATE OR REPLACE PROCEDURE analytics.sp_rebuild_customer_ltv()
BEGIN

  -- 1. stage completed-order economics into a temp table
  CREATE TEMP TABLE _orders AS
  SELECT
    o.customer_id,
    o.order_id,
    DATE(o.order_ts) AS order_date,
    SUM(oi.unit_price_cents * oi.quantity - oi.discount_cents) AS order_gross_cents,
    SUM(oi.unit_price_cents * oi.quantity - oi.discount_cents
        - p.unit_cost_cents * oi.quantity)                     AS order_margin_cents
  FROM `analytics.raw_orders` o
  JOIN `analytics.raw_order_items` oi ON oi.order_id = o.order_id
  JOIN `analytics.raw_products` p ON p.product_id = oi.product_id
  WHERE o.status = 'completed'
  GROUP BY o.customer_id, o.order_id, DATE(o.order_ts);

  -- 2. roll up to the customer grain
  CREATE TEMP TABLE _cust AS
  SELECT
    customer_id,
    COUNT(DISTINCT order_id)                       AS total_orders,
    SUM(order_gross_cents)                         AS total_gross_cents,
    SUM(order_margin_cents)                        AS total_margin_cents,
    MIN(order_date)                                AS first_order_date,
    MAX(order_date)                                AS last_order_date
  FROM _orders
  GROUP BY customer_id;

  -- 3. final select with segmentation + a naive annualized value model.
  --    NOTE: tenure/recency done with manual DATE_DIFF; segment thresholds
  --    are magic numbers buried in the CASE expression.
  CREATE OR REPLACE TABLE analytics.customer_ltv AS
  SELECT
    c.customer_id,
    cust.total_orders,
    ROUND(cust.total_gross_cents / 100, 2)   AS lifetime_revenue,
    ROUND(cust.total_margin_cents / 100, 2)  AS lifetime_margin,
    ROUND((cust.total_gross_cents / 100) / cust.total_orders, 2) AS avg_order_value,
    cust.first_order_date,
    cust.last_order_date,
    DATE_DIFF(CURRENT_DATE(), cust.first_order_date, DAY) AS tenure_days,
    DATE_DIFF(CURRENT_DATE(), cust.last_order_date, DAY)  AS recency_days,
    -- annualized value: lifetime revenue scaled to a 365-day rate
    ROUND(
      (cust.total_gross_cents / 100)
      / NULLIF(DATE_DIFF(CURRENT_DATE(), cust.first_order_date, DAY), 0)
      * 365
    , 2) AS predicted_annual_value,
    CASE
      WHEN cust.total_gross_cents / 100 >= 2000 THEN 'platinum'
      WHEN cust.total_gross_cents / 100 >= 750  THEN 'gold'
      WHEN cust.total_gross_cents / 100 >= 200  THEN 'silver'
      ELSE 'bronze'
    END AS ltv_segment,
    CASE
      WHEN DATE_DIFF(CURRENT_DATE(), cust.last_order_date, DAY) <= 90  THEN 'active'
      WHEN DATE_DIFF(CURRENT_DATE(), cust.last_order_date, DAY) <= 365 THEN 'lapsing'
      ELSE 'churned'
    END AS lifecycle_stage
  FROM `analytics.raw_customers` c
  JOIN _cust cust ON cust.customer_id = c.customer_id;

END;
