-- =============================================================
-- BRONZE LAYER — Raw CSV Ingestion
-- No transformations applied. Data loaded as-is from source CSVs.
-- All columns stored as TEXT to preserve raw fidelity.
-- =============================================================

CREATE SCHEMA IF NOT EXISTS bronze;

-- Drop and recreate tables for idempotent re-runs
DROP TABLE IF EXISTS bronze.customers CASCADE;
DROP TABLE IF EXISTS bronze.orders CASCADE;
DROP TABLE IF EXISTS bronze.order_items CASCADE;
DROP TABLE IF EXISTS bronze.order_payments CASCADE;
DROP TABLE IF EXISTS bronze.order_reviews CASCADE;
DROP TABLE IF EXISTS bronze.products CASCADE;
DROP TABLE IF EXISTS bronze.sellers CASCADE;
DROP TABLE IF EXISTS bronze.geolocation CASCADE;
DROP TABLE IF EXISTS bronze.product_category_translation CASCADE;

-- NOTE: Use \copy or your ETL tool to ingest CSVs from C:\olist_data
-- Example for psql:
-- \copy bronze.customers FROM 'C:\olist_data\olist_customers_dataset.csv' CSV HEADER ENCODING 'UTF8';

-- Expected row counts after ingestion:
-- bronze.customers                    : 99 441
-- bronze.orders                       : 99 441
-- bronze.order_items                  : 112 650
-- bronze.order_payments               : 103 886
-- bronze.order_reviews                : 99 224
-- bronze.products                     : 32 951
-- bronze.sellers                      : 3 095
-- bronze.geolocation                  : 1 000 163
-- bronze.product_category_translation : 71
-- TOTAL                               : 1 550 922
