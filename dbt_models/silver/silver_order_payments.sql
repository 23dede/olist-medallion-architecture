-- =============================================================
-- SILVER — order_payments | 103 886 rows
-- =============================================================
DROP TABLE IF EXISTS silver.order_payments;
CREATE TABLE silver.order_payments AS
SELECT
    order_id::TEXT                  AS order_id,
    payment_sequential::INT         AS payment_sequential,
    LOWER(TRIM(payment_type))       AS payment_type,
    payment_installments::INT       AS payment_installments,
    payment_value::DECIMAL(10,2)    AS payment_value
FROM bronze.order_payments
WHERE order_id IS NOT NULL
  AND payment_value::DECIMAL(10,2) >= 0;
