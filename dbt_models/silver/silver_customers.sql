-- =============================================================
-- SILVER — customers | 99 441 rows
-- =============================================================
DROP TABLE IF EXISTS silver.customers;
CREATE TABLE silver.customers AS
SELECT
    customer_id::TEXT               AS customer_id,
    customer_unique_id::TEXT        AS customer_unique_id,
    customer_zip_code_prefix::INT   AS customer_zip_code_prefix,
    INITCAP(TRIM(customer_city))    AS customer_city,
    UPPER(TRIM(customer_state))     AS customer_state
FROM bronze.customers
WHERE customer_id IS NOT NULL;
