-- =============================================================
-- SILVER — products | 32 951 rows
-- Transformations:
--   - LEFT JOIN with product_category_translation for EN names
--   - BOM character on join key: use quoted identifier
--   - All dimension columns → DECIMAL(10,2)
-- KNOWN ISSUE: UTF-8 BOM on first column of translation CSV
--   Quoted join key: t."<BOM>product_category_name"
-- =============================================================

DROP TABLE IF EXISTS silver.products;
CREATE TABLE silver.products AS
SELECT
    p.product_id::TEXT                                              AS product_id,
    COALESCE(t.product_category_name_english,
             p.product_category_name, 'unknown')                    AS product_category_en,
    p.product_name_lenght::INT                                      AS product_name_length,
    p.product_description_lenght::INT                               AS product_description_length,
    p.product_photos_qty::INT                                       AS product_photos_qty,
    COALESCE(p.product_weight_g::DECIMAL(10,2),   0)               AS product_weight_g,
    COALESCE(p.product_length_cm::DECIMAL(10,2),  0)               AS product_length_cm,
    COALESCE(p.product_height_cm::DECIMAL(10,2),  0)               AS product_height_cm,
    COALESCE(p.product_width_cm::DECIMAL(10,2),   0)               AS product_width_cm
FROM bronze.products p
LEFT JOIN bronze.product_category_translation t
    -- BOM-prefixed column name — required quoted identifier in PostgreSQL
    ON p.product_category_name = t."﻿product_category_name"
WHERE p.product_id IS NOT NULL;
