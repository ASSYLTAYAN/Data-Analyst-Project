CREATE DATABASE Customers_transactions;

SET SQL_SAFE_UPDATES = 0;
UPDATE customers SET Gender = NULL WHERE Gender = '';
UPDATE customers SET Age = NULL WHERE Age = '';
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE customers MODIFY AGE INT NULL ;

SELECT * FROM customers;

CREATE TABLE transactions
(
date_new DATE,
Id_check INT,
ID_client INT,
Count_products DECIMAL(10,3),
Sum_payment DECIMAL (10,2)
);

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\TRANSACTIONS_final.csv"
INTO TABLE transactions
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS ;

SELECT * FROM transactions;
SELECT * FROM customers;

#1
SELECT ID_client, COUNT(*) as total_transactions,
ROUND(SUM(Sum_payment)/ COUNT(*), 2 ) as avg_check,
ROUND(SUM(Sum_payment)/ 12, 2 ) as avg_month_spend
FROM transactions
WHERE date_new >= '2015-06-01' AND date_new < '2016-06-01'
GROUP BY ID_client
HAVING COUNT(DISTINCT DATE_FORMAT(date_new, '%Y-%m')) = 12;


#2

SELECT DATE_FORMAT(date_new, '%Y-%m') AS month,
ROUND(AVG(Sum_payment), 2) AS avg_check,
COUNT(*) AS total_operations, 
COUNT(DISTINCT ID_client) AS unique_clients,
ROUND(COUNT(*) / (SELECT COUNT(*) FROM transactions) * 100, 2) AS operation_share_percent,
ROUND(SUM(Sum_payment), 2) AS month_total_payment,
ROUND(SUM(Sum_payment) / (SELECT SUM(Sum_payment) FROM transactions) * 100, 2) AS payment_share_percent
FROM transactions
WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY month
ORDER BY month;

SELECT Gender, COUNT(*) AS total_clients,
ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customers), 2) AS percent_clients,
SUM(Total_amount) AS total_amount,
ROUND(SUM(Total_amount) * 100.0 / (SELECT SUM(Total_amount) FROM customers), 2) AS percent_amount
FROM customers
GROUP BY Gender;



#3 

SELECT 
  CASE 
    WHEN c.AGE IS NULL THEN 'Unknown'
    WHEN c.AGE BETWEEN 0 AND 9 THEN '0-9'
    WHEN c.AGE BETWEEN 10 AND 19 THEN '10-19'
    WHEN c.AGE BETWEEN 20 AND 29 THEN '20-29'
    WHEN c.AGE BETWEEN 30 AND 39 THEN '30-39'
    WHEN c.AGE BETWEEN 40 AND 49 THEN '40-49'
    WHEN c.AGE BETWEEN 50 AND 59 THEN '50-59'
    WHEN c.AGE >= 60 THEN '60+'
  END AS age_group,

  YEAR(t.date_new) AS year,
  QUARTER(t.date_new) AS quarter,
  COUNT(*) AS total_operations,
  COUNT(DISTINCT c.ID_client) AS total_clients,
  ROUND(SUM(t.Sum_payment), 2) AS total_amount,
  ROUND(AVG(t.Sum_payment), 2) AS avg_payment_per_operation,
  ROUND(SUM(t.Sum_payment) * 100 / 
        (SELECT SUM(Sum_payment) FROM transactions 
         WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'), 2) AS percent_of_total_amount

FROM customers c
JOIN transactions t ON c.ID_client = t.ID_client
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY age_group, year, quarter
ORDER BY year, quarter, age_group;


  







