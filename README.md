# Retail Sales and Order Operations Analytics

## Project Overview

This project analyzes retail sales, customer activity, product performance,
payment methods, and order delivery operations using an e-commerce dataset.

The goal is to demonstrate an end-to-end data analytics workflow by cleaning
the data in Python, storing and analyzing it in MySQL, and presenting the
results in an interactive Power BI dashboard.

## Business Questions

This project explores the following questions:

- How much revenue was generated from delivered orders?
- How many orders and unique customers were recorded?
- Which product categories generated the most sales?
- Which customer states generated the most sales?
- How did sales change over time?
- What percentage of delivered orders arrived late?
- Which payment methods generated the most payment value?

## Tools Used

- Python and pandas: Data cleaning and preparation
- Jupyter Notebook: Documenting the cleaning workflow
- MySQL: Relational data storage and SQL analysis
- Power BI: Data modeling, DAX measures, and dashboard development
- GitHub: Project documentation and version control

## Dataset

This project uses the Brazilian E-Commerce Public Dataset by Olist. It contains
information about customers, orders, order items, products, payments, sellers,
and delivery activity.

Five cleaned tables were used in the analysis:

- Customers: 99,441 rows
- Orders: 99,441 rows
- Order Items: 112,650 rows
- Products: 32,951 rows
- Payments: 103,886 rows

## Data Preparation

Python and pandas were used to:

- Load and inspect the original CSV files
- Check for duplicate records and missing values
- Standardize customer city and state values
- Convert date columns to the correct data types
- Create order purchase date and delivery performance fields
- Add English product category names
- Export cleaned CSV files for MySQL and Power BI

## SQL Analysis

The cleaned data was loaded into a MySQL database containing five related
tables. SQL queries were written to analyze:

- Overall sales and order performance
- Order status distribution
- Monthly sales trends
- Top-performing product categories
- Sales by customer state
- On-time and late delivery performance
- Payment method usage and value

The SQL scripts are available in the (sql) folder.

## Power BI Dashboard

The interactive dashboard includes:

- Delivered sales
- Delivered orders
- Unique customers
- Average order value
- Average delivery time
- Late delivery rate
- Monthly delivered-sales trends
- Top product categories
- Leading customer states
- On-time versus late deliveries
- Delivered payment value by payment method
- Date, state, and product-category slicers

Retail Sales and Order Operations Dashboard - (images/dashboard_overview.png)

## Key Findings

- Delivered orders generated approximately $15.42 million in product sales.
- The dataset contains approximately 96,478 delivered orders and 96,096 unique customers.
- Average order value was approximately $159.83.
- Average delivery time was approximately 12.1 days.
- Approximately 7.9% of delivered orders were delivered late.
- Credit cards represented the largest share of payment value.

## Skills Demonstrated

- Data cleaning and validation
- Python and pandas
- Relational database design
- SQL joins, aggregations, grouping, and filtering
- Power BI data modeling
- DAX measure development
- Interactive dashboard design
- Business-focused analysis
- Data storytelling and documentation

## Project Status

The core analysis and interactive dashboard are complete. Additional
documentation and dashboard enhancements may be added as the project develops.