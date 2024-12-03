BEGIN TRANSACTION
USE olist_warehouse
DELETE FROM olist_warehouse.dbo.Dim_Geolocation;
DELETE FROM olist_warehouse.dbo.Dim_Customers;
DELETE FROM Olist_warehouse.dbo.Dim_Payments;
DELETE FROM Olist_warehouse.dbo.Dim_Reviews;
DELETE FROM Olist_warehouse.dbo.Dim_Orders;
DELETE FROM Olist_warehouse.dbo.Dim_Products;
DELETE FROM Olist_warehouse.dbo.Dim_Sellers;
DELETE FROM Olist_warehouse.dbo.Junk_OrderItems;
DELETE FROM Olist_warehouse.dbo.Dim_Date;
DELETE FROM Olist_warehouse.dbo.Fact_OrderItems
------ WAREHOUSE DIMENSIONS ------
----------------------------------

-- GEOLOCATION DIMENSION
INSERT INTO olist_warehouse.dbo.Dim_Geolocation(
	olist_db_id, geolocation_zip_code_prefix,
	geolocation_lat, geolocation_lng, 
	geolocation_city, geolocation_state, etl_date)
SELECT id, geolocation_zip_code_prefix, 
	geolocation_lat, geolocation_lng, 
	geolocation_city, geolocation_state, 
	CAST(GETDATE() AS DATE) AS etl_date 
FROM olist.dbo.geolocation;

SELECT warehouse_id, olist_db_id, geolocation_zip_code_prefix,
	geolocation_lat, geolocation_lng, 
	geolocation_city, geolocation_state, etl_date 
FROM olist_warehouse.dbo.Dim_Geolocation;

-- DIMENSION CUSTOMERS
INSERT INTO  Olist_warehouse.dbo.Dim_Customers (olist_db_id, customer_id,
	customer_unique_id, customer_zip_code_prefix, 
	customer_city, customer_state, etl_date)
SELECT 
	id, customer_id, customer_unique_id, 
	customer_zip_code_prefix, customer_city, customer_state,
	CAST(GETDATE() AS DATE) AS etl_date
FROM olist.dbo.Customers;

SELECT warehouse_id, olist_db_id, customer_id,
	customer_unique_id, customer_zip_code_prefix, 
	customer_city, customer_state, etl_date
FROM Olist_warehouse.dbo.Dim_Customers;

-- ORDERS DIMENSION
INSERT INTO Olist_warehouse.dbo.Dim_Orders(olist_db_id, order_id,
	customer_id, order_status, order_purchase_timestamp, 
	order_approved_at, order_delivered_carrier_date, 
	order_delivered_customer_date, order_estimated_delivery_date, etl_date)
SELECT id, order_id, customer_id, order_status,
	order_purchase_timestamp, order_approved_at, 
	order_delivered_carrier_date, order_delivered_customer_date, 
	order_estimated_delivery_date, CAST(GETDATE() AS DATE) AS etl_date
FROM olist.dbo.Orders;

SELECT warehouse_id, olist_db_id, order_id,
	customer_id, order_status, order_purchase_timestamp, 
	order_approved_at, order_delivered_carrier_date, 
	order_delivered_customer_date, order_estimated_delivery_date, etl_date
FROM Olist_warehouse.dbo.Dim_Orders;

-- PRODUCTS DIMENSION
INSERT INTO Olist_warehouse.dbo.Dim_Products(olist_db_id, product_id,
	product_category_name, product_name_length, 
	product_description_length, product_photos_qty, 
	product_weight_g, product_length_cm, 
	product_height_cm, product_width_cm, etl_date)
SELECT id, product_id, product_category_name,
	product_name_length, product_description_length,
	product_photos_qty, product_weight_g, product_length_cm,
	product_height_cm, product_width_cm, CAST(GETDATE() AS DATE) AS etl_date
FROM olist.dbo.Products;


SELECT warehouse_id, olist_db_id, product_id,
	product_category_name, product_name_length,
	product_description_length, product_photos_qty, product_weight_g, 
	product_length_cm, product_height_cm, product_width_cm, etl_date
FROM Olist_warehouse.dbo.Dim_Products;


-- SELLERS DIMENSION
INSERT INTO Olist_warehouse.dbo.Dim_Sellers(olist_db_id,
	seller_id, seller_zip_code_prefix,
	seller_city, seller_state, etl_date)
SELECT id, seller_id, seller_zip_code_prefix, seller_city, 
	seller_state, CAST(GETDATE() AS DATE) AS etl_date
FROM olist.dbo.Sellers;


SELECT warehouse_id, olist_db_id,
	seller_id, seller_zip_code_prefix,
	seller_city, seller_state, etl_date
FROM Olist_warehouse.dbo.Dim_Sellers;

------ WAREHOUSE JUNK DIMENSIONS ------

-- ORDER ITEMS JUNK DIMENSION
INSERT INTO Olist_warehouse.dbo.Junk_OrderItems(olist_db_id, order_id, 
	order_item_id, product_id, seller_id, etl_date)
SELECT id, order_id, order_item_id, product_id, seller_id, 
	CAST(GETDATE() AS DATE) AS etl_date
FROM olist.dbo.OrderItems;

SELECT warehouse_id, olist_db_id, order_id, 
	order_item_id, product_id, seller_id, etl_date
FROM Olist_warehouse.dbo.Junk_OrderItems;

------ WAREHOUSE SNOWFLAKE DIMENSIONS ------
--------------------------------------------

-- PAYMENTS SNOWFLAKE DIMENSION
INSERT INTO Olist_warehouse.dbo.Dim_Payments(dim_order_warehouse_id,
	olist_db_id, order_id, payment_sequential, payment_type,
	payment_installments, payment_value, etl_date)
SELECT ow.warehouse_id as dim_order_warehouse_id, p.id as olist_db_id, p.order_id, p.payment_sequential, 
	p.payment_type, p.payment_installments, 
	p.payment_value, CAST(GETDATE() AS DATE) AS etl_date
FROM olist.dbo.Payments p
JOIN olist.dbo.Orders o on o.order_id = p.order_id
JOIN Olist_warehouse.dbo.Dim_Orders ow on ow.olist_db_id = o.id;

SELECT warehouse_id, dim_order_warehouse_id,
	olist_db_id, order_id, payment_sequential, 
	payment_type, payment_installments, 
	payment_value, etl_date
FROM Olist_warehouse.dbo.Dim_Payments;


-- REVIEWS SNOWFLAKE DIMENSION
INSERT INTO Olist_warehouse.dbo.Dim_Reviews(dim_order_warehouse_id, olist_db_id,
	review_id, order_id, review_score, review_comment_title, 
	review_comment_message, review_creation_date, 
	review_answer_timestamp, etl_date)
SELECT
ow.warehouse_id as dim_order_warehouse_id , r.id as olist_db_id,
r.review_id, r.order_id, r.review_score, r.review_comment_title, 
r.review_comment_message, r.review_creation_date, r.review_answer_timestamp,
CAST(GETDATE() AS DATE) AS etl_date
FROM olist.dbo.Reviews r
JOIN olist.dbo.Orders o on o.order_id = r.order_id
JOIN Olist_warehouse.dbo.Dim_Orders ow on ow.olist_db_id = o.id;


SELECT warehouse_id, dim_order_warehouse_id, olist_db_id,
	review_id, order_id, review_score, review_comment_title, 
	review_comment_message, review_creation_date, 
	review_answer_timestamp, etl_date
FROM Olist_warehouse.dbo.Dim_Reviews;

------ DATE AND TIME DIMENSIONS------
-------------------------------------
SELECT MIN(CAST(shipping_limit_date AS DATE)) AS operational_start_date from olist.dbo.OrderItems;
SELECT CAST(GETDATE() AS DATE) AS etl_date; 

DECLARE @start_date DATE, @end_date DATE;

-- Set start date from the minimum shipping_limit_date
SELECT @start_date = MIN(CAST(order_purchase_timestamp AS DATE)) FROM olist.dbo.Orders;

-- Set end date as the current date
SET @end_date = CAST(GETDATE() AS DATE);

-- Execute the stored procedure with the selected dates
EXEC dbo.GenerateDimDateTable @start_date, @end_date;

SELECT * FROM Dim_Date;

------ WAREHOUSE FACT TABLE------
---------------------------------

select count(*) as count_order_items_rows from olist.dbo.OrderItems

INSERT INTO Olist_warehouse.dbo.Fact_OrderItems(
	order_item_id, order_id, 
	order_purchase_date,
	customer_id, 
	customer_location_id, 
	seller_id, 
	seller_location_id, 
	product_id, 
	shipping_limit_date, 
	price, 
	freight_value, 
	etl_date)
SELECT 
    -- oi.id AS OrderItem_operational_surrogate_ID, woi.olist_db_id AS Junk_OrderItem_operational_ID, 
		woi.warehouse_id AS order_item_id,
	-- o.id AS order_operational_surrogate_ID, wo.olist_db_id AS Dim_Orders_ID,
		wo.warehouse_id AS order_id, 
		CAST(FORMAT(wo.order_purchase_timestamp, 'yyyyMMdd') AS INT) AS customer_purchase_date_key,
	-- c.id as customer_operational_surrogate_ID, wc.olist_db_id AS Dim_Customer_ID,
		wc.warehouse_id AS customer_id,
	-- gc.id AS Customer_Geolocation_ID, wgc.olist_db_id AS Dim_Customer_Geolocation_ID,
		wgc.warehouse_id AS customer_geolocation_id,
	-- s.id AS Seller_operational_surrogate_ID, ws.olist_db_id AS Dim_Seller_operational_ID, 
		ws.warehouse_id AS seller_id,
    -- gs.id AS Seller_Geolocation_ID, wgs.olist_db_id AS Dim_Seller_Geolocation_ID, 
		wgs.warehouse_id AS seller_geolocation_id,
    -- p.id AS Product_operational_surrogate_ID, wp.olist_db_id AS Dim_Product_operational_surrogate_ID,
		wp.warehouse_id AS products_id,
		oi.shipping_limit_date, 
		oi.price, 
		oi.freight_value,
		CAST(GETDATE() AS DATE) AS etl_date
FROM Olist.dbo.OrderItems oi
JOIN Olist.dbo.Orders o ON o.order_id = oi.order_id
	JOIN Olist_warehouse.dbo.Dim_Orders wo ON wo.olist_db_id = o.id
	JOIN Olist_warehouse.dbo.Junk_OrderItems woi ON woi.olist_db_id = oi.id 
JOIN Olist.dbo.Customers c ON c.customer_id = o.customer_id
	JOIN Olist_warehouse.dbo.Dim_Customers wc ON wc.olist_db_id = c.id
JOIN Olist.dbo.Sellers s ON s.seller_id = oi.seller_id
	JOIN Olist_warehouse.dbo.Dim_Sellers ws ON ws.olist_db_id = s.id
JOIN Olist.dbo.Products p ON p.product_id = oi.product_id
	JOIN Olist_warehouse.dbo.Dim_Products wp ON wp.olist_db_id = p.id	
JOIN Olist.dbo.Geolocation gc ON gc.geolocation_zip_code_prefix = c.customer_zip_code_prefix
	JOIN Olist_warehouse.dbo.Dim_Geolocation wgc ON wgc.olist_db_id = gc.id
JOIN Olist.dbo.Geolocation gs ON gs.geolocation_zip_code_prefix = s.seller_zip_code_prefix
	JOIN Olist_warehouse.dbo.Dim_Geolocation wgs ON wgs.olist_db_id = gs.id;

SELECT warehouse_fact_id, order_item_id, order_id, 
	customer_id, customer_location_id, seller_id, seller_location_id, 
	product_id, shipping_limit_date, price, freight_value, etl_date
FROM Olist_warehouse.dbo.Fact_OrderItems

COMMIT TRANSACTION


SELECT 
    CAST(FORMAT(order_purchase_timestamp, 'yyyyMMdd') AS INT) AS calculated_date_key
FROM Olist.dbo.Orders
order by calculated_date_key