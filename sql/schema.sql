CREATE DATABASE IF NOT EXISTS customer_segmentation_analysis;

USE customer_segmentation_analysis;

CREATE TABLE transactions (
    transaction_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    invoice_no VARCHAR(20) NOT NULL,
    stock_code VARCHAR(20) NOT NULL,
    description VARCHAR(255) NOT NULL,
    quantity INT NOT NULL,
    invoice_date DATETIME NOT NULL,
    unit_price DECIMAL(12,4) NOT NULL,
    customer_id INT NULL,
    country VARCHAR(100) NOT NULL,
    revenue DECIMAL(14,4) NOT NULL
);