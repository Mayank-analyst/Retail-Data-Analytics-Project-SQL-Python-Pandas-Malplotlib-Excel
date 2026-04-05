-- SQLite Schema for Retail Data Analytics Project
-- =========================================

-- Enable foreign key constraints
PRAGMA foreign_keys = ON;

-- Drop tables if they exist (fresh setup)
DROP TABLE IF EXISTS Retail_Data_Transactions;
DROP TABLE IF EXISTS Retail_Data_Response;

-- =========================================
-- Table 1: Retail_Data_Response
-- Stores customer responses
-- =========================================
CREATE TABLE IF NOT EXISTS Retail_Data_Response (
    customer_id TEXT PRIMARY KEY,
    response TEXT
);

-- =========================================
-- Table 2: Retail_Data_Transactions
-- Stores transactions linked to customers
-- =========================================
CREATE TABLE IF NOT EXISTS Retail_Data_Transactions (
    customer_id INTEGER NOT NULL,
    date TEXT,                 
    amount REAL,               
    FOREIGN KEY (customer_id) REFERENCES Retail_Data_Response(customer_id)
);

-- =========================================
-- Index to speed up queries joining by customer_id
-- =========================================
CREATE INDEX IF NOT EXISTS idx_transactions_customer
ON Retail_Data_Transactions(customer_id);



-- =========================================
-- DATA CLEANING QUERIES
-- =========================================

-- 1. Check missing customer_id in Response
SELECT * FROM Retail_Data_Response WHERE customer_id IS NULL;

-- 2. Check missing data in Transactions
SELECT * FROM Retail_Data_Transactions 
WHERE customer_id IS NULL OR date IS NULL OR amount IS NULL;

-- 3. Check invalid customer_id references in Transactions
SELECT * FROM Retail_Data_Transactions
WHERE customer_id NOT IN (SELECT customer_id FROM Retail_Data_Response);

-- Optional: Remove invalid transactions
DELETE FROM Retail_Data_Transactions
WHERE customer_id NOT IN (SELECT customer_id FROM Retail_Data_Response);

-- =========================================
-- DATA PREPARATION QUERIES
-- =========================================

-- 1. Total sales per customer
SELECT customer_id, SUM(amount) AS total_amount
FROM Retail_Data_Transactions
GROUP BY customer_id;

-- 2. Number of transactions per customer
SELECT customer_id, COUNT(transaction_id) AS num_transactions
FROM Retail_Data_Transactions
GROUP BY customer_id;

-- 3. Monthly sales (year-month)
SELECT 
    STRFTIME('%Y', date) AS year,
    STRFTIME('%m', date) AS month,
    SUM(amount) AS total_amount
FROM Retail_Data_Transactions
GROUP BY year, month
ORDER BY year, month;

-- 4. Average transaction amount per customer
SELECT customer_id, AVG(amount) AS avg_amount
FROM Retail_Data_Transactions
GROUP BY customer_id;

-- =========================================
-- MERGE RESPONSE WITH TRANSACTION DATA
-- =========================================
SELECT r.customer_id, r.response, SUM(t.amount) AS total_amount
FROM Retail_Data_Response r
LEFT JOIN Retail_Data_Transactions t
ON r.customer_id = t.customer_id
GROUP BY r.customer_id, r.response;

-- =========================================
-- OPTIONAL ADVANCED ANALYSIS QUERIES
-- =========================================

-- Highest transaction per customer
SELECT customer_id, MAX(amount) AS highest_transaction
FROM Retail_Data_Transactions
GROUP BY customer_id;

-- Top 5 customers by total sales
SELECT r.customer_id, r.response, SUM(t.amount) AS total_sales
FROM Retail_Data_Response r
JOIN Retail_Data_Transactions t
ON r.customer_id = t.customer_id
GROUP BY r.customer_id, r.response
ORDER BY total_sales DESC
LIMIT 5;

-- Count of customers by response type
SELECT response, COUNT(customer_id) AS num_customers
FROM Retail_Data_Response
GROUP BY response;
