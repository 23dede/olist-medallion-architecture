-- =============================================================
-- SILVER — order_reviews | 99 224 rows
-- =============================================================
DROP TABLE IF EXISTS silver.order_reviews;
CREATE TABLE silver.order_reviews AS
SELECT
    review_id::TEXT                                                             AS review_id,
    order_id::TEXT                                                              AS order_id,
    review_score::INT                                                           AS review_score,
    TRIM(review_comment_title)                                                  AS review_comment_title,
    TRIM(review_comment_message)                                                AS review_comment_message,
    TO_TIMESTAMP(review_creation_date,    'YYYY-MM-DD HH24:MI:SS')             AS review_creation_date,
    TO_TIMESTAMP(review_answer_timestamp, 'YYYY-MM-DD HH24:MI:SS')             AS review_answer_timestamp
FROM bronze.order_reviews
WHERE order_id IS NOT NULL
  AND review_score::INT BETWEEN 1 AND 5;
