# DataX_intern_task4
SQL for Data Analysis
# Task 4: SQL for Data Analysis — E-Commerce Database

##  Project Overview
This project focuses on querying, manipulating, and analyzing structured relational data using SQL in MySQL Workbench. Starting from an un-normalized raw e-commerce transaction dataset, the schema was normalized into a multi-table relational architecture with enforced primary and foreign key constraints. A sequence of analytical SQL operations was then executed to extract business metrics, analyze customer behavior, and evaluate query performance.

* **Objective:** Use SQL queries to extract, aggregate, and analyze structured data from a relational database.
* **Tool Used:** MySQL Workbench / MySQL Server.
* **Dataset:** E-Commerce Transaction Records (`nabihazahid/ecommerce-dataset-for-sql-analysis`).
* **Deliverables:** Normalized SQL script (`task4_SQL_queries.sql`), execution screenshots, and repository documentation.

---

##  Database Schema & Normalization

The initial staging table (`raw_ecommerce`) was normalized into four distinct tables to enforce relational integrity and eliminate redundancy:

* **`customers` (4,327 rows):** Contains customer demographic profiles.
  * *Primary Key:* `customer_id` (`VARCHAR(25)`)
* **`products` (15 rows):** Standard catalog table containing product names, categories, and list prices.
  * *Primary Key:* `product_id` (`VARCHAR(25)`)
* **`orders` (10,000 rows):** Line-item transaction records mapping purchases to customers and products.
  * *Composite Primary Key:* `(order_id, product_id)`
  * *Foreign Keys:* `customer_id` → `customers(customer_id)`, `product_id` → `products(product_id)`
* **`reviews` (10,000 rows):** Customer ratings and review submissions linked to specific order lines.
  * *Primary Key:* `review_id` (`VARCHAR(25)`)
  * *Foreign Key:* `order_id`

---

##  SQL Analysis & Operations

The analysis script covers the following technical requirements:

1. **Filtering, Aggregation & Grouping (`SELECT`, `WHERE`, `GROUP BY`, `ORDER BY`):**
   * Evaluated completed orders and aggregate unit volumes grouped by payment method.
2. **Relational Joins (`INNER`, `LEFT`, `RIGHT`):**
   * **`INNER JOIN`:** Calculated total revenue per order line by joining `orders` and `products`.
   * **`LEFT JOIN`:** Identified total lifetime orders placed per customer across demographics, preserving inactive user records.
   * **`RIGHT JOIN`:** Evaluated product review coverage by correlating low-score feedback (1-star ratings) with product lines.
3. **Nested Subqueries:**
   * Filtered for high-volume transactions purchasing units above the global order average.
4. **Summary Metrics & ARPU Calculation:**
   * Aggregated platform-wide gross sales, total unique customers, average order value, and **Average Revenue Per User (ARPU)**.
5. **Database Views:**
   * Created `vw_customer_order_summary` to join customer demographics, product lines, transaction amounts, and review scores into a modular reporting layer.
6. **Query Optimization via Indexing:**
   * Built B-Tree indexes on high-frequency filtering and join columns (`order_date` on `orders`, `country` on `customers`) to optimize execution performance.

---

##  Repository Deliverables

* `task4_SQL_queries.sql` — Schema creation, data normalization, constraints, and analytical queries.
* `screenshots/` — Images confirming query execution results from MySQL Workbench.
* `README.md` — Project summary and architectural overview.
