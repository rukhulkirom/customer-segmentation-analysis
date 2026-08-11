-- ============================================================
-- SQL BUSINESS ANALYSIS
-- ============================================================

USE customer_segmentation_analysis;

-- ============================================================
-- 1. SALES PERFORMANCE
-- ============================================================

-- ------------------------------------------------------------
-- 1.1 Total Revenue
-- ------------------------------------------------------------

SELECT
    ROUND(SUM(revenue), 2) AS total_revenue
FROM transactions;

-- ------------------------------------------------------------
-- 1.2 Total Transactions / Orders
-- ------------------------------------------------------------

SELECT
    COUNT(DISTINCT invoice_no) AS total_transactions
FROM transactions;

-- ------------------------------------------------------------
-- 1.3 Average Order Value (AOV)
-- ------------------------------------------------------------

SELECT
    ROUND(
        SUM(revenue) / COUNT(DISTINCT invoice_no),
        2
    ) AS average_order_value
FROM transactions;

-- ------------------------------------------------------------
-- 1.4 Monthly Revenue
-- ------------------------------------------------------------

SELECT
    DATE_FORMAT(invoice_date, '%Y-%m') AS month,
    COUNT(DISTINCT invoice_no) AS total_transactions,
    ROUND(SUM(revenue), 2) AS monthly_revenue
FROM transactions
GROUP BY DATE_FORMAT(invoice_date, '%Y-%m')
ORDER BY month;

-- ------------------------------------------------------------
-- 1.5 Monthly Revenue Growth
-- ------------------------------------------------------------

WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(invoice_date, '%Y-%m') AS month,
        SUM(revenue) AS revenue
    FROM transactions
    GROUP BY DATE_FORMAT(invoice_date, '%Y-%m')
),

monthly_growth AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (
            ORDER BY month
        ) AS previous_revenue
    FROM monthly_sales
)

SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(previous_revenue, 2) AS previous_revenue,
    ROUND(
        (revenue - previous_revenue)
        / NULLIF(previous_revenue, 0) * 100,
        2
    ) AS growth_percentage
FROM monthly_growth
ORDER BY month;

-- ------------------------------------------------------------
-- 1.6 Top Products by Revenue
-- ------------------------------------------------------------

SELECT
    stock_code,
    MAX(description) AS description,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT invoice_no) AS total_orders,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM transactions
WHERE description IS NOT NULL
GROUP BY stock_code
ORDER BY total_revenue DESC
LIMIT 10;

-- ============================================================
-- 2. CUSTOMER ANALYSIS
-- ============================================================

-- ------------------------------------------------------------
-- 2.1 Total Customers
-- ------------------------------------------------------------

SELECT
    COUNT(DISTINCT customer_id) AS total_customers
FROM transactions
WHERE customer_id IS NOT NULL;

-- ------------------------------------------------------------
-- 2.2 Average Revenue per Identified Customer
-- ------------------------------------------------------------

SELECT
    ROUND(
        SUM(revenue)
        / COUNT(DISTINCT customer_id),
        2
    ) AS average_revenue_per_customer
FROM transactions
WHERE customer_id IS NOT NULL;

-- ------------------------------------------------------------
-- 2.3 Top Customers by Revenue
-- ------------------------------------------------------------

SELECT
    customer_id,
    COUNT(DISTINCT invoice_no) AS total_orders,
    SUM(quantity) AS total_quantity,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM transactions
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY total_revenue DESC
LIMIT 10;

-- ------------------------------------------------------------
-- 2.4 Purchase Frequency
-- ------------------------------------------------------------

SELECT
    customer_id,
    COUNT(DISTINCT invoice_no) AS purchase_frequency
FROM transactions
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY purchase_frequency DESC;

-- ------------------------------------------------------------
-- 2.5 Customer Contribution
-- ------------------------------------------------------------

WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(revenue) AS customer_revenue
    FROM transactions
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
)

SELECT
    customer_id,
    ROUND(customer_revenue, 2) AS customer_revenue,
    ROUND(
        customer_revenue
        / SUM(customer_revenue) OVER () * 100,
        2
    ) AS revenue_contribution_percentage
FROM customer_revenue
ORDER BY customer_revenue DESC;

-- ============================================================
-- 3. PRODUCT ANALYSIS
-- ============================================================

-- ------------------------------------------------------------
-- 3.1 Top Products by Quantity
-- ------------------------------------------------------------

SELECT
    stock_code,
    MAX(description) AS description,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT invoice_no) AS total_orders,
    SUM(revenue) AS total_revenue
FROM transactions
WHERE description IS NOT NULL
  AND stock_code NOT IN ('DOT', 'POST', 'M')
GROUP BY
    stock_code
ORDER BY total_quantity DESC
LIMIT 10;

-- ------------------------------------------------------------
-- 3.2 Top Products by Revenue
-- ------------------------------------------------------------

SELECT
    stock_code,
    MAX(description) AS description,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT invoice_no) AS total_orders,
    SUM(revenue) AS total_revenue
FROM transactions
WHERE description IS NOT NULL
  AND stock_code NOT IN ('DOT', 'POST', 'M')
GROUP BY
    stock_code
ORDER BY total_revenue DESC
LIMIT 10;

-- ------------------------------------------------------------
-- 3.3 Product Performance
-- ------------------------------------------------------------

SELECT
    stock_code,
    MAX(description) AS description,
    COUNT(DISTINCT invoice_no) AS total_orders,
    SUM(quantity) AS total_quantity,
    SUM(revenue) AS total_revenue,
    ROUND(
        SUM(revenue) / COUNT(DISTINCT invoice_no),
        2
    ) AS revenue_per_order
FROM transactions
WHERE description IS NOT NULL
  AND stock_code NOT IN ('DOT', 'POST', 'M')
GROUP BY
    stock_code
HAVING total_orders >= 100
ORDER BY total_revenue DESC
LIMIT 10;

-- ------------------------------------------------------------
-- 3.4 Product Contribution
-- ------------------------------------------------------------

SELECT
    stock_code,
    MAX(description) AS description,
    ROUND(SUM(revenue), 2) AS product_revenue,
    ROUND(
        SUM(revenue) / (
            SELECT SUM(revenue)
            FROM transactions
            WHERE stock_code NOT IN ('DOT', 'POST', 'M')
        ) * 100,
        2
    ) AS revenue_contribution_percentage
FROM transactions
WHERE description IS NOT NULL
  AND stock_code NOT IN ('DOT', 'POST', 'M')
GROUP BY stock_code
ORDER BY product_revenue DESC
LIMIT 10;

-- ============================================================
-- 4. COUNTRY ANALYSIS
-- ============================================================

-- ------------------------------------------------------------
-- 4.1 Revenue by Country
-- ------------------------------------------------------------

SELECT
    country,
    COUNT(DISTINCT invoice_no) AS total_orders,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(
        SUM(revenue) / (
            SELECT SUM(revenue)
            FROM transactions
        ) * 100,
        2
    ) AS revenue_contribution_percentage
FROM transactions
GROUP BY country
ORDER BY total_revenue DESC;

-- ------------------------------------------------------------
-- 4.2 Orders by Country
-- ------------------------------------------------------------

SELECT
    country,
    COUNT(DISTINCT invoice_no) AS total_orders,
    ROUND(
        COUNT(DISTINCT invoice_no) / (
            SELECT COUNT(DISTINCT invoice_no)
            FROM transactions
        ) * 100,
        2
    ) AS order_contribution_percentage
FROM transactions
GROUP BY country
ORDER BY total_orders DESC;

-- ------------------------------------------------------------
-- 4.3 Customer Distribution
-- ------------------------------------------------------------

SELECT
    country,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(
        COUNT(DISTINCT customer_id) / (
            SELECT COUNT(DISTINCT customer_id)
            FROM transactions
            WHERE customer_id IS NOT NULL
        ) * 100,
        2
    ) AS customer_contribution_percentage
FROM transactions
WHERE customer_id IS NOT NULL
GROUP BY country
ORDER BY total_customers DESC;

-- ============================================================
-- 5. TIME ANALYSIS
-- ============================================================

-- ------------------------------------------------------------
-- 5.1 Average Daily Revenue
-- ------------------------------------------------------------

SELECT
    DATE_FORMAT(invoice_date, '%Y-%m') AS month,
    COUNT(DISTINCT invoice_no) AS total_orders,
    SUM(quantity) AS total_quantity,
    SUM(revenue) AS total_revenue,
    ROUND(
        SUM(revenue) / COUNT(DISTINCT DATE(invoice_date)),
        2
    ) AS average_revenue_per_active_day
FROM transactions
GROUP BY DATE_FORMAT(invoice_date, '%Y-%m')
ORDER BY month;

-- ------------------------------------------------------------
-- 5.2 Daily Sales
-- ------------------------------------------------------------

SELECT
    DATE(invoice_date) AS sales_date,
    COUNT(DISTINCT invoice_no) AS total_orders,
    SUM(quantity) AS total_quantity,
    SUM(revenue) AS total_revenue
FROM transactions
GROUP BY DATE(invoice_date)
ORDER BY sales_date;

-- ------------------------------------------------------------
-- 5.3 Peak Sales Period
-- ------------------------------------------------------------

SELECT
    DATE(invoice_date) AS sales_date,
    COUNT(DISTINCT invoice_no) AS total_orders,
    SUM(quantity) AS total_quantity,
    SUM(revenue) AS total_revenue
FROM transactions
GROUP BY DATE(invoice_date)
ORDER BY total_revenue DESC
LIMIT 10;

-- ------------------------------------------------------------
-- 5.4 Seasonal Pattern
-- ------------------------------------------------------------

SELECT
    MONTH(invoice_date) AS month_number,
    MONTHNAME(invoice_date) AS month_name,
    COUNT(DISTINCT invoice_no) AS total_orders,
    SUM(quantity) AS total_quantity,
    SUM(revenue) AS total_revenue,
    ROUND(
        SUM(revenue) / COUNT(DISTINCT invoice_no),
        2
    ) AS average_order_value
FROM transactions
GROUP BY
    MONTH(invoice_date),
    MONTHNAME(invoice_date)
ORDER BY
    month_number;