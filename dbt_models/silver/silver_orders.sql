-- =============================================================
-- SILVER — orders
-- Transformations:
--   - 5 date columns TEXT → TIMESTAMP
--   - Filter NULL order_id
-- Result: 99 441 rows
-- =============================================================

DROP TABLE IF EXISTS silver.orders;
CREATE TABLE silver.orders AS
SELECT
    order_id::TEXT                                                                      AS order_id,
    customer_id::TEXT                                                                   AS customer_id,
    order_status::TEXT                                                                  AS order_status,
    TO_TIMESTAMP(order_purchase_timestamp,    'YYYY-MM-DD HH24:MI:SS')                 AS order_purchase_timestamp,
    TO_TIMESTAMP(order_approved_at,           'YYYY-MM-DD HH24:MI:SS')                 AS order_approved_at,
    TO_TIMESTAMP(order_delivered_carrier_date,'YYYY-MM-DD HH24:MI:SS')                 AS order_delivered_carrier_date,
    TO_TIMESTAMP(order_delivered_customer_date,'YYYY-MM-DD HH24:MI:SS')                AS order_delivered_customer_date,
    TO_TIMESTAMP(order_estimated_delivery_date,'YYYY-MM-DD HH24:MI:SS')                AS order_estimated_delivery_date
FROM bronze.orders
WHERE order_id IS NOT NULL;
