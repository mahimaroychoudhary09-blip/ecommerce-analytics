-- =====================================================
-- E-COMMERCE ANALYTICS PROJECT
-- =====================================================
-- Objective:
-- Analyze sales performance, customer behavior, product trends,
-- seller activity, and the impact of ratings and reviews
-- to support data-driven decision-making.
-- =====================================================


create database Ecommerce

USE Ecommerce

  ------How much total money has the platform made so far, and how has it changed over time?---------

  -----total money has the platform made so far-------

  SELECT SUM(payment_value)
  FROM payments_table;

  -----total money has the platform made so far is 16008872.12----------

  ------how has it changed over time---------------

  SELECT 
    YEAR(o.order_purchase_timestamp) AS order_year,
    MONTH(o.order_purchase_timestamp) AS order_month,
    SUM(p.payment_value) AS total_revenue
FROM Payments_table p
JOIN Orders_table o
    ON p.order_id = o.order_id
GROUP BY 
    YEAR(o.order_purchase_timestamp),
    MONTH(o.order_purchase_timestamp)
ORDER BY 
    order_year,
    order_month;

	------The platform follows a clear product life cycle pattern. 
	-----It shows an introduction phase in late 2016, rapid growth throughout 2017,
	----and a maturity phase in early to mid-2018 with stable high revenue.
	-----A sharp decline is observed in late 2018.

------2) Which product categories are the most popular, and how do their sales numbers compare--------------
------Popularity - number of items sold per category
-----Sales comparison - total revenue per category

SELECT
pr.product_category_name AS category,
COUNT(oi.product_id) AS items_sold,
SUM(p.payment_value) AS total_revenue
FROM order_items_table oi
JOIN products_table pr
ON oi.product_id = pr.product_id
JOIN payments_table p
ON oi.order_id = p.order_id
GROUP BY pr.product_category_name
ORDER BY items_sold DESC;

-----Here we can see that bed_tableand bath have the higest number of items sold so its the most popular category  

-----3) What is the average amount spent per order (AOV), and how does it vary by category or payment method?----
----What is AOV overall?--------
--Average Order Value (AOV) means:
---Total revenue ÷ Total number of orders

SELECT SUM(payment_value) * 1.0/
COUNT(DISTINCT order_id) AS AOV FROM Payments_table

-----AOV is 160.99--------

----we can see that  the platform’s Average Order Value (AOV) is approximately 160.99, 
----indicating that customers spend around 161 per order on average.


-- Calculating average order value using actual payment amounts
-- One order is counted only once using DISTINCT order_id

---AOV by Payment Meathod-----
SELECT
    payment_type,
    SUM(payment_value) * 1.0 / COUNT(DISTINCT order_id) AS AOV
FROM payments_table
GROUP BY payment_type
ORDER BY AOV DESC;

----AOV by Product Category (FINAL VERSION)----

SELECT
    pr.product_category_name,
    SUM(p.payment_value) * 1.0 / COUNT(DISTINCT oi.order_id) AS AOV
FROM order_items_table oi
JOIN products_table pr
    ON oi.product_id = pr.product_id
JOIN payments_table p
    ON oi.order_id = p.order_id
GROUP BY pr.product_category_name
ORDER BY AOV DESC;

---4) How many active sellers are there on the platform, and does this number go up or down over time?--
----Active seller = seller who made at least one sale

---Count of active sellers
SELECT 
    COUNT(DISTINCT seller_id) AS active_sellers
FROM order_items_table 

---total active seller are 3095-----

----How that count changes over time----
SELECT
    YEAR(orders_table.order_purchase_timestamp) AS order_year,
    MONTH(orders_table.order_purchase_timestamp) AS order_month,
    COUNT(DISTINCT order_items_table.seller_id) AS active_sellers
FROM order_items_table
JOIN orders_table
    ON order_items_table.order_id = orders_table.order_id
GROUP BY
    YEAR(orders_table.order_purchase_timestamp),
    MONTH(orders_table.order_purchase_timestamp)
ORDER BY
    order_year,
    order_month;

	----From early 2017 onwards, the number of active sellers increased consistently, 
	-------showing that more sellers were joining and actively using the platform. 
	---Seller activity reached its highest point around mid-2018, suggesting that the marketplace had entered a more mature phase.
	----The sudden drop seen towards the end of 2018 appears to be caused by incomplete 
	----data rather than an actual decline in seller participation.

	---5)Which products sell the most, and how have their sales changed over time?

	SELECT TOP 10
    products_table.product_id,
    products_table.product_category_name,
    COUNT(order_items_table.product_id) AS items_sold
FROM order_items_table
JOIN products_table
    ON order_items_table.product_id = products_table.product_id
GROUP BY
    products_table.product_id,
    products_table.product_category_name
ORDER BY
    items_sold DESC;

	------furniture and decoration have been sold most folling with bet_table & bath and Garden tools------

	---how have product sales changed over time---

	SELECT
    products_table.product_id,
    products_table.product_category_name,
    YEAR(orders_table.order_purchase_timestamp) AS order_year,
    MONTH(orders_table.order_purchase_timestamp) AS order_month,
    COUNT(order_items_table.product_id) AS items_sold
FROM order_items_table
JOIN orders_table
    ON order_items_table.order_id = orders_table.order_id
JOIN products_table
    ON order_items_table.product_id = products_table.product_id
GROUP BY
    products_table.product_id,
    products_table.product_category_name,
    YEAR(orders_table.order_purchase_timestamp),
    MONTH(orders_table.order_purchase_timestamp)
ORDER BY
    products_table.product_id,
    order_year,
    order_month;

----The analysis shows that sales are distributed across a large number of products, 
----with most products selling in small quantities each month. Rather than a few products dominating sales, 
----demand is spread across multiple categories such as bed & bath, sports & leisure, household utilities, and beauty & health.
---Product-level sales often appear in short bursts, likely driven by promotions or seasonal demand,
---while category-level sales remain relatively consistent over time. 
---This indicates a diverse marketplace where overall performance is supported by steady 
---category demand rather than reliance on individual best-selling products

---6Do customer reviews and ratings help products sell more or perform better on the platform? 
---(Check sales with higher or lower ratings and identify if any correlation is there)

SELECT 
    Customers_review_table.review_score,
    SUM(Order_items_table.price) AS total_sales
FROM Customers_review_table
JOIN Orders_table 
    ON Customers_review_table.order_id = Orders_table.order_id
JOIN Order_items_table 
    ON Orders_table.order_id = Order_items_table.order_id
JOIN Products_table
    ON Order_items_table.product_id = Products_table.product_id
GROUP BY Customers_review_table.review_score
ORDER BY Customers_review_table.review_score;

----In this we can see that Total sale is higest on those product which review_score is 5 but the 
--lowest sale is on product with review score 2, This indicates that products with higher customer ratings generally 
---show better sales performance. 
---High-rated products tend to sell more units compared to low-rated products,
----suggesting a positive relationship between customer satisfaction and sales. 
---However the other factors such as price and product category also influence performance.


