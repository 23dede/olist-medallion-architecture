# Olist Medallion Architecture

End-to-end analytics pipeline built on the Brazilian e-commerce dataset [Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), using PostgreSQL, SQL transformations and Power BI DAX.

**Stack:** PostgreSQL 15 · SQL (dbt-style) · Power BI Desktop · DAX

---

## Download the Dashboard

The Power BI file is available directly in this repository.

**File:** [Graphe.pbix](./Graphe.pbix)

To open it, download the file and open it with Power BI Desktop. All data, relationships, DAX measures and visuals are included. No additional setup required.

---

## Dashboard Screenshots

### Page 1 — Vue Generale des Ventes

![Vue Generale des Ventes](./Olist%20E-Commerce%20%E2%80%94%20Vue%20G%C3%A9n%C3%A9rale%20des%20Ventes.png)

This page provides a consolidated view of Olist's e-commerce performance across the full 2016–2018 period. It surfaces four core KPIs at a glance: total revenue (R$ 15.8M), total orders (99,441), average basket size (R$ 159) and average delivery delay (12 days). The trend line tracks monthly revenue evolution across 22 clean, fully comparable months — partial months have been automatically filtered out via a dedicated DAX measure. The donut chart breaks down order status distribution, confirming a 97% delivery rate. Bar charts compare revenue and order volume across 2016, 2017 and 2018, making the growth trajectory immediately readable.

### Page 2 — Vendeurs & Logistique

![Vendeurs et Logistique](./Olist%20E-Commerce%20%E2%80%94%20Vendeurs%20%26%20Logistique.png)

This page focuses on seller performance and logistics analytics. Key metrics include: delivery success rate (97%), number of cancelled orders (625), median delivery delay (10 days), and average revenue per seller (R$ 5,117). The horizontal bar chart ranks top sellers by total sales volume. The column chart shows order distribution across months of the year, revealing seasonality patterns with a peak in Q4. The delivery delay analysis by order status highlights that cancelled orders have significantly higher average delays than delivered ones — a key operational insight.

---

## Architecture Overview

```
CSV Sources (C:\olist_data)
        |
        v
  BRONZE      Raw ingestion — 9 tables, 1,550,922 rows, no transformation
        |
        v
  SILVER      Typed and cleaned — TEXT to TIMESTAMP, DECIMAL casting, INITCAP/UPPER
        |
        v
  GOLD        Business-ready — fact table with pre-computed KPIs
        |
        v
  POWER BI    Semantic layer — Dim_Date, DAX measures, validated visual model
```

---

## Repository Structure

```
olist-medallion-architecture/
├── dbt_models/
│   ├── bronze/          # Raw CSV ingestion scripts
│   ├── silver/          # Typed and cleaned models (7 tables)
│   └── gold/            # Business fact table
├── dax_scripts/
│   ├── dim_date.dax     # Calendar table (2016–2018, 15 columns)
│   └── kpi_measures.dax # All KPI measures with business logic
├── assets/
├── Graphe.pbix           # Power BI dashboard (ready to open)
└── README.md
```

---

## Data Integrity and Business Logic

### The Challenge — Partial Monthly Cycles

When building trend analyses on transactional e-commerce data, a critical problem appears: partial monthly cycles at the boundaries of the data collection window.

The Olist dataset spans from September 2016 to October 2018, but the first and last months are incomplete — only a handful of orders were recorded, making them statistically non-representative. Including these months in a time-series visualization produces two issues:

1. A false dip at the start of the series — September 2016 shows only R$354 in revenue versus over R$1M in mature months, creating a misleading impression of a flat launch.
2. A sharp cliff at the end of the series — August to October 2018 show a sudden drop that is purely a data collection artifact, not a real business signal.

Without treatment, these artifacts would lead a business analyst to draw incorrect conclusions about the company's growth trajectory.

### The Solution — A Robust Semantic Layer

The fix was implemented across two layers.

**Layer 1 — Normalized Date Dimension (Dim_Date)**

A technical bug was identified and resolved: `order_purchase_timestamp` stores full DateTime values (e.g. `2017-11-03 10:56:33`), while Power BI's `CALENDAR()` function generates dates at midnight (`2017-11-03 00:00:00`). This precision mismatch caused 99% of fact table rows to fail the join, rendering all visuals empty.

The fix: a calculated column `order_date = DATE(YEAR, MONTH, DAY)` was added to the fact table to strip the time component and provide a clean join key.

**Layer 2 — Intelligent DAX Measure (Total Sales Full Months)**

Rather than applying a static date filter on the visual, a reusable DAX measure was built that encodes the business rule directly in the semantic layer:

```dax
-- Total Sales (Full Months) — primary trend measure
VAR MontantBrut =
    SUM('gold fact_sales_performance'[total_order_value])
VAR IsAout2018 =
    SELECTEDVALUE('Dim_Date'[Annee])       = 2018
    && SELECTEDVALUE('Dim_Date'[Mois_Num]) = 8
RETURN
IF(
    IsAout2018 || MontantBrut < 10000,
    BLANK(),
    MontantBrut
)
```

This measure applies a dual filter:
- Hard exclusion of August 2018, a known incomplete month (R$1M revenue but partial data)
- Automatic threshold of R$10,000 minimum — any month below this is statistically insignificant and automatically filtered, which future-proofs the measure against new boundary months without code changes

Result: 22 clean, fully comparable months from October 2016 to July 2018, presenting only periods where the business was operating at full capacity.

| Month | Raw Revenue | Filtered Out | Reason |
|-------|-------------|--------------|--------|
| Sept 2016 | R$354 | Yes | Below R$10,000 threshold |
| Dec 2016 | R$19 | Yes | Below R$10,000 threshold |
| Aug 2018 | R$1,003,308 | Yes | Known partial collection |
| Sept 2018 | R$166 | Yes | Below R$10,000 threshold |
| Oct 2018 | R$0 | Yes | Below R$10,000 threshold |

---

## Dashboard Insights

### Key Metrics (validated in DAX — March 2026)

| KPI | Value |
|-----|-------|
| Total Revenue (gross) | R$ 15,843,553 |
| Total Orders | 99,441 |
| Average Basket | R$ 159 |
| Avg Delivery Delay | 12 days |
| Delivery Rate | 97% |
| Active Sellers | 3,095 |
| Revenue per Seller | R$ 5,117 |
| Peak month | November 2017 — R$ 1,179,143 (Black Friday Brazil) |
| Clean analysis window | October 2016 to July 2018 (22 months) |
| Growth 2017 vs 2018 | +21% |

---

## Pipeline Details

### Bronze Layer — Raw Ingestion

| Table | Rows | Source |
|-------|------|--------|
| `bronze.customers` | 99,441 | olist_customers_dataset.csv |
| `bronze.orders` | 99,441 | olist_orders_dataset.csv |
| `bronze.order_items` | 112,650 | olist_order_items_dataset.csv |
| `bronze.order_payments` | 103,886 | olist_order_payments_dataset.csv |
| `bronze.order_reviews` | 99,224 | olist_order_reviews_dataset.csv |
| `bronze.products` | 32,951 | olist_products_dataset.csv |
| `bronze.sellers` | 3,095 | olist_sellers_dataset.csv |
| `bronze.geolocation` | 1,000,163 | olist_geolocation_dataset.csv |
| `bronze.product_category_translation` | 71 | product_category_name_translation.csv |
| **Total** | **1,550,922** | |

### Silver Layer — Typed and Cleaned (7 tables)

| Table | Rows | Key Transformations |
|-------|------|---------------------|
| `silver.orders` | 99,441 | 5 columns TEXT to TIMESTAMP, NULL filter |
| `silver.order_items` | 112,650 | TIMESTAMP + DECIMAL(10,2) |
| `silver.customers` | 99,441 | zip to INT, INITCAP city, UPPER state |
| `silver.sellers` | 3,095 | zip to INT, INITCAP city, UPPER state |
| `silver.products` | 32,951 | English category translation, DECIMAL dimensions |
| `silver.order_payments` | 103,886 | DECIMAL(10,2), filter >= 0, LOWER TRIM |
| `silver.order_reviews` | 99,224 | INT score 1–5, 2x TIMESTAMP |

### Gold Layer — Business Fact Table

| Table | Rows | Description |
|-------|------|-------------|
| `gold.fact_sales_performance` | 113,425 | LEFT JOIN orders x order_items + pre-computed KPIs |

Computed columns: `total_order_value`, `delivery_delay_days`, `order_month`, `order_year`, `order_month_num`, `order_date` (Power BI join key)

---

## Power BI Semantic Model

### Dim_Date — 15 columns, 1,096 rows

```
Date | Annee | Mois_Num | Mois_Nom | Mois_Nom_Court | Trimestre
Trimestre_Num | Annee_Trimestre | Mois_Annee | Mois_Annee_Tri
Semaine_Num | Jour_Semaine_Num | Jour_Semaine_Nom | Est_Weekend | Semestre
```

### Active Relationship

```
gold fact_sales_performance[order_date]  -->  Dim_Date[Date]  (Many-to-One)
```

### DAX Measures

| Measure | Expression | Format |
|---------|-----------|--------|
| `Total Sales` | `SUM([total_order_value])` | `#,##0.00` |
| `Total Sales (Full Months)` | Dual-filter business logic | `#,##0.00` |
| `Total Orders` | `DISTINCTCOUNT([order_id])` | `#,##0` |
| `Avg Delivery Delay` | `AVERAGE([delivery_delay_days])` | `#,##0.0` |
| `Panier Moyen` | `DIVIDE([Total Sales], [Total Orders], 0)` | `#,##0.00 R$` |
| `Nb Vendeurs Actifs` | `DISTINCTCOUNT([seller_id])` | `#,##0` |
| `Nb Clients Uniques` | `DISTINCTCOUNT([customer_id])` | `#,##0` |
| `Taux Livraison %` | `DIVIDE([Commandes Livrees], [Total Orders], 0)` | `0.0%` |
| `Croissance 2017 vs 2018` | `DIVIDE([CA 2018] - [CA 2017], [CA 2017], 0)` | `+0.0%` |
| `CA par Vendeur` | `DIVIDE([Total Sales], [Nb Vendeurs Actifs], 0)` | `#,##0.00 R$` |

All monetary values are in Brazilian Real (R$ / BRL). Olist is a Brazilian marketplace operating exclusively in Brazil. No currency conversion is required or applied anywhere in the pipeline.

---

## How to Reproduce

```bash
# 1. Load Bronze layer
psql -d postgres -f dbt_models/bronze/load_bronze.sql

# 2. Build Silver layer (run in order)
psql -d postgres -f dbt_models/silver/silver_orders.sql
psql -d postgres -f dbt_models/silver/silver_order_items.sql
psql -d postgres -f dbt_models/silver/silver_customers.sql
psql -d postgres -f dbt_models/silver/silver_sellers.sql
psql -d postgres -f dbt_models/silver/silver_products.sql
psql -d postgres -f dbt_models/silver/silver_order_payments.sql
psql -d postgres -f dbt_models/silver/silver_order_reviews.sql

# 3. Build Gold layer
psql -d postgres -f dbt_models/gold/gold_fact_sales_performance.sql

# 4. In Power BI Desktop
#    a) New Table > paste dax_scripts/dim_date.dax
#    b) New Measures > paste each measure from dax_scripts/kpi_measures.dax
#    c) Set relationship: fact[order_date] > Dim_Date[Date] (Many-to-One)
#    d) Sort Mois_Annee column by Mois_Annee_Tri
```

Alternatively, download [Graphe.pbix](./Graphe.pbix) directly to explore the full model without any setup.

---

## License

MIT — Dataset source: [Olist Brazilian E-Commerce on Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
