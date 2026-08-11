USE customer_segmentation_analysis;

LOAD DATA LOCAL INFILE 'D:/PORTOFOLIO DATA ANALYST/customer-segmentation-analysis/data/processed/online_retail_cleaned.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    invoice_no,
    stock_code,
    description,
    quantity,
    invoice_date,
    unit_price,
    @customer_id,
    country,
    @is_cancelled,
    revenue
)
SET customer_id = NULLIF(TRIM(@customer_id), '');