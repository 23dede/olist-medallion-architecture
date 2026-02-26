-- =============================================================
-- SILVER — order_items
-- Transformations:
--   - shipping_limit_date TEXT → TIMESTAMP
--   - price, freight_value DOUBLE PRECISION → DECIMAL(10,2)
-- Result: 112 650 rows
-- =============================================================

DROP TABLE IF EXISTS silver.order_items;
CREATE TABLE silver.order_items AS
SELECT
    order_id::TEXT                                                      AS order_id,
    order_item_id::INT                                                  AS order_item_id,
    product_id::TEXT                                                    AS product_id,
    seller_id::TEXT                                                     AS seller_id,
    TO_TIMESTAMP(shipping_limit_date, 'YYYY-MM-DD HH24:MI:SS')         AS shipping_limit_date,
    price::DECIMAL(10,2)                                                AS price,
    freight_value::DECIMAL(10,2)                                        AS freight_value
FROM bronze.order_items
WHERE order_id IS NOT NULL;
