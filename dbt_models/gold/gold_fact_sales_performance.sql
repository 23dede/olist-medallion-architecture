-- =============================================================
-- GOLD — fact_sales_performance | 113 425 rows
-- Central fact table for Power BI consumption.
-- Source: LEFT JOIN silver.orders × silver.order_items
--
-- Key design decisions:
--   1. order_date = DATE(purchase_timestamp) → Power BI join key
--      Strips time component to match Dim_Date[Date] (midnight)
--      Without this, 99% of rows fail the Dim_Date join (DateTime mismatch)
--   2. total_order_value = price + freight_value (pre-computed)
--   3. delivery_delay_days computed in SQL (avoids DAX DATEDIFF complexity)
-- =============================================================

CREATE SCHEMA IF NOT EXISTS gold;

DROP TABLE IF EXISTS gold.fact_sales_performance;
CREATE TABLE gold.fact_sales_performance AS
SELECT
    -- Dimension keys
    o.order_id,
    i.order_item_id,
    o.customer_id,
    i.product_id,
    i.seller_id,

    -- Status
    o.order_status,

    -- Full timestamps (audit / drill-down)
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    -- ⭐ Power BI join key — time component stripped
    --    Matches Dim_Date[Date] = CALENDAR() output (midnight)
    DATE(o.order_purchase_timestamp)                                    AS order_date,

    -- Temporal helpers for direct slicing (no Dim_Date needed)
    DATE_TRUNC('month', o.order_purchase_timestamp)::DATE               AS order_month,
    EXTRACT(YEAR  FROM o.order_purchase_timestamp)::INT                 AS order_year,
    EXTRACT(MONTH FROM o.order_purchase_timestamp)::INT                 AS order_month_num,

    -- Financial metrics
    COALESCE(i.price,         0)::DECIMAL(10,2)                         AS price,
    COALESCE(i.freight_value, 0)::DECIMAL(10,2)                         AS freight_value,
    COALESCE(i.price + i.freight_value, 0)::DECIMAL(10,2)               AS total_order_value,

    -- ⭐ KPI: delivery performance
    ROUND(
        EXTRACT(EPOCH FROM (
            o.order_delivered_customer_date - o.order_purchase_timestamp
        )) / 86400.0,
    1)::DECIMAL(6,1)                                                    AS delivery_delay_days

FROM silver.orders o
LEFT JOIN silver.order_items i
    ON o.order_id = i.order_id;

-- Performance indexes for Power BI DirectQuery / Import refresh
CREATE INDEX IF NOT EXISTS idx_fact_order_date ON gold.fact_sales_performance (order_date);
CREATE INDEX IF NOT EXISTS idx_fact_order_id   ON gold.fact_sales_performance (order_id);
CREATE INDEX IF NOT EXISTS idx_fact_customer   ON gold.fact_sales_performance (customer_id);
CREATE INDEX IF NOT EXISTS idx_fact_product    ON gold.fact_sales_performance (product_id);
CREATE INDEX IF NOT EXISTS idx_fact_seller     ON gold.fact_sales_performance (seller_id);
