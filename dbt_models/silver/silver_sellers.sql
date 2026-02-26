-- =============================================================
-- SILVER — sellers | 3 095 rows
-- =============================================================
DROP TABLE IF EXISTS silver.sellers;
CREATE TABLE silver.sellers AS
SELECT
    seller_id::TEXT                 AS seller_id,
    seller_zip_code_prefix::INT     AS seller_zip_code_prefix,
    INITCAP(TRIM(seller_city))      AS seller_city,
    UPPER(TRIM(seller_state))       AS seller_state
FROM bronze.sellers
WHERE seller_id IS NOT NULL;
