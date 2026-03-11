# Olist E-Commerce — Medallion Architecture

End-to-end analytics pipeline for Brazilian e-commerce sales, seller performance, and logistics monitoring.
Architecture: Medallion (Bronze / Silver / Gold) — dbt — PostgreSQL — Python — Power BI.

---

## Power BI Report

> **[Download Projet_Olist.pbix](https://github.com/23dede/olist-medallion-architecture/raw/main/Projet_Olist.pbix)**
> DAX measures across multiple folders — Seller, Sales, Logistics, and Time dimensions

The report connects directly to the Gold layer output and provides two analytical dashboards:
a general sales overview with revenue trends and order volume, and a seller and logistics breakdown
covering delivery performance and top-seller rankings.

---

## Dashboard 1 — General Sales Overview

![General Sales Overview](Olist%20E-Commerce%20%E2%80%94%20Vue%20G%C3%A9n%C3%A9rale%20des%20Ventes.png)

This dashboard provides a high-level view of the Olist platform's commercial performance across the
full observation period (2016–2018). It is designed for business managers and analysts who need a
quick, reliable picture of overall revenue growth, order volume, and delivery efficiency.

### Chart — Total Sales by Order Month (line chart, top left)

The line chart plots total revenue (Total Sales) on the vertical axis against the order month on the
horizontal axis, running from January 2017 to September 2018. The curve starts near 0 in early 2016
(very few transactions recorded), then climbs steadily through 2017, reaching peaks above 1.0M R$
in early 2018 before a sharp drop in the final months of the dataset. This drop reflects an incomplete
month in the data extract rather than a real business decline. The overall upward slope from left to
right confirms strong year-over-year growth in platform revenue. Analysts can use this curve to
identify specific months that over- or under-performed relative to the trend, and to correlate
revenue spikes with commercial events such as Black Friday or seasonal promotions in Brazil.

### Chart — Total Orders by Order Status (donut chart, top center)

The donut chart segments all 99,441 orders by their final delivery status. The dominant slice
(in dark blue, 97.02%, approximately 96K orders) represents **delivered** orders — orders that
reached the customer successfully. A thin outer ring contains all remaining statuses: shipped,
canceled, unavailable, invoiced, processing, created, and approved. Each status is color-coded
in the legend to the right. The near-complete dominance of the delivered status confirms a very
high fulfillment rate across the platform, and the small remaining segments represent operational
failure modes that logistics teams should monitor for improvement.

### Chart — Total Sales by Order Year (horizontal bar chart, bottom left)

Three horizontal bars represent the years 2016, 2017, and 2018. The 2018 bar is the longest,
extending beyond 7.5M R$ in total revenue. The 2017 bar is approximately half as long, and the
2016 bar is negligible, reflecting the platform's early launch phase. This year-over-year comparison
visually confirms the strong commercial growth trajectory of Olist between its early operations and
its peak year. The revenue roughly doubled from 2017 to 2018, consistent with the +21% monthly
growth rate captured in the seller dashboard.

### Chart — Total Orders by Order Year (bar chart, bottom center)

Three vertical bars confirm the same growth story from a volume perspective. In 2016, order count
is near zero. In 2017, it reaches approximately 45,000 orders. In 2018, it climbs to nearly 57,000.
The steeper rise in volume from 2017 to 2018 is slightly less pronounced than the revenue growth,
suggesting that average order value also increased over the same period — confirmed by the Average
Basket KPI card.

### KPI Cards (right panel)

| KPI card | Value | Meaning |
|---|---|---|
| Total Sales | 15,843,553 R$ | Total platform revenue across all recorded orders |
| Total Orders | 99,441 | Total number of orders placed on the platform |
| Average Basket | 159 R$ | Mean revenue per order across all transactions |
| Avg Delivery Delay | 12 days | Average number of days between order placement and delivery |

A **159 R$ average basket** positions Olist orders in the mid-range of Brazilian e-commerce.
An **average delivery delay of 12 days** is the baseline logistics performance metric against which
seller and regional breakdowns in Dashboard 2 are compared.

---

## Dashboard 2 — Sellers and Logistics

![Sellers and Logistics](Olist%20E-Commerce%20%E2%80%94%20Vendeurs%20%26%20Logistique.png)

This dashboard focuses on individual seller performance and delivery efficiency. It is designed
for operations managers, logistics coordinators, and marketplace administrators who need to identify
top-performing sellers, detect delivery bottlenecks, and monitor cancellation behavior.

### Chart — Total Sales by Seller ID (horizontal bar chart, top left)

Each horizontal bar represents one seller, identified by a truncated UUID (unique seller identifier).
The bars are ranked from highest to lowest total sales revenue. The top seller (starting with
`25c5c91f63607...`) generates approximately 400 units of sales, clearly ahead of the second and
third sellers. The ranking drops off progressively down the list. This chart is the primary tool
for marketplace managers to identify key sellers who drive a disproportionate share of revenue,
and to flag underperforming sellers for support or removal. Sellers with very short bars near the
bottom may represent inactive or newly onboarded accounts.

### Chart — Total Orders by Order Month Number (bar chart, top center)

The horizontal axis represents the month number (1 = January through 12 = December), aggregated
across all years in the dataset. The vertical axis shows total order count. The chart reveals a
clear seasonal pattern: order volume is low in the first months of the year (around 5,000 per month
in months 1–3), rises sharply from month 4 onwards, peaks in months 8–10 (around 10,000–11,000
orders per month), then drops back slightly toward month 12. This seasonal distribution is typical
of Brazilian e-commerce, where mid-year and late-year periods (including Children's Day in October
and Black Friday in November) generate significantly higher volumes. Logistics teams should use
this chart to anticipate staffing and carrier capacity needs during peak periods.

### Chart — Average Delivery Delay by Order Status (horizontal bar chart, bottom left)

This chart compares the average delivery delay (in days) across two order statuses: **canceled**
and **delivered**. The canceled bar is longer, showing an average delay of approximately 19 days
before cancellation, while delivered orders average approximately 12–13 days to reach the customer.
The fact that canceled orders have a longer associated delay suggests that many cancellations occur
after a prolonged wait — meaning customers abandon their order because it has not arrived within
an acceptable timeframe. Reducing delivery delays in the 12–19 day range would likely reduce the
cancellation rate and improve customer satisfaction scores.

### KPI Cards (right and center panels)

| KPI card | Value | Meaning |
|---|---|---|
| Delivery Rate | 97% | Percentage of orders that were successfully delivered to the customer |
| Canceled Orders | 625 | Total number of orders that were canceled across the entire period |
| Growth 2017 vs 2018 | +21% | Year-over-year revenue growth from 2017 to 2018 |
| Median Delivery Delay | 10 days | Median number of days between order and delivery (less sensitive to outliers than average) |
| Max Delivery Delay | 210 days | The longest recorded delivery in the dataset — a significant outlier worth investigating |
| Revenue per Seller | 5,117 R$ | Average total revenue generated per active seller on the platform |

The **210-day maximum delivery delay** is a critical outlier that signals either a data quality
issue (an order never marked as delivered) or an extreme logistics failure. The difference between
the median (10 days) and the average (12 days) confirms the presence of high-delay outliers
pulling the mean upward. The **97% delivery rate** and **+21% revenue growth** together confirm
a high-performing platform with strong commercial momentum across the 2017–2018 period.

---

## Problem Statement

Olist is a Brazilian e-commerce marketplace that connects small and medium sellers to major retail
platforms. With over 99,000 orders processed across nearly 3,000 sellers, the platform generates
a rich operational dataset covering sales, customer reviews, product categories, geolocation,
payment methods, and delivery logistics.

The challenge addressed by this project is multi-dimensional: how can Olist's operational
stakeholders monitor sales performance, identify underperforming sellers, detect logistics
bottlenecks, and understand customer satisfaction drivers — all from a single, well-structured
analytics platform?

The project demonstrates how a Medallion data architecture transforms raw transactional data
into a business-ready Power BI model, using dbt for transformation and PostgreSQL as the
analytical warehouse.

---

## Solution

This project builds a complete data pipeline from raw CSV ingestion to a Power BI business
intelligence layer, structured around three analytical stages:

**Stage 1 — Data Engineering (Bronze and Silver layers)**

Raw Olist CSV files are ingested into PostgreSQL without transformation. The Silver layer,
implemented in dbt, applies data cleaning, type casting, deduplication, and join logic to
combine the eight source tables (orders, customers, sellers, products, reviews, payments,
order items, geolocation) into clean, validated staging models.

**Stage 2 — Analytical Aggregation (Gold layer)**

The Gold layer consolidates the Silver models into pre-aggregated mart tables consumed
by Power BI. Key Gold models include seller performance metrics, monthly revenue trends,
delivery time distributions, and customer satisfaction scores.

**Stage 3 — Business Intelligence (Power BI)**

The aggregated data is exposed in a Power BI semantic model with DAX measures organized
across Sales, Seller, Logistics, and Time folders. Two dashboards provide complementary
views: one at the platform level, one at the seller and logistics level.

---

## Architecture

```
Source: Olist public dataset (9 CSV files from Kaggle)
  |
  v
Bronze Layer
  PostgreSQL — schema: bronze
  Raw ingestion — no transformation — timestamp logging per table
  Tables: orders, customers, sellers, products, order_items,
          order_reviews, order_payments, geolocation
  |
  v
Silver Layer
  dbt models — materialized as views
  stg_orders         : type casting, status normalization, date extraction
  stg_customers      : state/city normalization, customer deduplication
  stg_sellers        : seller state mapping, activity flags
  stg_order_items    : price/freight enrichment, seller linkage
  stg_order_reviews  : score normalization, lag between purchase and review
  stg_payments       : payment type flags, installment normalization
  |
  v
Gold Layer
  dbt models — materialized as tables
  mart_sales_overview     : monthly revenue, order counts, basket size
  mart_seller_performance : per-seller revenue, order count, avg delivery delay
  mart_logistics_kpis     : delivery rates, delay distributions, cancellation rates
  mart_customer_reviews   : review score averages by seller, product, state
  |
  v
Power BI Semantic Model
  DAX measures: Sales KPIs, Seller Rankings, Logistics Metrics, Time Intelligence
  Two report pages: General Sales Overview / Sellers and Logistics
  DimDate for time-intelligence functions
```

---

## Project Structure

```
olist-medallion-architecture/
|
|-- README.md
|-- Projet_Olist.pbix                          <- Power BI report (download above)
|
|-- dbt_models/
|   |-- models/
|   |   |-- silver/
|   |   |   |-- stg_orders.sql
|   |   |   |-- stg_customers.sql
|   |   |   |-- stg_sellers.sql
|   |   |   |-- stg_order_items.sql
|   |   |   |-- stg_order_reviews.sql
|   |   |   |-- stg_payments.sql
|   |   |   `-- schema.yml
|   |   `-- gold/
|   |       |-- mart_sales_overview.sql
|   |       |-- mart_seller_performance.sql
|   |       |-- mart_logistics_kpis.sql
|   |       |-- mart_customer_reviews.sql
|   |       `-- schema.yml
|
|-- dax_scripts/
|   `-- dax_measures.dax
|
`-- assets/
    |-- Olist E-Commerce — Vue Générale des Ventes.png
    `-- Olist E-Commerce — Vendeurs & Logistique.png
```

---

## Dataset

The Olist dataset is publicly available on Kaggle. It covers approximately 100,000 orders placed
on the Brazilian Olist marketplace between 2016 and 2018, across 27 Brazilian states.

| Source table           | Description                                              |
|------------------------|----------------------------------------------------------|
| olist_orders           | One row per order: status, timestamps, customer ID       |
| olist_customers        | Customer city, state, and anonymized zip prefix          |
| olist_sellers          | Seller city, state, and anonymized zip prefix            |
| olist_order_items      | Line items per order: seller, product, price, freight    |
| olist_products         | Product category (Portuguese), dimensions, weight        |
| olist_order_reviews    | Customer review score (1–5) and comment per order        |
| olist_order_payments   | Payment type, installments, and value per order          |
| olist_geolocation      | Zip code prefix mapped to lat/lon coordinates            |

---

## Technical Stack

| Layer                 | Technology                                  |
|-----------------------|---------------------------------------------|
| Data source           | Olist public dataset (Kaggle, 9 CSV files)  |
| Storage               | PostgreSQL 15                               |
| Transformation        | dbt Core                                    |
| Business intelligence | Power BI Desktop, DAX                       |
| Version control       | Git / GitHub                                |

---

## Power BI Semantic Model

The Power BI layer contains DAX measures organized across four analytical folders:

- Sales KPIs: total revenue, total orders, average basket, year-over-year growth
- Seller Metrics: revenue per seller, order count per seller, seller ranking
- Logistics Metrics: delivery rate, average delay, median delay, max delay, cancellation count
- Time Intelligence: monthly trends, year comparison, rolling totals

---

## Glossary — French to English Reference

This section translates all French labels used in the Power BI dashboards and data pipeline.
Use this as a reference guide when reading charts, axis labels, KPI cards, and field names.

### Dashboard Labels

| French label | English translation | Context |
|---|---|---|
| Ventes | Sales / Revenue | Total monetary value of orders |
| Commandes | Orders | Individual purchase transactions |
| Vendeur | Seller | A merchant registered on the Olist platform |
| Livraison | Delivery | The act of shipping a product to the customer |
| Délai de livraison | Delivery delay | Number of days between order placement and receipt |
| Délai livraison médian | Median delivery delay | The middle value of all delivery delays (robust to outliers) |
| Délai livraison max | Max delivery delay | The longest recorded delivery time in the dataset |
| Taux de livraison | Delivery rate | Percentage of orders successfully delivered |
| Commandes annulées | Canceled orders | Orders that were canceled before or during delivery |
| Croissance | Growth | Year-over-year revenue increase expressed as a percentage |
| Panier moyen | Average basket | Mean revenue per order (Total Sales / Total Orders) |
| CA par Vendeur | Revenue per Seller | Average total revenue attributed to one seller |
| Mois | Month | Calendar month of the order |
| Année | Year | Calendar year of the order |
| Statut de commande | Order status | Current state of the order in its fulfillment lifecycle |

### Order Status Labels (order_status)

| French/English label | Meaning |
|---|---|
| delivered | Order successfully delivered to the customer |
| shipped | Order dispatched by the seller, in transit |
| canceled | Order canceled before or after shipment |
| unavailable | Product or order not available for fulfillment |
| invoiced | Order invoiced but not yet shipped |
| processing | Order accepted, being prepared by the seller |
| created | Order record created, payment not yet confirmed |
| approved | Payment approved, awaiting seller processing |

### Key Metrics — Definitions

| Metric | Formula / Definition |
|---|---|
| Total Sales (R$) | Sum of all order item prices across all delivered and non-canceled orders |
| Total Orders | Count of distinct order IDs in the dataset |
| Average Basket (R$) | Total Sales / Total Orders |
| Delivery Rate (%) | Delivered Orders / Total Orders × 100 |
| Avg Delivery Delay (days) | Mean of (delivery date − order purchase date) across delivered orders |
| Median Delivery Delay (days) | Median of (delivery date − order purchase date) — less sensitive to extreme values |
| Max Delivery Delay (days) | Maximum value of (delivery date − order purchase date) in the dataset |
| Revenue per Seller (R$) | Total Sales / Count of distinct active sellers |
| Growth 2017 vs 2018 (%) | (Revenue 2018 − Revenue 2017) / Revenue 2017 × 100 |
| Canceled Orders | Count of orders where order_status = 'canceled' |

### Time Dimension

| French label | English label | Notes |
|---|---|---|
| order_month | Order month | Calendar month extracted from order purchase date |
| order_month_num | Order month number | Integer (1–12) representing the month, aggregated across years |
| order_year | Order year | Calendar year: 2016, 2017, or 2018 |
| saison | Season | Season of the order (Summer / Spring / Autumn / Winter) |

### Seller Dimension

| French/English field | Meaning |
|---|---|
| seller_id | Unique identifier (UUID) for each registered seller |
| seller_state | Brazilian state where the seller is located |
| seller_city | Brazilian city where the seller is located |

### Chart Types — Reading Guide

| Chart type | How to read it |
|---|---|
| Line chart (courbe) | X-axis = time dimension. Y-axis = measured value. Each point = one period. Rising slope = growth. |
| Horizontal bar chart | Each bar = one category. Bar length = magnitude of the measure. Longer bar = higher value. |
| Vertical bar chart | Each bar = one time period or category. Bar height = measured value. |
| Donut chart | Each slice = one category's share of the total. Percentages shown on arc labels. |
| KPI card | Single large number. Represents one key metric for the entire filtered scope. |

---

## License

MIT License. This project uses the publicly available Olist E-Commerce dataset.
Original data source: [Olist on Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).
