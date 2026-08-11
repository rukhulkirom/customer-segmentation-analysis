USE customer_segmentation_analysis;

SELECT 
    COUNT(*) AS total_rows 
FROM transactions;

SELECT 
    COUNT(*) AS total_rows, 
    COUNT(DISTINCT invoice_no) AS unique_invoices, 
    COUNT(DISTINCT stock_code) AS unique_products, 
    COUNT(DISTINCT customer_id) AS unique_customers, 
    MIN(invoice_date) AS min_invoice_date, 
    MAX(invoice_date) AS max_invoice_date, 
    SUM(revenue) AS total_revenue 
FROM transactions;

SELECT 
    SUM(invoice_no IS NULL) AS missing_invoice_no, 
    SUM(stock_code IS NULL) AS missing_stock_code, 
    SUM(description IS NULL) AS missing_description, 
    SUM(quantity IS NULL) AS missing_quantity, 
    SUM(invoice_date IS NULL) AS missing_invoice_date, 
    SUM(unit_price IS NULL) AS missing_unit_price, 
    SUM(customer_id IS NULL) AS missing_customer_id, 
    SUM(country IS NULL) AS missing_country, 
    SUM(revenue IS NULL) AS missing_revenue 
FROM transactions;

SELECT 
    COUNT(*) AS invalid_quantity_rows 
FROM transactions 
WHERE quantity <= 0;

SELECT 
    COUNT(*) AS invalid_unit_price_rows 
FROM transactions 
WHERE unit_price <= 0;

SELECT 
    COUNT(*) AS invalid_revenue_rows 
FROM transactions 
WHERE revenue <= 0;

SELECT 
    COUNT(*) AS mismatched_rows 
FROM transactions 
WHERE ABS( revenue - (quantity * unit_price) ) > 0.01;

SELECT 
    CASE 
        WHEN customer_id IS NULL THEN 'Missing' 
        ELSE 'Available' 
    END AS customer_status, 
    COUNT(*) AS row_count 
FROM transactions 
GROUP BY customer_status;

SELECT 
    MIN(invoice_date) AS min_invoice_date, 
    MAX(invoice_date) AS max_invoice_date 
FROM transactions;

SELECT 
    COUNT(*) AS total_rows, 
    MIN(revenue) AS min_revenue, 
    MAX(revenue) AS max_revenue, 
    AVG(revenue) AS avg_revenue, 
    SUM(revenue) AS total_revenue 
FROM transactions;

SELECT 
    transaction_id, 
    invoice_no, 
    stock_code, 
    quantity, 
    unit_price, 
    customer_id, 
    revenue 
FROM transactions 
ORDER BY transaction_id 
LIMIT 20;