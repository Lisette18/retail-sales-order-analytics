/* ============================================================
   RETAIL SALES AND ORDER OPERATIONS ANALYTICS
   File: analysis_queries.sql

   Purpose:
   Answer business questions related to sales, customers,
   products, order fulfillment, and payment behavior.

   Analysis areas:
   1. Overall business performance
   2. Order status distribution
   3. Monthly sales trend
   4. Top product categories
   5. Sales by customer state
   6. Overall delivery performance
   7. Delivery performance by state
   8. Payment method usage
   ============================================================ */

USE retail_operations;


/* ============================================================
   1. OVERALL BUSINESS PERFORMANCE

   Business question:
   What are the overall sales and order performance metrics
   for completed deliveries?
   ============================================================ */

WITH order_totals AS (
    SELECT
        o.order_id,
        c.customer_unique_id,
        SUM(oi.price) AS product_sales,
        SUM(oi.freight_value) AS freight_cost,
        SUM(oi.price + oi.freight_value) AS order_value
    FROM orders AS o
    INNER JOIN customers AS c
        ON o.customer_id = c.customer_id
    INNER JOIN order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY
        o.order_id,
        c.customer_unique_id
)

SELECT
    COUNT(*) AS delivered_orders,
    COUNT(DISTINCT customer_unique_id) AS unique_customers,
    ROUND(SUM(product_sales), 2) AS total_product_sales,
    ROUND(SUM(freight_cost), 2) AS total_freight,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(AVG(order_value), 2) AS average_order_value
FROM order_totals;


/* ============================================================
   2. ORDER STATUS DISTRIBUTION

   Business question:
   How many orders are associated with each order status?
   ============================================================ */

SELECT
    order_status,
    COUNT(*) AS total_orders,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


/* ============================================================
   3. MONTHLY SALES TREND

   Business question:
   How did delivered orders and sales change each month?
   ============================================================ */

SELECT
    DATE_FORMAT(
        o.order_purchase_date,
        '%Y-%m'
    ) AS sales_month,

    COUNT(DISTINCT o.order_id) AS total_orders,

    ROUND(
        SUM(oi.price),
        2
    ) AS product_sales,

    ROUND(
        SUM(oi.freight_value),
        2
    ) AS freight_cost,

    ROUND(
        SUM(oi.price + oi.freight_value),
        2
    ) AS total_order_value

FROM orders AS o
INNER JOIN order_items AS oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'delivered'

GROUP BY
    DATE_FORMAT(o.order_purchase_date, '%Y-%m')

ORDER BY sales_month;


/* ============================================================
   4. TOP PRODUCT CATEGORIES

   Business question:
   Which product categories generated the most sales?
   ============================================================ */

SELECT
    COALESCE(
        NULLIF(p.product_category_english, ''),
        'Unknown'
    ) AS product_category,

    COUNT(*) AS units_sold,

    COUNT(DISTINCT o.order_id) AS total_orders,

    ROUND(
        SUM(oi.price),
        2
    ) AS product_sales,

    ROUND(
        AVG(oi.price),
        2
    ) AS average_item_price

FROM orders AS o
INNER JOIN order_items AS oi
    ON o.order_id = oi.order_id
INNER JOIN products AS p
    ON oi.product_id = p.product_id

WHERE o.order_status = 'delivered'

GROUP BY
    COALESCE(
        NULLIF(p.product_category_english, ''),
        'Unknown'
    )

ORDER BY product_sales DESC

LIMIT 10;


/* ============================================================
   5. SALES BY CUSTOMER STATE

   Business question:
   Which customer states generated the most orders and sales?
   ============================================================ */

SELECT
    c.customer_state,

    COUNT(
        DISTINCT c.customer_unique_id
    ) AS unique_customers,

    COUNT(
        DISTINCT o.order_id
    ) AS total_orders,

    ROUND(
        SUM(oi.price),
        2
    ) AS product_sales,

    ROUND(
        SUM(oi.price) /
        COUNT(DISTINCT o.order_id),
        2
    ) AS average_sales_per_order

FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN order_items AS oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'delivered'

GROUP BY c.customer_state

ORDER BY product_sales DESC;


/* ============================================================
   6. OVERALL DELIVERY PERFORMANCE

   Business question:
   How long did deliveries take, and what percentage arrived
   by the estimated delivery date?
   ============================================================ */

SELECT
    COUNT(*) AS delivered_orders,

    ROUND(
        AVG(delivery_days),
        2
    ) AS average_delivery_days,

    SUM(
        CASE
            WHEN order_delivered_customer_date
                 <= order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS on_time_orders,

    SUM(
        CASE
            WHEN order_delivered_customer_date
                 > order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS late_orders,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN order_delivered_customer_date
                     <= order_estimated_delivery_date
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS on_time_percentage

FROM orders

WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;


/* ============================================================
   7. DELIVERY PERFORMANCE BY STATE

   Business question:
   Which customer states had the fastest delivery times and
   the highest on-time delivery percentages?
   ============================================================ */

SELECT
    c.customer_state,

    COUNT(*) AS delivered_orders,

    ROUND(
        AVG(o.delivery_days),
        2
    ) AS average_delivery_days,

    SUM(
        CASE
            WHEN o.order_delivered_customer_date
                 > o.order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS late_orders,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN o.order_delivered_customer_date
                     <= o.order_estimated_delivery_date
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS on_time_percentage

FROM orders AS o
INNER JOIN customers AS c
    ON o.customer_id = c.customer_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL

GROUP BY c.customer_state

ORDER BY on_time_percentage DESC;


/* ============================================================
   8. PAYMENT METHOD USAGE

   Business question:
   Which payment methods were used most frequently, and how
   much payment value was associated with each method?
   ============================================================ */

SELECT
    p.payment_type,

    COUNT(*) AS payment_transactions,

    COUNT(
        DISTINCT p.order_id
    ) AS total_orders,

    ROUND(
        SUM(p.payment_value),
        2
    ) AS total_payment_value,

    ROUND(
        AVG(p.payment_value),
        2
    ) AS average_payment_value,

    ROUND(
        AVG(p.payment_installments),
        2
    ) AS average_installments

FROM payments AS p
INNER JOIN orders AS o
    ON p.order_id = o.order_id

WHERE o.order_status = 'delivered'

GROUP BY p.payment_type

ORDER BY total_payment_value DESC;