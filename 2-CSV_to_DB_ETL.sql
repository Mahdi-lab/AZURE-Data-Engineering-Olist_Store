BEGIN TRANSACTION;
USE Olist;

-- Drop tables if they exist for re-creation (optional, uncomment to use)
DROP TABLE IF EXISTS #TempOrderItems;
DROP TABLE IF EXISTS #TempProducts;
DROP TABLE IF EXISTS #TempProductTranslations;
DROP TABLE IF EXISTS #TempSellers;
DROP TABLE IF EXISTS #TempOrders;
DROP TABLE IF EXISTS #TempCustomers;
DROP TABLE IF EXISTS #TempGeolocation;
DROP TABLE IF EXISTS #TempPayments;
DROP TABLE IF EXISTS #TempReviews;


-- Temporary table for Geolocation
CREATE TABLE #TempGeolocation (
    geolocation_zip_code_prefix NVARCHAR(10) NOT NULL,
    geolocation_lat DECIMAL(18, 15) NOT NULL,
    geolocation_lng DECIMAL(18, 15) NOT NULL,
    geolocation_city NVARCHAR(100) NOT NULL,
    geolocation_state CHAR(2) NOT NULL
);

-- Temporary table for Customers
CREATE TABLE #TempCustomers (
    customer_id NVARCHAR(50) NOT NULL,
    customer_unique_id NVARCHAR(50) NOT NULL,
    customer_zip_code_prefix NVARCHAR(10) NOT NULL,
    customer_city NVARCHAR(100) NOT NULL,
    customer_state CHAR(2) NOT NULL
);

-- Temporary table for Orders
CREATE TABLE #TempOrders (
    order_id NVARCHAR(50) NOT NULL,
    customer_id NVARCHAR(50) NOT NULL,
    order_status NVARCHAR(20) NOT NULL,
    order_purchase_timestamp DATETIME NOT NULL,
    order_approved_at DATETIME NULL,
    order_delivered_carrier_date DATETIME NULL,
    order_delivered_customer_date DATETIME NULL,
    order_estimated_delivery_date DATETIME NOT NULL
);

-- Temporary table for Payments
CREATE TABLE #TempPayments (
    order_id NVARCHAR(50) NOT NULL,
    payment_sequential INT NOT NULL,
    payment_type NVARCHAR(20) NOT NULL,
    payment_installments INT NOT NULL,
    payment_value DECIMAL(10, 2) NOT NULL
);

-- Temporary table for Reviews
CREATE TABLE #TempReviews (
    review_id NVARCHAR(50) NOT NULL,
    order_id NVARCHAR(50) NOT NULL,
    review_score INT NOT NULL,
    review_comment_title NVARCHAR(255) NULL,
    review_comment_message NVARCHAR(MAX) NULL,
    review_creation_date DATETIME NOT NULL,
    review_answer_timestamp DATETIME NULL
);

-- Temporary table for Products
CREATE TABLE #TempProducts (
    product_id NVARCHAR(50) NOT NULL,
    product_category_name NVARCHAR(50) NULL,
    product_name_length INT NULL,
    product_description_length INT NULL,
    product_photos_qty INT NULL,
    product_weight_g INT NULL,
    product_length_cm INT NULL,
    product_height_cm INT NULL,
    product_width_cm INT NULL
);

-- Temporary table for Sellers
CREATE TABLE #TempSellers (
    seller_id NVARCHAR(50) NOT NULL,
    seller_zip_code_prefix NVARCHAR(10) NOT NULL,
    seller_city NVARCHAR(100) NOT NULL,
    seller_state CHAR(2) NOT NULL
);

-- Temporary table for OrderItems
CREATE TABLE #TempOrderItems (
    order_id NVARCHAR(50) NOT NULL,
    order_item_id INT NOT NULL,
    product_id NVARCHAR(50) NOT NULL,
    seller_id NVARCHAR(50) NOT NULL,
    shipping_limit_date DATETIME NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    freight_value DECIMAL(10, 2) NOT NULL
);

-- Temporary table for ProductTranslations
CREATE TABLE #TempProductTranslations (
    product_category_name NVARCHAR(50) NOT NULL,
    product_category_name_english NVARCHAR(50) NOT NULL
);

--COMMIT TRANSACTION;


--BEGIN TRANSACTION
-- Perform BULK INSERT for each temporary table

-- BULK INSERT for Customers
BULK INSERT #TempCustomers
FROM 'C:\Users\mgbra\Desktop\Olist Project\data\olist_customers_dataset.csv'
WITH (
    FORMAT= 'CSV',
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',  
    FIRSTROW = 2, 
    MAXERRORS = 0
);

-- BULK INSERT for Geolocation
BULK INSERT #TempGeolocation
FROM 'c:\Users\mgbra\Desktop\Olist Project\data\olist_geolocation_dataset.csv'
WITH (
    FORMAT= 'CSV',
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',  
    FIRSTROW = 2, 
    MAXERRORS = 0
);

-- BULK INSERT for Orders
BULK INSERT #TempOrders
FROM 'c:\Users\mgbra\Desktop\Olist Project\data\olist_orders_dataset.csv'
WITH (
    FORMAT= 'CSV',
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',  
    FIRSTROW = 2, 
    MAXERRORS = 0
);

-- BULK INSERT for Payments
BULK INSERT #TempPayments
FROM 'c:\Users\mgbra\Desktop\Olist Project\data\olist_order_payments_dataset.csv'
WITH (
    FORMAT= 'CSV',
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',  
    FIRSTROW = 2, 
    MAXERRORS = 0
);

-- BULK INSERT for Reviews
BULK INSERT #TempReviews
FROM 'c:\Users\mgbra\Desktop\Olist Project\data\olist_order_reviews_dataset.csv'
WITH (
    FORMAT= 'CSV',
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',  
    FIRSTROW = 2, 
    MAXERRORS = 0
);

-- BULK INSERT sellers
BULK INSERT #TempSellers
FROM 'c:\Users\mgbra\Desktop\Olist Project\data\olist_sellers_dataset.csv'
WITH (
    FORMAT= 'CSV',
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',  
    FIRSTROW = 2, 
    MAXERRORS = 0
);

-- BULK INSERT for Products
BULK INSERT #TempProducts
FROM 'c:\Users\mgbra\Desktop\Olist Project\data\olist_products_dataset.csv'
WITH (
    FORMAT= 'CSV',
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',  
    FIRSTROW = 2, 
    MAXERRORS = 0
);

-- BULK INSERT for OrderItems
BULK INSERT #TempOrderItems
FROM 'c:\Users\mgbra\Desktop\Olist Project\data\olist_order_items_dataset.csv'
WITH (
    FORMAT= 'CSV',
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',  
    FIRSTROW = 2, 
    MAXERRORS = 0
);

-- BULK INSERT for Product Translations
BULK INSERT #TempProductTranslations
FROM 'c:\Users\mgbra\Desktop\Olist Project\data\product_category_name_translation.csv'
WITH (
    FORMAT= 'CSV',
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',  
    FIRSTROW = 2, 
    MAXERRORS = 0
);

-- Optional: Check record counts for verification
SELECT 'Customers Count' AS TableName, COUNT(*) AS RecordCount FROM #TempCustomers;
SELECT 'Geolocation Count' AS TableName, COUNT(*) AS RecordCount FROM #TempGeolocation;
SELECT 'Orders Count' AS TableName, COUNT(*) AS RecordCount FROM #TempOrders;
SELECT 'Payments Count' AS TableName, COUNT(*) AS RecordCount FROM #TempPayments;
SELECT 'Reviews Count' AS TableName, COUNT(*) AS RecordCount FROM #TempReviews;
SELECT 'Products Count' AS TableName, COUNT(*) AS RecordCount FROM #TempProducts;
SELECT 'OrderItems Count' AS TableName, COUNT(*) AS RecordCount FROM #TempOrderItems;
SELECT 'ProductTranslations Count' AS TableName, COUNT(*) AS RecordCount FROM #TempProductTranslations;
SELECT 'Sellers Counts' AS TableName, Count(*) AS RecordCount From #TempSellers

COMMIT TRANSACTION;
-------------------------------------------------------------------------------------------------

BEGIN TRANSACTION;
USE Olist;

-- check nulls in rows
select geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state 
from #TempGeolocation 
where geolocation_zip_code_prefix IS NULL OR 
	  geolocation_lat IS NULL OR
	  geolocation_lng IS NULL OR
	  geolocation_city IS NULL OR
	  geolocation_state IS NULL
ORDER BY geolocation_zip_code_prefix;

-- check for duplicate keys
SELECT geolocation_zip_code_prefix, Count(*) as count_keys
FROM #TempGeolocation
GROUP BY geolocation_zip_code_prefix
ORDER BY 1;

SELECT geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state, Count(*) as count_rows
FROM #TempGeolocation
GROUP BY geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state
ORDER BY geolocation_zip_code_prefix

SELECT customer_zip_code_prefix, count(*)
FROM #TempCustomers
GROUP BY customer_zip_code_prefix
ORDER BY customer_zip_code_prefix;
-- it seems like some locations have duplicated values
-- lets assume each area has a zip_code_prefix that includes a contimous number of coordinates
-- lets assume that each customer drops his coordinates on the map and the app assigns these coordinats to a zip code prefix
-- lets assume that some customers are in the same prefix but at slightly diffrent coordinate cauing a duplication of the key
-- based on the assumption there are multiple lat and long coordinats with small variation for the same zip code key
-- also some cities have variations in the nameing for the same zip code key
-- to conform to a unique constraints We will take the avarage lat and long coordinate and the largest variation of the same city name 
SELECT geolocation_zip_code_prefix, 
	   AVG(geolocation_lat) AS geolocation_lat, AVG(geolocation_lng) AS geolocation_lng, 
	   MAX(geolocation_city) AS geolocation_city, 
	   MAX(geolocation_state) AS geolocation_state,
	   COUNT(*) AS count_of_duplicates
FROM #TempGeolocation 
WHERE geolocation_zip_code_prefix IS NOT NULL AND 
	  geolocation_lat IS NOT NULL AND
	  geolocation_lng IS NOT NULL AND
	  geolocation_city IS NOT NULL AND
	  geolocation_state IS NOT NULL
GROUP BY geolocation_zip_code_prefix
ORDER BY geolocation_zip_code_prefix;

with unique_keys as(
select distinct geolocation_zip_code_prefix from #TempGeolocation)
select count(*) from unique_keys;
select count(*) from #TempGeolocation;

select distinct geolocation_city from #TempGeolocation
select distinct geolocation_zip_code_prefix, geolocation_city from #TempGeolocation order by 1,2
select geolocation_zip_code_prefix, max(geolocation_city) from #TempGeolocation group by geolocation_zip_code_prefix order by 1,2
-- we get a total of 19015 unique keys out of the 1000163 rows
-- city name requires more cleanup using a more advanced logic to fix the multiple city names for the same zip code prefix

-- Insert into Geolocation
INSERT INTO Geolocation (geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state)
SELECT geolocation_zip_code_prefix, 
	   AVG(geolocation_lat) AS geolocation_lat, AVG(geolocation_lng) AS geolocation_lng, 
	   MAX(geolocation_city) AS geolocation_city, 
	   MAX(geolocation_state) AS geolocation_state
FROM #TempGeolocation 
WHERE geolocation_zip_code_prefix IS NOT NULL AND 
	  geolocation_lat IS NOT NULL AND
	  geolocation_lng IS NOT NULL AND
	  geolocation_city IS NOT NULL AND
	  geolocation_state IS NOT NULL
GROUP BY geolocation_zip_code_prefix
ORDER BY geolocation_zip_code_prefix;


-- Some Sellers zip code keys are not present in the geolocation table 
select count(*) as count_zip_codes from #TempSellers;
select  count(distinct seller_zip_code_prefix) as count_distinct_zip_codes from #TempSellers;

select distinct gl.geolocation_zip_code_prefix, s.seller_zip_code_prefix 
from #TempSellers s
left join Geolocation gl on gl.geolocation_zip_code_prefix = s.seller_zip_code_prefix
-- WHERE gl.geolocation_zip_code_prefix IS NULL
order by 1;
-- exactly 7 sellers have no keys in the geolocation table
-- we will filter these sellers as their data is missing

select * 
from #TempSellers s
INNER JOIN Geolocation gl 
	ON gl.geolocation_zip_code_prefix = s.seller_zip_code_prefix
-- out of the 3095 sellers we have 3088 sellers data

-- Insert into Sellers
INSERT INTO Sellers (seller_id, seller_zip_code_prefix, seller_city, seller_state)
SELECT s.seller_id, s.seller_zip_code_prefix, s.seller_city, s.seller_state
FROM #TempSellers s
INNER JOIN Geolocation gl 
	ON gl.geolocation_zip_code_prefix = s.seller_zip_code_prefix;


-- some zip code locations are missing from the geolocation table
select * from #TempCustomers c 
left join geolocation g
	on g.geolocation_zip_code_prefix = c.customer_zip_code_prefix
where g.geolocation_zip_code_prefix is not null

-- missing code prefix zip code example
select * from Geolocation where geolocation_zip_code_prefix = 70324
-- 278 customers had geo location zip code not present in the geolocation table these customers will be dropped
-- the number of customers are now 99441 out of the 99163

-- Insert into Customers
INSERT INTO Customers (customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state)
SELECT c.customer_id, c.customer_unique_id, c.customer_zip_code_prefix, c.customer_city, c.customer_state
FROM #TempCustomers c 
INNER JOIN geolocation g
	on g.geolocation_zip_code_prefix = c.customer_zip_code_prefix;


-- Insert into Products
INSERT INTO Products (product_id, product_category_name, product_name_length, product_description_length, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm)
SELECT product_id, product_category_name, product_name_length, product_description_length, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm
FROM #TempProducts;


-- since we dropped some customers these customers orders should be dropped as well

select * from #TempOrders;

select distinct order_status from #TempOrders;

select * from customers c
inner join #TempOrders o
on c.customer_id = o.customer_id;

select count(distinct c.customer_id) from customers c
inner join #TempOrders o
on c.customer_id = o.customer_id
-- We noticed that the orders table has just one order per customer 
-- since the number of distinct custmers match the number of orders in the orders table
-- the total number of orders we are working with is 99163

-- Insert into Orders
INSERT INTO Orders (order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date)
SELECT o.order_id, o.customer_id, o.order_status, 
	   o.order_purchase_timestamp, o.order_approved_at, 
	   o.order_delivered_carrier_date, o.order_delivered_customer_date, 
	   o.order_estimated_delivery_date
FROM customers c
INNER JOIN #TempOrders o
ON c.customer_id = o.customer_id;


-- since we removed the orders of customers we don't have zip codes for
-- we need to remove payments for the removed orders 

SELECT order_id, COUNT(*) as counts FROM #TempPayments
group by order_id 
order by 2 desc;
-- the total number of orders with payment transactions is 99440 before removing the orders with incomplete data
select * from orders where order_id = 'fa65dad1b0e818e3ccc5cb0e39231352'

select sum(payment_value) from #TempPayments
where order_id = 'fa65dad1b0e818e3ccc5cb0e39231352'
Select * from #TempOrderItems where order_id = 'fa65dad1b0e818e3ccc5cb0e39231352'
select 392.55+65.44
-- a customer can pay from multiple different sources 
-- (order id fa... was payed by a over 20 vouchers transactions amounting to the toatal 392.55+65.44 total of the order)

SELECT count(distinct p.order_id) 
FROM #TempPayments p
LEFT JOIN orders o 
on o.order_id = p.order_id
WHERE o.order_id IS NOT NULL
-- there are 99440 orders in the payments table and 99163 in the filtered orders table
-- only 99162 match between the two tables making the payments missing one order payment and the orders missing 237 orders

SELECT * FROM #TempPayments p
LEFT JOIN orders o on o.order_id = p.order_id
WHERE o.order_id IS NULL
ORDER BY p.order_id, p.payment_sequential, payment_installments
-- the total number of payments with no orders data are 287
-- a total of 103599 payments' transaction are available at the cleaned payments table

-- Insert into Payments
INSERT INTO Payments (order_id, payment_sequential, payment_type, payment_installments, payment_value)
SELECT p.order_id, p.payment_sequential, p.payment_type, p.payment_installments, p.payment_value
FROM #TempPayments p
LEFT JOIN orders o on o.order_id = p.order_id
WHERE o.order_id IS NOT NULL
ORDER BY p.order_id, p.payment_sequential, payment_installments;


-- the orders id removed should also be removed from the reviews table
select count(*) as num_reviews from #TempReviews;
select count(distinct order_id) as num_orders_reviewed from #TempReviews;

select count(distinct o.order_id) as num_orders_reviewed_available from #TempReviews r
left join orders o on r.order_id = o.order_id
where o.order_id is not null;

select count(distinct o.order_id)  from #TempReviews r
join orders o on r.order_id = o.order_id;
select 98673-98397
-- the total number of reviews are 99224 and total number of order reviews 98673 
-- there are multiple reviews for the same order
-- 98397 out of the 98673 order_ids matche between the reviews and the orders table we shall drop the 276 reviews related to other order ids 

select count(*) from #TempReviews r
left join orders o on r.order_id = o.order_id
where o.order_id is not null
-- the total number of reviews available is 98945

-- Insert into Reviews
INSERT INTO Reviews (review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp)
SELECT r.review_id, r.order_id, r.review_score, r.review_comment_title, r.review_comment_message, r.review_creation_date, r.review_answer_timestamp
FROM #TempReviews r
LEFT JOIN orders o ON r.order_id = o.order_id
WHERE o.order_id IS NOT NULL;


-- we have to remove all orders that we filtered from the orderItems table
select count(*) as num_items from #TempOrderItems;
select count(distinct order_id) as num_orders from #TempOrderItems;

select count(distinct o.order_id) as num_orders_available from #TempOrderItems oi
left join orders o on oi.order_id = o.order_id
where o.order_id is not null;

select 98666 - 98392
-- we have a total of 112650 items ordered with only 98666 distinct orders 
-- out of the 98666 only 98393 match with the orders table with 274 un matching orders

SELECT count(*) FROM #TempOrderItems oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NOT NULL
-- num of available order_items 112348 out of the 112650
select 112650 - 112348

-- some sellers have been dropped and need to be addressed too

SELECT count(*) FROM #TempOrderItems oi
INNER JOIN orders o ON oi.order_id = o.order_id
INNER JOIN sellers s ON s.seller_id = oi.seller_id
-- after matching sellers we get 112,096
select 112650 - 112096

-- Insert into OrderItems
INSERT INTO OrderItems (order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value)
SELECT oi.order_id, oi.order_item_id, oi.product_id, oi.seller_id, oi.shipping_limit_date, oi.price, oi.freight_value
FROM #TempOrderItems oi
INNER JOIN orders o ON oi.order_id = o.order_id
INNER JOIN sellers s ON s.seller_id = oi.seller_id;

-- Insert into ProductTranslations
INSERT INTO ProductTranslations (product_category_name, product_category_name_english)
SELECT product_category_name, product_category_name_english
FROM #TempProductTranslations;


COMMIT TRANSACTION;

-------------------------------------------------------------------------------------------------

BEGIN TRANSACTION;

-- Drop temporary tables if they exist
IF OBJECT_ID('tempdb..#TempCustomers') IS NOT NULL
    DROP TABLE #TempCustomers;

IF OBJECT_ID('tempdb..#TempGeolocation') IS NOT NULL
    DROP TABLE #TempGeolocation;

IF OBJECT_ID('tempdb..#TempOrders') IS NOT NULL
    DROP TABLE #TempOrders;

IF OBJECT_ID('tempdb..#TempPayments') IS NOT NULL
    DROP TABLE #TempPayments;

IF OBJECT_ID('tempdb..#TempReviews') IS NOT NULL
    DROP TABLE #TempReviews;

IF OBJECT_ID('tempdb..#TempProducts') IS NOT NULL
    DROP TABLE #TempProducts;

IF OBJECT_ID('tempdb..#TempOrderItems') IS NOT NULL
    DROP TABLE #TempOrderItems;

IF OBJECT_ID('tempdb..#TempProductTranslations') IS NOT NULL
    DROP TABLE #TempProductTranslations;

IF OBJECT_ID('tempdb..#TempSellers') IS NOT NULL
    DROP TABLE #TempSellers

COMMIT TRANSACTION;