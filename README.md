

# 📊 GoldenMart Sales Intelligence – SQL Data Analysis Project

## 🧭 Overview

This project presents an advanced SQL-based analysis of GoldenMart’s sales ecosystem using **Microsoft SQL Server Management Studio (SSMS)**. It transforms raw transactional data into actionable business insights, including customer segmentation, product performance evaluation, and category-level contribution analysis.

All logic and SQL queries are written and structured inside the `sql_data_analysis_project.sql` file.

---

## 🎯 Project Objectives

* Track total and cumulative sales over daily, monthly, and yearly periods
* Benchmark product sales against historical and average trends
* Segment customers based on purchase activity, value, and lifespan
* Identify category contributions to overall revenue
* Provide dashboard-ready data outputs using SQL views

---

## 🗃️ Datasets and Tables Used

| Table Name           | Description                                                                     |
| -------------------- | ------------------------------------------------------------------------------- |
| `gold_fact_sales`    | Transaction-level data: order date, amount, quantity, customer key, product key |
| `gold_dim_products`  | Product metadata: product name, category, cost, price                           |
| `gold_dim_customers` | Customer metadata: name, birthdate, customer key                                |

---

## 🧠 SQL Concepts & Features Applied

* **Joins**: `LEFT JOIN` to integrate facts with dimensions
* **Window Functions**: `LAG()`, `SUM() OVER`, `AVG() OVER` for comparisons and running totals
* **Aggregations**: `SUM()`, `COUNT(DISTINCT)`, `AVG()` for metrics
* **Time Functions**: `YEAR()`, `MONTH()`, `DATEDIFF()`, `DATETRUNC()`
* **Conditional Logic**: `CASE WHEN` for customer and product classification
* **Common Table Expressions (CTEs)** for stepwise query construction
* **SQL Views** for reporting integration

---

## 🧮 Key Analytical Logic

### 📆 Time-Based Analysis

* Daily, monthly, and yearly sales tracking
* Cumulative revenue using `SUM() OVER (...)`
* Moving average of yearly product prices

### 📦 Product and Category Insights

* Compare product sales against average and prior year
* Label growth as `Above Average`, `Decline`, or `Stable`
* Evaluate category contributions to total revenue as a percentage

### 👥 Customer Segmentation

* Classify customers as:

  * `VIP`: High spenders with long tenure
  * `Regular`: Consistent spenders
  * `Beginner`: Low activity or new customers
* Use metrics like:

  * Total sales
  * Lifespan (months between first and last order)
  * Recency
  * Age grouping
  * Average order value

### 📊 Reporting View

* Created a consolidated SQL view: `gold_report_customers`
* Contains:

  * Customer key and name
  * Total orders and sales
  * Average monthly spend
  * Recency, product diversity, age group
  * Status (VIP, Regular, Beginner)

---

## 📈 Sample KPIs Generated

* 📅 Monthly and yearly sales volumes
* 🎯 Top product and customer performance
* 📦 Product segmentation (e.g., affordable, expensive)
* 💰 Category-wise revenue share
* 👤 Customer lifetime value and activity heatmap

---

## ✅ Final Insights & Recommendations

* **VIP customers (spending > ₹5000 and active > 12 months)** are the most profitable and should be retained through loyalty programs
* Certain product categories dominate revenue — double down on marketing these
* Products with declining YOY growth should be investigated for pricing or demand issues
* Younger customers (age 20–39) dominate — campaigns should align with their preferences
* `gold_report_customers` view can be used directly in **Power BI**, **Excel**, or other BI tools for visualization

---

## 🛠️ Tools Used

* Microsoft SQL Server Management Studio (SSMS)
* SQL Server 2019+
* `.sql` file: `sql_data_analysis_project.sql`

---

## 👤 Author

Created with 💡 by **[Naveen Gill](https://www.linkedin.com/in/naveen-gill-2b0829281)**
🔗 GitHub: [Naveen-0428](https://github.com/Naveen-0428)



