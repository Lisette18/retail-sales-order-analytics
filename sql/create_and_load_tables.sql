/* ============================================================
   RETAIL SALES AND ORDER OPERATIONS ANALYTICS
   File: create_and_load_tables.sql

   Purpose:
   1. Create the project database
   2. Create all five tables
   3. Load the cleaned CSV files
   4. Validate the completed database

   Tables:
   - customers
   - orders
   - order_items
   - products
   - payments
   ============================================================ */


/* ============================================================
   1. DATABASE SETUP
   ============================================================ */

CREATE DATABASE IF NOT EXISTS retail_operations;

USE retail_operations;

-- Allow MySQL to import local CSV files.
SET GLOBAL local_infile = 1;


/* ============================================================
   2. CREATE AND LOAD CUSTOMERS
   ============================================================ */

DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id              VARCHAR(50) PRIMARY KEY,
    customer_unique_id       VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city            VARCHAR(100),
    customer_state           VARCHAR(10)
);

LOAD DATA LOCAL INFILE
'C:/Users/liset/Documents/GitHub/retail-sales-order-analytics/data/cleaned/customers_clean.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
);


/* ============================================================
   3. CREATE AND LOAD ORDERS
   ============================================================ */

DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    order_id                       VARCHAR(50) PRIMARY KEY,
    customer_id                    VARCHAR(50),
    order_status                   VARCHAR(30),
    order_purchase_timestamp       DATETIME,
    order_approved_at              DATETIME,
    order_delivered_carrier_date   DATETIME,
    order_delivered_customer_date  DATETIME,
    order_estimated_delivery_date  DATETIME,
    order_purchase_date            DATE,
    delivery_days                  DECIMAL(10, 2),
    is_late                        TINYINT
);

LOAD DATA LOCAL INFILE
'C:/Users/liset/Documents/GitHub/retail-sales-order-analytics/data/cleaned/orders_clean.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    @order_approved_at,
    @order_delivered_carrier_date,
    @order_delivered_customer_date,
    order_estimated_delivery_date,
    order_purchase_date,
    @delivery_days,
    @is_late
)
SET
    order_approved_at =
        NULLIF(@order_approved_at, ''),

    order_delivered_carrier_date =
        NULLIF(@order_delivered_carrier_date, ''),

    order_delivered_customer_date =
        NULLIF(@order_delivered_customer_date, ''),

    delivery_days =
        NULLIF(@delivery_days, ''),

    is_late =
        CASE
            WHEN LOWER(@is_late) = 'true' THEN 1
            WHEN LOWER(@is_late) = 'false' THEN 0
            ELSE NULL
        END;


/* ============================================================
   4. CREATE AND LOAD ORDER ITEMS
   ============================================================ */

DROP TABLE IF EXISTS order_items;

CREATE TABLE order_items (
    order_id            VARCHAR(50),
    order_item_id       INT,
    product_id          VARCHAR(50),
    seller_id           VARCHAR(50),
    shipping_limit_date DATETIME,
    price               DECIMAL(10, 2),
    freight_value       DECIMAL(10, 2)
);

LOAD DATA LOCAL INFILE
'C:/Users/liset/Documents/GitHub/retail-sales-order-analytics/data/cleaned/order_items_clean.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
);


/* ============================================================
   5. CREATE AND LOAD PRODUCTS
   ============================================================ */

DROP TABLE IF EXISTS products;

CREATE TABLE products (
    product_id                 VARCHAR(50) PRIMARY KEY,
    product_category_name      VARCHAR(100),
    product_name_length        INT,
    product_description_length INT,
    product_photos_qty         INT,
    product_weight_g           DECIMAL(10, 2),
    product_length_cm          DECIMAL(10, 2),
    product_height_cm          DECIMAL(10, 2),
    product_width_cm           DECIMAL(10, 2),
    product_category_english   VARCHAR(100)
);

LOAD DATA LOCAL INFILE
'C:/Users/liset/Documents/GitHub/retail-sales-order-analytics/data/cleaned/products_clean.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    product_id,
    product_category_name,
    @product_name_length,
    @product_description_length,
    @product_photos_qty,
    @product_weight_g,
    @product_length_cm,
    @product_height_cm,
    @product_width_cm,
    product_category_english
)
SET
    product_name_length =
        NULLIF(@product_name_length, ''),

    product_description_length =
        NULLIF(@product_description_length, ''),

    product_photos_qty =
        NULLIF(@product_photos_qty, ''),

    product_weight_g =
        NULLIF(@product_weight_g, ''),

    product_length_cm =
        NULLIF(@product_length_cm, ''),

    product_height_cm =
        NULLIF(@product_height_cm, ''),

    product_width_cm =
        NULLIF(@product_width_cm, '');


/* ============================================================
   6. CREATE AND LOAD PAYMENTS
   ============================================================ */

DROP TABLE IF EXISTS payments;

CREATE TABLE payments (
    order_id             VARCHAR(50),
    payment_sequential   INT,
    payment_type         VARCHAR(30),
    payment_installments INT,
    payment_value        DECIMAL(10, 2)
);

LOAD DATA LOCAL INFILE
'C:/Users/liset/Documents/GitHub/retail-sales-order-analytics/data/cleaned/payments_clean.csv'
INTO TABLE payments
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
);


/* ============================================================
   7. VALIDATE TABLE ROW COUNTS
   ============================================================ */

SELECT
    'customers' AS table_name,
    COUNT(*) AS row_count
FROM customers

UNION ALL

SELECT
    'orders',
    COUNT(*)
FROM orders

UNION ALL

SELECT
    'order_items',
    COUNT(*)
FROM order_items

UNION ALL

SELECT
    'products',
    COUNT(*)
FROM products

UNION ALL

SELECT
    'payments',
    COUNT(*)
FROM payments;


/* ============================================================
   8. CHECK MISSING DELIVERY DATES
   ============================================================ */

SELECT
    COUNT(*) AS missing_delivery_dates
FROM orders
WHERE order_delivered_customer_date IS NULL;


/* ============================================================
   9. EXPECTED RESULTS

   customers:    99,441 rows
   orders:       99,441 rows
   order_items: 112,650 rows
   products:     32,951 rows
   payments:    103,886 rows

   Missing order delivery dates: 2,965
   ============================================================ */